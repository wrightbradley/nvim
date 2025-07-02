--- CodeCompanion Model Toggle Extension
--- Provides quick model switching for chat buffers.
-- extensions = {
--   ["chat-model-toggle"] = {
--     opts = {
--       keymap = "<S-Tab>", -- or any other keymap you prefer
--       copilot = "o4-mini", -- adapter = alternate model
--       openai = "gpt-4o",
--     }
--   }
-- }
---@alias ModelName string

---@class ModelToggleOpts
---@field keymap string?   Keymap to toggle models (default: "gM")

---@class ModelToggleConfig
---@field [adapter_name: string] ModelName  Alternate model per adapter

---@type table<integer, ModelName>
local original_models = {}

---Get the active CodeCompanion chat instance for a buffer.
---@param bufnr integer
---@return CodeCompanion.Chat|nil
local function get_chat_for_buffer(bufnr)
  -- Directly require the chat strategy module
  local chat_strategy = require("codecompanion.strategies.chat")
  if type(chat_strategy.buf_get_chat) ~= "function" then
    return nil
  end
  return chat_strategy.buf_get_chat(bufnr)
end

---Load extension configuration.
---@return ModelToggleConfig
local function load_config()
  local cfg = require("codecompanion.config")
  return (cfg.extensions and cfg.extensions["chat-model-toggle"] and cfg.extensions["chat-model-toggle"].opts) or {}
end

---Toggle between the original and alternate model in the chat buffer.
---@param bufnr integer
local function toggle_model(bufnr)
  local chat = get_chat_for_buffer(bufnr)
  if not chat or not chat.adapter then
    vim.notify("No CodeCompanion chat in this buffer", vim.log.levels.WARN)
    return
  end

  local cfg = load_config()
  local adapter_name = chat.adapter.name
  local alt_model = cfg[adapter_name]
  if type(alt_model) ~= "string" then
    vim.notify(string.format("No alternate model configured for adapter '%s'", adapter_name), vim.log.levels.WARN)
    return
  end

  -- Store original model name the first time
  if original_models[bufnr] == nil then
    local m = chat.adapter.model
    original_models[bufnr] = (type(m) == "table" and m.name) or chat.settings.model
  end

  local current = (type(chat.adapter.model) == "table" and chat.adapter.model.name) or chat.settings.model
  local original = original_models[bufnr]
  local target = (current == alt_model) and original or alt_model

  chat:apply_model(target)
  chat:apply_settings()

  vim.notify(string.format("Switched model to %s", target), vim.log.levels.INFO)
end

---Setup buffer-local and strategy keymaps.
---@param opts ModelToggleOpts
local function setup_keymaps(opts)
  local key = opts.keymap or "gM"
  local cfg = require("codecompanion.config")

  if cfg.strategies and cfg.strategies.chat and type(cfg.strategies.chat.keymaps) == "table" then
    cfg.strategies.chat.keymaps.toggle_model = {
      modes = { n = key },
      description = "Toggle chat model",
      callback = function()
        toggle_model(vim.api.nvim_get_current_buf())
      end,
    }
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "codecompanion",
    callback = function(args)
      vim.keymap.set("n", key, function()
        toggle_model(args.buf)
      end, {
        buffer = args.buf,
        desc = "Toggle chat model",
        silent = true,
      })
    end,
  })
end

---Cleanup original model cache on buffer deletion.
local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("CodeCompanionModelToggle", { clear = true })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      original_models[args.buf] = nil
    end,
  })
end

---@class ModelToggleExtensionAPI
---@field setup   fun(opts: ModelToggleOpts)
---@field exports table<string, fun(bufnr: integer)>

local Extension = {
  setup = function(opts)
    setup_keymaps(opts or {})
    setup_autocmds()
  end,
  exports = {
    toggle_model = toggle_model,
  },
}

return Extension
