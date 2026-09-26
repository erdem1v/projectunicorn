class_name EvTempo
extends RefCounted

# THE FOUR-LAYER BRAKE (GDD §13). The problem was never the NUMBER of cards, it was the
# SAMENESS: three cards about one account in a week reads as a bug. Every layer aims at that.
#
#   Layer 1  the same CARD          min_gap_days, default 30
#   Layer 2  the same SUBJECT       employees 14 days, customers 30 — POOL CARDS ONLY
#   Layer 3  the same CATEGORY      a quota over a rolling 7 days
#   Layer 4  the daily ceiling      2 interrupts; the third becomes paper
#
# I4: NOTHING IS EVER DROPPED (§13.2). A card over budget falls interrupt → paper and stops.
# Never to ambient: the ticker is lossy, so that would keep the letter of I4 and lose its point.
# Paper is a safe floor because every paper has an expiry (§12.1), which is why R8a requires
# the paper trio on any interrupt that CAN be demoted.
#
# THE ORDER OF DEMOTION: §4.1 would demote the third card to ARRIVE, and arrival order is
# meaningless. The day's admissions are collected and charged top-down by §11.2 priority, so
# the least important card is the one demoted.
#
# §13.5: critical tags, terminal telegraphs, arc steps and a paper's last-day warning recognise
# no budget at all — an arc that could be throttled could miss its own payoff.
#
# Every number is in EvTuning and none of them is measured (§13.8).

## Rolling window of admissions: [{day, event_id, category, subject, class}]
static var _window: Array = []


# --- The daily assignment --------------------------------------------------

## Assign a presentation class to each of today's admissions. Returns [{event_id, class}].
##
## `admissions` arrives in arrival order and is re-sorted by §11.2 priority before anything is
## charged, so the demotion falls on the least important card rather than the last one.
static func assign(admissions: Array) -> Array:
	_prune()
	var ranked: Array = admissions.duplicate()
	ranked.sort_custom(_more_important)

	var interrupts_today: int = _interrupts_on(GameState.day)
	var ceiling: int = _ceiling()
	var out: Array = []

	for a in ranked:
		var entry: Dictionary = a
		var event_id: String = String(entry["event_id"])
		var card: Dictionary = EvCatalog.card(event_id)
		var declared: String = String(card["class"])
		var final_class: String = declared

		if budget_exempt(card):
			# §13.5: recognises no budget and is not counted against one either.
			out.append({"event_id": event_id, "class": declared, "exempt": true})
			_record(event_id, card, declared)
			continue

		if declared == "interrupt":
			if interrupts_today >= ceiling:
				# I4: demoted, never dropped. It keeps its clock and the player still has to
				# answer it — just not right now, and not by being interrupted.
				final_class = "paper"
			else:
				interrupts_today += 1

		out.append({"event_id": event_id, "class": final_class,
			"demoted": final_class != declared})
		_record(event_id, card, final_class)
	return out


## §11.2's order, as a comparator. Terminal first, then a paper about to lapse, then critical,
## then the class ladder. Ties break by id — deterministic and deliberately NOT seeded.
static func _more_important(a: Dictionary, b: Dictionary) -> bool:
	var ra: int = _rank(String(a["event_id"]))
	var rb: int = _rank(String(b["event_id"]))
	if ra != rb:
		return ra < rb
	return String(a["event_id"]) < String(b["event_id"])


static func _rank(event_id: String) -> int:
	var card: Dictionary = EvCatalog.card(event_id)
	var tags: Array = card.get("tags", [])
	if tags.has("terminal_warning"):
		return 0
	if EvPapers.is_expiring_soon(event_id):
		return 1
	if tags.has("critical"):
		return 2
	return 3 + maxi(0, EvQueue.PRIORITY.find(String(card.get("class", "ambient"))))


## §13.5 — what the day's interrupt budget does NOT govern. Public because lint's R8a asks the
## same question (a card exempt here can never be demoted, so needs no paper trio).
static func budget_exempt(card: Dictionary) -> bool:
	var tags: Array = card.get("tags", [])
	return tags.has("critical") or tags.has("terminal_warning") or card.has("arc")


# --- The gate's question: may this card be admitted at all? ----------------

## "" when the pool brakes allow it. Layers 1-3 live here; layer 4 is a class change, not a
## refusal, and belongs in assign().
##
## Critical cards and arc steps never reach this — G8 does not run for them (§13.5).
static func pool_blocked_reason(card: Dictionary, subject_id: String) -> String:
	if budget_exempt(card):
		return ""
	_prune()

	# Layer 1 — the same card. The latch handles once-ever; this handles how soon again.
	var gap: int = int(card.get("min_gap_days", EvTuning.MIN_GAP_DAYS_DEFAULT))
	var last: int = _last_day_of(String(card["id"]))
	if last >= 0 and GameState.day - last < gap:
		return "layer 1: this card fired %d day(s) ago, min_gap is %d" % [GameState.day - last, gap]

	# Layer 2 — the same subject. Pool cards only: an arc may fire card after card about one
	# employee, because that is what an arc IS — so exempt cards neither check nor record it.
	if subject_id != "":
		var subject_gap: int = _subject_gap_for(card)
		var last_subject: int = _last_day_about(subject_id)
		if last_subject >= 0 and GameState.day - last_subject < subject_gap:
			return "layer 2: a pool card was about this subject %d day(s) ago, gap is %d" \
				% [GameState.day - last_subject, subject_gap]

	# Layer 3 — the category quota over a rolling 7 days. The side benefit is the real one:
	# a full quota forces the engine to look at another category, so the player's week is
	# never one colour.
	var category: String = String(card["category"])
	var used: int = _category_count(category)
	var quota: int = _quota_for(category)
	if used >= quota:
		return "layer 3: category '%s' is at %d of %d this week" % [category, used, quota]

	return ""


static func _subject_gap_for(card: Dictionary) -> int:
	for slot in (card.get("scope", {}) as Dictionary):
		var t: String = String((card["scope"] as Dictionary)[slot].get("type", ""))
		if t == EvScope.TYPE_CUSTOMER:
			return EvTuning.SUBJECT_GAP_CUSTOMER_DAYS
	return EvTuning.SUBJECT_GAP_EMPLOYEE_DAYS


## §13.4: the phase multiplier applies to layers 3 and 4 only. Layers 1 and 2 are FIXED,
## because repetition is bad in every phase and no amount of late-game pressure makes the same
## card twice in a week good.
static func _quota_for(category: String) -> int:
	var base: int = int(EvTuning.CATEGORY_QUOTA_7D.get(category, EvTuning.CATEGORY_QUOTA_DEFAULT))
	return int(round(float(base) * _phase_multiplier()))


static func _ceiling() -> int:
	return int(round(float(EvTuning.MAX_INTERRUPTS_PER_DAY) * _phase_multiplier()))


static func _phase_multiplier() -> float:
	return float(EvTuning.PHASE_MULTIPLIER.get(GameState.phase, 1.0))


# --- The rolling window ----------------------------------------------------

static func _record(event_id: String, card: Dictionary, final_class: String) -> void:
	_window.append({
		"day": GameState.day,
		"event_id": event_id,
		"category": String(card["category"]),
		"subject": "",
		"class": final_class,
	})


static func _prune() -> void:
	# 30 days rather than 7: layer 2's customer gap needs that much history, and the window is
	# a few dozen dictionaries at most.
	var cutoff: int = GameState.day - 30
	_window = _window.filter(func(e): return int(e["day"]) >= cutoff)


static func _category_count(category: String) -> int:
	var n: int = 0
	var cutoff: int = GameState.day - 7
	for e in _window:
		if int((e as Dictionary)["day"]) >= cutoff and String((e as Dictionary)["category"]) == category:
			n += 1
	return n


static func _interrupts_on(day: int) -> int:
	var n: int = 0
	for e in _window:
		if int((e as Dictionary)["day"]) == day and String((e as Dictionary)["class"]) == "interrupt":
			n += 1
	return n


static func _last_day_of(event_id: String) -> int:
	var last: int = -1
	for e in _window:
		if String((e as Dictionary)["event_id"]) == event_id:
			last = maxi(last, int((e as Dictionary)["day"]))
	return last


static func _last_day_about(subject_id: String) -> int:
	var last: int = -1
	for e in _window:
		if String((e as Dictionary)["subject"]) == subject_id:
			last = maxi(last, int((e as Dictionary)["day"]))
	return last


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_window.clear()


static func to_dict() -> Dictionary:
	return {"tempo_window": _window.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	_window = (d.get("tempo_window", []) as Array).duplicate(true)
