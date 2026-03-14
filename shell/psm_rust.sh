#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $(basename "$0") <process_name>"
    exit 1
fi

orig_name=$1
first_char="${orig_name:0:1}"
rest_of_name="${orig_name:1}"
SAFE_PATTERN="[$first_char]$rest_of_name"

VISITED_PIDS=" "
TOTAL_RSS=0
TOTAL_PRIVATE=0
TOTAL_VSZ=0
PROCESS_COUNT=0

## Create temporary files for cached data
PS_DATA_JSON=$(mktemp /tmp/psm_ps.json.XXXXXX)
PS_DATA_FLAT=$(mktemp /tmp/psm_ps.flat.XXXXXX)
TOP_DATA=$(mktemp /tmp/psm_top.XXXXXX)

# Cache all process data once using procs (Rust tool) for speed and structure
procs --insert Ppid --insert VmRss --insert VmSize --json > "$PS_DATA_JSON"
# Cache top data for private memory (rprvt, purg)
top -l 1 -stats pid,rprvt,purg -i 1 > "$TOP_DATA" 2>/dev/null

# Transform JSON into a pipe-delimited flat file
# Format: PID|PPID|PMEM(basis points)|RSS(bytes)|VSZ(bytes)|COMMAND
jq -r '.[] | "\(.PID)|\(.["Parent PID"] // 0)|\(.MEM)|\(.VmRSS)|\(.VmSize)|\(.Command // "<unknown>")"' "$PS_DATA_JSON" > "$PS_DATA_FLAT"

cleanup() {
    rm -f "$PS_DATA_JSON" "$PS_DATA_FLAT" "$TOP_DATA"
}
trap cleanup EXIT

# Colors
BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
RESET="\033[0m"

# Fast memory normalizer
normalize_kb() {
    local val=$1
    [[ -z "$val" || "$val" == "0" || "$val" == "N/A" ]] && echo 0 && return
    
    # Bytes to KB
    if [[ "$val" =~ ^[0-9]+$ ]]; then
        echo $((val / 1024))
        return
    fi

    # Handle units from top
    if [[ "$val" =~ ([0-9.]+)([GgMmKk]) ]]; then
        local n="${BASH_REMATCH[1]}"
        local u="${BASH_REMATCH[2]}"
        case "$u" in
            [Gg]) echo "$n" | awk '{print int($1 * 1048576)}' ;;
            [Mm]) echo "$n" | awk '{print int($1 * 1024)}' ;;
            [Kk]) echo "${n%.*}" ;;
        esac
    else
        echo "${val%.*}" | tr -dc '0-9'
    fi
}

format_mem() {
    local kb=$1
    if [ "$kb" -ge 1024 ]; then
        echo "$(echo "scale=1; $kb / 1024" | bc | sed 's/\.0$//')M"
    else
        echo "${kb}K"
    fi
}

# Recursively print and sum
print_and_sum_tree() {
    local pid=$1
    local indent=$2
    
    if [[ "$VISITED_PIDS" == *" $pid "* ]]; then return; fi
    VISITED_PIDS="$VISITED_PIDS$pid "
    
    # High-speed data extraction
    local line=$(rg -S "^$pid\|" "$PS_DATA_FLAT" | head -n 1)
    [ -z "$line" ] && return
    
    local _pid _ppid _pmem_bp _rss_bytes _vsz_bytes _full_path
    IFS='|' read _pid _ppid _pmem_bp _rss_bytes _vsz_bytes _full_path <<< "$line"
    
    # Extract executable name (first word, then basename)
    local exe_name=$(echo "$_full_path" | choose 0)
    local name=$(basename "$exe_name")
    # pmem is basis points (parts per 10000) in procs JSON
    local pmem=$(echo "scale=2; $_pmem_bp / 100" | bc | sed 's/^\./0./')
    [[ "$pmem" == "0" || "$pmem" == ".00" ]] && pmem="0.00"
    
    # Get Private memory
    local top_line=$(rg "^[[:space:]]*$pid[[:space:]]" "$TOP_DATA" | head -n 1)
    local rprvt_raw=$(echo "$top_line" | choose -f '[[:space:]]+' 1)
    local purg_raw=$(echo "$top_line" | choose -f '[[:space:]]+' 2)
    
    local rss_kb=$((_rss_bytes / 1024))
    local vsz_kb=$((_vsz_bytes / 1024))
    local priv_rss=$(normalize_kb "$rprvt_raw")
    local priv_purg=$(normalize_kb "$purg_raw")
    local private_kb=$((priv_rss + priv_purg))
    
    TOTAL_RSS=$((TOTAL_RSS + rss_kb))
    TOTAL_PRIVATE=$((TOTAL_PRIVATE + private_kb))
    TOTAL_VSZ=$((TOTAL_VSZ + vsz_kb))
    PROCESS_COUNT=$((PROCESS_COUNT + 1))
    
    # Alignment and Truncation
    local tree_prefix="${indent}└─ [${pid}] "
    local prefix_len=${#tree_prefix}
    local total_col_width=70
    local max_name_len=$((total_col_width - prefix_len))
    [ $max_name_len -lt 15 ] && max_name_len=15
    
    local display_name="$name"
    if [ ${#display_name} -gt $max_name_len ]; then
        display_name="${display_name:0:$((max_name_len-3))}..."
    fi
    
    local colored_name="${GREEN}${display_name}${RESET}"
    if echo "$name" | rg -qi "$orig_name"; then
        colored_name="${BOLD}${YELLOW}${display_name}${RESET}"
    fi
    
    local f_rss=$(format_mem $rss_kb)
    local f_priv=$(format_mem $private_kb)
    
    local final_visible_line="${tree_prefix}${display_name}"
    local final_visible_len=${#final_visible_line}
    local padding_width=$((total_col_width - final_visible_len))
    [ $padding_width -lt 0 ] && padding_width=0
    local spacer=$(printf "%*s" $padding_width "")
    
    # Clean output formatting
    printf "${CYAN}%s${RESET}└─ [${MAGENTA}%d${RESET}] %b%s | %6s%% | %12s | %12s\n" \
           "$indent" "$pid" "$colored_name" "$spacer" "$pmem" "$f_rss" "$f_priv"
    
    # Children
    local children=$(rg "^[0-9]+\|$pid\|" "$PS_DATA_FLAT" | choose -f '\|' 0)
    for child in $children; do
        print_and_sum_tree "$child" "  $indent"
    done
}

# Main
MATCHING_PIDS=$(rg -i "$orig_name" "$PS_DATA_FLAT" | choose -f '\|' 0)

SEP="--------------------------------------------------------------------------------------------------------------"

echo -e "${BOLD}Memory Analysis for '${YELLOW}$orig_name${RESET}${BOLD}' (Ultra-optimized):${RESET}"
printf "${BOLD}%-70s | %7s | %12s | %12s${RESET}\n" "Process Tree [PID]" "%MEM" "RES (Resident)" "PRIV (Private)"
echo "$SEP"

for pid_match in $MATCHING_PIDS; do
    ppid_val=$(rg "^$pid_match\|" "$PS_DATA_FLAT" | choose -f '\|' 1)
    is_parent_match=$(rg "^$ppid_val\|" "$PS_DATA_FLAT" | rg -i "$orig_name")
    
    if [ -z "$is_parent_match" ]; then
        print_and_sum_tree "$pid_match" ""
    fi
done

echo "$SEP"
fmt_mb() { echo "scale=2; $1 / 1024" | bc; }

echo -e "${BOLD}Summary Statistics:${RESET}"
printf "Total Processes:  ${BOLD}%d${RESET}\n" "$PROCESS_COUNT"
printf "Total RES/RSS:    ${GREEN}%8.2f MB${RESET} (Physical RAM + Shared Libs)\n" "$(fmt_mb $TOTAL_RSS)"
printf "Total Private:    ${YELLOW}%8.2f MB${RESET} (Estimated unique RAM usage)\n" "$(fmt_mb $TOTAL_PRIVATE)"
printf "Total Virtual:    ${CYAN}%8.2f MB${RESET} (Address Space)\n" "$(fmt_mb $TOTAL_VSZ)"
