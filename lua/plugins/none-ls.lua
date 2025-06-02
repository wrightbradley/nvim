return {
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      -- hadolint/docker
      table.insert(opts.sources, nls.builtins.diagnostics.hadolint)
      -- prettier
      table.insert(opts.sources, nls.builtins.formatting.prettier)
      -- terraform
      table.insert(opts.sources, nls.builtins.formatting.packer)
      table.insert(opts.sources, nls.builtins.formatting.terraform_fmt)
      table.insert(opts.sources, nls.builtins.formatting.terraform_validate)
      -- golang
      table.insert(opts.sources, nls.builtins.code_actions.gomodifytags)
      table.insert(opts.sources, nls.builtins.code_actions.impl)
      table.insert(opts.sources, nls.builtins.code_actions.goimports)
      table.insert(opts.sources, nls.builtins.code_actions.gofumpt)
      -- markdown
      table.insert(opts.sources, nls.builtins.diagnostics.markdownlint_cli2)
    end,
  },
}
