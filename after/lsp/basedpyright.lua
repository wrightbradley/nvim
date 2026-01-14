---@type vim.lsp.Config
return {
  -- basedpyright settings optimized for hover and inlay hints
  -- ty handles diagnostics, navigation, completion, etc.
  settings = {
    basedpyright = {
      analysis = {
        -- Completely disable type checking - ty handles all diagnostics
        typeCheckingMode = "off",
        -- Disable diagnostics completely
        diagnosticMode = "none",
        -- Enable inlay hints for better type information (basedpyright supports these!)
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          parameterTypes = true,
        },
      },
    },
    python = {
      analysis = {
        -- Enable type stubs for accurate hover information
        useLibraryCodeForTypes = true,
        -- Auto-search paths for better type resolution
        autoSearchPaths = true,
      },
    },
  },
}
