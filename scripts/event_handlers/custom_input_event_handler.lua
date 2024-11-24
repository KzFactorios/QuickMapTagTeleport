local add_tag_settings = require("settings/add_tag_settings")
local add_tag_GUI = require("scripts/gui/add_tag_GUI")
local map_tag_utils = require("utils/map_tag_utils")

local qmtt = require("scripts.gui.qmtt")

local custom_input_event_handler = {}

local _idx = -1

custom_input_event_handler.on_open_stock_gui = function(event)
  local stub = "stub"
end


-- when right click is performed on the map. Our trigger for opening our dialog
custom_input_event_handler.on_add_tag = function(event)
  local player = game.get_player(event.player_index)

  if ((player and player.render_mode == defines.render_mode.chart) and (not add_tag_GUI.is_open(player))) then
    local settings = add_tag_settings.getPlayerSettings(player)
    local position = map_tag_utils.snap_position(event.cursor_position, settings.snap_scale)
    local position_can_be_tagged = map_tag_utils.position_can_be_tagged(position, player)

    if position_can_be_tagged then
      local position_has_colliding_tags = map_tag_utils.position_has_colliding_tags(position, settings.snap_scale, player)
      if position_has_colliding_tags then
        -- we are editing, open a qmtt
        --find the nearest tag and load the dialog
        add_tag_GUI.open(player, position)
      else
        -- we are creating a new one
        add_tag_GUI.open(player, position)
      end
    end

      --[[
      if you would like to bring back the option to automatically create the tag and
      not offer a dialog box for creation, this is the code to do that. You will also
      need to fiddle with the settings to allow the option
      It will also mess with the Teleport feature of the mod

      if (settings.use_add_tag_gui) then
        add_tag_GUI.open(player, position)m
      else
        map_tag_utils.save_tag(player, position, settings.new_tag_text, settings.new_tag_icon)
      end
    ]]
    
  end
end

custom_input_event_handler.on_teleport = function(event)
  if event and event.entity and event.entity.player then
    local player = event.entity.player
    --[[player.surface.play_sound({m
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

--[[custom_input_event_handler.on_on_maptag_editor_open = function(event)
  local player = game.get_player(event.player_index)


  --[[if ((player and player.render_mode ~= defines.render_mode.game) and (add_tag_GUI.is_open(player))) then
    add_tag_GUI.close(player)
  end
end]]



return custom_input_event_handler
