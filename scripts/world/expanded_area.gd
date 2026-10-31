extends Node2D
const CATALOG := preload("res://scripts/world/world_catalog.gd")
var zone := "language"
var reflection: Node2D
var ground: Texture2D
var mirror_viewport: SubViewport
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
		for side in ["esquerda","direita"]:
			var curtain:=Sprite2D.new()
			curtain.texture=load("res://assets/cenario/provador/cortina_"+side+".png")
			curtain.centered=false
			curtain.position=Vector2(24 if side=="esquerda" else 921,204)
			curtain.scale=Vector2(0.8625,0.605556)
			curtain.z_index=552
			add_child(curtain)
		# Render into a separate texture: changing a child's Z cannot escape its edges.
		mirror_viewport=SubViewport.new()
		mirror_viewport.size=Vector2i(420,470)
		mirror_viewport.transparent_bg=true
		mirror_viewport.disable_3d=true
		mirror_viewport.world_2d=World2D.new()
		mirror_viewport.gui_disable_input=true
		add_child(mirror_viewport)
		var glass:=Sprite2D.new()
		glass.texture=mirror_viewport.get_texture()
		glass.centered=false
		glass.position=Vector2(395,246)
		glass.scale=Vector2(0.8625,0.605556)
		glass.z_index=10
		add_child(glass)
		reflection=load("res://scenes/player/bear.tscn").instantiate()
		reflection.nickname=""
		reflection.scale=Vector2(0.9/0.8625,0.9/0.605556)*CATALOG.DRESSING_SCALE
		mirror_viewport.add_child(reflection)
		reflection.pet.visible=false
		var shine:=Sprite2D.new()
		shine.texture=load("res://assets/cenario/provador/espelho_brilho.png")
		shine.centered=false
		shine.z_index=1000
		glass.add_child(shine)

func _process(_delta: float) -> void:
	if not is_instance_valid(reflection): return
	mirror_viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS if is_visible_in_tree() else SubViewport.UPDATE_DISABLED
	var id:=multiplayer.get_unique_id()
	if not Network.players.has(id): return
	var player: Dictionary=Network.players[id]
	var reflected := Vector2((player.position.x-395)/0.8625,440-(player.position.y-545)*0.5)
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
		load("res://scripts/world/ground_arrow.gd").paint(self,Vector2(710,490),-PI/2-0.35,0.8)
	elif zone=="loja_cosmeticos":
		load("res://scripts/world/ground_arrow.gd").paint(self,Vector2(865,432),PI)
