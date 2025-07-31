# Troubleshooting Guide

This guide helps you diagnose and fix common issues with this Neovim configuration.

## General Diagnostics

### Health Check

Always start with the built-in health check:

```vim
:checkhealth
```

This will check:

- Neovim version and capabilities
- Plugin installation status
- External dependencies
- LSP server status
- Python/Node.js integration

### Plugin Status

Check plugin loading and status:

```vim
:Lazy                    -- Plugin manager interface
:Lazy profile            -- See plugin loading times
:Lazy health             -- Plugin-specific health checks
```

## Common Issues and Solutions

### 1. Slow Startup

#### Symptoms

- Neovim takes more than 3-5 seconds to start
- Noticeable delay when opening files

#### Diagnosis

```vim
:Lazy profile            -- Check plugin loading times
nvim --startuptime startup.log  -- Generate startup log
```

### 2. LSP Issues

#### Symptoms

- No code completion
- Missing hover documentation
- No go-to-definition
- Error: "No LSP client found"

#### Diagnosis

```vim
:LspInfo                 -- Check attached LSP servers
:Mason                   -- Check server installation
:checkhealth lsp         -- LSP health check
```

#### Solutions

**Install Missing Servers:**

```vim
:Mason
# Navigate to server and press 'i' to install
```

**Restart LSP:**

```vim
:LspRestart
```

**Manual Server Installation:**

```bash
# Python
pip install pyright

# JavaScript/TypeScript
npm install -g typescript-language-server

# Go
go install golang.org/x/tools/gopls@latest

# Rust (should be automatic)
rustup component add rust-analyzer
```

**Check File Association:**

```vim
:echo &filetype         -- Verify correct filetype detection
:LspInfo                -- Check if server supports this filetype
```

### 3. AI Integration Problems

#### CodeCompanion Issues

**Symptoms:**

- Chat window not opening
- No AI responses
- Authentication errors

**Solutions:**

```bash
# Check Copilot status
gh copilot status

# Re-authenticate
gh auth login

# Check environment variables
echo $OPENAI_API_KEY
```

**CodeCompanion Restart:**

```vim
:CodeCompanionActions   -- Check if plugin loads
:checkhealth codecompanion  -- CodeCompanion health check
:Lazy reload codecompanion  -- Reload plugin
```

### 4. Git Integration Problems

#### Symptoms

- Git commands not working
- No git status in statusline
- Lazygit not opening

#### Solutions

**Check Git Installation:**

```bash
git --version
which git
```

**GitHub CLI Issues:**

```bash
gh auth status          -- Check authentication
gh auth login           -- Re-authenticate if needed
```

**Repository Issues:**

```bash
cd /path/to/project
git status              -- Verify git repository
```

### 5. Formatting and Linting Issues

#### Symptoms

- Code not formatting on save
- No linting errors shown
- Formatter not found errors

#### Diagnosis

```vim
:ConformInfo            -- Check formatter status
:checkhealth conform    -- Conform health check
```

#### Solutions

**Install Missing Formatters:**

```bash
# Python
pip install black isort

# JavaScript/TypeScript
npm install -g prettier

# Lua
brew install stylua     # macOS
# or install via Mason: :Mason

# Go
go install mvdan.cc/gofumpt@latest
```

**Manual Format:**

```vim
:lua require("conform").format()  -- Test manual formatting
```

**Check Configuration:**

```vim
:lua print(vim.inspect(require("conform").list_formatters()))
```

### 6. Completion Issues

#### Symptoms

- No autocompletion
- Completion menu not appearing
- Snippets not working

#### Solutions

**Check Blink.cmp Status:**

```vim
:checkhealth blink      -- Blink.cmp health check
:checkhealth blink.cmp  -- Alternative health check command
```

**Trigger Completion Manually:**

```vim
# In insert mode
<C-Space>               -- Manual trigger
```

**Reset Completion:**

```vim
:Lazy reload blink.cmp
```

### 7. File Explorer Problems

#### Symptoms

- File explorer not opening
- Cannot navigate directories
- Files not updating

#### Solutions

**Check Snacks Explorer:**

```vim
:checkhealth snacks     -- Snacks health check
:lua Snacks.explorer()  -- Manual trigger
```

**Alternative File Managers:**

```vim
:Explore                -- Built-in netrw
```

### 8. Theme and UI Issues

#### Symptoms

- Colors not displaying correctly
- Icons not showing
- Statusline missing

#### Solutions

**Check Terminal Capabilities:**

```vim
:echo $TERM
:set termguicolors?     -- Should be on
```

**Font Issues:**

```bash
# Install Nerd Font
brew install --cask font-jetbrains-mono-nerd-font  # macOS
```

**Reset Theme:**

```vim
:colorscheme default    -- Test with default theme
:colorscheme tokyonight -- Reset to configured theme
```

### 9. Performance Issues

#### Memory Usage

**Check Memory:**

```vim
:lua print(collectgarbage("count"))  -- Lua memory usage
```

**Reduce Memory:**

```vim
:lua collectgarbage()   -- Force garbage collection
```

#### High CPU Usage

**Identify Culprit:**

```vim
:Lazy profile           -- Check plugin performance
:set updatetime=1000    -- Reduce update frequency
```

## Advanced Troubleshooting

### Debug Mode

Start Neovim with debugging:

```bash
nvim --cmd "set verbose=9" --cmd "set verbosefile=/tmp/nvim.log"
```

### Plugin-Specific Debugging

**Plugin-Specific Health Checks:**

```vim
:checkhealth mason      -- Mason health check
:checkhealth nvim-dap   -- DAP health check
:checkhealth nvim-treesitter -- Treesitter health check
:checkhealth snacks     -- Snacks health check
:checkhealth codecompanion -- CodeCompanion health check
:checkhealth blink      -- Blink.cmp health check
```

**LSP Debug:**

```vim
:lua vim.lsp.set_log_level("debug")
:lua print(vim.lsp.get_log_path())
```

**Lazy.nvim Debug:**

```vim
:Lazy debug             -- Show plugin loading details
```

### Clean Reinstall

If all else fails, perform a clean reinstall:

```bash
# Backup current config
cp -r ~/.config/nvim ~/.config/nvim.backup

# Remove all Neovim data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Reinstall configuration
git clone <your-config-repo> ~/.config/nvim
nvim  # Will reinstall everything
```

## Getting Help

### Built-in Help

```vim
:help <topic>           -- Neovim help
:Lazy help              -- Plugin manager help
:Mason help             -- LSP server manager help
```

### Log Files

**Neovim Logs:**

```bash
# Location varies by system
~/.local/state/nvim/log
~/.cache/nvim/log
```

**LSP Logs:**

```vim
:lua print(vim.lsp.get_log_path())
```

## Prevention Tips

### Monitor Performance

```vim
# Regular performance checks
:Lazy profile           -- Plugin performance
:LspInfo                -- LSP status
:checkhealth            -- Overall health
```

## Emergency Recovery

### Minimal Configuration

If the configuration is completely broken, create a minimal init.lua:

```lua
-- ~/.config/nvim/init.minimal.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.mapleader = " "

-- Use with: nvim -u ~/.config/nvim/init.minimal.lua
```

### Safe Mode

Start without plugins:

```bash
nvim --noplugin         -- Start without any plugins
nvim --clean            -- Start with no config at all
```

This troubleshooting guide should help you resolve most issues you encounter with this Neovim configuration.
