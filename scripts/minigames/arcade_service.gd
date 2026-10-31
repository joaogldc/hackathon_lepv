extends Node
## Server simulates collisions, timers and rewards. Clients send intent and answers.
signal changed
const DECK = preload("res://scripts/education/question_deck.gd")
const FINISH := 6500.0
var sessions: Dictionary = {}
var view: Dictionary = {}
var publish_clock := 0.0

func _ready() -> void:
	Network.leaving_zone.connect(func(id: int, _destination: String): sessions.erase(id))
	Network.roster_changed.connect(func():
		if not Network.active:
			sessions.clear()
			view = {}
			changed.emit()
	)

func command(action: String, value: int = 0, revision: int = -1) -> void:
	if multiplayer.is_server(): _command(1, action, value, revision)
	elif Network.active: _request.rpc_id(1, action, value, revision)

func move(intent: Vector2) -> void:
	if not intent.is_finite(): return
	if multiplayer.is_server(): _move(1, intent)
	elif Network.active: _intent.rpc_id(1, intent)

@rpc("any_peer", "call_remote", "reliable")
func _request(action: String, value: int, revision: int) -> void:
	if multiplayer.is_server(): _command(multiplayer.get_remote_sender_id(), action, value, revision)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func _intent(intent: Vector2) -> void:
	if multiplayer.is_server(): _move(multiplayer.get_remote_sender_id(), intent)

func _move(id: int, intent: Vector2) -> void:
	if sessions.has(id) and intent.is_finite():
		sessions[id].intent = intent.limit_length()
		sessions[id].intent_until = Time.get_ticks_msec() + 350

func _allowed(id: int, kind: String) -> bool:
	if not Network.active: return id == 1
	if not Network.players.has(id): return false
	return Network.players[id].zone == ("ship" if kind == "race" else "science")

func _command(id: int, action: String, value: int, revision: int) -> void:
	if action in ["race", "rocket"]:
		if not _allowed(id, action): return
		if sessions.has(id) and sessions[id].phase != "result": return
		var grade := clampi(value, 1, 9)
		var subject := "portuguese" if action == "race" else "science"
		var deck: Array = DECK.build(subject, grade)
		if deck.is_empty(): return
		sessions[id] = {"kind": action, "grade": grade, "subject": subject,
			"calibration": DECK.calibration(grade), "deck": deck, "cursor": 0,
			"phase": "run", "revision": 0, "elapsed": 0.0, "distance": 0.0,
			"position": Vector2(265, 410) if action == "race" else Vector2(576, 535),
			"intent": Vector2.ZERO, "intent_until": 0, "fuel": 100.0,
			"boost": 0.0, "slow": 0.0, "invincible": 0.0, "objects": [],
			"spawn_clock": 1.5, "coin_clock": 0.8, "honey_clock": 2.5,
			"coins": 0, "score": 0, "answers": 0, "penalty": 0,
			"rank": 4, "review": [], "feedback": "", "deadline": 0,
			"question": {}, "history": [], "completed": false, "reward": 0}
		_send(id)
		return
	if not sessions.has(id): return
	var s: Dictionary = sessions[id]
	if not _allowed(id, s.kind):
		sessions.erase(id)
		return
	if action == "leave":
		sessions.erase(id)
		return
	if revision != int(s.revision): return
	if action == "answer" and s.phase == "question":
		if value < 0 or value >= s.question.options.size(): return
		_resolve(id, value if Time.get_ticks_msec() <= s.deadline else -1)
	elif action == "continue" and s.phase == "feedback":
		s.phase = "run"
		s.revision += 1
		s.intent = Vector2.ZERO
		_send(id)

func _process(delta: float) -> void:
	if not multiplayer.is_server(): return
	# Limit the simulation step after a stall instead of jumping through collisions.
	var dt := minf(delta, 0.05)
	publish_clock += delta
	for id in sessions.keys():
		var s: Dictionary = sessions[id]
		if not _allowed(id, s.kind):
			sessions.erase(id)
			continue
		if s.phase == "question":
			_coast(id, dt)
			if s.phase == "question" and Time.get_ticks_msec() > s.deadline: _resolve(id, -1)
		elif s.phase == "run": _step(id, dt)
		if publish_clock >= 0.1 and s.phase in ["run", "question"]: _send(id)
	if publish_clock >= 0.1: publish_clock = 0.0

func _coast(id: int, dt: float) -> void:
	var s: Dictionary = sessions[id]
	# The current challenge defers its collision until the answer. Other hazards
	# cannot deal hidden damage behind the question panel.
	var speed: float = float(s.calibration.speed) * 0.18
	s.distance = minf(FINISH - 1, float(s.distance) + speed * dt)
	for object in s.objects:
		if s.kind == "race": object.p.x -= speed * 1.7 * dt
		else: object.p.y += speed * 0.8 * dt
	s.objects = s.objects.filter(func(object: Dictionary): return object.p.x >= -150 and object.p.y <= 800)
	if s.kind == "rocket":
		s.fuel = maxf(0, float(s.fuel) - float(s.calibration.speed) * 100.0 / (FINISH * 0.42) * dt * 0.15)
		if s.fuel <= 0: _finish(id, false)

func _step(id: int, dt: float) -> void:
	var s: Dictionary = sessions[id]
	s.elapsed += dt
	for field in ["boost", "slow", "invincible"]: s[field] = maxf(0, float(s[field]) - dt)
	var speed: float = s.calibration.speed * (1.7 if s.boost > 0 else (0.5 if s.slow > 0 else 1.0))
	s.distance += speed * dt
	var intent: Vector2 = s.intent if Time.get_ticks_msec() <= s.intent_until else Vector2.ZERO
	if s.kind == "race":
		s.position.y = clampf(s.position.y + intent.y * s.calibration.move * dt, 270, 530)
	else:
		s.position = (s.position + intent * float(s.calibration.move) * dt).clamp(Vector2(140, 210), Vector2(1012, 590))
		# One tank covers roughly 42% of the ascent at cruising speed.
		# This keeps honey necessary at every school-year speed.
		s.fuel = maxf(0, s.fuel - float(s.calibration.speed) * 100.0 / (FINISH * 0.42) * dt)
		if s.fuel <= 0:
			_finish(id, false)
			return
	s.spawn_clock -= dt
	s.coin_clock -= dt
	s.honey_clock -= dt
	if s.spawn_clock <= 0:
		s.spawn_clock = s.calibration.spawn
		var p: Vector2 = Vector2(1220, s.position.y) if s.kind == "race" else Vector2(randf_range(180, 972), 130)
		s.objects.append({"type": "obstacle" if s.kind == "race" else "bee", "p": p, "variant": randi_range(0, 3), "age": 0.0})
	if s.kind == "race" and s.coin_clock <= 0:
		s.coin_clock = 1.3
		s.objects.append({"type": "coin", "p": Vector2(1190, randf_range(280, 520)), "variant": 0, "age": 0.0})
	if s.kind == "rocket" and s.honey_clock <= 0:
		s.honey_clock = 5.5
		s.objects.append({"type": "honey", "p": Vector2(clampf(s.position.x, 180, 972), 120), "variant": 0, "age": 0.0})
	for index in range(s.objects.size() - 1, -1, -1):
		var object: Dictionary = s.objects[index]
		object.age += dt
		if s.kind == "race": object.p.x -= speed * 1.7 * dt
		else:
			object.p.y += speed * 0.8 * dt
			if object.type == "bee":
				object.p.x += sin(object.age * (3.8 if s.distance > FINISH * 0.5 else 2.2) + object.variant) * (100 if s.distance > FINISH * 0.5 else 45) * dt
		var offset: Vector2 = object.p - s.position
		if s.kind == "race" and object.type == "obstacle" and absf(offset.y) < 65 and offset.x < 200 and offset.x > -80:
			s.objects.remove_at(index)
			_ask(id)
			break
		if offset.length() < (66.0 if object.type == "bee" else 58.0):
			s.objects.remove_at(index)
			if object.type == "coin": s.coins += 1
			elif object.type == "honey":
				_ask(id)
				break
			elif object.type == "bee" and s.invincible <= 0:
				s.fuel = maxf(0, s.fuel - 12)
				s.invincible = 1.5
				s.slow = 1.0
		elif object.p.x < -150 or object.p.y > 800: s.objects.remove_at(index)
	if s.phase == "run" and s.distance >= FINISH: _finish(id, true)

func _ask(id: int) -> void:
	var s: Dictionary = sessions[id]
	if s.cursor >= s.deck.size():
		s.deck.shuffle()
		s.cursor = 0
	s.question = s.deck[s.cursor].duplicate(true)
	s.cursor += 1
	s.phase = "question"
	s.deadline = Time.get_ticks_msec() + int(float(s.calibration.seconds) * 1000)
	s.revision += 1
	s.intent = Vector2.ZERO
	_send(id)

func _resolve(id: int, answer: int) -> void:
	var s: Dictionary = sessions[id]
	var q: Dictionary = s.question
	var correct: bool = answer == int(q.correct)
	s.answers += 1
	if correct:
		s.score += 1
		s.rank = maxi(1, int(s.rank) - 1)
		s.boost = 3.0
		if s.kind == "rocket":
			s.fuel = 100.0
			s.invincible = 4.0
		if Network.active: Progress.record(id, "reading_correct" if s.kind == "race" else "science_correct")
	else:
		s.penalty += 1
		s.rank = mini(4, int(s.rank) + 1)
		s.slow = 2.5
		if s.kind == "rocket": s.fuel = maxf(0, s.fuel - 8)
		s.review.append({"prompt": q.prompt, "reading": q.reading, "answer": q.options[int(q.correct)], "why": q.why, "skill": q.skill})
	s.feedback = ("Acertou! Desvio perfeito e impulso." if s.kind == "race" else "Acertou! Mel cheio e turbo invulnerável.") if correct else ("Tempo esgotado. " if answer == -1 else "Vamos rever. ") + ("Colisão: uma posição perdida." if s.kind == "race" else "O pote foi perdido: −8 de mel.")
	s.explanation = q.why
	s.reference = q.options[int(q.correct)]
	s.history.append({"lesson": q.lesson, "correct": correct})
	s.phase = "feedback"
	s.revision += 1
	_send(id)

func _finish(id: int, reached_end: bool) -> void:
	var s: Dictionary = sessions[id]
	if s.phase == "result": return
	s.phase = "result"
	s.completed = reached_end
	s.revision += 1
	if Network.active:
		# Coins are collected by server collisions, never reported by the client.
		Progress.arcade_result(id, s.kind, int(s.coins), reached_end, int(s.score))
		s.reward = int(s.coins) + (10 if reached_end else 0)
	_send(id)

func _send(id: int) -> void:
	if not sessions.has(id): return
	var s: Dictionary = sessions[id]
	var public: Dictionary = s.duplicate(true)
	for key in ["deck", "intent", "intent_until", "deadline", "history"]: public.erase(key)
	public.remaining = maxf(0, (float(s.deadline) - Time.get_ticks_msec()) / 1000.0)
	public.question.erase("correct")
	if public.phase == "question":
		for key in ["why", "answers"]: public.question.erase(key)
	if id == 1: _receive(public)
	elif Network.active: _receive.rpc_id(id, public)

@rpc("authority", "call_remote", "reliable")
func _receive(state: Dictionary) -> void:
	view = state
	changed.emit()
