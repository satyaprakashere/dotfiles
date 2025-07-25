[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish
fish_vi_key_bindings
fzf --fish | source

fish_add_path ~/.sdkman/bin
fish_add_path ~/.rustup/toolchains/stable-x86_64-apple-darwin/bin/
fish_add_path /usr/local/sbin
fish_add_path ~/.config/emacs/bin
 fish_add_path /usr/local/opt/openjdk/bin
 fish_add_path ~/github/zig

set --export BUN_INSTALL "$HOME/.bun"
set -gx CPPFLAGS -I/usr/local/opt/openjdk/includeó

alias gcc="gcc-15"
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

#starship init fish | source

set -x MallocNanoZone 0
set -x HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK true
set -x HOMEBREW_NO_AUTO_UPDATE true

# >>> coursier install directory >>>
#set -gx PATH "$PATH:/Users/satya/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<
#fish_add_path /usr/local/opt/llvm/bin
#fish_add_path /usr/local/opt/expat/bin
