class_name EvTempo
extends RefCounted

# THE FOUR-LAYER BRAKE (GDD §13). The problem was never the NUMBER of cards, it was the
# SAMENESS: three cards about one account in a week reads as a bug. Every layer aims at that.
#
#   Layer 1   the same CARD         min_gap_weeks, default in EvTuning
#   Layer 1b  the same FAMILY       a gap per family — every origin but an arc and a request
#   Layer 2   the same SUBJECT      a gap per subject type — POOL CARDS ONLY
#   Layer 2b  the family × SUBJECT  once ever, or a cooldown, per person
#   Layer 3   the same CATEGORY     a quota per week (tick)
#   Layer 4   the per-tick ceiling  interrupts over it become paper
#
# I4: NOTHING IS EVER DROPPED (§13.2). A card over budget falls interrupt → paper and stops.
# Never to ambient: the ticker is lossy, so that would keep the letter of I4 and lose its point.
# Paper is a safe floor because every paper has an expiry (§12.1), which is why R8a requires
# the paper trio on any interrupt that CAN be demoted.
#
# THE ORDER OF DEMOTION: §4.1 would demote the third card to ARRIVE, and arrival order is
# meaningless. The tick's admissions are collected and charged top-down by §11.2 priority, so
# the least important card is the one demoted.
#
# §13.5: critical tags, terminal telegraphs, arc steps and a paper's last warning recognise
# no budget at all — an arc that could be throttled could miss its own payoff.
#
# Every number is in EvTuning and none of them is measured (§13.8).

## Rolling window of admissions: [{day (tick), event_id, category, subject, class}]
static var _window: Array = []

## family -> {day, event_id} of its last fire. Kept apart from the window and NOT pruned: the
## widest family gap outruns the window's cutoff, and layer 2b's `once` has to remember a whole
## run. One entry per family, one per family × subject — a few dozen numbers.
static var _family_days: Dictionary = {}
## "family|subject_id" -> the tick that family last fired about that subject.
static var _family_subject_days: Dictionary = {}


# --- The per-tick assignment -----------------------------------------------

## Assign a presentation class to each of this tick's admissions ({event_id, context}). Returns
## [{event_id, key, class}], keyed by EvLatches.key_of.
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
		var key: String = EvLatches.key_of_entry(entry)
		var card: Dictionary = EvCatalog.card(event_id)
		var declared: String = String(card["class"])
		var final_class: String = declared

		if EvPapers.has(key) and EvQueue.holds(key):
			# §13.5: a paper's last warning, re-queued as an interrupt. It recognises no
			# budget, and it is the same paper, so it is not recorded a second time either.
			out.append({"event_id": event_id, "key": key, "class": "interrupt", "exempt": true})
			continue

		if budget_exempt(card):
			# §13.5: recognises no budget and is not counted against one either.
			out.append({"event_id": event_id, "key": key, "class": declared, "exempt": true})
			_record(event_id, card, declared, "")
			continue

		if declared == "interrupt":
			if interrupts_today >= ceiling:
				# I4: demoted, never dropped. It keeps its clock and the player still has to
				# answer it — just not right now, and not by being interrupted.
				final_class = "paper"
			else:
				interrupts_today += 1

		out.append({"event_id": event_id, "key": key, "class": final_class,
			"demoted": final_class != declared})
		_record(event_id, card, final_class, EvGate.subject_of(entry["context"]))
	return out


## §11.2's order, as a comparator. Terminal first, then a paper about to lapse, then critical,
## then the class ladder. Ties break by id, then by instance — deterministic and deliberately
## NOT seeded.
static func _more_important(a: Dictionary, b: Dictionary) -> bool:
	var ra: int = _rank(a)
	var rb: int = _rank(b)
	if ra != rb:
		return ra < rb
	var ia: String = String(a["event_id"])
	var ib: String = String(b["event_id"])
	return EvLatches.key_of_entry(a) < EvLatches.key_of_entry(b) if ia == ib else ia < ib


static func _rank(entry: Dictionary) -> int:
	var event_id: String = String(entry["event_id"])
	return EvQueue.rank(event_id, EvLatches.key_of_entry(entry), String(EvCatalog.card(event_id)["class"]))


## §13.5 — what the tick's interrupt budget does NOT govern. Public because lint's R8a asks the
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
	var brake: Dictionary = family_brake(card, subject_id)
	if not brake.is_empty():
		return String(brake["reason"])
	if budget_exempt(card):
		return ""
	_prune()

	# Layer 1 — the same card. The latch handles once-ever; this handles how soon again.
	var gap: int = TimeModel.ticks(int(card.get("min_gap_weeks", EvTuning.MIN_GAP_WEEKS_DEFAULT)))
	var last: int = _last_day_of(String(card["id"]))
	if last >= 0 and GameState.day - last < gap:
		return "layer 1: this card fired %d week(s) ago, min_gap is %d" % [GameState.day - last, gap]

	# Layer 2 — the same subject. Pool cards only: an arc may fire card after card about one
	# employee, because that is what an arc IS — so exempt cards neither check nor record it.
	if subject_id != "":
		var subject_gap: int = _subject_gap_for(card)
		var last_subject: int = _last_day_about(subject_id)
		if last_subject >= 0 and GameState.day - last_subject < subject_gap:
			return "layer 2: a pool card was about this subject %d week(s) ago, gap is %d" \
				% [GameState.day - last_subject, subject_gap]

	# Layer 3 — the category quota for this week. The side benefit is the real one:
	# a full quota forces the engine to look at another category, so the player's week is
	# never one colour.
	var category: String = String(card["category"])
	var used: int = _category_count(category)
	var quota: int = _quota_for(category)
	if used >= quota:
		return "layer 3: category '%s' is at %d of %d this week" % [category, used, quota]

	return ""


## Layers 1b and 2b, as both an explanation and a wait: {} when the family allows the card,
## else {reason, weeks} where `weeks` is how long the brake has left and -1 means never again.
##
## Asked on its own rather than folded into pool_blocked_reason because the signal, schedule and
## floor origins pay these two layers without paying the pool's three — and because a signal
## that these refuse is re-dated by `weeks` instead of being dropped (EvEngine._deferral_weeks).
##
## The family's rhythm is what the week already felt like, so no card tag buys past it: an arc,
## a request and a force are exempt by ORIGIN — they never ask — and `follows` by layer 1b alone.
static func family_brake(card: Dictionary, subject_id: String) -> Dictionary:
	var family: String = String(card.get("family", ""))
	if family == "":
		return {}

	# Layer 1b — ANOTHER card from this family. Three different cards about an employee asking
	# for money inside a month is one card as far as the week feels. The card's own return is
	# layer 1's business and its latch's, so its own last fire does not brake it. A `follows`
	# card pays this layer alone no brake: a chain node answers to its parent, not to its
	# family's rhythm — and 2b still holds it, because one person is still one person.
	var last: Dictionary = _family_days.get(family, {})
	if not card.has("follows") and not last.is_empty() \
			and String(last["event_id"]) != String(card["id"]):
		var since: int = GameState.day - int(last["day"])
		var gap: int = TimeModel.ticks(EvTuning.family_gap(family))
		if since < gap:
			return {"weeks": gap - since,
				"reason": "layer 1b: family '%s' fired %d week(s) ago, gap is %d"
					% [family, since, gap]}

	# Layer 2b — this family about THIS person. The finding that started all of it: the same
	# employee asked for money twice, and a family may be right twice without being right twice
	# about one person.
	var rule: Dictionary = card.get("family_subject", {})
	if subject_id == "" or rule.is_empty():
		return {}
	var seen: int = int(_family_subject_days.get(family + "|" + subject_id, -1))
	if seen < 0:
		return {}
	if bool(rule.get("once", false)):
		return {"weeks": -1,
			"reason": "layer 2b: family '%s' already happened to this subject in week %d"
				% [family, seen]}
	var since: int = GameState.day - seen
	var cooldown: int = TimeModel.ticks(int(rule.get("cooldown_weeks", 0)))
	if since < cooldown:
		return {"weeks": cooldown - since,
			"reason": "layer 2b: family '%s' was about this subject %d week(s) ago, cooldown is %d"
				% [family, since, cooldown]}
	return {}


static func _subject_gap_for(card: Dictionary) -> int:
	for slot in (card.get("scope", {}) as Dictionary):
		var t: String = String((card["scope"] as Dictionary)[slot].get("type", ""))
		if t == EvScope.TYPE_CUSTOMER:
			return TimeModel.ticks(EvTuning.SUBJECT_GAP_CUSTOMER_WEEKS)
	return TimeModel.ticks(EvTuning.SUBJECT_GAP_EMPLOYEE_WEEKS)


## §13.4: the phase multiplier applies to layers 3 and 4 only. Layers 1 and 2 are FIXED,
## because repetition is bad in every phase and no amount of late-game pressure makes the same
## card twice in a week good.
static func _quota_for(category: String) -> int:
	var base: int = int(EvTuning.CATEGORY_QUOTA_WEEK.get(category, EvTuning.CATEGORY_QUOTA_DEFAULT))
	return int(round(float(base) * _phase_multiplier()))


static func _ceiling() -> int:
	return int(round(float(EvTuning.MAX_INTERRUPTS_PER_DAY) * _phase_multiplier()))


static func _phase_multiplier() -> float:
	return float(EvTuning.PHASE_MULTIPLIER.get(GameState.phase, 1.0))


# --- The rolling window ----------------------------------------------------

static func _record(event_id: String, card: Dictionary, final_class: String, subject: String) -> void:
	_window.append({
		"day": GameState.day,
		"event_id": event_id,
		"category": String(card["category"]),
		"subject": subject,
		"class": final_class,
	})
	var family: String = String(card.get("family", ""))
	if family == "":
		return
	# The firing card's id too: layer 1b asks about ANOTHER card from the family, and without
	# the id a card's own fire would brake its own return a second time.
	_family_days[family] = {"day": GameState.day, "event_id": event_id}
	if subject != "":
		_family_subject_days[family + "|" + subject] = GameState.day


static func _prune() -> void:
	# As far back as the widest gap reads; the window is a few dozen dictionaries at most.
	var cutoff: int = GameState.day - TimeModel.ticks(maxi(EvTuning.MIN_GAP_WEEKS_DEFAULT,
		maxi(EvTuning.SUBJECT_GAP_CUSTOMER_WEEKS, EvTuning.SUBJECT_GAP_EMPLOYEE_WEEKS)))
	_window = _window.filter(func(e): return int(e["day"]) >= cutoff)


## This week's admissions in the category: the quota's window is one tick.
static func _category_count(category: String) -> int:
	var n: int = 0
	for e in _window:
		if int((e as Dictionary)["day"]) == GameState.day and String((e as Dictionary)["category"]) == category:
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
	_family_days.clear()
	_family_subject_days.clear()


static func to_dict() -> Dictionary:
	return {
		"tempo_window": _window.duplicate(true),
		"tempo_families": _family_days.duplicate(true),
		"tempo_family_subjects": _family_subject_days.duplicate(),
	}


static func from_dict(d: Dictionary) -> void:
	_window = (d.get("tempo_window", []) as Array).duplicate(true)
	_family_days = (d.get("tempo_families", {}) as Dictionary).duplicate(true)
	_family_subject_days = (d.get("tempo_family_subjects", {}) as Dictionary).duplicate()
