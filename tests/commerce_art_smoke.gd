extends Node

func _ready() -> void:
	var commerce := preload("res://scenes/world/commerce.tscn").instantiate()
	add_child(commerce)
	var art := commerce.get_node("CommerceArt")
	assert(not art.has_node("Objetos/Urso"), "Visual scene must not create a second player")
	for shop in ["LojaPets", "LojaCosmeticos"]:
		var sprite := art.get_node("Objetos/" + shop) as Sprite2D
		assert(sprite.texture != null)
		assert(is_equal_approx(sprite.scale.x, sprite.scale.y), "Shop proportions must be preserved")
		assert(not sprite.z_as_relative and sprite.z_index == roundi(sprite.position.y))
		for window in ["VitrineEsquerda", "VitrineDireita"]:
			assert(sprite.get_node(window + "/Espacos").get_child_count() == 6)
	var geometry := preload("res://scripts/world/world_geometry.gd")
	assert(geometry.blocked("commerce", Vector2(300, 380)))
	assert(geometry.blocked("commerce", Vector2(840, 380)))
	assert(geometry.blocked("commerce", Vector2(528.56, 446.22)))
	assert(geometry.blocked("commerce", Vector2(722.63, 458.33)))
	assert(not geometry.blocked("commerce", Vector2(576, 465)), "Spawn must remain clear")
	assert(not geometry.blocked("commerce", Minigames.EXIT.position), "Return portal must remain clear")
	var stopped: Vector2 = geometry.move("commerce", Vector2(300, 430), Vector2(300, 370))
	assert(stopped.y >= 412 and not geometry.blocked("commerce", stopped))
	print("COMMERCE ART PASS: sprites, aspect ratio, windows, player ownership, sorting and collision")
	get_tree().quit(0)
