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
    "https://github.com/Nealium/dict-popup.nvim",
    config = function()
        -- Normal mode, current word search 
        vim.keymap.set("n", "<leader>h", function() Dict(vim.fn.expand("<cword>")) end)
        -- Visual mode, current selection search 
        vim.keymap.set("v", "<leader>h", function()
            vim.cmd('noau normal! "vy"')
            Dict(vim.fn.getreg('v'))
        end)
    end
}
```

## Usage
ex command `:Dict {word}`, example `:Dict test`    

# TODO
- [ ] Center popup for `:Dict` command    
- [ ] Proper config & setup    
- [ ] Highlights in config / set per buffer    k
