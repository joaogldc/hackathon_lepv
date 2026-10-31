extends Node2D
func _draw() -> void:
	draw_rect(Rect2(24,204,1104,436), Color("54794a"))
	draw_rect(Rect2(520,370,112,260), Color("bcaa7e"))
	for x in [100,165,230,300,850,920,990,1055]:
		for y in [300,400,510,605]:
			for offset in [-12,12]:
				draw_line(Vector2(x+offset,y), Vector2(x+offset,y-65), Color("a5c76b"), 8)
				for k in [20,40,60]:
					draw_line(Vector2(x+offset-5,y-k),Vector2(x+offset+5,y-k),Color("496d3e"),2)
	draw_rect(Rect2(440,260,272,110),Color("aa8060"))
	draw_colored_polygon(PackedVector2Array([Vector2(410,270),Vector2(576,215),Vector2(742,270)]),Color("4b3936"))
	draw_rect(Rect2(545,300,62,70),Color("302f2a"))
	draw_string(ThemeDB.fallback_font,Vector2(545,292),"DOJO",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("fff2d9"))
	_arrow(Vector2(576,400),PI,"Entrar no dojo")
	_arrow(Vector2(576,575),0,"Voltar ao lobby")

func _arrow(point: Vector2, angle: float, title: String) -> void:
	draw_set_transform(point,angle)
	draw_colored_polygon(PackedVector2Array([Vector2(-8,-18),Vector2(8,-18),Vector2(8,0),Vector2(20,0),Vector2(0,22),Vector2(-20,0),Vector2(-8,0)]),Color("edd7a0"))
	draw_set_transform(Vector2.ZERO)
	draw_string(ThemeDB.fallback_font,point+Vector2(35,6),title,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fff2d9"))
