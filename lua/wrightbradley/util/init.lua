---@file Core utility functions for Neovim configuration
--- This module provides a set of utility functions and lazy-loading mechanisms
--- for other utility modules. It acts as a central point for accessing various
--- utilities like UI, LSP, and more. It integrates with the lazy.nvim plugin
--- manager for efficient loading of plugins and modules.

local LazyUtil = require("lazy.core.util")

---@class wrightbradley.util: LazyUtilCore
---@field config UtilConfig
---@field ui wrightbradley.util.ui
---@field lsp wrightbradley.util.lsp
---@field root wrightbradley.util.root
---@field terminal wrightbradley.util.terminal
---@field format wrightbradley.util.format
---@field lualine wrightbradley.util.lualine
---@field escape wrightbradley.util.escape
---@field mini wrightbradley.util.mini
---@field pick wrightbradley.util.pick
---@field spinner wrightbradley.util.spinner
---@field cmp wrightbradley.util.cmp
local M = {}

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then
      return LazyUtil[k]
    end
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("wrightbradley.util." .. k)
    return t[k]
  end,
})

--- Checks if the operating system is Windows.
---@return boolean True if the OS is Windows, false otherwise.
function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

--- Retrieves a plugin configuration by name.
---@param name string The name of the plugin.
---@return table|nil The plugin configuration or nil if not found.
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

--- Gets the path to a plugin.
---@param name string The name of the plugin.
---@param path string? Optional subpath within the plugin directory.
---@return string|nil The full path to the plugin or nil if not found.
function M.get_plugin_path(name, path)
  local plugin = M.get_plugin(name)
  path = path and "/" .. path or ""
  return plugin and (plugin.dir .. path)
end

--- Checks if a plugin is available.
---@param plugin string The name of the plugin.
---@return boolean True if the plugin is available, false otherwise.
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

--- Checks if an extra module is available.
---@param extra string The name of the extra module.
---@return boolean True if the extra module is available, false otherwise.
function M.has_extra(extra)
  local Config = require("wrightbradley.config")
  local modname = "wrightbradley.plugins.extras." .. extra
  return vim.tbl_contains(require("lazy.core.config").spec.modules, modname)
    or vim.tbl_contains(Config.json.data.extras, modname)
end

--- Registers a callback for the "VeryLazy" event.
---@param fn fun() The callback function to register.
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

--- Extends a nested list with a key in a table.
--- The nested list will be created if it does not exist.
---@generic T
---@param t T[] The table to extend.
---@param key string The dot-separated key string.
---@param values T[] The values to extend the table with.
---@return T[]? The extended table or nil if the operation failed.
function M.extend(t, key, values)
  local keys = vim.split(key, ".", { plain = true })
  for i = 1, #keys do
    local k = keys[i]
    t[k] = t[k] or {}
    if type(t) ~= "table" then
      return
    end
    t = t[k]
  end
  return vim.list_extend(t, values)
end

--- Retrieves options for a plugin.
---@param name string The name of the plugin.
---@return table The options for the plugin.
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

--- Delays notifications until a certain condition is met.
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

--- Checks if a plugin is loaded.
---@param name string The name of the plugin.
---@return boolean True if the plugin is loaded, false otherwise.
function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

--- Registers a callback for when a plugin is loaded.
---@param name string The name of the plugin.
---@param fn fun(name:string) The callback function to register.
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

--- Safely sets a keymap, avoiding conflicts with lazy key handlers.
--- Sets `silent` to true by default.
---@param mode string|string[] The mode(s) for the keymap.
---@param lhs string The left-hand side of the keymap.
---@param rhs string|function The right-hand side of the keymap.
---@param opts table? Additional options for the keymap.
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

--- Removes duplicates from a list.
---@generic T
---@param list T[] The list to deduplicate.
---@return T[] The deduplicated list.
function M.dedup(list)
  local ret = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end
  return ret
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)

--- Creates an undo point in insert mode.
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string The name of the package.
---@param path string? Optional subpath within the package directory.
---@param opts table? Additional options.
---@return string The full path to the package.
function M.get_pkg_path(pkg, path, opts)
  pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
  local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ""
  local ret = root .. "/packages/" .. pkg .. "/" .. path
  if opts.warn and not vim.loop.fs_stat(ret) and not require("lazy.core.config").headless() then
    M.warn(
      ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(pkg, path)
    )
  end
  return ret
end

--- Override the default title for notifications.
for _, level in ipairs({ "info", "warn", "error" }) do
  M[level] = function(msg, opts)
    opts = opts or {}
    opts.title = opts.title or "Util"
    return LazyUtil[level](msg, opts)
  end
end

local cache = {} ---@type table<(fun()), table<string, any>>
--- Memoizes a function to cache its results.
---@generic T: fun()
---@param fn T The function to memoize.
---@return T The memoized function.
function M.memoize(fn)
  return function(...)
    local key = vim.inspect({ ... })
    cache[fn] = cache[fn] or {}
    if cache[fn][key] == nil then
      cache[fn][key] = fn(...)
    end
    return cache[fn][key]
  end
end

--- Determines the completion engine to use.
---@return string The name of the completion engine.
function M.cmp_engine()
  vim.g.wrightbradley_cmp = vim.g.wrightbradley_cmp or "auto"
  if vim.g.wrightbradley_cmp == "auto" then
    return Util.has_extra("coding.nvim-cmp") and "nvim-cmp" or "blink.cmp"
  end
  return vim.g.wrightbradley_cmp
end

return M
