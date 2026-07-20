class_name LogoEmblem
extends Control

# Auto-emblem for the company logo (onboarding Page 3): renders the company
# name's initial inside a style-specific shape. Pure _draw — no image assets;
# the four shapes come from FounderConstants.LOGO_STYLES[].emblem:
#   circle_outline (Minimalist) · hexagon (Tech) · rounded_fill (Playful) ·
#   square_fill (Serious).
#
# Godot concept: draw_* primitives + draw_string with the theme's default font.
# The control is square via custom_minimum_size; parent decides the size.

var style_id: String = ""
var letter: String = "?"


func _init(diameter: float = 48.0) -> void:
	custom_minimum_size = Vector2(diameter, diameter)


func configure(new_style_id: String, company_name: String) -> void:
	style_id = new_style_id
	letter = initial_of(company_name)
	queue_redraw()


## Company initial, Turkish dotted-İ correct via the single home UiTokens.tr_upper
## (raw String.to_upper() is not locale-aware — "i" would become "I").
static func initial_of(company_name: String) -> String:
	var stripped: String = company_name.strip_edges()
	if stripped == "":
		return "?"
	return UiTokens.tr_upper(stripped.substr(0, 1))


func _emblem_kind() -> String:
	for style in FounderConstants.LOGO_STYLES:
		if style["id"] == style_id:
			return String(style["emblem"])
	return ""


func _draw() -> void:
	var c: Vector2 = size * 0.5
	var r: float = minf(size.x, size.y) * 0.5 - 2.0
	var letter_color: Color = UiTokens.CREAM
	match _emblem_kind():
		"circle_outline":
			draw_arc(c, r, 0.0, TAU, 48, UiTokens.ACCENT, 1.5, true)
		"hexagon":
			var pts := PackedVector2Array()
			for i in 7:   # 7th point closes the loop
				var a: float = TAU * i / 6.0 - PI / 2.0
				pts.append(c + Vector2(cos(a), sin(a)) * r)
			draw_polyline(pts, UiTokens.ACCENT, 1.5, true)
			letter_color = UiTokens.ACCENT
		"rounded_fill":
			var sb := StyleBoxFlat.new()
			sb.bg_color = UiTokens.ACCENT
			sb.set_corner_radius_all(int(r * 0.45))
			draw_style_box(sb, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0))
			letter_color = UiTokens.DIALOGUE_BG
		"square_fill":
			draw_rect(Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), UiTokens.CREAM)
			letter_color = UiTokens.DIALOGUE_BG
		_:
			return
	var font: Font = get_theme_default_font()
	var font_size: int = int(r * 1.05)
	var glyph: Vector2 = font.get_string_size(letter, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var ascent: float = font.get_ascent(font_size)
	var descent: float = font.get_descent(font_size)
	var baseline_y: float = c.y + (ascent - descent) * 0.5
	draw_string(font, Vector2(c.x - glyph.x * 0.5, baseline_y), letter,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, letter_color)
