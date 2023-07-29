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

local this = {}

local default_config = {
    sections = {
        left  = { 'evil_mode', 'branch', 'harpoon_filepath', 'lsp'   },
        right = { 'filetype', 'fileformat', 'percentage', 'position' },
    },
    inactive_sections = {
        left  = { 'harpoon_full_filepath' },
        right = {},
    },
    separator = ' | ',
}

function this.setup(config)
    local lib = require('plainline.utils')
    -- If something is not in the config, it is looked up in the default config
    if not config then config = default_config
    else setmetatable(config, { __index = default_config }) end

    -- Process the config to determine what must be in the statusline
    local apr = lib.generate_provider_table(config.sections)
    local ipr = lib.generate_provider_table(config.inactive_sections)

    -- Define the functions responsible for generating the statusline in its
    -- two states: active and inactive
    this.active = function()
        return lib.generate_statusline(apr, config.separator)
    end
    this.inactive = function()
        return lib.generate_statusline(ipr, config.separator)
    end
    -- Enable the statusline; this uses plainline.active and plainline.inactive
    -- under the hood
    lib.enable_plainline()
end

return this
