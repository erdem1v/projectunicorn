// A person's bust: un-premultiplied, since a transparent viewport's pixels carry their colour
// already multiplied by their alpha, and in an avatar disc cut to the circle.
shader_type canvas_item;

uniform bool circle = true;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float a = c.a;
	if (circle) {
		float edge = length(UV - 0.5) * 2.0;
		c.a *= 1.0 - smoothstep(1.0 - fwidth(edge) * 1.5, 1.0, edge);
	}
	COLOR = vec4(c.rgb / max(a, 1e-4), c.a);
}
