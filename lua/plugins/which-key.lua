return {
  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "mrjones2014/legendary.nvim",
        -- since legendary.nvim handles all your keymaps/commands,
        -- its recommended to load legendary.nvim before other plugins
        -- sqlite is only needed if you want to use frecency sorting
        -- dependencies = { 'kkharji/sqlite.lua' }
        opts = {
          extensions = {
            lazy_nvim = {
              -- Automatically register keymaps that are defined on lazy.nvim plugin specs
              -- using the `keys = {}` property.
              auto_register = true,
            },
            which_key = {
              -- Automatically add which-key tables to legendary
              -- see ./doc/WHICH_KEY.md for more details
              auto_register = true,
            },
            -- load keymaps and commands from nvim-tree.lua
            nvim_tree = true,
            -- load commands from smart-splits.nvim
            -- and create keymaps, see :h legendary-extensions-smart-splits.nvim
            smart_splits = {
              directions = { "h", "j", "k", "l" },
              mods = {
                move = "<C>",
                resize = "<M>",
              },
            },
            -- load commands from op.nvim
            op_nvim = true,
            -- load keymaps from diffview.nvim
            diffview = true,
          },
        },
      },
    },
    opts_extend = { "spec" },
    opts = {
      -- preset = "helix",
      defaults = {},
      spec = {
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>a", group = "ai" },
          { "<leader>aa", group = "avante" },
          { "<leader>ac", group = "copilot" },
          { "<leader>ag", group = "gpt" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>gi", group = "github issues" },
          { "<leader>gp", group = "github prs" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          -- better descriptions
          { "gx", desc = "Open with system app" },
          { "<BS>", desc = "Decrement Selection", mode = "x" },
          { "<c-space>", desc = "Increment Selection", mode = { "x", "n" } },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      if not vim.tbl_isempty(opts.defaults) then
        Util.warn("which-key: opts.defaults is deprecated. Please use opts.spec instead.")
        wk.register(opts.defaults)
      end
    end,
  },
}
