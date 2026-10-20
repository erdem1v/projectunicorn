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
| Seams (read) | **256** |
| Effect verbs (write) | **75** |
| Cards in the catalogue | 146 |
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
- `morale_crew`
- `assign_to`
- `send_on_leave`
- `start_training`
- `productivity_mod`
- `work_hours`
- `damage_product`
- `line_harden`
- `sprint_card_effort`
- `sprint_card_progress`
- `sprint_card_carry`
- `sprint_card_test`
- `sprint_hours`
- `sprint_fix_first`
- `sprint_card_trim`
- `sprint_card_outlook`
- `sprint_card_first`
- `satisfaction_delta`
- `trust_delta`
- `promise_create`
- `promise_extend`
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
- `b2b_month_discount`
- `marketing_push`
- `incident`
- `promise_break`

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
| `finance.daily_burn` | global | int | Finance | WRAPPER; a per-day rate, 0 at the start |
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
| `founder.is_busy` | global | bool | HR | assigned, in training, or in a sitting |
| `founder.leadership` | global | int | HR | 0-10; the morale ceiling and the team output multiplier |
| `founder.origin` | global | string | HR | self_made | heir | corporate_refugee |
| `founder.skill` | global | int | Founder | the skill a check leaned on; the specific seam wins when one exists |
| `founder.task_state` | global | string | HR | build | sales | support | research | training | idle |

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
| `hr.is_busy` | entity | bool | HR | leave or training, plus a sitting for the founder |
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
| `musteri.met_feature` | entity | string | Sales | the name KEY of the step the account's latest thanks is for; text reads it in the live language, a history row keeps the key |
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
| `musteri.thanks_variant` | entity | int | Sales | which body of the release thanks note the account's latest thanks reads, for by_seam text |
| `musteri.tolerance` | entity | int | Sales | WRAPPER; HIDDEN from the player. Condition on it, never name it in copy |
| `musteri.total_mrr` | global | int | Sales |  |
| `musteri.under_tolerance` | entity | bool | Sales | the comparison that actually drives Risk |

### `office.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `office.current` | global | string | Office | WRAPPER; home / ishani / plaza / loft. Where the company works, not where a move is heading |
| `office.moving` | global | bool | Office | WRAPPER; a move to the next office is under way |

### `olay.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `olay.accounts` | global | int | Incident | active B2B accounts |
| `olay.affected_accounts` | global | int | Incident | active B2B accounts that use the line the emergency hit |
| `olay.affected_users` | global | int | Incident | B2C: people who tried the app between the outage's start and the card's opening |
| `olay.clock` | global | string | Incident | when the open emergency began, 02:10; a history row reads the latest emergency's |
| `olay.line_users` | global | int | Incident | people the line the emergency hit reaches each day (B2C: the audience's share of it) |
| `olay.night_accounts` | global | int | Incident | active B2B accounts of a night-shift sector |
| `olay.outage_load` | global | int | Incident | the server load, in percent, the open outage was rolled at, for by_seam text; 0 for another kind |
| `olay.payers` | global | int | Incident | people a fix outside the sprint costs morale (SprintSystem.payers, on the line the emergency hit); 0 locks the option |
| `olay.service_up` | global | bool | Incident | no emergency is open, or the fix it was answered with is done |
| `olay.shares` | global | int | Incident | how many times the post going round has been shared: a share of the audience |
| `olay.variant` | global | int | Incident | which line-specific body a card reads (IncidentSystem.variant), for by_seam text |
| `olay.version` | global | string | Incident | the version the open regression broke, v1.4 |

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
| `time.month` | global | int | Time | 1-12; the month of the week's date on the real calendar |
| `time.run_active` | global | bool | Time | WRAPPER; false once a terminal has fired |
| `time.speed` | global | int | Time | WRAPPER; 0 paused, 1-4 |
| `time.week` | global | int | Time | WRAPPER; absolute game week (the tick), starts at 1. GameState owns it, not TimeManager |

### `urun.`

| seam | scope | type | owner | note |
|---|---|---|---|---|
| `urun.bugs_unconfirmed` | global | int | Product | incoming, unvalidated reports |
| `urun.capacity_state` | global | string | Product | normal | amber | over | unprovisioned |
| `urun.capacity_tier` | global | int | Product | provisioned infra units |
| `urun.colors_again` | global | bool | Product | the colours were changed by hand once, so the account asks for its colours on the pages added since |
| `urun.colors_central` | global | int | Product | the points of pulling every colour into one file; one more for each page added since the first change |
| `urun.colors_first` | global | int | Product | 1 the first time an account asks for its colours, 0 the second time |
| `urun.colors_hand` | global | int | Product | the points of changing the colours by hand; one more for each page added since the first change |
| `urun.crunch_finishes` | global | bool | Product | the crunch's hours finish the decision card this sprint; false when none waits |
| `urun.cut_test_finishes` | global | bool | Product | the decision card is in testing and cutting its test in half finishes it this sprint |
| `urun.decision_by_founder` | global | bool | Product | the founder speaks the pending paper (works the card's phase), not an employee |
| `urun.decision_card` | global | string | Product | name of the card a sprint decision waits on; empty when none |
| `urun.decision_card_done` | global | int | Product | points already worked on the decision card; 0 when none waits |
| `urun.decision_card_effort` | global | int | Product | the decision card's effort in points; 0 when none waits |
| `urun.decision_card_late` | global | bool | Product | at the team's pace the decision card will not finish this sprint; false when none waits |
| `urun.decision_kind` | global | string | Product | feature | request | fix | research: what the decision card is; empty when none waits |
| `urun.decision_line` | global | string | Product | id of the line the decision card is on, a shared line by its base id; empty when none waits |
| `urun.decision_line_accounts` | global | int | Product | B2B accounts that use the decision card's line |
| `urun.decision_line_bugs` | global | int | Product | open bugs on the decision card's line |
| `urun.decision_line_first_version` | global | bool | Product | the decision card's line was opened by the first version (the sprints before v1.0 and v1.0 itself) |
| `urun.decision_line_name` | global | string | Product | the name of that line, for a paper's text; empty when none waits |
| `urun.decision_phase` | global | int | Product | the phase the decision card is in: 0 design, 1 development, 2 testing, 3 done; 0 when none waits |
| `urun.decision_phone_late` | global | bool | Product | the phone layout's points added, the decision card would not finish this sprint |
| `urun.decision_promised` | global | bool | Product | an account was promised the decision card's step and the promise is still open |
| `urun.decision_renewal_saved` | global | bool | Product | the account's renewal falls after this sprint and before the next, and standing the card first ships it this sprint |
| `urun.decision_request_votes` | global | int | Product | B2C: the people who asked for the decision card's step; 0 until the consumer request data exists |
| `urun.decision_root_bugs` | global | int | Product | open bugs the decision card, a fix card, closes; 0 for any other card |
| `urun.decision_root_cause` | global | bool | Product | the decision card is a fix card with enough bugs on one line to share a root |
| `urun.decision_second_account` | global | string | Product | the other account that asked for the decision card's step; empty when only one did (open requests carry one account per step) |
| `urun.decision_step` | global | string | Product | id of the step the decision card takes its line to, a shared line's step by its base id; empty when none waits |
| `urun.decision_test_half` | global | int | Product | half of the decision card's testing left, in points; the work a developer helping with the test does |
| `urun.decision_test_untouched` | global | bool | Product | the decision card has reached testing and nobody has tested it yet |
| `urun.decision_tier` | global | int | Product | the tier the decision card takes its line to; 0 when none waits |
| `urun.decision_trim_finishes` | global | bool | Product | taking the trim share off the decision card finishes it this sprint |
| `urun.design_late` | global | bool | Product | the decision card is still in design after this week's work and a developer waits on it |
| `urun.durability_tier` | global | int | Product | the tier the Durability line has reached; 1 is autosave and nothing more |
| `urun.enterprise_trust` | global | bool | Product | Enterprise servers or the security_cert research: the trust bar the security and leak cards read |
| `urun.floor_area` | global | string | Product | localization key (PRODUCT_AREA_*_SHORT) of the worst area's name, '' without one; a card body prints it translated |
| `urun.floor_state` | global | string | Product | '' | warning | crossed: the state of the worst area; '' in B2B and while no area is below the warning ratio |
| `urun.interest` | global | float | Product | 0-100, refreshed on publish, decays by a half-life counted in weeks |
| `urun.is_live` | global | bool | Product | something has shipped |
| `urun.lines_open` | global | int | Product | 0-9 feature lines opened |
| `urun.market_type` | global | string | Product | b2b | b2c; empty until the product type is chosen |
| `urun.open_bugs` | global | int | Product | open bugs across every line |
| `urun.paid_plan_open` | global | bool | Product | the paid plan is open |
| `urun.paid_plan_set` | global | bool | Product | the paid plan is open, or its card is in the running or the planned sprint |
| `urun.paper_ask_silent` | global | int | Product | the audience that goes quiet when a request is not met: the people who asked, times the quiet ones behind each |
| `urun.paper_coupon_loss` | global | int | Product | the audience that would have come in on a coupon, in people |
| `urun.paper_first_screen_loss` | global | int | Product | the sign ups a sign up screen with three questions loses over its weeks, in people |
| `urun.paper_loss_mid` | global | int | Product | the audience a real annoyance costs, in people |
| `urun.paper_loss_small` | global | int | Product | the audience a small annoyance costs, in people |
| `urun.paper_phone_points` | global | int | Product | the work a phone layout adds to a card, in points |
| `urun.paper_server_bill` | global | int | Product | this month's server bill, in dollars |
| `urun.paper_signup_loss` | global | int | Product | the sign ups a week of a broken sign up code costs, in people |
| `urun.paper_test_phones` | global | int | Product | what a few phones to test on cost, in dollars, once |
| `urun.promise_card` | global | string | Product | name of the card the latest promise event is about; a history row reads the latest event's |
| `urun.promise_crunch_finishes` | global | bool | Product | employees work the promise card and the crunch's hours finish it this sprint |
| `urun.promise_cut_finishes` | global | bool | Product | the promise card is in testing and cutting its test in half finishes it this sprint |
| `urun.promise_extended` | global | bool | Product | one of those promises has already moved a sprint; a word moves once |
| `urun.promise_open` | global | int | Product | promises the latest promise event is about that are still open |
| `urun.responsive_shipped` | global | bool | Product | the Responsive Interface step is live |
| `urun.security_bugs` | global | int | Product | open bugs on the Security and Access line |
| `urun.security_fix_planned` | global | bool | Product | the Security and Access fix card is in the running sprint |
| `urun.security_tier` | global | int | Product | the tier the Security and Access line has reached; 0 before it is built |
| `urun.sprint_has_tester` | global | bool | Product | a tester works in the sprint's team (the Test job); the founder testing is not one |
| `urun.sprint_last_week` | global | bool | Product | a running sprint is in its last week: week 2 of a two-week sprint, the only week of a one-week one |
| `urun.sprint_number` | global | int | Product | the open sprint; 0 before the product type is chosen |
| `urun.sprint_running` | global | bool | Product | a sprint is under way: not planning, not the release note |
| `urun.sprint_single_card` | global | bool | Product | the open sprint holds one card; carried over, it leaves the sprint nothing to work on |
| `urun.sprint_week` | global | int | Product | 1 or 2 inside a running sprint |
| `urun.steps_shipped` | global | int | Product | feature steps live |
| `urun.subtype` | global | string | Product | one of the sub-product ids |
| `urun.support_staffed` | global | bool | Product | the module's central pressure reads from this one boolean |
| `urun.tech_debt` | global | bool | Product | WRAPPER over a flag; boolean by design in the demo |
| `urun.trust_level` | global | float | Product | Trust and Scale as the product page shows it, 0-3 in halves; 0 until a line of the area is built |
| `urun.usage` | global | float | Product | load multiplier |
| `urun.version` | global | int | Product | shipped version number |
| `urun.version_age` | global | int | Product | weeks since THIS VERSION shipped, not since the product was born |
| `urun.weeks_since_launch` | global | int | Product | -1 when nothing has shipped |
| `urun.weeks_to_month_end` | global | int | Product | ticks until the calendar month turns; 1 on the month's last tick |
| `urun.worst_line_bugs` | global | int | Product | open bugs on the line with the most |

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
| `incident` | 6 | 6 |
| `investor_favor` | 6 | 2 |
| `investor_pressure` | 6 | 1 |
| `leak_story` | 6 | 2 |
| `phase_gate` | 6 | 2 |
| `product_floor` | 4 | 2 |
| `product_progress` | 6 | 1 |
| `product_security` | 6 | 1 |
| `product_support` | 6 | 1 |
| `promise` | 6 | 1 |
| `release_thanks` | 6 | 1 |
| `rival_exit` | 6 | 1 |
| `rival_funding` | 6 | 1 |
| `rival_imitation` | 6 | 2 |
| `rival_poaching` | 6 | 2 |
| `run_end` | 6 | 5 |
| `sales_negotiation` | 6 | 1 |
| `seed_round` | 6 | 4 |
| `series_a_table` | 6 | 3 |
| `sprint_design` | 6 | 8 |
| `sprint_dev` | 6 | 9 |
| `sprint_late` | 6 | 2 |
| `sprint_pm` | 6 | 8 |
| `sprint_solo` | 6 | 5 |
| `sprint_test` | 6 | 9 |
| `sprint_untested` | 6 | 3 |
| `team_overload` | 6 | 2 |
| `team_ritual` | 6 | 1 |
| `team_security` | 6 | 1 |
| `world_offer_b2b` | 8 | 2 |
| `world_offer_b2c` | 8 | 3 |

A family absent from `EvTuning.FAMILY_GAP_WEEKS` pays the default, 6 weeks.

### `speaker_role` · `stage` · `pool_group` — the sprint paper

A card listed in sprint.json `decision.cards` is a sprint paper, asked for at most once a sprint for one of the
sprint's cards. `speaker_role` (`product_manager`, `designer`, `developer`, `tester`, `founder`) is the role of whoever speaks it: the engine binds the
person who works the card at `stage` (`any`, `design`, `dev`, `test`; `any` is any phase) to the card's `employee` slot, or
to its `founder` slot for the founder's own note, and a card nobody of that role works is not asked for.
`speaker_role` may be a list of roles: the first person working the card with any of them speaks.
A `product_manager` paper is spoken by the quarter's PM and is about a planned customer request card: its
`customer` slot is the request's account. `pool_group` (`pm`, `designer`, `developer`, `tester`, `no_tester`, `solo`, `system`) counts the paper in the
pool. A paper carries `latch: {cooldown_weeks: 52, max_fires: 3}` (the two stack); a card with no
`speaker_role` is spoken by no one.
A paper's `customer` slot may take `select: line_top | line_warehouse | line_newest | line_slow | request` (an account of
the decision card's line, SprintCatalog.paper_account) and a second `employee` slot `select: sprint_dev` (a developer of
the sprint's team); an option that fits one market only is a card of its own (`_b2c`), since a locked option is never hidden.

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

### Writer verbs (41) — any card, inside the two rules below

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
- `morale_crew`
- `satisfaction_delta`
- `trust_delta`
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
- `damage_product`
- `line_harden`
- `sprint_card_test`
- `sprint_fix_first`
- `sprint_card_trim`
- `sprint_card_outlook`
- `sprint_card_first`
- `b2b_month_discount`

Two rules narrow the list. A `sprint_card_*` verb belongs to a `tick: request` sprint
decision and to no other card (§17.14, V3). A module verb spends a page the build may
not have opened: never in a demo card, and past the demo only in an option whose
`requires` names the module as open (§17.15, O5).

- `marketing_push` — needs `build.module_unlocked.marketing`

### Reserved (21) — a `system` card only

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
- `incident`
- `promise_extend`
- `promise_break`

### Not writable (13) — no working arm or no chip

The executor dispatches these, so they are not unknown names; they are names a card
may not say. A draft that wants one writes `[VOCAB?]` and §21's DELTA workflow.

- `clear_flag`
- `set_timed_flag`
- `assign_to`
- `start_training`
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
