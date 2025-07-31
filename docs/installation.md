# Installation and Setup Guide

This guide will help you install and configure this Neovim setup on your system.

## Prerequisites

### System Requirements

- **Neovim**: Version 0.10.0 or higher
- **Git**: For cloning repositories and version control
- **Node.js**: Version 18+ (required for many LSP servers)
- **Python**: Version 3.8+ (required for Python tools)
- **Rust**: Latest stable (for some tools)
- **Go**: Version 1.19+ (for Go development)

### Operating System Support

This configuration works on:
- **macOS** (primary development platform)
- **Linux** (Ubuntu, Fedora, Arch, etc.)
- **Windows** (via WSL2 recommended)

## Installation

### 1. Install Prerequisites

#### macOS (using Homebrew)
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install neovim git node python@3.11 rust go
brew install ripgrep fd fzf lazygit
brew install --cask font-jetbrains-mono-nerd-font
```

#### Ubuntu/Debian
```bash
# Update package list
sudo apt update

# Install base requirements
sudo apt install -y neovim git curl wget unzip

# Install Node.js (using NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Python
sudo apt install -y python3 python3-pip

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Install additional tools
sudo apt install -y ripgrep fd-find fzf
```

#### Arch Linux
```bash
# Install packages
sudo pacman -S neovim git nodejs npm python python-pip rust go
sudo pacman -S ripgrep fd fzf lazygit

# Install AUR helper (yay) if needed
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### 2. Install Additional Development Tools

#### Using npm (global packages)
```bash
npm install -g neovim tree-sitter-cli
```

#### Using pip (Python packages)
```bash
pip3 install --user pynvim neovim
```

### 3. Backup Existing Configuration

```bash
# Backup existing Neovim config
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.local/state/nvim ~/.local/state/nvim.backup
mv ~/.cache/nvim ~/.cache/nvim.backup
```

### 4. Clone This Configuration

```bash
# Clone the configuration (replace with your actual repository URL)
git clone https://github.com/YOURUSERNAME/nvim-config.git ~/.config/nvim
```

### 5. Initial Setup

#### Environment Setup
```bash
# Copy environment template
cd ~/.config/nvim
cp .envrc.sample .envrc

# Edit environment variables
$EDITOR .envrc

# Allow direnv (if using direnv)
direnv allow .
```

#### Initialize Development Tools
```bash
# Initialize the development environment
make init
```

This will:
- Set up direnv environment
- Initialize Vale for documentation linting
- Install pre-commit hooks

### 6. First Launch

```bash
# Start Neovim
nvim
```

On first launch, the configuration will:
1. Install lazy.nvim plugin manager
2. Download and install all plugins
3. Set up LSP servers via Mason
4. Configure tree-sitter parsers

**Note**: The first launch may take several minutes as all plugins and tools are downloaded and compiled.

## Post-Installation Setup

### 1. LSP Servers

The configuration uses Mason to manage LSP servers. Most will install automatically, but you can manually install additional ones:

```
:Mason
```

Common LSP servers included:
- **lua_ls** (Lua)
- **pyright** (Python)
- **typescript-language-server** (TypeScript/JavaScript)
- **gopls** (Go)
- **rust_analyzer** (Rust)
- **terraformls** (Terraform)
- **yaml-language-server** (YAML)

### 2. Formatters and Linters

Install additional formatters:

```bash
# Python tools
pip install black isort flake8 mypy

# JavaScript/TypeScript tools
npm install -g prettier eslint

# Other formatters
go install mvdan.cc/gofumpt@latest
cargo install stylua
```

### 3. AI Setup

Follow the [AI Setup Guide](ai-setup.md) to configure:
- GitHub Copilot
- OpenAI API
- Other AI providers

### 4. Git Configuration

```bash
# Configure git for better integration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install GitHub CLI (optional but recommended)
# macOS
brew install gh

# Ubuntu/Debian
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Authenticate with GitHub
gh auth login
```

## Environment Configuration

### 1. Environment Variables

Edit `.envrc` to configure:

```bash
# Copilot control
export NVIM_ENABLE_COPILOT="true"  # Set to "false" to disable

# Python environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Go environment
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust environment
export PATH="$HOME/.cargo/bin:$PATH"
```

### 2. Shell Integration

Add to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
# Neovim as default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Aliases
alias vi="nvim"
alias vim="nvim"
alias vimdiff="nvim -d"

# Direnv integration (optional)
eval "$(direnv hook bash)"  # for bash
# eval "$(direnv hook zsh)"   # for zsh
```

## Verification

### 1. Check Health

```vim
:checkhealth
```

This will verify:
- Neovim version and capabilities
- Plugin installation status
- LSP server availability
- External tool dependencies

### 2. Test Key Features

```vim
" Test file picker
<leader><space>

" Test AI integration
<leader>apa

" Test LSP
:LspInfo

" Test file tree
<leader>e

" Test git integration
<leader>gs
```

### 3. Common Issues Check

Run the linting tools:
```bash
# Run all linters
make lint

# Run pre-commit hooks
pre-commit run --all-files
```

## Customization

### 1. Personal Configuration

Create personal overrides:
```bash
# Create personal config file
touch ~/.config/nvim/lua/config/personal.lua
```

Example personal configuration:
```lua
-- lua/config/personal.lua
local M = {}

function M.setup()
  -- Your personal overrides here
  vim.opt.relativenumber = false  -- Disable relative numbers
  vim.g.mapleader = ","          -- Change leader key
end

return M
```

### 2. Plugin Customization

Create custom plugin configurations in `lua/plugins/`:
```lua
-- lua/plugins/my-plugin.lua
return {
  "my-username/my-plugin",
  config = function()
    require("my-plugin").setup({
      -- your config
    })
  end
}
```

## Update and Maintenance

### 1. Update Configuration

```bash
cd ~/.config/nvim
git pull origin main
```

### 2. Update Plugins

```vim
:Lazy update
```

### 3. Update LSP Servers

```vim
:Mason
# Press 'U' to update all
```

### 4. Maintenance Commands

```bash
# Update plugin catalog
make gen-docs

# Run linters
make lint

# Update pre-commit hooks
pre-commit autoupdate
```

## Troubleshooting

### Common Issues

**Plugin installation fails:**
```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim/lazy
nvim --headless "+Lazy! sync" +qa
```

**LSP not working:**
```vim
:LspInfo
:Mason
```

**Slow startup:**
```vim
:Lazy profile
```

**Git integration issues:**
```bash
# Check git configuration
git config --list
gh auth status
```

For more detailed troubleshooting, see the [Troubleshooting Guide](troubleshooting.md).

## Getting Help

1. **Check Documentation**: Browse the `docs/` directory
2. **Health Check**: Run `:checkhealth` in Neovim
3. **Plugin Issues**: Use `:Lazy` to check plugin status
4. **LSP Issues**: Use `:LspInfo` and `:Mason` for diagnostics
5. **Community**: Check the plugin repositories for specific issues

## Next Steps

After installation:
1. Read the [Keybindings Reference](keybindings.md)
2. Set up [AI Integration](ai-setup.md)
3. Explore [Language Support](language-support.md)
4. Learn the [Development Workflow](development-workflow.md)
