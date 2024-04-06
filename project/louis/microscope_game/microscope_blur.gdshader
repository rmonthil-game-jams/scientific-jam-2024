shader_type canvas_item;

uniform float lod;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR.rgb = textureLod(TEXTURE, UV, lod).rgb;
	COLOR.rgb = texture(TEXTURE, 0.5*UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
