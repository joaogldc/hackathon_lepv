extends Control
signal finished(result: Dictionary)
var inside := true
var overlay: Control
var fighters: Array[AnimatedSprite2D] = []
var timer_label: Label
var remaining := 0.0
const COLORS := [Color("6b9e80"), Color("648ab1"), Color("ad795c")]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in range(2):
		var bear := AnimatedSprite2D.new()
		var frames := SpriteFrames.new()
		frames.add_animation("idle")
		frames.set_animation_speed("idle", 2)
		for index in range(1,3):
			frames.add_frame("idle", load("res://assets/sprites/urso/frames/E_idle_%d.png" % index))
		bear.sprite_frames = frames
		bear.play("idle")
		bear.flip_h = side == 1
		bear.position = Vector2(240 if side == 0 else 912, 345)
		bear.scale = Vector2(0.78,0.78)
		add_child(bear)
		fighters.append(bear)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	Duel.changed.connect(_refresh)
	_refresh()

func _style(color: Color, border := Color("d9c18a")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 12
	style.content_margin_right = 12
	return style

func _label(text: String, rect: Rect2, font_size := 22, color := Color("fff2d9")) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(label)
	return label

func _button(text: String, rect: Rect2, action: Callable, enabled := true) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.disabled = not enabled
	button.add_theme_font_size_override("font_size",19)
	button.add_theme_stylebox_override("normal",_style(Color("294b46")))
	button.add_theme_stylebox_override("hover",_style(Color("42665a"),Color("fff1b1")))
	button.pressed.connect(action)
	overlay.add_child(button)
	return button

func _refresh() -> void:
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	timer_label = null
	var v: Dictionary = Duel.view
	var phase: String = v.get("phase","idle")
	var mine := 0
	if v.has("ids"):
		mine = v.ids.find(multiplayer.get_unique_id())
	_label("DOJO DO BAMBU",Rect2(360,20,432,45),30)
	_button("Sair do dojo",Rect2(970,24,160,40),_return)
	_label("M: mapa da ilha",Rect2(20,24,180,40),17)
	for side in range(2):
		var name_text := "Você" if side == 0 else "Aguardando rival"
		var energy := 5
		if v.has("names"):
			name_text = v.names[side] + (" • você" if side == mine else "")
			energy = v.energy[side]
		var x := 70 if side == 0 else 752
		_label(name_text,Rect2(x,86,330,38),23)
		var bar := ProgressBar.new()
		bar.position = Vector2(x+25,130)
		bar.size = Vector2(280,22)
		bar.max_value = 5
		bar.value = energy
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background",_style(Color("302d28")))
		bar.add_theme_stylebox_override("fill",_style(Color("83b887"),Color("83b887")))
		overlay.add_child(bar)
		_label("%d / 5 energia" % energy,Rect2(x,156,330,28),17)
		fighters[side].modulate = Color.WHITE if v.has("ids") or side == 0 else Color(1,1,1,0.25)
		_label("DEFESA" if v.has("attacker") and side != v.attacker else "ATAQUE",Rect2(x,450,330,30),18,Color("ead39a"))
	if phase in ["idle","waiting"]:
		_label("Duelo de multiplicação" if phase == "idle" else "Procurando adversário…",Rect2(382,202,388,64),26)
		_label("Escolha uma carta para atacar.\nResponda para defender.\nAcerto bloqueia; erro tira 1 energia.",Rect2(390,274,372,102),19)
		_button("Procurar adversário" if phase == "idle" else "Cancelar busca",Rect2(401,396,350,52),func(): Duel.act("join" if phase == "idle" else "leave"))
		_fan([2,2,1],false)
	else:
		remaining = v.seconds
		_label("Turno %d / 10" % v.turn,Rect2(430,90,292,30),19)
		timer_label = _label("",Rect2(430,121,292,30),18)
		if phase == "choose":
			_label("Escolha uma carta\npara atacar" if mine == v.attacker else "O rival está escolhendo\numa carta…",Rect2(390,240,372,100),27)
			_label("Todas as cartas causam 1 de dano.",Rect2(385,360,382,40),17)
		elif phase == "answer":
			_label("Defenda seu urso!" if mine != v.attacker else "O rival está defendendo…",Rect2(385,195,382,50),22)
			_label(v.question,Rect2(390,250,372,70),40)
			for index in range(v.options.size()):
				_button(str(v.options[index]),Rect2(422+(index%2)*163,340+(index/2)*55,145,46),func(): Duel.act("answer",index),mine != v.attacker)
		elif phase == "resolve":
			_label(v.feedback,Rect2(385,235,382,170),24)
		elif phase == "finished":
			_label(v.feedback,Rect2(385,205,382,95),28)
			_label("Defesas certas: %d de %d" % [v.correct[mine],v.attempts[mine]],Rect2(385,300,382,50),20)
			_button("Jogar novamente",Rect2(426,380,300,50),func(): Duel.act("join"))
		_fan(v.cards[mine],phase == "choose" and mine == v.attacker)
	_label("SEU BARALHO  •  2 fáceis · 2 médias · 1 difícil por partida",Rect2(260,689,632,28),16,Color("e0d2b9"))
	queue_redraw()

func _fan(counts: Array, playable: bool) -> void:
	var levels: Array[int] = []
	for level in range(3):
		for index in range(counts[level]):
			levels.append(level)
	if levels.is_empty():
		_label("Baralho esgotado",Rect2(390,555,372,80),24)
		return
	for index in range(levels.size()):
		var level: int = levels[index]
		var offset := float(index) - float(levels.size()-1)/2.0
		var base := Vector2(576+offset*102-75,475+absf(offset)*8)
		var card := _button("×\n\n%s\n\nATÉ %d\n1 DANO" % [["FÁCIL","MÉDIA","DIFÍCIL"][level],[5,9,12][level]],Rect2(base,Vector2(150,170)),func(): Duel.act("card",level),playable)
		card.name = "Card%d" % index
		card.pivot_offset = Vector2(75,170)
		card.rotation = deg_to_rad(offset*9)
		card.add_theme_font_size_override("font_size",18)
		card.add_theme_stylebox_override("normal",_style(COLORS[level]))
		card.add_theme_stylebox_override("disabled",_style(COLORS[level].darkened(0.35),Color("968465")))
		card.add_theme_color_override("font_disabled_color",Color("d1c6af"))
		card.add_theme_stylebox_override("hover",_style(COLORS[level].lightened(0.2),Color("fff4be")))
		card.mouse_entered.connect(func():
			if not card.disabled:
				card.z_index = 20
				card.position = base + Vector2(0,-22))
		card.mouse_exited.connect(func():
			card.z_index = 0
			card.position = base)

func _draw() -> void:
	draw_rect(Rect2(0,0,1152,720),Color("322b29"))
	draw_rect(Rect2(20,65,1112,145),Color("654c3e"))
	for x in range(30,1152,86):
		draw_rect(Rect2(x,65,7,145),Color("3d302b"))
	draw_rect(Rect2(0,200,1152,520),Color("a77e55"))
	for y in range(220,720,40):
		draw_line(Vector2(0,y),Vector2(1152,y),Color("8d6949"),2)
	draw_colored_polygon(PackedVector2Array([Vector2(125,244),Vector2(1027,244),Vector2(1090,484),Vector2(62,484)]),Color("c7bd8b"))
	draw_polyline(PackedVector2Array([Vector2(125,244),Vector2(1027,244),Vector2(1090,484),Vector2(62,484),Vector2(125,244)]),Color("63765e"),7,true)
	draw_line(Vector2(576,245),Vector2(576,484),Color("a5a077"),3)
	draw_circle(Vector2(576,363),65,Color("b3ac7c"))
	draw_rect(Rect2(0,510,1152,210),Color(0.09,0.13,0.12,0.87))

func _process(delta: float) -> void:
	remaining = maxf(0,remaining-delta)
	if is_instance_valid(timer_label):
		timer_label.text = "Tempo: %ds" % ceili(remaining) if remaining > 0 else ""

func _return() -> void:
	Duel.act("leave")
	finished.emit({"game":"math","completed":false})

func _exit_dojo() -> void:
	_return()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_return()
