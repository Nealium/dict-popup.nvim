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
    opts = {
        normal_mapping = "<Leader>h",
        visual_mapping = "<Leader>h",
        visual_reg = "v",
    },
}
```
**Note:** setting either mapping as `"nil"` (string important) will disable the
mapping

## Usage
ex command `:Dict {word}`, example `:Dict test`    

# TODO
- [X] Proper config & setup    
- [X] Center popup for `:Dict` command    
- [ ] Ability to call `dict.Cursor` inside of a dict popup and have it overwrite
      the current contents    
- [ ] Colors set in config    
