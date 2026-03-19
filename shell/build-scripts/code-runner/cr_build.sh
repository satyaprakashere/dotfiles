#!/bin/bash
# This is a CodeRunner compile script. Compile scripts are used to compile
# code before being run using the run command specified in CodeRunner
# preferences. This script is invoked with the following properties:
#
# Current directory:	The directory of the source file being run
#
# Arguments $1-$n:		User-defined compile flags	
#
# Environment:			$CR_FILENAME	Filename of the source file being run
#						$CR_ENCODING	Encoding code of the source file
#						$CR_TMPDIR		Path of CodeRunner's temporary directory
#
# This script should have the following return values:
# 
# Exit status:			0 on success (CodeRunner will continue and execute run command)
#
# Output (stdout):		On success, one line of text which can be accessed
#						using the $compiler variable in the run command
#
# Output (stderr):		Anything outputted here will be displayed in
#						the CodeRunner console

# Common functions for CodeRunner build and run scripts

# Encoding mapping for CodeRunner
declare -a enc
enc[4]="UTF-8"
enc[0]="MacRoman"
enc[30]="UTF-16"
enc[1]="ISO-8859-1"
enc[3]="EUC-JP"
enc[5]="ISO-2022-JP"
enc[6]="Shift_JIS"
enc[9]="ISO-8859-2"
enc[10]="UTF-16BE"
enc[11]="UTF-16LE"
enc[12]="GBK"
enc[13]="GB18030"
enc[14]="Big5"

# Initialize CodeRunner environment variables
init_cr() {
    # Resolve absolute path for suggested output file
    if [[ "$CR_FILENAME" = /* ]]; then
        [ -z "$CR_SUGGESTED_OUTPUT_FILE" ] && CR_SUGGESTED_OUTPUT_FILE="${CR_FILENAME//./_}"
    else
        [ -z "$CR_SUGGESTED_OUTPUT_FILE" ] && CR_SUGGESTED_OUTPUT_FILE="$PWD/${CR_FILENAME//./_}"
    fi
    # Set default values for unsaved dir and language
    [ -z "$CR_UNSAVED_DIR" ] && CR_UNSAVED_DIR="$CR_TMPDIR"
    [ -z "$LANGUAGE" ] && LANGUAGE="${CR_FILENAME##*.}"

    # Checksum file is used to avoid rebuilding if source hasn't changed
    CHECKSUM_FILE="$CR_SUGGESTED_OUTPUT_FILE.sha256"
}

# Search upward for a project root (e.g. where go.mod or Makefile is)
find_project_root() {
    local start_dir="$1"
    local markers=($2) # Space-separated list of markers
    local current_dir="$start_dir"

    while [[ "$current_dir" != "/" ]]; do
        for marker in "${markers[@]}"; do
            if [[ -f "$current_dir/$marker" ]] || [[ -d "$current_dir/$marker" ]]; then
                echo "$current_dir"
                return 0
            fi
        done
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

# Handle builds for files that haven't been saved yet (CodeRunner temp files)
handle_unsaved() {
    local lang_dir="$LANGUAGE"
    if [[ "$PWD" -ef "$CR_UNSAVED_DIR" ]]; then
        is_tmp_dir=true
        # If building an unsaved file, use a separate directory to avoid conflicts
        rm -rf "$CR_UNSAVED_DIR/$lang_dir/" &>/dev/null
        mkdir -p "$CR_UNSAVED_DIR/$lang_dir"
        cp "$CR_FILENAME" "$CR_UNSAVED_DIR/$lang_dir/$CR_FILENAME"
        cd "$lang_dir"
        CR_FILENAME="$lang_dir/$CR_FILENAME"
    fi
}

# Check if a built binary already exists and matches the source checksum
check_checksum() {
    if [ -f "$CHECKSUM_FILE" ]; then
        # Check if current source matches the saved checksum
        sha256sum -c "$CHECKSUM_FILE" --status

        # If it matches and the binary exists, we can skip the build
        if [ $? -eq 0 ] && [ -f "$CR_SUGGESTED_OUTPUT_FILE" ]; then
            echo "$CR_SUGGESTED_OUTPUT_FILE"
            exit 0
        fi
        # Otherwise, we output the path so build_run.sh knows where to expect it
        # (This line is captured by BUILD_OUTPUT in build_run.sh)
        echo "$CR_SUGGESTED_OUTPUT_FILE"
    fi
}

# Post-build cleanup and artifact management
post_build() {
    local status=$1
    local lang_dir="$LANGUAGE"
    if [ $status -eq 0 ]; then
        # If we were building an unsaved file, move fragments back to the main temp dir
        if [ "$is_tmp_dir" = true ]; then
            mv -f "$CR_UNSAVED_DIR/$lang_dir/"* "$CR_UNSAVED_DIR/"
        fi
        # Create a checksum to enable build caching next time
        sha256sum "$CR_FILENAME" > "$CHECKSUM_FILE"
        # Always output the suggest output path for CodeRunner/build_run.sh to capture
        echo "$CR_SUGGESTED_OUTPUT_FILE"
    fi
    exit $status
}

