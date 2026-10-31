extends Control
## A arte não contém textos: destinos, indicação atual e cliques são controles.
signal destination_selected(destination: String)
signal close_requested
@export var imagem_mapa: Texture2D = preload("res://assets/ui/mapa/ilha-ursos-3d.png")
@export var zone: String = "lobby"
const DESTINATIONS := {
	"commerce": {"label":"Vila das lojas", "detail":"Cosméticos e pets", "rect":Rect2(0.35,0.025,0.35,0.27)},
	"math": {"label":"Bosque da Sabedoria", "detail":"Dojo do Bambu", "rect":Rect2(0.055,0.17,0.285,0.31)},
	"science": {"label":"Observatório", "detail":"Foguete de tronco", "rect":Rect2(0.735,0.10,0.235,0.38)},
	"language": {"label":"Porto Glacial", "detail":"Navio e botes", "rect":Rect2(0.30,0.565,0.59,0.36)},
	"lobby": {"label":"Praça dos encontros", "detail":"Encontre os outros ursos", "rect":Rect2(0.39,0.315,0.265,0.27)}
}
var mapa_rect := Rect2()
var cabecalho: Panel
var titulo: Label
var fechar: Button
var legenda: Label
var chips: Dictionary = {}
var _animacoes: Dictionary = {}

static func regiao_principal(destino: String) -> String:
	if destino == "dojo": return "math"
	if destino in ["ship","cave"]: return "language"
	if destino in ["pet_shop","cosmetics_shop","fitting_room","loja_pets","loja_cosmeticos","provador"]: return "commerce"
	return destino

static func centro_regiao(destino: String) -> Vector2:
	var regiao := regiao_principal(destino)
	return DESTINATIONS.get(regiao,DESTINATIONS.lobby).rect.get_center()

func _ready() -> void:
	var id := multiplayer.get_unique_id()
	if Network.players.has(id): zone = Network.players[id].zone
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	cabecalho = Panel.new()
	cabecalho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cabecalho.add_theme_stylebox_override("panel",_estilo(Color("fff5dc"),Color("513d2b"),16))
	add_child(cabecalho)
	titulo = Label.new()
	titulo.text = "ILHA DOS URSOS"
	titulo.add_theme_color_override("font_color",Color("513d2b"))
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(titulo)
	fechar = Button.new()
	fechar.text = "Fechar [M / Esc]"
	fechar.add_theme_stylebox_override("normal",_estilo(Color("259dcb"),Color("175c79"),10))
	fechar.add_theme_stylebox_override("hover",_estilo(Color("38b3dd"),Color("175c79"),10))
	fechar.add_theme_color_override("font_color",Color.WHITE)
	fechar.pressed.connect(_pedir_fechar)
	add_child(fechar)
	legenda = Label.new()
	legenda.text = "Escolha uma região para viajar"
	legenda.add_theme_color_override("font_color",Color("fff5dc"))
	legenda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legenda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(legenda)
	for destino in DESTINATIONS:
		var info: Dictionary = DESTINATIONS[destino]
		var botao := Button.new()
		botao.name = destino
		botao.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		botao.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
		botao.add_theme_stylebox_override("disabled",StyleBoxEmpty.new())
		botao.add_theme_stylebox_override("hover",StyleBoxEmpty.new())
		botao.add_theme_stylebox_override("pressed",StyleBoxEmpty.new())
		botao.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
		var nesta_regiao: bool = destino == regiao_principal(zone)
		botao.disabled = destino == zone
		botao.pressed.connect(_choose.bind(destino))
		botao.mouse_entered.connect(_destacar.bind(destino,true))
		botao.mouse_exited.connect(_destacar.bind(destino,false))
		botao.focus_entered.connect(_destacar.bind(destino,true))
		botao.focus_exited.connect(_destacar.bind(destino,false))
		add_child(botao)
		var chip := PanelContainer.new()
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_theme_stylebox_override("panel",_estilo(Color("d9edc7") if nesta_regiao else Color("fff5dc"),Color("513d2b"),12))
		botao.add_child(chip)
		var texto := Label.new()
		var detalhe: String = ("● Você está aqui" if botao.disabled else "Sair para esta região") if nesta_regiao else str(info.detail)
		texto.text = info.label + "\n" + detalhe
		texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		texto.add_theme_color_override("font_color",Color("513d2b"))
		texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(texto)
		chips[destino] = chip
	resized.connect(_organizar)
	_organizar()

func _estilo(cor: Color, borda: Color, raio: int) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = cor
	estilo.border_color = borda
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(raio)
	return estilo

func _organizar() -> void:
	if not is_instance_valid(cabecalho): return
	var margem := 16.0
	var disponivel := Vector2(maxf(200,size.x-32),maxf(130,size.y-108))
	var fator := minf(disponivel.x/imagem_mapa.get_width(),disponivel.y/imagem_mapa.get_height())
	var tamanho := imagem_mapa.get_size() * fator
	mapa_rect = Rect2(Vector2((size.x-tamanho.x)/2,70+(disponivel.y-tamanho.y)/2),tamanho)
	var escala_ui := clampf(size.x/1152.0,0.65,1.2)
	cabecalho.position = Vector2(margem,10)
	cabecalho.size = Vector2(size.x-32,50)
	titulo.position = Vector2(30,19)
	titulo.size = Vector2(size.x-220,34)
	titulo.add_theme_font_size_override("font_size",roundi(25*escala_ui))
	fechar.position = Vector2(size.x-184,17)
	fechar.size = Vector2(154,36)
	legenda.position = Vector2(0,size.y-30)
	legenda.size = Vector2(size.x,25)
	legenda.add_theme_font_size_override("font_size",roundi(16*escala_ui))
	for destino in DESTINATIONS:
		var info: Dictionary = DESTINATIONS[destino]
		var botao := get_node(NodePath(destino)) as Button
		botao.position = mapa_rect.position + info.rect.position * mapa_rect.size
		botao.size = info.rect.size * mapa_rect.size
		var chip: PanelContainer = chips[destino]
		chip.size = Vector2(205,48) * escala_ui
		chip.position = Vector2((botao.size.x-chip.size.x)/2,botao.size.y-chip.size.y)
		chip.pivot_offset = chip.size/2
		(chip.get_child(0) as Label).add_theme_font_size_override("font_size",roundi(14*escala_ui))
	queue_redraw()

func _choose(destino: String) -> void:
	if destino != zone: destination_selected.emit(destino)

func _destacar(destino: String, ativo: bool) -> void:
	ativo = ativo or (get_node(NodePath(destino)) as Button).has_focus()
	var cor := Color("d9edc7") if destino == regiao_principal(zone) else Color("fff5dc")
	(chips[destino] as PanelContainer).add_theme_stylebox_override("panel",_estilo(cor,Color("e8b338") if ativo else Color("513d2b"),12))
	if _animacoes.has(destino) and _animacoes[destino].is_valid(): _animacoes[destino].kill()
	var animacao := create_tween()
	_animacoes[destino] = animacao
	animacao.tween_property(chips[destino],"scale",Vector2.ONE * (1.04 if ativo else 1.0),0.12)

func _pedir_fechar() -> void:
	if close_requested.get_connections().is_empty(): get_tree().quit()
	else: close_requested.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_M,KEY_ESCAPE]:
		get_viewport().set_input_as_handled()
		_pedir_fechar()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.025,0.09,0.13,0.97))
	if imagem_mapa and mapa_rect.has_area(): draw_texture_rect(imagem_mapa,mapa_rect,false)
