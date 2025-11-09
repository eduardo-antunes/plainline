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

- `sections` lists the providers used in the active statusline;
- `inactive_sections` does the same, but for the inactive statusline;
- `separator` is the text that is shown between the outputs of providers;
- `formatter` is a function that is run on the result of each provider before it
  gets displayed;
- `winbar` should be a table with the `sections` and `inactive_sections` keys,
  following the exact same structure as the ones in the top-level config. They
  specify the providers used for the active and inactive winbar, respectively.
  Mostly useful with a global statusline.

Providers are simply functions that fetch a particular piece of information and
display it in text form. They are the building blocks of the statusline. The
buitin providers, which are all defined in
[`providers.lua`](./lua/plainline/providers.lua), can be specified by name. You
can also pass your own functions as providers, as long as those functions return
strings (or nil).

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
  formatter = function(component)
    return string.format(' %s ', component)
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
