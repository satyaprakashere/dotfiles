# ==============================================================================
# Fish Shell Configuration
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Homebrew Setup (Cross-Mac Support: Apple Silicon & Intel)
# ------------------------------------------------------------------------------
if not set -q HOMEBREW_PREFIX
    if test -d /opt/homebrew
        set -gx HOMEBREW_PREFIX /opt/homebrew
        set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
        set -gx HOMEBREW_REPOSITORY /opt/homebrew
        fish_add_path -gP /opt/homebrew/bin /opt/homebrew/sbin
        test -z "$MANPATH"; and set -gx MANPATH ''
        set -gx MANPATH ":$HOMEBREW_PREFIX/share/man" $MANPATH
        test -z "$INFOPATH"; and set -gx INFOPATH ''
        set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH
    else if test -d /usr/local/Homebrew -o -d /usr/local/Cellar
        set -gx HOMEBREW_PREFIX /usr/local
        set -gx HOMEBREW_CELLAR /usr/local/Cellar
        set -gx HOMEBREW_REPOSITORY /usr/local/Homebrew
        fish_add_path -gP /usr/local/bin /usr/local/sbin
    else if type -q brew
        brew shellenv | source
    end
end

# ------------------------------------------------------------------------------
# 2. Environment Variables
# ------------------------------------------------------------------------------
set -gx EDITOR vim
set -gx MallocNanoZone 0
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK 1

# Bun & Vcpkg
set -gx BUN_INSTALL "$HOME/.bun"
set -gx VCPKG_ROOT "$HOME/github/vcpkg"

# macOS SDK
if not set -q SDKROOT
    if test -d /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
        set -gx SDKROOT /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    else if test -d /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
        set -gx SDKROOT /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
    else if test -x /usr/bin/xcrun
        set -gx SDKROOT (xcrun --show-sdk-path 2>/dev/null)
    end
end

# Homebrew-dependent environment & compiler flags
if test -n "$HOMEBREW_PREFIX"
    # Dotnet
    if test -d "$HOMEBREW_PREFIX/opt/dotnet/libexec"
        set -gx DOTNET_ROOT "$HOMEBREW_PREFIX/opt/dotnet/libexec"
    end

    # Vulkan & MoltenVK
    if test -d "$HOMEBREW_PREFIX/opt/vulkan-loader"
        set -gx VULKAN_SDK "$HOMEBREW_PREFIX/opt/vulkan-loader"
        set -gx DYLD_LIBRARY_PATH "$HOMEBREW_PREFIX/opt/vulkan-loader/lib:$HOMEBREW_PREFIX/opt/molten-vk/lib"(test -n "$DYLD_LIBRARY_PATH"; and echo ":$DYLD_LIBRARY_PATH")
    end

    # C / C++ include and library paths
    set -gx LIBRARY_PATH "$HOMEBREW_PREFIX/lib"(test -n "$LIBRARY_PATH"; and echo ":$LIBRARY_PATH")
    set -gx C_INCLUDE_PATH "$HOMEBREW_PREFIX/include"(test -n "$C_INCLUDE_PATH"; and echo ":$C_INCLUDE_PATH")
    set -gx CPPFLAGS "-I$HOMEBREW_PREFIX/include"
    set -gx LDFLAGS "-L$HOMEBREW_PREFIX/lib"

    # LLVM (if installed)
    if test -d "$HOMEBREW_PREFIX/opt/llvm"
        fish_add_path "$HOMEBREW_PREFIX/opt/llvm/bin"
        set -ga CPPFLAGS "-I$HOMEBREW_PREFIX/opt/llvm/include"
        if test -d "$HOMEBREW_PREFIX/opt/llvm/lib/c++"
            set -ga LDFLAGS "-L$HOMEBREW_PREFIX/opt/llvm/lib/c++ -L$HOMEBREW_PREFIX/opt/llvm/lib/unwind -lunwind"
        end
    end

    # OpenJDK (if installed)
    if test -d "$HOMEBREW_PREFIX/opt/openjdk"
        fish_add_path "$HOMEBREW_PREFIX/opt/openjdk/bin"
        set -ga CPPFLAGS "-I$HOMEBREW_PREFIX/opt/openjdk/include"
    end
end

# ------------------------------------------------------------------------------
# 3. PATH Configuration
# ------------------------------------------------------------------------------
# User & Language Toolchains
fish_add_path ~/.local/bin \
    ~/.antigravity-ide/antigravity-ide/bin \
    ~/go/bin \
    ~/.bun/bin \
    ~/.cargo/bin \
    ~/.rustup/bin \
    ~/.config/emacs/bin \
    ~/.local/roc

# System & Package Managers
if test -n "$HOMEBREW_PREFIX"
    fish_add_path "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
end
fish_add_path /run/current-system/sw/bin /opt/local/bin /usr/local/sbin

# ------------------------------------------------------------------------------
# 4. Integrations
# ------------------------------------------------------------------------------
# Nix daemon
if not set -q __ETC_PROFILE_NIX_SOURCED; and test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

# Opam configuration
if test -r "$HOME/.opam/opam-init/init.fish"
    source "$HOME/.opam/opam-init/init.fish" >/dev/null 2>&1; or true
end

# ------------------------------------------------------------------------------
# 5. Interactive Shell Configuration
# ------------------------------------------------------------------------------
if status is-interactive
    # Autojump
    if not set -q AUTOJUMP_SOURCED; and test -n "$HOMEBREW_PREFIX"; and test -f "$HOMEBREW_PREFIX/share/autojump/autojump.fish"
        set -q OSTYPE; or set -gx OSTYPE darwin
        set -q AUTOJUMP_ERROR_PATH; or set -gx AUTOJUMP_ERROR_PATH "$HOME/Library/autojump/errors.log"
        source "$HOMEBREW_PREFIX/share/autojump/autojump.fish"
    end

    # Starship prompt (cached for fast startup)
    if type -q starship
        set -l starship_bin (type -p starship)
        set -l starship_cache "$HOME/.cache/fish/starship_init.fish"
        if not test -f "$starship_cache"; or test "$starship_bin" -nt "$starship_cache"
            mkdir -p "$HOME/.cache/fish"
            starship init fish --print-full-init >"$starship_cache"
        end
        source "$starship_cache"
    end

    # FZF integration & keybindings (cached)
    if type -q fzf
        set -l fzf_bin (type -p fzf)
        set -l fzf_cache "$HOME/.cache/fish/fzf_init.fish"
        if not test -f "$fzf_cache"; or test "$fzf_bin" -nt "$fzf_cache"
            mkdir -p "$HOME/.cache/fish"
            fzf --fish >"$fzf_cache"
        end
        source "$fzf_cache"
        bind \cf fzf-file-widget
        bind -e \ct
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

    # --------------------------------------------------------------------------
    # Aliases
    # --------------------------------------------------------------------------
    # Utilities
    alias e="hx"
    alias edit="hx"
    if type -q eza
        alias ls="eza --icons --group-directories-first --git"
        alias ll="eza -l --icons --group-directories-first --git"
        alias la="eza -la --icons --group-directories-first --git"
        alias lt="eza --tree --icons"
    end
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
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/prakash/.lmstudio/bin
# End of LM Studio CLI section
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-fish.sh
    . /nix/var/nix/profiles/default/etc/profile.d/nix-fish.sh
end

if test -d /opt/homebrew/opt/rustup/bin
    fish_add_path /opt/homebrew/opt/rustup/bin
end
