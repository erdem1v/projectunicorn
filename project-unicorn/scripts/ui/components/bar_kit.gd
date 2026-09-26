extends RefCounted

# BarKit — yüzen çubukların (BuildBar, ResearchBar) ortak çizim ilkelleri.
#
# TEMA-BAĞIMSIZ, BİLEREK: yazı boyu/rengi çağıranın verdiği UiTokens değerinden,
# yazı tipi PROJE temasından (ThemeDB) okunur; `get_theme_font` ya da
# `theme_type_variation` kullanılmaz. ODA alt ağacı kendi dondurulmuş temasını
# çözer, yani varyasyona uzanan bir kart monitörde tracker'dakinden farklı düşerdi;
# iki yerde aynı kart görünmeli.
#
# class_name yok, iki çubuk da `preload` eder: paylaşılan checkout'ta yeni bir
# class_name, öteki oturumların headless koşularını global class-cache yarım
# kalınca düşürüyor.

const ICON_DIR := "res://assets/icons/build/"


## Proje teması → MicroLabel varyasyonunun mono yüzü. Theme.get_font varyasyon
## zincirini yürümez, o yüzden önce has_font.
static func resolve_font(host: Control) -> Font:
	var th: Theme = ThemeDB.get_project_theme()
	if th != null:
		if th.has_font(&"font", &"MicroLabel"):
			return th.get_font(&"font", &"MicroLabel")
		if th.has_font(&"font", &"Label"):
			return th.get_font(&"font", &"Label")
	return host.get_theme_default_font()


static func label(font: Font, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override(&"font", font)
	l.add_theme_font_size_override(&"font_size", size_px)
	l.add_theme_color_override(&"font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# clip_text kapalı kalmalı: açıkken Label'ın asgari genişliği sıfıra iner ve
	# yanındaki esneyen boşluk bütün satırı yutar. Dolgunun kenarı hiçbir yazıyı kesmez.
	l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return l


static func glyph(name: String, px: int, color: Color) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(ICON_DIR + name + ".svg")
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.modulate = color
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return t


static func hairline() -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(0, 1)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.BG_AVATAR   # #1B232B — sayfanın satır kılı
	sb.anti_aliasing = false
	p.add_theme_stylebox_override(&"panel", sb)
	return p


## KAPAK ÇİZGİSİ. Ayrı bir Panel, çünkü StyleBoxFlat tek kenara ayrı RENK veremez
## ve kapak çizgisi gövde kenarından FARKLI renktedir (grubun durumu).
static func cap(height_px: int) -> Panel:
	var c := Panel.new()
	c.custom_minimum_size = Vector2(0, height_px)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func paint_cap(cap_panel: Panel, color: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.anti_aliasing = false
	cap_panel.add_theme_stylebox_override(&"panel", sb)


# --- Altıgen -------------------------------------------------------------------
# Ar-Ge düğümünün ağaçtaki şekli; çubuk aynı şekli taşır ki kart ile ağaç aynı nesneyi
# göstersin. Renk `meta`da durur çünkü `draw` sinyali argüman taşımaz.

const HEX_META := &"bar_kit_hex_color"


static func hex(px: int, color: Color) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(px, px)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.set_meta(HEX_META, color)
	c.draw.connect(_draw_hex.bind(c))
	return c


static func paint_hex(node: Control, color: Color) -> void:
	node.set_meta(HEX_META, color)
	node.queue_redraw()


static func _draw_hex(node: Control) -> void:
	var color: Color = node.get_meta(HEX_META, UiTokens.INK) as Color
	var mid: Vector2 = node.size * 0.5
	var r: float = minf(node.size.x, node.size.y) * 0.5 - 1.0
	if r <= 0.0:
		return
	var pts := PackedVector2Array()
	for i in 7:                       # 7. nokta = 1. nokta → kapalı çember
		var a: float = deg_to_rad(60.0 * float(i) - 90.0)
		pts.append(mid + Vector2(cos(a), sin(a)) * r)
	node.draw_polyline(pts, color, 1.0, true)
