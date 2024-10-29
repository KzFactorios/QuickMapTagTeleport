-- for migrations that should run on script.on_configuration_changed

local gui = require("lib/gui")
local AddTagGUI = require("scripts/GUI/AddTagGUI")

-- MUST be ordered from older to newer
return {
  ["0.1.0"] = function()
    gui.init()
    gui.build_lookup_tables()
    AddTagGUI.on_init()
  end
}
