extends Node
## The server owns positions. Clients send only a movement intent.
signal status_changed(message: String)
signal roster_changed
signal leaving_zone(id: int, destination: String)

const GEOMETRY := preload("res://scripts/world/world_geometry.gd")
const CATALOG := preload("res://scripts/world/world_catalog.gd")
const PET_EMOTES := preload("res://scripts/player/pet_emotes.gd")
const PORT := 9080
const SPEED := 190.0
const BOUNDS := Rect2(72, 230, 1008, 400)
const MAX_PLAYERS := 8
const SPAWNS := [Vector2(420,535),Vector2(520,535),Vector2(620,535),Vector2(720,535),Vector2(435,575),Vector2(525,575),Vector2(615,575),Vector2(705,575)]
var players: Dictionary = {}
var intents: Dictionary = {}
var nickname := "Urso"
var active := false
var dedicated := false
var tick := 0.0
var connect_elapsed := 0.0
var local_intent := Vector2.ZERO

func _ready() -> void:
	multiplayer.connected_to_server.connect(_connected)
	multiplayer.connection_failed.connect(func(): leave("Não foi possível conectar. Confira endereço e servidor."))
	multiplayer.server_disconnected.connect(func(): leave("O servidor encerrou a sala."))
	multiplayer.peer_disconnected.connect(_disconnected)

func host(player_name: String, headless := false, server_port := PORT) -> Error:
	leave("")
	if OS.has_feature("web"):
		status_changed.emit("No navegador, conecte a um servidor aberto no aplicativo Godot.")
		return ERR_UNAVAILABLE
	var peer := WebSocketMultiplayerPeer.new()
	var error := peer.create_server(server_port)
	if error != OK:
		status_changed.emit("Não foi possível abrir a porta %d: %s" % [server_port, error_string(error)])
		return error
	multiplayer.multiplayer_peer = peer
	active = true
	dedicated = headless
	if not dedicated:
		_add_player(1, player_name, Progress.identity)
	status_changed.emit("Sala aberta • porta %d" % server_port)
	return OK

func join_room(player_name: String, url: String) -> Error:
	leave("")
	nickname = player_name.strip_edges().left(18)
	var peer := WebSocketMultiplayerPeer.new()
	var error := peer.create_client(url.strip_edges())
	if error != OK:
		status_changed.emit("Endereço inválido: %s" % error_string(error))
		return error
	multiplayer.multiplayer_peer = peer
	active = true
	status_changed.emit("Conectando…")
	return OK

func leave(message := "Você saiu da sala.") -> void:
	active = false
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	if get_node_or_null("/root/Progress"): Progress.player_keys.clear()
	intents.clear()
	local_intent = Vector2.ZERO
	connect_elapsed = 0.0
	tick = 0.0
	roster_changed.emit()
	if not message.is_empty():
		status_changed.emit(message)

func _connected() -> void:
	_register.rpc_id(1, nickname, Progress.identity)
	status_changed.emit("Conectado à praça")

@rpc("any_peer", "call_remote", "reliable")
func _register(player_name: String, token: String="") -> void:
	if not multiplayer.is_server():
		return
	var id := multiplayer.get_remote_sender_id()
	if players.has(id):
		return
	if players.size() >= MAX_PLAYERS:
		multiplayer.multiplayer_peer.disconnect_peer(id)
		return
	_add_player(id, player_name, token)

func _add_player(id: int, player_name: String, token: String="") -> void:
	var clean := player_name.strip_edges().replace("\n", " ").replace("\r", " ").left(18)
	if clean.is_empty():
		clean = "Urso"
	var occupied: Array = players.values().map(func(player): return player.get("spawn_slot", -1))
	var slot := 0
	while occupied.has(slot) and slot < SPAWNS.size()-1:
		slot += 1
	players[id] = {"spawn_slot": slot, "nickname": clean, "position": SPAWNS[slot], "direction": "front", "zone": "lobby", "destination": null}
	players[id].position = GEOMETRY.safe_position("lobby",players[id].position)
	intents[id] = {"vector": Vector2.ZERO, "age": 0.0}
	players[id].sitting=false
	players[id].seat=-1
	Progress.attach(id,token)
	roster_changed.emit()

func _disconnected(id: int) -> void:
	if multiplayer.is_server():
		leaving_zone.emit(id, "disconnected")
		players.erase(id)
		intents.erase(id)
		roster_changed.emit()

func set_movement(value: Vector2) -> void:
	local_intent = value.limit_length()

func walk_to(point: Vector2) -> void:
	if not active or not point.is_finite() or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	if multiplayer.is_server():
		_set_destination(1, point)
	else:
		_request_walk.rpc_id(1, point)

@rpc("any_peer", "call_remote", "reliable")
func _request_walk(point: Vector2) -> void:
	if multiplayer.is_server():
		_set_destination(multiplayer.get_remote_sender_id(), point)

func _set_destination(id: int, point: Vector2) -> void:
	if not point.is_finite() or not players.has(id) or players[id].zone not in Minigames.WORLD_ZONES:
		return
	if players[id].get("sitting",false): _stand(id)
	players[id].destination = point.clamp(BOUNDS.position, BOUNDS.end)
	intents[id] = {"vector": Vector2.ZERO, "age": 0.0}

func request_zone(destination: String) -> void:
	if not active or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	local_intent = Vector2.ZERO
	if multiplayer.is_server():
		_change_zone(1, destination)
	else:
		_request_zone.rpc_id(1, destination)

@rpc("any_peer", "call_remote", "reliable")
func _request_zone(destination: String) -> void:
	if multiplayer.is_server():
		_change_zone(multiplayer.get_remote_sender_id(), destination)

func travel_to(destination: String) -> void:
	if not active or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	local_intent = Vector2.ZERO
	if multiplayer.is_server():
		_change_zone(1, destination, true)
	else:
		_request_travel.rpc_id(1, destination)

@rpc("any_peer", "call_remote", "reliable")
func _request_travel(destination: String) -> void:
	if multiplayer.is_server():
		_change_zone(multiplayer.get_remote_sender_id(), destination, true)

func _change_zone(id: int, destination: String, from_map := false) -> void:
	if not players.has(id):
		return
	var previous: String = players[id].zone
	if destination == previous:
		return
	if from_map:
		if destination == "dojo" or (destination != "lobby" and not Minigames.PORTALS.has(destination)):
			return
	else:
		if previous == "dojo" and destination == "math":
			pass
		elif previous=="science" and destination=="lobby":
			pass
		elif previous in ["ship","cave"] and destination=="language":
			pass
		else:
			if Minigames.exit_at(players[id].position, previous) != destination:
				return
	leaving_zone.emit(id, destination)
	if previous == "lobby":
		players[id].lobby_position = players[id].position if from_map else players[id].position.move_toward(Vector2(576, 447), 70.0)
	if destination == "lobby":
		if not from_map and previous == "math":
			players[id].position = Vector2(175,Minigames.PORTALS.math.position.y)
		elif not from_map and previous == "commerce":
			players[id].position = Vector2(players[id].position.x,325)
		elif not from_map and previous=="language":
			players[id].position=Vector2(576,575)
		else:
			players[id].position = players[id].get("lobby_position", Vector2(350,450))
	elif destination == "commerce":
		if previous in ["loja_pets","loja_cosmeticos"]:
			players[id].position=Vector2(309 if previous=="loja_pets" else 843,480)
		else: players[id].position = Vector2(players[id].position.x,585) if not from_map else Vector2(576,530)
	elif destination in ["loja_pets","loja_cosmeticos","provador"]:
		players[id].position=Vector2(865,475) if previous=="provador" else Vector2(576,580)
	elif destination=="language":
		players[id].position=Vector2(660,510) if previous=="ship" else (Vector2(559,405) if previous=="cave" else Vector2(576,580))
	elif destination == "math":
		if previous == "dojo":
			players[id].position = Vector2(560,500)
		else:
			players[id].position = Vector2(576,580)
	players[id].position = GEOMETRY.safe_position(destination, players[id].position)
	players[id].entry_until = 0
	players[id].entry_motion = Vector2.ZERO
	if not from_map and destination in Minigames.WORLD_ZONES:
		var entry_motion := Vector2.ZERO
		if previous == "lobby" and destination == "math":
			entry_motion = Vector2.UP
		elif previous == "math" and destination == "lobby":
			entry_motion = Vector2.RIGHT
		elif previous == "lobby" and destination == "commerce":
			entry_motion = Vector2.UP
		elif previous == "commerce" and destination == "lobby":
			entry_motion = Vector2.DOWN
		elif previous == "dojo" and destination == "math":
			entry_motion = Vector2.ZERO
		elif destination in ["loja_pets","loja_cosmeticos","provador"]:
			entry_motion=Vector2.DOWN if previous=="provador" else Vector2.UP
		elif previous in ["loja_pets","loja_cosmeticos"] and destination=="commerce":
			entry_motion=Vector2.DOWN
		elif previous=="lobby" and destination=="language":
			entry_motion=Vector2.UP
		elif previous=="language" and destination=="lobby":
			entry_motion=Vector2.UP
		players[id].entry_motion = entry_motion
		players[id].entry_until = Time.get_ticks_msec() + 260
	players[id].zone = destination
	players[id].sitting=false
	players[id].seat=-1
	players[id].destination = null
	intents[id] = {"vector": Vector2.ZERO, "age": 0.0}
	Progress.record(id,"visit_"+destination)
	roster_changed.emit()

func interact(action: String, value: String="") -> void:
	if not active: return
	if multiplayer.is_server(): _interact(1,action,value)
	else: _interaction.rpc_id(1,action,value)

@rpc("any_peer","call_remote","reliable")
func _interaction(action: String,value: String) -> void:
	if multiplayer.is_server(): _interact(multiplayer.get_remote_sender_id(),action,value)

func _interact(id: int,action: String,value: String) -> void:
	if not players.has(id): return
	var p: Dictionary=players[id]
	if action=="sit":
		if p.get("sitting",false):
			_stand(id)
		else:
			var seat:=CATALOG.nearest_seat(p.zone,p.position)
			if seat<0: return
			for other in players.values():
				if other.zone==p.zone and other.get("sitting",false) and other.get("seat",-1)==seat: return
			p.sitting=true
			p.seat=seat
			p.position=CATALOG.seats(p.zone)[seat]
			p.direction="front"
			p.destination=null
			intents[id]={"vector":Vector2.ZERO,"age":0.0}
	elif action in ["pet","outfit"]:
		Progress.equip(id,action,value)
	elif action=="pet_emote" and p.zone in Minigames.WORLD_ZONES and PET_EMOTES.IDS.has(value):
		var now:=Time.get_ticks_msec()
		if now<int(p.get("pet_emote_cooldown",0)): return
		p.pet_emote=value
		p.pet_emote_until=now+3500
		p.pet_emote_cooldown=now+800
	elif action=="discover" and p.zone=="language":
		var locations:={"mammoth":Vector2(275,411),"fossil":Vector2(885,574)}
		if locations.has(value) and p.position.distance_to(locations[value])<75:
			Progress.record(id,"discover_"+value)
	roster_changed.emit()

func _stand(id: int) -> void:
	players[id].sitting=false
	players[id].seat=-1
	players[id].position=GEOMETRY.safe_position(players[id].zone,players[id].position+Vector2(0,35))

@rpc("any_peer", "call_remote", "unreliable_ordered")
func _move(value: Vector2) -> void:
	if not multiplayer.is_server() or not value.is_finite():
		return
	var id := multiplayer.get_remote_sender_id()
	if players.has(id):
		intents[id] = {"vector": value.limit_length(), "age": 0.0}

@rpc("authority", "call_remote", "unreliable_ordered")
func _snapshot(state: Dictionary) -> void:
	players = state
	roster_changed.emit()

func _physics_process(delta: float) -> void:
	if not active:
		return
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		connect_elapsed += delta
		if connect_elapsed > 10.0:
			leave("Tempo de conexão esgotado. Confira o endereço.")
		return
	if multiplayer.is_server():
		if players.has(1):
			intents[1] = {"vector": local_intent, "age": 0.0}
		for id in players:
			if Time.get_ticks_msec()>=players[id].get("pet_emote_until",0): players[id].pet_emote=""
			var intent: Dictionary = intents[id]
			intent.age += delta
			var motion: Vector2 = intent.vector if intent.age < 0.5 else Vector2.ZERO
			if Time.get_ticks_msec() < players[id].get("entry_until", 0):
				motion = players[id].get("entry_motion", Vector2.ZERO)
			if motion != Vector2.ZERO:
				if players[id].get("sitting",false): _stand(id)
				players[id].destination = null
			if players[id].get("sitting",false): continue
			if players[id].zone not in Minigames.WORLD_ZONES:
				motion = Vector2.ZERO
			var pos: Vector2 = players[id].position
			var speed:=CATALOG.walk_speed(players[id].zone)
			if players[id].destination is Vector2 and players[id].zone in Minigames.WORLD_ZONES:
				var goal: Vector2 = players[id].destination
				motion = pos.direction_to(goal)
				pos = pos.move_toward(goal, speed * delta)
				if pos.is_equal_approx(goal):
					players[id].destination = null
			else:
				pos += motion * speed * delta
			players[id].position = GEOMETRY.move(players[id].zone, players[id].position, pos.clamp(BOUNDS.position, BOUNDS.end))
			if motion != Vector2.ZERO:
				if absf(motion.x) > 0.2 and absf(motion.y) > 0.2:
					players[id].direction = ("front" if motion.y > 0 else "back") + ("_right" if motion.x > 0 else "_left")
				elif absf(motion.x) > absf(motion.y):
					players[id].direction = "right" if motion.x > 0 else "left"
				else:
					players[id].direction = "front" if motion.y > 0 else "back"
	tick += delta
	if tick >= 0.05:
		tick = 0.0
		if multiplayer.is_server():
			if not multiplayer.get_peers().is_empty():
				_snapshot.rpc(players)
			roster_changed.emit()
		else:
			_move.rpc_id(1, local_intent)
