extends Node
## Presentation adapter: the server owns currency, purchases, quests and badges.
signal changed
signal badge_unlocked
const ITEMS := preload("res://scripts/core/shop_catalog.gd").ITEMS
const QUESTS := [
	{"id":"regions","title":"Explore três regiões","desc":"Passeie por três regiões diferentes.","goal":3,"reward":20},
	{"id":"answers","title":"Acerte cinco perguntas","desc":"Responda nos desafios da ilha.","goal":5,"reward":30},
	{"id":"duels","title":"Conclua um duelo","desc":"Jogue uma partida completa no dojo.","goal":1,"reward":30}
]
var coins := 0
var owned: Array=[]
var equipped := "none"
var outfits: Dictionary = {}
var pet := "fish"
var pet_acc := "none"
var badges: Array=[]
var progress: Dictionary={}
var claimed: Array=[]
var signature := ""
func _ready() -> void:
	Progress.changed.connect(_sync)
	Network.roster_changed.connect(_sync)
	_sync()
func _sync() -> void:
	var p: Dictionary=Network.players.get(multiplayer.get_unique_id(),{}).get("progress",{})
	# roster_changed chega 20 vezes por segundo. Só avisa a interface quando o
	# progresso muda; antes, os botões da loja eram recriados a cada snapshot e
	# perdiam cliques.
	var next_signature:=str(p)
	if next_signature==signature: return
	var first_sync:=signature.is_empty() or signature==str({})
	signature=next_signature
	var old: Array=badges.duplicate()
	coins=int(p.get("coins",0))
	owned=p.get("owned",["fish"])
	equipped=p.get("outfit","none")
	outfits=p.get("outfits",{})
	pet=p.get("pet","fish")
	pet_acc=p.get("pet_acc","none")
	badges=p.get("badges",[])
	progress=p.get("daily",{})
	claimed=[]
	for i in p.get("daily_awarded",[]):
		if i>=0 and i<QUESTS.size(): claimed.append(QUESTS[i].id)
	# Ao entrar na sala, selos antigos não são anunciados como novos.
	if not first_sync and badges.any(func(b): return not old.has(b)): badge_unlocked.emit()
	changed.emit()
func item(id: String) -> Dictionary:
	return preload("res://scripts/core/shop_catalog.gd").item(id)
func buy(id: String) -> String:
	var product:=item(id)
	if product.is_empty(): return "Peça não encontrada."
	if id in owned: return "Este item já está na sua coleção."
	if coins<int(product.price): return "Saldo insuficiente."
	Network.interact("buy",id)
	return ""
func equip(id: String) -> bool:
	if id not in owned and id!="none": return false
	var product:=item(id)
	var shop: String=product.get("shop","")
	Network.interact("pet_acc" if product.get("kind","")=="accessory" else ("pet" if shop=="pet" else "outfit"),id)
	return true
func remaining() -> int:
	return 86400-posmod(int(Time.get_unix_time_from_system()),86400)
