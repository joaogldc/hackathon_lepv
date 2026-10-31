extends Control
signal finished(result: Dictionary)
var zone:="science"
var texto_retorno: String = ""
var panel: VBoxContainer
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background:=ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color=Color("142b46") if zone=="science" else Color("224e66")
	add_child(background)
	var center:=CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box:=PanelContainer.new()
	box.custom_minimum_size=Vector2(770,580)
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("fff1d3")
	style.set_corner_radius_all(24)
	for side in ["left","right","top","bottom"]: style.set("content_margin_"+side,26)
	box.add_theme_stylebox_override("panel",style)
	center.add_child(box)
	panel=VBoxContainer.new()
	panel.add_theme_constant_override("separation",15)
	panel.alignment=BoxContainer.ALIGNMENT_CENTER
	box.add_child(panel)
	Learning.view={}
	Learning.changed.connect(_refresh)
	_refresh()

func _label(text: String,size:=22) -> void:
	var label:=Label.new()
	label.text=text
	label.custom_minimum_size.x=700
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color",Color("513d2b"))
	label.add_theme_font_size_override("font_size",size)
	panel.add_child(label)
func _button(text: String,action: Callable) -> void:
	var button:=Button.new()
	button.text=text
	button.custom_minimum_size.y=45
	button.add_theme_font_size_override("font_size",19)
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("299bd1")
	style.border_color=Color("513d2b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal",style)
	button.add_theme_stylebox_override("hover",style)
	button.add_theme_color_override("font_color",Color.WHITE)
	button.pressed.connect(action)
	panel.add_child(button)
func _refresh() -> void:
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	var v: Dictionary=Learning.view
	_label({"science":"Observatório • Desafio de ciências","ship":"Navio Aurora • Leitura e interpretação","cave":"Gruta Glacial • Expedição de leitura"}[zone],28)
	var phase: String=v.get("phase","intro")
	if phase=="intro":
		_label("Responda três perguntas. Acerte pelo menos duas para concluir a expedição.\nOs acertos e a conclusão contam para a história e as diárias.")
		_button("Começar",func(): Learning.act("start"))
	elif phase in ["question","feedback"]:
		_label("Pergunta %d/3  •  %d acertos" % [v.index+1,v.score],18)
		_label(v.text,22)
		_label(v.question,25)
		if phase=="question":
			for index in range(v.options.size()):
				_button(v.options[index],func(): Learning.act("answer",index))
		else:
			_label(v.feedback,23)
			_button("Continuar",func(): Learning.act("next"))
	else:
		_label("%d/3 acertos\n%s" % [v.score,"Expedição concluída!" if v.score>=2 else "Tente novamente: são necessários dois acertos."],27)
		_button("Jogar novamente",func(): Learning.act("start"))
	_button(texto_retorno if not texto_retorno.is_empty() else ("Voltar ao porto" if zone!="science" else "Voltar à praça"),func(): finished.emit({}))
	get_viewport().gui_release_focus()
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		finished.emit({})
