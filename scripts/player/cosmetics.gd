extends RefCounted
const CLOTHING := preload("res://scripts/player/clothing_assets.gd")
const SHOP := preload("res://scripts/core/shop_catalog.gd")
const HAT := preload("res://assets/cenario/comercial/produtos_exemplo/cartola.png")
const BOW := preload("res://assets/cenario/comercial/produtos_exemplo/laco_rosa.png")
static func paint(canvas: CanvasItem, outfit: String, direction: String, origin:=Vector2.ZERO, size:=1.0, clock:=0.0, moving:=false, sitting:=false) -> void:
	var product: Dictionary=SHOP.item(outfit)
	if product.has("garment"):
		var face: String={"front":"S","back":"N","left":"E","right":"E","front_left":"SE","front_right":"SE","back_left":"NE","back_right":"NE"}.get(direction,"S")
		var kind: String=product.garment
		var action: String=("sit_" if sitting else ("walk_" if moving else "idle_"))+face
		if sitting and face not in ["S","N","E"]: action="sit_N" if direction.begins_with("back") else "sit_S"
		var flip: bool=direction in ["left","front_left","back_left"]
		canvas.draw_set_transform(origin,0,Vector2(-0.7 if flip else 0.7,0.7)*size)
		for layer in (["cor","detalhe"] if kind in ["terno","chapeu"] else ["cor"]):
			var frames: SpriteFrames=CLOTHING.layer(kind+"_"+layer)
			if not frames: continue
			if not frames.has_animation(action): action="idle_"+face
			var frame: Texture2D=frames.get_frame_texture(action,int(clock*(8.0 if moving else 2.0))%frames.get_frame_count(action))
			canvas.draw_texture_rect(frame,Rect2(-48,-96,96,96),false,Color(product.color) if layer=="cor" else Color.WHITE)
		canvas.draw_set_transform(Vector2.ZERO)
		return
	if outfit=="none": return
	canvas.draw_set_transform(origin,0,Vector2.ONE*size)
	var left: bool=direction in ["left","front_left","back_left"]
	var side: float=-5 if left else (5 if direction in ["right","front_right","back_right"] else 0)
	if outfit=="cartola":
		canvas.draw_texture_rect(HAT,Rect2(side-16,-88,32,32),false)
	elif outfit=="laco_rosa":
		canvas.draw_texture_rect(BOW,Rect2(-24 if left else 4,-70,22,22),false)
	elif outfit in ["scarf_red","scarf_blue"]:
		var color:=Color("cb4e42") if outfit=="scarf_red" else Color("428fce")
		var style:=StyleBoxFlat.new()
		style.bg_color=color
		style.set_corner_radius_all(3)
		canvas.draw_style_box(style,Rect2(-12,-43,24,7))
		canvas.draw_colored_polygon(PackedVector2Array([Vector2(7,-39),Vector2(15,-37),Vector2(11,-22),Vector2(5,-25)]),color)
	canvas.draw_set_transform(Vector2.ZERO)
