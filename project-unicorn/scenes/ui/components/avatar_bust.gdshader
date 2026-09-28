// A person's bust in an avatar disc: cut to the circle, and un-premultiplied, since a transparent
// viewport's pixels carry their colour already multiplied by their alpha.
shader_type canvas_item;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float a = c.a;
	float edge = length(UV - 0.5) * 2.0;
	c.a *= 1.0 - smoothstep(1.0 - fwidth(edge) * 1.5, 1.0, edge);
	COLOR = vec4(c.rgb / max(a, 1e-4), c.a);
}
