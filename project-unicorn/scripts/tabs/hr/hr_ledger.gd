class_name HRLedger
extends RefCounted

# EKİP → KADRO defteri. Tam genişlikte tek bir tablo: etiketli mono sütun başlıkları,
# altlarında çıplak rakamlar — hiçbir sayı oyuncuya "bu ne?" dedirtmeden durmaz.
#
# Rol açıklaması satırda değil hover tooltip'te: satır tek satır yüksekliğinde kalır.
#
# Satırın dört kişi aksiyonu (zam · terfi · eğitim · çıkarma) da burada: satır menüsü ve Ekip
# dosyası aynı kapıdan, aynı gerekçe ve sonuç metniyle geçer.
#
# Sütunlar içeriğin tabanına oturur (rol yıldızları 256, izin etiketi 140, moral barı 124);
# ÇALIŞAN kalan yeri alır, ad ve rol gerekirse kısalır.
const W_ROLES := 256
const W_TASK := 150
const W_EXPERIENCE := 72
const W_STATE := 140
const W_TRAIT := 56
const W_SALARY := 76
const W_MORALE := 124

## Satırın aksiyonları. ACTION_MENU satır tıklamasıdır: kişi aksiyonlarını taşıyan popover'ı
## açar. ACTION_DOSSIER ad/avatar tıklamasıdır: Ekip dosyası penceresini açar.
const ACTION_MENU := "menu"
const ACTION_DOSSIER := "dossier"
const ACTION_RAISE := "raise"
const ACTION_FIRE := "fire"
const ACTION_TRAIN := "train"
const ACTION_PROMOTE := "promote"   # §13.3 dördüncü satır

const TRAINING_MODAL := "res://scenes/modals/TrainingModal.tscn"
## Açık HR görünümleri (Ekip sayfası, Ekip dosyası) bu gruptadır ve `rebuild_view()` uygular.
const VIEWS_GROUP := &"hr_views"


## Sütun başlığı satırı: tablonun başlığı, her grupta tekrar etmez.
static func column_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size = Vector2(0, 26)
	row.add_child(_head(tr_key("HR_COL_EMPLOYEE"), 0, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_head(tr_key("HR_COL_ROLES_LEADERSHIP"), W_ROLES))
	row.add_child(_head(tr_key("HR_COL_TASK"), W_TASK))
	row.add_child(_head(tr_key("HR_COL_EXPERIENCE"), W_EXPERIENCE))
	row.add_child(_head(tr_key("HR_COL_STATE"), W_STATE))
	row.add_child(_head(tr_key("HR_COL_TRAIT"), W_TRAIT))
	row.add_child(_head(tr_key("HR_COL_SALARY"), W_SALARY))
	row.add_child(_head(tr_key("HR_COL_MORALE"), W_MORALE))
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
	card.gui_input.connect(_on_row_input.bind(emp.id, ACTION_MENU, on_action, card))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.tooltip_text = HRConstants.role_phase_hint(emp.role)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)

	var muted: bool = emp.status != HRConstants.STATUS_ACTIVE

	# ÇALIŞAN: büst + ad + rol; tıklanınca Ekip dosyası açılır. Yer rozetleri DURUM
	# sütununda. Ad ve rol kısalabilir: dar pencerede sabit sütunlar yer kazanır.
	var who_cell := HBoxContainer.new()
	who_cell.add_theme_constant_override("separation", UiTokens.SPACE_L)
	who_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who_cell.tooltip_text = card.tooltip_text
	who_cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	who_cell.gui_input.connect(_on_row_input.bind(emp.id, ACTION_DOSSIER, on_action, who_cell))
	who_cell.add_child(UiFactory.make_person_avatar(emp.character_name, emp.look, 32))
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 2)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for text_label in [UiFactory.make_label(emp.character_name, &"RowName"), UiFactory.make_label(
			Fmt.upper(HRConstants.role_label(emp.role)), &"MicroLabel")]:
		text_label.clip_text = true
		text_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		who.add_child(text_label)
	who_cell.add_child(who)
	row.add_child(who_cell)

	row.add_child(HRUiShared.role_area_cell(emp, W_ROLES, muted))
	row.add_child(_task_cell(emp, muted))
	row.add_child(experience_cell(emp))
	row.add_child(HRUiShared.status_cell(emp, W_STATE))
	row.add_child(HRUiShared.trait_cell(emp.traits, W_TRAIT))
	row.add_child(_num(Fmt.money_exact(emp.monthly_salary), W_SALARY, muted))
	var morale_cell := HRUiShared.morale_row(emp.morale, refs)
	morale_cell.custom_minimum_size = Vector2(W_MORALE, 0)
	row.add_child(morale_cell)

	_pass_clicks_through(row)
	# Geçirgenlikten SONRA: dosya tıklaması satırın menüsüne düşmez.
	who_cell.mouse_filter = Control.MOUSE_FILTER_STOP
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
		l.modulate.a = UiTokens.TAB_LOCKED_ALPHA
	return l


## §12.2 GÖREV metni: tek iş → cümle; iki iş → orta noktalı kısa etiketler (cümle satırı
## taşırır); hiç iş → tire. Ekip dosyası da buradan okur.
static func task_text(emp: Character) -> String:
	var jobs: Array[String] = emp.assigned_job_ids
	if jobs.size() >= 2:
		var labels: Array[String] = []
		for job_id in jobs:
			labels.append(_job_text(job_id, true))
		return " · ".join(labels)
	if jobs.size() == 1:
		return _job_text(jobs[0], false)
	return tr_key("HR_TASK_NONE")


## §12.2 iş metni. Build aktif sürümün adıyla okunur ("Pulse v2'de çalışıyor"): oyuncunun
## kafasındaki şey o sürümdür. `short` iki iş hâlinin kısa etiketidir.
static func _job_text(job_id: String, short: bool) -> String:
	if job_id == HRConstants.JOB_BUILD:
		var build: FeatureBuild = ProductSystem.get_active_build()
		if build != null:
			var version: int = ProductSystem.build_version(build)
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


static func _task_cell(emp: Character, muted: bool) -> Control:
	var lbl := UiFactory.make_label(task_text(emp), &"RowMeta", UiTokens.INK_MUTED)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(W_TASK, 0)
	lbl.clip_text = true
	if muted:
		lbl.modulate.a = UiTokens.TAB_LOCKED_ALPHA
	return lbl


## DENEYİM hücresi: 4px bar + altında yüzde. §5.1 tek bar; eşik kişinin gelişmişliğiyle büyür.
static func experience_cell(emp: Character) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(W_EXPERIENCE, 0)
	box.add_theme_constant_override("separation", 3)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var ratio: float = CharacterRegistry.experience_ratio(emp)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(W_EXPERIENCE - 24, 4)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bar.max_value = 1.0
	bar.value = ratio
	box.add_child(bar)
	var val := UiFactory.make_label(Fmt.percent(int(round(ratio * 100.0)), 0), &"RowMeta")
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(val)
	return box


## Satır tıklaması = kişi aksiyonları menüsü, ad/avatar tıklaması = Ekip dosyası. Sözleşme
## `(emp_id, action, anchor)`: popover kendini çapaya göre konumlandırır.
static func _on_row_input(ev: InputEvent, emp_id: String, action: String, on_action: Callable,
		anchor: Control) -> void:
	if UiFactory.is_left_click(ev):
		on_action.call(emp_id, action, anchor)


# --- kişi aksiyonları -------------------------------------------------------

## Kişi aksiyonlarının dikey listesi (satır menüsü ve Ekip dosyası): dört satır, yıkıcı eylem
## hairline'la ayrı bölümde. `on_action(action)` açık bir satıra basılınca çağrılır.
static func action_list(emp: Character, on_action: Callable) -> VBoxContainer:
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 0)
	for spec in _action_specs(emp):
		var act: String = String(spec["action"])
		if act == ACTION_FIRE:
			list.add_child(HRUiShared.hairline())
		list.add_child(_action_row(spec, on_action.bind(act)))
	return list


## Kapalı satırın gerekçesi preview_*'ın `reason` anahtarından okunur: can_* yalnız bool döner.
## `meta` her satırın SONUCUNU söyler (maaş · unvan · süre · kalıcı).
static func _action_specs(emp: Character) -> Array:
	return [
		{"key": "HR_CARD_RAISE", "preview": HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT),
			"action": ACTION_RAISE, "meta": Fmt.money_exact(emp.monthly_salary)},
		# §13.3: kilitli hâli görünür kalır ve gerekçesini gösterir.
		{"key": "HR_CARD_PROMOTE",
			"preview": {"ok": HRActions.can_promote(emp), "reason": HRActions.promotion_block_reason(emp)},
			"action": ACTION_PROMOTE, "meta": HRConstants.job_title(emp.role, emp.level)},
		# §5.4 iki gerekçe: bar dolmadı ya da alan tavanda — metni registry seçer.
		{"key": "HR_TRAINING_PICK_TITLE",
			"preview": {"ok": CharacterRegistry.can_train(emp.id),
				"reason": CharacterRegistry.training_block_reason(emp.id)},
			"action": ACTION_TRAIN, "meta": HRConstants.training_duration_text()},
		{"key": "HR_CARD_FIRE", "preview": HRActions.preview_fire(emp),
			"action": ACTION_FIRE, "meta": tr_key("HR_MENU_PERMANENT")},
	]


## Aksiyon satırı (ActionRow): 46px ritim, 16px iç boşluk, sağda meta; kapalıysa kilit glifi +
## gerekçe.
static func _action_row(spec: Dictionary, on_press: Callable) -> Button:
	var preview: Dictionary = spec["preview"]
	var ok: bool = bool(preview.get("ok", false))
	var reason: String = String(preview.get("reason", ""))

	var btn := Button.new()
	btn.theme_type_variation = &"ActionRow"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(0, 46)
	btn.disabled = not ok
	if ok:
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(on_press)
	else:
		btn.tooltip_text = reason

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.offset_left = 16
	row.offset_right = -16
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Açık satırda glif saydam kalır: etiketler kilitli satırlarla aynı hizada durur.
	row.add_child(HRUiShared.lock_glyph(13, UiTokens.INK_FAINT if not ok else Color.TRANSPARENT))
	var label_col := VBoxContainer.new()
	label_col.add_theme_constant_override("separation", 1)
	label_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_col.add_child(UiFactory.make_label(tr_key(String(spec["key"])), &"RowName",
		UiTokens.INK if ok else UiTokens.INK_DIM))
	if not ok and reason != "":
		label_col.add_child(UiFactory.make_label(reason, &"RowMeta", UiTokens.INK_FAINT))
	row.add_child(label_col)
	var meta: String = String(spec.get("meta", ""))
	if meta != "":
		var meta_lbl := UiFactory.make_label(meta, &"RowMeta", UiTokens.INK_DIM)
		meta_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		meta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(meta_lbl)
	btn.add_child(row)
	return btn


## Kişi aksiyonlarının tek kapısı (§14 aksiyon kabuğu). `host`, eğitim modalının monte
## edileceği ağaçtaki bir düğüm.
static func run_action(host: Node, emp: Character, action: String) -> void:
	match action:
		ACTION_RAISE:
			_open_raise(emp)
		ACTION_PROMOTE:
			_open_promotion(emp)
		ACTION_TRAIN:
			# Alan seçimini oyuncu yapıyor (§5.2), o yüzden onay kutusu değil eğitim modalı.
			HRUiShared.mount_panel_modal(host, TRAINING_MODAL, _refresh_views, [emp.id])
		ACTION_FIRE:
			_confirm_fire(emp)


static func _open_raise(emp: Character) -> void:
	if not bool(HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT).get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr_key("HR_CARD_RAISE"),   # başlıkta yalnız eylem, ad yok
		"commit_key": "HR_APPLY_RAISE_PCT",
		"slider": {"min": HRConstants.RAISE_MIN_PCT, "max": HRConstants.RAISE_MAX_PCT,
			"start": HRConstants.RAISE_MIN_PCT},
		"preview": func(pct: int) -> Dictionary: return HRActions.preview_raise(emp, pct),
		"on_commit": _commit.bind(emp.id, HRActions.apply_raise),
	})


## §9.3: zam ile aynı kabuk; fark bir SEVİYE atlaması olması — unvan da bir delta satırı.
## Minimum %10, yani slider "terfi ettim ama zam almadım"a inmez.
static func _open_promotion(emp: Character) -> void:
	if not HRActions.can_promote(emp):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr_key("HR_CARD_PROMOTE"),
		"commit_key": "HR_APPLY_PROMOTE_PCT",
		"slider": {"min": HRConstants.PROMOTION_MIN_PCT, "max": HRConstants.PROMOTION_MAX_PCT,
			"start": HRConstants.PROMOTION_MIN_PCT},
		"preview": func(pct: int) -> Dictionary: return HRActions.preview_promotion(emp, pct),
		"on_commit": _commit.bind(emp.id, HRActions.apply_promotion),
	})


static func _confirm_fire(emp: Character) -> void:
	var pv: Dictionary = HRActions.preview_fire(emp)
	if not bool(pv.get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr_key("HR_CARD_FIRE"),
		"rows": pv.get("rows", []),
		"commit_text": tr_key("HR_FIRE_CONFIRM_OK"),
		# Modal her eyleme tek imzayla döner; çıkarmanın slider'ı yok, gelen sıfır düşer.
		"on_commit": _commit.bind(emp.id, HRActions.fire.unbind(1)),
	})


## Onay modalının dönüşü. Kişi o arada ayrıldıysa ya da motor reddederse false: modal açık kalır.
static func _commit(pct: int, emp_id: String, apply: Callable) -> bool:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null or not apply.call(emp, pct):
		return false
	_refresh_views()
	return true


## Maaş ve seviye yazımı sinyal atmıyor: aksiyon bitince açık her HR görünümü yeniden kurulur.
static func _refresh_views() -> void:
	(Engine.get_main_loop() as SceneTree).call_group(VIEWS_GROUP, &"rebuild_view")


## Statik bağlamda çeviri: tr() bir Object ister, burada yok.
static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
