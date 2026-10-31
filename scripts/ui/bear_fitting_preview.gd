extends Control
const CLOTHING := preload("res://scripts/player/clothing_assets.gd")
## Mesmo sprite frontal que scripts/player/bear.gd usa durante o jogo.
var item_id := ""
const BEAR := preload("res://assets/sprites/urso/frames/S_idle_1.png")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var side := minf(size.x, size.y)
	var origin := (size - Vector2.ONE * side) / 2
	draw_set_transform(origin, 0, Vector2.ONE * side / 256.0)
	draw_texture_rect(BEAR, Rect2(0,0,256,256), false)
	var product := DailyJournal.item(item_id)
	if product.has("garment"):
		var kind: String = product.garment
		for layer in (["cor","detalhe"] if kind in ["terno","chapeu"] else ["cor"]):
			var frames: SpriteFrames = CLOTHING.LAYERS[kind+"_"+layer]
			var frame := frames.get_frame_texture("idle_S",0)
			draw_texture_rect(frame,Rect2(0,0,256,256),false,Color(product.color) if layer == "cor" else Color.WHITE)
	elif item_id == "cartola":
		draw_texture_rect(load("res://assets/cenario/comercial/produtos_exemplo/cartola.png"), Rect2(73,-1,110,78), false)
	elif item_id == "laco_rosa":
		draw_texture_rect(load("res://assets/cenario/comercial/produtos_exemplo/laco_rosa.png"), Rect2(157,24,61,49), false)
	elif item_id == "camiseta":
		draw_texture_rect(load("res://assets/ui/lojas/camiseta-vestida.svg"), Rect2(0,0,256,256), false)
	draw_set_transform(Vector2.ZERO)
