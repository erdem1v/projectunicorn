# Event authoring · vocabulary

**GENERATED from the engine — do not hand-edit outside the marked block.**
Regenerate: `godot --headless --path . --event-vocab`

Every card may use only what is listed here. Anything a draft wants that is not
here is written `[VOCAB?] <what it wants>` for an effect or `[COND?] <…>` for a
prerequisite, and the node is not wired until the item ships. Nothing is invented —
that rule is GDD v2 ch.11 §3, and §21's DELTA workflow is how an item gets added.

Counts are what the engine actually has, at generation time:

| | count |
|---|---|
| Seams (read) | **162** |
| Effect verbs (write) | **61** |
| Cards in the catalogue | 38 |
| Arcs | 3 |

## a · Effect verbs

**The grouping IS the rule.** An effect's origin decides what it may do — that is
invariant I2, and it is enforced by the dispatch table rather than by a lint pass,
so a verb absent from a group is unreachable from it rather than merely discouraged.

| origin | may use |
|---|---|
| an option's `effects` | neutral + economic + terminal |
| `on_expire.penalties` | neutral + economic **negative only** |
| `on_invalidate.penalties`, arc auto-steps, signal handlers | neutral only |
| a `check` branch | neutral + economic, **never terminal** (I6) |

### Neutral — available everywhere

- `set_flag`
- `clear_flag`
- `set_timed_flag`
- `stamp_day`
- `schedule_event`
- `cancel_scheduled`
- `start_arc`
- `advance_arc`
- `set_arc_var`
- `abort_arc`
- `end_arc`
- `change_morale`
- `morale_all`
- `assign_to`
- `send_on_leave`
- `start_training`
- `dimension_delta`
- `bug_delta`
- `delay_days`
- `damage_product`
- `ship_active_build`
- `enter_development`
- `enter_beta`
- `satisfaction_delta`
- `promise_create`
- `ticker_push`
- `goto_tab`
- `unlock_content`
- `spend_budget`
- `notify`
- `open_negotiation`
- `start_vc_meeting`
- `open_term_table`
- `advance_phase`
- `phase_gate_decline`
- `open_seed_table`
- `decline_buyout`
- `decline_offer`
- `set_game_flag`
- `mentor_advisory`
- `b2b_retain_delay`
- `b2b_retain_ignore`
- `b2b_expand_decline`

### Economic — a played decision only

Barred from ambient origins entirely; on expiry, allowed only in the negative.

- `add_cash`
- `add_mrr`
- `add_brand`
- `add_reputation`
- `add_customer`
- `churn_customer`
- `customer_mrr_delta`
- `seats`
- `audience_delta`
- `convert_audience`
- `open_paid_tier`
- `change_salary`
- `fire_employee`
- `employee_leaves`
- `add_prospect`
- `angel_accept`
- `b2b_expand`
- `b2b_retain_discount`

### Terminal

Requires `requires_telegraph` naming a card or flag that has already fired (I3).

- `trigger_ending`

## b · Seams — everything a condition may read

A name not on this list is a **build error** (§17.1), not a runtime warning. An
entity-scoped seam needs a `scope` naming the slot when the card has more than one
slot of that type (§17.12).

### `arge.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `arge.active` | global | string | R&D | the running node id, or empty; exactly one at a time |
| `arge.attention_count` | global | int | R&D | what the rail badge counts |
| `arge.completed_count` | global | int | R&D | 0-20 |
| `arge.is_frozen` | global | bool | R&D | research with nobody assigned; progress is preserved, not lost |
| `arge.note_pending` | global | bool | R&D | an unread monthly product note is waiting |
| `arge.tree_open` | global | bool | R&D | the tab is reachable |

### `destek.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `destek.absorb_ceiling` | global | int | Ops | requests the desk can take before escalating |
| `destek.desk_staffed` | global | bool | Ops | anyone on support at all |
| `destek.warmth_band` | global | string | Ops | calm | warm | hot at 20 / 40 unvalidated reports |

### `finance.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `finance.brand` | global | int | Finance | WRAPPER; clamped 0-100 |
| `finance.cash` | global | int | Finance | WRAPPER over GameState.cash; MAY BE NEGATIVE, which is what starts the shutter |
| `finance.daily_burn` | global | int | Finance | WRAPPER; day 1 is $50 |
| `finance.daily_net` | global | int | Finance | signed |
| `finance.growth_streak_months` | global | int | Finance | consecutive closed months of MRR growth |
| `finance.investor_equity_pct` | global | int | Finance | 0-100 |
| `finance.months_closed` | global | int | Finance | WRAPPER; capped at 12 by the ledger |
| `finance.mrr` | global | int | Finance | WRAPPER; the headline revenue number |
| `finance.peak_mrr` | global | int | Finance | WRAPPER; high-water mark |
| `finance.profit_streak_months` | global | int | Finance | consecutive closed months in the black with no red days |
| `finance.reputation` | global | int | Finance | WRAPPER; clamped -10..100 |
| `finance.runway_days` | global | int | Finance | WRAPPER, filed as YOK; 9999 stands for default-alive |
| `finance.runway_months` | global | float | Finance | INF when net >= 0 — compare with '<', never '>' |
| `finance.shutter_days_left` | global | int | Finance | WRAPPER; -1 when not counting, else counts down |
| `finance.shutter_days_total` | global | int | Finance | the shutter window; card text interpolates this rather than typing it |
| `finance.total_raised` | global | int | Finance | cash in from all rounds |

### `founder.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `founder.charisma` | global | int | HR | 0-10 on the shared ruler; pitch and scandal outcomes read it |
| `founder.equity_pct` | global | int | HR | WRAPPER: the complement of the investor total |
| `founder.is_busy` | global | bool | HR | assigned, in training, or preparing a pitch |
| `founder.leadership` | global | int | HR | 0-10; the morale ceiling and the team output multiplier |
| `founder.origin` | global | string | HR | self_made | heir | corporate_refugee |
| `founder.skill` | global | int | Founder | the skill a check leaned on; the specific seam wins when one exists |
| `founder.task_state` | global | string | HR | build | sales | support | research | pitch_prep | training | idle |

### `funding.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `funding.acq_days_open` | global | int | Funding | -1 until the road closes; the buyout window is measured from that stamp |
| `funding.acq_offer` | global | string | Funding | the founder's slice of that price — what the sealed line calls 'your share' |
| `funding.acq_road_over` | global | bool | Funding | faced Series A by a decline or a walk, and no table is left to walk to |
| `funding.acq_valuation` | global | string | Funding | the buyer's price for the whole company: ARR x multiple |
| `funding.angel_days_since_accept` | global | int | Investment | -1 when the cheque has not landed; the day stamp stays in GameState |
| `funding.angel_threshold_met` | global | bool | Funding | MRR has crossed the bar Frank's cheque waits on |
| `funding.gate_pending_phase` | global | int | Funding | WRAPPER; 0 when no gate is open |
| `funding.hard_mode` | global | bool | Funding | RESERVED — no writer exists; the honest lock on Frank's decline row |
| `funding.last_answer_moment` | global | bool | Investment | one sheet, one day left, and no other table to walk to |
| `funding.meeting_day_arrived` | global | bool | Funding | a booked meeting's day has come |
| `funding.seed_band` | global | int | Funding | 0 harsh · 1 standard · 2 strong — an INDEX, for by_seam bodies |
| `funding.seed_days_since_close` | global | int | Funding | -1 until the round closes; mirrors funding.angel_days_since_accept |
| `funding.seed_door_open` | global | bool | Funding | the Traction-phase door is latched and unspent |
| `funding.seed_expectation` | global | int | Funding | 0 none · 1 grace · 2 on track · 3 durgun (SeedConstants.EXPECT_*) |
| `funding.seed_offer_live` | global | bool | Funding | an unsigned seed offer is on the table; it never expires |
| `funding.seed_pitch_used` | global | bool | Funding | the run's one seed meeting has been spent |
| `funding.seed_taken` | global | bool | Funding | a seed round was signed this run |
| `funding.sheet_days_left` | global | int | Funding | 9999 when no sheet is live |

### `hr.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `hr.account_count` | entity | int | HR | how many accounts this person carries |
| `hr.attention_count` | global | int | HR | what the rail badge counts |
| `hr.candidates_ready` | global | bool | HR | the Atlas search has delivered |
| `hr.experience_ratio` | entity | float | HR | 0.0-1.0 toward the next threshold |
| `hr.flight_risk` | entity | bool | HR | WRAPPER: morale under 35 |
| `hr.headcount` | global | int | HR | active employees; excludes the founder and the mentor by construction |
| `hr.idle_count` | global | int | HR | employees with no job |
| `hr.is_busy` | entity | bool | HR | leave or training, plus pitch prep for the founder |
| `hr.is_idle` | entity | bool | HR | an employee with no job at all |
| `hr.is_overloaded` | entity | bool | HR | more than one job |
| `hr.job_count` | entity | int | HR | 0, 1 or 2 |
| `hr.level` | entity | int | HR | WRAPPER over Character.level. 0 = junior, 1 = mid, 2 = senior |
| `hr.morale` | entity | int | HR | 0-100 |
| `hr.morale_avg` | global | float | HR | 0.0-100.0, and 0.0 when there are no employees at all |
| `hr.morale_band` | entity | string | HR | high | mid | low, at 80 / 50 / 35 |
| `hr.overtime_active` | entity | bool | HR | hours above 8 |
| `hr.payroll_monthly` | global | int | HR | not status-filtered: leave is paid |
| `hr.raise_cooldown_left` | entity | int | HR | days until a raise is allowed again; 0 means now |
| `hr.resign_voice` | entity | string | HR | the per-person resignation line |
| `hr.salary` | entity | int | HR | WRAPPER over Character.monthly_salary, USD/month |
| `hr.salary_band_position` | entity | float | HR | WRAPPER, filed as YOK: <0 under the band, 0..1 inside it |
| `hr.short_day_active` | entity | bool | HR | hours below 8 |
| `hr.status` | entity | string | HR | active | on_leave | training |
| `hr.tenure_days` | entity | int | HR | days on the payroll; 0 when hire_day was never stamped |
| `hr.unstaffed_job_count` | global | int | HR | jobs nobody is assigned to |
| `hr.work_hours` | entity | int | HR | 5-11, the resolved inheritance chain, default 8 |
| `hr.work_hours_company` | global | int | HR | the company base, 5-11 |

### `investor.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `investor.angel_taken` | global | bool | Funding | WRAPPER; Frank's cheque was accepted |
| `investor.leverage` | global | int | Investment | the table-side bonus a check adds; 0 outside a sitting |
| `investor.meeting_pending` | global | bool | Funding | WRAPPER; one at a time by construction |
| `investor.pivot_used` | global | bool | Funding | WRAPPER; the VC path is permanently closed |
| `investor.rejections` | global | int | Funding | WRAPPER; three closed tables reach the cascade |
| `investor.series_a_closed` | global | bool | Funding | WRAPPER |
| `investor.sheets_live` | global | int | Funding | WRAPPER; term sheets in hand |

### `musteri.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `musteri.at_risk_count` | global | int | Sales | accounts currently in Risk |
| `musteri.churn_countdown` | entity | int | Sales | WRAPPER; -1 when not counting, else days to churn |
| `musteri.company_name` | entity | string | Sales | for {customer} in prose |
| `musteri.complaint_voice` | entity | string | Sales | the per-sector complaint line |
| `musteri.count` | global | int | Sales | active customer RECORDS — includes the B2C aggregate; see sales.account_count |
| `musteri.cs_escalated` | entity | bool | Sales | an escalation is already open on this account |
| `musteri.discounts_used` | entity | int | Sales | 0-2; the discount row locks at the cap |
| `musteri.has_open_promise` | entity | bool | Sales | a feature was promised and has not resolved |
| `musteri.has_pain_feature` | entity | bool | Sales | the account wants a specific feature |
| `musteri.is_assigned` | entity | bool | Sales | WRAPPER; a CS rep carries it, rather than the founder |
| `musteri.is_at_risk` | entity | bool | Sales | the account is in a Risk episode |
| `musteri.is_expansion_ready` | entity | bool | Sales | mature, healthy, and never yet offered expansion |
| `musteri.lifecycle_phase` | entity | string | Sales | onboarding | active | risk | churning | expansion |
| `musteri.lost_this_run` | global | int | Sales | WRAPPER; churn counter |
| `musteri.min_satisfaction` | global | int | Sales | worst account |
| `musteri.mrr` | entity | int | Sales | WRAPPER |
| `musteri.pain_feature_label` | entity | string | Sales | the feature the promise row names |
| `musteri.pain_feature_shipped` | entity | bool | Sales | gates the promise row: promising work already done pays for nothing |
| `musteri.request_kind` | entity | string | Sales | complaint | feature | renewal — state-scored, no RNG |
| `musteri.satisfaction` | entity | int | Sales | WRAPPER; 0-100, the number the player can see |
| `musteri.scale` | entity | int | Sales | WRAPPER; 1-5, demo binds to 1-3 |
| `musteri.seats` | entity | int | Sales | WRAPPER |
| `musteri.sector_contact` | entity | string | Sales | the speaker's role line |
| `musteri.stalls_used` | entity | int | Sales | 0-2; the stall row locks at the cap |
| `musteri.tenure_days` | entity | int | Sales | WRAPPER; days since signature |
| `musteri.tolerance` | entity | int | Sales | WRAPPER; HIDDEN from the player. Condition on it, never name it in copy |
| `musteri.total_mrr` | global | int | Sales |  |
| `musteri.under_tolerance` | entity | bool | Sales | the comparison that actually drives Risk |

### `phase.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `phase.current` | global | int | Phase | WRAPPER; 1 Bootstrap, 2 Traction, 3 Series A Hunt |
| `phase.gate_declines` | global | int | Phase | WRAPPER; how many times the player has said not yet |
| `phase.gate_ready` | global | bool | Phase | WRAPPER; a transition is open and unanswered |
| `phase.name` | global | string | Phase | for prose |
| `phase.series_a_signal` | global | string | Phase | closed | warming | open. The number behind it is deliberately not a seam |

### `rival.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `rival.count` | global | int | Rivals |  |
| `rival.momentum` | entity | float | Rivals | WRAPPER; zero for the giants, who do not accelerate |
| `rival.player_share_pct` | global | float | Rivals | 0.0-90.0, derived from MRR against a fixed market total |
| `rival.status` | entity | string | Rivals | WRAPPER; DOMINANT | STEADY | SCALING | QUIET |

### `sales.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `sales.account_count` | global | int | Sales | accounts in the book; excludes the B2C aggregate userbase |
| `sales.b2c_audience` | global | float | Sales | float: it carries a sub-unit accumulator |
| `sales.b2c_price` | global | int | Sales | WRAPPER; monthly price |
| `sales.growth_band` | global | string | Sales |  |
| `sales.is_b2b` | global | bool | Sales | reads the SHIPPED market, not one being built |
| `sales.market_share_pct` | global | float | Sales | one global figure; per-segment share does not exist yet |
| `sales.pipeline_count` | global | int | Sales | live prospects |
| `sales.weekly_closes` | global | string | Sales | this week's closes, one line each, with a total |

### `time.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `time.day` | global | int | Time | WRAPPER; absolute game day, starts at 1. GameState owns it, not TimeManager |
| `time.hour` | global | int | Time | WRAPPER; 0-23 |
| `time.is_paused` | global | bool | Time | WRAPPER, filed as YOK: there is no named predicate for this |
| `time.month` | global | int | Time | 1-12; real month lengths, not 30-day blocks |
| `time.run_active` | global | bool | Time | WRAPPER; false once a terminal has fired |
| `time.speed` | global | int | Time | WRAPPER; 0 paused, 1-3. The 4x rung was removed 2026-08-19 |
| `time.weekday` | global | int | Time | 0-6 from the real calendar; day 1 is a Thursday, 1 Jan 2026 |

### `urun.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `urun.axis_experience` | global | int | Product | 0-120 |
| `urun.axis_innovation` | global | int | Product | 0-120 |
| `urun.axis_stability` | global | int | Product | 0-120 |
| `urun.bugs_confirmed` | global | int | Product | confirmed live bugs |
| `urun.bugs_unconfirmed` | global | int | Product | incoming, unvalidated reports |
| `urun.build_active` | global | bool | Product | a version is being built |
| `urun.build_paused` | global | bool | Product | auto or manual |
| `urun.build_progress` | global | float | Product | 0.0-1.0 |
| `urun.capacity_tier` | global | int | Product | provisioned infra units |
| `urun.days_since_launch` | global | int | Product | -1 when nothing has shipped |
| `urun.floor_experience` | global | string | Product | '' | warning | crossed |
| `urun.floor_innovation` | global | string | Product | '' | warning | crossed |
| `urun.floor_stability` | global | string | Product | '' | warning | crossed |
| `urun.interest` | global | float | Product | 0-100, refreshed on publish, 30-day half-life |
| `urun.is_live` | global | bool | Product | something has shipped |
| `urun.iteration_round` | global | int | Product | design rounds completed on the active build |
| `urun.lines_open` | global | int | Product | 0-9 feature lines opened |
| `urun.market_type` | global | string | Product | b2b | b2c; empty until the first ship writes it |
| `urun.phase` | global | string | Product | concept | design | development | beta | support; empty before anything exists |
| `urun.steps_shipped` | global | int | Product | feature steps live |
| `urun.subtype` | global | string | Product | one of the sub-product ids |
| `urun.support_staffed` | global | bool | Product | the module's central pressure reads from this one boolean |
| `urun.tech_debt` | global | bool | Product | WRAPPER over a flag; boolean by design in the demo |
| `urun.usage` | global | float | Product | load multiplier |
| `urun.version` | global | int | Product | shipped version number |
| `urun.version_age` | global | int | Product | days since THIS VERSION shipped, not since the product was born |

## c · Condition vocabulary

Nested dictionaries. Combinators: `all` (AND) · `any` (OR) · `none` · `not`.
An empty `all` is TRUE, an empty `any` is FALSE, an empty `none` is TRUE.

A node may carry `"reason"` — one authored sentence shown when it refuses. An
`any` that gates an option **must** carry one: when a disjunction fails, every
branch failed, and naming one of them is arbitrary and usually misleading.

```json
{"seam": "hr.headcount", "op": ">=", "value": 3}
{"seam": "phase.current", "op": "in", "value": [2, 3]}
{"flag": "frank_seed_taken"}
{"flag_unset": "acquisition_declined"}
{"days_since_flag": "mvp_launch", "op": ">=", "value": 30}
{"flag_expires_within": "negotiation_window", "days": 3}
{"history": "chose", "event": "hr.raise_request", "option": "accept"}
{"history": "fired", "event": "hr.raise_request"}
{"history": "days_since", "event": "hr.raise_request", "op": ">=", "value": 30}
{"history": "resolution", "event": "sales.offer", "value": "expired"}
{"arc": "active", "id": "arc_promise_mobile"}
{"arc": "at_step", "id": "arc_promise_mobile", "step": 2}
{"arc": "ended", "id": "arc_promise_mobile", "outcome": "kept"}
{"entity_exists": "employee_a"}
{"entity_count": "employee", "op": ">=", "value": 2}
{"entity_seam": "hr.morale", "scope": "employee_a", "op": "<", "value": 50}
```

**A flag is engine memory, not game state.** `flag` and `flag_unset` read the
engine's own store. Anything a SYSTEM owns — `series_a_closed`, `mvp_shipped` —
is read through its seam, never as a flag: the engine store has never heard of it,
so `flag_unset` would silently read true forever.

## d · Arcs in the catalogue

| arc | type | policy | steps |
|---|---|---|---|
| `arc_final_stretch` | world | fade | 2 |
| `arc_fixture_subject` | assignment | reassign | 1 |
| `arc_fixture_thesis` | promise | close | 2 |

<!-- HAND-WRITTEN — REGENERATION SKIPS THIS BLOCK -->
## e · Hand-written notes

This block survives regeneration. The three sections worth keeping here are the ones
the old file carried and nobody would reconstruct: the **trigger-hook map** (draft
hook name → the signal and file:line that fires it today), the **legacy-function map**
(every retired card id → the arc node that inherited its job), and the list of
**known gaps** the engine has not closed.
<!-- END HAND-WRITTEN -->
