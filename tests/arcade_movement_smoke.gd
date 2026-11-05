extends Node
## Continuous keyboard/render regression. Run with --max-fps 60, not isolated _step calls.
const GAME := preload("res://scripts/minigames/arcade_game.gd")
var failures := 0
var held_keys: Array[int] = []
var game: Control
var metrics: Array[Dictionary] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("MOVEMENT FAIL: " + message)

func key(code: int, pressed: bool) -> void:
	# Another native window can steal focus from a rendered test run. Each scripted
	# press starts a focused input sequence; the explicit focus-loss test below
	# intentionally sends no new presses until its stop assertions are complete.
	if pressed and is_instance_valid(game): game.notification(NOTIFICATION_WM_WINDOW_FOCUS_IN)
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	# parse_input_event is buffered; consume it before synchronous mapping assertions.
	Input.flush_buffered_events()
	if pressed and not held_keys.has(code): held_keys.append(code)
	elif not pressed: held_keys.erase(code)

func release_keys() -> void:
	for code in held_keys.duplicate(): key(code, false)

func frames(count: int) -> void:
	for frame in range(count): await get_tree().process_frame

func visual_position() -> Vector2:
	# Fallback also lets this scene quantify the original snapshot-only regression.
	var rendered: Variant = game.get("render_position")
	return rendered if rendered is Vector2 else game.state.get("position",Vector2.ZERO)

func _ready() -> void:
	get_tree().create_timer(40).timeout.connect(func(): release_keys(); push_error("MOVEMENT TEST TIMEOUT"); get_tree().quit(2))
	Network.set_physics_process(false)
	Progress.set_process(false)
	Network.active = false
	Network.players.clear()
	# Let native startup/focus events settle before injecting a held key. A late
	# native focus-in releases buffered key state and is unrelated to gameplay.
	if DisplayServer.get_name() != "headless":
		get_window().grab_focus()
		await get_tree().create_timer(0.8).timeout
	for kind in ["race","rocket"]:
		await run_kind(kind)
	print("MOVEMENT METRICS: " + JSON.stringify(metrics))
	print("ARCADE MOVEMENT PASS: keyboard, continuous frames, release, focus, phases, diagonals and limits" if failures == 0 else "ARCADE MOVEMENT FAIL: %d" % failures)
	release_keys()
	get_tree().quit(0 if failures == 0 else 1)

func run_kind(kind: String) -> void:
	game = GAME.new()
	game.kind = kind
	add_child(game)
	await frames(2)
	Arcade.command(kind,1)
	var session: Dictionary = Arcade.sessions[1]
	# Keep this a sustained control test rather than interrupting it with random hazards.
	session.spawn_clock = 999.0
	session.coin_clock = 999.0
	session.honey_clock = 999.0
	await frames(4)
	check(game.has_method("_sample_intent") and game.has_method("_advance_visuals"),kind+": continuous presentation contract")
	if game.has_method("_sample_intent"):
		for control in [[KEY_W,Vector2.UP],[KEY_UP,Vector2.UP],[KEY_S,Vector2.DOWN],[KEY_DOWN,Vector2.DOWN],[KEY_A,Vector2.LEFT],[KEY_LEFT,Vector2.LEFT],[KEY_D,Vector2.RIGHT],[KEY_RIGHT,Vector2.RIGHT]]:
			key(control[0],true)
			check(game._sample_intent().is_equal_approx(control[1]),kind+": key mapping %d" % control[0])
			key(control[0],false)
		key(KEY_W,true)
		key(KEY_S,true)
		check(game._sample_intent().is_zero_approx(),kind+": opposite keys cancel")
		release_keys()
	var start := visual_position()
	key(KEY_W,true)
	await frames(4)
	var previous := visual_position()
	var moving_frames := 0
	var active_frames := 0
	var key_frames := 0
	var max_step := 0.0
	var total_frames := 24
	for frame in range(total_frames):
		await frames(1)
		var current := visual_position()
		var step := current.distance_to(previous)
		if game.get("controls_active"): active_frames+=1
		if Input.is_physical_key_pressed(KEY_W): key_frames+=1
		if step > 0.001: moving_frames += 1
		max_step = maxf(max_step,step)
		previous = current
	var end := visual_position()
	check(end.y < start.y-20,kind+": W moves up")
	var continuity := float(moving_frames)/total_frames
	metrics.append({"kind":kind,"moving_frames":moving_frames,"frames":total_frames,"active_frames":active_frames,"held_key_frames":key_frames,"continuity":continuity,"max_step_px":max_step})
	check(continuity > 0.9,kind+": movement must change on more than 90%% of rendered frames (got %.1f%%)" % (continuity*100))
	key(KEY_W,false)
	await frames(10)
	var stopped := visual_position()
	await frames(12)
	check(visual_position().distance_to(stopped)<1.5,kind+": release must not leave movement stuck")
	check(session.intent.is_zero_approx(),kind+": released input reaches authority")
	# Arrows and WASD must map to the same controls.
	key(KEY_DOWN,true)
	if game.has_method("_sample_intent"): check(game._sample_intent().y>0,kind+": down arrow sampled")
	await frames(12)
	key(KEY_DOWN,false)
	await frames(8)
	check(visual_position().y>stopped.y+15,kind+": arrow controls move down")
	var before := visual_position()
	key(KEY_D,true)
	await frames(12)
	key(KEY_D,false)
	await frames(8)
	check(visual_position().x>before.x+15,kind+": horizontal control")
	key(KEY_A,true)
	key(KEY_W,true)
	if game.has_method("_sample_intent"):
		var diagonal: Vector2 = game._sample_intent()
		check(diagonal.x<0 and diagonal.y<0 and diagonal.length()<=1.001,kind+": diagonal does not move faster")
	await frames(6)
	release_keys()
	# Losing focus must stop command delivery even if a key was held.
	key(KEY_S,true)
	await frames(2)
	game.notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	if game.has_method("_sample_intent"): check(game._sample_intent().is_zero_approx(),kind+": focus loss clears controls")
	await frames(10)
	check(session.intent.is_zero_approx(),kind+": focus loss stops authority")
	release_keys()
	game.notification(NOTIFICATION_WM_WINDOW_FOCUS_IN)
	# During a question and feedback the underlying craft must stay still.
	Arcade._ask(1)
	await frames(6)
	var quiz_position := visual_position()
	key(KEY_D,true)
	key(KEY_S,true)
	if game.has_method("_sample_intent"): check(game._sample_intent().is_zero_approx(),kind+": quiz blocks flight controls")
	await frames(12)
	check(visual_position().distance_to(quiz_position)<1.5,kind+": question does not move craft")
	release_keys()
	Arcade.command("answer",int(session.question.correct),int(session.revision))
	await frames(3)
	var feedback_position := visual_position()
	key(KEY_W,true)
	await frames(10)
	check(visual_position().distance_to(feedback_position)<1.5,kind+": feedback does not move craft")
	release_keys()
	Arcade.command("continue",0,int(session.revision))
	await frames(3)
	# Check actual authoritative motion at both boundaries, including large steps.
	if Arcade.has_method("clamp_position"):
		var low: Vector2 = Arcade.clamp_position(kind,Vector2(-10000,-10000))
		var high: Vector2 = Arcade.clamp_position(kind,Vector2(10000,10000))
		session.position = low
		Arcade._move(1,Vector2(-1,-1))
		Arcade._step(1,0.05)
		check(session.position.is_equal_approx(low),kind+": lower boundary holds")
		session.position = high
		Arcade._move(1,Vector2(1,1))
		Arcade._step(1,0.05)
		check(session.position.is_equal_approx(high),kind+": upper boundary holds")
	else: check(false,kind+": missing shared position bounds")
	Arcade.command("leave")
	remove_child(game)
	game.queue_free()
	await frames(2)
