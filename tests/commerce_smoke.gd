extends "res://tests/portals_smoke.gd"

func _run_host() -> void:
	var entry: Vector2 = Vector2(576, 240)
	var client_id := 0
	for id in Network.players:
		if id != 1:
			client_id = id
	Network.players[1].position = entry
	Network.request_zone("commerce")
	await get_tree().create_timer(0.35).timeout
	if lobby.current_zone != "commerce" or not lobby.commerce_view.visible or lobby.bears[client_id].visible:
		_fail("Área comercial não separou a presença dos jogadores")
		return
	Network.players[client_id].position = entry
	if not await _wait_until(func(): return Network.players[client_id].zone == "commerce", "cliente na área comercial"):
		return
	if not lobby.bears[client_id].visible:
		_fail("Jogadores na mesma área não se veem")
		return
	Network.request_zone("math")
	if Network.players[1].zone != "commerce":
		_fail("Acesso indevido a minijogo a partir das lojas")
		return
	Network.walk_to(Vector2(700, 450))
	if not await _wait_until(func(): return Network.players[1].position.distance_to(Vector2(700, 450)) < 1, "caminhada anfitrião nas lojas"):
		return
	Network.request_zone("lobby")
	if Network.players[1].zone != "commerce":
		_fail("Saída distante foi aceita")
		return
	if not await _wait_until(func(): return Network.players[client_id].zone == "lobby", "visitante voltou"):
		return
	if lobby.bears[client_id].visible:
		_fail("Visitante no lobby aparece nas lojas")
		return
	Network.walk_to(Vector2(576, 615))
	if not await _wait_until(func(): return lobby.current_zone == "lobby", "retorno automático do anfitrião"):
		return
	if absf(Network.players[1].position.x - 576) >= 90 or Network.players[1].position.y < 325:
		_fail("Posição de retorno do anfitrião incorreta")
		return
	if not await _wait_until(func(): return Network.players.size() == 1, "desconexão visitante"):
		return
	print("COMMERCE PASS: separate presence, shared commerce, walking and validated return")
	Network.leave("")
	get_tree().quit(0)

func _run_client() -> void:
	var local_id := multiplayer.get_unique_id()
	var entry: Vector2 = Vector2(576, 240)
	if not await _wait_until(func(): return Network.players[local_id].zone == "commerce", "visitante no portal"):
		return
	Network.request_zone("commerce")
	if not await _wait_until(func(): return lobby.current_zone == "commerce", "cena comercial"):
		return
	await get_tree().create_timer(0.35).timeout
	lobby._toggle_map()
	if not is_instance_valid(lobby.map_view) or lobby.map_view.zone != "commerce":
		_fail("Mapa comercial ausente")
		return
	lobby._close_map()
	# Walk around the new freestanding shop sign instead of through it.
	Network.walk_to(Vector2(800, 505))
	if not await _wait_until(func(): return Network.players[local_id].position.distance_to(Vector2(800, 505)) < 1, "visitante contornou o cavalete"):
		return
	Network.walk_to(Vector2(800, 450))
	if not await _wait_until(func(): return Network.players[local_id].position.distance_to(Vector2(800, 450)) < 1, "visitante caminhou nas lojas"):
		return
	Network.walk_to(Vector2(576, 615))
	if not await _wait_until(func(): return lobby.current_zone == "lobby", "visitante no lobby"):
		return
	if absf(Network.players[local_id].position.x - 576) >= 90 or Network.players[local_id].position.y < 325:
		_fail("Posição de retorno do visitante incorreta")
		return
	if not await _wait_until(func(): return Network.players[1].zone == "lobby", "anfitrião voltou"):
		return
	print("COMMERCE PASS: remote transition, area map, walking and lobby exit corridor")
	Network.leave("")
	get_tree().quit(0)
