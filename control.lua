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

script.on_init(function()
  log(serpent.block("on_init"))
  gui.init()
  gui.build_lookup_tables()

  for _, player in pairs(game.players) do
    cache.init_player(player)
  end
end)

script.on_load(function()
  log(serpent.block("on_load"))
  gui.build_lookup_tables()
end)

script.on_event(defines.events.on_player_created, function(event)
  log(serpent.block("on_player_created"))
  if game then
    local player = game.get_player(event.player_index)
    if not player then return end

    control.initialize(player)
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
          --cache.init_player(player)
          control.initialize(player)
        end
      end
    end
  end
end)

--- Triggered when a player leaves a multiplayer session
script.on_event(defines.events.on_player_left_game, function(event)
  control.player_leaves_game(event.player_index)
end)

--- Triggered when a player is removed from the game
script.on_event(defines.events.on_player_removed, function(event)
  control.player_leaves_game(event.player_index)
end)

script.on_event(defines.events.script_raised_teleported,
  custom_input_event_handler.on_teleport)

script.on_event(constants.events.CLOSE_WITH_TOGGLE_MAP,
  custom_input_event_handler.on_close_with_toggle_map)

script.on_event(constants.events.ADD_TAG_INPUT,
  custom_input_event_handler.on_add_tag)

script.on_event(defines.events.on_player_controller_changed, function(event)
  if game then
    local player = game.get_player(event.player_index)
    if not player then return end

    if player.render_mode ~= defines.render_mode.chart and
        storage.qmtt.GUI.AddTag.players[event.player_index] and
        #storage.qmtt.GUI.AddTag.players[event.player_index] > 0
    then
      control.close_guis(player)
    end
  end
end)

script.on_event(defines.events.on_player_changed_force, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  -- implemented to handle EditorExtensions incompat? 1/20/2025
  pcall(cache.reset_surface_chart_tags, player)
end)

-- Tick events
local RESPONSIVE_TICKS = 30 * 1
-- local TICKS_PER_MINUTE = 60 * 60 * 1
-- local TICKS_PER_FIVE_MINUTES = 60 * 60 * 5 -- 18,000 ticks

script.on_nth_tick(RESPONSIVE_TICKS, function(event)

end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  local setting_name = event.setting
  local setting_type = event.setting_type

  if setting_type == "runtime-per-user" and setting_name == PREFIX .. "favorites-on" then
    control.check_favorites_on_off_change(player)
  end
end)

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

--[[TODO decide if this is necessary to handle stock editor and/or should
      handle mod's additions for consistency
script.on_event(defines.events.on_chart_tag_added, function(event)
  qmtt.handle_chart_tag_added(event)
end)]]

script.on_event(defines.events.on_chart_tag_modified, function(event)
  qmtt.handle_chart_tag_modified(event)
end)

-- set events for hotkeys
for i = 1, 10 do
  script.on_event(prototypes.custom_input[PREFIX .. "teleport-to-fave-" .. i], function(event)
    ---@diagnostic disable-next-line: undefined-field
    local player = game.get_player(event.player_index)
    if not player then return end

    local faves = cache.get_player_favorites(player)
    if not faves then return end

    local sel_fave = faves[i]
    if sel_fave and sel_fave._pos_idx and sel_fave._pos_idx ~= "" then
      -- Teleporting on a space platform is handled at teleport function
      map_tag_utils.teleport_player_to_closest_position(player,
        wutils.decode_position_from_pos_idx(sel_fave._pos_idx))
    end
  end)
end


gui.add_handlers(add_tag_GUI.handlers)
gui.add_handlers(fav_bar_GUI.handlers)
gui.add_handlers(edit_fave_GUI.handlers)
gui.register_handlers()


control = {}

function control.initialize(player)
  if not player then return end

  cache.init_player(player)

  control.check_favorites_on_off_change(player)

  -- Helps to place the gui at the end of the guis
  log(serpent.block("player_index: " .. player.index))
  log(serpent.block(player.name))
  fav_bar_GUI.update_ui(player)
end

function control.player_leaves_game(player_index)
  add_tag_GUI.on_player_removed(player_index)
  fav_bar_GUI.on_player_removed(player_index)
  edit_fave_GUI.on_player_removed(player_index)
  cache.remove_player_data(player_index)
end

--- If the favorites are on AND the player's fave bar exists AND there are NO existing favorites
--- THEN build/init the proper storage structure for player favorites
--- If the favorites are off THEN remove the player's favorites structure
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

  -- TODO always close the stock editor
  -- not accessible, stock editor is handled by c layer
end

function control.is_edit_fave_open(player)
  return edit_fave_GUI.is_open(player)
end

--- Given a position {x,y}, remove from player's inventory
function control.remove_tag_at_position(player, position)
  if player then
    local pos_idx = wutils.format_idx_from_position(position)

    qmtt.remove_chart_tag_at_position(player, position)
    qmtt.remove_ext_tag_at_position(player, position)
    qmtt.clear_matching_selected_fave(pos_idx)
    qmtt.clear_matching_fave_places(player, pos_idx)

    qmtt.reset_chart_tags(player.physical_surface_index)
    control.update_uis(player)
  end
end

return control
