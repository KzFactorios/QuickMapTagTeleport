--local wutils = require("wct_utils")
local table = require("__flib__.table")
local event_manager = require("lib/event_manager")

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
        if not storage.qmtt.GUI.AddTag.players[player_index].elements then
            storage.qmtt.GUI.AddTag.players[player_index].elements = {}
        end
        if not storage.qmtt.GUI.AddTag.players[player_index].position then
            storage.qmtt.GUI.AddTag.players[player_index].position = {}
        end

        if not storage.qmtt.GUI.fav_bar.players[player_index] then
            storage.qmtt.GUI.fav_bar.players[player_index] = {}
        end
        if not storage.qmtt.GUI.fav_bar.players[player_index].elements then
            storage.qmtt.GUI.fav_bar.players[player_index].elements = {}
        end
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
        if not storage.qmtt.GUI.edit_fave.players[player_index].elements then
            storage.qmtt.GUI.edit_fave.players[player_index].elements = {}
        end
        if not storage.qmtt.GUI.edit_fave.players[player_index].selected_fave then
            storage.qmtt.GUI.edit_fave.players[player_index].selected_fave = '' -- matches pos_idx
        end
    end
end

-- resets a base key to nil
local function reset_cache_key(cache_key)
    storage.qmtt[cache_key] = nil
end

-- adds a base key to the cache
local function set_cache_key(cache_key, value)
    storage.qmtt[cache_key] = value
end

local function get_cache_key(cache_key)
    return storage.qmtt[cache_key]
end

function get_surface_chart_tags(player_index)
    local player = game.players[player_index]
    return player.force.find_chart_tags(player.surface_index)
end

function refresh_surface_chart_tags(player_index)
    local player = game.players[player_index]
    storage.qmtt.surfaces[player.surface_index].chart_tags = get_surface_chart_tags(player_index)
end

function cache.get_chart_tags_from_cache(player_index)
    local player = game.players[player_index]
    if not storage.qmtt.surfaces[player.surface_index].chart_tags or
        #storage.qmtt.surfaces[player.surface_index].chart_tags == 0 then
        refresh_surface_chart_tags(player_index)
    end
    return storage.qmtt.surfaces[player.surface_index].chart_tags
end

function get_extended_tags_from_cache(player_index)
    local player = game.players[player_index]
    return storage.qmtt.surfaces[player.surface_index].extended_tags
end

function find_extended_tag(player_index, position)
    local tags = get_extended_tags_from_cache(player_index)
    for i = 1, #tags do
        if tags[i].position.x == position.x and tags[i].y == position.y then
            return tags[i]
        end
        return nil
    end
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

function tableContains(table, value)
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
    return tableContains(tag.faved_by_players, player_index)
end

function cache.get_player_selected_fave_pos_idx(player)
    return storage.qmtt.GUI.edit_fave.players[player.index].selected_fave
end

function cache.get_player_selected_fave_idx(player)
    local sel_fave = cache.get_player_selected_fave_pos_idx(player)
    if sel_fave and sel_fave ~= '' then
        local faves = cache.get_player_favorites(player)
        for i = 1, #faves do
            if faves[i]._pos_idx == sel_fave then
                return i
            end
        end
    end
    return 0
end

function cache.get_player_selected_favorite(player)
    local pos = cache.get_player_selected_fave_pos_idx(player)
    return cache.get_player_favorite_by_pos_idx(player, pos)
end


function cache.get_player_favorites(player)
    local places = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index] or {}
    -- TODO make this a setting
    if #places < 10 then
        for i = #places + 1, 10 do
            places[i] = {
                _pos_idx = ''                
            }
        end
    end
    return places
end

function cache.get_player_favorite_by_pos_idx(player, pos)
    local faves = cache.get_player_favorites(player)
    for _, v in pairs(faves) do
        if v._pos_idx == pos then
            return v
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

return cache
