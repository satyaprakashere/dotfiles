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
PS_DATA=$(mktemp /tmp/psm_ps.XXXXXX)
TOP_DATA=$(mktemp /tmp/psm_top.XXXXXX)

# Cache all process data once
# Columns: pid, ppid, %mem, rss, vsz, comm
ps -ax -o pid,ppid,%mem,rss,vsz,comm > "$PS_DATA"
# Cache top data for private memory (rprvt, purg)
top -l 1 -stats pid,rprvt,purg -i 1 > "$TOP_DATA" 2>/dev/null

cleanup() {
    rm -f "$PS_DATA" "$TOP_DATA"
}
trap cleanup EXIT

# Function to convert memory strings (e.g., 72M, 512K, 1G) to KB using pure Bash + awk for decimals
normalize_kb() {
    local val=$1
    local num unit
    
    # Remove any extra spaces
    val="${val// /}"
    
    if [[ "$val" =~ ^([0-9.]+)([GgMmKk]?)$ ]]; then
        num="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"
        
        case "$unit" in
            [Gg]) echo "$num" | awk '{print int($1 * 1048576)}' ;;
            [Mm]) echo "$num" | awk '{print int($1 * 1024)}' ;;
            [Kk]|"") echo "$num" | awk '{print int($1)}' ;;
            *) echo 0 ;;
        esac
    else
        echo 0
    fi
}

# Colors
BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
BLUE="\033[34m"
RESET="\033[0m"

# Function to format KB to a readable string (switches to MB if >=1024KB)
format_mem() {
    local kb=$1
    if [ "$kb" -ge 1024 ]; then
        # Use bc for precision and sed to remove trailing .0
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
    
    # Get pre-cached data for this PID from PS_DATA
    # Columns: pid, ppid, %mem, rss, vsz, comm
    local line=$(grep "^[[:space:]]*$pid[[:space:]]" "$PS_DATA" | head -n 1)
    [ -z "$line" ] && return
    
    # Extract fields using read
    local _pid _ppid _pmem _rss_raw _vsz_raw _full_path
    read _pid _ppid _pmem _rss_raw _vsz_raw _full_path <<< "$line"
    
    # Get short name
    local _name=$(basename "$_full_path")
    
    # Get Private memory from TOP_DATA
    local top_line=$(grep "^[[:space:]]*$pid[[:space:]]" "$TOP_DATA" | head -n 1)
    local _rprvt_raw=$(echo "$top_line" | awk '{print $2}')
    local _purg_raw=$(echo "$top_line" | awk '{print $3}')
    
    # Normalize values
    local rss_kb=$(normalize_kb "$_rss_raw")
    local vsz_kb=$(normalize_kb "$_vsz_raw")
    local rprvt_kb=$(normalize_kb "${_rprvt_raw:-0}")
    local purg_kb=$(normalize_kb "${_purg_raw:-0}")
    local private_kb=$((rprvt_kb + purg_kb))
    
    # Add to totals
    TOTAL_RSS=$((TOTAL_RSS + rss_kb))
    TOTAL_PRIVATE=$((TOTAL_PRIVATE + private_kb))
    TOTAL_VSZ=$((TOTAL_VSZ + vsz_kb))
    PROCESS_COUNT=$((PROCESS_COUNT + 1))
    
    # Formatting
    local colored_name="${GREEN}${_name}${RESET}"
    # Case-insensitive comparison for highlight (Bash 3.2 portable)
    if echo "$_name" | grep -qi "$orig_name"; then
        colored_name="${BOLD}${YELLOW}${_name}${RESET}"
    fi
    
    local f_rss=$(format_mem $rss_kb)
    local f_priv=$(format_mem $private_kb)
    
    local visible_line="${indent}└─ [${pid}] ${_name}"
    local visible_len=${#visible_line}
    local total_width=60
    local padding=$((total_width - visible_len))
    [ $padding -lt 0 ] && padding=0
    local spacer=$(printf "%*s" $padding "")
    
    echo -e "${CYAN}${indent}${RESET}└─ [${MAGENTA}${pid}${RESET}] ${colored_name}${spacer} | ${_pmem}% | $(printf "%14s" $f_rss) | $(printf "%14s" $f_priv)"
    
    # Find children using cached PS_DATA (PPID is 2nd column)
    local children=$(awk -v ppid="$pid" '$2 == ppid {print $1}' "$PS_DATA")
    for child in $children; do
        print_and_sum_tree "$child" "  $indent"
    done
}

# Main execution
MATCHING_PIDS=$(grep -i "$orig_name" "$PS_DATA" | awk '{print $1}')

echo -e "${BOLD}Memory Analysis for '${YELLOW}$orig_name${RESET}${BOLD}' (htop-inspired):${RESET}"
printf "${BOLD}%-60s | %6s | %14s | %14s${RESET}\n" "Process Tree [PID]" "%MEM" "RES (Resident)" "PRIV (Private)"
echo "-------------------------------------------------------------------------------------------------------------------"

for pid_match in $MATCHING_PIDS; do
    # Only start at root of matches (if parent isn't also a match)
    ppid_lookup=$(grep "^[[:space:]]*$pid_match[[:space:]]" "$PS_DATA" | awk '{print $2}')
    if ! grep -qi "^[[:space:]]*$ppid_lookup[[:space:]].*$orig_name" "$PS_DATA"; then
        print_and_sum_tree "$pid_match" ""
    fi
done

echo "-------------------------------------------------------------------------------------------------------------------"
fmt_mb() { echo "scale=2; $1 / 1024" | bc; }

echo -e "${BOLD}Summary Statistics:${RESET}"
printf "Total Processes:  ${BOLD}%d${RESET}\n" "$PROCESS_COUNT"
printf "Total RES/RSS:    ${GREEN}%7.2f MB${RESET} (Physical RAM + Shared Libs)\n" "$(fmt_mb $TOTAL_RSS)"
printf "Total Private:    ${YELLOW}%7.2f MB${RESET} (Estimated unique RAM usage)\n" "$(fmt_mb $TOTAL_PRIVATE)"
printf "Total Virtual:    ${CYAN}%7.2f MB${RESET} (Address Space)\n" "$(fmt_mb $TOTAL_VSZ)"
