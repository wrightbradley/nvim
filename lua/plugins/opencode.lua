---@file OpenCode AI Integration Configuration
--- This file configures the OpenCode plugin for additional AI coding assistance.
--- It provides an alternative AI interface with context-aware prompts and
--- specialized commands for code explanation, optimization, and testing.

return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    ---@type opencode.Config
    opts = {
      -- Configuration options for OpenCode
      -- Add any specific OpenCode settings here if needed
    },
    -- stylua: ignore
    keys = {
      -- opencode.nvim exposes a general, flexible API — customize it to your workflow!
      -- But here are some examples to get you started :)
      { '<leader>Ot', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
      { '<leader>Oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
      { '<leader>OA', function() require('opencode').ask('@file ') end, desc = 'Ask opencode about current file', mode = { 'n', 'v' }, },
      { '<leader>On', function() require('opencode').command('/new') end, desc = 'New session', },
      { '<leader>Oe', function() require('opencode').prompt('Explain @cursor and its context') end, desc = 'Explain code near cursor' },
      { '<leader>Or', function() require('opencode').prompt('Review @file for correctness and readability') end, desc = 'Review file', },
      { '<leader>Of', function() require('opencode').prompt('Fix these @diagnostics') end, desc = 'Fix errors', },
      { '<leader>Oo', function() require('opencode').prompt('Optimize @selection for performance and readability') end, desc = 'Optimize selection', mode = 'v', },
      { '<leader>Od', function() require('opencode').prompt('Add documentation comments for @selection') end, desc = 'Document selection', mode = 'v', },
      { '<leader>OT', function() require('opencode').prompt('Add tests for @selection') end, desc = 'Test selection', mode = 'v', },
    },
  },
}
