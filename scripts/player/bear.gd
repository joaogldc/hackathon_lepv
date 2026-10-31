extends Node2D
## Optional Inkscape exports: assets/characters/brown/{front,back,left,right}.png.
var direction := "front"
var nickname := "Urso"
var target := Vector2.ZERO
var local_player := false
var textures: Dictionary = {}
var animation_frames: Dictionary = {}
var animation_time := 0.0
var moving := false
const FACES := {"front": "S", "back": "N", "left": "E", "right": "E", "front_right": "SE", "front_left": "SE", "back_right": "NE", "back_left": "NE"}

func _ready() -> void:
	for face in ["S", "N", "E", "NE", "SE"]:
		for action in ["idle", "walk"]:
			var frames: Array[Texture2D] = []
			for i in range(1, (3 if action == "idle" else 5)):
				var frame_path := "res://assets/sprites/urso/frames/%s_%s_%d.png" % [face, action, i]
				if ResourceLoader.exists(frame_path):
					frames.append(load(frame_path))
			animation_frames[face + "_" + action] = frames
	for face in ["front", "back", "left", "right"]:
		var path := "res://assets/characters/brown/%s.png" % face
		if ResourceLoader.exists(path):
			textures[face] = load(path)

func _process(delta: float) -> void:
	var was_moving := moving
	moving = position.distance_to(target) > 1.5
	if was_moving != moving:
		animation_time = 0.0
	animation_time += delta
	position = position.lerp(target, 1.0 - exp(-18.0 * delta))
	z_index = int(position.y)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1, 0.3))
	draw_circle(Vector2.ZERO, 27, Color(0.05, 0.12, 0.1, 0.25))
	draw_set_transform(Vector2.ZERO)
	if local_player:
		draw_arc(Vector2(0, -4), 32, 0, TAU, 40, Color("f3ce79"), 2, true)
	var face: String = FACES.get(direction, "S")
	var frames: Array = animation_frames.get(face + ("_walk" if moving else "_idle"), [])
	if not frames.is_empty():
		var frame: Texture2D = frames[int(animation_time * (8.0 if moving else 2.0)) % frames.size()]
		var flip := direction in ["left", "front_left", "back_left"]
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1 if flip else 1, 1))
		draw_texture_rect(frame, Rect2(-48, -96, 96, 96), false)
		draw_set_transform(Vector2.ZERO)
	elif textures.has(direction):
		draw_texture_rect(textures[direction], Rect2(-48, -88, 96, 96), false)
	else:
		var brown := Color("a96f45")
		draw_circle(Vector2(0, -22), 22, brown)
		draw_circle(Vector2(-18, -58), 12, brown)
		draw_circle(Vector2(18, -58), 12, brown)
		draw_circle(Vector2(0, -45), 27, brown)
		draw_circle(Vector2(-13, -2), 10, brown)
		draw_circle(Vector2(13, -2), 10, brown)
		if direction != "back":
			var offset := -9.0 if direction == "left" else (9.0 if direction == "right" else 0.0)
			draw_circle(Vector2(offset, -37), 12, Color("eac79d"))
			draw_circle(Vector2(offset, -41), 4, Color("342c2a"))
			if direction != "right":
				draw_circle(Vector2(-11 + offset, -50), 3, Color("342c2a"))
			if direction != "left":
				draw_circle(Vector2(11 + offset, -50), 3, Color("342c2a"))
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(nickname, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	draw_string(font, Vector2(-width / 2, -85), nickname, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("fff2d9"))
