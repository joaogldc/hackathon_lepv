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
	draw_set_transform(Vector2.ZERO)
	var combination: Dictionary=DailyJournal.outfits.duplicate()
	if not item_id.is_empty() and item_id!="none":
		combination[preload("res://scripts/core/shop_catalog.gd").body_slot(item_id)]=item_id
	for slot in ["body","neck","head"]:
		preload("res://scripts/player/cosmetics.gd").paint(self,combination.get(slot,"none"),"front",origin+Vector2(side/2,side),side/(96*0.7))
