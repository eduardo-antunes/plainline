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

You may configure plainline by providing a table to the `setup` function. This table can contain any or all of three keys:

- `sections` lists the providers used in the active statusline;
- `inactive_sections` does the same, but for the inactive statusline;
- and `separator` is the text that is shown between the outputs of providers.

Providers are simply functions that fetch a particular piece of information and display it in text form. They are the building blocks of the statusline. The buitin
providers, which are all defined in [`providers.lua`](./lua/plainline/providers.lua), can be specified by name. You can also pass your own functions as providers,
as long as those functions return strings (or nil).

### Using Presets

The `setup` function also accepts a string as its argument, interpreting it as the name of a preset. Presets are buitin configurations that combine the available
providers to create some specific style. They are defined in [`presets.lua`](./lua/plainline/presets.lua); emacs users might want to check out the `emacs` preset,
which emulates the look of the stock emacs modeline.

### Default Configuration

```lua
require("plainline").setup {
  sections = {
    left  = { "mode", "branch", "name", "diagnostics", },
    right = { "macro", "filetype", "fileformat", "percentage", "position" },
  },
  inactive_sections = {
    left  = { "path" },
    right = { "percentage" },
  },
  separator = " │ ",
}
```

## Screenshots

The theme used is [onedark.nvim](https://github.com/navarasu/onedark.nvim) and the font is Inconsolata LGC. I would recommend using a theme that, like onedark, gives
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
