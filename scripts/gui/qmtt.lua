--OK this is not a gui but it just seemed appropriate
-- to put here
local wutils = require("wct_utils")
local table  = require("__flib__.table")
local fave   = require("scripts/gui/fave")
local cache  = require("lib/cache")
--local add_tag_GUI = require("scripts.gui.add_tag_GUI")

local qmtt   = {}

--[[
idx = "",
position = {},
faved_by_players = {},
fave_displaytext = "",
fave_description = "",
]]
local next = next

qmtt.init_QMTT = function()
end

function qmtt.create_new_qmtt(pos_idx, surface_id, position, player_index, display_text, description)
    return {        
        idx = pos_idx,
        surface_id = surface_id,
        position = position,
        faved_by_players = { player_index },
        fave_displaytext = display_text,
        fave_description = description,
    }
end

function qmtt.reset_chart_tags(surface_id)
    storage.qmtt.surfaces[surface_id].chart_tags = nil
end

-- leaving here for completeness, but not sure
-- when to use it
function qmtt.reset_extended_tags(surface_id)
    storage.qmtt.surfaces[surface_id].extended_tags = nil
end

--TODO flesh out
function qmtt.modify_tag(surface_id, chart_tag, new_fave_display_text, new_description)
    -- Event handler might do most of the heavy lifting
    local changed = false
    local pos_idx = wutils.format_idx_from_position(chart_tag.position)
    local found_qmtt = qmtt.get_matching_qmtt_by_pos_idx(pos_idx)
    local _qmtt = {}
    qmtt.reset_chart_tags(surface_id) -- check to see if this is in the event handler in control.lua
end

--TODO flesh out
function qmtt.remove_tag(surface_id, chart_tag)
    --local pos_idx = wutils.format_idx_from_position(chart_tag.position)
    --local found_qmtt = qmtt.get_matching_qmtt_by_pos_idx(surface_id, pos_idx)

    -- remove other references to this tag

    -- remove the tag and it's extended tag

    -- TODO remove element and raise event. Event handler should take care of the rest
end

function qmtt.get_matching_chart_tag_by_pos_idx(surface_id, pos_idx)
    for _, v in pairs(storage.qmtt.surfaces[surface_id].chart_tags) do
        if v.idx == pos_idx then
            return v
        end
    end
    return nil
end

function qmtt.get_matching_qmtt_by_pos_idx(surface_id, pos_idx)
    for _, v in pairs(storage.qmtt.surfaces[surface_id].extended_tags) do
        if v.idx == pos_idx then
            return v
        end
    end
    return nil
end

function qmtt.on_configuration_changed(event)
    -- destroy any guis
    -- qmtt.qmtt_load()
end

function qmtt.on_pre_player_left_game(event)
    -- destroy any guis
    -- remove player from player indexed storage
end

-- handle events from the stock edit controlm
-- not sure if the tag_added will throw?
-- going to try to make it not happen
script.on_event(defines.events.on_chart_tag_added, function(event)
    --qmtt.reset_chart_tags()
    if event.player_index then
        --[[local editor = game.players[event.player_index].gui.screen["gui-tag-edit"]
        if editor then
            local qtag = qmtt.add_new_tag(event.tag)
        end]]
    end
end)

-- handle changes from the stock tag editor
-- see if we can throw this only when the gui-tag-edit control makes changes
--TODO does this throw on add tag changes?
script.on_event(defines.events.on_chart_tag_modified, function(event)
    if game and event.player_index then
        local player = game.players[event.player_index]
        local old_pos = wutils.format_idx_from_position(event.old_position)

        -- update matching chart_tag
        local stored_tag =
            wutils.find_element_by_position(cache.get_chart_tags_from_cache(player.index),
                "position",
                event.old_position)
        if stored_tag then
            stored_tag = table.deep_copy(event.tag)
        end

        -- update matching qmtt
        if not storage.qmtt or not storage.qmtt.ext_tags then
            qmtt.init_QMTT()
        end
        local stored_qmtt =
            wutils.find_element_by_key_and_value(storage.qmtt.ext_tags, "idx", old_pos)
        if stored_qmtt then
            stored_qmtt.idx = wutils.format_idx_from_position(event.tag.position)
            stored_qmtt.position = event.tag.position
        else
            stored_qmtt = {
                idx = wutils.format_idx_from_position(event.tag.position),
                position = event.tag.position,
                faved_by_players = {},
                fave_displaytext = "",
                fave_description = "",
            }
        end

        -- TODO update favorite?

        qmtt.reset_chart_tags(player.surface_id)
    end
end)

-- This gets fired from the stock GUI
script.on_event(defines.events.on_chart_tag_removed, function(event)
    if game and event.player_index then
        local player = game.players[event.player_index]
        local pos_idx = wutils.format_idx_from_position(event.tag.position)

        local tableau = storage.qmtt.surfaces[player.surface_id].chart_tags
        if tableau then
            local stored = wutils.find_element_by_key_and_value(tableau, "idx", pos_idx)
            if stored then
                wutils.remove_element(tableau, stored)
                stored.destroy()
            end
        end

        local extendo = storage.qmtt.surfaces[player.surface_id].extended_tags
        if extendo then
            local stored = wutils.find_element_by_key_and_value(extendo, "idx", pos_idx)
            if stored then
                wutils.remove_element(extendo, stored)
                stored.destroy()
            end
        end

        for _, v in storage.qmtt.GUI.edit_fave.players do
            if v.selected_fave == pos_idx then
                v.selected_fave = ''
            end
        end

        for _, v in storage.qmtt.GUI.fav_bar.players do
            for _, u in v.fave_places[player.surface_id] do
                if u.idx == pos_idx then
                    u = {
                        idx = '',
                        position = {},
                        faved_by_players = {},
                        fave_displaytext = '',
                        fave_description = '',
                    }
                end
            end
        end
        -- TODO do we need to worry aobut the elements of the fav bar?

        qmtt.reset_chart_tags(player.surface_id)
    end
end)
