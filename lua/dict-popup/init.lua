local Ui = require("dict-popup.ui")
local Utils = require("dict-popup.utils")
local Buffer = require("dict-popup.buffer")

---@class DictPopupBufferMappings
---@field close table<string>
---@field next_definition table<string>
---@field previous_definition table<string>
---@field jump_back table<string>
---@field jump_forward table<string>
---@field jump_definition table<string>

---@class DictPopupConfig
---@field normal_mapping string
---@field visual_mapping string
---@field visual_register string
---@field buffer_mappings DictPopupBufferMappings
---@field stack boolean

---@class DictPopupPartialConfig
---@field normal_mapping? string
---@field visual_mapping? string
---@field visual_register? string
---@field buffer_mappings? table
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
---@param bufnr? integer
function DictInternal:close(bufnr)
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
---@param jump? boolean
function DictInternal:center(word, jump)
    local contents = Utils.CallDict(word)
    if #contents == 0 then
        return
    end

    local width = Utils.CalculateWidth(contents)
    local height = Utils.CalculateHeight(contents)
    local row = math.floor(((vim.o.lines - height) / 2) - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    if self.centerUi:exists() then
        self.centerUi:update(contents, row, col, width, height)
    else
        local buf = Buffer:new(contents)

        self.centerUi:create_window(
            buf,
            "editor",
            row,
            col,
            width,
            height,
            self.options.buffer_mappings
        )
    end
    if not jump or false then
        self.centerUi.jump:add(word)
    end
end

--- Create or update cursor popup, unless a center popup is shown then update it
---@param word string
---@param jump? boolean
function DictInternal:cursor(word, jump)
    if not self.options.stack and self.centerUi.win_id ~= nil then
        self:center(word)
    else
        if self.centerUi:exists() then
            -- flag this cursor is ontop of a center
            self.stacked = true
        end

        local contents = Utils.CallDict(word)
        if #contents == 0 then
            return
        end

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
                self.options.buffer_mappings,
                self.stacked
            )
        end
        if not jump or false then
            self.cursorUi.jump:add(word)
        end
    end
end

--- Jump forward in jump list
---@param bufnr integer
function DictInternal:jump_forward(bufnr)
    if self.centerUi:exists() and self.centerUi.buf:get_bufnr() == bufnr then
        local word = self.centerUi.jump:forward()
        if word ~= nil then
            self:center(word, true)
        end
    elseif
        self.cursorUi:exists() and self.cursorUi.buf:get_bufnr() == bufnr
    then
        local word = self.cursorUi.jump:forward()
        if word ~= nil then
            self:cursor(word, true)
        end
    end
end

--- Jump backwards in jump list
---@param bufnr integer
function DictInternal:jump_backwards(bufnr)
    if self.centerUi:exists() and self.centerUi.buf:get_bufnr() == bufnr then
        local word = self.centerUi.jump:backwards()
        if word ~= nil then
            self:center(word, true)
        end
    elseif
        self.cursorUi:exists() and self.cursorUi.buf:get_bufnr() == bufnr
    then
        local word = self.cursorUi.jump:backwards()
        if word ~= nil then
            self:cursor(word, true)
        end
    end
end

--- Fetch config and defaults
---@param options DictPopupPartialConfig
---@return DictPopupConfig
local function with_default(options)
    local buffer_mappings = {
        close = { "<Esc>", "q" },
        next_definition = { "}" },
        previous_definition = { "{" },
        jump_back = { "<C-o>" },
        jump_forward = { "<C-i>", "<Tab>" },
        jump_definition = { "<C-]>" },
    }
    if options.buffer_mappings then
        buffer_mappings = {
            close = options.buffer_mappings["close"]
                or buffer_mappings["close"],
            next_definition = options.buffer_mappings["next_definition"]
                or buffer_mappings["next_definition"],
            previous_definition = options.buffer_mappings["previous_definition"]
                or buffer_mappings["previous_definition"],
            jump_back = options.buffer_mappings["jump_back"]
                or buffer_mappings["jump_back"],
            jump_forward = options.buffer_mappings["jump_forward"]
                or buffer_mappings["jump_forward"],
            jump_definition = options.buffer_mappings["jump_definition"]
                or buffer_mappings["jump_definition"],
        }
    end
    return {
        normal_mapping = options.normal_mapping,
        visual_mapping = options.visual_mapping,
        visual_register = options.visual_register or "*",
        stack = options.stack or false,
        buffer_mappings = buffer_mappings,
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
        if opts.args == "" then
            vim.notify("Usage: :Dict {word}", vim.log.levels.ERROR)
            return
        end
        self:center(opts.args)
    end, { nargs = "*" })

    if self.options.normal_mapping ~= nil then
        -- Normal mode, current word search
        vim.keymap.set("n", self.options.normal_mapping, function()
            self:cursor(vim.fn.expand("<cword>"))
        end)
    end

    if self.options.visual_mapping ~= nil then
        -- Visual mode, current selection search
        vim.keymap.set("v", self.options.visual_mapping, function()
            vim.cmd('noau normal! "' .. self.options.visual_register .. 'y"')
            self:cursor(vim.fn.getreg(self.options.visual_register))
        end)
    end

    return self
end

return dict_popup
