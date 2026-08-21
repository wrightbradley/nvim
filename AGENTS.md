# AGENTS.md

## Build, Lint, and Test

- **Tooling:** Tools are managed with [mise](https://mise.jdx.dev)
  (`mise.toml`); git hooks run via [hk](https://hk.jdx.dev) (`hk.pkl`).
- **Lint:** Run `mise run lint` (executes `hk check --all`: whitespace, EOF,
  YAML/JSON validity, secret detection, gitleaks, yamlfmt/yamllint, stylua,
  selene).
- **Fix:** Run `mise run fix` to auto-fix issues where possible.
- **Hooks:** Run `mise run hooks` to (re)install hk git hooks; set `HK=0` to
  bypass hooks for a single commit.
- **No explicit build or test commands** are defined; this is a Neovim
  configuration repo. Testing is typically manual or plugin-specific.

## Code Style Guidelines

- **Lua formatting:**
  - Indent with 2 spaces, max line width 120.
  - Requires/imports should be sorted (see `stylua.toml`).
  - Use idiomatic Lua/Neovim naming and modularization.
- **Linting:**
  - Selene linter with `std = "vim"`; mixed tables allowed.
- **Markdown and YAML:**
  - Prettier and markdownlint are used for formatting and style.
- **General:**
  - Avoid trailing whitespace and ensure files end with a newline.
  - Avoid committing secrets or large files (hk enforced).
- **Error handling:**
  - Follow Lua/Neovim plugin conventions for error handling.

> For more details, see `stylua.toml`, `selene.toml`, `hk.pkl`, and the tasks in
> `mise.toml`.
