extends Node
const CATALOG := preload("res://scripts/world/world_catalog.gd")
func _ready() -> void:
	var lobby:=preload("res://scenes/world/lobby.tscn").instantiate()
	add_child(lobby)
	Progress.storage_path="user://polish_smoke.json"
	Progress.profiles={}
	Network.host("PolishTest",false,19097)
	Progress.profiles[Progress.player_keys[1]].coins=500
	Progress._publish(1)
	Network.players[1].zone="loja_pets"
	Network.players[1].position=Vector2(576,590)
	Network.players[1].pet="fish"
	Network.roster_changed.emit()
	lobby._interact_nearby()
	assert(not is_instance_valid(lobby.action_dialog),"Talking must require approaching the merchant")
	Network.interact("buy","parrot")
	assert(Network.players[1].pet=="fish","Remote equipment request from afar must be rejected")
	Network.players[1].position=CATALOG.MERCHANT
	lobby._interact_nearby()
	assert(lobby.commerce_ui.is_open())
	Network.interact("buy","parrot")
	assert(Network.players[1].pet=="parrot")
	lobby.commerce_ui.close_window()
	Network.players[1].zone="loja_cosmeticos"
	Network.roster_changed.emit()
	for outfit in ["cartola","laco_rosa"]:
		Network.interact("buy",outfit)
		assert(Network.players[1].outfit==outfit)
	Network.players[1].position=Vector2(576,590)
	Network.interact("outfit","none")
	assert(Network.players[1].outfit=="laco_rosa")
	assert(not CATALOG.collision("loja_cosmeticos",Vector2(576,551)),"Central puff collision must be gone")
	assert(CATALOG.seats("loja_cosmeticos").is_empty())
	assert(CATALOG.collision("provador",Vector2(576,500)),"Mirror must be solid")
	assert(CATALOG.collision("provador",Vector2(170,530)),"Curtains must block the wall area")
	assert(not CATALOG.collision("provador",Vector2(576,580)))
	assert(Minigames.exit_at(Vector2(559,362),"language")=="","Cave has no entry")
	assert(Minigames.exit_at(Minigames.SHIP_ENTRY,"language")=="ship")
	var quest_map:=preload("res://scripts/world/discovery_map.gd").new()
	add_child(quest_map)
	for button in quest_map.content.get_children():
		if button is Button and button.size==Vector2(68,68):
			for state in ["normal","hover","pressed","hover_pressed","focus","disabled"]:
				assert(button.get_theme_stylebox(state).corner_radius_top_left==34,"Every mission interaction must remain round")
	quest_map.queue_free()
	var before: int=Network.players[1].progress.coins
	var match_result:={"ids":[1,999],"winner":0,"names":["PolishTest","Rival"],"feedback":"Vitória"}
	Duel._reward_result(match_result,true)
	Duel._reward_result(match_result,true)
	assert(Network.players[1].progress.coins==before+25,"Match currency can only be credited once")
	lobby._show_result(match_result)
	assert(lobby.recompensa_moedas.visible)
	lobby.recompensa_moedas._continuar()
	lobby.recompensa_moedas._continuar()
	assert(Network.players[1].progress.coins==before+25,"Replaying/skipping an animation must not credit money")
	var saved=JSON.parse_string(FileAccess.get_file_as_string(Progress.storage_path))
	assert(saved[Progress.player_keys[1]].coins==before+25)
	print("POLISH PASS: merchant proximity, cosmetics, puff removal, mirror/curtain collision, inactive cave, circular states and one-time saved coins")
	get_tree().quit()
