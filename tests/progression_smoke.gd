extends SceneTree
func _initialize() -> void: call_deferred("check")
func check() -> void:
	var network=root.get_node("Network")
	var progress=root.get_node("Progress")
	progress.storage_path="user://progression_smoke.json"
	progress.profiles={}
	network.players[1]={"nickname":"ProgressTest","zone":"lobby"}
	progress.attach(1,"a".repeat(64))
	var key: String=progress.player_keys[1]
	var p: Dictionary=progress.profiles[key]
	for event in ["visit_math","visit_dojo","math_correct","math_correct","math_correct","duel_win","visit_language","discover_mammoth","discover_fossil","reading_complete","visit_science","science_correct","science_correct","science_correct","science_complete"]:
		progress.record(1,event)
	assert(p.story==12,"All story nodes must be completable in order")
	assert(p.daily_awarded.size()==2)
	progress.record(1,"duel_complete")
	assert(p.daily_awarded.size()==3 and p.streak==1)
	var xp: int=p.xp
	progress.record(1,"duel_complete")
	progress.record(1,"math_correct",10)
	assert(p.xp==xp,"Daily XP and story rewards cannot be claimed twice")
	var today: int=progress.day_number()
	p.daily_day=today-1
	p.last_daily=today-1
	p.streak=4
	progress.record(1,"visit_math")
	progress.record(1,"visit_language")
	progress.record(1,"visit_science")
	progress.record(1,"math_correct",5)
	progress.record(1,"duel_complete")
	assert(p.streak==5 and p.best_streak==5,"Consecutive days must extend the streak")
	progress._roll_day(p,today+2)
	assert(p.streak==0 and p.daily_awarded.is_empty(),"Missing a day resets the current streak")
	progress._save()
	var restored=JSON.parse_string(FileAccess.get_file_as_string(progress.storage_path))
	assert(restored[key].story==12 and restored[key].xp==p.xp and restored[key].best_streak==5)
	print("PROGRESSION PASS: 12 story quests, daily rollover, one-time XP, consecutive streak, missed day and saved state")
	quit()
