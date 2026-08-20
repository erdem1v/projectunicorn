# Event ve anlatı — GDD v2 conformance (engine side)

**Date:** 2026-08-20 · **Chapters:** 11 · Events & Narrative, plus `docs/.md` — **Event Pool Design v1** (2026-08-19), whose §5 is the engine specification chapter 11 implies
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Scope:** the engine — triggers, the effect vocabulary, memory, wiring. Authoring voice and node content are the director side and are out of scope here.

---

## Verdict

The engine is a competent **single-event dispatcher** and chapter 11 asks for a **storylet engine**. The distance between those is not volume, it is four structural properties, and the Pool Design already names them: one admission path, signal-driven triggers, readable history, and slots.

Concretely, at `7687095`: **28 condition types and 43 executable effect types**, fully enumerated below. Every condition is a standing-state comparison, a calendar number or a dice roll — **not one reads a system edge.** `EventManager` connects to nothing on `EventBus`, so churn, promise-broken, phase change and rival move are unreachable from content even though all four are emitted. `_history` is written on every resolution and `get_history()` has **zero callers**, so a node cannot ask what happened earlier. There is no arc, no chain, no slot substitution in authored text, and no weighted targeting — every target is index-0 or an argmin.

The largest single structural hole is the **injection bypass**: `enqueue` and `enqueue_front` skip eligibility entirely (`event_manager.gd:200-234`), which means `one_shot`, `cooldown_days`, the build gate, hour windows and all trigger conditions are dead fields on every system-fired event. Eleven owning systems have each re-implemented their own one-shot latch as a result. That is the mechanism the Pool Design §5.1 wants ended, and it is the change everything else rests on.

Two smaller defects are worth fixing whenever the vocabulary is next touched: **the `mrr` chip renders an effect the dispatcher cannot apply**, and **`delay_days` prints a day cost that silently no-ops** once no build is active.

---

## 1. Requirements — chapter 11

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | Nine arcs of 4-6 nodes each, plus a small texture pool; arcs bound to systems, not to a calendar (§1) | **No arc concept exists.** No `arc_id`, no node index, no chaining field on `GameEvent` (`event.gd:27-77`); grep for arc across `scripts/` returns only UI geometry and comments. The only ordering primitive is `priority`, an int with an in-bucket shuffle (`event_manager.gd:120-135`). | **YOK** | several days |
| 1.2 | About 40 nodes in v1, with customer events repeating against different accounts via slots (§2) | **16 authored JSON events carrying 31 choices** (three `ev_debug_*` files are skipped by a prefix guard, `event_manager.gd:865-866`), plus **21 code-factory builders** producing 41 more choices — the engine header counts 40 of 71 live choices as code-built (`:145`). Repetition against different accounts already happens, but only inside factories: ids are namespaced per entity, e.g. `ev_b2b_retain_<cid>` (`b2b_event_factory.gd:26`). | **KISMİ** | content, not engine |
| 1.3 | **Vocabulary law**: an event may only use effects the engine knows; a missing effect is written `[VOCAB?]` and not wired (§3) | The vocabulary is published as `docs/content/events_draft/_vocabulary.md`, which is the right instrument. It is now **stale in three measurable ways**: it says 43 modifiers with `advance_iteration` in flight (retirement has landed — the arm and chip are both gone), it says 27 conditions (there are 28; `b2b_discounts_below` and `mrr_growth_streak` arrived with the Build Bar and calibration work), and its gate-2 description predates the growth-streak condition. Its line numbers are off by 20-30 throughout. | **KISMİ** — the law holds, the document drifted | hours (regenerate) |
| 1.4 | **Cost law**: every option costs a real resource and has a visible reader; a no-cost option is valid only as an explicit beat (§4) | Across the whole live game: **72 choices; 6 carry no modifier at all; 12 carry only blind modifiers** (types that render no chip). So **18 of 72 render a card with zero effect chips**, and six of those are irreversible or terminal — accepting an acquisition, declining a pivot, shipping a build, forfeiting a VC meeting. Nothing in the engine validates that a choice has a cost or that a promised chip has a dispatcher arm. | **KISMİ** | a day (a validation pass) |
| 1.5 | **Triggers hook to system edges** — churn, phase change, incident, raise demand, rival move, version ship, coverage red, promise broken (§5) | **Not one of the eight is available as a condition.** `EventManager` listens to no signal (verified: the only `EventBus` references in the file are its own emits). System-fired events are direct injections from the owning system, which is why the edge exists in code but not in the vocabulary. Detail in §2 below. | **YOK** | several days |
| 1.6 | Ambient texture: at most one per day, never carrying economic weight (§5) | The cap exists and is exactly one per day (`_ambient_fired_day`, `event_manager.gd:49, 100-101, 113`), with a correct hour-0 boundary correction (`:99`). The no-economic-weight half is authorial, not enforced. | **VAR** | — |
| 1.7 | Memory: nodes write flags, later nodes read them (§6) | The channel exists — `set_flag` writes (`event_manager.gd:578-583`), `flag_equals` and `flag_set` read (`:386-389`). **It is used exactly once in the entire authored corpus**: `ev_mvp_dev_001` sets `tech_debt_birikti` and `ev_mvp_dev_002` requires it. One edge, two nodes. | **KISMİ** | — |
| 1.8 | Arc memory as a distinct thing (§6) | Absent. The dotted-key convention `<arc>.<n>.choice` exists only in the Pool Design document. | **YOK** | a day |
| 1.9 | Account memory lives in the account and is separate (§6, ch. 04 §3) | Correct and real: `trust_offset`, `retain_discounts`, `retain_stalls`, `last_risk_exit_day`, the per-account `b2b_broke_<id>` flag (`02_satis_ve_pazar.md` 3.8). One condition can read it back — `b2b_discounts_below` (`event_manager.gd:418-422`). | **VAR** | — |
| 1.10 | **Run history becomes readable** — today it is written and never read (§6) | Exactly as the chapter says. `_history` is appended on every resolution with `{id, day, choice}` (`event_manager.gd:36, 191`), persisted (`:299`), and read by precisely three things — the one-shot scan, the cooldown scan and save/load. **`get_history()` has zero callers.** No condition type touches it, so a node cannot ask whether something fired, which option was taken, or how long ago. | **YOK** | a day |
| 1.11 | Locked-visible choices with a reason line; never hidden (§8) | Built, and it is the engine best feature. `unlock_condition` is re-evaluated **at render** (`event_modal.gd:337`); a locked row stays visible at half alpha, is inert, has its effect chips **suppressed**, and shows either the authored reason or a `KİLİTLİ` fallback (`:388-394`). A mentor never endorses a locked path (`:339`). The reference implementation is the capped discount row (`b2b_event_factory.gd:310-321`). | **VAR** | — |
| 1.12 | Every arc names the systems it reads and writes; an arc with no system link is texture and marked as such (§9) | Authorial rule; no engine support needed beyond arcs existing. | **n/a** | — |

---

## 2. The trigger vocabulary — 28 conditions, none of them an edge

Single evaluator: `EventManager.is_condition_met` (`event_manager.gd:368-445`). An empty dict is true; an unknown type warns and returns **false**.

**Calendar and dice (3):** `day_min` `:375`, `day_max` `:376`, `random` `:385`.
**Run configuration (2):** `subgenre` `:384`, `market_type` `:429`.
**Economic levels (8):** `cash_below/above` `:378-379`, `brand_below/above` `:380-381`, `reputation_below/above` `:382-383`, `mrr_above/below` `:414-417`.
**Product levels (5):** `build_state` `:390`, `build_phase` `:399`, `bug_count_above` `:404`, `mvp_shipped` `:395`, `founder_skill_min` `:397`.
**Customer levels (4):** `customer_count_min/max` `:410-413`, `has_prospects` `:431`, `customer_satisfaction_below` `:437`.
**B2C level (1):** `audience_above` `:433`.
**Memory (2):** `flag_equals` `:386`, `flag_set` `:388`.
**Phase level (1):** `phase` `:377`.
**The two nearest to an edge (2):** `b2b_discounts_below` `:418` — the only condition that reads an account own decision history — and `mrr_growth_streak` `:423`, which counts closed months with month-over-month growth. Neither is a crossing.

### The eight edges chapter 11 §5 names, checked one by one

| Edge | Available as a condition? | What exists instead |
|---|---|---|
| **churn** | **No** | `EventBus.customer_churned` (`event_bus.gd:92`) is emitted and has no event-engine listener. Nearest proxy: `customer_count_min/max`, a level. |
| **phase change** | **No** | `phase` is the level; `EventBus.phase_changed` has no listener. |
| **incident** | **No** | Incidents do not exist (`05_operasyon.md`). |
| **raise demand** | **No** | The event does not exist (`03_ekip.md` 2.19). |
| **rival move** | **No** | Rival moves do not exist, and `RivalRegistry` is unreachable from both the condition and the effect vocabularies. |
| **version ship** | **Partial** | `mvp_shipped` is a latched flag that stays true forever. The *moment* is delivered by direct injection (`product_system.gd:977, 1306-1308`), not by a condition. |
| **coverage red** | **No** | Coverage does not exist. |
| **promise broken** | **No** | `EventBus.promise_broken` (`event_bus.gd:99`) has no listener. `PromiseRegistry.has_open_for` is read only *inside* a factory at build time (`b2b_event_factory.gd:60`), which is a different thing from a content-readable condition. |

**The structural cause is one line of architecture:** `EventManager` subscribes to nothing. Everything is polled — beats daily at slot 6, ambients hourly (`event_manager.gd:58-115`). Every system edge that could arm a node is instead handled by that system calling `enqueue` itself, which is why the eighteen injection sites in §4 exist.

---

## 3. The effect vocabulary — 43 types, 33 with chips

Dispatcher: `EventManager._apply_modifiers` (`event_manager.gd:545-793`); unknown type warns and no-ops. Player-facing chips: `EventModal._describe_modifier` (`event_modal.gd:452-533`); a type with no arm there renders no chip.

**Economy (4):** `cash` `:553`, `brand` `:555`, `reputation` `:557`, and **`mrr` — a chip with no dispatcher arm** (see 5.1).
**People (6):** `morale` `:559`, `morale_all_employees` `:575`, `add_character` `:584`, `hr_departure` `:624`, `hr_overtime_stop` `:632`, `hr_overtime_continue` `:634`.
**Flags and narration (2, both blind):** `set_flag` `:578`, `mentor_advisory` `:737`.
**Product and build (8):** `dimension_delta` `:640`, `bug_delta` `:643`, `delay_days` `:646`, deprecated `speed_bonus` `:650` and `quality_bonus` `:652`, `ship_active_build` `:654`, `enter_development` `:659`, `enter_beta` `:661`.
**Sales and customers (8):** `add_prospect` `:664`, `churn_customer` `:666`, `seats` `:691`, `customer_mrr_delta` `:704`, `satisfaction_delta` `:711`, `audience_delta` `:719`, `open_paid_tier` `:728`, `convert_audience` `:730`.
**B2B retention outcomes (8):** `b2b_promise_create` `:773`, `b2b_retain_delay` `:776`, `b2b_retain_discount` `:778`, `b2b_retain_ignore` `:780`, `b2b_cs_promise_honor` `:782`, `b2b_cs_promise_refuse` `:785`, `b2b_expand` `:787`, `b2b_expand_decline` `:790`. All eight route through `B2BSalesSystem` seams — the cleanest family in the vocabulary.
**Endgame and investor (8, all blind):** `advance_phase` `:740`, `phase_gate_decline` `:744`, `angel_accept` `:747`, `accept_acquisition` `:754`, `accept_pivot` `:757`, `decline_pivot` `:760`, `start_vc_meeting` `:763`, `decline_vc_meeting` `:767`.

`advance_iteration` is **retired** — no arm, no chip. Do not author it.

### Effects a designer will want and cannot have

| Wanted | Status |
|---|---|
| tech-debt change (numeric) | **absent** — only a boolean through `set_flag` |
| support-load change | **absent** |
| capacity change | **absent** — the only capacity levers are the two binary overtime types |
| coverage | **absent** |
| version-age reset | **absent** — `mvp_launch_day` is write-once and has no modifier |
| rival-share shift | **absent, and structurally unreachable** |
| generic account-memory write | **absent** — the eight `b2b_*` seams write real memory, but there is no general write |
| morale of a named person | **present** (with the caveat in 5.2) |
| **founder-time cost** | **absent** — `delay_days` is a build lever, not time. Every Pool Design node that says costs a day has no executable effect |
| aggregate MRR | **absent as a write**, and it is the chip-without-arm |
| price change | **write-once only** via `open_paid_tier`; no repricing modifier |
| prospect removal | **absent** (`add_prospect` exists) |
| employee experience or training | **absent** — signals exist, no modifier |
| **headline push** | **absent** — an event cannot leave a trace in the ticker |
| scandal start or clear | **absent** — `active_scandal` has no writer at all |

### Conditions a designer will want and cannot have

History reads (fired? which choice? days since?), headcount, days-since-flag, any edge or delta, rival state, promise state, runway, customers-lost, origin, and compound AND/OR — `unlock_condition` is a **single dictionary** (`event_choice.gd:24`), so a two-fact lock is inexpressible.

---

## 4. The Pool Design §5 engine requirements, scored

`docs/.md` §5 is the nine-point specification the rebuild is measured against.

| § | Requirement | Status |
|---|---|---|
| 5.1 | **One admission path** — every node enters through the same gate; the `enqueue()` bypass ends | **NOT MET, and it is the keystone.** Three paths exist (`event_manager.gd:159, 200, 217`); the two injection paths skip `_is_eligible` outright (`:202-203`), so on a synthetic event `one_shot`, `cooldown_days`, the build gate, `allowed_hours` and every trigger condition are dead fields. Eleven systems hold their own latches as a consequence — `angel_seed_offered`, `phase_gate_ready`, `_iter_intro_shown`, `cs_escalated`, `last_expansion_day`, `support_request_since_day`, `_pending`, `hr_last_positive_event_day`, `KEY_VALVE_FIRED`, `pivot_offer_made`, `acquisition_offer_made`. |
| 5.2 | **Two trigger kinds first-class** — on-action hooks plus a weekly phase-weighted pulse | **NOT MET.** Zero signal-driven triggers; polling only. No `weight` field exists — `priority` is a bucket sort with an in-bucket shuffle, not a draw weight. |
| 5.3 | **Content-readable memory** — `history_has(arc, node, choice)`; `get_history()` gets readers | **NOT MET.** No history condition; `get_history()` still has zero callers. Partial substitute: `set_flag` into `flag_equals`/`flag_set`, used by exactly one authored pair. |
| 5.4 | **Slots and weighted targeting** — `{account}` / `{employee}` / `{rival}`, most-arc-history first; an unfillable slot makes the node ineligible | **NOT MET.** No substitution in authored text — `populate` does `Localization.pick` plus a markdown pass and nothing else (`event_modal.gd:34-48`), so `{account}` would render literally. Substitution exists only inside code factories at build time. Targeting is index-0 or a deterministic argmin (`event_manager.gd:815-831`), never weighted, and there is no unfillable-slot rule. Two partial credits: `_active_event_market()` scopes a default target to the event own market (`:804-808`), and `_resolve_customer_target` lets one event hit one consistent account across several modifiers. |
| 5.5 | **Locked-visible options with a reason** | **MET.** See 1.11. The one remaining gap is that a lock cannot express two facts at once. |
| 5.6 | **Budget governor** — at most one decision node per day, category diversity per week, a weekly cap of 2-3, mandatory beats exempt | **~15 percent met.** Only the one-ambient-per-day cap exists. **Beats are uncapped and all fire the moment they qualify** (`:73-74`); injections are uncapped. No weekly cap, no category tracking. The mandatory-beats-exempt half is met by accident, since beats and injections are exempt from the only cap there is. The nearest thing to a category budget in the game is `CS_ESCALATION_WEEKLY_CAP`, enforced by one subsystem policing itself (`customer_rep_system.gd:276-300`). |
| 5.7 | **Variant text per node**, so a repeat never reads twice the same | **NOT MET** as a general facility. One hard-wired instance: the phase-gate scene rewrites its own body by decline count (`phase_gate_system.gd:266-276`). |
| 5.8 | **Effect vocabulary published**; missing effects flagged, never invented | **PARTIALLY MET.** The document exists and is the right instrument; it has drifted (1.3). |
| 5.9 | **Dead-choice sweep re-runs before merge** | **PARTIAL.** The tooling exists but is not a gate: `run_probe.gd` auto-plays choices and independently re-runs the unlock gate (`:356, 378-419`); smoke asserts specific outcomes. Neither enumerates every option to its effect to its reader. |

**One of nine met, two partial, six unmet** — and the three that are load-bearing for arcs (one admission path, readable history, slots) are precisely the three the current architecture most actively contradicts.

---

## 5. Defects worth fixing whenever the vocabulary is next touched

### 5.1 A chip that promises an effect the engine cannot apply
`EFFECT_MRR` renders `MRR {v}` (`event_modal.gd:459`) and `_apply_modifiers` has **no `mrr` arm**. It is documented as legal at `event_choice.gd:13`. No live choice uses it, so it is a trap rather than a bug — authoring `{"type":"mrr","delta":-500}` shows the player a promise and changes nothing.

### 5.2 Chips that lie in common states
- **`delay_days`** prints `{v} gün` unconditionally but the seam no-ops with no active build (`product_system.gd:1194-1195`) — so post-ship it is a visible cost that does not happen.
- **`morale`** prints the nominal delta while `apply_delta` scales it by trait multiplier and Liderlik climate (`hr_morale_system.gd:233`), and silently no-ops for the founder and mentor.
- **`seats`** hides the MRR half of its own effect (`event_modal.gd:466-468`).
- **`convert_audience`** renders `%0` when authored in its `count` form.
- **`quality_bonus`** hardcodes a plus sign and green.
- **`add_prospect`** promises a lead that silently fails to appear when the company pool is exhausted — the null contract at `pitch_system.gd:42-53`.

### 5.3 Ten blind types, four of them irreversible
`set_flag`, `mentor_advisory`, `ship_active_build`, `advance_phase`, `phase_gate_decline`, `accept_acquisition`, `accept_pivot`, `decline_pivot`, `start_vc_meeting`, `decline_vc_meeting` render no chip at all. Two are **terminal** (accepting an acquisition, declining a pivot) and two are irreversible in practice (shipping, forfeiting a meeting). Chapter 11 §4 says every option has a visible reader; these are the exceptions to close first.

### 5.4 One WRITE-THROUGH violation in the dispatcher
`decline_vc_meeting` clears `GameState.pending_meeting` with a raw field write (`event_manager.gd:767-769`). Every other endgame modifier calls a system seam.

### 5.5 A localization hole with a player-visible consequence
`mentor_advisory` carries its text as a **raw literal with no `_en` sibling** (`event_manager.gd:737-738`), and three live JSON choices pass Turkish prose inline (`ev_ps_frank_intro_b2b.json:36`, and the same pattern in `ev_ps_first_revenue` and `ev_ps_b2c_paid_tier`). That text is latched onto the ODA phone and the Hunt strip, so **an English player reads Turkish there**. Separately, factory text is baked at build time and stored, so a synthetic event that sits in the queue across a language change renders the stale locale.

---

## 6. Wiring — every place an event enters the queue

Eighteen production sites, plus the two pool paths. Each is a system that noticed an edge and injected a card, because it had no way to declare that edge to the engine.

| Owner | Site | The edge it stands in for |
|---|---|---|
| Pool, beats | `event_manager.gd:74` | daily eligibility sweep, uncapped |
| Pool, ambients | `event_manager.gd:112` | hourly roll, at most one per day |
| Product | `:575` | the first design round ended |
| Product | `:1308` | a build shipped |
| HR morale | `hr_morale_system.gd:498` | a resignation roll passed |
| HR morale | `:526` | a positive beat — ship, big signing or a calm stretch |
| HR overtime | `hr_overtime_system.gd:373` | someone crossed flight risk during a block |
| B2B sales | `b2b_sales_system.gd:170` | an assigned account fell below the escalation floor |
| B2B sales | `:204` | an account entered risk |
| B2B sales | `:263` | an account became expansion-ready |
| Customer desk | `customer_rep_system.gd:308` | a support request went stale or could not be absorbed |
| Sales tab | `sales_tab.gd:344` | **the player pressed İlgilen** |
| Sales tab | `sales_tab.gd:367` | **the player pressed Büyüt** |
| Angel | `angel_round_system.gd:89` | two days after the seed, still solo |
| Angel | `:119` | shipped, and MRR crossed the threshold |
| Phase gate | `phase_gate_system.gd:132, 144, 167` | gate opened; five-day reminder; shutter cleared with a gate open |
| Endings | `endings_system.gd:126, 177, 255` | cash went negative; the cascade deferred into a pivot offer; the acquisition band was entered |
| VC | `vc_pitch_system.gd:435, 482, 499` | a sheet hit its warning day; a meeting day arrived; the soft cap is one day away |

Two notes for the rebuild. **Sites 12 and 13 reach into `EventManager._active_event_id`, a private field, from a tab** — that guard belongs in the engine. And `vc_pitch_system.gd:435` uses one constant id for up to two sheets, so two sheets warning on the same day means the second warning is silently dedupe-dropped.

---

## 7. Frank delivery

Chapter 14 §7 retires the large dedicated Frank modal and rules that Frank speaks through the same event card as everyone else, with a small circular avatar.

**That is already how every Frank narrative scene ships.** Sixteen cards carry `character_id = "char_mentor_frank"` and render the ordinary initials avatar with name and role (`event_modal.gd:241-254`): three authored JSON, two phase gates, two angel, three endgame, three VC calendar, three product.

What §7 would retire is not on the event pipeline at all:
- **`MentorIntroModal`** — a bespoke 680x440 one-button scene used once at boot. It has a live defect: `_swap_to_shell_and_modal` awaits `_mount_shell()`, which itself instantiates the modal, and then instantiates a **second** one (`main.gd:1909, 1915-1917, 1959-1961`), so a new run stacks two. It also mounts on a **save load**, contradicting the comment two lines above it.
- **`FrankPopup`** — a cinematic dialogue shell whose only production use is the deal-closed prompt (`main.gd:2355`); everything else is a debug fixture. Its portrait asset does not exist on disk, so it renders the initials fallback anyway.

One presentation bug in the meantime: the source badge picks tags before speaker, and `endgame` maps to PİYASA before the Frank check runs (`event_modal.gd:209-226`). So the angel, shutter, pivot, acquisition and VC-calendar cards **read PİYASA while Frank is speaking**.

---

## 8. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| System edge → event trigger | all → Event | **ABSENT as a vocabulary**; present as eighteen hard-coded injections (§6). | **absent** |
| Event → economy | Event → Finans / Satış / Ürün / Ekip | 43 dispatcher arms, nearly all through owning-system seams. | **present** |
| Event → account memory | Event → Satış | Eight `b2b_*` seams write real per-account state. | **present** |
| Account memory → event condition | Satış → Event | One condition only: `b2b_discounts_below`. | **partial** |
| Event → arc memory | Event → Event | `set_flag` and `flag_set`, used once in the whole corpus. | **partial** |
| Run history → event condition | Event → Event | **ABSENT** — `get_history()` has no callers. | **absent** |
| Event → the news ticker | Event → world | **ABSENT** — no modifier can push a headline. | **absent** |
| Event → the ODA phone | Event → Arayüz | `event_triggered` lights the dot and buzzes the phone; the modal is born from the phone anchor (`oda_view.gd:655-657`, `event_modal.gd:56-76`). | **present** |
| Event queue size → rail badge | Event → Arayüz | `EventManager.get_queue_size()` feeds `left_tabs.gd:148-149`. Ch. 12 §1 removes the Events tab this badge sits on. | **present, needs relocating** |
| Terminal → queue flush | Sonlar → Event | `flush_queue()` at `endings_system.gd:268`. | **present** |

---

## 9. Depends on / depended on by

**The engine depends on:** nothing structural. One admission path, signal triggers, history reads, slots, variant text and a budget governor can all be built today against the systems as they stand.

**Depended on by:** every module that wants an edge to speak — Operasyon (incidents, coverage red), Ekip (raise demand, poaching), Rakipler (six move faces), Satış (audience-drop edge, promise broken), Ürün (ship moments now, DESTEK beats later). And by the content pass: the Pool Design nine arcs assume slots, memory and a budget governor exist.

**Order.** The engine work can and should run **in parallel from the start** — it waits on no other module. Only its *vocabulary extensions* track the others: an incident effect cannot exist before incidents do.

---

## 10. UI work

Modest, because the card itself is in good shape.

- **Effect chips need a hover reveal.** Chips are inert today (`mouse_filter` IGNORE at `event_modal.gd:353, 363, 369, 378`); `CLAUDE.md` already names the tooltip as a pending follow-up, and it is what lets a two-effect choice stay readable.
- **The blind types need readers**, especially the four irreversible ones (5.3).
- **Source-badge order** must put the speaker before the tag, so Frank cards stop reading PİYASA.
- **Slots** change the card: `{account}` and `{employee}` mean title and body are composed at display time, and an unfillable slot has to hide the option rather than render a brace.
- **The events log** moves into Kişisel (ch. 12 §1) and the Events tab disappears — `09_arayuz_ve_oda.md` owns that, but the queue-size badge needs a new home.

---

## 11. Sizing

| Item | Size | Assumes |
|---|---|---|
| Fix the source-badge order | hours | |
| Remove the `mrr` chip, or add its arm | hours | |
| Chips for the four irreversible blind types | hours | |
| `mentor_advisory` gains an `_en` sibling | hours | |
| Regenerate `_vocabulary.md` from source | hours | make it generated, not hand-kept |
| Fix the double MentorIntroModal mount and the load-path mount | hours | |
| Compound `unlock_condition` with AND/OR | hours | |
| History-reading conditions (`history_has`, days-since) | a day | `_history` already persists |
| A validation pass: every chip has an arm, every option has a cost | a day | run it in smoke |
| Variant text per node | a day | |
| Effect-chip hover reveal | a day | |
| **One admission path** — retire the bypass, move the latches into the engine | several days | touches eleven systems; the keystone |
| **Signal-driven triggers** for the eight edges | several days | some edges do not exist yet |
| **Slots and weighted targeting** | several days | |
| **Budget governor** (weekly cap, category diversity, one decision per day) | several days | |
| Arc ids, node ordering, arc memory | several days | |
| Vocabulary extensions per module | hours each | tracks Operasyon, Ekip and Rakipler as they land |

---

## 12. Open questions for the director

1. **Category to node-count targets for EA** (§10).
2. **How many texture nodes ship in v1** (§10).
3. **Do repeated customer events use named slots in v1, or fixed names?** (§10.) This single decision most changes the engine work — slots are several days, fixed names are zero.
4. **The three calibration vocabulary additions (F7)** have all landed in code (`audience_delta {pct}`, `mrr_growth_streak`, `b2b_discounts_below`); the published vocabulary document has not been updated to match. Confirm it becomes a generated artefact.
5. **Do the blind terminal types get chips, or are they exempt as ceremonies?** Chapter 11 §4 implies chips; the endgame cards may read better without them.
6. **Is the Events tab really removed** (ch. 12 §1)? It is the only rail badge that regularly shows a number above one, and it is the click target the ODA phone routes to.
