local gui = require("lib/gui")
local migration = require("__flib__.migration")
local wutils = require("wct_utils")

--local serpent = require("serpent")

local mod_version_migrations = require("migrations/mod_version_migrations")
local custom_input_event_handler = require("scripts/event_handlers/custom_input_event_handler")
local add_tag_GUI = require("scripts/gui/add_tag_GUI")
local fav_bar_GUI = require("scripts/gui/fav_bar_GUI")
local qmtt = require("scripts/gui/qmtt")

local constants = require("settings/constants")
--local PREFIX = constants.PREFIX

script.on_init(function()
  storage.GUI = nil
  if storage.GUI == nil then
    storage.GUI = {}
  end
  gui.init()
  gui.build_lookup_tables()
  qmtt.init_QMTT()
  add_tag_GUI.on_init()
  fav_bar_GUI.init_globals()
end)

script.on_load(function()
  --add_tag_GUI.on_init()
  --fav_bar_GUI.on_load()
  gui.build_lookup_tables()

  if game then
    -- GUIs already exist in the player's GUI hierarchy; global.guis contains their indexes
    for _, player in pairs(game.players) do
      --[[if storage.GUI.guis and global.guis[player.index] then
        local gui = player.gui.screen["my_persistent_gui"]
        if gui then
            -- Example: Rebind any event handlers if needed
            -- (if buttons or other interactive elements exist)
        end
    end--]]
    end
  end
end)

script.on_configuration_changed(function(event)
  --gui.init()
  migration.on_config_changed(event, mod_version_migrations)
  --fav_bar_GUI.init_globals()
  --qmtt.on_configuration_changed(event)
  storage.GUI = {}
end)

script.on_event(defines.events.on_player_created, function(event)
  add_tag_GUI.on_player_created(event)
  fav_bar_GUI.on_player_created(event)
  qmtt.on_player_created(event)
end)

script.on_event(defines.events.on_pre_player_left_game, function(event)
  add_tag_GUI.on_pre_player_left_game(event)
  fav_bar_GUI.on_pre_player_left_game(event)
  qmtt.on_pre_player_left_game(event)
end)

--script.on_event(defines.events.on_player_removed, add_tag_GUI.on_player_removed)

-- Run Once! script.on_event(defines.events.on_tick, nil)
script.on_event(defines.events.on_tick, function(event)
  if game then
    --[[ Fix code for stuck dialogs - to be run in the console
    for _, player in pairs(game.players) do
      for _, g in pairs(player.gui.screen.children) do
        if g.name == "gui-tag-edit" then
          g.destroy()
        end
      end
    end
      ]]
    --storage.qmtt.tags = nil
    script.on_event(defines.events.on_tick, nil)
  end
end)

-- NOTHING IS HITTING THIS!!!!
script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "save_tag" then
    local player = game.get_player(event.player_index)
    if player then
      local frame = player.gui.screen["custom-tag-editor"]

      if frame then
        local new_text = frame["tag_text"].text
        player.print("Saving tag with text: " .. new_text)
        frame.destroy()
      end
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local stub = "stub"
end)

--script.on_event(defines.events.on_chart)






-- TBD
script.on_event(defines.events.script_raised_teleported, custom_input_event_handler.on_teleport)
script.on_event(constants.events.CLOSE_WITH_TOGGLE_MAP, custom_input_event_handler.on_close_with_toggle_map)

--local _maptag_editor_open = script.generate_event_name()
--add_tag_GUI._maptag_editor_open = _maptag_editor_open
--script.on_event(_maptag_editor_open, custom_input_event_handler.on_maptag_editor_open)
script.on_event(constants.events.OPEN_STOCK_GUI, custom_input_event_handler.on_open_stock_gui)

script.on_event(constants.events.ADD_TAG_INPUT, custom_input_event_handler.on_add_tag)
--script.on_event(constants.events.ED_EX_INPUT, custom_input_event_handler.on_ed_ex_input)

script.on_event(defines.events.on_player_controller_changed, function(event)
  local stub = "stub"
  if game then
    local player = game.players[event.player_index]
    if player then
      if player.render_mode ~= defines.render_mode.chart and 
        storage.GUI and
        storage.GUI.AddTag and
        storage.GUI.AddTag.players and
        storage.GUI.AddTag.players[event.player_index] and 
        #storage.GUI.AddTag.players[event.player_index] > 0
        then
        storage.GUI.AddTag.players[event.player_index].close()
        storage.GUI.AddTag.players[event.player_index] = {}
      end
    end
  end

  -- check for fav bar
  --[[if game then
    local player = game.players[event.player_index]
    if player then
      player.print(string.format("Old_Type %s", event.old_type))
      wutils.print_view_data(player)

      if not fav_bar_GUI.is_open then
        fav_bar_GUI.open(player)
      end
    end
  end]]
end)

script.on_event(defines.events.on_player_changed_force, function(event)
  local player = game.get_player(event.player_index)
  if player then
    wutils.print_view_data(player)
  end
end)









gui.add_handlers(add_tag_GUI.handlers)
gui.add_handlers(fav_bar_GUI.handlers)
gui.register_handlers()







-- Get a specific force (like the player force)
-- local player_force = game.forces["player"]
--local tags = player_force.get_tagged_objects(game.surfaces[1])  -- or whatever surface you want


-- Get all tags for current force on a surface
--local tags = force.get_chart_tags(surface)

-- Or if you want all tags for all forces:
--[[for _, force in pairs(game.forces) do
      local tags = force.get_chart_tags(surface)
      for _, tag in pairs(tags) do
        -- tag is a LuaCustomChartTag object
        game.print(string.format("Tag at position {%d, %d} with text: %sm",
          tag.position.x, tag.position.y, tag.text or ""))
      end
    end]]

-- Ensure serpent is available for table serialization

-- Function to print event details
--[[local function print_event(event_name, event_data)
  -- Serialize the event data into a readable format
  local serialized_data = serpent.block(event_data, { comment = false })
  -- Print the event name and data to the in-game console
  game.print("Event: " .. event_name .. "\n" .. serialized_data .. "\n")
end]]

-- Iterate over all defined events in Factorio
--[[for event_name, event_id in pairs(defines.events) do
  -- Register an event handler for each event
  if (event_name ~= "on_tick") then
    script.on_event(event_id, function(event_data)
      print_event(event_name, event_data)
    end)
  end
end
]]
