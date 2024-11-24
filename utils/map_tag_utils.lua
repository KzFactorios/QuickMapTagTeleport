local PREFIX = require("settings/constants").PREFIX
local math = require("__flib__.math")
local wutils = require("wct_utils")
local table = require("__flib__.table")

local map_tag_utils = {}

local next = next

function map_tag_utils.save_tag(player, position, text, icon, display_text, description, favorite)
  -- tag must  have an icon or text!
  if (icon == nil and text == "") then
    player.print({ PREFIX .. "empty-tag-error" })
    return
  end

  -- propose a new tag based on input
  local tag = {
    position = position,
    text = text,
    last_user = player
  }
  if (icon ~= nil) then
    tag.icon = icon
  end

  -- "add_chart_tag" blindly adds new tags, it DOES NOT update!
  -- enforce that dupe tags are not created
  local current_pool = player.force.find_chart_tags(player.surface)
  local existing_tag = wutils.find_element_by_position(current_pool, "position", tag.position)
  local working_tag = nil

  -- UPDATE
  if existing_tag then
    -- update in memory?
    -- read-only existing_tag.position = tag.position
    existing_tag.text = tag.text
    existing_tag.last_user = tag.last_user
    existing_tag.icon = tag.icon
    working_tag = existing_tag

    -- NEW TAG
  else
    working_tag = player.force.add_chart_tag(player.surface, tag)
  end


  -- if chart_tag is nil then it could not be created - could it be updated though?
  -- examine chart tags to see if it has been updated yet


  -- NOW DEAL WITH QMTT
  if working_tag then
    local player_index = player.index
    local pos_idx = wutils.format_idx_from_position(working_tag.position)
    local elements = storage.GUI.AddTag.players[player_index].elements

    if elements then
      local fave_list = {}
      if favorite then fave_list = { player } else fave_list = {} end
      --local existing_q = qmtt.get_matching_qmtt_by_position(chart_tag.position, player)
      --[[if not storage.qmtt or not storage.qmtt.tags then
        qmtt.init_QMTT()
    end]]
    
      local existing_q = wutils.find_element_by_key_and_value(storage.qmtt.tags, "idx", pos_idx)
      if existing_q then
        existing_q.idx = pos_idx
        existing_q.position = working_tag.position
        existing_q.favorite_list = fave_list
        existing_q.fave_displaytext = display_text
        existing_q.fave_description = description
      else
        local _qmtt = {
          idx = pos_idx,
          position = working_tag.position,
          favorite_list = fave_list,
          fave_displaytext = display_text,
          fave_description = description,
        }
        storage.qmtt.tags[#storage.qmtt.tags + 1] = table.deep_copy(_qmtt)
      end

      local stub = "stub"
    end
  end

  return working_tag
end

map_tag_utils.snap_position = function(position, snap_scale)
  return {
    x = math.round(position.x / snap_scale) * snap_scale,
    y = math.round(position.y / snap_scale) * snap_scale
  }
end

map_tag_utils.position_has_colliding_tags = function(position, snap_scale, player)
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
    6                      -- Precision (smaller values = more precise, but slower) Range 0.01 - 8
  -- fastest but coarse, use 2-4
  -- balanced, use 6
  -- high precision, slowest, use 8
  )

  -- If a position is found, teleport the player there
  if closest_position then
    if player.teleport(closest_position, player.surface) then
      return_pos = closest_position
      return_msg = ""
      -- note that caller is currently handling raising of teleport event
    end
  end

  return return_pos, return_msg
end

-- Have we selected a point that is not in the fog of war?
map_tag_utils.position_can_be_tagged = function(position, player)
  local chunk_position = {
    x = math.floor(position.x / 32),
    y = math.floor(position.y / 32)
  }
  return player.force.is_chunk_charted(player.surface, chunk_position)
end

map_tag_utils.Dump_Data = function()
  --game.write_file("global_data_dump.txt", serpent.block(global))
end

































return map_tag_utils
