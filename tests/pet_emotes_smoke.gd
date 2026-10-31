extends Node
var client := false
var elapsed := 0.0
var reacted := false
var saw_host := false
func _ready() -> void:
	client="--client" in OS.get_cmdline_user_args()
	if client: Network.join_room("EmoteGuest","ws://127.0.0.1:19105")
	else:
		Network.host("EmoteHost",false,19105)
		_run.call_deferred()
func _process(delta: float) -> void:
	elapsed+=delta
	if elapsed>18:
		push_error("PET EMOTES FAIL: timeout")
		get_tree().quit(1)
	if not client: return
	for p in Network.players.values():
		if p.nickname!="EmoteHost": continue
		if p.get("pet_emote","")=="happy":
			saw_host=true
			if not reacted:
				reacted=true
				Network.interact("pet_emote","love")
		if saw_host and p.zone=="provador":
			assert(p.get("pet_emote","")=="","Expired reaction must clear on the client")
			print("PET EMOTES CLIENT PASS: host reaction and expiration replicated")
			Network.leave("")
			get_tree().quit()
func wait_for(predicate: Callable) -> bool:
	var deadline:=Time.get_ticks_msec()+10000
	while not predicate.call():
		if Time.get_ticks_msec()>deadline: return false
		await get_tree().create_timer(0.03).timeout
	return true
func _run() -> void:
	assert(await wait_for(func(): return Network.players.size()==2))
	var guest: int=Network.players.keys().filter(func(id): return id!=1)[0]
	Network.interact("pet_emote","invalid")
	assert(Network.players[1].get("pet_emote","")=="")
	Network.interact("pet_emote","happy")
	Network.interact("pet_emote","angry")
	assert(Network.players[1].pet_emote=="happy","Cooldown must reject immediate replacement")
	assert(await wait_for(func(): return Network.players[guest].get("pet_emote","")=="love"))
	assert(await wait_for(func(): return Network.players[1].pet_emote=="" and Network.players[guest].pet_emote==""))
	Network.players[1].zone="provador"
	Network.players[1].position=Vector2(500,580)
	Network.players[1].entry_until=0
	Network.set_physics_process(false)
	Network.set_movement(Vector2.RIGHT)
	Network._physics_process(0.1)
	assert(is_equal_approx(Network.players[1].position.x,545.6),"Dressing room must use proportional walking speed")
	Network.players[1].zone="loja_pets"
	Network.players[1].position=Vector2(500,580)
	Network._physics_process(0.1)
	assert(is_equal_approx(Network.players[1].position.x,519.0),"Other rooms must keep their original walking speed")
	Network.set_movement(Vector2.ZERO)
	Network.players[1].zone="provador"
	Network.set_physics_process(true)
	assert(await wait_for(func(): return Network.players.size()==1))
	print("PET EMOTES HOST PASS: client reaction, invalid requests, cooldown, expiration and proportional movement")
	get_tree().quit()
