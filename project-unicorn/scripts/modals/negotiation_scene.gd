class_name NegotiationScene
extends Control

# ACT 2's SURFACE (§5.3). A humble view over NegotiationSystem — every number lives there and
# this paints one view_state through `_render()`.
#
# THERE IS NOT ONE LINE OF SPEECH ON THIS SCREEN, and that is the sealed ruling (§5.3.1). No
# customer remark, no founder reply, no caption that narrates. A corporate negotiation is not
# banter across a desk, so the scene says it with a ruler, numbers the customer writes onto
# it, boxes that go out, and a button that changes TONE when the price crosses into insult.
# Every telegraph here is a VISUAL STATE.
#
# THE RESERVE IS NEVER DRAWN. The counter-offers are what reveal where it is, turn by turn —
# that is the whole information game, and a visible line would delete it.
#
# THE RULER IS `_draw`, NOT A THEME ITEM. It needs three zones, an anchor tick, a trail of
# counter marks and a handle; a stylebox cannot express any of that, and adding textures for
# it would mean new theme items and a THEME_STAMP bump for one surface. `ValueSlider` set the
# precedent for exactly this reason and its geometry is the ancestor of the constants below.
# Colours and sizes still come from tokens — `_draw` changes the drawing path, not the
# palette law (UI/STYLE LAW md.1).

signal closed()

const PAGE_MARGIN := 48
const COLUMN_W := 720
const RULER_H := 64.0
const RAIL_H := 3.0
const HANDLE_W := 12.0
const HANDLE_H := 22.0
const TICK_H := 10.0
const PATIENCE_BOX := Vector2(18, 18)

var _ruler: _Ruler = null
var _patience_row: HBoxContainer = null
var _offer_btn: Button = null
var _accept_btn: Button = null
var _walk_btn: Button = null
var _confirm_box: VBoxContainer = null
var _counter_label: Label = null
var _title_label: Label = null
var _scale_row: HBoxContainer = null
var _vs: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_render(NegotiationSystem.view_state())


# ============================================================================
#  The ruler — one `_draw` Control (§5.3's "cetvel")
# ============================================================================

class _Ruler extends Control:
	signal picked(value: int)

	var band_low: int = 0
	var band_high: int = 100
	var selected: int = 0
	var anchor: int = 0
	var locked_from: int = -1
	var insult_from: int = 999999
	var counters: Array = []
	var interactive: bool = true

	func _init() -> void:
		custom_minimum_size = Vector2(0, NegotiationScene.RULER_H)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _value_at(x: float) -> int:
		var t: float = clampf(x / maxf(size.x, 1.0), 0.0, 1.0)
		return int(round(lerpf(float(band_low), float(band_high), t)))

	func _x_of(value: int) -> float:
		var span: float = float(maxi(band_high - band_low, 1))
		return clampf((float(value - band_low) / span) * size.x, 0.0, size.x)

	func _gui_input(event: InputEvent) -> void:
		if not interactive:
			return
		var press := event as InputEventMouseButton
		if press != null and press.pressed and press.button_index == MOUSE_BUTTON_LEFT:
			picked.emit(_value_at(press.position.x))
			return
		var drag := event as InputEventMouseMotion
		if drag != null and (drag.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			picked.emit(_value_at(drag.position.x))

	func _draw() -> void:
		var mid: float = size.y * 0.5
		# The rail.
		draw_rect(Rect2(0.0, mid - NegotiationScene.RAIL_H * 0.5, size.x, NegotiationScene.RAIL_H),
			UiTokens.SEPARATOR)
		# DESIGN-PARKED: the insult zone is DRAWN. §5.3 seals that the reserve is never
		# drawn and says the zone carries "farklı ton"; a tone on the button alone would
		# let the player cross the line without ever having seen it, and I3 forbids an
		# untelegraphed loss. Alternative seen: button tone only, zone invisible.
		# §5.3 — the INSULT ZONE at the top end, in a different tone. It is drawn because the
		# player must be able to see the edge before stepping over it (I3: no untelegraphed loss).
		if insult_from < band_high:
			var ix: float = _x_of(insult_from)
			draw_rect(Rect2(ix, mid - NegotiationScene.RAIL_H * 0.5, size.x - ix,
				NegotiationScene.RAIL_H), UiTokens.negative_rule())
		# §5.3 / §6 — the promise-narrowed LOCKED zone. Hatched rather than tinted so it does
		# not read as "danger"; it is unavailable, which is a different fact.
		if locked_from >= 0:
			var lx: float = _x_of(locked_from)
			var step: float = 6.0
			var x: float = lx
			while x < size.x:
				draw_line(Vector2(x, mid - 8.0), Vector2(x + 4.0, mid + 8.0),
					UiTokens.INK_FAINT, 1.0)
				x += step
		# The stance anchor (§7.5) — where the dial says this conversation starts.
		var ax: float = _x_of(anchor)
		draw_line(Vector2(ax, mid - NegotiationScene.TICK_H), Vector2(ax, mid + NegotiationScene.TICK_H),
			UiTokens.ACCENT_DIM, 1.0)
		# The counter trail: every number the customer has written, oldest faintest.
		for i in counters.size():
			var cx: float = _x_of(int(counters[i]))
			var fade: float = 0.35 + 0.65 * (float(i + 1) / float(counters.size()))
			var col: Color = UiTokens.INK_MUTED
			col.a = fade
			draw_line(Vector2(cx, mid - 6.0), Vector2(cx, mid + 6.0), col, 1.0)
		# The handle.
		var hx: float = _x_of(selected)
		var hcol: Color = UiTokens.negative_bright() if selected >= insult_from else UiTokens.ACCENT
		draw_rect(Rect2(hx - NegotiationScene.HANDLE_W * 0.5, mid - NegotiationScene.HANDLE_H * 0.5,
			NegotiationScene.HANDLE_W, NegotiationScene.HANDLE_H), hcol)


# ============================================================================
#  Build
# ============================================================================

func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UiTokens.DIALOGUE_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		root.add_theme_constant_override("margin_" + side, PAGE_MARGIN)
	add_child(root)

	# A CENTRED COLUMN. The ruler is the one thing on this screen that wants width, and a
	# 1900px ruler is not a ruler — a dollar of price becomes twenty pixels of travel and the
	# insult edge stops being a place you can see yourself approaching.
	var centre := HBoxContainer.new()
	centre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(centre)
	centre.add_child(_grow())

	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(COLUMN_W, 0)
	col.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	centre.add_child(col)
	centre.add_child(_grow())

	_title_label = UiFactory.make_label("", &"DialogueName")
	col.add_child(_title_label)

	_ruler = _Ruler.new()
	_ruler.picked.connect(_on_picked)
	col.add_child(_ruler)

	_scale_row = HBoxContainer.new()
	col.add_child(_scale_row)

	# The customer's number and the patience track share a row: both are what the OTHER side
	# of the table has said so far, and reading them together is how the player infers the
	# reserve the scene never draws.
	var state_row := HBoxContainer.new()
	state_row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(state_row)
	_patience_row = HBoxContainer.new()
	_patience_row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	state_row.add_child(_patience_row)
	state_row.add_child(_grow())
	_counter_label = UiFactory.make_label("", &"DialogueNumber", UiTokens.ACCENT)
	state_row.add_child(_counter_label)

	_confirm_box = VBoxContainer.new()
	_confirm_box.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(_confirm_box)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(actions)

	_offer_btn = _button(tr("NEG_OFFER"), _on_offer, &"CommitButton")
	_accept_btn = _button(tr("NEG_ACCEPT"), _on_accept, &"DialogueChoice")
	_walk_btn = _button(tr("NEG_WALK"), _on_walk, &"DialogueGhost")
	actions.add_child(_offer_btn)
	actions.add_child(_accept_btn)
	actions.add_child(_walk_btn)


func _grow() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _button(text: String, cb: Callable, variation: StringName) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	return b


# ============================================================================
#  Render
# ============================================================================

func _render(vs: Dictionary) -> void:
	_vs = vs
	var band: Dictionary = vs.get("band", {}) as Dictionary
	_title_label.text = tr(String(vs.get("title_key", "")))

	_ruler.band_low = int(band.get("low", 0))
	_ruler.band_high = int(band.get("high", 100))
	_ruler.selected = int(vs.get("selected", 0))
	_ruler.anchor = int((vs.get("confirm", {}) as Dictionary).get("unit_price", 0))
	_ruler.locked_from = int(vs.get("locked_from", -1))
	_ruler.insult_from = int(vs.get("insult_from", 999999))
	_ruler.counters = (vs.get("counters", []) as Array).duplicate()
	_ruler.interactive = bool(vs.get("can_offer", false))
	_ruler.queue_redraw()

	# The customer's last number, on its own line. No sentence around it — §5.3.1.
	var counter: int = int(vs.get("counter", -1))
	_counter_label.text = "" if counter < 0 else \
		tr("NEG_COUNTER").format({"price": Fmt.money_exact(counter)})

	_render_scale(vs)
	_render_patience(vs.get("patience", {}) as Dictionary)
	_render_confirm(vs)
	_render_actions(vs)


func _render_scale(vs: Dictionary) -> void:
	var row: HBoxContainer = _scale_row
	for c in row.get_children():
		c.queue_free()
	var band: Dictionary = vs.get("band", {}) as Dictionary
	row.add_child(UiFactory.make_label(Fmt.money_exact(int(band.get("low", 0))),
		&"MicroLabel", UiTokens.INK_DIM))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	row.add_child(UiFactory.make_label(
		tr(String(vs.get("price_label_key", ""))) + "  " + Fmt.money_exact(int(vs.get("selected", 0))),
		&"MetricValueInk"))
	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer2)
	row.add_child(UiFactory.make_label(Fmt.money_exact(int(band.get("high", 0))),
		&"MicroLabel", UiTokens.INK_DIM))


## §5.3 — "her karşı-teklif turu bir kutu söndürür; son kutu vurgulu görünür". The highlight
## IS the last-offer telegraph, and it is visual: no line says "this is your last chance".
func _render_patience(p: Dictionary) -> void:
	for c in _patience_row.get_children():
		c.queue_free()
	var current: int = int(p.get("current", 0))
	var total: int = int(p.get("max", 0))
	_patience_row.add_child(UiFactory.make_label(tr("NEG_PATIENCE"), &"MicroLabel", UiTokens.INK_DIM))
	for i in total:
		var box := Panel.new()
		box.custom_minimum_size = PATIENCE_BOX
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := StyleBoxFlat.new()
		# LIT = still available. A spent box is hollow and dim; the LAST remaining one is the
		# §5.3 last-offer telegraph and it is the only box that ever takes the warning colour.
		var lit: bool = i < current
		var last_lit: bool = lit and current == 1
		sb.bg_color = UiTokens.ACCENT_DIM if lit else Color(0, 0, 0, 0)
		if last_lit:
			sb.bg_color = UiTokens.negative_bright()
		sb.border_color = UiTokens.BORDER_DISABLED if not lit else (
			UiTokens.negative_bright() if last_lit else UiTokens.ACCENT)
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		box.add_theme_stylebox_override("panel", sb)
		_patience_row.add_child(box)


## §5.3 — the confirmation strip: seats x price = MRR, plus the CAPACITY reading whose owner
## is Ürün §10. No decision sentence, no remark: the strip is the last thing the player reads
## and it is arithmetic.
func _render_confirm(vs: Dictionary) -> void:
	for c in _confirm_box.get_children():
		c.queue_free()
	var cf: Dictionary = vs.get("confirm", {}) as Dictionary
	_confirm_box.add_child(UiFactory.make_label(tr("NEG_CONFIRM_LINE").format({
		"units": int(cf.get("units", 0)),
		"unit_label": tr(String(vs.get("units_label_key", ""))),
		"price": Fmt.money_exact(int(cf.get("unit_price", 0))),
		"mrr": Fmt.money_exact(int(cf.get("mrr", 0))),
	}), &"MetricValueInk"))
	_confirm_box.add_child(UiFactory.make_label(tr("NEG_CAPACITY").format({
		"used": Fmt.group(int(cf.get("capacity_used", 0))),
		"cap": Fmt.group(int(cf.get("capacity_total", 0))),
	}), &"RowMeta", UiTokens.INK_DIM))


func _render_actions(vs: Dictionary) -> void:
	var closed_now: bool = String(vs.get("state", "")) == "closed" \
		or String(vs.get("state", "")) == "accepted"
	_accept_btn.visible = bool(vs.get("can_accept", false)) and not closed_now
	_walk_btn.visible = bool(vs.get("can_walk", false)) and not closed_now
	_offer_btn.visible = not closed_now
	if closed_now:
		# Accepted → the strip above is the deal; one button signs it. Closed any other way
		# and the same button simply leaves.
		_offer_btn.visible = true
		_offer_btn.text = tr("NEG_SIGN") if String(vs.get("state", "")) == "accepted" else tr("NEG_LEAVE")
		_offer_btn.theme_type_variation = &"CommitButton"
		_offer_btn.tooltip_text = ""
		return
	# §5.3 — "seçili fiyat bölgedeyken Teklif butonu UYARI TONUNA döner ve hover nedeni
	# yazar". The state IS the telegraph; nothing speaks.
	# §12 — past the last box the table has ONE live option and the button says so rather
	# than sitting there inert. The patience row already highlighted the final box; this is
	# the same telegraph reaching the place the player is about to press.
	if bool(vs.get("last_offer", false)):
		_offer_btn.text = tr("NEG_LAST_OFFER")
		_offer_btn.theme_type_variation = &"ChromeAlert"
		_offer_btn.tooltip_text = tr("NEG_LAST_OFFER_REASON")
		return
	var insulting: bool = bool(vs.get("insulting", false))
	_offer_btn.text = tr("NEG_OFFER")
	_offer_btn.theme_type_variation = &"ChromeAlert" if insulting else &"CommitButton"
	_offer_btn.tooltip_text = tr(String(vs.get("insult_reason_key", ""))) if insulting else ""
	if int(vs.get("locked_from", -1)) >= 0:
		_ruler.tooltip_text = tr(String(vs.get("locked_reason_key", "")))


# ============================================================================
#  Routing
# ============================================================================

func _on_picked(value: int) -> void:
	_render(NegotiationSystem.select_price(value))


## One button, three jobs, and the STATE decides which — "Teklif et" while the table is live,
## "İmzala" once a price is agreed, "Kapat" once it is over. A second button for each would
## make the strip a form; this keeps the last press where the player's eye already is.
func _on_offer() -> void:
	var state: String = String(_vs.get("state", ""))
	if state == "accepted" or state == "closed":
		_finish()
		return
	_render(NegotiationSystem.offer())
	# An insulted table is over the moment the button was pressed (§5.3): no confirmation
	# strip, no second chance — the decision was the press.
	if String(_vs.get("state", "")) == "closed":
		_finish()


func _on_accept() -> void:
	_render(NegotiationSystem.accept_counter())


func _on_walk() -> void:
	_render(NegotiationSystem.walk())
	_finish()


## THE SIGNATURE. It is the one place the negotiation's return contract is turned into world
## state, and it goes through the seams that own each half: SalesSystem for the customer,
## PromiseRegistry for the word given in Act 1, SalesFaucetSystem for a lock.
func _finish() -> void:
	SalesFinalizer.apply(NegotiationSystem.result())
	closed.emit()
