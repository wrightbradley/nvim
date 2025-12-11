local VAULTS = {
  { name = "Notes", path = "~/Projects/writing/notes" },
  { name = "Personal", path = "~/Projects/writing/obsidian-vault" },
}

local function select_vault_and_execute(action)
  vim.ui.select(VAULTS, {
    prompt = "Select Obsidian Vault:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      action(vim.fn.expand(choice.path))
    end
  end)
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Projects/writing/notes/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Projects/writing/notes/**.md",
      "BufReadPre " .. vim.fn.expand("~") .. "/Projects/writing/obsidian-vault/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Projects/writing/obsidian-vault/**.md",
    },
    cmd = {
      "Obsidian",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>oo",
        function()
          select_vault_and_execute(function(path)
            vim.cmd("cd " .. path)
          end)
        end,
        desc = "Navigate to Obsidian Vault",
      },
      {
        "<leader>on",
        ":Obsidian template note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>",
        desc = "Insert template and remove leading whitespace",
      },
      {
        "<leader>os",
        function()
          select_vault_and_execute(function(path)
            Snacks.picker.files({ cwd = path })
          end)
        end,
        desc = "Find files in Obsidian Vault",
      },
      {
        "<leader>oz",
        function()
          select_vault_and_execute(function(path)
            Snacks.picker.grep({ cwd = path })
          end)
        end,
        desc = "Grep in Obsidian Vault",
      },
      -- Quick operations (without vault selection)
      { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch notes" },
      { "<leader>of", "<cmd>Obsidian search<cr>", desc = "Search notes" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Show links" },
      { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "Search tags" },
      -- Note operations
      { "<leader>oN", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
      -- Daily notes
      { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Today's note" },
      { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
      { "<leader>oD", "<cmd>Obsidian dailies<cr>", desc = "Browse daily notes" },
      -- People database
      {
        "<leader>op",
        function()
          vim.ui.input({ prompt = "Person name: " }, function(name)
            if name then
              vim.cmd("Obsidian new_from_template " .. name .. " person")
            end
          end)
        end,
        desc = "New person note",
      },
      {
        "<leader>om",
        function()
          vim.ui.input({ prompt = "Meeting title: " }, function(title)
            if title then
              vim.cmd("Obsidian new_from_template " .. title .. " meeting")
            end
          end)
        end,
        desc = "New meeting note",
      },
    },
    opts = {
      workspaces = VAULTS,

      -- Use new command format
      legacy_commands = false,

      -- Frontmatter configuration
      frontmatter = {
        enabled = false,
        -- Optional: Enable sorting of frontmatter properties
        -- sort = true,
      },

      -- Templates configuration
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M:%S",
        -- Custom substitutions for templates
        substitutions = {
          yesterday = function()
            return os.date("%Y-%m-%d", os.time() - 86400)
          end,
          category = function()
            -- Prompt for category when creating person notes
            return vim.fn.input("Category (professional/friend/family/acquaintance): ")
          end,
        },
      },

      -- Daily notes configuration
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        default_tags = { "daily-notes" },
        template = "daily", -- Use the daily template by default
      },

      -- Completion with blink.cmp
      completion = {
        blink = true,
        min_chars = 2,
        -- Whether to create new notes in picker
        create_new = true,
      },

      -- Picker configuration
      picker = {
        name = "snacks",
      },

      -- Search configuration
      search = {
        max_links = nil,
        sort_by = "modified",
        sort_reversed = true,
      },

      -- Attachments/images configuration
      attachments = {
        img_folder = "attachments",
        -- Customize image name generation
        img_name_func = function()
          return string.format("%s-", os.time())
        end,
        -- Optional: confirm before pasting images
        confirm_img_paste = true,
      },

      -- Footer configuration (shows note info like Obsidian app)
      footer = {
        enabled = true,
      },

      -- UI configuration
      ui = {
        enable = false,
        -- Checkbox configuration
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          ["!"] = { char = "", hl_group = "ObsidianImportant" },
          order = { " ", "x", ">", "~", "!" },
        },
      },

      -- Optional: Customize link formatting
      -- preferred_link_style = "wiki",
      -- new_notes_location = "current_dir",
    },
    config = function(_, opts)
      require("obsidian").setup(opts)
    end,
  },
}
