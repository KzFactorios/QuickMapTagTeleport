local PREFIX = require("settings/constants").PREFIX

local add_tag_settings = {}

add_tag_settings.SNAP_SCALE_DEFAULT = 4
add_tag_settings.SNAP_SCALE_MIN = 1
add_tag_settings.SNAP_SCALE_MAX = 64

add_tag_settings.NEW_TAG_TEXT_DEFAULT = ""
add_tag_settings.NEW_TAG_ICON_DEFAULT = ""
add_tag_settings.NEW_TAG_ICON_ALLOWED_VALUES = {
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

add_tag_settings.TELEPORT_RADIUS_DEFAULT = 8
add_tag_settings.TELEPORT_RADIUS_MIN = 1
add_tag_settings.TELEPORT_RADIUS_MAX = 64

add_tag_settings.USE_ADD_TAG_GUI_DEFAULT = true

add_tag_settings.getPlayerSettings = function(player)
  local snap = add_tag_settings.SNAP_SCALE_DEFAULT
  if player.mod_settings[PREFIX .. "snap-scale"] and
      player.mod_settings[PREFIX .. "snap-scale"].value then
    snap = player.mod_settings[PREFIX .. "snap-scale"].value
  end

  local newtag = ""
  if player.mod_settings[PREFIX .. "new-tag-text"] and
      player.mod_settings[PREFIX .. "new-tag-text"].value
  then
    newtag = player.mod_settings[PREFIX .. "new-tag-text"].value
  end

  local t_radius = add_tag_settings.TELEPORT_RADIUS_DEFAULT
  if player.mod_settings[PREFIX .. "teleport-radius"] and
      player.mod_settings[PREFIX .. "teleport-radius"].value then
    t_radius = player.mod_settings[PREFIX .. "teleport-radius"].value
  end

  local settings = {
    snap_scale = snap,
    new_tag_text = newtag,
    teleport_radius = t_radius,
    use_add_tag_gui = add_tag_settings.USE_ADD_TAG_GUI_DEFAULT
    -- not necessary for current implementation - we are not allowing auto-tags without a dialog interface
    -- use_add_tag_gui = player.mod_settings[PREFIX .. "use-add-tag-gui"].value
  }

  local new_tag_icon = ""
  if player.mod_settings[PREFIX .. "new-tag-icon"] and
      player.mod_settings[PREFIX .. "new-tag-icon"].value then
    new_tag_icon = player.mod_settings[PREFIX .. "new-tag-icon"].value
  end

  if (new_tag_icon ~= "") then
    settings.new_tag_icon = {
      type = "virtual",
      name = new_tag_icon
    }
  end

  return settings
end

return add_tag_settings
