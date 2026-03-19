#!/bin/bash

# A CLI wrapper for CodeRunner build scripts

if [ $# -lt 1 ]; then
    echo "Usage: $0 <source_file> [additional_flags...]"
    echo "Example: $0 main.go"
    exit 1
fi

# Get the directory where the current script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export BUILD_SCRIPT="$SCRIPT_DIR/code-runner/general_cr_build.sh"

if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "Error: General build script '$BUILD_SCRIPT' not found."
    exit 1
fi

export CR_FILENAME="$1"
shift 1

# Run the compiled program based on its language
run_command() {
    local output_file="$1"
    shift
    case "$CR_FILENAME" in
        *.java)
            # Use the user's specific command for Java run
            # output_file contains classpath:classname
            local classpath="${output_file%:*}"
            local classname="${output_file##*:}"
            java --enable-preview -cp "$classpath" "$classname" "$@"
            ;;
        *.kt)
            # Use the user's specific command for Kotlin run
            # output_file contains classpath:classname
            local classpath="${output_file%:*}"
            local classname="${output_file##*:}"
            java --enable-preview -cp "$classpath" "$classname" "$@"
            ;;
        *.scala)
            # For Scala, we run the class from the output directory
            local class_name=$(basename "$CR_FILENAME" .scala)
            scala --classpath "$(dirname "$output_file")" --main-class "$class_name" -- "$@"
            ;;
        *.m)
            # Objective-C: run the compiled binary
            chmod +x "$output_file"
            "$output_file" "$@"
            ;;
        *)
            # Default: run the compiled binary (ensuring it is executable)
            chmod +x "$output_file"
            "$output_file" "$@"
            ;;
    esac
}

# Set up environment variables and create the output directory
setup_env() {
    # CR_TMPDIR: where temp files and build results are stored
    export CR_TMPDIR="${CR_TMPDIR:-/tmp}"
    # CR_ENCODING: CodeRunner's encoding code (4 = UTF-8)
    export CR_ENCODING="${CR_ENCODING:-4}" 
    # CR_UNSAVED_DIR: where unsaved files go (usually same as TMPDIR)
    export CR_UNSAVED_DIR="${CR_UNSAVED_DIR:-$CR_TMPDIR}"

    # Create the output directory and define the suggested binary path
    mkdir -p "$CR_TMPDIR/CodeRunner"
    export CR_SUGGESTED_OUTPUT_FILE="$CR_TMPDIR/CodeRunner/$(basename "${CR_FILENAME//./_}")"

    # Ensure CR_FILENAME is an absolute path for build scripts
    if [[ ! "$CR_FILENAME" = /* ]]; then
        export CR_FILENAME="$PWD/$CR_FILENAME"
    fi
}

# ... (existing content with new comments)
# Set up the environment (TMPDIR, output path, etc.)
setup_env

# Run the build script (general_cr_build.sh)
# We capture stdout to get the path of the compiled binary (printed by post_build or build_command)
# The build script sources cr_build.sh and handles language-specific build logic.
BUILD_OUTPUT=$(bash "$BUILD_SCRIPT" "$@")
BUILD_STATUS=$?

# Check if the build was successful (exit status 0)
if [ $BUILD_STATUS -eq 0 ]; then
    # The last line of stdout should be the path to the binary or a 'classpath:classname' string
    OUTPUT_FILE=$(echo "$BUILD_OUTPUT" | tail -n 1)

    # Verify that the output exists (either as a file or as a 'classpath:classname' string for Java/Kotlin)
    if [ -n "$OUTPUT_FILE" ] && ([ -f "$OUTPUT_FILE" ] || [[ "$OUTPUT_FILE" == *:* ]]); then
        echo "Build successful. Running: $OUTPUT_FILE"
        echo "----------------------------------------------------------------------"
        # Execute the language-specific run command
        run_command "$OUTPUT_FILE" "$@"
        EXIT_STATUS=$?
        echo "----------------------------------------------------------------------"
        echo "Program exited with status $EXIT_STATUS"
        exit $EXIT_STATUS
    else
        echo "Build successful, but output file '$OUTPUT_FILE' not found."
        exit 1
    fi
else
    # Build failed, exit with the build script's status
    echo "Build failed with status $BUILD_STATUS"
    exit $BUILD_STATUS
fi
