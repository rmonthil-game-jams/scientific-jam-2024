shader_type canvas_item;

uniform float lod;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR.rgb = texture(screen_texture, SCREEN_UV, 10.0).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
