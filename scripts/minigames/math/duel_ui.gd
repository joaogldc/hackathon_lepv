extends Control
signal finished(result: Dictionary)
var inside := true
var overlay: Control
var fighters: Array[AnimatedSprite2D] = []
var timer_label: Label
var remaining := 0.0
var selected_card := -1
var selected_slot := -1
var selected_answer := -1
var selection_revision := -1
const PET := preload("res://scripts/player/pet_companion.gd")
const FONTS := preload("res://scripts/ui/game_fonts.gd")
const PET_BACK := preload("res://assets/pets/flying_fish/back_1.png")
const PARROT_BACK := preload("res://assets/pets/parrot/back_1.png")
var fighter_pets: Array[Node2D]=[]
var fighter_cosmetics: Array[Node2D]=[]
const COSMETICS := preload("res://scripts/player/cosmetics.gd")
const CARD := preload("res://scripts/minigames/math/card_button.gd")
const ROOM := preload("res://assets/cenario/dojo_sala/fundo_dojo_sala.png")
const DESK := preload("res://assets/cenario/dojo_sala/mesa_baixa.png")
const SITTING := preload("res://assets/sprites/urso/frames/N_sit.png")
const SEATS := [Vector2(252,476),Vector2(900,476),Vector2(211,580),Vector2(940,580),Vector2(169,684),Vector2(983,684),Vector2(450,476),Vector2(702,476)]
## Espectador sentado entre a câmera e a mesa (atrás da mesa, olhando o quadro).
const SPECTATOR_OFFSET := Vector2(0,34)
const INK := Color("513d2b")
const CREAM := Color("fff5dc")
const PLAYER_PANEL := preload("res://assets/ui/cartas/painel-jogador.svg")
const TURN_PANEL := preload("res://assets/ui/cartas/painel-turno.svg")

func _ready() -> void:
	get_viewport().size_changed.connect(_fit)
	_fit()
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	for side in range(2):
		var bear:=AnimatedSprite2D.new()
		var frames:=SpriteFrames.new()
		frames.add_animation("idle")
		frames.set_animation_speed("idle",2)
		for index in range(1,3): frames.add_frame("idle",load("res://assets/sprites/urso/frames/E_idle_%d.png" % index))
		bear.sprite_frames=frames
		bear.play("idle")
		bear.flip_h=side==1
		bear.position=Vector2(265 if side==0 else 887,300)
		bear.scale=Vector2(0.42,0.42)
		add_child(bear)
		bear.z_index=10
		fighters.append(bear)
		var pet:=PET.new()
		pet.attached_to_bear=false
		pet.position=bear.position+Vector2(0,12)
		pet.configure("right" if side==0 else "left",false)
		add_child(pet)
		fighter_pets.append(pet)
		var accessory: Node2D=load("res://scripts/player/cosmetic_display.gd").new()
		accessory.position=bear.position+Vector2(0,53.76)
		accessory.scale=Vector2.ONE*1.6
		accessory.source=bear
		accessory.direction="right" if side==0 else "left"
		accessory.z_index=12
		add_child(accessory)
		fighter_cosmetics.append(accessory)
	overlay=Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index=20
	overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	Duel.changed.connect(_refresh)
	_refresh()

func _style(color: Color, border := INK) -> StyleBoxFlat:
	var box:=StyleBoxFlat.new()
	box.bg_color=color
	box.border_color=border
	box.set_border_width_all(2)
	box.set_corner_radius_all(16)
	box.shadow_color=Color(0.15,0.1,0.06,0.25)
	box.shadow_offset=Vector2(0,4)
	box.shadow_size=2
	return box

func _panel(rect: Rect2) -> void:
	var panel:=Panel.new()
	panel.position=rect.position
	panel.size=rect.size
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel",_style(CREAM))
	overlay.add_child(panel)

func _hud_panel(rect: Rect2, texture: Texture2D) -> void:
	var panel := NinePatchRect.new()
	panel.texture = texture
	panel.position = rect.position
	panel.size = rect.size
	panel.patch_margin_left = 20
	panel.patch_margin_right = 20
	panel.patch_margin_top = 20
	panel.patch_margin_bottom = 20
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(panel)

func _label(text: String, rect: Rect2, font_size := 22, color := INK) -> Label:
	var label:=Label.new()
	label.text=text
	label.position=rect.position
	label.size=rect.size
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	overlay.add_child(label)
	return label

func _button(text: String, rect: Rect2, action: Callable, enabled := true, light := false) -> Button:
	var button:=Button.new()
	button.text=text
	button.position=rect.position
	button.size=rect.size
	button.disabled=not enabled
	button.add_theme_font_size_override("font_size",18)
	button.add_theme_color_override("font_color",INK if light else Color.WHITE)
	button.add_theme_stylebox_override("normal",_style(CREAM if light else Color("259dcb")))
	button.add_theme_stylebox_override("hover",_style(Color("e7d6a4") if light else Color("3db3df"),Color("e4b347")))
	button.add_theme_stylebox_override("disabled",_style(Color("d5d1bf")))
	button.pressed.connect(action)
	overlay.add_child(button)
	return button

func _refresh() -> void:
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	timer_label=null
	var v: Dictionary=Duel.view
	var phase: String=v.get("phase","idle")
	var spectator: bool=v.get("spectator",false)
	var mine: int=v.get("ids",[]).find(multiplayer.get_unique_id())
	var revision: int=v.get("revision",-1)
	var audience_ids: Array = []
	for person in v.get("spectators",[]):
		audience_ids.append(person.id)
	if revision!=selection_revision:
		selected_card=-1
		selected_slot=-1
		selected_answer=-1
		selection_revision=revision
	for side in range(2):
		var x:=26 if side==0 else 866
		_hud_panel(Rect2(x,24,260,74),PLAYER_PANEL)
		var fighter_ids: Array = v.get("ids",[])
		var occupied: bool = fighter_ids.size()>side and not audience_ids.has(fighter_ids[side])
		var name_text: String=v.names[side] if occupied else "Aguardando jogador"
		_label(name_text+(" • você" if occupied and side==mine else ""),Rect2(x+10,30,240,30),19)
		var energy: int=v.energy[side] if occupied and v.has("energy") else 0
		var bar:=ColorRect.new()
		bar.position=Vector2(x+16,74)
		bar.size=Vector2(180,9)
		bar.color=Color("ddd5b6")
		bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
		overlay.add_child(bar)
		var fill:=ColorRect.new()
		fill.position=bar.position
		fill.size=Vector2(180.0*energy/5.0,9)
		fill.color=Color("6cae4b")
		fill.mouse_filter=Control.MOUSE_FILTER_IGNORE
		overlay.add_child(fill)
		_label("%d/5" % energy if occupied else "—",Rect2(x+198,62,50,28),16)
		fighters[side].visible=occupied
		fighter_pets[side].visible=occupied
		fighter_pets[side].configure("right" if side==0 else "left",false,v.get("pets",["fish","fish"])[side],"",v.get("pet_accs",["none","none"])[side])
		fighter_cosmetics[side].visible=occupied
		fighter_cosmetics[side].outfit=v.get("outfits",["none","none"])[side]
		fighter_cosmetics[side].outfits=v.get("outfit_slots",[{},{}])[side]
		fighter_cosmetics[side].queue_redraw()
	_hud_panel(Rect2(430,24,292,74),TURN_PANEL)
	var heading: String={"idle":"Dojo do Bambu","waiting":"Procurando rival","watch_wait":"Plateia","resolve":"Resultado","finished":"Fim do duelo"}.get(phase,"Sua defesa" if mine!=v.get("attacker",-1) else "Seu ataque")
	if spectator and v.has("ids"): heading="Assistindo ao duelo"
	_label(heading,Rect2(440,30,272,30),21)
	remaining=v.get("seconds",0.0)
	_label("Matemática • Turno %d/10" % v.turn if v.has("turn") else "Multiplicação",Rect2(440,64,195,25),14)
	timer_label=_label("%ds" % ceili(remaining) if remaining>0 else "",Rect2(638,62,74,28),16)
	_button("‹ Sair",Rect2(26,118,92,32),_return,true,true)
	if phase in ["idle","waiting","watch_wait"]:
		_panel(Rect2(396,200,360,236))
		_label("Duelo de multiplicação" if phase=="idle" else ("Você está na plateia" if phase=="watch_wait" else "Aguardando outro urso…"),Rect2(410,210,332,54),23)
		_label("Aguardando dois jogadores\npara começar o duelo." if phase=="watch_wait" else "Ataque com uma carta.\nAcerte a resposta para se defender.",Rect2(416,270,320,60),18)
		if phase=="watch_wait":
			_button("Levantar",Rect2(436,369,280,36),func(): Duel.act("leave"))
		else:
			_button("Procurar adversário" if phase=="idle" else "Cancelar",Rect2(436,339,280,36),func(): Duel.act("join" if phase=="idle" else "leave"))
			_button("Assistir sentado",Rect2(436,385,280,36),func(): Duel.act("watch"))
	elif phase=="answer":
		_panel(Rect2(376,203,400,300))
		_label("Defenda seu urso" if mine!=v.attacker and not spectator else "O defensor está respondendo",Rect2(391,215,370,34),19,Color("1478a2"))
		_label(v.question,Rect2(390,256,372,65),38)
		for index in range(v.options.size()):
			var button:=_button(str(v.options[index]),Rect2(396+(index%2)*184,338+(index/2)*65,176,52),func(): selected_answer=index; _refresh(),not spectator and mine!=v.attacker,true)
			if index==selected_answer: button.add_theme_stylebox_override("normal",_style(Color("d1edfa"),Color("259dcb")))
		_button("Confirmar",Rect2(456,520,240,44),func(): Duel.act("answer",selected_answer),selected_answer>=0 and not spectator and mine!=v.attacker)
	elif phase in ["resolve","finished"]:
		_panel(Rect2(376,220,400,258))
		var title: String=v.feedback
		if phase=="finished" and not spectator: title=("Empate!" if v.winner==-1 else ("Vitória!" if v.winner==mine else "Derrota"))+"\n"+v.feedback
		_label(title,Rect2(397,238,358,158),24)
		if phase=="finished": _button("Jogar novamente" if not spectator else "Entrar na fila",Rect2(446,412,260,44),func(): Duel.act("join"))
	if not spectator and phase in ["idle","waiting","choose"]:
		_fan(v.cards[mine] if v.has("cards") else [2,2,1],phase=="choose" and mine==v.attacker)
		if phase=="choose": _button("Jogar carta",Rect2(924,622,202,48),func(): Duel.act("card",selected_card),selected_card>=0 and mine==v.attacker)
	if spectator and v.has("ids"):
		_button("Levantar",Rect2(456,638,240,40),func(): Duel.act("leave"))
	queue_redraw()

func _fan(counts: Array, playable: bool) -> void:
	var levels: Array[int]=[]
	for level in range(3):
		for index in range(counts[level]): levels.append(level)
	for index in range(levels.size()):
		var level: int=levels[index]
		var offset:=float(index)-float(levels.size()-1)/2.0
		var card:=CARD.new()
		card.difficulty=level
		card.selected=selected_slot==index
		card.disabled=not playable
		card.position=Vector2(520+offset*124-64,520+absf(offset)*6-(18 if card.selected else 0))
		card.size=Vector2(128,154)
		card.pivot_offset=Vector2(64,154)
		card.rotation=deg_to_rad(offset*3.5)
		card.name="Card%d" % index
		card.pressed.connect(func(): selected_card=level; selected_slot=index; _refresh())
		overlay.add_child(card)

func _draw() -> void:
	draw_texture_rect(ROOM,Rect2(0,0,1152,720),false)
	var audience: Array=Duel.view.get("spectators",[])
	for seat in range(8):
		var desk_point: Vector2=SEATS[seat]
		# A mesa vem primeiro: o espectador senta atrás dela, de costas para a câmera,
		# olhando para o quadro, e fica desenhado por cima da borda da mesa.
		draw_texture_rect(DESK,Rect2(desk_point-Vector2(72,26),Vector2(144,66)),false)
		var point: Vector2=desk_point+SPECTATOR_OFFSET
		for person in audience:
			if person.seat==seat:
				draw_texture_rect(PARROT_BACK if person.get("pet","fish")=="parrot" else PET_BACK,Rect2(point+Vector2(24,-78),Vector2(28,28)),false)
				draw_texture_rect(SITTING,Rect2(point-Vector2(40,80),Vector2(80,80)),false)
				var worn: Dictionary=person.get("outfit_slots",{})
				for equipped in ([person.get("outfit","none")] if worn.is_empty() else [worn.get("body","none"),worn.get("neck","none"),worn.get("head","none")]):
					COSMETICS.paint(self,equipped,"back",point,80.0/67.2,0.0,false,true)
				var label_y:=-108 if person.get("outfit","")=="cartola" else (-92 if person.get("outfit","")=="laco_rosa" else -84)
				FONTS.nameplate(self,person.name,point.x,point.y+label_y,15)

func _process(delta: float) -> void:
	remaining=maxf(0,remaining-delta)
	if is_instance_valid(timer_label): timer_label.text="%ds" % ceili(remaining) if remaining>0 else ""
func _return() -> void:
	Duel.act("leave")
	finished.emit({"game":"math","completed":false})
func _exit_dojo() -> void: _return()
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_return()
func _fit() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size=Vector2(1152,720)
	var viewport_size:=get_viewport_rect().size
	var factor:=minf(viewport_size.x/1152.0,viewport_size.y/720.0)
	scale=Vector2.ONE*factor
	position=(viewport_size-size*factor)/2.0

func _bar_style(color: Color) -> StyleBoxFlat:
	var box:=StyleBoxFlat.new()
	box.bg_color=color
	box.set_corner_radius_all(4)
	return box
