--[[
   Copyright 2023 Eduardo Antunes dos Santos Vieira

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

-- Utility functions for plainline

local this = {}

-- From a provider specification of the form { left = {ids...}, right = {ids...}},
-- this function generates a table with a very similar format, but filled with
-- the provider functions that correspond to the given ids.
function this.generate_provider_table(spec)
   local pr = require("plainline.providers")
   local provider_tbl = { left = {}, right = {} }
   for part, provider_ids in pairs(spec) do
      for _, provider_id in ipairs(provider_ids) do
         local prov = pr[provider_id]
         if prov ~= nil then
            table.insert(provider_tbl[part], prov)
         end
      end
   end
   return provider_tbl
end

-- This function receives a provider table, calls the functions stored in it
-- and formats their results them appropiately using the given separator.
function this.generate_statusline(provider_tbl, sep)
   local status = { left = "", right = "" }
   for part, providers in pairs(provider_tbl) do
      local first = true
      for _, prov in ipairs(providers) do
         local info = prov()
         if info ~= nil and info ~= "" then
            if first then
               status[part] = string.format("%s%s", status[part], info)
               first = false
            else
               status[part] = string.format("%s%s%s", status[part], sep, info)
            end
         end
      end
   end
   return string.format(" %s%%=%s ", status.left, status.right)
end

-- This function"s sole responsability is setting up the autocommands necessary
-- to enable plainline. It expects the functions plainline.active and plainline
-- .inactive to have been previously defined.
function this.enable_plainline()
   local plainline_gr = vim.api.nvim_create_augroup("plainline", { clear = true })
   vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
         command = [[ setlocal statusline=%!v:lua.require"plainline".active() ]],
         group = plainline_gr,
      })
   vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
         command = [[ setlocal statusline=%!v:lua.require"plainline".inactive() ]],
         group = plainline_gr,
      })
end

return this
