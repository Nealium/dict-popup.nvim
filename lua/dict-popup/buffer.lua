---@class DictBuffer
---@field bufnr? number
local DictBuffer = {}
DictBuffer.__index = DictBuffer

--- Init new buffer
---@param contents table<string>
---@return DictBuffer
function DictBuffer:new(contents)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "dict", {
        buf = bufnr,
    })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)

    return setmetatable({
        bufnr = bufnr,
    }, self)
end

--- Return buffer number
---@return number | nil
function DictBuffer:get_bufnr()
    return self.bufnr
end

--- Close buffer
function DictBuffer:close()
    if self.closing then
        return
    end

    self.closing = true

    if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end

    self.buf = nil
    self.closing = false
end

--- Set buffer contents
---@param contents table<string>
function DictBuffer:set_contents(contents)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, true, contents)
end

--- Set buffer cmds and maps
function DictBuffer:setup_autocmd_and_keymaps()
    vim.keymap.set("n", "<Esc>", function()
        require("dict-popup"):close()
    end, { buffer = self.bufnr, silent = true })
    vim.keymap.set("n", "q", function()
        require("dict-popup"):close()
    end, { buffer = self.bufnr, silent = true })

    -- This is important..
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        buffer = self.bufnr,
        callback = function()
            require("dict-popup"):close()
        end,
    })
end

return DictBuffer
