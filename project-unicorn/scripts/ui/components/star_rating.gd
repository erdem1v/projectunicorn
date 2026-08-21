class_name StarRating
extends Control

# BEŞ YILDIZ, HER ZAMAN. Onaylı tasarımın (Unicorn Skins, tur 9-11) tek yetenek grameri:
# her alan beş glif çizer — dolular amber, boşlar #2A343D kontur. Sebebi süs değil ÖLÇÜ:
# yıldız değiştiğinde satır genişliği oynamaz ve tavanın beş olduğu bakışta görünür.
#
# YARIM YILDIZ GERÇEK. Alan cetveli 0..HRConstants.AREA_MAX (10) ve iki puan bir yıldız
# ediyor, yani tek sayılar yarım yıldıza düşüyor. Yarım, ayrı bir glif değil: aynı hücrenin
# YARISI mürekkepli. Godot'ta bunun ucuz ve piksel-doğru yolu iki katman —
#   altta beş SOLUK glif, üstte beş AMBER glif, üsttekinin kabı `clip_contents` ile
#   doldurulmuş orana kadar kısaltılmış.
# `_draw` ile tek tek glif çizmeye göre avantajı: yazı tipi metriklerini elle hesaplamıyoruz,
# motorun kendi kerning'i iki katmanda da aynı olduğu için kesim tam yıldızın ortasına düşüyor.
#
# YAZI TİPİ TEMADAN DEĞİL, DOSYADAN. `mono_reg.tres` bir FontVariation ve NotoSansSymbols2
# yedeği ona bağlı — U+2605 (★) oradan geliyor. Tema üzerinden çözseydik yeni bir
# theme_type_variation gerekirdi ve UI/STYLE LAW gereği THEME_STAMP artardı; bu bileşen
# hiçbir tema öğesi eklemiyor, o yüzden damga yerinde duruyor.

const MONO_FONT := preload("res://assets/fonts/variations/mono_reg.tres")
const FILLED := "★"

## Tek ev: puanı yıldıza çeviren eşleme HRConstants.stars_for'da, burada DEĞİL.
static func make(points: int, glyph_px: int = 14, muted: bool = false) -> Control:
	return make_stars(HRConstants.stars_for(points), glyph_px, muted)


## Doğrudan yıldız değeriyle (0.0 .. STAR_MAX, yarımlar dahil).
static func make_stars(stars: float, glyph_px: int = 14, muted: bool = false) -> Control:
	var total: int = HRConstants.STAR_MAX
	var row := FILLED.repeat(total)
	var font_size: int = maxi(glyph_px, 1)
	var span: Vector2 = MONO_FONT.get_string_size(row, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	var root := Control.new()
	root.custom_minimum_size = span
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Alt katman: beş boş yıldız.
	# Boş yıldızın rengi #2A343D — tasarımın "ghost" kenarıyla aynı ton, aynı token.
	var empty := _glyph_label(row, font_size, UiTokens.BORDER_HOVER)
	empty.set_anchors_preset(Control.PRESET_TOP_LEFT)
	root.add_child(empty)

	# Üst katman: aynı beş yıldız amber, kabı orana kadar kısaltılmış.
	var ratio: float = clampf(stars / float(total), 0.0, 1.0)
	if ratio > 0.0:
		var clip := Control.new()
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.position = Vector2.ZERO
		clip.size = Vector2(span.x * ratio, span.y)
		clip.custom_minimum_size = clip.size
		var full := _glyph_label(row, font_size, UiTokens.ACCENT)
		full.set_anchors_preset(Control.PRESET_TOP_LEFT)
		full.custom_minimum_size = span
		clip.add_child(full)
		root.add_child(clip)

	if muted:
		root.modulate = Color(1, 1, 1, 0.45)
	return root


## Etiket + yıldız, tasarımın hücre dizilişiyle: alan adı üstte, yıldızlar altında.
static func labelled(caption: String, points: int, glyph_px: int = 14,
		muted: bool = false) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cap := UiFactory.make_label(caption, &"RowMeta", UiTokens.CREAM_DIM)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(cap)
	col.add_child(make(points, glyph_px, muted))
	return col


static func _glyph_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", MONO_FONT)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
