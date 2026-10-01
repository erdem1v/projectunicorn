class_name SprintUiShared
extends RefCounted

# Sprint ekranı bileşenlerinin ortak parçaları. Hepsi statik: metin TranslationServer'dan
# okunur, çünkü statik fonksiyonda tr() çalışmaz. Anlamsal renk (Güçlü/Zayıf, "!", CANLI,
# taşma) burada renk körü yardımcılarıyla boyanır; tema bu rengi taşımaz.

const SEP := " · "
const ICON_DIR := "res://assets/icons/product/"
const LEVEL_KEYS := {
	"strong": "PRODUCT_LEVEL_STRONG", "enough": "PRODUCT_LEVEL_ENOUGH",
	"weak": "PRODUCT_LEVEL_WEAK", "none": "PRODUCT_LEVEL_NONE",
}
## Kart kipi "kapatır", öngörü kipi "kapanır" der.
const COUNT_KEYS := {
	"tickets": ["PRODUCT_FX_TICKETS_CLOSE", "PRODUCT_FX_TICKETS_CLOSED"],
	"voices": ["PRODUCT_FX_VOICES_CLOSE", "PRODUCT_FX_VOICES_CLOSED"],
}
## Mürekkep düğmesinin glifi; listede olmayan tür (remove) kelimeyle yazılır.
const BUTTON_GLYPHS := {"add": "+", "send_next": "→", "pull": "↑"}


## `count` kare. Dolu kare verilen rengi alır; yarım seviye (cila) kareyi yarıya kadar doldurur.
class Slices extends Control:
	var level: float
	var color: Color
	var count: int

	func _draw() -> void:
		var px: float = custom_minimum_size.y
		for i in count:
			var r := Rect2(i * (px + UiTokens.SPACE_XXS), 0.0, px, px)
			var fill: float = clampf(level - i, 0.0, 1.0)
			if fill > 0.0:
				draw_rect(Rect2(r.position, Vector2(px * fill, px)), color)
			if fill < 1.0:
				draw_rect(r.grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.BORDER_HOVER, false, UiTokens.BORDER_HAIRLINE)


## Kapasite çubuğu: dilimler alan renginde, kalan boşluk açık. Taşmada kapasitenin ötesi
## negatif boyanır; sprint sürerken bitmiş puanlar koyulaşır.
class CapacityBar extends Control:
	var _cap: Dictionary

	func _init() -> void:
		custom_minimum_size.y = UiTokens.PRODUCT_CAPACITY_BAR_H
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func setup(capacity: Dictionary) -> void:
		_cap = capacity
		queue_redraw()

	func _draw() -> void:
		var frame := Rect2(Vector2.ZERO, size)
		draw_rect(frame, UiTokens.BG_BODY)
		draw_rect(frame.grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.BORDER_HOVER, false, UiTokens.BORDER_HAIRLINE)
		# Ekip yoksa (0/0) çubuk boş çerçevedir.
		var span: int = maxi(int(_cap.total), int(_cap.used))
		if span == 0:
			return
		var inner := frame.grow(-UiTokens.BORDER_HAIRLINE)
		var unit: float = inner.size.x / span
		var x: float = inner.position.x
		for seg in _cap.segments:
			var w: float = int(seg.pts) * unit
			draw_rect(Rect2(x, inner.position.y, w, inner.size.y), UiTokens.area_color(int(seg.slot)))
			x += w
			draw_line(Vector2(x, inner.position.y), Vector2(x, inner.end.y), UiTokens.CARD_BG)
		if int(_cap.done) > 0:
			draw_rect(Rect2(inner.position, Vector2(int(_cap.done) * unit, inner.size.y)), UiTokens.SHADOW_SOFT)
		if _cap.state == "over":
			var limit: float = inner.position.x + int(_cap.total) * unit
			draw_rect(Rect2(limit, inner.position.y, inner.end.x - limit, inner.size.y), UiTokens.negative())


static func slices(level: float, px: int, color: Color, count := 3) -> Control:
	var s := Slices.new()
	s.level = level
	s.color = color
	s.count = count
	s.custom_minimum_size = Vector2(count * px + (count - 1) * UiTokens.SPACE_XXS, px)
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## Kapasite çubuğu ve "kullanılan/toplam"; taşmada sayı da negatif boyanır.
static func capacity_row(cap: Dictionary, value_variation: StringName) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	var bar := CapacityBar.new()
	bar.setup(cap)
	row.add_child(bar)
	var used := stamp("%d/%d" % [int(cap.used), int(cap.total)], value_variation)
	if cap.state == "over":
		used.add_theme_color_override(&"font_color", UiTokens.negative())
	row.add_child(used)
	return row


## Seviye kelimesinin ve dolu dilimin rengi.
static func word_color(word: String) -> Color:
	match word:
		"strong": return UiTokens.positive()
		"enough": return UiTokens.INK_MUTED
		"weak": return UiTokens.negative()
	return UiTokens.INK_FAINT


## ids: kind_feature · kind_polish · kind_fix · kind_research · role_design · role_dev ·
## role_test (böcek; uyarı çipi de bunu kullanır) · role_product · bubble · tick · arrow.
static func icon(id: String, px: int, color: Color) -> TextureRect:
	return HRUiShared._glyph(ICON_DIR + id + ".svg", px, color)


static func stamp(text: String, variation: StringName) -> Label:
	var l := UiFactory.make_label(text, variation)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


## kind: &"positive" (CANLI) ya da &"negative" (uyarı, son tarih). Çocuk 0 etikettir.
static func semantic_chip(text: String, kind: StringName) -> PanelContainer:
	var p: Dictionary = UiTokens.badge_palette(kind)
	var chip := UiFactory.make_state_chip(text, p.fg, p.bg,
		UiTokens.positive_rule() if kind == &"positive" else UiTokens.negative_rule())
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return chip


static func attention_badge() -> Label:
	var badge := UiFactory.make_label("!", &"AttentionBadge", UiTokens.negative())
	var sb: StyleBoxFlat = ThemeDB.get_project_theme().get_stylebox(&"normal", &"AttentionBadge").duplicate()
	sb.bg_color = UiTokens.negative_bg()
	sb.border_color = UiTokens.negative_rule()
	badge.add_theme_stylebox_override(&"normal", sb)
	return _square(badge, UiTokens.PRODUCT_BADGE_PX)


static func avatar(initials: String, tooltip: String, px: int, me: bool) -> Label:
	var a := UiFactory.make_label(initials, &"AvatarChipMe" if me else &"AvatarChip")
	a.tooltip_text = tooltip
	a.mouse_filter = Control.MOUSE_FILTER_PASS   # Label varsayılanı IGNORE; ipucu fareyi ister
	return _square(a, px)


## Direk + afiş: rakip çıkışı gri afiş, son tarih renk körü güvenli kırmızı.
static func flag(spec: Dictionary) -> HBoxContainer:
	var deadline: bool = spec.k == "deadline"
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 0)
	var pole := ColorRect.new()
	pole.color = UiTokens.negative() if deadline else UiTokens.INK_DIM
	pole.custom_minimum_size = Vector2(UiTokens.SPACE_XXS, UiTokens.SPACE_XXL)
	pole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(pole)
	var banner: Control
	if deadline:
		banner = semantic_chip(spec.text, &"negative")
	else:
		banner = stamp(spec.text, &"StampGrey")
	banner.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(banner)
	return row


## Faz noktası: bitmiş faz dolu nokta, süren amber halka, bekleyen boş halka.
static func phase_dot(phase: String, ink: Color) -> Control:
	var dot := Control.new()
	dot.custom_minimum_size = Vector2.ONE * UiTokens.PRODUCT_PHASE_RING_PX
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.draw.connect(_draw_phase_dot.bind(dot, phase, ink))
	return dot


static func _draw_phase_dot(dot: Control, phase: String, ink: Color) -> void:
	var c: Vector2 = dot.size / 2.0
	match phase:
		"done":
			dot.draw_circle(c, UiTokens.PRODUCT_PHASE_DOT_PX / 2.0, ink)
		"active":
			dot.draw_circle(c, UiTokens.PRODUCT_PHASE_RING_PX / 2.0, UiTokens.AMBER_BG)
			dot.draw_arc(c, (UiTokens.PRODUCT_PHASE_RING_PX - UiTokens.BORDER_FOCUS) / 2.0, 0.0, TAU, 24,
				UiTokens.ACCENT, UiTokens.BORDER_FOCUS, true)
		_:
			dot.draw_arc(c, (UiTokens.PRODUCT_PHASE_DOT_PX - UiTokens.BORDER_HAIRLINE) / 2.0, 0.0, TAU, 24,
				ink, UiTokens.BORDER_HAIRLINE, true)


## Kartın ve müşteri satırının mürekkep düğmesi.
static func ink_button(kind: String, disabled: bool) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"InkButton"
	b.text = BUTTON_GLYPHS.get(kind, RnDUiShared.t("PRODUCT_REMOVE"))
	b.custom_minimum_size = Vector2.ONE * UiTokens.SPACE_3XL
	b.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	b.disabled = disabled
	return b


## Bölmeli seçici (StanceDial). Yalnız seçili olmayan bölme `on_pick(i)` çağırır: alıcı basışı
## geçiş olarak okuyabilir, seçili tarafa basmak durumu ters çevirirdi.
static func dial(labels: Array, selected: int, on_pick: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override(&"separation", 0)
	for i in labels.size():
		var b := Button.new()
		b.theme_type_variation = &"StanceDialActive" if i == selected else &"StanceDial"
		b.text = labels[i]
		b.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
		if i != selected:
			b.pressed.connect(on_pick.bind(i))
		row.add_child(b)
	return row


## Alanın renk karesi.
static func swatch(slot: int, px: int) -> ColorRect:
	var s := ColorRect.new()
	s.color = UiTokens.area_color(slot)
	s.custom_minimum_size = Vector2.ONE * px
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## Sol kenarda alanın renk şeridi: kart ve alan satırı.
static func draw_edge(ci: Control, slot: int) -> void:
	ci.draw_rect(Rect2(0.0, 0.0, UiTokens.BORDER_ACCENT, ci.size.y), UiTokens.area_color(slot))


## Boş ya da sonraki sütunun kesikli çerçevesi; StyleBoxFlat kesik çizemez.
static func dashed_outline(column: Control) -> void:
	column.draw.connect(_draw_dashed_outline.bind(column))


static func _draw_dashed_outline(column: Control) -> void:
	RnDUiShared.draw_dashed_rect(column, Rect2(Vector2.ZERO, column.size).grow(-UiTokens.BORDER_HAIRLINE / 2.0),
		UiTokens.BORDER_HOVER)


## Kartın etki satırı (mode "card": dilimler, "kapatır") ya da SPRINT SONUNDA öngörüsü
## (mode "forecast": seviye kelimeleri, "kapanır"). Kartta parçalar SEP ile, öngörüde boşlukla ayrılır.
static func effect_line(parts: Array, mode: String) -> HFlowContainer:
	var forecast: bool = mode == "forecast"
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override(&"h_separation", UiTokens.SPACE_XL if forecast else UiTokens.SPACE_S)
	flow.add_theme_constant_override(&"v_separation", UiTokens.SPACE_XS)
	for part in parts:
		if not forecast and flow.get_child_count() > 0:
			flow.add_child(_meta(SEP.strip_edges()))
		flow.add_child(_part(part, forecast))
	return flow


static func _part(part: Dictionary, forecast: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	match String(part.k):
		"level":
			row.add_child(_strong(part.area))
			_transition(row, part, forecast)
		"cap":
			row.add_child(_strong(part.name))
			_transition(row, part, false)
		"holds":
			row.add_child(_strong(part.area))
			row.add_child(_meta(RnDUiShared.t("PRODUCT_FX_HOLDS").format({"level": RnDUiShared.t(LEVEL_KEYS[part.word])})))
		"alert_clear":
			row.add_child(_strong(part.area))
			row.add_child(attention_badge())
			row.add_child(_meta(RnDUiShared.t("PRODUCT_FX_ALERT_CLEARS")))
		"tickets", "voices":
			if forecast:
				row.add_child(icon("bubble", UiTokens.PRODUCT_ICON_PX, UiTokens.INK_MUTED))
			var n: int = int(part.n)
			row.add_child(_meta(RnDUiShared.t(Fmt.count_key(COUNT_KEYS[part.k][int(forecast)], n)).format({"n": n})))
		"request":
			row.add_child(_meta(RnDUiShared.t("PRODUCT_FX_REQUEST").format({"customer": part.customer}) + SEP
				+ RnDUiShared.t("PRODUCT_PER_YEAR").format({"amount": Fmt.money_exact(int(part.value))})))
		"rival_gap":
			row.add_child(_meta(RnDUiShared.t("PRODUCT_FX_RIVAL_GAP")))
		"research":
			row.add_child(_strong(part.area))
			row.add_child(_meta(RnDUiShared.t("PRODUCT_FX_RESEARCH")))
		"request_on_time":
			row.add_child(_strong(part.customer))
			row.add_child(_meta(RnDUiShared.t("PRODUCT_FX_ON_TIME")))
	return row


## from → to: kartta dilimlerle, öngörüde seviye kelimeleriyle; kelime ve renk parçanın taşıdığı
## from_word / to_word'den.
static func _transition(row: HBoxContainer, part: Dictionary, words: bool) -> void:
	row.add_child(_level_mark(part.from, part.from_word, words))
	row.add_child(icon("arrow", UiTokens.PRODUCT_ICON_PX, UiTokens.positive()))
	row.add_child(_level_mark(part.to, part.to_word, words))


static func _level_mark(level: float, word: String, as_word: bool) -> Control:
	if as_word:
		return UiFactory.make_label(RnDUiShared.t(LEVEL_KEYS[word]), &"RowMeta", word_color(word))
	return slices(level, UiTokens.PRODUCT_SLICE_PX_SMALL, word_color(word))


static func _square(l: Label, px: int) -> Label:
	l.custom_minimum_size = Vector2(px, px)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


static func _strong(text: String) -> Label:
	return UiFactory.make_label(text, &"RowMetaStrong")


static func _meta(text: String) -> Label:
	return UiFactory.make_label(text, &"RowMeta")
