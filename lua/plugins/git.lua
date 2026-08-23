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
      -- Review write-loop: start -> comment on lines -> submit
      { "<leader>gOs", "<cmd>Octo review start<cr>", desc = "Start PR Review (Octo)" },
      { "<leader>gOz", "<cmd>Octo review submit<cr>", desc = "Submit PR Review (Octo)" },
      { "<leader>gOm", "<cmd>Octo review commits<cr>", desc = "Review Commits (Octo)" },
      { "<leader>gOd", "<cmd>Octo pr diff<cr>", desc = "PR Diff (Octo)" },
    },
  },
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
