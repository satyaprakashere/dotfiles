#!/bin/bash

# build-cli.sh
# A CLI wrapper for CodeRunner build scripts

if [ $# -lt 2 ]; then
    echo "Usage: $0 <build_script> <source_file> [additional_flags...]"
    echo "Example: $0 ./go_cr_build.sh main.go"
    exit 1
fi

export BUILD_SCRIPT="$1"
if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "Error: Build script '$BUILD_SCRIPT' not found."
    exit 1
fi

export CR_FILENAME="$2"
shift 2

# Define constants needed by cr_build.sh
export CR_TMPDIR="${CR_TMPDIR:-/tmp}"
export CR_ENCODING="${CR_ENCODING:-4}" # 4 is UTF-8 in CodeRunner
# CR_UNSAVED_DIR is usually CR_TMPDIR, unless overridden
export CR_UNSAVED_DIR="${CR_UNSAVED_DIR:-$CR_TMPDIR}"

# Ensure CR_FILENAME is an absolute path for consistency
if [[ ! "$CR_FILENAME" = /* ]]; then
    export CR_FILENAME="$PWD/$CR_FILENAME"
fi

# Run the build script
# The build script will source cr_build.sh and call init_cr, handle_unsaved, etc.
bash "$BUILD_SCRIPT" "$@"
