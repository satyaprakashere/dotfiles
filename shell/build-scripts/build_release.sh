#!/bin/bash

# A CLI wrapper for CodeRunner build scripts

if [ $# -lt 1 ]; then
    echo "Usage: $0 <source_file> [additional_flags...]"
    echo "Example: $0 main.go"
    exit 1
fi

# Get the directory where the current script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export BUILD_SCRIPT="$SCRIPT_DIR/code-runner/general_cr_build_release.sh"

if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "Error: General build script '$BUILD_SCRIPT' not found."
    exit 1
fi

export CR_FILENAME="$1"
shift 1

setup_env() {
    # Define constants needed by cr_build.sh
    export CR_TMPDIR="${CR_TMPDIR:-/tmp}"
    export CR_ENCODING="${CR_ENCODING:-4}" # 4 is UTF-8 in CodeRunner
    # CR_UNSAVED_DIR is usually CR_TMPDIR, unless overridden
    export CR_UNSAVED_DIR="${CR_UNSAVED_DIR:-$CR_TMPDIR}"

    # Set suggested output file to a temp directory
    mkdir -p "$CR_TMPDIR/CodeRunner"
    export CR_SUGGESTED_OUTPUT_FILE="$CR_TMPDIR/CodeRunner/$(basename "${CR_FILENAME//./_}")"

    # Ensure CR_FILENAME is an absolute path for consistency
    if [[ ! "$CR_FILENAME" = /* ]]; then
        export CR_FILENAME="$PWD/$CR_FILENAME"
    fi
}

setup_env

# Run the build script
# The build script will source cr_build.sh and call init_cr, handle_unsaved, etc.
# We capture stdout to get the path of the compiled binary (printed by post_build or check_checksum)
# Note: we use process substitution or a temporary file to keep stdout/stderr separate
# but here we just capture stdout and assume the last line is the path.
# echo "Building..."
BUILD_OUTPUT=$(bash "$BUILD_SCRIPT" "$@")
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    # The last line of stdout should be the path to the binary
    OUTPUT_FILE=$(echo "$BUILD_OUTPUT" | tail -n 1)

    if [ -n "$OUTPUT_FILE" ] && [ -f "$OUTPUT_FILE" ]; then
        echo "Build successful"
    else
        echo "Build successful, but output file '$OUTPUT_FILE' not found."
        exit 1
    fi
else
    echo "Build failed with status $BUILD_STATUS"
    exit $BUILD_STATUS
fi
