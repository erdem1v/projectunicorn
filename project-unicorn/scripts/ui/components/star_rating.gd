class_name StarRating
extends Control

# BEŞ YILDIZ, HER ZAMAN: dolular amber, boşlar BORDER_HOVER. Yıldız değiştiğinde satır
# genişliği oynamaz ve tavanın beş olduğu bakışta görünür.
#
# Yarım yıldız ayrı bir glif değil, aynı hücrenin yarısı mürekkepli: altta beş soluk
# glif, üstte beş amber glif, üsttekinin kabı `clip_contents` ile orana kadar kısaltılmış.
# İki katmanda motorun kerning'i aynı olduğu için kesim tam yıldızın ortasına düşer.
#
# Yazı tipi temadan değil dosyadan: `mono_reg.tres` FontVariation'ı ★ (U+2605) glifini
# NotoSansSymbols2 yedeğinden alır; bu bileşen tema öğesi eklemez.

const MONO_FONT := preload("res://assets/fonts/variations/mono_reg.tres")
const FILLED := "★"

## Puanı yıldıza çeviren eşleme HRConstants.stars_for'da.
static func make(points: int, glyph_px: int = 14, muted: bool = false) -> Control:
	return make_stars(HRConstants.stars_for(points), glyph_px, muted)


## Doğrudan yıldız değeriyle (0.0 .. STAR_MAX, yarımlar dahil).
static func make_stars(stars: float, glyph_px: int = 14, muted: bool = false) -> Control:
	var total: int = HRConstants.STAR_MAX
	var row := FILLED.repeat(total)
	var span: Vector2 = MONO_FONT.get_string_size(row, HORIZONTAL_ALIGNMENT_LEFT, -1, glyph_px)

	var root := Control.new()
	root.custom_minimum_size = span
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_glyph_label(row, glyph_px, UiTokens.BORDER_HOVER))

	var ratio: float = clampf(stars / float(total), 0.0, 1.0)
	if ratio > 0.0:
		var clip := Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.size = Vector2(span.x * ratio, span.y)
		clip.custom_minimum_size = clip.size
		var full := _glyph_label(row, glyph_px, UiTokens.ACCENT)
		full.custom_minimum_size = span
		clip.add_child(full)
		root.add_child(clip)

	if muted:
		root.modulate = Color(1, 1, 1, 0.45)
	return root


## Etiket üstte, yıldızlar altında. `compact` = etiket gerekirse üç noktayla kısalabilir;
## sütunun tabanı o zaman beş yıldız olur. Varsayılanı false, çünkü `clip_text` Label'ın
## asgari genişliğini sıfıra indirir ve yer bol olsa bile uzun başlık kısalır. Yalnız
## Kişisel'in sekiz sütunlu şeridi bunu ister: sayfayı %125'te ekranda tutan şey o.
static func labelled(caption: String, points: int, glyph_px: int = 14,
		muted: bool = false, compact: bool = false) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cap := UiFactory.make_label(caption, &"RowMeta", UiTokens.CREAM_DIM)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if compact:
		cap.clip_text = true
		cap.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	col.add_child(cap)
	var stars: Control = make(points, glyph_px, muted)
	stars.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(stars)
	return col


static func _glyph_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", MONO_FONT)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
