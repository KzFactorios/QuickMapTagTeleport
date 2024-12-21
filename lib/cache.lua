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
    if not storage.player_data then
        storage.qmtt.player_data = {}
    end
    if not storage.qmtt.registered_events then
        storage.qmtt.registered_events = {}
    end
    if not storage.qmtt.surfaces then
        storage.qmtt.surfaces = {}
    end
    if storage.qmtt.GUI == nil then
        storage.qmtt.GUI = {}
    end
    if storage.qmtt.GUI.AddTag == nil then
        storage.qmtt.GUI.AddTag = {}
    end
    if storage.qmtt.GUI.AddTag.players == nil then
        storage.qmtt.GUI.AddTag.players = {}
    end
    if storage.qmtt.GUI.fav_bar == nil then
        storage.qmtt.GUI.fav_bar = {}
    end
    if storage.qmtt.GUI.fav_bar.players == nil then
        storage.qmtt.GUI.fav_bar.players = {}
    end
    if storage.qmtt.GUI.edit_fave == nil then
        storage.qmtt.GUI.edit_fave = {}
    end
    if storage.qmtt.GUI.edit_fave.players == nil then
        storage.qmtt.GUI.edit_fave.players = {}
    end
end

function cache.init_player(player)
    local player_index = player.index
    if player then
        if not storage.qmtt.player_data[player_index] then
            storage.qmtt.player_data[player_index] = {}
            storage.qmtt.player_data[player_index].interface_scale = player.display_scale
            storage.qmtt.player_data[player_index].render_mode = player.render_mode
        end
        if not storage.qmtt.surfaces[player.surface_index] then
            storage.qmtt.surfaces[player.surface_index] = {}
        end
        if not storage.qmtt.surfaces[player.surface_index].chart_tags then
            storage.qmtt.surfaces[player.surface_index].chart_tags = {}
        end
        if not storage.qmtt.surfaces[player.surface_index].extended_tags then
            storage.qmtt.surfaces[player.surface_index].extended_tags = {}
        end

        if not storage.qmtt.GUI.AddTag.players[player_index] then
            storage.qmtt.GUI.AddTag.players[player_index] = {}
        end
        --[[if not storage.qmtt.GUI.AddTag.players[player_index].elements then
            storage.qmtt.GUI.AddTag.players[player_index].elements = {}
        end]]
        if not storage.qmtt.GUI.AddTag.players[player_index].position then
            storage.qmtt.GUI.AddTag.players[player_index].position = {}
        end

        if not storage.qmtt.GUI.fav_bar.players[player_index] then
            storage.qmtt.GUI.fav_bar.players[player_index] = {}
        end
        --[[if not storage.qmtt.GUI.fav_bar.players[player_index].elements then
            storage.qmtt.GUI.fav_bar.players[player_index].elements = {}
        end]]
        if not storage.qmtt.GUI.fav_bar.players[player_index].fave_places then
            storage.qmtt.GUI.fav_bar.players[player_index].fave_places = {}
        end
        if not storage.qmtt.GUI.fav_bar.players[player_index].fave_places[player.surface_index] then
            storage.qmtt.GUI.fav_bar.players[player_index].fave_places[player.surface_index] = {}
            -- TODO make this a setting
            for i = 1, 10 do
                storage.qmtt.GUI.fav_bar.players[player_index].fave_places[player.surface_index][i] = {}
            end
        end

        if not storage.qmtt.GUI.edit_fave.players[player_index] then
            storage.qmtt.GUI.edit_fave.players[player_index] = {}
        end
        --[[if not storage.qmtt.GUI.edit_fave.players[player_index].elements then
            storage.qmtt.GUI.edit_fave.players[player_index].elements = {}
        end]]
        if not storage.qmtt.GUI.edit_fave.players[player_index].selected_fave then
            storage.qmtt.GUI.edit_fave.players[player_index].selected_fave = '' -- matches pos_idx
        end
    end
end

function cache.reset_surface_chart_tags(player)
    if player then
        storage.qmtt.surfaces[player.surface_index].chart_tags = nil
    end
end

function cache.get_chart_tags_from_cache(player)
    if player then
        local surf = storage.qmtt.surfaces[player.surface_index]
        if not surf.chart_tags or #surf.chart_tags == 0 then
            surf.chart_tags = player.force.find_chart_tags(player.surface_index)
        end
        return surf.chart_tags
    end
    return nil
end

function cache.get_extended_tags(player)
    if player then
        return storage.qmtt.surfaces[player.surface_index].extended_tags
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

--- Returns the player's selected fave value == to _pos_idx
function cache.get_player_selected_fave_pos_idx(player)
    if player then
        return storage.qmtt.GUI.edit_fave.players[player.index].selected_fave
    end
    return ""
end

function cache.set_player_selected_fave(player, v)
    if player then
        storage.qmtt.GUI.edit_fave.players[player.index].selected_fave = v
    end
end

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

function cache.get_player_selected_favorite(player)
    if player then
        local pos = cache.get_player_selected_fave_pos_idx(player)
        return cache.get_player_favorite_by_pos_idx(player, pos)
    end
    return ""
end

function cache.get_player_favorites(player)
    if player then
        local places = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index] or {}
        -- TODO make this a setting
        -- ensure we have a full 10 places
        if #places < 10 then
            for i = #places + 1, 10 do
                places[i] = {
                    _pos_idx = '',
                    _surface_id = -1,
                }
            end
        end
        return places
    end
    return nil
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

function cache.on_player_created(event)
    cache.update_player_scale(event.player_index)
end

function cache.update_player_scale(player_index)
    local player = game.get_player(player_index)
    if player and storage.qmtt.player_data then
        storage.qmtt.player_data[player_index].interface_scale = player.display_scale
    end
end

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
            for _, et in pairs(o.extended_tags) do
                if wutils.tableContainsKey(et.faved_by_players, player_index) then
                    wutils.remove_element(et.faved_by_players, player_index)
                end
            end
        end 
    end
end

return cache
