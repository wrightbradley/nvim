local copilot_enabled = os.getenv("NVIM_ENABLE_COPILOT")
if copilot_enabled == "false" then
  return {}
end

local mapping_key_prefix = "<leader>ap"

return {
  {
    "echasnovski/mini.diff", -- Inline and better diff over the default
    config = function()
      require("mini.diff").setup({ source = require("mini.diff").gen_source.none() })
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
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ravitemer/codecompanion-history.nvim",
      "kkharji/sqlite.lua",
      {
        "ravitemer/mcphub.nvim",
        cmd = "MCPHub",
        build = "npm install -g mcp-hub@latest",
        config = true,
      },
      "j-hui/fidget.nvim",
      "banjo/contextfiles.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "codecompanion" },
        opts = {
          render_modes = { "n", "c", "v" },
          overrides = {
            filetype = { codecompanion = { render_modes = { "n", "c", "v" } } },
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
        -- system_prompt = CLINE_PROMPT,
        system_prompt = require("ai.prompts.system").cline_prompt(),
      },
      adapters = {
        opts = {
          show_defaults = false,
          show_model_choices = true,
        },
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "gpt-4.1",
              },
            },
          })
        end,
      },
      extensions = {
        analytics = {
          enabled = true,
          callback = function()
            return require("ai.extensions.analytics.analytics")
          end,
          opts = {
            keymap = "gA",
            retention_days = 365,
            -- To show only specific queries in a specific order, uncomment below:
            -- default_queries = {
            --   "Copilot Premium Requests",
            --   "Copilot Premium Requests by Model"
            -- }
            queries = {
              ["Copilot Premium Requests"] = {
                name = "Copilot Premium Requests",
                sql = function(dimension)
                  return string.format(
                    [[SELECT SUM(CASE json_extract(payload, '$.adapter.model')
            WHEN 'gpt-4.5' THEN 50
            WHEN 'gpt-4.1' THEN 0
            WHEN 'gpt-4o' THEN 0
            WHEN 'claude-sonnet-3.5' THEN 1
            WHEN 'claude-sonnet-3.7' THEN 1
            WHEN 'claude-sonnet-3.7-thinking' THEN 1.25
            WHEN 'claude-sonnet-4' THEN 1
            WHEN 'claude-opus' THEN 4
            WHEN 'gemini-2.0-flash' THEN 0.25
            WHEN 'gemini-2.5-pro' THEN 1
            WHEN 'o1' THEN 10
            WHEN 'o3' THEN 1
            WHEN 'o3-mini' THEN 0.33
            WHEN 'o4-mini' THEN 0.33
            ELSE 0 END) AS premium_requests
          FROM metrics
          WHERE event_type = 'CodeCompanionRequestStarted'
            AND json_extract(payload, '$.adapter.name') = 'copilot'
            AND json_extract(payload, '$.adapter.model') IN (
              'gpt-4.1','gpt-4o','gpt-4.5',
              'claude-sonnet-3.5','claude-sonnet-3.7','claude-sonnet-3.7-thinking','claude-sonnet-4','claude-opus',
              'gemini-2.0-flash','gemini-2.5-pro','o1','o3','o3-mini','o4-mini'
            )
            AND %s;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, dimension)
                  return string.format("- **Premium Requests (%s):** %s", dimension.label, row.premium_requests or "0")
                end,
              },
              ["Copilot Premium Requests by Model"] = {
                name = "Copilot Premium Requests by Model",
                sql = function(dimension)
                  return string.format(
                    [[SELECT json_extract(payload, '$.adapter.model') AS model,
                     SUM(CASE json_extract(payload, '$.adapter.model')
                       WHEN 'gpt-4.5' THEN 50
                       WHEN 'claude-sonnet-3.5' THEN 1
                       WHEN 'claude-sonnet-3.7' THEN 1
                       WHEN 'claude-sonnet-3.7-thinking' THEN 1.25
                       WHEN 'claude-sonnet-4' THEN 1
                       WHEN 'claude-opus' THEN 4
                       WHEN 'gemini-2.0-flash' THEN 0.25
                       WHEN 'gemini-2.5-pro' THEN 1
                       WHEN 'o1' THEN 10
                       WHEN 'o3' THEN 1
                       WHEN 'o3-mini' THEN 0.33
                       WHEN 'o4-mini' THEN 0.33
                       ELSE 0 END) AS premium_requests
           FROM metrics
           WHERE event_type = 'CodeCompanionRequestStarted'
             AND json_extract(payload, '$.adapter.name') = 'copilot'
             AND json_extract(payload, '$.adapter.model') IN (
               'gpt-4.5',
               'claude-sonnet-3.5','claude-sonnet-3.7','claude-sonnet-3.7-thinking','claude-sonnet-4','claude-opus',
               'gemini-2.0-flash','gemini-2.5-pro','o1','o3','o3-mini','o4-mini'
             )
             AND %s
           GROUP BY model;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- `%s`: **%s** premium requests", row.model or "?", row.premium_requests or "0")
                end,
              },
              ["Requests Per Day"] = {
                name = "Requests Per Day",
                sql = function(dimension)
                  return string.format(
                    [[SELECT date(ts, 'unixepoch') AS day, COUNT(*) AS count
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestStarted'
                        AND %s
                      GROUP BY day
                      ORDER BY day DESC;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- %s: **%s** requests", row.day or "?", row.count or "0")
                end,
              },
              ["Requests By User"] = {
                name = "Requests By User",
                sql = function(dimension)
                  return string.format(
                    [[SELECT json_extract(payload, '$.user') AS user, COUNT(*) AS count
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestStarted'
                        AND %s
                      GROUP BY user
                      ORDER BY count DESC;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- %s: **%s** requests", row.user or "?", row.count or "0")
                end,
              },
              ["Requests By Command"] = {
                name = "Requests By Command",
                sql = function(dimension)
                  return string.format(
                    [[SELECT json_extract(payload, '$.command') AS command, COUNT(*) AS count
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestStarted'
                        AND %s
                      GROUP BY command
                      ORDER BY count DESC;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- %s: **%s** requests", row.command or "?", row.count or "0")
                end,
              },
              ["Average Response Time"] = {
                name = "Average Response Time (seconds)",
                sql = function(dimension)
                  return string.format(
                    [[SELECT AVG(json_extract(payload, '$.response_time')) AS avg_response_time
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestStarted'
                        AND %s;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- Average: **%.2f** seconds", tonumber(row.avg_response_time) or 0)
                end,
              },
              ["Requests By Adapter"] = {
                name = "Requests By Adapter",
                sql = function(dimension)
                  return string.format(
                    [[SELECT json_extract(payload, '$.adapter.name') AS adapter, COUNT(*) AS count
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestStarted'
                        AND %s
                      GROUP BY adapter
                      ORDER BY count DESC;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- %s: **%s** requests", row.adapter or "?", row.count or "0")
                end,
              },
              ["Requests By Filetype"] = {
                name = "Requests By Filetype",
                sql = function(dimension)
                  return string.format(
                    [[SELECT json_extract(payload, '$.filetype') AS filetype, COUNT(*) AS count
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestStarted'
                        AND %s
                      GROUP BY filetype
                      ORDER BY count DESC;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- %s: **%s** requests", row.filetype or "?", row.count or "0")
                end,
              },
              ["Requests By Hour"] = {
                name = "Requests By Hour",
                sql = function(dimension)
                  return string.format(
                    [[SELECT hour, COUNT(*) AS count
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestStarted'
                        AND %s
                      GROUP BY hour
                      ORDER BY hour;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- %02d:00: **%s** requests", tonumber(row.hour) or 0, row.count or "0")
                end,
              },
              ["Failed Requests"] = {
                name = "Failed Requests",
                sql = function(dimension)
                  return string.format(
                    [[SELECT COUNT(*) AS count
                      FROM metrics
                      WHERE event_type = 'CodeCompanionRequestFailed'
                        AND %s;]],
                    dimension.filter
                  )
                end,
                title_formatter = function(name, dimension)
                  return string.format("### %s (%s)", name, dimension.label)
                end,
                row_formatter = function(row, _)
                  return string.format("- **%s** failed requests", row.count or "0")
                end,
              },
            },
          },
        },
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
        -- mcphub = {
        --   callback = "mcphub.extensions.codecompanion",
        --   opts = {
        --     make_vars = true,
        --     make_slash_commands = true,
        --     show_result_in_chat = true,
        --   },
        -- },
        -- vectorcode = {
        --   opts = {
        --     add_tool = true,
        --     add_slash_command = true,
        --   },
        -- },
        ["chat-model-toggle"] = {
          enabled = true,
          opts = {
            keymap = "gM", -- or "<S-Tab>", or any key you want
            copilot = "gemini-2.5-pro", -- alternate model for copilot adapter
            -- openai = "gpt-4o", -- alternate model for openai adapter
          },
          callback = function()
            return require("ai.extensions.chat-model-toggle")
          end,
        },
        rules = {
          enabled = true,
          opts = {
            -- your rules config here if needed
          },
          callback = function()
            return require("ai.extensions.rules")
          end,
        },
        context_management = {
          enabled = true,
          opts = {
            -- keymap_picker = "gE",
            -- keymap_quick = "gO",
          },
          callback = function()
            return require("ai.extensions.context-management")
          end,
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          roles = { llm = "  Copilot Chat", user = "wrightbradley" },
          tools = {
            opts = {
              auto_submit_errors = true, -- Send any errors to the LLM automatically?
              auto_submit_success = true, -- Send any successful output to the LLM automatically?
            },
          },
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
            ["chat-edit-live"] = {
              keymap_picker = "gE", -- Default: picker mode
              keymap_quick = "gO", -- Default: quick removal
            },
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
      -- Load all modular prompts and workflows
      prompt_library = require("ai.prompts.library"),
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
