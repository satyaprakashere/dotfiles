#!/usr/bin/env bats

load "test_helper.bash"

setup() {
    common_setup
    mkdir -p "$TEST_TEMP_DIR/CodeRunner"
}

teardown() {
    common_teardown
}

@test "builder.sh: builds Node.js single file" {
    project_dir="$FIXTURES_DIR/single-node"
    mkdir -p "$project_dir"
    test_file="$project_dir/hello.js"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    mock_command "node" "echo 'Mock node running'"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    [ "$last_line" == "$TEST_TEMP_DIR/CodeRunner/hello_js" ]
    
    # Check if wrapper script uses node
    grep -q "node hello.js" "$last_line"
}

@test "builder.sh: builds TypeScript fallback with tsx" {
    project_dir="$FIXTURES_DIR/single-ts"
    mkdir -p "$project_dir"
    test_file="$project_dir/hello.ts"
    touch "$test_file"

    export CR_FILENAME="$test_file"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    # Mock deno to ensure it falls back to node/tsx if deno is not preferred
    # Actually, the logic is: if deno is available, use deno. Else use tsx.
    # We want to make sure it DOES NOT use bun even if available.
    
    # We don't mock bun here, so `command -v bun` will fail.
    # Mock bun to exist, but it should NOT be used
    mock_command "bun" "echo 'Bun should not be used'"
    
    # Ensure deno is NOT found by shadowing it with a non-executable or just not mocking it
    # and relying on a PATH that doesn't include it if possible, but that's hard.
    # Instead, let's mock deno to something that we can check.
    
    # If I want to test the TSX path, I need command -v deno to fail.
    # One way is to set PATH to ONLY include MOCKS_DIR for this run.
    
    # Mock npx
    mock_command "npx" "echo 'Mock npx running'"
    
    # Run with a restricted PATH to ensure only our mocks are visible, but keep system utils
    OLD_PATH="$PATH"
    export PATH="$MOCKS_DIR:/usr/bin:/bin:/usr/sbin:/sbin"
    run bash "$GENERAL_CR_BUILD_SH"
    export PATH="$OLD_PATH"
    
    echo "Output: $output" >&2
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    
    # Debug: show wrapper content
    cat "$last_line" >&2

    # Verify bun was NOT used (it would have been "bun run hello.ts")
    ! grep -q "bun run" "$last_line"
    
    # Verify npx tsx WAS used
    grep -q "npx tsx hello.ts" "$last_line"
}

@test "builder.sh: bunfig.toml is NOT recognized as a project root" {
    project=$(create_project "my-bun-app" "bunfig.toml" "index.js")
    export CR_FILENAME="$project/index.js"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    
    # Should NOT have "_Project" suffix because bunfig.toml is ignored
    [[ "$last_line" != *"_Project" ]]
    # Should be a single-file build result
    [[ "$last_line" == *"/index_js" ]]
}

@test "builder.sh: Node.js project uses npm start if available" {
    project=$(create_project "my-node-app" "package.json" "index.js")
    echo '{"scripts": {"start": "node index.js"}}' > "$project/package.json"
    export CR_FILENAME="$project/index.js"
    export CR_TMPDIR="$TEST_TEMP_DIR"
    
    run bash "$GENERAL_CR_BUILD_SH"
    [ "$status" -eq 0 ]
    last_line=$(echo "$output" | tail -n 1)
    
    # Check if wrapper script uses npm start
    grep -q "npm start" "$last_line"
}
