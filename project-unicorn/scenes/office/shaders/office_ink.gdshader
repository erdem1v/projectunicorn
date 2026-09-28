// The design's post (office-sim-v12.js EdgeShader, then GradeShader's vignette) on one full-screen
// quad, drawn first among the transparent objects so glass and glows land on top of it. An edge is
// a jump in view depth or view normal across a cross of `texel` pixels. Depth is in world units:
// the design's D() is depth01 * (far - near), which for its orthographic camera is view depth.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, depth_draw_never, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest, repeat_disable;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, filter_nearest, repeat_disable;

uniform vec3 ink : source_color = vec3(0.16471, 0.13333, 0.2);
uniform float depth_threshold = 0.25;
uniform float normal_threshold = 0.35;
uniform float texel = 1.15;
uniform float vignette = 0.22;
// A bust (person_bust) is drawn on a clear background: only the figure and its lines stay opaque.
uniform bool cutout = false;

// The design's lighter line on dark surfaces, a linear colour as it writes it.
const vec3 DARK_LINE = vec3(0.55, 0.62, 0.95);
const float FAR = 1.0e4;

// three.js ACESFilmicToneMapping (exposure 1) and inverses of its two matrices.
const mat3 ACES_IN = mat3(vec3(0.59719, 0.076, 0.0284), vec3(0.35458, 0.90834, 0.13383), vec3(0.04823, 0.01566, 0.83777));
const mat3 ACES_OUT = mat3(vec3(1.60475, -0.10208, -0.00327), vec3(-0.53108, 1.10813, -0.07276), vec3(-0.07367, -0.00605, 1.07602));
const mat3 ACES_IN_INV = mat3(vec3(1.764741, -0.1470279, -0.0363368), vec3(-0.6757777, 1.1602515, -0.1624364), vec3(-0.0889633, -0.0132237, 1.1987733));
const mat3 ACES_OUT_INV = mat3(vec3(0.6430382, 0.0592687, 0.0059619), vec3(0.3111868, 0.9314365, 0.063929), vec3(0.0457755, 0.0092949, 0.9301184));

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

// xyz view normal, w view depth. The sky and the design's no-edge ground (roughness 0, see
// office_materials) read as the far plane.
vec4 probe(vec2 uv, mat4 inv_projection) {
	vec4 nr = texture(normal_roughness_texture, uv);
	float raw = texture(depth_texture, uv).r;
	if (raw <= 0.0 || nr.w < 0.25) {
		return vec4(0.0, 0.0, 1.0, FAR);
	}
	vec4 view = inv_projection * vec4(uv * 2.0 - 1.0, raw, 1.0);
	return vec4(normalize(nr.xyz * 2.0 - 1.0), -view.z / view.w);
}

vec3 aces(vec3 x) {
	vec3 v = ACES_IN * x / 0.6;
	v = (v * (v + 0.0245786) - 0.000090537) / (v * (0.983729 * v + 0.432951) + 0.238081);
	return clamp(ACES_OUT * v, 0.0, 1.0);
}

vec3 aces_inverse(vec3 y) {
	vec3 v = ACES_OUT_INV * y;
	vec3 a = 0.983729 * v - 1.0;
	vec3 b = 0.432951 * v - 0.0245786;
	vec3 c = 0.238081 * v + 0.000090537;
	return ACES_IN_INV * ((-b - sqrt(b * b - 4.0 * a * c)) / (2.0 * a)) * 0.6;
}

vec3 to_srgb(vec3 c) {
	return mix(1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, c * 12.92, lessThan(c, vec3(0.0031308)));
}

vec3 to_linear(vec3 c) {
	return mix(pow((c + 0.055) / 1.055, vec3(2.4)), c / 12.92, lessThan(c, vec3(0.04045)));
}

void fragment() {
	vec2 px = texel / VIEWPORT_SIZE;
	vec2 ox = vec2(px.x, 0.0);
	vec2 oy = vec2(0.0, px.y);
	vec4 c = probe(SCREEN_UV, INV_PROJECTION_MATRIX);
	vec4 r = probe(SCREEN_UV + ox, INV_PROJECTION_MATRIX);
	vec4 l = probe(SCREEN_UV - ox, INV_PROJECTION_MATRIX);
	vec4 u = probe(SCREEN_UV + oy, INV_PROJECTION_MATRIX);
	vec4 d = probe(SCREEN_UV - oy, INV_PROJECTION_MATRIX);
	float dd = abs(r.w - c.w) + abs(l.w - c.w) + abs(u.w - c.w) + abs(d.w - c.w);
	float nd = 4.0 - dot(c.xyz, r.xyz) - dot(c.xyz, l.xyz) - dot(c.xyz, u.xyz) - dot(c.xyz, d.xyz);
	float fg = c.w < FAR ? 1.0 : 0.0;
	// The design's depth threshold is absolute, so a face's own slope trips it once a pixel spans
	// enough world: a wall square to the axes gains about 3.8 x texel x pixel size of depth across
	// the cross. Where that passes the threshold (the city map) the threshold follows it; every
	// office at its fitted zoom stays below and keeps the design's value.
	float px_world = 2.0 / abs(PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);
	float dth = max(depth_threshold, 4.0 * texel * px_world);
	float de = smoothstep(dth, dth * 2.0, dd) * fg;
	// Outline-only surfaces (people, roughness 0.5) keep their silhouette and overlaps, not creases.
	float crease = step(0.75, texture(normal_roughness_texture, SCREEN_UV).w);
	float ne = smoothstep(normal_threshold, normal_threshold * 2.0, nd) * fg * crease;
	vec3 col = texture(screen_texture, SCREEN_UV).rgb;
	float lum = dot(col, vec3(0.299, 0.587, 0.114));
	vec3 line = (lum < 0.18 && ne > de) ? mix(col, DARK_LINE, 0.3) : mix(col * 0.3, ink, 0.55);
	col = mix(col, line, max(de, ne) * 0.92);
	// The design darkens the tonemapped frame; the ACES round trip does it before Godot tonemaps.
	vec2 q = SCREEN_UV - 0.5;
	ALBEDO = aces_inverse(to_linear(to_srgb(aces(col)) * (1.0 - vignette * dot(q, q) * 2.0)));
	ALPHA = cutout ? max(fg, max(de, ne)) : 1.0;
}
