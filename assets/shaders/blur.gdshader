shader_type canvas_item;
render_mode blend_mix;

uniform float blur_amount : hint_range(0.0, 10.0) = 5.0;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec3 col = vec3(0.0);
	float total = 0.0;

	for(int x = -int(blur_amount); x <= int(blur_amount); x++) {
		for(int y = -int(blur_amount); y <= int(blur_amount); y++) {
			vec2 offset = vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE;
			col += texture(screen_texture, SCREEN_UV + offset).rgb;
			total += 1.0;
		}
	}

	col /= total;
	COLOR = vec4(col, 1.0);
}
