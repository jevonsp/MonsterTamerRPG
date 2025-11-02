shader_type canvas_item;
uniform float radius : hint_range(0.0, 2.0) = 0.5;
uniform vec2 center = vec2(0.5, 0.5);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 viewport_size = vec2(640.0, 360.0);

void fragment() {
	float aspect = viewport_size.x / viewport_size.y;

	vec2 fixed_uv = UV - center;
	fixed_uv.x *= aspect;

	float dist = length(fixed_uv);
	if (dist < radius) {
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}