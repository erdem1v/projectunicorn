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

**Deleted, not mapped:** `ev_debug_001_engineer_workload`, `ev_debug_002_press_inquiry`,
`ev_debug_003_cash_warning`. Never loaded by any build, Turkish only, and one of them
carries an option literally labelled `[NOT IMPLEMENTED]`.

**Held, not mapped:** `ev_seed_closed` stays in `data/events/unwired/`, unchanged, for
the seed round that does not exist yet.

**Retired with no successor:** `ev_buyout_offer` and `ev_vc_deal_prompt_<vc>`. Both
already had no caller, and two smoke cases ASSERT they never reach the queue — so
re-authoring either onto disk would fail the suite, which is the correct outcome.
