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

-- Configuration-related utilities for plainline

-- Validates the structure of a configuration table; note that all keys are
-- considered optional, which is useful for user configurations
local function validate(user_config)
   -- Validate top-level keys
   vim.validate { config = { user_config, "table", true} }
   user_config = user_config or {}
   vim.validate {
      sections = { user_config.sections, "table", true },
      inactive_sections = { user_config.inactive_sections, "table", true },
      separator = { user_config.separator, "string", true },
      provider_opts = { user_config.provider_opts, "table", true },
   }
   -- Validate table of sections
   if user_config.sections then
      vim.validate {
         sections_left = { user_config.sections.left, "table", true },
         sections_right = { user_config.sections.right, "table", true },
      }
   end
   -- Validate table of inactive sections
   if user_config.inactive_sections then
      vim.validate {
         inactive_sections_left = { user_config.inactive_sections.left, "table", true },
         inactive_sections_right = { user_config.inactive_sections.right, "table", true },
      }
   end
   -- Validate provider options
   if user_config.provider_opts then
      vim.validate {
         name_filter = { user_config.provider_opts.name_filter, "boolean", true },
         trad_status = { user_config.provider_opts.trad_status, "boolean", true },
      }
   end
end

local this = {}

-- Takes a user configuration table (which may very well not contain certain
-- keys or even straight up be nil) and converts it into the appropriate,
-- complete configuration table
function this.full_config_from(user_config)
   local presets = require("plainline.presets")
   -- The user may specify just a preset name as the config. In this case, the
   -- config will be a string and we attempt to load that preset
   if type(user_config) == "string" then
      local preset = presets[user_config]
      if not preset then
         -- Inexistent preset given! Bad!
         error(string.format("Inexistent plainline preset: %s", user_config))
      end
      return preset -- no validation needed
   end
   -- The user config may also be a table or nil (which we translate to the
   -- empty table). We validate it before merging it with the defaults
   validate(user_config)
   local config = vim.tbl_deep_extend("keep", user_config, presets.default)
   return config
end

return this
