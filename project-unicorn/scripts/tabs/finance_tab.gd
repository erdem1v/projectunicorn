extends Control

# Finans penceresi (GDD ch08, ch09). Ortak koyu başlıkta yalnız Finans: nakit, aylık net ve runway üst barda, pencere
# açıkken de görünür (envanter shell-03: ikinci kez yazılmaz). Denetim şeridinde, Yatırım açılınca,
# ÖZET | YATIRIM; Yatırım, Series A Hunt'a ya da seed kapısına kadar kilitli, gerekçesi yanında. Gövdede Özet
# (FinanceOzetView) ya da Yatırım (hunt_tab.gd); pencere görünen sayfanın içeriği kadar uzar (fit_height).
# PROCESS_MODE_ALWAYS (.tscn).

## The window grows with the page in view (WindowLayer reads fit_height).
signal fit_changed

const HUNT_TAB := preload("res://scripts/tabs/hunt_tab.gd")
const PAGE_KEYS := {"ozet": "FIN_SUBTAB_SUMMARY", "yatirim": "FIN_SUBTAB_INVESTMENT"}   # LOC-DATA sub-page ids

var frame_options: Dictionary
var _outer: VBoxContainer
var _ctl: PanelContainer   # the tab strip's row
var _tabs: HBoxContainer
var _pages: Dictionary = {}   # id -> page; its `content` is what the window fits
var _current: String = "ozet"
var _signals: Array = []


func _init() -> void:
	frame_options = {"title": "TAB_FINANCE", "pad": Vector2i.ZERO}


func _ready() -> void:
	_outer = SprintUiShared.column(0)
	_outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_outer)
	_ctl = PanelContainer.new()
	_ctl.theme_type_variation = &"WinCtl"
	_ctl.custom_minimum_size.y = UiTokens.D_H_WIN_CTL
	_tabs = SprintUiShared.box(UiTokens.SPACE_L)
	_ctl.add_child(_tabs)
	_outer.add_child(_ctl)
	var host := Control.new()
	var body := SprintUiShared.pad(host, Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XL, UiTokens.SPACE_3XL, UiTokens.SPACE_3XL))
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outer.add_child(body)
	_pages = {"ozet": FinanceOzetView.new(), "yatirim": HUNT_TAB.new()}   # LOC-DATA sub-page ids
	for id in _pages:
		var page: Control = _pages[id]
		page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		host.add_child(page)
		(page.content as Control).minimum_size_changed.connect(fit_changed.emit)
	_signals = [
		[EventBus.phase_changed, _apply_phase_lock], [EventBus.seed_door_opened, _apply_phase_lock],
		# Deep-link: masanın term sheet hatırlatıcısı (DeskPapers) ve kartların goto_tab etkisi
		# tab_changed("finance") + bu sinyali ardışık emit eder; tab mount'u senkron olduğu için bu
		# connect ikinci emit'ten önce hazırdır. _show_page'in kilit bekçisi (_yatirim_locked → erken
		# dönüş) deep-link'i güvenli kılar.
		[EventBus.finance_subpage_requested, _show_page],
	]
	for s in _signals:
		(s[0] as Signal).connect(s[1])
	_show_page("ozet")


func _exit_tree() -> void:
	for s in _signals:
		if (s[0] as Signal).is_connected(s[1]):
			(s[0] as Signal).disconnect(s[1])


func fit_height() -> float:
	return _outer.get_combined_minimum_size().y + (_pages[_current].content as Control).get_combined_minimum_size().y


## ÖZET | YATIRIM. Yatırım açılana kadar hiç görünmez, yaptıkça açılır (envanter world-01): tek sayfayla sekme satırı
## da, boş şeridi de çizilmez (shell-03); açılınca pencere şeridin boyu kadar uzar.
func _paint_tabs() -> void:
	UiFactory.clear(_tabs)
	var shown: bool = not _yatirim_locked()
	if _ctl.visible != shown:
		_ctl.visible = shown
		fit_changed.emit()
	if not shown:
		return
	var open: Array = PAGE_KEYS.keys()   # LOC-DATA sub-page id
	_tabs.add_child(UiFactory.D_seg_tabs(open.map(func(id: String) -> String: return tr(PAGE_KEYS[id])),
		open.find(_current), func(i: int) -> void: _show_page(open[i])))


func _show_page(id: String) -> void:
	if id == "yatirim" and _yatirim_locked():   # LOC-DATA sub-page id
		# The lock predicate, not a literal `phase < 3`: the seed door card's goto_tab
		# finance/yatirim must reach the page the door just unlocked.
		return  # locked: the page does not exist for the player yet (world-01: no tab, no strip)
	_current = id
	for page_id in _pages:
		(_pages[page_id] as Control).visible = page_id == id
	if id == "ozet":
		_pages.ozet.refresh()  # görünür olurken taze boya — sinyaller görünmezken erken döner
	_paint_tabs()
	fit_changed.emit()


# Connected to both phase_changed(int) and seed_door_opened(); the argument is unused.
func _apply_phase_lock(_signal_arg = null) -> void:
	if _yatirim_locked() and _current == "yatirim":   # LOC-DATA sub-page id
		_show_page("ozet")
	else:
		_paint_tabs()


## Is the Yatırım sub-page still shut?
##
## A RATCHET, not a live read, and that matters: the seed door opens on a revenue bar,
## and a live predicate would re-lock this page the day after a customer churned. The
## door card is one_shot, so a page that re-locks can never re-announce itself. Once the
## door has opened this run the page stays reachable — the cap-table row and the growth
## expectation live here and outlast the door.
func _yatirim_locked() -> bool:
	return GameState.phase < 3 and not SeedRoundSystem.page_unlocked()
