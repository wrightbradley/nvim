return {
  -- Treesitter git support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" } },
  },

  {
    "nvim-cmp",
    dependencies = {
      { "petertriho/cmp-git", opts = {} },
    },
    ---@module 'cmp'
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "git" })
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd("highlight default link gitblame SpecialComment")
      vim.g.gitblame_enabled = 0
    end,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        suppress_missing_scope = {
          projects_v2 = true,
        },
      })
    end,
  },
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("git-worktree").setup()
      require("telescope").load_extension("git_worktree")
    end,
    keys = {
      { "<leader>gws", "<cmd>Telescope git_worktree git_worktrees<cr>", desc = "Switch git worktrees" },
      {
        "<leader>gwc",
        "<cmd>Telescope git_worktree create_git_worktree<cr>",
        desc = "Create and switch to new worktree",
      },
    },
  },
}
