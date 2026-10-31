extends Node
## Rewards, quests, daily rollover and pet/outfit ownership are server-owned.
signal changed
const CATALOG := preload("res://scripts/world/world_catalog.gd")
const SHOP := preload("res://scripts/core/shop_catalog.gd")
const PET_ACCESSORIES := preload("res://scripts/player/pet_accessories.gd")
const WIN_COINS := 25
## Só para testes: ao rodar pelo editor, o saldo de cada perfil sobe até este
## valor ao entrar na sala. Jogos exportados não recebem nada. Use 0 para desligar.
const MOEDAS_TESTE := 1000
const STORY := [
	["Conheça o Bosque da Sabedoria","visit_math",1,30,"math"],
	["Entre no dojo","visit_dojo",1,30,"math"],
	["Defenda três ataques corretamente","math_correct",3,40,"math"],
	["Vença um duelo de cartas","duel_win",1,60,"math"],
	["Descubra o Porto Glacial","visit_language",1,30,"language"],
	["Investigue o mamute congelado","discover_mammoth",1,40,"language"],
	["Investigue o lago com fóssil","discover_fossil",1,40,"language"],
	["Conclua a leitura no navio","reading_complete",1,60,"language"],
	["Visite o Observatório","visit_science",1,30,"science"],
	["Responda uma pergunta de ciências","science_correct",1,40,"science"],
	["Acerte três perguntas de ciências","science_correct",3,40,"science"],
	["Conclua o desafio do Observatório","science_complete",1,60,"science"]
]
const DAILY := [["Explore três regiões","regions",3,20],["Acerte cinco perguntas","answers",5,30],["Conclua um duelo","duels",1,30]]
var profiles: Dictionary={}
var player_keys: Dictionary={}
var view: Dictionary={}
var timer:=0.0
var identity:=""
var storage_path:="user://progress_v1.json"

func _ready() -> void:
	var identity_file:=ConfigFile.new()
	identity_file.load("user://identity.cfg")
	identity=str(identity_file.get_value("profile","token",""))
	if identity.length()!=64:
		identity=Crypto.new().generate_random_bytes(32).hex_encode()
		identity_file.set_value("profile","token",identity)
		identity_file.save("user://identity.cfg")
	if FileAccess.file_exists(storage_path):
		var loaded=JSON.parse_string(FileAccess.get_file_as_string(storage_path))
		if loaded is Dictionary: profiles=loaded
		elif FileAccess.file_exists(storage_path+".backup"):
			var backup=JSON.parse_string(FileAccess.get_file_as_string(storage_path+".backup"))
			if backup is Dictionary: profiles=backup
	Network.roster_changed.connect(_sync_local)

func _sync_local() -> void:
	var next: Dictionary=Network.players.get(multiplayer.get_unique_id(),{}).get("progress",{})
	if view!=next:
		view=next.duplicate(true)
		changed.emit()

func day_number() -> int:
	# Every player follows the host's UTC day, independent of client clocks.
	return int(Time.get_unix_time_from_system()/86400.0)

func fresh() -> Dictionary:
	return {"stats":{},"story":0,"xp":0,"coins":0,"owned":["fish"],"badges":[],"daily_day":-1,"daily":{},"daily_regions":[],"daily_awarded":[],"last_daily":-999,"streak":0,"best_streak":0,"pet":"fish","pet_acc":"none","outfit":"none","wins":0,"losses":0,"draws":0}

func attach(id: int, token: String) -> void:
	if token.length()!=64 or not token.is_valid_hex_number(false): token=Crypto.new().generate_random_bytes(32).hex_encode()
	var key: String=(token+Network.players[id].nickname).sha256_text()
	if player_keys.values().has(key): key=(key+str(id)).sha256_text()
	player_keys[id]=key
	if not profiles.has(key): profiles[key]=fresh()
	var p: Dictionary=profiles[key]
	for field in fresh():
		if not p.has(field): p[field]=fresh()[field]
	for equipped_item in [p.pet,p.pet_acc,p.outfit]:
		if not SHOP.item(equipped_item).is_empty() and not p.owned.has(equipped_item): p.owned.append(equipped_item)
	if MOEDAS_TESTE>0 and OS.has_feature("editor") and int(p.coins)<MOEDAS_TESTE: p.coins=MOEDAS_TESTE
	_roll_day(p,day_number())
	Network.players[id].pet=p.pet
	Network.players[id].pet_acc=p.pet_acc
	Network.players[id].outfit=p.outfit
	record(id,"visit_lobby")

func _roll_day(p: Dictionary, day: int) -> void:
	if int(p.daily_day)==day: return
	p.daily_day=day
	p.daily={}
	p.daily_regions=[]
	p.daily_awarded=[]
	if day-int(p.last_daily)>1: p.streak=0

func record(id: int, event: String, amount:=1) -> void:
	if not multiplayer.is_server() or not player_keys.has(id): return
	var p: Dictionary=profiles[player_keys[id]]
	var day:=day_number()
	_roll_day(p,day)
	p.stats[event]=int(p.stats.get(event,0))+amount
	if event.begins_with("visit_") and event.trim_prefix("visit_") in ["lobby","math","commerce","language","science"]:
		if not p.daily_regions.has(event): p.daily_regions.append(event)
		p.daily.regions=p.daily_regions.size()
	if event in ["math_correct","reading_correct","science_correct"]: p.daily.answers=int(p.daily.get("answers",0))+amount
	if event=="duel_complete": p.daily.duels=int(p.daily.get("duels",0))+amount
	while int(p.story)<STORY.size():
		var quest: Array=STORY[int(p.story)]
		if int(p.stats.get(quest[1],0))<int(quest[2]): break
		p.xp+=quest[3]
		p.story+=1
	for index in range(DAILY.size()):
		if int(p.daily.get(DAILY[index][1],0))>=int(DAILY[index][2]) and not p.daily_awarded.has(index):
			p.daily_awarded.append(index)
			p.xp+=DAILY[index][3]
	if p.daily_awarded.size()==DAILY.size() and int(p.last_daily)!=day:
		p.streak=int(p.streak)+1 if int(p.last_daily)==day-1 else 1
		p.best_streak=maxi(int(p.best_streak),int(p.streak))
		p.last_daily=day
		p.xp+=50
	_publish(id)
	_save()

func duel_result(id: int, result: String, completed: bool) -> int:
	if not player_keys.has(id): return 0
	var p: Dictionary=profiles[player_keys[id]]
	var coins:=WIN_COINS if result=="win" else 0
	p.coins=int(p.get("coins",0))+coins
	if result=="win" and not p.badges.has("first_daily_win"): p.badges.append("first_daily_win")
	p[{"win":"wins","loss":"losses","draw":"draws"}[result]]+=1
	# Abandonment gives a match result but never farms quest XP.
	if completed:
		record(id,"duel_complete")
		if result=="win": record(id,"duel_win")
	else:
		_publish(id)
		_save()
	return coins

func equip(id: int, kind: String, value: String) -> void:
	if not player_keys.has(id) or not Network.players.has(id): return
	var p: Dictionary=profiles[player_keys[id]]
	var in_pet_shop: bool=Network.players[id].zone=="loja_pets" and CATALOG.near_merchant(Network.players[id].position)
	var product: Dictionary=SHOP.item(value)
	if kind=="pet" and in_pet_shop and product.get("shop","")=="pet" and not SHOP.is_accessory(product) and p.owned.has(value):
		p.pet=value
		Network.players[id].pet=value
	elif kind=="pet_acc" and in_pet_shop and (value=="none" or (SHOP.is_accessory(product) and p.owned.has(value) and PET_ACCESSORIES.supports(p.pet,product.accessory))):
		p.pet_acc=value
		Network.players[id].pet_acc=value
	elif kind=="outfit" and (value in ["none","scarf_red","scarf_blue"] or (SHOP.item(value).get("shop","")=="cosmetics" and p.owned.has(value))) and (Network.players[id].zone=="provador" or (Network.players[id].zone=="loja_cosmeticos" and CATALOG.near_merchant(Network.players[id].position))):
		p.outfit=value
		Network.players[id].outfit=value
	else: return
	_publish(id)
	_save()

func buy(id: int, value: String) -> void:
	if not multiplayer.is_server() or not player_keys.has(id) or not Network.players.has(id): return
	var product: Dictionary=SHOP.item(value)
	if product.is_empty(): return
	var player: Dictionary=Network.players[id]
	var action: String=Minigames.shop_action(player.zone,player.position)
	if action!=product.shop: return
	var p: Dictionary=profiles[player_keys[id]]
	if p.owned.has(value) or int(p.coins)<int(product.price): return
	if SHOP.is_accessory(product) and not PET_ACCESSORIES.supports(p.pet,product.accessory): return
	p.coins-=int(product.price)
	p.owned.append(value)
	if SHOP.is_accessory(product):
		p.pet_acc=value
		player.pet_acc=value
	elif product.shop=="pet":
		p.pet=value
		player.pet=value
	else:
		p.outfit=value
		player.outfit=value
	_publish(id)
	_save()

func _publish(id: int) -> void:
	if not Network.players.has(id) or not player_keys.has(id): return
	var p: Dictionary=profiles[player_keys[id]]
	Network.players[id].progress={"story":p.story,"xp":p.xp,"coins":p.coins,"level":1+int(p.xp)/100,"stats":p.stats.duplicate(),"daily":p.daily.duplicate(),"daily_awarded":p.daily_awarded.duplicate(),"daily_day":p.daily_day,"streak":p.streak,"best_streak":p.best_streak,"wins":p.wins,"losses":p.losses,"draws":p.draws,"pet":p.pet,"pet_acc":p.pet_acc,"outfit":p.outfit,"owned":p.owned.duplicate(),"badges":p.badges.duplicate()}
	Network.roster_changed.emit()

func _save() -> void:
	var file:=FileAccess.open(storage_path+".tmp",FileAccess.WRITE)
	if not file:
		push_error("Não foi possível salvar o progresso: "+error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(profiles))
	file.flush()
	file.close()
	var target:=ProjectSettings.globalize_path(storage_path)
	if FileAccess.file_exists(storage_path):
		DirAccess.copy_absolute(target,target+".backup")
	var error:=DirAccess.rename_absolute(target+".tmp",target)
	if error!=OK: push_error("Não foi possível concluir o salvamento: "+error_string(error))

func _process(delta: float) -> void:
	if not Network.active or not multiplayer.is_server(): return
	timer+=delta
	if timer<10: return
	timer=0
	for id in player_keys.keys():
		if not Network.players.has(id):
			player_keys.erase(id)
			continue
		var p: Dictionary=profiles[player_keys[id]]
		if int(p.daily_day)!=day_number():
			_roll_day(p,day_number())
			_publish(id)
			_save()
