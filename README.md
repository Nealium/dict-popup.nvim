# dict-popup.nvim

A simple plugin for the Linux command `dict` which shows the definitions in a popup.    
Reworked for Neovim ([vim9script version](https://github.com/Nealium/dict-popup.vim))

![Screenshot](screenshot.png)

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
**Note:** Syntax only tested with gcide *(default)*, jargon and vera

### Plugin
* https://github.com/folke/lazy.nvim
```lua
{
    "Nealium/dict-popup.nvim",
    config = function()
        require("dict-popup").setup({
            normal_mapping = "<Leader>h", -- Search current word
            visual_mapping = "<Leader>h", -- Search current selection
            visual_register = "v", -- temp register used in visual
        })
    end,
}
```
**Note:** setting either mapping as `"nil"` (string important) will disable the
mapping

## Usage
ex command `:Dict {word}`, example `:Dict test`    

# TODO
- [X] Proper config & setup    
- [ ] Center popup for `:Dict` command    
- [ ] Highlights in config / set per buffer    
