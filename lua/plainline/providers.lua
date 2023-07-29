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

-- Default plainline providers

local this = {}

-- Require a module if it exists only
local function try_require(name)
    local exists, lib = pcall(require, name)
    if exists then return lib end
    return nil
end

local evil_mode_lookup = {
    ['n' ] = 'N' ,
    ['no'] = 'N' ,
    ['nt'] = 'N' ,
    ['v' ] = 'V' ,
    ['V' ] = 'VL',
    [''] = 'VB',
    ['s' ] = 'S' ,
    ['S' ] = 'SL',
    [''] = 'SB',
    ['i' ] = 'I' ,
    ['ic'] = 'I' ,
    ['R' ] = 'R' ,
    ['Rv'] = 'Vr',
    ['c' ] = 'C' ,
    ['cv'] = 'EX',
    ['ce'] = 'EX',
    ['r' ] = 'P' ,
    ['rm'] = 'M' ,
    ['r?'] = '?' ,
    ['!' ] = '$' ,
    ['t' ] = 'T' ,
}

function this.evil_mode()
    local current = vim.api.nvim_get_mode().mode
    return string.format('<%s>', evil_mode_lookup[current])
end

function this.branch()
    local branch = vim.fn.system { 'git', 'symbolic-ref', '--short', 'HEAD' }
    if branch:find('^fatal:.*$') then return nil end
    return string.format('git-%s', branch:gsub('%s+', ''))
end

function this.harpoon()
    local fname = vim.fn.expand('%')
    local mark = try_require('harpoon.mark')
    if mark ~= nil then
        local harpoon_id = mark.get_index_of(fname)
        return harpoon_id
    end
    return nil
end

function this.harpoon_filepath()
    local text = ''
    local fname = vim.fn.expand('%')
    local harpoon_id = this.harpoon()
    if harpoon_id ~= nil then
        text = string.format('(%s) ', harpoon_id)
    end
    text = string.format('%s%s', text, fname)
    local status = this.evil_filestatus()
    if status ~= nil then
        text = string.format('%s %s', text, status)
    end
    return text
end

function this.evil_filestatus()
    if not vim.bo.modifiable or vim.bo.readonly then
        return '#'
    elseif vim.bo.modified then
        return '*'
    end
    return nil
end

function this.filestatus()
    if not vim.bo.modifiable or vim.bo.readonly then
        return '-'
    elseif vim.bo.modified then
        return '+'
    end
    return nil
end

local lsp_lookup = {
    errors   = { sym = 'E', level = 'Error' },
    warnings = { sym = 'W', level = 'Warn'  },
    hints    = { sym = 'H', level = 'Hint'  },
    info     = { sym = 'I', level = 'Info'  },
}

function this.lsp()
    local count = {}
    for name, tbl in pairs(lsp_lookup) do
        local diagnostics = vim.diagnostic.get(0, { severity = tbl.level })
        count[name] = vim.tbl_count(diagnostics)
    end

    local out = ''
    local prev = false
    if count.errors > 0 then
        out = string.format('%s%s:%s', out, lsp_lookup.errors.sym, count.errors)
        prev = true
    end
    if count.warnings > 0 then
        local ws = prev and ' ' or ''
        out = string.format('%s%s%s:%s', out, ws, lsp_lookup.warnings.sym, count.warnings)
        prev = true
    end
    if count.hints > 0 then
        local ws = prev and ' ' or ''
        out = string.format('%s%s%s:%s', out, ws, lsp_lookup.hints.sym, count.hints)
        prev = true
    end
    if count.info > 0 then
        local ws = prev and ' ' or ''
        out = string.format('%s%s%s:%s', out, ws, lsp_lookup.info.sym, count.info)
        prev = true
    end

    return out ~= '' and out or nil
end

function this.full_filepath()
    return '%F'
end

function this.harpoon_full_filepath()
    local text = ''
    local fname = vim.fn.expand('%')
    local harpoon_id = this.harpoon()
    if harpoon_id ~= nil then
        text = string.format('(%s) %%F', harpoon_id)
        return text
    end
    return '%F'
end

function this.filetype()
    return vim.bo.filetype:upper()
end

function this.fileformat()
    return vim.bo.fileformat
end

function this.percentage()
    if vim.bo.filetype == 'alpha' then return nil end
    return '%p%%'
end

function this.position()
    if vim.bo.filetype == 'alpha' then return nil end
    return '%l:%c'
end

return this
