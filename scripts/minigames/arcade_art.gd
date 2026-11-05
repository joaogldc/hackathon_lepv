extends RefCounted
## Explicit regions: generated sheets do not have a uniform cell grid.
const BOAT := "res://assets/sprites/urso/remando/urso_bote_remando_v1.png"
const ICE := "res://assets/sprites/minigames/corrida_glacial/obstaculos_moedas_agua_v1.png"
const ROCKET := "res://assets/sprites/minigames/foguete_madeira/foguete_abelhas_mel_v1.png"
# Keep source pixels at one scale throughout the rowing cycle. The generated
# frames have different bounds because the oar sweeps beyond the hull.
const BOAT_CANVAS := Vector2(496, 400)
const BOAT_PIVOT := Vector2(248, 344)
const BOAT_REGIONS := [Rect2(17, 75, 463, 370), Rect2(480, 85, 407, 360), Rect2(903, 90, 424, 355), Rect2(1348, 85, 407, 360), Rect2(17, 480, 432, 346), Rect2(463, 480, 424, 346), Rect2(900, 480, 427, 346), Rect2(1350, 480, 424, 346)]
# Registration points measured at the center/base of the hull, not at the oar.
const BOAT_HULL_PIVOTS := [Vector2(235, 394), Vector2(677, 402), Vector2(1119, 403), Vector2(1548, 402), Vector2(233, 808), Vector2(677, 808), Vector2(1118, 808), Vector2(1548, 808)]
# Normal and turbo exhaust share one native scale and one porthole registration.
# Turbo must extend the flame, never shrink the wooden body to fit its bounds.
const ROCKET_CANVAS := Vector2(300, 400)
const ROCKET_PIVOT := Vector2(148, 140)
const ROCKET_REGIONS := [Rect2(20, 0, 263, 340), Rect2(298, 0, 263, 340), Rect2(576, 0, 263, 340), Rect2(854, 0, 263, 340), Rect2(20, 342, 263, 380), Rect2(298, 342, 263, 380), Rect2(576, 342, 263, 380), Rect2(854, 342, 263, 380)]
const ROCKET_BODY_PIVOTS := [Vector2(158, 133), Vector2(428, 133), Vector2(697, 133), Vector2(965, 133), Vector2(158, 467), Vector2(428, 467), Vector2(696, 467), Vector2(965, 467)]
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
	var index := posmod(frame, BOAT_REGIONS.size())
	var key := "boat:%d" % index
	if cache.has(key): return cache[key]
	var rect: Rect2 = BOAT_REGIONS[index]
	var hull_offset: Vector2 = BOAT_HULL_PIVOTS[index] - rect.position
	var atlas := AtlasTexture.new()
	atlas.atlas = load(BOAT)
	atlas.region = rect
	# margin.size adds transparent space to the region's native size; its
	# position places the hull at the same pivot in every 496 x 400 canvas.
	atlas.margin = Rect2(BOAT_PIVOT - hull_offset, BOAT_CANVAS - rect.size)
	atlas.filter_clip = true
	cache[key] = atlas
	return atlas

func rocket(frame: int, turbo: bool) -> AtlasTexture:
	var index := posmod(frame, 4) + (4 if turbo else 0)
	var key := "rocket:%d" % index
	if cache.has(key): return cache[key]
	var rect: Rect2 = ROCKET_REGIONS[index]
	var body_offset: Vector2 = ROCKET_BODY_PIVOTS[index] - rect.position
	var atlas := AtlasTexture.new()
	atlas.atlas = load(ROCKET)
	atlas.region = rect
	atlas.margin = Rect2(ROCKET_PIVOT - body_offset, ROCKET_CANVAS - rect.size)
	atlas.filter_clip = true
	cache[key] = atlas
	return atlas

func bee(frame: int, space: bool) -> AtlasTexture:
	return region(ROCKET, Rect2(22 + ((frame % 2) + (2 if space else 0)) * 278, 722, 263, 231))

func teacher() -> AtlasTexture: return region(ROCKET, Rect2(24, 955, 266, 235))
func honey(frame: int) -> AtlasTexture: return region(ROCKET, Rect2((frame % 4) * 278, 1185, 278, 217))
func fuel(level: float) -> AtlasTexture:
	return region(ROCKET, Rect2(320 + (0 if level > 65 else (1 if level > 25 else 2)) * 270, 960, 245, 222))
func obstacle(index: int) -> AtlasTexture: return region(ICE, Rect2((index % 4) * 384 + 20, 16, 350, 270))
func coin(frame: int) -> AtlasTexture: return region(ICE, Rect2((frame % 4) * 384 + 80, 302, 230, 218))
func splash(frame: int) -> AtlasTexture: return region(ICE, Rect2((frame % 4) * 384 + 45, 530, 300, 210))
