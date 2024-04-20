--[[
   Copyright 2023-2024 Eduardo Antunes dos Santos Vieira

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

local this = {}

-- Shows the current mode
function this.mode()
  local current = vim.api.nvim_get_mode().mode
  return string.format("<%s>", mode_id[current])
end

-- Shows the current git branch
function this.branch()
  if vim.b.plainline_branch then
    return string.format("git-%s", vim.b.plainline_branch)
  end
end

-- Shows the name of the buffer and its status
function this.name()
  local name = clean(vim.fn.expand "%:.")
  if name == "" then return nil end
  local status = this.status()
  if status then
    name = string.format("%s %s", name, status)
  end
  return name
end

-- Shows the buffer status in a very particular way: '*' for modified buffers
-- and '#' for read-only ones, instead of the traditional '[+]' and '[-]'
function this.status()
  if not vim.bo.modifiable or vim.bo.readonly then
    return "#"
  elseif vim.bo.modified then
    return "*"
  end
end

-- Shows diagnostics for the current buffer
function this.diagnostics()
  local diag = {}
  local error = #vim.diagnostic.get(0, { severity = 1 })
  local warns = #vim.diagnostic.get(0, { severity = 2 })
  local infos = #vim.diagnostic.get(0, { severity = 3 })
  local hints = #vim.diagnostic.get(0, { severity = 4 })
  if error > 0 then table.insert(diag, string.format("E:%d", error)) end
  if warns > 0 then table.insert(diag, string.format("W:%d", warns)) end
  if infos > 0 then table.insert(diag, string.format("I:%d", infos)) end
  if hints > 0 then table.insert(diag, string.format("H:%d", hints)) end
  return table.concat(diag, " ")
end

-- Shows the full path of the buffer, along with its status
function this.path()
  local path = clean(vim.fn.expand "%:p")
  if path == "" then return nil end
  local status = this.status()
  if status then
    path = string.format("%s %s", path, status)
  end
  return path
end

-- Shows the name of the macro being recorded, if there is one
function this.macro()
  local name = vim.fn.reg_recording()
  if name == "" then return nil end -- not recording
  return string.format("recording @%s", name)
end

-- Shows the filetype of the buffer
function this.filetype()
  return vim.bo.filetype:gsub("^%l", string.upper)
end

-- Shows the fileformat of the buffer, unless it's unix
function this.fileformat()
  local fmt = vim.bo.fileformat
  if fmt == "unix" then return nil end
  return fmt
end

-- Shows the percentage of the buffer that has been scrolled down
function this.percentage()
  return "%p%%"
end

-- Shows the position in the buffer, using virtual column count
function this.position()
  return "%l:%v"
end

-- Shows the buffer status, emacs-style
function this.emacs_status()
  local type = vim.bo.binary and "=" or "-"
  local fmt_id = { unix = ":", dos = "\\", mac = "/" }
  local status = "--"
  if not vim.bo.modifiable or vim.bo.readonly then
    status = "%%%%"
  elseif vim.bo.modified then
    status = "**"
  end
  local fmt = fmt_id[vim.bo.fileformat]
  return string.format("%s%s%s-", type, fmt, status)
end

-- Shows just the name of the buffer, without the status
function this.emacs_name()
  return clean(vim.fn.expand "%:.")
end

-- Shows the percentage, emacs style
function this.emacs_percentage()
  return "%P"
end

-- Shows the position in the buffer, emacs style (column-number-mode)
function this.emacs_position()
  return "(%l,%v)"
end

-- Shows the current git branch, emacs style
function this.emacs_branch()
  if vim.b.plainline_branch then
    return string.format("Git:%s", vim.b.plainline_branch)
  end
end

-- Shows an emacs mode indicator
function this.emacs_mode()
  local mode
  if vim.fn.expand("%"):match("^term//.*$") then
    mode = "Vterm"
  else
    mode = vim.bo.filetype:gsub("^%l", string.upper)
    if mode == "" then mode = "Fundamental" end
  end
  return string.format("(%s)", mode)
end

return this
