@tool
extends Node2D
## Vitrine de loja.
## Arraste as texturas dos produtos da semana para a lista "produtos" no Inspetor.
## Eles aparecem nas prateleiras na ordem dos espaços: 3 em cima e 3 embaixo.
## Para deixar um espaço vazio, deixe aquele item da lista sem textura.

@export var produtos: Array[Texture2D] = []:
	set(valor):
		produtos = valor
		_montar()

## Tamanho máximo (em pixels) de cada produto na prateleira.
@export var tamanho_max := 44.0:
	set(valor):
		tamanho_max = valor
		_montar()

func _ready() -> void:
	_montar()

func _montar() -> void:
	if not is_inside_tree():
		return
	var espacos := get_node_or_null("Espacos")
	if espacos == null:
		return
	for espaco in espacos.get_children():
		for antigo in espaco.get_children():
			antigo.queue_free()
	for i in range(min(produtos.size(), espacos.get_child_count())):
		var tex := produtos[i]
		if tex == null:
			continue
		var s := Sprite2D.new()
		s.texture = tex
		var k := tamanho_max / float(max(tex.get_width(), tex.get_height()))
		s.scale = Vector2(k, k)
		s.offset = Vector2(0, -tex.get_height() / 2.0)
		espacos.get_child(i).add_child(s)
