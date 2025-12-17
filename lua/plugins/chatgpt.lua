---@file ChatGPT Integration Configuration
--- This file configures the ChatGPT plugin for direct OpenAI API integration.
--- It provides an alternative AI interface with custom prompts and secure
--- API key management using GPG encryption.

return {
  {
    "jackMort/ChatGPT.nvim",
    lazy = true, -- Load only when keys are pressed
    config = function()
      local home = vim.fn.expand("$HOME")
      require("chatgpt").setup({
        -- Secure API key retrieval using GPG encryption
        api_key_cmd = "gpg --decrypt " .. home .. "/chatgpt.key.gpg",

        -- OpenAI model parameters for chat interactions
        openai_params = {
          -- model = "o1-mini",           -- Alternative: use o1-mini for reasoning tasks
          model = "gpt-4o-2024-08-06",   -- Primary model: GPT-4o for general tasks
          frequency_penalty = 0,          -- No frequency penalty
          presence_penalty = 0,           -- No presence penalty
          max_tokens = 4096,              -- Maximum tokens per response
          -- max_completion_tokens = 4096, -- Alternative max tokens setting
          temperature = 1,                -- Creative temperature setting
          top_p = 1,                      -- Nucleus sampling parameter
          n = 1,                          -- Number of completions to generate
        },

        -- OpenAI parameters specifically for code editing tasks
        openai_edit_params = {
          -- model = "o1-mini",           -- Alternative: use o1-mini for editing
          model = "gpt-4o-2024-08-06",   -- Primary editing model
          frequency_penalty = 0,
          presence_penalty = 0,
          temperature = 1,
          top_p = 1,
          n = 1,
        },
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>agc", "<cmd>ChatGPT<CR>", desc = "chatgpt: Chat" },
      {
        "<leader>agg",
        "<cmd>ChatGPTRun grammar_correction<CR>",
        desc = "chatgpt: Grammar Correction",
        mode = { "n", "v" },
      },
      {
        "<leader>age",
        "<cmd>ChatGPTEditWithInstruction<CR>",
        desc = "chatgpt: Edit with instruction",
        mode = { "n", "v" },
      },
      { "<leader>agt", "<cmd>ChatGPTRun translate<CR>", desc = "chatgpt: Translate", mode = { "n", "v" } },
      { "<leader>agk", "<cmd>ChatGPTRun keywords<CR>", desc = "chatgpt: Keywords", mode = { "n", "v" } },
      { "<leader>agd", "<cmd>ChatGPTRun docstring<CR>", desc = "chatgpt: Docstring", mode = { "n", "v" } },
      { "<leader>aga", "<cmd>ChatGPTRun add_tests<CR>", desc = "chatgpt: Add Tests", mode = { "n", "v" } },
      { "<leader>ago", "<cmd>ChatGPTRun optimize_code<CR>", desc = "chatgpt: Optimize Code", mode = { "n", "v" } },
      { "<leader>ags", "<cmd>ChatGPTRun summarize<CR>", desc = "chatgpt: Summarize", mode = { "n", "v" } },
      { "<leader>agf", "<cmd>ChatGPTRun fix_bugs<CR>", desc = "chatgpt: Fix Bugs", mode = { "n", "v" } },
      { "<leader>agx", "<cmd>ChatGPTRun explain_code<CR>", desc = "chatgpt: Explain Code", mode = { "n", "v" } },
      { "<leader>agr", "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "chatgpt: Roxygen Edit", mode = { "n", "v" } },
      {
        "<leader>agl",
        "<cmd>ChatGPTRun code_readability_analysis<CR>",
        desc = "chatgpt: Code Readability Analysis",
        mode = { "n", "v" },
      },
    },
  },
}
