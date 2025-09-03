# AGENTS.md - Helix Steel Configuration

## Build/Test Commands
- `forge install` - Install Steel packages and dependencies
- `cargo build` - Build Rust components (if any)
- `cargo test` - Run tests (if any)
- No single test command available - this is a configuration repository

## Language & Framework
- **Steel Scheme** - Primary language for Helix editor configuration
- **TOML** - Configuration files (config.toml)
- Package management via `forge` CLI

## Code Style Guidelines
- **File naming**: kebab-case with .scm extension
- **Functions**: lisp-case naming (e.g., `load-package`, `move-cursor-down`)
- **Constants**: *surrounding-asterisks* for globals (e.g., `*loaded-package-registry*`)
- **Imports**: Use `require` for modules, `require-builtin` for built-ins
- **Prefixes**: Use `prefix-in` for namespacing (e.g., `helix.`, `helix.static.`)
- **Documentation**: Use `;;@doc` comments for function documentation
- **Indentation**: Scheme-style indentation, 2-space alignment
- **Structs**: PascalCase (e.g., `Picker`)
- **Error handling**: Use `with-handler` for error management
- **Provides**: Always use `(provide ...)` to export public functions