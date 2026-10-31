extends Node
var lobby: Node
var role := "host"
var sent := false
var handled := {}
var elapsed := 0.0
func _ready():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--role="):
			role = arg.trim_prefix("--role=")
	lobby = load("res://scenes/world/lobby.tscn").instantiate()
	add_child(lobby)
	if role == "host":
		Network.host("host",false,19081)
		_run.call_deferred()
	else:
		Network.join_room(role,"ws://127.0.0.1:19081")
func wait_for(predicate: Callable) -> bool:
	var deadline := Time.get_ticks_msec()+12000
	while not predicate.call():
		if Time.get_ticks_msec()>deadline:
			push_error("CLASSROOM FAIL timeout: " + role)
			get_tree().quit(1)
			return false
		await get_tree().create_timer(0.03).timeout
	return true
func enter(id: int):
	Network.players[id].zone = "math"
	Network.players[id].position = Vector2(576,400)
	Network._change_zone(id,"dojo")
func _run():
	if not await wait_for(func(): return Network.players.size()==3): return
	var fighter := 0
	var spectator := 0
	for id in Network.players:
		if Network.players[id].nickname=="fighter": fighter=id
		if Network.players[id].nickname=="spectator": spectator=id
	for stage in ["button","map","host_exit","disconnect"]:
		enter(1)
		enter(fighter)
		enter(spectator)
		Network.players[1].nickname="prepare"
		await get_tree().create_timer(0.2).timeout
		Duel.act("join")
		if not await wait_for(func(): return Duel.view.get("phase","")=="choose"): return
		var match_id: int = Duel.view.match_id
		if not await wait_for(func(): return Duel.watchers.has(spectator) and Duel.watchers[spectator].match_id==match_id): return
		var revision: int = Duel.matches[match_id].revision
		Duel._command(spectator,"card",0,match_id,revision)
		Duel._command(spectator,"answer",0,match_id,revision)
		if Duel.matches[match_id].revision!=revision:
			push_error("Spectator altered game")
			get_tree().quit(1)
			return
		Network.players[1].nickname=stage
		if stage=="host_exit":
			lobby.game_view._return()
		if not await wait_for(func(): return Duel.matches.has(match_id) and Duel.matches[match_id].phase=="finished"): return
		var result: Dictionary = Duel.matches[match_id]
		var expected: int = result.ids.find(fighter if stage=="host_exit" else 1)
		if result.winner!=expected or result.reason!="forfeit":
			push_error("Forfeit result incorrect")
			get_tree().quit(1)
			return
		print("CLASSROOM PASS: " + stage)
		await get_tree().create_timer(0.7).timeout
		if stage!="disconnect":
			Duel._depart(1)
			Duel._depart(fighter)
			Duel._depart(spectator)
	print("CLASSROOM PASS: all four departure routes and spectator permissions")
	get_tree().quit(0)
func _process(delta):
	elapsed+=delta
	if elapsed>40:
		push_error("CLASSROOM FAIL global timeout "+role)
		get_tree().quit(1)
	if role=="spectator" and elapsed > 2 and not Network.active:
		print("CLASSROOM PASS: spectator received match and server closure")
		get_tree().quit(0)
		return
	if role=="host" or not Network.active: return
	var id := multiplayer.get_unique_id()
	if not Network.players.has(id) or Network.players[id].zone!="dojo": return
	var v: Dictionary = Duel.view
	if role=="spectator":
		if not v.get("spectator",false): Duel.act("watch")
		elif v.has("match_id"):
			if v.has("answer") or v.has("explanation"):
				push_error("Answers leaked to spectator")
				get_tree().quit(1)
		return
	if v.is_empty():
		Duel.act("join")
		return
	if not v.has("match_id"): return
	var stage: String = Network.players[1].nickname
	var key := str(v.match_id)+stage
	if stage=="host_exit" and v.phase=="finished" and not handled.has(key):
		handled[key]=true
		if v.winner!=v.ids.find(id) or Duel.last_result.get("match_id",0)!=v.match_id:
			push_error("Winner did not receive host departure")
			get_tree().quit(1)
		return
	if v.phase!="choose" or handled.has(key): return
	if stage=="button":
		handled[key]=true
		lobby.game_view._return()
	elif stage=="map":
		handled[key]=true
		Network.travel_to("commerce")
	elif stage=="disconnect":
		Network.leave("")
		print("CLASSROOM PASS: remote fighter disconnected")
		get_tree().quit(0)
