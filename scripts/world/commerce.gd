extends Node2D
const ART := preload("res://scenes/world/commerce_art.tscn")

func _ready() -> void:
	# The imported scene is visual only; players and travel remain server-owned.
	add_child(ART.instantiate())

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var exit_point: Vector2 = Minigames.EXIT.position
	draw_set_transform(exit_point)
	draw_colored_polygon(PackedVector2Array([Vector2(-9,-22), Vector2(9,-22), Vector2(9,0), Vector2(23,0), Vector2(0,25), Vector2(-23,0), Vector2(-9,0)]), Minigames.EXIT.color)
	draw_set_transform(Vector2.ZERO)
	draw_string(font, exit_point + Vector2(-65, 55), "Voltar ao lobby", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("293b32"))
