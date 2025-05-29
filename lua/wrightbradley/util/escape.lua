---@file Better escape utility for Neovim
--- This module provides enhanced escape functionality, allowing for key sequences
--- like 'jk' or 'jj' to exit insert, command, visual, and terminal modes. It uses
--- a timeout-based approach to detect key sequences and handles buffer modification
--- state preservation.

---@class wrightbradley.util.escape
local M = {}

local uv = vim.uv or vim.loop
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

--- Indicator if the utility is currently waiting for a second key
M.waiting = false

--- Default settings for the better escape functionality
---@type table
M.opts = {
  timeout = vim.o.timeoutlen,
  default_mappings = true,
  mappings = {
    i = {
      --  first_key[s]
      j = {
        --  second_key[s]
        k = "<Esc>",
        j = "<Esc>",
      },
    },
    c = {
      j = {
        k = "<C-c>",
        j = "<C-c>",
      },
    },
    t = {
      j = {
        k = "<C-\\><C-n>",
      },
    },
    v = {
      j = {
        k = "<Esc>",
      },
    },
    s = {
      j = {
        k = "<Esc>",
      },
    },
  },
}

-- Internal state variables
local recorded_key = nil
local bufmodified = nil
local timeout_timer = uv.new_timer()
local has_recorded = false

--- Unmaps all key mappings configured in settings.
local function unmap_keys()
  for mode, keys in pairs(M.opts.mappings) do
    for key, subkeys in pairs(keys) do
      pcall(vim.keymap.del, mode, key)
      for subkey, _ in pairs(subkeys) do
        pcall(vim.keymap.del, mode, subkey)
      end
    end
  end
end

--- Records a key press and sets a timeout for key sequence detection.
---@param key string The pressed key
local function record_key(key)
  if timeout_timer:is_active() then
    timeout_timer:stop()
  end
  bufmodified = vim.bo.modified
  recorded_key = key
  has_recorded = true
  M.waiting = true
  timeout_timer:start(M.opts.timeout, 0, function()
    M.waiting = false
    recorded_key = nil
  end)
end

--- List of keys that undo the effect of pressing first_key
---@type table<string, string>
local undo_key = {
  i = "<bs>",
  c = "<bs>",
  t = "<bs>",
}

--- Maps all keys configured in the settings.
local function map_keys()
  for mode, first_keys in pairs(M.opts.mappings) do
    local map_opts = { expr = true }
    for first_key, _ in pairs(first_keys) do
      vim.keymap.set(mode, first_key, function()
        record_key(first_key)
        return first_key
      end, map_opts)
    end
    for _, second_keys in pairs(first_keys) do
      for second_key, mapping in pairs(second_keys) do
        if not mapping then
          goto continue
        end
        vim.keymap.set(mode, second_key, function()
          -- If a first_key wasn't recorded, record second_key because it might be a first_key for another sequence.
          if recorded_key == nil then
            record_key(second_key)
            return second_key
          end
          -- If a key was recorded, but it isn't the first_key for second_key, record second_key
          -- Or if the recorded_key was just a second_key
          if not (first_keys[recorded_key] and first_keys[recorded_key][second_key]) then
            record_key(second_key)
            return second_key
          end
          local keys = ""
          keys = keys
            .. t((undo_key[mode] or "") .. (("<cmd>setlocal %smodified<cr>"):format(bufmodified and "" or "no")))
          if type(mapping) == "string" then
            keys = keys .. t(mapping)
          elseif type(mapping) == "function" then
            keys = keys .. t(mapping() or "")
          end
          vim.api.nvim_feedkeys(keys, "in", false)
        end, map_opts)
        ::continue::
      end
    end
  end
end

--- Sets up the on_key callback to handle key sequence detection.
local function setup_on_key_callback()
  vim.on_key(function(_, typed)
    if typed == "" then
      return
    end
    if has_recorded == false then
      -- If the user presses a key that doesn't get recorded, remove the previously recorded key.
      recorded_key = nil
      return
    end
    has_recorded = false
  end)
end

--- Sets up the better escape functionality with optional overrides.
---@param opts? table Optional configuration overrides
function M.setup(opts)
  -- Handle legacy options
  if opts then
    if opts.default_mappings == false then
      M.opts.mappings = {}
    end

    if opts.keys or opts.clear_empty_lines then
      vim.notify(
        "[better-escape.nvim]: Rewrite! Check: https://github.com/max397574/better-escape.nvim",
        vim.log.levels.WARN,
        {}
      )
    end

    if opts.mapping then
      vim.notify(
        "[better-escape.nvim]: Rewrite! Check: https://github.com/max397574/better-escape.nvim",
        vim.log.levels.WARN,
        {}
      )
      if type(opts.mapping) == "string" then
        opts.mapping = { opts.mapping }
      end
      for _, mapping in ipairs(opts.mapping) do
        if not M.opts.mappings.i then
          M.opts.mappings.i = {}
        end
        if not M.opts.mappings.i[mapping:sub(1, 1)] then
          M.opts.mappings.i[mapping:sub(1, 1)] = {}
        end
        M.opts.mappings.i[mapping:sub(1, 1)][mapping:sub(2, 2)] = opts.keys or "<Esc>"
      end
    end
  end

  -- Merge user options with defaults
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- Setup the escape functionality
  unmap_keys()
  setup_on_key_callback()
  map_keys()
end

--- Cleans up and removes the escape functionality.
function M.disable()
  unmap_keys()
  if timeout_timer:is_active() then
    timeout_timer:stop()
  end
  vim.on_key(nil) -- Remove the callback
  M.waiting = false
  recorded_key = nil
  has_recorded = false
end

return M
