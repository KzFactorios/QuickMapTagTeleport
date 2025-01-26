# Quick Map Tag Teleport

**_And you may find yourself in another part of the world..._**


Tired of walking and running your game-time-life away? 
Can't fathom driving a car around your map, avoiding cliffs and lakes? 
Don't you just want to get there already?

What if you could simply open a dialog by **right-clicking** on the map view and teleport immediately to that location? 

Maybe you have been stymied by having to go through multiple steps just to create a map tag? 
Simply **right-click** and create your tag. That's it!

### A quick note before we begin:
- At this time, the gist of this mod is to allow the player to teleport between locations on their current surface
- You are allowed 10 favorited (hotkey) slots per surface
- It is not intended to be a transportation device to take you to other planets or space platforms
- It is also not intended to carry or automatically transport items from one place to another, with the exception of gear contained within the player's inventory
- If you use this mod to teleport on a space platform and teleport to an invalid location (like empty space without tiles) which is entirely achievable when using higher values for teleport radius, **it is entirely possible that the the player will fall and die!** It is for this reason that I have removed the mod's functionality on space platforms for the time being.

### The Favorites Bar:
- Left-click on the heart to show/hide the favorites bar 
- Left-click in the fave bar or ctrl+# on a numbered location to teleport
- Right-click on a favorite to edit hotkey assignment
- Don't want to use favorites? Head over to mod settings and turn them off.

### To move the position of the tag or delete a map tag:
- Left-click on the tag in the map view to use the stock editor to access those functions
- Right-click will allow access to the favorite checkbox.
- You can create up to 10 favorites and each successive favorite will be placed in the lowest available slot.
- If you would like to change the hotkey of the favorite, right-click on the favorite and a gui will popup that allows you to click on arrows to change the hotkey. 
- Currently, this works by swapping positions with the adjacent favorite, so you may have to do some twiddling to get things just right.

### In-A-Jam? Use a command:

##### Sometimes things do not work properly and you need a fix. For those occasions, I have provided the following commands
-----  
- Usage: /qmtt_delete_by_fave_index <fave_bar_index>
- So open up the command console by pressing the tilde (~) key and type the following: 
- (This pre-supposes that the favorite in question lives in the #3 slot)
- /qmtt_delete_by_fave_index 3
- You may have to do this twice if you rarely use commands - the console will let you know
-----  
- Usage: /qmtt_delete_by_pos_idx <pos_idx>
- pos_idx refers to the position of the tag and is in the format xxx.yyy
- You have to be very careful to get the coordinates exactly correct, but they should be provided for you if you right-click on the tag. Use the x and y values, including any minus signs and separate them with a dot.
- ex. I right click on a tag and it shows me the coordinates x: -44, y: -24
- So again, open up the command console by pressing the tilde (~) key and type the following:
- /qmtt_delete_by_pos_idx -44.-24
-----  
- I will continue to work on these issues, but I figured I'd give you a way to fix them yourselves. 

### NOT YET TESTED FOR MULTIPLAYER!
- although the only issue you may run into is uninstalling and I plan to conquer this issue soon.


#### Based on the hard work of [Quick Map Tag](https://mods.factorio.com/mod/QuickMapTag) by **[templar4522](https://mods.factorio.com/user/templar4522)** and [Tag To Teleport](https://mods.factorio.com/mod/TagToTeleport) by **[darkfrei](https://mods.factorio.com/user/darkfrei)** --

-----  
Check the changelog for further notes.