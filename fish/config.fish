if status is-interactive
    # Commands to run in interactive sessions can go here
end

zoxide init fish | source
starship init fish | source
#fzf --fish | source
#fish_vi_key_bindings
#[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

set -Ux EDITOR vim
set -x MallocNanoZone 0
set -x HOMEBREW_NO_AUTO_UPDATE true
set -x HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK true

# bun
set --export BUN_INSTALL "$HOME/.bun"
#set --export VCPKG_ROOT="$HOME/github/vcpkg"
#set --export JAVY_PLUGIN_WASM=/opt/javy/plugin.wasm

#set -gx CPPFLAGS -I/usr/local/opt/openjdk/include
#set -gx CPPFLAGS -I/opt/homebrew/opt/llvm/include

#set -gx LDFLAGS -L/opt/homebrew/opt/llvm/lib
#set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib/unwind -lunwind"
#set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib/c++ -L/opt/homebrew/opt/llvm/lib/unwind -lunwind"

alias j=z
alias e=vim
alias ls=eza
alias python=python3
alias lone=~/github/lone/build/aarch64/lone
#alias npm=bun
#alias node=bun
#alias gcc=gcc-15

fish_add_path ~/go/bin
fish_add_path ~/.bun/bin
fish_add_path ~/.ghcup/bin
fish_add_path ~/.cargo/bin
#fish_add_path ~/.config/emacs/bin
#fish_add_path ~/.local/bin
#fish_add_path ~/.sdkman/bin
#fish_add_path ~/.config/composer/vendor/bin
#fish_add_path ~/.rustup/toolchains/stable-x86_64-apple-darwin/bin/

fish_add_path /opt/local/bin
fish_add_path /usr/local/sbin
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/opt/llvm/bin
fish_add_path /opt/homebrew/sbin
#fish_add_path /usr/local/opt/llvm/bin
#fish_add_path /usr/local/opt/expat/bin

#fish_add_path /usr/local/opt/openjdk/bin
#fish_add_path /opt/homebrew/lib/ruby/gems/4.0.0/bin
#fish_add_path /opt/homebrew/Cellar/ruby/4.0.0/bin $PATH

# Added by Antigravity
#fish_add_path /Users/prakash/.antigravity/antigravity/bin

# Homebrew Config
set -x HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK true
set -x HOMEBREW_NO_AUTO_UPDATE true

# >>> coursier install directory >>>
#set -gx PATH "$PATH:/Users/prakash/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
#test -r '/Users/prakash/.opam/opam-init/init.fish' && source '/Users/prakash/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
#source ~/.orbstack/shell/init2.fish 2>/dev/null || :

