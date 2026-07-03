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
# Product Lifecycle Part 2B: when true the DesignDocumentView is in "v2 mode" — the shipped
# product's type + name are locked, its existing features are pre-checked and can't be
# dropped, and committing calls start_version_build (add features to the live product).
var _v2_mode: bool = false
# Pool-deepening sub-mode (feature-exhaustion unlock): true when _v2_mode AND every pool
# feature is already in the product. Then _selected_features holds the EXISTING features the
# player picks TO STRENGTHEN (⊆ mvp_components), not the product set.
var _v2_strengthen_mode: bool = false
# Product Lifecycle Part 1 — product name (required to commit) + suggest cursor.
var _selected_product_name: String = ""
var _name_suggest_index: int = 0
# Code-built "what this product strengthens" profile panel (right column).
var _projection_profile: VBoxContainer = null
# Commit ceremony (Blok C): Frank's last word inside the commit card.
var _commit_frank_label: Label = null
# Part 2B: "Vazgeç" escape hatch shown only in v2 mode (back to PostShip without committing).
var _v2_cancel_button: Button = null

# --- Feed tracking ---
var _seen_build_id: String = ""             # tracks build id to detect first paint on a new build
var _last_polish_bug_count: int = -1        # sentinel for detecting bug-fix days in polish

# --- View nodes (4) ---
# The static tab title (hidden in post-ship — PostShipTitle carries the identity there).
@onready var title_bar: HBoxContainer = $Margin/Layout/TitleBar
@onready var design_document_view: VBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView
@onready var build_progress_view: VBoxContainer = $Margin/Layout/BuildStateRoot/BuildProgressView
@onready var polish_progress_view: VBoxContainer = $Margin/Layout/BuildStateRoot/PolishProgressView
# Part 2B: PostShipView is now inside a ScrollContainer (content overflowed). post_ship_view
# points at the INNER VBox so all add_child/move_child/get_parent logic is unchanged; the
# scroll wrapper is the node we toggle visible.
@onready var post_ship_scroll: ScrollContainer = $Margin/Layout/BuildStateRoot/PostShipScroll
@onready var post_ship_view: VBoxContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView

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

# Product name row (Product Lifecycle Part 1)
@onready var name_row: HBoxContainer = $Margin/Layout/BuildStateRoot/DesignDocumentView/NameRow
@onready var name_input: LineEdit = $Margin/Layout/BuildStateRoot/DesignDocumentView/NameRow/NameInput
@onready var suggest_button: Button = $Margin/Layout/BuildStateRoot/DesignDocumentView/NameRow/SuggestButton

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
@onready var post_ship_title: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/PostShipTitle
@onready var post_ship_status_body: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/StatusPanel/StatusVBox/StatusBody
@onready var post_ship_frank_line: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/FrankPanel/FrankBody/FrankVBox/FrankLine
@onready var post_ship_traction_bar: ProgressBar = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/TractionPanel/TractionVBox/TractionBar
@onready var post_ship_traction_label: Label = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/TractionPanel/TractionVBox/TractionLabel
@onready var post_ship_sales_button: Button = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/SalesHintButton
# Structural PostShipView panels (for code-built-card order enforcement — Part 2A).
@onready var post_ship_status_panel: PanelContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/StatusPanel
@onready var post_ship_frank_panel: PanelContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/FrankPanel
@onready var post_ship_traction_panel: PanelContainer = $Margin/Layout/BuildStateRoot/PostShipScroll/PostShipView/TractionPanel

# --- Post-ship action center (Yön A redesign) — the sprint banner lives in _action_list ---
var _sprint_banner: VBoxContainer = null

# --- Post-ship funnel (B2C) + traction chip — built in code ---
var _status_funnel: HBoxContainer = null
var _traction_chip: Control = null

# --- Dynamic pricing lever (B2C) — built in code, mounted into PostShipView ---
var _pricing_panel: PanelContainer = null
var _pricing_header_row: HBoxContainer = null
var _pricing_status_chip: Control = null
var _pricing_value_label: Label = null
var _pricing_rationale: HFlowContainer = null
var _pricing_spectrum: Control = null
var _pricing_band: HBoxContainer = null
var _price_slider: HSlider = null
var _pricing_marks: Label = null
var _pricing_projection: VBoxContainer = null
var _pricing_apply: Button = null
var _pricing_initialized: bool = false

# --- Yön A control-panel scaffold (redesign) — built once; authored PostShip nodes are
# reparented into it at runtime (their @onready refs stay valid). ---
var _scaffold_built: bool = false
var _top_strip: HBoxContainer = null
var _version_row: HBoxContainer = null
var _health_slot: HBoxContainer = null
var _left_col: VBoxContainer = null
var _right_col: VBoxContainer = null
var _dim_list: VBoxContainer = null
var _chips_row: HFlowContainer = null
var _left_funnel_body: VBoxContainer = null
var _action_list: VBoxContainer = null
var _price_detail_slot: VBoxContainer = null
var _b2b_info: VBoxContainer = null
var _bottom_strip: VBoxContainer = null
var _rival_line: Label = null
var _action_built: bool = false
var _active_action: String = "price"   # "price" | "sprint" | "v2"
var _action_rows: Dictionary = {}       # id -> {root, title, desc, status}
var _design_two_col_built: bool = false

# --- BuildProgressView Yön A scaffold (C2) — built once; authored bp_* leaves reparented in ---
var _bp_scaffold_built: bool = false
var _bp_title_group: VBoxContainer = null
var _bp_phase_row: HBoxContainer = null
var _bp_status_chip_slot: HBoxContainer = null
var _bp_dim_list: VBoxContainer = null
var _bp_status_slot: VBoxContainer = null
var _bp_decision_card: PanelContainer = null
var _bp_decision_title: Label = null
var _bp_decision_desc: Label = null
var _bp_iter_btn: Button = null
var _bp_dev_btn: Button = null
var _bp_launch_btn: Button = null


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
	# Economy Model v2: audience flows hourly but b2c_audience is a silent flag, so
	# repaint the PostShip audience line each in-game hour (MRR repaints via mrr_changed).
	EventBus.hour_changed.connect(_on_sales_state_changed)
	_refresh_view()


func _exit_tree() -> void:
	if EventBus.day_advanced.is_connected(_on_day_advanced):
		EventBus.day_advanced.disconnect(_on_day_advanced)
	if EventBus.build_progress_changed.is_connected(_on_build_progress_changed):
		EventBus.build_progress_changed.disconnect(_on_build_progress_changed)
	if EventBus.modal_requested.is_connected(_on_modal_requested_for_feed):
		EventBus.modal_requested.disconnect(_on_modal_requested_for_feed)
	for sig in [EventBus.mrr_changed, EventBus.customer_added, EventBus.customer_removed,
			EventBus.prospect_added, EventBus.prospect_removed, EventBus.hour_changed]:
		if sig.is_connected(_on_sales_state_changed):
			sig.disconnect(_on_sales_state_changed)
	# C2: leaving the product tab (CenterViewport frees it) → let BuildHUD show again.
	_set_hud_suppressed(false)


# --- View routing ---

func _refresh_view() -> void:
	var active = ProductSystem.get_active_build()
	var shipped: bool = GameState.get_flag("mvp_shipped", false)
	if _v2_mode and active == null and shipped:
		# Part 2B: player opened "v2 Geliştir" — plan the next version in the design view
		# (pre-filled from the live product) before the build exists. Overrides the
		# active==null && shipped → PostShip route below.
		_show_state(design_document_view)
		_refresh_design_document()
		return
	if active != null and active.is_bug_sprint:
		# Bug sprint (Part 2A) stays in the product management center → pricing reachable,
		# sprint progress shown in the action card (BuildProgressView is for real builds).
		_show_state(post_ship_scroll)
		_paint_post_ship()
	elif active == null and shipped:
		_show_state(post_ship_scroll)
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
	# Post-ship toggles the scroll WRAPPER (post_ship_view is now the inner VBox).
	post_ship_scroll.visible = (view == post_ship_scroll)
	# The generic "Product / Design document" tab title is redundant in post-ship
	# (PostShipTitle shows "<name> · vN · canlı") — hide it there to kill the double title.
	title_bar.visible = (view != post_ship_scroll)
	# C2: the phase-decision now lives inside BuildProgressView, so suppress the
	# redundant BuildHUD desk overlay while that view is up (it still shows on
	# other tabs / during sprints).
	_set_hud_suppressed(view == build_progress_view)


func _set_hud_suppressed(v: bool) -> void:
	var parent: Node = get_parent()
	var hud: Node = parent.get_node_or_null("BuildHUD") if parent != null else null
	if hud != null and hud.has_method("set_suppressed"):
		hud.set_suppressed(v)


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
	# Product name row
	name_input.text_changed.connect(_on_name_input_changed)
	suggest_button.pressed.connect(_on_suggest_pressed)
	_name_suggest_index = GameState.day   # vary the first suggestion per run
	# Commit ceremony (Blok C): amber CTA + a framed decision card (no more gray slab).
	commit_bar.theme_type_variation = &"CommitButton"
	_build_commit_card()
	_ensure_design_two_col()   # Yön A: consolidate the 3 columns into 2 (identity | features+projection)


func _ensure_design_two_col() -> void:
	# Yön A dialect for the ship-PRE screen: merge the projection (RightColumn) into the bottom
	# of the feature column, so it reads as two columns — left = product identity (type + name in
	# the commit card), right = features + projection stacked. Reparent-only; @onready refs
	# (feature_grid/projection_list/mentor_advisory_label) stay valid, painting logic untouched.
	if _design_two_col_built:
		return
	_design_two_col_built = true
	var center_vbox: Node = feature_grid.get_parent()          # CenterColumn/CenterVBox
	var center_col: Control = center_vbox.get_parent() as Control
	var right_vbox: Node = projection_list.get_parent()        # RightColumn/RightVBox
	var right_col: Control = right_vbox.get_parent() as Control
	right_vbox.get_parent().remove_child(right_vbox)
	center_vbox.add_child(right_vbox)                          # projection now under the feature grid
	right_col.visible = false
	# Two-column read: left (identity) narrower, center (features + projection) wider.
	var left_col: Control = sub_type_list.get_parent().get_parent().get_parent() as Control  # SubTypeList→ProductSection→LeftVBox→LeftColumn
	if left_col != null:
		left_col.size_flags_stretch_ratio = 2.6
	center_col.size_flags_stretch_ratio = 5.4


func _build_commit_card() -> void:
	# Wrap the name row + amber commit button + reason into a bordered CardPanel so
	# the commit zone reads as a decision moment, not a button floating on gray.
	# Reparents existing nodes AFTER @onready resolved, so the refs stay valid.
	var dv: Node = name_row.get_parent()   # DesignDocumentView VBox
	var insert_idx: int = name_row.get_index()
	var card := PanelContainer.new()
	card.name = "CommitCard"
	card.theme_type_variation = &"CardPanel"
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	card.add_child(vb)
	vb.add_child(UiFactory.make_section_header("Karar"))
	dv.add_child(card)
	dv.move_child(card, insert_idx)
	for n in [name_row, commit_bar, reason_label]:
		n.get_parent().remove_child(n)
		vb.add_child(n)
	# Frank's last word, between the button and the reason hint.
	_commit_frank_label = Label.new()
	_commit_frank_label.theme_type_variation = &"QuoteSerif"
	_commit_frank_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_commit_frank_label.visible = false
	vb.add_child(_commit_frank_label)
	vb.move_child(_commit_frank_label, reason_label.get_index())  # above the reason hint
	# Part 2B: v2 escape hatch — back to the live product without building a version.
	_v2_cancel_button = Button.new()
	_v2_cancel_button.text = "Vazgeç"
	_v2_cancel_button.visible = false
	_v2_cancel_button.pressed.connect(_on_v2_cancel_pressed)
	vb.add_child(_v2_cancel_button)


func _refresh_design_document() -> void:
	_paint_sub_type_list()
	_paint_feature_grid()
	_refresh_projection()
	_refresh_commit_bar()
	# Name row appears once a product type is chosen.
	name_row.visible = _selected_sub_product_type != ""
	# Part 2B: in v2 mode the name is locked (product keeps its identity) and the escape
	# hatch is shown; normal build restores editable name + reroll.
	name_input.editable = not _v2_mode
	suggest_button.visible = not _v2_mode
	if _v2_cancel_button != null:
		_v2_cancel_button.visible = _v2_mode


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
	# Part 2B: in v2 mode the product type is fixed to the live product — no re-picking.
	if _v2_mode:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var sub_type_id: String = row.get_meta("sub_type_id", "")
		if sub_type_id == "":
			return
		# Switching sub-type invalidates the feature pool — clear features +
		# duration so the user re-decides downstream.
		_selected_sub_product_type = sub_type_id
		_selected_features = []
		# Prefill a suggested product name the first time a type is picked (the
		# player can edit or reroll it). Name persists across sub-type switches.
		if _selected_product_name == "":
			var s: String = ProductCatalog.suggest_product_name(_name_suggest_index)
			name_input.text = s
			_selected_product_name = s
		_refresh_design_document()


func _on_name_input_changed(new_text: String) -> void:
	_selected_product_name = new_text.strip_edges()
	_refresh_commit_bar()   # cheap toggle; avoids a full repaint that would reset the caret


func _on_suggest_pressed() -> void:
	_name_suggest_index += 1
	var s: String = ProductCatalog.suggest_product_name(_name_suggest_index)
	name_input.text = s
	_selected_product_name = s
	_refresh_commit_bar()


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
	var feature_cap: int
	if _v2_strengthen_mode:
		feature_cap = ProductSystem.STRENGTHEN_MAX_PER_VERSION
	elif _v2_mode:
		feature_cap = ProductSystem.MAX_VERSION_FEATURES
	else:
		feature_cap = 4
	var at_max: bool = _selected_features.size() >= feature_cap
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
			_paint_axes(card, data)
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
	if _v2_strengthen_mode:
		selection_counter_label.text = "%d / %d güçlendirme seçili" % [
			_selected_features.size(), ProductSystem.STRENGTHEN_MAX_PER_VERSION]
	elif _v2_mode:
		var base_n: int = GameState.get_flag("mvp_components", []).size()
		selection_counter_label.text = "%d / %d özellik · v1: %d, +%d yeni" % [
			_selected_features.size(), ProductSystem.MAX_VERSION_FEATURES, base_n,
			max(0, _selected_features.size() - base_n)]
	else:
		selection_counter_label.text = "%d / 4 seçili — min 2" % _selected_features.size()


func _paint_complexity_dots(card: Panel, complexity: int) -> void:
	var complexity_box: HBoxContainer = card.get_node("CardLayout/ComplexityRow/Complexity")
	for i in range(complexity_box.get_child_count()):
		var dot: Label = complexity_box.get_child(i) as Label
		if dot == null:
			continue
		if i < complexity:
			dot.add_theme_color_override("font_color", UiTokens.ACCENT)
		else:
			dot.add_theme_color_override("font_color", Color(0.80, 0.77, 0.70, 1))


# Feature-card three-axis display (Product Lifecycle Part 1). Built in code so the
# .tscn cards need no per-card surgery: the static ComplexityRow is hidden and a
# 3-row AxesBox (Çekim / Karmaşıklık / Risk) is added once, repainted each refresh.
const _AXIS_ROWS := [["pull", "Çekim"], ["complexity", "Karmaşıklık"], ["stakes", "Risk"]]


func _ensure_axes_box(card: Panel) -> VBoxContainer:
	var layout: VBoxContainer = card.get_node("CardLayout")
	var existing := layout.get_node_or_null("AxesBox")
	if existing != null:
		return existing
	var static_row := layout.get_node_or_null("ComplexityRow")
	if static_row != null:
		static_row.visible = false
	var box := VBoxContainer.new()
	box.name = "AxesBox"
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for pair in _AXIS_ROWS:
		var row := HBoxContainer.new()
		row.name = String(pair[0])
		row.add_theme_constant_override("separation", 6)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cap := Label.new()
		cap.text = String(pair[1])
		cap.custom_minimum_size = Vector2(70, 0)
		cap.add_theme_color_override("font_color", UiTokens.INK_DIM)
		cap.add_theme_font_size_override("font_size", 10)
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(cap)
		var dots := HBoxContainer.new()
		dots.name = "Dots"
		dots.add_theme_constant_override("separation", 2)
		dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in 5:
			var d := Label.new()
			d.text = "●"
			d.add_theme_font_size_override("font_size", 11)
			d.mouse_filter = Control.MOUSE_FILTER_IGNORE
			dots.add_child(d)
		row.add_child(dots)
		box.add_child(row)
	layout.add_child(box)
	return box


func _paint_axes(card: Panel, data: Dictionary) -> void:
	var box := _ensure_axes_box(card)
	for pair in _AXIS_ROWS:
		var key := String(pair[0])
		var v: int = int(data.get(key, 1))
		var dots: HBoxContainer = box.get_node(key + "/Dots")
		var fill: Color = UiTokens.ACCENT
		if key == "pull":
			fill = UiTokens.POSITIVE
		elif key == "stakes":
			fill = UiTokens.NEGATIVE
		for i in range(dots.get_child_count()):
			var dot: Label = dots.get_child(i) as Label
			if dot == null:
				continue
			dot.add_theme_color_override("font_color", fill if i < v else Color(0.80, 0.77, 0.70, 1))


func _on_feature_card_input(event: InputEvent, card: Panel) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var feature_id: String = card.get_meta("feature_id", "")
		if feature_id == "":
			return
		# Pool-deepening: in strengthen sub-mode, selecting an EXISTING feature marks it to
		# strengthen (freely toggleable, capped at STRENGTHEN_MAX_PER_VERSION).
		if _v2_mode and _v2_strengthen_mode:
			if _selected_features.has(feature_id):
				_selected_features.erase(feature_id)
			elif GameState.get_flag("mvp_components", []).has(feature_id) \
					and _selected_features.size() < ProductSystem.STRENGTHEN_MAX_PER_VERSION:
				_selected_features.append(feature_id)
			_refresh_design_document()
			return
		if _selected_features.has(feature_id):
			# Part 2B: shipped features are locked in v2 mode — you add to the product, not strip it.
			if _v2_mode and GameState.get_flag("mvp_components", []).has(feature_id):
				return
			_selected_features.erase(feature_id)
		else:
			# v2 carries the union (v1 + new) so it uses the larger version cap, not the v1 max of 4.
			var cap: int = ProductSystem.MAX_VERSION_FEATURES if _v2_mode else 4
			if _selected_features.size() >= cap:
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
	var _feat_cap: int
	if _v2_strengthen_mode:
		_feat_cap = ProductSystem.STRENGTHEN_MAX_PER_VERSION
	elif _v2_mode:
		_feat_cap = ProductSystem.MAX_VERSION_FEATURES
	else:
		_feat_cap = 4
	_set_projection_row("Row_FeatureCount", "%d / %d" % [_selected_features.size(), _feat_cap] if not _selected_features.is_empty() else "—")
	# Duration row: base + feature complexity. Strengthen builds carry the WHOLE product, so
	# their duration reads the full set, not the (1-2) strengthen picks.
	if _v2_strengthen_mode:
		_set_projection_row("Row_Duration", "~%d gün" % (ProductSystem.DEVELOPMENT_DAYS_BASE + _product_total_complexity()))
	elif not _selected_features.is_empty():
		_set_projection_row("Row_Duration", "~%d gün" % (ProductSystem.DEVELOPMENT_DAYS_BASE + _selected_total_complexity()))
	else:
		_hide_projection_row("Row_Duration")
	_hide_projection_row("Row_ShipDate")
	_hide_projection_row("Row_QualityCeiling")
	_hide_projection_row("Row_BugRisk")
	_hide_projection_row("Row_RunwayCost")
	_hide_projection_row("Row_RunwayAfter")
	_paint_projection_profile()
	mentor_advisory_label.text = _mentor_advisory_text()


# ---- Selection aggregates + dimension profile (Product Lifecycle Part 1) ----

func _selected_total_complexity() -> int:
	var t: int = 0
	for fid in _selected_features:
		t += int(ProductCatalog.get_feature_by_id(fid).get("complexity", 0))
	return t


func _selected_total_stakes() -> int:
	var t: int = 0
	for fid in _selected_features:
		t += int(ProductCatalog.get_feature_by_id(fid).get("stakes", 0))
	return t


func _selected_dimension_shares() -> Dictionary:
	var acc := {"innovation": 0.0, "stability": 0.0, "usability": 0.0}
	for fid in _selected_features:
		var dc: Dictionary = ProductCatalog.get_feature_by_id(fid).get("dimension_contribution", {})
		for k in acc.keys():
			acc[k] += float(dc.get(k, 0.0))
	var total: float = acc["innovation"] + acc["stability"] + acc["usability"]
	if total <= 0.0:
		return {"innovation": 1.0 / 3.0, "stability": 1.0 / 3.0, "usability": 1.0 / 3.0}
	return {"innovation": acc["innovation"] / total, "stability": acc["stability"] / total, "usability": acc["usability"] / total}


func _axis_display_labels() -> Dictionary:
	var out := {"innovation": "İnovasyon", "stability": "Kararlılık", "usability": "Kullanılabilirlik"}
	for a in ProductCatalog.get_quality_axes(_selected_sub_product_type):
		out[String(a.get("axis", ""))] = String(a.get("display_label", a.get("axis", "")))
	return out


func _ensure_projection_profile() -> VBoxContainer:
	if _projection_profile != null and is_instance_valid(_projection_profile):
		return _projection_profile
	var vb := VBoxContainer.new()
	vb.name = "ProfileBox"
	vb.add_theme_constant_override("separation", 3)
	var right_vbox: Node = mentor_advisory_label.get_parent()
	right_vbox.add_child(vb)
	right_vbox.move_child(vb, mentor_advisory_label.get_index())  # sit just above the mentor line
	_projection_profile = vb
	return vb


func _paint_projection_profile() -> void:
	var box := _ensure_projection_profile()
	for c in box.get_children():
		c.queue_free()
	if _selected_features.is_empty():
		box.visible = false
		return
	box.visible = true
	var header := Label.new()
	header.text = "BU ÜRÜN NEYİ GÜÇLENDİRİYOR"
	header.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	header.add_theme_font_size_override("font_size", 10)
	box.add_child(header)
	var shares := _selected_dimension_shares()
	var labels := _axis_display_labels()
	for axis in ["innovation", "stability", "usability"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var cap := Label.new()
		cap.text = String(labels.get(axis, axis))
		cap.custom_minimum_size = Vector2(140, 0)
		cap.add_theme_color_override("font_color", UiTokens.INK)
		cap.add_theme_font_size_override("font_size", 11)
		row.add_child(cap)
		var pct: int = int(round(float(shares[axis]) * 100.0))
		var filled: int = clampi(int(round(float(shares[axis]) * 10.0)), 0, 10)
		var bar := Label.new()
		bar.text = "▓".repeat(filled) + "░".repeat(10 - filled) + "  %d%%" % pct
		bar.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
		bar.add_theme_font_size_override("font_size", 11)
		row.add_child(bar)
		box.add_child(row)


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
	if _v2_mode and _v2_strengthen_mode:
		# Pool exhausted: deepen an existing feature instead of adding a new one.
		if _selected_features.is_empty():
			return "Havuz tükendi — mevcut gücünü derinleştir. Hangi yanını?"
		return "%s derinleşecek. Diğer yanlar bir tık yavaşlar — seçim bu." % _strengthen_target_axis_label()
	if _v2_mode:
		# v2: type/name locked, up to MAX_VERSION_FEATURES; advise on the weak axis to target.
		var base_n: int = GameState.get_flag("mvp_components", []).size()
		if _selected_features.size() <= base_n:
			return "Zayıf yanını güçlendiren yeni bir feature ekle — v2 büyüme demek."
		return "Zayıf yanın %s. Onu besleyen feature ekle, rakibi orada geç." % _weakest_axis_label()
	if _selected_sub_product_type == "":
		return "Soldan başla. Ne yaptığımıza karar verelim."
	if _selected_features.size() < 2:
		return "Ne yapacağına karar verelim. En az iki özellik."
	if _selected_features.size() > 4:
		return "Dört'ten fazlasını taşıyamayız."
	# Frank comments on the chosen profile (scope discipline + risk).
	var comp: int = _selected_total_complexity()
	var stakes: int = _selected_total_stakes()
	var tech: int = GameState.get_founder_skill("tech")
	if comp >= 12 and tech <= 1:
		return "Ağır bir liste, tech'in düşük. Bu bug yağmuru olabilir."
	if stakes >= 14:
		return "Riskli parçalar seçtin. Biri bozulursa itibarın yanar."
	if _selected_product_name == "":
		return "Fena değil. Şimdi ürününe bir isim ver."
	return "Hazır. Build'i başlat — fazları üst köşeden yöneteceksin."


# ---- Commit bar ----

func _refresh_commit_bar() -> void:
	if _v2_mode and _v2_strengthen_mode:
		_refresh_commit_bar_v2_strengthen()
		return
	if _v2_mode:
		_refresh_commit_bar_v2()
		return
	var valid: bool = _selected_sub_product_type != "" \
		and _selected_features.size() >= 2 \
		and _selected_features.size() <= 4 \
		and _selected_product_name != ""
	commit_bar.disabled = not valid
	# Speak the product name on the button when ready (commit-ceremony teaser; the
	# full decision card is Blok C).
	if valid:
		commit_bar.text = "%s'i inşa etmeye başla · %d özellik · ~%d gün" % [
			_selected_product_name, _selected_features.size(), ProductSystem.DEVELOPMENT_DAYS_BASE + _selected_total_complexity()]
	else:
		commit_bar.text = "BUILD'İ BAŞLAT"
	# Helpful "what's missing" hint.
	if not valid:
		if _selected_sub_product_type == "":
			reason_label.text = "Soldan bir ürün tipi seç."
		elif _selected_features.size() < 2:
			reason_label.text = "En az 2 özellik seç."
		elif _selected_features.size() > 4:
			reason_label.text = "En fazla 4 özellik taşıyabiliriz."
		else:
			reason_label.text = "Ürününe bir isim ver."
	reason_label.visible = not valid


func _refresh_commit_bar_v2() -> void:
	# Part 2B: v2 validity = at least one feature ADDED beyond the shipped set, union within cap.
	# Name/type are locked (inherited), so they're never the blocker.
	var base_n: int = GameState.get_flag("mvp_components", []).size()
	var added: int = max(0, _selected_features.size() - base_n)
	var valid: bool = added >= 1 and _selected_features.size() <= ProductSystem.MAX_VERSION_FEATURES
	commit_bar.disabled = not valid
	if valid:
		commit_bar.text = "v%d'i inşa et · +%d özellik · ~%d gün" % [
			int(GameState.get_flag("mvp_version", 1)) + 1, added,
			ProductSystem.DEVELOPMENT_DAYS_BASE + _selected_total_complexity()]
	else:
		commit_bar.text = "v%d GELİŞTİR" % (int(GameState.get_flag("mvp_version", 1)) + 1)
	if not valid:
		if added < 1:
			reason_label.text = "En az bir yeni özellik ekle — v2 büyüme demek."
		else:
			reason_label.text = "En fazla %d özellik taşıyabiliriz." % ProductSystem.MAX_VERSION_FEATURES
	reason_label.visible = not valid
	# Frank's last word in the commit card (v2 risk framing).
	if _commit_frank_label != null:
		_commit_frank_label.visible = valid
		if valid:
			_commit_frank_label.text = "Frank: \"Yeni feature, yeni bug. Ama büyümezsen geri kalırsın.\""


func _refresh_commit_bar_v2_strengthen() -> void:
	# Pool-deepening: the pool is exhausted, so the player picks 1..N existing features to
	# STRENGTHEN. Duration uses the WHOLE product's complexity (feature set is unchanged).
	var n: int = _selected_features.size()
	var valid: bool = n >= 1 and n <= ProductSystem.STRENGTHEN_MAX_PER_VERSION
	var next_v: int = int(GameState.get_flag("mvp_version", 1)) + 1
	commit_bar.disabled = not valid
	if valid:
		commit_bar.text = "v%d'i inşa et · %d güçlendirme · ~%d gün" % [
			next_v, n, ProductSystem.DEVELOPMENT_DAYS_BASE + _product_total_complexity()]
	else:
		commit_bar.text = "v%d GÜÇLENDİR" % next_v
	reason_label.text = "Güçlendirmek için en az bir mevcut özelliği seç." if not valid else ""
	reason_label.visible = not valid
	if _commit_frank_label != null:
		_commit_frank_label.visible = valid
		if valid:
			_commit_frank_label.text = "Frank: \"Yeni yüzey yok, yeni bug az. Ama derinleşmek de büyümektir.\""


func _product_total_complexity() -> int:
	# Whole live product's feature complexity — the strengthen build carries the full set.
	var t: int = 0
	for fid in GameState.get_flag("mvp_components", []):
		t += int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
	return t


func _strengthen_target_axis_label() -> String:
	# Aggregate dominant axis of the currently-picked strengthen features, in tip-özel labels.
	var acc := {"innovation": 0.0, "stability": 0.0, "usability": 0.0}
	for fid in _selected_features:
		var dc: Dictionary = ProductCatalog.get_feature_by_id(String(fid)).get("dimension_contribution", {})
		for ax in acc.keys():
			acc[ax] += float(dc.get(ax, 0.0))
	var labels: Dictionary = _axis_labels_for_shipped()
	var best: String = "innovation"
	var best_v: float = -INF
	for ax in ["innovation", "stability", "usability"]:
		if acc[ax] > best_v:
			best_v = acc[ax]
			best = ax
	return String(labels.get(best, best))


func _commit_frank_line() -> String:
	var comp: int = _selected_total_complexity()
	var stakes: int = _selected_total_stakes()
	var tech: int = GameState.get_founder_skill("tech")
	if comp >= 12 and tech <= 1:
		return "Ağır bir liste, tech'in düşük. Bug'a hazır ol."
	if stakes >= 14:
		return "Riskli parçalar var. Kırılırsa acıtır. Yine de — karar senin."
	return "Fena değil. Bas, fazları üstten yönet."


func _on_commit_pressed() -> void:
	if commit_bar.disabled:
		return
	var founder = CharacterRegistry.get_founder()
	var founder_id: String = founder.id if founder != null else "char_founder"
	var ok: bool
	if _v2_mode and _v2_strengthen_mode:
		# Pool-deepening: feature set is unchanged (whole product); pass the strengthen picks.
		ok = ProductSystem.start_version_build([], founder_id, _selected_features.duplicate())
	elif _v2_mode:
		# Part 2B: pass only the ADDED features; start_version_build unions them onto the
		# shipped set and seeds axes from the live product.
		var base: Array = GameState.get_flag("mvp_components", [])
		var added: Array[String] = []
		for fid in _selected_features:
			if not base.has(fid):
				added.append(String(fid))
		ok = ProductSystem.start_version_build(added, founder_id)
	else:
		ok = ProductSystem.start_build(_selected_sub_product_type, _selected_features, founder_id, _selected_product_name)
	if ok:
		# Reset transient state — router will take over to BuildProgressView
		_v2_mode = false
		_v2_strengthen_mode = false
		_selected_sub_product_type = ""
		_selected_features = []
		_selected_product_name = ""
		name_input.text = ""
		# A3: auto-unpause ONLY if the game was paused, so a player at 2x/4x keeps
		# their chosen speed instead of being slammed back to 1x on every commit.
		if TimeManager.current_speed == 0:
			EventBus.speed_change_requested.emit(1)
		_refresh_view()


func _on_v2_pressed() -> void:
	# Part 2B: open the design view in v2 mode, pre-filled from the live product. The build
	# doesn't exist yet, so _refresh_view's v2-mode branch keeps us on DesignDocumentView.
	_v2_mode = true
	_selected_sub_product_type = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	# Pool exhausted → strengthen sub-mode (pick existing features to deepen); else add-mode.
	_v2_strengthen_mode = _pool_exhausted(_selected_sub_product_type)
	_selected_features = []
	if not _v2_strengthen_mode:
		for fid in GameState.get_flag("mvp_components", []):
			_selected_features.append(String(fid))   # add-mode: existing pre-checked (locked)
	# strengthen-mode: _selected_features stays EMPTY → it holds the strengthen picks.
	_selected_product_name = String(GameState.get_flag("mvp_product_name", ""))
	name_input.text = _selected_product_name
	_refresh_view()


func _pool_exhausted(sub_id: String) -> bool:
	# Every pool feature already in the product → nothing new to add (strengthen instead).
	var mvp: Array = GameState.get_flag("mvp_components", [])
	for f in ProductCatalog.get_feature_pool(sub_id):
		if not mvp.has(String(f.get("id", ""))):
			return false
	return true


func _on_v2_cancel_pressed() -> void:
	# Escape hatch: drop v2 planning, return to the live product management center.
	_v2_mode = false
	_v2_strengthen_mode = false
	_selected_sub_product_type = ""
	_selected_features = []
	_selected_product_name = ""
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
	# C2: BuildProgressView in the Yön A language — two-column control panel that
	# mirrors PostShipView. Left = progress + live dimension climb + günlük gelişim
	# feed; right = status + the phase-transition DECISION card (weighty, not a
	# corner popup) + Frank. The decision buttons call the same ProductSystem API
	# the old BuildHUD overlay did; that overlay is suppressed while this view is up.
	_ensure_build_progress_scaffold()

	# Header: name + feature summary chip
	bp_sub_type_label.text = b.product_name if b.product_name != "" else _sub_product_type_name(b.sub_product_type_id)
	_clear(_bp_phase_row)
	_bp_phase_row.add_child(UiFactory.make_label(_build_feature_summary(b), &"RowMeta"))

	# Top-right phase chip
	_clear(_bp_status_chip_slot)
	var chip_text: String = ""
	var chip_kind: StringName = &"neutral"
	match b.current_phase:
		"iteration":
			chip_text = "Karar bekleniyor" if b.iteration_decision_pending else "İterasyon %d" % b.iteration_count
			chip_kind = &"attention" if b.iteration_decision_pending else &"accent"
		"development":
			chip_text = "Geliştirme"
			chip_kind = &"accent"
		"bugfix", "polish":
			chip_text = "Bug Fixing"
			chip_kind = &"attention"
	_bp_status_chip_slot.add_child(UiFactory.make_badge(chip_text, chip_kind))

	# Progress bar + caption (bar float → smooth hourly fill, B2)
	var bar_total: int = 1
	var bar_value: float = 0.0
	match b.current_phase:
		"iteration":
			bar_total = max(1, ProductSystem.ITERATION_LENGTH_DAYS)
			bar_value = float(bar_total) - b.iteration_days_in_current
			bp_progress_caption.text = "İterasyon %d · %d gün kaldı" % [b.iteration_count, int(ceil(b.iteration_days_in_current))]
		"development":
			bar_total = max(1, b.development_days_total)
			bar_value = b.development_days_elapsed
			bp_progress_caption.text = "Geliştirme · %d / %d gün" % [int(b.development_days_elapsed), b.development_days_total]
		"bugfix", "polish":
			bar_total = 1
			bar_value = 1
			bp_progress_caption.text = "Bug Fixing · yayın sende"
	bp_iteration_bar.max_value = float(bar_total)
	bp_iteration_bar.value = bar_value

	# Live dimension climb — raw axes (stability effective), same grammar as PostShip
	_clear(_bp_dim_list)
	var dims: Dictionary = QualityModel.economy_dims_from_build(b)
	var axes: Array = ProductCatalog.get_quality_axes(b.sub_product_type_id)
	var labels := {"innovation": "İnovasyon", "stability": "Kararlılık", "usability": "Kullanılabilirlik"}
	for a in axes:
		labels[String(a.get("axis", ""))] = String(a.get("display_label", a.get("axis", "")))
	for axis in ["innovation", "stability", "usability"]:
		_bp_dim_list.add_child(_bp_dim_row(String(labels.get(axis, axis)), int(round(float(dims.get(axis, 0.0))))))

	# Right column: status rows
	_clear(_bp_status_slot)
	var comp: int = int(round(QualityModel.composite_quality(dims, axes)))
	_bp_status_slot.add_child(_bp_status_row("Kalite", "%d" % comp, null))
	var bug_pal: Dictionary = UiTokens.bug_severity(b.bug_count)
	_bp_status_slot.add_child(_bp_status_row("Bug", "%d" % b.bug_count, bug_pal.fg))
	var phase_names := {"iteration": "İterasyon", "development": "Geliştirme", "bugfix": "Bug Fixing", "polish": "Bug Fixing"}
	_bp_status_slot.add_child(_bp_status_row("Faz", String(phase_names.get(b.current_phase, b.current_phase)), null))
	var remaining_txt: String = "—"
	match b.current_phase:
		"iteration":
			remaining_txt = "Karar bekleniyor" if b.iteration_decision_pending else ("%d gün" % int(ceil(b.iteration_days_in_current)))
		"development":
			remaining_txt = "%d gün kaldı" % int(ceil(max(0.0, float(b.development_days_total) - b.development_days_elapsed)))
	_bp_status_slot.add_child(_bp_status_row("Kalan", remaining_txt, null))

	# Decision card + Frank
	_paint_bp_decision(b)
	bp_mentor_line.text = _bp_mentor_text(b)

	# Feed bootstrap (first paint for this build)
	if _seen_build_id != b.id:
		_seen_build_id = b.id
		_clear_feed(bp_feed_list)
		_prepend_feed_entry(bp_feed_list, b.start_day, "Build başladı.")
		_last_polish_bug_count = -1


# ---- C2 BuildProgressView Yön A scaffold + helpers ----

func _reparent(node: Node, new_parent: Node) -> void:
	var p: Node = node.get_parent()
	if p != null:
		p.remove_child(node)
	new_parent.add_child(node)


func _ensure_build_progress_scaffold() -> void:
	# Build the two-column Yön A layout ONCE, reparenting the authored bp_* leaves
	# we keep into it (their @onready refs stay valid). Never call per-paint.
	if _bp_scaffold_built:
		return
	_bp_scaffold_built = true
	build_progress_view.add_theme_constant_override("separation", 12)
	var header_panel: Node = build_progress_view.get_node_or_null("BuildHeaderPanel")
	var bottom_row: Node = build_progress_view.get_node_or_null("BottomRow")

	# TOP STRIP — title + phase | status chip
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	_bp_title_group = VBoxContainer.new()
	_bp_title_group.add_theme_constant_override("separation", 2)
	_bp_title_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reparent(bp_sub_type_label, _bp_title_group)
	bp_sub_type_label.theme_type_variation = &"TitleSerif"
	_bp_phase_row = HBoxContainer.new()
	_bp_phase_row.add_theme_constant_override("separation", 5)
	_bp_title_group.add_child(_bp_phase_row)
	top.add_child(_bp_title_group)
	_bp_status_chip_slot = HBoxContainer.new()
	_bp_status_chip_slot.add_theme_constant_override("separation", 6)
	_bp_status_chip_slot.size_flags_horizontal = Control.SIZE_SHRINK_END
	_bp_status_chip_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_bp_status_chip_slot)
	build_progress_view.add_child(top)
	build_progress_view.add_child(HSeparator.new())

	# MAIN ROW — two columns
	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 16)
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 10)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_row.add_child(left)
	main_row.add_child(right)
	build_progress_view.add_child(main_row)

	# LEFT: progress card (caption + bar) + BOYUTLAR + GÜNLÜK GELİŞİM feed
	left.add_child(_two_ended_header("İlerleme", "Nasıl Gidiyor"))
	var prog_body := VBoxContainer.new()
	prog_body.add_theme_constant_override("separation", 8)
	_reparent(bp_progress_caption, prog_body)
	bp_progress_caption.theme_type_variation = &"NameSerif"
	_reparent(bp_iteration_bar, prog_body)
	bp_iteration_bar.custom_minimum_size = Vector2(0, 10)
	left.add_child(UiFactory.make_card(prog_body))
	left.add_child(UiFactory.make_section_header("Boyutlar"))
	_bp_dim_list = VBoxContainer.new()
	_bp_dim_list.add_theme_constant_override("separation", 6)
	left.add_child(_bp_dim_list)
	left.add_child(UiFactory.make_section_header("Günlük Gelişim"))
	var feed_scroll: Node = bp_feed_list.get_parent()   # authored FeedScroll
	if feed_scroll != null:
		_reparent(feed_scroll, left)
		if feed_scroll is Control:
			(feed_scroll as Control).custom_minimum_size = Vector2(0, 120)

	# RIGHT: status card + decision card (attention) + Frank card
	right.add_child(_two_ended_header("Durum", "Ne Oluyor"))
	_bp_status_slot = VBoxContainer.new()
	_bp_status_slot.add_theme_constant_override("separation", 6)
	right.add_child(UiFactory.make_card(_bp_status_slot))
	var dec_body := VBoxContainer.new()
	dec_body.add_theme_constant_override("separation", 8)
	_bp_decision_title = UiFactory.make_label("", &"NameSerif")
	_bp_decision_desc = UiFactory.make_label("", &"RowMeta")
	_bp_decision_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dec_body.add_child(_bp_decision_title)
	dec_body.add_child(_bp_decision_desc)
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	_bp_iter_btn = Button.new()
	_bp_iter_btn.text = "Bir iterasyon daha"
	_bp_iter_btn.pressed.connect(_on_bp_iteration_pressed)
	_bp_dev_btn = Button.new()
	_bp_dev_btn.theme_type_variation = &"CommitButton"
	_bp_dev_btn.text = "Development'a geç"
	_bp_dev_btn.pressed.connect(_on_bp_development_pressed)
	_bp_launch_btn = Button.new()
	_bp_launch_btn.theme_type_variation = &"CommitButton"
	_bp_launch_btn.text = "Yayınla"
	_bp_launch_btn.pressed.connect(_on_bp_launch_pressed)
	btn_row.add_child(_bp_iter_btn)
	btn_row.add_child(_bp_dev_btn)
	btn_row.add_child(_bp_launch_btn)
	dec_body.add_child(btn_row)
	_bp_decision_card = UiFactory.make_card(dec_body, false, true)   # attention card = weight
	right.add_child(_bp_decision_card)
	var frank_body := VBoxContainer.new()
	frank_body.add_theme_constant_override("separation", 4)
	frank_body.add_child(UiFactory.make_section_header("Frank"))
	_reparent(bp_mentor_line, frank_body)
	bp_mentor_line.theme_type_variation = &"QuoteSerif"
	bp_mentor_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(UiFactory.make_card(frank_body))

	# Retire the authored old-style panels (their kept leaves were reparented out).
	if header_panel is CanvasItem:
		(header_panel as CanvasItem).visible = false
	if bottom_row is CanvasItem:
		(bottom_row as CanvasItem).visible = false


func _bp_dim_row(label: String, score: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var cap: Label = UiFactory.make_label(label, &"NameSerif")
	cap.custom_minimum_size = Vector2(120, 0)
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(cap)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.custom_minimum_size = Vector2(0, 8)
	bar.show_percentage = false
	bar.max_value = 100.0
	bar.value = float(clampi(score, 0, 100))
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_override_bar_fill(bar, _score_color(score))
	row.add_child(bar)
	var val: Label = UiFactory.make_label("%d" % score, &"MetricValueInk")
	val.add_theme_font_size_override("font_size", 22)
	val.custom_minimum_size = Vector2(40, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	return row


func _bp_status_row(label: String, value: String, value_color) -> HBoxContainer:
	var row := HBoxContainer.new()
	var l: Label = UiFactory.make_label(label, &"RowMeta", UiTokens.INK_DIM)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	var v: Label = UiFactory.make_label(value, &"RowName", value_color)
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(v)
	return row


func _paint_bp_decision(b: FeatureBuild) -> void:
	_bp_decision_card.visible = true
	match b.current_phase:
		"iteration":
			if b.iteration_decision_pending:
				_bp_decision_title.text = "İterasyon %d bitti — karar ver" % b.iteration_count
				_bp_decision_desc.text = "Devam et: kalite tavanı yükselir ama runway yanar. İlerle: daha hızlı, daha düşük tavan. Klasik kurucu kararı."
				_bp_iter_btn.visible = true
				_bp_dev_btn.visible = true
				_bp_launch_btn.visible = false
			else:
				_bp_decision_title.text = "Tasarım sürüyor"
				_bp_decision_desc.text = "İterasyon ilerliyor — İnovasyon ve Kullanılabilirlik saat saat tırmanıyor. Süre dolunca karar verirsin."
				_bp_iter_btn.visible = false
				_bp_dev_btn.visible = false
				_bp_launch_btn.visible = false
		"development":
			_bp_decision_title.text = "Geliştirme sürüyor"
			_bp_decision_desc.text = "Otomatik ilerliyor — Kararlılık tırmanıyor, bug birikiyor. Bugfix'e kadar bekle."
			_bp_iter_btn.visible = false
			_bp_dev_btn.visible = false
			_bp_launch_btn.visible = false
		"bugfix", "polish":
			_bp_decision_title.text = "Yayına hazır"
			_bp_decision_desc.text = "Bug'lar temizleniyor. Hazır olduğunda yayınla — mükemmeli bekleme, runway eriyor."
			_bp_iter_btn.visible = false
			_bp_dev_btn.visible = false
			_bp_launch_btn.visible = true


func _bp_mentor_text(b: FeatureBuild) -> String:
	match b.current_phase:
		"iteration":
			return "Yeterince iyi mi? Development'a geç — para yanıyor. Değilse bir tur daha." if b.iteration_decision_pending else _iteration_mentor_line_for(b)
		"development":
			return "Çalışıyor. Bug birikiyor — normal, bugfix'te toplarsın." if b.bug_count >= 8 else "Çalışıyor. Sen izle."
		"bugfix", "polish":
			return "Bu kadar bug'la çıkma. Ama çok da bekleme — runway eriyor." if b.bug_count > 6 else "Temiz görünüyor. Hazır olduğunda yayınla."
	return ""


func _on_bp_iteration_pressed() -> void:
	ProductSystem.advance_iteration()
	_refresh_view()


func _on_bp_development_pressed() -> void:
	ProductSystem.enter_development()
	_refresh_view()


func _on_bp_launch_pressed() -> void:
	ProductSystem.launch()
	_refresh_view()


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
	# Token-driven severity chip: green (0) → amber (1-2) → red (3+).
	var pal: Dictionary = UiTokens.bug_severity(bug_count)
	sb.bg_color = pal.bg
	value_label.add_theme_color_override("font_color", pal.fg)
	panel.add_theme_stylebox_override("panel", sb)


# ---- Mentor line helpers ----

func _iteration_mentor_line_for(b: FeatureBuild) -> String:
	# Mentor cadence within the current iteration. iteration_days_in_current
	# decrements from ITERATION_LENGTH_DAYS → 0.
	var total: int = max(1, ProductSystem.ITERATION_LENGTH_DAYS)
	var elapsed: float = float(total) - b.iteration_days_in_current
	var ratio: float = elapsed / float(total)
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
	day_label.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	day_label.add_theme_font_size_override("font_size", 11)
	day_label.custom_minimum_size = Vector2(46, 0)
	var msg_label := Label.new()
	msg_label.text = message
	msg_label.add_theme_color_override("font_color", UiTokens.INK)
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
	# Yön A control panel (redesign): top strip (title + health) → two columns (status left,
	# actions right) → bottom strip (rival + Frank). Same data, new layout.
	_ensure_post_ship_scaffold()
	var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
	var quality: int = int(round(QualityModel.shipped_normalized()))
	var funnel_card: Node = _left_funnel_body.get_parent()   # the make_card wrapper
	# Market branch — B2C: funnel (left) + pricing action (right). B2B: status text + sales action.
	if market == "b2c":
		post_ship_status_body.visible = false
		_b2b_info.visible = false
		funnel_card.visible = true
		var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
		_paint_status_funnel(int(GameState.get_flag("b2c_audience", 0)), CustomerRegistry.get_total_users(), GameState.mrr, is_open)
		post_ship_sales_button.visible = false
	else:
		if _status_funnel != null:
			_status_funnel.visible = false
		funnel_card.visible = false
		_b2b_info.visible = true
		post_ship_status_body.visible = true
		if _pricing_panel != null:
			_pricing_panel.visible = false
		var custn: int = CustomerRegistry.get_active().size()
		if custn == 0:
			post_ship_status_body.text = "İlk pitch'in Sales sekmesinde seni bekliyor." if ProspectRegistry.has_any() \
				else "Henüz müşteri yok — Frank seni biriyle tanıştıracak."
		else:
			post_ship_status_body.text = "%d müşteri · MRR $%d." % [custn, GameState.mrr]
		post_ship_sales_button.visible = true

	# LEFT column — dimensions (bars + version delta) + status chips.
	_paint_dimensions()
	_paint_status_chips()
	# RIGHT column — action rows (pricing renders inside the price detail slot).
	_paint_action_card()
	# TOP strip — title + version + big health badge. BOTTOM strip — rival + Frank.
	_paint_top_strip()
	_paint_bottom_strip(quality)

	# TRACTION north-star — reparented into LeftCol (uncut); refs unchanged.
	post_ship_traction_bar.value = SalesSystem.traction_progress()
	post_ship_traction_label.text = "MRR $%d / $%d" % [GameState.mrr, SalesSystem.TRACTION_MRR_TARGET]
	_paint_traction_chip(GameState.get_flag("ready_for_traction", false))


func _ensure_post_ship_scaffold() -> void:
	# Build the two-column scaffold ONCE and reparent the authored PostShip nodes into it.
	# @onready refs are node instances (NodePaths resolved at tree-entry) → reparenting keeps
	# them valid. Same trick _build_commit_card already relies on. Never call this per-paint.
	if _scaffold_built:
		return
	_scaffold_built = true
	# TOP STRIP — title group (title + version row) | health slot ------------------------
	_top_strip = HBoxContainer.new()
	_top_strip.add_theme_constant_override("separation", 12)
	var title_group := VBoxContainer.new()
	title_group.add_theme_constant_override("separation", 2)
	title_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	post_ship_title.get_parent().remove_child(post_ship_title)
	post_ship_title.theme_type_variation = &"TitleSerif"       # big serif (token reuse)
	title_group.add_child(post_ship_title)
	_version_row = HBoxContainer.new()
	_version_row.add_theme_constant_override("separation", 5)
	title_group.add_child(_version_row)
	_top_strip.add_child(title_group)
	_health_slot = HBoxContainer.new()
	_health_slot.add_theme_constant_override("separation", 6)
	_health_slot.size_flags_horizontal = Control.SIZE_SHRINK_END
	_health_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_top_strip.add_child(_health_slot)
	post_ship_view.add_child(_top_strip)
	post_ship_view.add_child(HSeparator.new())
	# MAIN ROW — two columns -------------------------------------------------------------
	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 16)
	_left_col = VBoxContainer.new()
	_left_col.add_theme_constant_override("separation", 10)
	_left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_right_col = VBoxContainer.new()
	_right_col.add_theme_constant_override("separation", 10)
	_right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_row.add_child(_left_col)
	main_row.add_child(_right_col)
	post_ship_view.add_child(main_row)
	# LEFT scaffolding: header, dims, chips, funnel card, reparented traction ------------
	_left_col.add_child(_two_ended_header("Ürün Durumu", "Nasıl Gidiyor"))
	_dim_list = VBoxContainer.new()
	_dim_list.add_theme_constant_override("separation", 6)
	_left_col.add_child(_dim_list)
	_chips_row = HFlowContainer.new()
	_chips_row.add_theme_constant_override("h_separation", 6)
	_chips_row.add_theme_constant_override("v_separation", 4)
	_left_col.add_child(_chips_row)
	_left_funnel_body = VBoxContainer.new()
	_left_funnel_body.add_theme_constant_override("separation", 8)
	_left_col.add_child(UiFactory.make_card(_left_funnel_body))
	post_ship_traction_panel.get_parent().remove_child(post_ship_traction_panel)
	_left_col.add_child(post_ship_traction_panel)   # uncut now — grows with the column
	# RIGHT scaffolding: header, B2B info (reparented), action list ----------------------
	_right_col.add_child(_two_ended_header("Ne Yapacaksın?", "Bir Kol Seç"))
	_b2b_info = VBoxContainer.new()
	_b2b_info.add_theme_constant_override("separation", 8)
	_b2b_info.visible = false
	post_ship_status_body.get_parent().remove_child(post_ship_status_body)
	_b2b_info.add_child(post_ship_status_body)
	post_ship_sales_button.get_parent().remove_child(post_ship_sales_button)
	_b2b_info.add_child(post_ship_sales_button)
	_right_col.add_child(_b2b_info)
	_action_list = VBoxContainer.new()
	_action_list.add_theme_constant_override("separation", 8)
	_right_col.add_child(_action_list)
	# BOTTOM STRIP — rival line + reparented Frank card ----------------------------------
	post_ship_view.add_child(HSeparator.new())
	_bottom_strip = VBoxContainer.new()
	_bottom_strip.add_theme_constant_override("separation", 8)
	_rival_line = Label.new()
	_rival_line.add_theme_font_size_override("font_size", 12)
	_rival_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bottom_strip.add_child(_rival_line)
	post_ship_frank_panel.get_parent().remove_child(post_ship_frank_panel)
	_bottom_strip.add_child(post_ship_frank_panel)
	post_ship_view.add_child(_bottom_strip)
	# retire the legacy authored "DURUM" card (its body/funnel now live in the columns)
	post_ship_status_panel.visible = false


func _two_ended_header(left_text: String, right_text: String) -> HBoxContainer:
	var hb := HBoxContainer.new()
	var l := UiFactory.make_section_header(left_text)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(l)
	var r := UiFactory.make_label(right_text.to_upper(), &"SectionLabel", UiTokens.INK_DIM)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hb.add_child(r)
	return hb


func _ensure_status_funnel() -> void:
	if _status_funnel != null:
		return
	_status_funnel = HBoxContainer.new()
	_status_funnel.add_theme_constant_override("separation", 14)
	_left_funnel_body.add_child(_status_funnel)   # Yön A: funnel lives in the LeftCol card


func _paint_status_funnel(audience: int, paying: int, mrr: int, is_open: bool) -> void:
	_ensure_status_funnel()
	_clear(_status_funnel)
	_status_funnel.visible = true
	_status_funnel.add_child(UiFactory.make_stat("Deneyen", str(audience)))
	if is_open:
		_status_funnel.add_child(_funnel_arrow())
		_status_funnel.add_child(UiFactory.make_stat("Ödeyen", str(paying)))
		_status_funnel.add_child(_funnel_arrow())
		_status_funnel.add_child(UiFactory.make_stat("MRR", _fmt_money(mrr)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_funnel.add_child(spacer)
	var band: String = SalesSystem.growth_band()
	var kind: StringName = &"neutral"
	if band == "hızlı büyüyor" or band == "büyüyor":
		kind = &"positive"
	elif band == "eriyor":
		kind = &"negative"
	var chip: Control = UiFactory.make_badge(band, kind)
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_status_funnel.add_child(chip)


func _funnel_arrow() -> Label:
	var a: Label = UiFactory.make_label("→", &"MetricValueInk", UiTokens.INK_DIM)
	a.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return a


func _paint_traction_chip(ready: bool) -> void:
	if _traction_chip != null and is_instance_valid(_traction_chip):
		_traction_chip.get_parent().remove_child(_traction_chip)
		_traction_chip.queue_free()
		_traction_chip = null
	if ready:
		_traction_chip = UiFactory.make_badge("Hazır — Frank'le konuş", &"positive")
		post_ship_traction_label.get_parent().add_child(_traction_chip)


func _on_post_ship_sales_pressed() -> void:
	EventBus.tab_changed.emit("sales")


# =========================================================================
#  B1 status card + B2 action card + B4 wear-aware Frank (Product Lifecycle 2A)
# =========================================================================

const HEALTH_STAB_MARGIN := 10.0   # effective stability this far below raw → yıpranıyor
const HEALTH_BUG_WARN := 8         # or this many live bugs → yıpranıyor


func _sprinting() -> bool:
	var a = ProductSystem.get_active_build()
	return a != null and a.is_bug_sprint


func _live_bugs() -> int:
	return int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0)))


func _post_ship_composite() -> float:
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	return QualityModel.composite_quality(QualityModel.economy_dims_from_flags(), ProductCatalog.get_quality_axes(sub))


func _product_health() -> String:
	if _sprinting():
		return "toparlanıyor"
	var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
	if market == "b2c" and SalesSystem._audience_delta_per_hour() < 0.0:
		return "eriyor"
	var raw_stab: float = float(GameState.get_flag("mvp_stability", 0.0))
	var eff: float = QualityModel.effective_stability(raw_stab, _live_bugs())
	if (raw_stab - eff) >= HEALTH_STAB_MARGIN or _live_bugs() >= HEALTH_BUG_WARN:
		return "yıpranıyor"
	return "sağlıklı"


func _health_kind(h: String) -> StringName:
	match h:
		"eriyor": return &"negative"
		"yıpranıyor": return &"attention"
		"toparlanıyor": return &"accent"
		_: return &"positive"


func _rival_passed_name() -> String:
	# Closest same-type STARTUP rival above the player — but only a meaningful "you
	# fell behind" signal when the player is in the LOWER HALF of the startup league
	# (not merely because one stronger startup exists; a 2/6 product isn't "passed").
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var player: float = _post_ship_composite()
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, player)
	if int(rank["rank"]) <= int(ceil(float(int(rank["total"])) / 2.0)):
		return ""
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var passer: String = ""
	var best: float = INF
	for r in RivalRegistry.get_by_type(sub):
		if r.tier == "startup":
			var c: float = r.composite(axes)
			if c > player and c < best:
				best = c
				passer = r.product_name
	return passer


func _axis_labels_for_shipped() -> Dictionary:
	var out := {"innovation": "İnovasyon", "stability": "Kararlılık", "usability": "Kullanılabilirlik"}
	for a in ProductCatalog.get_quality_axes(String(GameState.get_flag("mvp_sub_product_type_id", ""))):
		out[String(a.get("axis", ""))] = String(a.get("display_label", a.get("axis", "")))
	return out


func _paint_dimensions() -> void:
	# Three dimension rows: label | bar (fill=score, state color) | big number | version delta.
	# Innovation/Usability: single version-over-version delta. Stability: DUAL info — big number
	# = effective (bug-eroded), green version delta (raw gain = "the build worked"), red bug badge.
	_clear(_dim_list)
	var L: Dictionary = _axis_labels_for_shipped()
	var inn: int = int(round(float(GameState.get_flag("mvp_innovation", 0.0))))
	var usa: int = int(round(float(GameState.get_flag("mvp_usability", 0.0))))
	var raw: int = int(round(float(GameState.get_flag("mvp_stability", 0.0))))
	var eff: int = int(round(QualityModel.effective_stability(float(GameState.get_flag("mvp_stability", 0.0)), _live_bugs())))
	_dim_list.add_child(_dim_row(L["innovation"], inn, inn, _ver_delta("mvp_innovation"), null))
	var bug_drop: int = raw - eff
	var bug_badge: Control = null
	var stab_color = null
	if bug_drop > 0:
		bug_badge = UiFactory.make_badge("🐛 −%d" % bug_drop, &"negative")
		stab_color = UiTokens.NEGATIVE
	_dim_list.add_child(_dim_row(L["stability"], eff, eff, _ver_delta("mvp_stability"), bug_badge, stab_color))
	_dim_list.add_child(_dim_row(L["usability"], usa, usa, _ver_delta("mvp_usability"), null))


func _dim_row(label: String, bar_score: int, big: int, ver_delta: int, extra_badge: Control, num_color = null) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var cap: Label = UiFactory.make_label(label, &"NameSerif")
	cap.custom_minimum_size = Vector2(120, 0)
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(cap)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"          # set FIRST, then override fill color
	bar.custom_minimum_size = Vector2(0, 8)
	bar.show_percentage = false
	bar.max_value = 100.0
	bar.value = float(clampi(bar_score, 0, 100))
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_override_bar_fill(bar, _score_color(bar_score))
	row.add_child(bar)
	var val: Label = UiFactory.make_label("%d" % big, &"MetricValueInk", num_color)
	val.add_theme_font_size_override("font_size", 24)    # the visual centerpiece (mockup big number)
	val.custom_minimum_size = Vector2(40, 0)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	var dtxt: String = ("+%d" % ver_delta) if ver_delta >= 0 else ("%d" % ver_delta)
	var db: Control = UiFactory.make_delta_badge(dtxt, ver_delta)
	db.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(db)
	if extra_badge != null:
		extra_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(extra_badge)
	return row


func _ver_delta(flag: String) -> int:
	# Version-over-version gain (display-only mvp_*_prev snapshot written at launch()).
	return int(round(float(GameState.get_flag(flag, 0.0)))) - int(round(float(GameState.get_flag(flag + "_prev", 0.0))))


func _score_color(s: int) -> Color:
	if s >= 67:
		return UiTokens.HEALTH_GREEN
	if s >= 34:
		return UiTokens.HEALTH_AMBER
	return UiTokens.NEGATIVE


func _override_bar_fill(bar: ProgressBar, c: Color) -> void:
	# BuildProgress's amber fill → per-bar state color. Must run AFTER theme_type_variation is set.
	var fill: StyleBox = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var f: StyleBoxFlat = fill.duplicate()
		f.bg_color = c
		bar.add_theme_stylebox_override("fill", f)


func _paint_status_chips() -> void:
	_clear(_chips_row)
	var bugs: int = _live_bugs()
	var dir: String = "azalıyor" if _sprinting() else "artıyor"
	var bug_kind: StringName = &"positive"
	if bugs > 2:
		bug_kind = &"negative"
	elif bugs > 0:
		bug_kind = &"attention"
	_chips_row.add_child(UiFactory.make_badge("◆ %d bug · %s" % [bugs, dir], bug_kind))
	var ver: int = int(GameState.get_flag("mvp_version", 1))
	var age_txt: String = "🕐 v%d · canlı" % ver
	if GameState.has_flag("mvp_launch_day"):
		var days: int = max(0, GameState.day - int(GameState.get_flag("mvp_launch_day", GameState.day)))
		age_txt = "🕐 v%d · %d gün canlı" % [ver, days]
	_chips_row.add_child(UiFactory.make_badge(age_txt, &"neutral"))


func _paint_top_strip() -> void:
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname == "":
		pname = _sub_product_type_name(String(GameState.get_flag("mvp_sub_product_type_id", "")))
	post_ship_title.text = pname
	var ver: int = int(GameState.get_flag("mvp_version", 1))
	var h: String = _product_health()
	var hc: Color = UiTokens.health_color(_health_state(h))
	_clear(_version_row)
	_version_row.add_child(UiFactory.make_label("V%d ·" % ver, &"RowMeta"))
	var dot: Control = UiFactory.make_dot(hc, 7)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_version_row.add_child(dot)
	_version_row.add_child(UiFactory.make_label("CANLI", &"RowMeta"))
	_clear(_health_slot)
	var bigdot: Control = UiFactory.make_dot(hc, 9)
	bigdot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_health_slot.add_child(bigdot)
	_health_slot.add_child(UiFactory.make_badge(h, _health_kind(h)))


func _health_state(h: String) -> StringName:
	# Map the Turkish health word → health_color() state (healthy/warn/bad).
	match h:
		"eriyor": return &"bad"
		"yıpranıyor": return &"warn"
		_: return &"healthy"   # sağlıklı / toparlanıyor


func _paint_bottom_strip(quality: int) -> void:
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, _post_ship_composite())
	var passer: String = _rival_passed_name()
	_rival_line.text = String(rank["text"]) + ("  —  %s seni geçti." % passer if passer != "" else "")
	_rival_line.add_theme_color_override("font_color", UiTokens.NEGATIVE if passer != "" else UiTokens.INK_MUTED)
	post_ship_frank_line.text = _post_ship_frank_text(quality)


func _ensure_action_card() -> void:
	# Yön A: three stacked selectable action ROWS; price expands the pricing panel inline.
	if _action_built:
		return
	_action_built = true
	_sprint_banner = VBoxContainer.new()
	_sprint_banner.add_theme_constant_override("separation", 4)
	_sprint_banner.visible = false
	_action_list.add_child(_sprint_banner)
	_action_rows["price"] = _make_action_row("price", "◆", "Fiyatlandır")
	_price_detail_slot = VBoxContainer.new()
	_action_list.add_child(_price_detail_slot)   # the pricing panel mounts here (expanded detail)
	_action_rows["sprint"] = _make_action_row("sprint", "🐛", "Bug Sprinti")
	_action_rows["v2"] = _make_action_row("v2", "▲", "Geliştir")


func _make_action_row(id: String, icon: String, title: String) -> Dictionary:
	var root: PanelContainer = UiFactory.make_card(null, true)   # CardPanelTight
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	var ic: Label = UiFactory.make_label(icon, &"NameSerif")
	ic.custom_minimum_size = Vector2(22, 0)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(ic)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var t: Label = UiFactory.make_label(title, &"NameSerif")
	var d: Label = UiFactory.make_label("", &"RowMeta")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(t)
	vb.add_child(d)
	hb.add_child(vb)
	var s: Label = UiFactory.make_label("", &"RowMeta")
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(s)
	root.add_child(hb)
	_set_mouse_ignore(hb)                       # clicks bubble to the card's gui_input
	root.gui_input.connect(_on_action_row_input.bind(id))
	_action_list.add_child(root)
	return {"root": root, "title": t, "desc": d, "status": s}


func _set_mouse_ignore(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_set_mouse_ignore(c)


func _apply_action_selection(sel_id: String) -> void:
	# Selected row → pale-amber card with a 2px amber border (mockup). Others → base card.
	for id in _action_rows.keys():
		(_action_rows[id]["root"] as PanelContainer).remove_theme_stylebox_override("panel")
	if _action_rows.has(sel_id):
		var root: PanelContainer = _action_rows[sel_id]["root"]
		var sel: StyleBoxFlat = (root.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
		sel.bg_color = UiTokens.AMBER_BG
		sel.border_color = UiTokens.ACCENT
		sel.set_border_width_all(2)
		root.add_theme_stylebox_override("panel", sel)


func _paint_action_card() -> void:
	_ensure_action_card()
	var is_b2c: bool = (String(GameState.get_flag("mvp_market_type", "b2c")) == "b2c")
	# Price row + its pricing detail exist only in B2C (B2B uses _b2b_info instead).
	_action_rows["price"]["root"].visible = is_b2c
	_price_detail_slot.visible = is_b2c and _active_action == "price"
	if is_b2c and _active_action == "price":
		_paint_pricing()
		if _pricing_panel != null:
			_pricing_panel.visible = true
	# Sprint mode banner (pricing stays live below it).
	if _sprinting():
		var b = ProductSystem.get_active_build()
		var remaining: int = int(ceil(max(0.0, float(b.development_days_total) - b.development_days_elapsed)))
		_sprint_banner.visible = true
		_clear(_sprint_banner)
		var bl := Label.new()
		bl.text = "Bug Sprinti · %d gün kaldı · 🐛 %d" % [remaining, _live_bugs()]
		bl.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
		bl.add_theme_font_size_override("font_size", 12)
		_sprint_banner.add_child(bl)
		var bar := ProgressBar.new()
		bar.theme_type_variation = &"BuildProgress"
		bar.custom_minimum_size = Vector2(0, 6)
		bar.show_percentage = false
		bar.max_value = float(max(1, b.development_days_total))
		bar.value = float(b.development_days_elapsed)
		_sprint_banner.add_child(bar)
	else:
		_sprint_banner.visible = false
	# Price row copy.
	_action_rows["price"]["desc"].text = "Fiyatı ayarla, dönüşüm ve MRR'yi optimize et"
	_action_rows["price"]["status"].text = ("Canlı · $%d" % int(GameState.get_flag("b2c_price", 0))) \
		if GameState.get_flag("b2c_paid_tier_open", false) else "Taslak"
	# Sprint row copy + lock state.
	var bugs: int = _live_bugs()
	var sr: Dictionary = _action_rows["sprint"]
	if _sprinting():
		sr["title"].text = "Sprint sürüyor…"
		sr["desc"].text = "Bug'lar temizleniyor. Büyüme sprint bitince döner."
		sr["status"].text = "🐛 %d" % bugs
	elif bugs <= 0:
		sr["title"].text = "Temiz — sprint gerekmez"
		sr["desc"].text = "0 aktif bug. Şu an müdahale gerekmiyor."
		sr["status"].text = "0 BUG"
	else:
		sr["title"].text = "Bug Sprinti başlat"
		sr["desc"].text = "Bug'ları temizle — kararlılık geri gelir (büyüme durur)."
		sr["status"].text = "%d BUG · ~%d GÜN" % [bugs, ProductSystem.sprint_duration_for(bugs)]
	# v2/v4 growth row.
	var vr: Dictionary = _action_rows["v2"]
	var nextv: int = int(GameState.get_flag("mvp_version", 1)) + 1
	vr["title"].text = "v%d Geliştir" % nextv
	vr["desc"].text = "Yeni feature / güçlendirme — daha yüksek rekabet. (Yeni feature = yeni bug.)"
	vr["status"].text = "~%d GÜN" % (ProductSystem.DEVELOPMENT_DAYS_BASE + _product_total_complexity())
	# Dim locked rows: sprint locked while sprinting or clean; v2 locked while sprinting.
	sr["root"].modulate = Color(1, 1, 1, 0.55 if (_sprinting() or bugs <= 0) else 1.0)
	vr["root"].modulate = Color(1, 1, 1, 0.55 if _sprinting() else 1.0)
	# Selection highlight (price is the expandable default; stays selected through sprint mode).
	_apply_action_selection(_active_action if is_b2c else "")


func _on_action_row_input(ev: InputEvent, id: String) -> void:
	if not (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT):
		return
	match id:
		"price":
			_active_action = "price"
			_on_price_action_pressed()
			_paint_action_card()
		"sprint":
			if _sprinting() or _live_bugs() <= 0:
				return   # locked
			_on_bug_sprint_pressed()
		"v2":
			if _sprinting():
				return   # can't build a version mid-sprint
			_on_v2_pressed()


func _on_bug_sprint_pressed() -> void:
	if ProductSystem.start_bug_sprint():
		# A3: unpause only if paused — don't reset a 2x/4x player's speed.
		if TimeManager.current_speed == 0:
			EventBus.speed_change_requested.emit(1)
		_refresh_view()


func _on_price_action_pressed() -> void:
	# Pricing panel is always shown in B2C PostShip; soft anchor / ensure visible.
	if _pricing_panel != null and is_instance_valid(_pricing_panel):
		_pricing_panel.visible = true


func _post_ship_frank_text(_quality: int) -> String:
	if GameState.get_flag("bug_sprint_just_done", false):
		GameState.set_flag("bug_sprint_just_done", false)   # one-shot
		return "\"Temizlendi. Şimdi geri büyümeye bak.\""
	if _sprinting():
		return "\"Doğru iş. Bitir şunu, sonra geri büyürüz.\""
	if GameState.get_flag("needs_engineer", false):
		return "\"Sürekli bug'la boğuşuyorsun — birini alma vaktin geldi.\""
	var passer: String = _rival_passed_name()
	var health: String = _product_health()
	if health == "eriyor":
		# Bleeding: if BUGS are the lever (a sprint fixes it), point there; otherwise
		# it's competition — name the rival.
		if _live_bugs() >= HEALTH_BUG_WARN:
			return "\"Kan kaybediyorsun. Bug sprinti vakti — yoksa bu ürün ölür.\""
		if passer != "":
			return "\"%s seni geçti. Ya bir şey yap ya kaybol.\"" % passer
		return "\"Kan kaybediyorsun. Bug sprinti vakti — yoksa bu ürün ölür.\""
	var weak: String = _weakest_axis_label()
	if passer != "":
		# Not bleeding, but a rival passed → point at the growth arm + the weak axis to fix.
		return "\"Zayıf yanın %s — v2'de onu güçlendir, %s'i yakala.\"" % [weak, passer]
	if health == "yıpranıyor":
		return "\"Bug'lar birikiyor. Kullanıcılar henüz gitmedi ama fark ediyorlar.\""
	# Healthy: nudge toward v2 growth (Part 2B), naming the weak axis + the §10 risk.
	return "\"İyi gidiyor. Ama büyümezsen geri kalırsın. v2 riskli — yeni feature, yeni bug. Yine de zayıf yanın %s, orası büyümeyi hak ediyor.\"" % weak


func _weakest_axis_label() -> String:
	# Lowest-scoring axis (economy dims → stability already bug-eroded), in tip-özel labels.
	var dims: Dictionary = QualityModel.economy_dims_from_flags()
	var labels: Dictionary = _axis_labels_for_shipped()
	var worst: String = "innovation"
	var worst_v: float = INF
	for ax in ["innovation", "stability", "usability"]:
		var s: float = QualityModel.axis_score(dims, ax)
		if s < worst_v:
			worst_v = s
			worst = ax
	return String(labels.get(worst, worst))


func _on_sales_state_changed(_arg = null) -> void:
	# Repaint PostShip on revenue / customer / prospect changes (routes safely
	# even outside the post-ship state).
	_refresh_view()


# =========================================================================
#  Dynamic pricing lever (B2C) — value algorithm + free-price ruler + churn
# =========================================================================

func _paint_pricing() -> void:
	_ensure_pricing_panel()
	_pricing_panel.visible = true
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var floor_p: int = int(v["floor"])
	var can_read: bool = GameState.get_founder_skill("markets") >= SkillCheck.MARKETS_READ_THRESHOLD
	var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)

	# Ruler range: lower bound near floor, top open (optimal × 3).
	var smax: int = maxi(optimal * 3, floor_p + 4)
	_price_slider.min_value = 1
	_price_slider.max_value = smax
	if not _pricing_initialized:
		_price_slider.value = float(int(GameState.get_flag("b2c_price", optimal))) if is_open else float(optimal)
		_pricing_initialized = true

	_rebuild_header_chip(is_open)

	# Value anchor + rationale chips (Markets-gated A.2/A.3).
	_pricing_value_label.text = "~$%d" % optimal if can_read else "belirsiz"
	_rebuild_rationale(v["lines"], can_read)

	# Colored value spectrum (band = slider track) + floor/optimal notches + marks.
	_rebuild_bands(optimal, floor_p, smax, can_read)
	if can_read:
		_pricing_marks.text = "Alt sınır $%d   ·   Optimal $%d   ·   üst açık" % [floor_p, optimal]
	else:
		_pricing_marks.text = "Alt sınır $%d   ·   Optimal belirsiz (Markets düşük)" % floor_p

	_update_projection(int(_price_slider.value))


func _ensure_pricing_panel() -> void:
	if _pricing_panel != null:
		return
	var panel := PanelContainer.new()
	panel.name = "PricingPanel"
	panel.theme_type_variation = &"CardPanel"

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)

	# 1. Header: "FİYATLANDIRMA" + right status chip (rebuilt in paint).
	_pricing_header_row = HBoxContainer.new()
	var hdr := UiFactory.make_section_header("Fiyatlandırma")
	hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pricing_header_row.add_child(hdr)
	vb.add_child(_pricing_header_row)

	# 2. Value anchor.
	vb.add_child(UiFactory.make_label("ÜRÜN DEĞERİ", &"MetricCaptionInk"))
	var anchor_row := HBoxContainer.new()
	anchor_row.add_theme_constant_override("separation", 6)
	_pricing_value_label = UiFactory.make_label("", &"MetricValueInk")
	anchor_row.add_child(_pricing_value_label)
	var per := UiFactory.make_label("/ kullanıcı", &"RowMeta")
	per.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	anchor_row.add_child(per)
	vb.add_child(anchor_row)

	# 3. Rationale chips (value drivers).
	_pricing_rationale = HFlowContainer.new()
	_pricing_rationale.add_theme_constant_override("h_separation", 5)
	_pricing_rationale.add_theme_constant_override("v_separation", 4)
	vb.add_child(_pricing_rationale)

	# 4. Spectrum control: colored band + notches with the slider overlaid so the
	# amber grabber rides directly on the value band (PriceSlider = transparent track).
	_pricing_spectrum = Control.new()
	_pricing_spectrum.custom_minimum_size = Vector2(0, 30)
	_pricing_spectrum.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(_pricing_spectrum)

	_pricing_band = HBoxContainer.new()
	_pricing_band.add_theme_constant_override("separation", 0)
	_pricing_band.anchor_right = 1.0
	_pricing_band.anchor_top = 0.5
	_pricing_band.anchor_bottom = 0.5
	_pricing_band.offset_top = -4.0
	_pricing_band.offset_bottom = 4.0
	_pricing_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pricing_spectrum.add_child(_pricing_band)

	_price_slider = HSlider.new()
	_price_slider.theme_type_variation = &"PriceSlider"
	_price_slider.min_value = 1
	_price_slider.max_value = 100
	_price_slider.step = 1
	_price_slider.anchor_right = 1.0
	_price_slider.anchor_bottom = 1.0
	_price_slider.value_changed.connect(_on_price_slider_changed)
	_pricing_spectrum.add_child(_price_slider)

	# 5. Marks.
	_pricing_marks = UiFactory.make_label("", &"MetricCaptionInk")
	vb.add_child(_pricing_marks)

	# 6. Projection block (live before→after), rebuilt on every slider move.
	var proj_card := PanelContainer.new()
	proj_card.theme_type_variation = &"CardPanelTight"
	_pricing_projection = VBoxContainer.new()
	_pricing_projection.add_theme_constant_override("separation", 8)
	proj_card.add_child(_pricing_projection)
	vb.add_child(proj_card)

	# 7. Apply CTA (amber primary).
	_pricing_apply = Button.new()
	_pricing_apply.theme_type_variation = &"CommitButton"
	_pricing_apply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pricing_apply.pressed.connect(_on_pricing_apply_pressed)
	vb.add_child(_pricing_apply)

	# Yön A: the pricing panel is the expanded detail of the "Fiyatlandır" action row.
	_price_detail_slot.add_child(panel)
	_pricing_panel = panel


func _rebuild_header_chip(is_open: bool) -> void:
	if _pricing_status_chip != null and is_instance_valid(_pricing_status_chip):
		_pricing_header_row.remove_child(_pricing_status_chip)
		_pricing_status_chip.queue_free()
	if is_open:
		_pricing_status_chip = UiFactory.make_badge("Canlı · $%d" % int(GameState.get_flag("b2c_price", 0)), &"positive")
	else:
		_pricing_status_chip = UiFactory.make_badge("Taslak", &"neutral")
	_pricing_status_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pricing_header_row.add_child(_pricing_status_chip)


func _rebuild_rationale(lines: Array, can_read: bool) -> void:
	_clear(_pricing_rationale)
	if not can_read:
		_pricing_rationale.add_child(UiFactory.make_badge("içgüdüsel fiyat", &"neutral"))
		return
	for line in lines:
		var s: int = int(line.get("sign", 0))
		var kind: StringName = &"neutral"
		if s > 0:
			kind = &"positive"
		elif s < 0:
			kind = &"negative"
		# Short chip: the driver, not the full explanation ("Kalite 100 → …" → "Kalite 100").
		var short: String = String(line.get("text", "")).split("→")[0].strip_edges()
		_pricing_rationale.add_child(UiFactory.make_badge(short, kind))


func _rebuild_bands(optimal: int, floor_p: int, smax: int, can_read: bool) -> void:
	_clear(_pricing_band)
	for ch in _pricing_spectrum.get_children():
		if String(ch.name).begins_with("Notch"):
			_pricing_spectrum.remove_child(ch)
			ch.queue_free()
	# Zones by ratio across the full 1..smax range: green (volume) → amber (optimal) → red (premium).
	var a: float = maxf(1.0, optimal * 0.85)
	var b: float = maxf(a + 1.0, optimal * 1.15)
	_add_band(UiTokens.POSITIVE, a - 1.0)
	_add_band(UiTokens.HEALTH_AMBER, b - a)
	_add_band(UiTokens.NEGATIVE, maxf(1.0, float(smax) - b))
	if can_read:
		var span: float = maxf(1.0, float(smax - 1))
		_add_notch(clampf(float(floor_p - 1) / span, 0.0, 1.0))
		_add_notch(clampf(float(optimal - 1) / span, 0.0, 1.0))


func _add_band(color: Color, ratio: float) -> void:
	var r := ColorRect.new()
	r.color = color
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.size_flags_stretch_ratio = maxf(0.01, ratio)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pricing_band.add_child(r)


func _add_notch(ratio: float) -> void:
	var n := ColorRect.new()
	n.name = "Notch"
	n.color = UiTokens.INK
	n.anchor_left = ratio
	n.anchor_right = ratio
	n.offset_left = -1.0
	n.offset_right = 1.0
	n.anchor_top = 0.5
	n.anchor_bottom = 0.5
	n.offset_top = -8.0
	n.offset_bottom = 8.0
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pricing_spectrum.add_child(n)
	_pricing_spectrum.move_child(n, 1)  # above band, below slider grabber


func _on_price_slider_changed(value: float) -> void:
	_update_projection(int(value))


func _update_projection(price: int) -> void:
	# Live, pre-commit estimate (B.3 / D.3). No mutation.
	_clear(_pricing_projection)
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var floor_p: int = int(v["floor"])
	var can_read: bool = GameState.get_founder_skill("markets") >= SkillCheck.MARKETS_READ_THRESHOLD
	var est: Dictionary = SalesSystem.estimate_price_change(price)
	var cur_paying: int = CustomerRegistry.get_total_users()
	var new_paying: int = int(est["new_paying"])
	var new_mrr: int = int(est["new_mrr"])
	var old_mrr: int = int(est["old_mrr"])
	var conv: int = int(round(SalesSystem.conversion_rate(price) * 100.0))
	var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)

	# Metric cells (before→after).
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.add_child(UiFactory.make_stat("Seçilen", "$%d" % price, 0, "", UiTokens.ACCENT_DEEP))
	var dpay: int = new_paying - cur_paying
	row.add_child(UiFactory.make_stat("Ödeyen", str(new_paying), dpay, _signed(dpay) if (is_open and dpay != 0) else ""))
	var dmrr: int = new_mrr - old_mrr
	row.add_child(UiFactory.make_stat("MRR", _fmt_money(new_mrr), dmrr, _signed_money(dmrr) if (is_open and dmrr != 0) else ""))
	row.add_child(UiFactory.make_stat("Dönüşüm", "%d%%" % conv))
	_pricing_projection.add_child(row)

	# Zone + raise chips.
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 5)
	chips.add_theme_constant_override("v_separation", 4)
	if not can_read:
		chips.add_child(UiFactory.make_badge("içgüdüsel fiyat", &"neutral"))
	elif price < floor_p:
		chips.add_child(UiFactory.make_badge("ucuza kaçış", &"positive"))
	elif price < optimal:
		chips.add_child(UiFactory.make_badge("volume oyunu · dönüşüm yüksek", &"positive"))
	elif price > optimal:
		chips.add_child(UiFactory.make_badge("premium · audience zorlanır", &"negative"))
	else:
		chips.add_child(UiFactory.make_badge("optimal · dengeli", &"accent"))
	if est["is_raise"]:
		chips.add_child(UiFactory.make_badge("zam · audience −%d%%" % int(round(float(est["audience_drop_pct"]) * 100.0)), &"negative"))
	_pricing_projection.add_child(chips)

	# CTA label carries the impact.
	if not is_open:
		_pricing_apply.text = "Fiyatı koy · $%d" % price
	else:
		_pricing_apply.text = "Fiyatı uygula · MRR %s → %s" % [_fmt_money(old_mrr), _fmt_money(new_mrr)]


func _on_pricing_apply_pressed() -> void:
	var price: int = int(_price_slider.value)
	SalesSystem.apply_b2c_price(price)  # the only B2C revenue mover — a played decision
	# apply emits mrr_changed → _on_sales_state_changed → _refresh_view repaints,
	# but call directly too so the panel updates even if MRR happened to be equal.
	_refresh_view()


# --- small formatting/util helpers for the pricing UI ---
func _clear(node: Node) -> void:
	for ch in node.get_children():
		node.remove_child(ch)
		ch.queue_free()


func _signed(v: int) -> String:
	if v > 0:
		return "+%d" % v
	if v < 0:
		return "−%d" % absi(v)
	return "±0"


func _signed_money(v: int) -> String:
	if v == 0:
		return ""
	return ("+%s" % _fmt_money(v)) if v > 0 else ("−%s" % _fmt_money(absi(v)))


func _fmt_money(value: int) -> String:
	if absi(value) >= 1000000:
		return "$%.1fM" % (value / 1000000.0)
	if absi(value) >= 1000:
		return "$%.0fK" % (value / 1000.0)
	return "$%d" % value


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
