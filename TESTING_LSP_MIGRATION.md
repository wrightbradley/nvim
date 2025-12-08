# Testing Instructions: Native LSP Migration

**Branch**: `feat/migrate-native-lsp`\
**Migration**: nvim-lspconfig → Native Neovim 0.11 LSP APIs\
**Date**: 2025-12-08

## Overview

This document provides comprehensive testing instructions for the migration from
nvim-lspconfig to native Neovim 0.11 LSP configuration. All 17 LSP servers have
been migrated to use `vim.lsp.config()` and `vim.lsp.enable()`.

## Pre-Testing Setup

### 1. Ensure Clean State

```bash
cd ~/.config/nvim
git status  # Verify on feat/migrate-native-lsp branch
```

### 2. Backup Current Session

```bash
# If you have important unsaved work, save it first
```

### 3. Restart Neovim

```bash
nvim
```

**Expected**: Neovim should start without errors. Lazy.nvim will load the new
`native-lsp` plugin.

## Quick Smoke Test (5 minutes)

### Health Check

```vim
:checkhealth lsp
```

**Expected**:

- ✅ No ERROR messages
- ✅ All health checks pass
- ⚠️ WARN messages are acceptable if they existed before

### LSP Info

```vim
:LspInfo
```

**Expected**:

- Window opens showing "Language client log: ..."
- No error messages displayed

### Plugin Count Verification

```vim
:Lazy
```

**Expected**:

- Total plugin count: 77 (reduced from 78)
- `nvim-lspconfig` should NOT appear in the list
- `native-lsp` entry should exist (it's a dummy plugin)

## Priority Language Testing (30-40 minutes)

Test these languages in order of importance:

### 1. TypeScript / JavaScript (HIGH PRIORITY)

#### Test Files

Create or open test files:

```bash
# Create test directory
mkdir -p /tmp/lsp-test/ts-project
cd /tmp/lsp-test/ts-project
npm init -y
```

**Test File**: `test.ts`

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

function getUser(id: number): User {
  return {
    id,
    name: "Test User",
    email: "test@example.com"
  };
}

const user = getUser(1);
console.log(user.); // Test completion here
```

#### Test Checklist

- [ ] **LSP Attaches**: `:LspInfo` shows `vtsls` client attached
- [ ] **Completions**: After `user.`, press `<C-Space>` - should show `id`,
      `name`, `email`
- [ ] **Hover**: Place cursor on `getUser`, press `K` - shows function signature
- [ ] **Go to Definition**: `gd` on `User` interface - jumps to definition
- [ ] **Inlay Hints**: Function parameters show hints (if enabled)
- [ ] **Diagnostics**:
  - Delete a semicolon → error appears inline (virtual_text)
  - Place cursor on error line → detailed diagnostics show (virtual_lines)
- [ ] **Code Actions**: `<leader>ca` shows available actions
- [ ] **Rename**: `<leader>cr` on `User` - renames all occurrences

#### Expected Behavior

- Server starts within 2-3 seconds
- Completions appear instantly
- No "LSP server not found" errors

---

### 2. Python (HIGH PRIORITY)

#### Test Files

```bash
mkdir -p /tmp/lsp-test/python-project
cd /tmp/lsp-test/python-project
```

**Test File**: `test.py`

```python
from typing import List

def calculate_sum(numbers: List[int]) -> int:
    """Calculate the sum of numbers."""
    return sum(numbers)

def process_data(data):
    """Process data without type hints."""
    result = calculate_sum([1, 2, 3])
    print(result.)  # Test completion here
    return result

# Intentional error for diagnostics
x: str = 123  # Should show type error
```

#### Test Checklist

- [ ] **Multiple Servers**: `:LspInfo` shows both `pyright` and `ruff` attached
- [ ] **Pyright Hover**: `K` on `calculate_sum` shows docstring + type info
- [ ] **Ruff Hover Disabled**: `K` on function doesn't duplicate hover info from
      ruff
- [ ] **Completions**: Both servers provide completions
- [ ] **Type Checking**: `x: str = 123` shows type error from pyright
- [ ] **Linting**: Unused imports/variables highlighted by ruff
- [ ] **Inlay Hints**: Parameter names show in function calls
- [ ] **Diagnostics**: Both virtual_text and virtual_lines work

#### Expected Behavior

- Both pyright and ruff start successfully
- No duplicate hover information
- Type errors appear immediately

---

### 3. YAML / Kubernetes (HIGH PRIORITY)

#### Test Files

```bash
mkdir -p /tmp/lsp-test/k8s
cd /tmp/lsp-test/k8s
```

**Test File**: `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.14.2
          ports:
            - containerPort: 80
            # Test completion here - type "resou" and see if it suggests "resources"
```

#### Test Checklist

- [ ] **LSP Attaches**: `:LspInfo` shows `yamlls` client attached
- [ ] **Kubeschema Integration**:
  - Change `kind:` - completion suggests K8s kinds
  - Under `spec:` - completions show K8s-specific fields
- [ ] **Schema Validation**: Invalid K8s field shows error
- [ ] **Hover**: `K` on `apiVersion` shows documentation
- [ ] **Completions**: Typing field names shows K8s schema completions
- [ ] **Diagnostics**: Invalid YAML syntax shows immediately

#### Expected Behavior

- yamlls recognizes Kubernetes schemas automatically
- kubeschema provides dynamic schema matching based on apiVersion/kind
- No schema loading errors in `:LspLog`

---

### 4. Go (HIGH PRIORITY)

#### Test Files

```bash
mkdir -p /tmp/lsp-test/go-project
cd /tmp/lsp-test/go-project
go mod init test
```

**Test File**: `main.go`

```go
package main

import "fmt"

type Person struct {
    Name string
    Age  int
}

func (p Person) Greet() string {
    return fmt.Sprintf("Hello, I'm %s", p.Name)
}

func main() {
    person := Person{
        Name: "Alice",
        Age:  30,
    }

    message := person.Greet()
    fmt.Println(message)

    // Test completion: person.
}
```

#### Test Checklist

- [ ] **LSP Attaches**: `:LspInfo` shows `gopls` client attached
- [ ] **Native Completion**: In `*.go` files, native completion triggers
      automatically
- [ ] **Completions**: After `person.`, shows `Name`, `Age`, `Greet`
- [ ] **Inlay Hints**: Function parameters and return types show hints
- [ ] **Go to Definition**: `gd` on `Person` jumps to struct definition
- [ ] **Semantic Tokens**: Syntax highlighting enhanced by semantic tokens
- [ ] **Code Lens**: Import organization, test running lenses appear
- [ ] **Diagnostics**: Syntax errors show with hybrid diagnostics

#### Expected Behavior

- gopls starts within 2-3 seconds
- Native completion (0.11 feature) works automatically
- Semantic tokens workaround applied successfully
- No "completion not supported" messages

---

## Additional Server Testing (15-20 minutes)

### Quick Tests for Other Servers

#### JSON (jsonls)

**Test File**: `test.json`

```json
{
	"name": "test",
	"version": "1.0.0",
	"dependencies": {
	}
}
```

- [ ] SchemaStore integration works
- [ ] `package.json` shows npm package completions
- [ ] Invalid JSON shows errors

#### Markdown (marksman)

**Test File**: `test.md`

```markdown
# Test

[Link](#test)

## Section
```

- [ ] LSP attaches
- [ ] Link completions work
- [ ] Heading navigation works

#### Bash (bashls)

**Test File**: `test.sh`

```bash
#!/bin/bash

function greet() {
  echo "Hello $1"
}

greet "World"
```

- [ ] LSP attaches
- [ ] Bash completions work
- [ ] Syntax checking active

#### Lua (lua_ls)

**Test File**: `test.lua`

```lua
local M = {}

function M.test()
  vim.notify("Hello")
end

return M
```

- [ ] LSP attaches to Lua files
- [ ] Neovim API completions work
- [ ] Type checking works

#### Terraform/OpenTofu (terraformls, tofu_ls)

**Test File**: `main.tf`

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

- [ ] LSP attaches
- [ ] Resource completions work
- [ ] Validation active

## Feature Testing (10 minutes)

### Hybrid Diagnostics

1. Open any file with LSP errors
2. **Virtual Text (Always Visible)**:
   - Errors should show inline with icons
   - Source should show "if_many"
3. **Virtual Lines (Current Line Only)**:
   - Place cursor on line with error
   - Detailed multi-line diagnostic should appear below cursor line
   - Move cursor away → virtual lines disappear

### Keymaps

Test these keymaps in any LSP-enabled buffer:

| Keymap       | Function         | Test                     |
| ------------ | ---------------- | ------------------------ |
| `gd`         | Go to Definition | ✅ Opens Snacks picker   |
| `gr`         | References       | ✅ Opens Snacks picker   |
| `K`          | Hover            | ✅ Shows documentation   |
| `<leader>ca` | Code Action      | ✅ Shows actions         |
| `<leader>cr` | Rename           | ✅ Renames symbol        |
| `<leader>cR` | Rename File      | ✅ LSP-aware file rename |

### Inlay Hints

1. Open TypeScript or Go file
2. Inlay hints should show:
   - Parameter names in function calls
   - Return types (Go)
   - Type annotations (TypeScript)

### Code Lens

1. Open Go file with tests
2. Code lenses should appear above functions:
   - "run test"
   - "debug test"
3. `<leader>cc` runs code lens

## Troubleshooting Guide

### Common Issues

#### Issue: "LSP server not found"

**Check**:

```vim
:Mason
```

Verify LSP servers are installed. If not:

```vim
:MasonInstall vtsls pyright ruff gopls yamlls
```

#### Issue: "No LSP attached"

**Debug**:

```vim
:LspInfo
:LspLog
```

Check if server started. Look for errors in log.

#### Issue: Completions not working

**Check**:

1. `:LspInfo` - is client attached?
2. Blink.cmp installed and loaded?
3. Try manual trigger: `<C-Space>`

#### Issue: Diagnostics not showing

**Check**:

```vim
:lua vim.print(vim.diagnostic.config())
```

Verify `virtual_text` and `virtual_lines` are enabled.

#### Issue: Native completion (Go) not working

**Expected**: Only works in `*.go` files due to autocmd on line 30-38 of
`lsp.lua`

**Verify**:

```vim
:autocmd LspAttach
```

Should show autocmd for `*.go` pattern.

### Debug Commands

```vim
" Check loaded plugins
:Lazy

" Check LSP status
:LspInfo

" View LSP logs
:LspLog

" Check diagnostics config
:lua vim.print(vim.diagnostic.config())

" List attached clients
:lua vim.print(vim.lsp.get_clients())

" Check specific server config
:lua vim.print(vim.lsp.config['vtsls'])
```

## Performance Baseline

Measure performance to ensure no regressions:

### Startup Time

```bash
nvim --startuptime startup.log test.ts
tail -20 startup.log
```

**Expected**: Similar or better than before migration (should be <200ms for LSP
setup).

### LSP Attach Time

Open a file and measure:

```vim
:LspInfo
```

**Expected**:

- TypeScript: 2-3 seconds
- Python: 1-2 seconds
- Go: 2-3 seconds
- YAML: 1 second

## Test Results Template

Copy this to document your results:

```markdown
## Test Results

**Date**: YYYY-MM-DD **Tester**: [Your Name] **Neovim Version**: [Run :version]

### Quick Smoke Test

- [ ] :checkhealth lsp - PASS/FAIL
- [ ] :LspInfo - PASS/FAIL
- [ ] Plugin count: 77 - PASS/FAIL

### Priority Languages

- [ ] TypeScript - PASS/FAIL - Notes:
- [ ] Python - PASS/FAIL - Notes:
- [ ] YAML/K8s - PASS/FAIL - Notes:
- [ ] Go - PASS/FAIL - Notes:

### Additional Servers

- [ ] JSON - PASS/FAIL
- [ ] Markdown - PASS/FAIL
- [ ] Bash - PASS/FAIL
- [ ] Lua - PASS/FAIL
- [ ] Terraform - PASS/FAIL

### Features

- [ ] Hybrid Diagnostics - PASS/FAIL
- [ ] Keymaps - PASS/FAIL
- [ ] Inlay Hints - PASS/FAIL
- [ ] Code Lens - PASS/FAIL

### Issues Found

[List any issues here]

### Overall Result

- [ ] ✅ READY TO MERGE
- [ ] ⚠️ NEEDS FIXES
- [ ] ❌ FAILED - ROLLBACK
```

## Post-Testing Actions

### If All Tests Pass ✅

1. **Merge to main**:
   ```bash
   git checkout main
   git merge feat/migrate-native-lsp
   git push
   ```

2. **Clean up branch** (optional):
   ```bash
   git branch -d feat/migrate-native-lsp
   ```

3. **Update lazy-lock.json**:
   - Neovim will automatically update on next start
   - Consider committing the updated lock file

### If Tests Fail ⚠️

1. **Document issues**: Note specific failures above
2. **Keep branch**: Don't merge yet
3. **Debug**: Use troubleshooting guide
4. **Request help**: Share test results

### If Critical Failure ❌

**Rollback immediately**:

```bash
git checkout main
```

Your main config is untouched - safe to continue work.

## Success Criteria

Migration is successful if:

✅ All 4 priority language servers work (TypeScript, Python, YAML, Go)\
✅ Hybrid diagnostics display correctly\
✅ All LSP keymaps function\
✅ No errors in `:checkhealth lsp`\
✅ No performance regressions\
✅ Native Go completion works\
✅ Kubeschema integration works for YAML

## Notes

- **Migration Philosophy**: This is a "big bang" migration - all servers
  migrated at once
- **Feature Parity**: All functionality from nvim-lspconfig has been preserved
- **Plugin Reduction**: Reduced from 78 to 77 plugins
- **Neovim Version**: Requires Neovim 0.11+
- **Rollback Safety**: Main branch unchanged - safe rollback anytime

## Contact

If you encounter issues during testing:

1. Check `:LspLog` for detailed errors
2. Review `:checkhealth lsp` output
3. Check git commit history for specific changes
4. File an issue with test results

---

**Happy Testing!** 🚀
