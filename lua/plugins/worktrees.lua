---@file Git Worktree Workflow
--- Snacks picker over `git worktree list` + session restore on switch.
--- Implementation lives in lua/util/worktrees.lua (`Util.worktrees`).
---
--- Keys:
---   <leader>gws  switch worktree (restores the persistence.nvim session
---                saved for that tree)
---   <leader>gwn  create worktree (`wt create` when available, else git)

return {
  {
    "folke/snacks.nvim",
    optional = true,
    keys = {
      {
        "<leader>gws",
        function()
          Snacks.picker.worktrees()
        end,
        desc = "Git Worktree switch",
      },
      {
        "<leader>gwn",
        function()
          Util.worktrees.create()
        end,
        desc = "Create new Git Worktree",
      },
    },
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.sources = vim.tbl_extend("force", opts.picker.sources or {}, {
        worktrees = {
          finder = function()
            return Util.worktrees.parse(Util.root.git())
          end,
          format = function(item)
            local icon = item.detached and "󰘛" or ""
            return {
              { icon .. " ", hl = "Directory" },
              { item.branch, hl = "Directory" },
              { "  " .. item.path, hl = "Comment" },
            }
          end,
          confirm = function(picker, item)
            picker:close()
            Util.worktrees.switch(item.path)
          end,
          preview = "none",
        },
      })
    end,
  },
}
