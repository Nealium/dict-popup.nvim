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
---@param buffer_mappings DictPopupBufferMappings
---@param stacked boolean
function DictBuffer:setup_autocmd_and_keymaps(buffer_mappings, stacked)
    for _, key in ipairs(buffer_mappings["close"]) do
        vim.keymap.set("n", key, function()
            require("dict-popup"):close(self.bufnr)
        end, { buffer = self.bufnr, silent = true })
    end

    -- next definition
    for _, key in ipairs(buffer_mappings["next_definition"]) do
        vim.keymap.set("n", key, function()
            local file_end = vim.fn.line("$")
            local counter = vim.fn.line(".") + 1
            local line_number = nil
            while counter < file_end do
                local substring = string.sub(vim.fn.getline(counter), 1, 1)
                if substring ~= " " and substring ~= "" then
                    line_number = counter
                    break
                end
                counter = counter + 1
            end
            if line_number then
                vim.cmd(":" .. line_number)
            end
        end, { buffer = self.bufnr, silent = true })
    end

    -- previous definition
    for _, key in ipairs(buffer_mappings["previous_definition"]) do
        vim.keymap.set("n", key, function()
            local counter = vim.fn.line(".") - 1
            local line_number = nil
            while counter > 0 do
                local substring = string.sub(vim.fn.getline(counter), 1, 1)
                if substring ~= " " and substring ~= "" then
                    line_number = counter
                    break
                end
                counter = counter - 1
            end
            if line_number then
                vim.cmd(":" .. line_number)
            end
        end, { buffer = self.bufnr, silent = true })
    end

    for _, key in ipairs(buffer_mappings["jump_back"]) do
        vim.keymap.set("n", key, function()
            require("dict-popup"):jump_backwards(self.bufnr)
        end, { buffer = self.bufnr, silent = true })
    end

    for _, key in ipairs(buffer_mappings["jump_forward"]) do
        vim.keymap.set("n", key, function()
            require("dict-popup"):jump_forward(self.bufnr)
        end, { buffer = self.bufnr, silent = true })
    end

    for _, key in ipairs(buffer_mappings["jump_definition"]) do
        vim.keymap.set("n", key, function()
            require("dict-popup"):cursor(vim.fn.expand("<cword>"))
        end, { buffer = self.bufnr, silent = true })
        vim.keymap.set("v", key, function()
            -- exit visual mode first
            vim.fn.feedkeys(
                vim.api.nvim_replace_termcodes("v", false, false, true),
                "x"
            )
            require("dict-popup"):cursor(vim.fn.expand("<cword>"))
        end, { buffer = self.bufnr, silent = true })
    end

    if stacked then
        -- if stacked try to override any "leaving" window events and focus back
        -- on the centered popup
        vim.keymap.set("n", "<C-w>", function()
            require("dict-popup"):close(self.bufnr)
        end, { buffer = self.bufnr, silent = true })
    end

    -- This is important.. else <C-W><C-W> is required to refocus
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        buffer = self.bufnr,
        callback = function()
            require("dict-popup"):close(self.bufnr)
        end,
    })
end

return DictBuffer
