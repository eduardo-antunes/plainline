--[[
Copyright 2023-2025 Eduardo Antunes dos Santos Vieira

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

local M = {}
local F = {}

function F.show_term_title(name)
  if not name:match("^term://.*$") then return name end
  return vim.b.term_title, true
end

function F.remove_protocol_prefix(name)
  local res = name:gsub("^.*://(.*)$", "%1"); return res
end

function F.abbrev_home_dir(name)
  local res = name:gsub(vim.fn.getenv "HOME", "~"); return res
end

function F.show_help_topic(name)
  if vim.bo.filetype ~= "help" and vim.bo.filetype ~= "man" then return name end
  return vim.fn.fnamemodify(name, ":t")
end

function F.show_repo_name(name)
  if vim.bo.filetype ~= "fugitive" then return name end
  local res = name:gsub("^.*/(.*)/%.git.*$", "%1.git"); return res
end

function F.clean(name)
  local clean_filters = {
    "show_term_title",
    "remove_protocol_prefix",
    "abbrev_home_dir",
    "show_help_topic",
    "show_repo_name",
  }
  return M.apply(clean_filters, name)
end

function M.apply(filters, name)
  for _, name_filter in ipairs(filters) do
    if type(name_filter) ~= "string" and type(name_filter) ~= "function" then
      goto continue
    end
    local filter_fn = name_filter
    if type(filter_fn) ~= "function" then
      filter_fn = F[name_filter]
      if not filter_fn then goto continue end
    end
    local ok, filtered_name, stop = pcall(filter_fn, name)
    if not ok then goto continue end
    name = filtered_name
    if stop then break end
    ::continue::
  end
  return name
end

return M
