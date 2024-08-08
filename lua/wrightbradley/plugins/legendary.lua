return {
  {
    "mrjones2014/legendary.nvim",
    -- since legendary.nvim handles all your keymaps/commands,
    -- its recommended to load legendary.nvim before other plugins
    priority = 10000,
    lazy = false,
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
      },
    },
    config = function(_, opts)
      require("legendary").setup(opts)
      --   require("todo-comments").setup(opts)
      --   local mappings = require("lazy-plugins.keymaps.todo_comments")
      --   require("legendary").keymaps(mappings)
    end,
  },
}
