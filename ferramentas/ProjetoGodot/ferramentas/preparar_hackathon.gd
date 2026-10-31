extends Node
## Copia o addon Godot AI para o projeto do hackathon, ativa o plugin e abre o editor nele.

const SRC_ADDON := "C:/Users/jpkil/Desktop/ProjetoGodot/addons/godot_ai"
const DEST := "C:/Users/jpkil/Desktop/hackathon_lepv"
const GODOT := "C:/Users/jpkil/Desktop/Godot_v4.7.2-stable_win64.exe"

var _n := 0


func _ready() -> void:
	_copy_dir(SRC_ADDON, DEST.path_join("addons/godot_ai"))
	print("Addon copiado: ", _n, " arquivos")

	var pg_path := DEST.path_join("project.godot")
	var txt := FileAccess.get_file_as_string(pg_path)
	if not txt.contains("res://addons/godot_ai/plugin.cfg"):
		if txt.contains("[editor_plugins]"):
			print("AVISO: ja existe [editor_plugins]; nao alterei")
		else:
			txt = txt.rstrip("\n") + "\n\n[editor_plugins]\n\nenabled=PackedStringArray(\"res://addons/godot_ai/plugin.cfg\")\n"
			var f := FileAccess.open(pg_path, FileAccess.WRITE)
			f.store_string(txt)
			f.close()
			print("Plugin ativado no project.godot")

	var bat := FileAccess.open(DEST.path_join("abrir_godot.bat"), FileAccess.WRITE)
	bat.store_string("@echo off\r\ncd /d \"%~dp0\"\r\nstart \"\" \"%USERPROFILE%\\Desktop\\Godot_v4.7.2-stable_win64.exe\" -e --path \"%~dp0.\"\r\n")
	bat.close()

	var pid := OS.create_process(GODOT, PackedStringArray(["-e", "--path", DEST]))
	print("Editor do hackathon aberto, pid=", pid)


func _copy_dir(src: String, dst: String) -> void:
	DirAccess.make_dir_recursive_absolute(dst)
	var d := DirAccess.open(src)
	if d == null:
		print("FALHA ao abrir ", src)
		return
	d.include_hidden = true
	for sub in d.get_directories():
		_copy_dir(src.path_join(sub), dst.path_join(sub))
	for file in d.get_files():
		if DirAccess.copy_absolute(src.path_join(file), dst.path_join(file)) == OK:
			_n += 1
		else:
			print("FALHA ao copiar ", file)
