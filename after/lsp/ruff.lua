---@type vim.lsp.Config
return {
  -- Disable hover in favor of basedpyright (provides better type information)
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
}
