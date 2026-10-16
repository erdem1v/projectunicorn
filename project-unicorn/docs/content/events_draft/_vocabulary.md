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
| Seams (read) | **195** |
| Effect verbs (write) | **63** |
| Cards in the catalogue | 97 |
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
- `productivity_mod`
- `work_hours`
- `damage_product`
- `sprint_card_effort`
- `sprint_card_progress`
- `sprint_card_carry`
- `sprint_hours`
- `satisfaction_delta`
- `promise_create`
- `ticker_push`
- `goto_tab`
- `unlock_content`
- `spend_budget`
- `notify`
- `open_negotiation`
- `open_term_table`
- `advance_phase`
- `phase_gate_decline`
- `open_seed_table`
- `decline_buyout`
- `decline_offer`
- `investor_strain`
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
- `marketing_push`

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

### `build.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `build.last_unlocked_module` | global | string | Build | the module whose page opened most recently; empty before any does |
| `build.module_unlocked.events` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the events page is reachable in this build |
| `build.module_unlocked.finance` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the finance page is reachable in this build |
| `build.module_unlocked.hr` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the hr page is reachable in this build |
| `build.module_unlocked.marketing` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the marketing page is reachable in this build |
| `build.module_unlocked.personal` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the personal page is reachable in this build |
| `build.module_unlocked.piyasa` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the piyasa page is reachable in this build |
| `build.module_unlocked.product` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the product page is reachable in this build |
| `build.module_unlocked.rnd` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the rnd page is reachable in this build. Never gated; the Ar-Ge tree's own door is arge.tree_open |
| `build.module_unlocked.sales` | global | bool | Build | WRAPPER over ModuleLocks.is_open; the sales page is reachable in this build |

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
| `finance.daily_burn` | global | int | Finance | WRAPPER; a per-day rate, $50 at the start |
| `finance.daily_net` | global | int | Finance | signed; a per-day rate |
| `finance.growth_streak_months` | global | int | Finance | consecutive closed months of MRR growth |
| `finance.investor_equity_pct` | global | int | Finance | 0-100 |
| `finance.months_closed` | global | int | Finance | WRAPPER; capped at 12 by the ledger |
| `finance.mrr` | global | int | Finance | WRAPPER; the headline revenue number |
| `finance.peak_mrr` | global | int | Finance | WRAPPER; high-water mark |
| `finance.profit_streak_months` | global | int | Finance | consecutive closed months in the black with no red weeks |
| `finance.reputation` | global | int | Finance | WRAPPER; clamped -10..100 |
| `finance.runway_months` | global | float | Finance | INF when net >= 0 — compare with '<', never '>' |
| `finance.runway_weeks` | global | int | Finance | WRAPPER; 9999 stands for default-alive |
| `finance.shutter_weeks_left` | global | int | Finance | WRAPPER; -1 when not counting, else weeks left |
| `finance.shutter_weeks_total` | global | int | Finance | the shutter window in weeks; card text interpolates this rather than typing it |
| `finance.total_raised` | global | int | Finance | cash in from all rounds |
| `finance.valuation` | global | float | Finance | post-money in $M: the signed Series A's, else the Seed's, else 0.0 |

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
| `funding.acq_offer` | global | string | Funding | the founder's slice of that price — what the sealed line calls 'your share' |
| `funding.acq_road_over` | global | bool | Funding | faced Series A by a decline or a walk, and no table is left to walk to |
| `funding.acq_valuation` | global | string | Funding | the buyer's price for the whole company: ARR x multiple |
| `funding.acq_weeks_open` | global | int | Funding | -1 until the road closes; the buyout window is measured from that stamp |
| `funding.angel_threshold_met` | global | bool | Funding | MRR has crossed the bar Frank's cheque waits on |
| `funding.angel_weeks_since_accept` | global | int | Investment | -1 when the cheque has not landed; the tick stamp stays in GameState |
| `funding.gate_pending_phase` | global | int | Funding | WRAPPER; 0 when no gate is open |
| `funding.hard_mode` | global | bool | Funding | RESERVED — no writer exists; the honest lock on Frank's decline row |
| `funding.last_answer_moment` | global | bool | Investment | one sheet, one week left, and no other table to walk to |
| `funding.seed_band` | global | int | Funding | 0 harsh · 1 standard · 2 strong — an INDEX, for by_seam bodies |
| `funding.seed_door_open` | global | bool | Funding | the Traction-phase door is latched and unspent |
| `funding.seed_expectation` | global | int | Funding | 0 none · 1 grace · 2 on track · 3 durgun (SeedConstants.EXPECT_*) |
| `funding.seed_offer_live` | global | bool | Funding | an unsigned seed offer is on the table; it never expires |
| `funding.seed_pitch_used` | global | bool | Funding | the run's one seed meeting has been spent |
| `funding.seed_taken` | global | bool | Funding | a seed round was signed this run |
| `funding.seed_weeks_since_close` | global | int | Funding | -1 until the round closes; mirrors funding.angel_weeks_since_accept |
| `funding.sheet_days_left` | global | int | Funding | sheet_expiry body text only; the weeks above in days |
| `funding.sheet_decision_due` | global | bool | Funding | a Series A sheet's window has closed and waits for sit-or-decline |
| `funding.sheet_weeks_left` | global | int | Funding | weeks; 9999 when no sheet is live |
| `funding.table_sitting_open` | global | bool | Funding | the term-sheet table can open now |

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
| `hr.job` | entity | string | HR | WRAPPER: the first job held, build | test | support | accounts | sales | research; "" with none |
| `hr.job_count` | entity | int | HR | 0, 1 or 2 |
| `hr.leave_cooldown_left` | entity | int | HR | weeks until the player may send this person on leave again; 0 means now |
| `hr.level` | entity | int | HR | WRAPPER over Character.level. 0 = junior, 1 = mid, 2 = senior |
| `hr.morale` | entity | int | HR | 0-100 |
| `hr.morale_avg` | global | float | HR | 0.0-100.0, and 0.0 when there are no employees at all |
| `hr.morale_band` | entity | string | HR | high | mid | low, at 80 / 50 / 35 |
| `hr.overtime_active` | entity | bool | HR | hours above 8 |
| `hr.payroll_monthly` | global | int | HR | not status-filtered: leave is paid |
| `hr.raise_cooldown_left` | entity | int | HR | weeks until a raise is allowed again; 0 means now |
| `hr.resign_voice` | entity | string | HR | the per-person resignation line |
| `hr.run_hires` | global | int | HR | WRAPPER; hires made this run, the founder excluded. Counts a person who has since left |
| `hr.salary` | entity | int | HR | WRAPPER over Character.monthly_salary, USD/month |
| `hr.salary_band_position` | entity | float | HR | WRAPPER: <0 under the band, 0..1 inside it |
| `hr.short_day_active` | entity | bool | HR | hours below 8 |
| `hr.status` | entity | string | HR | active | on_leave | training |
| `hr.tenure_weeks` | entity | int | HR | weeks on the payroll; 0 when hire_day was never stamped |
| `hr.unstaffed_job_count` | global | int | HR | jobs nobody is assigned to |
| `hr.weeks_since_last_hire` | global | int | HR | the youngest active employee's tenure in weeks; -1 while there is nobody |
| `hr.work_hours` | entity | int | HR | 5-16, the resolved inheritance chain, default 8 |
| `hr.work_hours_company` | global | int | HR | the company base, 5-16 |

### `investor.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `investor.angel_taken` | global | bool | Funding | WRAPPER; Frank's cheque was accepted |
| `investor.est_dilution` | entity | string | Funding | ~lo-hi % around the sheet's opening dilution; never the number |
| `investor.est_valuation` | entity | string | Funding | ~$lo-hi M around the sheet's opening valuation; never the number |
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
| `musteri.broke_promise` | entity | bool | Sales | a promise to this account broke inside the relock window and nothing earlier locks the promise row |
| `musteri.churn_countdown` | entity | int | Sales | WRAPPER; -1 when not counting, else weeks to churn |
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
| `musteri.pain_buildable` | entity | bool | Sales | gates the promise row: nobody can promise what the company cannot build yet |
| `musteri.pain_feature_label` | entity | string | Sales | the feature the promise row names |
| `musteri.pain_feature_shipped` | entity | bool | Sales | gates the promise row: promising work already done pays for nothing |
| `musteri.promise_fits` | entity | bool | Sales | the account's wish fits the free points of the next plannable sprint, or another clause locks the promise row |
| `musteri.request_kind` | entity | string | Sales | complaint | feature | renewal — state-scored, no RNG |
| `musteri.risk_voice` | entity | string | Sales | what an account in Risk says, by the cause of the Risk |
| `musteri.satisfaction` | entity | int | Sales | WRAPPER; 0-100, the number the player can see |
| `musteri.scale` | entity | int | Sales | WRAPPER; 1-5, demo binds to 1-3 |
| `musteri.seats` | entity | int | Sales | WRAPPER |
| `musteri.sector_contact` | entity | string | Sales | the speaker's role line |
| `musteri.stalls_used` | entity | int | Sales | 0-2; the stall row locks at the cap |
| `musteri.tenure_weeks` | entity | int | Sales | WRAPPER; weeks since signature |
| `musteri.tolerance` | entity | int | Sales | WRAPPER; HIDDEN from the player. Condition on it, never name it in copy |
| `musteri.total_mrr` | global | int | Sales |  |
| `musteri.under_tolerance` | entity | bool | Sales | the comparison that actually drives Risk |

### `office.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `office.current` | global | string | Office | WRAPPER; home / ishani / plaza / loft. Where the company works, not where a move is heading |
| `office.moving` | global | bool | Office | WRAPPER; a move to the next office is under way |

### `phase.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `phase.bootstrap_milestone` | global | bool | Phase | WRAPPER; the bootstrap milestone was taken (EA / full), so the soft cap no longer applies |
| `phase.current` | global | int | Phase | WRAPPER; 1 Bootstrap, 2 Traction, 3 Series A Hunt |
| `phase.gate_declines` | global | int | Phase | WRAPPER; how many times the player has said not yet |
| `phase.gate_ready` | global | bool | Phase | WRAPPER; a transition is open and unanswered |
| `phase.name` | global | string | Phase | for prose |
| `phase.series_a_approach` | global | int | Phase | 0-4: approach marks cleared toward the Series A revenue bar (50/75/90/100 %). A step, never the number |
| `phase.series_a_signal` | global | string | Phase | closed | warming | open. The number behind it is deliberately not a seam |

### `rival.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `rival.count` | global | int | Rivals |  |
| `rival.leader` | global | string | Rivals | the subtype's rival with the most launches so far, ties by table order; empty before the type is chosen |
| `rival.momentum` | entity | float | Rivals | WRAPPER; zero for the giants, who do not accelerate |
| `rival.player_share_pct` | global | float | Rivals | 0.0-90.0, derived from MRR against a fixed market total |
| `rival.status` | entity | string | Rivals | WRAPPER; DOMINANT | STEADY | SCALING | QUIET |

### `sales.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `sales.account_count` | global | int | Sales | accounts in the book; excludes the B2C aggregate userbase |
| `sales.b2c_audience` | global | float | Sales | float: it carries a sub-unit accumulator |
| `sales.b2c_price` | global | int | Sales | WRAPPER; monthly price |
| `sales.growth_band` | global | string | Sales | melting | flat | steady | fast |
| `sales.is_b2b` | global | bool | Sales | reads the SHIPPED market, not one being built |
| `sales.market_share_pct` | global | float | Sales | one global figure; per-segment share does not exist yet |
| `sales.pipeline_count` | global | int | Sales | live prospects |

### `time.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `time.hour` | global | int | Time | WRAPPER; 0-23 |
| `time.is_paused` | global | bool | Time | WRAPPER; there is no named predicate for this |
| `time.month` | global | int | Time | 1-12; the month of the week's Thursday on the real calendar |
| `time.run_active` | global | bool | Time | WRAPPER; false once a terminal has fired |
| `time.speed` | global | int | Time | WRAPPER; 0 paused, 1-4 |
| `time.week` | global | int | Time | WRAPPER; absolute game week (the tick), starts at 1. GameState owns it, not TimeManager |

### `urun.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `urun.axis_experience` | global | int | Product | 0-120 |
| `urun.axis_innovation` | global | int | Product | 0-120 |
| `urun.axis_stability` | global | int | Product | 0-120 |
| `urun.bugs_confirmed` | global | int | Product | confirmed live bugs |
| `urun.bugs_unconfirmed` | global | int | Product | incoming, unvalidated reports |
| `urun.capacity_state` | global | string | Product | normal | amber | over | unprovisioned |
| `urun.capacity_tier` | global | int | Product | provisioned infra units |
| `urun.crunch_finishes` | global | bool | Product | the crunch's hours finish the decision card this sprint; false when none waits |
| `urun.decision_card` | global | string | Product | name of the card a sprint decision waits on; empty when none |
| `urun.decision_card_effort` | global | int | Product | the decision card's effort in points; 0 when none waits |
| `urun.decision_card_late` | global | bool | Product | at the team's pace the decision card will not finish this sprint; false when none waits |
| `urun.enterprise_trust` | global | bool | Product | the enterprise provider or security_cert research: the bar a large account checks before it signs |
| `urun.floor_experience` | global | string | Product | '' | warning | crossed |
| `urun.floor_innovation` | global | string | Product | '' | warning | crossed |
| `urun.floor_stability` | global | string | Product | '' | warning | crossed |
| `urun.interest` | global | float | Product | 0-100, refreshed on publish, decays by a half-life counted in weeks |
| `urun.is_live` | global | bool | Product | something has shipped |
| `urun.lines_open` | global | int | Product | 0-9 feature lines opened |
| `urun.market_type` | global | string | Product | b2b | b2c; empty until the product type is chosen |
| `urun.paid_plan_set` | global | bool | Product | the paid plan is open, or its card is in the running or the planned sprint |
| `urun.sprint_last_week` | global | bool | Product | a running sprint is in its last week: week 2 of a two-week sprint, the only week of a one-week one |
| `urun.sprint_number` | global | int | Product | the open sprint; 0 before the product type is chosen |
| `urun.sprint_running` | global | bool | Product | a sprint is under way: not planning, not the release note |
| `urun.sprint_single_card` | global | bool | Product | the open sprint holds one card; carried over, it leaves the sprint nothing to work on |
| `urun.sprint_week` | global | int | Product | 1 or 2 inside a running sprint |
| `urun.steps_shipped` | global | int | Product | feature steps live |
| `urun.subtype` | global | string | Product | one of the sub-product ids |
| `urun.support_staffed` | global | bool | Product | the module's central pressure reads from this one boolean |
| `urun.tech_debt` | global | bool | Product | WRAPPER over a flag; boolean by design in the demo |
| `urun.usage` | global | float | Product | load multiplier |
| `urun.version` | global | int | Product | shipped version number |
| `urun.version_age` | global | int | Product | weeks since THIS VERSION shipped, not since the product was born |
| `urun.weeks_since_launch` | global | int | Product | -1 when nothing has shipped |

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
{"weeks_since_flag": "mvp_launch", "op": ">=", "value": 4}
{"flag_expires_within": "negotiation_window", "weeks": 1}
{"history": "chose", "event": "hr.raise_request", "option": "accept"}
{"history": "fired", "event": "hr.raise_request"}
{"history": "weeks_since", "event": "hr.raise_request", "op": ">=", "value": 4}
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

## e · Schema v3 — the plausibility block

Every card carries one and the engine compiles it into ordinary condition leaves
(GDD §3.1, §27.20). The block's SHAPE is §3.1's table; what follows is the value each
field accepts, read off the engine.

### `phase_band` — where in the run the card lives

| band | compiles to |
|---|---|
| `bootstrap_solo` | `phase.current == 1` ∧ `hr.headcount == 0` |
| `bootstrap_team` | `phase.current == 1` ∧ `hr.headcount >= 1` |
| `traction` | `phase.current == 2` |
| `series_a` | `phase.current == 3` |

### `product` — which side of the launch

| value | compiles to |
|---|---|
| `pre_launch` | `urun.is_live == false` |
| `live` | `urun.is_live == true` |
| `any` | nothing; the card lives on both sides |

### `modules` — the module pages a card may require

Each name becomes a `build.module_unlocked.<id>` leaf (§27.22).

- `product`
- `sales`
- `hr`
- `finance`
- `piyasa`
- `personal`
- `marketing`
- `rnd`
- `events`

### `subject_tenure_weeks` — where seniority is readable

The floor filters the slot's SELECTOR, so the card binds someone who has been here
that long rather than binding anyone and refusing at the gate. A slot of any other
type has no seniority, and a `system` card is given its subject, so it gets no filter.

| slot type | seam the floor reads |
|---|---|
| `employee` | `hr.tenure_weeks` |
| `customer` | `musteri.tenure_weeks` |

A family may impose a floor of its own, and the higher of the two is compiled:

- `employee_asks_money` — 26 weeks

### `family` — the brake the card pays

Another card from the same family waits out the gap (§13.3 layer 1b); with
`family_subject` the family also waits per person or account (layer 2b). The families
the catalogue already uses, and the gap each pays:

| family | gap (weeks) | cards |
|---|---|---|
| `customer_escalation` | 6 | 1 |
| `customer_feedback` | 6 | 1 |
| `customer_growth` | 6 | 1 |
| `customer_money_dispute` | 6 | 2 |
| `customer_ownership` | 6 | 2 |
| `customer_requests` | 6 | 3 |
| `customer_risk` | 2 | 1 |
| `customer_security` | 6 | 1 |
| `employee_asks_money` | 12 | 2 |
| `employee_mistake` | 6 | 1 |
| `founder_money` | 6 | 2 |
| `founder_network` | 4 | 2 |
| `founder_setup` | 6 | 1 |
| `founder_solitude` | 3 | 2 |
| `frank_mentor` | 6 | 10 |
| `funding_paperwork` | 6 | 3 |
| `hr_departure` | 6 | 1 |
| `investor_favor` | 6 | 2 |
| `investor_pressure` | 6 | 1 |
| `leak_story` | 6 | 2 |
| `phase_gate` | 6 | 2 |
| `product_floor` | 4 | 2 |
| `product_ops` | 6 | 1 |
| `product_progress` | 6 | 1 |
| `product_security` | 6 | 1 |
| `product_support` | 6 | 1 |
| `rival_exit` | 6 | 1 |
| `rival_funding` | 6 | 1 |
| `rival_imitation` | 6 | 2 |
| `rival_poaching` | 6 | 2 |
| `run_end` | 6 | 5 |
| `sales_negotiation` | 6 | 1 |
| `seed_round` | 6 | 4 |
| `series_a_table` | 6 | 3 |
| `sprint_capacity` | 6 | 3 |
| `sprint_rewrite` | 6 | 4 |
| `sprint_scope_creep` | 6 | 2 |
| `team_overload` | 6 | 2 |
| `team_ritual` | 6 | 1 |
| `team_security` | 6 | 1 |
| `world_offer_b2b` | 8 | 2 |
| `world_offer_b2c` | 8 | 3 |

A family absent from `EvTuning.FAMILY_GAP_WEEKS` pays the default, 6 weeks.

### The window, the immunity and the demo's reach

- `delay_weeks: [N, M]` — the week the condition first holds arms a window and the
  card is a candidate `N..M` weeks later (§27.19). `[0, 0]` needs a `delay_reason`.
- A condition un-held for more than 4 weeks running throws its window away.
- The pool is silent for the first 3 weeks (§27.21); the quiet floor, requests,
  arc steps, `system` cards and the `tutorial` / `terminal_warning` tags are exempt.
- `min_week` past week 130 is a warning: the demo never reaches it.

## f · Who may write each verb

Section a groups verbs by the ORIGIN that may run them. This groups them by
AUTHORITY, which is the linter's §17.14: a verb is writable only when it has a
working arm in `EvEffects._apply` AND a chip in `EvChips`, so what an option promises
is what the player is shown and what lands.

### Writer verbs (31) — any card, inside the two rules below

- `add_cash`
- `add_brand`
- `add_reputation`
- `customer_mrr_delta`
- `seats`
- `churn_customer`
- `audience_delta`
- `add_prospect`
- `employee_leaves`
- `b2b_retain_discount`
- `b2b_expand`
- `change_morale`
- `morale_all`
- `satisfaction_delta`
- `promise_create`
- `sprint_hours`
- `sprint_card_effort`
- `sprint_card_progress`
- `sprint_card_carry`
- `b2b_retain_delay`
- `b2b_retain_ignore`
- `b2b_expand_decline`
- `set_flag`
- `stamp_day`
- `schedule_event`
- `cancel_scheduled`
- `productivity_mod`
- `investor_strain`
- `marketing_push`
- `send_on_leave`
- `work_hours`

Two rules narrow the list. A `sprint_card_*` verb belongs to a `tick: request` sprint
decision and to no other card (§17.14, V3). A module verb spends a page the build may
not have opened: never in a demo card, and past the demo only in an option whose
`requires` names the module as open (§17.15, O5).

- `marketing_push` — needs `build.module_unlocked.marketing`

### Reserved (18) — a `system` card only

Each moves the run itself — a phase, a table, an arc, an ending — so a story card
reaching for one would be deciding the run instead of colouring it.

- `advance_phase`
- `phase_gate_decline`
- `angel_accept`
- `open_term_table`
- `open_seed_table`
- `decline_offer`
- `decline_buyout`
- `trigger_ending`
- `mentor_advisory`
- `goto_tab`
- `unlock_content`
- `spend_budget`
- `set_game_flag`
- `start_arc`
- `advance_arc`
- `end_arc`
- `abort_arc`
- `set_arc_var`

### Not writable (14) — no working arm or no chip

The executor dispatches these, so they are not unknown names; they are names a card
may not say. A draft that wants one writes `[VOCAB?]` and §21's DELTA workflow.

- `clear_flag`
- `set_timed_flag`
- `assign_to`
- `start_training`
- `damage_product`
- `ticker_push`
- `notify`
- `open_negotiation`
- `add_mrr`
- `add_customer`
- `convert_audience`
- `open_paid_tier`
- `change_salary`
- `fire_employee`

<!-- HAND-WRITTEN — REGENERATION SKIPS THIS BLOCK -->
## g · Hand-written notes

This block survives regeneration. The three sections worth keeping here are the ones
the old file carried and nobody would reconstruct: the **trigger-hook map** (draft
hook name → the signal and file:line that fires it today), the **legacy-function map**
(every retired card id → the arc node that inherited its job), and the list of
**known gaps** the engine has not closed.
<!-- END HAND-WRITTEN -->
