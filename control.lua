local gui = require("lib/gui")
local migration = require("__flib__.migration")

local Constants = require("Constants")
local mod_version_migrations = require("migrations/mod-version-migrations")
local CustomInputEventHandler = require("scripts/EventHandlers/CustomInputEventHandler")
local AddTagGUI = require("scripts/GUI/AddTagGUI")

script.on_init(function()
  gui.init()
  gui.build_lookup_tables()
  AddTagGUI.on_init()
end)

script.on_load(function()
  gui.build_lookup_tables()
end)

-- TODO test
script.on_configuration_changed(function(event)
  migration.on_config_changed(event, mod_version_migrations)
end)
script.on_event(defines.events.on_player_created, AddTagGUI.on_player_created)
script.on_event(defines.events.on_player_removed, AddTagGUI.on_player_removed)
script.on_event(Constants.events.ADD_TAG_INPUT, CustomInputEventHandler.on_add_tag)
script.on_event(Constants.events.CLOSE_WITH_TOGGLE_MAP, CustomInputEventHandler.on_close_with_toggle_map)

gui.add_handlers(AddTagGUI.handlers)
gui.register_handlers()