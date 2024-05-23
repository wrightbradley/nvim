return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "yaml" })
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- for ansiblels validation
      vim.list_extend(opts.ensure_installed, { "ansible-lint", "ansible-language-server" })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        ansible = { "ansible-lint" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ansible = { "yamlfmt" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ansiblels = {},
      },
    },
  },
  {
    "mfussenegger/nvim-ansible",
    ft = {},
    keys = {
      {
        "<leader>ta",
        function()
          require("ansible").run()
        end,
        desc = "Ansible Run Playbook/Role",
        silent = true,
      },
    },
  },
}
