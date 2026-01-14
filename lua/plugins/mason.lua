---@file Mason plugin configuration
--- This file configures Mason for managing tools (formatters, linters, DAP adapters).
--- LSP servers are managed by mason-lspconfig in lsp.lua via automatic_installation.

return {
  -- cmdline tools, formatters, linters, and DAP adapters
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        -- Linters and formatters
        "ansible-lint",
        "cmakelang",
        "cmakelint",
        "gofumpt",
        "goimports",
        "golangci-lint",
        "hadolint",
        "markdown-toc",
        "markdownlint-cli2",
        "prettier",
        "shellcheck",
        "shfmt",
        "stylua",
        "tflint",
        "yamlfmt",
        "yamllint",

        -- DAP adapters
        "delve",
        "js-debug-adapter",
        -- "codelldb",
        -- "java-debug-adapter",
        -- "java-test",
        -- "kotlin-debug-adapter",

        -- Utilities
        "cueimports",
        "jq",

        -- LSP servers are installed via mason-lspconfig in lsp.lua
        -- The list below is kept for reference but can be removed:
        -- "ansible-language-server",
        -- "bash-language-server",
        -- "clangd",
        -- "cuelsp",
        -- "cypher-language-server",
        -- "docker-compose-language-service",
        -- "dockerfile-language-server",
        -- "eslint-lsp",
        -- "gopls",
        -- "helm-ls",
        -- "jq-lsp",
        -- "json-lsp",
        -- "lua-language-server",
        -- "marksman",
        -- "neocmakelsp",
        -- "pyright",
        -- "ruff",
        -- "tailwindcss-language-server",
        -- "taplo",
        -- "terraform-ls",
        -- "vale-ls",
        -- "vtsls",
        -- "vue-language-server",
        -- "yaml-language-server",
        -- "zls",
      },
    },
    --- Configures Mason with the specified options.
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- Trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
