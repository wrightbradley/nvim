---@file nvim-lspconfig plugin configuration
--- This file configures the `nvim-lspconfig` plugin for setting up LSP servers in Neovim.
--- It sets up diagnostics, inlay hints, and server-specific configurations.

-- Main plugin configuration
return {
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
  },
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    -- event = "LazyFile",
    lazy = false,
    dependencies = {
      "mason.nvim",
      "b0o/SchemaStore.nvim",
    },
    -- Enable autocompletion for Go LSP servers
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "gopls" and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end,
        pattern = "*.go",
      })
    end,
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            -- Use function that returns diagnostics icon based on severity
            prefix = function(diagnostic)
              local icons = Util.config.icons.diagnostics
              for d, icon in pairs(icons) do
                if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                  return icon
                end
              end
            end,
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
        -- Inlay hints configuration for Neovim 0.11+
        inlay_hints = {
          enabled = true,
          exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
        },
        -- Code lens configuration for Neovim 0.11+
        codelens = {
          enabled = true,
        },
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- options for vim.lsp.buf.format
        -- `bufnr` and `filter` is handled by the Util formatter,
        -- but can be also overridden when specified
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP keymaps configuration
        keymaps = {
          -- LSP keymaps configuration
          mapping = {
            ["<leader>cl"] = { cmd = "LspInfo", desc = "Lsp Info" },
            ["gd"] = {
              handler = function()
                Snacks.picker.lsp_definitions()
              end,
              desc = "Goto Definition",
              method = "definition",
            },
            ["gE"] = {
              cmd = "Glance definitions",
              desc = "Glance D[e]finition",
            },
            ["gr"] = {
              handler = function()
                Snacks.picker.lsp_references()
              end,
              desc = "References",
              nowait = true,
            },
            ["gR"] = {
              cmd = "Glance references",
              desc = "Glance References",
              nowait = true,
            },
            ["gI"] = {
              handler = function()
                Snacks.picker.lsp_implementations()
              end,
              desc = "Goto Implementation",
              method = "implementation",
            },
            ["gM"] = {
              cmd = "Glance implementations",
              desc = "Glance I[m]plementation",
              method = "implementation",
            },
            ["gy"] = {
              handler = function()
                Snacks.picker.lsp_type_definitions()
              end,
              desc = "Goto T[y]pe Definition",
              method = "typeDefinition",
            },
            ["gY"] = {
              cmd = "Glance type_definitions",
              desc = "Glances T[y]pe Definitions",
              nowait = true,
            },
            ["gD"] = {
              handler = function()
                vim.lsp.buf.declaration()
              end,
              desc = "Goto Declaration",
              method = "declaration",
            },
            ["K"] = {
              handler = function()
                vim.lsp.buf.hover()
              end,
              desc = "Hover",
              method = "hover",
            },
            ["gK"] = {
              handler = function()
                vim.lsp.buf.signature_help()
              end,
              desc = "Signature Help",
              method = "signatureHelp",
            },
            ["<c-k>"] = {
              handler = function()
                vim.lsp.buf.signature_help()
              end,
              desc = "Signature Help",
              method = "signatureHelp",
              mode = "i",
            },
            ["<leader>ca"] = {
              handler = function()
                vim.lsp.buf.code_action()
              end,
              desc = "Code Action",
              method = "codeAction",
              mode = { "n", "v" },
            },
            ["<leader>cc"] = {
              handler = function()
                vim.lsp.codelens.run()
              end,
              desc = "Run Codelens",
              method = "codeLens",
              mode = { "n", "v" },
            },
            ["<leader>cC"] = {
              handler = function()
                vim.lsp.codelens.refresh()
              end,
              desc = "Refresh & Display Codelens",
              method = "codeLens",
              mode = { "n" },
            },
            ["<leader>cR"] = {
              handler = function()
                Snacks.rename.rename_file()
              end,
              desc = "Rename File",
              method = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
              mode = { "n" },
            },
            ["<leader>cr"] = {
              handler = function()
                vim.lsp.buf.rename()
              end,
              desc = "Rename",
              method = "rename",
            },
            ["<leader>cA"] = {
              handler = function()
                Util.lsp.action.source()
              end,
              desc = "Source Action",
              method = "codeAction",
            },
            ["<leader>ss"] = {
              handler = function()
                Snacks.picker.lsp_symbols({ filter = Util.config.kind_filter })
              end,
              desc = "LSP Symbols",
              method = "documentSymbol",
            },
            ["<leader>sS"] = {
              handler = function()
                Snacks.picker.lsp_workspace_symbols({ filter = Util.config.kind_filter })
              end,
              desc = "LSP Workspace Symbols",
              method = "workspace/symbols",
            },
            ["]]"] = {
              handler = function()
                Snacks.words.jump(vim.v.count1)
              end,
              desc = "Next Reference",
              method = "documentHighlight",
              cond = function()
                return Snacks.words.is_enabled()
              end,
            },
            ["[["] = {
              handler = function()
                Snacks.words.jump(-vim.v.count1)
              end,
              desc = "Prev Reference",
              method = "documentHighlight",
              cond = function()
                return Snacks.words.is_enabled()
              end,
            },
            ["<a-n>"] = {
              handler = function()
                Snacks.words.jump(vim.v.count1, true)
              end,
              desc = "Next Reference",
              method = "documentHighlight",
              cond = function()
                return Snacks.words.is_enabled()
              end,
            },
            ["<a-p>"] = {
              handler = function()
                Snacks.words.jump(-vim.v.count1, true)
              end,
              desc = "Prev Reference",
              method = "documentHighlight",
              cond = function()
                return Snacks.words.is_enabled()
              end,
            },
          },
        },
        -- LSP Server Settings
        ---@type table<string, vim.lsp.ClientConfig>
        ---@diagnostic disable: missing-fields
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
          eslint = {
            settings = {
              -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
              workingDirectories = { mode = "auto" },
              format = true,
            },
          },
          -- Helm LSP configuration
          helm_ls = {},
          -- YAML Language Server configuration
          yamlls = {
            settings = {
              redhat = { telemetry = { enabled = false } },
              yaml = {
                keyOrdering = false,
                format = {
                  enable = true,
                },
                validate = true,
                schemaStore = {
                  -- Must disable built-in schemaStore support to use
                  -- schemas from SchemaStore.nvim plugin
                  enable = false,
                  -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                  url = "",
                },
              },
            },
            -- Have to add this for yamlls to understand that we support line folding
            capabilities = {
              textDocument = {
                foldingRange = {
                  dynamicRegistration = false,
                  lineFoldingOnly = true,
                },
              },
            },
          },
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
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
          -- YAMLls setup for Helm and schemastore integration
          yamlls = function(server, opts)
            -- Ensure yaml-language-server is available
            if vim.fn.executable("yaml-language-server") ~= 1 then
              -- Try using Mason's binary
              local mason_registry = require("mason-registry")
              if mason_registry.is_installed("yaml-language-server") then
                local package = mason_registry.get_package("yaml-language-server")
                local install_path = package:get_install_path()
                opts.cmd = { install_path .. "/node_modules/.bin/yaml-language-server", "--stdio" }
              end
            end

            -- Load schemas from schemastore
            local status_ok, schemastore = pcall(require, "schemastore")
            if status_ok then
              opts.settings.yaml.schemas =
                vim.tbl_deep_extend("force", opts.settings.yaml.schemas or {}, schemastore.yaml.schemas())
            end

            -- Configure and enable the server with the new API
            vim.lsp.config(server, opts)
            vim.lsp.enable(server)

            -- Handle Helm files
            Util.lsp.on_attach(function(client, buffer)
              if vim.bo[buffer].filetype == "helm" then
                vim.schedule(function()
                  -- Stop YAML LS for Helm files to avoid conflicts
                  client.stop()
                end)
              end
            end, "yamlls")

            -- Return true to indicate we've handled the configuration
            return true
          end,
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- setup autoformat
      Util.format.register(Util.lsp.formatter())

      -- Setup LSP keymaps
      local function has_capability(client, method)
        if not client or not method then
          return true -- Default to true if no client or method is specified
        end

        if type(method) == "table" then
          for _, m in ipairs(method) do
            if has_capability(client, m) then
              return true
            end
          end
          return false
        end

        method = method:find("/") and method or "textDocument/" .. method
        return client.supports_method(method)
      end

      Util.lsp.on_attach(function(client, buffer)
        -- Apply keymap for LSP clients
        for lhs, mapping in pairs(opts.keymaps.mapping) do
          local method = mapping.method
          local mode = mapping.mode or "n"

          -- Only set up keymap if client supports the required method (if specified)
          if has_capability(client, method) then
            -- Skip if conditional is provided and returns false
            if mapping.cond == nil or (type(mapping.cond) == "function" and mapping.cond()) then
              -- Set up the keymap
              vim.keymap.set(mode, lhs, function()
                if mapping.cmd then
                  vim.cmd(mapping.cmd)
                elseif mapping.handler then
                  mapping.handler()
                end
              end, {
                buffer = buffer,
                silent = mapping.silent ~= false,
                nowait = mapping.nowait,
                desc = mapping.desc,
              })
            end
          end
        end
      end)

      Util.lsp.setup()

      -- Define diagnostic signs - Neovim 0.11 doesn't need conditional checks
      for severity, icon in pairs(opts.diagnostics.signs.text) do
        local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end

      -- inlay hints - directly use the 0.11 APIs
      if opts.inlay_hints.enabled then
        Util.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- code lens - directly use the 0.11 APIs
      if opts.codelens.enabled and vim.lsp.codelens then
        Util.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- Apply the diagnostic configuration
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      -- Configure each server using the new vim.lsp.config and vim.lsp.enable APIs
      for server, server_opts in pairs(opts.servers) do
        if server_opts then
          -- Prepare server options (handle true = {} case)
          server_opts = server_opts == true and {} or server_opts

          -- Skip if explicitly disabled
          if server_opts.enabled ~= false then
            -- Apply capabilities
            local config_opts = vim.tbl_deep_extend("force", {
              capabilities = vim.deepcopy(capabilities),
            }, server_opts)

            -- Handle special server setup cases via the setup table
            if opts.setup[server] then
              if opts.setup[server](server, config_opts) then
                goto continue
              end
            elseif opts.setup["*"] and opts.setup["*"](server, config_opts) then
              goto continue
            end

            -- Configure and enable the server with the new API
            vim.lsp.config(server, config_opts)
            vim.lsp.enable(server)
          end

          ::continue::
        end
      end
    end,
  },
}
