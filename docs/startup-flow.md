# Neovim Startup Flow Documentation

When you start Neovim with this configuration, the following sequence of events
occurs:

## 1. Entry Point: `init.lua`

```lua
-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- Clone lazy.nvim if not present
end
vim.opt.rtp:prepend(lazypath)

-- Initialize core configuration
require("wrightbradley.config").init()

-- Set up plugin management
require("lazy").setup({ /* plugin specs */ })

-- Finalize configuration setup
require("wrightbradley.config").setup()
```

## 2. Initial Configuration: `wrightbradley.config.init()`

```lua
function M.init()
  if M.did_init then return end
  M.did_init = true

  -- Delay notifications for better UX
  Util.lazy_notify()

  -- Load options early (before plugins load)
  M.load("options")

  -- Defer clipboard handling for performance
  lazy_clipboard = vim.opt.clipboard
  vim.opt.clipboard = ""

  -- Set up LazyFile event handling
  -- [Event setup code]
end
```

## 3. Options Loading: `wrightbradley.config.options`

- Sets editor behavior (tabs, indentation, line numbers)
- Configures UI elements (status line, colors)
- Sets up search preferences and formatting rules
- Defines global variables for plugins

## 4. Plugin Loading via `lazy.nvim`

- Loads core plugins from `wrightbradley.plugins`
- Loads LSP configurations from `wrightbradley.plugins.lsp`
- Manages plugin dependencies and versions

## 5. Main Configuration Setup: `wrightbradley.config.setup()`

```lua
function M.setup(opts)
  -- Merge options with defaults
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- Load autocmds immediately if opening a file
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  -- Set up VeryLazy event handler
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      -- Load autocmds if deferred
      if lazy_autocmds then M.load("autocmds") end

      -- Load keymaps
      M.load("keymaps")

      -- Restore clipboard setting
      if lazy_clipboard ~= nil then
        vim.opt.clipboard = lazy_clipboard
      end

      -- Set up formatters and root detection
      Util.format.setup()
      Util.root.setup()

      -- [Additional setup code]
    end,
  })

  -- Load colorscheme
  Util.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end)
end
```

## 6. Final Setup: `VeryLazy` Event

After all plugins are loaded, the `VeryLazy` event triggers:

1. **Autocmds**: Loads file watchers, highlighting rules, etc.
2. **Keymaps**: Sets up keyboard shortcuts and command bindings
3. **Formatters**: Configures code formatting via `Util.format.setup()`
4. **Root Detection**: Initializes project root detection via
   `Util.root.setup()`
5. **LSP Setup**: LSP servers are configured and attached to buffers
6. **UI Finalization**: Status line and other UI elements are rendered

## Key Utility Components

Throughout this process, several utility systems are initialized:

- **Util**: Core utility functions for the entire configuration
- **Snacks**: Toggle systems for various Neovim features
- **Format**: Code formatting management
- **Root**: Project directory detection
- **LSP**: Language server protocol configuration

This modular approach allows components to be loaded on-demand, increasing
startup performance while maintaining a rich feature set.
