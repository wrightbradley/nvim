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
      { '<leader>Ot', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
      { '<leader>Oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
      { '<leader>OA', function() require('opencode').ask('@file ') end, desc = 'Ask opencode about current file', mode = { 'n', 'v' }, },
      { '<leader>On', function() require('opencode').command('/new') end, desc = 'New session', },
      -- Review workflow (agent-written code)
      { '<leader>Ov', function() require('opencode').prompt('Review my uncommitted changes. Run `git diff` to see them, then review for correctness, security issues, and unnecessary complexity. Report findings before suggesting fixes.') end, desc = 'Review working diff', },
      { '<leader>Ob', function() require('opencode').prompt('Explain the hunk under the cursor. Run `git diff` first for context.') end, desc = 'Explain current change', },
      { '<leader>Oc', function() require('opencode').prompt('Write a conventional-commit message for my staged changes following the repo style in cliff.toml/CHANGELOG.md. Output only the message.') end, desc = 'Generate commit message', },
      -- General helpers
      { '<leader>Oe', function() require('opencode').prompt('Explain @cursor and its context') end, desc = 'Explain code near cursor' },
      { '<leader>Or', function() require('opencode').prompt('Review @file for correctness and readability') end, desc = 'Review file', },
      { '<leader>Of', function() require('opencode').prompt('Fix these @diagnostics') end, desc = 'Fix errors', },
      { '<leader>Oo', function() require('opencode').prompt('Optimize @selection for performance and readability') end, desc = 'Optimize selection', mode = 'v', },
      { '<leader>Od', function() require('opencode').prompt('Add documentation comments for @selection') end, desc = 'Document selection', mode = 'v', },
      { '<leader>OT', function() require('opencode').prompt('Add tests for @selection') end, desc = 'Test selection', mode = 'v', },
    },
  },
}
