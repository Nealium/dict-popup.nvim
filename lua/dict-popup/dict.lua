local dict_internal = {}

---@param bufnr? integer|nil
---@param win_id? integer|nil
local function DestroyDict(bufnr, win_id)
    if bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    if win_id ~= nil and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
    end
end

---@param word string
function dict_internal.Call(word)
    local output = vim.fn.systemlist({ "dict", word })

    -- Inject word in header
    if not string.find(output[1], "No") then
        output[1] = output[1] .. " for " .. '"' .. word .. '"'
    end

    -- Get eventual width
    local max_line_length = nil
    for _, line in ipairs(output) do
        if not string.find(line, "─") then
            -- ignore tables
            if max_line_length == nil then
                max_line_length = string.len(line)
            else
                local tmp = string.len(line)
                if tmp > max_line_length then
                    max_line_length = tmp
                end
            end
        end
    end
    -- NOTE: possibly add a "can't be wider than x"?
    local width = max_line_length

    -- Get height
    local height = 20
    if #output < 4 then
        height = 4
    elseif #output < 20 then
        height = #output
    end

    -- create buff
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- set buff contents
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, output)

    local win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = "cursor",
        title = "Dictionary",
        title_pos = "left",
        width = width,
        height = height,
        row = 0,
        col = 0,
        style = "minimal",
        border = "rounded",
    })

    vim.api.nvim_set_option_value("filetype", "dict", {
        buf = bufnr,
    })

    vim.keymap.set("n", "<Esc>", function()
        DestroyDict(bufnr, win_id)
    end, { buffer = bufnr, silent = true })
    vim.keymap.set("n", "q", function()
        DestroyDict(bufnr, win_id)
    end, { buffer = bufnr, silent = true })

    -- This is important..
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        buffer = bufnr,
        callback = function()
            DestroyDict(bufnr, win_id)
        end,
    })
end

return dict_internal
