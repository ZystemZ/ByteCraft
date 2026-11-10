shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 pixel_grid = vec2(360.0, 202.0);
uniform float color_steps = 4.0;

void fragment() {
	vec2 snapped_uv = floor(SCREEN_UV * pixel_grid) / pixel_grid;
	vec3 source = texture(screen_texture, snapped_uv).rgb;
	vec3 quantized = floor(source * (color_steps - 1.0) + 0.5) / (color_steps - 1.0);
	COLOR = vec4(quantized, 1.0);
}
