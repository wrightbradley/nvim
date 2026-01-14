---@type vim.lsp.Config
return {
  init_options = {
    provideFormatter = true,
  },
  before_init = function(_, config)
    config.settings.json.schemas = require("schemastore").json.schemas()
  end,
  settings = {
    json = {
      format = {
        enable = true,
      },
      validate = { enable = true },
    },
  },
}
