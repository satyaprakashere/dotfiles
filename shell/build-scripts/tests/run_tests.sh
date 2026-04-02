#!/bin/bash

# Get the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
    echo "Error: 'bats' (bats-core) is not installed." >&2
    echo "Please install it using: brew install bats-core" >&2
    exit 1
fi

# Run bats on all .bats files in the tests directory
bats "$DIR"/*.bats "$@"
