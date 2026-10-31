extends Node2D
## Visual companion derived from the original image. Pose follows authoritative bear direction.
const FRONT := preload("res://assets/pets/flying_fish/front.png")
const SIDE := [preload("res://assets/pets/flying_fish/side_1.png"),preload("res://assets/pets/flying_fish/side_2.png"),preload("res://assets/pets/flying_fish/side_3.png"),preload("res://assets/pets/flying_fish/side_4.png")]
const BACK := [preload("res://assets/pets/flying_fish/back_1.png"),preload("res://assets/pets/flying_fish/back_2.png")]
## A arara usa os quadros em alta resolução, os mesmos em que os acessórios foram desenhados.
const PARROT_FRONT := preload("res://assets/pets/arara/quadros/frente.png")
const PARROT_SIDE := [preload("res://assets/pets/arara/quadros/lado_1.png"),preload("res://assets/pets/arara/quadros/lado_2.png"),preload("res://assets/pets/arara/quadros/lado_3.png"),preload("res://assets/pets/arara/quadros/lado_4.png"),preload("res://assets/pets/arara/quadros/lado_5.png"),preload("res://assets/pets/arara/quadros/lado_6.png"),preload("res://assets/pets/arara/quadros/lado_7.png"),preload("res://assets/pets/arara/quadros/lado_8.png"),preload("res://assets/pets/arara/quadros/lado_9.png"),preload("res://assets/pets/arara/quadros/lado_10.png")]
const PARROT_BACK := [preload("res://assets/pets/arara/quadros/costas_1.png"),preload("res://assets/pets/arara/quadros/costas_2.png"),preload("res://assets/pets/arara/quadros/costas_3.png"),preload("res://assets/pets/arara/quadros/costas_4.png"),preload("res://assets/pets/arara/quadros/costas_5.png"),preload("res://assets/pets/arara/quadros/costas_6.png"),preload("res://assets/pets/arara/quadros/costas_7.png"),preload("res://assets/pets/arara/quadros/costas_8.png"),preload("res://assets/pets/arara/quadros/costas_9.png")]
const ACCESSORIES := preload("res://scripts/player/pet_accessories.gd")
const EMOTE_IDS := preload("res://scripts/player/pet_emotes.gd").IDS
const EMOTE_NAMES := preload("res://scripts/player/pet_emotes.gd").NAMES
const FISH_EMOTES := [preload("res://assets/pets/flying_fish/emotes/happy.png"),preload("res://assets/pets/flying_fish/emotes/love.png"),preload("res://assets/pets/flying_fish/emotes/star.png"),preload("res://assets/pets/flying_fish/emotes/surprise.png"),preload("res://assets/pets/flying_fish/emotes/confused.png"),preload("res://assets/pets/flying_fish/emotes/sad.png"),preload("res://assets/pets/flying_fish/emotes/angry.png"),preload("res://assets/pets/flying_fish/emotes/sleep.png")]
const PARROT_EMOTE_FRAMES := ["feliz", "apaixonada", "encantada", "surpresa", "duvida", "suor", "brava", "dormindo"]
const PARROT_EMOTES := [preload("res://assets/pets/arara/quadros/emocao_feliz.png"),preload("res://assets/pets/arara/quadros/emocao_apaixonada.png"),preload("res://assets/pets/arara/quadros/emocao_encantada.png"),preload("res://assets/pets/arara/quadros/emocao_surpresa.png"),preload("res://assets/pets/arara/quadros/emocao_duvida.png"),preload("res://assets/pets/arara/quadros/emocao_suor.png"),preload("res://assets/pets/arara/quadros/emocao_brava.png"),preload("res://assets/pets/arara/quadros/emocao_dormindo.png")]
static func expression(species: String, mood: String) -> Texture2D:
	var index:=EMOTE_IDS.find(mood)
	return null if index<0 else (PARROT_EMOTES if species=="parrot" else FISH_EMOTES)[index]
var emotion:=""
var kind := "fish"
var facing := "front"
var walking := false
var clock := 0.0
var offset := Vector2(30,8)
var attached_to_bear := true
var behind := false
var accessory := "none"
func configure(direction: String, is_moving: bool, species: String="fish", reaction: String="", worn: String="none") -> void:
	emotion=reaction
	# O perfil guarda o id da loja (pet_coroa); a arte usa só o nome (coroa).
	accessory=worn.trim_prefix("pet_")
	kind=species
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
	var parrot:=kind=="parrot"
	var texture: Texture2D=PARROT_FRONT if parrot else FRONT
	var frame:="frente" if parrot else "front"
	var side: Array=PARROT_SIDE if parrot else SIDE
	var back: Array=PARROT_BACK if parrot else BACK
	# A arara tem ciclos de 10 e 9 quadros; o peixe, de 4 e 2.
	if facing in ["left","right","front_left","front_right"]:
		var rate:=(12.0 if walking else 7.0) if parrot else (7.0 if walking else 4.0)
		var index:=int(clock*rate)%side.size()
		texture=side[index]
		frame=("lado_%d" if parrot else "side_%d") % (index+1)
	elif facing in ["back","back_left","back_right"]:
		var index:=int(clock*(8.0 if parrot else 4.0))%back.size()
		texture=back[index]
		frame=("costas_%d" if parrot else "back_%d") % (index+1)
	var emote: Texture2D=expression(kind,emotion)
	if emote:
		texture=emote
		# Os quadros de emoção do peixe não têm acessório; os da arara têm.
		frame="emocao_"+PARROT_EMOTE_FRAMES[EMOTE_IDS.find(emotion)] if parrot else ""
	# Keep the flight at shoulder height while the shadow stays on the floor.
	var center:=Vector2(offset.x,-44.0+sin(clock*4.0)*1.5)
	draw_set_transform(offset,0.0,Vector2(1,0.25))
	draw_circle(Vector2.ZERO,10,Color(0.04,0.12,0.16,0.15))
	var flip:=facing in ["left","front_left","back_left"]
	draw_set_transform(center,0.0,Vector2(-1 if flip else 1,1))
	# 0,25 px por pixel do peixe; a arara (288 px de largura) cabe na mesma largura de 32 px.
	var size:=texture.get_size()*(42.0/288.0 if parrot else 0.328125)
	var rect:=Rect2(-size/2.0+(Vector2(0,-4) if emote else Vector2.ZERO),size)
	draw_texture_rect(texture,rect,false)
	if accessory!="none" and not frame.is_empty():
		for layer in ACCESSORIES.layers(kind,accessory,frame): draw_texture_rect(layer,rect,false)
