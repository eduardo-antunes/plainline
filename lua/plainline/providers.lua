--[[
Copyright 2023-2025 Eduardo Antunes dos Santos Vieira

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]--

local fmt = string.format
local filters = require("plainline.filters")

local P = {}

-- Shows the current mode
function P.mode()
  local mode_id = {
    ["n" ] = "N"  , ["no"] = "N"  , ["nt"] = "N"  ,
    ["v" ] = "V"  , ["V" ] = "VL" , [""] = "VB" ,
    ["s" ] = "S"  , ["S" ] = "SL" , [""] = "SB" ,
    ["i" ] = "I"  , ["ic"] = "I"  , ["R" ] = "R"  ,
    ["Rv"] = "RV" , ["c" ] = "C"  , ["cv"] = "EX" ,
    ["ce"] = "EX" , ["r" ] = "P"  , ["rm"] = "M"  ,
    ["r?"] = "?"  , ["!" ] = "$"  , ["t" ] = "T"  ,
  }
  local current = vim.api.nvim_get_mode().mode
  return fmt("<%s>", mode_id[current] or "_")
end

-- Shows the current tab number, if there are more tabs open
function P.tabpage()
  if vim.fn.tabpagenr("$") > 1 then
    local t = vim.api.nvim_tabpage_get_number(0)
    return fmt("T%d", t)
  end
end

-- Shows the current git branch
function P.branch()
  if vim.b.plainline_branch then
    return fmt("git-%s", vim.b.plainline_branch)
  end
end

-- Shows buffer name with filters applied
function P.name_only()
  local name = vim.fn.expand "%:."
  return filters.apply(P.name_filters, name)
end

-- Shows buffer status in the plainline style:
-- '*' for modified buffers, '#' for read-only ones
function P.status()
  if not vim.bo.modifiable or vim.bo.readonly then
    return "#"
  elseif vim.bo.modified then
    return "*"
  end
end

-- Shows name_only + status
function P.name()
  local name = P.name_only()
  if name == "" then return nil end
  local status = P.status()
  if status then
    name = fmt("%s %s", name, status)
  end
  return name
end

-- Shows diagnostics for buffer
function P.diagnostics()
  local diag = {}
  local sev = { "E", "W", "I", "H" }
  local count = vim.diagnostic.count(0)
  for i = 1, #sev do
    if not count[i] then goto continue end
    table.insert(diag, fmt("%s:%s", sev[i], count[i]))
    ::continue::
  end
  return table.concat(diag, " ")
end

-- Shows clean full path of buffer
function P.path_only()
  local path = vim.fn.expand "%:p"
  return filters.apply(P.name_filters, path)
end

-- Shows path_only + status
function P.path()
  local path = P.path_only()
  if path == "" then return nil end
  local status = P.status()
  if status then
    path = fmt("%s %s", path, status)
  end
  return path
end

-- Shows name of the macro being recorded
function P.macro()
  local name = vim.fn.reg_recording()
  if name == "" then return nil end -- not recording
  return fmt("@%s", name)
end

-- Shows buffer filetype
function P.filetype()
  return vim.bo.filetype
end

-- Shows fileformat of the buffer, unless it's unix
function P.fileformat()
  local fmt = vim.bo.fileformat
  if fmt == "unix" then return nil end
  return fmt
end

-- Shows percentage of the buffer that has been scrolled down
function P.percentage()
  return "%p%%"
end

-- Shows position in the buffer, using virtual column count
function P.position()
  return "%l:%v"
end

--------------------------------------------------------------------------------

local M = {}

function M.with_filters(name_filters)
  P.name_filters = name_filters
  return P
end

return M
