local wutils = {}
local next = next

--- finds the next empty element to the left in the given table
--- returns nil if no empty element found
--- start from given index or last index if not provided
function wutils.find_next_empty_left_index(tbl, start)
    if type(tbl) ~= "table" then return nil end

    local idx = start or #tbl

    while idx > 0 do
        if next(tbl[idx]) == nil then
            return idx
        end
        idx = idx - 1
    end

    return nil
end

--- finds the next empty element to the right in the given table
--- returns nil if no empty element found
--- start from given index or 0 if not provided
function wutils.find_next_empty_right_index(tbl, start)
    if type(tbl) ~= "table" then return nil end

    local idx = start or 0
    local end_tbl = #tbl
    idx = idx + 1

    while idx <= end_tbl do
        if next(tbl[idx]) == nil then
            return idx
        end
        idx = idx + 1
    end

    return nil
end

--- Given a position structure { x: ###, y: ### } or { y: ###, x: ### }, return xxx.yyy
function wutils.format_idx_from_position(position)
    return string.format("%s.%s", tostring(math.floor(position.x)), tostring(math.floor(position.y)))
end

--- Given a pos_idx string xxx.yyy, return x: ###, y: ###
function wutils.format_idx_string_from_pos_idx(pos_idx)
    if not pos_idx or pos_idx == "" then return "" end
    local pos = wutils.decode_position_from_pos_idx(pos_idx)
    if not pos or pos == "" then return "" end
    return string.format("x: %s, y: %s", tostring(math.floor(pos.x)), tostring(math.floor(pos.y)))
end

function wutils.find_element_by_key_and_value(tbl, key, value)
    if type(tbl) ~= "table" then return nil end

    if tbl and #tbl > 0 then
        for _, element in pairs(tbl) do
            if element[key] and element[key] == value then
                return element
            end
        end
    end
    return nil
end

function wutils.decode_position_from_pos_idx(pos_idx)
    if not pos_idx then return nil end

    local position = {}
    local x, y = pos_idx:match("([^%.]+)%.([^%.]+)")
    position["x"] = x
    position["y"] = y
    return position
end

function wutils.find_index_of_value(tbl, value)
    if type(tbl) ~= "table" then return nil end

    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

-- TODO make this pretty!!! Learn more about Lua!
function wutils.find_element_by_position(tbl, key, pos)
    if type(tbl) ~= "table" then return nil end

    for _, element in pairs(tbl) do
        if element and element ~= {} and element.valid and element[key] ~= nil then
            if element[key].x ~= nil and element[key].y ~= nil and pos and
                (tostring(element[key]["x"]) == pos.x and tostring(element[key]["y"]) == pos.y) or
                (tostring(element[key].x) == pos.x and tostring(element[key].y) == pos.y) or
                (tostring(element[key].x) == tostring(pos.x) and tostring(element[key].y) == tostring(pos.y)) or
                (tonumber(element[key].x) == tonumber(pos.x) and tonumber(element[key].y) == tonumber(pos.y))
            then
                return element
            end
        end
    end
    return nil
end

---
function wutils.find_tag_element_idx_by_position(tbl, key, pos, check_validity)
    if key == nil or pos == nil then return -1 end
    if type(tbl) ~= "table" or pos ~= "table" then return -1 end

    for idx, element in pairs(tbl) do
        -- map tags need to pass is_valid test
        if not check_validity or (check_validity and element.valid) then
            if element ~= {} and element[key] ~= nil then
                if element[key].x ~= nil and element[key].y ~= nil and
                    (tostring(element[key]["x"]) == pos.x and tostring(element[key]["y"]) == pos.y) or
                    (tostring(element[key].x) == pos.x and tostring(element[key].y) == pos.y) or
                    (tostring(element[key].x) == tostring(pos.x) and tostring(element[key].y) == tostring(pos.y))
                then
                    return idx
                end
            end
        end
    end
    return -1
end

function wutils.tableContainsKey(t, key)
    if type(t) ~= "table" then return false end

    for k, v in pairs(t) do
        if k == key or v == key then
            return true
        end
    end
    return false
end

--- remove the element and shift the remaining elements down
function wutils.remove_element(tbl, key)
    if type(tbl) ~= "table" then
        error("Invalid arguments: expected (table)")
    end

    local index = nil
    for i, v in ipairs(tbl) do
        if v == key then
            index = i
            break
        end
    end
    -- If the element was found, shift elements to retain order
    if index then
        for i = index, #tbl - 1 do
            tbl[i] = tbl[i + 1]
        end
        tbl[#tbl] = nil -- Remove the last element (duplicate after shifting)
    end
end

function wutils.get_element_index(t, key, value)
    if type(t) ~= "table" then return -1 end

    for i = 1, #t do
        local match = t[i]
        if (match ~= nil or (type(match) == "table" and next(match) ~= nil)) and
            match[key] == value then
            return i
        end
    end
    return -1
end

function wutils.limit_text(inp, limit)
    if string.len(inp) < limit then return inp end

    return string.sub(inp, 1, limit) .. "..."
end

function wutils.format_sprite_path(type, name, is_signal)
    -- TODO what to do if type is signal?
    if not name then name = "" end
    if not type then type = "" end

    if type == "" and not is_signal then type = "item" end
    if type == "virtual" then
        type = "virtual-signal"
    end
    if type ~= "" then
        type = type .. "/"
    end

    local sprite_path = type .. name
    if not helpers.is_valid_sprite_path(sprite_path) then
        -- TODO better user messaging on error
        return ""
    end

    return sprite_path
end

function wutils.starts_with(haystack, needle)
    return haystack:sub(1, #needle) == needle
end

--[[
function string:contains(sub)
    return self:find(sub, 1, true) ~= nil
end

function string:startswith(start)
    return self:sub(1, #start) == start
end

function string:endswith(ending)
    return ending == "" or self:sub(-#ending) == ending
end

function string:replace(old, new)
    local s = self
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if (not start_idx) then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

function string:insert(pos, text)
    return self:sub(1, pos - 1) .. text .. self:sub(pos)
end
]]

-- http://lua-users.org/wiki/StringTrim

--function trim12(s)
function wutils.trim(s)
    local from = s:match "^%s*()"
    return from > #s and "" or s:match(".*%S", from)
end

-- http://lua-users.org/wiki/SplitJoin

-- Compatibility: Lua-5.1
function wutils.split(str, pat)
    local t = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

function wutils.split_path(str)
    return wutils.split(str, '[\\/]+')
end

return wutils
