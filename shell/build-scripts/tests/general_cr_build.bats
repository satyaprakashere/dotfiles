#!/usr/bin/env bats

load "test_helper.bash"

setup_file() {
    :
}

setup() {
    common_setup
    # Create required temp structure
    mkdir -p "$TEST_TEMP_DIR/CodeRunner"
}

teardown() {
    common_teardown
}

@test "general_cr_build.sh: builds Go project" {
    project=$(create_project "my-go-app" "go.mod" "src/main.go")
    export CR_FILENAME="$project/src/main.go"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    # Mock go
    mock_compiler "go"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    
    # Verify the output path is correctly printed by post_build
    # The last line should be the output path
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/my-go-app_Project" ]
}

@test "general_cr_build.sh: builds Go single file" {
    project_dir="$FIXTURES_DIR/single-go"
    mkdir -p "$project_dir"
    test_file="$project_dir/single.go"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_compiler "go"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/single_go" ]
}

@test "general_cr_build.sh: builds Rust project" {
    project=$(create_project "my-rust-app" "Cargo.toml" "src/main.rs")
    export CR_FILENAME="$project/src/main.rs"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_compiler "cargo"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/my-rust-app_Project" ]
}

@test "general_cr_build.sh: error on unknown file type" {
    export CR_FILENAME="/tmp/test.unknown"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 1 ]
    # "No build command defined for this file type: /tmp/test.unknown"
    [[ "$output" == *"No build command defined"* ]]
}
