extends Node
var client:=false
var elapsed:=0.0
var received:=false
var clothing_received:=false
var lobby: Node
func _ready() -> void:
	client="--client" in OS.get_cmdline_user_args()
	lobby=load("res://scenes/world/lobby.tscn").instantiate()
	add_child(lobby)
	if client: Network.join_room("ExpansionGuest","ws://127.0.0.1:19094")
	else:
		Progress.storage_path="user://expansion_smoke.json"
		Progress.profiles={}
		Network.host("ExpansionHost",false,19094)
		_run.call_deferred()
func _process(delta: float) -> void:
	elapsed+=delta
	if elapsed>25:
		push_error("EXPANSION FAIL: timeout")
		get_tree().quit(1)
	if client:
		var mine: int=multiplayer.get_unique_id()
		if Network.players.has(mine) and Network.players[mine].zone=="loja_pets" and Network.players[mine].get("pet","")!="parrot":
			Network.interact("buy","parrot")
		if Network.players.has(mine) and Network.players[mine].zone=="loja_cosmeticos" and Network.players[mine].get("outfit","")!="camisa_vermelha": Network.interact("buy","camisa_vermelha")
		for p in Network.players.values():
			if p.nickname=="ExpansionHost" and p.get("outfit","")=="terno_vinho": clothing_received=true
			if p.nickname=="ExpansionHost" and p.zone=="loja_pets" and p.get("pet","")=="parrot": received=true
			if received and clothing_received and p.nickname=="ExpansionHost" and p.zone=="lobby" and p.get("sitting",false):
				print("EXPANSION CLIENT PASS: shared zones, purchased clothing, parrot and seated state")
				Network.leave("")
				get_tree().quit()
func wait_for(predicate: Callable) -> bool:
	var deadline:=Time.get_ticks_msec()+12000
	while not predicate.call():
		if Time.get_ticks_msec()>deadline: return false
		await get_tree().create_timer(0.03).timeout
	return true
func _run() -> void:
	assert(await wait_for(func(): return Network.players.size()==2))
	for player_id in Network.players:
		Progress.profiles[Progress.player_keys[player_id]].coins=500
		Progress._publish(player_id)
	# Physical doors are validated on the host, including rejection from afar.
	Network._change_zone(1,"loja_pets")
	assert(Network.players[1].zone=="lobby")
	Network.travel_to("commerce")
	Network.players[1].position=Vector2(309,432)
	Network.request_zone("loja_pets")
	assert(Network.players[1].zone=="loja_pets")
	Network.players[1].position=Vector2(576,480)
	Network.interact("buy","parrot")
	assert(Network.players[1].pet=="parrot")
	var guest: int=Network.players.keys().filter(func(id): return id!=1)[0]
	Network.players[guest].zone="loja_pets"
	Network.players[guest].position=Vector2(576,480)
	assert(await wait_for(func(): return Network.players[guest].get("pet","")=="parrot"))
	await get_tree().create_timer(0.3).timeout
	Network.players[1].position=Vector2(576,610)
	Network.request_zone("commerce")
	Network.players[1].position=Vector2(843,432)
	Network.request_zone("loja_cosmeticos")
	assert(Network.players[1].zone=="loja_cosmeticos")
	Network.players[1].position=Vector2(865,432)
	Network.request_zone("provador")
	assert(Network.players[1].zone=="provador")
	Network.interact("outfit","scarf_red")
	assert(Network.players[1].outfit=="scarf_red")
	Network.travel_to("language")
	assert(Network.players[1].zone=="language")
	Network.players[1].position=Vector2(275,411)
	Network.interact("discover","mammoth")
	assert(Network.players[1].progress.stats.get("discover_mammoth",0)>0)
	Network.players[1].position=Vector2(710,500)
	Network.request_zone("ship")
	assert(Network.players[1].zone=="ship")
	Learning.act("start")
	assert(not Learning.view.has("correct") and not Learning.view.has("questions"))
	for index in range(3):
		Learning.act("answer",Learning.sessions[1].correct)
		Learning.act("next")
	assert(Learning.view.phase=="result" and Learning.view.score==3)
	assert(Network.players[1].progress.stats.get("reading_complete",0)>0)
	Network.travel_to("science")
	Learning.act("start")
	for index in range(3):
		Learning.act("answer",Learning.sessions[1].correct)
		Learning.act("next")
	assert(Network.players[1].progress.stats.get("science_complete",0)>0)
	Network.players[1].zone="loja_cosmeticos"
	Network.players[1].position=Vector2(576,480)
	Network.interact("buy","terno_vinho")
	Network.players[guest].zone="loja_cosmeticos"
	Network.players[guest].position=Vector2(576,480)
	assert(await wait_for(func(): return Network.players[guest].outfit=="camisa_vermelha"))
	assert(Network.players[guest].progress.coins==280)
	await get_tree().create_timer(0.3).timeout
	Network.travel_to("lobby")
	Network.players[1].position=Vector2(345,380)
	Network.interact("sit")
	assert(Network.players[1].sitting)
	Network.players[guest].zone="lobby"
	Network.players[guest].position=Vector2(345,380)
	Network._interact(guest,"sit","")
	assert(not Network.players[guest].sitting,"Two players cannot reserve the same seat")
	await get_tree().create_timer(0.5).timeout
	assert(await wait_for(func(): return Network.players.size()==1))
	lobby.set_process(false)
	Network.set_movement(Vector2.RIGHT)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(not Network.players[1].sitting)
	Network.interact("pet","fish")
	assert(Network.players[1].pet=="parrot","Pet switching outside its shop must be rejected")
	print("EXPANSION HOST PASS: doors, rooms, mirror scene, equipment, discoveries, private questions and stand on movement")
	get_tree().quit()
