return {
  ["Suggest Branch Name"] = {
    strategy = "workflow",
    description = "Suggest a git branch name and create it.",
    opts = { short_name = "branch", is_slash_cmd = true },
    prompts = {
      {
        {
          role = "user",
          content = [[
### Goal
Based on the following task description, generate a descriptive git branch name and then create it using the `@{cmd_runner}` tool.
### Branch Naming Convention
- Use the format `type/short-description`.
- `type` should be one of: `feature`, `bugfix`, `chore`, `refactor`.
- Use hyphens to separate words.
### Task Description
<task_description>
### Plan
1.  Generate a branch name.
2.  Use `@{cmd_runner}` to execute `git checkout -b <generated_branch_name>`.
]],
        },
      },
    },
  },
  ["Generate a Commit Message for Staged"] = {
    strategy = "chat",
    description = "Generate a commit message for staged change",
    opts = {
      short_name = "staged-commit",
      auto_submit = true,
      is_slash_cmd = true,
    },
    prompts = {
      {
        role = "user",
        content = function()
          return "Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
            .. "\n\n```\n"
            .. vim.fn.system("git diff --staged")
            .. "\n```"
        end,
        opts = {
          contains_code = true,
        },
      },
    },
  },
  ["Generate a Commit Message"] = {
    prompts = {
      {
        role = "user",
        content = function()
          return "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
            .. "\n\n```\n"
            .. vim.fn.system("git diff")
            .. "\n```"
        end,
        opts = {
          contains_code = true,
        },
      },
    },
  },
  ["Generate PR Description"] = {
    strategy = "chat",
    description = "Generate a PR description based on staged git changes.",
    opts = { short_name = "pr_description", auto_submit = true },
    prompts = {
      {
        role = "system",
        content = "You are an expert at writing clear and concise pull request descriptions. Analyze the git diff and use the provided PR template (`#pr_template`) to generate a description.",
      },
      {
        role = "user",
        content = function()
          vim.g.codecompanion_auto_tool_mode = true
          return string.format(
            [[Please generate a PR description based on the following git diff:

```diff
%s
```]],
            vim.fn.system("git diff --staged")
          )
        end,
      },
    },
  },
}
