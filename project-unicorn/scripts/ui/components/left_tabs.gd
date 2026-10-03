extends Panel

# Left tab rail. Tab definitions live in UiTokens.TABS; the buttons below match that
# array position-for-position (guarded by the rail_tabs_match_scene_order smoke case).
# A tab with a `lock` gate is visible, dimmed, carries a YAKINDA pill and never connects
# `pressed`. The rail lies opaque over the office's left edge (GameShell); under
# DisplaySettings.COMPACT_SHELL_BELOW of logical width it narrows to its icons.
# This script owns the row geometry (rail width, Stack insets, Badge offsets) and sets it
# in _apply_width; the matching values in LeftTabs.tscn are only the editor's preview of
# the labelled rail.
#
# Badges address a tab BY ID, never by index, so a reorder cannot shift a count onto
# the wrong tab. Sources:
#   hr       HRSystem.attention_count() (thresholds live in HRConstants)
#   sales    B2BSalesSystem.attention_count() (accounts in the RİSK phase)
#   finance  1 when runway is under FinanceSystem's first runway alert threshold
#   events   EventGate.queue_size()
#   rnd      RnDSystem.attention_count() (frozen research + unread report)

const WIDTH := 184.0
const WIDTH_ICONS := 64.0
## Row geometry per mode: the labelled stack's insets from the button's left and right edges
## (icons: none), and the badge's top-left from the button's right middle (labelled: right of
## the name; icons: on the icon's corner).
const STACK_LEFT := 16.0
const STACK_RIGHT := 12.0
const BADGE_AT := Vector2(-28.0, -8.0)
const BADGE_AT_ICONS := Vector2(-26.0, -18.0)

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
	for i in tab_buttons.size():
		var btn: Button = tab_buttons[i]
		if not _is_locked(i):
			btn.pressed.connect(_on_tab_button.bind(i))
			continue
		# Görünür-ama-ölü. Bilerek Button.disabled DEĞİL: TabButton varyasyonu disabled
		# stylebox tanımlamıyor, taban Button stylebox'ı sızardı. Amber rozet DİKKAT
		# register'ıdır, kilitli kapı için yanlış ses.
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.focus_mode = Control.FOCUS_NONE
		btn.modulate.a = UiTokens.TAB_LOCKED_ALPHA
		btn.get_node("Badge").visible = false
		# Pill akışa (Stack'e) girer, adın sağına; simge kipinde adla birlikte gizlenir.
		btn.get_node("Stack").add_child(UiFactory.make_badge(tr("SYS_SOON")))

	# The gear is not a tab: no active styling, never emits tab_changed. Its icon takes
	# the idle ink once; the SVG itself is white so modulate can tint it.
	settings_btn.pressed.connect(EventBus.settings_requested.emit)
	(settings_btn.get_node("Stack/Icon") as TextureRect).modulate = UiTokens.INK_DIM

	# Rail clicks, the ✕/Esc close and programmatic switches (a closing sprint, goto_tab)
	# all arrive here, so the highlight has a single painter.
	EventBus.tab_changed.connect(_on_tab_changed)
	_apply_visual()

	EventBus.morale_changed.connect(_refresh_hr_badge.unbind(2))
	EventBus.character_added.connect(_refresh_hr_badge.unbind(1))
	EventBus.character_removed.connect(_refresh_hr_badge.unbind(1))
	EventBus.runway_recalculated.connect(_refresh_finance_badge.unbind(1))
	EventBus.event_triggered.connect(_refresh_events_badge.unbind(1))
	EventBus.event_resolved.connect(_refresh_events_badge.unbind(2))
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
	get_viewport().size_changed.connect(_apply_width)
	EventBus.language_changed.connect(_apply_width.unbind(1))
	_apply_width()


## Etiketli ray ya da simge kipi, mantıksal genişliğe göre (üst barın sıkışık kipiyle aynı eşik).
## Simge kipinde adlar ağaçta kalır, gizlenir ve ipucu olur.
func _apply_width() -> void:
	var icons: bool = get_viewport_rect().size.x < DisplaySettings.COMPACT_SHELL_BELOW
	custom_minimum_size.x = WIDTH_ICONS if icons else WIDTH
	var badge_at: Vector2 = BADGE_AT_ICONS if icons else BADGE_AT
	for btn: Button in tab_buttons + [settings_btn]:
		var stack: HBoxContainer = btn.get_node("Stack")
		stack.alignment = BoxContainer.ALIGNMENT_CENTER if icons else BoxContainer.ALIGNMENT_BEGIN
		stack.offset_left = 0.0 if icons else STACK_LEFT
		stack.offset_right = 0.0 if icons else -STACK_RIGHT
		for part: Control in stack.get_children():
			part.visible = not icons or part.name == &"Icon"
		btn.tooltip_text = tr((stack.get_node("NameLabel") as Label).text) if icons else ""
		var badge: Control = btn.get_node_or_null("Badge")
		if badge != null:
			badge.offset_left = badge_at.x
			badge.offset_top = badge_at.y
			badge.offset_right = badge_at.x + badge.custom_minimum_size.x
			badge.offset_bottom = badge_at.y + badge.custom_minimum_size.y


func _on_tab_button(idx: int) -> void:
	# Aktif sekmeye tekrar tıklama = kapat → ofise dön (✕ ve Esc ile aynı kanal).
	EventBus.tab_changed.emit("" if idx == current_tab_idx else String(UiTokens.TABS[idx].id))


func _on_tab_changed(tab_id: String) -> void:
	current_tab_idx = _index_of(tab_id)
	_apply_visual()


## UiTokens bir ADLI KAPI taşır, boolean değil, böylece oyun durumundan uzak kalır. Bugünkü
## tek kapı "ea" (bu yapıda yok) ve bilinmeyen bir kapı da KİLİTLİ sayılır: bitmemiş bir
## sayfa oyuncuya açılmasın.
func _is_locked(idx: int) -> bool:
	return String(UiTokens.TABS[idx].get("lock", "")) != ""


func _apply_visual() -> void:
	for i in tab_buttons.size():
		# Kilitli sekme (--tab-shot=marketing onu açabilir) idle görünümde kalır, hiç vurgulanmaz.
		var is_active: bool = i == current_tab_idx and not _is_locked(i)
		tab_buttons[i].theme_type_variation = &"TabButtonActive" if is_active else &"TabButton"
		var color: Color = UiTokens.ACCENT_DEEP if is_active else UiTokens.INK_DIM
		(tab_buttons[i].get_node("Stack/Icon") as TextureRect).modulate = color
		(tab_buttons[i].get_node("Stack/NameLabel") as Label).add_theme_color_override("font_color", color)


func _index_of(tab_id: String) -> int:
	for i in UiTokens.TABS.size():
		if String(UiTokens.TABS[i].id) == tab_id:
			return i
	return -1


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
	_set_badge_count("events", EventGate.queue_size())


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
	var badge: Panel = tab_buttons[idx].get_node("Badge")
	badge.visible = count > 0
	(badge.get_node("BadgeLabel") as Label).text = str(count)
