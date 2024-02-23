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

function this.setup(user_config)
  local config = require("plainline.config").full_config_from(user_config)
  -- Make provider options availabe to all providers at runtime
  this.opts = config.provider_opts
  require("plainline.core").enable(config) -- enable plainline
end

return this
