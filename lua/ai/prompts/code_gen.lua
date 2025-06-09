local system = require("ai.prompts.system")

return {
  ["Generate API Client"] = {
    strategy = "chat",
    description = "Generate a typed TypeScript API client from a schema.",
    opts = { short_name = "api_client" },
    prompts = {
      {
        role = "user",
        content = [[
### Goal
Generate a TypeScript API client using `fetch` based on the provided OpenAPI schema.
### Plan
1.  Create typed interfaces for each schema definition.
2.  Create an async function for each endpoint.
3.  Provide the complete, ready-to-use code in a single block.
### API Schema
<paste_schema_here>
]],
      },
    },
  },
  ["Generate Mock Data"] = {
    strategy = "chat",
    description = "Generate mock data from a type/interface.",
    opts = { short_name = "mock" },
    prompts = {
      {
        role = "user",
        content = [[
### Goal
Based on the TypeScript interface below, generate an array of 5 realistic mock objects. Return the data as a `const` array.
### TypeScript Interface
```typescript
{{selection}}
]],
      },
    },
  },
  ["Refactor"] = {
    strategy = "inline",
    description = "Refactor the provided code snippet.",
    opts = {
      modes = { "v" },
      short_name = "refactor",
      auto_submit = true,
      user_prompt = false,
      stop_context_insertion = true,
    },
    prompts = {
      {
        role = "system",
        content = system.copilot_refactor(),
        opts = {
          visible = false,
        },
      },
      {
        role = "user",
        content = function(context)
          local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

          return "Please refactor the following code to improve its clarity and readability:\n\n```"
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
  ["Refactor Code"] = {
    strategy = "chat",
    description = "Refactor the provided code snippet.",
    opts = {
      short_name = "refactor-code",
      auto_submit = false,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = "system",
        content = system.copilot_refactor(),
        opts = {
          visible = false,
        },
      },
      {
        role = "user",
        content = "Please refactor the following code to improve its clarity and readability.",
      },
    },
  },
}
