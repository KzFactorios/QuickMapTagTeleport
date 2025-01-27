--OK this is not a gui but it just seemed appropriate to put here
local table  = require("__flib__.table")
local wutils = require("wct_utils")
local cache  = require("lib/cache")
local qmtt   = {}

--[[
idx = "",
position = {},
faved_by_players = {},
fave_displaytext = "",
fave_description = "",
]]

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

-- handle changes from the stock tag editor
-- see if we can throw this only when the gui-tag-edit control makes changes
--TODO does this throw on add tag changes?
script.on_event(defines.events.on_chart_tag_modified, function(event)
    if game and event.player_index then
        local player = game.get_player(event.player_index)
        if not player then return end

        local old_pos = wutils.format_idx_from_position(event.old_position)

        -- update matching chart_tag
        local stored_tag =
            wutils.find_element_by_position(cache.get_chart_tags_from_cache(player),
                "position",
                event.old_position)
        if stored_tag then
            stored_tag = table.deep_copy(event.tag)
        end

        local stored_qmtt =
            wutils.find_element_by_key_and_value(storage.qmtt.ext_tags, "idx", old_pos)
        if stored_qmtt then
            stored_qmtt.idx = wutils.format_idx_from_position(event.tag.position)
            stored_qmtt.position.x = event.tag.position.x
            stored_qmtt.position.y = event.tag.position.y
        else
            stored_qmtt = {
                idx = wutils.format_idx_from_position(event.tag.position),
                position = event.tag.position,
                faved_by_players = {},
                fave_displaytext = "",
                fave_description = "",
            }
        end

        qmtt.reset_chart_tags(player.physical_surface_index)
    end
end)

---  Cleans up linked chart tags, extended tags, selected faves
function qmtt.handle_chart_tag_removal(event)
    if game and event.player_index then
        local player = game.get_player(event.player_index)
        if not player then return end

        control.remove_tag_at_position(player, event.tag.position)
    end
end

function qmtt.handle_chart_tag_modified(event)
    -- only handle stock editor changes - event.mod_name == nil
    local mod = event.mod_name
    -- modified pos by stock editor, mod_name == nil

    if not mod and event.old_position ~= event.tag.position then
        local old_pos = wutils.format_idx_from_position(event.old_position)
        local new_pos = wutils.format_idx_from_position(event.tag.position)
        local surface_id = event.tag.surface.index
        local fav_bar_reset = false

        -- find any faves (pos_idx)
        for _, player in pairs(storage.qmtt.GUI.fav_bar.players) do
            for _, fave in pairs(player.fave_places[surface_id]) do
                if fave._pos_idx == old_pos then
                    fave._pos_idx = new_pos
                    fav_bar_reset = true
                    break
                end
            end
        end

        -- find any qmtts (idx and position)
        for _, ext in pairs(storage.qmtt.surfaces[surface_id].extended_tags) do
            if ext.idx == old_pos then
                ext.idx = new_pos
                ext.position.x = event.tag.position.x
                ext.position.y = event.tag.position.y
                break
            end
        end

        -- find any chart tags
        for _, chart_tag in pairs(storage.qmtt.surfaces[surface_id].chart_tags) do
            if wutils.format_idx_from_position(chart_tag.position) == old_pos then
                chart_tag.position.x = event.tag.position.x
                chart_tag.position.y = event.tag.position.y
                break
            end
        end

        -- reset any UIs, chart_tags?
        if fav_bar_reset and game and event.player_index then
            local player = game.get_player(event.player_index)
            if player then
                fav_bar_GUI.update_ui(player)
            end
        end
    end
end

function qmtt.remove_chart_tag_at_position(player, pos)
    if not player then return end

    local _chart_tags = storage.qmtt.surfaces[player.physical_surface_index].chart_tags
    if _chart_tags and #_chart_tags > 0 then
        local idx = wutils.find_element_idx_by_position(_chart_tags, "position", pos)
        if idx and idx > 0 then
            _chart_tags[idx] = nil
        end
    end
end

function qmtt.remove_ext_tag_at_position(player, pos)
    if not player then return end

    local _ext_tags = storage.qmtt.surfaces[player.physical_surface_index].extended_tags
    if _ext_tags and #_ext_tags > 0 then
        local idx = wutils.find_element_idx_by_position(_ext_tags, "position", pos)
        if idx and idx > 0 then
            _ext_tags[idx] = nil
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
    if not player then return end

    local surfs = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.physical_surface_index]
    local fave_idx = wutils.get_element_index(surfs, "_pos_idx", pos_idx)
    if fave_idx > 0 and fave_idx <= #surfs then
        surfs[fave_idx] = {}
    end
end

return qmtt
