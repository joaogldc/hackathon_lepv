extends Resource
## Recebe eventos de missões já validados e a data YYYY-MM-DD do servidor.
## Recurso independente de UI; o perfil deve salvá-lo junto com seus demais dados.
@export var missoes_obrigatorias: PackedStringArray = ["jogar", "acertar", "explorar"]
@export_range(1, 1000, 1) var bonus_por_dia: int = 5
@export_range(1, 10000, 1) var bonus_maximo: int = 50
@export var dias_seguidos: int = 0
@export var ultima_data_concluida: String = ""
@export var data_em_andamento: String = ""
@export var missoes_feitas: PackedStringArray = []

func registrar_missao(id_missao: String, data_servidor: String) -> Dictionary:
	var dia := _dia(data_servidor)
	var ids := _ids_validos()
	if dia < 0 or not ids.has(id_missao):
		return {"aceito": false, "novo_bonus": false, "bonus_xp": 0}
	if (not ultima_data_concluida.is_empty() and data_servidor < ultima_data_concluida) or (not data_em_andamento.is_empty() and data_servidor < data_em_andamento):
		return {"aceito": false, "novo_bonus": false, "bonus_xp": 0}
	if data_em_andamento != data_servidor:
		data_em_andamento = data_servidor
		missoes_feitas = []
	if not missoes_feitas.has(id_missao):
		missoes_feitas.append(id_missao)
	var resultado := consultar(data_servidor)
	resultado.aceito = true
	if missoes_feitas.size() != ids.size() or ultima_data_concluida == data_servidor:
		return resultado
	var anterior := _dia(ultima_data_concluida)
	dias_seguidos = dias_seguidos + 1 if anterior >= 0 and dia - anterior == 86400 else 1
	ultima_data_concluida = data_servidor
	resultado = consultar(data_servidor)
	resultado.aceito = true
	resultado.novo_bonus = true
	resultado.bonus_xp = mini(dias_seguidos * bonus_por_dia, bonus_maximo)
	resultado.id_recompensa = "diarias/" + data_servidor
	return resultado

func consultar(data_servidor: String) -> Dictionary:
	var dia := _dia(data_servidor)
	var anterior := _dia(ultima_data_concluida)
	var sequencia := dias_seguidos
	if dia >= 0 and anterior >= 0 and dia - anterior > 86400:
		sequencia = 0
	return {"novo_bonus": false, "bonus_xp": 0, "dias": sequencia,
		"missoes_concluidas": missoes_feitas.size() if data_em_andamento == data_servidor else 0,
		"total_missoes": _ids_validos().size(), "diarias_concluidas": ultima_data_concluida == data_servidor}

func _ids_validos() -> PackedStringArray:
	var ids: PackedStringArray = []
	for id in missoes_obrigatorias:
		if not id.is_empty() and not ids.has(id): ids.append(id)
	return ids

func _dia(data: String) -> int:
	if data.length() != 10: return -1
	var instante := int(Time.get_unix_time_from_datetime_string(data + "T00:00:00"))
	if Time.get_date_string_from_unix_time(instante) != data: return -1
	return instante
