local codeium_enabled = os.getenv("NVIM_ENABLE_CODEIUM")
if codeium_enabled == "false" then
  return {}
end
return {
  -- codeium
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    build = ":Codeium Auth",
    opts = {
      enable_cmp_source = vim.g.ai_cmp,
      virtual_text = {
        enabled = not vim.g.ai_cmp,
        key_bindings = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
    },
  },

  -- add ai_accept action
  {
    "Exafunction/codeium.nvim",
    opts = function()
      Util.cmp.actions.ai_accept = function()
        if require("codeium.virtual_text").get_current_completion_item() then
          Util.create_undo()
          vim.api.nvim_input(require("codeium.virtual_text").accept())
          return true
        end
      end
    end,
  },

  -- codeium cmp source
  {
    "nvim-cmp",
    optional = true,
    dependencies = { "codeium.nvim" },
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, Util.lualine.cmp_source("codeium"))
    end,
  },

  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        compat = vim.g.ai_cmp and { "codeium" } or nil,
      },
    },
    dependencies = {
      "codeium.nvim",
      vim.g.ai_cmp and "saghen/blink.compat" or nil,
    },
  },
}
