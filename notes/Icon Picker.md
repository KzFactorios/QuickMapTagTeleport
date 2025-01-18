
To implement a button in the text box to add an icon to the text, you can create a GUI that includes:

A text-box for entering or displaying the text.
A button next to the text-box to open a dropdown or picker for selecting an icon.
A list or grid of available icons in a pop-up window (e.g., frame or flow).
Logic to insert the chosen icon into the text.
Steps to Implement the Icon Picker
1. Create the Main GUI
Add a text-box and a button to open the icon picker.

2. Handle Button Click
When the button is clicked, display a list of icons (e.g., in a frame or scroll-pane).

3. Insert the Icon into the Text
When the user selects an icon, append the corresponding rich text tag (e.g., [img=item/iron-plate]) to the text-box.

Code Example
Here’s a full implementation:

lua
Copy code
script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    if player and player.valid then
        -- Create the main frame
        local frame = player.gui.screen.add{
            type = "frame",
            name = "icon_editor_frame",
            caption = "Add Icon to Text",
            direction = "horizontal"
        }

        -- Add the text box
        local text_box = frame.add{
            type = "text-box",
            name = "icon_text_box",
            text = "",
            tooltip = "Enter your text and click the button to add an icon.",
            word_wrap = false,
            clear_and_focus_on_right_click = true
        }

        -- Add the button to open the icon picker
        frame.add{
            type = "button",
            name = "open_icon_picker_button",
            caption = "Add Icon",
            tooltip = "Click to select an icon to add."
        }

        frame.force_auto_center()
    end
end)

-- Handle button click to open the icon picker
script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "open_icon_picker_button" then
        local player = game.get_player(event.player_index)
        if player then
            -- Create the icon picker frame
            local picker_frame = player.gui.screen.add{
                type = "frame",
                name = "icon_picker_frame",
                caption = "Select an Icon",
                direction = "vertical"
            }

            local scroll_pane = picker_frame.add{
                type = "scroll-pane",
                name = "icon_picker_scroll",
                direction = "vertical"
            }

            scroll_pane.style.maximal_height = 200

            -- Add some example icons (you can dynamically populate this list)
            local icons = {"iron-plate", "copper-plate", "signal-cyan"}
            for _, icon in ipairs(icons) do
                scroll_pane.add{
                    type = "sprite-button",
                    name = "icon_picker_" .. icon,
                    sprite = "item/" .. icon,
                    tooltip = icon
                }
            end

            picker_frame.force_auto_center()
        end
    end
end)

-- Handle icon selection
script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name:match("^icon_picker_") then
        local player = game.get_player(event.player_index)
        local icon_name = event.element.name:gsub("icon_picker_", "")
        if player then
            -- Find the text box
            local frame = player.gui.screen.icon_editor_frame
            local text_box = frame and frame.icon_text_box
            if text_box then
                -- Append the icon as rich text
                text_box.text = text_box.text .. "[img=item/" .. icon_name .. "]"
            end

            -- Close the picker frame
            if player.gui.screen.icon_picker_frame then
                player.gui.screen.icon_picker_frame.destroy()
            end
        end
    end
end)
How It Works
Main Frame:

A text-box for entering text.
A button to open the icon picker.
Icon Picker:

A dynamically populated list of icons displayed as sprite-buttons.
Icons are displayed using their corresponding rich text format (e.g., item/<name>).
Rich Text Insertion:

When an icon is selected, its rich text tag (e.g., [img=item/iron-plate]) is appended to the text-box text.
Cleanup:

The icon picker frame is closed after an icon is selected.
Customization Options
Dynamic Icon Lists: Populate the list of icons from game.item_prototypes, game.virtual_signal_prototypes, or game.fluid_prototypes to include all available icons dynamically.
Searchable Picker: Add a text-box above the icon grid to filter icons by name.
Custom Categories: Separate icons into tabs or groups for better organization.
Example of Dynamic Icon List
To dynamically populate all item icons:

lua
Copy code
for name, prototype in pairs(game.item_prototypes) do
    scroll_pane.add{
        type = "sprite-button",
        name = "icon_picker_" .. name,
        sprite = "item/" .. name,
        tooltip = name
    }
end
This approach provides a complete replication of the chart tag editor's icon functionality. Let me know if you’d like help expanding it further!