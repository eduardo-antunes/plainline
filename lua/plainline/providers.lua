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

-- Lookup table for mode indentifiers
local mode_id = {
  ["n" ] = "N"  , ["no"] = "N"  , ["nt"] = "N"  ,
  ["v" ] = "V"  , ["V" ] = "VL" , [""] = "VB" ,
  ["s" ] = "S"  , ["S" ] = "SL" , [""] = "SB" ,
  ["i" ] = "I"  , ["ic"] = "I"  , ["R" ] = "R"  ,
  ["Rv"] = "Vr" , ["c" ] = "C"  , ["cv"] = "EX" ,
  ["ce"] = "EX" , ["r" ] = "P"  , ["rm"] = "M"  ,
  ["r?"] = "?"  , ["!" ] = "$"  , ["t" ] = "T"  ,
}

-- Cleans up buffer names and paths before they get shown, reducing noise
local function clean(name)
  -- For terminal buffers, display their title
  if name:match("^term://.*$") then
    return vim.b.term_title
  end
  -- Remove protocol-style prefixes and substitute $HOME for '~'
  name = name:gsub("^.*://(.*)$", "%1")
  name = name:gsub(vim.fn.getenv("HOME"), "~")

  if vim.bo.filetype == "help" or vim.bo.filetype == "man" then
    -- I don't care about the path of help pages, just the topic
    name = vim.fn.fnamemodify(name, ":t")
  elseif vim.bo.filetype == "fugitive" then
    -- For fugitive: show just the name of the repository
    name = name:gsub("^.*/(.*)/%.git.*$", "%1.git")
  end
  return name
end

--------------------------------------------------------------------------------

local M = {}

-- Shows the current mode
function M.mode()
  local current = vim.api.nvim_get_mode().mode
  return fmt("<%s>", mode_id[current])
end

-- Shows the current tab number, if there are more tabs open
function M.tabpage()
  if vim.fn.tabpagenr("$") > 1 then
    local t = vim.api.nvim_tabpage_get_number(0)
    return fmt("T%d", t)
  end
end

-- Shows the current git branch
function M.branch()
  if vim.b.plainline_branch then
    return fmt("git-%s", vim.b.plainline_branch)
  end
end

-- Shows clean buffer name
function M.name_only()
  return clean(vim.fn.expand "%:.")
end

-- Shows buffer status in the plainline style:
-- '*' for modified buffers, '#' for read-only ones
function M.status()
  if not vim.bo.modifiable or vim.bo.readonly then
    return "#"
  elseif vim.bo.modified then
    return "*"
  end
end

-- Shows name_only + status
function M.name()
  local name = M.name_only()
  if name == "" then return nil end
  local status = M.status()
  if status then
    name = fmt("%s %s", name, status)
  end
  return name
end

-- Shows diagnostics for buffer
function M.diagnostics()
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
function M.path_only()
  return clean(vim.fn.expand "%:p")
end

-- Shows path_only + status
function M.path()
  local path = M.path_only()
  if path == "" then return nil end
  local status = M.status()
  if status then
    path = fmt("%s %s", path, status)
  end
  return path
end

-- Shows name of the macro being recorded
function M.macro()
  local name = vim.fn.reg_recording()
  if name == "" then return nil end -- not recording
  return fmt("@%s", name)
end

-- Shows buffer filetype
function M.filetype()
  return vim.bo.filetype
end

-- Shows fileformat of the buffer, unless it's unix
function M.fileformat()
  local fmt = vim.bo.fileformat
  if fmt == "unix" then return nil end
  return fmt
end

-- Shows percentage of the buffer that has been scrolled down
function M.percentage()
  return "%p%%"
end

-- Shows position in the buffer, using virtual column count
function M.position()
  return "%l:%v"
end

return M
