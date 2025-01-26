local gui           = require("lib/gui")
local wutils        = require("wct_utils")
local mod_gui       = require("mod-gui")
local constants     = require("settings/constants")
local PREFIX        = constants.PREFIX
local fave          = require("scripts/gui/fave")

local edit_fave_GUI = {}

--template
local function edit_fave_template(player, _fave)
    -- do any setup here
    if player then
        local position_string = wutils.format_idx_string_from_pos_idx(_fave._pos_idx)
        if not position_string then position_string = "" end

        local hotkey = cache.get_player_selected_fave_idx(player)
        if hotkey == 10 then hotkey = 0 end

        local fave_text = ""
        local fave_sprite_path = ""
        local ct = fave.get_chart_tag(player, _fave)
        if ct then
            fave_text = ct.text or ""
            if ct.icon then
                fave_sprite_path = wutils.format_sprite_path(ct.icon.type, ct.icon.name, false)
            end
        end

        return
        {
            name = "edit-fave-gui",
            type = "frame",
            save_as = "root_frame",
            direction = "vertical",
            handlers = "edit_fave.root_frame",
            children = {
                {
                    type = "flow",
                    style = "frame_header_flow",
                    children = {
                        { type = "label", style = "frame_title", caption = { "edit-fave-gui.frame_title" } },
                        {
                            type = "empty-widget",
                            save_as = "buttons.draggable_space_header",
                            style = "flib_dialog_footer_drag_handle"
                        },
                        {
                            type = "button",
                            save_as = "buttons.cancel_h",
                            style = PREFIX .. "frame_action_button",
                            caption = { "edit-fave-gui.x" },
                            handlers = "edit_fave.buttons.cancel"
                        }
                    }
                },

                {
                    type = "frame",
                    name = "frame-container",
                    direction = "vertical",
                    style = "inside_shallow_frame_with_padding",
                    children = {
                        {
                            type = "flow",
                            name = "info-flow",
                            style = "frame_header_flow",
                            direction = "horizontal",
                            children = {
                                {
                                    type = "sprite-button",
                                    save_as = "buttons.left",
                                    name = "buttons.left",
                                    style = PREFIX .. "frame_action_button",
                                    sprite = "utility/backward_arrow",
                                    handlers = "edit_fave.buttons.left",
                                },
                                {
                                    type = "sprite-button",
                                    save_as = "buttons.right",
                                    name = "buttons.right",
                                    style = PREFIX .. "frame_action_button",
                                    sprite = "utility/forward_arrow",
                                    handlers = "edit_fave.buttons.right",
                                },
                                {
                                    type = "sprite",
                                    name = "info-image",
                                    sprite = "info",
                                    style = PREFIX .. "edit-fave-gui-info-image",
                                    tooltip =
                                    "Click the arrow buttons to change the order of the favorite. Hotkey assignments will be updated automatically. Note that the hotkeys swap so you may have to update more than one assignment."
                                },
                                {
                                    type = "label",
                                    style = "label",
                                    caption = { "edit-fave-gui.hotkey", ": " }
                                },
                                {
                                    type = "label",
                                    style = "label",
                                    caption = hotkey
                                },
                            },
                        },
                        {
                            type = "flow",
                            name = "info-flow-pos",
                            style = "frame_header_flow",
                            direction = "horizontal",
                            children = {
                                {
                                    type = "label",
                                    style = "label",
                                    caption = { "edit-fave-gui.position", ": " }
                                },
                                {
                                    type = "label",
                                    style = "label",
                                    caption = position_string
                                },
                            }
                        },
                        {
                            type = "flow",
                            name = "info-flow-txt",
                            style = "frame_header_flow",
                            direction = "horizontal",
                            children = {
                                {
                                    type = "label",
                                    style = "label",
                                    caption = { "edit-fave-gui.text", ": " }
                                },
                                {
                                    type = "label",
                                    style = "fave_text_label",
                                    caption = fave_text
                                },
                            }
                        },
                        {
                            type = "flow",
                            name = "info-flow-sprite",
                            style = "frame_header_flow",
                            direction = "horizontal",
                            children = {
                                {
                                    type = "sprite-button",
                                    name = "buttons.icon",
                                    --style = "fave_icon_button",
                                    sprite = fave_sprite_path,
                                    -- mouse_button_filter={"left"}
                                },
                            }
                        },
                    },
                },
            }
        }
    end
end

function edit_fave_GUI.update_ui(player_index)
    if game then
        local player = game.get_player(player_index)
        if player then
            local fave_pos = cache.get_player_selected_fave_pos_idx(player)
            if not storage.qmtt.GUI.edit_fave.players[player.index] then
                storage.qmtt.GUI.edit_fave.players[player.index] = {
                    selected_fave = fave_pos,
                }
            end

            -- force redraw of the gui
            edit_fave_GUI.close(player)
            if fave_pos == nil or fave_pos == '' then
                return
            end

            -- then build it
            local screen = player.gui.screen
            local sel_fave = cache.get_player_favorite_by_pos_idx(player, fave_pos)
            local elements =
                gui.build(screen, { edit_fave_template(player, sel_fave) })

            elements.root_frame.force_auto_center()

            -- Allow the GUI to intercept ESC key presses
            --elements.root_frame.ignored_by_interaction = false
        end
    end
end

function edit_fave_GUI.on_player_removed(player_index)
    local player = game.get_player(player_index)
    if player then
        edit_fave_GUI.close(player)
    end
end

function edit_fave_GUI.is_open(player)
    if player then
        return mod_gui.get_button_flow(player).gui.screen["edit-fave-gui"] ~= nil
    end
end

function edit_fave_GUI.open(player)
    if player then
        control.close_guis(player)
        edit_fave_GUI.update_ui(player.index)
    end
end

function edit_fave_GUI.close(player)
    if player and edit_fave_GUI.is_open(player) then
        mod_gui.get_button_flow(player).gui.screen["edit-fave-gui"].destroy()
    end
end

-- handle when a fav_bar button has been clicked
function edit_fave_GUI.handle_fave_clicked(event) -- fave_index, player_index
    local player = game.get_player(event.player_index)
    if player and edit_fave_GUI.is_open(player) then
        edit_fave_GUI.update_ui(event.player_index)
    end
end

--enabled
function edit_fave_GUI.get_left(player)
    if player and edit_fave_GUI.is_open(player) then
        return mod_gui.get_button_flow(player).gui.screen["edit-fave-gui"]["frame-container"]["info-flow"]
            ["buttons.left"]
    end
    return nil
end

function edit_fave_GUI.get_right(player)
    if player and edit_fave_GUI.is_open(player) then
        return mod_gui.get_button_flow(player).gui.screen["edit-fave-gui"]["frame-container"]["info-flow"]
            ["buttons.right"]
    end
    return nil
end

function edit_fave_GUI.get_icon(player)
    if player then
        if edit_fave_GUI.is_open(player) then
            return mod_gui.get_button_flow(player).gui.screen["edit-fave-gui"]["frame-container"]["info-flow"]
                ["info-image"]
        end
    end
    return nil
end

function edit_fave_GUI.on_selected_fave_changed(event)
    local player = game.get_player(event.player_index)
    if player then
        local left = edit_fave_GUI.get_left(player)
        local right = edit_fave_GUI.get_right(player)
        if left and right then
            local sel_idx = cache.get_player_selected_fave_idx(player)
            left.enabled = sel_idx > 1
            right.enabled = sel_idx < 10
        end
    end
end

--handlers
edit_fave_GUI.handlers = {
    edit_fave = {
        root_frame = {
            on_gui_closed = function(event)
                -- gui should be closed at this point
                -- do any cleanup
                local stub = ""
            end
        },
        fields = {
            icon = {
                on_gui_elem_changed = function(event)
                    if game then
                        local player = game.get_player(event.player_index)
                        if player then
                        end
                    end
                end
            }
        },
        buttons = {
            cancel = {
                on_gui_click = function(event)
                    local player = game.get_player(event.player_index)
                    if player and edit_fave_GUI.is_open(player) then
                        edit_fave_GUI.close(player)
                        storage.qmtt.GUI.edit_fave.players[event.player_index].selected_fave = ''
                    end
                end
            },
            left = {
                on_gui_click = function(event)
                    -- if next space is empty
                    -- find next next open or non-locked space
                    -- if next space is occupied
                    --edit_fave_GUI.move(event)
                    edit_fave_GUI.swap(event)
                end
            },
            right = {
                on_gui_click = function(event)
                    --edit_fave_GUI.move(event)
                    edit_fave_GUI.swap(event)
                end
            },
            confirm = {
            }
        }
    }
}

function edit_fave_GUI.move(event)
    local player = game.get_player(event.player_index)
    if player then
        local all_faves = cache.get_player_favorites(player)
        if all_faves then
            local sel_fave = cache.get_player_selected_favorite(player)
            local sel_idx = cache.get_player_selected_fave_idx(player)
            local new_idx = nil

            if event.element.name == "buttons.left" then
                new_idx = wutils.find_next_empty_left_index(all_faves, sel_idx)
            else
                new_idx = wutils.find_next_empty_right_index(all_faves, sel_idx)
            end

            if new_idx ~= nil then
                -- local tmp = all_faves[sel_idx]
                all_faves[new_idx] = sel_fave
                all_faves[sel_idx] = {}

                script.raise_event(constants.events.FAVE_ORDER_UPDATED, {
                    player_index = event.player_index,
                    old_index = sel_idx,
                    new_index = new_idx
                })
            end
        end
    end
end

function edit_fave_GUI.swap(event)
    local player = game.get_player(event.player_index)
    if player then
        local all_faves = cache.get_player_favorites(player)
        if all_faves then
            local sel_fave = cache.get_player_selected_favorite(player)
            local sel_idx = cache.get_player_selected_fave_idx(player)

            -- assume left
            local swap_idx = sel_idx - 1
            if event.element.name == "buttons.right" then
                swap_idx = sel_idx + 1
            end

            if swap_idx > 0 and swap_idx < 11 then
                local tmp = all_faves[swap_idx]
                all_faves[swap_idx] = sel_fave
                all_faves[sel_idx] = tmp
            else
                swap_idx = -1
            end

            script.raise_event(constants.events.FAVE_ORDER_UPDATED, {
                player_index = event.player_index,
                old_index = sel_idx,
                new_index = swap_idx
            })
        end
    end
end

-- edit_fave.buttons.left
script.on_event(defines.events.on_gui_click, function(event)
    -- has to be a right click
    if event.button == 4 then
        -- select a fave
        -- if fave, raise an event
    end
end)

return edit_fave_GUI
