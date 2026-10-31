extends Node2D
## Visual companion derived from the original image. Pose follows authoritative bear direction.
const FRONT := preload("res://assets/pets/flying_fish/front.png")
const SIDE := [preload("res://assets/pets/flying_fish/side_1.png"),preload("res://assets/pets/flying_fish/side_2.png"),preload("res://assets/pets/flying_fish/side_3.png"),preload("res://assets/pets/flying_fish/side_4.png")]
const BACK := [preload("res://assets/pets/flying_fish/back_1.png"),preload("res://assets/pets/flying_fish/back_2.png")]
var facing := "front"
var walking := false
var clock := 0.0
var offset := Vector2(30,8)
var attached_to_bear := true
var behind := false
func configure(direction: String, is_moving: bool) -> void:
	facing=direction
	walking=is_moving
	behind=direction in ["left","front_left","back_left","back","back_right"]
	z_index=(-1 if behind else 1) if attached_to_bear else (9 if behind else 11)
func _process(delta: float) -> void:
	clock+=delta
	var goal:=Vector2(30,8)
	if facing in ["left","front_left","back_left"]: goal=Vector2(18,-12)
	elif facing in ["back","back_right"]: goal=Vector2(26,-10)
	elif facing=="right": goal=Vector2(28,4)
	offset=offset.lerp(goal,1.0-exp(-14.0*delta))
	queue_redraw()
func _draw() -> void:
	var texture: Texture2D=FRONT
	if facing in ["left","right","front_left","front_right"]:
		texture=SIDE[int(clock*(7.0 if walking else 4.0))%SIDE.size()]
	elif facing in ["back","back_left","back_right"]:
		texture=BACK[int(clock*4.0)%BACK.size()]
	# Keep the flight at shoulder height while the shadow stays on the floor.
	var center:=Vector2(offset.x,-44.0+sin(clock*4.0)*1.5)
	draw_set_transform(offset,0.0,Vector2(1,0.25))
	draw_circle(Vector2.ZERO,10,Color(0.04,0.12,0.16,0.15))
	var flip:=facing in ["left","front_left","back_left"]
	draw_set_transform(center,0.0,Vector2(-1 if flip else 1,1))
	draw_texture_rect(texture,Rect2(-16,-16,32,32),false)
