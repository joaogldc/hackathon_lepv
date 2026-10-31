extends Node
## Shared catalog. Clients request IDs, never arbitrary scene paths.
const PORTALS := {
	"dojo": {"title": "Entrar no dojo", "position": Vector2(576, 400), "scene": "res://scenes/minigames/math/entry.tscn"},
	"commerce": {"title": "Área comercial", "place": "Vila das lojas", "position": Vector2(576, 260), "color": Color("dfb181"), "scene": "res://scenes/world/commerce.tscn"},
	"math": {"title": "Bosque da Matemática", "place": "Bosque da Matemática", "position": Vector2(98, 460), "color": Color("91bf80"), "scene": "res://scenes/minigames/math/entry.tscn"},
	"language": {"title": "Geleira do Português", "place": "Geleira do Português", "position": Vector2(576, 610), "color": Color("99d2e4"), "scene": "res://scenes/minigames/language/entry.tscn"},
	"science": {"title": "Floresta de Ciências", "place": "Floresta de Ciências", "position": Vector2(1054, 460), "color": Color("ebbb86"), "scene": "res://scenes/minigames/science/entry.tscn"}
}
const ENTRY_RADIUS := 85.0
const GAME_IDS := ["math", "language", "science"]
const WORLD_ZONES := ["lobby", "commerce", "math", "pet_shop", "cosmetics_shop", "fitting_room"]
const SHOP_ZONES := ["pet_shop", "cosmetics_shop", "fitting_room"]
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
	elif zone == "pet_shop":
		if point.y >= 610 and absf(point.x-576) < 85: return "commerce"
	elif zone == "cosmetics_shop":
		if point.y >= 610 and absf(point.x-576) < 85: return "commerce"
		if point.y <= 340 and absf(point.x-878) < 48: return "fitting_room"
	elif zone == "fitting_room":
		if point.y >= 610 and absf(point.x-576) < 85: return "cosmetics_shop"
	elif zone in ["math", "commerce"]:
		if zone == "commerce" and point.y <= 437:
			if absf(point.x-309) < 38: return "pet_shop"
			if absf(point.x-844) < 38: return "cosmetics_shop"
		if point.y >= 602 and absf(point.x-576) < 90: return "lobby"
		if zone == "math" and point.distance_to(PORTALS.dojo.position) < 42: return "dojo"
	return ""

func bounds(zone: String) -> Rect2:
	if zone == "fitting_room": return Rect2(230,520,692,110)
	if zone in SHOP_ZONES: return Rect2(90,315,972,315)
	return Rect2(72,230,1008,400)

func shop_action(zone: String, point: Vector2) -> String:
	if zone == "pet_shop" and point.distance_to(Vector2(576,423)) < 82: return "pet"
	if zone == "cosmetics_shop" and point.distance_to(Vector2(576,423)) < 82: return "cosmetics"
	if zone == "fitting_room" and Rect2(350,520,450,82).has_point(point): return "fitting"
	return ""
