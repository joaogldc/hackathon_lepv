extends RefCounted
## Rotate in ground coordinates, then squash vertically to match the floor plane.
static func paint(canvas: CanvasItem, point: Vector2, angle: float, size:=1.0) -> void:
	var polygon := PackedVector2Array()
	for vertex in [Vector2(-10,-28),Vector2(10,-28),Vector2(10,-2),Vector2(26,-2),Vector2(0,28),Vector2(-26,-2),Vector2(-10,-2)]:
		var rotated: Vector2 = vertex.rotated(angle)
		polygon.append(point + rotated * Vector2(1.0,0.48)*size)
	var shadow := PackedVector2Array()
	for vertex in polygon: shadow.append(vertex+Vector2(0,3))
	canvas.draw_colored_polygon(shadow,Color(0.15,0.12,0.02,0.32))
	canvas.draw_colored_polygon(polygon,Color("ffd83d"))
	polygon.append(polygon[0])
	canvas.draw_polyline(polygon,Color("fff3a3"),2.0,true)
