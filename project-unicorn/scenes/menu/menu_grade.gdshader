shader_type canvas_item;

// The menu's city in the dark language: the world drawn in the surface's warm greys, a lit window keeping some of
// its own colour as a small warm accent.

uniform vec4 tone;                    // UiTokens.D_SURFACE_0: its hue is the one the greys lean to
const float DEPTH = 0.95;             // [WORKING] how bright the greys read
const float SPARK_FROM = 0.55;        // [WORKING] luminance from which a pixel counts as a lit window
const float SPARK_KEEP = 0.45;        // [WORKING] how much of a lit window's own colour stays
const float SPARK_DIM = 0.65;         // [WORKING] a lit window's brightness against the greys

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));
	float spark = smoothstep(SPARK_FROM, 1.0, lum) * SPARK_KEEP;
	vec3 grey = tone.rgb / max(tone.r, max(tone.g, tone.b)) * lum * DEPTH;
	COLOR = vec4(mix(grey, src.rgb * DEPTH * SPARK_DIM, spark), src.a * COLOR.a);
}
