local PREFIX = require("settings/constants").PREFIX

local add_tag_settings = {}

add_tag_settings.TELEPORT_RADIUS_DEFAULT = 8
add_tag_settings.TELEPORT_RADIUS_MIN = 1
add_tag_settings.TELEPORT_RADIUS_MAX = 64

add_tag_settings.getPlayerSettings = function(player)
 
  local t_radius = add_tag_settings.TELEPORT_RADIUS_DEFAULT
  if player.mod_settings[PREFIX .. "teleport-radius"] and
      player.mod_settings[PREFIX .. "teleport-radius"].value then
    t_radius = player.mod_settings[PREFIX .. "teleport-radius"].value
  end

  local favorites_on = true
  if player.mod_settings[PREFIX .. "favorites-on"] and
      player.mod_settings[PREFIX .. "favorites-on"].value then
    favorites_off = player.mod_settings[PREFIX .. "favorites-on"].value
  end


  local settings = {
    teleport_radius = t_radius,
    favorites_on = favorites_on,
  }

  return settings
end

return add_tag_settings