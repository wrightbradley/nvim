---@file Code Formatting Configuration with Conform.nvim
--- This file configures the conform.nvim plugin for automatic code formatting.
--- It provides language-specific formatters and integrates with the Util format system
--- to enable format-on-save functionality and manual formatting commands.

---@class ConformSetup
local M = {}

--- Setup function for conform.nvim with Util integration
--- Validates configuration options and warns about deprecated usage
---@param _ any Plugin spec (unused)
---@param opts conform.setupOpts Configuration options for conform
function M.setup(_, opts)
  -- Validate that format_on_save and format_after_save are not set
  -- These are handled by the Util format system instead
  for _, key in ipairs({ "format_on_save", "format_after_save" }) do
    if opts[key] then
      local msg = "Don't set `opts.%s` for `conform.nvim`.\n**Util** will use the conform formatter automatically"
      Util.warn(msg:format(key))
      ---@diagnostic disable-next-line: no-unknown
      opts[key] = nil
    end
  end

  -- Warn about deprecated format option
  ---@diagnostic disable-next-line: undefined-field
  if opts.format then
    Util.warn("**conform.nvim** `opts.format` is deprecated. Please use `opts.default_format_opts` instead.")
  end

  require("conform").setup(opts)
end

return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" }, -- Mason for formatter installation
    lazy = true,                     -- Load on demand
    cmd = "ConformInfo",            -- Load when ConformInfo command is used
    keys = {
      {
        "<leader>cF",
        function()
          -- Format injected languages (e.g., code blocks in markdown)
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },

    -- Initialize conform integration with Util format system
    init = function()
      -- Register conform as the primary formatter on VeryLazy event
      Util.on_very_lazy(function()
        Util.format.register({
          name = "conform.nvim",
          priority = 100,        -- High priority formatter
          primary = true,        -- This is the primary formatting system
          format = function(buf)
            require("conform").format({ bufnr = buf })
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v)
              return v.name
            end, ret)
          end,
        })
      end)
    end,
    opts = function()
      local plugin = require("lazy.core.config").plugins["conform.nvim"]
      if plugin.config ~= M.setup then
        Util.error({
          "Don't set `plugin.config` for `conform.nvim`.\n",
          "This will break **Util** formatting.\n",
        }, { title = "Util" })
      end
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        formatters_by_ft = {
          ["markdown.mdx"] = { "dprint", "markdownlint-cli2", "markdown-toc" },
          ["terraform-vars"] = { "terraform_fmt" },
          fish = { "fish_indent" },
          hcl = { "packer_fmt" },
          json = { "dprint" },
          lua = { "stylua" },
          markdown = { "dprint", "markdownlint-cli2", "markdown-toc" },
          sh = { "shfmt" },
          terraform = { "terraform_fmt" },
          tf = { "terraform_fmt" },
          yaml = { "yamlfmt", "dprint" },
          go = { "goimports", "gofumpt" },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          -- # Example of using dprint only when a dprint.json file is present
          -- dprint = {
          --   condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          --   prepend_args = { "-i", "2", "-ci" },
          -- },
          injected = { options = { ignore_errors = true } },
          yamlfmt = {
            command = "yamlfmt",
          },
          ["markdown-toc"] = {
            condition = function(_, ctx)
              for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                if line:find("<!%-%- toc %-%->") then
                  return true
                end
              end
            end,
          },
          ["markdownlint-cli2"] = {
            condition = function(_, ctx)
              local diag = vim.tbl_filter(function(d)
                return d.source == "markdownlint"
              end, vim.diagnostic.get(ctx.buf))
              return #diag > 0
            end,
          },
        },
      }
      return opts
    end,
    config = M.setup,
  },
}
