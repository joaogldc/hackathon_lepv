extends Control
var alvo: Node2D
var zona_override: String = ""
var limites: Rect2 = Rect2(72,230,1008,400)
const MARKERS := {
	"ship":[[Vector2(265,405),"B"],[Vector2(887,405),"B"],[Vector2(576,585),"↓"]],
	"lobby":[[Vector2(576,260),"L"],[Vector2(98,460),"×"],[Vector2(1054,460),"★"],[Vector2(576,610),"N"]],
	"commerce":[[Vector2(309,432),"L"],[Vector2(843,432),"L"],[Vector2(576,610),"↓"]],
	"math":[[Vector2(576,418),"×"],[Vector2(576,610),"↓"]],
	"language":[[Vector2(722,476),"N"],[Vector2(576,610),"↓"]],
	"loja_cosmeticos":[[Vector2(865,432),"P"],[Vector2(576,610),"↓"]],
	"loja_pets":[[Vector2(576,480),"L"],[Vector2(576,610),"↓"]],
	"provador":[[Vector2(576,625),"↓"]]
}
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_PASS
	tooltip_text="Sua área atual · L: lojas · ×: dojo · ★: ciências · N: navio · P: provador"
func _process(_delta: float) -> void: queue_redraw()
func ponto(pos: Vector2) -> Vector2:
	var p:=Vector2(10,16)+(pos-limites.position)/limites.size*Vector2(86,64)
	return Vector2(53,47)+(p-Vector2(53,47)).limit_length(37)
func _draw() -> void:
	var player: Dictionary=Network.players.get(multiplayer.get_unique_id(),{})
	var zone: String=player.get("zone","lobby")
	if not zona_override.is_empty(): zone=zona_override
	else:
		limites=Rect2(72,545,1008,85) if zone=="provador" else (Rect2(72,414,1008,216) if zone in ["loja_pets","loja_cosmeticos"] else Rect2(72,230,1008,400))
	draw_circle(Vector2(53,47),46,Color("d7e8c5"))
	draw_line(Vector2(14,47),Vector2(92,47),Color("f5dfac"),9)
	draw_line(Vector2(53,12),Vector2(53,82),Color("f5dfac"),9)
	for marker in MARKERS.get(zone,[]):
		var p:=ponto(marker[0])
		draw_circle(p,8,Color("fff5dc"))
		draw_string(ThemeDB.fallback_font,p+Vector2(-4,4),marker[1],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("513d2b"))
	if not player.is_empty() or is_instance_valid(alvo):
		var pos:=ponto(alvo.position if is_instance_valid(alvo) else player.position)
		draw_circle(pos,5,Color("133e57"))
		draw_circle(pos,3,Color("35c6ee"))
