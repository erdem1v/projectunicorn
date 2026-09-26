extends Panel

# Left tab rail. Tab definitions live in UiTokens.TABS; the buttons below match that
# array position-for-position (guarded by the rail_tabs_match_scene_order smoke case).
# A tab with a `lock` gate is visible, dimmed, carries a YAKINDA pill and never connects
# `pressed`.
#
# Badges address a tab BY ID, never by index, so a reorder cannot shift a count onto
# the wrong tab. Sources:
#   hr       HRSystem.attention_count() (thresholds live in HRConstants)
#   sales    B2BSalesSystem.attention_count() (accounts in the RİSK phase)
#   finance  1 when runway < 3 months
#   events   EventGate.queue_size()
#   rnd      RnDSystem.attention_count() (frozen research + unread report)

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

var current_tab_idx: int = -1  # -1 = oda görünür, hiçbir sekme açık değil


func _ready() -> void:
	for i in tab_buttons.size():
		var btn: Button = tab_buttons[i]
		if not _is_locked(i):
			btn.pressed.connect(_on_tab_button.bind(i))
			continue
		# Görünür-ama-ölü. Bilerek Button.disabled DEĞİL: ChromeTabButton varyasyonu disabled
		# stylebox tanımlamıyor, taban Button stylebox'ı sızardı. Amber rozet DİKKAT
		# register'ıdır, kilitli kapı için yanlış ses.
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.focus_mode = Control.FOCUS_NONE
		btn.modulate = Color(1, 1, 1, 0.45)
		btn.get_node("Badge").visible = false
		# Pill akışa (Stack'e) girer, çapaya değil: butona anchor atmak onu rayın tamamına
		# yayıp etiketin üstüne bindirirdi.
		var stack: VBoxContainer = btn.get_node("Stack")
		stack.add_theme_constant_override("separation", 2)
		stack.add_child(UiFactory.make_pill(tr("SYS_SOON"), Color(1, 1, 1, 0.05), UiTokens.CREAM_DIM))

	# The gear is not a tab: no active styling, never emits tab_changed.
	settings_btn.pressed.connect(func() -> void: EventBus.settings_requested.emit())

	# Rail clicks, the ✕/Esc close and programmatic switches (Tracker Card, product_tab's
	# sales redirect) all arrive here, so the highlight has a single painter.
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


func _on_tab_button(idx: int) -> void:
	# Aktif sekmeye tekrar tıklama = kapat → odaya dön (✕ ve Esc ile aynı kanal).
	EventBus.tab_changed.emit("" if idx == current_tab_idx else String(UiTokens.TABS[idx].id))


func _on_tab_changed(tab_id: String) -> void:
	# Rayda sekmesi olmayan sayfa (milestones) da highlight'ı boşaltır.
	current_tab_idx = _index_of(tab_id)
	_apply_visual()


## UiTokens bir ADLI KAPI taşır, boolean değil, böylece oyun durumundan uzak kalır. Bugünkü
## tek kapı "ea" (bu yapıda yok) ve bilinmeyen bir kapı da KİLİTLİ sayılır: bitmemiş bir
## sayfa oyuncuya açılmasın.
func _is_locked(idx: int) -> bool:
	return String(UiTokens.TABS[idx].get("lock", "")) != ""


func _apply_visual() -> void:
	for i in tab_buttons.size():
		if _is_locked(i):
			continue   # kilitli sekme sönük idle görünümünde kalır, hiç vurgulanmaz
		var is_active: bool = i == current_tab_idx
		tab_buttons[i].theme_type_variation = &"ChromeTabButtonActive" if is_active else &"ChromeTabButton"
		var color: Color = UiTokens.CREAM if is_active else UiTokens.CREAM_DIM
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
	# INF (kârlı) `< 3.0`'ı geçemez → rozet yok; kârlılık asla uyarı değildir.
	_set_badge_count("finance", 1 if GameState.get_runway_months() < 3.0 else 0)


func _refresh_events_badge() -> void:
	_set_badge_count("events", EventGate.queue_size())


func _refresh_sales_badge() -> void:
	_set_badge_count("sales", B2BSalesSystem.attention_count())


func _refresh_rnd_badge() -> void:
	# Ar-Ge §5.6.2: donmuş araştırma okunmamış raporla toplanır. Yüzen tracker oda görünürken
	# saklı, cam ürün barını gösteriyor; odadaki oyuncu için donmuş araştırmaya ulaşan tek
	# yüzey bu rozet. Koşan araştırma sayılmaz: Ar-Ge talep etmez. Ağaç açılmadan sayılacak
	# bir şey olmaması tesadüftür; koruma o yüzden açıkça yazılı.
	_set_badge_count("rnd", RnDSystem.attention_count() if RnDSystem.tree_open() else 0)


func _set_badge_count(tab_id: String, count: int) -> void:
	var idx := _index_of(tab_id)
	if idx < 0:
		push_error("LeftTabs: badge for unknown tab id '%s'" % tab_id)
		return
	var badge: Panel = tab_buttons[idx].get_node("Badge")
	badge.visible = count > 0
	(badge.get_node("BadgeLabel") as Label).text = str(count)
