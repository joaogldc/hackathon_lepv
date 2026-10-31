extends Node
## Estado de apresentação local. Não representa uma economia validada pelo servidor.
signal changed
signal badge_unlocked
const SAVE := "user://lojas_missoes_v1.json"
const ITEMS := [
	{"id": "camisa_azul", "name": "Camisa azul", "shop": "cosmetics", "price": 80, "art": "camisa_azul", "garment": "camisa", "color": "45b3e6", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "camisa_verde", "name": "Camisa verde", "shop": "cosmetics", "price": 80, "art": "camisa_verde", "garment": "camisa", "color": "7cc34f", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "camisa_vermelha", "name": "Camisa vermelha", "shop": "cosmetics", "price": 80, "art": "camisa_vermelha", "garment": "camisa", "color": "e9453a", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "terno_azul_marinho", "name": "Terno azul marinho", "shop": "cosmetics", "price": 160, "art": "terno_azul_marinho", "garment": "terno", "color": "2c3e6b", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "terno_cinza", "name": "Terno cinza", "shop": "cosmetics", "price": 160, "art": "terno_cinza", "garment": "terno", "color": "7a7a85", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "terno_vinho", "name": "Terno vinho", "shop": "cosmetics", "price": 160, "art": "terno_vinho", "garment": "terno", "color": "8e3a35", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "chapeu_preto", "name": "Chapéu preto", "shop": "cosmetics", "price": 100, "art": "chapeu_preto", "garment": "chapeu", "color": "2b2b2b", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "chapeu_palha", "name": "Chapéu palha", "shop": "cosmetics", "price": 100, "art": "chapeu_palha", "garment": "chapeu", "color": "d9c27a", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "touca_amarela", "name": "Touca amarela", "shop": "cosmetics", "price": 70, "art": "touca_amarela", "garment": "touca", "color": "f6c945", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id": "touca_vermelha", "name": "Touca vermelha", "shop": "cosmetics", "price": 70, "art": "touca_vermelha", "garment": "touca", "color": "e9453a", "desc": "Uma peça da nova coleção de roupas dos ursos."},
	{"id":"bacia", "name":"Bacia de água", "shop":"pet", "price":60, "art":"bacia_de_agua", "desc":"Um cantinho fresquinho para seu companheiro."},
	{"id":"peixe", "name":"Peixe astronauta", "shop":"pet", "price":140, "art":"peixe_capacete", "desc":"Um amigo cheio de personalidade para sua coleção."},
	{"id":"cartola", "name":"Cartola elegante", "shop":"cosmetics", "price":100, "art":"cartola", "desc":"Um toque de elegância para o seu urso."},
	{"id":"laco", "name":"Laço rosa", "shop":"cosmetics", "price":80, "art":"laco_rosa", "desc":"Um detalhe alegre para combinar com você."},
	{"id":"camiseta", "name":"Camiseta da ilha", "shop":"cosmetics", "price":120, "art":"camiseta", "desc":"Conforto para explorar todos os cantinhos da ilha."}
]
const QUESTS := [
	{"id":"win", "title":"Primeira vitória diária", "desc":"Vença um duelo no Dojo do Bambu.", "goal":1, "reward":50},
	{"id":"visit", "title":"Passeio pelas vitrines", "desc":"Visite a loja de pets e a de cosméticos.", "goal":2, "reward":20},
	{"id":"try", "title":"Um novo visual", "desc":"Experimente uma peça no provador.", "goal":1, "reward":15}
]
var coins := 300
var owned: Array = []
var equipped := ""
var badges: Array = []
var day := ""
var progress: Dictionary = {}
var claimed: Array = []
var shops: Array = []
var _timer := 0.0
var persistence := true

func _ready() -> void:
	# Os testes usam um perfil isolado e nunca escrevem no perfil de quem joga.
	persistence = not "--hud-test" in OS.get_cmdline_user_args()
	if persistence and FileAccess.file_exists(SAVE):
		var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
		if data is Dictionary:
			coins = maxi(0, int(data.get("coins", 300)))
			owned = data.get("owned", []) if data.get("owned", []) is Array else []
			equipped = str(data.get("equipped", ""))
			badges = data.get("badges", []) if data.get("badges", []) is Array else []
			day = str(data.get("day", ""))
			progress = data.get("progress", {}) if data.get("progress", {}) is Dictionary else {}
			claimed = data.get("claimed", []) if data.get("claimed", []) is Array else []
			shops = data.get("shops", []) if data.get("shops", []) is Array else []
	roll_day()
	Duel.result_received.connect(_result)

func day_key() -> String:
	return Time.get_date_string_from_unix_time(int(Time.get_unix_time_from_system()) - 10800)

func remaining() -> int:
	return 86400 - posmod(int(Time.get_unix_time_from_system()) - 10800, 86400)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= 1.0:
		_timer = 0.0
		roll_day()

func roll_day() -> void:
	var today := day_key()
	if today == day: return
	day = today
	progress = {"win":0, "visit":0, "try":0}
	claimed = []
	shops = []
	_commit()

func item(id: String) -> Dictionary:
	for product in ITEMS:
		if product.id == id: return product
	return {}

func visit(shop: String) -> void:
	roll_day()
	if shop not in ["pet", "cosmetics"] or shop in shops: return
	shops.append(shop)
	progress.visit = shops.size()
	_commit()

func try_item(id: String) -> void:
	roll_day()
	if item(id).get("shop", "") != "cosmetics": return
	progress["try"] = 1
	_commit()

func buy(id: String) -> String:
	var product := item(id)
	if product.is_empty(): return "Peça não encontrada."
	if id in owned: return "Este item já está na sua coleção."
	if coins < product.price: return "Faltam %d moedas. Complete missões para juntar mais!" % (product.price - coins)
	coins -= product.price
	owned.append(id)
	_commit()
	return ""

func equip(id: String) -> bool:
	if id not in owned or item(id).get("shop", "") != "cosmetics": return false
	equipped = id
	_commit()
	return true

func claim(id: String) -> bool:
	roll_day()
	for quest in QUESTS:
		if quest.id == id and id not in claimed and int(progress.get(id, 0)) >= quest.goal:
			claimed.append(id)
			coins += quest.reward
			_commit()
			return true
	return false

func _result(result: Dictionary) -> void:
	if result.get("spectator", false): return
	var mine: int = result.get("ids", []).find(multiplayer.get_unique_id())
	if mine < 0 or int(result.get("winner", -1)) != mine: return
	roll_day()
	if int(progress.get("win", 0)) > 0: return
	progress.win = 1
	var fresh := "first_daily_win" not in badges
	if fresh: badges.append("first_daily_win")
	_commit()
	if fresh: badge_unlocked.emit()

func _commit() -> void:
	if persistence:
		var file := FileAccess.open(SAVE, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify({"coins":coins, "owned":owned, "equipped":equipped, "badges":badges, "day":day, "progress":progress, "claimed":claimed, "shops":shops}))
	changed.emit()
