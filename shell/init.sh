-- install homebrew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

-- set macvim as default editor for all files
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=org.vim.MacVim;}'


-- download fonts

-- setup config links

-- setup editors

-- setup build scripts
-- modern rust cli tools
brwe install eza ripgrep dust nushell dua-cli gitui xh bat zoxide uutils-coreutils yazi hyperfine evil-helix fselect ripgrep-all tokei presenterm

