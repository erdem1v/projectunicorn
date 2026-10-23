class_name LogoEmblem
extends Control

# The company's emblem: one or two initials in a shape of one of the logo colours, drawn filled, outlined or split by
# a slanted cut. Drawn, not an image, on a 100 box scaled to the control's least side; the parent decides the size.
# A logo is {shape, color, style, glyphs}; {} draws nothing.

const SHAPES := ["circle", "hexagon", "square", "shield", "tag", "diamond"]
const STYLES := ["filled", "outline", "split"]
const CANDIDATES := 12
# A save from before the emblem named one of four styles; each reads as the emblem it drew.
const LEGACY := {
	"minimalist": {"shape": "circle", "style": "outline", "color": "bone"},
	"tech": {"shape": "hexagon", "style": "outline", "color": "teal"},
	"playful": {"shape": "circle", "style": "filled", "color": "brick"},
	"serious": {"shape": "square", "style": "filled", "color": "bone"},
}
const OUTLINE_W := 5.0
const OUTLINE_SCALE := 0.94   # the stroke stays inside the box
const SPLIT_DEEP := 0.26      # the cut's dark half: this much of the colour over the ground
# The cut: the part of the shape left of it is the light half.
const CUT_RIGHT := [Vector2(62, 0), Vector2(100, 0), Vector2(100, 100), Vector2(38, 100)]
const HOLE := Vector3(21, 50, 5)   # the tag's hole: centre and radius
# The initials' size on the 100 box, by their count, where a shape leaves them less room than the rest.
const GLYPH_SIZE := [{"diamond": 44, "": 58}, {"diamond": 34, "circle": 46, "shield": 44, "tag": 40, "": 48}]

var logo := {}
# The split's light half, through which its dark initials show.
var _mask := Control.new()


func _init(side: float = 48.0) -> void:
	custom_minimum_size = Vector2(side, side)
	_mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	var ink := Control.new()
	_mask.add_child(ink)
	for part: Control in [_mask, ink]:
		part.set_anchors_preset(Control.PRESET_FULL_RECT)
		part.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mask.draw.connect(func() -> void:
		_to_box(_mask)
		for half in _halves()[0]:
			_mask.draw_colored_polygon(half, UiTokens.D_INK_1))
	ink.draw.connect(func() -> void: _draw_glyphs(ink, UiTokens.D_SURFACE_1))
	add_child(_mask)


func configure(new_logo: Dictionary) -> void:
	logo = new_logo
	_mask.visible = logo.get("style") == "split"
	queue_redraw()
	_mask.queue_redraw()
	_mask.get_child(0).queue_redraw()


## The twelve emblems a company name opens with, the same for the same name and reroll: every shape twice, every
## style four times, every colour at least once; one initial or, for a name of two words or more, the first two.
static func candidates(company_name: String, reroll: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%s|%d" % [company_name, reroll])
	var initials := ""
	for word in company_name.split(" ", false).slice(0, 2):
		initials += word.left(1)
	initials = Fmt.upper(initials)
	var shapes := _shuffled(SHAPES, rng)
	var colors := _shuffled(UiTokens.LOGO_PALETTE.keys(), rng)
	var style_at := rng.randi_range(0, STYLES.size() - 1)
	var out := []
	for i in CANDIDATES:
		# A shape's second turn takes the next style and the other count of initials.
		var turn := int(i >= SHAPES.size())
		out.append({"shape": shapes[i % SHAPES.size()], "color": colors[i % colors.size()],
			"style": STYLES[(i + turn + style_at) % STYLES.size()], "glyphs": initials.left(1 + (i + turn) % 2)})
	return out


## The emblem of a save that kept only a style, or none: its first letter in the style's shape, else the name's first
## candidate.
static func from_legacy(style: String, company_name: String) -> Dictionary:
	if not LEGACY.has(style):
		return candidates(company_name, 0)[0]
	return LEGACY[style].merged({"glyphs": Fmt.upper(company_name.strip_edges().left(1))})


static func _shuffled(items: Array, rng: RandomNumberGenerator) -> Array:
	var out := items.duplicate()
	for i in range(out.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var held: Variant = out[i]
		out[i] = out[j]
		out[j] = held
	return out


## The shape's outline on the 100 box, curves flattened.
static func _outline(shape: String) -> PackedVector2Array:
	var pts := PackedVector2Array()
	match shape:
		"circle":
			pts = _arc(Vector2(50, 50), 47, 0.0, TAU, 64)
			pts.resize(64)   # the arc's last point is its first
		"hexagon":
			for i in 6:
				pts.append(Vector2(50, 50) + Vector2.from_angle(TAU * i / 6.0 - PI / 2.0) * 48)
		"square":
			for corner in [[Vector2(86, 14), -PI / 2.0], [Vector2(86, 86), 0.0], [Vector2(14, 86), PI / 2.0],
					[Vector2(14, 14), PI]]:
				pts.append_array(_arc(corner[0], 9, corner[1], corner[1] + PI / 2.0, 6))
		"shield":
			pts = PackedVector2Array([Vector2(50, 3), Vector2(92, 14), Vector2(92, 47)])
			for curve in [[Vector2(92, 47), Vector2(92, 72), Vector2(74, 88), Vector2(50, 97)],
					[Vector2(50, 97), Vector2(26, 88), Vector2(8, 72), Vector2(8, 47)]]:
				for k in range(1, 13):
					pts.append(curve[0].bezier_interpolate(curve[1], curve[2], curve[3], k / 12.0))
			pts.append(Vector2(8, 14))
		"tag":
			pts = PackedVector2Array([Vector2(32, 7)])
			pts.append_array(_arc(Vector2(89, 12), 5, -PI / 2.0, 0.0, 4))
			pts.append_array(_arc(Vector2(89, 88), 5, 0.0, PI / 2.0, 4))
			pts.append_array(PackedVector2Array([Vector2(32, 93), Vector2(5, 50)]))
		"diamond":
			pts = PackedVector2Array([Vector2(50, 2), Vector2(98, 50), Vector2(50, 98), Vector2(2, 50)])
	return pts


static func _arc(centre: Vector2, radius: float, from: float, to: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in steps + 1:
		pts.append(centre + Vector2.from_angle(lerpf(from, to, float(k) / steps)) * radius)
	return pts


## [light parts, dark parts] of the split shape.
func _halves() -> Array:
	var shape := _outline(logo.shape)
	var right := PackedVector2Array(CUT_RIGHT)
	return [Geometry2D.clip_polygons(shape, right), Geometry2D.intersect_polygons(shape, right)]


## Draws on `item` in the 100 box, centred in the control.
func _to_box(item: CanvasItem) -> void:
	var side := minf(size.x, size.y)
	item.draw_set_transform((size - Vector2.ONE * side) * 0.5, 0.0, Vector2.ONE * side / 100.0)


func _draw() -> void:
	if logo.is_empty():
		return
	var hue: Color = UiTokens.LOGO_PALETTE[logo.color]
	var ground := UiTokens.D_SURFACE_1
	var shape := _outline(logo.shape)
	var tag: bool = logo.shape == "tag"
	_to_box(self)
	match logo.style:
		"filled":
			draw_colored_polygon(shape, hue)
		"outline":
			var ring := PackedVector2Array()
			for p in shape:
				ring.append(Vector2(50, 50) + (p - Vector2(50, 50)) * OUTLINE_SCALE)
			ring.append(ring[0])
			draw_polyline(ring, hue, OUTLINE_W, true)
			if tag:
				draw_arc(Vector2(HOLE.x, HOLE.y), HOLE.z, 0.0, TAU, 24, hue, OUTLINE_W - 1.0, true)
		"split":
			var halves := _halves()
			for half in halves[0]:
				draw_colored_polygon(half, hue)
			for half in halves[1]:
				draw_colored_polygon(half, UiTokens.D_SURFACE_0.lerp(hue, SPLIT_DEEP))
	if tag and logo.style != "outline":
		draw_circle(Vector2(HOLE.x, HOLE.y), HOLE.z, ground, true, -1.0, true)
	_draw_glyphs(self, ground if logo.style == "filled" else hue)


## The initials in the CompanyTitle face, at pixel size: a scaled raster would blur.
func _draw_glyphs(item: CanvasItem, ink: Color) -> void:
	item.draw_set_transform(Vector2.ZERO)
	var glyphs: String = logo.glyphs
	var by_shape: Dictionary = GLYPH_SIZE[clampi(glyphs.length(), 1, 2) - 1]
	var side := minf(size.x, size.y)
	var font: Font = get_theme_font(&"font", &"CompanyTitle")
	var font_size := roundi(by_shape.get(logo.shape, by_shape[""]) * side / 100.0)
	var width := font.get_string_size(glyphs, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var centre := size * 0.5 + Vector2(10 if logo.shape == "tag" else 0, 1) * side / 100.0
	item.draw_string(font, Vector2(centre.x - width * 0.5,
		centre.y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5), glyphs,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink)
