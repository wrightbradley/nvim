# AI Setup and Configuration Guide

This configuration includes two powerful AI assistants: CodeCompanion and
OpenCode. This guide covers setup, configuration, and usage.

## Prerequisites

- Neovim 0.10+ with Lua support
- Internet connection for AI services
- API access to supported providers

## Supported AI Providers

### CodeCompanion (Primary)

- **GitHub Copilot** (recommended)
- **OpenAI** (GPT-4, GPT-4o, o1, o3 models)
- **Anthropic Claude** (Sonnet, Opus models)
- **Google Gemini** (2.0 Flash, 2.5 Pro)

### OpenCode

- **OpenCode** service integration

## Setup Instructions

### 1. CodeCompanion Setup

CodeCompanion is the primary AI assistant and supports multiple providers.

#### GitHub Copilot (Recommended)

1. **Install GitHub Copilot**:
   ```bash
   # If you have GitHub Copilot subscription
   gh extension install github/gh-copilot
   ```

2. **Authentication**:
   ```bash
   # Login to GitHub
   gh auth login

   # Verify Copilot access
   gh copilot status
   ```

3. **Configuration**: CodeCompanion will automatically detect your Copilot
   access.

#### OpenAI Setup

1. **Get API Key**:
   - Visit [OpenAI API](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the key securely

2. **Set Environment Variable**:
   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   export OPENAI_API_KEY="your-api-key-here"
   ```

3. **Alternative: Use Secret Management**:
   ```bash
   # Store securely using gpg
   echo "your-api-key" | gpg --encrypt --recipient your-email > ~/.openai-key.gpg
   ```

#### Other Providers

For Anthropic Claude, Google Gemini, and other providers, set the respective
environment variables:

```bash
export ANTHROPIC_API_KEY="your-claude-key"
export GEMINI_API_KEY="your-gemini-key"
```

### 2. OpenCode Setup

1. **Installation**: OpenCode is automatically configured through the plugin.

2. **API Configuration**: Follow OpenCode's authentication process when first
   launched.

## Configuration Options

### Model Selection

#### CodeCompanion Models

The configuration supports multiple models with different capabilities:

**Free Models:**

- `gpt-4.1` (Copilot free tier)
- `gpt-4o` (Copilot free tier)

**Premium Models (usage tracked):**

- `gpt-4.5` (50 premium requests)
- `claude-sonnet-3.5` (1 premium request)
- `claude-sonnet-3.7` (1 premium request)
- `claude-sonnet-3.7-thinking` (1.25 premium requests)
- `claude-sonnet-4` (1 premium request)
- `claude-opus` (4 premium requests)
- `gemini-2.0-flash` (0.25 premium requests)
- `gemini-2.5-pro` (1 premium request)
- `o1` (10 premium requests)
- `o3` (1 premium request)
- `o3-mini` (0.33 premium requests)

#### Switching Models

Use `gM` in chat windows to toggle between models:

- Default: `gpt-4.1` (Copilot)
- Alternate: `gemini-2.5-pro`

### Custom System Prompts

The configuration uses a custom system prompt optimized for coding tasks. You
can modify it in:

```lua
-- lua/ai/prompts/system.lua
system_prompt = require("ai.prompts.system").cline_prompt()
```

## Usage Guide

### CodeCompanion Usage

#### Starting a Chat

```
<leader>apv  -- Toggle chat window
<leader>apa  -- Action palette
<leader>apq  -- Quick chat
```

#### Code Actions

```
<leader>ape  -- Explain selected code
<leader>apf  -- Fix selected code
<leader>apr  -- Refactor code
<leader>apt  -- Generate tests
<leader>apd  -- Add documentation
```

#### Chat Commands

Within chat windows:

- `<CR>` or `<C-CR>` - Send message
- `q` - Close chat
- `<C-c>` - Stop generation
- `gA` - View analytics
- `gh` - Chat history
- `gM` - Switch model

#### Slash Commands

- `/buffer` - Insert open buffers
- `/file` - Insert a file
- `/explain` - Explain code
- `/fix` - Fix code
- `/tests` - Generate tests
- `/commit` - Generate commit message

### OpenCode Usage

```
<leader>Ot   -- Toggle OpenCode
<leader>Oa   -- Ask question
<leader>OA   -- Ask about current file
<leader>Oe   -- Explain cursor context
<leader>Or   -- Review file
<leader>Of   -- Fix diagnostics
```

## Analytics and Monitoring

### Premium Usage Tracking

CodeCompanion includes detailed analytics to track premium model usage:

#### View Analytics

Press `gA` in any chat window to see:

- Premium requests by time period
- Requests by model
- Usage by command
- Response times
- Failure rates

#### Usage Reports

Analytics track premium request costs:

- Daily/weekly/monthly breakdowns
- Model-specific usage
- User and command statistics
- Performance metrics

### History Management

#### Chat History

- Press `gh` in chat windows to browse previous conversations
- Auto-generated titles for easy navigation
- Search through chat history
- Restore previous sessions

## Tips and Best Practices

### 1. Model Selection Strategy

- Use **Copilot free models** (`gpt-4.1`, `gpt-4o`) for general coding
- Use **Claude Sonnet** for complex reasoning and refactoring
- Use **o1/o3 models** for mathematical and complex problem solving
- Use **Gemini Flash** for quick, cost-effective queries

### 2. Context Management

- Use `/file` to include specific files in context
- Select relevant code before using AI commands
- Use `/buffer` to include multiple open files
- Be specific in your prompts for better results

### 3. Workflow Integration

- Use `<leader>apt` to generate tests for functions
- Use `<leader>apm` for commit message generation
- Use `<leader>apf` to fix LSP diagnostics
- Use `<leader>apr` for refactoring suggestions

### 4. Security Best Practices

- Store API keys encrypted with GPG
- Use environment variables for sensitive data
- Never commit API keys to version control
- Regularly rotate API keys

## Troubleshooting

### Common Issues

**CodeCompanion not working:**

1. Check Copilot status: `gh copilot status`
2. Verify authentication: `gh auth status`
3. Check network connectivity
4. Restart Neovim

**Model switching not working:**

1. Verify you have access to the target model
2. Check premium usage limits
3. Try restarting the chat session

**Slow response times:**

1. Check internet connection
2. Try switching to a faster model (e.g., Gemini Flash)
3. Reduce context size

### Getting Help

1. Use `:checkhealth codecompanion` for diagnostics
2. Check the analytics dashboard for usage patterns
3. Review the chat history for previous solutions
4. Consult the plugin documentation for advanced features

## Advanced Configuration

### Custom Prompts

Create custom prompts in `lua/ai/prompts/`:

```lua
-- lua/ai/prompts/custom.lua
return {
  ["my-prompt"] = {
    strategy = "chat",
    description = "My custom prompt",
    prompts = {
      {
        role = "user",
        content = "Your custom prompt here"
      }
    }
  }
}
```

### Extension Development

The configuration supports custom extensions:

```lua
-- lua/ai/extensions/my-extension.lua
local M = {}

function M.setup(opts)
  -- Your extension setup
end

return M
```

Register in CodeCompanion configuration:

```lua
extensions = {
  ["my-extension"] = {
    enabled = true,
    callback = function()
      return require("ai.extensions.my-extension")
    end
  }
}
```
