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

local a = vim.api -- helpful alias

-- Takes the ID and the number of a tabpage and generates a title for it; this
-- is the default value of the tab_title function
local function default_tab_title(tab_id, tab_nr)
   -- Get the tab's current buffer
   local win = a.nvim_tabpage_get_win(tab_id)
   local buf = a.nvim_win_get_buf(win)

   -- Actually generate the title
   local fullname = a.nvim_buf_get_name(buf)
   local name = vim.fn.fnamemodify(fullname, ":p:t")
   return string.format("%d %s", tab_nr, name)
end

-- Iterates over all tabpages, generating titles for each of them using the
-- provided tab_title function and formatting them as a valid tabline
local function make_tabs(tab_title)
   local tabs = ""
   local current_tab_nr = a.nvim_tabpage_get_number(0)
   local tabpages = a.nvim_list_tabpages()

   for _, tab_id in ipairs(tabpages) do
      -- There is this curious distinction in vim between the tab handle (or ID)
      -- and the tab number. Though both are positive integers, one is intended
      -- as a reference to the tab itself and the other, just for presentation
      local tab_nr = a.nvim_tabpage_get_number(tab_id)

      local title = tab_title(tab_id, tab_nr)
      local tab_nr = a.nvim_tabpage_get_number(tab_id)
      local hl = (tab_nr == current_tab_nr) and "%#TabLineSel#" or "%#TabLine#"
      local tab = string.format("%%%dT%s %s ", tab_nr, hl, title)
      tabs = string.format("%s%s", tabs, tab)
   end
   return tabs .. "%#TabLineFill#%="
end

local this = {}

-- Enables plainline.tabs with a custom tab_title function (or the default,
-- if nil is given), using the 'tabline' option
function this.setup(tab_title)
   tab_title = tab_title or default_tab_title
   this.tabline = function() return make_tabs(tab_title) end
   vim.opt.tabline = "%!v:lua.require'plainline.tabs'.tabline()"
end

return this
