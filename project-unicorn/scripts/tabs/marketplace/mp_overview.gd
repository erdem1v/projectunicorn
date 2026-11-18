extends VBoxContainer

# Pazaryeri'nin Genel sayfası: ziyaretten teslime dönüşüm (beş satır, adımın ipucu, iki küçük oran), iki tarafın memnuniyeti ve
# bekleyen talepler.
# Her değer saklanan durumdan ve modelin saf okuyucularından gelir; sayfa hiçbir seam'e yazmaz.

const PARTS := preload("res://scripts/tabs/marketplace/mp_parts.gd")
const STEPS := ["visits", "cart", "checkout", "order", "delivered"]
const STEP_KEYS := ["MP_STEP_VISITS", "MP_STEP_CART", "MP_STEP_CHECKOUT", "MP_STEP_ORDER", "MP_STEP_DELIVERED"]
const TIP_KEYS := ["", "MP_TIP_CART", "MP_TIP_CHECKOUT", "MP_TIP_ORDER", "MP_TIP_DELIVERED"]
## The visits' sources as the week's close counts them, [funnel key, name, ground, ink], lightest first.
const VISIT_SOURCES := [
	["returning", "MP_VISITS_RETURNING", UiTokens.D_INK_3, UiTokens.D_SURFACE_2],
	["organic", "MP_VISITS_ORGANIC", UiTokens.D_INK_4, UiTokens.D_SURFACE_2],
	["channel", "MP_VISITS_CHANNEL", UiTokens.D_LINE_3, UiTokens.D_INK_2],
	["campaign", "MP_VISITS_CAMPAIGN", UiTokens.D_LINE_2, UiTokens.D_INK_2],
]
## The ledger rows whose argument is a Talepler topic; the others' is a category.
const TOPIC_ROWS := ["met", "late_topic"]
const STEP := 136
const COUNT := 88
const RATE := 64
const TIP := 400
const SIDE := 376
const SAT_NAME := 104
const REASON := 96

var _state: Dictionary
var _world: Dictionary
var _funnel: Dictionary   # last week's counts over the open categories, `MarketplaceModel.funnel`
var _tag_slots: Array[Control] = []   # the reason slots of the two satisfaction rows


## A conversion step's bar: the track ends at the thin mark, which is the rate the step can reach and stands at the same x on every
## row; the fill is today's rate against it. Between the fill and the mark it is hatched: in the warning colour for the weakest
## step, a faint trace for the others.
class StepBar extends Control:
	var fill: float
	var weak: bool

	func _init(share: float, weakest: bool) -> void:
		fill = share
		weak = weakest
		custom_minimum_size.y = UiTokens.D_H_CAP_TRACK + 2 * UiTokens.SPACE_XS
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var bar := Rect2(0.0, UiTokens.SPACE_XS, size.x - UiTokens.D_BAR_TICK.x, size.y - 2.0 * UiTokens.SPACE_XS)
		draw_rect(bar, UiTokens.D_BAR_TRACK)
		var done := Rect2(bar.position, Vector2(bar.size.x * fill, bar.size.y))
		draw_rect(done, UiTokens.D_BAR_FILL)
		var gap := Rect2(done.end.x, bar.position.y, bar.end.x - done.end.x, bar.size.y)
		if weak:
			StagePaint.spill(self, gap)
			draw_rect(gap.grow(-UiTokens.BORDER_FOCUS / 2.0), UiTokens.D_warn(), false, UiTokens.BORDER_FOCUS)
		else:
			StagePaint.hatch(self, gap, Color.TRANSPARENT, UiTokens.D_EARLY_STRIPE, UiTokens.D_EARLY_PERIOD)
		draw_rect(Rect2(bar.end.x, 0.0, UiTokens.D_BAR_TICK.x, size.y), UiTokens.D_INK_1)


## The visits' bar: one track, a neutral tone per source, lightest for the visits the company earned and darkest for the ones it
## paid for; a hairline of the ground between two parts. A part wide enough to hold its word carries it.
class SourceBar extends Control:
	var parts: Array   # [{text, share, ground, ink}]

	func _init(source_parts: Array) -> void:
		parts = source_parts
		custom_minimum_size.y = UiTokens.D_H_CAP_TRACK + 2 * UiTokens.SPACE_XS
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var font: Font = get_theme_font(&"font", &"CaptionStrong")
		var font_size: int = get_theme_font_size(&"font_size", &"CaptionStrong")
		var top: float = UiTokens.SPACE_XS
		var height: float = size.y - 2.0 * top
		var x := 0.0
		var last := parts.size() - 1
		while last > 0 and float(parts[last].share) <= 0.0:
			last -= 1
		for n in parts.size():
			var part: Dictionary = parts[n]
			var width: float = size.x * float(part.share)
			draw_rect(Rect2(x, top, maxf(width - (float(UiTokens.BORDER_HAIRLINE) if n < last else 0.0), 0.0), height), part.ground)
			var word: float = font.get_string_size(part.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			if width >= word + 2.0 * UiTokens.SPACE_M:
				draw_string(font, Vector2(x + UiTokens.SPACE_M, top + (height + font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0),
					part.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, part.ink)
			x += width


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_3XL)


func refresh() -> void:
	UiFactory.clear(self)
	_state = MarketplaceSystem.read_state()
	_world = MarketplaceSystem.world()
	_funnel = MarketplaceModel.funnel(_state)
	var cols := SprintUiShared.box(UiTokens.SPACE_4XL)
	var left := SprintUiShared.column(UiTokens.SPACE_M)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var right := SprintUiShared.column(UiTokens.SPACE_XL)
	right.custom_minimum_size.x = SIDE
	cols.add_child(left)
	cols.add_child(right)
	add_child(cols)
	_paint_conversion(left)
	_paint_satisfaction(right)
	_paint_requests(right)


# --- Dönüşüm --------------------------------------------------------------------------------------------

func _count(i: int) -> float:
	return _funnel[STEPS[i]]


## A step's rate: its count over the step before it; 0 while that has none.
func _rate(i: int) -> float:
	var before := _count(i - 1)
	return _count(i) / before if before > 0.0 else 0.0


## The most a step's rate can reach over the open categories: the module's mark, lifted by last week's campaign.
func _reach(i: int) -> float:
	return MarketplaceModel.step_reach(_state, "", STEPS[i])


## How far last week's campaign lifted a step's reachable rate; 1 in a week without one.
func _campaign_lift(i: int) -> float:
	return _reach(i) / MarketplaceModel.cfg("steps.reach." + STEPS[i])


## The share of the reachable rate a step has reached.
func _fill(i: int) -> float:
	return _rate(i) / _reach(i)


## The step furthest from its reachable rate; -1 while there are no visits and while every step has reached its own.
func _weakest() -> int:
	if _count(0) <= 0.0:
		return -1
	var weak := -1
	var lowest := 1.0
	for i in range(1, STEPS.size()):
		if _fill(i) < lowest:
			weak = i
			lowest = _fill(i)
	return weak


## The path to an order: the whole rate as a sentence in the section's head, the columns' heads, five rows and the two small rates.
func _paint_conversion(col: VBoxContainer) -> void:
	var head := SprintUiShared.section("MP_CONVERSION")
	if _count(0) > 0.0:
		head.add_child(SprintUiShared.label(tr("MP_CONVERSION_LINE").format(
			{"rate": Fmt.percent(_count(3) / _count(0) * 100.0, 1)}), &"Caption"))
	col.add_child(head)
	col.add_child(_funnel_head())
	var weak := _weakest()
	var rows := SprintUiShared.column(0)
	for i in STEPS.size():
		rows.add_child(_funnel_row(i, i == weak))
	col.add_child(rows)
	if _count(0) > 0.0:
		col.add_child(SprintUiShared.pad(_small_rates(), Vector4i(UiTokens.SPACE_M, UiTokens.SPACE_M, UiTokens.SPACE_M, 0)))


## The returning users' share of the orders and the returned share of them, as two figures under the rows.
func _small_rates() -> HBoxContainer:
	var pairs := SprintUiShared.box(UiTokens.SPACE_4XL)
	var metrics := MarketplaceModel.metrics(_state, _world)
	for pair in [["MP_RETURNING", metrics.returning_share], ["MP_RETURNS", metrics.return_rate]]:
		var item := SprintUiShared.box(UiTokens.SPACE_S)
		item.add_child(SprintUiShared.label(tr(pair[0]), &"Caption"))
		item.add_child(SprintUiShared.label(Fmt.percent(float(pair[1]) * 100.0, 0), &"DataStrong"))
		pairs.add_child(item)
	return pairs


## The funnel's column heads: the count's is last week, the rate's and the bar's is the step before it; "reachable" stands over
## the mark the bars end at.
func _funnel_head() -> PanelContainer:
	var head := PanelContainer.new()
	head.theme_type_variation = &"TableHead"
	var line := SprintUiShared.box(UiTokens.SPACE_XL)
	line.add_child(RnDUiShared.spacer(STEP))
	line.add_child(HRUiShared.D_head(tr("MP_COL_LAST_WEEK"), COUNT, HORIZONTAL_ALIGNMENT_RIGHT))
	var rates := SprintUiShared.box(0)
	rates.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rates.add_child(HRUiShared.D_head(tr("MP_COL_FROM_PREV"), 0, HORIZONTAL_ALIGNMENT_LEFT))
	rates.add_child(RnDUiShared.spacer())
	rates.add_child(HRUiShared.D_head(tr("MP_REACHABLE"), 0, HORIZONTAL_ALIGNMENT_RIGHT))
	line.add_child(rates)
	head.add_child(SprintUiShared.pad(line, Vector4i(UiTokens.SPACE_M, 0, UiTokens.SPACE_M, 0)))
	return head


## A step's row: name, count, rate (faint, the weakest step's in the warning colour) and bar. The tip of what carries the step
## opens when the pointer rests on its row; the visits' tip lists their sources.
func _funnel_row(i: int, weak: bool) -> PanelContainer:
	var row := PARTS.TipRow.new()
	row.theme_type_variation = &"TableRow"
	row.custom_minimum_size.y = UiTokens.D_H_ROW_LG
	var line := SprintUiShared.box(UiTokens.SPACE_XL)
	line.add_child(PARTS.cell(tr(STEP_KEYS[i]), &"DataText", STEP, HORIZONTAL_ALIGNMENT_LEFT))
	line.add_child(PARTS.cell(PARTS.count(_count(i)), &"DataStrong", COUNT, HORIZONTAL_ALIGNMENT_RIGHT))
	if i == 0:
		line.add_child(PARTS.cell("", &"DataText", RATE, HORIZONTAL_ALIGNMENT_RIGHT))
		line.add_child(_visits_bar())
		if _count(0) > 0.0:
			row.build = _visits_tip
			row.tooltip_text = tr(STEP_KEYS[0])
	else:
		line.add_child(PARTS.cell(Fmt.percent(_rate(i) * 100.0, 0), &"DataStrong" if weak else &"NoteMuted", RATE,
			HORIZONTAL_ALIGNMENT_RIGHT, UiTokens.D_warn() if weak else null))
		line.add_child(StepBar.new(_fill(i), weak))
		if _count(0) > 0.0:
			row.build = _step_tip.bind(i)
			row.tooltip_text = tr(STEP_KEYS[i])
	var inset := SprintUiShared.pad(line, Vector4i(UiTokens.SPACE_M, 0, UiTokens.SPACE_M, 0))
	HRUiShared.set_mouse_ignore(inset)
	row.add_child(inset)
	return row


## The visits' sources, from what the company earned to what it paid for: the users who come back, the organic visits, the ones a
## channel brought and, in a campaign's week, the campaign's. A part has no width before the first visit and in a week its source
## brought none.
func _visits_bar() -> SourceBar:
	var visits := _count(0)
	var parts := []
	for source: Array in VISIT_SOURCES:
		parts.append({"text": tr(source[1]), "share": float(_funnel.get(source[0], 0.0)) / visits if visits > 0.0 else 0.0,
			"ground": source[2], "ink": source[3]})
	return SourceBar.new(parts)


## The visits' tip, a key of the bar: each source that brought visits last week, a sample of its part's tone, its count and its
## share of them, lightest first (a tree key's sample, as R&D's). The bar has no room for a narrow part's name.
func _visits_tip() -> Control:
	var tip := SprintUiShared.tip_column()
	tip.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var visits := _count(0)
	for source: Array in VISIT_SOURCES:
		var n: float = _funnel.get(source[0], 0.0)
		if n <= 0.0:
			continue
		var line := SprintUiShared.box(UiTokens.SPACE_M)
		var sample := ColorRect.new()
		sample.color = source[2]
		sample.custom_minimum_size = UiTokens.D_SWATCH
		sample.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(sample)
		line.add_child(SprintUiShared.label(tr("MP_TIP_ROW").format({"row": tr(source[1]),
			"v": PARTS.count(n) + SprintUiShared.SEP + Fmt.percent(n / visits * 100.0, 0)}), &"CaptionPrimary"))
		tip.add_child(line)
	return tip


## The tip of a step, a line each saying what it is of: the step, its rate of the step before it and the most it can reach; the
## module that carries it and the tier it stands at; the next tier and the weekly orders it would bring; the open bugs and the
## weekly orders their fix would bring; in a campaign's week, how far the campaign lifted the mark. A module with no tier yet has
## no line of its own.
func _step_tip(i: int) -> Control:
	var hint: Dictionary = MarketplaceModel.step_hint(_state, _world, STEPS[i])
	var line: String = MarketplaceSystem.MODULE_LINES[hint.module]
	var tip := SprintUiShared.tip_column()
	tip.custom_minimum_size.x = TIP
	tip.add_theme_constant_override("separation", UiTokens.SPACE_S)
	tip.add_child(SprintUiShared.prose(tr(TIP_KEYS[i]).format({"rate": Fmt.percent(_rate(i) * 100.0, 0),
		"cap": Fmt.percent(_reach(i) * 100.0, 0)}), &"TipTitle"))
	if int(hint.tier) > 0:
		tip.add_child(SprintUiShared.prose(tr("MP_TIP_MODULE").format(
			{"module": SprintCatalog.cap_name(line), "tier": _tier_name(line, int(hint.tier))}), &"CaptionPrimary"))
	if int(hint.next_tier) > 0:
		tip.add_child(SprintUiShared.prose(tr("MP_TIP_NEXT").format(
			{"tier": _tier_name(line, int(hint.next_tier)), "n": PARTS.count(hint.next_gain)}), &"CaptionPrimary"))
	var bugs := int(hint.bugs)
	if bugs > 0:
		tip.add_child(SprintUiShared.prose(tr(Fmt.count_key("MP_TIP_BUGS", bugs)).format(
			{"n": Fmt.group(bugs), "m": PARTS.count(hint.bug_gain)}), &"CaptionPrimary"))
	var lift := _campaign_lift(i)
	if lift > 1.0:
		tip.add_child(SprintUiShared.prose(tr("MP_TIP_CAMPAIGN").format({"n": Fmt.number(lift, 1)}), &"CaptionPrimary"))
	return tip


func _tier_name(line: String, tier: int) -> String:
	return SprintCatalog.step_name(String(ProductLines.step_at(line, tier).id))


# --- Memnuniyet -----------------------------------------------------------------------------------------

func _paint_satisfaction(col: VBoxContainer) -> void:
	var block := SprintUiShared.column(UiTokens.SPACE_M)
	block.add_child(SprintUiShared.section("MP_SATISFACTION"))
	var rows := SprintUiShared.column(0)
	_tag_slots.clear()
	for side: String in MarketplaceModel.SIDES:
		rows.add_child(_sat_row(side))
	block.add_child(rows)
	col.add_child(block)


## Both reason slots take the width of the wider tag, never less than REASON, so the two meters end together. The tags' own
## width is known once they stand in the tree, where the slots report it.
func _match_tag_slots() -> void:
	var width := 0
	for slot in _tag_slots:
		width = maxi(width, ceili(slot.get_combined_minimum_size().x))
	for slot in _tag_slots:
		slot.custom_minimum_size.x = width


## A crowd's satisfaction on a row of the funnel's height: name, figure and a meter that takes the column's width, the warning
## colour under SalesConstants.SAT_MID, with the heaviest negative ledger row's name in its own slot at the end (a row with a
## category or a topic in its short form). The slot keeps its room in the rows without one. The tip lists every row of the ledger
## with its points.
func _sat_row(side: String) -> PanelContainer:
	var value := roundi(_state.sat[side])
	var warn := value < SalesConstants.SAT_MID
	var row := PARTS.TipRow.new()
	row.theme_type_variation = &"TableRow"
	row.custom_minimum_size.y = UiTokens.D_H_ROW_LG
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	line.add_child(PARTS.cell(tr("MP_SIDE_" + side.to_upper()), &"DataText", SAT_NAME, HORIZONTAL_ALIGNMENT_LEFT))
	line.add_child(PARTS.cell(str(value), &"SatValue", UiTokens.D_W_SAT, HORIZONTAL_ALIGNMENT_RIGHT, UiTokens.D_warn() if warn else null))
	line.add_child(HRUiShared.D_bar(Vector2(0, UiTokens.D_SAT_BAR.y), value / 100.0, UiTokens.D_warn() if warn else UiTokens.D_BAR_FILL))
	var slot := SprintUiShared.box(0)
	slot.custom_minimum_size.x = REASON
	slot.minimum_size_changed.connect(_match_tag_slots)
	_tag_slots.append(slot)
	var worst := MarketplaceModel.ledger_worst(_state, side)
	if not worst.is_empty():
		slot.add_child(UiFactory.D_tag(_row_name(worst, true), &"warn"))
	line.add_child(slot)
	var ledger: Array = _state.ledger[side]
	if not ledger.is_empty():
		row.build = _ledger_tip.bind(ledger)
		row.tooltip_text = tr("MP_SIDE_" + side.to_upper())
	var inset := SprintUiShared.pad(line, Vector4i(UiTokens.SPACE_M, 0, UiTokens.SPACE_M, 0))
	HRUiShared.set_mouse_ignore(inset)
	row.add_child(inset)
	return row


## Every row of a side's ledger, the heaviest first, each with its points.
func _ledger_tip(ledger: Array) -> Control:
	var tip := SprintUiShared.tip_column()
	tip.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var rows := ledger.duplicate()
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.points < b.points)
	for row: Dictionary in rows:
		var points := roundi(row.points)
		tip.add_child(SprintUiShared.prose(tr("MP_TIP_ROW").format(
			{"row": _row_name(row, false), "v": ("+" if points > 0 else "") + Fmt.group(points)}), &"CaptionPrimary"))
	return tip


## A ledger row's name; `short` is the name without its category or topic, for the tag that has no room for it.
func _row_name(row: Dictionary, short: bool) -> String:
	var key := "MP_ROW_" + String(row.key).to_upper()
	if row.arg == "":
		return tr(key)
	if short:
		return tr(key + "_SHORT")
	var named := MarketplaceSystem.topic_name(row.arg) if row.key in TOPIC_ROWS else tr("MP_CAT_" + String(row.arg).to_upper())
	return tr(key).format({"category": named, "topic": named})


# --- Talepler ----------------------------------------------------------------------------------------------

## Bekleyen konuların sayısı, Talepler'in Bekleyen süzgeciyle aynı tanımdan, ve Talepler'i o süzgeçte açan düğme. Bekleyen konu
## yokken oyuncunun açacağı bir şey olmadığından bölüm hiç çizilmez.
func _paint_requests(col: VBoxContainer) -> void:
	var waiting := ProductModel.waiting_topics().size()
	if waiting == 0:
		return
	var block := SprintUiShared.column(UiTokens.SPACE_M)
	block.add_child(SprintUiShared.section("PRODUCT_VIEW_REQUESTS"))
	var row := PanelContainer.new()
	row.theme_type_variation = &"TableRow"
	row.custom_minimum_size.y = UiTokens.D_H_ROW_LG
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	line.add_child(SprintUiShared.label(SprintUiShared.count("MP_REQUESTS_WAITING", waiting), &"DataText"))
	line.add_child(RnDUiShared.spacer())
	line.add_child(SprintUiShared.button(tr("MP_REQUESTS_OPEN"), &"SecondaryButtonSmall",
		func() -> void: SprintUiShared.open_requests(get_tree(), {"status": "waiting"})))
	row.add_child(SprintUiShared.pad(line, Vector4i(UiTokens.SPACE_M, 0, UiTokens.SPACE_M, 0)))
	block.add_child(row)
	col.add_child(block)

