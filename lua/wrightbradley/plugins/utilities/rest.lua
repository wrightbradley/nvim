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
      { "<leader>k", "", desc = "+Rest", ft = "http" },
      { "<leader>ka", "<cmd>lua require('kulala').run_all()<cr>", desc = "Send all requests", ft = "http" },
      { "<leader>kc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy the current request as a curl command", ft = "http" },
      { "<leader>ke", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Sets selected environment", ft = "http" },
      { "<leader>kf", "<cmd>lua require('kulala').search()<cr>", desc = "Search for http files", ft = "http" },
      { "<leader>kh", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Opens scratchpad", ft = "http" },
      { "<leader>ki", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect the current request", ft = "http" },
      { "<leader>kjn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
      { "<leader>kjp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
      { "<leader>kr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay last run request", ft = "http" },
      { "<leader>ks", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
      { "<leader>kt", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show statistics of the last run request", ft = "http" },
      { "<leader>kv", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body", ft = "http" },
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
