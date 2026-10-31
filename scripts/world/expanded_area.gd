extends Node2D
const CATALOG := preload("res://scripts/world/world_catalog.gd")
var zone := "language"
var reflection: Node2D
var ground: Texture2D
func _ready() -> void:
	var layout: Dictionary=CATALOG.layouts[zone]
	ground=load(layout.ground)
	for item in layout.objects:
		var sprite:=Sprite2D.new()
		sprite.name=item.name
		sprite.texture=load(item.texture)
		sprite.position=Vector2(item.position[0],item.position[1])
		sprite.offset=Vector2(item.offset[0],item.offset[1])
		sprite.scale=Vector2(item.scale[0],item.scale[1])
		sprite.centered=item.centered
		sprite.z_index=item.depth
		add_child(sprite)
	if zone in ["loja_pets","loja_cosmeticos"]:
		var vendor:=Sprite2D.new()
		vendor.texture=load("res://assets/sprites/urso/frames/S_idle_1.png")
		vendor.position=Vector2(576,441)
		vendor.offset=Vector2(0,-110)
		vendor.scale=Vector2.ONE*0.254333
		vendor.z_index=441
		add_child(vendor)
	if zone=="provador":
		var glass:=Sprite2D.new()
		glass.texture=load("res://assets/cenario/provador/espelho_vidro.png")
		glass.centered=false
		glass.position=Vector2(395,246)
		glass.scale=Vector2(0.8625,0.605556)
		glass.clip_children=CanvasItem.CLIP_CHILDREN_ONLY
		glass.z_index=10
		add_child(glass)
		reflection=load("res://scenes/player/bear.tscn").instantiate()
		reflection.nickname=""
		reflection.scale=Vector2(0.9/0.8625,0.9/0.605556)
		glass.add_child(reflection)
		reflection.pet.visible=false
		var shine:=Sprite2D.new()
		shine.texture=load("res://assets/cenario/provador/espelho_brilho.png")
		shine.centered=false
		shine.z_index=1000
		glass.add_child(shine)

func _process(_delta: float) -> void:
	if not is_instance_valid(reflection): return
	var id:=multiplayer.get_unique_id()
	if not Network.players.has(id): return
	var player: Dictionary=Network.players[id]
	var reflected := Vector2((player.position.x-395)/0.8625,420-(player.position.y-540)*0.4)
	reflection.target=reflected
	reflection.position=reflected
	reflection.direction={"back":"front","front":"back","back_left":"front_left","back_right":"front_right","front_left":"back_left","front_right":"back_right"}.get(player.direction,player.direction)
	reflection.sitting=player.get("sitting",false)
	reflection.outfit=player.get("outfit","none")
	reflection.pet.visible=false

func _draw() -> void:
	draw_texture_rect(ground,Rect2(24,204,1104,436),false)
	load("res://scripts/world/ground_arrow.gd").paint(self,Vector2(576,608),0.0)
	if zone=="language":
		load("res://scripts/world/ground_arrow.gd").paint(self,Vector2(760,500),-PI/2)
		load("res://scripts/world/ground_arrow.gd").paint(self,Vector2(559,362),PI)
	elif zone=="loja_cosmeticos":
		load("res://scripts/world/ground_arrow.gd").paint(self,Vector2(865,432),PI)
