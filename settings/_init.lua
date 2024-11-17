local add_tag_settings = require("settings/add_tag_settings")

local PREFIX = require("settings/constants").PREFIX

data:extend({
  {
    name = PREFIX .. "snap-scale",
    type = "int-setting",
    setting_type = "runtime-per-user",
    default_value = add_tag_settings.SNAP_SCALE_DEFAULT,
    minimum_value = add_tag_settings.SNAP_SCALE_MIN,
    maximum_value = add_tag_settings.SNAP_SCALE_MAX
  },
  {
    name = PREFIX .. "new-tag-text",
    type = "string-setting",
    setting_type = "runtime-per-user",
    default_value = add_tag_settings.NEW_TAG_TEXT_DEFAULT,
    allow_blank = true
  },
  {
    name = PREFIX .. "new-tag-icon",
    type = "string-setting",
    setting_type = "runtime-per-user",
    default_value = add_tag_settings.NEW_TAG_ICON_DEFAULT,
    allow_blank = true,
    allowed_values = add_tag_settings.NEW_TAG_ICON_ALLOWED_VALUES
  },
  {
    name = PREFIX .. "teleport-radius",
    type = "int-setting",
    setting_type = "runtime-per-user",
    default_value = add_tag_settings.TELEPORT_RADIUS_DEFAULT,
    minimum_value = add_tag_settings.TELEPORT_RADIUS_MIN,
    maximum_value = add_tag_settings.TELEPORT_RADIUS_MAX
  }

  --[[  This setting was removed for the Teleport functionality,
  {
    name = PREFIX .. "use-add-tag-gui",
    type = "bool-setting",
    setting_type = "runtime-per-user",
    default_value = add_tag_settings.USE_ADD_TAG_GUI_DEFAULT
  }
  ]]
})
