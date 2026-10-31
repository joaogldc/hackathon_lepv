extends Node
var count := 0

func check(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		get_tree().quit(1)
		return
	count += 1

func _ready() -> void:
	check(not DailyJournal.persistence,"Teste não pode gravar no perfil real")
	DailyJournal.coins = 300
	DailyJournal.owned = []
	DailyJournal.badges = []
	DailyJournal.progress = {"win":0,"visit":0,"try":0}
	DailyJournal.claimed = []
	DailyJournal.shops = []
	check(not DailyJournal.claim("win"),"Não resgata missão incompleta")
	check(DailyJournal.buy("invalid") != "","Item inexistente não pode ser comprado")
	check(DailyJournal.buy("cartola").is_empty(),"Compra válida")
	check(DailyJournal.coins == 200 and "cartola" in DailyJournal.owned,"Compra debita e adiciona item")
	check(DailyJournal.buy("cartola") != "" and DailyJournal.coins == 200,"Não cobra compra repetida")
	DailyJournal.coins = 0
	check(DailyJournal.buy("laco") != "" and "laco" not in DailyJournal.owned,"Saldo insuficiente não altera inventário")
	check(not DailyJournal.equip("laco") and DailyJournal.equip("cartola"),"Só veste o que possui")
	DailyJournal.visit("pet")
	DailyJournal.visit("pet")
	check(DailyJournal.progress.visit == 1,"Visitas repetidas não duplicam progresso")
	DailyJournal.visit("cosmetics")
	check(DailyJournal.claim("visit") and DailyJournal.coins == 20,"Resgata visita às duas lojas")
	check(not DailyJournal.claim("visit") and DailyJournal.coins == 20,"Não repete recompensa")
	DailyJournal.try_item("bacia")
	check(DailyJournal.progress["try"] == 0,"Pet não vale como roupa provada")
	DailyJournal.try_item("laco")
	check(DailyJournal.claim("try"),"Provar roupa conclui missão")
	var id := multiplayer.get_unique_id()
	var result := {"ids":[id,999],"winner":-1}
	DailyJournal._result(result)
	result.winner = 1
	DailyJournal._result(result)
	check(DailyJournal.badges.is_empty(),"Empate e derrota não concedem selo")
	result.winner = 0
	result.spectator = true
	DailyJournal._result(result)
	check(DailyJournal.badges.is_empty(),"Espectador não recebe selo")
	result.spectator = false
	DailyJournal._result(result)
	check(DailyJournal.badges == ["first_daily_win"] and DailyJournal.progress.win == 1,"Vitória real concede primeiro selo")
	check(DailyJournal.claim("win"),"Vitória permite resgate")
	DailyJournal._result(result)
	check(not DailyJournal.claim("win") and DailyJournal.badges.size() == 1,"Segunda vitória não duplica selo ou resgate")
	DailyJournal.day = "2000-01-01"
	DailyJournal.roll_day()
	check(DailyJournal.claimed.is_empty() and DailyJournal.progress.win == 0,"Novo dia renova missões")
	check(DailyJournal.badges.size() == 1 and "cartola" in DailyJournal.owned and DailyJournal.equipped == "cartola","Novo dia preserva coleção e visual")
	var world: Node2D = load("res://scenes/world/lobby.tscn").instantiate()
	add_child(world)
	Network.host("Kilim")
	var view: Control = world.commerce_ui
	view.open_page("shops")
	check(not view.is_open(),"Não existe central de compras")
	view.open_page("cosmetics")
	check(not view.is_open(),"Não compra cosméticos na praça")
	Network.players[1].position = Vector2(576,240)
	Network._change_zone(1,"commerce")
	check(Network.players[1].zone == "commerce","Entra na área comercial")
	Network._change_zone(1,"cosmetics_shop")
	check(Network.players[1].zone == "commerce","Não entra na loja longe da porta")
	Network.players[1].position = Vector2(844,430)
	Network._change_zone(1,"cosmetics_shop")
	check(Network.players[1].zone == "cosmetics_shop" and world.interior_view.visible,"Porta abre interior de cosméticos")
	view.open_page("cosmetics")
	check(not view.is_open(),"Compra não abre na entrada da loja")
	Network.players[1].position = Vector2(576,423)
	view.open_page("cosmetics")
	check(view.page == "cosmetics","Balcão abre apenas cosméticos")
	view.open_page("pet")
	check(view.page == "cosmetics","Cosméticos não abre compra de pets")
	view.open_page("fitting")
	check(view.page == "cosmetics","Balcão não abre provador")
	Network.players[1].position = Vector2(878,330)
	Network._change_zone(1,"fitting_room")
	check(not view.is_open() and world.current_zone == "fitting_room","Entrar no provador fecha compra")
	Network.players[1].position = Vector2(576,550)
	view.open_page("fitting")
	check(view.page == "fitting","Espelho abre interface de experimentar")
	view.selected = "camisa_azul"
	view._refresh()
	check(view.selected == "camisa_azul","Nova roupa está disponível no provador")
	var clothes := preload("res://scripts/player/clothing_assets.gd")
	for key in clothes.LAYERS:
		var frames: SpriteFrames = clothes.LAYERS[key]
		for face in ["S","SE","E","NE","N"]:
			check(frames.get_frame_count("idle_"+face) == 2 and frames.get_frame_count("walk_"+face) == 4,"Animações das roupas preservadas: "+key+face)
	var mask: Image = clothes.LAYERS.camisa_cor.get_frame_texture("idle_S",0).get_image()
	check(mask.get_pixel(128,60).a == 0.0 and mask.get_pixel(128,160).a > 0.5,"Camisa não contém cabeça/corpo cinza do urso")
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	view.handle_key(escape)
	check(not view.is_open(),"Esc fecha provador")
	Network.players[1].position = Vector2(576,620)
	Network._change_zone(1,"cosmetics_shop")
	check(Network.players[1].zone == "cosmetics_shop","Provador volta para a mesma loja")
	Network.players[1].position = Vector2(576,620)
	Network._change_zone(1,"commerce")
	Network.players[1].position = Vector2(309,430)
	Network._change_zone(1,"pet_shop")
	Network.players[1].position = Vector2(576,423)
	view.open_page("pet")
	check(view.page == "pet","Balcão da loja de pets abre compra de pet")
	Network.players[1].position = Vector2(576,620)
	Network._change_zone(1,"commerce")
	check(not view.is_open(),"Sair da loja fecha sua interface")
	view.open_page("daily")
	check(view.page == "daily","Diário está disponível no HUD principal")
	Network.leave("")
	await get_tree().process_frame
	print("SHOPS DAILY PASS: %d checks" % count)
	get_tree().quit()
