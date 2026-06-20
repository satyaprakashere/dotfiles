#!/bin/bash

# ==============================================================================
# Universal Project Cleaner
# Recursively discovers projects and cleans their build artifacts
# ==============================================================================

# Directories to prune during search to avoid deep traversal into build or vcs folders
PRUNE_DIRS=(
    ".git"
    ".hg"
    ".svn"
    "node_modules"
    "deps"
    "vendor"
    "elm-stuff"
    ".phpunit.cache"
    "target"
    "build"
    "_build"
    ".build"
    "dist"
    "out"
    "bin"
    "obj"
    ".gradle"
    ".zig-cache"
    "zig-cache"
    "zig-out"
    "zig-pkg"
    ".zig-cache-global"
    ".zig-global-cache-local"
    ".stack-work"
    "dist-newstyle"
    ".lake"
    ".dart_tool"
    "__pycache__"
    ".pytest_cache"
    ".mypy_cache"
    ".ruff_cache"
    ".venv"
    "venv"
    "env"
    ".env"
)

# Detect project types in a given directory
detect_project_types() {
    local dir="$1"
    local types=()

    [ -f "$dir/Cargo.toml" ] && types+=("Rust")
    [ -f "$dir/go.mod" ] && types+=("Go")
    [ -f "$dir/pom.xml" ] && types+=("Maven")
    if [ -f "$dir/build.gradle" ] || [ -f "$dir/build.gradle.kts" ] || [ -f "$dir/settings.gradle" ] || [ -f "$dir/settings.gradle.kts" ]; then
        types+=("Gradle")
    fi
    if [ -f "$dir/build.zig" ] || [ -f "$dir/build.zig.zon" ]; then
        types+=("Zig")
    fi
    if [ -f "$dir/package.json" ] || [ -f "$dir/deno.json" ] || [ -d "$dir/node_modules" ]; then
        types+=("Node.js")
    fi
    [ -f "$dir/CMakeLists.txt" ] && types+=("CMake")
    if [ -f "$dir/Makefile" ] && [ ! -f "$dir/CMakeLists.txt" ]; then
        types+=("Make")
    fi
    [ -f "$dir/Package.swift" ] && types+=("Swift")
    if [ -f "$dir/dune-project" ] || [ -f "$dir/dune" ]; then
        types+=("OCaml")
    fi
    [ -f "$dir/rebar.config" ] && types+=("Erlang")
    if [ -f "$dir/mix.exs" ] || [ -f "$dir/mix.lock" ]; then
        types+=("Elixir")
    fi
    if [ -f "$dir/deps.edn" ] || [ -f "$dir/project.clj" ] || [ -f "$dir/shadow-cljs.edn" ] || [ -f "$dir/bb.edn" ] || [ -f "$dir/nbb.edn" ] || [ -f "$dir/squint.edn" ] || [ -d "$dir/.clj-kondo" ]; then
        types+=("Clojure")
    fi
    if [ -f "$dir/stack.yaml" ] || [ -f "$dir/cabal.project" ] || compgen -G "$dir/*.cabal" >/dev/null; then
        types+=("Haskell")
    fi
    if compgen -G "$dir/*.csproj" >/dev/null || compgen -G "$dir/*.sln" >/dev/null; then
        types+=(".NET")
    fi
    [ -f "$dir/pubspec.yaml" ] && types+=("Dart")
    if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/Pipfile" ]; then
        types+=("Python")
    fi
    if compgen -G "$dir/*.nimble" >/dev/null; then
        types+=("Nim")
    fi
    [ -f "$dir/gleam.toml" ] && types+=("Gleam")
    if [ -f "$dir/mojoproject.toml" ] || [ -f "$dir/pixi.toml" ]; then
        types+=("Mojo")
    fi
    if [ -f "$dir/lakefile.lean" ] || [ -f "$dir/lakefile.toml" ] || [ -f "$dir/lean-toolchain" ] || [ -d "$dir/.lake" ]; then
        types+=("Lean")
    fi
    if [ -f "$dir/elm.json" ] || [ -d "$dir/elm-stuff" ]; then
        types+=("Elm")
    fi
    if [ -f "$dir/composer.json" ] || [ -f "$dir/composer.lock" ] || [ -d "$dir/vendor" ]; then
        types+=("PHP")
    fi
    [ -f "$dir/ols.json" ] && types+=("Odin")

    echo "${types[@]}"
}

# Calculate size in kilobytes of a file or directory
get_size_kb() {
    local target="$1"
    if [ -e "$target" ]; then
        local size
        size=$(du -sk "$target" 2>/dev/null | awk '{print $1}')
        echo "${size:-0}"
    else
        echo 0
    fi
}

# Format kilobytes into human-readable size
format_size() {
    local kb="$1"
    if [ "$kb" -ge 1048576 ]; then
        awk -v k="$kb" 'BEGIN {printf "%.2f GB", k/1048576}'
    elif [ "$kb" -ge 1024 ]; then
        awk -v k="$kb" 'BEGIN {printf "%.1f MB", k/1024}'
    else
        echo "${kb} KB"
    fi
}

# Clean build artifacts for a specific project directory given its detected types
# Returns: outputs cleaned paths and prints summary
clean_project_artifacts() {
    local dir="$1"
    local types=($2)
    local dry_run="$3"
    local verbose="$4"
    local run_tool_commands="$5"

    local artifacts_to_remove=()
    local dir_kb=0

    for ptype in "${types[@]}"; do
        case "$ptype" in
            "Rust")
                [ -d "$dir/target" ] && artifacts_to_remove+=("$dir/target")
                ;;
            "Go")
                # Remove binaries generated in project root if any
                local module_name=""
                if [ -f "$dir/go.mod" ]; then
                    module_name=$(grep -E '^module\s+' "$dir/go.mod" | head -n 1 | awk '{print $2}')
                    module_name=$(basename "$module_name")
                fi
                if [ -n "$module_name" ] && [ -f "$dir/$module_name" ] && [ -x "$dir/$module_name" ]; then
                    artifacts_to_remove+=("$dir/$module_name")
                fi
                local dir_base="$(basename "$dir")"
                if [ -n "$dir_base" ] && [ -f "$dir/$dir_base" ] && [ -x "$dir/$dir_base" ]; then
                    artifacts_to_remove+=("$dir/$dir_base")
                fi
                if [ "$run_tool_commands" = true ] && command -v go >/dev/null 2>&1; then
                    if [ "$dry_run" = true ]; then
                        [ "$verbose" = true ] && echo "    (dry-run) would run: go clean in $dir"
                    else
                        (cd "$dir" && go clean 2>/dev/null)
                    fi
                fi
                ;;
            "Maven")
                [ -d "$dir/target" ] && artifacts_to_remove+=("$dir/target")
                ;;
            "Gradle")
                [ -d "$dir/build" ] && artifacts_to_remove+=("$dir/build")
                [ -d "$dir/.gradle" ] && artifacts_to_remove+=("$dir/.gradle")
                ;;
            "Zig")
                for d in zig-out .zig-cache zig-cache zig-pkg .zig-cache-global .zig-global-cache-local; do
                    [ -d "$dir/$d" ] && artifacts_to_remove+=("$dir/$d")
                done
                ;;
            "Node.js")
                for d in dist build out .next .nuxt .turbo .parcel-cache .svelte-kit .output coverage node_modules; do
                    [ -d "$dir/$d" ] && artifacts_to_remove+=("$dir/$d")
                done
                for f in $(compgen -G "$dir/*.tsbuildinfo" 2>/dev/null); do
                    [ -f "$f" ] && artifacts_to_remove+=("$f")
                done
                ;;
            "CMake")
                for d in build CMakeFiles; do
                    [ -d "$dir/$d" ] && artifacts_to_remove+=("$dir/$d")
                done
                for d in $(compgen -G "$dir/cmake-build-*" 2>/dev/null); do
                    [ -d "$d" ] && artifacts_to_remove+=("$d")
                done
                for f in CMakeCache.txt cmake_install.cmake; do
                    [ -f "$dir/$f" ] && artifacts_to_remove+=("$dir/$f")
                done
                ;;
            "Make")
                # If Makefile has a clean target, we can execute it if tools enabled
                if [ "$run_tool_commands" = true ] && [ -f "$dir/Makefile" ]; then
                    if make -C "$dir" -n clean >/dev/null 2>&1; then
                        if [ "$dry_run" = true ]; then
                            [ "$verbose" = true ] && echo "    (dry-run) would run: make clean in $dir"
                        else
                            make -C "$dir" clean >/dev/null 2>&1
                        fi
                    fi
                fi
                # Also clean common compiled objects
                for f in $(compgen -G "$dir/*.o" 2>/dev/null) $(compgen -G "$dir/*.a" 2>/dev/null) $(compgen -G "$dir/*.so" 2>/dev/null) $(compgen -G "$dir/*.dylib" 2>/dev/null); do
                    [ -f "$f" ] && artifacts_to_remove+=("$f")
                done
                for d in $(compgen -G "$dir/*.dSYM" 2>/dev/null); do
                    [ -d "$d" ] && artifacts_to_remove+=("$d")
                done
                ;;
            "Swift")
                [ -d "$dir/.build" ] && artifacts_to_remove+=("$dir/.build")
                ;;
            "OCaml")
                [ -d "$dir/_build" ] && artifacts_to_remove+=("$dir/_build")
                ;;
            "Erlang")
                [ -d "$dir/_build" ] && artifacts_to_remove+=("$dir/_build")
                ;;
            "Elixir")
                [ -d "$dir/_build" ] && artifacts_to_remove+=("$dir/_build")
                [ -d "$dir/deps" ] && artifacts_to_remove+=("$dir/deps")
                [ -d "$dir/.elixir_ls" ] && artifacts_to_remove+=("$dir/.elixir_ls")
                [ -d "$dir/.lexical" ] && artifacts_to_remove+=("$dir/.lexical")
                ;;
            "Clojure")
                for d in target .cpcache .shadow-cljs out .calva .lsp .lsp/.cache .clj-kondo/.cache; do
                    [ -d "$dir/$d" ] && artifacts_to_remove+=("$dir/$d")
                done
                ;;
            "Haskell")
                for d in .stack-work dist-newstyle dist; do
                    [ -d "$dir/$d" ] && artifacts_to_remove+=("$dir/$d")
                done
                ;;
            ".NET")
                [ -d "$dir/bin" ] && artifacts_to_remove+=("$dir/bin")
                [ -d "$dir/obj" ] && artifacts_to_remove+=("$dir/obj")
                ;;
            "Dart")
                [ -d "$dir/build" ] && artifacts_to_remove+=("$dir/build")
                [ -d "$dir/.dart_tool" ] && artifacts_to_remove+=("$dir/.dart_tool")
                ;;
            "Python")
                for d in build dist .pytest_cache .mypy_cache .ruff_cache __pycache__; do
                    [ -d "$dir/$d" ] && artifacts_to_remove+=("$dir/$d")
                done
                for d in $(compgen -G "$dir/*.egg-info" 2>/dev/null); do
                    [ -d "$d" ] && artifacts_to_remove+=("$d")
                done
                for f in $(compgen -G "$dir/*.pyc" 2>/dev/null) $(compgen -G "$dir/*.pyo" 2>/dev/null); do
                    [ -f "$f" ] && artifacts_to_remove+=("$f")
                done
                ;;
            "Nim")
                [ -d "$dir/nimcache" ] && artifacts_to_remove+=("$dir/nimcache")
                ;;
            "Gleam")
                [ -d "$dir/build" ] && artifacts_to_remove+=("$dir/build")
                ;;
            "Mojo")
                [ -d "$dir/build" ] && artifacts_to_remove+=("$dir/build")
                [ -d "$dir/.pixi" ] && artifacts_to_remove+=("$dir/.pixi")
                ;;
            "Odin")
                [ -d "$dir/bin" ] && artifacts_to_remove+=("$dir/bin")
                ;;
            "Lean")
                [ -d "$dir/.lake" ] && artifacts_to_remove+=("$dir/.lake")
                ;;
            "Elm")
                [ -d "$dir/elm-stuff" ] && artifacts_to_remove+=("$dir/elm-stuff")
                ;;
            "PHP")
                for d in vendor .phpunit.cache storage/framework/cache storage/framework/views var/cache; do
                    [ -d "$dir/$d" ] && artifacts_to_remove+=("$dir/$d")
                done
                for f in .phpunit.result.cache composer.phar; do
                    [ -f "$dir/$f" ] && artifacts_to_remove+=("$dir/$f")
                done
                ;;
        esac
    done

    # Remove duplicates from artifacts list
    local -a unique_artifacts=()
    if [ ${#artifacts_to_remove[@]} -gt 0 ]; then
        while IFS= read -r item; do
            [ -n "$item" ] && unique_artifacts+=("$item")
        done < <(printf "%s\n" "${artifacts_to_remove[@]}" | sort -u)
    fi

    # Clean CodeRunner temporary wrapper and checksums if they exist
    local cr_tmp="${CR_TMPDIR:-/tmp}/CodeRunner"
    local proj_basename="$(basename "$dir")"
    if [ -d "$cr_tmp" ]; then
        for cr_f in "$cr_tmp/${proj_basename}_Project"* "$cr_tmp/${proj_basename}_Project.sha256"*; do
            if [ -e "$cr_f" ]; then
                unique_artifacts+=("$cr_f")
            fi
        done
    fi

    local cleaned_names=()
    for artifact in "${unique_artifacts[@]}"; do
        if [ -e "$artifact" ]; then
            local sz
            sz=$(get_size_kb "$artifact")
            dir_kb=$((dir_kb + sz))
            local rel_name="${artifact#$dir/}"
            [ "$rel_name" = "$artifact" ] && rel_name="$(basename "$artifact")"
            [ -d "$artifact" ] && rel_name="$rel_name/"
            cleaned_names+=("$rel_name")

            if [ "$dry_run" = true ]; then
                [ "$verbose" = true ] && echo "    (dry-run) would delete: $artifact ($(format_size $sz))"
            else
                [ "$verbose" = true ] && echo "    deleting: $artifact ($(format_size $sz))"
                rm -rf "$artifact" 2>/dev/null
            fi
        fi
    done

    # Return summary: output line format: <kb_freed>|<comma_separated_cleaned_artifacts>
    local cleaned_str=""
    if [ ${#cleaned_names[@]} -gt 0 ]; then
        cleaned_str=$(IFS=", "; echo "${cleaned_names[*]}")
    fi
    echo "${dir_kb}|${cleaned_str}"
}

# Clean loose build artifacts across subdirectories (e.g. __pycache__, *.pyc, *.dSYM)
clean_loose_artifacts() {
    local root_dir="$1"
    local dry_run="$2"
    local verbose="$3"

    local total_loose_kb=0
    local loose_count=0

    # Clean __pycache__ folders and .pytest_cache that might not be at project root
    while IFS= read -r -d '' pcache; do
        if [ -d "$pcache" ]; then
            local sz
            sz=$(get_size_kb "$pcache")
            total_loose_kb=$((total_loose_kb + sz))
            loose_count=$((loose_count + 1))
            if [ "$dry_run" = true ]; then
                [ "$verbose" = true ] && echo "  (dry-run) would delete loose cache: $pcache ($(format_size $sz))"
            else
                [ "$verbose" = true ] && echo "  deleting loose cache: $pcache ($(format_size $sz))"
                rm -rf "$pcache" 2>/dev/null
            fi
        fi
    done < <(find "$root_dir" \( -name ".git" -o -name "node_modules" -o -name "deps" -o -name "vendor" -o -name "elm-stuff" -o -name ".lake" -o -name ".phpunit.cache" \) -prune -o \( -name "__pycache__" -o -name ".pytest_cache" -o -name "*.dSYM" -o -name "zig-pkg" -o -name ".zig-cache-global" -o -name ".zig-global-cache-local" -o -path "*/.clj-kondo/.cache" -o -path "*/.lsp/.cache" \) -type d -print0 2>/dev/null)

    echo "$total_loose_kb|$loose_count"
}

# Main cleaning driver
run_cleaner() {
    local target_dir="."
    local dry_run=false
    local verbose=false
    local quiet=false
    local run_tools=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                echo "Usage: cclean [directory] [options]"
                echo ""
                echo "Cleans build files and artifacts for all projects in a directory and its subdirectories."
                echo ""
                echo "Options:"
                echo "  -n, --dry-run     Show what would be deleted without actually deleting"
                echo "  -v, --verbose     Show detailed file and directory deletions"
                echo "  -q, --quiet       Suppress non-essential output"
                echo "  -t, --tools       Run native build tool clean commands (e.g. go clean, make clean)"
                echo "  -h, --help        Show this help message"
                echo ""
                echo "Examples:"
                echo "  cclean                   Clean projects in current directory and subdirectories"
                echo "  cclean /path/to/code     Clean projects in /path/to/code"
                echo "  cclean -n .              Dry run preview of what would be cleaned"
                return 0
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -t|--tools)
                run_tools=true
                shift
                ;;
            -*)
                echo "Unknown option: $1" >&2
                echo "Run 'cclean --help' for usage." >&2
                return 1
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done

    # Resolve target directory
    if [ ! -d "$target_dir" ]; then
        echo "Error: Directory '$target_dir' does not exist." >&2
        return 1
    fi

    # Convert to absolute path
    target_dir="$(cd "$target_dir" 2>/dev/null && pwd)"

    if [ "$quiet" = false ]; then
        if [ "$dry_run" = true ]; then
            echo "🔍 [Dry Run] Scanning for projects in: $target_dir"
        else
            echo "🧹 Cleaning projects in: $target_dir"
        fi
        echo "----------------------------------------------------------------------"
    fi

    # Build find prune expression
    # We prune known build/dependency directories to keep scanning fast and avoid recursion into artifacts
    local prune_expr=()
    for pdir in "${PRUNE_DIRS[@]}"; do
        if [ ${#prune_expr[@]} -gt 0 ]; then
            prune_expr+=("-o")
        fi
        prune_expr+=("-name" "$pdir")
    done

    local candidate_dirs=()

    # Collect directories safely without following symlinks into outer trees
    while IFS= read -r -d '' d; do
        candidate_dirs+=("$d")
    done < <(find "$target_dir" \
        -path "$target_dir" -o \
        \( "${prune_expr[@]}" \) -prune -o \
        -type d -print0 2>/dev/null)

    local total_cleaned_projects=0
    local total_freed_kb=0

    for cdir in "${candidate_dirs[@]}"; do
        local detected_types
        detected_types=$(detect_project_types "$cdir")

        if [ -n "$detected_types" ]; then
            local res
            res=$(clean_project_artifacts "$cdir" "$detected_types" "$dry_run" "$verbose" "$run_tools")
            local freed_kb="${res%%|*}"
            local cleaned_items="${res##*|}"

            if [ -n "$cleaned_items" ] || [ "$verbose" = true ]; then
                total_cleaned_projects=$((total_cleaned_projects + 1))
                total_freed_kb=$((total_freed_kb + freed_kb))

                if [ "$quiet" = false ]; then
                    local type_label="[${detected_types// /, }]"
                    local rel_proj_path="."
                    if [ "$cdir" != "$target_dir" ]; then
                        rel_proj_path="${cdir#$target_dir/}"
                    fi

                    if [ -n "$cleaned_items" ]; then
                        local size_str=""
                        [ "$freed_kb" -gt 0 ] && size_str=" ($(format_size "$freed_kb"))"
                        if [ "$dry_run" = true ]; then
                            echo "  $type_label $rel_proj_path -> would clean $cleaned_items$size_str"
                        else
                            echo "  $type_label $rel_proj_path -> cleaned $cleaned_items$size_str"
                        fi
                    elif [ "$verbose" = true ]; then
                        echo "  $type_label $rel_proj_path -> already clean"
                    fi
                fi
            fi
        fi
    done

    # Clean any loose artifacts (like __pycache__, .pytest_cache)
    local loose_res
    loose_res=$(clean_loose_artifacts "$target_dir" "$dry_run" "$verbose")
    local loose_kb="${loose_res%%|*}"
    local loose_cnt="${loose_res##*|}"
    if [ "$loose_cnt" -gt 0 ]; then
        total_freed_kb=$((total_freed_kb + loose_kb))
        if [ "$quiet" = false ]; then
            if [ "$dry_run" = true ]; then
                echo "  [Loose Artifacts] would clean $loose_cnt cache directories ($(format_size "$loose_kb"))"
            else
                echo "  [Loose Artifacts] cleaned $loose_cnt cache directories ($(format_size "$loose_kb"))"
            fi
        fi
    fi

    if [ "$quiet" = false ]; then
        echo "----------------------------------------------------------------------"
        if [ "$dry_run" = true ]; then
            echo "Dry run complete: Found $total_cleaned_projects project(s) with cleanable artifacts."
            echo "Potential space to reclaim: $(format_size "$total_freed_kb")"
        else
            echo "Clean complete: $total_cleaned_projects project(s) cleaned."
            echo "Total space freed: $(format_size "$total_freed_kb")"
        fi
    fi

    return 0
}

# If executed directly as a script, run cleaner
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_cleaner "$@"
    exit $?
fi
