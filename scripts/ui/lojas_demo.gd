extends Node
var world: Node2D
func _ready() -> void:
	world = load("res://scenes/world/lobby.tscn").instantiate()
	add_child(world)
	Network.host("Kilim")
	if "--render-huds" in OS.get_cmdline_user_args(): _render.call_deferred()

func fixture(zone: String, point: Vector2, page := "") -> void:
	Network.players[1].zone = zone
	Network.players[1].position = point
	Network.players[1].destination = null
	Network.roster_changed.emit()
	world.position = Vector2.ZERO
	if world.transition_tween: world.transition_tween.kill()
	if not page.is_empty(): world.commerce_ui.open_page(page)
	else: world.commerce_ui.close_window()

func capture(name: String) -> void:
	for i in range(3): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/huds-lojas/"+name+".png")
	print("CAPTURE ",name)

func _render() -> void:
	DailyJournal.owned = ["camisa_azul"]
	DailyJournal.equipped = "camisa_azul"
	fixture("lobby",Vector2(500,535))
	await capture("principal-clube")
	fixture("pet_shop",Vector2(576,423))
	await capture("balcao-pets")
	world.commerce_ui.open_page("pet")
	await capture("pet")
	fixture("cosmetics_shop",Vector2(576,423),"cosmetics")
	await capture("cosmetics")
	fixture("fitting_room",Vector2(576,550),"fitting")
	world.commerce_ui.selected = "camisa_azul"
	world.commerce_ui._refresh()
	await capture("fitting")
	DailyJournal._result({"ids":[1,999],"winner":0})
	fixture("lobby",Vector2(500,535),"daily")
	await capture("selo-conquistado")
	world.hide()
	world.hud.hide()
	world.commerce_ui.hide()
	var sheet := Control.new()
	add_child(sheet)
	var bg := ColorRect.new()
	bg.color = Color("fff5dc")
	bg.size = Vector2(1152,720)
	sheet.add_child(bg)
	var products: Array = DailyJournal.ITEMS.filter(func(product): return product.has("garment"))
	for i in range(products.size()):
		var preview := preload("res://scripts/ui/bear_fitting_preview.gd").new()
		preview.item_id = products[i].id
		preview.position = Vector2(18+(i%5)*225,35+(i/5)*325)
		preview.size = Vector2(210,270)
		sheet.add_child(preview)
		var label := Label.new()
		label.text = products[i].name
		label.position = preview.position+Vector2(0,275)
		label.size = Vector2(210,35)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size",17)
		label.add_theme_color_override("font_color",Color("513d2b"))
		sheet.add_child(label)
	await capture("roupas-novas")
	get_tree().quit()
