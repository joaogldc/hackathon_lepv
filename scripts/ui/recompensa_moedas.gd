extends CanvasLayer
## Apresentação reutilizável. O valor animado não altera saldo ou inventário.
signal animacao_concluida(valor: int)
signal fechada

@export_category("Recompensa")
## Valor usado por mostrar() quando o minigame não informa outro valor.
@export_range(0, 1000000, 1) var quantidade_moedas: int = 25
@export var titulo: String = "Você venceu!"
@export var mensagem: String = "Cada descoberta leva você mais longe."
@export_category("Animação")
@export_range(0.5, 8.0, 0.1, "suffix:s") var duracao_animacao: float = 2.4
## Permite testar esta cena sozinha com F6. Desativado na instância do mundo.
@export var reproduzir_ao_iniciar: bool = false
@export var permitir_pular: bool = true

const MOEDA := preload("res://assets/ui/recompensas/moeda.svg")
const BRILHO := preload("res://assets/ui/recompensas/brilho.svg")
@onready var fundo: ColorRect = $Tela/Fundo
@onready var painel: Panel = $Tela/Painel
@onready var rotulo_valor: Label = $Tela/Painel/Valor
@onready var botao: Button = $Tela/Painel/Continuar
@onready var aluno: AnimatedSprite2D = $Tela/Painel/Aluno
@onready var bolsa: TextureRect = $Tela/Painel/Bolsa
@onready var efeitos: Control = $Tela/Painel/Efeitos
var valor_exibido: int = 0
var em_animacao: bool = false
var _valor_alvo: int = 0
var _animacoes: Array[Tween] = []
var _escala_painel := 1.0

func _ready() -> void:
	get_viewport().size_changed.connect(_ajustar_tamanho)
	botao.pressed.connect(_continuar)
	_ajustar_tamanho()
	hide()
	if reproduzir_ao_iniciar:
		mostrar.call_deferred()

## Um valor >= 0 substitui a configuração só nesta apresentação, inclusive zero.
func mostrar(valor: int = -1, nome_aluno: String = "") -> void:
	_cancelar_animacoes()
	_valor_alvo = quantidade_moedas if valor == -1 else clampi(valor, 0, 1000000)
	em_animacao = true
	$Tela/Painel/Titulo.text = titulo
	$Tela/Painel/Mensagem.text = mensagem if nome_aluno.is_empty() else "Boa, %s! %s" % [nome_aluno, mensagem]
	_atualizar_valor(0)
	botao.text = "Pular animação" if permitir_pular else "Recebendo…"
	botao.disabled = not permitir_pular
	aluno.play("comemorar")
	bolsa.scale = Vector2.ONE
	show()
	_ajustar_tamanho()
	fundo.modulate.a = 0.0
	painel.modulate.a = 0.0
	painel.scale = Vector2.ONE * _escala_painel * 0.88
	var entrada := _novo_tween().set_parallel(true)
	entrada.tween_property(fundo, "modulate:a", 1.0, 0.2)
	entrada.tween_property(painel, "modulate:a", 1.0, 0.2)
	entrada.tween_property(painel, "scale", Vector2.ONE * _escala_painel, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var contar := _novo_tween()
	contar.tween_interval(duracao_animacao * 0.18)
	contar.tween_method(_atualizar_valor, 0.0, float(_valor_alvo), duracao_animacao * 0.72).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	contar.tween_callback(_concluir)
	var quantidade_visual := clampi(_valor_alvo, 4, 14) if _valor_alvo > 0 else 0
	for indice in range(quantidade_visual):
		_voar_moeda(indice, quantidade_visual)
	for indice in range(7):
		_brilhar(indice)
	botao.grab_focus()

func _voar_moeda(indice: int, total: int) -> void:
	var moeda := Sprite2D.new()
	moeda.texture = MOEDA
	moeda.scale = Vector2.ONE * 0.40
	moeda.modulate.a = 0.0
	efeitos.add_child(moeda)
	var origem := Vector2(244, 233) + Vector2((indice % 3) * 10, (indice % 2) * 8)
	var destino := Vector2(555, 326)
	var altura := 100.0 + (indice % 4) * 15.0
	var animacao := _novo_tween()
	animacao.tween_interval(duracao_animacao * (0.12 + float(indice) / maxf(total, 1) * 0.45))
	animacao.tween_callback(func(): moeda.modulate.a = 1.0)
	animacao.tween_method(func(progresso: float):
		moeda.position = origem.lerp(destino, progresso) + Vector2(0, -sin(progresso * PI) * altura)
		moeda.rotation = progresso * TAU
		moeda.scale = Vector2(0.40 * (0.45 + absf(cos(progresso * TAU)) * 0.55), 0.40)
	, 0.0, 1.0, duracao_animacao * 0.32)
	animacao.tween_callback(func():
		moeda.hide()
		bolsa.scale = Vector2(1.07, 0.94)
	)
	animacao.tween_property(bolsa, "scale", Vector2.ONE, 0.12)
	animacao.tween_callback(moeda.queue_free)

func _brilhar(indice: int) -> void:
	var brilho := Sprite2D.new()
	brilho.texture = BRILHO
	brilho.position = [Vector2(106, 186),Vector2(290, 153),Vector2(330, 268),Vector2(651, 205),Vector2(640, 337),Vector2(106, 318),Vector2(387, 177)][indice]
	brilho.scale = Vector2.ZERO
	efeitos.add_child(brilho)
	var animacao := _novo_tween()
	animacao.tween_interval(duracao_animacao * 0.12 + indice * 0.09)
	animacao.tween_property(brilho, "scale", Vector2.ONE * (0.40 if indice % 2 == 0 else 0.6), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animacao.tween_interval(duracao_animacao * 0.34)
	animacao.tween_property(brilho, "scale", Vector2.ZERO, 0.25)
	animacao.tween_callback(brilho.queue_free)

func _atualizar_valor(valor: float) -> void:
	valor_exibido = roundi(valor)
	rotulo_valor.text = "+%d" % valor_exibido

func _concluir() -> void:
	if not em_animacao:
		return
	em_animacao = false
	_atualizar_valor(_valor_alvo)
	fundo.modulate.a = 1.0
	painel.modulate.a = 1.0
	painel.scale = Vector2.ONE * _escala_painel
	botao.text = "Continuar"
	botao.disabled = false
	aluno.play("repouso")
	animacao_concluida.emit(_valor_alvo)

func _continuar() -> void:
	if em_animacao:
		if not permitir_pular:
			return
		_cancelar_animacoes()
		_concluir()
	else:
		fechar()

func fechar() -> void:
	var estava_visivel := visible
	_cancelar_animacoes()
	em_animacao = false
	aluno.stop()
	hide()
	if estava_visivel:
		fechada.emit()

func _novo_tween() -> Tween:
	var animacao := create_tween()
	_animacoes.append(animacao)
	return animacao

func _cancelar_animacoes() -> void:
	for animacao in _animacoes:
		if animacao.is_valid():
			animacao.kill()
	_animacoes.clear()
	for efeito in efeitos.get_children():
		efeito.hide()
		efeito.queue_free()
	bolsa.scale = Vector2.ONE

func _ajustar_tamanho() -> void:
	var tamanho := get_viewport().get_visible_rect().size
	_escala_painel = minf(1.0, minf((tamanho.x - 32.0) / 760.0, (tamanho.y - 32.0) / 500.0))
	_escala_painel = maxf(0.1, _escala_painel)
	painel.pivot_offset = painel.size / 2.0
	painel.position = (tamanho - painel.size) / 2.0
	painel.scale = Vector2.ONE * _escala_painel

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_continuar()
