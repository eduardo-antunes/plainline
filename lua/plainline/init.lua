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

-- Main file for plainline

local this = {}

local default_config = {
    sections = {
        left  = { 'evil_mode', 'branch', 'harpoon_filepath', 'filestatus' },
        right = { 'filetype', 'percentage', 'position'},
    },
    inactive_sections = {
        left  = { 'full_filepath' },
        right = {},
    },
    separator = ' | ',
}

local function setup_statusline()
    local plainline_gr = vim.api.nvim_create_augroup('plainline', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
            command = [[setlocal statusline=%!v:lua.require'plainline'.active()]],
            group = plainline_gr,
        })
    vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
            command = [[setlocal statusline=%!v:lua.require'plainline'.inactive()]],
            group = plainline_gr,
        })
end

local function generate_providers(spec)
    local pr = require('plainline.providers')
    local result = { left = {}, right = {} }
    for part, providers in pairs(spec) do
        for _, provider_id in ipairs(providers) do
            local prov = pr[provider_id]
            if prov ~= nil then
                table.insert(result[part], prov)
            end
        end
    end
    return result
end

local function generate_statusline(part_providers, sep)
    local status = { left = '', right = '' }
    for part, providers in pairs(part_providers) do
        local first = true
        for _, prov in ipairs(providers) do
            local info = prov()
            if info ~= nil then
                if first then
                    status[part] = string.format('%s%s', status[part], info)
                    first = false
                else
                    status[part] = string.format('%s%s%s', status[part], sep, info)
                end
            end
        end
    end
    return string.format(' %s%%=%s ', status.left, status.right)
end

function this.setup(config)
    -- If something is not in the config, we look it up in the default config
    if not config then config = default_config
    else setmetatable(config, { __index = default_config }) end
    
    -- Determine which providers are going to be used
    local active_providers = generate_providers(config.sections)
    local inactive_providers = generate_providers(config.inactive_sections)

    -- Define statusline generating functions based on those providers

    this.active = function() 
        return generate_statusline(active_providers, config.separator) 
    end

    this.inactive = function() 
        return generate_statusline(inactive_providers, config.separator) 
    end

    -- Sets up the appropriate autocommands
    setup_statusline()
end

return this
