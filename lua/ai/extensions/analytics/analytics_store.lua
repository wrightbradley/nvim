---@brief [[
---  Analytics store for the CodeCompanion “analytics” extension.
---  Keeps a single Sqlite database in $XDG_DATA_HOME/codecompanion.
---
---  Public exports:
---    store.add_metric(evt)                 -- raw insert
---    store.metrics:select{where=…}         -- simple query
---    store.metrics:sql(sql,?params)        -- raw SQL
---    store.cleanup_metrics(retention_days) -- pruning helper
---@brief ]]

local Path = require("plenary.path")
---@class sqlite_db
local sqlite = require("sqlite.db")
---@class sqlite_tbl
local tbl = require("sqlite.tbl")

local json_encode = vim.json and vim.json.encode or vim.fn.json_encode

---@type string
local DB_PATH = Path:new(vim.fn.stdpath("data"), "cc_metrics.sqlite"):absolute()

---@class AnalyticsMetricRow
---@field id         integer
---@field ts         integer
---@field event_type string
---@field year       integer
---@field month      integer
---@field day        integer
---@field hour       integer
---@field payload    string

---@type sqlite_tbl
local metrics_tbl = tbl("metrics", {
  id = true,
  ts = { "integer", required = true },
  event_type = { "text", required = true },
  year = "integer",
  month = "integer",
  day = "integer",
  hour = "integer",
  payload = "text",
})

---@class AnalyticsDB : sqlite_db
---@field metrics sqlite_tbl
local DB = sqlite({
  uri = DB_PATH,
  metrics = metrics_tbl,
})

-- open once; ignore “already open” errors
pcall(DB.open, DB)

-- Explicitly create the table and indexes
pcall(function()
  DB:eval(DB.metrics:sql_create())
  DB:eval([[CREATE INDEX IF NOT EXISTS idx_metrics_year  ON metrics(year);]])
  DB:eval([[CREATE INDEX IF NOT EXISTS idx_metrics_month ON metrics(month);]])
  DB:eval([[CREATE INDEX IF NOT EXISTS idx_metrics_day   ON metrics(day);]])
  DB:eval([[CREATE INDEX IF NOT EXISTS idx_metrics_evt   ON metrics(event_type);]])
end)

local Metrics = DB.metrics -- short alias

-- --------------------------------------------------------------------- --
-- helpers
-- --------------------------------------------------------------------- --
local function dims(ts)
  local d = os.date("*t", ts)
  return d.year, d.month, d.day, d.hour
end

local function strip_functions(t)
  if type(t) ~= "table" then
    return t
  end
  local out = {}
  for k, v in pairs(t) do
    if type(v) == "function" then
      -- skip
    elseif type(v) == "table" then
      out[k] = strip_functions(v)
    else
      out[k] = v
    end
  end
  return out
end

-- --------------------------------------------------------------------- --
-- public API
-- --------------------------------------------------------------------- --

---Insert the Neovim <User> autocommand event into the DB.
---@param evt {match:string, data?:table}|table
local function add_metric(evt)
  local now = os.time()
  local y, m, d, h = dims(now)
  Metrics:insert({
    ts = now,
    event_type = evt.match,
    year = y,
    month = m,
    day = d,
    hour = h,
    payload = json_encode(strip_functions(evt.data or {})),
  })
end

---@class MetricStore
local MetricStore = {}

---`SELECT * FROM metrics WHERE …`
---@param where? table
---@return AnalyticsMetricRow[]
function MetricStore:select(where)
  return Metrics:get({ where = where or {} })
end

---Run a raw SQL statement.
---@param statement string
---@param params?   table
---@return table[]        rows
function MetricStore:sql(statement, params)
  local result = DB:eval(statement, params)
  if type(result) == "boolean" then
    return {}
  end
  return result
end

---Allow fall-through to any sqlite_tbl method (`insert`, `get`, …)
setmetatable(MetricStore, { __index = Metrics })

---Optionally expose a tiny wrapper; fixes the earlier “nil delete” issue.
function MetricStore:delete(where) -- luacheck: ignore 212
  return Metrics:remove(where)
end

---Remove rows older than N days (default 365).
---@param retention_days? integer
local function cleanup_metrics(retention_days)
  retention_days = retention_days or 365
  local cutoff = os.time() - retention_days * 24 * 60 * 60
  DB:eval("DELETE FROM metrics WHERE ts < ?", { cutoff })
end

return {
  add_metric = add_metric,
  metrics = MetricStore,
  cleanup_metrics = cleanup_metrics,
}
