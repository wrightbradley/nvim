local system = require("ai.prompts.system")

return {
  ["Add Docstrings"] = {
    strategy = "inline",
    description = "Add documentation to the selected code.",
    opts = { short_name = "document", modes = { "v" }, auto_submit = true },
    prompts = {
      {
        role = "system",
        content = "You are an expert at writing code documentation. Add documentation to the provided code, adhering to the standard format for the language. Return only the modified code.",
      },
      {
        role = "user",
        content = function(context)
          return "Please add documentation to this code:\n\n```"
            .. context.filetype
            .. "\n"
            .. require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
            .. "\n```"
        end,
      },
    },
  },
  ["Inline Document"] = {
    strategy = "inline",
    description = "Add documentation for code.",
    opts = {
      modes = { "v" },
      short_name = "inline-doc",
      auto_submit = true,
      user_prompt = false,
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = "user",
        content = function(context)
          local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

          return "Please provide documentation in comment code for the following code and suggest to have better naming to improve readability.\n\n```"
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
  ["Document"] = {
    strategy = "chat",
    description = "Write documentation for code.",
    opts = {
      modes = { "v" },
      short_name = "doc",
      auto_submit = true,
      user_prompt = false,
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = "user",
        content = function(context)
          local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

          return "Please brief how it works and provide documentation in comment code for the following code. Also suggest to have better naming to improve readability.\n\n```"
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
  ["Review"] = {
    strategy = "chat",
    description = "Review the provided code snippet.",
    opts = {
      modes = { "v" },
      short_name = "review",
      auto_submit = true,
      user_prompt = false,
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = "system",
        content = system.copilot_review(),
        opts = {
          visible = false,
        },
      },
      {
        role = "user",
        content = function(context)
          local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

          return "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability:\n\n```"
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
  ["Review Code"] = {
    strategy = "chat",
    description = "Review code and provide suggestions for improvement.",
    opts = {
      short_name = "review-code",
      auto_submit = false,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = "system",
        content = system.copilot_review(),
        opts = {
          visible = false,
        },
      },
      {
        role = "user",
        content = "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability.",
      },
    },
  },
}
