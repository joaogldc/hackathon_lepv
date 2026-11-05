extends Node
## Start one instance with -- --movement-server and a second without it.
const GAME := preload("res://scripts/minigames/arcade_game.gd")
const PORT := 19225
var server := false
var prepared_kind := ""
var failures := 0
var game: Control
var metrics: Array[Dictionary] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("REMOTE MOVEMENT FAIL: " + message)

func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func frames(count: int) -> void:
	for frame in range(count): await get_tree().process_frame

func _ready() -> void:
	get_tree().create_timer(30).timeout.connect(func(): push_error("REMOTE MOVEMENT TIMEOUT"); get_tree().quit(2))
	server = OS.get_cmdline_user_args().has("--movement-server")
	Progress.storage_path = ProjectSettings.globalize_path("res://../.tools/remote_movement_test_progress.json")
	Progress.profiles = {}
	Progress.identity = "test-remote-movement"
	if server:
		check(Network.host("MovementHost",true,PORT)==OK,"Server listen")
		print("REMOTE MOVEMENT SERVER READY")
		return
	check(Network.join_room("MovementClient","ws://127.0.0.1:%d" % PORT)==OK,"Client connect")
	for attempt in range(300):
		if Network.players.has(multiplayer.get_unique_id()): break
		await frames(1)
	check(Network.players.has(multiplayer.get_unique_id()),"Remote registration")
	check(not multiplayer.is_server() and multiplayer.get_unique_id()>1,"Real remote peer")
	for kind in ["race","rocket"]: await run_kind(kind)
	print("REMOTE MOVEMENT METRICS: " + JSON.stringify(metrics))
	print("REMOTE MOVEMENT PASS: both games on a real client, smooth snapshots, keyboard and stop" if failures==0 else "REMOTE MOVEMENT FAIL: %d" % failures)
	_done.rpc_id(1,failures)
	await frames(12)
	Network.leave("")
	get_tree().quit(0 if failures==0 else 1)

func _process(_delta: float) -> void:
	if not server: return
	for session in Arcade.sessions.values():
		session.spawn_clock=999.0
		session.coin_clock=999.0
		session.honey_clock=999.0

@rpc("any_peer","call_remote","reliable")
func _prepare(kind: String) -> void:
	if not server or kind not in ["race","rocket"]: return
	var id := multiplayer.get_remote_sender_id()
	if not Network.players.has(id): return
	var zone := "ship" if kind=="race" else "science"
	Network.leaving_zone.emit(id,zone)
	Network.players[id].zone=zone
	Network.roster_changed.emit()
	_prepared.rpc_id(id,kind)

@rpc("authority","call_remote","reliable")
func _prepared(kind: String) -> void:
	prepared_kind=kind

@rpc("any_peer","call_remote","reliable")
func _done(client_failures: int) -> void:
	if not server: return
	print("REMOTE MOVEMENT SERVER FINISHED: client failures=%d" % client_failures)
	get_tree().create_timer(0.5).timeout.connect(func(): get_tree().quit(0 if client_failures==0 else 1))

func run_kind(kind: String) -> void:
	prepared_kind=""
	_prepare.rpc_id(1,kind)
	for attempt in range(180):
		if prepared_kind==kind: break
		await frames(1)
	check(prepared_kind==kind,kind+": server zone fixture")
	game=GAME.new()
	game.kind=kind
	add_child(game)
	Arcade.command(kind,1)
	for attempt in range(180):
		if game.state.get("kind","")==kind and game.state.get("phase","")=="run": break
		await frames(1)
	check(game.state.get("phase","")=="run",kind+": start received")
	check(Arcade.local_frame(kind).is_empty(),kind+": uses remote snapshots")
	var initial_snapshot: int=Arcade.received_snapshot
	var before: Vector2=game.render_position
	key(KEY_W,true)
	await frames(8)
	var previous: Vector2=game.render_position
	var changes := 0
	var max_step := 0.0
	var reverse_steps := 0
	for sample in range(24):
		await frames(1)
		var current: Vector2=game.render_position
		var step := current.distance_to(previous)
		if step>0.001: changes+=1
		if current.y>previous.y+0.2: reverse_steps+=1
		max_step=maxf(max_step,step)
		previous=current
	check(game.render_position.y<before.y-35,kind+": remote W movement")
	check(changes>21,kind+": continuous rendered movement")
	check(reverse_steps==0,kind+": no snapshot recoil")
	check(Arcade.received_snapshot>initial_snapshot+3,kind+": transient snapshots received")
	metrics.append({"kind":kind,"moving_frames":changes,"frames":24,"max_step_px":max_step,"reverse_steps":reverse_steps,"snapshots":Arcade.received_snapshot-initial_snapshot})
	key(KEY_W,false)
	await frames(15)
	var stopped: Vector2=game.render_position
	await frames(12)
	check(game.render_position.distance_to(stopped)<1.5,kind+": remote release stops")
	before=game.render_position
	key(KEY_D,true)
	await frames(16)
	key(KEY_D,false)
	await frames(10)
	check(game.render_position.x>before.x+25,kind+": remote horizontal control")
	Arcade.command("leave")
	remove_child(game)
	game.queue_free()
	await frames(3)
