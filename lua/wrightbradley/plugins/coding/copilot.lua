-- copilot suggestions and completion
return {
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local colors = {
        [""] = Util.ui.fg("Special"),
        ["Normal"] = Util.ui.fg("Special"),
        ["Warning"] = Util.ui.fg("DiagnosticError"),
        ["InProgress"] = Util.ui.fg("DiagnosticWarn"),
      }
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local icon = require("wrightbradley.config").icons.kinds.Copilot
          local status = require("copilot.api").status.data
          return icon .. (status.message or "")
        end,
        cond = function()
          if not package.loaded["copilot"] then
            return
          end
          local ok, clients = pcall(Util.lsp.get_clients, { name = "copilot", bufnr = 0 })
          if not ok then
            return false
          end
          return ok and #clients > 0
        end,
        color = function()
          if not package.loaded["copilot"] then
            return
          end
          local status = require("copilot.api").status.data
          return colors[status.status] or colors[""]
        end,
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    keys = {
      -- Code related commands
      { "<leader>cce", "<Cmd>CopilotChatExplain<CR>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<Cmd>CopilotChatTests<CR>", desc = "CopilotChat - Generate tests" },
      { "<leader>ccr", "<Cmd>CopilotChatReview<CR>", desc = "CopilotChat - Review code" },
      { "<leader>ccR", "<Cmd>CopilotChatRefactor<CR>", desc = "CopilotChat - Refactor code" },
      { "<leader>ccn", "<Cmd>CopilotChatBetterNamings<CR>", desc = "CopilotChat - Better Naming" },
      -- Chat with Copilot in visual mode
      { "<leader>ccv", ":CopilotChatVisual ", mode = "x", desc = "CopilotChat - Chat with vertical split" },
      { "<leader>ccx", ":CopilotChatInline<CR>", mode = "x", desc = "CopilotChat - Inline chat" },
      -- Custom input for CopilotChat
      {
        "<leader>cci",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "CopilotChat - Ask input",
      },
      -- Generate commit message based on the git diff
      { "<leader>ccm", "<Cmd>CopilotChatCommit<CR>", desc = "CopilotChat - Generate commit message for all changes" },
      {
        "<leader>ccM",
        "<Cmd>CopilotChatCommitStaged<CR>",
        desc = "CopilotChat - Generate commit message for staged changes",
      },
      -- Quick chat with Copilot
      {
        "<leader>ccq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CopilotChatBuffer " .. input)
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      -- Debug
      { "<leader>ccd", "<Cmd>CopilotChatDebugInfo<CR>", desc = "CopilotChat - Debug Info" },
      -- Fix the issue with diagnostic
      { "<leader>ccf", "<Cmd>CopilotChatFixDiagnostic<CR>", desc = "CopilotChat - Fix Diagnostic" },
      -- Clear buffer and chat history
      { "<leader>ccl", "<Cmd>CopilotChatReset<CR>", desc = "CopilotChat - Clear buffer and chat history" },
      --  -- Toggle Copilot Chat Vsplit
      --  { "<leader>ccv", "<Cmd>CopilotChatToggle<CR>", desc = "CopilotChat - Toggle Vsplit" },
      -- Show help actions with telescope
      {
        "<leader>cch",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end,
        desc = "CopilotChat - Help actions",
      }, -- show help actions with telescope
      {
        "<leader>ccp",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Help actions",
      }, -- show prompts actions with telescope
      {
        "<leader>ccp",
        ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
        desc = "CopilotChat - Prompt actions",
      },
    },
    opts = {
      debug = true, -- Enable debugging
      window = {
        layout = "float",
        relative = "cursor",
        width = 1,
        height = 0.4,
        row = 1,
      },
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  -- copilot cmp source
  {
    "nvim-cmp",
    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        dependencies = "copilot.lua",
        opts = {},
        config = function(_, opts)
          local copilot_cmp = require("copilot_cmp")
          copilot_cmp.setup(opts)
          -- attach cmp source whenever copilot attaches
          -- fixes lazy-loading issues with the copilot cmp source
          Util.lsp.on_attach(function(client)
            if client.name == "copilot" then
              copilot_cmp._on_insert_enter({})
            end
          end)
        end,
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "copilot",
        group_index = 1,
        priority = 100,
      })
    end,
  },
}
