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
      { "<leader>R", "", desc = "+Rest", ft = "http" },
      { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad", ft = "http" },
      { "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
      { "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
      {
        "<leader>Rg",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = "http",
      },
      { "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
      { "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
      { "<leader>Rp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
      { "<leader>Rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close window", ft = "http" },
      { "<leader>Rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request", ft = "http" },
      { "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
      { "<leader>RS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
      { "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body", ft = "http" },
      { "<leader>Ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Send all requests", ft = "http" },
      {
        "<leader>Re",
        "<cmd>lua require('kulala').set_selected_env()<cr>",
        desc = "Sets selected environment",
        ft = "http",
      },
      { "<leader>Rf", "<cmd>lua require('kulala').search()<cr>", desc = "Search for http files", ft = "http" },
      {
        "<leader>Rg",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = "http",
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
