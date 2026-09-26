class_name FeatureLinesView
extends VBoxContainer

# ============================================================================
# ÜRÜN → sürüm planı · HAT LİSTESİ (GDD ÜRÜN §12.9): eksen başına üç hat, her hat
# en fazla İKİ metin satırı.
#
#   Arama       Anında Arama ✓  →  Filtreli Arama    Efor 8 · Deneyim 7,2 (+3,2)
#                                  Kilit: Tasarım ★ ✗ → Eğit / İşe al
#
# Üç hüküm motorda yaşar, bu dosya yalnız çizer:
# 1. SAYI AĞIRLIKLIDIR: `ProductLines.weighted_points` / `net_gain` okunur ("oyuncu
#    ekranda gördüğü sayıyı alır"); Kano katsayısı burada bir daha uygulanmaz.
# 2. KİLİT SATIRI YALNIZ KARŞILANMAYANI YAZAR (`LineGates.unmet_parts`); "Kilitsiz"
#    diye bir kelime yok. Tam liste, karşılananlar ✓ ile, yalnız hover'da.
# 3. MERDİVEN KURALI ProductLines'ındır (`ladder_refusal`); burada yeniden yazılmaz.
# Kademe etiketi (BASIC / PERFORMANS / DELIGHTER) hiçbir yerde görünmez; Kano yalnız
# katsayıdır.
#
# "→ Araştır" iki hâllidir: Ar-Ge ağacı kapalıyken (`ResearchSeam.tree_available()`)
# bağ çizilir ama tıklanmaz; açıkken `research_requested` yayar.
# Sahne yok; ev sahibi `FeatureLinesView.new()` ile kurar.
# ============================================================================

## Sürüm planındaki kademe kimlikleri değişti.
signal selection_changed(step_ids: Array)
## Kilit satırındaki "→ Eğit / İşe al" tıklandı; ev sahibi Ekip sekmesine yönlendirir.
signal train_or_hire_requested()
## Kilit satırındaki "→ Araştır" tıklandı; ev sahibi Ar-Ge sekmesine ve düğüme yönlendirir.
signal research_requested(node_id: String)

# Glifler metin değil noktalama: kodda dururlar, CSV'de yalnız etraflarındaki cümle yaşar.
const MARK_MET := "✓"
const MARK_UNMET := "✗"
const ARROW := "→"
const STAR := "★"
const PART_SEP := " · "

# Sütun genişlikleri sabit: kilit satırı kademe sütununun tam altına iner (§12.9 şeması).
const W_NAME := 150
const W_SHIPPED := 170
const W_ARROW := 16
const W_STAT := 236

## "Tamamlandı" satırının soluğu (HRUiShared.locked_telegraph ile aynı sayı).
const DIM_ALPHA := 0.55

var _subtype: String = ""
var _selected: Array[String] = []
## line_id -> {"card", "next": Label|null, "hovered", "selectable", "step": step_id}
var _rows: Dictionary = {}
var _count_label: Label = null


## `subtype` boşsa canlı ürünün alt-tipi okunur (ilk sürümde ev sahibi taslaktan verir).
## Merdivenden GEÇMEYEN ön-seçim sessizce düşer.
func setup(subtype: String, preselected: Array) -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_M)
	_subtype = subtype if subtype != "" else ProductState.subtype()
	_selected.clear()
	for raw in preselected:
		var step_id: String = String(raw)
		var line_id: String = String(ProductLines.step(step_id).get("line_id", ""))
		if ProductLines.ladder_refusal(step_id, ProductState.line_tier(line_id), _selected) == "":
			_selected.append(step_id)
	repaint()


func repaint() -> void:
	ProductUiShared.clear(self)
	_rows.clear()
	add_child(_make_header())
	add_child(HRUiShared.hairline())
	var by_axis: Dictionary = ProductLines.line_ids_by_axis(_subtype)
	var drawn: int = 0
	for axis in QualityModel.AXES:
		var ids: Array = by_axis.get(axis, [])
		if ids.is_empty():
			continue
		add_child(_make_axis_header(axis))
		for line_id in ids:
			# Kart önce AĞACA girer, sonra boyanır: seçili satırın kutusu varyasyondan kopyalanır.
			add_child(_make_line_row(line_id))
			_style_row(line_id)
			drawn += 1
	if drawn == 0:
		add_child(UiFactory.make_label(tr("PROD_LINES_EMPTY"), &"EmptyRowLabel"))
	_refresh_count()


# ------------------------------------------------------------------ çizim

## Bölüm adı · boşluk · akan sayaç (Ekip panelinin başlık grameri; iki panel yan yana durur).
func _make_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var title := UiFactory.make_section_header(tr("PROD_LINES_HEADER"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	_count_label = UiFactory.make_label("", &"RowMeta")
	row.add_child(_count_label)
	return row


## Amber mono bölüm başlığı + sağa uzayan saç teli.
func _make_axis_header(axis: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_label(Fmt.upper(ProductUiShared.axis_label(axis)), &"SectionAmber"))
	var rule := HRUiShared.hairline()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(rule)
	return row


func _make_line_row(line_id: String) -> Control:
	var tier: int = ProductState.line_tier(line_id)
	var complete: bool = ProductLines.is_complete(tier)
	var next_step: Dictionary = ProductLines.step_at(line_id, ProductLines.next_tier(tier))
	var next_id: String = String(next_step.get("id", ""))
	var selectable: bool = next_id != "" and LineGates.is_unlocked(next_id)

	# HOVER = KENAR: iki varyasyonun dolgusu bayt-aynı, satır hover'da zıplamaz.
	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRow"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	card.add_child(col)

	# 1. satır: ad · yayınlanmış kademe → sıradaki kademe · sayı
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(head)
	var name_lbl := UiFactory.make_label(tr(String(ProductLines.line(line_id).get("name_key", ""))), &"RowName")
	name_lbl.custom_minimum_size = Vector2(W_NAME, 0)
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(name_lbl)

	var next_lbl: Label = null
	if complete:
		# "Anlamsal Arama ✓ · hat tamamlandı": CSV yalnız kuyruğu taşır. Önerilecek kazanç
		# yok, o yüzden sayı sütunu boş.
		var last: String = tr(String(ProductLines.step_at(line_id, ProductLines.TIER_MAX).get("name_key", "")))
		var done := UiFactory.make_label(
			PART_SEP.join(["%s %s" % [last, MARK_MET], tr("PROD_LINE_COMPLETE")]), &"RowMeta", UiTokens.INK_DIM)
		done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		done.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		head.add_child(done)
	else:
		head.add_child(_make_shipped_cell(line_id, tier))
		var arrow := UiFactory.make_label(ARROW if tier > 0 else "", &"RowMeta", UiTokens.INK_FAINT)
		arrow.custom_minimum_size = Vector2(W_ARROW, 0)
		arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		head.add_child(arrow)
		next_lbl = UiFactory.make_label(tr(String(next_step.get("name_key", ""))), &"RowName")
		next_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		next_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		head.add_child(next_lbl)
		head.add_child(_make_stat_cell(line_id, next_id, tier))
		# 2. satır: kilit, yalnız kilitli kademede.
		if not selectable:
			col.add_child(_make_lock_row(next_id))

	_rows[line_id] = {
		"card": card, "next": next_lbl, "hovered": false,
		"selectable": selectable, "step": next_id,
	}
	if selectable:
		HRUiShared.set_mouse_ignore(col)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.mouse_entered.connect(_on_row_hover.bind(line_id, true))
		card.mouse_exited.connect(_on_row_hover.bind(line_id, false))
		card.gui_input.connect(_on_row_input.bind(line_id))
	else:
		# Kilit satırı hover'ı ve tıklamayı kendi tutar (tooltip + eylem bağı).
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.focus_mode = Control.FOCUS_NONE
		if complete:
			card.modulate.a = DIM_ALPHA   # soluk = yalnız alfa; palet dışına renk çıkmaz
	return card


## Yayınlanmış kademe: adı soluk, yanında ✓. Hat boşsa hücre boş kalır ama genişliğini
## korur, sıradaki kademe sütunu bütün satırlarda aynı yerde başlar.
func _make_shipped_cell(line_id: String, tier: int) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_S)
	box.custom_minimum_size = Vector2(W_SHIPPED, 0)
	box.alignment = BoxContainer.ALIGNMENT_END
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if tier > 0:
		box.add_child(UiFactory.make_label(
			tr(String(ProductLines.step_at(line_id, tier).get("name_key", ""))), &"RowMeta", UiTokens.INK_DIM))
		box.add_child(UiFactory.make_label(MARK_MET, &"RowMeta", UiTokens.INK_DIM))
	return box


## "Efor 8 · Deneyim 7,2 (+3,2)": kademenin AĞIRLIKLI eksen katkısı ve parantezde NET
## kazanç, ikisi de motordan.
func _make_stat_cell(line_id: String, step_id: String, tier: int) -> Control:
	var gain: float = ProductLines.net_gain(line_id, tier)
	var lbl := UiFactory.make_label(PART_SEP.join([
		tr("PROD_EFFORT_N").format({"n": ProductLines.effort_of(step_id)}),
		tr("PROD_LINE_CONTRIB").format({
			"axis": ProductUiShared.axis_label(ProductLines.axis_of(line_id)),
			"value": Fmt.number(ProductLines.weighted_points(step_id), 1),
			"gain": ("+" if gain >= 0.0 else "") + Fmt.number(gain, 1),
		}),
	]), &"RowMeta")
	lbl.custom_minimum_size = Vector2(W_STAT, 0)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl


# ------------------------------------------------------------------ kilit satırı

## "Kilit: Ar-Ge "Veri Modeli" ✗ → Araştır · Tasarım ★ ✗ → Eğit / İşe al"
## Tek Label değil HBox: eylem bağları aynı cümlede ama davranışları ayrı.
func _make_lock_row(step_id: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	# Tam gereksinim listesi, karşılananlar ✓ ile: §12.9 ekrana yasaklar, hover'a açar
	# (oyuncu tek eksik ile üç eksiği ayırt edebilmeli). Godot boş tooltip'te ebeveyne
	# yürüdüğü için tıklanabilir bağlar da bu listeyi gösterir.
	var full: Array[String] = []
	for part in LineGates.evaluate(step_id).get("parts", []):
		full.append(_part_text(part))
	row.tooltip_text = "\n".join(full)

	# Girinti ölçülür: 1. satırda kademe sütunu W_NAME + W_SHIPPED + W_ARROW + üç ayraçtan
	# sonra başlar; bu satırın kendi ilk ayracı (SPACE_S) düşülür.
	var indent := Control.new()
	indent.custom_minimum_size = Vector2(
		W_NAME + W_SHIPPED + W_ARROW + 3 * UiTokens.SPACE_L - UiTokens.SPACE_S, 0)
	indent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(indent)
	row.add_child(_lock_text(tr("PROD_LOCK_PREFIX")))

	var unmet: Array = LineGates.unmet_parts(step_id)
	for i in unmet.size():
		var part: Dictionary = unmet[i]
		if i > 0:
			row.add_child(_lock_text(PART_SEP.strip_edges()))
		row.add_child(_lock_text(_part_text(part)))
		row.add_child(_make_action_link(String(part.get("kind", "")), String(part.get("node", ""))))
	return row


func _lock_text(text: String) -> Label:
	var lbl := UiFactory.make_label(text, &"RowMeta", UiTokens.INK_DIM)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl


## Bağın SÖZCÜĞÜ kapının cinsine göre değişir (§12.9): kişi kapısı "→ Eğit / İşe al"
## (eldeki insanı büyütmek önce), toplam kapısı "→ İşe al / Eğit" (toplamı büyüten önce
## kişi sayısıdır). Araştır bağı Ar-Ge ağacı kapalıyken İNERT: çizilir, hover sebebini söyler.
func _make_action_link(kind: String, node_id: String) -> Control:
	var research: bool = kind == LineGates.KIND_RESEARCH
	var key: String = "PROD_LOCK_ACTION_PERSON"
	if research:
		key = "PROD_LOCK_ACTION_RESEARCH"
	elif kind == LineGates.KIND_TOTAL:
		key = "PROD_LOCK_ACTION_TOTAL"
	var link := UiFactory.make_label(tr(key), &"RowMeta", UiTokens.ACCENT)
	link.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if research and not ResearchSeam.tree_available():
		link.add_theme_color_override("font_color", UiTokens.INK_FAINT)
		link.mouse_filter = Control.MOUSE_FILTER_PASS
		link.tooltip_text = tr("PROD_LOCK_RESEARCH_SOON")
		return link
	link.mouse_filter = Control.MOUSE_FILTER_STOP
	link.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if research:
		link.gui_input.connect(_on_research_link_input.bind(node_id))
	else:
		link.gui_input.connect(_on_action_link_input)
	return link


## Tek gereksinim parçasının cümlesi; ✓/✗ parçanın kendi `met` cevabı.
func _part_text(part: Dictionary) -> String:
	var mark: String = MARK_MET if bool(part.get("met", false)) else MARK_UNMET
	var kind: String = String(part.get("kind", ""))
	if kind == LineGates.KIND_RESEARCH:
		return tr("PROD_LOCK_RESEARCH").format({
			"node": ResearchSeam.node_name(String(part.get("node", ""))), "mark": mark})
	var area: String = HRConstants.area_label(String(part.get("area", "")))
	var stars: int = int(part.get("stars", 0))
	if kind == LineGates.KIND_TOTAL:
		# Toplam kapısında buçuklar yüz değerinden sayılır (§12.6): eldeki toplam ondalık olabilir.
		var have: float = float(part.get("have", 0.0))
		return tr("PROD_LOCK_TOTAL").format({
			"area": area,
			"stars": STAR + str(stars),
			"have": STAR + (str(roundi(have)) if is_equal_approx(have, roundf(have)) else Fmt.number(have, 1)),
			"mark": mark,
		})
	return tr("PROD_LOCK_PERSON").format({"area": area, "stars": STAR.repeat(stars), "mark": mark})


# ------------------------------------------------------------------ etkileşim

func _on_row_hover(line_id: String, entered: bool) -> void:
	_rows[line_id]["hovered"] = entered
	_style_row(line_id)


## SEÇİM. Ekleme kararı ProductLines'ın: `ladder_refusal` boş dönmüyorsa satır sessizce
## reddedilir (aynı hatta ikinci kademe, atlanan kademe, yayınlanmış kademe).
func _on_row_input(ev: InputEvent, line_id: String) -> void:
	if not _is_left_press(ev):
		return
	var step_id: String = _rows[line_id]["step"]
	if _selected.has(step_id):
		_selected.erase(step_id)
	elif ProductLines.ladder_refusal(step_id, ProductState.line_tier(line_id), _selected) == "":
		_selected.append(step_id)
	else:
		return
	_style_row(line_id)
	_refresh_count()
	selection_changed.emit(_selected.duplicate())


func _on_action_link_input(ev: InputEvent) -> void:
	if _is_left_press(ev):
		train_or_hire_requested.emit()


func _on_research_link_input(ev: InputEvent, node_id: String) -> void:
	if _is_left_press(ev):
		research_requested.emit(node_id)


func _is_left_press(ev: InputEvent) -> bool:
	var mb := ev as InputEventMouseButton
	return mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT


# ------------------------------------------------------------------ boyama

## Satırın üç durumu: SEÇİLİ (amber yıkama + amber kenar) · HOVER (yalnız kenar açılır)
## · durgun. Kenar üç durumda da bir piksel; kalınlaşan çerçeve satırı oynatırdı.
func _style_row(line_id: String) -> void:
	var row: Dictionary = _rows[line_id]
	var card: PanelContainer = row["card"]
	var picked: bool = _selected.has(row["step"])
	if picked:
		var base: StyleBox = card.get_theme_stylebox("panel")
		if base is StyleBoxFlat:
			var sel: StyleBoxFlat = base.duplicate()
			sel.bg_color = UiTokens.AMBER_BG
			sel.border_color = UiTokens.ACCENT
			card.add_theme_stylebox_override("panel", sel)
	else:
		card.remove_theme_stylebox_override("panel")
		card.theme_type_variation = &"LedgerRowHover" if row["hovered"] else &"LedgerRow"
	var next_lbl: Label = row["next"]
	if next_lbl != null:
		var tint: Color = UiTokens.INK if row["selectable"] else UiTokens.INK_FAINT
		next_lbl.add_theme_color_override("font_color", UiTokens.ACCENT if picked else tint)


func _refresh_count() -> void:
	_count_label.text = tr("PROD_SELECTED_COUNT").format({"n": _selected.size()})
