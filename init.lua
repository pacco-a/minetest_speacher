local function debug_log(message)
	minetest.chat_send_all(math.random() .. " " .. message)
end

minetest.register_node("speachermod:speacher_block", {
	description = "Speacher Talker",
	tiles = {"speacher.png"},
	groups = {cracky = 3},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        minetest.chat_send_all("Le bloc Speacher a été cliqué !")
		
		-- make player speacher of zone
		local meta = minetest:get_meta(node)
		meta:set_string("activated", "true")
		meta:set_string("speacher_player", player:get_player_name())

		-- create zone structure

		for i=0,10 do
			minetest.set_node({ x = pos.x + 6, y = pos.y + i, z = pos.z + 6}, {name = "default:stone"})
		end

		for i=0,10 do
			minetest.set_node({ x = pos.x - 6, y = pos.y + i, z = pos.z - 6}, {name = "default:stone"})
		end

		for i=0,10 do
			minetest.set_node({ x = pos.x + 6, y = pos.y + i, z = pos.z - 6}, {name = "default:stone"})
		end

		for i=0,10 do
		minetest.set_node({ x = pos.x - 6, y = pos.y + i, z = pos.z + 6}, {name = "default:stone"})
		end

    end,
})

minetest.register_craft({
	type = "shapeless",
	output = "speachermod:speacher_block 3",
	recipe = { "default:cobble", "default:cobble" }
})

minetest.register_chatcommand("speacher", {
    params = "",
    description = "Donne le bloc speacher au joueur",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if player then
			-- player:get_inventory():add_item("speachermod:speacher_block 1")
			player:get_inventory():add_item("main", "speachermod:speacher_block 1")

            -- local pos = player:get_pos()
            -- minetest.set_node(pos, {name = "speachermod:speacher_block"})
            -- minetest.chat_send_player(name, "Vous avez reçu le bloc speacher.")
        else
            minetest.chat_send_player(name, "Vous n'êtes pas en jeu.")
        end
    end,
})

minetest.register_chatcommand("day", {
    params = "",
    description = "Réglez le temps à midi",
    func = function(name, param)
        minetest.set_timeofday(0.5)  -- 0.5 représente midi (0.0 est minuit, 1.0 est minuit du jour suivant)
        minetest.chat_send_player(name, "Le temps a été réglé à midi.")
    end,
})

-- Définir le nœud à surveiller
local node_to_watch = "speachermod:speacher_block"

-- Enregistrez la minuterie de nœud pour vérifier la proximité
minetest.register_abm({
    nodenames = {node_to_watch},
    interval = 1,  -- ajustez l'intervalle selon vos besoins (en secondes)
    chance = 1,    -- la minuterie s'exécutera à chaque intervalle
    action = function(pos, node, active_object_count, active_object_count_wider)
		-- check player proximity

		-- Distance de détection
		local detection_distance = 8  -- ajustez la distance selon vos besoins

		local node_meta = minetest:get_meta(node)
		
		debug_log(node_meta:get_string("activated"))
		if node_meta:get_string("activated") ~= "true" then
			return 
		end
		
    	local players = minetest.get_connected_players()
    	for _, player in ipairs(players) do
        	local player_pos = player:get_pos()
			local player_meta = minetest:get_meta(player)
        	local distance = vector.distance(pos, player_pos)

        	if distance <= detection_distance then
            	-- minetest.chat_send_all(math.random() .. " Un joueur est proche du bloc!")
				debug_log("Un joueur est proche du bloc!")
				
				if node_meta.get_string("speacher_player") ~= player.get_name() then
					debug_log("Player " .. player.get_name() .. " muted !")
					player_meta.set_string("muted", true);
				end

				-- local meta = minetest.get_meta(player)
				-- meta:set_string("player_data_" .. key, value)
			else
				debug_log("Player " .. player.get_name() .. " unmuted !")
				player_meta.set_string("muted", false);
			end
		end

    end,
})

minetest.register_on_chat_message(function(name, message)
	local player = minetest.get_player_by_name(name)

    if not minetest.check_player_privs(name, {toto_speak = true}) then
        return true, "Vous n'avez pas le droit de parler dans le chat."
    end
end)