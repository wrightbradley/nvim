---@file Code injection utilities for Neovim
--- This module provides utility functions for code injection and manipulation in Neovim.
--- It includes functions for wrapping functions with additional logic and manipulating
--- upvalues in Lua functions.

---@class wrightbradley.util.inject
local M = {}

--- Wraps a function with additional logic.
--- The wrapper function is called with the same arguments as the original function.
--- If the wrapper returns false, the original function is not called.
---@generic A: any
---@generic B: any
---@generic C: any
---@generic F: function
---@param fn F|fun(a:A, b:B, c:C) The original function to wrap.
---@param wrapper fun(a:A, b:B, c:C): boolean? The wrapper function.
---@return F The wrapped function.
function M.args(fn, wrapper)
  return function(...)
    if wrapper(...) == false then
      return
    end
    return fn(...)
  end
end

--- Retrieves an upvalue from a function.
---@param func function The function to inspect.
---@param name string The name of the upvalue to retrieve.
---@return any The value of the upvalue, or nil if not found.
function M.get_upvalue(func, name)
  local i = 1
  while true do
    local n, v = debug.getupvalue(func, i)
    if not n then
      break
    end
    if n == name then
      return v
    end
    i = i + 1
  end
end

--- Sets an upvalue in a function.
---@param func function The function to modify.
---@param name string The name of the upvalue to set.
---@param value any The new value for the upvalue.
function M.set_upvalue(func, name, value)
  local i = 1
  while true do
    local n = debug.getupvalue(func, i)
    if not n then
      break
    end
    if n == name then
      debug.setupvalue(func, i, value)
      return
    end
    i = i + 1
  end
  Util.error("upvalue not found: " .. name)
end

return M
