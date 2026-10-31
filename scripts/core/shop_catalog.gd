extends RefCounted
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
	{"id":"fish", "name":"Peixe voador", "shop":"pet", "price":0, "art":"fish", "desc":"Seu primeiro companheiro de aventuras."},
	{"id":"parrot", "name":"Papagaio", "shop":"pet", "price":140, "art":"parrot", "desc":"Um amigo alegre para explorar a ilha."},
	{"id":"cartola", "name":"Cartola elegante", "shop":"cosmetics", "price":100, "art":"cartola", "desc":"Um toque de elegância para o seu urso."},
	{"id":"laco_rosa", "name":"Laço rosa", "shop":"cosmetics", "price":80, "art":"laco_rosa", "desc":"Um detalhe alegre para combinar com você."},
	{"id":"pet_bigode", "name":"Bigode distinto", "shop":"pet", "kind":"accessory", "accessory":"bigode", "price":60, "art":"bigode", "desc":"Um bigode charmoso para um pet cheio de classe."},
	{"id":"pet_oculos", "name":"Óculos escuros", "shop":"pet", "kind":"accessory", "accessory":"oculos", "price":80, "art":"oculos", "desc":"Para o pet que acorda pronto para o sol."},
	{"id":"pet_tapa_olho", "name":"Tapa-olho de pirata", "shop":"pet", "kind":"accessory", "accessory":"tapa_olho", "price":80, "art":"tapa_olho", "desc":"Só para a arara: aventura em alto-mar!"},
	{"id":"pet_laco", "name":"Laço de fita", "shop":"pet", "kind":"accessory", "accessory":"laco", "price":70, "art":"laco", "desc":"Um laço alegre para os dias de festa."},
	{"id":"pet_festa", "name":"Chapéu de festa", "shop":"pet", "kind":"accessory", "accessory":"festa", "price":70, "art":"festa", "desc":"Todo dia é dia de comemorar."},
	{"id":"pet_helice", "name":"Boné de hélice", "shop":"pet", "kind":"accessory", "accessory":"helice", "price":90, "art":"helice", "desc":"A hélice gira e o pet fica ainda mais animado."},
	{"id":"pet_quepe", "name":"Quepe de capitão", "shop":"pet", "kind":"accessory", "accessory":"quepe", "price":90, "art":"quepe", "desc":"Quem comanda o navio é o seu pet."},
	{"id":"pet_capacete", "name":"Capacete espacial", "shop":"pet", "kind":"accessory", "accessory":"capacete", "price":120, "art":"capacete", "desc":"Pronto para explorar o Observatório."},
	{"id":"pet_cartola", "name":"Cartola de gala", "shop":"pet", "kind":"accessory", "accessory":"cartola", "price":100, "art":"cartola", "desc":"Elegância para os passeios da ilha."},
	{"id":"pet_terninho", "name":"Terninho de gala", "shop":"pet", "kind":"accessory", "accessory":"terninho", "price":110, "art":"terninho", "desc":"Gravata borboleta e camisa branca."},
	{"id":"pet_coroa", "name":"Coroa real", "shop":"pet", "kind":"accessory", "accessory":"coroa", "price":150, "art":"coroa", "desc":"O pet mais majestoso do reino."}
]

## Acessórios de pet são vendidos na loja de pets, mas não são pets.
static func is_accessory(product: Dictionary) -> bool:
	return product.get("kind","")=="accessory"

static func body_slot(id: String) -> String:
	var product := item(id)
	var garment: String = product.get("garment", "")
	if garment in ["camisa","terno"]: return "body"
	if id in ["scarf_red","scarf_blue"]: return "neck"
	return "head"

static func item(id: String) -> Dictionary:
	for product in ITEMS:
		if product.id==id: return product
	return {}
