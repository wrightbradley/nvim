-- checklist_tools.lua

local data_path = vim.fn.stdpath("data") .. "/codecompanion"
local workspace_root = vim.fn.getcwd()
local workspace_id = vim.fn.substitute(workspace_root, '[/\\:*?"<>|]', "_", "g")
local checklist_file = data_path .. "/checklists_v2_" .. workspace_id .. ".json"

vim.fn.mkdir(data_path, "p")

---@class ChecklistTask
---@field id integer
---@field text string
---@field done boolean
---@field created_at integer
---@field completed_at? integer

---@class ChecklistHistoryEntry
---@field action string
---@field commit_message string
---@field context any
---@field timestamp integer

---@class Checklist
---@field id integer
---@field goal string
---@field created_at integer
---@field tasks table<integer, ChecklistTask>
---@field next_task_id integer
---@field history ChecklistHistoryEntry[]

local checklist_storage = {
  load = function()
    local ok, data = pcall(vim.fn.readfile, checklist_file)
    if not ok or not data or #data == 0 then
      return {}, 1
    end
    local json_ok, parsed = pcall(vim.json.decode, table.concat(data, "\n"))
    if not json_ok or not parsed then
      return {}, 1
    end
    local checklists = {}
    for checklist_id, checklist in pairs(parsed.checklists or {}) do
      local restored_checklist = vim.deepcopy(checklist)
      if checklist.tasks_array then
        restored_checklist.tasks = {}
        for _, task in ipairs(checklist.tasks_array) do
          restored_checklist.tasks[task.id] = task
        end
        restored_checklist.tasks_array = nil
      else
        restored_checklist.tasks = restored_checklist.tasks or {}
      end
      checklists[checklist_id] = restored_checklist
    end
    return checklists, parsed.next_id or 1
  end,

  save = function(checklists, next_id)
    local serializable_checklists = {}
    for checklist_id, checklist in pairs(checklists) do
      local serializable_checklist = vim.deepcopy(checklist)
      local tasks_array = {}
      for task_id, task in pairs(checklist.tasks or {}) do
        table.insert(tasks_array, task)
      end
      serializable_checklist.tasks_array = tasks_array
      serializable_checklist.tasks = nil
      serializable_checklists[checklist_id] = serializable_checklist
    end
    local data = {
      workspace = workspace_root,
      checklists = serializable_checklists,
      next_id = next_id,
      last_updated = os.time(),
    }
    pcall(vim.fn.writefile, { vim.json.encode(data) }, checklist_file)
  end,
}

local checklists, next_checklist_id = checklist_storage.load()

local function get_sorted_tasks(checklist)
  local sorted_tasks = {}
  for _, task in pairs(checklist.tasks) do
    table.insert(sorted_tasks, task)
  end
  table.sort(sorted_tasks, function(a, b)
    return a.id < b.id
  end)
  return sorted_tasks
end

local function format_checklist_output(checklist)
  if not checklist then
    return "No checklist data"
  end

  local output = string.format(
    [[📋 **CHECKLIST %d**
🎯 **GOAL**: %s
📅 **CREATED**: %s
📝 **TASKS**:]],
    checklist.id,
    checklist.goal or "No goal",
    os.date("%Y-%m-%d %H:%M", checklist.created_at)
  )

  if vim.tbl_isempty(checklist.tasks) then
    output = output .. "\n   No tasks defined"
  else
    local sorted_tasks = get_sorted_tasks(checklist)
    for _, task in ipairs(sorted_tasks) do
      local status_icon = task.done and "✅" or "❌"
      local completed_info = task.done and string.format(" (completed %s)", os.date("%m/%d %H:%M", task.completed_at))
        or ""
      output = output .. string.format("\n%d. %s %s%s", task.id, status_icon, task.text, completed_info)
    end
  end

  -- Show history if available
  if checklist.history and #checklist.history > 0 then
    output = output .. "\n\n📜 **HISTORY**:"
    for _, entry in ipairs(checklist.history) do
      output = output
        .. string.format(
          "\n- [%s] %s\n  • %s\n  • Context: %s",
          os.date("%Y-%m-%d %H:%M", entry.timestamp),
          entry.action,
          entry.commit_message,
          type(entry.context) == "string" and entry.context or vim.inspect(entry.context)
        )
    end
  end

  -- Completion summary
  local total = vim.tbl_count(checklist.tasks)
  local completed = 0
  for _, task in pairs(checklist.tasks) do
    if task.done then
      completed = completed + 1
    end
  end
  output = output
    .. string.format(
      "\n\n📊 **PROGRESS**: %d/%d tasks complete (%.0f%%)",
      completed,
      total,
      total > 0 and (completed / total) * 100 or 0
    )

  return output
end

local function get_checklist(id)
  if not id then
    return nil, "No checklist ID provided"
  end
  local checklist_id = tonumber(id)
  if not checklist_id then
    return nil, "Invalid checklist ID format"
  end
  local checklist = checklists[checklist_id]
  if not checklist then
    return nil, "Checklist not found"
  end
  return checklist, nil
end

local function create_checklist(goal, tasks, commit_message, context)
  local id = next_checklist_id
  next_checklist_id = next_checklist_id + 1

  local checklist = {
    id = id,
    goal = goal,
    created_at = os.time(),
    tasks = {},
    next_task_id = 1,
    history = {
      {
        action = "create",
        commit_message = commit_message,
        context = context,
        timestamp = os.time(),
      },
    },
  }

  for _, task_text in ipairs(tasks or {}) do
    if task_text and task_text:match("%S") then
      checklist.tasks[checklist.next_task_id] = {
        id = checklist.next_task_id,
        text = task_text:gsub("^%s*[-*+]?%s*", ""),
        done = false,
        created_at = os.time(),
      }
      checklist.next_task_id = checklist.next_task_id + 1
    end
  end

  checklists[id] = checklist
  checklist_storage.save(checklists, next_checklist_id)
  return checklist
end

local function complete_tasks(checklist, complete_task_ids, commit_message, context)
  local changed = false
  for _, task_id in ipairs(complete_task_ids or {}) do
    local task_id_num = tonumber(task_id)
    if task_id_num and checklist.tasks[task_id_num] and not checklist.tasks[task_id_num].done then
      checklist.tasks[task_id_num].done = true
      checklist.tasks[task_id_num].completed_at = os.time()
      changed = true
    end
  end
  if changed then
    table.insert(checklist.history, {
      action = "complete_tasks",
      commit_message = commit_message,
      context = context,
      timestamp = os.time(),
    })
    checklist_storage.save(checklists, next_checklist_id)
    return true, "Tasks marked complete"
  else
    return false, "No valid incomplete tasks specified"
  end
end

local ChecklistList = {
  description = "List all checklists in the workspace.",
  callback = {
    name = "checklist_list",
    cmds = {
      function(self, args, input, cb)
        print("checklist_list args:", vim.inspect(args))
        local page = tonumber(args.page) or 1
        local per_page = tonumber(args.per_page) or 10

        -- Validate pagination parameters
        if page < 1 then
          return cb({ status = "error", data = "page must be >= 1" })
        end
        if per_page < 1 or per_page > 100 then
          return cb({ status = "error", data = "per_page must be between 1 and 100" })
        end

        if vim.tbl_isempty(checklists) then
          return cb({
            status = "success",
            data = "📋 **NO CHECKLISTS FOUND**\n\nUse the create tool to make a new checklist.",
          })
        end

        local summaries = {}
        for id, checklist in pairs(checklists) do
          local total = vim.tbl_count(checklist.tasks)
          local completed = 0
          for _, task in pairs(checklist.tasks) do
            if task.done then
              completed = completed + 1
            end
          end
          table.insert(summaries, {
            id = id,
            goal = checklist.goal or "No goal",
            created_at = checklist.created_at,
            progress = { completed = completed, total = total },
          })
        end
        table.sort(summaries, function(a, b)
          return a.created_at > b.created_at
        end)

        -- Calculate pagination
        local total_count = #summaries
        local total_pages = math.ceil(total_count / per_page)
        local start_index = (page - 1) * per_page + 1
        local end_index = math.min(page * per_page, total_count)

        -- Build paginated output
        local output = string.format(
          "📋 **CHECKLISTS** (Page %d of %d, showing %d-%d of %d):\n\n",
          page,
          total_pages,
          start_index,
          end_index,
          total_count
        )

        for i = start_index, end_index do
          local summary = summaries[i]
          output = output
            .. string.format(
              "ID: %d | %s (%d/%d complete)\n",
              summary.id,
              summary.goal,
              summary.progress.completed,
              summary.progress.total
            )
          output = output .. string.format("     Created: %s\n\n", os.date("%m/%d %H:%M", summary.created_at))
        end

        -- Add pagination info
        if total_pages > 1 then
          output = output .. "\n📄 **PAGINATION**:\n"
          if page > 1 then
            output = output
              .. string.format('- Previous: `@checklist_list page="%d" per_page="%d"`\n', page - 1, per_page)
          end
          if page < total_pages then
            output = output .. string.format('- Next: `@checklist_list page="%d" per_page="%d"`\n', page + 1, per_page)
          end
          output = output .. string.format('- Go to page: `@checklist_list page="X" per_page="%d"`\n', per_page)
        end

        output = output .. "\n💡 **NEXT STEPS**:\n"
        output = output .. '- View checklist: `@checklist_status checklist_id="X"`\n'
        output = output .. "- Create new: use the create tool"
        return cb({ status = "success", data = output })
      end,
    },
    system_prompt = [[## Checklist List Tool

   - Use this tool to list all checklists in the workspace.
   - No modifications are allowed.
   - Use the create tool to add a new checklist.

### Usage Example

   @checklist_list page="1" per_page="5"
   @checklist_list page="2" per_page="10"
]],
    schema = {
      type = "function",
      ["function"] = {
        name = "checklist_list",
        description = "List all checklists in the workspace.",
        parameters = {
          type = "object",
          properties = {
            page = {
              type = "string",
              description = "Page number to retrieve (default: 1)",
            },
            per_page = {
              type = "string",
              description = "Number of checklists per page (default: 10, max: 100)",
            },
          },
          additionalProperties = false,
        },
        strict = true,
      },
    },
    opts = {},
    output = {
      success = function(self, agent, cmd, stdout)
        local chat = agent.chat
        chat:add_tool_output(self, stdout[1])
      end,
      error = function(self, agent, cmd, stderr)
        local chat = agent.chat
        local error_msg = stderr[1] or "Unknown error"
        chat:add_tool_output(self, string.format("**Checklist List Tool Error**: %s", error_msg))
      end,
      rejected = function(self, agent, cmd)
        local chat = agent.chat
        chat:add_tool_output(self, "**Checklist List Tool**: User declined to execute the operation")
      end,
    },
  },
}

-- checklist_status tool
local ChecklistStatus = {
  description = "Show the status of a specific checklist.",
  callback = {
    name = "checklist_status",
    cmds = {
      function(self, args, input, cb)
        local checklist_id = args.checklist_id
        if not checklist_id then
          return cb({ status = "error", data = "checklist_id is required" })
        end
        local checklist, err = get_checklist(checklist_id)
        if not checklist then
          return cb({ status = "error", data = err })
        end
        return cb({
          status = "success",
          data = format_checklist_output(checklist),
        })
      end,
    },
    system_prompt = [[## Checklist Status Tool

- Use this tool to show the status of a specific checklist.
- No modifications are allowed.

### Usage Example

- Show the status of a checklist (replace X with the checklist ID):
  @checklist_status checklist_id="X"
]],
    schema = {
      type = "function",
      ["function"] = {
        name = "checklist_status",
        description = "Show the status of a specific checklist.",
        parameters = {
          type = "object",
          properties = {
            checklist_id = {
              type = "string",
              description = "Checklist ID to show status for",
            },
          },
          required = { "checklist_id" },
          additionalProperties = false,
        },
        strict = true,
      },
    },
    opts = {},
    output = {
      success = function(self, agent, cmd, stdout)
        local chat = agent.chat
        chat:add_tool_output(self, stdout[1])
      end,
      error = function(self, agent, cmd, stderr)
        local chat = agent.chat
        local error_msg = stderr[1] or "Unknown error"
        chat:add_tool_output(self, string.format("**Checklist Status Tool Error**: %s", error_msg))
      end,
      rejected = function(self, agent, cmd)
        local chat = agent.chat
        chat:add_tool_output(self, "**Checklist Status Tool**: User declined to execute the operation")
      end,
    },
  },
}

-- checklist_create tool
local ChecklistCreate = {
  description = "Create a new checklist. Requires goal, tasks, commit_message, and context.",
  callback = {
    name = "checklist_create",
    cmds = {
      function(self, args, input, cb)
        local goal = args.goal
        local tasks = args.tasks or {}
        local commit_message = args.commit_message
        local context = args.context

        if not goal or goal == "" then
          return cb({ status = "error", data = "Goal is required" })
        end
        if not tasks or #tasks == 0 then
          return cb({ status = "error", data = "At least one task is required" })
        end
        if not commit_message or commit_message == "" then
          return cb({ status = "error", data = "commit_message is required" })
        end
        if not context then
          return cb({ status = "error", data = "context is required" })
        end
        local checklist = create_checklist(goal, tasks, commit_message, context)
        return cb({
          status = "success",
          data = format_checklist_output(checklist),
        })
      end,
    },
    system_prompt = [[## Checklist Create Tool

- Use this tool to create a new checklist.
- All fields are required.
- All changes require:
  - commit_message: a detailed justification for the change.
  - context: all information used to make the decision (user prompt, file, code, etc).

### Usage Example

- Create a new checklist:
  @checklist_create goal="Refactor module X" tasks=["Update API", "Write tests"] commit_message="Refactoring for maintainability" context={...}
]],
    schema = {
      type = "function",
      ["function"] = {
        name = "checklist_create",
        description = "Create a new checklist. Requires goal, tasks, commit_message, and context.",
        parameters = {
          type = "object",
          properties = {
            goal = {
              type = "string",
              description = "Goal of the checklist",
            },
            tasks = {
              type = "array",
              items = { type = "string" },
              description = "Initial tasks as array of strings",
            },
            commit_message = {
              type = "string",
              description = "Justification for the change",
            },
            context = {
              type = "object",
              description = "All information used to make the decision",
            },
          },
          required = { "goal", "tasks", "commit_message", "context" },
          additionalProperties = false,
        },
        strict = true,
      },
    },
    opts = {
      requires_approval = true,
    },
    output = {
      prompt = function(self, agent)
        return string.format(
          "Create checklist with goal: '%s' and %d tasks?\n\nCommit message: %s\nContext: %s",
          self.args.goal or "",
          self.args.tasks and #self.args.tasks or 0,
          self.args.commit_message or "",
          type(self.args.context) == "string" and self.args.context or vim.inspect(self.args.context)
        )
      end,
      success = function(self, agent, cmd, stdout)
        local chat = agent.chat
        chat:add_tool_output(self, stdout[1])
      end,
      error = function(self, agent, cmd, stderr)
        local chat = agent.chat
        local error_msg = stderr[1] or "Unknown error"
        chat:add_tool_output(self, string.format("**Checklist Create Tool Error**: %s", error_msg))
      end,
      rejected = function(self, agent, cmd)
        local chat = agent.chat
        chat:add_tool_output(self, "**Checklist Create Tool**: User declined to execute the operation")
      end,
    },
  },
}

-- checklist_complete_tasks tool
local ChecklistCompleteTasks = {
  description = "Mark tasks complete in a checklist. Requires checklist_id, complete_task_ids, commit_message, and context.",
  callback = {
    name = "checklist_complete_tasks",
    cmds = {
      function(self, args, input, cb)
        local checklist_id = args.checklist_id
        local complete_task_ids = args.complete_task_ids
        local commit_message = args.commit_message
        local context = args.context

        if not checklist_id then
          return cb({ status = "error", data = "checklist_id is required" })
        end
        if not complete_task_ids or #complete_task_ids == 0 then
          return cb({ status = "error", data = "complete_task_ids is required" })
        end
        if not commit_message or commit_message == "" then
          return cb({ status = "error", data = "commit_message is required" })
        end
        if not context then
          return cb({ status = "error", data = "context is required" })
        end
        local checklist, err = get_checklist(checklist_id)
        if not checklist then
          return cb({ status = "error", data = err })
        end
        local success, msg = complete_tasks(checklist, complete_task_ids, commit_message, context)
        if not success then
          return cb({ status = "error", data = msg })
        end
        return cb({
          status = "success",
          data = format_checklist_output(checklist),
        })
      end,
    },
    system_prompt = [[## Checklist Complete Tasks Tool

- Use this tool to mark tasks complete in a checklist.
- All fields are required.
- All changes require:
  - commit_message: a detailed justification for the change.
  - context: all information used to make the decision (user prompt, file, code, etc).

### Usage Example

- Mark tasks complete (replace X with checklist ID, and Y/Z with task IDs):
  @checklist_complete_tasks checklist_id="X" complete_task_ids=["Y", "Z"] commit_message="Tasks completed after review" context={...}
]],
    schema = {
      type = "function",
      ["function"] = {
        name = "checklist_complete_tasks",
        description = "Mark tasks complete in a checklist. Requires checklist_id, complete_task_ids, commit_message, and context.",
        parameters = {
          type = "object",
          properties = {
            checklist_id = {
              type = "string",
              description = "Checklist ID to update",
            },
            complete_task_ids = {
              type = "array",
              items = { type = "string" },
              description = "Task IDs to mark complete",
            },
            commit_message = {
              type = "string",
              description = "Justification for the change",
            },
            context = {
              type = "object",
              description = "All information used to make the decision",
            },
          },
          required = { "checklist_id", "complete_task_ids", "commit_message", "context" },
          additionalProperties = false,
        },
        strict = true,
      },
    },
    opts = {
      requires_approval = true,
    },
    output = {
      prompt = function(self, agent)
        return string.format(
          "Mark tasks complete in checklist %s?\n\nCommit message: %s\nContext: %s",
          self.args.checklist_id or "",
          self.args.commit_message or "",
          type(self.args.context) == "string" and self.args.context or vim.inspect(self.args.context)
        )
      end,
      success = function(self, agent, cmd, stdout)
        local chat = agent.chat
        chat:add_tool_output(self, stdout[1])
      end,
      error = function(self, agent, cmd, stderr)
        local chat = agent.chat
        local error_msg = stderr[1] or "Unknown error"
        chat:add_tool_output(self, string.format("**Checklist Complete Tasks Tool Error**: %s", error_msg))
      end,
      rejected = function(self, agent, cmd)
        local chat = agent.chat
        chat:add_tool_output(self, "**Checklist Complete Tasks Tool**: User declined to execute the operation")
      end,
    },
  },
}

return {
  checklist_list = ChecklistList,
  checklist_status = ChecklistStatus,
  checklist_create = ChecklistCreate,
  checklist_complete_tasks = ChecklistCompleteTasks,
}
