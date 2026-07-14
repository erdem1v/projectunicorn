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

# --- Settings / audio signals ---
# Gear button (below the left tab column) → main.gd mounts SettingsModal
# (same lifecycle as modal_requested: pause on open, restore on close).
signal settings_requested
# Genel amaçlı onay modalı isteği (main.gd ModalLayer'a ConfirmModal mount eder).
# config: {title, body, confirm_text, cancel_text, on_confirm: Callable}
# İlk kullanıcı: Tracker Card build-iptal çarpısı.
signal confirm_requested(config: Dictionary)
# AudioManager emits these when the prefs change so any UI can reflect state
# without polling. music_volume is linear 0..1.
signal music_enabled_changed(enabled: bool)
signal music_volume_changed(volume: float)

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
# DEPRECATED (Build Tracker Card, dört-faz akış): emitter YOK — iterasyonlar
# otomatik döner, karar-bekleme modeli kalktı. Declared kalıyor (en az churn);
# yeni kod bağlanmasın.
signal build_iteration_decision_pending(pending: bool)
# Emitted at the END of ProductSystem.daily_tick (after the phase tick advances
# its counters), so build progress bars repaint with the post-tick value.
# day_advanced fires BEFORE the tick decrements the counter, which made the bar
# lag a day and read empty on day 1 then jump (Faz 1 bug 1.1).
signal build_progress_changed()

# --- Rival signals (Product Lifecycle Part 1) ---
# Emitted by RivalRegistry. rival_added on seed; rival_status_changed when a
# rival's display band flips; rival_advanced once per day after advance_all so
# RightPanel repaints its ACTIVE RIVALS section.
signal rival_added(rival_id: String)
signal rival_status_changed(rival_id: String, status: String)
signal rival_advanced()

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

# --- Endgame signals (ENDGAME_DESIGN.md §2/§3) ---
# Gate condition satisfied (slot 8). Phase has NOT changed yet — the transition
# is played inside the Frank scene; phase_changed fires only after advance_phase().
signal phase_gate_reached(next_phase: int)
# Terminal reached (slot 9 scan or Class A instant). ending_data: snapshot dict
# built by EndingsSystem._build_ending_data (title/tone/frank_line + run stats).
signal run_ended(ending_id: String, ending_data: Dictionary)
# Kepenk counter (§4.3). -1 = inactive/cleared; 7..0 = counting. TopBar listens.
signal shutter_changed(days_left: int)
# Month-End Summary (Spec 3 / §1.1): emitted by MonthSummarySystem (daily slot
# 10) when a calendar month closes. summary_data shape is documented on
# MonthSummarySystem._build_summary_data. main.gd mounts MonthSummaryModal.
signal month_ended(summary_data: Dictionary)

# --- Cinematic dialogue shell (Spec 5) — MeetingScene / FrankPopup ---
# view_state is the dict populate() consumes (contract on MeetingScene). For now these
# fire from debug fixtures (game_shell Shift+F2 / Shift+F3) and main.gd mounts the scene
# into ModalLayer; Spec 4's PitchSystem will emit meeting_scene_requested with a real
# view state and connect its own listener to the scene's choice_selected signal.
signal meeting_scene_requested(view_state: Dictionary)
signal frank_popup_requested(view_state: Dictionary)

# --- VC Pitch / Series A Hunt signals (Spec 4 / VC_PITCH_DESIGN.md §7) ---
# Roster + Teklifler panel repaint from these; TopBar chip from offer_countdown_changed.
signal sheet_granted(vc_id: String)             # term sheet delivered into active_sheets
signal sheet_expired(vc_id: String)             # validity clock hit 0 — NOT a rejection
signal callback_ready(vc_id: String)            # callback condition met; door reopened
signal meeting_day(vc_id: String)               # pending meeting's day arrived (prompt enqueued)
signal meeting_requested(vc_id: String)         # Hunt "TOPLANTI İSTE" → VCPitchSystem schedules
signal offer_countdown_changed(days_left: int)  # min sheet validity ≤ threshold; -1 = hide chip

# --- Debug signals (OS.is_debug_build only; emitter game_shell.gd) ---
# Shift+F4 re-triggers onboarding on a running game (screenshot/mockup capture).
# main.gd tears down the shell and remounts OnboardingFlow. No-op in release.
signal debug_onboarding_retrigger_requested
