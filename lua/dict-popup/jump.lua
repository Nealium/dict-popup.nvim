---@class DictJump
---@field jumps? table<string>
---@field current? integer
local DictJump = {}
DictJump.__index = DictJump

--- Init
---@return DictJump
function DictJump:new()
    return setmetatable({
        jumps = {},
        current = 0,
    }, self)
end

--- Add word to jump list
---@note there's no diverging
---@param word string
function DictJump:add(word)
    if
        self.jumps[self.current] ~= nil
        and string.lower(self.jumps[self.current]) == string.lower(word)
    then
        -- don't add back-to-back same words
        return
    end
    if self.current ~= #self.jumps then -- not at the end, but adding new.
        -- splice list
        local tmp = {}

        ---@diagnostic disable-next-line: deprecated
        for _, v in ipairs({ (table.unpack or unpack)(self.jumps, 1, 2) }) do
            table.insert(tmp, v)
        end

        -- add newest word
        table.insert(tmp, word)
        -- overwrite
        self.jumps = tmp
        self.current = #self.jumps
    else
        table.insert(self.jumps, word)
        self.current = self.current + 1
    end
end

--- Get previous word in jump list
--@return string | nil
function DictJump:backwards()
    self.current = self.current - 1
    if self.current <= 0 then
        -- no more back jumps
        self.current = 1
    else
        return self.jumps[self.current]
    end
end

--- Get next word in jump list
--@return string | nil
function DictJump:forward()
    self.current = self.current + 1
    local jumps_len = #self.jumps
    if self.current > jumps_len then
        -- no more forward jumps
        self.current = jumps_len
    else
        return self.jumps[self.current]
    end
end

--- Clear jump list
function DictJump:clear()
    self.current = 0
    self.jumps = {}
end

return DictJump
