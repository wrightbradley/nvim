# GitHub PR Review Workflow

This guide covers reviewing pull requests, monitoring CI, and working with
GitHub Actions entirely from Neovim. No browser required until you actually want
to look at the GitHub UI.

## Prerequisites

```bash
gh auth login          # one-time GitHub CLI auth
brew install gh-dash   # optional, enables the dashboard float (<leader>gH)
```

## Tool Overview

| Key           | Tool              | Use for                                        |
| ------------- | ----------------- | ---------------------------------------------- |
| `<leader>gO`  | octo.nvim         | Full PR review: comments, threads, approvals   |
| `<leader>gp`  | Snacks picker     | Quick browse of open PRs                       |
| `<leader>gP`  | Snacks picker     | Browse all PRs (open/closed/merged)            |
| `<leader>gi`  | Snacks picker     | Quick browse of open issues                    |
| `<leader>gI`  | Snacks picker     | Browse all issues                              |
| `<leader>gH`  | gh-dash (float)   | Dashboard: PR queue + CI status at a glance    |
| `<leader>gv`  | gh CLI (float)    | Watch CI checks for the current branch's PR    |
| `<leader>gR`  | gh CLI (float)    | List GitHub Actions runs                       |
| `<leader>gc`  | gh-addressed.nvim | Track review threads left on your own PRs      |
| `<leader>gg`  | lazygit           | Staging, committing, rebasing                  |
| `<leader>gws` | worktrees.nvim    | Switch worktrees (review multiple PRs at once) |
| `<leader>gwn` | worktrees.nvim    | Create a new worktree                          |

## Flow 1: Reviewing Someone Else's PR

The full write-loop lives in octo.nvim.

### 1. Find and open the PR

```
<leader>gO        -- Octo PR list (Snacks picker, fuzzy filter)
```

Pick a PR to open its summary buffer: description, labels, reviewers, timeline,
and changed files.

### 2. Read the code

Open changed files from the PR buffer. Files load as real buffers, so your
entire setup works normally:

- LSP go-to-definition (`gd`), references (`gr`), hover (`K`)
- Treesitter text objects and folding
- Flash navigation

Useful while reading:

```
gd                -- Go to definition (follows code across the repo)
gr                -- References
gy                -- Open file/line on github.com
<C-r>             -- Reload the octo buffer (fetch latest state)
```

### 3. Leave review comments

Start a pending review, then anchor comments to specific lines:

```vim
:Octo review start        " begin a pending review
:Octo comment add         " comment on the line under cursor
:Octo review submit       " finish: choose Comment / Approve / Request Changes
```

Other useful thread commands:

```vim
:Octo thread resolve      " resolve the thread under cursor
:Octo reaction add        " react to a comment
```

Inside octo buffers there are many buffer-local mappings — press `<leader>?`
(which-key, buffer scope) or see `:h octo-mappings` for the full list rather
than memorizing them.

### 4. Run the PR locally (optional)

```vim
:Octo pr checkout         " check out the PR branch
```

Pair this with worktrees to keep your own branch intact:

```
<leader>gwn               -- new worktree for the review
:Octo pr checkout
... test/build/run ...
<leader>gws               -- switch back to your worktree when done
```

## Flow 2: Self-Review Before Opening a PR

Before pushing, review your own diff against the base branch:

```
<leader>gD        -- Git Diff vs origin (grouped by file)
<leader>gd        -- Git Diff (working-tree hunks)
<leader>gg        -- lazygit for staging and commit surgery
```

For a deeper pass, walk history per file:

```
<leader>gC        -- Commits touching current buffer
<leader>gc        -- Repo commit history
```

## Flow 3: Monitoring CI

After pushing:

```
<leader>gv        -- gh pr checks --watch (float, live status)
<leader>gR        -- gh run list (recent Actions runs)
<leader>gH        -- gh-dash dashboard (all PRs + their CI)
```

`<leader>gv` follows the current branch's PR; press `q` in the float to close
it. If checks fail, jump back into the code, fix, and re-push — then re-run
`<leader>gv`.

## Flow 4: Addressing Feedback on Your Own PR

When reviewers leave comments on your PR:

```
<leader>gc        -- GhReviewComments: all unresolved threads (Trouble list)
```

Work through each item, then re-request review via octo:

```vim
:Octo pr ready            " mark draft PR ready for review
```

Blame context when investigating old code:

```
<leader>ghb       -- GitHub blame for current line (links to the PR)
<leader>gbl       -- Local blame line (float)
```

## Quick Reference: A Complete Review Session

```
<leader>gO            pick PR from list
<C-r>                 refresh PR state
(open changed files)  read with LSP/Treesitter
:Octo review start    begin pending review
:Octo comment add     anchor comments while reading
:Octo pr checkout     run it locally (optional, worktree-safe)
:Octo review submit   approve / request changes / comment
<leader>gv            confirm CI is green before approving
```

## Troubleshooting

| Symptom                           | Fix                                                              |
| --------------------------------- | ---------------------------------------------------------------- |
| `gh-dash` warning on `<leader>gH` | `brew install gh-dash`                                           |
| Octo can't find the repo          | Ensure remote uses SSH/HTTPS you're authed for; `gh auth status` |
| Stale PR state                    | `<C-r>` in the octo buffer                                       |
| Rate limit errors                 | `gh auth login` (octo uses your gh credentials)                  |
