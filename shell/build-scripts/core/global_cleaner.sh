#!/bin/bash

# ==============================================================================
# Universal Global Cache & Package Cleaner (gclean)
# Cleans system-wide caches, package registries, and heavy toolchains.
# Gated by a 1st-level directory size threshold (default 10 MB).
# ==============================================================================

# Calculate size in kilobytes of a path
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

# Check if a 1st-level directory meets the minimum size threshold
check_first_level_dir() {
    local dir="$1"
    local min_kb="${2:-1048576}" # 1 GB (1024 MB) default
    local verbose="$3"

    if [ ! -d "$dir" ]; then
        return 1
    fi

    local sz
    sz=$(get_size_kb "$dir")
    if [ "$sz" -lt "$min_kb" ]; then
        [ "$verbose" = true ] && echo "  (skipped tool: $(basename "$dir") < $(format_size "$min_kb") total [$(format_size "$sz")])"
        return 1
    fi

    return 0
}

# Safely remove an artifact with dry-run and verbose support
remove_sub_artifact() {
    local path="$1"
    local label="$2"
    local dry_run="$3"
    local verbose="$4"

    if [ ! -e "$path" ]; then
        echo "0"
        return
    fi

    local sz
    sz=$(get_size_kb "$path")

    if [ "$dry_run" = true ]; then
        [ "$verbose" = true ] && echo "    (dry-run) would delete: $path ($(format_size "$sz"))"
    else
        [ "$verbose" = true ] && echo "    deleting: $path ($(format_size "$sz"))"
        rm -rf "$path" 2>/dev/null
    fi

    echo "$sz"
}

# Read user choice from terminal or stdin
prompt_choice() {
    local prompt_msg="$1"
    local default_choice="$2"
    local answer=""

    # Print prompt message to stderr so it doesn't pollute piped stdout
    printf "%s" "$prompt_msg" >&2
    if read -r answer; then
        :
    else
        answer="$default_choice"
    fi

    answer="${answer:-$default_choice}"
    echo "$answer" | tr '[:upper:]' '[:lower:]'
}

# Clean Tier 1: Safe global caches (default)
clean_tier1() {
    local home_dir="${1:-$HOME}"
    local dry_run="$2"
    local verbose="$3"
    local quiet="$4"
    local min_kb="${5:-1048576}" # 1 GB default

    local total_kb=0
    local cleaned_count=0

    [ "$quiet" = false ] && echo "📦 Tier 1: Safe Global Caches (ignoring tool folders < $(format_size "$min_kb"))"

    # Helper to clean subtargets if 1st-level directory qualifies
    clean_tool_group() {
        local tool_root="$1"
        shift
        local sub_paths=("$@")

        if ! check_first_level_dir "$tool_root" "$min_kb" "$verbose"; then
            return
        fi

        for sub in "${sub_paths[@]}"; do
            local target_path="$tool_root/$sub"
            if [ -e "$target_path" ]; then
                local sz
                sz=$(remove_sub_artifact "$target_path" "$sub" "$dry_run" "$verbose")
                if [ "$sz" -gt 0 ]; then
                    total_kb=$((total_kb + sz))
                    cleaned_count=$((cleaned_count + 1))
                    if [ "$quiet" = false ] && [ "$verbose" = false ]; then
                        local rel_display="~/${target_path#$home_dir/}"
                        if [ "$dry_run" = true ]; then
                            echo "  [Cache] would clean $rel_display ($(format_size "$sz"))"
                        else
                            echo "  [Cache] cleaned $rel_display ($(format_size "$sz"))"
                        fi
                    fi
                fi
            fi
        done
    }

    # 1. ~/.cache (Zig, uv, pip, vcpkg, LSP caches, dune, etc.)
    clean_tool_group "$home_dir/.cache" \
        "zig" ".zig-cache-global" "uv" "pip" "pipenv" "vcpkg" \
        "clojure-lsp" "ghcide" "hie-bios" "nvim" "pack" "dune"

    # 2. ~/.npm
    clean_tool_group "$home_dir/.npm" "_cacache" "_npx" "_libvips"

    # 3. ~/.bun
    clean_tool_group "$home_dir/.bun" "install"

    # 4. ~/.yarn
    clean_tool_group "$home_dir/.yarn" "cache" "berry/cache"

    # 5. ~/.gradle
    clean_tool_group "$home_dir/.gradle" "caches" "daemon" ".tmp" "wrapper/dists"

    # 6. ~/.m2
    clean_tool_group "$home_dir/.m2" "wrapper/dists"

    # 7. ~/.rustup
    clean_tool_group "$home_dir/.rustup" "downloads" "tmp"

    # 8. ~/.wasmer
    clean_tool_group "$home_dir/.wasmer" "cache"

    # 9. ~/.jbang
    clean_tool_group "$home_dir/.jbang" "cache"

    # 10. ~/.konan
    clean_tool_group "$home_dir/.konan" "dependencies"

    # 11. ~/.opam
    clean_tool_group "$home_dir/.opam" "download-cache"

    # 12. ~/.openjfx
    clean_tool_group "$home_dir/.openjfx" "cache"

    # 13. ~/.metal-analyzer
    clean_tool_group "$home_dir/.metal-analyzer" "index-cache"

    # 14. Standalone Zig global cache folders in ~
    for zpath in "$home_dir/.zig-cache-global" "$home_dir/.zig-global-cache-local"; do
        if [ -d "$zpath" ]; then
            local zsz
            zsz=$(get_size_kb "$zpath")
            if [ "$zsz" -ge "$min_kb" ]; then
                local sz
                sz=$(remove_sub_artifact "$zpath" "$(basename "$zpath")" "$dry_run" "$verbose")
                if [ "$sz" -gt 0 ]; then
                    total_kb=$((total_kb + sz))
                    cleaned_count=$((cleaned_count + 1))
                    [ "$quiet" = false ] && [ "$verbose" = false ] && echo "  [Cache] cleaned ~/${zpath#$home_dir/} ($(format_size "$sz"))"
                fi
            fi
        fi
    done

    # 15. CodeRunner temp directory
    local cr_tmp="${CR_TMPDIR:-/tmp}/CodeRunner"
    if [ -d "$cr_tmp" ]; then
        local cr_sz
        cr_sz=$(get_size_kb "$cr_tmp")
        if [ "$cr_sz" -ge "$min_kb" ]; then
            local sz
            sz=$(remove_sub_artifact "$cr_tmp" "CodeRunner tmp" "$dry_run" "$verbose")
            if [ "$sz" -gt 0 ]; then
                total_kb=$((total_kb + sz))
                cleaned_count=$((cleaned_count + 1))
                [ "$quiet" = false ] && [ "$verbose" = false ] && echo "  [Cache] cleaned $cr_tmp ($(format_size "$sz"))"
            fi
        fi
    fi

    # 16. Local caches in ~/.local/share
    clean_tool_group "$home_dir/.local/share/steel" "target"
    clean_tool_group "$home_dir/.local/share/junie" "versions"
    if [ -d "$home_dir/.local/share/nvim~" ]; then
        local nv_sz
        nv_sz=$(get_size_kb "$home_dir/.local/share/nvim~")
        if [ "$nv_sz" -ge "$min_kb" ]; then
            local sz
            sz=$(remove_sub_artifact "$home_dir/.local/share/nvim~" "nvim~ backup" "$dry_run" "$verbose")
            if [ "$sz" -gt 0 ]; then
                total_kb=$((total_kb + sz))
                cleaned_count=$((cleaned_count + 1))
                [ "$quiet" = false ] && [ "$verbose" = false ] && echo "  [Cache] cleaned ~/.local/share/nvim~ ($(format_size "$sz"))"
            fi
        fi
    fi

    TIER1_KB="$total_kb"
}

# Clean Tier 2: Global package registries & dependencies (--deps / --packages)
clean_tier2() {
    local home_dir="${1:-$HOME}"
    local dry_run="$2"
    local verbose="$3"
    local quiet="$4"
    local min_kb="${5:-1048576}" # 1 GB default

    local total_kb=0
    local cleaned_count=0

    [ "$quiet" = false ] && echo ""
    [ "$quiet" = false ] && echo "📚 Tier 2: Global Package & Dependency Registries (--deps) (ignoring tool folders < $(format_size "$min_kb"))"

    clean_dep_group() {
        local tool_root="$1"
        shift
        local sub_paths=("$@")

        if ! check_first_level_dir "$tool_root" "$min_kb" "$verbose"; then
            return
        fi

        for sub in "${sub_paths[@]}"; do
            local target_path="$tool_root/$sub"
            if [ -e "$target_path" ]; then
                local sz
                sz=$(remove_sub_artifact "$target_path" "$sub" "$dry_run" "$verbose")
                if [ "$sz" -gt 0 ]; then
                    total_kb=$((total_kb + sz))
                    cleaned_count=$((cleaned_count + 1))
                    if [ "$quiet" = false ] && [ "$verbose" = false ]; then
                        local rel_display="~/${target_path#$home_dir/}"
                        if [ "$dry_run" = true ]; then
                            echo "  [Registry] would clean $rel_display ($(format_size "$sz"))"
                        else
                            echo "  [Registry] cleaned $rel_display ($(format_size "$sz"))"
                        fi
                    fi
                fi
            fi
        done
    }

    # 1. ~/.cargo (crates.io registry & git checkouts)
    clean_dep_group "$home_dir/.cargo" "registry/cache" "registry/src" "git/db" "git/checkouts"

    # 2. ~/.m2 repository
    clean_dep_group "$home_dir/.m2" "repository"

    # 3. ~/.hex (Elixir)
    clean_dep_group "$home_dir/.hex" "packages" "cache.ets"

    # 4. ~/.bundle & ~/.gem (Ruby)
    clean_dep_group "$home_dir/.bundle" "cache"
    clean_dep_group "$home_dir/.gem" "specs"

    # 5. ~/.julia
    clean_dep_group "$home_dir/.julia" "compiled" "artifacts"

    # 6. ~/.stack (Haskell)
    clean_dep_group "$home_dir/.stack" "setup-exe-cache" "snapshots" "pantry"

    # 7. ~/.elm
    clean_dep_group "$home_dir/.elm" "0.19.1" "0.19.2"

    # 8. Cabal (Haskell store & packages)
    clean_dep_group "$home_dir/.local/state/cabal" "store"
    clean_dep_group "$home_dir/.cabal" "store" "packages"
    clean_dep_group "$home_dir/.cache/cabal" "packages"

    # 9. Pack (Idris 2 packages)
    clean_dep_group "$home_dir/.local/state/pack" "install" "db"

    TIER2_KB="$total_kb"
}

# Prune Rust toolchains (~/.rustup/toolchains)
prune_rust_toolchains() {
    local toolchains_dir="$1"
    local dry_run="$2"
    local verbose="$3"
    local auto_yes="$4"

    local total_kb=0
    [ ! -d "$toolchains_dir" ] && echo 0 && return

    local toolchains=()
    while IFS= read -r d; do
        [ -n "$d" ] && toolchains+=("$(basename "$d")")
    done < <(find "$toolchains_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

    local count=${#toolchains[@]}
    [ "$count" -eq 0 ] && echo 0 && return

    local overall_sz
    overall_sz=$(get_size_kb "$toolchains_dir")

    echo ""
    echo "🦀 Rust Toolchains: $toolchains_dir ($(format_size "$overall_sz"))"
    echo "   Installed toolchains ($count):"
    for tc in "${toolchains[@]}"; do
        local sz
        sz=$(get_size_kb "$toolchains_dir/$tc")
        echo "     - $tc ($(format_size "$sz"))"
    done

    local latest_stable=""
    local latest_nightly=""

    for tc in "${toolchains[@]}"; do
        if [[ "$tc" == stable* ]]; then
            latest_stable="$tc"
        fi
        if [[ "$tc" == nightly* ]]; then
            latest_nightly="$tc"
        fi
    done

    if [ -z "$latest_stable" ]; then
        local versioned_stables=()
        for tc in "${toolchains[@]}"; do
            if [[ "$tc" =~ ^[0-9]+\.[0-9]+ ]]; then
                versioned_stables+=("$tc")
            fi
        done
        if [ ${#versioned_stables[@]} -gt 0 ]; then
            latest_stable=$(printf "%s\n" "${versioned_stables[@]}" | sort -V | tail -n 1)
        fi
    fi

    echo "   Identified to keep: ${latest_stable:-none} and ${latest_nightly:-none}"

    local choice=""
    if [ "$auto_yes" = true ]; then
        choice="k"
    else
        choice=$(prompt_choice "   Action: [k]eep latest stable & nightly / [d]elete all / [s]kip (default: k): " "k")
    fi

    case "$choice" in
        k|keep)
            for tc in "${toolchains[@]}"; do
                if [ "$tc" != "$latest_stable" ] && [ "$tc" != "$latest_nightly" ]; then
                    local sz
                    sz=$(remove_sub_artifact "$toolchains_dir/$tc" "$tc" "$dry_run" "$verbose")
                    total_kb=$((total_kb + sz))
                    echo "     -> removed older toolchain: $tc ($(format_size "$sz"))"
                else
                    echo "     -> preserved: $tc"
                fi
            done
            ;;
        d|delete|all)
            for tc in "${toolchains[@]}"; do
                local sz
                sz=$(remove_sub_artifact "$toolchains_dir/$tc" "$tc" "$dry_run" "$verbose")
                total_kb=$((total_kb + sz))
            done
            echo "     -> removed all Rust toolchains"
            ;;
        *)
            echo "     -> skipped"
            ;;
    esac

    RUST_PRUNED_KB="$total_kb"
}

# Prune Lean toolchains (~/.elan/toolchains)
prune_lean_toolchains() {
    local toolchains_dir="$1"
    local dry_run="$2"
    local verbose="$3"
    local auto_yes="$4"

    local total_kb=0
    [ ! -d "$toolchains_dir" ] && echo 0 && return

    local toolchains=()
    while IFS= read -r d; do
        [ -n "$d" ] && toolchains+=("$(basename "$d")")
    done < <(find "$toolchains_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

    local count=${#toolchains[@]}
    [ "$count" -eq 0 ] && echo 0 && return

    local overall_sz
    overall_sz=$(get_size_kb "$toolchains_dir")

    echo ""
    echo "📐 Lean Toolchains: $toolchains_dir ($(format_size "$overall_sz"))"
    echo "   Installed toolchains ($count):"
    for tc in "${toolchains[@]}"; do
        local sz
        sz=$(get_size_kb "$toolchains_dir/$tc")
        echo "     - $tc ($(format_size "$sz"))"
    done

    local latest_lean
    latest_lean=$(printf "%s\n" "${toolchains[@]}" | sort -V | tail -n 1)

    echo "   Identified latest: $latest_lean"

    local choice=""
    if [ "$auto_yes" = true ]; then
        choice="k"
    else
        choice=$(prompt_choice "   Action: [k]eep latest only / [d]elete all / [s]kip (default: k): " "k")
    fi

    case "$choice" in
        k|keep)
            for tc in "${toolchains[@]}"; do
                if [ "$tc" != "$latest_lean" ]; then
                    local sz
                    sz=$(remove_sub_artifact "$toolchains_dir/$tc" "$tc" "$dry_run" "$verbose")
                    total_kb=$((total_kb + sz))
                    echo "     -> removed older toolchain: $tc ($(format_size "$sz"))"
                else
                    echo "     -> preserved latest: $tc"
                fi
            done
            ;;
        d|delete|all)
            for tc in "${toolchains[@]}"; do
                local sz
                sz=$(remove_sub_artifact "$toolchains_dir/$tc" "$tc" "$dry_run" "$verbose")
                total_kb=$((total_kb + sz))
            done
            echo "     -> removed all Lean toolchains"
            ;;
        *)
            echo "     -> skipped"
            ;;
    esac

    LEAN_PRUNED_KB="$total_kb"
}

# Prune Cabal GHC stores (~/.local/state/cabal/store or ~/.cabal/store)
prune_cabal_stores() {
    local store_dir="$1"
    local dry_run="$2"
    local verbose="$3"
    local auto_yes="$4"

    local total_kb=0
    [ ! -d "$store_dir" ] && echo 0 && return

    local ghc_stores=()
    while IFS= read -r d; do
        [ -n "$d" ] && ghc_stores+=("$(basename "$d")")
    done < <(find "$store_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

    local count=${#ghc_stores[@]}
    [ "$count" -eq 0 ] && echo 0 && return

    local overall_sz
    overall_sz=$(get_size_kb "$store_dir")

    echo ""
    echo "📦 Cabal GHC Stores: $store_dir ($(format_size "$overall_sz"))"
    echo "   Installed GHC store versions ($count):"
    for gs in "${ghc_stores[@]}"; do
        local sz
        sz=$(get_size_kb "$store_dir/$gs")
        echo "     - $gs ($(format_size "$sz"))"
    done

    local latest_ghc
    latest_ghc=$(printf "%s\n" "${ghc_stores[@]}" | sort -V | tail -n 1)

    echo "   Identified latest: $latest_ghc"

    local choice=""
    if [ "$auto_yes" = true ]; then
        choice="k"
    else
        choice=$(prompt_choice "   Action: [k]eep latest only / [d]elete all / [s]kip (default: k): " "k")
    fi

    case "$choice" in
        k|keep)
            for gs in "${ghc_stores[@]}"; do
                if [ "$gs" != "$latest_ghc" ]; then
                    local sz
                    sz=$(remove_sub_artifact "$store_dir/$gs" "$gs" "$dry_run" "$verbose")
                    total_kb=$((total_kb + sz))
                    echo "     -> removed older GHC store: $gs ($(format_size "$sz"))"
                else
                    echo "     -> preserved latest: $gs"
                fi
            done
            ;;
        d|delete|all)
            for gs in "${ghc_stores[@]}"; do
                local sz
                sz=$(remove_sub_artifact "$store_dir/$gs" "$gs" "$dry_run" "$verbose")
                total_kb=$((total_kb + sz))
            done
            echo "     -> removed all Cabal GHC stores"
            ;;
        *)
            echo "     -> skipped"
            ;;
    esac

    CABAL_PRUNED_KB="$total_kb"
}

# Clean Tier 3: Heavy Toolchains, Models & SDKs with 1-by-1 confirmation (--all)
clean_tier3() {
    local home_dir="${1:-$HOME}"
    local dry_run="$2"
    local verbose="$3"
    local quiet="$4"
    local auto_yes="$5"
    local min_kb="${6:-1048576}" # 1 GB default

    local total_kb=0

    [ "$quiet" = false ] && echo ""
    [ "$quiet" = false ] && echo "⚡ Tier 3: Heavy Toolchains, Models & SDKs (--all) (ignoring tool folders < $(format_size "$min_kb"))"

    # 1. Rust Toolchains
    if check_first_level_dir "$home_dir/.rustup" "$min_kb" "$verbose"; then
        if [ -d "$home_dir/.rustup/toolchains" ]; then
            RUST_PRUNED_KB=0
            prune_rust_toolchains "$home_dir/.rustup/toolchains" "$dry_run" "$verbose" "$auto_yes"
            total_kb=$((total_kb + RUST_PRUNED_KB))
        fi
    fi

    # 2. Lean Toolchains
    if check_first_level_dir "$home_dir/.elan" "$min_kb" "$verbose"; then
        if [ -d "$home_dir/.elan/toolchains" ]; then
            LEAN_PRUNED_KB=0
            prune_lean_toolchains "$home_dir/.elan/toolchains" "$dry_run" "$verbose" "$auto_yes"
            total_kb=$((total_kb + LEAN_PRUNED_KB))
        fi
    fi

    # 3. Ollama Models
    if check_first_level_dir "$home_dir/.ollama" "$min_kb" "$verbose"; then
        local ollama_models="$home_dir/.ollama/models"
        if [ -d "$ollama_models" ]; then
            local sz
            sz=$(get_size_kb "$ollama_models")
            if [ "$sz" -gt 0 ]; then
                echo ""
                echo "🦙 Ollama Local Models: $ollama_models ($(format_size "$sz"))"
                local choice=""
                if [ "$auto_yes" = true ]; then
                    choice="s"
                else
                    choice=$(prompt_choice "   Action: [d]elete models / [s]kip (default: s): " "s")
                fi
                if [[ "$choice" == "d" || "$choice" == "delete" ]]; then
                    local freed
                    freed=$(remove_sub_artifact "$ollama_models" "Ollama models" "$dry_run" "$verbose")
                    total_kb=$((total_kb + freed))
                    echo "     -> deleted Ollama models ($(format_size "$freed"))"
                else
                    echo "     -> skipped"
                fi
            fi
        fi
    fi

    # 4. HuggingFace Models Cache
    local hf_cache="$home_dir/.cache/huggingface"
    if [ -d "$hf_cache" ]; then
        local sz
        sz=$(get_size_kb "$hf_cache")
        if [ "$sz" -ge "$min_kb" ]; then
            echo ""
            echo "🤗 HuggingFace Cache: $hf_cache ($(format_size "$sz"))"
            local choice=""
            if [ "$auto_yes" = true ]; then
                choice="s"
            else
                choice=$(prompt_choice "   Action: [d]elete cache / [s]kip (default: s): " "s")
            fi
            if [[ "$choice" == "d" || "$choice" == "delete" ]]; then
                local freed
                freed=$(remove_sub_artifact "$hf_cache" "HuggingFace cache" "$dry_run" "$verbose")
                total_kb=$((total_kb + freed))
                echo "     -> deleted HuggingFace cache ($(format_size "$freed"))"
            else
                echo "     -> skipped"
            fi
        fi
    fi

    # 5. Gradle Downloaded JDKs
    local gradle_jdks="$home_dir/.gradle/jdks"
    if [ -d "$gradle_jdks" ]; then
        local sz
        sz=$(get_size_kb "$gradle_jdks")
        if [ "$sz" -ge "$min_kb" ]; then
            echo ""
            echo "☕ Gradle Downloaded JDKs: $gradle_jdks ($(format_size "$sz"))"
            local choice=""
            if [ "$auto_yes" = true ]; then
                choice="d"
            else
                choice=$(prompt_choice "   Action: [d]elete JDKs / [s]kip (default: d): " "d")
            fi
            if [[ "$choice" == "d" || "$choice" == "delete" ]]; then
                local freed
                freed=$(remove_sub_artifact "$gradle_jdks" "Gradle JDKs" "$dry_run" "$verbose")
                total_kb=$((total_kb + freed))
                echo "     -> deleted Gradle JDKs ($(format_size "$freed"))"
            else
                echo "     -> skipped"
            fi
        fi
    fi

    # 6. Haskell Stack GHC Compilers
    local stack_programs="$home_dir/.stack/programs"
    if [ -d "$stack_programs" ]; then
        local sz
        sz=$(get_size_kb "$stack_programs")
        if [ "$sz" -ge "$min_kb" ]; then
            echo ""
            echo "λ Stack GHC Compilers: $stack_programs ($(format_size "$sz"))"
            local choice=""
            if [ "$auto_yes" = true ]; then
                choice="s"
            else
                choice=$(prompt_choice "   Action: [d]elete GHC versions / [s]kip (default: s): " "s")
            fi
            if [[ "$choice" == "d" || "$choice" == "delete" ]]; then
                local freed
                freed=$(remove_sub_artifact "$stack_programs" "Stack GHC versions" "$dry_run" "$verbose")
                total_kb=$((total_kb + freed))
                echo "     -> deleted Stack GHC compilers ($(format_size "$freed"))"
            else
                echo "     -> skipped"
            fi
        fi
    fi

    # 7. Old IDE Backups (~/.gemini/antigravity-backup)
    local ide_backup="$home_dir/.gemini/antigravity-backup"
    if [ -d "$ide_backup" ]; then
        local sz
        sz=$(get_size_kb "$ide_backup")
        if [ "$sz" -ge "$min_kb" ]; then
            echo ""
            echo "💾 IDE Backups: $ide_backup ($(format_size "$sz"))"
            local choice=""
            if [ "$auto_yes" = true ]; then
                choice="d"
            else
                choice=$(prompt_choice "   Action: [d]elete old backups / [s]kip (default: d): " "d")
            fi
            if [[ "$choice" == "d" || "$choice" == "delete" ]]; then
                local freed
                freed=$(remove_sub_artifact "$ide_backup" "IDE backups" "$dry_run" "$verbose")
                total_kb=$((total_kb + freed))
                echo "     -> deleted IDE backups ($(format_size "$freed"))"
            else
                echo "     -> skipped"
            fi
        fi
    fi

    # 8. Cabal GHC Stores
    for cdir in "$home_dir/.local/state/cabal/store" "$home_dir/.cabal/store"; do
        if [ -d "$cdir" ]; then
            local cparent="$(dirname "$cdir")"
            if check_first_level_dir "$cparent" "$min_kb" "$verbose"; then
                CABAL_PRUNED_KB=0
                prune_cabal_stores "$cdir" "$dry_run" "$verbose" "$auto_yes"
                total_kb=$((total_kb + CABAL_PRUNED_KB))
            fi
        fi
    done

    # 9. Alire Ada Toolchains
    local alire_tc="$home_dir/.local/share/alire/toolchains"
    if [ -d "$alire_tc" ]; then
        local sz
        sz=$(get_size_kb "$alire_tc")
        if [ "$sz" -ge "$min_kb" ]; then
            echo ""
            echo "🦅 Alire Ada Toolchains: $alire_tc ($(format_size "$sz"))"
            local choice=""
            if [ "$auto_yes" = true ]; then
                choice="s"
            else
                choice=$(prompt_choice "   Action: [d]elete toolchains / [s]kip (default: s): " "s")
            fi
            if [[ "$choice" == "d" || "$choice" == "delete" ]]; then
                local freed
                freed=$(remove_sub_artifact "$alire_tc" "Alire toolchains" "$dry_run" "$verbose")
                total_kb=$((total_kb + freed))
                echo "     -> deleted Alire toolchains ($(format_size "$freed"))"
            else
                echo "     -> skipped"
            fi
        fi
    fi

    # 10. Neovim Mason Packages
    local mason_dir="$home_dir/.local/share/nvim/mason"
    if [ -d "$mason_dir" ]; then
        local sz
        sz=$(get_size_kb "$mason_dir")
        if [ "$sz" -ge "$min_kb" ]; then
            echo ""
            echo "🧩 Neovim Mason Packages: $mason_dir ($(format_size "$sz"))"
            local choice=""
            if [ "$auto_yes" = true ]; then
                choice="s"
            else
                choice=$(prompt_choice "   Action: [d]elete Mason packages / [s]kip (default: s): " "s")
            fi
            if [[ "$choice" == "d" || "$choice" == "delete" ]]; then
                local freed
                freed=$(remove_sub_artifact "$mason_dir" "Mason packages" "$dry_run" "$verbose")
                total_kb=$((total_kb + freed))
                echo "     -> deleted Neovim Mason packages ($(format_size "$freed"))"
            else
                echo "     -> skipped"
            fi
        fi
    fi

    TIER3_KB="$total_kb"
}

# Main driver for global cleaning
run_global_cleaner() {
    local home_dir="$HOME"
    local dry_run=false
    local verbose=false
    local quiet=false
    local include_deps=false
    local include_all=false
    local auto_yes=false
    local min_mb=1024

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                echo "Usage: gclean [options]"
                echo ""
                echo "Cleans global development caches, package registries, and toolchains."
                echo "Ignores 1st-level tool directories smaller than 1 GB (1024 MB) by default."
                echo ""
                echo "Tiers:"
                echo "  (default)            Clean Tier 1: Safe global caches (Zig, uv, npm, Bun, Gradle caches,"
                echo "                       vcpkg, rustup tmp/downloads, wasmer, jbang, lsp/editor caches, etc.)"
                echo "  --deps, --packages   Also clean Tier 2: Global package registries & downloaded dependencies"
                echo "                       (Cargo registry/git caches, Maven repo, Hex, Bundle/Gem caches, etc.)"
                echo "  --all                Also review Tier 3: Heavy toolchains, SDKs & models with interactive"
                echo "                       1-by-1 confirmation and smart version pruning (Rust, Lean, Ollama, etc.)"
                echo ""
                echo "Options:"
                echo "  -n, --dry-run        Show what would be deleted without actually deleting"
                echo "  -v, --verbose        Show detailed deletions and skipped items"
                echo "  -q, --quiet          Suppress non-essential output"
                echo "  -y, --yes            Assume default/recommended action on all prompts"
                echo "      --min-size <MB>  Minimum size for 1st-level tool directories (default: 1024 MB / 1 GB)"
                echo "      --home <dir>     Override home directory (useful for testing)"
                echo "  -h, --help           Show this help message"
                echo ""
                echo "Examples:"
                echo "  gclean                   Clean safe global caches (Tier 1, >= 1 GB)"
                echo "  gclean --deps            Clean safe caches + package dependencies (Tier 1 & 2)"
                echo "  gclean --all             Clean caches + dependencies + interactive toolchains (All Tiers)"
                echo "  gclean -n                Dry run preview of what would be cleaned"
                echo "  gclean --min-size 500    Clean tools that are at least 500MB"
                echo "  gclean --min-size 100    Clean tools that are at least 100MB"
                echo "  gclean --min-size 0      Clean caches without any minimum size threshold"
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
            -y|--yes)
                auto_yes=true
                shift
                ;;
            --deps|--packages)
                include_deps=true
                shift
                ;;
            --all)
                include_deps=true
                include_all=true
                shift
                ;;
            --min-size)
                min_mb="$2"
                shift 2
                ;;
            --home)
                home_dir="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1" >&2
                echo "Run 'gclean --help' for usage." >&2
                return 1
                ;;
        esac
    done

    local min_kb=$((min_mb * 1024))
    local grand_total_kb=0

    if [ "$quiet" = false ]; then
        if [ "$dry_run" = true ]; then
            echo "🔍 [Dry Run] Global Clean Inspection (Home: $home_dir, Min Tool Size: ${min_mb} MB)"
        else
            echo "🧹 Global System Cleanup (Home: $home_dir, Min Tool Size: ${min_mb} MB)"
        fi
        echo "======================================================================"
    fi

    # 1. Tier 1: Always cleaned
    TIER1_KB=0
    clean_tier1 "$home_dir" "$dry_run" "$verbose" "$quiet" "$min_kb"
    grand_total_kb=$((grand_total_kb + TIER1_KB))

    # 2. Tier 2: Included if --deps or --packages or --all
    if [ "$include_deps" = true ]; then
        TIER2_KB=0
        clean_tier2 "$home_dir" "$dry_run" "$verbose" "$quiet" "$min_kb"
        grand_total_kb=$((grand_total_kb + TIER2_KB))
    fi

    # 3. Tier 3: Included if --all
    if [ "$include_all" = true ]; then
        TIER3_KB=0
        clean_tier3 "$home_dir" "$dry_run" "$verbose" "$quiet" "$auto_yes" "$min_kb"
        grand_total_kb=$((grand_total_kb + TIER3_KB))
    fi

    if [ "$quiet" = false ]; then
        echo ""
        echo "======================================================================"
        if [ "$dry_run" = true ]; then
            echo "Dry run complete: Potential global space to reclaim: $(format_size "$grand_total_kb")"
        else
            echo "Global cleanup complete! Total space freed: $(format_size "$grand_total_kb")"
        fi
    fi

    return 0
}

# If executed directly as a script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_global_cleaner "$@"
    exit $?
fi
