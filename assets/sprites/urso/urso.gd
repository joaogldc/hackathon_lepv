extends CharacterBody2D
## Urso jogador: anda em 8 direções e senta em bancos.
## Setas para andar. Perto de um banco, aperte Espaço/Enter para sentar.
## Sentado, aperte Espaço/Enter ou uma seta para levantar.

@export var speed := 160.0
@onready var spr: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisao: CollisionShape2D = $CollisionShape2D

var last_dir := 2           # começa olhando para a frente (S)
var banco_proximo: Node = null
var sentado := false
var ocupado := false        # durante a animação de sentar/levantar
var _pos_antes := Vector2.ZERO

const OFFSET_PE := Vector2(0, -110)      # quadros normais: pés na origem
const OFFSET_BANCO := Vector2(0, -70)    # quadros de sentar ficam 40 px mais altos na folha

# setor 0=E,1=SE,2=S,3=SW,4=W,5=NW,6=N,7=NE -> [animação, espelhar]
const DIRS = [["E",false],["SE",false],["S",false],["SE",true],
			  ["E",true],["NE",true],["N",false],["NE",false]]

func _physics_process(_delta: float) -> void:
	if ocupado:
		return
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if sentado:
		if Input.is_action_just_pressed("ui_accept") or input != Vector2.ZERO:
			levantar()
		return
	if banco_proximo != null and Input.is_action_just_pressed("ui_accept"):
		sentar()
		return

	velocity = input * speed
	move_and_slide()
	var state := "idle"
	if input != Vector2.ZERO:
		last_dir = wrapi(roundi(input.angle() / (PI / 4)), 0, 8)
		state = "walk"
	var d = DIRS[last_dir]
	spr.flip_h = d[1]
	spr.play("%s_%s" % [state, d[0]])

func sentar() -> void:
	ocupado = true
	velocity = Vector2.ZERO
	_pos_antes = global_position
	colisao.set_deferred("disabled", true)
	global_position = banco_proximo.assento_mais_perto(global_position)
	spr.flip_h = false
	spr.offset = OFFSET_BANCO
	spr.play("sentar")
	var subir: float = banco_proximo.altura_assento / spr.scale.y
	var t := create_tween()
	t.tween_property(spr, "offset", OFFSET_BANCO + Vector2(0, -subir), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await spr.animation_finished
	spr.play("sentado")
	sentado = true
	ocupado = false

func levantar() -> void:
	ocupado = true
	spr.play_backwards("sentar")
	var t := create_tween()
	t.tween_property(spr, "offset", OFFSET_BANCO, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await spr.animation_finished
	spr.offset = OFFSET_PE
	global_position = Vector2(global_position.x, _pos_antes.y)
	colisao.set_deferred("disabled", false)
	sentado = false
	ocupado = false
	last_dir = 2
	spr.play("idle_S")
