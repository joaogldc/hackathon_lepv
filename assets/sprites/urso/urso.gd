extends CharacterBody2D
## Movimento em 8 direções do urso. Precisa de um AnimatedSprite2D filho
## usando urso_frames.tres. W, SW e NW usam flip_h.

@export var speed := 160.0
@onready var spr: AnimatedSprite2D = $AnimatedSprite2D
var last_dir := 2  # começa olhando para a frente (S)

# setor 0=E,1=SE,2=S,3=SW,4=W,5=NW,6=N,7=NE -> [animação, espelhar]
const DIRS = [["E",false],["SE",false],["S",false],["SE",true],
			  ["E",true],["NE",true],["N",false],["NE",false]]

func _physics_process(_delta):
	var input := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = input * speed
	move_and_slide()

	var state := "idle"
	if input != Vector2.ZERO:
		last_dir = wrapi(roundi(input.angle() / (PI / 4)), 0, 8)
		state = "walk"
	var d = DIRS[last_dir]
	spr.flip_h = d[1]
	spr.play("%s_%s" % [state, d[0]])
