extends Node

# Event pipeline per TECH_SPEC §6.1 + §8.2 slot 6.
#
# Loads GameEvent resources from data/events/reactive/*.json at _ready.
# Each daily tick (slot 6, after Finance) walks the deterministic "beat"
# events (no random trigger), filters by eligibility (trigger conditions +
# cooldown + one-shot history), queues eligible events sorted by priority
# desc, and emits modal_requested for the top of the queue if no modal is
# currently active. Ambient events (random trigger) evaluate on hourly_tick
# instead, gated by optional allowed_hours time-of-day windows (D-A). The
# modal is mounted by main.gd (deferred consumer pattern — EventManager has
# no scene dependency).
#
# When a choice is picked, EventModal calls resolve_choice(event_id, idx):
# the modifier dispatcher applies effects through existing GameState +
# CharacterRegistry setters (which emit existing EventBus signals so the
# UI updates automatically — one-way dataflow per TECH_SPEC §6.2).
#
# State (queue, history, _all_events dict) lives here because it must persist
# across daily ticks — autoload over RefCounted system (Finance/HR/Sales are
# stateless per-tick logic and use the RefCounted pattern).
#
# RNG: random_chance triggers use bare randf() against the global seed set by
# GameState.initialize_run (TECH_SPEC §10.4). Deterministic for the run.
# Migration cue (TECH_SPEC §20, 2026-05-15): when a second system needs RNG,
# move to a RandomNumberGenerator instance on GameState to avoid sequencing
# coupling between systems.

const EVENTS_DIR := "res://data/events/reactive/"

var _all_events: Dictionary = {}          # id (String) -> GameEvent
var _queue: Array[GameEvent] = []         # Eligible but not yet shown
var _history: Array = []                  # Array of {id, day, choice}
var _active_event_id: String = ""         # "" = no modal up
var _active_event: GameEvent = null       # live event object — covers synthetic events (e.g. ship moment) not in _all_events

# Time-of-day windows (D-A). Optional JSON field "allowed_hours": [start, end]
# — inclusive 24h ints; start > end wraps midnight (e.g. [22, 2] = 22:00-02:59).
# Kept manager-side (id -> Array) so GameEvent's schema stays untouched —
# the loader ignores unknown JSON keys, this dict is the extension seam.
var _hour_windows: Dictionary = {}

# Day (GameState.day) on which an ambient event last ENTERED the queue.
# Preserves the Faz 1 bug 1.6 "≤1 ambient per day" throttle now that ambient
# evaluation runs hourly (was: `break` after first ambient enqueue in daily_tick).
var _ambient_fired_day: int = -1


func _ready() -> void:
	_load_all_events_from_disk()


# --- TimeManager slot 6 entry point ---

func daily_tick() -> void:
	# Deterministic "beat" events only (Faz 1 bug 1.6 split, D-A refinement):
	# state-gated events with no random roll — critical flow moments (paid-tier,
	# first-revenue, Frank intro, traction-ready) — fire the moment their
	# condition holds, never delayed behind any cap. The ambient random pool
	# moved to hourly_tick() so time-of-day windows (allowed_hours) are
	# mechanically honest; its ≤1-per-day throttle lives there now
	# (_ambient_fired_day).
	var beats: Array[GameEvent] = []
	for ev in _all_events.values():
		if ev.has_random_trigger():
			continue  # ambient — evaluated on the hourly path
		if _is_eligible(ev):
			beats.append(ev)
	# Every eligible beat, highest priority first.
	for ev in _ordered_by_priority(beats):
		_enqueue_eligible(ev)
	_pump_queue()  # also drains anything a prior tick left queued


# --- TimeManager hourly slot entry point (D-A: time-of-day windows) ---

func hourly_tick(hour: int) -> void:
	# Ambient events (those with a "random" trigger) evaluate here so their
	# allowed_hours windows line up with the fiction — a 02:17 API-bug event
	# fires at night, not at the midnight daily tick. Semantics:
	#   - The window gate controls queue-ENTRY only (_is_eligible step 4b);
	#     display (_pump_queue) is untouched — an enqueued event still shows
	#     later if a modal is up.
	#   - ≤1 ambient per day survives via _ambient_fired_day (counts ENTRY).
	#   - Chance normalization: the JSON "chance" keeps meaning per-DAY
	#     probability. The roll now repeats every in-window hour, so each
	#     hourly roll uses chance / window_length_hours (24 h when the event
	#     has no window). Daily fire probability ≈ 1-(1-p/n)^n — same ballpark
	#     as p (slightly below), instead of silently multiplying frequency.
	if _ambient_fired_day == GameState.day:
		return  # today's ambient slot already used
	var eligible: Array[GameEvent] = []
	for ev in _all_events.values():
		if not ev.has_random_trigger():
			continue  # beats stay on the daily path
		if not _is_hour_in_window(hour, _hour_windows.get(ev.id, []) as Array):
			continue  # cheap pre-filter; _is_eligible re-gates via GameState.current_hour
		if _is_eligible(ev, 1.0 / float(_window_length_hours(ev))):
			eligible.append(ev)
	# At most one ambient event enters the queue per day.
	for ev in _ordered_by_priority(eligible):
		if _enqueue_eligible(ev):
			_ambient_fired_day = GameState.day
			_pump_queue()
			break


# Group by priority (descending), shuffle each group, concatenate. Uses the
# global seeded RNG per TECH_SPEC §10.4 (bare shuffle) for deterministic replay.
func _ordered_by_priority(events: Array[GameEvent]) -> Array[GameEvent]:
	var by_priority: Dictionary = {}
	for ev in events:
		if not by_priority.has(ev.priority):
			by_priority[ev.priority] = []
		by_priority[ev.priority].append(ev)
	var priorities: Array = by_priority.keys()
	priorities.sort()
	priorities.reverse()  # high → low
	var ordered: Array[GameEvent] = []
	for p in priorities:
		var group: Array = by_priority[p]
		group.shuffle()
		for ev in group:
			ordered.append(ev)
	return ordered


# Queue an eligible event unless it is already queued / currently showing.
# Returns true only when it was newly added (so the ambient cap can count it).
func _enqueue_eligible(ev: GameEvent) -> bool:
	if _queue.has(ev) or ev.id == _active_event_id:
		return false
	_queue.append(ev)
	EventBus.event_triggered.emit(ev.id)
	if OS.is_debug_build():
		print("[EventManager] Eligible: %s" % ev.id)
	return true


# --- Modal closure entry point (called by EventModal when a choice is picked) ---

func resolve_choice(event_id: String, choice_index: int) -> void:
	# Idempotency guard: only the currently-active event may be resolved. Blocks
	# the double-click / double-fire race — queue_free() is deferred, so the
	# modal's choice buttons stay live within the frame; a fast second click
	# would otherwise re-apply modifiers AND free the next queued event's modal,
	# leaving the clock paused on a phantom active event (the dev-phase freeze).
	if event_id != _active_event_id:
		push_warning("[EventManager] resolve_choice for non-active event %s (active=%s) — ignored" % [event_id, _active_event_id])
		return
	var ev: GameEvent = _all_events.get(event_id, null)
	# Synthetic events (e.g. the ProductSystem ship moment) are enqueued directly
	# and never registered in _all_events — fall back to the live active event.
	if ev == null and _active_event != null and _active_event.id == event_id:
		ev = _active_event
	if ev == null or choice_index < 0 or choice_index >= ev.choices.size():
		push_warning("[EventManager] resolve_choice invalid: %s [%d]" % [event_id, choice_index])
		return
	var choice: EventChoice = ev.choices[choice_index]
	_apply_modifiers(choice.modifiers)
	_history.append({"id": event_id, "day": GameState.day, "choice": choice_index})
	_active_event_id = ""
	_active_event = null
	if OS.is_debug_build():
		print("[EventManager] Resolved: %s choice %d" % [event_id, choice_index])
	EventBus.event_resolved.emit(event_id, choice_index)
	_pump_queue()  # Open the next queued modal if any


func enqueue(event: GameEvent) -> void:
	# Injection point for system-built synthetic events (e.g. ProductSystem
	# ship moment). Bypasses eligibility check + history append by design —
	# callers are responsible for one-shot enforcement themselves.
	if not GameState.run_active:
		return  # nothing new mounts after a terminal (ENDGAME_DESIGN.md §7.3)
	if event == null:
		push_warning("[EventManager] enqueue called with null event")
		return
	if _queue.has(event) or event.id == _active_event_id:
		return
	_queue.append(event)
	EventBus.event_triggered.emit(event.id)
	_pump_queue()


func enqueue_front(event: GameEvent) -> void:
	# High-priority deterministic injection (ENDGAME_DESIGN.md §2.4): the Frank
	# gate scene must jump ahead of already-queued ambient/beat events. Same
	# dedupe as enqueue() — re-enqueueing the SAME cached GameEvent instance is
	# a no-op, which is what makes gate reminders stack-proof (§7.10).
	if not GameState.run_active:
		return
	if event == null:
		push_warning("[EventManager] enqueue_front called with null event")
		return
	if _queue.has(event) or event.id == _active_event_id:
		return
	_queue.push_front(event)
	EventBus.event_triggered.emit(event.id)
	_pump_queue()


func flush_queue() -> void:
	# Terminal path (§7.2): queued scenes die with the run — including a pending
	# Frank gate scene. Deliberately does NOT touch _active_event_id: an open
	# modal resolves normally; its post-resolve speed restore is swallowed by
	# TimeManager's dead-run guard.
	_queue.clear()


func remove_queued(event_id: String) -> void:
	# Targeted hold (§7.4): shutter start pulls a queued gate scene without
	# killing the whole queue. The gate latch survives; PhaseGateSystem
	# re-prompts after the shutter clears.
	for i in range(_queue.size() - 1, -1, -1):
		if _queue[i].id == event_id:
			_queue.remove_at(i)


# --- Public queries ---

func has_pending() -> bool:
	return _active_event_id != "" or not _queue.is_empty()


func get_queue_size() -> int:
	# Public getter for the Events tab badge (LeftTabs).
	return _queue.size()


func get_history() -> Array:
	# Snapshot — callers must not mutate the returned array.
	return _history.duplicate(true)


func is_condition_met(condition: Dictionary) -> bool:
	# Public — reused by EventModal for choice unlock checks.
	# Empty Dictionary means "no gate" — used by unlocked choices.
	if condition.is_empty():
		return true
	var t: String = condition.get("type", "")
	match t:
		"day_min":            return GameState.day >= int(condition.get("value", 0))
		"day_max":            return GameState.day <= int(condition.get("value", 0))
		"phase":              return GameState.phase == int(condition.get("value", 0))
		"cash_below":         return GameState.cash < int(condition.get("value", 0))
		"cash_above":         return GameState.cash > int(condition.get("value", 0))
		"brand_below":        return GameState.brand < int(condition.get("value", 0))
		"brand_above":        return GameState.brand > int(condition.get("value", 0))
		"reputation_below":   return GameState.reputation < int(condition.get("value", 0))
		"reputation_above":   return GameState.reputation > int(condition.get("value", 0))
		"subgenre":           return GameState.subgenre == String(condition.get("value", ""))
		"random":             return randf() < float(condition.get("chance", 0.0))
		"flag_equals":
			return GameState.get_flag(String(condition.get("key", "")), null) == condition.get("value")
		"flag_set":
			return GameState.has_flag(String(condition.get("key", "")))
		"build_state":
			var b = ProductSystem.get_active_build()
			if b == null:
				return false
			return b.status == String(condition.get("value", ""))
		"mvp_shipped":
			return bool(GameState.get_flag("mvp_shipped", false)) == bool(condition.get("value", true))
		"founder_skill_min":
			return GameState.get_founder_skill(String(condition.get("skill", ""))) >= int(condition.get("value", 0))
		"build_phase":
			var b_phase = ProductSystem.get_active_build()
			if b_phase == null:
				return false
			return b_phase.current_phase == String(condition.get("value", ""))
		"bug_count_above":
			var b_bug = ProductSystem.get_active_build()
			if b_bug == null:
				return false
			return b_bug.bug_count > int(condition.get("value", 0))
		# --- PostShip / sales conditions ---
		"customer_count_min":
			return CustomerRegistry.get_active().size() >= int(condition.get("value", 0))
		"customer_count_max":
			return CustomerRegistry.get_active().size() <= int(condition.get("value", 0))
		"mrr_above":
			return GameState.mrr > int(condition.get("value", 0))
		"mrr_below":
			return GameState.mrr < int(condition.get("value", 0))
		"market_type":
			return String(GameState.get_flag("mvp_market_type", "")) == String(condition.get("value", ""))
		"has_prospects":
			return ProspectRegistry.has_any() == bool(condition.get("value", true))
		"audience_above":
			return int(GameState.get_flag("b2c_audience", 0)) > int(condition.get("value", 0))
		"customer_satisfaction_below":
			return CustomerRegistry.get_min_satisfaction() < int(condition.get("value", 0))
		_:
			push_warning("[EventManager] Unknown condition type: %s" % t)
			return false


# --- Private helpers ---

func _is_eligible(ev: GameEvent, random_chance_scale: float = 1.0) -> bool:
	# 1. Active or already queued — skip.
	if ev.id == _active_event_id:
		return false
	# 2. Phase-appropriate gate during active builds. While a build is running
	# the only events allowed to fire are the ones explicitly scoped to the
	# current phase via a build_phase trigger condition — or system narrators
	# (ship moment, mentor cinematics) that opt in with the "build_safe" tag.
	# This is what keeps the legacy ev_debug_* pool (no build_phase, no tag)
	# silent during MVP build without touching their JSON.
	var active_build = ProductSystem.get_active_build()
	if active_build != null and not ev.has_tag("build_safe"):
		var phase_match: bool = false
		for cond in ev.trigger_conditions:
			if typeof(cond) != TYPE_DICTIONARY:
				continue
			if cond.get("type") == "build_phase" and cond.get("value") == active_build.current_phase:
				phase_match = true
				break
		if not phase_match:
			return false
	# 3. one_shot guard.
	if ev.one_shot:
		for entry in _history:
			if entry.get("id", "") == ev.id:
				return false
	# 4. Cooldown guard.
	if ev.cooldown_days > 0:
		var current_day: int = GameState.day
		for entry in _history:
			if entry.get("id", "") != ev.id:
				continue
			var since: int = current_day - int(entry.get("day", 0))
			if since < ev.cooldown_days:
				return false
	# 4b. Time-of-day window (optional JSON "allowed_hours": [start, end],
	# inclusive; start > end wraps midnight). Gates queue-ENTRY only — an
	# already-queued event still displays whenever _pump_queue reaches it.
	# Windowless events always pass.
	if not _is_hour_in_window(GameState.current_hour, _hour_windows.get(ev.id, []) as Array):
		return false
	# 5. Trigger conditions (AND logic). "random" rolls are scaled by
	# random_chance_scale — the hourly ambient path passes 1/window_hours so
	# the JSON chance keeps meaning per-DAY probability; daily path uses 1.0.
	for c in ev.trigger_conditions:
		if typeof(c) != TYPE_DICTIONARY:
			push_warning("[EventManager] trigger_conditions entry not Dictionary in %s" % ev.id)
			return false
		if String(c.get("type", "")) == "random":
			if not (randf() < float(c.get("chance", 0.0)) * random_chance_scale):
				return false
			continue
		if not is_condition_met(c):
			return false
	return true


# --- Time-of-day window helpers (D-A) ---

func _is_hour_in_window(hour: int, window: Array) -> bool:
	# Empty / malformed window = no gate. Inclusive on both ends.
	# Wrap-around supported: [22, 2] allows 22, 23, 0, 1, 2.
	if window.size() != 2:
		return true
	var start_h: int = int(window[0])
	var end_h: int = int(window[1])
	if start_h <= end_h:
		return hour >= start_h and hour <= end_h
	return hour >= start_h or hour <= end_h


func _window_length_hours(ev: GameEvent) -> int:
	# Nominal hour count of the event's window (inclusive), 24 when windowless.
	# Used to normalize per-hour random rolls back to per-day probability.
	var window: Array = _hour_windows.get(ev.id, []) as Array
	if window.size() != 2:
		return 24
	var start_h: int = int(window[0])
	var end_h: int = int(window[1])
	if start_h <= end_h:
		return end_h - start_h + 1
	return (24 - start_h) + end_h + 1


func _apply_modifiers(modifiers: Array) -> void:
	for m in modifiers:
		if typeof(m) != TYPE_DICTIONARY:
			push_warning("[EventManager] modifier not Dictionary: %s" % str(m))
			continue
		var t: String = m.get("type", "")
		var delta: int = int(m.get("delta", 0))
		match t:
			"cash":
				GameState.set_cash(GameState.cash + delta)
			"brand":
				GameState.set_brand(GameState.brand + delta)
			"reputation":
				GameState.set_reputation(GameState.reputation + delta)
			"morale":
				var cid: String = m.get("character_id", "")
				var c: Character = CharacterRegistry.get_character(cid)
				if c == null:
					push_warning("[EventManager] morale modifier targets unknown character: %s" % cid)
					continue
				CharacterRegistry.set_morale(cid, c.morale + delta)
			"morale_all_employees":
				for emp in CharacterRegistry.get_employees():
					CharacterRegistry.set_morale(emp.id, emp.morale + delta)
			"set_flag":
				var key: String = m.get("key", "")
				if key == "":
					push_warning("[EventManager] set_flag modifier missing 'key'")
					continue
				GameState.set_flag(key, m.get("value"))
			"add_character":
				var cdata: Dictionary = m.get("character_data", {})
				if typeof(cdata) != TYPE_DICTIONARY:
					push_warning("[EventManager] add_character missing or malformed character_data")
					continue
				var new_cid: String = String(cdata.get("id", ""))
				if new_cid == "":
					push_warning("[EventManager] add_character requires non-empty id")
					continue
				if CharacterRegistry.get_character(new_cid) != null:
					push_warning("[EventManager] add_character: id already exists (no-op): %s" % new_cid)
					continue
				var new_c: Character = Character.new()
				new_c.id = new_cid
				new_c.character_name = String(cdata.get("character_name", ""))
				new_c.role = String(cdata.get("role", ""))
				new_c.category = String(cdata.get("category", "employee"))
				new_c.monthly_salary = int(cdata.get("monthly_salary", 0))
				new_c.equity_pct = float(cdata.get("equity_pct", 0.0))
				new_c.morale = int(cdata.get("morale", 50))
				new_c.loyalty = int(cdata.get("loyalty", 50))
				new_c.relationship = String(cdata.get("relationship", "neutral"))
				new_c.trust_score = int(cdata.get("trust_score", 0))
				var traits_in: Array = cdata.get("traits", [])
				var typed_traits: Array[String] = []
				for tr in traits_in:
					typed_traits.append(String(tr))
				new_c.traits = typed_traits
				new_c.role_stats = cdata.get("role_stats", {})
				new_c.attention_flag = String(cdata.get("attention_flag", ""))
				CharacterRegistry.add(new_c)
			# --- Build modifiers (Product Lifecycle Part 1: clear two-rule vocabulary) ---
			"dimension_delta":
				# {axis, amount} — grow (+) or penalize (−) a quality axis, bounded via grow().
				ProductSystem.apply_dimension_delta(String(m.get("axis", "innovation")), int(m.get("amount", 0)))
			"bug_delta":
				# {amount} — add (+) or clear (−) bugs directly.
				ProductSystem.apply_bug_delta(int(m.get("amount", 0)))
			"delay_days":
				# {days} — POSITIVE = slower (adds days to the phase), NEGATIVE = faster.
				ProductSystem.apply_speed_bonus(int(m.get("days", 0)))
			# Deprecated aliases (kept so any un-migrated content still applies):
			"speed_bonus":
				ProductSystem.apply_speed_bonus(int(m.get("days", 0)))
			"quality_bonus":
				ProductSystem.apply_dimension_delta("innovation", int(m.get("amount", 0)))
			"ship_active_build":
				ProductSystem.ship_active_build()
			# --- PostShip / sales modifiers (§10: revenue only via played choices) ---
			"add_prospect":
				PitchSystem.spawn_prospect(String(m.get("archetype", "small")), String(m.get("source", "event")))
			"churn_customer":
				# Most-at-risk customer leaves. B2C is one aggregate record, so for B2C
				# erode the AUDIENCE (derived MRR follows) instead of deleting the whole
				# userbase; B2B removes the account record. (Economy Model v2.)
				var victim: Customer = CustomerRegistry.get_lowest_satisfaction_customer()
				if victim != null:
					if victim.market_type == "b2c":
						var aud: int = int(GameState.get_flag("b2c_audience", 0))
						SalesSystem.add_b2c_audience(-int(round(aud * 0.15)))
					else:
						CustomerRegistry.remove(victim.id)
						GameState.run_customers_lost += 1  # run counter seam (Spec 3 §3) — sole customer-removal path
						SalesSystem.reflect_mrr()
			"seats":
				# WRITE-THROUGH: grant B2B seats via the registry seam (emits), and price the
				# recurring value off seats × per-seat rate on the SAME account. The narrative
				# claim ("N koltuk ekle") now matches the state (seats + MRR move together).
				var b2bs_s: Array[Customer] = CustomerRegistry.get_by_market("b2b")
				var seat_tgt: Customer = _resolve_customer_target(m.get("customer_id", ""), b2bs_s[0] if not b2bs_s.is_empty() else null)
				if seat_tgt != null:
					var add_seats: int = int(m.get("amount", 0))
					var per_seat: int = int(m.get("per_seat_mrr", 0))
					CustomerRegistry.set_seats(seat_tgt.id, seat_tgt.seats + add_seats)
					if per_seat != 0:
						CustomerRegistry.set_mrr(seat_tgt.id, seat_tgt.mrr + add_seats * per_seat)
						SalesSystem.reflect_mrr()
			"customer_mrr_delta":
				# Expansion: grow a B2B account's MRR (target-threaded; default = first B2B).
				var b2bs_m: Array[Customer] = CustomerRegistry.get_by_market("b2b")
				var tgt: Customer = _resolve_customer_target(m.get("customer_id", ""), b2bs_m[0] if not b2bs_m.is_empty() else null)
				if tgt != null:
					CustomerRegistry.set_mrr(tgt.id, tgt.mrr + delta)
					SalesSystem.reflect_mrr()
			"satisfaction_delta":
				# Target-threaded; default = the most-at-risk customer (legacy behavior).
				var sc: Customer = _resolve_customer_target(m.get("customer_id", ""), CustomerRegistry.get_lowest_satisfaction_customer())
				if sc != null:
					CustomerRegistry.set_satisfaction(sc.id, sc.satisfaction + delta)
			"audience_delta":
				SalesSystem.add_b2c_audience(delta)  # +/- audience; derived MRR follows
			"open_paid_tier":
				SalesSystem.open_b2c_paid_tier(int(m.get("price", 15)), float(m.get("initial_pct", 0.1)))
			"convert_audience":
				# Economy Model v2: growth-move events (Product Hunt, power-user) are now
				# an AUDIENCE SPIKE — MRR follows via the hourly derivation, not a chunk.
				var n: int = int(m.get("count", 0))
				if m.has("pct"):
					n = int(round(int(GameState.get_flag("b2c_audience", 0)) * float(m.get("pct", 0.0))))
				SalesSystem.add_b2c_audience(n)
			"mentor_advisory":
				EventBus.mentor_advisory_changed.emit(String(m.get("text", "")))
			# --- Endgame modifiers (ENDGAME_DESIGN.md §2/§4) — precedent: ship_active_build ---
			"advance_phase":
				# Frank gate scene confirm. The single played path to a phase change;
				# zero economic modifiers ride along (§2.1).
				GameState.advance_phase()
			"phase_gate_decline":
				# "Henüz değil" — no penalty; re-arms the 5-day reminder clock.
				PhaseGateSystem.on_gate_declined()
			"accept_acquisition":
				# Class A instant soft win — fired by the played moment, not the daily scan.
				EndingsSystem.trigger_ending("acquisition")
			"accept_pivot":
				# §4.5 escape hatch taken: VC path closes permanently; run continues to Day 180.
				EndingsSystem.on_pivot_accepted()
			"decline_pivot":
				# Hatch refused at the third closed table — cascade resolves now.
				EndingsSystem.trigger_ending("vc_rejection_cascade")
			"start_vc_meeting":
				# Spec 4: scheduled meeting-prompt accept → mount MeetingScene via a
				# view-state build. VCPitchSystem emits meeting_scene_requested.
				VCPitchSystem.begin_meeting(String(m.get("vc_id", "")))
			"decline_vc_meeting":
				# "Bugün değil" — the request is consumed, VC stays open, no penalty.
				GameState.pending_meeting.clear()
			# --- B2B Sales System modifiers (retention outcomes; each routes through a
			#     B2BSalesSystem seam. Brand/reputation ride as their own modifiers on the
			#     same choice - see B2BEventFactory - so the fiction matches the state). ---
			"b2b_promise_create":
				B2BSalesSystem.accept_promise(String(m.get("customer_id", "")),
					String(m.get("feature_id", "")), int(m.get("deadline_days", 14)))
			"b2b_retain_delay":
				B2BSalesSystem.hold(String(m.get("customer_id", "")))
			"b2b_retain_discount":
				B2BSalesSystem.apply_discount(String(m.get("customer_id", "")), int(m.get("mrr_delta", 0)))
			"b2b_retain_ignore":
				B2BSalesSystem.ignore_risk(String(m.get("customer_id", "")))
			"b2b_cs_promise_honor":
				B2BSalesSystem.honor_cs_promise(String(m.get("customer_id", "")),
					String(m.get("feature_id", "")), int(m.get("deadline_days", 14)))
			"b2b_cs_promise_refuse":
				B2BSalesSystem.refuse_cs_promise(String(m.get("customer_id", "")))
			"b2b_expand":
				B2BSalesSystem.expand(String(m.get("customer_id", "")),
					int(m.get("add_seats", 0)), int(m.get("per_seat_mrr", 0)))
			"b2b_expand_decline":
				B2BSalesSystem.decline_expansion(String(m.get("customer_id", "")))
			_:
				push_warning("[EventManager] Unknown modifier type: %s" % t)


func _resolve_customer_target(customer_id_raw: Variant, fallback: Customer) -> Customer:
	# Target selector for customer-scoped modifiers (WRITE-THROUGH §A.3): a concrete
	# customer id, the "primary_b2b" selector (first active B2B account), or "" → the
	# caller's documented fallback. Lets one event hit ONE consistent account across
	# its seats / MRR / satisfaction modifiers.
	var sel: String = String(customer_id_raw)
	if sel == "":
		return fallback
	if sel == "primary_b2b":
		var b2bs: Array[Customer] = CustomerRegistry.get_by_market("b2b")
		return b2bs[0] if not b2bs.is_empty() else null
	var by_id: Customer = CustomerRegistry.get_customer(sel)
	if by_id == null:
		push_warning("[EventManager] modifier customer_id not found: %s" % sel)
	return by_id


func _pump_queue() -> void:
	if not GameState.run_active:
		return  # ending modal owns the screen — no event modals behind/over it
	if _active_event_id != "":
		return
	if _queue.is_empty():
		return
	var next: GameEvent = _queue.pop_front()
	_active_event_id = next.id
	_active_event = next
	if OS.is_debug_build():
		print("[EventManager] Modal requested: %s" % next.id)
	EventBus.modal_requested.emit(next)


# --- JSON loader ---

func _load_all_events_from_disk() -> void:
	var dir := DirAccess.open(EVENTS_DIR)
	if dir == null:
		push_warning("[EventManager] events dir missing: %s" % EVENTS_DIR)
		return
	var loaded: int = 0
	dir.list_dir_begin()
	var filename: String = dir.get_next()
	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".json"):
			# ev_debug_* are placeholder/test events ([DEBUG] markers, nonexistent
			# characters). Keep the files as fixtures but never load them into the
			# live pool — they leaked into normal play (e.g. a "çalışan event"i with
			# zero employees, before any build / after ship). Faz 1 bug 1.4.
			if filename.begins_with("ev_debug_"):
				pass
			elif _load_one(EVENTS_DIR + filename):
				loaded += 1
		filename = dir.get_next()
	dir.list_dir_end()
	if OS.is_debug_build():
		print("[EventManager] Loaded %d events from %s" % [loaded, EVENTS_DIR])


func _load_one(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[EventManager] Failed to open %s (err %d)" % [path, FileAccess.get_open_error()])
		return false
	var content: String = file.get_as_text()
	var parsed: Variant = JSON.parse_string(content)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("[EventManager] JSON parse failed: %s" % path)
		return false
	var ev: GameEvent = _build_event_from_dict(parsed)
	if ev == null:
		push_error("[EventManager] Event build failed: %s" % path)
		return false
	if _all_events.has(ev.id):
		push_warning("[EventManager] Duplicate event id, last wins: %s" % ev.id)
	_all_events[ev.id] = ev
	# Optional "allowed_hours": [start, end] (inclusive; start > end wraps
	# midnight). Parsed into the manager-side dict — see _hour_windows above.
	var window_raw: Variant = parsed.get("allowed_hours", null)
	if window_raw is Array and (window_raw as Array).size() == 2:
		_hour_windows[ev.id] = [int(window_raw[0]), int(window_raw[1])]
	elif window_raw != null:
		push_warning("[EventManager] allowed_hours malformed (want [start, end]) in %s" % path)
	return true


func _build_event_from_dict(d: Dictionary) -> GameEvent:
	if not d.has("id") or String(d["id"]) == "":
		push_error("[EventManager] Event JSON missing id")
		return null
	var ev := GameEvent.new()
	ev.id = String(d.get("id", ""))
	ev.category = String(d.get("category", "reactive"))
	ev.title = String(d.get("title", ""))
	ev.subtitle = String(d.get("subtitle", ""))
	ev.illustration_path = String(d.get("illustration_path", ""))
	ev.character_id = String(d.get("character_id", ""))
	ev.body_text = String(d.get("body_text", ""))
	ev.trigger_conditions = d.get("trigger_conditions", []) as Array
	ev.cooldown_days = int(d.get("cooldown_days", 0))
	ev.one_shot = bool(d.get("one_shot", false))
	ev.priority = int(d.get("priority", 0))
	var tags_raw: Array = d.get("tags", []) as Array
	for t in tags_raw:
		ev.tags.append(String(t))
	var choices_raw: Array = d.get("choices", []) as Array
	for cdict in choices_raw:
		if typeof(cdict) != TYPE_DICTIONARY:
			continue
		var c := EventChoice.new()
		c.label = String(cdict.get("label", ""))
		c.modifiers = cdict.get("modifiers", []) as Array
		c.unlock_condition = cdict.get("unlock_condition", {}) as Dictionary
		c.unlock_reason_text = String(cdict.get("unlock_reason_text", ""))
		ev.choices.append(c)
	return ev
