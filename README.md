# Plainline

The Merriam-Webster dictionary defines [plain](https://www.merriam-webster.com/dictionary/plain) as undecorated, unobstructed, clear and characterized by
simplicity. Plainline is a simple and succint plugin that brings those qualities to the space of neovim statuslines. It tries to be highly informative
and pratical while also retaining the visual simplicity of the default statusline.

## Installation

To install it, simply use your preferred neovim plugin manager. Using `packer.nvim`, you would have the following:

```lua
use {
  "eduardo-antunes/plainline",
  config = function ()
    require("plainline").setup()
  end
}
```

Installing the excellent [`harpoon.nvim`](https://github.com/ThePrimeagen/harpoon) is also recommended. Note that neovim >= 0.7 is required.

## Configuration

You may configure plainline by providing a table to the `setup` function. This table can contain any or all of three keys:

- `sections` determines which providers are used to construct the active statusline;
- `inactive_sections` does the same, but for the inactive statusline;
- and `separator` determines the text that is shown between the outputs of providers.

Providers are simply functions that fecth a particular piece information and display it in text form. They are the building blocks of the statusline, and are
specified by name. You can see the available providers in the [`providers.lua`](./lua/plainline/providers.lua) file. Both `sections` and `inactive_sections` are
given as a { left, right } pair, where each one of these is associated with a list of providers.

### Harpoon integration

If `harpoon.nvim` is installed, the `harpoon_filepath` and `harpoon_full_filepath` providers will use it to display the associated harpoon mark number of the
current buffer, in addition to its filepath and modified status.

### Default configuration

```lua
require("plainline").setup {
  sections = {
    left  = { "evil_mode", "branch", "harpoon_filepath", "lsp"   },
    right = { "filetype", "fileformat", "percentage", "position" },
  },
  inactive_sections = { left  = { "harpoon_full_filepath" }, right = {} },
  separator = " | ",
}
```

## Screenshots

![plainline](https://github.com/eduardo-antunes/plainline/assets/61597061/38f85042-156c-4bb7-813e-7d9eba65902a)

The theme used is [nightfly](https://github.com/bluz71/vim-nightfly-colors) and the font is Fira Code. I would recommended using a theme that, like nightfly,
gives proper contrast to the statusline in relation to the brackground. This greatly enhances readability. A couple of examples that pop to mind are
[moonfly](https://github.com/bluz71/vim-moonfly-colors) and [solarized](https://github.com/ishan9299/nvim-solarized-lua).

## License

```
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
```
