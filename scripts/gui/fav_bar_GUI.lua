local gui              = require("lib/gui")
local wutils           = require("wct_utils")
local mod_gui          = require("mod-gui")
local edit_fave_GUI    = require("edit_fave_GUI")

local add_tag_settings = require("settings/add_tag_settings")
local map_tag_utils    = require("utils/map_tag_utils")
local table            = require("__flib__/table")

local constants        = require("settings/constants")
local PREFIX           = constants.PREFIX

fav_bar_GUI            = {
    on_click = {}
}

function fav_bar_GUI.init_player(player_index)
    local player = game.players[player_index]
    if not storage.qmtt.GUI.fav_bar.players[player_index].fave_places[player.surface_index] then
        cache.get_player_favorites(player)

        -- TODO check ext_tags for any missed tags on init
    end
end

--[[function fav_bar_GUI.handle_fave_order_changed(event)
    local stub = "stub"
end]]

function fav_bar_GUI.update_ui(player)
    if player then
        local inner_container = mod_gui.get_button_flow(player)
        if inner_container then
            local fav_bar = inner_container["fav_bar_GUI"]
            if fav_bar then
                fav_bar.destroy()
                storage.qmtt.GUI.fav_bar.players[player.index].elements = nil
            end
        end
        storage.qmtt.GUI.fav_bar.players[player.index].elements =
            gui.build(inner_container, { add_fav_bar_template(player) })
        --else
        sync_buttons_to_faves(player)
        --end
    end
end

function sync_buttons_to_faves(player)
    -- get player faves
    local faves = cache.get_player_favorites(player)
    -- get player buttons
    local butts = storage.qmtt.GUI.fav_bar.players[player.index].elements.buttons
    local buttons = wutils.get_elements_starts_with_key(butts, "favorite_") or {}

    if buttons ~= {} then
        -- sync them up - fave is king
        for i = 1, #faves do
            -- find the matching button
            local fave = faves[i]
            local type = ''
            local name = ''
            if fave._chart_tag and fave._chart_tag.icon then
                type = fave._chart_tag.icon.type
                name = fave._chart_tag.icon.name
            end
            local sprite_path = wutils.format_sprite_path(type, name)

            -- use a default sprite for fave tags without an icon
            if sprite_path == '' and next(fave) then
                sprite_path = 'custom-map-view-tag'
            end



            buttons[i].sprite = sprite_path
            --TODO decide how to use extra text
            buttons[i].caption = fave.fave_displaytext or ''
            buttons[i].tooltip = fave._pos_idx or ''
        end
    end
end

function add_fav_bar_template(player)
    local child_buttons = {
        {
            type = "button",
            name = "buttons.toggle.favorite_mode",
            save_as = "buttons.toggle_favorite_mode",
            style = PREFIX .. "toggle_favorite_mode_button",
            handlers = "fav_bar.buttons.toggle_favorite_mode",
            caption = "",
        }
    }

    -- Dynamically add buttons for every favorite
    local faves = cache.get_player_favorites(player)
    local index_fave = nil

    for i = 1, 10 do
        index_fave = nil
        local sprite_path = ""
        local fave_displayText = ""
        local fave_description = ""

        if i <= #faves then
            index_fave = faves[i]

            if index_fave and index_fave._chart_tag and index_fave._chart_tag.icon then
                local type = index_fave._chart_tag.icon.type
                if type == "virtual" then
                    type = "virtual-signal"
                end
                sprite_path = type .. "/" .. index_fave._chart_tag.icon.name
                if not helpers.is_valid_sprite_path(sprite_path) then
                    -- TODO better user messaging on error
                    sprite_path = ""
                end

                fave_displayText = index_fave._qmtt.fave_displayText
                fave_description = index_fave._qmtt.idx
            end
        end

        table.insert(child_buttons, {
            type = "sprite-button",
            name = "tele_" .. i,
            save_as = "buttons.favorite_sel" .. i,
            style = "slot_button",
            handlers = "fav_bar.buttons.fave_action",
            sprite = sprite_path,
            caption = fave_displayText,
            tooltip = fave_description,
        })
    end

    return {
        type = "frame",
        style = "fav_bar_gui",
        save_as = "root_frame",
        name = "fav_bar_GUI",
        direction = "vertical",
        handlers = "fav_bar.root_frame",
        children = { {
            type = "frame",
            style = "fav_bar_row",
            name = "fav_bar_row",
            direction = "horizontal",
            children =
                child_buttons
        } }
    }
end

function fav_bar_GUI.close(player)
    if player then
        storage.qmtt.GUI.fav_bar.players[player.index].elements = {}
    end
end

-- at this point we can be certain that the storage structure has been initialized
-- so be sure to initialize it before using -- derp!!!
fav_bar_GUI.open = function(player)
    if player then
        fav_bar_GUI.update_ui(player)
    end
end

fav_bar_GUI.handlers = {
    fav_bar = {
        root_frame = {
            on_gui_closed = function(event)
                storage.qmtt.GUI.fav_bar.players[event.player_index].elements.root_frame.destroy()
            end
        },
        buttons = {
            fave_action = {
                on_gui_click = function(event)
                    local player = game.players[event.player_index]
                    if event.button == 2 then
                        -- do a teleport
                        game.print("you LEFT clicked a fave button")
                        --element.name = "tele_8"
                        if event.element.tooltip ~= "" then
                            local og_position = player.position
                            local og_surface_index = player.surface_index
                            local position = wutils.decode_position_from_pos_idx(event.element.tooltip)
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
                        game.print("you RIGHT clicked a fave button")
                        local index_str = string.gsub(event.element.name, 'tele_', '')
                        local fave_index = tonumber(index_str)
                        if fave_index then
                            local selected_fave = storage.qmtt.GUI.fav_bar.players[player.index]
                                .fave_places[player.surface_index][fave_index]._pos_idx

                            storage.qmtt.GUI.edit_fave.players[player.index].selected_fave =
                                selected_fave

                            -- TODO raise an event
                            --script.raise_event(storage.qmtt.registered_events['fave_selected_event'],
                            --    { fave_index, player.index })

                            script.raise_event(constants.events.SELECTED_FAVE_CHANGED, {
                                player_index = player.index,
                                fave_index = fave_index,
                                selected_fave = selected_fave,
                            })

                            --[[edit_fave_GUI.handle_fave_clicked(
                                {
                                    player_index = player.index,
                                    fave_index = fave_index,
                                    selected_fave = selected_fave,
                                })]]
                        end
                    end
                    --event.element.name
                    --event.player_index
                    --event.button 2=left,,4=right
                    --event.alt/control/shift
                end
            },
            toggle_favorite_mode = {
                on_gui_click = function(event)

                end
            }
        },
    }
}

return fav_bar_GUI
