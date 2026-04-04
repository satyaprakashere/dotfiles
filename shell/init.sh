#!/bin/bash

# macOS Setup Script
# This script automates the installation of Homebrew, CLI tools, 
# macOS system defaults, and dotfile symlinking.

set -e # Exit on error

echo "🚀 Starting macOS setup..."

# ---------------------------------------------------------
# 1. Homebrew Installation
# ---------------------------------------------------------
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH immediately for the rest of the script
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed. Skipping..."
fi

# ---------------------------------------------------------
# 2. Package & Font Installation
# ---------------------------------------------------------
echo "Installing CLI tools..."
# Modern Rust-based CLI tools and utilities
PACKAGES=(
    eza ripgrep dust nushell dua-cli gitui xh bat zoxide 
    uutils-coreutils yazi hyperfine evil-helix fselect 
    ripgrep-all tokei presenterm starship fzf fd
)

brew install "${PACKAGES[@]}"

echo "Installing fonts..."
brew tap homebrew/cask-fonts || true
brew install --cask font-symbols-only-nerd-font font-fira-code-nerd-font

# ---------------------------------------------------------
# 3. macOS System Defaults
# ---------------------------------------------------------
echo "Applying macOS system defaults..."

# Keyboard: Fast key repeat (Lower = faster)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.sublimetext.4 ApplePressAndHoldEnabled -bool false

# Finder: Show all extensions and path bar
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Dock: Autohide and indicator lights
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-process-indicators -bool true

# Default editor for text files (MacVim)
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=org.vim.MacVim;}'

# Google Keystone parameters
sudo defaults write /Library/Preferences/com.google.Keystone.Parameters.plist TargetChannel extended
sudo defaults write /Library/Preferences/com.google.Keystone.Parameters.plist RollbackToTargetVersion -bool true

# ---------------------------------------------------------
# 4. Dotfile Symlinking
# ---------------------------------------------------------
echo "Creating symlinks for dotfiles..."
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

mkdir -p "$CONFIG_DIR"

# List of folders to link to ~/.config/
CONFIG_FOLDERS=("fish" "nvim" "ghostty" "alacritty" "helix" "zed" "doom")

for folder in "${CONFIG_FOLDERS[@]}"; do
    if [ -d "$DOTFILES_DIR/$folder" ]; then
        echo "Linking $folder to $CONFIG_DIR/$folder"
        ln -sfn "$DOTFILES_DIR/$folder" "$CONFIG_DIR/$folder"
    fi
done

# Single file symlinks
ln -sfn "$DOTFILES_DIR/starship.toml" "$CONFIG_DIR/starship.toml"

# ---------------------------------------------------------
# 5. Git Configuration
# ---------------------------------------------------------
echo "Configuring Git..."
# Replace with your actual name and email if not already set
if [ -z "$(git config --global user.name)" ]; then
    echo "Enter your Git name: "
    read git_name
    git config --global user.name "$git_name"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "Enter your Git email: "
    read git_email
    git config --global user.email "$git_email"
fi

git config --global init.defaultBranch main
git config --global core.editor "vim"

# ---------------------------------------------------------
# 6. Default Shell (Fish)
# ---------------------------------------------------------
if ! grep -q "/opt/homebrew/bin/fish" /etc/shells; then
    echo "Adding fish to /etc/shells..."
    echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
fi

if [[ "$SHELL" != "/opt/homebrew/bin/fish" ]]; then
    echo "Switching default shell to fish..."
    chsh -s /opt/homebrew/bin/fish
fi

echo "✅ Setup complete! Please restart your terminal."
