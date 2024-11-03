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

-- Takes a user configuration and expands it into a full config table
local function full_config(user_config)
   local presets = require("plainline.presets")
   -- The user may specify just a preset name as the config. In this case, the
   -- config will be a string and we attempt to load that preset
   if type(user_config) == "string" then
      local preset = presets[user_config]
      if not preset then
         error(string.format("Inexistent plainline preset: %s", user_config))
      end
      if preset ~= presets.default then
        -- Makes all presets fallback to the default configuration
        setmetatable(preset, {__index=preset})
      end
      return preset
   end
   user_config = user_config or {}
   local config = vim.tbl_deep_extend("keep", user_config, presets.default)
   return config
end

local this = {}

function this.setup(user_config)
  local config = full_config(user_config)
  require("plainline.core").enable(config)
end

return this
