---@file fff.nvim - Freakin Fast Fuzzy File Finder
--- Rust-backed file picker and live grep with frecency scoring, git status
--- integration, and query history. Replaces Snacks.picker for find_files
--- and live_grep; Snacks.picker remains active for all other search sources.

return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  opts = {
    layout = {
      height = 0.8,
      width = 0.8,
      prompt_position = "bottom",
      preview_position = "right",
      preview_size = 0.5,
      flex = {
        size = 130,
        wrap = "top",
      },
    },
    frecency = {
      enabled = true,
    },
    history = {
      enabled = true,
    },
    git = {
      status_text_color = false,
    },
    grep = {
      smart_case = true,
      modes = { "plain", "regex", "fuzzy" },
    },
    debug = {
      enabled = false,
      show_scores = false,
    },
  },
  -- stylua: ignore
  keys = {
    -- Find files
    { "<leader>ff", function() require("fff").find_files() end, desc = "Find Files (Root Dir)" },
    { "<leader>fF", function() require("fff").find_files_in_dir(vim.uv.cwd()) end, desc = "Find Files (cwd)" },
    { "<leader><space>", function() require("fff").find_files() end, desc = "Find Files (Root Dir)" },

    -- Live grep
    { "<leader>/", function() require("fff").live_grep() end, desc = "Grep (Root Dir)" },
    { "<leader>sg", function() require("fff").live_grep() end, desc = "Grep (Root Dir)" },
    { "<leader>sG", function() require("fff").live_grep({ cwd = vim.uv.cwd() }) end, desc = "Grep (cwd)" },
    { "<leader>sw", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, desc = "Search word (Root Dir)", mode = { "n", "x" } },
    { "<leader>sW", function() require("fff").live_grep({ query = vim.fn.expand("<cword>"), cwd = vim.uv.cwd() }) end, desc = "Search word (cwd)", mode = { "n", "x" } },
    { "<leader>sz", function() require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end, desc = "Fuzzy grep" },
  },
}
