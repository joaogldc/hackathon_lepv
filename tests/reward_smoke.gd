extends Node
var conclusoes: Array[int] = []

func _ready() -> void:
	var cena := preload("res://scenes/ui/recompensa_moedas.tscn")
	var recompensa := cena.instantiate()
	recompensa.reproduzir_ao_iniciar = false
	recompensa.quantidade_moedas = 125
	recompensa.duracao_animacao = 0.5
	add_child(recompensa)
	recompensa.animacao_concluida.connect(func(valor: int): conclusoes.append(valor))
	assert(not recompensa.visible, "A instância do jogo aguarda um resultado")
	recompensa.mostrar()
	await get_tree().create_timer(0.7).timeout
	assert(recompensa.valor_exibido == 125 and conclusoes == [125], "Respeita o valor do Inspetor")
	recompensa.fechar()
	recompensa.mostrar(0)
	await get_tree().create_timer(0.7).timeout
	assert(recompensa.valor_exibido == 0 and conclusoes == [125, 0], "Zero é um valor válido")
	assert(recompensa.quantidade_moedas == 125, "Override não altera a configuração")
	recompensa.mostrar(999)
	recompensa._continuar()
	await get_tree().create_timer(0.7).timeout
	assert(recompensa.valor_exibido == 999 and conclusoes == [125, 0, 999], "Pular conclui exatamente uma vez")
	assert(recompensa.painel.modulate.a == 1.0, "Pular a entrada revela o painel completo")
	recompensa._continuar()
	assert(not recompensa.visible)
	recompensa.mostrar(500)
	recompensa.mostrar(7)
	await get_tree().create_timer(0.7).timeout
	assert(recompensa.valor_exibido == 7 and conclusoes == [125, 0, 999, 7], "Reabrir cancela os efeitos anteriores")
	recompensa.fechar()
	var mundo := preload("res://scenes/world/lobby.tscn").instantiate()
	add_child(mundo)
	var id := multiplayer.get_unique_id()
	var resultado := {"ids": [id, 999], "names": ["Aluno", "Colega"], "winner": 0, "feedback": "Aluno venceu!"}
	mundo._show_result(resultado)
	assert(mundo.recompensa_moedas.visible, "Vitória abre a recompensa")
	mundo._set_zone("dojo")
	var saidas: Array[bool] = []
	mundo.game_view.finished.connect(func(_resultado: Dictionary): saidas.append(true))
	var escapar := InputEventKey.new()
	escapar.physical_keycode = KEY_ESCAPE
	escapar.keycode = KEY_ESCAPE
	escapar.pressed = true
	Input.parse_input_event(escapar)
	await get_tree().process_frame
	assert(saidas.is_empty(), "Esc é consumido pela recompensa, sem sair do minigame")
	assert(mundo.recompensa_moedas.visible and not mundo.recompensa_moedas.em_animacao)
	mundo.recompensa_moedas.fechar()
	resultado.winner = 1
	mundo._show_result(resultado)
	assert(not mundo.recompensa_moedas.visible and mundo.result_dialog.visible, "Derrota mantém seu resultado")
	mundo.result_dialog.hide()
	resultado.winner = -1
	mundo._show_result(resultado)
	assert(not mundo.recompensa_moedas.visible, "Empate não anuncia moedas de vitória")
	print("REWARD PASS: Inspector amount, zero, override, skip, replay and winner integration")
	get_tree().quit(0)
