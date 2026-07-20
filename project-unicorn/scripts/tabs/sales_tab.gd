extends Control

# Sales tab — B2B portfolio management (PostShip spec §G, redesigned on the approved
# mockups). Center area only: a pipeline pulse strip, a prospect column, and a live
# state-keyed customer portfolio. Humble UI — the tab reads registries + GameState and
# TRIGGERS existing seams; it performs ZERO state writes (WRITE-THROUGH LAW). Rows
# rebuild on the relevant EventBus signals (no per-frame polling). process_mode=ALWAYS
# (.tscn) so actions work while the clock is paused.
#
# B2C is out of scope: when the shipped product is B2C the tab falls back to the prior
# simple metrics line + customer rows, unchanged. The redesign is B2B-only.

const FIND_PROSPECTS_COOLDOWN_DAYS := 5
const FIND_PROSPECTS_COUNT := 2

@onready var subtitle_label: Label = $Margin/Layout/TitleBar/SubtitleLabel
@onready var metrics_label: Label = $Margin/Layout/TitleBar/MetricsLabel
@onready var pulse_strip: HBoxContainer = $Margin/Layout/PulseStrip
@onready var phead_label: Label = $Margin/Layout/Columns/ProspectsCol/PHeader/PHeaderLabel
@onready var phead_count: Label = $Margin/Layout/Columns/ProspectsCol/PHeader/PHeaderCount
@onready var find_slot: VBoxContainer = $Margin/Layout/Columns/ProspectsCol/FindSlot
@onready var prospects_empty: Label = $Margin/Layout/Columns/ProspectsCol/ProspectsEmpty
@onready var prospects_list: VBoxContainer = $Margin/Layout/Columns/ProspectsCol/ProspectsScroll/ProspectsList
@onready var chead_label: Label = $Margin/Layout/Columns/CustomersCol/CHeader/CHeaderLabel
@onready var chead_count: Label = $Margin/Layout/Columns/CustomersCol/CHeader/CHeaderCount
@onready var customers_empty: Label = $Margin/Layout/Columns/CustomersCol/CustomersEmpty
@onready var customers_list: VBoxContainer = $Margin/Layout/Columns/CustomersCol/CustomersScroll/CustomersList

var _signals := []


func _ready() -> void:
	subtitle_label.text = tr("SALES_SUBTITLE")
	phead_label.text = tr("SALES_PROSPECTS_HEADER")
	chead_label.text = tr("SALES_PORTFOLIO_HEADER")
	prospects_empty.text = tr("SALES_PROSPECTS_EMPTY")
	customers_empty.text = tr("SALES_CUSTOMERS_EMPTY")
	# Signal-driven refresh (never polling): every seam that can change what a row shows.
	_signals = [
		EventBus.prospect_added, EventBus.prospect_removed,
		EventBus.customer_added, EventBus.customer_removed,
		EventBus.customer_health_changed, EventBus.customer_churned,
		EventBus.customer_expanded, EventBus.customer_assigned,
		EventBus.customer_satisfaction_changed, EventBus.customer_seats_changed,
		EventBus.mrr_changed, EventBus.day_advanced, EventBus.pitch_finished,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)


# Two optional params so 0/1/2-arg signals can all bind to one handler.
func _on_state_changed(_a = null, _b = null) -> void:
	_refresh()


func _refresh() -> void:
	var is_b2b: bool = String(GameState.get_flag("mvp_market_type", "")) == "b2b"
	subtitle_label.visible = is_b2b
	metrics_label.visible = not is_b2b
	pulse_strip.visible = is_b2b
	_refresh_prospects(is_b2b)
	if is_b2b:
		_refresh_strip()
		_refresh_portfolio()
	else:
		_refresh_metrics_b2c()
		_refresh_customers_b2c()


# --- Pipeline pulse strip (B2B) ---

func _refresh_strip() -> void:
	for ch in pulse_strip.get_children():
		ch.queue_free()
	var custs: Array[Customer] = CustomerRegistry.get_by_market("b2b")
	var count: int = custs.size()
	var avg: int = 0
	if count > 0:
		var total: int = 0
		for c in custs:
			total += c.satisfaction
		avg = int(round(float(total) / float(count)))
	# This-month customer delta = current run counter − the month-start snapshot the
	# MonthSummarySystem stores in month_ledger (read-only; the tab never writes).
	var ledger: Dictionary = GameState.month_ledger
	var gained: int = GameState.run_customers_signed - int(ledger.get("customers_signed", 0))
	var lost: int = GameState.run_customers_lost - int(ledger.get("customers_lost", 0))
	var net: int = gained - lost
	_add_pulse_cell(tr("SALES_STRIP_CUSTOMERS"), str(count))
	_add_pulse_cell(tr("SALES_STRIP_SATISFACTION"), "%%%d" % avg)
	_add_pulse_cell(tr("SALES_STRIP_GAINED"), "+%d" % gained, UiTokens.delta_color(gained))
	var net_str: String = ("+%d" % net) if net > 0 else str(net)
	_add_pulse_cell(tr("SALES_STRIP_NET"), net_str, UiTokens.delta_color(net), "(+%d / -%d)" % [gained, lost])


func _add_pulse_cell(caption: String, value: String, color: Variant = null, sub: String = "") -> void:
	# No divider hairlines (they read wrong on cream) — even cell spacing carries the
	# division; each cell EXPAND_FILLs an equal quarter of the strip width.
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	col.add_child(UiFactory.make_label(caption, &"MetricCaptionInk"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(UiFactory.make_label(value, &"MetricValueInk", color))
	if sub != "":
		var s := UiFactory.make_label(sub, &"RowMeta", UiTokens.INK_DIM)
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(s)
	col.add_child(row)
	pulse_strip.add_child(col)


# --- Prospect column ---

func _refresh_prospects(is_b2b: bool) -> void:
	for ch in prospects_list.get_children():
		ch.queue_free()
	for ch in find_slot.get_children():
		ch.queue_free()
	if is_b2b:
		find_slot.add_child(_build_find_card())
	var prospects: Array[Prospect] = ProspectRegistry.get_all()
	phead_count.text = tr("SALES_PROSPECTS_COUNT") % prospects.size()
	prospects_empty.visible = prospects.is_empty()
	for p in prospects:
		prospects_list.add_child(_build_prospect_card(p))
	if is_b2b:
		prospects_list.add_child(_build_tier2_teaser())


func _build_find_card() -> Control:
	var on_cooldown: bool = GameState.day < int(GameState.get_flag("next_find_prospects_day", 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var lbl := UiFactory.make_label(tr("SALES_FIND"), &"RowName", UiTokens.INK if not on_cooldown else UiTokens.INK_DIM)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	if on_cooldown:
		var days: int = int(GameState.get_flag("next_find_prospects_day", 0)) - GameState.day
		row.add_child(UiFactory.make_label(tr("SALES_FIND_COOLDOWN") % days, &"RowMeta", UiTokens.INK_DIM))
	var card := UiFactory.make_card(row)
	if not on_cooldown:
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.gui_input.connect(_on_find_card_input)
	return card


func _on_find_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_find_pressed()


func _build_prospect_card(p: Prospect) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	# Name + sector.
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	var name_lbl := UiFactory.make_label(p.company_name, &"RowName")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_lbl)
	var sector := UiFactory.make_label(UiTokens.tr_upper(p.industry), &"SectionLabel")
	sector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(sector)
	col.add_child(top)
	# Stars (size) + pain-point chip.
	var mid := HBoxContainer.new()
	mid.add_theme_constant_override("separation", 8)
	mid.add_child(_stars(p.scale))
	var pain: String = B2BConstants.feature_label(p.pain_feature_id)
	if pain != "":
		var pal: Dictionary = UiTokens.badge_palette(&"neutral")
		var chip := UiFactory.make_pill("\"%s\"" % pain, pal.bg, pal.fg, false)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mid.add_child(chip)
	col.add_child(mid)
	# Value RANGE (min–max/ay, K/M formatter).
	var vr: String = tr("SALES_VALUE_RANGE") % [UiTokens.format_money(p.value_band_min), UiTokens.format_money(p.value_band_max)]
	col.add_child(UiFactory.make_label(vr, &"RowMeta", UiTokens.INK))
	# Action → the existing pitch flow (unchanged).
	var btn := Button.new()
	btn.text = tr("SALES_PROSPECT_ACTION")
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.disabled = not PitchSystem.can_pitch()
	var pid: String = p.id
	btn.pressed.connect(func() -> void: EventBus.pitch_requested.emit(pid))
	col.add_child(btn)
	return UiFactory.make_card(col)


func _build_tier2_teaser() -> Control:
	# Static "coming soon" telegraph for the gated 4-5 star enterprise segment (mockup).
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	var top := HBoxContainer.new()
	var title := UiFactory.make_label(tr("SALES_TIER2_TITLE"), &"RowName", UiTokens.INK_DIM)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	top.add_child(UiFactory.make_label(tr("SALES_TIER2_TAG"), &"SectionLabel"))
	col.add_child(top)
	col.add_child(UiFactory.make_label(tr("SALES_TIER2_HINT"), &"RowMeta", UiTokens.INK_DIM))
	var card := UiFactory.make_card(col, true)
	card.modulate = Color(1, 1, 1, 0.55)
	return card


# --- Customer portfolio (B2B, state-keyed rows) ---

func _refresh_portfolio() -> void:
	for ch in customers_list.get_children():
		ch.queue_free()
	var custs: Array[Customer] = CustomerRegistry.get_by_market("b2b")
	chead_count.text = tr("SALES_CUSTOMERS_COUNT") % custs.size()
	customers_empty.visible = custs.is_empty()
	# Attention-badged rows (risk, expansion) sort above calm rows (FM grammar).
	custs.sort_custom(func(a: Customer, b: Customer) -> bool: return _attention_rank(a) > _attention_rank(b))
	for c in custs:
		customers_list.add_child(_build_customer_card(c))


func _attention_rank(c: Customer) -> int:
	match c.lifecycle_phase:
		"risk": return 2
		"expansion": return 1
		_: return 0


func _build_customer_card(c: Customer) -> Control:
	match c.lifecycle_phase:
		"risk": return _card_risk(c)
		"expansion": return _card_expansion(c)
		_: return _card_calm(c)  # active | onboarding | churning


func _card_calm(c: Customer) -> Control:
	var is_new: bool = c.lifecycle_phase == "onboarding"
	var managed: bool = c.assigned_to != ""
	var ink: Color = UiTokens.INK_MUTED if managed else UiTokens.INK  # CS-managed rows read calmer
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	var name_lbl := UiFactory.make_label(c.company_name, &"RowName", ink)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_lbl)
	if is_new:
		top.add_child(UiFactory.make_badge(tr("SALES_CHIP_NEW"), &"neutral"))
	else:
		top.add_child(UiFactory.make_badge(tr("SALES_CHIP_HEALTHY"), &"positive"))
	col.add_child(top)
	col.add_child(UiFactory.make_label(_meta_line(c), &"RowMeta", UiTokens.INK_MUTED))
	_add_steward_line(col, c)
	return UiFactory.make_card(col)


func _card_risk(c: Customer) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	var name_lbl := UiFactory.make_label(c.company_name, &"RowName")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_lbl)
	top.add_child(UiFactory.make_badge(tr("SALES_CHIP_RISK"), &"negative"))
	top.add_child(UiFactory.make_badge("!", &"negative"))
	col.add_child(top)
	col.add_child(UiFactory.make_label(_meta_line(c), &"RowMeta", UiTokens.INK_MUTED))
	# Reason — in-voice, no raw numbers (dim italic).
	col.add_child(UiFactory.make_label(tr("SALES_REASON_PREFIX") % _risk_reason(c), &"QuoteSerif"))
	# Watched churn countdown (brick, mono).
	if c.churn_countdown >= 0:
		col.add_child(UiFactory.make_label(tr("SALES_CHURN_COUNTDOWN") % c.churn_countdown, &"RowMeta", UiTokens.NEGATIVE))
	# Action → the existing retention decision modal (backend-built; state-free trigger).
	col.add_child(_action_button(tr("SALES_ACTION_RETAIN") + " →", func() -> void:
		if EventManager._active_event_id == "":
			EventManager.enqueue(B2BEventFactory.build_retention(c))))
	return UiFactory.make_card(col, false, true)  # CardAttention (amber)


func _card_expansion(c: Customer) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	var name_lbl := UiFactory.make_label(c.company_name, &"RowName")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_lbl)
	top.add_child(UiFactory.make_badge(tr("SALES_CHIP_EXPANSION"), &"accent"))
	top.add_child(UiFactory.make_badge("↑", &"accent"))
	col.add_child(top)
	col.add_child(UiFactory.make_label(_meta_line(c), &"RowMeta", UiTokens.INK_MUTED))
	col.add_child(UiFactory.make_label(tr("SALES_EXPANSION_FICTION"), &"QuoteSerif"))
	# Action → the existing expansion event (state-free trigger).
	col.add_child(_action_button(tr("SALES_ACTION_EXPAND") + " →", func() -> void:
		if EventManager._active_event_id == "":
			EventManager.enqueue(B2BEventFactory.build_expansion(c))))
	return UiFactory.make_card(col)


func _add_steward_line(col: VBoxContainer, c: Customer) -> void:
	# ONLY on CS-assigned rows; founder-managed rows show no steward line.
	if c.assigned_to == "":
		return
	var cs: Character = CharacterRegistry.get_character(c.assigned_to)
	if cs == null:
		return
	col.add_child(UiFactory.make_label(tr("SALES_STEWARD") % cs.character_name, &"RowMeta", UiTokens.INK_DIM))


func _action_button(label: String, on_press: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.theme_type_variation = &"CommitButton"
	btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	btn.pressed.connect(on_press)
	return btn


func _meta_line(c: Customer) -> String:
	var mrr_part: String = UiTokens.format_money(c.mrr) + tr("SALES_PER_MONTH")
	var seats_part: String = tr("SALES_SEATS") % c.seats
	var months: int = int((GameState.day - c.acquired_on_day) / GameState.DAYS_PER_MONTH)
	var tenure: String = tr("SALES_TENURE_NEW") if months < 1 else (tr("SALES_TENURE") % months)
	return "%s · %s · %s" % [mrr_part, seats_part, tenure]


func _risk_reason(c: Customer) -> String:
	# Derived read-only from the product state that drove the account below tolerance.
	# NO raw numbers. Working TR — FLAG for Erdem's voice pass.
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0)))
	if bugs > B2BConstants.COMPLAINT_BUG_GATE:
		return tr("SALES_REASON_OUTAGE")
	return tr("SALES_REASON_SATISFACTION")


func _stars(n: int) -> Control:
	# Filled/empty 1-5 star rating (amber filled, dim empty). No existing helper.
	var filled: int = clampi(n, 0, 5)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if filled > 0:
		row.add_child(UiFactory.make_label("★".repeat(filled), &"BodySerif", UiTokens.ACCENT_DEEP))
	if filled < 5:
		row.add_child(UiFactory.make_label("☆".repeat(5 - filled), &"BodySerif", UiTokens.INK_DIM))
	return row


# --- Find Prospects action (unchanged seam) ---

func _on_find_pressed() -> void:
	if GameState.day < int(GameState.get_flag("next_find_prospects_day", 0)):
		return
	for i in FIND_PROSPECTS_COUNT:
		var archetype: String = "mid" if (GameState.day + i) % 3 == 0 else "small"
		PitchSystem.spawn_prospect(archetype, "find")
	GameState.set_flag("next_find_prospects_day", GameState.day + FIND_PROSPECTS_COOLDOWN_DAYS)
	_refresh()


# --- B2C fallback (unchanged behavior; out of redesign scope) ---

func _refresh_metrics_b2c() -> void:
	var sat: int = CustomerRegistry.get_min_satisfaction()
	metrics_label.text = "MRR $%d · %d ödeyen kullanıcı · en düşük memnuniyet %d" % [GameState.mrr, CustomerRegistry.get_total_users(), sat]


func _refresh_customers_b2c() -> void:
	for ch in customers_list.get_children():
		ch.queue_free()
	var custs: Array[Customer] = CustomerRegistry.get_active()
	chead_count.text = ""
	customers_empty.visible = custs.is_empty()
	for c in custs:
		var col := VBoxContainer.new()
		col.add_child(UiFactory.make_label(c.company_name, &"RowName"))
		col.add_child(UiFactory.make_label("$%d/ay · %s" % [c.mrr, _health_tr(c.health)], &"RowMeta", UiTokens.INK_MUTED))
		customers_list.add_child(col)


func _health_tr(h: String) -> String:
	match h:
		"healthy": return "sağlıklı"
		"at_risk": return "riskli"
		"churning": return "kaçıyor"
		_: return h
