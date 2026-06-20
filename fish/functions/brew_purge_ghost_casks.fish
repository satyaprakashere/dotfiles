function brew_purge_ghost_casks --description 'Purge Homebrew tracking for casks that were manually deleted from Applications'
    echo "Scanning for ghost casks..."
    set -l found_ghosts 0

    for cask in (brew list --casks)
        # Query Homebrew's data to find the actual .app filename it installed
        set -l app_name (brew info --json=v2 $cask | jq -r '.casks[0].artifacts[]? | select(.app != null) | .app[0]' 2>/dev/null)
        
        # Fallback if jq parsing fails or structural output changes: use the cask name
        if test -z "$app_name" -o "$app_name" = "null"
            set app_name "$cask.app"
        end

        # Check the standard system application directories
        set -l path_found 0
        for dir in "/Applications" "$HOME/Applications"
            if test -d "$dir/$app_name"
                set path_found 1
                break
            end
        end

        # If the app bundle is nowhere to be found, it's a ghost record
        if test $path_found -eq 0
            set_color yellow
            echo "👻 Ghost cask detected: $cask ($app_name) is missing from disk."
            set_color normal
            
            # Force remove the tracking receipt and zap leftover configuration files
            brew uninstall --force --zap $cask
            set found_ghosts 1
        end
    end

    if test $found_ghosts -eq 0
        set_color green
        echo "✅ No ghost casks found. Your Application directories match Homebrew's database perfectly!"
        set_color normal
    else
        echo "Clean up complete. Running Homebrew cache maintenance..."
        command brew cleanup -s
    end
end
