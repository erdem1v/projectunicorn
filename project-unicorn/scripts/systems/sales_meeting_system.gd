class_name SalesMeetingSystem
extends RefCounted

# ACT 1 — PERSUASION (§5.1, §5.1.1). Pure static logic under a humble scene, the shape
# TermSheetTableSystem proved: all the arithmetic lives here so the headless smoke suite can
# drive a whole meeting with no scene mounted.
#
# THE SITTING IS ATOMIC (§5.0). No save is taken inside it and the world does not turn:
# SaveManager.can_save() refuses while is_active(), which is what makes "meeting-local state
# is reset, never serialised" honest rather than a carve-out. On close the clock jumps two
# hours and those hours are SIMULATED — the same hourly path live play uses, with the founder
# counted busy (§5.0). There is no second catch-up formula, because a second simulation path
# is a divergence factory.
#
# THE CUSTOMER ENDS THE MEETING, NOT A QUOTA (§5.1.1). One needle, two thresholds: over the
# top one the customer cuts and Act 2 opens, under the bottom one the customer cuts and it is
# a loss, in between the probing continues to a safety cap. There is no fixed round count and
# the meeting's SHAPE changes with the star, so it cannot be memorised.
#
# THE DIE IS THE ENGINE'S (§5.1 → engine §9.2/§9.3). It is rolled in exactly one place: when
# the sitting reaches the safety cap or the player skips to the offer with the needle between
# the thresholds. Its key carries the run seed, the day, the lead and THE PATH — so replaying
# the same answers after a reload gives the same result, and only a different (and costlier)
# set of answers moves it. That is the no-dice-fishing law the re-pitch design leans on.

# --- Sitting state. NEVER SERIALISED (see the header) ---
static var _active: bool = false
static var _lead_id: String = ""
static var _facts: Dictionary = {}
static var _used_families: Array = []
static var _probe: Dictionary = {}
static var _probe_index: int = 0
static var _probe_budget: int = 0
static var _needle: float = 0.0
static var _base_contributions: Array = []
static var _answer_contributions: Array = []
static var _path: Array = []
static var _promised_feature: String = ""
static var _inner_voice_shown: bool = false
static var _outcome: String = ""            # "" | "won" | "lost"
static var _loss_reason: String = ""

const EVENT_KIND := "sales_meeting"


static func is_active() -> bool:
	return _active


static func active_lead_id() -> String:
	return _lead_id


## Run-boundary reset (SaveManager.reset_all_owners), and the same doctrine as the other
## sitting-scoped systems: eleven statics cleared, nothing serialised.
static func reset() -> void:
	_active = false
	_lead_id = ""
	_facts = {}
	_used_families = []
	_probe = {}
	_probe_index = 0
	_probe_budget = 0
	_needle = 0.0
	_base_contributions = []
	_answer_contributions = []
	_path = []
	_promised_feature = ""
	_inner_voice_shown = false
	_outcome = ""
	_loss_reason = ""


# ============================================================================
#  Lifecycle
# ============================================================================

## "" when the founder may sit down, else the CSV key naming the refusal (§5.0, §9, §3.1).
static func block_reason(lead_id: String) -> String:
	return SalesLedger.meeting_block_reason(lead_id)


static func open(lead_id: String) -> Dictionary:
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	if p == null:
		return {}
	reset()
	_active = true
	_lead_id = lead_id
	_facts = SalesProbes.facts_for(p)
	_probe_budget = _probes_for_star(p.star)
	_base_contributions = _build_base_contributions(p)
	_needle = _odds_from(_base_contributions)
	SalesLedger.consume_meeting_right()
	# §5.0 — the founder is AT the table for the whole sitting. The flag is what the two
	# busy gates read during the skip; setting it on open rather than on close means a save
	# taken by any path outside the scene can never catch a half-set world.
	GameState.set_flag("sales_meeting_active", true)
	EventBus.meeting_entered.emit(lead_id)
	_advance_probe()
	if _probe.is_empty():
		# The catalogue had nothing to ask of this table. That is a legitimate state (a
		# narrow content set, an unusual world) and it must RESOLVE rather than render an
		# empty row: the customer simply goes straight to the verdict on the reading as it
		# stands, which is the same thing "Teklife geç" does.
		return _resolve_by_check()
	return view_state()


## §5.0 — closing costs two hours, and those hours RUN. The founder contributes nothing to
## them (the busy flag is still set); everyone else works normally, which is exactly Ekip
## §2.1: a build with a free team member flows, a founder-only build pauses.
static func close() -> void:
	if not _active:
		return
	_active = false
	_skip_hours(SalesConstants.MEETING_SKIP_HOURS)
	GameState.set_flag("sales_meeting_active", false)
	EventBus.pitch_finished.emit()
	# ONE SITTING, and nothing of it survives. Clearing here rather than on the next open() is
	# what makes "never serialised" a fact rather than a promise: between two meetings there
	# is no meeting state at all, so a save taken in between has nothing to leave out.
	reset()


static func _skip_hours(hours: int) -> void:
	for i in maxi(hours, 0):
		var next_hour: int = GameState.current_hour + 1
		if next_hour >= TimeManager.HOURS_PER_DAY:
			# Mirrors TimeManager._drain_boundaries' order exactly: hour 0's hourly tick
			# fires, THEN the day rolls. Getting this backwards costs a day its first hour.
			GameState.set_current_hour(0)
			TimeManager._dispatch_hourly_tick(0)
			GameState.advance_day()
			TimeManager._dispatch_daily_tick()
		else:
			GameState.set_current_hour(next_hour)
			TimeManager._dispatch_hourly_tick(next_hour)
	# The float accumulator is authoritative over the integer hour; leaving them disagreeing
	# makes TimeManager.from_dict warn and silently drop back to the integer on the next load.
	TimeManager.sync_to_current_hour()


# ============================================================================
#  §5.1 — the reading
# ============================================================================

## The persuasion inputs (§5.1, "şekil mühürlü, ağırlıklar K"). Each entry is a
## {seam, delta} pair in the engine's §9.6 shape, so the hover list is built by the engine's
## own `EvDice.modifier_lines` rather than by a second display rule.
##
## I7 IS STRUCTURAL HERE: a term exists only if a named query produced it. "Masada olmayan
## yetenek satır olamaz" (§5.1) is enforced by there being nowhere else to get a number.
static func _build_base_contributions(p: Prospect) -> Array:
	var out: Array = []
	# Product fit — the dominant term. The archetype's axis weights are what make the same
	# product read differently at two tables.
	var weights: Dictionary = SalesArchetypes.axis_weights(p.archetype_id)
	var floors: Dictionary = ProductRead.market_floors("b2b")
	var fit: float = 0.0
	for axis in weights.keys():
		var a: String = String(axis)
		var floor_v: float = maxf(float(floors.get(a, 30)), 1.0)
		fit += float(weights[a]) * clampf(float(ProductRead.axis_reading("", a)) / floor_v - 1.0, -1.0, 1.0)
	out.append({"seam": "urun.axis_reading", "delta": SalesConstants.W_PRODUCT_FIT * fit})

	# The founder's Satış — the base.
	var sales_star: float = HRConstants.stars_for(GameState.get_founder_skill(HRConstants.AREA_SALES))
	out.append({"seam": "hr.effective_skill",
		"delta": SalesConstants.W_FOUNDER_SALES * (sales_star / float(HRConstants.STAR_MAX) - 0.4)})

	# The price signal (§7.5) — the dial the player set is felt at the table.
	var stance_signal: float = 0.0
	match SalesLedger.price_stance():
		SalesConstants.STANCE_COMPETITIVE: stance_signal = 1.0
		SalesConstants.STANCE_PREMIUM: stance_signal = -1.0
	out.append({"seam": "sales.price_stance", "delta": SalesConstants.W_PRICE_SIGNAL * stance_signal})

	# The provider ladder (Ürün §10).
	var provider_ok: float = 1.0 if not InfraSystem.blocks_enterprise_signature() else -1.0
	out.append({"seam": "urun.capacity_tier", "delta": SalesConstants.W_PROVIDER_TIER * provider_ok})

	# Star mismatch — a HARD curve, and Charisma is one of only two moments it may be touched.
	var gap: int = clampi(p.star - int(sales_star), 0, SalesConstants.MISMATCH_PENALTY.size() - 1)
	var penalty: float = float(SalesConstants.MISMATCH_PENALTY[gap])
	if penalty > 0.0 and GameState.get_founder_skill(FounderConstants.SKILL_CHARISMA) > 0:
		penalty *= (1.0 - SalesConstants.CHARISMA_MISMATCH_RELIEF)
		out.append({"seam": "founder.charisma", "delta": 0.0001})   # the line, not the size
	if penalty > 0.0:
		out.append({"seam": "sales.reach_band", "delta": -penalty})

	# §9 — the first loss leaves a permanent mark on the return.
	if p.loss_count > 0:
		out.append({"seam": "sales.loss_reason", "delta": -SalesConstants.REPITCH_PENALTY})
	return out


static func _odds_from(contributions: Array) -> float:
	var total: float = SalesConstants.ODDS_BASE
	for c in contributions:
		total += float((c as Dictionary).get("delta", 0.0))
	return clampf(total, SalesConstants.ODDS_FLOOR, SalesConstants.ODDS_CEIL)


static func odds() -> float:
	return _needle


## The §9.6 hover list: signed, sorted by magnitude, NO NUMBERS, at most four lines with the
## rest folded into one. Built with the engine's own helper — Sales is its first consumer.
static func modifier_lines() -> Array:
	var all: Array = _base_contributions.duplicate()
	all.append_array(_answer_contributions)
	return EvDice.modifier_lines(all, _modifier_labels(), SalesConstants.MODIFIER_LINES_MAX)


static func _modifier_labels() -> Dictionary:
	# Every key here is a seam name, and every seam name here is one a query actually answers.
	return {
		"urun.axis_reading": TranslationServer.translate("SALES_MOD_PRODUCT_FIT"),
		"hr.effective_skill": TranslationServer.translate("SALES_MOD_FOUNDER_SALES"),
		"sales.price_stance": TranslationServer.translate("SALES_MOD_PRICE_SIGNAL"),
		"urun.capacity_tier": TranslationServer.translate("SALES_MOD_PROVIDER"),
		"sales.reach_band": TranslationServer.translate("SALES_MOD_MISMATCH"),
		"founder.charisma": TranslationServer.translate("SALES_MOD_CHARISMA"),
		"sales.loss_reason": TranslationServer.translate("SALES_MOD_RETURNED"),
		"sales.answer": TranslationServer.translate("SALES_MOD_ANSWERS"),
	}


# ============================================================================
#  Probing
# ============================================================================

static func _probes_for_star(star: int) -> int:
	match star:
		1: return SalesConstants.PROBES_ONE_BREATH
		2: return SalesConstants.PROBES_STANDARD
	return SalesConstants.PROBES_DEEP


static func _advance_probe() -> void:
	var p: Prospect = ProspectRegistry.get_prospect(_lead_id)
	if p == null:
		return
	_probe = SalesProbes.pick(_facts, _used_families,
		GameState.run_seed + GameState.day * 31 + _probe_index * 17)
	if _probe.is_empty():
		return
	_used_families.append(String(_probe.get("family", "")))
	SalesProbes.remember(String(_probe.get("id", "")))
	_probe_index += 1


## Play one answer. Moves the needle, records the path, then asks whether the CUSTOMER is
## done — the two thresholds and the safety cap, in that order.
static func choose(answer_id: String) -> Dictionary:
	if not _active or _probe.is_empty():
		return view_state()
	var answers: Array = SalesProbes.answers_for(_probe, _facts, _promise_locked())
	var chosen: Dictionary = {}
	for a in answers:
		if String((a as Dictionary).get("id", "")) == answer_id and bool((a as Dictionary).get("open", false)):
			chosen = a as Dictionary
			break
	if chosen.is_empty():
		return view_state()

	_path.append("%s:%s" % [String(_probe.get("id", "")), answer_id])
	var verb: String = String(chosen.get("verb", ""))
	var delta: float = float(chosen.get("delta", 0.0))
	var p: Prospect = ProspectRegistry.get_prospect(_lead_id)

	# §5.1 — the honesty premium is an ARCHETYPE property, not a global one.
	if verb == SalesProbes.VERB_ADMIT and p != null \
			and SalesArchetypes.pays_honesty_premium(p.archetype_id):
		delta += SalesConstants.HONESTY_BONUS / maxf(SalesConstants.W_ANSWER, 0.001)
	# §6 — a pitch promise is registered at the SIGNATURE, not here: a promise made to a
	# company that walks out was never given. What it does now is narrow Act 2's band.
	if verb == SalesProbes.VERB_PROMISE:
		_promised_feature = _pick_promise_feature()

	_answer_contributions.append({"seam": "sales.answer", "delta": SalesConstants.W_ANSWER * delta})
	_needle = _odds_from(_base_contributions + _answer_contributions)

	# The customer decides. Top threshold first: a table that is already convinced does not
	# sit through two more questions to be polite.
	if _needle >= SalesConstants.CUT_HIGH:
		return _win()
	if _needle <= SalesConstants.CUT_LOW:
		return _lose(_derive_loss_reason())
	if _probe_index >= mini(_probe_budget, SalesConstants.SAFETY_CAP_PROBES):
		return _resolve_by_check()
	_advance_probe()
	if _probe.is_empty():
		return _resolve_by_check()
	return view_state()


# DESIGN-PARKED: §5.1.1 gives the ENDING to the customer and defines no player exit from
# Act 1, so there is none — sitting down is the decision and the sitting always resolves.
# Alternatives seen: a neutral "stand up" (makes the two-hour cost dodgeable and weakens
# "masa kurucunundur"), or an exit that burns the daily meeting right anyway.
# DESIGN-PARKED: §5.1.1 gives the ENDING to the customer and defines no player exit from
# Act 1, so there is none — sitting down is the decision and the sitting always resolves.
# Alternatives seen: a neutral "stand up" (makes the two-hour cost dodgeable and weakens
# "masa kurucunundur"), or an exit that burns the daily meeting right anyway.
## §5.1.1 — "Teklife geç" from the second probe on. The remaining probes are not played and
## the reading goes to the close AS IT STANDS. No penalty; the cost is the ▲ never earned.
static func skip_to_offer() -> Dictionary:
	if not _active or not can_skip_to_offer():
		return view_state()
	_path.append("skip:%d" % _probe_index)
	return _resolve_by_check()


static func can_skip_to_offer() -> bool:
	return _active and _probe_index >= SalesConstants.SKIP_TO_OFFER_FROM_PROBE


## THE ONE DIE (§5.1, engine §9.2/§9.3). The key carries the run seed, the day, the lead and
## the PATH, so the same answers replay identically after a save/load and a different set of
## answers is a genuinely different roll.
static func _resolve_by_check() -> Dictionary:
	var passed: bool = EvDice.check(_needle, "%s.%s" % [EVENT_KIND, _lead_id], path_id())
	return _win() if passed else _lose(_derive_loss_reason())


## The stable identifier of the path played so far — the engine's `option_id` (§9.3). NEVER
## EMPTY: a sitting that resolves without a single played answer still has an identity, and an
## empty option_id would make two different tables hash to the same die.
static func path_id() -> String:
	if _path.is_empty():
		return "opened"
	return "|".join(PackedStringArray(_path))


static func _win() -> Dictionary:
	_outcome = "won"
	EventBus.meeting_won.emit(_lead_id)
	return view_state()


static func _lose(reason: String) -> Dictionary:
	_outcome = "lost"
	_loss_reason = reason
	var p: Prospect = ProspectRegistry.get_prospect(_lead_id)
	if p != null:
		# §5.2 — the account remembers, the log records, the signal fires. No economic delta.
		SalesLedger.report_loss(p.company_name, reason, _loss_target(reason))
		SalesFaucetSystem.lock_return(p.company_name, SalesConstants.RETURN_LOCK_DAYS)
		ProspectRegistry.remove(p.id)
	return view_state()


# DESIGN-PARKED: §5.2 gives the taxonomy but not the PRECEDENCE. This order is the one a
# buyer would actually weigh — can it stay up, do I trust who runs it, does it do the thing,
# who carries the switch — with price as the falling branch. Alternatives seen: weight by the
# archetype's own axis priorities; or name whichever modifier is most negative (which turns a
# number into a sentence and reads against §9.6's no-numbers rule).
# DESIGN-PARKED: §5.2 gives the taxonomy but not the PRECEDENCE. This order is the one a
# buyer would actually weigh — can it stay up, do I trust who runs it, does it do the thing,
# who carries the switch — with price as the falling branch. Alternatives seen: weight by the
# archetype's own axis priorities; or name whichever modifier is most negative (which turns a
# number into a sentence and reads against §9.6's no-numbers rule).
## §5.2 — the customer names its reason FROM REAL STATE. The order is the order a buyer would
## actually weigh them, and every branch is a query the meeting already read.
static func _derive_loss_reason() -> String:
	if _facts.get("confirmed_bugs", 0) >= 3 or int(_facts.get("axis_stability", 0)) < 40:
		return SalesConstants.LOSS_STABILITY
	if not bool(_facts.get("provider_enterprise_ok", true)):
		return SalesConstants.LOSS_PROVIDER_TRUST
	if bool(_facts.get("has_locked_next_step", false)):
		return SalesConstants.LOSS_MISSING_TIER
	if not bool(_facts.get("cs_staffed", false)):
		return SalesConstants.LOSS_SWITCHING_RISK
	return SalesConstants.LOSS_PRICE


## The reason's TARGET field (§5.2 "Hedef alanı ilgili hat/eksen kimliğini taşır") — what the
## demand generator will read when it lands.
static func _loss_target(reason: String) -> String:
	match reason:
		SalesConstants.LOSS_STABILITY: return "stability"
		SalesConstants.LOSS_MISSING_TIER:
			var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
			for line_id in ProductLines.line_ids(sub_id):
				var step_id: String = ProductRead.line_next_step("", String(line_id))
				if step_id != "" and not ProductRead.step_unlockable(step_id):
					return String(line_id)
			return ""
		SalesConstants.LOSS_PROVIDER_TRUST: return InfraSystem.provider()
		SalesConstants.LOSS_SWITCHING_RISK: return HRConstants.AREA_CUSTOMER_SUCCESS
	return ""


# ============================================================================
#  §6 — the promise lock
# ============================================================================

static func _promise_locked() -> bool:
	if SalesLedger.open_pitch_promise() != "":
		return true
	var p: Prospect = ProspectRegistry.get_prospect(_lead_id)
	return p != null and SalesLedger.promise_locked_for(p.company_name)


static func promised_feature() -> String:
	return _promised_feature


## The feature a pitch promise would carry. Reuses the account-side picker so a promise made
## at the table points at the same kind of thing a retention promise does.
static func _pick_promise_feature() -> String:
	return B2BSalesSystem.pick_pain_feature(
		String(GameState.get_flag("mvp_sub_product_type_id", "")), _probe_index)


# ============================================================================
#  View
# ============================================================================

static func view_state() -> Dictionary:
	var p: Prospect = ProspectRegistry.get_prospect(_lead_id)
	var company: String = p.company_name if p != null else ""
	var star: int = p.star if p != null else 0
	var archetype: String = p.archetype_id if p != null else ""
	var vs: Dictionary = {
		"active": _active,
		"lead_id": _lead_id,
		"company_name": company,
		"star": star,
		"archetype_line": SalesArchetypes.voice_line(archetype) if archetype != "" else "",
		"whale_condition": p.whale_condition if p != null else "",
		"odds": _needle,
		"modifier_lines": modifier_lines(),
		"outcome": _outcome,
		"probe_index": _probe_index,
		"probe_budget": _probe_budget,
		"can_skip": can_skip_to_offer() and _outcome == "",
		"memory_line": _memory_line(p),
		"inner_voice": _take_inner_voice(),
	}
	if _outcome == "":
		vs["probe_key"] = "SALES_PROBE_%s" % String(_probe.get("id", "")).to_upper()
		vs["answers"] = _answer_views()
	elif _outcome == "lost":
		vs["closing_key"] = "SALES_LOSS_%s" % _loss_reason.to_upper()
	else:
		vs["closing_key"] = "SALES_WIN_CUT"
	return vs


static func _answer_views() -> Array:
	var out: Array = []
	for a in SalesProbes.answers_for(_probe, _facts, _promise_locked()):
		var ans: Dictionary = a as Dictionary
		out.append({
			"id": String(ans.get("id", "")),
			"verb": String(ans.get("verb", "")),
			"open": bool(ans.get("open", false)),
			"text_key": "SALES_ANS_%s_%s" % [
				String(_probe.get("id", "")).to_upper(), String(ans.get("id", "")).to_upper()],
			"lock_key": _lock_key(String(ans.get("lock_fact", ""))),
		})
	return out


## §5.1.1 / §11.9 — a locked row is still an INFORMATION sentence: the lock names the game's
## real gap, never a bare "unavailable".
static func _lock_key(lock_fact: String) -> String:
	if lock_fact == "":
		return ""
	return "SALES_LOCK_%s" % lock_fact.to_upper()


## §9 — the memory line. Only a company that has actually walked out of a meeting carries one.
static func _memory_line(p: Prospect) -> String:
	if p == null or p.loss_count <= 0 or p.last_loss_reason == "":
		return ""
	return TranslationServer.translate("SALES_MEMORY_%s" % p.last_loss_reason.to_upper())


# DESIGN-PARKED: §5.1.1 says budgeted and conditional but not WHICH line or WHEN. At most
# once per sitting, on the second probe, cycling three lines while the run has budget.
# Alternative seen: a criteria-scored picker like the probes — more content machinery than
# three lines can pay for, and the writing round may want a different shape entirely.
# DESIGN-PARKED: §5.1.1 says budgeted and conditional but not WHICH line or WHEN. At most
# once per sitting, on the second probe, cycling three lines while the run has budget.
# Alternative seen: a criteria-scored picker like the probes — more content machinery than
# three lines can pay for, and the writing round may want a different shape entirely.
## §5.1.1 — the inner voice is BUDGETED and CONDITIONAL: no compulsory opening slot, at most
## once per sitting, and only while the run still has budget.
static func _take_inner_voice() -> String:
	if _inner_voice_shown or _probe_index != 1 or SalesLedger.inner_voice_left() <= 0:
		return ""
	_inner_voice_shown = true
	SalesLedger.spend_inner_voice()
	return TranslationServer.translate("SALES_INNER_VOICE_%d"
		% (SalesLedger.inner_voice_left() % 3))
