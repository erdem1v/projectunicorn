extends Panel

# Actor panel per PROJECT_SPEC §5 + TECH_SPEC §5.2 / §11.3.
# Five stacked sections: Mentor / Top Customers / Active Rivals /
# Upcoming Events / Cap Table.
#
# Real-data policy (mini-spec §4):
#  - Read from GameState where a field exists (company_name).
#  - Hardcode placeholder text in the TSCN for unbuilt systems.
#  - Wire only existing EventBus signals (day_advanced). Do not invent
#    speculative customer/rival/cap-table signals — they belong to systems
#    that aren't built yet.
#
# TODO when mentor quote system comes online:
#   - Connect EventBus.mentor_quote_changed (declared by future mentor system)
# TODO when customer health system comes online:
#   - Connect EventBus.customer_health_changed and repaint health dots
#     (currently hardcoded green/yellow in RightPanel.tscn)
# Rivals are now registry-backed (Product Lifecycle Part 1): rows come from
# RivalRegistry.get_by_type(active_sub_type); wired to rival_added/advanced/
# status_changed. (Rival AI decisions are still Tier 2 — momentum only for now.)
# TODO when EventManager exposes upcoming queue:
#   - Build rows from EventManager.get_upcoming(14)
# TODO when funding system comes online:
#   - Update cap table bar + legend from GameState.cap_table

const UPCOMING_WINDOW := 14  # days

@onready var mentor_name_label: Label = $Scroll/Margin/Sections/MentorSection/MentorBody/MentorTextCol/NameLabel
@onready var mentor_quote_label: Label = $Scroll/Margin/Sections/MentorSection/QuoteLabel
@onready var customers_count_label: Label = $Scroll/Margin/Sections/CustomersSection/HeaderRow/CountLabel
@onready var customer_row_1_name: Label = $Scroll/Margin/Sections/CustomersSection/Customer1/Col/NameLabel
@onready var customer_row_1_meta: Label = $Scroll/Margin/Sections/CustomersSection/Customer1/Col/MetaLabel
@onready var customer_row_2_name: Label = $Scroll/Margin/Sections/CustomersSection/Customer2/Col/NameLabel
@onready var customer_row_2_meta: Label = $Scroll/Margin/Sections/CustomersSection/Customer2/Col/MetaLabel
@onready var customer_row_3_name: Label = $Scroll/Margin/Sections/CustomersSection/Customer3/Col/NameLabel
@onready var customer_row_3_meta: Label = $Scroll/Margin/Sections/CustomersSection/Customer3/Col/MetaLabel
@onready var customer_rows: Array[HBoxContainer] = [
	$Scroll/Margin/Sections/CustomersSection/Customer1,
	$Scroll/Margin/Sections/CustomersSection/Customer2,
	$Scroll/Margin/Sections/CustomersSection/Customer3,
]
@onready var customers_empty_label: Label = $Scroll/Margin/Sections/CustomersSection/EmptyStateLabel
@onready var rival_rows: Array[HBoxContainer] = [
	$Scroll/Margin/Sections/RivalsSection/Rival1,
	$Scroll/Margin/Sections/RivalsSection/Rival2,
	$Scroll/Margin/Sections/RivalsSection/Rival3,
]
@onready var rivals_count_label: Label = $Scroll/Margin/Sections/RivalsSection/HeaderRow/CountLabel
@onready var rivals_empty_label: Label = $Scroll/Margin/Sections/RivalsSection/EmptyStateLabel
@onready var events_header_label: Label = $Scroll/Margin/Sections/EventsSection/HeaderRow/HeaderLabel
@onready var event_rows: Array[HBoxContainer] = [
	$Scroll/Margin/Sections/EventsSection/Event1,
	$Scroll/Margin/Sections/EventsSection/Event2,
	$Scroll/Margin/Sections/EventsSection/Event3,
]
@onready var events_empty_label: Label = $Scroll/Margin/Sections/EventsSection/EmptyStateLabel
@onready var captable_founder_label: Label = $Scroll/Margin/Sections/CapTableSection/Legend/FounderRow/FounderLabel
@onready var captable_employees_equity_row: HBoxContainer = $Scroll/Margin/Sections/CapTableSection/Legend/EmployeesWithEquityRow
@onready var captable_employees_equity_label: Label = $Scroll/Margin/Sections/CapTableSection/Legend/EmployeesWithEquityRow/EmployeesEquityLabel


func _ready() -> void:
	# Initial paint — populate the values we actually have.
	_refresh_static_from_state()
	_refresh_events_header(GameState.day)
	_refresh_events_visibility(GameState.day)

	# Subscribe to existing EventBus signals only (TECH_SPEC §13.3)
	EventBus.day_advanced.connect(_on_day_advanced)
	EventBus.character_added.connect(_on_character_changed)
	EventBus.character_removed.connect(_on_character_changed)
	EventBus.customer_added.connect(_on_customer_changed)
	EventBus.customer_removed.connect(_on_customer_changed)
	EventBus.customer_mrr_changed.connect(_on_customer_field_changed)
	EventBus.customer_seats_changed.connect(_on_customer_field_changed)
	# Frank's advisory line — updated by PostShip intro/customer/traction events.
	EventBus.mentor_advisory_changed.connect(_on_mentor_advisory_changed)
	# Rivals (Product Lifecycle Part 1) — registry-backed now.
	EventBus.rival_added.connect(_on_rival_changed)
	EventBus.rival_advanced.connect(_refresh_rivals)
	EventBus.rival_status_changed.connect(_on_rival_status_changed)
	# Repaint the rival league when the build/ship state moves the active sub-type.
	EventBus.build_phase_changed.connect(_on_build_phase_changed)


func _exit_tree() -> void:
	EventBus.day_advanced.disconnect(_on_day_advanced)
	EventBus.character_added.disconnect(_on_character_changed)
	EventBus.character_removed.disconnect(_on_character_changed)
	EventBus.customer_added.disconnect(_on_customer_changed)
	EventBus.customer_removed.disconnect(_on_customer_changed)
	EventBus.customer_mrr_changed.disconnect(_on_customer_field_changed)
	EventBus.customer_seats_changed.disconnect(_on_customer_field_changed)
	EventBus.mentor_advisory_changed.disconnect(_on_mentor_advisory_changed)
	EventBus.rival_added.disconnect(_on_rival_changed)
	EventBus.rival_advanced.disconnect(_refresh_rivals)
	EventBus.rival_status_changed.disconnect(_on_rival_status_changed)
	EventBus.build_phase_changed.disconnect(_on_build_phase_changed)


func _on_mentor_advisory_changed(text: String) -> void:
	mentor_quote_label.text = "\"%s\"" % text


func _on_customer_field_changed(_customer_id: String, _new_value: int) -> void:
	# Live seat/MRR mutation on an existing account → repaint the Top Customers list.
	_refresh_customers()


# --- Refresh helpers ---

func _refresh_static_from_state() -> void:
	# Mentor name from CharacterRegistry (single source of truth). Null-guard
	# so the panel never goes blank if the registry is empty during early dev;
	# the .tscn literal stays as a static editor preview.
	var mentor: Character = CharacterRegistry.get_mentor()
	if mentor != null:
		mentor_name_label.text = mentor.character_name

	_refresh_customers()
	_refresh_rivals()

	# Cap table founder line includes company name from GameState.
	_refresh_captable()


func _refresh_customers() -> void:
	# Top customers from CustomerRegistry. .tscn literals stay as editor preview;
	# overwritten at _ready time. Health dots stay as static colors until the
	# customer health system is built (see TODO above).
	var top: Array[Customer] = CustomerRegistry.get_top_customers(3)
	var active_count: int = CustomerRegistry.get_active().size()
	customers_count_label.text = "%d of %d" % [top.size(), active_count]
	if active_count == 0:
		for row in customer_rows:
			row.visible = false
		customers_empty_label.visible = true
		return
	customers_empty_label.visible = false
	var row_names: Array[Label] = [customer_row_1_name, customer_row_2_name, customer_row_3_name]
	var row_metas: Array[Label] = [customer_row_1_meta, customer_row_2_meta, customer_row_3_meta]
	for i in range(customer_rows.size()):
		customer_rows[i].visible = (i < top.size())
		if i < top.size():
			var c: Customer = top[i]
			row_names[i].text = c.company_name
			row_metas[i].text = "$%.1fK · %d seats" % [c.mrr / 1000.0, c.seats]
			var initial: Label = customer_rows[i].get_node("Avatar/Initial")
			initial.text = c.company_name.substr(0, 1).to_upper() if c.company_name != "" else "?"
			# Health dots: green placeholder until the customer-health system lands.
			_paint_dot(customer_rows[i].get_node("HealthDot"), UiTokens.HEALTH_GREEN)


func _paint_dot(panel: Panel, color: Color) -> void:
	# Token-driven status dot (replaces inline circular styleboxes).
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", sb)


func _on_rival_changed(_rival_id: String = "") -> void:
	_refresh_rivals()


func _on_rival_status_changed(_rival_id: String, _status: String) -> void:
	_refresh_rivals()


func _on_build_phase_changed(_new_phase: String) -> void:
	_refresh_rivals()


func _refresh_rivals() -> void:
	# Registry-backed (Product Lifecycle Part 1). Show the strongest rivals in the
	# active/shipped sub-type (giant on top = who dominates); the header count slot
	# carries the player's startup-league rank "N/M".
	var sub: String = _active_sub_type_id()
	var list: Array[Rival] = RivalRegistry.get_by_type(sub) if sub != "" else ([] as Array[Rival])
	if list.is_empty():
		for row in rival_rows:
			row.visible = false
		rivals_count_label.text = "0"
		rivals_empty_label.visible = true
		return
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	list.sort_custom(func(a, b): return a.composite(axes) > b.composite(axes))
	rivals_empty_label.visible = false
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, _player_composite(sub))
	rivals_count_label.text = "%d/%d" % [int(rank["rank"]), int(rank["total"])]
	for i in range(rival_rows.size()):
		rival_rows[i].visible = i < list.size()
		if i < list.size():
			var r: Rival = list[i]
			(rival_rows[i].get_node("Col/NameLabel") as Label).text = r.product_name
			(rival_rows[i].get_node("Col/StatusLabel") as Label).text = r.status


func _active_sub_type_id() -> String:
	# Active build → shipped snapshot → first type of the founder's subgenre.
	var b = ProductSystem.get_active_build()
	if b != null and b.sub_product_type_id != "":
		return b.sub_product_type_id
	var shipped: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	if shipped != "":
		return shipped
	var types: Array = ProductCatalog.get_sub_product_types(GameState.subgenre)
	return String(types[0].get("id", "")) if not types.is_empty() else ""


func _player_composite(sub: String) -> float:
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var b = ProductSystem.get_active_build()
	if b != null:
		return QualityModel.composite_quality(QualityModel.economy_dims_from_build(b), axes)
	if GameState.get_flag("mvp_shipped", false):
		return QualityModel.shipped_composite()
	return 0.0


func _refresh_events_header(current_day: int) -> void:
	events_header_label.text = "UPCOMING — DAY %d TO %d" % [current_day, current_day + UPCOMING_WINDOW]


func _refresh_events_visibility(_current_day: int) -> void:
	# Until EventManager.get_upcoming(14) lands (see TODO at top), hide all
	# hardcoded sample rows and show the empty-state label unconditionally.
	for row in event_rows:
		row.visible = false
	events_empty_label.visible = true


# --- Signal handlers ---

func _on_day_advanced(new_day: int) -> void:
	_refresh_events_header(new_day)
	_refresh_events_visibility(new_day)


func _on_character_changed(_id: String) -> void:
	_refresh_captable()


func _on_customer_changed(_id: String) -> void:
	_refresh_customers()


func _refresh_captable() -> void:
	var founder_pct: int = int(round(GameState.get_founder_equity() * 100.0))
	captable_founder_label.text = "Founder · %d%%" % founder_pct

	var count: int = 0
	for emp in CharacterRegistry.get_employees():
		if emp.equity_pct > 0.0:
			count += 1
	if count > 0:
		var noun: String = "employee" if count == 1 else "employees"
		captable_employees_equity_label.text = "%d %s with equity" % [count, noun]
		captable_employees_equity_row.visible = true
	else:
		captable_employees_equity_row.visible = false
