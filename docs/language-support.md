# Language Support Guide

This configuration provides comprehensive support for multiple programming languages through LSP servers, formatters, linters, debuggers, and specialized plugins.

## Supported Languages

### Primary Languages (Full Support)
- **Python** - Complete development environment
- **TypeScript/JavaScript** - Full-stack web development
- **Go** - Systems programming and web services
- **Rust** - Systems programming with cargo integration
- **Lua** - Neovim configuration and scripting

### Additional Languages (Good Support)
- **Terraform** - Infrastructure as code
- **Ansible** - Configuration management
- **YAML/JSON** - Configuration files with schema validation
- **Markdown** - Documentation with live preview
- **HTML/CSS** - Web development
- **Helm** - Kubernetes templating
- **Shell/Bash** - System scripting

## Language-Specific Setup

### Python

#### Features
- **LSP**: Pyright for type checking and IntelliSense
- **Formatting**: Black, isort for import sorting
- **Linting**: Flake8, mypy for type checking
- **Debugging**: Built-in DAP support with debugpy
- **Virtual Environment**: Automatic detection and switching

#### Configuration
```lua
-- Located in: lua/plugins/python.lua
{
  "linux-cultist/venv-selector.nvim",
  "mfussenegger/nvim-dap-python",
}
```

#### LSP Settings
```lua
-- Located in: lua/plugins/nvim-lspconfig.lua
pyright = {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}
```

#### Usage
```
:VenvSelect              -- Select virtual environment
<leader>dPt              -- Debug test method
<leader>dPc              -- Debug test class
<F5>                     -- Start debugging
```

#### Dependencies Installation
```bash
# Python tools
pip install black isort flake8 mypy debugpy
pip install python-lsp-server  # Alternative LSP
```

### TypeScript/JavaScript

#### Features
- **LSP**: TypeScript Language Server
- **Formatting**: Prettier with automatic configuration detection
- **Linting**: ESLint integration
- **Debugging**: Chrome DevTools protocol
- **Framework Support**: React, Vue, Angular, Node.js

#### Configuration
```lua
-- Located in: lua/plugins/typescript.lua
typescript = {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}
```

#### Custom Keybindings
```
<leader>co               -- Organize imports
<leader>cM               -- Add missing imports
<leader>cu               -- Remove unused imports
<leader>cV               -- Select TypeScript version
```

#### Dependencies
```bash
# Global tools
npm install -g typescript typescript-language-server
npm install -g prettier eslint
npm install -g @types/node  # For Node.js projects
```

### Go

#### Features
- **LSP**: gopls for comprehensive Go support
- **Formatting**: gofumpt for enhanced formatting
- **Linting**: Built into gopls
- **Debugging**: Delve debugger integration
- **Testing**: Go test integration
- **Build Tools**: Go modules and build support

#### Configuration
```lua
-- Located in: lua/plugins/go.lua
{
  "ray-x/go.nvim",
  "ray-x/guihua.lua",
  "leoluz/nvim-dap-go",
}
```

#### Go-specific Commands
```
:GoRun                   -- Run current file
:GoTest                  -- Run tests
:GoCoverage              -- Show test coverage
:GoImpl                  -- Generate interface implementation
:GoFillStruct            -- Fill struct with default values
```

#### Usage
```
<leader>gt               -- Run tests
<leader>gT               -- Run test file
<leader>gc               -- Show coverage
<leader>gi               -- Generate interface
```

#### Dependencies
```bash
# Go tools (installed automatically by go.nvim)
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install mvdan.cc/gofumpt@latest
```

### Rust

#### Features
- **LSP**: rust-analyzer for comprehensive Rust support
- **Formatting**: rustfmt integration
- **Linting**: Clippy integration
- **Debugging**: LLDB/GDB support
- **Cargo Integration**: Build, test, and run commands
- **Crate Management**: Dependency handling

#### LSP Configuration
```lua
-- Located in: lua/plugins/nvim-lspconfig.lua
rust_analyzer = {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      procMacro = {
        enable = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
}
```

#### Usage
```
:RustRun                 -- Run current project
:RustTest                -- Run tests
:RustFmt                 -- Format code
:RustAnalyzer            -- Analyzer commands
```

#### Dependencies
```bash
# Rust toolchain
rustup component add rust-analyzer
rustup component add rustfmt
rustup component add clippy
```

### Lua

#### Features
- **LSP**: lua-language-server with Neovim API support
- **Formatting**: stylua for consistent formatting
- **Linting**: selene for Lua-specific linting
- **Debugging**: One Small Step for debugging Lua scripts
- **Neovim Integration**: Full API completion and documentation

#### Configuration
```lua
-- Located in: lua/plugins/nvim-lspconfig.lua
lua_ls = {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        globals = { "vim", "use", "describe", "it", "before_each", "after_each" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      telemetry = { enable = false },
    },
  },
}
```

#### Dependencies
```bash
# Lua tools
brew install lua-language-server stylua selene  # macOS
# Or install via Mason: :Mason
```

## Infrastructure and Configuration Languages

### Terraform

#### Features
- **LSP**: terraform-ls for HCL support
- **Formatting**: terraform fmt
- **Linting**: tflint integration
- **Documentation**: Terraform docs integration
- **Providers**: Auto-completion for providers

#### Configuration
```lua
-- Located in: lua/plugins/terraform.lua
{
  "ANGkeith/telescope-terraform-doc.nvim",
  "cappyzawa/telescope-terraform.nvim",
}
```

#### Usage
```
:Terraform plan          -- Run terraform plan
:Terraform apply         -- Run terraform apply
<leader>td               -- Terraform docs
<leader>tp               -- Terraform providers
```

### Ansible

#### Features
- **LSP**: ansible-language-server
- **Syntax**: YAML with Jinja2 templating
- **Linting**: ansible-lint integration
- **Documentation**: Module documentation

#### Configuration
```lua
-- Located in: lua/plugins/ansible.lua
{
  "mfussenegger/nvim-ansible",
}
```

### YAML/JSON

#### Features
- **Schema Validation**: SchemaStore integration
- **LSP**: yaml-language-server, json-language-server
- **Formatting**: Prettier integration
- **Linting**: yamllint, jsonlint

#### Schema Support
- Kubernetes manifests
- Docker Compose files
- GitHub Actions workflows
- Package.json files
- And many more via SchemaStore

### Helm

#### Features
- **Syntax**: Helm template syntax highlighting
- **LSP**: Integration with YAML LSP for values
- **Templating**: Go template support

#### Configuration
```lua
-- Located in: lua/plugins/helm.lua
{
  "towolf/vim-helm",
}
```

## Adding New Language Support

### 1. LSP Server Setup

```lua
-- Add to lua/plugins/nvim-lspconfig.lua
servers = {
  your_language_server = {
    settings = {
      -- Language server specific settings
    },
    filetypes = { "your_filetype" },
    cmd = { "language-server-command" },
  },
}
```

### 2. Formatter Configuration

```lua
-- Add to lua/plugins/conform.lua
formatters_by_ft = {
  your_filetype = { "your_formatter" },
}
```

### 3. Linter Setup

```lua
-- Add to lua/plugins/nvim-lint.lua
linters_by_ft = {
  your_filetype = { "your_linter" },
}
```

### 4. Debugger Integration

```lua
-- Add to lua/plugins/nvim-dap.lua
dap.adapters.your_debugger = {
  type = "executable",
  command = "debugger-command",
  args = { "args" },
}

dap.configurations.your_filetype = {
  {
    type = "your_debugger",
    request = "launch",
    name = "Debug configuration",
    -- Additional config
  },
}
```

### 5. Treesitter Parser

```lua
-- Add to lua/plugins/nvim-treesitter.lua
ensure_installed = {
  "your_language",
}
```

## Language-Specific Tips

### Python Development

1. **Virtual Environments**: Use `:VenvSelect` to switch between environments
2. **Testing**: Leverage pytest integration with debugging support
3. **Type Checking**: Enable mypy for better type safety
4. **Jupyter**: Use built-in Jupyter notebook support

### JavaScript/TypeScript

1. **Framework Detection**: Configuration auto-detects React, Vue, etc.
2. **Package.json**: LSP provides completion for npm scripts
3. **Import Management**: Automatic import organization and optimization
4. **Type Annotations**: Inlay hints show type information

### Go Development

1. **Module Management**: Automatic go.mod detection and management
2. **Interface Implementation**: Generate implementations automatically
3. **Test Coverage**: Visual test coverage in the editor
4. **Build Tags**: Support for conditional compilation

### Rust Development

1. **Cargo Integration**: Full cargo command support
2. **Macro Expansion**: See expanded macros in hover
3. **Trait Implementation**: Automatic trait implementation generation
4. **Error Handling**: Enhanced error messages with suggestions

## Performance Considerations

### Large Files

The configuration automatically optimizes for large files by:
- Disabling expensive features for files > 1MB
- Using faster parsers when available
- Reducing LSP features for better performance

### Multi-Language Projects

For projects with multiple languages:
- LSP servers load only for relevant file types
- Language-specific plugins are lazy-loaded
- Shared formatters (like Prettier) work across file types

## Troubleshooting Language Issues

### LSP Not Working

```vim
:LspInfo                 -- Check LSP status
:Mason                   -- Verify server installation
:checkhealth lsp         -- Health check
```

### Formatter Issues

```vim
:ConformInfo             -- Check formatter status
:checkhealth conform     -- Health check
```

### Debugger Problems

```vim
:checkhealth dap         -- Check DAP status
```

### Common Solutions

1. **Restart LSP**: `:LspRestart`
2. **Update Servers**: `:Mason` → `U` to update all
3. **Clear Cache**: `:Lazy clean` and restart
4. **Check Dependencies**: Ensure language tools are installed

This language support guide should help you leverage the full capabilities of this configuration for multi-language development.
