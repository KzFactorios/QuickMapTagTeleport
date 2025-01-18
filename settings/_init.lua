local add_tag_settings = require("settings/add_tag_settings")
local PREFIX = require("settings/constants").PREFIX

data:extend({
  {
    name = PREFIX .. "teleport-radius",
    type = "int-setting",
    setting_type = "runtime-per-user",
    default_value = add_tag_settings.TELEPORT_RADIUS_DEFAULT,
    minimum_value = add_tag_settings.TELEPORT_RADIUS_MIN,
    maximum_value = add_tag_settings.TELEPORT_RADIUS_MAX
  },
  {
    name = PREFIX .. "favorites-on",
    type = "bool-setting",
    setting_type = "runtime-per-user",
    default_value = true,
  }
})
