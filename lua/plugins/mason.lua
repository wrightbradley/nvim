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
      -- Set to true to automatically uninstall tools not in ensure_installed
      -- Warning: Only uninstalls non-LSP tools (LSPs managed by mason-lspconfig)
      auto_uninstall = true,
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
        -- Install missing packages
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end

        -- Auto-uninstall packages not in ensure_installed (if enabled)
        if opts.auto_uninstall then
          local installed = mr.get_installed_packages()
          local ensure_installed_set = {}
          for _, tool in ipairs(opts.ensure_installed) do
            ensure_installed_set[tool] = true
          end

          -- Also get LSP servers from mason-lspconfig to avoid uninstalling them
          local lsp_servers = {}
          local ok, lspconfig_opts = pcall(require("lazy.core.config").plugins["nvim-lspconfig"].opts)
          if ok and lspconfig_opts and lspconfig_opts.servers then
            for _, server in ipairs(lspconfig_opts.servers) do
              lsp_servers[server] = true
            end
          end

          for _, pkg in ipairs(installed) do
            local pkg_type = pkg.spec.categories[1] or ""
            -- Only auto-uninstall if:
            -- 1. Not in ensure_installed list
            -- 2. Not an LSP server (those are managed by mason-lspconfig)
            -- 3. Not in the LSP servers list from lsp.lua
            if not ensure_installed_set[pkg.name] and pkg_type ~= "LSP" and not lsp_servers[pkg.name] then
              vim.notify(
                "Mason: Auto-uninstalling " .. pkg.name .. " (not in ensure_installed)",
                vim.log.levels.INFO
              )
              pkg:uninstall()
            end
          end
        end
      end)
    end,
  },
}
