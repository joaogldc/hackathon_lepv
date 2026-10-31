extends Node2D
const SHOPS := {"Cosméticos": Vector2(380, 330), "Pets": Vector2(770, 330)}

func _draw() -> void:
	draw_rect(Rect2(24, 204, 1104, 436), Color("6c795a"))
	draw_rect(Rect2(64, 240, 1024, 380), Color("a8ad7e"))
	draw_rect(Rect2(72, 425, 1008, 65), Color("dfc99f"))
	draw_rect(Rect2(540, 350, 72, 270), Color("dfc99f"))
	var font := ThemeDB.fallback_font
	for title in SHOPS:
		var point: Vector2 = SHOPS[title]
		draw_rect(Rect2(point - Vector2(100, 60), Vector2(200, 130)), Color("dfa777"))
		draw_colored_polygon(PackedVector2Array([point + Vector2(-115, -60), point + Vector2(0, -110), point + Vector2(115, -60)]), Color("87554b"))
		draw_rect(Rect2(point + Vector2(-23, 15), Vector2(46, 55)), Color("654c3e"))
		draw_string(font, point + Vector2(-70, -12), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("382d2b"))
		draw_string(font, point + Vector2(-82, 105), "Loja em preparação", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("293b32"))
	var exit_point: Vector2 = Minigames.EXIT.position
	draw_set_transform(exit_point)
	draw_colored_polygon(PackedVector2Array([Vector2(-9,-22), Vector2(9,-22), Vector2(9,0), Vector2(23,0), Vector2(0,25), Vector2(-23,0), Vector2(-9,0)]), Minigames.EXIT.color)
	draw_set_transform(Vector2.ZERO)
	draw_string(font, exit_point + Vector2(-65, 55), "Voltar ao lobby", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("293b32"))
