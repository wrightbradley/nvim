# AGENTS.md

## Build, Lint, and Test
- **Lint:** Run `make lint` to execute all linters and pre-commit hooks.
- **Pre-commit:** Runs checks for whitespace, end-of-file, YAML/JSON validity, secret detection, and gitleaks.
- **No explicit build or test commands** are defined; this is a Neovim configuration repo. Testing is typically manual or plugin-specific.

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
  - Avoid committing secrets or large files (pre-commit enforced).
- **Error handling:**
  - Follow Lua/Neovim plugin conventions for error handling.

> For more details, see `stylua.toml`, `selene.toml`, `.pre-commit-config.yaml`, and the Makefile.