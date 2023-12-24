# Plainline

The Merriam-Webster dictionary defines [plain](https://www.merriam-webster.com/dictionary/plain) as undecorated, unobstructed, clear and characterized by
simplicity. Plainline is a simple and succint plugin that brings those qualities to the space of neovim statuslines. It tries to be highly informative
and pratical while also retaining the visual simplicity of the default statusline.

## Installation

To install it, simply use your preferred neovim plugin manager. Using [`lazy.nvim`](https://github.com/folke/lazy.nvim), you would have the following:

```lua
{ "eduardo-antunes/plainline", opts = {} },
```

Note that neovim >= 0.7 is required.

## Configuration

You may configure plainline by providing a table to the `setup` function (or to the `opts` key in the lazy plugin spec). This table can contain any or all of
four keys:

- `sections` determines which providers are used to construct the active statusline;
- `inactive_sections` does the same, but for the inactive statusline;
- `separator` determines the text that is shown between the outputs of providers;
- and `mode_filter` enables or disables the mode filter.

Providers are simply functions that fecth a particular piece information and display it in text form. They are the building blocks of the statusline, and are
specified by name. You can see the available providers in the [`providers.lua`](./lua/plainline/providers.lua) file. Both `sections` and `inactive_sections` are
given as a { left, right } pair, where each one of these is associated with a list of providers.

### Mode filter

If the current buffer is of a type closely associated to a particular plugin or vim functionality, plainline will apply the mode filter, which will clean up
its name before showing it on the status line. This filter is based on the filetype (the "mode", in emacs terminology) and on the name itself, and is designed
to reduce noise in the displayed name. The effects of this feature may be seen in help files, manpages and [fugitive](https://github.com/tpope/vim-fugitive)
buffers, to cite a few.

I realize this may not be a good feature for everyone, though. If you'd rather always see the original names/filepaths for every buffer, you can easily disable
the mode filter in your config, as seen above.

### Harpoon integration

If `harpoon.nvim` is installed, the `harpoon_filepath` and `harpoon_full_filepath` providers (which are used by default) will use it to display the associated
harpoon mark number of the current buffer, in addition to its filepath and modified status. This may come in handy if you have key mappings to navigate to each
harpoon mark by its number.

### Default configuration

```lua
require("plainline").setup {
  sections = {
    left  = { "evil_mode", "branch", "harpoon_filepath", "lsp"   },
    right = { "filetype", "fileformat", "percentage", "position" },
  },
  inactive_sections = { left  = { "harpoon_full_filepath" }, right = {} },
  mode_filter = true,
  separator = " | ",
}
```

## Screenshots

![plainline](https://github.com/eduardo-antunes/plainline/assets/61597061/d49421e7-0dfe-44f3-9920-446bf189891d)

The theme used is [vim-habamax](https://github.com/habamax/vim-habamax) and the font is Intel One Mono. I would recommend using a theme that, like habamax, lends
proper contrast to the statusline in relation to the background, as this greatly improves readability.

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
