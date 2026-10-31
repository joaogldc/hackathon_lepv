extends RefCounted
## Explicit regions: generated sheets do not have a uniform cell grid.
const BOAT := "res://assets/sprites/urso/remando/urso_bote_remando_v1.png"
const ICE := "res://assets/sprites/minigames/corrida_glacial/obstaculos_moedas_agua_v1.png"
const ROCKET := "res://assets/sprites/minigames/foguete_madeira/foguete_abelhas_mel_v1.png"
var cache: Dictionary = {}

func region(sheet: String, rect: Rect2) -> AtlasTexture:
	var key := sheet + str(rect)
	if cache.has(key): return cache[key]
	var atlas := AtlasTexture.new()
	atlas.atlas = load(sheet)
	atlas.region = rect
	atlas.filter_clip = true
	cache[key] = atlas
	return atlas

func boat(frame: int) -> AtlasTexture:
	var boxes := [Rect2(17, 75, 463, 370), Rect2(480, 85, 407, 360), Rect2(903, 90, 424, 355), Rect2(1348, 85, 407, 360), Rect2(17, 480, 432, 346), Rect2(463, 480, 424, 346), Rect2(900, 480, 427, 346), Rect2(1350, 480, 424, 346)]
	return region(BOAT, boxes[frame % 8])

func rocket(frame: int, turbo: bool) -> AtlasTexture:
	return region(ROCKET, Rect2(20 + (frame % 4) * 278, 342 if turbo else 0, 263, 380 if turbo else 340))

func bee(frame: int, space: bool) -> AtlasTexture:
	return region(ROCKET, Rect2(22 + ((frame % 2) + (2 if space else 0)) * 278, 722, 263, 231))

func teacher() -> AtlasTexture: return region(ROCKET, Rect2(24, 955, 266, 235))
func honey(frame: int) -> AtlasTexture: return region(ROCKET, Rect2((frame % 4) * 278, 1185, 278, 217))
func fuel(level: float) -> AtlasTexture:
	return region(ROCKET, Rect2(320 + (0 if level > 65 else (1 if level > 25 else 2)) * 270, 960, 245, 222))
func obstacle(index: int) -> AtlasTexture: return region(ICE, Rect2((index % 4) * 384 + 20, 16, 350, 270))
func coin(frame: int) -> AtlasTexture: return region(ICE, Rect2((frame % 4) * 384 + 80, 302, 230, 218))
func splash(frame: int) -> AtlasTexture: return region(ICE, Rect2((frame % 4) * 384 + 45, 530, 300, 210))
