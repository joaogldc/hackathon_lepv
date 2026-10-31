extends Node
var resultados: Array[Dictionary] = []
func _ready() -> void:
	var diario = preload("res://resources/progression/diarias_padrao.tres").duplicate(true)
	assert(not diario.registrar_missao("inexistente","2026-10-20").aceito)
	assert(not diario.registrar_missao("jogar","2026-10-20").novo_bonus)
	assert(not diario.registrar_missao("jogar","2026-10-20").novo_bonus)
	assert(not diario.registrar_missao("acertar","2026-10-20").novo_bonus)
	var dia1: Dictionary = diario.registrar_missao("explorar","2026-10-20")
	assert(dia1.novo_bonus and dia1.bonus_xp == 5 and dia1.dias == 1)
	assert(not diario.registrar_missao("explorar","2026-10-20").novo_bonus)
	for id in diario.missoes_obrigatorias: diario.registrar_missao(id,"2026-10-21")
	assert(diario.dias_seguidos == 2)
	assert(diario.consultar("2026-10-23").dias == 0)
	for id in diario.missoes_obrigatorias: diario.registrar_missao(id,"2026-10-23")
	assert(diario.dias_seguidos == 1, "Pular um dia reinicia a sequência")
	assert(not diario.registrar_missao("jogar","2026-10-22").aceito, "Evento antigo não recua o dia")
	diario.bonus_maximo = 12
	for data in ["2026-10-24","2026-10-25"]:
		for id in diario.missoes_obrigatorias:
			var r: Dictionary = diario.registrar_missao(id,data)
			assert(r.bonus_xp <= 12)
	assert(diario.dias_seguidos == 3)
	var caminho := "user://teste-diarias-%d.tres" % Time.get_ticks_usec()
	assert(ResourceSaver.save(diario,caminho) == OK)
	var recarregado = ResourceLoader.load(caminho,"",ResourceLoader.CACHE_MODE_IGNORE)
	assert(recarregado.dias_seguidos == 3 and not recarregado.registrar_missao("jogar","2026-10-25").novo_bonus)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(caminho))
	var xp := preload("res://scenes/ui/recompensa_xp.tscn").instantiate()
	xp.reproduzir_ao_iniciar = false
	xp.duracao_animacao = 0.5
	add_child(xp)
	xp.animacao_concluida.connect(func(r: Dictionary): resultados.append(r))
	xp.mostrar()
	await get_tree().create_timer(0.65).timeout
	assert(xp.xp_exibido == 40 and xp.nivel_atual == 4 and xp.xp_atual == 10)
	assert(resultados.size() == 1)
	xp.mostrar(0,{"novo_bonus":false,"dias":3,"missoes_concluidas":3,"total_missoes":3,"bonus_xp":50})
	xp._continuar()
	await get_tree().create_timer(0.65).timeout
	assert(xp.xp_exibido == 0 and resultados.size() == 2, "Bônus repetido não é anunciado")
	xp.mostrar(200,{"novo_bonus":true,"dias":4,"missoes_concluidas":2,"total_missoes":3,"bonus_xp":20})
	xp._continuar()
	assert(xp.xp_exibido == 200 and xp.nivel_atual == 6 and xp.xp_atual == 10, "Missões incompletas não dão bônus; suporta múltiplos níveis")
	xp.fechar()
	var navio := preload("res://scenes/world/navio_interior.tscn").instantiate()
	add_child(navio)
	var saidas: Array[Dictionary] = []
	navio.finished.connect(func(r: Dictionary): saidas.append(r))
	navio.jogador.position = Vector2(576,445)
	navio.jogador.target = navio.jogador.position
	navio._process(0)
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_E
	tecla.pressed = true
	navio._unhandled_key_input(tecla)
	assert(navio.fala.text.contains("iceberg"))
	navio._sair()
	assert(saidas.size() == 1 and saidas[0].game == "language")
	var mundo := preload("res://scenes/world/lobby.tscn").instantiate()
	add_child(mundo)
	assert(Network.host("Aluno",false,19184) == OK)
	mundo._show_result({"ids":[1,999],"names":["Aluno","Colega"],"winner":0,"feedback":"Vitória!","xp_rewards":[20,0],"xp_before":[0,0]})
	assert(mundo.recompensa_moedas.visible and not mundo.recompensa_xp.visible)
	mundo.recompensa_moedas._continuar()
	mundo.recompensa_moedas._continuar()
	assert(mundo.recompensa_xp.visible, "XP começa após fechar as moedas")
	mundo.recompensa_xp._continuar()
	assert(mundo.recompensa_xp.xp_exibido == 20, "Vitória não inventa um bônus diário")
	Network.leave("")
	assert(not mundo.recompensa_xp.visible and not mundo.xp_pendente and mundo.recompensa_xp.xp_atual == 0)
	print("XP DAILY PASS: daily completion, deduplication, consecutive days, reset, cap, save/load, XP, level-up and ship")
	get_tree().quit(0)
