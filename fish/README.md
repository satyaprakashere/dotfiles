# Fish Shell Configuration

Cross-platform Fish shell configuration optimized for macOS across different architectures (Apple Silicon and Intel).

## Architecture & Homebrew Portability

Homebrew defaults to different installation prefixes depending on the Mac architecture:
- **Apple Silicon (ARM64)**: `/opt/homebrew`
- **Intel (x86_64)**: `/usr/local`

This configuration automatically initializes Homebrew using `brew shellenv` and dynamically resolves paths using `(brew --prefix)`:

1. **Automatic Initialization**:
   - Detects `/opt/homebrew` or `/usr/local` automatically and sources `brew shellenv`.
   - Exports `$HOMEBREW_PREFIX` and adds `bin`/`sbin` to the PATH.
   - Falls back gracefully if running in an environment without Homebrew.

2. **Dynamic Tool & Library Paths**:
   - **Autojump**: Sourced dynamically via `(brew --prefix)/share/autojump/autojump.fish`.
   - **Mold Linker**: Sets `RUSTFLAGS` with `-fuse-ld=(brew --prefix)/bin/mold` if mold is present.
   - **Dotnet**: Sets `DOTNET_ROOT` to `(brew --prefix)/opt/dotnet/libexec`.
   - **Vulkan & MoltenVK**: Dynamically points `VULKAN_SDK` and `DYLD_LIBRARY_PATH` to `(brew --prefix)/opt/vulkan-loader` and `(brew --prefix)/opt/molten-vk/lib`.
   - **C/C++ Build Environment**: Sets `LIBRARY_PATH`, `C_INCLUDE_PATH`, `CPPFLAGS`, and `LDFLAGS` to `(brew --prefix)/lib` and `(brew --prefix)/include`.
   - **LLVM & OpenJDK**: Dynamically appends binary paths, compiler flags, and library flags only if the respective formulas are installed.

## Directory Structure

```
fish/
├── config.fish         # Main shell configuration
├── conf.d/             # Modular configuration snippets (loaded automatically)
│   ├── fish_ai.fish
│   ├── fish_frozen_key_bindings.fish
│   ├── fish_frozen_theme.fish
│   └── sdk.fish
├── functions/          # Autoloaded Fish functions
│   ├── brew.fish       # Homebrew wrapper
│   ├── cf.fish         # Change directory to command's source location
│   ├── openf.fish      # Reveal command's binary/target in Finder
│   └── ...
├── completions/        # Tab completions
└── themes/             # Fish prompt / syntax themes
```

## Features & Cleanup Highlights

- **Autoloaded Functions**: Standalone utilities such as `cf` and `openf` are placed in `functions/` to be loaded on demand instead of cluttering `config.fish`.
- **Portable Paths**: Replaced hardcoded home paths (`/Users/<username>`) with `~` and `$HOME`.
- **Idempotent PATH Management**: Uses `fish_add_path` for all user toolchains (Go, Bun, Cargo, Rustup, Emacs, Roc, Antigravity).
- **Guarded Integrations**: Wrapped interactive tool setups (`starship`, `fzf`, `fd`) with `type -q` checks to prevent startup errors if a tool is missing on any machine.
- **Deduplication**: Cleaned up duplicated blocks (OPAM init, redundant IDE and Emacs paths) and removed obsolete conflicting flags.
