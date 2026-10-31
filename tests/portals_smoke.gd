extends Node
## Two real peers plus actual lobby and placeholder scenes.
var lobby: Node
var host_mode := false

func _ready() -> void:
	lobby = load("res://scenes/world/lobby.tscn").instantiate()
	add_child(lobby)
	host_mode = "--test-host" in OS.get_cmdline_user_args()
	var error: Error
	if host_mode:
		error = Network.host("Anfitrião portais")
	else:
		error = Network.join_room("Visitante portais", "ws://127.0.0.1:9080")
	if error != OK:
		_fail("Não foi possível conectar: " + error_string(error))
		return
	_run.call_deferred()

func _wait_until(condition: Callable, description: String) -> bool:
	var deadline := Time.get_ticks_msec() + 10000
	while not condition.call():
		if Time.get_ticks_msec() > deadline:
			_fail("Timeout: " + description)
			return false
		await get_tree().create_timer(0.02).timeout
	return true

func _fail(message: String) -> void:
	push_error("PORTALS FAIL: " + message)
	get_tree().quit(1)

func _run() -> void:
	if not await _wait_until(func(): return Network.players.size() == 2, "dois jogadores"):
		return
	if host_mode:
		await _run_host()
	else:
		await _run_client()

func _run_host() -> void:
	Network.request_zone("invalid")
	Network.request_zone("math")
	if Network.players[1].zone != "lobby":
		_fail("Servidor aceitou destino inválido ou portal distante")
		return
	# Give the client time to try a remote request from its original spawn.
	await get_tree().create_timer(0.5).timeout
	for id in Minigames.GAME_IDS:
		var point: Vector2 = Minigames.PORTALS[id].position
		# Fixture positioning only; transitions use the public navigation API.
		Network.players[1].position = point
		Network.request_zone(id)
		if lobby.current_zone != id or not is_instance_valid(lobby.game_view):
			_fail("Cena do anfitrião não abriu: " + id)
			return
		await get_tree().create_timer(0.15).timeout
		lobby.game_view._return()
		if lobby.current_zone != "lobby" or Network.players[1].position != point:
			_fail("Retorno do anfitrião perdeu posição")
			return
	var client_id := 0
	for id in Network.players:
		if id != 1:
			client_id = id
	for id in Minigames.GAME_IDS:
		Network.players[client_id].position = Minigames.PORTALS[id].position
		if not await _wait_until(func(): return Network.players[client_id].zone == id, "visitante entrou: " + id):
			return
		if lobby.bears[client_id].visible:
			_fail("Visitante ainda visível na praça durante minijogo")
			return
		if not await _wait_until(func(): return Network.players[client_id].zone == "lobby", "visitante voltou: " + id):
			return
		if not lobby.bears[client_id].visible:
			_fail("Visitante não reapareceu na praça")
			return
		# Let the client observe the return before the next fixture relocates it.
		await get_tree().create_timer(0.35).timeout
	if not await _wait_until(func(): return Network.players.size() == 1, "desconexão"):
		return
	print("PORTALS PASS: host validated entries, all scenes and remote visibility/return")
	Network.leave("")
	get_tree().quit(0)

func _run_client() -> void:
	var local_id := multiplayer.get_unique_id()
	Network.request_zone("math")
	await get_tree().create_timer(0.25).timeout
	if Network.players[local_id].zone != "lobby":
		_fail("RPC aceitou entrada distante")
		return
	for id in Minigames.GAME_IDS:
		var point: Vector2 = Minigames.PORTALS[id].position
		if not await _wait_until(func(): return Network.players[local_id].position.distance_to(point) < 1, "posição de entrada: " + id):
			return
		Network.request_zone(id)
		if not await _wait_until(func(): return lobby.current_zone == id, "cena visitante: " + id):
			return
		await get_tree().create_timer(0.2).timeout
		if not is_instance_valid(lobby.game_view):
			_fail("Cena visitante ausente")
			return
		lobby.game_view._return()
		if not await _wait_until(func(): return lobby.current_zone == "lobby", "retorno visitante: " + id):
			return
		if Network.players[local_id].position != point:
			_fail("Retorno do visitante perdeu posição")
			return
		await get_tree().create_timer(0.15).timeout
	print("PORTALS PASS: remote distance rejection, three entries and returns without reconnect")
	Network.leave("")
	get_tree().quit(0)
