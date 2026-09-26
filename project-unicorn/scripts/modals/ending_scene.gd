class_name EndingScene
extends Control

# Ending ceremony — "Ekonomi Postası" (newspaper layout).
# A humble full-screen Register-B view: a cream newspaper PAGE on the left (~70%,
# a LIGHT surface — INK text) and a DARK meta RAIL on the right (~30%, CREAM text).
# It paints ONE immutable view_state from EndingsCopy.build() through _fill(); it
# authors no copy of its own (the paper prose lives in EndingsCopy, the rail chrome
# in the ENDING_* CSV keys). In ending mode the single write action is TEKRAR DENE's process
# relaunch; milestone mode's two actions (below) belong to main.gd — this scene only asks.
#
# Mirrors term_sheet_table_scene.gd (the sibling Register-B screen): programmatic
# layout over a minimal .tscn root, DIALOGUE_BG backdrop, fade-in tween.
#
# process_mode = ALWAYS on the ROOT (set in EndingScene.tscn; children INHERIT → resolve to ALWAYS), so every
# rail button stays clickable on the paused tree. In ending mode there is
# no dismiss-back-to-gameplay path: the run is over. Milestone mode's DEVAM ET is that path.
#
# Retry = process relaunch (owner ruling): OS.set_restart_on_exit resets all
# autoload state cleanly.
#
# TWO MODES, ONE PAPER (owner rulings). The paper is the
# same in both; only the rail and the strip under it change.
#   ending    — the run is over. In the DEMO build: the Coming-Soon cards, WISHLIST'E EKLE
#               and Frank's strip. In EA / full builds the store CTA and the Coming-Soon
#               cards go (the player already owns the game) and Frank does not speak under
#               the paper.
#   milestone — EA / full only (EndingsSystem.ending_mode): a win the company lives through.
#               DEVAM ET closes the paper and the run goes on; ANA MENÜ keeps the save and
#               leaves. main.gd owns both actions — this scene only asks.

# Steam store page — filled when the page goes live. Empty ⇒ WISHLIST'E EKLE stays
# VISIBLE on every DEMO ending but pressed is a no-op until the store page exists.
const STEAM_PAGE_URL := ""

const LOCK_ICON := "res://assets/icons/lock.svg"

signal continue_requested       # milestone mode: DEVAM ET
signal main_menu_requested      # milestone mode: ANA MENÜ

var _rail_host: Control               # host for the rail panel
var _paper_panel: PanelContainer      # the cream page (PNG-crop target — rail excluded)
var _paper_col: VBoxContainer         # the page plus the Frank strip beneath it
var _toast: Label                     # share-confirmation line (hidden until GAZETEYİ PAYLAŞ)
var _open_folder_btn: Button          # reveals with the toast — opens the save folder

var _data: Dictionary = {}            # the run_ended / milestone_reached payload
var _mode: String = EndingsSystem.MODE_ENDING   # payload "mode"; absent = ending
var _demo: bool = true                # EndingsSystem.build_scope() == demo, read at populate
var _ledger: Dictionary = {}          # GameState.get_run_ledger() snapshot


func _ready() -> void:
	_build_skeleton()
	modulate = Color(1, 1, 1, 0)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.22)


# main.gd mount contract: called AFTER add_child.
func populate(ending_data: Dictionary) -> void:
	_data = ending_data
	_mode = String(ending_data.get("mode", EndingsSystem.MODE_ENDING))
	_demo = EndingsSystem.build_scope() == EndingsSystem.BUILD_DEMO
	_ledger = GameState.get_run_ledger()
	_fill(EndingsCopy.build(String(ending_data.get("ending_id", "")), _ledger, ending_data))


# ============================================================================
# Skeleton — static frame built once in _ready (bg + two column hosts)
# ============================================================================

func _build_skeleton() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UiTokens.DIALOGUE_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 0)
	add_child(row)

	# Left ~70%: a dark gutter (MarginContainer) around the cream page.
	var paper_host := MarginContainer.new()
	paper_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paper_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paper_host.size_flags_stretch_ratio = 2.4
	paper_host.add_theme_constant_override("margin_left", 40)
	paper_host.add_theme_constant_override("margin_right", 24)
	paper_host.add_theme_constant_override("margin_top", 36)
	paper_host.add_theme_constant_override("margin_bottom", 36)
	row.add_child(paper_host)

	# THE STRIP LIVES BESIDE THE PAGE, NOT ON IT, and the arrangement is the ruling.
	# Ch. 13 §2 puts Frank's closing line on its own strip OUTSIDE the newspaper, because
	# the paper bans mentor attribution — EndingsCopy's own editorial rules say quotes
	# are attributed to the crowd and never to one person.
	#
	# It is also outside the SHARED IMAGE for free: _export_paper_png crops
	# _paper_panel.get_global_rect(), and the strip is a sibling of that panel rather
	# than a child. The player shares a newspaper; the mentor's verdict was for them.
	_paper_col = VBoxContainer.new()
	_paper_col.add_theme_constant_override("separation", 14)
	paper_host.add_child(_paper_col)

	# Right ~30%: the dark rail fills full height.
	_rail_host = Control.new()
	_rail_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rail_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(_rail_host)


func _fill(vs: Dictionary) -> void:
	_paper_panel = _build_paper(vs)
	_paper_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_paper_col.add_child(_paper_panel)
	# Frank's strip is the DEMO's (owner ruling): in EA / full builds he does not
	# speak under the paper, in either mode.
	if _demo:
		_paper_col.add_child(_build_frank_strip())
	var rail := _build_milestone_rail() if _mode == EndingsSystem.MODE_MILESTONE else _build_rail()
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
		# Engraving frame (a "coming soon" placeholder until the PNG lands) + caption.
		col.add_child(_build_engraving(vs))
		var caption := UiFactory.make_label(String(vs.get("engraving_caption", "")), &"NewsCaptionSerif")
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(caption)
		col.add_child(_rule(1))
		# Body: big-figure stat row, then the editorial prose in two columns.
		var stats := _build_stat_block(vs)
		if stats != null:
			col.add_child(stats)
		col.add_child(_build_prose_columns(vs))

	return panel


## Frank's closing line, on the dark gutter under the page.
##
## It reads the payload, not the view state: EndingsCopy composes the PAPER and has no
## business carrying a line the paper is forbidden to print.
##
## UI/STYLE LAW: this scene owns LAYOUT only. QuoteSerifCream is the cream serif quote
## on a dark ground the cinematic register already uses, and DialogueTag is its
## attribution — so the strip adds no theme surface.
func _build_frank_strip() -> Control:
	var line: String = String(_data.get("frank_line", ""))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	var quote := UiFactory.make_label(line, &"QuoteSerifCream")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(quote)
	var tag := UiFactory.make_label(
		tr("ENDING_FRANK_TAG").format({"name": tr("MENTOR_NAME")}), &"DialogueTag")
	col.add_child(tag)
	return col


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


func _build_stat_block(vs: Dictionary) -> Control:
	# Stat row: the "RAKAMLARLA <ŞİRKET>" title over 4 big serif FIGURES with
	# small mono labels beneath. Returns null when the composer supplied no cells
	# (an unknown ending id) — the caller skips the block entirely.
	var cells: Array = vs.get("stat_cells", [])
	if cells.is_empty():
		return null

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)

	var title := UiFactory.make_label(String(vs.get("ledger_title", "")), &"NewsMeta")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	# 4 equal cells: EXPAND_FILL at default stretch splits the row evenly (~300px each
	# at 1080p — far above any figure/label min width, so no custom_minimum_size).
	var row := HBoxContainer.new()
	box.add_child(row)
	for cell in cells:
		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 2)
		cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var figure := UiFactory.make_label(String(cell.get("figure", "")), &"NewsStatSerif")
		figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(figure)
		var lbl := UiFactory.make_label(String(cell.get("label", "")), &"NewsMeta")
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(lbl)
		row.add_child(cv)
	return box


func _build_prose_columns(vs: Dictionary) -> Control:
	# The editorial ledger sentences flow as TWO balanced newspaper columns.
	var lines: Array = vs.get("ledger_lines", [])

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 28)
	for part in _balanced_split(lines):
		if String(part) == "":
			continue
		var column := UiFactory.make_label(String(part), &"NewsBodySerif")
		column.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.custom_minimum_size = Vector2(220, 0)   # first-frame autowrap guard
		row.add_child(column)
	return row


func _balanced_split(lines: Array) -> Array:
	# Split sentences into two paragraphs at the boundary whose left cumulative char
	# count lands nearest half the total — sentence lengths vary 2-4x, so a plain
	# half-by-count split visibly unbalances the columns. <2 sentences → one column.
	if lines.size() < 2:
		return [" ".join(PackedStringArray(lines)), ""]
	var total := 0
	for l in lines:
		total += String(l).length()
	var best_idx := 1
	var best_diff := total
	var acc := 0
	for i in range(lines.size() - 1):
		acc += String(lines[i]).length()
		var diff: int = abs(acc * 2 - total)   # |left − right|
		if diff < best_diff:
			best_diff = diff
			best_idx = i + 1
	return [
		" ".join(PackedStringArray(lines.slice(0, best_idx))),
		" ".join(PackedStringArray(lines.slice(best_idx))),
	]


func _build_quiet_notice(vs: Dictionary) -> Control:
	# A small single-column "Kısa Kısa" notice, left-aligned, narrower than the page.
	var wrap := HBoxContainer.new()
	var notice := UiFactory.make_label(String(vs.get("quiet_notice", "")), &"NewsBodySerif")
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.custom_minimum_size = Vector2(420, 0)
	wrap.add_child(notice)
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_child(pad)
	return wrap


# ============================================================================
# Right rail (dark surface — CREAM text)
# ============================================================================

func _build_rail() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"RailPanel"

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	panel.add_child(col)

	# The Coming-Soon half of the rail (the two named milestones and WISHLIST'E EKLE) is the
	# DEMO's: in EA / full the player already owns the game, so a store CTA and "coming in
	# Early Access" badges would be selling it to them again.
	if _demo:
		_build_coming_soon(col)

	# Run-meta line — the ONLY place the raw day count is rendered.
	var meta := UiFactory.make_label(tr("ENDING_RUN_META").format({"days": int(_ledger.get("day", 0))}), &"ZoneLabel")
	meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(meta)

	_build_share_toast(col)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)

	# Bottom action row: TEKRAR DENE · ZOR MOD (every ending, visible-locked) · GAZETEYİ PAYLAŞ.
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	col.add_child(actions)

	var retry := _button(&"DialogueGhost", "ENDING_RETRY")
	retry.pressed.connect(_on_retry)
	actions.add_child(retry)

	_add_hard_mode(actions)
	var share := _button(&"DialogueGhost", "ENDING_SHARE")
	share.pressed.connect(_on_share)
	actions.add_child(share)

	return panel


## The demo's Coming-Soon block: the header, the two named milestones and WISHLIST'E EKLE.
func _build_coming_soon(col: VBoxContainer) -> void:
	var header := UiFactory.make_label(tr("ENDING_NEXT"), &"ZoneLabel")
	col.add_child(header)

	# THE TWO NAMED MILESTONES (ch. 01 §3 · ch. 13 §2): what the player's own company
	# reaches next, the strongest Coming-Soon this game has. Both are truthful to the
	# game's scope: Series B is a MILESTONE the run continues past — never an ending —
	# and IPO opens in the full version.
	# Telegraph only: _build_tier_card renders a panel, never a button.
	col.add_child(_build_tier_card(
		tr("ENDING_CARD_SERIESB_TAG"), tr("ENDING_CARD_SERIESB_TITLE"),
		tr("ENDING_BADGE_EA"), tr("ENDING_CARD_SERIESB_BODY")))
	col.add_child(_build_tier_card(
		tr("ENDING_CARD_IPO_TAG"), tr("ENDING_CARD_IPO_TITLE"),
		tr("LOCK_FULL"), tr("ENDING_CARD_IPO_BODY")))

	# WISHLIST'E EKLE — always visible in the demo; inert while the store URL is empty.
	var wishlist := _button(&"CommitButton", "ENDING_WISHLIST")
	wishlist.pressed.connect(_on_wishlist)
	col.add_child(wishlist)


## Share-confirmation toast + open-folder button (hidden until GAZETEYİ PAYLAŞ writes a file).
func _build_share_toast(col: VBoxContainer) -> void:
	_toast = UiFactory.make_label("", &"ZoneLabel")
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.visible = false
	col.add_child(_toast)
	_open_folder_btn = _button(&"DialogueGhost", "ENDING_OPEN_FOLDER")
	_open_folder_btn.visible = false
	_open_folder_btn.pressed.connect(_on_open_folder)
	col.add_child(_open_folder_btn)


func _add_hard_mode(actions: HBoxContainer) -> void:
	var hard := _button(&"DialogueGhost", "ENDING_HARD_MODE")
	hard.disabled = true                       # visible-LOCKED telegraph, no mechanic
	hard.tooltip_text = tr("ENDING_SOON_TOOLTIP")
	# Kilit ikonu Button.icon değil: kaynak SVG 24px ve beyaz stroke'lu, expand_icon onu
	# butonun tamamına yayar. Tier kartlarının reçetesi (12px TextureRect + CREAM_DIM)
	# butonun YANINDA durur: ölçü ve renk kontrolü bizde.
	var hard_row := HBoxContainer.new()
	hard_row.add_theme_constant_override("separation", 5)
	hard_row.add_child(HRUiShared.lock_glyph(12, UiTokens.CREAM_DIM))
	hard_row.add_child(hard)
	actions.add_child(hard_row)


## A rail button: themed by its variation, never takes focus, labelled from its key.
func _button(variation: StringName, key: String) -> Button:
	var b := Button.new()
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE
	b.text = tr(key)
	return b


## The milestone rail (EA / full): the run is NOT over. A short line saying so, then the two
## buttons the owner's ruling names: DEVAM ET as the primary action and
## ANA MENÜ. No share, no Coming-Soon cards, no store CTA, no retry or hard mode, and no
## run-meta line — "BU RUN: n GÜN" reads as a total, and the run has no total yet. The notice
## line under DEVAM ET is where main.gd says why ANA MENÜ could not keep the save.
func _build_milestone_rail() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"RailPanel"

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	panel.add_child(col)

	col.add_child(UiFactory.make_label(tr("ENDING_MILESTONE_HEAD"), &"ZoneLabel"))
	var body := UiFactory.make_label(tr("ENDING_MILESTONE_BODY"), &"DialogueMonologue")
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(body)

	var cont := _button(&"CommitButton", "UI_CONTINUE")
	cont.name = "ContinueButton"
	cont.pressed.connect(func() -> void: continue_requested.emit())
	col.add_child(cont)

	_toast = UiFactory.make_label("", &"ZoneLabel")
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.visible = false
	col.add_child(_toast)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	col.add_child(actions)
	var menu := _button(&"DialogueGhost", "ENDING_MAIN_MENU")
	menu.name = "MainMenuButton"
	menu.pressed.connect(func() -> void: main_menu_requested.emit())
	actions.add_child(menu)
	return panel


## main.gd's answer when ANA MENÜ could not keep the save (a decision screen is open under
## the paper): the paper stays up and says why.
func show_notice(text: String) -> void:
	_toast.text = text
	_toast.visible = true


func _build_tier_card(tag: String, title: String, badge_text: String, body: String) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"RailCard"
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)

	# Tag row: "KİLOMETRE TAŞI · SERIES B" + a small lock icon top-right.
	var tag_row := HBoxContainer.new()
	var tag_lbl := UiFactory.make_label(tag, &"ZoneLabel")
	tag_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag_row.add_child(tag_lbl)
	var lock := TextureRect.new()
	lock.texture = load(LOCK_ICON)
	lock.custom_minimum_size = Vector2(12, 12)
	# EXPAND_IGNORE_SIZE şart: KEEP_SIZE (varsayılan) min-size'ı DOKUNUN boyutuna
	# sabitler ve custom_minimum_size sessizce yutulur; kilit 12 değil 48px
	# (24px SVG × svg/scale 2.0) çizilir.
	lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
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
	_toast.text = tr("ENDING_SAVED_TOAST").format({"path": ProjectSettings.globalize_path(path)})
	_toast.visible = true
	_open_folder_btn.visible = true


func _on_open_folder() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


# PNG export: crop the PAPER rect out of the live viewport (rail excluded), soft 2×
# upscale, save under user://. The viewport capture mirrors the --*-shot harness.
func _export_paper_png() -> String:
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
	crop.resize(region.size.x * 2, region.size.y * 2, Image.INTERPOLATE_LANCZOS)  # soft 2×
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
