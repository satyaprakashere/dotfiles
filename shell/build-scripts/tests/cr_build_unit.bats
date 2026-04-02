#!/usr/bin/env bats

load "test_helper.bash"

setup_file() {
    # Check dependencies before running tests
    if ! command -v sha256sum >/dev/null 2>&1; then
        echo "Error: sha256sum not found. Skipping tests that depend on it." >&2
    fi
}

setup() {
    common_setup
    # Source cr_build.sh to load functions into the test environment
    # We must mock enough so that it doesn't fail on source
    source "$CR_BUILD_SH"
}

teardown() {
    common_teardown
}

@test "find_project_root: finds root with marker file" {
    project=$(create_project "my-go-app" "go.mod" "src/main.go")
    
    run find_project_root "$project/src" "go.mod"
    [ "$status" -eq 0 ]
    [ "$output" == "$project" ]
}

@test "find_project_root: finds root with multiple markers" {
    project=$(create_project "my-java-app" "pom.xml" "src/main/java/Main.java")
    
    run find_project_root "$project/src/main/java" "pom.xml build.gradle"
    [ "$status" -eq 0 ]
    [ "$output" == "$project" ]
}

@test "find_project_root: fails when no marker exists" {
    mkdir -p "$FIXTURES_DIR/no-project/src"
    
    run find_project_root "$FIXTURES_DIR/no-project/src" "go.mod"
    [ "$status" -eq 1 ]
}

@test "init_cr: sets up paths correctly for single file" {
    export CR_FILENAME="/tmp/test.go"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    init_cr
    
    [ "$CR_SUGGESTED_OUTPUT_FILE" == "$TEST_TEMP_DIR/CodeRunner/test_go" ]
    [ "$CHECKSUM_FILE" == "$TEST_TEMP_DIR/CodeRunner/test_go.sha256" ]
}

@test "init_cr: sets up paths correctly for project file" {
    project=$(create_project "my-proj" "go.mod")
    export CR_FILENAME="$project/go.mod"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    init_cr
    
    [ "$CR_SUGGESTED_OUTPUT_FILE" == "$TEST_TEMP_DIR/CodeRunner/my-proj_Project" ]
    [ "$CHECKSUM_FILE" == "$TEST_TEMP_DIR/CodeRunner/my-proj_Project.sha256" ]
}

@test "handle_unsaved: correctly copies file when in CR_UNSAVED_DIR" {
    # Create an unsaved file in the unsaved dir
    mkdir -p "$CR_UNSAVED_DIR"
    echo "test_content" > "$CR_UNSAVED_DIR/testfile.sh"
    
    export CR_FILENAME="$CR_UNSAVED_DIR/testfile.sh"
    export LANGUAGE="sh"
    
    # Run the function
    (cd "$CR_UNSAVED_DIR" && handle_unsaved)
    
    # Note: handle_unsaved changes CR_FILENAME and creates a directory
    [ -d "$CR_UNSAVED_DIR/sh" ]
    [ -f "$CR_UNSAVED_DIR/sh/testfile.sh" ]
}

@test "post_build: creates checksum file upon success" {
    test_file="$FIXTURES_DIR/test.sh"
    echo "echo hello" > "$test_file"
    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    export LANGUAGE="sh"
    
    init_cr
    
    # Ensure the script directory exists
    mkdir -p "$(dirname "$CR_SUGGESTED_OUTPUT_FILE")"
    
    run post_build 0
    [ "$status" -eq 0 ]
    [ -f "$CHECKSUM_FILE" ]
}
