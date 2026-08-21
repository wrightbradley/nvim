-- Detect `uv run --script` shebangs as Python (PEP 723 inline scripts).
-- Neovim's builtin detection doesn't recognize the `uv run` shebang,
-- so extensionless uv scripts get misdetected. BufReadPost handles new files;
-- BufWinEnter catches files opened before this file was sourced
-- (e.g. files passed as CLI arguments).
local group = vim.api.nvim_create_augroup("uv_script_filetype", { clear = false })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  group = group,
  callback = function(event)
    if vim.bo[event.buf].filetype == "python" then
      return
    end
    -- Skip special buffers
    if vim.bo[event.buf].buftype ~= "" then
      return
    end
    local first_line = vim.api.nvim_buf_get_lines(event.buf, 0, 1, false)[1] or ""
    if first_line:find("uv run %-%-script") then
      vim.bo[event.buf].filetype = "python"
    end
  end,
  desc = "Detect uv run --script shebangs as Python",
})
