extends Node
## The server owns positions. Clients send only a movement intent.
signal status_changed(message: String)
signal roster_changed

const GEOMETRY := preload("res://scripts/world/world_geometry.gd")
const PORT := 9080
const SPEED := 190.0
const BOUNDS := Rect2(72, 230, 1008, 400)
const MAX_PLAYERS := 8
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

func host(player_name: String, headless := false) -> Error:
	leave("")
	if OS.has_feature("web"):
		status_changed.emit("No navegador, conecte a um servidor aberto no aplicativo Godot.")
		return ERR_UNAVAILABLE
	var peer := WebSocketMultiplayerPeer.new()
	var error := peer.create_server(PORT)
	if error != OK:
		status_changed.emit("Não foi possível abrir a porta %d: %s" % [PORT, error_string(error)])
		return error
	multiplayer.multiplayer_peer = peer
	active = true
	dedicated = headless
	if not dedicated:
		_add_player(1, player_name)
	status_changed.emit("Sala aberta • porta %d" % PORT)
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
	intents.clear()
	local_intent = Vector2.ZERO
	connect_elapsed = 0.0
	tick = 0.0
	roster_changed.emit()
	if not message.is_empty():
		status_changed.emit(message)

func _connected() -> void:
	_register.rpc_id(1, nickname)
	status_changed.emit("Conectado à praça")

@rpc("any_peer", "call_remote", "reliable")
func _register(player_name: String) -> void:
	if not multiplayer.is_server():
		return
	var id := multiplayer.get_remote_sender_id()
	if players.has(id):
		return
	if players.size() >= MAX_PLAYERS:
		multiplayer.multiplayer_peer.disconnect_peer(id)
		return
	_add_player(id, player_name)

func _add_player(id: int, player_name: String) -> void:
	var clean := player_name.strip_edges().replace("\n", " ").replace("\r", " ").left(18)
	if clean.is_empty():
		clean = "Urso"
	players[id] = {"nickname": clean, "position": Vector2(300 + (players.size() % 4) * 55, 530 + (players.size() / 4) * 40), "direction": "front", "zone": "lobby", "destination": null}
	intents[id] = {"vector": Vector2.ZERO, "age": 0.0}
	roster_changed.emit()

func _disconnected(id: int) -> void:
	if multiplayer.is_server():
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
		elif previous in ["language", "science"] and destination == "lobby":
			pass
		else:
			if Minigames.nearest(players[id].position, previous) != destination:
				return
			if players[id].position.distance_to(Minigames.portal(destination).position) > 30.0:
				return
	if previous == "lobby":
		players[id].lobby_position = players[id].position if from_map else players[id].position.move_toward(Vector2(576, 447), 110.0)
	if destination == "lobby":
		players[id].position = players[id].get("lobby_position", Vector2(350, 450))
	elif destination == "commerce":
		players[id].position = Vector2(576, 465)
	elif destination == "math":
		players[id].position = Vector2(576, 490)
	players[id].position = GEOMETRY.safe_position(destination, players[id].position)
	players[id].zone = destination
	players[id].destination = null
	intents[id] = {"vector": Vector2.ZERO, "age": 0.0}
	roster_changed.emit()

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
			var intent: Dictionary = intents[id]
			intent.age += delta
			var motion: Vector2 = intent.vector if intent.age < 0.5 else Vector2.ZERO
			if motion != Vector2.ZERO:
				players[id].destination = null
			if players[id].zone not in Minigames.WORLD_ZONES:
				motion = Vector2.ZERO
			var pos: Vector2 = players[id].position
			if players[id].destination is Vector2 and players[id].zone in Minigames.WORLD_ZONES:
				var goal: Vector2 = players[id].destination
				motion = pos.direction_to(goal)
				pos = pos.move_toward(goal, SPEED * delta)
				if pos.is_equal_approx(goal):
					players[id].destination = null
			else:
				pos += motion * SPEED * delta
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
