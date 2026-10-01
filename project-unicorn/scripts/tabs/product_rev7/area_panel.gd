class_name AreaPanel
extends VBoxContainer

# Ürün sprint ekranının sol paneli: alan satırları (aynı anda tek açık akordeon), açık alanın
# yetenekleri, aday kartları ve sesleri; B2B'de akordeonun dışında hep açık Müşteriler satırı.
# Panel modeli çizer. Akordeonun ve ses katlamasının sahibi sekmedir: tık `ui_changed` olarak
# çıkar, sekme durumu yazıp paneli yeniden kurar.

signal action(kind: String, args: Dictionary)
signal ui_changed(open_area: String, voices_open: bool)

const CARD_SCENE := preload("res://scenes/tabs/product_rev7/SprintCard.tscn")
## B2B'de Gelir alanı yok; Müşteriler satırı onun boş kalan renk yuvasını taşır.
const CUSTOMERS_SLOT := 4

var _model: Dictionary
var _compact := false
var _open := ""
var _voices_open := false


func _init() -> void:
	add_theme_constant_override(&"separation", UiTokens.PRODUCT_CARD_GAP)


## compact: çeyrek görünümünün dar sütunu; satır açılmaz, şevron ve rakip çipi yok.
## Aday kartları kurulurken ağaçta olmalı: panel sahnedeyken çağrılır.
func setup(model: Dictionary, compact: bool) -> void:
	_model = model
	_compact = compact
	_open = "" if compact else String(model.ui.open_area)
	_voices_open = bool(model.ui.voices_open)
	UiFactory.clear(self)
	if _model.ui.history_open:
		_add_history()
	add_child(HRUiShared.section_header(tr("PRODUCT_AREAS"), true, &"SectionAmber"))
	for area in _model.areas:
		_add_area_row(area)
	if _model.customers != null:
		_add_customers_row(_model.customers)


func _add_history() -> void:
	add_child(HRUiShared.section_header(tr("PRODUCT_HISTORY"), true, &"SectionAmber"))
	if _model.versions.is_empty():
		add_child(UiFactory.make_label(tr("PRODUCT_HISTORY_NONE"), &"EmptyRowLabel"))
	# Bilinmeyen (-1) parça yazılmaz: eski sürüm kayıtları sprint ve kart sayısı taşımıyor.
	for v in _model.versions:
		var parts := PackedStringArray([v.label])
		if int(v.sprint) >= 0:
			parts.append(tr("PRODUCT_TAG_SPRINT").format({"n": int(v.sprint)}))
		var n: int = int(v.shipped_count)
		if n >= 0:
			parts.append(tr(Fmt.count_key("PRODUCT_HISTORY_CARDS", n)).format({"n": n}))
		add_child(UiFactory.make_label(SprintUiShared.SEP.join(parts), &"RowMeta"))


func _add_area_row(area: Dictionary) -> void:
	var id: String = area.id
	var open: bool = id == _open
	var row := _edged_card(int(area.slot))
	if open:
		row.theme_type_variation = &"PaperCardOpen"
	elif area.tone == "alert":
		var sb: StyleBoxFlat = ThemeDB.get_project_theme().get_stylebox(&"panel", &"PaperCard").duplicate()
		sb.bg_color = UiTokens.negative_bg()
		sb.border_color = UiTokens.negative_rule()
		row.add_theme_stylebox_override(&"panel", sb)
	add_child(row)
	var body := _vbox(UiTokens.SPACE_M)
	row.add_child(body)

	var head := _vbox(UiTokens.SPACE_XXS)
	body.add_child(head)
	if not _compact:
		head.mouse_filter = Control.MOUSE_FILTER_STOP
		head.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		head.gui_input.connect(_on_area_input.bind(id))

	var top := _hbox(UiTokens.SPACE_S)
	head.add_child(top)
	var title := UiFactory.make_label(area.name, &"AreaName")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	if int(area.voices.n) > 0:
		var chip := PanelContainer.new()
		chip.theme_type_variation = &"ChipAmber" if int(area.voices["new"]) > 0 else &"ChipNeutral"
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE   # PanelContainer tıkı yutar; satır başlığına geçsin
		var counts := _hbox(UiTokens.SPACE_XS)
		chip.add_child(counts)
		_add_voice_counts(counts, area.voices, false)
		top.add_child(chip)
	if area.alert:
		top.add_child(SprintUiShared.attention_badge())
	if not _compact:
		if area.rival_topic != "":
			top.add_child(SprintUiShared.stamp(
				tr("PRODUCT_RIVAL_TOPIC").format({"topic": area.rival_topic}), &"Stamp"))
		top.add_child(_chevron(open))

	var level := _hbox(UiTokens.SPACE_S)
	head.add_child(level)
	var word: String = area.word
	level.add_child(SprintUiShared.slices(float(area.level), UiTokens.PRODUCT_SLICE_PX, SprintUiShared.word_color(word)))
	# Sürüm notunda bu sürümde değişen alan oklu okunur: dilimler ve kelimeler eskiden yeniye.
	if int(area.level_to) >= 0:
		level.add_child(SprintUiShared.icon("arrow", UiTokens.PRODUCT_ICON_PX, UiTokens.INK_MUTED))
		level.add_child(SprintUiShared.slices(float(area.level_to), UiTokens.PRODUCT_SLICE_PX,
			SprintUiShared.word_color(area.word_to)))
		level.add_child(UiFactory.make_label(tr(SprintUiShared.LEVEL_KEYS[word]), &"RowMeta"))
		level.add_child(SprintUiShared.icon("arrow", UiTokens.PRODUCT_ICON_PX, UiTokens.INK_MUTED))
		word = area.word_to
	level.add_child(UiFactory.make_label(tr(SprintUiShared.LEVEL_KEYS[word]), &"RowMetaStrong",
		SprintUiShared.word_color(word)))

	var sentence := UiFactory.make_label(area.sentence, &"AreaSentence")
	sentence.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.add_child(sentence)
	if open:
		_add_open_body(body, area)


## Açık satır: YAPILANLAR (yetenek · kademe · rakipler), YAPILABİLECEKLER (aday kartlar), SESLER.
func _add_open_body(body: VBoxContainer, area: Dictionary) -> void:
	var built := _section(body, "PRODUCT_BUILT")
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override(&"h_separation", UiTokens.SPACE_L)
	grid.add_theme_constant_override(&"v_separation", UiTokens.SPACE_XS)
	built.add_child(grid)
	for cap in area.capabilities:
		var tier: int = int(cap.tier)
		grid.add_child(UiFactory.make_label(cap.name, &"RowMetaStrong" if tier > 0 else &"RowMeta"))
		# Kademe bir durum değil miktar: dolu kareler Yeterli'nin nötr mürekkebini alır.
		grid.add_child(SprintUiShared.slices(tier, UiTokens.PRODUCT_SLICE_PX_SMALL, SprintUiShared.word_color("enough")))
		var rivals := SprintUiShared.stamp(tr("PRODUCT_RIVALS_HAVE").format(
			{"have": int(cap.rivals_have), "total": int(cap.rivals_total)}), &"Stamp")
		rivals.tooltip_text = SprintUiShared.SEP.join(PackedStringArray(cap.rival_names))
		rivals.mouse_filter = Control.MOUSE_FILTER_PASS   # Label varsayılanı IGNORE; ipucu fareyi ister
		grid.add_child(rivals)

	var possible := _section(body, "PRODUCT_POSSIBLE")
	if area["empty"]:
		possible.add_child(UiFactory.make_label(tr("PRODUCT_AREA_NOTHING_LEFT"), &"EmptyRowLabel"))
	for c in area.candidates:
		var card: SprintCard = CARD_SCENE.instantiate()
		possible.add_child(card)
		card.setup(c, bool(_model.center.can_add))
		card.action.connect(action.emit)

	var voices: Dictionary = area.voices
	if int(voices.n) == 0:
		return
	var heard := _section(body, "PRODUCT_VOICES")
	var fold := _hbox(UiTokens.SPACE_S)
	fold.mouse_filter = Control.MOUSE_FILTER_STOP
	fold.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	fold.gui_input.connect(_on_voices_input.bind(area.id))
	heard.add_child(fold)
	_add_voice_counts(fold, voices, true)
	fold.add_child(RnDUiShared.spacer())
	fold.add_child(_chevron(_voices_open))
	if not _voices_open:
		return
	for v in area.voices_list:
		var line := _hbox(UiTokens.SPACE_S)
		heard.add_child(line)
		if v["new"]:
			line.add_child(SprintUiShared.stamp(tr("PRODUCT_NEW_STAMP"), &"StampAmber"))
		var text := UiFactory.make_label(v.text, &"AreaSentence")
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(text)


## Ses sayacı: kapalı satırın çipinde yalnız sayı, SESLER satırında "n ses"; yeni ses varsa amber "· k yeni".
func _add_voice_counts(box: HBoxContainer, voices: Dictionary, worded: bool) -> void:
	var n: int = int(voices.n)
	var fresh: int = int(voices["new"])
	box.add_child(SprintUiShared.icon("bubble", UiTokens.PRODUCT_ICON_PX,
		UiTokens.ACCENT_DEEP if fresh > 0 else UiTokens.INK_MUTED))
	box.add_child(UiFactory.make_label(
		tr(Fmt.count_key("PRODUCT_VOICES_COUNT", n)).format({"n": n}) if worded else str(n), &"RowMetaStrong"))
	if fresh > 0:
		box.add_child(UiFactory.make_label(SprintUiShared.SEP.strip_edges(), &"SectionAmber"))
		box.add_child(UiFactory.make_label(tr("PRODUCT_NEW_COUNT").format({"n": fresh}), &"SectionAmber"))


## Müşteriler: akordeonun dışında, hep açık. Dar sütunda yalnız başlık ve sayı.
func _add_customers_row(customers: Array) -> void:
	var row := _edged_card(CUSTOMERS_SLOT)
	add_child(row)
	var box := _vbox(UiTokens.SPACE_XS)
	row.add_child(box)
	box.add_child(UiFactory.make_label(tr("PRODUCT_CUSTOMERS"), &"AreaName"))
	var n: int = customers.size()
	box.add_child(UiFactory.make_label(tr(Fmt.count_key("PRODUCT_REQUESTS_COUNT", n)).format({"n": n})
		if n > 0 else tr("PRODUCT_CUSTOMERS_NONE"), &"RowMeta"))
	if _compact:
		return
	for c in customers:
		box.add_child(_customer_card(c))


## Talep kartı: "müşteri · talep" ve planlı sprint damgası, altında son tarih · yıllık bedel · alan.
## Talebi olmayan müşteri tek satırlık ticket sayısıdır.
func _customer_card(c: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"PaperCard"
	var box := _vbox(UiTokens.SPACE_XS)
	card.add_child(box)
	var top := _hbox(UiTokens.SPACE_S)
	box.add_child(top)
	if c.request == "":
		var tickets: int = int(c.tickets)
		top.add_child(UiFactory.make_label(tr(Fmt.count_key("PRODUCT_CUSTOMER_TICKETS", tickets)).format(
			{"customer": c.name, "n": tickets}), &"DataMono"))
		return card
	var title := UiFactory.make_label(c.name + SprintUiShared.SEP + c.request, &"DataMono")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	if int(c.tag_sprint) >= 0:
		top.add_child(SprintUiShared.stamp(tr("PRODUCT_TAG_SPRINT").format({"n": int(c.tag_sprint)}), &"StampAmber"))
	for kind in c.buttons:
		var b := SprintUiShared.ink_button(kind, kind == "add" and not _model.center.can_add)
		b.pressed.connect(action.emit.bind(kind, {"card_id": c.card_id}))
		top.add_child(b)

	var terms := _hbox(UiTokens.SPACE_S)
	box.add_child(terms)
	if int(c.due_sprint) >= 0:
		terms.add_child(UiFactory.make_label(tr("PRODUCT_DUE_SPRINT").format({"n": int(c.due_sprint)}),
			&"RowMetaStrong", UiTokens.negative()))
		terms.add_child(UiFactory.make_label(SprintUiShared.SEP.strip_edges(), &"RowMeta"))
	terms.add_child(UiFactory.make_label(tr("PRODUCT_PER_YEAR").format({"amount": Fmt.money_exact(int(c.value))}),
		&"RowMetaStrong"))
	if int(c.area_slot) >= 0:
		var tag := PanelContainer.new()
		tag.theme_type_variation = &"ChipNeutral"
		tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var inner := _hbox(UiTokens.SPACE_XS)
		tag.add_child(inner)
		inner.add_child(SprintUiShared.swatch(int(c.area_slot), UiTokens.PRODUCT_SLICE_PX_SMALL))
		inner.add_child(UiFactory.make_label(c.area_name, &"RowMeta"))
		terms.add_child(tag)
	return card


## Açık satırın alt bölümü: saç teli ve amber başlık; içerik dönen kutuya eklenir.
func _section(body: VBoxContainer, key: String) -> VBoxContainer:
	var box := _vbox(UiTokens.SPACE_S)
	body.add_child(box)
	box.add_child(HRUiShared.hairline())
	box.add_child(UiFactory.make_label(tr(key), &"SectionAmber"))
	return box


## Kâğıt kart; sol kenarda alanın renk şeridi.
func _edged_card(slot: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"PaperCard"
	card.custom_minimum_size.y = UiTokens.PRODUCT_AREA_ROW_H
	card.draw.connect(func() -> void: SprintUiShared.draw_edge(card, slot))
	return card


## Açık satır aşağı, kapalı satır sağa bakan şevron.
func _chevron(open: bool) -> TextureRect:
	if open:
		return HRUiShared.chevron(UiTokens.PRODUCT_ICON_PX, UiTokens.ACCENT_DEEP)
	return HRUiShared._glyph("res://assets/icons/chevron_right.svg", UiTokens.PRODUCT_ICON_PX, UiTokens.INK_FAINT)


func _hbox(separation: int) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override(&"separation", separation)
	return box


func _vbox(separation: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", separation)
	return box


func _on_area_input(ev: InputEvent, id: String) -> void:
	if UiFactory.is_left_click(ev):
		ui_changed.emit("" if _open == id else id, false)


func _on_voices_input(ev: InputEvent, id: String) -> void:
	if not UiFactory.is_left_click(ev):
		return
	if not _voices_open:
		action.emit("voices_seen", {"area": id})
	ui_changed.emit(_open, not _voices_open)
