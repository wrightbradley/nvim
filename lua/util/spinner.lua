---@file Spinner animation utilities for Neovim
--- This module provides utility functions for managing spinner animations in Neovim.
--- It integrates with the Fidget plugin to display progress indicators for asynchronous tasks.

---@class util.spinner
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

local progress = require("fidget.progress")

--- Initializes the spinner by setting up autocommands for request events.
function M:init()
  local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequestStarted",
    group = group,
    callback = function(request)
      local handle = M:create_progress_handle(request)
      M:store_progress_handle(request.data.id, handle)
    end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequestFinished",
    group = group,
    callback = function(request)
      local handle = M:pop_progress_handle(request.data.id)
      if handle then
        M:report_exit_status(handle, request)
        handle:finish()
      end
    end,
  })
end

M.handles = {}

--- Stores a progress handle by request ID.
---@param id string The request ID.
---@param handle table The progress handle to store.
function M:store_progress_handle(id, handle)
  M.handles[id] = handle
end

--- Retrieves and removes a progress handle by request ID.
---@param id string The request ID.
---@return table|nil The progress handle, or nil if not found.
function M:pop_progress_handle(id)
  local handle = M.handles[id]
  M.handles[id] = nil
  return handle
end

--- Creates a progress handle for a request.
---@param request table The request data.
---@return table The created progress handle.
function M:create_progress_handle(request)
  return progress.handle.create({
    -- title = "  Requesting assistance (" .. request.data.strategy .. ")",
    title = "",
    message = "  Sending...",
    lsp_client = {
      name = M:llm_role_title(request.data.adapter),
    },
  })
end

--- Generates a title for the LLM role based on the adapter.
---@param adapter table The adapter data.
---@return string The generated title.
function M:llm_role_title(adapter)
  local parts = {}
  table.insert(parts, adapter.formatted_name)
  if adapter.model and adapter.model ~= "" then
    table.insert(parts, "(" .. adapter.model .. ")")
  end
  return table.concat(parts, " ")
end

--- Reports the exit status of a request.
---@param handle table The progress handle.
---@param request table The request data.
function M:report_exit_status(handle, request)
  if request.data.status == "success" then
    handle.message = "Completed"
  elseif request.data.status == "error" then
    handle.message = " Error"
  else
    handle.message = "󰜺 Cancelled"
  end
end

return M
