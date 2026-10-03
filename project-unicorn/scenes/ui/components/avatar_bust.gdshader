// A person's bust: un-premultiplied, since a transparent viewport's pixels carry their colour
// already multiplied by their alpha, and in an avatar disc cut to the circle. A grey face is
// someone away (on leave).
shader_type canvas_item;

uniform bool circle = true;
uniform bool grey = false;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float a = c.a;
	if (circle) {
		float edge = length(UV - 0.5) * 2.0;
		c.a *= 1.0 - smoothstep(1.0 - fwidth(edge) * 1.5, 1.0, edge);
	}
	vec3 rgb = c.rgb / max(a, 1e-4);
	if (grey) {
		rgb = vec3(dot(rgb, vec3(0.299, 0.587, 0.114)));
	}
	COLOR = vec4(rgb, c.a);
}
