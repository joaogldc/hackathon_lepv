extends Node
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func capture(filename: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if DisplayServer.get_name() != "headless":
		get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../.tools/" + filename + ".png"))
func _ready() -> void:
	Arcade.set_physics_process(false)
	Network.set_physics_process(false)
	Progress.set_process(false)
	Progress.storage_path = ProjectSettings.globalize_path("res://../.tools/hud_ship_test_progress.json")
	for level in range(3):
		for sample in range(500):
			var q: Dictionary = Duel.generate_question(level)
			var parts: PackedStringArray = q.question.split(" ")
			check(q.answer == int(parts[0]) * int(parts[2]), "Incorrect multiplication")
			check(q.explanation.ends_with("= %d" % q.answer),"Incorrect explained result")
			check(q.options.size() == 4 and q.options.count(q.answer) == 1, "Answer choices")
	var ui := preload("res://scripts/minigames/math/duel_ui.gd").new()
	add_child(ui)
	await capture("hud-nova-entrada")
	Duel.view = {"phase":"choose", "ids":[1,2], "names":["Lopes","Rival"], "attacker":0,"cards":[[2,2,1],[2,2,1]],"energy":[5,3],"turn":1,"seconds":25,"revision":1}
	ui._refresh()
	await capture("hud-nova-cartas")
	Duel.view.merge({"phase":"answer","question":"99 × 79 = ?","options":[7821,7921,7721,7801],"revision":2},true)
	ui._refresh()
	var found_confirm := false
	for child in ui.overlay.get_children():
		if child is Button and child.text == "Confirmar":
			found_confirm = true
			check(Rect2(376,203,400,374).encloses(child.get_rect()), "Confirm button outside panel")
	check(found_confirm,"Missing confirm")
	await capture("hud-nova-conta")
	Duel.view.merge({"phase":"resolve","feedback":"Defesa perfeita!\n99 × 79 = 7821\n99 × 70 + 99 × 9\n= 6930 + 891 = 7821","revision":3},true)
	ui._refresh()
	await capture("hud-nova-resultado")
	ui.queue_free()
	await get_tree().process_frame
	Duel.view = {}
	Network.active = true
	Network.players = {1:{"zone":"ship","position":Vector2(576,500)}}
	Progress.player_keys = {1:"hud_ship_test"}
	Progress.profiles = {"hud_ship_test":Progress.fresh()}
	Arcade.command("race",5)
	var s: Dictionary = Arcade.sessions[1]
	s.objects = [{"type":"obstacle","p":s.position+Vector2(110,0),"age":0.0,"variant":0}]
	Arcade._step(1,0.016)
	check(s.phase=="question","Obstacle question")
	check(not Arcade.view.question.has("correct"),"Answer exposed")
	var revision: int = s.revision
	Arcade.command("answer",int(s.question.correct),revision)
	Arcade.command("answer",int(s.question.correct),revision)
	check(s.score==1 and s.boost>0,"Score/duplicate answer")
	Arcade.command("continue",0,int(s.revision))
	s.coins=3
	s.score=2
	Arcade._finish(1,true)
	Arcade._finish(1,true)
	check(Progress.profiles.hud_ship_test.coins==13,"Duplicate reward")
	Arcade.command("leave")
	Network.active=false
	Network.players.clear()
	Progress.player_keys.clear()
	var deck := preload("res://scenes/world/navio_deque.tscn").instantiate()
	add_child(deck)
	await capture("navio-destaques")
	deck._iniciar_bote(1)
	check(deck.desafio.kind=="race","Boat should open race")
	deck.desafio._start()
	check(Arcade.view.phase=="run","Race start")
	Arcade.sessions[1].objects = [{"type":"obstacle","p":Vector2(850,410),"age":0.0,"variant":0},{"type":"coin","p":Vector2(670,340),"age":0.0,"variant":0}]
	Arcade._send(1)
	await capture("navio-corrida")
	Arcade._ask(1)
	await capture("navio-pergunta")
	deck._voltar_deque({})
	check(Arcade.sessions.is_empty(),"Race cleanup")
	await get_tree().process_frame
	deck._iniciar_bote(2)
	check(deck.desafio.kind=="race","Second boat")
	deck._voltar_deque({})
	print("HUD SHIP PASS: 1500 multiplications, layout, collisions, answers, rewards, both boats" if failures==0 else "HUD SHIP FAIL: %d" % failures)
	get_tree().quit(0 if failures==0 else 1)
