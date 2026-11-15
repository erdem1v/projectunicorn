extends VBoxContainer

# Pazaryeri'nin Politikalar sayfası: iki grupta dört kural, her biri seçenekleriyle. Yürürlükteki seçenekten başkasına basılınca
# satırın altında o seçeneğin dört hafta sonraki farkı çiplerde, kilidin süresi ve Uygula açılır; Uygula kuralı yazar ve satır
# dört hafta kilitlenir. Şartını bekleyen kural şartını yazar. Değerler saklanan durumdan ve modelin saf okuyucularından gelir;
# yazan yalnız sahibin seam'idir.

const PARTS := preload("res://scripts/tabs/marketplace/mp_parts.gd")
const RULE := 200
const OPTIONS := 450
## The rules under each group's name.
const GROUPS := [["MP_GROUP_SHOPPING", ["shipping", "return_window", "return_shipping"]], ["MP_GROUP_STORE_RULES", ["admission"]]]
## The results a rule's change is read by, in the order they are written: the `MarketplaceModel.metrics` figure, its chip's key,
## whether more of it is better and, when the chip has one, the key of the line its tip adds.
const RESULTS := {
	"shipping": [["orders", "MP_CHIP_ORDERS", true], ["store_earnings", "MP_CHIP_STORE_EARNINGS", true, "MP_TIP_STORE_EARNINGS"],
		["monthly_revenue", "MP_CHIP_REVENUE", true]],
	"return_window": [["returning_share", "MP_CHIP_RETURNING", true], ["return_rate", "MP_CHIP_RETURN_RATE", false],
		["store_sat", "MP_CHIP_STORE_SAT", true], ["monthly_revenue", "MP_CHIP_REVENUE", true, "MP_TIP_NO_COMMISSION_ON_RETURN"]],
	"return_shipping": [["store_sat", "MP_CHIP_STORE_SAT", true], ["return_rate", "MP_CHIP_RETURN_RATE", false],
		["monthly_cost", "MP_CHIP_COST", false]],
	"admission": [["store_acquisition", "MP_CHIP_ACQUISITION", true], ["return_rate", "MP_CHIP_RETURN_RATE", false],
		["user_sat", "MP_CHIP_USER_SAT", true]],
}

var _state: Dictionary
var _world: Dictionary
var _rule := ""     # the rule whose choice is made and not applied yet; one at a time
var _option := ""   # that choice
var _diff := {}     # `MarketplaceModel.preview_policy` of that choice, taken when the choice or the week changes
var _diff_week := -1   # the week `_diff` was taken in


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_M)


## Reads the state again: a choice made and not applied keeps standing, its preview taken again when the week has turned.
func refresh() -> void:
	_state = MarketplaceSystem.read_state()
	_world = MarketplaceSystem.world()
	if _rule != "" and _world.week != _diff_week:
		_preview()
	_paint()


## The four-close preview of the choice; a choice the model refuses has none and is dropped.
func _preview() -> void:
	_diff = MarketplaceModel.preview_policy(_state, _world, _rule, _option)
	_diff_week = _world.week
	if _diff.is_empty():
		_rule = ""


func _paint() -> void:
	UiFactory.clear(self)
	for group: Array in GROUPS:
		add_child(SprintUiShared.section(group[0]))
		for rule: String in group[1]:
			add_child(_row(rule))
			if rule == _rule:
				add_child(_outcome())
	PARTS.restyle_segments.call_deferred(self)


# --- Satırlar -------------------------------------------------------------------------------------------

## A rule's row: its name and options; after them what holds the options shut, what the rule waits for or the weeks it stands
## locked.
func _row(rule: String) -> PanelContainer:
	var open := MarketplaceModel.policy_open(_world, rule)
	var left := MarketplaceModel.lock_left(_state.policy[rule].day, _world)
	var row := PanelContainer.new()
	row.theme_type_variation = &"TableRow"
	row.custom_minimum_size.y = UiTokens.D_H_ROW_LG
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	line.add_child(PARTS.cell(tr("MP_RULE_" + rule.to_upper()), &"DataStrong" if open else &"DataText", RULE,
		HORIZONTAL_ALIGNMENT_LEFT, null if open else UiTokens.D_INK_OFF))
	var slot := SprintUiShared.box(0)
	slot.custom_minimum_size.x = OPTIONS
	slot.add_child(_options(rule, open and left == 0))
	line.add_child(slot)
	if not open:
		var need := SprintUiShared.box(UiTokens.SPACE_S)
		need.add_child(UiFactory.make_glyph(UiFactory.LOCK_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_OFF))
		need.add_child(SprintUiShared.label(_need(rule), &"MetaMuted"))
		line.add_child(need)
	elif left > 0:
		line.add_child(PARTS.lock_row(left))
	row.add_child(line)
	return row


## The rule's options, the one in force filled. The segment a choice waits on is framed, and the one in force then takes the choice
## back when pressed.
func _options(rule: String, can_pick: bool) -> PanelContainer:
	var options: Array = MarketplaceModel.cfg("rules.options")[rule]
	var kept: int = options.find(_state.policy[rule].pick)
	var on_pick := func(i: int) -> void: _pick(rule, options[i])
	var pick := UiFactory.D_seg_pick(options.map(func(option: String) -> Dictionary:
		return {"text": tr("MP_OPT_%s_%s" % [rule.to_upper(), option.to_upper()])}), kept, on_pick, not can_pick)
	if rule == _rule:
		PARTS.mark_pending(pick, options.find(_option))
		var keys := pick.get_child(0).get_children().filter(func(n: Node) -> bool: return n is Button)
		keys[kept].pressed.connect(on_pick.bind(kept))
	return pick


## What the rule waits for: the tier of the module its need names, as that tier's name.
func _need(rule: String) -> String:
	var need: Dictionary = MarketplaceModel.cfg("rules.needs")[rule]
	var step: Dictionary = ProductLines.step_at(MarketplaceSystem.MODULE_LINES[need.module], int(need.tier))
	return tr("MP_NEEDS_TIER").format({"tier": SprintCatalog.step_name(String(step.id))})


## The pending choice's results under its row: the chips, and the lock and Apply at the far end.
func _outcome() -> PanelContainer:
	var row := PanelContainer.new()
	row.theme_type_variation = &"TableRow"
	row.custom_minimum_size.y = UiTokens.D_H_ROW
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	var chips := PARTS.chip_flow(RESULTS[_rule].map(_chip))
	chips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(chips)
	line.add_child(PARTS.apply_cell(int(MarketplaceModel.cfg("rules.lock_weeks")), true, _apply))
	row.add_child(SprintUiShared.pad(line, Vector4i(RULE + UiTokens.SPACE_L, 0, 0, 0)))
	return row


## One result as a chip, in the tone of its change's sign (a figure that rounds to none is a plain fact); its tip is the line it
## adds, if it has one, then that the figure is the difference four weeks from now.
func _chip(result: Array) -> Control:
	var read := _read(result[0])
	var change: float = read[0]
	var mark := "+" if change > 0.0 else "-" if change < 0.0 else ""
	var kind := &"fact" if is_zero_approx(change) else &"gain" if (change > 0.0) == result[2] else &"cost"
	return PARTS.chip(tr(result[1]).format({"v": mark + read[1]}), kind, result.slice(3).map(tr) + [tr("MP_TIP_PREVIEW")])


## A figure's change as the chip writes it: rounded to what it shows, and its magnitude's text. Shares are written in percentage
## points, the store's earnings as its relative change, satisfaction in whole points, money whole.
func _read(metric: String) -> Array:
	var change: float = _diff[metric]
	match metric:
		"store_earnings":
			change = snappedf(change * 100.0, 1.0)
			return [change, Fmt.percent(absf(change), 0)]
		"returning_share", "return_rate":
			change = snappedf(change * 100.0, 0.1)
			return [change, Fmt.percent(absf(change), 1)]
		"orders", "store_acquisition":
			change = snappedf(change, 0.1)
			return [change, PARTS.count(absf(change))]
		"store_sat", "user_sat":
			change = roundf(change)
			return [change, Fmt.group(roundi(absf(change)))]
	change = roundf(change)
	return [change, Fmt.money(roundi(absf(change)))]


# --- Eylemler -------------------------------------------------------------------------------------------

## A press on another option makes it the pending choice, previewed here and not on every repaint; a press on the one in force
## takes the choice back.
func _pick(rule: String, option: String) -> void:
	if option == _state.policy[rule].pick:
		_rule = ""
	else:
		_rule = rule
		_option = option
		_preview()
	_paint()


## The choice is dropped before the write: the owner's seam announces it and the page repaints from that announcement, inside the
## call. The options are shut whenever the model would refuse, so the write lands.
func _apply() -> void:
	var rule := _rule
	_rule = ""
	MarketplaceSystem.set_policy(rule, _option)
