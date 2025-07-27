# AGENTS.md - Nushell Configuration

## Build/Test Commands
- No formal build system - Nushell configs are interpreted directly
- Test config: `nu --config config.nu --env-config env.nu -c "exit"`
- Validate syntax: `nu --check config.nu` or `nu --check env.nu`

## Code Style Guidelines

### File Structure
- `config.nu`: Main configuration, custom commands, aliases, completions
- `env.nu`: Environment variables only (legacy compatibility)
- Use `archive/` for backup configurations

### Nushell Conventions
- Use snake_case for custom command names and variables
- Prefix environment variables with `$env.`
- Use `def --env` for commands that modify environment
- Comment sections with `# Section Name`
- Use conventional commits format for git messages

### Error Handling
- Use `try/catch` blocks for external commands that may fail
- Check for empty results with `is-empty` before processing
- Use `complete` to capture both stdout and stderr when needed

### Security
- Store sensitive tokens in env.nu (already gitignored)
- Never commit API keys or credentials to version control