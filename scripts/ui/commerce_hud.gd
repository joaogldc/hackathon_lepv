extends Control
signal story_requested
## Catálogo, provador e diário. Estado local de UI em DailyJournal.
const PREVIEW := preload("res://scripts/ui/bear_fitting_preview.gd")
const INK := Color("513d2b")
const CREAM := Color("fff5dc")
const BLUE := Color("259dcb")
const GREEN := Color("cfe3bc")
const GOLD := Color("f4c768")
const PRODUCT_PATH := "res://assets/cenario/comercial/produtos_exemplo/"
var canvas: Control
var page := ""
var selected := "camisa_azul"
var catalog_page := 0
var pending := ""
var notice := ""
var timer_label: Label
var toast: Label
var _clock := 0.0
var _profile_state := ""

func _ready() -> void:
	if not DailyJournal.equipped.is_empty(): selected = DailyJournal.equipped
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas = Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	get_viewport().size_changed.connect(_resize)
	DailyJournal.changed.connect(func(): _refresh.call_deferred())
	DailyJournal.badge_unlocked.connect(_badge_toast)
	Network.roster_changed.connect(_presence)
	_resize()
	_refresh()

func _resize() -> void:
	var viewport := get_viewport_rect().size
	var factor := minf(viewport.x / 1152, viewport.y / 720)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (viewport - Vector2(1152,720) * factor) / 2

func _presence() -> void:
	var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(), {})
	var state := str(profile.get("zone", "offline"))
	if state == _profile_state: return
	_profile_state = state
	visible = not profile.is_empty()
	if not visible or profile.get("zone", "") not in Minigames.WORLD_ZONES:
		close_window()
	_refresh.call_deferred()

func is_open() -> bool:
	return not page.is_empty()

func open_page(destination: String) -> void:
	if destination not in ["daily","pet","cosmetics","fitting"]: return
	var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(), {})
	if destination != "daily":
		if profile.is_empty() or Minigames.shop_action(profile.zone,profile.position) != destination: return
	catalog_page = 0
	page = destination
	pending = ""
	notice = ""
	if destination in ["pet", "cosmetics"]:
		DailyJournal.visit(destination)
		selected = "fish" if destination == "pet" else "camisa_azul"
	if destination == "fitting":
		if DailyJournal.item(selected).get("shop", "") != "cosmetics": selected = "camisa_azul"
		DailyJournal.try_item(selected)
	_refresh()

func close_window() -> void:
	page = ""
	pending = ""
	_refresh()
	get_viewport().gui_release_focus()

func handle_key(event: InputEvent) -> bool:
	if not event is InputEventKey or not event.pressed or event.echo: return false
	var key: int=event.keycode if event.keycode else event.physical_keycode
	if key == KEY_ESCAPE and is_open():
		if not pending.is_empty(): pending = ""; _refresh()
		else: close_window()
		return true
	if key == KEY_Q:
		var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(), {})
		if not profile.is_empty() and profile.get("zone", "") not in Minigames.WORLD_ZONES: return false
		if page == "daily": close_window()
		else: open_page("daily")
		return true
	if key == KEY_E and not is_open():
		var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(), {})
		if not profile.is_empty():
			var action: String = Minigames.shop_action(profile.zone,profile.position)
			if not action.is_empty(): open_page(action); return true
	return false

func _style(color: Color, border := INK, radius := 18) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(radius)
	return s

func _box(rect: Rect2, color: Color, border := INK, parent: Node = null) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", _style(color,border))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	(parent if parent != null else canvas).add_child(panel)
	return panel

func _text(value: String, rect: Rect2, font_size := 20, color := INK, center := false, parent: Node = null) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color",color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if center: label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent != null else canvas).add_child(label)
	return label

func _button(value: String, rect: Rect2, action: Callable, color := BLUE, disabled := false, parent: Node = null) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size",18)
	button.add_theme_color_override("font_color", INK if color != BLUE else Color.WHITE)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_disabled_color", Color("746858"))
	button.add_theme_stylebox_override("normal",_style(color))
	button.add_theme_stylebox_override("hover",_style(GOLD))
	button.add_theme_stylebox_override("pressed",_style(GREEN))
	button.add_theme_stylebox_override("focus",_style(Color(0,0,0,0),Color("da9f39")))
	button.add_theme_stylebox_override("disabled",_style(Color("e4dfcf"),Color("b9ad98")))
	button.disabled = disabled
	button.pressed.connect(action)
	(parent if parent != null else canvas).add_child(button)
	return button

func _image(path: String, rect: Rect2, parent: Node = null) -> TextureRect:
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = load(path)
	image.position = rect.position
	image.size = rect.size
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent != null else canvas).add_child(image)
	return image

func _art(product: Dictionary) -> String:
	if product.id in ["fish","parrot"]: return "res://assets/pets/"+("flying_fish" if product.id=="fish" else "parrot")+"/front.png"
	if product.has("garment"): return "res://assets/sprites/urso/roupas/icones/"+product.art+".png"
	return "res://assets/ui/lojas/camiseta.svg" if product.art == "camiseta" else PRODUCT_PATH + product.art + ".png"

func _refresh() -> void:
	if not is_instance_valid(canvas): return
	for child in canvas.get_children():
		canvas.remove_child(child)
		child.queue_free()
	timer_label = null
	_last_action = ""
	var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(), {})
	if page.is_empty(): return
	var shade := ColorRect.new()
	shade.color = Color(0.07,0.16,0.17,0.76)
	shade.size = Vector2(1152,720)
	canvas.add_child(shade)
	_box(Rect2(70,72,1012,576),CREAM)
	_box(Rect2(70,72,1012,94),Color("dfecd7"))
	_image("res://assets/sprites/urso/frames/S_idle_1.png",Rect2(87,80,76,76))
	var titles := {"shops":"Vila das lojas", "pet":"Loja de pets", "cosmetics":"Loja de cosméticos", "fitting":"Seu momento no provador", "daily":"Missões diárias"}
	_text(titles.get(page,"Vila das lojas"),Rect2(178,85,570,40),30)
	_text("Um mundo de descobertas, do seu jeito.",Rect2(180,126,600,25),16)
	_button("Fechar ×",Rect2(935,94,126,45),close_window,CREAM)
	_text("SUA CARTEIRA",Rect2(95,490,160,25),14)
	_image("res://assets/ui/recompensas/moeda.svg",Rect2(99,523,34,34))
	_text(str(DailyJournal.coins),Rect2(141,520,108,40),28)
	_text("Esc para fechar",Rect2(96,595,170,24),14)
	if page == "daily":
		_image("res://assets/ui/lojas/selo-primeira-vitoria.svg",Rect2(110,207,125,140))
		_text("Seu diário",Rect2(91,353,170,36),22,INK,true)
	else:
		var art: String = "res://assets/cenario/comercial/loja_pets.png" if page == "pet" else "res://assets/cenario/comercial/loja_cosmeticos.png"
		_image(art,Rect2(94,217,164,125))
		_text("Escolha seu pet" if page == "pet" else ("Experimente à vontade" if page == "fitting" else "Coleção da ilha"),Rect2(89,355,176,75),20,INK,true)
	match page:
		"pet", "cosmetics": _catalog()
		"fitting": _fitting()
		"daily": _daily()
	if not notice.is_empty(): _text(notice,Rect2(295,594,750,35),16)
	if not pending.is_empty(): _confirmation()

func _widget() -> void:
	pass

func _directory() -> void:
	pass

func _catalog() -> void:
	_text("Escolha seu novo companheiro" if page == "pet" else "Escolha uma peça da coleção",Rect2(298,184,730,34),24)
	var products: Array = DailyJournal.ITEMS.filter(func(p): return p.shop == page)
	products = _paginate(products)
	for i in range(products.size()):
		var product: Dictionary = products[i]
		var x := 296 + i*250
		_box(Rect2(x,232,234,242),Color("f9e5b5") if selected == product.id else Color("fffaf0"),Color("bf8736") if selected == product.id else Color("c7b796"))
		_image(_art(product),Rect2(x+40,246,154,111))
		_text(product.name,Rect2(x+8,360,218,46),20,INK,true)
		var caption: String = "Na coleção ✓" if product.id in DailyJournal.owned else str(product.price)+" moedas"
		_button(caption,Rect2(x+14,418,206,40),func(): selected = product.id; notice = ""; _refresh(),GREEN if product.id in DailyJournal.owned else GOLD)
	var choice := DailyJournal.item(selected)
	if choice.get("shop", "") != page: return
	_text(choice.desc,Rect2(300,483,732,49),18)
	_button("Equipar" if selected in DailyJournal.owned else ("Comprar pet • %d moedas" if page == "pet" else "Comprar • %d moedas") % choice.price,Rect2(300,540,332,44),func():
		if selected in DailyJournal.owned: DailyJournal.equip(selected); notice="Escolha equipada!"
		else: pending = selected
		_refresh(),BLUE)
	if page == "cosmetics":
		_text("Para experimentar, visite o provador da loja.",Rect2(647,536,385,50),17)

func _fitting() -> void:
	_box(Rect2(297,190,326,392),Color("d9edf0"))
	_box(Rect2(315,209,290,331),Color("f1f8ed"),Color("99b6af"))
	var preview := PREVIEW.new()
	preview.item_id = selected
	preview.position = Vector2(329,226)
	preview.size = Vector2(262,280)
	canvas.add_child(preview)
	_button("Retirar roupa",Rect2(315,543,290,32),func(): Network.interact("outfit","none"),CREAM)
	_text("Escolha uma peça",Rect2(647,193,392,35),25)
	var products: Array = DailyJournal.ITEMS.filter(func(p): return p.shop == "cosmetics")
	products = _paginate(products)
	for i in range(products.size()):
		var product: Dictionary = products[i]
		var y := 246 + i*85
		_image(_art(product),Rect2(649,y,67,63))
		_button(product.name + (" ✓" if selected == product.id else ""),Rect2(731,y+5,306,53),func(): selected = product.id; DailyJournal.try_item(selected); _refresh(),GOLD if selected == product.id else CREAM)
	var choice := DailyJournal.item(selected)
	if choice.is_empty(): return
	var owned: bool = selected in DailyJournal.owned
	var caption := "Guardar combinação" if owned else "Experimente antes de comprar"
	_button(caption,Rect2(647,513,390,48),func():
		if owned:
			DailyJournal.equip(selected)
			notice = "Combinação salva no provador!"
		else: notice = "Gostou? A compra é feita no balcão de cosméticos."
		_refresh())
	_text("Visual salvo: "+DailyJournal.item(DailyJournal.equipped).get("name","nenhum"),Rect2(647,565,390,27),16)

func _daily() -> void:
	_text("Um pouquinho de aventura todo dia",Rect2(299,182,747,37),24)
	timer_label = _text("",Rect2(300,220,742,26),16)
	_update_timer()
	_button("Mapa da história",Rect2(806,215,235,35),func(): story_requested.emit(),CREAM)
	for i in range(DailyJournal.QUESTS.size()):
		var quest: Dictionary = DailyJournal.QUESTS[i]
		var y := 265 + i*103
		var count := mini(int(DailyJournal.progress.get(quest.id,0)),quest.goal)
		var claimed: bool = quest.id in DailyJournal.claimed
		var ready: bool = count >= quest.goal
		_box(Rect2(297,y,490,94),GREEN if ready else Color("fffaf0"),Color("b9ad98"))
		_text(quest.title,Rect2(312,y+4,456,30),20)
		_text(quest.desc,Rect2(312,y+33,456,27),15)
		var track := ProgressBar.new()
		track.show_percentage = false
		track.position = Vector2(312,y+70)
		track.size = Vector2(158,10)
		track.max_value = quest.goal
		track.value = count
		track.add_theme_stylebox_override("background",_style(Color("e0d7c5"),Color("e0d7c5"),5))
		track.add_theme_stylebox_override("fill",_style(Color("689b60"),Color("689b60"),5))
		canvas.add_child(track)
		_text("%d/%d" % [count,quest.goal],Rect2(478,y+58,55,30),15)
		var id: String = quest.id
		_button("XP recebido ✓" if claimed else "+%d XP" % quest.reward,Rect2(552,y+56,220,32),func(): pass,GOLD,true)
	_box(Rect2(806,265,235,300),Color("f8e7be"))
	var unlocked: bool = "first_daily_win" in DailyJournal.badges
	var badge := _image("res://assets/ui/lojas/selo-primeira-vitoria.svg",Rect2(841,285,165,150))
	if not unlocked: badge.modulate = Color(0.68,0.68,0.68,0.65)
	_text("Primeira vitória",Rect2(816,433,215,59),23,INK,true)
	_text("Selo conquistado!" if unlocked else "Vença seu primeiro duelo\npara desbloquear.",Rect2(819,502,209,48),16,INK,true)
	_text("Sequência: %d dias • Todas as diárias: +50 XP • Renovação à meia-noite UTC" % Progress.view.get("streak",0),Rect2(300,578,743,31),16)

func _confirmation() -> void:
	var choice := DailyJournal.item(pending)
	if choice.is_empty(): pending = ""; return
	var shade := ColorRect.new()
	shade.size = Vector2(1152,720)
	shade.color = Color(0.08,0.12,0.12,0.73)
	canvas.add_child(shade)
	_box(Rect2(326,187,500,326),CREAM)
	_text("Levar para sua coleção?",Rect2(346,202,460,42),26,INK,true)
	_image(_art(choice),Rect2(501,255,150,97))
	_text(choice.name,Rect2(345,357,462,31),23,INK,true)
	_text("%d moedas  •  Saldo após a compra: %d" % [choice.price,DailyJournal.coins-choice.price],Rect2(343,394,466,27),17,INK,true)
	_button("Voltar",Rect2(346,447,210,44),func(): pending = ""; _refresh(),CREAM)
	_button("Confirmar compra",Rect2(571,447,235,44),_purchase,BLUE,DailyJournal.coins < choice.price)
	if DailyJournal.coins < choice.price:
		_text("Saldo insuficiente. Complete missões para juntar moedas.",Rect2(334,520,484,45),17,Color.WHITE,true)

func _purchase() -> void:
	var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(),{})
	if profile.is_empty() or Minigames.shop_action(profile.zone,profile.position) != page:
		close_window()
		return
	var error := DailyJournal.buy(pending)
	notice = "Pedido enviado ao balcão. Saldo e coleção são confirmados pelo servidor." if error.is_empty() else error
	pending = ""
	_refresh()

func _badge_toast() -> void:
	# A tela da vitória tem prioridade. A notificação fica disponível no diário.
	notice = "Novo selo: Primeira vitória diária!"
	_refresh.call_deferred()

func _process(delta: float) -> void:
	if page in ["pet","cosmetics","fitting"]:
		var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(),{})
		if profile.is_empty() or Minigames.shop_action(profile.zone,profile.position) != page: close_window()
	_context()
	_clock += delta
	if _clock >= 1.0:
		_clock = 0.0
		_update_timer()

func _update_timer() -> void:
	if not is_instance_valid(timer_label): return
	var left := DailyJournal.remaining()
	timer_label.text = "Renovam em %02d:%02d:%02d • Horário UTC do servidor" % [left/3600,(left%3600)/60,left%60]

var _last_action := ""
var context_button: Button
func _context() -> void:
	var profile: Dictionary = Network.players.get(multiplayer.get_unique_id(), {})
	var action: String = Minigames.shop_action(profile.get("zone",""),profile.get("position",Vector2.ZERO))
	if is_open() or not visible: action = ""
	if action == _last_action: return
	_last_action = action
	if is_instance_valid(context_button): context_button.queue_free()
	if not action.is_empty():
		var captions := {"pet":"Comprar pet [E]", "cosmetics":"Comprar cosméticos [E]", "fitting":"Experimentar roupas [E]"}
		context_button = _button(captions[action],Rect2(405,130,342,40),func(): open_page(action),GOLD)

func _paginate(products: Array) -> Array:
	var pages := maxi(1,ceili(products.size()/3.0))
	catalog_page = clampi(catalog_page,0,pages-1)
	if pages > 1:
		_button("‹",Rect2(866,183,43,38),func(): catalog_page = posmod(catalog_page-1,pages); _refresh(),CREAM)
		_text("%d/%d" % [catalog_page+1,pages],Rect2(915,186,61,33),17,INK,true)
		_button("›",Rect2(987,183,43,38),func(): catalog_page = (catalog_page+1)%pages; _refresh(),CREAM)
	return products.slice(catalog_page*3,mini(products.size(),catalog_page*3+3))
