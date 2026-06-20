#!/usr/bin/env bats

load "test_helper.bash"

GCLEAN_SH="$SOURCE_DIR/gclean.sh"
GLOBAL_CLEANER_CORE="$SOURCE_DIR/core/global_cleaner.sh"

setup() {
    common_setup
    source "$GLOBAL_CLEANER_CORE"
    # Mock HOME environment
    MOCK_HOME="$TEST_TEMP_DIR/mock_home"
    mkdir -p "$MOCK_HOME"
}

teardown() {
    common_teardown
}

# Helper to create a dummy directory with arbitrary size (in KB)
create_sized_dir() {
    local target_dir="$1"
    local size_kb="$2"
    mkdir -p "$target_dir"
    dd if=/dev/zero of="$target_dir/dummy_data.bin" bs=1024 count="$size_kb" 2>/dev/null
}

@test "check_first_level_dir: ignores directories smaller than threshold" {
    local small_tool="$MOCK_HOME/.smalltool"
    create_sized_dir "$small_tool" 100 # 100 KB (< 1 GB)

    run check_first_level_dir "$small_tool" 1048576 false
    [ "$status" -eq 1 ]
}

@test "check_first_level_dir: accepts directories larger than threshold" {
    local big_tool="$MOCK_HOME/.bigtool"
    create_sized_dir "$big_tool" 11000 # 11 MB (> 10 MB when threshold is 10MB)

    run check_first_level_dir "$big_tool" 10240 false
    [ "$status" -eq 0 ]
}

@test "clean_tier1: respects custom min-size and default threshold" {
    # 1. Create small tool (e.g. ~/.openjfx with 500 KB cache)
    create_sized_dir "$MOCK_HOME/.openjfx/cache" 500

    # 2. Create tool (e.g. ~/.npm with 12 MB cache)
    create_sized_dir "$MOCK_HOME/.npm/_cacache" 12000

    # Run Tier 1 with 10MB threshold
    clean_tier1 "$MOCK_HOME" false false false 10240

    # Small tool (< 10MB) must NOT be touched
    [ -d "$MOCK_HOME/.openjfx/cache" ]
    [ -f "$MOCK_HOME/.openjfx/cache/dummy_data.bin" ]

    # Tool (>= 10MB) MUST be cleaned when threshold is 10MB
    [ ! -d "$MOCK_HOME/.npm/_cacache" ]
}

@test "clean_tier2: cleans cargo registry when ~/.cargo >= 10MB" {
    create_sized_dir "$MOCK_HOME/.cargo/registry/cache" 12000
    create_sized_dir "$MOCK_HOME/.cargo/bin" 2000 # Installed CLI binary

    clean_tier2 "$MOCK_HOME" false false false 10240

    # Registry cache deleted
    [ ! -d "$MOCK_HOME/.cargo/registry/cache" ]
    # Cargo bin preserved
    [ -d "$MOCK_HOME/.cargo/bin" ]
}

@test "prune_rust_toolchains: keeps latest stable and latest nightly" {
    local rustup_tc="$MOCK_HOME/.rustup/toolchains"
    mkdir -p "$rustup_tc/1.80.0-aarch64-apple-darwin"
    mkdir -p "$rustup_tc/stable-aarch64-apple-darwin"
    mkdir -p "$rustup_tc/nightly-aarch64-apple-darwin"
    mkdir -p "$rustup_tc/beta-aarch64-apple-darwin"

    # Run with auto_yes=true (selects 'k')
    prune_rust_toolchains "$rustup_tc" false false true

    # Older version and beta removed
    [ ! -d "$rustup_tc/1.80.0-aarch64-apple-darwin" ]
    [ ! -d "$rustup_tc/beta-aarch64-apple-darwin" ]

    # Latest stable & nightly preserved
    [ -d "$rustup_tc/stable-aarch64-apple-darwin" ]
    [ -d "$rustup_tc/nightly-aarch64-apple-darwin" ]
}

@test "prune_lean_toolchains: keeps only latest Lean toolchain" {
    local lean_tc="$MOCK_HOME/.elan/toolchains"
    mkdir -p "$lean_tc/leanprover--lean4---v4.6.0"
    mkdir -p "$lean_tc/leanprover--lean4---v4.7.0"
    mkdir -p "$lean_tc/leanprover--lean4---v4.8.0"

    # Run with auto_yes=true (selects 'k')
    prune_lean_toolchains "$lean_tc" false false true

    # Older versions removed
    [ ! -d "$lean_tc/leanprover--lean4---v4.6.0" ]
    [ ! -d "$lean_tc/leanprover--lean4---v4.7.0" ]

    # Latest preserved
    [ -d "$lean_tc/leanprover--lean4---v4.8.0" ]
}

@test "prune_cabal_stores: keeps only latest GHC store" {
    local cabal_store="$MOCK_HOME/.local/state/cabal/store"
    mkdir -p "$cabal_store/ghc-9.4.8"
    mkdir -p "$cabal_store/ghc-9.10.3-fe9c"
    mkdir -p "$cabal_store/ghc-9.14.1-bcbf"

    # Run with auto_yes=true (selects 'k')
    prune_cabal_stores "$cabal_store" false false true

    # Older versions removed
    [ ! -d "$cabal_store/ghc-9.4.8" ]
    [ ! -d "$cabal_store/ghc-9.10.3-fe9c" ]

    # Latest preserved
    [ -d "$cabal_store/ghc-9.14.1-bcbf" ]
}

@test "clean_tier2: cleans cabal store under ~/.local/state/cabal" {
    create_sized_dir "$MOCK_HOME/.local/state/cabal/store" 12000

    clean_tier2 "$MOCK_HOME" false false false 10240

    [ ! -d "$MOCK_HOME/.local/state/cabal/store" ]
}

@test "gclean.sh: prints help with --help" {
    run bash "$GCLEAN_SH" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: gclean"* ]]
    [[ "$output" == *"--min-size"* ]]
}

