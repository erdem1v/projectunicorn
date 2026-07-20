class_name PhaseGateSystem
extends RefCounted

# Phase Transition Engine — daily tick slot 8 per docs/ENDGAME_DESIGN.md §2.
#
# Gate = systemic: this system evaluates the current phase's exit condition
# daily; on satisfy it LATCHES (phase_gate_ready + pending_next_phase), emits
# phase_gate_reached, and queues a high-priority deterministic Frank scene.
# Transition = played: the phase only changes when the player confirms inside
# that scene → GameState.advance_phase() (the single write seam).
#
# Ratchet (§2.3): once open, a gate never re-locks; conditions are never
# re-evaluated after the latch. Subgenre-agnostic by construction: conditions
# run through EventManager.is_condition_met(), which reads GameState/registry
# state — B2C bar-fill and B2B signature feed the same evaluator (this kills
# the old _check_traction B2C-branch bug architecturally).
#
# Static (FinanceSystem pattern); the only system-side state is the cached
# Frank scene (_gate_event) — a single instance so reminders re-surface the
# SAME GameEvent and EventManager's dedupe makes stacking impossible (§7.10).
# All persistent/serialized state lives on GameState (§7.9).

const REMIND_INTERVAL_DAYS := 5  # working value (§2.4)

# Gate table (§2.2). Conditions use EventManager.is_condition_met() vocabulary;
# numeric values are working placeholders (§10 — numbers last).
const GATES := [
	{
		"from": 1, "to": 2,
		"event_id": "ev_phase_gate_traction",
		"conditions": [
			{"type": "mvp_shipped", "value": true},        # first product shipped
			{"type": "customer_count_min", "value": 1},    # first real customer (B2C record or B2B account)
			{"type": "mrr_above", "value": 0},             # MRR > 0
		],
		"title": "Traction zamanı",
		"bodies": [
			"Frank ekrandaki rakamları çeviriyor, acele etmiyor.\n\n\"Bir şey sattın. Demek ki alan var. Şimdi soru şu: tekrar yapabilir misin?\"\n\nTraction fazı vites değiştirmek demek: ölçek baskısı, churn, daha büyük masalar. Geri dönüşü yok — zaten geriye bakan da yok.",
			"Frank kapıda, ceketi hâlâ üstünde.\n\n\"Hâlâ buradayız. Rakamlar hâlâ aynı şeyi söylüyor. Rakipler beklemiyor, biliyorsun.\"",
			"Frank bu sefer oturmuyor bile.\n\n\"Beklemek de bir karar. Kirasını sen ödüyorsun.\"",
		],
	},
	{
		"from": 2, "to": 3,
		"event_id": "ev_phase_gate_series_a",
		"conditions": [
			# mrr_above is strict ">" so target-1 ≡ "MRR ≥ TRACTION_MRR_TARGET" —
			# single source SalesSystem.TRACTION_MRR_TARGET (UI traction bar reads the same).
			{"type": "mrr_above", "value": SalesSystem.TRACTION_MRR_TARGET - 1},
			{"type": "brand_above", "value": 24},          # brand ≥ 25 (working floor; calibration item)
		],  # runway deliberately NOT a condition (§2.2 — deadlock; low runway feeds pitch odds instead)
		"title": "Series A masası",
		"bodies": [
			"Frank telefonunu ters çevirip masaya koyuyor. Ciddi olduğunda yapar bunu.\n\n\"MRR tutuyor, marka ayakta. Series A avı açık. Runway'in dar mı geniş mi — girebilirsin, ama masada kokusunu alırlar.\"\n\nBundan sonrası saatli bir av: pitch takvimi ve runway, ikisi de sayacak.",
			"Frank pencereden dışarı bakıyor.\n\n\"Masalar sonsuza kadar açık kalmaz. Metrikler bugün iyi; yarını kimse garanti etmiyor.\"",
			"Frank bu sefer oturmuyor bile.\n\n\"Beklemek de bir karar. Kirasını sen ödüyorsun.\"",
		],
	},
	# Phase 3 has no exit gate — the run resolves through terminals (§2.2 Gate 3).
]

# The ONE pending transition scene (§7.10). Built when a gate opens; reminders
# re-enqueue this same instance. Cleared when the gate resolves (advance) or
# the run ends (EventManager.flush_queue drops the queued reference; the cache
# itself is reset on the next gate open / initialize_run via a fresh process).
static var _gate_event: GameEvent = null


static func daily_tick() -> void:
	if not GameState.run_active:
		return
	if GameState.phase_gate_ready:
		_tick_reminder()  # ratchet: gate stays open, conditions never re-checked
		return
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		return
	for c in gate.conditions:
		if not EventManager.is_condition_met(c):
			return
	_open_gate(gate)


static func _open_gate(gate: Dictionary) -> void:
	GameState.phase_gate_ready = true
	GameState.pending_next_phase = int(gate.to)
	EventBus.phase_gate_reached.emit(int(gate.to))
	GameState.set_flag("gate_prompt_day", GameState.day)
	GameState.set_flag("gate_declines", 0)
	GameState.submit_month_highlight(
		"%s kapısı açıldı" % _phase_display_name(int(gate.to)), 70)  # AYIN OLAYI (Spec 3 §4)
	_gate_event = _build_gate_event(gate)
	if OS.is_debug_build():
		print("[PhaseGateSystem] Gate open: phase %d → %d" % [int(gate.from), int(gate.to)])
	if GameState.shutter_days_left >= 0:
		return  # §7.4: Frank can't say "hazırsın, büyü" ve "kepenk iniyor" aynı anda
	EventManager.enqueue_front(_gate_event)


static func _tick_reminder() -> void:
	if _gate_event == null:
		return
	if GameState.shutter_days_left >= 0:
		return  # held while the Kepenk runs (§7.4); on_shutter_cleared re-prompts
	if GameState.day - int(GameState.get_flag("gate_prompt_day", 0)) < REMIND_INTERVAL_DAYS:
		return
	GameState.set_flag("gate_prompt_day", GameState.day)
	_refresh_gate_copy()
	EventManager.enqueue_front(_gate_event)  # no-op if still queued/active (dedupe)


static func on_gate_declined() -> void:
	# "Henüz değil" — no penalty (§2.4); escalation index advances, reminder
	# clock re-arms. Called via the "phase_gate_decline" event modifier.
	GameState.set_flag("gate_declines", int(GameState.get_flag("gate_declines", 0)) + 1)
	GameState.set_flag("gate_prompt_day", GameState.day)


# --- Shutter interplay (§7.4) — called by EndingsSystem ---

static func on_shutter_started() -> void:
	# Pull a queued (not yet shown) gate scene; the latch survives.
	if _gate_event != null:
		EventManager.remove_queued(_gate_event.id)


static func on_shutter_cleared() -> void:
	# "Shutter resolves ... then the transition returns" — promptly, not after
	# the reminder cadence catches up.
	if GameState.phase_gate_ready and _gate_event != null:
		GameState.set_flag("gate_prompt_day", GameState.day)
		EventManager.enqueue_front(_gate_event)


# --- Debug (F1) ---

static func debug_force_gate() -> void:
	# Force-open the current phase's gate regardless of conditions.
	if GameState.phase_gate_ready:
		return
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		print("[PhaseGateSystem] debug_force_gate: no gate for phase %d" % GameState.phase)
		return
	_open_gate(gate)


# --- Helpers ---

static func _gate_for_phase(phase: int) -> Dictionary:
	for gate in GATES:
		if int(gate.from) == phase:
			return gate
	return {}


static func _phase_display_name(phase: int) -> String:
	# TopBar display names (top_bar.gd PHASE_NAMES) — keep in sync.
	var names := ["Bootstrap", "Traction", "Series A"]
	return names[clampi(phase - 1, 0, names.size() - 1)]


static func _build_gate_event(gate: Dictionary) -> GameEvent:
	# Synthetic deterministic beat (ship-moment pattern) — reuses EventModal
	# (§2.4, no new UI). Not one_shot: the same cached instance re-surfaces via
	# reminders; one-shot enforcement is the phase_gate_ready latch itself.
	var ev: GameEvent = GameEvent.new()
	ev.id = String(gate.event_id)
	ev.category = "reactive"
	ev.title = String(gate.title)
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = String((gate.bodies as Array)[0])
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "phase_gate"]
	ev.trigger_conditions = []
	var advance: EventChoice = EventChoice.new()
	advance.label = "Hazırız — geçelim"
	advance.modifiers = [{"type": "advance_phase"}]  # zero economic delta (§2.1)
	advance.unlock_condition = {}
	advance.unlock_reason_text = ""
	var decline: EventChoice = EventChoice.new()
	decline.label = "Henüz değil"
	decline.modifiers = [{"type": "phase_gate_decline"}]
	decline.unlock_condition = {}
	decline.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(advance)
	choices.append(decline)
	ev.choices = choices
	return ev


static func _refresh_gate_copy() -> void:
	# Escalating dryness (§2.4). Safe to mutate: reminders only fire from the
	# daily tick, which never runs while a modal has the tree paused.
	if _gate_event == null:
		return
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		return
	var bodies: Array = gate.bodies as Array
	var idx: int = clampi(int(GameState.get_flag("gate_declines", 0)), 0, bodies.size() - 1)
	_gate_event.body_text = String(bodies[idx])
