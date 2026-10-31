extends RefCounted
## Server-side feet collision; substeps prevent crossing an obstacle in a long frame.
const CENTER := Vector2(576, 466)
const RADII := Vector2(109, 48)
static func blocked(zone: String, point: Vector2) -> bool:
	if zone in ["pet_shop", "cosmetics_shop"]:
		if Rect2(444,350,264,41).has_point(point): return true
		if zone == "pet_shop":
			for base in [Rect2(243,464,126,24),Rect2(810,504,110,24),Rect2(742,378,134,29)]:
				if base.has_point(point): return true
		else:
			for base in [Rect2(184,451,172,28),Rect2(796,523,172,28),Rect2(534,487,84,32)]:
				if base.has_point(point): return true
		return false
	if zone == "lobby":
		if ((point - CENTER) / RADII).length_squared() < 1.0: return true
		for bush in [Vector2(290,295),Vector2(850,295),Vector2(290,555),Vector2(850,555)]:
			if ((point-bush)/Vector2(53,30)).length_squared() < 1.0: return true
		for post in [Vector2(715,340),Vector2(117,420),Vector2(1020,420),Vector2(715,620)]:
			if point.distance_to(post) < 14.0: return true
		return false
	if zone == "math":
		if Rect2(430,225,292,150).has_point(point): return true
		# Dense background bamboo closes the rear of the grove; the door stays clear.
		for rear in [Rect2(24,204,392,188),Rect2(736,204,392,188),Rect2(416,204,320,22)]:
			if rear.has_point(point): return true
		for fence in [Rect2(326,499,98,30),Rect2(716,499,98,30)]:
			if fence.grow(10).has_point(point): return true
		# Collision at the bases, rather than the tall leaves and lantern tops.
		for base in [Rect2(58,493,137,45),Rect2(204,434,105,42),Rect2(922,493,137,45),Rect2(363,385,49,30),Rect2(753,385,49,30)]:
			if base.grow(12).has_point(point): return true
		return false
	if zone == "commerce":
		# Footprints match the uniformly scaled shop and street sprites.
		for shop in [Rect2(159, 355, 300, 57), Rect2(694, 355, 300, 57)]:
			if shop.has_point(point):
				return true
		if Rect2(505, 412, 142, 24).has_point(point):
			return true
		for table in [Vector2(282.75, 552.19), Vector2(869.25, 552.19)]:
			if ((point - table) / Vector2(38, 21)).length_squared() < 1.0:
				return true
		for lamp in [Vector2(239.63, 470.44), Vector2(912.38, 470.44)]:
			if point.distance_to(lamp) < 11.0:
				return true
		for sign_board in [Vector2(429.38, 452.28), Vector2(722.63, 452.28)]:
			if point.distance_to(sign_board) < 17.0:
				return true

	return false

static func move(zone: String, start: Vector2, target: Vector2) -> Vector2:
	var point := safe_position(zone,start)
	var steps := maxi(1, ceili(start.distance_to(target) / 5.0))
	var step := (target - start) / steps
	for i in range(steps):
		var next := point + step
		if not blocked(zone, next):
			point = next
		else:
			var x := point + Vector2(step.x, 0)
			if not blocked(zone, x):
				point = x
			var y := point + Vector2(0, step.y)
			if not blocked(zone, y):
				point = y
	return point

static func safe_position(zone: String, point: Vector2) -> Vector2:
	if not blocked(zone,point): return point
	var bounds := Rect2(230,520,692,110) if zone == "fitting_room" else (Rect2(90,315,972,315) if zone in ["pet_shop","cosmetics_shop"] else Rect2(72,230,1008,400))
	for radius in range(8,241,8):
		for index in range(32):
			var candidate := point + Vector2.RIGHT.rotated(TAU*index/32.0)*radius
			if bounds.has_point(candidate) and not blocked(zone,candidate): return candidate
	return Vector2(560,500) if zone == "math" else Vector2(350,450)
