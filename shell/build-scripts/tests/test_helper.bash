#!/usr/bin/env bash

# Load the source files
# Note: we use absolute paths to ensure they are found
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
CR_BUILD_SH="$SOURCE_DIR/code-runner/cr_build.sh"
GENERAL_CR_BUILD_SH="$SOURCE_DIR/code-runner/general_cr_build.sh"

common_setup() {
    # Create a temporary directory for tests
    TEST_TEMP_DIR="$(mktemp -d)"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    export CR_UNSAVED_DIR="$TEST_TEMP_DIR/unsaved"
    mkdir -p "$CR_UNSAVED_DIR"
    
    # Common test data directory
    FIXTURES_DIR="$TEST_TEMP_DIR/fixtures"
    mkdir -p "$FIXTURES_DIR"
    
    # Path to mock executables
    MOCKS_DIR="$TEST_TEMP_DIR/mocks"
    mkdir -p "$MOCKS_DIR"
    export PATH="$MOCKS_DIR:$PATH"
}

common_teardown() {
    # Remove the temporary directory
    rm -rf "$TEST_TEMP_DIR"
}

# Helper to mock shell commands
# Usage: mock_command "cmd_name" "script_body"
mock_command() {
    local cmd="$1"
    local body="$2"
    
    cat <<EOF > "$MOCKS_DIR/$cmd"
#!/bin/bash
$body
EOF
    chmod +x "$MOCKS_DIR/$cmd"
}

# Helper to mock compilers that create output files
mock_compiler() {
    local cmd="$1"
    mock_command "$cmd" '
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|-femit-bin|--out|-out)
            mkdir -p "$(dirname "$2")"
            touch "$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done
echo "Mock $cmd build successful"
'
}

# Helper to create a dummy project
# Usage: create_project "path/to/project" "marker_file" ["other_files"...]
create_project() {
    local project_path="$FIXTURES_DIR/$1"
    local marker="$2"
    shift 2
    
    mkdir -p "$project_path"
    touch "$project_path/$marker"
    
    for file in "$@"; do
        mkdir -p "$(dirname "$project_path/$file")"
        touch "$project_path/$file"
    done
    
    echo "$project_path"
}
