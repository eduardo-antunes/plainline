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

-- Takes a provider specification (as given by the sections and inactive
-- sections keys of the config) and returns a table of similar structure, but
-- with concrete functions as its elements
local function get_ptable(sections)
  local ptable = { left = {}, right = {} }
  local builtin = require("plainline.providers")
  for s, providers in pairs(sections) do
    for _, provider in ipairs(providers) do
      if type(provider) == "string" then
        -- Providers given as strings => builtin provider functions
        provider = builtin[provider]
      end
      table.insert(ptable[s], provider)
    end
  end
  return ptable
end

-- Takes a table of functions (as produced by get_ptable), calls them and
-- formats their results into a string, using the separator
local function mkstatus(ptable, separator)
  local status = { left = {}, right = {} }
  for s, providers in pairs(ptable) do
    for _, provider in ipairs(providers) do
      local ok, res = pcall(provider)
      if ok and res and res ~= "" then
        table.insert(status[s], res)
      end
    end
  end
  local left = table.concat(status.left, separator)
  local right = table.concat(status.right, separator)
  return string.format(" %s%%=%s ", left, right)
end

-- Updates the buffer local variable plainline_branch, used by the predefined
-- branch provider and available for use in custom providers. Having this thing
-- here drastically reduces the number of times the git command has to be
-- executed in comparison with the previous approach
local function update_branch(args)
  local branch = vim.fn.system { "git", "symbolic-ref", "--short", "HEAD" }
  if not branch:find("^fatal:.*$") then
    vim.b[args.buf].plainline_branch = branch:gsub("%s+", "")
    return
  end
  vim.b[args.buf].plainline_branch = nil
end

local this = {}

-- Enables plainline, using the functions in plainline.core to set up the
-- appropriate autocommands for the thing to work properly
function this.enable(config)
  local on = get_ptable(config.sections)
  local off = get_ptable(config.inactive_sections)
  -- Statusline functions for active and inactive states, respectively
  this.on  = function() return mkstatus(on, config.separator) end
  this.off = function() return mkstatus(off, config.separator) end

  -- Core autocommands to get plainline running
  local plainline = vim.api.nvim_create_augroup("plainline", {})
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      command = "setl statusline=%{%v:lua.require'plainline.core'.on()%}",
      group = plainline,
    })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
      command = "setl statusline=%{%v:lua.require'plainline.core'.off()%}",
      group = plainline,
    })
  -- Set up ocasional updates to the b:plainline_branch variable
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
      callback = update_branch, group = plainline,
    })
end

return this
