extends Node2D
## Grounded sign: depth follows its post, lettering stays sharp at display size.
const TEXTURES := {
	"commerce": preload("res://assets/cenario/placas/placa_commerce.svg"),
	"math": preload("res://assets/cenario/placas/placa_math.svg"),
	"science": preload("res://assets/cenario/placas/placa_science.svg"),
	"language": preload("res://assets/cenario/placas/placa_language.svg")
}
const CAPTIONS := {"commerce": ["Área", "comercial"], "math": ["Bosque da", "Sabedoria"], "science": ["Observatório", ""], "language": ["Porto", "Glacial"]}
## Centro horizontal do texto em cada placa: a ponta da seta ocupa um dos lados da tábua.
const TEXT_CENTER := {"commerce": 10.0, "math": 5.0, "science": -6.0, "language": 10.0}
const FONTS := preload("res://scripts/ui/game_fonts.gd")
const MAX_TEXT_WIDTH := 88.0
var destination := "math"
func _ready() -> void:
	z_index = int(position.y)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
func _draw() -> void:
	draw_texture_rect(TEXTURES[destination], Rect2(-75,-150,150,160), false)
	var lines: Array = CAPTIONS[destination].filter(func(line): return not line.is_empty())
	var font := FONTS.title()
	for index in range(lines.size()):
		# Reduz o corpo só se a palavra não couber na tábua.
		var size := 16
		while size > 11 and font.get_string_size(lines[index],HORIZONTAL_ALIGNMENT_LEFT,-1,size).x > MAX_TEXT_WIDTH: size -= 1
		var baseline := (-84.0 if lines.size() == 1 else -91.0 + index * 15.0) + (size - 16) * 0.35
		FONTS.engraved(self,lines[index],TEXT_CENTER[destination],baseline,size)
