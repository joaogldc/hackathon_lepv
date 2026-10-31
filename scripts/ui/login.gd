extends Control
## Tela de entrada. Contas ficam só neste computador (user://contas.cfg), sem servidor.
## O primeiro login com um nome novo cria a conta; os seguintes conferem a senha.
const CONTAS_PATH := "user://contas.cfg"
const PRIMEIRA_CENA := "res://scenes/world/lobby.tscn"
const FONTS := preload("res://scripts/ui/game_fonts.gd")

@onready var painel: Panel = $Painel
@onready var titulo: Label = $Painel/Titulo
@onready var campo_usuario: LineEdit = $Painel/Usuario
@onready var campo_senha: LineEdit = $Painel/Senha
@onready var botao: Button = $Painel/Entrar
@onready var aviso: Label = $Painel/Aviso

func _ready() -> void:
	titulo.add_theme_font_override("font", FONTS.title())
	get_viewport().size_changed.connect(_ajustar_tamanho)
	botao.pressed.connect(_entrar)
	campo_usuario.text_submitted.connect(func(_t): campo_senha.grab_focus())
	campo_senha.text_submitted.connect(func(_t): _entrar())
	_ajustar_tamanho()
	campo_usuario.grab_focus()

func _entrar() -> void:
	var usuario := campo_usuario.text.strip_edges()
	var senha := campo_senha.text
	if usuario.is_empty() or senha.is_empty():
		_avisar("Preencha usuário e senha.", true)
		return
	var contas := ConfigFile.new()
	contas.load(CONTAS_PATH)
	var chave := usuario.to_lower()
	if contas.has_section(chave):
		var sal: String = contas.get_value(chave, "sal", "")
		if (sal + senha).sha256_text() != contas.get_value(chave, "hash", ""):
			_avisar("Senha incorreta. Tente de novo.", true)
			campo_senha.clear()
			campo_senha.grab_focus()
			return
	else:
		var sal := str(randi()) + str(Time.get_unix_time_from_system())
		contas.set_value(chave, "nome", usuario)
		contas.set_value(chave, "sal", sal)
		contas.set_value(chave, "hash", (sal + senha).sha256_text())
		contas.save(CONTAS_PATH)
	Network.nickname = str(contas.get_value(chave, "nome", usuario)).left(18)
	botao.disabled = true
	_avisar("Bem-vindo, %s!" % Network.nickname, false)
	get_tree().change_scene_to_file.call_deferred(PRIMEIRA_CENA)

func _avisar(texto: String, erro: bool) -> void:
	aviso.text = texto
	aviso.add_theme_color_override("font_color", Color(0.72, 0.22, 0.16) if erro else Color(0.12, 0.48, 0.61))

func _ajustar_tamanho() -> void:
	var tamanho := get_viewport().get_visible_rect().size
	var escala := clampf(minf((tamanho.x - 32.0) / painel.size.x, (tamanho.y - 32.0) / painel.size.y), 0.1, 1.0)
	painel.pivot_offset = painel.size / 2.0
	painel.position = (tamanho - painel.size) / 2.0
	painel.scale = Vector2.ONE * escala
