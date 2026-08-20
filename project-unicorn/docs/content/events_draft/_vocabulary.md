# Event Authoring · Vocabulary (extracted from the engine, 2026-08-19)

**Read this first.** Every node draft under `docs/content/events_draft/` may use only what is listed here. Anything a node wants that is not here is written as `[VOCAB?] <what it wants>` (an effect) or `[COND?] <what it wants>` (a prerequisite). Nothing is invented. Nothing here is wired; this document is an audit of what the engine can execute today, so the director and the rebuild arc can see the distance between the Pool Design (`docs/.md`, EVENT POOL DESIGN v1) and the code.

Source of truth for each table: `scripts/autoload/event_manager.gd`, `scripts/modals/event_modal.gd`, `scripts/data_models/event.gd`, `scripts/data_models/event_choice.gd`, `scripts/autoload/game_state.gd`, `scripts/autoload/event_bus.gd`, `localization/strings.csv`. Line numbers are as of this date; re-check before wiring.

Sections: **a.** effects · **b.** conditions · **c.** slots and targeting · **d.** memory hooks · **e.** trigger-hook map · **f.** legacy-function map · **g.** conventions and known gaps.

---

## a. Effect vocabulary (43 executable modifier types as extracted this morning; the in-flight Build Bar task removes `advance_iteration` and adds `enter_beta`, so the live count is still 43)

Dispatcher: `EventManager._apply_modifiers` (`event_manager.gd:522-761`). Every entry is `{"type": <string>, ...params}`. `delta` is read for every modifier (`:528`) but only the rows that name it use it. Unknown type → `push_warning` and silent no-op (`:760-761`).

What the player sees: `EventModal._describe_modifier` (`event_modal.gd:452-526`) builds one chip per modifier from `EFFECT_*` keys in `strings.csv:1664-1697`. **A type with no row there renders no chip; the card is blind for that effect.** The audit (2026-07-14) counts a hidden cost as a defect. So: a blind type may carry bookkeeping (memory), never a cost.

`{v}` = signed value; money is `$1.234` TR / `$1,234` EN via `Fmt`.

### a.1 Economy

| type | params (default) | changes (seam) | player sees (TR / EN) | notes |
|---|---|---|---|---|
| `cash` | `delta` (0) | `GameState.set_cash(cash+delta)` → `cash_changed`, runway recalculated | `Nakit {v}` / `Cash {v}` | latches `cash_went_negative` if it dips under 0 |
| `brand` | `delta` (0) | `GameState.set_brand`, **clamps 0..100** | `Marka {v}` / `Brand {v}` | chip prints the nominal delta, clamp happens after |
| `reputation` | `delta` (0) | `GameState.set_reputation`, **clamps −10..100** | `İtibar {v}` / `Reputation {v}` | same clamp caveat |
| `mrr` | `delta` | **NO DISPATCHER BRANCH** | `MRR {v}` (chip exists, `event_modal.gd:459`) | **Mismatch #1**: documented as legal in `event_choice.gd:13`, has a chip, does nothing. Treat as `[VOCAB?] mrr` |

### a.2 People / morale

| type | params (default) | changes | player sees | notes |
|---|---|---|---|---|
| `morale` | `character_id` (""), `delta` | employee → `HRMoraleSystem.apply_delta(c, delta, "event")` (trait × Liderlik scaling); non-employee → `CharacterRegistry.set_morale` | `{Ad} {v}` (first name) / `Moral` if id unknown | **Mismatch #2**: chip prints nominal, engine scales. Unknown id → warn + skip |
| `morale_all_employees` | `delta` | broadcast to every employee (incl. on leave) | `Ekip {v}` / `Team {v}` | no targeting |
| `add_character` | `character_data{id (req), character_name, role, category, monthly_salary, equity_pct, morale, loyalty, relationship, trust_score, traits, role_stats, attention_flag}` | `CharacterRegistry.add` | `Yeni ekip üyesi` / `A new teammate` | duplicate id → warn, no-op |
| `hr_departure` | `character_id` (req) | `HRMoraleSystem.confirm_departure` → registry remove, `run_departures++` | `{Ad} ayrılıyor` / `{Name} is leaving` | |
| `hr_overtime_stop` | `department` ("") | `HROvertimeSystem.stop(dept)` | `Ek mesai durur` / `Overtime stops` | |
| `hr_overtime_continue` | `department`, `character_id` | `HROvertimeSystem.note_valve_continued` (per-person, run-lifetime memory; feeds resignation odds) | `Mesai sürer · istifa riski artar` / `Overtime continues · the risk of resignations rises` | |

### a.3 Flags / narration (blind)

| type | params | changes | player sees | notes |
|---|---|---|---|---|
| `set_flag` | `key` (req), `value` (any, may be null) | `GameState.set_flag(key, value)`; no signal | **nothing** | the arc-memory write. Never a cost |
| `mentor_advisory` | `text` ("") | `EventBus.mentor_advisory_changed.emit(text)` → latched line on the Events page / Hunt page | **nothing on the card**; the line appears elsewhere | `text` is a **raw TR literal with no `_en`** → any new use is `[VOCAB?] mentor_advisory key/text_en` (Bilingual Birth Law) |

### a.4 Product / build

| type | params (default) | changes | player sees | notes |
|---|---|---|---|---|
| `dimension_delta` | `axis` ("innovation"), `amount` (0) | `ProductSystem.apply_dimension_delta` (axis validated; invalid → innovation); **no-op if no active build** | `İnovasyon/Kararlılık/Deneyim {v}` via `ProductCatalog.axis_label` | |
| `bug_delta` | `amount` (0) | `ProductSystem.apply_bug_delta` (floor 0) | `Hata {v}` / `Bugs {v}` (sign inverted for colour) | |
| `delay_days` | `days` (0), **+ = slower** | `ProductSystem.apply_speed_bonus(days)`; **no-op without an active build** (`product_system.gd:1153`) | `{v} gün` / `{v} days` | **post-ship this chip lies**: it shows a day cost that nothing pays. Not usable as "founder time" outside a build |
| `speed_bonus` (deprecated) | `days` | same as `delay_days` | `{v} gün` (no neutral at 0) | do not use in new nodes |
| `quality_bonus` (deprecated) | `amount` | innovation delta | `Kalite +{n}` (**hardcodes "+", always green**) | do not use |
| `ship_active_build` | | `ProductSystem.ship_active_build()` (narrative-only) | nothing | |
| `advance_iteration` **(RETIRED)** | | was `ProductSystem.advance_iteration()` | was `Bir tasarım turu · {days} gün` | **retired by the Build Bar task (in flight, 2026-08-19): the dispatcher arm and the `EFFECT_DESIGN_ROUND` chip are gone from the working tree; do not use** |
| `enter_development` | | `ProductSystem.enter_development()` | `Geliştirme başlar` | |
| `enter_beta` **(NEW, Build Bar task)** | | `ProductSystem.enter_beta()` | `Beta başlar` / `Beta begins` (`EFFECT_BETA_BEGINS`) | added by the Build Bar task in the same working tree; confirm at wiring time |

### a.5 Sales / customers

| type | params (default) | changes | player sees | notes |
|---|---|---|---|---|
| `add_prospect` | `archetype` ("small"), `source` ("event") | `PitchSystem.spawn_prospect` → a lead on the sales board | `Yeni aday` / `A new prospect` | **may return null silently** (sector pool exhausted): chip promises, nothing lands. The only "Frank opens a door" effect that exists |
| `churn_customer` | `customer_id` ("" → lowest-satisfaction in the event's market) | B2C: audience −15 %; B2B: `CustomerRegistry.remove` + `run_customers_lost++` + MRR bridge | `Müşteri kaybı` / `A customer lost` | |
| `seats` | `customer_id` ("" → first B2B by insertion), `amount`, `per_seat_mrr` (0) | `set_seats` (+ `set_mrr` if per_seat_mrr) | `Koltuk {v}` | **Mismatch #3a**: the MRR half is invisible |
| `customer_mrr_delta` | `customer_id` ("" → first B2B), `delta` | `CustomerRegistry.set_mrr` (≥0) + bridge | `Müşteri MRR {v}` | |
| `satisfaction_delta` | `customer_id` ("" → lowest-sat in market), `delta` | `set_satisfaction` (0..100) | `Memnuniyet {v}` | |
| `audience_delta` | `delta` | `SalesSystem.add_b2c_audience` (≥0, float) | `Kitle {v}` / `Audience {v}` | |
| `open_paid_tier` | `price` (15), `initial_pct` (dead) | `SalesSystem.open_b2c_paid_tier` | `Ücretli katman açılır` | |
| `convert_audience` | `pct` (0.0) **or** `count` (0) | audience += round(audience×pct) or count | `Kitleden dönüşüm {pct}` | **Mismatch #3b**: `count` form renders "%0" |

### a.6 B2B retention outcomes (each routes through a `B2BSalesSystem` seam)

| type | params (default) | changes | player sees |
|---|---|---|---|
| `b2b_promise_create` | `customer_id`, `feature_id`, `deadline_days` (14) | `accept_promise` → `PromiseRegistry.create`; kept: sat +15 / broken: sat −20, brand −3 | `Müşteri kalır · söz borcu` / `The customer stays · a promise owed` |
| `b2b_retain_delay` | `customer_id` | `hold` (stall, max 2, +3 days countdown) | `Kısa vadeli hamle` / `A short-term move` |
| `b2b_retain_discount` | `customer_id`, `mrr_delta` | `apply_discount` (−15 % MRR, +8 sat) | `Müşteri kalır · MRR {v}` |
| `b2b_retain_ignore` | `customer_id` | `ignore_risk` | `müdahale yok · sayaç işlemeye devam eder` |
| `b2b_cs_promise_honor` | `customer_id`, `feature_id`, `deadline_days` (14) | `honor_cs_promise` | `Müşteri kalır · söz borcu doğar · yol haritasına eklenir` |
| `b2b_cs_promise_refuse` | `customer_id` | `refuse_cs_promise` (brand −3, rep morale −10, account churns) | `Müşteriyi kaybet` / `Lose the customer` |
| `b2b_expand` | `customer_id`, `add_seats`, `per_seat_mrr` | `expand` | `Koltuk +{seats} · MRR {mrr}` |
| `b2b_expand_decline` | `customer_id` | `decline_expansion` | `Değişiklik yok` / `No change` |

### a.7 Endgame / investor (mostly blind by design; the option label carries the meaning)

| type | params | changes | player sees |
|---|---|---|---|
| `advance_phase` | | `GameState.advance_phase()` (refuses without an open gate) | nothing |
| `phase_gate_decline` | | `PhaseGateSystem.on_gate_declined()` (`gate_declines++`, re-prompt in 5 days) | nothing |
| `angel_accept` | | `AngelRoundSystem.accept_offer()`: atomic cash + ledger + cap table + latch | `Nakit +$25.000 · Frank'e %4 hisse` / `Cash +$25,000 · 4% to Frank` (values from the system consts, not the modifier) |
| `accept_acquisition` | | `EndingsSystem.trigger_ending("acquisition")` | nothing |
| `accept_pivot` / `decline_pivot` | | pivot on / `trigger_ending("vc_rejection_cascade")` | nothing |
| `start_vc_meeting` | `vc_id` | `VCPitchSystem.begin_meeting` | nothing |
| `decline_vc_meeting` | | clears `GameState.pending_meeting` (raw write) | nothing |

### a.8 Blind and partial, in one place
- **No chip (10):** `set_flag`, `mentor_advisory`, `ship_active_build`, `advance_phase`, `phase_gate_decline`, `accept_acquisition`, `accept_pivot`, `decline_pivot`, `start_vc_meeting`, `decline_vc_meeting`.
- **Chip without effect (1):** `mrr`.
- **Partial chip (3):** `seats` (MRR half hidden), `convert_audience` (`count` form), `quality_bonus` (hardcoded "+").
- **Chip that can lie (1):** `delay_days` outside an active build.

**Rule for drafts:** an option's cost must ride a type from a.1 to a.7 that has a chip and a screen reader (top bar, Finance, Sales board, HR page, Product page). Blind types carry memory only. A node with one option is a *beat* and must say so in its header.

---

## b. Condition vocabulary (27 types)

`EventManager.is_condition_met` (`event_manager.gd:367-433`). Public; also used by `EventModal` for `unlock_condition`, and by `PhaseGateSystem` / `AngelRoundSystem` for their own gates. Empty dict `{}` = true (that is how an unlocked option is expressed). Unknown type → warn + **false**.

| type | params (default) | reads | note |
|---|---|---|---|
| `day_min` / `day_max` | `value` | `GameState.day` ≥ / ≤ | |
| `phase` | `value` (int) | `GameState.phase ==` (1 Bootstrap · 2 Traction · 3 Series A Hunt) | standing state, not an edge |
| `cash_below` / `cash_above` | `value` | `GameState.cash` < / **>** (strict) | |
| `brand_below` / `brand_above` | `value` | strict | gate 2 uses `brand_above 24` for "≥ 25" |
| `reputation_below` / `reputation_above` | `value` | strict | |
| `subgenre` | `value` | `GameState.subgenre` | |
| `random` | `chance` (0.0) | events RNG stream | on the hourly path the chance is scaled by 1/window-hours |
| `flag_equals` | `key`, `value` (default **null**) | `GameState.get_flag(key, null) == value` | absent key ≠ false: `null == false` is false. Use `flag_set` for "exists" |
| `flag_set` | `key` | `GameState.has_flag(key)` | true even if the stored value is false |
| `build_state` | `value` | `active_build.status` | null build → false |
| `mvp_shipped` | `value` (true) | flag `mvp_shipped` | |
| `founder_skill_min` | `skill`, `value` | founder `role_stats[skill]` ≥ | |
| `build_phase` | `value` | `active_build.current_phase` (design/development/test/beta) | null → false |
| `bug_count_above` | `value` | `active_build.bug_count` > | null → false |
| `customer_count_min` / `_max` | `value` | `CustomerRegistry.get_active().size()` | |
| `mrr_above` / `mrr_below` | `value` | `GameState.mrr` **>** / < (strict; callers pass target−1) | |
| `market_type` | `value` ("b2b"/"b2c") | flag `mvp_market_type` | also how the engine scopes a node's market |
| `has_prospects` | `value` (true) | `ProspectRegistry.has_any()` | |
| `audience_above` | `value` | flag `b2c_audience` (float) > | |
| `customer_satisfaction_below` | `value`, `market` ("") | `CustomerRegistry.get_min_satisfaction(market)` < | |

**Eligibility pipeline** (`_is_eligible`, `:438-492`), in order: not the active event → active-build gate (needs `build_safe` tag or a matching `build_phase` trigger) → `one_shot` (scans `_history` by id) → `cooldown_days` (scans `_history`) → `allowed_hours` window (manager-side, JSON only) → AND over `trigger_conditions`.

**Not in the vocabulary (each is `[COND?]` in drafts):** any read of `_history` (fired? which choice? days since?), employee count, customers-lost count, days since a flag was set, an audience *drop* edge, market-share delta, rival state, promise state by customer, origin. `unlock_condition` is **one dictionary**, no AND/OR; a lock that needs two facts is `[COND?] compound unlock`.

---

## c. Slots and targeting

**There is no slot substitution in authored events.** `EventModal.populate` sets `title`/`body` through `Localization.pick(tr, en)` and a `**bold**`/`*italic*` markdown pass, nothing else (`event_modal.gd:34-49`, `:578-587`). `{account}`, `{employee}`, `{rival}`, `{investor}`, `{company_name}` would render literally. All 16 loaded JSON events carry static text.

Substitution exists **only in the code factories, at build time**, over CSV keys:
- B2B (`b2b_event_factory.gd`): `{company}` (customer name), `{feature}` (`B2BConstants.feature_label`), `{voice}` (sector complaint line / pain phrase), `{note}` (`CompanyCatalog.background_for`), `{n}` (churn countdown chip).
- HR (`hr_event_factory.gd`): `{voice}` (per-person valve line), `{dept}`, `{n}` (calm days), `{company}` + `{amount}` (signing), `{version}`; the resignation body is a per-person whole-string lookup.
- Product/endgame/VC builders: `{version}`, `{inn}`, `{days}`, `{cash}`, `{equity}`, `{investor}` (VC meeting copy).
- Modal chrome: `{day}` in `KARAR · GÜN {day}`.

**How a target is chosen today** (`_resolve_customer_target`, `event_manager.gd:783-799`):
- explicit `customer_id` → that customer;
- `"primary_b2b"` / `"primary_b2c"` → `get_by_market(m)[0]` = **dictionary insertion order, i.e. the oldest surviving account**; not biggest, not most at risk;
- empty → per-type fallback: `churn_customer` / `satisfaction_delta` use `get_lowest_satisfaction_customer(market)` (deterministic argmin, id tiebreak); `seats` / `customer_mrr_delta` use `get_by_market("b2b")[0]` (`:671`, `:682`).
- Employees: `morale` / `hr_departure` need a literal `character_id`; the owning system picks the person before it builds the event (resignation roll, overtime valve, CS rep = `reps[0]` at `customer_rep_system.gd:308`). **No `another_employee` concept exists.**
- Rivals: **unreachable.** No modifier, no condition, no token touches `RivalRegistry`.
- Investors: only `start_vc_meeting{vc_id}` with an id the VC system supplies.

**Weighted targeting is MISSING** (Pool Design §5.4 requirement 4): the picks at `event_manager.gd:671`, `:682`, `:788-795` and `customer_rep_system.gd:308` are index-0 or argmin, never a weighted draw over arc history. Marked here; not fixed here.

**Draft convention.** Node files still write `slots:` with `{account}`, `{employee}`, `{another_employee}`, `{rival}`, `{investor}` because the Pool Design's arcs need them. Each is a content-side placeholder that the rebuild must fill by weighted pick (`[VOCAB?] slot`); a node whose slot cannot be filled is ineligible (Pool §5.4). Where a fixed name is honest today (one candidate exists), the draft uses the fixed name and says so.

---

## d. Memory hooks (what a later node can read)

**`_history`**: `event_manager.gd:36`: `Array of {id, day, choice}`; appended in `resolve_choice` after modifiers apply (`:190`). Read only by the one_shot and cooldown scans and by save/load. **`get_history()` (`:362`) has zero callers.** No condition type reads it. So a node cannot ask "did Y1.1 fire, and which option was taken", not yet. Pool §5.3 (`history_has(arc, node, choice)`) is a rebuild requirement.

**The flag bag**: the only working memory channel: `set_flag{key,value}` → `flag_equals{key,value}` / `flag_set{key}`. `GameState.FLAG_TYPES` (`game_state.gd:58-130`) registers known keys for save typing; `FLAG_TYPE_PREFIXES` (`:134-139`) registers four per-entity families (`b2b_broke_<customer>`, `hr_manual_leave_<char>`, `hr_valve_continued_<char>`, `bug_count_at_bugfix_start_<build>`). **A key absent from both tables is legal** ("content can invent flags", `:56-57`); it round-trips best-effort.

Existing flags a node may read: `mvp_shipped`, `mvp_version`, `mvp_market_type`, `mvp_launch_day`, `critical_bug_unfixed`, `tech_debt_birikti`, `needs_engineer`, `b2c_audience`, `b2c_price`, `b2c_paid_tier_open`, `gate_prompt_day`, `gate_declines`, `pivot_offer_made`, `acquisition_offer_made/_rejected`, `vc_d179_warned`, `angel_seed_offered`, `angel_seed_accepted_day`, `angel_nudge_shown`, `hard_mode_unlocked` (reserved, no writer), `origin_press_sympathy`, `origin_low_capital`.

Per-entity state the factories can *quote* in text (not conditions): `Customer.last_request_kind`, `.risk_streak`, `.churn_countdown`, `.retain_stalls`, `.trust_offset`, `.satisfaction`, `.acquired_on_day`; run counters `GameState.run_customers_signed/_lost/_expanded`, `run_hires`, `run_departures`, `run_peak_mrr`, `run_pitches`, `run_sheets_won`, `vc_rejections`.

**Arc-memory convention for drafts:** `memory write: <arc>.<n>.choice → set_flag key "<arc>.<n>.choice" value "<short id>"` (dotted keys are legal Dictionary/JSON keys; string ids read cleanly in `flag_equals`). Registration is optional; the rebuild may add one prefix family per arc for hygiene. Existing system flags (the angel trio) are reused, not duplicated.

---

## e. Trigger-hook map (draft hook name → today's nearest edge)

The engine has **no signal-driven triggers**. Beats poll daily (`daily_tick`, `event_manager.gd:58-75`), ambients poll hourly with `random` (`hourly_tick`, `:80-114`, ≤1/day), and systems inject with `enqueue`/`enqueue_front` (`:199-233`), which **bypass one_shot/cooldown**. Pool §5.1-5.2 (one admission path; `on_action` hooks + weekly pulse) is the rebuild. Drafts write `trigger: event:<hook>`; this table says what the hook corresponds to today.

| draft hook | today's edge | where |
|---|---|---|
| `run_start` | onboarding completed → boot modal | `main.gd:1780-1797` (skipped on save load) |
| `angel_offer` | slot-8a poll `mvp_shipped ∧ mrr_above 2499`, latch `angel_seed_offered` | `angel_round_system.gd:61-70, 112-119` |
| `angel_nudge` | `day ≥ accepted+2 ∧ employees == 0`, latch `angel_nudge_shown` | `angel_round_system.gd:73-89` |
| `customer_churned` | `EventBus.customer_churned(customer_id)` from `B2BSalesSystem._remove_lost` | `b2b_sales_system.gd:265-272`; B2C has **no churn edge** |
| `customer_health_changed` (risk edge) | `EventBus.customer_health_changed(customer_id, phase)`; retention card enqueue | `b2b_sales_system.gd:194-203` |
| `promise_created / kept / broken` | `EventBus.promise_*` from `PromiseRegistry` | `promise_registry.gd:112-141` |
| `build_phase_changed("shipped")` (ship moment) | `EventBus.build_phase_changed`; `ProductSystem._trigger_ship_moment` enqueue | `product_system.gd:1265-1267` |
| `phase_gate_reached(n)` | `EventBus.phase_gate_reached`; gate scene `enqueue_front` | `phase_gate_system.gd:94-122` |
| `phase_changed(n)` | `EventBus.phase_changed` after the player confirms the gate | `game_state.gd:329-342` |
| `morale_changed` / flight-risk edge | `EventBus.morale_changed`; resignation roll after 10-14 days under 25 | `hr_morale_system.gd:472-498` |
| `character_added` (hire) | `EventBus.character_added` | `character_registry.gd` |
| `rival_status_changed` / share moved | `EventBus.rival_status_changed`, `rival_advanced`; share is stateless (`get_market_snapshot`); **no `rival_shipped`, no share-delta signal** | `rival_registry.gd:164-196` |
| `sheet_granted / sheet_expired / meeting_day / sheet_walked` | `EventBus.sheet_*` etc. | `vc_pitch_system.gd:435-497` |
| `run_ended(id)` | `EventBus.run_ended(ending_id, ending_data)`; **queue flushed, no events after** | `endings_system.gd:225-228` |
| `pulse` | does not exist; nearest = daily poll + `priority` ordering; no `weight` field | `event_manager.gd:119-134` |

---

## f. Legacy-function map (16 loaded JSON + factory families → where the function goes)

All legacy **copy** retires. The **function** carries.

| legacy id | function | inheriting node |
|---|---|---|
| `ev_mvp_dev_001_integration_broken` | tech-debt seeding (2 a.m. grind vs quick fix) | build-phase family, **unassigned; director** (Pool Design has no build-phase arc; Y7 is post-ship) |
| `ev_mvp_dev_002_tech_debt_callout` | debt payback loop | same |
| `ev_mvp_dev_003_solo_dev_fatigue` | founder fatigue beat | same |
| `ev_mvp_iter_001_scope_creep` | scope-creep decision | same |
| `ev_mvp_iter_002_competitor_signal` | rival differentiation beat ("Meridyen") | Y3.1 Noticed (post-ship form) |
| `ev_mvp_iter_003_early_user_feedback` | vision vs feedback | build family, unassigned |
| `ev_mvp_bugfix_001_critical_bug` | ship-with-known-bug gamble | Y7.1 Bug threshold (post-ship form) / build family |
| `ev_mvp_bugfix_002_early_launch_pressure` | ship-now pressure | build family, unassigned |
| `ev_mvp_bugfix_003_final_polish` | polish beat (weak trade, audit #8) | retire; no node |
| `ev_ps_first_revenue` | **first-revenue beat**, Frank "Artık bir şirketsin." | **unassigned; director** (not one of Y5's six; candidates: Y1 first-customer node (B2B), Y9.2 (B2C), or a Y5 seventh) |
| `ev_ps_frank_intro_b2b` | Frank opens the first B2B door (`add_prospect{mid, frank_intro}`) | Bootstrap "first-customer node of Y1" (Pool §2), out of Batch 1; Y5 cross-reads it |
| `ev_ps_b2c_paid_tier` | B2C pricing gate (Frank) | Y9.1/Y9.2 |
| `ev_ps_bug_complaint` | quality/churn warning (B2C only today) | Y7.2 Named complaint (B2B mirror ruled in the 2026-08-18 research §B6) + Y9 |
| `ev_ps_power_user_b2c` | organic momentum | Y9.4 Power user |
| `ev_ps_b2c_producthunt` | launch-day visibility bet ("Vitrin") | Y9.3 Product Hunt decision → outcome node |
| `ev_ps_referral_b2b` | warm-intro pipeline with roadmap debt | Y1.1 The Ask (referral variant) / Y8 texture |
| factory: B2B retention / expansion / CS escalation / CS request | account at risk · seats · rep-forced promise · demand channel | Y2.1-2.4 · Y1.1 · Y2.2 (escalate to rep) · Y1.1 |
| factory: HR resignation / valve / positives | departure · overtime valve · morale recovery | Y4.5-4.6 · Y4.3 · Y4.6 / Y8 |
| builder: ship moments, iteration intro | THE ship moment · one-more-round | Y9.1 (B2C) / Y3.5 (v2 ships) · unassigned (the iteration intro's `advance_iteration` effect is retired by the Build Bar task) |
| builder: phase gates ×2 | Bootstrap→Traction, Traction→Series A (Frank) | mandatory beats (exempt from budget); Y5.5 follows gate 2 |
| builder: angel nudge, seed | Frank seed + hire nudge | **Y5.2, Y5.3** |
| builder: VC calendar ×3 | meeting day · sheet expiry · D-179 | Y6.3-6.5 |
| builder: endgame ×3 | shutter warning · pivot · acquisition | Y5.6 (verdicts) + Y6.5; pivot/acquisition = follow-ups |
| `ev_debug_*` ×3 | never loaded (fixtures for locked choice / mentor endorsement / threshold trigger) | none |

---

## g. Conventions and known gaps

**Markers.** `[VOCAB?] <effect>` = the node wants an effect not in §a. `[COND?] <condition>` = a prerequisite not in §b. Both are expected; both are collected per arc in the arc README for the rebuild.

**Header fields** (Pool §7): `id · arc · node · category · market` · `trigger` · `prerequisites` · `slots` · `one_shot / cooldown / variants (weight: pulse only)` · `memory write`. `weight` has no engine counterpart today (only `priority` int); drafts still state it for pulse nodes.

**Beat.** A one-option node (ship moment, first revenue, mentor line) is a sanctioned category (audit 2026-07-14 §"beat, not choice"), not a fake choice. Its header says `beat: 1`; its INTENT names the reader the player sees afterwards.

**Locked-visible.** `unlock_condition` (one dict from §b) + `unlock_reason_text` / `_en`. Rendered at 50 % alpha, unclickable, reason badge in place of chips; default reason `KİLİTLİ` / `LOCKED`. A mentor never endorses a locked path (`event_modal.gd:339`).

**Clock in the subtitle** only with an `allowed_hours` window; day-boundary beats carry no clock.

**Arc-independent gaps already known (rebuild input):**
1. `mrr` modifier: chip, no branch.
2. `mentor_advisory` has no `_en` sibling.
3. No founder-time cost exists (`delay_days` is a build-speed lever, no-op post-ship). Pool nodes that say "costs a day" need `[VOCAB?] founder_days{n}`.
4. No employee-count condition, no customers-lost condition, no days-since-flag condition, no history condition.
5. No slots; targeting is index-0/argmin (weighted pick missing).
6. No `weight`; no pulse; no on_action hooks; `enqueue()` bypasses suppression.
7. `unlock_condition` is a single dict.
8. `advance_iteration` is retired by the Build Bar task (same day, in flight: the arm and its chip are already gone from the working tree) and `enter_beta` is added; nodes must not use `advance_iteration`. Line numbers in this document are from the morning extraction; `event_manager.gd` / `event_modal.gd` / `strings.csv` are being edited concurrently, so re-extract before wiring.
9. Frank's ending lines (`END_META_*_FRANK`) ride `ending_data.frank_line` but the ending newspaper does not render them (`endings_copy.gd:53-65`; the paper bans mentor attribution); a verdict needs a surface.
