# Lua Code Documentation Standards

This document outlines the documentation standards and conventions used throughout the Lua codebase in this Neovim configuration.

## Documentation Style

### File Headers

Every Lua file should start with a comprehensive header:

```lua
---@file Brief description of the file's purpose
--- Detailed description of what this file does, its role in the configuration,
--- and any important context or usage information. Explain integration points
--- with other modules and any special considerations.
```

### Module Documentation

For modules that export functions or classes:

```lua
---@class ModuleName Brief description
---@field field_name type Description of field
local M = {}

--- Function description explaining purpose and behavior
---@param param_name type Parameter description
---@param optional_param? type Optional parameter description
---@return type Description of return value
function M.function_name(param_name, optional_param)
  -- Implementation
end

return M
```

### Configuration Files

Plugin configuration files should document their purpose and key features:

```lua
---@file Plugin Name Configuration
--- This file configures [plugin-name] for [primary purpose].
--- It provides [key features] and integrates with [other systems].
---
--- Key features:
--- - Feature 1: Description
--- - Feature 2: Description
---
--- Dependencies: [list major dependencies]
--- Keybindings: [mention key prefix if applicable]

return {
  {
    "author/plugin-name",
    -- configuration
  }
}
```

## Type Annotations

### Basic Types

```lua
---@type string
---@type number
---@type boolean
---@type table
---@type function
---@type any
```

### Complex Types

```lua
---@alias CustomType string|number Custom type definition

---@class ConfigOptions
---@field enabled boolean Whether feature is enabled
---@field timeout number Timeout in milliseconds
---@field callbacks? table<string, function> Optional callback functions

---@type ConfigOptions
local config = {
  enabled = true,
  timeout = 5000
}
```

### Function Signatures

```lua
--- Process data with optional transformation
---@param data table<string, any> Input data to process
---@param transform? function Optional transformation function
---@param options? {timeout?: number, retry?: boolean} Processing options
---@return boolean success Whether processing succeeded
---@return string? error Error message if processing failed
function process_data(data, transform, options)
  -- Implementation
end
```

## Documentation Patterns

### Utility Modules

```lua
---@file Utility Description
--- This utility module provides [functionality] for [use case].
--- It is used by [consumers] to [purpose].

---@class util.module_name
local M = {}

--- Brief description of what this function does
--- More detailed explanation if needed, including examples
---@param param type Description
---@return type Description
function M.function_name(param)
  -- Implementation
end

return M
```

### Plugin Configurations

```lua
---@file Plugin Configuration for Feature
--- Configures [plugin] to provide [functionality].
---
--- Features:
--- - Feature 1
--- - Feature 2
---
--- Keybindings: <leader>xx prefix
--- Dependencies: [list]

local config_var = "value" -- Brief explanation

return {
  {
    "plugin/name",
    event = "LazyEvent",      -- When to load
    dependencies = {},        -- Required plugins
    opts = {
      -- Configuration with comments
    },
    config = function(_, opts)
      -- Setup with explanation
    end,
    keys = {
      -- Keybinding documentation
      { "<leader>xx", "command", desc = "Description" },
    },
  }
}
```

### AI Extension Modules

```lua
---@file AI Extension Name
--- This extension provides [functionality] for AI interactions.
--- It [purpose] and integrates with [systems].
---
--- Usage:
--- ```lua
--- extensions = {
---   ["extension-name"] = {
---     opts = {
---       option = "value"
---     }
---   }
--- }
---

---@class ExtensionOpts
---@field option type Description of option

---@class ExtensionAPI
---@field setup function Setup function
---@field exports table Exported functions

local Extension = {}

--- Setup the extension with provided options
---@param opts ExtensionOpts Configuration options
function Extension.setup(opts)
  -- Implementation
end

return Extension
```

## Comment Standards

### Inline Comments

```lua
-- Brief explanation of complex logic
local result = complex_calculation()

-- TODO: Implement feature X
-- HACK: Workaround for issue Y
-- NOTE: Important information about Z
-- WARN: This could cause problems if...
```

### Block Comments

```lua
--[[
Multi-line explanation of complex algorithm or logic.
Used for detailed explanations that don't fit in single-line comments.
Explain the reasoning, alternatives considered, and any trade-offs.
--]]
```

### Section Separators

```lua
-- ============================================================================
-- SECTION NAME
-- ============================================================================

-- Or for smaller sections:
-- ----------------------------------------------------------------------------
-- Subsection Name
-- ----------------------------------------------------------------------------
```

## Variable Documentation

### Local Variables

```lua
--- Description of what this variable stores
---@type table<string, ConfigOption>
local configuration_map = {}

--- User-provided settings for the module
---@type UserSettings
local user_settings = {}
```

### Constants

```lua
--- Default timeout for network operations (in milliseconds)
---@type number
local DEFAULT_TIMEOUT = 5000

--- Available log levels for the application
---@type table<string, number>
local LOG_LEVELS = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
}
```

## Example Documentation

### Well-Documented Utility Function

```lua
---@file LSP Utility Functions
--- Provides helper functions for LSP operations including server management,
--- diagnostic handling, and client information retrieval.

---@class util.lsp
local M = {}

--- Get all active LSP clients for a buffer with optional filtering
--- This function retrieves LSP clients and can filter by client name,
--- capabilities, or other criteria to find specific language servers.
---@param opts? {bufnr?: number, filter?: {name?: string, method?: string}} Options for client retrieval
---   - bufnr: Buffer number (defaults to current buffer)
---   - filter: Filter criteria for clients
---     - name: Filter by client name (e.g., "lua_ls", "pyright")
---     - method: Filter by supported method (e.g., "textDocument/hover")
---@return lsp.Client[] clients List of matching LSP clients
---@usage
--- -- Get all clients for current buffer
--- local clients = M.get_clients()
---
--- -- Get specific client by name
--- local lua_clients = M.get_clients({filter = {name = "lua_ls"}})
function M.get_clients(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if opts.filter then
    clients = vim.tbl_filter(function(client)
      if opts.filter.name and client.name ~= opts.filter.name then
        return false
      end
      if opts.filter.method and not client.supports_method(opts.filter.method) then
        return false
      end
      return true
    end, clients)
  end

  return clients
end

return M
```

## Best Practices

### 1. Document Public APIs

All public functions, classes, and modules should have comprehensive documentation.

### 2. Use Consistent Formatting

- Use `---` for LuaLS annotations
- Use `--` for regular comments
- Maintain consistent indentation and spacing

### 3. Include Examples

For complex functions, include usage examples in `@usage` tags.

### 4. Document Configuration

Plugin configurations should explain:

- What the plugin does
- Key features provided
- Important configuration options
- Keybindings added
- Integration points

### 5. Maintain Accuracy

Keep documentation updated when code changes. Outdated documentation is worse than no documentation.

### 6. Use Descriptive Names

Choose clear, descriptive names for functions, variables, and types that reduce the need for extensive documentation.

## Tools and Integration

### LuaLS Support

The configuration uses LuaLS (Lua Language Server) which provides:

- Type checking based on annotations
- Hover documentation
- Completion suggestions
- Diagnostic warnings for type mismatches

### Documentation Generation

Consider using tools like:

- `ldoc` for generating HTML documentation
- `emmylua` annotations for IDE support
- Custom scripts to extract and format documentation

This documentation standard ensures that the Lua codebase remains maintainable, understandable, and accessible to both current and future contributors.
