extends Control
signal finished(result: Dictionary)
@export var nome_sala: String = "Salão Ursatlântico"
@export var velocidade: float = 170.0
@export var permitir_movimento: bool = true
const FUNDO := preload("res://assets/cenario/navio_glacial/salao-ursatlantico.png")
const URSO := preload("res://scenes/player/bear.tscn")
const PONTOS := [
	{"ponto": Vector2(260,465), "nome": "Piano", "fala": "Concerto em dó... de mel. O pianista aceita gorjetas em biscoitos."},
	{"ponto": Vector2(576,445), "nome": "Iceberg VIP", "fala": "Primeira classe para o iceberg. Favor não servir gelo deste balde."},
	{"ponto": Vector2(898,465), "nome": "Chá de pato", "fala": "Chá das cinco. O pato chegou às quatro para garantir a banheira."}
]
var jogador: Node2D
var dica: Label
var fala: Label
var proximo := -1
var tempo_fala := 0.0

func _ready() -> void:
	get_viewport().size_changed.connect(_ajustar)
	_ajustar()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	jogador = URSO.instantiate()
	jogador.position = Vector2(576,565)
	jogador.target = jogador.position
	jogador.nickname = "Explorador"
	var rede := get_node_or_null("/root/Network")
	if rede and rede.players.has(multiplayer.get_unique_id()):
		jogador.nickname = rede.players[multiplayer.get_unique_id()].nickname
	add_child(jogador)
	var barra := Panel.new()
	barra.position = Vector2(18,12)
	barra.size = Vector2(1116,58)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("fff5dc")
	estilo.border_color = Color("65472e")
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(12)
	barra.add_theme_stylebox_override("panel",estilo)
	add_child(barra)
	var titulo := Label.new()
	titulo.text = nome_sala
	titulo.position = Vector2(18,10)
	titulo.add_theme_font_size_override("font_size",25)
	titulo.add_theme_color_override("font_color",Color("513d2b"))
	barra.add_child(titulo)
	var ajuda := Label.new()
	ajuda.text = "WASD / setas: andar   •   E: interagir"
	ajuda.position = Vector2(380,19)
	ajuda.add_theme_color_override("font_color",Color("513d2b"))
	barra.add_child(ajuda)
	var sair := Button.new()
	sair.text = "Voltar à praça [Esc]"
	sair.position = Vector2(887,9)
	sair.size = Vector2(210,40)
	sair.pressed.connect(_sair)
	barra.add_child(sair)
	dica = Label.new()
	dica.position = Vector2(270,638)
	dica.size = Vector2(612,30)
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_configurar_texto(dica,19)
	add_child(dica)
	fala = Label.new()
	fala.position = Vector2(140,676)
	fala.size = Vector2(872,40)
	fala.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fala.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_configurar_texto(fala,17)
	add_child(fala)
	queue_redraw()

func _configurar_texto(rotulo: Label, tamanho: int) -> void:
	rotulo.add_theme_font_size_override("font_size",tamanho)
	rotulo.add_theme_color_override("font_color",Color("fff5dc"))
	rotulo.add_theme_color_override("font_outline_color",Color("163746"))
	rotulo.add_theme_constant_override("outline_size",5)

func _process(delta: float) -> void:
	var movimento := Vector2.ZERO
	if permitir_movimento:
		movimento = Vector2(
			float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
			float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).limit_length()
	jogador.target = (jogador.target + movimento * velocidade * delta).clamp(Vector2(240,436),Vector2(912,625))
	if movimento.length_squared() > 0:
		jogador.direction = ("right" if movimento.x > 0 else "left") if absf(movimento.x) > absf(movimento.y) else ("front" if movimento.y > 0 else "back")
	proximo = -1
	for indice in range(PONTOS.size()):
		if jogador.position.distance_to(PONTOS[indice].ponto) < 86:
			proximo = indice
	dica.text = "[E] " + PONTOS[proximo].nome if proximo >= 0 else "Explore o salão e aproxime-se dos objetos."
	tempo_fala = maxf(0,tempo_fala - delta)
	if tempo_fala <= 0: fala.text = ""

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_sair()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E and proximo >= 0 and permitir_movimento:
		fala.text = PONTOS[proximo].fala
		tempo_fala = 7.0
		get_viewport().set_input_as_handled()

func _sair() -> void:
	if finished.get_connections().is_empty(): get_tree().quit()
	else: finished.emit({"game":"language","completed":false,"reason":"left_ship"})

func _return() -> void: _sair()

func _ajustar() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	var viewport := get_viewport_rect().size
	size = Vector2(1152,720)
	var proporcao := minf(viewport.x / 1152.0,viewport.y / 720.0)
	scale = Vector2.ONE * proporcao
	position = (viewport - size * proporcao) / 2

func _draw() -> void:
	draw_texture_rect(FUNDO,Rect2(0,36,1152,648),false)
