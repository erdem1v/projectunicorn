extends Node

# Global signal hub per TECH_SPEC §13.
# Singletons and systems emit signals here; scenes connect to update themselves.
# Scenes connect on tree-enter, disconnect on tree-exit (§13.3).

# --- State change signals (§13.2) ---
signal cash_changed(new_value: int)
signal mrr_changed(new_value: int)
signal burn_changed(new_value: int)
signal brand_changed(new_value: int)
signal reputation_changed(new_value: int)
signal day_advanced(new_day: int)
signal hour_changed(hour: int)            # 0-23, emitted every in-game hour boundary
signal phase_changed(new_phase: int)
signal runway_recalculated(months: float)

# --- UI / time signals (§13.2) ---
signal speed_change_requested(speed: int)  # 0=pause, 1=1x, 2=2x, 3=4x
signal tab_changed(tab_id: String)  # "product", "hr", "finance", "sales", "ops", "rnd", "personal", "events"

# --- Character signals (§13.2) ---
signal character_added(character_id: String)
signal character_removed(character_id: String)
signal morale_changed(character_id: String, new_morale: int)

# --- Customer signals (§13.2) ---
signal customer_added(customer_id: String)
signal customer_removed(customer_id: String)
signal customer_mrr_changed(customer_id: String, new_mrr: int)

# --- Event signals (§13.2) ---
signal event_triggered(event_id: String)
signal event_resolved(event_id: String, choice_index: int)
signal modal_requested(event: GameEvent)

# --- Build / product signals ---
# Emitted by ProductSystem whenever current_phase transitions. BuildHUDPanel
# subscribes to drive its faz-aware paint instead of polling active_build.
signal build_phase_changed(new_phase: String)
# Emitted when an iteration's day counter hits zero and the player needs to
# pick "advance" or "enter_development". BuildHUDPanel flips its buttons
# active on this; iteration ticks keep flowing (no auto-pause).
signal build_iteration_decision_pending(pending: bool)
# Emitted at the END of ProductSystem.daily_tick (after the phase tick advances
# its counters), so build progress bars repaint with the post-tick value.
# day_advanced fires BEFORE the tick decrements the counter, which made the bar
# lag a day and read empty on day 1 then jump (Faz 1 bug 1.1).
signal build_progress_changed()

# --- PostShip / sales signals ---
# Prospect pool changes (Sales tab repaints). Mirrors customer_added/removed.
signal prospect_added(prospect_id: String)
signal prospect_removed(prospect_id: String)
# Sales tab "Pitch" button → main.gd mounts PitchDialogueModal (same lifecycle
# as modal_requested: pause on open, restore on close).
signal pitch_requested(prospect_id: String)
# Emitted by PitchDialogueModal when the pitch flow ends (any outcome) so main.gd
# frees the modal and restores speed.
signal pitch_finished()
# Frank's RightPanel advisory line — updated by intro/customer events/traction.
signal mentor_advisory_changed(text: String)
