class_name EvTempo
extends RefCounted

# THE FOUR-LAYER BRAKE (GDD §13).
#
# §13.1's diagnosis is the thing to keep in mind while reading this: **the problem was never
# the NUMBER of cards, it was the SAMENESS.** Five cards about five different things is a
# normal week at a company. Three cards about the same account in one week reads as a bug.
# Every layer below is aimed at that, not at volume.
#
#   Layer 1  the same CARD          min_gap_days, default 30
#   Layer 2  the same SUBJECT       employees 14 days, customers 30 — POOL CARDS ONLY
#   Layer 3  the same CATEGORY      a quota over a rolling 7 days
#   Layer 4  the daily ceiling      2 interrupts; the third becomes paper
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# I4: NOTHING IS EVER DROPPED
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# §13.2. When the budget is spent a card does not disappear — its presentation class falls:
#
#     interrupt → paper → and stops there.
#
# **It never falls to ambient.** That is not in §13.2 and it needs saying, because the ticker
# looks like a natural third rung and is not: `NewsFeedSystem.on_headline_added` drops the
# NEWEST line when its buffer fills (news_feed_system.gd:164-173), by design, because
# autonomous closes produce lines faster than the feed drains. Demoting into a lossy channel
# would satisfy the letter of I4 while destroying its point.
#
# Paper is a safe floor for one reason only: every paper has an expiry (§12.1), so a demoted
# card still forces a resolution. Which is also why R8a exists — an interrupt that CAN be
# demoted must carry the paper trio, or the demotion manufactures a card the linter would
# have rejected.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# THE ORDER OF DEMOTION IS THE POINT
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# §4.1 places the budget check inside `propose()`, which would demote the THIRD CARD TO ARRIVE.
# Arrival order is meaningless — the third proposal of the day might be the arc payoff and the
# first two might be rival news. So the day's admissions are collected and classes assigned
# TOP-DOWN by §11.2 priority: the least important thing is demoted, which is what I4 is for.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# THREE THINGS RECOGNISE NO BUDGET AT ALL (§13.5)
# ─────────────────────────────────────────────────────────────────────────────────────────
#
#   · tag: critical — the spine, arc turning points, phase transitions
#   · terminal telegraphs
#   · a paper's last-day warning
#
# An arc that could be throttled is an arc that can miss its own payoff, and §0.2 dies with it.
#
# EVERY NUMBER HERE IS IN EvTuning AND NONE OF THEM IS MEASURED (§13.8).

## Rolling window of admissions: [{day, category, subject_id, card_class}]
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

		if _budget_exempt(card):
			# §13.5. Not "gets priority" — recognises no budget, and is not counted against
			# one either. An arc turning point does not consume the day's interrupt slots.
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
## then the class ladder. Ties break by admission day and then alphabetically — deterministic,
## and deliberately NOT seeded, so two players in the same state see the same order.
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


## §13.5 — what the day's interrupt budget does NOT govern. PUBLIC because the linter has to
## ask the same question: R8a requires the paper expiry trio on anything that CAN be demoted,
## and a card that is exempt here can never be. Two answers to one question is how a linter
## comes to demand a field for a code path that cannot run.
static func budget_exempt(card: Dictionary) -> bool:
	return _budget_exempt(card)


static func _budget_exempt(card: Dictionary) -> bool:
	var tags: Array = card.get("tags", [])
	return tags.has("critical") or tags.has("terminal_warning") or card.has("arc")


# --- The gate's question: may this card be admitted at all? ----------------

## "" when the pool brakes allow it. Layers 1-3 live here; layer 4 is a class change, not a
## refusal, and belongs in assign().
##
## Critical cards and arc steps never reach this — G8 does not run for them (§13.5).
static func pool_blocked_reason(card: Dictionary, subject_id: String) -> String:
	if _budget_exempt(card):
		return ""
	_prune()

	# Layer 1 — the same card. The latch handles once-ever; this handles how soon again.
	var gap: int = int(card.get("min_gap_days", EvTuning.MIN_GAP_DAYS_DEFAULT))
	var last: int = _last_day_of(String(card["id"]))
	if last >= 0 and GameState.day - last < gap:
		return "layer 1: this card fired %d day(s) ago, min_gap is %d" % [GameState.day - last, gap]

	# Layer 2 — the same subject. THE EXEMPTION IS THE INTERESTING HALF: this applies to pool
	# cards only, so an arc can fire card after card about one employee. That is what an arc IS.
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


## Note the subject separately: it is known at admission, not at class-assignment time.
static func note_subject(event_id: String, subject_id: String) -> void:
	for i in range(_window.size() - 1, -1, -1):
		if String((_window[i] as Dictionary)["event_id"]) == event_id:
			(_window[i] as Dictionary)["subject"] = subject_id
			return


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


# --- Reporting (the harness's anchor, §13.7) -------------------------------

static func window_snapshot() -> Array:
	return _window.duplicate(true)


static func reset() -> void:
	_window.clear()


static func to_dict() -> Dictionary:
	return {"tempo_window": _window.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	_window = (d.get("tempo_window", []) as Array).duplicate(true)
