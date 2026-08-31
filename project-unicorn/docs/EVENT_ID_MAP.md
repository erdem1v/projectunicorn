# Card id map — old to new

Used to repoint the 37 event-coupled smoke cases. Every case is repointed at the
BEHAVIOUR it was testing; the id is only the handle.

| was | is |
|---|---|
| `ev_angel_frank_seed` | `funding.frank_cheque` |
| `ev_angel_hire_nudge` | `funding.hire_nudge` |
| `ev_b2b_escalation_<customer_id>` | `customer.cs_escalation` |
| `ev_b2b_expand_<customer_id>` | `customer.expansion` |
| `ev_b2b_request_<customer_id>` | `customer.request_complaint` |
| `ev_b2b_request_<customer_id>` | `customer.request_feature` |
| `ev_b2b_request_<customer_id>` | `customer.request_renewal` |
| `ev_b2b_retain_<customer_id>` | `customer.retention` |
| `ev_hr_resign_<employee_id>` | `team.resignation` |
| `ev_mvp_bugfix_001_critical_bug` | `product.critical_bug` |
| `ev_mvp_bugfix_002_early_launch_pressure` | `product.early_launch_pressure` |
| `ev_mvp_bugfix_003_final_polish` | `product.final_polish` |
| `ev_mvp_dev_001_integration_broken` | `product.integration_broken` |
| `ev_mvp_dev_002_tech_debt_callout` | `product.tech_debt_callout` |
| `ev_mvp_dev_003_solo_dev_fatigue` | `product.solo_dev_fatigue` |
| `ev_mvp_iter_001_scope_creep` | `product.scope_creep` |
| `ev_mvp_iter_002_competitor_signal` | `product.competitor_signal` |
| `ev_mvp_iter_003_early_user_feedback` | `product.early_user_feedback` |
| `ev_mvp_iter_decision_intro` | `product.design_round_intro` |
| `ev_mvp_ship_moment` | `product.first_ship` |
| `ev_mvp_version_ship_moment` | `product.version_ship` |
| `ev_phase_gate_series_a` | `funding.gate_series_a` |
| `ev_phase_gate_traction` | `funding.gate_traction` |
| `ev_ps_b2c_paid_tier` | `product.paid_tier` |
| `ev_ps_b2c_producthunt` | `customer.showcase_feature` |
| `ev_ps_bug_complaint` | `customer.bug_complaint` |
| `ev_ps_frank_intro_b2b` | `customer.frank_intro` |
| `ev_ps_power_user_b2c` | `customer.power_user` |
| `ev_ps_referral_b2b` | `customer.referral` |
| `ev_sheet_expiry_warning` | `funding.sheet_expiry` |
| `ev_shutter_warning` | `funding.shutter_warning` |
| `ev_vc_last_answer_day` | `funding.last_answer` |
| `ev_vc_meeting_prompt` | `funding.meeting_day` |

**Deleted again, by the event-deck delete (2026-08-31).** Sixteen of the right-hand ids
above no longer exist. They were carried across by the port and then judged LEGACY-FLAVOR in
`docs/reports/EVENT_DECK_DELETE_2026-08-31.md`: written against the game before the engine
rebuild, firing phase-blind, and damaging the playtest. The rows are left standing because
this file is the record of a MIGRATION, and the migration happened; what the reader needs is
to know which arrows now point at nothing.

`customer.bug_complaint` · `customer.power_user` · `customer.referral` ·
`customer.showcase_feature` · `product.competitor_signal` · `product.critical_bug` ·
`product.early_launch_pressure` · `product.early_user_feedback` · `product.final_polish` ·
`product.integration_broken` · `product.quiet_version_age` · `product.scope_creep` ·
`product.solo_dev_fatigue` · `product.tech_debt_callout` · `team.quiet_late_light` ·
`world.quiet_runway_glance`

Two smoke cases named one of them and were repointed rather than deleted:
`bug_complaint_costs_audience_not_cash` became `complaint_never_charges_cash` on the live
`customer.request_complaint`, and `event_i4_demoted_never_dropped` took `customer.retention`
as its governor fixture. A third, `ambient_one_per_day_across_hour0`, lost every authored
hourly card and now runs on `fixture.hourly_ambient`.

**Deleted, not mapped:** `ev_debug_001_engineer_workload`, `ev_debug_002_press_inquiry`,
`ev_debug_003_cash_warning`. Never loaded by any build, Turkish only, and one of them
carries an option literally labelled `[NOT IMPLEMENTED]`.

**Held, not mapped:** `ev_seed_closed` stays in `data/events/unwired/`, unchanged, for
the seed round that does not exist yet.

**Retired with no successor:** `ev_buyout_offer` and `ev_vc_deal_prompt_<vc>`. Both
already had no caller, and two smoke cases ASSERT they never reach the queue — so
re-authoring either onto disk would fail the suite, which is the correct outcome.
