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

local F = {}

function F.clean(name)
  -- For terminal buffers, display their title
  if name:match("^term://.*$") then
    return vim.b.term_title
  end
  -- Remove protocol-style prefixes and substitute $HOME for '~'
  name = name:gsub("^.*://(.*)$", "%1")
  name = name:gsub(vim.fn.getenv("HOME"), "~")

  if vim.bo.filetype == "help" or vim.bo.filetype == "man" then
    -- I don't care about the path of help pages, just the topic
    name = vim.fn.fnamemodify(name, ":t")
  elseif vim.bo.filetype == "fugitive" then
    -- For fugitive: show just the name of the repository
    name = name:gsub("^.*/(.*)/%.git.*$", "%1.git")
  end
  return name
end

--------------------------------------------------------------------------------

local M = {}

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
    local ok, filtered_name = pcall(filter_fn, name)
    if not ok then goto continue end
    name = filtered_name
    ::continue::
  end
  return name
end

return M
