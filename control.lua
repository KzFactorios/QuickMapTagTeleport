local gui                        = require("lib/gui")
local cache                      = require("lib/cache")
local migration                  = require("__flib__.migration")
local wutils                     = require("wct_utils")
local map_tag_utils              = require("utils/map_tag_utils")
local fave                       = require("scripts/gui/fave")
local table                      = require("__flib__.table")

--local serpent = require("serpent")

local mod_version_migrations     = require("migrations/mod_version_migrations")
local custom_input_event_handler = require("scripts/event_handlers/custom_input_event_handler")
local add_tag_GUI                = require("scripts/gui/add_tag_GUI")
local fav_bar_GUI                = require("scripts/gui/fav_bar_GUI")
local edit_fave_GUI              = require("scripts/gui/edit_fave_GUI")
local qmtt                       = require("scripts/gui/qmtt")
--local event_manager              = require("lib.event_manager")

local constants                  = require("settings/constants")
local PREFIX                     = constants.PREFIX
local next                       = next

script.on_init(function()
  gui.init()
  gui.build_lookup_tables()
  cache.init()
end)

script.on_load(function()
  gui.build_lookup_tables()
end)

script.on_configuration_changed(function(event)
  migration.on_config_changed(event, mod_version_migrations)
  edit_fave_GUI.on_configuration_changed(event)
end)

script.on_event(defines.events.on_player_created, function(event)
  cache.on_player_created(event)
end)

script.on_event(defines.events.on_pre_player_left_game, function(event)
  add_tag_GUI.on_pre_player_left_game(event)
  qmtt.on_pre_player_left_game(event)
end)

--script.on_event(defines.events.on_player_removed, add_tag_GUI.on_player_removed)

-- NOTHING IS HITTING THIS!!!!
script.on_event(defines.events.on_gui_click, function(event)
  if event.element and event.element.name == "save_tag" then
    local player = game.get_player(event.player_index)
    if player then
      local frame = player.gui.screen["custom-tag-editor"]

      if frame then
        local new_text = frame["tag_text"].text
        player.print("Saving tag with text: " .. new_text)
        frame.destroy()
      end
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local stub = "stub"
end)

-- TBD
script.on_event(defines.events.script_raised_teleported, custom_input_event_handler.on_teleport)
script.on_event(constants.events.CLOSE_WITH_TOGGLE_MAP, custom_input_event_handler.on_close_with_toggle_map)

--local _maptag_editor_open = script.generate_event_name()
--add_tag_GUI._maptag_editor_open = _maptag_editor_open
--script.on_event(_maptag_editor_open, custom_input_event_handler.on_maptag_editor_open)


script.on_event(constants.events.ADD_TAG_INPUT, custom_input_event_handler.on_add_tag)
--script.on_event(constants.events.ED_EX_INPUT, custom_input_event_handler.on_ed_ex_input)

script.on_event(defines.events.on_player_controller_changed, function(event)
  if game then
    local player = game.players[event.player_index]
    if player then
      -- edit_fave_GUI.is_open(player)
      --[[local sel_fave = cache.get_player_selected_fave(player)
      if sel_fave ~= '' then
        if sel_fave then
          edit_fave_GUI.update_ui(event.player_index)
        end
      end]]

      if player.render_mode ~= defines.render_mode.chart and
          storage.qmtt.GUI.AddTag.players[event.player_index] and
          #storage.qmtt.GUI.AddTag.players[event.player_index] > 0
      then
        storage.qmtt.GUI.AddTag.players[event.player_index].close()
        storage.qmtt.GUI.AddTag.players[event.player_index].elements = nil
      end
    end
  end
end)

script.on_event(defines.events.on_player_changed_force, function(event)
  local player = game.players[event.player_index]
  if player then
    cache.reset_surface_chart_tags(player)
  end
end)


local function reset_player_favorites(player)
  if player then

    local places = storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index]
    for i = 1, #places do
      places[i] = {}
    end

    local extended = storage.qmtt.surfaces[player.surface_index].extended_tags
    for i= 1, #extended do
      extended[i].faved_by_players = {}
    end

    cache.set_player_selected_fave(player, "")
  end
end



local __initialized = false
local function initialize()
  -- Perform initialization tasks here
  cache.init()

  for _, player in pairs(game.players) do
    if player then

      --reset_player_favorites(player)

      -- by destrying and updating, this should push faves to the end of the top bar?
      --[[if player.gui.top['mod_gui_top_frame'] and
          player.gui.top['mod_gui_top_frame']['mod_gui_inner_frame'] and
          player.gui.top['mod_gui_top_frame']['mod_gui_inner_frame']['fav_bar_GUI'] then
        player.gui.top['mod_gui_top_frame']['mod_gui_inner_frame']['fav_bar_GUI'].destroy()
      end]]

      -- clean up any legacy structures
      --[[local faves = cache.get_player_favorites(player)
      if faves then
        for i, k in pairs(faves) do
          if wutils.tableContainsKey(k, "idx") and wutils.tableContainsKey(k, "surface_id") then
            local _fave = fave.convert_qmtt_to_fave(player.index, k)
            k = _fave
          end
          if wutils.tableContainsKey(k, "_pos_idx") and wutils.tableContainsKey(k, "_chart_tag") then
            local _fave = fave.convert_old_fave_to_new(k)
            storage.qmtt.GUI.fav_bar.players[player.index].fave_places[player.surface_index][i] = _fave
          end
        end
      end]]

      cache.init_player(player)

      fav_bar_GUI.update_ui(player)
    end
  end
  __initialized = true
end




-- Run Once! script.on_event(defines.events.on_tick, nil)
script.on_event(defines.events.on_tick, function(event)
  if not __initialized then
    if game then
      initialize()
      --script.on_event(defines.events.on_tick, nil)
    end
  end

  --[[if event.tick % 20 == 0 then
    for _, player in pairs(game.connected_players) do
      local current_render_mode = player.render_mode
      local saved_render_mode = storage.qmtt.player_data[player.index].render_mode

      if saved_render_mode ~= current_render_mode then
        storage.qmtt.player_data[player.index].render_mode = current_render_mode

        if edit_fave_GUI.is_open(player) then
          edit_fave_GUI.update_ui(player.index)
        end
      end
    end
  end ]]

  if event.tick % 120 == 0 then
    for _, player in pairs(game.connected_players) do
      if player then
        local current_scale = player.display_scale
        local saved_scale = storage.qmtt.player_data[player.index].interface_scale

        if saved_scale ~= current_scale then
          -- Interface size has changed
          saved_scale = current_scale

          if edit_fave_GUI.is_open(player) then
            edit_fave_GUI.update_ui(player.index)
          end
        end
      end
    end
  end
end)

gui.add_handlers(add_tag_GUI.handlers)
gui.add_handlers(fav_bar_GUI.handlers)
gui.add_handlers(edit_fave_GUI.handlers)
gui.register_handlers()

constants.events.OPEN_STOCK_GUI = script.generate_event_name()
script.on_event(constants.events.OPEN_STOCK_GUI,
  custom_input_event_handler.on_open_stock_gui)

constants.events.FAVE_ORDER_UPDATED = script.generate_event_name()
script.on_event(constants.events.FAVE_ORDER_UPDATED,
  custom_input_event_handler.on_fave_order_updated)

constants.events.SELECTED_FAVE_CHANGED = script.generate_event_name()
script.on_event(constants.events.SELECTED_FAVE_CHANGED,
  custom_input_event_handler.on_selected_fave_changed)

script.on_event(defines.events.on_chart_tag_removed, function(event)
  qmtt.handle_chart_tag_removal(event)
end)



-- set events for hotkeys
for i = 1, 10 do
  script.on_event(PREFIX .. "teleport-to-fave-" .. i, function(event)
    local player = game.players[event.player_index]
    if player then
      local faves = cache.get_player_favorites(player)
      if faves then
        local sel_fave = faves[i]
        if sel_fave and next(sel_fave) and sel_fave._pos_idx and sel_fave._pos_idx ~= "" then
          -- TODO make this a setting
          local search_radius = 10
          map_tag_utils.teleport_player_to_closest_position(player,
            wutils.decode_position_from_pos_idx(sel_fave._pos_idx),
            search_radius)
        end
      end
    end
  end)
end


control = {}

--- for now, updates the favorites bar
function control.update_uis(player)
  if player then
    fav_bar_GUI.update_ui(player)
  end
end

return control
