extends Node
## Baixa o projeto do hackathon (branch main) do GitHub e extrai na Área de Trabalho.

const URL := "https://codeload.github.com/joaogldc/hackathon_lepv/zip/refs/heads/main"
const DEST := "C:/Users/jpkil/Desktop/hackathon_lepv"

var _zip_path := ""


func _ready() -> void:
	if DirAccess.dir_exists_absolute(DEST):
		print("ABORTADO: a pasta já existe: ", DEST)
		return
	_zip_path = OS.get_user_data_dir().path_join("hackathon_lepv_main.zip")
	var http := HTTPRequest.new()
	http.download_file = _zip_path
	http.use_threads = true
	http.timeout = 600.0
	add_child(http)
	http.request_completed.connect(_on_done)
	var err := http.request(URL)
	print("Download iniciado: ", err)


func _on_done(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	print("Download terminou: result=", result, " http=", code)
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		print("FALHA no download")
		return
	var zr := ZIPReader.new()
	if zr.open(_zip_path) != OK:
		print("FALHA ao abrir o zip")
		return
	var n := 0
	for f in zr.get_files():
		var slash := f.find("/")
		if slash < 0:
			continue
		var rel := f.substr(slash + 1)
		if rel.is_empty():
			continue
		var out := DEST.path_join(rel)
		if f.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(out)
			continue
		DirAccess.make_dir_recursive_absolute(out.get_base_dir())
		var fa := FileAccess.open(out, FileAccess.WRITE)
		if fa == null:
			print("FALHA ao gravar ", out)
			continue
		fa.store_buffer(zr.read_file(f))
		fa.close()
		n += 1
	zr.close()
	print("EXTRAIDOS ", n, " arquivos em ", DEST)
