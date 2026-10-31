extends Button
## The source atlas is visual; the damage label is drawn from the game's rules.
const ATLAS := preload("res://assets/ui/cartas/cartas-atlas.png")
@export var difficulty := 0
var selected := false
func _ready() -> void:
	for state in ["normal","hover","pressed","disabled","focus"]:
		add_theme_stylebox_override(state,StyleBoxEmpty.new())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
func _draw() -> void:
	var tint := Color(0.7,0.7,0.7) if disabled else Color.WHITE
	draw_texture_rect_region(ATLAS,Rect2(Vector2.ZERO,size),Rect2(difficulty*160,0,160,192),tint)
	var k := size/Vector2(160,192)
	draw_set_transform(Vector2.ZERO,0,k)
	draw_rect(Rect2(18,64,124,99),Color("fff5dc").darkened(0.2) if disabled else Color("fff5dc"))
	draw_string(ThemeDB.fallback_font,Vector2(65,118),"1",HORIZONTAL_ALIGNMENT_LEFT,-1,46,Color("513d2b"))
	draw_string(ThemeDB.fallback_font,Vector2(57,146),"DANO",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("7d7058"))
	if selected or (is_hovered() and not disabled):
		draw_style_box(_border(),Rect2(3,3,154,183))
func _border() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color=Color.TRANSPARENT
	box.border_color=Color("f6c64c")
	box.set_border_width_all(4)
	box.set_corner_radius_all(16)
	return box
