class_name NegotiationSystem
extends RefCounted

# ACT 2 — NEGOTIATION (§5.3). Pure static logic under a humble scene, the TermSheetTableSystem
# shape: every number lives here, the scene paints one view_state() and routes clicks back.
#
# ACT 2 IS DIALOGUE-FREE, AND THAT IS THE POINT (§5.3.1, MÜHÜRLÜ). There is not one line of
# speech in this file or in its scene. A corporate negotiation is not banter across a desk;
# the scene says it with numbers and states — a ruler, a hidden reserve the counters reveal,
# patience boxes, and a button that changes TONE when the price crosses into insult. The
# telegraph is a visual state, never a remark.
#
# ONE ENGINE, TWO CALLERS (§5.3, §15). `open(type, context)` implements the engine's §9.4
# contract verbatim and returns `{outcome_id, values, effects_to_apply}`. `type` is
# "b2b_deal" today and "series_a" when the endgame calls it: seats become equity and price
# becomes valuation, the LABELS swap, and not one mechanic changes. Building a second
# negotiation later would give the player two grammars for one idea, and the endgame is
# supposed to reuse the grammar they learned selling.
#
# THE RESERVE IS NEVER DRAWN (§5.3). Counter-offer numbers are what reveal the limit, turn by
# turn. That is the whole information game and a visible reserve would delete it.

const TYPE_B2B := "b2b_deal"
const TYPE_SERIES_A := "series_a"

const OUTCOME_SIGNED := "signed"
const OUTCOME_WALKED := "walked"
const OUTCOME_INSULTED := "insulted"

const STATE_OFFERING := "offering"
const STATE_COUNTERED := "countered"
const STATE_ACCEPTED := "accepted"
const STATE_CLOSED := "closed"

# --- Sitting state. NEVER SERIALISED — can_save() refuses while is_active(). ---
static var _active: bool = false
static var _type: String = TYPE_B2B
static var _context: Dictionary = {}
static var _units: int = 0                  # seats (b2b) / equity points (series_a)
static var _band_low: int = 0
static var _band_high: int = 0
static var _locked_from: int = -1           # promise-narrowed top end; -1 = no locked zone
static var _reserve: int = 0                # HIDDEN
static var _insult_from: int = 0
static var _patience: int = 0
static var _patience_max: int = 0
static var _selected: int = 0
static var _counter: int = -1               # the customer's last number, drawn on the ruler
static var _counters: Array = []            # every number seen, so the ruler keeps the trail
static var _state: String = STATE_OFFERING
static var _result: Dictionary = {}


static func is_active() -> bool:
	return _active


static func reset() -> void:
	_active = false
	_type = TYPE_B2B
	_context = {}
	_units = 0
	_band_low = 0
	_band_high = 0
	_locked_from = -1
	_reserve = 0
	_insult_from = 0
	_patience = 0
	_patience_max = 0
	_selected = 0
	_counter = -1
	_counters = []
	_state = STATE_OFFERING
	_result = {}


# ============================================================================
#  §5.3 · The contract
# ============================================================================

## THE ENTRY POINT the engine's §9.4 effect names. `context` for a b2b deal carries:
##   account          the company name (the memory key)
##   lead_id          the prospect id, so the signature can convert it
##   star             1..3, which picks the seat band
##   archetype        the §11.1 id — reserve sensitivity, patience, insult margin
##   promised         "" or the feature id promised in Act 1 (narrows the band, §6)
##   is_whale         plays the negotiation hard (§8)
## Returns the opening view_state; the OUTCOME is read from `result()` once the table closes.
static func open(negotiation_type: String, context: Dictionary) -> Dictionary:
	reset()
	_active = true
	_type = negotiation_type
	_context = context.duplicate(true)
	var lead_id: String = String(context.get("lead_id", ""))

	var star: int = clampi(int(context.get("star", 1)), SalesConstants.STAR_MIN, SalesConstants.STAR_MAX)
	var archetype: String = String(context.get("archetype", SalesArchetypes.DEFAULT_ID))
	var profile: Dictionary = SalesArchetypes.negotiation(archetype)

	# Seats are NOT negotiated (§5.3): the need comes from the star band. One axis only.
	var seats: Dictionary = SalesConstants.seat_band(star)
	_units = int(context.get("units", 0))
	if _units <= 0:
		_units = int(lerpf(float(seats["low"]), float(seats["high"]),
			SalesConstants.mix_unit(lead_id, SalesConstants.SALT_UNITS)))

	# The ruler. The stance dial (§7.5) places the anchor; the band is the calibration span
	# around it, so moving the dial visibly moves where the whole conversation starts.
	var anchor: int = int(context.get("anchor", SalesLedger.seat_price_anchor()))
	_band_low = SalesConstants.SEAT_PRICE_MIN
	_band_high = SalesConstants.SEAT_PRICE_MAX
	_selected = clampi(anchor, _band_low, _band_high)

	# §5.3 / §6 — a promise narrows the TOP end and the locked zone carries its reason. What
	# was given away in Act 1 cannot also be charged for in Act 2.
	if String(context.get("promised", "")) != "":
		_locked_from = _band_high - int(round(float(_band_high - _band_low)
			* SalesConstants.PROMISE_BAND_NARROW))
		_selected = mini(_selected, _locked_from - 1)

	# The hidden reserve: band anchor × archetype sensitivity × run seed (§5.3).
	var sensitivity: float = clampf(float(profile.get("reserve_sensitivity", 1.0)),
		SalesConstants.RESERVE_SENSITIVITY_MIN, SalesConstants.RESERVE_SENSITIVITY_MAX)
	var jitter: float = 0.94 + 0.12 * SalesConstants.mix_unit(lead_id, SalesConstants.SALT_RESERVE)
	_reserve = clampi(int(round(float(anchor) * sensitivity * jitter)), _band_low, _band_high)
	# §8 — a whale plays hard: its reserve sits lower and its patience is shorter.
	if bool(context.get("is_whale", false)):
		_reserve = maxi(int(round(float(_reserve) * 0.9)), _band_low)

	_insult_from = int(round(float(_reserve) * (1.0
		+ float(profile.get("insult_margin", SalesConstants.INSULT_MARGIN)))))
	_patience_max = clampi(int(profile.get("patience", SalesConstants.PATIENCE_MIN)),
		SalesConstants.PATIENCE_MIN, SalesConstants.PATIENCE_MAX)
	if bool(context.get("is_whale", false)):
		_patience_max = maxi(_patience_max - 1, SalesConstants.PATIENCE_MIN)
	_patience = _patience_max
	return view_state()


## The §9.4 return structure, available once the table has closed. The engine runs
## `effects_to_apply` through its own dictionary with the ORIGIN of the option that opened
## the negotiation, which is what keeps I2 intact across a scene boundary.
static func result() -> Dictionary:
	return _result.duplicate(true)


# ============================================================================
#  Moves
# ============================================================================

static func select_price(value: int) -> Dictionary:
	if not _active:
		return view_state()
	var top: int = _locked_from - 1 if _locked_from >= 0 else _band_high
	_selected = clampi(value, _band_low, top)
	return view_state()


## §5.3 — "hakaret bölgesine bilerek teklif → masa devrilir". The button already showed a
## warning tone with the reason on hover; pressing it anyway is a decision, not an accident.
static func is_insulting() -> bool:
	return _selected >= _insult_from


static func offer() -> Dictionary:
	if not _active:
		return view_state()
	if is_insulting():
		return _close(OUTCOME_INSULTED)
	if _selected <= _reserve:
		return _close(OUTCOME_SIGNED, _selected)
	# §12 — PAST THE LAST BOX the counter on the table is the only live option: accept it or
	# the table closes, and that close is a LOSS on price rather than a neutral walk. Without
	# this the patience track is decoration — the player presses until the reserve falls out.
	if patience_spent():
		return _close(OUTCOME_WALKED, 0, SalesConstants.LOSS_PRICE)
	# A counter. The number walks from the offer toward the reserve by a temperament step, so
	# each round narrows the visible bracket and the reserve is inferred rather than shown.
	var step: float = lerpf(SalesConstants.COUNTER_STEP_MIN, SalesConstants.COUNTER_STEP_MAX,
		float(_patience) / float(_patience_max))
	_counter = maxi(int(round(float(_selected) * (1.0 - step))), _reserve)
	_counters.append(_counter)
	_patience -= 1
	_state = STATE_COUNTERED
	return view_state()


## §5.3 — "Kabul et her an açık, sabır yakmaz." Accepting the customer's number is always a
## live option and never costs a box; that is what stops the patience track from being a
## countdown to nothing.
static func accept_counter() -> Dictionary:
	if not _active or _counter < 0:
		return view_state()
	return _close(OUTCOME_SIGNED, _counter)


## §5.3 — walking is NEUTRAL. A 30-day lock, and no trace on the account.
static func walk() -> Dictionary:
	if not _active:
		return view_state()
	return _close(OUTCOME_WALKED)


## §12 — "Sabır biterse | son karşı-teklif geçerli tek seçenektir: kabul ya da masa kapanır."
static func patience_spent() -> bool:
	return _patience <= 0


## `reason` rides in `values` rather than in a fourth outcome id: §5.3's contract names
## EXACTLY three (signed | walked | insulted) and the engine's §9.4 handler is written against
## those three. A player-initiated walk carries no reason and is traceless (§5.3); a table that
## ran out of patience carries "price" and the applier writes it to the account's memory.
static func _close(outcome: String, price: int = 0, reason: String = "") -> Dictionary:
	_state = STATE_CLOSED if outcome != OUTCOME_SIGNED else STATE_ACCEPTED
	var mrr: int = _units * price
	_result = {
		"outcome_id": outcome,
		"values": {"units": _units, "unit_price": price, "mrr": mrr, "reason": reason},
		"effects_to_apply": [],
		"context": _context.duplicate(true),
	}
	if outcome == OUTCOME_SIGNED:
		_result["effects_to_apply"] = [{"verb": "sales_sign", "lead": _context.get("lead_id", ""),
			"units": _units, "unit_price": price}]
	_active = false
	return view_state()


# ============================================================================
#  View — the scene paints this and nothing else
# ============================================================================

static func view_state() -> Dictionary:
	var b2b: bool = _type != TYPE_SERIES_A
	return {
		"state": _state,
		# LABEL KEYS, not sentences: a Series A table says "hisse" and "değerleme" over the
		# same mechanic, and that is the only difference between the two callers.
		"units_label_key": "NEG_UNITS_SEATS" if b2b else "NEG_UNITS_EQUITY",
		"price_label_key": "NEG_PRICE_SEAT" if b2b else "NEG_PRICE_VALUATION",
		"title_key": "NEG_TITLE_B2B" if b2b else "NEG_TITLE_SERIES_A",
		"band": {"low": _band_low, "high": _band_high},
		"selected": _selected,
		"locked_from": _locked_from,
		"locked_reason_key": "NEG_LOCK_PROMISE" if _locked_from >= 0 else "",
		"insult_from": _insult_from,
		"insulting": is_insulting(),
		"insult_reason_key": "NEG_INSULT_REASON",
		"counter": _counter,
		"counters": _counters.duplicate(),
		"patience": {"current": _patience, "max": _patience_max},
		"can_offer": _active and not patience_spent(),
		"last_offer": patience_spent() and _counter >= 0,
		"can_accept": _active and _counter >= 0,
		"can_walk": _active,
		"confirm": {
			"units": _units,
			"unit_price": _pending_price(),
			"mrr": _units * _pending_price(),
			# §5.3 — the confirmation strip carries the CAPACITY reading, whose owner is
			# Ürün §10. Seats signed here land in that same count the same day.
			"capacity_used": InfraSystem.served_count() + _units,
			"capacity_total": int(round(InfraSystem.effective_capacity())),
		},
	}


static func _pending_price() -> int:
	if _state == STATE_ACCEPTED:
		return int((_result.get("values", {}) as Dictionary).get("unit_price", 0))
	return _counter if _counter >= 0 and _counter < _selected else _selected

