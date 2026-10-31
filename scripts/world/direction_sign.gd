extends Node2D
## Grounded sign: depth follows its post, lettering stays sharp at display size.
const TEXTURES := {
	"commerce": preload("res://assets/cenario/placas/placa_commerce.svg"),
	"math": preload("res://assets/cenario/placas/placa_math.svg"),
	"science": preload("res://assets/cenario/placas/placa_science.svg"),
	"language": preload("res://assets/cenario/placas/placa_language.svg")
}
const CAPTIONS := {"commerce": ["Área", "comercial"], "math": ["Bosque da", "Sabedoria"], "science": ["Observatório", ""], "language": ["Porto", "Glacial"]}
var destination := "math"
func _ready() -> void:
	z_index = int(position.y)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
func _draw() -> void:
	draw_texture_rect(TEXTURES[destination], Rect2(-75,-150,150,160), false)
	var font := ThemeDB.fallback_font
	for line in range(2):
		var caption: String = CAPTIONS[destination][line]
		var width := font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x
		draw_string(font,Vector2(-width/2,(-88 if CAPTIONS[destination][1].is_empty() else -96+line*16)),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("3b2513"))
