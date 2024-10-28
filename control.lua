local gui = require("lib/gui")

--local event = require("__flib__.event")
local migration = require("__flib__.migration")

local Constants = require("Constants")
local mod_version_migrations = require("mod-version-migrations")
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

-- TODO test
--[[script.on_player_created(function(event)
  AddTagGUI.on_player_created(event)
end)

-- TODO test
script.on_player_removed(function(event)
  AddTagGUI.on_player_removed(event)
end)
]]

gui.add_handlers(AddTagGUI.handlers)
gui.register_handlers()

script.on_event(Constants.events.ADD_TAG_INPUT, CustomInputEventHandler.on_add_tag)
script.on_event(Constants.events.CLOSE_WITH_TOGGLE_MAP, CustomInputEventHandler.on_close_with_toggle_map)
