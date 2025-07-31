# Development Workflow Guide

This guide covers how to effectively use this Neovim configuration for software development, including debugging, testing, formatting, and project management.

## Project Management

### 1. Project Root Detection

The configuration automatically detects project roots using multiple strategies:

- Git repositories (`.git`)
- Package files (`package.json`, `Cargo.toml`, `pyproject.toml`)
- Configuration files (`.prettierrc`, `.eslintrc`, etc.)

#### Changing Project Root
```
<leader>fp  -- Project picker
```

### 2. File and Buffer Management

#### Finding Files
```
<leader><space>  -- Find files in project
<leader>ff       -- Find files (root dir)
<leader>fF       -- Find files (current dir)
<leader>fg       -- Git files only
<leader>fr       -- Recent files
<leader>fc       -- Config files
```

#### Buffer Management
```
<leader>,        -- Switch buffers
<leader>bp       -- Pin buffer
<leader>br       -- Close buffers to right
<leader>bl       -- Close buffers to left
```

#### File Explorer
```
<leader>e        -- Toggle file explorer (root)
<leader>E        -- Toggle file explorer (cwd)
```

## Code Development Workflow

### 1. Language Server Protocol (LSP)

#### LSP Actions
```
gd               -- Go to definition
gD               -- Go to declaration
gr               -- Go to references
gI               -- Go to implementation
K                -- Show hover documentation
<leader>ca       -- Code actions
<leader>cr       -- Rename symbol
<leader>cf       -- Format code
```

#### Diagnostics
```
]d               -- Next diagnostic
[d               -- Previous diagnostic
<leader>cd       -- Line diagnostics
<leader>cD       -- Workspace diagnostics
```

### 2. Code Completion

#### Blink.cmp Features
- **Intelligent completion** with context awareness
- **Snippet expansion** with tab navigation
- **LSP integration** for accurate suggestions
- **AI completion** via Copilot integration

#### Completion Controls
```
<Tab>            -- Accept completion / expand snippet
<S-Tab>          -- Previous completion item
<C-Space>        -- Trigger completion
<C-e>            -- Close completion menu
```

### 3. Code Formatting

#### Format on Save
The configuration automatically formats code on save using:
- **conform.nvim** for primary formatting
- **LSP formatters** as fallback

#### Manual Formatting
```
<leader>cf       -- Format current buffer
<leader>cF       -- Format with specific formatter
```

#### Supported Formatters
- **Lua**: stylua
- **Python**: black, isort
- **JavaScript/TypeScript**: prettier
- **Go**: gofumpt
- **Rust**: rustfmt
- **JSON/YAML**: prettier

## Debugging Workflow

### 1. Debug Adapter Protocol (DAP)

#### Debug Controls
```
<F5>             -- Start/continue debugging
<F10>            -- Step over
<F11>            -- Step into
<F12>            -- Step out
<leader>db       -- Toggle breakpoint
<leader>dB       -- Conditional breakpoint
<leader>dr       -- Open REPL
<leader>dl       -- Run last debug session
```

#### Debug UI
```
<leader>du       -- Toggle debug UI
<leader>dh       -- Hover variables
<leader>dp       -- Preview variable
```

### 2. Language-Specific Debugging

#### Python Debugging
```python
# Set up pytest debugging
pytest --pdb test_file.py

# Django debugging
python manage.py runserver --pdb
```

#### Go Debugging
```go
// Use delve debugger integration
// Breakpoints work automatically
func main() {
    // Your code here
}
```

#### JavaScript/TypeScript
```javascript
// Chrome DevTools integration
// Set breakpoints in source code
console.log("Debug point");
```

## Testing Workflow

### 1. Running Tests

#### General Test Commands
```
<leader>tt       -- Run all tests
<leader>tf       -- Run current file tests
<leader>tn       -- Run nearest test
<leader>tl       -- Run last test
<leader>ts       -- Test summary
```

#### Language-Specific Testing

**Python:**
```bash
# pytest integration
pytest test_file.py
pytest test_file.py::test_function
pytest -v  # verbose output
```

**JavaScript/TypeScript:**
```bash
# Jest integration
npm test
npm run test:watch
npm run test:coverage
```

**Go:**
```bash
# Go test integration
go test ./...
go test -v package_name
go test -run TestFunction
```

### 2. Test-Driven Development (TDD)

#### TDD Workflow
1. Write failing test
2. Run test to see failure: `<leader>tn`
3. Write minimal code to pass
4. Run test to see pass: `<leader>tn`
5. Refactor and repeat

#### AI-Assisted Testing
```
<leader>apt      -- Generate tests for selection
<leader>aga      -- Generate tests with ChatGPT
```

## Git Integration Workflow

### 1. Git Operations

#### Basic Git Commands
```
<leader>gs       -- Git status
<leader>gc       -- Git commits
<leader>gb       -- Git branches
<leader>gd       -- Git diff (hunks)
<leader>gS       -- Git stash
```

#### Hunk Operations
```
]h               -- Next git hunk
[h               -- Previous git hunk
<leader>ghs      -- Stage hunk
<leader>ghr      -- Reset hunk
<leader>ghp      -- Preview hunk
```

#### Git Browsing
```
<leader>gy       -- Open in browser
<leader>gY       -- Copy repo URL
```

### 2. Commit Workflow

#### AI-Assisted Commits
```
<leader>apm      -- Generate commit message
<leader>apM      -- Generate commit for staged changes
```

#### Manual Commits
```bash
# Stage changes
git add .

# Traditional commit
git commit -m "feat: add new feature"

# Or use lazygit integration
<leader>gg       -- Open lazygit
```

### 3. Branch Management

#### Branch Operations
```
<leader>gb       -- Switch branches
<leader>gB       -- Create new branch
```

#### Git Worktrees
```bash
# Create worktree for feature branch
git worktree add ../feature-branch feature-branch

# Switch between worktrees
<leader>gw       -- Worktree picker
```

## AI-Enhanced Development

### 1. Code Generation

#### CodeCompanion Workflow
```
<leader>apv      -- Open AI chat
<leader>ape      -- Explain code
<leader>apf      -- Fix code issues
<leader>apr      -- Refactor code
<leader>apt      -- Generate tests
<leader>apd      -- Add documentation
```

#### Quick AI Actions
```
<leader>apq      -- Quick AI chat
<leader>apa      -- AI action palette
```

### 2. Code Review

#### AI Code Review
```
<leader>apR      -- AI code review
<leader>apl      -- Explain LSP diagnostics
```

#### Code Quality
```
<leader>apn      -- Better naming suggestions
<leader>ago      -- Optimize code (ChatGPT)
<leader>agl      -- Readability analysis
```

## Search and Navigation

### 1. Fuzzy Finding

#### File Search
```
<leader><space>  -- Find files
<leader>/        -- Grep in files
<leader>sw       -- Search word under cursor
<leader>sg       -- Live grep
```

#### Code Navigation
```
<leader>ss       -- Search symbols
<leader>sj       -- Search jump list
<leader>sm       -- Search marks
<leader>sr       -- Search registers
```

### 2. Advanced Search

#### Regex Search
```
<leader>sg       -- Live grep with regex
<leader>sG       -- Grep in current directory
<leader>sB       -- Grep in open buffers
```

#### Symbol Search
```
<leader>ss       -- Workspace symbols
<leader>sS       -- Document symbols
gI               -- Implementation
gr               -- References
```

## Performance and Optimization

### 1. Profiling

#### Startup Performance
```vim
:Lazy profile    -- Plugin loading profile
:Startup         -- Startup time breakdown
```

#### Runtime Performance
```
<leader>dps      -- Profiler scratch buffer
```

### 2. Large File Handling

The configuration automatically optimizes for large files by:
- Disabling syntax highlighting for files > 1MB
- Reducing features for better performance
- Using lazy loading for expensive operations

## Multi-Language Development

### 1. Polyglot Projects

#### Language Detection
The configuration automatically detects file types and loads appropriate:
- LSP servers
- Formatters
- Linters
- Debuggers
- Snippets

#### Per-Language Settings
Each language has optimized settings for:
- Indentation rules
- Line length limits
- Specific tooling integration

### 2. Monorepo Support

#### Project Management
```
<leader>fp       -- Switch between projects
<leader>fw       -- Find in workspace
```

#### Multi-Root Workspaces
The configuration supports multiple project roots within a single workspace.

## Productivity Tips

### 1. Efficient Editing

#### Text Objects
```
vai              -- Select function (treesitter)
vii              -- Select inner function
vaf              -- Select outer function
```

#### Quick Actions
```
<leader>.        -- Scratch buffer
<leader>S        -- Select scratch buffer
gcc              -- Comment line
gc               -- Comment selection
```

### 2. Window Management

#### Window Operations
```
<C-w>s           -- Horizontal split
<C-w>v           -- Vertical split
<C-w>c           -- Close window
<C-w>=           -- Equal window sizes
```

#### Tab Management
```
<leader><tab>n   -- New tab
<leader><tab>c   -- Close tab
<leader><tab>]   -- Next tab
<leader><tab>[   -- Previous tab
```

### 3. Session Management

#### Session Operations
```
<leader>qs       -- Save session
<leader>ql       -- Load session
<leader>qr       -- Restore last session
```

## Troubleshooting Development Issues

### 1. LSP Issues

#### Diagnostics
```vim
:LspInfo         -- Check LSP status
:LspRestart      -- Restart LSP servers
:Mason           -- Manage LSP servers
```

#### Common Fixes
```vim
:Mason           -- Update/install servers
:Lazy update     -- Update plugins
:checkhealth lsp -- Check LSP health
```

### 2. Plugin Issues

#### Plugin Management
```vim
:Lazy            -- Plugin manager
:Lazy update     -- Update plugins
:Lazy clean      -- Remove unused plugins
:Lazy profile    -- Performance analysis
```

## Best Practices

### 1. Code Organization

- Use consistent indentation and formatting
- Follow language-specific conventions
- Leverage AI for code documentation
- Regular code reviews with AI assistance

### 2. Version Control

- Make atomic commits
- Use AI for commit messages
- Regular branch cleanup
- Utilize git hooks for quality checks

### 3. Performance

- Profile regularly during development
- Use lazy loading for expensive operations
- Monitor startup time
- Keep plugins updated

This workflow guide should help you leverage the full power of this Neovim configuration for efficient software development.
