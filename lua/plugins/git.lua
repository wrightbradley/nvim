return {
  {
    "dlvhdr/gh-blame.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>ghb", "<cmd>GhBlameCurrentLine<cr>", desc = "GitHub Blame Current Line" },
    },
  },
  -- NOTE: Octo.nvim re-enabled for the PR review write-loop (comments,
  -- reviews, approvals). Snacks.picker still handles lightweight browsing
  -- (<leader>gp / <leader>gi); Octo handles stateful GitHub editing.
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "folke/snacks.nvim",
    },
    opts = {
      picker = "snacks",
    },
    keys = {
      { "<leader>gO", "<cmd>Octo pr list<cr>", desc = "GitHub PRs (Octo)" },
    },
  },
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
  -- Worktree switching lives in lua/plugins/worktrees.lua (custom snacks
  -- picker over `git worktree list`, with persistence.nvim auto-restore).
  {
    "dlvhdr/gh-addressed.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "folke/trouble.nvim",
    },
    cmd = "GhReviewComments",
    keys = {
      -- NOTE: <leader>gc is Git Commits (snacks.lua); use ghc for GitHub comments
      { "<leader>ghc", "<cmd>GhReviewComments<cr>", desc = "GitHub Review Comments" },
    },
  },
  -- { "wakatime/vim-wakatime", lazy = false },
}
