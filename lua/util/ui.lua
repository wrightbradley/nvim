---@file UI-related utility functions for Neovim
--- This module provides utility functions for handling fold text and fold
--- expressions in Neovim. It includes optimizations for different Neovim
--- versions and integrates with Tree-sitter for enhanced folding capabilities.

---@class util.ui
local M = {}

--- Returns the fold text for Neovim versions less than 0.10.0.
--- This function retrieves the line at the current fold level.
---@return string The text of the fold.
function M.foldtext()
  return vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1]
end

--- Provides an optimized fold expression using Tree-sitter for Neovim versions 0.10.0 and above.
--- This function checks if Tree-sitter is available and uses it for folding if possible.
---@return string The fold expression result.
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- As long as we don't have a filetype, don't bother checking if Tree-sitter is available (it won't be)
    if vim.bo[buf].filetype == "" then
      return "0"
    end
    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

return M
