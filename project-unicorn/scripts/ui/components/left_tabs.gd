extends Panel

# Left tab column per PROJECT_SPEC §5 and the UI overhaul mini-spec.
# 8 vertical tabs: Product / HR / Finance / Sales / Ops / R&D / Personal / Events.
# Each tab carries an icon glyph (top), a label (below), and an optional
# attention badge (top-right corner). Tab definition source: UiTokens.TABS.
#
# Badge data sources (UI mini-spec §4):
#   - HR: HRSystem.attention_count() — employees carrying any derived badge
#     (TÜKENİYOR / KAÇMA RİSKİ / AŞIRI YÜKLÜ) plus a waiting candidate file.
#     Thresholds live in HRConstants; never re-derive them here.
#   - Finance: 1 when runway < 3 months, 0 otherwise
#   - Events: EventManager.get_queue_size()
#   - Other tabs: no badge (their systems do not exist yet)

@onready var tab_buttons: Array[Button] = [
	$Margin/Col/ProductBtn,
	$Margin/Col/HRBtn,
	$Margin/Col/FinanceBtn,
	$Margin/Col/SalesBtn,
	$Margin/Col/OpsBtn,
	$Margin/Col/RnDBtn,
	$Margin/Col/PersonalBtn,
	$Margin/Col/EventsBtn,
]

@onready var settings_btn: Button = $Margin/Col/SettingsBtn

var current_tab_idx: int = -1  # -1 = ODA (oda görünür, hiçbir sekme açık değil) — ODA rework varsayılanı

# (Spec 6: the Yatırım tab was relocated into Finance>Yatırım; its phase-3 lock now lives on
# the Finance sub-page selector, not on the rail.)

# Active/idle look is driven by theme type variations (ChromeTabButtonActive/
# ChromeTabButton — ODA rework'te ray koyu kabuğa geçti); icon + label colors are
# tinted at runtime in _apply_visual (CREAM/CREAM_DIM register).


func _ready() -> void:
	for i in tab_buttons.size():
		tab_buttons[i].pressed.connect(_on_tab_button.bind(i))

	# Gear button — bottom-pinned, NOT a tab (kept out of tab_buttons so it never
	# gets active styling or emits tab_changed). Opens the settings panel instead.
	settings_btn.pressed.connect(_on_settings_button)

	_apply_visual(current_tab_idx)
	# (ODA rework) Eski default-product emit'i silindi: açılış durumu oda,
	# center_viewport kendi _ready'sinde _on_tab_changed("") ile kendini kurar.
	# O emit zaten sibling-ready sırası gereği center_viewport connect'inden
	# ÖNCE ateşleniyordu — ölü koddu.

	# Programatik tab geçişlerinde highlight'ı senkron tut (Tracker Card
	# "PostShip'e geç →" + product_tab'ın sales yönlendirmesi tab_changed emit
	# ediyor; buraya kadar rail dinlemiyordu → bayat highlight). LISTEN-ONLY:
	# kendi butonumuzun emit'i de buraya düşer ama idempotent, re-emit yok.
	EventBus.tab_changed.connect(_on_tab_changed_external)

	# Subscribe to signals that move badge counts (TECH_SPEC §13.3)
	EventBus.morale_changed.connect(_on_morale_changed)
	EventBus.character_added.connect(_on_roster_changed)
	EventBus.character_removed.connect(_on_roster_changed)
	EventBus.runway_recalculated.connect(_on_runway_changed)
	EventBus.event_triggered.connect(_on_events_changed)
	EventBus.event_resolved.connect(_on_events_changed)

	# Initial badge paint
	_refresh_hr_badge()
	_refresh_finance_badge()
	_refresh_events_badge()


func _exit_tree() -> void:
	if EventBus.tab_changed.is_connected(_on_tab_changed_external):
		EventBus.tab_changed.disconnect(_on_tab_changed_external)
	EventBus.morale_changed.disconnect(_on_morale_changed)
	EventBus.character_added.disconnect(_on_roster_changed)
	EventBus.character_removed.disconnect(_on_roster_changed)
	EventBus.runway_recalculated.disconnect(_on_runway_changed)
	EventBus.event_triggered.disconnect(_on_events_changed)
	EventBus.event_resolved.disconnect(_on_events_changed)


func _on_tab_button(idx: int) -> void:
	if idx == current_tab_idx:
		# Aktif sekmeye tekrar tıklama = kapat → odaya dön (ODA rework §2,
		# ✕ ve Esc ile aynı kanal).
		current_tab_idx = -1
		_apply_visual(-1)
		EventBus.tab_changed.emit("")
		return
	current_tab_idx = idx
	_apply_visual(idx)
	EventBus.tab_changed.emit(UiTokens.TABS[idx].id)


func _on_settings_button() -> void:
	EventBus.settings_requested.emit()


func _on_tab_changed_external(tab_id: String) -> void:
	# id → index; bilinmeyen id no-op. Kendi butonumuzdan gelen emit'te idx zaten
	# doğru — idempotent boya, RE-EMIT YOK (sonsuz döngü engeli).
	if tab_id == "":
		# Odaya dönüş (✕ / Esc / programatik) — tüm sekmeler idle'a.
		if current_tab_idx != -1:
			current_tab_idx = -1
			_apply_visual(-1)
		return
	for i in UiTokens.TABS.size():
		if String(UiTokens.TABS[i].id) == tab_id:
			if current_tab_idx != i:
				current_tab_idx = i
				_apply_visual(i)
			return


func _apply_visual(active_idx: int) -> void:
	# Active tab: amber-left-border veil tile (ChromeTabButtonActive) + cream icon/label.
	# Idle tabs: transparent (ChromeTabButton) + dim cream. active_idx == -1 → hepsi
	# idle (ODA görünür, hiçbir sekme açık değil).
	for i in tab_buttons.size():
		var is_active: bool = i == active_idx
		tab_buttons[i].theme_type_variation = &"ChromeTabButtonActive" if is_active else &"ChromeTabButton"
		var icon: TextureRect = tab_buttons[i].get_node("Stack/Icon")
		var name_label: Label = tab_buttons[i].get_node("Stack/NameLabel")
		var color: Color = UiTokens.CREAM if is_active else UiTokens.CREAM_DIM
		icon.modulate = color
		name_label.add_theme_color_override("font_color", color)


# --- Badge refresh helpers (data sources per UI mini-spec §4) ---

func _refresh_hr_badge() -> void:
	# One number from one place: HRSystem.attention_count() counts employees carrying any
	# derived badge (thresholds live in HRConstants, never as a literal here) plus a
	# waiting candidate file — the arrival signal the design wants as a badge, not a modal.
	# On-leave employees are INCLUDED: still on the team, still need attention.
	_set_badge_count(1, HRSystem.attention_count())  # tab index 1 = HR

func _refresh_finance_badge() -> void:
	# Net runway (Package 5): warn only on LOW FINITE months. INF (profitable/"Kârlı")
	# fails `< 3.0` → no badge, which is correct — profitability is never a warning.
	var months: float = GameState.get_runway_months()
	var n: int = 1 if months < 3.0 else 0
	_set_badge_count(2, n)  # tab index 2 = Finance

func _refresh_events_badge() -> void:
	_set_badge_count(7, EventManager.get_queue_size())  # tab index 7 = Events

func _set_badge_count(tab_idx: int, count: int) -> void:
	var badge: Panel = tab_buttons[tab_idx].get_node("Badge")
	var badge_label: Label = badge.get_node("BadgeLabel")
	if count <= 0:
		badge.visible = false
	else:
		badge.visible = true
		badge_label.text = str(count)


# --- Signal handlers ---

func _on_morale_changed(_id: String, _new_morale: int) -> void:
	_refresh_hr_badge()

func _on_roster_changed(_id: String) -> void:
	_refresh_hr_badge()

func _on_runway_changed(_months: float) -> void:
	_refresh_finance_badge()

func _on_events_changed(_id: String, _arg = null) -> void:
	# Same handler for event_triggered(id) and event_resolved(id, choice_index).
	# Godot 4 accepts extra unused signal args via default-value parameter.
	_refresh_events_badge()
