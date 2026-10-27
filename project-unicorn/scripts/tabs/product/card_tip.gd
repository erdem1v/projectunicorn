class_name CardTip
extends RefCounted

# Zengin kart ipucu: kartın adının üstüne gelince açılan panel (`_make_custom_tooltip`, ok yok). Başlık (tür ikonu, ad, efor), aşama
# başına efor kutuları (önden biten aşamada tik), aşama başına çalışanlar ve kurucunun görüşmeleri (türü başına bir satır, günleri
# toplanmış), sprint sonuna yetişip yetişmediği ve künye (müşteri, söz, modül, PM, kurucunun kartı). Kural ve sayım cümlesi yoktur,
# hafta yazılmaz. Satırın verisini okur; kişilerin yüzleri panel kurulurken istenir (`ProductModel.stage_face`), bu yüzden panel yalnız
# ipucu açılınca kurulur.


## `team_pm` ekipte PM olup olmadığıdır: künyede "PM yok" yalnız o yokken yazılır.
static func panel(card: Dictionary, team_pm: bool) -> Control:
	var tip := SprintUiShared.tip_column()
	tip.add_child(_head(card))
	var stages: Array = card.stages.filter(func(s: Dictionary) -> bool: return not s.fix)
	for block: Control in [_needs(stages), _who(stages), _end(card), _notes(card, team_pm)]:
		if block != null:
			tip.add_child(HSeparator.new())
			tip.add_child(block)
	return tip


static func _head(card: Dictionary) -> HBoxContainer:
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	head.add_child(UiFactory.make_glyph(SprintUiShared.KIND_ICON % card.kind, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	head.add_child(SprintUiShared.prose(String(card.name), &"TipTitle"))
	head.add_child(SprintUiShared.label(RnDUiShared.t("PRODUCT_EFFORT"), &"MetaMuted"))
	head.add_child(SprintUiShared.label(str(card.effort), &"ValueTextStrong"))
	return head


## Aşama başına bir kutu: aşamanın bandında ikon ve efor; önden biten aşamada efor yerine tik. Hiç aşama yoksa null.
static func _needs(stages: Array) -> HFlowContainer:
	var shown: Array = stages.filter(func(s: Dictionary) -> bool: return SprintUiShared.stage_done(s) or s.need > SprintSystem.EPS)
	if shown.is_empty():
		return null
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
	row.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	for s: Dictionary in shown:
		var done: bool = SprintUiShared.stage_done(s)
		row.add_child(_box(s.stage, "" if done else str(roundi(s.need)), done))
	return row


static func _box(stage: String, text: String, done: bool) -> StagePaint:
	var rect := Rect2(Vector2.ZERO, Vector2(UiTokens.D_NEED_BOX))
	var state := "done" if done else "plan"
	var box: StagePaint = StagePaint.part(&"bar", stage, {"state": state, "late": false, "fill": 0.0}, rect)
	box.custom_minimum_size = rect.size
	box.add_child(StagePaint.part(&"label", stage, {"state": state, "late": false, "main": text, "sub": "",
		"left": UiTokens.D_STAGE_BAR_PAD.x, "room": 0.0, "icon": SprintUiShared.stage_icon(stage)}, rect))
	return box


## Kim: aşama başına satır, o aşamada çalışanların yüzü ve "{ad} {yıldız}"; eksenden önce biten aşamada ne zaman bittiği; kurucunun
## görüşmeleri, türü başına bir satır, görüşmeli ilk aşamanın altında. Kimse yoksa null.
static func _who(stages: Array) -> VBoxContainer:
	var seated: Array = stages.filter(func(s: Dictionary) -> bool: return SprintUiShared.stage_done(s) or not s.people.is_empty())
	if seated.is_empty():
		return null
	var col := SprintUiShared.column(UiTokens.SPACE_M)
	var meets: PackedStringArray = SprintUiShared.meet_lines_of(stages, true)
	for s: Dictionary in seated:
		var done: bool = SprintUiShared.stage_done(s)
		var line := SprintUiShared.box(UiTokens.SPACE_M)
		var icon := UiFactory.make_glyph(SprintUiShared.stage_icon(s.stage), UiTokens.D_ICON_ROW, UiTokens.D_stage(s.stage))
		icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		line.add_child(SprintUiShared.pad(icon, Vector4i(0, UiTokens.D_PAD_CARD_ICON, 0, 0)))
		var rows := SprintUiShared.column(UiTokens.SPACE_XS)
		rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(rows)
		if done:
			rows.add_child(SprintUiShared.prose(SprintUiShared.done_text(s), &"Caption"))
		else:
			rows.add_child(_people(s))
			if not s.meet.is_empty():
				for text in meets:
					rows.add_child(SprintUiShared.prose(text, &"Caption"))
				meets = PackedStringArray()
		col.add_child(line)
	return col


static func _people(stage: Dictionary) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	for id: String in stage.people:
		var person: Dictionary = ProductModel.stage_face(id, stage.stage)
		var who := SprintUiShared.box(UiTokens.SPACE_S)
		who.add_child(SprintUiShared.face(person, UiTokens.D_AVATAR_ROW_SM, false, false))
		who.add_child(SprintUiShared.label(SprintUiShared.named_stars(person), &"CaptionStrong"))
		flow.add_child(who)
	return flow


## Sprint sonuna yetişir ya da yetişmez (kurucunun yetişmeyen kartında tehlike renginde).
static func _end(card: Dictionary) -> Label:
	return SprintUiShared.prose(RnDUiShared.t("PRODUCT_ON_TIME" if card.finishes else "PRODUCT_LATE_TIP"), &"CaptionStrong",
		UiTokens.D_neg_ink() if card.late else null)


## Künye: müşteri ve yıllık değeri, söz tarihi (varsa), modül ve hazırlayan PM (ekipte PM yoksa "PM yok"; PM var ama kartı
## hazırlamadıysa yalnız modül), kurucunun kartıysa onu.
static func _notes(card: Dictionary, team_pm: bool) -> VBoxContainer:
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	var slot: Dictionary = card.slot
	if slot.get("kind", "") == "due":
		var deal: PackedStringArray = [slot.customer]
		if slot.value > 0:
			deal.append(RnDUiShared.t("PRODUCT_PER_YEAR").format({"amount": Fmt.money_exact(slot.value)}))
		col.add_child(_note(SprintUiShared.BUILDING, SprintUiShared.SEP.join(deal)))
		if slot.promise:
			col.add_child(_note(SprintUiShared.HOURGLASS, RnDUiShared.t("PRODUCT_TIP_PROMISE").format({"when": slot.text})))
	var about: PackedStringArray = [card.module_name]
	if card.pm != null:
		about.append(RnDUiShared.t("PRODUCT_PREPARED_BY").format({"name": card.pm.name}))
	elif not team_pm:
		about.append(RnDUiShared.t("PRODUCT_NO_PM"))
	if card.founder:
		about.append(RnDUiShared.t("PRODUCT_FOUNDER_CARD"))
	col.add_child(SprintUiShared.prose(SprintUiShared.SEP.join(about), &"CaptionPrimary"))
	return col


static func _note(glyph: String, text: String) -> HBoxContainer:
	var line := SprintUiShared.box(UiTokens.SPACE_S)
	line.add_child(UiFactory.make_glyph(glyph, UiTokens.D_ICON_TAG, UiTokens.D_INK_3))
	line.add_child(SprintUiShared.prose(text, &"CaptionPrimary"))
	return line
