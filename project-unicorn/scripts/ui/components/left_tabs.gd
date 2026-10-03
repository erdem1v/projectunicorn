extends Panel

# Left tab rail, on the dark theme. Tab definitions live in UiTokens.TABS; the buttons below match
# that array position-for-position (guarded by the rail_tabs_match_scene_order smoke case). The rail
# lies opaque over the office's left edge (GameShell); under DisplaySettings.COMPACT_SHELL_BELOW of
# logical width it narrows to its icons: the names stay in the tree, hidden, and become tooltips,
# a count moves to the icon's corner and a locked row shows a small lock there.
# This script owns the row geometry and every row state (_paint); the matching values in
# LeftTabs.tscn are only the editor's preview of the labelled rail.
#
# Row states: idle, active (raised ground, a marker on the left edge), locked. A tab with a `lock`
# gate is visible, its icon and name off, the reason under the name, and never connects `pressed`.
#
# Badges address a tab BY ID, never by index, so a reorder cannot shift a count onto the wrong tab.
# Red is for danger only (DANGER_TABS); every other count is neutral. Sources:
#   hr       HRSystem.attention_count() (thresholds live in HRConstants)
#   sales    B2BSalesSystem.attention_count() (accounts in the RİSK phase)
#   finance  1 when runway is under FinanceSystem's first runway alert threshold
#   events   the decisions queued and the papers on the desk; while a decision waits, the amber
#            gate dot instead
#   rnd      RnDSystem.attention_count() (frozen research + unread report)

const WIDTH := 184.0
const WIDTH_ICONS := 64.0
## The labelled row's insets from the button's left and right edges (icons: none).
const STACK_LEFT := 20.0
const STACK_RIGHT := 16.0
## Labelled: the badge's right edge from the button's right. Icons: the badge's and the lock's
## top-left on the row.
const BADGE_RIGHT := 16.0
const BADGE_AT_ICONS := Vector2(34, 6)
const LOCK_AT_ICONS := Vector2(38, 28)
## In icon mode a badge sits on the icon; a ring in the row's ground cuts it out.
const BADGE_RING := 2
const DANGER_TABS := ["hr", "sales", "finance"]
const LOCK_ICON := preload("res://assets/icons/util/lock.svg")

@onready var tab_buttons: Array[Button] = [
	$Margin/Col/ProductBtn,
	$Margin/Col/SalesBtn,
	$Margin/Col/HRBtn,
	$Margin/Col/FinanceBtn,
	$Margin/Col/PersonalBtn,
	$Margin/Col/MarketingBtn,
	$Margin/Col/RnDBtn,
	$Margin/Col/EventsBtn,
]

@onready var settings_btn: Button = $Margin/Col/SettingsBtn

var current_tab_idx: int = -1  # -1 = hiçbir sekme açık değil, pencere yok


func _ready() -> void:
	for btn: Button in tab_buttons + [settings_btn]:
		var mark := Panel.new()
		mark.name = "Mark"
		mark.theme_type_variation = &"RailMark"
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mark.anchor_bottom = 1.0
		mark.offset_top = UiTokens.D_MARK.y
		mark.offset_bottom = -UiTokens.D_MARK.y
		mark.offset_right = UiTokens.D_MARK.x
		btn.add_child(mark)
	for i in tab_buttons.size():
		var btn: Button = tab_buttons[i]
		if not _is_locked(i):
			btn.pressed.connect(_on_tab_button.bind(i))
			continue
		# Görünür ama ölü; Button.disabled değil, satır kendi kilitli görünümünü taşır.
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.focus_mode = Control.FOCUS_NONE
		# Gerekçe adın altında: ad ve gerekçe birlikte satırın ortasına oturur.
		var name_label: Label = btn.get_node("Stack/NameLabel")
		var reason := Label.new()
		reason.name = "Reason"
		reason.theme_type_variation = &"NavReason"
		name_label.add_child(reason)
		reason.position.y = name_label.get_line_height()
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		name_label.custom_minimum_size.y = name_label.get_line_height() + reason.get_line_height()
		var lock := TextureRect.new()
		lock.name = "Lock"
		lock.texture = LOCK_ICON
		lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock.size = Vector2.ONE * UiTokens.D_ICON_MARK
		lock.position = LOCK_AT_ICONS
		lock.modulate = UiTokens.D_INK_4
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(lock)

	settings_btn.pressed.connect(EventBus.settings_requested.emit)
	var gate := Panel.new()
	gate.name = "GateDot"
	gate.theme_type_variation = &"GateDot"
	gate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gate.custom_minimum_size = Vector2.ONE * UiTokens.SPACE_M
	tab_buttons[_index_of("events")].add_child(gate)

	# Rail clicks, the ✕/Esc close and programmatic switches (a closing sprint, goto_tab)
	# all arrive here, so the highlight has a single painter.
	EventBus.tab_changed.connect(_on_tab_changed)

	EventBus.morale_changed.connect(_refresh_hr_badge.unbind(2))
	EventBus.character_added.connect(_refresh_hr_badge.unbind(1))
	EventBus.character_removed.connect(_refresh_hr_badge.unbind(1))
	EventBus.runway_recalculated.connect(_refresh_finance_badge.unbind(1))
	EventBus.event_triggered.connect(_refresh_events_badge.unbind(1))
	EventBus.event_resolved.connect(_refresh_events_badge.unbind(2))
	EventBus.event_set_aside.connect(_refresh_events_badge.unbind(1))
	EventBus.desk_changed.connect(_refresh_events_badge)
	EventBus.customer_health_changed.connect(_refresh_sales_badge.unbind(2))
	EventBus.customer_churned.connect(_refresh_sales_badge.unbind(1))
	EventBus.customer_removed.connect(_refresh_sales_badge.unbind(1))
	EventBus.research_started.connect(_refresh_rnd_badge.unbind(1))
	EventBus.research_completed.connect(_refresh_rnd_badge.unbind(1))
	EventBus.research_frozen.connect(_refresh_rnd_badge.unbind(1))
	EventBus.research_resumed.connect(_refresh_rnd_badge.unbind(1))
	EventBus.product_note_issued.connect(_refresh_rnd_badge.unbind(1))
	EventBus.product_note_read.connect(_refresh_rnd_badge)
	# v1 yayını Ar-Ge ağacını açar; kayıt yüklemesi her sayacı birden değiştirir.
	EventBus.build_phase_changed.connect(_refresh_badges.unbind(1))
	EventBus.game_loaded.connect(_refresh_badges.unbind(1))
	_refresh_badges()
	get_viewport().size_changed.connect(_paint)
	EventBus.language_changed.connect(_paint.unbind(1))
	EventBus.palette_changed.connect(_paint.unbind(1))
	_paint()


## Every row's look from its state and the rail's mode (labelled or icons, by logical width; the
## same threshold as the top bar's compact mode).
func _paint() -> void:
	var icons: bool = get_viewport_rect().size.x < DisplaySettings.COMPACT_SHELL_BELOW
	custom_minimum_size.x = WIDTH_ICONS if icons else WIDTH
	for i in tab_buttons.size():
		var id: String = String(UiTokens.TABS[i].id)
		# Kilitli sekme (--tab-shot=marketing onu açabilir) kilitli görünümde kalır, hiç vurgulanmaz.
		var state: String = "locked" if _is_locked(i) else ("active" if i == current_tab_idx else "idle")
		_paint_row(tab_buttons[i], "TAB_" + id.to_upper(), state, icons)
		_paint_badge(tab_buttons[i].get_node("Badge"), id in DANGER_TABS, state == "active", icons)
		if id == "events":
			_place_gate_dot(tab_buttons[i].get_node("GateDot"), icons)
		if state == "locked":
			var reason: Label = tab_buttons[i].get_node("Stack/NameLabel/Reason")
			reason.text = Fmt.upper(tr(_lock_reason(String(UiTokens.TABS[i].lock))))
			tab_buttons[i].get_node("Lock").visible = icons
	_paint_row(settings_btn, "TAB_SETTINGS", "idle", icons)


func _paint_row(btn: Button, key: String, state: String, icons: bool) -> void:
	btn.theme_type_variation = &"RailRowActive" if state == "active" else &"RailRow"
	btn.tooltip_text = tr(key) if icons else ""
	btn.get_node("Mark").visible = state == "active"
	var stack: HBoxContainer = btn.get_node("Stack")
	stack.alignment = BoxContainer.ALIGNMENT_CENTER if icons else BoxContainer.ALIGNMENT_BEGIN
	stack.offset_left = 0.0 if icons else STACK_LEFT
	stack.offset_right = 0.0 if icons else -STACK_RIGHT
	(stack.get_node("Icon") as TextureRect).modulate = {"idle": UiTokens.D_INK_4, "active": UiTokens.D_INK_2,
		"locked": UiTokens.D_INK_OFF}[state]
	var name_label: Label = stack.get_node("NameLabel")
	name_label.visible = not icons
	name_label.theme_type_variation = {"idle": &"NavLabel", "active": &"NavLabelActive",
		"locked": &"NavLabelLocked"}[state]
	name_label.text = Fmt.upper(tr(key))


## Labelled: right of the name. Icons: on the icon's corner, smaller, with a ring in the row's ground.
## The danger fill is read from D_neg() so the colour-blind palette reaches it.
func _paint_badge(badge: Label, danger: bool, active: bool, icons: bool) -> void:
	badge.theme_type_variation = StringName(("BadgeDanger" if danger else "BadgeCount") + ("Icon" if icons else ""))
	var h: float = UiTokens.D_H_BADGE_ICON if icons else UiTokens.D_H_BADGE
	badge.custom_minimum_size = Vector2.ONE * h
	badge.set_anchors_preset(Control.PRESET_TOP_LEFT if icons else Control.PRESET_CENTER_RIGHT)
	if icons:
		badge.grow_horizontal = Control.GROW_DIRECTION_END
		badge.offset_left = BADGE_AT_ICONS.x
		badge.offset_top = BADGE_AT_ICONS.y
		badge.offset_right = BADGE_AT_ICONS.x + h
		badge.offset_bottom = BADGE_AT_ICONS.y + h
	else:
		badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		badge.offset_left = -BADGE_RIGHT - h
		badge.offset_top = -h / 2.0
		badge.offset_right = -BADGE_RIGHT
		badge.offset_bottom = h / 2.0
	badge.remove_theme_stylebox_override("normal")
	badge.remove_theme_color_override("font_color")
	if not (danger or icons):
		return
	var box: StyleBoxFlat = badge.get_theme_stylebox("normal").duplicate()
	if danger:
		box.bg_color = UiTokens.D_neg()
		badge.add_theme_color_override("font_color", UiTokens.D_on_neg())
	if icons:
		box.set_border_width_all(BADGE_RING)
		box.set_expand_margin_all(BADGE_RING)
		box.border_color = UiTokens.D_SURFACE_4 if active else UiTokens.D_SURFACE_1
	badge.add_theme_stylebox_override("normal", box)


## Where a count would sit: right of the name, or on the icon's corner.
func _place_gate_dot(dot: Panel, icons: bool) -> void:
	var px: float = UiTokens.SPACE_M
	dot.set_anchors_preset(Control.PRESET_TOP_LEFT if icons else Control.PRESET_CENTER_RIGHT)
	var at := BADGE_AT_ICONS if icons else Vector2(-BADGE_RIGHT - UiTokens.D_H_BADGE / 2.0 - px / 2.0, -px / 2.0)
	dot.offset_left = at.x
	dot.offset_top = at.y
	dot.offset_right = at.x + px
	dot.offset_bottom = at.y + px


## The demo build says which build opens a tab gated "ea"; any other build, or gate, says "soon".
func _lock_reason(gate: String) -> String:
	return "ENDING_BADGE_EA" if gate == "ea" and EndingsSystem.build_scope() == EndingsSystem.BUILD_DEMO \
		else "SYS_SOON"


func _on_tab_button(idx: int) -> void:
	# Aktif sekmeye tekrar tıklama = kapat → ofise dön (✕ ve Esc ile aynı kanal).
	EventBus.tab_changed.emit("" if idx == current_tab_idx else String(UiTokens.TABS[idx].id))


func _on_tab_changed(tab_id: String) -> void:
	current_tab_idx = _index_of(tab_id)
	_paint()


## UiTokens bir ADLI KAPI taşır, boolean değil, böylece oyun durumundan uzak kalır. Bugünkü
## tek kapı "ea" ve bilinmeyen bir kapı da KİLİTLİ sayılır: bitmemiş bir sayfa oyuncuya açılmasın.
func _is_locked(idx: int) -> bool:
	return String(UiTokens.TABS[idx].get("lock", "")) != ""


func _index_of(tab_id: String) -> int:
	for i in UiTokens.TABS.size():
		if String(UiTokens.TABS[i].id) == tab_id:
			return i
	return -1


## The ticker's collapsed tab sits on the rail's bottom-left corner; the rail's last row stays
## above it.
func set_bottom_clearance(px: float) -> void:
	$Margin.add_theme_constant_override("margin_bottom", int(UiTokens.SPACE_L + px))


# --- Badges ---

func _refresh_badges() -> void:
	_refresh_hr_badge()
	_refresh_sales_badge()
	_refresh_finance_badge()
	_refresh_events_badge()
	_refresh_rnd_badge()


func _refresh_hr_badge() -> void:
	# İzindeki çalışan da sayılır: hâlâ ekipte, hâlâ dikkat ister.
	_set_badge_count("hr", HRSystem.attention_count())


func _refresh_finance_badge() -> void:
	# INF (kârlı) eşiği geçemez → rozet yok; kârlılık asla uyarı değildir. Eşik, şeritteki
	# runway satırıyla paylaşılır.
	_set_badge_count("finance",
		1 if GameState.get_runway_months() < FinanceSystem.RUNWAY_ALERT_MONTHS[0] else 0)


func _refresh_events_badge() -> void:
	var gated: bool = EventGate.active_id() != ""
	tab_buttons[_index_of("events")].get_node("GateDot").visible = gated
	_set_badge_count("events", 0 if gated else EventGate.queue_size() + EventGate.desk_papers().size())


func _refresh_sales_badge() -> void:
	_set_badge_count("sales", B2BSalesSystem.attention_count())


func _refresh_rnd_badge() -> void:
	# Ar-Ge §5.6.2: donmuş araştırma okunmamış raporla toplanır. Koşan araştırma sayılmaz: Ar-Ge
	# talep etmez. Ağaç açılmadan sayılacak bir şey olmaması tesadüftür; koruma o yüzden açıkça
	# yazılı.
	_set_badge_count("rnd", RnDSystem.attention_count() if RnDSystem.tree_open() else 0)


func _set_badge_count(tab_id: String, count: int) -> void:
	var idx := _index_of(tab_id)
	if idx < 0:
		push_error("LeftTabs: badge for unknown tab id '%s'" % tab_id)
		return
	var badge: Label = tab_buttons[idx].get_node("Badge")
	badge.visible = count > 0
	badge.text = str(count)
