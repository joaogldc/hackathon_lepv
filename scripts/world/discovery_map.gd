extends Control
signal close_requested
signal travel_requested(destination: String)
const ART := preload("res://assets/ui/quests/mapa-de-descobertas.png")
const POSITIONS := [Vector2(130,800),Vector2(220,700),Vector2(315,615),Vector2(470,620),Vector2(595,690),Vector2(785,755),Vector2(945,735),Vector2(1095,645),Vector2(1190,540),Vector2(1320,440),Vector2(1450,340),Vector2(1540,270)]
var daily:=false
var selected:=-1
var content: Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter=Control.MOUSE_FILTER_STOP
	content=Control.new()
	add_child(content)
	Progress.changed.connect(_refresh)
	_refresh()

func _style(color: Color) -> StyleBoxFlat:
	var style:=StyleBoxFlat.new()
	style.bg_color=color
	style.border_color=Color("624129")
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	return style

func _box(rect: Rect2,color:=Color("fff1d3")) -> void:
	var panel:=Panel.new()
	panel.position=rect.position
	panel.size=rect.size
	panel.add_theme_stylebox_override("panel",_style(color))
	content.add_child(panel)

func _text(text: String,rect: Rect2,font_size:=21) -> void:
	var label:=Label.new()
	label.text=text
	label.position=rect.position
	label.size=rect.size
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color",Color("513d2b"))
	label.add_theme_font_size_override("font_size",font_size)
	content.add_child(label)

func _button(caption: String,rect: Rect2,action: Callable,enabled:=true,color:=Color("299bd1")) -> void:
	var button:=Button.new()
	button.text=caption
	button.position=rect.position
	button.size=rect.size
	button.disabled=not enabled
	button.add_theme_font_size_override("font_size",20)
	var normal:=_style(color)
	var locked:=_style(Color("96958e"))
	if rect.size==Vector2(68,68):
		normal.set_corner_radius_all(34)
		locked.set_corner_radius_all(34)
		button.add_theme_font_size_override("font_size",25)
		button.add_theme_color_override("font_disabled_color",Color("fff8e9"))
	button.add_theme_stylebox_override("normal",normal)
	button.add_theme_stylebox_override("disabled",locked)
	button.pressed.connect(action)
	content.add_child(button)

func _refresh() -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	var p: Dictionary=Progress.view
	var shade:=ColorRect.new()
	shade.size=Vector2(1152,720)
	shade.color=Color(0.03,0.07,0.08,0.93)
	content.add_child(shade)
	_button("História",Rect2(48,20,180,45),func(): daily=false; _refresh())
	_button("Missões diárias",Rect2(240,20,230,45),func(): daily=true; _refresh())
	_button("Fechar [Q / Esc]",Rect2(880,20,224,45),func(): close_requested.emit())
	if daily:
		_box(Rect2(80,95,992,560))
		_text("Complete as três diárias para manter sua sequência",Rect2(100,110,952,55),26)
		_text("Sequência: %d dias  •  Recorde: %d  •  Nível %d  •  %d XP" % [p.get("streak",0),p.get("best_streak",0),p.get("level",1),p.get("xp",0)],Rect2(100,170,952,45))
		for index in range(3):
			var quest: Array=Progress.DAILY[index]
			var count:=mini(int(p.get("daily",{}).get(quest[1],0)),quest[2])
			var done: bool=p.get("daily_awarded",[]).has(index)
			_box(Rect2(120,240+index*104,912,90),Color("d7ebc8") if done else Color("fff8e6"))
			_text(("✓  " if done else "○  ")+quest[0],Rect2(140,245+index*104,570,75),23)
			_text("%d/%d  •  +%d XP" % [count,quest[2],quest[3]],Rect2(740,245+index*104,260,75))
		_text("Bônus das três: +50 XP. Renovação à meia-noite UTC do servidor.\nUm dia sem completar as três reinicia a sequência.",Rect2(120,565,912,65),18)
		return
	var image:=TextureRect.new()
	image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	image.texture=ART
	image.position=Vector2(48,80)
	image.size=Vector2(1056,594)
	image.mouse_filter=Control.MOUSE_FILTER_IGNORE
	content.add_child(image)
	# Cover all illustrative progress from the supplied image with real controls.
	_box(Rect2(810,80,265,80))
	_text("Nível %d   •   %d / 100 XP" % [p.get("level",1),int(p.get("xp",0))%100],Rect2(820,86,245,65),22)
	_button("×",Rect2(1056,96,40,40),func(): close_requested.emit(),true,Color("bc4b42"))
	var completed:=int(p.get("story",0))
	var route:=PackedVector2Array()
	for point in POSITIONS:
		route.append(Vector2(48,88)+point*Vector2(1056.0/1672.0,594.0/941.0))
	# Replace the baked example route, including its checks/locks, with live nodes.
	for width in [106,100]:
		var road:=Line2D.new()
		road.points=route
		road.width=width
		road.default_color=Color("c49d67") if width==106 else Color("f4e4c4")
		road.joint_mode=Line2D.LINE_JOINT_ROUND
		road.begin_cap_mode=Line2D.LINE_CAP_ROUND
		road.end_cap_mode=Line2D.LINE_CAP_ROUND
		road.antialiased=true
		content.add_child(road)
	for index in range(12):
		var center: Vector2=Vector2(48,80)+POSITIONS[index]*Vector2(1056.0/1672.0,594.0/941.0)
		var caption:=("✓ " if index<completed else "")+str(index+1)
		_button(caption,Rect2(center-Vector2(34,26),Vector2(68,68)),func(): selected=index; _refresh(),index<=completed,Color("70ad45") if index<completed else Color("ddab3c"))
	var choice:=clampi(selected if selected>=0 else completed,0,11)
	var mission: Array=Progress.STORY[choice]
	_box(Rect2(815,460,280,210))
	_text("História %d / 12" % mini(completed+1,12),Rect2(825,467,260,32),22)
	_text(mission[0],Rect2(835,505,240,64),21)
	var count:=mini(int(p.get("stats",{}).get(mission[1],0)),mission[2])
	_text("%d/%d  •  +%d XP%s" % [count,mission[2],mission[3],"  ✓" if choice<completed else ""],Rect2(825,569,260,32),18)
	_button("Explorar região",Rect2(836,610,238,43),func(): travel_requested.emit(mission[4]),choice<=completed)
