---@file Python language support configuration
--- This file configures Python-related plugins and tools for Neovim, including LSP,
--- Treesitter, and DAP. It sets up Python language servers and ensures necessary tools
--- are installed for Python development.

-- Native LSP configuration for Neovim 0.11+

-- Configure ruff
vim.lsp.config("ruff", {
  cmd_env = { RUFF_TRACE = "messages" },
  init_options = {
    settings = {
      logLevel = "error",
    },
  },
})

-- Configure ty
vim.lsp.config("ty", {
  cmd = { "uvx", "ty", "server" },
  filetypes = { "python" },
  root_dir = vim.fs.dirname(vim.fs.find({ "ty.toml", ".git", "pyproject.toml" }, { upward = true })[1])
    or vim.fn.getcwd(),
  capabilities = {
    textDocument = {
      publishDiagnostics = {},
    },
  },
  on_attach = function(client, bufnr)
    -- Disable everything else
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.definitionProvider = false
    client.server_capabilities.referencesProvider = false
    client.server_capabilities.completionProvider = false
    client.server_capabilities.renameProvider = false
    client.server_capabilities.documentSymbolProvider = false
  end,
})

-- Configure pyright
vim.lsp.config("pyright", {})

-- Enable the language servers
vim.lsp.enable("ruff")
vim.lsp.enable("ty")
vim.lsp.enable("pyright")

-- Set up on_attach callbacks
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ruff" then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- Add keymaps
vim.keymap.set("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "source.organizeImports" },
      diagnostics = {}, -- Add empty diagnostics array to satisfy the type requirement
    },
  })
end, { desc = "Organize Imports" })

return {

  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          -- Here you can specify the settings for the adapter, i.e.
          -- runner = "pytest",
          -- python = ".venv/bin/python",
        },
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      keys = {
        {
          "<leader>dPt",
          function()
            require("dap-python").test_method()
          end,
          desc = "Debug Method",
          ft = "python",
        },
        {
          "<leader>dPc",
          function()
            require("dap-python").test_class()
          end,
          desc = "Debug Class",
          ft = "python",
        },
      },
      config = function()
        if vim.fn.has("win32") == 1 then
          require("dap-python").setup(Util.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
        else
          require("dap-python").setup(Util.get_pkg_path("debugpy", "/venv/bin/python"))
        end
      end,
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp", -- Use this branch for the new version
    cmd = "VenvSelect",
    enabled = function()
      return Util.has("telescope.nvim")
    end,
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    --  Call config for python files and load the cached venv automatically
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      opts.auto_brackets = opts.auto_brackets or {}
      table.insert(opts.auto_brackets, "python")
    end,
  },

  -- Don't mess up DAP adapters provided by nvim-dap-python
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        python = function() end,
      },
    },
  },
}
