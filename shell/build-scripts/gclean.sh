#!/bin/bash

# A CLI tool to clean global development caches, package registries, and toolchains

# Get the directory where the current script is located
# Resolve the real path of the script even if it's a symlink or an alias
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

GLOBAL_CLEANER="$SCRIPT_DIR/core/global_cleaner.sh"

if [ ! -f "$GLOBAL_CLEANER" ]; then
    echo "Error: Global cleaner script '$GLOBAL_CLEANER' not found." >&2
    exit 1
fi

exec bash "$GLOBAL_CLEANER" "$@"
