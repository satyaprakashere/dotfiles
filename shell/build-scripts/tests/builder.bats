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

@test "builder.sh: builds Go project" {
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

@test "builder.sh: builds Go single file" {
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

@test "builder.sh: builds Rust project" {
    project=$(create_project "my-rust-app" "Cargo.toml" "src/main.rs")
    export CR_FILENAME="$project/src/main.rs"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_compiler "cargo"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/my-rust-app_Project" ]
}

@test "builder.sh: error on unknown file type" {
    export CR_FILENAME="/tmp/test.unknown"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 1 ]
    # "No build command defined for this file type: /tmp/test.unknown"
    [[ "$output" == *"No build command defined"* ]]
}

@test "builder.sh: builds Mojo single file" {
    project_dir="$FIXTURES_DIR/single-mojo"
    mkdir -p "$project_dir"
    test_file="$project_dir/hello.mojo"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_compiler "mojo"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/hello_mojo" ]
}

@test "builder.sh: builds Mojo project with magic" {
    project=$(create_project "my-mojo-app" "mojoproject.toml" "main.mojo")
    export CR_FILENAME="$project/main.mojo"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_compiler "magic"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/main_mojo" ]
    
    # Check if wrapper script was created with magic run
    grep -q "magic run mojo main.mojo" "$last_line"
}

@test "builder.sh: builds Mojo project with pixi" {
    project=$(create_project "my-pixi-app" "pixi.toml" "main.mojo")
    export CR_FILENAME="$project/main.mojo"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_compiler "pixi"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    # Check if wrapper script was created with pixi run
    grep -q "pixi run" "$last_line"
}

@test "builder.sh: builds Erlang standalone file" {
    project_dir="$FIXTURES_DIR/single-erl"
    mkdir -p "$project_dir"
    test_file="$project_dir/hello.erl"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_command "escript" "echo 'Mock escript running'"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/hello_erl" ]
    
    # Check if wrapper script uses escript
    grep -q "escript hello.erl" "$last_line"
}

@test "builder.sh: builds Erlang rebar3 project" {
    project=$(create_project "my-erl-app" "rebar.config" "src/my_erl_app.erl")
    export CR_FILENAME="$project/src/my_erl_app.erl"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_command "rebar3" "echo 'Mock rebar3 running'"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/my-erl-app_Project" ]
    
    # Check if wrapper script uses rebar3 shell
    grep -q "rebar3 shell" "$last_line"
}

@test "builder.sh: builds OCaml project" {
    project=$(create_project "my-ocaml-app" "dune-project" "bin/main.ml" "bin/dune")
    echo '(executable (name main))' > "$project/bin/dune"
    export CR_FILENAME="$project/bin/main.ml"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_command "dune" "echo 'Mock dune build successful'"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/my-ocaml-app_Project" ]
    
    # Check that wrapper exists and points to dune exec -- ./bin/main.exe
    [ -f "$TEST_TEMP_DIR/CodeRunner/my-ocaml-app_Project" ]
    wrapper_content=$(cat "$TEST_TEMP_DIR/CodeRunner/my-ocaml-app_Project")
    [[ "$wrapper_content" == *"dune exec -- ./bin/main.exe"* ]]
}

@test "builder.sh: builds OCaml single file" {
    project_dir="$FIXTURES_DIR/single-ocaml"
    mkdir -p "$project_dir"
    test_file="$project_dir/hello.ml"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_compiler "ocamlopt"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/hello_ml" ]
}

@test "builder.sh: builds Java single file" {
    project_dir="$FIXTURES_DIR/single-java"
    mkdir -p "$project_dir"
    test_file="$project_dir/Main.java"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"

    mock_command "javac" "echo 'Mock javac build successful'"

    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]

    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/Main_java" ]
}

@test "builder.sh: fails when Java single file compilation fails" {
    project_dir="$FIXTURES_DIR/single-java-fail"
    mkdir -p "$project_dir"
    test_file="$project_dir/Bad.java"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"

    mock_command "javac" "echo 'Main.java: error' >&2; exit 1"

    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -ne 0 ]
}

