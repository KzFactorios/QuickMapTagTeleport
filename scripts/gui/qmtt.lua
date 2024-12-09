--OK this is not a gui but it just seemed appropriate
-- to put here
local wutils    = require("wct_utils")
local table     = require("__flib__.table")
local fave      = require("scripts/gui/fave")
local cache     = require("lib/cache")
local constants = require("settings/constants")
--local control = require("control")
--local add_tag_GUI = require("scripts.gui.add_tag_GUI")

local qmtt      = {}

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
    local found_qmtt = qmtt.get_matching_qmtt_by_pos_idx(surface_id, pos_idx)
    local _qmtt = {}
    qmtt.reset_chart_tags(surface_id) -- check to see if this is in the event handler in control.lua
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
        if player then
            local old_pos = wutils.format_idx_from_position(event.old_position)

            -- update matching chart_tag
            local stored_tag =
                wutils.find_element_by_position(cache.get_chart_tags_from_cache(player),
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

            qmtt.reset_chart_tags(player.surface_index)
        end
    end
end)

---  Cleans up linked chart tags, extended tags, selected faves
function qmtt.handle_chart_tag_removal(event)
    if game and event.player_index then
        local player = game.players[event.player_index]
        if player then
            local pos_idx = wutils.format_idx_from_position(event.tag.position)

            qmtt.remove_chart_tag_at_position(player, event.tag.position)
            qmtt.remove_ext_tag_at_position(player, event.tag.position)
            local sel_fave_changed = qmtt.clear_matching_selected_fave(pos_idx)
            qmtt.clear_matching_fave_places(player, pos_idx)

            -- reset cache and update the fave bar
            qmtt.reset_chart_tags(player.surface_index)
            fav_bar_GUI.update_ui(player)

            if sel_fave_changed then
                script.raise_event(constants.events.SELECTED_FAVE_CHANGED, {
                    player_index = player.index,
                    fave_index = cache.get_player_selected_fave_idx(player),
                    selected_fave = cache.get_player_selected_favorite(player),
                })
            end
        end
    end
end

function qmtt.remove_chart_tag_at_position(player, pos)
    if player then
        local _chart_tags = storage.qmtt.surfaces[player.surface_index].chart_tags
        if _chart_tags and #_chart_tags > 0 then
            local idx = wutils.find_element_idx_by_position(_chart_tags, "position", pos)
            if idx and idx > 0 then
                wutils.remove_element_at_index(_chart_tags, idx)
            end
        end
    end
end

function qmtt.remove_ext_tag_at_position(player, pos)
    if player then
        local _ext_tags = storage.qmtt.surfaces[player.surface_index].extended_tags
        if _ext_tags and #_ext_tags > 0 then
            local idx = wutils.find_element_idx_by_position(_ext_tags, "position", pos)
            if idx and idx > 0 then
                wutils.remove_element_at_index(_ext_tags, idx)
            end
        end
    end
end

function qmtt.clear_matching_selected_fave(pos_idx)
    for _, v in pairs(storage.qmtt.GUI.edit_fave.players) do
        if v.selected_fave and v.selected_fave == pos_idx then
            v.selected_fave = ""
            return true
        end
    end
    return false
end

function qmtt.clear_matching_fave_places(player, pos_idx)
    if player then
        local surfs = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index]
        local fave_idx = wutils.get_element_index(surfs, "_pos_idx", pos_idx)
        if fave_idx > 0 and fave_idx <= #surfs then
            surfs[fave_idx] = {}
        end
    end
end

return qmtt
