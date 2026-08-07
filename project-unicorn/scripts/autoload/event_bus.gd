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
signal speed_change_requested(speed: int)  # 0=pause, 1=1x, 2=2x, 3=3x, 4=4x
# ODA rework: "" = sekme yok, oda görünür (varsayılan durum). Sekme id'leri:
# "product", "hr", "finance", "sales", "ops", "rnd", "personal", "events".
signal tab_changed(tab_id: String)
# Kâğıt deep-link'i (ODA rework §5.3): mount edilmiş Finance sekmesine alt sayfa
# seçtirir ("ozet"|"yatirim"). tab_changed("finance") emit'i SENKRON mount eder,
# ardışık emit bu yüzden güvenli — handler bağlanmış olur.
signal finance_subpage_requested(page_id: String)

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
# Localization (Package 5): emitted by the Localization autoload when the language
# changes so live surfaces re-translate (e.g. TopBar runway). Payload = locale "tr"/"en".
signal language_changed(locale: String)

# --- Character signals (§13.2) ---
signal character_added(character_id: String)
signal character_removed(character_id: String)
signal morale_changed(character_id: String, new_morale: int)
# Emitted at the END of HRSystem.daily_tick, once all seven HR steps have settled — the HR
# tab's day-boundary repaint hook. Exactly the same reason build_progress_changed exists:
# day_advanced fires inside GameState.advance_day(), which TimeManager calls BEFORE the daily
# ticks dispatch, so a repaint on day_advanced would read PRE-tick HR state (Atlas strip one
# day behind, arriving candidate files invisible until the next day). No payload — a repaint
# hook, not a data channel; every number is still read from the owning system.
signal hr_day_processed()

# Emitted at the END of NewsFeedSystem.daily_tick (slot 7), once the day's news lines are
# composed — the ticker's day-boundary repaint hook. Same rationale as hr_day_processed:
# day_advanced fires BEFORE the daily ticks dispatch, so a feed repaint on day_advanced
# would read yesterday's stream. No payload — read NewsFeedSystem.get_stream().
signal news_stream_changed()

# --- Customer signals (§13.2) ---
signal customer_added(customer_id: String)
signal customer_removed(customer_id: String)
signal customer_mrr_changed(customer_id: String, new_mrr: int)
signal customer_seats_changed(customer_id: String, new_seats: int)
signal customer_satisfaction_changed(customer_id: String, new_satisfaction: int)

# --- B2B lifecycle / relationship signals (B2B Sales System) ---
# health/phase changes drive the portfolio health display + the churn countdown
# ("Churn'e ~N gün"); churned/expanded are discrete account moments; assigned
# tracks Customer-Success delegation.
signal customer_health_changed(customer_id: String, phase: String)
signal customer_churned(customer_id: String)
signal customer_expanded(customer_id: String, new_seats: int)
signal customer_assigned(customer_id: String, employee_id: String)
# Promise tracking (B2B Sales System §C). "Söz ver" / a CS escalation create a
# promise; a Product feature ship keeps it, a passed deadline breaks it.
signal promise_created(promise_id: String)
signal promise_kept(promise_id: String)
signal promise_broken(promise_id: String)

# --- Event signals (§13.2) ---
signal event_triggered(event_id: String)
signal event_resolved(event_id: String, choice_index: int)
signal modal_requested(event: GameEvent)

# --- Build / product signals ---
# Emitted by ProductSystem whenever current_phase transitions. BuildHUDPanel
# subscribes to drive its faz-aware paint instead of polling active_build.
signal build_phase_changed(new_phase: String)
# CANLANDI (player-gated iterasyon restore, 2026-08): tasarım bandı dolunca ve her
# ek tur bitince true, oyuncu karar verince false. Emitter'lar ProductSystem'de
# (_pend_iteration_decision / advance_iteration / enter_development); BuildHUDPanel
# bağlanır, creation_flow zaten build_progress_changed üzerinden repaint oluyor.
signal build_iteration_decision_pending(pending: bool)
# Emitted at the END of ProductSystem.daily_tick (after the phase tick advances
# its counters), so build progress bars repaint with the post-tick value.
# day_advanced fires BEFORE the tick decrements the counter, which made the bar
# lag a day and read empty on day 1 then jump (Faz 1 bug 1.1).
signal build_progress_changed()

# --- Rival signals (Product Lifecycle Part 1) ---
# Emitted by RivalRegistry. rival_added on seed; rival_status_changed when a
# rival's display band flips; rival_advanced once per day after advance_all so
# the ODA board league repaints (RightPanel retired — ODA rework 2026-08-06).
signal rival_added(rival_id: String)
signal rival_status_changed(rival_id: String, status: String)
signal rival_advanced()

# --- PostShip / sales signals ---
# Prospect pool changes (Sales tab repaints). Mirrors customer_added/removed.
signal prospect_added(prospect_id: String)
signal prospect_removed(prospect_id: String)
# Sales tab "Görüşmeye git" → main.gd routes to B2BPitchMeeting, which renders the
# pitch in the shared MeetingScene (pause on open, restore on close).
signal pitch_requested(prospect_id: String)
# Emitted by B2BPitchMeeting when the pitch flow ends (any outcome) so the Sales/Hunt
# tabs repaint. Speed restore + scene teardown happen in main.gd's dialogue close path.
signal pitch_finished()
# Frank's advisory line — updated by intro/customer events/traction. Its RightPanel
# home retired with the ODA rework; the mentor surfaces read it now.
signal mentor_advisory_changed(text: String)

# Live ticker line. The ONLY non-modal notification channel: a system pushes one line and
# NewsTicker scrolls it ahead of the ambient pool. `source` is the attribution shown in
# accent ("Atlas Seçme & Yerleştirme", "İK"). Use this for beats that must NOT interrupt
# the player — candidate files arriving, an employee going on leave.
signal headline_added(source: String, text: String)

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
signal term_table_requested(vc_id: String)      # Finance>Yatırım "Masaya otur" / deal-prompt → main mounts the table (Spec 6)
signal sheet_walked(vc_id: String)              # a table walk destroyed a sheet — HuntTab repaints (Spec 6)

# --- Debug signals (OS.is_debug_build only; emitter game_shell.gd) ---
# Shift+F4 re-triggers onboarding on a running game (screenshot/mockup capture).
# main.gd tears down the shell and remounts OnboardingFlow. No-op in release.
signal debug_onboarding_retrigger_requested
