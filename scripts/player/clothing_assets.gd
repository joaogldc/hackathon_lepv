extends RefCounted
## Keep only requested atlases alive. Clothing is optional to the world/server.
const IDS := ["camisa_cor","terno_cor","terno_detalhe","chapeu_cor","chapeu_detalhe","touca_cor"]
static var loaded: Dictionary={}
static func layer(id: String) -> SpriteFrames:
	if not IDS.has(id): return null
	if not loaded.has(id):
		loaded[id]=load("res://assets/sprites/urso/roupas/"+id+".tres") as SpriteFrames
	return loaded[id]
