# AGENTS.md - Helix Configuration

## Build/Test Commands
- No build system - this is a personal Helix editor configuration
- No specific test framework - validate configs by reloading: `:config-reload`
- Check Steel syntax: `steel <file.scm>` or validate via Helix LSP
- Reload configuration: `:config-reload` in Helix editor

## Language & Framework
- **Steel Scheme** - Primary configuration language (init.scm, *.scm files)
- **TOML** - Editor/language configuration (config.toml, languages.toml)
- Package management via Steel's built-in `require`/`provide` system

## Code Style Guidelines
- **File naming**: kebab-case with .scm extension (e.g., `file-tree.scm`)
- **Functions**: lisp-case naming (e.g., `load-package`, `move-cursor-down`)
- **Globals**: Wrap in `*asterisks*` (e.g., `*last-focus*`, `*loaded-package-registry*`)
- **Imports**: Use `(require ...)` for modules, `(require-builtin ...)` for built-ins
- **Prefixes**: Namespace with `(prefix-in ...)` (e.g., `helix.`, `helix.static.`)
- **Documentation**: Use `;;@doc` comments above function definitions
- **Indentation**: Standard Scheme indentation, align function arguments vertically
- **Structs**: PascalCase for data types (e.g., `Picker`, `Component`)
- **Constants**: Use `define` for immutable values, avoid hardcoded strings
- **Error handling**: Use `when`/`unless` for conditionals, `error` for failures
- **Exports**: Always use `(provide ...)` to export public functions from modules
- **TOML**: Use kebab-case keys, group related settings, enable auto-format where appropriate