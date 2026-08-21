---@file TypeScript/JavaScript configuration
--- LSP config is in after/lsp/vtsls.lua
--- This file handles DAP and TypeScript-specific keymaps

return {
  -- TypeScript-specific LSP keymaps
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      setup = {
        vtsls = function()
          Util.lsp.on_attach(function(_client, buffer)
            local function map(lhs, rhs, desc)
              vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
            end

            -- TypeScript-specific commands
            map("gD", function()
              local params = vim.lsp.util.make_position_params()
              Util.lsp.execute({
                command = "typescript.goToSourceDefinition",
                arguments = { params.textDocument.uri, params.position },
                open = true,
              })
            end, "Goto Source Definition")

            map("gR", function()
              Util.lsp.execute({
                command = "typescript.findAllFileReferences",
                arguments = { vim.uri_from_bufnr(0) },
                open = true,
              })
            end, "File References")

            map("<leader>co", Util.lsp.action["source.organizeImports"], "Organize Imports")
            map("<leader>cM", Util.lsp.action["source.addMissingImports.ts"], "Add missing imports")
            map("<leader>cu", Util.lsp.action["source.removeUnused.ts"], "Remove unused imports")
            map("<leader>cD", Util.lsp.action["source.fixAll.ts"], "Fix all diagnostics")
            map("<leader>cV", function()
              Util.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
            end, "Select TS workspace version")
          end, "vtsls")
        end,
      },
    },
  },

  -- TypeScript DAP configuration
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "js-debug-adapter")
        end,
      },
    },
    opts = function()
      local dap = require("dap")
      if not dap.adapters["pwa-node"] then
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              Util.get_pkg_path("js-debug-adapter", "/js-debug/src/dapDebugServer.js"),
              "${port}",
            },
          },
        }
      end
      if not dap.adapters["node"] then
        dap.adapters["node"] = function(cb, config)
          if config.type == "node" then
            config.type = "pwa-node"
          end
          local nativeAdapter = dap.adapters["pwa-node"]
          if type(nativeAdapter) == "function" then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },
}
