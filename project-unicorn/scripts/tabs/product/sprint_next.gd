class_name SprintNext
extends ScrollContainer

# Sağ sütun: üstte HAZIRLIK (ekipteki PM'ler ve hazırladıkları kart sayısı; PM yoksa soluk "PM yok"), altında kesikli çerçeveli sonraki
# sprint kutusu: başlık, üç aşamanın yükü (devreden kısım taralı, planlı kısım dolu, ekibin gücüne oranlı), DEVREDEN (sprint
# çizgisini aşan paylar) ve KARTLAR (ad, efor, her aşamanın payı önden yapılan kadar dolu şerit, önden çalışanların yüzleri, hazırlayan PM).
# Kart ve devreden yoksa yalnız başlık ve aşama yükü kalır. Yalnız modeli çizer; kart tuşları sekmeye `action` olarak çıkar. Her öğe
# kendi Control'üdür.

signal action(kind: String, args: Dictionary)

## DEVREDEN en çok bu kadar satır gösterir; beşten çoğu en büyük dördü ve "+{n} kart" satırıdır.
const CARRIED_ROWS := 4


## Devreden satırı: aşamanın bandında ikon, kart adı ve efor; taramalı zemini satırın kendi çizimidir.
class CarryRow extends PanelContainer:
	func _draw() -> void:
		var box := Rect2(Vector2.ZERO, size)
		StagePaint.hatch(self, box, Color.TRANSPARENT, Color(UiTokens.D_warn(), UiTokens.D_CARRY_HATCH_ALPHA), UiTokens.D_HATCH)
		draw_rect(box.grow(-UiTokens.BORDER_HAIRLINE / 2.0), Color(UiTokens.D_warn(), UiTokens.D_CARRY_EDGE_ALPHA), false, UiTokens.BORDER_HAIRLINE)


## Bir aşama payının altında önden çalışanların yüzleri, üst üste binerek; hücreye sığmayanların yerini son sığan yüzün ardında
## "+{n}" alır (o da sığmazsa yalnız ilk yüz), hücre kırpılır: dar payda iki üç kişi olabilir.
class FaceCell extends Control:
	var _faces: Array[Control] = []
	var _more: Label

	func _init(people: Array) -> void:
		clip_contents = true
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for person: Dictionary in people:
			var face: Control = SprintUiShared.face(person, UiTokens.D_AVATAR_ROW_SM, false, false)
			face.size = Vector2.ONE * UiTokens.D_AVATAR_ROW_SM
			add_child(face)
			_faces.append(face)
		_more = SprintUiShared.label("", &"Caption")
		add_child(_more)
		resized.connect(_fit)

	func _fit() -> void:
		var step: float = UiTokens.D_AVATAR_ROW_SM - UiTokens.SPACE_S
		var shown: int = _faces.size()
		var room := func(k: int, rest: int) -> float:
			var w: float = UiTokens.D_AVATAR_ROW_SM + (k - 1) * step
			if rest > 0:
				_more.text = "+%d" % rest
				w += UiTokens.SPACE_XXS + _more.get_combined_minimum_size().x
			return w
		while shown > 1 and room.call(shown, _faces.size() - shown) > size.x:
			shown -= 1
		for i in _faces.size():
			_faces[i].visible = i < shown
			_faces[i].position = Vector2(i * step, 0.0)
		# Tek yüzün yanına "+{n}" de sığmıyorsa yalnız yüz kalır (kalanlar ipucunda).
		_more.visible = shown < _faces.size() and room.call(shown, _faces.size() - shown) <= size.x
		if _more.visible:
			_more.text = "+%d" % (_faces.size() - shown)
			_more.size = _more.get_combined_minimum_size()
			_more.position = Vector2(UiTokens.D_AVATAR_ROW_SM + (shown - 1) * step + UiTokens.SPACE_XXS,
				(UiTokens.D_AVATAR_ROW_SM - _more.size.y) / 2.0)


func setup(model: Dictionary) -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	custom_minimum_size.x = UiTokens.D_W_NEXT
	size_flags_horizontal = Control.SIZE_SHRINK_END
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var col := SprintUiShared.column(UiTokens.SPACE_L)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(col)
	col.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_PREP")), &"Eyebrow"))
	var pms: Array = model.prep.pms
	if pms.is_empty():
		col.add_child(_no_pm())
	for pm: Dictionary in pms:
		col.add_child(_pm_row(pm, pms.size() > 1))
	col.add_child(_box(model.next))


# --- Hazırlık -------------------------------------------------------------------------------

## PM'in satırı: yüzü (yıldız çipiyle), adı ve "{n} kart hazırladı" ya da sonraki sütunda hazırlıkta (ikisi de yoksa soluk "0 kart
## hazırladı"); iki ve daha çok PM'de sıkışık.
func _pm_row(pm: Dictionary, tight: bool) -> PanelContainer:
	var row := PanelContainer.new()
	row.theme_type_variation = &"PrepRowTight" if tight else &"PrepRow"
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(line)
	line.add_child(SprintUiShared.face_slot(pm.person, UiTokens.D_AVATAR_ROW))
	var tip: PackedStringArray = [SprintUiShared.named_stars(pm.person)]
	if not pm.cards.is_empty():
		tip.append(", ".join(pm.cards))
	row.tooltip_text = SprintUiShared.SEP.join(tip)
	var words := SprintUiShared.column(UiTokens.SPACE_XXS)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(words)
	words.add_child(SprintUiShared.prose(String(pm.person.name), &"DataStrong"))
	# Ne hazırlamış ne hazırlıkta olan PM soluk "0 kart hazırladı" yazar.
	var n: int = pm.cards.size()
	var state: String = tr("PRODUCT_PM_PREPARING") if n == 0 and pm.preparing else tr(Fmt.count_key("PRODUCT_PM_CARDS", n)).format({"n": n})
	words.add_child(SprintUiShared.prose(Fmt.cap_first(state), &"CaptionFaint" if n == 0 and not pm.preparing else &"Caption"))
	HRUiShared.set_mouse_ignore(line)
	return row


## Ekipte PM yokken: boş disk ve soluk "PM yok".
func _no_pm() -> PanelContainer:
	var row := PanelContainer.new()
	row.theme_type_variation = &"PrepRow"
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(line)
	var disc := Panel.new()
	disc.theme_type_variation = &"FaceGhost"
	disc.custom_minimum_size = Vector2.ONE * UiTokens.D_AVATAR_ROW
	disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(disc)
	line.add_child(SprintUiShared.label(tr("PRODUCT_NO_PM"), &"DataStrong", UiTokens.D_INK_OFF))
	HRUiShared.set_mouse_ignore(line)
	row.tooltip_text = tr("PRODUCT_NO_PM_TIP")
	return row


# --- Sonraki sprint kutusu ------------------------------------------------------------------

func _box(next: Dictionary) -> PanelContainer:
	var box := PanelContainer.new()
	box.theme_type_variation = &"NextBox"
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	HRUiShared.D_dashed(box, UiTokens.D_LINE_3)
	var col := SprintUiShared.column(UiTokens.SPACE_M)
	box.add_child(col)
	var title := SprintUiShared.box(UiTokens.SPACE_M)
	title.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_SPRINT_TITLE").format({"n": next.sprint})), &"NextTitle"))
	title.add_child(RnDUiShared.spacer())
	title.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_NEXT")), &"Caption"))
	col.add_child(title)
	var load := SprintUiShared.column(UiTokens.SPACE_XS)
	for row: Dictionary in next.load:
		load.add_child(_load_row(row))
	col.add_child(load)
	if not next.carried.is_empty():
		col.add_child(_section("PRODUCT_CARRIED_OVER"))
		_carried(col, next.carried)
	if not next.cards.is_empty():
		col.add_child(_section("PRODUCT_CARDS"))
		for card: Dictionary in next.cards:
			col.add_child(_card(card))
	return box


func _section(key: String) -> Label:
	return SprintUiShared.label(Fmt.upper(tr(key)), &"Eyebrow")


## Bir aşamanın yükü: ikon, çubuk ve "{devreden + planlı}/{ekip}" (aşarsa uyarı renginde).
func _load_row(row: Dictionary) -> HBoxContainer:
	var line := SprintUiShared.box(UiTokens.SPACE_S)
	line.tooltip_text = tr("PRODUCT_NEXT_LOAD_TIP").format({"stage": SprintUiShared.stage_name(row.stage), "carried": roundi(row.carried),
		"planned": roundi(row.planned), "team": roundi(row.team)})
	line.add_child(UiFactory.make_glyph(SprintUiShared.ROLE_ICONS[row.stage], UiTokens.D_ICON_TAG, UiTokens.D_stage(row.stage)))
	var bar := StagePaint.part(&"load", row.stage, {"carried": row.carried, "planned": row.planned, "team": row.team}, Rect2())
	bar.custom_minimum_size.y = UiTokens.D_H_LOAD_BAR
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(bar)
	var load: int = roundi(row.carried + row.planned)
	var team: int = roundi(row.team)
	var figure := SprintUiShared.box(0)
	figure.custom_minimum_size.x = UiTokens.D_W_LOAD_NUM
	figure.alignment = BoxContainer.ALIGNMENT_END
	figure.add_child(SprintUiShared.label(str(load), &"LoadNum", UiTokens.D_warn() if load > team else null))
	figure.add_child(SprintUiShared.label("/%d" % team, &"LoadNum", UiTokens.D_INK_4))
	line.add_child(figure)
	return line


## Devreden payların satırları (en büyük önde); beşten çoksa en büyük dördü ve kalanların toplamı tek "+{n} kart" satırında.
func _carried(col: VBoxContainer, rows: Array) -> void:
	var shown: Array = rows if rows.size() <= CARRIED_ROWS + 1 else rows.slice(0, CARRIED_ROWS)
	for row: Dictionary in shown:
		col.add_child(_carry_row(row))
	if shown.size() < rows.size():
		col.add_child(_more_row(rows.slice(CARRIED_ROWS)))


func _carry_row(row: Dictionary) -> CarryRow:
	var line := CarryRow.new()
	line.theme_type_variation = &"CarriedRow"
	var content := SprintUiShared.box(UiTokens.SPACE_M)
	line.add_child(content)
	content.add_child(_icon(SprintUiShared.ROLE_ICONS[row.stage], UiTokens.D_stage(row.stage)))
	content.add_child(_name(String(row.card), &"CaptionPrimary"))
	content.add_child(_figure(str(roundi(row.effort)), &"CaptionStrong", UiTokens.D_INK_1))
	line.tooltip_text = SprintUiShared.SEP.join([row.card, SprintUiShared.stage_name(row.stage), SprintUiShared.effort_tip(roundi(row.effort))])
	return line


## Beşten çok devredende sığmayanların toplu satırı; ipucu her kalanı "{kart} · {aşama} {efor}" diye sıralar.
func _more_row(rest: Array) -> PanelContainer:
	var n: int = rest.size()
	var effort := 0.0
	for row: Dictionary in rest:
		effort += row.effort
	var line := PanelContainer.new()
	line.theme_type_variation = &"CarriedRest"
	line.tooltip_text = "\n".join(rest.map(func(row: Dictionary) -> String:
		return SprintUiShared.SEP.join([row.card, SprintUiShared.stage_name(row.stage) + " " + str(roundi(row.effort))])))
	var content := SprintUiShared.box(UiTokens.SPACE_M)
	line.add_child(content)
	content.add_child(_icon(SprintUiShared.PLUS, UiTokens.D_INK_3))
	content.add_child(_name(tr(Fmt.count_key("PRODUCT_MORE_CARDS", n)).format({"n": n}), &"CaptionPrimary"))
	content.add_child(_figure(str(roundi(effort)), &"CaptionStrong", UiTokens.D_INK_1))
	return line


## Kart adı: iki satıra iner, yine taşarsa üç nokta.
func _name(text: String, variation: StringName) -> Label:
	var name_label := SprintUiShared.prose(text, variation)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.max_lines_visible = 2
	name_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return name_label


## Satırın başındaki ikon: ad iki satıra inebildiği için üste yaslı, ilk satırın hizasında.
func _icon(path: String, ink: Color) -> MarginContainer:
	var glyph := UiFactory.make_glyph(path, UiTokens.D_ICON_TAG, ink)
	glyph.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return SprintUiShared.pad(glyph, Vector4i(0, UiTokens.D_PAD_CARD_ICON, 0, 0))


## Satırın sonundaki efor: ilk satırın hizasında.
func _figure(text: String, variation: StringName, ink: Variant = null) -> Label:
	var figure := SprintUiShared.label(text, variation, ink)
	figure.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return figure


# --- Kart -----------------------------------------------------------------------------------

## Sonraki sütunun kartı: tür ikonu, ad, efor; altında aşama şeridi, önden çalışanların yüzleri ve hazırlayan PM. Planlamada üstüne
## gelince "↑" ve "×" (sürüm notunda ve sprint sürerken yalnız "×").
func _card(card: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.theme_type_variation = &"NextCard"
	var col := SprintUiShared.column(UiTokens.SPACE_S)
	row.add_child(col)
	var tip: PackedStringArray = [card.name, SprintUiShared.effort_tip(card.effort)]
	if card.ahead:
		tip.append(tr("PRODUCT_STARTS_AHEAD"))
	row.tooltip_text = SprintUiShared.SEP.join(tip)
	var top := SprintUiShared.box(UiTokens.SPACE_M)
	col.add_child(top)
	top.add_child(_icon(SprintUiShared.KIND_ICON % card.kind, UiTokens.D_INK_3))
	top.add_child(_name(String(card.name), &"CaptionStrong"))
	top.add_child(_figure(str(card.effort), &"DataStrong"))
	var strip := SprintUiShared.box(UiTokens.SPACE_XXS)
	for part: Dictionary in card.parts:
		var seg := StagePaint.part(&"seg", part.stage, {"fill": part.done / part.effort}, Rect2())
		seg.custom_minimum_size.y = UiTokens.D_H_NEXT_STRIP
		seg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		seg.size_flags_stretch_ratio = part.effort
		seg.tooltip_text = _part_tip(part)
		strip.add_child(seg)
	col.add_child(strip)
	if card.parts.any(func(part: Dictionary) -> bool: return not part.people.is_empty()):
		col.add_child(_faces(card.parts))
	if card.prep != null:
		col.add_child(_prep(card))
	row.add_child(_keys(row, card))
	return row


## Aşama payının ipucu: "{aşama} · efor {n}", önden yapılan kısım (bittiyse "önden bitti", yoksa yüzdesi) ve önden çalışanların adları.
func _part_tip(part: Dictionary) -> String:
	var tip: PackedStringArray = [SprintUiShared.stage_name(part.stage), SprintUiShared.effort_tip(roundi(part.effort))]
	if part.done >= part.effort - SprintSystem.EPS:
		tip.append(tr("PRODUCT_DONE_AHEAD"))
	elif part.done > SprintSystem.EPS:
		tip.append(Fmt.percent(part.done / part.effort * 100.0, 0))
	if not part.people.is_empty():
		tip.append(", ".join(part.people.map(func(person: Dictionary) -> String: return person.name)))
	return SprintUiShared.SEP.join(tip)


## Önden çalışanların yüzleri kendi aşama payının altında: pay başına bir hücre (`FaceCell`), şeritle aynı oranda.
func _faces(parts: Array) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_XXS)
	row.custom_minimum_size.y = UiTokens.D_AVATAR_ROW_SM
	for part: Dictionary in parts:
		var cell := FaceCell.new(part.people)
		HRUiShared.set_mouse_ignore(cell)
		cell.mouse_filter = Control.MOUSE_FILTER_PASS
		cell.tooltip_text = _part_tip(part)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.size_flags_stretch_ratio = part.effort
		row.add_child(cell)
	return row


## Hazırlayan PM: yüzü ve kum saati "hazırlanıyor" ya da tik "hazır"; ipucu hazırsa kısalttığı efor, değilse hazırlıyor olduğu.
func _prep(card: Dictionary) -> HBoxContainer:
	var prep: Dictionary = card.prep
	var line := SprintUiShared.box(UiTokens.SPACE_M)
	line.custom_minimum_size.y = UiTokens.D_AVATAR_ROW_SM
	line.add_child(SprintUiShared.avatar(prep.pm, UiTokens.D_AVATAR_ROW_SM))
	var ready: bool = prep.done >= 1.0 - SprintSystem.EPS
	line.add_child(UiFactory.make_glyph(SprintUiShared.CHECK if ready else SprintUiShared.HOURGLASS, UiTokens.D_ICON_TAG, UiTokens.D_INK_3))
	line.add_child(SprintUiShared.label(Fmt.cap_first(tr("PRODUCT_READY" if ready else "PRODUCT_PREPARING")), &"Caption"))
	HRUiShared.set_mouse_ignore(line)
	line.mouse_filter = Control.MOUSE_FILTER_PASS
	line.tooltip_text = (SprintUiShared.prepared_tip(prep.pm, card.raw_effort, card.effort) if ready
		else tr("PRODUCT_PREPARING_TIP").format({"name": prep.pm.name}))
	return line


## Kartın tuşları, kartın sağ üstünde, yalnız imleç kartın üstündeyken görünür.
func _keys(row: PanelContainer, card: Dictionary) -> Control:
	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if card.buttons.is_empty():
		return layer
	var acts := SprintUiShared.row_keys(card.buttons, String(card.id), action.emit)
	acts.anchor_left = 1.0
	acts.anchor_right = 1.0
	acts.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	acts.offset_top = UiTokens.SPACE_XS
	layer.add_child(acts)
	row.mouse_entered.connect(func() -> void: acts.visible = true)
	row.mouse_exited.connect(func() -> void:
		acts.visible = row.get_global_rect().has_point(row.get_global_mouse_position()))
	return layer
