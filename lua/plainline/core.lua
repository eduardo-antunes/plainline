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

local M = {}
local fmt = string.format

-- Takes a provider specification (as given by the sections and inactive
-- sections keys of the config) and returns a table of similar structure,
-- but with concrete functions as its elements
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

-- Takes a table of functions (as produced by get_ptable) and calls them.
-- Formats each result using a formatter function and then joins the formatted
-- results with a separator.
local function mkstatus(ptable, config)
  local status = { left = {}, right = {} }
  for s, providers in pairs(ptable) do
    for _, provider in ipairs(providers) do
      local ok, res = pcall(provider)
      if not ok then
        -- Indicate a provider failed to run
        table.insert(status[s], "<err>")
      elseif res and res ~= "" then
        table.insert(status[s], config.formatter(res))
      end
    end
  end
  local left = table.concat(status.left, config.separator)
  local right = table.concat(status.right, config.separator)
  return fmt("%s%%=%s", left, right)
end

-- Updates the buffer local variable plainline_branch, which shows the current
-- git branch. It's better to have a dedicated variable for this
local function update_branch(args)
  local branch = vim.fn.system { "git", "symbolic-ref", "--short", "HEAD" }
  if not branch:find("^fatal:.*$") then
    vim.b[args.buf].plainline_branch = branch:gsub("%s+", "")
    return
  end
  vim.b[args.buf].plainline_branch = nil
end

--------------------------------------------------------------------------------

-- Sets statusline for the current buffer
local function set_status(mode)
  -- Sanity checks
  if mode ~= "on" and mode ~= "off" then return end
  if not M.status_on or not M.status_off then return end

  local expr = fmt("%%{%%v:lua.require'plainline.core'.status_%s()%%}", mode)
  vim.wo.statusline = expr
end

-- Sets winbar for the current window
-- Mode must be one of 'on' or 'off'
local function set_winbar(mode)
  -- Sanity checks
  if mode ~= "on" and mode ~= "off" then return end
  if not M.winbar_on or not M.winbar_off then return end

  -- No point in setting winbar for floating windows
  if vim.api.nvim_win_get_config(0).relative ~= "" then return end
  local expr = fmt("%%{%%v:lua.require'plainline.core'.winbar_%s()%%}", mode)
  vim.wo.winbar = expr
end

local function autocmd_setup_status_local(group)
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    callback = function() set_status("on") end,
    group = group,
  })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    callback = function() set_status("off") end,
    group = group,
  })
end

local function autocmd_setup_status_global(group)
  vim.go.statusline = "%{%v:lua.require'plainline.core'.status_on()%}"
  -- Tragically, quickfix tries to set its own statusline.
  -- See: https://github.com/neovim/neovim/issues/27731
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf", group = group,
    callback = function() vim.wo.statusline = "" end
  })
end

local function autocmd_setup_winbar(group)
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    callback = function() set_winbar("on") end,
    group = group,
  })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    callback = function() set_winbar("off") end,
    group = group,
  })
end

--------------------------------------------------------------------------------

-- Enables plainline, using the functions in plainline.core to set up the
-- appropriate autocommands for the thing to work properly
function M.enable(config)
  local plainline_group = vim.api.nvim_create_augroup("plainline", {})

  -- Statusline functions for active and inactive states, respectively
  local on = get_ptable(config.sections)
  local off = get_ptable(config.inactive_sections)
  M.status_on  = function() return mkstatus(on, config) end
  M.status_off = function() return mkstatus(off, config) end

  if vim.o.laststatus == 3 then
    autocmd_setup_status_global(plainline_group)
  else autocmd_setup_status_local(plainline_group)
  end

    -- Winbar functions for active and inactive states, respectively
  if config.winbar then
    local winbar_on = get_ptable(config.winbar.sections or {})
    local winbar_off = get_ptable(config.winbar.inactive_sections or {})
    M.winbar_on  = function() return mkstatus(winbar_on, config) end
    M.winbar_off = function() return mkstatus(winbar_off, config) end
    autocmd_setup_winbar(plainline_group)
  end

  -- Set up ocasional updates to the b:plainline_branch variable
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
      callback = update_branch, group = plainline_group,
    })
end

return M
