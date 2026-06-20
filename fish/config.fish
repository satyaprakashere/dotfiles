# ==============================================================================
# Fish Shell Configuration
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Homebrew Setup (Cross-Mac Support: Apple Silicon & Intel)
# ------------------------------------------------------------------------------
if test -d /opt/homebrew
    /opt/homebrew/bin/brew shellenv | source
else if test -d /usr/local/Homebrew -o -d /usr/local/Cellar
    /usr/local/bin/brew shellenv | source
else if type -q brew
    brew shellenv | source
end

# Autojump
if type -q brew; and test -f (brew --prefix)/share/autojump/autojump.fish
    source (brew --prefix)/share/autojump/autojump.fish
end

# ------------------------------------------------------------------------------
# 2. Environment Variables
# ------------------------------------------------------------------------------
set -gx EDITOR vim
set -gx MallocNanoZone 0
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK 1

# macOS SDK
if test -x /usr/bin/xcrun
    set -gx SDKROOT (xcrun --show-sdk-path 2>/dev/null)
end

# Bun
set -gx BUN_INSTALL "$HOME/.bun"

# Homebrew-dependent environment & compiler flags
if type -q brew
    # Rust mold linker
    if test -f (brew --prefix)/bin/mold
        set -gx RUSTFLAGS "-C opt-level=0 -C debuginfo=0 -C link-arg=-si -C link-arg=-fuse-ld="(brew --prefix)"/bin/mold"
    end

    # Dotnet
    if test -d (brew --prefix)/opt/dotnet/libexec
        set -gx DOTNET_ROOT (brew --prefix)/opt/dotnet/libexec
    end

    # Vulkan & MoltenVK
    if test -d (brew --prefix)/opt/vulkan-loader
        set -gx VULKAN_SDK (brew --prefix)/opt/vulkan-loader
        set -gx DYLD_LIBRARY_PATH (brew --prefix)/opt/vulkan-loader/lib:(brew --prefix)/opt/molten-vk/lib(test -n "$DYLD_LIBRARY_PATH"; and echo ":$DYLD_LIBRARY_PATH")
    end

    # C / C++ include and library paths
    set -gx LIBRARY_PATH (brew --prefix)/lib(test -n "$LIBRARY_PATH"; and echo ":$LIBRARY_PATH")
    set -gx C_INCLUDE_PATH (brew --prefix)/include(test -n "$C_INCLUDE_PATH"; and echo ":$C_INCLUDE_PATH")
    set -gx CPPFLAGS "-I"(brew --prefix)"/include"
    set -gx LDFLAGS "-L"(brew --prefix)"/lib"

    # LLVM (if installed)
    if test -d (brew --prefix)/opt/llvm
        fish_add_path (brew --prefix)/opt/llvm/bin
        set -ga CPPFLAGS "-I"(brew --prefix)"/opt/llvm/include"
        if test -d (brew --prefix)/opt/llvm/lib/c++
            set -ga LDFLAGS "-L"(brew --prefix)"/opt/llvm/lib/c++ -L"(brew --prefix)"/opt/llvm/lib/unwind -lunwind"
        end
    end

    # OpenJDK (if installed)
    if test -d (brew --prefix)/opt/openjdk
        fish_add_path (brew --prefix)/opt/openjdk/bin
        set -ga CPPFLAGS "-I"(brew --prefix)"/opt/openjdk/include"
    end
end

# ------------------------------------------------------------------------------
# 3. PATH Configuration
# ------------------------------------------------------------------------------
# User & Language Toolchains
fish_add_path ~/.local/bin
fish_add_path ~/.antigravity-ide/antigravity-ide/bin
fish_add_path ~/go/bin
fish_add_path ~/.bun/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.rustup/bin
fish_add_path ~/.config/emacs/bin
fish_add_path ~/.local/roc

# System & Package Managers
if type -q brew
    fish_add_path (brew --prefix)/bin
    fish_add_path (brew --prefix)/sbin
end
fish_add_path /run/current-system/sw/bin
fish_add_path /opt/local/bin
fish_add_path /usr/local/sbin

# ------------------------------------------------------------------------------
# 4. Integrations & Prompts
# ------------------------------------------------------------------------------
# Nix daemon
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

# Starship prompt
if type -q starship
    starship init fish | source
end

# FZF integration & keybindings
if type -q fzf
    fzf --fish | source
    bind \cf fzf-file-widget
    bind -e \ct
end

# Opam configuration
if test -r "$HOME/.opam/opam-init/init.fish"
    source "$HOME/.opam/opam-init/init.fish" > /dev/null 2>&1; or true
end

# Use fd for fzf if available
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --follow \
        --exclude .git \
        --exclude node_modules \
        --exclude Downloads \
        --exclude Library \
        --exclude .cargo \
        --exclude .rustup \
        --exclude "*.app" \
        --exclude "*.dmg" \
        --exclude "*.iso" \
        --exclude "*.pkg"'

    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --strip-cwd-prefix --follow \
        --exclude .git \
        --exclude node_modules \
        --exclude Downloads \
        --exclude Library \
        --exclude .cargo \
        --exclude .rustup'
end

# ------------------------------------------------------------------------------
# 5. Aliases
# ------------------------------------------------------------------------------
# Utilities
alias e="hx"
alias ls="eza --icons --group-directories-first --git"
alias man="tldr"
alias python="python3"
alias pip="uv pip"

# Development & Scripts
alias build="bash ~/dotfiles/shell/build-scripts/cbuild.sh"
alias run="bash ~/dotfiles/shell/build-scripts/crun.sh"
alias mem="~/dotfiles/shell/psm.sh"
alias lone="~/github/lone/build/aarch64/lone"

# Emacs
alias em='emacsclient -c -a ""'
alias et='emacsclient -t -a ""'
alias ke='emacsclient -e "(kill-emacs)"'

# Git
alias gits="git status"
alias gitd="git diff"
alias gitl="git log --oneline --graph --decorate --all"
alias gita="git add"
alias gitc="git clone --depth 1 --branch"
alias gitp="git push"
alias gitpra="git pull --rebase origin master --autostash"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Quick Config Access
alias vimrc="vim ~/.config/vim/vimrc"
alias fishrc="vim ~/.config/fish/config.fish"
alias ghostrc="vim ~/.config/ghostty/config"
alias emrc="vim ~/.config/doom/init.el"
alias makefile="vim Makefile"
