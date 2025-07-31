# Customization Guide

This guide covers how to customize and extend this Neovim configuration to suit your personal preferences and workflow.

## Configuration Architecture

### Directory Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config/           # Core configuration
│   │   ├── init.lua      # Main config module
│   │   ├── autocmds.lua  # Auto commands
│   │   ├── keymaps.lua   # Key mappings
│   │   └── options.lua   # Vim options
│   ├── plugins/          # Plugin configurations
│   ├── util/            # Utility functions
│   └── ai/              # AI-related modules
├── docs/                # Documentation
└── snippets/            # Code snippets
```

### Loading Order

1. `init.lua` - Sets leader keys and bootstraps lazy.nvim
2. `config.init()` - Loads options and sets up lazy loading
3. Plugin loading via lazy.nvim
4. `config.setup()` - Finalizes configuration

## Basic Customization

### 1. Personal Configuration File

Create a personal configuration file that won't conflict with updates:

```lua
-- ~/.config/nvim/lua/config/personal.lua
local M = {}

function M.setup()
  -- Your personal customizations here
end

return M
```

Then load it in your main configuration:

```lua
-- Add to ~/.config/nvim/lua/config/init.lua
require("config.personal").setup()
```

### 2. Vim Options

#### Basic Editor Settings

```lua
-- lua/config/personal.lua
local M = {}

function M.setup()
  local opt = vim.opt

  -- Line numbers
  opt.relativenumber = false        -- Disable relative line numbers
  opt.number = true                 -- Enable absolute line numbers

  -- Indentation
  opt.tabstop = 4                   -- 4 spaces for tabs
  opt.shiftwidth = 4                -- 4 spaces for indentation
  opt.expandtab = true              -- Use spaces instead of tabs

  -- Appearance
  opt.wrap = true                   -- Enable line wrapping
  opt.colorcolumn = "100"           -- Show column at 100 characters
  opt.cursorline = true             -- Highlight current line

  -- Behavior
  opt.mouse = ""                    -- Disable mouse
  opt.clipboard = "unnamedplus"     -- Use system clipboard
  opt.swapfile = false              -- Disable swap files
  opt.backup = false                -- Disable backup files
  opt.undofile = true               -- Enable persistent undo
end

return M
```

#### File-specific Settings

```lua
-- lua/config/personal.lua
function M.setup()
  -- Python-specific settings
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      vim.opt_local.tabstop = 4
      vim.opt_local.shiftwidth = 4
      vim.opt_local.textwidth = 88  -- Black formatter line length
    end,
  })

  -- Markdown settings
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      vim.opt_local.spell = true
    end,
  })
end
```

### 3. Custom Keybindings

#### Leader Key

```lua
-- Change leader key (add to init.lua before plugin loading)
vim.g.mapleader = ","
vim.g.maplocalleader = ","
```

#### Custom Mappings

```lua
-- lua/config/personal.lua
function M.setup()
  local map = vim.keymap.set

  -- Quick save
  map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

  -- Better window navigation
  map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
  map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
  map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
  map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

  -- Custom AI shortcuts
  map("n", "<leader>cc", function()
    require("codecompanion").chat()
  end, { desc = "Quick AI Chat" })

  -- Custom file operations
  map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
  map("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save file" })
end
```

## Plugin Customization

### 1. Modifying Existing Plugins

Create override files in `lua/plugins/`:

```lua
-- lua/plugins/custom-nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  opts = {
    view = {
      width = 40,              -- Wider sidebar
      side = "right",          -- Move to right side
    },
    renderer = {
      icons = {
        show = {
          git = false,         -- Hide git icons
        },
      },
    },
  },
}
```

### 2. Adding New Plugins

```lua
-- lua/plugins/my-plugins.lua
return {
  -- Example: Add a new colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
      })
    end,
  },

  -- Example: Add a note-taking plugin
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/notes",
        },
      },
    },
    keys = {
      { "<leader>no", "<cmd>ObsidianOpen<cr>", desc = "Open Obsidian" },
      { "<leader>nn", "<cmd>ObsidianNew<cr>", desc = "New note" },
    },
  },
}
```

### 3. Disabling Plugins

```lua
-- lua/plugins/disabled.lua
return {
  -- Disable a plugin
  { "plugin-name", enabled = false },

  -- Conditionally disable
  {
    "another-plugin",
    enabled = function()
      return vim.fn.hostname() ~= "work-laptop"
    end,
  },
}
```

## Colorscheme Customization

### 1. Changing the Default Theme

```lua
-- lua/config/personal.lua
function M.setup()
  -- Change colorscheme
  vim.cmd.colorscheme("catppuccin")

  -- Or use a function for conditional theming
  local function set_colorscheme()
    local hour = tonumber(os.date("%H"))
    if hour >= 6 and hour < 18 then
      vim.cmd.colorscheme("tokyonight-day")
    else
      vim.cmd.colorscheme("tokyonight-night")
    end
  end

  set_colorscheme()
end
```

### 2. Custom Highlights

```lua
-- lua/config/personal.lua
function M.setup()
  -- Create autocmd for custom highlights
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      -- Custom highlight groups
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2d3748" })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#4a5568" })

      -- Make comments more prominent
      vim.api.nvim_set_hl(0, "Comment", { fg = "#81c784", italic = true })

      -- Custom diagnostic colors
      vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f56565" })
      vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#ed8936" })
    end,
  })
end
```

## LSP Customization

### 1. Custom LSP Settings

```lua
-- lua/plugins/custom-lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Customize Python LSP
      pyright = {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "strict",
              autoImportCompletions = true,
            },
          },
        },
      },

      -- Add a custom LSP server
      ["custom-ls"] = {
        cmd = { "custom-language-server", "--stdio" },
        filetypes = { "customlang" },
        root_dir = function(fname)
          return require("lspconfig.util").find_git_ancestor(fname)
        end,
      },
    },
  },
}
```

### 2. Custom LSP Keybindings

```lua
-- lua/config/personal.lua
function M.setup()
  -- Override LSP keybindings
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf

      local map = function(mode, key, cmd, desc)
        vim.keymap.set(mode, key, cmd, { buffer = bufnr, desc = desc })
      end

      -- Custom LSP mappings
      map("n", "gR", vim.lsp.buf.references, "References")
      map("n", "gI", vim.lsp.buf.implementation, "Implementation")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")
    end,
  })
end
```

## AI Customization

### 1. Custom AI Prompts

```lua
-- lua/ai/prompts/custom.lua
local M = {}

M.custom_prompts = {
  ["code-review"] = {
    strategy = "chat",
    description = "Comprehensive code review",
    prompts = {
      {
        role = "user",
        content = function(context)
          return string.format([[
Please review this code for:
1. Correctness and potential bugs
2. Performance optimizations
3. Code style and best practices
4. Security considerations
]], context.filetype, context.selection)
        end,
      },
    },
  },

  ["explain-detailed"] = {
    strategy = "chat",
    description = "Detailed code explanation",
    prompts = {
      {
        role = "system",
        content = "You are a senior software engineer. Provide detailed explanations of code, including algorithms, design patterns, and trade-offs."
      },
      {
        role = "user",
        content = function(context)
          return "Please explain this code in detail:\n\n" .. context.selection
        end,
      },
    },
  },
}

return M
```

### 2. Custom AI Extensions

```lua
-- lua/ai/extensions/custom-analytics.lua
local M = {}

function M.setup(opts)
  -- Custom analytics tracking
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequestStarted",
    callback = function(args)
      -- Custom logging logic
      print("AI request started:", vim.inspect(args.data))
    end,
  })
end

return M
```

## Statusline Customization

### 1. Lualine Configuration

```lua
-- lua/plugins/custom-lualine.lua
return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
      section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        {
          "filename",
          path = 1,  -- Show relative path
          symbols = {
            modified = " ●",
            readonly = " ",
            unnamed = "[No Name]",
          },
        },
      },
      lualine_x = {
        "encoding",
        "fileformat",
        "filetype",
        {
          -- Show LSP server names
          function()
            local clients = vim.lsp.get_active_clients({ bufnr = 0 })
            if #clients == 0 then
              return ""
            end
            local names = {}
            for _, client in ipairs(clients) do
              table.insert(names, client.name)
            end
            return " " .. table.concat(names, ", ")
          end,
        },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
```

## Project-Specific Configuration

### 1. Local Configuration

Create `.nvimrc` in project roots:

```lua
-- .nvimrc (in project root)
-- This file will be loaded automatically if trustworthy

-- Project-specific settings
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

-- Project-specific keymaps
vim.keymap.set("n", "<leader>pr", "<cmd>!npm run dev<cr>", { desc = "Run dev server" })
vim.keymap.set("n", "<leader>pt", "<cmd>!npm test<cr>", { desc = "Run tests" })

-- Project-specific LSP settings
require("lspconfig").tsserver.setup({
  settings = {
    typescript = {
      preferences = {
        importModuleSpecifier = "relative"
      }
    }
  }
})
```

### 2. Directory-based Configuration

```lua
-- lua/config/personal.lua
function M.setup()
  -- Different settings for different project types
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      local cwd = vim.fn.getcwd()

      if string.match(cwd, "python") then
        vim.opt.tabstop = 4
        vim.opt.shiftwidth = 4
      elseif string.match(cwd, "javascript") or string.match(cwd, "typescript") then
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
      end
    end,
  })
end
```

## Performance Customization

### 1. Lazy Loading

```lua
-- lua/plugins/optimized.lua
return {
  {
    "expensive-plugin",
    lazy = true,
    event = "VeryLazy",  -- Load after startup
    cmd = "PluginCommand", -- Load on command
    ft = "filetype",     -- Load for specific filetypes
    keys = {             -- Load on specific keymap
      { "<leader>x", "<cmd>PluginCommand<cr>", desc = "Plugin action" },
    },
  },
}
```

### 2. Startup Optimization

```lua
-- lua/config/personal.lua
function M.setup()
  -- Disable unnecessary providers
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_ruby_provider = 0

  -- Optimize for large files
  vim.api.nvim_create_autocmd("BufReadPre", {
    callback = function(args)
      local file = vim.fn.expand("<afile>")
      local size = vim.fn.getfsize(file)

      if size > 1024 * 1024 then  -- 1MB
        -- Disable expensive features for large files
        vim.opt_local.syntax = "off"
        vim.opt_local.wrap = false
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
      end
    end,
  })
end
```

## Environment-Specific Configuration

### 1. Machine-specific Settings

```lua
-- lua/config/personal.lua
function M.setup()
  local hostname = vim.fn.hostname()

  if hostname == "work-laptop" then
    -- Work-specific settings
    vim.g.copilot_enabled = false
    vim.opt.backup = true
    vim.opt.backupdir = "/secure/backup/nvim"

  elseif hostname == "home-desktop" then
    -- Home-specific settings
    vim.g.copilot_enabled = true
    vim.opt.transparency = true
  end
end
```

### 2. Conditional Plugin Loading

```lua
-- lua/plugins/conditional.lua
return {
  {
    "work-specific-plugin",
    enabled = function()
      return vim.fn.hostname() == "work-laptop"
    end,
  },

  {
    "github/copilot.vim",
    enabled = function()
      return os.getenv("ENABLE_COPILOT") == "true"
    end,
  },
}
```

## Tips and Best Practices

### 1. Keep Customizations Organized

- Use separate files for different types of customizations
- Document your changes
- Use descriptive variable names
- Group related configurations together

### 2. Test Changes Safely

```lua
-- Test configuration changes
function M.test_config()
  local ok, err = pcall(function()
    -- Your configuration code here
  end)

  if not ok then
    vim.notify("Configuration error: " .. err, vim.log.levels.ERROR)
  end
end
```

### 3. Performance Monitoring

```vim
" Check startup time
:Lazy profile

" Check which plugins are loading
:Lazy

" Check LSP status
:LspInfo

" Check health
:checkhealth
```

### 4. Backup Important Settings

```bash
# Backup your personal configuration
cp ~/.config/nvim/lua/config/personal.lua ~/personal-nvim-backup.lua

# Version control your customizations
cd ~/.config/nvim
git add lua/config/personal.lua
git commit -m "Add personal customizations"
```

This guide should help you customize the configuration to fit your specific needs while maintaining compatibility with future updates.
