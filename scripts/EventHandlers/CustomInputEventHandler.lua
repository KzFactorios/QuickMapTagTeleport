local AddTagSettings = require("scripts/Settings/AddTagSettings")
local AddTagGUI = require("scripts/GUI/AddTagGUI")
local MapTagUtils = require("scripts/Utils/MapTagUtils")

local CustomInputEventHandler = {}

CustomInputEventHandler.on_add_tag = function(event)
  local player = game.get_player(event.player_index)
  if ((player and player.render_mode == defines.render_mode.chart) and (not AddTagGUI.is_open(player))) then
    local settings = AddTagSettings.getPlayerSettings(player)
    local position = MapTagUtils.snap_position(event.cursor_position, settings.snap_scale)
    local position_can_be_tagged = MapTagUtils.position_can_be_tagged(position, player)
    local position_has_collisions = MapTagUtils.position_has_collisions(position, settings.snap_scale, player)
    if (position_can_be_tagged and not position_has_collisions) then
      if (settings.use_add_tag_gui) then
        AddTagGUI.open(player, position)
      else
        MapTagUtils.create_new_tag(player, position, settings.new_tag_text, settings.new_tag_icon)
      end
    end
  end
end

CustomInputEventHandler.on_close_with_toggle_map = function(event)
  local player = game.get_player(event.player_index)
  if ((player and player.render_mode ~= defines.render_mode.game) and (AddTagGUI.is_open(player))) then
    AddTagGUI.close(player)
  end
end

return CustomInputEventHandler
