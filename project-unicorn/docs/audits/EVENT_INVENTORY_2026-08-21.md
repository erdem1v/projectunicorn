# EVENT INVENTORY — every event that is not Frank's

**Date:** 2026-08-21 · **Type:** READ-ONLY inventory (nothing fixed, no balance change, no new events) · **Tree:** working tree at `9908a8b`, audited as it stands · **Sibling report:** `FRANK_VERIFY_2026-08-21.md`

## Why this document exists

The event layer has choices whose effects make a run untestable: one click grants a permanent economic swing, or every option does the same thing, or an option does nothing at all. Until those are sane, no playtest tells us anything about balance. We would rather revise the events we have than write new ones — so this is what we have, exactly.

**Nothing here is a proposal.** Every entry is what the code does today.

## Scope

Every event that is **not Frank's** and that can put a modal in front of the player:

- **13 authored pool events** in `data/events/reactive/` that the loader actually loads
- **3 `ev_debug_*` fixtures** in the same directory that the loader skips by filename (`event_manager.gd:886`)
- **1 unwired card** in `data/events/unwired/` that no loader opens
- **11 code-built card families** from `b2b_event_factory` (4, one of which branches three ways) and `hr_event_factory` (5)

**28 entries.** Frank's own surfaces — the two Frank pool events, the product ship moments, the phase gates, the angel pair, the four VC cards and the two endgame cards — are in the sibling report, not here.

Decision surfaces that are not EventModal cards (MeetingScene, the term-sheet table, HRAtlas, Training, the 16 ConfirmModal callers) are enumerated in the appendix so nothing is invisible; they do not fit the per-event shape and are not graded.

## Method

**Read, then played, then verified.** Each entry was extracted from source against a shared reference table of all 44 dispatcher arms (`event_manager._apply_modifiers`, `:557-814`) and all 36 chip descriptors (`event_modal._describe_modifier`, `:483-567`), then graded against all eleven flags, then handed to a second reader whose only job was to refute it. Refutations that survived are folded in; the ones that changed a verdict are marked **[corrected]** in the entry.

**Reachability comes from eight played runs**, not from reading triggers — `--run-log=<preset>:<days>:sim`, seed 424242, 2,290 simulated days in total. The primary run (`full_run:730`) reached `profitable_bootstrap` on day 275 with 62 cards. Its log is attached to the sibling report.

**Chips were verified against rendered frames**, not inferred: `--event-shot=<id>` and `--b2b-shot=<kind>` at 1920×1080 for the cards that carry the report's headline claims.

### Two engine facts every entry depends on

- **`enqueue` / `enqueue_front` bypass `_is_eligible` entirely** (`event_manager.gd:200`, `:217`). For every code-built card, `one_shot`, `cooldown_days`, `allowed_hours` and the `build_safe` gate are **inert**. The FREQUENCY line therefore quotes the owning system's private latch, never the event object's own field.
- **`_describe_modifier` is the only place effect chips are built**, and its terminal `return {}` is why some options render nothing at all. That is the objective test behind every BLIND verdict here.

### A note on how the table is sorted, and on one flag

By the letter of its definition — "a one-click effect that changes the economy forever" — **PERMANENT_SWING applies to all 28 entries**, because almost every modifier in this game writes state that never decays: a `stability +2` on a build is stamped into `mvp_stability` at ship and re-seeds every later version. Reported faithfully, the flag stops discriminating, and a table where every row is flagged tells you nothing about where the damage is.

So the flag is recorded honestly on every row that earns it, **and the table is sorted by the measured size of the swing**, with the number in its own column. The first rows are the ones that move dollars; the last are the ones that move a build axis by single digits. Where a flag's verdict was reversed by the second reader, the correction is shown rather than quietly applied.

### What the flag distribution itself says

| flag | rows | |
|---|---|---|
| PERMANENT SWING | 27 / 28 | near-universal by definition — see above |
| **COPY LIE** | **27 / 28** | **not an artifact — read this one** |
| VOICE | 25 / 28 | mostly the em-dash construction: 13 of the pool's 40 choice labels are `action — justification`, and several of those justifications pre-judge the choice for the player |
| MAGNITUDE | 17 / 28 | |
| DEAD REFERENCE | 15 / 28 | |
| FREE LUNCH | 13 / 28 | |
| REPEATABLE COMPOUND | 10 / 28 | |
| INVISIBLE | 9 / 28 | |
| NO OP | 5 / 28 | |
| BLIND | 3 / 28 | |
| IDENTICAL OPTIONS | 1 / 28 | |

**COPY LIE landing on 27 of 28 entries is the single most important number in this document**, and it is not flag inflation. The dominant shape, found independently on card after card, is that **a label names the resource the player is being asked to spend, and the engine charges a different one — or nothing at all**:

- `Çıkışı ertele, çöz` ("postpone the launch, fix it") carries `bug_delta −6`, `dimension_delta stability +4`, `cash −150`. There is no `delay_days`. **The launch is not postponed.**
- `Vakit harca, cila çek` ("spend the time, polish it") spends no time — no `delay_days`, `total_efor` untouched, the build finishes on exactly the day it would have. It takes $80.
- `Kabul et — özellik sözü ver` ("accept — promise the feature") creates no promise: no `b2b_promise_create`, nothing in `PromiseRegistry`, and the body's *"yol haritana bir borç yazıyor"* records nothing.
- `Görmezden gel` renders the chip *"Müşteri kaybı"* / "A customer lost" and on the B2C branch loses no customer at all — `event_manager.gd:684-688` erodes 15 % of the audience, leaves the record standing and never touches `run_customers_lost`.

That is one defect class, repeated roughly two dozen times, and it is the reason the events read as arbitrary: the fiction and the modifiers were written against different models of what the game charges for. **It is also the cheapest class to fix**, because in most cases the prose is right and the missing modifier is one line — which is exactly the argument for revising these events rather than replacing them.

---

## 2.4 · Summary — worst first

| # | event | category | reachable | choices | measured weight | flags |
|---|---|---|---|---|---|---|
| 1 | `ev_b2b_expand_<customer_id>` | B2B account | yes — 25 fires, d77-d212 | 2 | +$360 / +$720 / +$1,440 MRR per click, permanent, no cost | PERMANENT SWING, FREE LUNCH, MAGNITUDE, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 2 | `ev_ps_referral_b2b` | B2B account | yes — 16 fires, d32-d252 | 3 | two prospect options, one identical chip; a promise the engine never creates | REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, NO OP, DEAD REFERENCE, COPY LIE, VOICE |
| 3 | `ev_b2b_retain_<customer_id>` | B2B account | yes — 4 fires (87 in b2b_solo:365) | 4 | -15% MRR permanent, twice per account, compounding | PERMANENT SWING, FREE LUNCH, NO OP, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 4 | `ev_ps_bug_complaint` | B2C audience | yes — 42 fires in b2c_neglect:365 | 3 | satisfaction +10 ratchet; the churn chip lies on the B2C branch | REPEATABLE COMPOUND, PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE |
| 5 | `ev_ps_b2c_producthunt` | B2C audience | yes — 16 fires in b2c_keep:183 | 2 | audience swing, no cost on the upside | REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, DEAD REFERENCE, COPY LIE, VOICE |
| 6 | `ev_ps_power_user_b2c` | B2C audience | yes — 13 fires in b2c_keep:183 | 2 | audience swing, no cost on the upside | REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, COPY LIE, VOICE |
| 7 | `ev_b2b_escalation_<customer_id>` | B2B account | only with a hired CS rep | 2 | blind promise/refuse with a permanent trust move | REPEATABLE COMPOUND, PERMANENT SWING, MAGNITUDE, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 8 | `ev_b2b_request_<customer_id> — COMPLAINT branch` | B2B account | only with a hired CS rep | 3 | blind | REPEATABLE COMPOUND, PERMANENT SWING, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 9 | `ev_b2b_request_<customer_id> — FEATURE branch` | B2B account | only with a hired CS rep | 3 | blind | PERMANENT SWING, FREE LUNCH, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 10 | `ev_b2b_request_<customer_id> — RENEWAL branch` | B2B account | only with a hired CS rep | 3 | free-lunch renewal | PERMANENT SWING, FREE LUNCH, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 11 | `ev_hr_ship_glow` | team | NO — structurally unreachable | 1 | morale, free | REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, DEAD REFERENCE, COPY LIE |
| 12 | `ev_hr_big_signing` | team | NO — structurally unreachable | 1 | morale, free | REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, DEAD REFERENCE, COPY LIE |
| 13 | `ev_hr_calm_stretch` | team | only under narrow morale window | 1 | morale, free | PERMANENT SWING, FREE LUNCH, DEAD REFERENCE, COPY LIE, VOICE |
| 14 | `ev_hr_valve_<emp.id>` | team | only with an active overtime block | 2 | morale / overtime | PERMANENT SWING, NO OP, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 15 | `ev_hr_resign_<emp.id>` | team | only after 10+ days under morale 25 | 1 | the employee is already gone | PERMANENT SWING, DEAD REFERENCE |
| 16 | `ev_mvp_dev_001_integration_broken` | product | yes — d14 | 2 | build axis + hidden flag | PERMANENT SWING, MAGNITUDE, BLIND, COPY LIE, VOICE |
| 17 | `ev_mvp_dev_002_tech_debt_callout` | product | only after dev_001 choice 1 | 2 | build axis + the flag it reads | PERMANENT SWING, MAGNITUDE, BLIND, COPY LIE, VOICE |
| 18 | `ev_mvp_bugfix_001_critical_bug` | product | yes — d61 | 2 | build axis, blind side | PERMANENT SWING, MAGNITUDE, BLIND, COPY LIE, VOICE |
| 19 | `ev_mvp_iter_001_scope_creep` | product | yes — d55 | 2 | build axis | PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE |
| 20 | `ev_mvp_iter_002_competitor_signal` | product | yes — d6 | 2 | build axis | PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE |
| 21 | `ev_mvp_iter_003_early_user_feedback` | product | yes — d89 | 2 | build axis | PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE |
| 22 | `ev_mvp_bugfix_002_early_launch_pressure` | product | yes — d21 | 2 | build axis | PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE |
| 23 | `ev_mvp_bugfix_003_final_polish` | product | yes — d18 | 2 | build axis | PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE |
| 24 | `ev_mvp_dev_003_solo_dev_fatigue` | product | yes — d16 | 2 | build axis, smallest in the family | PERMANENT SWING, COPY LIE, VOICE |
| 25 | `ev_debug_003_cash_warning` | debug | no — loader skips ev_debug_* | 3 | fixture | PERMANENT SWING, FREE LUNCH, MAGNITUDE, NO OP, IDENTICAL OPTIONS, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 26 | `ev_debug_001_engineer_workload` | debug | no — loader skips ev_debug_* | 3 | fixture | REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE |
| 27 | `ev_debug_002_press_inquiry` | debug | no — loader skips ev_debug_* | 3 | fixture | REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, COPY LIE, VOICE |
| 28 | `ev_seed_closed` | other | no — outside the scanned directory | 1 | inert by design | NO OP, COPY LIE, VOICE |

### What the second reader changed

Every entry above was re-opened by a reader whose only instruction was to refute it, defaulting to *refuted* when a claim could not be confirmed from source. 308 verdicts were returned across the six families; **14 reversed a flag**, **37 corrected a number**, and **0 corrected a quote**. The reversals are listed here rather than quietly applied, because a flag that was wrong the first time is worth knowing about.

| event | flag | first read | after refutation | why |
|---|---|---|---|---|
| `ev_b2b_expand_<customer_id>` | REPEATABLE COMPOUND | flagged | **not flagged** | The objective test I was told to run is whether the owning system really has no latch — and it does. Customer.last_expansion_day at customer.gd:69 ("-1 = expansion moment not yet offered"), stamped on BOTH answers at b2b_sales_system.gd:385 (expand) and :398 (decline), read by the one shared gate can_offer_expansion at :272-273, which both the daily sweep (:259) and the Sales-tab button (sales_tab |
| `ev_b2b_expand_<customer_id>` | NO OP | flagged | **not flagged** | Objective test: is the modifiers array empty, or is every arm a no-op? Neither. "Şimdilik gerek yok" carries b2b_expand_decline (b2b_event_factory.gd:104-106) → event_manager.gd:811-812 → decline_expansion (b2b_sales_system.gd:390-400), which performs two real state writes: CustomerRegistry.set_last_expansion_day(c.id, GameState.day) at :398 and set_lifecycle_phase back to "active" at :399-400. Th |
| `ev_b2b_expand_<customer_id>` | COPY LIE | not flagged | **flagged** | The decline row's chip is EFFECT_NO_CHANGE, TR "Değişiklik yok" / EN "No change" (event_modal.gd:557, strings.csv verified byte-exact), and it renders over a modifier that writes two pieces of durable state: CustomerRegistry.set_last_expansion_day (b2b_sales_system.gd:398) and set_lifecycle_phase (:399-400). The latch is permanent and read by the single gate that governs the whole family (can_offe |
| `ev_b2b_escalation_<customer_id>` | BLIND | flagged | **not flagged** | REFUTED by the objective test. _describe_modifier returns a chip for all four modifiers on this card: b2b_cs_promise_honor event_modal.gd:551 (accent), b2b_cs_promise_refuse :552 (negative), brand :491, morale :493. None reaches the terminal `return {}` at event_modal.gd:567. The entry itself concedes 'both rows carry chips'; the deferred-cost complaint is chip completeness, already carried by COP |
| `ev_b2b_request_<customer_id> — COMPLAINT branch` | BLIND | flagged | **not flagged** | REFUTED by the objective test. Every modifier on this branch chips: b2b_retain_discount event_modal.gd:549, satisfaction_delta :496, b2b_promise_create :547. None falls through to `return {}` at :567. The +16-vs-'+8' understatement (apply_discount's own _recover at b2b_sales_system.gd:340 plus the sibling CS_DISCOUNT_SAT=8) is real but is a magnitude/label accuracy problem, not a missing chip. |
| `ev_b2b_request_<customer_id> — COMPLAINT branch` | VOICE | not flagged | **flagged** | REFUTED. The body ALWAYS interpolates B2BConstants.complaint_voice(c.industry) (b2b_event_factory.gd:236), and two of the 15 sector rows carry an em dash in EN: B2B_COMPLAINT_CONSTRUCTION 'The site crew cannot stay connected — it drops constantly...' and B2B_COMPLAINT_LEGAL 'We cannot reach our files — it goes down several times a day.' Both sectors are live (b2b_constants.gd:99 SECTORS). The entr |
| `ev_b2b_request_<customer_id> — RENEWAL branch` | INVISIBLE | not flagged | **flagged** | REFUTED. 'No hidden field is touched' is false. (a) build_cs_request writes CustomerRegistry.set_last_request_kind for THIS branch too (b2b_event_factory.gd:226); last_request_kind (customer.gd:89) has no reader outside pick_request_kind (:155) and no player surface — the entry's own COMPLAINT and FEATURE entries flag exactly this field as invisible 'on every branch'. (b) 'İndirimle bağla' -> appl |
| `ev_b2b_request_<customer_id> — FEATURE branch` | BLIND | flagged | **not flagged** | REFUTED by the objective test. b2b_promise_create returns a chip at event_modal.gd:547 and satisfaction_delta at :496; nothing on this branch reaches the terminal `return {}` at :567. The missing deadline/break-cost detail is chip completeness — already carried by this entry's COPY_LIE and INVISIBLE verdicts — not blindness. |
| `ev_b2b_request_<customer_id> — FEATURE branch` | VOICE | not flagged | **flagged** | REFUTED. The VOICE body splices B2BConstants.pain_phrase(c.pain_feature_id) (b2b_event_factory.gd:277), and three pain rows carry an em dash in EN: B2B_PAIN_AI_VEC_EMBED_API ('...understands our data — keyword matching is not enough.'), B2B_PAIN_AI_VEC_DASHBOARD ('...usage at all — management is flying blind.'), B2B_PAIN_AI_VEC_SDK ('Integration is hard — without a ready library...'). Those ids ar |
| `ev_ps_b2c_producthunt` | INVISIBLE | flagged | **not flagged** | Neither leg survives the flag's own definition ('the effect never surfaces anywhere the player can see'). Leg 2, the $800: event_manager.gd:566 calls GameState.set_cash, which at game_state.gd:309-312 emits cash_changed AND _emit_runway, and top_bar.gd:146/:149 bind both - the player watches the money leave the instant they click. What is genuinely missing is the ATTRIBUTION: apply_one_time_cost ( |
| `ev_ps_power_user_b2c` | INVISIBLE | flagged | **not flagged** | This entry's only leg is the $600, and the $600 is visible. event_manager.gd:566 -> GameState.set_cash -> game_state.gd:309-312 emits cash_changed and _emit_runway, both rendered by top_bar.gd:146/:149. The player sees the treasury drop the moment they click. The correct finding is narrower and belongs elsewhere: apply_one_time_cost (finance_system.gd:178-192) is bypassed, so record_transaction (: |
| `ev_ps_referral_b2b` | IDENTICAL OPTIONS | flagged | **not flagged** | Fails the stated objective test ('are the modifier sets really equal?') twice over. Modifiers: choice 0 is {add_prospect mid, cash -400} (json:36-46), choice 1 is {add_prospect small} (json:53-59) - not equal. Chips: _make_effect_chips (event_modal.gd:429-438) emits [Yeni aday][Nakit -$400] for choice 0 and [Yeni aday] for choice 1 - not equal either, and the audit's own prose says exactly that (' |
| `ev_ps_referral_b2b` | INVISIBLE | flagged | **not flagged** | Same defect as the power_user entry. The $400 surfaces immediately: event_manager.gd:566 -> GameState.set_cash -> game_state.gd:309-312 emits cash_changed and _emit_runway, rendered by top_bar.gd:146/:149. The effect is seen; only its ATTRIBUTION is missing, because apply_one_time_cost (finance_system.gd:178-192) is bypassed and record_transaction (:283-288), one_time_today and accrue_month_expens |
| `ev_ps_referral_b2b` | DEAD REFERENCE | not flagged | **flagged** | The audit stopped one hop short. It is true that event_manager.gd:677 reads m.get("source") - unlike the producthunt card - and passes it to PitchSystem.spawn_prospect. But spawn_prospect's only use of that argument is pitch_system.gd:98, `p.source = source`, and a repo-wide grep for readers of Prospect.source returns exactly that one WRITE and nothing else. prospect.gd:39 declares it (@export var |

**Numbers corrected**

- `ev_b2b_expand_<customer_id>` — claim: *MAGNITUDE: "the run ended profitable_bootstrap with runway=INF from day 120 onward"* → **Runway goes INF far earlier. The log holds 80 PROBE STATE lines with a finite runway and the last of them is day=84 (day 84 finite, day 85 onward all runway=INF; day 76 runway=8.86 and day 77 runway=10.07 are the last dip). The correct statement is "runway=INF from day 85 onward", which strengthens rather than weakens the finding.**
- `ev_b2b_retain_<customer_id>` — claim: *PERMANENT_SWING: "three kept promises (-15) drop a mid account from 51 to 36 — below the target even a WEAK product produces ... i.e. the account becomes structurally unable to churn"* → **The arithmetic is right (TOLERANCE_BASE 33 + 2×TOLERANCE_PER_SCALE 9 = 51; 51-15 = 36) but the scenario is unreachable through this card. The promise row is built only when the pain feature is NOT in mvp_components (b2b_event_factory.gd:58-60), and a KEPT promise means that feature shipped into mvp_components — so the row can never rebuild for that account. pain_feature_id is written once, at sign**
- `ev_b2b_request_<customer_id> — COMPLAINT branch` — claim: *REPEATABLE_COMPOUND: 'two promises = +30 satisfaction, −10 tolerance, +12 trust_offset for one shipped feature'* → **+12 trust_offset is unreachable. set_trust_offset clamps to TRUST_OFFSET_MAX = 10.0 (b2b_constants.gd:377, applied at customer_registry.gd:280), so two kept promises (PROMISE_KEPT_OFFSET = 6.0 each, b2b_constants.gd:373) saturate at +10.0. The mirrored broken figure (−24) IS reachable, since TRUST_OFFSET_MIN = −25.0 (b2b_constants.gd:376). The satisfaction and tolerance halves of the claim are cor**
- `ev_b2b_escalation_<customer_id>` — claim: *'pick_pain_feature returns "" once every feature in the active pool is live, b2b_sales_system.gd:512-522' and, in DEAD_REFERENCE, 'b2b_sales_system.gd:520-522'* → **Both citations run past end of file — b2b_sales_system.gd is 516 lines. pick_pain_feature is at :498-516; the exhausted-pool comment is :514-515 and the `return ""` is :516. The substance is correct.**
- `ev_b2b_escalation_<customer_id>` — claim: *Call-site line citations in 'fires' and the effects table: '_tick_cs_escalation (b2b_sales_system.gd:52, :149)', 'the per-customer sweep (b2b_sales_system.gd:39-40)', 'CustomerRepSystem.daily_tick runs right after it (:4* → **Off by one to three. The _tick_cs_escalation CALL is b2b_sales_system.gd:53 (the function is :149, which is right); the customer sweep is :40-41 and CustomerRepSystem.daily_tick() is :42; the assigned_to test is :155 (the latch clear is :156, as stated); accept_promise begins at :298 (PromiseRegistry.create :303, _recover :308); set_current_hour(0) is time_manager.gd:140, so the day-roll spans :14**
- `ev_hr_big_signing` — claim: *"the played run signed 25 accounts, six of them at or above HRConstants.BIG_SIGNING_MRR 1500 — day 52 +$1.700 (Marmara Klinik), day 85 +$2.000, day 110 +$1.700, day 112 +$1.700, day 116 +$1.700, day 131 +$2.000 — and fiv* → **SEVEN qualifying signings, SIX of them with an employee on staff. The entry drops day 154: run_full_run_730.log line 2499 'PROBE PLAY day=154 pitch Marmara Lojistik -> SIGNED (mrr 23750 -> 25450)' = +$1.700, and PROBE STATE day=154 reads emp=1. Full qualifying list: day 52 +$1.700, day 85 +$2.000, day 110 +$1.700, day 112 +$1.700, day 116 +$1.700, day 131 +$2.000, day 154 +$1.700. The zero-fires c**
- `ev_hr_ship_glow` — claim: *MAGNITUDE reason: "day 119 MRR ~$12.700"* → **PROBE STATE day=119 cash=27922 mrr=17665 brand=50 burn=260 cust=17 emp=1. $12.685 is day 110, not day 119. The other two contexts are correct: day 63 cash=27769 mrr=3550, day 96 mrr=9405.**
- `ev_hr_calm_stretch` — claim: *PERMANENT_SWING: "the gate requires average < 70 and the reward is +5, so this beat alone can never push the team average past 75 — which is exactly MORALE_HIRE_START"; REPEATABLE_COMPOUND repeats it as "The reward can n* → **Only true at Liderlik 0-1. HRConstants.climate_gain_mult (hr_constants.gd:904-906) = clampf(1 + 0.05*L, 1.0, 1.5) and hr_morale_system.gd:261 writes int(round(5 * mult)): L=2 -> round(5.5)=6, L=3 -> round(5.75)=6, L=10 -> round(7.5)=8. A 69-average team therefore lands at 75 (L=2-3) or 77 (L=10), i.e. past 75. Liderlik above the onboarding cap of 3 (founder_constants.gd:53) is reachable: character**
- `ev_hr_valve` — claim: *'Devam et' what_happens: "adds RESIGN_VALVE_PENALTY 0.15 to that person's daily resignation roll for the rest of the run: base 0.25 -> 0.40 before the trait multiplier, a +60% relative increase"* → **The penalty is added AFTER the trait multiplier and is never scaled by it — hr_constants.gd:953-957: chance = RESIGN_CHANCE_PER_DAY(0.25) * trait_mult(traits,'resign_chance_mult') + RESIGN_VALVE_PENALTY(0.15). 0.25 -> 0.40 and "+60%" hold only at trait_mult 1.0. With 'wont_jump_ship' (0.6, hr_constants.gd:489) it is 0.15 -> 0.30, a +100% increase; with 'one_foot_out' (1.6, hr_constants.gd:509) it **
- `ev_hr_resign` — claim: *Slot numbering, repeated across three entries: tick_thresholds is "HRSystem.daily_tick slot 6 (hr_system.gd:52)", tick_positive_events is "slot 7 (hr_system.gd:54)", HROvertimeSystem.daily_tick is "slot 4 (hr_system.gd:5* → **The cited line numbers are all correct, the slot labels are not, on either available counting. By hr_system.gd's own step comments (:36-43) overtime is step 4, thresholds step 5, and trait effects + positive events share step 6. By raw call index in HRSystem.daily_tick (:44-54: leave_returns, leave_departures, tick_overload, HRSearchSystem, HROvertimeSystem, tick_thresholds, tick_trait_effects, ti**
- `ev_hr_valve` — claim: *reachable: "the only PROBE PLAY verbs are hire, start_version_build, launch, bug_sprint, pitch, enter_development/beta"* → **Incomplete. The log's full verb tally is find_prospects x48, pitch x65, bug_sprint x20, enter_beta x4, enter_development x4, launch x4, start_version_build x3, hire x1, start_build x1, start_search x1. The load-bearing half of the claim is confirmed: a case-insensitive grep for 'overtime\|mesai' over run_full_run_730.log returns 0 lines, so no block was ever started.**
- `ev_ps_referral_b2b` — claim: *Choice 2 (archetype "small"): "Value band $130-$230 shown."* → **$228-$403. pitch_system.gd:94-97 computes mid = (200+500)/2 = 350, then value_band_min = round(350 x VALUE_BAND_LOW_FRAC 0.65) = round(227.5) = 228 and value_band_max = round(350 x VALUE_BAND_HIGH_FRAC 1.15) = round(402.5) = 403 (b2b_constants.gd:243-244). The audit applied the correct fractions to the mid archetype ($910-$1610, correct) but not to the small one.**
- `ev_ps_referral_b2b` — claim: *NO_OP: "the highest-numbered account ever created was co_lead_164_61, signed on DAY 164" and "from day 165 to day 275 the customer count and MRR are frozen at 25 / $32,495 in every PROBE STATE line".* → **Both are wrong. The log holds exactly 25 SIGNED lines; the last is 'PROBE PLAY day=167 pitch Poyraz Sigorta -> SIGNED (mrr 28395 -> 28895)'. PROBE STATE shows cust=24 on days 162-166 and cust=25 only from day 167. MRR is not frozen from day 165: it climbs 28,395 -> 28,895 (d167) -> 29,255 -> 30,335 -> 30,695 -> 31,055 -> 31,775 -> 32,135 -> 32,495 (d212) via the expansion cards, and only flatlines**
- `ev_ps_bug_complaint` — claim: *"the played run's composite quality hovered 33.8-44.7 all run".* → **The post-ship q= range in run_full_run_730.log is 32.2 to 45.7 (day 1 carries the pre-ship sentinel q=-1.0). Neither endpoint of the audit's band is a bound the run actually reached.**
- `ev_ps_b2c_producthunt` — claim: *PERMANENT_SWING: "+3 brand = +0.012/hour = +0.288/day = +51.84 audience over 180 days (at audience_growth_multiplier 1.0)" and "$5.25 of MRR per head" -> "+$272/month", total "+$419/month".* → **Both are ceilings, not expectations, because two reducers in the same functions are assumed to be 1.0. (1) sales_system.gd:213 applies grow *= clampf(sat / WOM_MULT_PIVOT 50.0, WOM_MULT_MIN 0.3, 1.0) to the whole brand term; the aggregate B2C record is seeded from the experience axis (sales_system.gd:272) and this family's sibling card is gated on satisfaction < 60, so sat < 50 scales the brand co**
- `ev_ps_power_user_b2c` — claim: *PERMANENT_SWING: "+4 = +0.016/hour = +0.384/day = +69.12 audience over 180 days" -> "+$363/month", total "+$494/month", "3.7x an entire measured B2C company".* → **Same two omitted reducers as the producthunt entry: the word-of-mouth base multiplier grow *= clampf(sat/50, 0.3, 1.0) at sales_system.gd:213 and the real conversion_rate formula at sales_system.gd:507-515. The arithmetic as written (0.004 x 4 x 24 x 180 = 69.12; 69.12 x 5.25 = 362.9; 25 x 5.25 = 131.25; 494/135 = 3.66) is internally correct, but the result is an upper bound under two unstated ass**
- `ev_ps_bug_complaint` — claim: *Line citations: churn_customer B2C branch at "event_manager.gd:684-688"; run_customers_lost "that line, event_manager.gd:697"; set_satisfaction "customer_registry.gd:211-223"; satisfaction drift "sales_system.gd:419-428"* → **The B2C erosion branch is event_manager.gd:692-698 (aud read at :697, add_b2c_audience(-int(round(aud*0.15))) at :698); run_customers_lost += 1 is event_manager.gd:701, inside the else/B2B branch (the substance is right, the line is not). set_satisfaction is customer_registry.gd:211-224. _tick_satisfaction is sales_system.gd:414-428 and the drift is not strictly +/-1: delta = (+1 if exp_axis >= SA**
- `ev_ps_b2c_producthunt` — claim: *Line citations: apply_one_time_cost "finance_system.gd:179-193"; record_transaction "finance_system.gd:283-287"; add_b2c_audience "sales_system.gd:305-314"; _window_length_hours "event_manager.gd:544-556".* → **apply_one_time_cost is finance_system.gd:178-192; record_transaction is finance_system.gd:283-288; add_b2c_audience is sales_system.gd:305-316; _window_length_hours is event_manager.gd:544-554. Every substantive claim at those seams is correct; only the spans drift.**
- `ev_ps_b2c_producthunt` — claim: *Reachability: "mvp_market_type is set to \"b2b\" by run_probe.gd:845/_open_the_company".* → **run_probe.gd:845 sits inside _seed_b2b_world (the fixture seeder), not _open_the_company (run_probe.gd:554-580). In the full_run preset the flag is written by product_system.gd:1120 from ProductCatalog.get_market_type on ship, after _open_the_company starts a saas_ops build. The conclusion (the played run is B2B) is independently proven by the 16 fires of ev_ps_referral_b2b, whose market_type=='b2**
- `ev_ps_referral_b2b` — claim: *"neither ev_debug_001 nor ev_debug_002 fired at all", offered as evidence that the referral card took the ambient slot uncontested.* → **Understated: ev_debug_* files are never loaded into the live pool at all. event_manager.gd:886-887 skips every filename beginning with 'ev_debug_' inside _load_all_events_from_disk, so 15 of the 18 files in data/events/reactive/ load. They did not lose the roll; they were never candidates.**
- `ev_mvp_iter_002_competitor_signal` — claim: *Composite drops from (9+27+10)/3 = 15.33 to 13.33 and normalized market quality from q 38.0 to 35.3* → **Arithmetic error in the composite. Removing innovation +5 from the audited v1 (I9/S27/E10) gives (4+27+10)/3 = 41/3 = 13.67, not 13.33 (13.33 is the dev_001 counterfactual, where 6 is removed from stability: 40/3). The normalized value 35.3 is correct and consistent with 13.67: 100 x 13.667 / (13.667+25) = 35.35.**
- `ev_mvp_dev_003_solo_dev_fatigue` — claim: *moving the composite from 15.33 to 16.00 and normalized market quality from 38.0 to 39.0, about +1.0 on the 0-100 band* → **Double-counts the effect. The probe picked choice 0 (PROBE PICK day=16 ... label=Bugun kendine ver, yarin taze basla), so the shipped stability of 27.0 and the log's q=38.0 on day 24 ALREADY include this +2. The correct removal counterfactual is (9+25+10)/3 = 14.67 -> normalized 36.97, i.e. 38.0 falls to 37.0 without the card. The band swing of ~1.0 point is unchanged.**
- `ev_mvp_dev_001_integration_broken` — claim: *_history is appended in resolve_choice (event_manager.gd:224)* → **_history.append is at event_manager.gd:191. Line 224 is 'if not GameState.run_active:' inside enqueue_front. The same wrong citation (':224') is repeated in all five entries under review.**
- `ev_mvp_dev_001_integration_broken` — claim: *whose one_shot guard scans _history (event_manager.gd:486-490) ... cooldown_days guard at event_manager.gd:492-500 ... build-phase silencing at event_manager.gd:472-485 ... re-arms only on EventManager.reset() (event_man* → **All four spans are shifted. _is_eligible begins at :462; the build-phase gate is :466-482; the one_shot guard is :483-487; the cooldown guard is :488-496; the hour-window gate is :497-502. EventManager.reset() is :321-332. (Also: hourly_chance is :538-542 not :537-541, and _window_length_hours is :545-553 not :544-552.) The same shifted spans are repeated across all five entries; the guards themse**
- `ev_mvp_iter_001_scope_creep` — claim: *the paid feature (saas_ops_mobile) that the build was commissioned and invoiced for (FinanceSystem.apply_one_time_cost at product_system.gd:1310)* → **The version-build invoice is FinanceSystem.apply_one_time_cost(ProductCatalog.sum_cost(typed_new), "version_build_commit") at product_system.gd:1312. (The v1 equivalent, tagged "build_commit", is at :1214.)**
- `ev_mvp_iter_003_early_user_feedback` — claim: *This is the only three-chip row in the family.* → **Both rows of this card render three chips - the same entry's own choice-1 chip block lists three ('-1 gun', 'Marka +1', 'Deneyim -2'). It is the only card in the family with three-chip rows, but there are two such rows, not one.**
- `ev_mvp_dev_001_integration_broken` — claim: *the economy reads effective_stability = stability - 0.8 x bug_count (quality_model.gd:67 BUG_STABILITY_COEF := 0.8)* → **The constant and its value are right, but it is declared at quality_model.gd:68 (lines 64-67 are its comment block). The same off-by-one citation recurs in the dev_002, dev_003 and iter_001 entries; the 'born at 0' note cited as quality_model.gd:24-25 is at :25-26.**
- `ev_mvp_bugfix_001_critical_bug` — claim: *"PROBE TALLY ... fires=1 picks=1 across FOUR separate Beta phases (v1 d18-24, v2 d59-63, v3, v4)"* → **v2's Beta ran d61-63, not d59-63. run_full_run_730.log: 'PROBE PLAY day=58 enter_development', 'PROBE PLAY day=61 enter_beta', 'PROBE PLAY day=63 launch'. Days 58-61 were v2's DEVELOPMENT band. (v1's Beta d18-24 is correct: 'PROBE PLAY day=18 enter_beta' / 'day=24 launch'.)**
- `ev_mvp_bugfix_001_critical_bug` — claim: *MAGNITUDE: "its cost varies twentyfold while its permanent gain does not vary at all"* → **About four- to fivefold, not twentyfold. The card's own figures: 150/7,350 = 2.04 % (v1 Beta, day 18) vs 150/28,203 = 0.53 % (day 61) = 3.8x; as runway, 150/50 = 3.0 days vs 150/260 = 0.58 days = 5.2x. Nothing in the comparison reaches 20x.**
- `ev_mvp_bugfix_001_critical_bug` — claim: *PERMANENT_SWING: "+1.714 composite; on a post-ship composite of ~15-18 and NORMALIZE_HALF_SAT 25 that is roughly +3 normalized quality points"* → **+2.2 to +2.6, not ~+3. normalized_quality = 100c/(c+25) (quality_model.gd:102, NORMALIZE_HALF_SAT := 25.0 at :52). At c=15: 16.714/41.714 − 15/40 = +2.57 pts; at c=18: +2.23 pts. The composite figure itself (+4 × 1.5/3.5 = +1.714, product_catalog.gd:210-214) is correct.**
- `ev_mvp_bugfix_001_critical_bug` — claim: *priority: "1 — the only card in this family above 0"* → **Only true of the three ev_mvp_bugfix_* cards. Within the audited family 'mvp_bugfix_debug_unwired', ev_debug_003_cash_warning and ev_seed_closed both carry priority 10 (their own JSON), which the entries themselves state elsewhere.**
- `ev_debug_002_press_inquiry` — claim: *PERMANENT_SWING: "Choice 2's +6 in one click is 12 % of the entire 0-100 band"* → **6 % of the band. set_brand clamps to 0-100 (game_state.gd:326-328), so +6 of 100 points = 6 %.**
- `ev_debug_002_press_inquiry` — claim: *REPEATABLE_COMPOUND: "about 7 fires per 180 days = +42 brand, which is the whole distance from the 50 baseline to the 100 clamp"* → **The distance from 50 to the clamp at 100 is 50 points; +42 is 84 % of it. Saturation would need ~8.3 fires, not 7. (The 7-fires arithmetic itself is right: 21-day cooldown + 1/0.20 = 5 expected days ⇒ ~26-day interval, 180/26 = 6.9.)**
- `ev_debug_002_press_inquiry` — claim: *MAGNITUDE: "+6 ... a quarter of the distance between the brand-collapse floor (15) and the baseline"* → **6/(50−15) = 6/35 = 17.1 %, i.e. about a sixth, not a quarter. (BRAND_COLLAPSE_FLOOR := 15, endings_system.gd:28.)**
- `ev_debug_002_press_inquiry` — claim: *MAGNITUDE: "a permanent sixth of the Series A brand requirement"* → **About a quarter. phase_gate_system.gd:63 is {"type": "brand_above", "value": 24} and the arm is strict (event_manager.gd:381), so the requirement is brand ≥ 25: 6/25 = 24 %. The two fractions in this reason are swapped.**
- `ev_debug_003_cash_warning` — claim: *NO_OP: "resolve_choice appends to _history (event_manager.gd:212)"* → **The history append is event_manager.gd:191 (`_history.append({"id": event_id, "day": GameState.day, "choice": choice_index})`). Line 212 is `_queue.append(event)` inside enqueue(). The substantive claim — resolving any choice consumes the one_shot — is correct.**
- `ev_seed_closed` — claim: *notes: "the one body rewrite that FRANK_UNWIRED.md:60-64 already schedules for the day the seed round is designed"* → **FRANK_UNWIRED.md:59-61 schedules no body rewrite: 'Attaching it. Small, once the round exists: move the file into `data/events/reactive/` and give it a trigger, or inject it from the seed-close seam the way `AngelRoundSystem` injects the cheque. One file moved, one enqueue site.' The phrase 'one body rewrite' is at line 37 and belongs to section 1 (the Series A gate), a different surface. FRANK_UN**

---

## Per-event entries

### ev_b2b_retain_<customer_id>  (e.g. ev_b2b_retain_co_lead_51_13)

```
FILE          scripts/systems/b2b_event_factory.gd — build_retention(), lines 24-82. Injected from scripts/systems/b2b_sales_system.gd:204 (_maybe_enqueue_retention) and scripts/tabs/sales_tab.gd:344 (the "İlgilen →" button). Copy resolves through localization/strings.csv via TranslationServer.translate.
CATEGORY      B2B account
REACHABLE     yes, in a normal run. Seed 424242 / preset full_run fired it 4 times, all at hour 0: day 55 ev_b2b_retain_co_lead_51_13, day 88 ev_b2b_retain_co_lead_81_27, day 113 ev_b2b_retain_co_lead_107_38, day 115 ev_b2b_retain_co_lead_110_39. Every one answered choice 0 ("Söz ver"). PROBE RETAIN reports fires=1 max30=1 discounts=0 for all four accounts — the §8 hysteresis held and no account produced a second card in 275 days.
FIRES         The daily sweep, at hour 00. SalesSystem.daily_tick → B2BSalesSystem.daily_tick (b2b_sales_system.gd:23-43, hard-gated on flag mvp_shipped at :24) → _tick_customer → _tick_lifecycle (:143). When the account's VISIBLE satisfaction is below its HIDDEN tolerance, _tick_at_risk runs (b2b_sales_system.gd:173-193): risk_streak++ and, once risk_streak >= B2BConstants.RISK_TRIGGER_DAYS = 3 (b2b_constants.gd:10) AND the hysteresis window has closed (GameState.day - last_risk_exit_day >= RISK_REENTRY_DAYS = 21, b2b_sales_system.gd:183 / b2b_constants.gd:18), the account is stamped lifecycle_phase="risk" with churn_countdown = CHURN_COUNTDOWN_DAYS = 7 (:185-186) and _maybe_enqueue_retention (:200-204) enqueues the card if can_offer_retention passes (:216-223: market_type b2b, status active, phase == "risk", churn_countdown >= 0, and NOT (assigned_to != "" and cs_escalated)). SECOND ENTRY POINT, player-driven and at any hour: the Sales tab risk row's "İlgilen →" button, sales_tab.gd:342-344, which asks EventManager._active_event_id == "" plus the same can_offer_retention gate.
FREQUENCY     Repeatable. one_shot / cooldown_days / allowed_hours / build_safe on the object are INERT — enqueue (event_manager.gd:200-214) appends straight to _queue and never touches _is_eligible. TWO REAL LATCHES, both in the owning system, neither on the event: (1) ACROSS episodes — Customer.last_risk_exit_day (customer.gd:62), stamped by _recover (b2b_sales_system.gd:433) and by _tick_healthy's risk branch (:241) and read at :183 against RISK_REENTRY_DAYS = 21, so the daily sweep can re-offer the same account at most once every 21 days. (2) WITHIN one Risk episode there is NO latch at all: "Oyala" and "Kendi haline bırak" do not recover the account, so can_offer_retention stays true and the Sales tab button rebuilds and re-enqueues the identical id as often as the player clicks (the dedupe at event_manager.gd:209 only rejects a card already queued or already showing). What actually bounds that re-open loop is the per-seam use caps, not the card: hold() returns at retain_stalls >= RETAIN_DELAY_MAX_USES = 2 (b2b_sales_system.gd:317-318), apply_discount() returns at retain_discounts >= RETAIN_DISCOUNT_MAX_USES = 2 (:334-335), and any discount or promise calls _recover, which ends the episode.
```

**TITLE (TR)** Müşteri riski  ·  **TITLE (EN)** Account at risk
**SUBTITLE (TR)** MISSING — build_retention never assigns ev.subtitle; GameEvent.subtitle defaults to "" (event.gd:31), so no subtitle line renders.  ·  **(EN)** MISSING — ev.subtitle_en likewise never assigned (event.gd:75).
**PRIORITY** 0 — GameEvent.priority default (event.gd:60); build_retention never assigns it. INERT regardless: _ordered_by_priority (event_manager.gd:120-127) runs only over the pool candidate lists at :73 and :111, and enqueue appends directly to _queue.

**BODY (TR)**

> Sisteminiz son zamanlarda sık sık aksıyor, ekibim işini yapamıyor.

**BODY (EN)**

> Your system has been failing often lately and my team cannot do their job.

**CHOICE 1** — `Söz ver: 'mobil uygulama'` / `Promise it: 'mobile app'`

  - **EFFECTS** `b2b_promise_create` — {"type": "b2b_promise_create", "customer_id": c.id, "feature_id": c.pain_feature_id, "deadline_days": B2BConstants.PROMISE_DEADLINE_DAYS = 14}  (b2b_event_factory.gd:62-63)
    event_manager.gd:794-796 → B2BSalesSystem.accept_promise (b2b_sales_system.gd:298-308): PromiseRegistry.create(customer_id, feature_id, 14), then _recover(c, bump) where bump = RETAIN_SAT_BUMP = 8, HALVED to 4 (int(8/2)) when GameState flag "b2b_broke_<customer_id>" is true. _recover (:427-443): set_satisfaction(+8 or +4), set_risk_streak(0), and because the phase is "risk": set_churn_countdown(-1) — the 7-day counter is cleared on the spot — set_last_risk_exit_day(GameState.day), set_lifecycle_phase("onboarding" if day < onboarding_until else "active"). DEFERRED HALF, 14 days later, PromiseRegistry.tick_deadlines → B2BSalesSystem.on_promise_resolved (:448-493): KEPT → tolerance -5 (PROMISE_KEPT_TOLERANCE, permanent and never decayed), trust_offset +6.0, _recover(c, PROMISE_KEPT_SAT = +15), flag b2b_broke=false. PARTIAL → satisfaction -5, trust_offset -2.0. BROKEN → satisfaction -20, tolerance +5, trust_offset -12.0, GameState.brand -3, flag b2b_broke=true. Played run: promise created day 55 deadline 69, resolved KEPT day 63; the account's hidden tolerance moved 56 → 51 and stayed there.
  - **EFFECTS** `reputation` — {"type": "reputation", "delta": B2BConstants.RETAIN_PROMISE_REP = 1}  (b2b_event_factory.gd:64)
    event_manager.gd:569 → GameState.set_reputation(GameState.reputation + 1). Unconditional and irreversible — no branch of on_promise_resolved ever touches reputation again, so the point survives even when the promise later breaks.
  - **DURATION** permanent (the +8/+4 satisfaction, the cleared countdown, the +1 reputation and the eventual ±5 tolerance move are all permanent state writes); the promise debt itself is a 14-day clock.
  - **CHIP** Müşteri kalır · söz borcu   |   İtibar +1        (EN: "The customer stays · a promise owed" | "Reputation +1")  — event_modal.gd:547 and :492
  - **UNLOCK** NONE — no unlock_condition. The row is present or absent by CONSTRUCTION: b2b_event_factory.gd:59-60 requires c.pain_feature_id != "" AND the feature is not already in GameState flag "mvp_components" AND PromiseRegistry.has_open_for(c.id) is false. When any of those fails the row simply is not built and "Oyala" becomes choice index 0.

**CHOICE 2** — `Oyala` / `Stall them`

  - **EFFECTS** `b2b_retain_delay` — {"type": "b2b_retain_delay", "customer_id": c.id}  (b2b_event_factory.gd:67)
    event_manager.gd:797-798 → B2BSalesSystem.hold (b2b_sales_system.gd:311-321): if c.retain_stalls >= RETAIN_DELAY_MAX_USES = 2 it RETURNS and nothing at all happens; otherwise retain_stalls += 1 and, while phase == "risk" and churn_countdown >= 0, set_churn_countdown(churn_countdown + RETAIN_DELAY_DAYS = 3). So: click 1 → 7 days becomes 10; click 2 → 13; click 3 and every click after → zero effect. The account is NOT recovered — it stays in Risk, keeps paying, the counter keeps running.
  - **EFFECTS** `brand` — {"type": "brand", "delta": B2BConstants.RETAIN_DELAY_BRAND = -1}  (b2b_event_factory.gd:68)
    event_manager.gd:567 → GameState.set_brand(GameState.brand - 1). Applied on EVERY click, including the third and later ones where the delay half is a silent no-op — and uncapped, because the row carries no unlock_condition.
  - **DURATION** +3 days on the churn countdown, twice per account for the whole run; the -1 brand is permanent and applies every time.
  - **CHIP** Kısa vadeli hamle   |   Marka -1        (EN: "A short-term move" | "Brand -1")  — event_modal.gd:548 and :491. The chip never states the +3 days, never states the 2-use cap, and renders IDENTICALLY on the click where hold() early-returns and nothing moves.
  - **UNLOCK** NONE — plain _choice (b2b_event_factory.gd:66), no unlock_condition. Contrast the discount row two lines below, which does get a visible locked state at its cap.

**CHOICE 3** — `İndirim ver` / `Offer a discount`

  *desc:* İki kez indirim verdin. Bu hesabı fiyat değil ürün tutar. / You have discounted twice. Price will not keep this account; the product will.

  - **EFFECTS** `b2b_retain_discount` — {"type": "b2b_retain_discount", "customer_id": c.id, "mrr_delta": -int(round(float(c.mrr) * B2BConstants.RETAIN_DISCOUNT_PCT))} with RETAIN_DISCOUNT_PCT = 0.15  (b2b_event_factory.gd:40, :71). Worked example from the played run, day 55, co_lead_51_13 at mrr 1700 → mrr_delta = -255.
    event_manager.gd:799-800 → B2BSalesSystem.apply_discount (b2b_sales_system.gd:324-340): if c.retain_discounts >= RETAIN_DISCOUNT_MAX_USES = 2 it RETURNS (the seam's own defense, because resolve_choice does not re-check unlocks); otherwise set_retain_discounts(+1), CustomerRegistry.set_mrr(c.id, c.mrr - 255), SalesSystem.reflect_mrr(), then _recover(c, RETAIN_SAT_BUMP = 8) — satisfaction +8, risk_streak 0, countdown cleared to -1, last_risk_exit_day stamped, phase back to onboarding/active. The MRR cut is PERMANENT; nothing ever restores it. Two cuts compound multiplicatively: 1700 → 1445 → 1228, i.e. -$472/month forever on that account.
  - **EFFECTS** `reputation` — {"type": "reputation", "delta": B2BConstants.RETAIN_DISCOUNT_REP = -1}  (b2b_event_factory.gd:72)
    event_manager.gd:569 → GameState.set_reputation(GameState.reputation - 1).
  - **DURATION** permanent — the MRR cut, the reputation point and the recovery are all permanent; capped at 2 uses per account across BOTH discount channels (this card and the CS complaint/renewal cards).
  - **CHIP** Müşteri kalır · MRR -$255   |   İtibar -1        (EN: "The customer stays · MRR -$255" | "Reputation -1")  — event_modal.gd:549 and :492. _fmt_money_delta truncation note: a cut of 1000-9999 renders one decimal with a RAW "." separator regardless of locale (e.g. a 2000-MRR account gives -300 → "-$300"; an 8000-MRR enterprise gives -1200 → "-$1.2K").
  - **UNLOCK** unlock_condition = {"type": "b2b_discounts_below", "customer_id": c.id, "value": B2BConstants.RETAIN_DISCOUNT_MAX_USES = 2}  (b2b_event_factory.gd:317-318, via _discount_choice). Re-evaluated at RENDER by EventManager.is_condition_met (event_modal.gd:368 → event_manager.gd:430). When locked the row stays visible, dims to modulate alpha 0.5, becomes mouse-inert, its effect chips are SUPPRESSED entirely (event_modal.gd:412-425) and the right-hand badge falls back to tr("LOCK_CHIP") = "KİLİTLİ" / "LOCKED", because the factory sets ch.description and not ch.unlock_reason_text. The reason renders as the italic sub-line: "İki kez indirim verdin. Bu hesabı fiyat değil ürün tutar." / "You have discounted twice. Price will not keep this account; the product will." SEAM BUG worth recording: that sub-line is baked at BUILD time (b2b_event_factory.gd:319-320) while the lock is re-evaluated at RENDER time, so a card built at 1 discount and rendered after a queued CS discount card pushed the account to 2 shows a dimmed row with "KİLİTLİ" and NO reason at all.

**CHOICE 4** — `Kendi haline bırak` / `Leave it alone`

  - **EFFECTS** `b2b_retain_ignore` — {"type": "b2b_retain_ignore", "customer_id": c.id}  (b2b_event_factory.gd:79)
    event_manager.gd:801-802 → B2BSalesSystem.ignore_risk (b2b_sales_system.gd:343-347), whose entire body is `pass`. A LITERAL no-op, and deliberately so: the account stays in Risk, keeps paying, and the already-running churn_countdown continues on the daily tick until _tick_at_risk (:189-192) hits zero and calls _churn, which is where the CHURN_BRAND = -2 hit lands (:282) — not here.
  - **DURATION** one-time (nothing changes at all).
  - **CHIP** müdahale yok · sayaç işlemeye devam eder        (EN: "no intervention · the counter keeps running") — event_modal.gd:550. The lowercase leading word is byte-exact in the CSV.
  - **UNLOCK** NONE — plain _choice, no unlock_condition.

**FLAGS** — PERMANENT SWING, FREE LUNCH, NO OP, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **PERMANENT SWING** — Two of them. (1) PROMISE_KEPT_TOLERANCE = -5 (b2b_constants.gd:184, applied at b2b_sales_system.gd:455) permanently lowers the account's hidden churn bar and NOTHING ever decays it — CustomerRegistry.set_tolerance has exactly two callers, both in on_promise_resolved, and only clamps 0..100 (customer_registry.gd:256-262). Measured in the played run: co_lead_51_13's tolerance went 56 → 51 on day 63 and never moved again. Against TOLERANCE_PER_SCALE = 9, three kept promises (-15) drop a mid account from 51 to 36 — below the target even a WEAK product produces (the calibration note at b2b_constants.gd:26-38 measures a bad v1 at T=42), i.e. the account becomes structurally unable to churn. (2) "İndirim ver" cuts that account's MRR by 15 % permanently; two cuts compound to -27.75 %. 180-day projection for one discount on the day-55 account (mrr 1700, cut 255): MRR converts to cash at mrr/30 per day (finance_system.gd:151, GameState.DAYS_PER_MONTH = 30), so -255/mo = -$8.50/day = -$1,530 of cash over 180 days; two cuts = -$472/mo = -$15.73/day = -$2,832 over 180 days, forever after that.
- **FREE LUNCH** — "Söz ver" pays +1 İtibar (b2b_event_factory.gd:64, RETAIN_PROMISE_REP) the instant it is clicked, and NO branch ever takes it back: on_promise_resolved's "broken" arm (b2b_sales_system.gd:477-493) moves satisfaction, tolerance, trust_offset, brand and a flag — never reputation. So the reputation point is upside with no possible cost. The larger free lunch is the KEPT path in a run where the founder was going to ship that feature anyway: the played run's four promises were all kept (PROBE PROMISE, days 55→63, 88→96, 113→119, 115→119, kept in 8, 8, 6 and 4 days against a 14-day deadline), each paying +8 satisfaction on the click, +15 more on delivery, tolerance -5 permanently and trust_offset +6.0 — for work already on the roadmap. "Kendi haline bırak" is the inverse: no cost and no upside.
- **NO OP** — Twice. (1) "Kendi haline bırak" — its only modifier routes to ignore_risk, whose body is `pass` (b2b_sales_system.gd:343-347). Deliberate, and the chip declares it honestly. (2) "Oyala" DEGRADES into a no-op after two uses: hold() early-returns at b2b_sales_system.gd:317-318, so the third and every later click changes nothing about the account while still charging -1 brand and still showing the same "Kısa vadeli hamle" chip. That state is reachable in one Risk episode by clicking "İlgilen" three times.
- **INVISIBLE** — The most durable consequences of this card never surface anywhere. Customer.tolerance is explicitly a hidden field with no signal (customer_registry.gd:256-257 "the UI never shows raw tolerance") and grep over scripts/tabs + scripts/modals finds no reader — so the permanent ±5 tolerance move is invisible. Customer.trust_offset is likewise hidden (customer_registry.gd:274, zero readers outside the systems layer), so PROMISE_KEPT_OFFSET +6.0 / PROMISE_BROKEN_OFFSET -12.0 — the term that actually differentiates one account's satisfaction target from another's — is invisible. And GameState flag "b2b_broke_<id>" (b2b_sales_system.gd:471/493), which silently halves the next promise's satisfaction bump from 8 to 4 (:306-307), has no player-facing surface at all.
- **DEAD REFERENCE** — ev.tags = ["build_safe", "b2b_retention"] (b2b_event_factory.gd:29) with the inline comment "survives the active-build gate; cost-line render". BOTH halves are dead on this card. "build_safe" is only read by _is_eligible (event_manager.gd:473), which enqueue bypasses entirely — the tag does nothing for a code-built card. And "b2b_retention" has ZERO readers anywhere in scripts/ or scenes/: no cost-line renderer, nothing. Grep returns only the write site.
- **COPY LIE** — "Oyala" / "Stall them" with the chip "Kısa vadeli hamle" / "A short-term move" is rendered byte-identically on the third and every later click, when hold() early-returns at b2b_sales_system.gd:317-318 and NO move of any kind occurs. The chip asserts a move the engine does not make, and takes -1 brand for it. The card contains the counter-example in its own body: the discount row at the same cap goes visibly locked with an explicit written reason (B2B_DISCOUNT_SPENT_DESC), so the grammar for "this lever is spent" exists in this very card and the stall row does not use it.
- **VOICE** — Two findings, one of them the card's own law. (a) The factory's copy law at b2b_event_factory.gd:16 reads "no raw numbers, no em-dash, no emoji" — and two of the fourteen body strings it draws from carry an em dash in the English column: B2B_COMPLAINT_CONSTRUCTION "The site crew cannot stay connected — it drops constantly. This is no way to work." and B2B_COMPLAINT_LEGAL "We cannot reach our files — it goes down several times a day." (b) The same fourteen-row voice pool is reused verbatim by the CS complaint card (B2BConstants.complaint_voice at b2b_event_factory.gd:236), so one account can deliver the identical sentence in two structurally different decisions. CLEAN on the rest: no clock anywhere in the copy, which is correct for a card that fires at hour 00; no UI tab named in the fiction; the speaker is the customer's sector contact ("Saha Sorumlusu", "Başhekim Yardımcısı", …) rather than a narrator; and no scene-setting prose in anyone's mouth.

<details><summary>Flags checked and not applicable (4)</summary>

- *REPEATABLE COMPOUND* — Repeatable — yes, on two axes (the 21-day hysteresis re-entry, and unlimited re-opens of the SAME card via sales_tab.gd:342-344 inside one Risk episode). Compounding — no, on every upside axis: hold() caps at 2 (b2b_sales_system.gd:317-318), apply_discount() caps at 2 (:334-335), only one promise may be open per account (PromiseRegistry.has_open_for, b2b_event_factory.gd:60), and both recovering answers call _recover, which ends the episode and closes the button. The one thing that DOES compound is a cost, not a gain: the -1 brand on "Oyala" is uncapped and lands on every click including the spent ones, so a player who keeps re-opening and stalling bleeds brand indefinitely for nothing.
- *IDENTICAL OPTIONS* — Four rows, four distinct modifier sets (promise+rep / delay+brand / discount+rep / ignore). Near-collision worth recording: once retain_stalls has hit 2, "Oyala" and "Kendi haline bırak" have the same effect on the ACCOUNT (none) and differ only by the -1 brand — making the stall row strictly dominated by the do-nothing row, with nothing on screen saying so.
- *BLIND* — Objective test passed: all four modifier types have arms in _describe_modifier and none falls through to the terminal `return {}` — b2b_promise_create :547, b2b_retain_delay :548, b2b_retain_discount :549, b2b_retain_ignore :550, plus brand :491 and reputation :492. What the chips DO NOT say is nonetheless substantial: "Müşteri kalır · söz borcu" names neither the 14-day deadline nor the break penalty (-20 satisfaction, +5 tolerance, -3 brand, -12 trust), and "Kısa vadeli hamle" names neither the +3 days nor the 2-use cap. Recorded here rather than flagged, because a chip does render.
- *MAGNITUDE* — In band for the phase it fires in. Played-run context on the four firing days (PROBE STATE): day 55 cash $29,111 / MRR $3,125 / burn $50 per day; day 88 cash $24,877 / MRR $8,905 / burn $260; day 113 cash $26,231 / MRR $14,745; day 115 cash $26,711 / MRR $15,245. The discount on the day-55 account would have been -$255/mo, i.e. 8.2 % of ALL company revenue and 15 % of that account's — noticeable, deliberately so, and the 2-use cap exists exactly because an uncapped version was measured bleeding MRR from $7,349 to $2,534 (b2b_constants.gd:75-80). The satisfaction bump is deliberately small: RETAIN_SAT_BUMP = 8 against SAT_DRIFT_STEP = 3/day buys roughly 2.7 days of drift. The one number that is arguably out of band is the tolerance move, and it is filed under PERMANENT_SWING above rather than double-counted here.

</details>

**Notes.** Body text is derived per sector, not authored per card: ev.body_text = B2BConstants.complaint_voice(c.industry) (b2b_event_factory.gd:37), which builds the key "B2B_COMPLAINT_" + industry.to_upper() and falls back to B2B_COMPLAINT_FALLBACK when the row is missing (b2b_constants.gd:135-136, :151-156). The fourteen rows, verbatim TR: CONSTRUCTION "Sahadaki ekip sisteme bağlanamıyor, bağlantı sürekli kopuyor. Böyle iş yürümez." · HEALTH "Ekranlar sürekli çöküyor, hasta kapıda beklerken sistemi açamıyoruz." · LOGISTICS "Sevkiyat saatinde sistem donuyor, operasyon aksıyor." · INSURANCE "Sisteminiz son haftalarda sürekli düşüyor, ekibim poliçe işlerini yürütemiyor." · MANUFACTURING "Hat başında sistem takılıyor, üretim raporu tutmuyor." · RETAIL "Yoğun saatte sistem kilitleniyor, kasa akmıyor." · REAL_ESTATE "Sistem sık sık kopuyor, ekip müşteriye dönemiyor." · TEXTILE "Sipariş ekranı sürekli hata veriyor, üretim planı kayıyor." · LEGAL "Dosyalara erişemiyoruz, sistem gün içinde defalarca düşüyor." · TECHNOLOGY "Sisteminiz sürekli hata veriyor, ekibimiz üretime dönemiyor." · ECOMMERCE "Kampanya saatinde sistem çöküyor, siparişleri kaybediyoruz." · MEDIA "Yayın anında sistem donuyor, akış kesiliyor." · FINANCE "Sistem gün içinde düşüyor, işlemler askıda kalıyor." · TESTING and FALLBACK both "Sisteminiz son zamanlarda sık sık aksıyor, ekibim işini yapamıyor." (the fixture sector and the fallback share the string; that pair is the one quoted in body_tr/body_en above). Speaker strip: ev.speaker_name = c.company_name, ev.speaker_role = B2BConstants.sector_contact(c.industry) (13 rows, e.g. B2B_CONTACT_CONSTRUCTION "Saha Sorumlusu"/"Site Supervisor", fallback "Yetkili"/"Contact"), ev.speaker_status = SALES_CHIP_RISK "RİSK ALTINDA"/"AT RISK" with kind "negative", plus one accent chip when churn_countdown >= 0: SALES_CHURN_COUNTDOWN "Churn'e ~{n} gün"/"~{n} days to churn" — at the sweep's enqueue that always reads 7, because set_churn_countdown(7) at b2b_sales_system.gd:186 writes through to the same instance one line before _maybe_enqueue_retention. The whole card is frozen at BUILD time (countdown chip, discount figure, promise-row presence, locked sub-line), so a card that waits behind other modals renders stale numbers. Localization contract: title_en / subtitle_en / body_text_en / label_en are all empty by design — TranslationServer.translate already returns the active locale's string (b2b_event_factory.gd:9-14 explains why it is TranslationServer and not tr() in a static). No mentor_line: Frank never speaks on a churn decision. Nothing in this card is a NO-OP dispatcher reference — all six modifier types used (b2b_promise_create, b2b_retain_delay, b2b_retain_discount, b2b_retain_ignore, brand, reputation) have live arms at event_manager.gd:794-802, :567, :569.

---

### ev_b2b_expand_<customer_id>  (e.g. ev_b2b_expand_co_lead_31_4)

```
FILE          scripts/systems/b2b_event_factory.gd — build_expansion(), lines 85-108. Injected from scripts/systems/b2b_sales_system.gd:263 (_tick_healthy) and scripts/tabs/sales_tab.gd:367 (the "Değerlendir →" button). Copy resolves through localization/strings.csv via TranslationServer.translate.
CATEGORY      B2B account
REACHABLE     yes, in a normal run, and heavily. Seed 424242 / preset full_run produced 25 DISTINCT expansion cards between day 77 and day 212, every one at hour 0, every one answered "Büyüt": days 77, 79, 83, 97, 104, 112, 116, 118, 123, 130, 132, 137, 143, 155, 157, 159, 161, 171, 174, 176, 180, 195, 199, 207, 212. PROBE TALLY shows each id at fires=1 picks=1 — no id fired twice.
FIRES         The daily sweep, at hour 00. SalesSystem.daily_tick → B2BSalesSystem.daily_tick (b2b_sales_system.gd:23-43, gated on flag mvp_shipped) → _tick_customer → _tick_lifecycle (:143-146). When the account's satisfaction is at or above its hidden tolerance, _tick_healthy runs (:226-263): it clears the risk streak, reads lifecycle_phase ONCE at entry, returns for any phase other than "active" (:256-257), then asks can_offer_expansion (:259, defined :269-274) — market_type == "b2b", status == "active", last_expansion_day < 0, and GameState.day - c.acquired_on_day >= B2BConstants.EXPANSION_MATURE_DAYS = 45 (b2b_constants.gd:20). On a pass it promotes the account to lifecycle_phase "expansion" (:262) and enqueues the card (:263). Observed cadence matches: co_lead_31_4 was acquired day 31 and fired day 77 (46 days). SECOND ENTRY POINT, player-driven and at any hour: the Sales tab's "Değerlendir →" button, which is only rendered for a row already in lifecycle_phase "expansion" (sales_tab.gd:293-295) and asks EventManager._active_event_id == "" plus the identical can_offer_expansion gate (sales_tab.gd:365-367). There is NO satisfaction test on the button path — but there is no way to reach that row without the sweep's healthy-path promotion.
FREQUENCY     ONE PER ACCOUNT PER RUN — and this is the answer to the 2026-08-06 S1-1 finding. one_shot / cooldown_days / allowed_hours / build_safe are INERT (enqueue bypasses _is_eligible, event_manager.gd:200-214). The real latch is Customer.last_expansion_day (customer.gd:69, "-1 = expansion moment not yet offered"), stamped on BOTH answers — expand() at b2b_sales_system.gd:385 and decline_expansion() at :398, each via CustomerRegistry.set_last_expansion_day — and read by can_offer_expansion at :272-273, which BOTH the sweep and the Sales-tab button go through. A second, redundant latch backs it up: the promotion to lifecycle_phase "expansion" at :262, after which _tick_healthy's `if phase_at_entry != "active": return` (:256) can never reach the enqueue again. Both answers also write the phase back to "active" (:386-387, :399-400) so the account resumes normal lifecycle ticking. VERDICT ON S1-1: the daily re-fire is CLOSED — 25 distinct ids, all fires=1, across 275 days. The free-MRR pump itself is NOT closed; it is now metered at one click per account.
```

**TITLE (TR)** Büyüme fırsatı  ·  **TITLE (EN)** Growth opening
**SUBTITLE (TR)** MISSING — build_expansion never assigns ev.subtitle; GameEvent.subtitle defaults to "" (event.gd:31).  ·  **(EN)** MISSING — ev.subtitle_en likewise never assigned (event.gd:75).
**PRIORITY** 0 — GameEvent.priority default (event.gd:60); build_expansion never assigns it, and it is inert for enqueued cards (the priority sort at event_manager.gd:120-127 only runs over pool candidates).

**BODY (TR)**

> Ekibimiz büyüyor, sistemi başka birimlere de yaymak istiyoruz. Koltuk ekleyelim.

**BODY (EN)**

> Our team is growing and we want to roll the system out to other units. Let us add seats.

**CHOICE 1** — `Büyüt` / `Expand`

  - **EFFECTS** `b2b_expand` — {"type": "b2b_expand", "customer_id": c.id, "add_seats": B2BConstants.expansion_seats(c.company_size), "per_seat_mrr": B2BConstants.EXPANSION_PER_SEAT_MRR = 120}  (b2b_event_factory.gd:98, :101-102). expansion_seats delegates to CustomerArchetypes.expansion_seats (b2b_constants.gd:272-273), which reads the archetype table at customer_archetypes.gd:24/32/40 → small 3, mid 6, enterprise 12 (unknown/blank falls back to small). So the three possible clicks are EXACTLY: +3 seats / +$360 MRR, +6 seats / +$720 MRR, +12 seats / +$1,440 MRR.
    event_manager.gd:808-810 → B2BSalesSystem.expand (b2b_sales_system.gd:371-387): returns on a null customer or add_seats <= 0; otherwise CustomerRegistry.set_seats(c.id, c.seats + n), CustomerRegistry.set_mrr(c.id, c.mrr + n*120), SalesSystem.reflect_mrr() (the canonical MRR bridge to GameState), GameState.run_customers_expanded += 1, EventBus.customer_expanded.emit(c.id, c.seats), CustomerRegistry.set_last_expansion_day(c.id, GameState.day), and lifecycle_phase "expansion" → "active". NO cash cost, NO burn increase, NO morale cost, NO satisfaction cost, NO support-load cost (the field was deleted — see DEAD_REFERENCE). MEASURED IN THE PLAYED RUN, per-account MRR before → after on the firing day: day 77 co_lead_31_4 425 → 785 (+360, i.e. +84.7 % of that account's revenue in one click); day 97 co_lead_51_13 1700 → 2420 (+720, +42.4 %); day 130 co_lead_81_27 2000 → 2720 (+720); day 212 co_lead_164_61 500 → 860 (+360). Eighteen of the 25 were +$360 and seven were +$720, totalling +$11,520/month of permanent MRR added for free.
  - **DURATION** permanent — recurring MRR, never reversed, and the seats never come back down. One click per account for the whole run.
  - **CHIP** Koltuk +3 · MRR +$360   (small)   /   Koltuk +6 · MRR +$720   (mid)   /   Koltuk +12 · MRR +$1.4K   (enterprise)        EN: "Seats +3 · MRR +$360" / "Seats +6 · MRR +$720" / "Seats +12 · MRR +$1.4K" — event_modal.gd:553-556, kind hardcoded positive; the "+" before {seats} is literal in the CSV string. Formatter note: 12*120 = 1440 crosses _fmt_money_delta's 1000 boundary (event_modal.gd:614-615) and renders as "+$1.4K" with a raw "." decimal in BOTH locales — the enterprise chip understates the figure by $40.
  - **UNLOCK** NONE — plain _choice (b2b_event_factory.gd:100), no unlock_condition.

**CHOICE 2** — `Şimdilik gerek yok` / `Not needed yet`

  - **EFFECTS** `b2b_expand_decline` — {"type": "b2b_expand_decline", "customer_id": c.id}  (b2b_event_factory.gd:105)
    event_manager.gd:811-812 → B2BSalesSystem.decline_expansion (b2b_sales_system.gd:390-400): CustomerRegistry.set_last_expansion_day(c.id, GameState.day) and, if the phase is "expansion", set_lifecycle_phase back to "active". No MRR, no seats, no counter, no brand, no reputation, no satisfaction. The only state it writes is the latch that closes the offer for the rest of the run — as the seam's own comment says, declining is an answer, not a postponement.
  - **DURATION** permanent in the sense that it burns the account's one expansion moment; zero economic effect.
  - **CHIP** Değişiklik yok        (EN: "No change") — event_modal.gd:557
  - **UNLOCK** NONE — plain _choice, no unlock_condition.

**FLAGS** — PERMANENT SWING, FREE LUNCH, MAGNITUDE, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **PERMANENT SWING** — Magnitudes today, read from source: EXPANSION_PER_SEAT_MRR = 120 (b2b_constants.gd:249) × expansion_seats 3/6/12 (customer_archetypes.gd:24/32/40) = +$360 / +$720 / +$1,440 of permanent monthly MRR per click, plus +3/+6/+12 seats. The 2026-08-06 filing of "+6 seats / +$720 MRR" is still EXACTLY the mid-archetype number — the per-click magnitude has not changed at all; only the bound has. 180-DAY PROJECTION. MRR converts to cash at mrr / GameState.DAYS_PER_MONTH = 30 per day (finance_system.gd:151), verified against the log (day 213→214: cash +823 = 32495/30 − 260 burn). Per single click: small +$12.00/day → +$2,160 over 180 days; mid +$24.00/day → +$4,320; enterprise +$48.00/day → +$8,640 — and the MRR keeps running past day 180, forever. Per FAMILY, at the played run's demonstrated rate: 25 clicks in the 135 days from day 77 to day 212 (one every 5.4 days) added +$11,520/month = +$384/day of cash. Held for 180 days that is +$69,120, against a starting cash of $10,000 and a whole-company daily burn of $260 — the free clicks alone out-earn the entire payroll by 1.48×. Extrapolated to a full 180-day window at the same cadence, ~33 clicks ≈ +$15,200/month.
- **FREE LUNCH** — The defining flaw of this card and the live half of the 2026-08-06 S1-1 finding. "Büyüt" is pure upside with literally no cost anywhere in the seam: B2BSalesSystem.expand (b2b_sales_system.gd:371-387) writes seats up, MRR up, a run counter, a signal and the latch — and touches nothing else. No cash, no burn, no satisfaction, no morale, no reputation, no brand, no support pressure. The alternative row is not a trade-off either: "Şimdilik gerek yok" has neither upside nor cost (it only stamps the latch), so it is strictly dominated. By the EVENT AUTHORING LAW's own test — no fake choices — this is a one-button card wearing two buttons: the played run answered "Büyüt" 25 times out of 25 because there is no reason on the screen or in the engine to ever answer otherwise.
- **MAGNITUDE** — Out of band on the account axis, in band on the company axis at the end and badly out of band at the start. Firing-day context from PROBE STATE: FIRST fire, day 77 — cash $25,679, company MRR $4,900 before the click, burn $260/day, 8 customers, 1 employee, phase 2; the click added $360, i.e. 7.3 % of the ENTIRE company's revenue from one free button, and it moved that one account 425 → 785, an +84.7 % raise. Day 130 — company MRR $18,950, the click added $720 (3.8 %) and moved co_lead_81_27 2000 → 2720. LAST fire, day 212 — cash $83,814, MRR $32,135, +$360 (1.1 %). The trajectory is the problem: the card's magnitude is largest, relative to the company, exactly when the company is smallest and most fragile. Cumulatively the family delivered $11,520 of the run's $32,495 closing MRR (35.5 %) and $384/day of the run's $823/day net cash flow, at zero cost — while the run ended profitable_bootstrap with runway=INF from day 120 onward.
- **INVISIBLE** — Partially. The primary effects are all visible: seats surface through CustomerRegistry.set_seats → EventBus.customer_seats_changed (customer_registry.gd:196-208), MRR through SalesSystem.reflect_mrr into GameState, and both feed the Sales tab meta line and the top bar. But GameState.run_customers_expanded (game_state.gd:222), incremented at b2b_sales_system.gd:381 and carried into the run ledger dict at game_state.gd:678, has NO renderer anywhere: a grep over scripts/ and scenes/ for "expanded" outside the writer returns only endings_copy.gd:535, which is a test fixture, and sales_tab.gd:43, which is a refresh subscription to the signal rather than a display of the count. The counter is written, saved and never shown. Customer.last_expansion_day, the latch that governs the whole card's frequency, is likewise invisible — nothing tells the player this offer was their only one.
- **DEAD REFERENCE** — Two. (1) build_expansion's own docstring at b2b_event_factory.gd:87 states "Accepting raises support load (feeds the need for a CS rep)" — the ONLY cost the card ever claimed to have. It does not exist: Customer.support_load was deleted (customer.gd:54 "written twice, read never"), B2BConstants.support_load_for() was deleted (b2b_constants.gd:55), and expand() carries a comment acknowledging the removal (b2b_sales_system.gd:378-380) while arguing the pressure survives because the request channel reads `scale` — but expansion does not raise `scale`, so an expanded account generates exactly the same request load as before. The stated CS-pressure feedback loop is severed. (2) ev.tags = ["build_safe", "b2b_expansion"] (b2b_event_factory.gd:92): "build_safe" is only read by _is_eligible (event_manager.gd:473), which enqueue bypasses, and "b2b_expansion" has zero readers anywhere in scripts/ or scenes/.
- **COPY LIE** **[corrected by the second reader]** — The player-facing copy is accurate. B2B_EV_EXPANSION_BODY says the customer wants to roll the system out to other units and add seats; the chip promises seats and MRR; expand() delivers exactly those seats and exactly that MRR through the owning seams. Nothing on screen asserts a support-load cost — the false claim about support load lives only in the source docstring, and is filed under DEAD_REFERENCE.
- **VOICE** — ONE fixed sentence for every account, every sector, every run: ev.body_text = TranslationServer.translate("B2B_EV_EXPANSION_BODY") (b2b_event_factory.gd:97), a flat key with no sector derivation. In the played run, 25 different companies delivered the identical two sentences on 25 different days — while the card still attaches each company's sector-specific contact role ("Saha Sorumlusu", "Operasyon Müdürü", …) via B2BConstants.sector_contact at :94, so a Site Supervisor and a CTO say word-for-word the same thing. The sibling retention card in the same file reaches a 13-row sector voice pool for exactly this reason; the positive family got none. Clean on the rest: no clock (correct for a card that fires at hour 00), no dash in either locale, no UI tab named in the fiction, no scene-setting prose in the customer's mouth, no raw numbers in the copy.

<details><summary>Flags checked and not applicable (4)</summary>

- *REPEATABLE COMPOUND* **[corrected: was flagged, refuted]** — Not per account — the last_expansion_day latch genuinely closes that door, and the played run proves it (25 ids, all fires=1). But the CARD IS A FAMILY TEMPLATE that re-instantiates for every account the sales desk signs, and its effect is permanent ADDITIVE MRR, so the family compounds with book size: every new customer that survives 45 days brings one more free permanent raise. In the played run that produced +$11,520/month, which is 35.5 % of the day-275 MRR of $32,495 — better than a third of the company's entire revenue arrived through a button with no downside. The compounding is bounded only by how many accounts the player can sign, which is exactly the axis Calibration Law 1 says must never stop mattering.
- *NO OP* **[corrected: was flagged, refuted]** — "Şimdilik gerek yok" writes no economic state at all — decline_expansion (b2b_sales_system.gd:390-400) sets the latch and the phase and nothing else. It is not a pure no-op in the strict sense (the latch it stamps is meaningful: it permanently forfeits the account's one expansion moment), which is why the chip "Değişiklik yok" is arguably a half-truth — the change it makes is invisible and irreversible, and the chip says there is none.
- *IDENTICAL OPTIONS* — Two rows with genuinely different modifiers (b2b_expand vs b2b_expand_decline) and different outcomes (+seats/+MRR vs nothing). They are not identical; they are asymmetric — see FREE_LUNCH.
- *BLIND* — Objective test passed: both modifier types have arms in _describe_modifier (b2b_expand at event_modal.gd:553-556, b2b_expand_decline at :557); neither falls through to the terminal `return {}`. The expand chip is unusually good — it is the file's own precedent for putting two facts on one chip, and it states both the seat count and the exact MRR. The one thing not disclosed is that answering AT ALL, in either direction, permanently forfeits the account's only expansion moment.

</details>

**Notes.** Speaker strip: ev.speaker_name = c.company_name, ev.speaker_role = B2BConstants.sector_contact(c.industry), ev.speaker_status = SALES_CHIP_EXPANSION "BÜYÜMEK İSTİYOR" / "WANTS TO GROW" with kind "positive" (b2b_event_factory.gd:93-96). No speaker_chips, no mentor_line, no character_id — the speaker is a Customer, not a CharacterRegistry character. Localization contract: title_en / subtitle_en / body_text_en / label_en are all empty by design; TranslationServer.translate already returns the active locale (b2b_event_factory.gd:9-14). THE S1-1 RE-AUDIT, stated plainly: the 2026-08-06 audit filed "+6 seats / +$720 MRR per matured account, one click, no cost, re-firing daily forever". Today, from source — the PER-CLICK MAGNITUDE IS UNCHANGED ($120/seat × 3/6/12 seats = $360/$720/$1,440, b2b_constants.gd:249 + customer_archetypes.gd:24/32/40). The FREE-MRR PUMP IS UNCHANGED — expand() still costs nothing, and the only cost the design ever claimed (support load) was deleted rather than implemented. THE DAILY RE-FIRE IS CLOSED, by Customer.last_expansion_day stamped on both answers (b2b_sales_system.gd:385 and :398) and read by the single shared gate can_offer_expansion (:269-274) that both the daily sweep and the Sales-tab button go through, backed by the phase promotion at :262 against the early-return at :256. The played run is the proof: 25 distinct ids, each fires=1, none repeating. What the fix converted is the SHAPE of the problem, not its size — from an unbounded per-account pump into a free, permanent, uncapped-across-the-book raise that scales linearly with how many accounts the sales desk signs. In this run that was +$11,520/month of permanent MRR (18 × $360 + 7 × $720), 35.5 % of the closing MRR, +$384/day of cash against a $260/day burn, and $69,120 if held over 180 days.

---

### ev_b2b_escalation_<customer_id>  (runtime example: ev_b2b_escalation_co_lead_107_38)

```
FILE          project-unicorn/scripts/systems/b2b_event_factory.gd — builder B2BEventFactory.build_cs_escalation, lines 111-134. Injected from project-unicorn/scripts/systems/b2b_sales_system.gd:170 (_enqueue_cs_escalation), armed at :149-163 (_tick_cs_escalation).
CATEGORY      B2B account (CS-delegated) — code-built card, speaker is the REAL Müşteri Temsilcisi employee (ev.character_id = cs.id, b2b_event_factory.gd:120)
REACHABLE     NO, not in the played run — 0 fires in run_full_run_730.log (grep 'ev_b2b_escalation' = 0 hits; PROBE TALLY_BEGIN..END at lines 6337-6383 lists no escalation id). The run hired exactly ONE employee, a developer, on day 55 (log line 420: '[HRSearchSystem] hire: Baran Erdem (developer)'), and emp stays 1 through day 275. TWO preconditions are missing at once: (a) at least one active Müşteri Temsilcisi (ROLE_CUSTOMER_REP) must exist or CustomerRepSystem.reconcile_assignments() returns at customer_rep_system.gd:101 and nothing is ever delegated; (b) the account must be delegated (c.assigned_to != "", b2b_sales_system.gd:154-156). Delegation itself needs founder_managed_count() > FOUNDER_DIRECT_CAP=4 (customer_rep_system.gd:143, b2b_constants.gd:195) and the account out of onboarding (CS_ASSIGNABLE_PHASES = active/risk/expansion, b2b_constants.gd:327). The run's book crosses 4 accounts on day 60 (PROBE STATE day=60 cust=5), so from day ~60-90 onward the ONLY thing standing between this run and the card is the hire. Reachable in a normal run: hire a Müşteri Temsilcisi (role locked until ProductSystem.has_b2b_product(), hr_constants.gd:446-449), carry 5+ settled B2B accounts, and let one delegated account sink under satisfaction 35.
FIRES         Daily, at hour 00. TimeManager rolls the day at time_manager.gd:141-143 (set_current_hour(0) → advance_day() → _dispatch_daily_tick()), which reaches SalesSystem.daily_tick (time_manager.gd:321) → B2BSalesSystem.daily_tick (sales_system.gd:143) → per-customer sweep → _tick_customer → _tick_cs_escalation (b2b_sales_system.gd:52, :149). The condition, in plain words: this B2B account is stewarded by a rep (c.assigned_to != "", :154), its visible satisfaction has fallen below 35 (B2BConstants.CS_ESCALATION_SAT, b2b_constants.gd:196; test at b2b_sales_system.gd:158), and it has not already raised this escalation (c.cs_escalated == false, :159). No random roll, no hour window, no dice — a deterministic day-boundary beat. The rep who speaks is the account's OWN steward, CharacterRegistry.get_character(c.assigned_to) (:167); a null lookup silently drops the card (:168-169).
FREQUENCY     Repeatable, no cooldown — and one_shot/cooldown_days/allowed_hours/build_safe on this object are ALL INERT, because EventManager.enqueue (event_manager.gd:200-214) never calls _is_eligible. The REAL latch is Customer.cs_escalated (customer.gd:70), a plain bool on the customer record: set true at b2b_sales_system.gd:160 immediately before the enqueue, and cleared in three places — :156 (the rep was released, assigned_to went empty), :163 (satisfaction climbed back to >= 35), and :358 inside honor_cs_promise. There is NO company-wide ceiling on this family: CS_ESCALATION_WEEKLY_CAP=2 (b2b_constants.gd:340) guards only the CS REQUEST channel (customer_rep_system.gd:286-287, :309), never this one. Consequence, and it is load-bearing: because honoring clears the latch on the spot (:358) while accept_promise only lifts satisfaction by RETAIN_SAT_BUMP=8 (b2b_constants.gd:84, applied at b2b_sales_system.gd:308 → _recover), an account honored at satisfaction 22 lands at 30 — still under 35 — and the SAME card fires again the next morning. With the b2b_broke_<id> flag set the bump halves to 4 (b2b_sales_system.gd:306-307), so the loop can run 3-4 mornings. Only EventManager's id dedupe (event_manager.gd:209) stops two copies coexisting in the queue, and it cannot: the game pauses at speed 0 while a modal is open (main.gd:2096 pattern), so the previous card is always answered first. Cross-family note: while cs_escalated is true, can_offer_retention() returns false (b2b_sales_system.gd:221), so the generic retention card stands down — one situation, one decision. But the CS REQUEST card is a different id with a different latch, so the same account can hand the player TWO rep cards on the same morning.
```

**TITLE (TR)** Müşteri temsilcisi uyarısı  ·  **TITLE (EN)** Account manager warning
**SUBTITLE (TR)** MISSING — ev.subtitle is never set by build_cs_escalation; the GameEvent default "" (event.gd:31) stands, so the modal renders no subtitle row and no clock.  ·  **(EN)** MISSING — ev.subtitle_en likewise never set (event.gd:75), default "".
**ALLOWED HOURS** NONE. GameEvent has no allowed_hours field at all — windows live in EventManager._hour_windows, populated only from JSON at load (event_manager.gd:913-919), so a code-built card is never keyed there. The card fires at hour 00 (time_manager.gd:141-143) and the copy contains no clock, which is the correct pairing under the EVENT AUTHORING LAW.
**PRIORITY** 0 — GameEvent.priority default (event.gd:60); build_cs_escalation never sets it. Irrelevant in practice: priority is only consulted on the eligibility path, and enqueue appends straight to the queue (event_manager.gd:212).

**BODY (TR)**

> Patron, {company} bir süredir '{feature}' istiyor. Oyaladım ama artık tutamıyorum. Gideceklerdi, büyük müşteri, söz vermek zorunda kaldım. En kısa sürede yapalım.

**BODY (EN)**

> Boss, {company} has been asking for '{feature}' for a while. I stalled them, but I cannot hold it any longer. They were ready to walk — big account — so I had to promise. Let us get it done.

**CHOICE 1** — `Tamam, sözü tut` / `All right, keep the promise`

  *desc:* NONE — EventChoice.description is left "" (only _discount_choice sets one). / NONE

  - **EFFECTS** `b2b_cs_promise_honor` — {"type": "b2b_cs_promise_honor", "customer_id": c.id, "feature_id": c.pain_feature_id, "deadline_days": 14}  — deadline_days is B2BConstants.PROMISE_DEADLINE_DAYS = 14 (b2b_constants.gd:167). Authored at b2b_event_factory.gd:124-127.
    event_manager.gd:803 → B2BSalesSystem.honor_cs_promise (b2b_sales_system.gd:352) → accept_promise (:301). Three state changes: (1) PromiseRegistry.create(customer_id, feature_id, 14) mints an open Promise with deadline_day = GameState.day + 14 (promise_registry.gd:56-70), which shows up as a 'SÖZ VERİLDİ · <şirket> · <özellik> · N gün' row in the Product detail view (detail_view.gd:461-477) and as a dated line on the ODA board (oda_view.gd:1294-1296); (2) _recover(c, 8) — CustomerRegistry.set_satisfaction(+8, clamped 0-100), risk_streak reset to 0, and if the account was in Risk the churn countdown is cleared and last_risk_exit_day stamped (b2b_sales_system.gd:426-443); the bump is HALVED to 4 when GameState flag b2b_broke_<customer_id> is true (:306-307); (3) c.cs_escalated = false (:358), which re-arms this very card for tomorrow. Later, on resolution: kept → tolerance −5 PERMANENTLY (b2b_sales_system.gd:455, PROMISE_KEPT_TOLERANCE), trust_offset +6.0 (decaying 0.4/day), and a second _recover(+15); broken at deadline+1 → satisfaction −20, tolerance +5 PERMANENTLY (:482), trust_offset −12.0, brand −3, and flag b2b_broke_<id> = true (:478-492). NOTE THE DEAD CASE: when c.pain_feature_id is "" (B2BSalesSystem.pick_pain_feature returns "" once every feature in the active pool is live, b2b_sales_system.gd:512-522), the promise is created with feature_id "" and PromiseRegistry._on_build_phase_changed tests live.has("") (promise_registry.gd:119) — always false — so the promise can only ever break. Nothing in build_cs_escalation guards for it.
  - **DURATION** one-time (+8 or +4 satisfaction, erased by the daily drift at SAT_DRIFT_STEP 3/day within ~2-3 days) + a 14-day debt whose RESOLUTION is permanent on tolerance (±5, and set_tolerance has exactly two writers — b2b_sales_system.gd:455 and :482 — with no decay path anywhere, so it is a one-way ratchet)
  - **CHIP** Müşteri kalır · söz borcu doğar · yol haritasına eklenir   /  EN: The customer stays · a promise is owed · it goes on the roadmap   (tr("EFFECT_PROMISE_HONOR"), event_modal.gd:551, kind = accent)
  - **UNLOCK** NONE — _choice() (b2b_event_factory.gd:303-307) leaves unlock_condition = {} and EventManager.is_condition_met({}) passes, so the row is always live.

**CHOICE 2** — `Hayır, yapmıyoruz` / `No, we are not doing it`

  *desc:* NONE / NONE

  - **EFFECTS** `b2b_cs_promise_refuse` — {"type": "b2b_cs_promise_refuse", "customer_id": c.id}  — b2b_event_factory.gd:129
    event_manager.gd:806 → B2BSalesSystem.refuse_cs_promise (b2b_sales_system.gd:361) → _remove_lost(c) (:286): GameState.run_customers_lost += 1, lifecycle_phase set to 'churning', EventBus.customer_churned emitted, CustomerRegistry.remove(c.id) DELETES the account, then SalesSystem.reflect_mrr() drops its MRR out of GameState.mrr. The removal signal also makes PromiseRegistry.drop_open_for() erase every open promise this account held (promise_registry.gd:23, :89-107). Deliberately does NOT route through _churn(), so B2BConstants.CHURN_BRAND (−2) is NOT applied — the −3 below is the whole brand cost, no double-apply (comment at b2b_sales_system.gd:277-282).
  - **EFFECTS** `brand` — {"type": "brand", "delta": -3}  — literally -B2BConstants.CS_REFUSE_BRAND, CS_REFUSE_BRAND = 3 (b2b_constants.gd:198), written at b2b_event_factory.gd:130
    event_manager.gd:567 → GameState.set_brand(GameState.brand + (-3)). Brand sat at exactly 50 for all 275 days of the played run (every PROBE STATE line reads brand=50), so this is a 6 % cut of the only brand number the run ever had.
  - **EFFECTS** `morale` — {"type": "morale", "character_id": cs.id, "delta": -10}  — literally -B2BConstants.CS_REFUSE_MORALE, CS_REFUSE_MORALE = 10 (b2b_constants.gd:199), written at b2b_event_factory.gd:131
    event_manager.gd:571 → the target is category 'employee', so HRMoraleSystem.apply_delta(cs, -10, "event") (hr_morale_system.gd:220-239), which routes through scaled_delta(): the carrier's trait multiplier, the founder's Liderlik CLIMATE coefficient, the trait morale floor and the registry clamp are all folded in. The number that actually lands is therefore NOT −10 in general, while the chip prints the nominal −10.
  - **DURATION** permanent — the account is deleted (its MRR never returns), brand −3 stands until some other event moves brand, the morale hit stands until HR's own drift/actions move it
  - **CHIP** Müşteriyi kaybet | Marka -3 | <CS'in adı> -10        /  EN: Lose the customer | Brand -3 | <CS first name> -10   (three stacked chips: tr("EFFECT_PROMISE_REFUSE") event_modal.gd:552 kind=negative; tr("EFFECT_BRAND").format({"v": _fmt_signed(-3)}) event_modal.gd:491 kind=negative; tr("EFFECT_AXIS").format({"axis": _char_first(cs.id), "v": "-10"}) event_modal.gd:493 — _char_first returns the employee's FIRST name, event_modal.gd:589-595)
  - **UNLOCK** NONE — unlock_condition = {}

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, MAGNITUDE, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — The honor row is repeatable AND its debts stack. Two facts combine: honor_cs_promise clears c.cs_escalated on the spot (b2b_sales_system.gd:358), and the card carries NO PromiseRegistry.has_open_for(c.id) gate — the gate that b2b_event_factory.gd:59-60 (retention card) and :287 (CS feature request) both have, and whose absence the file's own comment at :48-57 documents as the measured failure ('90 günlük bir sürücü koşusunda 5 müşteriye 142 SÖZ verildi ve 117'si kırıldı'). So an account honored at satisfaction 22 goes to 30, is still under CS_ESCALATION_SAT=35, and re-fires the next morning; with the b2b_broke flag halving the bump to 4 (:306-307) the loop runs 3-4 mornings and leaves 3-4 OPEN promises for the same feature on one account. PromiseRegistry.create only dedupes ids within a single day (promise_registry.gd:59, :66-67), so different mornings mint genuinely separate records. One later ship then resolves all of them: promise_registry.gd:118-124 iterates every promise matching the live feature, and each one runs on_promise_resolved → _recover(+15) + tolerance −5 + trust +6 (b2b_sales_system.gd:453-461). Three or four promises = +45/+60 satisfaction, −15/−20 tolerance for a single piece of delivered work. Bounded (the +8/day bump outruns the −3/day drift, so the loop self-terminates in ≤4 days), not unbounded — but it is the same triple-reward class the retention card was explicitly fixed for.
- **PERMANENT SWING** — BOTH rows swing the economy forever on one click. (a) Refuse deletes a B2B account outright (b2b_sales_system.gd:286-292). In the played run's book that account was worth mrr/cust = $10,625/13 = $817/mo on day 100, $23,750/22 = $1,079 on day 150 and $31,775/25 = $1,271 on day 200 (PROBE STATE lines 1138, 2385, 3947). Projected over 180 days at the day-200 figure: 6 × $1,271 = $7,626 of revenue gone, against a cash position of $74,566 and a burn of $260/day — i.e. one click erases about 29 days of runway-equivalent income, plus a permanent 6 % brand cut. (b) Honor mints a promise whose resolution moves `tolerance` by ±5 with NO decay path in the codebase — grep shows set_tolerance has exactly two writers, b2b_sales_system.gd:455 and :482, and nothing walks it back. Tolerance is the bar under which the account enters Risk (:97), so a broken word raises that bar permanently for the rest of the run.
- **MAGNITUDE** — The refuse row is out of band for a routine daily card. On the days this can fire in a run shaped like the played one (day 60 onward, PROBE STATE day=60 cash=28345 mrr=3550 cust=5; day 100 cash=25061 mrr=10625 cust=13; day 200 cash=74566 mrr=31775 cust=25, burn=260/day throughout), one B2B account is 7.7 % of MRR at day 100 and 4.0 % at day 200 — and it is deleted with no counter-offer, no partial outcome and no recovery path. Against the day-100 cash of $25,061 the lost account is $817/mo, i.e. the equivalent of 3.1 days of total company burn every month, forever. The morale chip is also out of band relative to its own truth: it prints −10 while HRMoraleSystem.scaled_delta re-scales the figure by trait multiplier and the founder's Liderlik climate (hr_morale_system.gd:242-250).
- **INVISIBLE** — `tolerance` and `trust_offset` — the two fields this card's honor row moves permanently — are never surfaced anywhere the player can look. Both are marked HIDDEN in the model (customer.gd:50, :75), their registry seams deliberately emit no signal (customer_registry.gd:256-273, :274+), and a grep of scripts/tabs, scripts/ui and scripts/modals for `.tolerance` or `trust_offset` returns ZERO hits. The player sees satisfaction (sales_tab.gd:88, :491; portfolio_view.gd:132) but never the bar it is measured against, so a broken promise's permanent effect is only ever felt as 'this account got touchy' with no readable cause — the failure Calibration Law 3 names.
- **DEAD REFERENCE** — Three: (1) ev.tags = ["build_safe", "b2b_escalation"] (b2b_event_factory.gd:119) — the tag `b2b_escalation` has NO reader anywhere; grep across scripts/, scenes/ and data/ finds only the write. (2) `build_safe` is real vocabulary but INERT here: its only reader is _is_eligible (event_manager.gd:473), which enqueue never calls (event_manager.gd:200-214). Same for one_shot and cooldown_days, both left at their defaults. (3) The honor row can create a promise whose feature_id is "" when c.pain_feature_id is empty (pick_pain_feature returns "" once every pool feature is live, b2b_sales_system.gd:520-522); PromiseRegistry then tests live.has("") at promise_registry.gd:119, which can never be true, so the promise is structurally unkeepable and can only break. Nothing in build_cs_escalation checks for it, and the body still renders the FEATURE_LABEL_FALLBACK word 'yeni özellik' as if it were a named request.
- **COPY LIE** — Two. (1) The honor chip promises 'yol haritasına eklenir' / 'it goes on the roadmap'. Nothing puts the feature on any roadmap: PromiseRegistry.create only records a row (promise_registry.gd:56-70), and its only readers are two display surfaces — the Product detail view's promise list (detail_view.gd:461-477) and the ODA board's date list (oda_view.gd:1294-1296). No build queue is touched, no design round is pre-seeded, no feature is selected; a grep of product_system.gd for 'promise' returns nothing but two unrelated prose comments. The player must independently pick that feature in a later design round, and if they don't, the promise breaks. (2) The body asserts 'söz vermek zorunda kaldım' — the rep says a promise has already been given — but no Promise exists until the player picks 'Tamam, sözü tut'; refusing costs the account, not a broken word. The fiction of an already-given promise is not backed by any state at the moment the card is shown.
- **VOICE** — The English body carries two em dashes: 'They were ready to walk — big account — so I had to promise.' The factory's own copy law, three lines above the builder, says 'Copy law: no raw numbers, no em-dash, no emoji' (b2b_event_factory.gd:16-18) — this is that file's stated rule broken in its own EN sibling, not an imported style preference. Separately, the title asserts a role the speaker may not hold: build_cs_escalation names the speaker via ev.character_id = c.assigned_to, and _delegate_excess draws stewards from _ranked(AREA_CUSTOMER_SUCCESS) (customer_rep_system.gd:162), which admits ANY employee assigned to that area — a Satış Temsilcisi's secondary area is customer_success (hr_constants.gd:122). The modal then renders '<ad> · Satış Temsilcisi' (event_modal.gd:262) under a card titled 'Müşteri temsilcisi uyarısı'. Otherwise clean: no clock in a card that fires at hour 00, no UI tab named in the fiction, register short and dry, no scene-setting prose in the rep's mouth.

<details><summary>Flags checked and not applicable (4)</summary>

- *FREE LUNCH* — Two options, both priced. 'Tamam, sözü tut' buys +8 satisfaction with a 14-day debt whose break costs −20 satisfaction, +5 permanent tolerance, −12 trust and −3 brand (b2b_sales_system.gd:478-492). 'Hayır, yapmıyoruz' costs the whole account plus brand −3 plus morale −10. Neither is upside-without-cost.
- *NO OP* — Neither option has empty modifiers and no modifier is a no-op: b2b_cs_promise_honor, b2b_cs_promise_refuse, brand and morale all have live arms in _apply_modifiers (event_manager.gd:803, :806, :567, :571).
- *IDENTICAL OPTIONS* — Exactly two options and they are opposites — keep the account with a debt, or lose the account. No shared modifier type between them.
- *BLIND* **[corrected: was flagged, refuted]** — Not blind in the 'no chip at all' sense — both rows carry chips — but the honor row's chip covers only the immediate half. The permanent ±5 tolerance ratchet, the ±6/−12 trust_offset, and the −20 satisfaction plus −3 brand that land if the deadline passes are nowhere on the card. The player is asked to take on a 14-day obligation with no on-card statement of what breaking it costs, and no on-card statement that nothing will build the feature for them. The refuse row's chip says 'Müşteriyi kaybet' but never says how much MRR walks out ($817-$1,271/mo in the played run's book), even though EFFECT_RETAIN_DISCOUNT next door proves the chip grammar can carry a money figure.

</details>

**Notes.** Cross-checks worth carrying forward: (1) c.cs_escalated is written as a RAW FIELD (b2b_sales_system.gd:156, :160, :163, :358), not through a CustomerRegistry seam — a standing WRITE-THROUGH LAW exception on a persisted @export (customer.gd:70). Every sibling latch on the same record (support_request_since_day, last_request_kind, retain_discounts) has a seam; this one does not. (2) The chip grammar already proves it can carry money (EFFECT_RETAIN_DISCOUNT renders 'Müşteri kalır · MRR -$191'), so 'Müşteriyi kaybet' silently declining to name the MRR is a choice, not a limitation. (3) The two-card-per-morning case is real: this card and ev_b2b_request_<same customer> use different ids and different latches, so one account with one rep can produce both on the same day-0 tick — _tick_cs_escalation runs inside the per-customer sweep (b2b_sales_system.gd:39-40) and CustomerRepSystem.daily_tick runs right after it (:41).

---

### ev_b2b_request_<customer_id> — COMPLAINT branch (kind = B2BConstants.CS_KIND_COMPLAINT, "complaint")

```
FILE          project-unicorn/scripts/systems/b2b_event_factory.gd — builder B2BEventFactory.build_cs_request, lines 203-300; this branch is the match arm at lines 231-253. Branch selector B2BEventFactory.pick_request_kind, lines 137-200. Injected from project-unicorn/scripts/systems/customer_rep_system.gd:318 (_escalate).
CATEGORY      B2B account — code-built card, speaker is the top-ranked Müşteri Başarısı employee (ev.character_id = reps[0].id, customer_rep_system.gd:318 → b2b_event_factory.gd:223)
REACHABLE     NO, not in the played run — 0 fires (grep 'ev_b2b_request' in run_full_run_730.log = 0 hits; absent from PROBE TALLY lines 6337-6383). CustomerRepSystem.daily_tick returns immediately at customer_rep_system.gd:191 whenever count_active_by_role(ROLE_CUSTOMER_REP) == 0, and the run's only hire was a developer on day 55 (log line 420), emp=1 for all 275 days. Unlike the escalation card, this family needs NOTHING but the hire — the request channel is uncapped and covers the whole customer book, founder-managed accounts included, from the rep's first day (customer_rep_system.gd:14-17, :203-208). So with a rep hired at day 55 and cust=4 (PROBE STATE day=55), the first request would open within 22 days. Two throttles then decide whether it reaches the player at all: the absorb valve (difficulty <= 3 + top rep's Müşteri Başarısı, customer_rep_system.gd:240-244, :254) and the 3-day staleness escape (:290-298). Demo difficulty tops out at 1+2+2+(3-1) = 7 (:225-237 with scale capped at SCALE_DEMO_MAX 3, b2b_constants.gd:24, :67), so a rep with Müşteri Başarısı >= 4 absorbs EVERY request and the player never sees this card through the valve — every player-facing request in demo then comes from _escalate_stale. With a rep at Müşteri Başarısı <= 3 the hardest requests escalate directly.
FIRES         Daily, at hour 00, three steps deep. TimeManager rolls the day (time_manager.gd:141-143) → SalesSystem.daily_tick → B2BSalesSystem.daily_tick → CustomerRepSystem.daily_tick (b2b_sales_system.gd:41). Then: (1) _open_due_requests (customer_rep_system.gd:198-208) opens a request on any B2B account with no open one when (GameState.day + c.cs_request_phase) % 22 == 0 — CS_REQUEST_INTERVAL_DAYS = 22 (b2b_constants.gd:331), the phase assigned once at signing by a stride-9 walk (sales_system.gd:385-386, CS_PHASE_STRIDE = 9, coprime with 22 so the book spreads). (2) _work_the_queue (:247-259) spends desk_throughput() = sum over rank-ordered reps of 0.6^rank × (0.5 + MüşteriBaşarısı × 0.15) × overtime multiplier (:74-92, b2b_constants.gd:342-343, :291); each request costs 1.0 of budget, and a request whose difficulty exceeds 3 + top expertise goes to _escalate instead of being silently absorbed. (3) _escalate_stale (:290-298) escalates anything open >= 3 days (CS_ESCALATE_AFTER_DAYS, b2b_constants.gd:349). _escalate (:301-318) then checks the rolling company cap — at most 2 escalations per 7 days (CS_ESCALATION_WEEKLY_CAP=2, CS_ESCALATION_WINDOW_DAYS=7, b2b_constants.gd:340-341, counted at :278-287) — clears the latch, stamps GameState.cs_escalation_days, and enqueues. No random roll anywhere in the chain. WHICH BRANCH: pick_request_kind (b2b_event_factory.gd:137-200) scores three kinds and takes the highest among those != c.last_request_kind. COMPLAINT scores 2 × max(0, tolerance + 10 − satisfaction), +30 if GameState flag b2b_broke_<id> is truthy, +15 if trust_offset < −4.0, +10 if risk_streak > 0 or churn_countdown >= 0 (:161-168). Concretely: an account at tolerance 51 and satisfaction 30 scores 62, +10 if it is in Risk = 72, which beats FEATURE's ceiling of 55 and any plausible RENEWAL. So THIS branch is 'the account is unhappy, or has been lied to before' — ties break on tied[c.cs_request_phase % tied.size()] (:198-199), never on RNG.
FREQUENCY     Repeatable, no cooldown — one_shot/cooldown_days/allowed_hours/build_safe on the object are INERT (enqueue bypasses _is_eligible, event_manager.gd:200-214). THREE real latches, all in the owning system: (a) Customer.support_request_since_day (customer.gd:76) — one open request per account at a time, opened at customer_rep_system.gd:208, cleared at :270 when absorbed and at :316 when escalated to the player; over the weekly cap _escalate returns at :309-310 WITHOUT clearing it, so the request stays open and re-tries tomorrow (deferred, never dropped). (b) The rolling company ceiling: at most 2 player-facing CS cards per 7 days across the whole book (:286-287). (c) Customer.last_request_kind (customer.gd:89), written at b2b_event_factory.gd:226 — the same account never opens the same kind twice running. Practical cadence: one account every 22 days, company-wide never more than 2 per week.
```

**TITLE (TR)** Müşteri şikâyeti  ·  **TITLE (EN)** Customer complaint
**SUBTITLE (TR)** MISSING — build_cs_request never sets ev.subtitle; GameEvent default "" (event.gd:31).  ·  **(EN)** MISSING — ev.subtitle_en never set (event.gd:75), default "".
**ALLOWED HOURS** NONE — no allowed_hours field exists on GameEvent; windows are keyed by id in EventManager._hour_windows only from JSON (event_manager.gd:913-919). The card fires at hour 00 and the copy carries no clock, which is correct. ('hattı arıyor' / 'is on the line' implies a phone call but asserts no time of day.)
**PRIORITY** 0 — GameEvent default (event.gd:60), never set; and irrelevant, since enqueue appends directly (event_manager.gd:212).

**BODY (TR)**

> HARD variant (fires when c.satisfaction < c.tolerance, b2b_event_factory.gd:238-239): "{company} hattı arıyor, ton sert: "{voice}" Kendi başıma yatıştıramadım."   ·   SOFT variant (satisfaction >= tolerance, :240-241): "{company} hattı arıyor: "{voice}" Şimdilik idare ettim ama karar senin."   ·   {voice} = B2BConstants.complaint_voice(c.industry) (:236), the same sector pool build_retention uses — e.g. logistics: "Sevkiyat saatinde sistem donuyor, operasyon aksıyor."; health: "Ekranlar sürekli çöküyor, hasta kapıda beklerken sistemi açamıyoruz."; an off-catalog sector falls back to "Sisteminiz son zamanlarda sık sık aksıyor, ekibim işini yapamıyor." (B2B_COMPLAINT_FALLBACK, b2b_constants.gd:135-136, :151-156).

**BODY (EN)**

> HARD: "{company} is on the line and the tone is hard: "{voice}" I could not calm them down on my own."   ·   SOFT: "{company} is on the line: "{voice}" I have held it for now, but the call is yours."   ·   {voice} e.g. logistics: "The system freezes right at dispatch and the whole operation stalls."; health: "The screens keep crashing and we cannot bring the system up with a patient waiting at the door."; fallback: "Your system has been failing often lately and my team cannot do their job."

**CHOICE 1** — `İndirim ver` / `Offer a discount`

  *desc:* İki kez indirim verdin. Bu hesabı fiyat değil ürün tutar.   (B2B_DISCOUNT_SPENT_DESC, set only when c.retain_discounts >= 2, b2b_event_factory.gd:319-320) / You have discounted twice. Price will not keep this account; the product will.

  - **EFFECTS** `b2b_retain_discount` — {"type": "b2b_retain_discount", "customer_id": c.id, "mrr_delta": -cut}  where cut = maxi(int(round(float(c.mrr) * 15 / 100.0)), 1) — CS_DISCOUNT_PCT = 15 (b2b_constants.gd:362), computed at b2b_event_factory.gd:242, authored at :244
    event_manager.gd:799 → B2BSalesSystem.apply_discount (b2b_sales_system.gd:325): guard returns if c.retain_discounts >= RETAIN_DISCOUNT_MAX_USES=2 (b2b_constants.gd:81); otherwise set_retain_discounts(+1), CustomerRegistry.set_mrr(c.id, c.mrr − cut) — a PERMANENT price cut, nothing ever restores it — then SalesSystem.reflect_mrr() and _recover(c, RETAIN_SAT_BUMP=8): satisfaction +8, risk_streak 0, churn countdown cleared if the account was in Risk.
  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "customer_id": c.id, "delta": 8}  — B2BConstants.CS_DISCOUNT_SAT = 8 (b2b_constants.gd:363), authored at b2b_event_factory.gd:245
    event_manager.gd:723 → CustomerRegistry.set_satisfaction(c.id, c.satisfaction + 8), clamped 0-100 (customer_registry.gd:219). NOTE THE DOUBLE COUNT: apply_discount already ran _recover(+8) inside the previous modifier, so this row moves satisfaction by +16 in total while the two chips read '+8' once and 'Müşteri kalır' once. It is +8 only when the discount cap has already been spent — in which case the row is locked and unpickable anyway.
  - **DURATION** the MRR cut is PERMANENT (no restore path); the +16 satisfaction is transient — the daily drift pulls satisfaction back to its target at SAT_DRIFT_STEP 3/day (b2b_sales_system.gd:68-81), so it is gone in ~5 days on a founder-managed account and ~16 on one stewarded by a Müşteri Başarısı-9 rep (cs_dampen 0.505 truncates the −3 step to −1)
  - **CHIP** Müşteri kalır · MRR -$191 | Memnuniyet +8   /  EN: The customer stays · MRR -$191 | Satisfaction +8   — the money figure is the account's own 15 %: at the played run's per-account MRR the chip reads -$123 on day 100 ($817 account) and -$191 on day 200 ($1,271 account); a mid-band account at its $2,000 ceiling reads -$300. Only an account above $6,667 would trip _fmt_money_delta's K form (event_modal.gd:612-616), which no demo-scale account reaches. Chips built at event_modal.gd:549 (kind=negative) and :496 (kind=positive).
  - **UNLOCK** {"type": "b2b_discounts_below", "customer_id": c.id, "value": 2}  — attached by _discount_choice (b2b_event_factory.gd:315-321), value = B2BConstants.RETAIN_DISCOUNT_MAX_USES. Re-evaluated at RENDER by event_modal.gd:368 through EventManager.is_condition_met (event_manager.gd:430-434), counting BOTH discount channels (retention card + these CS cards). Past the cap the row stays visible at modulate 0.5, refuses the click, renders NO effect chips at all, shows the badge 'KİLİTLİ' / 'LOCKED' (tr("LOCK_CHIP")) and prints the reason on its italic sub-line (event_modal.gd:421-426).

**CHOICE 2** — `Düzeltme sözü ver` / `Promise a fix`

  *desc:* NONE / NONE

  - **EFFECTS** `b2b_promise_create` — {"type": "b2b_promise_create", "customer_id": c.id, "feature_id": c.pain_feature_id, "deadline_days": 14}  — PROMISE_DEADLINE_DAYS = 14 (b2b_constants.gd:167), authored at b2b_event_factory.gd:248-249
    event_manager.gd:794 → B2BSalesSystem.accept_promise (b2b_sales_system.gd:301): PromiseRegistry.create(customer_id, feature_id, 14) mints an open Promise with deadline_day = day + 14, then _recover(c, 8) — or _recover(c, 4) when the flag b2b_broke_<id> is set (:306-307). Resolution later: KEPT on the next ship that puts the feature in GameState flag mvp_components (promise_registry.gd:112-124) → tolerance −5 permanently, trust_offset +6.0, _recover(+15) (b2b_sales_system.gd:453-461); BROKEN at deadline+1 (promise_registry.gd:127-131) → satisfaction −20, tolerance +5 permanently, trust_offset −12.0, brand −3, flag b2b_broke_<id> = true (:478-492).
  - **DURATION** one-time +8 (or +4) satisfaction, erased by the drift in ~3-5 days; the 14-day debt's resolution is PERMANENT on tolerance (±5, no decay path)
  - **CHIP** Müşteri kalır · söz borcu   /  EN: The customer stays · a promise owed   (tr("EFFECT_PROMISE_CREATE"), event_modal.gd:547, kind = accent)
  - **UNLOCK** NONE — plain _choice(), unlock_condition = {}

**CHOICE 3** — `Açıkla ve reddet` / `Explain and decline`

  *desc:* NONE / NONE

  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "customer_id": c.id, "delta": -3}  — B2BConstants.CS_EXPLAIN_SAT = -3 (b2b_constants.gd:364), authored at b2b_event_factory.gd:252
    event_manager.gd:723 → CustomerRegistry.set_satisfaction(c.id, c.satisfaction − 3), clamped 0-100, emits customer_satisfaction_changed (customer_registry.gd:211-224). Nothing else: no brand, no reputation, no state on the account records that the founder said no.
  - **DURATION** transient — 3 points is one day of drift (SAT_DRIFT_STEP = 3, b2b_constants.gd:21), so on a founder-managed account whose target is above its current satisfaction the cost is erased the following morning
  - **CHIP** Memnuniyet -3   /  EN: Satisfaction -3   (tr("EFFECT_SATISFACTION").format({"v": "-3"}), event_modal.gd:496, kind = negative)

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — 'Düzeltme sözü ver' is the one row in this whole family that can STACK a debt. It carries NO PromiseRegistry.has_open_for(c.id) gate — compare b2b_event_factory.gd:59-60 (retention card) and :287 (the FEATURE branch of this very function), both of which do. So an account that already owes a promise from the retention card or from a CS escalation can be handed a SECOND one here for the same feature, and promise_registry.gd:118-124 later resolves every matching open promise, running on_promise_resolved once per record: two promises = +30 satisfaction, −10 tolerance, +12 trust_offset for one shipped feature; if instead the deadline passes, two promises = −40 satisfaction, +10 permanent tolerance, −24 trust and −6 brand for one piece of undone work. That is exactly the two-directional break the file's own comment at :48-57 says was measured and closed ('tek yapılmamış iş için üç ayrı ceza … tek ship üçünü birden tutuldu'ya çevirdi'). The gate was added in two of the three places that needed it. The satisfaction rows do NOT compound — the daily drift is a hard attractor (b2b_sales_system.gd:68-81) and the 22-day per-account interval is far longer than the 1-5 days a bump survives.
- **PERMANENT SWING** — 'İndirim ver' cuts the account's MRR by 15 % FOREVER — CustomerRegistry.set_mrr is called once and nothing in the codebase restores a discounted price (b2b_sales_system.gd:325-341). At the played run's day-200 per-account figure ($31,775/25 = $1,271) that is −$191/mo; projected over 180 days = −$1,145 from a single click, and the cap allows two, so an account can be walked down to 72.25 % of its signing MRR permanently. Against day-200 MRR of $31,775 one full discount is 0.6 % of company revenue; across a 25-account book fully discounted twice it would be 27.75 % of all B2B revenue. The promise row's tolerance ±5 is the second permanent swing (see the escalation entry — set_tolerance has two writers and no decay).
- **INVISIBLE** **[corrected by the second reader]** — Same two hidden fields as the escalation card, reached through the promise row: `tolerance` (customer.gd:50) and `trust_offset` (customer.gd:75) are permanently/durably moved by promise resolution and are surfaced nowhere — their registry seams emit no signal (customer_registry.gd:256-282) and a grep of scripts/tabs, scripts/ui and scripts/modals for either name returns zero hits. Also invisible: Customer.last_request_kind, written as a side effect of merely BUILDING this card (b2b_event_factory.gd:226) — it silently steers which kind the account raises next and has no reader outside pick_request_kind.
- **DEAD REFERENCE** — ev.tags = ["build_safe", "b2b_cs_request"] (b2b_event_factory.gd:222): the tag `b2b_cs_request` has NO reader in scripts/, scenes/ or data/ — only the write. `build_safe` is real vocabulary but inert, because its only reader is _is_eligible (event_manager.gd:473) which enqueue never calls. Second dead reference: the promise row passes c.pain_feature_id with no check that it is non-empty or still unshipped — when it is "" the promise is created against a feature id that live.has() can never match (promise_registry.gd:119), making it unkeepable by construction; when it is ALREADY LIVE the next ship of anything converts it to 'kept' for work already done.
- **COPY LIE** — 'Açıkla ve reddet' / 'Explain and decline' asserts an explanation was given, but the only modifier is satisfaction_delta −3; no record is kept that the founder explained anything, and the very next request from this account is chosen by pick_request_kind with no memory of the refusal (b2b_event_factory.gd:137-200 reads satisfaction, tolerance, trust, risk, tenure, stalls and the open promise — never a refusal). The rep's line 'Kendi başıma yatıştıramadım' / 'I could not calm them down on my own' is honest as far as it goes, but the desk did in fact spend a throughput unit on this account before escalating (customer_rep_system.gd:253) — that spend is invisible and unmentioned.
- **VOICE** **[corrected by the second reader]** — Checked and clean. No clock in a card that fires at hour 00. No UI tab or node named in the fiction — the rep talks about the account, not about a screen. The body is a report in the rep's own register with the customer quoted, i.e. the sector voice is inside quotation marks and the framing sentence belongs to the speaker, not to a narrator. No em dash in either the TR or the EN of B2B_EV_COMPLAINT_HARD/SOFT. The HARD/SOFT split (b2b_event_factory.gd:238-241) makes the temperature match the state rather than being fixed copy.

<details><summary>Flags checked and not applicable (5)</summary>

- *FREE LUNCH* — All three rows are priced: the discount cuts MRR permanently, the promise creates a dated debt, and the honest refusal costs 3 satisfaction. The cheapest option is not free.
- *NO OP* — No option has empty modifiers and every modifier type used here has a live dispatcher arm (b2b_retain_discount event_manager.gd:799, satisfaction_delta :723, b2b_promise_create :794). The locked discount row is inert, but it is unpickable rather than a no-op choice.
- *IDENTICAL OPTIONS* — Three distinct modifier sets. Closest pair is 'İndirim ver' and 'Düzeltme sözü ver' — both keep the account — but one pays in permanent MRR and the other in a dated obligation. No two rows share the same effects.
- *BLIND* **[corrected: was flagged, refuted]** — 'Düzeltme sözü ver' takes on a 14-day obligation whose downside — −20 satisfaction, +5 PERMANENT tolerance, −12 trust_offset, −3 brand, and a credibility flag that halves every future promise's goodwill — is entirely absent from its one chip 'Müşteri kalır · söz borcu'. Nothing on the card says the feature is not scheduled, that the clock is 14 days, or what happens at zero. Additionally the 'İndirim ver' row understates itself in the other direction: apply_discount's own _recover(+8) plus the sibling satisfaction_delta +8 move satisfaction by +16, while the chips read '+8'.
- *MAGNITUDE* — In band for the phase it fires in. The discount's −$123 (day 100, mrr=10625 cust=13, PROBE STATE line 1138) to −$191 (day 200, mrr=31775 cust=25, line 3947) is 1.2 % and 0.6 % of company MRR respectively — a real but proportionate concession, and it is hard-capped at two per account (b2b_constants.gd:81). The satisfaction figures (+8, −3) sit within 1-3 days of the natural drift step of 3/day. Nothing here moves cash, and the card cannot delete an account.

</details>

**Notes.** All three branches of build_cs_request share ONE event id, ev_b2b_request_<customer_id> (b2b_event_factory.gd:220). EventManager's dedupe is by id (event_manager.gd:209), so it cannot tell a complaint from a renewal — harmless today only because the support_request_since_day latch already guarantees one open request per account. Second observation: build_cs_request MUTATES state as a side effect of construction — CustomerRegistry.set_last_request_kind at :226 runs before the card is ever enqueued, so a card discarded by the dedupe would still consume the kind rotation. Third: _work_the_queue debits 1.0 of desk throughput at customer_rep_system.gd:253 BEFORE branching, so a request that _escalate then refuses on the weekly cap (:309-310) has already eaten the capacity that could have absorbed a different account's request that day.

---

### ev_b2b_request_<customer_id> — RENEWAL branch (kind = B2BConstants.CS_KIND_RENEWAL, "renewal")

```
FILE          project-unicorn/scripts/systems/b2b_event_factory.gd — builder B2BEventFactory.build_cs_request, lines 203-300; this branch is the match arm at lines 254-267. Branch selector pick_request_kind, lines 169-176. Injected from project-unicorn/scripts/systems/customer_rep_system.gd:318.
CATEGORY      B2B account — code-built card, speaker is the top-ranked Müşteri Başarısı employee (b2b_event_factory.gd:223)
REACHABLE     NO, not in the played run — 0 fires (grep 'ev_b2b_request' = 0 in run_full_run_730.log; absent from PROBE TALLY 6337-6383), for the same single reason as the other two branches: no Müşteri Temsilcisi was ever hired (emp=1, a developer, from day 55 to the day-275 ending), so CustomerRepSystem.daily_tick returns at customer_rep_system.gd:191. This branch additionally needs TENURE to win the score: renewal = 6 × floor((GameState.day − c.acquired_on_day)/30) (b2b_event_factory.gd:170-171), so it only outscores FEATURE's typical 20-55 once an account is roughly 5-9 months old (5 months = 30, 9 months = 54), or sooner with +20 for a running churn countdown (:172-173) and +10 for a prior stall (:174-175). The played run's oldest accounts (co_lead_31_4, signed day 31) reach day 275 = 8 months of tenure = score 48, so in a run shaped like this one the renewal branch would start appearing around day 180-200 for the earliest signings — late, and only if the account is otherwise calm enough that COMPLAINT does not outscore it.
FIRES         Identical chain to the complaint branch: hour 00 daily tick (time_manager.gd:141-143) → SalesSystem.daily_tick → B2BSalesSystem.daily_tick → CustomerRepSystem.daily_tick (b2b_sales_system.gd:41) → _open_due_requests every 22 days per account (customer_rep_system.gd:198-208) → _work_the_queue's absorb valve (:247-259) or _escalate_stale after 3 days (:290-298) → _escalate under the 2-per-7-days ceiling (:301-318). No random roll anywhere. WHICH BRANCH: pick_request_kind (b2b_event_factory.gd:137-200) takes the highest score among the kinds != c.last_request_kind. RENEWAL scores 6 × tenure_months, +20 if churn_countdown >= 0, +10 if retain_stalls > 0 (:169-176) — plain words: 'this account has been with you a long time, and/or you have stalled it, and/or its churn clock is running'. It wins when the account is OLD and CALM: complaint's 2 × max(0, tolerance + 10 − satisfaction) collapses to near zero on a happy account (satisfaction 55 vs tolerance 51 → 12), and feature caps at 55, so a 10-month account (60) takes it. Ties break on tied[c.cs_request_phase % tied.size()] (:198-199).
FREQUENCY     Repeatable, no cooldown; one_shot/cooldown_days/allowed_hours/build_safe INERT (enqueue bypasses _is_eligible, event_manager.gd:200-214). Real latches: Customer.support_request_since_day (customer.gd:76; opened customer_rep_system.gd:208, cleared :270 or :316, NOT cleared when the weekly cap bites at :309-310 so the request defers to tomorrow), the rolling 2-per-7-days company ceiling (:278-287, b2b_constants.gd:340-341), and Customer.last_request_kind (customer.gd:89, written b2b_event_factory.gd:226) which forbids the same kind twice running from one account. Because tenure only grows, once an account is old enough this branch becomes its default answer whenever it is calm — alternating with whichever kind ranks second.
```

**TITLE (TR)** Yenileme sinyali  ·  **TITLE (EN)** Renewal signal
**SUBTITLE (TR)** MISSING — never set (event.gd:31 default "").  ·  **(EN)** MISSING — never set (event.gd:75 default "").
**ALLOWED HOURS** NONE — GameEvent has no allowed_hours field; windows are keyed by id only from JSON (event_manager.gd:913-919). Fires at hour 00 and the copy carries no clock, correctly.
**PRIORITY** 0 — GameEvent default (event.gd:60), never set; irrelevant because enqueue appends directly (event_manager.gd:212).

**BODY (TR)**

> {company} sözleşme yenilemesini sorguluyor. Fiyatı gözden geçiriyorlar; masaya oturmak gerek.

**BODY (EN)**

> {company} is questioning the renewal. They are reviewing the price; this needs a meeting.

**CHOICE 1** — `Yenilemeyi görüş` / `Negotiate the renewal`

  *desc:* NONE / NONE

  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "customer_id": c.id, "delta": 6}  — B2BConstants.CS_RENEWAL_TALK_SAT = 6 (b2b_constants.gd:365), authored at b2b_event_factory.gd:259
    event_manager.gd:723 → CustomerRegistry.set_satisfaction(c.id, c.satisfaction + 6), clamped 0-100, emits customer_satisfaction_changed (customer_registry.gd:211-224). Nothing else happens: no meeting is scheduled, no contract term is written, no price is agreed, Customer.renewal_day is not touched, and no flag records that a renewal was negotiated.
  - **DURATION** transient — 2 days of drift at SAT_DRIFT_STEP 3/day (b2b_constants.gd:21) erases it on a founder-managed account
  - **CHIP** Memnuniyet +6   /  EN: Satisfaction +6   (event_modal.gd:496, kind = positive)
  - **UNLOCK** NONE — plain _choice(), unlock_condition = {}

**CHOICE 2** — `İndirimle bağla` / `Lock them in with a discount`

  *desc:* İki kez indirim verdin. Bu hesabı fiyat değil ürün tutar. / You have discounted twice. Price will not keep this account; the product will.

  - **EFFECTS** `b2b_retain_discount` — {"type": "b2b_retain_discount", "customer_id": c.id, "mrr_delta": -cut2}  where cut2 = maxi(int(round(float(c.mrr) * 15 / 100.0)), 1) — CS_DISCOUNT_PCT = 15 (b2b_constants.gd:362), computed at b2b_event_factory.gd:257, authored at :262
    event_manager.gd:799 → B2BSalesSystem.apply_discount (b2b_sales_system.gd:325): returns silently if retain_discounts >= 2; else counter +1, CustomerRegistry.set_mrr(c.id, c.mrr − cut2) — permanent, no restore path — SalesSystem.reflect_mrr(), then _recover(c, 8). Nothing 'locks in' anything: no term, no exclusivity, no churn immunity, no renewal_day, no flag. The account is exactly as free to leave the next morning as it was.
  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "customer_id": c.id, "delta": 8}  — CS_DISCOUNT_SAT = 8 (b2b_constants.gd:363), authored at b2b_event_factory.gd:263
    event_manager.gd:723 → set_satisfaction(+8). Same double count as the complaint branch: apply_discount's own _recover already added +8, so the row moves satisfaction +16 while the chips read '+8'.
  - **DURATION** the MRR cut is PERMANENT; the +16 satisfaction is transient (≈5 days of drift)
  - **CHIP** Müşteri kalır · MRR -$191 | Memnuniyet +8   /  EN: The customer stays · MRR -$191 | Satisfaction +8   — figure is the account's own 15 %: -$123 at the played run's day-100 per-account MRR of $817, -$191 at the day-200 figure of $1,271, -$300 for a mid-band account at its $2,000 ceiling. Chips at event_modal.gd:549 (negative) and :496 (positive).
  - **UNLOCK** {"type": "b2b_discounts_below", "customer_id": c.id, "value": 2}  — _discount_choice (b2b_event_factory.gd:315-321), re-evaluated at render (event_modal.gd:368 → event_manager.gd:430-434). Past the cap: visible, modulate 0.5, click refused, NO effect chips, badge 'KİLİTLİ' / 'LOCKED', reason on the italic sub-line (event_modal.gd:421-426).

**CHOICE 3** — `Beklet` / `Hold it`

  *desc:* NONE / NONE

  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "customer_id": c.id, "delta": -5}  — B2BConstants.CS_RENEWAL_STALL_SAT = -5 (b2b_constants.gd:366), authored at b2b_event_factory.gd:266
    event_manager.gd:723 → set_satisfaction(c.id, c.satisfaction − 5), clamped 0-100. Nothing is deferred, re-queued or remembered: unlike the retention card's 'Oyala' (which routes to B2BSalesSystem.hold and actually pushes the churn countdown out by RETAIN_DELAY_DAYS and increments retain_stalls, b2b_sales_system.gd:314-323), this row touches no timer and does not increment retain_stalls — so it does not even feed the +10 'stall' term that pick_request_kind reads at b2b_event_factory.gd:174-175.
  - **DURATION** transient — under 2 days of drift
  - **CHIP** Memnuniyet -5   /  EN: Satisfaction -5   (event_modal.gd:496, kind = negative)

**FLAGS** — PERMANENT SWING, FREE LUNCH, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **PERMANENT SWING** — 'İndirimle bağla' cuts the account's MRR by 15 % permanently (b2b_sales_system.gd:325-341; nothing restores a discounted price anywhere in the codebase). At the played run's day-200 per-account $1,271 that is −$191/mo → −$1,145 projected over 180 days from one click; two clicks take the account to 72.25 % of its signing price for the rest of the run. The card offers this as the middle option on a routine renewal beat.
- **FREE LUNCH** — 'Yenilemeyi görüş' is +6 satisfaction with NO cost of any kind — one modifier, satisfaction_delta +6 (b2b_event_factory.gd:258-260), and nothing else: no cash, no MRR, no days, no obligation, no roadmap claim, no counter. On a card whose own body says a meeting is needed and the price is being reviewed, the option named 'negotiate' is strictly the best answer with no downside. Its only bound is that the bump decays in 2 days and the card only comes round every 22 days per account.
- **INVISIBLE** **[corrected by the second reader]** — Every effect this branch produces lands on `satisfaction`, which the player can see — Sales tab renders the book average (sales_tab.gd:88) and the minimum (sales_tab.gd:491), the product portfolio view averages it (portfolio_view.gd:132), and CustomerRegistry.set_satisfaction emits customer_satisfaction_changed so the UI repaints without polling (customer_registry.gd:224). The MRR cut is visible in every MRR readout. No hidden field is touched: this is the one CS branch that creates no promise and therefore never moves tolerance or trust_offset.
- **DEAD REFERENCE** — THE WHOLE BRANCH NAMES A SYSTEM THAT DOES NOT EXIST. The body says 'sözleşme yenilemesini sorguluyor' and the labels are 'Yenilemeyi görüş' and 'İndirimle bağla', but there is no renewal system in the game: Customer.renewal_day is declared under the header 'Reserved for future systems (declared, not used this turn)' with the comment 'When the next renewal event fires (churn/renewal — next spec)' (customer.gd:95-96), and a grep for renewal_day across scripts/ returns the declaration, the doc comment listing it as reserved, and NOTHING that reads or writes it. oda_view.gd:1387 confirms it from the other side: 'renewal sistemi gelince bu kaynak onunla değiştirilir'. Accounts have no contract term, no renewal date, and no lock-in state for any option here to change. Secondary dead references, as on the other branches: the tag `b2b_cs_request` (b2b_event_factory.gd:222) has no reader in scripts/, scenes/ or data/, and `build_safe` is inert because enqueue never calls _is_eligible (event_manager.gd:200-214, :473).
- **COPY LIE** — Three assertions the engine does not perform. (1) 'İndirimle bağla' / 'Lock them in with a discount' — nothing is locked in. apply_discount cuts MRR and bumps satisfaction (b2b_sales_system.gd:325-341); the account's churn machinery, tolerance bar and countdown are untouched and it can enter Risk the next morning. (2) 'masaya oturmak gerek' / 'this needs a meeting' followed by 'Yenilemeyi görüş' / 'Negotiate the renewal' — no meeting scene exists for customers, no negotiation resolves, no price is agreed; the option is a bare +6 satisfaction. (3) 'Beklet' / 'Hold it' claims a deferral, but unlike the retention card's 'Oyala' (which really does push the churn countdown out and increment retain_stalls, b2b_sales_system.gd:314-323) this row sets no timer and records no stall — the signal is not held, it is simply paid for at 5 satisfaction. This is the CONTENT & LANGUAGE LAW's 'No event implies an unbuilt system' broken at the level of a whole branch.
- **VOICE** **[corrected by the second reader]** — Checked and clean on the writing itself: short and dry, no clock in a card that fires at hour 00, no UI tab or node named in the fiction, no em dash in either the TR or the EN of B2B_EV_RENEWAL_BODY, and the rep speaks as a person reporting an account rather than as a narrator setting a scene. (The problem with this branch is what the words CLAIM, which is filed under COPY_LIE and DEAD_REFERENCE, not how they are written.)

<details><summary>Flags checked and not applicable (5)</summary>

- *REPEATABLE COMPOUND* — Repeatable (every ~22 days per account, 2/week company-wide) but nothing stacks. The two satisfaction rows are erased by the bidirectional daily drift toward the product-health target (b2b_sales_system.gd:68-81), which is a hard attractor at 3/day — far faster than the 22-day cadence. The discount is hard-capped at RETAIN_DISCOUNT_MAX_USES = 2 across both channels (b2b_constants.gd:81, enforced at the seam b2b_sales_system.gd:333-334 as well as by the locked row). No promise is created on this branch, so the promise-stacking hole of the complaint branch does not apply.
- *NO OP* — Every row carries at least one live modifier: satisfaction_delta has a dispatcher arm at event_manager.gd:723 and b2b_retain_discount at :799. 'Beklet' does nothing narratively but it does move satisfaction by −5, so it is not mechanically empty.
- *IDENTICAL OPTIONS* — No two rows share the same effects. Worth stating plainly though: 'Yenilemeyi görüş' and 'Beklet' are the SAME lever at two magnitudes — one satisfaction_delta each, +6 and −5, with nothing else on either — so the decision reduces to picking a number, not to picking a different kind of consequence. That is thin, but not identical.
- *BLIND* **[corrected: was flagged, refuted]** — Every modifier on this branch has a chip: satisfaction_delta renders 'Memnuniyet ±N' (event_modal.gd:496) and b2b_retain_discount renders the money figure (event_modal.gd:549). Nothing irreversible fires without a badge. The understatement in the discount row (+16 actual vs '+8' shown) is a magnitude problem, not a missing chip.
- *MAGNITUDE* — In band. On the days this can realistically fire in a run shaped like the played one (day ~180-275, PROBE STATE day=200 cash=74566 mrr=31775 brand=50 burn=260 cust=25; day=275 cash=134463 mrr=32495 cust=25), the discount is −$191/mo = 0.6 % of company MRR and the satisfaction moves (+6, +8, −5) are one-to-three days of the natural 3/day drift. No cash is touched and no account can be lost on this card.

</details>

**Notes.** This branch is the strongest candidate in the family for a content decision rather than a code fix: three options, all thin, on top of a system (contract renewal) that does not exist. Note also that the tenure term is unbounded and monotone — renewal = 6 × tenure_months with no ceiling (b2b_event_factory.gd:171) — so past roughly month 10 it outscores FEATURE's maximum of 55 permanently, and a calm long-lived account will alternate between this branch and whatever ranks second for the rest of the run.

---

### ev_b2b_request_<customer_id> — FEATURE branch (kind = B2BConstants.CS_KIND_FEATURE, "feature"; also the `_:` default arm)

```
FILE          project-unicorn/scripts/systems/b2b_event_factory.gd — builder B2BEventFactory.build_cs_request, lines 203-300; this branch is the default match arm at lines 268-297. Branch selector pick_request_kind, lines 177-187 (and the empty-eligible fallback at :157-158). Injected from project-unicorn/scripts/systems/customer_rep_system.gd:318.
CATEGORY      B2B account — code-built card, speaker is the top-ranked Müşteri Başarısı employee (b2b_event_factory.gd:223)
REACHABLE     NO, not in the played run — 0 fires (grep 'ev_b2b_request' = 0 hits in run_full_run_730.log; absent from PROBE TALLY 6337-6383), for the one reason that gates the whole family: no Müşteri Temsilcisi was ever hired. The run's single hire on day 55 was a developer (log line 420) and emp stays 1 through the day-275 profitable_bootstrap ending, so CustomerRepSystem.daily_tick returns at customer_rep_system.gd:191 every single morning. This is the DEFAULT branch and the easiest of the three to reach once a rep exists: feature = 20 base, +25 when the account's pain feature is unshipped, +10 when satisfaction >= tolerance, −25 when a promise is already open (b2b_event_factory.gd:179-187), so a healthy account with an unmet need scores 55 and beats a calm complaint (12) and a young renewal (6-18). In a run shaped like the played one — cust=13 by day 100, cust=25 by day 200 with q≈40-46 and accounts sitting near their tolerance bars — this would be the ordinary CS card from the rep's first month onward. It reaches the player only through the absorb valve (difficulty > 3 + top rep's Müşteri Başarısı, customer_rep_system.gd:240-244, :254) or the 3-day staleness path (:290-298); demo difficulty tops out at 7 (:225-237 with scale capped at 3), so a rep at Müşteri Başarısı >= 4 absorbs everything and only _escalate_stale surfaces this card.
FIRES         Same chain as the other two branches: hour 00 daily tick (time_manager.gd:141-143) → SalesSystem.daily_tick → B2BSalesSystem.daily_tick → CustomerRepSystem.daily_tick (b2b_sales_system.gd:41) → _open_due_requests when (day + c.cs_request_phase) % 22 == 0 (customer_rep_system.gd:198-208, CS_REQUEST_INTERVAL_DAYS = 22 at b2b_constants.gd:331) → _work_the_queue spends desk throughput and routes over-ceiling requests to _escalate (:247-259) → _escalate_stale surfaces anything open >= 3 days (:290-298, CS_ESCALATE_AFTER_DAYS = 3) → _escalate enforces the 2-per-7-days ceiling, clears the latch and enqueues (:301-318). No random roll. WHICH BRANCH: pick_request_kind takes the top score among kinds != c.last_request_kind; FEATURE is also the fallback when the eligible list is somehow empty (b2b_event_factory.gd:157-158) and the `_:` default of the match (:268). In plain words it wins when the account is CALM and WANTING: its named pain feature is still unbuilt (+25), it is at or above its tolerance bar (+10), and it does not already owe you a promise (−25 if it does). Ties break on tied[c.cs_request_phase % tied.size()] (:198-199).
FREQUENCY     Repeatable, no cooldown; one_shot/cooldown_days/allowed_hours/build_safe INERT (enqueue bypasses _is_eligible, event_manager.gd:200-214). Real latches: Customer.support_request_since_day (customer.gd:76; opened customer_rep_system.gd:208, cleared :270 on absorb and :316 on escalation, deliberately NOT cleared when the weekly cap bites at :309-310 so the request re-tries tomorrow), the rolling 2-per-7-days company ceiling (:278-287), and Customer.last_request_kind (customer.gd:89, written at b2b_event_factory.gd:226) blocking the same kind twice running. One extra shape latch that belongs to this branch alone: PromiseRegistry.has_open_for(c.id) at :287 removes the 'Söz ver' row entirely while a debt is open, so the card can arrive with TWO options instead of three.
```

**TITLE (TR)** Müşteri talebi  ·  **TITLE (EN)** Customer request
**SUBTITLE (TR)** MISSING — never set (event.gd:31 default "").  ·  **(EN)** MISSING — never set (event.gd:75 default "").
**ALLOWED HOURS** NONE — GameEvent carries no allowed_hours field; windows exist only in EventManager._hour_windows, populated from JSON (event_manager.gd:913-919). Fires at hour 00; the copy contains no clock, correctly.
**PRIORITY** 0 — GameEvent default (event.gd:60), never set; irrelevant since enqueue appends directly (event_manager.gd:212).

**BODY (TR)**

> VOICE variant (fires when c.pain_feature_id != "" AND that feature is NOT in GameState flag mvp_components, b2b_event_factory.gd:275-277): "{company} '{feature}' istiyor: "{voice}" Kendi başıma kapatamadım, karar senin."   ·   PLAIN variant (every other case — pain_feature_id empty OR the feature already live, :278-279): "{company} '{feature}' istiyor. Kendi başıma kapatamadım, karar senin."   ·   {voice} = B2BConstants.pain_phrase(c.pain_feature_id) e.g. "Sistemlerimiz birbiriyle konuşmuyor, entegrasyon şart." (saas_ops_integration) or "Randevu ve planlama dağınık, çakışmalar yaşıyoruz." (saas_ops_scheduling); {feature} = B2BConstants.feature_label(...) e.g. "sistem entegrasyonu", "randevu planlama", or the fallback "yeni özellik" when the id is empty.   ·   OPTIONAL APPENDED CLAUSE (:280-282, only when CompanyCatalog.background_for(c.company_name) resolves): body_text += " " + "Dosya notu: {note}", e.g. "Dosya notu: Fiyat kırarak büyüdü, şimdi hasar dosyalarının altında eziliyor."

**BODY (EN)**

> VOICE: "{company} wants '{feature}': "{voice}" I could not close it on my own; the call is yours."   ·   PLAIN: "{company} wants '{feature}'. I could not close it on my own; the call is yours."   ·   {voice} e.g. "Our systems do not talk to each other; integration is a must."; {feature} e.g. "system integration", "scheduling", fallback "a new feature".   ·   appended: "File note: {note}", e.g. "File note: Grew by undercutting on price, and is now buried under the claims files."

**CHOICE 1** — `Söz ver: '{feature}'   — e.g. "Söz ver: 'sistem entegrasyonu'"` / `Promise it: '{feature}'   — e.g. "Promise it: 'system integration'"`

  *desc:* NONE / NONE

  - **EFFECTS** `b2b_promise_create` — {"type": "b2b_promise_create", "customer_id": c.id, "feature_id": c.pain_feature_id, "deadline_days": 14}  — PROMISE_DEADLINE_DAYS = 14 (b2b_constants.gd:167), authored at b2b_event_factory.gd:289-290
    event_manager.gd:794 → B2BSalesSystem.accept_promise (b2b_sales_system.gd:301): PromiseRegistry.create(customer_id, feature_id, 14) mints an open Promise with deadline_day = day + 14 (promise_registry.gd:56-70), which renders as a 'SÖZ VERİLDİ · <şirket> · <özellik> · N gün' row in the Product detail view (detail_view.gd:461-477) and a dated line on the ODA board (oda_view.gd:1294-1296); then _recover(c, 8) — satisfaction +8, risk_streak 0, churn countdown cleared if in Risk — halved to +4 when the flag b2b_broke_<id> is set (:306-307). Resolution: KEPT on the next ship that adds the feature to mvp_components (promise_registry.gd:112-124) → tolerance −5 permanently, trust_offset +6.0, _recover(+15); BROKEN at deadline+1 → satisfaction −20, tolerance +5 permanently, trust_offset −12.0, brand −3, flag b2b_broke_<id> = true (b2b_sales_system.gd:478-492).
  - **DURATION** one-time +8 (or +4) satisfaction, gone in ~3 days of drift; the resolution is PERMANENT on tolerance (±5, set_tolerance has exactly two writers and no decay path)
  - **CHIP** Müşteri kalır · söz borcu   /  EN: The customer stays · a promise owed   (tr("EFFECT_PROMISE_CREATE"), event_modal.gd:547, kind = accent)
  - **UNLOCK** NONE as a condition — but the ROW ITSELF is conditionally absent: b2b_event_factory.gd:287 appends it only when NOT PromiseRegistry.has_open_for(c.id). When a debt is already open the player is never shown the option at all (not a locked row — an absent one), and the card renders with two choices.

**CHOICE 2** — `Önceliklendir` / `Prioritize it`

  *desc:* NONE / NONE

  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "customer_id": c.id, "delta": 4}  — B2BConstants.CS_PRIORITIZE_SAT = 4 (b2b_constants.gd:361), authored at b2b_event_factory.gd:293
    event_manager.gd:723 → CustomerRegistry.set_satisfaction(c.id, c.satisfaction + 4), clamped 0-100, emits customer_satisfaction_changed (customer_registry.gd:211-224). NOTHING IS PRIORITIZED: no build queue is touched, no design round is pre-seeded, no feature is selected, no promise is created, no flag records the commitment. ProductSystem is never called — a grep of product_system.gd for 'promise' or any request hook returns nothing but two unrelated prose comments.
  - **DURATION** transient — ~1.5 days of drift at SAT_DRIFT_STEP 3/day (b2b_constants.gd:21)
  - **CHIP** Memnuniyet +4   /  EN: Satisfaction +4   (event_modal.gd:496, kind = positive)
  - **UNLOCK** NONE — plain _choice(), unlock_condition = {}

**CHOICE 3** — `Şimdilik olmaz` / `Not right now`

  *desc:* NONE / NONE

  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "customer_id": c.id, "delta": -6}  — B2BConstants.CS_REQUEST_IGNORE_SAT = -6 (b2b_constants.gd:350), authored at b2b_event_factory.gd:296
    event_manager.gd:723 → CustomerRegistry.set_satisfaction(c.id, c.satisfaction − 6), clamped 0-100. The request itself was already closed at escalation time (customer_rep_system.gd:316 cleared support_request_since_day before the enqueue), so the choice's only job is the satisfaction cost; the account will file again on its next 22-day beat.
  - **DURATION** transient — 2 days of drift
  - **CHIP** Memnuniyet -6   /  EN: Satisfaction -6   (event_modal.gd:496, kind = negative)

**FLAGS** — PERMANENT SWING, FREE LUNCH, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **PERMANENT SWING** — Only through the promise row, and only via a hidden field: a resolved promise moves `tolerance` by ±5 permanently (kept b2b_sales_system.gd:455, broken :482), and set_tolerance has no third writer and no decay anywhere in the codebase — the account's Risk bar is ratcheted for the rest of the run by one click. The satisfaction rows are NOT permanent (bidirectional drift toward the product-health target at 3/day, b2b_sales_system.gd:68-81), and this branch touches neither MRR nor cash, so it carries no economic swing of the discount's kind.
- **FREE LUNCH** — 'Önceliklendir' is +4 satisfaction with NO cost whatsoever — a single satisfaction_delta modifier and nothing else (b2b_event_factory.gd:292-294). It spends no cash, no build days, no roadmap slot, no obligation and no counter; it does not even set a flag. Against 'Şimdilik olmaz' at −6 it is a strictly dominant answer worth 10 points of satisfaction for free, and it is the option that remains when the promise row is withheld by the open-debt gate at :287 — i.e. exactly when the player has the least reason to be given a free win.
- **INVISIBLE** **[corrected by the second reader]** — Via the promise row, the same two never-surfaced fields as the rest of the family: `tolerance` (customer.gd:50, marked HIDDEN) and `trust_offset` (customer.gd:75), whose seams emit no signal (customer_registry.gd:256-282) and which a grep of scripts/tabs, scripts/ui and scripts/modals never reads. The satisfaction rows are fully visible (sales_tab.gd:88, :491; portfolio_view.gd:132). Also invisible on every branch: Customer.last_request_kind, written as a side effect of building the card at b2b_event_factory.gd:226.
- **DEAD REFERENCE** — Two. (1) ev.tags = ["build_safe", "b2b_cs_request"] (b2b_event_factory.gd:222) — `b2b_cs_request` has no reader in scripts/, scenes/ or data/, and `build_safe` is inert because its only reader is _is_eligible (event_manager.gd:473), which enqueue never calls (event_manager.gd:200-214). (2) The promise row passes c.pain_feature_id unchecked. The card reaches the PLAIN body exactly when pain_feature_id is "" or already live (b2b_event_factory.gd:275-279), yet the promise row is still offered in both cases: with "" the promise is created against an id that live.has() can never match (promise_registry.gd:119) and is therefore unkeepable by construction, breaking on schedule 14 days later; with an already-live feature the next ship of anything converts it to 'kept' for work that was finished before the promise was made (+15 satisfaction, −5 tolerance, +6 trust for free).
- **COPY LIE** — Two, and the first is the load-bearing one. (1) 'Önceliklendir' / 'Prioritize it' asserts a roadmap action the engine does not perform — nothing is prioritized, queued, scheduled or even recorded; the sole effect is +4 satisfaction. Compare the promise row two lines above it, which at least creates a tracked Promise. Under the EFFECT-VISIBILITY and WRITE-THROUGH laws ('every event choice's narrative claim must match its modifiers'), a label naming a product action backed only by a satisfaction bump is the disease the worked example in CLAUDE.md describes. (2) The PLAIN body fires when the pain feature is EMPTY or ALREADY LIVE (b2b_event_factory.gd:278-279) and still says "{company} '{feature}' istiyor" — so the card can tell the player an account is asking for something the product already shipped, or, with an empty id, that it wants the literal fallback word 'yeni özellik' / 'a new feature'. Neither state is checked before the card is built.
- **VOICE** **[corrected by the second reader]** — Checked and clean as writing. Short, dry, in the rep's own register; the customer's own words are inside quotation marks and the framing sentence belongs to the speaker; the CompanyCatalog 'Dosya notu:' clause is a fact about the account rather than staging (b2b_event_factory.gd:270-272 states the rule: background colors the file note, it never picks the subject). No clock in a card that fires at hour 00. No UI tab or node named in the fiction. No em dash in the TR or EN of B2B_EV_REQUEST_BODY_VOICE / _PLAIN / B2B_FILE_NOTE, nor in the three labels. (What is wrong on this branch is what 'Önceliklendir' claims, filed under COPY_LIE.)

<details><summary>Flags checked and not applicable (5)</summary>

- *REPEATABLE COMPOUND* — Repeatable (every ~22 days per account, 2/week company-wide) but nothing stacks — and this is the branch that gets it RIGHT. The promise row is gated by PromiseRegistry.has_open_for(c.id) at b2b_event_factory.gd:287, so a second debt can never be piled on an open one from here (the comment at :283-286 states the intent explicitly, and this is the gate the escalation card at :124-127 and the complaint branch at :247-250 are missing). The satisfaction rows are erased by the daily drift long before the 22-day cadence brings the card back.
- *NO OP* — Mechanically, no: every row moves state through a live dispatcher arm (b2b_promise_create event_manager.gd:794, satisfaction_delta :723). Narratively 'Önceliklendir' performs nothing it names, but that is a COPY_LIE, not an empty modifier list.
- *IDENTICAL OPTIONS* — No two rows share the same effects. As on the renewal branch it is worth saying plainly that 'Önceliklendir' (+4) and 'Şimdilik olmaz' (−6) are the same lever at two magnitudes — one satisfaction_delta each and nothing else — so whenever the promise row is withheld by the open-debt gate the card degenerates into a two-option pick-a-number, on a card whose body has just quoted the customer's need.
- *BLIND* **[corrected: was flagged, refuted]** — The promise row commits the player to a 14-day obligation and its chip says only 'Müşteri kalır · söz borcu'. The card never states the deadline, never states that NOTHING will schedule the feature, and never states the break cost (−20 satisfaction, +5 permanent tolerance, −12 trust_offset, −3 brand, and the b2b_broke flag that halves every future promise's goodwill via b2b_sales_system.gd:306-307). The one place the deadline surfaces is a different screen — the Product detail view's promise row (detail_view.gd:461-477) — which the player reaches only after the decision is already made.
- *MAGNITUDE* — In band, and the smallest numbers in the family. On the days this can fire in a run shaped like the played one (any day from the first rep hire onward — PROBE STATE day=100 cash=25061 mrr=10625 brand=50 burn=260 cust=13; day=200 cash=74566 mrr=31775 cust=25), the effects are +8/+4/−6 satisfaction against a natural drift step of 3/day and a 0-100 scale. No cash, no MRR, no account loss. If anything the numbers are UNDER band: a card that interrupts the player is worth at most 1.3 days of drift.

</details>

**Notes.** Family-level findings that belong in the audit summary rather than to one branch: (1) THE PROMISE-DEBT GATE IS APPLIED IN TWO OF FOUR PLACES. b2b_event_factory.gd:59-60 (retention card) and :287 (this branch) refuse to offer a second promise while one is open; b2b_event_factory.gd:124-127 (CS escalation 'Tamam, sözü tut') and :247-250 (CS complaint 'Düzeltme sözü ver') do not. The file's own comment at :48-57 records what the missing gate cost when measured — 142 promises to 5 customers, 117 broken, brand 50→0 in 30 days — so this is a known failure mode still open on two surfaces. (2) THE PAIN-FEATURE STATE IS NEVER CHECKED BEFORE A PROMISE IS OFFERED on the escalation card or the complaint branch; only build_retention checks both `pain_feature_id != ""` and `not live_now.has(pain_feature_id)` (:59). (3) All three request branches share one event id (:220), so EventManager's id dedupe (event_manager.gd:209) cannot distinguish them. (4) build_cs_request mutates state during construction (set_last_request_kind, :226), before the card is enqueued. (5) CS_DISCOUNT_PCT = 15 (int, divided by 100.0) and RETAIN_DISCOUNT_PCT = 0.15 (float) are the same 15 % expressed twice in the same constants file (b2b_constants.gd:83, :362); both feed the same seam, so a calibration change to one silently desynchronises the two discount channels.

---

### ev_ps_b2c_producthunt

```
FILE          project-unicorn/data/events/reactive/ev_ps_b2c_producthunt.json (pool event, literal text; loaded by event_manager.gd:872 _load_all_events_from_disk, allowed_hours parsed at event_manager.gd:915-919)
CATEGORY      B2C audience
REACHABLE     NOT in the played run — zero fires (absent from PROBE TALLY; the log's only run is B2B: PROBE STATE shows aud=0 on every one of days 1-275 and mvp_market_type is set to "b2b" by run_probe.gd:845/_open_the_company). Reachable only in a B2C run, and there it needs THREE things at once: (1) the player picks a B2C sub-product so product_system.gd:1120 writes mvp_market_type="b2c"; (2) the paid tier is open — the flag b2c_paid_tier_open is written by SalesSystem.apply_b2c_price (sales_system.gd:568, reached only from pricing_panel.gd:299, the Product tab price slider) or open_b2c_paid_tier (sales_system.gd:296); (3) b2c_audience > 30 as a FLOAT (event_manager.gd:445). Point (3) is the real wall: run_probe.gd:557-560 records a measured B2C autopilot run that "topped out at MRR 135 by day 173" — at B2C_PRICE_DEFAULT 15 and CONVERSION_BASE 0.35 that is ~9 paying users off an audience of ~26, i.e. UNDER the >30 gate for the whole run. So on the only B2C trajectory anyone has measured, this card never arms at all.
FIRES         Hourly ambient path. event_manager.gd:80-115 hourly_tick walks every event with a random trigger (event.gd:84 has_random_trigger), pre-filters on the hour window, then calls _is_eligible (event_manager.gd:462-519) with the window length. Literal trigger_conditions (ev_ps_b2c_producthunt.json:12-29), ANDed, no negation, no OR: market_type == "b2c" (:13-16 → event_manager.gd:441, reads GameState flag mvp_market_type); flag_set "b2c_paid_tier_open" (:17-20 → event_manager.gd:388, tests key PRESENCE not truth — safe by accident here, sales_system.gd:296/568 only ever write true); audience_above 30 (:21-24 → event_manager.gd:445, STRICT >, compared as float so 30.4 passes); random chance 0.4 (:25-28). allowed_hours [20,23] (:30-33) → a 4-hour window (event_manager.gd:544-556 _window_length_hours = 23-20+1 = 4), so the 0.4 is normalised to a PER-HOUR 1-(1-0.4)^(1/4) = 0.119888 (11.99%) rolled once per in-window hour (event_manager.gd:510-515 + :537-541), summing back to exactly 40% per day. At most ONE ambient card enters the queue per calendar day (_ambient_fired_day, event_manager.gd:99-101/113).
FREQUENCY     Repeatable with a real cooldown. This is a POOL event and therefore goes through _is_eligible, so one_shot=false (:35) and cooldown_days=10 (:34) are LIVE, not inert (the enqueue-bypass rule applies only to code-built cards). Cooldown guard at event_manager.gd:489-496 walks _history. Expected cadence = 10 days cooldown + 1/0.4 = 2.5 days expected wait ≈ 12.5 days, i.e. ~14.4 fires per 180 days. Priority 1 (:36) means it loses the one-per-day ambient slot to ev_ps_bug_complaint (priority 2) whenever both pass their roll in the same hour (_ordered_by_priority, event_manager.gd:120-135) — and a loser is simply DROPPED, not requeued.
```

**TITLE (TR)** Vitrin penceresi  ·  **TITLE (EN)** A window in the shop front
**SUBTITLE (TR)** Mesaj · 23:11  ·  **(EN)** Message · 23:11
**PRIORITY** 1 (ev_ps_b2c_producthunt.json:36). Beats ev_ps_power_user_b2c (0), loses to ev_ps_bug_complaint (2).

**BODY (TR)**

> Bir tanıdık yazdı: *"Yarın Vitrin'de çıksana, sana destek olurum."*
>
> Görünürlük demek — bir günlüğüne herkes bakar. Kötü giderse, o da herkesin önünde olur.

**BODY (EN)**

> Someone you know wrote: *"Why not launch on Vitrin tomorrow, I will back you."*
>
> It means visibility — for one day everybody looks. If it goes badly, that is in front of everybody too.

**CHOICE 1** — `Çık — görünürlüğü al` / `Launch — take the visibility`

  - **EFFECTS** `convert_audience` — {"type": "convert_audience", "pct": 0.25, "source": "producthunt"} (:41-45)
    event_manager.gd:742-748: n = int(round(float(GameState.get_flag("b2c_audience", 0.0)) * 0.25)); SalesSystem.add_b2c_audience(n) (sales_system.gd:305-314), which writes the audience flag as a FLOAT and immediately calls _derive_b2c_mrr() + _mrr_bridge(). The "source" key is NEVER READ — the arm reads only "count" and "pct". At the minimum arming audience of 31 this is int(round(7.75)) = +8 people. It is PROPORTIONAL, so at audience 400 it is +100.
  - **EFFECTS** `brand` — {"type": "brand", "delta": 3} (:46-49)
    event_manager.gd:567: GameState.set_brand(GameState.brand + 3), clamped 0-100. From the 50 baseline (game_state.gd:34) this is 50 → 53. Brand is load-bearing three ways: hourly B2C audience growth (sales_system.gd:205, HOURLY_AUD_BRAND_COEF 0.004 per point per hour), VC seed conviction (vc_pitch_system.gd:128, clampi(round((brand-50)*0.4), -12, +12) → +1 conviction here), and the brand-collapse ending floor of 15 (endings_system.gd:28, :112).
  - **EFFECTS** `audience_delta` — {"type": "audience_delta", "delta": 20} (:50-53)
    event_manager.gd:731-739, flat branch (no "pct" key): SalesSystem.add_b2c_audience(20). +20 people, derived MRR recomputed on the spot. Note this is the SAME seam convert_audience just used — the choice fires add_b2c_audience twice with two different chips.
  - **EFFECTS** `cash` — {"type": "cash", "delta": -800} (:54-57)
    event_manager.gd:565: GameState.set_cash(GameState.cash - 800). This is the raw setter (game_state.gd:309-313) — it does NOT go through FinanceSystem.apply_one_time_cost, so record_transaction (finance_system.gd:283-287) never runs and GameState.accrue_month_expense (game_state.gd:498-500) never runs. The $800 leaves the treasury with no Finance-tab transaction row, no line in the gider dökümü, and no entry in the calendar-month expense ledger.
  - **DURATION** convert_audience + audience_delta: permanent additions to the b2c_audience accumulator (it only ever decays through the hourly erosion term, never gets "taken back"). brand +3: permanent (GameState.brand, clamped 0-100 at game_state.gd:326-328). cash: one-time.
  - **CHIP** TR: "Kitleden dönüşüm %25" · "Marka +3" · "Kitle +20" · "Nakit -$800"  ||  EN: "25% of the audience converts" · "Brand +3" · "Audience +20" · "Cash -$800". Four chips, stacked one per row (event_modal.gd:404-411). Kinds: positive, positive, positive, negative.
  - **UNLOCK** NONE — unlock_condition is {} (:59) and is_condition_met returns true on an empty Dictionary (event_manager.gd:371-372). Unconditionally available.

**CHOICE 2** — `Pas geç — organik kal` / `Pass — stay organic`

  - **EFFECTS** `audience_delta` — {"type": "audience_delta", "delta": 6} (:66-69)
    event_manager.gd:737: SalesSystem.add_b2c_audience(6). +6 people, no cost of any kind. At the minimum arming audience of 31 that is +19.4%.
  - **DURATION** permanent (audience addition)
  - **CHIP** TR: "Kitle +6"  ||  EN: "Audience +6". One chip, kind positive.
  - **UNLOCK** NONE — unlock_condition {} (:71).

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, DEAD REFERENCE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — THE WORST CLASS, and it is the pct form that does it. cooldown_days 10 (:34) + 1/0.4 expected wait = ~12.5-day cadence → ~14.4 fires per 180 days. convert_audience pct 0.25 is PROPORTIONAL to the live audience (event_manager.gd:744), so 14 fires multiply the audience by 1.25^14 = 22.7× from that term alone, before the +20 flat (14 × 20 = +280) and before the brand-driven hourly growth those larger audiences all feed. brand +3 × 14 = +42 → brand 50 → 92; 17 fires cap it at 100 (game_state.gd:327), permanently maxing the VC conviction bonus at +12. Nothing in the card ever gets more expensive, harder or more suspicious on the tenth telling.
- **PERMANENT SWING** — brand +3 (:46-49) is permanent and compounds through the hourly audience engine forever. sales_system.gd:205: HOURLY_AUD_BRAND_COEF = 0.004 audience/hour per brand point → +3 brand = +0.012/hour = +0.288/day = +51.84 audience over 180 days (at audience_growth_multiplier 1.0, i.e. price at optimal, sales_system.gd:529-534). At B2C_PRICE_DEFAULT $15 and CONVERSION_BASE 0.35 that is $5.25 of MRR per head → +$272/month of permanent MRR from ONE click, on top of the immediate +28 audience (+$147/month). Total ≈ +$419/month of permanent MRR for a one-time $800. Also permanently raises the VC seed conviction bonus by +1 (vc_pitch_system.gd:128).
- **FREE LUNCH** — Choice 2 "Pas geç — organik kal" is audience_delta +6 (:66-69) and NOTHING ELSE — pure upside, zero cost, zero risk. Declining the opportunity PAYS the player 6 users, which at the minimum arming audience of 31 is +19.4% growth for saying no. There is no branch of this card that can leave the player worse off than before it fired.
- **MAGNITUDE** — Out of band by a wide margin. At the earliest legal fire the audience is 31 (the >30 float gate, event_manager.gd:445); choice 1 adds int(round(31*0.25)) = 8 plus 20 flat = +28, taking the audience 31 → 59, a +90% jump in one click. The played run's log carries no B2C PROBE STATE (aud=0 on all 275 days), so the reference for cash is the same run's Bootstrap band — PROBE STATE day 32 cash=6470, day 51 cash=5896 — against which $800 is 12-14% of the treasury. And the reference for what a B2C company is worth in this build is run_probe.gd:557-560's measured autopilot: "topped out at MRR 135 by day 173". This one card's permanent MRR contribution (+$419/month, PERMANENT_SWING) is roughly THREE TIMES the entire measured lifetime MRR of a B2C run.
- **DEAD REFERENCE** — convert_audience carries "source": "producthunt" (:44) and NOTHING reads it. The dispatcher arm at event_manager.gd:742-748 reads only "count" and "pct"; a grep of the whole file finds exactly one reader of a modifier "source" key — event_manager.gd:677, the add_prospect arm — and that is a different modifier type. The field is authored, saved, and ignored.
- **COPY LIE** — Two lies. (1) The body promises a risk the engine cannot deliver: "Kötü giderse, o da herkesin önünde olur." / "If it goes badly, that is in front of everybody too." Choice 1 has NO bad branch — brand +3, audience +8(pct)+20 and the -$800 are all deterministic, unconditional, and land every single time. Nothing in the card can go badly. (2) The chip on the first modifier says "Kitleden dönüşüm %25" / "25% of the audience converts" (event_modal.gd:536, CSV EFFECT_CONVERT_AUDIENCE), i.e. it tells the player that a quarter of the audience becomes PAYING. It does not: event_manager.gd:742-748 adds raw audience, and the dispatcher's own comment at :743-744 admits it — "growth-move events are now an AUDIENCE SPIKE — MRR follows via the hourly derivation, not a chunk." The chip text was never re-written after Economy Model v2 changed the semantics under it.
- **VOICE** — Three findings. (1) DASHES: three em dashes in player-facing text — body "Görünürlük demek — bir günlüğüne herkes bakar" (:11) and both labels, "Çık — görünürlüğü al" (:39) and "Pas geç — organik kal" (:64). (2) LOCALIZATION INCONSISTENCY, and it is a law breach, not a taste note: "Vitrin" is a proper noun (the in-fiction platform). The EN body keeps it — "Why not launch on Vitrin tomorrow" (:78) — while the EN title TRANSLATES it, "A window in the shop front" (:76). CLAUDE.md BILINGUAL BIRTH LAW: "Proper nouns do not localize." The EN reader meets the platform under two different names on the same card. (3) The speaker is an unnamed "bir tanıdık" / "someone you know" with no identity, no history and no reason to be doing the player a favour — on a repeatable card that fires ~14 times per 180 days, the same anonymous friend offers the same favour over and over. Clean on the other criteria: the clock "23:11" sits inside the real allowed_hours window [20,23] (:30-33) so the time-of-day fiction is honest; no UI tab is named; the quoted line is in-character and the narration is not in the NPC's mouth.

<details><summary>Flags checked and not applicable (4)</summary>

- *NO OP* — Neither choice is a no-op. Choice 1's four modifiers all dispatch to live arms (convert_audience :742, brand :567, audience_delta :731, cash :565); choice 2's audience_delta +6 lands through SalesSystem.add_b2c_audience. The only inert thing on the card is the unread "source": "producthunt" KEY, which is a dead field, not a dead choice — see DEAD_REFERENCE.
- *IDENTICAL OPTIONS* — Two choices, materially different chip sets and materially different effects: choice 1 is +8 (pct) +20 audience / +3 brand / -$800; choice 2 is +6 audience only. No overlap.
- *BLIND* — Objective test (the terminal `return {}` at event_modal.gd:567): every one of the five modifiers across both choices hits a labelled arm — convert_audience (event_modal.gd:536), brand (:491), audience_delta flat (:507), cash (:489). Zero modifiers fall through. The player sees a chip for everything the card does.
- *INVISIBLE* **[corrected: was flagged, refuted]** — Two separate invisibilities. (1) The "source": "producthunt" key (:44) is never read by any consumer — see DEAD_REFERENCE. (2) The $800 outgoing never surfaces as a SPEND anywhere: event_manager.gd:565 calls GameState.set_cash directly, bypassing FinanceSystem.apply_one_time_cost (finance_system.gd:179-193), so there is no row in the transactions log (finance_system.gd:283-287), no line in one_time_today (the gider dökümü), and no accrual into month_ledger["expense"] (game_state.gd:498-500). The balance drops and the Finance tab can never explain why — and the monthly "Artıda" / profitability test that decides the profitable_bootstrap ending reads that same ledger, so a repeated $800 habit is invisible to the win condition.

</details>

**Notes.** Both choices are unconditionally unlocked (unlock_condition {} at :59 and :71 → is_condition_met returns true, event_manager.gd:371-372). Neither choice carries a description field, so the chip column is the player's ONLY information about magnitude. The "tags": ["build_safe"] (:3-5) matters: it lets the card fire during an active v2 build (_is_eligible step 2, event_manager.gd:466-478), which is correct for a post-ship card. Note that choice 1 calls SalesSystem.add_b2c_audience TWICE in one resolve (convert_audience then audience_delta) — the same seam, the same effect, presented to the player as two different kinds of thing.

---

### ev_ps_bug_complaint

```
FILE          project-unicorn/data/events/reactive/ev_ps_bug_complaint.json (pool event, literal text)
CATEGORY      B2C audience
REACHABLE     NOT in the played run — zero fires (absent from PROBE TALLY; the run is B2B, PROBE STATE aud=0 and sat=-1 on all 275 days). In a B2C run it is the EASIEST of the three B2C cards to arm and the first to fire. It needs: mvp_market_type == "b2c"; at least one active customer (customer_count_min 1, event_manager.gd:422) — in a B2C run the ONLY customer record is the aggregate userbase co_b2c_userbase, created by SalesSystem._ensure_b2c_record (sales_system.gd:268-289) which runs only from _derive_b2c_mrr (sales_system.gd:247-253) and is therefore gated behind b2c_paid_tier_open; and min satisfaction < 60 (event_manager.gd:449). That last one is nearly free: the aggregate record is SEEDED with satisfaction = the experience axis score (sales_system.gd:272), and a fresh v1's experience axis sits well under 60 (the played run's composite quality hovered 33.8-44.7 all run), so the card is armed from the moment the price is first set and stays armed until something pushes satisfaction to 60. With priority 2 — the highest in this family — it wins the one-ambient-per-day slot over both other B2C cards.
FIRES         Hourly ambient path (event_manager.gd:80-115 → _is_eligible :462-519). Literal trigger_conditions (ev_ps_bug_complaint.json:12-29), ANDed: market_type == "b2c" (:13-16 → event_manager.gd:441); customer_count_min 1 (:17-20 → event_manager.gd:422, CustomerRegistry.get_active().size() >= 1, INCLUSIVE); customer_satisfaction_below 60 (:21-24 → event_manager.gd:449, CustomerRegistry.get_min_satisfaction("") < 60, STRICT — and note the condition carries NO "market" key, so it scans the WHOLE book while the card's own payload is market-scoped, see notes); random chance 0.5 (:25-28). allowed_hours [9,18] (:30-33) → a 10-hour window, so the 0.5 is normalised to a per-hour 1-(1-0.5)^(1/10) = 0.066967 (6.70%), rolled once per in-window hour (event_manager.gd:510-515, :537-541), summing back to 50%/day. This is the exact event the hourly_tick header comment names: event_manager.gd:93, "bug_complaint's 0.5 landed at ~0.40" under the old p/n approximation.
FREQUENCY     Repeatable with a live cooldown — pool event, so _is_eligible applies: one_shot=false (:35), cooldown_days=8 (:34), enforced at event_manager.gd:489-496. Expected cadence = 8 + 1/0.5 = 10 days → ~18 fires per 180 days, the most frequent card in this family. CRITICALLY: the cooldown is identical on all three branches and NO branch repairs the trigger condition unless satisfaction crosses 60 — so picking "Görmezden gel" re-arms the card in 8 days, forever, with no escalation and no memory.
```

**TITLE (TR)** Bu çalışmıyor  ·  **TITLE (EN)** This does not work
**SUBTITLE (TR)** Destek kutusu · 16:48  ·  **(EN)** Support inbox · 16:48
**PRIORITY** 2 (ev_ps_bug_complaint.json:36) — the highest of the four post-ship pool cards. _ordered_by_priority (event_manager.gd:120-135) sorts descending, so on any hour where this and ev_ps_b2c_producthunt (1) or ev_ps_power_user_b2c (0) both pass their rolls, this one takes the day's single ambient slot and the others are dropped outright, not requeued.

**BODY (TR)**

> Bir kullanıcı herkesin göreceği yere yazmış: *"Söz verdiğiniz şey çalışmıyor."*
>
> Altına başkaları da ekleniyor. Cevap vermemek de bir cevap. Yanlış olanı.

**BODY (EN)**

> A user has posted it where everyone can see: *"The thing you promised does not work."*
>
> Others are piling in underneath. Not answering is an answer too. The wrong one.

**CHOICE 1** — `Herkesin önünde cevap ver` / `Answer in the open`

  *desc:* Hatayı kabul et, düzeltmeyi anlat. Bazıları yine gider. / Own the bug, say what you will fix. Some leave anyway.

  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "delta": 10} (:42-45)
    event_manager.gd:723-730: sc = _resolve_customer_target("", CustomerRegistry.get_lowest_satisfaction_customer(_active_event_market())); _active_event_market() (event_manager.gd:823-829) reads this card's own market_type condition and returns "b2c", so the target is the aggregate userbase co_b2c_userbase. CustomerRegistry.set_satisfaction(id, sat + 10), clamped 0-100 (customer_registry.gd:211-223). Ten points is TEN DAYS of the B2C satisfaction drift, which is ±1/day (sales_system.gd:419-428). It is also enough, in one click, to carry satisfaction across WOM_SAT_GATE = 60 (sales_system.gd:91) and switch on the compounding word-of-mouth growth term.
  - **EFFECTS** `brand` — {"type": "brand", "delta": 2} (:46-49)
    event_manager.gd:567: GameState.set_brand(brand + 2), clamped 0-100. Feeds the hourly audience engine at 0.004 audience/hour per point (sales_system.gd:205) and the VC seed conviction (vc_pitch_system.gd:128).
  - **EFFECTS** `audience_delta` — {"type": "audience_delta", "pct": -0.03} (:50-53)
    event_manager.gd:731-736, the PCT branch (Calibration Round A §7): SalesSystem.add_b2c_audience(int(round(float(GameState.get_flag("b2c_audience", 0.0)) * -0.03))). Proportional. At an audience of 26-40 (the realistic arming band for a B2C run) that is int(round(-0.78)) to int(round(-1.2)) = -1 person.
  - **DURATION** satisfaction +10: permanent until the ±1/day B2C drift moves it (sales_system.gd:419-428). brand +2: permanent. audience -3%: permanent (proportional one-time subtraction).
  - **CHIP** TR: "Memnuniyet +10" · "Marka +2" · "Kitle -%3"  ||  EN: "Satisfaction +10" · "Brand +2" · "Audience -3%". Kinds: positive, positive, negative. (The description line renders above the chips, event_modal.gd:397-402.)
  - **UNLOCK** NONE — unlock_condition {} (:55).

**CHOICE 2** — `Özelden yaz, konuyu kapat` / `Reply in private, close the thread`

  *desc:* Sessiz düzelt. Konu açık kalır. / Fix it quietly. The thread stays open.

  - **EFFECTS** `satisfaction_delta` — {"type": "satisfaction_delta", "delta": 6} (:64-67)
    Same path as choice 1: event_manager.gd:723-730 → CustomerRegistry.set_satisfaction on the B2C aggregate, +6 (six days of drift).
  - **EFFECTS** `brand` — {"type": "brand", "delta": -1} (:68-71)
    event_manager.gd:567: GameState.set_brand(brand - 1). -0.004 audience/hour permanently = -17.3 audience over 180 days.
  - **EFFECTS** `audience_delta` — {"type": "audience_delta", "pct": -0.01} (:72-75)
    event_manager.gd:732-733, pct branch: add_b2c_audience(int(round(audience * -0.01))). At audience 26-99 this rounds to 0 or -1 person.
  - **DURATION** permanent (satisfaction subject to daily drift; brand and audience permanent)
  - **CHIP** TR: "Memnuniyet +6" · "Marka -1" · "Kitle -%1"  ||  EN: "Satisfaction +6" · "Brand -1" · "Audience -1%". Kinds: positive, negative, negative.
  - **UNLOCK** NONE — unlock_condition {} (:77).

**CHOICE 3** — `Görmezden gel` / `Ignore it`

  - **EFFECTS** `churn_customer` — {"type": "churn_customer"} (:85-87) — no customer_id key, so the target defaults
    event_manager.gd:678-702: victim = _resolve_customer_target("", CustomerRegistry.get_lowest_satisfaction_customer("b2c")) — the market comes from this card's own market_type condition via _active_event_market (event_manager.gd:823-829). victim.market_type == "b2c", so the B2C BRANCH runs: aud = float(GameState.get_flag("b2c_audience", 0.0)); SalesSystem.add_b2c_audience(-int(round(aud * 0.15))). That is a 15% AUDIENCE EROSION, PROPORTIONAL and unbounded — 5 people at audience 31, 150 people at audience 1000. The customer record is NOT removed, GameState.run_customers_lost is NOT incremented (that line, event_manager.gd:697, lives only in the else/B2B branch), and SalesSystem.reflect_mrr() is not called on this path either (the derive inside add_b2c_audience covers it).
  - **EFFECTS** `brand` — {"type": "brand", "delta": -2} (:88-91)
    event_manager.gd:567: GameState.set_brand(brand - 2). Permanent; -0.008 audience/hour = -34.56 audience over 180 days; and it walks toward BRAND_COLLAPSE_FLOOR = 15 (endings_system.gd:28), which after BRAND_COLLAPSE_WINDOW = 30 days below the floor ends the run (endings_system.gd:112-155).
  - **DURATION** permanent
  - **CHIP** TR: "Müşteri kaybı" · "Marka -2"  ||  EN: "A customer lost" · "Brand -2". Kinds: negative, negative.
  - **UNLOCK** NONE — unlock_condition {} (:93).

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — Yes, on BOTH ends. cooldown_days 8 + 1/0.5 = ~10-day cadence → ~18 fires per 180 days. UPWARD: choice 1's satisfaction +10 is a ratchet that repeats until the card's own trigger band (satisfaction < 60) closes — the punishment card is a free elevator to the word-of-mouth gate, and it self-disarms exactly when it has finished paying out. DOWNWARD: choice 3 repairs NOTHING (no satisfaction modifier at all), so the trigger stays true and the card re-arms every 8 days forever, each time taking 15% of the audience and 2 brand. 18 ignores over 180 days = 0.85^18 = 5.4% of the audience left standing, and brand 50 - 36 = 14, which is BELOW BRAND_COLLAPSE_FLOOR 15 (endings_system.gd:28) — a card that fires because of a bug can, unaided, end the run by brand collapse.
- **PERMANENT SWING** — Two permanent levers on one card. (1) brand ±: choice 1's +2 = +34.56 audience over 180 days (≈ +$181/month of MRR at price 15, conversion 0.35); choice 3's -2 is the exact mirror, -34.56. (2) The bigger one is satisfaction +10 crossing WOM_SAT_GATE = 60 (sales_system.gd:91). Above that gate the growth term gains `grow += audience * WOM_COEF * (sat-60)/100` with WOM_COEF = 0.005/hour (sales_system.gd:90, :214) — an audience-PROPORTIONAL, i.e. exponential, term that did not exist a moment earlier. At satisfaction 70 that is 0.0005 per audience member per hour = +1.2%/day compounding, forever. One click flips a linear economy into a compounding one.
- **MAGNITUDE** — Wildly asymmetric within one card. The costs are rounding errors and the rewards are structural. At the realistic B2C arming band — the only measured B2C trajectory in the project reaches MRR 135 by day 173 (run_probe.gd:557-560), i.e. ~9 paying users off an audience of ~26 — choice 1's headline cost of "Kitle -%3" is int(round(26 * -0.03)) = -1 PERSON, and choice 2's "-%1" rounds to 0. Meanwhile satisfaction +10 is one sixth of the entire 0-60 trigger band and ten days of drift, and it can flip the WOM gate. Conversely choice 3's cost is unbounded and proportional: 15% of the audience, which is 4 people at audience 26 and 150 at audience 1000 — the SAME chip text ("Müşteri kaybı") for both.
- **COPY LIE** — Three. (1) The choice-3 chip reads "Müşteri kaybı" / "A customer lost" (event_modal.gd:534, CSV EFFECT_CHURN) but the B2C branch loses NO customer: event_manager.gd:684-688 erodes 15% of the audience, leaves the co_b2c_userbase record in place, and never touches run_customers_lost. The player is told a specific, countable thing happened; it did not, and the ending's lost-customer tally will prove it. (2) Choice 2's description asserts "Konu açık kalır." / "The thread stays open" as if it were a distinguishing consequence — it is not. cooldown_days 8 is identical on all three branches (:34, enforced at event_manager.gd:489-496) and no branch writes any flag; the thread is exactly as open after answering in public, answering in private, or ignoring it. (3) The body says "Cevap vermemek de bir cevap. Yanlış olanı." — that silence is the wrong answer — while the engine makes the silent option cheap and self-perpetuating: it repairs nothing, so the card returns in 8 days to be ignored again at the same price.
- **VOICE** — The strongest-written card of the four, and it still has findings. CLEAN on: no dash anywhere in body, labels or descriptions (checked all six strings); the clock "16:48" sits inside the real allowed_hours window [9,18] (:30-33), so the time-of-day fiction is honest; no UI node or tab is named; the quoted user line is in-character and the narration is not in an NPC's mouth. FINDINGS: (1) DESCRIPTION ASYMMETRY — choices 1 and 2 carry a description line, choice 3 does not (:82-96), so "Görmezden gel" is the only option the player must judge from its chips alone, and it is the run-shaping one. (2) On a card that fires ~18 times per 180 days, the complainant is a permanently anonymous "bir kullanıcı" with no name, no product feature, no bug identity and no memory of the last seventeen times — the engine HAS a live bug count (mvp_live_bug_count, read at sales_system.gd:418) and the card never once mentions what is actually broken. (3) "Söz verdiğiniz şey çalışmıyor" — "the thing you promised" — invokes a promise the B2C path has no machinery for (B2BSalesSystem.accept_promise is the B2B engine and cannot be reached from a b2c-gated card).

<details><summary>Flags checked and not applicable (6)</summary>

- *FREE LUNCH* — Checked and it does not apply: all three choices carry an explicit downside modifier — choice 1 audience -3%, choice 2 brand -1 AND audience -1%, choice 3 churn plus brand -2. There is no zero-cost option. WORTH RECORDING THOUGH, because the cost is nominal rather than real: choice 1's only cost at the realistic arming audience of 26-40 is ONE person, while its brand +2 alone yields +34.56 audience over 180 days (0.008/hour × 24 × 180) and its satisfaction +10 can open the compounding WOM term. The option is a ~35:1 payoff wearing the costume of a sacrifice.
- *NO OP* — No no-op branch. All eight modifiers across three choices reach live dispatcher arms (satisfaction_delta :723, brand :567, audience_delta pct :732, churn_customer :678). The pct forms CAN round to zero (int(round(audience * -0.01)) = 0 below audience 50), but that is a magnitude artefact of a live effect, not a dead one.
- *IDENTICAL OPTIONS* — Three distinct chip sets and three distinct outcomes. Choices 1 and 2 share a SHAPE (satisfaction+, brand±, audience-%) but every number differs (+10/+2/-3% vs +6/-1/-1%) and the sign on brand flips, which is the whole trade. Choice 3 is a different kind of thing entirely.
- *BLIND* — Objective test (event_modal.gd:567 terminal `return {}`): every modifier on the card resolves to a labelled arm — satisfaction_delta (event_modal.gd:496), brand (:491), audience_delta pct (:500-506), churn_customer (:534). Nothing falls through. Chips exist for all eight. (Whether the churn chip is TRUE is a different flag — see COPY_LIE.)
- *INVISIBLE* — Checked: no invisible effect. This is the one card in the family with NO cash modifier, so it does not hit the ledger-bypass problem the other three do. Satisfaction surfaces as the customer's health band (customer_registry.gd:223 update_health_from_satisfaction + emit), brand surfaces in the TopBar (top_bar.gd:150), audience surfaces as the audience figure and the derived MRR (SalesSystem._derive_b2c_mrr runs inside add_b2c_audience). The nearest thing to an invisibility is that the B2C churn branch never increments GameState.run_customers_lost (event_manager.gd:697 is in the else branch only), so the ending screen's lost-customer count never records what the chip just promised — but that is a truthfulness defect, filed under COPY_LIE.
- *DEAD REFERENCE* — Checked every field. All four modifier types are present in _apply_modifiers' 44 arms. Both description / description_en fields are read and rendered (event_modal.gd:397-402). No unread keys (unlike ev_ps_b2c_producthunt's "source"). The one structural oddity — customer_satisfaction_below (:21-24) omitting the optional "market" key, so event_manager.gd:449 scans the whole book with market="" while the card's own churn and satisfaction modifiers are market-SCOPED to b2c via _active_event_market — is an inconsistency, not a dead reference: in a single-market run only B2C records exist, so the unscoped gate and the scoped payload agree by accident.

</details>

**Notes.** All three choices are unconditionally unlocked (unlock_condition {} at :55, :77, :93 → is_condition_met true, event_manager.gd:371-372). "tags": ["build_safe"] (:3-5) lets it fire during a v2 build. The interaction that most deserves a designer's eye: this card's trigger is satisfaction < 60 and its best answer grants +10 satisfaction, while the B2C drift is only ±1/day (sales_system.gd:419-428) — so the card is, mechanically, ten free days of satisfaction repair handed to the player every ten days, priced at one lost user. Also note that priority 2 makes this card a STARVATION source for the rest of the B2C family: it is armed almost continuously in a young B2C run and it takes the single daily ambient slot (event_manager.gd:99-101, :113) whenever it and another B2C card both pass their rolls in the same hour.

---

### ev_ps_power_user_b2c

```
FILE          project-unicorn/data/events/reactive/ev_ps_power_user_b2c.json (pool event, literal text)
CATEGORY      B2C audience
REACHABLE     NOT in the played run — zero fires (absent from PROBE TALLY; the run is B2B, aud=0 on all 275 days). And in a B2C run it is the HARDEST of the three to reach, on two independent counts. (1) Its audience gate is the highest: audience_above 40 (event_manager.gd:445, strict float >) versus 30 for ev_ps_b2c_producthunt and none for ev_ps_bug_complaint. The only measured B2C trajectory in the project — run_probe.gd:557-560, "a B2C autopilot run was played first and topped out at MRR 135 by day 173" — implies an audience of roughly 26 at price 15 / conversion 0.35, i.e. it NEVER crosses 40 in a whole run. (2) Its priority is 0, the lowest in the family, so on any hour where ev_ps_bug_complaint (2) or ev_ps_b2c_producthunt (1) also passes its roll, this card is dropped and not requeued (_ordered_by_priority, event_manager.gd:120-135; one-ambient-per-day cap at :99-101/:113). It also needs customer_count_min 1, which in a B2C run means the aggregate userbase record exists, which means the paid tier is already open (sales_system.gd:247-253, :268-289). Verdict: reachable in principle, but on the measured B2C curve it is the least reachable card of the four.
FIRES         Hourly ambient path (event_manager.gd:80-115 → _is_eligible :462-519). Literal trigger_conditions (ev_ps_power_user_b2c.json:12-29), ANDed: market_type == "b2c" (:13-16 → event_manager.gd:441); customer_count_min 1 (:17-20 → event_manager.gd:422, inclusive >=); audience_above 40 (:21-24 → event_manager.gd:445, strict >, float compare); random chance 0.3 (:25-28). allowed_hours [18,22] (:30-33) → a 5-hour window (event_manager.gd:544-556), so the 0.3 is normalised to a per-hour 1-(1-0.3)^(1/5) = 0.068846 (6.88%) rolled once per in-window hour (event_manager.gd:510-515, :537-541), summing back to 30%/day.
FREQUENCY     Repeatable with a live cooldown — pool event, so _is_eligible applies: one_shot=false (:35), cooldown_days=12 (:34), enforced at event_manager.gd:489-496. Nominal cadence = 12 + 1/0.3 = 15.33 days → ~11.7 fires per 180 days. REAL cadence is lower than that because priority 0 loses every contested day to the other two B2C cards.
```

**TITLE (TR)** Erken hayran  ·  **TITLE (EN)** An early admirer
**SUBTITLE (TR)** Akış · 19:30  ·  **(EN)** The feed · 19:30
**PRIORITY** 0 (ev_ps_power_user_b2c.json:36) — the lowest of the four post-ship pool cards, and the only one at 0. Structurally starved by ev_ps_bug_complaint (2), which in a young B2C run is armed almost continuously.

**BODY (TR)**

> Bir kullanıcı ürünü göklere çıkarmış: *"Bu araç iş akışımı değiştirdi, herkes denemeli."* Altında yorumlar birikiyor.
>
> Momentum küçük ama gerçek. Üstüne gidersen büyür.

**BODY (EN)**

> A user has been raving about the product: *"This tool changed how I work, everybody should try it."* The replies are piling up underneath.
>
> The momentum is small but real. Lean on it and it grows.

**CHOICE 1** — `Tanıtım yaz — momentumu kullan` / `Write a post — use the momentum`

  - **EFFECTS** `brand` — {"type": "brand", "delta": 4} (:41-44)
    event_manager.gd:567: GameState.set_brand(GameState.brand + 4), clamped 0-100 (game_state.gd:326-328). From the 50 baseline that is 50 → 54. The LARGEST single brand grant in this whole family. Feeds the hourly audience engine at HOURLY_AUD_BRAND_COEF 0.004/hour per point (sales_system.gd:205), the VC seed conviction at clampi(round((brand-50)*0.4), -12, +12) (vc_pitch_system.gd:128), and the brand-collapse floor of 15 (endings_system.gd:28).
  - **EFFECTS** `audience_delta` — {"type": "audience_delta", "delta": 25} (:45-48)
    event_manager.gd:731-739, flat branch: SalesSystem.add_b2c_audience(25) (sales_system.gd:305-314) → b2c_audience flag += 25.0, then _derive_b2c_mrr() + _mrr_bridge() immediately, so the MRR jump is visible on the spot. At the minimum arming audience of 41 that is +61%.
  - **EFFECTS** `cash` — {"type": "cash", "delta": -600} (:49-52)
    event_manager.gd:565: GameState.set_cash(GameState.cash - 600) — the RAW setter (game_state.gd:309-313), bypassing FinanceSystem.apply_one_time_cost (finance_system.gd:179-193). No record_transaction row, no one_time_today line, no accrue_month_expense. See INVISIBLE.
  - **DURATION** brand +4 and audience +25 are permanent; cash is one-time.
  - **CHIP** TR: "Marka +4" · "Kitle +25" · "Nakit -$600"  ||  EN: "Brand +4" · "Audience +25" · "Cash -$600". Kinds: positive, positive, negative.
  - **UNLOCK** NONE — unlock_condition {} (:54).

**CHOICE 2** — `Sessiz kal` / `Stay quiet`

  - **EFFECTS** `audience_delta` — {"type": "audience_delta", "delta": 5} (:61-64)
    event_manager.gd:737: SalesSystem.add_b2c_audience(5). +5 people, no cost, no risk, no downside modifier of any kind.
  - **DURATION** permanent
  - **CHIP** TR: "Kitle +5"  ||  EN: "Audience +5". One chip, kind positive.
  - **UNLOCK** NONE — unlock_condition {} (:66).

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — Repeatable (one_shot false, cooldown 12) and the brand half compounds. Nominal cadence 15.33 days → ~11.7 fires per 180 days → brand +4 × 11.7 = +47, i.e. brand 50 → 97, and 13 fires cap it at 100 (game_state.gd:327), permanently maxing the VC conviction bonus at +12. Each brand point permanently raises the hourly audience inflow, and each new audience member permanently raises the word-of-mouth term (grow += audience * WOM_COEF * (sat-60)/100, sales_system.gd:214), so the two levers feed each other. The audience half is FLAT (+25), not proportional, which is the one thing keeping this card below ev_ps_b2c_producthunt's pct-form compounding — the brand half is not so restrained.
- **PERMANENT SWING** — brand +4 is the largest permanent brand grant in the family and it never expires. sales_system.gd:205: 0.004 audience/hour per brand point → +4 = +0.016/hour = +0.384/day = +69.12 audience over 180 days at multiplier 1.0 (sales_system.gd:529-534). At price 15 / conversion 0.35 = $5.25 per head that is +$363/month of PERMANENT MRR, on top of the immediate +25 audience (+$131/month). Total ≈ +$494/month of permanent recurring revenue for one click and a one-time $600 — payback in under 1.3 months, then pure profit forever. For scale: the only measured B2C run in the project reached MRR 135 total (run_probe.gd:557-560), so a single resolution of this card is worth ~3.7× an entire measured B2C company. Also permanently lifts the VC seed conviction bonus by +2 (vc_pitch_system.gd:128).
- **FREE LUNCH** — Choice 2 "Sessiz kal" / "Stay quiet" is audience_delta +5 (:61-64) and nothing else. The player is paid five users for doing nothing. At the minimum arming audience of 41 that is +12.2% growth for declining to act, and it feeds straight into the compounding hourly engine (each of those 5 heads earns the WOM term and the churn term forever). Identical in shape to ev_ps_b2c_producthunt's "Pas geç" (+6) — the family has a systemic habit of paying for refusal.
- **MAGNITUDE** — Out of band. At the earliest legal fire the audience is 41 (the >40 float gate) and choice 1 adds 25, a +61% jump in one click. The permanent MRR contribution (+$494/month, see PERMANENT_SWING) is 3.7× the ENTIRE measured lifetime MRR of a B2C run (135 by day 173, run_probe.gd:557-560). The played log carries no B2C cash reference (aud=0, market b2b throughout), so the cash yardstick is the same run's Bootstrap treasury — PROBE STATE day 32 cash=6470, day 51 cash=5896 — against which $600 is 9-10%. The card is priced like a small expense and pays like a funding round.
- **COPY LIE** — The weakest instance of the four, but real: the copy and the modifiers disagree about money. The label is "Tanıtım yaz" / "Write a post" — writing a post is free labour — and the body's only framing is "Üstüne gidersen büyür" / "Lean on it and it grows." Nowhere does the card mention spending anything, yet the choice charges $600 (:49-52). The WRITE-THROUGH LAW's claim-matching rule runs in both directions ("every event choice's narrative claim must match its modifiers"); here the modifier makes a claim the fiction never makes, and the player's only notice is the chip. A secondary, softer point: the body's "Üstüne gidersen büyür" implies growth is conditional on acting, while "Sessiz kal" also grows the audience (+5) — staying quiet is never the stagnation the sentence promises.
- **VOICE** — CLEAN on: the clock "19:30" sits inside the real allowed_hours window [18,22] (:30-33), so the time-of-day fiction is honest; no UI node or tab is named; the quoted line is in-character and the narration is not put in the NPC's mouth; "momentum" is on the ruled-accepted TR-tech loanword list (CLAUDE.md LANGUAGE INTEGRITY LAW). FINDINGS: (1) DASH: one em dash in the label "Tanıtım yaz — momentumu kullan" (:39 / :56 EN). (2) The card implies a system that is not in this release. CLAUDE.md's RELEASE SCOPE table puts the Marketing system in EARLY ACCESS, and the EVENT AUTHORING LAW says "No event implies an unbuilt system" — "Tanıtım yaz" plus an unexplained $600 charge reads as paid promotion, a lever the player has nowhere else in the build. (3) On a card that repeats every ~15 days, the admirer is a permanently anonymous "bir kullanıcı" whose praise never changes wording, never names the product (the engine has mvp_product_name, read at sales_system.gd:281), and never acknowledges being the eleventh such admirer.

<details><summary>Flags checked and not applicable (5)</summary>

- *NO OP* — Neither choice is a no-op. All four modifiers across the two choices hit live arms (brand event_manager.gd:567, audience_delta :731-739 twice, cash :565), every one of them moves visible state, and no key on the card is unread.
- *IDENTICAL OPTIONS* — Two choices, different chip sets, different effects: +4 brand / +25 audience / -$600 versus +5 audience alone. No overlap in either the chips or the state changes.
- *BLIND* — Objective test (event_modal.gd:567 terminal `return {}`): brand → event_modal.gd:491, audience_delta flat → :507, cash → :489. All four modifiers produce chips; none falls through.
- *INVISIBLE* **[corrected: was flagged, refuted]** — The $600 never surfaces as a SPEND. event_manager.gd:565 writes GameState.set_cash directly instead of routing through FinanceSystem.apply_one_time_cost (finance_system.gd:179-193), so record_transaction (finance_system.gd:283-287) never appends a row to GameState.transactions, one_time_today never gets a line for the gider dökümü, and GameState.accrue_month_expense (game_state.gd:498-500) never adds it to month_ledger["expense"]. Consequences: the Finance tab's transaction log cannot explain the drop, and — more seriously — the calendar-month profitability ledger that decides the "Artıda" verdict and the profitable_bootstrap ending never counts this money as spent. It is also a WRITE-THROUGH LAW breach in spirit: Finance owns cash, and this modifier pokes past it.
- *DEAD REFERENCE* — Checked every field. All three modifier types are live arms in _apply_modifiers. Every key authored on the card is read: "delta" by brand (:567), "delta" by audience_delta's flat branch (:737), "delta" by cash (:565). No unread "source"-style field (unlike ev_ps_b2c_producthunt:44). Both trigger condition types (customer_count_min, audience_above) exist in is_condition_met.

</details>

**Notes.** Both choices unconditionally unlocked (unlock_condition {} at :54 and :66 → is_condition_met true, event_manager.gd:371-372). Neither carries a description field, so the chips are the player's only information. "tags": ["build_safe"] (:3-5). The structural observation worth carrying forward: this is the family's clearest case of a card whose GATE is calibrated against a curve the game does not produce — audience_above 40 sits above the ceiling of the only B2C run anyone has measured (run_probe.gd:557-560) — while its PAYOUT is calibrated as if the player were much larger. Fix one and the other becomes wrong.

---

### ev_ps_referral_b2b

```
FILE          project-unicorn/data/events/reactive/ev_ps_referral_b2b.json (pool event, literal text)
CATEGORY      B2B account
REACHABLE     YES, and it is by a wide margin the most-fired authored card in the played run: PROBE TALLY ev_ps_referral_b2b fires=16 picks=16, out of 62 total fires in the whole run. Exact fire days and hours from PROBE FIRE: day 32 h13, 51 h15, 67 h12, 81 h10, 95 h16, 110 h12, 128 h11, 143 h11, 155 h10, 169 h9, 183 h9, 197 h15, 211 h16, 226 h9, 239 h17, 252 h17. Every single one was answered with choice 0 (PROBE PICK ... choice=0 label=Kabul et — özellik sözü ver, sixteen times). It is effectively the ONLY ambient card alive in a post-ship B2B run: the three B2C siblings all fail market_type, the nine ev_mvp_* build cards all fail build_phase once no build is active (event_manager.gd:411-415 returns false on a null build), and neither ev_debug_001 nor ev_debug_002 fired at all. So it takes the one-ambient-per-day slot essentially uncontested.
FIRES         Hourly ambient path (event_manager.gd:80-115 → _is_eligible :462-519). Literal trigger_conditions (ev_ps_referral_b2b.json:12-25), ANDed, only THREE of them — the loosest gate of the four: market_type == "b2b" (:13-16 → event_manager.gd:441, reads GameState flag mvp_market_type, written by product_system.gd:1120 from the chosen sub-product); customer_count_min 1 (:17-20 → event_manager.gd:422, CustomerRegistry.get_active().size() >= 1, inclusive); random chance 0.3 (:21-24). NO satisfaction gate, NO MRR gate, NO phase gate, NO day gate. allowed_hours [9,17] (:26-29) → a 9-hour window (event_manager.gd:544-556 = 17-9+1), so the 0.3 is normalised to a per-hour 1-(1-0.3)^(1/9) = 0.038855 (3.89%) rolled once per in-window hour (event_manager.gd:510-515, :537-541), summing back to 30%/day. Every one of the 16 observed fire hours (9-17) falls inside that window, confirming the gate is live.
FREQUENCY     Repeatable with a live cooldown — pool event, so _is_eligible applies and the JSON fields are NOT inert: one_shot=false (:31), cooldown_days=12 (:30), enforced at event_manager.gd:489-496 against _history. Nominal cadence = 12 + 1/0.3 = 15.33 days. OBSERVED cadence across the 16 fires: intervals of 19, 16, 14, 14, 15, 18, 15, 12, 14, 14, 14, 14, 15, 13, 13 days — mean 14.67 days, i.e. the card runs essentially cooldown-limited for the entire back half of the run. Extrapolated to the 730-day preset it would fire ~47 times. Nothing re-arms it and nothing wears it out; the only thing that ever changes is that it silently stops working (see NO_OP).
```

**TITLE (TR)** Patronun arkadaşı  ·  **TITLE (EN)** The boss's friend
**SUBTITLE (TR)** E-posta · 13:05  ·  **(EN)** Email · 13:05
**PRIORITY** 1 (ev_ps_referral_b2b.json:32). In a B2B run this is academic — the three priority-2/1/0 B2C siblings can never pass market_type, so there is no contention for the daily ambient slot.

**BODY (TR)**

> Müşterilerinden birinin genel müdürü yazmış — sözleşmeye imzayı atan adamın kendisi: *"Geçen hafta bir tedarikçi yemeğinde başka bir şirketin sahibiyle konuştum, sizin üründen bahsettim. Ciddi ilgilendi — isterseniz tanıştırayım."*
>
> E-postanın sonunda bir şart: *"Tek ricam, şu özelliği yol haritanıza almanız. İki şirket de kullanır."*
>
> Patron seviyesinden açılan bir kapı — ama yol haritana bir borç yazıyor.

**BODY (EN)**

> The managing director of one of your customers has written — the man who signed the contract himself: *"At a supplier dinner last week I got talking to the owner of another company and mentioned your product. He was seriously interested — I can introduce you if you like."*
>
> At the end of the email, one condition: *"My only request is that you put a certain feature on your roadmap. Both companies would use it."*
>
> A door opened at boss level — and a debt written onto your roadmap.

**CHOICE 1** — `Kabul et — özellik sözü ver` / `Accept — promise the feature`

  - **EFFECTS** `add_prospect` — {"type": "add_prospect", "archetype": "mid", "source": "referral"} (:37-41)
    event_manager.gd:676-677: PitchSystem.spawn_prospect("mid", "referral") (pitch_system.gd:42-101). Builds a Prospect with archetype "mid" → CustomerArchetypes.TABLE["mid"] (customer_archetypes.gd:30-37): seats 12, expansion_seats 6, mrr_band {low: 800, high: 2000}, scale_base 3, difficulty_stars 2, budget_band "mid". The displayed value band is midpoint 1400 × VALUE_BAND_LOW_FRAC 0.65 = $910 and × VALUE_BAND_HIGH_FRAC 1.15 = $1610 (b2b_constants.gd:243-244, pitch_system.gd:94-96). If the player closes it, that is $800-$2,000 of PERMANENT monthly recurring revenue. CRITICAL: spawn_prospect can return NULL and silently register nothing — pitch_system.gd:74-75, when every catalog company in the product's affinity sectors is already signed or already a live lead. Signed names are NEVER freed (pitch_system.gd:44-47: "churn does NOT re-open cold prospecting"). See NO_OP for what that did in the played run.
  - **EFFECTS** `cash` — {"type": "cash", "delta": -400} (:42-45)
    event_manager.gd:565: GameState.set_cash(GameState.cash - 400) — the raw setter (game_state.gd:309-313), bypassing FinanceSystem.apply_one_time_cost (finance_system.gd:179-193). No transaction row, no gider dökümü line, no month-ledger expense accrual. Charged UNCONDITIONALLY, including on the fires where add_prospect returned null.
  - **DURATION** add_prospect: one-time spawn, but a prospect that closes becomes a PERMANENT recurring account. cash: one-time.
  - **CHIP** TR: "Yeni aday" · "Nakit -$400"  ||  EN: "A new prospect" · "Cash -$400". Kinds: positive, negative. NOTE: the chip says only "Yeni aday" — it does NOT say the prospect is a MID one. It is byte-identical to the chip on choice 2, which spawns a SMALL prospect.
  - **UNLOCK** NONE — unlock_condition {} (:47), is_condition_met returns true on an empty Dictionary (event_manager.gd:371-372).

**CHOICE 2** — `Pazarlık et — söz verme` / `Negotiate — promise nothing`

  - **EFFECTS** `add_prospect` — {"type": "add_prospect", "archetype": "small", "source": "referral"} (:54-58)
    event_manager.gd:676-677: PitchSystem.spawn_prospect("small", "referral"). archetype "small" → CustomerArchetypes.TABLE["small"] (customer_archetypes.gd:22-29): seats 4, expansion_seats 3, mrr_band {low: 200, high: 500}, scale_base 2, difficulty_stars 1, budget_band "low". Value band $130-$230 shown. NO cash cost. Same null risk as choice 1 (pitch_system.gd:74-75).
  - **DURATION** one-time spawn; a closed account is permanent
  - **CHIP** TR: "Yeni aday"  ||  EN: "A new prospect". One chip, kind positive. BYTE-IDENTICAL to the reward chip on choice 1, for a prospect worth a quarter as much.
  - **UNLOCK** NONE — unlock_condition {} (:60).

**CHOICE 3** — `Reddet — yol haritan temiz kalsın` / `Decline — keep your roadmap clean`

  - **EFFECTS** `reputation` — {"type": "reputation", "delta": 2} (:66-70)
    event_manager.gd:569: GameState.set_reputation(GameState.reputation + 2), clamped -10..100. Baseline is 0 (game_state.gd:35), so this is 0 → 2. WHO READS IT: sales_system.gd:206 (HOURLY_AUD_REPUTATION_COEF 0.01 in the B2C audience growth term — DEAD here, _tick_b2c_audience only runs when market == "b2c", sales_system.gd:160-162, and this card can only fire in a B2B run); vc_pitch_system.gd:716 (`if GameState.reputation < 0` — a penalty branch only, so a POSITIVE value changes nothing); event_manager.gd:382-383 reputation_below / reputation_above (authored by exactly one event, ev_debug_002_press_inquiry); top_bar.gd:151 (displays it); endings_system.gd:298 (records it in the ending snapshot). In the market this card can fire in, at reputation >= 0, nothing mechanical reads it.
  - **DURATION** permanent (GameState.reputation, clamped -10..100 at game_state.gd:330-334)
  - **CHIP** TR: "İtibar +2"  ||  EN: "Reputation +2". One chip, kind positive.
  - **UNLOCK** NONE — unlock_condition {} (:72).

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, NO OP, DEAD REFERENCE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — The worst class, and the played run is the proof. one_shot=false (:31), cooldown_days=12 (:30), chance 0.3/day → observed mean interval 14.67 days across 16 fires spanning days 32-252, with 16/16 accepted. Every accept adds a permanent recurring account; every account raises MRR; nothing about the card ever gets harder, more expensive, more suspicious, or gated on how many times it has already fired. There is no diminishing return, no relationship cost, no rising bar — which is precisely what CALIBRATION LAW 1 ("Money must NEVER stop mattering... build anti-snowball mechanics") forbids. Extrapolated to the 730-day preset it fires ~47 times. Its only brake is accidental and invisible: the company catalog running dry (see NO_OP).
- **PERMANENT SWING** — A mid prospect that closes is PERMANENT recurring revenue: mrr_band $800-$2,000/month (customer_archetypes.gd:33), midpoint $1,400. Over 180 days that is $8,400 of revenue for a one-time $400 — a 21× return on a single click, and the account then keeps paying and expands via the B2B expansion engine on top. Scale check against the played run: this card fired 16 times and was accepted 16 times, at a total cash cost of $6,400, while the run ended at MRR $32,495 across 25 customers (PROBE STATE day 275) — and the run's ending was profitable_bootstrap, i.e. the win came out of exactly this revenue. For a single fire at the first observed one, day 32: PROBE STATE day=32 cash=6470 mrr=425 cust=1 — one accepted referral offers $800-$2,000 of MRR against a company whose entire MRR is $425.
- **FREE LUNCH** — TWO of the three options are free lunches. Choice 2 "Pazarlık et — söz verme" spawns a full small prospect ($200-500/mo if closed) with ZERO cost — no cash, no reputation hit, no promise, nothing. Choice 3 "Reddet" pays +2 reputation for refusing. There is no branch of this card that can leave the player worse off than before it fired, on a card that fires every ~15 days forever. Worse, choice 2 is strictly DOMINANT AS PRESENTED: its chip ("Yeni aday") is byte-identical to choice 1's reward chip, and it lacks choice 1's "Nakit -$400" — so a player reading the chips sees the same prize for $400 less.
- **MAGNITUDE** — Out of band at the moment it first fires, and it fires early. First observed fire is day 32; PROBE STATE day=32 cash=6470 mrr=425 brand=50 cust=1 phase=1 (Bootstrap), runway 5.99 months. The $400 charge is 6.2% of the treasury — survivable. The PRIZE is the problem: a mid prospect banded $800-$2,000/month against a company whose entire monthly recurring revenue is $425. One accepted referral offers between 1.9× and 4.7× the company's whole revenue, on a Bootstrap-phase card with no phase gate, no MRR gate and no satisfaction gate (:12-25 has only three conditions). By the second fire (day 51: cash=5896 mrr=1425 cust=3) the same card is still offering the same mid prospect. It never scales to the company it is talking to.
- **NO OP** — TWO no-ops, one of them proven by the run log. (1) THE PROVEN ONE: PitchSystem.spawn_prospect returns null and registers nothing when every catalog company in the product's affinity sectors is taken (pitch_system.gd:74-75), and signed names are never freed (pitch_system.gd:44-47). The played run's product is saas_ops, whose SECTOR_AFFINITY is [construction, logistics, health, insurance, manufacturing] (b2b_constants.gd:236) — FIVE sectors × 5 companies each in CompanyCatalog = exactly 25 companies. The run ended with cust=25 and the highest-numbered account ever created was co_lead_164_61, signed on DAY 164; from day 165 to day 275 the customer count and MRR are frozen at 25 / $32,495 in every PROBE STATE line, while the probe kept calling find_prospects every 5 days. The referral card fired SEVEN more times after the pool dried up — days 169, 183, 197, 211, 226, 239, 252 — and choice 0 was picked every time, charging $400 each for a total of $2,800 in exchange for nothing at all, while still showing the chip "Yeni aday". The card became a pure money sink that still advertised a prize. (2) Choice 3 "Reddet" grants reputation +2, and in the ONLY market this card can fire in (market_type b2b, :13-16) no live consumer of reputation exists at a non-negative value: the B2C audience term that reads it (sales_system.gd:206) is inside _tick_b2c_audience, which only runs when market == "b2c" (sales_system.gd:160-162), and the VC reader (vc_pitch_system.gd:716) only branches on reputation < 0. The option moves a TopBar number and an ending-snapshot field and changes no system behaviour.
- **DEAD REFERENCE** **[corrected by the second reader]** — Checked every field, and this one is clean at the field level — which is worth recording explicitly because its sibling ev_ps_b2c_producthunt is not. Both authored keys on add_prospect are READ: "archetype" and "source" are both consumed by event_manager.gd:677, PitchSystem.spawn_prospect(String(m.get("archetype", "small")), String(m.get("source", "event"))) — this is in fact the ONLY reader of a modifier "source" key anywhere in the dispatcher. All three modifier types (add_prospect, cash, reputation) exist in _apply_modifiers. All three trigger condition types (market_type, customer_count_min, random) exist in is_condition_met. The reputation problem is a market-scoped inertness, not a missing referent, so it is filed under NO_OP.
- **COPY LIE** — The card's central promise is fiction. The label is "Kabul et — özellik sözü ver" / "Accept — promise the feature", the quoted email demands "Tek ricam, şu özelliği yol haritanıza almanız", and the closing narration states "ama yol haritana bir borç yazıyor" / "and a debt written onto your roadmap". NO SUCH DEBT IS CREATED. The choice's modifiers are exactly add_prospect and cash -400 (:36-46). The engine HAS the machinery — b2b_promise_create dispatches to B2BSalesSystem.accept_promise(customer_id, feature_id, deadline_days) at event_manager.gd:794-796, and the played run carries a live promises counter (PROBE STATE ... promises=4) fed by the B2B factory cards — and this card does not touch it. The player is told they have taken on an obligation with a deadline; they have taken on nothing, and the third option's label ("Reddet — yol haritan temiz kalsın" / "keep your roadmap clean") reinforces a distinction that does not exist, since all three roadmaps end up equally clean. Secondary lie, in the other direction: the copy never mentions money anywhere, yet choice 1 charges $400 — a modifier making a claim the fiction does not make. Third: the introduction the email offers is a MID prospect versus choice 2's SMALL one, a 4× difference in value that neither the copy nor the chip ever states.
- **VOICE** — The heaviest VOICE load in the family, because this is the card the player actually reads sixteen times. (1) REPETITION UNACKNOWLEDGED — the headline finding. Sixteen fires (days 32, 51, 67, 81, 95, 110, 128, 143, 155, 169, 183, 197, 211, 226, 239, 252), sixteen byte-identical emails. The sender is a permanently anonymous "müşterilerinden birinin genel müdürü", the friend at the dinner is an anonymous "başka bir şirketin sahibi", the feature is an anonymous "şu özellik", and the supplier dinner was always "geçen hafta". Nothing varies and nothing acknowledges that this has happened fifteen times before. The engine has every name it needs — CustomerRegistry holds the actual accounts (co_lead_31_4, co_lead_51_13 …), CompanyCatalog holds 65 named companies, and the B2B factory cards already name their account via the speaker_* fields (event_manager.gd:190-194) — and this card uses none of it. By the sixth telling the fiction is actively contradicting the player's own customer list. (2) DASHES: six em dashes in player-facing text — three in the body ("genel müdürü yazmış — sözleşmeye", "Ciddi ilgilendi — isterseniz tanıştırayım", "bir kapı — ama yol haritana") and one in each of the three labels (:35, :52, :65). (3) The clock is honest as a WINDOW but not as a moment: "E-posta · 13:05" sits inside allowed_hours [9,17] (:26-29), which satisfies the EVENT AUTHORING LAW, but the run fired this card at hours 9, 10, 11, 12, 13, 15, 16 and 17 while it claimed 13:05 every time — including twice at 17:00. (4) "sözleşmeye imzayı atan adamın kendisi" / "the man who signed the contract himself" hard-codes the signatory as male, on a card that fires 16+ times per run and never names anyone. CLEAN on: no UI node or tab is named; the quoted email is in-character and the scene-setting narration is kept outside the quotation marks; "yol haritası" is the correct TR for roadmap per the LANGUAGE INTEGRITY LAW.

<details><summary>Flags checked and not applicable (3)</summary>

- *IDENTICAL OPTIONS* **[corrected: was flagged, refuted]** — Choices 1 and 2 are identical AS PRESENTED. Both carry exactly one reward modifier of type add_prospect, and the chip builder renders add_prospect as the constant tr("EFFECT_NEW_PROSPECT") with no argument at all (event_modal.gd:535; CSV EFFECT_NEW_PROSPECT = TR "Yeni aday" / EN "A new prospect"). The archetype — the ONLY thing that differs, and it differs by 4× (mid mrr_band 800-2000 vs small 200-500, customer_archetypes.gd:22-37) — never reaches the chip. So the player choosing between them sees: [Yeni aday][Nakit -$400] versus [Yeni aday]. On the visible information, choice 2 strictly dominates and choice 1 is a trap. Only the prose hints otherwise, and it hints in the wrong direction (choice 1's label is about making a PROMISE, not about getting a bigger lead).
- *BLIND* — Objective test (event_modal.gd:567 terminal `return {}`): add_prospect resolves at event_modal.gd:535, cash at :489, reputation at :492. All four modifiers across the three choices produce chips; none falls through. The card is not blind by the objective test — its problem is that one of its chips is uninformative (IDENTICAL_OPTIONS) rather than absent.
- *INVISIBLE* **[corrected: was flagged, refuted]** — The $400 never surfaces as a SPEND anywhere. event_manager.gd:565 writes GameState.set_cash directly rather than routing through FinanceSystem.apply_one_time_cost (finance_system.gd:179-193), so record_transaction (finance_system.gd:283-287) appends no row to GameState.transactions, one_time_today gets no line for the gider dökümü, and GameState.accrue_month_expense (game_state.gd:498-500) never adds it to month_ledger["expense"]. In the played run that is $6,400 of spending that the Finance tab could not account for and that the calendar-month profitability ledger never saw — and the month ledger is what produces the "Artıda" verdict and the profit_streak the run's profitable_bootstrap ending was built on (PROBE MONTH day=274 n=9 income=32490 expense=7800 net=24690 — the referral spend is not in that 7800). The treasury moves; the reason is unrecorded.

</details>

**Notes.** All three choices are unconditionally unlocked (unlock_condition {} at :47, :60, :72 → is_condition_met returns true, event_manager.gd:371-372) and none carries a description field, so the chip column is the player's only quantitative information — which is what makes the identical "Yeni aday" chips load-bearing. "tags": ["build_safe"] (:3-5) lets it fire during a v2 build. THE SINGLE MOST IMPORTANT COMPOUND FINDING, since it needs all the pieces at once: this card is the only ambient card alive in a post-ship B2B run, it fires every ~15 days forever, two of its three options are free, its chips cannot distinguish its best option from its worst, its central narrative promise (the roadmap debt) is never created, its cash cost never reaches the Finance ledger, and after day 164 of the played run — when all 25 saas_ops companies had been signed — it kept firing seven more times and charging $400 apiece for a prospect that pitch_system.gd:74-75 had already stopped creating. Absolute paths for the four files audited: C:/Users/erdem/Desktop/project steam/project-unicorn/data/events/reactive/ev_ps_b2c_producthunt.json, ev_ps_bug_complaint.json, ev_ps_power_user_b2c.json, ev_ps_referral_b2b.json.

---

### ev_hr_resign_<emp.id>  (live shape: ev_hr_resign_char_emp_55_0 — employee ids are "char_emp_%d_%d" % [GameState.day, GameState.run_hires], hr_search_system.gd:200)

```
FILE          scripts/systems/hr_event_factory.gd — build_resignation(emp: Character), lines 29-42 (id built at :34, single choice at :41). Injected by scripts/systems/hr_morale_system.gd:498 (EventManager.enqueue).
CATEGORY      team
REACHABLE     ONLY under sustained neglect; it did NOT fire in the played run (grep 'ev_hr' over run_full_run_730.log returns 0 lines; PROBE TALLY carries no ev_hr_* row). Exact reason for the played run: days 1-54 there were zero employees (PROBE STATE emp=0 through day 54), so tick_thresholds (hr_morale_system.gd:127) iterated an empty roster; from day 55 there was exactly one employee (log: '[HRSearchSystem] hire: Baran Erdem (developer) $6300/mo'), hired at HRConstants.MORALE_HIRE_START = 75 (hr_search_system.gd:206, hr_constants.gd:760). Morale HAS NO DRIFT (hr_morale_system.gd:21-25) and the probe never started an overtime block (no PROBE PLAY overtime line; HROvertimeSystem.daily_tick returns at :87-88 every day because GameState.hr_overtime is empty), so that employee sat at 75 for 220 days. HRConstants.is_flight_risk(75) is false (threshold MORALE_FLIGHT_RISK = 25, hr_constants.gd:759/872), so emp.flight_risk_days never left 0 (tick_thresholds :136-139) and _maybe_resign was never called. WHAT A PLAYER MUST DO: (1) hire at least one employee; (2) drive that person under 25 morale — the only sinks are overtime nights (HRConstants.overtime_morale_drop: 2/day through block-day 3, 4/day through 7, 7/day from 8), the 1.6x OVERLOAD_MORALE_MULT, MORALE_FIRE_TEAM -5 to the survivors when somebody is fired, the 'Havayı bozar' peer trait and event morale modifiers. A single 14-day product_dev block delivers 3x2 + 4x4 + 7x7 = 71 raw points at Liderlik 0, and crosses under 25 on block-day 12 (cumulative 57 → 75-57 = 18); (3) then leave them under 25 for 10 consecutive days that are not leave days (the counter FREEZES on leave, :130-135); (4) survive the roll. Total ~22 days from starting a 14-day block, ~26 to the guaranteed edge.
FIRES         HRMoraleSystem.tick_thresholds (hr_morale_system.gd:124-145), run daily at the day boundary (hour 00) from HRSystem.daily_tick slot 6 (hr_system.gd:52), which TimeManager dispatches as daily slot 3 (time_manager.gd:311-315, after the hour-0 hourly tick and GameState.advance_day at :141-143). For every non-on-leave employee with morale < 25 it increments emp.flight_risk_days by 1 (:144) and calls _maybe_resign (:472-498): needs flight_risk_days >= HRConstants.RESIGN_WINDOW_MIN_DAYS (10, hr_constants.gd:946) and no existing _pending entry, then rolls HRConstants.resign_chance(traits, HROvertimeSystem.valve_continued_for(id)) = RESIGN_CHANCE_PER_DAY 0.25 x the trait resign_chance_mult (0.6 for one trait, 1.6 for another — hr_constants.gd:489/509) plus RESIGN_VALVE_PENALTY 0.15 if the player ever answered 'Devam et' on that person's valve card; the chance is FORCED to 1.0 once flight_risk_days >= RESIGN_WINDOW_MAX_DAYS (14, :487-493). On a successful roll the id is latched into _pending (:497) and the card is enqueued at :498.
FREQUENCY     Once per employee per run, in practice. The event object's one_shot=false / cooldown_days=0 / tags are INERT because EventManager.enqueue (event_manager.gd:200-214) bypasses _is_eligible entirely. The REAL latch is HRMoraleSystem._pending (hr_morale_system.gd:72), appended one line BEFORE the enqueue (:497) so a re-entrant path cannot double-fire, and cleared only by forget_employee (:423-430) — which runs from confirm_departure (:412, i.e. on resolve, immediately before CharacterRegistry.remove) and from HRActions.fire. Because resolving the card REMOVES the person, the latch can never re-arm for that id; the id is namespaced per character (:34) so two neglected employees each raise their own card. HRActions additionally refuses every card action on that person while the latch is set (hr_actions.gd:263-264, HR_ERR_LEAVING).
```

**TITLE (TR)** Ayrılık  ·  **TITLE (EN)** A departure
**SUBTITLE (TR)** (unset — the factory never assigns ev.subtitle; GameEvent.subtitle defaults to "" at scripts/data_models/event.gd:31)  ·  **(EN)** (unset — same; subtitle_en defaults to "" at scripts/data_models/event.gd:75)
**ALLOWED HOURS** NONE. allowed_hours is a JSON-loader-only field (event_manager.gd:913-919) stored outside GameEvent and read only inside _is_eligible (:497), which enqueue bypasses. This card fires at the day boundary, hour 00. No clock appears anywhere in the copy — correct.
**PRIORITY** 9 (hr_event_factory.gd:37) — INERT. _ordered_by_priority (event_manager.gd:120-133) is called only from daily_tick/hourly_tick over the JSON pool; _pump_queue (:855-868) pops the synthetic queue FIFO with pop_front and never looks at ev.priority.

**BODY (TR)**

> HRConstants.resign_voice(emp.id) → resign_voice_line(absi(emp.id.hash())) → HR_RESIGN_VOICE_{(hash mod 4)+1} (hr_constants.gd:1085-1104). One of exactly four, deterministic per person:
> HR_RESIGN_VOICE_1: "Bir süre düşündüm. Burada tükeniyorum, daha fazla taşımak istemiyorum."
> HR_RESIGN_VOICE_2: "Kimseyle sorunum yok. Sadece her sabah biraz daha zor kalkıyorum. O kadar."
> HR_RESIGN_VOICE_3: "Bana kötü davranıldı demeyeceğim. Ama fark edilmedim."
> HR_RESIGN_VOICE_4: "Başka bir yerden teklif geldi. Doğrusunu istersen, aramayı ben yaptım."

**BODY (EN)**

> HR_RESIGN_VOICE_1: "I have thought about it for a while. I am burning out here and I do not want to carry it any longer."
> HR_RESIGN_VOICE_2: "I have no problem with anyone. Every morning is just a little harder to get up. That is all."
> HR_RESIGN_VOICE_3: "I will not say I was treated badly. But I was not noticed."
> HR_RESIGN_VOICE_4: "An offer came from somewhere else. If you want the truth, I made the call."

**CHOICE 1** — `Anlaşıldı` / `Understood`

  *desc:* (none — EventChoice.description defaults to "", event_choice.gd:22) / (none)

  - **EFFECTS** `hr_departure` — {"type": "hr_departure", "character_id": emp.id}  (hr_event_factory.gd:41; emp.id is the live employee id, e.g. "char_emp_55_0")
    event_manager.gd:636-643 → HRMoraleSystem.confirm_departure(leaver_id) (hr_morale_system.gd:405-420) → forget_employee() clears the _pending latch and the hr_manual_leave_<id> flag → CharacterRegistry.remove(character_id), which increments GameState.run_departures by 1 and emits character_removed. NO money moves: HRConstants.SEVERANCE_ON_RESIGN == 0 (hr_constants.gd:950), and the seam charges nothing on purpose (hr_morale_system.gd:418-419). In the played run's terms this would have deleted a $6.300/mo salary — $210 of the $260/day burn — and the company's only non-founder developer.
  - **DURATION** permanent — the character record is destroyed; there is no undo and no re-hire of the same person.
  - **CHIP** TR: "Baran ayrılıyor"  ·  EN: "Baran is leaving". Built at event_modal.gd:543 as tr("EFFECT_DEPARTURE").format({"who": _char_name_or(character_id, tr("EFFECT_AN_EMPLOYEE"))}); _char_name_or (:576-584) returns the FIRST name while the record is still in the registry (it is — the removal only happens on resolve). If the id were already gone the fallback noun renders "Çalışan ayrılıyor" / "An employee is leaving". kind = negative.
  - **UNLOCK** NONE — EventChoice.unlock_condition is left at its default {} (event_choice.gd:24), so the row is always available.

**FLAGS** — PERMANENT SWING, DEAD REFERENCE

- **PERMANENT SWING** — One click permanently deletes an employee record (CharacterRegistry.remove, hr_morale_system.gd:420). In the played run the only hire cost $6.300/mo = $210 of a $260/day burn (PROBE STATE day=56 burn=260, log '[HRSearchSystem] hire: … $6300/mo'), so acknowledging would cut daily burn by 81% permanently — roughly $37.800 of payroll not spent over 180 days — while permanently deleting that person's build capacity, accumulated DENEYİM and role coverage. Both halves are irreversible.
- **DEAD REFERENCE** — Two fields are set and read by nothing on this path. ev.priority = 9 (:37) is only ever consulted by _ordered_by_priority (event_manager.gd:120-133) over the JSON pool; the synthetic queue is FIFO (_pump_queue :862). ev.tags = ["build_safe", "hr_departure"] (:36) are only read inside _is_eligible, which enqueue bypasses — the factory header (:10-14) admits this for build_safe but not for priority.

<details><summary>Flags checked and not applicable (9)</summary>

- *FREE LUNCH* — The single option is pure loss: it removes a salaried teammate and increments run_departures. There is no upside branch and no alternative to weigh it against.
- *REPEATABLE COMPOUND* — Not repeatable for a given person: resolving it removes the character, and the _pending latch (hr_morale_system.gd:72/497/429) can never re-arm for a dead id. Another employee can raise their own card under their own namespaced id, but nothing stacks.
- *NO OP* — The single modifier always lands: character_id is non-empty by construction (built from emp.id at :41), so the empty-id guard at event_manager.gd:640-642 cannot trip, and confirm_departure removes a record that is guaranteed present (the roll ran on a live roster entry this same tick).
- *IDENTICAL OPTIONS* — There is exactly one option (ev.choices has a single element, :41). Nothing to duplicate.
- *BLIND* — The irreversible effect carries a chip that names the leaver by first name (event_modal.gd:543). This is the one HR modifier whose chip builder explicitly refuses _char_first because its unknown-id fallback would read 'Moral ayrılıyor' (:541-542).
- *INVISIBLE* — The roster row disappears, character_removed repaints the HR tab and the left rail, GameState.run_departures feeds the run ledger and the ending screen, and payroll drops on the next FinanceSystem pull.
- *MAGNITUDE* — The card authors no number at all — the size of the loss is whatever the neglected employee's salary and capacity were. At the only point it could have fired in the played run (day 56+, PROBE STATE cash=28.955, mrr=3.125, burn=260/day, emp=1) that is one $6.300/mo developer, i.e. the entire non-founder payroll. That is the designed price of ignoring a red badge for 10-14 days, not an out-of-band number.
- *COPY LIE* — All four voice lines are the leaver's own words and assert nothing the engine denies: burnout, being unnoticed, and the daily grind are exactly what the trigger measures (morale < 25 for 10+ consecutive days). HR_RESIGN_VOICE_4 mentions an outside offer the game does not simulate as a system, but as first-person fiction it is a character's claim, not an engine promise.
- *VOICE* — One line, first person, dry, short. No dash, no time of day (correct for a card that fires at hour 00), no UI tab named, no scene-setting prose in the NPC's mouth. character_id is set (:39) so the modal renders the portrait plus 'İsim · Rol' plus trait chips around the quote — the person, not the room, speaks.

</details>

**Notes.** FAMILY-LEVEL FINDING (reported here once for all five cards, per instruction): the header at hr_event_factory.gd:20-22 reads 'Copy is WORKING TR (a voice pass comes with the content sprint). Turkish literals, no CSV keys — same convention as B2BEventFactory.' That is STALE and now false in both halves. Every string in the file goes through TranslationServer.translate of a CSV key (HR_EV_RESIGN_TITLE, HR_EV_RESIGN_ACK, HR_EV_VALVE_TITLE, HR_EV_VALVE_BODY, HR_EV_OVERTIME_STOP, HR_EV_VALVE_CONTINUE, HR_EV_CALM_TITLE/BODY/ACK, HR_EV_SIGNING_TITLE, HR_EV_SIGNED_BODY, HR_EV_SIGNING_ACK, HR_EV_SHIPPED_TITLE/BODY/ACK), the voice pools left the code for strings.csv too (hr_constants.gd:1081-1098 says so explicitly), and every one of those keys has a finished EN column. The 'same convention as B2BEventFactory' clause is also stale — b2b_event_factory.gd is on keys as well. A reader trusting this header would add a Turkish literal and break BILINGUAL BIRTH LAW. SECOND FAMILY NOTE: because the factory calls TranslationServer.translate at BUILD time, the resolved string is baked into ev.title/body_text at enqueue; the *_en sibling fields stay empty, which is the documented 'already localized' contract (event.gd:68-77, event_choice.gd:27-35), not a gap. THIRD: this card is a one-option notification, not a decision — by design (design doc §6: the played decision is upstream, the KAÇMA RİSKİ badge and all three card actions were live for the whole 10-14 day window).

---

### ev_hr_valve_<emp.id>  (live shape: ev_hr_valve_char_emp_55_0)

```
FILE          scripts/systems/hr_event_factory.gd — build_overtime_valve(emp: Character, dept_id: String), lines 47-63 (id at :49, two choices at :59-62). Injected by scripts/systems/hr_overtime_system.gd:373 (EventManager.enqueue), inside _maybe_enqueue_valve.
CATEGORY      team
REACHABLE     NOT in the played run, and only under a player-started overtime block. Why the played run never saw it: HROvertimeSystem.daily_tick returns immediately at :87-88 on every single day because GameState.hr_overtime is empty — the probe never called start() (no overtime line anywhere in run_full_run_730.log; the only PROBE PLAY verbs are hire, start_version_build, launch, bug_sprint, pitch, enter_development/beta). With no block there is no _charge_day and therefore no _maybe_enqueue_valve call at all. WHAT A PLAYER MUST DO: (1) hire at least one employee into a department — HROvertimeSystem.can_start requires a non-empty paid participant list (:145-155), so a solo founder cannot start one; (2) start a block from a department header, 3 / 7 / 14 days (HRConstants.OVERTIME_BLOCKS, hr_constants.gd:1023); (3) keep it running until that night's morale drop pushes someone under 25. From the hire baseline of 75 at Liderlik 0 that is block-day 12 of a 14-day block (cumulative 3x2+4x4+5x7 = 57 → 18). Someone already tired from an earlier block can trip it on night 1.
FIRES         HROvertimeSystem.daily_tick (hr_overtime_system.gd:79-94) → _tick_department (:97-107) → _charge_day (:119-140), run daily at the day boundary (hour 00) from HRSystem.daily_tick slot 4 (hr_system.gd:51), i.e. TimeManager daily slot 3. _charge_day advances the 1-based day index, applies HRConstants.overtime_morale_drop(idx) (2 through block-day 3, 4 through 7, 7 from 8 — hr_constants.gd:1035-1039) to every participant via HRMoraleSystem.apply_delta, and then calls _maybe_enqueue_valve (:351-373) for that person. The card fires only if HRConstants.is_flight_risk(emp.morale) is true AFTER tonight's drop (morale < 25, :367-368) and the id is not already in block["valve_fired"] (:369-371). Departments are walked in the fixed HRConstants.DEPARTMENTS order (product_dev, sales, customer) so the enqueue sequence is deterministic.
FREQUENCY     REPEATABLE — once per person per overtime block, unlimited blocks. one_shot / cooldown_days / build_safe on the object are INERT (enqueue bypasses _is_eligible; the factory header says so at :10-14). The real latch is the per-block array block[KEY_VALVE_FIRED] (hr_overtime_system.gd:45, appended at :372), which start() creates empty on every new block (:169) and _end_block erases with the whole record (:428). So stopping a block and starting a new one re-arms the card for everyone who is still under 25 — and the 'Devam et' memory it feeds is NOT re-armed, it persists for the rest of the run (:382-387).
```

**TITLE (TR)** Mesai sınırı  ·  **TITLE (EN)** Overtime limit
**SUBTITLE (TR)** (unset — GameEvent.subtitle default "", event.gd:31)  ·  **(EN)** (unset — GameEvent.subtitle_en default "", event.gd:75)
**ALLOWED HOURS** NONE — allowed_hours is a JSON-loader-only field (event_manager.gd:913-919) read only in _is_eligible (:497), which enqueue bypasses. Fires at the day boundary, hour 00. The copy DOES carry a clock: HR_VALVE_VOICE_2 says 'eve gece yarısı gidiyorum' / 'getting home at midnight'. See the VOICE flag.
**PRIORITY** 10 (hr_event_factory.gd:52, commented 'a person about to quit outranks routine beats') — INERT. Nothing sorts the synthetic queue: _pump_queue pops FIFO (event_manager.gd:862), and _ordered_by_priority only touches the JSON pool. The comment describes behaviour the engine does not implement.

**BODY (TR)**

> HR_EV_VALVE_BODY.format({"voice": HRConstants.valve_voice(emp.id), "dept": HRConstants.department_label(dept_id)}) →
> "{voice}
>
> **{dept}** bölümündeki ek mesai sürüyor. Devam edilirse bu riski bilerek alıyorsun."
> {voice} is one of three, picked deterministically by absi(emp.id.hash()) mod 3 (hr_constants.gd:1094-1108):
> HR_VALVE_VOICE_1: "Bu tempoyla devam edemem. Şimdi söylüyorum ki sonra sürpriz olmasın."
> HR_VALVE_VOICE_2: "Haftalardır eve gece yarısı gidiyorum. Bir yere kadar."
> HR_VALVE_VOICE_3: "Kimse sormadı diye iyi olduğum sanılmasın."
> {dept} is HR_DEPT_PRODUCT_DEV "Ürün Geliştirme" / HR_DEPT_SALES "Satış" / HR_DEPT_CUSTOMER "Müşteri" (hr_constants.gd:377-378).

**BODY (EN)**

> "{voice}
>
> Overtime in **{dept}** is still running. If it continues you are taking this risk knowingly."
> HR_VALVE_VOICE_1: "I cannot keep this pace. I am saying it now so it is not a surprise later."
> HR_VALVE_VOICE_2: "I have been getting home at midnight for weeks. There is a limit."
> HR_VALVE_VOICE_3: "Do not assume I am fine just because nobody asked."
> {dept}: "Product Development" / "Sales" / "Customer Success".

**CHOICE 1** — `Mesaiyi durdur` / `Stop the overtime`

  *desc:* (none) / (none)

  - **EFFECTS** `hr_overtime_stop` — {"type": "hr_overtime_stop", "department": dept_id}  (hr_event_factory.gd:60; dept_id is "product_dev" | "sales" | "customer")
    event_manager.gd:644-645 → HROvertimeSystem.stop(dept_id) (:180-200). If the block is not active it returns false and NOTHING happens. Otherwise: if today has not been billed yet (block["charged_day"] != GameState.day) it runs _charge_day with to_carry=true and fire_valve=false, so the day's overtime pay (HRConstants.overtime_daily_pay = monthly_salary/30 x OVERTIME_PAY_PCT 0.40) lands in tomorrow's Finance pull instead of being lost, and tonight's morale drop still lands; then _end_block(dept_id, true) erases GameState.hr_overtime[dept_id]. Consequences the chip does not spell out: HROvertimeSystem.speed_multiplier(dept) falls back to 1.0, dropping OVERTIME_SPEED_BONUS_EARLY 0.30 (or LATE 0.15 from block-day 8) off build speed (product_system.gd:599), autonomous sales (sales_rep_system.gd:95) or CS throughput (customer_rep_system.gd:71) depending on the department, and bug_multiplier 1.25 stops inflating the product bug rate (product_system.gd:836).
  - **DURATION** permanent for this block (the record is erased and the remaining block days are cancelled); a new block can be started freely afterwards.
  - **CHIP** TR: "Ek mesai durur"  ·  EN: "Overtime stops". event_modal.gd:544, tr("EFFECT_OVERTIME_STOP"), kind = neutral. It does NOT mention the lost speed multiplier or the day of pay still being charged.
  - **UNLOCK** NONE — unlock_condition left at {} (event_choice.gd:24).

**CHOICE 2** — `Devam et` / `Carry on`

  *desc:* (none) / (none)

  - **EFFECTS** `hr_overtime_continue` — {"type": "hr_overtime_continue", "department": dept_id, "character_id": emp.id}  (hr_event_factory.gd:61)
    event_manager.gd:646-650 → HROvertimeSystem.note_valve_continued(dept, character_id) (:376-394) → GameState.set_flag("hr_valve_continued_" + character_id, true). Nobody is removed from the block and no morale, cash or speed changes right now. The flag is RUN-LONG (not per block, :382-387) and is read by exactly one line in the codebase, hr_morale_system.gd:486, where HRConstants.resign_chance adds RESIGN_VALVE_PENALTY 0.15 to that person's daily resignation roll for the rest of the run: base 0.25 → 0.40 before the trait multiplier, a +60% relative increase. Across the four rolled days of the flight-risk window (days 10-13; day 14 is a forced certainty) that moves the cumulative odds from 1-0.75^4 = 68.4% to 1-0.60^4 = 87.0%.
  - **DURATION** permanent for the run — the flag is cleared only by GameState.initialize_run's flags.clear(); the block ending does not unsay it (hr_overtime_system.gd:382-387).
  - **CHIP** TR: "Mesai sürer · istifa riski artar"  ·  EN: "Overtime continues · the risk of resignations rises". event_modal.gd:545, tr("EFFECT_OVERTIME_CONTINUE"), kind = negative. It states the direction but never the number (0.15/day, run-long, that person only).
  - **UNLOCK** NONE — unlock_condition left at {}.

**FLAGS** — PERMANENT SWING, NO OP, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **PERMANENT SWING** — 'Devam et' writes hr_valve_continued_<id> = true, which is never cleared inside a run. That person's daily resignation chance rises 0.25 → 0.40 (+0.15, HRConstants.RESIGN_VALVE_PENALTY, hr_constants.gd:949/953-957) for however long the run lasts. Over 180 further days the practical effect is that any future 10-day flight-risk window kills them with 87.0% probability across the rolled days instead of 68.4%, and one click sets it.
- **NO OP** — Two concrete cases. (a) A second 'Devam et' for the same person changes nothing (boolean flag already true, hr_overtime_system.gd:391) while the chip still promises a rising risk. (b) THE STRUCTURAL ONE: the valve is fired from inside _charge_day (:135-137) and _tick_department auto-ends the block on the very same tick when day_index >= block length (:105-107). So a valve raised on the FINAL night hands the player a modal about a block that no longer exists — 'Mesaiyi durdur' then hits `if not is_active(dept_id): return false` (:192-193) and does literally nothing, chip notwithstanding. Reachable instance: a 3-day product_dev block started with the person at morale 29 and Liderlik 0 runs 29→27→25→23, and is_flight_risk (morale < 25) first trips on block-day 3, the last night.
- **INVISIBLE** — The 'Devam et' memory never surfaces again. A grep of scripts/ and scenes/ for valve_continued_for / hr_valve_continued_ / VALVE_FLAG_PREFIX returns only the constant (hr_overtime_system.gd:59), the writer (:391), the accessor (:397-403), its single consumer hr_morale_system.gd:486, and the flag-type table at game_state.gd:140. No UI reads it: no badge, no line on the employee card, no HR-tab column, no run-ledger entry. After the chip scrolls away the player has no way to learn which of their people are carrying a permanently raised resignation chance.
- **DEAD REFERENCE** — ev.priority = 10 (:52) is read by nothing on the enqueue path — _pump_queue is FIFO (event_manager.gd:862) — so the comment's claim that 'a person about to quit outranks routine beats' is unimplemented; a resignation card queued a moment earlier still opens first. ev.tags = ["build_safe", "hr_overtime"] (:51) are read only by _is_eligible, which enqueue bypasses.
- **COPY LIE** — Two. (a) The body asserts '**{dept}** bölümündeki ek mesai sürüyor' — 'overtime in X is still running'. In the final-night case described under NO_OP the block was erased by _end_block on the same tick that queued this card, and _end_block has already emitted the HR_NEWS_OVERTIME_DONE ticker headline (hr_overtime_system.gd:429-439): the modal insists the overtime continues while the news strip announces it finished. (b) HR_VALVE_VOICE_2 asserts 'Haftalardır eve gece yarısı gidiyorum' ('for weeks'), but the trigger is a single morale threshold with no duration term — someone who entered a block already at morale 26 raises this card after ONE overtime night (75-point baseline aside, is_flight_risk only tests morale < 25, :367).
- **VOICE** — Three things. (1) HR_VALVE_VOICE_2 puts a time of day ('gece yarısı' / 'midnight') in an NPC's mouth on a card that fires at hour 00 — the exact shape the EVENT AUTHORING LAW rules against ('Time-of-day fiction must match a real firing window — or omit the clock entirely'). (2) The same line asserts a stretch of weeks the trigger does not guarantee. (3) The body's second paragraph is founder-facing narration ('Devam edilirse bu riski bilerek alıyorsun') appended to the employee's quote inside a card whose character_id is set (:54), so the modal renders the room's sentence under that employee's portrait as if the employee said it. No dash anywhere; the chip's '·' is house punctuation, not a dash.

<details><summary>Flags checked and not applicable (5)</summary>

- *FREE LUNCH* — Both rows cost something. 'Mesaiyi durdur' surrenders the department's 0.30 speed multiplier and the rest of the block, and still bills today's overtime pay through the carry path (hr_overtime_system.gd:186-198). 'Devam et' buys nothing and adds a permanent risk penalty.
- *REPEATABLE COMPOUND* — The card is repeatable (once per person per block, and every new block re-arms the latch), but the effect does NOT stack: the payload is a boolean flag. A second 'Devam et' for the same person calls GameState.set_flag with true on a flag that is already true — same 0.15 penalty, not 0.30.
- *IDENTICAL OPTIONS* — The two rows call different seams (HROvertimeSystem.stop vs note_valve_continued) with different chips and opposite intent.
- *BLIND* — Both rows carry a chip (event_modal.gd:544-545), and the risky one even names its consequence in words ('istifa riski artar'). The stop row under-specifies (it never says the 0.30 speed bonus ends) but it is not blind.
- *MAGNITUDE* — The card authors no number of its own — the department label is its only interpolated value, and the sizes (0.15 penalty, 0.30 speed, 2/4/7 nightly morale) all live in HRConstants. In band for the scale at which it can first fire: the earliest point in the played run with an employee to work overtime is day 56, PROBE STATE cash=28.955, mrr=3.125, burn=260/day, emp=1.

</details>

**Notes.** See the family-level stale-header finding on ev_hr_resign (hr_event_factory.gd:20-22 claims Turkish literals and no CSV keys; this card is built entirely from HR_EV_VALVE_TITLE / HR_EV_VALVE_BODY / HR_VALVE_VOICE_1-3 / HR_EV_OVERTIME_STOP / HR_EV_VALVE_CONTINUE, all with finished EN columns). Design note worth keeping: this is the family's only genuine two-option decision, and its asymmetry is honest — the valve exists so that nobody is silently pulled off overtime (:352-354).

---

### ev_hr_calm_stretch

```
FILE          scripts/systems/hr_event_factory.gd — build_calm_stretch(days: int), lines 72-76, built through _positive() at :95-104. Injected by scripts/systems/hr_morale_system.gd:213 → _fire_positive (:521-526, EventManager.enqueue at :526).
CATEGORY      team
REACHABLE     YES in principle, but it did NOT fire in the played run and it needs the player to hurt the team first. Why it never fired: from day 56 the roster held exactly one employee at MORALE_HIRE_START 75 and morale HAS NO DRIFT (hr_morale_system.gd:21-25), so average_morale() returned 75.0 every day and the gate `average_morale() < HRConstants.CALM_STRETCH_MAX_MORALE` (70) at :212 failed on all 220 days. Every other clause was satisfied: the roster was non-empty (:196-198), the cooldown was open (hr_last_positive_event_day stayed 0, :516-517), and days_since_last_overtime() was GameState.day - 1 (no block ever ran, :320-326) so the 21-day clause passed from day 22 onward. WHAT A PLAYER MUST DO: spend at least 6 morale points and then be quiet for three weeks. At Liderlik 0 a single 3-day overtime block does exactly that (2+2+2 = 6 → 75 becomes 69), then 21 days with no overtime day stamped and the card fires. At Liderlik 10 the climate multiplier halves each drop to round(-2 x 0.5) = -1, so a 3-day block only reaches 72 and a 7-day block (3x1 + 4x2 = 11 → 64) is needed. The other morale sinks that open the gate are MORALE_FIRE_TEAM -5 to the survivors when somebody is fired, the 1.6x overload multiplier, the 'Havayı bozar' weekly peer nudge, and negative event morale modifiers.
FIRES         HRMoraleSystem.tick_positive_events (hr_morale_system.gd:190-213), daily at the day boundary (hour 00) from HRSystem.daily_tick slot 7 (hr_system.gd:54, TimeManager daily slot 3). Five conditions, all evaluated in this order: (1) CharacterRegistry.get_employees() must be non-empty (:196-198); (2) _positive_off_cooldown() — GameState.hr_last_positive_event_day <= 0, or GameState.day minus it >= HRConstants.POSITIVE_EVENT_COOLDOWN_DAYS 14 (:513-518); (3) days_since_last_ship() != 0, otherwise the ship glow takes the tick (:203-206); (4) _big_signing_today() == null, otherwise the signing takes it (:207-210); (5) days_since_last_overtime() >= HRConstants.CALM_STRETCH_DAYS 21 AND average_morale() < HRConstants.CALM_STRETCH_MAX_MORALE 70 (:211-213). days_since_last_overtime() is GameState.day - maxi(GameState.hr_last_overtime_day, 1), so with no block ever run it measures from day 1 (:320-326).
FREQUENCY     Repeatable, gated only by the SHARED positive-beat cooldown: GameState.hr_last_positive_event_day is stamped at ENQUEUE (never at resolve — hr_morale_system.gd:521-526), so an unread beat still blocks the next one, and all THREE positive cards share the one cursor (a ship glow blocks a calm stretch for 14 days and vice versa). ev.one_shot / cooldown_days / tags are INERT (enqueue bypasses _is_eligible). Beyond the cooldown, re-arming needs the average to fall back under 70 and 21 fresh overtime-free days — and since overtime is the main way to push the average down, the two clauses fight each other by construction.
```

**TITLE (TR)** Sakin bir dönem  ·  **TITLE (EN)** A calm stretch
**SUBTITLE (TR)** (unset — GameEvent.subtitle default "", event.gd:31)  ·  **(EN)** (unset — GameEvent.subtitle_en default "", event.gd:75)
**ALLOWED HOURS** NONE — JSON-loader-only field (event_manager.gd:913-919), read only in _is_eligible which enqueue bypasses. Fires at the day boundary, hour 00. The copy DOES carry a clock: 'akşam sekizde' / 'at eight in the evening'. See VOICE.
**PRIORITY** 4 (hr_event_factory.gd:100, commented 'below system beats; good news can wait its turn') — INERT. _pump_queue pops FIFO (event_manager.gd:862); a positive beat enqueued before a resignation still opens first.

**BODY (TR)**

> HR_EV_CALM_BODY.format({"n": days}) where days = the local `calm` = days_since_last_overtime() (hr_morale_system.gd:211-213):
> "Ekip {n} gündür ek mesai görmedi. Kimse akşam sekizde ekran başında değil, ve bu fark ediliyor."

**BODY (EN)**

> "The team has gone {n} days without overtime. Nobody is at a screen at eight in the evening, and it is noticed."

**CHOICE 1** — `İyi` / `Good`

  *desc:* (none) / (none)

  - **EFFECTS** `morale_all_employees` — {"type": "morale_all_employees", "delta": HRConstants.CALM_STRETCH_MORALE}  → delta = 5  (hr_event_factory.gd:75; constant at hr_constants.gd:1068)
    event_manager.gd:587-589 → for every employee returned by CharacterRegistry.get_employees() (category filter only — on-leave and in-training people are INCLUDED, character_registry.gd:54-62) HRMoraleSystem.apply_delta(emp, 5, "event"). apply_delta (:220-239) routes through scaled_delta (:242-278), which for a POSITIVE delta multiplies by HRConstants.climate_gain_mult(founder Liderlik) = clampf(1 + 0.05 x L, 1.0, 1.5): +5 at Liderlik 0, round(5.75) = +6 at Liderlik 3 (the onboarding cap), round(7.5) = +8 at Liderlik 10. CharacterRegistry.set_morale then clamps to 0..100 and emits morale_changed.
  - **DURATION** permanent — morale never decays (the ±1/day drift toward 50 was DELETED, not tuned to zero: hr_morale_system.gd:21-25). The points stay until an overtime block, a firing or a negative event spends them.
  - **CHIP** TR: "Ekip +5"  ·  EN: "Team +5". event_modal.gd:494, tr("EFFECT_TEAM").format({"v": _fmt_signed(5)}), kind = positive. Note the chip prints the NOMINAL 5 even when the founder's Liderlik makes the real write 6, 7 or 8.
  - **UNLOCK** NONE — unlock_condition left at {} (event_choice.gd:24).

**FLAGS** — PERMANENT SWING, FREE LUNCH, DEAD REFERENCE, COPY LIE, VOICE

- **PERMANENT SWING** — Morale has no drift, so the +5 is permanent state, and morale gates resignation risk (<25 starts the clock) and, through the HR Coupling wiring, department throughput. It is BOUNDED, though, and worth stating: the gate requires average < 70 and the reward is +5, so this beat alone can never push the team average past 75 — which is exactly MORALE_HIRE_START. Over 180 days its whole contribution is the difference between a <=69 team and a <=75 team.
- **FREE LUNCH** — The card's only option grants every employee +5 morale (up to +8 with Liderlik) for nothing at all: no cash, no time, no risk, no counter-effect, and no alternative row to weigh it against. It is a pure gift with an acknowledgement button — which is the design intent (the recovery channel exists because morale never self-heals, :191-195), but the shape is textbook free lunch.
- **DEAD REFERENCE** — ev.priority = 4 (hr_event_factory.gd:100) and ev.tags = ["build_safe", "hr_positive"] (:99) are read by nothing on the enqueue path (_pump_queue is FIFO; tags only matter inside the bypassed _is_eligible). Additionally the file's own section header (:66-70) and HRConstants (:1062-1066) still describe this card as a placeholder whose copy 'the content sprint replaces' — the content has since been written into strings.csv with a finished EN column, so both comments now point at a state that no longer exists.
- **COPY LIE** — Two. (a) 'Ekip {n} gündür ek mesai görmedi' counts from day 1 whenever no block has ever run, because days_since_last_overtime() returns GameState.day - maxi(GameState.hr_last_overtime_day, 1) (:320-326). A team whose first member was hired on day 200 is told, on day 260, that it has gone 259 days without overtime — a history longer than the team's existence. In the played run the value on the first legal day (56) would have been 55, against a team that was one day old. (b) The chip promises 'Ekip +5' while apply_delta actually writes round(5 x climate_gain_mult(Liderlik)) — +6 at Liderlik 3, +8 at Liderlik 10 (hr_constants.gd:904-906, hr_morale_system.gd:261). The chip is the player's only source of truth for the number and it is wrong whenever the founder has any Liderlik at all.
- **VOICE** — 'Kimse akşam sekizde ekran başında değil' puts a time of day in a beat that fires at hour 00 (HRSystem.daily_tick at the day boundary). It reads as idiomatic absence rather than a timestamp, but the EVENT AUTHORING LAW is written against exactly this shape — a clock must match a real firing window or be omitted. Everything else in the card is right: no dash, no UI tab named, and the factory deliberately leaves the speaker unset (:102-103) so the prose is the room's rather than an NPC's.

<details><summary>Flags checked and not applicable (6)</summary>

- *REPEATABLE COMPOUND* — Repeatable at best every 14 days, but self-limiting and therefore non-compounding: the average_morale() < 70 gate (:212) closes the moment the +5 lands on a team at 66-69, and the only way to reopen it is to spend morale again — mostly through overtime, which simultaneously resets the 21-day CALM_STRETCH_DAYS counter (GameState.hr_last_overtime_day is stamped on every block day, hr_overtime_system.gd:140). The reward can never stack past 75.
- *NO OP* — The write always lands: a +5 nominal delta cannot round to zero (climate_gain_mult is clamped to >= 1.0, hr_constants.gd:904-906), and the gate guarantees at least one employee below the 100 clamp.
- *IDENTICAL OPTIONS* — One option only.
- *BLIND* — The single option carries the 'Ekip +5' chip (event_modal.gd:494).
- *INVISIBLE* — Morale is shown on every employee card, drives the derived TÜKENİYOR / KAÇMA RİSKİ badges (HRMoraleSystem.badges_for, :283-301) and feeds the left-rail attention signal.
- *MAGNITUDE* — +5 on a 0-100 axis, against a 3-day overtime block that costs 6 — proportionate, and deliberately smaller than the +20 manual-vacation return (MORALE_VACATION_RETURN) that the player has to pay for. Context at the first day it could legally have fired in the played run (day 56, first employee): cash $28.955, MRR $3.125, burn $260/day, 1 employee. Note the CHIP is nonetheless off by up to 60% when Liderlik is high — see COPY_LIE.

</details>

**Notes.** See the family-level stale-header finding on ev_hr_resign. Design observation specific to this card: the gate is a catch-22 that the audit should surface — the ONLY recovery channel for a stat that never self-heals is locked behind average morale < 70, and the only ways to get under 70 are overtime (which resets the same card's 21-day clock), firing someone, overload, or a bad event. A player who never overworks anyone can never see the game's morale-recovery beat, which is the inverse of what a recovery channel is for.

---

### ev_hr_big_signing

```
FILE          scripts/systems/hr_event_factory.gd — build_big_signing(customer_name: String, mrr: int), lines 79-83, built through _positive() at :95-104. Injected by scripts/systems/hr_morale_system.gd:209 → _fire_positive (:521-526, enqueue at :526).
CATEGORY      team
REACHABLE     NO — structurally unreachable in normal play, and the run log proves it empirically. The trigger _big_signing_today() (hr_morale_system.gd:542-554) requires a Customer whose acquired_on_day == GameState.day, but acquired_on_day is stamped only at sales_system.gd:372 (add_b2b_customer, called by PitchSystem on SIGNED and by SalesRepSystem's autonomous close) and sales_system.gd:286 (the B2C aggregate record). Every one of those writers runs LATER than this reader: SalesRepSystem lives inside B2BSalesSystem.daily_tick (b2b_sales_system.gd:43) inside SalesSystem.daily_tick, which is TimeManager daily SLOT 4 (time_manager.gd:317-321), while tick_positive_events runs inside HRSystem.daily_tick at SLOT 3 (:311-315); a played pitch resolves at some hour of the day, after the whole synchronous dispatch has finished. So a customer signed on day D is first visible to this reader on day D+1, when acquired_on_day (D) != GameState.day (D+1), and the branch is dead. EMPIRICAL PROOF: the played run signed 25 accounts, six of them at or above HRConstants.BIG_SIGNING_MRR 1500 — day 52 +$1.700 (Marmara Klinik), day 85 +$2.000, day 110 +$1.700, day 112 +$1.700, day 116 +$1.700, day 131 +$2.000 — and five of those landed while an employee was on staff (emp=1 from day 55). Zero ev_hr_big_signing fires: PROBE TALLY has no ev_hr_* row. The day-85 log block shows the ordering directly: '[HRSystem] Daily tick — 1 employees' prints, then '[TimeManager] Daily tick — Day 85', and only then 'PROBE PLAY day=85 pitch Marmara İnşaat -> SIGNED'. A player could see this card only if a customer were minted between GameState.advance_day() and HR's slot-3 tick, which nothing does.
FIRES         HRMoraleSystem.tick_positive_events (hr_morale_system.gd:190-213), branch two (:207-210), daily at the day boundary (hour 00) from HRSystem.daily_tick slot 7 (hr_system.gd:54). Needs: a non-empty employee roster (:196-198); _positive_off_cooldown() (:513-518, 14 days); days_since_last_ship() != 0 so the ship glow does not take the tick first (:203-206); and _big_signing_today() != null — i.e. some Customer in CustomerRegistry.get_all() with acquired_on_day == GameState.day and mrr >= HRConstants.BIG_SIGNING_MRR 1500, largest MRR winning, ties by registry insertion order, and explicitly NO market_type filter (:542-546).
FREQUENCY     Would be repeatable per qualifying signing, gated only by the SHARED 14-day positive-beat cooldown stamped at enqueue (GameState.hr_last_positive_event_day, hr_morale_system.gd:521-526) — the same cursor the calm stretch and ship glow use. Unlike the calm stretch there is NO morale ceiling on this branch. ev.one_shot / cooldown_days / tags are INERT (enqueue bypasses _is_eligible). In practice the frequency is zero: see reachable.
```

**TITLE (TR)** Ofiste iyi haber  ·  **TITLE (EN)** Good news in the office
**SUBTITLE (TR)** (unset — GameEvent.subtitle default "", event.gd:31)  ·  **(EN)** (unset — GameEvent.subtitle_en default "", event.gd:75)
**ALLOWED HOURS** NONE — JSON-loader-only field (event_manager.gd:913-919) read only in the bypassed _is_eligible. Fires at the day boundary, hour 00. No clock anywhere in the copy — correct.
**PRIORITY** 4 (hr_event_factory.gd:100) — INERT; _pump_queue pops FIFO (event_manager.gd:862).

**BODY (TR)**

> HR_EV_SIGNED_BODY.format({"company": customer_name, "amount": HRConstants.money_tr(mrr)}), where customer_name = signing.company_name and mrr = signing.mrr (hr_morale_system.gd:209):
> "**{company}** imzaladı, aylık {amount}. Haber mutfağa varmadan herkes duymuş."
> {amount} renders through Fmt.money_exact (hr_constants.gd:1115-1116, fmt.gd:174-175) with the TR group separator: a $1.700 account prints "$1.700".

**BODY (EN)**

> "**{company}** signed, {amount} a month. Everyone heard before the news reached the kitchen."
> {amount} uses the EN group separator: "$1,700".

**CHOICE 1** — `Hak ettiler` / `They earned it`

  *desc:* (none) / (none)

  - **EFFECTS** `morale_all_employees` — {"type": "morale_all_employees", "delta": HRConstants.BIG_SIGNING_MORALE}  → delta = 4  (hr_event_factory.gd:82; constant at hr_constants.gd:1071)
    event_manager.gd:587-589 → for every employee from CharacterRegistry.get_employees() (on-leave and in-training included, character_registry.gd:54-62) HRMoraleSystem.apply_delta(emp, 4, "event") → scaled_delta multiplies by HRConstants.climate_gain_mult(Liderlik) = clampf(1 + 0.05 x L, 1.0, 1.5): +4 at Liderlik 0, round(4.6) = +5 at Liderlik 3, +6 at Liderlik 10. CharacterRegistry.set_morale clamps to 0..100 and emits morale_changed.
  - **DURATION** permanent — morale never decays (hr_morale_system.gd:21-25).
  - **CHIP** TR: "Ekip +4"  ·  EN: "Team +4". event_modal.gd:494, tr("EFFECT_TEAM").format({"v": _fmt_signed(4)}), kind = positive. Prints the nominal 4 regardless of the Liderlik multiplier actually applied.
  - **UNLOCK** NONE — unlock_condition left at {}.

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, DEAD REFERENCE, COPY LIE

- **REPEATABLE COMPOUND** — This branch has no morale ceiling — the only gate on repetition is the shared 14-day cooldown. A player closing one account at or above $1.500 MRR every fortnight would stack +4 (or +5/+6 with Liderlik) per fire until the 100 clamp: six fires over 84 days takes a 75-morale team to 99. It is the worst class by construction and is currently masked only by the trigger being unreachable — fix the ordering without adding a ceiling and the compound arrives with it.
- **PERMANENT SWING** — Morale never decays, so +4 (up to +6 with Liderlik) to every employee is permanent state that lowers resignation exposure and, through the Coupling wiring, raises throughput. Unlike the calm stretch it has NO ceiling clause, so its swing is bounded only by MORALE_MAX 100.
- **FREE LUNCH** — The card's only option is +4 morale to the entire roster with no cost, no risk and no alternative. (Shape only — the card cannot currently fire; see reachable.)
- **DEAD REFERENCE** — Beyond the inert priority 4 (:100) and tags (:99), the TRIGGER itself is a dead reference: it reads Customer.acquired_on_day expecting it to equal GameState.day, but every writer of that field (sales_system.gd:286 and :372) runs at daily slot 4 or later, or at an arbitrary hour, i.e. always after this slot-3 reader has run for that day. The field exists and is read — it just can never carry the value this condition needs. Empirically confirmed: six qualifying signings, five of them with an employee on staff, zero fires.
- **COPY LIE** — '**{company}** imzaladı' takes signing.company_name RAW. _big_signing_today applies no market filter and says so explicitly (:544-546, 'No market_type filter'), while the B2C aggregate record is created with company_name deliberately EMPTY — its name is a key plus an argument rendered by Customer.display_name(), and baking it froze one language into the save (sales_system.gd:275-279). A B2C userbase record over $1.500 MRR would therefore render '**** imzaladı, aylık $X.' — a bolded blank asserting that somebody signed. Latent today only because the trigger cannot fire at all.

<details><summary>Flags checked and not applicable (6)</summary>

- *NO OP* — A +4 nominal delta cannot round to zero (climate_gain_mult >= 1.0), so the write always lands whenever the card fires — unless every employee is already clamped at 100, which nothing prevents but which the design would treat as saturation rather than a no-op.
- *IDENTICAL OPTIONS* — One option only.
- *BLIND* — The single option carries the 'Ekip +4' chip (event_modal.gd:494).
- *INVISIBLE* — Morale is on every employee card and drives the derived badges (HRMoraleSystem.badges_for :283-301).
- *MAGNITUDE* — +4 on a 0-100 axis for an account worth >= $1.500/mo is in band — smaller than the ship glow's +6 and the calm stretch's +5, which is the right ordering. Player context on the days it would have fired in the played run: day 85 cash $24.800 / MRR $8.405 / burn $260/day / 1 employee; day 131 MRR $21.670. A $2.000 signing is 24% of the day-85 MRR, so the beat sits on a genuinely large event.
- *VOICE* — Short, concrete, physical ('Haber mutfağa varmadan herkes duymuş'). No dash, no time of day, no UI tab named, and the speaker is deliberately unset (:102-103) so the prose belongs to the room rather than to an NPC.

</details>

**Notes.** See the family-level stale-header finding on ev_hr_resign. Two things to fix together if this card is revived: the slot-ordering (either move the positive-event tick after Sales, or have _big_signing_today look one day back with a 'not yet announced' latch) AND the missing morale ceiling, or the fix ships a repeatable compound. Also route the name through Customer.display_name() rather than company_name.

---

### ev_hr_ship_glow

```
FILE          scripts/systems/hr_event_factory.gd — build_ship_glow(version: int), lines 86-90, built through _positive() at :95-104. Injected by scripts/systems/hr_morale_system.gd:205 → _fire_positive (:521-526, enqueue at :526).
CATEGORY      team
REACHABLE     NO — structurally unreachable in normal play, confirmed by the run log. The trigger needs days_since_last_ship() == 0 (hr_morale_system.gd:203), i.e. the newest {version, day} record in the mvp_version_history flag must carry TODAY's day (:329-336, :529-539). The ONLY writer of that flag is ProductSystem.ship_active_build (product_system.gd:1391-1393), which is reached only through the ship-moment modal's ship_active_build modifier (event_manager.gd:666-667) — a player click. The whole daily dispatch is one synchronous call (time_manager.gd:142-143 → _dispatch_daily_tick :249-268), HR is slot 3 and ProductSystem is slot 1, so the ship-moment modal is queued and mounted while the day's HR tick has ALREADY run; the click that stamps the history necessarily happens afterwards. The stamp therefore always carries a day HR has ticked past, and on the next tick days_since_last_ship() is >= 1. EMPIRICAL PROOF: the played run shipped on days 24, 63, 96 and 119 (PROBE FIRE ev_mvp_ship_moment / ev_mvp_version_ship_moment), three of them with an employee on staff, and fired the ship glow zero times (PROBE TALLY has no ev_hr_* row). The day-63 block shows the ordering literally: '[HRSystem] Daily tick — 1 employees' → '[TimeManager] Daily tick — Day 63' → 'PROBE PLAY day=63 launch' → 'PROBE PICK day=63 id=ev_mvp_version_ship_moment' → '[ProductSystem] Build shipped.' A player would have to resolve a ship modal in the same day BEFORE HR's slot-3 tick, which no code path allows.
FIRES         HRMoraleSystem.tick_positive_events (hr_morale_system.gd:190-213), branch one (:203-206) and therefore the highest-precedence positive beat, daily at the day boundary (hour 00) from HRSystem.daily_tick slot 7 (hr_system.gd:54). Needs a non-empty employee roster (:196-198), _positive_off_cooldown() (:513-518, 14 days), and days_since_last_ship() == 0 — GameState.day minus the day field of the newest mvp_version_history record. The version passed to the factory is int(ship.get("version", 1)) from _latest_ship() (:529-539).
FREQUENCY     Would be repeatable per shipped version, gated only by the SHARED 14-day positive-beat cooldown stamped at enqueue (GameState.hr_last_positive_event_day, :521-526) — the same cursor the calm stretch and big signing use, so any one of the three locks the other two for a fortnight. NO morale ceiling on this branch. ev.one_shot / cooldown_days / tags are INERT (enqueue bypasses _is_eligible). In practice the frequency is zero: see reachable.
```

**TITLE (TR)** Yayında  ·  **TITLE (EN)** Live
**SUBTITLE (TR)** (unset — GameEvent.subtitle default "", event.gd:31)  ·  **(EN)** (unset — GameEvent.subtitle_en default "", event.gd:75)
**ALLOWED HOURS** NONE — JSON-loader-only field (event_manager.gd:913-919) read only in the bypassed _is_eligible. Fires at the day boundary, hour 00. No clock anywhere in the copy — correct.
**PRIORITY** 4 (hr_event_factory.gd:100) — INERT; _pump_queue pops FIFO (event_manager.gd:862).

**BODY (TR)**

> HR_EV_SHIPPED_BODY.format({"version": version}), version = int(_latest_ship()["version"]) (hr_morale_system.gd:205):
> "Sürüm {version} çıktı ve tutuyor. Aylardır uğraşılan şeyin karşılığını görmek ekibi ayağa kaldırdı."

**BODY (EN)**

> "Version {version} is out and it is holding. Seeing months of work pay off put the team on its feet."

**CHOICE 1** — `Devam` / `Carry on`

  *desc:* (none) / (none)

  - **EFFECTS** `morale_all_employees` — {"type": "morale_all_employees", "delta": HRConstants.SHIP_GLOW_MORALE}  → delta = 6  (hr_event_factory.gd:89; constant at hr_constants.gd:1072)
    event_manager.gd:587-589 → for every employee from CharacterRegistry.get_employees() (on-leave and in-training included, character_registry.gd:54-62) HRMoraleSystem.apply_delta(emp, 6, "event") → scaled_delta multiplies by HRConstants.climate_gain_mult(Liderlik) = clampf(1 + 0.05 x L, 1.0, 1.5): +6 at Liderlik 0, round(6.9) = +7 at Liderlik 3, +9 at Liderlik 10. CharacterRegistry.set_morale clamps to 0..100 and emits morale_changed. This is the largest of the three positive beats — larger than a manual +5 calm stretch and a +4 signing, and just under a third of the +20 manual-vacation return.
  - **DURATION** permanent — morale never decays (hr_morale_system.gd:21-25).
  - **CHIP** TR: "Ekip +6"  ·  EN: "Team +6". event_modal.gd:494, tr("EFFECT_TEAM").format({"v": _fmt_signed(6)}), kind = positive. Prints the nominal 6 regardless of the Liderlik multiplier actually applied.
  - **UNLOCK** NONE — unlock_condition left at {}.

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, DEAD REFERENCE, COPY LIE

- **REPEATABLE COMPOUND** — No morale gate on this branch; the only limiter is the shared 14-day cooldown. A player shipping a version every fortnight stacks +6 per fire: four fires over 56 days takes a 75-morale team to 99, and version builds in the played run took 8 days (day 55 start → day 63 ship), so a 14-day shipping cadence is comfortably achievable. Worst class, currently masked only by the unreachable trigger — restoring the trigger without adding a ceiling ships the compound with it.
- **PERMANENT SWING** — Morale never decays, so +6 (up to +9 with Liderlik) per employee is permanent state that pushes the team away from the <25 resignation threshold and raises Coupling throughput. No ceiling clause on this branch — bounded only by MORALE_MAX 100.
- **FREE LUNCH** — The card's only option is +6 morale to the whole roster — the biggest single morale gift in the HR module outside the paid vacation — with no cost, no risk and no alternative row. (Shape only; the card cannot currently fire, see reachable.)
- **DEAD REFERENCE** — Beyond the inert priority 4 (:100) and tags (:99), the TRIGGER is a dead reference: days_since_last_ship() reads the mvp_version_history flag expecting a stamp carrying today's day, but the flag's only writer (product_system.gd:1391-1393, via the ship-moment modal's ship_active_build modifier at event_manager.gd:666-667) can only run after the day's slot-3 HR tick has already finished. The flag exists and is written; the condition it is asked to satisfy is unsatisfiable. Empirically: three ships with an employee on staff (days 63, 96, 119), zero fires.
- **COPY LIE** — Three. (a) 'Aylardır uğraşılan şeyin karşılığını' asserts months of work; the played run's v2 build ran from day 55 to day 63 — eight days — and the first MVP shipped on day 24 of a run that started on day 1. Nothing in the trigger measures build duration. (b) 've tutuyor' ('and it is holding') asserts market reception at the instant of shipping, before any satisfaction or churn data exists — ProductSystem.ship_active_build is explicitly narrative-only with no economic delta (product_system.gd:1373-1374). (c) The chip promises 'Ekip +6' while apply_delta writes round(6 x climate_gain_mult(Liderlik)) — +7 at Liderlik 3, +9 at Liderlik 10 (hr_constants.gd:904-906, hr_morale_system.gd:261).

<details><summary>Flags checked and not applicable (6)</summary>

- *NO OP* — A +6 nominal delta cannot round to zero (climate_gain_mult >= 1.0), so the write lands whenever the card fires, short of everyone already sitting at the 100 clamp.
- *IDENTICAL OPTIONS* — One option only.
- *BLIND* — The single option carries the 'Ekip +6' chip (event_modal.gd:494).
- *INVISIBLE* — Morale is on every employee card and drives the derived badges (HRMoraleSystem.badges_for :283-301).
- *MAGNITUDE* — +6 on a 0-100 axis is the family's largest free gift but still in band: a 3-day overtime block costs 6, so one ship exactly refunds one short crunch. Player context on the days it would have fired in the played run: day 63 cash $27.769 / MRR $3.550 / burn $260/day / 1 employee; day 96 MRR ~$9.400; day 119 MRR ~$12.700. The chip nonetheless under-reports by up to 50% when Liderlik is high — see COPY_LIE.
- *VOICE* — Short, physical, no dash, no time of day, no UI tab named, and the speaker is deliberately unset (:102-103) so the prose belongs to the room rather than to an NPC. The register is right; the factual overreach is logged under COPY_LIE, not here.

</details>

**Notes.** See the family-level stale-header finding on ev_hr_resign. If this branch is revived, note it sits FIRST in tick_positive_events (:203) and returns immediately, so a ship day silently consumes the tick that a big signing or a calm stretch would otherwise have used, and the shared cooldown stamp then blocks all three for 14 days — the three beats compete for one channel by design (:201-202).

---

### ev_mvp_dev_001_integration_broken

```
FILE          data/events/reactive/ev_mvp_dev_001_integration_broken.json (authored JSON pool event — no GDScript builder; loaded by EventManager._load_all_events_from_disk, event_manager.gd:866-889, one of the 15 files the run log reports as "[EventManager] Loaded 15 events")
CATEGORY      product (build-phase pool; fiction is founder-interior, mechanics are 100% ProductSystem)
REACHABLE     yes, in a normal run — PROBE FIRE day=14 hour=3 id=ev_mvp_dev_001_integration_broken src=pool, inside the v1 development band (enter_development day 8, enter_beta day 18). The probe answered choice 0.
FIRES         Ambient/hourly path only. Requires (a) an active build whose current_phase == "development" (event_manager.gd:411-415, reading ProductSystem.get_active_build()), and (b) an hourly random roll, evaluated ONLY at hours 01, 02, 03, 04 (allowed_hours [1,4]; cheap pre-filter event_manager.gd:106, re-gated against GameState.current_hour at event_manager.gd:501, window helper :523-533). The authored "chance": 0.30 is a per-DAY probability: because the window is 4 hours, each hourly roll actually uses hourly_chance(0.30, 4) = 1 − 0.7^(1/4) = 0.08531 → 8.531 % per hour (event_manager.gd:512 calling :537-541), which reproduces 30 % across a full development day. At most ONE ambient card enters the queue per calendar day across the entire pool (_ambient_fired_day, event_manager.gd:100 + :113). While any build is running, event_manager.gd:472-485 silences every event that is neither scoped to the current build_phase nor tagged "build_safe", so during a development band the only ambient competitors are ev_mvp_dev_002 (which additionally needs the debt flag) and ev_mvp_dev_003.
FREQUENCY     one-shot per run, and the latch is REAL for this card. It is a pool event, so it goes through _is_eligible, whose one_shot guard scans _history (event_manager.gd:486-490); _history is appended in resolve_choice (event_manager.gd:224). Note the JSON also carries "cooldown_days": 14 (guard at event_manager.gd:492-500) — dead weight, it can never bind beneath one_shot. Re-arms only on EventManager.reset() (event_manager.gd:325-333), i.e. a new run.
```

**TITLE (TR)** Bir şey çalışmıyor  ·  **TITLE (EN)** Something is not working
**SUBTITLE (TR)** Mutfak masası · 02:17  ·  **(EN)** Kitchen table · 02:17
**ALLOWED HOURS** [1, 4] — hours 01, 02, 03, 04 inclusive (4 hours, _window_length_hours = 4). The subtitle clock "02:17" sits INSIDE the window, and the header stamp is not a lie at render time: event_modal._live_subtitle (event_modal.gd:192-206) rewrites the HOUR from GameState.current_hour and keeps only the authored minutes, so the player sees "MUTFAK MASASI · 03:17" on a 03:00 fire. The BODY is not rewritten, and it hard-asserts the hour: "Saat ikiyi geçiyor." On 3 of the 4 eligible hours that sentence contradicts the header 40 px away. In the audited run the card fired at hour 03.
**PRIORITY** 0. All six of this family are priority 0, so _ordered_by_priority (event_manager.gd:120-137) puts them in one tie group and shuffles it through RngStreams.STREAM_EVENTS — when two are eligible in the same hour, the shuffle decides which one consumes the day's single ambient slot.

**BODY (TR)**

> Saat ikiyi geçiyor. Üçüncü kahve soğumuş. Sunucudan dönen veri ile arayüzün beklediği biçim tutmuyor — büyük bir fark değil, ama bir türlü kapanmıyor.
>
> İki yol var: yarın taze gözle bakmak, ya da geçici bir çözümle şimdi geçip sonra dönmek.
>
> *Sonra dönüp düzeltmek.* O sözü daha önce de duymuştun.

**BODY (EN)**

> It is gone two in the morning. The third coffee has gone cold. The data coming back from the server does not match the shape the interface expects — not a big difference, but it will not close.
>
> Two ways: look at it tomorrow with fresh eyes, or patch around it now and come back later.
>
> *Come back and fix it later.* You have heard that promise before.

**CHOICE 1** — `Gece boyu uğraş, doğru yap` / `Work through the night, do it properly`

  *desc:* ABSENT — the JSON carries no "description" field; the card renders label + chips only (event_modal.gd:395-400 skips the serif description line when the string is empty). / ABSENT

  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "stability", "amount": 6}
    EventManager._apply_modifiers (event_manager.gd:652-654) calls ProductSystem.apply_dimension_delta("stability", 6) → product_system.gd:1349-1362: active_build.stability = maxf(0.0, stability + 6.0), then _sync_legacy_quality. Flat add, floor 0, NO grow() ceiling. In the audited run the v1 shipped at stability 27.0 (PROBE SHIP day=24), so this single click is 22 % of the whole shipped stability axis. Removing it drops the composite from (9+27+10)/3 = 15.33 to 13.33 and the normalized market-quality band from q 38.0 to 34.8 (QualityModel.normalized_quality, NORMALIZE_HALF_SAT = 25.0, quality_model.gd:52+:99-102). PERMANENT: the axis is stamped into mvp_stability at ship (product_system.gd:1099-1101) and every later version build SEEDS from that flag (product_system.gd:1287-1296), so the +6 rides into v2, v3, v4 — the audited run's v4 stability 34.0 still contains it.
  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": 1}
    event_manager.gd:658-660 calls ProductSystem.apply_speed_bonus(1) → product_system.gd:1333-1341: b.total_efor = maxf(maxf(1.0, efor_spent), total_efor + 1.0 × team_speed(b)). POSITIVE = slower. Priced at the CURRENT phase's team speed (team_speed is phase-sensitive, product_system.gd:501-506 → _speed_for_phase :423-434, PHASE_AREAS "development" = ["engineering"]). The added effort is then spent 80/20 across the development and beta bands (caps at product_system.gd:586-590, PHASE_DEV_END = 0.80), so "+1 gün" is one day of ENGINEERING work redistributed, not a flat one-day calendar stop. Cost in the audited run: 1 extra day at burn $50/day = $50, 0.66 % of the day-14 cash of $7,550.
  - **DURATION** mixed — Kararlılık +6 is PERMANENT (ship snapshot + every later version seed); +1 gün is one-time.
  - **CHIP** Two chips, stacked right-aligned one per row (event_modal.gd:402-412 + _make_effect_chips :429-438):
TR: "Kararlılık +6" (positive) · "+1 gün" (negative)
EN: "Stability +6" (positive) · "+1 days" (negative)
Resolved through EFFECT_AXIS "{axis} {v}" with ProductCatalog.axis_label("stability") → PROD_AXIS_STABILITY = "Kararlılık"/"Stability" (event_modal.gd:508-516), and EFFECT_DAYS "{v} gün"/"{v} days" with _fmt_signed(1) = "+1" (event_modal.gd:520-522). The EN day chip is ungrammatical for a magnitude of one: it renders "+1 days".
  - **UNLOCK** NONE — "unlock_condition": {} and "unlock_reason_text": "". EventManager.is_condition_met returns true for an empty Dictionary (event_manager.gd:370-371), so the row is always live and its chips always render.

**CHOICE 2** — `Geçici çözüm — sonraya not et` / `Patch it — make a note for later`

  *desc:* ABSENT / ABSENT

  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": -2}
    ProductSystem.apply_speed_bonus(-2) (event_manager.gd:658 → product_system.gd:1333-1341): total_efor = maxf(maxf(1.0, efor_spent), total_efor − 2.0 × team_speed(b)). Two engineering-days of work removed from the build's remaining total, floored so it can never fall below what has already been spent. On the audited v1 (total_efor = 25, build ran days 2-24) that is roughly 9 % of the whole build.
  - **EFFECTS** `bug_delta` — {"type": "bug_delta", "amount": 2}
    ProductSystem.apply_bug_delta(2) (event_manager.gd:655-657 → product_system.gd:1364-1369): active_build.bug_count = max(0, bug_count + 2). Bugs are the live face of Stability — the economy reads effective_stability = stability − 0.8 × bug_count (quality_model.gd:67 BUG_STABILITY_COEF := 0.8), so +2 bugs is −1.6 effective stability until beta finds and fixes them.
  - **EFFECTS** `set_flag` — {"type": "set_flag", "key": "tech_debt_birikti", "value": true}
    event_manager.gd:590-595 calls GameState.set_flag("tech_debt_birikti", true) (game_state.gd:407-411). This is NOT bookkeeping: at the next enter_beta, ProductSystem._apply_tech_debt_due (product_system.gd:632-637, called from :751) adds TECH_DEBT_BUG_PENALTY = 5 bugs (product_system.gd:119) and then writes the flag back to false — leaving the KEY present. So the real bug cost of this row is 2 now + 5 at beta entry = 7 bugs, i.e. −5.6 effective stability, and the chip only announces 2. The flag is also the sole entry key for ev_mvp_dev_002 (event_manager.gd:388-389).
  - **DURATION** one-time, but two-stage: −2 gün and Hata +2 land immediately; the flag's 5 extra bugs are DEFERRED to the next enter_beta (product_system.gd:751).
  - **CHIP** Two chips only — the third modifier is silent:
TR: "-2 gün" (positive badge, because delay_days kind is inverted: dd<0 → positive) · "Hata +2" (negative)
EN: "-2 days" (positive) · "Bugs +2" (negative)
The set_flag modifier falls through _describe_modifier's terminal `return {}` (event_modal.gd:567) and renders NO CHIP. The player is shown a 2-bug price for a 7-bug decision.
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**FLAGS** — PERMANENT SWING, MAGNITUDE, BLIND, COPY LIE, VOICE

- **PERMANENT SWING** — Choice 0's dimension_delta stability +6 never decays. It is written into active_build.stability, stamped into the mvp_stability flag at ship (product_system.gd:1099-1101), and re-seeded as the base of every subsequent version build (product_system.gd:1287-1296) — the audited run's v4 (day 119, stability 34.0) still carries it. Magnitude: 22 % of the v1 shipped stability axis; removing it moves normalized market quality from 38.0 to 34.8, a −3.2 swing on the 0-100 band. 180-day projection in a B2C run: the audience accrual reads normalized quality every hour at HOURLY_AUD_QUALITY_COEF = 0.006 (sales_system.gd:62, :203-206), so +3.2 points ≈ +0.019 audience/hour ≈ +83 audience members over 180 days, against the HOURLY_AUD_BASE trickle of 0.08 × 4320 = 346 — roughly a 24 % permanent uplift on the base term, plus the compounding word-of-mouth term (sales_system.gd:213). In a B2B run the same axis feeds pitch odds and the customer satisfaction target instead.
- **MAGNITUDE** — Two numbers are out of band for the phase. (1) The +6 stability is 22 % of the entire shipped v1 stability axis (27.0, PROBE SHIP day=24) from one ambient card, at a point where the player's state is cash $7,550, MRR $0, brand 50, burn $50/day, runway 5.03 months (PROBE STATE day=14). (2) The hidden +5 bugs on choice 1 are 2.5× the disclosed +2 and, at 0.8 effective-stability each, cost −4.0 stability — 15 % of the axis — against a v1 that shipped with bug_count 1.
- **BLIND** — Choice 1's set_flag has no chip — _describe_modifier hits its terminal `return {}` at event_modal.gd:567. That flag is worth 5 bugs at the next enter_beta (product_system.gd:636, TECH_DEBT_BUG_PENALTY = 5), 2.5× the 2 bugs the visible chip promises, so the disclosed price understates the real one by 71 %. The body's only warning is the literary "*Sonra dönüp düzeltmek.* O sözü daha önce de duymuştun." — no number, no system name, and the penalty lands days later with nothing attributing it to this click (CLAUDE.md Calibration Law 3: the cause must be readable).
- **COPY LIE** — The body asserts a clock the engine contradicts: "Saat ikiyi geçiyor." The card's window is [1,4], and event_modal._live_subtitle (event_modal.gd:192-206) prints the LIVE hour in the same header — so on 3 of the 4 eligible hours the header says 01:17 / 03:17 / 04:17 while the prose says it is just past two. The audited run fired it at hour 03. Second claim: "Üçüncü kahve soğumuş" / the whole solo-at-the-kitchen-table framing is unconditional, but nothing in the trigger checks headcount (is_condition_met has no employee-count type at all, event_manager.gd:374-457), so it fires identically with a hired engineering team — the audited run had emp=1 from day 55 onward and this card is not gated against a version build.
- **VOICE** — Two hits. (1) The listed dash criterion: 1 em dash in the TR body, 1 in the EN body, 1 in the TR choice label "Geçici çözüm — sonraya not et" and 1 in its EN sibling. (2) The hard clock in the prose ("Saat ikiyi geçiyor") against a 4-hour window whose header is rewritten to the live hour. Otherwise the register is clean and in the house voice, and the language law is respected: no banned English ("arayüz", "sunucu" translated; no loanword outside the accepted set). No UI tab is named; no NPC speaks (character_id is "", the whole card is founder interior monologue).

<details><summary>Flags checked and not applicable (6)</summary>

- *FREE LUNCH* — Both rows are priced. Choice 0 pays +1 gün (one day of burn, $50 against $7,550 cash on day 14). Choice 1 pays Hata +2 now and, invisibly, 5 more at enter_beta. No option has upside with no cost.
- *REPEATABLE COMPOUND* — "one_shot": true and the guard is live for pool events (event_manager.gd:486-490 scanning _history). It can fire at most once per run — the run log's PROBE TALLY confirms fires=1. Nothing stacks.
- *NO OP* — Every modifier on both rows dispatches to a live arm (dimension_delta :652, delay_days :658, bug_delta :655, set_flag :590) and each changes state. The only theoretical inertness is the ProductSystem null-guard (product_system.gd:1336, 1355, 1366) if active_build vanished between enqueue and resolve; the build_phase gate makes that unreachable in normal play, since enqueue pumps the modal in the same hour (event_manager.gd:108-115).
- *IDENTICAL OPTIONS* — The two rows share no modifier: {stability +6, +1 day} vs {−2 days, bugs +2, debt flag}. They are genuine opposites. (Family note, not an in-event hit: this row-1 shape recurs almost verbatim as ev_mvp_dev_002 choice 1 {−1 day, bugs +2, flag} and ev_mvp_dev_003 choice 1 {−1 day, bugs +2}.)
- *INVISIBLE* — The flag IS read — product_system.gd:636 consumes it at enter_beta and converts it into bug_count, which the player sees on the build tracker and in the ship report card. It is blind at the point of decision, not invisible in outcome.
- *DEAD REFERENCE* — All four modifier types are live dispatcher arms (event_manager.gd:652, :658, :655, :590); both condition types are live (build_phase :411, random :385/:512). The flag key tech_debt_birikti is declared (game_state.gd:86) and read by two consumers (product_system.gd:636 and the ev_mvp_dev_002 gate).

</details>

**Notes.** Mechanically the strongest card in the family and the one carrying the family's single biggest defect: the two-bug chip on a seven-bug decision. The tech-debt channel is also the ONLY authored flag edge in the entire event corpus (this card writes it, ev_mvp_dev_002 reads it), so it is the only place event memory exists — and it is one-directional: pick choice 0 and ev_mvp_dev_002 is unreachable for the whole run, which is exactly what happened in the audited run. cooldown_days 14 is inert beneath one_shot true.

---

### ev_mvp_dev_002_tech_debt_callout

```
FILE          data/events/reactive/ev_mvp_dev_002_tech_debt_callout.json (authored JSON pool event — no GDScript builder)
CATEGORY      product (build-phase pool)
REACHABLE     only under a prior choice, and it did NOT fire in the audited run. It requires the key "tech_debt_birikti" to be PRESENT in GameState.flags, and the only shipped writer that creates it is ev_mvp_dev_001's choice 1 (ev_mvp_dev_001_integration_broken.json:55-59). The probe picked ev_mvp_dev_001 choice 0 on day 14 (PROBE PICK day=14 … choice=0 label=Gece boyu uğraş, doğru yap), so the key was never written and this id is absent from PROBE TALLY entirely. Even after the debt is taken, it still needs a later development-phase day (the ≤1-ambient-per-day throttle blocks the same day, since the two windows are [1,4] and [13,17]) with a 25 %/day roll. SECOND, PERMANENTLY-OPEN DOOR: product_system.gd:637 writes the flag back to false but LEAVES THE KEY, and the gate is flag_set = key PRESENCE, not truth (event_manager.gd:388-389) — so once any debt has ever been redeemed at a beta entry, this card's gate is satisfied for the rest of the run and it can fire on a much later version build with zero debt outstanding.
FIRES         Ambient/hourly path. Needs all three trigger conditions AND-ed (event_manager.gd:505-518): (1) an active build with current_phase == "development" (event_manager.gd:411-415); (2) flag_set on key "tech_debt_birikti" — GameState.has_flag, which tests KEY PRESENCE and is satisfied by a key explicitly holding false (event_manager.gd:388-389, game_state.gd:451-452); (3) a random roll at hours 13-17 only (allowed_hours [13,17], 5 hours). The authored chance 0.25 is per-DAY, so each hourly roll uses hourly_chance(0.25, 5) = 1 − 0.75^(1/5) = 0.055913 → 5.591 % per hour (event_manager.gd:512 + :537-541). ≤1 ambient card enters the queue per calendar day pool-wide (event_manager.gd:100 + :113).
FREQUENCY     one-shot per run, honored. Pool event → _is_eligible's one_shot guard (event_manager.gd:486-490) against _history (appended in resolve_choice, :224). "cooldown_days": 16 is dead weight beneath one_shot. Re-arms only on EventManager.reset() (:325-333).
```

**TITLE (TR)** Borç faturayı kesiyor  ·  **TITLE (EN)** The debt sends its invoice
**SUBTITLE (TR)** Geliştirici forumu · 14:33  ·  **(EN)** Developer forum · 14:33
**ALLOWED HOURS** [13, 17] — hours 13, 14, 15, 16, 17 inclusive (5 hours). The subtitle clock "14:33" sits INSIDE the window; _live_subtitle (event_modal.gd:192-206) rewrites the hour to the live clock and keeps the minutes, so a 16:00 fire reads "GELİŞTİRİCİ FORUMU · 16:33". The body carries no clock, so nothing in the prose can contradict it.
**PRIORITY** 0 — same tie group as the rest of the family, shuffled through RngStreams.STREAM_EVENTS (event_manager.gd:120-137).

**BODY (TR)**

> İlk hafta açtığın o kestirme — *'şimdilik böyle, sonra düzeltiriz'* — şimdi üç ayrı yerden bağırıyor. Her yeni şey eklemek zorlaşıyor.
>
> Durup düzeltmek = iki gün kayıp ama ileride pürüzsüz.
> Üstüne eklemek = bugünün hızı, yarının daha büyük faturası.
>
> *'Yarının ekibi yarının problemidir,'* diyen yazıyı bir yerlerde okumuştun. Şu an yarının ekibi de sensin.

**BODY (EN)**

> That shortcut you took in the first week — *'like this for now, we will fix it later'* — is shouting from three separate places. Adding anything new is getting harder.
>
> Stopping to fix it = two days lost, smooth going afterwards.
> Building on top = today's speed, a bigger invoice tomorrow.
>
> You once read a post that said *'tomorrow's team is tomorrow's problem.'* Right now you are also tomorrow's team.

**CHOICE 1** — `Dur, düzelt, sonra devam` / `Stop, fix it, then carry on`

  *desc:* ABSENT — the JSON carries no "description" field. / ABSENT

  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "stability", "amount": 6}
    event_manager.gd:652-654 → ProductSystem.apply_dimension_delta("stability", 6) → product_system.gd:1349-1362: active_build.stability = maxf(0.0, stability + 6.0). Flat add, floor 0, no ceiling. Against the audited run's v1 shipped stability of 27.0 that is 22 % of the whole axis; against v2's 31.0, 19 %. Permanent — stamped into mvp_stability at ship (product_system.gd:1099-1101) and re-seeded into every later version (product_system.gd:1287-1296).
  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": 2}
    event_manager.gd:658-660 → ProductSystem.apply_speed_bonus(2) → product_system.gd:1341: total_efor += 2.0 × team_speed(b), priced at DEVELOPMENT speed (PHASE_AREAS["development"] = ["engineering"], product_system.gd:293-297) and then spent 80 % in the development band, 20 % in beta (caps at product_system.gd:586-590). Cost in burn: 2 days × the day's burn — $50/day early (day 14-17 of the audited run) rising to $260/day once one engineer is hired (PROBE STATE day=56).
  - **EFFECTS** `set_flag` — {"type": "set_flag", "key": "tech_debt_birikti", "value": false}
    event_manager.gd:590-595 → GameState.set_flag("tech_debt_birikti", false). The value write is real: ProductSystem._apply_tech_debt_due reads get_flag("tech_debt_birikti", false) at enter_beta (product_system.gd:635, called from :751), so writing false cancels the pending TECH_DEBT_BUG_PENALTY = 5 bugs. Two consequences the player is never told: (a) this row is worth 5 bugs of AVOIDED damage — a real benefit with no chip; (b) writing false does NOT remove the key, so the flag_set gate that armed this very card stays permanently satisfied for the rest of the run (event_manager.gd:388-389, game_state.gd:411 + :451-452). In the late-fire case described under "reachable" — the flag already false when the card fires — this modifier is an outright no-op.
  - **DURATION** mixed — Kararlılık +6 PERMANENT (ship snapshot + every later version seed); +2 gün one-time; the debt clear is one-time and forward-looking (it cancels a penalty scheduled for the next enter_beta).
  - **CHIP** Two chips; the third modifier is silent:
TR: "Kararlılık +6" (positive) · "+2 gün" (negative)
EN: "Stability +6" (positive) · "+2 days" (negative)
The set_flag modifier falls through the terminal `return {}` (event_modal.gd:567) — the 5 bugs this row PREVENTS never appear on the card, so the player reads a pure cost (two days) for what is actually the cheaper path.
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**CHOICE 2** — `Üstüne eklemeye devam` / `Keep building on top`

  *desc:* ABSENT / ABSENT

  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": -1}
    ProductSystem.apply_speed_bonus(-1) (event_manager.gd:658 → product_system.gd:1341): total_efor = maxf(maxf(1.0, efor_spent), total_efor − 1.0 × team_speed(b)). One engineering-day of remaining work removed.
  - **EFFECTS** `bug_delta` — {"type": "bug_delta", "amount": 2}
    ProductSystem.apply_bug_delta(2) (event_manager.gd:655 → product_system.gd:1364-1369): bug_count = max(0, bug_count + 2). Worth −1.6 effective stability while they are open (BUG_STABILITY_COEF = 0.8, quality_model.gd:67).
  - **EFFECTS** `set_flag` — {"type": "set_flag", "key": "tech_debt_birikti", "value": true}
    GameState.set_flag("tech_debt_birikti", true) (event_manager.gd:590-595). Redeemed at the next enter_beta for +5 bugs (product_system.gd:636, TECH_DEBT_BUG_PENALTY = 5 at :119). Real bug price of this row: 2 now + 5 at beta = 7.
  - **DURATION** one-time, two-stage: −1 gün and Hata +2 immediately; 5 more bugs deferred to the next enter_beta.
  - **CHIP** Two chips; the flag is silent:
TR: "-1 gün" (positive badge — delay_days kind is inverted, dd<0 → positive) · "Hata +2" (negative)
EN: "-1 days" (positive) · "Bugs +2" (negative)
Note the EN string is ungrammatical at magnitude one ("-1 days"), because EFFECT_DAYS is "{v} days" with no plural handling.
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**FLAGS** — PERMANENT SWING, MAGNITUDE, BLIND, COPY LIE, VOICE

- **PERMANENT SWING** — Choice 0's dimension_delta stability +6 is permanent by the same chain as ev_mvp_dev_001: written to the build, stamped into mvp_stability at ship (product_system.gd:1099-1101), re-seeded into every later version (product_system.gd:1287-1296). Magnitude on the audited run's scale: 22 % of the v1 shipped stability axis (27.0), moving normalized quality by roughly +3.2 points of the 0-100 band. 180-day B2C projection: +3.2 normalized × HOURLY_AUD_QUALITY_COEF 0.006 (sales_system.gd:62, :203-206) = +0.019 audience/hour = +83 audience over 4,320 hours, against the 346 the HOURLY_AUD_BASE trickle produces in the same window — a permanent ~24 % uplift on the base term, before the compounding word-of-mouth factor at sales_system.gd:213.
- **MAGNITUDE** — The invisible half of each row is larger than the visible half. Choice 1's true bug price is 7 (2 shown + 5 hidden), 3.5× the chip; against a v1 that shipped with bug_count 1 (PROBE SHIP day=24) that is a seven-fold change in the product's open defect stock. The player's state on the days this can fire in a v1 development band (days 8-17 of the audited run): cash $7,850 down to $7,400, MRR $0, brand 50, burn $50/day, runway 5.23 → 4.93 months. The +6 stability on choice 0 is 22 % of the shipped axis.
- **BLIND** — BOTH rows carry a chipless set_flag (terminal `return {}`, event_modal.gd:567) and in both directions it is worth 5 bugs — TECH_DEBT_BUG_PENALTY at product_system.gd:119/:636. Choice 0 prevents 5 bugs and shows nothing; choice 1 incurs 5 bugs and shows nothing. The card therefore misprices its own core decision by 10 bugs of spread, and the body's numeric guidance ("Durup düzeltmek = iki gün kayıp") reinforces the wrong reading by naming only the visible cost.
- **COPY LIE** — Three assertions the engine cannot back. (1) "İlk hafta açtığın o kestirme" — the debt flag is written by ev_mvp_dev_001, which fires on ANY development-phase day; in the audited run's shape that is day 14 (week 3), and on a version build it can be day 90. Nothing stamps a week. (2) "şimdi üç ayrı yerden bağırıyor" — the engine models the debt as one boolean (game_state.gd:86); there are no three sites, and after any earlier redemption the boolean reads FALSE while this card still fires and still claims the debt is live. (3) "Durup düzeltmek = iki gün kayıp ama ileride pürüzsüz" promises a smooth road, but the axis effect is +6 stability, not a bug reduction — the 5 bugs it actually avoids are precisely what the copy does not name.
- **VOICE** — Three hits. (1) Dash criterion: 2 em dashes in the TR body, 2 in the EN body (labels are clean). (2) Machine-flavoured: the body uses spreadsheet syntax in an interior monologue — "Durup düzeltmek = iki gün kayıp" / "Üstüne eklemek = bugünün hızı", two consecutive lines built on "=". That is a decision table wearing prose. (3) The card pre-quantifies its own outcome in the fiction ("iki gün kayıp"), which duplicates the chip and edges toward telling the player which path is correct. Language law is otherwise respected: no banned English, no UI tab named, no NPC speaks (character_id "").

<details><summary>Flags checked and not applicable (7)</summary>

- *FREE LUNCH* — Choice 0 costs +2 gün of burn; choice 1 costs 2 bugs now and 5 at beta. Neither is upside without cost — though the framing is inverted: choice 0 is presented as the expensive one while, once the hidden 5 bugs are counted, it is the cheaper one.
- *REPEATABLE COMPOUND* — "one_shot": true, honored by _is_eligible (event_manager.gd:486-490). Once per run, maximum. The 25 % roll is re-tried per eligible hour but the card cannot recur after it resolves.
- *NO OP* — As a whole choice, no — both rows carry live modifiers. But choice 0's set_flag IS individually inert in the reachable late-fire case: after any earlier debt has been redeemed, product_system.gd:637 has already written the flag to false while leaving the key, the presence-gate re-arms the card, and "Dur, düzelt" then writes false over false while charging the player two days.
- *IDENTICAL OPTIONS* — The two rows share no modifier and point in opposite directions: {stability +6, +2 days, debt cleared} vs {−1 day, bugs +2, debt taken}. (Family note: choice 1 here is ev_mvp_dev_003 choice 1 {−1 day, bugs +2} plus the flag — a strict superset, and ev_mvp_dev_001 choice 1 differs only in the day count.)
- *INVISIBLE* — The flag has a live reader — product_system.gd:635-637 at enter_beta, plus this card's own gate at event_manager.gd:388-389. The effect surfaces as bug_count on the build tracker and in the ship report card. Blind at the decision, not invisible afterwards.
- *DEAD REFERENCE* — Every modifier type has a live dispatcher arm (dimension_delta :652, delay_days :658, bug_delta :655, set_flag :590) and every condition type a live is_condition_met arm (build_phase :411, flag_set :388, random :385/:512). The flag key is declared TYPE_BOOL at game_state.gd:86 and read at product_system.gd:635.
- *NO OP SECOND ORDER NOTE* — Placeholder not used — the eleven canonical flags above are the complete check for this event; this row is intentionally false and carries no finding.

</details>

**Notes.** The one card in the family that DID NOT FIRE in the audited run, and the only one whose reachability depends on a prior player choice. Two structural defects worth escalating: (a) the flag_set presence-vs-truth gate (event_manager.gd:388-389) combined with product_system.gd:637's write-false-but-keep-key means that after the first debt is ever redeemed, this card's arming condition is permanently true for the rest of the run, so it can fire on a version build with no debt and offer to "fix" nothing for two days; (b) both of its rows hide a 5-bug swing behind a chipless set_flag. cooldown_days 16 is inert beneath one_shot true. Note also that the eleventh row in the flags array of this entry is a deliberate no-finding placeholder — the eleven audited flags are FREE_LUNCH, PERMANENT_SWING, REPEATABLE_COMPOUND, NO_OP, IDENTICAL_OPTIONS, BLIND, INVISIBLE, MAGNITUDE, DEAD_REFERENCE, COPY_LIE, VOICE, all present above.

---

### ev_mvp_dev_003_solo_dev_fatigue

```
FILE          data/events/reactive/ev_mvp_dev_003_solo_dev_fatigue.json (authored JSON pool event — no GDScript builder)
CATEGORY      product (build-phase pool; the fiction is founder-condition but nothing in the effects touches the founder, morale or HR)
REACHABLE     yes, in a normal run — PROBE FIRE day=16 hour=7 id=ev_mvp_dev_003_solo_dev_fatigue src=pool, inside the v1 development band (days 8-17). The probe answered choice 0.
FIRES         Ambient/hourly path. Requires an active build with current_phase == "development" (event_manager.gd:411-415) and a random roll evaluated ONLY at hours 06, 07, 08, 09 (allowed_hours [6,9], 4 hours; pre-filter event_manager.gd:106, re-gate :501). The authored "chance": 0.20 is per-DAY, so each hourly roll uses hourly_chance(0.20, 4) = 1 − 0.8^(1/4) = 0.054258 → 5.426 % per hour (event_manager.gd:512 + :537-541), reproducing 20 % across a full development day. ≤1 ambient card enters the queue per calendar day pool-wide (event_manager.gd:100 + :113); in the audited run it won day 16's slot against ev_mvp_dev_001 (already spent) and ev_mvp_dev_002 (flag never set).
FREQUENCY     one-shot per run, honored — pool path, _is_eligible one_shot guard against _history (event_manager.gd:486-490, appended at :224). "cooldown_days": 20 is dead weight beneath it. Re-arms only on EventManager.reset() (:325-333).
```

**TITLE (TR)** Tek başına ağır  ·  **TITLE (EN)** Heavy on your own
**SUBTITLE (TR)** Yatak odası · 07:48  ·  **(EN)** Bedroom · 07:48
**ALLOWED HOURS** [6, 9] — hours 06, 07, 08, 09 inclusive (4 hours). The subtitle clock "07:48" sits INSIDE the window and the header hour is rewritten live by _live_subtitle (event_modal.gd:192-206), so the audited hour-07 fire rendered "YATAK ODASI · 07:48" correctly. The body's only time reference is retrospective ("Dün gece üçte yattın"), which no window can contradict — this is the family's cleanest clock handling.
**PRIORITY** 0 — same tie group as the family, shuffled through RngStreams.STREAM_EVENTS (event_manager.gd:120-137).

**BODY (TR)**

> Alarm çaldı, kalkmadın. On dakika sonra bir kez daha çaldı, hâlâ kalkmadın.
>
> Dün gece üçte yattın, gözlerin yanıyor. Bir kullanıcı geri bildirimi yok, son tarih yok — sadece sen ve laptop. **Yapmazsan kimse yapmayacak.** Yapsan da kimse görmeyecek.
>
> Bir gün dinlensen — runway eriyor ama belki yarın daha iyi düşünürsün. Ya da bugün kendini zorlasan — bir şey daha biter ama hata yapma ihtimalin artar.

**BODY (EN)**

> The alarm went off and you did not get up. Ten minutes later it went off again, and you still did not get up.
>
> You went to bed at three, your eyes are burning. No user feedback, no deadline — just you and the laptop. **If you do not do it, nobody will.** And if you do, nobody will see it.
>
> Take a day off — the runway melts, but maybe tomorrow you think more clearly. Or push through today — one more thing gets finished, and your odds of making a mistake go up.

**CHOICE 1** — `Bugün kendine ver, yarın taze başla` / `Give yourself today, start fresh tomorrow`

  *desc:* ABSENT — the JSON carries no "description" field. / ABSENT

  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": 1}
    event_manager.gd:658-660 → ProductSystem.apply_speed_bonus(1) → product_system.gd:1333-1341: total_efor = maxf(maxf(1.0, efor_spent), total_efor + 1.0 × team_speed(b)), priced at development (engineering) speed and then spent 80 % in the development band and 20 % in beta (product_system.gd:586-590). Cost in the audited run: one extra day at burn $50/day = $50, 0.67 % of the day-16 cash of $7,450.
  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "stability", "amount": 2}
    event_manager.gd:652-654 → ProductSystem.apply_dimension_delta("stability", 2) → product_system.gd:1349-1362: active_build.stability = maxf(0.0, stability + 2.0). Against the audited v1's shipped stability of 27.0 that is 7.4 % of the axis. Permanent by the ship-snapshot + version-seed chain (product_system.gd:1099-1101, :1287-1296).
  - **DURATION** mixed — Kararlılık +2 PERMANENT (ship snapshot + every later version seed); +1 gün one-time.
  - **CHIP** Two chips, in modifier order:
TR: "+1 gün" (negative) · "Kararlılık +2" (positive)
EN: "+1 days" (negative) · "Stability +2" (positive)
EFFECT_DAYS is "{v} gün"/"{v} days" (event_modal.gd:520-522) and EFFECT_AXIS is "{axis} {v}" with PROD_AXIS_STABILITY (event_modal.gd:508-516). The EN chip reads "+1 days" — no plural handling in the CSV string.
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**CHOICE 2** — `Zorla, kahve yap, masaya otur` / `Push through, make coffee, sit down`

  *desc:* ABSENT / ABSENT

  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": -1}
    ProductSystem.apply_speed_bonus(-1) (event_manager.gd:658 → product_system.gd:1341): total_efor = maxf(maxf(1.0, efor_spent), total_efor − 1.0 × team_speed(b)) — one engineering-day of remaining work removed, floored so it can never fall below the effort already spent.
  - **EFFECTS** `bug_delta` — {"type": "bug_delta", "amount": 2}
    ProductSystem.apply_bug_delta(2) (event_manager.gd:655-657 → product_system.gd:1364-1369): active_build.bug_count = max(0, bug_count + 2). Costs −1.6 effective stability while open (BUG_STABILITY_COEF 0.8, quality_model.gd:67). Against a v1 that shipped with bug_count 1, two bugs is a doubling-and-more of the launch defect stock if they survive beta.
  - **DURATION** one-time — both modifiers land immediately; the bugs persist until beta or a bug sprint clears them.
  - **CHIP** Two chips:
TR: "-1 gün" (positive badge — delay_days kind is inverted, dd<0 → positive) · "Hata +2" (negative)
EN: "-1 days" (positive) · "Bugs +2" (negative)
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**FLAGS** — PERMANENT SWING, COPY LIE, VOICE

- **PERMANENT SWING** — Choice 0's dimension_delta stability +2 never decays: it enters active_build.stability, is stamped into mvp_stability at ship (product_system.gd:1099-1101), and re-seeds every later version build (product_system.gd:1287-1296). Magnitude is the family's smallest — 7.4 % of the audited v1 shipped stability axis (27.0), moving the composite from 15.33 to 16.00 and normalized market quality from 38.0 to 39.0, about +1.0 on the 0-100 band. 180-day B2C projection: +1.0 normalized × HOURLY_AUD_QUALITY_COEF 0.006 (sales_system.gd:62) = +0.006 audience/hour = +26 audience over 4,320 hours, against the 346 from the HOURLY_AUD_BASE trickle — a permanent ~7.5 % uplift on the base term. Still permanent, but it is the one dimension_delta in the family that is genuinely in band.
- **COPY LIE** — The body asserts a state the engine can contradict outright, and does in the audited run's later shape. "Bir kullanıcı geri bildirimi yok, son tarih yok — sadece sen ve laptop" and "Yapmazsan kimse yapmayacak": the card is gated only on build_phase == development, which is equally true of every VERSION build. In the audited run the v3 version build was started on day 88 specifically to satisfy a customer promise carrying a hard deadline (run log: "start_version_build feature=saas_ops_workflow (promise promise_co_lead_81_27_saas_ops_workflow_88 deadline=102)") while the company had 11 customers, 2 open promises and 1 employee (PROBE STATE day=88). There is no employee-count and no promise-count condition type anywhere in is_condition_met (event_manager.gd:374-457), so the card cannot be gated against that state. Second claim: the fiction is entirely about the founder's exhaustion, and NOT ONE modifier touches morale, the founder, or HR — there is no morale modifier and no character_id (""), so "kendine ver" and "kendini zorla" resolve purely as product numbers.
- **VOICE** — Two hits. (1) Dash criterion: 3 em dashes in the TR body, 3 in the EN body (the family's highest count); labels are clean. (2) The solo framing ("Tek başına ağır", "sadece sen ve laptop") is written as unconditional truth but the card fires unchanged with a hired team. Otherwise the register is strong and the language law is respected: "runway" and "laptop" are both on the ruled accepted loanword list, "son tarih" and "geri bildirim" are correctly translated rather than left as deadline/feedback, no UI tab is named, and no NPC is made to deliver scene-setting (character_id is "", the whole card is founder interior).

<details><summary>Flags checked and not applicable (8)</summary>

- *FREE LUNCH* — Choice 0 pays a day of burn ($50 on day 16); choice 1 pays two bugs. Both are priced, and unusually for this family both prices are fully chipped — this is the only card in the six whose entire cost surface is visible.
- *REPEATABLE COMPOUND* — "one_shot": true, honored by _is_eligible (event_manager.gd:486-490); PROBE TALLY confirms fires=1. Nothing stacks.
- *NO OP* — All four modifiers dispatch to live arms (delay_days :658, dimension_delta :652, bug_delta :655) and each mutates the active build. No empty-modifier row and no silently-dropped type.
- *IDENTICAL OPTIONS* — The two rows are opposites: {+1 day, stability +2} vs {−1 day, bugs +2}. (Family note: choice 1 is modifier-for-modifier identical to the non-flag part of ev_mvp_dev_002 choice 1, and one day away from ev_mvp_dev_001 choice 1 — three cards in the family offer effectively the same shortcut.)
- *BLIND* — Every modifier on both rows has a chip builder (delay_days event_modal.gd:520-522, dimension_delta :508-516, bug_delta :517-519). Nothing falls through the terminal `return {}` at :567. This is the only card in the family with a fully-disclosed effect surface.
- *INVISIBLE* — No set_flag, no mentor_advisory, no bookkeeping modifier. Both effects land on gauges the player watches: the build tracker's day estimate (ProductSystem.estimated_days_remaining, product_system.gd:513-518) and the bug count.
- *MAGNITUDE* — This is the family's in-band card. +2 stability is 7.4 % of the v1 shipped axis (27.0) and moves normalized quality by ~1.0 point; ±1 day at the day-16 state (cash $7,450, MRR $0, brand 50, burn $50/day, runway 4.97 months — PROBE STATE day=16) is $50, 0.67 % of cash and about 4.5 % of the 22-day v1 build. +2 bugs is the one number worth watching: against a v1 that shipped at bug_count 1 it is a large relative move, but beta finds and fixes (product_system.gd:629 _tick_beta_hourly) and the audited run cleared it, so it is a temporary stock, not a permanent one.
- *DEAD REFERENCE* — All modifier types are live dispatcher arms; both condition types (build_phase :411, random :385/:512) are live. No flag is written, so there is nothing that could go unread.

</details>

**Notes.** Mechanically the cleanest and best-calibrated card of the six: nothing hidden, no permanent swing out of band, symmetric costs. Its defect is purely narrative reach — a card written for a solo pre-launch founder that the trigger vocabulary cannot keep away from a staffed, customer-bearing version build. Fixing it needs a condition type that does not exist yet (headcount or open-promise count); flag that as a gap rather than reworking the copy. cooldown_days 20 is inert beneath one_shot true.

---

### ev_mvp_iter_001_scope_creep

```
FILE          data/events/reactive/ev_mvp_iter_001_scope_creep.json (authored JSON pool event — no GDScript builder)
CATEGORY      product (build-phase pool, iteration/design band)
REACHABLE     yes, in a normal run — PROBE FIRE day=55 hour=22 id=ev_mvp_iter_001_scope_creep src=pool, on the first day of the v2 version build's iteration band ("v2 build started: 4 features (union), total_efor=8" on day 55; enter_development day 58). The probe answered choice 0.
FIRES         Ambient/hourly path. Requires an active build with current_phase == "iteration" (event_manager.gd:411-415) and a random roll evaluated ONLY at hours 22, 23, 00, 01, 02 — allowed_hours [22,2] wraps midnight and _is_hour_in_window handles the wrap (event_manager.gd:523-533), _window_length_hours returning (24−22)+2+1 = 5 (event_manager.gd:544-552). The authored "chance": 0.35 is per-DAY, so each hourly roll uses hourly_chance(0.35, 5) = 1 − 0.65^(1/5) = 0.082549 → 8.255 % per hour (event_manager.gd:512 + :537-541), the family's highest per-day rate. ≤1 ambient card enters the queue per calendar day pool-wide (event_manager.gd:100 + :113); note the day-boundary correction at event_manager.gd:98 (slot_day = GameState.day + 1 when hour == 0), which matters for this card specifically because its window straddles midnight.
FREQUENCY     one-shot per run, honored — pool path, _is_eligible one_shot guard against _history (event_manager.gd:486-490, appended at :224). "cooldown_days": 12 is dead weight beneath it. Re-arms only on EventManager.reset() (:325-333).
```

**TITLE (TR)** Bu özellik beklediğimden derinmiş  ·  **TITLE (EN)** This feature runs deeper than I thought
**SUBTITLE (TR)** Mutfak masası · 23:14  ·  **(EN)** Kitchen table · 23:14
**ALLOWED HOURS** [22, 2] — hours 22, 23, 00, 01, 02 inclusive (5 hours, wrapping). The subtitle clock "23:14" sits INSIDE the window; _live_subtitle (event_modal.gd:192-206) rewrites the hour from GameState.current_hour, so the audited hour-22 fire rendered "MUTFAK MASASI · 22:14". The body's time references are relative ("Bir saat önce"), so no prose clock can contradict the window.
**PRIORITY** 0 — same tie group, shuffled through RngStreams.STREAM_EVENTS (event_manager.gd:120-137). During an iteration band its only ambient competitors are ev_mvp_iter_002 and ev_mvp_iter_003, since the build-phase gate (event_manager.gd:472-485) silences everything not scoped to "iteration" or tagged build_safe.

**BODY (TR)**

> Bir saat önce *'bir tarama daha,'* dedin. Şimdi üç sekme açık, hiçbirinde planladığın şey yok.
>
> Özelliği düşünürken küçüktü. Yazmaya başlayınca bir köşesinden başka bir şey çıktı. Şimdi seçim şu: ya bunu **doğru** yap — birkaç gün daha. Ya da **kırp**, görünürde çalışıyor, derinleşmesi sonraya kalır.
>
> Kimsenin bilmediği bir şey hakkında karar veriyorsun. Bu da onun bir parçası.

**BODY (EN)**

> An hour ago you said *'one more pass.'* Now three tabs are open and not one of them holds what you planned.
>
> The feature was small while you were thinking about it. Once you started writing, something else came out of one corner of it. Now the choice is: build it **properly** — a few more days. Or **trim it**, it works on the surface, the depth waits.
>
> You are deciding about something nobody knows exists. That is part of it too.

**CHOICE 1** — `Düzgün yap — birkaç gün daha gerek` / `Do it properly — it needs a few more days`

  *desc:* ABSENT — the JSON carries no "description" field. / ABSENT

  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "experience", "amount": 6}
    event_manager.gd:652-654 → ProductSystem.apply_dimension_delta("experience", 6) → product_system.gd:1349-1362: active_build.experience = maxf(0.0, experience + 6.0). MEASURED in the audited run: the v2 build was seeded at experience 16 ("v2 build started … seeded I12/S27/E16", day 55) and shipped at experience 22.0 (PROBE SHIP day=63) — the entire v2 experience gain over the shipped v1 came from this one click plus the paid feature, and the click alone is 27 % of the shipped axis. Composite moves from (12+31+16)/3 = 19.67 to (12+31+22)/3 = 21.67, normalized quality from 44.0 to 46.4 (QualityModel, NORMALIZE_HALF_SAT 25.0). PERMANENT: stamped into mvp_experience at ship (product_system.gd:1099-1101) and re-seeded into v3 and v4 — the day-119 v4 experience of 36.0 still contains it.
  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": 2}
    event_manager.gd:658-660 → ProductSystem.apply_speed_bonus(2) → product_system.gd:1341: total_efor = maxf(maxf(1.0, efor_spent), total_efor + 2.0 × team_speed(b)). Two facts the chip does not carry. (a) The days are PRICED at ITERATION speed — PHASE_AREAS["iteration"] = ["product", "design"] (product_system.gd:293-297), _speed_for_phase at :423-434 — and then SPENT 20 % in the design band, 60 % in development (engineering) and 20 % in beta (caps at product_system.gd:586-590, PHASE_DESIGN_END 0.20 / PHASE_DEV_END 0.80), so the promised day count is the calendar slip only if design and engineering speeds happen to match. (b) During an iteration ROUND HOLD effort accrual is frozen entirely (in_iter_hold, product_system.gd:580-581 + :594) because rounds are ITER_ROUND_DAYS = 4 calendar days and speed-independent (product_system.gd:70, :701-706) — so a "+2 gün" taken during a hold does not slip the phase it fires in at all; the whole cost defers to development and beta. On the audited v2 (total_efor 8) two iteration-days of effort is a 25-50 % increase in the build's entire remaining work.
  - **DURATION** mixed — Deneyim +6 PERMANENT (ship snapshot + every later version seed); +2 gün one-time and deferred (see above).
  - **CHIP** Two chips:
TR: "Deneyim +6" (positive) · "+2 gün" (negative)
EN: "Experience +6" (positive) · "+2 days" (negative)
EFFECT_AXIS "{axis} {v}" with ProductCatalog.axis_label("experience") → PROD_AXIS_EXPERIENCE = "Deneyim"/"Experience" (event_modal.gd:508-516); EFFECT_DAYS "{v} gün"/"{v} days" (event_modal.gd:520-522).
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**CHOICE 2** — `Kırp, yüzeyi koru, devam et` / `Trim it, keep the surface, move on`

  *desc:* ABSENT / ABSENT

  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": -1}
    ProductSystem.apply_speed_bonus(-1) (event_manager.gd:658 → product_system.gd:1341): total_efor = maxf(maxf(1.0, efor_spent), total_efor − 1.0 × team_speed(b)), priced at iteration speed. Same deferral as above — during a round hold it buys no calendar time in the phase it fires in; the saving shows up in the development and beta bands.
  - **EFFECTS** `bug_delta` — {"type": "bug_delta", "amount": 3}
    ProductSystem.apply_bug_delta(3) (event_manager.gd:655-657 → product_system.gd:1364-1369): active_build.bug_count = max(0, bug_count + 3). The largest single bug_delta in the family. Worth −2.4 effective stability while open (BUG_STABILITY_COEF 0.8, quality_model.gd:67). On the audited v2, which inherited 10 live bugs at build start and shipped at bug_count 1, three bugs is a substantial addition to the pool beta has to find and fix.
  - **DURATION** one-time — both land immediately (with the deferral caveat on the day count); the bugs persist until beta or a bug sprint clears them.
  - **CHIP** Two chips:
TR: "-1 gün" (positive badge — delay_days kind is inverted) · "Hata +3" (negative)
EN: "-1 days" (positive) · "Bugs +3" (negative)
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**FLAGS** — PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE

- **PERMANENT SWING** — Choice 0's dimension_delta experience +6 is permanent and, in the audited run, MEASURABLY dominant: v2 seeded at experience 16, shipped at 22 — the click supplied 27 % of the shipped axis and matched the contribution of the paid feature (saas_ops_mobile) that the build was commissioned and invoiced for (FinanceSystem.apply_one_time_cost at product_system.gd:1310). It then re-seeds v3 (25) and v4 (36), so it is still in the product 56 days later. Effect on the economy: normalized quality 44.0 → 46.4, +2.4 on the 0-100 band. 180-day B2C projection: +2.4 × HOURLY_AUD_QUALITY_COEF 0.006 (sales_system.gd:62, :203-206) = +0.0144 audience/hour = +62 audience over 4,320 hours, against the 346 from the HOURLY_AUD_BASE trickle — a permanent ~18 % uplift on the base term, before the compounding word-of-mouth term at sales_system.gd:213. In the audited B2B run the same axis feeds the customer satisfaction target and pitch odds instead.
- **MAGNITUDE** — The +6 experience is out of band for an ambient card at this scale. Measured: it supplied as much of the v2 experience axis as the paid feature the build existed to deliver (seed 16 → ship 22, PROBE SHIP day=63), 27 % of the shipped axis, from one 8.255 %/hour roll. Player state on the day it fired (PROBE STATE day=55): cash $29,111, MRR $3,125, 4 customers, 1 employee, burn $50/day rising to $260 the next day, runway INF. The delay_days +2 is also out of band relative to the build it lands in: the v2 build's whole total_efor was 8 ("v2 build started … total_efor=8"), so two iteration-days of added effort is a 25-50 % increase in the entire remaining work, while the chip presents it as "+2 gün" against a build the player reads as roughly 8 days long.
- **COPY LIE** — Two claims the engine contradicts. (1) "Kimsenin bilmediği bir şey hakkında karar veriyorsun" — on a version build the feature is frequently a CONTRACTUAL PROMISE to a named account with a deadline. The audited run fired this card on the exact day such a build was commissioned: "start_version_build feature=saas_ops_mobile (promise promise_co_lead_51_13_saas_ops_mobile_55 deadline=69)", with the customer's satisfaction already decaying against that promise. Somebody knows, is named, and is counting days. (2) The label promises "birkaç gün daha" — "a few more days" reads as three or more, the modifier is 2, and during an iteration round hold the phase does not slip at all because rounds are ITER_ROUND_DAYS = 4 speed-independent calendar days and effort is frozen (product_system.gd:70, :580-581, :594). The card asserts a delay it may not deliver in the band it fires in.
- **VOICE** — One substantive hit plus the dash criterion. (1) Dash: 1 em dash in the TR body, 1 in the EN body, 1 in the TR label "Düzgün yap — birkaç gün daha gerek" and 1 in its EN sibling. (2) The closing line "Kimsenin bilmediği bir şey hakkında karar veriyorsun" is written as a universal truth about the moment and is false in the version-build case the card most often fires in. The prose is otherwise the best writing in the family — concrete, unhurried, no pre-labelled wisdom on either path. Language law respected: "sekme" means browser tab and is not a UI tab name (the tab labels are Ürün/Ekip/Finans/Satış/…, strings.csv TAB_*), no banned English, no NPC voice (character_id is "").

<details><summary>Flags checked and not applicable (7)</summary>

- *FREE LUNCH* — Choice 0 pays +2 gün of effort; choice 1 pays 3 bugs. Both are priced and both prices are chipped. The only softness is that the day price is deferred out of the phase it is charged in (product_system.gd:580-594), so the cost is felt later and elsewhere than the card implies — a legibility problem, not a free lunch.
- *REPEATABLE COMPOUND* — "one_shot": true, honored (event_manager.gd:486-490); PROBE TALLY shows fires=1. The 35 %/day roll is the family's highest but it can still land only once per run.
- *NO OP* — All four modifiers dispatch to live arms (dimension_delta :652, delay_days :658, bug_delta :655) and each mutates the active build. Note that the delay_days effect on the CURRENT phase can be zero during an iteration round hold, but the effort change itself is real and lands in the later bands — a deferral, not a no-op.
- *IDENTICAL OPTIONS* — The two rows share no modifier: {experience +6, +2 days} vs {−1 day, bugs +3}. (Family note: this is the same skeleton as ev_mvp_iter_002 and ev_mvp_iter_003 — one row buys an axis for days, the other sells quality for speed — so the three iteration cards read as one decision offered three times with different flavour.)
- *BLIND* — Every modifier has a chip builder (dimension_delta event_modal.gd:508-516, delay_days :520-522, bug_delta :517-519); nothing falls through the terminal `return {}` at :567.
- *INVISIBLE* — No set_flag or bookkeeping modifier. Both effects land on visible gauges — the experience axis on the build HUD and ship report card, the bug count on the tracker.
- *DEAD REFERENCE* — All modifier types are live dispatcher arms; both condition types (build_phase :411, random :385/:512) are live. No flag written, nothing unread.

</details>

**Notes.** The highest-frequency card in the family (35 %/day) and the one whose day-cost is least honest to the phase it fires in. The deferral mechanism is worth escalating as a family-wide issue, not just here: apply_speed_bonus prices "days" at the CURRENT phase's team_speed (product_system.gd:1341) and then spends that effort across three bands with different speeds, and during an iteration round hold it buys or costs no calendar time at all — so "+2 gün" on an iteration card is a promise about a number the engine does not keep in the band the player is watching. cooldown_days 12 is inert beneath one_shot true.

---

### ev_mvp_iter_002_competitor_signal

```
FILE          data/events/reactive/ev_mvp_iter_002_competitor_signal.json (authored JSON pool event — no GDScript builder)
CATEGORY      product (build-phase pool, iteration band; the fiction is rival-facing but no rival system is touched or read)
REACHABLE     yes, in a normal run, and it is the FIRST decision the player meets — PROBE FIRE day=6 hour=8 id=ev_mvp_iter_002_competitor_signal src=pool, during the v1 build's iteration round 1 (build started day 2, round 1 ended day 7, enter_development day 8). The probe answered choice 0.
FIRES         Ambient/hourly path. Requires an active build with current_phase == "iteration" (event_manager.gd:411-415) and a random roll evaluated ONLY at hours 08, 09, 10, 11 (allowed_hours [8,11], 4 hours; pre-filter event_manager.gd:106, re-gate :501). The authored "chance": 0.25 is per-DAY, so each hourly roll uses hourly_chance(0.25, 4) = 1 − 0.75^(1/4) = 0.069396 → 6.940 % per hour (event_manager.gd:512 + :537-541), reproducing 25 % across a full iteration day. ≤1 ambient card enters the queue per calendar day pool-wide (event_manager.gd:100 + :113). Because the v1 build is the first thing that happens in a run and its iteration band is short (days 2-7 in the audited run), this card competes only with ev_mvp_iter_001 and ev_mvp_iter_003 for that window.
FREQUENCY     one-shot per run, honored — pool path, _is_eligible one_shot guard against _history (event_manager.gd:486-490, appended at :224). "cooldown_days": 21 is dead weight beneath it (the family's longest, and the most obviously never-reached). Re-arms only on EventManager.reset() (:325-333).
```

**TITLE (TR)** Rakip benzer şey duyurdu  ·  **TITLE (EN)** A rival announced something similar
**SUBTITLE (TR)** Akış · 11:02  ·  **(EN)** The feed · 11:02
**ALLOWED HOURS** [8, 11] — hours 08, 09, 10, 11 inclusive (4 hours). The subtitle clock "11:02" sits INSIDE the window and _live_subtitle (event_modal.gd:192-206) rewrites the hour from the live clock, so the audited hour-08 fire rendered "AKIŞ · 08:02". The body's time reference is "Sabah akışı karıştırırken" ("scrolling the feed this morning"), which is true across all four eligible hours — the family's second-cleanest clock handling after ev_mvp_dev_003.
**PRIORITY** 0 — same tie group, shuffled through RngStreams.STREAM_EVENTS (event_manager.gd:120-137).

**BODY (TR)**

> Sabah akışı karıştırırken bir paylaşım dizisi denk geldi. **Meridyen'in bu dönem ekibinden biri** — neredeyse aynı problemi vuruyorlar. Onların paylaşımı temiz, demo videosu pürüzsüz, yorumları iyi.
>
> İlk içgüdü: panik. İkinci içgüdü: *'Bizimkini onların yapamadığı bir şeye eğip ayrışalım.'*
>
> Üçüncü içgüdü, bir saat sonra geliyor: belki ikisi de yanlış cevap.

**BODY (EN)**

> Scrolling the feed this morning you came across a thread. **Someone from Meridyen's cohort this season** — hitting almost exactly the same problem. Their post is clean, the demo video is smooth, the replies are warm.
>
> First instinct: panic. Second instinct: *'let us bend ours toward something they cannot do and stand apart.'*
>
> The third instinct arrives an hour later: maybe both are the wrong answer.

**CHOICE 1** — `Tasarımı onların eksik yerine eğ` / `Bend the design toward their blind spot`

  *desc:* ABSENT — the JSON carries no "description" field. / ABSENT

  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "innovation", "amount": 5}
    event_manager.gd:652-654 → ProductSystem.apply_dimension_delta("innovation", 5) → product_system.gd:1349-1362: active_build.innovation = maxf(0.0, innovation + 5.0). MEASURED in the audited run: the v1 shipped at innovation 9.0 (PROBE SHIP day=24), so this single click is 56 % of the entire shipped innovation axis — without it the axis would have been 4.0. Composite drops from (9+27+10)/3 = 15.33 to 13.33 and normalized market quality from q 38.0 to 35.3 (QualityModel.normalized_quality, NORMALIZE_HALF_SAT 25.0, quality_model.gd:52 + :99-102; the run log's own q=38.0 on day 24 reproduces the raw-dims arithmetic exactly). PERMANENT: stamped into mvp_innovation at ship (product_system.gd:1099-1101) and re-seeded into v2 (12), v3 (18), v4 (18).
  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": 2}
    event_manager.gd:658-660 → ProductSystem.apply_speed_bonus(2) → product_system.gd:1341: total_efor = maxf(maxf(1.0, efor_spent), total_efor + 2.0 × team_speed(b)), priced at ITERATION speed (PHASE_AREAS["iteration"] = ["product","design"]) and spent 20/60/20 across the design, development and beta bands (product_system.gd:586-590). In the audited run it fired during round 1, the one part of the iteration band where effort actually accrues (product_system.gd:605-618) — so here the raised design cap did lengthen round 1. Cost: 2 days at burn $50/day = $100, 1.26 % of the day-6 cash of $7,950.
  - **DURATION** mixed — İnovasyon +5 PERMANENT (ship snapshot + every later version seed); +2 gün one-time.
  - **CHIP** Two chips:
TR: "İnovasyon +5" (positive) · "+2 gün" (negative)
EN: "Innovation +5" (positive) · "+2 days" (negative)
EFFECT_AXIS "{axis} {v}" with ProductCatalog.axis_label("innovation") → PROD_AXIS_INNOVATION = "İnovasyon"/"Innovation" (event_modal.gd:508-516, product_catalog.gd:369-374); EFFECT_DAYS "{v} gün"/"{v} days" (event_modal.gd:520-522).
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**CHOICE 2** — `Kendi yolundan sapma` / `Do not swerve from your own line`

  *desc:* ABSENT / ABSENT

  - **EFFECTS** `brand` — {"type": "brand", "delta": 2}
    event_manager.gd:567-568 → GameState.set_brand(GameState.brand + 2) (game_state.gd:326). Brand starts at 50 (PROBE STATE day=1 brand=50) and NOTHING decays it — the only other shipped writers are B2BConstants.CHURN_BRAND (b2b_sales_system.gd:282) and PROMISE_BROKEN_BRAND (:492). So this is a permanent global +2. Live readers: the B2C hourly audience accrual (sales_system.gd:205, HOURLY_AUD_BRAND_COEF = 0.004 at :63), the Series A phase gate's brand_above 24 requirement (phase_gate_system.gd:63), and the VC seed score, where brand_delta = clampi(round((brand − 50) × 0.4), −12, +12) (vc_pitch_system.gd:128, PitchConstants.SEED_BRAND_FLOOR = 50) — so +2 brand is worth exactly +1 point of seed pitch score, permanently.
  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "innovation", "amount": -2}
    event_manager.gd:652-654 → ProductSystem.apply_dimension_delta("innovation", -2) → product_system.gd:1349-1362: active_build.innovation = maxf(0.0, innovation − 2.0), floored at 0. On the audited v1 the innovation axis without this card's help would have been 4.0, so a −2 here is a 50 % cut of the axis — and if the axis were below 2 the floor would silently swallow part of the penalty while the chip still promises the full −2. Permanent by the same ship-snapshot + version-seed chain.
  - **DURATION** PERMANENT on both counts — Marka +2 never decays (no decay path exists in shipped code); İnovasyon −2 rides into the ship snapshot and every later version seed.
  - **CHIP** Two chips:
TR: "Marka +2" (positive) · "İnovasyon -2" (negative)
EN: "Brand +2" (positive) · "Innovation -2" (negative)
EFFECT_BRAND "Marka {v}"/"Brand {v}" with _fmt_signed(2) = "+2" (event_modal.gd:491), EFFECT_AXIS with _fmt_signed(-2) = "-2" (event_modal.gd:508-516).
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**FLAGS** — PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE

- **PERMANENT SWING** — BOTH rows are permanent, and choice 0 is the family's largest measured swing. Choice 0: +5 innovation is 56 % of the audited v1's entire shipped innovation axis (9.0, PROBE SHIP day=24) — one ambient card more than DOUBLED it. Removing it moves normalized market quality from 38.0 to 35.3, −2.7 on the 0-100 band, and the axis re-seeds every later version (product_system.gd:1099-1101, :1287-1296). 180-day B2C projection: 2.7 normalized points × HOURLY_AUD_QUALITY_COEF 0.006 (sales_system.gd:62, :203-206) = +0.0162 audience/hour = +70 audience over 4,320 hours, against the 346 the HOURLY_AUD_BASE trickle yields — a permanent ~20 % uplift on the base term, plus compounding through the word-of-mouth term (sales_system.gd:213). Choice 1: brand +2 has no decay path anywhere in shipped code, feeds the audience accrual at HOURLY_AUD_BRAND_COEF 0.004 forever (0.004 × 2 × 24 × 180 = +34.6 audience over 180 days, ~10 % of the base term) and is worth a permanent +1 on the VC seed score (vc_pitch_system.gd:128).
- **MAGNITUDE** — The family's clearest out-of-band number. Player state when it fires (PROBE STATE day=6): cash $7,950, MRR $0, brand 50, burn $50/day, runway 5.30 months, 0 customers, 0 employees — the poorest, earliest moment in the run. From that position a single ambient card at 6.940 %/hour supplies +5 innovation, which is 56 % of the axis the product ships with 18 days later, and moves permanent market quality by 2.7 points of 100. For comparison, the paid three-feature v1 build cost $1,800 at commit ("[FinanceSystem] one-time cost $1800 (build_commit)") and delivered a total innovation of 4.0 without this card. An unpriced ambient roll out-produces the purchased build on that axis.
- **COPY LIE** — The card is about a competitor and the competitor system is never consulted or moved. (1) It names "Meridyen" and "bu dönem ekibi" — an accelerator cohort. The engine has no accelerator concept anywhere, and the only "Meridyen" in shipped data is "Meridyen Hukuk", a LAW FIRM in the prospect roster (company_catalog.gd:89). (2) The game does model rivals — RivalCatalog carries eight named rival products per subgenre with share and momentum (rival_catalog.gd:44-53, :79-81) and RivalRegistry advances them daily; SalesSystem even benchmarks the player against the startup league (sales_system.gd:_rival_relative_quality). This card reads none of it, names none of them, and changes no rival's state, so "neredeyse aynı problemi vuruyorlar" is an assertion about a world object that does not exist. (3) "Kendi yolundan sapma" awards public BRAND +2 for a decision taken alone during a pre-launch build that, in the audited run, fired on day 6 when the product had not shipped, there were no customers and no audience — brand is the public-perception scalar the B2C audience reads hourly (sales_system.gd:205), and nothing in the fiction has anyone observing the choice.
- **VOICE** — One substantive hit plus the dash criterion. (1) Dash: 1 em dash in the TR body, 1 in the EN body; labels are clean. (2) The named-but-unmodelled institution ("Meridyen'in bu dönem ekibinden biri") — the writing is doing world-building the engine cannot honour, and the world it does have (the rival roster) goes unused. The register itself is strong: the three-instinct structure is the best-shaped paragraph in the family, and neither choice pre-labels its own wisdom. Language law respected: "demo" is on the ruled accepted loanword list; "Akış" is the feed, not a UI tab (the tab labels are Ürün/Ekip/Finans/Satış/…, strings.csv TAB_*); no NPC speaks (character_id is "").

<details><summary>Flags checked and not applicable (7)</summary>

- *FREE LUNCH* — Choice 0 pays +2 gün ($100 of burn on day 6, 1.26 % of cash). Choice 1 pays İnovasyon −2 for its Marka +2 — a real trade, and on the audited v1 the axis it cuts is small enough that −2 is half of what the axis would otherwise have been. No option is upside-only.
- *REPEATABLE COMPOUND* — "one_shot": true, honored by _is_eligible (event_manager.gd:486-490); PROBE TALLY shows fires=1. Nothing stacks.
- *NO OP* — All four modifiers dispatch to live arms (dimension_delta :652, delay_days :658, brand :567) and each mutates state. Sole caveat: apply_dimension_delta's maxf(0.0, …) floor (product_system.gd:1357-1359) can silently absorb part of choice 1's −2 if the innovation axis is below 2 at the time — on a v1 iteration, before any features have landed, the axis genuinely can be that low.
- *IDENTICAL OPTIONS* — The two rows share no modifier and are structurally different — one is a product trade (axis for days), the other a cross-domain trade (product axis for brand). This is the only card in the family whose second row is not the standard "go faster, take bugs" shape.
- *BLIND* — Every modifier has a chip builder (dimension_delta event_modal.gd:508-516, delay_days :520-522, brand :491); nothing falls through the terminal `return {}` at :567. Note the chips are accurate about the DIRECTION of every effect; what they cannot convey is that both of choice 1's effects are permanent.
- *INVISIBLE* — No set_flag, no bookkeeping modifier. Brand is a headline stat rendered in the TopBar and Finance summary; the innovation axis appears on the build HUD and the ship report card.
- *DEAD REFERENCE* — As an EFFECT question: no. All modifier types are live dispatcher arms and both condition types (build_phase :411, random :385/:512) are live; brand has real readers (sales_system.gd:205, phase_gate_system.gd:63, vc_pitch_system.gd:128). The fiction's dangling reference to a rival is filed under COPY_LIE, where it belongs.

</details>

**Notes.** Usually the first decision a player ever makes, and it hands out the largest permanent product swing in the family for the smallest visible price. Two things to escalate: the +5 innovation against a v1 that ships at innovation 9, and the fact that the game's only rival-facing build card ignores the rival system entirely while inventing an institution for it. Both of choice 1's effects are permanent and neither chip says so — the card's whole cost surface is deferred into stats the player will not reconcile for weeks. cooldown_days 21 is inert beneath one_shot true.

---

### ev_mvp_iter_003_early_user_feedback

```
FILE          data/events/reactive/ev_mvp_iter_003_early_user_feedback.json (authored JSON pool event — no GDScript builder)
CATEGORY      product (build-phase pool, iteration band)
REACHABLE     yes, in a normal run — PROBE FIRE day=89 hour=18 id=ev_mvp_iter_003_early_user_feedback src=pool, during the v3 version build's iteration band, and specifically DURING iteration round 2 ("[ProductSystem] Iteration round 2 started (4 days)" is logged immediately before the fire on day 89; enter_development followed on day 90 regardless). The probe answered choice 0. Its earliest reachable window is the v1 iteration band, days 2-7.
FIRES         Ambient/hourly path. Requires an active build with current_phase == "iteration" (event_manager.gd:411-415) and a random roll evaluated ONLY at hours 16, 17, 18, 19, 20 (allowed_hours [16,20], 5 hours; pre-filter event_manager.gd:106, re-gate :501). The authored "chance": 0.25 is per-DAY, so each hourly roll uses hourly_chance(0.25, 5) = 1 − 0.75^(1/5) = 0.055913 → 5.591 % per hour (event_manager.gd:512 + :537-541). ≤1 ambient card enters the queue per calendar day pool-wide (event_manager.gd:100 + :113). Only ev_mvp_iter_001 and ev_mvp_iter_002 compete for the iteration window, since the build-phase gate (event_manager.gd:472-485) silences everything not scoped to "iteration" or tagged build_safe.
FREQUENCY     one-shot per run, honored — pool path, _is_eligible one_shot guard against _history (event_manager.gd:486-490, appended at :224). "cooldown_days": 18 is dead weight beneath it. Re-arms only on EventManager.reset() (:325-333).
```

**TITLE (TR)** Tanıdıktan istenmemiş geri bildirim  ·  **TITLE (EN)** Unsolicited feedback from someone you know
**SUBTITLE (TR)** Mesaj · 16:48  ·  **(EN)** Message · 16:48
**ALLOWED HOURS** [16, 20] — hours 16, 17, 18, 19, 20 inclusive (5 hours). The subtitle clock "16:48" sits INSIDE the window and _live_subtitle (event_modal.gd:192-206) rewrites the hour from GameState.current_hour, so the audited hour-18 fire rendered "MESAJ · 18:48". The body's only time reference is "Bugün uzun bir mesaj attı", which holds across the whole window.
**PRIORITY** 0 — same tie group, shuffled through RngStreams.STREAM_EVENTS (event_manager.gd:120-137).

**BODY (TR)**

> Eski iş arkadaşına geçen hafta demoyu açmıştın. Bugün uzun bir mesaj attı. **'Aslında şu olsa daha iyi olurdu...'** ile başlıyor. Üç paragraf devam ediyor.
>
> Halbuki o senin hedef kullanıcın bile değil. Ama söyledikleri aklına takıldı.
>
> *'Bir geri bildirim — herkes bir şey söyler.'* Bu cümleyi kaç kere duymuştun ki?

**BODY (EN)**

> You showed an old colleague the demo last week. Today they sent a long message. It opens with **'Actually it would be better if…'** and goes on for three paragraphs.
>
> They are not even your target user. But what they said has stuck with you.
>
> *'One piece of feedback — everybody has an opinion.'* How many times have you heard that sentence?

**CHOICE 1** — `Önerilerini ciddiye al, tasarımı tekrar düşün` / `Take their notes seriously, rethink the design`

  *desc:* ABSENT — the JSON carries no "description" field. / ABSENT

  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "experience", "amount": 6}
    event_manager.gd:652-654 → ProductSystem.apply_dimension_delta("experience", 6) → product_system.gd:1349-1362: active_build.experience = maxf(0.0, experience + 6.0). MEASURED in the audited run: the v3 build was seeded at experience 25 ("v3 build started: 5 features (union), total_efor=8, seeded I18/S31/E25", day 88) and shipped at experience 31.0 (PROBE SHIP day=96) — the entire increment came from this click, 19 % of the shipped axis. Composite moves from (18+31+25)/3 = 24.67 to 26.67, normalized quality from 49.7 to 51.6. PERMANENT: stamped into mvp_experience at ship (product_system.gd:1099-1101) and re-seeded into v4, which shipped at experience 36.0 on day 119 still carrying it.
  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": 2}
    event_manager.gd:658-660 → ProductSystem.apply_speed_bonus(2) → product_system.gd:1341: total_efor = maxf(maxf(1.0, efor_spent), total_efor + 2.0 × team_speed(b)), priced at ITERATION speed and spent 20/60/20 across the design, development and beta bands (product_system.gd:586-590). In the audited run the card fired DURING iteration round 2, where effort accrual is frozen (in_iter_hold, product_system.gd:580-581 + :594) because rounds are ITER_ROUND_DAYS = 4 speed-independent calendar days (product_system.gd:70, :701-706) — and the run bears this out: enter_development still happened the very next day, day 90. The promised two days did not slip the phase the card fired in at all; the whole cost deferred into development and beta.
  - **EFFECTS** `cash` — {"type": "cash", "delta": -100}
    event_manager.gd:565-566 → GameState.set_cash(GameState.cash − 100) (game_state.gd set_cash). The family's ONLY cash modifier. At the day-89 state (cash $24,914, burn $260/day, PROBE STATE day=89) it is 0.40 % of cash and 38 % of one day's burn. At the earliest reachable moment — the v1 iteration band, days 2-7, cash $8,150 falling to $7,900, burn $50/day — it is 1.26 % of cash and exactly TWO days of burn.
  - **DURATION** mixed — Deneyim +6 PERMANENT (ship snapshot + every later version seed); +2 gün one-time and deferred; Nakit -$100 one-time.
  - **CHIP** Three chips, stacked one per row (event_modal.gd:402-412):
TR: "Deneyim +6" (positive) · "+2 gün" (negative) · "Nakit -$100" (negative)
EN: "Experience +6" (positive) · "+2 days" (negative) · "Cash -$100" (negative)
EFFECT_AXIS with PROD_AXIS_EXPERIENCE = "Deneyim"/"Experience" (event_modal.gd:508-516); EFFECT_DAYS "{v} gün"/"{v} days" (:520-522); EFFECT_CASH "Nakit {v}"/"Cash {v}" with _fmt_money_delta(-100) → abs 100 < 1000, so the plain form "-$100" (event_modal.gd:489, formatter :604-614 — no K-truncation at this magnitude). This is the only three-chip row in the family.
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**CHOICE 2** — `Vizyonuna sadık kal, yola devam` / `Stay true to your vision, keep going`

  *desc:* ABSENT / ABSENT

  - **EFFECTS** `delay_days` — {"type": "delay_days", "days": -1}
    ProductSystem.apply_speed_bonus(-1) (event_manager.gd:658 → product_system.gd:1341): total_efor = maxf(maxf(1.0, efor_spent), total_efor − 1.0 × team_speed(b)), priced at iteration speed. Same deferral: during a round hold it buys no calendar time in the iteration band; the saving lands in development and beta.
  - **EFFECTS** `brand` — {"type": "brand", "delta": 1}
    event_manager.gd:567-568 → GameState.set_brand(GameState.brand + 1) (game_state.gd:326). Permanent, no decay path in shipped code. Live readers: the B2C hourly audience accrual (sales_system.gd:205, HOURLY_AUD_BRAND_COEF 0.004), the Series A brand_above 24 gate (phase_gate_system.gd:63), and the VC seed score — where brand_delta = clampi(round((brand − 50) × 0.4), −12, +12) (vc_pitch_system.gd:128, SEED_BRAND_FLOOR 50). Note the arithmetic: from the starting brand of 50, +1 gives round(0.4) = 0, so in the VC scoring channel this modifier is worth exactly NOTHING until a second brand point arrives.
  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "experience", "amount": -2}
    event_manager.gd:652-654 → ProductSystem.apply_dimension_delta("experience", -2) → product_system.gd:1349-1362: active_build.experience = maxf(0.0, experience − 2.0), floored at 0. On the audited v3 (seed 25) that is 8 % of the axis; on a v1 iteration, where the experience axis starts near zero (QualityModel's axes are BORN AT 0, quality_model.gd:24-25), the maxf floor can silently swallow the whole penalty while the chip still promises −2. Permanent by the ship-snapshot + version-seed chain.
  - **DURATION** mixed — Marka +1 and Deneyim −2 are both PERMANENT; −1 gün is one-time and deferred.
  - **CHIP** Three chips:
TR: "-1 gün" (positive badge — delay_days kind is inverted, dd<0 → positive) · "Marka +1" (positive) · "Deneyim -2" (negative)
EN: "-1 days" (positive) · "Brand +1" (positive) · "Experience -2" (negative)
Two of the three badges read positive, which is an accurate rendering of a row that is genuinely two upsides against one thin cost.
  - **UNLOCK** NONE — "unlock_condition": {}, "unlock_reason_text": "".

**FLAGS** — PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE

- **PERMANENT SWING** — Three of the six modifiers are permanent. Choice 0's experience +6: measured 25 → 31 on the audited v3 (seed line day 88, PROBE SHIP day=96), 19 % of the shipped axis, moving normalized quality from 49.7 to 51.6 (+1.9 on the 0-100 band) and re-seeding into v4's shipped 36.0. 180-day B2C projection: +1.9 × HOURLY_AUD_QUALITY_COEF 0.006 (sales_system.gd:62, :203-206) = +0.0114 audience/hour = +49 audience over 4,320 hours, against the 346 from the HOURLY_AUD_BASE trickle — a permanent ~14 % uplift on the base term. Choice 1's brand +1 has no decay path anywhere and feeds the same accrual at HOURLY_AUD_BRAND_COEF 0.004 forever (0.004 × 1 × 24 × 180 = +17 audience over 180 days), plus the Series A gate at phase_gate_system.gd:63. Choice 1's experience −2 is equally permanent in the other direction.
- **MAGNITUDE** — The axis number is out of band; the cash number is not. Axis: +6 experience is 19 % of the audited v3's shipped axis (25 → 31) and, on its earliest reachable firing during the v1 iteration band, would be 60 % of the 10.0 experience the v1 actually shipped with (PROBE SHIP day=24) — an ambient 5.591 %/hour roll outweighing the three purchased features on that axis. Cash: −$100 is in band on both ends — 0.40 % of the day-89 cash of $24,914 and 38 % of one day's $260 burn (PROBE STATE day=89), or 1.26 % of the ~$7,900-8,150 and exactly two days of $50 burn at the earliest reachable moment (PROBE STATE days 2-7). Nothing about the money is alarming; the axis is.
- **COPY LIE** — Three assertions the engine cannot back. (1) "Eski iş arkadaşına geçen hafta demoyu açmıştın" — nothing in the engine records a demo ever being shown, and on the card's EARLIEST reachable window (the v1 iteration band, days 2-7) there is no artifact to show: the audited run's v1 did not ship until day 24, and the iteration phase is the design band before any code exists. (2) "Halbuki o senin hedef kullanıcın bile değil" claims a target-user model; the engine has a market_type flag and a subgenre, no user personas, and this card reads neither. (3) The $100 has no counterpart in the fiction — the body describes reading a message and rethinking a design; nothing is bought, nobody is paid, and the chip "Nakit -$100" is the player's only notice that money left.
- **VOICE** — Three hits. (1) Dash criterion: 1 em dash in the TR body, 1 in the EN body; labels are clean. (2) The card fabricates run history ("geçen hafta demoyu açmıştın") that no state records and that its earliest firing window makes impossible. (3) A TR/EN typographic mismatch inside the same quoted fragment: the Turkish uses three periods, "**'Aslında şu olsa daha iyi olurdu...'**", while the English uses the ellipsis character, "**'Actually it would be better if…'**" — the two locales should not disagree on the same punctuation mark. Language law otherwise respected: "demo" is on the ruled accepted loanword list, "geri bildirim" is correctly translated rather than left as feedback, no UI tab is named, and no NPC delivers scene-setting (character_id is ""; the colleague is quoted, never staged).

<details><summary>Flags checked and not applicable (7)</summary>

- *FREE LUNCH* — Not strictly — choice 1 does carry a cost (Deneyim −2). But it is the thinnest cost in the family and the closest call: the row buys a day of build time AND a permanent brand point for 2 points of a product axis, and on the audited v3 that axis was 25, so the price is 8 % of one of three axes while the brand gain never decays. Worth recording as a near-miss rather than a hit; on a v1 iteration, where the experience axis is still near its born-at-zero start, apply_dimension_delta's maxf(0.0, …) floor (product_system.gd:1357-1359) can absorb the penalty entirely and the row becomes a literal free lunch.
- *REPEATABLE COMPOUND* — "one_shot": true, honored by _is_eligible (event_manager.gd:486-490); PROBE TALLY shows fires=1. Nothing stacks.
- *NO OP* — All six modifiers dispatch to live arms (dimension_delta :652, delay_days :658, cash :565, brand :567). Two partial-inertness edges worth noting rather than counting: choice 1's experience −2 can be wholly absorbed by the maxf(0.0, …) floor on an early-v1 iteration (product_system.gd:1357-1359), and its brand +1 contributes literally zero to the VC seed score from the starting brand of 50 because round(1 × 0.4) = 0 (vc_pitch_system.gd:128).
- *IDENTICAL OPTIONS* — The two rows share no modifier: {experience +6, +2 days, cash −$100} vs {−1 day, brand +1, experience −2}. This is the family's most differentiated pair, and the only one where both rows carry three modifiers.
- *BLIND* — Every modifier has a chip builder (dimension_delta event_modal.gd:508-516, delay_days :520-522, cash :489, brand :491); nothing falls through the terminal `return {}` at :567. This card and ev_mvp_dev_003 are the family's only fully-disclosed ones. What the chips cannot say is that the brand and axis effects are permanent while the day and cash effects are not.
- *INVISIBLE* — No set_flag or bookkeeping modifier. Cash and brand are TopBar headline stats; the experience axis appears on the build HUD and ship report card; the day count moves the tracker's estimate (product_system.gd:513-518).
- *DEAD REFERENCE* — All four modifier types are live dispatcher arms (dimension_delta :652, delay_days :658, cash :565, brand :567); both condition types (build_phase :411, random :385/:512) are live; brand and cash have real readers. No flag written.

</details>

**Notes.** The family's only cash modifier lives here and it is well-calibrated; the problem is the axis beside it. Two mechanism findings proven directly from the run log rather than inferred: (a) the card fired on day 89 during iteration round 2 and enter_development still happened on day 90, so the "+2 gün" chip cost zero calendar days in the band the player was watching — effort is frozen during a round hold (product_system.gd:580-581, :594) and rounds are speed-independent ITER_ROUND_DAYS = 4 (product_system.gd:70); (b) the +6 experience took the v3 axis from its seeded 25 to the shipped 31, and v4 then seeded from 31 and shipped at 36 — the click is still in the product 30 days later. Also worth flagging for the parent: choice 1's brand +1 is worth exactly 0 in the VC seed score from the default brand of 50 (round(0.4) = 0, vc_pitch_system.gd:128), so one of its two advertised upsides is inert in the channel a player would most expect brand to matter. cooldown_days 18 is inert beneath one_shot true.

---

### ev_mvp_bugfix_001_critical_bug

```
FILE          data/events/reactive/ev_mvp_bugfix_001_critical_bug.json (pool JSON, no builder function — loaded by EventManager._load_one, event_manager.gd:896)
CATEGORY      product (build-phase card, Beta/"bugfix")
REACHABLE     yes, in a normal run — PROBE FIRE day=61 hour=22 id=ev_mvp_bugfix_001_critical_bug src=pool, resolved choice 0 ("Çıkışı ertele, çöz"). It fired during the v2 build's Beta, not the MVP's, despite the id.
FIRES         Both conditions must hold (AND, event_manager.gd:506-517): (1) build_phase == "bugfix" — ProductSystem.get_active_build() is non-null and its current_phase is the internal name for BETA (event_manager.gd:411-414; the phase is set at product_system.gd:752 and displayed as "BETA"/BUILD_PHASE_BETA); (2) a random roll. Because it has a random trigger it takes the HOURLY path (event_manager.gd:88-115), pre-filtered to allowed_hours [18,23], so _window_length_hours returns 6 and the authored 0.4 is converted to the per-hour probability hourly_chance(0.4, 6) = 1 − 0.6^(1/6) = 0.08162 (8.16 % per hour, event_manager.gd:537-541). Six rolls across 18:00-23:59 reproduce exactly 40 % per day. Capped further by the ≤1-ambient-per-day throttle (_ambient_fired_day, event_manager.gd:96-98) and by _is_eligible step 2, which during any active build admits only build_phase-scoped or "build_safe"-tagged events (event_manager.gd:468-481). Over a 6-day Beta the cumulative chance is 1 − 0.6^6 = 95.3 % before contention with its two siblings.
FREQUENCY     one-shot, and the latch is REAL here — this is a pool event, so it goes through _is_eligible, whose history guard at event_manager.gd:485-489 enforces one_shot: true against EventManager._history. cooldown_days: 14 is authored but moot behind the one-shot. Run evidence: PROBE TALLY ev_mvp_bugfix_001_critical_bug fires=1 picks=1 across FOUR separate Beta phases (v1 d18-24, v2 d59-63, v3, v4).
```

**TITLE (TR)** Bir hata buldun ki...  ·  **TITLE (EN)** You found a bug of the kind that…
**SUBTITLE (TR)** Mutfak masası · 19:22  ·  **(EN)** Kitchen table · 19:22
**ALLOWED HOURS** [18, 23] — hours 18,19,20,21,22,23 inclusive, 6 hours, no midnight wrap. The clock in the copy ("19:22") DOES sit inside the window. But the run fired it at hour 22 (PROBE FIRE day=61 hour=22), so the stamped minute and the actual clock were nearly three hours apart.
**PRIORITY** 1 — the only card in this family above 0, so it wins the _ordered_by_priority tie-break (event_manager.gd:124-135) against bugfix_002/003 in the same hour.

**BODY (TR)**

> Test ederken bir yerde tıkadın. Adımları tekrar ettin — tutarlı şekilde çöküyor. **Uç durum**: belki kullanıcıların yüzde biri görür, belki yarısı. Tahmin etmenin yolu yok.
>
> Çözmek belki üç-dört gün. Bırakmak: çıkış günü forumda gözükür mü, kim bilir.
>
> *'Yüzde bir, yüzde elli — istatistik değil bu, kumar.'*

**BODY (EN)**

> Testing, you snagged on something. You repeated the steps — it crashes consistently. **An edge case**: maybe one per cent of users hit it, maybe half. There is no way to know.
>
> Fixing it, maybe three or four days. Leaving it: does it turn up on a forum on launch day? Who knows.
>
> *'One per cent, fifty per cent — that is not statistics, that is a bet.'*

**CHOICE 1** — `Çıkışı ertele, çöz` / `Delay the launch, fix it`

  - **EFFECTS** `bug_delta` — {"type": "bug_delta", "amount": -6}
    event_manager.gd:655 → ProductSystem.apply_bug_delta(-6) → active_build.bug_count = max(0, bug_count - 6) (product_system.gd:1364-1369), then _sync_legacy_quality. Floored at 0, so it is only fully paid when the build carries ≥6 open bugs. In the recorded run v2's Beta opened with hidden_bugs=14 ([ProductSystem] Development band complete → BETA. hidden_bugs=14), so all 6 landed. Beta auto-clears ~4.5 bugs/day (v1 went 28→1 in 6 days), so −6 is worth roughly 1.3 days of Beta. NOTE: it writes bug_count without touching bugs_found/bugs_fixed, so _tick_beta_hourly's invariant hidden = bug_count − (bugs_found − bugs_fixed) can go negative (product_system.gd:808-819); bug_count stays floored at 0, but the Beta counters desync.
  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "stability", "amount": 4}
    event_manager.gd:652 → ProductSystem.apply_dimension_delta("stability", 4) → active_build.stability = max(0.0, stability + 4.0) (product_system.gd:1349-1361). Flat add, floor 0, NO upper clamp. The axis is stamped into the shipped product at launch and re-seeds every later version (product_system.gd:1288-1296: v2 seeds from mvp_innovation/mvp_stability/mvp_experience). PROOF from the run: v2 started seeded S27 ([ProductSystem] v2 build started: … seeded I12/S27/E16 bugs=10) and shipped S31 (PROBE SHIP day=63 version=2 stability=31.0) — this +4 is the ENTIRE version-over-version Stability gain of v2, and v3 then seeded from 31 and v4 from 34.
  - **EFFECTS** `cash` — {"type": "cash", "delta": -150}
    event_manager.gd:565 → GameState.set_cash(GameState.cash - 150). Unclamped (game_state.gd:309-312). Confirmed in the log: day 61 cash 28,203 → day 62 cash 27,911 = 28,203 − 142 burn − 150.
  - **DURATION** cash −$150 one-time; bug −6 one-time within the build (it buys back ~1.3 days of Beta); Stability +4 PERMANENT — it lands on the live product's axis and every later version seeds from it
  - **CHIP** Three chips, stacked: "Hata -6" (positive kind — bug_delta inverts sign, event_modal.gd:517-519) · "Kararlılık +4" (positive; EFFECT_AXIS "{axis} {v}" with axis = ProductCatalog.axis_label("stability") → PROD_AXIS_STABILITY "Kararlılık") · "Nakit -$150" (negative; _fmt_money_delta(−150), |v|<1000 → "-$150"). EN: "Bugs -6" · "Stability +4" · "Cash -$150".
  - **UNLOCK** NONE — unlock_condition {} (is_condition_met returns true on an empty dict, event_manager.gd:369-370); unlock_reason_text ""

**CHOICE 2** — `Bırak, gönder — fark eden olmaz` / `Leave it, ship — nobody will notice`

  - **EFFECTS** `set_flag` — {"type": "set_flag", "key": "critical_bug_unfixed", "value": true}
    event_manager.gd:590-595 → GameState.set_flag("critical_bug_unfixed", true) (declared TYPE_BOOL at game_state.gd:85). Read in three places: product_system.gd:1064 (projected_launch_bugs adds CRITICAL_BUG_LAUNCH_PENALTY = 5, product_system.gd:134) and product_system.gd:1084-1086 (launch() writes active_build.bug_count = projected_launch_bugs() and then consumes the flag back to false). Net effect: +5 bugs stamped onto the product at the next launch, i.e. −0.8 × 5 = −4.0 raw effective Stability (QualityModel.BUG_STABILITY_COEF = 0.8, quality_model.gd:68, 122-123) held until a post-ship bug sprint clears them. That −4.0 is almost exactly the mirror of the +4 the sibling option grants.
  - **EFFECTS** `brand` — {"type": "brand", "delta": -2}
    event_manager.gd:567 → GameState.set_brand(GameState.brand - 2), clamped 0-100 (game_state.gd:326-328). Brand's live readers are the Series A gate (brand_above 24, phase_gate_system.gd:63) and the brand-collapse ending (under 15 for 30 days, endings_system.gd:28-29, 112-113).
  - **DURATION** Brand −2 permanent (a clamped stat write). The flag is permanent until the next launch() consumes it, after which its +5 bugs persist on the live product until a bug sprint clears them.
  - **CHIP** ONE chip only: "Marka -2" (negative). EN "Brand -2". The set_flag modifier produces NOTHING — it falls through _describe_modifier's terminal `return {}` at event_modal.gd:567, so the entire +5-launch-bugs payload is chip-silent.
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**FLAGS** — PERMANENT SWING, MAGNITUDE, BLIND, COPY LIE, VOICE

- **PERMANENT SWING** — Choice 0's dimension_delta stability +4 is uncapped, floor-0, and rides forward through every version seed (product_system.gd:1288-1296). Measured, not inferred: v2 seeded S27 and shipped S31 (log line "seeded I12/S27/E16" + PROBE SHIP day=63 stability=31.0) — the whole of v2's Stability gain. With saas_ops weights (stability 1.5, wsum 3.5, product_catalog.gd:210-214) that is +1.714 composite; on a post-ship composite of ~15-18 and NORMALIZE_HALF_SAT 25 that is roughly +3 normalized quality points, held for the remaining 214 days of the run (day 61 → day 275) and inherited by v3 (S31) and v4 (S34). The mirror is choice 1: +5 permanent launch bugs = −4.0 raw effective Stability.
- **MAGNITUDE** — The card is priced for one economy and fires in another. In the recorded run it fired on day 61: cash 28,203, MRR 3,550, burn 260/day (PROBE STATE day=61) — $150 is 0.53 % of cash and 0.58 days of runway, i.e. free in practice, in exchange for the single largest Stability move the product makes all run. The same one_shot card can equally fire during v1's Beta (days 18-24 in this run), where cash is 7,120-7,350 and burn is 50/day — there the same $150 is 2.0 % of cash and exactly 3 days of runway. Nothing in the card scales with phase, so its cost varies twentyfold while its permanent gain does not vary at all.
- **BLIND** — Choice 1's set_flag critical_bug_unfixed=true hits the terminal `return {}` at event_modal.gd:567, so the only badge on that row is "Marka -2". The player is choosing to ship a known crash and is told the price is two brand points; the actual price is CRITICAL_BUG_LAUNCH_PENALTY = 5 bugs welded onto the product at launch (−4.0 raw Stability). It IS surfaced later — the Yayınla tooltip reads ProductSystem.projected_launch_bugs() on both hosts (creation_flow.gd:872-873, build_hud_panel.gd:210) — but not on the card where the decision is made. Recorded as a hidden-cost finding in docs/audits/AUDIT_2026-08-06_full_game.md:460.
- **COPY LIE** — Two, both in the labels. (a) "Çıkışı ertele, çöz" / "Delay the launch, fix it" delays nothing — there is no delay_days modifier, total_efor is untouched, and Beta ends when the player presses Yayınla, so no launch date moves. The body reinforces it: "Çözmek belki üç-dört gün" when the fix costs zero days. (b) "Bırak, gönder — fark eden olmaz" / "Leave it, ship — nobody will notice" does not ship: ship_active_build is not in the modifier list, ProductSystem.launch() is never called, the build stays in "bugfix", and the player must still press Yayınla afterwards. Both halves of the decision name an action the engine does not perform.
- **VOICE** — (a) Clock drift: the card is stamped "Mutfak masası · 19:22" but its window is [18,23] and it actually fired at hour 22 (PROBE FIRE day=61 hour=22) — the subtitle names a minute the engine has no intention of honouring. (b) Em dashes throughout, against the project's own live dash ban (docs/writing/FRANK_UNWIRED.md:38-39): body "ettin — tutarlı", "elli — istatistik", and both labels "gönder — fark eden olmaz" / "ship — nobody will notice". (c) The TR title closes on three ASCII dots ("Bir hata buldun ki...") while its EN sibling uses a real ellipsis ("…") — the pair is typographically inconsistent. (d) The closing italic line is a quotation with no speaker; character_id is "", so _build_speaker_row (event_modal.gd:243-250) renders no strip and the reader cannot tell whose voice it is.

<details><summary>Flags checked and not applicable (6)</summary>

- *FREE LUNCH* — Both options carry a real cost. Choice 0 pays $150; choice 1 pays 2 brand and a hidden bug penalty. Worth recording, though: at the day-61 fire the $150 was 0.53 % of cash (28,203) and 0.58 days of runway at burn 260/day, against a permanent +4 Stability — the price is nominal, not zero, but only just.
- *REPEATABLE COMPOUND* — one_shot: true and this is a POOL event, so the latch is genuinely enforced by _is_eligible's history scan (event_manager.gd:485-489) rather than being inert the way it is on enqueue()-injected cards. PROBE TALLY shows fires=1 across four separate Beta phases.
- *NO OP* — Both options move state. Partial caveat only: bug_delta −6 is floored at 0 (product_system.gd:1368), so on a build carrying fewer than 6 open bugs part of the promised clear silently evaporates. In this run it did not — v2's Beta opened with 14.
- *IDENTICAL OPTIONS* — Choice 0 (bug_delta/dimension_delta/cash) and choice 1 (set_flag/brand) share no modifier type and no direction.
- *INVISIBLE* — critical_bug_unfixed has three live readers (product_system.gd:1064, :1084, :1086), a declared save type (game_state.gd:85) and one player-facing surface (BUILD_SHIP_TOOLTIP_BUGS). It is hidden at decision time, not unread — that is BLIND, not INVISIBLE.
- *DEAD REFERENCE* — All four modifier types have live dispatcher arms: bug_delta event_manager.gd:655, dimension_delta :652, cash :565, set_flag :590, brand :567. Both conditions are live: build_phase :411, random :385/:510-515. Separately noted but not a dead reference: bug_delta desyncs the Beta bugs_found/bugs_fixed counters (product_system.gd:808-819).

</details>

**Notes.** The family's strongest card and its most defensible one. Its permanence claim is not a projection — the log lets you read it off two lines: v2 seeded S27, shipped S31, and no other stability modifier fired in that build cycle (iter_001 on day 55 was experience +6 / delay +2). One real engine defect surfaced while checking bug_delta: because it edits bug_count alone, a large negative delta against a build with found-but-unfixed bugs drives _tick_beta_hourly's hidden-bug invariant negative (product_system.gd:808-819). No crash — bug_count is re-floored at 0 each tick — but bugs_found/bugs_fixed drift out of step with bug_count for the rest of the Beta. Worth a line in the Product backlog, owner ProductSystem, not this family.

---

### ev_mvp_bugfix_002_early_launch_pressure

```
FILE          data/events/reactive/ev_mvp_bugfix_002_early_launch_pressure.json (pool JSON, no builder function)
CATEGORY      product (build-phase card, Beta/"bugfix")
REACHABLE     yes, in a normal run — PROBE FIRE day=21 hour=9 id=ev_mvp_bugfix_002_early_launch_pressure src=pool, resolved choice 0 ("Bir tur daha temizlik — gönder olmadı"), during v1's Beta.
FIRES         AND of two conditions (event_manager.gd:506-517): (1) build_phase == "bugfix" (event_manager.gd:411-414) — an active build in BETA; (2) a random roll. Ambient/hourly path (event_manager.gd:88-115) pre-filtered to allowed_hours [9,12], so _window_length_hours = 4 and the authored 0.3/day becomes hourly_chance(0.3, 4) = 1 − 0.7^(1/4) = 0.085307 (8.53 % per hour, event_manager.gd:537-541); four rolls across 09:00-12:59 reproduce 30 %/day. Subject to the ≤1-ambient-per-day throttle (event_manager.gd:96-98) and to _is_eligible step 2, which silences everything not scoped to the running build phase (event_manager.gd:468-481). Over a 6-day Beta: 1 − 0.7^6 = 88.2 % before sibling contention.
FREQUENCY     one-shot, and genuinely latched: pool events pass through _is_eligible, whose history guard at event_manager.gd:485-489 enforces one_shot: true. cooldown_days: 15 is authored but unreachable behind it. PROBE TALLY: fires=1 picks=1 across four Beta phases.
```

**TITLE (TR)** İçeride bir ses 'şimdi çık' diyor  ·  **TITLE (EN)** A voice inside says 'ship now'
**SUBTITLE (TR)** Masa başı · 10:15  ·  **(EN)** At the desk · 10:15
**ALLOWED HOURS** [9, 12] — hours 9,10,11,12 inclusive, 4 hours, no wrap. The copy's clock ("10:15") sits inside it. The run fired it at hour 9 (PROBE FIRE day=21 hour=9), so the shown card said 10:15 while the clock read 09:00.
**PRIORITY** 0 — loses the same-hour tie-break to ev_mvp_bugfix_001 (priority 1); ties with ev_mvp_bugfix_003 and is separated by the RngStreams shuffle inside the priority group (event_manager.gd:124-135).

**BODY (TR)**

> Banka uygulamasını açıyorsun, kapatıyorsun. Açıyorsun, kapatıyorsun. Sayı düşmüş.
>
> Hataları temizliyorsun ama her gün **runway eriyor**. Bir tarafın *'biraz daha temizle, doğru çıksın'* diyor. Diğer tarafın *'sonsuza kadar bekleyemezsin, kullanıcıya bırak'* diyor.
>
> İkisi de doğru. Bu yüzden zor.

**BODY (EN)**

> You open the banking app, close it. Open it, close it. The number has gone down.
>
> You are clearing bugs, but every day the **runway melts**. One side of you says *'clean it up a little more, ship it right.'* The other side says *'you cannot wait forever, let the users find them.'*
>
> Both are true. That is why it is hard.

**CHOICE 1** — `Bir tur daha temizlik — gönder olmadı` / `One more cleanup pass — shipping can wait`

  - **EFFECTS** `bug_delta` — {"type": "bug_delta", "amount": -4}
    event_manager.gd:655 → ProductSystem.apply_bug_delta(-4) → active_build.bug_count = max(0, bug_count - 4) (product_system.gd:1364-1369). At the day-21 fire the v1 Beta had opened three days earlier with 28 hidden bugs ([ProductSystem] Development band complete → BETA. hidden_bugs=28), so all 4 landed. Beta was clearing ~4.5 bugs/day (28 → 1 over 6 days), so −4 bought back roughly 0.9 days of Beta.
  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "stability", "amount": 2}
    event_manager.gd:652 → ProductSystem.apply_dimension_delta("stability", 2) → active_build.stability = max(0.0, stability + 2.0) (product_system.gd:1349-1361). Flat, floor 0, no ceiling. v1 shipped with stability 27.0 (PROBE SHIP day=24 version=1 stability=27.0); build events supplied 10 of those 27 points in total (dev_001 +6 on day 14, dev_003 +2 on day 16, this +2 on day 21), so this click is 2/27 ≈ 7.4 % of the MVP's whole Stability axis. It then re-seeds forward: v2 started at S27 (log "seeded I12/S27/E16").
  - **EFFECTS** `cash` — {"type": "cash", "delta": -100}
    event_manager.gd:565 → GameState.set_cash(GameState.cash - 100). Confirmed in the log: day 21 cash 7,120 → day 22 cash 6,970 = 7,120 − 50 burn − 100.
  - **DURATION** cash −$100 one-time; bug −4 one-time within the build (~0.9 days of Beta); Stability +2 PERMANENT (stamped at launch, re-seeded by every later version)
  - **CHIP** Three chips: "Hata -4" (positive kind — bug_delta inverts, event_modal.gd:517-519) · "Kararlılık +2" (positive) · "Nakit -$100" (negative, |v|<1000 form). EN: "Bugs -4" · "Stability +2" · "Cash -$100".
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**CHOICE 2** — `Hazır olmasa da çık — kullanıcı gösterir` / `Ship it ready or not — users will show you`

  - **EFFECTS** `brand` — {"type": "brand", "delta": -1}
    event_manager.gd:567 → GameState.set_brand(GameState.brand - 1), clamped 0-100 (game_state.gd:326-328). That is the option's ENTIRE mechanical content: nothing ships, no phase advances, no bug is added, no day is saved.
  - **DURATION** Brand −1, permanent (a clamped stat write)
  - **CHIP** ONE chip: "Marka -1" (negative). EN "Brand -1".
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**FLAGS** — PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE

- **PERMANENT SWING** — dimension_delta stability +2 is a flat, uncapped, floor-0 add to the live product's Stability axis, stamped in at launch and re-seeded into every later version (product_system.gd:1288-1296). With saas_ops weights (stability 1.5 / wsum 3.5) it is +0.857 composite, ~+1.3 normalized quality points on a v1 that shipped at composite ~16.7. It survived to day 275: v2 seeded S27, which contains it.
- **MAGNITUDE** — Not the upside — the DOWNSIDE is out of band. At the day-21 fire the player had cash 7,120, MRR 0, burn 50/day (PROBE STATE day=21), so choice 0's $100 is 1.4 % of cash and exactly 2 days of runway: a fair, legible price. Choice 1 — the option the card's entire body is built to make tempting ("her gün runway eriyor") — costs 1 brand point out of a baseline of 50, on a stat that did not move once in 275 recorded days (PROBE STATE brand=50 on every single line). Against the brand-collapse floor of 15 (endings_system.gd:28) that is 1/35th of the distance to a run-ending condition. The pressure branch is priced at approximately zero.
- **COPY LIE** — Choice 1 is "Hazır olmasa da çık — kullanıcı gösterir" / "Ship it ready or not — users will show you" and it does not ship. There is no ship_active_build modifier and ProductSystem.launch() is never called; the build stays in "bugfix", Beta keeps finding and fixing bugs on the next tick, and the player still has to press Yayınla themselves. The label announces a product going live and the engine deducts one brand point. Choice 0's "gönder olmadı" / "shipping can wait" has the same defect in reverse — it implies a schedule slip that no delay_days produces.
- **VOICE** — (a) Clock drift: subtitled "Masa başı · 10:15" on a card whose window is [9,12]; the run fired it at hour 9. (b) Em dashes in both labels ("temizlik — gönder olmadı", "çık — kullanıcı gösterir", "pass — shipping can wait", "not — users will show you"), against the project's live dash ban (docs/writing/FRANK_UNWIRED.md:38-39). (c) Structural repetition inside its own family: the title is literally "İçeride bir ses" and the body stages two inner voices arguing — the identical device that ev_mvp_bugfix_003 builds its closing paragraph on ("aynı anda kafanın içinde konuşuyor"). Two of the three cards in one Beta family run on the same trick, and a player who sees both in one run will notice. The banking-app opening is a fact, not staging, and reads fine.

<details><summary>Flags checked and not applicable (7)</summary>

- *FREE LUNCH* — Choice 0 costs $100 (2 days of runway at the day-21 burn of 50/day). Choice 1 is pure downside — a cost with no upside at all, which is the opposite failure but not this one.
- *REPEATABLE COMPOUND* — one_shot: true on a POOL event, so the guard at event_manager.gd:485-489 actually binds (unlike code-built cards where enqueue bypasses eligibility). PROBE TALLY fires=1 across four Betas.
- *NO OP* — Choice 0 moves three things, choice 1 moves brand. Partial caveat on choice 0: bug_delta −4 floors at 0 (product_system.gd:1368), so on a low-bug build part of the badged clear silently vanishes. Not the case here — v1's Beta opened with 28.
- *IDENTICAL OPTIONS* — Choice 0 is bug_delta + dimension_delta + cash; choice 1 is a single brand delta. No overlap.
- *BLIND* — Every modifier on both rows resolves to a chip through _describe_modifier: bug_delta at event_modal.gd:517, dimension_delta at :508-516, cash at :489, brand at :491. Nothing falls to the terminal `return {}`.
- *INVISIBLE* — All four effects have live player surfaces: cash and brand on the HUD, bug_count and the Stability axis on the Build HUD gauges (and via QualityModel into the shipped product's quality number).
- *DEAD REFERENCE* — bug_delta (event_manager.gd:655), dimension_delta (:652), cash (:565) and brand (:567) all have live dispatcher arms; build_phase (:411) and random (:385, :510-515) are both live condition types.

</details>

**Notes.** The cleanest-built card of the three — every modifier chips, the price is legible, and the fix half is honestly scaled to a pre-revenue day-21 economy. Its problem is entirely on the other side of the fork: the option the fiction is engineered to make attractive costs one brand point on a stat that provably never moves, so a player who takes the pressure seriously is punished and a player who ignores it pays nothing. Fixing that means giving choice 1 a real consequence (bugs carried to launch, or a Stability penalty), not softening choice 0.

---

### ev_mvp_bugfix_003_final_polish

```
FILE          data/events/reactive/ev_mvp_bugfix_003_final_polish.json (pool JSON, no builder function)
CATEGORY      product (build-phase card, Beta/"bugfix")
REACHABLE     yes, in a normal run — PROBE FIRE day=18 hour=0 id=ev_mvp_bugfix_003_final_polish src=pool, resolved choice 0 ("Vakit harca, cila çek"). It fired on the same day v1's Beta opened (PROBE PLAY day=18 enter_beta).
FIRES         AND of two conditions (event_manager.gd:506-517): (1) build_phase == "bugfix" — an active build in BETA (event_manager.gd:411-414); (2) a random roll. Ambient/hourly path, pre-filtered to allowed_hours [21,1], which WRAPS midnight, so _window_length_hours = (24−21)+1+1 = 5 (event_manager.gd:544-553) and the authored 0.25/day becomes hourly_chance(0.25, 5) = 1 − 0.75^(1/5) = 0.055912 (5.59 % per hour); five rolls across 21:00, 22:00, 23:00, 00:00, 01:00 reproduce 25 %/day. Throttled by ≤1 ambient/day (event_manager.gd:96-98) and by the build-phase gate at _is_eligible step 2 (event_manager.gd:468-481). Over a 6-day Beta: 1 − 0.75^6 = 82.2 % before sibling contention.
FREQUENCY     one-shot, really enforced — pool events run through _is_eligible and its history guard at event_manager.gd:485-489 honours one_shot: true. cooldown_days: 12 is authored but never reached. PROBE TALLY: fires=1 picks=1 across four Beta phases.
```

**TITLE (TR)** Küçük bir cila fırsatı  ·  **TITLE (EN)** A small chance to polish
**SUBTITLE (TR)** Demo videosu · 23:51  ·  **(EN)** Demo video · 23:51
**ALLOWED HOURS** [21, 1] — WRAPS midnight: hours 21, 22, 23, 0, 1, five hours (_is_hour_in_window, event_manager.gd:523-533). The copy's clock ("23:51") does sit inside — but so do 00:xx and 01:xx, and the recorded run fired it at HOUR 0 (PROBE FIRE day=18 hour=0). A card stamped 23:51 was shown at midnight.
**PRIORITY** 0 — loses the same-hour tie-break to ev_mvp_bugfix_001 (priority 1); ties with ev_mvp_bugfix_002, separated by the in-group RngStreams shuffle (event_manager.gd:124-135). In practice their windows barely overlap ([21,1] vs [9,12]).

**BODY (TR)**

> Ekran kaydı çekiyorsun, izliyorsun. Bir geçiş kaba. Bir yazı tipi hizalaması yamuk. Bir hata mesajı pek anlamsız.
>
> Hepsi tek tek küçük. Hepsi birlikte... fark eder mi? Belki. Belki etmez.
>
> *'Detaylar mühim'* diyenlerle *'çık önce'* diyenler aynı anda kafanın içinde konuşuyor. İkisi de tanıdık ses.

**BODY (EN)**

> You record the screen and watch it back. One transition is rough. One typeface sits crooked. One error message makes very little sense.
>
> Each of them is small on its own. All of them together… does it matter? Maybe. Maybe not.
>
> The people who say *'details matter'* and the people who say *'ship first'* are talking at the same time inside your head. Both voices are familiar.

**CHOICE 1** — `Vakit harca, cila çek` / `Spend the time, polish it`

  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "experience", "amount": 5}
    event_manager.gd:652 → ProductSystem.apply_dimension_delta("experience", 5) → active_build.experience = max(0.0, experience + 5.0) (product_system.gd:1349-1361). Flat, floor 0, no ceiling. MEASURED: v1 shipped with experience = 10.0 (PROBE SHIP day=24 version=1 experience=10.0) and this was the ONLY experience modifier that fired before that ship (iter_001's +6 landed on day 55, iter_003's +6 on day 89, both after). One click supplied HALF of the MVP's entire Experience axis. It then re-seeds forward: v2 started at E16 (log "seeded I12/S27/E16").
  - **EFFECTS** `cash` — {"type": "cash", "delta": -80}
    event_manager.gd:565 → GameState.set_cash(GameState.cash - 80). Confirmed in the log: day 18 cash 7,350 → day 19 cash 7,220 = 7,350 − 50 burn − 80.
  - **DURATION** cash −$80 one-time; Experience +5 PERMANENT (stamped at launch, inherited by every later version seed)
  - **CHIP** Two chips: "Deneyim +5" (positive; EFFECT_AXIS with axis = ProductCatalog.axis_label("experience") → PROD_AXIS_EXPERIENCE "Deneyim") · "Nakit -$80" (negative, |v|<1000 form). EN: "Experience +5" · "Cash -$80".
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**CHOICE 2** — `Yeterince iyi — devam` / `Good enough — move on`

  - **EFFECTS** `dimension_delta` — {"type": "dimension_delta", "axis": "experience", "amount": -2}
    event_manager.gd:652 → ProductSystem.apply_dimension_delta("experience", -2) → active_build.experience = max(0.0, experience - 2.0). A negative delta applies in full (no diminishing-returns softening — apply_dimension_delta bypasses QualityModel.grow entirely, product_system.gd:1350-1352), floored at 0. On the v1 that shipped at E10 this would have been a 20 % cut to the axis.
  - **EFFECTS** `bug_delta` — {"type": "bug_delta", "amount": 1}
    event_manager.gd:655 → ProductSystem.apply_bug_delta(1) → active_build.bug_count = max(0, bug_count + 1). One extra open bug = −0.8 raw effective Stability while it stands (QualityModel.BUG_STABILITY_COEF = 0.8, quality_model.gd:68, 122-123). During Beta the auto-fixer will normally clear it within hours, so its real cost is a fraction of a day unless the player ships immediately.
  - **DURATION** Experience −2 PERMANENT; bug +1 transient inside Beta (auto-cleared at ~4.5 bugs/day) but permanent if the player ships before it is fixed
  - **CHIP** Two chips: "Deneyim -2" (negative) · "Hata +1" (negative kind — bug_delta inverts sign, event_modal.gd:517-519). EN: "Experience -2" · "Bugs +1".
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**FLAGS** — PERMANENT SWING, MAGNITUDE, COPY LIE, VOICE

- **PERMANENT SWING** — The family's largest, measured directly: v1's Experience axis shipped at 10.0 and this single click supplied 5.0 of it — the axis was literally doubled by one option. With saas_ops weights (experience 1.1 / wsum 3.5, product_catalog.gd:210-214) that is +1.571 composite, ~+2.3 normalized quality points on a product that shipped around composite 16.7 / normalized 38-40. And it compounds forward: v2 seeded from the shipped flags (product_system.gd:1288-1296) at E16, v3 shipped E31, v4 E36 — the +5 is inside every one of them, for the remaining 251 days of the run. Choice 1 is the same lever pulled backwards (−2 permanent).
- **MAGNITUDE** — $80 — 1.1 % of the day-18 cash of 7,350, one and a half days of runway at a 50/day burn — buys a permanent doubling of one of the product's three quality axes (Experience 5.0 → 10.0 at ship). Nothing else available to the player at day 18 moves an axis by 100 % at any price; the deterministic feature contributions that built the other 5.0 points cost days of build effort and real build_commit cash ($1,800 for the whole v1). The two sides of the fork are also mismatched: the reward for care is +5, the penalty for haste only −2, so the expected value of always polishing is overwhelming and the choice is not really a choice.
- **COPY LIE** — "Vakit harca, cila çek" / "Spend the time, polish it" spends no time. There is no delay_days modifier and total_efor is untouched, so the build finishes on exactly the day it would have finished anyway. The engine takes $80. The label names the resource the player is being asked to trade, and it is the wrong one — which matters here more than elsewhere, because in a Beta the whole tension the body sets up ("çık önce" versus "detaylar mühim") is a tension about TIME.
- **VOICE** — (a) The clearest time-stamp failure in the audit: the card is subtitled "Demo videosu · 23:51" and its window [21,1] wraps past midnight, so hours 0 and 1 are legal — and the recorded run fired it at HOUR 0 (PROBE FIRE day=18 hour=0). The player was shown a card claiming 23:51 at midnight. (b) Em dash in the label "Yeterince iyi — devam" / "Good enough — move on", against the live dash ban (docs/writing/FRANK_UNWIRED.md:38-39). (c) TR/EN typographic split: the TR body uses three ASCII dots ("Hepsi birlikte... fark eder mi?") where the EN sibling uses a real ellipsis ("All of them together… does it matter?"). (d) The closing paragraph runs the same two-voices-in-your-head device that ev_mvp_bugfix_002 uses for its entire premise and title — the second time in a three-card family, and both cards can fire in the same Beta.

<details><summary>Flags checked and not applicable (7)</summary>

- *FREE LUNCH* — Choice 0 costs $80 — 1.1 % of the day-18 cash of 7,350 and 1.6 days of runway at the 50/day burn. Choice 1 is pure downside. Neither is costless, though $80 for a permanent 100 % gain on a quality axis is the thinnest price in the family.
- *REPEATABLE COMPOUND* — one_shot: true on a POOL event, so _is_eligible's history guard (event_manager.gd:485-489) genuinely binds. PROBE TALLY fires=1 across four separate Beta phases.
- *NO OP* — Both options move the Experience axis; choice 1 also adds a bug. Nothing here is empty or silently floored — apply_dimension_delta's floor is 0 and the axis sat at 5.0 before the click, so nothing was clipped.
- *IDENTICAL OPTIONS* — The two rows are exact sign-mirrors on the same axis (+5 vs −2) but not identical: choice 0 carries a cash cost, choice 1 carries a bug. Different effect sets.
- *BLIND* — All four modifiers across both rows resolve to chips: dimension_delta at event_modal.gd:508-516, cash at :489, bug_delta at :517-519. Nothing falls to the terminal `return {}`.
- *INVISIBLE* — Cash shows on the HUD; the Experience axis and bug count both show on the Build HUD gauges and flow through QualityModel into the product's visible quality number.
- *DEAD REFERENCE* — dimension_delta (event_manager.gd:652), cash (:565) and bug_delta (:655) all have live dispatcher arms; the "experience" axis id is in QualityModel.AXES (quality_model.gd:29) so it survives apply_dimension_delta's fallback check at product_system.gd:1355-1356; build_phase (:411) and random (:385) are live condition types.

</details>

**Notes.** The strongest permanence evidence in the family and the weakest fork. Because the run log stamps v1's shipped axes (PROBE SHIP day=24 experience=10.0) and no other experience modifier fired before it, the claim "this one click was half the MVP's Experience axis" is a reading, not an estimate. The asymmetry is the design finding: +5 for $80 against −2 for nothing means there is no reason ever to pick the second row, so the card presents a dilemma the numbers have already resolved. Pairing it with the clock defect — a 23:51 card firing at 00:00 — makes this the one entry in the family where both the fiction and the mechanics need a pass.

---

### ev_debug_001_engineer_workload

```
FILE          data/events/reactive/ev_debug_001_engineer_workload.json (DEBUG fixture, pool JSON, no builder function)
CATEGORY      team (HR-flavoured debug fixture)
REACHABLE     NO — the loader skips it by filename. _load_all_events_from_disk tests `if filename.begins_with("ev_debug_"): pass` BEFORE calling _load_one (event_manager.gd:886-887), so the file never reaches _all_events and therefore never reaches _is_eligible, the queue or _history. Confirmed by the run log's boot line: "[EventManager] Loaded 15 events from res://data/events/reactive/" against 18 .json files in that directory — the three ev_debug_* fixtures are exactly the missing three. A second, independent wall stands behind it: the event's character_id and all three of its morale modifiers point at "char_debug_eng_a", which is created only inside _seed_debug_characters (character_registry.gd:631) — and that function is gated behind `const DEBUG_SEED := false` (character_registry.gd:26, call site :37-38), so it never runs. Even if the loader skip were removed today, the card would mount with no speaker strip and three dead modifiers. Only reachable through the screenshot harness seam EventManager.debug_build_event_from_file (event_manager.gd:981-991), which explicitly bypasses the pool and never queues anything.
FIRES         If it were loaded: AND of (1) day_min 3 — GameState.day >= 3 (event_manager.gd:375); (2) random 0.30/day (event_manager.gd:385, intercepted upstream at :510-515). It has a random trigger, so it would take the hourly ambient path (event_manager.gd:88-115); with NO allowed_hours, _window_length_hours returns 24 (event_manager.gd:546-547) and the per-hour probability would be hourly_chance(0.30, 24) = 1 − 0.7^(1/24) = 0.0147514, i.e. 1.475 % per hour, 24 rolls reproducing 30 %/day. It carries no build_phase condition and no "build_safe" tag, so _is_eligible step 2 (event_manager.gd:468-481) would silence it for the whole duration of any active build — which is precisely the leak the loader skip was written to close (see the comment at event_manager.gd:882-885: "a 'çalışan event'i with zero employees", Faz 1 bug 1.4).
FREQUENCY     repeatable with cooldown 14 — and both latches would be REAL, because this is a pool event that would pass through _is_eligible (one_shot guard at event_manager.gd:485-489, cooldown guard at :491-498), not an enqueue()-injected card. one_shot: false, cooldown_days: 14. At the authored 0.30/day the expected re-fire interval would be 14 + ~3.3 ≈ 17 days. Never fires today: PROBE TALLY has no row for it.
```

**TITLE (TR)** Mühendisin mola istiyor  ·  **TITLE (EN)** MISSING
**SUBTITLE (TR)** Ofis · 18:30 [DEBUG]  ·  **(EN)** MISSING
**ALLOWED HOURS** NONE — no allowed_hours field, so _hour_windows has no entry and _is_hour_in_window returns true for every hour (event_manager.gd:523-527). The subtitle nevertheless stamps "18:30", a clock the engine would not honour: on the hourly path the card could mount at any hour of the 24, hour 00 included.
**PRIORITY** 0

**BODY (TR)**

> **Debug Engineer A** son sprint'i bitirip masada uyukladı. Sabah erken geldi, akşam geç çıkıyor. Bir kahve daha içip 'tamam' diyor — ama gözleri *biraz çukurlanmış*. [DEBUG content]

**BODY (EN)**

> MISSING

**CHOICE 1** — `Bu hafta izin ver` / `MISSING`

  - **EFFECTS** `morale` — {"type": "morale", "character_id": "char_debug_eng_a", "delta": 5}
    NOTHING. event_manager.gd:571-586 → CharacterRegistry.get_character("char_debug_eng_a") returns null because DEBUG_SEED is false (character_registry.gd:26, 37-38), so the dispatcher takes the null branch: push_warning("[EventManager] morale modifier targets unknown character: char_debug_eng_a") at event_manager.gd:575 and `continue`. No morale value anywhere changes, no signal fires. The HRMoraleSystem.apply_delta path (trait multiplier, founder Liderlik CLIMATE coefficient) is never reached.
  - **EFFECTS** `cash` — {"type": "cash", "delta": -2000}
    event_manager.gd:565 → GameState.set_cash(GameState.cash - 2000). This one DOES land. Against STARTING_CASH = 10,000 (founder_constants.gd:79) it is 20 % of the opening capital; at the run's early burn of $50/day it is 40 days of runway.
  - **DURATION** cash −$2,000 one-time and permanent; the morale leg has no duration because it never occurs
  - **CHIP** Two chips: "Moral +5" (positive) · "Nakit -$2.0K" (negative). The morale chip reads "Moral" and not a first name because _char_first cannot resolve the id and falls back to TranslationServer.translate("EFFECT_MORALE") = "Moral" (event_modal.gd:589-596). EN would be "Morale +5" · "Cash -$2.0K". Note the money format: _fmt_money_delta(−2000) takes the 1000..9999 branch → String.num(2.0, 1) → "-$2.0K" with a raw ASCII decimal point, not locale-swapped.
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**CHOICE 2** — `Deadline'a kadar bastır` / `MISSING`

  - **EFFECTS** `morale` — {"type": "morale", "character_id": "char_debug_eng_a", "delta": -3}
    NOTHING — same null branch at event_manager.gd:573-576, same push_warning, same `continue`. The option's entire declared cost evaporates.
  - **EFFECTS** `brand` — {"type": "brand", "delta": 1}
    event_manager.gd:567 → GameState.set_brand(GameState.brand + 1), clamped 0-100 (game_state.gd:326-328). This one lands, and it is the only thing this option does.
  - **DURATION** Brand +1, permanent (clamped stat write), re-armed every 14 days by the cooldown
  - **CHIP** Two chips: "Moral -3" (negative) · "Marka +1" (positive). EN: "Morale -3" · "Brand +1". The first chip badges a cost the dispatcher provably skips.
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**CHOICE 3** — `Yardımcı bir mühendis daha al` / `MISSING`

  - **EFFECTS** `cash` — {"type": "cash", "delta": -8000}
    event_manager.gd:565 → GameState.set_cash(GameState.cash - 8000). Lands in full. 80 % of STARTING_CASH (10,000); at the run's day-3 cash of 8,100 (PROBE STATE day=3) it would leave $100.
  - **EFFECTS** `morale` — {"type": "morale", "character_id": "char_debug_eng_a", "delta": 3}
    NOTHING — the same null branch at event_manager.gd:573-576. And critically, NO ENGINEER IS HIRED: there is no add_character modifier here (the type exists at event_manager.gd:596 but has zero producers anywhere in the codebase) and no HRSystem seam is called. The option deducts $8,000 and adds nobody.
  - **DURATION** cash −$8,000 one-time and permanent; the morale leg never occurs; the hire never occurs
  - **CHIP** Two chips: "Nakit -$8.0K" (negative) · "Moral +3" (positive). EN: "Cash -$8.0K" · "Morale +3".
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — one_shot: false with cooldown_days: 14, and as a pool event both would be genuinely enforced by _is_eligible (event_manager.gd:485-498) rather than inert. Choice 1's free +1 brand therefore re-arms every 14 days; at 0.30/day the expected interval is ~17 days, so roughly 10 fires over 180 days = +10 brand, cumulative, for a cost the engine refuses to charge. Brand's 0-100 clamp (game_state.gd:327) makes it saturate rather than run away, but from the 50 baseline it is still a fifth of the remaining headroom for nothing.
- **PERMANENT SWING** — Choice 2's one-click −$8,000 is 80 % of the game's entire opening capital (STARTING_CASH = 10,000, founder_constants.gd:79) and, at the $50/day burn observed through the run's first three weeks, 160 days of runway — with nothing whatsoever received in return (no hire, no morale). Choice 0's −$2,000 is 40 days. Cash is unclamped (game_state.gd:309-312) and there is no recovery path at day 3. Choice 1's brand +1 is permanent in the other direction and, given the 14-day cooldown, cumulative.
- **FREE LUNCH** — Choice 1 ("Deadline'a kadar bastır") pairs a live, permanent brand +1 with a morale −3 that cannot land — CharacterRegistry has no char_debug_eng_a (DEBUG_SEED := false, character_registry.gd:26), so event_manager.gd:573-576 push_warns and skips. The option is a costless +1 brand, and the modal still badges "Moral -3" as though a price had been paid. Counterfactual, not live, since the card is unreachable.
- **MAGNITUDE** — day_min is 3, so the earliest legal fire is day 3 — when the recorded run held cash 8,100 with MRR 0 and a $50/day burn (PROBE STATE day=3 cash=8100 mrr=0 burn=50). Choice 2's −$8,000 would leave $100 in the bank on day 3 and end the run inside two days; choice 0's −$2,000 removes 40 days of runway. Neither number was ever scaled to the shipped economy: they read as figures written for a company with employees and revenue, and this card can fire before either exists.
- **INVISIBLE** — All three morale modifiers are invisible in the strict sense — the effect never surfaces anywhere the player can see, because it never occurs. CharacterRegistry.get_character returns null, the dispatcher `continue`s, no morale value changes and no EventBus signal fires. The card's own character_id has the same fate on the presentation side: EventModal._render_registry_character push_warns at event_modal.gd:256 and leaves _speaker_row.visible = false, so a card that names "Debug Engineer A" in bold body text renders with no face, no name strip and no trait badges.
- **DEAD REFERENCE** — Four dead references on one card. The event-level character_id "char_debug_eng_a" and all three morale modifiers' character_id point at a Character that exists only inside _seed_debug_characters (character_registry.gd:631), a function gated behind `const DEBUG_SEED := false` (character_registry.gd:26) and therefore never executed. Every reference to that id in this file is dead in both the dispatcher (event_manager.gd:573-576) and the modal (event_modal.gd:253-256).
- **COPY LIE** — Three. (a) "Yardımcı bir mühendis daha al" — hire another engineer — hires nobody: there is no add_character modifier (that type has zero producers game-wide) and no HRSystem call; it deducts $8,000 and stops. (b) "Bu hafta izin ver" — give them the week off — starts no leave: HRLeaveSystem is untouched, no leave_month is written; it deducts $2,000. (c) All three chips promise a morale movement ("Moral +5", "Moral -3", "Moral +3") that event_manager.gd:573-576 provably skips, so every row on this card advertises a number that never lands.
- **VOICE** — Engineering markers printed straight to the player: "[DEBUG]" in the subtitle and "[DEBUG content]" closing the body, with the character named in bold as "Debug Engineer A". "Deadline'a kadar bastır" leaves an untranslated English noun with a Turkish suffix in a player-facing label. The body carries an em dash ("diyor — ama gözleri"), against the project's live dash ban. And the subtitle stamps "18:30" on a card with no allowed_hours, so on the hourly path it could mount at any hour, midnight included. There is no EN sibling at any level (title_en, subtitle_en, body_text_en and all three label_en are ABSENT, not empty) — exempt from the BILINGUAL BIRTH LAW by director ruling, per the comment at endgame_smoke.gd:7025-7028, but it means the card would render Turkish-only to an English player if it were ever wired.

<details><summary>Flags checked and not applicable (3)</summary>

- *NO OP* — No option is wholly empty — each still moves cash or brand. But every option's morale half is individually a no-op: three of the six modifiers on this card do nothing at all.
- *IDENTICAL OPTIONS* — The three rows differ in their live legs: −$2,000, +1 brand, −$8,000. Once the dead morale modifiers are discounted they are still three distinct outcomes.
- *BLIND* — Every modifier on every row produces a chip — morale at event_modal.gd:493, cash at :489, brand at :491. Nothing reaches the terminal `return {}`. The failure here is the opposite of blindness: the card badges effects that do not happen.

</details>

**Notes.** Correctly quarantined, and the quarantine is load-bearing: this card is the reason the ev_debug_ skip exists (event_manager.gd:882-885 names it — Faz 1 bug 1.4, a staff event firing at zero employees). Two independent walls now stand between it and a player, and either alone would suffice. The entry is worth keeping in the ledger because the failure modes it embodies are the ones a future authored HR card is most likely to repeat: a modifier addressed to a character id that no longer exists renders a confident chip and silently does nothing, and the dispatcher's only complaint is a push_warning nobody reads at runtime. If the DEBUG fixtures are ever revived as screenshot subjects, the morale rows will need re-pointing at a live id or they will photograph as lies.

---

### ev_debug_002_press_inquiry

```
FILE          data/events/reactive/ev_debug_002_press_inquiry.json (DEBUG fixture, pool JSON, no builder function)
CATEGORY      world (press/brand debug fixture)
REACHABLE     NO — skipped by filename at load. _load_all_events_from_disk short-circuits on `filename.begins_with("ev_debug_")` before _load_one is ever called (event_manager.gd:886-887), so the card never enters _all_events and cannot reach eligibility, the queue or _history. Run-log corroboration: "[EventManager] Loaded 15 events from res://data/events/reactive/" against 18 files on disk. Unlike its sibling ev_debug_001 there is no second wall — character_id is empty and every modifier type it uses is live, so this card would work the moment the prefix skip were lifted, which is what makes its numbers worth recording. Reachable only through the screenshot seam EventManager.debug_build_event_from_file (event_manager.gd:981-991), which never queues.
FIRES         If it were loaded: AND of (1) day_min 5 — GameState.day >= 5 (event_manager.gd:375); (2) random 0.20/day (event_manager.gd:385, intercepted at :510-515). Having a random trigger it would take the hourly ambient path (event_manager.gd:88-115); with NO allowed_hours, _window_length_hours returns 24 (event_manager.gd:546-547), so each hour would roll hourly_chance(0.20, 24) = 1 − 0.8^(1/24) = 0.0092555 (0.926 % per hour), 24 rolls reproducing the authored 20 %/day. No build_phase condition and no "build_safe" tag, so _is_eligible step 2 would silence it for the entire duration of any active build (event_manager.gd:468-481) — which in a normal opening is days 2-24.
FREQUENCY     repeatable with cooldown 21 — and both latches would be REAL, since a pool event passes through _is_eligible's one_shot guard (event_manager.gd:485-489) and cooldown guard (:491-498) rather than being injected past them by enqueue(). one_shot: false, cooldown_days: 21. At 0.20/day the expected re-fire interval is 21 + 5 = 26 days, so about 7 fires per 180 days. Never fires today: no PROBE TALLY row.
```

**TITLE (TR)** Basın arıyor  ·  **TITLE (EN)** MISSING
**SUBTITLE (TR)** TeknoGündem e-postası · 11:14 [DEBUG]  ·  **(EN)** MISSING
**ALLOWED HOURS** NONE — no allowed_hours field, so _hour_windows holds no entry and _is_hour_in_window passes every hour (event_manager.gd:523-527). The subtitle stamps "11:14" anyway, a clock the engine would not honour: on the hourly path the card could mount at any hour including 00.
**PRIORITY** 0

**BODY (TR)**

> TeknoGündem muhabiri bir alıntı istiyor: *son altı ayda 'AI startup'ları nasıl ayakta kalır?'* Cevabın yarın yayınlanacak. [DEBUG content]

**BODY (EN)**

> MISSING

**CHOICE 1** — `Hazırlanmış, ölçülü bir açıklama gönder` / `MISSING`

  *desc:* Ölçülü ton. Yarınki manşette kontrol sende kalır. / MISSING

  - **EFFECTS** `brand` — {"type": "brand", "delta": 3}
    event_manager.gd:567 → GameState.set_brand(GameState.brand + 3), clamped 0-100 (game_state.gd:326-328). Brand's live readers: the Series A phase gate requires brand_above 24 (phase_gate_system.gd:63) and the brand-collapse ending fires when brand stays under BRAND_COLLAPSE_FLOOR = 15 for 30 days (endings_system.gd:28-29, 112-113).
  - **EFFECTS** `reputation` — {"type": "reputation", "delta": 1}
    event_manager.gd:569 → GameState.set_reputation(GameState.reputation + 1), clamped −10..100 (game_state.gd:330-334). The run baseline is 0 (game_state.gd:35, :764). This is also the key that eventually unlocks this same card's third option.
  - **DURATION** Both permanent (clamped stat writes), and both re-armed every 21 days by the cooldown
  - **CHIP** Two chips: "Marka +3" (positive) · "İtibar +1" (positive). EN: "Brand +3" · "Reputation +1". This row is also the MENTOR PICK — mentor_choice: 0 with a mentor_line present, so the modal wraps it in the ChoiceCardMentor variation and a mentor tab (event_modal.gd:370-375), i.e. Frank's endorsement points at the free option.
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**CHOICE 2** — `Yorum yapmayı reddet` / `MISSING`

  - **EFFECTS** `brand` — {"type": "brand", "delta": -2}
    event_manager.gd:567 → GameState.set_brand(GameState.brand - 2), clamped 0-100. The option's entire content.
  - **DURATION** Brand −2, permanent
  - **CHIP** One chip: "Marka -2" (negative). EN "Brand -2".
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**CHOICE 3** — `Sıcağı sıcağına konuş` / `MISSING`

  *desc:* Riskli ama akılda kalır. / MISSING

  - **EFFECTS** `brand` — {"type": "brand", "delta": 6}
    event_manager.gd:567 → GameState.set_brand(GameState.brand + 6), clamped 0-100. The option's ONLY modifier — there is no counterweight of any kind despite the description promising risk.
  - **DURATION** Brand +6, permanent, and re-armed every 21 days
  - **CHIP** WHEN UNLOCKED: one chip, "Marka +6" (positive) / EN "Brand +6". WHEN LOCKED (the default — reputation starts at 0): no effect chips render at all; event_modal.gd:419-425 replaces the whole chip column with a single neutral badge carrying the unlock reason, so the player sees "Reputation 10+ gerekli" and the row greyed to 50 % alpha with input disabled.
  - **UNLOCK** unlock_condition {"type": "reputation_above", "value": 10} — evaluated live at render by EventManager.is_condition_met via event_modal.gd:368. The arm at event_manager.gd:383 is STRICT (`>`), so the real bar is reputation 11, not 10. unlock_reason_text: "Reputation 10+ gerekli"

**FLAGS** — REPEATABLE COMPOUND, PERMANENT SWING, FREE LUNCH, MAGNITUDE, COPY LIE, VOICE

- **REPEATABLE COMPOUND** — The worst instance in this family. one_shot: false, cooldown_days: 21, and as a pool event both are genuinely honoured by _is_eligible (event_manager.gd:485-498). Choice 2 is +6 brand at zero cost every ~26 days (21 cooldown + ~5 expected at 0.20/day): about 7 fires per 180 days = +42 brand, which is the whole distance from the 50 baseline to the 100 clamp. And it bootstraps itself — choice 0's reputation +1, also free and also repeatable, is exactly the resource that unlocks choice 2 (reputation_above 10), so the card manufactures the key to its own strongest row.
- **PERMANENT SWING** — Brand and reputation are permanent, clamped stat writes with no decay. Brand gates two run-shaping outcomes: the Series A gate requires brand_above 24 (phase_gate_system.gd:63) and the brand-collapse ending terminates the run below 15 for 30 days (endings_system.gd:28-29, 112-113). Choice 2's +6 in one click is 12 % of the entire 0-100 band. The context that makes this severe: brand did not move once in the recorded 275-day run — PROBE STATE reads brand=50 on every single line from day 1 to day 275 — so any brand producer is a swing on an otherwise frozen stat.
- **FREE LUNCH** — Two of the three rows are costless upside. Choice 0 is brand +3 and reputation +1 with no cash, no morale, no time, no flag — nothing at all on the debit side. Choice 2 is brand +6 with a single modifier and no counterweight, while its own description advertises "Riskli ama akılda kalır" (risky but memorable) — the risk exists only in the prose. The card compounds the problem by pointing at the free option: mentor_choice: 0 makes Frank endorse it, so the game's own advisor recommends the costless row.
- **MAGNITUDE** — Brand starts at 50 and, in the recorded run, never moved from it across all 275 days. Into that frozen stat this card puts +6 in a single click for free — 12 % of the whole band, and a quarter of the distance between the brand-collapse floor (15) and the baseline. day_min is 5, so it can land in the first week, before there is a product, a customer or a dollar of revenue. Nothing about a press quote in week one justifies a permanent sixth of the Series A brand requirement, repeatable every three weeks.
- **COPY LIE** — (a) The body states "Cevabın yarın yayınlanacak" — your answer will be published tomorrow — and choice 0's description promises "Yarınki manşette kontrol sende kalır", you keep control of tomorrow's headline. Nothing is published: the card writes no flag, queues no follow-up event, and does not touch NewsFeedSystem, which is the system that actually owns the ticker. Tomorrow arrives with no headline. (b) Choice 2's description reads "Riskli ama akılda kalır" but its modifier list is a single unconditional brand +6 — there is no risk arm, no downside branch, no roll. (c) The unlock_reason_text says "Reputation 10+ gerekli" while the condition is reputation_above: 10, and that arm is strict (event_manager.gd:383), so the real requirement is 11. The card misstates its own gate by one.
- **VOICE** — "[DEBUG]" in the subtitle and "[DEBUG content]" closing the body are engineering markers in player-facing copy. The unlock reason "Reputation 10+ gerekli" mixes an English stat name into a Turkish sentence where every shipped surface uses "İtibar" (strings.csv EFFECT_REPUTATION). The body leaves "AI startup'ları" untranslated mid-sentence. The subtitle stamps a clock ("11:14") on a card with no allowed_hours, so it could mount at any hour including 00. And no EN sibling exists at any level — title_en, subtitle_en, body_text_en and all three label_en/description_en are ABSENT rather than empty (exempt by director ruling per endgame_smoke.gd:7025-7028, but Turkish-only if ever wired).

<details><summary>Flags checked and not applicable (5)</summary>

- *NO OP* — Every option writes at least one live stat through a live dispatcher arm. Nothing here is empty or silently skipped.
- *IDENTICAL OPTIONS* — +3 brand/+1 reputation, −2 brand, and +6 brand are three distinct effect sets.
- *BLIND* — Every modifier resolves to a chip — brand at event_modal.gd:491, reputation at :492. Nothing reaches the terminal `return {}`. Worth noting the locked row shows no effect chips at all, but that is deliberate (event_modal.gd:419-425 swaps the chip column for the unlock-reason badge) and applies to every locked choice in the game.
- *INVISIBLE* — Brand and reputation both have live readers (phase_gate_system.gd:63, endings_system.gd:112-113) and player-facing surfaces (the HUD stats, and the Series A gate's requirement list at phase_gate_system.gd:211 and finance_ozet_view.gd:203).
- *DEAD REFERENCE* — brand (event_manager.gd:567) and reputation (:569) both have live dispatcher arms; day_min (:375), random (:385) and reputation_above (:383) are all live condition types. Unlike ev_debug_001 this card names nothing that does not exist.

</details>

**Notes.** The most dangerous of the three quarantined fixtures, because unlike ev_debug_001 nothing but the filename stands between it and a live pool: character_id is empty, every modifier type and every condition type it uses is live, and it would work perfectly the day someone renamed the file. The free repeatable +6 brand is the single largest costless economic lever anywhere in the audited content, and the card's own free reputation row is the key to it. If these fixtures are ever revived for screenshots, this one needs its numbers cut and a real cost arm on the third row before it goes anywhere near data/events/reactive/ under a non-debug name.

---

### ev_debug_003_cash_warning

```
FILE          data/events/reactive/ev_debug_003_cash_warning.json (DEBUG fixture, pool JSON, no builder function)
CATEGORY      founder / mentor (Frank speaks; cash-crisis debug fixture)
REACHABLE     NO — skipped by filename at load. _load_all_events_from_disk hits `if filename.begins_with("ev_debug_"): pass` before _load_one (event_manager.gd:886-887), so it never enters _all_events, eligibility, the queue or _history. The run log's boot line confirms the arithmetic: "[EventManager] Loaded 15 events" against 18 .json files in data/events/reactive/. Its speaker WOULD resolve if wired — char_mentor_frank is created unconditionally by CharacterRegistry.ensure_mentor from GameState.initialize_run (character_registry.gd:392-408) — so the loader skip is the only thing holding it. Reachable otherwise only via the screenshot seam EventManager.debug_build_event_from_file (event_manager.gd:981-991), which never queues.
FIRES         If it were loaded: a single condition, cash_below 30000 — GameState.cash < 30,000 (event_manager.gd:378). There is no random trigger, so has_random_trigger() returns false (event.gd:84-93) and it would take the DAILY BEAT path (daily_tick, event_manager.gd:62-79), firing the moment its condition holds rather than waiting on any roll. The condition holds ON DAY ONE: STARTING_CASH is 10,000 (founder_constants.gd:79), confirmed by PROBE STATE day=1 cash=10000. At priority 10 it would sort ahead of every other beat (event_manager.gd:124-135). The one thing that would defer it is _is_eligible step 2 — it carries no build_phase condition and no "build_safe" tag, so any active build silences it (event_manager.gd:468-481); in the recorded run the first build starts on day 2, so the card's window is day 1, then reopens whenever no build is running.
FREQUENCY     one-shot, and the latch would be REAL — this is a pool event, so _is_eligible's history guard at event_manager.gd:485-489 genuinely enforces one_shot: true (unlike enqueue()-injected cards, where the field is inert). cooldown_days: 0 is therefore moot. Fires at most once per run; never fires today (no PROBE TALLY row).
```

**TITLE (TR)** Frank arıyor — runway  ·  **TITLE (EN)** MISSING
**SUBTITLE (TR)** Telefon · 09:45 [DEBUG]  ·  **(EN)** MISSING
**ALLOWED HOURS** NONE — no allowed_hours field, so _hour_windows has no entry and the window gate passes unconditionally (event_manager.gd:523-527). It matters more here than on its siblings: as a BEAT it is evaluated by daily_tick, which runs at the day boundary, i.e. hour 00. The subtitle nevertheless stamps "09:45" and the body opens "Frank sabah ilk işi aradı" — a card that would always fire at midnight insisting it is first thing in the morning.
**PRIORITY** 10 — the highest in the whole reactive pool, tied only with ev_seed_closed. On the beat path it would be queued ahead of every other eligible event on the day it fires.

**BODY (TR)**

> Frank sabah ilk işi aradı. *'Şu kasaya bir bak,'* diyor. **Üç haftalık runway**. Bir şey kesmek gerekiyor — ama hangisi? [DEBUG content]

**BODY (EN)**

> MISSING

**CHOICE 1** — `Tool harcamasını kıs (acılı)` / `MISSING`

  - **EFFECTS** `cash` — {"type": "cash", "delta": 5000}
    event_manager.gd:565 → GameState.set_cash(GameState.cash + 5000). Cash is unclamped (game_state.gd:309-312) and no ledger entry, no FinanceSystem seam and no recurring-cost change accompanies it — the money is minted at the point of the click. Against STARTING_CASH 10,000 that is a 50 % capital increase; at the run's observed early burn of $50/day it is 100 additional days of runway.
  - **EFFECTS** `morale_all_employees` — {"type": "morale_all_employees", "delta": -3}
    event_manager.gd:587-589 → `for emp in CharacterRegistry.get_employees(): HRMoraleSystem.apply_delta(emp, -3, "event")`. get_employees returns every Character whose category is "employee" (character_registry.gd:54-61). At the moment this card can fire the founder is alone — PROBE STATE reads emp=0 from day 1 through day 54 of the recorded run — so the loop body never executes and the declared cost is exactly zero. No morale changes, no signal fires.
  - **DURATION** cash +$5,000 one-time and permanent (never repaid, no offsetting ledger entry); the morale leg has no duration because with zero employees it never occurs
  - **CHIP** Two chips: "Nakit +$5.0K" (positive; _fmt_money_delta(5000) takes the 1000..9999 branch → String.num(5.0, 1) → "+$5.0K", raw ASCII decimal point) · "Ekip -3" (negative). EN: "Cash +$5.0K" · "Team -3".
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**CHOICE 2** — `Küçük bir köprü turu denesem? [NOT IMPLEMENTED]` / `MISSING`

  - **EFFECTS** none — the modifiers array is empty
  - **DURATION** one-time — but there is nothing to time: the modifiers array is empty
  - **CHIP** NONE — and not because a modifier lacks a chip builder, but because there are no modifiers at all. In any case the row renders LOCKED: event_modal.gd:419-425 dims it to 50 % alpha, sets MOUSE_FILTER_IGNORE and FOCUS_NONE, and puts one neutral badge in the chip column reading "VC sistemi henüz yok".
  - **UNLOCK** unlock_condition {"type": "phase", "value": 99} — evaluated at render by is_condition_met (event_modal.gd:368 → event_manager.gd:377, exact equality GameState.phase == 99). GameState.phase is clamped to 1-3 in BOTH write seams (game_state.gd:355 and :366), so this is structurally unsatisfiable for the entire life of the game. unlock_reason_text: "VC sistemi henüz yok"

**CHOICE 3** — `Mevcut yolda devam et, sayıları izle` / `MISSING`

  - **EFFECTS** none — the modifiers array is empty
  - **DURATION** none — the modifiers array is empty
  - **CHIP** NONE. The row is UNLOCKED (unlock_condition {} → is_condition_met returns true, event_manager.gd:369-370), so it renders as a normal, full-opacity, clickable choice card with hover states — and an entirely empty chip column, because _make_effect_chips iterates an empty array (event_modal.gd:429-437).
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**FLAGS** — PERMANENT SWING, FREE LUNCH, MAGNITUDE, NO OP, IDENTICAL OPTIONS, INVISIBLE, DEAD REFERENCE, COPY LIE, VOICE

- **PERMANENT SWING** — One click, one-time, and permanent in effect: cash is unclamped (game_state.gd:309-312), nothing repays it, no recurring cost changes and no ledger entry offsets it. +$5,000 against STARTING_CASH 10,000 is a 50 % capital increase, and at the $50/day burn observed through the run's first three weeks it is 100 extra days of runway handed over on day 1. Nothing else in the shipped economy moves cash by half in a single click — Frank's angel cheque, the largest sanctioned injection, is $25,000 and costs 4 % of the company (AngelRoundSystem.CASH_AMOUNT / EQUITY_PCT).
- **FREE LUNCH** — Choice 0 mints $5,000 out of nothing. Its sole declared counterweight — morale_all_employees −3 — loops over CharacterRegistry.get_employees() (event_manager.gd:587-588), and at the only moment this card can fire the player has no employees at all (PROBE STATE emp=0 from day 1 to day 54). The loop body never runs, so the price is zero while the chip still reads "Ekip -3". A costless +50 % to the entire capital of the company.
- **MAGNITUDE** — The gate is cash_below 30000 and the game begins at 10,000 (founder_constants.gd:79; PROBE STATE day=1 cash=10000), so this card is eligible on the very first daily tick — at priority 10, ahead of every other beat. On day 1 it hands the player +$5,000 against a $50/day burn: half of all the money in the game, 100 days of runway, before a product exists. For scale, the shipped v1 build in the recorded run cost $1,800 to commit; this single click funds nearly three of them. The number was written for a company with employees and a payroll to cut, and the card fires at the one moment when neither exists.
- **NO OP** — Choice 2, "Mevcut yolda devam et, sayıları izle", carries "modifiers": [] — an empty array. It renders as a normal unlocked clickable card with hover states and a completely empty chip column, and clicking it changes nothing whatsoever. Its only mechanical consequence is that resolve_choice appends to _history (event_manager.gd:212), which consumes the one_shot so the card never returns.
- **IDENTICAL OPTIONS** — Choices 1 and 2 both carry "modifiers": [] — literally the same (empty) effect set. Two of the three rows on this card do exactly the same thing, which is nothing. They differ only in presentation: choice 1 is permanently locked behind an unsatisfiable phase==99 gate and greys out, choice 2 is clickable. The player is offered a three-way decision in which two branches are indistinguishable in outcome.
- **INVISIBLE** — Choice 0's morale_all_employees −3 never surfaces anywhere the player can see, because with zero employees the dispatcher's for-loop body at event_manager.gd:588 never executes: no morale value changes, no EventBus signal fires, no HR surface updates. The chip "Ekip -3" is rendered regardless, so the card displays a cost that provably does not exist.
- **DEAD REFERENCE** — Choice 1's unlock_condition is {"type": "phase", "value": 99}. GameState.phase is clamped to 1-3 in both of its write seams — set_phase at game_state.gd:355 and advance_phase at :366 — so the condition is unsatisfiable for the life of the game and the row is permanently dead. Its reason text is stale on top of that: "VC sistemi henüz yok" says the VC system does not exist yet, and it does — VCPitchSystem, the meeting scene and TermSheetTableScene are all shipped.
- **COPY LIE** — Three, and the first is the worst number in the audit. (a) The body asserts "**Üç haftalık runway**" in bold as a fact. The card's own gate is cash < 30,000 and it will normally fire on day 1 at cash 10,000 against a $50/day burn — that is 200 days, roughly twenty-eight weeks, not three. The card states the player's runway and is wrong by nearly an order of magnitude, on the one stat the whole scene is about. (b) "Tool harcamasını kıs" claims a spending cut, and the engine credits a $5,000 lump sum with no change to any recurring cost: FinanceSystem's burn is untouched, so the burn line reads exactly the same the following day. (c) The chip "Ekip -3" claims a team morale cost that, at the only moment this card can fire, provably does not occur.
- **VOICE** — "[NOT IMPLEMENTED]" is printed inside a player-facing choice label, and "[DEBUG content]" and "[DEBUG]" inside the body and subtitle — engineering state shown to the player as fiction. The character_id is char_mentor_frank, which DOES resolve (ensure_mentor, character_registry.gd:392-408), so the modal renders Frank's avatar, name and role strip (event_modal.gd:253-266) — and then the body opens with third-person stage direction about him, "Frank sabah ilk işi aradı … diyor": narration about the speaker inside the speaker's own card. The title "Frank arıyor — runway" carries an em dash and leaves an English noun untranslated. The subtitle stamps "09:45" and the body says "sabah ilk işi" on a card that takes the daily BEAT path and therefore always resolves at hour 00. And there is no EN sibling at any level (all *_en ABSENT, exempt by director ruling per endgame_smoke.gd:7025-7028).

<details><summary>Flags checked and not applicable (2)</summary>

- *REPEATABLE COMPOUND* — one_shot: true on a POOL event, so _is_eligible's history guard (event_manager.gd:485-489) genuinely binds and the gift can be taken at most once per run. cooldown_days: 0 is moot behind it. It is a one-time break in the economy, not a compounding one.
- *BLIND* — Choice 0's two modifiers both produce chips (cash at event_modal.gd:489, morale_all_employees at :494). Choices 1 and 2 have no modifiers, so there is no effect a chip could fail to disclose — an empty chip column there is honest, if uninformative.

</details>

**Notes.** Correctly quarantined, and the only fixture that would break the game outright on day 1 if the prefix skip were lifted: a priority-10 beat whose condition is true at start, offering +50 % capital for a cost the engine cannot charge. It is also the family's densest cluster of flags — eight of eleven — and the clearest illustration of why the ev_debug_ skip is worth more than a comment. Two findings here generalise beyond the fixture and are worth carrying into any future authored card: an unlock_condition on a clamped field (phase==99) is dead forever and nothing in the toolchain warns about it, and morale_all_employees is silently free whenever the team is empty, which in this game is the entire opening act.

---

### ev_seed_closed

```
FILE          data/events/unwired/ev_seed_closed.json (unwired JSON, no builder function — deliberately outside the loader's reach)
CATEGORY      founder / mentor (Frank speaks; funding-round confirmation beat)
REACHABLE     NO, and structurally rather than by luck. EventManager.EVENTS_DIR is a single constant, "res://data/events/reactive/" (event_manager.gd:32); _load_all_events_from_disk opens exactly that one directory with DirAccess and does NOT recurse into subdirectories (event_manager.gd:873-891); and nothing else in the codebase opens data/events/ at all. A file in unwired/ therefore never reaches _all_events, which means it never reaches _is_eligible, the queue or _history. The project asserts this in its own smoke suite: endgame_smoke.gd:9003 _case_unwired_dir_is_never_pooled reads every id off disk in res://data/events/unwired and fails if any of them is in the live pool ("%s is IN THE LIVE POOL — the unwired directory is being loaded", endgame_smoke.gd:9026). Behind that stands a second, design-level wall: there is no seed round anywhere in the game for this card to confirm. The only funding rungs that exist are Frank's fixed $25,000 angel cheque (AngelRoundSystem) and Series A — stated in the project's own words at docs/writing/FRANK_UNWIRED.md:47-49 and data/events/unwired/README.md. It has no PROBE TALLY row and never could.
FIRES         NEVER, as shipped. Its trigger_conditions array is EMPTY — and that is worth stating precisely, because empty does not mean inert: is_condition_met is never consulted, the for-loop in _is_eligible step 5 (event_manager.gd:506-517) iterates zero times and falls through to `return true`. It also has no random trigger, so has_random_trigger() returns false (event.gd:84-93) and it would take the daily BEAT path (event_manager.gd:62-79). If this file were moved into data/events/reactive/ unchanged it would therefore be eligible on the FIRST daily tick and fire on day 1 at priority 10, ahead of everything else — the failure mode the directory's own README warns about in bold ("trigger_conditions: [] means always eligible and fires on day 1"). The tag "build_safe" is live vocabulary (event_manager.gd:472, event.gd:80-81) and would exempt it from the active-build gate, removing even that accidental delay.
FREQUENCY     one-shot — and the latch would be real if it were ever pooled, since a JSON pool event passes through _is_eligible's history guard at event_manager.gd:485-489 rather than being injected past it by enqueue(). cooldown_days: 0, moot behind the one-shot. Today the frequency is zero: the file is not in the loader's directory, so no latch of any kind is ever consulted.
```

**TITLE (TR)** Para hesapta  ·  **TITLE (EN)** The money's in
**ALLOWED HOURS** NONE — no allowed_hours field, so _hour_windows would hold no entry and _is_hour_in_window would pass every hour (event_manager.gd:523-527). No clock appears anywhere in the copy either: subtitle is "" in both locales and the body names no time of day, so unlike every other card in this family there is nothing for the engine to contradict. On the beat path it would resolve at hour 00, and the copy would still read correctly.
**PRIORITY** 10 — tied with ev_debug_003 for the highest in any reactive JSON. Inert while unwired, but it means a careless move into reactive/ would put this card at the very front of the day-1 queue.

**BODY (TR)**

> Bu turu başarıyla atlattık. Para hesapta.
>
> Frank'ten mesaj.
>
> "Tamam, bunu cebe koyduk. Bu para dursun diye gelmedi, büyüyeceğiz. Series A masasına oturduğumuzda elimiz daha güçlü olmalı."

**BODY (EN)**

> You got through the round. The money is in the account.
>
> A message from Frank.
>
> "Good, money in the bank. It didn't come in to sit there, we grow with it. By the time we sit down for Series A we need to be in a stronger position."

**CHOICE 1** — `Tamam` / `All right`

  - **EFFECTS** none — the modifiers array is empty
  - **DURATION** none — the modifiers array is empty, so nothing is applied for any length of time
  - **CHIP** NONE. The modifiers array is empty, so _make_effect_chips iterates nothing (event_modal.gd:429-437) and the chip column renders bare. The row is unlocked (unlock_condition {} → is_condition_met returns true, event_manager.gd:369-370), full opacity, clickable, and dismisses the card.
  - **UNLOCK** NONE — unlock_condition {}; unlock_reason_text ""

**FLAGS** — NO OP, COPY LIE, VOICE

- **NO OP** — By the objective test: the only option carries "modifiers": [] and changes nothing. This is intentional and correctly so — the card is a confirmation beat, and the cash would be booked by the seed-round system it is waiting for, exactly the way AngelRoundSystem's angel_accept modifier owns cash, ledger, cap table and latch in one seam (event_manager.gd:764-770). But as the file stands it is a card the player can only dismiss, and if it were wired without also wiring the round it would announce money arriving while no money arrived.
- **COPY LIE** — "Bu turu başarıyla atlattık. Para hesapta." / "You got through the round. The money is in the account." asserts that a funding round closed and cash landed. No modifier moves cash, and no system in the game closes a seed round: the only rungs that exist are Frank's fixed $25,000 angel cheque and Series A. The project states this itself at docs/writing/FRANK_UNWIRED.md:47-49 ("there is no funding rung between Frank's $25,000 angel cheque and Series A, so there is no moment for this card to confirm"). Recorded as a live flag rather than waived because the text ships in the repository and is gated as shipped content — endgame_smoke.gd's loc_event_en_coverage scans unwired/ alongside reactive/ (endgame_smoke.gd:7030-7036) precisely so this directory is not treated as a drawer. The mitigation is real and should be read with the finding: the assertion becomes true the day the seed round exists, and the file is held inert until then by a mechanism a smoke case defends.
- **VOICE** — The card's character_id is char_mentor_frank, which resolves (ensure_mentor, character_registry.gd:392-408), so EventModal renders Frank's avatar, name and role strip (event_modal.gd:253-266) and the source badge reads MENTOR (event_modal.gd:234-235). The body then opens in the founder's voice — "Bu turu başarıyla atlattık", first person plural — and follows it with a stage direction naming Frank in the third person, "Frank'ten mesaj.", before he finally speaks in quotes. Two narrators and a scene-setting line inside a card the UI has already attributed to one named NPC. The locales also do not narrate from the same person: TR opens first-person plural ("atlattık", we got through it) where EN opens second-person ("You got through the round"), so the same beat is told by different voices in the two languages. Everything else here is clean — no dev markers, no dashes, no clock on a card with no window, and both locales are complete and reviewed.

<details><summary>Flags checked and not applicable (8)</summary>

- *FREE LUNCH* — The single option carries no modifiers at all, so there is no upside for a missing cost to be measured against. Nothing is granted.
- *PERMANENT SWING* — No modifiers, therefore no state change of any duration. Note the asymmetry with the copy, which asserts a large permanent swing (a funding round landing in the bank) — that mismatch is recorded under COPY_LIE, not here.
- *REPEATABLE COMPOUND* — one_shot: true, and unreachable regardless — the file is never loaded, so no latch is ever consulted and there is nothing to repeat.
- *IDENTICAL OPTIONS* — There is exactly one option, so no two can coincide.
- *BLIND* — Nothing happens, so there is no irreversible or run-shaping effect for a missing chip to conceal. An empty chip column over an empty modifier list is honest.
- *INVISIBLE* — No effect exists that could fail to surface. The card as a whole is invisible to the player, but that is the reachability finding above, not this flag, which tests effects.
- *MAGNITUDE* — There are no numbers in the effects to be out of band. The body does carry an implied magnitude — "Para hesapta" / "The money is in the account" — with no figure attached and no engine value behind it, which is a copy problem rather than a calibration one.
- *DEAD REFERENCE* — At the effect level there is nothing to be dead: the choice names no system, flag or field, and the event's "build_safe" tag is live vocabulary read by _is_eligible (event_manager.gd:472). The absence here is at the file level — the card's premise names a funding rung the engine has no system for — which is recorded under reachable and COPY_LIE.

</details>

**Notes.** The best-behaved file in the family and the one that needs no engine work. It is held inert by a mechanism that is structural rather than conditional — a single non-recursive EVENTS_DIR constant — and that mechanism is defended by a dedicated smoke case (endgame_smoke.gd:9003), while the text is still gated as shipped content by loc_event_en_coverage so it cannot rot into a Turkish-only card before it is wired. Both flags raised against it are copy-level and both resolve the same way, in the one body rewrite that FRANK_UNWIRED.md:60-64 already schedules for the day the seed round is designed: give the narration a single owner, and let the round's own seam book the cash the way angel_accept does. The one thing to watch is the empty trigger_conditions array — inert where the file sits, but a day-1 priority-10 fire the moment anyone moves it into reactive/ without adding a trigger, which is exactly what the directory's README warns about.

---
## Appendix · Decision surfaces that are not EventModal cards

Recorded so nothing is invisible. None of these fits the 2.2 shape — they are scenes and dialogs, not cards with triggers and modifier lists — but every one of them puts a decision in front of the player.

| surface | file:line | kind | why it is not in the main body |
|---|---|---|---|
| **MeetingScene · VC pitch** | mounted `main.gd:2369`; view-state from `vc_pitch_system.gd:783` (`begin_meeting`) | multi-stage dialogue, choice cards per stage | a branching conversation, not a card; its choices are dialogue ids resolved by `_on_choice_selected` (`meeting_scene.gd:135`) |
| **MeetingScene · B2B prospect pitch** | `b2b_pitch_meeting.gd:89-100`; entry `main.gd:2130` ← `EventBus.pitch_requested` | same scene, different stage table | as above |
| **TermSheetTableScene** | mounted `main.gd:2433`; state machine `term_sheet_table_system.gd:270-291` | lever pushes + SIGN / WALK | a negotiation minigame with its own odds model |
| **HRAtlasModal** | `hr_tab.gd:572-594` (into **PanelLayer**, not ModalLayer); `_on_hire_pressed` `:430`, `_on_dismiss_pressed` `:436` | hire / dismiss a candidate | a browsing surface with an action, not an authored beat |
| **TrainingModal** | `hr_tab.gd:362`, `personal_tab.gd:289` (PanelLayer) | pick a training track | as above |
| **ConfirmModal** | 16 emitters of `EventBus.confirm_requested` — `main.gd:1107,1116` (both debug shot fixtures) · `save_load_modal.gd:140,159,175` · `settings_modal.gd:399` · `system_menu_modal.gd:79` · `term_sheet_table_scene.gd:395,414` · `hr_atlas_modal.gd:441` · `hr_tab.gd:311,816,838` · `hunt_tab.gd:232` · `creation_flow.gd:943` · `build_hud_panel.gd:248` | binary / ternary confirm | UI confirmation, not content |
| **MonthSummaryModal** | `main.gd:2302-2319` ← `EventBus.month_ended` | information | no choice (carries Frank's line — surface 19) |
| **EndingScene** | `main.gd:2334-2348` ← `EventBus.run_ended` | terminal ceremony | no choice |
| **MentorIntroModal** | `main.gd:2024` | information | no choice (Frank surface 1) |
| SystemMenuModal / SaveLoadModal / SettingsModal | `main.gd:2212 / 2238 / 2147` | menus | not content |

**One structural note worth carrying forward:** `HRAtlasModal` and `TrainingModal` mount into **PanelLayer**, not ModalLayer, so `game_shell.gd`'s Guard 2 does not see them and the clock keeps running through a hiring decision. Filed in the 2026-08-06 audit as S2-30; still true.

---

## 2.5 · The playtest question, answered directly

### Which events actually appear in a full run, in what order, and how many are there?

**The primary run — Bootstrap to a terminal state, 275 days, 62 cards.** Mean spacing 4.4 days, median gap 2 days, longest silence 18 days.

The shape of it, in three parts:

- **Days 1–24 · the build.** Eight cards, all from the MVP pool: the design-round intro (d7), integration broken (d14), solo-dev fatigue (d16), final polish (d18), early-launch pressure (d21), and the first ship (d24). Every one of them fires once and never returns. **This is the best stretch of the game** — six different situations, each with a genuine two-way trade, spread across three weeks.
- **Days 25–120 · the company.** Frank's B2B introduction (d25), the first referral (d32), the Traction gate (d33), Frank's cheque (d53), the hire nudge (d55), the first retention card (d55), three version ships, four scope/bugfix beats and the first expansions. This is the densest and most varied part of the run: **2.2 decisions a week, roughly ten distinct situations.**
- **Days 121–275 · the plateau.** 33 cards, of which **32 are the same two**: `ev_b2b_expand_<customer>` and `ev_ps_referral_b2b`. After day 212 there are **four cards in 63 days and all four are the referral**, with byte-identical fiction each time.

**Eighteen distinct card families fire in 275 days. Two of them account for 41 of the 62 fires (66%).** Fourteen families fire exactly once, and a fifteenth (the version-ship moment) three times — those 17 fires *are* the authored content a player sees, and they are all spent by day 120.

The B2C path is starker. `b2c_keep` reached a terminal state in 183 days with **35 cards, of which 29 (83%) are the same two ambient beats** — `ev_ps_b2c_producthunt` ×16 and `ev_ps_power_user_b2c` ×13, alternating on a roughly ten-day rhythm from day 7 to day 180. Six cards in that entire run are one-shot content.

### What the event layer feels like

For the first four months it feels like a game: a decision every three or four days, each one different, several of them with a real cost on both sides. After that it becomes **two recurring emails**. The player is still being interrupted — 1.3 to 2.2 times a week — but the interruptions stop carrying information, because the same customer asks for the same expansion and the same GM sends the same referral, and neither card acknowledges that it has happened fifteen times before.

**How many mattered.** Of the 62 cards in the primary run, **25 were "Büyüt" with no downside** (see the summary table), **16 were a referral whose two prospect options render an identical chip**, and **4 were retention cards** — the only recurring family in the run where the options genuinely diverge. That leaves **17 fires** of authored, non-repeating content. So: *seventeen decisions in 275 days actually changed the shape of the run, and all seventeen landed before day 120.*

### Twelve card families never appear at all

Across **eight runs and 2,290 simulated days**, these never fired once:

| family | why |
|---|---|
| `ev_hr_resign_<emp>` | needs morale < 25 for 10+ consecutive days; a new hire starts at 75 and nothing in the probe's policy pushes anyone down. **Correctly gated, never reached.** |
| `ev_hr_valve_<emp>` | needs an active overtime block; the probe never starts overtime. **Correctly gated.** |
| `ev_hr_ship_glow` · `ev_hr_big_signing` | **structurally unreachable — see the finding below.** |
| `ev_hr_calm_stretch` | needs 21 days with no overtime **and** average morale < 70; a team that never worked overtime is above 70. Reachable only in a narrow window. |
| `ev_b2b_escalation_<cust>` | needs an assigned steward (`c.assigned_to`); requires hiring a Customer Success rep. **Correctly gated, behind a hire the probe never makes.** |
| `ev_b2b_request_<cust>` | needs `_ranked(AREA_CUSTOMER_SUCCESS)` to be non-empty (`customer_rep_system.gd:313`). Same hire. **Correctly gated.** |
| `ev_mvp_dev_002_tech_debt_callout` | needs flag `tech_debt_birikti`, which only choice 1 of `ev_mvp_dev_001` sets; the probe always answers choice 0. **Reachable by a player, not by this policy.** |
| the four VC cards + `ev_shutter_warning` | see the Frank report — no run books a meeting, holds a sheet, or goes cash-negative. |
| `ev_seed_closed` · `ev_buyout_offer` · `ev_vc_deal_prompt` | deliberately inert, verified. |
| the three `ev_debug_*` | skipped by the loader on the filename prefix. |

**A defect, not a gate: `ev_hr_ship_glow` and `ev_hr_big_signing` can never fire, for one shared reason.** Both test *today*: `days_since_last_ship() == 0` (`hr_morale_system.gd:203`) and `c.acquired_on_day != GameState.day` (`_big_signing_today`). The only caller is `HRMoraleSystem.tick_positive_events()`, run from `HRSystem.daily_tick()` at **slot 3 of the day boundary, hour 0** (`time_manager.gd:258`). A ship is stamped into `mvp_version_history` inside `ProductSystem.ship_active_build()` (`product_system.gd:1391-1393`), which runs when the player resolves the ship card — always *after* that day's HR tick. A customer is acquired at slot 4 (Sales) or through a played pitch, likewise after slot 3. So by the time the HR tick looks, the answer is always "yesterday" (1), never "today" (0). Two of the three recovery events in the morale system are dead on arrival, and the third (`calm_stretch`) is the one with the narrowest window. **The morale system's entire recovery channel is effectively silent** — which matters because its own header says morale never self-heals without it.

### Which events are worth revising rather than replacing?

**Keep and re-number — these have a real moment under them (9):**

1. **`ev_ps_bug_complaint`** — the best-authored card in the pool. Three options with genuine divergence, per-option `description` lines nothing else uses, full differentiated chips, no dominated row, and Calibration Round A already cleaned its copy. Its only problem is the trigger: it fired **42 times in 365 days** in `b2c_neglect` because `get_min_satisfaction()` stays under 60 forever. Fix the arming condition, keep every word.
2. **`ev_mvp_dev_001_integration_broken`** — the "do it right vs hack it" trade, with a hidden flag on both sides. The moment is excellent; the invisible `set_flag` cost is the problem.
3. **`ev_mvp_dev_002_tech_debt_callout`** — the payoff of the above, and the only event in the game that reads a flag another event wrote. Worth keeping purely for that structure.
4. **`ev_mvp_iter_001_scope_creep`**, 5. **`ev_mvp_bugfix_002_early_launch_pressure`**, 6. **`ev_mvp_bugfix_003_final_polish`** — the ship-it-or-polish-it family. Three variations on one good question, correctly windowed, each once per build.
7. **`ev_b2b_retain_<customer>`** — mechanically the strongest card in the game: four options, a real cap system behind two of them, a promise ledger behind a third. It fires far too often (87 times across five accounts in one year) but nothing about the card itself is wrong.
8. **`ev_ps_b2c_producthunt`** and 9. **`ev_ps_power_user_b2c`** — the two B2C ambients. Both have a legible trade (visibility vs. organic; momentum vs. quiet). They are the entire B2C mid-game and they repeat because there is nothing else, not because they are bad.

**Revise the numbers, keep the scene (2):**

- **`ev_b2b_expand_<customer>`** — the moment is right (a happy account wants to grow) and the once-per-account latch is now correct. What is wrong is that accepting has **no cost of any kind**. Give the seats a price and this becomes a decision.
- **`ev_ps_referral_b2b`** — a good fictional situation (the customer's boss opens a door) with two real outcomes (mid lead for $400 vs small lead for free) that the chips render **identically**, and a roadmap promise the engine never records. Fix the chip and add the promise; the prose can stay.

**Not worth keeping (5):**

- The three `ev_debug_*` fixtures — placeholder voice, `[DEBUG content]` markers in the body, `[NOT IMPLEMENTED]` leaked into a label. They are fixtures and should be labelled as such or deleted.
- **`ev_mvp_dev_003_solo_dev_fatigue`** and **`ev_mvp_iter_003_early_user_feedback`** — pleasant scenes with symmetric, low-stakes effects; nothing underneath them that a playtest would notice.

**The other twelve, and why they are not on either list.** They are not bad and they are not load-bearing, because a playtest cannot currently reach most of them:

- **`ev_mvp_bugfix_001_critical_bug`** and **`ev_mvp_iter_002_competitor_signal`** — both are good cards with real, differentiated chips (`HATA −6 · KARARLILIK +4 · NAKİT −$150` against `MARKA −2`). They belong with the "keep" set on quality; they are listed separately only because each carries a COPY LIE the revision must fix first — `Çıkışı ertele` postpones nothing, and the competitor card moves no competitor.
- **`ev_b2b_escalation_<customer>`** and the three **`ev_b2b_request_<customer>`** branches — four well-built cards behind one unmade hire. They cannot appear until the player employs a Customer Success rep, so no playtest has ever seen them. Judge them after the hire is on the critical path, not before.
- **The five HR cards** — same situation, worse: two of them (`ship_glow`, `big_signing`) are structurally unreachable and must be fixed before they can be judged at all; the other three need a stressed team the current policy never produces.
- **`ev_seed_closed`** — deliberately inert, complete, correct, waiting for a seed round to exist. Nothing to do.

### Is the roughly-ten already there?

**Yes — eleven, and they are the right eleven.** The nine "keep" events plus the two "revise the numbers" events carry a full playthrough after revision, and they already cover the three phases: six build-phase beats, two B2C ambients, and three B2B account beats. Nothing new needs to be written to make a run testable.

**What is missing is not events, it is spread.** All eleven fire before day 120 or repeat forever after it. The pool has no card whose trigger is "the company is large and settled", which is why the last third of every run collapses onto two ids. That is a trigger problem, not a content problem — and it is cheaper to fix than authoring an arc.
