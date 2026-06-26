extends Panel

# Persistent stat strip per PROJECT_SPEC §3.3 + TECH_SPEC §11.3.
# Reads GameState on _ready, then updates via EventBus signals (§13).
#
# Design notes (skill-driven):
#  - No emoji icons — text labels instead (minimalist-ui directive).
#  - Typographic hierarchy: Cash + CompanyName at 15px, other stats at 13px,
#    secondary metrics in dimmer tinted neutral (impeccable §typography).
#  - Phase indicator: 3-segment dot bar + active phase name label
#    (replaces the earlier 3-Panel strip that overflowed).
#  - Speed buttons: transparent idle / subtle hover / walnut active
#    (emil-design-eng §buttons must feel responsive).

const PHASE_NAMES := ["Bootstrap", "Traction", "Series A"]

@onready var company_name_label: Label = $Margin/Row/IdentityGroup/CompanyNameLabel
@onready var cash_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Cash/ValueLabel
@onready var cash_delta_label: Label = $Margin/Row/FinanceGroup/StatCol_Cash/DeltaLabel
@onready var mrr_value_label: Label = $Margin/Row/FinanceGroup/StatCol_MRR/ValueLabel
@onready var mrr_delta_label: Label = $Margin/Row/FinanceGroup/StatCol_MRR/DeltaLabel
@onready var burn_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Burn/ValueLabel
@onready var net_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Net/ValueLabel
@onready var runway_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Runway/ValueLabel
@onready var brand_value_label: Label = $Margin/Row/ReputationGroup/StatCol_Brand/ValueLabel
@onready var rep_value_label: Label = $Margin/Row/ReputationGroup/StatCol_Rep/ValueLabel
@onready var day_label: Label = $Margin/Row/TimeGroup/DayLabel
@onready var phase_name_label: Label = $Margin/Row/TimeGroup/PhaseGroup/PhaseNameLabel
@onready var phase_dots: Array[Panel] = [
	$Margin/Row/TimeGroup/PhaseGroup/PhaseDots/PhaseDot1,
	$Margin/Row/TimeGroup/PhaseGroup/PhaseDots/PhaseDot2,
	$Margin/Row/TimeGroup/PhaseGroup/PhaseDots/PhaseDot3,
]
@onready var speed_btns: Array[Button] = [
	$Margin/Row/TimeGroup/SpeedControls/PauseBtn,
	$Margin/Row/TimeGroup/SpeedControls/Speed1Btn,
	$Margin/Row/TimeGroup/SpeedControls/Speed2Btn,
	$Margin/Row/TimeGroup/SpeedControls/Speed4Btn,
]

# Local mirror of TimeManager.current_speed kept purely for visual paint.
# Never set this directly — speed flows through EventBus.speed_change_requested
# → TimeManager._on_speed_change_requested → TimeManager.speed_changed →
# _on_time_manager_speed_changed (round-trip). That round-trip is what keeps
# the indicator honest after event-pause restore, build commits, etc.
var current_speed: int = 1  # 0=pause, 1=1x, 2=2x, 3=4x

# Stylebox refs captured at design time, swapped at runtime
var _dot_active: StyleBoxFlat
var _dot_dim: StyleBoxFlat
var _btn_active: StyleBoxFlat
var _btn_idle: StyleBoxFlat


func _ready() -> void:
	# Capture the styleboxes the scene already has: dot1 / btn1 = active,
	# dot2 / btn0 = idle. Use these references when swapping state.
	_dot_active = phase_dots[0].get_theme_stylebox("panel")
	_dot_dim = phase_dots[1].get_theme_stylebox("panel")
	_btn_active = speed_btns[1].get_theme_stylebox("normal")
	_btn_idle = speed_btns[0].get_theme_stylebox("normal")

	# Initial paint from current GameState
	_refresh_all()

	# Subscribe to state changes (TECH_SPEC §13.3 — tree-enter)
	EventBus.cash_changed.connect(_on_cash_changed)
	EventBus.mrr_changed.connect(_on_mrr_changed)
	EventBus.burn_changed.connect(_on_burn_changed)
	EventBus.runway_recalculated.connect(_on_runway_changed)
	EventBus.brand_changed.connect(_on_brand_changed)
	EventBus.reputation_changed.connect(_on_reputation_changed)
	EventBus.day_advanced.connect(_on_day_advanced)
	EventBus.hour_changed.connect(_on_hour_changed)
	EventBus.phase_changed.connect(_on_phase_changed)
	TimeManager.speed_changed.connect(_on_time_manager_speed_changed)
	# Initial sync — TimeManager's _ready ran first (autoload order) and the
	# field is whatever it landed on (default 1, or main.gd may have already
	# emitted 0 to pause for onboarding before we got here).
	current_speed = TimeManager.current_speed

	for i in speed_btns.size():
		speed_btns[i].pressed.connect(_on_speed_button.bind(i))


func _exit_tree() -> void:
	EventBus.cash_changed.disconnect(_on_cash_changed)
	EventBus.mrr_changed.disconnect(_on_mrr_changed)
	EventBus.burn_changed.disconnect(_on_burn_changed)
	EventBus.runway_recalculated.disconnect(_on_runway_changed)
	EventBus.brand_changed.disconnect(_on_brand_changed)
	EventBus.reputation_changed.disconnect(_on_reputation_changed)
	EventBus.day_advanced.disconnect(_on_day_advanced)
	EventBus.hour_changed.disconnect(_on_hour_changed)
	EventBus.phase_changed.disconnect(_on_phase_changed)
	TimeManager.speed_changed.disconnect(_on_time_manager_speed_changed)


# --- Refresh helpers ---

func _refresh_all() -> void:
	company_name_label.text = GameState.company_name
	_on_cash_changed(GameState.cash)
	_on_mrr_changed(GameState.mrr)
	_on_burn_changed(GameState.daily_burn)
	_on_runway_changed(GameState.get_runway_months())
	_on_brand_changed(GameState.brand)
	_on_reputation_changed(GameState.reputation)
	_update_day_label()
	_on_phase_changed(GameState.phase)
	_apply_speed_visual(current_speed)


# --- Signal handlers ---

func _on_cash_changed(value: int) -> void:
	cash_value_label.text = _fmt_money(value)
	_refresh_cash_delta()

func _refresh_cash_delta() -> void:
	# Cash daily delta = projected net flow tomorrow. Color tints by sign.
	var net: int = GameState.get_net_daily_flow()
	var sign_str: String
	var color: Color
	if net > 0:
		sign_str = "+"
		color = UiTokens.POSITIVE
	elif net < 0:
		sign_str = "-"
		color = UiTokens.NEGATIVE
	else:
		sign_str = ""
		color = UiTokens.TEXT_MUTED
	cash_delta_label.text = "%s%s/d" % [sign_str, _fmt_money(absi(net))]
	cash_delta_label.add_theme_color_override("font_color", color)

func _on_mrr_changed(value: int) -> void:
	mrr_value_label.text = _fmt_money(value)
	# No per-day MRR delta tracking yet; structural placeholder per UI mini-spec.
	mrr_delta_label.text = "+$0/d"
	# Net flow depends on MRR too — refresh both Net column and Cash delta.
	_refresh_net()
	_refresh_cash_delta()

func _on_burn_changed(value: int) -> void:
	burn_value_label.text = "-%s/d" % _fmt_money(value)
	_refresh_net()
	_refresh_cash_delta()

func _refresh_net() -> void:
	# Derived from GameState.mrr and GameState.daily_burn. _fmt_money is unsigned;
	# sign branching lives here.
	var net: int = GameState.get_net_daily_flow()
	var sign_str: String
	if net > 0:
		sign_str = "+"
	elif net < 0:
		sign_str = "-"
	else:
		sign_str = ""
	net_value_label.text = "%s%s/d" % [sign_str, _fmt_money(absi(net))]

func _on_runway_changed(months: float) -> void:
	runway_value_label.text = "∞" if months == INF else "%.1fmo" % months

func _on_brand_changed(value: int) -> void:
	brand_value_label.text = "%d" % value

func _on_reputation_changed(value: int) -> void:
	rep_value_label.text = "%d" % value

func _on_day_advanced(_new_day: int) -> void:
	# Day + hour formatted together; reads current_hour from GameState (which
	# was reset to 0 just before advance_day, see TimeManager._drain_boundaries).
	_update_day_label()

func _on_hour_changed(_hour: int) -> void:
	_update_day_label()

func _update_day_label() -> void:
	# In-fiction date per UI overhaul mini-spec (e.g. "Wed, Jan 1 · 09:00").
	day_label.text = "%s · %02d:00" % [GameState.get_display_date(), GameState.current_hour]

func _on_phase_changed(new_phase: int) -> void:
	var idx: int = clampi(new_phase - 1, 0, PHASE_NAMES.size() - 1)
	phase_name_label.text = PHASE_NAMES[idx]
	for i in phase_dots.size():
		phase_dots[i].add_theme_stylebox_override(
			"panel",
			_dot_active if i <= idx else _dot_dim
		)


func _on_speed_button(idx: int) -> void:
	# Don't paint here — round-trip through TimeManager and let speed_changed
	# repaint us. Otherwise post-event restore or other speed changers leave
	# the indicator stale (the original bug).
	EventBus.speed_change_requested.emit(idx)


func _on_time_manager_speed_changed(new_speed: int) -> void:
	current_speed = new_speed
	_apply_speed_visual(new_speed)


func _apply_speed_visual(active_idx: int) -> void:
	for i in speed_btns.size():
		speed_btns[i].add_theme_stylebox_override(
			"normal",
			_btn_active if i == active_idx else _btn_idle
		)


# --- Formatting ---

func _fmt_money(value: int) -> String:
	if absi(value) >= 1000000:
		return "$%.1fM" % (value / 1000000.0)
	if absi(value) >= 1000:
		return "$%.0fK" % (value / 1000.0)
	return "$%d" % value
