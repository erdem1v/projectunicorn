// Two skies in one. What the camera sees is the design's screen-space gradient (top to bottom of
// the frame, blended in sRGB like its canvas texture). What the radiance map sees is the design's
// hemisphere light plus its ambient light: a sky half and a ground half, whose cosine-weighted
// sum over a normal is exactly three.js's HemisphereLight term.
shader_type sky;

uniform vec3 top_color;     // sRGB
uniform vec3 bottom_color;  // sRGB
uniform vec3 hemi_sky;      // linear radiance
uniform vec3 hemi_ground;   // linear radiance

void sky() {
	if (AT_CUBEMAP_PASS) {
		COLOR = EYEDIR.y > 0.0 ? hemi_sky : hemi_ground;
	} else {
		vec3 c = mix(top_color, bottom_color, SCREEN_UV.y);
		COLOR = mix(pow((c + 0.055) / 1.055, vec3(2.4)), c / 12.92, lessThan(c, vec3(0.04045)));
	}
}
