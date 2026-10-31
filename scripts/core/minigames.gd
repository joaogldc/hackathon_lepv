extends Node
## Shared catalog. Clients request IDs, never arbitrary scene paths.
const PORTALS := {
	"dojo": {"title": "Entrar no dojo", "position": Vector2(576, 400), "scene": "res://scenes/minigames/math/entry.tscn"},
	"commerce": {"title": "Área comercial", "place": "Vila das lojas", "position": Vector2(576, 285), "color": Color("dfb181"), "scene": "res://scenes/world/commerce.tscn"},
	"math": {"title": "Bosque de bambu", "place": "Bosque de bambu", "position": Vector2(135, 425), "color": Color("91bf80"), "scene": "res://scenes/minigames/math/entry.tscn"},
	"language": {"title": "Barco de português", "place": "Porto polar", "position": Vector2(576, 575), "color": Color("99d2e4"), "scene": "res://scenes/minigames/language/entry.tscn"},
	"science": {"title": "Foguete de ciências", "place": "Floresta do foguete", "position": Vector2(1010, 425), "color": Color("ebbb86"), "scene": "res://scenes/minigames/science/entry.tscn"}
}
const ENTRY_RADIUS := 85.0
const GAME_IDS := ["math", "language", "science"]
const WORLD_ZONES := ["lobby", "commerce", "math"]
const EXIT := {"title": "Voltar ao lobby", "position": Vector2(576, 575), "color": Color("c7dab2")}

func portal(id: String) -> Dictionary:
	return EXIT if id == "lobby" else PORTALS[id]

func nearest(position: Vector2, zone := "lobby") -> String:
	if zone == "math":
		if position.distance_to(PORTALS.dojo.position) <= ENTRY_RADIUS:
			return "dojo"
		return "lobby" if position.distance_to(EXIT.position) <= ENTRY_RADIUS else ""
	if zone == "commerce":
		return "lobby" if position.distance_to(EXIT.position) <= ENTRY_RADIUS else ""
	for id in PORTALS:
		if id == "dojo":
			continue
		if position.distance_to(PORTALS[id].position) <= ENTRY_RADIUS:
			return id
	return ""
