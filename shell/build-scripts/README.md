# Universal Code Builder and Runner

A powerful, universal CLI wrapper script that automatically detects your project type (or single file) and compiles/runs it seamlessly. Originally designed for CodeRunner, it has evolved into a highly capable, standalone utility that works right from your terminal.

## Features

- **Universal Support**: Understands and builds a wide variety of languages out-of-the-box:
  - C / C++ / Objective-C (including CMake and Make projects)
  - Go, Rust, Zig, Nim
  - Java, Kotlin, Scala (supports Maven and Gradle)
  - JavaScript / TypeScript (supports Node.js, Deno, and Bun)
  - Python, Ruby, PHP, Perl, Lua, R
  - Clojure, Elixir, Gleam, Haskell
  - Swift, Dart, Mojo
  - Erlang
  - Shell scripts (bash, zsh, fish)
- **Automatic Project Detection**: Automatically scans for project markers (like `go.mod`, `Cargo.toml`, `package.json`, `pom.xml`, `Makefile`) and builds/runs the entire project if applicable.
- **Smart Recompilation**: Caches built binaries using SHA-256 checksums of your source file to avoid unnecessary recompilation of single-file scripts.
- **Cross-Platform**: Works gracefully across Unix-like systems (macOS, Linux).

## Installation

The easiest way to install is to run the provided install script, which will create symlinks for the commands as `cbuild`, `crun`, and `cclean` in your `~/.local/bin` directory.

```bash
./install.sh
```

Make sure `~/.local/bin` is in your system's `PATH`. For example, add this to your `~/.zshrc` or `~/.bashrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

You can use the scripts to either just build a file, or build and immediately run it.

### Build and Run (Recommended)
Use `crun` to compile (if necessary) and execute the program in one step.

```bash
# Run a single file
crun main.go
crun script.py
crun main.cpp

# Run a file within a larger project context 
# (The script will automatically detect the project root and use the appropriate build system)
crun src/main.rs
```

### Build Only
Use `cbuild` to just compile the program. It will output the path to the resulting binary or executable wrapper.

```bash
cbuild main.go
# Outputs: /tmp/CodeRunner/main_go
```

### Clean Build Files (Project level)
Use `cclean` to recursively clean build artifacts for all projects in a directory and its subdirectories.

Supports polyglot workspaces across **Rust** (`target`), **Go** (root binaries), **Maven** (`target`), **Gradle** (`build`, `.gradle`), **Node.js** (`dist`, `build`, `.next`, `node_modules`), **Zig** (`zig-out`, `.zig-cache`, `zig-pkg`), **Elixir** (`_build`, `deps`, `.elixir_ls`, `.lexical`), **Lean 4** (`.lake`), **Elm** (`elm-stuff`), **PHP** (`vendor`, `.phpunit.cache`), **Clojure** (`target`, `.cpcache`, `.clj-kondo/.cache`), **Python** (`__pycache__`, `.pytest_cache`, `.venv`), **Haskell** (`.stack-work`, `dist-newstyle`), **CMake**, **Make**, **Swift**, **OCaml**, **Erlang**, **Dart**, **.NET**, **Nim**, **Gleam**, **Mojo**, and **Odin**.

```bash
# Clean current directory and all subdirectories
cclean

# Clean a specific directory and all subdirectories
cclean /path/to/projects

# Dry run to preview what would be cleaned without deleting
cclean --dry-run /path/to/projects

# Show detailed deletion output
cclean -v /path/to/projects
```

### Clean Global Caches & Packages (System level)
Use `gclean` to clean system-wide developer caches, package registries, and heavy toolchains. By default, it gates on a **1 GB** 1st-level directory threshold to focus on high-impact bloat while keeping editor and LSP caches warm.

- **Tier 1 (Default)**: Safe global caches (Zig, npm, Bun, Yarn, Gradle caches/daemons, vcpkg, uv, pip, dune, Steel target, Junie versions, CodeRunner tmp).
- **Tier 2 (`--deps`)**: Package registries and dependency stores (Cargo, Maven, Hex, Ruby gems/bundle, Julia, Stack, Elm, Cabal store/packages, Idris 2 Pack).
- **Tier 3 (`--all`)**: Interactive 1-by-1 confirmation for heavy toolchains:
  - **Rust**: keeps latest stable & nightly, prunes older toolchains.
  - **Lean**: keeps latest Lean toolchain, prunes older versions.
  - **Cabal**: keeps latest GHC store (`ghc-9.14.1`), prunes older GHC versions.
  - **Ollama Models, HuggingFace Models, Gradle JDKs, Alire Ada Toolchains, Neovim Mason Packages, IDE Backups**.

```bash
# Clean safe global caches (Tier 1, tool dirs >= 1 GB)
gclean

# Also clean package registries & downloaded dependencies (Tier 1 & 2: Cargo, Maven, Hex, Cabal, Pack, etc.)
gclean --deps

# Review heavy toolchains and models (Tier 3: Rust, Lean, Cabal GHC stores, Ollama, Alire) with 1-by-1 confirmation
gclean --all

# Set custom minimum tool size threshold (e.g. 500MB, 100MB, or 0 for everything)
gclean --min-size 500
gclean --min-size 100
gclean --min-size 0

# Dry run preview of what would be cleaned without deleting
gclean -n
```

## How it Works

The scripts set up a temporary directory environment (defaulting to `/tmp/CodeRunner`) to hold your compiled binaries and executable wrappers. It relies on `core/builder.sh` to determine the language and the best way to compile or run the program.

## Acknowledgments

A portion of the configuration logic in `core/utils.sh` (specifically the initial environment configuration and encoding mappings) is adapted from the build scripts provided by the **CodeRunner** app for macOS. Full credit for the design of those variables and that initial logic goes to Nikolai Ruhe, the creator of CodeRunner.

## License

This software is provided under the [zlib License](LICENSE).
