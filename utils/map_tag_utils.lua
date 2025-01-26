local PREFIX           = require("settings/constants").PREFIX
local add_tag_settings = require("settings/add_tag_settings")
local fave             = require("scripts/gui/fave")
local table            = require("__flib__/table")
local math             = require("__flib__/math")
local wutils           = require("wct_utils")

local map_tag_utils    = {}

-- note that we should have already updated tags and qmtts (displaytext/description)
-- we are just making sure objects are correctly assigned to faves
function map_tag_utils.curate_player_fave_places(is_favorite, player, pos_idx)
  if player then
    -- get all the potential pieces/parts
    local player_index = player.index
    local fave_places = storage.qmtt.GUI.fav_bar.players[player_index]
        .fave_places[player.physical_surface_index]
    local existing_fave = wutils.find_element_by_key_and_value(
      fave_places, "_pos_idx", pos_idx)

    -- ensure favorite exists in fave places
    if is_favorite then
      cache.set_player_selected_fave(player, pos_idx)

      if not existing_fave then
        local new_index = fave.get_next_open_fave_places_index(player)
        if new_index ~= -1 then
          existing_fave = fave.create_fave(pos_idx, player.physical_surface_index)
          fave_places[new_index] = existing_fave
        else
          -- TODO put max faves in a setting
          game.print("You have reached the max number of allowable favorites")
          return
        end
      end
    else
      --reset selected fave
      cache.set_player_selected_fave(player, "")

      -- remove the existing fave from the player's fave_places
      if existing_fave then
        local fave_idx = wutils.get_element_index(fave_places, "_pos_idx", existing_fave._pos_idx)
        if fave_idx > 0 then
          fave_places[fave_idx] = {}
        end
      end
    end
  end
end

--- find the existing chart tag or create a new one to work with based on input tag
function wutils.establish_working_tag(input_tag, player)
  if player then
    local current_pool = player.force.find_chart_tags(player.surface)
    local existing_tag = wutils.find_element_by_position(current_pool, "position", input_tag.position)
    -- working_tag will hold our intended tag information
    local working_tag = nil

    -- register tag with player forces tags
    if existing_tag then
      existing_tag.text = input_tag.text
      existing_tag.last_user = input_tag.last_user
      existing_tag.icon = input_tag.icon

      working_tag = existing_tag
    else
      working_tag = player.force.add_chart_tag(player.surface, input_tag)
      -- register working tag with qmtt.surfaces
      if working_tag ~= nil then
        if wutils.find_element_by_position(storage.qmtt.surfaces[player.physical_surface_index].chart_tags, "position", working_tag.position) == nil then
          table.insert(storage.qmtt.surfaces[player.physical_surface_index].chart_tags, working_tag)
        end
      end
    end

    return working_tag
  end
  return nil
end

--- Adds or updates a qmtt based on the working chart tag. Updates the faved_by_players list
function wutils.establish_working_qmtt(working_tag, player, is_favorite, display_text, description)
  if player and working_tag then
    local player_index = player.index
    local pos_idx = wutils.format_idx_from_position(working_tag.position)
    local existing_q = wutils.find_element_by_key_and_value(
      storage.qmtt.surfaces[player.physical_surface_index].extended_tags, "idx", pos_idx)

    if not existing_q then
      local _qmtt = {
        idx = pos_idx,
        surface_id = player.physical_surface_index,
        position = working_tag.position,
        faved_by_players = {},
      }
      table.insert(storage.qmtt.surfaces[player.physical_surface_index].extended_tags, _qmtt)
      --local et_index = #storage.qmtt.surfaces[player.physical_surface_index].extended_tags
      --storage.qmtt.surfaces[player.physical_surface_index].extended_tags[et_index + 1] = _qmtt
      existing_q = _qmtt
    end

    existing_q.idx = pos_idx
    existing_q.surface_id = player.physical_surface_index
    existing_q.position.x = working_tag.position.x
    existing_q.position.y = working_tag.position.y
    existing_q.fave_displaytext = display_text
    existing_q.fave_description = description

    if is_favorite and not wutils.tableContainsKey(existing_q.faved_by_players, player_index) then
      table.insert(existing_q.faved_by_players, player_index)
    elseif not is_favorite and wutils.tableContainsKey(existing_q.faved_by_players, player_index) then
      wutils.remove_element(existing_q.faved_by_players, player_index)
    end
  end
end

-- "add_chart_tag" blindly adds new tags, it DOES NOT update!
function map_tag_utils.save_tag(player, position, text, icon, display_text, description, favorite)
  if player then
    -- tag must  have an icon or text!
    if (icon == nil and text == "") then
      player.print({ PREFIX .. "empty-tag-error" })
      return
    end

    -- a new tag based on input
    local input_tag = {
      position = position,
      text = text or "",
      last_user = player,
    }
    if (icon ~= nil) then
      input_tag.icon = icon
    end

    local working_tag = wutils.establish_working_tag(input_tag, player)
    wutils.establish_working_qmtt(working_tag, player, favorite, display_text, description)

    -- Deal with faves, note that we have already updated tags and qmtts
    map_tag_utils.curate_player_fave_places(favorite, player, wutils.format_idx_from_position(position))

    cache.reset_surface_chart_tags(player)
  end
end

map_tag_utils.snap_position = function(position, snap_scale)
  return {
    x = math.round(position.x / snap_scale) * snap_scale,
    y = math.round(position.y / snap_scale) * snap_scale
  }
end

-- returns the position of the first colliding tag in the area
function map_tag_utils.position_has_colliding_tags(position, snap_scale, player)
  if player then
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
  end

  return nil
  --TODO RESEARCH return next(colliding_tags) ~= nil
end

--- evaluates player surface and determines if player is in space
function map_tag_utils.is_on_space_platform(player)
  if player and player.surface then
    if player.surface.map_gen_settings then
      local map_gen = player.surface.map_gen_settings
      -- Planets have either default/custom terrain gen or specific planet presets
      return map_gen.preset == "space-platform" or map_gen.preset == "space"
    end
  end
  return false
end

-- By virtue of the gui opening...
-- we know the spot has been AOK'd for being clear of other tags
-- and it has not yet been cleared for not having structures in
-- the way. So ensure we are "clear to land" or find the closest
-- spot to where we think we were going
-- aka check if we are in a structure, teleport closest to the spot we have already selected
-- Player's are not allowed to teleport on space platforms!
function map_tag_utils.teleport_player_to_closest_position(player, target_position)
  if player then
    if map_tag_utils.is_on_space_platform(player) then
      return nil,
          "The surgeon general has determined that teleportation on space platforms may incur death and is not authorized!"
    end

    storage.qmtt.player_data[player.index].render_mode = player.render_mode
    local surface = player.surface
    local return_pos = nil
    local return_msg =
    "No valid teleport position found within the teleport radius. Please select another location or you could try increasing the search radius in settings. The hive mind discourages this practice as it will reduce the accuracy of your teleport landing points."

    local teleport_radius = player.mod_settings[PREFIX .. "teleport-radius"].value
    if teleport_radius < add_tag_settings.TELEPORT_RADIUS_MIN then
      teleport_radius = add_tag_settings.TELEPORT_RADIUS_MIN
    elseif teleport_radius > add_tag_settings.TELEPORT_RADIUS_MAX then
      teleport_radius = add_tag_settings.TELEPORT_RADIUS_MAX
    end

    -- Find a non-colliding position near the target position
    local closest_position = surface.find_non_colliding_position(
      player.character.name, -- Prototype name of the player's character
      target_position,       -- Target position to search around
      teleport_radius,       -- Search radius in tiles
      4                      -- Precision (smaller values = more precise, but slower) Range 0.01 - 8
    -- fastest but coarse, use 2-4
    -- balanced, use 6
    -- high precision, slowest, use 8
    )

    local valid = player.surface.can_place_entity({ name = "character", position = closest_position })

    -- If a position is found, teleport the player there
    if closest_position and valid then
      if player.teleport(closest_position, player.surface) then
        return_pos = closest_position
        return_msg = ""
        -- note that caller is currently handling raising of teleport event
      end
    end

    return return_pos, return_msg
  end
  return nil, ""
end

-- Have we selected a point that is not in the fog of war?
function map_tag_utils.position_can_be_tagged(position, player)
  if player then
    local chunk_position = {
      x = math.floor(position.x / 32),
      y = math.floor(position.y / 32)
    }
    return player.force.is_chunk_charted(player.surface, chunk_position)
  end
  return false
end

map_tag_utils.Dump_Data = function()
  --game.write_file("global_data_dump.txt", serpent.block(global))
end

return map_tag_utils
