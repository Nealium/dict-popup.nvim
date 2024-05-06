---@class DictUI
---@field win_id? number
---@field buf? DictBuffer
---@field win_type? string
local DictUI = {}
DictUI.__index = DictUI

--- Init
---@return DictUI
function DictUI:new()
    return setmetatable({
        win_id = nil,
        buf = nil,
        win_type = nil,
    }, self)
end

--- Return if window exists
---@return boolean
function DictUI:exists()
    return self.win_id ~= nil
end

--- Destroy buffer and window
function DictUI:close()
    if self.closing then
        return
    end

    self.closing = true

    if self.win_id ~= nil and vim.api.nvim_win_is_valid(self.win_id) then
        vim.api.nvim_win_close(self.win_id, true)
    end

    self.buf = nil
    self.win_id = nil
    self.win_type = nil
    self.closing = false
end

--- Create popup window
---@param buf DictBuffer
---@param position string
---@param row number
---@param col number
---@param width number
---@param height number
function DictUI:create_window(buf, position, row, col, width, height)
    local win_id = vim.api.nvim_open_win(buf:get_bufnr(), true, {
        relative = position,
        title = "Dictionary",
        title_pos = "left",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    -- TODO: add catch for failing to open window

    buf:setup_autocmd_and_keymaps()

    self.win_id = win_id
    self.buf = buf
    self.win_type = position
end

--- Update popup window
---@param row number
---@param col number
---@param width number
---@param height number
function DictUI:update(contents, row, col, width, height)
    local conf = vim.api.nvim_win_get_config(self.win_id)

    if conf.relative ~= "win" then
        conf.row[false] = row
        conf.col[false] = col
    end
    conf.width = width
    conf.height = height

    vim.api.nvim_win_set_config(self.win_id, conf)
    self.buf:set_contents(contents)
    -- move cursor back to the top left
    vim.api.nvim_win_set_cursor(self.win_id, { 1, 0 })
end

return DictUI
