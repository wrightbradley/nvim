---@file Project root directory detection utilities for Neovim
--- This module provides functionality to detect and manage project root directories.
--- It uses LSP, file patterns, and other heuristics to determine the root of a project.
--- The module is used throughout the configuration for project-aware functionality.

---@class util.root
---@overload fun(): string Return the root directory for the current buffer
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.get(...)
  end,
})

---@class LazyRoot Information about a detected root
---@field paths string[] List of root directory paths
---@field spec LazyRootSpec Specification that matched this root

---@alias LazyRootFn fun(buf: number): (string|string[]) Function that returns root(s) for a buffer

---@alias LazyRootSpec string|string[]|LazyRootFn Specification for root detection

---@type LazyRootSpec[] Root detection specifications in order of priority
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

M.detectors = {}

--- Returns the current working directory.
---@return string[] The current working directory as a list.
function M.detectors.cwd()
  return { vim.uv.cwd() }
end

--- Detects root directories using LSP.
---@param buf number The buffer number.
---@return string[] List of root directories detected by LSP.
function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end
  local roots = {} ---@type string[]
  local clients = Util.lsp.get_clients({ bufnr = buf })
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
  end, clients)
  for _, client in pairs(clients) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end
  return vim.tbl_filter(function(path)
    path = Util.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

--- Detects root directories using file patterns.
---@param patterns string[]|string The patterns to match.
---@param buf number The buffer number.
---@return string[] List of root directories matching the patterns.
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = M.bufpath(buf) or vim.uv.cwd()
  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then
        return true
      end
      if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]
  return pattern and { vim.fs.dirname(pattern) } or {}
end

--- Gets the real path of a buffer.
---@param buf number The buffer number.
---@return string|nil The real path of the buffer or nil if not found.
function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

--- Gets the real path of the current working directory.
---@return string The real path of the current working directory.
function M.cwd()
  return M.realpath(vim.uv.cwd()) or ""
end

--- Resolves the real path of a given path.
---@param path string The path to resolve.
---@return string|nil The resolved real path or nil if not found.
function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.uv.fs_realpath(path) or path
  return Util.norm(path)
end

--- Resolves a root detection specification to a function.
---@param spec LazyRootSpec The root detection specification.
---@return LazyRootFn The resolved function for root detection.
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

--- Detects root directories based on specified options.
---@param opts? { buf?: number, spec?: LazyRootSpec[], all?: boolean } Optional detection options.
---@return LazyRoot[] List of detected root directories.
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {} ---@type LazyRoot[]
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then
        break
      end
    end
  end
  return ret
end

--- Displays information about detected root directories.
---@return string The first detected root directory or the current working directory.
function M.info()
  local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec

  local roots = M.detect({ all = true })
  local lines = {} ---@type string[]
  local first = true
  for _, root in ipairs(roots) do
    for _, path in ipairs(root.paths) do
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        type(root.spec) == "table" and table.concat(root.spec, ", ") or root.spec
      )
      first = false
    end
  end
  lines[#lines + 1] = "```lua"
  lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
  lines[#lines + 1] = "```"
  Util.info(lines, { title = "Util Roots" })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

---@type table<number, string>
M.cache = {}

--- Sets up autocommands for root detection.
function M.setup()
  vim.api.nvim_create_user_command("LazyRoot", function()
    Util.root.info()
  end, { desc = "Util roots for the current buffer" })

  -- FIX: doesn't properly clear cache in neo-tree `set_root` (which should happen presumably on `DirChanged`),
  -- probably because the event is triggered in the neo-tree buffer, therefore add `BufEnter`
  -- Maybe this is too frequent on `BufEnter` and something else should be done instead??
  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("root_cache", { clear = true }),
    callback = function(event)
      M.cache[event.buf] = nil
    end,
  })
end

--- Returns the root directory based on various heuristics.
---@param opts? {normalize?:boolean, buf?:number} Optional options for root detection.
---@return string The detected root directory.
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]
  if not ret then
    local roots = M.detect({ all = false, buf = buf })
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    M.cache[buf] = ret
  end
  if opts and opts.normalize then
    return ret
  end
  return Util.is_win() and ret:gsub("/", "\\") or ret
end

--- Gets the root directory of the current Git repository.
---@return string The Git root directory or the current root directory.
function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
  return ret
end

--- Returns a pretty-printed path.
---@param opts? {hl_last?: string} Optional options for path formatting.
---@return string The formatted path.
function M.pretty_path(opts)
  return ""
end

return M
