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
# şey o koridordur: kılavuz çizgisi satır arasından ve koridordan geçer — ikisi de
# yapı gereği boş, yani çizgi hiçbir karonun üstünden geçemez.
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
# ÇAPA KURALI: düğüm kartı ağacın ALTINDA, iki sütun genişliğinde ve SABİT yükseklikte
# açılır; ağaç kıpırdamaz, pencere aşağı doğru uzar (tuvalin en küçük boyu). Kart
# seçili ailenin sütunundan başlar; son aile sağ kenara taşmasın diye bir sütun sola
# yaslanır. Kartın içi kendi kaydırmasında.
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
const ROWS := 3
const HEAD := UiTokens.SPACE_3XL   # a family's head over its column
const CHEVRON := "res://assets/icons/util/chevron_left.svg"
const CHECK := "res://assets/icons/util/check.svg"

var _slots: Dictionary = {}        # node_id -> Rect2 (TEK geometri kaynağı)
var _col_x: Dictionary = {}        # family -> float
var _roots: Dictionary = {}        # family -> root node id
var _tiles: Dictionary = {}        # node_id -> Control
var _boxes: Dictionary = {}        # node_id -> Panel (its look follows state, selection, hover)
var _heads: Dictionary = {}        # family -> Control
var _selected: String = ""
var _detail: RnDDetailPanel = null

var _col_w: float = 0.0
var _tile_w: float = 0.0
var _bottom: float = 0.0


func _ready() -> void:
	# Tuvalin kendisi tıklanabilir: boşluğa tıklamak seçimi bırakır. Godot
	# çocukları ÖNCE sınar, o yüzden STOP karoların tıklamasını yutmaz. Seçmek okumaktır:
	# karar beklerken de çalışır.
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_meta(&"gate_reads", true)
	rebuild()
	# Yeniden YERLEŞİM, yeniden KURULUM değil: bir pencere boyu değişikliği açık
	# atama panelinin seçimini düşürmemeli.
	resized.connect(_relayout)


func _gui_input(event: InputEvent) -> void:
	if UiFactory.is_left_click(event):
		accept_event()
		select("")


# ---------------------------------------------------------------- ölçü

func _measure() -> void:
	_col_w = (size.x - 3.0 * UiTokens.D_RND_COL_GAP) / 4.0
	_tile_w = (_col_w - UiTokens.D_RND_CORRIDOR) * 0.5
	_bottom = _row_y(ROWS - 1) + UiTokens.D_RND_TILE_H


func _row_y(row: int) -> float:
	return HEAD + UiTokens.SPACE_XL + float(row) * (UiTokens.D_RND_TILE_H + UiTokens.D_RND_ROW_GAP)


func _detail_top() -> float:
	return _bottom + UiTokens.D_RND_LANE


func _compute_slots() -> void:
	_slots.clear()
	for i in FAMILY_ORDER.size():
		var family: String = String(FAMILY_ORDER[i])
		var col_x: float = float(i) * (_col_w + UiTokens.D_RND_COL_GAP)
		_col_x[family] = col_x
		var root: String = String(_roots[family])
		# KÖK sütuna ortalı — merkezi koridorun merkezidir.
		_slots[root] = Rect2(col_x + (_col_w - _tile_w) * 0.5, _row_y(0), _tile_w, UiTokens.D_RND_TILE_H)
		# DAL A / DAL B, aralarında koridor. Sıra ResearchTree.children_of'un
		# sıralı çıktısıdır — bir isimlendirme kuralı DEĞİL.
		var branches: Array = ResearchTree.children_of(root)
		for j in branches.size():
			var b: String = String(branches[j])
			var bx: float = col_x if j == 0 else col_x + _tile_w + UiTokens.D_RND_CORRIDOR
			_slots[b] = Rect2(bx, _row_y(1), _tile_w, UiTokens.D_RND_TILE_H)
			# DEVAM dalın tam altında: dikey bağ düz bir çizgi olsun diye AYNI x.
			for c in ResearchTree.children_of(b):
				_slots[String(c)] = Rect2(bx, _row_y(2), _tile_w, UiTokens.D_RND_TILE_H)


# ---------------------------------------------------------------- kurulum

## Tam yeniden kurulum: yapı anahtarı değiştiğinde (açılan/tamamlanan düğüm,
## aktif düğüm, donma hali). Karoları serbest bırakır ve yeniden yaratır.
func rebuild() -> void:
	UiFactory.clear(self)
	_tiles.clear()
	_boxes.clear()
	_heads.clear()
	for id in ResearchSeam.NODES.keys():
		if ResearchSeam.placement(String(id)) == ResearchSeam.PLACE_ROOT:
			_roots[ResearchSeam.family(String(id))] = String(id)
	_measure()
	_compute_slots()
	for family in FAMILY_ORDER:
		_heads[family] = _make_head(String(family))
		add_child(_heads[family])
	for nid in _slots.keys():
		_tiles[nid] = _make_tile(String(nid))
		add_child(_tiles[nid])
	# Kart EN SON eklenir: çizim sırasında karoların üstünde kalsın.
	_detail = RnDDetailPanel.new()
	add_child(_detail)
	_apply_positions()
	_paint_selection()
	queue_redraw()


## Ucuz tazeleme: koşan karonun ilerlemesi + başlıklar + kart. Hiçbir düğüm serbest
## bırakılmaz — `research_progress_changed` günde bir kez geliyor ve bütün
## karoları yıkmak için hiçbir sebep yok.
func repaint() -> void:
	for nid in _tiles.keys():
		(_tiles[nid] as Control).propagate_call(&"queue_redraw")
	for family in _heads.keys():
		var count: Label = (_heads[family] as Control).get_child(-1)
		count.text = "%d/%d" % [_family_done(String(family)), FAMILY_SIZE]
	_detail.repaint()
	queue_redraw()


func _relayout() -> void:
	_measure()
	_compute_slots()
	_apply_positions()
	queue_redraw()


func _apply_positions() -> void:
	for family in FAMILY_ORDER:
		var head: Control = _heads[family]
		head.set_position(Vector2(float(_col_x[family]), 0.0))
		head.set_size(Vector2(_col_w, HEAD))
	for nid in _tiles.keys():
		var r: Rect2 = _slots[nid]
		(_tiles[nid] as Control).set_position(r.position)
		(_tiles[nid] as Control).set_size(r.size)
	_place_detail()


## Çapa: seçili ailenin sütunu (son aile bir sütun solda), iki sütun genişlik, SABİT yükseklik.
## Tuval kartla birlikte uzar; pencere boyunu bundan okur.
func _place_detail() -> void:
	_detail.visible = _selected != ""
	custom_minimum_size.y = (_detail_top() + UiTokens.D_H_RND_CARD) if _detail.visible else _bottom + UiTokens.SPACE_M
	if not _detail.visible:
		return
	var at: int = mini(FAMILY_ORDER.find(ResearchSeam.family(_selected)), FAMILY_ORDER.size() - 2)
	_detail.set_position(Vector2(float(_col_x[FAMILY_ORDER[at]]), _detail_top()))
	_detail.set_size(Vector2(2.0 * _col_w + UiTokens.D_RND_COL_GAP, UiTokens.D_H_RND_CARD))


## A family's head: its caps name, the area it reads (the design family's is its own name), and how
## many of its five are done.
func _make_head(family: String) -> HBoxContainer:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var fam: String = Fmt.upper(RnDUiShared.family_name(family))
	head.add_child(UiFactory.make_label(fam, &"GroupLabel"))
	var area: String = RnDUiShared.area_name(family)
	if Fmt.upper(area) != fam:
		head.add_child(UiFactory.make_label(RnDUiShared.t("RND_AREA_OF").format({"area": area}), &"Caption"))
	head.add_child(RnDUiShared.spacer())
	head.add_child(UiFactory.make_label("%d/%d" % [_family_done(family), FAMILY_SIZE], &"Caption"))
	for part: Control in head.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.set_mouse_ignore(head)
	return head


func _family_done(family: String) -> int:
	var n: int = 0
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		if ResearchSeam.family(nid) == family and RnDSystem.node_completed(nid):
			n += 1
	return n


# ---------------------------------------------------------------- karo

## A tile: its box by state, its name on top, its foot (the hexagon, the tier, the cross requirement or the
## frozen mark, the check of a finished one) and, while it runs, its progress along the foot.
func _make_tile(node_id: String) -> Control:
	var state: String = RnDUiShared.tile_state(node_id)
	var tile := Control.new()
	tile.name = "Tile_%s" % node_id
	if state == RnDUiShared.TILE_LOCKED:
		# KİLİTLİ YUVA: zemini YOK, kenarı kesikli. Tek yazısı alanın adı (§3 — ağacın ŞEKLİ
		# görünür, ADI değil). Tıklanmaz: kilitli bir karoyu tıklatmak adı sızdırırdı. Derin bağ
		# (select) yine de seçebilir, çünkü orada adı zaten söyleyen bir sebep var.
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		HRUiShared.D_dashed(tile)
		var cap := UiFactory.make_label(RnDUiShared.t("RND_LOCKED_SLOT").format({
			"area": RnDUiShared.area_name(ResearchSeam.family(node_id))}), &"Caption", UiTokens.D_INK_OFF)
		cap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tile.add_child(cap)
		return tile
	# TAMAMLANMIŞ KARO İNCELENEBİLİR KALIR: §7'nin "seçilemez"i YENİDEN BAŞLATILAMAZ
	# demektir, İNCELENEMEZ değil.
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tile.set_meta(&"gate_reads", true)
	tile.gui_input.connect(_on_tile_input.bind(node_id))
	tile.mouse_entered.connect(_paint_tile.bind(node_id, true))
	tile.mouse_exited.connect(_paint_tile.bind(node_id, false))
	var look: Array = RnDUiShared.TILE_LOOKS[state]
	var box := Panel.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tile.add_child(box)
	_boxes[node_id] = box
	if state == RnDUiShared.TILE_FROZEN:
		HRUiShared.D_dashed(box, UiTokens.D_LINE_3)
	var col := SprintUiShared.column(0)
	var name_label := UiFactory.make_label(ResearchSeam.node_name(node_id), &"TipTitle", look[0])
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.max_lines_visible = 2
	name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(name_label)
	col.add_child(_tile_foot(node_id, state, look[1]))
	var pad := SprintUiShared.pad(col, Vector4i(UiTokens.SPACE_L, UiTokens.SPACE_M, UiTokens.SPACE_M, UiTokens.SPACE_M))
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tile.add_child(pad)
	if state in [RnDUiShared.TILE_RUNNING, RnDUiShared.TILE_FROZEN]:
		tile.add_child(_progress_strip(node_id, state == RnDUiShared.TILE_FROZEN))
	tile.add_child(HRUiShared.D_mark())
	HRUiShared.set_mouse_ignore(box)
	HRUiShared.set_mouse_ignore(pad)
	return tile


## The foot: the hexagon (its stroke is the tier) and the tier's word. A continuation that needs another family
## shows that family's area in the word's place, a frozen tile the pause mark and "frozen": the row and the
## stroke already say the tier, and either fits the tile in both languages.
func _tile_foot(node_id: String, state: String, hex_ink: Color) -> HBoxContainer:
	var foot := SprintUiShared.box(UiTokens.SPACE_S)
	foot.add_child(RnDUiShared.hex_glyph(node_id, hex_ink))
	var cross: String = ResearchTree.cross_of(node_id)
	var mark := SprintUiShared.box(UiTokens.SPACE_XS)
	if state == RnDUiShared.TILE_FROZEN:
		mark.add_child(UiFactory.make_glyph(RnDUiShared.PAUSE, UiTokens.D_ICON_MARK, UiTokens.D_INK_2))
		mark.add_child(SprintUiShared.label(RnDUiShared.t("RND_TIER_FROZEN"), &"SmallMuted", UiTokens.D_INK_2))
	elif cross != "":
		mark.add_child(UiFactory.make_glyph(CHEVRON, UiTokens.D_ICON_MARK, UiTokens.D_INK_3))
		mark.add_child(SprintUiShared.label(RnDUiShared.area_name(ResearchSeam.family(cross)), &"SmallMuted"))
	else:
		mark.add_child(SprintUiShared.label(RnDUiShared.tier_caption(node_id), &"SmallMuted"))
	foot.add_child(mark)
	if state == RnDUiShared.TILE_DONE:
		foot.add_child(RnDUiShared.spacer())
		foot.add_child(UiFactory.make_glyph(CHECK, UiTokens.D_ICON_PART, UiTokens.D_INK_3))
	return foot


## The running research's progress along its tile's foot, inside the border: neutral, never a judgement.
func _progress_strip(node_id: String, frozen: bool) -> Control:
	var strip := Control.new()
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.anchor_top = 1.0
	strip.anchor_right = 1.0
	strip.anchor_bottom = 1.0
	strip.offset_left = UiTokens.BORDER_HAIRLINE
	strip.offset_right = -UiTokens.BORDER_HAIRLINE
	strip.offset_top = -UiTokens.BORDER_HAIRLINE - UiTokens.D_H_TILE_PROGRESS
	strip.offset_bottom = -UiTokens.BORDER_HAIRLINE
	strip.draw.connect(func() -> void:
		strip.draw_rect(Rect2(Vector2.ZERO, strip.size), UiTokens.D_BAR_TRACK)
		strip.draw_rect(Rect2(Vector2.ZERO, Vector2(strip.size.x * RnDSystem.progress(node_id), strip.size.y)),
			UiTokens.D_LINE_3 if frozen else UiTokens.D_INK_2))
	return strip


## The tile's box: selected is ink with its marker, hover a lighter edge; the frozen box keeps its dashes.
func _paint_tile(node_id: String, hovered: bool) -> void:
	var box: Panel = _boxes[node_id]
	var state: String = RnDUiShared.tile_state(node_id)
	var look: StringName = RnDUiShared.TILE_LOOKS[state][2]
	if node_id == _selected and state != RnDUiShared.TILE_FROZEN:
		look = &"RndTileSelected"
	elif hovered and state in [RnDUiShared.TILE_AVAILABLE, RnDUiShared.TILE_DONE]:
		look = StringName(look + "Hover")
	box.theme_type_variation = look
	# The tile's last child is its selected marker.
	(_tiles[node_id] as Control).get_child(-1).visible = node_id == _selected


func _on_tile_input(event: InputEvent, node_id: String) -> void:
	if UiFactory.is_left_click(event):
		accept_event()
		select(node_id)


# ---------------------------------------------------------------- seçim

## `open_assign` derin bağdan gelir (barın "ata"sı true; ağaçtaki tık false).
## Kilitli ama AÇILMAMIŞ bir düğüm de seçilebilir: kart kendini "Önce {düğüm}." diye
## açıklayabilsin diye (§7).
func select(node_id: String, open_assign: bool = false) -> void:
	if node_id != "" and not _slots.has(node_id):
		return
	_selected = node_id
	_paint_selection(open_assign)
	selection_changed.emit(_selected)
	queue_redraw()


func _paint_selection(open_assign: bool = false) -> void:
	for nid in _boxes.keys():
		_paint_tile(String(nid), false)
	if _selected != "":
		_detail.show_node(_selected, open_assign)
	_place_detail()


# ---------------------------------------------------------------- çizgiler

func _draw() -> void:
	if _slots.is_empty():
		return
	for family in FAMILY_ORDER:
		var x: float = float(_col_x[family])
		draw_line(Vector2(x, HEAD - 0.5), Vector2(x + _col_w, HEAD - 0.5), UiTokens.D_LINE_1, UiTokens.BORDER_HAIRLINE)
		# AİLE İÇİ BAĞLAR — kalıcı. Açılmamış çocuğa giden bağ KESİKLİ: §3 "Ağacın şekli baştan
		# görünür" — şekil ilk saniyeden okunur, içerik açıldıkça dolar.
		_draw_family_lines(String(family))
	_draw_guide()
	# ÇAPRAZ — YALNIZ seçiliyken, ağacın altındaki şeritten geçerek.
	_draw_cross()


func _draw_family_lines(family: String) -> void:
	var root: String = String(_roots[family])
	var rr: Rect2 = _slots[root]
	var root_cx: float = rr.get_center().x
	var mid_y: float = rr.end.y + UiTokens.D_RND_ROW_GAP * 0.5
	for b in ResearchTree.children_of(root):
		var bid := String(b)
		var br: Rect2 = _slots[bid]
		var bcx: float = br.get_center().x
		# Gövde her dal için yeniden çizilir (iki dal aynı ana çizgiyi paylaşır); kök
		# tamamlandığında iki dal AYNI ANDA açılır (§3), o yüzden iki geçiş asla çelişmez.
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
		draw_line(a, b, UiTokens.D_LINE_3, UiTokens.D_RND_LINE, true)
	else:
		draw_dashed_line(a, b, UiTokens.D_LINE_2, UiTokens.D_RND_LINE, UiTokens.D_RND_DASH)


## Kılavuz: seçili karodan karta, hiçbiri bir karonun üstünden GEÇMEZ. Dal karosu koridora bakan
## yanından çıkar (kendi devamına giden kenarın üstünden geçmesin), kök 6 px yandan iner (kendi
## gövdesinin yanında), devam ayağından şeride iner; sonra ailenin koridorundan karta.
func _draw_guide() -> void:
	if _selected == "":
		return
	var r: Rect2 = _slots[_selected]
	var corridor: float = float(_col_x[ResearchSeam.family(_selected)]) + _col_w * 0.5
	var pts := PackedVector2Array()
	match ResearchSeam.placement(_selected):
		ResearchSeam.PLACE_BRANCH:
			var side: float = r.end.x if r.get_center().x < corridor else r.position.x
			pts = PackedVector2Array([Vector2(side, r.get_center().y), Vector2(corridor, r.get_center().y)])
		ResearchSeam.PLACE_ROOT:
			corridor += UiTokens.SPACE_S
			pts = PackedVector2Array([Vector2(corridor, r.end.y)])
		_:
			var lane: float = _bottom + UiTokens.D_RND_LANE * 0.35
			pts = PackedVector2Array([Vector2(r.get_center().x, r.end.y), Vector2(r.get_center().x, lane),
				Vector2(corridor, lane)])
	pts.append(Vector2(corridor, _detail_top()))
	draw_polyline(pts, UiTokens.D_INK_2, UiTokens.BORDER_FOCUS, true)


## Çapraz koşul (§3). Hedef DAİMA başka bir ailenin KÖKÜDÜR (ResearchTree
## yükleme sırasında doğruluyor), ve bir kökün merkezi kendi sütununun koridor
## merkezidir — yani şeritten köke tırmanan dikey parça o sütunun boş
## koridorundan geçer.
func _draw_cross() -> void:
	if _selected == "" or ResearchTree.cross_of(_selected) == "":
		return
	var sel: Rect2 = _slots[_selected]
	var target: Rect2 = _slots[ResearchTree.cross_of(_selected)]
	var lane: float = _bottom + UiTokens.D_RND_LANE * 0.72
	for seg in [[Vector2(sel.get_center().x, sel.end.y), Vector2(sel.get_center().x, lane)],
			[Vector2(sel.get_center().x, lane), Vector2(target.get_center().x, lane)],
			[Vector2(target.get_center().x, lane), Vector2(target.get_center().x, target.end.y)]]:
		draw_dashed_line(seg[0], seg[1], UiTokens.D_INK_4, UiTokens.D_RND_LINE, UiTokens.D_RND_DOT)
