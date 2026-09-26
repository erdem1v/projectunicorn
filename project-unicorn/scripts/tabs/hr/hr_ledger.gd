class_name HRLedger
extends RefCounted

# EKİP → KADRO defteri. Tam genişlikte tek bir tablo: etiketli mono sütun başlıkları,
# altlarında çıplak rakamlar — hiçbir sayı oyuncuya "bu ne?" dedirtmeden durmaz.
#
# Rol açıklaması satırda değil hover tooltip'te: satır tek satır yüksekliğinde kalır.
#
# Geniş sütunlar 1920 için çizildi; %125 ölçekte mantıksal viewport 1536'ya iner ve
# sağdaki sütunlar ekrandan taşardı. Yoğun kademede sütunlar daralır, hiçbiri düşmez.
const W_ROLES_WIDE := 370
const W_TASK_WIDE := 260
const W_EXPERIENCE_WIDE := 140
const W_STATE_WIDE := 160
const W_SALARY_WIDE := 150
const W_MORALE_WIDE := 160

const W_ROLES_DENSE := 300
const W_TASK_DENSE := 232
const W_EXPERIENCE_DENSE := 104
const W_STATE_DENSE := 140
const W_SALARY_DENSE := 118
const W_MORALE_DENSE := 124
const DENSE_BELOW := 1600   # mantıksal genişlik eşiği (top_bar ile aynı sayı)

const W_TRAIT := 90
const MUTED := Color(1, 1, 1, 0.45)

## Başlık ile satırların AYNI kademeyi okuması şart; o yüzden statik ve defter kurulmadan
## önce ölçülür.
static var _dense: bool = false


## Ev sahibi (hr_tab) defteri kurmadan ÖNCE çağırır.
static func measure(viewport_width: float) -> void:
	_dense = viewport_width > 0.0 and viewport_width < float(DENSE_BELOW)


static func w_roles() -> int:      return W_ROLES_DENSE if _dense else W_ROLES_WIDE
static func w_task() -> int:       return W_TASK_DENSE if _dense else W_TASK_WIDE
static func w_experience() -> int: return W_EXPERIENCE_DENSE if _dense else W_EXPERIENCE_WIDE
static func w_state() -> int:      return W_STATE_DENSE if _dense else W_STATE_WIDE
static func w_salary() -> int:     return W_SALARY_DENSE if _dense else W_SALARY_WIDE
static func w_morale() -> int:     return W_MORALE_DENSE if _dense else W_MORALE_WIDE

## Satırın aksiyonları. ACTION_MENU satır tıklamasıdır: kişi aksiyonlarını taşıyan popover'ı açar.
const ACTION_MENU := "menu"
const ACTION_RAISE := "raise"
const ACTION_FIRE := "fire"
const ACTION_TRAIN := "train"
const ACTION_PROMOTE := "promote"   # §13.3 dördüncü satır


## Sütun başlığı satırı: tablonun başlığı, her grupta tekrar etmez.
static func column_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size = Vector2(0, 26)
	row.add_child(_head(tr_key("HR_COL_EMPLOYEE"), 0, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_head(tr_key("HR_COL_ROLES_LEADERSHIP"), w_roles()))
	row.add_child(_head(tr_key("HR_COL_TASK"), w_task()))
	row.add_child(_head(tr_key("HR_COL_EXPERIENCE"), w_experience()))
	row.add_child(_head(tr_key("HR_COL_STATE"), w_state()))
	row.add_child(_head(tr_key("HR_COL_TRAIT"), W_TRAIT))
	row.add_child(_head(tr_key("HR_COL_SALARY"), w_salary()))
	row.add_child(_head(tr_key("HR_COL_MORALE"), w_morale()))
	var wrap := PanelContainer.new()
	wrap.theme_type_variation = &"HeaderBand"
	wrap.add_child(row)
	return wrap


## Bir çalışan satırı. `refs` moral yerinde-boyama referanslarını doldurur (hr_tab._morale_refs).
static func row(emp: Character, on_action: Callable, refs: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRow"
	# Hover = kenar. İki varyasyonun dolgusu ve margin'i aynı, yoksa satır hover'da zıplardı.
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"LedgerRowHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"LedgerRow")
	card.gui_input.connect(_on_row_input.bind(emp.id, on_action, card))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.tooltip_text = HRConstants.role_phase_hint(emp.role)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)

	var muted: bool = emp.status != HRConstants.STATUS_ACTIVE

	# ÇALIŞAN: baş harf rozeti + ad + rol. Yer rozetleri DURUM sütununda.
	var who_cell := HBoxContainer.new()
	who_cell.add_theme_constant_override("separation", UiTokens.SPACE_L)
	who_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who_cell.add_child(UiFactory.make_avatar(UiFactory.initials_of(emp.character_name), 32))
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 2)
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	who.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
	who.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(emp.role)), &"MicroLabel"))
	who_cell.add_child(who)
	row.add_child(who_cell)

	row.add_child(HRUiShared.role_area_cell(emp, w_roles(), muted))
	row.add_child(_task_cell(emp, muted))
	row.add_child(_experience_cell(emp))
	row.add_child(HRUiShared.status_cell(emp, w_state()))
	row.add_child(HRUiShared.trait_cell(emp.traits, W_TRAIT))
	row.add_child(_num(HRUiShared.money(emp.monthly_salary), w_salary(), muted))
	var morale_cell := HRUiShared.morale_row(emp.morale, refs)
	morale_cell.custom_minimum_size = Vector2(w_morale(), 0)
	row.add_child(morale_cell)

	_pass_clicks_through(row)
	return card


## Satırın içi tıklamayı yutmasın: ProgressBar STOP ile doğar ve satırın ortasındaki
## barlara tıklamak gui_input'a hiç ulaşmazdı. Butonlar kendi tıklamasının sahibi;
## tooltip taşıyan düğümler de muaf, yoksa hover'ları ölürdü.
static func _pass_clicks_through(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			continue
		if child is Control and (child as Control).tooltip_text == "":
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pass_clicks_through(child)


## Boş grup satırı: kesikli kenar + "Henüz kimse yok" + satır içi hayalet düğme.
static func empty_row(on_search: Callable) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"EmptyRow"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var lbl := UiFactory.make_label(tr_key("HR_EMPTY_ROW"), &"EmptyRowLabel")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lbl)
	row.add_child(HRUiShared.action_button(tr_key("HR_SEARCH_START_INLINE"), on_search))
	card.add_child(row)
	return card


# --- hücreler ---------------------------------------------------------------

static func _head(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := UiFactory.make_label(text, &"ColumnHeader")
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if width > 0:
		l.custom_minimum_size = Vector2(width, 0)
	else:
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func _num(text: String, width: int, muted: bool) -> Label:
	var l := UiFactory.make_label(text, &"MetricValueInk")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(width, 0)
	if muted:
		l.modulate = MUTED
	return l


## §12.2 iş metni. Build aktif sürümün adıyla okunur ("Pulse v2'de çalışıyor"): oyuncunun
## kafasındaki şey o sürümdür. `short` iki iş hâlinin kısa etiketidir.
static func _job_text(job_id: String, short: bool) -> String:
	if job_id == HRConstants.JOB_BUILD:
		var build: FeatureBuild = ProductSystem.get_active_build()
		if build != null:
			# Yapımdaki sürüm: yayında ProductSystem mvp_version'ı tam olarak buna çeker.
			var version: int = (int(GameState.get_flag("mvp_version", 0)) + 1) \
				if build.is_version_build else 1
			if short:
				return "%s v%d" % [build.product_name, version]
			return tr_key("HR_TASK_ON_VERSION").format(
				{"product": build.product_name, "version": version})
	if short:
		return HRConstants.job_label(job_id)
	var key: String = "HR_TASK_ON_JOB_%s" % job_id.to_upper()
	var sentence: String = tr_key(key)
	# Cümlesi olmayan iş (Araştırma) adıyla okunur; ham anahtar ekrana düşmez.
	return HRConstants.job_label(job_id) if sentence == key else sentence


## GÖREV hücresi: tek iş → cümle; iki iş → orta noktalı kısa etiketler (cümle satırı
## taşırır); hiç iş → tire.
static func _task_cell(emp: Character, muted: bool) -> Control:
	var text: String = tr_key("HR_TASK_NONE")
	var jobs: Array[String] = emp.assigned_job_ids
	if jobs.size() >= 2:
		var labels: Array[String] = []
		for job_id in jobs:
			labels.append(_job_text(job_id, true))
		text = " · ".join(labels)
	elif jobs.size() == 1:
		text = _job_text(jobs[0], false)
	var lbl := UiFactory.make_label(text, &"RowMeta", UiTokens.INK_MUTED)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(w_task(), 0)
	lbl.clip_text = true
	if muted:
		lbl.modulate = MUTED
	return lbl


## DENEYİM hücresi: 4px bar + altında yüzde. §5.1 tek bar; eşik kişinin gelişmişliğiyle büyür.
static func _experience_cell(emp: Character) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(w_experience(), 0)
	box.add_theme_constant_override("separation", 3)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var ratio: float = CharacterRegistry.experience_ratio(emp)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(w_experience() - 24, 4)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bar.max_value = 1.0
	bar.value = ratio
	box.add_child(bar)
	var val := UiFactory.make_label(Fmt.percent(int(round(ratio * 100.0)), 0), &"RowMeta")
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(val)
	return box


## Satır tıklaması = kişi aksiyonları menüsü. Sözleşme `(emp_id, action, anchor)`: popover
## kendini çapaya göre konumlandırır.
static func _on_row_input(ev: InputEvent, emp_id: String, on_action: Callable, anchor: Control) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		on_action.call(emp_id, ACTION_MENU, anchor)


## Statik bağlamda çeviri: tr() bir Object ister, burada yok.
static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
