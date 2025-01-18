-- for migrations that should run on script.on_configuration_changed

local cache = require("lib/cache")
local gui = require("lib/gui")

-- MUST be ordered from older to newer
return {
  ["0.1.1"] = function()
    gui.init()
    gui.build_lookup_tables()
  end,
  ["0.1.2"] = function()
    gui.init()
    gui.build_lookup_tables()
  end,
  ["0.2.0"] = function()
    gui.init()
    gui.build_lookup_tables()
    cache.init()
  end,
}