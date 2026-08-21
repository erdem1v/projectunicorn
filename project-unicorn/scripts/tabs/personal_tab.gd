extends Control

# ============================================================================
# KİŞİSEL sekmesi — onaylı tasarım 10a.
#
# Üç blok, iki kolon: solda KURUCU kartı (flex 1.35), sağda 620px sabit kolonda
# NEREDE DURUYORUM ve NET SERVET.
#
# Bu dosya hiçbir sonucu HESAPLAMAZ. Tek istisna biçimleme (yüzde, para) ve hisse
# aritmetiği — o da finance_ozet_view._refresh_captable'ın BİREBİR eşi, çünkü aynı
# soruya iki farklı cevap veren iki ekran, oyuncunun gözünde oyunun kendisinin
# tutarsız olması demektir.
#
# DEĞERLEME YOK ve UYDURULMUYOR. Normal oyunda canlı bir şirket değerlemesi yok:
# GameState.run_valuation_m yalnız term sheet imzasında yazılıyor ve koşu o karede
# bitiyor (endings_system.gd'nin kendi yorumu bunu açıkça söylüyor). ZİRVE DEĞER için
# hiçbir seam yok. Tasarımın kendisi de üç hücreyi "—" çiziyor ve dürüst bir satırla
# kapatıyor; ekran onu yapıyor. Değerleme seam'i bölüm 09'un işi.
# ============================================================================

const RIGHT_COL_WIDTH := 620   # tasarım genişliği (1920'de); artık ORANİ belirler
const RIGHT_COL_MIN := 430     # merdivenin tepesinde inebileceği taban
const PORTRAIT_SIZE := Vector2(150, 186)
const TRAINING_MODAL := "res://scenes/modals/TrainingModal.tscn"

var _signals: Array = []
var _root: VBoxContainer = null


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
	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 16)
	margin.add_child(_root)

	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		_root.add_child(UiFactory.make_label(tr("ODA_PAGE_PLACEHOLDER"), &"CaptionMuted"))
		return

	_root.add_child(_header(founder))

	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 22)
	# İÇERİĞE GÖRE: kartlar sayfayı doldurmaya çalışmaz. 10a'da sol kartın altında hava
	# var ve o hava bilinçli — ileride rakip/ilişki bloğu oraya gelecek.
	cols.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_root.add_child(cols)

	# İKİ KOLON DA ESNER, ORAN SABİT (2026-08-21). Eskiden sağ kolon `SIZE_FILL` +
	# 620 asgari genışlikti, yani TEK PİKSEL geri vermiyordu; %110'da mantıksal
	# viewport 1920'den 1745'e İNER (content_scale_factor büyütmez, KÜÇÜLTÜR) ve
	# açığın tamamı sol karta binerken sağ kolon ekranın dışına taşıyordu.
	# 2.0 : 1.0 — 1920'de 1244:622, tasarımın 1246:620'siyle pratikte aynı.
	var left := _founder_card(founder)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 2.0
	cols.add_child(left)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 22)
	# Asgari, tasarım genişliği DEĞİL bir TABAN: merdivenin tepesinde daralmasına
	# izin veriyoruz, ama okunamayacak kadar değil.
	right.custom_minimum_size = Vector2(RIGHT_COL_MIN, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	right.add_child(_where_i_stand())
	right.add_child(_net_worth())
	cols.add_child(right)


# --- başlık ------------------------------------------------------------------

func _header(founder: Character) -> Control:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(UiFactory.make_label(tr("TAB_PERSONAL"), &"PageTitleSerif"))
	head.add_child(UiFactory.make_label(tr("PER_HEADER_META").format({
		"origin": UiTokens.tr_upper(_origin_label()),
		"phase": UiTokens.tr_upper(GameState.phase_display_name(GameState.phase)),
		"n": _tenure_days(founder),
	}), &"TitleRowSummary"))
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(pad)
	# Günlük atama BURADA değil — tasarım yönlendirmeyi başlığın sağına koyuyor, ki
	# oyuncu "kurucuyu nereye koyacağım" sorusunu bu sayfada aramasın.
	head.add_child(UiFactory.make_label(tr("PER_ASSIGN_HINT"), &"RowMeta", UiTokens.INK_FAINT))
	return head


func _origin_label() -> String:
	var origin: Dictionary = FounderConstants.origin_by_id(GameState.origin)
	return tr(String(origin.get("name_key", "")))


## Kıdem = koşunun kaçıncı günü. Kurucunun hire_day'i yok (işe alınmadı, kurdu).
func _tenure_days(_founder: Character) -> int:
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
	# GameState.founder_name onboarding'de yazılır ve debug koşularında boş olabilir;
	# Character her zaman bir ad taşıyor, o yüzden kart asla adsız çizilmez.
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
		tr("PER_TENURE").format({"n": _tenure_days(founder)}), &"RowMeta", UiTokens.CREAM_DIM))
	name_block.add_child(meta)
	right.add_child(name_block)

	# altı alan + hairline + Liderlik + Karizma, hepsi tek yıldız gramerinde
	var skills := HBoxContainer.new()
	# 24 → 16: sekiz sütunun arasındaki boşluk merdivenin tepesinde geri verilen
	# ilk şey. İki değer de tasarımdan değil ölçümden geliyor ve %100'de fark
	# görünmüyor — dar viewport'ta görünüyor.
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

	# trait'ler: ikon kutusu + ad + tek satır etki
	var traits := VBoxContainer.new()
	traits.add_theme_constant_override("separation", 12)
	for trait_id in founder.traits:
		traits.add_child(_founder_trait(String(trait_id)))
	right.add_child(traits)

	col.add_child(HRUiShared.hairline())
	col.add_child(_founder_footer(founder))
	return card


## Liderlik ve Karizma için Title Case etiket. FounderConstants.skill_label KÜÇÜK harfli
## oran parçaları veriyor ("+%15 satış"), HRConstants.area_label ise sütun başlığı registeri
## — burada ikincisi doğru, ama Karizma bir ALAN değil, o yüzden kendi anahtarından okunur.
func _founder_skill_label(skill_key: String) -> String:
	if skill_key == FounderConstants.SKILL_CHARISMA:
		return tr("PER_CHARISMA")
	return HRConstants.area_label(skill_key)


func _portrait() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = PORTRAIT_SIZE
	frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.SEPARATOR
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	frame.add_theme_stylebox_override("panel", sb)

	# Kurucunun portresi Character.portrait_path'te DEĞİL: onboarding'de seçilen id
	# GameState.founder_portrait'te duruyor ve dosya yolunu FounderConstants çözüyor.
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


func _founder_trait(trait_id: String) -> Control:
	var spec: Dictionary = FounderConstants.trait_by_id(trait_id)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 11)
	# KURUCU KATALOĞU (A5, 2026-08-21). Burası `trait_id`'yi ÇALIŞAN tablosunda
	# arıyordu ve `visionary`/`stubborn`/... hiçbir zaman eşleşmiyordu — yani ikon
	# HER ZAMAN yer tutucuydu ve bu bir KIRIK'tı, bir karar değil. Artık kataloğu
	# açıkça söylüyoruz; kurucu ikonları çizilene kadar yer tutucu BİLEREK duruyor.
	row.add_child(HRUiShared.trait_icon(trait_id, 16, true, "founder"))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_child(UiFactory.make_label(
		UiTokens.tr_upper(tr(String(spec.get("name_key", "")))), &"RowMeta", UiTokens.INK))
	col.add_child(UiFactory.make_label(
		tr(String(spec.get("effect_key", ""))), &"RowMeta", UiTokens.CREAM_DIM))
	row.add_child(col)
	return row


func _founder_footer(founder: Character) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)

	var area_key: String = _experience_area(founder)
	var value: int = int(founder.area_experience.get(area_key, 0))
	var pct: int = int(round(float(value) / float(HRConstants.EXPERIENCE_MAX) * 100.0))

	var exp_row := HBoxContainer.new()
	exp_row.add_theme_constant_override("separation", 11)
	exp_row.add_child(UiFactory.make_label(tr("PER_EXPERIENCE"), &"RowMeta", UiTokens.INK_DIM))
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(120, 5)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.max_value = HRConstants.EXPERIENCE_MAX
	bar.value = value
	exp_row.add_child(bar)
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
			tr("HR_TRAINING_SEND"), tr("HR_TRAINING_AT_CAP")))
	return row


func _experience_area(founder: Character) -> String:
	if not founder.assigned_jobs.is_empty():
		var assigned: String = String(founder.assigned_jobs[0])
		if HRConstants.AREAS.has(assigned):
			return assigned
	return HRConstants.AREA_PRODUCT


func _open_training(character_id: String) -> void:
	var layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[PersonalTab] PanelLayer bulunamadı — eğitim modalı mount edilemiyor")
		return
	var scene: PackedScene = load(TRAINING_MODAL) as PackedScene
	if scene == null:
		return
	var modal: Control = scene.instantiate() as Control
	layer.add_child(modal)
	if modal.has_signal("state_changed"):
		modal.state_changed.connect(_on_state_changed)
	if modal.has_method("populate"):
		modal.populate(character_id)


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
	goal_col.add_child(UiFactory.make_label(_goal_line(), &"RowName"))
	goal.add_child(goal_col)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_top", 12)
	pad.add_child(goal)
	col.add_child(pad)
	return card


func _goal_line() -> String:
	match GameState.phase:
		2:
			return tr("PER_GOAL_TRACTION")
		3:
			return tr("PER_GOAL_SERIES_A")
		_:
			return tr("PER_GOAL_BOOTSTRAP")


# --- sağ alt: NET SERVET ------------------------------------------------------

func _net_worth() -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	card.add_child(col)
	col.add_child(HRUiShared.section_header(tr("PER_NET_WORTH"), true))

	# HİSSE: finance_ozet_view._refresh_captable'ın birebir aritmetiği.
	var investors: int = GameState.get_investor_equity_pct()
	var employees: int = 0
	for emp in CharacterRegistry.get_employees():
		employees += int(round(emp.equity_pct * 100.0))
	employees = mini(employees, maxi(0, 100 - investors))
	var founder_pct: int = maxi(0, 100 - investors - employees)

	col.add_child(_kv(tr("PER_EQUITY"), Fmt.percent(founder_pct, 0), true))
	# DEĞERLEME: normal oyunda yok. run_valuation_m yalnız imzada yazılıyor ve koşu o
	# karede bitiyor; ZİRVE DEĞER'in hiçbir seam'i yok. Üçü de dürüstçe tire duruyor.
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
