#The `game` object becomes available during the runtime stage of Factorio's modding lifecycle, which occurs after the settings and prototype stages. To understand when exactly the `game` object can be accessed, let's examine the key events that happen automatically during game startup and save loading, listed in the order they occur:#

## Startup Events

1. **on_init**: Triggered when a new game is started or when a mod is added to an existing save. This event runs once for the lifetime of a save.

2. **on_load**: Fired when loading a save or when soft-mods are modified. It runs every time the game is loaded.

3. **on_configuration_changed**: Called when mod versions change or game version changes between saves. It allows mods to update their data when necessary.

## Map Loading Events

4. **on_game_created_from_scenario**: Triggered when a new game is created from a scenario.

5. **on_pre_surface_cleared**: Fired just before a surface is cleared (all entities removed and chunks deleted).

6. **on_surface_cleared**: Called after a surface has been cleared.

7. **on_surface_created**: Triggered when a new surface is created.

8. **on_player_created**: Fired when a player is created, including the first player when starting a new game.

9. **on_game_created**: Called after the game has been fully set up, including the generation of the starting area.

10. **on_tick**: This event fires every tick once the game is running. It's the heartbeat of the game and runs continuously.

The `game` object is available from the `on_init` event onwards, allowing mods to interact with the game world, players, and other game elements. However, it's important to note that certain game elements may not be fully initialized in the earliest events, so care should be taken when accessing specific game data in these early stages[1][3].

Citations:
[1] https://lua-api.factorio.com/latest/auxiliary/data-lifecycle.html
[2] https://lua-api.factorio.com/latest/events.html
[3] https://lua-api.factorio.com/latest/index-runtime.html

You're correct, and I apologize for any confusion in my previous response. Let me clarify the order of events and when the `game` object becomes available:

1. `on_init()`: This event occurs first when a new game is started or when a mod is added to an existing save. The `game` object is available during this event.

2. `on_load()`: This event runs every time a save is loaded, but not for new games or newly added mods. The `game` object is not available during this event.

3. `on_configuration_changed()`: This event runs after `on_load()` if there have been changes to mod versions, game version, or other configuration changes. The `game` object is available during this event.

The key points to remember are:

- `on_init()` and `on_load()` are mutually exclusive. A mod will either run `on_init()` (for new games/newly added mods) or `on_load()` (for existing saves), but never both in the same session.
- The `game` object is available during `on_init()` and `on_configuration_changed()`, but not during `on_load()`.
- `on_load()` is specifically designed for restoring mod state without altering game state, which is why the `game` object is not accessible during this event.

This order ensures that mods can properly initialize new games, restore state on load, and handle configuration changes while maintaining game integrity and preventing desyncs in multiplayer scenarios.

Citations:
[1] https://lua-api.factorio.com/latest/auxiliary/data-lifecycle.html
[2] https://wiki.factorio.com/Tutorial:Scripting
[3] https://wiki.factorio.com/Tutorial:Modding_tutorial/Gangsir
[4] https://lua-api.factorio.com/latest/classes/LuaBootstrap.html