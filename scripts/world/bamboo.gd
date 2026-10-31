extends Node2D
const GROUND := preload("res://assets/cenario/bosque/chao_bosque.png")
const DOJO := preload("res://assets/cenario/bosque/dojo.png")
const BAMBOO_A := preload("res://assets/cenario/bosque/bambuzal_a.png")
const BAMBOO_B := preload("res://assets/cenario/bosque/bambuzal_b.png")
const FENCE := preload("res://assets/cenario/bosque/cerca_bambu.png")
const LANTERN := preload("res://assets/cenario/bosque/lanterna_de_pedra.png")
const BASIN := preload("res://assets/cenario/bosque/tsukubai.png")
func _ready() -> void:
	_object(DOJO,Rect2(416,210,320,205),385)
	_object(BAMBOO_A,Rect2(35,210,170,325),533)
	_object(BAMBOO_B,Rect2(200,210,120,260),470)
	_object(BAMBOO_A,Rect2(900,210,170,325),533)
	for x in [365,755]:
		_object(LANTERN,Rect2(x,335,45,77),412)
		_object(FENCE,Rect2(x-45,490,110,41),524)
	_object(BASIN,Rect2(800,530,66,55),580)

func _object(texture: Texture2D, rect: Rect2, ground_y: int) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = rect.get_center()
	sprite.scale = rect.size / texture.get_size()
	sprite.z_index = ground_y
	add_child(sprite)

func _draw() -> void:
	draw_texture_rect(GROUND,Rect2(24,204,1104,436),false)
	load("res://scripts/world/ground_arrow.gd").paint(self,Vector2(576,435),PI,0.6)
	_arrow(Vector2(576,608),0)
func _arrow(point: Vector2, angle: float) -> void:
	load("res://scripts/world/ground_arrow.gd").paint(self,point,angle)
