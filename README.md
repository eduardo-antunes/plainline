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
function. This table can contain any or all of six keys:

- `sections` defines the active statusline;
- `inactive_sections` defines the inactive statusline;
- `separator` sets the text that is shown between the outputs of providers;
- `formatter` is a function that is run on the result of each provider before
  it gets displayed. By default, surrounds it with spaces;
- `name_filters` defines the filtering functions that will be applied to buffer
  names before display;
- `winbar` should be nil or a table with the `sections` and `inactive_sections`
  keys, which define the active and inactive winbar, respectively. Mostly
  useful with a global statusline (`laststatus` set to 3);

### Sections, inactive sections and providers

The `sections` and `inactive_sections` keys in both the top-level config and the
`winbar` configuration should be tables with any or all of two keys: `left` and
`right`, which define the left and right sections of the statusline/winbar,
respectively. Each of these keys should be a list of providers.

A provider is simply a function that fetches a particular piece of information
and returns it as nicely formatted text. They are the building blocks of
plainline. The built-in providers, which are listed below, may be specified by
name (i.e. as strings). You can also pass your own functions as providers, as
long as they return strings (or nil).

* `mode`: current mode;
* `tabpage`: current tab page number;
* `branch`: current git branch, if in a git repository;
* `name_only`: just the filtered buffer name;
* `status`: buffer status. `*` for modified and `#` for read-only;
* `name`: `name_only` + `status` in the same provider;
* `diagnostics`: diagnostics, of course;
* `path_only`: just the filtered absolute filepath of the current buffer;
* `path`: `path_only` + `status` in the same provider;
* `macro`: name of macro being recorded, if any;
* `filetype`: filetype for the current buffer;
* `fileformat`: fileformat for the current buffer, if it's not unix;
* `percentage`: percentage of the buffer that has been scrolled down;
* `position`: position of the cursor within the buffer.

### Filtering

The `name_only` and `path_only` providers apply a series of filtering functions
to their respective outputs. These filtering functions are specified via the
`name_filters` key in the config. Similar to providers, built-in name filters
may be specified by name (i.e. as strings).

You may also pass your own functions as filters. Such functions should receive
and return a string. If they return an additional value and it is truthy (i.e.
neither `nil` nor `false`), this causes all following filters to not be run,
which may be useful in some contexts. It also means you have to take care with
functions such as `string.gsub`, which return multiple values; instead of doing
`return string.gsub(...)`, do `local res = string.gsub(...); return res`.

The built-in filters are listed below.

* `show_term_title`: replaces the buffer name of terminal buffers with their
  title (`vim.b.term_title`);
* `remove_protocol_prefix`: removes protocol style prefixes
  (`protocol://<actual-name>` -> `<actual-name>`);
* `abbrev_home_dir`: replaces the full path of the home directory with `~`;
* `show_help_topic`: shows just the filename (the "topic") for built-in vim help
  and manpages;
* `show_repo_name`: for `vim-fugitive` buffers, shows just the name of the
  repository instead of its full path;
* `clean`: applies all of the above, in that order.

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
  name_filters = { "clean" },
  winbar = nil, -- no winbar by default
}
```

## Screenshot

![screenshot](/static/screenshot.png?raw=true)

The above screenshot showcases the default configuration with both the
`sections` and `inactive_sections` keys of the `winbar`option set to `{ right =
{ "status", "name_only" }}` and `laststatus` set to 2 (the default).

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
