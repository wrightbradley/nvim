vim.filetype.add({
  extension = {
    ["http"] = "http",
  },
})
return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>k", "", desc = "+Rest" },
      { "<leader>ka", "<cmd>lua require('kulala').run_all()<cr>", desc = "Send all requests" },
      { "<leader>kc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy the current request as a curl command" },
      { "<leader>ke", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Sets selected environment" },
      { "<leader>kf", "<cmd>lua require('kulala').search()<cr>", desc = "Search for http files" },
      { "<leader>kh", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Opens scratchpad" },
      { "<leader>ki", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect the current request" },
      { "<leader>kjn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request" },
      { "<leader>kjp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request" },
      { "<leader>kr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay last run request" },
      { "<leader>ks", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request" },
      { "<leader>kt", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show statistics of the last run request" },
      { "<leader>kv", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body" },
      {
        "<leader>kp",
        "<cmd>lua require('kulala').from_curl()<cr>",
        desc = "Paste curl from clipboard as http request",
      },
    },
    opts = {
      default_env = "local",
      debug = true,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "http", "graphql" },
    },
  },
}
