[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish
fish_vi_key_bindings
fzf --fish | source

fish_add_path /usr/local/sbin
#fish_add_path /usr/local/opt/openjdk/bin
#fish_add_path ~/.sdkman/bin
fish_add_path ~/.ghcup/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.config/emacs/bin
#fish_add_path ~/.config/composer/vendor/bin

set --export BUN_INSTALL "$HOME/.bun"
#set -gx CPPFLAGS -I/usr/local/opt/openjdk/include

#alias gcc="gcc-15"
alias npm="bun"
alias node="bun"
#alias zig="zig2"

if status is-interactive
    # Commands to run in interactive sessions can go here
end

function zigr
    zig run -ODebug $argv[1]
end

function ktr
    kotlin $argv[1]
end

function cljr
    set ns $argv[1]
    clojure -Sdeps '{:paths ["."]}' -M -m $ns
end

function cdf
    set target (osascript -e '
        tell application "Finder"
            if (count of Finder windows) is not 0 then
                set thePath to (POSIX path of (target of front window as alias))
                return thePath
            else
                return ""
            end if
        end tell
    ')
    if test -n "$target"
        cd "$target"
    else
        echo "No Finder window is open."
    end
end

starship init fish | source

set -x MallocNanoZone 0
set -x HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK true
set -x HOMEBREW_NO_AUTO_UPDATE true

# >>> coursier install directory >>>
#set -gx PATH "$PATH:/Users/prakash/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<
#fish_add_path /usr/local/opt/llvm/bin
#fish_add_path /usr/local/opt/expat/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Added by Antigravity
#fish_add_path /Users/prakash/.antigravity/antigravity/bin

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
#test -r '/Users/prakash/.opam/opam-init/init.fish' && source '/Users/prakash/.opam/opam-init/init.fish' >/dev/null 2>/dev/null; or true
# END opam configuration
