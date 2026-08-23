return {
  "nvzone/typr",
  -- Only use the local checkout when it exists (development); otherwise fall
  -- back to the GitHub repo so this works on any machine.
  dir = vim.fn.isdirectory(vim.fn.expand("~/Projects/study/typr")) == 1 and vim.fn.expand("~/Projects/study/typr")
    or nil,
  dependencies = "nvzone/volt",
  opts = {
    -- Optional: Add your custom config here
    mode = "python", -- Start in python mode
    -- wpm_goal = 100,
  },
  cmd = { "Typr", "TyprStats" },
  keys = {
    { "<leader>ty", "<cmd>Typr<cr>", desc = "Open Typr" },
    { "<leader>T", "<cmd>TyprStats<cr>", desc = "Typr Stats" },
  },
}
