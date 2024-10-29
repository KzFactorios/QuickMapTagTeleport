local mod_gui = require("mod-gui")

for _, player in pairs(game.players) do
    local gui = mod_gui.get_frame_flow(player).hwclock
    if gui then
        gui.destroy() 
        game.print("Quick Map Tag Teleport migration complete 0.1.0")
    end  
end