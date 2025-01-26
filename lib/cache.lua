local table = require("__flib__.table")
local wutils = require("wct_utils")

cache = {}

function cache.reset()
    storage.qmtt = nil
end

function cache.init()
    if not storage.qmtt then
        storage.qmtt = {}
    end
    if not storage.qmtt.player_data then
        storage.qmtt.player_data = {}
    end
    if not storage.qmtt.surfaces then
        storage.qmtt.surfaces = {}
    end
    if not storage.qmtt.GUI then
        storage.qmtt.GUI = {}
    end
    if not storage.qmtt.GUI.AddTag then
        storage.qmtt.GUI.AddTag = {}
    end
    if not storage.qmtt.GUI.AddTag.players then
        storage.qmtt.GUI.AddTag.players = {}
    end
    if not storage.qmtt.GUI.fav_bar then
        storage.qmtt.GUI.fav_bar = {}
    end
    if not storage.qmtt.GUI.fav_bar.players then
        storage.qmtt.GUI.fav_bar.players = {}
    end
    if not storage.qmtt.GUI.edit_fave then
        storage.qmtt.GUI.edit_fave = {}
    end
    if not storage.qmtt.GUI.edit_fave.players then
        storage.qmtt.GUI.edit_fave.players = {}
    end
end

function cache.init_player(player)
    if not storage.qmtt then
        cache.init()
    end

    if not player then
        log("no player in init player")
        return
    end

    local player_index = player.index

    if not storage.qmtt.player_data[player_index] then
        storage.qmtt.player_data[player_index] = {}
        storage.qmtt.player_data[player_index].render_mode = player.render_mode
        storage.qmtt.player_data[player_index].show_fave_bar_buttons = true
    end
    if not storage.qmtt.surfaces[player.physical_surface_index] then
        storage.qmtt.surfaces[player.physical_surface_index] = {}
    end
    if not storage.qmtt.surfaces[player.physical_surface_index].chart_tags then
        storage.qmtt.surfaces[player.physical_surface_index].chart_tags = {}
    end
    if not storage.qmtt.surfaces[player.physical_surface_index].extended_tags then
        storage.qmtt.surfaces[player.physical_surface_index].extended_tags = {}
    end

    if not storage.qmtt.GUI.AddTag.players[player_index] then
        storage.qmtt.GUI.AddTag.players[player_index] = {}
    end

    if not storage.qmtt.GUI.fav_bar.players[player_index] then
        storage.qmtt.GUI.fav_bar.players[player_index] = {}
    end
    if not storage.qmtt.GUI.fav_bar.players[player_index].fave_places then
        storage.qmtt.GUI.fav_bar.players[player_index].fave_places = {}
    end
    if not storage.qmtt.GUI.fav_bar.players[player_index].fave_places[player.physical_surface_index] then
        storage.qmtt.GUI.fav_bar.players[player_index].fave_places[player.physical_surface_index] = {}
        -- TODO make this a setting
        for i = 1, 10 do
            storage.qmtt.GUI.fav_bar.players[player_index].fave_places[player.physical_surface_index][i] = {}
        end
    end

    if not storage.qmtt.GUI.edit_fave.players[player_index] then
        storage.qmtt.GUI.edit_fave.players[player_index] = {}
    end
    if not storage.qmtt.GUI.edit_fave.players[player_index].selected_fave then
        storage.qmtt.GUI.edit_fave.players[player_index].selected_fave = '' -- matches pos_idx
    end

    -- cleanup/transform legacy structures
    if storage.qmtt.player_data[player_index].registered_events then
        storage.qmtt.player_data[player_index].registered_events = nil
    end
    -- end legacy cleanup
end

--- Removes a player from any faved_by_player lists in the extended_tags
function cache.remove_player_from_qmtt_faved_by_players(player)
    local tags = cache.get_extended_tags(player)
    local player_index = player.index
    if tags ~= nil then
        for i = 1, #tags do
            wutils.remove_element(tags[i].faved_by_players, player_index)
        end
    end
end

--- Remove unnecessary player favorites data from storage per player
function cache.unfavorite_the_player_experience(player)
    if player then
        control.close_guis(player)

        storage.qmtt.player_data.show_fave_bar_buttons = false -- reset
        storage.qmtt.GUI.fav_bar.players[player.index].fave_places = nil
        cache.set_player_selected_fave(player, "")
        cache.remove_player_from_qmtt_faved_by_players(player)

        control.update_uis(player)
    end
end

--- Build/init the proper storage structure for player favorites
function cache.favorite_the_player_experience(player)
    if player then
        control.close_guis(player)

        storage.qmtt.player_data.show_fave_bar_buttons = true -- reset
        storage.qmtt.GUI.fav_bar.players[player.index].fave_places = {}
        storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.physical_surface_index] = {}
        -- TODO make 10 a setting
        for i = 1, 10 do
            storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.physical_surface_index][i] = {}
        end
        cache.set_player_selected_fave(player, "")
        cache.remove_player_from_qmtt_faved_by_players(player)

        control.update_uis(player)
    end
end

function cache.reset_surface_chart_tags(player)
    if player then
        storage.qmtt.surfaces[player.physical_surface_index].chart_tags = nil
    end
end

function cache.remove_invalid_tags(player, tag_list)
    local list = {}
    if tag_list ~= nil then
        for _, tag in pairs(tag_list) do
            if tag.valid then
                table.insert(list, tag)
            else
                --local pos = wutils.format_idx_from_position(tag.position)
                -- remove from player faves
                -- remove from selected fave
                -- remove from ext tags
                control.remove_tag_at_position(player, tag.position)
            end
        end
    end
    return list
end

function cache.get_chart_tags_from_cache(player)
    if player then
        local surf = storage.qmtt.surfaces[player.physical_surface_index]
        if surf == nil then
            cache.init_player(player)
            surf = storage.qmtt.surfaces[player.physical_surface_index]
        end
        if not surf.chart_tags or #surf.chart_tags == 0 then
            surf.chart_tags = cache.remove_invalid_tags(player,
                player.force.find_chart_tags(player.physical_surface_index))
        end
        return surf.chart_tags
    end
    return nil
end

--- Returns the qmtt/extended_tags for a player's physical_surface_index
function cache.get_extended_tags(player)
    if player then
        return storage.qmtt.surfaces[player.physical_surface_index].extended_tags
    end
    return nil
end

function cache.get_matching_qmtt_by_position(surface_index, position)
    local pos = string.format("%s.%s",
        tostring(math.floor(position.x)), tostring(math.floor(position.y)))
    local existing_q = nil

    for _, v in pairs(storage.qmtt.surfaces[surface_index].extended_tags) do
        if v.idx == pos then
            existing_q = table.deep_copy(v)
            break
        end
    end

    if not existing_q then
        existing_q = {
            idx = pos,
            position = position,
            faved_by_players = {},
            fave_displaytext = "",
            fave_description = "",
        }
    end

    return existing_q
end

function cache.tableContains(table, value)
    for i = 1, #table do
        if (table[i] == value) then
            return true
        end
    end
    return false
end

function cache.is_player_favorite(qmtt, player_index)
    for _, v in pairs(qmtt.faved_by_players) do
        if v.value == player_index then
            return true
        end
    end
    return false
end

function cache.extended_tag_is_player_favorite(tag, player_index)
    return cache.tableContains(tag.faved_by_players, player_index)
end

--- Returns the player's selected fave pos_idx
function cache.get_player_selected_fave_pos_idx(player)
    if not player then return "" end

    return storage.qmtt.GUI.edit_fave.players[player.index].selected_fave
end

--- To reset, set to ""
function cache.set_player_selected_fave(player, val)
    if not player then return end

    storage.qmtt.GUI.edit_fave.players[player.index].selected_fave = val
end

--- Returns the player's selected favorite index from the player's faves
function cache.get_player_selected_fave_idx(player)
    if player then
        local sel_fave = cache.get_player_selected_fave_pos_idx(player)
        if sel_fave and sel_fave ~= '' then
            local faves = cache.get_player_favorites(player)
            if faves then
                for i = 1, #faves do
                    if faves[i]._pos_idx == sel_fave then
                        return i
                    end
                end
            end
        end
    end
    return 0
end

--- Returns the player's selected favorite
function cache.get_player_selected_favorite(player)
    if not player then return "" end

    local pos = cache.get_player_selected_fave_pos_idx(player)
    return cache.get_player_favorite_by_pos_idx(player, pos)
end

local __DEBUG = true
--- Returns the player's favorites
--- @param player LuaPlayer
function cache.get_player_favorites(player)
    if not player then return nil end

    if not storage.qmtt then
        cache.init_player(player)
    end

    if __DEBUG then
        local logFormat = { comment = false, numformat = '%1.8g' }
        log(serpent.block(storage.qmtt, logFormat))
        log("surface index: " .. tostring(player.physical_surface_index))
    end

    --[[local places = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.physical_surface_index]
    -- TODO make 10 a setting
    if #places < 10 then
        for i = #places + 1, 10 do
            places[i] = {
                _pos_idx = '',
                _surface_id = -1,
            }
        end
        storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.physical_surface_index] = places
    end

    return places]]
    return storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.physical_surface_index]
end

--- Return the number of slots a player has remaining per surface
--- @param player LuaPlayer
function cache.get_available_fave_slots(player)
    local count = 0
    if player then
        local fave_places = cache.get_player_favorites(player)
        if fave_places then
            for i = 1, #fave_places do
                local place = fave_places[i]
                if place == nil or (type(place) == "table" and next(place) == nil) or place._pos_idx == '' then
                    count = count + 1
                end
            end
        end
    end
    -- TODO make 10 a var/settings
    return 10 - count
end

function cache.get_player_favorite_by_pos_idx(player, pos)
    if player then
        local faves = cache.get_player_favorites(player)
        if faves then
            for _, v in pairs(faves) do
                if v._pos_idx == pos then
                    return v
                end
            end
        end
    end
    return nil
end

--- Used when a player exits the mod
function cache.remove_player_data(player_index)
    local player = game.get_player(player_index)
    if player then
        -- make sure each gui is destroyed
        if storage.qmtt.player_data[player_index] then
            storage.qmtt.player_data[player_index] = nil
        end
        if storage.qmtt.GUI.fav_bar.players[player_index] then
            storage.qmtt.GUI.fav_bar.players[player_index] = nil
        end
        if storage.qmtt.GUI.AddTag.players[player_index] then
            storage.qmtt.GUI.AddTag.players[player_index] = nil
        end
        if storage.qmtt.GUI.edit_fave.players[player_index] then
            storage.qmtt.GUI.edit_fave.players[player_index] = nil
        end
    end

    for _, surface_idx in pairs(storage.qmtt.surfaces) do
        for _, o in pairs(surface_idx) do
            if o.extended_tags ~= nil then
                for _, et in pairs(o.extended_tags) do
                    wutils.remove_element(et.faved_by_players, player_index)
                end
            end
        end
    end
end

--- haven't incorporated this yet, but it may become a command should someone need it
--- TODO come up with a better name
function cache.fix_zero_tags_and_hotkey_locked(player)
    if player then
        local changed = false
        local all_tags = cache.get_chart_tags_from_cache(player)
        if all_tags ~= nil then
            for _, v in ipairs(all_tags) do
                if tostring(v.position.x) == "-0" then
                    v.position.x = 0
                    changed = true
                end
                if tostring(v.position.y) == "-0" then
                    v.position.x = 0
                    changed = true
                end
            end
        end
        if changed then
            cache.reset_surface_chart_tags(player)
        end

        -- do qmtts
        local all_qmtts = cache.get_extended_tags(player)
        if all_qmtts ~= nil then
            for _, v in ipairs(all_qmtts) do
                local q_change = false
                if tostring(v.position.x) == "-0" then
                    v.position.x = 0
                    q_change = true
                end
                if tostring(v.position.y) == "-0" then
                    v.position.x = 0
                    q_change = true
                end
                if q_change then
                    v.idx = wutils.format_idx_from_position(v.position)
                end
            end
        end

        -- loop through player faves and set hotkey_locked to nil
        local p_faves = cache.get_player_favorites(player)
        local p_change = false
        if p_faves ~= nil then
            for _, v in ipairs(p_faves) do
                if wutils.tableContainsKey(v, "hotkey_locked") then
                    v["hotkey_locked"] = nil
                end

                -- update idx if either part of pos is -0
                local f_change = false
                local _pos = wutils.decode_position_from_pos_idx(v._pos_idx)
                if _pos then
                    if tostring(_pos.x) == "-0" then
                        _pos.x = 0
                        f_change = true
                    end
                    if tostring(_pos.y) == "-0" then
                        _pos.x = 0
                        f_change = true
                    end
                    if f_change then
                        v._pos_idx = wutils.format_idx_from_position(_pos)
                        p_change = true
                    end
                end
            end
        end
        if p_change then
            cache.set_player_selected_fave(player, "")
        end
    end
end

return cache
