---@file Completion-related utility functions for Neovim
--- This module provides utility functions for handling snippets and mapping actions
--- for the completion engine in Neovim. It integrates with LSP for enhanced snippet
--- documentation and completion capabilities.

---@class wrightbradley.util.cmp
local M = {}

---@alias wrightbradley.util.cmp.Action fun():boolean?
---@type table<string, wrightbradley.util.cmp.Action>
M.actions = {
  -- Native Snippets
  --- Moves forward in a snippet if active.
  snippet_forward = function()
    if vim.snippet.active({ direction = 1 }) then
      vim.schedule(function()
        vim.snippet.jump(1)
      end)
      return true
    end
  end,
  --- Stops the current snippet session.
  snippet_stop = function()
    if vim.snippet then
      vim.snippet.stop()
    end
  end,
}

--- Maps a sequence of actions to a function.
---@param actions string[] List of action names to map.
---@param fallback? string|fun() Fallback action if none of the actions succeed.
---@return fun() A function that executes the mapped actions.
function M.map(actions, fallback)
  return function()
    for _, name in ipairs(actions) do
      if M.actions[name] then
        local ret = M.actions[name]()
        if ret then
          return true
        end
      end
    end
    return type(fallback) == "function" and fallback() or fallback
  end
end

---@alias Placeholder {n:number, text:string}

--- Replaces placeholders in a snippet with a custom function.
---@param snippet string The snippet string containing placeholders.
---@param fn fun(placeholder:Placeholder):string The function to replace placeholders.
---@return string The snippet with placeholders replaced.
function M.snippet_replace(snippet, fn)
  return snippet:gsub("%$%b{}", function(m)
    local n, name = m:match("^%${(%d+):(.+)}$")
    return n and fn({ n = n, text = name }) or m
  end) or snippet
end

--- Resolves nested placeholders in a snippet.
---@param snippet string The snippet string to resolve.
---@return string The resolved snippet string.
function M.snippet_preview(snippet)
  local ok, parsed = pcall(function()
    return vim.lsp._snippet_grammar.parse(snippet)
  end)
  return ok and tostring(parsed)
    or M.snippet_replace(snippet, function(placeholder)
      return M.snippet_preview(placeholder.text)
    end):gsub("%$0", "")
end

--- Replaces nested placeholders in a snippet with LSP placeholders.
---@param snippet string The snippet string to fix.
---@return string The fixed snippet string.
function M.snippet_fix(snippet)
  local texts = {} ---@type table<number, string>
  return M.snippet_replace(snippet, function(placeholder)
    texts[placeholder.n] = texts[placeholder.n] or M.snippet_preview(placeholder.text)
    return "${" .. placeholder.n .. ":" .. texts[placeholder.n] .. "}"
  end)
end

--- Automatically adds brackets for function and method completions.
---@param entry cmp.Entry The completion entry.
function M.auto_brackets(entry)
  local cmp = require("cmp")
  local Kind = cmp.lsp.CompletionItemKind
  local item = entry:get_completion_item()
  if vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind) then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local prev_char = vim.api.nvim_buf_get_text(0, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] + 1, {})[1]
    if prev_char ~= "(" and prev_char ~= ")" then
      local keys = vim.api.nvim_replace_termcodes("()<left>", false, false, true)
      vim.api.nvim_feedkeys(keys, "i", true)
    end
  end
end

--- Adds missing documentation to snippets.
--- The documentation is a preview of the snippet.
---@param window cmp.CustomEntriesView|cmp.NativeEntriesView The completion window.
function M.add_missing_snippet_docs(window)
  local cmp = require("cmp")
  local Kind = cmp.lsp.CompletionItemKind
  local entries = window:get_entries()
  for _, entry in ipairs(entries) do
    if entry:get_kind() == Kind.Snippet then
      local item = entry:get_completion_item()
      if not item.documentation and item.insertText then
        item.documentation = {
          kind = cmp.lsp.MarkupKind.Markdown,
          value = string.format("```%s\n%s\n```", vim.bo.filetype, M.snippet_preview(item.insertText)),
        }
      end
    end
  end
end

--- A better implementation of `cmp.confirm`.
--- This function is both faster and more reliable.
---@param opts? {select: boolean, behavior: cmp.ConfirmBehavior} Optional confirmation options.
---@return fun(fallback: fun()) A function to confirm the completion.
function M.confirm(opts)
  local cmp = require("cmp")
  opts = vim.tbl_extend("force", {
    select = true,
    behavior = cmp.ConfirmBehavior.Insert,
  }, opts or {})
  return function(fallback)
    if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
      Util.create_undo()
      if cmp.confirm(opts) then
        return
      end
    end
    return fallback()
  end
end

--- Expands a snippet, handling nested sessions.
---@param snippet string The snippet to expand.
function M.expand(snippet)
  -- Native sessions don't support nested snippet sessions.
  -- Always use the top-level session.
  -- Otherwise, when on the first placeholder and selecting a new completion,
  -- the nested session will be used instead of the top-level session.
  -- See: https://github.com/LazyVim/LazyVim/issues/3199
  local session = vim.snippet.active() and vim.snippet._session or nil

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = M.snippet_fix(snippet)
    ok = pcall(vim.snippet.expand, fixed)

    local msg = ok and "Failed to parse snippet,\nbut was able to fix it automatically."
      or ("Failed to parse snippet.\n" .. err)

    Util[ok and "warn" or "error"](
      ([[%s
```%s
%s
```]]):format(msg, vim.bo.filetype, snippet),
      { title = "vim.snippet" }
    )
  end

  -- Restore top-level session when needed
  if session then
    vim.snippet._session = session
  end
end

--- Sets up the completion engine with specified options.
---@param opts cmp.ConfigSchema | {auto_brackets?: string[]} The setup options.
function M.setup(opts)
  for _, source in ipairs(opts.sources) do
    source.group_index = source.group_index or 1
  end

  local parse = require("cmp.utils.snippet").parse
  require("cmp.utils.snippet").parse = function(input)
    local ok, ret = pcall(parse, input)
    if ok then
      return ret
    end
    return Util.cmp.snippet_preview(input)
  end

  local cmp = require("cmp")
  cmp.setup(opts)
  cmp.event:on("confirm_done", function(event)
    if vim.tbl_contains(opts.auto_brackets or {}, vim.bo.filetype) then
      Util.cmp.auto_brackets(event.entry)
    end
  end)
  cmp.event:on("menu_opened", function(event)
    Util.cmp.add_missing_snippet_docs(event.window)
  end)
end

return M
