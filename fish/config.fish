set RUSTFLAGS "-C opt-level=0 -C debuginfo=0 -C link-arg=-si -C link-arg=-fuse-ld=/usr/local/bin/mold"

zoxide init fish | source
starship init fish | source
fzf --fish | source
#fish_vi_key_bindings
# [ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

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

alias j="z"
alias e="vim"
alias ls="eza --icons --group-directories-first --git"
alias ll="ls -l"
alias la="ls -a"
alias lT="ls --tree"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias python="python3"
alias mem="~/dotfiles/shell/psm.sh"
alias lone="~/github/lone/build/aarch64/lone"
alias run="bash $HOME/dotfiles/shell/build-scripts/build_run.sh"

# Git aliases
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate --all"
alias ga="git add"
alias gc="git commit"
alias gp="git push"

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

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

# Use fd instead of find for fzf (much faster)
# Updated fzf command to ignore large packages and hidden app folders
set -x FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --follow \
    --exclude .git \
    --exclude "*.app" \
    --exclude "*.dmg" \
    --exclude "*.iso" \
    --exclude "*.pkg"'

set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
