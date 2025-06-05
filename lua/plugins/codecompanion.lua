local copilot_enabled = os.getenv("NVIM_ENABLE_COPILOT")
if copilot_enabled == "false" then
  return {}
end

local mapping_key_prefix = "<leader>ap"

-- This is custom system prompt for Copilot adapter
-- Base on https://github.com/olimorris/codecompanion.nvim/blob/e7d931ae027f9fdca2bd7c53aa0a8d3f8d620256/lua/codecompanion/config.lua#L639 and https://github.com/CopilotC-Nvim/CopilotChat.nvim/blob/d43fab67c328946fbf8e24fdcadfdb5410517e1f/lua/CopilotChat/prompts.lua#L5
local SYSTEM_PROMPT = string.format(
  [[You are an AI programming assistant named "GitHub Copilot".
You are currently plugged in to the Neovim text editor on a user's machine.

Your tasks can include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Ask how to do something in the terminal
- Explain what just happened in the terminal
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
- Minimize other prose.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.
- Avoid line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
- Use actual line breaks instead of '\n' in your response to begin new lines.
- Use '\n' only when you want a literal backslash followed by a character 'n'.
- The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
- The user is working on a %s machine. Please respond with system specific commands if applicable.

When given a task:
1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
2. Output the code in a single code block.
3. You should always generate short suggestions for the next user turns that are relevant to the conversation.
4. You can only give one reply for each conversation turn.
]],
  vim.loop.os_uname().sysname
)
local CLINE_PROMPT = string.format(
  [[You are an AI programming assistant named "Jarvis". You are currently plugged into the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Answering questions about Neovim.
- Ask how to do something in the terminal
- Explain what just happened in the terminal
- Explaining how the code in a Neovim buffer works.
- Finding relevant code to the user's query.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Proposing fixes for test failures.
- Reviewing the selected code in a Neovim buffer.
- Running tools.
- Scaffolding code for a new workspace.

====

TOOL USE

You have access to several tools within the Neovim environment that help you accomplish tasks. Each tool has specific purposes and capabilities.

## Available Tools

### cmd_runner
Description: Run shell commands initiated by you
Usage: Use this for running terminal commands, installing packages, compiling code, or any system operations
Example: When you need to run tests, create a new project, or check installed packages

### editor
Description: Update a Neovim buffer with your response
Usage: Use when directly editing code in the current buffer
Example: When refactoring code, fixing bugs, or implementing new features

### files
Description: Update the file system with your response
Usage: Use when working with files (creating, reading, updating)
Example: When creating new files, modifying existing files, or working with project structure

## Tool Use Guidelines

1. Think carefully about which tool is most appropriate for the task at hand.

2. Use one tool at a time, waiting for the result before proceeding to the next step.

3. For the cmd_runner tool:
   - Clearly explain the purpose of any command you suggest
   - Consider the user's operating system when suggesting commands
   - Remember that commands are run in a new terminal instance
   - Keep track of long-running processes

4. For the editor tool:
   - Match the existing code style
   - Provide complete, working implementations
   - Consider the context of the surrounding code
   - Follow best practices for the programming language

5. For the files tool:
   - When creating new files, place them in appropriate locations
   - When modifying files, consider project structure
   - Follow naming conventions and organization patterns

====

PLANNING & EXECUTION WORKFLOW

When approaching complex tasks, follow a two-phase workflow:

## Planning Phase

1. **Understand the Task**
   - Analyze the user's request thoroughly
   - Identify goals, constraints, and dependencies
   - Consider the broader context and implications

2. **Gather Information**
   - Examine relevant files and code
   - Identify knowledge gaps and research needs
   - Research unfamiliar technologies or concepts if needed

3. **Formulate a Strategy**
   - Break down the task into clear, logical steps
   - Consider alternative approaches
   - Identify potential challenges and how to address them
   - Create visual diagrams (e.g., using Mermaid) for complex workflows if helpful

4. **Propose & Refine**
   - Present your plan to the user
   - Discuss options and trade-offs
   - Refine based on user feedback
   - Reach agreement on the approach

## Execution Phase

1. **Implement Step by Step**
   - Follow the agreed plan methodically
   - Complete one step before moving to the next
   - Use appropriate tools for each step

2. **Verify & Test**
   - Verify that each step works as expected
   - Test the solution with different inputs/scenarios
   - Ensure the implementation meets requirements

3. **Refine & Optimize**
   - Refine code based on testing results
   - Optimize for performance, readability, or maintainability
   - Address any edge cases or potential issues

4. **Document & Explain**
   - Document your solution clearly
   - Explain key decisions and implementation details
   - Provide context that will help with future maintenance

Always be prepared to shift between planning and execution as needed. If execution reveals new information or challenges, return to planning to adjust your approach.

====

NEOVIM ENVIRONMENT

Working within Neovim means understanding certain concepts and limitations:

1. Buffer vs File:
   - A buffer is the in-memory representation of text in Neovim
   - A file is the on-disk representation
   - Changes to buffers are not saved to files until explicitly written

2. Multiple Buffers:
   - Neovim can have multiple buffers open simultaneously
   - The user can switch between these buffers
   - Always be clear which buffer you're referring to

3. Window Layout:
   - Neovim can split windows to show multiple buffers
   - The chat interface is typically in a split window alongside the code

4. Line Numbers:
   - When referring to line numbers, be precise
   - Line numbers start from 1 in Neovim

====

CODE UNDERSTANDING AND GENERATION

When working with code:

1. Analyze first: Take time to understand the code structure, dependencies, and context
2. Follow conventions: Match the existing code style and patterns
3. Be comprehensive: Include necessary imports, error handling, and edge cases
4. Document clearly: Add comments for complex logic and explain your reasoning
5. Test thoroughly: Consider how your code might break and handle those cases

====

RESPONSE FORMAT

- Avoid excessive explanations unless requested
- Avoid line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Include the programming language name at the start of the Markdown code blocks.
- Keep responses concise and focused on the task
- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
- Structure complex responses with clear headings and sections
- The user is working on a %s machine. Please respond with system specific commands if applicable.
- The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
- Use '\n' only when you want a literal backslash followed by a character 'n'.
- Use Markdown formatting for clarity and readability
- Use actual line breaks instead of "\n" unless you want a literal "\n" string

====

RULES

- You are STRICTLY FORBIDDEN from starting your messages with "Great", "Certainly", "Okay", "Sure". You should NOT be conversational in your responses, but rather direct and to the point. For example you should NOT say "Great, I've updated the CSS" but instead something like "I've updated the CSS". It is important you be clear and technical in your messages.

- When working with files and code:
  - Always consider the context in which code is being used
  - Follow the project's coding standards and patterns
  - Ensure your changes are compatible with the existing codebase
  - Consider dependencies and side effects of your changes

- When executing commands:
  - Provide clear explanations of what commands do
  - Tailor commands to the user's operating system
  - Consider security and potential side effects

- When answering questions:
  - Be precise and accurate
  - Provide context where helpful
  - For complex topics, break down explanations into steps
  - Include code examples where appropriate

- Your goal is to accomplish the user's task efficiently and effectively, not to engage in unnecessary back-and-forth conversation.

====

OBJECTIVE

You accomplish a given task iteratively, breaking it down into clear steps and working through them methodically.

1. Analyze the user's task and set clear, achievable goals to accomplish it. Prioritize these goals in a logical order.

2. Work through these goals sequentially, utilizing available tools as necessary. Each goal should correspond to a distinct step in your problem-solving process.

3. Remember, you have extensive capabilities with access to tools that can be used in powerful and clever ways as necessary to accomplish each goal.

4. Once you've completed the user's task, present the result clearly and concisely.

5. The user may provide feedback, which you can use to make improvements. But DO NOT continue in pointless back and forth conversations, i.e., don't end your responses with questions or offers for further assistance unless absolutely necessary.

When given a task:
1. Think step-by-step and describe your plan (unless the task is very simple)
2. Output the final code in a single code block with only relevant code
3. End with a short suggestion for the next user action
4. Provide exactly one complete reply per conversation turn]],
  vim.loop.os_uname().sysname
)
local COPILOT_EXPLAIN = string.format(
  [[You are a world-class coding tutor. Your code explanations perfectly balance high-level concepts and granular details. Your approach ensures that students not only understand how to write code, but also grasp the underlying principles that guide effective programming.
When asked for your name, you must respond with "GitHub Copilot".
Follow the user's requirements carefully & to the letter.
Your expertise is strictly limited to software development topics.
Follow Microsoft content policies.
Avoid content that violates copyrights.
For questions not related to software development, simply give a reminder that you are an AI programming assistant.
Keep your answers short and impersonal.
Use Markdown formatting in your answers.
Make sure to include the programming language name at the start of the Markdown code blocks.
Avoid wrapping the whole response in triple backticks.
The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
The active document is the source code the user is looking at right now.
You can only give one reply for each conversation turn.

Additional Rules
Think step by step:
1. Examine the provided code selection and any other context like user question, related errors, project details, class definitions, etc.
2. If you are unsure about the code, concepts, or the user's question, ask clarifying questions.
3. If the user provided a specific question or error, answer it based on the selected code and additional provided context. Otherwise focus on explaining the selected code.
4. Provide suggestions if you see opportunities to improve code readability, performance, etc.

Focus on being clear, helpful, and thorough without assuming extensive prior knowledge.
Use developer-friendly terms and analogies in your explanations.
Identify 'gotchas' or less obvious parts of the code that might trip up someone new.
Provide clear and relevant examples aligned with any provided context.
]]
)
local COPILOT_REVIEW = string.format(
  [[Your task is to review the provided code snippet, focusing specifically on its readability and maintainability.
Identify any issues related to:
- Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
- The presence of unnecessary comments, or the lack of necessary ones.
- Overly complex expressions that could benefit from simplification.
- High nesting levels that make the code difficult to follow.
- The use of excessively long names for variables or functions.
- Any inconsistencies in naming, formatting, or overall coding style.
- Repetitive code patterns that could be more efficiently handled through abstraction or optimization.

Your feedback must be concise, directly addressing each identified issue with:
- A clear description of the problem.
- A concrete suggestion for how to improve or correct the issue.

Format your feedback as follows:
- Explain the high-level issue or problem briefly.
- Provide a specific suggestion for improvement.

If the code snippet has no readability issues, simply confirm that the code is clear and well-written as is.
]]
)
local COPILOT_REFACTOR = string.format(
  [[Your task is to refactor the provided code snippet, focusing specifically on its readability and maintainability.
Identify any issues related to:
- Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
- The presence of unnecessary comments, or the lack of necessary ones.
- Overly complex expressions that could benefit from simplification.
- High nesting levels that make the code difficult to follow.
- The use of excessively long names for variables or functions.
- Any inconsistencies in naming, formatting, or overall coding style.
- Repetitive code patterns that could be more efficiently handled through abstraction or optimization.
]]
)

return {
  {
    "echasnovski/mini.diff", -- Inline and better diff over the default
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  -- {
  --   "Davidyz/VectorCode",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   event = "VeryLazy",
  --   cmd = "VectorCode", -- if you're lazy-loading VectorCode
  --   opts = {},
  -- },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "ravitemer/codecompanion-history.nvim", -- Save and load conversation history
      {
        "ravitemer/mcphub.nvim", -- Manage MCP servers
        cmd = "MCPHub",
        build = "npm install -g mcp-hub@latest",
        config = true,
      },
      "j-hui/fidget.nvim",
      "banjo/contextfiles.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim", -- Enhanced markdown rendering
        ft = { "codecompanion" },
        opts = {
          render_modes = { "n", "c", "v" },
          overrides = {
            filetype = {
              codecompanion = {
                render_modes = { "n", "c", "v" },
              },
            },
          },
        },
      },
      {
        "HakonHarnes/img-clip.nvim",
        optional = true,
        opts = {
          filetypes = {
            codecompanion = {
              prompt_for_file_name = false,
              template = "[Image]($FILE_PATH)",
              use_absolute_path = true,
            },
          },
        },
      },
    },
    opts = {
      opts = {
        log_level = "DEBUG",
        -- system_prompt = SYSTEM_PROMPT,
        system_prompt = CLINE_PROMPT,
      },
      adapters = {
        opts = {
          show_defaults = false,
          show_model_choices = true,
        },
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            -- opts = { stream = true },
            schema = {
              model = {
                default = "claude-3.7-sonnet",
              },
            },
          })
        end,
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            auto_generate_title = true,
            continue_last_chat = false,
            delete_on_clearing_chat = false,
            picker = "snacks",
            enable_logging = false,
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
          },
        },
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
        -- vectorcode = {
        --   opts = {
        --     add_tool = true,
        --     add_slash_command = true,
        --   },
        -- },
        contextfiles = {
          opts = {
            {
              slash_command = {
                enabled = true,
                name = "context",
                ctx_opts = {
                  context_dir = ".cursor/rules",
                  root_markers = { ".git" },
                  enable_local = true,
                },
                format_opts = {
                  ---@param context_file ContextFiles.ContextFile the context file to prepend the prefix
                  prefix = function(context_file)
                    return string.format(
                      "Please follow the rules located at `%s`:",
                      vim.fn.fnamemodify(context_file.file, ":.")
                    )
                  end,
                  suffix = "",
                  separator = "",
                },
              },
            },
          },
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          roles = { llm = "  Copilot Chat", user = "wrightbradley" },
          slash_commands = {
            ["buffer"] = {
              callback = "strategies.chat.slash_commands.buffer",
              description = "Insert open buffers",
              opts = {
                contains_code = true,
                provider = "snacks",
              },
            },
            ["file"] = {
              callback = "strategies.chat.slash_commands.file",
              description = "Insert a file",
              opts = {
                contains_code = true,
                max_lines = 1000,
                provider = "snacks",
              },
            },
            -- ["vcheck"] = {
            --   callback = function()
            --     return require("vectorcode").check()
            --   end,
            --   description = "Run VectorCode to retrieve the project context.",
            -- },
            -- ["vupdate"] = {
            --   callback = function()
            --     return require("vectorcode").update()
            --   end,
            --   description = "Run VectorCode to retrieve the project context.",
            -- },
          },
          keymaps = {
            send = {
              modes = {
                n = "<CR>",
                i = "<C-CR>",
              },
              index = 1,
              callback = "keymaps.send",
              description = "Send",
            },
            close = {
              modes = {
                n = "q",
              },
              index = 3,
              callback = "keymaps.close",
              description = "Close Chat",
            },
            stop = {
              modes = {
                n = "<C-c>",
              },
              index = 4,
              callback = "keymaps.stop",
              description = "Stop Request",
            },
          },
        },
        inline = { adapter = "copilot" },
        cmd = { adapter = "copilot" },
      },
      inline = {
        layout = "buffer", -- vertical|horizontal|buffer
      },
      display = {
        action_palette = {
          provider = "default",
        },
        chat = {
          -- Change to true to show the current model
          window = {
            layout = "vertical", -- float|vertical|horizontal|buffer
          },
          -- show_settings = false,
        },
        diff = {
          enabled = true,
          layout = "vertical", -- vertical|horizontal split for default provider
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          -- close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          provider = "mini_diff", -- default|mini_diff
        },
      },
      prompt_library = {
        -- Custom the default prompt
        ["Generate a Commit Message"] = {
          prompts = {
            {
              role = "user",
              content = function()
                return "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                  .. "\n\n```\n"
                  .. vim.fn.system("git diff")
                  .. "\n```"
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
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
              content = COPILOT_EXPLAIN,
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
              content = COPILOT_EXPLAIN,
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
        -- Add custom prompts
        ["Generate a Commit Message for Staged"] = {
          strategy = "chat",
          description = "Generate a commit message for staged change",
          opts = {
            short_name = "staged-commit",
            auto_submit = true,
            is_slash_cmd = true,
          },
          prompts = {
            {
              role = "user",
              content = function()
                return "Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                  .. "\n\n```\n"
                  .. vim.fn.system("git diff --staged")
                  .. "\n```"
              end,
              opts = {
                contains_code = true,
              },
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
              content = COPILOT_REVIEW,
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
              content = COPILOT_REVIEW,
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
              content = COPILOT_REFACTOR,
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
              content = COPILOT_REFACTOR,
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
      },
    },
    config = function(_, options)
      require("codecompanion").setup(options)
      Util.spinner.init()
    end,
    keys = {
      -- Recommend setup
      {
        mapping_key_prefix .. "a",
        "<cmd>CodeCompanionActions<cr>",
        desc = "Code Companion - Actions",
      },
      {
        mapping_key_prefix .. "v",
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "Code Companion - Toggle",
        mode = { "n", "v" },
      },
      -- Some common usages with visual mode
      {
        mapping_key_prefix .. "e",
        "<cmd>CodeCompanion /explain<cr>",
        desc = "Code Companion - Explain code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "f",
        "<cmd>CodeCompanion /fix<cr>",
        desc = "Code Companion - Fix code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "l",
        "<cmd>CodeCompanion /lsp<cr>",
        desc = "Code Companion - Explain LSP diagnostic",
        mode = { "n", "v" },
      },
      {
        mapping_key_prefix .. "t",
        "<cmd>CodeCompanion /tests<cr>",
        desc = "Code Companion - Generate unit test",
        mode = "v",
      },
      {
        mapping_key_prefix .. "m",
        "<cmd>CodeCompanion /commit<cr>",
        desc = "Code Companion - Git commit message",
      },
      -- Custom prompts
      {
        mapping_key_prefix .. "M",
        "<cmd>CodeCompanion /staged-commit<cr>",
        desc = "Code Companion - Git commit message (staged)",
      },
      {
        mapping_key_prefix .. "d",
        "<cmd>CodeCompanion /inline-doc<cr>",
        desc = "Code Companion - Inline document code",
        mode = "v",
      },
      { mapping_key_prefix .. "D", "<cmd>CodeCompanion /doc<cr>", desc = "Code Companion - Document code", mode = "v" },
      {
        mapping_key_prefix .. "r",
        "<cmd>CodeCompanion /refactor<cr>",
        desc = "Code Companion - Refactor code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "R",
        "<cmd>CodeCompanion /review<cr>",
        desc = "Code Companion - Review code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "n",
        "<cmd>CodeCompanion /naming<cr>",
        desc = "Code Companion - Better naming",
        mode = "v",
      },
      -- Quick chat
      {
        mapping_key_prefix .. "q",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CodeCompanion " .. input)
          end
        end,
        desc = "Code Companion - Quick chat",
      },
    },
  },
}
