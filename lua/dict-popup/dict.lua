local dict_internal = {}

--- Destroy buffer and window
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

--- SysCall `dict` with given word
---@param word string
---@return table
local function CallDict(word)
    local output = vim.fn.systemlist({ "dict", word })

    -- Inject word in header
    if not string.find(output[1], "No") then
        output[1] = output[1] .. " for " .. '"' .. word .. '"'
    end

    return output
end

--- Calculate width by longest line
---@param contents table
---@return number
local function CalculateWidth(contents)
    local max_line_length = nil
    for _, line in ipairs(contents) do
        if not string.find(line, "─") then -- ignore tables
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
    return max_line_length or 20
end

--- Calculate height by table length
---@param contents table
---@return number
local function CalculateHeight(contents)
    if #contents < 4 then
        return 4
    elseif #contents < 20 then
        return #contents
    end
    return 20
end

--- Create buffer and set filetype
---@return number
local function SetupBuffer()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "dict", {
        buf = bufnr,
    })
    return bufnr
end

--- Create popup window
---@param bufnr number
---@param position string
---@param row number
---@param col number
---@param width number
---@param height number
---@return number
local function ShowPopup(bufnr, position, row, col, width, height)
    return vim.api.nvim_open_win(bufnr, true, {
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
end

--- Setup autocmds and keymmaps
---@param bufnr number
---@param win_id number
local function SetupCmdsAndKeymaps(bufnr, win_id)
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

--- Call `dict` & place popup at cursor
---@param word string
function dict_internal.Cursor(word)
    local contents = CallDict(word)
    local bufnr = SetupBuffer()

    -- set buff contents
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)

    local win_id = ShowPopup(
        bufnr,
        "cursor",
        1,
        0,
        CalculateWidth(contents),
        CalculateHeight(contents)
    )

    SetupCmdsAndKeymaps(bufnr, win_id)
end

--- Call `dict` & place popup at the center
---@param word string
function dict_internal.Center(word)
    local contents = CallDict(word)
    local bufnr = SetupBuffer()

    -- set buff contents
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)

    local width = CalculateWidth(contents)
    local height = CalculateHeight(contents)

    local win_id = ShowPopup(
        bufnr,
        "editor",
        math.floor(((vim.o.lines - height) / 2) - 1),
        math.floor((vim.o.columns - width) / 2),
        width,
        height
    )

    SetupCmdsAndKeymaps(bufnr, win_id)
end

return dict_internal
