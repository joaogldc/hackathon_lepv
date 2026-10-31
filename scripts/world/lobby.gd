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
const PET := preload("res://scripts/player/pet_companion.gd")
var expanded: Dictionary={}
var quests: Control
var action_dialog: AcceptDialog
var interaction_hint: Label
var bamboo_view: Node2D
var fountain: Sprite2D
var world_hud: Control
var commerce_ui: Control
var login_panel: PanelContainer
var commerce_view: Node2D
var title_label: Label
var bears: Dictionary = {}
var name_field: LineEdit
var address_field: LineEdit
var status_label: Label
var host_button: Button
var join_button: Button
var hud: CanvasLayer
var game_layer: CanvasLayer
var game_view: Control
var current_zone := "lobby"
var nearby_portal := ""
var result_dialog: AcceptDialog
var transition_tween: Tween
var exit_armed := false
var map_view: Control
var student_dashboard: Control
var signs: Array[Node2D] = []
@onready var recompensa_moedas: CanvasLayer = $RecompensaMoedas
@onready var recompensa_xp: CanvasLayer = $RecompensaXP
var xp_pendente := false
var xp_dados: Dictionary={}

func _ready() -> void:
	recompensa_moedas.fechada.connect(_show_pending_xp)
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
	var commerce_layer := CanvasLayer.new()
	commerce_layer.layer = 8
	add_child(commerce_layer)
	commerce_ui = load("res://scripts/ui/commerce_hud.gd").new()
	commerce_layer.add_child(commerce_ui)
	commerce_ui.story_requested.connect(_toggle_quests)
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
	if current_zone=="ship" and is_instance_valid(game_view):
		game_view.permitir_movimento=not is_instance_valid(map_view) and not is_instance_valid(quests) and not recompensa_aberta
	var movement := Vector2.ZERO
	var focused := get_viewport().gui_get_focus_owner()
	if current_zone in Minigames.WORLD_ZONES and not focused is LineEdit and not is_instance_valid(map_view) and not is_instance_valid(quests) and not (is_instance_valid(action_dialog) and action_dialog.visible) and not recompensa_aberta and not (is_instance_valid(commerce_ui) and commerce_ui.is_open()):
		movement = Vector2(
			float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
			float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	Network.set_movement(movement)
	host_button.disabled = Network.active or OS.has_feature("web")
	join_button.disabled = Network.active
	var has_profile := Network.players.has(multiplayer.get_unique_id())
	login_panel.visible = not has_profile
	world_hud.visible = has_profile
	nearby_portal = ""
	var id := multiplayer.get_unique_id()
	interaction_hint.text=_hint()
	if current_zone in Minigames.WORLD_ZONES and Network.players.has(id):
		nearby_portal = Minigames.exit_at(Network.players[id].position,current_zone)
	if nearby_portal.is_empty():
		exit_armed = true
	elif exit_armed and current_zone!="provador" and not is_instance_valid(map_view) and not is_instance_valid(quests) and not recompensa_aberta and not (is_instance_valid(commerce_ui) and commerce_ui.is_open()):
		exit_armed = false
		Network.request_zone(nearby_portal)

func _input(event: InputEvent) -> void:
	if recompensa_moedas.visible or recompensa_xp.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var dashboard_key: int = event.keycode if event.keycode else event.physical_keycode
		if is_instance_valid(student_dashboard) and student_dashboard.visible:
			if dashboard_key == KEY_R or dashboard_key == KEY_ESCAPE:
				_close_student_dashboard()
			get_viewport().set_input_as_handled()
			return
		if dashboard_key == KEY_R and Network.active and not get_viewport().gui_get_focus_owner() is LineEdit:
			_toggle_student_dashboard()
			get_viewport().set_input_as_handled()
			return
	if is_instance_valid(commerce_ui) and Network.active and not get_viewport().gui_get_focus_owner() is LineEdit:
		if not is_instance_valid(quests) and commerce_ui.handle_key(event):
			_close_map()
			get_viewport().set_input_as_handled()
			return
		if commerce_ui.is_open(): return
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int=event.keycode if event.keycode else event.physical_keycode
		if Network.active and not get_viewport().gui_get_focus_owner() is LineEdit:
			if key==KEY_Q:
				_toggle_quests()
				get_viewport().set_input_as_handled()
				return
			if is_instance_valid(quests):
				if key==KEY_ESCAPE: _close_quests()
				get_viewport().set_input_as_handled()
				return
			if current_zone in Minigames.WORLD_ZONES:
				if key==KEY_B:
					_toggle_pet_emotes()
					get_viewport().set_input_as_handled()
					return
				if key>=KEY_1 and key<=KEY_8:
					Network.interact("pet_emote",PET.EMOTE_IDS[key-KEY_1])
					get_viewport().set_input_as_handled()
					return
			if key==KEY_SPACE and current_zone in Minigames.WORLD_ZONES:
				Network.interact("sit")
				get_viewport().set_input_as_handled()
				return
			if key==KEY_E and current_zone in Minigames.WORLD_ZONES:
				_interact_nearby()
				get_viewport().set_input_as_handled()
				return
			if key == KEY_P and current_zone in Minigames.WORLD_ZONES:
				world_hud.toggle_passport()
				get_viewport().set_input_as_handled()
				return
			if key == KEY_M:
				_toggle_map()
				get_viewport().set_input_as_handled()
				return
			if key == KEY_ESCAPE and is_instance_valid(map_view):
				_close_map()
				get_viewport().set_input_as_handled()
				return

func _toggle_student_dashboard() -> void:
	if not Network.active or not Network.players.has(multiplayer.get_unique_id()):
		return
	if is_instance_valid(student_dashboard):
		_close_student_dashboard()
		return
	_close_map()
	_close_quests()
	if is_instance_valid(commerce_ui):
		commerce_ui.close_window()
	student_dashboard = load("res://scenes/ui/dashboard/student_dashboard.tscn").instantiate() as Control
	game_layer.add_child(student_dashboard)

func _close_student_dashboard() -> void:
	if is_instance_valid(student_dashboard):
		student_dashboard.queue_free()
		student_dashboard = null
	get_viewport().gui_release_focus()

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
	if zone=="ship":
		game_view=load("res://scenes/world/navio_deque.tscn").instantiate()
	elif zone in ["cave","science"]:
		game_view=load("res://scripts/minigames/learning_room.gd").new()
		game_view.zone=zone
	else:
		var scene: PackedScene = load(Minigames.PORTALS[zone].scene)
		game_view = scene.instantiate()
	game_view.finished.connect(_minigame_finished)
	game_layer.add_child(game_view)

func _minigame_finished(_result: Dictionary) -> void:
	# Navigation only; rewards are validated by the services on the server.
	Network.request_zone("math" if current_zone == "dojo" else ("language" if current_zone in ["ship","cave"] else "lobby"))

func _sync_players() -> void:
	if not Network.active:
		_close_map()
		_close_quests()
		_close_student_dashboard()
		xp_pendente=false
		recompensa_moedas.fechar()
		recompensa_xp.reiniciar_sessao()
	var local_id := multiplayer.get_unique_id()
	var zone := "lobby"
	if Network.players.has(local_id):
		zone = Network.players[local_id].zone
	_set_zone(zone)
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
		bears[id].pet_acc=state.get("pet_acc","none")
		bears[id].outfit=state.get("outfit","none")
		bears[id].outfits=state.get("outfits",{})
		bears[id].scale=Vector2.ONE*CATALOG.character_scale(state.zone)
		bears[id].pet_emote=state.get("pet_emote","")
		bears[id].visible = state.zone == current_zone and current_zone in Minigames.WORLD_ZONES

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	hud = layer
	add_child(layer)
	world_hud = load("res://scripts/world/world_hud.gd").new()
	layer.add_child(world_hud)
	world_hud.visible = false
	world_hud.map_requested.connect(_toggle_map)
	world_hud.travel_requested.connect(_travel_from_map)
	world_hud.daily_requested.connect(func(): _close_quests(); _close_map(); commerce_ui.open_page("daily"))
	world_hud.pet_emotes_requested.connect(_toggle_pet_emotes)
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
	name_field.text = Network.nickname
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

func _show_result(result: Dictionary) -> void:
	var mine: int = result.ids.find(multiplayer.get_unique_id())
	if mine >= 0 and result.winner == mine:
		# O resultado vem de Duel; este efeito não concede saldo por conta própria.
		_close_map()
		_close_quests()
		if is_instance_valid(result_dialog):
			result_dialog.hide()
		var amount: int=result.get("coin_rewards",[recompensa_moedas.quantidade_moedas,recompensa_moedas.quantidade_moedas])[mine]
		xp_dados={"amount":result.get("xp_rewards",[0,0])[mine],"before":result.get("xp_before",[0,0])[mine]}
		xp_pendente=int(xp_dados.amount)>0
		recompensa_moedas.mostrar(amount, str(result.names[mine]))
		return
	if not is_instance_valid(result_dialog):
		result_dialog = AcceptDialog.new()
		add_child(result_dialog)
	result_dialog.title = "Empate" if result.winner == -1 else ("Vitória!" if result.winner == mine else "Derrota")
	result_dialog.dialog_text = result.feedback
	result_dialog.popup_centered(Vector2i(440,160))

func _toggle_quests() -> void:
	if not Network.active: return
	if is_instance_valid(commerce_ui): commerce_ui.close_window()
	if is_instance_valid(quests):
		_close_quests()
		return
	_close_map()
	quests=DISCOVERY.new()
	quests.z_index=100
	quests.close_requested.connect(_close_quests)
	quests.daily_requested.connect(func(): _close_quests(); commerce_ui.open_page("daily"))
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
	if current_zone in ["loja_pets","loja_cosmeticos"]:
		if CATALOG.near_merchant(p.position): return "E: conversar com o comerciante  •  Q: história e diárias"
		return "Aproxime-se do comerciante para escolher "+("seu pet" if current_zone=="loja_pets" else "um acessório")
	if current_zone=="provador":
		return "E: sair do provador" if Minigames.exit_at(p.position,current_zone)!="" else "E: experimentar acessórios  •  Q: história e diárias"
	if current_zone=="language":
		if p.position.distance_to(Vector2(275,411))<75: return "E: investigar o mamute"
		if p.position.distance_to(Vector2(885,574))<75: return "E: investigar o fóssil"
	return "Q: história e missões diárias" if current_zone in Minigames.WORLD_ZONES else ""

func _interact_nearby() -> void:
	var local: Dictionary=Network.players.get(multiplayer.get_unique_id(),{})
	if current_zone=="provador" and not local.is_empty() and Minigames.exit_at(local.position,current_zone)!="":
		Network.request_zone("loja_cosmeticos")
		return
	if is_instance_valid(action_dialog): action_dialog.queue_free()
	var point: Vector2=Network.players.get(multiplayer.get_unique_id(),{}).get("position",Vector2.ZERO)
	var shop_action: String=Minigames.shop_action(current_zone,point)
	if not shop_action.is_empty():
		commerce_ui.open_page(shop_action)
		return
	if current_zone!="language": return
	var title:=""
	var text:=""
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
	action_dialog.popup_centered(Vector2i(640,260))

func _toggle_pet_emotes() -> void:
	if not Network.players.has(multiplayer.get_unique_id()): return
	if is_instance_valid(action_dialog):
		if action_dialog.visible and action_dialog.get_meta("pet_emotes",false):
			action_dialog.hide()
			return
		action_dialog.queue_free()
	action_dialog=AcceptDialog.new()
	action_dialog.title="Expressões do pet • atalhos 1 a 8"
	action_dialog.set_meta("pet_emotes",true)
	action_dialog.get_label().hide()
	var grid:=GridContainer.new()
	grid.columns=4
	grid.add_theme_constant_override("h_separation",12)
	grid.add_theme_constant_override("v_separation",12)
	action_dialog.add_child(grid)
	var species: String=Network.players[multiplayer.get_unique_id()].get("pet","fish")
	for index in range(8):
		var key: String=PET.EMOTE_IDS[index]
		var button:=Button.new()
		button.text=PET.EMOTE_NAMES[index]+" ["+str(index+1)+"]"
		button.icon=PET.expression(species,key)
		button.expand_icon=true
		button.add_theme_constant_override("icon_max_width",56)
		button.custom_minimum_size=Vector2(150,92)
		button.pressed.connect(func(): Network.interact("pet_emote",key); action_dialog.hide(); get_viewport().gui_release_focus())
		grid.add_child(button)
	add_child(action_dialog)
	action_dialog.popup_centered(Vector2i(720,300))

func _show_pending_xp() -> void:
	if not xp_pendente or not Network.active: return
	xp_pendente=false
	recompensa_xp.xp_atual=int(xp_dados.before)%100
	recompensa_xp.nivel_atual=1+int(xp_dados.before)/100
	recompensa_xp.mostrar(int(xp_dados.amount),{"novo_bonus":false,"dias":Progress.view.get("streak",0),"missoes_concluidas":Progress.view.get("daily_awarded",[]).size(),"total_missoes":3})
