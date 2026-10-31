extends RefCounted
## Server-side feet collision; substeps prevent crossing an obstacle in a long frame.
const CENTER := Vector2(576, 466)
const RADII := Vector2(109, 48)
static func blocked(zone: String, point: Vector2) -> bool:
	if zone == "lobby":
		return ((point - CENTER) / RADII).length_squared() < 1.0
	if zone == "math":
		return Rect2(430, 225, 292, 150).has_point(point)
	return false

static func move(zone: String, start: Vector2, target: Vector2) -> Vector2:
	var point := start
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
	if zone == "lobby" and blocked(zone, point):
		var direction := (point - CENTER) / RADII
		if direction.is_zero_approx():
			direction = Vector2.DOWN
		return CENTER + direction.normalized() * RADII * 1.05
	return point
