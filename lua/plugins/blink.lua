--[[
  Blink.cmp Configuration - Performance Optimized

  This configuration is the result of extensive debugging and optimization.
  Key performance insights discovered:

  1. LSP sources can block completion if servers are slow/unavailable
  2. Multiple sources competing simultaneously causes delays
  3. Per-filetype sources provide better performance than global defaults
  4. Friendly-snippets loading causes hanging issues - disabled until fixed
  5. Documentation auto-show adds significant overhead
  6. Buffer source scanning can be expensive with large files

  Performance Strategy:
  - Conservative default sources (snippets + buffer only)
  - LSP enabled per-filetype only where valuable
  - Aggressive buffer source limits
  - Documentation disabled by default (manual trigger available)
  - Snippet prioritization ensures they appear first
--]]

return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
    dependencies = {
      "rafamadriz/friendly-snippets", -- Currently disabled due to loading issues
      {
        "saghen/blink.compat",
        optional = true, -- make optional so it's only enabled if any extras need it
        opts = {},
      },
      "giuxtaposition/blink-cmp-copilot",
    },
    event = "InsertEnter",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = function()
      return {
        snippets = {
          expand = function(snippet, _)
            -- Snippet expansion using vim.snippet (native)
            return vim.snippet.expand(snippet)
          end,
        },
        appearance = {
          use_nvim_cmp_as_default = false,
          nerd_font_variant = "mono",
          kind_icons = vim.tbl_extend("force", {}, Util.config.icons.kinds),
        },
        completion = {
          accept = {
            auto_brackets = { enabled = true },
            dot_repeat = false,
          },
          menu = {
            auto_show = true,
            draw = {
              columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            },
            winblend = 0, -- Disable transparency for better performance
          },
          -- Documentation disabled for performance (was causing delays)
          -- Use <C-Space> to manually show documentation when needed
          documentation = {
            auto_show = false,
          },
          -- Ghost text enabled (minimal performance impact)
          ghost_text = {
            enabled = true,
          },
          -- Trigger settings optimized for responsiveness vs performance
          trigger = {
            show_on_insert_on_trigger_character = true,
            prefetch_on_insert = false, -- Reduce background processing
            show_in_snippet = true,
          },
        },
        signature = {
          enabled = true,
        },
        sources = {
          compat = {}, -- For nvim-cmp source compatibility
          -- Conservative default sources for general use
          -- Removed LSP from default to prevent blocking when servers unavailable
          default = { "snippets", "buffer" },

          -- Minimum keyword length to trigger completion (performance optimization)
          min_keyword_length = 2,

          providers = {
            -- Snippets configuration
            snippets = {
              opts = {
                friendly_snippets = true,
                search_paths = { vim.fn.stdpath("config") .. "/snippets" },
              },
              score_offset = 100, -- Highest priority - snippets first
            },

            -- Buffer source optimized for performance
            buffer = {
              max_items = 5, -- Limit to prevent overwhelming completion menu
              min_keyword_length = 3, -- Require more chars to reduce noise
              score_offset = -50, -- Lower priority than snippets
            },

            -- LazyDev for lua development
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },

            -- Copilot integration (disabled by default for performance)
            copilot = {
              name = "copilot",
              module = "blink-cmp-copilot",
              kind = "Copilot",
              score_offset = 100,
              async = true,
            },
          },

          --[[
            Per-filetype sources - key performance optimization

            Only enable LSP for languages where it provides significant value
            and where LSP servers are reliably available.

            Philosophy:
            - Snippets always included (primary value for most languages)
            - Buffer included for context-aware completion
            - LSP only where it adds substantial value
            - Specialized sources (lazydev) only where relevant
          --]]
          per_filetype = {
            -- Lua: Full featured with LSP + LazyDev for Neovim development
            lua = { "snippets", "lsp", "buffer", "lazydev" },

            -- Python: Snippets + buffer only (LSP can be added when properly configured)
            -- TODO: Add LSP back when Python language server is set up
            python = { "snippets", "buffer" },

            -- JavaScript/TypeScript: LSP typically well-configured and fast
            javascript = { "snippets", "lsp", "buffer" },
            typescript = { "snippets", "lsp", "buffer" },
            javascriptreact = { "snippets", "lsp", "buffer" },
            typescriptreact = { "snippets", "lsp", "buffer" },

            -- Shell scripts: No LSP needed, snippets are primary value
            -- Buffer useful for referencing variables and function names
            sh = { "snippets", "buffer" },
            bash = { "snippets", "buffer" },
            zsh = { "snippets", "buffer" },

            -- Configuration files: Buffer useful for duplicating values
            json = { "snippets", "buffer" },
            yaml = { "snippets", "buffer" },
            toml = { "snippets", "buffer" },

            -- Markdown: Buffer useful for referencing other content
            markdown = { "snippets", "buffer" },

            -- Go: Typically has excellent LSP support
            go = { "snippets", "lsp", "buffer" },

            -- Rust: Excellent LSP with rust-analyzer
            rust = { "snippets", "lsp", "buffer" },

            -- Special cases
            codecompanion = { "codecompanion" }, -- AI coding assistant
          },
        },

        -- Command line completion disabled (can cause conflicts)
        cmdline = {
          enabled = false,
        },

        -- Keymaps optimized for workflow
        keymap = {
          preset = "enter", -- Enter accepts completion
          ["<C-y>"] = { "select_and_accept" }, -- Ctrl-Y for quick accept
          ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" }, -- Manual trigger and docs
          ["<S-Tab>"] = {
            function()
              if vim.snippet.active({ direction = -1 }) then
                vim.snippet.jump(-1)
                return true
              end
            end,
            "fallback",
          },
        },
      }
    end,

    ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
    config = function(_, opts)
      -- Setup compat sources for nvim-cmp compatibility
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- Add Tab key behavior for snippet navigation + AI accept
      if not opts.keymap["<Tab>"] then
        opts.keymap["<Tab>"] = {
          function()
            -- First priority: snippet navigation
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
              return true
            end
            -- Second priority: AI accept (if available and configured)
            if Util.cmp.actions.ai_accept then
              return Util.cmp.actions.ai_accept()
            end
          end,
          "fallback",
        }
      end

      -- Unset custom prop to pass blink.cmp validation
      opts.sources.compat = nil

      -- Handle custom completion item kinds (for copilot, etc.)
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          ---@diagnostic disable-next-line: no-unknown
          CompletionItemKind[provider.kind] = kind_idx

          ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
          local transform_items = provider.transform_items
          ---@param ctx blink.cmp.Context
          ---@param items blink.cmp.CompletionItem[]
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
              item.kind_icon = Util.config.icons.kinds[item.kind_name] or item.kind_icon or nil
            end
            return items
          end

          -- Unset custom prop to pass blink.cmp validation
          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },
}

--[[
  Usage Notes:

  1. Snippets are the highest priority completion source
  2. Type 2+ characters to trigger completion
  3. <C-Space> to manually trigger completion and show documentation
  4. <Tab> and <S-Tab> to navigate between snippet placeholders
  5. <C-y> for quick accept without triggering completion

  Troubleshooting:

  - If completion is slow: Check which LSP servers are running
  - If snippets don't appear: Verify filetype with `:echo &filetype`
  - If LSP completions needed: Add language to per_filetype configuration
  - If friendly-snippets needed: Enable after investigating loading issue

  Performance Tuning:

  - Increase keyword_length if too aggressive
  - Decrease buffer max_items if still slow
  - Add more languages to per_filetype as needed
  - Re-enable documentation auto_show if performance allows
--]]
