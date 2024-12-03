local gui = require("lib/gui")
local mod_gui = require("mod-gui")
local add_tag_settings = require("settings/add_tag_settings")
local map_tag_utils = require("utils/map_tag_utils")
local wutils = require("wct_utils")
local cache = require("lib/cache")

local constants = require("settings/constants")
local PREFIX = constants.PREFIX

local function add_tag_frame_template(formatted_position, text, icon, _qmtt, element_favorite)
  return
  {
    name = "gui-tag-edit",
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
                caption = formatted_position,
                handlers = "add_tag.buttons.teleport"
              },

              -- couldn't get the line to span 2 columns so empty widget is the workaround
              { type = "empty-widget" },
              { type = "line",        direction = "horizontal", style = PREFIX .. "section_divider" },

              {
                type = "choose-elem-button",
                save_as = "fields.icon",
                style = "slot_button_in_shallow_frame",
                elem_type = "signal",
                signal = icon,
                handlers = "add_tag.fields.icon"
              },
              {
                type = "text-box",
                save_as = "fields.text",
                text = text,
                style = PREFIX .. "add_tag_textfield",
                clear_and_focus_on_right_click = true,
                handlers = "add_tag.fields.text"
              },

              { type = "label",       style = "label",          caption = { "gui-tag-edit.icon" } },
              { type = "label",       style = "label",          caption = { "gui-tag-edit.name" } },

              -- couldn't get the line to span 2 columns so empty widget is the workaround
              { type = "empty-widget" },
              { type = "line",        direction = "horizontal", style = PREFIX .. "section_divider" },

              {
                type = "checkbox",
                save_as = "fields.favorite",
                state = element_favorite,
                handlers = "add_tag.fields.favorite"
              },
              {
                type = "textfield",
                save_as = "fields.displaytext",
                text = _qmtt.fave_displaytext,
                style = PREFIX .. "add_tag_textfield",
                handlers = "add_tag.fields.displaytext"
              },
              {
                type = "textfield",
                save_as = "fields.description",
                text = _qmtt.fave_description,
                style = PREFIX .. "add_tag_textfield",
                handlers = "add_tag.fields.description"
              },
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
          { type = "empty-widget", save_as = "buttons.draggable_space_footer", style = "flib_dialog_footer_drag_handle" },
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

function add_tag_GUI.on_player_created(event)
end

function add_tag_GUI.on_pre_player_left_game(event)
  -- destroy any guis
  add_tag_GUI.close(event.player_index)
  -- remove player from player indexed storage
  storage.qmtt.GUI.AddTag.players[event.player_index] = nil
end

function add_tag_GUI.on_player_removed(event)
  add_tag_GUI.close(event.player_index)
  storage.qmtt.GUI.AddTag.players[event.player_index] = nil
end

-- Handle confirmation (Enter key)
script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name == "add_tag_GUI" then
    local entered_text = event.element.text
    --game.print("Text confirmed: " .. entered_text)

    -- Close the editor or perform another action
    event.element.parent.destroy()
  end
end)

function add_tag_GUI.is_open(player)
  if player then
    add_tag_GUI.ensure_structure(player)
    return storage.qmtt.GUI.AddTag.players[player.index].elements ~= nil and
        storage.qmtt.GUI.AddTag.players[player.index].elements.buttons ~= nil and
        storage.qmtt.GUI.AddTag.players[player.index].elements.fields ~= nil
  end
end

function add_tag_GUI.ensure_structure(player)
  if not storage.qmtt.GUI then storage.qmtt.GUI = {} end
  if not storage.qmtt.GUI.AddTag then storage.qmtt.GUI.AddTag = {} end
  if not storage.qmtt.GUI.AddTag.players then storage.qmtt.GUI.AddTag.players = {} end
  if not storage.qmtt.GUI.AddTag.players[player.index] then
    storage.qmtt.GUI.AddTag.players[player.index] = {}
  end
end

function kill_gui(player)
  add_tag_GUI.ensure_structure(player)
  if storage.qmtt.GUI.AddTag.players[player.index].elements then
    storage.qmtt.GUI.AddTag.players[player.index].elements = nil
  end
  if player.gui.screen["tag-edit-gui"] then
    player.gui.screen["tag-edit-gui"].destroy()
  end
end

function add_tag_GUI.format_position_text(position)
  return string.format("x: %d, y: %d", math.floor(position.x), math.floor(position.y))
end

function add_tag_GUI.open(player, position_to_open_from)
  local position = position_to_open_from
  if player and position then
    kill_gui(player)

    local settings = add_tag_settings.getPlayerSettings(player)
    local posTxt = add_tag_GUI.format_position_text(position)

    -- find tags with position =
    local _tags = cache.get_chart_tags_from_cache(player.index)
    local _tag = wutils.find_element_by_position(_tags, "position", position)

    local _qmtt = cache.get_matching_qmtt_by_position(player.surface_index, position)

    local new_tag_text = settings.new_tag_tex
    local new_tag_icon = settings.new_tag_icon

    if _qmtt == nil and _tag ~= nil then
      _qmtt = {
        idx = add_tag_GUI.format_position_text(_tag.position),
        position = _tag.position,
        faved_by_players = {},
        fave_display_text = "",
        fave_description = "",
      }
      new_tag_text = _tag.text
      new_tag_icon = _tag.icon
    elseif _qmtt == nil and _tag == nil then
      _qmtt = {
        idx = add_tag_GUI.format_position_text(position),
        position = position,
        faved_by_players = {},
        fave_display_text = "",
        fave_description = "",
      }
    elseif _qmtt ~= nil and _tag ~= nil then
      new_tag_text = _tag.text
      new_tag_icon = _tag.icon
    end

    local element_favorite = cache.extended_tag_is_player_favorite(_qmtt, player.index)


    -- mod_gui_inner_frame is the parent
    --local champ = mod_gui.get_frame_flow(player)
    -- the dialog is in the screen!
    local elements = gui.build(player.gui.screen,
      { add_tag_frame_template(posTxt, new_tag_text, new_tag_icon, _qmtt, element_favorite) })

    elements.root_frame.force_auto_center()
    elements.fields.text.focus()
    elements.buttons.draggable_space_header.drag_target = elements.root_frame
    elements.buttons.draggable_space_footer.drag_target = elements.root_frame

    -- Not sure if this will fix the problem aka are we building the player correctly?
    --if not storage.qmtt.GUI.AddTag.players[player.index] then
    --  storage.qmtt.GUI.AddTag.players[player.index] = player
    --end

    storage.qmtt.GUI.AddTag.players[player.index].elements = elements
    storage.qmtt.GUI.AddTag.players[player.index].position = position
    player.opened = elements.root_frame
  end
end

function add_tag_GUI.close(player)
  if player then
    if not add_tag_GUI.is_open(player) then
      return
    end
    player.opened = nil
    if player.gui.screen["gui-tag-edit"] then
      player.gui.screen["gui-tag-edit"].destroy()
    end
    storage.qmtt.GUI.AddTag.players[player.index].elements = nil
  end
end

function add_tag_GUI.get_position(player_index)
  if player_index then
    return storage.qmtt.GUI.AddTag.players[player_index].position
  end
end

function add_tag_GUI.get_text(player)
  if (player) then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end
    return storage.qmtt.GUI.AddTag.players[player.index].elements.fields.text.text
  end
end

function add_tag_GUI.get_displaytext(player)
  if (player) then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end
    return storage.qmtt.GUI.AddTag.players[player.index].elements.fields.displaytext.text
  end
end

function add_tag_GUI.get_description(player)
  if (player) then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end
    return storage.qmtt.GUI.AddTag.players[player.index].elements.fields.description.text
  end
end

function add_tag_GUI.get_favorite(player)
  if (player) then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end
    return storage.qmtt.GUI.AddTag.players[player.index].elements.fields.favorite.state
  end
end

function add_tag_GUI.get_icon(player)
  if player then
    if (not add_tag_GUI.is_open(player)) then
      return nil
    end
    if storage.qmtt.GUI.AddTag.players[player.index].elements then
      return storage.qmtt.GUI.AddTag.players[player.index].elements.fields.icon.elem_value
    end
  end
  return nil
end

local function on_fields_values_changed(event)
  local player = game.get_player(event.player_index)
  local text = add_tag_GUI.get_text(player)
  local icon = add_tag_GUI.get_icon(player)
  local enabled = icon ~= nil or text ~= ""
  storage.qmtt.GUI.AddTag.players[event.player_index].elements.buttons.confirm.enabled = enabled
end

add_tag_GUI.handlers = {
  add_tag = {
    root_frame = {
      on_gui_closed = function(event)
        storage.qmtt.GUI.AddTag.players[event.player_index].elements.root_frame.destroy()
        storage.qmtt.GUI.AddTag.players[event.player_index] = {}
      end
    },
    fields = {
      text = {
        on_gui_text_changed = on_fields_values_changed
      },
      displaytext = {
        on_gui_text_changed = on_fields_values_changed
      },
      description = {
        on_gui_text_changed = on_fields_values_changed
      },
      icon = {
        on_gui_elem_changed = on_fields_values_changed
      },
      favorite = {
        on_gui_state_changed = on_fields_values_changed
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
          if player then
            map_tag_utils.save_tag(
              player,
              add_tag_GUI.get_position(player.index),
              add_tag_GUI.get_text(player),
              add_tag_GUI.get_icon(player),
              add_tag_GUI.get_displaytext(player),
              add_tag_GUI.get_description(player),
              add_tag_GUI.get_favorite(player)
            )
            add_tag_GUI.close(player)
          end
        end
      },
      teleport = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          if player then
            local target_position = add_tag_GUI.get_position(player.index)
            local og_position = player.position
            local og_surface_index = player.surface_index
            --local settings = add_tag_settings.getPlayerSettings(player)
            -- TODO assign a player setting
            local radius = 10

            local tele_pos, msg = map_tag_utils.teleport_player_to_closest_position(player, target_position, radius)
            if tele_pos then
              game.print(string.format("%s teleported to x: %d, y: %d", player.name, tele_pos.x, tele_pos.y))
              add_tag_GUI.close()

              -- provide a hook for others to key into
              ---@diagnostic disable-next-line: param-type-mismatch
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
