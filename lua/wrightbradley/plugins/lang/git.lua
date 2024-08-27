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
    "polarmutex/git-worktree.nvim",
    -- version = "^2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      local Hooks = require("git-worktree.hooks")
      require("telescope").load_extension("git_worktree")
      Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
        local relativePath = path:gsub("^" .. os.getenv("HOME"), "")
        vim.notify("Switched to ~" .. relativePath)

        -- Update the current buffer
        -- Hooks.builtins.update_current_buffer_on_switch(path, prev_path)

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end)
    end,
    keys = {
      {
        "<leader>gws",
        function()
          require("telescope").extensions.git_worktree.git_worktree()
        end,
        desc = "Git Worktree switch",
      },
      {
        "<leader>gwc",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "Create new Git Worktree",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
  },
}
