extends Node
const DECK = preload("res://scripts/education/question_deck.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("ARCADE FAIL: " + message)

func _ready() -> void:
	Arcade.set_process(false)
	Network.set_physics_process(false)
	Progress.set_process(false)
	Progress.storage_path = ProjectSettings.globalize_path("res://../.tools/arcade_test_progress.json")
	for subject in ["portuguese", "science"]:
		for grade in range(1, 10):
			var deck: Array = DECK.build(subject, grade)
			check(deck.size() >= 3, "missing grade/subject")
			for question in deck:
				check(question.options.size() == (3 if grade <= 3 else 4), "choice count")
				check(question.options[int(question.correct)] == question.answers[int(question.get("correct_original", 0))], "correct answer preserved")
	# Simulate an isolated authoritative session, without opening a socket or touching real saves.
	Network.active = true
	Network.players = {1: {"zone": "ship", "position": Vector2(576, 500)}}
	Progress.player_keys = {1: "arcade_test"}
	Progress.profiles = {"arcade_test": Progress.fresh()}
	Arcade.command("race", 5)
	var s: Dictionary = Arcade.sessions[1]
	s.objects = [{"type": "obstacle", "p": s.position + Vector2(150, 0), "age": 0.0, "variant": 0}]
	Arcade._step(1, 0.016)
	check(s.phase == "question", "obstacle triggers question")
	check(not Arcade.view.question.has("correct") and not Arcade.view.question.has("answers"), "answer hidden before submission")
	var revision: int = s.revision
	Arcade.command("answer", int(s.question.correct), revision)
	check(s.score == 1 and s.boost > 0 and s.phase == "feedback", "correct boost")
	Arcade.command("answer", int(s.question.correct), revision)
	check(s.score == 1, "duplicate answer rejected")
	Arcade.command("continue", 0, int(s.revision))
	s.rank = 2
	Arcade._ask(1)
	s.deadline = Time.get_ticks_msec() - 1
	Arcade.command("answer", int(s.question.correct), int(s.revision))
	check(s.penalty == 1 and s.rank == 3 and s.slow > 0 and s.review.size() == 1, "timeout, lost position and review")
	Arcade.command("continue", 0, int(s.revision))
	s.coins = 3
	s.score = 2
	Arcade._finish(1, true)
	var balance: int = Progress.profiles.arcade_test.coins
	Arcade._finish(1, true)
	check(Progress.profiles.arcade_test.coins == balance and balance == 13, "reward once")
	check(Progress.profiles.arcade_test.stats.get("reading_complete", 0) == 1, "story completion")
	Arcade.command("leave")
	Network.players[1].zone = "science"
	Arcade.command("rocket", 9)
	s = Arcade.sessions[1]
	s.fuel = 25.0
	Arcade._ask(1)
	Arcade.command("answer", int(s.question.correct), int(s.revision))
	check(s.fuel == 100 and s.invincible > 0 and s.boost > 0, "honey refill and turbo")
	Arcade.command("continue", 0, int(s.revision))
	s.fuel = 0.001
	Arcade._step(1, 0.05)
	check(s.phase == "result" and not s.completed, "empty tank game over")
	var before: int = s.score
	Arcade.command("answer", 0, int(s.revision))
	check(s.score == before, "answers after result rejected")
	Arcade.command("leave")
	check(Arcade.sessions.is_empty(), "leave clears session")
	Network.active = false
	Network.players.clear()
	Progress.player_keys.clear()
	for path in ["res://scenes/minigames/language/corrida_glacial.tscn", "res://scenes/minigames/science/foguete_madeira.tscn", "res://scenes/world/navio_deque.tscn"]:
		var game: Control = load(path).instantiate()
		add_child(game)
		await get_tree().process_frame
		if game.has_method("_start"):
			game._start()
			check(game.state.phase == "run", "scene starts")
			Arcade.command("leave")
		game.queue_free()
		await get_tree().process_frame
	print("ARCADE PASS: grade decks, timed answers, collision, reward, fuel and scene loading" if failures == 0 else "ARCADE FAILED: %d" % failures)
	get_tree().quit(0 if failures == 0 else 1)
