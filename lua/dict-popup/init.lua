local Ui = require("dict-popup.ui")
local Utils = require("dict-popup.utils")
local Buffer = require("dict-popup.buffer")

---@class DictPopupConfig
---@field normal_mapping string
---@field visual_mapping string
---@field visual_register string
---@field stack boolean

---@class DictPopupPartialConfig
---@field normal_mapping? string
---@field visual_mapping? string
---@field visual_register? string
---@field stack? boolean

---@class DictInternal
---@field cursorUi DictUI
---@field centerUi DictUI
---@field options DictPopupConfig | nil
---@field stacked boolean
local DictInternal = {}
DictInternal.__index = DictInternal

--- Init internal class
---@return DictInternal
function DictInternal:new()
    return setmetatable({
        cursorUi = Ui:new(),
        centerUi = Ui:new(),
        options = nil,
        stacked = false,
    }, self)
end

--- Close currently shown popup
function DictInternal:close()
    local bufnr = vim.api.nvim_get_current_buf()
    if self.cursorUi.buf and self.cursorUi.buf:get_bufnr() == bufnr then
        self.cursorUi:close()
        if self.stacked then
            -- focus onto the centerUi
            self.stacked = false
            vim.api.nvim_set_current_win(self.centerUi.win_id)
        end
    elseif
        not self.stacked
        and self.centerUi.buf
        and self.centerUi.buf:get_bufnr() == bufnr
    then
        self.centerUi:close()
    end
end

--- Create or update center popup
---@param word string
function DictInternal:center(word)
    local contents = Utils.CallDict(word)

    local width = Utils.CalculateWidth(contents)
    local height = Utils.CalculateHeight(contents)
    local row = math.floor(((vim.o.lines - height) / 2) - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    if self.centerUi:exists() then
        self.centerUi:update(contents, row, col, width, height)
    else
        local buf = Buffer:new(contents)

        self.centerUi:create_window(buf, "editor", row, col, width, height)
    end
end

--- Create or update cursor popup, unless a center popup is shown then update it
---@param word string
function DictInternal:cursor(word)
    if not self.options.stack and self.centerUi.win_id ~= nil then
        self:center(word)
    else
        if self.centerUi.win_id ~= nil then
            -- flag this cursor is ontop of a center
            self.stacked = true
        end

        local contents = Utils.CallDict(word)

        local width = Utils.CalculateWidth(contents)
        local height = Utils.CalculateHeight(contents)
        if self.cursorUi:exists() then
            self.cursorUi:update(contents, 1, 0, width, height)
        else
            local buf = Buffer:new(contents)

            self.cursorUi:create_window(
                buf,
                "cursor",
                1,
                0,
                width,
                height,
                self.stacked
            )
        end
    end
end

--- Fetch config and defaults
---@param options DictPopupPartialConfig
---@return DictPopupConfig
local function with_default(options)
    return {
        normal_mapping = options.normal_mapping or "<Leader>h",
        visual_mapping = options.visual_mapping or "<Leader>h",
        visual_register = options.visual_register or "v",
        stack = options.stack or false,
    }
end

---@class DictInternal
local dict_popup = DictInternal:new()

---Plugin Setup
---@param options DictPopupPartialConfig
---@return DictInternal
function dict_popup.setup(self, options)
    if self ~= dict_popup then
        ---@diagnostic disable-next-line: cast-local-type
        options = self
        self = dict_popup
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    self.options = with_default(options)

    -- User function, called with argument
    vim.api.nvim_create_user_command("Dict", function(opts)
        local usage = "Usage: :Dict {word}"
        if not opts.args then
            print(usage)
            return
        end
        self:center(opts.args)
    end, { nargs = "*" })

    if self.options.normal_mapping ~= "nil" then
        -- Normal mode, current word search
        vim.keymap.set("n", self.options.normal_mapping, function()
            self:cursor(vim.fn.expand("<cword>"))
        end)
    end

    if self.options.visual_mapping ~= "nil" then
        -- Visual mode, current selection search
        vim.keymap.set("v", self.options.visual_mapping, function()
            vim.cmd('noau normal! "' .. self.options.visual_register .. 'y"')
            self:cursor(vim.fn.getreg(self.options.visual_register))
        end)
    end

    return self
end

return dict_popup
