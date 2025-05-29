---@file Code formatting utilities for Neovim
--- This module provides utility functions for managing code formatters and
--- handling formatting operations in Neovim. It integrates with LSP and other
--- formatting tools to provide a seamless formatting experience.

---@class wrightbradley.util.format
---@overload fun(opts?: {force?:boolean})
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.format(...)
  end,
})

---@class LazyFormatter
---@field name string The name of the formatter.
---@field primary? boolean Whether the formatter is primary.
---@field format fun(bufnr:number) The function to format a buffer.
---@field sources fun(bufnr:number):string[] The function to get sources for a buffer.
---@field priority number The priority of the formatter.

M.formatters = {} ---@type LazyFormatter[]

--- Registers a new formatter.
---@param formatter LazyFormatter The formatter to register.
function M.register(formatter)
  M.formatters[#M.formatters + 1] = formatter
  table.sort(M.formatters, function(a, b)
    return a.priority > b.priority
  end)
end

--- Returns the format expression for the current buffer.
---@return string The format expression.
function M.formatexpr()
  if Util.has("conform.nvim") then
    return require("conform").formatexpr()
  end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

--- Resolves active formatters for a buffer.
---@param buf? number The buffer number.
---@return (LazyFormatter|{active:boolean,resolved:string[]})[] List of resolved formatters.
function M.resolve(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local have_primary = false
  ---@param formatter LazyFormatter
  return vim.tbl_map(function(formatter)
    local sources = formatter.sources(buf)
    local active = #sources > 0 and (not formatter.primary or not have_primary)
    have_primary = have_primary or (active and formatter.primary) or false
    return setmetatable({
      active = active,
      resolved = sources,
    }, { __index = formatter })
  end, M.formatters)
end

--- Displays information about the formatters for a buffer.
---@param buf? number The buffer number.
function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[buf].autoformat
  local enabled = M.enabled(buf)
  local lines = {
    "# Status",
    ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    ("- [%s] buffer **%s**"):format(
      enabled and "x" or " ",
      baf == nil and "inherit" or baf and "enabled" or "disabled"
    ),
  }
  local have = false
  for _, formatter in ipairs(M.resolve(buf)) do
    if #formatter.resolved > 0 then
      have = true
      lines[#lines + 1] = "\n# " .. formatter.name .. (formatter.active and " ***(active)***" or "")
      for _, line in ipairs(formatter.resolved) do
        lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.active and "x" or " ", line)
      end
    end
  end
  if not have then
    lines[#lines + 1] = "\n***No formatters available for this buffer.***"
  end
  Util[enabled and "info" or "warn"](
    table.concat(lines, "\n"),
    { title = "LazyFormat (" .. (enabled and "enabled" or "disabled") .. ")" }
  )
end

--- Checks if autoformatting is enabled for a buffer.
---@param buf? number The buffer number.
---@return boolean True if autoformatting is enabled, false otherwise.
function M.enabled(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local gaf = vim.g.autoformat
  local baf = vim.b[buf].autoformat

  -- If the buffer has a local value, use that
  if baf ~= nil then
    return baf
  end

  -- Otherwise use the global value if set, or true by default
  return gaf == nil or gaf
end

--- Toggles autoformatting for a buffer.
---@param buf? boolean Whether to toggle for the buffer.
function M.toggle(buf)
  M.enable(not M.enabled(), buf)
end

--- Enables or disables autoformatting.
---@param enable? boolean Whether to enable autoformatting.
---@param buf? boolean Whether to apply to the buffer.
function M.enable(enable, buf)
  if enable == nil then
    enable = true
  end
  if buf then
    vim.b.autoformat = enable
  else
    vim.g.autoformat = enable
    vim.b.autoformat = nil
  end
  M.info()
end

--- Formats the current buffer using registered formatters.
---@param opts? {force?:boolean, buf?:number} Optional formatting options.
function M.format(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not ((opts and opts.force) or M.enabled(buf)) then
    return
  end

  local done = false
  for _, formatter in ipairs(M.resolve(buf)) do
    if formatter.active then
      done = true
      Util.try(function()
        return formatter.format(buf)
      end, { msg = "Formatter `" .. formatter.name .. "` failed" })
    end
  end

  if not done and opts and opts.force then
    Util.warn("No formatter available", { title = "Util" })
  end
end

--- Sets up the formatting system and related autocommands.
function M.setup()
  -- Autoformat autocmd
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("LazyFormat", {}),
    callback = function(event)
      M.format({ buf = event.buf })
    end,
  })

  -- Manual format
  vim.api.nvim_create_user_command("LazyFormat", function()
    M.format({ force = true })
  end, { desc = "Format selection or buffer" })

  -- Format info
  vim.api.nvim_create_user_command("LazyFormatInfo", function()
    M.info()
  end, { desc = "Show info about the formatters for the current buffer" })
end

--- Toggles snacks formatting for a buffer.
---@param buf? boolean Whether to toggle for the buffer.
---@return SnacksToggle The snacks toggle object.
function M.snacks_toggle(buf)
  return Snacks.toggle({
    name = "Auto Format (" .. (buf and "Buffer" or "Global") .. ")",
    get = function()
      if not buf then
        return vim.g.autoformat == nil or vim.g.autoformat
      end
      return Util.format.enabled()
    end,
    set = function(state)
      Util.format.enable(state, buf)
    end,
  })
end

return M
