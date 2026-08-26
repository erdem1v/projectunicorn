# SEAM REGISTRY — the named read surface the event engine speaks through

**Owner:** event engine · **Opened:** 2026-08-25 (Aşama 0) · **Authority:** [`GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`](../GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md) §6

A seam is **a named, read-only query a system opens to the outside** (§6.1). Content never
reaches into a system; it asks the registry. This file is the registry's paper form — the
code form is `scripts/events/seams/`, and the two are gated against each other by lint
(§17.1: an unknown seam name is a build error).

## The contract (§6.1)

1. **Read-only.** Mutation is `EffectExecutor`'s job, never a seam's. A seam that writes
   state or emits a signal is not a seam — see the live counter-example in §0.3 below.
2. **Namespaced.** `hr. urun. arge. finance. sales. musteri. destek. phase. rival. investor.
   time. founder.`
3. **A changed meaning gets a new name.** Silent semantic drift is forbidden: the whole point
   is that a card written in month one still means what it said in month six.
4. **The manifest is linted.** A name not in the registry does not reach a build.
5. **Mockable.** This is the only way content can be tested without the systems behind it.

## How to read the status column

| Status | Meaning | What the engine does |
|---|---|---|
| **VAR** | A named read-only query already exists | Register the binding. Zero cost. |
| **OKUNUYOR** | The value is reachable — a public var, a field on a model — but there is no named query | The engine **wraps** it in `seams/`. The owning module is untouched. |
| **YOK** | Not present in the code at all | Filed as open work against the owning module (§7 below). The engine does not invent it. |

**A wrapper is not a fix.** `OKUNUYOR` rows work today and are honest about why: the value
exists, the name does not. When the owning module next opens its own read surface, the wrapper
retires and the binding moves. Nothing content-side changes, which is the entire argument for
naming the query rather than the field.

---

## 0.3 · One measured hazard, recorded before the tables

`ProductRead.emit_edges()` (`scripts/systems/product_read.gd:196-243`) is a **static function
on a read-surface class that mutates statics and emits five signals.** It is not a seam and is
not registered. It is called once per day from `time_manager.gd:314`.

This is why `SeamRegistry` is an **explicit allowlist**, never "any static on a class the GDD
calls a read catalogue". §5.3 bans side effects in condition evaluation, and a convention
cannot enforce that — an allowlist can. A smoke case snapshots `GameState` plus every
registry, evaluates the whole catalogue, and asserts byte-equality.

---

## 1 · `hr.` — Ekip

**The best-established surface in the codebase.** Ekip rev11 §15.3 opened it deliberately
ahead of this engine ("Katalog Ekip'in sorumluluğudur ve bu inşayla birlikte açılır — olay
motorunu beklemez"), and it is already contract-tested at `endgame_smoke.gd:8092-8156`.

### 1.1 The §15.3 block — `hr_system.gd:120-277`

| seam | code | type | range | status |
|---|---|---|---|---|
| `hr.morale(p)` | `hr_system.gd:133` | int | 0–100 | VAR |
| `hr.morale_band(p)` | `:137` → `hr_constants.gd:1131` | String | `high`/`mid`/`low` at 80/50/35 | VAR |
| `hr.headcount()` | `:145` | int | ≥0, **excludes founder + mentor** | VAR |
| `hr.skill(p, area)` | `:149` | int | 0–10 raw | VAR |
| `hr.status(p)` | `:155` | String | `active`/`on_leave`/`training` | VAR |
| `hr.is_busy(p)` | `:159` | bool | leave ∪ training ∪ founder-pitch-prep | VAR |
| `hr.tenure_days(p)` | `:171` | int | ≥0 | VAR |
| `hr.accounts_of(p)` | `:177` | Array[Customer] | reverse index | VAR |
| `hr.work_hours(p)` | `:190` → `work_hours_system.gd:45` | int | 5–11, default 8 | VAR |
| `hr.work_hours_company()` | `:195` | Dictionary | `{hours, start_hour}` | VAR |
| `hr.work_hours_overrides()` | `:202` | int | ≥0 | VAR |
| `hr.overtime_active(p)` | `:206` | bool | hours > 8 | VAR |
| `hr.short_day_active(p)` | `:210` | bool | hours < 8 | VAR |
| `hr.founder_task_label()` | `:242` | String | localized | VAR |
| `hr.founder_task_state()` | `:254` | String | 7 states, mutually exclusive | VAR |

### 1.2 The assignment block — `hr_system.gd:279-408`

Ten more named queries the GDD's "15 seams" count omits. All **VAR**.

`hr.assigned_to(area)` `:283` · `hr.is_idle(p)` `:297` · `hr.job_count(p)` `:305` ·
`hr.is_overloaded(p)` `:309` · `hr.idle_count()` `:316` · `hr.assigned_to_job(job)` `:333` ·
`hr.unstaffed_jobs()` `:351` · `hr.area_lead(area)` `:364` ·
`hr.area_lead_leadership_for(p)` `:377` · `hr.output_mult_for_area(p, area)` `:392`

### 1.3 The §4.5 output block — `hr_system.gd:411-500`

`hr.effective_skill(p, area)` `:422` (float; 0 when not ACTIVE) ·
`hr.daily_contribution(p, area)` `:484` · `hr.area_output(area, people)` `:457` ·
`hr.leadership_output_mult(n)` `:451` · `hr.area_sum_for(area)` `:490`. All **VAR**, and R&D
already consumes `effective_skill` (`rnd_system.gd:181`).

### 1.4 Wrapped by the engine (OKUNUYOR)

| seam | reads | why it is not VAR |
|---|---|---|
| `hr.morale_avg()` | `hr_morale_system.gd:393` | VAR in fact — named, **0.0 with no employees**; registered as-is |
| `hr.level(p)` | `Character.level` `character.gd:68` | field, no query. 0/1/2 |
| `hr.salary(p)` | `Character.monthly_salary` `:50` | field |
| `hr.payroll_total()` | `character_registry.gd:630` | VAR; **not status-filtered** — leave is paid |
| `hr.traits(p)` | `Character.traits` `:58` | field; `TRAIT_COUNT = 1` |
| `hr.leave_week(p)` | `Character.leave_week` `:148` | field; −1 unset |
| `hr.attrition_risk(p)` | `hr_constants.gd:1301` + `:1387` | predicate + odds both named — registered |
| `hr.promotion_eligible(p)` | `hr_actions.gd:145` | VAR, but the rule is **only** the level cap — see §7 |
| `hr.severance(p)` | `hr_constants.gd:1485` | VAR |
| `hr.badges(p)` | `hr_system.gd:592` | VAR |
| `hr.search_state()` | `hr_search_system.gd:78` | VAR |
| `hr.training_state(p)` | `Character.training_days_left` `:125` | field |

### 1.5 `hr.retention_odds(p)` — the seam §9.2 names and the code does not have

GDD §9.2's worked example is `odds_seam: hr.retention_odds`. What exists is
`HRConstants.resign_chance(traits, valve_continued)` (`hr_constants.gd:1387`) — the daily
resignation roll, not a retention probability, and it takes no person.
**Status: OKUNUYOR.** The engine wraps it as `1 − resign_chance(...)` and — because I7 requires
every hover line to name a seam — publishes its *contributions* as
`{value, contributions: [{seam, delta}]}` over the seams that already exist: `hr.morale_band`,
`hr.tenure_days`, `hr.work_hours`, `hr.level`, `hr.traits`, `founder.charisma`. The one
contribution the GDD's own §9.7 table wants and cannot have is salary-vs-band — see §7.

---

## 2 · `urun.` — Ürün

`ProductRead` (`scripts/systems/product_read.gd`) **is** this namespace: its header states that
`ProductRead.X` is the GDD's `urun.X`. All **VAR**, all bound 1:1.

`urun.phase()` `:38` · `urun.build_active()` `:46` · `urun.axis_reading(axis)` `:51` (0–120) ·
`urun.market_word(axis)` `:64` — **prose only, never rendered** · `urun.confirmed_open()` `:74` ·
`urun.unconfirmed()` `:79` · `urun.version_age()` `:84` — *version*, not product ·
`urun.usage()` `:89` · `urun.line_tier(line)` `:94` · `urun.line_next_step(line)` `:99` ·
`urun.lines_open()` `:106` · `urun.steps_shipped()` `:111` · `urun.interest()` `:116` ·
`urun.capacity_tier()` `:121` · `urun.support_staffed()` `:127` ·
`urun.step_unlockable(step)` `:133` · `urun.market_floors(market)` `:148` ·
`urun.axis_floor_state(axis)` `:156` — `""`/`warning`/`crossed`, **the floor ladder's trigger**

### 2.1 Wrapped from `ProductState` and `ProductSystem` (OKUNUYOR unless noted)

`urun.is_live()` `product_state.gd:42` · `urun.version()` `:54` · `urun.market_type()` `:50`
(VAR — the named home of `mvp_market_type`) · `urun.sub_type()` `:46` ·
`urun.quality()` `quality_model.gd:168` · `urun.bugs_confirmed()` / `reports_incoming()`
`product_state.gd:159` / `:155` · `urun.live_bug_count()` `product_system.gd:591` ·
`urun.bug_trend()` `:2202` · `urun.bug_risk()` `:2223` · `urun.build_progress()` `:1007` ·
`urun.build_days_remaining()` `:1014` · `urun.build_paused()` `:460` · `urun.pause_kind()` `:440` ·
`urun.capacity_*` `:284`/`:311`/`:334` · `urun.infra_units()` / `infra_provider()`
`product_state.gd:206` / `:202` · `urun.warmth_band()` `support_system.gd:440` ·
`urun.hidden_lines()` `product_state.gd:110`

`urun.tech_debt()` — **OKUNUYOR**, and the honest note is that it is a *boolean flag*
(`GameState.flags["tech_debt_birikti"]`, read at `product_system.gd:1196`), not a level. Cards
may ask whether it is set; they may not ask how much. Filed in §7.

---

## 3 · `arge.` — Ar-Ge

⚠️ **Another agent is editing these files concurrently.** Bindings are by *name*, which
`rnd_system.gd:652-654` declares stable ("Names are STABLE; each signal has exactly one
publisher"), so line drift is harmless. Read 2026-08-25.

All **VAR**, from the §10 block `rnd_system.gd:652-727`:
`arge.completed(node)` `:657` — declared unrenameable, Ürün §12.5 calls it ·
`arge.active()` `:662` · `arge.progress(node)` `:667` · `arge.progress_effort(node)` `:674` ·
`arge.available(node)` `:681` · `arge.revealed(node)` `:697` · `arge.state_of(node)` `:719` ·
`arge.assigned(node)` `:715` · `arge.family_root_done(family)` `:689` ·
`arge.hidden_line_unlocked(line)` `:702` · `arge.completed_count()` `:706` ·
`arge.is_frozen()` `:725` · `arge.freeze_note_key()` `:354` · `arge.tree_open()` `:71` ·
`arge.days_estimate(node, ids)` `:200` — **−1.0 means "no contribution", never infinity** ·
`arge.start_refusal(node, ids)` `:235` · `arge.note_pending()` `:611`

`ResearchSeam` (`research_seam.gd`) is **not** this namespace — its own header says it is
Ürün's *gate* into R&D. Registered separately as `research.completed(node)` `:91`, the one name
Ürün rev 6 §12.5 pins.

---

## 4 · `finance.` — Finans

| seam | code | status |
|---|---|---|
| `finance.cash()` | `GameState.cash` `game_state.gd:31` | OKUNUYOR |
| `finance.mrr()` | `:32` | OKUNUYOR |
| `finance.peak_mrr()` | `:285` | OKUNUYOR |
| `finance.daily_burn()` | `:33` | OKUNUYOR |
| `finance.monthly_flow()` | `finance_system.gd:305` | VAR |
| `finance.daily_revenue()` | `game_state.gd:492` | VAR |
| `finance.net_daily_flow()` | `:495` | VAR |
| `finance.runway_months()` | `:498` | VAR — **`INF` when net ≥ 0** |
| `finance.burn_breakdown()` | `finance_system.gd:245` | VAR |
| `finance.transactions()` | `:298` | VAR, cap 50 |
| `finance.mrr_growth_streak(pct)` | `game_state.gd:548` | VAR |
| `finance.profitable_month_streak()` | `:563` | VAR |
| `finance.window_margin_pct(months)` | `:574` | VAR — **−1 = insufficient data** |
| `finance.investor_equity_pct()` | `:605` | VAR |
| `finance.total_raised()` | `:612` | VAR |
| `finance.shutter_days_left()` | `GameState.shutter_days_left` `:183` | OKUNUYOR — **−1 inactive, else 30..0** |
| `finance.shutter_days_total()` | `endings_system.gd:25` `SHUTTER_DAYS := 30` | VAR (const) |

**`finance.shutter_days_total()` is the seam that kills defect 9.**
`END_META_BANKRUPTCY_FRANK` says "yedi gün" while the constant is 30
(`localization/strings.csv:2026` vs `endings_system.gd:25`). Under §8.4 the number lives in the
seam and the copy interpolates it, so the sentence cannot go stale again.

`finance.runway_days()` and `finance.valuation()` — **YOK**, see §7.

---

## 5 · `sales.` · `musteri.` · `destek.`

**VAR:** `musteri.by_market(m)` `customer_registry.gd:65` · `musteri.total_mrr()` `:57` ·
`musteri.min_satisfaction(market)` `:93` · `musteri.lowest_satisfaction_customer(market)` `:108` ·
`musteri.top(n)` `:127` · `musteri.founder_managed_count()` `b2b_sales_system.gd:412` ·
`musteri.attention_count()` `:424` · `musteri.can_offer_retention(c)` `:225` ·
`musteri.can_offer_expansion(c)` `:278` · `musteri.promises_open(c)` `promise_registry.gd:39` ·
`musteri.has_open_promise(c)` `:47` · `sales.pipeline_count()` `prospect_registry.gd:28` ·
`sales.pipeline_optimistic_mrr()` `sales_system.gd:335` · `sales.can_pitch()` `pitch_system.gd:196` ·
`sales.b2c_audience()` `sales_system.gd:315` · `sales.conversion_rate(price)` `:527` ·
`sales.growth_band()` `:634` · `sales.is_b2b_market()` `:157` · `sales.market_share()`
`rival_registry.gd:199` · `destek.desk_throughput()` `customer_rep_system.gd:80` ·
`destek.absorb_ceiling()` `:213` · `destek.desk_staffed()` `support_system.gd:265` ·
`destek.warmth_band()` `:440` · `destek.daily_satisfaction_damage()` `:324` (cap −2.0/day)

**OKUNUYOR (wrapped):** `musteri.count()` (`get_active().size()`) ·
`musteri.satisfaction(c)` `customer.gd:39` · `musteri.tolerance(c)` `:50` — **the hidden
second layer**; the pair `satisfaction < tolerance` is the whole B2B risk model, so the engine
also publishes `musteri.under_tolerance(c)` as a wrapper · `musteri.trust_offset(c)` `:75`
(−25.0…+10.0) · `musteri.health(c)` `:38` · `musteri.lifecycle_phase(c)` `:48` ·
`musteri.churn_countdown(c)` `:51` (−1 inactive, else 7..0) · `musteri.risk_streak(c)` `:52` ·
`musteri.mrr(c)` `:33` · `musteri.seats(c)` `:34` · `musteri.scale(c)` `:49` ·
`musteri.assigned_to(c)` `:53` · `sales.b2c_price()` `game_state.gd:124`

### 5.1 · The `sales.` block after SATIŞ rev 6 (`sales_ledger.gd`)

§14 opened the module's own read surface the way Ekip §15.3 did — ahead of any content that
needs it, and with STABLE names. Every row below is a real function on `SalesLedger` unless
noted; the engine wraps none of them, because there is nothing left to wrap.

| seam | code | type | status |
|---|---|---|---|
| `sales.pipeline_count()` | `sales_ledger.gd:31` | int | VAR |
| `sales.lead_star(id)` | `:35` | int | VAR |
| `sales.lead_days_left(id)` | `:40` | int | VAR |
| `sales.lead_routing(id)` | `:45` | String | VAR |
| `sales.reach_band()` | `:63` → `SalesFaucetSystem.reach_band` | int | VAR — DERIVED, never stored (§13) |
| `sales.rep_band_cap(p)` | `:74` | int | VAR — `-1` IS the answer, not a gap |
| `sales.rep_busy(p)` | `:96` | String | VAR — "" = free |
| `sales.price_stance()` | `:109` | String | VAR — the SINGLE B2B price source (§7.5, §15) |
| `sales.open_pitch_promise()` | `:133` | String | VAR |
| `sales.loss_reason(account)` | `:180` | String | VAR |
| `sales.loss_log()` | `:196` | Array | VAR — UNPRUNED, on purpose (§5.2 "depo-öncesi") |
| `sales.deal_count(star)` | `:216` | int | VAR |
| `sales.last_signed_star()` | `:224` | int | VAR |
| `sales.whale_condition(account)` | `:228` | String | VAR |
| `sales.meeting_available_today()` | `:249` | bool | VAR |
| `sales.signing_discount(account)` | `:233` | float | VAR |
| `sales.seat_price(account)` | `:238` | int | VAR |

**Two rows retired with their machines.** `sales.can_pitch()` (`pitch_system.gd:196`) went
with the two-day cooldown; `sales.meeting_available_today()` is the rule that replaced it and
it answers a different question, so §6.1's "a changed meaning gets a new name" is honoured
rather than worked around. `sales.pipeline_optimistic_mrr()` still exists and still feeds the
Finance curve, but it reads seats × the stance price now rather than a retired display band.

**Not registered in `scripts/events/seams/`.** These are the MODULE's catalogue; the engine's
allowlist binds what content actually asks for, and no card asks yet. Registering them is a
`seams_sales.gd` edit and therefore the event package's call, not this task's — the names are
stable so that call is a one-liner when it comes.

---

**Note for content:** `musteri.tolerance` is deliberately hidden from the player. A card may
*condition* on it; a card may not *name* it. That is a writing rule, not an engine rule, and it
goes in the vocabulary doc.

---

## 6 · `phase.` · `rival.` · `investor.` · `time.` · `founder.`

**`phase.`** — `phase.current()` (`GameState.phase`, 1/2/3, OKUNUYOR) ·
`phase.name(p)` `game_state.gd:417` VAR · `phase.gate_ready()` `:180` OKUNUYOR ·
`phase.series_a_signal()` `phase_gate_system.gd:198` **VAR — and load-bearing**: it is the
single home the Finance indicator, the product page and the ODA board all paint from ·
`phase.gate_declines()` OKUNUYOR

⚠️ **`phase_gate_system.gd:200-215` walks the gate's condition array leaf-by-leaf**, switching
on each leaf's `type` to build that readout. It is a *consumer of the condition vocabulary's
shape*, not just of its result. The nested vocabulary must therefore ship a leaf-enumeration
API in the same phase it ships nesting.

**`rival.`** — `rival.all()` `rival_registry.gd:62` · `rival.market_snapshot(sub)` `:164`
(sums to 100) · `rival.player_share_pct()` `:199` · `rival.player_rank()` `:88` ·
`rival.format_share(pct)` `:203` — all VAR. `rival.status(id)` / `momentum(id)` / axes are
OKUNUYOR off `Rival`. `news.stream()` `news_feed_system.gd:185` VAR.

**`investor.`** — `investor.all()` / `active()` / `get(id)` `investor_registry.gd:112/:117/:105`
VAR · `investor.sheet_for(vc)` `vc_pitch_system.gd:382` VAR ·
`investor.meeting_active()` `:46` VAR · `investor.seed_conviction(vc)` `:116` VAR ·
`investor.prep_blocked_reason(vc)` `:406` VAR. `vc_states` / `active_sheets` /
`pending_meeting` / `vc_rejections` / `pivot_used` / `series_a_closed` are OKUNUYOR off
`GameState`.

**`time.`** — `time.day()` (`GameState.day`, starts 1) and `time.hour()` (`:37`, 0–23) are
OKUNUYOR; **`GameState` owns both and TimeManager keeps no copy** (`time_manager.gd:23-26`).
`time.date()` `game_state.gd:643` VAR — **the single day→calendar conversion**, anchor
2026-01-01, so Day 1 is a Thursday · `time.month_name(day)` `:655` VAR ·
`time.months_elapsed_since(d)` `:659` VAR (calendar months, may be negative) ·
`time.speed()` (`TimeManager.current_speed`, 0–3) OKUNUYOR · `time.run_active()` OKUNUYOR.
`time.is_paused()` — **YOK**, wrapped as `speed() == 0`.

**`founder.`** — `founder.skill(name)` `game_state.gd:630` VAR, with a `push_error` tripwire on
retired skill names · `founder.charisma` via the same seam · `founder.task_state()`
`hr_system.gd:254` VAR (seven mutually exclusive states, contract-tested at
`endgame_smoke.gd:8130`) · `founder.is_busy()` VAR · `founder.origin` `game_state.gd:22` +
`founder_constants.gd:238` VAR · `founder.traits` OKUNUYOR · `founder.equity_pct` OKUNUYOR
(derived as `100 − investor_equity_pct`).

**The founder is a `Character` with `category == "founder"`**, not a separate class
(`game_state.gd:948-1006`), and `CharacterRegistry.get_employees()` filters him out — so
`hr.headcount()` excludes him by construction and the employee selector can never return him.
That is §4.3's rule already holding in the data model.

---

## 7 · YOK — filed against the owning module

Each row is open work for the module that owns the state. The engine does **not** invent these.

| seam | owner | why it is needed | note |
|---|---|---|---|
| `hr.salary_vs_band(p)` | **Ekip** | I7: the GDD's own §9.7 table lists "maaşın banda göre konumu" as a retention modifier with **status YOK**. Without it the line cannot be written. | Both halves exist — `hr_constants.gd:835 salary_band_for_level` and `Character.monthly_salary` — but **zero production readers compare a sitting employee to the band** (the only comparison in the tree is a test, `endgame_smoke.gd:8360`). `hr_actions.gd:140-143` documents the *opposite* rule: a promotion does not reseat salary into the new band, so promoted staff drift below it by design and nothing reads the drift. Engine wraps it meanwhile. |
| `hr.raise_edge` | **Ekip** | `EventBus.raise_requested` is declared and never emitted; §9.2 makes raises a *player* action and defines no employee-side trigger | The engine opens the emit site because §15.2 requires it, which means **choosing an edge — a design ruling**. Flagged for Hat-1. |
| `hr.promotion_edge` | **Ekip** | `employee_eligible_for_promotion` likewise. `event_bus.gd:90-94` says outright that §9.3 gives promotion **no condition beyond the level ceiling**, so there is no GDD-defined edge to fire | Same. Proposed: the existing `experience_bar_full` edge AND `level < 2`. |
| `finance.valuation()` | **Yatırım** | An acquisition/soft-cap card wanting to name a number has none | `GameState.run_valuation_m` is **write-only**, set at signing (`vc_pitch_system.gd:326`); `endings_system.gd:363` says plainly there is no company valuation in normal play, and Kişisel renders three em-dashes for it. |
| `finance.runway_days()` | **Finans** | The shutter and the soft cap are day-counted; runway is month-counted | Exists only inside *display* code (`ui_tokens.gd:785`, and `_runway_days_text` is private). Engine wraps `runway_months() × 30` meanwhile — but `INF` must be handled, not multiplied. |
| `urun.tech_debt()` as a level | **Ürün** | Only a boolean exists | Ürün rev6.1 §20 lists tech debt among "KALDIRILANLAR" for the demo, so this may stay boolean by design. Recorded, not pressed. |
| `sales.market_share_by_segment()` | **Satış** | GDD v2 ch.04 §7 and ch.10 §2 both want per-segment share | Today share is one global number derived from MRR (`rival_registry.gd:199`). Segments do not exist yet. |
| `founder.energy()` | **Ekip / Kişisel** | GDD v2 ch.02 §6 specifies an energy bar that triggers events | Does not exist and `hr_morale_system.gd:213-218` records it as out of demo scope. |
| `destek.queue_length()` | **Operasyon** | A support-load card would ask this | `customer_rep_system.gd:184 _open_requests()` is private. Reachable via `Customer.support_request_since_day`; wrapped meanwhile. |
| `rival.is_ahead_of_player()` | **Rakipler** | Rival-move cards | Exists but private and in the wrong module (`vc_pitch_system.gd:827`). |

---

## 8 · The seam contract clause for future module tasks (§6.4)

Copied verbatim into every module task written from here on:

> **SEAM SÖZLEŞMESİ:** Bu modül şu isimli, salt-okunur sorguları açar: *[liste]*. Seam'ler
> `SeamRegistry`'ye kaydedilir ve `docs/SEAM_REGISTRY.md`'ye işlenir. Modül "bitti" sayılmaz
> eğer seam'leri kayıtlı değilse.

That is what stops the next module — Pazarlama, Operasyon, the R&D continuation — from being
born needing a retrofit.

## 9 · Signals

The write side of the same idea lives in
[`EVENT_SIGNAL_MANIFEST.md`](EVENT_SIGNAL_MANIFEST.md): which system emits what, who listens,
and which declared signals have no emitter.

---

## 10 · `funding.` — the port's own namespace, and one deletion

The `funding.` seams did not exist when this registry was first written: they were added during
the migration, wrapping values the code-built families used to read directly out of their own
systems. Each is a WRAPPER — no module gained a method for it.

| seam | type | reads | note |
|---|---|---|---|
| `funding.angel_threshold_met` | BOOL | `GameState.mrr >= AngelRoundSystem.MRR_THRESHOLD` | the bar Frank's cheque waits on |
| `funding.angel_days_since_accept` | INT | `angel_seed_accepted_day` | **-1** when the cheque has not landed. The hire nudge's two-day delay reads this, and the reason matters: it first read `days_since_flag` on an ENGINE flag nothing stamps, which is §19.5's failure — a condition asking the wrong store is false forever and looks like a design decision |
| `funding.hard_mode` | BOOL | `GameState.get_flag("hard_mode_unlocked")` | RESERVED — no writer exists anywhere. It is the honest lock on Frank's decline row, and it is a seam for the same reason as the row above |
| `funding.gate_pending_phase` | INT | `GameState.pending_next_phase` | 0 when no gate is open |
| `funding.sheet_days_left` | INT | the MINIMUM across live sheets | 9999 with no sheet, so a `<= 3` test cannot be satisfied by having none |
| `funding.last_answer_moment` | BOOL | `VCPitchSystem.is_last_answer_moment()` | one sheet, one day left, no other table to walk to. The predicate stayed in the system; only the QUESTION moved |
| `funding.meeting_day_arrived` | BOOL | `GameState.pending_meeting` | a booked meeting's day has come |

**Deleted: `funding.angel_offered`.** It wrapped `angel_seed_offered`, a hand-rolled one-shot
that went with the old engine. A seam over a flag nothing writes is a seam that answers `false`
forever, which is worse than an absent one — an absent seam is a lint error, a false one is a
card that never fires.

## 11 · `musteri.` additions from the port

`musteri.is_at_risk` · `is_expansion_ready` · `has_pain_feature` · `pain_feature_shipped` ·
`discounts_used` · `stalls_used` · `cs_escalated` · `request_kind` · `company_name` ·
`complaint_voice` · `sector_contact` · `pain_feature_label`.

Two of them are worth naming individually.

**`musteri.request_kind`** wraps `B2BEventFactory.pick_request_kind`, the state-scored rule that
decides what an account is calling about. That rule is the ONLY thing left of the factory, and
it survived for a reason: the branch it picks used to be chosen at construction time, written
into `last_request_kind`, and read by nothing. Three cards read it through this seam now, so
the branch is a condition the "why didn't this fire" panel can name.

**`musteri.complaint_voice`** returns PROSE, not a number — the per-sector complaint line. It is
the reason §8.4's `{seam:…}` interpolation exists for strings as well as figures: one card
carrying `{seam:musteri.complaint_voice}` replaces fifteen near-identical cards each with one
sector's sentence baked in.

## 12 · Coverage, measured

147 seams registered; **36 read by the 43 cards that exist today**. The other 111 are not dead
weight and not a defect — they are the vocabulary the writing round inherits, and the registry's
job is to have them ready before anyone needs them. What would be a defect is the reverse: a
card reading a name nothing registers, and `event_i7_modifier_needs_seam` plus the linter's
condition walk both check for that in every card, in both directions.
