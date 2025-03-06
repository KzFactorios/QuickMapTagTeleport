local PREFIX = require("settings/constants").PREFIX

local add_tag_settings = {}

add_tag_settings.TELEPORT_RADIUS_DEFAULT = 8
add_tag_settings.TELEPORT_RADIUS_MIN = 1
add_tag_settings.TELEPORT_RADIUS_MAX = 64

--- usage: local settings = add_tag_settings.getPlayerSettings(player)
--- if setting.favorites_on
--- replaces: player.mod_settings[PREFIX ..
add_tag_settings.getPlayerSettings = function(player)
  if not player then
    return {
      teleport_radius = 8,
      favorites_on = true,
      destination_msg_on = true,
    }
  end

  local t_radius = add_tag_settings.TELEPORT_RADIUS_DEFAULT
  if player.mod_settings[PREFIX .. "teleport-radius"] and
      player.mod_settings[PREFIX .. "teleport-radius"].value ~= nil then
    t_radius = player.mod_settings[PREFIX .. "teleport-radius"].value
  end

  local favorites_on = true
  if player.mod_settings[PREFIX .. "favorites-on"] and
      player.mod_settings[PREFIX .. "favorites-on"].value ~= nil then
    favorites_on = player.mod_settings[PREFIX .. "favorites-on"].value
  end

  local destination_msg_on = true
  if player.mod_settings[PREFIX .. "destination-msg-on"] and
      player.mod_settings[PREFIX .. "destination-msg-on"].value ~= nil then
    destination_msg_on = player.mod_settings[PREFIX .. "destination-msg-on"].value
  end

  local settings = {
    teleport_radius = t_radius,
    favorites_on = favorites_on,
    destination_msg_on = destination_msg_on,
  }

  return settings
end

return add_tag_settings
