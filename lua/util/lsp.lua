---@file LSP-related utility functions for Neovim
--- This module provides utility functions for managing Language Server Protocol (LSP)
--- clients, handling dynamic capabilities, and configuring LSP-related settings in Neovim.

---@class util.lsp
local M = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: lsp.Client):boolean}

--- Retrieves active LSP clients based on filters.
---@param opts? lsp.Client.filter Optional filters for retrieving clients.
---@return vim.lsp.Client[] List of active LSP clients.
function M.get_clients(opts)
  local ret = {} ---@type vim.lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ---@param client vim.lsp.Client
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

--- Sets up an autocmd for LSP attachment.
---@param on_attach fun(client:vim.lsp.Client, buffer) Callback function for LSP attachment.
---@param name? string Optional name of the LSP client.
function M.on_attach(on_attach, name)
  return vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (not name or client.name == name) then
        return on_attach(client, buffer)
      end
    end,
  })
end

---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
M._supports_method = {}

--- Initializes LSP-related handlers and capabilities.
function M.setup()
  local register_capability = vim.lsp.handlers["client/registerCapability"]
  vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
    ---@diagnostic disable-next-line: no-unknown
    local ret = register_capability(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client then
      for buffer in pairs(client.attached_buffers) do
        vim.api.nvim_exec_autocmds("User", {
          pattern = "LspDynamicCapability",
          data = { client_id = client.id, buffer = buffer },
        })
      end
    end
    return ret
  end
  M.on_attach(M._check_methods)
  M.on_dynamic_capability(M._check_methods)
end

--- Checks and triggers methods supported by LSP clients.
---@param client vim.lsp.Client The LSP client.
---@param buffer number The buffer number.
function M._check_methods(client, buffer)
  -- Don't trigger on invalid buffers
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end
  -- Don't trigger on non-listed buffers
  if not vim.bo[buffer].buflisted then
    return
  end
  -- Don't trigger on nofile buffers
  if vim.bo[buffer].buftype == "nofile" then
    return
  end
  for method, clients in pairs(M._supports_method) do
    clients[client] = clients[client] or {}
    if not clients[client][buffer] then
      if client.supports_method and client.supports_method(method, { bufnr = buffer }) then
        clients[client][buffer] = true
        vim.api.nvim_exec_autocmds("User", {
          pattern = "LspSupportsMethod",
          data = { client_id = client.id, buffer = buffer, method = method },
        })
      end
    end
  end
end

--- Registers a callback for dynamic LSP capabilities.
---@param fn fun(client:vim.lsp.Client, buffer):boolean? The callback function.
---@param opts? {group?: integer} Optional group for the autocmd.
function M.on_dynamic_capability(fn, opts)
  return vim.api.nvim_create_autocmd("User", {
    pattern = "LspDynamicCapability",
    group = opts and opts.group or nil,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.data.buffer ---@type number
      if client then
        return fn(client, buffer)
      end
    end,
  })
end

--- Registers a callback for when a method is supported by an LSP client.
---@param method string The method to check for support.
---@param fn fun(client:vim.lsp.Client, buffer) The callback function.
function M.on_supports_method(method, fn)
  M._supports_method[method] = M._supports_method[method] or setmetatable({}, { __mode = "k" })
  return vim.api.nvim_create_autocmd("User", {
    pattern = "LspSupportsMethod",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.data.buffer ---@type number
      if client and method == args.data.method then
        return fn(client, buffer)
      end
    end,
  })
end

--- Retrieves the configuration for a specific LSP server.
---@param server string The name of the LSP server.
---@return _.lspconfig.options The configuration options for the server.
function M.get_config(server)
  local configs = require("lspconfig.configs")
  return rawget(configs, server)
end

--- Retrieves the raw configuration for an LSP server.
---@param server string The name of the LSP server.
---@return {default_config:lspconfig.Config} The raw configuration for the server.
function M.get_raw_config(server)
  local ok, ret = pcall(require, "lspconfig.configs." .. server)
  if ok then
    return ret
  end
  return require("lspconfig.server_configurations." .. server)
end

--- Checks if an LSP server is enabled.
---@param server string The name of the LSP server.
---@return boolean True if the server is enabled, false otherwise.
function M.is_enabled(server)
  local c = M.get_config(server)
  return c and c.enabled ~= false
end

--- Disables an LSP server based on a condition.
---@param server string The name of the LSP server.
---@param cond fun(root_dir, config): boolean The condition function.
function M.disable(server, cond)
  local util = require("lspconfig.util")
  local def = M.get_config(server)
  ---@diagnostic disable-next-line: undefined-field
  def.document_config.on_new_config = util.add_hook_before(def.document_config.on_new_config, function(config, root_dir)
    if cond(root_dir, config) then
      config.enabled = false
    end
  end)
end

--- Configures a formatter for LSP.
---@param opts? LazyFormatter| {filter?: (string|lsp.Client.filter)}
---@return LazyFormatter The configured formatter.
function M.formatter(opts)
  opts = opts or {}
  local filter = opts.filter or {}
  filter = type(filter) == "string" and { name = filter } or filter
  ---@cast filter lsp.Client.filter
  ---@type LazyFormatter
  local ret = {
    name = "LSP",
    primary = true,
    priority = 1,
    format = function(buf)
      M.format(Util.merge({}, filter, { bufnr = buf }))
    end,
    sources = function(buf)
      local clients = M.get_clients(Util.merge({}, filter, { bufnr = buf }))
      ---@param client vim.lsp.Client
      local ret = vim.tbl_filter(function(client)
        return client.supports_method("textDocument/formatting")
          or client.supports_method("textDocument/rangeFormatting")
      end, clients)
      ---@param client vim.lsp.Client
      return vim.tbl_map(function(client)
        return client.name
      end, ret)
    end,
  }
  return Util.merge(ret, opts) --[[@as LazyFormatter]]
end

--- Formats the current buffer using LSP.
---@param opts? lsp.Client.format Optional formatting options.
function M.format(opts)
  opts = vim.tbl_deep_extend(
    "force",
    {},
    opts or {},
    Util.opts("nvim-lspconfig").format or {},
    Util.opts("conform.nvim").format or {}
  )
  local ok, conform = pcall(require, "conform")
  -- Use conform for formatting with LSP when available,
  -- since it has better format diffing
  if ok then
    opts.formatters = {}
    conform.format(opts)
  else
    vim.lsp.buf.format(opts)
  end
end

M.action = setmetatable({}, {
  __index = function(_, action)
    return function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { action },
          diagnostics = {},
        },
      })
    end
  end,
})

---@class LspCommand: lsp.ExecuteCommandParams
---@field open? boolean
---@field handler? lsp.Handler

--- Executes an LSP command.
---@param opts LspCommand The command options.
function M.execute(opts)
  local params = {
    command = opts.command,
    arguments = opts.arguments,
  }
  if opts.open then
    require("trouble").open({
      mode = "lsp_command",
      params = params,
    })
  else
    return vim.lsp.buf_request(0, "workspace/executeCommand", params, opts.handler)
  end
end

return M
