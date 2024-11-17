local gui = require("lib/gui")
local migration = require("__flib__.migration")

local mod_version_migrations = require("migrations/mod_version_migrations")
local custom_input_event_handler = require("scripts/event_handlers/custom_input_event_handler")
local add_tag_GUI = require("scripts/gui/add_tag_GUI")

local constants = require("settings/constants")

script.on_init(function()
  gui.init()
  gui.build_lookup_tables()
  add_tag_GUI.on_init()
end)

script.on_load(function()
  gui.build_lookup_tables()  
end)

script.on_configuration_changed(function(event)
  migration.on_config_changed(event, mod_version_migrations)
end)

script.on_event(defines.events.on_player_created, add_tag_GUI.on_player_created)

script.on_event(defines.events.on_player_removed, add_tag_GUI.on_player_removed)
-- TBD
script.on_event(defines.events.script_raised_teleported, custom_input_event_handler.on_teleport)

script.on_event(constants.events.ADD_TAG_INPUT, custom_input_event_handler.on_add_tag)
script.on_event(constants.events.CLOSE_WITH_TOGGLE_MAP, custom_input_event_handler.on_close_with_toggle_map)

gui.add_handlers(add_tag_GUI.handlers)

gui.register_handlers()


-- run once
script.on_event(defines.events.on_tick, function(event)
  if game then    
    script.on_event(defines.events.on_tick, nil)
  end
end)
