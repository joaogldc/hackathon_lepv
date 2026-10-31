extends Area2D
## Banco onde o urso pode sentar. Coloque este Area2D na base do banco.
## `assentos` são as posições X (relativas ao banco) de cada lugar.

@export var altura_assento := 44.0
@export var assentos: Array[float] = [-34.0, 34.0]

func _ready() -> void:
	$Dica.visible = false
	body_entered.connect(_entrou)
	body_exited.connect(_saiu)

func _entrou(body: Node) -> void:
	if "banco_proximo" in body:
		body.banco_proximo = self
		$Dica.visible = true

func _saiu(body: Node) -> void:
	if "banco_proximo" in body and body.banco_proximo == self and not body.sentado:
		body.banco_proximo = null
	$Dica.visible = false

func assento_mais_perto(pos: Vector2) -> Vector2:
	var melhor: float = assentos[0]
	for x in assentos:
		if abs(global_position.x + x - pos.x) < abs(global_position.x + melhor - pos.x):
			melhor = x
	# um pouco à frente do banco para o urso ser desenhado na frente dele
	return global_position + Vector2(melhor, 3)
