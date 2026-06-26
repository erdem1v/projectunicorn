extends Node

# Event pipeline per TECH_SPEC §6.1 + §8.2 slot 6.
#
# Loads GameEvent resources from data/events/reactive/*.json at _ready.
# Each daily tick (slot 6, after Finance) walks all loaded events, filters by
# eligibility (trigger conditions + cooldown + one-shot history), queues
# eligible events sorted by priority desc, and emits modal_requested for the
# top of the queue if no modal is currently active. The modal is mounted by
# main.gd (deferred consumer pattern — EventManager has no scene dependency).
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


func _ready() -> void:
	_load_all_events_from_disk()


# --- TimeManager slot 6 entry point ---

func daily_tick() -> void:
	var newly_eligible: Array[GameEvent] = []
	for ev in _all_events.values():
		if _is_eligible(ev):
			newly_eligible.append(ev)
	if newly_eligible.is_empty():
		_pump_queue()  # in case prior tick left something queued
		return
	# Group by priority (descending), shuffle each group, concatenate.
	# Uses the global seeded RNG per TECH_SPEC §10.4 (bare randf / shuffle).
	var by_priority: Dictionary = {}
	for ev in newly_eligible:
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
	newly_eligible = ordered
	for ev in newly_eligible:
		if _queue.has(ev) or ev.id == _active_event_id:
			continue
		_queue.append(ev)
		EventBus.event_triggered.emit(ev.id)
		if OS.is_debug_build():
			print("[EventManager] Eligible: %s" % ev.id)
	_pump_queue()


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
	if event == null:
		push_warning("[EventManager] enqueue called with null event")
		return
	if _queue.has(event) or event.id == _active_event_id:
		return
	_queue.append(event)
	EventBus.event_triggered.emit(event.id)
	_pump_queue()


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

func _is_eligible(ev: GameEvent) -> bool:
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
	# 5. Trigger conditions (AND logic).
	for c in ev.trigger_conditions:
		if typeof(c) != TYPE_DICTIONARY:
			push_warning("[EventManager] trigger_conditions entry not Dictionary in %s" % ev.id)
			return false
		if not is_condition_met(c):
			return false
	return true


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
			"mrr":
				GameState.set_mrr(GameState.mrr + delta)
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
			"speed_bonus":
				ProductSystem.apply_speed_bonus(int(m.get("days", 0)))
			"quality_bonus":
				ProductSystem.apply_quality_bonus(int(m.get("amount", 0)))
			"ship_active_build":
				ProductSystem.ship_active_build()
			# --- PostShip / sales modifiers (§10: revenue only via played choices) ---
			"add_prospect":
				PitchSystem.spawn_prospect(String(m.get("archetype", "small")), String(m.get("source", "event")))
			"churn_customer":
				# Lose the most-at-risk customer; resync MRR immediately so the drop is felt now.
				var victim: Customer = CustomerRegistry.get_lowest_satisfaction_customer()
				if victim != null:
					CustomerRegistry.remove(victim.id)
					GameState.set_mrr(CustomerRegistry.get_total_mrr())
			"customer_mrr_delta":
				# Expansion: grow an existing B2B account's MRR.
				var b2bs: Array[Customer] = CustomerRegistry.get_by_market("b2b")
				if not b2bs.is_empty():
					var tgt: Customer = b2bs[0]
					CustomerRegistry.set_mrr(tgt.id, tgt.mrr + delta)
					GameState.set_mrr(CustomerRegistry.get_total_mrr())
			"satisfaction_delta":
				var sc: Customer = CustomerRegistry.get_lowest_satisfaction_customer()
				if sc != null:
					sc.satisfaction = clampi(sc.satisfaction + delta, 0, 100)
					sc.update_health_from_satisfaction()
			"audience_delta":
				GameState.set_flag("b2c_audience", maxi(0, int(GameState.get_flag("b2c_audience", 0)) + delta))
			"open_paid_tier":
				SalesSystem.open_b2c_paid_tier(int(m.get("price", 15)), float(m.get("initial_pct", 0.1)))
			"convert_audience":
				var n: int = int(m.get("count", 0))
				if m.has("pct"):
					n = int(round(int(GameState.get_flag("b2c_audience", 0)) * float(m.get("pct", 0.0))))
				SalesSystem.convert_b2c_audience(n, String(m.get("source", "decision")))
			"mentor_advisory":
				EventBus.mentor_advisory_changed.emit(String(m.get("text", "")))
			_:
				push_warning("[EventManager] Unknown modifier type: %s" % t)


func _pump_queue() -> void:
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
			if _load_one(EVENTS_DIR + filename):
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
