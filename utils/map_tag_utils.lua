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

map_tag_utils.position_has_tag_collisions = function(position, snap_scale, player)
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

-- By virtue of the gui opening...
-- we know the spot has been AOK'd for being clear of other tags
-- but it has not yet been cleared for not having structures in
-- the way. So ensure we are "clear to land" or find the closest
-- spot to where we think we were going
-- aka check if we are in a structure, teleport closest to the spot we have already selected
map_tag_utils.teleport_player_to_closest_position = function(player, target_position, search_radius)
  local surface = player.surface
  local return_pos = nil
  local return_msg = "No valid teleport position found within the search radius. Please select another location."

  -- Find a non-colliding position near the target position
  local closest_position = surface.find_non_colliding_position(
    player.character.name, -- Prototype name of the player's character
    target_position,       -- Target position to search around
    search_radius,         -- Search radius in tiles
    2                      -- Precision (smaller values = more precise, but slower
  )

  -- If a position is found, teleport the player there
  if closest_position then
    if player.teleport(closest_position) then
      return_pos = closest_position
      return_msg = ""
      -- note that caller is currently handling raising of teleport event
    end
  end

  return return_pos, return_msg
end

map_tag_utils.position_can_be_tagged = function(position, player)
  local chunk_position = {
    x = math.floor(position.x / 32),
    y = math.floor(position.y / 32)
  }
  return player.force.is_chunk_charted(player.surface, chunk_position)
end

return map_tag_utils
