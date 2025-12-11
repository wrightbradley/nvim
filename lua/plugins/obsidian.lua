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
      -- Template-based creation with proper organization
      {
        "<leader>op",
        function()
          vim.ui.select(
            { "professional", "friend", "family", "acquaintance" },
            { prompt = "Category: " },
            function(category)
              if category then
                vim.ui.input({ prompt = "Person name: " }, function(name)
                  if name then
                    local vault_path = vim.fn.expand("~/Projects/writing/notes")
                    local subdir = "people/" .. category .. "s"
                    local dir_path = vault_path .. "/" .. subdir

                    vim.fn.mkdir(dir_path, "p")

                    local file_path = vault_path .. "/" .. subdir .. "/" .. name .. ".md"

                    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
                    vim.cmd("read " .. vault_path .. "/templates/person.md")
                    vim.cmd("1delete")
                    vim.cmd([[%s/^category: $/category: ]] .. category .. [[/e]])
                    vim.cmd("write")
                    vim.cmd("normal! gg")
                  end
                end)
              end
            end
          )
        end,
        desc = "New person note",
      },
      {
        "<leader>om",
        function()
          vim.ui.input({ prompt = "Meeting title: " }, function(title)
            if title then
              local vault_path = vim.fn.expand("~/Projects/writing/notes")
              local subdir = "meetings"
              local dir_path = vault_path .. "/" .. subdir

              vim.fn.mkdir(dir_path, "p")

              local date = os.date("%Y-%m-%d")
              local file_path = vault_path .. "/" .. subdir .. "/" .. date .. " - " .. title .. ".md"

              vim.cmd("edit " .. vim.fn.fnameescape(file_path))
              vim.cmd("read " .. vault_path .. "/templates/meeting.md")
              vim.cmd("1delete")
              vim.cmd("write")
              vim.cmd("normal! gg")
            end
          end)
        end,
        desc = "New meeting note",
      },
      {
        "<leader>oP",
        function()
          vim.ui.input({ prompt = "Project name: " }, function(name)
            if name then
              local vault_path = vim.fn.expand("~/Projects/writing/notes")
              local subdir = "projects"
              local dir_path = vault_path .. "/" .. subdir

              vim.fn.mkdir(dir_path, "p")

              local file_path = vault_path .. "/" .. subdir .. "/" .. name .. ".md"

              vim.cmd("edit " .. vim.fn.fnameescape(file_path))
              vim.cmd("read " .. vault_path .. "/templates/project.md")
              vim.cmd("1delete")
              vim.cmd("write")
              vim.cmd("normal! gg")
            end
          end)
        end,
        desc = "New project note",
      },
      {
        "<leader>oO",
        function()
          vim.ui.input({ prompt = "Organization name: " }, function(name)
            if name then
              local vault_path = vim.fn.expand("~/Projects/writing/notes")
              local subdir = "organizations"
              local dir_path = vault_path .. "/" .. subdir

              vim.fn.mkdir(dir_path, "p")

              local file_path = vault_path .. "/" .. subdir .. "/" .. name .. ".md"

              vim.cmd("edit " .. vim.fn.fnameescape(file_path))
              vim.cmd("read " .. vault_path .. "/templates/organization.md")
              vim.cmd("1delete")
              vim.cmd("write")
              vim.cmd("normal! gg")
            end
          end)
        end,
        desc = "New organization note",
      },
    },
    opts = {
      workspaces = VAULTS,
      legacy_commands = false,

      frontmatter = {
        enabled = false,
        -- Optional: Enable sorting of frontmatter properties
        -- sort = true,
      },

      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M:%S",
        substitutions = {
          yesterday = function()
            return os.date("%Y-%m-%d", os.time() - 86400)
          end,
          category = function()
            return vim.fn.input("Category (professional/friend/family/acquaintance): ")
          end,
        },
      },

      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        default_tags = { "daily-notes" },
        template = "daily",
      },

      completion = {
        blink = true,
        min_chars = 2,
        create_new = true,
      },

      picker = {
        name = "snacks",
      },

      search = {
        max_links = nil,
        sort_by = "modified",
        sort_reversed = true,
      },

      attachments = {
        img_folder = "attachments",
        -- Customize image name generation
        img_name_func = function()
          return string.format("%s-", os.time())
        end,
        confirm_img_paste = true,
      },

      footer = {
        enabled = true,
      },

      ui = {
        enable = false,
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
