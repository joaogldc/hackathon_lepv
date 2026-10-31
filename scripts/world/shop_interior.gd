extends Node2D
## Reaproveita as artes de interior já presentes no projeto, sem outro jogador local.
var room := ""
func set_room(zone: String) -> void:
	if room == zone: return
	room = zone
	for child in get_children(): remove_child(child); child.queue_free()
	var folder: String = {"pet_shop":"loja_pets","cosmetics_shop":"loja_cosmeticos","fitting_room":"provador"}.get(zone,"loja_pets")
	var background: String = {"pet_shop":"fundo_loja_pets","cosmetics_shop":"fundo_loja_cosmeticos","fitting_room":"fundo_provador"}.get(zone,"")
	_sprite(folder,background,Vector2.ZERO,0,true)
	if zone == "pet_shop":
		_sprite(folder,"balcao_pets",Vector2(640,420),65)
		_sprite(folder,"gondola_bacias",Vector2(340,540),39)
		_sprite(folder,"pilha_racao",Vector2(960,580),84)
		_sprite(folder,"aquario_grande",Vector2(900,440),94)
	elif zone == "cosmetics_shop":
		_sprite(folder,"balcao_cosmeticos",Vector2(640,420),65)
		_sprite(folder,"arara_roupas_1",Vector2(300,520),79)
		_sprite(folder,"arara_roupas_2",Vector2(980,600),79)
		_sprite(folder,"manequim_1",Vector2(230,660),84)
		_sprite(folder,"manequim_2",Vector2(1060,470),84)
		_sprite(folder,"espelho_de_pe",Vector2(470,430),90)
		_sprite(folder,"pufe",Vector2(640,560),19)
	else:
		_sprite(folder,"espelho_vidro",Vector2(430,70),0,true)
		_sprite(folder,"espelho_brilho",Vector2(430,70),0,true)
		_sprite(folder,"pufe_provador",Vector2(1040,640),19)
	if zone != "fitting_room":
		var vendor := Sprite2D.new()
		vendor.texture = load("res://assets/sprites/urso/frames/S_idle_1.png")
		vendor.position = Vector2(576,318)
		vendor.scale = Vector2.ONE * 0.3
		vendor.z_index = 376
		add_child(vendor)
	queue_redraw()

func _sprite(folder: String, file: String, at: Vector2, offset_y: float, top_left := false) -> void:
	var image := Sprite2D.new()
	image.texture = load("res://assets/cenario/%s/%s.png" % [folder,file])
	image.position = at*0.9
	image.scale = Vector2.ONE*0.9
	image.centered = not top_left
	image.offset.y = -offset_y
	image.z_index = -20 if top_left else int(image.position.y)
	add_child(image)

func _draw() -> void:
	if room.is_empty(): return
	var arrow := load("res://scripts/world/ground_arrow.gd")
	arrow.paint(self,Vector2(576,613),0.0)
	if room == "cosmetics_shop":
		draw_string(ThemeDB.fallback_font,Vector2(808,350),"Provador ↑",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("513d2b"))
