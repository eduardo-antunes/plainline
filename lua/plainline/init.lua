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

local this = {}

local function get_full_config(user_config)
  -- The user may specify just a preset name as the config. In this case, the
  -- config will be a string and we attempt to load that preset
  if type(user_config) == "string" then
    local config = require("plainline.presets")[user_config]
    if config == nil then
      error(string.format("Invalid plainline preset: %s"), user_config)
    end
    -- no validation needed because the presets are all valid configurations
    return config
  end

  -- Otherwise, the user config must be a table, which we have to recursively
  -- merge with the default preset in order to get the full configuration table
  vim.validate { config = { user_config, "table", true } }
  local default = require("plainline.presets").default
  local config = vim.tbl_deep_extend("keep", user_config or {}, default)

  -- Validate the provided config's keys, in order to catch configuration
  -- errors early and report them to the user
  vim.validate {
    sections = { config.sections, "table" },
    inactive_sections = { config.inactive_sections, "table" },
    separator = { config.separator, "string" },
    provider_opts = { config.provider_opts, "table" },
  }
  -- Providers must be given as either strings or functions (custom providers)
  for _, provider in ipairs(config.sections) do
    vim.validate { active_provider = { provider, { "string", "function"} } }
  end
  for _, provider in ipairs(config.inactive_sections) do
    vim.validate { inactive_provider = { provider, { "string", "function"} } }
  end
  -- Validate provider options
  vim.validate {
    name_filter = { config.provider_opts.name_filter, "boolean" },
    trad_status = { config.provider_opts.trad_status, "boolean" },
  }

  return config
end

function this.setup(user_config)
  local config = get_full_config(user_config)
  -- Make the configurations that must be seen by the providers at runtime
  -- available to them via the require'plainline'.opts table
  this.opts = config.provider_opts

  -- Process the config to determine what must be in the statusline
  local utils = require("plainline.utils")
  local a = utils.generate_provider_table(config.sections)
  local i = utils.generate_provider_table(config.inactive_sections)

  -- Define the functions responsible for generating the statusline in its
  -- two states: active and inactive. This functions are baked into the
  -- autocommands used to enable plainline
  this.active   = function() return utils.generate_statusline(a, config.separator) end
  this.inactive = function() return utils.generate_statusline(i, config.separator) end
  utils.enable_plainline(active, inactive, config.separator)
end

return this
