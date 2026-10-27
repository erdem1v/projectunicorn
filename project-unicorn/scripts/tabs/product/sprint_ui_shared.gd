class_name SprintUiShared
extends RefCounted

# Sprint ekranı bileşenlerinin ortak parçaları, koyu dilde. Hepsi statik: metin TranslationServer'dan
# okunur, çünkü statik fonksiyonda tr() çalışmaz.

const SEP := " · "
const KIND_ICON := "res://assets/icons/product/kind_%s.svg"
const ROLE_ICONS := {"design": "res://assets/icons/skill/design.svg", "dev": "res://assets/icons/skill/engineering.svg",
	"test": "res://assets/icons/skill/qa.svg", "product": "res://assets/icons/skill/product.svg"}
## Aşamanın adının anahtarı; "product" araştırma kartının çubuğudur.
const STAGE_KEYS := {"design": "PRODUCT_PHASE_DESIGN", "dev": "PRODUCT_PHASE_DEV", "test": "PRODUCT_PHASE_TEST",
	"product": "PRODUCT_STAGE_RESEARCH"}
## Kurucunun görüşmelerinin adı (`TimeModel.MEETING_DAYS` ile aynı anahtarlar).
const MEETING_KEYS := {"sales": "PRODUCT_MEETING_SALES", "vc": "PRODUCT_MEETING_VC", "table": "PRODUCT_MEETING_TABLE"}
const BUG := "res://assets/icons/product/bug.svg"
const ARROW := "res://assets/icons/util/arrow_right.svg"
const WARN := "res://assets/icons/util/warn.svg"
const CHECK := "res://assets/icons/util/check.svg"
const CLOCK := "res://assets/icons/util/clock.svg"
const FLAG := "res://assets/icons/util/flag.svg"
const PLUS := "res://assets/icons/util/plus.svg"
const CHEVRON_DOWN := "res://assets/icons/util/chevron_down.svg"
const HOURGLASS := "res://assets/icons/util/hourglass.svg"
const BUILDING := "res://assets/icons/util/building.svg"
const LOCK := "res://assets/icons/util/lock.svg"
const RESULT_KEYS := {"expected": "PRODUCT_RESULT_EXPECTED", "actual": "PRODUCT_RESULT_ACTUAL"}
## Kaydırma yeri yerleşim oturana dek bu kadar kare yeniden yazılır.
const SCROLL_SETTLE_FRAMES := 3
## Planlamada kartın tuşları: glifi ve ipucunun anahtarı.
const ROW_KEYS := {"send_next": [ARROW, "PRODUCT_TO_NEXT"], "pull": ["res://assets/icons/util/chevron_up.svg", "PRODUCT_TO_THIS"],
	"remove": ["res://assets/icons/util/close.svg", "PRODUCT_REMOVE"]}
## Hat satırının değişim oku: artış yukarı, azalış aşağı üçgen.
const TREND_ICONS := {1: "res://assets/icons/util/tri_up.svg", -1: "res://assets/icons/util/tri_down.svg"}


## `count` kare: soldan `level` kadarı `color`da dolu (kesirli seviye kareyi kısmen doldurur), gerisi çizgidir.
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


static func label(text: String, variation: StringName, color: Variant = null) -> Label:
	var l := UiFactory.make_label(text, variation, color)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


static func prose(text: String, variation: StringName, color: Variant = null) -> Label:
	var l := UiFactory.make_label(text, variation, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


## Zengin ipucunun kökü: `D_W_TIP` geniş bir sütun, menajer temalı (açılır pencere sahnenin temasını kalıtmaz).
static func tip_column() -> VBoxContainer:
	var tip := TipColumn.new()
	tip.add_theme_constant_override("separation", UiTokens.SPACE_L)
	tip.theme = load(UiTokens.MENAJER_THEME)
	tip.custom_minimum_size.x = UiTokens.D_W_TIP
	return tip


## Zengin ipucunun kök sütunu. Godot ipucu penceresini içerik kurulurken ölçer; satır kıran yazılar o an genişliklerini bilmediği için
## boy pencerenin boyuna uzar. Yerleşim oturdukça pencere içeriğin boyuna iner ve Godot'nun kuralıyla imlecin altına ya da üstüne konur.
class TipColumn extends VBoxContainer:
	func _ready() -> void:
		minimum_size_changed.connect(_fit, CONNECT_DEFERRED)
		_fit.call_deferred()

	func _fit() -> void:
		var win := get_window()
		if not win is Popup or win.get_parent() == null:
			return
		var host := win.get_parent().get_viewport()
		var want := Vector2i(win.get_contents_minimum_size().ceil())
		if want.y >= win.size.y:
			return
		var offset: Vector2 = ProjectSettings.get_setting("display/mouse_cursor/tooltip_position_offset", Vector2(10, 10))
		var mouse := host.get_mouse_position()
		# Godot ipucunu sahibinin (pencerenin ebeveyni) üstündeki imleçte açar; imleç sahibin dışında okunuyorsa (çekim, olayı
		# işletim sisteminin imlecini oynatmadan iter) sahibin ortası alınır.
		var owner_rect := (win.get_parent() as Control).get_global_rect() if win.get_parent() is Control else Rect2(mouse, Vector2.ZERO)
		if not owner_rect.has_point(mouse):
			mouse = owner_rect.get_center()
		var room := host.get_visible_rect()
		var top := mouse.y + offset.y
		if top + want.y > room.end.y:
			top = maxf(room.position.y, mouse.y - want.y - offset.y)
		win.size = Vector2i(win.size.x, want.y)
		win.position = Vector2i(win.position.x, roundi(top))


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


## Büyük harfli bölüm etiketi ve sağa uzanan çizgi.
static func section(key: String) -> HBoxContainer:
	var row := box(UiTokens.SPACE_L)
	row.custom_minimum_size.y = UiTokens.D_H_SECTION
	row.add_child(label(Fmt.upper(RnDUiShared.t(key)), &"KeyLabel"))
	var rule := HSeparator.new()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(rule)
	return row


## Bir kişinin yüzü (`grey`: sprinte seçilemeyen); üstüne gelince adı ve rolü.
static func avatar(person: Dictionary, px: int, grey := false) -> Panel:
	var face := UiFactory.make_person_avatar(String(person.name), person.get("look", {}), px, grey)
	face.tooltip_text = String(person.name) if String(person.get("role_text", "")) == "" \
		else RnDUiShared.t("PRODUCT_PERSON_ROLE").format({"name": person.name, "role": person.role_text})
	face.mouse_filter = Control.MOUSE_FILTER_PASS
	return face


## Yüzün yanında yıldız çipinin taştığı yeri de tutan hücre (`px` yüzün çapı).
static func face_slot(person: Dictionary, px: int) -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = Vector2(px + UiTokens.D_W_FACE_SLOT - UiTokens.D_AVATAR_ROW_SM, px)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(face(person, px))
	return slot


## Kimse çalışamıyorken çıkış yolu: kurucu araştırıyorsa Ar-Ge, kadro yoksa işe alım, varsa Ekip. `act` eylemin yayıcısıdır
## (`action.emit`).
static func way_out(c: Dictionary, variation: StringName, act: Callable) -> Button:
	var way: Array = (["PRODUCT_GO_RND", "rnd", {"node": c.rnd_node.id}] if c.rnd_node != null
		else ["PRODUCT_GO_TEAM", "team", {}] if c.staffed else ["HR_SEARCH_START", "hire", {}])
	var go := button(RnDUiShared.t(way[0]), variation, act.bind(way[1], way[2]))
	if way[1] == "hire":
		go.icon = load(PLUS)
	return go


## Planlamada üstüne gelince görünen kart tuşları ("→", "↑", "×"): glifli, kenarsız, üstüne gelinince yükselen zeminli; basılınca
## `act` eylemin adıyla ve {card_id} ile çağrılır. Başta görünmez.
static func row_keys(kinds: Array, card_id: String, act: Callable) -> PanelContainer:
	var acts := PanelContainer.new()
	acts.theme_type_variation = &"RowActs"
	var row := box(UiTokens.SPACE_XXS)
	acts.add_child(row)
	for kind: String in kinds:
		var key := Button.new()
		key.theme_type_variation = &"RowKey"
		key.icon = load(ROW_KEYS[kind][0])
		key.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key.custom_minimum_size = Vector2.ONE * UiTokens.D_H_KEY_SM
		key.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
		key.tooltip_text = RnDUiShared.t(ROW_KEYS[kind][1])
		key.pressed.connect(act.bind(kind, {"card_id": card_id}))
		row.add_child(key)
	acts.visible = false
	return acts


## Kişinin yıldızı: "3★", yarım yıldızda "3,5★".
static func stars_text(stars: float) -> String:
	return Fmt.number(stars, 0 if is_equal_approx(stars, roundf(stars)) else 1) + "★"


## Aşamanın adı.
static func stage_name(stage: String) -> String:
	return RnDUiShared.t(STAGE_KEYS[stage])


## Aşamanın ikonu: araştırma kartının çubuğu Ar-Ge'nin ikonunu taşır.
static func stage_icon(stage: String) -> String:
	return RnDUiShared.ICON if stage == "product" else ROLE_ICONS[stage]


## İpucunda kişi: "{ad} {yıldız}"; `name` kişinin tam adıdır, aynı adlı iki kişi böyle ayrılır.
static func named_stars(person: Dictionary) -> String:
	return "%s %s" % [person.name, stars_text(person.stars)]


## Aşama eksenden önce bitti: koşan sprintte önceki haftada ya da önceki sprintte önden (sonraki aşamanın başında tik kutusudur).
static func stage_done(stage: Dictionary) -> bool:
	return stage.before or (stage.need <= SprintSystem.EPS and stage.pre > SprintSystem.EPS)


## Eksenden önce biten aşamanın ipucu parçası: sprint başladığında işi kalmamışsa önceki sprintte önden bitti, yoksa bu sprintte
## (koşan sprintin önceki haftasında) bitti.
static func done_text(stage: Dictionary) -> String:
	return RnDUiShared.t("PRODUCT_AHEAD_DONE" if stage.need <= SprintSystem.EPS and stage.pre > SprintSystem.EPS else "PRODUCT_STAGE_DONE_NOW")


## İpucu parçası "efor {n}".
static func effort_tip(n: Variant) -> String:
	return RnDUiShared.t("PRODUCT_EFFORT_TIP").format({"n": n})


## "{PM} {yıldız} hazırladı: efor {önce} yerine {şimdi}" (PM'in kartı hazırlarken kısalttığı efor).
static func prepared_tip(pm: Dictionary, before: int, now: int) -> String:
	return RnDUiShared.t("PRODUCT_PM_PREPARED").format({"name": pm.name, "stars": stars_text(pm.stars), "before": before, "now": now})


## Kurucunun görüşme kalemleri, kalem başına bir satır: "{görüşme} · {n} gün" (hafta yazılmaz, bir tik hafta olduğu için gün yalnız
## görüşmenin süresidir).
static func meet_lines(kinds: Array) -> PackedStringArray:
	var out := PackedStringArray()
	for kind: String in kinds:
		out.append(_meet_line(kind, TimeModel.MEETING_DAYS[kind]))
	return out


## `stages`in taramalarının kalemleri: kurucunun haftasının görüşmeleri o hafta çalıştığı her aşamanın taramasında yazılıdır, bir hafta
## bir kez okunur. `total` doğruysa aynı türden kalemler tek satırdır, günleri toplanır ("Satış görüşmesi · 4 gün").
static func meet_lines_of(stages: Array, total := false) -> PackedStringArray:
	var kinds: Array = []
	var seen: Dictionary = {}
	for s: Dictionary in stages:
		for m: Dictionary in s.meet:
			if not seen.has(m.week):
				seen[m.week] = true
				kinds.append_array(m.kinds)
	if not total:
		return meet_lines(kinds)
	var days: Dictionary = {}
	for kind: String in kinds:
		days[kind] = days.get(kind, 0.0) + TimeModel.MEETING_DAYS[kind]
	return PackedStringArray(days.keys().map(func(kind: String) -> String: return _meet_line(kind, days[kind])))


static func _meet_line(kind: String, days: float) -> String:
	return SEP.join([RnDUiShared.t(MEETING_KEYS[kind]), count("PRODUCT_DAYS", roundi(days))])


## Kişinin yüzü ve işaretleri: kurucunun halkası, sağ altta yıldız çipi (`chip` yanlışsa çip yok); sprinte seçilemeyen (`away`) soluk
## gri durur, yıldız taşımaz. Çip yüzün sağ kenarına biner (`D_STAR_CHIP`), yüzün yanında `D_W_FACE_SLOT`ta yer tutulur.
static func face(person: Dictionary, px: int, away := false, chip := true) -> Panel:
	var disc: Panel = avatar(person, px, away)
	disc.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	if person.founder:
		var ring := Panel.new()
		ring.theme_type_variation = &"FaceRing"
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ring.offset_left = -UiTokens.BORDER_FOCUS
		ring.offset_top = -UiTokens.BORDER_FOCUS
		ring.offset_right = UiTokens.BORDER_FOCUS
		ring.offset_bottom = UiTokens.BORDER_FOCUS
		disc.add_child(ring)
	if away:
		disc.modulate.a = UiTokens.D_AWAY_ALPHA
	elif chip:
		var stars := label(stars_text(person.stars), &"StarChip")
		stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stars.anchor_left = 1.0
		stars.anchor_right = 1.0
		stars.anchor_top = 1.0
		stars.anchor_bottom = 1.0
		stars.grow_horizontal = Control.GROW_DIRECTION_END
		stars.grow_vertical = Control.GROW_DIRECTION_BEGIN
		stars.offset_left = -UiTokens.D_STAR_CHIP.x
		stars.offset_right = -UiTokens.D_STAR_CHIP.x
		stars.offset_top = UiTokens.D_STAR_CHIP.y
		stars.offset_bottom = UiTokens.D_STAR_CHIP.y
		disc.add_child(stars)
	return disc


## Çeyrek hedefinin menüsü, SPRINT başlığının seçicisi ile ÇEYREK şeridinin ortak işlevi: "Hedef yok", her alan adıyla ve hedef
## cümlesiyle, "Hatalar"; tik seçili olanda. Seçim `on_pick(kimlik)` ile ertelenir: sekme eylemde yeniden kurar, menü kendi
## sinyali akarken ağaçtan sökülmez.
static func open_goal_menu(anchor: Control, areas: Array, picked: String, on_pick: Callable) -> void:
	var menu := HRPopover.mount(anchor, true)
	menu.body().custom_minimum_size.x = UiTokens.D_W_GOAL_MENU
	menu.body().add_theme_constant_override("separation", 0)
	var choices: Array = [["", RnDUiShared.t("PRODUCT_GOAL_NONE_ITEM"), ""]]
	for a in areas:
		choices.append([a.id, a.name, Fmt.cap_first(a.goal_text)])
	choices.append([SprintCatalog.GOAL_BUGS, RnDUiShared.t("PRODUCT_QUARTER_BUGS"), ""])
	for choice in choices:
		var item := Button.new()
		item.theme_type_variation = &"MenuItem"
		item.focus_mode = Control.FOCUS_NONE
		var row := box(UiTokens.SPACE_M)
		var check := UiFactory.make_glyph(CHECK, UiTokens.D_ICON_ROW, UiTokens.D_INK_1)
		check.modulate.a = 1.0 if choice[0] == picked else 0.0
		check.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(pad(check, Vector4i(0, UiTokens.SPACE_XXS, 0, 0)))
		var words := column(UiTokens.SPACE_XXS)
		words.add_child(UiFactory.make_label(String(choice[1]), &"DataMedium", UiTokens.D_INK_1))
		if choice[2] != "":
			words.add_child(UiFactory.make_label(String(choice[2]), &"Caption"))
		row.add_child(words)
		var inset := pad(row, Vector4i(UiTokens.SPACE_M, UiTokens.SPACE_S, UiTokens.SPACE_M, UiTokens.SPACE_S))
		inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(inset)
		item.pressed.connect(func() -> void:
			menu.close()
			on_pick.call_deferred(choice[0]))
		menu.body().add_child(item)
		item.custom_minimum_size.y = inset.get_combined_minimum_size().y
	menu.open_at(anchor, true)


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


## Söz tarihinin çipi: kum saati ve "bu çeyrek", "gelecek çeyrek" ya da "{q}. çeyrek" (`glyph` "" ise yalnız yazı: sprint damgası).
## Hâlleri aynı boydadır; yakın olan yalnız daha açık mürekkep ve kenarla ayrılır.
static func due_chip(text: String, soon := false, glyph := HOURGLASS) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.theme_type_variation = &"DueChipSoon" if soon else &"DueChip"
	chip.size_flags_horizontal = Control.SIZE_SHRINK_END
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ink: Color = UiTokens.D_INK_1 if soon else UiTokens.D_INK_2
	var row := box(UiTokens.SPACE_XS)
	if glyph != "":
		row.add_child(UiFactory.make_glyph(glyph, UiTokens.D_ICON_TAG, ink))
	row.add_child(label(text, &"CaptionName", ink))
	chip.add_child(row)
	return chip


## Adayın "+" tuşunun tema görünümü: parlak, ya da değeri henüz bilinmiyorsa sönük.
static func add_look(lit: bool) -> StringName:
	return &"IconKey" if lit else &"IconKeyIdle"


## Adayın "+" tuşu; kapalıyken de görünür.
static func add_key() -> Button:
	var b := Button.new()
	b.theme_type_variation = add_look(true)
	b.icon = load(PLUS)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.custom_minimum_size = Vector2.ONE * UiTokens.D_H_KEY_SM
	b.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return b


## Şeridin etiketli anahtarı: soluk adı ve yanında anahtar `row`'a eklenir; `tip` ikisinin de ipucudur. `off` anahtarı soluk
## ve basılmaz yapar, değeri gösterir.
static func switch(row: Control, text: String, on: bool, toggled: Callable, tip := "", off := false) -> void:
	var title := label(text, &"MetaMuted", UiTokens.D_INK_OFF if off else null)
	if tip != "":
		title.mouse_filter = Control.MOUSE_FILTER_STOP
		title.tooltip_text = tip
	row.add_child(title)
	var toggle := CheckButton.new()
	toggle.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	toggle.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	toggle.tooltip_text = tip
	toggle.button_pressed = on
	toggle.toggled.connect(toggled)
	toggle.disabled = off
	row.add_child(toggle)


## Yeniden kurulan kaydırma alanı eski yerine döner: yerleşmemiş içerik değeri sıfıra kırpardı, bu yüzden çubuğun üst sınırı
## değer kadar açılır ve içerik yerleşince gerçek sınırı alır. Sarılan yazı bir sonraki karede oturur ve yerleşimin geçici sayfa
## boyu değeri kırpabilir: değer yerleşim oturana dek her karede yeniden yazılır.
static func keep_scroll(scroll: ScrollContainer, value: int) -> void:
	if value <= 0:
		return
	var bar: VScrollBar = scroll.get_v_scroll_bar()
	bar.max_value = maxf(bar.max_value, value + bar.page + 1.0)
	scroll.scroll_vertical = value
	_settle_scroll(scroll, value)


static func _settle_scroll(scroll: ScrollContainer, value: int) -> void:
	var tree: SceneTree = scroll.get_tree()
	for _frame in SCROLL_SETTLE_FRAMES:
		await tree.process_frame
		if not is_instance_valid(scroll):
			return
		scroll.scroll_vertical = value


## Sütun ve şerit düğmesi: metni ve görünümü, basılınca `on_press`.
static func button(text: String, variation: StringName, on_press: Callable) -> Button:
	var b := Button.new()
	b.theme_type_variation = variation
	b.text = text
	b.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(on_press)
	return b


## Düzeltme kartının hata satırı: "6 hata · 3 hesap · 140 kullanıcı · en büyüğü Demir Holding (100 kullanıcı)"; `with_top`
## yanlışsa en büyük hesap yazılmaz. B2C'de hesap sayısı (-1) ve en büyük hesap yoktur.
static func bugs_text(part: Dictionary, with_top := true) -> String:
	var bits: PackedStringArray = [count("PRODUCT_FX_BUGS", int(part.n))]
	bits.append_array(impact_bits(part))
	if with_top and part.top != "":
		bits.append(RnDUiShared.t("PRODUCT_FX_TOP").format(
			{"account": part.top, "users": count("PRODUCT_USER_COUNT", int(part.top_users))}))
	return SEP.join(bits)


## Hata parçasının etkilenenleri: "3 hesap", "140 kullanıcı"; B2C'de hesap sayısı (-1) yazılmaz.
static func impact_bits(part: Dictionary) -> PackedStringArray:
	var bits := PackedStringArray()
	if int(part.accounts) >= 0:
		bits.append(count("PRODUCT_ACCOUNT_COUNT", int(part.accounts)))
	bits.append(count("PRODUCT_USER_COUNT", int(part.users)))
	return bits


## Hat satırı (`ProductModel.bug_row_of`): metni, sağında son haftalık tikten bu yana değişim oku (artış uyarı renginde,
## azalış olumlu renkte; değişmediyse yuvası boş kalır, satırlar aynı genişlikte sarar); ayrıntı ipucunda.
static func bug_line(row: Dictionary, variation: StringName) -> HBoxContainer:
	var line := box(UiTokens.SPACE_M)
	line.tooltip_text = row.tip
	line.add_child(prose(String(row.text), variation))
	var delta: int = int(row.delta)
	if delta == 0:
		var slot := Control.new()
		slot.custom_minimum_size.x = UiTokens.D_ICON_TAG
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(slot)
	else:
		line.add_child(UiFactory.make_glyph(TREND_ICONS[signi(delta)], UiTokens.D_ICON_TAG,
			UiTokens.D_warn() if delta > 0 else UiTokens.D_pos()))
	return line


## Ürün penceresi SPRINT'te, `area_id` alanı açık: önce sayfa açılır, sayfa kendi durumunu kurulurken alanı tohumlar.
static func open_product_area(tree: SceneTree, area_id: String) -> void:
	EventBus.tab_changed.emit("product")
	tree.get_first_node_in_group(&"window_layer").get_current_page_body().open_area(area_id)


## Sayılan anahtarın metni: `n` 1 ise tekili, binlik ayraçlı.
static func count(key: String, n: int) -> String:
	return RnDUiShared.t(Fmt.count_key(key, n)).format({"n": Fmt.group(n)})
