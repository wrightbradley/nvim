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
