class_name MeetingRuler
extends VBoxContainer

# The price ruler of a sales meeting's second act, on the meeting panel's deck: the band the customer
# talks in, where the conversation opened, every number the customer has written, the price the
# founder holds, and the deal that price makes. It draws SalesMeetingAdapter's `instrument` and says
# where the founder put the handle; the panel asks the adapter and hands the next instrument back.
#
# THE RESERVE IS NEVER DRAWN: the counters give it away, turn by turn, and that is the game.
# THE INSULT ZONE IS DRAWN: a tone on the offer alone would let the price cross the line unseen.
# The zone a promise closed is hatched rather than tinted, because it is unavailable, not dangerous.

signal changed(value: int)

var _rail := _Rail.new()
var _low := UiFactory.make_label("", &"SmallMuted")
var _price_label := UiFactory.make_label("", &"KeyLabel")
var _price := UiFactory.make_label("", &"ValueText", UiTokens.D_INK_1)
var _high := UiFactory.make_label("", &"SmallMuted")
var _deal := UiFactory.make_label("", &"ValueText", UiTokens.D_INK_1)
var _capacity := UiFactory.make_label("", &"Caption")


## The ruler itself: `_draw`, because a danger zone, an anchor tick, a trail of counters and a handle
## are no stylebox. Every colour is a token; the handle is ink, red once the price insults.
class _Rail extends Control:
	signal picked(value: int)

	var ins: Dictionary

	func _init() -> void:
		custom_minimum_size.y = UiTokens.D_H_RULER

	func _x_of(value: int) -> float:
		var low: int = ins.band.low
		return clampf(float(value - low) / float(int(ins.band.high) - low) * size.x, 0.0, size.x)

	func _gui_input(event: InputEvent) -> void:
		if not ins.can_offer:
			return
		var drag := event as InputEventMouseMotion
		if not UiFactory.is_left_click(event) and (drag == null or (drag.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0):
			return
		var t := clampf((event as InputEventMouse).position.x / size.x, 0.0, 1.0)
		var value := int(round(lerpf(float(ins.band.low), float(ins.band.high), t)))
		if value != int(ins.selected):
			picked.emit(value)

	func _draw() -> void:
		var mid := size.y * 0.5
		var track := float(UiTokens.D_RULER_TRACK)
		var top := mid - track * 0.5
		draw_rect(Rect2(0.0, top, size.x, track), UiTokens.D_BAR_TRACK)
		if int(ins.insult_from) < int(ins.band.high):
			var ix := _x_of(ins.insult_from)
			draw_rect(Rect2(ix, top, size.x - ix, track), UiTokens.D_neg())
		if ins.locked_from >= 0:
			var x := _x_of(ins.locked_from)
			while x < size.x:
				draw_line(Vector2(x, mid - UiTokens.SPACE_M), Vector2(x + UiTokens.SPACE_XS, mid + UiTokens.SPACE_M),
					UiTokens.D_INK_4, UiTokens.BORDER_HAIRLINE)
				x += UiTokens.SPACE_S
		_tick(_x_of(ins.anchor), UiTokens.D_RULER_ANCHOR, UiTokens.BORDER_HAIRLINE, UiTokens.D_INK_4)
		# The customer's numbers; the one on the table now is the ink one.
		var counters: Array = ins.counters
		for i in counters.size():
			var now: bool = i == counters.size() - 1
			_tick(_x_of(counters[i]), UiTokens.D_RULER_MARK, UiTokens.BORDER_FOCUS if now else UiTokens.BORDER_HAIRLINE,
				UiTokens.D_INK_1 if now else UiTokens.D_INK_3)
		# The handle's left edge is clamped, not its centre, so at the band's floor it still draws
		# whole rather than as a sliver; its ground ring parts it from the track and the ticks.
		var handle: Vector2 = UiTokens.D_RULER_HANDLE
		var hx := clampf(_x_of(ins.selected) - handle.x * 0.5, 0.0, maxf(size.x - handle.x, 0.0))
		var box := Rect2(hx, mid - handle.y * 0.5, handle.x, handle.y)
		draw_rect(box.grow(UiTokens.BORDER_FOCUS), UiTokens.D_SURFACE_3)
		draw_rect(box, UiTokens.D_neg() if ins.insulting else UiTokens.D_INK_1)

	func _tick(x: float, height: int, width: int, ink: Color) -> void:
		draw_rect(Rect2(x - width * 0.5, (size.y - height) * 0.5, width, height), ink)


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	_rail.picked.connect(changed.emit)
	add_child(_rail)

	# The band's ends at the sides, the held price between them.
	var scale_row := SprintUiShared.box(0)
	var held := SprintUiShared.box(UiTokens.SPACE_M)
	held.alignment = BoxContainer.ALIGNMENT_CENTER
	held.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for part: Label in [_low, _price_label, _price, _high]:
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	held.add_child(_price_label)
	held.add_child(_price)
	scale_row.add_child(_low)
	scale_row.add_child(held)
	scale_row.add_child(_high)
	add_child(scale_row)

	_deal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(SprintUiShared.pad(_deal, Vector4i(0, UiTokens.SPACE_M, 0, 0)))
	add_child(_capacity)


## `instrument`: NegotiationSystem.view_state() with the adapter's `price_label`, `locked_reason`
## and `deal` (the MRR line, then the capacity line).
func show_instrument(instrument: Dictionary) -> void:
	_rail.ins = instrument
	_rail.tooltip_text = instrument.locked_reason
	_rail.queue_redraw()
	_low.text = Fmt.money_exact(instrument.band.low)
	_high.text = Fmt.money_exact(instrument.band.high)
	_price_label.text = Fmt.upper(instrument.price_label)
	_price.text = Fmt.money_exact(instrument.selected)
	_price.add_theme_color_override("font_color", UiTokens.D_neg() if instrument.insulting else UiTokens.D_INK_1)
	_deal.text = instrument.deal[0]
	_capacity.text = instrument.deal[1]
