local wutils = require("wct_utils")

commands.add_command("qmtt_dump_storage",
    "debug method to take a look at storage vars. Usage: /qmtt_dump_storage",
    function()
        local logFormat = { comment = false, numformat = '%1.8g' }
        log(serpent.block(storage.qmtt, logFormat))
    end)

commands.add_command("qmtt_clear_storage",
    "Clears the qmtt database. This will delete all of your data (not your tags, but it will delete amy favorite info). Usage: /qmtt_clear_storage",
    function()
        storage.qmtt = nil
    end)

--- Provides a method to delete a mismatched or non-responding favorite.
commands.add_command("qmtt_delete_by_fave_index",
    "Provides a method to delete a mismatched or non-responding favorite. Usage: /qmtt_delete_by_fave_index <fave_bar_index>",
    function(parameters)
        local player = game.get_player(parameters.player_index)
        if not player then
            game.print("player not found")
            return
        end

        if not parameters.parameter then
            player.print("Usage: /qmtt_delete_by_fave_index <fave_bar_index>")
            return
        end

        local fave_idx = tonumber(parameters.parameter)
        if not fave_idx then
            player.print("Invalid value! Please enter a number.")
            return
        end

        -- correction
        if fave_idx == 0 then fave_idx = 10 end

        local base_play_faves = cache.get_player_favorites(player)
        if base_play_faves then
            local idx_fave = base_play_faves[fave_idx]

            if idx_fave then
                local fave_pos_idx = idx_fave._pos_idx

                for _, plr in pairs(game.players) do
                    local play_faves = cache.get_player_favorites(plr)

                    if play_faves then
                        game.print("favorites being updated...")

                        -- close any guis
                        control.close_guis(plr)

                        -- find and remove from player faves
                        for idx, v in ipairs(play_faves) do
                            if v._pos_idx == fave_pos_idx then
                                play_faves[idx] = {}
                                game.print(fave_pos_idx .. " removed from favorites")
                            end
                        end

                        -- reset selected fave
                        cache.set_player_selected_fave(plr, "")

                        -- find in qmtt by idx and remove from faved_by_players
                        local tags = cache.get_extended_tags(plr)
                        if tags ~= nil then
                            for _, v in ipairs(tags) do
                                if v.idx == fave_pos_idx then
                                    wutils.remove_element(v.faved_by_players, plr.index)
                                end
                            end
                        end

                        local change = false
                        local cts = cache.get_chart_tags_from_cache(plr)
                        if cts ~= nil then
                            for _, v in pairs(cts) do
                                if wutils.format_idx_from_position(v.position) == fave_pos_idx then
                                    v.destroy()
                                    change = true
                                end
                            end
                        end

                        if change then cache.reset_surface_chart_tags(plr) end

                        -- update the fave bar gui
                        control.update_uis(plr)

                        game.print("favorites have been updated.")
                    end
                end
            end
        end



        -- player can delete remaining items from map
    end)

--- Provides a method to delete any trace of a given position = idx style xxx.yyy
commands.add_command("qmtt_delete_by_pos_idx",
    "Provides a method to delete any trace of a given position by pos_idx xxx.yyy. Usage: /qmtt_delete_by_pos_idx <pos_idx>",
    function(parameters)
        local player = game.get_player(parameters.player_index)
        if not player then
            game.print("player not found")
            return
        end

        if not parameters.parameter then
            player.print("Usage: /qmtt_delete_by_pos_idx <pos_idx>")
            return
        end

        local pos_idx = parameters.parameter
        -- TODO Validate the pos_idx

        if not pos_idx then
            player.print("Invalid value! Please enter a string representing a position in the format xxx.yyy ")
            return
        end

        local parts = wutils.split(pos_idx, ".")
        if #parts ~= 2 and (type(parts[1]) ~= "number" or type(parts[2]) ~= "number") then
            player.print("Invalid value! Please enter a string representing a position in the format xxx.yyy ")
            return
        end

        -- TODO Validate the pos_idx

        for _, plr in pairs(game.players) do
            game.print("updating favorites...")

            -- close any guis
            control.close_guis(plr)

            -- delete user faves, selected_fave, chart_tag, qmtt/extended_tag
            local play_faves = cache.get_player_favorites(plr)

            if play_faves then
                for _, v in pairs(play_faves) do
                    if v._pos_idx == pos_idx then
                        v = {}
                    end
                end
            end

            cache.set_player_selected_fave(plr, "")

            local change = false
            local tags = cache.get_chart_tags_from_cache(plr)
            if tags ~= nil then
                for _, v in pairs(tags) do
                    if wutils.format_idx_from_position(v.position) == pos_idx then
                        v.destroy()
                        change = true
                    end
                end

                if change then cache.reset_surface_chart_tags(plr) end
            end

            -- note this is a bit different than the above command in that it
            -- destroys the entire qmtt
            local qmtts = cache.get_extended_tags(plr)
            if qmtts ~= nil then
                for _, v in pairs(qmtts) do
                    if v.idx == pos_idx then
                        v.destroy()
                    end
                end
            end

            -- reset fav_bar
            control.update_uis(plr)

            game.print("favorites have been updated.")
        end
    end)
