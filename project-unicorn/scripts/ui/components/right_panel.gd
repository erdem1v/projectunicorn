extends Panel

# Actor panel per PROJECT_SPEC §5 + TECH_SPEC §5.2 / §11.3.
# Stacked sections: Build (while a build exists) / Mentor / Top Customers /
# Active Rivals / Upcoming Events / Cap Table.
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
#     (currently placeholder green — see _make_customer_row)
# Rivals are now registry-backed (Product Lifecycle Part 1): rows come from
# RivalRegistry.get_by_type(active_sub_type); wired to rival_added/advanced/
# status_changed. (Rival AI decisions are still Tier 2 — momentum only for now.)
# TODO when EventManager exposes upcoming queue:
#   - Build rows from EventManager.get_upcoming(14)
# TODO when funding system comes online:
#   - Update cap table bar + legend from GameState.cap_table
#
# BUILD SECTION (C-kutu — replaces the retired BuildHUD desk overlay):
# A persistent, Software-Inc-style monitor box at the TOP of the panel, visible
# whenever ANY build exists — first builds, v2/v3 version builds, AND bug
# sprints (the old BuildHUD hid on is_bug_sprint; this one shows sprint state).
# Multi-build-ready: _paint_builds(builds) paints N self-contained entry-cards
# from a list; today the list is [ProductSystem.get_active_build()] (null
# filtered), later multiple products feed the same box. Decision buttons are
# full-width rows INSIDE the card (VBox children — structurally cannot overlap
# sibling text, which was the designer's complaint about the old overlay) and
# call the existing ProductSystem.advance_iteration()/enter_development()/
# launch() API. Zero build/economy logic here — visibility + buttons only.

const UPCOMING_WINDOW := 14  # days
# B2: sanity cap for the dynamic customer list (counter stays honest: shows
# "first N of M" when M exceeds the cap; every customer up to 12 is listed).
const MAX_CUSTOMER_ROWS := 12

@onready var mentor_name_label: Label = $Scroll/Margin/Sections/MentorSection/MentorBody/MentorTextCol/NameLabel
@onready var mentor_quote_label: Label = $Scroll/Margin/Sections/MentorSection/QuoteLabel
@onready var sections_box: VBoxContainer = $Scroll/Margin/Sections
@onready var customers_count_label: Label = $Scroll/Margin/Sections/CustomersSection/HeaderRow/CountLabel
@onready var customer_rows_box: VBoxContainer = $Scroll/Margin/Sections/CustomersSection/Rows
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

# --- Build section state (code-built; see header comment) ---
var _build_section: VBoxContainer = null
var _build_sep: ColorRect = null
var _build_cards_box: VBoxContainer = null
# Per-card mutable-node refs (index-aligned with the painted builds list).
var _build_card_refs: Array = []
# Structural signature of the painted cards; when unchanged we update labels
# in place instead of rebuilding nodes (keeps buttons alive across hourly
# build_progress_changed repaints — a mid-press rebuild would eat the click).
var _build_signature: Array = []


func _ready() -> void:
	_create_build_section()

	# Initial paint — populate the values we actually have.
	_refresh_static_from_state()
	_refresh_events_header(GameState.day)
	_refresh_events_visibility(GameState.day)
	_refresh_build_section()

	# Subscribe to existing EventBus signals only (TECH_SPEC §13.3)
	EventBus.day_advanced.connect(_on_day_advanced)
	EventBus.character_added.connect(_on_character_changed)
	EventBus.character_removed.connect(_on_character_changed)
	EventBus.customer_added.connect(_on_customer_changed)
	EventBus.customer_removed.connect(_on_customer_changed)
	# Frank's advisory line — updated by PostShip intro/customer/traction events.
	EventBus.mentor_advisory_changed.connect(_on_mentor_advisory_changed)
	# Rivals (Product Lifecycle Part 1) — registry-backed now.
	EventBus.rival_added.connect(_on_rival_changed)
	EventBus.rival_advanced.connect(_refresh_rivals)
	EventBus.rival_status_changed.connect(_on_rival_status_changed)
	# Repaint the rival league when the build/ship state moves the active sub-type;
	# also drives the build section's show/hide + phase repaint.
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	# Build section live updates (mirrors the retired BuildHUD's subscriptions).
	EventBus.build_progress_changed.connect(_on_build_progress_changed)
	EventBus.build_iteration_decision_pending.connect(_on_build_decision_pending)


func _exit_tree() -> void:
	EventBus.day_advanced.disconnect(_on_day_advanced)
	EventBus.character_added.disconnect(_on_character_changed)
	EventBus.character_removed.disconnect(_on_character_changed)
	EventBus.customer_added.disconnect(_on_customer_changed)
	EventBus.customer_removed.disconnect(_on_customer_changed)
	EventBus.mentor_advisory_changed.disconnect(_on_mentor_advisory_changed)
	EventBus.rival_added.disconnect(_on_rival_changed)
	EventBus.rival_advanced.disconnect(_refresh_rivals)
	EventBus.rival_status_changed.disconnect(_on_rival_status_changed)
	EventBus.build_phase_changed.disconnect(_on_build_phase_changed)
	EventBus.build_progress_changed.disconnect(_on_build_progress_changed)
	EventBus.build_iteration_decision_pending.disconnect(_on_build_decision_pending)


func _on_mentor_advisory_changed(text: String) -> void:
	mentor_quote_label.text = "\"%s\"" % text


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
	# B2: dynamic list — ALL active customers render as code-built rows (MRR-desc
	# from get_top_customers; registry sorting untouched), capped at
	# MAX_CUSTOMER_ROWS for sanity. Counter stays consistent: visible N of M.
	var top: Array[Customer] = CustomerRegistry.get_top_customers(MAX_CUSTOMER_ROWS)
	var active_count: int = CustomerRegistry.get_active().size()
	customers_count_label.text = "%d of %d" % [top.size(), active_count]
	for child in customer_rows_box.get_children():
		customer_rows_box.remove_child(child)
		child.queue_free()
	if active_count == 0:
		customers_empty_label.visible = true
		return
	customers_empty_label.visible = false
	for c in top:
		customer_rows_box.add_child(_make_customer_row(c))


func _make_customer_row(c: Customer) -> HBoxContainer:
	# Row template (replaces the 3 authored Customer1..3 rows): avatar initial +
	# name/meta column + health dot. Same variations the .tscn rows carried.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var avatar := Panel.new()
	avatar.custom_minimum_size = Vector2(24, 24)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	avatar.theme_type_variation = &"Avatar"
	var initial := UiFactory.make_label(
		c.company_name.substr(0, 1).to_upper() if c.company_name != "" else "?",
		&"AvatarInitial")
	initial.set_anchors_preset(Control.PRESET_FULL_RECT)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(initial)
	row.add_child(avatar)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", 1)
	col.add_child(UiFactory.make_label(c.company_name, &"RowName"))
	col.add_child(UiFactory.make_label("$%.1fK · %d seats" % [c.mrr / 1000.0, c.seats], &"RowMeta"))
	row.add_child(col)

	# Health dot: green placeholder until the customer-health system lands.
	var dot := UiFactory.make_dot(UiTokens.HEALTH_GREEN, 7)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	return row


func _on_rival_changed(_rival_id: String = "") -> void:
	_refresh_rivals()


func _on_rival_status_changed(_rival_id: String, _status: String) -> void:
	_refresh_rivals()


func _on_build_phase_changed(_new_phase: String) -> void:
	_refresh_rivals()
	_refresh_build_section()


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
	_refresh_build_section()


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


# =========================================================================
#  BUILD SECTION (C-kutu) — persistent build monitor, BuildHUD's replacement
# =========================================================================

func _create_build_section() -> void:
	# Code-built section at the TOP of Sections (active work belongs above the
	# passive monitor sections — working call). Header + accent line mirror the
	# authored sections' grammar; a trailing hairline separates it from Mentor.
	_build_section = VBoxContainer.new()
	_build_section.name = "BuildSection"
	_build_section.visible = false
	_build_section.add_theme_constant_override("separation", 8)
	# Mirror the retired BuildHUD: buttons stay interactive while modals pause
	# the tree (same gotcha as ModalLayer — working call).
	_build_section.process_mode = Node.PROCESS_MODE_ALWAYS
	_build_section.add_child(UiFactory.make_section_header("BUILD"))
	var accent := ColorRect.new()
	accent.custom_minimum_size = Vector2(20, 1)
	accent.size_flags_horizontal = 0
	accent.color = UiTokens.ACCENT
	_build_section.add_child(accent)
	_build_cards_box = VBoxContainer.new()
	_build_cards_box.name = "Cards"
	_build_cards_box.add_theme_constant_override("separation", 8)
	_build_section.add_child(_build_cards_box)

	_build_sep = ColorRect.new()
	_build_sep.custom_minimum_size = Vector2(0, 1)
	_build_sep.color = UiTokens.DIVIDER_LIGHT
	_build_sep.visible = false

	sections_box.add_child(_build_section)
	sections_box.move_child(_build_section, 0)
	sections_box.add_child(_build_sep)
	sections_box.move_child(_build_sep, 1)


func _refresh_build_section() -> void:
	# Today's list = the single active build (null filtered); later multiple
	# products feed the same list-shaped paint. Includes bug sprints — the old
	# BuildHUD hid on is_bug_sprint; this section must not.
	var builds: Array = []
	var b = ProductSystem.get_active_build()
	# Terminal phases filtered: cancel_build()/ship_active_build() emit
	# build_phase_changed BEFORE nulling active_build, so during that emit the
	# build still exists with a dead phase — without this filter the section
	# would keep a phantom card until the next unrelated signal.
	if b != null and not (b.current_phase in ["cancelled", "shipped"]):
		builds.append(b)
	var showing: bool = not builds.is_empty()
	_build_section.visible = showing
	_build_sep.visible = showing
	if not showing:
		_clear_build_cards()
		_build_signature = []
		return
	# Structural signature: rebuild card nodes only when structure changes;
	# otherwise update texts/values in place (hourly build_progress_changed
	# must not free a button mid-click).
	var sig: Array = []
	for bb in builds:
		sig.append([bb.id, bb.current_phase, bb.iteration_decision_pending, _bug_band(bb.bug_count), bb.is_bug_sprint])
	if sig != _build_signature:
		_build_signature = sig
		_paint_builds(builds)
	else:
		for i in range(builds.size()):
			_update_build_card(builds[i], _build_card_refs[i])


func _paint_builds(builds: Array) -> void:
	# Multi-build-ready paint: one self-contained entry-card per build.
	_clear_build_cards()
	for bb in builds:
		var refs: Dictionary = _make_build_card(bb)
		_build_cards_box.add_child(refs["root"])
		_build_card_refs.append(refs)
		_update_build_card(bb, refs)


func _clear_build_cards() -> void:
	for child in _build_cards_box.get_children():
		_build_cards_box.remove_child(child)
		child.queue_free()
	_build_card_refs.clear()


func _make_build_card(b: FeatureBuild) -> Dictionary:
	# Entry-card: header (click → Product tab) → phase+days line → progress bar
	# → dimension climb (skipped for sprints — no axes grow there) → bug chip →
	# decision area (full-width button rows OR one calm status line). Everything
	# stacks in a VBox: nothing can overlay sibling text by construction.
	var refs := {}
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)

	# Header row — click-to-jump to the Product tab (working call).
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	header.gui_input.connect(_on_build_header_gui_input)
	var name_lbl := UiFactory.make_label(_build_display_name(b), &"RowName")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(name_lbl)
	header.add_child(_build_version_badge(b))
	col.add_child(header)

	# Phase + days remaining — one clear line.
	var phase_lbl := UiFactory.make_label("", &"RowMeta")
	phase_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	refs["phase"] = phase_lbl
	col.add_child(phase_lbl)

	# Thin progress bar.
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 6)
	refs["bar"] = bar
	col.add_child(bar)

	# Compact dimension climb — sub-type display labels (ProductCatalog.QUALITY_AXES),
	# economy dims (stability shown EFFECTIVE so bugs drag it live, same as PostShip).
	if not b.is_bug_sprint:
		var labels: Dictionary = _axis_display_labels_for(b.sub_product_type_id)
		var dim_box := VBoxContainer.new()
		dim_box.add_theme_constant_override("separation", 2)
		var dim_refs := {}
		for axis in ["innovation", "stability", "usability"]:
			var drow := HBoxContainer.new()
			drow.add_theme_constant_override("separation", 6)
			var cap := UiFactory.make_label(String(labels.get(axis, axis)), &"RowMeta")
			cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			drow.add_child(cap)
			var val := UiFactory.make_label("0", &"RowName")
			dim_refs[axis] = val
			drow.add_child(val)
			dim_box.add_child(drow)
		refs["dims"] = dim_refs
		col.add_child(dim_box)

	# Bug count chip — only when > 0, severity-colored (UiTokens.bug_severity).
	if b.bug_count > 0:
		var pal: Dictionary = UiTokens.bug_severity(b.bug_count)
		var chip := UiFactory.make_pill("BUG %d" % b.bug_count, pal.bg, pal.fg)
		chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		refs["bug_label"] = chip.get_child(0)
		col.add_child(chip)

	# Decision area: pending → full-width buttons on their own rows (never
	# overlapping anything); otherwise one calm status line.
	if b.current_phase == "iteration" and b.iteration_decision_pending:
		var btn_iter := _make_card_button("Bir iterasyon daha")
		btn_iter.pressed.connect(_on_build_iteration_pressed)
		col.add_child(btn_iter)
		var btn_dev := _make_card_button("Development'a geç")
		btn_dev.pressed.connect(_on_build_development_pressed)
		col.add_child(btn_dev)
	elif b.current_phase in ["bugfix", "polish"]:
		var btn_launch := _make_card_button("Yayınla")
		btn_launch.pressed.connect(_on_build_launch_pressed)
		col.add_child(btn_launch)
	else:
		var status := UiFactory.make_label("", &"CaptionMuted")
		status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		refs["status"] = status
		col.add_child(status)

	refs["root"] = UiFactory.make_card(col, true)
	return refs


func _make_card_button(text: String) -> Button:
	# Full-width row button (base light Button variation from the theme). Its own
	# VBox row inside the card — cannot overlap sibling text by construction.
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return btn


func _update_build_card(b: FeatureBuild, refs: Dictionary) -> void:
	# In-place value refresh (structure untouched — see _refresh_build_section).
	(refs["phase"] as Label).text = _build_phase_line(b)

	var bar := refs["bar"] as ProgressBar
	match b.current_phase:
		"iteration":
			bar.visible = true
			bar.max_value = float(max(1, ProductSystem.ITERATION_LENGTH_DAYS))
			bar.value = float(ProductSystem.ITERATION_LENGTH_DAYS) - b.iteration_days_in_current
		"development", "bug_sprint":
			bar.visible = true
			bar.max_value = float(max(1, b.development_days_total))
			bar.value = b.development_days_elapsed
		_:
			# bugfix is open-ended — the bar would lie about an end date.
			bar.visible = false

	if refs.has("dims"):
		var dims: Dictionary = QualityModel.economy_dims_from_build(b)
		for axis in refs["dims"].keys():
			(refs["dims"][axis] as Label).text = str(int(round(float(dims.get(axis, 0.0)))))

	if refs.has("bug_label"):
		(refs["bug_label"] as Label).text = "BUG %d" % b.bug_count

	if refs.has("status"):
		(refs["status"] as Label).text = _build_status_line(b)


func _build_display_name(b: FeatureBuild) -> String:
	if b.product_name != "":
		return b.product_name
	if b.sub_product_type_id == "":
		return "Build"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(b.sub_product_type_id)
	return String(data.get("name", b.sub_product_type_id)) if not data.is_empty() else b.sub_product_type_id


func _build_version_badge(b: FeatureBuild) -> PanelContainer:
	if b.is_bug_sprint:
		return UiFactory.make_badge("SPRINT", &"accent")
	if b.is_version_build:
		return UiFactory.make_badge("v%d" % (int(GameState.get_flag("mvp_version", 1)) + 1), &"accent")
	return UiFactory.make_badge("v1", &"neutral")


func _build_phase_line(b: FeatureBuild) -> String:
	# Phase + days-remaining in ONE readable line (the old HUD's cramped stats
	# row is the anti-pattern).
	match b.current_phase:
		"iteration":
			if b.iteration_decision_pending:
				return "İterasyon %d bitti — karar ver" % b.iteration_count
			return "İterasyon %d · %d gün kaldı" % [b.iteration_count, int(ceil(b.iteration_days_in_current))]
		"development":
			return "Development · %d gün kaldı" % int(ceil(float(b.development_days_total) - b.development_days_elapsed))
		"bugfix", "polish":
			return "Bug Fixing · %d bug kaldı" % b.bug_count
		"bug_sprint":
			return "Bug Sprint · %d gün kaldı · %d bug" % [
				int(ceil(float(b.development_days_total) - b.development_days_elapsed)),
				b.bug_count,
			]
		_:
			return b.current_phase.capitalize()


func _build_status_line(b: FeatureBuild) -> String:
	# The calm no-decision-pending line.
	match b.current_phase:
		"iteration":
			return "İterasyon sürüyor"
		"development":
			return "Development otomatik ilerliyor"
		"bug_sprint":
			return "Sprint sürüyor — buglar temizleniyor"
		_:
			return ""


func _axis_display_labels_for(sub_type_id: String) -> Dictionary:
	# Same pattern as product_tab._axis_display_labels — ProductCatalog.QUALITY_AXES
	# is the source; TR fallbacks if the sub-type carries no display labels.
	var out := {"innovation": "İnovasyon", "stability": "Kararlılık", "usability": "Kullanılabilirlik"}
	for a in ProductCatalog.get_quality_axes(sub_type_id):
		out[String(a.get("axis", ""))] = String(a.get("display_label", a.get("axis", "")))
	return out


func _bug_band(count: int) -> int:
	# Mirrors UiTokens.bug_severity thresholds — part of the card signature so a
	# severity change rebuilds the chip with the right palette.
	if count <= 0:
		return 0
	if count <= 2:
		return 1
	return 2


# --- Build section signal handlers + button actions ---

func _on_build_progress_changed() -> void:
	_refresh_build_section()


func _on_build_decision_pending(_pending: bool) -> void:
	_refresh_build_section()


func _on_build_header_gui_input(event: InputEvent) -> void:
	# Click-to-jump: entry-card header → Product tab (working call).
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		EventBus.tab_changed.emit("product")


func _on_build_iteration_pressed() -> void:
	# Existing ProductSystem API only (pattern from the retired BuildHUDPanel).
	ProductSystem.advance_iteration()
	_refresh_build_section()


func _on_build_development_pressed() -> void:
	ProductSystem.enter_development()
	_refresh_build_section()


func _on_build_launch_pressed() -> void:
	ProductSystem.launch()
	_refresh_build_section()
