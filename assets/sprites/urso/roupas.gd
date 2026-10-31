@tool
extends Node2D
## Roupas do urso. Fica dentro do AnimatedSprite2D do urso e copia a animação dele.
## Escolha a roupa e a cor no Inspetor; o resultado aparece no editor também.
## As camadas "Cor" são cinza e são tingidas pela cor escolhida (self_modulate).
## As camadas "Detalhe" (camisa branca, gravata, botões, faixa do chapéu) não mudam de cor.

@export_enum("Nenhuma", "Camisa", "Terno") var roupa := 0:
	set(v):
		roupa = v
		_atualizar()
@export var cor_roupa := Color("e9453a"):
	set(v):
		cor_roupa = v
		_atualizar()
@export_enum("Nenhum", "Chapéu", "Touca") var chapeu := 0:
	set(v):
		chapeu = v
		_atualizar()
@export var cor_chapeu := Color("2b2b2b"):
	set(v):
		cor_chapeu = v
		_atualizar()

const CORES_SUGERIDAS := {
	"vermelho": Color("e9453a"), "azul": Color("45b3e6"), "azul_marinho": Color("2c3e6b"),
	"verde": Color("7cc34f"), "amarelo": Color("f6c945"), "roxo": Color("9b6fc7"),
	"rosa": Color("e84f8c"), "cinza": Color("7a7a85"), "preto": Color("2b2b2b"),
	"vinho": Color("8e3a35"), "palha": Color("d9c27a"), "branco": Color("f4f4f4"),
}

var _camadas := {}

func _ready() -> void:
	for n in ["CamisaCor", "TernoCor", "TernoDetalhe", "ChapeuCor", "ChapeuDetalhe", "ToucaCor"]:
		_camadas[n] = get_node_or_null(n)
	_atualizar()

func _atualizar() -> void:
	if _camadas.is_empty():
		return
	_mostrar("CamisaCor", roupa == 1, cor_roupa)
	_mostrar("TernoCor", roupa == 2, cor_roupa)
	_mostrar("TernoDetalhe", roupa == 2, Color.WHITE)
	_mostrar("ChapeuCor", chapeu == 1, cor_chapeu)
	_mostrar("ChapeuDetalhe", chapeu == 1, Color.WHITE)
	_mostrar("ToucaCor", chapeu == 2, cor_chapeu)

func _mostrar(nome: String, ligado: bool, cor: Color) -> void:
	var c: AnimatedSprite2D = _camadas.get(nome)
	if c:
		c.visible = ligado
		c.self_modulate = cor

## Atalho para trocar tudo de uma vez pelo código, ex.: vestir(2, Color.NAVY_BLUE, 1, Color.BLACK)
func vestir(nova_roupa: int, nova_cor_roupa: Color, novo_chapeu: int, nova_cor_chapeu: Color) -> void:
	roupa = nova_roupa
	cor_roupa = nova_cor_roupa
	chapeu = novo_chapeu
	cor_chapeu = nova_cor_chapeu

func _process(_delta: float) -> void:
	var urso := get_parent() as AnimatedSprite2D
	if urso == null:
		return
	for c in _camadas.values():
		if c and c.visible:
			if c.animation != urso.animation and c.sprite_frames.has_animation(urso.animation):
				c.animation = urso.animation
			c.frame = urso.frame
			c.flip_h = urso.flip_h
			c.offset = urso.offset
