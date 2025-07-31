---@file CodeCompanion Model Toggle Extension
--- This extension provides quick model switching functionality for CodeCompanion chat buffers.
--- It allows users to toggle between a primary model and an alternate model per adapter,
--- which is useful for comparing responses or switching between cost/performance tiers.
---
--- Usage in CodeCompanion configuration:
--- extensions = {
---   ["chat-model-toggle"] = {
---     opts = {
---       keymap = "gM",              -- Keymap to toggle models
---       copilot = "gemini-2.5-pro", -- Alternate model for copilot adapter
---       openai = "gpt-4o",          -- Alternate model for openai adapter
---     }
---   }
--- }

---@alias ModelName string The name of a language model

---@class ModelToggleOpts Configuration options for the model toggle extension
---@field keymap string? Keymap to toggle models (default: "gM")

---@class ModelToggleConfig Adapter-specific alternate model configuration
---@field [adapter_name: string] ModelName Alternate model per adapter (e.g., copilot = "o1")

---@type table<integer, ModelName> Cache of original models per buffer
local original_models = {}

--- Get the active CodeCompanion chat instance for a buffer
---@param bufnr integer Buffer number to get chat instance for
---@return CodeCompanion.Chat|nil The chat instance or nil if not found
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
