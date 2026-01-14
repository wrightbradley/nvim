---@file LSP Configuration for Neovim 0.11+
--- Uses native vim.lsp.config() with server configs in after/lsp/
--- mason-lspconfig handles installation and automatic enabling

return {
  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
      {
        "b0o/SchemaStore.nvim", -- JSON and YAML schema validation
        ft = { "json", "jsonc", "yaml", "yml" },
      },
    },

    -- Initialize Go LSP completion support
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          -- Enable enhanced completion for Go language server
          if client and client.name == "gopls" and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end,
        pattern = "*.go",
      })
    end,

    opts = function()
      ---@class PluginLspOpts
      return {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "icons",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = Util.config.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = Util.config.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = Util.config.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = Util.config.icons.diagnostics.Info,
            },
          },
        },
        -- Inlay hints configuration
        inlay_hints = {
          enabled = true,
          exclude = { "vue" },
        },
        -- Code lens configuration
        codelens = {
          enabled = true,
        },
        -- LSP-based folding
        folds = {
          enabled = true,
        },
        -- options for vim.lsp.buf.format
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- Servers to ensure are installed (mason-lspconfig handles enabling)
        servers = {
          "lua_ls",
          "gopls",
          "yamlls",
          "vtsls",
          "jsonls",
          "pyright", -- For hover/type information (ty handles diagnostics)
          "ruff",
          "eslint",
          "bashls",
          "ansiblels",
          "tailwindcss",
          "helm_ls",
          "taplo",
          "jqls",
          "tofu_ls",
          "vale_ls",
          "dockerls",
          "marksman",
          "terraformls",
          "dagger",
        },
        -- Servers NOT managed by mason (enabled manually)
        manual_servers = { "ty" },
        -- Special setup functions for servers that need extra handling
        setup = {
          eslint = function()
            local formatter = Util.lsp.formatter({
              name = "eslint: lsp",
              primary = false,
              priority = 200,
              filter = "eslint",
            })
            -- register the formatter
            Util.format.register(formatter)
          end,
          vtsls = function()
            Util.lsp.on_attach(function(client, _)
              client.commands["_typescript.moveToFileRefactoring"] = function(command, _)
                local action, uri, range = unpack(command.arguments)
                local function move(newf)
                  client.request("workspace/executeCommand", {
                    command = command.command,
                    arguments = { action, uri, range, newf },
                  })
                end
                local fname = vim.uri_to_fname(uri)
                client.request("workspace/executeCommand", {
                  command = "typescript.tsserverRequest",
                  arguments = {
                    "getMoveToRefactoringFileSuggestions",
                    {
                      file = fname,
                      startLine = range.start.line + 1,
                      startOffset = range.start.character + 1,
                      endLine = range["end"].line + 1,
                      endOffset = range["end"].character + 1,
                    },
                  },
                }, function(_, result)
                  local files = result.body.files
                  table.insert(files, 1, "Enter new path...")
                  vim.ui.select(files, {
                    prompt = "Select move destination:",
                    format_item = function(f)
                      return vim.fn.fnamemodify(f, ":~:.")
                    end,
                  }, function(f)
                    if f and f:find("^Enter new path") then
                      vim.ui.input({
                        prompt = "Enter move destination:",
                        default = vim.fn.fnamemodify(fname, ":h") .. "/",
                        completion = "file",
                      }, function(newf)
                        return newf and move(newf)
                      end)
                    elseif f then
                      move(f)
                    end
                  end)
                end)
              end
            end, "vtsls")
          end,
          gopls = function()
            Util.lsp.on_attach(function(client, _)
              -- workaround for gopls not supporting semanticTokensProvider
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end, "gopls")
          end,
          ruff = function()
            Util.lsp.on_attach(function(client, _)
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end, "ruff")
          end,
          pyright = function()
            Util.lsp.on_attach(function(client, _)
              -- Pyright only provides hover (better type info than ty's "Unknown")
              -- ty handles everything else (diagnostics, navigation, completion, etc.)
              client.server_capabilities.diagnosticProvider = nil
              client.server_capabilities.publishDiagnostics = false
              -- Disable navigation to let ty handle it
              client.server_capabilities.definitionProvider = false
              client.server_capabilities.declarationProvider = false
              client.server_capabilities.typeDefinitionProvider = false
              client.server_capabilities.referencesProvider = false
              client.server_capabilities.implementationProvider = false
              client.server_capabilities.renameProvider = false
              client.server_capabilities.codeActionProvider = false
              client.server_capabilities.completionProvider = nil
            end, "pyright")
          end,
          ty = function()
            Util.lsp.on_attach(function(client, _)
              -- ty handles everything except hover (shows "Unknown" for many types)
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end, "ty")
          end,
        },
      }
    end,

    ---@param opts PluginLspOpts
    config = vim.schedule_wrap(function(_, opts)
      -- setup autoformat
      Util.format.register(Util.lsp.formatter())

      -- Diagnostics: handle "icons" shorthand
      if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
        opts.diagnostics.virtual_text.prefix = function(diagnostic)
          local icons = Util.config.icons.diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return "●"
        end
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Global LSP capabilities
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_blink and blink.get_lsp_capabilities() or {},
        {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        }
      )
      vim.lsp.config("*", {
        capabilities = vim.deepcopy(capabilities),
      })

      -- Setup special handlers
      for _, setup_fn in pairs(opts.setup) do
        setup_fn()
      end

      -- LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local buffer = args.buf
          if not client then
            return
          end

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buffer, silent = true, desc = desc })
          end

          -- Navigation
          map("n", "<leader>cl", function()
            Snacks.picker.lsp_config()
          end, "Lsp Info")
          map("n", "gd", function()
            Snacks.picker.lsp_definitions()
          end, "Goto Definition")
          map("n", "gr", function()
            Snacks.picker.lsp_references()
          end, "References")
          map("n", "gI", function()
            Snacks.picker.lsp_implementations()
          end, "Goto Implementation")
          map("n", "gy", function()
            Snacks.picker.lsp_type_definitions()
          end, "Goto Type Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>ss", function()
            Snacks.picker.lsp_symbols({ filter = Util.config.kind_filter })
          end, "LSP Symbols")
          map("n", "<leader>sS", function()
            Snacks.picker.lsp_workspace_symbols({ filter = Util.config.kind_filter })
          end, "LSP Workspace Symbols")
          map("n", "gai", function()
            Snacks.picker.lsp_incoming_calls()
          end, "Calls Incoming")
          map("n", "gao", function()
            Snacks.picker.lsp_outgoing_calls()
          end, "Calls Outgoing")

          -- Actions
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>cA", function()
            Util.lsp.action.source()
          end, "Source Action")
          map("n", "<leader>cR", function()
            Snacks.rename.rename_file()
          end, "Rename File")

          -- Capability-specific keymaps
          if client:supports_method("textDocument/signatureHelp") then
            map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
            map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
          end
          if client:supports_method("textDocument/codeLens") then
            map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
            map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh Codelens")
          end
          if Snacks.words.is_enabled() and client:supports_method("textDocument/documentHighlight") then
            map("n", "]]", function()
              Snacks.words.jump(vim.v.count1)
            end, "Next Reference")
            map("n", "[[", function()
              Snacks.words.jump(-vim.v.count1)
            end, "Prev Reference")
            map("n", "<a-n>", function()
              Snacks.words.jump(vim.v.count1, true)
            end, "Next Reference")
            map("n", "<a-p>", function()
              Snacks.words.jump(-vim.v.count1, true)
            end, "Prev Reference")
          end
        end,
      })

      -- Inlay hints
      if opts.inlay_hints.enabled then
        Util.lsp.on_supports_method("textDocument/inlayHint", function(_, buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- Code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        Util.lsp.on_supports_method("textDocument/codeLens", function(_, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- LSP-based folding
      if opts.folds.enabled then
        Util.lsp.on_supports_method("textDocument/foldingRange", function(_, buffer)
          local win = vim.fn.bufwinid(buffer)
          if win ~= -1 and vim.wo[win].foldmethod == "manual" then
            vim.wo[win].foldmethod = "expr"
            vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
          end
        end)
      end

      -- Initialize LSP utilities
      Util.lsp.setup()

      -- Enable manually-managed servers (not in mason)
      for _, server in ipairs(opts.manual_servers) do
        vim.lsp.enable(server)
      end

      -- mason-lspconfig handles ensure_installed and automatic_enable
      if Util.has("mason-lspconfig.nvim") then
        require("mason-lspconfig").setup({
          ensure_installed = opts.servers,
          automatic_enable = true,
        })
      end
    end),
  },
}
