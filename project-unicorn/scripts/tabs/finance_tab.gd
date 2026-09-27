extends Control

# Finance tab host: a segmented control switching two sub-pages under one parent:
#   * Özet    — FinanceOzetView (nakit eğrisi, aylık akış, gider dağılımı, son işlemler,
#     cap table, mentor uyarısı). The view owns its own signals and refresh; this host only
#     tells it when it becomes the visible page.
#   * Yatırım — the Series A Hunt panel (nests HuntTab.tscn). Locked, with the
#     FIN_SUBTAB_LOCKED telegraph as tooltip, until phase 3 or the seed door (_yatirim_locked).

const HUNT_TAB := preload("res://scenes/tabs/HuntTab.tscn")

var _ozet_btn: Button
var _yatirim_btn: Button
var _ozet_view: FinanceOzetView
var _yatirim_view: Control
var _current: String = "ozet"


func _ready() -> void:
	_build()
	EventBus.phase_changed.connect(_apply_phase_lock)
	EventBus.seed_door_opened.connect(_apply_phase_lock)
	# Deep-link: masanın term sheet hatırlatıcısı (DeskPapers) ve kartların goto_tab etkisi
	# tab_changed("finance") + bu sinyali ardışık emit eder; tab mount'u senkron olduğu için bu
	# connect ikinci emit'ten önce hazırdır. _show_page'in kilit bekçisi (_yatirim_locked → erken
	# dönüş) deep-link'i güvenli kılar.
	EventBus.finance_subpage_requested.connect(_show_page)
	_apply_phase_lock()
	_show_page("ozet")


func _exit_tree() -> void:
	if EventBus.phase_changed.is_connected(_apply_phase_lock):
		EventBus.phase_changed.disconnect(_apply_phase_lock)
	if EventBus.seed_door_opened.is_connected(_apply_phase_lock):
		EventBus.seed_door_opened.disconnect(_apply_phase_lock)
	if EventBus.finance_subpage_requested.is_connected(_show_page):
		EventBus.finance_subpage_requested.disconnect(_show_page)


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Kenar boşluğu pencerenin (WindowFrame): başlık satırı kapatma glifiyle aynı çizgide.
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	col.add_child(head)
	head.add_child(UiFactory.make_label(tr("TAB_FINANCE"), &"PageTitleSerif"))
	var seg := HBoxContainer.new()
	seg.add_theme_constant_override("separation", UiTokens.SPACE_M)
	seg.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(seg)
	_ozet_btn = _make_segment(tr("FIN_SUBTAB_SUMMARY"), "ozet")
	_yatirim_btn = _make_segment(tr("FIN_SUBTAB_INVESTMENT"), "yatirim")   # LOC-DATA sub-page id
	seg.add_child(_ozet_btn)
	seg.add_child(_yatirim_btn)

	# Sub-page host — siblings toggled by visibility.
	var host := Control.new()
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(host)

	_ozet_view = FinanceOzetView.new()
	_ozet_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(_ozet_view)

	_yatirim_view = HUNT_TAB.instantiate()
	_yatirim_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(_yatirim_view)


func _make_segment(label: String, id: String) -> Button:
	var b := Button.new()
	b.text = label
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(_show_page.bind(id))
	return b


func _show_page(id: String) -> void:
	if id == "yatirim" and _yatirim_locked():   # LOC-DATA sub-page id
		# The lock predicate, not a literal `phase < 3`: the seed door card's goto_tab
		# finance/yatirim must reach the page the door just unlocked.
		return  # locked — the disabled button + tooltip already tell the player why
	_current = id
	_ozet_view.visible = id == "ozet"
	_yatirim_view.visible = id == "yatirim"   # LOC-DATA sub-page id
	_ozet_btn.modulate.a = 1.0 if id == "ozet" else UiTokens.TAB_LOCKED_ALPHA
	if not _yatirim_btn.disabled:
		_yatirim_btn.modulate.a = 1.0 if id == "yatirim" else UiTokens.TAB_LOCKED_ALPHA   # LOC-DATA sub-page id
	if id == "ozet":
		_ozet_view.refresh()  # görünür olurken taze boya — sinyaller görünmezken erken döner


# Connected to both phase_changed(int) and seed_door_opened(); the argument is unused.
func _apply_phase_lock(_signal_arg = null) -> void:
	var locked: bool = _yatirim_locked()
	_yatirim_btn.disabled = locked
	_yatirim_btn.tooltip_text = tr("FIN_SUBTAB_LOCKED") if locked else ""
	if locked or _current != "yatirim":   # LOC-DATA sub-page id
		_yatirim_btn.modulate.a = UiTokens.TAB_LOCKED_ALPHA
	if locked and _current == "yatirim":   # LOC-DATA sub-page id
		_show_page("ozet")


## Is the Yatırım sub-page still shut?
##
## A RATCHET, not a live read, and that matters: the seed door opens on a revenue bar,
## and a live predicate would re-lock this page the day after a customer churned. The
## door card is one_shot, so a page that re-locks can never re-announce itself. Once the
## door has opened this run the page stays reachable — the cap-table row and the growth
## expectation live here and outlast the door.
func _yatirim_locked() -> bool:
	return GameState.phase < 3 and not SeedRoundSystem.page_unlocked()
