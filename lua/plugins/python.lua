---@file Python language support configuration
--- This file configures Python-related plugins and tools for Neovim, including LSP,
--- Treesitter, and DAP. It sets up Python language servers and ensures necessary tools
--- are installed for Python development.
local py_ft = { "python", "ipynb", "jupyter", "quarto" }
-- local jupyter_ft = { "ipynb", "jupyter", "quarto" }
-- local mojo_ft = { "mojo", "🔥" }

-- Add keymaps
vim.keymap.set("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "source.organizeImports" },
      diagnostics = {}, -- Add empty diagnostics array to satisfy the type requirement
    },
  })
end, { desc = "Organize Imports" })

-- Enable autocompletion for Python LSP servers
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
  pattern = "*.py",
})

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

  -- {
  --   "mfussenegger/nvim-dap",
  --   optional = true,
  --   dependencies = {
  --     "mfussenegger/nvim-dap-python",
  --     keys = {
  --       {
  --         "<leader>dPt",
  --         function()
  --           require("dap-python").test_method()
  --         end,
  --         desc = "Debug Method",
  --         ft = "python",
  --       },
  --       {
  --         "<leader>dPc",
  --         function()
  --           require("dap-python").test_class()
  --         end,
  --         desc = "Debug Class",
  --         ft = "python",
  --       },
  --     },
  --     config = function()
  --       -- TODO: fix paths
  --       -- if vim.fn.has("win32") == 1 then
  --       --   require("dap-python").setup(Util.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
  --       -- else
  --       --   require("dap-python").setup(Util.get_pkg_path("debugpy", "/venv/bin/python"))
  --       -- end
  --     end,
  --   },
  -- },
  {
    "benomahony/uv.nvim",
    ft = py_ft,
    opts = {
      keymaps = {
        prefix = "<leader>cu", -- Main prefix for uv commands
        commands = true, -- Show uv commands menu (<leader>x)
        run_file = true, -- Run current file (<leader>xr)
        run_selection = true, -- Run selected code (<leader>xs)
        run_function = true, -- Run function (<leader>xf)
        venv = true, -- Environment management (<leader>xe)
        init = true, -- Initialize uv project (<leader>xi)
        add = true, -- Add a package (<leader>xa)
        remove = true, -- Remove a package (<leader>xd)
        sync = true, -- Sync packages (<leader>xc)
        sync_all = true, -- Sync all packages, extras and groups (<leader>xC)
      },
      picker_integration = true,
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = false,
        },
      },
      picker = {
        type = "snacks", -- Custom type name, just to indicate we override
        -- The function Snacks will call to pick
        fn = function(opts, on_choice)
          -- opts.items is the list of venvs discovered
          local items = {}
          for _, venv in ipairs(opts.items) do
            table.insert(items, {
              text = venv.name,
              path = venv.path,
            })
          end

          -- Use Snacks picker
          require("snacks").picker({
            prompt = "Select Python venv",
            items = items,
            format_item = function(item)
              return item.text
            end,
            on_select = function(item)
              on_choice(item.path) -- Send selected venv path back to venv-selector
            end,
          })
        end,
      },
    },
    --  Call config for python files and load the cached venv automatically
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
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
