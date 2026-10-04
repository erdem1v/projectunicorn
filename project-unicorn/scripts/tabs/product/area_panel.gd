class_name AreaPanel
extends VBoxContainer

# Ürün sprint ekranının sol paneli: Geçmiş açıksa sürüm listesi, B2B'de Müşteriler satırı (son tarihli
# talepler bir bakışta görünsün diye en üstte), sonra alan satırları (aynı anda tek açık akordeon), açık
# alanın yetenekleri, aday kartları ve sesleri. Panel modeli çizer. Akordeonun ve ses katlamasının
# sahibi sekmedir: tık `ui_changed` olarak çıkar, sekme durumu yazıp paneli yeniden kurar.

signal action(kind: String, args: Dictionary)
signal ui_changed(open_area: String, voices_open: bool)

const CARD_SCENE := preload("res://scenes/tabs/product/SprintCard.tscn")
const CHEVRONS := ["res://assets/icons/util/chevron_right.svg", "res://assets/icons/util/chevron_down.svg"]

var _model: Dictionary
var _compact := false
var _open := ""
var _voices_open := false


## compact: çeyrek görünümünün dar sütunu; satır açılmaz, şevron, rakip bayrağı ve talep kartı yok.
## Aday kartları kurulurken ağaçta olmalı: panel sahnedeyken çağrılır.
func setup(model: Dictionary, compact: bool) -> void:
	_model = model
	_compact = compact
	_open = "" if compact else String(model.ui.open_area)
	_voices_open = bool(model.ui.voices_open)
	UiFactory.clear(self)
	add_theme_constant_override("separation", 0)
	if _model.ui.history_open and not compact:
		_add_history()
	if _model.customers != null:
		_add_customers(_model.customers)
	add_child(SprintUiShared.section("PRODUCT_AREAS"))
	for area in _model.areas:
		_add_area_row(area)


## Sürümler, en yenisi üstte: "v1.4 Sprint 6 · 2 kart", altında beklenen ya da gerçekleşen sonuç.
## Bilinmeyen (-1) parça yazılmaz: eski sürüm kayıtları sprint ve kart sayısı taşımıyor.
func _add_history() -> void:
	add_child(SprintUiShared.section("PRODUCT_HISTORY"))
	var list := SprintUiShared.column(0)
	add_child(SprintUiShared.pad(list, Vector4i(UiTokens.SPACE_XL, 0, UiTokens.SPACE_XL, UiTokens.SPACE_M)))
	if _model.versions.is_empty():
		list.add_child(SprintUiShared.empty_line(tr("PRODUCT_HISTORY_NONE")))
	for i in range(_model.versions.size() - 1, -1, -1):
		var v: Dictionary = _model.versions[i]
		var row := PanelContainer.new()
		row.theme_type_variation = &"TableRow"
		var lines := SprintUiShared.column(UiTokens.SPACE_XS)
		row.add_child(SprintUiShared.pad(lines, Vector4i(0, UiTokens.SPACE_M, 0, UiTokens.SPACE_M)))
		var head := SprintUiShared.box(UiTokens.SPACE_M)
		head.add_child(SprintUiShared.label(String(v.label), &"DataStrong"))
		var parts := PackedStringArray()
		if int(v.sprint) >= 0:
			parts.append(tr("PRODUCT_TAG_SPRINT").format({"n": int(v.sprint)}))
		var n: int = int(v.shipped_count)
		if n >= 0:
			parts.append(tr(Fmt.count_key("PRODUCT_HISTORY_CARDS", n)).format({"n": n}))
		if not parts.is_empty():
			head.add_child(SprintUiShared.label(SprintUiShared.SEP.join(parts), &"MetaMuted"))
		lines.add_child(head)
		if v.result != null:
			lines.add_child(SprintUiShared.result_line(v.result, &"MetaText"))
		list.add_child(row)


## Alan satırı: ad, uyarı üçgeni ve şevron; seviye kareleri ve kelimesi, sağda ses sayacı ve rakip
## bayrağı; cümlesi. Açık satır yükselir ve gövdesini taşır.
func _add_area_row(area: Dictionary) -> void:
	var id: String = area.id
	var open: bool = id == _open
	var row := HRUiShared.D_row(open)
	row.custom_minimum_size.y = 0
	add_child(row)
	var col := SprintUiShared.column(0)
	var inset: int = UiTokens.SPACE_L if _compact else UiTokens.SPACE_XL
	row.add_child(SprintUiShared.pad(col, Vector4i(inset, UiTokens.SPACE_M if _compact else UiTokens.SPACE_L,
		inset, UiTokens.SPACE_M if _compact else UiTokens.SPACE_L)))

	var head := SprintUiShared.column(0)
	col.add_child(head)
	if not _compact:
		head.mouse_filter = Control.MOUSE_FILTER_STOP
		head.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		head.gui_input.connect(_on_area_input.bind(id))
	var top := SprintUiShared.box(UiTokens.SPACE_M)
	top.custom_minimum_size.y = UiTokens.D_H_TAG
	head.add_child(top)
	var title := SprintUiShared.label(String(area.name), &"DataStrong")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top.add_child(title)
	if area.alert:
		top.add_child(UiFactory.make_glyph(SprintUiShared.WARN, UiTokens.D_ICON_ROW, UiTokens.D_warn()))
	if not _compact:
		top.add_child(UiFactory.make_glyph(CHEVRONS[int(open)], UiTokens.D_ICON_ROW,
			UiTokens.D_INK_2 if open else UiTokens.D_INK_4))

	var level := SprintUiShared.box(UiTokens.SPACE_M)
	head.add_child(SprintUiShared.pad(level, Vector4i(0, UiTokens.SPACE_S, 0, 0)))
	var word: String = area.word
	level.add_child(SprintUiShared.squares(float(area.level), UiTokens.D_SQUARE, SprintUiShared.word_color(word)))
	# Sürüm notunda bu sürümde değişen alan oklu okunur: kareler ve kelimeler eskiden yeniye.
	if int(area.level_to) >= 0:
		level.add_child(UiFactory.make_glyph(SprintUiShared.ARROW, UiTokens.D_ICON_MARK, UiTokens.D_INK_4))
		level.add_child(SprintUiShared.squares(float(area.level_to), UiTokens.D_SQUARE,
			SprintUiShared.word_color(area.word_to)))
		level.add_child(SprintUiShared.label(tr(SprintUiShared.LEVEL_KEYS[word]), &"MetaMuted"))
		level.add_child(UiFactory.make_glyph(SprintUiShared.ARROW, UiTokens.D_ICON_MARK, UiTokens.D_INK_4))
		word = area.word_to
	level.add_child(SprintUiShared.label(tr(SprintUiShared.LEVEL_KEYS[word]), &"KeyText",
		SprintUiShared.word_color(word)))
	level.add_child(RnDUiShared.spacer())
	if int(area.voices.n) > 0:
		var chip := PanelContainer.new()
		chip.theme_type_variation = &"CountChip"
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE   # PanelContainer tıkı yutar; satır başlığına geçsin
		var counts := SprintUiShared.box(UiTokens.SPACE_XS)
		chip.add_child(counts)
		_add_voice_counts(counts, area.voices, false)
		level.add_child(chip)
	if not _compact and area.rival_topic != "":
		level.add_child(SprintUiShared.flag(tr("PRODUCT_RIVAL_TOPIC").format({"topic": area.rival_topic})))

	var sentence := SprintUiShared.prose(String(area.sentence), &"Caption")
	head.add_child(SprintUiShared.pad(sentence, Vector4i(0, UiTokens.SPACE_XS, 0, 0)))
	if open:
		_add_open_body(col, area)


## Açık satırın gövdesi: YAPILANLAR (yetenek, kademe, rakipler), YAPILABİLECEKLER (aday kartlar), SESLER.
func _add_open_body(col: VBoxContainer, area: Dictionary) -> void:
	var body := SprintUiShared.column(UiTokens.SPACE_M)
	col.add_child(SprintUiShared.pad(body, Vector4i(0, UiTokens.SPACE_L, 0, 0)))
	body.add_child(SprintUiShared.section("PRODUCT_BUILT", true))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_XL)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	body.add_child(grid)
	for cap in area.capabilities:
		var tier: int = int(cap.tier)
		var cap_name := SprintUiShared.label(String(cap.name), &"MetaText" if tier > 0 else &"MetaMuted")
		cap_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(cap_name)
		# Kademe bir durum değil miktar: dolu kareler nötr mürekkepte.
		grid.add_child(SprintUiShared.squares(tier, UiTokens.D_SQUARE_SM, SprintUiShared.word_color("enough")))
		var rivals := SprintUiShared.label(tr("PRODUCT_RIVALS_HAVE").format(
			{"have": int(cap.rivals_have), "total": int(cap.rivals_total)}), &"Caption")
		rivals.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		rivals.tooltip_text = SprintUiShared.SEP.join(PackedStringArray(cap.rival_names))
		rivals.mouse_filter = Control.MOUSE_FILTER_PASS   # Label varsayılanı IGNORE; ipucu fareyi ister
		grid.add_child(rivals)

	body.add_child(SprintUiShared.section("PRODUCT_POSSIBLE", true))
	if area["empty"]:
		body.add_child(SprintUiShared.empty_line(tr("PRODUCT_AREA_NOTHING_LEFT"), SprintUiShared.CHECK))
	for c in area.candidates:
		var card: SprintCard = CARD_SCENE.instantiate()
		body.add_child(card)
		card.setup(c, bool(_model.center.can_add), SprintCard.Look.LOW)
		card.action.connect(action.emit)

	var voices: Dictionary = area.voices
	if int(voices.n) == 0:
		return
	body.add_child(SprintUiShared.section("PRODUCT_VOICES", true))
	var fold := SprintUiShared.box(UiTokens.SPACE_M)
	fold.custom_minimum_size.y = UiTokens.D_H_FX
	fold.mouse_filter = Control.MOUSE_FILTER_STOP
	fold.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	fold.gui_input.connect(_on_voices_input.bind(area.id))
	body.add_child(fold)
	_add_voice_counts(fold, voices, true)
	fold.add_child(RnDUiShared.spacer())
	fold.add_child(UiFactory.make_glyph(CHEVRONS[int(_voices_open)], UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	if not _voices_open:
		return
	for v in area.voices_list:
		var line := SprintUiShared.box(UiTokens.SPACE_M)
		if v["new"]:
			line.add_child(UiFactory.D_tag(tr("PRODUCT_NEW_STAMP")))
		line.add_child(SprintUiShared.prose(String(v.text), &"MetaText"))
		body.add_child(line)


## Ses sayacı: kapalı satırın çipinde yalnız sayı, SESLER satırında "n ses"; yeni ses varsa "· k yeni".
func _add_voice_counts(box: HBoxContainer, voices: Dictionary, worded: bool) -> void:
	var n: int = int(voices.n)
	var fresh: int = int(voices["new"])
	box.add_child(UiFactory.make_glyph(SprintUiShared.VOICES, UiTokens.D_ICON_ROW if worded else UiTokens.D_ICON_PART,
		UiTokens.D_INK_3))
	var small: StringName = &"MetaText" if worded else &"CaptionPrimary"
	box.add_child(SprintUiShared.label(tr(Fmt.count_key("PRODUCT_VOICES_COUNT", n)).format({"n": n}) if worded
		else str(n), small))
	if fresh > 0:
		box.add_child(SprintUiShared.label(SprintUiShared.SEP.strip_edges(), small, UiTokens.D_INK_4))
		box.add_child(SprintUiShared.label(tr("PRODUCT_NEW_COUNT").format({"n": fresh}),
			&"TipTitle" if worded else &"CaptionStrong", UiTokens.D_INK_1))


## Müşteriler: talep sayısı ve talep kartları; dar sütunda yalnız başlık ve sayı.
func _add_customers(customers: Array) -> void:
	var row := HRUiShared.D_row(false)
	row.custom_minimum_size.y = 0
	add_child(row)
	var col := SprintUiShared.column(UiTokens.SPACE_M)
	var inset: int = UiTokens.SPACE_L if _compact else UiTokens.SPACE_XL
	row.add_child(SprintUiShared.pad(col, Vector4i(inset, UiTokens.SPACE_L, inset, UiTokens.SPACE_L)))
	var top := SprintUiShared.box(UiTokens.SPACE_M)
	top.custom_minimum_size.y = UiTokens.D_H_TAG
	col.add_child(top)
	var title := SprintUiShared.label(tr("PRODUCT_CUSTOMERS"), &"DataStrong")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var n: int = customers.size()
	top.add_child(SprintUiShared.label(tr(Fmt.count_key("PRODUCT_REQUESTS_COUNT", n)).format({"n": n})
		if n > 0 else tr("PRODUCT_CUSTOMERS_NONE"), &"Caption"))
	if _compact:
		return
	for c in customers:
		col.add_child(_customer_card(c))


## Talep kartı: "müşteri · talep" ve planlı sprintin etiketi ya da "+" ve "→"; altında son tarih (bu ya da
## sonraki sprintte bitiyorsa uyarı renginde), yıllık bedel ve alan. Talebi olmayan müşteri tek satırlık
## ticket sayısıdır.
func _customer_card(c: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"SprintCard"
	var col := SprintUiShared.column(UiTokens.SPACE_M)
	card.add_child(col)
	var top := SprintUiShared.box(UiTokens.SPACE_M)
	col.add_child(top)
	var tickets: int = int(c.tickets)
	var title := SprintUiShared.label(String(c.name) + SprintUiShared.SEP + String(c.request) if c.request != ""
		else tr(Fmt.count_key("PRODUCT_CUSTOMER_TICKETS", tickets)).format({"customer": c.name, "n": tickets}), &"DataStrong")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top.add_child(title)
	if c.request == "":
		return card
	if int(c.tag_sprint) >= 0:
		top.add_child(UiFactory.D_tag(tr("PRODUCT_TAG_SPRINT").format({"n": int(c.tag_sprint)}), &"outline"))
	for kind in c.buttons:
		var b := SprintUiShared.key_button(kind, kind == "add" and not _model.center.can_add)
		b.pressed.connect(action.emit.bind(kind, {"card_id": c.card_id}))
		top.add_child(b)

	var terms := HFlowContainer.new()
	terms.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	terms.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	col.add_child(terms)
	if int(c.due_sprint) >= 0:
		var soon: bool = int(c.due_sprint) <= int(_model.center.sprint) + 1
		var due := SprintUiShared.box(UiTokens.SPACE_S)
		due.add_child(UiFactory.make_glyph(SprintUiShared.CLOCK, UiTokens.D_ICON_PART,
			UiTokens.D_warn() if soon else UiTokens.D_INK_4))
		due.add_child(SprintUiShared.label(tr("PRODUCT_DUE_SPRINT").format({"n": int(c.due_sprint)}), &"MetaMuted",
			UiTokens.D_warn() if soon else null))
		terms.add_child(due)
	terms.add_child(SprintUiShared.label(tr("PRODUCT_PER_YEAR").format({"amount": Fmt.money_exact(int(c.value))}),
		&"KeyText"))
	if String(c.area_name) != "":
		terms.add_child(SprintUiShared.flag(String(c.area_name)))
	return card


func _on_area_input(ev: InputEvent, id: String) -> void:
	if UiFactory.is_left_click(ev):
		ui_changed.emit("" if _open == id else id, false)


func _on_voices_input(ev: InputEvent, id: String) -> void:
	if not UiFactory.is_left_click(ev):
		return
	if not _voices_open:
		action.emit("voices_seen", {"area": id})
	ui_changed.emit(_open, not _voices_open)
