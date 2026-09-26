shader_type canvas_item;

// ODA obje hover rim'i. Alpha-kenar tespiti: 8 örnekli halkada komşu alfa > kendi alfa ⇒ kenar.
// Renk koddan değil UiTokens.ODA_RIM_GLOW uniform'undan gelir. glow_strength hover tween'iyle
// 0..1 sürülür; 0'ken shader kimliksizdir (piksel-eş geçiş).

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
// Rim kalınlığı, KAYNAK texel cinsinden — # WORKING. Render sprite'larının kenarı keskin: silüetin
// dışında tex.a = 0, yani rim = na ve na şekle rim_px'ten yakın her pikselde 1'dir. Kalınlık bu
// yüzden yumuşak bir hale değil düz bir şerit basar; 3.0 texel ≈ 1080p'de 1.4 ekran px'i, dolgu
// değil kenar vurgusu. Rim yalnız tex.a = 0 olan yere eklenir: dolgu asla parlamaz.
uniform float rim_px = 3.0;

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
