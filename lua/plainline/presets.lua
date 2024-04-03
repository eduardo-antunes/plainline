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

local presets = {}

-- Default configuration
presets.default = {
  sections = {
    left  = { "mode", "branch", "filename", "lsp" },
    right = { "filetype", "fileformat", "percentage", "position" },
  },
  inactive_sections = { left  = { "fullpath" }, right = {} },
  provider_opts = { name_filter = true, trad_status = false },
  separator = " | ", -- suggested alternative: " │ "
}

-- Emulation of the stock emacs modeline
presets.emacs = {
  sections = {
    left  = { "emacs_status", "branch", "emacs_filename" },
    right = { "mode", "trad_percentage", "emacs_linenum", "emacs_modes" },
  },
  inactive_sections = {
    left  = { "emacs_status", "branch", "emacs_filename" },
    right = { "trad_percentage", "emacs_linenum", "emacs_modes" },
  },
  provider_opts = { name_filter = true, trad_status = false },
  separator = "  ",
}

return presets
