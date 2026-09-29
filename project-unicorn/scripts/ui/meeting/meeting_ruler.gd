class_name MeetingRuler
extends VBoxContainer

# The price ruler of a sales meeting's second act, in the meeting panel's options area: the band
# the customer talks in, where the conversation opened, every number the customer has written, the
# price the founder holds, and the deal that price makes. It draws SalesMeetingAdapter's
# `instrument` and says where the founder put the handle; the panel asks the adapter and hands the
# next instrument back.
#
# THE RESERVE IS NEVER DRAWN: the counters give it away, turn by turn, and that is the game.
# THE INSULT ZONE IS DRAWN: a tone on the offer button alone would let the price cross the line
# unseen.
# The zone a promise closed is hatched rather than tinted, because it is unavailable, not dangerous.

signal changed(value: int)

var _rail := _Rail.new()
var _low := UiFactory.make_label("", &"MicroLabel")
var _price_label := UiFactory.make_label("", &"MicroLabel")
var _price := UiFactory.make_label("", &"MetricValueInk")
var _high := UiFactory.make_label("", &"MicroLabel")
var _deal := UiFactory.make_label("", &"MetricValueInk")
var _capacity := UiFactory.make_label("", &"RowMeta")


## The ruler itself: `_draw`, because three zones, an anchor tick, a trail of counters and a
## handle are no stylebox. Every colour is a token.
class _Rail extends Control:
	signal picked(value: int)

	const RAIL_H := UiTokens.SPACE_XS
	const HANDLE := Vector2(UiTokens.SPACE_L, UiTokens.SPACE_3XL)
	const TICK_H := UiTokens.SPACE_L     # half-height of the anchor tick
	const MARK_H := UiTokens.SPACE_S     # half-height of a counter mark
	const HATCH_H := UiTokens.SPACE_M    # half-height of a locked-zone hatch

	var ins: Dictionary

	func _init() -> void:
		custom_minimum_size = Vector2(0, HANDLE.y + TICK_H * 2)

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
		var top := mid - RAIL_H * 0.5
		draw_rect(Rect2(0.0, top, size.x, RAIL_H), UiTokens.SURFACE_SUNKEN)
		if int(ins.insult_from) < int(ins.band.high):
			var ix := _x_of(ins.insult_from)
			draw_rect(Rect2(ix, top, size.x - ix, RAIL_H), UiTokens.negative_rule())
		if ins.locked_from >= 0:
			var x := _x_of(ins.locked_from)
			while x < size.x:
				draw_line(Vector2(x, mid - HATCH_H), Vector2(x + UiTokens.SPACE_XS, mid + HATCH_H),
					UiTokens.INK_FAINT, UiTokens.BORDER_HAIRLINE)
				x += UiTokens.SPACE_S
		# Where the stance dial opened the talk. Neutral: the amber on the ruler is the handle's.
		var ax := _x_of(ins.anchor)
		draw_line(Vector2(ax, mid - TICK_H), Vector2(ax, mid + TICK_H), UiTokens.INK_DIM, UiTokens.BORDER_HAIRLINE)
		# The customer's numbers; the one on the table now is the dark one.
		var counters: Array = ins.counters
		for i in counters.size():
			var cx := _x_of(counters[i])
			draw_line(Vector2(cx, mid - MARK_H), Vector2(cx, mid + MARK_H),
				UiTokens.INK if i == counters.size() - 1 else UiTokens.INK_DIM, UiTokens.BORDER_HAIRLINE)
		# The handle's left edge is clamped, not its centre, so at the band's floor it still draws
		# whole rather than as a sliver.
		var hx := clampf(_x_of(ins.selected) - HANDLE.x * 0.5, 0.0, maxf(size.x - HANDLE.x, 0.0))
		var handle := Rect2(hx, mid - HANDLE.y * 0.5, HANDLE.x, HANDLE.y)
		draw_rect(handle, UiTokens.negative() if ins.insulting else UiTokens.ACCENT)
		draw_rect(handle, UiTokens.negative() if ins.insulting else UiTokens.ACCENT_DEEP, false,
			UiTokens.BORDER_HAIRLINE)


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_S)
	_rail.picked.connect(changed.emit)
	add_child(_rail)

	# The band's ends at the sides, the held price between them.
	var scale_row := HBoxContainer.new()
	var held := HBoxContainer.new()
	held.alignment = BoxContainer.ALIGNMENT_CENTER
	held.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	held.add_theme_constant_override("separation", UiTokens.SPACE_S)
	for caption: Label in [_low, _price_label, _high]:
		caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	held.add_child(_price_label)
	held.add_child(_price)
	scale_row.add_child(_low)
	scale_row.add_child(held)
	scale_row.add_child(_high)
	add_child(scale_row)

	_deal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_deal)
	add_child(_capacity)


## `instrument`: NegotiationSystem.view_state() with the adapter's `price_label`, `locked_reason`
## and `deal` (the MRR line, then the capacity line).
func show_instrument(instrument: Dictionary) -> void:
	_rail.ins = instrument
	_rail.tooltip_text = instrument.locked_reason
	_rail.queue_redraw()
	_low.text = Fmt.money_exact(instrument.band.low)
	_high.text = Fmt.money_exact(instrument.band.high)
	_price_label.text = instrument.price_label
	_price.text = Fmt.money_exact(instrument.selected)
	_deal.text = instrument.deal[0]
	_capacity.text = instrument.deal[1]
