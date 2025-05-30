---@file Picker abstraction utilities for Neovim
--- This module provides utility functions for abstracting picker functionality
--- in Neovim. It allows for integration with different picker plugins like Telescope,
--- FZF, and Snacks, providing a unified interface for opening and managing pickers.

---@class util.pick
---@overload fun(command:string, opts?:util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

---@class util.pick.Opts: table<string, any>
---@field root? boolean Whether to use the project root as the working directory.
---@field cwd? string The current working directory for the picker.
---@field buf? number The buffer number to use for context.
---@field show_untracked? boolean Whether to show untracked files in the picker.

---@class LazyPicker
---@field name string The name of the picker.
---@field open fun(command:string, opts?:util.pick.Opts) Function to open the picker.
---@field commands table<string, string> Table of picker commands.

---@type LazyPicker?
M.picker = nil

--- Registers a picker.
---@param picker LazyPicker The picker to register.
---@return boolean True if the picker was registered successfully, false otherwise.
function M.register(picker)
  -- This only happens when using :LazyExtras
  -- so allow to get the full spec
  if vim.v.vim_did_enter == 1 then
    return true
  end

  if M.picker and M.picker.name ~= M.want() then
    M.picker = nil
  end

  if M.picker and M.picker.name ~= picker.name then
    -- Util.warn(
    --   "`Util.pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`"
    -- )
    return false
  end
  M.picker = picker
  return true
end

--- Determines the desired picker to use.
---@return "telescope" | "fzf" | "snacks" The name of the desired picker.
function M.want()
  vim.g.picker = vim.g.wrightbradley_picker or "auto"
  if vim.g.picker == "auto" then
    return "snacks"
  end
  return vim.g.picker
end

--- Opens a picker with a specified command and options.
---@param command? string The picker command to execute.
---@param opts? util.pick.Opts Optional options for the picker.
function M.open(command, opts)
  if not M.picker then
    return Util.error("Util.pick: picker not set")
  end

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == "boolean" then
    Util.warn("Util.pick: opts.cwd should be a string or nil")
    opts.cwd = nil
  end

  if not opts.cwd and opts.root ~= false then
    opts.cwd = Util.root({ buf = opts.buf })
  end

  command = M.picker.commands[command] or command
  M.picker.open(command, opts)
end

--- Wraps a picker command and options into a function.
---@param command? string The picker command to wrap.
---@param opts? util.pick.Opts Optional options for the picker.
---@return fun() A function that opens the picker with the specified command and options.
function M.wrap(command, opts)
  opts = opts or {}
  return function()
    Util.pick.open(command, vim.deepcopy(opts))
  end
end

--- Returns a function to open a picker for configuration files.
---@return fun() A function that opens the picker for configuration files.
function M.config_files()
  return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
