extends Control
signal map_requested
signal travel_requested(destination: String)
var passport: PanelContainer
var visited: Dictionary={}
var wins:=0
var losses:=0
var draws:=0
var nickname:="Urso"
var last_zone:=""
var signature:=""
var widgets: Control
const CREAM:=Color("fff5dc")
const INK:=Color("513d2b")
func _ready() -> void:
	var ui_theme:=Theme.new()
	var blue:=StyleBoxFlat.new()
	blue.bg_color=Color("259dcb")
	blue.border_color=INK
	blue.set_border_width_all(2)
	blue.set_corner_radius_all(10)
	ui_theme.set_stylebox("normal","Button",blue)
	ui_theme.set_stylebox("hover","Button",blue)
	ui_theme.set_color("font_color","Button",Color.WHITE)
	theme=ui_theme
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	widgets=Control.new()
	widgets.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(widgets)
	Network.roster_changed.connect(_update)
	Duel.result_received.connect(_result)
func _box(rect: Rect2,color:=CREAM) -> Panel:
	var panel:=Panel.new()
	panel.position=rect.position
	panel.size=rect.size
	var style:=StyleBoxFlat.new()
	style.bg_color=color
	style.border_color=INK
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	panel.add_theme_stylebox_override("panel",style)
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	widgets.add_child(panel)
	return panel
func _label(text: String,rect: Rect2,font_size:=19) -> void:
	var label:=Label.new()
	label.text=text
	label.position=rect.position
	label.size=rect.size
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color",INK)
	label.add_theme_font_size_override("font_size",font_size)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	widgets.add_child(label)
func _button(text: String,rect: Rect2,action: Callable) -> void:
	var button:=Button.new()
	button.text=text
	button.position=rect.position
	button.size=rect.size
	button.add_theme_color_override("font_color",Color.WHITE)
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("259dcb")
	style.border_color=INK
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	button.add_theme_stylebox_override("normal",style)
	button.add_theme_stylebox_override("hover",style)
	button.pressed.connect(action)
	widgets.add_child(button)
func _result(result: Dictionary) -> void:
	var mine: int=result.ids.find(multiplayer.get_unique_id())
	if result.winner==-1: draws+=1
	elif result.winner==mine: wins+=1
	else: losses+=1
	_update()
func _update() -> void:
	var id:=multiplayer.get_unique_id()
	if not Network.players.has(id): return
	var player: Dictionary=Network.players[id]
	var next_signature: String=str([player.nickname,player.zone,wins,losses,draws])
	if signature==next_signature: return
	signature=next_signature
	if last_zone!=player.zone and is_instance_valid(passport): passport.hide()
	nickname=player.nickname
	visited[player.zone]=true
	last_zone=player.zone
	_redraw_hud()
func _redraw_hud() -> void:
	for child in widgets.get_children():
		widgets.remove_child(child)
		child.queue_free()
	_box(Rect2(24,18,262,90),Color("e5f2ee"))
	_label(nickname,Rect2(100,28,170,32),23)
	_label("Explorador da ilha",Rect2(100,63,170,28),16)
	var portrait:=Sprite2D.new()
	portrait.texture=load("res://assets/sprites/urso/frames/S_idle_1.png")
	portrait.position=Vector2(70,63)
	portrait.scale=Vector2(0.27,0.27)
	widgets.add_child(portrait)
	_button("Sair da sala",Rect2(963,135,142,32),func(): Network.leave())
	_box(Rect2(24,120,262,65))
	_label("Seu próximo destino",Rect2(34,124,242,23),15)
	_button("Abrir passaporte [P]",Rect2(45,150,220,28),toggle_passport)
	_box(Rect2(945,18,178,100),Color("b9d7a1"))
	var preview:=TextureRect.new()
	preview.texture=load({"lobby":"res://assets/cenario/praca/chao.png","math":"res://assets/cenario/bosque/chao_bosque.png","commerce":"res://assets/cenario/comercial/chao_comercial.png"}.get(last_zone,"res://assets/cenario/praca/chao.png"))
	preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	preview.position=Vector2(970,24)
	preview.size=Vector2(126,34)
	preview.mouse_filter=Control.MOUSE_FILTER_IGNORE
	widgets.add_child(preview)
	_button("Viajar [M]",Rect2(963,65,142,37),func(): map_requested.emit())
	_box(Rect2(375,656,402,47),Color("259dcb"))
	_button("Passaporte [P]",Rect2(389,664,180,30),toggle_passport)
	_button("Mapa [M]",Rect2(581,664,180,30),func(): map_requested.emit())
	if is_instance_valid(passport) and passport.visible: _fill_passport()
func toggle_passport() -> void:
	if not is_instance_valid(passport):
		passport=PanelContainer.new()
		passport.position=Vector2(145,65)
		passport.size=Vector2(862,565)
		var style:=StyleBoxFlat.new()
		style.bg_color=CREAM
		style.border_color=INK
		style.set_border_width_all(3)
		style.set_corner_radius_all(24)
		passport.add_theme_stylebox_override("panel",style)
		add_child(passport)
		_fill_passport()
	else:
		passport.visible=not passport.visible
		if passport.visible: _fill_passport()
func _fill_passport() -> void:
	for child in passport.get_children():
		passport.remove_child(child)
		child.queue_free()
	var margin:=MarginContainer.new()
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,24)
	passport.add_child(margin)
	var box:=VBoxContainer.new()
	box.add_theme_constant_override("separation",22)
	margin.add_child(box)
	var title:=Label.new()
	title.text="Meu passaporte • "+nickname
	title.add_theme_font_size_override("font_size",28)
	title.add_theme_color_override("font_color",INK)
	box.add_child(title)
	var stats:=Label.new()
	stats.text="Esta sessão: %d vitórias • %d derrotas • %d empates" % [wins,losses,draws]
	stats.add_theme_color_override("font_color",INK)
	box.add_child(stats)
	var row:=HBoxContainer.new()
	row.add_theme_constant_override("separation",14)
	box.add_child(row)
	for destination in ["math","language","science"]:
		var card_panel:=PanelContainer.new()
		var subject_style:=StyleBoxFlat.new()
		subject_style.bg_color={"math":Color("d8eef7"),"language":Color("f5dccb"),"science":Color("d9ebcf")}[destination]
		subject_style.border_color=INK
		subject_style.set_border_width_all(2)
		subject_style.set_corner_radius_all(16)
		subject_style.content_margin_left=12
		subject_style.content_margin_right=12
		subject_style.content_margin_top=20
		card_panel.add_theme_stylebox_override("panel",subject_style)
		row.add_child(card_panel)
		var card:=VBoxContainer.new()
		card.custom_minimum_size=Vector2(224,290)
		card.add_theme_constant_override("separation",20)
		card_panel.add_child(card)
		var label:=Label.new()
		label.text={"math":"×  Matemática\n\nDojo do Bambu","language":"Aa  Português\n\nPorto Glacial","science":"Ciências\n\nObservatório"}[destination]
		label.add_theme_color_override("font_color",INK)
		label.add_theme_font_size_override("font_size",22)
		card.add_child(label)
		var stamp:=Label.new()
		stamp.text="● Região descoberta" if visited.has(destination) else "○ Ainda não visitada"
		stamp.add_theme_color_override("font_color",INK)
		card.add_child(stamp)
		var button:=Button.new()
		button.text="Explorar →"
		button.custom_minimum_size.y=48
		button.pressed.connect(func(): passport.hide(); travel_requested.emit(destination))
		card.add_child(button)
	var close:=Button.new()
	close.text="Fechar [P]"
	close.pressed.connect(passport.hide)
	box.add_child(close)
