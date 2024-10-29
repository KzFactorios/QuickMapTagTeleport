local AddTagSettings = require("scripts/Settings/AddTagSettings")

local PREFIX = require("Constants").PREFIX

data:extend({
  {
    name = PREFIX .. "snap-scale",
    type = "int-setting",
    setting_type = "runtime-per-user",
    default_value = AddTagSettings.SNAP_SCALE_DEFAULT,
    minimum_value = AddTagSettings.SNAP_SCALE_MIN,
    maximum_value = AddTagSettings.SNAP_SCALE_MAX
  },
  {
    name = PREFIX .. "new-tag-text",
    type = "string-setting",
    setting_type = "runtime-per-user",
    default_value = AddTagSettings.NEW_TAG_TEXT_DEFAULT,
    allow_blank = true
  },
  {
    name = PREFIX .. "new-tag-icon",
    type = "string-setting",
    setting_type = "runtime-per-user",
    default_value = AddTagSettings.NEW_TAG_ICON_DEFAULT,
    allow_blank = true,
    allowed_values = AddTagSettings.NEW_TAG_ICON_ALLOWED_VALUES
  }
  
  --[[  This setting was removed for the Teleport functionality,
  {
    name = PREFIX .. "use-add-tag-gui",     
    type = "bool-setting",
    setting_type = "runtime-per-user",
    default_value = AddTagSettings.USE_ADD_TAG_GUI_DEFAULT
  }
  ]]
})
