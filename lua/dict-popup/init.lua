local dict = require("dict-popup.dict")

local dict_popup = {}

---@class DictPopupConfig
---@field normal_mapping string
---@field visual_mapping string
---@field visual_register string

---@class DictPopupPartialConfig
---@field normal_mapping? string
---@field visual_mapping? string
---@field visual_register? string

--- Fetch config and defaults
---@param options DictPopupPartialConfig
---@return DictPopupConfig
local function with_default(options)
    return {
        normal_mapping = options.normal_mapping or "<Leader>h",
        visual_mapping = options.visual_mapping or "<Leader>h",
        visual_register = options.visual_register or "v",
    }
end

--- Plugin Setup
---@param options DictPopupPartialConfig
function dict_popup.setup(options)
    dict_popup.options = with_default(options)

    -- User function, called with argument
    vim.api.nvim_create_user_command("Dict", function(opts)
        local usage = "Usage: :Dict {word}"
        if not opts.args then
            print(usage)
            return
        end
        dict.Center(opts.args)
    end, { nargs = "*" })

    if dict_popup.options.normal_mapping ~= "nil" then
        -- Normal mode, current word search
        vim.keymap.set("n", dict_popup.options.normal_mapping, function()
            dict.Cursor(vim.fn.expand("<cword>"))
        end)
    end

    if dict_popup.options.visual_mapping ~= "nil" then
        -- Visual mode, current selection search
        vim.keymap.set("v", dict_popup.options.visual_mapping, function()
            vim.cmd(
                'noau normal! "' .. dict_popup.options.visual_register .. 'y"'
            )
            dict.Cursor(vim.fn.getreg(dict_popup.options.visual_register))
        end)
    end
end

return dict_popup

