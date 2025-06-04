return {
  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific
  -- location.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
    -- config = function(_, opts)
    --   -- Also set up flash integration with Snacks
    --   require("flash").setup(opts)
    --
    -- Integration with Snacks
    -- if Util.has("snacks.nvim") then
    --   Util.on_load("snacks.nvim", function()
    --     Snacks.picker.register_extension({
    --       actions = {
    --         flash = function(picker)
    --           require("flash").jump({
    --             pattern = "^",
    --             label = { after = { 0, 0 } },
    --             search = {
    --               mode = "search",
    --               exclude = {
    --                 function(win)
    --                   return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
    --                 end,
    --               },
    --             },
    --             action = function(match)
    --               local idx = picker.list:row2idx(match.pos[1])
    --               picker.list:_move(idx, true, true)
    --             end,
    --           })
    --         end,
    --       },
    --       keys = {
    --         input = {
    --           ["<a-s>"] = { "flash", mode = { "n", "i" } },
    --           ["s"] = { "flash" },
    --         }
    --       }
    --     })
    --   end)
    -- end
  },
}
