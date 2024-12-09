--local add_tag_settings = require("settings/add_tag_settings")
--local map_tag_utils    = require("utils/map_tag_utils")
local wutils = require("wct_utils")

--local constants        = require("settings/constants")
--local table  = require("__flib__/table")
local cache  = require("lib/cache")
--local PREFIX           = constants.PREFIX

--local fav_bar_GUI      = require("scripts/gui/fav_bar_GUI")

--[[
Fave_Structure
_pos_idx
_surface_id
_tag
_qmtt
]]

local fave = {}

function fave.create_fave(pos, surface_id)
    local self = {}
    self._pos_idx = pos
    self._surface_id = surface_id
    return self
end

-- this might end up being the index
local _pos_idx = ""
local _surface_id = -1

function fave.get_qmtt(player, _fave)
    if player then
        local tag_pool = cache.get_extended_tags(player)
        return wutils.find_element_by_key_and_value(tag_pool, "idx", _fave._pos_idx)
    end
    return nil
end

function fave.get_chart_tag(player, _fave)
    if not player or not _fave or not _fave._pos_idx or _fave._pos_idx == "" then return nil end

    local tag_pool = cache.get_chart_tags_from_cache(player)
    local pos = wutils.decode_position_from_pos_idx(_fave._pos_idx)
    return wutils.find_element_by_position(tag_pool, "position", pos)
end

function fave.format_sprite_path_from_favorite(player, favorite, is_signal)
    local type = ""
    local name = ""
    local ct = fave.get_chart_tag(player, favorite)
    if ct and ct.icon and ct.icon ~= "" then
        type = ct.icon.type
        name = ct.icon.name
    end
    local sprite_path = wutils.format_sprite_path(type, name, is_signal)

    -- use a default sprite for fave tags without an icon
    if sprite_path == '' and next(favorite) then
        sprite_path = 'custom-map-view-tag'
    end

    return sprite_path
end

function fave.get_display_text(player, _fave)
    if player then
        local q = fave.get_qmtt(player, _fave)
        if q then
            return q.fave_displaytext or ""
        end
    end
    return ""
end

function fave.get_description(player, _fave)
    if player then
        local q = fave.get_qmtt(player, _fave)
        if q then
            return q.fave_description or ""
        end
    end
    return ""
end

function fave.get_icon(player, _fave)
    if player then
        local ct = fave.get_chart_tag(player, _fave)
        if ct then
            return ct.icon or ""
        end
    end
    return ""
end

function fave.convert_qmtt_to_fave(player_index, _qmtt)
    if wutils.find_index_of_value(_qmtt.faved_by_players, player_index) then
        local pos_idx = wutils.format_idx_from_position(_qmtt.position)
        local _fave = {
            _pos_idx = pos_idx,
            _surface_id = _qmtt.surface_id,
        }
        return _fave
    end
    return nil
end

function fave.convert_old_fave_to_new(old_fave)
    local _fave = {
        _pos_idx = old_fave._pos_idx,
        _surface_id = old_fave._qmtt.surface_id,
    }
    return _fave
end

--@params old_position, tag, player_index
function fave.refresh_data(event)
    if game then
        local player = game.players[event.player_index]
        if player then
            --find fave in collection
            local existing_f = wutils.find_element_by_key_and_value(
                storage.qmtt.GUI.fav_bar.players[event.player_index]
                .fave_places[player.surface_index], "_pos_idx",
                wutils.format_idx_from_position(event.old_position))

            if existing_f then
                existing_f._pos_idx = wutils.format_idx_from_position(event.tag.position)
            end
        end
    end
end

function fave.get_next_open_fave_places_index(player)
    if player then
        local fave_places = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index]
        for i = 1, #fave_places do
            local place = fave_places[i]
            if place == nil or (type(place) == "table" and next(place) == nil) or place._pos_idx == '' then
                return i
            end
        end
    end
    return -1
end

-- TODO make 10 a var/settings
function fave.get_fave_places_available_slots(player)
    if player then
        local fave_places = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index]
        local count = 0
        for i = 1, #fave_places do
            local place = fave_places[i]
            if place == nil or (type(place) == "table" and next(place) == nil) or place._pos_idx == '' then
                count = count + 1
            end
        end
        return 10 - count
    end
    return 0
end

return fave
