local function safe_require(module_path)
  local ok, module = pcall(require, module_path)
  if not ok or type(module) ~= "table" then
    vim.notify(
      "Error loading module: " .. module_path .. ". Got " .. type(module) .. " instead of table.",
      vim.log.levels.ERROR
    )
    return {}
  end
  return module
end

local agent_workflows = safe_require("ai.prompts.workflows")
local doc_prompts = safe_require("ai.prompts.documentation")
local gen_prompts = safe_require("ai.prompts.code_gen")
local git_prompts = safe_require("ai.prompts.git")
local system = safe_require("ai.prompts.system")

local library = {
  ["Explain"] = {
    strategy = "chat",
    description = "Explain how code in a buffer works",
    opts = {
      default_prompt = true,
      modes = { "v" },
      short_name = "explain",
      auto_submit = true,
      user_prompt = false,
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = "system",
        content = system.copilot_explain(),
        opts = {
          visible = false,
        },
      },
      {
        role = "user",
        content = function(context)
          local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

          return "Please explain how the following code works:\n\n```"
            .. context.filetype
            .. "\n"
            .. code
            .. "\n```\n\n"
        end,
        opts = {
          contains_code = true,
        },
      },
    },
  },
  ["Explain Code"] = {
    strategy = "chat",
    description = "Explain how code works",
    opts = {
      short_name = "explain-code",
      auto_submit = false,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = "system",
        content = system.copilot_explain(),
        opts = {
          visible = false,
        },
      },
      {
        role = "user",
        content = [[Please explain how the following code works.]],
      },
    },
  },
  -- Default Fix prompt
  ["Fix Code"] = {
    strategy = "chat",
    description = "Propose a fix for the selected code",
    opts = { short_name = "fix", modes = { "v" } },
    -- You can add a system prompt here if needed
  },
  -- Default Tests prompt
  ["Generate Tests"] = {
    strategy = "chat",
    description = "Generate unit tests for the selected code",
    opts = { short_name = "tests", modes = { "v" } },
  },
  ["Naming"] = {
    strategy = "inline",
    description = "Give betting naming for the provided code snippet.",
    opts = {
      modes = { "v" },
      short_name = "naming",
      auto_submit = true,
      user_prompt = false,
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = "user",
        content = function(context)
          local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

          return "Please provide better names for the following variables and functions:\n\n```"
            .. context.filetype
            .. "\n"
            .. code
            .. "\n```\n\n"
        end,
        opts = {
          contains_code = true,
        },
      },
    },
  },
  ["Better Naming"] = {
    strategy = "chat",
    description = "Give betting naming for the provided code snippet.",
    opts = {
      short_name = "better-naming",
      auto_submit = false,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = "user",
        content = "Please provide better names for the following variables and functions.",
      },
    },
  },
}

-- Defensive merge - verify each module is a table before merging
local function safe_merge(...)
  local result = {}
  local args = { ... }

  for i, module in ipairs(args) do
    if type(module) == "table" then
      result = vim.tbl_deep_extend("force", result, module)
    else
      vim.notify("Cannot merge item at index " .. i .. ": expected table, got " .. type(module), vim.log.levels.ERROR)
    end
  end

  return result
end

return safe_merge(library, git_prompts, doc_prompts, gen_prompts, agent_workflows)
