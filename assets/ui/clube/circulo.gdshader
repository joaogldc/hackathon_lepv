shader_type canvas_item;
void fragment() {
	vec4 pixel = texture(TEXTURE,UV);
	if (distance(UV,vec2(0.5)) > 0.5) { pixel.a = 0.0; }
	COLOR = pixel * COLOR;
}
