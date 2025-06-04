return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    -- ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      "BufReadPre "
        .. vim.fn.expand("~")
        .. "Projects/writing/obsidian-vault/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "Projects/writing/obsidian-vault/**.md",
    },
    cmd = {
      "ObsidianBacklinks",
      "ObsidianFollowLink",
      "ObsidianLink",
      "ObsidianLinkNew",
      "ObsidianNew",
      "ObsidianOpen",
      "ObsidianPasteImg",
      "ObsidianQuickSwitch",
      "ObsidianRename",
      "ObsidianSearch",
      "ObsidianTemplate",
      "ObsidianToday",
      "ObsidianTomorrow",
      "ObsidianWorkspace",
      "ObsidianYesterday",
    },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>oo", ":cd /Users/bwright/Projects/writing/obsidian-vault/<cr>", desc = "Navigate to Obsidian Vault" },
      {
        "<leader>on",
        ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>",
        desc = "Convert note to template and remove leading white space",
      },
      {
        "<leader>os",
        ':Telescope find_files search_dirs={"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/notes"}<cr>',
        desc = "Find files in Obsidian Vault",
      },
      {
        "<leader>oz",
        ':Telescope live_grep search_dirs={"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/notes"}<cr>',
        desc = "Grep files in Obsidian Vault",
      },
    },
    opts = {
      workspaces = {
        {
          name = "Personal",
          path = "~/Projects/writing/obsidian-vault",
        },
        -- {
        --   name = "work",
        --   path = "~/vaults/work",
        -- },
      },
      -- see below for full list of options 👇
      disable_frontmatter = true,
      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M:%S",
      },
      -- key mappings, below are the defaults
      mappings = {
        -- overrides the 'gf' mapping to work on markdown/wiki links within your vault
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- toggle check-boxes
        -- ["<leader>ch"] = {
        --   action = function()
        --     return require("obsidian").util.toggle_checkbox()
        --   end,
        --   opts = { buffer = true },
        -- },
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      ui = {
        -- Disable some things below here because I set these manually for all Markdown files using treesitter
        checkboxes = {},
        bullets = {},
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)
    end,
  },
}
