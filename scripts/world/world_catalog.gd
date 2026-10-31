extends RefCounted
const LAYOUT_DATA := preload("res://scripts/world/area_layout_data.gd")
static var layouts: Dictionary = LAYOUT_DATA.DATA
const TITLES := {"lobby":"Praça dos encontros","math":"Bosque da Sabedoria","language":"Porto Glacial","commerce":"Vila das lojas","loja_pets":"Loja de pets","loja_cosmeticos":"Loja de cosméticos","provador":"Provador"}
const SEATS := {
	"lobby":[Vector2(345,362),Vector2(385,362),Vector2(760,362),Vector2(800,362)],
	"commerce":[Vector2(225,555),Vector2(340,555),Vector2(812,555),Vector2(927,555)],
	"provador":[Vector2(921,591)]
}
const MERCHANT := Vector2(576,480)
const MERCHANT_RADIUS := 75.0
static func near_merchant(point: Vector2) -> bool:
	return point.distance_to(MERCHANT)<=MERCHANT_RADIUS
const DRESSING_SCALE := 2.4
static func character_scale(zone: String) -> float:
	return DRESSING_SCALE if zone=="provador" else 1.0
static func walk_speed(zone: String) -> float:
	return 190.0*character_scale(zone)
static func seats(zone: String) -> Array:
	return SEATS.get(zone,[])
static func nearest_seat(zone: String, point: Vector2) -> int:
	var options := seats(zone)
	for index in range(options.size()):
		if point.distance_to(options[index])<55: return index
	return -1
static func collision(zone: String, point: Vector2) -> bool:
	if not layouts.has(zone): return false
	if zone=="provador":
		# Mirror and curtain footprints meet the back edge of the dressing-room floor.
		if Rect2(387,238,378,306).has_point(point) or point.y<545: return true
		var depth:=clampf((point.y-545)/85,0,1)
		if point.x<lerpf(231,72,depth) or point.x>lerpf(930,1080,depth): return true
	if zone in ["loja_pets","loja_cosmeticos","provador"] and point.y<414: return true
	for shape in layouts[zone].collisions:
		var center := Vector2(shape.position[0],shape.position[1])
		if shape.has("size"):
			var size := Vector2(shape.size[0],shape.size[1])
			if Rect2(center-size/2,size).grow(8).has_point(point): return true
		elif center.distance_to(point)<shape.radius+8: return true
	if zone=="language":
		# Feet footprints; tall sprites still allow walking behind them.
		for shape in [Vector4(169,384,95,23),Vector4(174,515,75,22),Vector4(241,415,110,12),Vector4(242,538,104,12),Vector4(904,501,155,32),Vector4(893,620,115,30),Vector4(345,379,23,10),Vector4(715,378,25,10),Vector4(425,603,22,10),Vector4(76,630,18,12)]:
			if ((point-Vector2(shape.x,shape.y))/Vector2(shape.z,shape.w)).length_squared()<1: return true
		for lamp in [Vector2(385,351),Vector2(721,355),Vector2(818,492),Vector2(434,622)]:
			if point.distance_to(lamp)<12: return true
		if point.y<342 or (point.x>760 and point.y<540) or point.x>965: return true
	return false
