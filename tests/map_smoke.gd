extends "res://tests/portals_smoke.gd"
const ROUTE := ["commerce", "math", "science", "language", "lobby"]

func _run_host() -> void:
	var start: Vector2 = Network.players[1].position
	Network.travel_to("invalid")
	if Network.players[1].zone != "lobby":
		_fail("Destino de mapa inválido foi aceito")
		return
	for destination in ROUTE:
		Network.travel_to(destination)
		if lobby.current_zone != destination or Network.players.size() != 2:
			_fail("Viagem do anfitrião falhou: " + destination)
			return
		await get_tree().create_timer(0.15).timeout
	if Network.players[1].position != start:
		_fail("Retorno do mapa perdeu posição no lobby")
		return
	Network.players[1].nickname = "MAP_READY"
	var client_id := 0
	for id in Network.players:
		if id != 1:
			client_id = id
	for destination in ROUTE:
		if not await _wait_until(func(): return Network.players.has(client_id) and Network.players[client_id].zone == destination, "viagem remota: " + destination):
			return
		if lobby.bears[client_id].visible != (destination == "lobby"):
			_fail("Presença incorreta após viagem remota")
			return
		await get_tree().create_timer(0.15).timeout
	if not await _wait_until(func(): return Network.players.size() == 1, "fim do teste"):
		return
	print("MAP PASS: direct travel to every destination and presence synchronized")
	Network.leave("")
	get_tree().quit(0)

func _run_client() -> void:
	var local_id := multiplayer.get_unique_id()
	var start: Vector2 = Network.players[local_id].position
	if not await _wait_until(func(): return Network.players[1].nickname == "MAP_READY", "anfitrião pronto"):
		return
	Network.travel_to("res://not_a_destination.tscn")
	await get_tree().create_timer(0.15).timeout
	if Network.players[local_id].zone != "lobby":
		_fail("Servidor aceitou caminho arbitrário")
		return
	for destination in ROUTE:
		lobby._toggle_map()
		if not is_instance_valid(lobby.map_view) or lobby.map_view.zone != lobby.current_zone:
			_fail("Mapa não abriu na área atual")
			return
		lobby.map_view.get_node(destination).pressed.emit()
		if not await _wait_until(func(): return lobby.current_zone == destination, "destino selecionado: " + destination):
			return
		if is_instance_valid(lobby.map_view) or Network.players.size() != 2:
			_fail("Mapa não fechou ou conexão foi perdida")
			return
		await get_tree().create_timer(0.3).timeout
	if Network.players[local_id].position != start:
		_fail("Retorno do visitante perdeu posição")
		return
	print("MAP PASS: destination buttons, cross-game travel, invalid ID rejection and lobby return")
	Network.leave("")
	get_tree().quit(0)
