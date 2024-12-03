local wutils = {}
local next = next

function wutils.format_idx_from_position(position)
    return wutils.format_idx_from_position_x_y(position.x, position.y)
end

function wutils.format_idx_from_position_x_y(x, y)
    return string.format("%s.%s", tostring(math.floor(x)), tostring(math.floor(y)))
end

function wutils.find_chart_tag_by_pos_idx(tbl, pos_idx)
    if tbl and #tbl > 0 then
        for _, element in pairs(tbl) do
            if wutils.format_idx_from_position(element.position) == pos_idx then
                return element
            end
        end
    end
    return nil
end

function wutils.find_element_by_key_and_value(tbl, key, value)
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
    local position = {}
    local x, y = pos_idx:match("([^%.]+)%.([^%.]+)")
    position["x"] = x
    position["y"] = y
    return position
end

function splitPosOnDot(input)
    local x, y = input:match("([^%.]+)%.([^%.]+)")
    return x, y
end

function wutils.find_index_of_value(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

-- TODO make this pretty!!! Learn more about Lua!
function wutils.find_element_by_position(tbl, key, pos)
    for _, element in pairs(tbl) do
        if element[key] and
            (tostring(element[key]["x"]) == pos.x and tostring(element[key]["y"]) == pos.y) or
            (tostring(element[key].x) == pos.x and tostring(element[key].y) == pos.y) or
            (tostring(element[key].x) == tostring(pos.x) and tostring(element[key].y) == tostring(pos.y))
        then
            return element
        end
    end
    return nil
end

function wutils.find_element_by_key(tbl, key)
    for _, element in pairs(tbl) do
        if element.key == key then
            return element
        end
    end
    return nil
end

wutils.tableContainsKey = function(t, key)
    for k, v in pairs(t) do
        if k == key or v == key then
            return true
        end
    end
    return false
end

function wutils.remove_element(tbl, key)
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

-- Careful how you use this one
-- It was created for a use-case where most of the text
-- is matched from the start
wutils.tableContainsLikeKey = function(t, key)
    -- Validate inputs
    if type(t) ~= "table" or type(key) ~= "string" then
        error("Invalid arguments: expected (table, string)")
    end

    for k, v in pairs(t) do
        -- Convert value to string for comparison
        if k then
            local keyStr = tostring(k)
            if string.find(keyStr, key, 1, true) then -- Use `plain` mode for literal substring search
                return true
            end
        end
        local valueStr = tostring(v)
        if string.find(valueStr, key, 1, true) then -- Use `plain` mode for literal substring search
            return true
        end
    end
    return false
end

function wutils.get_elements_starts_with_key(t, key)
    -- Validate inputs
    if type(t) ~= "table" or type(key) ~= "string" then
        error("Invalid arguments: expected (table, string)")
    end

    local results = {}
    for k, v in pairs(t) do
        -- Convert value to string for comparison
        if k then
            local keyStr = tostring(k)
            if keyStr:sub(1, #key) == key then -- Use `plain` mode for literal substring search
                table.insert(results, v)
            end
        end
    end
    return results
end

wutils.tableFindByName = function(t, name)
    for i = 1, #t do
        if t[i].name == name then return t[i] end
    end
    return nil
end

function hex_to_rgb(hex)
    -- Remove # if present
    hex = hex:gsub("#", "")

    -- Convert to rgb values (0-1 range)
    local r = tonumber("0x" .. hex:sub(1, 2)) / 255
    local g = tonumber("0x" .. hex:sub(3, 4)) / 255
    local b = tonumber("0x" .. hex:sub(5, 6)) / 255

    return { r = r, g = g, b = b }
end

-- helper function to get gui elements
-- ex: local gui_element = find_gui_element_by_name(player.gui.screen, "gui-tag-edit")
wutils.find_gui_element_by_name = function(parent, name)
    for k, child in ipairs(parent.children) do
        if child.name == name then
            return child
        elseif #child.children > 0 then
            local result = wutils.find_gui_element_by_name(child, name)
            if result then
                return result
            end
        end
    end
    return nil
end

function wutils.print_view_data(player)
    if player then
        if player.render_mode == defines.render_mode.chart then
            player.print(string.format("You are now in chart view! %d", player.render_mode))
        elseif player.render_mode == defines.render_mode.chart_zoomed_in then
            player.print(string.format("You are now in zoomed-in chart view! %d", player.render_mode))
        else
            player.print(string.format("You are now in normal view! %d", player.render_mode))
        end
    end
end

function wutils.find_element_in_table(t, key, value)
    for _, v in t do
        if type(v) == 'table' and v[key] == value then
            return v
        end
    end
    return nil
end

function wutils.get_element_index(t, key, value)
    for i = 1, #t do
        local match = t[i]
        if (match ~= nil or (type(match) == "table" and next(match) ~= nil)) and
            match[key] == value then
            return i
        end
    end
    return -1
end

function wutils.format_sprite_path(type, name)
    if type == "virtual" then
        type = "virtual-signal"
    end
    local sprite_path = type .. "/" .. name
    if not helpers.is_valid_sprite_path(sprite_path) then
        -- TODO better user messaging on error
        sprite_path = ""
    end
    return sprite_path
end

return wutils


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