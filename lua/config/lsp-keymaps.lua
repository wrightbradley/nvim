---@file LSP key mappings configuration
--- This file configures key mappings specifically for LSP-related actions in Neovim.
--- It integrates with the LSP client to provide shortcuts for features like go-to
--- definition, references, and code actions.

local M = {}

---@type LazyKeysLspSpec[]|nil
M._keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string|string[], cond?:fun():boolean}
---@alias LazyKeysLsp LazyKeys|{has?:string|string[], cond?:fun():boolean}

--- Retrieves the LSP key mappings.
---@return LazyKeysLspSpec[] List of LSP key mappings.
function M.get()
  if M._keys then
    return M._keys
  end
    -- stylua: ignore
    M._keys =  {
      { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
      -- Using Snacks picker for definition
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
      -- Using Snacks picker for references
      { "gr", function() Snacks.picker.lsp_references() end, desc = "References", nowait = true },
      -- Using Snacks picker for implementations
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      -- Using Snacks picker for type definitions
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
      { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
      { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
      { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
      { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
      { "<leader>cA", Util.lsp.action.source, desc = "Source Action", has = "codeAction" },
      -- Add LSP symbols search with Snacks
      { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = Util.config.kind_filter }) end, desc = "LSP Symbols", has = "documentSymbol" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = Util.config.kind_filter }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
        desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
        desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
      { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
        desc = "Next Reference", cond = function() return Snacks.words.is_enabled() end },
      { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
        desc = "Prev Reference", cond = function() return Snacks.words.is_enabled() end },
    }

  return M._keys
end

--- Checks if a buffer has a specific LSP method.
---@param buffer number Buffer number.
---@param method string|string[] LSP method(s) to check.
---@return boolean True if the buffer has the method, false otherwise.
function M.has(buffer, method)
  if type(method) == "table" then
    for _, m in ipairs(method) do
      if M.has(buffer, m) then
        return true
      end
    end
    return false
  end
  method = method:find("/") and method or "textDocument/" .. method
  local clients = Util.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

--- Resolves LSP key mappings for a buffer.
---@param buffer number Buffer number.
---@return LazyKeysLsp[] List of resolved LSP key mappings.
function M.resolve(buffer)
  local Keys = require("lazy.core.handler.keys")
  if not Keys.resolve then
    return {}
  end
  local spec = vim.tbl_extend("force", {}, M.get())
  local opts = Util.opts("nvim-lspconfig")
  local clients = Util.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

--- Attaches LSP key mappings to a buffer.
---@param _ any Unused parameter.
---@param buffer number Buffer number.
function M.on_attach(_, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = M.resolve(buffer)

  for _, keys in pairs(keymaps) do
    local has = not keys.has or M.has(buffer, keys.has)
    local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

    if has and cond then
      local opts = Keys.opts(keys)
      opts.cond = nil
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

return M
