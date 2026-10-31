extends Control
## Island destinations, independent of walking coordinates in each area.
signal destination_selected(destination: String)
signal close_requested
const DESTINATIONS := {
	"commerce": {"label": "Vila das lojas", "detail": "Cosméticos e pets", "rect": Rect2(465, 211, 222, 65)},
	"math": {"label": "Bosque da Matemática", "detail": "Duelo matemático", "rect": Rect2(213, 343, 222, 65)},
	"science": {"label": "Floresta de Ciências", "detail": "Minijogo de ciências", "rect": Rect2(718, 343, 222, 65)},
	"language": {"label": "Geleira do Português", "detail": "Minijogo de português", "rect": Rect2(465, 523, 222, 65)},
	"lobby": {"label": "Praça dos encontros", "detail": "Lobby", "rect": Rect2(465, 363, 222, 65)}
}
var zone := "lobby"

func _ready() -> void:
	var id := multiplayer.get_unique_id()
	if Network.players.has(id):
		zone = Network.players[id].zone
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var close := Button.new()
	close.text = "Fechar [M / Esc]"
	close.position = Vector2(852, 89)
	close.size = Vector2(160, 38)
	close.pressed.connect(func(): close_requested.emit())
	add_child(close)
	for destination in DESTINATIONS:
		var info: Dictionary = DESTINATIONS[destination]
		var button := Button.new()
		button.name = destination
		button.position = info.rect.position
		button.size = info.rect.size
		button.text = info.label + "\n" + ("Você está aqui" if destination == zone else info.detail)
		button.disabled = destination == zone
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(_choose.bind(destination))
		add_child(button)

func _choose(destination: String) -> void:
	if destination != zone:
		destination_selected.emit(destination)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var point := get_local_mouse_position()
		var destination := ""
		if Rect2(472, 170, 208, 125).has_point(point):
			destination = "commerce"
		elif Rect2(210, 295, 230, 180).has_point(point):
			destination = "math"
		elif Rect2(710, 295, 240, 180).has_point(point):
			destination = "science"
		elif Rect2(465, 485, 222, 112).has_point(point):
			destination = "language"
		elif Rect2(445, 305, 255, 175).has_point(point):
			destination = "lobby"
		if not destination.is_empty():
			_choose(destination)
		accept_event()

func _text(point: Vector2, value: String, font_size := 17, color := Color("fff2d9")) -> void:
	draw_string(ThemeDB.fallback_font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _tree(point: Vector2) -> void:
	draw_rect(Rect2(point + Vector2(-4, 0), Vector2(8, 20)), Color("735437"))
	draw_circle(point + Vector2(0, -8), 22, Color("356849"))
	draw_circle(point + Vector2(-7, -16), 14, Color("4a8456"))

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.06, 0.07, 0.85))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("153a49")
	panel.set_corner_radius_all(20)
	draw_style_box(panel, Rect2(120, 70, 912, 598))
	_text(Vector2(151, 112), "ILHA DOS URSOS", 29)
	_text(Vector2(151, 145), "Escolha uma região para viajar diretamente até ela.", 18)
	for point in [Vector2(176, 242), Vector2(964, 530), Vector2(248, 584), Vector2(923, 216)]:
		draw_arc(point, 34, 0.2, 2.7, 24, Color("3d7180"), 3, true)
	var coast := PackedVector2Array([Vector2(182, 312), Vector2(286, 245), Vector2(423, 231), Vector2(478, 169), Vector2(665, 170), Vector2(722, 235), Vector2(870, 253), Vector2(969, 334), Vector2(981, 446), Vector2(856, 506), Vector2(739, 527), Vector2(675, 609), Vector2(476, 617), Vector2(408, 530), Vector2(261, 502), Vector2(175, 422)])
	draw_colored_polygon(coast, Color("e2cc91"))
	var land := PackedVector2Array([Vector2(197, 321), Vector2(290, 263), Vector2(436, 250), Vector2(487, 187), Vector2(653, 187), Vector2(710, 253), Vector2(864, 271), Vector2(951, 342), Vector2(961, 433), Vector2(846, 489), Vector2(723, 511), Vector2(664, 592), Vector2(486, 598), Vector2(419, 514), Vector2(269, 483), Vector2(194, 414)])
	draw_colored_polygon(land, Color("8eae71"))
	draw_colored_polygon(PackedVector2Array([Vector2(197, 321), Vector2(290, 263), Vector2(436, 250), Vector2(466, 312), Vector2(447, 463), Vector2(419, 514), Vector2(269, 483), Vector2(194, 414)]), Color("749c58"))
	draw_colored_polygon(PackedVector2Array([Vector2(710, 253), Vector2(864, 271), Vector2(951, 342), Vector2(961, 433), Vector2(846, 489), Vector2(723, 511), Vector2(692, 448), Vector2(691, 313)]), Color("507951"))
	draw_colored_polygon(PackedVector2Array([Vector2(419, 514), Vector2(481, 466), Vector2(663, 466), Vector2(723, 511), Vector2(664, 592), Vector2(486, 598)]), Color("cbe9ed"))
	draw_rect(Rect2(515, 266, 120, 245), Color("d9c18a"))
	draw_rect(Rect2(425, 351, 292, 71), Color("d9c18a"))
	for point in [Vector2(264, 310), Vector2(304, 312), Vector2(352, 302), Vector2(393, 318), Vector2(268, 450), Vector2(333, 462), Vector2(392, 450)]:
		for offset in [-8, 8]:
			draw_line(point + Vector2(offset, 12), point + Vector2(offset, -25), Color("315e3a"), 5, true)
			draw_line(point + Vector2(offset, -12), point + Vector2(offset + 10, -20), Color("c0d68b"), 3, true)
	for point in [Vector2(751, 301), Vector2(812, 304), Vector2(885, 320), Vector2(754, 453), Vector2(817, 463), Vector2(897, 442)]:
		_tree(point)
	for point in [Vector2(494, 494), Vector2(644, 491), Vector2(465, 557), Vector2(685, 551)]:
		draw_colored_polygon(PackedVector2Array([point + Vector2(-13, 7), point + Vector2(-4, -16), point + Vector2(5, -21), point + Vector2(16, 8)]), Color("f3fdff"))
	for point in [Vector2(504, 206), Vector2(640, 206)]:
		draw_rect(Rect2(point - Vector2(15, 8), Vector2(30, 24)), Color("c58e65"))
		draw_colored_polygon(PackedVector2Array([point + Vector2(-20, -8), point + Vector2(0, -24), point + Vector2(20, -8)]), Color("825b51"))
	_text(Vector2(150, 643), "M / Esc: fechar o mapa     •     WASD / setas: caminhar dentro de cada área", 17)
