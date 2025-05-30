return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jqls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "jq-lsp",
        "jq",
      })
    end,
  },
}
