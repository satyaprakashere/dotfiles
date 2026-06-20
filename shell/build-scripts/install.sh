#!/bin/bash

set -e

# Get the directory of this script
SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Target directory for symlinks
TARGET_DIR="$HOME/.local/bin"

echo "Installing Universal Code Builder & Runner to $TARGET_DIR..."

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Create symlinks
ln -sf "$SCRIPT_DIR/cbuild.sh" "$TARGET_DIR/cbuild"
ln -sf "$SCRIPT_DIR/crun.sh" "$TARGET_DIR/crun"
ln -sf "$SCRIPT_DIR/cclean.sh" "$TARGET_DIR/cclean"
ln -sf "$SCRIPT_DIR/gclean.sh" "$TARGET_DIR/gclean"

echo "Installation complete! ✓"
echo ""
echo "You can now use 'cbuild', 'crun', 'cclean', and 'gclean' commands from anywhere."
echo ""
echo "IMPORTANT: Make sure $TARGET_DIR is in your system PATH."
echo "If it's not, add the following line to your ~/.zshrc or ~/.bashrc:"
echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
