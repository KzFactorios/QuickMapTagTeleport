local add_tag_settings = require("settings/add_tag_settings")
local add_tag_GUI = require("scripts/gui/add_tag_GUI")
local map_tag_utils = require("utils/map_tag_utils")

local custom_input_event_handler = {}

-- when right click is performed on the map. Our trigger for opening our dialog
custom_input_event_handler.on_add_tag = function(event)
  local player = game.get_player(event.player_index)

  if ((player and player.render_mode == defines.render_mode.chart) and (not add_tag_GUI.is_open(player))) then
    local settings = add_tag_settings.getPlayerSettings(player)
    local position = map_tag_utils.snap_position(event.cursor_position, settings.snap_scale)
    local position_can_be_tagged = map_tag_utils.position_can_be_tagged(position, player)
    local position_has_tag_collisions = map_tag_utils.position_has_tag_collisions(position, settings.snap_scale, player)

    if (position_can_be_tagged and not position_has_tag_collisions) then
      add_tag_GUI.open(player, position)

      --[[
      if you would like to bring back the option to automatically create the tag and
      not offer a dialog box for creation, this is the code to do that. You will also
      need to fiddle with the settings to allow the option
      It will also mess with the Teleport feature of the mod

      if (settings.use_add_tag_gui) then
        add_tag_GUI.open(player, position)m
      else
        map_tag_utils.create_new_tag(player, position, settings.new_tag_text, settings.new_tag_icon)
      end
    ]]
    end
  end
end

custom_input_event_handler.on_teleport = function(event)
  if event and event.entity and event.entity.player then
    local player = event.entity.player
    --[[player.surface.play_sound({
      path = "wct-qmtt-construction-robot",
      position = player.position,
      volume = 1.0
    })]]
  end
end

custom_input_event_handler.on_close_with_toggle_map = function(event)
  local player = game.get_player(event.player_index)

  if ((player and player.render_mode ~= defines.render_mode.game) and (add_tag_GUI.is_open(player))) then
    add_tag_GUI.close(player)
  end
end

return custom_input_event_handler
