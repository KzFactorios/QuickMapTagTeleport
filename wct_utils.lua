local wutils = {}

function wutils.format_idx_from_position(position)
    return wutils.format_idx_from_position_x_y(position.x, position.y)
end

function wutils.format_idx_from_position_x_y(x, y)
    return string.format("%s.%s", tostring(math.floor(x)), tostring(math.floor(y)))
end

function wutils.find_element_by_key_and_value(tbl, key, value)
    for _, element in pairs(tbl) do
        if element[key] and element[key] == value then
            return element
        end
    end
    return nil
end

function wutils.find_element_by_position(tbl, key, pos)
    for _, element in pairs(tbl) do
        if element[key] and element[key].x == pos.x and element[key].y == pos.y then
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

wutils.tableFindByName = function(t, name)
    for i = 1, #t do
        if t[i].name == name then return t[i] end
    end
    return nil
end

wutils.addToSet = function(set, key)
    set[key] = true
end

wutils.removeFromSet = function(set, key)
    set[key] = nil
end

wutils.setContains = function(set, key)
    return set[key] ~= nil
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


return wutils
