--OK this is not a gui but it just seemed appropriate
-- to put here
local wutils = require("wct_utils")
local table = require("__flib__.table")
--local add_tag_GUI = require("scripts.gui.add_tag_GUI")

local qmtt = {}

--[[
idx = "",
position = {},
favorite_list = {},
fave_displaytext = "",
fave_description = "",
]]
local next = next

qmtt.init_QMTT = function()
    -- storage.qmtt = nil
    if storage.qmtt == nil then
        storage.qmtt = {}
    end
    if storage.qmtt.tags == nil then
        storage.qmtt.tags = {}
    end

    -- can we access chart tags yet?
end

-- rebind any event handlers
function qmtt.qmtt_load()

end

local map_tags = {}

function qmtt.reset_chart_tags()
    map_tags = nil
end

-- refreshes the map tags and returns a fresh collection
function qmtt.get_chart_tags(player)
    if map_tags == nil or #map_tags == 0 then
        map_tags = player.force.find_chart_tags(player.surface)
    end

    return map_tags
end

function qmtt.is_player_favorite(q, player)
    return wutils.tableContainsKey(q.favorite_list, player)
end

--TODO flesh out
function qmtt.modify_tag(chart_tag, new_favow_display_text, new_description)
    local changed = false
    local pos_idx = wutils.format_idx_from_position(chart_tag.position)
    local found_qmtt = qmtt.get_matching_qmtt_by_pos_idx(pos_idx)
    local _qmtt = {}
end

--TODO flesh out
function qmtt.remove_tag(chart_tag)
    local pos_idx = wutils.format_idx_from_position(chart_tag.position)
    local found_qmtt = qmtt.get_matching_qmtt_by_pos_idx(pos_idx)
end

function qmtt.get_matching_qmtt_by_position(position, player)
    if not storage.qmtt or not storage.qmtt.tags then
        qmtt.init_QMTT()
    end

    local existing_q = wutils.find_element_by_key_and_value(
        storage.qmtt.tags, "idx", wutils.format_idx_from_position(position))

    if not existing_q then
        existing_q = {
            idx = wutils.format_idx_from_position(position),
            position = position,
            favorite_list = {},
            fave_displaytext = "",
            fave_description = "",
        }
    end

    return existing_q
end

function qmtt.get_matching_qmtt_by_pos_idx(posIdx)
    return wutils.find_element_by_key(storage.qmtt.tags, "posIdx")
end

function qmtt.on_player_created(event)
    -- destroy any guis
    -- qmtt.qmtt_load()
end

function qmtt.on_configuration_changed(event)
    -- destroy any guis
    -- qmtt.qmtt_load()
end

function qmtt.on_pre_player_left_game(event)
    -- destroy any guis
    -- remove player from player indexed storage
    storage.GUI.qmtt.players[event.player_index] = nil
end

-- handle events from the stock edit controlm
-- not sure if the tag_added will throw?
-- going to try to make it not happen
script.on_event(defines.events.on_chart_tag_added, function(event)
    qmtt.reset_chart_tags()
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

        -- update matching tag
        local stored_tag = wutils.find_element_by_key_and_value(qmtt.get_chart_tags(player), "idx", old_pos)
        if stored_tag then
            stored_tag = table.deep_copy(event.tag)
        end

        -- update matching qmtt
        if not storage.qmtt or not storage.qmtt.tags then
            qmtt.init_QMTT()
        end
        local stored_qmtt = wutils.find_element_by_key_and_value(storage.qmtt.tags, "idx", old_pos)
        if stored_qmtt then
            stored_qmtt.idx = wutils.format_idx_from_position(event.tag.position)
            stored_qmtt.position = event.tag.position
        else
            stored_qmtt = {
                idx = wutils.format_idx_from_position(event.tag.position),
                position = event.tag.position,
                favorite_list = {},
                fave_displaytext = "",
                fave_description = "",
            }
        end
    end
end)

script.on_event(defines.events.on_chart_tag_removed, function(event)
    if game and event.player_index then
        local player = game.players[event.player_index]
        local pos_idx = wutils.format_idx_from_position(event.tag.position)
        if storage.qmtt and storage.qmtt.tags then
            local stored_qmtt = wutils.find_element_by_key_and_value(storage.qmtt.tags, "idx", pos_idx)            
            if stored_qmtt then
                wutils.remove_element(storage.qmtt.tags, stored_qmtt)
                stored_qmtt.destroy()
            end
            qmtt.reset_chart_tags()
        end
    end
end)

function qmtt.add_tag_ensure_structure(player)
    if not storage.GUI then storage.GUI = {} end
    if not storage.GUI.AddTag then storage.GUI.AddTag = {} end
    if not storage.GUI.AddTag.players then storage.GUI.AddTag.players = {} end
    if not storage.GUI.AddTag.players[player.index] then
        storage.GUI.AddTag.players[player.index] = {
            elements = nil,
            position = nil
        }
    end
end

function qmtt.add_tag_is_open(player)
    if player then
        qmtt.add_tag_ensure_structure(player)
        return storage.GUI.AddTag.players[player.index].elements ~= nil
    end
end

return qmtt





--[[function qmtt.add_tag_get_display_text(player)
    if (player) then
        if (not qmtt.add_tag_is_open(player)) then
            return nil
        end
        return storage.GUI.AddTag.players[player.index].elements.fields.displaytext.text
    end
end

function qmtt.add_tag_get_description(player)
    if (player) then
        if (not qmtt.add_tag_is_open(player)) then
            return nil
        end
        return storage.GUI.AddTag.players[player.index].elements.fields.description.text
    end
end

function qmtt.add_tag_get_favorite(player)
    if (player) then
        if (not qmtt.add_tag_is_open(player)) then
            return nil
        end
        return storage.GUI.AddTag.players[player.index].elements.fields.favorite.state
    end
end]]

-- this handles the qmtt side of things ONLY!!
--[[function qmtt.add_new_tag(chart_tag)
    local player = chart_tag.last_user
    local player_index = player.index
    local pos_idx = wutils.format_idx_from_position(chart_tag.position)

    local favorite = qmtt.add_tag_get_favorite(player)
    local fave_list = {}
    if favorite then fave_list = { player_index } else fave_list = {} end

    local _qmtt = {
        idx = pos_idx,
        position = chart_tag.position,
        favorite_list = fave_list,
        fave_displaytext = qmtt.add_tag_get_display_text(player),
        fave_description = qmtt.add_tag_get_description(player),
    }

    local existing_q = qmtt.get_matching_qmtt_by_position(chart_tag.position, player)
    if existing_q then
        existing_q = _qmtt
        return existing_q
    end

    storage.qmtt.tags[#storage.qmtt.tags + 1] = _qmtt
    return storage.qmtt.tags[#storage.qmtt.tags]
end]]
