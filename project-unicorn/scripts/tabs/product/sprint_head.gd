class_name SprintHead
extends HBoxContainer

# Sprintin başlığı: numarası, çeyreğin çentikleri, v1.0'dan önce MVP rozeti, sprint sürerken hafta çubukları, bir aşamanın
# yüzleri kümeye dönünce ekip rozeti ve çeyrek hedefinin seçicisi. Yalnız modeli çizer; hedef seçimi sekmeye `pick_goal` olarak çıkar.
# Rozetler akar: yer daralınca alt satıra iner, hiçbir şey kesilmez; seçici sağda durur.

signal action(kind: String, args: Dictionary)

const CHEVRON := "res://assets/icons/util/chevron_down.svg"
## Ekip rozetinde üst üste binen yüz sayısı.
const CREW_FACES := 3


func setup(model: Dictionary) -> void:
	UiFactory.clear(self)
	var c: Dictionary = model.center
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	flow.add_theme_constant_override("v_separation", 0)
	add_child(flow)
	flow.add_child(_item([SprintUiShared.label(Fmt.upper(tr("PRODUCT_SPRINT_TITLE").format({"n": c.sprint})), &"SprintTitle")]))
	flow.add_child(_quarter(model.quarter))
	if c.mvp != null:
		flow.add_child(_mvp(c.mvp))
	if c.mode == "active":
		flow.add_child(_week(c))
	if c.crew != null:
		flow.add_child(_crew(c))
	add_child(_goal(model.quarter.goal, model.areas))


## Başlık öğesi: `D_H_SPRINT_HEAD` yüksekliğinde bir satır; `divided` ise solunda ince bir çizgi (rozetin ayracı) durur. Üstüne
## gelince `tip`.
func _item(parts: Array, divided := false, tip := "") -> HBoxContainer:
	var item := SprintUiShared.box(UiTokens.SPACE_M)
	item.custom_minimum_size.y = UiTokens.D_H_SPRINT_HEAD
	if divided:
		var rule := VSeparator.new()
		rule.custom_minimum_size.y = UiTokens.D_H_TAG
		rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		item.add_child(rule)
	for part: Control in parts:
		item.add_child(part)
	HRUiShared.set_mouse_ignore(item)
	if tip != "":
		item.mouse_filter = Control.MOUSE_FILTER_PASS
		item.tooltip_text = tip
	return item


## "{q}. ÇEYREK" ve ürün çeyreğinin sprint sayısı kadar çentik: geçmiş dolu, bugünkü vurgulu.
func _quarter(q: Dictionary) -> HBoxContainer:
	var notches := SprintUiShared.box(UiTokens.SPACE_XS)
	for i in range(1, int(q.total) + 1):
		var notch := Panel.new()
		notch.theme_type_variation = &"QuarterNotchNow" if i == q.pos else (&"QuarterNotchPast" if i < q.pos else &"QuarterNotch")
		notch.custom_minimum_size = Vector2.ONE * UiTokens.D_NOTCH_QUARTER
		notch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		notches.add_child(notch)
	var left: int = int(q.total) - int(q.pos)
	var tip: String = tr(Fmt.count_key("PRODUCT_QUARTER_TIP", left)).format({"year": q.year, "q": q.q, "pos": q.pos, "left": left})
	return _item([SprintUiShared.label(Fmt.upper(tr("PRODUCT_QUARTER_ORD").format({"q": q.q})), &"HeadMeta"), notches], true, tip)


## v1.0'dan önce: sürümün adı, biten kart sayısı ve motorun tahmini; ipucu sürüm koşulu.
func _mvp(line: Dictionary) -> HBoxContainer:
	var parts: Array = [SprintUiShared.label(String(line.version), &"MvpVersion"),
		SprintUiShared.label(tr("PRODUCT_MVP_BADGE_CARDS").format(line), &"HeadMeta")]
	if line.sprint >= 0:
		parts.append(SprintUiShared.label(tr("PRODUCT_MVP_BADGE_ETA").format({"n": line.sprint}), &"HeadMeta"))
	return _item(parts, true, tr("PRODUCT_MVP_RULE" if line.sprint >= 0 else "PRODUCT_MVP_RULE_NO_ETA").format(line))


## Koşan sprintin haftaları: geçen kısmı dolu iki çubuk ve "{w}. hafta".
func _week(c: Dictionary) -> HBoxContainer:
	var bars := SprintUiShared.box(UiTokens.SPACE_XS)
	for i in int(c.weeks):
		var bar := ProgressBar.new()
		bar.theme_type_variation = &"WeekBar"
		bar.show_percentage = false
		bar.max_value = 1.0
		bar.step = 0.001
		bar.value = clampf(c.now_at - i, 0.0, 1.0)
		bar.custom_minimum_size = Vector2(UiTokens.D_WEEK_BAR)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bars.add_child(bar)
	return _item([bars, SprintUiShared.label(tr("PRODUCT_WEEK_ORD").format({"w": c.week}), &"HeadMeta")], true)


## Bir aşamanın yüzleri kümeye dönünce: üç yüz üst üste ve ekibin büyüklüğü; ipucu ekibin dökümü.
func _crew(c: Dictionary) -> HBoxContainer:
	var faces := SprintUiShared.box(-UiTokens.D_CREW_OVERLAP)
	for row: Dictionary in c.capacity:
		for seat in [row.people, row.away]:
			if faces.get_child_count() < CREW_FACES and not seat.is_empty():
				var face := SprintUiShared.avatar(seat[0].person, UiTokens.D_AVATAR_ROW_SM)
				face.mouse_filter = Control.MOUSE_FILTER_IGNORE
				faces.add_child(face)
	return _item([faces, SprintUiShared.label(str(c.crew.n), &"CrewTotal")], true, tr("PRODUCT_CREW_TIP").format(c.crew))


## Çeyrek hedefinin seçicisi: "Bu çeyrek: {alan}", "Bu çeyrek: Hatalar" ya da "Bu çeyrek: hedef yok"; PM'siz ve v1.0'dan önce de
## açıktır.
func _goal(goal: Dictionary, areas: Array) -> Button:
	var pick := Button.new()
	pick.theme_type_variation = &"GoalPick" if goal.area_id == "" else &"GoalPickSet"
	pick.text = tr("PRODUCT_QUARTER_NONE") if goal.area_id == "" else tr("PRODUCT_QUARTER_GOAL").format({"goal": goal.area_name})
	pick.icon = load(CHEVRON)
	pick.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pick.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	pick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pick.tooltip_text = tr("PRODUCT_GOAL_CHANGE_TIP")
	pick.pressed.connect(SprintUiShared.open_goal_menu.bind(pick, areas, goal.area_id,
		func(id: String) -> void: action.emit("pick_goal", {"area_id": id})))
	return pick
