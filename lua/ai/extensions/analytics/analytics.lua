local AnalyticsExtension = {}

local function get_store()
  return require("ai.extensions.analytics.analytics_store")
end

local function get_snacks()
  return require("snacks")
end

local DIMENSIONS = {
  daily = {
    label = "Daily",
    filter = "date(ts,'unixepoch') = date('now')",
  },
  weekly = {
    label = "Weekly",
    filter = "date(ts,'unixepoch') >= date('now','-6 days')",
  },
  monthly = {
    label = "Monthly",
    filter = "strftime('%Y-%m', ts,'unixepoch') = strftime('%Y-%m','now')",
  },
}

local DEFAULT_QUERIES = {
  event_type = {
    name = "Event Counts by Type",
    sql = function(dimension)
      return string.format(
        [[SELECT event_type, COUNT(*) AS count FROM metrics WHERE %s GROUP BY event_type;]],
        dimension.filter
      )
    end,
    title_formatter = function(name, dimension)
      return "### " .. name .. " [" .. (dimension.label or "") .. "]"
    end,
    row_formatter = function(row, _)
      return string.format("- `%s`: **%d**", row.event_type or "?", row.count or 0)
    end,
  },
  adapter_model = {
    name = "Requests Started by Adapter/Model",
    sql = function(dimension)
      return string.format(
        [[SELECT json_extract(payload, '$.adapter.name') AS adapter_name, json_extract(payload, '$.adapter.model') AS model, COUNT(*) AS count FROM metrics WHERE event_type = 'CodeCompanionRequestStarted' AND %s GROUP BY adapter_name, model;]],
        dimension.filter
      )
    end,
    title_formatter = function(name, dimension)
      return "### " .. name .. " [" .. (dimension.label or "") .. "]"
    end,
    row_formatter = function(row, _)
      return string.format("- `%s` / `%s`: **%d**", row.adapter_name or "?", row.model or "?", row.count or 0)
    end,
  },
}

local function normalize_lines(lines)
  local result = {}
  for _, line in ipairs(lines) do
    if type(line) == "string" then
      for sub in line:gmatch("([^\n]+)") do
        table.insert(result, sub)
      end
    else
      table.insert(result, vim.inspect(line))
    end
  end
  return result
end

local function build_content(user_config, dimension_entry)
  local store = get_store()
  local lines = {}
  local all_queries = vim.tbl_deep_extend("force", {}, DEFAULT_QUERIES, user_config.queries or {})

  -- If default_queries is specified, use it to filter and order.
  -- Otherwise, run all available queries.
  local query_keys = user_config.default_queries
  if not query_keys then
    query_keys = {}
    -- Add default query keys first, in a consistent order
    for k, _ in pairs(DEFAULT_QUERIES) do
      table.insert(query_keys, k)
    end
    -- Add user-defined query keys
    if user_config.queries then
      for k, _ in pairs(user_config.queries) do
        if not DEFAULT_QUERIES[k] then -- Avoid duplicates
          table.insert(query_keys, k)
        end
      end
    end
  end

  for _, key in ipairs(query_keys) do
    local query = all_queries[key]
    if query then
      local rows = store.metrics:sql(query.sql(dimension_entry))
      table.insert(lines, query.title_formatter(query.name, dimension_entry))
      if type(rows) ~= "table" or #rows == 0 then
        table.insert(lines, "- _(none)_")
      else
        for _, row in ipairs(rows) do
          table.insert(lines, query.row_formatter(row, dimension_entry))
        end
      end
    end
  end
  return normalize_lines(lines)
end

function AnalyticsExtension.setup(opts)
  local Snacks = get_snacks()
  local store = get_store()
  local chat_keymaps = require("codecompanion.config").strategies.chat.keymaps
  local dimension = opts and opts.dimension or "monthly"
  local user_config = opts or {}

  local function show_window()
    local dimension_entry = DIMENSIONS[dimension] or DIMENSIONS["daily"]
    local content = build_content(user_config, dimension_entry)
    local max_width = 0
    for _, line in ipairs(content) do
      max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
    end
    local size = {
      width = math.min(max_width + 4, 80),
      height = math.min(#content + 2, 28),
    }
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "markdown"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    Snacks.win({
      title = "📈 CodeCompanion Analytics [" .. (dimension_entry.label or dimension) .. "]",
      buf = buf,
      border = "rounded",
      minimal = true,
      width = size.width,
      height = size.height,
      keys = {
        q = function(win)
          win:close()
        end,
        ["<Esc>"] = function(win)
          win:close()
        end,
      },
      wo = {
        wrap = false,
        number = false,
        relativenumber = false,
        signcolumn = "no",
        conceallevel = 2,
        concealcursor = "nvc",
      },
    }):show()
  end

  chat_keymaps.show_events = {
    modes = { n = (opts and opts.keymap) or "gA" },
    description = "Toggle CodeCompanion Analytics",
    callback = show_window,
  }

  -- Autocommand to log events
  local group = vim.api.nvim_create_augroup("CodeCompanionEventLogger", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanion*",
    group = group,
    callback = function(event)
      store.add_metric(event)
      if opts and opts.debug then
        print("Event:", event.match)
      end
    end,
  })

  -- Cleanup command
  local retention_days = (opts and opts.retention_days) or 365
  vim.api.nvim_create_user_command("CodeCompanionAnalyticsCleanup", function(params)
    local days = tonumber(params.args) or retention_days
    store.cleanup_metrics(days)
    print("CodeCompanion Analytics: cleaned up metrics older than " .. days .. " days.")
  end, {
    nargs = "?",
    desc = "Cleanup CodeCompanion analytics metrics older than N days",
  })
end

AnalyticsExtension.exports = {}

return AnalyticsExtension
