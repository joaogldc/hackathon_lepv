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
var years: OptionButton
var closing := false

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
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(1152, 720)
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
		honey_bar = ProgressBar.new()
		honey_bar.custom_minimum_size = Vector2(175, 24)
		honey_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		honey_bar.value = 100
		row.add_child(honey_bar)
	var leave := Button.new()
	leave.text = "Voltar [Esc]"
	leave.pressed.connect(_leave)
	row.add_child(leave)
	var tip := Label.new()
	tip.text = "W / S ou ↑ / ↓: escolher a rota • desvie e recolha moedas" if kind == "race" else "WASD / setas: pilotar • recolha mel • desvie das abelhas"
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
	content.add_theme_constant_override("separation", 10)
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
	button.custom_minimum_size.y = 54
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
	overlay.show()
	hud.text = "Corrida Glacial • Língua Portuguesa" if kind == "race" else "Foguete de Madeira • Ciências"
	_text("Corrida Glacial" if kind == "race" else "Da floresta ao espaço", 32)
	_text("Escolha o ano escolar. O conteúdo é o mesmo das trilhas educacionais; o ano também ajusta velocidade e tempo de resposta.", 20)
	years = OptionButton.new()
	for year in range(1, 10): years.add_item("%dº ano" % year)
	years.select(grade - 1)
	years.item_selected.connect(func(index: int): grade = index + 1; DECK.save_grade(grade))
	content.add_child(years)
	_text("Reme para cima e para baixo. Obstáculos na sua rota abrem uma pergunta: acertar dá impulso; errar faz perder uma posição. As outras três canoas são ursos controlados pelo jogo." if kind == "race" else "O foguete consome mel. Pegue potes para conversar com a Abelha Sábia: acertar enche o tanque e dá turbo; errar perde mel. Na metade da subida, você entra no espaço.", 21)
	_text("Você pode ler uma dica e revisar os erros no final. Nas perguntas, o ritmo diminui e o cronômetro continua. A explicação pode ser lida sem pressa. Para praticar sem tempo, abra Trilhas [F2] no mundo.", 17)
	_button("Começar aventura", _start)
	_text("Demo: recortes de prática do 1º ao 9º ano; não cobre todo o currículo.", 15)

func _start() -> void:
	DECK.save_grade(grade)
	panel_key = ""
	Arcade.command(kind, grade)

func _refresh() -> void:
	if closing or Arcade.view.get("kind", "") != kind: return
	state = Arcade.view
	var phase: String = state.phase
	var prefix := "Corrida Glacial • %dº ano • %dº / 4" % [state.grade, state.rank] if kind == "race" else ("Espaço" if state.distance > Arcade.FINISH * 0.5 else "Atmosfera") + " • %dº ano • Mel: %d%%" % [state.grade, int(state.fuel)]
	hud.text = prefix + "\n%d%% • %d acertos / %d respostas%s" % [mini(100, int(float(state.distance) / Arcade.FINISH * 100)), state.score, state.answers, " • %d moedas" % int(state.coins) if kind == "race" else ""]
	if is_instance_valid(honey_bar): honey_bar.value = state.fuel
	var next_key := phase + str(state.revision)
	if next_key != panel_key:
		panel_key = next_key
		_clear()
		overlay.visible = phase != "run"
		if phase == "question": _question()
		elif phase == "feedback": _feedback()
		elif phase == "result": _result()
	if is_instance_valid(timer): timer.text = "Tempo para responder: %ds" % ceili(float(state.get("remaining", 0)))
	queue_redraw()

func _question() -> void:
	var q: Dictionary = state.question
	if kind == "rocket":
		var teacher := TextureRect.new()
		teacher.texture = art.teacher()
		teacher.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		teacher.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		teacher.custom_minimum_size = Vector2(100, 82)
		content.add_child(teacher)
	_text("Abelha Sábia • Vamos pensar!" if kind == "rocket" else "Obstáculo à frente!", 27)
	_text("%s • %s" % [q.title, q.skill], 16)
	timer = _text("", 18)
	if not str(q.reading).is_empty(): _text(q.reading, 23 if grade <= 3 else 21)
	_text(q.prompt, 25)
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

func _process(delta: float) -> void:
	clock += delta
	input_clock += delta
	if input_clock >= 0.05 and state.get("phase", "") == "run":
		input_clock = 0
		var intent := Vector2(
			float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
			float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
		Arcade.move(intent)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_leave()

func _leave() -> void:
	if closing: return
	closing = true
	Arcade.command("leave")
	if finished.get_connections().is_empty(): get_tree().change_scene_to_file("res://scenes/world/lobby.tscn")
	else: finished.emit({"completed": state.get("completed", false), "game": kind})

func _sprite(texture: Texture2D, center: Vector2, extent: Vector2, tint := Color.WHITE) -> void:
	draw_texture_rect(texture, Rect2(center - extent / 2, extent), false, tint)

func _draw() -> void:
	if background == null: return
	draw_rect(Rect2(0, 0, 1152, 720), Color("10213d"))
	var progress := clampf(float(state.get("distance", 0)) / Arcade.FINISH, 0, 1)
	if kind == "race":
		var offset := fmod(float(state.get("distance", 0)) * 0.15, 1152.0)
		draw_texture_rect(background, Rect2(-offset, 95, 1152, 578), false)
		draw_texture_rect(background, Rect2(1152 - offset, 95, 1152, 578), false)
	else:
		var bg_y := lerpf(-1055.0, 95.0, clampf(progress * 2, 0, 1))
		draw_texture_rect(background, Rect2(0, bg_y, 1152, 1728), false)
		var fade := smoothstep(0.42, 0.60, progress)
		if fade > 0: draw_texture_rect(space, Rect2(0, lerpf(-1055.0, 95.0, clampf((progress - 0.5) * 2, 0, 1)), 1152, 1728), false, Color(1, 1, 1, fade))
	var frame := int(clock * 7)
	var p: Vector2 = state.get("position", Vector2(265, 410) if kind == "race" else Vector2(576, 535))
	if kind == "race":
		for rival in range(3):
			var rival_x := 265 + (float(state.get("rank", 4)) - rival - 1.5) * 110 + sin(clock * 1.3 + rival) * 12
			_sprite(art.boat(frame + rival), Vector2(clampf(rival_x, 120, 940), 290 + rival * 100), Vector2(145, 112), Color(0.8, 0.88, 1, 0.85))
	for object in state.get("objects", []):
		var object_pos: Vector2 = object.p
		match object.type:
			"obstacle": _sprite(art.obstacle(int(object.variant)), object_pos, Vector2(135, 92))
			"coin": _sprite(art.coin(frame), object_pos, Vector2(42, 42))
			"honey": _sprite(art.honey(frame), object_pos, Vector2(70, 64))
			"bee": _sprite(art.bee(frame, progress > 0.5), object_pos, Vector2(98, 86))
	if kind == "race":
		if float(state.get("slow", 0)) > 0: _sprite(art.splash(frame), p + Vector2(5, 24), Vector2(150, 86))
		_sprite(art.boat(frame), p + Vector2(0, sin(clock * 4) * 3), Vector2(178, 140))
	else:
		if float(state.get("invincible", 0)) > 0: draw_arc(p, 77, 0, TAU, 60, Color(0.4, 0.9, 1, 0.7), 3, true)
		_sprite(art.rocket(frame, float(state.get("boost", 0)) > 0), p, Vector2(105, 151))
		_sprite(art.fuel(float(state.get("fuel", 100))), Vector2(860, 58), Vector2(44, 42))
