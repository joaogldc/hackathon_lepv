extends Control
## Painel independente: dados locais já recebidos do servidor via Progress.view.
## Não depende de autoload novo e não modifica as cenas existentes.
const BG := Color("#eaf4f3")
const INK := Color("#254b53")
const ACCENT := Color("#259dcb")
const GOOD := Color("#23836a")
const WARN := Color("#c07a35")

var _root: VBoxContainer
var _summary: Label
var _subject_rows: VBoxContainer
var _stats_rows: VBoxContainer
var _notice: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = BG
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 32)
	scroll.add_child(margin)
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 16)
	margin.add_child(_root)
	var heading := HBoxContainer.new()
	_root.add_child(heading)
	var title := Label.new()
	title.text = "Meu progresso"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", INK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	var close := Button.new()
	close.text = "Fechar"
	close.pressed.connect(func() -> void: hide())
	heading.add_child(close)
	_notice = _label("", 15)
	_root.add_child(_notice)
	_summary = _label("", 22)
	_root.add_child(_summary)
	_root.add_child(_label("Desempenho por matéria", 22))
	_subject_rows = VBoxContainer.new()
	_root.add_child(_subject_rows)
	_root.add_child(_label("Atividades registradas", 22))
	_stats_rows = VBoxContainer.new()
	_root.add_child(_stats_rows)
	if Progress.has_signal("changed"):
		Progress.changed.connect(refresh)
	Network.roster_changed.connect(refresh)
	refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide()
		get_viewport().set_input_as_handled()

func _label(value: String, size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_color_override("font_color", INK)
	label.add_theme_font_size_override("font_size", size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _clear(container: VBoxContainer) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _line(label_text: String, correct: int, total: int) -> void:
	var row := VBoxContainer.new()
	_subject_rows.add_child(row)
	var percent := 0.0 if total == 0 else 100.0 * float(correct) / float(total)
	row.add_child(_label("%s — %d/%d (%0.1f%%)" % [label_text, correct, total, percent], 17))
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 22
	bar.max_value = 100.0
	bar.value = percent
	bar.show_percentage = false
	row.add_child(bar)

func refresh() -> void:
	if not is_instance_valid(_summary):
		return
	var profile: Dictionary = Progress.view
	var stats: Dictionary = profile.get("stats", {})
	var math_correct := int(stats.get("math_correct", 0))
	var reading_correct := int(stats.get("reading_correct", 0))
	var science_correct := int(stats.get("science_correct", 0))
	var correct_total := math_correct + reading_correct + science_correct
	_summary.text = "Nível %d  •  %d XP  •  %d respostas corretas  •  sequência: %d" % [int(profile.get("level", 1)), int(profile.get("xp", 0)), correct_total, int(profile.get("streak", 0))]
	_notice.text = "Indicadores disponíveis no progresso do servidor. O jogo atual não publica o total de tentativas ou tempo de resposta; portanto, não é possível calcular uma taxa de acerto confiável aqui."
	_clear(_subject_rows)
	_subject_rows.add_child(_label("Matemática: %d acertos" % math_correct, 18))
	_subject_rows.add_child(_label("Português: %d acertos" % reading_correct, 18))
	_subject_rows.add_child(_label("Ciências: %d acertos" % science_correct, 18))
	_clear(_stats_rows)
	var keys: Array = stats.keys()
	keys.sort()
	if keys.is_empty():
		_stats_rows.add_child(_label("Jogue um desafio para acompanhar seu progresso!", 17))
	for key in keys:
		_stats_rows.add_child(_label("%s: %d" % [str(key).replace("_", " ").capitalize(), int(stats[key])], 16))
