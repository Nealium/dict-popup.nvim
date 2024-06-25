<div align="center">

# dict-popup.nvim

[![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)

</div>

A simple plugin for the Linux command `dict` which shows the definitions in a popup. ([vim9script version](https://github.com/Nealium/dict-popup.vim))

![Screenshot](screenshot.png)

### Features
* center and cursor popups
* ex command: `:Dict {word}` (center)
* normal mode: lookup current word (cursor)
* visual mode: lookup selection (cursor)
* `dict` filetype and accompanying syntax
* in-buffer pseudo jumplist

## Install

### Command
```bash
sudo apt install dictd
# or
sudo dnf install dictd
```
```bash
# extra dictionaries
sudo apt install dict-jargon dict-vera
```
**Note:** Syntax tested with gcide *(default)*, jargon and vera

### Plugin
* https://github.com/folke/lazy.nvim
```lua
{
    "Nealium/dict-popup.nvim",
    opts = {
        normal_mapping = nil, -- disable
        visual_mapping = "<Leader>h",
        visual_reg = "*",
        stack = false,
    },
}
```
**Notes:**
* Setting `normal_mapping` or `visual_mapping` to `nil` (*actual* nil, not a
  string), or leaving the keys out all together, will disable the mapping.
* Setting `stack` to `true` will open up a cursor popup on top of a center popup
  instead of the default behavior which is to overwrite the center popup's
  contents. This *may* lead you with the center popup open and unfocused, to
  refocus do `<C-w><C-w>`- in some situations this won't work and you are on
  your own!

## Dict buffer keymaps
* `<ESC>` and `q` close popup
* `}` next definition
* `{` previous definition
* `<C-O>` next in search jumplist
* `<C-I>` and `<TAB>` previous in search jumplist
* `<C-]>` search current word
* if stacked, `<C-W>` close popup

Keymaps can be changed through the opts key `buffer_mappings`:
```lua
{
    "Nealium/dict-popup.nvim",
    opts = {
        normal_mapping = "<Leader>h",
        visual_mapping = "<Leader>h",
        visual_reg = "*",
        stack = false,
        buffer_mappings = { -- defaults
            close = { "<Esc>", "q" },
            next_definition = { "}" },
            previous_definition = { "{" },
            jump_back = { "<C-o>" },
            jump_forward = { "<C-i>", "<Tab>" },
            jump_definition = { "<C-]>" },
        },
    },
}
```

# TODO
- [X] Proper config & setup    
- [X] Center popup for `:Dict` command    
- [X] Ability to call `dict.Cursor` inside of a dict popup and have it overwrite
      the current contents    
- [ ] Colors set in config    
