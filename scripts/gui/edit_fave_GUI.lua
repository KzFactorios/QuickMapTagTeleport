local gui           = require("lib/gui")
local wutils        = require("wct_utils")
local mod_gui       = require("mod-gui")
local constants     = require("settings/constants")
local PREFIX        = constants.PREFIX
--local control       = require("control")

local edit_fave_GUI = {}

function edit_fave_GUI.init()
end

--template
local function add_edit_fave_template(player, fave)
    -- do any setup here
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
                direction = "vertical",
                style = "inside_shallow_frame_with_padding",
                children = {
                    {
                        type = "flow",
                        style = "frame_header_flow",
                        direction = "horizontal",
                        children = {
                            {
                                type = "sprite",
                                sprite = "info",
                                style = PREFIX .. "edit-fave-gui-info-image",
                                --minimal_width = 80,
                                --minimal_height = 80,
                                --scale = 2,
                                tooltip =
                                "Click the arrow buttons to change the order of the favorite. Hotkey assignments will be updated automatically."
                            },
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
                                type = "label",
                                style = "label",
                                caption = { "edit-fave-gui.position" }
                            },
                            {
                                type = "label",
                                style = "label",
                                caption = fave._pos_idx
                            },
                        },
                    },
                },
            },
        }
    }
end

function edit_fave_GUI.update_ui(player_index)
    if game then
        local player = game.players[player_index]
        local fave_pos = cache.get_player_selected_fave_pos_idx(player)
        local fave_index = cache.get_player_selected_fave_idx(player)

        if player then
            --local selected_fave = storage.qmtt.GUI.edit_fave.players[player.index].selected_fave
            if not storage.qmtt.GUI.edit_fave.players[player.index] then
                storage.qmtt.GUI.edit_fave.players[player.index] = {
                    elements = {},
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
            storage.qmtt.GUI.edit_fave.players[player.index].elements =
                gui.build(screen, { add_edit_fave_template(player, sel_fave) })

            storage.qmtt.GUI.edit_fave.players[player.index].elements.root_frame.force_auto_center()


            --[[local scale = player.display_scale
            local chart_view_x = 0
            local chart_view_y = 0
            if player.render_mode ~= defines.render_mode.game then
                chart_view_x = 14 * scale
                chart_view_y = 48 * scale
            end
            local offset = (fave_index - 1) * (43 * scale)
            screen["edit-fave-gui"].location = { x = chart_view_x + (160 * scale) + offset, y = chart_view_y + (57 * scale) }
            ]]
        end
    end
end

function edit_fave_GUI.on_configuration_changed(event)
    local stub = 'stub'
end

function edit_fave_GUI.is_open(player)
    if storage.qmtt.GUI.edit_fave.players[player.index].elements and
        next(storage.qmtt.GUI.edit_fave.players[player.index].elements) then
        return true
    end
    return false
end

function edit_fave_GUI.open(player)
    edit_fave_GUI.update_ui(player.index)
end

function edit_fave_GUI.close(player)
    --storage.qmtt.GUI.edit_fave.players[player.index].selected_fave = ''
    storage.qmtt.GUI.edit_fave.players[player.index].elements = {}
    if mod_gui.get_button_flow(player).gui.screen["edit-fave-gui"] ~= nil then
        mod_gui.get_button_flow(player).gui.screen["edit-fave-gui"].destroy()
    end
end

-- handle when a fav_bar button has been clicked
function edit_fave_GUI.handle_fave_clicked(event) -- fave_index, player_index
    if game then
        edit_fave_GUI.update_ui(event.player_index)
    end
end

--enabled
edit_fave_GUI.get_left = function(player)
    if (not edit_fave_GUI.is_open(player)) then
        return nil
    end

    return storage.qmtt.GUI.edit_fave.players[player.index].elements.buttons.left
end

edit_fave_GUI.get_right = function(player)
    if (not edit_fave_GUI.is_open(player)) then
        return nil
    end

    return storage.qmtt.GUI.edit_fave.players[player.index].elements.buttons.right
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
                storage.qmtt.GUI.edit_fave.players[event.player_index] = {
                    elements = {},
                    selected_fave = ''
                }
            end
        },
        buttons = {
            cancel = {
                on_gui_click = function(event)
                    local player = game.get_player(event.player_index)
                    edit_fave_GUI.close(player)
                    storage.qmtt.GUI.edit_fave.players[event.player_index].selected_fave = ''
                end
            },
            left = {
                on_gui_click = function(event)
                    swap(event)
                end
            },
            right = {
                on_gui_click = function(event)
                    swap(event)
                end
            },
            confirm = {
            }
        }
    }
}

function swap(event)
    local player = game.get_player(event.player_index)
    if player then
        local all_faves = cache.get_player_favorites(player)
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

-- edit_fave.buttons.left
script.on_event(defines.events.on_gui_click, function(event)
    -- has to be a right click
    if event.button == 4 then
        -- select a fave
        -- if fave, raise an event
    end
end)

return edit_fave_GUI
