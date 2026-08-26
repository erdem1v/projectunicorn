class_name FeatureLinesView
extends VBoxContainer

# ============================================================================
# ÜRÜN → sürüm planı · HAT LİSTESİ (GDD ÜRÜN MODÜLÜ rev 6.1 §12.9).
#
# S4'ün KART IZGARASI EMEKLİ. Tasarım otoritesi onun yerine bir SATIR LİSTESİ
# koydu: dokuz hat, eksen başına üç, her hat en fazla İKİ METİN SATIRI.
#
#   Arama       Anında Arama ✓  →  Filtreli Arama    Efor 8 · Deneyim 7,2 (+3,2)
#                                  Kilit: Tasarım ★ ✗ → Eğit / İşe al
#
# ÜÇ HÜKÜM, ve üçü de burada değil MOTORDA yaşıyor — bu dosya yalnız çiziyor:
#
# 1. SAYI AĞIRLIKLIDIR. Kartta ham puan yazılmaz; `ProductLines.weighted_points`
#    ve `ProductLines.net_gain` okunur (§12.9: "oyuncu ekranda gördüğü sayıyı
#    alır"). Kano katsayısı burada bir daha uygulanmaz.
# 2. KİLİT SATIRI YALNIZ KARŞILANMAYANI YAZAR. `LineGates.unmet_parts` tam olarak
#    o kümeyi döndürür; karşılanan gereksinim hiçbir yerde çizilmez ve "Kilitsiz"
#    diye bir kelime yoktur. Tamamı — karşılananlar ✓ ile — YALNIZ hover'daki
#    listede görünür (`LineGates.evaluate(...)["parts"]`).
# 3. MERDİVEN KURALI ProductLines'INDIR. Bir hatta ikinci kademe seçilemez;
#    cevabı `ProductLines.ladder_refusal` veriyor, burada yeniden yazılmıyor.
#
# KADEME ETİKETİ (BASIC / PERFORMANS / DELIGHTER) HİÇBİR YERDE GÖRÜNMEZ (§12.9,
# onaylı S4/S9). Kano yalnız katsayı olarak yaşar, kelime olarak değil.
#
# → Araştır İKİ HÂLLİDİR ve hâli `ResearchSeam.tree_available()` seçer. Ağaç
# kapalıyken (ürün henüz yayında değil) bağ çizilir ama tıklanmaz ve hover'ı
# "Ar-Ge yakında." der — bu bir eksik değil SIRALAMA'dır (research_seam.gd:
# "geçici bypass yazılmaz"). Ağaç açıkken bağ CANLIDIR ve `research_requested`
# yayınlar; ev sahibi onu Ar-Ge sekmesine ve düğüme taşır. (2026-08-25'e kadar
# ikinci dal ulaşılamazdı ve kendi yorumu "bir sonraki turun işi" diyordu; o tur
# bu tur oldu.)
#
# YERLEŞİM BU DOSYANIN, RENK VE BOY TEMANIN. Ham `Color(...)` ve ham font boyutu
# yok; her şey `UiTokens` ile mevcut varyasyonlardan çözülüyor (StarRating ve
# ValueSlider'ın reçetesi) — yeni tema öğesi eklenmediği için THEME_STAMP durur.
#
# Sahne DEĞİL, kod. `.tscn` yok; ev sahibi bunu `FeatureLinesView.new()` ile kurar.
# PAUSE: GameShell alt ağacında mount edildiği için PROCESS_MODE_ALWAYS MİRAS
# ALINIR — burada ayrıca set edilmez (CLAUDE.md UI/STYLE LAW).
# ============================================================================

## Sürüm planındaki kademe kimlikleri değişti. Ev sahibi bunu Konsept onayına taşır.
signal selection_changed(step_ids: Array)
## Kilit satırındaki "→ Eğit / İşe al" (ya da "→ İşe al / Eğit") tıklandı.
## Ev sahibi bunu Ekip sekmesine yönlendirir; bu görünüm nereye gidildiğini bilmez.
signal train_or_hire_requested()
## Kilit satırındaki "→ Araştır" tıklandı. Ev sahibi bunu Ar-Ge sekmesine ve o
## düğüme yönlendirir; bu görünüm — kardeşi gibi — nereye gidildiğini bilmez.
signal research_requested(node_id: String)

# --- Glifler. Türkçe metin DEĞİL, noktalama: kod tarafında sabit dururlar ve
# CSV'de yalnız etraflarındaki cümle yaşar (creation_flow.gd'nin "✓" precedent'i).
const MARK_MET := "✓"
const MARK_UNMET := "✗"
const ARROW := "→"
const STAR := "★"
const PART_SEP := " · "

# --- Sütun genişlikleri. Satırın iki metin satırı ÜST ÜSTE hizalansın diye
# sabittirler: kilit satırı, kademe sütununun altına iner (§12.9'un kendi şeması).
const W_NAME := 150
const W_SHIPPED := 170
const W_ARROW := 16
const W_STAT := 236
const ROW_SEP := 12          # UiTokens.SPACE_L ile aynı sayı; hesapta kullanılıyor

## "Tamamlandı" satırının soluğu. Evin sayısı (HRUiShared.locked_telegraph,
## creation_flow'un dondurulmuş satırı) — YENİ bir değer uydurulmuyor.
const DIM_ALPHA := 0.55

var _subtype: String = ""
var _selected: Array[String] = []
## line_id -> {"card": PanelContainer, "next": Label, "hovered": bool, "selectable": bool}
var _rows: Dictionary = {}
var _count_label: Label = null


# ------------------------------------------------------------------ public API

## `subtype` boşsa canlı ürünün alt-tipi okunur (ilk sürümde ev sahibi taslaktan verir).
## `preselected` merdivenden GEÇMEYEN kademeleri sessizce düşürür — kural
## ProductLines'ın, filtre burada yalnız uygulanır.
func setup(subtype: String, preselected: Array) -> void:
	_subtype = subtype if subtype != "" else ProductState.subtype()
	_selected.clear()
	for raw in preselected:
		var step_id: String = String(raw)
		var s: Dictionary = ProductLines.step(step_id)
		if s.is_empty():
			continue
		var line_id: String = String(s.get("line_id", ""))
		if ProductLines.ladder_refusal(step_id, ProductState.line_tier(line_id), _selected) != "":
			continue
		_selected.append(step_id)
	_rebuild()


func selected_step_ids() -> Array:
	return _selected.duplicate()


func repaint() -> void:
	_rebuild()


# ------------------------------------------------------------------ çizim

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_rows.clear()
	_count_label = null
	add_theme_constant_override("separation", UiTokens.SPACE_M)

	add_child(_make_header())
	add_child(HRUiShared.hairline())

	var by_axis: Dictionary = ProductLines.line_ids_by_axis(_subtype)
	var drawn: int = 0
	for axis in QualityModel.AXES:
		var ids: Array = by_axis.get(axis, []) as Array
		if ids.is_empty():
			continue
		add_child(_make_axis_header(String(axis)))
		for line_id in ids:
			# Kart önce AĞACA girer, sonra boyanır: `get_theme_stylebox` ağaç dışında
			# varyasyonu çözemez ve seçili satır yanlış kutuyu kopyalardı.
			add_child(_make_line_row(String(line_id)))
			_style_row(String(line_id))
			drawn += 1
	if drawn == 0:
		add_child(UiFactory.make_label(_t("PROD_LINES_EMPTY"), &"EmptyRowLabel"))
	_refresh_count()


## Başlık: sol tarafta bölüm adı, sağda AKAN SAYAÇ. Ekip panelinin başlık grameriyle
## aynı (etiket · boşluk · sayaç) — iki panel yan yana durduğu için aynı dili konuşurlar.
func _make_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(UiFactory.make_section_header(_t("PROD_LINES_HEADER")))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	_count_label = UiFactory.make_label("", &"RowMeta")
	row.add_child(_count_label)
	return row


## Amber mono bölüm başlığı + sağa uzayan saç teli — HRUiShared.section_header'ın
## şekli, yalnız yüzü amber (`SectionAmber` zaten tanımlı; yeni varyasyon EKLENMEDİ).
func _make_axis_header(axis: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_label(
		Fmt.upper(ProductUiShared.axis_label(axis)), &"SectionAmber"))
	var rule := HRUiShared.hairline()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(rule)
	return row


func _make_line_row(line_id: String) -> Control:
	var tier: int = ProductState.line_tier(line_id)
	var next_tier: int = ProductLines.next_tier(tier)
	var complete: bool = ProductLines.is_complete(tier)
	var next_step: Dictionary = ProductLines.step_at(line_id, next_tier) if next_tier > 0 else {}
	var next_id: String = String(next_step.get("id", ""))
	var unlocked: bool = next_id != "" and LineGates.is_unlocked(next_id)
	var selectable: bool = next_id != "" and unlocked

	# HOVER = KENAR (hr_ledger.gd'nin reçetesi): iki varyasyonun dolgusu bayt-aynı,
	# yalnız çerçeve açılır, o yüzden satır hover'da bir piksel bile zıplamaz.
	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRow"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	card.add_child(col)

	# --- 1. SATIR: ad · kademe · sayı --------------------------------------
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", ROW_SEP)
	col.add_child(head)

	var name_lbl := UiFactory.make_label(
		_t(String(ProductLines.line(line_id).get("name_key", ""))), &"RowName")
	name_lbl.custom_minimum_size = Vector2(W_NAME, 0)
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(name_lbl)

	var next_lbl: Label = null
	if complete:
		# HAT TAMAMLANDI: kademe sütunu tek soluk cümleye düşer, sayı sütunu boş kalır —
		# önerilecek bir kazanç yok, o yüzden yazılacak bir sayı da yok.
		# "Anlamsal Arama ✓ · hat tamamlandı" — CSV yalnız KUYRUĞU taşıyor
		# (`PROD_LINE_COMPLETE` = "hat tamamlandı"), kademe adı ve orta nokta
		# burada eklenir. Aynı birleştirme grameri ProductUiShared.feature_info_line'da.
		var last: String = _t(String(ProductLines.step_at(line_id, ProductLines.TIER_MAX)
			.get("name_key", "")))
		var done := UiFactory.make_label(
			PART_SEP.join(["%s %s" % [last, MARK_MET], _t("PROD_LINE_COMPLETE")]),
			&"RowMeta", UiTokens.INK_DIM)
		done.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		done.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		head.add_child(done)
	else:
		head.add_child(_make_shipped_cell(line_id, tier))
		head.add_child(_make_arrow_cell(tier > 0))
		next_lbl = UiFactory.make_label(
			_t(String(next_step.get("name_key", ""))), &"RowName")
		next_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		next_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		head.add_child(next_lbl)
		head.add_child(_make_stat_cell(line_id, next_id, tier))

	# --- 2. SATIR: kilit. YALNIZ kilitli kademede, ve yalnız karşılanmayanlar. ---
	if next_id != "" and not unlocked:
		col.add_child(_make_lock_row(next_id))

	_rows[line_id] = {
		"card": card, "next": next_lbl, "hovered": false,
		"selectable": selectable, "step": next_id,
	}

	if selectable:
		HRUiShared.set_mouse_ignore(col)
		# Kilit satırı tıklamayı ve hover'ı KENDİ tutar (tooltip + eylem bağı orada),
		# ama kilitli satır zaten seçilebilir değil — çakışma yok.
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.mouse_entered.connect(_on_row_hover.bind(line_id, true))
		card.mouse_exited.connect(_on_row_hover.bind(line_id, false))
		card.gui_input.connect(_on_row_input.bind(line_id))
	else:
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.focus_mode = Control.FOCUS_NONE
		if complete:
			# SOLUK = yalnız ALFA. Ham bir `Color(...)` yazmamak için modulate'in
			# rengine değil kanalına dokunuyoruz; palet tablosu dışına renk çıkmıyor.
			card.modulate.a = DIM_ALPHA
	return card


## Yayınlanmış kademe: adı SOLUK, yanında ✓. Hat boşsa hücre BOŞ kalır ama
## genişliğini korur — bir sonraki kademe sütunu bütün satırlarda aynı yerde başlar.
func _make_shipped_cell(line_id: String, tier: int) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_S)
	box.custom_minimum_size = Vector2(W_SHIPPED, 0)
	box.alignment = BoxContainer.ALIGNMENT_END
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if tier <= 0:
		return box
	box.add_child(UiFactory.make_label(
		_t(String(ProductLines.step_at(line_id, tier).get("name_key", ""))),
		&"RowMeta", UiTokens.INK_DIM))
	box.add_child(UiFactory.make_label(MARK_MET, &"RowMeta", UiTokens.INK_DIM))
	return box


func _make_arrow_cell(visible_arrow: bool) -> Control:
	var lbl := UiFactory.make_label(ARROW if visible_arrow else "", &"RowMeta", UiTokens.INK_FAINT)
	lbl.custom_minimum_size = Vector2(W_ARROW, 0)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl


## "Efor 8 · Deneyim 7,2 (+3,2)" — efor, kademenin AĞIRLIKLI eksen katkısı ve
## parantez içinde NET kazanç. İkisi de motordan; burada hiçbir çarpma yapılmıyor.
func _make_stat_cell(line_id: String, step_id: String, tier: int) -> Control:
	var axis: String = ProductLines.axis_of(line_id)
	var gain: float = ProductLines.net_gain(line_id, tier)
	var parts: Array[String] = [
		_t("PROD_EFFORT_N").format({"n": ProductLines.effort_of(step_id)}),
		_t("PROD_LINE_CONTRIB").format({
			"axis": ProductUiShared.axis_label(axis),
			"value": Fmt.number(ProductLines.weighted_points(step_id), 1),
			"gain": ("+" if gain >= 0.0 else "") + Fmt.number(gain, 1),
		}),
	]
	var lbl := UiFactory.make_label(PART_SEP.join(parts), &"RowMeta")
	lbl.custom_minimum_size = Vector2(W_STAT, 0)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl


# ------------------------------------------------------------------ kilit satırı

## "Kilit: Ar-Ge "Veri Modeli" ✗ → Araştır · Tasarım ★ ✗ → Eğit / İşe al"
##
## Tek Label DEĞİL, HBox: eylem bağlarının biri CANLI (Eğit / İşe al), diğeri
## İNERT (Araştır) — ikisi aynı cümlenin içinde ama aynı davranışta değil.
## Satırın KENDİSİ tooltip taşır: tam gereksinim listesi, karşılananlar ✓ ile.
## Godot boş tooltip'te ebeveyne yürüdüğü için tıklanabilir bağlar (STOP, boş
## tooltip) yine bu listeyi gösterir; Araştır bağı kendi cümlesini taşır.
func _make_lock_row(step_id: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.tooltip_text = _requirement_tooltip(step_id)

	# ÖLÇÜLMÜŞ GİRİNTİ, göz kararı değil: birinci satırda kademe sütunu
	# W_NAME + W_SHIPPED + W_ARROW + ÜÇ ayraçtan sonra başlıyor. Bu satırın KENDİ
	# ilk ayracı (SPACE_S) da girintiye eklenecek, o yüzden buradan düşülür —
	# yoksa kilit satırı kademenin altına altı piksel sağdan iner.
	var indent := Control.new()
	indent.custom_minimum_size = Vector2(
		W_NAME + W_SHIPPED + W_ARROW + 3 * ROW_SEP - UiTokens.SPACE_S, 0)
	indent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(indent)

	row.add_child(_lock_text(_t("PROD_LOCK_PREFIX")))

	var first := true
	for raw in LineGates.unmet_parts(step_id):
		var part: Dictionary = raw as Dictionary
		if not first:
			row.add_child(_lock_text(PART_SEP.strip_edges()))
		first = false
		row.add_child(_lock_text(_part_text(part)))
		# DÜĞÜM KİMLİĞİ PARÇADAN GELİR (line_gates.gd "node" yazıyor) — "→ Araştır"
		# bağının nereye gideceğini bilmesi için gereken tek şey bu.
		row.add_child(_make_action_link(
			String(part.get("kind", "")), String(part.get("node", ""))))
	return row


func _lock_text(text: String) -> Label:
	var lbl := UiFactory.make_label(text, &"RowMeta", UiTokens.INK_DIM)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl


## Eylem bağının SÖZCÜĞÜ kapının cinsine göre değişir ve bu bilinçlidir: kişi
## kapısı "→ Eğit / İşe al" (eldeki insanı büyütmek önce), toplam kapısı
## "→ İşe al / Eğit" (toplamı büyüten şey önce kişi sayısıdır). §12.9'un sırası.
func _make_action_link(kind: String, node_id: String) -> Control:
	if kind == LineGates.KIND_RESEARCH:
		var research := UiFactory.make_label(
			_t("PROD_LOCK_ACTION_RESEARCH"), &"RowMeta", UiTokens.INK_FAINT)
		research.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if not ResearchSeam.tree_available():
			# İNERT. Ar-Ge sekmesi ürün yayına girene dek kapalı; bağ çizilir,
			# tıklanmaz ve hover'ı sebebini söyler ("geçici bypass yazılmaz").
			research.mouse_filter = Control.MOUSE_FILTER_PASS
			research.tooltip_text = _t("PROD_LOCK_RESEARCH_SOON")
		else:
			# CANLI. `ResearchSeam.tree_available()` artık gerçek durumu döndürüyor,
			# yani bu dal ulaşılabilir. Reçete kişi/toplam bağlarıyla AYNI: amber +
			# STOP + el imleci + gui_input.
			research.add_theme_color_override("font_color", UiTokens.ACCENT)
			research.mouse_filter = Control.MOUSE_FILTER_STOP
			research.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			research.gui_input.connect(_on_research_link_input.bind(node_id))
		return research

	var key: String = "PROD_LOCK_ACTION_TOTAL" if kind == LineGates.KIND_TOTAL \
		else "PROD_LOCK_ACTION_PERSON"
	var link := UiFactory.make_label(_t(key), &"RowMeta", UiTokens.ACCENT)
	link.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	link.mouse_filter = Control.MOUSE_FILTER_STOP
	link.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	link.gui_input.connect(_on_action_link_input)
	return link


## Tek bir gereksinim parçasının cümlesi. `met` işareti PARAMETRE değil parçanın
## kendi cevabı: kilit satırı yalnız ✗ olanları çağırır, tooltip hepsini.
func _part_text(part: Dictionary) -> String:
	var mark: String = MARK_MET if bool(part.get("met", false)) else MARK_UNMET
	var kind: String = String(part.get("kind", ""))
	if kind == LineGates.KIND_RESEARCH:
		return _t("PROD_LOCK_RESEARCH").format({
			"node": ResearchSeam.node_name(String(part.get("node", ""))), "mark": mark})
	var area: String = HRConstants.area_label(String(part.get("area", "")))
	if kind == LineGates.KIND_TOTAL:
		return _t("PROD_LOCK_TOTAL").format({
			"area": area,
			"stars": STAR + _stars_number(float(int(part.get("stars", 0)))),
			"have": STAR + _stars_number(float(part.get("have", 0.0))),
			"mark": mark,
		})
	return _t("PROD_LOCK_PERSON").format({
		"area": area, "stars": STAR.repeat(int(part.get("stars", 0))), "mark": mark})


## Tam gereksinim listesi — karşılananlar ✓ ile. §12.9 bunu EKRANA yasaklıyor ama
## HOVER'A açıyor: oyuncu tek eksik ile üç eksiği ayırt edebilmeli.
func _requirement_tooltip(step_id: String) -> String:
	var lines: Array[String] = []
	for raw in (LineGates.evaluate(step_id).get("parts", []) as Array):
		lines.append(_part_text(raw as Dictionary))
	return "\n".join(lines)


## Yıldız SAYISI metni: tam sayı "5", buçuk "3,5". Toplam kapılarında buçuklar
## yüz değerinden sayılıyor (LineGates §12.6), o yüzden ondalık gerçek olabilir.
func _stars_number(v: float) -> String:
	return str(int(round(v))) if is_equal_approx(v, roundf(v)) else Fmt.number(v, 1)


# ------------------------------------------------------------------ etkileşim

func _on_row_hover(line_id: String, entered: bool) -> void:
	var row: Dictionary = _rows.get(line_id, {}) as Dictionary
	if row.is_empty():
		return
	row["hovered"] = entered
	_style_row(line_id)


func _on_row_input(ev: InputEvent, line_id: String) -> void:
	if not (ev is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = ev as InputEventMouseButton
	if not (mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT):
		return
	_toggle(line_id)


func _on_action_link_input(ev: InputEvent) -> void:
	if not (ev is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = ev as InputEventMouseButton
	if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		train_or_hire_requested.emit()


## "→ Araştır". Düğüm kimliği bağa `bind` ile takılı geldi; bu görünüm ne sekme
## adı ne de akordeon bilir — yalnız hangi düğümün istendiğini söyler.
func _on_research_link_input(ev: InputEvent, node_id: String) -> void:
	if not (ev is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = ev as InputEventMouseButton
	if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		research_requested.emit(node_id)


## SEÇİM. Ekleme kararı ProductLines'ın: `ladder_refusal` boş dönmüyorsa satır
## SESSİZCE reddedilir (aynı hatta ikinci kademe, atlanan kademe, yayınlanmış
## kademe). Kural burada yeniden yazılmıyor — cevabı sorup uyuluyor.
func _toggle(line_id: String) -> void:
	var row: Dictionary = _rows.get(line_id, {}) as Dictionary
	if row.is_empty() or not bool(row.get("selectable", false)):
		return
	var step_id: String = String(row.get("step", ""))
	if step_id == "":
		return
	if _selected.has(step_id):
		_selected.erase(step_id)
	else:
		if ProductLines.ladder_refusal(step_id, ProductState.line_tier(line_id), _selected) != "":
			return
		_selected.append(step_id)
	_style_row(line_id)
	_refresh_count()
	selection_changed.emit(selected_step_ids())


# ------------------------------------------------------------------ boyama

## Satırın üç durumu tek yerde: SEÇİLİ (amber yıkama + amber kenar) · HOVER
## (yalnız kenar açılır, dolgu kıpırdamaz) · durgun. Kenar kalınlığı üç durumda
## da BİR piksel — kalınlaşan bir çerçeve satırı yerinden oynatırdı.
func _style_row(line_id: String) -> void:
	var row: Dictionary = _rows.get(line_id, {}) as Dictionary
	if row.is_empty():
		return
	var card: PanelContainer = row.get("card", null) as PanelContainer
	if card == null or not is_instance_valid(card):
		return
	var step_id: String = String(row.get("step", ""))
	var picked: bool = step_id != "" and _selected.has(step_id)

	if picked:
		var base: StyleBox = card.get_theme_stylebox("panel")
		if base is StyleBoxFlat:
			var sel: StyleBoxFlat = (base as StyleBoxFlat).duplicate()
			sel.bg_color = UiTokens.AMBER_BG
			sel.border_color = UiTokens.ACCENT
			card.add_theme_stylebox_override("panel", sel)
	else:
		card.remove_theme_stylebox_override("panel")
		card.theme_type_variation = &"LedgerRowHover" if bool(row.get("hovered", false)) \
			else &"LedgerRow"

	var next_lbl: Label = row.get("next", null) as Label
	if next_lbl != null and is_instance_valid(next_lbl):
		var tint: Color = UiTokens.INK
		if picked:
			tint = UiTokens.ACCENT
		elif not bool(row.get("selectable", false)):
			tint = UiTokens.INK_FAINT
		next_lbl.add_theme_color_override("font_color", tint)


func _refresh_count() -> void:
	if _count_label != null and is_instance_valid(_count_label):
		_count_label.text = _t("PROD_SELECTED_COUNT").format({"n": _selected.size()})


func _t(key: String) -> String:
	return TranslationServer.translate(key)
