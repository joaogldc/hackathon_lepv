extends Node2D

const SIGN := preload("res://scripts/world/direction_sign.gd")
const GROUND := preload("res://assets/cenario/praca/chao.png")
const BUSH := preload("res://assets/cenario/praca/arbusto.png")
const BENCH := preload("res://assets/cenario/praca/banco.png")
const BEAR := preload("res://scenes/player/bear.tscn")
const COMMERCE := preload("res://scenes/world/commerce.tscn")
const MAP := preload("res://scripts/world/world_map.gd")
var bamboo_view: Node2D
var fountain: Sprite2D
var world_hud: Control
var commerce_ui: Control
var login_panel: PanelContainer
var commerce_view: Node2D
var interior_view: Node2D
var title_label: Label
var bears: Dictionary = {}
var name_field: LineEdit
var address_field: LineEdit
var status_label: Label
var count_label: Label
var host_button: Button
var join_button: Button
var hud: CanvasLayer
var game_layer: CanvasLayer
var game_view: Control
var portal_button: Button
var current_zone := "lobby"
var nearby_portal := ""
var result_dialog: AcceptDialog
var transition_tween: Tween
var exit_armed := false
var map_view: Control
var signs: Array[Node2D] = []
@onready var recompensa_moedas: CanvasLayer = $RecompensaMoedas
@onready var recompensa_xp: CanvasLayer = $RecompensaXP
var xp_pendente := false

func _ready() -> void:
	recompensa_moedas.fechada.connect(_apos_moedas)
	var sign_positions := {"commerce": Vector2(715,340), "math": Vector2(117,420), "science": Vector2(1020,420), "language": Vector2(715,620)}
	for destination in sign_positions:
		var sign_board := SIGN.new()
		sign_board.destination = destination
		sign_board.position = sign_positions[destination]
		add_child(sign_board)
		signs.append(sign_board)
	commerce_view = COMMERCE.instantiate()
	commerce_view.visible = false
	add_child(commerce_view)
	interior_view = load("res://scripts/world/shop_interior.gd").new()
	add_child(interior_view)
	interior_view.hide()
	bamboo_view = load("res://scripts/world/bamboo.gd").new()
	bamboo_view.visible = false
	add_child(bamboo_view)
	fountain = Sprite2D.new()
	fountain.texture = load("res://assets/cenario/praca/chafariz.png")
	fountain.position = Vector2(576, 401)
	fountain.scale = Vector2(0.5, 0.5)
	fountain.z_index = 478
	add_child(fountain)
	_build_ui()
	Network.status_changed.connect(func(message: String): status_label.text = message)
	Network.roster_changed.connect(_sync_players)
	Duel.result_received.connect(_show_result)
	game_layer = CanvasLayer.new()
	game_layer.layer = 10
	var commerce_layer := CanvasLayer.new()
	commerce_layer.layer = 8
	add_child(commerce_layer)
	commerce_ui = load("res://scripts/ui/commerce_hud.gd").new()
	commerce_layer.add_child(commerce_ui)
	add_child(game_layer)
	var args := OS.get_cmdline_user_args()
	if "--server" in args:
		Network.host("", true)
	elif "--host" in args:
		Network.host("Anfitrião")
	elif "--join" in args:
		Network.join_room("Visitante", "ws://127.0.0.1:9080")
	queue_redraw()

func _process(_delta: float) -> void:
	var recompensa_aberta := recompensa_moedas.visible or recompensa_xp.visible
	if current_zone == "language" and is_instance_valid(game_view):
		game_view.permitir_movimento = not recompensa_aberta and not is_instance_valid(map_view)
	var movement := Vector2.ZERO
	var focused := get_viewport().gui_get_focus_owner()
	if current_zone in Minigames.WORLD_ZONES and not focused is LineEdit and not is_instance_valid(map_view) and not recompensa_aberta and not (is_instance_valid(commerce_ui) and commerce_ui.is_open()):
		movement = Vector2(
			float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
			float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	Network.set_movement(movement)
	host_button.disabled = Network.active or OS.has_feature("web")
	join_button.disabled = Network.active
	var has_profile := Network.players.has(multiplayer.get_unique_id())
	login_panel.visible = not has_profile
	world_hud.visible = has_profile
	count_label.visible = false
	nearby_portal = ""
	var id := multiplayer.get_unique_id()
	portal_button.visible = false
	if current_zone in Minigames.WORLD_ZONES and Network.players.has(id):
		nearby_portal = Minigames.exit_at(Network.players[id].position,current_zone)
	if nearby_portal.is_empty():
		exit_armed = true
	elif exit_armed and not is_instance_valid(map_view) and not recompensa_aberta and not (is_instance_valid(commerce_ui) and commerce_ui.is_open()):
		exit_armed = false
		Network.request_zone(nearby_portal)

func _input(event: InputEvent) -> void:
	if recompensa_moedas.visible or recompensa_xp.visible:
		return
	if is_instance_valid(commerce_ui) and Network.active and not get_viewport().gui_get_focus_owner() is LineEdit:
		if commerce_ui.handle_key(event):
			_close_map()
			get_viewport().set_input_as_handled()
			return
		if commerce_ui.is_open(): return
	if event is InputEventKey and event.pressed and not event.echo:
		if Network.active and not get_viewport().gui_get_focus_owner() is LineEdit:
			if event.physical_keycode == KEY_P and current_zone in Minigames.WORLD_ZONES:
				world_hud.toggle_passport()
				get_viewport().set_input_as_handled()
				return
			if event.physical_keycode == KEY_M:
				_toggle_map()
				get_viewport().set_input_as_handled()
				return
			if event.physical_keycode == KEY_ESCAPE and is_instance_valid(map_view):
				_close_map()
				get_viewport().set_input_as_handled()
				return

func _unhandled_key_input(event: InputEvent) -> void:
	if is_instance_valid(map_view):
		return

func _toggle_map() -> void:
	if not Network.active or not Network.players.has(multiplayer.get_unique_id()):
		return
	if is_instance_valid(map_view):
		_close_map()
		return
	map_view = MAP.new()
	map_view.destination_selected.connect(_travel_from_map)
	map_view.close_requested.connect(_close_map)
	game_layer.add_child(map_view)

func _travel_from_map(destination: String) -> void:
	Network.travel_to(destination)
	_close_map()

func _close_map() -> void:
	if is_instance_valid(map_view):
		map_view.queue_free()
		map_view = null
	get_viewport().gui_release_focus()

func _enter_portal() -> void:
	if not nearby_portal.is_empty():
		Network.request_zone(nearby_portal)
		get_viewport().gui_release_focus()

func _set_zone(zone: String) -> void:
	if zone == current_zone:
		return
	var previous_zone := current_zone
	current_zone = zone
	if is_instance_valid(commerce_ui): commerce_ui.close_window()
	if transition_tween:
		transition_tween.kill()
	position = Vector2.ZERO
	if zone in Minigames.WORLD_ZONES:
		var offset := Vector2(0,24)
		if previous_zone == "lobby" and zone == "math":
			offset = Vector2(0,35)
		elif previous_zone == "math" and zone == "lobby":
			offset = Vector2(55,0)
		position = offset
		transition_tween = create_tween()
		transition_tween.tween_property(self,"position",Vector2.ZERO,0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	exit_armed = false
	_close_map()
	if is_instance_valid(game_view):
		game_view.queue_free()
		game_view = null
	hud.visible = zone in Minigames.WORLD_ZONES
	commerce_view.visible = zone == "commerce"
	interior_view.visible = zone in Minigames.SHOP_ZONES
	if interior_view.visible: interior_view.set_room(zone)
	bamboo_view.visible = zone == "math"
	fountain.visible = zone == "lobby"
	for sign_board in signs:
		sign_board.visible = zone == "lobby"
	title_label.text = "MUNDO DOS URSOS  /  " + ("Área comercial" if zone == "commerce" else ("Bosque da Matemática" if zone == "math" else "Praça dos encontros"))
	queue_redraw()
	if zone in Minigames.WORLD_ZONES:
		get_viewport().gui_release_focus()
		return
	var scene: PackedScene = load(Minigames.PORTALS[zone].scene)
	game_view = scene.instantiate()
	game_view.finished.connect(_minigame_finished)
	game_layer.add_child(game_view)

func _minigame_finished(_result: Dictionary) -> void:
	# Navigation only. Reward validation will be integrated separately on the server.
	Network.request_zone("math" if current_zone == "dojo" else "lobby")

func _sync_players() -> void:
	if not Network.active:
		_close_map()
		xp_pendente = false
		recompensa_moedas.fechar()
		recompensa_xp.reiniciar_sessao()
	var local_id := multiplayer.get_unique_id()
	var zone := "lobby"
	if Network.players.has(local_id):
		zone = Network.players[local_id].zone
	_set_zone(zone)
	var in_plaza := 0
	for id in bears.keys():
		if not Network.players.has(id):
			bears[id].queue_free()
			bears.erase(id)
	for id in Network.players:
		var state: Dictionary = Network.players[id]
		if not bears.has(id):
			var bear := BEAR.instantiate()
			bear.position = state.position
			add_child(bear)
			bears[id] = bear
		if bears[id].get_meta("zone", "") != state.zone:
			bears[id].position = state.position
			bears[id].set_meta("zone", state.zone)
		bears[id].target = state.position
		bears[id].direction = state.direction
		bears[id].nickname = state.nickname
		bears[id].local_player = id == multiplayer.get_unique_id()
		bears[id].visible = state.zone == current_zone and current_zone in Minigames.WORLD_ZONES
		if state.zone == current_zone:
			in_plaza += 1
	count_label.text = "%d nesta área • %d online" % [in_plaza, Network.players.size()]

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	hud = layer
	add_child(layer)
	world_hud = load("res://scripts/world/world_hud.gd").new()
	layer.add_child(world_hud)
	world_hud.visible = false
	world_hud.map_requested.connect(_toggle_map)
	world_hud.travel_requested.connect(_travel_from_map)
	world_hud.daily_requested.connect(func(): _close_map(); commerce_ui.open_page("daily"))
	var panel := PanelContainer.new()
	login_panel = panel
	panel.position = Vector2(24, 18)
	panel.size = Vector2(1104, 170)
	layer.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	var title := Label.new()
	title_label = title
	title.text = "MUNDO DOS URSOS  /  Praça dos encontros"
	title.add_theme_font_size_override("font_size", 26)
	box.add_child(title)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	name_field = LineEdit.new()
	name_field.placeholder_text = "Seu apelido"
	name_field.text = "Urso"
	name_field.max_length = 18
	name_field.custom_minimum_size.x = 170
	row.add_child(name_field)
	address_field = LineEdit.new()
	address_field.text = "ws://127.0.0.1:9080"
	address_field.custom_minimum_size.x = 300
	row.add_child(address_field)
	host_button = _button(row, "Criar sala", func():
		Network.host(name_field.text)
		get_viewport().gui_release_focus())
	join_button = _button(row, "Entrar", func():
		Network.join_room(name_field.text, address_field.text)
		get_viewport().gui_release_focus())
	_button(row, "Sair", func(): Network.leave())
	status_label = Label.new()
	status_label.text = "Crie uma sala ou entre usando o endereço do anfitrião."
	box.add_child(status_label)
	count_label = Label.new()
	count_label.position = Vector2(40, 652)
	count_label.text = "0 na praça • 0 online"
	layer.add_child(count_label)
	var help := Label.new()
	help.text = "WASD / setas: andar  •  Passe nas setas para sair  •  M: mapa da ilha"
	help.position = Vector2(390, 652)
	help.visible = false
	layer.add_child(help)
	portal_button = _button(layer, "Entrar no portal  [E]", _enter_portal)
	portal_button.position = Vector2(375, 680)
	portal_button.size = Vector2(410, 32)
	portal_button.visible = false
	var map_button := _button(layer, "Mapa [M]", _toggle_map)
	map_button.visible = false
	map_button.position = Vector2(980, 130)
	map_button.size = Vector2(125, 36)

func _button(parent: Node, caption: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _draw() -> void:
	if current_zone != "lobby":
		return
	draw_texture_rect(GROUND, Rect2(24, 204, 1104, 436), false)
	for point in [Vector2(290, 295), Vector2(850, 295), Vector2(290, 555), Vector2(850, 555)]:
		draw_texture_rect(BUSH, Rect2(point - Vector2(45, 38), Vector2(90, 66)), false)
	for point in [Vector2(365, 340), Vector2(780, 340)]:
		draw_texture_rect(BENCH, Rect2(point - Vector2(48, 32), Vector2(96, 64)), false)
	for id in Minigames.PORTALS:
		if id == "dojo":
			continue
		var portal: Dictionary = Minigames.PORTALS[id]
		var point: Vector2 = portal.position
		var angle := 0.0
		if id == "commerce":
			angle = PI
		elif id == "math":
			angle = PI / 2
		elif id == "science":
			angle = -PI / 2
		load("res://scripts/world/ground_arrow.gd").paint(self,point,angle)

func _ground_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("60866a")
	style.set_corner_radius_all(32)
	return style

func _show_result(result: Dictionary) -> void:
	var mine: int = result.ids.find(multiplayer.get_unique_id())
	if mine >= 0 and result.winner == mine:
		# O resultado vem de Duel; este efeito não concede saldo por conta própria.
		_close_map()
		if is_instance_valid(result_dialog):
			result_dialog.hide()
		recompensa_moedas.mostrar(-1, str(result.names[mine]))
		xp_pendente = true
		return
	if not is_instance_valid(result_dialog):
		result_dialog = AcceptDialog.new()
		add_child(result_dialog)
	result_dialog.title = "Empate" if result.winner == -1 else ("Vitória!" if result.winner == mine else "Derrota")
	result_dialog.dialog_text = result.feedback
	result_dialog.popup_centered(Vector2i(440,160))

func _apos_moedas() -> void:
	if not xp_pendente: return
	xp_pendente = false
	if Network.active:
		recompensa_xp.mostrar()
