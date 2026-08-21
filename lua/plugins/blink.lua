--[[
  Blink.cmp Configuration

  Sources strategy:
  - LSP, snippets, path, and buffer enabled globally. Modern blink.cmp
    handles slow LSP servers gracefully (async, debounced), so there is no
    need to disable LSP per-filetype.
  - lazydev is added for Lua (Neovim config development).
  - friendly-snippets is enabled and loaded from this config's snippets/
    directory plus the friendly-snippets collection.
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
      "rafamadriz/friendly-snippets",
      {
        "saghen/blink.compat",
        optional = true, -- make optional so it's only enabled if any extras need it
        opts = {},
      },
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
        -- Use the bundled Rust fuzzy matcher (faster than the default Lua fzy)
        fuzzy = {
          implementation = "rust",
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
            winblend = 0,
          },
          -- Auto-show documentation after a short delay; <C-Space> toggles manually
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 300,
          },
          -- Ghost text enabled (minimal performance impact)
          ghost_text = {
            enabled = true,
          },
          trigger = {
            show_on_insert_on_trigger_character = true,
            prefetch_on_insert = true,
            show_in_snippet = true,
          },
        },
        signature = {
          enabled = true,
        },
        sources = {
          compat = {}, -- For nvim-cmp source compatibility
          default = { "lsp", "snippets", "path", "buffer" },

          providers = {
            -- Snippets configuration
            snippets = {
              opts = {
                friendly_snippets = true,
                search_paths = { vim.fn.stdpath("config") .. "/snippets" },
              },
              score_offset = 100, -- Highest priority - snippets first
            },

            -- Buffer source: context-aware suggestions, kept modest in size
            buffer = {
              max_items = 5,
              min_keyword_length = 3,
              score_offset = -50, -- Lower priority than LSP/snippets
            },

            -- LazyDev for lua development
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },

          per_filetype = {
            -- Lua: add LazyDev for Neovim config development
            lua = { "snippets", "lsp", "path", "buffer", "lazydev" },
          },
        },

        -- Command line completion (LazyVim v15+ default)
        cmdline = {
          enabled = true,
          keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
          completion = {
            list = { selection = { preselect = false } },
            menu = {
              auto_show = function(_ctx)
                return vim.fn.getcmdtype() == ":"
              end,
            },
            ghost_text = { enabled = true },
          },
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

      -- Add Tab key behavior for snippet navigation
      if not opts.keymap["<Tab>"] then
        opts.keymap["<Tab>"] = {
          function()
            -- Snippet navigation
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
              return true
            end
          end,
          "fallback",
        }
      end

      -- Unset custom prop to pass blink.cmp validation
      opts.sources.compat = nil

      -- Handle custom completion item kinds
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

  1. Sources: LSP > snippets > path > buffer (via score_offsets)
  2. <C-Space> to manually trigger completion and toggle documentation
  3. <Tab> and <S-Tab> to navigate between snippet placeholders
  4. <C-y> for quick accept without triggering completion

  Troubleshooting:

  - If completion is slow: check which LSP servers are running (`:LspInfo`)
  - If snippets don't appear: verify filetype with `:echo &filetype`
  - To customize sources for a specific filetype, add an entry to
    `sources.per_filetype` (see the `lua` entry for an example)
--]]
