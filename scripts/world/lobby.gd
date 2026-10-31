extends Node2D

const SIGN := preload("res://scripts/world/direction_sign.gd")
const GROUND := preload("res://assets/cenario/praca/chao.png")
const BUSH := preload("res://assets/cenario/praca/arbusto.png")
const BENCH := preload("res://assets/cenario/praca/banco.png")
const BEAR := preload("res://scenes/player/bear.tscn")
const COMMERCE := preload("res://scenes/world/commerce.tscn")
const MAP := preload("res://scripts/world/world_map.gd")
const CATALOG := preload("res://scripts/world/world_catalog.gd")
const AREA := preload("res://scripts/world/expanded_area.gd")
const DISCOVERY := preload("res://scripts/world/discovery_map.gd")
var expanded: Dictionary={}
var quests: Control
var action_dialog: AcceptDialog
var interaction_hint: Label
var bamboo_view: Node2D
var fountain: Sprite2D
var world_hud: Control
var login_panel: PanelContainer
var commerce_view: Node2D
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

func _ready() -> void:
	for zone in ["language","loja_pets","loja_cosmeticos","provador"]:
		var area:=AREA.new()
		area.zone=zone
		area.visible=false
		add_child(area)
		expanded[zone]=area
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
	var movement := Vector2.ZERO
	var focused := get_viewport().gui_get_focus_owner()
	if current_zone in Minigames.WORLD_ZONES and not focused is LineEdit and not is_instance_valid(map_view) and not is_instance_valid(quests) and not (is_instance_valid(action_dialog) and action_dialog.visible):
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
	interaction_hint.text=_hint()
	if current_zone in Minigames.WORLD_ZONES and Network.players.has(id):
		nearby_portal = Minigames.exit_at(Network.players[id].position,current_zone)
	if nearby_portal.is_empty():
		exit_armed = true
	elif exit_armed and not is_instance_valid(map_view) and not is_instance_valid(quests):
		exit_armed = false
		Network.request_zone(nearby_portal)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if Network.active and not get_viewport().gui_get_focus_owner() is LineEdit:
			if event.physical_keycode==KEY_Q:
				_toggle_quests()
				get_viewport().set_input_as_handled()
				return
			if is_instance_valid(quests):
				if event.physical_keycode==KEY_ESCAPE: _close_quests()
				get_viewport().set_input_as_handled()
				return
			if event.physical_keycode==KEY_SPACE and current_zone in Minigames.WORLD_ZONES:
				Network.interact("sit")
				get_viewport().set_input_as_handled()
				return
			if event.physical_keycode==KEY_E and current_zone in Minigames.WORLD_ZONES:
				_interact_nearby()
				get_viewport().set_input_as_handled()
				return
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
	_close_quests()

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
	_close_quests()
	if is_instance_valid(game_view):
		game_view.queue_free()
		game_view = null
	hud.visible = zone in Minigames.WORLD_ZONES
	commerce_view.visible = zone == "commerce"
	bamboo_view.visible = zone == "math"
	for area_zone in expanded:
		expanded[area_zone].visible=zone==area_zone
	fountain.visible = zone == "lobby"
	for sign_board in signs:
		sign_board.visible = zone == "lobby"
	title_label.text = "MUNDO DOS URSOS  /  " + CATALOG.TITLES.get(zone,zone)
	queue_redraw()
	if zone in Minigames.WORLD_ZONES:
		get_viewport().gui_release_focus()
		return
	if zone in ["ship","cave","science"]:
		game_view=load("res://scripts/minigames/learning_room.gd").new()
		game_view.zone=zone
	else:
		var scene: PackedScene = load(Minigames.PORTALS[zone].scene)
		game_view = scene.instantiate()
	game_view.finished.connect(_minigame_finished)
	game_layer.add_child(game_view)

func _minigame_finished(_result: Dictionary) -> void:
	# Navigation only. Reward validation will be integrated separately on the server.
	Network.request_zone("math" if current_zone == "dojo" else ("language" if current_zone in ["ship","cave"] else "lobby"))

func _sync_players() -> void:
	if not Network.active:
		_close_map()
		_close_quests()
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
		bears[id].sitting=state.get("sitting",false)
		bears[id].pet_kind=state.get("pet","fish")
		bears[id].outfit=state.get("outfit","none")
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
	world_hud.quests_requested.connect(_toggle_quests)
	interaction_hint=Label.new()
	interaction_hint.position=Vector2(305,174)
	interaction_hint.size=Vector2(540,28)
	interaction_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	interaction_hint.add_theme_font_size_override("font_size",17)
	layer.add_child(interaction_hint)
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
	if not is_instance_valid(result_dialog):
		result_dialog = AcceptDialog.new()
		add_child(result_dialog)
	result_dialog.title = "Empate" if result.winner == -1 else ("Vitória!" if result.winner == mine else "Derrota")
	result_dialog.dialog_text = result.feedback
	result_dialog.popup_centered(Vector2i(440,160))

func _toggle_quests() -> void:
	if not Network.active: return
	if is_instance_valid(quests):
		_close_quests()
		return
	_close_map()
	quests=DISCOVERY.new()
	quests.z_index=100
	quests.close_requested.connect(_close_quests)
	quests.travel_requested.connect(func(destination: String): _close_quests(); Network.travel_to(destination))
	game_layer.add_child(quests)

func _close_quests() -> void:
	if is_instance_valid(quests):
		quests.queue_free()
		quests=null
	get_viewport().gui_release_focus()

func _hint() -> String:
	var p: Dictionary=Network.players.get(multiplayer.get_unique_id(),{})
	if p.is_empty(): return ""
	if p.get("sitting",false): return "Espaço ou movimento: levantar  •  Q: história e diárias"
	if CATALOG.nearest_seat(current_zone,p.position)>=0: return "Espaço: sentar  •  Q: história e diárias"
	if current_zone=="loja_pets": return "E: escolher seu pet  •  Q: história e diárias"
	if current_zone=="provador": return "E: experimentar um lenço  •  Q: história e diárias"
	if current_zone=="language":
		if p.position.distance_to(Vector2(275,411))<75: return "E: investigar o mamute"
		if p.position.distance_to(Vector2(885,574))<75: return "E: investigar o fóssil"
	return "Q: história e missões diárias" if current_zone in Minigames.WORLD_ZONES else ""

func _interact_nearby() -> void:
	if is_instance_valid(action_dialog): action_dialog.queue_free()
	var options: Dictionary={}
	var title:=""
	var text:=""
	var kind:=""
	if current_zone=="loja_pets":
		title="Escolha seu companheiro"
		text="Peixe e papagaio estão disponíveis nesta versão. Sua escolha fica salva."
		options={"Peixe voador":"fish","Papagaio":"parrot"}
		kind="pet"
	elif current_zone=="provador":
		title="Experimente no espelho"
		text="Escolha um lenço. Os outros jogadores também veem sua aparência."
		options={"Sem lenço":"none","Lenço vermelho":"scarf_red","Lenço azul":"scarf_blue"}
		kind="outfit"
	elif current_zone=="language":
		var point: Vector2=Network.players.get(multiplayer.get_unique_id(),{}).get("position",Vector2.ZERO)
		if point.distance_to(Vector2(275,411))<75:
			title="Mamute congelado"
			text="Mamutes eram parentes dos elefantes. Algumas espécies tinham pelos espessos, que ajudavam a conservar o calor."
			Network.interact("discover","mammoth")
		elif point.distance_to(Vector2(885,574))<75:
			title="Lago com fóssil"
			text="Fósseis são restos ou vestígios de seres vivos preservados. Eles ajudam a investigar como era a vida no passado. A figura no lago é uma representação artística."
			Network.interact("discover","fossil")
	if title.is_empty(): return
	action_dialog=AcceptDialog.new()
	action_dialog.title=title
	action_dialog.dialog_text=text
	add_child(action_dialog)
	if not options.is_empty():
		var row:=HBoxContainer.new()
		row.position=Vector2(20,95)
		row.add_theme_constant_override("separation",12)
		action_dialog.add_child(row)
		for caption in options:
			var value: String=options[caption]
			var button:=Button.new()
			button.text=caption
			button.custom_minimum_size=Vector2(150,46)
			button.pressed.connect(func(): Network.interact(kind,value); action_dialog.hide(); get_viewport().gui_release_focus())
			row.add_child(button)
	action_dialog.popup_centered(Vector2i(600,220))
