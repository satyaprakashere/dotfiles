function brew --description 'Wrapper for Homebrew to intercept upgrades and outdated checks'
    # Check if there are any arguments passed
    if test (count $argv) -gt 0
        
        switch $argv[1]
            case 'upgrade'
                # If they typed EXACTLY 'brew upgrade', use our security logic
                if test (count $argv) -eq 1
                    echo "Intercepting 'brew upgrade' to skip major version jumps..."
                    brew_security_upgrade
                else
                    # Let specific upgrades pass through natively (e.g. brew upgrade git)
                    command brew $argv
                end

            case 'outdated'
                # If they typed EXACTLY 'brew outdated', show categorized output
                if test (count $argv) -eq 1
                    brew_security_outdated
                else
                    # Let flags like 'brew outdated --json' pass through untouched
                    command brew $argv
                end

            case '*'
                # Pass all other commands natively to the real brew binary
                command brew $argv
        end
    else
        # Handle running plain 'brew' without arguments
        command brew
    end
end
