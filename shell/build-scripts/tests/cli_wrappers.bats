#!/usr/bin/env bats

load "test_helper.bash"

# Path to the scripts under test
BUILD_SH="$SOURCE_DIR/build.sh"
BUILD_RUN_SH="$SOURCE_DIR/build_run.sh"

setup() {
    common_setup
    # Ensure temporary directory structure
    mkdir -p "$TEST_TEMP_DIR/CodeRunner"

    # Mock compilers to avoid actual building
    mock_compiler "go"
    mock_compiler "cargo"
}

teardown() {
    common_teardown
}

@test "build.sh: successfully builds a single file" {
    test_file="$FIXTURES_DIR/test.go"
    touch "$test_file"
    
    run bash "$BUILD_SH" "$test_file"
    [ "$status" -eq 0 ]
    
    # Check for success message and binary path in output
    [[ "$output" == *"Build successful"* ]]
    [[ "$output" == *"$TEST_TEMP_DIR/CodeRunner/test_go"* ]]
}

@test "build_run.sh: builds and executes binary" {
    test_file="$FIXTURES_DIR/hello.sh"
    echo 'echo "Hello from script"' > "$test_file"
    
    run bash "$BUILD_RUN_SH" "$test_file"
    [ "$status" -eq 0 ]
    
    # Check for build success and execution output
    [[ "$output" == *"Build successful"* ]]
    [[ "$output" == *"Hello from script"* ]]
}

@test "build.sh: outputs exactly one line to stdout for CodeRunner" {
    test_file="$FIXTURES_DIR/contract.go"
    touch "$test_file"
    
    # We use a subshell to capture ONLY stdout
    stdout_count=$(bash "$BUILD_SH" "$test_file" 2>/dev/null | wc -l | tr -d ' ')
    
    [ "$stdout_count" -eq 1 ]
}

@test "build.sh: fails when source file does not exist" {
    run bash "$BUILD_SH" "/path/to/nonexistent.go"
    [ "$status" -ne 0 ]
}
