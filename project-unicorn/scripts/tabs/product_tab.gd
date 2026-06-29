extends Control

# Product tab — Spec #4 (post-iteration-duration removal).
# View routing keyed off (active_build, GameState.flags["mvp_shipped"]):
#   DesignDocumentView  | active_build == null AND not mvp_shipped
#   BuildProgressView   | active_build != null AND phase in {iteration, development, bugfix}
#   PostShipView        | active_build == null AND mvp_shipped
#
# DesignDocumentView now only takes sub-type + 2-4 features — no duration. The
# old Rushed/Standard/Polished selector + projection's quality-ceiling/bug-risk/
# runway rows are gone; planning trusts the player to commit and learn the
# system through play, not through forecast math. The Rushed/Standard/Polished
# selector nodes and all duration refs were removed outright from both this
# script and ProductTab.tscn.
#
# Phase-by-phase build flow is managed by BuildHUDPanel (the right-top desk
# panel in CenterViewport) — the buttons that used to live in BuildProgress /
# PolishProgress views now live there. The Product tab keeps the feed-style
# detail visible while a build is active but doesn't expose decision buttons.
# PolishProgressView is now a deprecated alias for the bugfix phase and is
# hidden — _refresh_view routes "bugfix" to BuildProgressView.

# --- Mentor lines ---

const MENTOR_ITERATION_LINES := {
	"q4": "İzliyorum.",
	"q3": "Hız iyi gidiyor.",
	"q2": "Yaklaşıyor.",
	"q1": "Son sprint.",
}
const MENTOR_POLISH_LINES := {
	"start": "Bugları çöz.",
	"mid": "Yarısı geçti.",
	"end": "Bitiş çizgisinde.",
}

# Feed cap — older entries dropped silently (scroll container also handles overflow).
const FEED_MAX_ENTRIES := 30

# --- Transient planning state (held until start_build is called) ---

var _selected_sub_product_type: String = ""
var _selected_features: Array[String] = []

# --- Feed tracking ---
var _seen_build_id: String = ""             # tracks build id to detect first paint on a new build
var _last_polish_bug_count: int = -1        # sentinel for detecting bug-fix days in polish

# --- View nodes (4) ---
@onready var design_document_view: VBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView
@onready var build_progress_view: VBoxContainer = $Margin/Layout/BuildStateRoot/BuildProgressView
@onready var polish_progress_view: VBoxContainer = $Margin/Layout/BuildStateRoot/PolishProgressView
@onready var post_ship_view: VBoxContainer = $Margin/Layout/BuildStateRoot/PostShipView

# --- DesignDocumentView wiring ---
# Sub-type rows (5)
@onready var sub_type_list: VBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/LeftColumn/LeftVBox/ProductSection/SubTypeList

# Feature grid (7 cards)
@onready var selection_counter_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/HeaderRow/SelectionCounterLabel
@onready var context_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/ContextLabel
@onready var empty_instruction_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/EmptyInstructionLabel
@onready var feature_grid: GridContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/CenterColumn/CenterVBox/FeatureGrid

# Projection rows (8)
@onready var projection_list: VBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/RightColumn/RightVBox/ProjectionList
@onready var mentor_advisory_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ColumnsRow/RightColumn/RightVBox/MentorAdvisoryLabel

# Commit bar
@onready var commit_bar: Button = $Margin/Layout/BuildStateRoot/DesignDocumentView/CommitBar
@onready var reason_label: Label = $Margin/Layout/BuildStateRoot/DesignDocumentView/ReasonLabel

# --- BuildProgressView wiring ---
@onready var bp_sub_type_label: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BuildHeaderPanel/HeaderLayout/SubTypeLabel
@onready var bp_features_label: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BuildHeaderPanel/HeaderLayout/FeaturesLabel
@onready var bp_engineer_label: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BuildHeaderPanel/HeaderLayout/EngineerLabel
@onready var bp_iteration_bar: ProgressBar = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/ProgressPanel/ProgressLayout/PhaseSegmentedBar/IterationBar
@onready var bp_polish_bar: ProgressBar = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/ProgressPanel/ProgressLayout/PhaseSegmentedBar/PolishBar
@onready var bp_phase_bar: HBoxContainer = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/ProgressPanel/ProgressLayout/PhaseSegmentedBar
@onready var bp_progress_caption: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/ProgressPanel/ProgressLayout/ProgressCaption
@onready var bp_feed_list: VBoxContainer = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/ProgressPanel/ProgressLayout/FeedScroll/FeedList
@onready var bp_quality_value: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Quality/ValueRight
@onready var bp_bugs_row: PanelContainer = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Bugs
@onready var bp_bugs_value: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Bugs/BugLayout/ValueRight
@onready var bp_phase_value: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Phase/ValueRight
@onready var bp_remaining_value: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Remaining/ValueRight
@onready var bp_mentor_line: Label = $Margin/Layout/BuildStateRoot/BuildProgressView/BottomRow/StatusPanel/StatusLayout/MentorLineLabel

# --- PolishProgressView wiring ---
@onready var pp_sub_type_label: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BuildHeaderPanel/HeaderLayout/SubTypeLabel
@onready var pp_features_label: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BuildHeaderPanel/HeaderLayout/FeaturesLabel
@onready var pp_engineer_label: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BuildHeaderPanel/HeaderLayout/EngineerLabel
@onready var pp_iteration_bar: ProgressBar = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/ProgressPanel/ProgressLayout/PhaseSegmentedBar/IterationBar
@onready var pp_polish_bar: ProgressBar = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/ProgressPanel/ProgressLayout/PhaseSegmentedBar/PolishBar
@onready var pp_phase_bar: HBoxContainer = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/ProgressPanel/ProgressLayout/PhaseSegmentedBar
@onready var pp_progress_caption: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/ProgressPanel/ProgressLayout/ProgressCaption
@onready var pp_feed_list: VBoxContainer = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/ProgressPanel/ProgressLayout/FeedScroll/FeedList
@onready var pp_quality_value: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Quality/ValueRight
@onready var pp_bugs_row: PanelContainer = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Bugs
@onready var pp_bugs_value: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Bugs/BugLayout/ValueRight
@onready var pp_phase_value: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Phase/ValueRight
@onready var pp_remaining_value: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/StatusPanel/StatusLayout/StatRow_Remaining/ValueRight
@onready var pp_mentor_line: Label = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/StatusPanel/StatusLayout/MentorLineLabel
@onready var pp_ship_now_button: Button = $Margin/Layout/BuildStateRoot/PolishProgressView/BottomRow/StatusPanel/StatusLayout/ShipNowButton

# --- PostShipView (PostShip sales phase, B2C/B2B aware) ---
@onready var post_ship_title: Label = $Margin/Layout/BuildStateRoot/PostShipView/PostShipTitle
@onready var post_ship_status_body: Label = $Margin/Layout/BuildStateRoot/PostShipView/StatusPanel/StatusVBox/StatusBody
@onready var post_ship_frank_line: Label = $Margin/Layout/BuildStateRoot/PostShipView/FrankPanel/FrankVBox/FrankLine
@onready var post_ship_traction_bar: ProgressBar = $Margin/Layout/BuildStateRoot/PostShipView/TractionPanel/TractionVBox/TractionBar
@onready var post_ship_traction_label: Label = $Margin/Layout/BuildStateRoot/PostShipView/TractionPanel/TractionVBox/TractionLabel
@onready var post_ship_sales_button: Button = $Margin/Layout/BuildStateRoot/PostShipView/SalesHintButton


func _ready() -> void:
	_wire_design_document_view()
	_wire_polish_view()
	post_ship_sales_button.pressed.connect(_on_post_ship_sales_pressed)
	EventBus.day_advanced.connect(_on_day_advanced)
	EventBus.build_progress_changed.connect(_on_build_progress_changed)
	EventBus.modal_requested.connect(_on_modal_requested_for_feed)
	# PostShip repaint on sales-state changes (immediate feedback for revenue/leads).
	EventBus.mrr_changed.connect(_on_sales_state_changed)
	EventBus.customer_added.connect(_on_sales_state_changed)
	EventBus.customer_removed.connect(_on_sales_state_changed)
	EventBus.prospect_added.connect(_on_sales_state_changed)
	EventBus.prospect_removed.connect(_on_sales_state_changed)
	_refresh_view()


func _exit_tree() -> void:
	if EventBus.day_advanced.is_connected(_on_day_advanced):
		EventBus.day_advanced.disconnect(_on_day_advanced)
	if EventBus.build_progress_changed.is_connected(_on_build_progress_changed):
		EventBus.build_progress_changed.disconnect(_on_build_progress_changed)
	if EventBus.modal_requested.is_connected(_on_modal_requested_for_feed):
		EventBus.modal_requested.disconnect(_on_modal_requested_for_feed)
	for sig in [EventBus.mrr_changed, EventBus.customer_added, EventBus.customer_removed,
			EventBus.prospect_added, EventBus.prospect_removed]:
		if sig.is_connected(_on_sales_state_changed):
			sig.disconnect(_on_sales_state_changed)


# --- View routing ---

func _refresh_view() -> void:
	var active = ProductSystem.get_active_build()
	var shipped: bool = GameState.get_flag("mvp_shipped", false)
	if active == null and shipped:
		_show_state(post_ship_view)
		_paint_post_ship()
	elif active != null and active.current_phase in ["iteration", "development", "bugfix", "polish"]:
		# All active build phases share BuildProgressView (PolishProgressView is
		# deprecated, hidden permanently). Decision buttons live in BuildHUDPanel.
		_show_state(build_progress_view)
		_paint_build_progress(active)
	else:
		_show_state(design_document_view)
		_refresh_design_document()


func _show_state(view: Control) -> void:
	design_document_view.visible = (view == design_document_view)
	build_progress_view.visible = (view == build_progress_view)
	polish_progress_view.visible = (view == polish_progress_view)
	post_ship_view.visible = (view == post_ship_view)


# =========================================================================
#  DesignDocumentView wiring + painting
# =========================================================================

func _wire_design_document_view() -> void:
	# Sub-type rows
	for i in range(sub_type_list.get_child_count()):
		var row: Panel = sub_type_list.get_child(i) as Panel
		if row != null:
			row.gui_input.connect(_on_sub_type_row_input.bind(row))
	# Feature cards
	for i in range(feature_grid.get_child_count()):
		var card: Panel = feature_grid.get_child(i) as Panel
		if card != null:
			card.gui_input.connect(_on_feature_card_input.bind(card))
	# Commit
	commit_bar.pressed.connect(_on_commit_pressed)


func _refresh_design_document() -> void:
	_paint_sub_type_list()
	_paint_feature_grid()
	_refresh_projection()
	_refresh_commit_bar()


# ---- Sub-type list ----

func _paint_sub_type_list() -> void:
	var sub_types: Array = ProductCatalog.get_sub_product_types(GameState.subgenre)
	for i in range(sub_type_list.get_child_count()):
		var row: Panel = sub_type_list.get_child(i) as Panel
		if row == null:
			continue
		if i < sub_types.size():
			var data: Dictionary = sub_types[i]
			var sub_id: String = String(data.get("id", ""))
			row.get_node("RowLayout/NameLabel").text = String(data.get("name", ""))
			row.get_node("RowLayout/PitchLabel").text = String(data.get("pitch", ""))
			row.set_meta("sub_type_id", sub_id)
			row.visible = true
			var sel_border: Panel = row.get_node("SelectedBorder")
			sel_border.visible = (_selected_sub_product_type == sub_id)
		else:
			row.visible = false


func _on_sub_type_row_input(event: InputEvent, row: Panel) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var sub_type_id: String = row.get_meta("sub_type_id", "")
		if sub_type_id == "":
			return
		# Switching sub-type invalidates the feature pool — clear features +
		# duration so the user re-decides downstream.
		_selected_sub_product_type = sub_type_id
		_selected_features = []
		_refresh_design_document()


# ---- Feature grid ----

func _paint_feature_grid() -> void:
	if _selected_sub_product_type == "":
		feature_grid.visible = false
		context_label.visible = false
		empty_instruction_label.visible = true
		selection_counter_label.text = "0 / 4 seçili — min 2"
		return
	empty_instruction_label.visible = false
	context_label.visible = true
	var sub_type_name: String = _sub_product_type_name(_selected_sub_product_type)
	context_label.text = "%s için özellikler" % sub_type_name
	feature_grid.visible = true

	var pool: Array = ProductCatalog.get_feature_pool(_selected_sub_product_type)
	var at_max: bool = _selected_features.size() >= 4
	for i in range(feature_grid.get_child_count()):
		var card: Panel = feature_grid.get_child(i) as Panel
		if card == null:
			continue
		if i < pool.size():
			var data: Dictionary = pool[i]
			var fid: String = String(data.get("id", ""))
			card.get_node("CardLayout/NameLabel").text = String(data.get("name", ""))
			card.get_node("CardLayout/VoiceLabel").text = String(data.get("voice", ""))
			card.set_meta("feature_id", fid)
			var complexity: int = int(data.get("complexity", 1))
			_paint_complexity_dots(card, complexity)
			card.visible = true
			var sel_border: Panel = card.get_node("SelectedBorder")
			var selected: bool = _selected_features.has(fid)
			sel_border.visible = selected
			# Dim unselected cards when at the 4-feature cap (matches Spec #2 recipe).
			if at_max and not selected:
				card.modulate = Color(1, 1, 1, 0.55)
			else:
				card.modulate = Color(1, 1, 1, 1)
		else:
			card.visible = false
	selection_counter_label.text = "%d / 4 seçili — min 2" % _selected_features.size()


func _paint_complexity_dots(card: Panel, complexity: int) -> void:
	var complexity_box: HBoxContainer = card.get_node("CardLayout/ComplexityRow/Complexity")
	for i in range(complexity_box.get_child_count()):
		var dot: Label = complexity_box.get_child(i) as Label
		if dot == null:
			continue
		if i < complexity:
			dot.add_theme_color_override("font_color", Color(0.91, 0.733, 0.471, 1))
		else:
			dot.add_theme_color_override("font_color", Color(0.30, 0.27, 0.22, 1))


func _on_feature_card_input(event: InputEvent, card: Panel) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var feature_id: String = card.get_meta("feature_id", "")
		if feature_id == "":
			return
		if _selected_features.has(feature_id):
			_selected_features.erase(feature_id)
		else:
			if _selected_features.size() >= 4:
				return
			_selected_features.append(feature_id)
		_refresh_design_document()


# ---- Projection panel ----

func _refresh_projection() -> void:
	# Spec #4: planning no longer commits a duration, so the duration/quality-
	# ceiling/bug-risk/runway-cost/runway-after rows have nothing honest to
	# forecast. Keep them hidden; show sub-type + feature count + a one-line
	# hint about iteration cadence so the player knows what they're committing
	# to before pressing build.
	_set_projection_row("Row_SubType", _sub_product_type_name(_selected_sub_product_type) if _selected_sub_product_type != "" else "—")
	_set_projection_row("Row_FeatureCount", "%d / 4" % _selected_features.size() if not _selected_features.is_empty() else "—")
	_hide_projection_row("Row_Duration")
	_hide_projection_row("Row_ShipDate")
	_hide_projection_row("Row_QualityCeiling")
	_hide_projection_row("Row_BugRisk")
	_hide_projection_row("Row_RunwayCost")
	_hide_projection_row("Row_RunwayAfter")
	mentor_advisory_label.text = _mentor_advisory_text()


func _set_projection_row(row_name: String, value: String) -> void:
	var row := projection_list.get_node_or_null(row_name)
	if row == null:
		return
	row.visible = true
	var value_label := row.get_node_or_null("ValueRight")
	if value_label is Label:
		value_label.text = value


func _hide_projection_row(row_name: String) -> void:
	var row := projection_list.get_node_or_null(row_name)
	if row != null:
		row.visible = false


func _mentor_advisory_text() -> String:
	if _selected_sub_product_type == "":
		return "Soldan başla. Ne yaptığımıza karar verelim."
	if _selected_features.size() < 2:
		return "Ne yapacağına karar verelim. En az iki özellik."
	if _selected_features.size() > 4:
		return "Dört'ten fazlasını taşıyamayız."
	return "Hazır. Build'i başlat — fazları üst köşeden yöneteceksin."


# ---- Commit bar ----

func _refresh_commit_bar() -> void:
	var valid: bool = _selected_sub_product_type != "" \
		and _selected_features.size() >= 2 \
		and _selected_features.size() <= 4
	commit_bar.disabled = not valid
	reason_label.visible = not valid


func _on_commit_pressed() -> void:
	if commit_bar.disabled:
		return
	var founder = CharacterRegistry.get_founder()
	var founder_id: String = founder.id if founder != null else "char_founder"
	if ProductSystem.start_build(_selected_sub_product_type, _selected_features, founder_id):
		# Reset transient state — router will take over to BuildProgressView
		_selected_sub_product_type = ""
		_selected_features = []
		# Auto-unpause so the build starts ticking immediately.
		EventBus.speed_change_requested.emit(1)
		_refresh_view()


# =========================================================================
#  BuildProgressView / PolishProgressView
# =========================================================================

func _wire_polish_view() -> void:
	# Spec #4: PolishProgressView is deprecated — the ŞİMDİ SHIP'LE button
	# moved to BuildHUDPanel as the LAUNCH button. Wire a no-op so the
	# .tscn signal connection (if any) doesn't crash on click. Whole view
	# stays hidden via _show_state().
	if pp_ship_now_button != null and not pp_ship_now_button.pressed.is_connected(_on_polish_ship_now_pressed):
		pp_ship_now_button.pressed.connect(_on_polish_ship_now_pressed)


func _paint_build_progress(b: FeatureBuild) -> void:
	# Spec #4: BuildProgressView covers iteration / development / bugfix —
	# decision buttons live in BuildHUDPanel; here we just show header + a
	# faz-aware status block + the development feed. The phase-segmented bar
	# from the old Spec #2 model degrades to a single progress bar driven by
	# whichever counter belongs to the current phase.
	bp_sub_type_label.text = _sub_product_type_name(b.sub_product_type_id)
	bp_features_label.text = _build_feature_summary(b)
	bp_engineer_label.text = "Mühendis: %s" % _engineer_name(b)

	# Bar values per phase. The old iteration / polish split is no longer
	# meaningful — collapse to "iteration bar = current phase progress".
	var bar_total: int = 1
	var bar_value: int = 0
	match b.current_phase:
		"iteration":
			bar_total = max(1, ProductSystem.ITERATION_LENGTH_DAYS)
			bar_value = bar_total - b.iteration_days_in_current
		"development":
			bar_total = max(1, b.development_days_total)
			bar_value = b.development_days_elapsed
		"bugfix", "polish":
			# Open-ended phase — show full bar so the segmented widget doesn't
			# look broken; LAUNCH lives on BuildHUDPanel.
			bar_total = 1
			bar_value = 1
	bp_iteration_bar.max_value = float(bar_total)
	bp_iteration_bar.value = float(bar_value)
	bp_polish_bar.max_value = 1.0
	bp_polish_bar.value = 0.0
	bp_phase_bar.get_child(0).size_flags_stretch_ratio = 1.0
	bp_phase_bar.get_child(1).size_flags_stretch_ratio = 0.0

	# Caption
	match b.current_phase:
		"iteration":
			bp_progress_caption.text = "Iteration %d · %d gün kaldı" % [b.iteration_count, b.iteration_days_in_current]
		"development":
			bp_progress_caption.text = "Development %d / %d gün" % [b.development_days_elapsed, b.development_days_total]
		"bugfix", "polish":
			bp_progress_caption.text = "Bug Fixing · launch sende"

	# Status rows
	bp_quality_value.text = "%d / 100" % b.quality
	bp_bugs_value.text = "%d" % b.bug_count
	_paint_bug_indicator_color(bp_bugs_row, bp_bugs_value, b.bug_count)
	match b.current_phase:
		"iteration":
			bp_phase_value.text = "İterasyon"
			if b.iteration_decision_pending:
				bp_remaining_value.text = "Karar bekleniyor"
			else:
				bp_remaining_value.text = "%d gün" % b.iteration_days_in_current
		"development":
			bp_phase_value.text = "Development"
			bp_remaining_value.text = "%d gün kaldı" % max(0, b.development_days_total - b.development_days_elapsed)
		"bugfix", "polish":
			bp_phase_value.text = "Bug Fixing"
			bp_remaining_value.text = "—"

	# Mentor line varies by phase
	match b.current_phase:
		"iteration":
			bp_mentor_line.text = _iteration_mentor_line_for(b)
		"development":
			bp_mentor_line.text = "Çalışıyor. Sen izle."
		"bugfix", "polish":
			bp_mentor_line.text = "Hazır olduğunda yayınla."

	# Feed bootstrap (first paint for this build)
	if _seen_build_id != b.id:
		_seen_build_id = b.id
		_clear_feed(bp_feed_list)
		_prepend_feed_entry(bp_feed_list, b.start_day, "Build başladı.")
		_last_polish_bug_count = -1


# ---- Bug indicator color (ported from Spec #2 _paint_bug_indicator_color) ----

func _paint_bug_indicator_color(panel: PanelContainer, value_label: Label, bug_count: int) -> void:
	var sb := StyleBoxFlat.new()
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_right = 3
	sb.corner_radius_bottom_left = 3
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	if bug_count > 5:
		# NEGATIVE — soft red bg, cream text
		sb.bg_color = Color(0.40, 0.18, 0.16, 1)
		value_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.82, 1))
	elif bug_count >= 3:
		sb.bg_color = Color(0.165, 0.137, 0.106, 1)
		value_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.82, 1))
	else:
		sb.bg_color = Color(0.165, 0.137, 0.106, 1)
		value_label.add_theme_color_override("font_color", Color(0.78, 0.722, 0.612, 1))
	panel.add_theme_stylebox_override("panel", sb)


# ---- Mentor line helpers ----

func _iteration_mentor_line_for(b: FeatureBuild) -> String:
	# Mentor cadence within the current iteration. iteration_days_in_current
	# decrements from ITERATION_LENGTH_DAYS → 0.
	var total: int = max(1, ProductSystem.ITERATION_LENGTH_DAYS)
	var elapsed: int = total - b.iteration_days_in_current
	var ratio: float = float(elapsed) / float(total)
	if ratio < 0.25:
		return MENTOR_ITERATION_LINES["q4"]
	elif ratio < 0.5:
		return MENTOR_ITERATION_LINES["q3"]
	elif ratio < 0.75:
		return MENTOR_ITERATION_LINES["q2"]
	return MENTOR_ITERATION_LINES["q1"]


# Deprecated — Spec #4 dropped the mid-polish ship-now button. The handler
# is kept as a no-op so the .tscn signal binding (if it survives in scene
# state) doesn't crash when clicked.
func _on_polish_ship_now_pressed() -> void:
	push_warning("[ProductTab] Polish ship-now is deprecated; use BuildHUDPanel LAUNCH instead.")


# =========================================================================
#  Development feed
# =========================================================================

func _active_feed_list() -> VBoxContainer:
	var active = ProductSystem.get_active_build()
	if active == null:
		return null
	# Spec #4: all phases route to BuildProgressView's feed; PolishProgressView
	# is hidden and its feed_list is never painted.
	return bp_feed_list


func _clear_feed(feed: VBoxContainer) -> void:
	for c in feed.get_children():
		c.queue_free()


func _prepend_feed_entry(feed: VBoxContainer, day: int, message: String) -> void:
	# Entry: HBox with DayLabel (min_width=46) + MessageLabel (autowrap).
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var day_label := Label.new()
	day_label.text = "Gün %d" % day
	day_label.add_theme_color_override("font_color", Color(0.78, 0.722, 0.612, 1))
	day_label.add_theme_font_size_override("font_size", 11)
	day_label.custom_minimum_size = Vector2(46, 0)
	var msg_label := Label.new()
	msg_label.text = message
	msg_label.add_theme_color_override("font_color", Color(0.96, 0.91, 0.82, 1))
	msg_label.add_theme_font_size_override("font_size", 11)
	msg_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(day_label)
	row.add_child(msg_label)
	feed.add_child(row)
	feed.move_child(row, 0)
	# Cap at FEED_MAX_ENTRIES
	while feed.get_child_count() > FEED_MAX_ENTRIES:
		var oldest = feed.get_child(feed.get_child_count() - 1)
		feed.remove_child(oldest)  # immediate detach → get_child_count() drops now → loop terminates
		oldest.queue_free()        # deferred free is safe once the row is detached (queue_free alone left it parented → infinite loop)


func _mirror_feed(src: VBoxContainer, dst: VBoxContainer) -> void:
	# Copy entries (newest first in src) into dst preserving order.
	# Walks src from oldest to newest and prepends each into dst so the
	# resulting order in dst matches src.
	var n: int = src.get_child_count()
	for i in range(n - 1, -1, -1):
		var entry = src.get_child(i)
		if not (entry is HBoxContainer):
			continue
		var day_text: String = ""
		var msg_text: String = ""
		if entry.get_child_count() >= 2:
			day_text = String((entry.get_child(0) as Label).text)
			msg_text = String((entry.get_child(1) as Label).text)
		# day_text already has "Gün N" prefix from the original entry — re-parse
		# the number, falling back to GameState.day on parse failure.
		var day_num: int = GameState.day
		var parts: PackedStringArray = day_text.split(" ", false)
		if parts.size() >= 2:
			day_num = int(parts[1])
		_prepend_feed_entry(dst, day_num, msg_text)


func _on_modal_requested_for_feed(event) -> void:
	# Only log when a build is active (filters onboarding/system modals).
	var active = ProductSystem.get_active_build()
	if active == null or event == null:
		return
	var feed = _active_feed_list()
	if feed == null:
		return
	var title: String = String(event.title) if event != null else ""
	if title == "":
		title = "Olay"
	_prepend_feed_entry(feed, GameState.day, title)


# =========================================================================
#  PostShipView (preserved from Spec #1)
# =========================================================================

func _paint_post_ship() -> void:
	var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
	var quality: int = int(GameState.get_flag("mvp_quality", 50))
	post_ship_title.text = "%s · canlı" % _sub_product_type_name(String(GameState.get_flag("mvp_sub_product_type_id", "")))

	# GÜNCEL DURUM — market-aware
	if market == "b2c":
		var audience: int = int(GameState.get_flag("b2c_audience", 0))
		if not GameState.get_flag("b2c_paid_tier_open", false):
			post_ship_status_body.text = "%d kişi ürünü deniyor. Henüz para kazanmıyorsun — fiyatlandırma kararın yaklaşıyor. Büyüme: %s." % [audience, SalesSystem.growth_band()]
		else:
			post_ship_status_body.text = "%d kişi deniyor · %d ödeyen kullanıcı · MRR $%d. Büyüme: %s." % [audience, CustomerRegistry.get_total_users(), GameState.mrr, SalesSystem.growth_band()]
		post_ship_sales_button.visible = false
	else:
		var custn: int = CustomerRegistry.get_active().size()
		if custn == 0:
			post_ship_status_body.text = "İlk pitch'in Sales sekmesinde seni bekliyor." if ProspectRegistry.has_any() \
				else "Henüz müşteri yok — Frank seni biriyle tanıştıracak."
		else:
			post_ship_status_body.text = "%d müşteri · MRR $%d." % [custn, GameState.mrr]
		post_ship_sales_button.visible = true

	# FRANK — ship-moment reaction varying by quality/bugs
	post_ship_frank_line.text = _frank_ship_reaction(quality, int(GameState.get_flag("mvp_bug_count_at_launch", 0)))

	# TRACTION north-star
	post_ship_traction_bar.value = SalesSystem.traction_progress()
	if GameState.get_flag("ready_for_traction", false):
		post_ship_traction_label.text = "Traction'a hazır — Frank'le konuş."
	else:
		# MRR is the canonical traction north-star (Faz 1 bug 1.5). The old label
		# also showed a customer-record count, which for B2C is one aggregate
		# record (never climbs) and contradicted the "ödeyen kullanıcı" seats line
		# above it. Show MRR progress only.
		post_ship_traction_label.text = "MRR $%d / $%d" % [GameState.mrr, SalesSystem.TRACTION_MRR_TARGET]


func _on_post_ship_sales_pressed() -> void:
	EventBus.tab_changed.emit("sales")


func _on_sales_state_changed(_arg = null) -> void:
	# Repaint PostShip on revenue / customer / prospect changes (routes safely
	# even outside the post-ship state).
	_refresh_view()


func _frank_ship_reaction(quality: int, bugs: int) -> String:
	if bugs > 8:
		return "\"Çıktı işte. Ama o bug'lar… ilk izlenim önemli, çabuk topla.\""
	if quality >= 80:
		return "\"İyi iş. Temiz çıktı. Şimdi sabır — müşteri kendiliğinden gelmez.\""
	return "\"Tamam, yayında. Zor kısım şimdi: birinin buna para vermesini sağlamak.\""


# =========================================================================
#  Helpers
# =========================================================================

func _sub_product_type_name(sub_type_id: String) -> String:
	if sub_type_id == "":
		return "—"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return String(data.get("name", sub_type_id))


func _build_feature_summary(b: FeatureBuild) -> String:
	var pool: Array = ProductCatalog.get_feature_pool(b.sub_product_type_id)
	var names: Array[String] = []
	for fid in b.feature_ids:
		var found: bool = false
		for f in pool:
			if String(f.get("id", "")) == String(fid):
				names.append(String(f.get("name", "")))
				found = true
				break
		if not found:
			names.append(String(fid))
	if names.is_empty():
		return "—"
	return ", ".join(names)


func _engineer_name(b: FeatureBuild) -> String:
	var founder = CharacterRegistry.get_founder()
	if founder != null and b.assigned_engineer_id == founder.id:
		return founder.character_name
	# Fallback — registry lookup by id, then a generic label
	if founder != null:
		return founder.character_name
	return "Founder"


func _display_date_for(day_number: int) -> String:
	# Mirrors GameState.get_display_date() but for an arbitrary day number.
	# Day 1 = Wed Jan 1 2025 anchor.
	if day_number <= 0:
		return "—"
	var anchor_unix: int = int(Time.get_unix_time_from_datetime_dict(GameState.START_DATE))
	var current_unix: int = anchor_unix + (day_number - 1) * 86400
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(current_unix)
	return "%s, %s %d" % [GameState.DOW_ABBR[d.weekday], GameState.MONTH_ABBR[d.month - 1], d.day]


# =========================================================================
#  Signal handlers
# =========================================================================

func _on_day_advanced(_new_day: int) -> void:
	# Per-day feed bookkeeping BEFORE re-painting (so paint reads the latest counts).
	var active = ProductSystem.get_active_build()
	if active != null:
		var feed = _active_feed_list()
		if feed != null:
			if active.current_phase == "polish":
				# Polish day: detect bug-fix delta vs the previous tick.
				if _last_polish_bug_count >= 0 and active.bug_count < _last_polish_bug_count:
					var fixed: int = _last_polish_bug_count - active.bug_count
					_prepend_feed_entry(feed, GameState.day, "Bug temizliği · %d düşürüldü (kalan %d)." % [fixed, active.bug_count])
				elif not EventManager.has_pending():
					_prepend_feed_entry(feed, GameState.day, "Sessiz bir gün.")
				_last_polish_bug_count = active.bug_count
			else:
				# Iteration day: filler only when no pending event will surface.
				if not EventManager.has_pending():
					_prepend_feed_entry(feed, GameState.day, "Sessiz bir gün.")
	# Re-route + paint (build might have transitioned phase this tick).
	_refresh_view()


func _on_build_progress_changed() -> void:
	# Fired at the end of ProductSystem.daily_tick, after the phase counter
	# advanced. day_advanced already repainted with yesterday's value (it fires
	# before the tick); repaint again with the post-tick value so the bar tracks
	# the day correctly (Faz 1 bug 1.1). Feed bookkeeping stays in _on_day_advanced
	# so entries are not duplicated.
	_refresh_view()
