local copilot_enabled = os.getenv("NVIM_ENABLE_COPILOT")
if copilot_enabled == "false" then
  return {}
end
local M = {}

---@param kind string
function M.pick(kind)
  return function()
    local actions = require("CopilotChat.actions")
    local items = actions[kind .. "_actions"]()
    if not items then
      Util.warn("No " .. kind .. " found on the current line")
      return
    end
    local map = {
      telescope = "telescope",
      fzf = "fzflua",
      snacks = "snacks",
    }
    for _, def in pairs(Util.config.get_defaults()) do
      if def.enabled and map[def.name] then
        return require("CopilotChat.integrations." .. map[def.name]).pick(items)
      end
    end
    Snacks.notify.error("No picker found")
  end
end

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    lazy = false,
    cmd = "CopilotChat",
    opts = function()
      local user = vim.env.USER or "User"
      user = user:sub(1, 1):upper() .. user:sub(2)
      return {
        auto_insert_mode = true,
        question_header = "  " .. user .. " ",
        answer_header = "  Copilot ",
        window = {
          width = 0.4,
        },
      }
    end,
    keys = {
      { "<leader>ac", group = "copilot" },
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
      {
        "<leader>acc",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>acx",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>acq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input)
          end
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
      -- Show prompts actions with telescope
      { "<leader>acp", M.pick("prompt"), desc = "Prompt Actions (CopilotChat)", mode = { "n", "v" } },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },

  -- Edgy integration
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        ft = "copilot-chat",
        title = "Copilot Chat",
        size = { width = 50 },
      })
    end,
  },
}
