extends RefCounted
const HAT := preload("res://assets/cenario/comercial/produtos_exemplo/cartola.png")
const BOW := preload("res://assets/cenario/comercial/produtos_exemplo/laco_rosa.png")
const NAMES := {"none":"Sem acessório","cartola":"Cartola","laco_rosa":"Laço rosa","scarf_red":"Lenço vermelho","scarf_blue":"Lenço azul"}
static func paint(canvas: CanvasItem, outfit: String, direction: String, origin:=Vector2.ZERO, size:=1.0) -> void:
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
