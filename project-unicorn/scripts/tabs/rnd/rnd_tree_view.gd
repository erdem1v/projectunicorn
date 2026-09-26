class_name RnDTreeView
extends Control

# ============================================================================
# AR-GE AĞACI (§3 · §8).
#
# KAFES YÜK TAŞIYAN KARARDIR. Bir aile sütunu ÜST ÜSTE BEŞ KARO DEĞİLDİR; ÜÇ
# SATIRDA beş yuvadır:
#
#         KÖK              (satır 0, sütuna ORTALI)
#       /     \
#   DAL A    DAL B         (satır 1)
#     |        |
# DEVAM A  DEVAM B         (satır 2)
#
# Ortada KALICI OLARAK BOŞ bir KORİDOR kalır. Çapa kuralını BELİRLENİMCİ yapan
# şey o koridordur: kılavuz çizgisinin 2. parçası bir satır arasında, 3. parçası
# koridorda yaşar — ikisi de yapı gereği boş, yani çizgi hiçbir karonun üstünden
# geçemez.
#
# UYGULAMA:
#   · `_slots` (node_id → Rect2) her yeniden yerleşimde BİR KEZ hesaplanır.
#   · Karolar GERÇEK düğümlerdir (`set_position`/`set_size`), bir GridContainer
#     DEĞİL: dal yuvaları adlarını KIPIRDAMADAN almalı ve açılış animasyonsuz
#     olmalı; bir kap içerik değişince akar.
#   · `_draw()` her çizgi için AYNI `_slots` sözlüğünü okur, yani bir çizgi
#     bayatlamış bir karoyu asla gösteremez. Godot düğümün kendi `_draw()`'unu
#     çocuklarından ÖNCE işler — çizgiler karoların ALTINA bedavaya düşer.
#
# ÇAPA KURALI: detay paneli ağacın ALTINDAKİ ayrılmış şeride düşer, SABİT
# yükseklikte, seçili sütunun x'inde ve `_col_w` genişliğinde. Yani bir karonun
# üstünü asla örtmez, kendi sütununun genişliği dışına taşmaz ve PANELİN İÇERİĞİ
# NE OLURSA OLSUN DÜZEN KAYMAZ — panelin içi kendi ScrollContainer'ında. Seçim
# yokken panel gizlidir ve şerit boş durur; o ayrılmış boşluk kuralın bedelidir.
# ============================================================================

signal selection_changed(node_id: String)

## §4.1-§4.4'ün sütun sırası. Ağacın okunuşu bu sıradır; alfabetik DEĞİL.
const FAMILY_ORDER := [
	ResearchSeam.FAMILY_CAPABILITY,
	ResearchSeam.FAMILY_PLATFORM,
	ResearchSeam.FAMILY_PRACTICE,
	ResearchSeam.FAMILY_DESIGN,
]
const FAMILY_SIZE := 5          # §3 — her ailede bir kök, iki dal, iki devam

# --- Ölçüler. Hiçbiri bir viewport'a çakılı DEĞİL: `_col_w` ve `_tile_w` `size.x`ten
#     türetilir, satır arası ise kalan yükseklikten (aşağıdaki _measure).
const PAGE_PAD := 28.0          # tuvalin sol/sağ kenar boşluğu
const COL_GAP := 28.0           # sütunlar arası
const CORRIDOR_W := 24.0        # sütunun ortasındaki kalıcı boş şerit
const TILE_H := 84.0
const TILE_H_MIN := 62.0        # ölçek merdiveninin dar kademeleri için taban
const ROW_GAP_MIN := 34.0       # kılavuzun 2. parçasının sığdığı en dar aralık
const ROW_GAP_MAX := 76.0
const COL_HEADER_H := 24.0
const CROSS_LANE_H := 28.0      # ağaç ile şerit arasındaki çapraz koridoru
const DETAIL_H := 280.0         # SABİT — düzenin kaymamasının tek sebebi.
const ROWS := 3
const TILE_PAD_X := 10          # karonun iç dolgusu
const TILE_PAD_Y := 8

const LINE_INTRA := 1.5
const LINE_GUIDE := 2.0
const LINE_CROSS := 1.5
const DASH_INTRA := 5.0
const DASH_CROSS := 4.0
const SELECT_EDGE_W := 2

var _slots: Dictionary = {}        # node_id -> Rect2 (TEK geometri kaynağı)
var _cols: Dictionary = {}         # family -> {"x": float, "root": String}
var _tiles: Dictionary = {}        # node_id -> Control
var _frames: Dictionary = {}       # node_id -> Panel (hover yalnız BUNU boyar)
var _fills: Dictionary = {}        # node_id -> Panel (yüzde çapalı dolgu)
var _headers: Dictionary = {}      # family -> Label
var _selected: String = ""
var _detail: RnDDetailPanel = null

var _col_w: float = 0.0
var _tile_w: float = 0.0
var _row_gap: float = 0.0
var _tile_h: float = TILE_H
var _top: float = 0.0
var _tree_bottom: float = 0.0
var _detail_top: float = 0.0


func _ready() -> void:
	# Tuvalin kendisi tıklanabilir: boşluğa tıklamak seçimi bırakır. Godot
	# çocukları ÖNCE sınar, o yüzden STOP karoların tıklamasını yutmaz.
	mouse_filter = Control.MOUSE_FILTER_STOP
	rebuild()
	# Yeniden YERLEŞİM, yeniden KURULUM değil: bir pencere boyu değişikliği açık
	# atama panelinin seçimini düşürmemeli.
	resized.connect(_relayout)


func _gui_input(event: InputEvent) -> void:
	if RnDUiShared.is_left_click(event):
		accept_event()
		select("")


# ---------------------------------------------------------------- ölçü

func _measure() -> void:
	_col_w = maxf(140.0, (size.x - 2.0 * PAGE_PAD - 3.0 * COL_GAP) / 4.0)
	_tile_w = maxf(72.0, (_col_w - CORRIDOR_W) * 0.5)
	_top = COL_HEADER_H + UiTokens.SPACE_M
	# Satır arası KALAN yükseklikten türetilir ve kelepçelenir. Sabit bir aralık
	# kısa bir viewport'ta ağacı şeridin üstüne bindirir, uzun bir viewport'ta ağacın
	# altında ölü bir bant bırakırdı; kelepçe ikisini de kapatıyor.
	var avail: float = size.y - DETAIL_H - CROSS_LANE_H - _top
	# ÖLÇEK MERDİVENİ: mantıksal viewport OYUN İÇİNDE değişiyor (Ayarlar → ölçek);
	# karo boyu sabit kalsaydı %125'te üç satır ayrılmış şeridin altına taşardı.
	# Önce KARO BOYU sıkışır (84 → 62 tabanına), sonra satır arası dağıtılır;
	# çapa kuralı (sabit DETAIL_H) böylece her kademede korunur.
	_tile_h = clampf((avail - 2.0 * ROW_GAP_MIN) / float(ROWS), TILE_H_MIN, TILE_H)
	_row_gap = clampf((avail - ROWS * _tile_h) / float(ROWS - 1), ROW_GAP_MIN, ROW_GAP_MAX)
	_tree_bottom = _row_y(ROWS - 1) + _tile_h
	_detail_top = _tree_bottom + CROSS_LANE_H
	# Son çare kelepçesi: panel hiçbir koşulda tuvalin dışına taşmaz.
	_detail_top = minf(_detail_top, maxf(_tree_bottom + UiTokens.SPACE_M, size.y - DETAIL_H))


func _row_y(row: int) -> float:
	return _top + float(row) * (_tile_h + _row_gap)


func _col_x(family: String) -> float:
	return float(_cols[family]["x"])


func _compute_slots() -> void:
	_slots.clear()
	_cols.clear()
	for i in FAMILY_ORDER.size():
		var family: String = String(FAMILY_ORDER[i])
		var col_x: float = PAGE_PAD + float(i) * (_col_w + COL_GAP)
		var root: String = _root_of(family)
		_cols[family] = {"x": col_x, "root": root}
		if root == "":
			continue
		# KÖK sütuna ortalı — merkezi koridorun merkezidir.
		_slots[root] = Rect2(col_x + (_col_w - _tile_w) * 0.5, _row_y(0), _tile_w, _tile_h)
		# DAL A / DAL B, aralarında koridor. Sıra ResearchTree.children_of'un
		# sıralı çıktısıdır — bir isimlendirme kuralı DEĞİL.
		var branches: Array = ResearchTree.children_of(root)
		for j in branches.size():
			var b: String = String(branches[j])
			var bx: float = col_x if j == 0 else col_x + _tile_w + CORRIDOR_W
			_slots[b] = Rect2(bx, _row_y(1), _tile_w, _tile_h)
			# DEVAM dalın tam altında: dikey bağ düz bir çizgi olsun diye AYNI x.
			for c in ResearchTree.children_of(b):
				_slots[String(c)] = Rect2(bx, _row_y(2), _tile_w, _tile_h)


func _root_of(family: String) -> String:
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		if ResearchSeam.family(nid) == family \
				and ResearchSeam.placement(nid) == ResearchSeam.PLACE_ROOT:
			return nid
	return ""


# ---------------------------------------------------------------- kurulum

## Tam yeniden kurulum: yapı anahtarı değiştiğinde (açılan/tamamlanan düğüm,
## aktif düğüm, donma hali). Karoları serbest bırakır ve yeniden yaratır.
func rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_tiles.clear()
	_frames.clear()
	_fills.clear()
	_headers.clear()

	_measure()
	_compute_slots()

	for family in FAMILY_ORDER:
		_headers[family] = _make_header(String(family))
		add_child(_headers[family])
	for nid in _slots.keys():
		var tile: Control = _make_tile(String(nid))
		_tiles[nid] = tile
		add_child(tile)

	# Detay paneli EN SON eklenir: çizim sırasında karoların üstünde kalsın.
	_detail = RnDDetailPanel.new()
	# Atama paneli açılıp kapanınca panelin KUTUSU değişmez, ama kılavuz çizgisi
	# panelin üst kenarına dayanıyor — tuval tazelenir.
	_detail.assign_visibility_changed.connect(queue_redraw)
	add_child(_detail)

	_apply_positions()
	_paint_selection()
	queue_redraw()


## Ucuz tazeleme: koşan karonun dolgusu + başlıklar + kart. Hiçbir düğüm serbest
## bırakılmaz — `research_progress_changed` günde bir kez geliyor ve bütün
## karoları yıkmak için hiçbir sebep yok.
func repaint() -> void:
	for nid in _fills.keys():
		RnDUiShared.set_fill(_fills[nid] as Panel, RnDSystem.progress(String(nid)))
	for family in _headers.keys():
		(_headers[family] as Label).text = RnDUiShared.column_header(String(family),
			_family_done(String(family)), FAMILY_SIZE)
	if _detail != null and is_instance_valid(_detail):
		_detail.repaint()
	queue_redraw()


func _relayout() -> void:
	_measure()
	_compute_slots()
	_apply_positions()
	queue_redraw()


func _apply_positions() -> void:
	for family in FAMILY_ORDER:
		var lbl: Label = _headers[family] as Label
		lbl.set_position(Vector2(_col_x(family), 0.0))
		lbl.set_size(Vector2(_col_w, COL_HEADER_H))
	for nid in _tiles.keys():
		var tile: Control = _tiles[nid] as Control
		var r: Rect2 = _slots.get(nid, Rect2()) as Rect2
		tile.set_position(r.position)
		tile.set_size(r.size)
	_place_detail()


## Çapa: seçili SÜTUNUN x'i, `_col_w` genişlik, SABİT yükseklik.
func _place_detail() -> void:
	if _selected == "":
		_detail.visible = false
		return
	_detail.visible = true
	_detail.set_position(Vector2(_col_x(ResearchSeam.family(_selected)), _detail_top))
	_detail.set_size(Vector2(_col_w, DETAIL_H))


func _make_header(family: String) -> Label:
	var lbl := UiFactory.make_label(
		RnDUiShared.column_header(family, _family_done(family), FAMILY_SIZE), &"ColumnHeader")
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.clip_text = true
	lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl


func _family_done(family: String) -> int:
	var n: int = 0
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		if ResearchSeam.family(nid) == family and RnDSystem.node_completed(nid):
			n += 1
	return n


# ---------------------------------------------------------------- karo

## KARO KABUĞU KODDA KURULU, ve iki ayrı sebeple:
##   1. Yüzdelik dolgu. Bir `StyleBoxFlat` yüzde İFADE EDEMEZ; dolgu ayrı bir
##      çocuk Panel'dir (RnDUiShared.fill_host).
##   2. Sol kenar. Godot bir stylebox'ta kenarlara AYRI RENK veremez ve donmuş
##      karoda çerçeve ile sol kenar farklı renktedir — sol kenar da ayrı düğüm.
func _make_tile(node_id: String) -> Control:
	var state: String = RnDUiShared.tile_state(node_id)
	var tile := Control.new()
	tile.name = "Tile_%s" % node_id

	if state == RnDUiShared.TILE_LOCKED:
		# KİLİTLİ YUVA: zemini YOK, çerçevesi tuvalin kesikli dikdörtgeni (bkz.
		# _draw). Tek yazısı alanın adı (§3 — ağacın ŞEKLİ görünür, ADI değil; §3 ve
		# §5.5 onu "? Ürün" diye yazar, RND_LOCKED_SLOT "?" taşımıyor). Tıklanmaz:
		# kilitli bir karoyu tıklatmak adı sızdırırdı. Derin bağ (select) yine de
		# seçebilir, çünkü orada adı zaten söyleyen bir sebep var.
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cap := UiFactory.make_label(RnDUiShared.t("RND_LOCKED_SLOT").format({
			"area": RnDUiShared.area_name(ResearchSeam.family(node_id))}),
			&"MicroLabel", UiTokens.INK_FAINT)
		cap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(cap)
		return tile

	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	# TAMAMLANMIŞ KARO İNCELENEBİLİR KALIR: §7'nin "seçilemez"i YENİDEN
	# BAŞLATILAMAZ demektir, İNCELENEMEZ değil. İşaretçi ok kalır: tıklama bir
	# EYLEM değil, bir okuma.
	tile.mouse_default_cursor_shape = Control.CURSOR_ARROW if state == RnDUiShared.TILE_DONE \
		else Control.CURSOR_POINTING_HAND
	tile.gui_input.connect(_on_tile_input.bind(node_id))
	if state != RnDUiShared.TILE_DONE:
		tile.mouse_entered.connect(_on_tile_hover.bind(node_id, true))
		tile.mouse_exited.connect(_on_tile_hover.bind(node_id, false))

	# 1. TABAK — düz zemin, kenarsız.
	var plate := Panel.new()
	plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var plate_sb := StyleBoxFlat.new()
	plate_sb.bg_color = UiTokens.CARD_BG
	plate_sb.set_corner_radius_all(UiTokens.RADIUS_M)
	plate_sb.anti_aliasing = false
	plate.add_theme_stylebox_override("panel", plate_sb)
	tile.add_child(plate)

	# 2. DOLGU — yalnız koşan karoda; yüzde çapalı, kırpılmış.
	if state == RnDUiShared.TILE_RUNNING:
		tile.add_child(RnDUiShared.fill_host(_fills, node_id))
		RnDUiShared.set_fill(_fills[node_id] as Panel, RnDSystem.progress(node_id))

	# 3. ÇERÇEVE — dolgunun ÜSTÜNDE, yoksa dolgu kenarı yer.
	var frame := Panel.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _frame_box(state, false))
	tile.add_child(frame)
	_frames[node_id] = frame

	# 4. SOL KENAR — 2px, çerçeveden BAŞKA renkte olabildiği için ayrı düğüm.
	#    Tamamlanmış karoda kenar yok.
	if state != RnDUiShared.TILE_DONE:
		var edge := Panel.new()
		edge.anchor_bottom = 1.0
		edge.offset_right = SELECT_EDGE_W
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var esb := StyleBoxFlat.new()
		esb.bg_color = UiTokens.INK_DIM if state == RnDUiShared.TILE_FROZEN else UiTokens.ACCENT
		esb.anti_aliasing = false
		edge.add_theme_stylebox_override("panel", esb)
		tile.add_child(edge)

	tile.add_child(_tile_content(node_id, state))
	return tile


func _tile_content(node_id: String, state: String) -> Control:
	var ink: Color = RnDUiShared.state_ink(state)
	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override("margin_left", TILE_PAD_X + SELECT_EDGE_W)
	pad.add_theme_constant_override("margin_right", TILE_PAD_X)
	pad.add_theme_constant_override("margin_top", TILE_PAD_Y)
	pad.add_theme_constant_override("margin_bottom", TILE_PAD_Y)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	pad.add_child(col)

	# --- 1. satır: altıgen + ad (+ tamamlandıysa ✓) ---
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_S)
	head.add_child(RnDUiShared.hex_glyph(node_id, ink))
	var name_lbl := UiFactory.make_label(ResearchSeam.node_name(node_id), &"RowName", ink)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.add_child(name_lbl)
	if state == RnDUiShared.TILE_DONE:
		head.add_child(UiFactory.make_label(RnDUiShared.MARK_DONE, &"RowName", UiTokens.INK_DIM))
	col.add_child(head)

	# --- 2. satır: mertebe + (varsa) çapraz köşe işareti ---
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", UiTokens.SPACE_S)
	foot.add_child(UiFactory.make_label(
		RnDUiShared.tier_caption(node_id, state == RnDUiShared.TILE_FROZEN), &"MicroLabel"))
	foot.add_child(RnDUiShared.spacer())
	# ÇAPRAZ İŞARETİ KALICIDIR: çapraz ÇİZGİ yalnız seçiliyken çizilir, ama köşe
	# işareti ("⇠ Tasarım") hep durur — yoksa oyuncu bir düğümün başka bir aileye
	# bağlı olduğunu ancak ona tıklayınca öğrenirdi.
	var cross: String = ResearchTree.cross_of(node_id)
	if cross != "":
		foot.add_child(UiFactory.make_label(RnDUiShared.t("RND_CROSS_MARK").format({
			"area": RnDUiShared.area_name(ResearchSeam.family(cross))}), &"MicroLabel"))
	col.add_child(foot)

	HRUiShared.set_mouse_ignore(pad)
	return pad


## Çerçeve kutusu. Kalınlık her durumda AYNI, o yüzden hover'da karo bir piksel
## bile oynamaz. Hover YALNIZ KENARI açar — dolgu kıpırdamaz.
func _frame_box(state: String, hovered: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.draw_center = false
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.set_corner_radius_all(UiTokens.RADIUS_M)
	sb.anti_aliasing = false
	match state:
		RnDUiShared.TILE_AVAILABLE, RnDUiShared.TILE_RUNNING:
			sb.border_color = UiTokens.ACCENT_HOVER if hovered else UiTokens.ACCENT
		RnDUiShared.TILE_FROZEN:
			sb.border_color = UiTokens.BORDER_HOVER
		_:
			sb.border_color = UiTokens.CARD_BORDER
	return sb


func _on_tile_hover(node_id: String, entered: bool) -> void:
	# Yeniden kurulumda karo imlecin altından çekilirken de mouse_exited gelir;
	# o anda sözlük temizlenmiş olabilir.
	var frame: Panel = _frames.get(node_id, null) as Panel
	if frame != null and is_instance_valid(frame):
		frame.add_theme_stylebox_override("panel",
			_frame_box(RnDUiShared.tile_state(node_id), entered))


func _on_tile_input(event: InputEvent, node_id: String) -> void:
	if RnDUiShared.is_left_click(event):
		accept_event()
		select(node_id)


# ---------------------------------------------------------------- seçim

## `open_assign` derin bağdan gelir (barın "ata"sı true, Konsept'in
## "→ Araştır"ı false). Kilitli ama AÇILMAMIŞ bir düğüm de seçilebilir: kart
## kendini "Önce {düğüm}." diye açıklayabilsin diye (§7).
func select(node_id: String, open_assign: bool = false) -> void:
	if node_id != "" and not _slots.has(node_id):
		return
	_selected = node_id
	_paint_selection(open_assign)
	selection_changed.emit(_selected)
	queue_redraw()


func _paint_selection(open_assign: bool = false) -> void:
	if _detail == null or not is_instance_valid(_detail):
		return
	if _selected != "":
		_detail.show_node(_selected, open_assign)
	_place_detail()


# ---------------------------------------------------------------- çizgiler

func _draw() -> void:
	if _slots.is_empty():
		return
	# 1. KİLİTLİ YUVALAR — kesikli dikdörtgen. Karonun kendi işi değil: bir
	#    StyleBoxFlat kesikli kenar taşımaz.
	for nid in _slots.keys():
		if not RnDSystem.revealed(String(nid)):
			RnDUiShared.draw_dashed_rect(self, (_slots[nid] as Rect2).grow(-0.5),
				UiTokens.BORDER_DASHED, 1.0, DASH_INTRA)

	# 2. AİLE İÇİ BAĞLAR — kalıcı. Açılmamış çocuğa giden bağ KESİKLİ: §3 "Ağacın
	#    şekli baştan görünür" — şekil ilk saniyeden okunur, içerik açıldıkça dolar.
	for family in FAMILY_ORDER:
		_draw_family_lines(String(family))

	# 3. KILAVUZ — seçili karodan detay şeridine, üç parça.
	_draw_guide()

	# 4. ÇAPRAZ — YALNIZ seçiliyken, ağacın altındaki koridordan geçerek.
	_draw_cross()


func _draw_family_lines(family: String) -> void:
	var root: String = String(_cols[family]["root"])
	if root == "":
		return
	var rr: Rect2 = _slots[root] as Rect2
	var root_cx: float = rr.get_center().x
	var mid_y: float = rr.end.y + _row_gap * 0.5
	for b in ResearchTree.children_of(root):
		var bid := String(b)
		var br: Rect2 = _slots[bid] as Rect2
		var bcx: float = br.get_center().x
		# Gövde her dal için yeniden çizilir (iki dal aynı ana çizgiyi paylaşır);
		# çizim ÇOCUĞUN kendi durumunu taşısın diye böyle — kök tamamlandığında
		# iki dal AYNI ANDA açılır (§3), o yüzden iki geçiş asla çelişmez.
		_line(Vector2(root_cx, rr.end.y), Vector2(root_cx, mid_y), bid)
		_line(Vector2(root_cx, mid_y), Vector2(bcx, mid_y), bid)
		_line(Vector2(bcx, mid_y), Vector2(bcx, br.position.y), bid)
		for c in ResearchTree.children_of(bid):
			var cid := String(c)
			_line(Vector2(bcx, br.end.y), Vector2(bcx, (_slots[cid] as Rect2).position.y), cid)


## Bir aile-içi bağ. Çocuk açıldıysa DÜZ, açılmadıysa KESİKLİ.
func _line(a: Vector2, b: Vector2, child_id: String) -> void:
	if a.is_equal_approx(b):
		return
	if RnDSystem.revealed(child_id):
		draw_line(a, b, UiTokens.CARD_BORDER, LINE_INTRA, true)
	else:
		draw_dashed_line(a, b, UiTokens.CARD_BORDER, LINE_INTRA, DASH_INTRA)


## Kılavuz. Üç parça, ve hiçbiri bir karonun üstünden GEÇEMEZ:
##   1. karodan aşağı, satır arasına (ya da son satırda çapraz koridoruna),
##   2. yatay, sütunun KORİDOR merkezine — satır arası yapı gereği boş,
##   3. koridordan düz aşağı, şeridin üst kenarına — koridor yapı gereği boş.
## Koridor merkezi kök karonun merkeziyle AYNI x'tir.
func _draw_guide() -> void:
	if _selected == "":
		return
	var r: Rect2 = _slots[_selected] as Rect2
	var cx: float = r.get_center().x
	var corridor: float = _col_x(ResearchSeam.family(_selected)) + _col_w * 0.5
	var lane_y: float = r.end.y + _row_gap * 0.5
	if ResearchSeam.placement(_selected) == ResearchSeam.PLACE_CONT:
		lane_y = _tree_bottom + CROSS_LANE_H * 0.35
	draw_line(Vector2(cx, r.end.y), Vector2(cx, lane_y), UiTokens.ACCENT, LINE_GUIDE, true)
	if not is_equal_approx(cx, corridor):
		draw_line(Vector2(cx, lane_y), Vector2(corridor, lane_y),
			UiTokens.ACCENT, LINE_GUIDE, true)
	draw_line(Vector2(corridor, lane_y), Vector2(corridor, _detail_top),
		UiTokens.ACCENT, LINE_GUIDE, true)


## Çapraz koşul (§3). Hedef DAİMA başka bir ailenin KÖKÜDÜR (ResearchTree
## yükleme sırasında doğruluyor), ve bir kökün merkezi kendi sütununun koridor
## merkezidir — yani şeritten köke tırmanan dikey parça o sütunun boş
## koridorundan geçer. Kesişme yok, hesap yok.
func _draw_cross() -> void:
	if _selected == "":
		return
	var src: String = ResearchTree.cross_of(_selected)
	if src == "":
		return
	var sel: Rect2 = _slots[_selected] as Rect2
	var target: Rect2 = _slots[src] as Rect2
	var sel_cx: float = sel.get_center().x
	var src_cx: float = target.get_center().x
	var lane_y: float = _tree_bottom + CROSS_LANE_H * 0.72
	draw_dashed_line(Vector2(sel_cx, sel.end.y), Vector2(sel_cx, lane_y),
		UiTokens.ACCENT, LINE_CROSS, DASH_CROSS)
	draw_dashed_line(Vector2(sel_cx, lane_y), Vector2(src_cx, lane_y),
		UiTokens.ACCENT, LINE_CROSS, DASH_CROSS)
	draw_dashed_line(Vector2(src_cx, lane_y), Vector2(src_cx, target.end.y),
		UiTokens.ACCENT, LINE_CROSS, DASH_CROSS)
