extends Area2D
## Porta de loja. Com `destino` vazio, mostra um aviso quando o urso chega.
## Quando a cena de dentro da loja existir, coloque ela em `destino`.

@export var nome_loja := "Loja"
@export_file("*.tscn") var destino := ""
@export var ponto := ""

func _ready() -> void:
	$Aviso.visible = false
	body_entered.connect(_entrou)
	body_exited.connect(_saiu)

func _entrou(body: Node) -> void:
	if not body is CharacterBody2D:
		return
	if destino != "":
		Porta.proximo_ponto = ponto
		get_tree().call_deferred("change_scene_to_file", destino)
	else:
		$Aviso.text = nome_loja + "\n(em breve!)"
		$Aviso.visible = true

func _saiu(body: Node) -> void:
	if body is CharacterBody2D:
		$Aviso.visible = false
