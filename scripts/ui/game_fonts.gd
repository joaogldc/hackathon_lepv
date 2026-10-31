extends RefCounted
## Fonte de letreiros do jogo (placas e nomes). Se o arquivo faltar, cai na fonte padrão.
const TITLE_PATH := "res://assets/fonts/Baloo2-ExtraBold.ttf"
static var _title: Font

static func title() -> Font:
	if _title == null:
		_title = load(TITLE_PATH) if ResourceLoader.exists(TITLE_PATH) else ThemeDB.fallback_font
	return _title

## Letreiro "entalhado": sombra clara embaixo, contorno suave e tinta escura.
static func engraved(canvas: CanvasItem, text: String, center_x: float, baseline: float, size: int, ink := Color("4a2a10"), light := Color("ffe0a0")) -> void:
	var font: Font = preload("res://assets/fonts/Lato-Bold.ttf")
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var origin := Vector2(center_x - width / 2.0, baseline)
	canvas.draw_string(font, origin + Vector2(0, 1.2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, light)
	canvas.draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, ink)

## Nome flutuante legível sobre qualquer cenário.
static func nameplate(canvas: CanvasItem, text: String, center_x: float, baseline: float, size: int, ink := Color("ffe15c"), outline := Color("142535")) -> void:
	var font: Font = preload("res://assets/fonts/Lato-Bold.ttf")
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var origin := Vector2(center_x - width / 2.0, baseline)
	canvas.draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 5, outline)
	canvas.draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, ink)
