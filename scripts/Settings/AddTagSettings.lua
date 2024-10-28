local PREFIX = require("Constants").PREFIX

local AddTagSettings = {}

AddTagSettings.SNAP_SCALE_DEFAULT = 16
AddTagSettings.SNAP_SCALE_MIN = 1
AddTagSettings.SNAP_SCALE_MAX = 64
AddTagSettings.NEW_TAG_TEXT_DEFAULT = ""
AddTagSettings.NEW_TAG_ICON_DEFAULT = ""
AddTagSettings.NEW_TAG_ICON_ALLOWED_VALUES = {
  "",
  "signal-unknown",
  "signal-dot",
  "signal-info",
  "signal-black",
  "signal-blue",
  "signal-check",
  "signal-cyan",
  "signal-green",
  "signal-grey",
  "signal-pink",
  "signal-red",
  "signal-white",
  "signal-yellow"
}
AddTagSettings.USE_ADD_TAG_GUI_DEFAULT = true

AddTagSettings.getPlayerSettings = function(player)
  local settings = {
    snap_scale = player.mod_settings[PREFIX .. "snap-scale"].value,
    new_tag_text = player.mod_settings[PREFIX .. "new-tag-text"].value,
    use_add_tag_gui = player.mod_settings[PREFIX .. "use-add-tag-gui"].value
  }
  local new_tag_icon = player.mod_settings[PREFIX .. "new-tag-icon"].value
  if (new_tag_icon ~= "") then
    settings.new_tag_icon = {
      type = "virtual",
      name = new_tag_icon
    }
  end
  return settings
end

return AddTagSettings
