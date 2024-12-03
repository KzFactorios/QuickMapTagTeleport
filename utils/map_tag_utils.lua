local PREFIX = require("settings/constants").PREFIX
local math   = require("__flib__/math")
local wutils = require("wct_utils")
local table  = require("__flib__/table")
local fave   = require("scripts/gui/fave")
local qmtt   = require("scripts/gui/qmtt")

local map_tag_utils = {}

local next = next

-- note that we should have already updated tags and qmtts (displaytext/description)
-- we are just making sure objects are correctly assigned to faves
function assign_objects_to_favorites(is_favorite, player, pos_idx)
  -- get all the potential pieces/parts
  local player_index = player.index
  local fave_places = storage.qmtt.GUI.fav_bar.players[player_index]
      .fave_places[player.surface_index]
  local existing_fave = wutils.find_element_by_key_and_value(
    fave_places, "_pos_idx", pos_idx)

  local surfs = storage.qmtt.surfaces[player.surface_index]
  local matching_qmtt = wutils.find_element_by_key_and_value(
    surfs.extended_tags, "idx", pos_idx)
  local matching_chart_tag = wutils.find_chart_tag_by_pos_idx(
    surfs.chart_tags, pos_idx)

  -- if favorite then update existing or create new
  if is_favorite then
    if existing_fave then
      existing_fave._pos_idx = pos_idx
      existing_fave._surface_id = player.surface_index
    else
      local new_index = fave.get_next_open_fave_places_index
      if new_index ~= -1 then
        existing_fave = fave.create_fave(pos_idx, player.surface_index, matching_chart_tag, matching_qmtt)
        fave_places[new_index] = existing_fave
      else
        -- TODO put max faves in a setting
        game.print("You already have max number of faves")
        return
      end
    end
  else
    -- if not favorite then remove existing, update
    if existing_fave then
      if matching_qmtt then
        local idx = wutils.get_element_index(matching_qmtt, 'faved_by_players', player_index)
        if idx > 0 then
          wutils.remove_element(matching_qmtt.faved_by_players, player_index)
        end
      end

      local idx = wutils.get_element_index(fave_places, '_pos_idx', existing_fave._pos_idx)
      fave_places[idx] = {}
    end
    -- else - do nothing
  end
end

function establish_working_tag(input_tag, player)
  -- find a matching tag - were we editing?
  local current_pool = player.force.find_chart_tags(player.surface)
  local existing_tag = wutils.find_element_by_position(current_pool, "position", input_tag.position)

  -- working_tag will hold our intended tag information
  local working_tag = nil
  if existing_tag then
    existing_tag.text = input_tag.text
    existing_tag.last_user = input_tag.last_user
    existing_tag.icon = input_tag.icon

    working_tag = existing_tag
  else
    -- NEW TAG
    working_tag = player.force.add_chart_tag(player.surface, input_tag)
  end

  return working_tag
end

function establish_working_qmtt(working_tag, player, is_favorite, display_text, description)
  if working_tag then
    local player_index = player.index
    local pos_idx = wutils.format_idx_from_position(working_tag.position)
    local elements = storage.qmtt.GUI.AddTag.players[player_index].elements

    if elements then
      local existing_q = wutils.find_element_by_key_and_value(
        storage.qmtt.surfaces[player.surface_index].extended_tags, "idx", pos_idx)

      if existing_q then
        existing_q.idx = pos_idx
        existing_q.surface_id = player.surface_index
        existing_q.position = working_tag.position
        existing_q.faved_by_players = {}
        if is_favorite and not wutils.tableContainsKey(existing_q.faved_by_players, player_index) then
          table.insert(existing_q.faved_by_players, player_index)
        end
        existing_q.fave_displaytext = display_text
        existing_q.fave_description = description
      else
        local _qmtt = {
          idx = pos_idx,
          surface_id = player.surface_index,
          position = working_tag.position,
          faved_by_players = {},
          fave_displaytext = display_text,
          fave_description = description,
        }
        if is_favorite then
          table.insert(_qmtt.faved_by_players, player_index)
        end
        local et_index = #storage.qmtt.surfaces[player.surface_index].extended_tags
        storage.qmtt.surfaces[player.surface_index].extended_tags[et_index + 1] = table.deep_copy(_qmtt)
        existing_q = table.deep_copy(_qmtt)
      end
    end
  end
end

-- "add_chart_tag" blindly adds new tags, it DOES NOT update!
-- enforce that dupe tags are not created
function map_tag_utils.save_tag(player, position, text, icon, display_text, description, favorite)
  -- tag must  have an icon or text!
  if (icon == nil and text == "") then
    player.print({ PREFIX .. "empty-tag-error" })
    return
  end

  -- a new tag based on input
  local input_tag = {
    position = position,
    text = text,
    last_user = player,
  }
  if (icon ~= nil) then
    input_tag.icon = icon
  end

  establish_working_qmtt(
    establish_working_tag(input_tag, player), player, favorite, display_text, description)

  -- AND DEAL WITH FAVES
  -- note that we have already updated tags and qmtts
  assign_objects_to_favorites(favorite, player, wutils.format_idx_from_position(position))

  fav_bar_GUI.update_ui(player)
  control.update_uis(player)
end

map_tag_utils.snap_position = function(position, snap_scale)
  return {
    x = math.round(position.x / snap_scale) * snap_scale,
    y = math.round(position.y / snap_scale) * snap_scale
  }
end

-- returns the position of the first colliding tag in the area
function map_tag_utils.position_has_colliding_tags(position, snap_scale, player)
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
  if colliding_tags and #colliding_tags > 0 then
    return colliding_tags[1].position
  end

  return nil
  --TODO RESEARCH return next(colliding_tags) ~= nil
end

-- By virtue of the gui opening...
-- we know the spot has been AOK'd for being clear of other tags
-- and it has not yet been cleared for not having structures in
-- the way. So ensure we are "clear to land" or find the closest
-- spot to where we think we were going
-- aka check if we are in a structure, teleport closest to the spot we have already selected
function map_tag_utils.teleport_player_to_closest_position(player, target_position, search_radius)
  local surface = player.surface
  local return_pos = nil
  local return_msg = "No valid teleport position found within the search radius. Please select another location."

  -- Find a non-colliding position near the target position
  local closest_position = surface.find_non_colliding_position(
    player.character.name, -- Prototype name of the player's character
    target_position,       -- Target position to search around
    search_radius,         -- Search radius in tiles
    4                      -- Precision (smaller values = more precise, but slower) Range 0.01 - 8
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
function map_tag_utils.position_can_be_tagged(position, player)
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
