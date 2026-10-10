class_name SprintUiShared
extends RefCounted

# Sprint ekranı bileşenlerinin ortak parçaları, koyu dilde. Hepsi statik: metin TranslationServer'dan
# okunur, çünkü statik fonksiyonda tr() çalışmaz. Anlamın rengi (Güçlü, Zayıf, kalkan uyarı, aşım,
# son tarih) D_ yardımcılarından gelir; alanlar renk taşımaz, adları, kareleri ve kelimeleriyle okunur.

const SEP := " · "
const KIND_ICON := "res://assets/icons/product/kind_%s.svg"
const ROLE_ICONS := {"design": "res://assets/icons/skill/design.svg", "dev": "res://assets/icons/skill/engineering.svg",
	"test": "res://assets/icons/skill/qa.svg", "product": "res://assets/icons/skill/product.svg"}
const VOICES := "res://assets/icons/product/voices.svg"
const BUG := "res://assets/icons/product/bug.svg"
const ARROW := "res://assets/icons/util/arrow_right.svg"
const WARN := "res://assets/icons/util/warn.svg"
const CHECK := "res://assets/icons/util/check.svg"
const CLOCK := "res://assets/icons/util/clock.svg"
const LOCK := "res://assets/icons/util/lock.svg"
const GAIN := "res://assets/icons/stake/cash_in.svg"
const LEVEL_KEYS := {
	"strong": "PRODUCT_LEVEL_STRONG", "enough": "PRODUCT_LEVEL_ENOUGH",
	"weak": "PRODUCT_LEVEL_WEAK", "none": "PRODUCT_LEVEL_NONE",
}
const RESULT_KEYS := {"expected": "PRODUCT_RESULT_EXPECTED", "actual": "PRODUCT_RESULT_ACTUAL"}
## Kart kipi "kapatır", öngörü kipi "kapanır" der.
const COUNT_KEYS := {
	"tickets": ["PRODUCT_FX_TICKETS_CLOSE", "PRODUCT_FX_TICKETS_CLOSED"],
	"voices": ["PRODUCT_FX_VOICES_CLOSE", "PRODUCT_FX_VOICES_CLOSED"],
}
## Kartın glif tuşları; listede olmayan tür (remove) kelimeyle yazılır.
const KEY_GLYPHS := {"add": "res://assets/icons/util/plus.svg", "send_next": ARROW,
	"pull": "res://assets/icons/util/chevron_up.svg"}


## `count` seviye karesi: dolu kare kelimenin renginde, yarım seviye (cila) kareyi yarıya kadar
## doldurur, boş kare çizgidir.
class Squares extends Control:
	var level: float
	var color: Color
	var count: int

	func _draw() -> void:
		var px: float = size.y
		for i in count:
			var r := Rect2(i * (px + UiTokens.SPACE_XXS), 0.0, px, px)
			var fill: float = clampf(level - i, 0.0, 1.0)
			if fill > 0.0:
				draw_rect(Rect2(r.position, Vector2(px * fill, px)), color)
			if fill < 1.0:
				draw_rect(r.grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.D_LINE_3, false, UiTokens.BORDER_HAIRLINE)


## Kapasite çubuğu: kart başına tek renk dilim, aralarında boşluk; bitmiş puanlar vurgulu, kapasitenin
## ötesi uyarı renginde ve kapasite bir çizgiyle işaretli. Ekip yoksa (0/0) yalnız çerçeve.
class CapacityBar extends Control:
	var cap: Dictionary

	func _init(capacity: Dictionary) -> void:
		cap = capacity
		custom_minimum_size.y = UiTokens.D_BAR_TICK.y
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var bar := Rect2(0.0, (size.y - UiTokens.D_H_BAR) / 2.0, size.x, UiTokens.D_H_BAR)
		var span: float = maxf(cap.total, cap.used)
		if span == 0:
			draw_rect(bar.grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.D_LINE_2, false, UiTokens.BORDER_HAIRLINE)
			return
		draw_rect(bar, UiTokens.D_BAR_TRACK)
		var unit: float = bar.size.x / span
		var limit: float = cap.total * unit
		var done: float = cap.done * unit
		var x := 0.0
		for seg in cap.segments:
			var w: float = seg.pts * unit
			for part in [[x, minf(x + w, done), UiTokens.D_BAR_EMPH], [maxf(x, done), minf(x + w, limit), UiTokens.D_BAR_FILL],
					[maxf(x, limit), x + w, UiTokens.D_warn()]]:
				var right: float = minf(part[1], x + w - UiTokens.SPACE_XXS)
				if right > part[0]:
					draw_rect(Rect2(part[0], bar.position.y, right - part[0], bar.size.y), part[2])
			x += w
		if cap.state == "over":
			draw_rect(Rect2(limit - UiTokens.D_BAR_TICK.x / 2.0, 0.0, UiTokens.D_BAR_TICK.x, size.y), UiTokens.D_INK_1)


static func squares(level: float, px: int, color: Color, count := 3) -> Control:
	var s := Squares.new()
	s.level = level
	s.color = color
	s.count = count
	s.custom_minimum_size = Vector2(count * px + (count - 1) * UiTokens.SPACE_XXS, px)
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## Kapasite çubuğu ve "kullanılan/toplam"; aşımda sayı da uyarı renginde.
static func capacity_row(cap: Dictionary, value_variation: StringName) -> HBoxContainer:
	var row := box(UiTokens.SPACE_L)
	row.add_child(CapacityBar.new(cap))
	row.add_child(label("%s/%s" % [points(cap.used), points(cap.total)], value_variation,
		UiTokens.D_warn() if cap.state == "over" else null))
	return row


## Sprint puanı iki ondalıkla, tam sayı ondalıksız ("4", "5,75"): Fmt.number tam sayıya da bir
## ondalık yazar ("4,0"), yuvarlanınca tamlaşana da ("4,996" → "5,0").
static func points(v: float) -> String:
	return Fmt.number(v, 2).trim_suffix(TranslationServer.translate("NUM_DECIMAL_SEP") + "0")


## Puan sayan anahtarın tekili, ekranda "1" okunan puandır: count_key tam sayı alır, 1,5'i 1'e keserdi.
static func points_key(key: String, shown: String) -> String:
	return Fmt.count_key(key, 1 if shown == "1" else 0)


## Seviye kelimesinin ve dolu karenin rengi.
static func word_color(word: String) -> Color:
	match word:
		"strong": return UiTokens.D_pos()
		"enough": return UiTokens.D_INK_3
		"weak": return UiTokens.D_warn()
	return UiTokens.D_INK_4


static func label(text: String, variation: StringName, color: Variant = null) -> Label:
	var l := UiFactory.make_label(text, variation, color)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


static func prose(text: String, variation: StringName) -> Label:
	var l := UiFactory.make_label(text, variation)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func box(separation: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", separation)
	return row


static func column(separation: int) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", separation)
	return col


## Margins (left, top, right, bottom) round a child.
static func pad(child: Control, sides: Vector4i) -> MarginContainer:
	var m := MarginContainer.new()
	for i in 4:
		m.add_theme_constant_override(["margin_left", "margin_top", "margin_right", "margin_bottom"][i], sides[i])
	m.add_child(child)
	return m


## Sürümün sonuç satırı: anahtarı ikincil mürekkepte ("Gerçekleşen:"), cümlesi metin mürekkebinde.
static func result_line(result: Dictionary, variation: StringName) -> HBoxContainer:
	var line := box(UiTokens.SPACE_S)
	var key := UiFactory.make_label(RnDUiShared.t(RESULT_KEYS[result.kind]), &"MetaMuted")
	key.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	line.add_child(key)
	line.add_child(prose(String(result.text), variation))
	return line


## Boş satır: glifi (varsa) ve notu; üstünde ve altında `room` boşluk (kartın başında ya da tek satırında 0).
static func empty_line(text: String, glyph_path := "", room := UiTokens.SPACE_M) -> MarginContainer:
	var line := box(UiTokens.SPACE_M)
	if glyph_path != "":
		line.add_child(UiFactory.make_glyph(glyph_path, UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
	line.add_child(label(text, &"MetaMuted"))
	return pad(line, Vector4i(0, room, 0, room))


## Büyük harfli bölüm etiketi ve sağa uzanan çizgi; `small` açık alanın alt bölümleri.
static func section(key: String, small := false) -> HBoxContainer:
	var row := box(UiTokens.SPACE_L)
	row.custom_minimum_size.y = UiTokens.D_H_SECTION_SM if small else UiTokens.D_H_SECTION
	row.add_child(label(Fmt.upper(RnDUiShared.t(key)), &"KeySmall" if small else &"KeyLabel"))
	var rule := HSeparator.new()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(rule)
	return row


## Bir kişinin yüzü; üstüne gelince adı ve rolü.
static func avatar(person: Dictionary, px: int) -> Panel:
	var face := UiFactory.make_person_avatar(String(person.name), person.get("look", {}), px)
	face.tooltip_text = String(person.name) if String(person.get("role_text", "")) == "" \
		else RnDUiShared.t("PRODUCT_PERSON_ROLE").format({"name": person.name, "role": person.role_text})
	face.mouse_filter = Control.MOUSE_FILTER_PASS
	return face


## Cümle düzeninde bayrak: rakip çıkışı nötr, bu ya da sonraki sprintte biten son tarih uyarı renginde.
static func flag(text: String, warn := false) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.theme_type_variation = UiTokens.D_variation(&"FlagChipWarn") if warn else &"FlagChip"
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := box(UiTokens.SPACE_S)
	if warn:
		row.add_child(UiFactory.make_glyph(CLOCK, UiTokens.D_ICON_PART, UiTokens.D_warn()))
	row.add_child(label(text, &"CaptionStrong", UiTokens.D_warn() if warn else null))
	chip.add_child(row)
	return chip


## Kartın glif tuşu (+, →, ↑); "+" kapalıyken de görünür.
static func key_button(kind: String, disabled: bool) -> Button:
	var b := Button.new()
	if KEY_GLYPHS.has(kind):
		b.theme_type_variation = &"IconKey"
		b.icon = load(KEY_GLYPHS[kind])
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = Vector2.ONE * UiTokens.D_H_KEY_SM
	else:
		b.theme_type_variation = &"CardKeyText"
		b.text = RnDUiShared.t("PRODUCT_REMOVE")
	b.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	b.disabled = disabled
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return b


## Sütun ve şerit düğmesi: metni ve görünümü, basılınca `on_press`.
static func button(text: String, variation: StringName, on_press: Callable) -> Button:
	var b := Button.new()
	b.theme_type_variation = variation
	b.text = text
	b.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(on_press)
	return b


## Kartın etki satırı: parçalar arasında boşluk, ayraç yok; seviye geçişi karelerle.
static func effect_line(parts: Array) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	for part in parts:
		flow.add_child(_part(part, false))
	return flow


## SPRINT SONUNDA öngörüsü: her parça kazanç glifiyle kendi kutusunda, seviye kelimeyle okunur.
static func forecast(parts: Array) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	for part in parts:
		var chip := PanelContainer.new()
		chip.theme_type_variation = &"FxChip"
		var row := _part(part, true)
		row.add_child(UiFactory.make_glyph(GAIN, UiTokens.D_ICON_PART, UiTokens.D_pos()))
		row.move_child(row.get_child(-1), 0)
		chip.add_child(row)
		flow.add_child(chip)
	return flow


static func _part(part: Dictionary, forecast_mode: bool) -> HBoxContainer:
	var row := box(UiTokens.SPACE_S)
	var say: StringName = &"KeyText" if forecast_mode else &"MetaMuted"
	match String(part.k):
		"level", "cap":
			row.add_child(label(String(part.area if part.k == "level" else part.name), &"KeyText"))
			for end in [["from", "from_word"], [], ["to", "to_word"]]:
				if end.is_empty():
					row.add_child(UiFactory.make_glyph(ARROW, UiTokens.D_ICON_MARK, UiTokens.D_INK_4))
				elif forecast_mode and part.k == "level":
					var word: String = part[end[1]]
					row.add_child(label(RnDUiShared.t(LEVEL_KEYS[word]), &"KeyText", word_color(word)))
				else:
					row.add_child(squares(float(part[end[0]]), UiTokens.D_SQUARE_SM, word_color(String(part[end[1]]))))
		"holds":
			row.add_child(label(String(part.area), &"KeyText"))
			row.add_child(label(RnDUiShared.t("PRODUCT_FX_HOLDS").format(
				{"level": RnDUiShared.t(LEVEL_KEYS[part.word])}), say))
		"alert_clear":
			row.add_child(label(String(part.area), &"KeyText"))
			row.add_child(UiFactory.make_glyph(WARN, UiTokens.D_ICON_PART, UiTokens.D_warn()))
			row.add_child(label(RnDUiShared.t("PRODUCT_FX_ALERT_CLEARS"), say))
		"tickets", "voices":
			var n: int = int(part.n)
			row.add_child(label(RnDUiShared.t(Fmt.count_key(COUNT_KEYS[part.k][int(forecast_mode)], n)).format({"n": n}), say))
		"request":
			row.add_child(label(RnDUiShared.t("PRODUCT_FX_REQUEST").format({"customer": part.customer}) + SEP
				+ RnDUiShared.t("PRODUCT_PER_YEAR").format({"amount": Fmt.money_exact(int(part.value))}), say))
		"rival_gap":
			row.add_child(label(RnDUiShared.t("PRODUCT_FX_RIVAL_GAP"), say))
		"research":
			row.add_child(label(String(part.area), &"KeyText"))
			row.add_child(label(RnDUiShared.t("PRODUCT_FX_RESEARCH"), say))
		"request_on_time":
			row.add_child(label(String(part.customer), &"KeyText"))
			row.add_child(label(RnDUiShared.t("PRODUCT_FX_ON_TIME"), say))
		"promise":
			if forecast_mode:
				row.add_child(label(String(part.customer), &"KeyText"))
				row.add_child(label(RnDUiShared.t("PRODUCT_FX_PROMISE_KEPT"), say))
			else:
				row.add_child(label(RnDUiShared.t("PRODUCT_FX_PROMISE").format({"customer": part.customer}), say))
	return row
