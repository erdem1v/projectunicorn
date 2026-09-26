extends Control

# ============================================================================
# KİŞİSEL sekmesi (10a). Üç blok, iki kolon: solda KURUCU kartı, sağda NEREDE DURUYORUM
# ve NET SERVET.
#
# Bu dosya hiçbir sonucu hesaplamaz. Tek istisna biçimleme ve hisse aritmetiği — o da
# finance_ozet_view._refresh_captable'ın birebir eşi: aynı soruya iki ekran iki cevap
# vermemeli.
#
# DEĞERLEME UYDURULMUYOR: normal oyunda canlı şirket değerlemesi yok (run_valuation_m
# yalnız term sheet imzasında yazılıyor ve koşu o karede bitiyor), ZİRVE DEĞER için de
# seam yok. Üç hücre "—" ve dürüst bir notla kapanıyor.
# ============================================================================

const RIGHT_COL_MIN := 430     # sağ kolonun dar viewport'ta inebileceği taban
const PORTRAIT_SIZE := Vector2(150, 186)
## §2.6'nın nötr huy yuvası — çalışan trait ikonuyla (28×28) aynı ailede, bir tık küçük.
const TRAIT_SLOT_SIZE := Vector2(26, 26)
const TRAINING_MODAL := "res://scenes/modals/TrainingModal.tscn"

var _signals: Array = []


func _ready() -> void:
	_signals = [
		EventBus.cash_changed, EventBus.equity_changed, EventBus.phase_changed,
		EventBus.hr_day_processed, EventBus.employee_experience_changed,
		EventBus.employee_training_changed, EventBus.character_added,
		EventBus.character_removed, EventBus.palette_changed,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	_build()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)


func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	_build()


func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		root.add_child(UiFactory.make_label(tr("ODA_PAGE_PLACEHOLDER"), &"CaptionMuted"))
		return

	root.add_child(_header())

	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 22)
	# İçeriğe göre: sol kartın altındaki hava bilinçli (10a).
	cols.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	root.add_child(cols)

	# İki kolon da esner, oran sabit (2:1 — 1920'de tasarımın 1246:620'si). Ölçek büyüyünce
	# mantıksal viewport daralır; sabit genişlikli sağ kolon ekran dışına taşardı.
	var left := _founder_card(founder)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 2.0
	cols.add_child(left)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 22)
	right.custom_minimum_size = Vector2(RIGHT_COL_MIN, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	right.add_child(_where_i_stand())
	right.add_child(_net_worth())
	cols.add_child(right)


# --- başlık ------------------------------------------------------------------

func _header() -> Control:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(UiFactory.make_label(tr("TAB_PERSONAL"), &"PageTitleSerif"))
	head.add_child(UiFactory.make_label(tr("PER_HEADER_META").format({
		"origin": UiTokens.tr_upper(_origin_label()),
		"phase": UiTokens.tr_upper(GameState.phase_display_name(GameState.phase)),
		"n": _tenure_days(),
	}), &"TitleRowSummary"))
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(pad)
	return head


func _origin_label() -> String:
	var origin: Dictionary = FounderConstants.origin_by_id(GameState.origin)
	return tr(String(origin.get("name_key", "")))


## Kıdem = koşunun kaçıncı günü. Kurucunun hire_day'i yok (işe alınmadı, kurdu).
func _tenure_days() -> int:
	return maxi(GameState.day, 1)


# --- sol: KURUCU kartı --------------------------------------------------------

func _founder_card(founder: Character) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	card.add_child(col)

	col.add_child(HRUiShared.section_header(tr("PER_FOUNDER"), true))

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 22)
	col.add_child(body)

	body.add_child(_portrait())

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 16)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)

	# ad + köken · kıdem
	var name_block := VBoxContainer.new()
	name_block.add_theme_constant_override("separation", 6)
	# founder_name onboarding'de yazılır ve debug koşularında boş olabilir; Character her
	# zaman bir ad taşıyor, kart asla adsız çizilmez.
	var shown_name: String = GameState.founder_name.strip_edges()
	if shown_name == "":
		shown_name = founder.character_name
	name_block.add_child(UiFactory.make_label(shown_name, &"TitleSerif"))
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 12)
	meta.add_child(UiFactory.make_label(
		UiTokens.tr_upper(_origin_label()), &"RowMeta", UiTokens.CREAM_DIM))
	meta.add_child(HRUiShared._v_hairline(11))
	meta.add_child(UiFactory.make_label(
		tr("PER_TENURE").format({"n": _tenure_days()}), &"RowMeta", UiTokens.CREAM_DIM))
	name_block.add_child(meta)
	right.add_child(name_block)

	# altı alan + hairline + Liderlik + Karizma, hepsi tek yıldız gramerinde
	var skills := HBoxContainer.new()
	skills.add_theme_constant_override("separation", 16)
	skills.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for area_key in HRConstants.AREAS:
		var cell: Control = StarRating.labelled(HRConstants.area_label(String(area_key)),
			int(founder.role_stats.get(String(area_key), 0)), 15, false, true)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		skills.add_child(cell)
	skills.add_child(HRUiShared._v_hairline(30))
	for skill_key in [HRConstants.SKILL_LEADERSHIP, FounderConstants.SKILL_CHARISMA]:
		skills.add_child(StarRating.labelled(_founder_skill_label(String(skill_key)),
			int(founder.role_stats.get(String(skill_key), 0)), 15))
	right.add_child(skills)

	right.add_child(_founder_trait_area())

	col.add_child(HRUiShared.hairline())
	col.add_child(_founder_footer(founder))
	return card


## Karizma bir ALAN değil, kendi anahtarından okunur; FounderConstants.skill_label oran
## parçası verir ("+%15 satış"), etiket değil.
func _founder_skill_label(skill_key: String) -> String:
	if skill_key == FounderConstants.SKILL_CHARISMA:
		return tr("PER_CHARISMA")
	return HRConstants.area_label(skill_key)


## Portre çerçevesi ve huy yuvası: hairline kenarlı boş kare.
func _frame(min_size: Vector2) -> PanelContainer:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = min_size
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.SEPARATOR
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	frame.add_theme_stylebox_override("panel", sb)
	return frame


func _portrait() -> Control:
	var frame := _frame(PORTRAIT_SIZE)
	frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	# Kurucunun portresi Character.portrait_path'te DEĞİL: onboarding'de seçilen id
	# GameState.founder_portrait'te, dosya yolunu FounderConstants çözüyor.
	var path: String = FounderConstants.portrait_path(GameState.founder_portrait)
	if path != "" and ResourceLoader.exists(path):
		var tex := TextureRect.new()
		tex.texture = load(path)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.custom_minimum_size = PORTRAIT_SIZE
		frame.clip_contents = true
		frame.add_child(tex)
	return frame


## §2.5 / §2.6 · KURUCU HUYLARI: ayrılmış, şu an NÖTR GLİFTE ve BAĞLANMAMIŞ. Huy etkilerini
## hiçbir sistem tüketmediği için ad ve etki çizilmez. Yuva sayısı katalogdan okunur
## (§15.2). Nötr glif: ikon yok (hangi huy olduğunu ima ederdi), renk yok (kutup ima ederdi).
func _founder_trait_area() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.add_child(UiFactory.make_label(tr("PER_TRAITS"), &"ColumnHeader", UiTokens.INK_DIM))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	for _i in FounderConstants.TRAITS.size():
		row.add_child(_frame(TRAIT_SLOT_SIZE))
	box.add_child(row)
	return box


func _founder_footer(founder: Character) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)

	# §2.5 · MEVCUT GÖREV DURUMU eğitim eyleminin yanında: "ne yapıyor · ne kadar
	# yaklaştı · gönder" tek satırda okunuyor.
	var task_row := HBoxContainer.new()
	task_row.add_theme_constant_override("separation", 10)
	task_row.add_child(UiFactory.make_label(tr("PER_TASK_LABEL"), &"RowMeta", UiTokens.INK_DIM))
	task_row.add_child(UiFactory.make_label(HRSystem.founder_task_label(), &"RowMeta", UiTokens.INK))
	row.add_child(task_row)
	row.add_child(HRUiShared._v_hairline(13))

	var exp_row := HBoxContainer.new()
	exp_row.add_theme_constant_override("separation", 11)
	exp_row.add_child(UiFactory.make_label(tr("PER_EXPERIENCE"), &"RowMeta", UiTokens.INK_DIM))
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(120, 5)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# §5.1 tek bar; değişen arkasındaki eşiktir.
	bar.max_value = maxi(founder.experience_threshold, 1)
	bar.value = founder.experience_raw
	exp_row.add_child(bar)
	var pct: int = int(round(CharacterRegistry.experience_ratio(founder) * 100.0))
	exp_row.add_child(UiFactory.make_label(Fmt.percent(pct, 0), &"RowMeta", UiTokens.INK_MUTED))
	row.add_child(exp_row)

	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)

	if CharacterRegistry.can_train(founder.id):
		row.add_child(HRUiShared.action_button(
			tr("HR_TRAINING_SEND"), _open_training.bind(founder.id), true))
	else:
		row.add_child(HRUiShared.disabled_button(
			tr("HR_TRAINING_SEND"), CharacterRegistry.training_block_reason(founder.id)))
	return row


## PanelLayer'a monte olur (gerekçe hr_tab._mount_panel_modal).
func _open_training(character_id: String) -> void:
	var layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[PersonalTab] PanelLayer bulunamadı — eğitim modalı mount edilemiyor")
		return
	var modal: Node = (load(TRAINING_MODAL) as PackedScene).instantiate()
	layer.add_child(modal)   # önce add_child, sonra populate (ev konvansiyonu)
	modal.connect("state_changed", _on_state_changed)
	modal.call("populate", character_id)


# --- sağ üst: NEREDE DURUYORUM -----------------------------------------------

func _where_i_stand() -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	card.add_child(col)
	col.add_child(HRUiShared.section_header(tr("PER_WHERE_AM_I"), true))

	for phase_no in [1, 2, 3]:
		var active: bool = GameState.phase == phase_no
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.custom_minimum_size = Vector2(0, 30)
		var pip := Panel.new()
		pip.custom_minimum_size = Vector2(22, 4)
		pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var pip_sb := StyleBoxFlat.new()
		pip_sb.bg_color = UiTokens.ACCENT if active else UiTokens.SURFACE_SUNKEN
		pip.add_theme_stylebox_override("panel", pip_sb)
		row.add_child(pip)
		row.add_child(UiFactory.make_label(GameState.phase_display_name(phase_no),
			&"RowName" if active else &"RowMeta",
			UiTokens.INK if active else UiTokens.INK_DIM))
		col.add_child(row)

	# BU FAZIN HEDEFİ — sol amber kenarlı kutu.
	var goal := PanelContainer.new()
	var goal_sb := StyleBoxFlat.new()
	goal_sb.bg_color = UiTokens.AMBER_WASH
	goal_sb.border_width_left = UiTokens.BORDER_FOCUS
	goal_sb.border_color = UiTokens.ACCENT
	goal_sb.content_margin_left = 14.0
	goal_sb.content_margin_right = 14.0
	goal_sb.content_margin_top = 12.0
	goal_sb.content_margin_bottom = 12.0
	goal.add_theme_stylebox_override("panel", goal_sb)
	var goal_col := VBoxContainer.new()
	goal_col.add_theme_constant_override("separation", 6)
	goal_col.add_child(UiFactory.make_label(tr("PER_PHASE_GOAL"), &"ColumnHeader", UiTokens.INK_DIM))
	var goal_key: String = {2: "PER_GOAL_TRACTION", 3: "PER_GOAL_SERIES_A"}.get(
		GameState.phase, "PER_GOAL_BOOTSTRAP")
	goal_col.add_child(UiFactory.make_label(tr(goal_key), &"RowName"))
	goal.add_child(goal_col)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_top", 12)
	pad.add_child(goal)
	col.add_child(pad)
	return card


# --- sağ alt: NET SERVET ------------------------------------------------------

func _net_worth() -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	card.add_child(col)
	col.add_child(HRUiShared.section_header(tr("PER_NET_WORTH"), true))

	# finance_ozet_view._refresh_captable'ın birebir aritmetiği. Çalışan hissesinin motorda
	# kaynağı yok (opsiyon havuzu kurulmadı).
	var founder_pct: int = maxi(0, 100 - GameState.get_investor_equity_pct())

	col.add_child(_kv(tr("PER_EQUITY"), Fmt.percent(founder_pct, 0), true))
	# Değerleme seam'i yok (dosya başı); üçü de dürüstçe tire.
	col.add_child(_kv(tr("PER_VALUATION"), "—", false))
	col.add_child(_kv(tr("PER_NET_WORTH"), "—", false))
	col.add_child(_kv(tr("PER_PEAK_VALUE"), "—", false))

	var note := UiFactory.make_label(tr("PER_NO_VALUATION"), &"RowMeta", UiTokens.CREAM_DIM)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var note_pad := MarginContainer.new()
	note_pad.add_theme_constant_override("margin_top", 14)
	note_pad.add_child(note)
	col.add_child(note_pad)

	# Kurucu payı şeridi.
	var bar := Panel.new()
	bar.custom_minimum_size = Vector2(0, 8)
	var bar_sb := StyleBoxFlat.new()
	bar_sb.bg_color = UiTokens.INK_MUTED
	bar_sb.set_corner_radius_all(UiTokens.RADIUS_S)
	bar.add_theme_stylebox_override("panel", bar_sb)
	var strip := VBoxContainer.new()
	strip.add_theme_constant_override("separation", 9)
	strip.add_child(bar)
	strip.add_child(UiFactory.make_label(
		tr("PER_CAP_FOUNDER").format({"pct": founder_pct}), &"RowMeta", UiTokens.INK_MUTED))
	var strip_pad := MarginContainer.new()
	strip_pad.add_theme_constant_override("margin_top", 16)
	strip_pad.add_child(strip)
	col.add_child(strip_pad)
	return card


func _kv(caption: String, value: String, strong: bool) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 38)
	var cap := UiFactory.make_label(caption, &"RowMeta", UiTokens.INK_DIM)
	cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(cap)
	var val := UiFactory.make_label(value, &"MetricValueInk",
		UiTokens.INK if strong else UiTokens.INK_DIM)
	val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(val)
	var wrap := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_width_bottom = UiTokens.BORDER_HAIRLINE
	sb.border_color = UiTokens.DIVIDER_LIGHT
	wrap.add_theme_stylebox_override("panel", sb)
	wrap.add_child(row)
	return wrap
