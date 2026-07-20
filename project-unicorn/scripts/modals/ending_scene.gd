class_name EndingScene
extends Control

# Ending ceremony — "Ekonomi Postası" (ENDGAME_DESIGN.md §6, newspaper layout).
# A humble full-screen Register-B view: a cream newspaper PAGE on the left (~70%,
# a LIGHT surface — INK text) and a DARK meta RAIL on the right (~30%, CREAM text).
# It paints ONE immutable view_state from EndingsCopy.build() through _fill(); it
# authors no copy of its own (the paper prose lives in EndingsCopy, the rail chrome
# in the ENDING_* CSV keys). The single write action is TEKRAR DENE's process relaunch.
#
# Mirrors term_sheet_table_scene.gd (the sibling Register-B screen): programmatic
# layout over a minimal .tscn root, DIALOGUE_BG backdrop, fade-in tween.
#
# process_mode = ALWAYS on the ROOT (children INHERIT → resolve to ALWAYS), so every
# rail button stays clickable on the permanently-frozen tree (§7.6). There is no
# dismiss-back-to-gameplay path: the run is over.
#
# Retry = process relaunch (Erdem 2026-07-13): OS.set_restart_on_exit resets all
# autoload state cleanly. The in-place initialize_run return is deferred (it needs a
# complete multi-registry reset seam that does not exist yet).

# Steam store page — filled when the page goes live. Empty ⇒ WISHLIST'E EKLE stays
# VISIBLE but pressed is a no-op (Erdem 2026-07-21: the CTA shows on every ending, the
# link is wired when the store page exists). GodotSteam overlay is a future
# capability-gated branch; today the only route is OS.shell_open(STEAM_PAGE_URL).
const STEAM_PAGE_URL := ""

const LOCK_ICON := "res://assets/icons/lock.svg"

var _paper_host: MarginContainer      # dark-gutter host for the paper panel
var _rail_host: Control               # host for the rail panel
var _paper_panel: PanelContainer      # the cream page (PNG-crop target — rail excluded)
var _toast: Label                     # share-confirmation line (hidden until GAZETEYİ PAYLAŞ)
var _open_folder_btn: Button          # reveals with the toast — opens the save folder

var _data: Dictionary = {}            # the run_ended payload
var _ledger: Dictionary = {}          # GameState.get_run_ledger() snapshot
var _vs: Dictionary = {}              # composed view_state


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_skeleton()
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.22)


# main.gd mount contract (identical to the retired EndingModal): called AFTER add_child.
func populate(ending_data: Dictionary) -> void:
	_data = ending_data
	_ledger = GameState.get_run_ledger()
	_vs = _compose(ending_data, _ledger)
	_fill(_vs)


func _compose(ending_data: Dictionary, ledger: Dictionary) -> Dictionary:
	# The copy system owns all paper prose. Defensive fallback keeps the scene
	# renderable even if the composer returns nothing (should never happen live).
	var vs: Dictionary = EndingsCopy.build(String(ending_data.get("ending_id", "")), ledger, ending_data)
	if vs.is_empty():
		vs = _fallback_view_state(ending_data, ledger)
	return vs


# ============================================================================
# Skeleton — static frame built once in _ready (bg + two column hosts)
# ============================================================================

func _build_skeleton() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UiTokens.DIALOGUE_BG   # from token, never inline (grep gate)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 0)
	add_child(row)

	# Left ~70%: a dark gutter (MarginContainer) around the cream page.
	_paper_host = MarginContainer.new()
	_paper_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_paper_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_paper_host.size_flags_stretch_ratio = 2.4
	_paper_host.add_theme_constant_override("margin_left", 40)
	_paper_host.add_theme_constant_override("margin_right", 24)
	_paper_host.add_theme_constant_override("margin_top", 36)
	_paper_host.add_theme_constant_override("margin_bottom", 36)
	row.add_child(_paper_host)

	# Right ~30%: the dark rail fills full height.
	_rail_host = Control.new()
	_rail_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rail_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rail_host.size_flags_stretch_ratio = 1.0
	row.add_child(_rail_host)


func _fill(vs: Dictionary) -> void:
	for c in _paper_host.get_children():
		c.queue_free()
	for c in _rail_host.get_children():
		c.queue_free()
	_paper_panel = _build_paper(vs)
	_paper_host.add_child(_paper_panel)
	var rail := _build_rail(vs)
	rail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rail_host.add_child(rail)


# ============================================================================
# Paper page (light surface — INK text)
# ============================================================================

func _build_paper(vs: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"PaperPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)

	# Masthead + dateline
	var masthead := UiFactory.make_label(String(vs.get("masthead", "")), &"MastheadSerif")
	masthead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(masthead)

	var date := UiFactory.make_label(String(vs.get("date_line", "")), &"NewsMeta")
	date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(date)

	col.add_child(_rule(3))

	# Headline + subhead (quiet closure runs a generic sector story here)
	var headline := UiFactory.make_label(String(vs.get("headline", "")), &"NewsHeadlineSerif")
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(headline)

	var subhead := UiFactory.make_label(String(vs.get("subhead", "")), &"NewsDeckSerif")
	subhead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(subhead)

	if bool(vs.get("is_quiet_closure", false)):
		# Faz-1: no engraving, no ledger box; a small below-the-fold notice pushed down.
		var spacer := Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		col.add_child(spacer)
		col.add_child(_rule(1))
		col.add_child(_build_quiet_notice(vs))
	else:
		# Engraving frame (empty neutral frame until the PNG lands) + caption.
		col.add_child(_build_engraving(vs))
		var caption := UiFactory.make_label(String(vs.get("engraving_caption", "")), &"NewsCaptionSerif")
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(caption)
		col.add_child(_rule(1))
		col.add_child(_build_ledger_box(vs))

	return panel


func _rule(thickness: int) -> Control:
	var rule := ColorRect.new()
	rule.color = UiTokens.PAPER_RULE
	rule.custom_minimum_size = Vector2(0, thickness)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


func _build_engraving(vs: Dictionary) -> Control:
	var frame := PanelContainer.new()
	frame.theme_type_variation = &"EngravingFrame"
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.custom_minimum_size = Vector2(0, 260)
	frame.clip_contents = true

	var path: String = String(vs.get("engraving_path", ""))
	if path != "" and ResourceLoader.exists(path):
		# Real engraving present → fill the frame (covered aspect). Zero-code drop-in.
		var tex := TextureRect.new()
		tex.texture = load(path)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(tex)
	else:
		# Neutral placeholder: a centered dim mono telegraph (Coming-Soon grammar).
		var ph := UiFactory.make_label(tr("ENDING_ENGRAVING_SOON"), &"NewsMeta")
		ph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(ph)
	return frame


func _build_ledger_box(vs: Dictionary) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)

	var title := UiFactory.make_label(String(vs.get("ledger_title", "")), &"NewsMeta")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	# Two-column layout like the mockup's "Rakamlarla" box.
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 32)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)

	for line in vs.get("ledger_lines", []):
		var cell := UiFactory.make_label(String(line), &"NewsBodySerif")
		cell.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.custom_minimum_size = Vector2(220, 0)
		grid.add_child(cell)
	return box


func _build_quiet_notice(vs: Dictionary) -> Control:
	# A small single-column "Kısa Kısa" notice, left-aligned, narrower than the page.
	var wrap := HBoxContainer.new()
	var notice := UiFactory.make_label(String(vs.get("quiet_notice", "")), &"NewsBodySerif")
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.custom_minimum_size = Vector2(420, 0)
	notice.size_flags_horizontal = Control.SIZE_FILL
	wrap.add_child(notice)
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_child(pad)
	return wrap


# ============================================================================
# Right rail (dark surface — CREAM text)
# ============================================================================

func _build_rail(vs: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"RailPanel"

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	panel.add_child(col)

	var header := UiFactory.make_label(tr("ENDING_NEXT"), &"ZoneLabel")
	col.add_child(header)

	col.add_child(_build_tier_card(
		tr("ENDING_CARD_EA_TAG"), tr("ENDING_CARD_EA_TITLE"),
		tr("ENDING_BADGE_EA"), tr("ENDING_CARD_EA_BODY")))
	col.add_child(_build_tier_card(
		tr("ENDING_CARD_FULL_TAG"), tr("ENDING_CARD_FULL_TITLE"),
		tr("ENDING_BADGE_FULL"), tr("ENDING_CARD_FULL_BODY")))

	# WISHLIST'E EKLE — always visible; inert while the store URL is empty.
	var wishlist := Button.new()
	wishlist.theme_type_variation = &"CommitButton"
	wishlist.focus_mode = Control.FOCUS_NONE
	wishlist.text = tr("ENDING_WISHLIST")
	wishlist.pressed.connect(_on_wishlist)
	col.add_child(wishlist)

	# Run-meta line — the ONLY place the raw day count is rendered.
	var meta := UiFactory.make_label(tr("ENDING_RUN_META") % int(_ledger.get("day", 0)), &"ZoneLabel")
	meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(meta)

	# Share-confirmation toast + open-folder button (hidden until GAZETEYİ PAYLAŞ writes a file).
	_toast = UiFactory.make_label("", &"ZoneLabel")
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.visible = false
	col.add_child(_toast)
	_open_folder_btn = Button.new()
	_open_folder_btn.theme_type_variation = &"DialogueGhost"
	_open_folder_btn.focus_mode = Control.FOCUS_NONE
	_open_folder_btn.text = tr("ENDING_OPEN_FOLDER")
	_open_folder_btn.visible = false
	_open_folder_btn.pressed.connect(_on_open_folder)
	col.add_child(_open_folder_btn)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)

	# Bottom action row: TEKRAR DENE · ZOR MOD (every ending, visible-locked) · GAZETEYİ PAYLAŞ.
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	col.add_child(actions)

	var retry := Button.new()
	retry.theme_type_variation = &"DialogueGhost"
	retry.focus_mode = Control.FOCUS_NONE
	retry.text = tr("ENDING_RETRY")
	retry.pressed.connect(_on_retry)
	actions.add_child(retry)

	var hard := Button.new()
	hard.theme_type_variation = &"DialogueGhost"
	hard.focus_mode = Control.FOCUS_NONE
	hard.text = tr("ENDING_HARD_MODE")
	hard.disabled = true                       # visible-LOCKED telegraph, no mechanic
	hard.tooltip_text = tr("ENDING_SOON_TOOLTIP")
	actions.add_child(hard)

	var share := Button.new()
	share.theme_type_variation = &"DialogueGhost"
	share.focus_mode = Control.FOCUS_NONE
	share.text = tr("ENDING_SHARE")
	share.pressed.connect(_on_share)
	actions.add_child(share)

	return panel


func _build_tier_card(tag: String, title: String, badge_text: String, body: String) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"RailCard"
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)

	# Tag row: "TİER 2 · ORTA ÖLÇEK" + a small lock icon top-right.
	var tag_row := HBoxContainer.new()
	var tag_lbl := UiFactory.make_label(tag, &"ZoneLabel")
	tag_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag_row.add_child(tag_lbl)
	if ResourceLoader.exists(LOCK_ICON):
		var lock := TextureRect.new()
		lock.texture = load(LOCK_ICON)
		lock.custom_minimum_size = Vector2(12, 12)
		lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lock.modulate = UiTokens.CREAM_DIM
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tag_row.add_child(lock)
	vb.add_child(tag_row)

	var title_lbl := UiFactory.make_label(title, &"DialogueName")
	vb.add_child(title_lbl)

	vb.add_child(UiFactory.make_badge(badge_text, &"accent"))

	var body_lbl := UiFactory.make_label(body, &"DialogueMonologue")
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(body_lbl)
	return card


# ============================================================================
# Actions
# ============================================================================

func _on_retry() -> void:
	# Process relaunch → clean autoload reset → boots back through onboarding.
	OS.set_restart_on_exit(true)
	get_tree().quit()


func _on_wishlist() -> void:
	if STEAM_PAGE_URL != "":
		OS.shell_open(STEAM_PAGE_URL)


func _on_share() -> void:
	var path: String = await _export_paper_png()
	if path == "":
		return
	_toast.text = tr("ENDING_SAVED_TOAST") % ProjectSettings.globalize_path(path)
	_toast.visible = true
	_open_folder_btn.visible = true


func _on_open_folder() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


# PNG export (Part 7): crop the PAPER rect out of the live viewport (rail excluded),
# optional 2× upscale, save under user://. The crop idiom mirrors the --*-shot harness;
# the true-2× SubViewport render is a documented future upgrade (decision 2).
func _export_paper_png() -> String:
	if _paper_panel == null:
		return ""
	await get_tree().process_frame
	await get_tree().process_frame
	var full: Image = get_viewport().get_texture().get_image()
	var r: Rect2 = _paper_panel.get_global_rect()
	var region := Rect2i(
		Vector2i(int(r.position.x), int(r.position.y)),
		Vector2i(int(r.size.x), int(r.size.y)))
	region = region.intersection(Rect2i(Vector2i.ZERO, full.get_size()))
	if region.size.x <= 0 or region.size.y <= 0:
		return ""
	var crop: Image = full.get_region(region)
	crop.resize(region.size.x * 2, region.size.y * 2, Image.INTERPOLATE_LANCZOS)  # soft 2× (spec: 2×)
	var fname := "gazete_%s_%s.png" % [String(_data.get("ending_id", "son")), _date_stamp()]
	var path := "user://%s" % fname
	var err := crop.save_png(path)
	if err != OK:
		push_warning("[EndingScene] gazete PNG save failed: %d" % err)
		return ""
	print("[EndingScene] gazete saved %s" % ProjectSettings.globalize_path(path))
	return path


func _date_stamp() -> String:
	var t: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d-%02d%02d%02d" % [t.year, t.month, t.day, t.hour, t.minute, t.second]


# ============================================================================
# Fallback view_state — defensive only (EndingsCopy is the real composer).
# ============================================================================

func _fallback_view_state(ending_data: Dictionary, ledger: Dictionary) -> Dictionary:
	return {
		"tone": String(ending_data.get("tone", "loss")),
		"is_win": false,
		"masthead": "EKONOMİ POSTASI",
		"date_line": "",
		"headline": String(ending_data.get("title", "")),
		"subhead": String(ending_data.get("frank_line", "")),
		"engraving_path": "",
		"engraving_caption": "",
		"ledger_title": "RAKAMLARLA",
		"ledger_lines": [],
		"is_quiet_closure": false,
		"is_generic_masthead": false,
		"quiet_notice": "",
	}
