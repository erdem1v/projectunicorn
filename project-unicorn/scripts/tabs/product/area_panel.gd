class_name AreaPanel
extends MarginContainer

# Ürün ekranının sol sütunu (SPRINT ve ÇEYREK): Geçmiş açıksa sürüm listesi; B2B'de MÜŞTERİ TALEPLERİ (ilk üçü görünür, fazlası
# "+N talep" ile açılır); MODÜLLER (aynı anda tek açık modül, açık modülün adayları). Panel modeli çizer; durum sekmenindir: açık
# modül ve talep listesinin açıklığı `ui_changed` olarak çıkar, sekme yazıp paneli yeniden kurar. Adayın "+"ının değeri kurulumda
# hesaplanmaz: değeri bilinmeyen "+" nötr görünür, değerler sonraki karelerde ekrandaki sırayla gelir
# (`ProductModel.resolve_addable`); imleç ya da tık sırayı beklemez, o "+"nın değeri o an hesaplanır.

signal action(kind: String, args: Dictionary)
signal ui_changed(key: String, value: Variant)
## Bir talep satırına tıklandı: modülü açılır ve görünür kaydırılır.
signal request_picked(area_id: String)
## İmleç bir adayın açık "+"ına geldi ya da ondan ayrıldı (""): hayaletin olayı.
signal hovered(card_id: String)

const CHEVRONS := ["res://assets/icons/util/chevron_right.svg", "res://assets/icons/util/chevron_down.svg"]
const CHEVRON_UP := "res://assets/icons/util/chevron_up.svg"
## Modülün işareti: modül kimliği → ikon.
const AREA_ICONS := {
	"core": "res://assets/icons/rail/product.svg",
	"trust": "res://assets/icons/util/shield.svg",
	"onboarding": "res://assets/icons/product/area_onboarding.svg",
	"integrations": "res://assets/icons/product/area_integrations.svg",
	"growth": "res://assets/icons/product/area_growth.svg",
	"revenue": "res://assets/icons/product/area_revenue.svg",
}
## Talep listesi kapalıyken görünen satır sayısı.
const REQUESTS_SHOWN := 3

var _model: Dictionary
var _col := SprintUiShared.column(0)
var _open_row: Control
## "+"ının değeri henüz bilinmeyen adaylar (açık modülün, ekrandaki sırayla): kart kimliği → tuşu.
var _unknown: Dictionary = {}
var _hover_id := ""


func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("margin_top", UiTokens.SPACE_XS)
	add_theme_constant_override("margin_right", UiTokens.SPACE_L)
	add_theme_constant_override("margin_bottom", UiTokens.SPACE_XL)
	add_child(_col)


func setup(model: Dictionary) -> void:
	_model = model
	_open_row = null
	_unknown.clear()
	_hover_id = ""
	UiFactory.clear(_col)
	if model.ui.history_open:
		_add_history()
	if model.requests != null and not model.requests.is_empty():
		_add_requests(model.requests)
	_col.add_child(_eyebrow("PRODUCT_MODULES"))
	var list := SprintUiShared.column(UiTokens.SPACE_XXS)
	_col.add_child(list)
	for module in model.modules:
		list.add_child(_module_row(module))
	set_process(not _unknown.is_empty())


## Açık modül satırının panelin tepesinden uzaklığı (açık modül yoksa 0): kaydırma alanı oraya kaydırılınca modülün başı görünür.
func open_offset() -> int:
	return 0 if _open_row == null else int(_open_row.global_position.y - global_position.y)


## Her karede değeri bilinmeyen "+"lardan en az birinin değeri istenir (süre dolana dek); gelen değer tuşu açık ya da kapalı yapar.
func _process(_delta: float) -> void:
	ProductModel.resolve_addable(_unknown.keys())
	_apply_known()


## Değeri öğrenilmiş "+"ları açar ya da kapatır.
func _apply_known() -> void:
	for id: String in _unknown.keys():
		var ok: Variant = ProductModel.addable(id)
		if ok != null:
			_set_add(_unknown[id], ok)
			_unknown.erase(id)
	set_process(not _unknown.is_empty())


## Büyük harfli bölüm başlığı ve (verilmişse) sayısı; ilk bölümden sonrakinin üstünde boşluk var.
func _eyebrow(key: String, count := -1) -> MarginContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.add_child(SprintUiShared.label(Fmt.upper(tr(key)), &"Eyebrow"))
	if count >= 0:
		row.add_child(SprintUiShared.label(str(count), &"Eyebrow", UiTokens.D_INK_3))
	return SprintUiShared.pad(row, Vector4i(0, UiTokens.SPACE_XL if _col.get_child_count() > 0 else 0, 0, UiTokens.SPACE_M))


## Sürümler, en yenisi üstte: "v1.4 Sprint 6 · 2 kart", altında beklenen ya da gerçekleşen sonuç.
## Bilinmeyen (-1) parça yazılmaz: eski sürüm kayıtları sprint ve kart sayısı taşımıyor.
func _add_history() -> void:
	_col.add_child(_eyebrow("PRODUCT_HISTORY"))
	var list := SprintUiShared.column(0)
	_col.add_child(list)
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


# --- Müşteri talepleri ----------------------------------------------------------------

func _add_requests(requests: Array) -> void:
	# Bu çeyrekte karşılananlar açıkların altında kalır: başlıktaki sayıya girmez, "+N talep" katlaması onları gizlemez.
	var open: Array = requests.filter(func(r: Dictionary) -> bool: return r.status.kind != "met")
	var met: Array = requests.filter(func(r: Dictionary) -> bool: return r.status.kind == "met")
	# Yalnız karşılanmış talep kaldıysa başlık sayı taşımaz ("0" yazmaz).
	_col.add_child(_eyebrow("PRODUCT_REQUESTS", open.size() if not open.is_empty() else -1))
	var list := SprintUiShared.column(UiTokens.SPACE_XS)
	_col.add_child(list)
	var unfolded: bool = _model.ui.requests_open
	for i in open.size():
		if unfolded or i < REQUESTS_SHOWN:
			list.add_child(_request_row(open[i]))
	if open.size() > REQUESTS_SHOWN:
		var more := open.size() - REQUESTS_SHOWN
		var fold := SprintUiShared.button(tr(Fmt.count_key("PRODUCT_MORE_REQUESTS", more)).format({"n": more}), &"MoreLink",
			ui_changed.emit.bind("requests_open", not unfolded))
		fold.icon = load(CHEVRON_UP if unfolded else CHEVRONS[1])
		fold.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		fold.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		list.add_child(fold)
	for r: Dictionary in met:
		list.add_child(_request_row(r))


## Talep satırı, üç satır: müşteri ve söz tarihi (açık talepte; hepsinde, planda olsun olmasın), modülün ikonu ve kartın adı, altında
## kartın durumu (`_status_line`; durumu yoksa satır yok). Tıklanınca modülü açılır. Hiçbir satır soluk değildir.
func _request_row(r: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.theme_type_variation = &"RequestRow"
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	row.add_child(col)
	var who := SprintUiShared.box(UiTokens.SPACE_M)
	who.add_child(UiFactory.make_glyph(SprintUiShared.BUILDING, UiTokens.D_ICON_MARK, UiTokens.D_INK_3))
	who.add_child(_name(String(r.customer), &"TipTitle", null))
	if String(r.due_text) != "":
		who.add_child(SprintUiShared.due_chip(String(r.due_text), r.soon))
	col.add_child(who)
	var what := SprintUiShared.box(UiTokens.SPACE_M)
	var mark := _area_mark(String(r.module_id))
	what.add_child(mark)
	what.add_child(_name(String(r.card_name), &"CaptionPrimary", null))
	col.add_child(what)
	var status: Control = _status_line(r.status)
	if status != null:
		# Durum, kartın adıyla aynı hizada başlar: işaret kutusunun genişliği ve aralığı kadar içeriden.
		col.add_child(SprintUiShared.pad(status, Vector4i(UiTokens.D_BOX_MONO + UiTokens.SPACE_M, 0, 0, 0)))
	HRUiShared.set_mouse_ignore(col)
	# İkon modülün adını ipucu taşır: imleci alır, tıkı satıra geçirir.
	mark.tooltip_text = SprintCatalog.area_name(String(r.module_id))
	mark.mouse_filter = Control.MOUSE_FILTER_PASS
	row.tooltip_text = r.tip
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_hover(row, row.theme_type_variation, &"RequestRowHover")
	row.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			request_picked.emit(r.module_id))
	return row


## Talebin durum satırı: planda ya da karşılanmışta tik ("Sprint {n}", "{q}. çeyrekte tamamlandı"), koşan sprintte aşamanın renginde açık
## halka ve aşamanın adı (yüzde yok); durumu yoksa null.
func _status_line(status: Dictionary) -> HBoxContainer:
	if status.kind == "":
		return null
	var line := SprintUiShared.box(UiTokens.SPACE_S)
	var lead: Control = StageRing.new(UiTokens.D_stage(String(status.stage))) if status.kind == "dev" 		else UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_TAG, UiTokens.D_ST_TEST)
	lead.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(lead)
	line.add_child(_name(String(status.text), &"CaptionName", UiTokens.D_INK_2))
	return line


## Koşan sprintte kartın aşamasının işareti: aşamanın renginde, üstü açık halka; tik kadar yer tutar.
class StageRing extends Control:
	var _ink: Color

	func _init(ink: Color) -> void:
		_ink = ink
		custom_minimum_size = Vector2.ONE * UiTokens.D_ICON_TAG
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var radius: float = size.x / 2.0 - UiTokens.BORDER_FOCUS / 2.0
		draw_arc(size / 2.0, radius, deg_to_rad(-45.0), deg_to_rad(225.0), 32, _ink, UiTokens.BORDER_FOCUS, true)


# --- Modüller ---------------------------------------------------------------------------

## Modülün ikonu, kutusunda ortalı.
func _area_mark(area_id: String) -> PanelContainer:
	return HRUiShared.D_mono_box(UiTokens.D_BOX_MONO, UiFactory.make_glyph(AREA_ICONS[area_id], UiTokens.D_ICON_ROW, UiTokens.D_INK_2))


## Modül satırı: işaret, ad, tik (bu sprintte kartı varsa; ipucu `PRODUCT_IN_PLAN_TIP`) ve şevron; açıksa altında adayları. Satırın başı tıklanınca açılır ya da
## kapanır.
func _module_row(m: Dictionary) -> PanelContainer:
	var open: bool = m.id == String(_model.ui.open_area)
	var row := PanelContainer.new()
	row.theme_type_variation = &"ModuleRowOpen" if open else &"ModuleRow"
	var col := SprintUiShared.column(UiTokens.SPACE_L)
	row.add_child(col)
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	head.custom_minimum_size.y = UiTokens.D_BOX_MONO
	head.add_child(_area_mark(String(m.id)))
	head.add_child(_name(String(m.name), &"TipTitle", UiTokens.D_INK_2))
	if m.planned:
		var tick := UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_ST_TEST)
		tick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(tick)
	head.add_child(UiFactory.make_glyph(CHEVRONS[int(open)], UiTokens.D_ICON_MARK, UiTokens.D_INK_4))
	HRUiShared.set_mouse_ignore(head)
	head.mouse_filter = Control.MOUSE_FILTER_STOP
	head.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	head.tooltip_text = String(m.name) + (SprintUiShared.SEP + tr("PRODUCT_IN_PLAN_TIP") if m.planned else "")
	head.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			ui_changed.emit("open_area", "" if open else m.id))
	col.add_child(head)
	if open:
		_open_row = row
		var cards := SprintUiShared.column(UiTokens.SPACE_S)
		for c in m.candidates:
			cards.add_child(_candidate(c))
		if m.waiting != null:
			cards.add_child(_waiting_card(m.waiting))
		col.add_child(cards)
	else:
		head.mouse_entered.connect(func() -> void: row.theme_type_variation = &"ModuleRowHover")
		head.mouse_exited.connect(func() -> void: row.theme_type_variation = &"ModuleRow")
	return row


## Aday kart: ad, efor ve "+" (planda tik, başka sprintte damga); altında düzeltme kartının hata metni (sarar) ve aşama payları.
func _candidate(c: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"ModuleCandidate"
	var col := SprintUiShared.column(UiTokens.SPACE_S)
	card.add_child(col)
	var top := SprintUiShared.box(UiTokens.SPACE_M)
	top.add_child(_name(String(c.name), &"CaptionName", UiTokens.D_INK_2))
	top.add_child(SprintUiShared.label(str(c.effort), &"CaptionName", UiTokens.D_INK_1))
	if c.planned:
		var tick := UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_ST_TEST)
		tick.custom_minimum_size.x = UiTokens.D_H_KEY_CAND
		tick.mouse_filter = Control.MOUSE_FILTER_PASS
		tick.tooltip_text = tr("PRODUCT_CAND_IN_PLAN_TIP")
		top.add_child(tick)
	elif int(c.stamp) >= 0:
		top.add_child(SprintUiShared.due_chip(tr("PRODUCT_TAG_SPRINT").format({"n": int(c.stamp)}), false, ""))
	else:
		top.add_child(_add_key(c))
	col.add_child(top)
	if int(c.bugs) > 0:
		col.add_child(SprintUiShared.prose(String(c.fix_text), &"Caption"))
	col.add_child(_strip(c.parts))
	if c.planned or int(c.stamp) >= 0:
		card.modulate = Color(Color.WHITE, UiTokens.D_TAKEN_ALPHA)
	return card


## Modülün araştırma bekleyen sıradaki kartı: efor ve şerit yok, "+" yerinde Ar-Ge'nin ikonu, ad soluk; ipucu araştırılacak düğümü
## söyler, tık Ar-Ge'yi o düğümde açar; üstüne gelince kenarı talep satırı gibi aydınlanır.
func _waiting_card(w: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"ModuleCandidate"
	var top := SprintUiShared.box(UiTokens.SPACE_M)
	top.add_child(_name(String(w.name), &"CaptionName", UiTokens.D_INK_3))
	var mark := UiFactory.make_glyph(RnDUiShared.ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_3)
	mark.custom_minimum_size.x = UiTokens.D_H_KEY_CAND
	top.add_child(mark)
	card.add_child(top)
	HRUiShared.set_mouse_ignore(top)
	card.tooltip_text = String(w.reason)
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_hover(card, card.theme_type_variation, &"ModuleCandidateHover")
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			action.emit("rnd", {"node": String(w.node)}))
	return card


## Aşama payları yan yana, bant renginde ve efor oranında; üstüne gelince "{aşama} {efor}".
func _strip(parts: Array) -> HBoxContainer:
	var strip := SprintUiShared.box(UiTokens.SPACE_XXS)
	strip.custom_minimum_size.x = UiTokens.D_W_STAGE_STRIP
	strip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	for part in parts:
		var seg := ColorRect.new()
		seg.color = UiTokens.D_stage(String(part.stage))
		seg.custom_minimum_size.y = UiTokens.D_H_STAGE_STRIP
		seg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		seg.size_flags_stretch_ratio = part.effort
		seg.tooltip_text = SprintUiShared.stage_name(part.stage) + " " + str(roundi(part.effort))
		strip.add_child(seg)
	return strip


## Adayın "+"ı. Değeri bilinmiyorsa (`addable` null) nötr durur, kuyruğa girer; değer gelince `_set_add` açar ya da kapatır.
func _add_key(c: Dictionary) -> Button:
	var key := SprintUiShared.add_key()
	key.custom_minimum_size = Vector2.ONE * UiTokens.D_H_KEY_CAND
	key.pressed.connect(_on_add_pressed.bind(key, String(c.id)))
	key.mouse_entered.connect(_on_add_hover.bind(key, String(c.id), true))
	key.mouse_exited.connect(_on_add_hover.bind(key, String(c.id), false))
	if c.addable == null:
		_unknown[c.id] = key
		_set_add(key, null)
	else:
		_set_add(key, c.addable)
	return key


## null: değer bilinmiyor, nötr, ipucu yok. true: açık. false: kapalı ve basılmaz; planlamada nedeni ipucunda.
func _set_add(key: Button, ok: Variant) -> void:
	key.theme_type_variation = SprintUiShared.add_look(ok != null)
	key.disabled = ok == false
	key.tooltip_text = "" if ok == null else tr("PRODUCT_ADD_TO_PLAN") if ok else _closed_tip()


## Planlamada kapalı "+"nın nedeni: boş puan kaldıysa yük tavanı, kalmadıysa sprint dolu.
func _closed_tip() -> String:
	var c: Dictionary = _model.center
	if c.mode != "plan":
		return ""
	return tr("PRODUCT_ADD_CLOSED").format({"pct": Fmt.percent(c.ceiling_pct, 0)}) if c.spare else tr("PRODUCT_ADD_CLOSED_FULL")


## Kuyruktaki adayın değeri sırası beklenmeden hesaplanır: "+"ya gelen imleç ve tık, kuyrukta olsa da doğru karşılık bulur.
func _learn(card_id: String) -> void:
	if _unknown.has(card_id):
		ProductModel.resolve_addable([card_id])
		_apply_known()


## Kart sığmıyorsa basış değeri kapatır ve eklemez; nedeni ipucundadır.
func _on_add_pressed(key: Button, card_id: String) -> void:
	_learn(card_id)
	if not key.disabled:
		action.emit("add", {"card_id": card_id})


func _on_add_hover(key: Button, card_id: String, on: bool) -> void:
	if on:
		_learn(card_id)
	if on and not key.disabled:
		_hover_id = card_id
		hovered.emit(card_id)
	elif not on and _hover_id == card_id:
		_hover_id = ""
		hovered.emit("")


# --- Ortak parçalar -----------------------------------------------------------------------

## Satırın ya da kartın adı: uzun ad kesilmez, sarar; yanındakilere kalan yeri doldurur.
func _name(text: String, variation: StringName, color: Variant) -> Label:
	var name_label := SprintUiShared.prose(text, variation, color)
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return name_label


## Üstüne gelme kenarı: çocuk kutuya geçmek satırı bırakmaz.
func _hover(row: Control, rest: StringName, hover: StringName) -> void:
	row.mouse_entered.connect(func() -> void: row.theme_type_variation = hover)
	row.mouse_exited.connect(func() -> void:
		if not row.get_global_rect().has_point(row.get_global_mouse_position()):
			row.theme_type_variation = rest)
