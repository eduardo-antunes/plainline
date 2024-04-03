# Plainline

The Merriam-Webster dictionary defines [plain](https://www.merriam-webster.com/dictionary/plain) as undecorated, unobstructed and clear.
Plainline is a simple and succint plugin that brings those qualities to the space of neovim statuslines. It tries to be highly informative
and pratical while also retaining the visual minimalism of the stock statusline.

## Installation

To install it, simply use your preferred neovim plugin manager. Using [lazy.nvim](https://github.com/folke/lazy.nvim), you would have the following:

```lua
{
  "eduardo-antunes/plainline",
  config = function ()
    require("plainline").setup()
  end
}
```

Note that neovim >= 0.7 is required.

## Configuration

You may configure plainline by providing a table to the `setup` function. This table can contain any or all of four keys:

- `sections` determines which providers are used to construct the active statusline;
- `inactive_sections` does the same, but for the inactive statusline;
- `separator` determines the text that is shown between the outputs of providers;
- and `provider_opts` is a table of provider options.

Providers are simply functions that fetch a particular piece of information and display it in text form. They are the building blocks of the statusline. The buitin
providers, which are all defined in [`providers.lua`](./lua/plainline/providers.lua), can be specified by name. You can also pass your own functions as providers,
as long as those functions return strings (or nil).

Provider options are a set of boolean keys that configure the behavior of some providers. Currently, the following options are available:

- `name_filter` enables or disables the name filter. It's on by default;
- `trad_status` changes the plainline-style status indicators (`*` for modified buffers and `#` for read-only ones) for the traditional vim status indicators (namely, `[+]` and `[-]`). It's off by default.

### Name Filter

The name filter is a function within plainline that attempts to clean up buffer names before they are displayed in the statusline. This is done mostly to reduce
noise and make using certain plugins more pleasant. Here's a brief description of the things it does:

- removes protocol-style prefixes (`[protocol]://`);
- truncates the name of terminals to show just the shell name;
- replaces the contents of the `HOME` environment variable with `~`;
- shows just the filename for help and manpage buffers;
- shows just the repository name for fugitive buffers.

### Using Presets

The `setup` function also accepts a string as its argument, interpreting it as the name of a preset. Presets are buitin configurations that combine the available
providers to create some specific style. They are defined in [`presets.lua`](./lua/plainline/presets.lua); emacs users might want to check out the `emacs` preset,
which emulates the look of the stock emacs modeline.

### Default Configuration

```lua
require("plainline").setup {
  sections = {
    left  = { "mode", "branch", "filename", "lsp" },
    right = { "filetype", "fileformat", "percentage", "position" },
  },
  inactive_sections = { left  = { "fullpath" }, right = {} },
  provider_opts = { name_filter = true, trad_status = false }
  separator = " | ", -- suggested alternative: " │ "
}
```

### Tabline

Plainline also comes with a simple tabline module. It preserves the aesthetics of the default tabline while also reducing noise and offering more granular
control of its look to the user. To enable it, simply add the following line to your config:

```lua
require("plainline.tabs").setup()
```

To configure it, you may provide as an argument to `setup` a `tab_title` function. It will be called once for each tabpage, receiving the corresponding tab ID
and number each time. Its return value will be used as the title for that tab. The default implementation, used if no function is given, simply concatenates
the tab number with its current buffer's name.

## Screenshots

The theme used is [onedark.nvim](https://github.com/navarasu/onedark.nvim) and the font is Source Code Pro. I would recommend using a theme that, like onedark, gives
proper contrast to the statusline in relation to the background, as this greatly improves readability.

### Default Configuration

![plainline-default](/static/plainline-default.png?raw=true "Default configuration")

### Emacs Preset

![plainline-emacs](/static/plainline-emacs.png?raw=true "Emacs preset")

## License

```
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
```
