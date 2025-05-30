---@file Autocommands configuration
--- This file defines autocommands for various events to automate tasks in Neovim.
--- It includes handlers for events like buffer read, window resize, and text yank,
--- enhancing the user experience by automating common tasks.
--- See `:help lua-guide-autocommands`

--- Creates an autocommand group with the given name.
---@param name string Name of the autocommand group.
---@return string

local function augroup(name)
  return vim.api.nvim_create_augroup("" .. name, { clear = true })
end

--- Check if we need to reload the file when it changed
--- autocmd group: checktime
--- This autocommand checks if the file needs to be reloaded when focus is gained, or a terminal is closed/left.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

--- Highlight when yanking (copying) text
--- Try it with `yap` in normal mode
--- See `:help vim.highlight.on_yank()`
--- autocmd group: highlight_yank
--- This autocommand highlights the yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    if vim.highlight and vim.highlight.on_yank then
      vim.highlight.on_yank()
    end
  end,
  desc = "Highlight text on yank",
})

--- Resize splits if window got resized
--- autocmd group: resize_splits
--- This autocommand resizes splits when the window is resized.
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
  desc = "Resize splits on window resize",
})

--- Go to last loc when opening a buffer
--- autocmd group: last_loc
--- This autocommand goes to the last known location in a buffer when it's opened.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Go to last location when opening a buffer",
})

--- Close some filetypes with <q>
--- autocmd group: close_with_q
--- This autocommand closes certain filetypes with the <q> key.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
  desc = "Close some filetypes with <q>",
})

--- Make it easier to close man-files when opened inline
--- autocmd group: man_unlisted
--- This autocommand makes it easier to close man files when opened inline.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

--- Wrap and check for spell in text filetypes
--- autocmd group: wrap_spell
--- This autocommand enables wrapping and spell checking for text filetypes.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = "Enable wrap and spell checking for text-like files",
})

--- Fix conceallevel for json files
--- autocmd group: json_conceal
--- This autocommand fixes the conceallevel for json files.
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

--- Auto create dir when saving a file, in case some intermediate directory does not exist
--- autocmd group: auto_create_dir
--- This autocommand automatically creates a directory when saving a file if it doesn't exist.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Create directory if it doesn't exist when saving a file",
})
