# Endgame Pre-Transition Audit — 2026-07-13

Read-only audit per ENDGAME_DESIGN.md §9 step 2, run before Spec 1 (Phase Transition Engine)
and Spec 2 (Endings Evaluator) implementation. Scope: TimeManager slots 8/9, GameState.phase
writability, `_check_traction` B2C branch, EventBus signal inventory, event-queue injection
seams, modal/pause patterns, TopBar surface, Frank infrastructure, debug hooks.

## 1. TimeManager (`scripts/autoload/time_manager.gd`)

- Tick driver: `_process(delta)` accumulating `_in_game_hours`; boundaries drained in
  `_drain_boundaries()` (L75-103). Day rollover: hour-0 hourly tick → `GameState.advance_day()`
  → `_dispatch_daily_tick()` (L128-148).
- **Slots 8/9 already exist as `pass` stubs, last in dispatch order:** `_tick_phase_check()`
  (L207) and `_tick_endings_check()` (L211). Dispatch comment (L131-132) already states
  "Endings last because it can terminate the run." Stub TODOs referenced outdated
  PROJECT_SPEC §3.3/§3.5 conditions — ENDGAME_DESIGN.md overrides.
- **No run-halt mechanism exists.** No `run_active`, no game-over gate; the only thing that
  stops the clock is pause (`get_tree().paused` at speed 0, `_on_speed_change_requested`
  L115-123). An EndingsSystem must introduce the stop flag AND make `_process` /
  dispatchers / speed-change honor it.
- Header slot-count comments stale: says 9 daily / 2-3 hourly; actual 10 daily (rivals
  inserted later) / 4 hourly.

## 2. GameState (`scripts/autoload/game_state.gd`)

- `phase: int = 1` (1=Bootstrap, 2=Traction, 3=Series A Hunt), L33.
- `set_phase()` (L75-77) clamps 1..3 and emits `EventBus.phase_changed` — **zero callers
  anywhere in the codebase.** The phase pipe (signal + TopBar 3-dot indicator + `"phase"`
  event condition in EventManager) is fully wired end-to-end but has no driver: phase is
  frozen at 1 for the entire run.
- Absent fields: `phase_gate_ready`, `run_active`, `series_a_closed`, ending id, shutter
  counter — the endgame state surface is greenfield. Extensible seam: `flags: Dictionary`
  + `set_flag/get_flag/has_flag` (L81-91).
- `initialize_run()` (L142-177) is the single reset seam (direct field writes, pre-shell).
- Runway is derived, not stored: `get_runway_months()` (L101-106), INF on non-negative flow.
- Namespace quirk: `GameState.phase` (int, run macro-phase) vs `FeatureBuild.current_phase`
  (String, build lifecycle) + `EventBus.build_phase_changed(String)` — two unrelated "phase"
  machines. Specs must disambiguate.

## 3. Traction gate — `_check_traction` B2C-branch bug (CONFIRMED)

- `sales_system.gd:288-294` `_check_traction()` sets flag `ready_for_traction` when
  `traction_progress() >= 1.0`. Its ONLY call site is `hourly_tick` L107, inside
  `if market == "b2c":` (L104). No B2B call site; `daily_tick` doesn't call it either.
  **B2B runs can never become traction-ready.**
- `traction_progress()` (L282-285) itself is market-agnostic:
  `clampf(maxf(mrr/5000, customers/8), 0, 1)` — targets `TRACTION_MRR_TARGET := 5000`,
  `TRACTION_CUSTOMER_TARGET := 8` (L29-30).
- `ready_for_traction` readers: `product_tab.gd:1266` (post-ship chip),
  `data/events/reactive/ev_ps_traction_ready.json` (one-shot flag_set beat, priority 9 —
  **narrative-only; never calls `set_phase`**).
- Fix per canon: the subgenre-agnostic gate evaluator in slot 8 replaces this mechanism
  entirely; `_check_traction` is deleted, `ev_ps_traction_ready.json` retired (Erdem
  2026-07-13: delete outright).
- Correction of an earlier suspicion: `mvp_market_type` IS written at ship time —
  `product_system.gd:487`. No gap there.

## 4. Ship / customer / economy signal seams (gate-condition inputs)

- First product shipped: `flags["mvp_shipped"]` (product_system.gd:723) +
  `EventBus.build_phase_changed.emit("shipped")` (product_system.gd:736). No dedicated
  `product_shipped` signal.
- B2B first customer: `PitchSystem._resolve_outcome` (pitch_system.gd:246-284) → SIGNED →
  `SalesSystem.add_b2b_customer` (sales_system.gd:235-252) → CustomerRegistry add
  (`customer_added`) + `GameState.set_mrr`.
- B2C: aggregate `co_b2c_userbase` record; `_derive_b2c_mrr` (sales_system.gd:181-190)
  derives paying users from audience × conversion; requires `b2c_paid_tier_open`. MRR sink:
  `_mrr_bridge()` = `GameState.set_mrr(CustomerRegistry.get_total_mrr())`.
- Brand: mutated only via event modifiers (event_manager.gd:362-363), no system ticks it.
- **Scandal: no state field exists** — only an event category string (`event.gd:29`);
  `scandal_breaking` signal referenced in a news_ticker.gd comment is NOT declared in
  event_bus.gd. Endings needing scandal state get RESERVED debug-settable fields.
- Daily burn/cash: `FinanceSystem.daily_tick()` (finance_system.gd:38-56) is the single
  daily cash mutation, slot 5 — runs before slots 8/9, so the endings scan sees the day's
  net applied.

## 5. EventBus inventory (`scripts/autoload/event_bus.gd`, 84 lines)

Relevant existing signals: `cash_changed`, `mrr_changed`, `burn_changed`, `brand_changed`,
`reputation_changed`, `day_advanced`, `hour_changed`, **`phase_changed(new_phase: int)`**,
`runway_recalculated`, `speed_change_requested`, `confirm_requested(config)`,
`event_triggered`, `event_resolved`, `modal_requested(GameEvent)`, `build_phase_changed`,
`customer_added/removed`, `pitch_requested/finished`, `mentor_advisory_changed`.
**No gate / run-ended / shutter signals exist** — Spec 1/2 add `phase_gate_reached`,
`run_ended`, `shutter_changed`.

## 6. Event queue & modal/pause patterns

- `event_manager.gd`: `enqueue(event)` (L171-182) is the documented synthetic-event
  injection point (ship-moment precedent product_system.gd:744-793) — but it appends to
  TAIL; the priority sort (L111) applies only to eligibility batches. A high-priority
  deterministic Frank scene needs a push-front variant. No flush/remove-by-id APIs exist.
- `_pump_queue()` (L474): one modal at a time via `modal_requested`. Dedupe on enqueue is
  object/id-based (L178) — a cached single GameEvent instance makes reminder stacking
  impossible.
- `_apply_modifiers()` (L350-471) precedent for system-calling modifier types:
  `"ship_active_build"` (L428). `is_condition_met()` (L201-261) is the shared,
  subgenre-agnostic condition vocabulary (mvp_shipped, customer count, MRR, brand, phase…).
- Pause pattern: every modal mount in main.gd emits `speed_change_requested(0)`; speed
  restored on dismiss only if `!EventManager.has_pending()`. All modal .tscn set
  `process_mode = 3` (ALWAYS). Modal host: `GameShell/ModalLayer` (CanvasLayer).

## 7. UI surfaces & Frank

- TopBar (`top_bar.gd`): phase indicator already wired (`PHASE_NAMES` + 3-dot bar,
  `_on_phase_changed` L151, driven by `phase_changed`). Kepenk/shutter label belongs in
  TimeGroup next to DayLabel, following the `_on_*` handler pattern.
- Frank: `char_mentor_frank` "Frank Köseoğlu" via `CharacterRegistry.ensure_mentor()`;
  RightPanel advisory line (`mentor_advisory_changed`); MentorIntroModal; Frank-voiced
  events (ev_ps_frank_intro_b2b). No standalone dialogue-tree system — gate scenes reuse
  EventModal per canon §2.4.
- Debug keys: only F12 (main.gd:245-257, debug-build-gated pre-shell skip). game_shell.gd
  `_input` (process_mode ALWAYS) owns Space pause-toggle — natural home for endgame F-keys.
  F1–F11 free.
- Month-End Summary: nothing exists; `DAYS_PER_MONTH := 30` used only for arithmetic.

## 8. Conclusions feeding Specs 1–2

1. Slot seams exist and are correctly ordered — implementation fills stubs, no dispatch surgery.
2. Phase plumbing (signal → TopBar) works; only the driver (gate engine + `advance_phase()`
   seam) is missing.
3. Run termination is greenfield: `run_active` field + guards in TimeManager `_process`,
   both dispatchers, and speed-change handler; EventManager needs enqueue/pump guards +
   `flush_queue()`.
4. The B2B traction bug is killed architecturally by evaluating gate conditions from
   GameState/registry state in slot 8 (daily), not from inside SalesSystem's B2C branch.
5. Frank gate scene: cached single GameEvent + new `enqueue_front()` satisfies both the
   high-priority requirement and the no-duplicate-reminders ledger rule.
