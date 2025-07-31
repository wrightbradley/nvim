# Keybindings Reference

This document provides a comprehensive reference for all custom keybindings in this Neovim configuration.

## Leader Key

- **Leader**: `<Space>`
- **Local Leader**: `<Space>`

## Quick Reference

Press `<leader>?` to show the which-key help for available keybindings.

## AI and Coding Assistance

### CodeCompanion (`<leader>ap`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>apa` | n, v | Code Companion - Actions |
| `<leader>apv` | n, v | Code Companion - Toggle |
| `<leader>ape` | v | Code Companion - Explain code |
| `<leader>apf` | v | Code Companion - Fix code |
| `<leader>apl` | n, v | Code Companion - Explain LSP diagnostic |
| `<leader>apt` | v | Code Companion - Generate unit test |
| `<leader>apm` | n | Code Companion - Git commit message |
| `<leader>apM` | n | Code Companion - Git commit message (staged) |
| `<leader>apd` | v | Code Companion - Inline document code |
| `<leader>apD` | v | Code Companion - Document code |
| `<leader>apr` | v | Code Companion - Refactor code |
| `<leader>apR` | v | Code Companion - Review code |
| `<leader>apn` | v | Code Companion - Better naming |
| `<leader>apq` | n | Code Companion - Quick chat |

### ChatGPT (`<leader>ag`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>agc` | n | ChatGPT - Chat |
| `<leader>agg` | n, v | ChatGPT - Grammar Correction |
| `<leader>age` | n, v | ChatGPT - Edit with instruction |
| `<leader>agt` | n, v | ChatGPT - Translate |
| `<leader>agk` | n, v | ChatGPT - Keywords |
| `<leader>agd` | n, v | ChatGPT - Docstring |
| `<leader>aga` | n, v | ChatGPT - Add Tests |
| `<leader>ago` | n, v | ChatGPT - Optimize Code |
| `<leader>ags` | n, v | ChatGPT - Summarize |
| `<leader>agf` | n, v | ChatGPT - Fix Bugs |
| `<leader>agx` | n, v | ChatGPT - Explain Code |
| `<leader>agr` | n, v | ChatGPT - Roxygen Edit |
| `<leader>agl` | n, v | ChatGPT - Code Readability Analysis |

### OpenCode (`<leader>O`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>Ot` | n | Toggle opencode |
| `<leader>Oa` | n, v | Ask opencode |
| `<leader>OA` | n, v | Ask opencode about current file |
| `<leader>On` | n | New session |
| `<leader>Oe` | n | Explain code near cursor |
| `<leader>Or` | n | Review file |
| `<leader>Of` | n | Fix errors |
| `<leader>Oo` | v | Optimize selection |
| `<leader>Od` | v | Document selection |
| `<leader>OT` | v | Test selection |

## File and Project Management

### File Operations (`<leader>f`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader><space>` | n | Find Files (Root Dir) |
| `<leader>ff` | n | Find Files (Root Dir) |
| `<leader>fF` | n | Find Files (cwd) |
| `<leader>fg` | n | Find Files (git-files) |
| `<leader>fr` | n | Recent |
| `<leader>fR` | n | Recent (cwd) |
| `<leader>fb` | n | Buffers |
| `<leader>fB` | n | Buffers (all) |
| `<leader>fc` | n | Find Config File |
| `<leader>fp` | n | Projects |
| `<leader>fe` | n | Explorer Snacks (root dir) |
| `<leader>fE` | n | Explorer Snacks (cwd) |
| `<leader>e` | n | Explorer Snacks (root dir) |
| `<leader>E` | n | Explorer Snacks (cwd) |

### Buffer Management (`<leader>b`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>,` | n | Buffers |
| `<leader>bp` | n | Toggle Pin |
| `<leader>bP` | n | Delete Non-Pinned Buffers |
| `<leader>br` | n | Delete Buffers to the Right |
| `<leader>bl` | n | Delete Buffers to the Left |

## Search and Navigation

### Search (`<leader>s`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>/` | n | Grep (Root Dir) |
| `<leader>sg` | n | Grep (Root Dir) |
| `<leader>sG` | n | Grep (cwd) |
| `<leader>sw` | n, x | Visual selection or word (Root Dir) |
| `<leader>sW` | n, x | Visual selection or word (cwd) |
| `<leader>sb` | n | Buffer Lines |
| `<leader>sB` | n | Grep Open Buffers |
| `<leader>sp` | n | Search for Plugin Spec |
| `<leader>s"` | n | Registers |
| `<leader>s/` | n | Search History |
| `<leader>sa` | n | Autocmds |
| `<leader>sc` | n | Command History |
| `<leader>sC` | n | Commands |
| `<leader>sd` | n | Diagnostics |
| `<leader>sD` | n | Buffer Diagnostics |
| `<leader>sh` | n | Help Pages |
| `<leader>sH` | n | Highlights |
| `<leader>si` | n | Icons |
| `<leader>sj` | n | Jumps |
| `<leader>sk` | n | Keymaps |
| `<leader>sl` | n | Location List |
| `<leader>sM` | n | Man Pages |
| `<leader>sm` | n | Marks |
| `<leader>sR` | n | Resume |
| `<leader>sq` | n | Quickfix List |
| `<leader>su` | n | Undotree |

### Noice (`<leader>sn`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>snl` | n | Noice Last Message |
| `<leader>snh` | n | Noice History |
| `<leader>sna` | n | Noice All |
| `<leader>snd` | n | Dismiss All |
| `<leader>snt` | n | Noice Picker (Telescope/FzfLua) |

## Git Integration

### Git Operations (`<leader>g`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>gs` | n | Git Status |
| `<leader>gS` | n | Git Stash |
| `<leader>gc` | n | Git Commits |
| `<leader>gC` | n | Git Buffer Commits |
| `<leader>gb` | n | Git Branches |
| `<leader>gd` | n | Git Diff (hunks) |
| `<leader>gy` | n | Open in git repository browser |
| `<leader>gY` | n | Yank git repository URL |

## Code Operations

### Code Actions (`<leader>c`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>co` | n | Organize Imports |
| `<leader>cM` | n | Add missing imports |
| `<leader>cu` | n | Remove unused imports |
| `<leader>cD` | n | Go to Source Definition |
| `<leader>cV` | n | Select TypeScript Version |

## Debugging (`<leader>d`)

### Debug Profiler (`<leader>dp`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>dps` | n | Profiler Scratch Buffer |

## UI and Utilities

### UI Controls (`<leader>u`)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>un` | n | Dismiss All Notifications |
| `<leader>up` | n | Toggle UI element |

### Notifications and Utilities

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>.` | n | Toggle Scratch Buffer |
| `<leader>S` | n | Select Scratch Buffer |
| `<leader>n` | n | Notification History |
| `<leader>:` | n | Command History |

## Special Chat Keybindings

### In Chat Windows

| Key | Mode | Description |
|-----|------|-------------|
| `<CR>` | n | Send message |
| `<C-CR>` | i | Send message |
| `q` | n | Close Chat |
| `<C-c>` | n | Stop Request |
| `gA` | n | Analytics |
| `gh` | n | History |
| `gM` | n | Toggle Model |
| `gE` | n | Context Management (picker) |
| `gO` | n | Context Management (quick) |

## Escape Sequences

The configuration includes custom escape sequences for easier mode switching:

| Key Sequence | Mode | Action |
|--------------|------|--------|
| `jk` | i, c, v, s | Escape to normal mode |
| `jj` | i, c | Escape to normal mode |

## Which-Key Categories

The keybindings are organized into logical groups that appear in which-key:

- `<leader><tab>` - Tabs
- `<leader>a` - AI
- `<leader>aa` - Avante
- `<leader>ac` - Copilot
- `<leader>ag` - GPT
- `<leader>c` - Code
- `<leader>d` - Debug
- `<leader>dp` - Profiler
- `<leader>f` - File/Find
- `<leader>g` - Git
- `<leader>gh` - Hunks
- `<leader>q` - Quit/Session
- `<leader>s` - Search
- `<leader>u` - UI
- `<leader>x` - Diagnostics/Quickfix

## Tips

1. Use `<leader>?` to see available keybindings at any time
2. Many commands work in both normal and visual mode
3. AI commands work best when you have relevant code selected
4. File operations automatically use the project root when possible
5. Search operations support fuzzy matching
