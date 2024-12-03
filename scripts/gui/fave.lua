--local add_tag_settings = require("settings/add_tag_settings")
--local map_tag_utils    = require("utils/map_tag_utils")
local wutils = require("wct_utils")

--local constants        = require("settings/constants")
local table  = require("__flib__/table")
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

function fave.new()
    return fave.create_fave("", 0, {}, {})
end

function fave.create_fave(pos, surface_id, chart_tag, qmtt)
    local self = {}
    self._pos_idx = pos
    self._surface_id = surface_id
    self._chart_tag = table.deep_copy(chart_tag)
    self._qmtt = table.deep_copy(qmtt)
    return self
end

-- this might end up being the index
local _pos_idx = ""
function pos_idx()
    return _pos_idx
end

function set_pos_idx(v)
    _pos_idx = v
end

local _surface_id = 0
function surface_id()
    return _surface_id
end

function set_surface_id(id)
    _surface_id = id
end


local _qmtt = {}
function qmtt()
    return _qmtt
end

function set_qmtt(q)
    _qmtt = table.deep_copy(q)
end

function set_qmtt_by_position(position, player)
    q = cache.get_matching_qmtt_by_position(player.surface_index, position)
    if q and cache.is_player_favorite(q, player.index) then
        _qmtt = table.deepcopy(q)
    end
end

local _chart_tag = {}
function chart_tag()
    return _chart_tag
end

function set_chart_tag(t)
    _chart_tag = table.deep_copy(t)
end

function set_chart_tag_by_position(position, player)
    _chart_tag = table.deep_copy(wutils.find_element_by_position(player.force.find_chart_tags(player.surface),
        "position", position))
end

function display_text()
    return fave.qmtt().display_text
end

function description()
    return fave.qmtt().description
end

function icon()
    return fave.tag().icon
end

--@params old_position, tag, player_index
function fave.refresh_data(event)
    if game then
        local player = game.players[event.player_index]

        --find fave in collection
        local existing_f = wutils.find_element_by_key_and_value(
            storage.qmtt.GUI.fav_bar.players[event.player_index]
            .fave_places[player.surface_index], "_pos_idx",
            wutils.format_idx_from_position(event.old_position))

        if existing_f then
            existing_f._pos_idx = wutils.format_idx_from_position(event.tag.position)
            existing_f.set_chart_tag_by_position(event.tag.position, player)
            existing_f.set_qmtt_by_position(event.tag.position, player)
        end
    end
end

function fave.get_next_open_fave_places_index(player)
    local fave_places = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index]
    for i = 1, #fave_places do
        local place = fave_places[i]
        if place == nil or (type(place) == "table" and next(place) == nil) or place._pos_idx == '' then
          return i
        end
    end
    return -1
end

-- TODO make 10 a var/settings
function fave.get_fave_places_available_slots(player)
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


return fave
