---@type vim.lsp.Config
return {
  -- Disable hover in favor of ty (Astral's type checker provides better hover)
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
}
