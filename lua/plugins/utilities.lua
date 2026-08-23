return {
  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "aserowy/tmux.nvim",
    -- Navigation/resize functions are called from keymaps.lua; the plugin
    -- itself only needs to be loadable when those keys fire.
    lazy = true,
    config = function()
      require("tmux").setup({
        navigation = {
          -- We map <C-hjkl> ourselves in keymaps.lua (tmux.nvim's defaults
          -- would clash with them), so only enable behavior options here.
          enable_default_keybindings = false,
          -- Unzoom a zoomed tmux pane when navigating beyond the nvim border
          persist_zoom = true,
        },
        resize = { enable_default_keybindings = false },
      })
    end,
  },
  {
    "deponian/nvim-base64",
    keys = {
      -- Decode/encode selected sequence from/to base64
      -- (mnemonic: [b]ase64)
      { "<Leader>b", "<Plug>(FromBase64)", mode = "x" },
      { "<Leader>B", "<Plug>(ToBase64)", mode = "x" },
    },
    config = function()
      require("nvim-base64").setup()
    end,
  },
  {
    "laytan/cloak.nvim",
    config = function()
      require("cloak").setup({
        enabled = true,
        cloak_character = "*",
        -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
        highlight_group = "Comment",
        -- Applies the length of the replacement characters for all matched
        -- patterns, defaults to the length of the matched pattern.
        cloak_length = nil, -- Provide a number if you want to hide the true length of the value.
        -- Whether it should try every pattern to find the best fit or stop after the first.
        try_all_patterns = true,
        patterns = {
          {
            -- Match any file starting with '.env'.
            -- This can be a table to match multiple file patterns.
            file_pattern = { ".env*" },
            -- Match an equals sign and any character after it.
            -- This can also be a table of patterns to cloak,
            -- example: cloak_pattern = { ':.+', '-.+' } for yaml files.
            cloak_pattern = "=.+",
            -- A function, table or string to generate the replacement.
            -- The actual replacement will contain the 'cloak_character'
            -- where it doesn't cover the original text.
            -- If left emtpy the legacy behavior of keeping the first character is retained.
            replace = nil,
          },
        },
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "Util", words = { "Util" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "Util" } },
      },
    },
  },
  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    init = function()
      -- tmux-resurrect reopens nvim panes by re-running bare `nvim` in the
      -- saved working directory. This makes that launch automatically restore
      -- this project's session (buffers, layout) instead of opening empty.
      -- Skipped when nvim is opened with file arguments.
      vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function(args)
          if vim.fn.argc(-1) == 0 and #args.file == 0 then
            require("persistence").load()
          end
        end,
      })
    end,
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
      -- Neovim 0.12 :restart - restarts Nvim in place; persistence restores the session
      { "<leader>qR", "<cmd>restart<cr>", desc = "Restart Nvim" },
    },
  },
  -- Kubernetes YAML schema support - lazy loads only for YAML files
  {
    "imroc/kubeschema.nvim",
    ft = { "yaml", "yml" },
    opts = {},
  },
  {
    "hat0uma/csvview.nvim",
    config = function()
      require("csvview").setup()
    end,
  },
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },
}
