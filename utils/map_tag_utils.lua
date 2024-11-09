local PREFIX = require("settings/constants").PREFIX
local math = require("__flib__.math")

local map_tag_utils = {}

map_tag_utils.create_new_tag = function(player, position, text, icon)
  if (icon == nil and text == "") then
    player.print({ PREFIX .. "empty-tag-error" })
    return
  end
  local tag = {
    position = position,
    text = text,
    last_user = player
  }
  if (icon ~= nil) then
    tag.icon = icon
  end
  return player.force.add_chart_tag(player.surface, tag)
end

map_tag_utils.snap_position = function(position, snap_scale)
  return {
    x = math.round(position.x / snap_scale) * snap_scale,
    y = math.round(position.y / snap_scale) * snap_scale
  }
end

map_tag_utils.position_has_collisions = function(position, snap_scale, player)
  local collision_area = {
    left_top = {
      x = position.x - snap_scale + 0.1,
      y = position.y - snap_scale + 0.1
    },
    right_bottom = {
      x = position.x + snap_scale - 0.1,
      y = position.y + snap_scale - 0.1
    }
  }
  local colliding_tags = player.force.find_chart_tags(player.surface, collision_area)
  return next(colliding_tags) ~= nil
end

map_tag_utils.position_can_be_tagged = function(position, player)
  local chunk_position = {
    x = math.floor(position.x / 32),
    y = math.floor(position.y / 32)
  }
  return player.force.is_chunk_charted(player.surface, chunk_position)
end

return map_tag_utils
