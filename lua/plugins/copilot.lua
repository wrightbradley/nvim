-- local copilot_enabled = os.getenv("NVIM_ENABLE_COPILOT")
-- if copilot_enabled == "false" then
--   return {}
-- end
-- copilot suggestions and completion
return {
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  -- -- add ai_accept action
  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = "VeryLazy", -- Load after other plugins
  --   config = function()
  --     -- Ensure ai_accept action is available
  --     if not Util.cmp.actions.ai_accept then
  --       Util.cmp.actions.ai_accept = function()
  --         if require("copilot.suggestion").is_visible() then
  --           Util.create_undo()
  --           require("copilot.suggestion").accept()
  --           return true
  --         end
  --       end
  --     end
  --   end,
  -- },
}
