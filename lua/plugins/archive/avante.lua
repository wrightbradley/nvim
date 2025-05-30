local copilot_enabled = os.getenv("NVIM_ENABLE_COPILOT")
if copilot_enabled == "false" then
  return {}
end
return {
  {
    "yetone/avante.nvim",
    -- event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "copilot",
      -- claude = {
      --   endpoint = "https://api.anthropic.com",
      --   model = "claude-3-5-sonnet-20241022",
      --   temperature = 0,
      --   max_tokens = 4096,
      --   api_key_name = { "gpg", "--decrypt", vim.fn.getenv("HOME") .. "/anthropic.key.gpg" },
      -- },
      -- openai = {
      --   endpoint = "https://api.openai.com/v1",
      --   model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
      --   timeout = 30000, -- timeout in milliseconds
      --   temperature = 0, -- adjust if needed
      --   max_tokens = 4096,
      --   reasoning_effort = "high" -- only supported for "o" models
      -- },
      copilot = {
        endpoint = "https://api.githubcopilot.com",
        model = "gemini-2.0-flash-001",
        -- model = "claude-3.5-sonnet",
        -- model = "gpt-4",
        -- model = "gpt-4o",
        -- model = "gpt-4o-mini",
        -- model = "o1",
        -- model = "o3-mini",
        proxy = nil, -- [protocol://]host[:port] Use this proxy
        allow_insecure = false, -- Allow insecure server connections
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 4096,
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = false,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true, -- Whether to enable token counting. Default to true.
        enable_cursor_planning_mode = false, -- Whether to enable Cursor Planning Mode. Default to false.
      },
      file_selector = {
        --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string | fun(params: avante.file_selector.IParams|nil): nil
        provider = "fzf",
        -- Options override for custom providers
        provider_opts = {},
      },
      mappings = {
        ask = "<leader>aaa", -- Ask avante
        edit = "<leader>aae", -- Edit avante
        refresh = "<leader>aar", -- Refresh avante
      },
    },
    keys = {
      {
        "<leader>aaa",
        function()
          require("avante.api").ask()
        end,
        mode = { "n", "v" },
        desc = "avante: ask",
      },
      {
        "<leader>aae",
        function()
          require("avante.api").edit()
        end,
        mode = "v",
        desc = "avante: edit",
      },
      {
        "<leader>aar",
        function()
          require("avante.api").refresh()
        end,
        mode = "n",
        desc = "avante: refresh",
      },
      {
        "<leader>aaf",
        function()
          require("avante.api").focus()
        end,
        mode = "n",
        desc = "avante: focus",
      },
      {
        "<leader>aat",
        "<Plug>(AvanteToggle)",
        mode = "n",
        desc = "avante: toggle",
      },
      {
        "<leader>aad",
        "<Plug>(AvanteToggleDebug)",
        mode = "n",
        desc = "avante: toggle debug",
      },
      {
        "<leader>aah",
        "<Plug>(AvanteToggleHint)",
        mode = "n",
        desc = "avante: toggle hint",
      },
      {
        "<leader>aas",
        "<Plug>(AvanteToggleSuggestion)",
        mode = "n",
        desc = "avante: toggle suggestion",
      },
      {
        "<leader>aar",
        function()
          require("avante.repo_map").show()
        end,
        mode = "n",
        desc = "avante: display repo map",
        noremap = true,
        silent = true,
      },
      {
        "<leader>aa?",
        function()
          require("avante.api").select_model()
        end,
        mode = "n",
        desc = "avante: select model",
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "saghen/blink.cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
            hints = { enabled = true },
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
