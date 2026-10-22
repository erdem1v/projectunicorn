# K0 · Plan öncesi keşif (salt okuma, HEAD 1faeb82, 2026-10-16)
Üç Sonnet keşifçisinin raporu ve adım tablosunun Opus incelemesi. Satır numaraları 1faeb82'ye göredir; dilimler ilerledikçe kayar.

## Keşifçi: k1-matrix

**Report: PRD Karar 13 sizing (K1a / K1b)**, HEAD 1faeb82. Nothing was modified. I did not write the plan file plan mode suggested, because the task is strictly read-only. Line numbers refer to the current tree. Counts of smoke cases are estimates from grep, not a run.

**1. Sprint readers (definition; every caller)**
- `team()` is defined at `scripts/systems/sprint_system.gd:518`.
  - It takes active employees plus the active founder, skips anyone with no fitting role or who holds `JOB_RESEARCH`, and never reads the other jobs.
  - Points come from `_points` (`:1289`), which does not use `focus_mult`.
  - The founder is always included, through `founder_roles` in `data/product/sprint.json:23`.
  - Callers in scripts:
    - `sprint_system.gd`: 168, 448, 509, 538, 571, 603, 641, 658, 722, 746, 933 (the last is the `_restaff` path).
    - `effects.gd:365` (scope=team productivity).
    - `office_people.gd:97`.
    - `product_model.gd:204`.
    - `sprint_probe.gd:194` and `:200`.
    - `endgame_smoke.gd`: 17139, 17264, 17453.
  - There are no hits in `scenes/` or `tools/`.
- `capacity()` is defined at `:446` (the sum of `team().points` times the sprint weeks). It has 8 callers in `sprint_system.gd` (152, 400, 537, 557, 591, 695, 970 and the self-use at 446). Callers elsewhere:
  - `sprint_catalog.gd`: 411, 440, 493.
  - `product_model.gd`: 203, 371.
  - `run_probe.gd:872`.
  - Smoke: 2579, 6926, 7114, 13335, 17199-17225, 17751, 18275.
- `plan_outcome()` is defined at `:566`. Callers:
  - `sprint_catalog.gd:822`.
  - `product_model.gd:117`.
  - `sprint_probe.gd:149` and `:152`.
  - Plus internal use through `mvp_eta` and `_play_out`.
- `assignees` is written only inside `_assign` (`:754-779`). Its other writers and readers, found by grep, are `:119`, `:317`, `:654-655`, `:730`, `:759`, `:815-823`, `:937`, `:1045` and `sprint_catalog.gd:292`. UI readers are `sprint_card.gd:256` and `product_model.gd:229/234`. `_assign` takes its people from `team()` (`:168`, `:746`, `:939`), so `assignees` and `role_of` follow `team()` automatically and need no change of their own.
- `role_of` is defined at `:1260` (active mode only; it also counts cards prepared ahead). Callers:
  - `hr_system.gd:235`.
  - `support_system.gd:236` (validation readers).
  - `product_model.gd:251` (idle count).
  - `office_people.gd:667`.
- `week_points` is defined at `:507`. It is read only by `work_hours_modal.gd:217` and `:218`.
- `pm_plans` is defined at `sprint_catalog.gd:483`. It does not read `team()`. Callers: `sprint_system.gd:348/355/364`, `product_model.gd:374`, smoke 18513-18527. The only coupling is through `capacity()` at `sprint_catalog.gd:493`.

**2. HRConstants and desk counting**
- `focus_mult` is at `hr_constants.gd:184`: it returns 1.0 for 0 or 1 jobs and 0.5 for 2 jobs.
- `MAX_JOBS_PER_PERSON` is 2 (`:142`). It is enforced in `character_registry.gd:215` and `:275`, `save_manager.gd:1095` and `hr_assignments.gd:121`.
- `AREA_PRIMARY_JOB` is at `:190-197`. `assign_area` is at `character_registry.gd:323` and delegates to `assign_job`. Its only runtime caller is a debug fixture at `main.gd:2801`.
- `effective_skill` is at `hr_system.gd:381`. It applies `focus_mult(job_count(c))` at `:393`.
- The desk side already honours the matrix:
  - `SupportSystem.desk_roster` (`support_system.gd:191`) is the people with `JOB_SUPPORT` plus the founder when `founder_passive_care()` is true (`:212`). That holds only when the product is live, the founder is active and not busy, and `assigned_job_ids` is empty.
  - `desk_staffed()` (`:223`) is `not desk_roster().is_empty()`. The seam `destek.desk_staffed` (`seams_sales.gd:117`) and `product_read.gd:91` both read it.
  - A founder on Build alone is therefore not on the desk today. A founder on Build and Support is on the desk at 0.5 through `effective_skill`. An unassigned founder gets passive care.
- Sprint side: `_points` ignores jobs and focus. A founder with Support only is full points in the sprint and also on the desk. That is the only double count that remains.

**3. Founder job code**
- `ProductSystem._founder_on_build` is at `product_system.gd:71` and is read at `:86`. It reads `founder.assigned_jobs` (the area mirror), requires `_is_free`, and feeds only the product-quality average. It does not touch the sprint.
- `hr_system.gd:221` (`founder_task_label`) shows the jobs joined by " · " when the founder has more than one. Otherwise `:235` shows "plan" when the state is BUILD and `role_of == ""`.
- `founder_task_state` is at `:240`. The order is training, pitch prep, research, build, sales or accounts, support or test, passive care (CARE), then idle.
- The `_validate_shape` rule is at `character_registry.gd:507-510`:
  `if character.category == "founder" and character.assigned_job_ids.size() > 1: push_error("... founder holds %d jobs — §2.1 allows exactly one")`
- It runs only in `add()` (`:438`) and `insert_raw()` (`:511`), meaning at registration and at save load. It never runs at runtime.
- The founder's starting job comes from `game_state.gd:978-983`: the primary job of the build area with the highest allocation, so exactly one job (Build, or Test if QA is the top area).

**4. Can the founder hold two jobs at runtime today?**
- Yes. `assign_job` (`character_registry.gd:195-250`) has no founder exception, and its comment says "kurucu istisnası yoktur".
- The HR matrix UI (`hr_assignments.gd:106-127`) and `hr_tab.gd:468` call it for every row.
- Smoke case `_case_job_assignment_and_idle` (`endgame_smoke.gd:10131-10147`) asserts that the founder gets a second continuous job and that a third is refused with `job_cap`. Its comment says the old single-job exception was removed on 2026-08-25.
- `_validate_shape` is the only block, and it only logs. A save made with a two-job founder logs an `ERROR:` line on load. `gate_common.sh:9` counts `^ERROR:` as a gate failure, so the rule is stale.

**5. office_people.gd**
- `:97` sets `_kickoff` from `team()` on `sprint_started`, so everyone in `team()` walks to the kick-off.
- `:667` (`_work_of`) reads `role_of` first. If it is empty the founder shows "phone" when passive care is on, or "plan" otherwise; employees show `JOB_WORK[assigned_job_ids[0]]`.
- No code change is needed here. Only visible behaviour changes: the founder leaves the kick-off when he has no sprint job.

**6. effects.gd:365**
- `productivity_mod` with `scope=team` loops `SprintSystem.team()` and calls `add_productivity_mod` for each member. It returns a no-target result when the mode is not "active" or the team is empty.
- When K1b changes `team()`, who gets the mod changes with it. This is covered by `_case_productivity_mod_paces_the_sprint` (11 hits).

**7. run_probe.gd B2C arm**
- The founder is moved at `run_probe.gd:1089-1098`: when the market is b2c and `b2c_paying_users() > 0`, it calls `clear_jobs` and then `assign_job(JOB_SUPPORT)`.
- The comment at `:1089-1093` encodes the assumption: "Sprint points do not read his job (SprintSystem.team), so the sprint loses nothing".
- After K1b this arm would drop the founder's sprint points to 0. A rebuild would assign Support as a second job, which gives 0.5 and 0.5, instead of `clear_jobs`.
- `:1116` already gives a developer Support for fix passes, and after K1b that developer drops to 0.5 in the sprint.
- `run_gate.sh` runs `full_run`, `full_run_b2c` and `full_run_vc_cautious`, and checks only for a single `PROBE END`, an ending and no `ERROR`. It does not check economy values.
  - Only `full_run_b2c` is affected. The founder never changes jobs in the b2b presets.
  - Any economy shift goes in the K1 report, not into the gate.

**8. sprint_probe.gd fixture**
- `team=N` calls `_hire(n)` (`:173`) for N-1 employees from `HIRES` (`:40`).
- `CharacterRegistry.add` (`character_registry.gd:446`) puts each new hire on `default_job_for_role`, so developers and designers get Build and testers get Test. The founder keeps his starting Build.
- The fixture stays valid after K1b. `_count_idle` (`:194`) compares `team().size()` with the worked ids, and `_inputs` (`:200`) snapshots `team()`, so the mismatch detector sees any team change.
- The PRD §4.6(a) baseline (`--sprint-probe=...:team=3:fill=1:events=1`) should be taken before K1a, as the PRD says.

**9. Smoke cases (391 `_case_` in total)**
- Direct readers of `team()`, `capacity()` or `_sprint_points` (16 cases):
  - `_case_sprint_capacity_from_team` (12 hits)
  - `_case_productivity_mod_paces_the_sprint` (11)
  - `_case_prep_bonus_and_capacity`
  - `_case_hr_leave_cycle`
  - `_case_promise_row_locked_when_no_room`
  - `_case_leave_does_not_pause_build` (13307)
  - `_case_hr_raise_and_leave` (7076)
  - `_case_sprint_ceiling_125_blocks_add`
  - `_case_research_occupies_person`
  - `_case_research_and_build_pause_each_other`
  - `_case_office_move_gates_and_save`
  - `_case_sprint_save_roundtrip`
  - `_case_sprint_late_only_when_behind`
  - `_case_sprint_faulty_ticket_deterministic`
  - `_case_sprint_carry_keeps_progress`
  - `_case_hr_active_filters`
- Founder desk counting (K1a territory):
  - `_case_hotfix_founder_takes_support_desk` (5183). It already asserts all of these: no job plus a live product gives passive care, with the desk staffed and the state CARE; a founder on Build makes `desk_staffed` false; clearing his jobs makes care resume; a sales meeting stops care; and with no live product it reads idle.
  - `_case_support_desk_rates_stack` (5303)
  - `_case_owned_account_erodes_slower` (5366)
  - `_case_founder_owns_accounts_manually` (5489)
  - `_case_destek_survives_ship` (13194)
  - `_case_destek_empty_desk_piles_up` (13411)
  - `_case_split_bars_name_their_cause` (14847; Build plus Support at 0.5)
  - `_case_paused_job_resumes_on_direct_return` (14799)
  - `_case_sales_meeting_time_skip_founder_share` (15794)
  - `_case_hr_read_catalogue` (10390)
  - `_case_job_assignment_and_idle` (10034)
  - The seam test is at 5857-5868.
- At risk from K1b: about 27 cases start or add sprints, 18 call `clear_jobs` or `unassign_job`, and 13 assign jobs to the founder. Most of them may need a founder Build assignment, or a check that they still have a sprint team.
- `_case_gorevler_has_no_founder` (13235) and the "exactly one job" asserts at 10119, 10317 and 13254 must be kept in line with Karar 13.

**Answer: ordering of K1a and K1b**
1. Acceptance §4.9 (`founder_not_double_counted`) cannot be fully tested before K1b.
   - States 1 and 3 on the desk side, and state 2 on the desk side, already pass without any code change. They hold today through `desk_roster`, `founder_passive_care` and `effective_skill`.
   - The sprint halves ("Yapım ve Destek tutan kurucu sprintte 0.5" and "işi olmayan kurucu sprintte değildir") need K1b's job-aware `team()`.
   - A K1a that only fixes desk counting has almost no code to change. The PRD's "masa sayımı" is mostly a characterization test.
2. `_validate_shape` does not block testing. Runtime `assign_job` ignores it. It matters only for a save/load round trip of a two-job founder, which would log an `ERROR:` and fail the gate. It is a one-line removal (`character_registry.gd:507-510`) plus an assertion in the new case.
3. Recommendation: land K1a first, but keep it thin.
   - It removes the `_validate_shape` rule.
   - It adds the desk-half of `founder_not_double_counted`, covering Build only, Build+Support and no job, plus a founder save/load round trip with two jobs.
   - It records the §4.6(a) baseline.
   - It does not touch `SprintSystem.team()`.
   - K1b then finishes the case with the sprint halves.
   - If you would rather avoid two commits for such a small slice, merging K1a into K1b is acceptable. The risk is that `_validate_shape` and the sprint-side changes then land in one commit that touches many readers.
4. Estimates (rough):
   - K1a: 2 files of code (`character_registry.gd`, `endgame_smoke.gd`) and 1 doc line. Smoke: 1 new case (desk half) and 1 or 2 assertions added to existing cases.
   - K1b: 8 to 10 code files.
     - `sprint_system.gd` (`team`, `_points` or `_fits`, with a job filter on Build and Test and `focus_mult`)
     - `hr_system.gd` (founder label)
     - `product_model.gd` (empty-team text, with a link to Ekip)
     - the sprint panel and its strings
     - `run_probe.gd` (B2C arm)
     - `sprint_probe.gd` if the fixture is kept as is (probably unchanged)
     - TR and EN localization
     - 4 docs (`HARITA.md`, `CLAUDE.md`, `GUNCELLEMELER.md`, the report)
   - K1b smoke: 2 new cases (`founder_not_double_counted` finished, and the matrix case from §4.10) and edits to roughly 16 to 25 existing cases.
5. D's scope: `_fits` (`sprint_system.gd:1270`) picks sprint roles from the role's areas, not from jobs, so "the person holding the Test job fits Test" is left to D. A only needs the filter on who is in the sprint and at what share.

Files read: `C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_ab/PRD_FAZ_A_HATALAR.md`, `scripts/systems/sprint_system.gd`, `scripts/systems/support_system.gd`, `scripts/systems/hr_system.gd`, `scripts/systems/hr_constants.gd`, `scripts/autoload/character_registry.gd`, `scripts/autoload/game_state.gd`, `scripts/debug/run_probe.gd`, `scripts/debug/sprint_probe.gd`, `scripts/debug/endgame_smoke.gd`, `tools/run_gate.sh`, `tools/gate_common.sh`.

## Keşifçi: k2-k4-store

Read-only pass done at HEAD 1faeb82. Working tree has unrelated edits (project.godot, themes/*.tres) and untracked docs. The only file I wrote was a stray scratch file in Windows `%TEMP%` (`hits.txt`), outside the repo. Scenes had 0 hits for every identifier, so `scenes/` is left out below.

## 1. Identifier counts (matching lines per file)
- **mvp_bugs_confirmed** (2): game_state.gd 1 (`FLAG_TYPES` :75), product_state.gd 1 (`BUGS_CONFIRMED` const :16).
- **bugs_confirmed()** accessor and other readers (11 files, 38 hits):
  - endgame_smoke 15, run_probe 5, product_state 4, support_system 4, product_read 2.
  - seams_product.gd 1 (:90 `urun.bugs_confirmed`), b2b_sales_system 1 (:504), sprint_bridges 1, build_bar_model 1 (:50).
  - data: b2c_refunds.json 1, bug_pile.json 3.
- **mvp_live_bug_count** (6 files, 39 hits): endgame_smoke 26, run_probe 4, product_system 4, main.gd 3 (shots :1044, :1114, :1177), game_state 1, sprint_system 1 (:1093 reset in `_go_public`).
- **mvp_live_bug_progress** (4 files, 11 hits): endgame_smoke 7, product_system 2, game_state 1, sprint_system 1 (:1094).
- **mvp_bug_history** (4 files, 10 hits): product_system 4, endgame_smoke 3, save_manager 2 (:724, :725 in `_migrate_14`), game_state 1.
- **live_bug_count()** method (9 files, 19 hits): endgame_smoke 4, product_system 3, vc_pitch_system 3, sales_system 2, support_system 2, run_probe 2, quality_model 1, term_sheet_table_system 1, inbox.gd 1.
- **tickets** (word) (11 files, 47 hits):
  - sprint_bridges 11, endgame_smoke 10, sprint_catalog 10, sprint_system 7, product_fixtures 5.
  - rnd_system 3, product_model 3, game_state 2, run_probe 2, area_panel 2, sprint_ui_shared 2.
  - strings.csv 8 rows.
- **ticket_seq** (3 files, 6 hits): sprint_bridges 3, sprint_system 2 (`new_state` :82), game_state 1.
- **voices_seen** (5 files, 8 hits): sprint_system 3 (:83 and `voices_seen()` :376), product_tab 2 (:8, :248), product_fixtures 1, sprint_catalog 1, area_panel 1.
- **fix_run** (any form) (15 files, about 80 hits):
  - support_system 13, endgame_smoke 23, product_state 5, build_bar_model 7, build_bar 6, run_probe 5.
  - effects.gd 4, seams_sales.gd 4 (:119-123), main.gd 3, game_state 3, event_bus 2 (:147-148 signals), lint.gd 2.
  - chips.gd 1, product_model 1 (:254), bug_pile.json 3.
- **bug_pile**: endgame_smoke 2, bug_pile.json 1 (106 lines), tools/lint_v3_frozen.json 1 (:28).
- **gate_faulty** (sprint_system only, 4): :85 (`new_state`), :226, :227, :1042.
- **urgent_tickets**: sprint.json 1, sprint_catalog 3 (:148, :265, :285), endgame_smoke 1.
- **effort.fix / fix_urgent**: sprint.json 1 line (:6, both keys), sprint_catalog 1 (:266), endgame_smoke 1.
  - Bare "effort" is far too broad: 27 files, mostly unrelated Ar-Ge and line data.
  - The fix-relevant effort readers are sprint_catalog :209-216, :266 and the migration at save_manager :863.
- **ticket_titles**: sprint.json 1 (`content.ticket_titles` :34), sprint_catalog 1 (:202).
- **impact.ticket**: sprint.json 1 (:33), sprint_catalog 4 (`_impact` :715-719, `w.ticket`).
- **_post_ship_wear_hourly**: product_system 2 (:128 call, :133 def), support_system 1 (:170 comment).
- **reports_missed**: product_state 2, endgame_smoke 2, build_bar_model 1.
  - `REPORTS_WEEK_NET` / `mvp_fix_run_*`: game_state, product_state, support_system, main.gd (:1286-1304 shots).
- **PRODUCT_TICKET\***: sprint_catalog 1 (:203), strings.csv 3 rows (`_0..2`).
- **PRODUCT_VOICES\***: area_panel 2 (:166, :193), strings.csv 3 rows.
- **Other CSV families** (rows): PRODUCT_NEW_ 2, PRODUCT_FX_VOICES 4, PRODUCT_FX_TICKETS 4, PRODUCT_AREA_TICKETS 2, PRODUCT_CUSTOMER_TICKETS 2, PRODUCT_RIVAL_VOICE 1.
  - PROD_FIX_RUN 2, FIX_RUN_REFUSED 1, PRODUCT_IDLE_FIX 1, BUILD_SUPPORT_ 3 (:590-592), EFFECT_FIX_RUN 1.
  - PROD_TIP_BUGS 1 (0 code refs, already dead), EV_PRODUCT_BUG_PILE 5.
  - VC_Q_BUGS 2, HUNT_CB_BUGS 1, SALES_PROBE_PROBE_STABILITY_BUGS 1, HR_AREA_MEANING_TESTER_QA 1, ONB_SKILL_QA_DESC 1.
  - `PRODUCT_BUGS_TIP*` has 0 rows, so it is a new key.
- **data/**: only sprint.json, bug_pile.json and b2c_refunds.json (:39 `urun.bugs_confirmed`). **tools/**: only lint_v3_frozen.json.
- **Docs that still list the fix-run seams** (outside the §4.1 grep): HARITA.md, ACIK_KARARLAR.md, `_vocabulary.md`, EVENT_SIGNAL_MANIFEST.md.
- **Voice icon**: `assets/icons/product/voices.svg` is used only by `SprintUiShared.VOICES` (:12).

## 2. Smoke cases touching these identifiers
All cases are `_case_*` in scripts/debug/endgame_smoke.gd. The dispatch line number is in parentheses.
- **K2 (Hotfix / fix run / bug_pile / reports_missed):**
  - `fix_run_ships_subset` (190; 16 hits, drives `BuildBarModel`; delete or rewrite)
  - `destek_empty_desk_piles_up` (189), `destek_survives_ship` (396)
  - `hotfix_founder_takes_support_desk` (247; "hotfix" here is the 2026-08 patch round, but it touches the desk)
  - `event_beat_freezes_seams` (322), `split_bars_name_their_cause` (417)
  - `support_desk_rates_stack` (251), `product_read_catalogue` (195)
  - the `bug_pile` card is touched in 2 helper spots
  - `coupling_wear_team_average` (204; 8 hits on wear and `live_bug_count`; K5 owns the wear removal, K2 only the fix-run part)
- **K3 (single store, tickets, schema 16):**
  - `sprint_fix_card_closes_tickets` (456; 11 hits), `sprint_faulty_ticket_deterministic` (455; 11)
  - `sprint_save_roundtrip` (460), `sprint_release_resets_live_bugs` (463; 6)
  - `sprint_mvp_three_identity_k1` (454), `sprint_legacy_beta_cards_ship` (462), `sprint_decision_blocks_progress` (461)
  - `save_v10_product_state` (421), `save_v13_day_stamps_migrate` (285)
  - new `save_v15_*` cases are required by PRD §4.7
  - `rnd_note_author_and_lines` (419; 12 hits on per-line tickets)
  - `risk_exit_stamps_day` (353), `callback_contract` (95) and `pitch_bug_interrogation` (96) (VC `bugs_under`)
- **K4 (fix card):**
  - `sprint_fix_card_closes_tickets` (456) again, `sprint_ceiling_125_blocks_add` (452)
  - the new `sprint_fix_preview_matches_close` has no existing case
  - `--sprint-probe` is the other gate
- **K5 (L reads, wear, churn):**
  - `conversion_bug_penalty` (347), `coupling_cs_dampen_axis` (205), `b2c_satisfaction_drifts_to_experience` (332)
  - `b2b_*`: `b2b_cs_absorbs_routine` (159), `b2b_ignore_then_churn` (135), `b2b_lifecycle_and_countdown` (131), `b2b_onboarding_grace_floor` (132), `b2b_satisfaction_leaves_b2c_identical` (133), `b2b_retention_routes_seams` (134)
  - `sales_meeting_time_skip_founder_share` (142), `infra_local_provider_tradeoff` (194)
- **K6 (line panel / Destek card):**
  - `fix_run_ships_subset` (190) again, because `BuildBarModel.derive` is exercised there. No other existing case touches `AreaPanel` or `ProductModel` voices.
  - `_node_tree_has_text` is a helper and `product_read_catalogue` (195) is shared.
  - Visual acceptance is by shots, not smoke.

## 3. Debug shots and fixtures
- **`--office-shot=<office>:<hour>:desk_shut`:** exists at `main.gd:1289` (match in `_run_office_shot`, header comment :1220).
  - It sets `REPORTS_INCOMING` 12 and `REPORTS_WEEK_NET` 12 on a B2C note_tool. It writes a removed flag, so it must be rebuilt.
  - The sibling `fix_run` shot (:1295-1304) also exists and must go. CLAUDE.md §12 documents `desk_shut`.
- **`--product-shot=live:<scenario>`:** handled in `main.gd` ~:3255-3290 (`_seed_product_live`).
  - `live:active`: `apply_lead`, `send_next`, `start`, one `day`, returns at :3283.
  - `live:plan`: returns at :3276 after `send_next`.
  - Header doc is at :3124.
- **`edge:<name>`:** `main.gd:3191` calls `_shell.debug_product_apply(id.trim_prefix("edge:"))`. `game_shell.gd:172` relays to `scripts/debug/product_fixtures.gd`.
  - The `_build()` match (:70-170) has these ids: `c4/goal_menu/approved`, `replan`, `cards`, `no_candidates`, `cap_zero`, `over_100`, `over_125`, `empty_start`, `no_release`, `gate`, `b2b_no_requests`, `locked_k3`, `history_empty`, `history`, `pm_started`, `mvp`, `quarter_no_pm`, `voices_open`. `voices_seen` is an `act()` arm.
  - `BASES` (:14) maps ids to mockups c2, c3, c4, c5.
  - Stale after K3/K6: `edge:voices_open` (also special-cased at `main.gd:3192-3198`), the `voices_seen` arm, the `tickets` and `voices` effect chips (:289, :475-477, :500), `_heard()` (:530) and the `customer.tickets` field (:359, :573).
  - There are no fixtures for a line panel, a fix card with a long account name, or a release note. All are new.
- **`--sprint-probe` `team=`:** exists. `sprint_probe.gd:4` documents it, :52 holds the default `"team": 1`, :73 adds N-1 mid-skilled hires, :171 is the hire helper.
  - The PRD baseline `hours=40:cards=2:ticks=60:team=3:fill=1:events=1` is all valid keys (`events` default 0 at :51, `fill` at :52).
  - Mismatch causes `cause=<event id>` and `cause=team` are at :63, :209.

## 4. Save, state and flag facts
- `SaveManager.SCHEMA_VERSION` = 15 (save_manager.gd:16). `MIN_LOADABLE_VERSION` = 10 (:23).
- **`_migrate_16` does not exist.** `read_slot` chains `<11`, `<13`, `<14`, `<15` at :186-201. `_migrate_15` is at :817.
- `GameState.FLAG_TYPES` is at game_state.gd:48.
  - Entries to remove: `mvp_live_bug_count` :61, `mvp_live_bug_progress` :62, `mvp_bug_history` :63, `mvp_bugs_confirmed` :75, `mvp_fix_run_active/fixed/progress` :77-79.
  - `mvp_reports_week_net` is also referenced (in `ProductState`).
  - `mvp_reports_incoming` :73 and `mvp_reports_progress` :74 stay (the validation pipeline).
- `SaveManager.reset_all_owners` (:320) does not name SprintSystem or ProductState.
  - It calls `ProductSystem.reset()`, which does `ProductLines.reload`, `SupportSystem.reset` and `ProductRead.reset`.
  - Sprint state is part of the `GameState.product` dict, rebuilt by `SprintSystem.new_state` (called from save_manager :882 and `_migrate_15`).
  - The PRD §6 line "reset_all_owners entries for SprintSystem/ProductState" has no literal entry. There is no `SprintSystem.reset`.
- `SprintSystem.new_state` (sprint_system.gd:76-86) has `tickets: []`, `ticket_seq: 0`, `voices_seen: {}` (:82-83) and `gate_faulty: []` (:85). A_PLAN renames `gate_faulty` to `pending_faulty`.
- `GameState.set_reputation` already clamps to [-10, 100] (game_state.gd:346-348).
- **Missing today, as the PRD says:** `SalesArchetypes.uses_axis`, `USE_AXIS_MIN`, `ProductState.add_bugs/open_bugs`.
- **Exist and usable:** `SprintSystem.team()` (:518), `HRConstants.MAX_JOBS_PER_PERSON` = 2 (:142), `focus_mult` (:184), `Customer.seats` (customer.gd:25), `display_name()` (:103), `CharacterRegistry._validate_shape` (:468).

## 5. class_name impact
- No planned deletion removes a whole `class_name` file.
  - `SprintBridges` keeps `requests` and `rival_hits`. `AreaPanel`, `ProductModel`, `SprintUiShared`, `SupportSystem` and `ProductState` all stay.
  - `build_bar_model.gd` deliberately has no `class_name` (:8-9); smoke `preload`s it.
- Only `bug_pile.json` (a card, not a class) and `voices.svg` (asset, with `.import`) go.
- A `--headless --import` is needed only if K6 adds a new script with `class_name` (a separate line-panel file) or K3 splits a helper out of `SprintBridges`. Neither is planned.

## 6. A_PLAN §5.1/§5.6 spot check
About 45 references checked against the code; all but the three below match. A few examples that match:
- support_system :172 (carried-bug coefficient) and :273
- sales_system :33, :106, :424, :467 and :410
- quality_model :109-112, :233; b2b :136, :504; vc_pitch :1145, :1149, :1193, :1199, :1291
- term_sheet :62, :549
- effects :43, :439; chips :44; lint :323, :341
- time_manager :427; product_model :254; inbox :211; rnd_system :595-603

Contradictions and drift:
1. **A_PLAN §5.6 K2 vs PRD §4.12 on `desk_shut`.** A_PLAN deletes the `desk_shut` and `fix_run` shots. The PRD (which wins) keeps `desk_shut` and rebuilds it for the new card. Only `fix_run` is deleted.
2. **A_PLAN §5.1 row 8 cites `sales_system.gd:204` and `:184` as the B2C churn site.** The code there is `CHURN_COEF * max(0, EROSION_THRESHOLD - quality_term)` and the `quality_term` line, i.e. the existing quality-erosion churn.
   - The new bug churn term must be added next to it. It does not replace a bug-reading line.
   - Row 5 is the only place L enters this path (via `QualityModel`).
3. **A_PLAN §5.6 and PRD §6 say `ProductSystem.hourly_tick` drives wear and TimeManager:427 calls it.**
   - This is right (`product_system.gd:125` runs `_post_ship_wear_hourly` at :128), but A_PLAN moves the removal of wear, `_is_free`, `_founder_on_build` and `_team_area_avg` to K5.
   - PRD §6 (Karar 13) still needs `_founder_on_build` for matrix linkage (K1b). Deleting it in K5 conflicts with K1b. Check the order.
4. **A_PLAN §5.3.1 says "hat: bug_line() weighted pick, same week same line".** PRD Karar 3 replaces this with an independent, equal-probability pick per bug. The `×3` weight and the clustering constant are invalid.
5. **Tickets are not an independent ledger today.**
   - `SprintBridges.sync_tickets()` (:19-42) rebuilds the ticket list from `mvp_bugs_confirmed` (hash-spread over lines). It runs at `sprint_system.gd:31` (daily), in `close_tickets`, `add_faulty_ticket`, and twice in smoke.
   - `_migrate_16` "count ticket rows per line, spread the excess of C" is therefore correct, but tickets may lag C.
6. **PRD says the Destek card shows no action.** `build_bar.gd` still has the action button (:174-177 `start_fix_run`/`end_fix_run`) and `build_bar_model` derives `fix_run_active`, `decision_key`, `refusal_key`.
   - The whole model is rewritten in K6. K2 only has to stop referencing `can_start_fix_run`, `fix_run_active` and the `REFUSAL_*` constants. They can sit on a stub until K6, or K2 and K6 must be done together.
7. `run_probe.gd:1104-1122` is the bot's fix-run block. `PROBE B2C` also prints `live_bugs` and `confirmed` (:31, :532-536).

**Cross-slice coupling:** K2 deletes `can_start_fix_run` and the `destek.*` seams, which `bug_pile.json` and the smoke cases read. K3 swaps `bugs_confirmed()`, which has 11 readers. K4 and K6 share `sprint_ui_shared` and `product_model`.

## Keşifçi: k5-bot

**K5 sizing report** (read-only; HEAD 1faeb82; no Godot was run, so every run-time figure below is an estimate)

**Caveat on the code state.** K5 comes after K1–K4 in the PRD (PRD_FAZ_A_HATALAR.md:559-575). K2 deletes the Hotfix and fix-run code, and K3 replaces the ticket ledger with the single bug store. The file:line references below describe today's tree and will shift.

**1. RunProbe.PRESETS (scripts/debug/run_probe.gd)**
- The table is at :72-85 and has 17 keys.
  - Fixtures with `{}`: `b2b_reps`, `b2b_solo`, `b2b_risk`, `b2b_slip`, `b2c`, `b2c_neglect`.
  - Played runs with a `subtype`: `full_run`, `full_run_naive`, `full_run_discount`, `full_run_vc_naive`, `full_run_vc_cautious`, `full_run_lean`, `full_run_b2c`, `full_run_b2c_video`, `full_run_b2c_vc_cautious`, `full_run_b2c_vc_walk`, `full_run_b2c_k1`.
- Fields in use are `subtype` (`erp` for B2B, `note_tool` for B2C), `policy` (:75-76, values naive|discount, default "sensible"), `vc`, `staff_cap` and `k1_only`.
- There is no `fix` key today. The only `fix` strings in the file are `fix_run` in PROBE PLAY lines.
- `--run-log=<preset>:<weeks>:<mode>[:<seed>][:replay=K]` is parsed in `run()` (:154-173). `main.gd:216-218` passes the flag to `RunProbe.run`, and an unknown preset prints `PROBE ERROR unknown preset` (:171).
- `_seed_world` (:1558-1570) reads the spec only when the preset name starts with `full_run`: `subtype`, `policy`, `vc`, `staff_cap`, `k1_only`. A `fix` field needs one more `spec.get("fix", ...)` read there.
- Two ways to add the arms:
  - 8 explicit presets (4 arms x 2 markets), as the PRD says.
  - A named 5th spec part like the existing `replay=` option (:167-170), giving 4 arms plus a market choice.
- `_run_seed` defaults to 424242 and is the 4th spec part, so seeds 7 and 11 work as `full_run_fix_none:104:sim:7`.
- Static state is reset at :175-197. Any new bot state (arm, debug switch) must be reset there.

**2. How the bot plans a sprint today**
- `_plan_the_sprint` (run_probe.gd:837-872) does these steps in order:
  1. `_plan_promises`.
  2. On B2C, adds the paid-plan card.
  3. `SprintSystem.apply_lead()` (:855).
  4. `_keep_building` on B2C.
  5. `SprintSystem.start()`.
- It prints `PROBE PLAY ... sprint N start cards=... used= capacity=` (:870).
- `_k1_only` already strips cards after the lead with `SprintSystem.remove` (:856-859). That is the same pattern fix_none needs.
- The fixture presets use `_start_on_lead` (:878-882).
- `apply_lead` (sprint_system.gd:260-266) calls `SprintCatalog.lead_suggestion()` (sprint_catalog.gd:410) and places each card with the private `_place` (:1213). It does not go through `add` or `can_add`.
- `_suggest` (sprint_catalog.gd:790-830) builds the `must` list in this order:
  1. Cards that carry promises.
  2. The soonest request (:806).
  3. The paid plan (:807).
  4. The best card of the weakest area (:808). This can be a fix card.
  5. All urgent fixes (:809).
  - Must cards are taken up to `capacity * cap_ceiling`, and the first card is always taken when the sprint is empty (:814). The rest of the pool is filled by impact/effort ratio, played out with `plan_outcome` (:817-829).
- Urgent rule: `is_urgent` (sprint_catalog.gd:284-285) is true for a fix card with at least `urgent_tickets` tickets.
  - The value is 3 (data/product/sprint.json:36).
  - Effort is 1 normally, 2 when urgent (sprint.json:6, `effort.fix` and `fix_urgent`).
  - `cap_ceiling` is 1.25 (sprint.json:25).
  - Urgent fix cards are built at sprint_catalog.gd:262-269 and sorted urgent-first at :275.
- Why `SprintSystem.add` rejects a card (sprint_system.gd:92-96):
  - `_movable` (:1185) requires a state other than running or done, and `gate_reason(step) == ""`.
  - `can_add` (:536) requires plan mode and `capacity() > 0`, then `_takes` (:545-552).
  - `_takes` accepts when the sprint is empty (load <= EPS). Otherwise it needs `load + extra <= cap * cap_ceiling` AND `_play_out(...).spare > EPS` (some points must remain free).
  - Once the lead has filled the sprint, `add` rejects the fix card. This is why the FIXBOT attempt (A_PLAN.md:476-477) did nothing.
- The PRD's order (build the lead plan, remove all fix cards, add the arm's fix cards first, then refill) works with the public seams:
  - `remove` (:110) deletes unstarted cards.
  - On an emptied sprint, `add` accepts the first card, and later fix cards are only bounded by `_takes`.
  - A second `apply_lead` would put urgent fixes (:809) and the weakest-area card (:808) back. So K5 has to change `_suggest` (the acil-rule work) or filter the pool for fix_none.
- Calling the private `SprintSystem._place` from the bot bypasses `_takes`. It is the fallback if the PRD's step 3 still gets rejected.

**3. Hotfix / fix-run block and PROBE formats**
- The fix-run block is in `_run_the_company` (:1086-1124), specifically :1099-1122.
  - It ends the pass when `bugs_confirmed() <= 1` or after 4 days, and starts one when `bugs_confirmed() >= 6`, via `SupportSystem.start_fix_run()` / `end_fix_run()`.
  - It lends a developer to the support job.
  - State vars are `_fix_on_at`, `_fix_off_at` and `_fixer_id` (:129-131).
  - A_PLAN.md:473 says K2 deletes the block and these vars.
- The founder takes the support desk on B2C at :1093-1098. `_run_research` and `_keep_the_team` are called at :1123-1124.
- Line formats:
  - `PROBE B2C day aud paying price conv sat sat_target live_bugs confirmed q interest occ desk incoming inflow_day validation_day` (:532). Printed weekly, B2C only.
  - `PROBE SHIP day version label stability innovation experience bugs tickets` (:283).
  - `PROBE STATE ... aud sat bugs q ...` (:483).
  - `PROBE CUST ... target ... bugs` (:511).
  - `PROBE CHURN day id sat tol trust phase streak countdown mrr` (:433).
  - `PROBE SPRINT day n label shipped carried velocity=done/total` (:292).
  - `PROBE WEEK` (:754).
  - `PROBE END` (:766).
  - `PROBE PLAY` lines for the sprint start (:870), fix_run (:1106, :1121) and promise cards (:918).
- There is no `PROBE FIX` yet. The PRD wants one at each sprint start with the fix-card remaining sum divided by `capacity()`. A natural place is right after `start()` at :869-872.
  - The data comes from `GameState.product.sprint.cards` and `SprintSystem.remaining` / `capacity`.
  - The new unit should be one series of per-sprint lines (day, share, number of fix cards, emergency flag).
- The weekly new-bug and open-bug series for table (a) and (b) need per-week lines too. The new open-bug store has no probe line yet.

**4. Gates and run time**
- `tools/run_gate.sh`:
  - It runs `full_run`, `full_run_b2c` and `full_run_vc_cautious` sequentially, each as `--headless --run-log=$p:$WEEKS:sim`.
  - `WEEKS` defaults to 730 (:17) and `RUN_TIMEOUT` to 900 s (:18).
  - It expects exactly one `PROBE END` with an ending and zero engine or `PROBE ERROR` lines, and prints `RUN OK ... ${secs}s`.
  - `tools/gate_common.sh` supplies the Godot lookup and the `engine_errors` regex.
- `tools/plausibility_run.sh`:
  - It runs 40 runs x 16 weeks (SEEDS=20 x plain/early), then PLAUS LONG with 4 x 60 weeks.
  - Defaults are `RUN_TIMEOUT=180`, `LONG_TIMEOUT=600` and `JOBS=1`.
  - Each run gets its own process and its own `APPDATA`/`HOME` (:47) so parallel runs are safe.
  - It prints `PLAUS SUMMARY/LONG ... secs=` as phase totals.
- No document records the headless wall time of a `--run-log`.
  - The 900 s timeout for 730 weeks is a ceiling, not a measurement.
  - GUNCELLEMELER.md:484 gives 104 weeks at 1x REAL clock as about 39 minutes. That figure is not headless sim.
  - HARITA.md:359 only describes the gate.
- A baseline run time is unknown. The PRD's A1 step already includes a base run, and the first K5 action should be a single timed 104-week run.

**5. Tools that aggregate ^PROBE lines**
- None. `tools/` holds `smoke_run.sh`, `run_gate.sh`, `plausibility_run.sh`, `gate_common.sh`, `export_build.sh`, `gen_signal_manifest.py`, lint JSONs, `brand/`, `office3d/` and `people/`.
- Only run_gate.sh and plausibility_run.sh grep `^PROBE`, and only for END/ERROR.
- K5 needs a new parser and table maker covering the medians by market x early/late x arm x seed. Python 3.14 exists at /c/Python314.
- CLAUDE.md §8 says measurement files do not go into the repo. The PRD (§9 item 6) wants the table-producing commands listed in the R report. Either put the script in the scratchpad, or ask Erdem whether a `tools/` script is acceptable.

**6. Switches that could zero bug effects (fix_off)**
- No such switch exists. The only debug overrides are `EndingsSystem.build_scope_override` (endings_system.gd:374) and `SummarySystem.frequency_override` (summary_system.gd:41). RunProbe sets both at run_probe.gd:197-199. That is the precedent for a static var set by RunProbe, which also has to be reset in `run()` and in `SaveManager.reset_all_owners` if it must not leak.
- Bug effects that exist today and are consumed through `ProductSystem.live_bug_count()` (product_system.gd:100):
  - `QualityModel.effective_stability` (quality_model.gd:92) via `economy_dims_from_flags` (:109-112). This feeds the B2B satisfaction target, the B2C satisfaction target, the audience quality term, the signing seed and the price value.
  - `SalesSystem._tick_satisfaction` push (sales_system.gd:423-424) and the conversion bug factor (:467).
  - `SupportSystem.daily_satisfaction_damage` (support_system.gd:273) and `apply_daily_satisfaction_damage` (:281-299), which the PRD keeps.
- A_PLAN §5.3 rewrites these and deletes `BUG_STABILITY_COEF`, `SATISFACTION_BUG_*` and `BUG_CONV_*` (A_PLAN.md:413-416).
- The natural home is the K5 impact chain itself. One static flag in whichever module owns the open-bug-to-impact functions (the B2B per-account term, the B2C audience term, the weekly reputation step), checked by each of them. The existing support damage must be checked too. RunProbe sets it for `fix_off` only.

**7. K5 impact-chain hooks (file:line today)**
- B2B satisfaction target: `B2BSalesSystem.satisfaction_target` (b2b_sales_system.gd:124) calls `_target_on` (:129-141). The health term is read at :136 from `economy_dims_from_flags`. The drift is applied in `_tick_satisfaction` (:73-107).
  - The target is clamped 0..100 (:141).
  - A_PLAN §5.3.7 has the new formula: `target = clamp(raw stability score + trust ledger - min(0.5 x b, 20), 0, 100)`, with `b` the open bugs on lines the account uses. The onboarding floor (:139-140) goes after the penalty.
  - The new line-usage predicate `SalesArchetypes.uses_axis` does not exist yet (PRD :137-138).
  - Churn follows from `_tick_at_risk` (:163-185), `_tick_healthy` (:202) and `_churn` (:236-243), which also writes the brand hit.
- B2C audience delta: `SalesSystem._audience_delta_per_hour` (sales_system.gd:183-200), applied by `_tick_b2c_audience` (:168-175).
  - `GameState.reputation * HOURLY_AUD_REPUTATION_COEF` is already there at :188 (coefficient at :52).
  - A_PLAN §5.3.8: `delta -= B2C_BUG_CHURN_COEF x min(max(0, O-3), 40) x audience`.
  - B2C user satisfaction target and drift are at :417-428.
- Reputation:
  - `GameState.set_reputation` (game_state.gd:346-349, clamp -10..100, emits `reputation_changed`).
  - Its only gameplay caller is the card effect `add_reputation` (events/core/effects.gd:240-241), so no system writes reputation from bugs today.
  - A_PLAN §5.3.9 adds a weekly writer in `SupportSystem.daily_tick`. The PRD drops the `max(0, ...)` floor, so the clamp at -10 applies.
  - Readers are `vc_pitch_system.gd:1145` and `:1193`, `sales_system.gd:188` and the top bar (`top_bar.gd:220`).
- Wear removal and the bug source:
  - `ProductSystem._post_ship_wear_hourly` (product_system.gd:133-145) with `WEAR_*` (:15-18), called from `hourly_tick` (:125-128).
  - `SupportSystem.reports_per_day` (support_system.gd:164-176) with `INFLOW_*` (:34-43) and `usage_multiplier` (:181-184).
  - A_PLAN §5.3.1 says every hour a validated report becomes one open bug.

**Estimate and verdict**
- K5 coding scope:
  - About 8 preset entries or one spec option, the fix-arm branch in `_plan_the_sprint`, a `PROBE FIX` line plus weekly flow lines, and an `_suggest` change for the urgent rule and a fix_none filter.
  - Three impact-chain terms (B2B target, B2C audience, weekly reputation) behind one debug switch.
  - Wear removal, and a new parser/table script.
  - No smoke is required beyond the PRD's `neglect_reputation_below_zero` case (PRD §4.8).
- That is roughly 150-300 changed lines across 8 to 10 files, plus the 16-run matrix (4 arms x 2 markets x 2 seeds x 104 weeks) and calibration.
- Run time, unmeasured and assumed: if a headless 104-week `full_run` takes 1 to 3 minutes, one pass of 16 runs takes about 16 to 48 minutes serial. Running 4 jobs in parallel, each with its own `APPDATA` as plausibility_run.sh does, brings that to about 5 to 15 minutes. Runs that end early are shorter.
- Is 4h30 plausible? Yes if runs are about 2 minutes or less. It is tight if the PRD's target misses force repeated calibration passes, since each pass costs one matrix run plus analysis.
- The PRD already says a missed target is not tuned silently but reported "onay bekliyor" (PRD :349-351). That bounds the time to one or two matrix passes.
- Main risks:
  - K1b's B2C bot changes and K3's rewrite of the data sources land first, so the K5 line numbers will move.
  - The emergency-card choice is B's, so the arm only gets the hook, not the choice.
  - The fix_due "due line" definition depends on E1.
  - Seed 7 and 11 runs may end early; the PRD allows that if marked in the table.
- The first action is to measure one timed 104-week `full_run` and `full_run_b2c` for wall time, then set JOBS.

Absolute paths of the primary sources:
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_ab/PRD_FAZ_A_HATALAR.md
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_ab/ek/A_PLAN.md
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/scripts/debug/run_probe.gd

## Opus incelemesi (adım tablosu)

**Findings on the draft step table** (HEAD 1faeb82, read-only)

1. **Major: K1a cannot pass on its own, so it should merge into K1b.**
   - Evidence: the desk side already behaves as Karar 13 asks. A founder on Build only is off the desk, Build plus Support counts 0.5 through `effective_skill`, and passive care only runs when `assigned_job_ids` is empty (`support_system.gd:191-223`, `hr_system.gd:393`).
   - The §4.9 sprint halves ("0.5 in the sprint", "a founder with no job is not in the sprint") only work once `team()` reads jobs. That is K1b's change to `sprint_system.gd:518`.
   - A_PLAN's K1 code (passive care leaves out a founder who has a card) stops mattering after K1b, because a founder with no job is no longer in `team()`. That code would be thrown away.
   - Change: make one row, "K1: kurucu + Görevler matrisi", at Sonnet max, about 3 h. This saves one Opus review and one gate round (about 40 min). If the PRD's split must stay, K1a should only hold `_validate_shape` (`character_registry.gd:507-510`), the desk half of §4.9 and a save round trip of a two-job founder, at 30 min.

2. **Major: K1b's spec is missing three edge cases.**
   - (a) Shares add up per sprint job. A person on Build and Test counts 0.5 + 0.5 = 1.0 in the sprint, not 0.5.
   - (b) A job change in the middle of a sprint only reaches the cards on Ekip's day. `_on_assignment_changed` refreshes only outside the active sprint (`sprint_system.gd:915-917`); `_restaff` runs on `hr_day_processed` (:896-910). The K1b spec should say capacity follows the same rule, or `--sprint-probe` will show unnamed mismatches.
   - (c) The founder's starting job is Test when QA is the highest area (`game_state.gd:978-983`). He is still in the sprint, but the PRD text says "Yapım". Either note it or align it.
   - Change: write all three into the K1 "Ne" cell.

3. **Major: K1b has no gates for "ekonomi kayması" or §4.12 "sprint planı".**
   - The PRD says `full_run_b2c` and `run_gate.sh` are affected (Karar 13). CLAUDE.md §3 says a gate is green before the commit that claims it.
   - No fixture exists for "a person on Support in the team list" or "nobody in the sprint" (`product_fixtures.gd:70-170` has neither).
   - Change: add a `full_run_b2c` 104-week baseline to A1d. Give K1 one full `run_gate.sh` pass, plus a comparison against that baseline written to scratchpad notes. Add new `edge:` fixtures for the Support-member and empty-sprint states, with TR/EN/cb/1.25 shots. Add the §4.9 empty-desk office shot.

4. **Major: what can run before E1, and the reordering it allows.**
   - K1–K4 do not depend on E1. K4 puts the effort tiers and the urgent threshold in `sprint.json` as one setting, keeping today's value 3 (`sprint.json:36`); E1 only changes the values.
   - Only K5's calibration depends on E1. K6 and K7 do not depend on K5.
   - Change: if E1 has not come back when K4 commits, run K6 and K7 before K5. K8 always stays last.
   - In practice: the main session starts the K1 coding agent in the background and only then sends E1. Otherwise ending its turn stops all work.

5. **Major: the K5 matrix runs against a shared, live tree.**
   - The 16 runs (4 arms x 2 markets x 2 seeds x 104 weeks) load scripts from the working tree. If K6 code is edited while they run, the measurement mixes two builds.
   - Change: freeze the tree for the length of the matrix. No other K step edits code until it ends.
   - Run the matrix once: `JOBS=4`, each run with its own `APPDATA`, and the parser script in scratchpad (CLAUDE.md §8).
   - A_PLAN Risk 2 ("kalibrasyon turu ... yinelenir") breaks the no-repeat rule and is dropped. A missed target goes to R marked "onay bekliyor" (§4.5).

6. **Minor, resolved: the K5 wear removal vs K1b conflict raised by the scout is not real.**
   - `_founder_on_build` only feeds `_team_area_avg`. `_team_area_avg` is only called by wear (`product_system.gd:86`, `:136`; grep finds no other callers).
   - K5 can delete the `_is_free` / `_founder_on_build` / `_team_area_avg` group as A_PLAN §5.6 says.
   - Change: one line in K1, "K1b `_founder_on_build`'e yeni bağımlılık kurmaz". K5 also cleans up the `hr_system.gd:149` comment and the smoke case at `endgame_smoke.gd:2581-2590`.

7. **Major: the K2 → K3 → K5 split needs to be stated explicitly.**
   - K2:
     - removes fix-run, `bug_pile` (+ its `lint_v3_frozen.json:28` row), the `destek.can_start_fix_run` / `fix_run_active` seams and the `fix_run_*` signals;
     - removes the build_bar button, while the card keeps "Doğrulanmış/Gelen" for now;
     - rebuilds `desk_shut` in the same commit, because it writes `REPORTS_WEEK_NET` (`main.gd:1289`). This is not a deletion;
     - deletes the `fix_run` shot (`main.gd:1295-1304`) and the bot's fix-run block (`run_probe.gd:1099-1122`).
   - K3 brings the single store (C → `open_bugs`), the first half of `_migrate_16` and the uniform random pick. L and wear stay; the in-between state is today's game.
   - K5 removes L and wear together with all their readers, and finishes `_migrate_16` (L keys and `bugs_under`).
   - The §4.1 grep can only pass after K5, so it belongs in K8.
   - Change: write these boundaries into the "Ne" cells.

8. **Major: the generated docs are missing from the table.**
   - K2 deletes signals and seams. K3 renames `urun.bugs_confirmed` → `urun.open_bugs` and adds `line_bugs_cleared`.
   - Change: in K2 and K3, run `--event-vocab` (writes `_vocabulary.md`) and `python tools/gen_signal_manifest.py`, then commit both outputs. Add `--event-lint` in K2, K3 and K5.

9. **Major: the write points B needs (§9 item 5) have no step.**
   - Missing: `ProductState.add_bugs(hat, n)`, `line_blocked(hat)`, `EventBus.line_bugs_cleared(hat, n)`, the entry that puts a line's fix card into the sprint or moves it to the front, and the "release.faulty" read.
   - Change: the first three go in K3, the card entry in K4. The Opus review in K8 checks that each has a name and a caller.

10. **Major: Karar items with no step.**
    - Karar 12 texts `HR_AREA_MEANING_TESTER_QA` and `ONB_SKILL_QA_DESC` (the "canlı aşınma" promise) → K5, together with the wear removal; TR/EN onay bekliyor.
    - Karar 4: rename the "Acil" label so it does not clash with B's emergency event → K4.
    - Karar 10: the surface where the reputation reason shows → K5. The `ISLER.md` note about the VC follow-up → K8.
    - Karar 6: `uses_axis` and `USE_AXIS_MIN` → K4.
    - Karar 3: a bug born with no live line is held for v1.0 (`pending_faulty`) → K3/K4.
    - Change: add these to the cells.

11. **Major: smoke falsification and the shared tree.**
    - §4.2 requires falsification, and the other new cases (§4.3, §4.6b, §4.7–§4.10) should have it too.
    - It is a temporary code edit, so `git checkout --` is not allowed. The edit is undone by hand.
    - Change:
      - The Sonnet step falsifies, runs, undoes the edit and writes a `## FALSİFİKASYON` line, following the existing pattern (`endgame_smoke.gd:17777`).
      - The Haiku step checks with `git diff` that no falsification edit is left.
      - Run targeted smoke sequentially, or at `CASE_TIMEOUT=300` under `xargs -P 2` (cases share save slots).

12. **Minor: add a `--headless --import` rule.**
    - No step plans a `class_name` change today, but K3 or K6 could add one.
    - Change: the first Haiku gate line in every K step is "diff'te `class_name` değiştiyse `--headless --import`".

13. **Minor: K7.**
    - Change, in this order:
      - First copy `git diff -- themes/` and the two `.tres` files to scratchpad.
      - Do not touch or stage `project.godot`.
      - Stage the regenerated themes, `ui_tokens.gd` (with the `THEME_STAMP` bump), `build_theme.gd`, `sprint_card.gd` and `sprint_ui_shared.gd`, each by explicit path. Never `git add -A`.
      - Gates: `theme_check.gd`, `--theme-contrast-audit`, and `live:active` / `live:plan` hover shots.
      - The report tells Erdem the editor's uid lines were lost.

14. **Minor: RAPOR_A must not appear early.**
    - The K1 economy shift, the K5 tables and the commands go to `<scratchpad>/A_notlar/Kn.md`.
    - `docs/tasks/faz_ab/RAPOR_A.md` is written only in step R, after the last K8 commit.
    - Change: add to the "Neden" column of the K rows.

15. **Minor: the K rows have an empty Model column.** Fill in "Sonnet / Haiku / Opus".

16. **Minor: durations.**
    - K8 includes a full `run_gate.sh` (3 runs x 730 weeks, timeout 900 s each) plus `plausibility_run.sh`. Raise it to 1 h 30.
    - Merging K1 gives 3 h instead of 3 h 30.
    - K5 stays 4 h 30, provided A1d measures the wall time first.

17. **Minor: plausibility timing.** K5 changes the Kararlılık reading, which `b2c_floor_*` and `launch_leak` read. So `plausibility_run.sh` runs in K5 as well as K2 and K8 (§4.11 is final in K8).

**Where the PRD conflicts with A_PLAN in a way the executor could get wrong** (all go into A2's execution note, which is given to every Sonnet prompt):
- **(a) `desk_shut`:** the PRD rebuilds it (§4.12). A_PLAN §5.6 K2 and scenario 4 delete it or replace it with `:bugs`. Only `fix_run` is deleted.
- **(b) Reputation floor:** no `max(0, …)`. The `GameState` clamp at −10 applies (`game_state.gd:346-348`).
- **(c) Top account:** shown by name and seat count inside the card. `line_impact` returns `{accounts, seats, top_id, top_seats}`; `top_star` and `{stars}★` are removed. The B and C name tables in A_INCELEME §2 still say `top_star`.
- **(d) Bug placement:** uniform, seeded, one independent pick per bug among the live lines. No "haftanın hattı" and no ×3 weight. The only exception is a faulty-closed card, whose bug lands on its own line.
- **(e) K5 gate:** the "B2B ≤ 12" gate is invalid. The gate is the two measures in §2.11 plus §4.4/§4.5. `USAGE_DIV_B2B` 25 is not a fixed value; it comes from §5/E1 as "onay bekliyor".
- **(f) `fix_all`:** invalid. Four arms with preset key `fix`; `policy` stays the event-answer key.
- **(g) Schema numbers:** A takes 16 and B takes 17. A_PLAN's "D 17" is invalid.
- **(h) K1:** A_PLAN's K1 content is replaced by the Karar 13 matrix.
- **(i) Founder's sprint share:** ORTAK says this calculation is D's. The PRD wins: A sets who is in the sprint and how much; D sets role points.

**Acceptance criteria mapped to gates:**
- §4.1 → K8 (grep with the exceptions; partial check in K3).
- §4.2 and §4.3 → K3.
- §4.4 and §4.5 → K5, then R.
- §4.6:
  - (a) baseline in A1d; unnamed mismatches = 0 in K1, K3, K4 and K5;
  - (b) and (c) → K4.
- §4.7:
  - `save_v15_tickets…` → K3;
  - `save_v15_callback_bugs_under` → K5.
- §4.8 → K5.
- §4.9 and §4.10 → K1.
- §4.11:
  - `event-lint` and `loc` in every K step;
  - plausibility in K2, K5 and K8;
  - `run_gate` in K1 and K8.
- §4.12:
  - sprint plan → K1;
  - fix card with a long name and the release note → K4;
  - line panel B2B/B2C, the long list and `desk_shut` → K6;
  - dim buttons → K7.

**Proposed final table**

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| A0 | §5 araştırması (≥6 oyun; satır başına kaynak + arandı/bulunamadı) | Alt ajan | Sonnet | orta | 25 dk | Akış hedefleri ve Karar 4 buna dayanır |
| A1a–c | Bağlantı haritası, üç paralel okuyucu: (a) sistemler, (b) olay motoru, veri, kayıt, araçlar, (c) arayüz ve belgeler | Alt ajan ×3 | Sonnet | yüksek | 30 dk | **değişti:** §6 ~60 kalem, dört katman |
| A1d | Taban (koddan önce): `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` adlı uyuşmazlık listesi; `full_run` ve `full_run_b2c` 104 hafta, süre ölçümü ve PROBE çıktısı scratchpad'e (ayrı APPDATA) | Alt ajan | Haiku | düşük | 25 dk | **değişti:** K1 ekonomi kayması için tek taban; K5'in JOBS planı |
| A2 | Haritaları birleştir, kodda doğrula, grep süpürmesi, %40 zarı; PRD↔A_PLAN çakışma notu (a–i), her Sonnet istemine eklenir | Alt ajan | Opus | yüksek | 25 dk | **değişti:** yürütücünün A_PLAN'ın geçersiz kısımlarını kodlamasını önler |
| E1 | Erdem durağı: A0 özeti, iki ölçünün hedefi, Karar 4 mekanizması ve yapılabilirlik hesabı, düzeltme payı hedefleri (erken dönem dahil), `fix_due` tanımı | Ana | Opus | orta | Erdem'e bağlı | K1 arka planda başlatıldıktan sonra gönderilir |
| K1 | Görevler matrisi sprinte, kurucu dahil. `team()`: Yapım ve Test, pay `focus_mult`, sprint işlerinin payları toplanır; hafta ortası değişiklik Ekip'in gününde. `_validate_shape` kuralı kalkar. Kurucu etiketi, boş ekip metni (Ekip'e bağ). B2C bot kolu (ikinci iş, `clear_jobs` yok). Smoke: `founder_not_double_counted`, matris vakası (falsifikasyonlu), etkilenen ~20 vaka. Kapı: sprint-probe, `run_gate.sh`, taban karşılaştırması. Yeni fikstür (Destek'teki kişi, sprint boş) ve boş masa ofis karesi; TR/EN/cb/1.25 | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | max / düşük / yüksek | 3 sa | **değişti:** K1a ile K1b birleşti; §4.9 sprint yarısı `team()` olmadan geçmez, A_PLAN K1 kodu K1b'de boşa gider; bir inceleme eksik |
| K2 | Hotfix, düzeltme koşusu, "Kaçırıldı", `bug_pile` (+ `lint_v3_frozen` satırı), `destek.*` fix seam'leri, sinyaller, bot bloğu, `fix_run` çekimi silinir; `desk_shut` yeniden kurulur (silinmez). `--event-vocab`, `gen_signal_manifest.py`, `--event-lint`, plausibility, `--run-log` B2B ve B2C 30 hafta | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 1 sa 50 dk | Olay motoru sözleşmesi |
| K3 | Tek hata deposu; hata eşit olasılıkla ve tohumlu rastgele hatta (haftanın hattı yok), hatalı kart kendi hattına, hat yoksa v1.0'a. B'nin yazma noktaları (`add_bugs`, `line_blocked`, `line_bugs_cleared`). `_migrate_16` 1. kısım, `save_v15_*` (bilet). Hat temizleme ve dağılım vakaları falsifikasyonlu. Seam adı değişir; vocab, manifest, sprint-probe, 30 haftalık koşu. L ve aşınma kalır | aynı | Sonnet / Haiku / Opus | max / düşük / yüksek | 2 sa 45 dk | En büyük dilim, kayıt riski |
| K4 | Düzeltme kartı: efor ve acil eşiği `sprint.json`'da tek ayar (E1'e kadar bugünkü değer), "Acil" adı B ile karışmaz; `uses_axis` ve `USE_AXIS_MIN`; `line_impact {accounts, seats, top_id, top_seats}`; kartı sprinte koyan giriş; sürüm notu "6 → 0"; `sprint_fix_preview_matches_close`; edge: uzun adlı kart ve sürüm notu; `glyph_audit`; görsel | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 1 sa 40 dk | Arayüz ve tahmin eşliği |
| K5 | (E1 sonrası) Etki zinciri (B2B hedef, B2C kitle, haftalık itibar, taban yok, −10); Karar 8 kesimleri; aşınma, L, `_founder_on_build` ailesi silinir; QA metinleri; itibar sebebi yüzeyi; `_migrate_16` 2. kısım (`bugs_under`). Smoke: `neglect_reputation_below_zero`, `bugs_leave_sales_and_vc_alone`. Bot: `fix` kolları, `PROBE FIX`, `fix_off` ayarı (`run()` ve `reset_all_owners` sıfırlar). Tek matris turu (16 koşu, JOBS=4, ağaç donuk), tablo betiği scratchpad'de; plausibility | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 4 sa 30 dk | Kalibrasyon; tutmazsa "onay bekliyor", ikinci tur yok |
| K6 | Hat paneli (tek `bug_row`), alan cümlesi, Sesler kalkar; Destek kartı son hâli "N açık hata ›" ve tıklama; `desk_shut` son hâli; edge: hat paneli B2B/B2C, 1–2 hatalı uzun liste; TR/EN/cb/1.25, sırayla | aynı | Sonnet / Haiku / Opus | max / düşük / yüksek | 2 sa 40 dk | UI kanunu, görsel kabul; E1 gecikirse K5'ten önce |
| K7 | Sönük kart düğmeleri. Önce tema farkı ve iki `.tres` scratchpad'e; `THEME_STAMP`; yalnız üretilen tema ve kendi dosyaları sahnelenir, `project.godot`'a dokunulmaz; `theme_check`, contrast audit, `live:active` ve `live:plan` hover kareleri | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 55 dk | Küçük; sahipsiz fark riski; E1 gecikirse K5'ten önce |
| K8 | Ölü kod, belgeler (HARITA, CLAUDE §6/§8/§12, GUNCELLEMELER, motor md §27, ZAMAN MODELİ, glossary, ACIK_KARARLAR 39/45 + `:446` maddesi, ISLER C-07/INT-9 + VC takip notu); §4.1 grep kapısı; `run_gate.sh` tam, plausibility, lint, loc, glyph | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 1 sa 30 dk | Temizlik ve son kapılar; +10 dk koşu süresi |
| R | `RAPOR_A.md` scratchpad notlarından, son K8 commit'inden sonra yazılır (✅/⚠️/❌, onay bekleyenler, commit listesi, okuma ve yazma noktaları, preset adları ve tablo komutları) | Ana | Opus | orta | 20 dk | B'nin başlama tetiği; erken görünmemeli |

Every K step uses the same flow: Sonnet codes and falsifies → Haiku runs the gates. Haiku runs `--headless --import` if a `class_name` changed, checks with `git diff` that no falsification edit is left, stages only explicit paths and runs windowed jobs one at a time. Then Opus does one review and at most one fix round, and the commit message is `Faz A Kn: …`.

### Critical Files for Implementation
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/scripts/systems/sprint_system.gd
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/scripts/systems/support_system.gd
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/scripts/systems/product_system.gd
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/scripts/debug/run_probe.gd
- C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/scripts/autoload/save_manager.gd
