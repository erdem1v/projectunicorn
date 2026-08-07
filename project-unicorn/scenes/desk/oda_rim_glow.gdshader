shader_type canvas_item;

// ODA obje hover rim'i (projenin İLK shader'ı — ODA rework 2026-08-06).
// Alpha-kenar tespiti: 8 örnekli halkada komşu alfa > kendi alfa ⇒ kenar.
// Renk KODDA SABİT DEĞİL — UiTokens.ODA_RIM_GLOW uniform'dan gelir (runtime
// stylebox'larla aynı yasallık sınıfı, sweep ledger §A). glow_strength hover
// tween'iyle 0..1 sürülür; 0'ken shader kimliksizdir (piksel-eş geçiş).

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float rim_px = 10.0; // kaynak texel cinsinden rim kalınlığı — # WORKING

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * rim_px;
	float na = 0.0;
	na = max(na, texture(TEXTURE, UV + vec2(px.x, 0.0)).a);
	na = max(na, texture(TEXTURE, UV + vec2(-px.x, 0.0)).a);
	na = max(na, texture(TEXTURE, UV + vec2(0.0, px.y)).a);
	na = max(na, texture(TEXTURE, UV + vec2(0.0, -px.y)).a);
	na = max(na, texture(TEXTURE, UV + px * 0.707).a);
	na = max(na, texture(TEXTURE, UV - px * 0.707).a);
	na = max(na, texture(TEXTURE, UV + vec2(px.x, -px.y) * 0.707).a);
	na = max(na, texture(TEXTURE, UV + vec2(-px.x, px.y) * 0.707).a);
	float rim = clamp(na - tex.a, 0.0, 1.0) * glow_strength * glow_color.a;
	COLOR = vec4(mix(glow_color.rgb, tex.rgb, tex.a), max(tex.a * COLOR.a, rim));
}
