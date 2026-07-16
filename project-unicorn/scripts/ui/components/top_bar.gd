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
@onready var mrr_value_label: Label = $Margin/Row/FinanceGroup/StatCol_MRR/ValueLabel
@onready var burn_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Burn/ValueRow/ValueLabel
@onready var net_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Net/ValueRow/ValueLabel
@onready var runway_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Runway/ValueRow/ValueLabel
@onready var runway_unit_label: Label = $Margin/Row/FinanceGroup/StatCol_Runway/ValueRow/UnitLabel
@onready var brand_value_label: Label = $Margin/Row/ReputationGroup/StatCol_Brand/ValueLabel
@onready var rep_value_label: Label = $Margin/Row/ReputationGroup/StatCol_Rep/ValueLabel
@onready var day_label: Label = $Margin/Row/TimeGroup/DayLabel
@onready var shutter_label: Label = $Margin/Row/TimeGroup/ShutterLabel
@onready var offer_label: Label = $Margin/Row/TimeGroup/OfferLabel
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

# Active/idle look is driven by theme type variations (master_theme.tres):
# PhaseDotActive/PhaseDotDim and SpeedButtonActive/SpeedButton.


func _ready() -> void:
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
	EventBus.shutter_changed.connect(_on_shutter_changed)
	EventBus.offer_countdown_changed.connect(_on_offer_countdown_changed)
	TimeManager.speed_changed.connect(_on_time_manager_speed_changed)
	EventBus.language_changed.connect(_on_language_changed)
	# Kepenk counter is danger-red on the dark chrome (bright variant for contrast).
	shutter_label.add_theme_color_override("font_color", UiTokens.NEGATIVE_BRIGHT)
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
	EventBus.shutter_changed.disconnect(_on_shutter_changed)
	EventBus.offer_countdown_changed.disconnect(_on_offer_countdown_changed)
	TimeManager.speed_changed.disconnect(_on_time_manager_speed_changed)
	EventBus.language_changed.disconnect(_on_language_changed)


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
	_on_shutter_changed(GameState.shutter_days_left)
	_apply_speed_visual(current_speed)


# --- Signal handlers ---

func _on_cash_changed(value: int) -> void:
	cash_value_label.text = _fmt_cash_full(value)   # full number w/ separators (not abbreviated)

func _on_mrr_changed(value: int) -> void:
	mrr_value_label.text = _fmt_money(value)
	_refresh_net()  # net = mrr − burn

func _on_burn_changed(value: int) -> void:
	# Burn is a daily cost; caption + dim "/d" unit convey the rate (value stays cream).
	burn_value_label.text = _fmt_money(value)
	_refresh_net()

func _refresh_net() -> void:
	# Net daily flow (mrr − burn), sign-colored on the dark chrome. The "/d" unit
	# is a static dim suffix in the scene.
	var net: int = GameState.get_net_daily_flow()
	var sign_str: String = "+" if net > 0 else ("-" if net < 0 else "")
	net_value_label.text = "%s%s" % [sign_str, _fmt_money(absi(net))]
	net_value_label.add_theme_color_override("font_color", UiTokens.delta_color_bright(net))

func _on_runway_changed(months: float) -> void:
	# Net runway (Package 5): profitable (net_burn ≤ 0) → status word ("Kârlı"), unit hidden;
	# else whole months. All formatting/localization lives in UiTokens.net_runway_parts.
	var p: Dictionary = UiTokens.net_runway_parts(months)
	runway_value_label.text = String(p.value)
	runway_unit_label.text = String(p.unit)
	runway_unit_label.visible = String(p.unit) != ""


func _on_language_changed(_locale: String) -> void:
	# Re-translate live surfaces (the runway status word) on a language switch.
	_refresh_all()

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
	day_label.text = "%s · %02d:00" % [GameState.get_display_date(true), GameState.current_hour]

func _on_shutter_changed(days_left: int) -> void:
	# Kepenk counter (ENDGAME_DESIGN.md §4.3): visible red countdown while cash
	# is under zero. -1 = inactive/cleared → hidden.
	shutter_label.visible = days_left >= 0
	if days_left >= 0:
		shutter_label.text = "KEPENK: %d GÜN" % days_left

func _on_offer_countdown_changed(days_left: int) -> void:
	# Term-sheet validity chip (Spec 4 / ledger 14): shown only when the soonest sheet
	# is ≤ WARNING_DAYS. Amber above 1 day, red on the last day. -1 = hide.
	offer_label.visible = days_left >= 0
	if days_left >= 0:
		offer_label.text = "TEKLİF: %d GÜN" % days_left
		offer_label.add_theme_color_override("font_color", UiTokens.ACCENT if days_left > 1 else UiTokens.NEGATIVE_BRIGHT)

func _on_phase_changed(new_phase: int) -> void:
	var idx: int = clampi(new_phase - 1, 0, PHASE_NAMES.size() - 1)
	phase_name_label.text = PHASE_NAMES[idx].to_upper()
	for i in phase_dots.size():
		phase_dots[i].theme_type_variation = &"PhaseDotActive" if i <= idx else &"PhaseDotDim"


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
		speed_btns[i].theme_type_variation = &"SpeedButtonActive" if i == active_idx else &"SpeedButton"


# --- Formatting ---

# MRR/BURN/NET stay abbreviated (K/M) so they can't widen FinanceGroup and shove the speed
# controls. One decimal below $10K keeps MRR precise ("$3.5K"), no decimal above ("$50K",
# "$350K"), M above a million ("$1.2M").
func _fmt_money(value: int) -> String:
	var a: int = absi(value)
	if a >= 1000000:
		return "$%.1fM" % (value / 1000000.0)
	if a >= 10000:
		return "$%.0fK" % (value / 1000.0)
	if a >= 1000:
		return "$%.1fK" % (value / 1000.0)
	return "$%d" % value


# CASH is shown in FULL with thousands separators (Erdem: money management is precise, wants
# the exact figure) — "$12,340", "$1,234,567". Godot has no locale grouping, so group manually.
# The StatCol_Cash width bound (+ clip_text) keeps even 7-digit values from shoving the chrome.
func _fmt_cash_full(value: int) -> String:
	var digits: String = str(absi(value))
	var out: String = ""
	var c: int = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return ("-$" if value < 0 else "$") + out
