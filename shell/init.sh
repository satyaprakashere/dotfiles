-- install homebrew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

-- set macvim as default editor for all files
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=org.vim.MacVim;}'
defaults write com.sublimetext.4 ApplePressAndHoldEnabled -bool false

# Set the target channel to extended
sudo defaults write /Library/Preferences/com.google.Keystone.Parameters.plist TargetChannel extended

# Allow rollback to ensure it switches immediately
sudo defaults write /Library/Preferences/com.google.Keystone.Parameters.plist RollbackToTargetVersion -bool true


-- download fonts

-- setup config links

-- setup editors

-- setup build scripts
-- modern rust cli tools
brwe install eza ripgrep dust nushell dua-cli gitui xh bat zoxide uutils-coreutils yazi hyperfine evil-helix fselect ripgrep-all tokei presenterm

