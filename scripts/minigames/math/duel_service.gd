extends Node
## Server-only rules. RPC views exclude the answer until resolution.
signal changed
signal result_received(result: Dictionary)
var last_result: Dictionary = {}
var delivered: Dictionary = {}
var watchers: Dictionary = {}
var view: Dictionary = {}
var waiting: Array[int] = []
var matches: Dictionary = {}
var membership: Dictionary = {}
var serial := 0

func _ready() -> void:
	Network.roster_changed.connect(_roster)
	Network.leaving_zone.connect(func(id: int, _destination: String): _depart(id))

func _roster() -> void:
	if not Network.active:
		watchers.clear()
		delivered.clear()
		waiting.clear()
		matches.clear()
		membership.clear()
		view = {}
		changed.emit()
		return
	if not multiplayer.is_server():
		return
	for id in membership.keys():
		if not Network.players.has(id) or Network.players[id].zone != "dojo":
			_depart(id)
	for id in watchers.keys():
		if not Network.players.has(id) or Network.players[id].zone != "dojo":
			_depart(id)
	for id in waiting.duplicate():
		if not Network.players.has(id) or Network.players[id].zone != "dojo":
			_depart(id)

func act(action: String, value := 0) -> void:
	if not Network.active:
		return
	var match_id: int = view.get("match_id", 0)
	var revision: int = view.get("revision", 0)
	if multiplayer.is_server():
		_command(1, action, value, match_id, revision)
	else:
		_request.rpc_id(1, action, value, match_id, revision)

@rpc("any_peer", "call_remote", "reliable")
func _request(action: String, value: int, match_id: int, revision: int) -> void:
	if multiplayer.is_server():
		_command(multiplayer.get_remote_sender_id(), action, value, match_id, revision)

func _command(id: int, action: String, value: int, match_id: int, revision: int) -> void:
	if not Network.players.has(id) or Network.players[id].zone != "dojo":
		return
	if action == "leave":
		_depart(id)
		return
	if action == "watch":
		_depart(id)
		var occupied := watchers.keys().map(func(peer): return watchers[peer].seat)
		var seat := 0
		while occupied.has(seat):
			seat += 1
		if seat >= 8:
			return
		var key := 0
		for candidate in matches:
			if matches[candidate].phase != "finished":
				key = candidate
		watchers[id] = {"match_id": key, "seat": seat}
		if key != 0:
			_publish(matches[key])
		else:
			_publish_waiting()
		return
	if action == "join":
		watchers.erase(id)
		if membership.has(id):
			if matches[membership[id]].phase != "finished":
				return
			_depart(id)
		if not waiting.has(id):
			waiting.append(id)
			_send(id, {"phase": "waiting"})
		if waiting.size() >= 2:
			_start(waiting.pop_front(), waiting.pop_front())
		return
	if not membership.has(id) or membership[id] != match_id:
		return
	var m: Dictionary = matches[match_id]
	if m.revision != revision:
		return
	if action == "card" and m.phase == "choose" and id == m.ids[m.attacker]:
		if value < 0 or value > 2 or m.cards[m.attacker][value] <= 0:
			return
		_choose(m, value)
	elif action == "answer" and m.phase == "answer" and id == m.ids[1 - m.attacker]:
		if value < 0 or value >= m.options.size():
			return
		_resolve(m, m.options[value] == m.answer)

func _start(a: int, b: int) -> void:
	serial += 1
	var m := {"match_id": serial, "revision": 0, "ids": [a,b], "names": [Network.players[a].nickname, Network.players[b].nickname], "energy": [5,5], "cards": [[2,2,1],[2,2,1]], "attacker": 0, "turn": 1, "phase": "choose", "seconds": 25.0, "question": "", "options": [], "feedback": "", "winner": -1, "correct": [0,0], "attempts": [0,0]}
	matches[serial] = m
	membership[a] = serial
	membership[b] = serial
	for id in watchers:
		if watchers[id].match_id == 0 or not matches.has(watchers[id].match_id) or matches[watchers[id].match_id].phase == "finished":
			watchers[id].match_id = serial
	_publish(m)

func _choose(m: Dictionary, level: int) -> void:
	m.cards[m.attacker][level] -= 1
	var low: int = [2,4,7][level]
	var high: int = [5,9,12][level]
	var a := randi_range(low, high)
	var b := randi_range(2, high)
	m.answer = a * b
	m.question = "%d × %d = ?" % [a,b]
	m.explanation = "%d × %d = %d. São %d grupos de %d." % [a,b,a*b,a,b]
	var options: Array = [a*b]
	while options.size() < 4:
		var candidate := maxi(1, a*b + randi_range(-12,12))
		if not options.has(candidate):
			options.append(candidate)
	options.shuffle()
	m.options = options
	m.phase = "answer"
	m.seconds = 30.0
	m.feedback = ""
	_publish(m)

func _resolve(m: Dictionary, correct: bool) -> void:
	var defender: int = 1 - m.attacker
	m.attempts[defender] += 1
	if correct:
		m.correct[defender] += 1
	else:
		m.energy[defender] -= 1
	m.feedback = ("Defesa perfeita! " if correct else "Ataque acertou: −1 energia. ") + m.explanation
	m.phase = "resolve"
	m.seconds = 3.5
	_publish(m)

func _next(m: Dictionary) -> void:
	if m.energy.min() <= 0 or m.turn >= 10:
		m.phase = "finished"
		m.reason = "energy" if m.energy.min() <= 0 else "turn_limit"
		m.winner = -1 if m.energy[0] == m.energy[1] else (0 if m.energy[0] > m.energy[1] else 1)
		m.feedback = "Empate!" if m.winner == -1 else "%s venceu!" % m.names[m.winner]
		m.seconds = 0.0
	else:
		m.turn += 1
		m.attacker = 1 - m.attacker
		m.phase = "choose"
		m.seconds = 25.0
		m.question = ""
		m.options = []
	_publish(m)

func _process(delta: float) -> void:
	if not Network.active or not multiplayer.is_server():
		return
	for m in matches.values():
		if m.phase == "finished":
			continue
		m.seconds -= delta
		if m.seconds > 0:
			continue
		if m.phase == "choose":
			for level in range(3):
				if m.cards[m.attacker][level] > 0:
					_choose(m, level)
					break
		elif m.phase == "answer":
			_resolve(m, false)
		elif m.phase == "resolve":
			_next(m)

func _depart(id: int) -> void:
	waiting.erase(id)
	if watchers.has(id):
		var watched: int = watchers[id].match_id
		watchers.erase(id)
		if matches.has(watched):
			_publish(matches[watched])
		else:
			_publish_waiting()
	if membership.has(id):
		var key: int = membership[id]
		var m: Dictionary = matches[key]
		if m.phase != "finished":
			m.phase = "finished"
			m.reason = "forfeit"
			m.winner = 1 - m.ids.find(id)
			m.feedback = "%s venceu: o adversário saiu do dojo." % m.names[m.winner]
			m.seconds = 0.0
			_publish(m)
		membership.erase(id)
		if not membership.values().has(key) and not watchers.values().any(func(w): return w.match_id == key):
			matches.erase(key)
	_send(id, {})

func _publish(m: Dictionary) -> void:
	m.revision += 1
	var public := m.duplicate(true)
	public.erase("answer")
	public.erase("explanation")
	public.spectators = []
	for id in watchers:
		if watchers[id].match_id == m.match_id and Network.players.has(id):
			public.spectators.append({"id": id, "name": Network.players[id].nickname, "seat": watchers[id].seat})
	for id in m.ids:
		if membership.has(id) and membership[id] == m.match_id:
			public.spectator = false
			_send(id, public)
	for id in watchers:
		if watchers[id].match_id == m.match_id:
			public.spectator = true
			_send(id, public)

func _send(id: int, state: Dictionary) -> void:
	if id == 1:
		_receive(state)
	elif multiplayer.get_peers().has(id):
		_receive.rpc_id(id, state)

@rpc("authority", "call_remote", "reliable")
func _receive(state: Dictionary) -> void:
	view = state.duplicate(true)
	if state.get("phase", "") == "finished" and not state.get("spectator", false) and not delivered.has(state.match_id):
		delivered[state.match_id] = true
		last_result = state.duplicate(true)
		result_received.emit(last_result)
	changed.emit()

func _publish_waiting() -> void:
	var audience: Array = []
	for id in watchers:
		if watchers[id].match_id == 0 and Network.players.has(id):
			audience.append({"id": id, "name": Network.players[id].nickname, "seat": watchers[id].seat})
	for id in watchers:
		if watchers[id].match_id == 0:
			_send(id,{"phase":"watch_wait","spectator":true,"seat":watchers[id].seat,"spectators":audience})
