extends RefCounted
## Acessórios dos pets. Cada acessório tem as camadas "cor" e "detalhe",
## já alinhadas ao quadro-base do pet (mesmo nome de arquivo, mesmo tamanho).
const FOLDERS := {"fish": "res://assets/pets/acessorios/", "parrot": "res://assets/pets/acessorios_arara/"}
const ICON_PREFIX := {"fish": "peixe_", "parrot": "arara_"}
const IDS := ["bigode", "oculos", "tapa_olho", "laco", "festa", "helice", "quepe", "capacete", "cartola", "terninho", "coroa"]
## A arte do tapa-olho só foi entregue para a arara.
const PARROT_ONLY := ["tapa_olho"]
static var _cache: Dictionary = {}

static func supports(species: String, accessory: String) -> bool:
	return FOLDERS.has(species) and accessory in IDS and (species == "parrot" or accessory not in PARROT_ONLY)

## Texturas (cor, depois detalhe) que cobrem o quadro-base `frame`. Vazio se não houver arte.
static func layers(species: String, accessory: String, frame: String) -> Array:
	if not supports(species, accessory): return []
	var key := species + "/" + accessory + "/" + frame
	if _cache.has(key): return _cache[key]
	var found: Array = []
	for layer in ["cor", "detalhe"]:
		var path: String = FOLDERS[species] + accessory + "/" + layer + "/" + frame + ".png"
		if ResourceLoader.exists(path): found.append(load(path))
	_cache[key] = found
	return found

## Ícone do pet usando o acessório, para vitrines e catálogo.
static func icon(species: String, accessory: String) -> String:
	if not supports(species, accessory): species = "fish" if accessory not in PARROT_ONLY else "parrot"
	return FOLDERS[species] + "icones/" + ICON_PREFIX[species] + accessory + ".png"
