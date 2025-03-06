local edit_fave_GUI = require("scripts/gui/edit_fave_GUI")
local map_tag_utils = require("utils/map_tag_utils")
local constants     = require("settings/constants")
local fave          = require("scripts/gui/fave")
local table         = require("__flib__/table")
local wutils        = require("wct_utils")
local gui           = require("lib/gui")
local mod_gui       = require("mod-gui")
local PREFIX        = constants.PREFIX
local add_tag_settings = require("settings/add_tag_settings")
local next          = next

fav_bar_GUI         = {}

function fav_bar_GUI.update_ui(player)
    if not player then return end

    fav_bar_GUI.close(player)
    -- Don't allow the interface on a space platform
    if map_tag_utils.is_on_space_platform(player) or player.character == nil then return end

    local settings = add_tag_settings.getPlayerSettings(player)
    if not settings.favorites_on then return end

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

--- Indicates if the fav_bar exists in the button_flow gui
function fav_bar_GUI.is_open(player)
    if not player then return false end

    return mod_gui.get_button_flow(player)["fav_bar_GUI"] ~= nil
end

function fav_bar_GUI.buttons_show(player)
    if not player then return end
    if not player.character then return end

    storage.qmtt.player_data[player.index].show_fave_bar_buttons = true
    mod_gui.get_button_flow(player).fav_bar_GUI.fav_bar_widget["fav_bar_row"].visible =
        storage.qmtt.player_data[player.index].show_fave_bar_buttons
end

function fav_bar_GUI.buttons_hide(player)
    if not player then return end

    storage.qmtt.player_data[player.index].show_fave_bar_buttons = false
    mod_gui.get_button_flow(player).fav_bar_GUI.fav_bar_widget["fav_bar_row"].visible =
        storage.qmtt.player_data[player.index].show_fave_bar_buttons
end

function fav_bar_GUI.close(player)
    if not player then return end

    if fav_bar_GUI.is_open(player) then
        local flow = mod_gui.get_button_flow(player)
        flow["fav_bar_GUI"].destroy()
    end

    -- check gui for zero elements?
    --if player.gui and player.gui.top and player.gui.top.children["mod_gui_top_frame"] then
    --    local top_frame = 
    --end

end

--- returns boolean indicating if the button bar is showing or not
function fav_bar_GUI.buttons_on(player)
    if not player then return false end

    if fav_bar_GUI.is_open(player) then
        return storage.qmtt.player_data[player.index].show_fave_bar_buttons
    end
    return false
end

--- Build the Favorite Bar. Add the favorite hide/show and buttons for every favorite
--- @param player LuaPlayer
function fav_bar_GUI.add_fav_bar_template(player)
    if not player then return end

    local faves = cache.get_player_favorites(player)
    if not faves then return end

    local child_buttons = {}

    for i = 1, #faves do
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
                    local player = game.get_player(event.player_index)
                    if not player then return end
                    if not player.character then return end
                    if not event.element then return end

                    local idx_num = event.element.number
                    if idx_num == nil then return end

                    -- transpose
                    if idx_num == 0 then idx_num = 10 end
                    local index_fave = nil

                    if event.button == 2 then
                        -- don't allow teleports when the editor is open
                        if edit_fave_GUI.is_open(player) then return end

                        -- do a teleport
                        -- game.print("you LEFT clicked a fave button")
                        if event.element.tooltip ~= "" then
                            local position = nil
                            local og_position = player.position
                            local og_surface_index = player.physical_surface_index
                            local all_faves = cache.get_player_favorites(player)

                            if all_faves and next(all_faves) then
                                index_fave = all_faves[idx_num]
                            end
                            if index_fave ~= nil then
                                position = wutils.decode_position_from_pos_idx(index_fave._pos_idx)
                            end
                            if position == nil then return end

                            local tele_pos, msg = map_tag_utils.teleport_player_to_closest_position(player, position)
                            
                            if tele_pos then
                                local settings = add_tag_settings.getPlayerSettings(player)

                                if settings.destination_msg_on then
                                  game.print(string.format("%s teleported to x: %d, y: %d", player.name, tele_pos.x, tele_pos.y))
                                end
                                --add_tag_GUI.close(player)
                    
                                -- provide a hook for others to key into
                                ---@diagnostic disable-next-line: param-type-mismatch
                                script.raise_event(defines.events.script_raised_teleported,
                                  {
                                    player_index = player.index,
                                    entity = player.character,
                                    old_surface_index = og_surface_index,
                                    old_position = og_position
                                  }
                                )
                              else
                                game.print(msg)
                              end
                        end
                    elseif event.button == 4 then
                        -- open an editor
                        -- game.print("you RIGHT clicked a fave button")
                        index_fave = storage.qmtt.GUI.fav_bar.players[player.index]
                            .fave_places[player.physical_surface_index][idx_num]._pos_idx

                        storage.qmtt.GUI.edit_fave.players[player.index].selected_fave = index_fave

                        script.raise_event(constants.events.SELECTED_FAVE_CHANGED, {
                            player_index = player.index,
                            fave_index = idx_num,
                            selected_fave = index_fave,
                        })
                    end
                end
            },
            toggle_favorite_mode = {
                on_gui_click = function(event)
                    if event.button == 2 then
                        if game then
                            local player = game.get_player(event.player_index)
                            if not player then return end
                            if not player.character then return end

                            if fav_bar_GUI.buttons_on(player) then
                                fav_bar_GUI.buttons_hide(player)
                            else
                                fav_bar_GUI.buttons_show(player)
                            end
                        end
                    end
                end
            }
        },
    }
}

function fav_bar_GUI.on_player_removed(player_index)
    local player = game.get_player(player_index)
    if not player then return end

    fav_bar_GUI.close(player)
end

return fav_bar_GUI
