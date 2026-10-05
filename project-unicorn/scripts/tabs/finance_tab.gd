extends Control

# Finans penceresi (GDD ch08, ch09). Ortak koyu başlıkta Finans ve üç ölçü: nakit, aylık net ve runway (kasa
# eksiyken kepenk sayacı), üst barın renk kuralıyla (UiTokens.D_runway_reading, D_net_ink). Denetim şeridinde
# ÖZET | YATIRIM; Yatırım, Series A Hunt'a ya da seed kapısına kadar kilitli, gerekçesi yanında. Gövdede Özet
# (FinanceOzetView) ya da Yatırım (hunt_tab.gd); pencere görünen sayfanın içeriği kadar uzar (fit_height).
# PROCESS_MODE_ALWAYS (.tscn).

## The window grows with the page in view (WindowLayer reads fit_height).
signal fit_changed

const HUNT_TAB := preload("res://scripts/tabs/hunt_tab.gd")
const PAGE_KEYS := {"ozet": "FIN_SUBTAB_SUMMARY", "yatirim": "FIN_SUBTAB_INVESTMENT"}   # LOC-DATA sub-page ids

var frame_options: Dictionary
var _kpis: HBoxContainer
var _outer: VBoxContainer
var _tabs: HBoxContainer
var _pages: Dictionary = {}   # id -> page; its `content` is what the window fits
var _current: String = "ozet"
var _signals: Array = []


func _init() -> void:
	_kpis = SprintUiShared.box(0)
	frame_options = {"title": "TAB_FINANCE", "kpi": _kpis, "pad": Vector2i.ZERO}


func _ready() -> void:
	_outer = SprintUiShared.column(0)
	_outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_outer)
	var ctl := PanelContainer.new()
	ctl.theme_type_variation = &"WinCtl"
	ctl.custom_minimum_size.y = UiTokens.D_H_WIN_CTL
	_tabs = SprintUiShared.box(UiTokens.SPACE_L)
	ctl.add_child(_tabs)
	_outer.add_child(ctl)
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
		[EventBus.cash_changed, _paint_kpis], [EventBus.mrr_changed, _paint_kpis],
		[EventBus.burn_changed, _paint_kpis], [EventBus.shutter_changed, _paint_kpis],
		[EventBus.runway_recalculated, _paint_kpis],
		[EventBus.phase_changed, _apply_phase_lock], [EventBus.seed_door_opened, _apply_phase_lock],
		# Deep-link: masanın term sheet hatırlatıcısı (DeskPapers) ve kartların goto_tab etkisi
		# tab_changed("finance") + bu sinyali ardışık emit eder; tab mount'u senkron olduğu için bu
		# connect ikinci emit'ten önce hazırdır. _show_page'in kilit bekçisi (_yatirim_locked → erken
		# dönüş) deep-link'i güvenli kılar.
		[EventBus.finance_subpage_requested, _show_page],
	]
	for s in _signals:
		(s[0] as Signal).connect(s[1])
	_paint_kpis()
	_show_page("ozet")


func _exit_tree() -> void:
	for s in _signals:
		if (s[0] as Signal).is_connected(s[1]):
			(s[0] as Signal).disconnect(s[1])


func fit_height() -> float:
	return _outer.get_combined_minimum_size().y + (_pages[_current].content as Control).get_combined_minimum_size().y


## Nakit; aylık net (artıysa olumlu, kasa artıdayken eksi bedeldir, tehlike yalnız kasa eksideyken); runway ya
## da kepenk sayacı. Her değişiklikte baştan kurulur; bağlandığı sinyallerin değeri okunmaz.
func _paint_kpis(_value = null) -> void:
	UiFactory.clear(_kpis)
	var cash := UiFactory.D_kpi(tr("FIN_CASH"), Fmt.money_exact(GameState.cash))
	if GameState.cash < 0:
		UiFactory.D_kpi_value(cash).add_theme_color_override("font_color", UiTokens.D_neg())
	_kpis.add_child(cash)
	var net: int = int(FinanceSystem.get_monthly_flow().net)
	var net_ink: Variant = UiTokens.D_net_ink(net)
	var net_cell := UiFactory.D_kpi(tr("FIN_MONTHLY_NET"), ("+" if net > 0 else "") + Fmt.money(net),
		net < 0 and net_ink == null)
	if net_ink != null:
		UiFactory.D_kpi_value(net_cell).add_theme_color_override("font_color", net_ink)
	_kpis.add_child(net_cell)
	var reading: Dictionary = UiTokens.D_runway_reading()
	var runway := UiFactory.D_kpi(tr("TOPBAR_SHUTTER" if reading.shutter else "FIN_RUNWAY"), reading.text)
	if reading.ink != null:
		UiFactory.D_kpi_value(runway).add_theme_color_override("font_color", reading.ink)
	runway.tooltip_text = reading.note
	_kpis.add_child(runway)


## ÖZET | YATIRIM; kilitliyken Yatırım soluk, kilidiyle, gerekçesi yanında.
func _paint_tabs() -> void:
	UiFactory.clear(_tabs)
	var locked: bool = _yatirim_locked()
	var open: Array = ["ozet"] if locked else PAGE_KEYS.keys()   # LOC-DATA sub-page id
	var seg := UiFactory.D_seg_tabs(open.map(func(id: String) -> String: return tr(PAGE_KEYS[id])),
		open.find(_current), func(i: int) -> void: _show_page(open[i]))
	_tabs.add_child(seg)
	if locked:
		seg.add_child(UiFactory.D_locked_tab(tr(PAGE_KEYS.yatirim)))
		_tabs.add_child(SprintUiShared.label(tr("FIN_SUBTAB_LOCKED"), &"Caption"))


func _show_page(id: String) -> void:
	if id == "yatirim" and _yatirim_locked():   # LOC-DATA sub-page id
		# The lock predicate, not a literal `phase < 3`: the seed door card's goto_tab
		# finance/yatirim must reach the page the door just unlocked.
		return  # locked — the locked tab and its reason already tell the player why
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
