extends Node
func _ready() -> void:
	var world:=preload("res://scenes/world/lobby.tscn").instantiate()
	add_child(world)
	Progress.storage_path="user://requested_fixes_test.json"
	Progress.profiles={}
	assert(Network.host("FixesTest",false,19190)==OK)
	var player: Dictionary=Network.players[1]
	player.zone="loja_cosmeticos"
	player.position=Vector2(865,432)
	Network.request_zone("provador")
	assert(player.zone=="provador" and player.position.y<570)
	player.position=Vector2(576,626)
	world._process(0)
	assert(player.zone=="provador","Andar para trás não deve fechar o provador")
	world._interact_nearby()
	assert(player.zone=="loja_cosmeticos")
	player.zone="provador"
	player.position=Vector2(576,555)
	Network.roster_changed.emit()
	var profile: Dictionary=Progress.profiles[Progress.player_keys[1]]
	profile.owned.append_array(["camisa_azul","camisa_verde","chapeu_preto"])
	for outfit in ["camisa_azul","chapeu_preto","scarf_red"]: Network.interact("outfit",outfit)
	assert(profile.outfits=={"body":"camisa_azul","head":"chapeu_preto","neck":"scarf_red"})
	Network.interact("outfit","camisa_verde")
	assert(profile.outfits.head=="chapeu_preto" and profile.outfits.body=="camisa_verde")
	assert(player.progress.outfits==profile.outfits)
	assert(world.bears[1].outfits==profile.outfits)
	player.zone="language"
	player.position=Minigames.SHIP_ENTRY
	Network.request_zone("ship")
	assert(world.game_view.modo_botes,"O porto deve abrir o deque")
	var deck: Control=world.game_view
	deck.jogador.position=deck.get_node("BoteBombordo").position
	deck.jogador.target=deck.jogador.position
	deck._process(0)
	await get_tree().process_frame
	assert(is_instance_valid(deck.desafio) and Learning.view.get("phase","")=="question")
	var serial: int=Learning.view.revision
	deck._process(0)
	assert(Learning.view.revision==serial,"Contato não pode reiniciar a pergunta a cada quadro")
	deck._voltar_deque({})
	assert(not Learning.sessions.has(1) and player.zone=="ship")
	deck.jogador.position=deck.get_node("BoteBoreste").position
	deck.jogador.target=deck.jogador.position
	deck._process(0)
	await get_tree().process_frame
	assert(Learning.view.get("phase","")=="question")
	var minimap:=preload("res://scripts/ui/local_minimap.gd").new()
	assert(minimap.MARKERS.commerce.size()==3 and minimap.MARKERS.math[0][1]=="×")
	minimap.free()
	Network.leave("")
	await get_tree().process_frame
	print("REQUESTED FIXES PASS: fitting exit, slots, replication, ship, both boat contacts and local map")
	get_tree().quit(0)
