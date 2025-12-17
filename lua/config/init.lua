---@file Main configuration initialization
--- This file initializes the core Neovim configuration, setting up utilities,
--- options, keymaps, and autocommands. It acts as the entry point for the
--- configuration, integrating various modules and setting the colorscheme.

_G.Util = require("util")

---@class UtilConfig: UtilOptions
local M = {}

Util.config = M

---@class UtilOptions
local defaults = {
  ---@type string|fun() Colorscheme to use
  colorscheme = function()
    require("tokyonight").load()
  end,
  -- icons used by other plugins
  -- stylua: ignore
  ---@type table<string, table> Icons used by other plugins
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = "󰆼 ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
  ---@type table<string, string[]|boolean>? Kind filter for different filetypes
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    markdown = false,
    help = false,
    -- you can specify a different filter for each filetype
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      -- "Package", -- remove package since luals uses it for control flow structures
      "Property",
      "Struct",
      "Trait",
    },
  },
}

---@type UtilOptions
local options ---@type UtilOptions
local lazy_clipboard ---@type string|nil

--- Sets up the configuration with optional overrides.
---@param opts? UtilOptions Optional configuration overrides.
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- autocmds can be loaded lazily when not opening a file
  -- Load autocommands and keymaps
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("Util", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then
        M.load("autocmds")
      end
      M.load("keymaps")
      if lazy_clipboard ~= nil then
        vim.opt.clipboard = lazy_clipboard
      end

      Util.format.setup()
      Util.root.setup()

      vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

      vim.api.nvim_create_user_command("LazyLoaded", function()
        local plugins = require("lazy").plugins()
        local loaded = {}
        local not_loaded = {}
        
        for _, p in ipairs(plugins) do
          if p._.loaded then
            table.insert(loaded, p.name)
          else
            table.insert(not_loaded, p.name)
          end
        end
        
        table.sort(loaded)
        table.sort(not_loaded)
        
        local lines = {
          "# Loaded Plugins (" .. #loaded .. "/" .. #plugins .. ")",
          "",
        }
        for _, name in ipairs(loaded) do
          table.insert(lines, "✓ " .. name)
        end
        
        table.insert(lines, "")
        table.insert(lines, "# Not Loaded (" .. #not_loaded .. ")")
        table.insert(lines, "")
        for _, name in ipairs(not_loaded) do
          table.insert(lines, "○ " .. name)
        end
        
        -- Create a new buffer and display the results
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        
        -- Open in a split
        vim.cmd("split")
        vim.api.nvim_win_set_buf(0, buf)
        vim.api.nvim_buf_set_name(buf, "Lazy Loaded Plugins")
      end, { desc = "Show which plugins are currently loaded" })

      local health = require("lazy.health")
      vim.list_extend(health.valid, {
        "recommended",
        "desc",
        "vscode",
      })
    end,
  })

  Util.track("colorscheme")
  Util.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
  Util.track()
end

--- Retrieves the kind filter for a buffer.
---@param buf? number Buffer number.
---@return string[]? Kind filter for the buffer.
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

--- Loads a module from config
---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      Util.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  _load("config." .. name)
  if vim.bo.filetype == "lazy" then
    -- HACK: Util may have overwritten options of the Lazy ui, so reset this here
    vim.cmd([[do VimResized]])
  end
end

M.did_init = false
--- Initializes the configuration.
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true

  -- delay notifications till vim.notify was replaced or after 500ms
  Util.lazy_notify()

  -- load options here, before lazy init while sourcing plugin modules
  -- this is needed to make sure options will be correctly applied
  -- after installing missing plugins
  M.load("options")
  -- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
  lazy_clipboard = vim.opt.clipboard
  vim.opt.clipboard = ""

  -- Add support for the LazyFile event
  local Event = require("lazy.core.handler.event")
  M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }
  Event.mappings.LazyFile = { id = "LazyFile", event = M.lazy_file_events }
  Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options UtilConfig
    return options[key]
  end,
})

return M
