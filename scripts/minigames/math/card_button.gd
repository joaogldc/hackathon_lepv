extends Button
## One to three honeycomb cells indicate difficulty. Every card deals one damage.
const FONT := preload("res://assets/fonts/Lato-Bold.ttf")
@export var difficulty := 0
var selected := false
func _ready() -> void:
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	tooltip_text = "%s • %d favo(s) de mel • 1 de dano" % [["Fácil", "Médio", "Difícil"][difficulty], difficulty + 1]
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
func _box(rect: Rect2, color: Color, border: Color, width := 2) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(14)
	draw_style_box(style, rect)
func _honeycomb(center: Vector2) -> void:
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for corner in range(6):
		var direction := Vector2.from_angle(corner * TAU / 6.0 - PI / 2.0)
		outer.append(center + direction * 14)
		inner.append(center + direction * 10)
	draw_colored_polygon(outer, Color("a9681c"))
	draw_colored_polygon(inner, Color("efaa25"))
	outer.append(outer[0])
	draw_polyline(outer, Color("ffd36a"), 2, true)
	draw_line(center + Vector2(-7,-4), center + Vector2(-2,-8), Color("ffe7a0"), 3, true)
	draw_line(center + Vector2(2,8), center + Vector2(7,4), Color("ce8017"), 2, true)
func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, size / Vector2(128, 154))
	var active := selected or (is_hovered() and not disabled) or has_focus()
	_box(Rect2(2, 5, 124, 147), Color("33271f"), Color("33271f"))
	_box(Rect2(2, 0, 124, 147), Color("fff5dc"), Color("ffc95b") if active else Color("846346"), 4 if active else 2)
	_box(Rect2(9, 7, 110, 30), Color(["347d66", "236c86", "994c39"][difficulty]), Color.TRANSPARENT, 0)
	draw_string(FONT, Vector2(9, 28), ["FÁCIL", "MÉDIO", "DIFÍCIL"][difficulty], HORIZONTAL_ALIGNMENT_CENTER, 110, 15, Color.WHITE)
	for index in range(difficulty + 1): _honeycomb(Vector2(64 + (index - difficulty / 2.0) * 30, 60))
	draw_line(Vector2(19, 83), Vector2(109, 83), Color("ddcba2"), 1)
	draw_string(FONT, Vector2(9, 117), "1", HORIZONTAL_ALIGNMENT_CENTER, 110, 32, Color("513d2b"))
	draw_string(FONT, Vector2(9, 137), "DE DANO", HORIZONTAL_ALIGNMENT_CENTER, 110, 11, Color("846346"))
