---@class util.mdterm
--- Embed mdterm markdown viewer via Snacks.terminal (lazygit-style).
local M = {}

---@class util.mdterm.Opts
---@field follow? boolean
---@field theme? string
---@field save? boolean

---@param opts? util.mdterm.Opts
---@return string? file
---@return string? err
function M.resolve_file(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()

  if vim.bo[buf].buftype ~= "" then
    return nil, "Not a normal file buffer"
  end

  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    return nil, "Buffer has no file path"
  end

  if opts.save ~= false and vim.bo[buf].modified then
    local ok, err = pcall(vim.cmd.write, { mods = { silent = true } })
    if not ok then
      return nil, "Failed to save buffer: " .. (err or "unknown error")
    end
  end

  return vim.fn.fnamemodify(file, ":p"), nil
end

---@param file string
---@param opts? util.mdterm.Opts
---@return string[]
function M.build_cmd(file, opts)
  opts = opts or {}
  local cmd = { "mdterm" }

  if opts.follow ~= false then
    cmd[#cmd + 1] = "--follow"
  end

  cmd[#cmd + 1] = "--theme"
  cmd[#cmd + 1] = opts.theme or "light"
  cmd[#cmd + 1] = file

  local extra = vim.g.mdterm_args
  if type(extra) == "table" then
    vim.list_extend(cmd, extra)
  end

  return cmd
end

---@param file string
---@return snacks.terminal.Opts
function M.term_opts(file)
  return {
    cwd = vim.fn.fnamemodify(file, ":h"),
    win = {
      title = " mdterm │ " .. vim.fn.fnamemodify(file, ":t"),
    },
  }
end

---@param opts? util.mdterm.Opts
---@param toggle boolean
---@return snacks.win?
function M._launch(opts, toggle)
  if vim.fn.executable("mdterm") ~= 1 then
    Util.warn("mdterm is not installed (`cargo install mdterm`)", { title = "mdterm" })
    return
  end

  local file, err = M.resolve_file(opts)
  if not file then
    Util.warn(err or "Cannot open mdterm", { title = "mdterm" })
    return
  end

  local cmd = M.build_cmd(file, opts)
  local term_opts = M.term_opts(file)

  if toggle then
    return Snacks.terminal.toggle(cmd, term_opts)
  end
  return Snacks.terminal(cmd, term_opts)
end

---@param opts? util.mdterm.Opts
---@return snacks.win?
function M.open(opts)
  return M._launch(opts, false)
end

---@param opts? util.mdterm.Opts
---@return snacks.win?
function M.toggle(opts)
  return M._launch(opts, true)
end

return M
