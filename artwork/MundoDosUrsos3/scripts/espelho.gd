extends Sprite2D
## Espelho do provador: mostra o reflexo do urso (de frente quando ele olha para o espelho).
## Este nó só serve de máscara (clip_children); o reflexo é o filho "Reflexo".

@export var urso_path: NodePath
@export var linha_chao := 400.0       # onde ficam os pés do reflexo, dentro do espelho
@export var chao_sala := 560.0        # y do chão da sala mais perto do espelho
@export var escala := 0.92

@onready var reflexo: AnimatedSprite2D = $Reflexo
var urso: Node2D
var spr_urso: AnimatedSprite2D

const TROCA := {"N": "S", "S": "N", "NE": "SE", "SE": "NE", "E": "E"}

func _ready() -> void:
	urso = get_node_or_null(urso_path)
	if urso:
		spr_urso = urso.get_node("AnimatedSprite2D")

func _process(_delta: float) -> void:
	if urso == null:
		return
	var anim := String(spr_urso.animation)
	var partes := anim.split("_")
	if partes.size() == 2 and TROCA.has(partes[1]):
		anim = partes[0] + "_" + TROCA[partes[1]]
	if reflexo.animation != anim and reflexo.sprite_frames.has_animation(anim):
		reflexo.play(anim)
	reflexo.frame = spr_urso.frame
	reflexo.flip_h = spr_urso.flip_h
	var dist := urso.global_position.y - chao_sala
	reflexo.position = Vector2(urso.global_position.x - global_position.x, linha_chao - dist * 0.3)
	reflexo.scale = spr_urso.scale * escala * (1.0 - dist * 0.0008)
	reflexo.offset = spr_urso.offset
