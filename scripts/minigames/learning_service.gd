extends Node
signal changed
var sessions: Dictionary={}
var view: Dictionary={}
const READING := [
	["O navio Aurora partiu ao amanhecer. Antes de zarpar, a capitã conferiu as cordas, pois o vento aumentara durante a noite.","Por que a capitã conferiu as cordas?",["Porque o vento havia aumentado","Porque já era noite","Porque o navio chegara ao destino","Porque faltavam passageiros"],0],
	["Embora a neblina escondesse a costa, a tripulação continuou a viagem com ajuda dos instrumentos.","Que ideia a palavra ‘embora’ introduz?",["Uma oposição ao que seria esperado","Uma causa da neblina","Uma conclusão da viagem","Uma sequência de horários"],0],
	["Na volta, Lia escreveu: ‘O porto estava silencioso; só o ranger das cordas quebrava a quietude.’","O que ‘quietude’ significa nesse trecho?",["Silêncio e tranquilidade","Pressa para partir","Movimento intenso","Uma tempestade"],0],
	["O diário registra: ‘O gelo recuou, mas a água permanecia fria. Por isso, a equipe manteve os casacos.’","A expressão ‘por isso’ liga o uso dos casacos a quê?",["À temperatura da água e do ambiente","À cor do gelo","À chegada ao porto","À escrita do diário"],0],
	["O marinheiro levou uma lanterna para que todos enxergassem a trilha na gruta.","A expressão ‘para que’ indica…",["Finalidade","Oposição","Dúvida","Tempo passado"],0]
]
const SCIENCE := [
	["O céu parece mudar ao longo da noite.","Qual movimento da Terra explica o ciclo de dia e noite?",["Rotação","Translação","Movimento das marés","Fases da Lua"],0],
	["A Lua não produz luz própria.","Por que conseguimos vê-la iluminada?",["Ela reflete a luz do Sol","Ela queima combustível","A Terra ilumina toda a Lua","Sua superfície produz eletricidade"],0],
	["Uma colher metálica é deixada em uma sopa quente.","O calor chega ao cabo principalmente por…",["Condução térmica","Fotossíntese","Evaporação do metal","Magnetismo"],0],
	["A água pode mudar de estado físico.","Na evaporação, a água passa de…",["Líquido para gasoso","Gasoso para líquido","Sólido para líquido","Líquido para sólido"],0],
	["Plantas verdes fazem fotossíntese.","Qual é a principal fonte de energia desse processo?",["Luz solar","Som do ambiente","Calor das raízes","Oxigênio do solo"],0],
	["Em um circuito simples, uma lâmpada só acende quando há caminho para a corrente.","O que acontece ao abrir o interruptor?",["A corrente é interrompida","A corrente dobra","A pilha se recarrega","A lâmpada acende mais forte"],0]
]

func _ready() -> void:
	Network.leaving_zone.connect(func(id: int,_zone: String): sessions.erase(id))
	Network.roster_changed.connect(func():
		if not Network.active:
			sessions.clear()
			view={}
	)

func act(action: String, index: int=-1) -> void:
	if not Network.active: return
	if multiplayer.is_server(): _command(1,action,index,int(view.get("revision",-1)))
	else: _request.rpc_id(1,action,index,int(view.get("revision",-1)))

@rpc("any_peer","call_remote","reliable")
func _request(action: String,index: int,revision: int) -> void:
	if multiplayer.is_server(): _command(multiplayer.get_remote_sender_id(),action,index,revision)

func _command(id: int,action: String,index: int,revision: int) -> void:
	if not Network.players.has(id): return
	var zone: String=Network.players[id].zone
	if zone not in ["ship","cave","science"]: return
	if action=="cancel":
		sessions.erase(id)
		if id==1: _receive({})
		else: _receive.rpc_id(id,{})
		return
	if action=="start":
		if sessions.has(id) and sessions[id].phase=="question": return
		var questions: Array=(SCIENCE if zone=="science" else READING).duplicate(true)
		questions.shuffle()
		sessions[id]={"questions":questions.slice(0,3),"index":0,"score":0,"revision":randi_range(1,1000000),"phase":"question","zone":zone}
		_ask(id)
	elif action=="answer" and sessions.has(id):
		var s: Dictionary=sessions[id]
		if s.phase!="question" or s.revision!=revision or index<0 or index>3: return
		var correct: bool=index==s.correct
		if correct:
			s.score+=1
			Progress.record(id,"science_correct" if zone=="science" else "reading_correct")
		s.feedback="Resposta correta!" if correct else "Resposta: "+s.options[s.correct]
		s.phase="feedback"
		s.revision+=1
		_send(id)
	elif action=="next" and sessions.has(id):
		var s: Dictionary=sessions[id]
		if s.phase!="feedback" or s.revision!=revision: return
		s.index+=1
		if s.index>=3:
			s.phase="result"
			s.revision+=1
			if s.score>=2: Progress.record(id,"science_complete" if zone=="science" else "reading_complete")
			_send(id)
		else: _ask(id)

func _ask(id: int) -> void:
	var s: Dictionary=sessions[id]
	var q: Array=s.questions[s.index]
	var answer: String=q[2][q[3]]
	s.options=q[2].duplicate()
	s.options.shuffle()
	s.correct=s.options.find(answer)
	s.text=q[0]
	s.question=q[1]
	s.phase="question"
	s.revision+=1
	_send(id)

func _send(id: int) -> void:
	var s: Dictionary=sessions[id]
	var public:={"phase":s.phase,"revision":s.revision,"index":s.index,"score":s.score,"text":s.get("text",""),"question":s.get("question",""),"options":s.get("options",[]),"feedback":s.get("feedback","") if s.phase!="question" else ""}
	if id==1: _receive(public)
	else: _receive.rpc_id(id,public)

@rpc("authority","call_remote","reliable")
func _receive(state: Dictionary) -> void:
	view=state
	changed.emit()
