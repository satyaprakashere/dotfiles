function brew_security_upgrade --description 'Upgrade homebrew packages skipping major version jumps'
    echo "Scanning for minor patch / security updates..."
    brew update > /dev/null

    # Match the updated field structural query path mapping
    brew outdated --json=v2 | jq -r '(.formulae[], .casks[]) | select(. != null) | "\(.name) \(.installed_versions[0]) \(.current_version)"' | while read -l name current latest

        if test -z "$latest" -o "$latest" = "null" -o -z "$current" -o "$current" = "null"
            continue
        end

        set -l current_parts (string split '.' $current)
        set -l latest_parts (string split '.' $latest)

        set -l current_major $current_parts[1]
        set -l latest_major $latest_parts[1]

        if test "$current_major" = "$latest_major"
            set_color green
            echo "✅ Upgrading $name ($current -> $latest) - Safe Major Version Match"
            set_color normal
            brew upgrade $name
        else
            set_color yellow
            echo "⚠️  SKIPPING $name ($current -> $latest) - Major version jump detected!"
            set_color normal
        end
    end
end
