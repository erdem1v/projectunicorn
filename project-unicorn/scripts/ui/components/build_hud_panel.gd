extends Control

# Right-top compact build panel — Software Inc. fidelity. Lives inside
# CenterViewport (the desk area) as a child Control, not RightPanel. The root
# is a full-rect, mouse-ignore Control so desk clicks pass through; only the
# inner Panel/buttons capture input. (Was a root CanvasLayer that floated over
# the whole screen / RightPanel — now confined to the desk, clipped by
# CenterViewport.clip_contents.) Visible only while a build is active. Faz-aware:
#   iteration → kalite + bug-risk + [Bir iterasyon daha] [Development'a geç]
#   development → kalite + bug + progress bar (no buttons, auto-tick)
#   bugfix → kalite + canlı bug count + [LAUNCH]
#
# Signal-driven refresh (no _process poll): EventBus.build_phase_changed +
# build_iteration_decision_pending + day_advanced are enough. Refresh is also
# called on _ready in case we mount mid-build (e.g. save load).
#
# process_mode = ALWAYS so the panel stays interactive while the tree is
# paused (event modals up, etc) — same gotcha as ModalLayer / MCPRuntime.

@onready var root_panel: PanelContainer = $Root/Panel
@onready var product_name_label: Label = $Root/Panel/VBox/HeaderRow/ProductNameLabel
@onready var phase_label: Label = $Root/Panel/VBox/HeaderRow/PhaseLabel
@onready var quality_label: Label = $Root/Panel/VBox/StatsRow/QualityLabel
@onready var bugs_label: Label = $Root/Panel/VBox/StatsRow/BugsLabel
@onready var progress_bar: ProgressBar = $Root/Panel/VBox/ProgressBar
@onready var iteration_button: Button = $Root/Panel/VBox/ButtonRow/IterationButton
@onready var development_button: Button = $Root/Panel/VBox/ButtonRow/DevelopmentButton
@onready var launch_button: Button = $Root/Panel/VBox/ButtonRow/LaunchButton

# C2: product_tab suppresses this desk overlay while its BuildProgressView is up
# (the phase decision now lives there as a proper card). Still shows on other tabs.
var _suppressed: bool = false


func set_suppressed(v: bool) -> void:
	_suppressed = v
	_refresh()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	iteration_button.pressed.connect(_on_iteration_pressed)
	development_button.pressed.connect(_on_development_pressed)
	launch_button.pressed.connect(_on_launch_pressed)
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	EventBus.build_iteration_decision_pending.connect(_on_decision_pending_changed)
	EventBus.day_advanced.connect(_on_day_advanced)
	EventBus.build_progress_changed.connect(_on_build_progress_changed)
	_refresh()


func _exit_tree() -> void:
	if EventBus.build_phase_changed.is_connected(_on_build_phase_changed):
		EventBus.build_phase_changed.disconnect(_on_build_phase_changed)
	if EventBus.build_iteration_decision_pending.is_connected(_on_decision_pending_changed):
		EventBus.build_iteration_decision_pending.disconnect(_on_decision_pending_changed)
	if EventBus.day_advanced.is_connected(_on_day_advanced):
		EventBus.day_advanced.disconnect(_on_day_advanced)
	if EventBus.build_progress_changed.is_connected(_on_build_progress_changed):
		EventBus.build_progress_changed.disconnect(_on_build_progress_changed)


func _on_build_phase_changed(_new_phase: String) -> void:
	_refresh()


func _on_decision_pending_changed(_pending: bool) -> void:
	_refresh()


func _on_day_advanced(_new_day: int) -> void:
	_refresh()


func _on_build_progress_changed() -> void:
	# Fired at the end of ProductSystem.daily_tick, after the phase counter
	# advanced — paints the bar with this tick's value instead of yesterday's.
	_refresh()


func _refresh() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	# Hidden with no build, during a bug sprint (Part 2A — sprint UI lives in
	# PostShipView), or while suppressed (C2 — BuildProgressView owns the decision).
	if _suppressed or b == null or b.is_bug_sprint:
		visible = false
		return
	visible = true

	# Header — product name (falls back to the sub-type name) + phase label
	product_name_label.text = b.product_name if b.product_name != "" else _sub_type_display(b.sub_product_type_id)
	phase_label.text = _phase_display(b)
	# Accent the phase label while an iteration decision is pending so the
	# "now decide" state reads at a glance (Faz 1 bug 1.7).
	if b.current_phase == "iteration" and b.iteration_decision_pending:
		phase_label.add_theme_color_override("font_color", UiTokens.ACCENT_DEEP)
	else:
		phase_label.remove_theme_color_override("font_color")

	# Stats row — three quality dimensions (Stability shown EFFECTIVE, so bugs drag
	# it down live) + raw bug count in bugs_label. İno / Krl / Kul = per-axis 0-100.
	# C3 single-source: RAW dims (stability = effective) to match the PostShip
	# left card + pricing badges. Was axis_score (normalized) → inconsistent.
	var draw: Dictionary = QualityModel.dims_from_build(b)
	var deco: Dictionary = QualityModel.economy_dims_from_build(b)
	quality_label.text = "İno %d · Krl %d · Kul %d" % [
		int(round(float(draw.get("innovation", 0.0)))),
		int(round(float(deco.get("stability", 0.0)))),
		int(round(float(draw.get("usability", 0.0)))),
	]
	bugs_label.text = _bugs_display(b)

	# Progress bar — drives off phase counter
	_paint_progress(b)

	# Buttons — set visible + disabled per phase
	_paint_buttons(b)


func _sub_type_display(sub_type_id: String) -> String:
	if sub_type_id == "":
		return "Build"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return String(data.get("name", sub_type_id))


func _phase_display(b: FeatureBuild) -> String:
	match b.current_phase:
		"iteration":
			if b.iteration_decision_pending:
				return "İterasyon %d bitti — karar ver" % b.iteration_count
			return "Designing — Iteration %d" % b.iteration_count
		"development":
			return "Development"
		"bugfix", "polish":
			return "Bug Fixing"
		_:
			return b.current_phase.capitalize()


func _bugs_display(b: FeatureBuild) -> String:
	match b.current_phase:
		"iteration":
			# Bug riski seviyesi olarak hafif bir kategorize ver; ham sayı da
			# parantezde.
			var band: String = _bug_risk_band(b.bug_count)
			return "Bug riski: %s (%d)" % [band, b.bug_count]
		"development":
			return "Bug: %d" % b.bug_count
		"bugfix", "polish":
			return "Bug: %d (azalıyor)" % b.bug_count
		_:
			return "Bug: %d" % b.bug_count


func _bug_risk_band(count: int) -> String:
	if count <= 2:
		return "Düşük"
	elif count <= 6:
		return "Orta"
	return "Yüksek"


func _paint_progress(b: FeatureBuild) -> void:
	match b.current_phase:
		"iteration":
			progress_bar.visible = true
			progress_bar.max_value = float(max(1, ProductSystem.ITERATION_LENGTH_DAYS))
			progress_bar.value = float(ProductSystem.ITERATION_LENGTH_DAYS - b.iteration_days_in_current)
		"development":
			progress_bar.visible = true
			progress_bar.max_value = float(max(1, b.development_days_total))
			progress_bar.value = float(b.development_days_elapsed)
		"bugfix", "polish":
			# Open-ended; hide the bar so it doesn't lie about an end-date.
			progress_bar.visible = false
		_:
			progress_bar.visible = false


func _paint_buttons(b: FeatureBuild) -> void:
	match b.current_phase:
		"iteration":
			iteration_button.visible = true
			development_button.visible = true
			launch_button.visible = false
			# Active only when the current iteration finished and we're waiting
			# on the player. Visible-but-disabled otherwise so layout doesn't
			# jump when the decision opens up.
			var pending: bool = b.iteration_decision_pending
			iteration_button.disabled = not pending
			development_button.disabled = not pending
			# Decision-pending visibility (Faz 1 bug 1.7): the clock keeps running
			# (no pause by design), so accent the now-live buttons to read as
			# "act now"; plain tint while the iteration is still running.
			var btn_tint: Color = UiTokens.ACCENT if pending else Color(1, 1, 1, 1)
			iteration_button.modulate = btn_tint
			development_button.modulate = btn_tint
		"development":
			iteration_button.visible = false
			development_button.visible = false
			launch_button.visible = false
		"bugfix", "polish":
			iteration_button.visible = false
			development_button.visible = false
			launch_button.visible = true
			launch_button.disabled = false
		_:
			iteration_button.visible = false
			development_button.visible = false
			launch_button.visible = false


func _on_iteration_pressed() -> void:
	ProductSystem.advance_iteration()
	_refresh()


func _on_development_pressed() -> void:
	ProductSystem.enter_development()
	_refresh()


func _on_launch_pressed() -> void:
	ProductSystem.launch()
	_refresh()
