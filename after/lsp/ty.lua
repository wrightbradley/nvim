-- Get the virtual environment path if set
local function get_python_path()
  -- Check VIRTUAL_ENV first (set by venv activation or venv-selector)
  local venv = vim.env.VIRTUAL_ENV
  if venv and venv ~= "" then
    return venv
  end
  return nil
end

local python_path = get_python_path()

---@type vim.lsp.Config
return {
  -- ty language server settings
  -- See: https://docs.astral.sh/ty/reference/editor-settings/
  init_options = {
    -- Enable debug logging to troubleshoot issues
    logLevel = "debug",
    logFile = "/tmp/ty.log",
  },
  settings = {
    ty = {
      -- Pass environment config through the `configuration` key
      configuration = python_path and {
        environment = {
          python = python_path,
        },
      } or nil,
    },
  },
}
