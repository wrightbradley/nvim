---@file Git worktree helpers
--- Access via `Util.worktrees` (auto-loaded submodule).
--- Designed for a bare-repo layout (~/Projects/code/github.com/org/repo) where
--- worktrees are created outside nvim (e.g. `wt`/worktrunk) — nvim's job is to
--- *switch* between them quickly:
---   - wipes loaded file buffers so LSP/treesitter reattach against the new tree
---   - chdirs into the worktree
---   - restores the persistence.nvim session saved for that cwd, so switching
---     trees restores your full editing context

local M = {}

--- Parse `git worktree list --porcelain` output.
---@param root string? repo root to run git against
---@return table[] items with { path, branch, detached, text }
function M.parse(root)
  if not root then
    return {}
  end
  local ok, out = pcall(vim.fn.systemlist, { "git", "-C", root, "worktree", "list", "--porcelain" })
  if not ok or vim.v.shell_error ~= 0 then
    Util.warn("Failed to list worktrees", { title = "worktrees" })
    return {}
  end

  local ret, entry = {}, nil
  local function flush()
    if entry and entry.path then
      entry.branch = entry.branch or (entry.detached and "(detached)" or vim.fs.basename(entry.path))
      entry.text = entry.branch .. " " .. entry.path
      table.insert(ret, entry)
    end
    entry = nil
  end

  for _, line in ipairs(out) do
    local key, value = line:match("^(%w+)%s*(.*)$")
    if key == "worktree" then
      flush()
      entry = { path = value }
    elseif key == "branch" then
      if entry then
        entry.branch = value:gsub("^refs/heads/", "")
      end
    elseif key == "detached" then
      if entry then
        entry.detached = true
      end
    elseif key == "bare" then
      if entry then
        entry.bare = true
      end
    elseif line == "" then
      flush()
    end
  end
  flush()

  -- skip bare checkouts; they aren't editing targets
  return vim.tbl_filter(function(e)
    return not e.bare
  end, ret)
end

--- Switch to a worktree: drop buffers, chdir, restore its session.
---@param path string absolute worktree path
function M.switch(path)
  -- Wipe loaded normal buffers so LSP/treesitter clients reattach in the new
  -- tree instead of holding references into the old one.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end

  vim.cmd.cd(path)
  Util.info("Switched to worktree: " .. vim.fs.basename(path), { title = "worktrees" })

  -- persistence stores sessions per-cwd; load the one for this tree.
  -- Schedule so persistence sees the post-cd state after picker teardown.
  vim.schedule(function()
    require("persistence").load()
  end)
end

--- Create a worktree. Prefers `wt` (worktrunk) since that is what manages the
--- bare-repo layout; falls back to plain `git worktree add`. Runs in a terminal
--- window so output/errors stay visible.
function M.create()
  Snacks.input({
    prompt = "Branch name for new worktree:",
  }, function(branch)
    if not branch or branch == "" then
      return
    end
    local cmd = vim.fn.executable("wt") == 1 and { "wt", "create", branch }
      or { "git", "worktree", "add", branch, "-b", branch }
    Snacks.terminal(cmd, {
      cwd = Util.root.git(),
      win = { style = "float", title = " create worktree ", footer = "" },
    })
  end)
end

return M
