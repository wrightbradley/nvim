---@type vim.lsp.Config
return {
  -- Pyright settings optimized for hover/type information only
  -- ty and ruff handle all diagnostics
  settings = {
    python = {
      analysis = {
        -- Completely disable type checking - ty handles all diagnostics
        typeCheckingMode = "off",
        -- Enable type stubs for accurate hover information
        useLibraryCodeForTypes = true,
        -- Auto-search paths for better type resolution
        autoSearchPaths = true,
        -- Disable diagnostics completely
        diagnosticMode = "none",
      },
    },
  },
}
