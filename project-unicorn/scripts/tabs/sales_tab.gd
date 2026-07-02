extends Control

# Sales tab — PostShip spec §G. Mounted into CenterViewport by center_viewport.gd
# when the "sales" tab is selected. Two columns: Prospects (with Pitch /
# Find Prospects) and Customers, plus a metrics line. Rebuilds rows on the
# relevant EventBus signals. The pitch itself runs in PitchDialogueModal via
# EventBus.pitch_requested (main.gd mounts it).

const FIND_PROSPECTS_COOLDOWN_DAYS := 5
const FIND_PROSPECTS_COUNT := 2

# Light-surface row text (Sales tab renders on the light body).
const C_CREAM := UiTokens.INK
const C_DIM := UiTokens.INK_MUTED
const C_SUBDUED := UiTokens.INK_DIM

@onready var metrics_label: Label = $Margin/Layout/TitleBar/MetricsLabel
@onready var find_button: Button = $Margin/Layout/Columns/ProspectsPanel/PVBox/PHeader/FindButton
@onready var prospects_list: VBoxContainer = $Margin/Layout/Columns/ProspectsPanel/PVBox/ProspectsScroll/ProspectsList
@onready var prospects_empty: Label = $Margin/Layout/Columns/ProspectsPanel/PVBox/ProspectsEmpty
@onready var customers_list: VBoxContainer = $Margin/Layout/Columns/CustomersPanel/CVBox/CustomersScroll/CustomersList
@onready var customers_empty: Label = $Margin/Layout/Columns/CustomersPanel/CVBox/CustomersEmpty

var _signals := []


func _ready() -> void:
	find_button.pressed.connect(_on_find_pressed)
	_signals = [
		EventBus.prospect_added, EventBus.prospect_removed,
		EventBus.customer_added, EventBus.customer_removed,
		EventBus.mrr_changed, EventBus.day_advanced, EventBus.pitch_finished,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)


func _on_state_changed(_a = null) -> void:
	_refresh()


func _refresh() -> void:
	_refresh_metrics()
	_refresh_prospects()
	_refresh_customers()


func _refresh_metrics() -> void:
	var sat: int = CustomerRegistry.get_min_satisfaction()
	# MRR-led, market-aware count (Faz 1 bug 1.5): B2C's base is one aggregate
	# record whose seats are the paying users, so showing the record count (1)
	# contradicted the "ödeyen kullanıcı" seats figure elsewhere. Show seats for
	# B2C, real account count for B2B.
	if String(GameState.get_flag("mvp_market_type", "")) == "b2c":
		metrics_label.text = "MRR $%d · %d ödeyen kullanıcı · en düşük memnuniyet %d" % [GameState.mrr, CustomerRegistry.get_total_users(), sat]
	else:
		metrics_label.text = "MRR $%d · %d müşteri · en düşük memnuniyet %d" % [GameState.mrr, CustomerRegistry.get_active().size(), sat]


func _refresh_prospects() -> void:
	for c in prospects_list.get_children():
		c.queue_free()
	var prospects: Array[Prospect] = ProspectRegistry.get_all()
	var is_b2b: bool = String(GameState.get_flag("mvp_market_type", "")) == "b2b"
	# Find Prospects is a B2B action; cooldown-gated.
	find_button.visible = is_b2b
	var on_cooldown: bool = GameState.day < int(GameState.get_flag("next_find_prospects_day", 0))
	find_button.disabled = on_cooldown
	find_button.text = "+ Prospect bul" if not on_cooldown else "Cooldown…"

	prospects_empty.visible = prospects.is_empty()
	var can_pitch: bool = PitchSystem.can_pitch()
	for p in prospects:
		prospects_list.add_child(_build_prospect_row(p, can_pitch))


func _build_prospect_row(p: Prospect, can_pitch: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(_label(p.company_name, C_CREAM, 13))
	var stars: String = "★".repeat(maxi(p.difficulty_stars, 0))
	col.add_child(_label("%s · %s · %s" % [_archetype_tr(p.archetype), stars, p.need_summary], C_DIM, 11, true))
	row.add_child(col)
	var btn := Button.new()
	btn.text = "Pitch"
	btn.disabled = not can_pitch
	btn.pressed.connect(func(): EventBus.pitch_requested.emit(p.id))
	row.add_child(btn)
	return row


func _refresh_customers() -> void:
	for c in customers_list.get_children():
		c.queue_free()
	var custs: Array[Customer] = CustomerRegistry.get_active()
	customers_empty.visible = custs.is_empty()
	for cust in custs:
		customers_list.add_child(_build_customer_row(cust))


func _build_customer_row(c: Customer) -> Control:
	var col := VBoxContainer.new()
	col.add_child(_label(c.company_name, C_CREAM, 13))
	col.add_child(_label("$%d/ay · %s · %s" % [c.mrr, _health_tr(c.health), _source_tr(c.acquisition_source)], C_DIM, 11, true))
	return col


# --- Find Prospects action ---

func _on_find_pressed() -> void:
	if GameState.day < int(GameState.get_flag("next_find_prospects_day", 0)):
		return
	for i in FIND_PROSPECTS_COUNT:
		# Bootstrap leans small; an occasional mid based on the day for variety.
		var archetype: String = "mid" if (GameState.day + i) % 3 == 0 else "small"
		PitchSystem.spawn_prospect(archetype, "find")
	GameState.set_flag("next_find_prospects_day", GameState.day + FIND_PROSPECTS_COOLDOWN_DAYS)
	_refresh()


# --- Helpers ---

func _label(content: String, color: Color, fsize: int, do_wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = content
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", fsize)
	if do_wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _archetype_tr(a: String) -> String:
	match a:
		"enterprise": return "Enterprise"
		"mid": return "Orta ölçek"
		"individual": return "Bireysel"
		_: return "Küçük işletme"


func _health_tr(h: String) -> String:
	match h:
		"healthy": return "sağlıklı"
		"at_risk": return "riskli"
		"churning": return "kaçıyor"
		_: return h


func _source_tr(s: String) -> String:
	match s:
		"founder_pitch": return "pitch"
		"organic": return "organik"
		"referral": return "referans"
		"event": return "fırsat"
		_: return s if s != "" else "—"
