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

-- Presets of configuration for plainline

return {
  -- Default configuration
  default = {
    sections = {
      left  = {
        "mode",
        "tabpage",
        "branch",
        "name",
        "diagnostics",
      },
      right = {
        "macro",
        "filetype",
        "fileformat",
        "percentage",
        "position",
      },
    },
    inactive_sections = {
      left  = { "path" },
      right = { "percentage" },
    },
    global = false,
    separator = "│",
    formatter = function (component) return string.format(' %s ', component) end,
    winbar = nil,
  },
  -- Emulation of the stock emacs modeline
  emacs = {
    sections = {
      left = {
        "emacs_status",
        "emacs_name",
        "emacs_percentage",
        "emacs_position",
        "emacs_branch",
        "emacs_mode",
      }
    },
    inactive_sections = {
      left = {
        "emacs_status",
        "emacs_name",
        "emacs_percentage",
        "emacs_position",
        "emacs_branch",
        "emacs_mode",
      }
    },
    separator = "  ",
  },
}
