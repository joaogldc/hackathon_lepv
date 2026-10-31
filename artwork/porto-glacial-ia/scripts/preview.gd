extends Node2D
var mapa: TextureRect
func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	mapa = TextureRect.new()
	mapa.texture = load("res://hud/mapa-de-descobertas.png")
	mapa.size = Vector2(1280, 720)
	mapa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mapa.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mapa.visible = false
	layer.add_child(mapa)
	var hint := Label.new()
	hint.text = "M: mapa de quests  |  Esc: fechar mapa"
	hint.position = Vector2(18, 693)
	hint.add_theme_color_override("font_outline_color", Color("133c55"))
	hint.add_theme_constant_override("outline_size", 5)
	layer.add_child(hint)
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_M:
			mapa.visible = not mapa.visible
		elif event.physical_keycode == KEY_ESCAPE:
			mapa.visible = false
