---@file nvim-treesitter plugin configuration
--- This file configures the `nvim-treesitter` plugin for syntax highlighting and text objects
--- in Neovim. It sets up Treesitter parsers and additional modules for enhanced functionality.

-- Parsers to ensure are installed
local parsers = {
  "bash",
  "c",
  "css",
  "csv",
  "cue",
  "diff",
  "dockerfile",
  "editorconfig",
  "fish",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "gotmpl",
  "gowork",
  "graphql",
  "hcl",
  "helm",
  "html",
  "http",
  "hurl",
  "javascript",
  "jinja",
  "jq",
  "jsdoc",
  "json",
  "latex",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "rst",
  "scss",
  "svelte",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "typst",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    -- The new main branch does not support lazy-loading
    lazy = false,
    config = function()
      local ts_install = require("nvim-treesitter.install")

      local ts_path = vim.fn.stdpath("data") .. "/mise/installs/node/latest/bin"
      vim.env.PATH = ts_path .. ":" .. (vim.env.PATH or "")
      ts_install.compilers = { "tree-sitter" }

      require("nvim-treesitter").setup()

      -- Register mise as a TOML-based filetype so treesitter uses the toml parser
      -- and queries/mise/injections.scm applies for mise config files.
      vim.treesitter.language.register("toml", "mise")

      -- Install missing parsers asynchronously on startup
      require("nvim-treesitter").install(parsers)

      -- Enable treesitter highlighting, indent, and folding for all supported filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local ok = pcall(vim.treesitter.start, ev.buf)
          if ok then
            -- Treesitter-based indentation (buffer-local, always safe)
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            -- Treesitter-based folding (window-local; apply to all windows showing this buffer)
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.api.nvim_win_get_buf(win) == ev.buf then
                vim.wo[win].foldmethod = "expr"
                vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
              end
            end
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    enabled = true,
    opts = {
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      -- When in diff mode, use default vim text objects c & C instead of treesitter ones.
      local move = require("nvim-treesitter-textobjects.move") ---@type table<string,fun(...)>
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = opts.textobjects.move[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },
  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>ut")
      return { mode = "cursor", max_lines = 3 }
    end,
  },
  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },
}
