local map_tag_utils = require("utils/map_tag_utils")
local constants     = require("settings/constants")
local wutils        = require("wct_utils")
local cache         = require("lib/cache")
local gui           = require("lib/gui")
local PREFIX        = constants.PREFIX

local function add_tag_frame_template(player, formatted_position, text, icon, _qmtt, element_favorite)
  local container_elements = {}

  table.insert(container_elements, { type = "label", style = "label", caption = { "gui-tag-edit.teleport" } })
  table.insert(container_elements, {
    type = "button",
    name = "button-teleport",
    save_as = "buttons.teleport",
    style = PREFIX .. "red_confirm_button",
    caption = formatted_position,
    handlers = "add_tag.buttons.teleport"
  })

  table.insert(container_elements, { type = "label", style = "label", caption = "Name" })
  table.insert(container_elements, {
    type = "text-box",
    name = "text-name",
    save_as = "fields.text",
    text = text,
    style = PREFIX .. "add_tag_textfield",
    clear_and_focus_on_right_click = true,
    handlers = "add_tag.fields.text"
  })

  if player.mod_settings[PREFIX .. "favorites-on"].value and cache.get_available_fave_slots(player) < 10 then
    table.insert(container_elements, { type = "label", caption = "Favorite" })
    table.insert(container_elements, {
      type = "checkbox",
      name = "checkbox-favorite",
      save_as = "fields.favorite",
      state = element_favorite,
    })
  end

  table.insert(container_elements, {
    type = "choose-elem-button",
    name = "elem-icon",
    save_as = "fields.icon",
    style = "fav_bar_slot_button_in_shallow_frame",
    elem_type = "signal",
    signal = icon,
    --mouse_button_filter={"left"},
    handlers = "add_tag.fields.icon"
  })

  return
  {
    name = "gui-tag-edit",
    type = "frame",
    save_as = "root_frame",
    direction = "vertical",
    handlers = "add_tag.root_frame",
    children = {

      {
        type = "frame",
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

      {
        type = "frame",
        name = "table-container",
        style = "inside_shallow_frame_with_padding",
        direction = "vertical",
        children = {
          {
            type = "table",
            name = "table-proper",
            column_count = 2,
            style = PREFIX .. "add_tag_table",
            children = container_elements
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

--- Close the gui and remove player refs to AddTag
function add_tag_GUI.on_player_removed(player_index)
  local player = game.get_player(player_index)
  if not player then return end

  add_tag_GUI.close(player)
  storage.qmtt.GUI.AddTag.players[player_index] = nil
end

-- Handle confirmation (Enter key)
script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name == "add_tag_GUI" then
    event.element.parent.destroy()
  end
end)

function add_tag_GUI.is_open(player)
  if not player then return end

  return player.gui.screen["gui-tag-edit"] ~= nil
end

function add_tag_GUI.format_position_text(position)
  return string.format("x: %d, y: %d", math.floor(position.x), math.floor(position.y))
end

add_tag_GUI.gui_position = {}

function add_tag_GUI.open(player, position_to_open_from)
  if not player or not position_to_open_from or position_to_open_from == {} then return end

  control.close_guis(player)
  -- Don't allow the interface on a space platform
  if map_tag_utils.is_on_space_platform(player) then return end

  add_tag_GUI.gui_position = position_to_open_from

  local posTxt = add_tag_GUI.format_position_text(add_tag_GUI.gui_position)

  -- find tags with position =
  local _tags = cache.get_chart_tags_from_cache(player)
  local _tag = wutils.find_element_by_position(_tags, "position", add_tag_GUI.gui_position)
  local _qmtt = cache.get_matching_qmtt_by_position(player.physical_surface_index, add_tag_GUI.gui_position)
  local new_tag_text = ""
  local new_tag_icon = { type = "virtual", name = "" }

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
      idx = add_tag_GUI.format_position_text(add_tag_GUI.gui_position),
      position = add_tag_GUI.gui_position,
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
    { add_tag_frame_template(player, posTxt, new_tag_text, new_tag_icon, _qmtt, element_favorite) })

  elements.root_frame.force_auto_center()
  elements.fields.text.focus()

  elements.buttons.draggable_space_header.drag_target = elements.root_frame
  elements.buttons.draggable_space_footer.drag_target = elements.root_frame
end

function add_tag_GUI.close(player)
  if not player then return end

  if add_tag_GUI.is_open(player) then
    player.gui.screen["gui-tag-edit"].destroy()
  end
end

function add_tag_GUI.get_position()
  local pos = add_tag_GUI.gui_position
  if tostring(pos.x) == "-0" then pos.x = 0 end
  if tostring(pos.y) == "-0" then pos.y = 0 end
  return pos
end

function add_tag_GUI.get_text(player)
  if not player then return "" end

  if add_tag_GUI.is_open(player) then
    local _txt = player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["text-name"].text
    return wutils.limit_text(_txt, 256)
  else
    return ""
  end
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

--- TODO rename this to favorite state
function add_tag_GUI.get_favorite_state(player)
  if not player then return false end

  if add_tag_GUI.is_open(player) and
      player.mod_settings[PREFIX .. "favorites-on"].value and
      cache.get_available_fave_slots(player) < 10 then
    return player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["checkbox-favorite"].state
  end
  return false
end

function add_tag_GUI.get_icon(player)
  if not player then return nil end

  if add_tag_GUI.is_open(player) then
    return player.gui.screen["gui-tag-edit"]["table-container"]["table-proper"]["elem-icon"].elem_value
  end
  return nil
end

local function on_fields_values_changed(event)
  -- check for button pressed
  local player = game.get_player(event.player_index)
  if not player then return end

  if add_tag_GUI.is_open(player) then
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
        local stub = ""
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
          if not player then return end

          add_tag_GUI.close(player)
        end
      },
      confirm = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          if not player then return end

          map_tag_utils.save_tag(
            player,
            add_tag_GUI.get_position(),
            add_tag_GUI.get_text(player),
            add_tag_GUI.get_icon(player),
            "", --add_tag_GUI.get_displaytext(player),
            "", --add_tag_GUI.get_description(player),
            add_tag_GUI.get_favorite_state(player)
          )
          add_tag_GUI.close(player)
          control.update_uis(player) -- this is just fav_bar update
        end
      },
      teleport = {
        on_gui_click = function(event)
          local player = game.get_player(event.player_index)
          if not player then return end

          local target_position = add_tag_GUI.get_position()
          local og_position = player.position
          local og_surface_index = player.physical_surface_index
          local tele_pos, msg = map_tag_utils.teleport_player_to_closest_position(player, target_position)

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
      }
    }
  }
}

return add_tag_GUI
