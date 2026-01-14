---@type vim.lsp.Config
return {
  on_attach = function(client, bufnr)
    -- Ensure client has the workspace notification method before kubeschema tries to use it
    if not client.workspace_did_change_configuration then
      client.workspace_did_change_configuration = function(settings)
        client.notify("workspace/didChangeConfiguration", { settings = settings or nil })
      end
    end

    -- Lazy-load kubeschema only when yamlls attaches (i.e., when a YAML file is opened)
    local has_kubeschema, kubeschema = pcall(require, "kubeschema")
    if has_kubeschema then
      kubeschema.on_attach(client, bufnr)
    end
  end,
  before_init = function(_, config)
    -- Add SchemaStore schemas for common YAML files (GitHub Actions, docker-compose, etc.)
    config.settings.yaml.schemas = require("schemastore").yaml.schemas()
  end,
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = {
        enable = false,
      },
      validate = true,
      schemas = {}, -- Will be populated by SchemaStore in before_init
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
    workspace = {
      didChangeConfiguration = {
        -- kubeschema.nvim relies on workspace.didChangeConfiguration to implement dynamic schema loading of yamlls.
        dynamicRegistration = true,
      },
    },
  },
}
