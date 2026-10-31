class_name Porta
extends Area2D
## Troca de cena quando o urso entra nesta área.
## `ponto` é o nome de um Marker2D dentro de "Pontos" na cena de destino,
## onde o urso vai aparecer.

static var proximo_ponto := ""

@export_file("*.tscn") var destino := ""
@export var ponto := ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and destino != "":
		Porta.proximo_ponto = ponto
		get_tree().call_deferred("change_scene_to_file", destino)
