function brew_security_outdated --description 'Show outdated packages categorized by upgrade risk'
    echo "Checking for outdated packages..."
    brew update > /dev/null

    set -l has_safe 0
    set -l has_major 0

    set -l raw_data (brew outdated --json=v2)

    # --- 1. MAJOR JUMPS FIRST ---
    echo ""
    set_color --bold yellow
    echo "=== MAJOR JUMPS (Potential Breaking Changes) ==="
    set_color normal

    # We map .installed_versions[0] to current, and .current_version to latest target
    echo $raw_data | jq -r '(.formulae[], .casks[]) | select(. != null) | "\(.name) \(.installed_versions[0]) \(.current_version)"' | while read -l name current latest
        if test -z "$latest" -o "$latest" = "null" -o -z "$current" -o "$current" = "null"
            continue
        end

        set -l current_parts (string split '.' $current)
        set -l latest_parts (string split '.' $latest)
        
        if test "$current_parts[1]" != "$latest_parts[1]"
            echo "  [MAJOR]  $name: $current -> $latest"
            set has_major 1
        end
    end
    if test $has_major -eq 0; echo "  None"; end

    # --- 2. SAFE UPDATES SECOND ---
    echo ""
    set_color --bold cyan
    echo "=== SAFE UPDATES (Minor / Patch / Security Fixes) ==="
    set_color normal

    echo $raw_data | jq -r '(.formulae[], .casks[]) | select(. != null) | "\(.name) \(.installed_versions[0]) \(.current_version)"' | while read -l name current latest
        if test -z "$latest" -o "$latest" = "null" -o -z "$current" -o "$current" = "null"
            continue
        end

        set -l current_parts (string split '.' $current)
        set -l latest_parts (string split '.' $latest)
        
        if test "$current_parts[1]" = "$latest_parts[1]"
            echo "  (Patch)  $name: $current -> $latest"
            set has_safe 1
        end
    end
    if test $has_safe -eq 0; echo "  None"; end
    echo ""
end
