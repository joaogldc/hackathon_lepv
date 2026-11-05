extends Node
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func capture(filename: String) -> void:
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../.tools/"+filename+".png"))
func _ready() -> void:
	get_tree().create_timer(35).timeout.connect(func(): push_error("TEST TIMEOUT"); get_tree().quit(2))
	Progress.storage_path = ProjectSettings.globalize_path("res://../.tools/observatory_test_progress.json")
	Progress.profiles = {}
	var world := preload("res://scenes/world/lobby.tscn").instantiate()
	add_child(world)
	if Network.host("ObservatoryTest",false,19213) != OK:
		push_error("Test host failed")
		get_tree().quit(2)
		return
	Network._change_zone(1,"science",true)
	await get_tree().process_frame
	check(world.game_view.has_method("_launch"),"Science should open habitat")
	var room: Control = world.game_view
	Arcade.set_physics_process(false)
	check(room.background != null,"Habitat texture")
	check(room._walk_target(Vector2(170,636)).x>=500,"Exit fence collision")
	for target in [room.LAUNCH,room.TEACHER,room.TELESCOPE]:
		room.player.position=target
		room.player.target=target
		check(room._near()!="","Habitat interactions reachable")
	room.player.position=room.START
	room.player.target=room.START
	await capture("observatorio-habitat")
	room._talk(true)
	await capture("observatorio-telescopio")
	room._close_dialog()
	room._talk(false)
	check(is_instance_valid(room.dialog),"Teacher dialog")
	room._close_dialog()
	room._launch()
	await capture("observatorio-preparar")
	var game: Control=room.game
	game.grade=5
	game._start()
	check(Arcade.view.kind=="rocket" and Arcade.view.phase=="run","Rocket starts")
	var s: Dictionary=Arcade.sessions[1]
	s.objects=[{"type":"honey","p":Vector2(450,290),"age":0.0,"variant":0},{"type":"bee","p":Vector2(750,350),"age":0.0,"variant":0}]
	Arcade._send(1)
	await capture("foguete-atmosfera")
	var fuel: float=s.fuel
	Arcade._step(1,0.05)
	check(s.fuel<fuel,"Fuel consumption")
	s.objects=[{"type":"honey","p":s.position,"age":0.0,"variant":0}]
	Arcade._step(1,0.016)
	check(s.phase=="question","Honey starts science question")
	check(not Arcade.view.question.has("correct"),"Hidden answer")
	await capture("foguete-pergunta")
	var revision: int=s.revision
	Arcade.command("answer",int(s.question.correct),revision)
	check(s.fuel==100 and s.boost>0 and s.invincible>0,"Correct answer refill and turbo")
	Arcade.command("answer",int(s.question.correct),revision)
	check(s.score==1,"Duplicate answer")
	await capture("foguete-resposta")
	Arcade.command("continue",0,int(s.revision))
	s.distance=Arcade.FINISH*0.8
	s.objects=[{"type":"bee","p":Vector2(760,350),"age":0.0,"variant":0},{"type":"honey","p":Vector2(400,300),"age":0.0,"variant":0}]
	Arcade._send(1)
	await capture("foguete-espaco")
	s.invincible=0
	s.objects=[{"type":"bee","p":s.position,"age":0.0,"variant":0}]
	fuel=s.fuel
	Arcade._step(1,0.016)
	check(s.fuel<fuel-10,"Bee collision fuel loss")
	s.fuel=0.001
	Arcade._step(1,0.05)
	check(s.phase=="result" and not s.completed,"Empty tank failure")
	Arcade.command("rocket",5)
	s=Arcade.sessions[1]
	s.score=2
	var balance: int=Progress.profiles[Progress.player_keys[1]].coins
	Arcade._finish(1,true)
	Arcade._finish(1,true)
	check(Progress.profiles[Progress.player_keys[1]].coins==balance+10,"Completion reward once")
	check(Progress.profiles[Progress.player_keys[1]].stats.get("science_complete",0)==1,"Science mission")
	game._leave()
	check(not is_instance_valid(room.game) and Arcade.sessions.is_empty(),"Return to habitat")
	get_window().size=Vector2i(960,600)
	await get_tree().process_frame
	room._launch()
	check(room.game.scale.is_equal_approx(Vector2.ONE),"Nested scaling")
	await capture("observatorio-janela-menor")
	room.game._leave()
	room._leave()
	check(Network.players[1].zone=="lobby","Return to plaza")
	Network.leave("")
	print("OBSERVATORY PASS: world navigation, habitat, telescope, teacher, launch, fuel, collisions, science, turbo, space, rewards, return and resizing" if failures==0 else "OBSERVATORY FAIL: %d" % failures)
	get_tree().quit(0 if failures==0 else 1)
