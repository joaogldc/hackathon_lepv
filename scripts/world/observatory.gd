extends Control
## Local explorable science habitat; quiz simulation and rewards stay on the server.
signal finished(result: Dictionary)
const BACKGROUND_PATH := "res://assets/cenario/observatorio/clareira_observatorio_v1.png"
const ART := preload("res://scripts/minigames/arcade_art.gd")
const FONTS := preload("res://scripts/ui/game_fonts.gd")
const PLAYER := preload("res://scenes/player/bear.tscn")
const WALK := Rect2(170,440,810,196)
const START := Vector2(576,590)
const LAUNCH := Vector2(380,470)
const TEACHER := Vector2(660,475)
const TELESCOPE := Vector2(865,460)
var background: Texture2D
var art = ART.new()
var player: Node2D
var game: Control
var dialog: PanelContainer
var tip: Label
var exit_armed := false
var clock := 0.0

func _ready() -> void:
	background = load(BACKGROUND_PATH)
	clip_contents = true
	get_viewport().size_changed.connect(_resize)
	_resize()
	player = PLAYER.instantiate()
	player.depth_sort = false
	player.position = START
	player.target = START
	player.nickname = Network.nickname if not Network.nickname.is_empty() else "Explorador"
	var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(),{})
	player.outfit = profile.get("outfit","none")
	player.outfits = profile.get("outfits",{}).duplicate()
	player.pet_kind = profile.get("pet","fish")
	player.pet_acc = profile.get("pet_acc","none")
	add_child(player)
	var bar := PanelContainer.new()
	bar.position = Vector2(18,12)
	bar.size = Vector2(1116,64)
	bar.add_theme_stylebox_override("panel",_paper())
	add_child(bar)
	var row := HBoxContainer.new()
	bar.add_child(row)
	var title := Label.new()
	title.text = "Observatório • Clareira das descobertas"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font",FONTS.title())
	title.add_theme_font_size_override("font_size",24)
	title.add_theme_color_override("font_color",Color("513d2b"))
	row.add_child(title)
	var leave := _button("Voltar à praça [Esc]",_leave)
	row.add_child(leave)
	var help := Label.new()
	help.position = Vector2(20,86)
	help.size = Vector2(1112,28)
	help.text = "WASD / setas: caminhar   •   E: interagir   •   Foguete: aventura de ciências"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_style(help,17)
	add_child(help)
	var footer := PanelContainer.new()
	footer.position = Vector2(120,658)
	footer.size = Vector2(912,48)
	footer.add_theme_stylebox_override("panel",_paper())
	add_child(footer)
	tip = Label.new()
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size",18)
	tip.add_theme_color_override("font_color",Color("513d2b"))
	footer.add_child(tip)

func _paper() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("fff5dc")
	box.border_color = Color("946b34")
	box.set_border_width_all(2)
	box.set_corner_radius_all(14)
	box.set_content_margin_all(12)
	return box

func _button(caption: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 40
	button.add_theme_stylebox_override("normal",_paper())
	button.add_theme_color_override("font_color",Color("513d2b"))
	button.pressed.connect(action)
	return button

func _text_style(label: Label, font_size: int) -> void:
	label.add_theme_font_override("font",preload("res://assets/fonts/Lato-Bold.ttf"))
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("fff5dc"))
	label.add_theme_color_override("font_outline_color",Color("263f31"))
	label.add_theme_constant_override("outline_size",5)

func _resize() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(1152,720)
	var viewport := get_viewport_rect().size
	scale = Vector2.ONE * minf(viewport.x / size.x,viewport.y / size.y)
	position = (viewport - size * scale) / 2

func _near() -> String:
	if player.position.distance_to(LAUNCH) < 90: return "launch"
	if player.position.distance_to(TEACHER) < 80: return "teacher"
	if player.position.distance_to(TELESCOPE) < 85: return "telescope"
	return ""

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()
	if is_instance_valid(game) or is_instance_valid(dialog): return
	var move := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).limit_length()
	player.target = _walk_target(player.target + move * 180 * delta)
	if move.length_squared() > 0:
		player.direction = ("right" if move.x>0 else "left") if absf(move.x)>absf(move.y) else ("front" if move.y>0 else "back")
	var at_exit: bool = player.position.y>620 and absf(player.position.x-576)<70
	if not at_exit: exit_armed = true
	elif exit_armed and move.y>0:
		_leave()
		return
	tip.text = {"launch":"[E] Entrar no foguete e decolar", "teacher":"[E] Conversar com a Abelha Sábia", "telescope":"[E] Observar o céu pelo telescópio"}.get(_near(),"Explore a clareira: foguete, Abelha Sábia e telescópio.")

func _walk_target(point: Vector2) -> Vector2:
	var result := point.clamp(WALK.position,WALK.end)
	# The fence narrows the lower clearing into the central exit path.
	var edge := lerpf(170,500,clampf((result.y-590)/46.0,0,1))
	result.x = clampf(result.x,edge,1152-edge)
	return result

func _unhandled_key_input(event: InputEvent) -> void:
	if is_instance_valid(game): return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if is_instance_valid(dialog): _close_dialog()
		else: _leave()
	elif event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode==KEY_E or event.keycode==KEY_E):
		get_viewport().set_input_as_handled()
		if is_instance_valid(dialog): return
		match _near():
			"launch": _launch()
			"teacher": _talk(false)
			"telescope": _talk(true)

func _talk(telescope: bool) -> void:
	dialog = PanelContainer.new()
	dialog.position = Vector2(286,170)
	dialog.size = Vector2(580,400)
	dialog.add_theme_stylebox_override("panel",_paper())
	add_child(dialog)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",14)
	dialog.add_child(content)
	var portrait := TextureRect.new()
	portrait.texture = art.teacher()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size.y = 110
	content.add_child(portrait)
	var label := Label.new()
	label.text = "O céu do observatório" if telescope else "Abelha Sábia • Antes de decolar"
	label.add_theme_font_size_override("font_size",25)
	label.add_theme_color_override("font_color",Color("513d2b"))
	content.add_child(label)
	var body := Label.new()
	body.text = "A Lua reflete a luz do Sol. A rotação da Terra faz o céu parecer se mover durante a noite. Na aventura, vamos investigar essas descobertas!" if telescope else "Nosso foguete usa mel como combustível! Recolha potes e responda às perguntas para encher o tanque e ganhar turbo. Desvie das abelhas; no espaço elas usam capacetes. Escolha seu ano antes de partir."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size",21)
	body.add_theme_color_override("font_color",Color("513d2b"))
	content.add_child(body)
	content.add_child(_button("Preparar decolagem",func(): _close_dialog(); _launch()))
	content.add_child(_button("Continuar explorando",_close_dialog))

func _close_dialog() -> void:
	if is_instance_valid(dialog):
		remove_child(dialog)
		dialog.queue_free()
	dialog = null
	get_viewport().gui_release_focus()

func _launch() -> void:
	if is_instance_valid(game): return
	game = preload("res://scripts/minigames/arcade_game.gd").new()
	game.kind = "rocket"
	game.finished.connect(_land)
	player.hide()
	add_child(game)

func _land(_result: Dictionary) -> void:
	Arcade.command("leave")
	if is_instance_valid(game):
		remove_child(game)
		game.queue_free()
	game = null
	player.position = START
	player.target = START
	player.show()
	get_viewport().gui_release_focus()

func _leave() -> void:
	if is_instance_valid(game): return
	finished.emit({"game":"science","completed":false})

func _draw() -> void:
	if background: draw_texture_rect(background,Rect2(0,0,1152,720),false)
	if is_instance_valid(game): return
	draw_texture_rect(art.teacher(),Rect2(620,358+sin(clock*2)*3,80,100),false)
	for point in [LAUNCH,TEACHER,TELESCOPE]:
		draw_arc(point,25+sin(clock*3)*2,0,TAU,40,Color("ffd36c"),3,true)
	FONTS.nameplate(self,"DECOLAR",LAUNCH.x,LAUNCH.y-34,18)
	FONTS.nameplate(self,"Abelha Sábia",TEACHER.x,TEACHER.y-126,17)
	FONTS.nameplate(self,"TELESCÓPIO",TELESCOPE.x,TELESCOPE.y-34,18)
	preload("res://scripts/world/ground_arrow.gd").paint(self,Vector2(576,628),0.0)
