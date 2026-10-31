extends Control
## Painel isolado. SEM acesso a perfis reais: não existem turmas/papéis autenticados.
## Apenas dados fictícios locais; não expõe o snapshot público de Network.players.
const BG := Color("#eaf4f3")
const INK := Color("#254b53")

var _list: VBoxContainer
var _notice: Label
var _students: Array[Dictionary] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 28)
	scroll.add_child(margin)
	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 12)
	margin.add_child(main)
	var header := HBoxContainer.new()
	main.add_child(header)
	var title := _label("Painel do professor — demonstração", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close := Button.new()
	close.text = "Fechar"
	close.pressed.connect(func() -> void: hide())
	header.add_child(close)
	_notice = _label("Somente dados fictícios. O repositório atual não possui autenticação de professores, vínculo aluno–turma ou API de agregação autorizada. Nenhum dado real de jogadores é lido.", 16)
	main.add_child(_notice)
	var sample := Button.new()
	sample.text = "Gerar 15 alunos fictícios"
	sample.pressed.connect(_populate_demo)
	main.add_child(sample)
	_list = VBoxContainer.new()
	main.add_child(_list)
	_list.add_child(_label("Nenhuma turma real conectada.", 18))

func _label(content: String, size: int) -> Label:
	var label := Label.new()
	label.text = content
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", INK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _populate_demo() -> void:
	_students.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261031
	for index in range(15):
		var total := rng.randi_range(15, 70)
		var correct := rng.randi_range(0, total)
		_students.append({"name": "Aluno fictício %02d" % [index + 1], "total": total, "correct": correct})
	_render()

func _render() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	var attempts := 0
	var successes := 0
	for entry in _students:
		attempts += int(entry.total)
		successes += int(entry.correct)
	var rate := 0.0 if attempts == 0 else 100.0 * float(successes) / float(attempts)
	_list.add_child(_label("Turma simulada: %d alunos  •  %d respostas  •  %.1f%% acertos" % [_students.size(), attempts, rate], 20))
	for entry in _students:
		var fraction := 100.0 * float(entry.correct) / float(entry.total)
		_list.add_child(_label("%s  •  %d/%d acertos (%.1f%%)" % [entry.name, entry.correct, entry.total, fraction], 17))
