extends CanvasLayer
signal animacao_concluida(resultado: Dictionary)
signal fechada
const GOTA := preload("res://assets/ui/recompensas/gota_mel.svg")
@export_category("XP")
@export_range(0, 1000000, 1) var xp_ganho: int = 20
@export_range(0, 1000000, 1) var xp_atual: int = 70
@export_range(1, 1000000, 1) var xp_por_nivel: int = 100
@export_range(1, 10000, 1) var nivel_atual: int = 3
@export_category("Mel e sequência diária")
@export var exibir_bonus_diario: bool = true
@export_range(0, 3650, 1) var dias_sequencia: int = 4
@export_range(0, 100000, 1) var bonus_xp_diario: int = 20
@export_range(0, 100, 1) var missoes_concluidas: int = 3
@export_range(1, 100, 1) var total_missoes: int = 3
@export_category("Animação")
@export_range(0.5, 8, 0.1, "suffix:s") var duracao_animacao: float = 2.8
@export var reproduzir_ao_iniciar: bool = false
@onready var painel: Panel = $Tela/Painel
@onready var fundo: ColorRect = $Tela/Fundo
@onready var botao: Button = $Tela/Painel/Continuar
@onready var pote: TextureProgressBar = $Tela/Painel/Diarias/Mel
var em_animacao := false
var xp_exibido := 0
var _base := 0
var _bonus := 0
var _xp_inicio := 0
var _nivel_inicio := 1
var _dias := 0
var _escala := 1.0
var _xp_configurado := 0
var _nivel_configurado := 1
var _tweens: Array[Tween] = []

func _ready() -> void:
	_xp_configurado = xp_atual
	_nivel_configurado = nivel_atual
	get_viewport().size_changed.connect(_ajustar)
	botao.pressed.connect(_continuar)
	_ajustar()
	hide()
	if reproduzir_ao_iniciar: mostrar.call_deferred()

## dados_diarios é o retorno de SequenciaDiaria.registrar_missao, validado no servidor.
func mostrar(valor: int = -1, dados_diarios: Dictionary = {}) -> void:
	_cancelar()
	_base = xp_ganho if valor == -1 else clampi(valor, 0, 1000000)
	_xp_inicio = xp_atual
	_nivel_inicio = nivel_atual
	_dias = maxi(0, int(dados_diarios.get("dias", dias_sequencia)))
	var feitas := int(dados_diarios.get("missoes_concluidas", missoes_concluidas))
	var total := int(dados_diarios.get("total_missoes", total_missoes))
	var completo := total > 0 and feitas >= total
	var liberar := exibir_bonus_diario if dados_diarios.is_empty() else bool(dados_diarios.get("novo_bonus", false))
	_bonus = maxi(0, int(dados_diarios.get("bonus_xp", bonus_xp_diario))) if completo and liberar else 0
	em_animacao = true
	$Tela/Painel/Titulo.text = "Aprender faz você crescer!"
	$Tela/Painel/Diarias/Sequencia.text = "%d %s de mel" % [_dias, "dia" if _dias == 1 else "dias"]
	$Tela/Painel/Diarias/Missoes.text = "%d/%d missões de hoje" % [feitas, total]
	$Tela/Painel/Diarias/Bonus.text = "+%d XP de bônus" % _bonus if _bonus > 0 else ("Diárias concluídas!" if completo else "Complete as missões de hoje")
	$Tela/Painel/Diarias/Bonus.modulate.a = 0.0
	$Tela/Painel/Diarias/Dias.text = "  ".join(range(1, 8).map(func(dia): return "●" if dia <= mini(_dias, 7) else "○"))
	$Tela/Painel/Diarias/Descricao.text = "Seu mel cresce a cada dia concluído." if _bonus > 0 else "Conclua todas as diárias para manter a sequência."
	pote.value = maxf(0, _dias - 1) / 7.0 * 100.0 if _bonus > 0 else minf(_dias / 7.0 * 100.0, 100)
	$Tela/Painel/Aluno.play("comemorar")
	_atualizar(0)
	show()
	_ajustar()
	fundo.modulate.a = 0
	painel.modulate.a = 0
	painel.scale = Vector2.ONE * _escala * 0.9
	botao.text = "Pular animação"
	var entrada := _novo().set_parallel(true)
	entrada.tween_property(fundo, "modulate:a", 1.0, 0.18)
	entrada.tween_property(painel, "modulate:a", 1.0, 0.2)
	entrada.tween_property(painel, "scale", Vector2.ONE * _escala, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var animacao := _novo()
	animacao.tween_interval(duracao_animacao * 0.15)
	animacao.tween_method(_atualizar, 0.0, float(_base), duracao_animacao * 0.35)
	animacao.tween_callback(func():
		var mel := _novo().set_parallel(true)
		mel.tween_property(pote, "value", minf(_dias / 7.0 * 100.0, 100), duracao_animacao * 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		mel.tween_property($Tela/Painel/Diarias/Bonus, "modulate:a", 1.0, 0.2)
	)
	animacao.tween_method(_atualizar, float(_base), float(_base + _bonus), duracao_animacao * 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animacao.tween_callback(_concluir)
	if _bonus > 0:
		for indice in range(4): _gota(indice)
	botao.grab_focus()

func _gota(indice: int) -> void:
	var gota := Sprite2D.new()
	gota.texture = GOTA
	gota.scale = Vector2.ONE * 0.38
	gota.modulate.a = 0
	$Tela/Painel/Efeitos.add_child(gota)
	var efeito := _novo()
	efeito.tween_interval(duracao_animacao * (0.48 + indice * 0.045))
	efeito.tween_callback(func(): gota.modulate.a = 1)
	efeito.tween_method(func(t: float):
		gota.position = Vector2(640,246).lerp(Vector2(375,398),t) + Vector2(0,-sin(t * PI) * 68)
		gota.rotation = -t * PI / 3
	, 0.0, 1.0, duracao_animacao * 0.22)
	efeito.tween_callback(gota.queue_free)

func _atualizar(valor: float) -> void:
	xp_exibido = roundi(valor)
	var acumulado := _xp_inicio + xp_exibido
	var nivel := _nivel_inicio + int(acumulado / xp_por_nivel)
	$Tela/Painel/Valor.text = "+%d XP" % xp_exibido
	$Tela/Painel/Progresso.value = float(acumulado % xp_por_nivel) / xp_por_nivel * 100.0
	$Tela/Painel/Nivel.text = "NÍVEL %d" % nivel
	$Tela/Painel/Meta.text = "%d / %d XP" % [acumulado % xp_por_nivel, xp_por_nivel]
	if nivel > _nivel_inicio: $Tela/Painel/Titulo.text = "Você subiu de nível!"

func _concluir() -> void:
	if not em_animacao: return
	em_animacao = false
	_atualizar(_base + _bonus)
	xp_atual = (_xp_inicio + _base + _bonus) % xp_por_nivel
	nivel_atual = _nivel_inicio + int((_xp_inicio + _base + _bonus) / xp_por_nivel)
	fundo.modulate.a = 1
	painel.modulate.a = 1
	painel.scale = Vector2.ONE * _escala
	pote.value = minf(_dias / 7.0 * 100.0, 100)
	$Tela/Painel/Diarias/Bonus.modulate.a = 1
	$Tela/Painel/Aluno.play("repouso")
	botao.text = "Continuar"
	animacao_concluida.emit({"xp_base": _base, "bonus_xp": _bonus, "xp_total": _base + _bonus, "nivel": nivel_atual, "xp_atual": xp_atual})

func _continuar() -> void:
	if em_animacao:
		_cancelar()
		_concluir()
	else: fechar()

func fechar() -> void:
	var aberta := visible
	_cancelar()
	em_animacao = false
	hide()
	if aberta: fechada.emit()

func reiniciar_sessao() -> void:
	fechar()
	xp_atual = _xp_configurado
	nivel_atual = _nivel_configurado

func _novo() -> Tween:
	var animacao := create_tween()
	_tweens.append(animacao)
	return animacao

func _cancelar() -> void:
	for animacao in _tweens:
		if animacao.is_valid(): animacao.kill()
	_tweens.clear()
	for efeito in $Tela/Painel/Efeitos.get_children():
		efeito.hide()
		efeito.queue_free()

func _ajustar() -> void:
	var tamanho := get_viewport().get_visible_rect().size
	_escala = maxf(0.1, minf(1.0, minf((tamanho.x - 32) / 860.0, (tamanho.y - 32) / 540.0)))
	painel.pivot_offset = painel.size / 2
	painel.position = (tamanho - painel.size) / 2
	painel.scale = Vector2.ONE * _escala

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_continuar()
