// The design's MeshToonMaterial (office-sim-v12.js): a three-step light ramp read from a 3-texel
// gradient map (95, 175, 255) at dot(N, L) * 0.5 + 0.5, times the light's shadow. Ambient comes
// from the sky radiance (office_sky.gdshader), emission passes through.
shader_type spatial;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec2 uv1_scale = vec2(1.0);
uniform vec2 uv1_offset = vec2(0.0);
uniform vec3 emission : source_color = vec3(0.0);
uniform float emission_energy = 0.0;
uniform sampler2D emission_texture : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
// The emission map may tile apart from the albedo map (the city's facades).
uniform vec2 emission_uv_scale = vec2(1.0);
uniform vec2 emission_uv_offset = vec2(0.0);
// The design keeps its ground out of the ink pass; roughness carries that to office_ink.
uniform bool no_edge = false;
// Office people carry their clothes and faces as linear vertex colours (office_body).
uniform bool use_vertex_color = false;
// People take only outline ink: their hair and folds would draw as streaks. Roughness 0.5 tells
// office_ink so.
uniform bool outline_only = false;

void fragment() {
	ALBEDO = albedo.rgb * texture(albedo_texture, UV * uv1_scale + uv1_offset).rgb * (use_vertex_color ? COLOR.rgb : vec3(1.0));
	EMISSION = emission * emission_energy * texture(emission_texture, UV * emission_uv_scale + emission_uv_offset).rgb;
	ROUGHNESS = no_edge ? 0.0 : (outline_only ? 0.5 : 1.0);
}

void light() {
	// Nearest-filtered 3-texel map: thirds of dot(N, L) * 0.5 + 0.5.
	float ndl = dot(NORMAL, LIGHT);
	float ramp = ndl < -1.0 / 3.0 ? 95.0 / 255.0 : (ndl < 1.0 / 3.0 ? 175.0 / 255.0 : 1.0);
	// LIGHT_COLOR carries π; three.js's Lambert divides by it and its lights do not.
	DIFFUSE_LIGHT += ramp * ATTENUATION * LIGHT_COLOR / PI;
}
