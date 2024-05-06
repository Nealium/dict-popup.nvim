local M = {}

--- SysCall `dict` with given word
---@param word string
---@return table<string>
function M.CallDict(word)
    local output = vim.fn.systemlist({ "dict", word })

    -- Inject word in header
    if not string.find(output[1], "No") then
        output[1] = output[1] .. " for " .. '"' .. word .. '"'
    end

    return output
end

--- Calculate width by longest line
---@param contents table<string>
---@return number
function M.CalculateWidth(contents)
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
---@param contents table<string>
---@return number
function M.CalculateHeight(contents)
    if #contents < 4 then
        return 4
    elseif #contents < 20 then
        return #contents
    end
    return 20
end

return M
