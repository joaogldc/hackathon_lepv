extends Control
signal exit_requested
const BANK := preload("res://resources/education/bncc_lessons.gd")
const SUBJECTS := {"math":"Matemática","portuguese":"Língua Portuguesa","science":"Ciências"}
const SAVE := "user://education_demo_v1.cfg"
var initial_subject := "math"
var grade := 1
var subject := "math"
var content: VBoxContainer
var profile := ConfigFile.new()
var current: Dictionary={}
var queue: Array=[]
var missed: Array=[]
var supported: Array=[]
var cursor := 0
var score := 0
var reviewing := false
var answered := false
var selected_answer := -1
var show_hint := false
var counters := 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter=Control.MOUSE_FILTER_STOP
	profile.load(SAVE)
	grade=clampi(int(profile.get_value("preferences","grade",1)),1,9)
	subject=initial_subject if SUBJECTS.has(initial_subject) else "math"
	var ui:=Theme.new()
	ui.default_font_size=18
	ui.set_color("font_color","Label",Color("513d2b"))
	for type in ["Button","OptionButton"]:
		var normal:=StyleBoxFlat.new()
		normal.bg_color=Color("259dcb")
		normal.set_corner_radius_all(10)
		normal.set_content_margin_all(10)
		ui.set_stylebox("normal",type,normal)
		var hover: StyleBoxFlat=normal.duplicate()
		hover.bg_color=Color("197fa9")
		ui.set_stylebox("hover",type,hover)
		ui.set_color("font_color",type,Color.WHITE)
	theme=ui
	var background:=ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color=Color("14292e")
	add_child(background)
	var margin:=MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,20)
	add_child(margin)
	var panel:=PanelContainer.new()
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("fff5dc")
	style.set_corner_radius_all(20)
	style.set_content_margin_all(22)
	panel.add_theme_stylebox_override("panel",style)
	margin.add_child(panel)
	var scroll:=ScrollContainer.new()
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	content=VBoxContainer.new()
	content.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",16)
	scroll.add_child(content)
	_home()

func _clear(title: String) -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	var heading:=HBoxContainer.new()
	content.add_child(heading)
	var name:=Label.new()
	name.text=title
	name.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	name.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	name.add_theme_font_size_override("font_size",28)
	heading.add_child(name)
	var close:=Button.new()
	close.text="Voltar ao mundo"
	close.pressed.connect(_close)
	heading.add_child(close)

func _text(value: String, font_size:=20) -> Label:
	var label:=Label.new()
	label.text=value
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	content.add_child(label)
	return label

func _button(caption: String, action: Callable) -> Button:
	var button:=Button.new()
	button.custom_minimum_size.y=74 if caption.length()>65 else 50
	var label:=Label.new()
	label.text=caption
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_left=12
	label.offset_right=-12
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color",Color.WHITE)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
	button.pressed.connect(action)
	content.add_child(button)
	return button

func _home() -> void:
	_clear("Academia dos Ursos • demo educacional")
	_text("Escolha seu ano e uma trilha. Leia, experimente, explique e revise. Não há cronômetro nem perda de energia.")
	var selectors:=HBoxContainer.new()
	content.add_child(selectors)
	var years:=OptionButton.new()
	for year in range(1,10): years.add_item(str(year)+"º ano",year)
	years.select(grade-1)
	years.item_selected.connect(func(index: int): grade=index+1; _home())
	selectors.add_child(years)
	var subjects:=OptionButton.new()
	for key in SUBJECTS: subjects.add_item(SUBJECTS[key])
	subjects.select(SUBJECTS.keys().find(subject))
	subjects.item_selected.connect(func(index: int): subject=SUBJECTS.keys()[index]; _home())
	selectors.add_child(subjects)
	if grade<=2: _text("Pode pedir a um adulto para ler os enunciados. Use objetos, desenhos e a ferramenta de contagem para pensar junto.",18)
	for entry in BANK.LESSONS:
		if int(entry.grade)!=grade or entry.subject!=subject: continue
		var saved: Dictionary=profile.get_value("lessons",entry.id,{})
		var label: String=entry.title+" • "+entry.skill
		if not saved.is_empty(): label+=" • melhor rodada: %d/3" % int(saved.get("best",0))
		_button(label,_intro.bind(entry))
	_text("30 trilhas / 90 questões autorais nesta demo. Cada trilha é um recorte de prática; não representa a cobertura completa do ano ou da habilidade.",16)
	_button("Caderno de prática",_notebook)
	_button("Outros componentes e próximos módulos",_roadmap)

func _intro(entry: Dictionary) -> void:
	current=entry.duplicate(true)
	_clear("%dº ano • %s • %s" % [grade,SUBJECTS[subject],current.title])
	_text("Referência: %s • faixa da habilidade: %s • PDF, p. %d" % [current.skill,current.band,current.source_page],16)
	_text(current.intro,24)
	_text("Como praticar: leia a situação, escolha uma resposta e compare sua estratégia com a explicação. A dica é uma forma de apoio; depois você poderá rever o que errou.")
	_button("Começar a prática",_start)
	_button("Escolher outra trilha",_home)

func _start() -> void:
	queue=range(current.questions.size())
	missed=[]
	supported=[]
	score=0
	cursor=0
	reviewing=false
	_reset_question()

func _reset_question() -> void:
	answered=false
	selected_answer=-1
	show_hint=false
	counters=0
	_question_view()

func _question_view() -> void:
	var item: Dictionary=current.questions[int(queue[cursor])]
	_clear(current.title+" • "+("revisão" if reviewing else "prática"))
	_text("%dº ano • %s • questão %d/%d • %s" % [grade,SUBJECTS[subject],cursor+1,queue.size(),current.skill],16)
	if not str(item.reading).is_empty(): _text(item.reading,26 if grade<=2 else 22)
	_text(item.prompt,26 if grade<=2 else 23)
	if not answered:
		var order: Array=range(item.answers.size())
		order.shuffle()
		for index in order: _button(str(item.answers[index]),_answer.bind(int(index)))
		_button("Ler uma dica",_hint)
		if show_hint: _text("Dica: "+item.hint,20)
		if subject=="math" and grade<=5: _counter_tool()
		_button("Reler a explicação da trilha",func(): _text(current.intro,20))
	else:
		_text("Sua resposta confere." if selected_answer==int(item.correct) else "Vamos rever a ideia.",24)
		_text("Resposta de referência: "+str(item.answers[int(item.correct)]))
		_text(item.why,22)
		_text("Converse ou registre: como você chegou à resposta? Que pista ou estratégia ajudou?",18)
		var reflection:=TextEdit.new()
		reflection.placeholder_text="Rascunho opcional — fica só nesta tela e não é avaliado automaticamente."
		reflection.custom_minimum_size.y=80
		content.add_child(reflection)
		_button("Continuar",_next)

func _counter_tool() -> void:
	_text("Material de apoio: conte, junte ou retire marcas.",17)
	var count:=_text("Marcas: 0",20)
	var row:=HBoxContainer.new()
	content.add_child(row)
	for amount in [-1,1,10]:
		var button:=Button.new()
		button.text="+"+str(amount) if amount>0 else str(amount)
		button.custom_minimum_size=Vector2(70,42)
		button.pressed.connect(func():
			counters=clampi(counters+amount,0,100)
			count.text="Marcas: %d\n%s" % [counters,"● ".repeat(counters)])
		row.add_child(button)

func _hint() -> void:
	show_hint=true
	if not supported.has(queue[cursor]): supported.append(queue[cursor])
	_question_view()

func _answer(index: int) -> void:
	if answered: return
	answered=true
	selected_answer=index
	var item: Dictionary=current.questions[int(queue[cursor])]
	if index==int(item.correct):
		if not reviewing: score+=1
	elif not missed.has(queue[cursor]): missed.append(queue[cursor])
	_question_view()

func _next() -> void:
	cursor+=1
	if cursor<queue.size(): _reset_question()
	else: _result()

func _result() -> void:
	if not reviewing:
		var saved: Dictionary=profile.get_value("lessons",current.id,{})
		profile.set_value("lessons",current.id,{"best":maxi(score,int(saved.get("best",0))),"rounds":int(saved.get("rounds",0))+1,"last_score":score,"support":supported.size()})
		profile.set_value("preferences","grade",grade)
	_clear("Seu caderno de prática")
	_text("Rodada inicial: %d de %d respostas conferem com a referência." % [score,current.questions.size()],24)
	_text("Apoio por dica: %d questão(ões). Esse registro descreve esta prática, não comprova domínio da habilidade." % supported.size(),18)
	if profile.save(SAVE)!=OK: _text("Não foi possível salvar o caderno neste computador. Você ainda pode continuar a prática.",18)
	if missed.is_empty(): _text("Revisão encerrada. Explique uma estratégia com suas palavras ou tente outra trilha.")
	else: _button("Rever %d questão(ões) com explicação" % missed.size(),_review)
	_button("Praticar a trilha inteira de novo",_start)
	_button("Escolher ano e conteúdo",_home)

func _review() -> void:
	queue=missed.duplicate()
	missed.clear()
	reviewing=true
	cursor=0
	_reset_question()

func _notebook() -> void:
	_clear("Caderno • registros neste computador")
	var found:=false
	for entry in BANK.LESSONS:
		var saved: Dictionary=profile.get_value("lessons",entry.id,{})
		if saved.is_empty(): continue
		found=true
		_text("%dº • %s • %s: melhor %d/3; %d rodada(s); última rodada %d/3, apoio em %d questão(ões)." % [int(entry.grade),SUBJECTS[entry.subject],entry.title,int(saved.best),int(saved.rounds),int(saved.last_score),int(saved.support)],18)
	if not found: _text("Pratique uma trilha para começar seu caderno.")
	_text("Os registros desta demo são locais, separados das moedas e do progresso multiplayer. Não incluem nome, escola ou respostas do rascunho.",16)
	_button("Voltar às trilhas",_home)

func _roadmap() -> void:
	_clear("Próximos componentes • ainda sem atividades nesta demo")
	_text("História e Geografia: fontes, memórias, lugares e investigação do território.\nArte: criação, apreciação e discussão de produções.\nEducação Física: jogos cooperativos e práticas corporais, além da tela.\nLíngua Inglesa: trilhas para os anos finais (6º ao 9º).\nEnsino Religioso: diversidade e respeito, sem coletar crenças pessoais.")
	_text("Leitura, escrita, oralidade, investigação e produção não se resumem a múltipla escolha. Os próximos módulos precisam incluir criações e mediação do professor.")
	_text("A BNCC orienta currículos. A sequência desta demo é uma proposta de organização do jogo e deve ser adaptada ao currículo da rede e à turma.",18)
	_button("Voltar às trilhas",_home)

func _close() -> void:
	if exit_requested.get_connections().is_empty(): get_tree().change_scene_to_file("res://scenes/world/lobby.tscn")
	else: exit_requested.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()
