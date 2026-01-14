---@type vim.lsp.Config
return {
  -- Pyright settings optimized for hover and inlay hints
  -- ty handles diagnostics, navigation, completion, etc.
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
        -- Enable inlay hints for better type information
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
          parameterTypes = true,
        },
      },
    },
  },
}
