return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "delve" } },
      },
      {
        "leoluz/nvim-dap-go",
        opts = {},
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "fredrikaverpil/neotest-golang",
    },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          -- Here we can set options for neotest-golang, e.g.
          -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
          dap_go_enabled = true, -- requires leoluz/nvim-dap-go
        },
      },
    },
  },

  -- TODO: Investigate this
  -- -- Enable autocompletion for Go LSP servers
  -- {
  --   init = function()
  --     vim.api.nvim_create_autocmd("LspAttach", {
  --       callback = function(ev)
  --         local client = vim.lsp.get_client_by_id(ev.data.client_id)
  --         if client and client.name == "gopls" and client:supports_method('textDocument/completion') then
  --           vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
  --         end
  --       end,
  --       pattern = "*.go",
  --     })
  --   end,
  -- },
}
