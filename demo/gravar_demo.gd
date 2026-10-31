extends SceneTree
## Roteiro da demo: gravado com --write-movie, tempo fixo de 30 qps.
## Na pasta do projeto:
##   Godot_v4.7.2-stable_win64_console.exe --path . --write-movie demo/bruto.avi --fixed-fps 30 --script <caminho absoluto>/demo/gravar_demo.gd
##   ffmpeg -i demo/bruto.avi -an -c:v libx264 -preset slow -crf 26 -pix_fmt yuv420p -movflags +faststart demo/kbear_demo.mp4
const FONTS := preload("res://scripts/ui/game_fonts.gd")
var net: Node
var mg: Node
var learning: Node
var duel: Node
var caption_layer: CanvasLayer
var caption_panel: PanelContainer
var caption_title: Label
var caption_sub: Label
var fade: ColorRect
var caption_tween: Tween

func _wait(seconds: float) -> void:
	for i in int(seconds * 30.0):
		await process_frame

func _caption(title: String, sub := "") -> void:
	caption_title.text = title
	caption_sub.text = sub
	caption_sub.visible = not sub.is_empty()
	caption_panel.visible = not title.is_empty()
	caption_panel.reset_size()
	caption_panel.position = Vector2((1152 - caption_panel.size.x) / 2.0, 548)
	# Legenda entra, fica um pouco e sai, para não esconder a tela por muito tempo.
	if caption_tween: caption_tween.kill()
	caption_panel.modulate.a = 0.0
	caption_tween = root.create_tween()
	caption_tween.tween_property(caption_panel, "modulate:a", 1.0, 0.25)
	caption_tween.tween_interval(2.6)
	caption_tween.tween_property(caption_panel, "modulate:a", 0.0, 0.35)

func _build_overlay() -> void:
	caption_layer = CanvasLayer.new()
	caption_layer.layer = 120
	root.add_child(caption_layer)
	caption_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.961, 0.863, 0.95)
	style.border_color = Color(0.318, 0.239, 0.169)
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 6
	style.content_margin_bottom = 8
	style.shadow_color = Color(0.02, 0.08, 0.1, 0.3)
	style.shadow_size = 10
	caption_panel.add_theme_stylebox_override("panel", style)
	caption_layer.add_child(caption_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", -4)
	caption_panel.add_child(box)
	caption_title = Label.new()
	caption_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_title.add_theme_font_override("font", FONTS.title())
	caption_title.add_theme_font_size_override("font_size", 30)
	caption_title.add_theme_color_override("font_color", Color(0.318, 0.239, 0.169))
	box.add_child(caption_title)
	caption_sub = Label.new()
	caption_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_sub.add_theme_font_size_override("font_size", 16)
	caption_sub.add_theme_color_override("font_color", Color(0.12, 0.48, 0.61))
	box.add_child(caption_sub)
	caption_panel.visible = false
	fade = ColorRect.new()
	fade.color = Color(0.08, 0.15, 0.16, 1)
	fade.size = Vector2(1152, 720)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption_layer.add_child(fade)

func _fade_to(alpha: float, seconds := 0.5) -> void:
	var steps := int(seconds * 30.0)
	var start := fade.color.a
	for i in steps:
		fade.color.a = lerpf(start, alpha, float(i + 1) / steps)
		await process_frame

func _transition(action: Callable) -> void:
	await _fade_to(1.0, 0.35)
	if caption_tween: caption_tween.kill()
	caption_panel.visible = false
	action.call()
	await _wait(0.3)
	await _fade_to(0.0, 0.35)

func _me() -> Dictionary:
	return net.players[1]

func _walk(point: Vector2, seconds: float) -> void:
	net.walk_to(point)
	await _wait(seconds)

func _goto_door(zone_from_pos: Vector2, destination: String) -> void:
	_me().position = zone_from_pos
	net.request_zone(destination)

func _initialize() -> void:
	net = root.get_node("Network")
	mg = root.get_node("Minigames")
	learning = root.get_node("Learning")
	duel = root.get_node("Duel")
	var progress := root.get_node("Progress")
	progress.storage_path = "user://demo_progress.json"
	progress.profiles = {}
	# A demo cria uma conta; guarda as contas reais para restaurar no fim.
	var contas_backup := FileAccess.get_file_as_bytes("user://contas.cfg") if FileAccess.file_exists("user://contas.cfg") else PackedByteArray()
	_build_overlay()

	# 1. Abertura e login
	change_scene_to_file("res://scenes/ui/login.tscn")
	await _wait(0.2)
	await _fade_to(0.0, 0.6)
	_caption("kBear.", "Um mundo de ursos para aprender explorando")
	await _wait(2.2)
	_caption("")
	var tela = current_scene
	for c in "Explorador":
		tela.campo_usuario.text += c
		await _wait(0.08)
	await _wait(0.3)
	tela.campo_senha.grab_focus()
	for c in "mel123":
		tela.campo_senha.text += c
		await _wait(0.08)
	await _wait(0.5)
	tela.botao.grab_focus()
	await _wait(0.4)
	await _fade_to(1.0, 0.35)
	tela._entrar()
	await _wait(0.2)
	var world = current_scene
	net.host("Explorador", false, 19301)
	await _wait(0.2)
	_me().pet = "parrot"
	_me().pet_acc = "pet_coroa"
	_me().outfits = {"head": "chapeu_preto"}
	net.roster_changed.emit()
	await _fade_to(0.0, 0.35)

	# 2. Praça
	_caption("Praça dos encontros", "O ponto de partida: os amigos se encontram aqui")
	await _walk(Vector2(470, 470), 1.6)
	await _walk(Vector2(690, 520), 1.6)
	await _walk(Vector2(576, 560), 1.2)
	net.interact("pet_emote", "happy")
	await _wait(1.2)

	# 3. Mapa
	_caption("Mapa da ilha", "Viaje para qualquer região com um clique")
	world._toggle_map()
	await _wait(2.6)
	world._close_map()

	# 4. Vila das lojas
	await _transition(func(): net.travel_to("commerce"))
	_caption("Vila das lojas", "Pets e cosméticos comprados com moedas ganhas aprendendo")
	await _walk(Vector2(700, 470), 1.8)
	await _transition(func(): _goto_door(Vector2(309, 432), "loja_pets"))
	_caption("Loja de pets", "Escolha um companheiro para a jornada")
	await _walk(Vector2(576, 470), 2.0)
	world.commerce_ui.open_page("pet")
	await _wait(2.6)
	world.commerce_ui.close_window()
	await _transition(func():
		_me().zone = "commerce"
		_goto_door(Vector2(843, 432), "loja_cosmeticos"))
	_caption("Loja de cosméticos", "Chapéus, camisas e acessórios")
	await _walk(Vector2(576, 470), 1.4)
	world.commerce_ui.open_page("cosmetics")
	await _wait(2.4)
	world.commerce_ui.close_window()
	await _transition(func(): _goto_door(Vector2(865, 432), "provador"))
	_caption("Provador", "Experimente o visual e veja seu pet no espelho")
	await _walk(Vector2(470, 560), 1.4)
	await _walk(Vector2(660, 560), 1.6)

	# 5. Bosque e dojo (duelo de matemática)
	await _transition(func(): net.travel_to("math"))
	_caption("Bosque da Sabedoria", "Casa do dojo de bambu")
	await _walk(Vector2(576, 470), 2.0)
	await _transition(func(): _goto_door(mg.PORTALS.dojo.position, "dojo"))
	_caption("Minigame: Duelo de cartas", "Cada carta vira uma multiplicação para o adversário resolver")
	var rival: Dictionary = _me().duplicate(true)
	rival.nickname = "Amiga Ursa"
	rival.pet = "fish"
	rival.pet_acc = "none"
	rival.outfits = {}
	net.players[2] = rival
	net.intents[2] = {"vector": Vector2.ZERO, "age": 0.0}
	duel._command(1, "join", 0, 0, 0)
	duel._command(2, "join", 0, 0, 0)
	await _play_duel(14.0)
	# A rival sai do dojo: a vitória mostra as animações de moedas e XP.
	net.players[2].zone = "math"
	duel._depart(2)
	await _wait(0.2)
	_caption("Recompensas", "Moedas e experiência por aprender")
	await _wait(3.6)
	world.recompensa_moedas.fechar()
	await _wait(0.2)
	if world.recompensa_xp.visible:
		await _wait(3.2)
		world.recompensa_xp.fechar()
	net.players.erase(2)
	net.intents.erase(2)
	net.roster_changed.emit()
	await _transition(func(): net.request_zone("math"))

	# 6. Porto Glacial e navio
	await _transition(func(): net.travel_to("language"))
	_caption("Porto Glacial", "Mamutes, fósseis e um navio esperando no cais")
	await _walk(Vector2(420, 470), 1.8)
	await _walk(mg.SHIP_ENTRY + Vector2(-60, 20), 1.6)
	await _transition(func():
		_me().position = mg.SHIP_ENTRY
		net.request_zone("ship"))
	_caption("Deque Glacial", "Caminhe até um bote para começar a leitura")
	var deck = world.game_view
	await _wait(1.0)
	var start: Vector2 = deck.jogador.position
	var goal: Vector2 = deck.get_node("BoteBombordo").position
	for i in 75:
		deck.jogador.target = start.lerp(goal, float(i + 1) / 75.0)
		await process_frame
	await _wait(0.6)
	_caption("Minigame: Leitura no bote", "Textos curtos e perguntas de interpretação")
	await _answer_questions(2)
	deck._voltar_deque({})
	await _wait(0.8)
	_caption("Deque Glacial", "Siga a seta para voltar ao porto")
	var down := InputEventKey.new()
	down.physical_keycode = KEY_S
	down.keycode = KEY_S
	down.pressed = true
	Input.parse_input_event(down)
	var hold := 0
	while _me().zone == "ship" and hold < 90:
		hold += 1
		await process_frame
	down = down.duplicate()
	down.pressed = false
	Input.parse_input_event(down)
	await _wait(0.5)

	# 7. Observatório
	await _transition(func(): net.travel_to("science"))
	_caption("Minigame: Observatório", "Desafios de ciências")
	await _wait(1.0)
	if learning.view.is_empty(): learning.act("start")
	await _answer_questions(2)

	# 8. Encerramento
	await _fade_to(1.0, 0.5)
	net.leave("")
	change_scene_to_file("res://scenes/ui/login.tscn")
	await _wait(0.3)
	current_scene.campo_usuario.text = ""
	_caption("kBear.", "Explore, aprenda e jogue com os amigos")
	await _fade_to(0.0, 0.5)
	await _wait(2.8)
	await _fade_to(1.0, 0.6)
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://demo_progress.json"))
	if contas_backup.is_empty(): DirAccess.remove_absolute(ProjectSettings.globalize_path("user://contas.cfg"))
	else: FileAccess.open("user://contas.cfg", FileAccess.WRITE).store_buffer(contas_backup)
	quit()

func _answer_questions(count: int) -> void:
	for q in count:
		var t := 0
		while learning.view.get("phase", "") != "question" and t < 90:
			t += 1
			await process_frame
		await _wait(2.4)
		var s: Dictionary = learning.sessions.get(1, {})
		if s.is_empty(): return
		learning.act("answer", s.correct)
		await _wait(1.8)
		if q < count - 1: learning.act("next")

func _play_duel(seconds: float) -> void:
	var frames := int(seconds * 30.0)
	var last_revision := -1
	var acted_at := 0
	for f in frames:
		await process_frame
		if not duel.membership.has(1): continue
		var m: Dictionary = duel.matches[duel.membership[1]]
		if m.revision != last_revision:
			last_revision = m.revision
			acted_at = f + 45
		if f != acted_at: continue
		var attacker: int = m.ids[m.attacker]
		var defender: int = m.ids[1 - m.attacker]
		if m.phase == "choose":
			duel._command(attacker, "card", f % 2, m.match_id, m.revision)
		elif m.phase == "answer":
			var pick: int = m.options.find(m.answer)
			if defender == 2 and m.turn == 1: pick = (pick + 1) % m.options.size()
			duel._command(defender, "answer", pick, m.match_id, m.revision)
		elif m.phase == "resolve":
			m.seconds = minf(m.seconds, 1.0)
