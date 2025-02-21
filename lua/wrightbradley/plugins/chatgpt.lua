return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      local home = vim.fn.expand("$HOME")
      require("chatgpt").setup({
        api_key_cmd = "gpg --decrypt " .. home .. "/chatgpt.key.gpg",
        openai_params = {
          -- model = "o1-mini",
          model = "gpt-4o-2024-08-06",
          frequency_penalty = 0,
          presence_penalty = 0,
          max_tokens = 4096,
          -- max_completion_tokens = 4096,
          temperature = 1,
          top_p = 1,
          n = 1,
        },
        openai_edit_params = {
          -- model = "o1-mini",
          model = "gpt-4o-2024-08-06",
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
