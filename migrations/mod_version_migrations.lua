-- for migrations that should run on script.on_configuration_changed

local gui = require("lib/gui")
local add_tag_GUI = require("scripts/gui/add_tag_GUI")

-- MUST be ordered from older to newer
return {
  --[[["0.1.0"] = function()
    gui.init()
    gui.build_lookup_tables()
    add_tag_GUI.on_init()
  end,]]
  ["0.1.1"] = function()
    gui.init()
    gui.build_lookup_tables()
  end,
  ["0.1.2"] = function()
    gui.init()
    gui.build_lookup_tables()
  end
}

