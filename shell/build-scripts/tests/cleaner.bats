#!/usr/bin/env bats

load "test_helper.bash"

CLEAN_SH="$SOURCE_DIR/cclean.sh"
CLEANER_CORE="$SOURCE_DIR/core/cleaner.sh"

setup() {
    common_setup
    source "$CLEANER_CORE"
}

teardown() {
    common_teardown
}

@test "detect_project_types: detects multiple project markers" {
    local proj_dir="$FIXTURES_DIR/polyglot"
    mkdir -p "$proj_dir"
    touch "$proj_dir/Cargo.toml"
    touch "$proj_dir/package.json"

    types=$(detect_project_types "$proj_dir")
    [[ "$types" == *"Rust"* ]]
    [[ "$types" == *"Node.js"* ]]
}

@test "clean_project_artifacts: cleans Rust target directory" {
    local proj_dir="$FIXTURES_DIR/rust_app"
    mkdir -p "$proj_dir/target/debug"
    touch "$proj_dir/Cargo.toml"
    touch "$proj_dir/target/debug/app"

    [ -d "$proj_dir/target" ]

    res=$(clean_project_artifacts "$proj_dir" "Rust" false false false)
    [ ! -d "$proj_dir/target" ]
}

@test "clean_project_artifacts: cleans Maven target and Gradle build directories" {
    local maven_dir="$FIXTURES_DIR/maven_app"
    mkdir -p "$maven_dir/target/classes"
    touch "$maven_dir/pom.xml"

    local gradle_dir="$FIXTURES_DIR/gradle_app"
    mkdir -p "$gradle_dir/build/libs" "$gradle_dir/.gradle"
    touch "$gradle_dir/build.gradle"

    clean_project_artifacts "$maven_dir" "Maven" false false false
    [ ! -d "$maven_dir/target" ]

    clean_project_artifacts "$gradle_dir" "Gradle" false false false
    [ ! -d "$gradle_dir/build" ]
    [ ! -d "$gradle_dir/.gradle" ]
}

@test "clean_project_artifacts: cleans Zig cache, out, and pkg directories" {
    local zig_dir="$FIXTURES_DIR/zig_app"
    mkdir -p "$zig_dir/zig-out" "$zig_dir/.zig-cache" "$zig_dir/zig-pkg" "$zig_dir/.zig-cache-global" "$zig_dir/.zig-global-cache-local"
    touch "$zig_dir/build.zig.zon"

    clean_project_artifacts "$zig_dir" "Zig" false false false
    [ ! -d "$zig_dir/zig-out" ]
    [ ! -d "$zig_dir/.zig-cache" ]
    [ ! -d "$zig_dir/zig-pkg" ]
    [ ! -d "$zig_dir/.zig-cache-global" ]
    [ ! -d "$zig_dir/.zig-global-cache-local" ]
}

@test "clean_project_artifacts: cleans Node.js build outputs and node_modules" {
    local node_dir="$FIXTURES_DIR/node_app"
    mkdir -p "$node_dir/dist" "$node_dir/.next" "$node_dir/build" "$node_dir/node_modules/pkg"
    touch "$node_dir/package.json"
    touch "$node_dir/tsconfig.tsbuildinfo"

    clean_project_artifacts "$node_dir" "Node.js" false false false
    [ ! -d "$node_dir/dist" ]
    [ ! -d "$node_dir/.next" ]
    [ ! -d "$node_dir/build" ]
    [ ! -d "$node_dir/node_modules" ]
    [ ! -f "$node_dir/tsconfig.tsbuildinfo" ]
}

@test "clean_project_artifacts: cleans Python cache and build directories" {
    local py_dir="$FIXTURES_DIR/py_app"
    mkdir -p "$py_dir/build" "$py_dir/dist" "$py_dir/__pycache__" "$py_dir/.pytest_cache"
    touch "$py_dir/pyproject.toml"
    touch "$py_dir/__pycache__/mod.cpython-310.pyc"

    clean_project_artifacts "$py_dir" "Python" false false false
    [ ! -d "$py_dir/build" ]
    [ ! -d "$py_dir/dist" ]
    [ ! -d "$py_dir/__pycache__" ]
    [ ! -d "$py_dir/.pytest_cache" ]
}

@test "clean_project_artifacts: dry-run does not delete directories" {
    local proj_dir="$FIXTURES_DIR/dry_run_app"
    mkdir -p "$proj_dir/target"
    touch "$proj_dir/Cargo.toml"
    touch "$proj_dir/target/binary"

    clean_project_artifacts "$proj_dir" "Rust" true false false
    [ -d "$proj_dir/target" ]
    [ -f "$proj_dir/target/binary" ]
}

@test "cclean.sh: cleans all projects in directory and subdirectories" {
    local workspace="$FIXTURES_DIR/workspace"
    mkdir -p "$workspace/backend/target"
    touch "$workspace/backend/Cargo.toml"
    touch "$workspace/backend/target/app"

    mkdir -p "$workspace/frontend/dist" "$workspace/frontend/node_modules/lodash"
    touch "$workspace/frontend/package.json"
    touch "$workspace/frontend/dist/bundle.js"

    mkdir -p "$workspace/services/auth/build"
    touch "$workspace/services/auth/build.gradle"
    touch "$workspace/services/auth/build/service.jar"

    run bash "$CLEAN_SH" "$workspace"
    [ "$status" -eq 0 ]

    # Verify that all build files across subdirectories were removed
    [ ! -d "$workspace/backend/target" ]
    [ ! -d "$workspace/frontend/dist" ]
    [ ! -d "$workspace/frontend/node_modules" ]
    [ ! -d "$workspace/services/auth/build" ]

    # Verify source and config files remain untouched
    [ -f "$workspace/backend/Cargo.toml" ]
    [ -f "$workspace/frontend/package.json" ]
    [ -f "$workspace/services/auth/build.gradle" ]
}

@test "cclean.sh: prunes .git and node_modules from recursion" {
    local workspace="$FIXTURES_DIR/git_workspace"
    mkdir -p "$workspace/backend/target"
    touch "$workspace/backend/Cargo.toml"

    # Create dummy marker inside .git that should NOT be cleaned
    mkdir -p "$workspace/.git/submodule/target"
    touch "$workspace/.git/submodule/Cargo.toml"
    touch "$workspace/.git/submodule/target/test"

    run bash "$CLEAN_SH" "$workspace"
    [ "$status" -eq 0 ]

    [ ! -d "$workspace/backend/target" ]
    # The .git directory contents must not be touched or pruned into
    [ -d "$workspace/.git/submodule/target" ]
}

@test "cclean.sh: fails with error on non-existent directory" {
    run bash "$CLEAN_SH" "$FIXTURES_DIR/nonexistent_dir_12345"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Error: Directory"* ]]
}

@test "clean_project_artifacts: cleans Clojure .clj-kondo/.cache but preserves config.edn" {
    local clj_dir="$FIXTURES_DIR/clojure_app"
    mkdir -p "$clj_dir/target" "$clj_dir/.cpcache" "$clj_dir/.clj-kondo/.cache/v1"
    touch "$clj_dir/deps.edn"
    touch "$clj_dir/.clj-kondo/config.edn"
    touch "$clj_dir/.clj-kondo/.cache/v1/cache.db"

    clean_project_artifacts "$clj_dir" "Clojure" false false false
    [ ! -d "$clj_dir/target" ]
    [ ! -d "$clj_dir/.cpcache" ]
    [ ! -d "$clj_dir/.clj-kondo/.cache" ]
    # config.edn must be preserved
    [ -f "$clj_dir/.clj-kondo/config.edn" ]
}

@test "clean_project_artifacts: cleans Elixir _build, deps, and LSP directories" {
    local elixir_dir="$FIXTURES_DIR/elixir_app"
    mkdir -p "$elixir_dir/_build/dev" "$elixir_dir/deps/phoenix" "$elixir_dir/.elixir_ls" "$elixir_dir/.lexical"
    touch "$elixir_dir/mix.exs"
    touch "$elixir_dir/mix.lock"
    touch "$elixir_dir/deps/phoenix/mix.exs"

    clean_project_artifacts "$elixir_dir" "Elixir" false false false
    [ ! -d "$elixir_dir/_build" ]
    [ ! -d "$elixir_dir/deps" ]
    [ ! -d "$elixir_dir/.elixir_ls" ]
    [ ! -d "$elixir_dir/.lexical" ]
    [ -f "$elixir_dir/mix.exs" ]
    [ -f "$elixir_dir/mix.lock" ]
}

@test "clean_project_artifacts: cleans Lean 4 .lake directory" {
    local lean_dir="$FIXTURES_DIR/lean_app"
    mkdir -p "$lean_dir/.lake/build" "$lean_dir/.lake/packages"
    touch "$lean_dir/lakefile.lean"
    touch "$lean_dir/lean-toolchain"
    touch "$lean_dir/.lake/build/Main.olean"

    clean_project_artifacts "$lean_dir" "Lean" false false false
    [ ! -d "$lean_dir/.lake" ]
    [ -f "$lean_dir/lakefile.lean" ]
    [ -f "$lean_dir/lean-toolchain" ]
}

@test "clean_project_artifacts: cleans Elm elm-stuff directory" {
    local elm_dir="$FIXTURES_DIR/elm_app"
    mkdir -p "$elm_dir/elm-stuff/0.19.1"
    touch "$elm_dir/elm.json"
    touch "$elm_dir/elm-stuff/0.19.1/Main.elmi"

    clean_project_artifacts "$elm_dir" "Elm" false false false
    [ ! -d "$elm_dir/elm-stuff" ]
    [ -f "$elm_dir/elm.json" ]
}

@test "clean_project_artifacts: cleans PHP vendor, test cache, and framework caches" {
    local php_dir="$FIXTURES_DIR/php_app"
    mkdir -p "$php_dir/vendor/monolog" "$php_dir/.phpunit.cache" "$php_dir/storage/framework/cache"
    touch "$php_dir/composer.json"
    touch "$php_dir/composer.lock"
    touch "$php_dir/composer.phar"
    touch "$php_dir/.phpunit.result.cache"

    clean_project_artifacts "$php_dir" "PHP" false false false
    [ ! -d "$php_dir/vendor" ]
    [ ! -d "$php_dir/.phpunit.cache" ]
    [ ! -d "$php_dir/storage/framework/cache" ]
    [ ! -f "$php_dir/composer.phar" ]
    [ ! -f "$php_dir/.phpunit.result.cache" ]
    [ -f "$php_dir/composer.json" ]
    [ -f "$php_dir/composer.lock" ]
}

@test "cclean.sh: prints help with --help" {
    run bash "$CLEAN_SH" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: cclean"* ]]
}

@test "get_project_prune_dirs: returns language-specific prune directories" {
    elixir_prune=$(get_project_prune_dirs "Elixir")
    [[ "$elixir_prune" == *"deps"* ]]
    [[ "$elixir_prune" == *"_build"* ]]
    [[ "$elixir_prune" != *"target"* ]]
    [[ "$elixir_prune" != *"vendor"* ]]

    rust_prune=$(get_project_prune_dirs "Rust")
    [[ "$rust_prune" == *"target"* ]]
    [[ "$rust_prune" != *"deps"* ]]
    [[ "$rust_prune" != *"vendor"* ]]
    [[ "$rust_prune" != *"obj"* ]]

    dotnet_prune=$(get_project_prune_dirs ".NET")
    [[ "$dotnet_prune" == *"bin"* ]]
    [[ "$dotnet_prune" == *"obj"* ]]
    [[ "$dotnet_prune" != *"deps"* ]]
    [[ "$dotnet_prune" != *"vendor"* ]]

    php_prune=$(get_project_prune_dirs "PHP")
    [[ "$php_prune" == *"vendor"* ]]
    [[ "$php_prune" != *"deps"* ]]
    [[ "$php_prune" != *"obj"* ]]

    node_prune=$(get_project_prune_dirs "Node.js")
    [[ "$node_prune" == *"dist"* ]]
    [[ "$node_prune" == *"node_modules"* ]]
    [[ "$node_prune" != *"deps"* ]]
    [[ "$node_prune" != *"obj"* ]]
}

@test "cclean.sh: project-sensitive pruning - deps inside non-Elixir project is not pruned" {
    local workspace="$FIXTURES_DIR/deps_sensitivity"
    # Create a C/Make project that contains a deps/ folder with a sub-project (Rust)
    mkdir -p "$workspace/c_app/deps/sub_rust/target/debug"
    touch "$workspace/c_app/Makefile"
    touch "$workspace/c_app/deps/sub_rust/Cargo.toml"
    touch "$workspace/c_app/deps/sub_rust/target/debug/sub_bin"

    # Also create an Elixir project with deps/ containing dummy files
    mkdir -p "$workspace/elixir_app/deps/phoenix_pkg/mix.exs"
    touch "$workspace/elixir_app/mix.exs"
    touch "$workspace/elixir_app/mix.lock"

    run bash "$CLEAN_SH" "$workspace"
    [ "$status" -eq 0 ]

    # The subproject in c_app/deps/sub_rust should have been discovered and its target cleaned!
    [ ! -d "$workspace/c_app/deps/sub_rust/target" ]
    [ -f "$workspace/c_app/deps/sub_rust/Cargo.toml" ]

    # The Elixir project should have its deps/ pruned from traversal and cleaned as an artifact
    [ ! -d "$workspace/elixir_app/deps" ]
}

@test "cclean.sh: project-sensitive pruning - vendor inside non-PHP project is not pruned" {
    local workspace="$FIXTURES_DIR/vendor_sensitivity"
    # Create a Go or Make project that contains a vendor/ folder with a nested Node project
    mkdir -p "$workspace/go_tool/vendor/nested_node/dist"
    touch "$workspace/go_tool/go.mod"
    touch "$workspace/go_tool/vendor/nested_node/package.json"
    touch "$workspace/go_tool/vendor/nested_node/dist/bundle.js"

    # Also create a PHP project with vendor/
    mkdir -p "$workspace/php_app/vendor/composer_pkg"
    touch "$workspace/php_app/composer.json"
    touch "$workspace/php_app/composer.lock"

    run bash "$CLEAN_SH" "$workspace"
    [ "$status" -eq 0 ]

    # The subproject in go_tool/vendor/nested_node should have been discovered and cleaned!
    [ ! -d "$workspace/go_tool/vendor/nested_node/dist" ]
    [ -f "$workspace/go_tool/vendor/nested_node/package.json" ]

    # The PHP app's vendor should be cleaned
    [ ! -d "$workspace/php_app/vendor" ]
}

@test "cclean.sh: project-sensitive pruning - obj and dist sensitivity" {
    local workspace="$FIXTURES_DIR/obj_dist_sensitivity"
    # Create a project with an obj/ directory that contains a nested Rust project (not a .NET project)
    mkdir -p "$workspace/graphics/obj/nested_tool/target"
    touch "$workspace/graphics/CMakeLists.txt"
    touch "$workspace/graphics/obj/nested_tool/Cargo.toml"
    touch "$workspace/graphics/obj/nested_tool/target/app"

    # Create a .NET project where obj and bin are build artifacts
    mkdir -p "$workspace/dotnet_app/obj/Debug" "$workspace/dotnet_app/bin/Debug"
    touch "$workspace/dotnet_app/App.csproj"
    touch "$workspace/dotnet_app/obj/Debug/project.assets.json"
    touch "$workspace/dotnet_app/bin/Debug/app.dll"

    run bash "$CLEAN_SH" "$workspace"
    [ "$status" -eq 0 ]

    # graphics/obj/nested_tool was visited and cleaned
    [ ! -d "$workspace/graphics/obj/nested_tool/target" ]
    [ -f "$workspace/graphics/obj/nested_tool/Cargo.toml" ]

    # dotnet_app obj and bin were pruned and cleaned
    [ ! -d "$workspace/dotnet_app/obj" ]
    [ ! -d "$workspace/dotnet_app/bin" ]
}



