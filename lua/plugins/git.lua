return {
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd("highlight default link gitblame SpecialComment")
      vim.g.gitblame_enabled = 0
    end,
  },
  {
    "dlvhdr/gh-blame.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>ghb", "<cmd>GhBlameCurrentLine<cr>", desc = "GitHub Blame Current Line" },
    },
  },
  -- NOTE: Octo.nvim removed in favor of Snacks.gh (LazyVim v15.13.0)
  -- Snacks.gh provides lightweight GitHub integration via picker
  -- For full GitHub editing capabilities, Octo can be re-enabled if needed
  -- {
  --   "polarmutex/git-worktree.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  --   config = function()
  --     local Hooks = require("git-worktree.hooks")
  --     require("telescope").load_extension("git_worktree")
  --     Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
  --       local relativePath = path:gsub("^" .. os.getenv("HOME"), "")
  --       vim.notify("Switched to ~" .. relativePath)
  --
  --       -- Update the current buffer
  --       Hooks.builtins.update_current_buffer_on_switch(path, prev_path)
  --
  --       for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  --         if vim.api.nvim_buf_is_loaded(buf) then
  --           vim.api.nvim_buf_delete(buf, { force = true })
  --         end
  --       end
  --     end)
  --   end,
  --   keys = {
  --     {
  --       "<leader>gws",
  --       function()
  --         require("telescope").extensions.git_worktree.git_worktree()
  --       end,
  --       desc = "Git Worktree switch",
  --     },
  --     {
  --       "<leader>gwc",
  --       function()
  --         require("telescope").extensions.git_worktree.create_git_worktree()
  --       end,
  --       desc = "Create new Git Worktree",
  --     },
  --   },
  -- },
  {
    "Juksuu/worktrees.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("worktrees").setup()
    end,
    keys = {
      {
        "<leader>gws",
        function()
          Snacks.picker.worktrees()
        end,
        desc = "Git Worktree switch",
      },
      {
        "<leader>gwn",
        function()
          Snacks.picker.worktrees_new()
        end,
        desc = "Create new Git Worktree",
      },
    },
  },
  {
    "dlvhdr/gh-addressed.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "folke/trouble.nvim",
    },
    cmd = "GhReviewComments",
    keys = {
      { "<leader>gc", "<cmd>GhReviewComments<cr>", desc = "GitHub Review Comments" },
    },
  },
  -- { "wakatime/vim-wakatime", lazy = false },
}
