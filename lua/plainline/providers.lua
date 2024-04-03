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

-- Cleans up buffer names (if enabled) before display
local function name_filter(name)
  if not require("plainline").opts.name_filter then
    -- The name filter is disabled
    return name
  end
  -- If in a terminal, display just the final part of the "path"
  if name:match("^term://.*$") then
    return vim.fn.fnamemodify(name, ":p:t")
  end
  -- Remove protocol-style prefixes and substitute $HOME for '~'
  name = name:gsub("^.*://(.*)$", "%1")
  name = name:gsub(vim.fn.getenv("HOME"), "~")

  -- Filetype-based noise removal
  if vim.bo.filetype == "help" or vim.bo.filetype == "man" then
    -- I don't care about the path of help pages, just the topic
    name = vim.fn.fnamemodify(name, ":t")
  elseif vim.bo.filetype == "fugitive" then
    -- For fugitive: show just the name of the repository
    name = name:gsub("^.*/(.*)/%.git.*$", "%1.git")
  end
  return name
end

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
setmetatable(mode_id, { __index = function ()
  return "?!" -- unknow modes (should not happen)
end})

local this = {}

-- Shows the current mode, evil-style (I've used emacs btw)
function this.mode()
  local current = vim.api.nvim_get_mode().mode
  return string.format("<%s>", mode_id[current])
end

-- Shows the current git branch if in a git repository
function this.branch()
  -- The current approach to this provider is to just use this buffer local
  -- variable, which is set up to be updated at certain events only. This is
  -- much better than the previous one, which ran git at every screen update
  if vim.b.plainline_branch then
    return string.format("git-%s", vim.b.plainline_branch)
  end
end

-- Shows the name of the current buffer, along with its status
function this.filename()
  local status = this.filestatus()
  local filename = name_filter(vim.fn.expand "%:.")
  if status then
    filename = string.format("%s %s", filename, status)
  end
  return filename
end

-- Shows the status of the file; If it's been modified, shows a '*' character;
-- if it's read-only, shows a '#'; otherwise, does not appear. I realize this
-- is different from the traditional vim status; if you want that, set the
-- trad_status provider option in the config
function this.filestatus()
  local t = require("plainline").opts.trad_status
  if not vim.bo.modifiable or vim.bo.readonly then
    return t and "[-]" or "#"
  elseif vim.bo.modified then
    return t and "[+]" or "*"
  end
  return nil
end

-- Shows the count for each level of diagnostic for the current buffer. Since
-- most diagnostics will come from lsp, that's used as its name
function this.lsp()
  -- Get the count for each diagnostic level
  local e = vim.tbl_count(vim.diagnostic.get(0, { severity = "Error" }))
  local w = vim.tbl_count(vim.diagnostic.get(0, { severity = "Warn"  }))
  local h = vim.tbl_count(vim.diagnostic.get(0, { severity = "Hint"  }))
  local i = vim.tbl_count(vim.diagnostic.get(0, { severity = "Info"  }))
  -- Arrange all counts into a neat little table
  local counts = {
    { sym = "E", n = e }, { sym = "W", n = w },
    { sym = "H", n = h }, { sym = "I", n = i },
  }
  -- Now iterate over the table to generate the status string, skipping counts
  -- that are equal to zero because they would just be noise
  local status = ""
  local before = false -- was there a non-zero count before?
  for _, count in ipairs(counts) do
    if count.n > 0 then
      local sep = before and " " or ""
      status = string.format("%s%s%s:%d", status, sep, count.sym, count.n)
      before = true
    end
  end
  return status
end

-- Shows the full filepath for the buffer, along with its status
function this.fullpath()
  local status = this.filestatus()
  local fullpath = name_filter(vim.fn.expand "%:p")
  if status then
    fullpath = string.format("%s %s", fullpath, status)
  end
  return fullpath
end

-- Shows the filetype for the buffer
function this.filetype()
  return vim.bo.filetype:upper()
end

-- Shows the fileformat for the buffer
function this.fileformat()
  return vim.bo.fileformat
end

-- Shows the percentage of the buffer that has been scrolled down
function this.percentage()
  if vim.bo.filetype == "alpha" then return nil end
  return "%p%%"
end

-- Shows the percentage in the traditional vim fashion
function this.trad_percentage()
  if vim.bo.filetype == "alpha" then return nil end
  return "%P"
end

-- Shows the position in the buffer, using virtual column count
function this.position()
  if vim.bo.filetype == "alpha" then return nil end
  return "%l:%v"
end

-- Shows the position in the buffer, using byte column count
function this.position_bytes()
  if vim.bo.filetype == "alpha" then return nil end
  return "%l:%c"
end

-- In the spirit of catering to the emacs bros (very powerful people), I've
-- taken the liberty to include a series of providers to help emulate
-- components of the stock emacs modeline, thus taking the emacs inspiration
-- already present in plainline one step further. I based these on:
-- https://www.gnu.org/software/emacs/manual/html_node/emacs/Mode-Line.html

-- Shows just the filename, without the buffer status; inteded for use in
-- conjunction with the emacs status
function this.emacs_filename()
  return name_filter(vim.fn.expand "%:.")
end

-- Shows that weird thing in the beggining of the emacs modeline
function this.emacs_status()
  -- Basic file encoding portion (emacs nerds know this is more complicated in
  -- the real thing, but I want to keep it simple)
  local enc = vim.bo.binary and "=" or "-"
  -- Line ending convention portion
  local ending = ":" -- assumes unix
  if vim.bo.fileformat == "dos" then
    ending = "\\"
  elseif vim.bo.fileformat == "mac" then
    ending = "/"
  end
  -- Buffer status portion
  local status = "--" -- assume unmodified
  if not vim.bo.modifiable or vim.bo.readonly then
    status = "%%%%" -- gotta escape the %'s
  elseif vim.bo.modified then
    status = "**"
  end
  -- Assemble the thing
  return string.format("%s%s%s-", enc, ending, status)
end

-- Shows an emacs-style major/minor mode indicator
function this.emacs_modes()
  local major_mode = vim.bo.filetype:gsub("^%l", string.upper)
  if major_mode == "" then
    major_mode = "Fundamental" -- for empty buffers such as the initial
  end
  -- I really don't know what I could show for the minor modes
  return string.format("(%s)", major_mode)
end

-- Shows the line number, emacs style
function this.emacs_linenum()
  return "L%l"
end

-- Shows the position in the buffer, emacs style, emulating the usage of
-- the builtin column-number-mode
function this.emacs_position()
  return "(%l,%v)"
end

return this
