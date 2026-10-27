class_name CapacityView
extends PanelContainer

# Kapasite bloğu: başlığı (sağda liderin önerisi) ve üç aşamanın satırı. Satırda aşamanın adı, oluğu (ekibin gücü) ve içindeki
# dolgu (sprintin işi; koşarken önü koyu, sığmayan pay taralı), "Efor {iş} / {ekip}", sığma tiki ya da taşma rozeti ve aşamada
# çalışanların yüzleri (kalabalık satırda yıldız kümeleri, seçilemeyenler soluk). Yalnız modeli çizer; öneriyi uygulamak sekmeye
# `apply_lead` olarak çıkar. Üstüne gelinen adayın hayaleti sayfa kurulmadan `set_ghost` ile gelir.

signal action(kind: String, args: Dictionary)

const STAGE_KEYS := {"design": "PRODUCT_PHASE_DESIGN", "dev": "PRODUCT_PHASE_DEV", "test": "PRODUCT_PHASE_TEST"}
const STAYS_KEYS := {"design": "PRODUCT_STAYS_DESIGN", "dev": "PRODUCT_STAYS_DEV", "test": "PRODUCT_STAYS_TEST"}
const AWAY_KEYS := {"training": "PRODUCT_AWAY_TRAINING", "leave": "PRODUCT_AWAY_LEAVE", "research": "PRODUCT_AWAY_RESEARCH",
	"meetings": "PRODUCT_AWAY_MEETINGS"}


## Aşamanın etiketi ve rozeti: üstüne gelince `build` verilmişse onun kurduğu zengin ipucu, yoksa düz metin.
class TipBox extends HBoxContainer:
	var build: Callable

	func _make_custom_tooltip(_for_text: String) -> Object:
		return build.call() if build.is_valid() else null


var _rows: Array = []
var _grooves: Array = []


func _init() -> void:
	theme_type_variation = &"CapBlock"


func setup(model: Dictionary) -> void:
	UiFactory.clear(self)
	var c: Dictionary = model.center
	_rows = c.capacity
	_grooves.clear()
	var col := SprintUiShared.column(0)
	add_child(col)
	col.add_child(_head(c.suggest))
	var list := SprintUiShared.column(0)
	var rows := MarginContainer.new()
	rows.add_child(list)
	for row: Dictionary in _rows:
		list.add_child(_row(row, c.mode == "active"))
	if _rows[0].shared:
		var mid: float = UiTokens.SPACE_XS + UiTokens.D_H_CAP_LINE / 2.0
		rows.add_child(StagePaint.bracket({"x": UiTokens.SPACE_XS + UiTokens.D_W_CAP_LABEL + UiTokens.SPACE_L - UiTokens.BORDER_ACCENT,
			"top": mid, "bottom": mid + 2.0 * UiTokens.D_H_CAP_ROW}))
	col.add_child(rows)
	set_ghost(ProductModel.ghost_effort(model.ui.hover_card) if model.ui.hover_card != "" else {})


## Üstüne gelinen adayın hayaleti {aşama: efor} (boşsa kalkar): oluklar tek ölçeği paylaşır, hayalet sığmazsa ölçek büyür.
func set_ghost(efforts: Dictionary) -> void:
	var span := 0.0
	for row: Dictionary in _rows:
		span = maxf(span, maxf(row.work + efforts.get(row.stage, 0.0), row.team))
	span = maxf(span * UiTokens.D_CAP_HEADROOM, 1.0)
	for i in _grooves.size():
		_grooves[i].spec.merge({"scale": span, "ghost": efforts.get(_rows[i].stage, 0.0)}, true)
		_grooves[i].queue_redraw()


## "KAPASİTE" ve planlamada liderin önerisi: "{n} efor daha sığar" (öneri yalnız sütuna ekliyorsa sayı yok) ve "Öneriyi uygula";
## ipucu önerinin kartları.
func _head(suggest: Variant) -> HBoxContainer:
	var head := SprintUiShared.box(UiTokens.SPACE_L)
	head.custom_minimum_size.y = UiTokens.D_H_CAP_HEAD
	var title := SprintUiShared.label(Fmt.upper(tr("PRODUCT_CAPACITY")), &"Eyebrow")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	if suggest == null:
		return head
	var tip: String = "\n".join(suggest.cards.map(func(card: Dictionary) -> String:
		return String(card.name) + SprintUiShared.SEP + "%d/%d" % [roundi(card.done), roundi(card.effort)]))
	if roundi(suggest.amount) > 0:
		var room := SprintUiShared.label(tr("PRODUCT_SUGGEST").format({"n": roundi(suggest.amount)}), &"MetaMuted")
		room.mouse_filter = Control.MOUSE_FILTER_PASS
		room.tooltip_text = tip
		head.add_child(room)
	var apply := SprintUiShared.button(tr("PRODUCT_SUGGEST_APPLY"), &"SecondaryButtonSmall", action.emit.bind("apply_lead", {}))
	apply.tooltip_text = tip
	head.add_child(apply)
	return head


## Bir aşamanın satırı: aşama etiketi, oluk, sayı ve rozet üstte; altta aşamanın yüzleri. En çok taşan aşama süreklilikteyse zemini sıcak.
func _row(row: Dictionary, running: bool) -> PanelContainer:
	var empty: bool = row.work < SprintSystem.EPS and row.team < SprintSystem.EPS
	var spills: bool = roundi(row.out) > 0
	var tip: String = "" if empty else _tip(row, running)
	var rich: Callable = _over_tip.bind(row) if spills else Callable()
	var cell := PanelContainer.new()
	cell.theme_type_variation = UiTokens.D_variation(&"CapRowHot") if row.hot else &"CapRow"
	cell.custom_minimum_size.y = UiTokens.D_H_CAP_ROW
	var body := SprintUiShared.column(UiTokens.SPACE_XXS)
	cell.add_child(SprintUiShared.pad(body, Vector4i(UiTokens.SPACE_XS, UiTokens.SPACE_XS, 0, 0)))
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	line.custom_minimum_size.y = UiTokens.D_H_CAP_LINE
	body.add_child(line)
	var name_cell := _tipped(tip, rich)
	name_cell.custom_minimum_size.x = UiTokens.D_W_CAP_LABEL
	name_cell.add_child(UiFactory.make_glyph(SprintUiShared.ROLE_ICONS[row.stage], UiTokens.D_ICON_ROW, UiTokens.D_stage(row.stage)))
	name_cell.add_child(SprintUiShared.label(tr(STAGE_KEYS[row.stage]), &"CapStage", UiTokens.D_INK_OFF if empty else null))
	line.add_child(name_cell)
	var groove := StagePaint.groove(row.stage, {"work": row.work, "groove": row.team, "done": row.done,
		"outer": maxf(0.0, row.out - row.out_inside), "inner": row.out_inside, "ghost": 0.0, "scale": 1.0, "shared": row.shared,
		"empty": empty})
	groove.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_grooves.append(groove)
	line.add_child(groove)
	var figure := _figure(row, tip)
	figure.visible = not empty
	line.add_child(_cell(figure, UiTokens.D_W_CAP_NUMBER, true))
	line.add_child(_cell(_badge(row, spills, empty, tip, rich), UiTokens.D_W_CAP_BADGE, false))
	body.add_child(SprintUiShared.pad(_people(row), Vector4i(UiTokens.D_W_CAP_LABEL + UiTokens.SPACE_L, 0, 0, 0)))
	return cell


## Etiket ve rozetin kutusu: üstüne gelince `tip`, `rich` verilmişse zengin panel.
func _tipped(tip: String, rich: Callable) -> TipBox:
	var box := TipBox.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_M)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.tooltip_text = tip
	box.build = rich
	return box


## Satırın sabit genişlikli hücresi: içerik hücrenin dikeyinde ortalanır ve boyunu hücreye dayatmaz (büyük sayı satırı uzatmaz).
func _cell(content: Control, width: int, from_right: bool) -> Control:
	var cell := Control.new()
	cell.custom_minimum_size = Vector2(width, UiTokens.D_H_CAP_LINE)
	cell.add_child(content)
	content.anchor_left = 1.0 if from_right else 0.0
	content.anchor_right = content.anchor_left
	content.anchor_top = 0.5
	content.anchor_bottom = 0.5
	content.grow_horizontal = Control.GROW_DIRECTION_BEGIN if from_right else Control.GROW_DIRECTION_END
	content.grow_vertical = Control.GROW_DIRECTION_BOTH
	return cell


## "Efor {iş} / {ekip}": taşan aşamada iş sayısı uyarı renginde.
func _figure(row: Dictionary, tip: String) -> HBoxContainer:
	var figure := SprintUiShared.box(UiTokens.SPACE_XS)
	figure.mouse_filter = Control.MOUSE_FILTER_PASS
	figure.tooltip_text = tip
	figure.add_child(SprintUiShared.label(tr("PRODUCT_EFFORT"), &"CapUnit"))
	figure.add_child(SprintUiShared.label(str(roundi(row.work)), &"CapFigure", UiTokens.D_warn() if roundi(row.out) > 0 else null))
	figure.add_child(SprintUiShared.label("/ %d" % roundi(row.team), &"CapTeam"))
	return figure


## Sığıyorsa tik, taşıyorsa "+{n}"; aynı aşama art arda iki ve daha çok sprint taşıyorsa yanında "{n}." halkası (kendi ipucuyla).
func _badge(row: Dictionary, spills: bool, empty: bool, tip: String, rich: Callable) -> TipBox:
	var badge := _tipped(tip, rich)
	if spills:
		var over := PanelContainer.new()
		over.theme_type_variation = UiTokens.D_variation(&"CapBadgeOver")
		over.mouse_filter = Control.MOUSE_FILTER_IGNORE
		over.add_child(SprintUiShared.label("+%d" % roundi(row.out), UiTokens.D_variation(&"CapBadgeOverInk")))
		badge.add_child(over)
	elif not empty:
		badge.add_child(UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
	if row.streak >= 2:
		badge.add_child(_ring(row.streak))
	return badge


## Süreklilik halkası "{n}.": aynı aşama art arda bu kadar sprint taşıyor.
func _ring(streak: int) -> PanelContainer:
	var ring := PanelContainer.new()
	ring.theme_type_variation = UiTokens.D_variation(&"CapStreak")
	ring.add_child(SprintUiShared.label("%d." % streak, UiTokens.D_variation(&"CapStreakInk")))
	ring.tooltip_text = tr("PRODUCT_NECK_STREAK").format({"n": streak})
	return ring


## Aşamanın yüzleri: yanında oturanlar tek tek (üstünde yıldız çipi, altında doluluk çizgisi), seçilemeyenler soluk ve nedeniyle;
## satır kalabalıksa yıldız kümeleri.
func _people(row: Dictionary) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_XS)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	var crowd: Variant = row.cluster
	if crowd == null:
		for p: Dictionary in row.people:
			flow.add_child(_person(p, row.stage))
		for gone: Dictionary in row.away:
			flow.add_child(_away(gone))
		return flow
	for person: Dictionary in crowd.founders:
		flow.add_child(SprintUiShared.face(person, UiTokens.D_AVATAR_ROW_SM))
	for group: Dictionary in crowd.stars:
		flow.add_child(_cluster(group.person, SprintUiShared.stars_text(group.stars), group.n, false))
	for group: Dictionary in crowd.away:
		flow.add_child(_cluster(group.person, tr(AWAY_KEYS[group.reason]), group.n, true))
	return flow


## Yanındaki biri: yüzü, yıldız çipi ve altında aşamanın renginde doluluk çizgisi (kurucuda görüşmelerin payı taralı); ipucu adı,
## yıldızı, sprintteki gücü ve doluluğu.
func _person(p: Dictionary, stage: String) -> VBoxContainer:
	var slot := SprintUiShared.column(UiTokens.SPACE_XXS)
	slot.custom_minimum_size.x = UiTokens.D_W_FACE_SLOT
	var face := SprintUiShared.face(p.person, UiTokens.D_AVATAR_ROW_SM)
	face.tooltip_text = tr("PRODUCT_PERSON_TIP").format({"name": p.person.name, "stars": SprintUiShared.stars_text(p.person.stars),
		"effort": roundi(p.effort), "busy": Fmt.percent(p.busy * 100.0, 0)})
	slot.add_child(face)
	var bar := StagePaint.busy(stage, p.busy, p.cut)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	slot.add_child(bar)
	return slot


## Sprinte seçilemeyen kişi: soluk gri yüz ve yanında nedeni; ipucu adı, yıldızı ve nedeni.
func _away(gone: Dictionary) -> Control:
	var reason: String = tr(AWAY_KEYS[gone.reason])
	var item := SprintUiShared.box(UiTokens.SPACE_M)
	item.add_child(SprintUiShared.face(gone.person, UiTokens.D_AVATAR_ROW_SM, true))
	item.add_child(SprintUiShared.label(reason, &"AwayLabel"))
	return _hover(item, String(gone.person.name) + " " + SprintUiShared.stars_text(gone.person.stars) + SprintUiShared.SEP + reason)


## Küme: bir temsilci yüz, ağırlığı (yıldız ya da neden) ve sayısı; ipucu "{ağırlık} · {n} kişi".
func _cluster(person: Dictionary, weight: String, n: int, away: bool) -> Control:
	var item := SprintUiShared.box(UiTokens.SPACE_XS)
	var face := SprintUiShared.avatar(person, UiTokens.D_AVATAR_ROW_SM, away)
	if away:
		face.modulate.a = UiTokens.D_AWAY_ALPHA
	item.add_child(face)
	item.add_child(SprintUiShared.label(weight, &"AwayLabel" if away else &"ClusterStars"))
	item.add_child(SprintUiShared.label(tr("PRODUCT_TIMES").format({"n": n}), &"SmallMuted"))
	return _hover(item, tr(Fmt.count_key("PRODUCT_CLUSTER_TIP", n)).format({"stars": weight, "n": n}))


## Kutunun ipucunu bağlar (çocuklar fareyi geçirir) ve yanına yer bırakır.
func _hover(item: Control, tip: String) -> MarginContainer:
	HRUiShared.set_mouse_ignore(item)
	item.mouse_filter = Control.MOUSE_FILTER_PASS
	item.tooltip_text = tip
	return SprintUiShared.pad(item, Vector4i(0, 0, UiTokens.SPACE_XL, 0))


## Aşamanın ipucu: ad, iş ve ekip; koşarken yapılan; sığıyor ya da sonraki sprinte kalan; bekleme yüzünden kalan kısım.
func _tip(row: Dictionary, running: bool) -> String:
	var parts := PackedStringArray([tr("PRODUCT_CAP_TIP").format({"stage": tr(STAGE_KEYS[row.stage]), "work": roundi(row.work),
		"team": roundi(row.team)})])
	if running:
		parts.append(tr("PRODUCT_CAP_TIP_DONE").format({"n": roundi(row.done)}))
	parts.append(tr("PRODUCT_CAP_SPILL").format({"n": roundi(row.out)}) if roundi(row.out) > 0 else tr("PRODUCT_CAP_FITS"))
	if roundi(row.out_inside) > 0:
		parts.append(tr("PRODUCT_CAP_WAITING").format({"n": roundi(row.out_inside)}))
	return SprintUiShared.SEP.join(parts)


## Taşan aşamanın paneli: başlık ("{aşama}" ve "Efor {iş} / {ekip}"), "+{n} sonraki sprinte kalır", "{AŞAMA}DA KALIR" altında kart
## satırları ve süreklilik.
func _over_tip(row: Dictionary) -> Control:
	var tip := SprintUiShared.column(UiTokens.SPACE_L)
	tip.theme = load(UiTokens.MENAJER_THEME)
	tip.custom_minimum_size.x = UiTokens.D_W_CAP_TIP
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	head.add_child(UiFactory.make_glyph(SprintUiShared.ROLE_ICONS[row.stage], UiTokens.D_ICON_ROW, UiTokens.D_stage(row.stage)))
	var stage := SprintUiShared.label(tr(STAGE_KEYS[row.stage]), &"TipTitle")
	stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(stage)
	head.add_child(SprintUiShared.label("%s %d / %d" % [tr("PRODUCT_EFFORT"), roundi(row.work), roundi(row.team)], &"MetaMuted"))
	tip.add_child(head)
	var spill := SprintUiShared.box(UiTokens.SPACE_M)
	var over := PanelContainer.new()
	over.theme_type_variation = UiTokens.D_variation(&"CapBadgeOver")
	over.add_child(SprintUiShared.label("+%d" % roundi(row.out), UiTokens.D_variation(&"CapBadgeOverInk")))
	spill.add_child(over)
	spill.add_child(SprintUiShared.label(tr("PRODUCT_STAGE_OUT"), &"CaptionPrimary"))
	tip.add_child(spill)
	var stays := SprintUiShared.column(UiTokens.SPACE_XS)
	stays.add_child(SprintUiShared.label(Fmt.upper(tr(STAYS_KEYS[row.stage])), &"KeySmall"))
	for stay: Dictionary in row.stays:
		var line := SprintUiShared.box(UiTokens.SPACE_M)
		line.add_child(SprintUiShared.prose(String(stay.card), &"CaptionPrimary"))
		line.add_child(SprintUiShared.label(str(roundi(stay.effort)), &"CaptionStrong"))
		stays.add_child(line)
	tip.add_child(stays)
	if row.streak >= 2:
		var streak := SprintUiShared.box(UiTokens.SPACE_M)
		streak.add_child(_ring(row.streak))
		streak.add_child(SprintUiShared.prose(tr("PRODUCT_NECK_STREAK").format({"n": row.streak}), &"CaptionPrimary"))
		tip.add_child(streak)
	return tip
