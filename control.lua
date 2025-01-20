local custom_input_event_handler = require("scripts/event_handlers/custom_input_event_handler")
local edit_fave_GUI              = require("scripts/gui/edit_fave_GUI")
local add_tag_GUI                = require("scripts/gui/add_tag_GUI")
local fav_bar_GUI                = require("scripts/gui/fav_bar_GUI")
local map_tag_utils              = require("utils/map_tag_utils")
local constants                  = require("settings/constants")
local qmtt                       = require("scripts/gui/qmtt")
local wutils                     = require("wct_utils")
local cache                      = require("lib/cache")
local commands                   = require("commands")
local gui                        = require("lib/gui")
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

script.on_event(defines.events.on_player_created, function(event)
  if game then
    local player = game.players[event.player_index]
    if player then
      cache.init_player(player)
    end
  end
end)

script.on_configuration_changed(function(event)
  if event.mod_changes and event.mod_changes["QuickMapTagTeleport"] then
    local changes = event.mod_changes["QuickMapTagTeleport"]

    -- this condition indicates the mod was removed
    if changes.old_version and not changes.new_version then
      -- cleanup gui for all players
      if game then
        for _, player in pairs(game.players) do
          add_tag_GUI.on_player_removed(player.index)
          edit_fave_GUI.on_player_removed(player.index)
          fav_bar_GUI.on_player_removed(player.index)
        end
      end
      -- Mod is being removed, clean up data
      storage.qmtt = nil
    else
      if game then
        for _, player in pairs(game.players) do
          cache.init_player(player)
        end
      end
    end
  end
end)

--- Triggered when a player leaves a multiplayer session
script.on_event(defines.events.on_player_left_game, function(event)
  add_tag_GUI.on_player_removed(event.player_index)
  fav_bar_GUI.on_player_removed(event.player_index)
  edit_fave_GUI.on_player_removed(event.player_index)
  cache.remove_player_data(event.player_index)
end)

--- Triggered when a player is removed from the game
script.on_event(defines.events.on_player_removed, function(event)
  add_tag_GUI.on_player_removed(event.player_index)
  fav_bar_GUI.on_player_removed(event.player_index)
  edit_fave_GUI.on_player_removed(event.player_index)
  cache.remove_player_data(event.player_index)
end)


-- NOTHING IS CURRENTLY HITTING THESE STUBS
script.on_event(defines.events.on_gui_click, function(event)
  local stub = ""
end)

-- stock editor does not hit this
script.on_event(defines.events.on_gui_opened, function(event)
  local stub = event.gui_type
end)
-- stock editor does not hit this
script.on_event(defines.events.on_gui_closed, function(event)
  local stub = "stub"
end)


script.on_event(defines.events.script_raised_teleported, custom_input_event_handler.on_teleport)
script.on_event(constants.events.CLOSE_WITH_TOGGLE_MAP, custom_input_event_handler.on_close_with_toggle_map)
script.on_event(constants.events.ADD_TAG_INPUT, custom_input_event_handler.on_add_tag)

script.on_event(defines.events.on_player_controller_changed, function(event)
  if game then
    local player = game.players[event.player_index]
    if player then
      if player.render_mode ~= defines.render_mode.chart and
          storage.qmtt.GUI.AddTag.players[event.player_index] and
          #storage.qmtt.GUI.AddTag.players[event.player_index] > 0
      then
        control.close_guis(player)
        --storage.qmtt.GUI.AddTag.players[event.player_index].close()
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

local __initialized = false
local function initialize()
  -- Perform initialization tasks here
  --cache.init()

  for _, player in pairs(game.players) do
    if player then
      control.check_favorites_on_off_change(player)
      --reset_player_favorites(player)

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
      -- cache.init_player(player)

      -- Helps to place the gui at the end of the guis
      fav_bar_GUI.update_ui(player)
    end
  end
  __initialized = true
end

-- Tick events
local RESPONSIVE_TICKS = 30 * 1
local TICKS_PER_MINUTE = 60 * 60 * 1
local TICKS_PER_FIVE_MINUTES = 60 * 60 * 5 -- 18,000 ticks

script.on_nth_tick(RESPONSIVE_TICKS, function(event)
  if game and not __initialized then
    initialize()
  end

  --react to ui setting change?
  --[[for _, player in pairs(game.connected_players) do
    if player then
      if add_tag_GUI.is_open(player) then
        add_tag_GUI.open(player, storage.qmtt.GUI.AddTag.players[player.index].position)
      end
      if edit_fave_GUI.is_open(player) then
        edit_fave_GUI.update_ui(player.index)
      end
    end
  end--]]
end)

--[[
script.on_nth_tick(TICKS_PER_MINUTE, function(event)
  --if game then
  --end
end)

script.on_nth_tick(TICKS_PER_FIVE_MINUTES, function(event)

end)
]]

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local player = game.get_player(event.player_index)
  local setting_name = event.setting
  local setting_type = event.setting_type

  if player and setting_type == "runtime-per-user" then
    if setting_name == PREFIX .. "favorites-on" then
      control.check_favorites_on_off_change(player)
    end
  end
end)


gui.add_handlers(add_tag_GUI.handlers)
gui.add_handlers(fav_bar_GUI.handlers)
gui.add_handlers(edit_fave_GUI.handlers)
gui.register_handlers()

constants.events.OPEN_STOCK_GUI = script.generate_event_name()
script.on_event(constants.events.OPEN_STOCK_GUI, custom_input_event_handler.on_open_stock_gui)

constants.events.FAVE_ORDER_UPDATED = script.generate_event_name()
script.on_event(constants.events.FAVE_ORDER_UPDATED, custom_input_event_handler.on_fave_order_updated)

constants.events.SELECTED_FAVE_CHANGED = script.generate_event_name()
script.on_event(constants.events.SELECTED_FAVE_CHANGED, custom_input_event_handler.on_selected_fave_changed)

script.on_event(defines.events.on_chart_tag_removed, function(event)
  qmtt.handle_chart_tag_removal(event)
end)

--[[script.on_event(defines.events.on_chart_tag_added, function(event)
  qmtt.handle_chart_tag_added(event)
end)]]

script.on_event(defines.events.on_chart_tag_modified, function(event)
  qmtt.handle_chart_tag_modified(event)
end)


-- set events for hotkeys
for i = 1, 10 do
  script.on_event(PREFIX .. "teleport-to-fave-" .. i, function(event)
    ---@diagnostic disable-next-line: undefined-field
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

function control.check_favorites_on_off_change(player)
  if player.mod_settings[PREFIX .. "favorites-on"].value and
      storage.qmtt.GUI.fav_bar.players[player.index] ~= nil and
      -- cache.get_player_favorites(player) -- don't use this as it will create a new empty faves collection
      (storage.qmtt.GUI.fav_bar.players[player.index].fave_places == nil or
        #storage.qmtt.GUI.fav_bar.players[player.index].fave_places == 0) -- count of surface indices
  then
    cache.favorite_the_player_experience(player)
  elseif not player.mod_settings[PREFIX .. "favorites-on"].value then
    cache.unfavorite_the_player_experience(player)
  end
end

--- updates the favorites bar
function control.update_uis(player)
  if player then
    fav_bar_GUI.update_ui(player)
  end
end

--- obviously we cannot handle ALL guis, just handle what we know
function control.close_guis(player)
  if player then
    add_tag_GUI.close(player)
    edit_fave_GUI.close(player)
  end

  -- TODO
  -- always close the stock editor
  -- not yet accessible, stock editor is handled by c functions
end

function control.is_edit_fave_open(player)
  return edit_fave_GUI.is_open(player)
end

function control.remove_tag_at_position(player, position)
  if player then
    local pos_idx = wutils.format_idx_from_position(position)

    qmtt.remove_chart_tag_at_position(player, position)
    qmtt.remove_ext_tag_at_position(player, position)
    qmtt.clear_matching_selected_fave(pos_idx)
    qmtt.clear_matching_fave_places(player, pos_idx)

    -- reset cache and update the fave bar
    qmtt.reset_chart_tags(player.surface_index)
    control.update_uis(player)
  end
end

return control
