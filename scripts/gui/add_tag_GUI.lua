local gui = require("lib/gui")
local PREFIX = require("settings/constants").PREFIX
local add_tag_settings = require("settings/add_tag_settings")
local map_tag_utils = require("utils/map_tag_utils")

local add_tag_frame_template = function(text, icon, position_text)
  return
  {
    type = "frame",
    save_as = "root_frame",
    direction = "vertical",
    handlers = "add_tag.root_frame",
    children = {

      {
        type = "flow",
        style = "frame_header_flow",
        children = {
          { type = "label",        style = "frame_title",                      caption = { "gui-tag-edit.frame_title" } },
          { type = "empty-widget", save_as = "buttons.draggable_space_header", style = "flib_dialog_footer_drag_handle" },
          {
            type = "button",
            save_as = "buttons.cancel_h",
            style = PREFIX .. "frame_action_button",
            caption = { "gui-tag-edit.x" },
            handlers = "add_tag.buttons.cancel"
          }
        }
      },

      {
        type = "frame",
        direction = "vertical",
        style = "inside_shallow_frame_with_padding",
        children = {
          {
            type = "table",
            column_count = 2,
            style = PREFIX .. "add_tag_table",
            children = {

              { type = "label",       style = "label",          caption = { "gui-tag-edit.teleport" } },
              {
                type = "button",
                save_as = "buttons.teleport",
                style = PREFIX .. "red_confirm_button",
                caption = position_text,
                handlers = "add_tag.buttons.teleport"
              },

              -- couldn't get the line to span 2 columns so empty widget is the workaround
              { type = "empty-widget" },
              { type = "line",        direction = "horizontal", style = PREFIX .. "section_divider" },

              { type = "label",       style = "label",          caption = { "gui-tag-edit.name" } },
              {
                type = "textfield",
                save_as = "fields.text",
                text = text,
                style = PREFIX .. "add_tag_textfield",
                handlers = "add_tag.fields.text"
              },

              { type = "label", style = "label", caption = { "gui-tag-edit.icon" } },
              {
                type = "choose-elem-button",
                save_as = "fields.icon",
                style = "slot_button_in_shallow_frame",
                elem_type = "signal",
                signal = icon,
                handlers = "add_tag.fields.icon"
              }
            }
          }
        }
      },

      {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
        children = {
          {
            type = "button",
            save_as = "buttons.cancel",
            style = "back_button",
            caption = { "gui-tag-edit.cancel" },
            handlers = "add_tag.buttons.cancel"
          },
          { type = "empty-widget", save_as = "buttons.draggable_space", style = "flib_dialog_footer_drag_handle" },
          {
            type = "button",
            save_as = "buttons.confirm",
            style = "confirm_button",
            caption = { "gui-tag-edit.confirm" },
            handlers = "add_tag.buttons.confirm",
            enabled = (icon ~= nil or text ~= "")
          }
        }
      }

    }
  } -- end of root frame
end

local add_tag_GUI = {}

add_tag_GUI.on_init = function()
  if (storage.GUI == nil) then
    storage.GUI = {}
  end
  storage.GUI.AddTag = {
    players = {}
  }
  for _, player in pairs(game.players) do
    storage.GUI.AddTag.players[player.index] = {}
  end
end

add_tag_GUI.on_player_created = function(event)
  storage.GUI.AddTag.players[event.player_index] = {}
end

add_tag_GUI.on_player_removed = function(event)
  storage.GUI.AddTag.players[event.player_index] = nil
end

add_tag_GUI.is_open = function(player)
  if player then
    return storage.GUI.AddTag.players[player.index].elements ~= nil
  end
end

add_tag_GUI.open = function(player, position)
  if player and position then
    local settings = add_tag_settings.getPlayerSettings(player)
    local posTxt = string.format("x: %d, y: %d", math.floor(position.x), math.floor(position.y))
    local elements = gui.build(player.gui.screen,
      { add_tag_frame_template(settings.new_tag_text, settings.new_tag_icon, posTxt) })

    elements.root_frame.force_auto_center()
    elements.fields.text.focus()
    elements.buttons.draggable_space.drag_target = elements.root_frame

    -- Not sure if this will fix the problem aka are we building the player correctly?
    if not storage.GUI.AddTag.players[player.index] then
      storage.GUI.AddTag.players[player.index] = player
    end

    storage.GUI.AddTag.players[player.index].elements = elements
    storage.GUI.AddTag.players[player.index].position = position
    player.opened = elements.root_frame
  end
end

add_tag_GUI.close = function(player)
  if player then
    if not add_tag_GUI.is_open(player) then
      return
    end
    player.opened = nil
  end
end

add_tag_GUI.get_position = function(player)
  if player then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end

    return storage.GUI.AddTag.players[player.index].position
  end
end

add_tag_GUI.get_text = function(player)
  if (player) then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end
    return storage.GUI.AddTag.players[player.index].elements.fields.text.text
  end
end

add_tag_GUI.get_icon = function(player)
  if player then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end
    if storage.GUI.AddTag.players[player.index].elements then
      return storage.GUI.AddTag.players[player.index].elements.fields.icon.elem_value
    end
  end
  return nil
end

local on_fields_values_changed = function(event)
  local player = game.get_player(event.player_index)
  local text = add_tag_GUI.get_text(player)
  local icon = add_tag_GUI.get_icon(player)
  local enabled = icon ~= nil or text ~= ""
  storage.GUI.AddTag.players[event.player_index].elements.buttons.confirm.enabled = enabled
end

add_tag_GUI.handlers = {
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
          add_tag_GUI.close(player)
        end
      },
      confirm = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          map_tag_utils.create_new_tag(
            player,
            add_tag_GUI.get_position(player),
            add_tag_GUI.get_text(player),
            add_tag_GUI.get_icon(player)
          )
          add_tag_GUI.close(player)
        end
      },
      teleport = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          if player then
            local target_position = add_tag_GUI.get_position(player)
            local og_position = player.position
            local og_surface_index = player.surface_index
            local settings = add_tag_settings.getPlayerSettings(player)
            local radius = 10

            local tele_pos, msg = map_tag_utils.teleport_player_to_closest_position(player, target_position, radius)
            if tele_pos then
              game.print(string.format("%s teleported to x: %d, y: %d", player.name, tele_pos.x, tele_pos.y))
              add_tag_GUI.close()

              -- provide a hook for others to key into
              script.raise_event(defines.events.script_raised_teleported,
                {
                  entity = player.character,
                  old_surface_index = og_surface_index,
                  old_position = og_position
                }
              )
            else
              game.print(msg)
            end
          end
        end
      }
    }
  }
}

return add_tag_GUI
