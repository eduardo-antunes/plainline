# Plainline

The Merriam-Webster dictionary defines
[plain](https://www.merriam-webster.com/dictionary/plain) as undecorated,
unobstructed and clear. Plainline is a simple and succint plugin that brings
those qualities to the space of neovim statuslines. It tries to be highly
informative and pratical while also retaining the visual minimalism of the stock
statusline.

## Installation

Install it using your favorite plugin manager, and don't forget to invoke the
`setup` function. With the new builtin plugin manager of neovim, this would be:

```lua
vim.pack.add { src = "https://github.com/eduardo-antunes/plainline" }
require("plainline").setup()
```

Note that neovim 0.10+ is required for the plugin, and that `vim.pack` is only
available for neovim 0.12+ (for older versions, use a third-party plugin
manager).

## Configuration

You may configure plainline by providing a configuration table to the `setup`
function. This table can contain any or all of five keys:

- `sections` defines the active statusline;
- `inactive_sections` defines the inactive statusline;
- `separator` sets the text that is shown between the outputs of providers;
- `formatter` is a function that is run on the result of each provider before
  it gets displayed. By default, surrounds it with spaces;
- `winbar` should be nil or a table with the `sections` and `inactive_sections`
  keys, which define the active and inactive winbar, respectively. Mostly
  useful with a global statusline (`laststatus` set to 3).

### Sections, inactive sections and providers

The `sections` and `inactive_sections` keys in both the top-level config and the
`winbar` configuration should be tables with any or all of two keys: `left` and
`right`, which define the left and right sections of the statusline/winbar,
respectively. Each of these keys should be a list of providers.

A provider is simply a function that fetches a particular piece of information
and returns it as nicely formatted text. They are the building blocks of
plainline. The builtin providers, which are listed below, may be specified by
name (i.e. as strings). You can also pass your own functions as providers, as
long as they return strings (or nil).

* `mode`: current mode;
* `tabpage`: current tab page number;
* `branch`: current git branch, if in a git repository;
* `name_only`: just the clean buffer name;
* `status`: buffer status. `*` for modified and `#` for read-only;
* `name`: `name_only` + `status` in the same provider;
* `diagnostics`: diagnostics, of course;
* `path_only`: just the clean, absolute filepath of the current buffer;
* `path`: `path_only` + `status` in the same provider;
* `macro`: name of macro being recorded, if any;
* `filetype`: filetype for the current buffer;
* `fileformat`: fileformat for the current buffer, if it's not unix;
* `percentage`: percentage of the buffer that has been scrolled down;
* `position`: position of the cursor within the buffer.

The `name_only` and `path_only` providers apply a cleaning function to their
respective pieces of information. The idea behind that is to reduce visual
noise, improving clarity.

### Default Configuration

```lua
require("plainline").setup {
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
    left  = { "name" },
    right = { "percentage" },
  },
  separator = "│",
  formatter = function(str)
    return string.format(" %s ", str)
  end,
  winbar = nil, -- no winbar by default
}
```

## Screenshot

![screenshot](/static/screenshot.png?raw=true)

The above screenshot showcases the default configuration with both the
`sections` and `inactive_sections` keys of the `winbar`option set to `{ right =
{ "status", "name_only" }}` and `laststatus` set to 2 (the default). The theme
used is [`accent.nvim`](https://github.com/eduardo-antunes/accent.nvim) with the
accent color set to green and the `invert_status` option enabled. The font is
Hack.

## License

```
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
```
