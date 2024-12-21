local gui              = require("lib/gui")
--local mod_gui          = require("mod-gui")
local add_tag_settings = require("settings/add_tag_settings")
local map_tag_utils    = require("utils/map_tag_utils")
local wutils           = require("wct_utils")
local cache            = require("lib/cache")

local constants        = require("settings/constants")
local PREFIX           = constants.PREFIX

local function add_tag_frame_template(formatted_position, text, icon, _qmtt, element_favorite)
  return
  {
    name = "gui-tag-edit",
    type = "frame",
    save_as = "root_frame",
    direction = "vertical",
    handlers = "add_tag.root_frame",
    children = {

      {        type = "frame",
        name = "header-row",
        style = "header_frame",
        direction = "horizontal",
        children = {
          { type = "label",        style = "frame_title",                      caption = { "gui-tag-edit.frame_title" } },
          { type = "empty-widget", save_as = "buttons.draggable_space_header", style = "flib_dialog_footer_drag_handle" },
          {
            type = "button",
            name = "button-cancel-header",
            save_as = "buttons.cancel_h",
            style = PREFIX .. "frame_action_button",
            caption = { "gui-tag-edit.x" },
            handlers = "add_tag.buttons.cancel"
          },
        }
      },


      {        type = "frame",
        name = "table-container",
        style = "inside_shallow_frame_with_padding",
        direction = "vertical",
        children = {
          {
            type = "table",
            name="table-proper",
            column_count = 2,
            style = PREFIX .. "add_tag_table",
            children = {
              { type = "label", style = "label",          caption = { "gui-tag-edit.teleport" } },
              {
                type = "button",
                name = "button-teleport",
                save_as = "buttons.teleport",
                style = PREFIX .. "red_confirm_button",
                caption = formatted_position,
                handlers = "add_tag.buttons.teleport"
              },

              { type = "label", style = "label",          caption = "Name" },
              {
                type = "text-box",
                name = "text-name",
                save_as = "fields.text",
                text = text,
                style = PREFIX .. "add_tag_textfield",
                clear_and_focus_on_right_click = true,
                handlers = "add_tag.fields.text"
              },

              { type = "label", caption = "Favorite" },
              {
                type = "checkbox",
                name = "checkbox-favorite",
                save_as = "fields.favorite",
                state = element_favorite,
                --handlers = "add_tag.fields.favorite"
              },

              {
                type = "choose-elem-button",
                name = "elem-icon",
                save_as = "fields.icon",
                style = "fav_bar_slot_button_in_shallow_frame",
                elem_type = "signal",
                signal = icon,
                handlers = "add_tag.fields.icon"
              },

            },
          },
        },
      },
      {
        type = "frame",
        name = "action-row",
        style = "row_container",
        direction = "horizontal",
        children = {
          {
            type = "button",
            name = "button-cancel",
            save_as = "buttons.cancel",
            style = "back_button",
            caption = { "gui-tag-edit.cancel" },
            handlers = "add_tag.buttons.cancel"
          },
          { type = "empty-widget", save_as = "buttons.draggable_space_footer", style = "flib_dialog_footer_drag_handle" },
          {
            type = "button",
            name = "button-confirm",
            save_as = "buttons.confirm",
            style = "confirm_button",
            caption = { "gui-tag-edit.confirm" },
            handlers = "add_tag.buttons.confirm",
            enabled = (icon ~= nil or text ~= "")
          }
        }
      },
      {
        type = "frame",
        visible = false,
        column_count = 2,
        name = "display-text-row",
        style = "row_container",
        direction = "horizontal",
        children = {
          { type = "label", style = "label", caption = "Display Text" },
          {
            type = "textfield",
            name = "text-display",
            save_as = "fields.displaytext",
            text = _qmtt.fave_displaytext,
            style = PREFIX .. "add_tag_textfield",
            --handlers = "add_tag.fields.displaytext"
          },
        }
      },
      {
        type = "frame",
        visible = false,
        name = "description-row",
        style = "row_container",
        direction = "horizontal",
        children = {
          { type = "label", style = "label", caption = "Description" },
          {
            type = "textfield",
            name = "text-description",
            save_as = "fields.description",
            text = _qmtt.fave_description,
            style = PREFIX .. "add_tag_textfield",
            --handlers = "add_tag.fields.description"
          },
        },
      },
    }
  } -- end of root frame
end

local add_tag_GUI = {}

function add_tag_GUI.on_player_created(event)
end

--- Close the gui and remove player refs to AddTag
function add_tag_GUI.on_player_removed(player_index)
  local player = game.players[player_index]
  if player then
    add_tag_GUI.close(player)
    storage.qmtt.GUI.AddTag.players[player_index] = nil
  end
end

-- Handle confirmation (Enter key)
script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name == "add_tag_GUI" then
    event.element.parent.destroy()
  end
end)

function add_tag_GUI.is_open(player)
  if player then
    return player.gui.screen["gui-tag-edit"] ~= nil
  end
end

function add_tag_GUI.format_position_text(position)
  return string.format("x: %d, y: %d", math.floor(position.x), math.floor(position.y))
end

function add_tag_GUI.open(player, position_to_open_from)
  local position = position_to_open_from
  --local tagedit = mod_gui.get_frame_flow(player)["AddTag"]

  if player and position then
    if add_tag_GUI.is_open(player) then
      add_tag_GUI.close(player)
    end

    local settings = add_tag_settings.getPlayerSettings(player)
    local posTxt = add_tag_GUI.format_position_text(position)

    -- find tags with position =
    local _tags = cache.get_chart_tags_from_cache(player)
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
    local elements = gui.build(player.gui.screen,
      { add_tag_frame_template(posTxt, new_tag_text, new_tag_icon, _qmtt, element_favorite) })

    elements.root_frame.force_auto_center()
    elements.fields.text.focus()
    elements.buttons.draggable_space_header.drag_target = elements.root_frame
    elements.buttons.draggable_space_footer.drag_target = elements.root_frame
    storage.qmtt.GUI.AddTag.players[player.index].position = position
  end
end

function add_tag_GUI.close(player)
  if player then
    if add_tag_GUI.is_open(player) then
      player.gui.screen["gui-tag-edit"].destroy()
    end
  end
end

function add_tag_GUI.get_position(player_index)
  if player_index then
    return storage.qmtt.GUI.AddTag.players[player_index].position
  end
end

function add_tag_GUI.get_text(player)
  if player then
    if add_tag_GUI.is_open(player) then
      -- PREFIX .. "add_tag_table"
      return player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["text-name"].text
    end
  end
  return ""
end

--[[function add_tag_GUI.get_displaytext(player)
  if player then
    if add_tag_GUI.is_open(player) then
      return player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["text-display"].text
    end
  end
  return ""
end

function add_tag_GUI.get_description(player)
  if player then
    if add_tag_GUI.is_open(player) then
      return player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["text-description"].text
    end
  end
  return ""
end]]

function add_tag_GUI.get_favorite(player)
  if player then
    if add_tag_GUI.is_open(player) then
      return player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["checkbox-favorite"].state
    end
  end
  return false
end

function add_tag_GUI.get_icon(player)
  if player then
    if add_tag_GUI.is_open(player) then
      return player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["elem-icon"].elem_value
    end
  end
  return nil
end

local function on_fields_values_changed(event)
  local player = game.get_player(event.player_index)
  if player and add_tag_GUI.is_open(player) then
    local text = add_tag_GUI.get_text(player)
    local icon = add_tag_GUI.get_icon(player)
    local enabled = icon ~= nil or text ~= ""
    player.gui.screen["gui-tag-edit"]["action-row"]["button-confirm"].enabled = enabled
  end
end

add_tag_GUI.handlers = {
  add_tag = {
    root_frame = {
      on_gui_closed = function(event)
        -- gui should be closed
        -- do any other cleanup
      end
    },
    fields = {
      text = {
        on_gui_text_changed = on_fields_values_changed
      },

      icon = {
        on_gui_elem_changed = on_fields_values_changed
      },
      --[[
      displaytext = {
        on_gui_text_changed = on_fields_values_changed
      },
      description = {
        on_gui_text_changed = on_fields_values_changed
      },
      favorite = {
        on_gui_state_changed = on_fields_values_changed
      }
        ]]
    },
    buttons = {
      cancel = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          if player then
            add_tag_GUI.close(player)
          end
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
              "",--add_tag_GUI.get_displaytext(player),
              "",--add_tag_GUI.get_description(player),
              add_tag_GUI.get_favorite(player)
            )
            add_tag_GUI.close(player)
            control.update_uis(player)
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
            -- TODO assign a player setting
            local radius = 10

            local tele_pos, msg = map_tag_utils.teleport_player_to_closest_position(player, target_position, radius)
            if tele_pos then
              game.print(string.format("%s teleported to x: %d, y: %d", player.name, tele_pos.x, tele_pos.y))
              add_tag_GUI.close(player)

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


--[[


function add_tag_GUI.ensure_structure(player)
  if not storage.qmtt.GUI then storage.qmtt.GUI = {} end
  if not storage.qmtt.GUI.AddTag then storage.qmtt.GUI.AddTag = {} end
  if not storage.qmtt.GUI.AddTag.players then storage.qmtt.GUI.AddTag.players = {} end
  if not storage.qmtt.GUI.AddTag.players[player.index] then
    storage.qmtt.GUI.AddTag.players[player.index] = {}
  end
end



]]
