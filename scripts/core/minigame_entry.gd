extends Control
## Replace this placeholder with the actual game, preserving finished(result).
signal finished(result: Dictionary)
@export var game_id := "math"
@export var owner_label := "Pessoa 2"
var returning := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("142a2c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	box.custom_minimum_size.x = 650
	center.add_child(box)
	var portal: Dictionary = Minigames.PORTALS[game_id]
	_add_label(box, portal.place.to_upper(), 18, portal.color)
	_add_label(box, portal.title, 36, Color("fff2d9"))
	_add_label(box, "Você atravessou o portal e continua conectado à sala.", 20)
	_add_label(box, "Cena provisória • desenvolvimento: " + owner_label, 20)
	_add_label(box, "M: mapa da ilha • Esta cena provisória não concede moedas.", 18)
	var back := Button.new()
	back.text = "Voltar à praça  [Esc]"
	back.custom_minimum_size.y = 54
	back.pressed.connect(_return)
	box.add_child(back)
	back.grab_focus()

func _add_label(parent: Node, text_value: String, size: int, color := Color("c2d2d0")) -> void:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_return()

func _return() -> void:
	if returning:
		return
	returning = true
	finished.emit({"game": game_id, "completed": false, "reason": "placeholder"})
