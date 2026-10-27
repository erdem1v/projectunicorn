class_name SprintBoard
extends VBoxContainer

# Orta sütunun panosu: sabit bir başlık ("{n} KART", eksenin haftaları, erken kapanışta bayrak) ve altında kayan gövde. Gövde zaman
# ekseninin zeminini (hafta ayracı, sprint sonu çizgisi, sonraki sprintin çizgili zemini, erken kapanışın taralı alanı, koşarken
# şimdiki an çizgisi) ve kart satırlarını taşır; kartsız planda tek hayalet satır ("+ Kart ekle"), kartsız planda önerinin ilk üç
# adayı ve imleç sol sütunda bir adayın "+"ındayken o adayın hayaleti "EKLENEBİLİR" altında durur. Gövde taşarsa altta "aşağıda
# {n} kart daha" hapı yapışık kalır. Yalnız modeli çizer; satır tıkları sekmeye `action` olarak çıkar. Saat ilerleyince `set_now`
# yalnız şimdiki an çizgisini ve koşan çubukları günceller.

signal action(kind: String, args: Dictionary)

## Hapın hesabında satırın altı bu kadar piksel görünmüyorsa satır "aşağıda" sayılır.
const MORE_SLACK := 10

## Gövdenin kaydırması: yeniden kurulumda yeri korunur (`SprintUiShared.keep_scroll`).
var scroll: ScrollContainer
var _rows: Array = []
var _now: StagePaint
var _ghost_box: VBoxContainer
var _more: Control
var _more_label: Label
var _has_candidates := false
var _ctx: Dictionary


## `nobody` doluysa (kimse çalışamıyor) gövdenin ortasında satırların yerine durur.
func setup(model: Dictionary, nobody: Control) -> void:
	UiFactory.clear(self)
	_rows.clear()
	_now = null
	_ghost_box = null
	_more = null
	var c: Dictionary = model.center
	var running: bool = c.mode == "active"
	_ctx = {"mode": c.mode, "now": c.now_at, "people": c.people, "candidate": false, "hot": false}
	add_theme_constant_override("separation", 0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_head(c))
	var holder := Control.new()
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(holder)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(scroll)
	if nobody != null:
		nobody.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		holder.add_child(nobody)
		scroll.visible = false
		return
	scroll.add_child(_body(c, model.ui.hover_card, running))
	_more = _more_pill()
	holder.add_child(_more)
	scroll.get_v_scroll_bar().value_changed.connect(func(_v: float) -> void: _update_more())
	scroll.resized.connect(_update_more)
	_update_more.call_deferred()


# --- Başlık ---------------------------------------------------------------------------------

## Solda "{n} KART" (erken kapanışta bayrak ve "SPRINT ERKEN BİTER"), eksenin hafta etiketleri ve sonraki sprintin adı.
func _head(c: Dictionary) -> Control:
	var head := Control.new()
	head.custom_minimum_size = Vector2(UiTokens.D_W_CARD_INFO + UiTokens.D_W_TIMELINE, UiTokens.D_H_BOARD_HEAD)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.draw.connect(func() -> void:
		head.draw_rect(Rect2(0.0, head.size.y - UiTokens.BORDER_HAIRLINE, head.size.x, UiTokens.BORDER_HAIRLINE), UiTokens.D_LINE_2))
	var left := SprintUiShared.box(UiTokens.SPACE_L)
	left.add_child(SprintUiShared.label(Fmt.upper(tr(Fmt.count_key("PRODUCT_STATUS_CARDS", c.cards.size())).format({"n": c.cards.size()})), &"Eyebrow"))
	var early: bool = c.close_at < float(c.weeks) - SprintSystem.EPS
	if early:
		var end := SprintUiShared.box(UiTokens.SPACE_XS)
		end.add_child(UiFactory.make_glyph(SprintUiShared.FLAG, UiTokens.D_ICON_TAG, UiTokens.D_INK_2))
		end.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_EARLY_END")), &"Eyebrow", UiTokens.D_INK_2))
		left.add_child(end)
	_at_foot(head, left, 0.0)
	var per: float = UiTokens.D_W_TIMELINE / UiTokens.D_TIMELINE_WEEKS
	for week in int(c.weeks):
		_at_foot(head, SprintUiShared.label(Fmt.upper(tr("PRODUCT_WEEK_ORD").format({"w": week + 1})), &"AxisLabel"),
			UiTokens.D_W_CARD_INFO + roundf(per * week) + UiTokens.SPACE_M)
	_at_foot(head, SprintUiShared.label(Fmt.upper(tr("PRODUCT_SPRINT_TITLE").format({"n": c.sprint + 1})), &"Eyebrow"),
		UiTokens.D_W_CARD_INFO + roundf(per * c.weeks) + UiTokens.SPACE_M)
	if early:
		var flag := UiFactory.make_glyph(SprintUiShared.FLAG, UiTokens.D_ICON_TAG, UiTokens.D_INK_2)
		_at_foot(head, flag, UiTokens.D_W_CARD_INFO + roundf(per * c.close_at) - UiTokens.SPACE_S)
	return head


## `part` başlığın alt çizgisinin üstünde, soldan `x` pikselde durur.
func _at_foot(head: Control, part: Control, x: float) -> void:
	part.anchor_top = 1.0
	part.anchor_bottom = 1.0
	part.grow_vertical = Control.GROW_DIRECTION_BEGIN
	part.offset_left = x
	part.offset_top = -UiTokens.SPACE_S
	part.offset_bottom = -UiTokens.SPACE_S
	head.add_child(part)


# --- Gövde ----------------------------------------------------------------------------------

## Katmanlar üst üste: zemin (ızgara, erken kapanışın alanı), satırlar, şimdiki an çizgisi; zemin ve çizgi eksenin hizasında
## başlar ve gövdenin boyunu doldurur.
func _body(c: Dictionary, hover_card: String, running: bool) -> Control:
	var layers := MarginContainer.new()
	layers.custom_minimum_size.x = UiTokens.D_W_CARD_INFO + UiTokens.D_W_TIMELINE
	layers.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	layers.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var per: float = UiTokens.D_W_TIMELINE / UiTokens.D_TIMELINE_WEEKS
	var under: Array = [StagePaint.part(&"grid", "", {"px": per, "weeks": c.weeks}, Rect2())]
	under[0].set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if c.close_at < float(c.weeks) - SprintSystem.EPS:
		var early: StagePaint = StagePaint.part(&"early", "", {"from": c.close_at, "to": c.weeks}, Rect2())
		early.anchor_bottom = 1.0
		early.offset_left = roundf(per * c.close_at)
		early.offset_right = roundf(per * c.weeks)
		under.append(early)
	layers.add_child(_lane_layer(under))
	var rows := SprintUiShared.column(0)
	rows.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layers.add_child(rows)
	for card: Dictionary in c.cards:
		_rows.append(_row(card, _ctx))
		rows.add_child(_rows.back())
	if c.cards.is_empty():
		rows.add_child(_empty_row())
	var candidates: Array = c.candidates
	_has_candidates = not candidates.is_empty()
	if _has_candidates:
		rows.add_child(_section())
		for card: Dictionary in candidates:
			_rows.append(_row(card, _ctx.merged({"candidate": true, "hot": card.id == hover_card}, true)))
			rows.add_child(_rows.back())
	_ghost_box = SprintUiShared.column(0)
	rows.add_child(_ghost_box)
	if running:
		_now = StagePaint.part(&"now", "", {}, Rect2())
		_now.anchor_bottom = 1.0
		_place_now(c.now_at)
		layers.add_child(_lane_layer([_now]))
	if hover_card != "":
		set_ghost(hover_card)
	return layers


## Eksenin sol kenarından başlayan, kendi boyunu hizalayan katman: `parts` içindeki öğeler eksene göre durur.
func _lane_layer(parts: Array) -> Control:
	var layer := MarginContainer.new()
	layer.add_theme_constant_override("margin_left", UiTokens.D_W_CARD_INFO)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := Control.new()
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fill)
	for part: Control in parts:
		fill.add_child(part)
	return layer


## Satır; pano satırları ve adaylar `_rows`'a girer, imlecin hayaleti girmez (her üstüne gelmede yeniden kurulur).
func _row(card: Dictionary, ctx: Dictionary) -> BoardRow:
	var row := BoardRow.new()
	row.setup(card, ctx)
	row.action.connect(action.emit)
	return row


## Kartsız planın tek hayalet satırı: "+ Kart ekle" ve altında "← MODÜLLER".
func _empty_row() -> Control:
	var cell := PanelContainer.new()
	cell.theme_type_variation = &"GhostRow"
	HRUiShared.D_dashed(cell)
	var col := SprintUiShared.column(0)
	var add := SprintUiShared.box(UiTokens.SPACE_M)
	add.add_child(UiFactory.make_glyph(SprintUiShared.PLUS, UiTokens.D_ICON_TAG, UiTokens.D_INK_3))
	add.add_child(SprintUiShared.label(tr("PRODUCT_ADD_CARD"), &"DataStrong", UiTokens.D_INK_2))
	col.add_child(add)
	var back := SprintUiShared.box(UiTokens.SPACE_M)
	var arrow := UiFactory.make_glyph(SprintUiShared.ARROW, UiTokens.D_ICON_TAG, UiTokens.D_INK_3)
	(arrow as TextureRect).flip_h = true
	back.add_child(arrow)
	back.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_MODULES")), &"Caption"))
	col.add_child(back)
	cell.add_child(col)
	cell.custom_minimum_size = Vector2(UiTokens.D_W_CARD_INFO - UiTokens.SPACE_L, UiTokens.D_H_CARD_ROW - 2.0 * UiTokens.SPACE_XS)
	var wrap := SprintUiShared.pad(cell, Vector4i(0, UiTokens.SPACE_XS, UiTokens.SPACE_L, UiTokens.SPACE_XS))
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return wrap


## "EKLENEBİLİR": aday satırlarının bölümü.
func _section() -> Control:
	var row := MarginContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_BOARD_SECTION
	row.add_theme_constant_override("margin_bottom", UiTokens.SPACE_S)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.draw.connect(func() -> void:
		row.draw_dashed_line(Vector2(0.0, row.size.y - 0.5), Vector2(row.size.x, row.size.y - 0.5), UiTokens.D_LINE_2,
			UiTokens.BORDER_HAIRLINE, UiTokens.SPACE_XS))
	var label := SprintUiShared.label(Fmt.upper(tr("PRODUCT_AVAILABLE")), &"Eyebrow")
	label.size_flags_vertical = Control.SIZE_SHRINK_END
	row.add_child(label)
	return row


## İmleç sol sütunda bir adayın "+"ındayken adayın hayaleti panonun sonunda, planla birlikte oynatılmış yerinde durur; `card_id`
## boşsa kalkar. Planda kart yokken önerinin adayları zaten satırdır: imlecin üstündeki aday açık görünür, listede olmayan aday
## onların altına gelir.
func set_ghost(card_id: String) -> void:
	var listed := false
	for row: BoardRow in _rows:
		if row.is_candidate():
			row.set_hot(row.card.id == card_id)
			listed = listed or row.card.id == card_id
	if _ghost_box == null:
		return
	UiFactory.clear(_ghost_box)
	var ghost: Dictionary = {} if card_id == "" or listed else ProductModel.ghost_row(card_id)
	if ghost.is_empty():
		return
	if not _has_candidates:
		_ghost_box.add_child(_section())
	_ghost_box.add_child(_row(ghost, _ctx.merged({"candidate": true, "hot": true}, true)))
	_update_more.call_deferred()


# --- "aşağıda {n} kart daha" ---------------------------------------------------------------

func _more_pill() -> Control:
	var holder := Control.new()
	holder.anchor_top = 1.0
	holder.anchor_right = 1.0
	holder.anchor_bottom = 1.0
	holder.offset_top = -UiTokens.D_H_BOARD_FADE
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fade := StagePaint.part(&"fade", "", {}, Rect2())
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(fade)
	var pill := PanelContainer.new()
	pill.theme_type_variation = &"MoreHintPill"
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	row.add_child(UiFactory.make_glyph(SprintUiShared.CHEVRON_DOWN, UiTokens.D_ICON_TAG, UiTokens.D_INK_2))
	_more_label = SprintUiShared.label("", &"MoreHint")
	row.add_child(_more_label)
	pill.add_child(row)
	pill.anchor_left = 0.5
	pill.anchor_right = 0.5
	pill.anchor_top = 1.0
	pill.anchor_bottom = 1.0
	pill.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pill.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pill.offset_bottom = -UiTokens.SPACE_S
	holder.add_child(pill)
	holder.visible = false
	return holder


## Satırın altı görünür yüksekliğin `MORE_SLACK` piksel dışındaysa kart "aşağıda" sayılır; kaydırınca güncellenir.
func _update_more() -> void:
	if _more == null or scroll == null:
		return
	var seen: float = scroll.scroll_vertical + scroll.size.y - MORE_SLACK
	var hidden := 0
	for row: BoardRow in _rows:
		if not row.is_candidate() and row.position.y + row.size.y > seen:
			hidden += 1
	_more.visible = hidden > 0
	if hidden > 0:
		_more_label.text = tr(Fmt.count_key("PRODUCT_MORE_BELOW", hidden)).format({"n": hidden})


# --- Saat ve kaydırma -----------------------------------------------------------------------

func _place_now(at: float) -> void:
	var x: float = roundf(at * UiTokens.D_W_TIMELINE / UiTokens.D_TIMELINE_WEEKS)
	_now.offset_left = x - UiTokens.D_NOW_HEAD.x / 2.0
	_now.offset_right = x + UiTokens.D_NOW_HEAD.x / 2.0


## Koşan sprintte saat ilerleyince: şimdiki an çizgisi ve her satırın çubukları.
func set_now(at: float) -> void:
	if _now == null:
		return
	_place_now(at)
	for row: BoardRow in _rows:
		row.set_now(at)


## Satırların aşama listeleri: kapasitenin "yapılan" dolgusu bunlardan okunur.
func stage_lists() -> Array:
	return _rows.filter(func(row: BoardRow) -> bool: return not row.is_candidate()).map(
		func(row: BoardRow) -> Array: return row.card.stages)
