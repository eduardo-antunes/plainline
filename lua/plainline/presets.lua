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

-- The default configuration
presets.default = {
  -- Configurations that are used to assemble the basic shape of the statusline
  sections = {
    left  = { "mode", "branch", "harpoon_filename", "lsp" },
    right = { "filetype", "fileformat", "percentage", "position" },
  },
  inactive_sections = { left  = { "harpoon_fullpath" }, right = {} },
  separator = " | ",
  -- Options that are seen by the providers at runtime
  provider_opts = {
    name_filter = true,  -- enable the name filter
    trad_status = false, -- use traditional vim status indicators
  }
}

-- This is one is for the emacs (evil) users. It combines the available
-- providers to try to emulate the stock emacs modeline. Based on:
-- https://www.gnu.org/software/emacs/manual/html_node/emacs/Mode-Line.html
presets.emacs = {
  sections = {
    left  = { "emacs_status", "branch", "filename" },
    right = { "mode", "trad_percentage", "emacs_linenum", "emacs_modes" },
  },
  inactive_sections = {
    left  = { "emacs_status", "branch", "filename" },
    right = { "trad_percentage", "emacs_linenum", "emacs_modes" },
  },
  separator = "  ",
  provider_opts = { name_filter = true, trad_status = false },
}

return presets
