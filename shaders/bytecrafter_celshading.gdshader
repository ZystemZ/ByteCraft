shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float outline_strength = 0.72;

float luminance_at(vec2 uv) {
	vec3 sample_color = texture(screen_texture, clamp(uv, vec2(0.0), vec2(1.0))).rgb;
	return dot(sample_color, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	vec3 source = texture(screen_texture, SCREEN_UV).rgb;
	float luminance = dot(source, vec3(0.299, 0.587, 0.114));
	float band = floor(luminance * 3.0 + 0.5) / 3.0;
	vec3 cel_color = source * (band / max(luminance, 0.06));
	vec2 offset = SCREEN_PIXEL_SIZE * 1.5;
	float edge_x = abs(luminance_at(SCREEN_UV + vec2(offset.x, 0.0)) - luminance_at(SCREEN_UV - vec2(offset.x, 0.0)));
	float edge_y = abs(luminance_at(SCREEN_UV + vec2(0.0, offset.y)) - luminance_at(SCREEN_UV - vec2(0.0, offset.y)));
	float edge = smoothstep(0.07, 0.22, max(edge_x, edge_y));
	cel_color = mix(cel_color, vec3(0.035, 0.047, 0.065), edge * outline_strength);
	COLOR = vec4(clamp(cel_color, 0.0, 1.0), 1.0);
}
