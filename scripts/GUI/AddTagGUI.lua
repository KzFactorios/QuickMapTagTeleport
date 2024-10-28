local PREFIX = require("Constants").PREFIX
local gui = require("lib/gui")
local AddTagSettings = require("scripts/Settings/AddTagSettings")
local MapTagUtils = require("scripts/Utils/MapTagUtils")

local add_tag_frame_template = function(text, icon, position_text)
  return
    {type = "frame", save_as = "root_frame", direction = "vertical", handlers="add_tag.root_frame", children = {

      {type = "flow", style = "frame_header_flow", children = {
        {type = "label", style = "frame_title", caption = {"gui-tag-edit.frame_title"}},
        {type = "empty-widget", save_as = "buttons.draggable_space_header", style = "flib_dialog_footer_drag_handle"},
        {type = "button", save_as = "buttons.cancel_h", style = "frame_action_button", caption = {"gui-tag-edit.x"},
          handlers = "add_tag.buttons.cancel"}
      }},
      

      {type = "frame", direction = "vertical", style = "inside_shallow_frame_with_padding", children = {
        {type = "table", column_count = 2, style = PREFIX .. "add_tag_table", children = {

          {type = "label", style = "label", caption = {"gui-tag-edit.teleport"}},
          {type = "button", save_as = "buttons.teleport", style = "back_button", caption = position_text,
            handlers = "add_tag.buttons.teleport"},

          {type = "label", style = "label", caption = {"gui-tag-edit.name"}},
          {type = "textfield", save_as = "fields.text", text = text, style = PREFIX .. "add_tag_textfield",
           handlers = "add_tag.fields.text"},
          
           {type = "label", style = "label", caption = {"gui-tag-edit.icon"}},
          {type = "choose-elem-button", save_as = "fields.icon", style = "slot_button_in_shallow_frame",
           elem_type = "signal", signal = icon, handlers = "add_tag.fields.icon"}
        }}
      }},

      {type = "flow", style = "dialog_buttons_horizontal_flow", children = {
        {type = "button", save_as = "buttons.cancel", style = "back_button", caption = {"gui-tag-edit.cancel"},
         handlers = "add_tag.buttons.cancel"},
        {type = "empty-widget", save_as = "buttons.draggable_space", style = "flib_dialog_footer_drag_handle"},
        {type = "button", save_as = "buttons.confirm", style = "confirm_button", caption = {"gui-tag-edit.confirm"},
         handlers = "add_tag.buttons.confirm", enabled = (icon ~= nil or text ~= "")}
      }}

    }} -- end of root frame
end

local AddTagGUI = {}

AddTagGUI.on_init = function()
  if (storage.GUI == nil) then
    storage.GUI = {}
  end
  storage.GUI.AddTag = {
    players = {}
  }
  for i, player in pairs(game.players) do
    storage.GUI.AddTag.players[i] = {}
  end
end

AddTagGUI.on_player_created = function(event)
  storage.GUI.AddTag.players[event.player_index] = {}
end

AddTagGUI.on_player_removed = function(event)
  storage.GUI.AddTag.players[event.player_index] = nil
end

AddTagGUI.is_open = function(player)
  assert(player ~= nil)
  assert(storage.GUI ~= nil)
  assert(storage.GUI.AddTag ~= nil)
  assert(storage.GUI.AddTag.players ~= nil)

  return storage.GUI.AddTag.players[player.index].elements ~= nil
end

AddTagGUI.open = function(player, position)
  assert(player ~= nil)
  assert(position ~= nil)

  local settings = AddTagSettings.getPlayerSettings(player)
  local posTxt = string.format("x: %d, y: %d", math.floor(position.x), math.floor(position.y))
  local elements = gui.build(player.gui.screen, {add_tag_frame_template(settings.new_tag_text, settings.new_tag_icon, posTxt)})

  elements.root_frame.force_auto_center()
  elements.fields.text.focus()
  elements.buttons.draggable_space.drag_target = elements.root_frame

  storage.GUI.AddTag.players[player.index].elements = elements
  storage.GUI.AddTag.players[player.index].position = position

  player.opened = elements.root_frame
end

AddTagGUI.close = function(player)
  assert(player ~= nil)

  if (not AddTagGUI.is_open(player)) then
    return
  end

  player.opened = nil
end

AddTagGUI.get_position = function(player)
  assert(player ~= nil)

  if (not AddTagGUI.is_open(player)) then
    return nil
  end

  return storage.GUI.AddTag.players[player.index].position
end

AddTagGUI.get_text = function(player)
  assert(player ~= nil)

  if (not AddTagGUI.is_open(player)) then
    return nil
  end

  return storage.GUI.AddTag.players[player.index].elements.fields.text.text
end

AddTagGUI.get_icon = function(player)
  assert(player ~= nil)

  if (not AddTagGUI.is_open(player)) then
    return nil
  end

  return storage.GUI.AddTag.players[player.index].elements.fields.icon.elem_value
end

local on_fields_values_changed = function(event)
  local player = game.get_player(event.player_index)
  local text = AddTagGUI.get_text(player)
  local icon = AddTagGUI.get_icon(player)
  local enabled = icon ~= nil or text ~= ""
  storage.GUI.AddTag.players[event.player_index].elements.buttons.confirm.enabled = enabled
end

AddTagGUI.handlers = {
  add_tag = {
    root_frame = {
      on_gui_closed = function(event)
        storage.GUI.AddTag.players[event.player_index].elements.root_frame.destroy()
        storage.GUI.AddTag.players[event.player_index] = {}
      end
    },
    fields = {
      text = {
        on_gui_text_changed = on_fields_values_changed
      },
      icon = {
        on_gui_elem_changed = on_fields_values_changed
      }
    },
    buttons = {
      cancel = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          AddTagGUI.close(player)
        end
      },
      confirm = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          MapTagUtils.create_new_tag(
            player,
            AddTagGUI.get_position(player),
            AddTagGUI.get_text(player),
            AddTagGUI.get_icon(player)
          )
          AddTagGUI.close(player)
        end
      },
      teleport = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          local pos = AddTagGUI.get_position(player)
          if(pos and player and player.teleport(pos, player.surface)) then
            game.print(string.format("%s teleported to x: %d, y: %d", player.name, pos.x, pos.y))
            AddTagGUI.close(player)
          end          
        end
      }
    }
  }
}

return AddTagGUI
