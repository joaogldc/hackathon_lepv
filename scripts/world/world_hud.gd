extends Control
const ISLAND_MAP := preload("res://scripts/world/world_map.gd")
signal daily_requested
signal map_requested
signal travel_requested(destination: String)
signal pet_emotes_requested
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
	DailyJournal.changed.connect(_update)
	get_viewport().size_changed.connect(_layout)
	_layout()
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
func _label(text: String,rect: Rect2,font_size:=19,align:=HORIZONTAL_ALIGNMENT_CENTER,wrap:=false) -> void:
	var bounds:=Control.new()
	bounds.position=rect.position
	bounds.size=rect.size
	bounds.clip_contents=true
	bounds.mouse_filter=Control.MOUSE_FILTER_IGNORE
	widgets.add_child(bounds)
	var label:=Label.new()
	label.text=text
	if wrap:
		var lines:=PackedStringArray([""])
		for word in text.split(" "):
			if lines[-1].length()+word.length()>20: lines.append("")
			lines[-1]+=(" " if not lines[-1].is_empty() else "")+word
		label.text="\n".join(lines)
	label.size=rect.size
	label.horizontal_alignment=align
	label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	label.clip_text=true
	label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_color_override("font_color",INK)
	label.add_theme_font_size_override("font_size",font_size)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	label.size=rect.size
	bounds.add_child(label)
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
func _result(_result_data: Dictionary) -> void:
	_update()
func _update() -> void:
	var id:=multiplayer.get_unique_id()
	if not Network.players.has(id): return
	var player: Dictionary=Network.players[id]
	var p: Dictionary=player.get("progress",{})
	wins=p.get("wins",0)
	losses=p.get("losses",0)
	draws=p.get("draws",0)
	var next_signature: String=str([player.nickname,player.zone,p])
	if signature==next_signature: return
	signature=next_signature
	if last_zone!=player.zone and is_instance_valid(passport): passport.hide()
	nickname=player.nickname
	visited[player.zone]=true
	for region in ["math","language","science"]:
		if p.get("stats",{}).get("visit_"+region,0)>0: visited[region]=true
	last_zone=player.zone
	_redraw_hud()
func _redraw_hud() -> void:
	for child in widgets.get_children(): widgets.remove_child(child); child.queue_free()
	_box(Rect2(22,20,266,90),Color("e5f2ee"))
	_box(Rect2(36,33,63,63),Color("ffd36b"))
	_picture("res://assets/sprites/urso/frames/S_idle_1.png",Rect2(36,31,63,65))
	_label(nickname,Rect2(113,25,161,35),24,HORIZONTAL_ALIGNMENT_LEFT)
	_label("Nível %d · Explorador" % Progress.view.get("level",1),Rect2(113,61,161,23),14,HORIZONTAL_ALIGNMENT_LEFT)
	_box(Rect2(113,85,142,8),Color("bcdcdc"))
	var done := int(Progress.view.get("xp",0))%100
	if done > 0: _box(Rect2(113,85,maxf(8,142.0*done/100),8),Color("259dcb"))
	_box(Rect2(22,138,246,106))
	_icon("quest",Rect2(39,154,36,40))
	_label("Próxima descoberta",Rect2(87,145,170,24),14,HORIZONTAL_ALIGNMENT_LEFT)
	_label(Progress.STORY[mini(int(Progress.view.get("story",0)),11)][0],Rect2(87,169,170,44),16,HORIZONTAL_ALIGNMENT_LEFT,true)
	_link("Abrir passaporte ›",Rect2(87,215,170,23),toggle_passport)
	_box(Rect2(22,248,246,88))
	_icon("quest",Rect2(39,261,36,40))
	_label("Missões diárias",Rect2(87,254,171,25),18,HORIZONTAL_ALIGNMENT_LEFT)
	var count := 0
	for quest in DailyJournal.QUESTS:
		if int(DailyJournal.progress.get(quest.id,0)) >= quest.goal: count += 1
	_label("%d/3 concluídas" % count,Rect2(87,279,171,23),14,HORIZONTAL_ALIGNMENT_LEFT)
	_link("Abrir diário [Q] ›",Rect2(87,303,171,23),func(): daily_requested.emit())
	_box(Rect2(510,24,260,38))
	var places := preload("res://scripts/world/world_catalog.gd").TITLES
	_label(places.get(last_zone,"Mundo dos Ursos"),Rect2(518,27,244,31),16)
	_box(Rect2(1025,24,112,40))
	_icon("coin",Rect2(1034,31,27,27))
	_label(str(DailyJournal.coins),Rect2(1065,27,67,32),20)
	var mini := _box(Rect2(1150,38,116,104),Color("ffd36b"))
	var style := mini.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.set_corner_radius_all(52)
	mini.add_theme_stylebox_override("panel",style)
	var image := _picture("res://assets/ui/mapa/ilha-ursos-3d.png",Rect2(1155,43,106,94))
	image.stretch_mode = TextureRect.STRETCH_SCALE
	var material := ShaderMaterial.new()
	material.shader = load("res://assets/ui/clube/circulo.gdshader")
	image.material = material
	mini_dot = _box(Rect2(1196,84,12,12),Color("259dcb"))
	_button("Mapa (M)",Rect2(1145,148,114,33),func(): map_requested.emit())
	_box(Rect2(175,625,930,80),Color("259dcb"))
	_round_action("smile","Pet [B]",212,func(): pet_emotes_requested.emit())
	var chat := LineEdit.new()
	chat.placeholder_text = "Escreva para seus amigos..."
	chat.position = Vector2(263,645)
	chat.size = Vector2(412,40)
	chat.max_length = 100
	chat.add_theme_stylebox_override("normal",_flat(Color("fffaf0"),12))
	chat.add_theme_color_override("font_color",INK)
	chat.add_theme_color_override("font_placeholder_color",Color("68857c"))
	chat.add_theme_font_size_override("font_size",16)
	chat.text_submitted.connect(func(message: String): _bubble(message); chat.clear(); chat.release_focus())
	widgets.add_child(chat)
	_icon("chat",Rect2(632,652,28,27))
	_round_action("bag","Mochila",732,func(): _social("bag"))
	_round_action("friends","Amigos",830,func(): _social("friends"))
	_round_action("book","Passaporte",928,toggle_passport)
	_round_action("map","Mapa",1026,func(): map_requested.emit())
	if is_instance_valid(passport) and passport.visible: _fill_passport()

var mini_dot: Panel
var social: AcceptDialog
var bubble: Label
var _bubble_left := 0.0
func _layout() -> void:
	if is_instance_valid(widgets): widgets.scale = get_viewport_rect().size/Vector2(1280,720)

func _flat(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = INK
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	return style

func _picture(path: String, rect: Rect2) -> TextureRect:
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = load(path)
	image.position = rect.position
	image.size = rect.size
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	widgets.add_child(image)
	return image

func _icon(id: String, rect: Rect2) -> void:
	_picture("res://assets/ui/clube/icone-%s.svg" % id,rect)

func _link(caption: String, rect: Rect2, action: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.position = rect.position
	button.size = rect.size
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size",14)
	button.add_theme_color_override("font_color",Color("087fba"))
	button.pressed.connect(action)
	widgets.add_child(button)

func _round_action(icon: String, caption: String, x: float, action: Callable) -> void:
	var button := Button.new()
	button.position = Vector2(x-24,632)
	button.size = Vector2(48,48)
	button.tooltip_text = caption
	button.add_theme_stylebox_override("normal",_flat(Color("c6e5e8"),24))
	button.add_theme_stylebox_override("hover",_flat(Color("ffd36b"),24))
	button.pressed.connect(action)
	widgets.add_child(button)
	_icon(icon,Rect2(x-18,638,36,36))
	var label := Label.new()
	label.text = caption
	label.position = Vector2(x-45,681)
	label.size = Vector2(90,20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",14)
	label.add_theme_color_override("font_color",Color.WHITE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	widgets.add_child(label)

func _social(kind: String) -> void:
	if not is_instance_valid(social):
		social = AcceptDialog.new()
		add_child(social)
	if kind == "bag":
		social.title = "Mochila"
		var names: Array[String] = []
		for id in DailyJournal.owned: names.append(DailyJournal.item(id).get("name",id))
		social.dialog_text = "Sua coleção está vazia. Visite o balcão de uma loja!" if names.is_empty() else "Sua coleção:\n"+"\n".join(names)
	elif kind == "friends":
		social.title = "Amigos na sala"
		var names: Array[String] = []
		for player in Network.players.values(): names.append(player.nickname)
		social.dialog_text = "\n".join(names)
	else:
		_bubble("Olá! ☺")
		return
	social.popup_centered(Vector2i(450,260))

func _bubble(message: String) -> void:
	if message.strip_edges().is_empty(): return
	if is_instance_valid(bubble): bubble.queue_free()
	bubble = Label.new()
	bubble.text = message.strip_edges().left(100)
	bubble.add_theme_stylebox_override("normal",_flat(CREAM,15))
	bubble.add_theme_color_override("font_color",INK)
	bubble.add_theme_font_size_override("font_size",17)
	bubble.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble.size = Vector2(220,60)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bubble)
	_bubble_left = 4.0

func _process(delta: float) -> void:
	var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(),{})
	if profile.is_empty(): return
	if is_instance_valid(mini_dot):
		mini_dot.position = Vector2(1155,43) + ISLAND_MAP.centro_regiao(profile.zone) * Vector2(106,94) - Vector2(6,6)
	if is_instance_valid(bubble):
		_bubble_left -= delta
		bubble.position = profile.position-Vector2(110,150)
		if _bubble_left <= 0: bubble.queue_free()

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
	box.add_theme_constant_override("separation",12)
	margin.add_child(box)
	var title:=Label.new()
	title.text="Meu passaporte • "+nickname
	title.add_theme_font_size_override("font_size",28)
	title.add_theme_color_override("font_color",INK)
	box.add_child(title)
	var stats:=Label.new()
	stats.text="%d vitórias • %d derrotas • %d empates • Sequência: %d dias" % [wins,losses,draws,Progress.view.get("streak",0)]
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
	var seal_row:=HBoxContainer.new()
	box.add_child(seal_row)
	var seal:=TextureRect.new()
	seal.texture=load("res://assets/ui/lojas/selo-primeira-vitoria.svg")
	seal.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	seal.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	seal.custom_minimum_size=Vector2(56,56)
	seal.modulate=Color.WHITE if "first_daily_win" in DailyJournal.badges else Color(0.5,0.5,0.5,0.5)
	seal_row.add_child(seal)
	var seal_text:=Label.new()
	seal_text.text="Primeira vitória • conquistado!" if "first_daily_win" in DailyJournal.badges else "Primeira vitória • vença um duelo para conquistar"
	seal_text.add_theme_color_override("font_color",INK)
	seal_row.add_child(seal_text)
	var close:=Button.new()
	close.text="Fechar [P]"
	close.pressed.connect(passport.hide)
	box.add_child(close)
