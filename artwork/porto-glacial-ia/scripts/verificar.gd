extends SceneTree
func _initialize() -> void:
	var packed := load("res://cenas/porto_glacial.tscn") as PackedScene
	assert(packed != null)
	var scene := packed.instantiate()
	root.add_child.call_deferred(scene)
	_check.call_deferred(scene)
func _check(scene: Node) -> void:
	assert(scene.get_node("Navio").texture != null)
	assert(scene.get_node("Mamute").texture != null)
	assert(scene.get_node("Smilodon").texture != null)
	assert(scene.get_node("Gruta").texture != null)
	assert(scene.get_node("Chao").texture != null)
	assert(scene.mapa.texture != null)
	assert(not scene.mapa.visible)
	scene.mapa.visible = true
	assert(scene.mapa.visible)
	print("GLACIAL PREVIEW PASS: scene, textures, separate objects and quest HUD")
	quit(0)
