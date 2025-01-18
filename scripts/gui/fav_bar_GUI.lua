local gui           = require("lib/gui")
local wutils        = require("wct_utils")
local mod_gui       = require("mod-gui")
local map_tag_utils = require("utils/map_tag_utils")
local table         = require("__flib__/table")
local constants     = require("settings/constants")
local PREFIX        = constants.PREFIX
local fave          = require("scripts/gui/fave")
--local edit_fave_GUI = require("scripts/gui/edit_fave_GUI")
local next          = next

fav_bar_GUI         = {
    on_click = {}
}

function fav_bar_GUI.init_player(player_index)
    local player = game.players[player_index]
    if player and not storage.qmtt.GUI.fav_bar.players[player_index]
        .fave_places[player.surface_index] then
        cache.get_player_favorites(player)
    end
end

function fav_bar_GUI.update_ui(player)
    if player then
        fav_bar_GUI.close(player)
        gui.build(mod_gui.get_button_flow(player), { fav_bar_GUI.add_fav_bar_template(player) })
        -- sync_buttons_to_faves(player)

        if fav_bar_GUI.is_open(player) then
            if storage.qmtt.player_data[player.index].show_fave_bar_buttons == true then
                fav_bar_GUI.buttons_show(player)
            else
                fav_bar_GUI.buttons_hide(player)
            end
        end
    end
end

--- Indicates if the fav_bar exists in the button_flow gui
function fav_bar_GUI.is_open(player)
    if player then
        return mod_gui.get_button_flow(player)["fav_bar_GUI"] ~= nil
    end
    return false
end

function fav_bar_GUI.buttons_show(player)
    if player then
        storage.qmtt.player_data[player.index].show_fave_bar_buttons = true
        mod_gui.get_button_flow(player).fav_bar_GUI.fav_bar_widget["fav_bar_row"].visible =
            storage.qmtt.player_data[player.index].show_fave_bar_buttons
    end
end

function fav_bar_GUI.buttons_hide(player)
    if player then
        storage.qmtt.player_data[player.index].show_fave_bar_buttons = false
        mod_gui.get_button_flow(player).fav_bar_GUI.fav_bar_widget["fav_bar_row"].visible =
            storage.qmtt.player_data[player.index].show_fave_bar_buttons
    end
end

function fav_bar_GUI.close(player)
    if player and fav_bar_GUI.is_open(player) then
        mod_gui.get_button_flow(player)["fav_bar_GUI"].destroy()
    end
end

--- returns boolean indicating if the button bar is showing or not
function fav_bar_GUI.buttons_on(player)
    if player and fav_bar_GUI.is_open(player) then
        return storage.qmtt.player_data[player.index].show_fave_bar_buttons
    end
    return false
end

--- OBS
function fav_bar_GUI.sync_buttons_to_faves(player)
    if player then
        local faves = cache.get_player_favorites(player)
        if faves then
            local butts = mod_gui.get_button_flow(player)["fav_bar_GUI"].fav_bar_widget.fav_bar_row.children

            local buttons = {} --wutils.tableContainsLikeKey(butts, "tele_") or {}
            local add_tag_settings = require("settings/add_tag_settings")
            for i = 1, #butts do
                if wutils.starts_with(butts[i].name, "tele_") then
                    table.insert(buttons, butts[i])
                end
            end

            if #buttons then
                -- sync them up - fave is king
                for i = 1, #faves do
                    -- find the matching button
                    local _fave = faves[i]
                    local type = ""
                    local name = ""
                    local ct = fave.get_chart_tag(player, _fave)
                    if ct and ct.icon and ct.icon ~= "" then
                        type = ct.icon.type
                        name = ct.icon.name
                    end
                    local sprite_path = wutils.format_sprite_path(type, name, false)

                    -- use a default sprite for fave tags without an icon
                    if sprite_path == '' and next(_fave) then
                        sprite_path = 'custom-map-view-tag'
                    end

                    buttons[i].sprite = sprite_path
                    --TODO decide how to use extra text
                    local q = fave.get_qmtt(player, _fave)
                    if q then
                        buttons[i].caption = fave.get_display_text(player, _fave)
                    end
                    buttons[i].tooltip = _fave._pos_idx
                    buttons[i].number = i
                end
            end
        end
    end
end

function fav_bar_GUI.add_fav_bar_template(player)
    -- Dynamically add buttons for every favorite
    if player then
        local faves = cache.get_player_favorites(player)
        if faves then
            local child_buttons = {}

            for i = 1, 10 do
                local index_fave = nil
                local sprite_path = ""
                --local fave_displayText = ""
                --local fave_description = ""
                local fave_tooltip = ""
                local fave_number = nil

                if i <= #faves then
                    index_fave = faves[i]
                    fave_tooltip = (index_fave._pos_idx or "")

                    if index_fave and next(index_fave) then
                        sprite_path = fave.format_sprite_path_from_favorite(player, index_fave, false)

                        local ct = fave.get_chart_tag(player, index_fave)
                        if ct and ct.text ~= nil and string.len(ct.text) > 0 then
                            fave_tooltip = fave_tooltip .. "\n" .. ct.text
                        end

                        fave_number = tostring(i)
                        if fave_number == "10" then
                            fave_number = "0"
                        end
                        --fave_displayText = fave.get_display_text(player, index_fave)
                        --fave_description = fave.get_description(player, index_fave)
                    end
                end

                table.insert(child_buttons, {
                    type = "sprite-button",
                    name = "tele_" .. i,
                    save_as = "buttons.favorite_sel" .. i,
                    style = "slot_button",
                    handlers = "fav_bar.buttons.fave_action",
                    sprite = sprite_path,
                    number = fave_number,
                    tooltip = fave_tooltip,
                })
            end

            return {
                type = "frame",
                style = "fav_bar_gui",
                save_as = "root_frame",
                name = "fav_bar_GUI",
                direction = "horizontal",
                handlers = "fav_bar.root_frame",
                children =
                {
                    {
                        type = "flow",
                        name = "fav_bar_widget",
                        save_as = "fav_bar_widget",
                        direction = "horizontal",
                        horizontally_stretchable = true,
                        vertically_stretchable = true,
                        minimal_width = 200,
                        minimal_height = 80,
                        padding = 0,
                        horizontal_spacing = 0,
                        children =
                        {
                            {

                                type = "button",
                                name = "buttons.toggle.favorite_mode",
                                save_as = "buttons.toggle_favorite_mode",
                                style = PREFIX .. "toggle_favorite_mode_button",
                                handlers = "fav_bar.buttons.toggle_favorite_mode",
                                caption = "",
                            },
                            {
                                type = "frame",
                                style = "fav_bar_row",
                                name = "fav_bar_row",
                                direction = "horizontal",
                                children =
                                    child_buttons
                            }
                        }
                    }
                }
            }
        end
    end
end

fav_bar_GUI.handlers = {
    fav_bar = {
        root_frame = {
            on_gui_closed = function(event)
                -- gui should already be closed
            end
        },
        buttons = {
            --event.element.name
            --event.player_index
            --event.button 2=left,3=middle,4=right
            --event.alt/control/shift
            fave_action = {
                on_gui_click = function(event)
                    local player = game.players[event.player_index]
                    if player then
                        local index_fave = nil
                        local idx_num = event.element.number

                        if idx_num == 0 then idx_num = 10 end

                        if event.button == 2 then
                            -- don't allow teleports when the editor is open
                            if control.is_edit_fave_open(player) then return end

                            -- do a teleport
                            -- game.print("you LEFT clicked a fave button")
                            if event.element.tooltip ~= "" then
                                local position = nil
                                local og_position = player.position
                                local og_surface_index = player.surface_index
                                local all_faves = cache.get_player_favorites(player)
                                
                                if all_faves and next(all_faves) then
                                    index_fave = all_faves[idx_num]
                                end
                                if index_fave ~= nil then
                                    position = wutils.decode_position_from_pos_idx(index_fave._pos_idx)
                                end
                                if position == nil then return end

                                -- TODO assign a player setting
                                local radius = 10

                                local tele_pos, msg = map_tag_utils.teleport_player_to_closest_position(player, position,
                                    radius)
                                if tele_pos then
                                    game.print(string.format("%s teleported to x: %d, y: %d", player.name, tele_pos.x,
                                        tele_pos.y))

                                    -- provide a hook for others to key into
                                    ---@diagnostic disable-next-line: param-type-mismatch
                                    script.raise_event(defines.events.script_raised_teleported,
                                        {
                                            entity = player.character,
                                            old_surface_index = og_surface_index,
                                            old_position = og_position,
                                            teleported_to = tele_pos
                                        }
                                    )
                                end
                            end
                        elseif event.button == 4 then
                            -- open an editor
                            -- game.print("you RIGHT clicked a fave button")

                            index_fave = storage.qmtt.GUI.fav_bar.players[player.index]
                                .fave_places[player.surface_index][idx_num]._pos_idx

                            storage.qmtt.GUI.edit_fave.players[player.index].selected_fave = index_fave

                            script.raise_event(constants.events.SELECTED_FAVE_CHANGED, {
                                player_index = player.index,
                                fave_index = idx_num,
                                selected_fave = index_fave,
                            })
                        end
                    end
                end
            },
            toggle_favorite_mode = {
                on_gui_click = function(event)
                    if event.button == 2 then
                        if game then
                            local player = game.players[event.player_index]
                            if player then
                                if fav_bar_GUI.buttons_on(player) then
                                    fav_bar_GUI.buttons_hide(player)
                                else
                                    fav_bar_GUI.buttons_show(player)
                                end
                            end
                        end
                    end
                end
            }
        },
    }
}

function fav_bar_GUI.on_player_removed(player_index)
    local player = game.players[player_index]
    if player then
        fav_bar_GUI.close(player)
    end
end

return fav_bar_GUI
