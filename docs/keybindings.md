# Keybindings Reference

Auto-generated reference of keybindings in this Neovim configuration.

- **Leader**: `<Space>` · **Local Leader**: `<Space>`
- Press `<leader>?` for buffer-local which-key, or `<leader>sk` to search all
  keymaps.

## General

| Key         | Mode    | Description                       |
| ----------- | ------- | --------------------------------- |
| `jk`        | i       | Exit insert mode                  |
| `jj`        | i       | Exit insert mode                  |
| `<Esc>`     | i,n,s   | Escape and clear hlsearch         |
| `<C-s>`     | i,x,n,s | Save File                         |
| `n`         | n/x/o   | Next search result (centered)     |
| `N`         | n/x/o   | Previous search result (centered) |
| `<`         | x       | Indent left, keep selection       |
| `>`         | x       | Indent right, keep selection      |
| `gco`       | n       | Add comment below                 |
| `gcO`       | n       | Add comment above                 |
| `gc`        | n/x     | Toggle comment                    |
| `gcc`       | n       | Toggle comment line               |
| `<A-j>`     | n/v/i   | Move line/selection down          |
| `<A-k>`     | n/v/i   | Move line/selection up            |
| `<C-h>`     | n       | Go to left window                 |
| `<C-j>`     | n       | Go to lower window                |
| `<C-k>`     | n       | Go to upper window                |
| `<C-l>`     | n       | Go to right window                |
| `<C-Up>`    | n       | Increase window height            |
| `<C-Down>`  | n       | Decrease window height            |
| `<C-Left>`  | n       | Decrease window width             |
| `<C-Right>` | n       | Increase window width             |

## File & Project (`<leader>f`, `<leader>e`)

| Key               | Mode | Description                |
| ----------------- | ---- | -------------------------- |
| `<leader>/`       | n    | Grep (Root Dir)            |
| `<leader><Space>` | n    | Find Files (Root Dir)      |
| `<leader>E`       | n    | Explorer Snacks (root dir) |
| `<leader>e`       | n    | Explorer Snacks (cwd)      |
| `<leader>fB`      | n    | Buffers (all)              |
| `<leader>fE`      | n    | Explorer Snacks (root dir) |
| `<leader>fF`      | n    | Find Files (cwd)           |
| `<leader>fR`      | n    | Recent (cwd)               |
| `<leader>fT`      | n    | Terminal (cwd)             |
| `<leader>fb`      | n    | Buffers                    |
| `<leader>fc`      | n    | Find Config File           |
| `<leader>fe`      | n    | Explorer Snacks (cwd)      |
| `<leader>ff`      | n    | Find Files (Root Dir)      |
| `<leader>fg`      | n    | Find Files (git-files)     |
| `<leader>fn`      | n    | New File                   |
| `<leader>fp`      | n    | Projects                   |
| `<leader>fr`      | n    | Recent                     |
| `<leader>ft`      | n    | Terminal (Root Dir)        |

## Buffers (`<leader>b`)

| Key          | Mode | Description                 |
| ------------ | ---- | --------------------------- |
| `<leader>bD` | n    | Delete Buffer and Window    |
| `<leader>bP` | n    | Delete Non-Pinned Buffers   |
| `<leader>bb` | n    | Switch to Other Buffer      |
| `<leader>bd` | n    | Delete Buffer               |
| `<leader>bi` | n    | Show Buffer Info            |
| `<leader>bl` | n    | Delete Buffers to the Left  |
| `<leader>bo` | n    | Delete Other Buffers        |
| `<leader>bp` | n    | Toggle Pin                  |
| `<leader>br` | n    | Delete Buffers to the Right |
| `[b`         | n    | Prev Buffer                 |
| `]b`         | n    | Next Buffer                 |

## Search (`<leader>s`)

| Key          | Mode | Description            |
| ------------ | ---- | ---------------------- |
| `<leader>s"` | n    | Registers              |
| `<leader>s/` | n    | Search History         |
| `<leader>sB` | n    | Grep Open Buffers      |
| `<leader>sC` | n    | Commands               |
| `<leader>sD` | n    | Buffer Diagnostics     |
| `<leader>sG` | n    | Grep (cwd)             |
| `<leader>sH` | n    | Highlights             |
| `<leader>sM` | n    | Man Pages              |
| `<leader>sR` | n    | Resume                 |
| `<leader>sT` | n    | Todo/Fix/Fixme         |
| `<leader>sW` | n    | Search word (cwd)      |
| `<leader>sa` | n    | Autocmds               |
| `<leader>sb` | n    | Buffer Lines           |
| `<leader>sc` | n    | Command History        |
| `<leader>sd` | n    | Diagnostics            |
| `<leader>sg` | n    | Grep (Root Dir)        |
| `<leader>sh` | n    | Help Pages             |
| `<leader>si` | n    | Icons                  |
| `<leader>sj` | n    | Jumps                  |
| `<leader>sk` | n    | Keymaps                |
| `<leader>sl` | n    | Location List          |
| `<leader>sm` | n    | Marks                  |
| `<leader>sp` | n    | Search for Plugin Spec |
| `<leader>sq` | n    | Quickfix List          |
| `<leader>sr` | n    | Search and Replace     |
| `<leader>st` | n    | Todo                   |
| `<leader>su` | n    | Undotree               |
| `<leader>sw` | n    | Search word (Root Dir) |
| `<leader>sz` | n    | Fuzzy grep             |

## Git (`<leader>g`)

| Key           | Mode | Description                    |
| ------------- | ---- | ------------------------------ |
| `<leader>gB`  | n    | Git Browse (open)              |
| `<leader>gC`  | n    | Git Buffer Commits             |
| `<leader>gD`  | n    | Git Diff (origin)              |
| `<leader>gG`  | n    | Lazygit (cwd)                  |
| `<leader>gH`  | n    | GitHub Dashboard (gh-dash)     |
| `<leader>gI`  | n    | GitHub Issues (all)            |
| `<leader>gL`  | n    | Git Log (cwd)                  |
| `<leader>gO`  | n    | GitHub PRs (Octo)              |
| `<leader>gP`  | n    | GitHub Pull Requests (all)     |
| `<leader>gR`  | n    | GitHub Actions Runs            |
| `<leader>gS`  | n    | Git Stash                      |
| `<leader>gY`  | n    | Git Browse (copy)              |
| `<leader>gb`  | n    | Git Blame Line                 |
| `<leader>gbl` | n    | Git Blame Line                 |
| `<leader>gc`  | n    | Git Commits                    |
| `<leader>gd`  | n    | Git Diff (hunks)               |
| `<leader>gf`  | n    | Git Current File History       |
| `<leader>gg`  | n    | Lazygit (Root Dir)             |
| `<leader>ghb` | n    | GitHub Blame Current Line      |
| `<leader>gi`  | n    | GitHub Issues (open)           |
| `<leader>gl`  | n    | Git Log                        |
| `<leader>go`  | n    | Toggle mini.diff overlay       |
| `<leader>gp`  | n    | GitHub Pull Requests (open)    |
| `<leader>gs`  | n    | Git Status                     |
| `<leader>gv`  | n    | PR Checks (watch CI)           |
| `<leader>gwn` | n    | Create new Git Worktree        |
| `<leader>gws` | n    | Git Worktree switch            |
| `<leader>gy`  | n    | Open in git repository browser |

## Code (`<leader>c`)

| Key          | Mode | Description                              |
| ------------ | ---- | ---------------------------------------- |
| `<leader>cF` | n    | Format Injected Langs                    |
| `<leader>cS` | n    | LSP references/definitions/... (Trouble) |
| `<leader>cd` | n    | Line Diagnostics                         |
| `<leader>cf` | n    | Format                                   |
| `<leader>cm` | n    | Mason                                    |
| `<leader>co` | n    | Organize Imports                         |
| `<leader>cs` | n    | Symbols (Trouble)                        |

## Diagnostics & Quickfix (`<leader>x`, `[d`, `]d`)

| Key          | Mode | Description                  |
| ------------ | ---- | ---------------------------- |
| `<leader>xL` | n    | Location List (Trouble)      |
| `<leader>xQ` | n    | Quickfix List (Trouble)      |
| `<leader>xT` | n    | Todo/Fix/Fixme (Trouble)     |
| `<leader>xX` | n    | Buffer Diagnostics (Trouble) |
| `<leader>xl` | n    | Location List                |
| `<leader>xq` | n    | Quickfix List                |
| `<leader>xt` | n    | Todo (Trouble)               |
| `<leader>xx` | n    | Diagnostics (Trouble)        |
| `[d`         | n    | Prev Diagnostic              |
| `[e`         | n    | Prev Error                   |
| `[q`         | n    | Previous Quickfix            |
| `[t`         | n    | Previous Todo Comment        |
| `[w`         | n    | Prev Warning                 |
| `]d`         | n    | Next Diagnostic              |
| `]e`         | n    | Next Error                   |
| `]q`         | n    | Next Quickfix                |
| `]t`         | n    | Next Todo Comment            |
| `]w`         | n    | Next Warning                 |

## Debugging (`<leader>d`)

| Key           | Mode | Description                |
| ------------- | ---- | -------------------------- |
| `<leader>dB`  | n    | Breakpoint Condition       |
| `<leader>dC`  | n    | Run to Cursor              |
| `<leader>dO`  | n    | Step Over                  |
| `<leader>dP`  | n    | Pause                      |
| `<leader>da`  | n    | Run with Args              |
| `<leader>db`  | n    | Toggle Breakpoint          |
| `<leader>dc`  | n    | Run/Continue               |
| `<leader>de`  | n    | Eval                       |
| `<leader>dg`  | n    | Go to Line (No Execute)    |
| `<leader>di`  | n    | Step Into                  |
| `<leader>dj`  | n    | Down                       |
| `<leader>dk`  | n    | Up                         |
| `<leader>dl`  | n    | Run Last                   |
| `<leader>do`  | n    | Step Out                   |
| `<leader>dph` | n    | Toggle Profiler Highlights |
| `<leader>dpp` | n    | Toggle Profiler            |
| `<leader>dps` | n    | Profiler Scratch Buffer    |
| `<leader>dr`  | n    | Toggle REPL                |
| `<leader>ds`  | n    | Session                    |
| `<leader>dt`  | n    | Terminate                  |
| `<leader>du`  | n    | Dap UI                     |
| `<leader>dw`  | n    | Widgets                    |

## UI Toggles (`<leader>u`)

| Key          | Mode | Description                              |
| ------------ | ---- | ---------------------------------------- |
| `<leader>uA` | n    | Toggle Tabline                           |
| `<leader>uC` | n    | Colorschemes                             |
| `<leader>uD` | n    | Toggle Dimming                           |
| `<leader>uF` | n    | Toggle Auto Format (Buffer)              |
| `<leader>uG` | n    | Toggle Mini Diff Signs                   |
| `<leader>uI` | n    | Inspect Tree                             |
| `<leader>uL` | n    | Toggle Relative Number                   |
| `<leader>uS` | n    | Toggle Smooth Scroll                     |
| `<leader>uT` | n    | Toggle Treesitter Highlight              |
| `<leader>uZ` | n    | Toggle Zoom Mode                         |
| `<leader>ua` | n    | Toggle Animations                        |
| `<leader>ub` | n    | Toggle Dark Background                   |
| `<leader>uc` | n    | Toggle Conceal Level                     |
| `<leader>ud` | n    | Toggle Diagnostics                       |
| `<leader>uf` | n    | Toggle Auto Format (Global)              |
| `<leader>ug` | n    | Toggle Indent Guides                     |
| `<leader>uh` | n    | Toggle Inlay Hints                       |
| `<leader>ui` | n    | Inspect Pos                              |
| `<leader>ul` | n    | Toggle Line Numbers                      |
| `<leader>un` | n    | Dismiss All Notifications                |
| `<leader>up` | n    | Toggle Mini Pairs                        |
| `<leader>ur` | n    | Redraw / Clear hlsearch / Diff Update    |
| `<leader>us` | n    | Toggle Spelling                          |
| `<leader>uw` | n    | Toggle Wrap                              |
| `<leader>uz` | n    | Toggle Zen Mode                          |
| `<leader>uv` | n    | Toggle Diagnostic Virtual Lines _(0.12)_ |

## Obsidian Notes (`<leader>o`)

| Key          | Mode | Description                                   |
| ------------ | ---- | --------------------------------------------- |
| `<leader>oD` | n    | Browse daily notes                            |
| `<leader>oN` | n    | New note                                      |
| `<leader>oO` | n    | New organization note                         |
| `<leader>oP` | n    | New project note                              |
| `<leader>ob` | n    | Show backlinks                                |
| `<leader>od` | n    | Today's note                                  |
| `<leader>of` | n    | Search notes                                  |
| `<leader>ol` | n    | Show links                                    |
| `<leader>om` | n    | New meeting note                              |
| `<leader>on` | n    | Insert template and remove leading whitespace |
| `<leader>oo` | n    | Navigate to Obsidian Vault                    |
| `<leader>op` | n    | New person note                               |
| `<leader>oq` | n    | Quick switch notes                            |
| `<leader>or` | n    | Rename note                                   |
| `<leader>os` | n    | Find files in Obsidian Vault                  |
| `<leader>ot` | n    | Search tags                                   |
| `<leader>oy` | n    | Yesterday's note                              |
| `<leader>oz` | n    | Grep in Obsidian Vault                        |

## AI Assistance (`<leader>O`)

| Key          | Mode    | Description                     |
| ------------ | ------- | ------------------------------- |
| `<leader>OA` | n, x, s | Ask opencode about current file |
| `<leader>OT` | x, s    | Test selection                  |
| `<leader>Oa` | n, x, s | Ask opencode                    |
| `<leader>Od` | x, s    | Document selection              |
| `<leader>Oe` | n       | Explain code near cursor        |
| `<leader>Of` | n       | Fix errors                      |
| `<leader>On` | n       | New session                     |
| `<leader>Oo` | x, s    | Optimize selection              |
| `<leader>Or` | n       | Review file                     |
| `<leader>Ot` | n       | Toggle opencode                 |

## Sessions & Quit (`<leader>q`)

| Key          | Mode | Description                |
| ------------ | ---- | -------------------------- |
| `<leader>qR` | n    | Restart Nvim               |
| `<leader>qS` | n    | Select Session             |
| `<leader>qd` | n    | Don't Save Current Session |
| `<leader>ql` | n    | Restore Last Session       |
| `<leader>qq` | n    | Quit All                   |
| `<leader>qs` | n    | Restore Session            |

## Windows (`<leader>w`) & Tabs (`<leader><tab>`)

| Key                  | Mode | Description        |
| -------------------- | ---- | ------------------ |
| `<leader>-`          | n    | Split Window Below |
| `<leader><Tab><Tab>` | n    | New Tab            |
| `<leader><Tab>[`     | n    | Previous Tab       |
| `<leader><Tab>]`     | n    | Next Tab           |
| `<leader><Tab>d`     | n    | Close Tab          |
| `<leader><Tab>f`     | n    | First Tab          |
| `<leader><Tab>l`     | n    | Last Tab           |
| `<leader><Tab>o`     | n    | Close Other Tabs   |
| `<leader>w`          | n    | Windows            |
| `<leader>wd`         | n    | Delete Window      |
| `<leader>wm`         | n    | Toggle Zoom Mode   |
| `<leader>            | `    | n                  |

## Miscellaneous

| Key          | Mode | Description            |
| ------------ | ---- | ---------------------- |
| `<leader>.`  | n    | Toggle Scratch Buffer  |
| `<leader>:`  | n    | Command History        |
| `<leader>K`  | n    | Keywordprg             |
| `<leader>S`  | n    | Select Scratch Buffer  |
| `<leader>` ` | n    | Switch to Other Buffer |
| `<leader>l`  | n    | Lazy                   |
| `<leader>n`  | n    | Notification History   |
| `<leader>p`  | n    | Open Yank History      |
| `<leader>td` | n    | Debug Nearest          |
| `<leader>ts` | n    | Typr Stats             |
| `<leader>ty` | n    | Open Typr              |

## LSP (buffer-local, on attach)

| Key          | Mode | Description                                        |
| ------------ | ---- | -------------------------------------------------- |
| `gd`         | n    | Goto Definition (picker)                           |
| `gr`         | n    | References (picker)                                |
| `gI`         | n    | Goto Implementation (picker)                       |
| `gy`         | n    | Goto Type Definition (picker)                      |
| `gD`         | n    | Goto Declaration                                   |
| `gai`        | n    | Incoming Calls (picker)                            |
| `gao`        | n    | Outgoing Calls (picker)                            |
| `K`          | n    | Hover _(native 0.12 default)_                      |
| `gK`         | n    | Signature Help                                     |
| `<C-k>`      | i    | Signature Help                                     |
| `<C-S>`      | i    | Signature Help _(native 0.12 default)_             |
| `<M-y>`      | i    | Trigger/Accept Inline Completion _(0.12)_          |
| `gra`        | n,x  | Code Action _(native default)_                     |
| `grn`        | n    | Rename _(native default)_                          |
| `grt`        | n    | Type Definition _(native default)_                 |
| `grx`        | n    | Run Codelens _(native default)_                    |
| `gO`         | n    | Document Symbols _(native default)_                |
| `gx`         | n    | Open link/document under cursor _(native default)_ |
| `<leader>cl` | n    | Lsp Info (config picker)                           |
| `<leader>ca` | n,x  | Code Action                                        |
| `<leader>cA` | n    | Source Action                                      |
| `<leader>cr` | n    | Rename                                             |
| `<leader>cR` | n    | Rename File                                        |
| `<leader>cc` | n,v  | Run Codelens                                       |
| `<leader>cC` | n    | Refresh Codelens                                   |
| `<leader>cd` | n    | Line Diagnostics                                   |
| `<leader>ss` | n    | LSP Symbols (picker)                               |
| `<leader>sS` | n    | LSP Workspace Symbols (picker)                     |
| `]]`         | n    | Next Reference (word)                              |
| `[[`         | n    | Prev Reference (word)                              |
| `<A-n>`      | n    | Next Reference (word, all windows)                 |
| `<A-p>`      | n    | Prev Reference (word, all windows)                 |

## Completion (blink.cmp, insert mode)

| Key           | Mode | Description                               |
| ------------- | ---- | ----------------------------------------- |
| `<Tab>`       | i    | Accept / jump to next snippet placeholder |
| `<S-Tab>`     | i    | Jump to previous snippet placeholder      |
| `<C-Space>`   | i    | Show completion / toggle documentation    |
| `<C-y>`       | i    | Accept completion                         |
| `<C-e>`       | i    | Hide completion menu                      |
| `<C-n>/<C-p>` | i    | Select next/previous item                 |

## Treesitter & Flash Navigation

| Key       | Mode | Description                               |
| --------- | ---- | ----------------------------------------- |
| `an`      | x    | Select parent (outer) treesitter node     |
| `in`      | x    | Select child (inner) treesitter node      |
| `]n`      | x    | Select next node                          |
| `[n`      | x    | Select previous node                      |
| `]N`      | x    | Expand selection to next sibling node     |
| `[N`      | x    | Expand selection to previous sibling node |
| `]f / ]F` | n    | Next function start/end                   |
| `]c / ]C` | n    | Next class start/end                      |
| `]a / ]A` | n    | Next parameter start/end                  |
| `[f / [F` | n    | Previous function start/end               |
| `[c / [C` | n    | Previous class start/end                  |
| `[a / [A` | n    | Previous parameter start/end              |
| `s`       | n,x  | Flash jump                                |
| `S`       | n,x  | Flash Treesitter (select node)            |
| `R`       | x    | Treesitter Search (flash)                 |

## Surrounding (mini.surround)

| Key   | Mode | Description                    |
| ----- | ---- | ------------------------------ |
| `gsa` | n,x  | Add surrounding                |
| `gsd` | n    | Delete surrounding             |
| `gsr` | n    | Replace surrounding            |
| `gsf` | n    | Find right surrounding         |
| `gsF` | n    | Find left surrounding          |
| `gsh` | n    | Highlight surrounding          |
| `gsn` | n    | Update `mini.surround` n_lines |

## Yank & Paste (yanky.nvim)

| Key         | Mode | Description                         |
| ----------- | ---- | ----------------------------------- |
| `p / P`     | n    | Put with indent tracking (yanky)    |
| `<leader>p` | n,x  | Open yank history (picker)          |
| `]y`        | n    | Cycle forward through yank history  |
| `[y`        | n    | Cycle backward through yank history |
| `gp / gP`   | n,x  | Put text after/before selection     |

## Terminal

| Key           | Mode | Description                     |
| ------------- | ---- | ------------------------------- |
| `<C-/>`       | n    | Toggle terminal (root dir)      |
| `<leader>ft`  | n    | Terminal (root dir)             |
| `<leader>fT`  | n    | Terminal (cwd)                  |
| `<Esc><Esc>`  | t    | Exit terminal mode              |
| `<C-h/j/k/l>` | t    | Navigate out of terminal window |
