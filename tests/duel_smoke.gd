extends Node
var host_mode := false
var elapsed := 0.0
var joined := false
var heading_to_dojo := false
var last_revision := -1
var rounds := 0
var finished_id := 0
var lobby: Node

func _ready() -> void:
	lobby = load("res://scenes/world/lobby.tscn").instantiate()
	add_child(lobby)
	host_mode = "--test-host" in OS.get_cmdline_user_args()
	if host_mode:
		Network.host("Host")
	else:
		Network.join_room("Client", "ws://127.0.0.1:9080")

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > 25:
		push_error("DUEL FAIL: timeout")
		get_tree().quit(1)
		return
	var id := multiplayer.get_unique_id()
	if not Network.players.has(id):
		return
	if not joined:
		Network.travel_to("math")
		joined = true
	if Network.players[id].zone == "math" and not heading_to_dojo:
		Network.walk_to(Vector2(576,400))
		heading_to_dojo = true
	if Network.players[id].zone != "dojo":
		return
	var v: Dictionary = Duel.view
	if v.is_empty():
		Duel.act("join")
		return
	if v.get("phase", "") == "waiting":
		return
	if v.has("answer") or v.has("explanation"):
		push_error("DUEL FAIL: answer leaked")
		get_tree().quit(1)
		return
	if host_mode and v.phase == "resolve":
		Duel.matches[v.match_id].seconds = minf(Duel.matches[v.match_id].seconds, 0.05)
	if v.phase == "finished":
		if v.match_id == finished_id:
			return
		finished_id = v.match_id
		if rounds == 0:
			if v.turn != 10 or v.energy != [0,5] or v.winner != 1:
				push_error("DUEL FAIL: incorrect final result " + str(v))
				get_tree().quit(1)
				return
			print("DUEL PASS: ten turns, cards exhausted, correct damage and winner")
			rounds = 1
			last_revision = -1
			Duel.act("join")
		elif host_mode:
			if v.winner != 0:
				push_error("DUEL FAIL: forfeit winner")
				get_tree().quit(1)
				return
			print("DUEL PASS: rematch and disconnect forfeit")
			get_tree().quit(0)
		return
	if rounds == 1:
		if not host_mode:
			print("DUEL PASS: client disconnect during rematch")
			Network.leave("")
			get_tree().quit(0)
		return
	if v.revision == last_revision:
		return
	last_revision = v.revision
	var mine: int = v.ids.find(id)
	if host_mode:
		var m: Dictionary = Duel.matches[v.match_id]
		var revision: int = m.revision
		var wrong_id: int = m.ids[1-m.attacker] if m.phase == "choose" else m.ids[m.attacker]
		Duel._command(wrong_id, "card" if m.phase == "choose" else "answer", 0, m.match_id, revision)
		Duel._command(id, "card", 0, m.match_id, revision-1)
		if m.revision != revision:
			push_error("DUEL FAIL: accepted wrong turn or stale command")
			get_tree().quit(1)
			return
	if v.phase == "choose" and mine == v.attacker:
		for level in range(3):
			if v.cards[mine][level] > 0:
				Duel.act("card", level)
				break
	elif v.phase == "answer" and mine != v.attacker:
		var parts: PackedStringArray = v.question.split(" ")
		var answer := int(parts[0]) * int(parts[2])
		for option in range(v.options.size()):
			if (v.options[option] == answer) != host_mode:
				Duel.act("answer", option)
				break
