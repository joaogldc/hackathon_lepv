extends Node
const ART := preload("res://scripts/minigames/arcade_art.gd")
const GAME := preload("res://scripts/minigames/arcade_game.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("VISUAL MOVEMENT FAIL: "+message)
func _ready() -> void:
	Arcade.set_physics_process(false)
	Network.active=false
	var art = ART.new()
	for index in range(8):
		var boat: AtlasTexture=art.boat(index)
		check(boat.get_size()==ART.BOAT_CANVAS,"Boat frame size")
		check(boat.margin.position+ART.BOAT_HULL_PIVOTS[index]-boat.region.position==ART.BOAT_PIVOT,"Boat hull registration")
		var rocket: AtlasTexture=art.rocket(index,index>=4)
		check(rocket.get_size()==ART.ROCKET_CANVAS,"Normal/turbo scale")
		check(rocket.margin.position+ART.ROCKET_BODY_PIVOTS[index]-rocket.region.position==ART.ROCKET_PIVOT,"Rocket body registration")
	for kind in ["race","rocket"]:
		var game := GAME.new()
		game.kind=kind
		add_child(game)
		game.set_process(false)
		Arcade.command(kind,1)
		var s: Dictionary=Arcade.sessions[1]
		s.spawn_clock=999
		s.coin_clock=999
		s.honey_clock=999
		Arcade._spawn(s,"coin" if kind=="race" else "bee",Vector2(950,300))
		Arcade._spawn(s,"coin" if kind=="race" else "honey",Vector2(1000,320))
		game._advance_visuals(1.0/60.0)
		var key: String=str(s.objects[0].id)
		var old_distance: float=game.render_distance
		var old_point: Vector2=game.render_objects[key].p
		var moving_objects := 0
		var moving_background := 0
		# Deliberately do not publish snapshots: host visuals must read fixed ticks.
		for tick in range(24):
			Arcade._step(1,1.0/60.0)
			game._advance_visuals(1.0/60.0)
			if game.render_distance>old_distance: moving_background+=1
			if Vector2(game.render_objects[key].p).distance_to(old_point)>0.01: moving_objects+=1
			old_distance=game.render_distance
			old_point=game.render_objects[key].p
		check(moving_objects==24 and moving_background==24,kind+": smooth objects and scenery")
		s.objects.reverse()
		game._advance_visuals(1.0/60.0)
		check(Vector2(game.render_objects[key].p).distance_to(old_point)<10,kind+": stable object IDs")
		s.objects.clear()
		game._advance_visuals(1.0/60.0)
		check(game.render_objects.is_empty(),kind+": removed object must disappear")
		if kind=="race":
			var rival: Vector2=game.rival_positions[0]
			s.rank=1
			game._advance_visuals(1.0/60.0)
			check(game.rival_positions[0].distance_to(rival)>0 and game.rival_positions[0].distance_to(rival)<30,"Rival rank transition")
			Arcade._spawn(s,"obstacle",s.position+Vector2(170,0))
			Arcade._step(1,1.0/60.0)
			check(s.phase=="run","No question before touching obstacle")
			s.objects[0].p=s.position+Vector2(110,0)
			Arcade._step(1,1.0/60.0)
			check(s.phase=="question","Visible obstacle contact still opens question")
		Arcade._send(1)
		var published: Dictionary=Arcade.view.duplicate(true)
		var seq: int=Arcade.received_snapshot
		published.snapshot_id=seq-1
		published.position=Vector2(-900,-900)
		Arcade._receive(published)
		check(Arcade.view.position.x>=0,"Stale snapshot cannot rewind position")
		Arcade.command("leave")
		remove_child(game)
		game.queue_free()
	print("ARCADE VISUAL PASS: stable sprite pivots, normal/turbo scale, smooth objects/scenery, IDs, rivals, contact and snapshot ordering" if failures==0 else "ARCADE VISUAL FAIL: %d" % failures)
	get_tree().quit(0 if failures==0 else 1)
