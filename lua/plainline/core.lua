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
-- formats each result using the `formatter` from the config and then joins
-- the formatted results into the final string, using the `separator`.
local function mkstatus(ptable, config)
  local separator = config.separator
  local formatter = config.formatter

  local status = { left = {}, right = {} }
  for s, providers in pairs(ptable) do
    for _, provider in ipairs(providers) do
      local ok, res = pcall(provider)
      if not ok then
        -- Indicate a provider failed to run
        table.insert(status[s], '<err>')
      elseif res and res ~= "" then
        table.insert(status[s], formatter(res))
      end
    end
  end
  local left = table.concat(status.left, separator)
  local right = table.concat(status.right, separator)
  return string.format("%s%%=%s", left, right)
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

-- Due to some quirks with winbars, this function does some checking
-- before setting the `winbar` option on a window.
local function enable_winbar(mode)
  -- If for whatever reason winbar_* isn't defined, give up.
  if this.winbar_on == nil or this.winbar_off == nil then
    return
  end
  -- Means current window
  local window_id = 0
  -- Give up if window is floating. This is done because
  -- floating windows don't deal well with winbars.
  if vim.api.nvim_win_get_config(window_id).relative ~= '' then
    return
  end

  if mode == 'on' then
    vim.wo.winbar = "%{%v:lua.require'plainline.core'.winbar_on()%}"
  elseif mode == 'off' then
    vim.wo.winbar = "%{%v:lua.require'plainline.core'.winbar_off()%}"
  else
    error(string.format('Invalid winbar mode "%s"', mode))
  end
end

local function setup_locals(config)

  -- Core autocommands to get plainline running
  local plainline = this.plainline_group
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    command = "setl statusline=%{%v:lua.require'plainline.core'.on()%}",
    group = plainline,
  })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    command = "setl statusline=%{%v:lua.require'plainline.core'.off()%}",
    group = plainline,
  })

  -- Setup winbar too
  if config.winbar then
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      callback = function() enable_winbar('on') end,
      group = plainline,
    })
    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
      callback = function() enable_winbar('off') end,
      group = plainline,
    })
  end
end

local function setup_globals(config)
  vim.go.statusline = "%{%v:lua.require'plainline.core'.on()%}"

  -- Tragically, quickfix tries to set its own statusline.
  -- See: https://github.com/neovim/neovim/issues/27731
  vim.api.nvim_create_autocmd({'FileType'}, {
    pattern = 'qf',
    command = 'setl statusline=',
    group=this.plainline_group,
  })

  if config.winbar then
    -- Unfortunately, this still needs to be run using autocommands
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      callback = function() enable_winbar('on') end,
      group = this.plainline_group,
    })
  end
end

-- Enables plainline, using the functions in plainline.core to set up the
-- appropriate autocommands for the thing to work properly
function this.enable(config)
  local on = get_ptable(config.sections)
  local off = get_ptable(config.inactive_sections)

  this.plainline_group = vim.api.nvim_create_augroup("plainline", {})

  -- Statusline functions for active and inactive states, respectively
  this.on  = function() return mkstatus(on, config) end
  this.off = function() return mkstatus(off, config) end

  if config.winbar then
    local winbar_on = get_ptable(config.winbar.sections or {})
    local winbar_off = get_ptable(config.winbar.inactive_sections or {})

    -- Winbar functions for active and inactive states, respectively
    this.winbar_on  = function() return mkstatus(winbar_on, config) end
    this.winbar_off = function() return mkstatus(winbar_off, config) end
  end

  -- If laststatus is set to 3, this means the user has a global status bar,
  -- which means there is no need to set it individually for each window.
  if vim.go.laststatus == 3 then
    setup_globals(config)
  else
    setup_locals(config)
  end

  -- Set up ocasional updates to the b:plainline_branch variable
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
      callback = update_branch, group = this.plainline_group,
    })
end

return this
