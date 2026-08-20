extends Panel

# Left tab column per PROJECT_SPEC §5 and the UI overhaul mini-spec.
# 8 vertical tabs, in two groups (GDD v2 ch. 12 §1, re-seated 2026-08-20):
#   ACTIVE  Ürün · Satış · Ekip · Finans · Kişisel
#   LOCKED  Pazarlama · Ar-Ge   — visible, dimmed, YAKINDA, unclickable (EARLY ACCESS)
#   then    Olaylar
# Each tab carries an icon glyph (top), a label (below), and an optional
# attention badge (top-right corner). Tab definition source: UiTokens.TABS.
#
# Badge data sources (UI mini-spec §4):
#   - HR: HRSystem.attention_count() — employees carrying any derived badge
#     (TÜKENİYOR / KAÇMA RİSKİ / AŞIRI YÜKLÜ) plus a waiting candidate file.
#     Thresholds live in HRConstants; never re-derive them here.
#   - Sales: B2BSalesSystem.attention_count() — live accounts sitting in the RİSK phase.
#   - Finance: 1 when runway < 3 months, 0 otherwise
#   - Events: EventManager.get_queue_size()
#   - Other tabs: no badge (their systems do not exist yet)
#
# Badges address a tab BY ID, never by index (S2 fix, 2026-08-20). The refreshers used to
# carry hard-coded 1/2/7 literals against a positional node array, so the first reorder
# would have moved every badge one tab off — silently, since nothing would render wrong,
# it would just be counting the wrong thing.

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

var current_tab_idx: int = -1  # -1 = ODA (oda görünür, hiçbir sekme açık değil) — ODA rework varsayılanı

# (Spec 6: the Yatırım tab was relocated into Finance>Yatırım; its phase-3 lock now lives on
# the Finance sub-page selector, not on the rail.)

# Active/idle look is driven by theme type variations (ChromeTabButtonActive/
# ChromeTabButton — ODA rework'te ray koyu kabuğa geçti); icon + label colors are
# tinted at runtime in _apply_visual (CREAM/CREAM_DIM register).


func _ready() -> void:
	for i in tab_buttons.size():
		if _is_locked(i):
			_lock_button(i)
			continue
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
	EventBus.customer_health_changed.connect(_on_customer_health_changed)
	EventBus.customer_churned.connect(_on_customer_left)
	EventBus.customer_removed.connect(_on_customer_left)

	# Initial badge paint
	_refresh_hr_badge()
	_refresh_sales_badge()
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
	EventBus.customer_health_changed.disconnect(_on_customer_health_changed)
	EventBus.customer_churned.disconnect(_on_customer_left)
	EventBus.customer_removed.disconnect(_on_customer_left)


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


func _is_locked(idx: int) -> bool:
	return bool(UiTokens.TABS[idx].get("locked", false))


func _lock_button(idx: int) -> void:
	# Visible-but-inert recipe, borrowed verbatim from the locked origin cards
	# (origin_traits_step._build_card). Deliberately NOT Button.disabled: the
	# ChromeTabButton variation defines no disabled stylebox, so the base Button one would
	# show through — and closing that gap would be a theme change, which this task must not make.
	var btn: Button = tab_buttons[idx]
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.focus_mode = Control.FOCUS_NONE
	btn.modulate = Color(1, 1, 1, 0.45)
	# The amber Badge panel is the ATTENTION register — the wrong voice for a locked door.
	# A YAKINDA pill in the chrome-surface locked palette replaces it, and the Badge node
	# stays hidden for good (no refresher addresses these ids).
	var badge: Panel = btn.get_node_or_null("Badge")
	if badge != null:
		badge.visible = false
	# Pill AKIŞA girer, çapaya DEĞİL: butonun kendisine anchor'lamak onu 84px'lik rayın
	# tamamına yayıyor ve etiketin üstüne biniyordu (F5'te ilk denemede tam olarak bu oldu).
	# Stack zaten ikon+etiketi dikey ortalayan bir VBox; üçüncü çocuk olarak eklenince
	# yerleşimi o çözüyor. Kilitli sekmede satır aralığı 4→2: üç öğe 64px'e ancak sığıyor.
	var stack: VBoxContainer = btn.get_node_or_null("Stack")
	if stack == null:
		return
	stack.add_theme_constant_override("separation", 2)
	stack.add_child(UiFactory.make_pill(tr("SYS_SOON"), Color(1, 1, 1, 0.05), UiTokens.CREAM_DIM))


func _apply_visual(active_idx: int) -> void:
	# Active tab: amber-left-border veil tile (ChromeTabButtonActive) + cream icon/label.
	# Idle tabs: transparent (ChromeTabButton) + dim cream. active_idx == -1 → hepsi
	# idle (ODA görünür, hiçbir sekme açık değil).
	for i in tab_buttons.size():
		if _is_locked(i):
			continue   # locked tabs keep their dimmed idle look; never highlighted
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
	_set_badge_count("hr", HRSystem.attention_count())

func _refresh_finance_badge() -> void:
	# Net runway (Package 5): warn only on LOW FINITE months. INF (profitable/"Kârlı")
	# fails `< 3.0` → no badge, which is correct — profitability is never a warning.
	var months: float = GameState.get_runway_months()
	var n: int = 1 if months < 3.0 else 0
	_set_badge_count("finance", n)

func _refresh_events_badge() -> void:
	_set_badge_count("events", EventManager.get_queue_size())

func _refresh_sales_badge() -> void:
	# Accounts sitting in the RİSK lifecycle phase. Until now an account could slide into
	# risk and the rail said nothing — the player only found out by opening Satış. One
	# number from one place: B2BSalesSystem owns the phase, so it owns the count.
	_set_badge_count("sales", B2BSalesSystem.attention_count())

func _set_badge_count(tab_id: String, count: int) -> void:
	var tab_idx: int = _index_of(tab_id)
	if tab_idx < 0:
		return
	var badge: Panel = tab_buttons[tab_idx].get_node("Badge")
	var badge_label: Label = badge.get_node("BadgeLabel")
	if count <= 0:
		badge.visible = false
	else:
		badge.visible = true
		badge_label.text = str(count)


func _index_of(tab_id: String) -> int:
	for i in UiTokens.TABS.size():
		if String(UiTokens.TABS[i].id) == tab_id:
			return i
	push_warning("[LeftTabs] unknown tab id: %s" % tab_id)
	return -1


# --- Signal handlers ---

func _on_morale_changed(_id: String, _new_morale: int) -> void:
	_refresh_hr_badge()

func _on_roster_changed(_id: String) -> void:
	_refresh_hr_badge()

func _on_runway_changed(_months: float) -> void:
	_refresh_finance_badge()

func _on_customer_health_changed(_id: String, _arg = null) -> void:
	_refresh_sales_badge()

func _on_customer_left(_id: String) -> void:
	_refresh_sales_badge()

func _on_events_changed(_id: String, _arg = null) -> void:
	# Same handler for event_triggered(id) and event_resolved(id, choice_index).
	# Godot 4 accepts extra unused signal args via default-value parameter.
	_refresh_events_badge()
