extends Node
## Run host and client processes with this scene; see docs/DESENVOLVIMENTO.md.
var elapsed := 0.0
var is_host := false
var saw_pair := false
var saw_movement := false
var initial_x := 0.0
var started := false

func _ready() -> void:
	Network.status_changed.connect(func(message: String): print("SMOKE STATUS: ", message))
	is_host = "--test-host" in OS.get_cmdline_user_args()
	var error: Error
	if is_host:
		error = Network.host("Teste anfitrião")
	else:
		error = Network.join_room("Teste visitante", "ws://127.0.0.1:9080")
	if error != OK:
		get_tree().quit(1)

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > 15.0:
		push_error("SMOKE FAIL: timeout host=%s pair=%s movement=%s" % [is_host, saw_pair, saw_movement])
		get_tree().quit(1)
		return
	if Network.players.size() == 2:
		saw_pair = true
		var client_id := 0
		for id in Network.players:
			if id != 1:
				client_id = id
		var state: Dictionary = Network.players[client_id]
		if not started:
			initial_x = state.position.x
			started = true
		if not is_host:
			Network.set_movement(Vector2.RIGHT)
		if state.position.x > initial_x + 80 and state.direction == "right":
			saw_movement = true
			if not is_host:
				print("SMOKE PASS: client received both players and server movement")
				Network.leave("")
				get_tree().quit(0)
	if is_host and saw_pair and saw_movement and Network.players.size() == 1:
		print("SMOKE PASS: server registered, moved and removed client")
		Network.leave("")
		get_tree().quit(0)
