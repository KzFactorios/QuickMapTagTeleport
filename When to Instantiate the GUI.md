Integrating a persistent GUI into the Factorio 2.0 modding lifecycle involves carefully managing the GUI's lifecycle in alignment with Factorio's events and the game's multiplayer-safe logic. Here's a breakdown of best practices:

---

### **When to Instantiate the GUI**
1. **Initialization in `on_player_created`:**
   - The **best time** to create a persistent GUI for a player is during the `on_player_created` event.
   - This ensures the GUI is created for every player who joins the game (including players who join after the game has started).
   - Example:
     ```lua
     script.on_event(defines.events.on_player_created, function(event)
         local player = game.get_player(event.player_index)
         if player.gui.screen["my_mod_gui"] == nil then
             create_gui(player) -- Your custom function to create the GUI
         end
     end)
     ```

2. **Handling Existing Players in `on_init` or `on_configuration_changed`:**
   - Use `on_init` to initialize the GUI for all existing players when the mod is first added.
   - Use `on_configuration_changed` to ensure the GUI is updated or recreated when the mod is updated.
   - Example:
     ```lua
     script.on_init(function()
         for _, player in pairs(game.players) do
             if player.gui.screen["my_mod_gui"] == nil then
                 create_gui(player)
             end
         end
     end)

     script.on_configuration_changed(function()
         for _, player in pairs(game.players) do
             -- Optionally, destroy old GUI if it needs to be refreshed
             if player.gui.screen["my_mod_gui"] then
                 player.gui.screen["my_mod_gui"].destroy()
             end
             create_gui(player)
         end
     end)
     ```

3. **On Demand:**
   - If the GUI is not meant to be always visible, create it when needed (e.g., when a button is clicked) and store its state in global variables.

---

### **When to Destroy the GUI**
1. **During `on_player_removed`:**
   - Destroy the GUI when a player is removed from the game to prevent dangling references.
   - Example:
     ```lua
     script.on_event(defines.events.on_player_removed, function(event)
         local player = game.get_player(event.player_index)
         if player and player.gui.screen["my_mod_gui"] then
             player.gui.screen["my_mod_gui"].destroy()
         end
     end)
     ```

2. **When the GUI is No Longer Needed:**
   - If your GUI is session-based (e.g., used only during specific game states or events), destroy it when it’s no longer relevant.
   - Example:
     ```lua
     function hide_gui(player)
         if player.gui.screen["my_mod_gui"] then
             player.gui.screen["my_mod_gui"].destroy()
         end
     end
     ```

3. **During `on_gui_closed`:**
   - If a player manually closes a GUI element, you may opt to destroy it depending on your use case.

---

### **Key Considerations**
- **Global State Management:**
  - Use the `global` table to track the state of your GUI and any persistent data.
  - For example, if the GUI has settings or player-specific configurations, store these in `global` for easy retrieval.

- **Event-Driven Updates:**
  - Instead of polling, update your GUI in response to game events (e.g., `on_tick`, `on_gui_click`).

- **Multiplayer Safety:**
  - Ensure GUI logic is idempotent and that all player-specific GUI operations are indexed by `player_index`.

- **Performance Optimization:**
  - Avoid recreating the GUI unnecessarily. Instead, update its contents dynamically.

- **Style and Design Consistency:**
  - Use `LuaStyle` properties to ensure the GUI aligns with Factorio’s aesthetic.

---

By following these practices, your GUI will integrate seamlessly into Factorio's lifecycle and work efficiently across different game states, even in multiplayer scenarios.