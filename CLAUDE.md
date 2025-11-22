# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a Neovim configuration written primarily in Fennel (a Lisp that compiles to Lua). The configuration is structured as follows:

### Core Structure
- `init.lua` - Entry point that bootstraps Lazy.nvim and Hotpot.nvim, then loads Fennel modules
- `fnl/` - Main Fennel source directory containing all configuration modules
- `after_opt/` - Contains Lua configuration files loaded after plugin setup
- `lua/` - Direct Lua modules and utilities

### Key Components
- **kaza** - Custom utility framework providing macros and helper functions
- **hotpot.nvim** - Enables Fennel compilation and evaluation in Neovim
- **lazy.nvim** - Plugin manager with lazy loading configuration
- **Fennel configuration modules**:
  - `fnl/core/` - Core Neovim settings (options, mappings, autocommands, LSP)
  - `fnl/plugs.fnl` - Plugin definitions and configurations
  - `fnl/setup.fnl` - Main setup orchestration
  - `fnl/kaza/` - Custom utility framework
  - `fnl/util/` - Utility functions and macros

### Plugin Management
The configuration uses Lazy.nvim with extensive lazy loading. Plugins are defined in `fnl/plugs.fnl` with event-based loading patterns and custom configuration through lambda functions.

## Common Development Commands

### Package Management
- Plugin installation and updates are handled automatically by Lazy.nvim
- Run `:Lazy` to open the plugin manager interface
- Run `:Lazy sync` to update all plugins

### Fennel Development
- Hotpot.nvim compiles Fennel files automatically
- Use `:Fnl` commands for Fennel REPL and evaluation
- Fennel files in `fnl/` are automatically compiled to `lua/` when modified

### LSP and Formatting
- LSP configurations are in `after_opt/lsp_conf.lua`
- Formatting is handled by null-ls with stylua for Lua files
- Mason.nvim manages LSP server installations

### Testing Configuration
- Source configuration changes with `:source %` or restart Neovim
- Use `:checkhealth` to diagnose configuration issues
- Monitor startup time with `nvim --startuptime startup.log`

## File Organization

### Configuration Loading Order
1. `init.lua` - Bootstrap and load Fennel compiler
2. `fnl/kaza/init.fnl` - Initialize utility framework
3. `fnl/core/opt/init.fnl` - Set Neovim options
4. `fnl/plugs.fnl` - Load plugin specifications
5. `fnl/setup.fnl` - Final setup and customizations

### Key Directories
- `UltiSnips/` - Code snippets for various languages
- `after/ftplugin/` - Filetype-specific configurations
- `plug/` - Legacy Vim scripts and utilities
- `gallery/` - Screenshots and documentation images

## Development Notes

### Fennel Conventions
- Use kebab-case for function names in Fennel
- Macros are imported from `util.macros` and `kaza.macros`
- Configuration uses functional programming patterns with immutable data structures

### Plugin Configuration Patterns
- Most plugins use lazy loading with `["User plug-lazy-load"]` event
- Configuration functions use lambda expressions `(λ [] ...)`
- Key mappings are organized with prefix-based systems through the kaza framework

### Custom Utilities
- `req-f` and `ref-f` macros for safe require calls
- `nmaps` function for creating nested key mappings
- Custom command definitions through `cmd` macro