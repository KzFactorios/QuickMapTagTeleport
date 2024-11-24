local gui              = require("lib/gui")
local wutils           = require("wct_utils")
local mod_gui          = require("mod-gui")
local qmtt             = require("qmtt")

local add_tag_settings = require("settings/add_tag_settings")
local map_tag_utils    = require("utils/map_tag_utils")

local constants        = require("settings/constants")
local PREFIX           = constants.PREFIX

fav_bar_GUI            = {
    on_click = {}
}

function fav_bar_GUI.init_globals()
    if storage.GUI.fav_bar == nil then
        storage.GUI.fav_bar = {}
    end
    if storage.GUI.fav_bar.players == nil then
        storage.GUI.fav_bar.players = {}
    end
    for index, _ in pairs(game.players) do
        fav_bar_GUI.init_player(index)
        if not storage.GUI.fav_bar.players[index] then
            storage.GUI.fav_bar.players[index] = {
                elements = {},
                favorites = {},
            }
        end
    end
end

function fav_bar_GUI.init_player(player_index)
    local player = game.players[player_index]
    if not storage.player_data then storage.player_data = {} end
    local player_data = storage.player_data[player_index]
    if not player_data then player_data = {} end
    storage.player_data[player_index] = player_data
end

function fav_bar_GUI.on_load()
    --local stub = "stub"
end

function fav_bar_GUI.on_player_created(event)
    fav_bar_GUI.init_player(event.player_index)
end

function fav_bar_GUI.on_gui_click(event)
    if fav_bar_GUI.on_click[event.element.name] then
        fav_bar_GUI.on_click[event.element.name](event)
    end
end

function fav_bar_GUI.on_pre_player_left_game(event)
    -- destroy any guis
    fav_bar_GUI.close(event.player)
    -- remove player from player indexed storage
    local g = mod_gui.get_button_flow(event.player)
    -- g.destroy() -- TODO test!!!!
    storage.GUI.fav_bar.players[event.player.index] = nil
  end

function fav_bar_GUI.on_gui_closed(event)
    --if event.gui_type ~= defines.gui_type.custom then return end
    --if not event.element or not event.element.valid then return end
    --if event.element.name ~= "YARM_site_rename" then return end

    --fav_bar_GUI.on_click.YARM_rename_cancel(event)
    fav_bar_GUI.close(event.player)
end

function fav_bar_GUI.update_ui(player)
    if player then
        local next = next

        -- if a player has no structure then build it
        if not storage.GUI.fav_bar.players[player.index] then
            storage.GUI.fav_bar.players[player.index] = {
                elements = {},
                favorites = {},
            }
        end

        if storage.GUI.fav_bar.players[player.index].elements == nil or
            next(storage.GUI.fav_bar.players[player.index].elements) == nil then
            storage.GUI.fav_bar.players[player.index].elements =
                gui.build(mod_gui.get_button_flow(player), { add_fav_bar_template() })
        end

        -- update the little dude's fave buttond
        fav_bar_GUI.update_fave_buttons(player)
    end
end

-- fill buttons with user fav info
function fav_bar_GUI.update_fave_buttons(player)
    if player then
        local user = storage.GUI.fav_bar.players[player.index]
        if user then
            local user_favorites = user.favorites or {}
            if #user_favorites > 0 then
                for k, v in pairs(user_favorites) do
                    -- match user faves to collection of game favorites
                    -- and create entries for buttons
                    local fave = get_global_favorite_by_id(v)
                    if fave then
                        --local button_slot = user.elements.
                        -- find by caption = k? no this will change on every assign
                        assign_global_favorite_to_gui_button(fave, user, k)
                    end
                end
            end
        end
    end
end

function assign_global_favorite_to_gui_button(fave, user, idx)
    --TODO follow path
    local button_array = user.elements.buttons
    local button = button_array[idx]
    button.icon = fave.icon
    button.name = fave.text
    button.caption = tostring(idx)
    --[[idx = "",
            position = {},
            icon = "",
            displaytext = "",
            description = "",
            last_user = "",]]
end

function get_global_favorite_by_id(idx)
    return storage.qmtt.tags[idx] or nil
end

function fav_bar_GUI.get_player_favorite_buttons(player)
    if player and storage.GUI and storage.GUI.fav_bar and storage.GUI.fav_bar.players then
        --TODO follow path
        -- TODO if not logo button
        local button_array = storage.GUI.fav_bar.players[player.index].elements
        return button_array
    end
    return nil
end

function add_fav_bar_template()
    local child_buttons = {
        {
            type = "button",
            direction = "horizontal",
            save_as = "buttons.toggle_favorite_mode",
            style = PREFIX .. "toggle_favorite_mode_button",
            name = "toggle_favorite_mode",
            handlers = "fav_bar.buttons.toggle_favorite_mode",
            caption = "t",
        }
    }

    -- Dynamically add 10 buttons
    for i = 1, 10 do
        table.insert(child_buttons, {
            type = "button",
            style = "light_blue_button_style", -- Use a light blue style (create this style if it doesn't exist)
            save_as = "buttons.favorite_select_" .. i,
            name = "dynamic_button_" .. i,
            caption = tostring(i),
            handlers = "fav_bar.buttons.fave_action",
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

function fav_bar_GUI.update_players(event)
    -- At t0 on an MP server initial join, on_init may not have run
    if not storage.player_data then return end

    for index, player in pairs(game.players) do
        local player_data = storage.player_data[index]

        if not player_data then
            fav_bar_GUI.init_player(index)
        end

        if event.tick % 300 == 1 + index then -- player_data.gui_update_ticks == 15
            fav_bar_GUI.update_ui(player)
        end
    end
end

local function on_tick_internal(event)
    --ore_tracker.on_tick(event)
    --resmon.entity_cache = ore_tracker.get_entity_cache()

    fav_bar_GUI.update_players(event)
    --fav_bar_GUI.update_forces(event)
end

function fav_bar_GUI.on_tick(event)
    --local wants_profiling = settings.global["YARM-debug-profiling"].value or false
    --if wants_profiling then
    --    on_tick_internal_with_profiling(event)
    --else
    on_tick_internal(event)
    --end
end

function fav_bar_GUI.close(player)
    if player then
        storage.GUI.fav_bar.players[player.index] = nil
    end
end

-- at this point we can be certain that the storage structure has been initialized
-- so be sure to initialize it before using!!!
fav_bar_GUI.open = function(player)
    if player then
        fav_bar_GUI.update_ui(player)
    end
    storage.qmtt = nil
    storage.GUI.AddTag = nil
end

fav_bar_GUI.player_joined = function(event)
    if event then
        fav_bar_GUI.open(event.player)
    end
end

function fav_bar_GUI.on_player_removed(event)
    storage.player_data[event.player_index] = nil
end

fav_bar_GUI.handlers = {
    fav_bar = {
        root_frame = {
            on_gui_closed = function(event)
                storage.GUI.fav_bar.players[event.player_index].elements.root_frame.destroy()
                storage.GUI.fav_bar.players[event.player_index] = {}
            end
        },
        buttons = {
            fave_action = {
                on_gui_click = function(event)
                    --event.element.name
                    --event.player_index
                    --event.button 2=left,,4=right
                    --event.alt/control/shift
                    -- todo determine context of click - left/right - alt/ctrl
                    local schlub = "stub"
                    game.print("you clicked a fave button")
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
