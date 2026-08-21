---@file Mason plugin configuration
--- This file configures Mason for managing tools (formatters, linters, DAP adapters).
--- LSP servers are managed by mason-lspconfig in lsp.lua via automatic_installation.

--- Mise Python builds omit stdlib venv; Mason PyPI packages need a Python with venv.
--- NOTE: These are macOS paths (Homebrew on Apple Silicon / Intel + system Python).
local function ensure_mason_python_path()
  if vim.g.mason_python_path_prepared then
    return
  end

  for _, dir in ipairs({ "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin" }) do
    local py = dir .. "/python3"
    if vim.fn.executable(py) == 1 then
      local result = vim.system({ py, "-c", "import venv" }, { text = true }):wait()
      if result.code == 0 then
        vim.env.PATH = dir .. ":" .. (vim.env.PATH or "")
        vim.g.mason_python_path_prepared = true
        return
      end
    end
  end
end

return {
  -- cmdline tools, formatters, linters, and DAP adapters
  {
    "mason-org/mason.nvim",
    event = "LazyFile",
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
      ensure_mason_python_path()
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
          local ok, lsp_plugin = pcall(function()
            return require("lazy.core.config").plugins["nvim-lspconfig"]
          end)
          if ok and lsp_plugin then
            local lsp_opts = type(lsp_plugin.opts) == "function" and lsp_plugin.opts() or lsp_plugin.opts
            if lsp_opts and lsp_opts.servers then
              for _, server in ipairs(lsp_opts.servers) do
                lsp_servers[server] = true
              end
            end
          end

          for _, pkg in ipairs(installed) do
            local pkg_categories = pkg.spec.categories or {}
            local is_lsp = vim.tbl_contains(pkg_categories, "LSP")

            -- Only auto-uninstall if:
            -- 1. Not in ensure_installed list
            -- 2. Not an LSP server (those are managed by mason-lspconfig)
            -- 3. Not in the LSP servers list from lsp.lua
            if not ensure_installed_set[pkg.name] and not is_lsp and not lsp_servers[pkg.name] then
              vim.notify("Mason: Auto-uninstalling " .. pkg.name .. " (not in ensure_installed)", vim.log.levels.INFO)
              pkg:uninstall()
            end
          end
        end
      end)
    end,
  },
}
