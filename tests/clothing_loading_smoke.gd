extends Node
const CLOTHING := preload("res://scripts/player/clothing_assets.gd")
func _ready() -> void:
	var world:=preload("res://scenes/world/lobby.tscn").instantiate()
	add_child(world)
	await get_tree().process_frame
	assert(CLOTHING.loaded.is_empty(),"Starting the world must not decode every clothing atlas")
	# An optional clothing load failure must not prevent creating the world/UI.
	CLOTHING.loaded["camisa_cor"]=null
	var bear:=preload("res://scenes/player/bear.tscn").instantiate()
	bear.outfit="camisa_azul"
	add_child(bear)
	await get_tree().process_frame
	assert(is_instance_valid(world.host_button))
	assert(Network.host("ClothingLoadTest",false,19109)==OK)
	CLOTHING.loaded.erase("camisa_cor")
	var shirt: SpriteFrames=CLOTHING.layer("camisa_cor")
	assert(shirt and shirt.has_animation("idle_S") and shirt.has_animation("sit_N"))
	assert(CLOTHING.loaded.size()==1,"A shirt must not load suit, hat and beanie atlases")
	assert(CLOTHING.layer("invalid")==null)
	print("CLOTHING LOAD PASS: optional texture failure preserves startup; only requested atlases load")
	get_tree().quit()
