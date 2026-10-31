extends Node
## Shared catalog. Clients request IDs, never arbitrary scene paths.
const PORTALS := {
	"dojo": {"title": "Entrar no dojo", "position": Vector2(576, 400), "scene": "res://scenes/minigames/math/entry.tscn"},
	"commerce": {"title": "Área comercial", "place": "Vila das lojas", "position": Vector2(576, 260), "color": Color("dfb181"), "scene": "res://scenes/world/commerce.tscn"},
	"math": {"title": "Bosque da Sabedoria", "place": "Bosque da Sabedoria", "position": Vector2(98, 460), "color": Color("91bf80"), "scene": "res://scenes/minigames/math/entry.tscn"},
	"language": {"title": "Porto Glacial", "place": "Porto Glacial", "position": Vector2(576, 610), "color": Color("99d2e4"), "scene": "res://scenes/minigames/language/entry.tscn"},
	"science": {"title": "Observatório", "place": "Observatório", "position": Vector2(1054, 460), "color": Color("ebbb86"), "scene": "res://scenes/minigames/science/entry.tscn"}
}
const ENTRY_RADIUS := 85.0
const GAME_IDS := ["math", "language", "science"]
const WORLD_ZONES := ["lobby", "commerce", "math", "language", "loja_pets", "loja_cosmeticos", "provador"]
const BAMBOO_EXIT := {"title": "Voltar ao lobby", "position": Vector2(576, 610)}
const EXIT := {"title": "Voltar ao lobby", "position": Vector2(576, 575), "color": Color("c7dab2")}

func portal(id: String, zone := "lobby") -> Dictionary:
	return (BAMBOO_EXIT if zone == "math" else EXIT) if id == "lobby" else PORTALS[id]

func nearest(position: Vector2, zone := "lobby") -> String:
	if zone == "math":
		if position.distance_to(PORTALS.dojo.position) <= ENTRY_RADIUS:
			return "dojo"
		return "lobby" if position.distance_to(BAMBOO_EXIT.position) <= ENTRY_RADIUS else ""
	if zone == "commerce":
		return "lobby" if position.distance_to(EXIT.position) <= ENTRY_RADIUS else ""
	for id in PORTALS:
		if id == "dojo":
			continue
		if position.distance_to(PORTALS[id].position) <= ENTRY_RADIUS:
			return id
	return ""

# Exit corridors are wider than the floor markers; touching an arrow is unnecessary.
func exit_at(point: Vector2, zone: String) -> String:
	if zone == "lobby":
		if point.x <= 110 and absf(point.y-460) < 48: return "math"
		if point.x >= 1042 and absf(point.y-460) < 48: return "science"
		if point.y <= 255 and absf(point.x-576) < 90: return "commerce"
		if point.y >= 602 and absf(point.x-576) < 90: return "language"
	elif zone in ["math", "commerce", "language"]:
		if point.y >= 602 and absf(point.x-576) < 90: return "lobby"
		if zone == "math" and point.distance_to(PORTALS.dojo.position) < 42: return "dojo"
		if zone=="commerce":
			if point.distance_to(Vector2(309,432))<30: return "loja_pets"
			if point.distance_to(Vector2(843,432))<30: return "loja_cosmeticos"
		if zone=="language":
			if point.distance_to(Vector2(710,500))<32: return "ship"
	elif zone in ["loja_pets","loja_cosmeticos","provador"]:
		if point.y>=602 and absf(point.x-576)<90: return "loja_cosmeticos" if zone=="provador" else "commerce"
		if zone=="loja_cosmeticos" and point.distance_to(Vector2(865,432))<28: return "provador"
	return ""
