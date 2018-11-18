--antigrief things made by mewmew

local event = require 'utils.event'

local function admin_only_message(str)
	for _, player in pairs(game.connected_players) do
		if player.admin == true then
			player.print("Admins-only-message: " .. str, { r=0.88, g=0.88, b=0.88})
		end
	end
end

local jail_messages = {
	"You´re done bud!",
	"Busted!"
}
local function jail(player, source_player)
	local permission_group = game.permissions.get_group("prisoner")		
	if not permission_group then
		permission_group = game.permissions.create_group("prisoner")
		for action_name, _ in pairs(defines.input_action) do
			permission_group.set_allows_action(defines.input_action[action_name], false)
		end
		permission_group.set_allows_action(defines.input_action.write_to_console, true)
		permission_group.set_allows_action(defines.input_action.gui_click, true)
		permission_group.set_allows_action(defines.input_action.gui_selection_state_changed, true)		
	end
	permission_group.add_player(player.name)
	game.print(player.name .. " has been jailed. " .. jail_messages[math.random(1, #jail_messages)], { r=0.98, g=0.66, b=0.22})
	admin_only_message(player.name .. " was jailed by " .. source_player.name)
end

local freedom_messages = {
	"Yaay!",
	"Welcome back!"
}
local function free(player, source_player)
	local permission_group = game.permissions.get_group("Default")
	permission_group.add_player(player.name)
	game.print(player.name .. " was set free from jail. " .. freedom_messages[math.random(1, #freedom_messages)], { r=0.98, g=0.66, b=0.22})
	admin_only_message(source_player.name .. " set " .. player.name .. " free from jail")
end

local bring_player_messages = {
	"Come here my friend!",
	"Papers, please.",
	"What are you up to?"
}
local function bring_player(player, source_player)
	local pos = source_player.surface.find_non_colliding_position("player", source_player.position, 50, 1)
	if pos then
		player.teleport(pos, source_player.surface)
		game.print(player.name .. " has been teleported to " .. source_player.name .. ". " .. bring_player_messages[math.random(1, #bring_player_messages)], { r=0.98, g=0.66, b=0.22})
	end
end

local go_to_player_messages = {
	"Papers, please.",
	"What are you up to?"
}
local function go_to_player(player, source_player)
	local pos = player.surface.find_non_colliding_position("player", player.position, 50, 1)
	if pos then
		source_player.teleport(pos, player.surface)
		game.print(source_player.name .. " is visiting " .. player.name .. ". " .. go_to_player_messages[math.random(1, #go_to_player_messages)], { r=0.98, g=0.66, b=0.22})
	end
end

local function spank(player, source_player)
	if player.character then
		if player.character.health > 1 then player.character.damage(1, "player") end
		player.character.health = player.character.health - 5
		player.surface.create_entity({name = "water-splash", position = player.position})
		game.print(source_player.name .. " spanked " .. player.name, { r=0.98, g=0.66, b=0.22})
	end
end

local damage_messages = {
	" recieved a love letter from ",
	" recieved a strange package from "
}
local function damage(player, source_player)
	if player.character then
		if player.character.health > 1 then player.character.damage(1, "player") end
		player.character.health = player.character.health - 125
		player.surface.create_entity({name = "big-explosion", position = player.position})
		game.print(player.name .. damage_messages[math.random(1, #damage_messages)] .. source_player.name, { r=0.98, g=0.66, b=0.22})		
	end
end

local kill_messages = {
	" did not obey the law.",
	" should not have triggered the admins.",
	" did not respect authority.",
	" had a strange accident.",
	" was struck by lightning."
}
local function kill(player, source_player)
	if player.character then
		player.character.die("player")
		game.print(player.name .. kill_messages[math.random(1, #kill_messages)], { r=0.98, g=0.66, b=0.22})
		admin_only_message(source_player.name .. " killed " .. player.name)
	end
end

local enemy_messages = {
	"Shoot on sight!",
	"Wanted dead or alive!"
}
local function enemy(player, source_player)
	if not game.forces.enemy_players then game.create_force("enemy_players") end
	player.force = game.forces.enemy_players
	game.print(player.name .. " is now an enemy! " .. enemy_messages[math.random(1, #enemy_messages)], {r=0.95, g=0.15, b=0.15})
	admin_only_message(source_player.name .. " has turned " .. player.name .. " into an enemy")	
end

local function ally(player, source_player)
	player.force = game.forces.player
	game.print(player.name .. " is our ally again!", {r=0.98, g=0.66, b=0.22})
	admin_only_message(source_player.name .. " made " .. player.name .. " our ally")	
end

local function turn_off_global_speakers(player, source_player)
	local speakers = source_player.surface.find_entities_filtered({name = "programmable-speaker"})
	local counter = 0
	for i, speaker in pairs(speakers) do
		if speaker.parameters.playback_globally == true then
			speaker.surface.create_entity({name = "massive-explosion", position = speaker.position})
			speaker.die("player")
			counter = counter + 1
		end
	end
	if counter == 0 then return end
	if counter == 1 then
		game.print(source_player.name .. " has nuked " .. counter .. " global speaker.", { r=0.98, g=0.66, b=0.22})
	else
		game.print(source_player.name .. " has nuked " .. counter .. " global speakers.", { r=0.98, g=0.66, b=0.22})
	end
end

local function create_admin_panel(player)
	if player.gui.left["admin_panel"] then player.gui.left["admin_panel"].destroy() end
	
	local player_names = {}
	for _, p in pairs(game.connected_players) do
		--if player.name ~= p.name then
		table.insert(player_names, p.name)
		--end
	end	
	
	local frame = player.gui.left.add({type = "frame", name = "admin_panel", direction = "vertical"})
	
	local l = frame.add({type = "label", caption = "Select Player:"})
	l.style.font = "default-listbox"
	l.style.font_color = { r=0.98, g=0.66, b=0.22}
	
	
	local drop_down = frame.add({type = "drop-down", name = "admin_player_select", items = player_names, selected_index = #player_names})
	drop_down.style.right_padding = 12
	drop_down.style.left_padding = 12
			
	local t = frame.add({type = "table", column_count = 3})
	local buttons = {
		t.add({type = "button", caption = "Jail", name = "jail", tooltip = "Jails the player, they will no longer be able to perform any actions except writing in chat."}),
		t.add({type = "button", caption = "Free", name = "free", tooltip = "Frees the player from jail."}),			
		t.add({type = "button", caption = "Bring Player", name = "bring_player", tooltip = "Teleports the selected player to your position."}),
		t.add({type = "button", caption = "Make Enemy", name = "enemy", tooltip = "Sets the selected players force to enemy_players.          DO NOT USE IN PVP MAPS!!"}),
		t.add({type = "button", caption = "Make Ally", name = "ally", tooltip = "Sets the selected players force back to the default player force.           DO NOT USE IN PVP MAPS!!"}),
		t.add({type = "button", caption = "Go to Player", name = "go_to_player", tooltip = "Teleport yourself to the selected player."}),		
		t.add({type = "button", caption = "Spank", name = "spank", tooltip = "Hurts the selected player with minor damage. Can not kill the player."}),
		t.add({type = "button", caption = "Damage", name = "damage", tooltip = "Damages the selected player with greater damage. Can not kill the player."}),
		t.add({type = "button", caption = "Kill", name = "kill", tooltip = "Kills the selected player instantly."})
		
	}
	for _, button in pairs(buttons) do
		button.style.font = "default-bold"
		button.style.font_color = { r=0.99, g=0.11, b=0.11}
		button.style.minimal_width = 96
	end
	
	local l = frame.add({type = "label", caption = "----------------------------------------------"})
	local l = frame.add({type = "label", caption = "Global Actions:"})
	local t = frame.add({type = "table", column_count = 3})
	local buttons = {
		t.add({type = "button", caption = "Nuke all Global Speakers", name = "turn_off_global_speakers"})
	}
	for _, button in pairs(buttons) do
		button.style.font = "default-bold"
		button.style.font_color = { r=0.98, g=0.66, b=0.22}
		button.style.minimal_width = 80
	end
	
	if global.landfill_history then
		local l = frame.add({type = "label", caption = "----------------------------------------------"})
		local l = frame.add({type = "label", caption = "Landfill History:"})
		l.style.font = "default-listbox"
		l.style.font_color = { r=0.98, g=0.66, b=0.22}
		local scroll_pane = frame.add({ type = "scroll-pane", direction = "vertical", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto"})
		scroll_pane.style.maximal_height = 160
		for i = #global.landfill_history, 1, -1 do
			scroll_pane.add({type = "label", caption = global.landfill_history[i]})
		end
	end
end

local admin_functions = {
		["jail"] = jail,
		["free"] = free,
		["bring_player"] = bring_player,
		["spank"] = spank,
		["damage"] = damage,
		["kill"] = kill,	
		["turn_off_global_speakers"] = turn_off_global_speakers,
		["enemy"] = enemy,
		["ally"] = ally,
		["go_to_player"] = go_to_player
	}

local function on_gui_click(event)
	local player = game.players[event.player_index]
	
	local name = event.element.name
	if name == "admin_button" then		
		if player.gui.left["admin_panel"] then
			player.gui.left["admin_panel"].destroy()
		else
			create_admin_panel(player)
		end
		return
	end
	
	if admin_functions[name] then
		local target_player_name = player.gui.left["admin_panel"]["admin_player_select"].items[player.gui.left["admin_panel"]["admin_player_select"].selected_index]
		if not target_player_name then return end
		local target_player = game.players[target_player_name]
		if target_player.connected == true then
			admin_functions[name](target_player, player)
		end
	end
end

event.add(defines.events.on_gui_click, on_gui_click)
