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
	{"id":"laco_rosa", "name":"Laço rosa", "shop":"cosmetics", "price":80, "art":"laco_rosa", "desc":"Um detalhe alegre para combinar com você."}
]

static func item(id: String) -> Dictionary:
	for product in ITEMS:
		if product.id==id: return product
	return {}
