local add_tag_settings = require("settings/add_tag_settings")
local add_tag_GUI = require("scripts/gui/add_tag_GUI")
local fav_bar_GUI = require("scripts/gui/fav_bar_GUI")
local edit_fave_GUI = require("scripts/gui/edit_fave_GUI")
local map_tag_utils = require("utils/map_tag_utils")

local custom_input_event_handler = {}

-- when right click is performed on the map. Our trigger for opening our dialog
function custom_input_event_handler.on_add_tag(event)
  local player = game.get_player(event.player_index)

  if ((player and player.render_mode == defines.render_mode.chart) and (not add_tag_GUI.is_open(player))) then
    local settings = add_tag_settings.getPlayerSettings(player)
    local position = map_tag_utils.snap_position(event.cursor_position, settings.snap_scale)
    local position_can_be_tagged = map_tag_utils.position_can_be_tagged(position, player)

    -- TODO work on better snap_scale. I am either getting too far
    -- inside the indicator or too far away. Opted for outside as
    -- I think the UX demands that if you light up the indicator,
    -- you should be getting what you are expecting. Also we are
    -- dealing with a square indicator and a round selector
    if position_can_be_tagged then
      local position_has_colliding_tags =
          map_tag_utils.position_has_colliding_tags(position, 7.1, player)
      if position_has_colliding_tags then
        -- we are editing, open a qmtt
        -- use the position of the colliding tag for all further calcs
        add_tag_GUI.open(player, position_has_colliding_tags)
      else
        -- we are creating a new one
        add_tag_GUI.open(player, position)
      end
    end
  end
end

function on_teleport(event)
  if event and event.entity and event.entity.player then
    local player = event.entity.player
    if player then
    --[[player.surface.play_sound({m
      path = "wct-qmtt-construction-robot",
      position = player.position,
      volume = 1.0
    })]]
    end
  end
end

function on_close_with_toggle_map(event)
  local player = game.get_player(event.player_index)
  if ((player and player.render_mode ~= defines.render_mode.game) and (add_tag_GUI.is_open(player))) then
    add_tag_GUI.close(player)
  end
end

function custom_input_event_handler.on_fave_order_updated(event)
  if game then
    local player = game.players[event.player_index]
    if player then
      fav_bar_GUI.update_ui(player)
    end
  end
end

function custom_input_event_handler.on_selected_fave_changed(event)
  if game then
    local player = game.players[event.player_index]
    if player then
      edit_fave_GUI.on_selected_fave_changed(event)
      edit_fave_GUI.update_ui(event.player_index)
    end
  end
end

--[[custom_input_event_handler.on_on_maptag_editor_open = function(event)
  local player = game.get_player(event.player_index)

  --[[if ((player and player.render_mode ~= defines.render_mode.game) and (add_tag_GUI.is_open(player))) then
    add_tag_GUI.close(player)
  end
end]]

return custom_input_event_handler
