#!/bin/bash

# A CLI tool to clean build artifacts for projects across directories and subdirectories

# Get the directory where the current script is located
# Resolve the real path of the script even if it's a symlink or an alias
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

CLEAN_SCRIPT="$SCRIPT_DIR/core/cleaner.sh"

if [ ! -f "$CLE_SCRIPT" ] && [ ! -f "$CLEAN_SCRIPT" ]; then
    echo "Error: Cleaner script '$CLEAN_SCRIPT' not found." >&2
    exit 1
fi

exec bash "$CLEAN_SCRIPT" "$@"
