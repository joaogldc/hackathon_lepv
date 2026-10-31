extends Node2D
## Coloca o urso no ponto de chegada definido pela última porta usada.

func _ready() -> void:
	var p := Porta.proximo_ponto
	if p != "" and has_node("Pontos/" + p) and has_node("Objetos/Urso"):
		$Objetos/Urso.position = get_node("Pontos/" + p).position
	Porta.proximo_ponto = ""
