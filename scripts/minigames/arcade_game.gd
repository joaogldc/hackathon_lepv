extends Control
signal finished(result: Dictionary)
@export_enum("race", "rocket") var kind := "race"
const DECK = preload("res://scripts/education/question_deck.gd")
const ART = preload("res://scripts/minigames/arcade_art.gd")
var art = ART.new()
var grade := 1
var background: Texture2D
var space: Texture2D
var state: Dictionary = {}
var clock := 0.0
var input_clock := 0.0
var panel_key := ""
var overlay: PanelContainer
var content: VBoxContainer
var hud: Label
var timer: Label
var honey_bar: ProgressBar
var fuel_icon: TextureRect
var years: OptionButton
var closing := false
var controls_active := true
var last_intent := Vector2.ZERO
var snapshot_age := 0.0
var render_position := Vector2.ZERO
var render_distance := 0.0
var render_objects: Dictionary = {}
var rival_positions: Array[Vector2] = []
var presentation_run := -1
var controls_tip: Label

func _ready() -> void:
	grade = DECK.saved_grade()
	background = load("res://assets/cenario/minigames/corrida_glacial/rio_glacial_fundo_v1.png" if kind == "race" else "res://assets/cenario/minigames/foguete_madeira/subida_atmosfera_fundo_v1.png")
	if kind == "rocket": space = load("res://assets/cenario/minigames/foguete_madeira/espaco_orbital_fundo_v1.png")
	clip_contents = true
	get_viewport().size_changed.connect(_resize)
	_resize()
	_build_ui()
	Arcade.changed.connect(_refresh)
	state = {}
	_intro()
	queue_redraw()

func _resize() -> void:
	if not is_inside_tree(): return
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(1152, 720)
	# Habitat screens already scale their entire design canvas to the viewport.
	if get_parent() is Control and get_parent().size.is_equal_approx(size):
		scale = Vector2.ONE
		position = Vector2.ZERO
		return
	var view_size := get_viewport_rect().size
	var ratio := minf(view_size.x / 1152.0, view_size.y / 720.0)
	scale = Vector2.ONE * ratio
	position = (view_size - size * ratio) / 2

func _build_ui() -> void:
	var skin := Theme.new()
	skin.default_font_size = 20
	skin.set_color("font_color", "Label", Color("513d2b"))
	var font: Font = load("res://assets/fonts/Baloo2-ExtraBold.ttf")
	skin.default_font = font
	for type in ["Button", "OptionButton"]:
		for status in ["normal", "hover", "pressed", "focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = Color("258bab") if status == "normal" else Color("196b89")
			style.border_color = Color("745332")
			style.set_border_width_all(2)
			style.set_corner_radius_all(12)
			style.set_content_margin_all(10)
			skin.set_stylebox(status, type, style)
		skin.set_color("font_color", type, Color.WHITE)
	theme = skin
	var bar := PanelContainer.new()
	bar.position = Vector2(16, 12)
	bar.size = Vector2(1120, 82)
	bar.add_theme_stylebox_override("panel", _paper())
	add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	bar.add_child(row)
	hud = Label.new()
	hud.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_theme_font_size_override("font_size", 21)
	row.add_child(hud)
	if kind == "rocket":
		fuel_icon = TextureRect.new()
		fuel_icon.texture = art.fuel(100)
		fuel_icon.custom_minimum_size = Vector2(48,48)
		fuel_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fuel_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(fuel_icon)
		honey_bar = ProgressBar.new()
		honey_bar.custom_minimum_size = Vector2(175, 24)
		honey_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		honey_bar.value = 100
		var track := StyleBoxFlat.new()
		track.bg_color = Color("e0d2b2")
		track.set_corner_radius_all(8)
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("eab23d")
		fill.set_corner_radius_all(8)
		honey_bar.add_theme_stylebox_override("background",track)
		honey_bar.add_theme_stylebox_override("fill",fill)
		honey_bar.add_theme_color_override("font_color",Color("513d2b"))
		row.add_child(honey_bar)
	var leave := Button.new()
	leave.text = "Voltar [Esc]"
	leave.pressed.connect(_leave)
	row.add_child(leave)
	var tip := Label.new()
	controls_tip = tip
	tip.text = _control_caption()
	tip.position = Vector2(24, 678)
	tip.size = Vector2(1104, 30)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_color_override("font_color", Color.WHITE)
	tip.add_theme_color_override("font_outline_color", Color("17283b"))
	tip.add_theme_constant_override("outline_size", 6)
	add_child(tip)
	overlay = PanelContainer.new()
	overlay.position = Vector2(188, 117)
	overlay.size = Vector2(776, 540)
	overlay.add_theme_stylebox_override("panel", _paper())
	add_child(overlay)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	overlay.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	scroll.add_child(content)

func _paper() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("fff5dc")
	style.border_color = Color("745332")
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.set_content_margin_all(18)
	return style

func _clear() -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	timer = null

func _text(caption: String, font_size := 22) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(label)
	return label

func _button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size.y = 48
	var label := Label.new()
	label.text = caption
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 12
	label.offset_right = -12
	button.add_child(label)
	if caption.length() > 65: button.custom_minimum_size.y = 84
	button.pressed.connect(callback)
	content.add_child(button)
	return button

func _intro() -> void:
	_clear()
	render_position = Vector2(265,410) if kind == "race" else Vector2(576,535)
	render_distance = 0.0
	render_objects.clear()
	rival_positions.clear()
	presentation_run = -1
	overlay.show()
	hud.text = "Corrida Glacial • Língua Portuguesa" if kind == "race" else "Foguete de Madeira • Ciências"
	_text("Corrida Glacial" if kind == "race" else "Da floresta ao espaço", 32)
	_text("Escolha o ano escolar. As perguntas, a velocidade e o tempo de resposta são ajustados ao ano escolhido.", 20)
	years = OptionButton.new()
	for year in range(1, 10): years.add_item("%dº ano" % year)
	years.select(grade - 1)
	years.item_selected.connect(func(index: int): grade = index + 1; DECK.save_grade(grade))
	content.add_child(years)
	_text("Use WASD ou as setas para remar em todas as direções. Desvie dos obstáculos e recolha moedas. Ao encostar num obstáculo, responda para ganhar impulso; errar tira uma posição. As outras três canoas são controladas pelo jogo." if kind == "race" else "O foguete consome mel. Pegue potes para conversar com a Abelha Sábia: acertar enche o tanque e dá turbo; errar perde mel. Na metade da subida, você entra no espaço.", 21)
	_text("Você pode ler uma dica e revisar os erros no final. Nas perguntas, o ritmo diminui e o cronômetro continua. Depois de responder, leia a explicação sem pressa e escolha quando continuar.", 17)
	_button("Começar aventura", _start)
	_text("Demo: recortes de prática do 1º ao 9º ano; não cobre todo o currículo.", 15)

func _start() -> void:
	DECK.save_grade(grade)
	panel_key = ""
	Arcade.command(kind, grade)

func _refresh() -> void:
	if closing or Arcade.view.get("kind", "") != kind: return
	state = Arcade.view
	snapshot_age = 0.0
	var run: int = state.get("run_id",0)
	if run != presentation_run:
		presentation_run = run
		render_position = state.position
		render_distance = float(state.distance)
		render_objects.clear()
		rival_positions.clear()
	var phase: String = state.phase
	var prefix := "Corrida Glacial • %dº ano • %dº / 4" % [state.grade, state.rank] if kind == "race" else ("Espaço" if state.distance > Arcade.FINISH * 0.5 else "Atmosfera") + " • %dº ano • Mel: %d%%" % [state.grade, roundi(state.fuel)]
	hud.text = prefix + "\n%d%% • %d acertos / %d respostas%s" % [mini(100, int(float(state.distance) / Arcade.FINISH * 100)), state.score, state.answers, " • %d moedas" % int(state.coins) if kind == "race" else ""]
	if is_instance_valid(honey_bar):
		honey_bar.value = state.fuel
		fuel_icon.texture = art.fuel(float(state.fuel))
	var next_key := phase + str(state.revision)
	if next_key != panel_key:
		panel_key = next_key
		_clear()
		overlay.visible = phase != "run"
		if phase == "question": _question()
		elif phase == "feedback": _feedback()
		elif phase == "result": _result()
		elif phase == "run": get_viewport().gui_release_focus()
	controls_tip.text = _control_caption() if phase == "run" else ("Responda à pergunta para retomar a aventura" if phase == "question" else "Leia a explicação e escolha Continuar" if phase == "feedback" else "Fim da aventura • jogue novamente ou volte")
	if is_instance_valid(timer): timer.text = "Tempo para responder: %ds" % ceili(float(state.get("remaining", 0)))
	queue_redraw()

func _question() -> void:
	var q: Dictionary = state.question
	if kind == "rocket":
		var heading := HBoxContainer.new()
		content.add_child(heading)
		var teacher := TextureRect.new()
		teacher.texture = art.teacher()
		teacher.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		teacher.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		teacher.custom_minimum_size = Vector2(64, 56)
		heading.add_child(teacher)
		var title := Label.new()
		title.text = "Abelha Sábia • Vamos pensar!"
		title.add_theme_font_size_override("font_size",24)
		heading.add_child(title)
	else: _text("Obstáculo à frente!",27)
	_text("%s • %s" % [q.title, q.skill], 14)
	timer = _text("", 16)
	if not str(q.reading).is_empty(): _text(q.reading, 23 if grade <= 3 else 21)
	_text(q.prompt, 22)
	var revision: int = state.revision
	for index in range(q.options.size()):
		_button(str(q.options[index]), _answer.bind(index, revision))
	var hint := _text("Dica: " + q.hint, 18)
	hint.hide()
	_button("Ver dica", func(): hint.show())

func _answer(index: int, revision: int) -> void:
	for child in content.get_children():
		if child is Button: child.disabled = true
	Arcade.command("answer", index, revision)

func _feedback() -> void:
	_text(state.feedback, 27)
	_text("Resposta de referência: " + state.reference, 23)
	_text(state.explanation, 23)
	_text("Que pista ajudou você a pensar nessa resposta?", 18)
	_button("Continuar aventura", func(): Arcade.command("continue", 0, int(state.revision)))

func _result() -> void:
	_text(("Chegada! • %dº lugar" % int(state.rank) if kind == "race" else "Você chegou à órbita!") if state.completed else "O mel acabou • vamos tentar de novo?", 30)
	_text("%d acertos em %d respostas." % [state.score, state.answers], 24)
	if Network.active: _text("%d moedas recebidas. Acertos contam para as missões; concluir com dois acertos conta como desafio concluído." % int(state.reward), 18)
	else: _text("Prática avulsa: sem moedas ou missões da sala multiplayer.", 18)
	if not state.review.is_empty():
		_button("Revisar respostas com explicação", _review)
	_button("Escolher ano / jogar novamente", func(): state = {}; panel_key = ""; _intro())
	_button("Voltar", _leave)

func _review() -> void:
	_clear()
	_text("Caderno de revisão", 30)
	for q in state.review:
		_text(q.skill + " • " + q.prompt, 22)
		if not str(q.reading).is_empty(): _text(q.reading, 20)
		_text("Resposta: " + q.answer + "\n" + q.why, 21)
	_button("Voltar ao resultado", func(): _clear(); _result())

func _control_caption() -> String:
	return "WASD / setas: remar em todas as direções • desvie e recolha moedas" if kind == "race" else "WASD / setas: pilotar • recolha mel • desvie das abelhas"

func _sample_intent() -> Vector2:
	if not controls_active or closing or state.get("phase","") != "run" or overlay.visible:
		return Vector2.ZERO
	var right := Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_RIGHT)
	var left := Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_LEFT)
	var down := Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_DOWN)
	var up := Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_UP)
	return Vector2(float(right)-float(left),float(down)-float(up)).limit_length()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		controls_active = false
		last_intent = Vector2.ZERO
		if is_inside_tree(): Arcade.move(Vector2.ZERO)
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		controls_active = true

func _process(delta: float) -> void:
	clock += delta
	input_clock += delta
	snapshot_age += delta
	var intent := _sample_intent()
	# Presses and releases go out immediately; a heartbeat handles lost packets.
	if intent != last_intent or input_clock >= 0.1:
		last_intent = intent
		input_clock = 0.0
		Arcade.move(intent)
	_advance_visuals(delta)
	queue_redraw()

func _advance_visuals(delta: float) -> void:
	if state.is_empty(): return
	var live: Dictionary = Arcade.local_frame(kind)
	var source: Dictionary = state if live.is_empty() else live
	var age := minf(snapshot_age,0.12) if live.is_empty() else 0.0
	var speed: float = source.get("scroll_speed",0.0)
	var motion: Vector2 = source.get("motion",Vector2.ZERO)
	var move_speed: float = source.calibration.move
	var target: Vector2 = Arcade.clamp_position(kind,source.position + motion*move_speed*age)
	var blend := 1.0-exp(-30.0*delta)
	render_position = render_position.lerp(target,blend)
	render_distance = lerpf(render_distance,float(source.distance)+speed*age,blend)
	var visible_keys: Array = []
	var index := 0
	for object in source.objects:
		var key: String = str(object.get("id",str(object.type)+str(index)))
		index += 1
		visible_keys.append(key)
		var velocity := Vector2(-speed*1.7,0) if kind == "race" else Vector2(0,speed*0.8)
		if object.type == "bee":
			velocity.x = sin(float(object.age)*(3.8 if render_distance>Arcade.FINISH*0.5 else 2.2)+int(object.variant))*(100 if render_distance>Arcade.FINISH*0.5 else 45)
		var point: Vector2 = object.p + velocity*age
		if not render_objects.has(key): render_objects[key] = {"p":point,"type":object.type,"variant":object.variant}
		else: render_objects[key].p = Vector2(render_objects[key].p).lerp(point,blend)
	for key in render_objects.keys():
		if not visible_keys.has(key): render_objects.erase(key)
	if kind == "race":
		for rival in range(3):
			var x := clampf(265+(float(source.rank)-rival-1.5)*110,120,940)
			var point := Vector2(x,280+rival*100)
			if rival_positions.size()<=rival: rival_positions.append(point)
			else: rival_positions[rival]=rival_positions[rival].lerp(point,1.0-exp(-4.0*delta))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_leave()

func _leave() -> void:
	if closing: return
	closing = true
	Arcade.move(Vector2.ZERO)
	Arcade.command("leave")
	if finished.get_connections().is_empty(): get_tree().change_scene_to_file("res://scenes/world/lobby.tscn")
	else: finished.emit({"completed": state.get("completed", false), "game": kind})

func _sprite(texture: Texture2D, center: Vector2, extent: Vector2, tint := Color.WHITE, pivot := Vector2(-1,-1)) -> void:
	var original := texture.get_size()
	var fitted := original * minf(extent.x/original.x,extent.y/original.y)
	var anchor := original / 2 if pivot.x < 0 else pivot
	draw_texture_rect(texture, Rect2(center - anchor * (fitted/original), fitted), false, tint)

func _draw() -> void:
	if background == null: return
	draw_rect(Rect2(0, 0, 1152, 720), Color("10213d"))
	var progress := clampf(render_distance / Arcade.FINISH, 0, 1)
	if kind == "race":
		var offset := fmod(render_distance * 0.35, 1152.0)
		draw_texture_rect(background, Rect2(-offset, 95, 1152, 578), false)
		draw_texture_rect(background, Rect2(1152 - offset, 95, 1152, 578), false)
	else:
		var bg_y := lerpf(-1055.0, 95.0, clampf(progress * 2, 0, 1))
		draw_texture_rect(background, Rect2(0, bg_y, 1152, 1728), false)
		var fade := smoothstep(0.42, 0.60, progress)
		if fade > 0: draw_texture_rect(space, Rect2(0, lerpf(-1055.0, 95.0, clampf((progress - 0.5) * 2, 0, 1)), 1152, 1728), false, Color(1, 1, 1, fade))
	var frame := int(clock * 7)
	var p: Vector2 = render_position
	if kind == "race":
		for rival in range(rival_positions.size()):
			_sprite(art.boat(frame + rival),rival_positions[rival]+Vector2(0,sin(clock*1.3+rival)*2),Vector2(145,112),Color(0.8,0.88,1,0.85),ART.BOAT_PIVOT-Vector2(0,55))
	for object in render_objects.values():
		var object_pos: Vector2 = object.p
		match object.type:
			"obstacle": _sprite(art.obstacle(int(object.variant)), object_pos, Vector2(135, 92))
			"coin": _sprite(art.coin(frame), object_pos, Vector2(42, 42))
			"honey": _sprite(art.honey(frame), object_pos, Vector2(70, 64))
			"bee": _sprite(art.bee(frame, progress > 0.5), object_pos, Vector2(98, 86))
	if kind == "race":
		if float(state.get("slow", 0)) > 0: _sprite(art.splash(frame), p + Vector2(5, 24), Vector2(150, 86))
		_sprite(art.boat(frame), p + Vector2(0, sin(clock * 4) * 3), Vector2(178, 140),Color.WHITE,ART.BOAT_PIVOT-Vector2(0,55))
	else:
		if float(state.get("invincible", 0)) > 0: draw_arc(p, 77, 0, TAU, 60, Color(0.4, 0.9, 1, 0.7), 3, true)
		_sprite(art.rocket(frame, float(state.get("boost", 0)) > 0), p, Vector2(105, 151),Color.WHITE,ART.ROCKET_PIVOT+Vector2(0,40))
