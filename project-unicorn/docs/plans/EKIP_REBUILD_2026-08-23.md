# EKİP MODULE — REBUILD PLAN TO GDD rev 11

**Date:** 2026-08-23 · **This pass produces a plan. No production code was written.**
**Location:** `project-unicorn/docs/plans/EKIP_REBUILD_2026-08-23.md` · plan approved 2026-08-23; implementation not started
**Authority:** `project-unicorn/GDDs/GDD — EKİP MODÜLÜ vson.docx` — rev 11 · İNŞA SÜRÜMÜ
**Code baseline:** working tree at `b1bdaaa`. No HR file is uncommitted (`git status --short scripts/` lists no `hr_*`, `personal_tab.gd`, `character_registry.gd` or `save_manager.gd`).

---

## Context

The Ekip module was built in four commits between 2026-08-19 and 2026-08-22 (`18d27e3` → `9908a8b` → `fe2e439` → `b1bdaaa`) against **ch.07 rev 2** and an approved mockup set. On 2026-08-23 rev 11 replaced ch.07 outright and overturned several rulings the code was built to obey — most visibly the one recorded verbatim at `hr_constants.gd:126-137`, where the assignment unit was ruled to be the **area**. Rev 11 §12.0 rules it is the **job**, and names five.

Three other classes of work land in the same pass.

**Absent mechanics the GDD requires.** There is no working-hours model of any kind — a repo-wide grep for `work_hours|working_hours|hours_per_day` returns only `TimeManager.HOURS_PER_DAY := 24` (`time_manager.gd:48`). There is no `level` field, no title derivation, no promotion. And **no production output formula reads `Character.morale`**: `_speed_for_phase` (`product_system.gd:540-551`), `_diminished_sum` (`sales_rep_system.gd:70-81`) and `desk_throughput` (`customer_rep_system.gd:83-92`) each build their own multiplier stack and none of them asks. Morale today drives badges, a resignation roll and one modal — nothing economic.

**Dead paths.** An overtime block system the GDD deletes outright; a manual-vacation path retired at the surface and still fully wired underneath; a morale multiplier with exactly one occurrence in the repository, its own declaration; ~15 uncalled functions; a per-area lead seat with no writer.

**Lies.** `HR_OVERLOAD_HINT` (`strings.csv:380`) promises in both shipped languages that overload erodes morale faster, against an engine that has never charged it. 66 comments across 13 files cite a "design doc" that is not in the repository, one of them stamping a constant `ONAYLI`.

The outcome this plan aims at: one ruler, one home per number, the GDD as the only authority, and §15.3's read catalogue published so the event engine has nothing to discover when it arrives.

---

## 0 · Method, and three corrections to the brief

**0.1 — The authority is a `.docx`, not the `.md` the brief names.** `GDDs/GDD_EKIP_rev11_INSA.md` does not exist; `find . -iname "*rev11*" -o -iname "*INSA*"` returns nothing. The only rev-11 document in the tree is `GDDs/GDD — EKİP MODÜLÜ vson.docx` (written 2026-08-23 03:57), line 2: *"Project Unicorn · 23 Ağustos 2026 · rev 11 — İNŞA SÜRÜMÜ"*. Every `§n` below is a section of that file.

**0.2 — The character-migration defect the brief names is already fixed; a second instance of the same bug is not.**
The brief says three migrations read `state["characters"]` while saves are written to `state["registries"]["characters"]`, and instructs me to fix it first. That fix landed 2026-08-21. `SaveManager._rows()` (`save_manager.gd:621-628`) reads `state["registries"][key]` first and falls back to the flat key; **all four** character migrations go through it — `:683`, `:778`, `:820`, `:894`. The bug and its fix are confessed in place at `save_manager.gd:613-619`.

Two residual instances survive, and one of them is inside HR:

- **`_migrate_assignments_to_areas` writes the lead seats to the wrong nesting level.** `save_manager.gd:798` reads top-level `state["job_leads"]`; `:810` writes top-level `state["area_leads"]`. But `GameState` variables are captured and restored under `state["game_state"]` (`save_codec.gd:274-296`, restore `:298-324`, block set at `save_manager.gd:324`). So the v4→v5 lead-seat migration reads a key that is not there and writes one nobody loads. Its smoke case passes because it hand-builds a flat dict (`endgame_smoke.gd:7496-7512`, assertion `:7531`). *This one dies with `area_leads` — see §2.*
- **`_migrate_sector_ids` was never converted.** `save_manager.gd:632-634` reads flat `state["customers"]` / `state["prospects"]` while `capture_registries()` writes both under `registries` (`save_codec.gd:364-365`). v1→v2 is still a silent no-op on any real save. Outside Ekip; see §9b Q3.

**0.3 — The two throwing smoke cases could not be confirmed by static reading.** The *mechanism* is confirmed: all 240 case functions are declared `-> String`, a GDScript runtime error aborts the body and returns `""`, and `""` is the pass sentinel (`endgame_smoke.gd:339-342`). The file documents a past instance and its fix at `endgame_smoke.gd:4381-4387` (*"The case printed SMOKE PASS while proving nothing"*), and a second false-green flavour at `:9361-9365`. Static reading of every bracket read, index and dynamic dispatch in the suite did not isolate two live throwers, and the harness was not executed (read-only pass). **Phase 0 therefore sweeps all 240 ids rather than a shortlist** — the mechanism is global, not local. Command in §7.

---

## 1 · Conformance delta

**OK** = already correct · **CHANGE** = exists, behaves differently · **NEW** = does not exist.

### §0–§1 · Yürürlük, kapsam

| § | Verdict | Now → Must |
|---|---|---|
| §0 deletions | CHANGE | `GDDs/ch07` is `GDD v2 — 07 · Team & Roles (HR).docx` — already removed from the worktree (`git status`: ` D`), still tracked. There is no `05` either. `docs/audits/gdd_conformance/03_ekip.md` is present, 227 lines, baselined at `7687095`, stale in all four headline claims. → §2d. |
| §0 source-file rule | CHANGE | **66** comments in 13 files cite "design doc"; ~114 across 24 files if chapter citations are counted. Every HR file names "GDD v2 ch. 07 rev 2" — a chapter with no file. `hr_constants.gd:1004` stamps `RAISE_MAX_PCT := 15` as `ONAYLI (design doc §12.3)`. → all removed or re-pointed at this GDD. |
| §0.1 ch02 warning | CHANGE | ch02 is a `.docx` and still legislates six skills incl. Pazarlama/Operasyon plus meta Hız. → chapter debt, **flagged only, no `.docx` touched** (§9a R4). |
| §1 two tabs | OK | `hr_tab.gd:156-162` builds the KADRO/GÖREVLER segment; Kişisel is its own tab; Atlas is a modal. |
| §1 module produces no economic outcome | OK | HR pushes nothing; Finance pulls (`hr_system.gd:22-27`, `finance_system.gd:137`, `:143`). |

### §2 · Kurucu

| § | Verdict | Now → Must |
|---|---|---|
| §2 not a labour unit · not in Görevler · not in Kadro | OK | `hr_assignments.gd:28-31` states the ruling and `:37` enforces it; smoke `gorevler_has_no_founder` (`endgame_smoke.gd:9238-9257`). |
| §2 founder has no morale | CHANGE (cosmetic) | `HRMoraleSystem.apply_delta` returns early for non-employees (`hr_morale_system.gd:213-218`), but `game_state.gd:952` still writes `morale = 50` onto him and `character_registry.gd:405` onto the mentor. → stop writing an inert number. |
| §2 no energy bar | OK | Repo-wide grep for `energy`/`enerji` returns zero hits in `scripts/` and `localization/`. Nothing to delete here; the *chapters* that still demand one are flagged, not rewritten (§9a R4). |
| §2 Karizma founder-only | OK | `founder_constants.gd:38`; read by the pitch beats (`pitch_constants.gd:62-65`, `:101`; `pitch_system.gd:247`); employees fail validation if they carry it. |
| §2 founder inherits company hours, no exception, no OT pay, no morale benefit | NEW | No hours model exists at all (§8.1). |
| §2 founder name from onboarding, default "Kurucu" | OK | fallback at `personal_tab.gd:160-163`. |
| §2.1 build pauses with two stated reasons | OK | `product_system.gd:365-378`; smoke `build_pauses_when_all_busy` / `build_resumes_when_one_frees` (`endgame_smoke.gd:9081-9151`). |
| §2.2 single busyness model; pitch_prep half-speed removed | **OK** | Already done. The capacity coupling is retired at `product_system.gd:255` (`if false:   # emekli: pitch_prep_active`), replaced by a binary busy gate at `:336`. The contract is written out at `:253-254`. → only the **stale comment** at `vc_pitch_system.gd:422` (*"capacity coupling (product slows)"*) still claims otherwise. |
| §2.3 seven founder task states, each with an id | NEW — but **derivable today** | No task-state enum, and "Yatırım hazırlığında" exists only as the boolean `pitch_prep_active` (`game_state.gd:108`, written `vc_pitch_system.gd:422`, cleared `:432`/`:498`/`:551`) — a flag, not an id. Every input for all seven states nonetheless already exists, so the state is **computed, never stored** (§15.1's rule, ruled 2026-08-23): HR reads the assignment list, the active build phase, the pitch flag and `status`, and derives. No other module is asked to write anything. |
| §2.4 founder is a full citizen of the HR model | **CHANGE — structural** | Founder skills already live in `founder.role_stats` (`game_state.gd:621`), the same dictionary employees use, and `personal_tab.gd:181`/`:187-189` renders them through the same `StarRating`. **But the rulers differ:** employees are 0–10 (`hr_constants.gd:54`), the founder is 0–5 (`founder_constants.gd:54`, per-skill creation cap 3 at `:53`). With `stars_for` at 2 points/star (`hr_constants.gd:182-185`) the founder's star row is structurally capped at **2.5 of 5** and can never reach the 5.0 §5.3 promises. → one ruler, 0–10. Blast radius §4d; **ruled into this pass** (§9a R1). |
| §2.5 Kişisel content, seven items | CHANGE | Six of seven are drawn: card `personal_tab.gd:135-172`, six areas + Liderlik + Karizma `:181`/`:187-189`, experience bar `:258-278`, EĞİTİME GÖNDER `:284-289`, traits `:193-197`. **Missing: the current-task status line.** The page reads `assigned_jobs` only to pick which experience bar to show (`:293-298`); where the status line belongs it draws a navigation hint instead (`:119`, `PER_ASSIGN_HINT`). → §6c. |
| §2.6 founder traits parked in a neutral glyph | CHANGE | `FounderConstants.TRAITS` (`founder_constants.gd:66-75`) holds eight named, polarity-tagged founder traits and `personal_tab.gd:238-255` draws name + effect text for each. The catalog's own header says the effects are consumed by no system (`founder_constants.gd:64-65`). → keep the ids, neutralise the presentation. |

### §3 · Roller ve seviyeler

| § | Verdict | Now → Must |
|---|---|---|
| §3 six roles | OK | `hr_constants.gd:248-253`, `EMPLOYEE_ROLES` at `:258`. |
| §3 three levels, `level` 0/1/2 | **NEW** | `Character` has no `level`, no `band`, no `seniority` (full field list `character.gd:29-96`). `BAND_JUNIOR/MID/SENIOR` (`hr_constants.gd:634-637`) are **budget tiers**, and the strings say so — "ekonomik / dengeli / üst segment" (`strings.csv:545-547`), confirmed at `hr_constants.gd:638-639`. The band is chosen at search time and **discarded at hire**: `HRSearchSystem.hire()` copies name/role/salary/axes/traits only (`hr_search_system.gd:196-209`); the candidate's `"band"` key (`hr_candidate_generator.gd:123`) never reaches `Character`. |
| §3 title derived, not stored | NEW | `role_label()` (`hr_constants.gd:347-352`) returns the bare role name; no prefix machinery. Every draw site derives it (`hr_ledger.gd:126`, `hr_assignments.gd:89`, `training_modal.gd:101`, `hr_search_system.gd:264`, `:356`). |
| §3 no promotion | **NEW** | Repo-wide grep for `terfi|promot|kıdemli|seviye` returns zero mechanics. |
| §3 terminology: UX/UI Designer · Ürün Yöneticisi · Test Mühendisi | CHANGE | `strings.csv:536` renders `designer` as **"Tasarımcı / Designer"**. `:538` already reads "Test Mühendisi / QA Engineer" ✓. |
| §3.1 EN prefixes (Senior) · EN role names | CHANGE | `strings.csv:540` renders `customer_rep` EN as **"Account Manager"**; §3.1 says **Customer Success Manager**. No prefix table exists. |

### §4 · Yetenek alanları

| § | Verdict | Now → Must |
|---|---|---|
| §4 six areas | OK | `hr_constants.gd:31-37`. |
| §4 Liderlik on everyone; Karizma founder-only | OK | `:41`, `:43-44`; founder set `founder_constants.gd:36-38`. |
| §4 no Hız, no Pazarlama/Operasyon | OK | `RETIRED_SKILL_KEYS` + tripwire `hr_constants.gd:61-66`, `:103-109`, fired at `character_registry.gd:477-479`. |
| §4.1 0–10 raw, 2 points = 1 star, five stars always drawn | OK for employees, CHANGE for founder | `:54`, `:58-59`, `stars_for` `:182-185`. Founder ruler is the exception (§2.4). |
| §4.1 raw only in deep hover | OK | design 1b. |
| §4.1 closed row shows key + secondary + Liderlik | OK | `hr_ui_shared.gd:54-66`. |
| §4.2 Liderlik: **+1% output / −2% morale-drop per half star** | CHANGE | Two coefficient families exist and neither matches. Morale climate: `CLIMATE_DROP_PER_POINT 0.05` with `CLIMATE_DROP_FLOOR 0.50` (`hr_constants.gd:890-891`) — a −50% ceiling where the GDD wants −20%; `CLIMATE_GAIN_PER_POINT 0.05`, cap 1.50 (`:892-893`). Output coordination: `COORD_MIN 0.85` … `COORD_MAX 1.20` (`:895-896`). → one table, the GDD's. |
| §4.2 lead is per-build (Product module); leaderless areas read the founder's Liderlik | CHANGE | **Two unrelated "leads" exist.** The per-area seat `GameState.area_leads` (`game_state.gd:254`) has **exactly one reader** (`hr_system.gd:191`) and **zero production writers** — every other touch is an erase (`game_state.gd:600-608`, `:803`; `character_registry.gd:546`) or the broken migration (`save_manager.gd:810`). The per-build `FeatureBuild.lead_engineer_id` is chosen in the creation flow (`creation_flow.gd:680-695`) and is what `_lead_coordination` actually reads (`product_system.gd:494-506`). → delete the per-area seat; §4.2's model is per-build lead with a founder fallback. |
| §4.2 percentages never on screen | OK | none rendered. |
| §4.3 secondary ×0.8 | CHANGE | `SECONDARY_AREA_MULT := 0.7` (`hr_constants.gd:147`), applied by `area_fatigue_mult` (`:217-225`). There is no 0.8 and no 0.6 anywhere in the module. |
| §4.4 sales/CS roles carry **no** secondary | CHANGE | `ROLE_AREAS` gives `sales_rep` → `customer_success` and `customer_rep` → `sales` (`hr_constants.gd:123-124`). |
| §4.4 product-side four never carry Satış / MI | OK | `can_hold_area` derives from the same table (`:170-179`). |
| §4.5 one canonical formula behind `hr.effective_skill(kişi, alan)` | **NEW** | There are **three** partially-overlapping computations and no shared one: `HRSystem.output_mult_for_area` (`hr_system.gd:235-247` — area coefficient × overload, no skill), `HRSystem.area_sum_for` (`:250-260`), and `ProductSystem._phase_area_sum` (`product_system.gd:509-537` — adds two trait multipliers). Sales and CS stack differently again (`sales_rep_system.gd:70-81`, `customer_rep_system.gd:83-92`). **Morale is in none of them.** |
| §4.5 daily contribution = effective output × that person's hours | NEW | No per-person hours value exists. |
| §4.5 leave/training contribute zero | OK | `HRSystem.assigned_to` filters both (`hr_system.gd:134`). |

### §5 · Deneyim ve eğitim

| § | Verdict | Now → Must |
|---|---|---|
| §5.1 experience is **one bar** | CHANGE | Stored per area: `Character.area_experience: Dictionary` (`character.gd:84`), initialised per area at `character_registry.gd:452-454`, accrued per area in the loop at `hr_system.gd:110-122`. |
| §5.1 threshold grows with total development | CHANGE | `EXPERIENCE_MAX := 100`, flat (`hr_constants.gd:809`), compared at `character_registry.gd:107`. |
| §5.1 learn-by-doing retired; the only exit is training | CHANGE | Learn-by-doing is live and is the **only** route to the fifth star: `add_area_experience` awards `role_stats[area] += 1` on overflow (`character_registry.gd:120-122`), ceiling `AREA_MAX 10`, while paid training stops at 8 (`hr_constants.gd:815-818`). Idle people learn nothing (`hr_system.gd:100-101`) ✓ — that half stays true. |
| §5.2 flow, two weeks, +½ star, bar resets, returns to prior job | OK in the parts that exist | `TRAINING_DAYS := 14` (`hr_constants.gd:813`); the award is +1 point = ½ star (`character_registry.gd:191`, modal states it at `training_modal.gd:192-200`); experience zeroed `:193`. Return-to-prior-job holds because nothing clears `assigned_jobs` on training (`character_registry.gd:194-195`) — but see §12.3. |
| §5.2 employee may train key + secondary + Liderlik; founder all seven | **OK** | Engine `trainable_keys()` returns seven (`hr_constants.gd:840-846`); modal gives the founder seven and an employee three (`training_modal.gd:162-171`, branch at `:163`). rev 11 ratifies **both halves** — the brief asked; both are correct. |
| §5.3 ceiling is 5.0 stars (10/10), buyable | CHANGE | `AREA_TRAIN_CAP := 8` (`:815`), deliberately below `AREA_MAX` — *"para her şeyi satın alamaz"* (`:816-818`). rev 11 removes the split. |
| §5.3 fee tiers by the target area's current star level | CHANGE | `round((500 + 220 × value) × (1 + 0.35 × repeats) × (1.35 if Liderlik))` — `training_fee` `hr_constants.gd:829-837`, constants `:814`, `:821`, `:825-826`. §5.3 prices by star level only. |
| §5.4 two distinct lock reasons, never merged | CHANGE | design 1a draws them; the engine's cap reason is `HR_TRAINING_AT_CAP` (`strings.csv:359`) and the bar reason is *"Deneyim barı dolmadı"*. Both survive; the wording re-points at §5.4. |
| §5.5 modal: area choice, tiered fee, one warning, **derived** duration | CHANGE | `HR_TRAINING_DURATION_WEEKS` is fixed copy read at `training_modal.gd:147` and `:206` with no computed fallback. Retune `TRAINING_DAYS` and the modal lies in both languages. |
| §5.6 full salary during training and leave | OK | payroll deliberately not status-filtered (`character_registry.gd:412-421`, rationale `:414-416`). |
| §5.7 no knowledge-loss penalty | OK | none applied. |

### §6 · Huylar

| § | Verdict | Now → Must |
|---|---|---|
| §6 eight traits, ids and effects | **OK** | `hr_constants.gd:492-533` carries exactly §6's eight, with matching semantics, and **every one has a live production reader**: `loyal`→`:961`, `picks_it_up_fast`→`hr_system.gd:105`, `last_one_out`→`hr_overtime_system.gd:130-131`, `takes_them_under`→`hr_system.gd:119` + `hr_morale_system.gd:414-415`, `double_checker`→`product_system.gd:982`/`:534`, `cant_say_no`→`b2b_event_factory.gd:193-194` + `b2b_sales_system.gd:86-88`, `bag_packed`→`:961` + `product_system.gd:535`, `mood_buster`→`hr_morale_system.gd:172`. |
| §6 one trait per employee | OK | `TRAIT_COUNT := 1` (`:547`), validated `:587-600`. |
| §6 GERÇEK LİDER pays −10 where others pay −5 | OK | `departure_morale_extra: -5` on top of `MORALE_FIRE_TEAM 5` (`:511`, `:770`). |
| §6 İŞKOLİK slows the drop **under long hours** | CHANGE | `overtime_morale_mult: 0.5` is read only by the block system (`hr_overtime_system.gd:130-131`), which §8.2 deletes. → re-point at the §7.1 hour multiplier. |
| §6 TAT KAÇIRAN raises teammates' drop modifier | CHANGE | `dept_morale_decay_mult: 1.25` is gated on the **department** taxonomy (`hr_morale_system.gd:163-172`), which dies with the block system. → re-key to the roster group. |
| §6.1 no green/red split, one badge language | CHANGE at the surface | The engine already retired `polarity` for `carries_cost` and forbids any drawing from reading it (`hr_constants.gd:564-566`). The approved **11b** artboard still colours candidate traits green/red. → GDD wins, §6b. |
| §6.1 28×28 icon, 26×26 cell, 15px glyph, hover name + effect | OK | `hr_ui_shared.gd:146-157`; design 1c. |

### §7 · Moral

| § | Verdict | Now → Must |
|---|---|---|
| §7 four bands with speed effects | **NEW** | Morale has **zero mechanical readers outside HR**. Its complete reader list is the flight-risk counter (`hr_morale_system.gd:136`), the write and clamp (`:222-223`, `:253-254`), badges (`:267`, `:269`), the average (`:291`), the overtime valve (`hr_overtime_system.gd:371`), the raise preview (`hr_actions.gd:80-81`, `:90`) and UI paint. |
| §7 thresholds 80 / 50 / 35 | CHANGE | `MORALE_BURNOUT := 40`, `MORALE_FLIGHT_RISK := 25` (`hr_constants.gd:765-766`), compared at `:875-880`. → Ayrılabilir at 35; the BURNING_OUT band has no counterpart in rev 11 and goes. |
| §7 morale drifts toward a target, never jumps | NEW | `apply_delta` writes immediately (`hr_morale_system.gd:206-225`). |
| §7 morale touches speed only | OK by omission | nothing links it to quality. |
| §7.1 seven-row hour↔multiplier table | NEW | — |
| §7.1 overload ×1.5 | CHANGE | `OVERLOAD_MORALE_MULT := 1.6` — **one occurrence in the repository, its own declaration** (`hr_constants.gd:146`). Confirmed by whole-repo grep; `scaled_delta` (`hr_morale_system.gd:228-254`) never reads `overload_days` or `assigned_jobs.size()`. |
| §7.1 multipliers multiply, never add | NEW | — |
| §7.1 multipliers apply only to base drift; event deltas raw | NEW | There is no base drift — it was deleted, not zeroed, and both files say so (`hr_system.gd:15-21`, `hr_morale_system.gd:21-25`). *(Stale: `time_manager.gd:312-313` still claims HR applies it.)* |
| §7.1 overload sets a floor | NEW | — |
| §7.1 **all modifiers are direction-sensitive** | CHANGE | Approximated by two functions, `climate_drop_mult` / `climate_gain_mult` (`hr_constants.gd:906-913`), applied on opposite branches (`hr_morale_system.gd:247-250`). → one signed scaler. |
| §7.1 every delta scaled in exactly one place | OK | `apply_delta` is the only door (`hr_morale_system.gd:206-225`); eight production call sites, all routed. *(One deliberate bypass for non-employees: `event_manager.gd:586`.)* |
| §7.1 salary fairness is not a morale input | OK | nothing reads relative pay. |
| §7.2 three in-module channels: raise · leave return · short day | CHANGE | Raise ✓ (`hr_actions.gd:109`). Leave return exists at **+10**, not +15 (`hr_constants.gd:768`). Short day does not exist. The three placeholder positive beats (`CALM_STRETCH_*`, `BIG_SIGNING_*`, `SHIP_GLOW_*`, `:1074-1080`, fired `hr_morale_system.gd:176-199`) become event-engine content under §17.3 → deleted here. |

### §8 · Çalışma saatleri

| § | Verdict | Now → Must |
|---|---|---|
| §8.1 three scopes with one resolver | **NEW** | Nothing exists. The overtime unit is the **department** (three of them, `hr_constants.gd:287`), not the roster group and not the person. |
| §8.1 range 5–11, whole hours, default 8 | NEW | — |
| §8.1 start hour, company scope only, 09:00 in 06:00–11:00 | NEW | — |
| §8.1 inheritance rules | NEW | — |
| §8.1 nightfall follows the company window | CHANGE | ODA's light layer is clock-driven; it re-points at `hr.work_hours_company()`. |
| §8.2 **no EK MESAİ button** | CHANGE | The chip is on the **group header**, not the page header (`hr_tab.gd:429-433`, built `:593-605`, `HR_OVERTIME_CHIP` `strings.csv:868`) — the `development` band can never host it (`hr_constants.gd:329` maps it to `""`). All of it goes. |
| §8.2 overtime priced per person, +50% above 8h | CHANGE | `OVERTIME_PAY_PCT := 0.40` of a **daily** wage per participant per night (`hr_constants.gd:1040`, billed `hr_overtime_system.gd:134`). **The 1.5× rule exists only as a comment** (`hr_constants.gd:1038-1039`) — it is pre-baked into 0.40 and there is no 1.5 anywhere in the module. |
| §8.2 hourly wage from monthly salary through one constant | NEW | No such constant. |
| §8.3 short day | NEW | No path exists; the only "less work" states are on-leave, training, idle and the 0.7/0.75 multipliers. |
| §8.4 no separate speed bonus, no quality penalty | CHANGE | `OVERTIME_SPEED_BONUS_EARLY 0.30` / `_LATE 0.15` / `OVERTIME_DIMINISH_DAY 8` (`hr_constants.gd:1034-1036`) consumed by three desks (`product_system.gd:718`, `sales_rep_system.gd:95`, `customer_rep_system.gd:71`); `OVERTIME_BUG_MULT 1.25` (`:1037`) consumed at `product_system.gd:977`. All deleted. |
| §8.5 modal shaped like the roster | NEW backend — **design exists**, canvas turn 19. |
| §8.6 leave and training outside the hours model | NEW | — |

### §9 · Maaş, zam, terfi

| § | Verdict | Now → Must |
|---|---|---|
| §9.1 one monthly salary, never reduced | NEW field | `set_salary` clamps `>= 0` only (`character_registry.gd:560-572`); no floor field. |
| §9.1 salary band table | **CHANGE — large** | `SALARY_BANDS` (`hr_constants.gd:645-652`) is keyed by budget band, not level, and its numbers are roughly **2×** the GDD's: developer junior `[5000,8000]` vs §9.1's `$2,000–3,000`; mid `[8000,12000]` vs `$3,000–6,000`; senior `[12000,18000]` vs `$6,000–10,000`. The **hierarchy also inverts** — today `product_manager` junior `[5500,8500]` sits *above* `developer` `[5000,8000]`, while §9.1 puts Yazılım Mühendisi at the top. → replaced verbatim. Economic consequence in §9b Q4. |
| §9.1 the band table is the single source for hiring, promotion and raise preview | CHANGE | Only hiring reads it (`hr_candidate_generator.gd:244`, `hr_search_system.gd:253`). The raise is a bare percentage multiply, uncapped by any band (`hr_actions.gd:250-251`); promotion does not exist. |
| §9.1 founder not on payroll | OK | `get_total_monthly_salaries()` filters `category == "employee"` (`character_registry.gd:412-421`). |
| §9.1 no living costs | OK | none exist. |
| §9.2 raise 3–10% | CHANGE | `RAISE_MIN_PCT 3` ✓ / `RAISE_MAX_PCT 15` (`hr_constants.gd:1003-1004`), the 15 carrying the phantom `ONAYLI` stamp. |
| §9.2 six-month cooldown | **NEW** | `can_raise` checks only: not blocked, salary > 0, and that the rounded raise is larger (`hr_actions.gd:43-53`). No date field on `Character`, no flag. |
| §9.2 modal reads new salary, morale, payroll, permanence | OK | `hr_actions.gd:84-94`; design 2a. The cooldown lock reason is already drawn in design 1a. |
| §9.3 promotion | **NEW** | Nothing. |
| §9.3 promoted salary does not re-seat to the new band | NEW | — |
| §9.3 no onboarding penalty for external seniors | OK | none exists. |

### §10 · İşe alım

| § | Verdict | Now → Must |
|---|---|---|
| §10 search is **free** | CHANGE | `SEARCH_RETAINER := 600`, non-refundable (`hr_constants.gd:710`, charged `hr_search_system.gd:159`). |
| §10 candidates arrive **one week** later | CHANGE | Engine says 2–4 days (`hr_constants.gd:712-713`); **the UI already says a week** (`hr_atlas_modal.gd:119-121`, `HR_ATLAS_ARRIVAL_SPAN` `strings.csv:344`). A live copy/engine mismatch that rev 11 resolves in the copy's favour. |
| §10 commission **50%** of one month | CHANGE | `SEARCH_COMMISSION_PCT := 0.15` (`:711`, `commission_for` `:753-754`). |
| §10 no interview, no negotiation, three candidates | OK | `CANDIDATE_COUNT := 3` (`:714`). |
| §10.1 ≥6 named candidates per role per level, no repeats in a run | CHANGE | Names are combinatorial (`hr_constants.gd:1127+`) and the generator is deterministic with no RNG (`hr_candidate_generator.gd:31-36`); there is no run-scoped used-name set. |
| §10.2 three fixed archetypes | CHANGE | `BAND_SHAPE` (`hr_constants.gd:677-684`) supplies three skill profiles **per budget band**, cheapest first — a different axis. |
| §10.2 no candidate dominates on every axis | OK | non-dominance invariant `hr_candidate_generator.gd:20-28`. |
| §10.2 ≤1 star spread in the key area | CHANGE | Not enforced; `BAND_SHAPE` senior spans key 7→10, three full stars. |
| §10.2 price spread 20–45% | CHANGE | `SALARY_SPREAD_MAX := 0.15` (`:715`) — below the GDD's floor. |
| §10.2 at least one of the trio carries a cost trait | CHANGE | `TRAIT_COST_SHARE := 0.5` is a per-candidate probability (`:551`), not a trio invariant. |
| §10.2 five-star candidates rare, Kıdemli only, priced at the ceiling | NEW | Today `BAND_SHAPE["senior"][2]` reaches key 10 deterministically. |
| §10.3 candidate card; cost read before the button | OK | design 11b; `hr_atlas_modal.gd:355-386`. |
| §10.4 Atlas role descriptions, binding table | CHANGE | Canvas copy is a placeholder and says so. |
| §10.5 YENİ badge for N days | CHANGE | `NEW_HIRE_BADGE_DAYS := 3` (`:793`), derived correctly from the hire date (`is_new_hire` `:863-867`) but far too short; the design instead says "until first assignment". → date-based, N in §8. |
| §10.6 locked cards = **Pazarlama** and **in-house İK** | CHANGE | The two locked cards are `sales_rep` and `customer_rep`, gated on a B2B product (`hr_constants.gd:432-451`, enforced `hr_search_system.gd:137-139`, drawn `hr_atlas_modal.gd:140-194`). Turn 16 already draws the GDD's pair. → engine follows. |

### §11 · Ayrılmalar, tazminat, izin

| § | Verdict | Now → Must |
|---|---|---|
| §11.1 severance ⅓ / 1 / 2 / 3, capped, completed years | CHANGE | `severance_months = max(1, floor(days/365))` (`hr_constants.gd:1018-1020`) — under one year pays a full month instead of ⅓, and ten years pays ten instead of three. |
| §11.1 resignation pays nothing | OK | `SEVERANCE_ON_RESIGN := 0` (`:957`), explicit at `hr_morale_system.gd:396-398`. |
| §11.2 dismissal modal; cash may go negative, read separately | OK | `preview_fire` exposes `negative_after` so the UI never re-derives the sign (`hr_actions.gd:170-172`); design 2c. Deliberately not affordability-gated (`:136-138`) ✓ matches §11.2. |
| §11.3 departures come from an event | CHANGE | Daily roll: `RESIGN_CHANCE_PER_DAY 0.25` over a 10–14 day flight-risk window (`hr_constants.gd:954`, `:940-941`), rolled in `hr_morale_system.gd:481`. |
| §11.3 **no automatic hand-off to the founder** | CHANGE | `CustomerRepSystem._release_unheld` (`customer_rep_system.gd:106+`, called `:100`) reassigns a departed rep's whole book to the founder, destroying the pin with it (`:110-113`, `:127-128`). §11.3 forbids it by name. |
| §11.4 leave belongs to the employee; no player verb | CHANGE | Retired at the hand (`hr_tab.gd:815-818`, `hr_actions.gd:115-128`), still wired: `send_on_leave(emp, days, is_manual)` (`hr_morale_system.gd:358-380`) keeps the parameter and every production caller passes `false` (`:121`, `main.gd:1703`). |
| §11.4 **two weeks (10 working days)** | CHANGE | `LEAVE_DAYS := 7` (`hr_constants.gd:970`). |
| §11.4 leave falls in **June–August**, distributed | CHANGE | Assigned by **month**, coprime stride over a ten-month span (`leave_month_for` `:979-989`); field is `Character.leave_month` 1–12 (`character.gd:61`). |
| §11.4 request card; defer −5 / +30 days / max 2 | NEW, engine-blocked | Leave is automatic with no player approval (`hr_morale_system.gd:103-121`, rationale `:104`). **There is no deferral mechanism at all** — `leave_taken_year` (`character.gd:63`) is a once-per-year latch, and a missed month is silently skipped to next year. → **R2: stays automatic until the engine lands**, but built to hand over — emits `leave_requested`, accepts an external accept/defer, and carries `leaveDeferrals` from day one. |
| §11.4 return **+15** | CHANGE | `MORALE_LEAVE_RETURN := 10` (`hr_constants.gd:768`). |
| §11.4 returns to the same job | OK | nothing clears the assignment on leave. |

### §12 · Görevler

| § | Verdict | Now → Must |
|---|---|---|
| §12 rows are people, columns are **jobs**, cap two | **CHANGE — structural** | Columns are the six areas plus `research` (`ASSIGNABLE`, `hr_constants.gd:139-140`; matrix header `hr_assignments.gd:59-62`). The ruling that made it so is written out at `hr_constants.gd:126-137`; rev 11 §12.0 is the third ruling on the same sentence and restores the jobs. `assigned_jobs` holds area ids — the experience loop filters them with `HRConstants.AREAS.has(...)` (`hr_system.gd:113`). |
| §12 cap of two, enforced | **NEW** | **No cap for employees anywhere.** `assign_area` appends unconditionally once eligibility passes (`character_registry.gd:229`); its refusals are `unknown`/`unknown_area`/`inactive`/`founder_busy`/`not_your_area` only (`:210-231`). The UI never counts either (`hr_tab.gd:572-590`). Two is the *de facto* max because `can_hold_area` allows only key + secondary — which is a coincidence of eligibility, not a rule, and it dies the moment jobs replace areas. |
| §12.0 five jobs and their carrying areas | NEW | Build ← Ürün·Tasarım·Yazılım · Test ← Test · Destek ← Yazılım·Müşteri İlişkileri · Hesap sahipliği ← Müşteri İlişkileri·Satış · Satış ← Satış. |
| §12.0 **no Araştırma column** | CHANGE | `AREA_RESEARCH` (`hr_constants.gd:138`) says in its own declaration that it has no consumer. It is drawn as a seventh column, is dashed-and-unclickable for **every employee** (no role carries it, `:177-179`), and is clickable only for the founder — who has no row. So the column is unreachable for 100% of rendered rows, and `tick_experience` skips it (`hr_system.gd:113-115`). |
| §12.0 jobs gated by **area only**, never by title | CHANGE | `CustomerRepSystem` gates the desk on `count_active_by_role(ROLE_CUSTOMER_REP) == 0` (`customer_rep_system.gd:191`, sibling `:101`) while every worker lookup reads `HRSystem.assigned_to(AREA_CUSTOMER_SUCCESS)` (`:48`) — and the comment at `:43-46` states the intent is *"rol değil atama"*. With a rep on payroll but off the area: `_open_due_requests` keeps opening requests (`:208`), `_work_the_queue` breaks immediately on zero throughput (`:251-252`), and `_escalate` **returns before clearing the latch** (`:311-313`). Result: one permanently-open request per B2B account, no player-facing signal, and a burst release when anyone is re-seated. `SalesRepSystem` gates correctly, by area (`sales_rep_system.gd:36`). |
| §12.1 focus 1.00 / 0.50, no third job | CHANGE | `OVERLOAD_OUTPUT_MULT := 0.75` gated behind `OVERLOAD_TOLERANCE_DAYS := 5` (`hr_constants.gd:144-145`, gate `hr_system.gd:153-156`). rev 11 removes the tolerance counter and re-seats the coefficient. |
| §12.1 overload morale ×1.5, direction-sensitive | NEW | see §7.1. |
| §12.1 AŞIRI YÜK badge in **DURUM**, no number | CHANGE | Approved 9b draws it next to the name, overlapping the role label. Brief §5 rules this a mockup error. |
| §12.1 hover states **both** costs | CHANGE | `HR_OVERLOAD_HINT` (`strings.csv:380`, shown at `hr_ledger.gd:220` and `hr_assignments.gd:122`) promises morale erosion the engine has never charged. Design 1d's hover omits the split/speed clause. → one true sentence with both. |
| §12.1 third cell locked and visible | NEW | — |
| §12.2 GÖREV cell reads as a sentence | OK | `hr_ledger.gd:236-255`, keys `HR_TASK_ON_VERSION` / `_ON_AREA` / `_NONE` (`strings.csv:335-337`). |
| §12.2 **no empty-job warning line** | CHANGE | Approved turn 14 draws *"Destek: kimse yok."* under the matrix. §12.2 forbids it by name. |
| §12.3 four cell states + legend | OK | `hr_assignments.gd:146-188`, legend `:222-263`. |
| §12.3 **no system may clear a training or leave assignment** | CHANGE | `ProductSystem._reseat_founder` calls `clear_areas` then `assign_area` (`product_system.gd:414-415`); `clear_areas` has no status check (`character_registry.gd:244-252`) while `assign_area` refuses non-active characters (`:221`). **Correction to the brief:** the trigger is a **build**-phase change, not a game-phase change — the four callers are `product_system.gd:854`, `:905`, `:1363`, `:1462`, and `phase_gate_system.gd` contains zero HR references. A second defect in the same function: `:409-410` returns early for `shipped`, so after a ship the founder stays parked on the last build area indefinitely. |
| §12.3 empty page shows one line + İŞE ALIM BAŞLAT | OK | `hr_ledger.gd:177-188`; design 1e. |

### §13 · Kadro

| § | Verdict | Now → Must |
|---|---|---|
| §13.1 four groups, **single** definition | CHANGE | `ROSTER_GROUPS` matches §13.1 exactly (`hr_constants.gd:311-323`) — but **three competing taxonomies exist**: the four roster groups, three `DEPARTMENTS` (`:287`, the overtime unit), and three `SECTIONS` (`:290-292`) which are fully orphaned — no callers, and no `HR_SECTION_*` rows in `strings.csv`, so `section_label()` would return a raw id. |
| §13.1 the same four groups serve the hours scope | NEW | second consumer arrives with §8.1. |
| §13.2 header: counters, chips, hours control, + İŞE ALIM BAŞLAT | CHANGE | Today: title, summary, chips, **EĞİTİM control**, CTA (`hr_tab.gd:129-151`). §13.2's action group has two members, and the hours control does not exist. The EĞİTİM button opens on `eligible[0]` without asking who (`hr_tab.gd:383-390`) — it goes. |
| §13.2 header on both tabs | OK | `hr_tab.gd:109-188` is shared chrome. |
| §13.3 row contents | OK | The eight columns at `hr_ledger.gd:96-156` match §13.3 one for one: ÇALIŞAN · ROLLER·LİDERLİK · GÖREV · DENEYİM · DURUM · TRAIT · MAAŞ · MORAL. |
| §13.3 clicking **anywhere** opens the menu | CHANGE | Four chips are `MOUSE_FILTER_STOP` and swallow the click: `hr_ledger.gd:221` (AŞIRI YÜK), `:227` (BOŞTA), `hr_assignments.gd:123`, `:130` — plus the dashed cell at `hr_assignments.gd:199`. `_pass_clicks_through` exempts any tooltip-carrying child (`hr_ledger.gd:171`). The correct convention is written out one file away and obeyed for the trait icon (`hr_ui_shared.gd:135-142`). |
| §13.3 menu opens on the right, single entry path | OK | `hr_popover.gd:83` right-aligns to the anchor; the single path is enforced and explained at `hr_ledger.gd:44-46`, `:103-104`. |
| §13.3 menu carries four entries | CHANGE | It carries **three** — Zam · Eğitim · İşten çıkar (`hr_tab.gd:695-704`). Two comments still say four (`hr_tab.gd:690`, `hr_ledger.gd:65-67`); the fourth was the retired vacation entry. Terfi is the new fourth. |
| §13.3 DURUM column, seven derived states | CHANGE | Today's precedence is Eğitimde → İzinde → AŞIRI YÜK/BOŞTA → YENİ → worst attention badge → em-dash (`hr_ledger.gd:299-350`), showing **at most one**. §13.3 requires multiple simultaneous badges (§15.1), drops BURNING_OUT, adds the hour-exception label, and moves BOŞTA out to the GÖREV column. The Görevler tab's own DURUM cell has only three states and no leave chip (`hr_assignments.gd:104-132`) — the two must converge. |
| §13.3 no team-size cap | OK | none. |

### §14–§16

| § | Verdict | Now → Must |
|---|---|---|
| §14 shared shell; three record types; arrow belongs to layout | OK | `hr_action_modal.gd:136-223` — `_delta_row` `:175-188`, `_fact_row` `:191-198` (*"OK YOK"* at `:193`), `_rule_row` `:201-223`. Scene `HRActionModal.tscn`. |
| §14 modals never mention production | OK | none do. |
| §15 field list | CHANGE | §4 below. `Character` is 27 exported fields (`character.gd:29-96`) and the codec is a generic property walk (`save_codec.gd:97-106`), so adding a field is free and removing one is a data decision. |
| §15.1 badges derived, never stored | CHANGE | Derivation is correct (`hr_morale_system.gd:262-263`, `hr_system.gd:352-354`) — but a **stored** badge field still exists and is writable: `Character.attention_flag` (`character.gd:96`), written only by event JSON import (`event_manager.gd:632`) and asserted empty by smoke (`endgame_smoke.gd:5069-5070`). §15.1 says no such field exists. |
| §15.2 twelve single-source rules | CHANGE | Known duplicates: `TRAINING_DAYS` vs fixed "iki hafta" copy; `MORALE_MIN/MAX` vs the bare `clampi(value, 0, 100)` at `character_registry.gd:598`; seven id arrays re-typed as string literals immediately below the constants they duplicate; the 1600px breakpoint in three homes (`hr_ledger.gd:34` + `TopBar` + settings prose). |
| §15.3 read catalogue, 18 keys | CHANGE | §5. |
| §15.3 ten signals | CHANGE | §5. Note `EventBus.assignment_changed` is emitted (`character_registry.gd:230`, `:241`, `:252`) and **has no listener** — `hr_tab.gd` force-rebuilds instead (`:578`, `:590`). |
| §16 Turkish canonical, keys carry labels | OK | 235 `HR_*` keys; `loc_residue` gate exists. |
| §16 numbers never hard-coded into copy | CHANGE | `HR_TRAINING_DURATION_WEEKS` (`strings.csv:356`), `HR_OVERTIME_BLOCK_3/7/14` (`:552-554`). |
| §16 one word must not name two conditions | CHANGE | `HR_BADGE_OVERLOADED` = "Overloaded" (`strings.csv:550`, the company-wide `needs_engineer` flag) and `HR_BADGE_OVERLOADED_JOBS` = "OVERLOADED" (`:378`, this person's job count). Both can be true; the per-person one hides the other because `_state_cell` returns at `hr_ledger.gd:328-331` before reaching `:342`. The severity table conflates them under one id (`hr_constants.gd:779`, `:783-787`), so the roster sort does too. Secondary collision the source itself records at `hr_constants.gd:68-70`: `"sales"` is an area id, a department id and a group id, and all three render "Satış / Sales". |

---

## 2 · Deletion list

### 2a · Safe — no production caller

| What | Where |
|---|---|
| `OVERLOAD_MORALE_MULT` | `hr_constants.gd:146` — one occurrence repo-wide |
| `VACATION_DAYS` · `MORALE_VACATION_RETURN` · `REASON_VACATION_RETURN` | `hr_constants.gd:1006`, `:769`, `:742` |
| `is_manual` parameter + its branch + `hr_manual_leave_*` flag family | `hr_morale_system.gd:358`, `:377-379`, `:51`, `:91`, `:374`, `:426`; flag type `game_state.gd:139` |
| `HR_NEWS_ON_HOLIDAY` · `HR_WHENCE_HOLIDAY` | `strings.csv:854`, `:860` — shipped in both languages, unrenderable |
| Dead string rows | `strings.csv:153` `HR_CS_LOAD`, `:381` `HR_ASSIGN_FOUNDER_BUSY`, `:415` `HR_STATE_NEW`, `:422`, `:423`, `:551`, `:556`, `:560`, `:823`, `:824`, `:851`, `:859`, `:893` |
| 24 derived rows whose value never reaches a pixel | `strings.csv:382-393` (`HR_AREA_MEANING_*`, packed at `hr_search_system.gd:270-275`, no reader) and `:809-820` (`HR_FILE_NOTE_*`, quote deliberately not drawn — `hr_atlas_modal.gd:285-287`) |
| Uncalled functions | `hr_constants.gd:381`, `:389`, `:410`, `:565`, `:624`, `:721`, `:729`, `:992`; `hr_system.gd:167`, `:177`; `hr_morale_system.gd:317`; `hr_overtime_system.gd:300`; `hr_search_system.gd:122`; `hr_candidate_generator.gd:375`; `hr_actions.gd:254`; `character_registry.gd:262`, `:272`, `:322`, `:332`, `:345`; `product_system.gd:277` |
| Dead constants | `COORD_MAX_WITH_TRAIT` / `COORD_NATURAL_LEADER_BONUS` (`hr_constants.gd:897-898` — the only caller always passes `false`, `product_system.gd:504`, `:506`); `HRMoraleSystem.RNG_SALT` (`:44`, self-documented as superseded); `HROvertimeSystem.KEY_STARTED_DAY` (`:44`, written `:173`, never read); `HRActions._rule()`'s `pause` parameter (`hr_actions.gd:272-276`) |
| HR event priorities 9 / 10 / 4 | `hr_event_factory.gd:37`, `:52`, `:100` — `enqueue` bypasses `_ordered_by_priority`; they order nothing |
| `CALM_STRETCH_*` · `BIG_SIGNING_*` · `SHIP_GLOW_*` · `POSITIVE_EVENT_COOLDOWN_DAYS` | `hr_constants.gd:1074-1080` and `hr_morale_system.gd:176-199` — §7.2 moves these to the event engine |
| 66 phantom "design doc" comments (~114 with chapter citations) | 13 files, incl. the `ONAYLI` stamp at `hr_constants.gd:1004` |
| Comments contradicting their own bodies | `character.gd:80-83`; `time_manager.gd:312-313` (drift), `:299` ("9 slots" against 13), `:279` and `event_bus.gd:193` ("twelve"), `:385` ("3 hourly" against 4); "seven steps" in `hr_system.gd:38-43`, `hr_morale_system.gd:5-13`, `hr_search_system.gd:6` against a nine-step body; "DÖRT SATIR" at `hr_tab.gd:690` and `hr_ledger.gd:65-67` against three; `character_registry.gd:322`; `vc_pitch_system.gd:422`; `creation_flow.gd:686-687` (cites the retired UYUM axis) |

### 2a-bis · Phase 7 deletions created by the strangler (R8)

These do not exist today — they are scaffolding this rebuild adds and must remove. Listed
now so the last step cannot be forgotten.

| What | Where it will live | Dies when |
|---|---|---|
| **`assigned_to(alan)` job adapter** | `hr_system.gd`, derived from `JOB_AREAS` | the last area-keyed consumer is converted (all 8 sites in §5a) |
| `ASSIGNABLE` + `AREA_RESEARCH` | `hr_constants.gd:138-140` | with the adapter, same commit |
| Old `SALARY_BANDS` (string-keyed) + `BANDS` / `BAND_*` / `band_shape` | `hr_constants.gd` | when the Atlas search and generator read `SALARY_BANDS_BY_LEVEL` |
| `MORALE_BURNOUT` · `BADGE_BURNING_OUT` · `BADGE_OVERLOADED` | `hr_constants.gd` | when the DURUM column is rebuilt (Phase 5a) |
| `EXPERIENCE_MAX` · `EXPERIENCE_PER_DAY` · `EXPERIENCE_PER_BUILD_DAY` | `hr_constants.gd` | when the experience ladder lands (Phase 2c) |
| `AREA_TRAIN_CAP` · old `training_fee` arity | `hr_constants.gd` | when the training modal converts (Phase 5b) |
| `SEARCH_RETAINER` · old arrival min/max | `hr_constants.gd` | when the Atlas flow converts (Phase 5b) |
| `leave_month_for` · `leave_month_label` · `LEAVE_MONTH_*` | `hr_constants.gd` | when summer leave lands (Phase 2c) |
| Overtime block constants + `hr_overtime_system.gd` + `hr_overtime_panel.gd` | as today | when the hours model's consumers convert (Phase 3) |

### 2b · Deletions with callers to repoint

| What | Where | Callers |
|---|---|---|
| Whole overtime block system | `hr_overtime_system.gd` (476 lines); `hr_constants.gd:1030-1053`; `hr_overtime_panel.gd` | `product_system.gd:718`, `:977`; `sales_rep_system.gd:95`; `customer_rep_system.gd:71`; `finance_system.gd:143`; `oda_view.gd:629`; `hr_tab.gd:218`, `:429-433`, `:593-605`, `:640-647`; `game_state.gd:293-298`; the valve event family (`hr_event_factory.gd:47-63`) and `RESIGN_VALVE_PENALTY` (`hr_constants.gd:956`) |
| `AREA_RESEARCH` + its `ASSIGNABLE` entry | `hr_constants.gd:138-140` | matrix column `hr_assignments.gd:59-62`; `tick_experience` skip `hr_system.gd:113-115`; ledger note `hr_ledger.gd:265-267`; smoke `endgame_smoke.gd:7316`; `strings.csv:324` |
| `GameState.area_leads` + `area_lead()` + `release_area_leads()` + the v4→v5 lead block | `game_state.gd:254`, `:600-608`, `:803`; `hr_system.gd:187-206`; `character_registry.gd:546`; `save_manager.gd:798-811` | `hr_system.gd:102`, `:116-119`, `:209-221`; smoke `:7330`, `:7335`, `:7531` |
| `covering_heads()` · `unstaffed_areas()` | `hr_system.gd:167`, `:177` | smoke only (`endgame_smoke.gd:7248-7251`) — replaced by `hr.unstaffed_jobs()` |
| `DEPARTMENTS` · `SECTIONS` · `ROLE_DEPARTMENT` · `ROLE_SECTION` · `GROUP_OVERTIME_HOST` | `hr_constants.gd:283-343` | `product_system.gd:243` (`count_active_in_department`); `hr_morale_system.gd:163-172` (TAT KAÇIRAN scope); `character_registry.gd:332`, `:345` (both uncalled) |
| `needs_engineer` flag + `BADGE_OVERLOADED` | `game_state.gd:90`; `hr_search_system.gd:48`, `:224-228`; `product_system.gd:170-171`, `:1114-1125`; `hr_morale_system.gd:275-278`, `:328-334`; `strings.csv:550` | left-rail badge `hr_system.gd:358-384` → `left_tabs.gd:190`; roster sort `hr_tab.gd:456-460` |
| `SEARCH_RETAINER` | `hr_constants.gd:710` | `hr_search_system.gd:159`; Atlas CTA `hr_atlas_modal.gd:239-240`; warnings `hr_tab.gd:349-356`, `hr_atlas_modal.gd:441-447` |
| `AREA_TRAIN_CAP` | `hr_constants.gd:815` | `character_registry.gd:145`, `:150`, `:191`; `training_modal.gd`; `hr_tab.gd:698-701` lock |
| `right_panel.gd` employee `equity_pct` reader | `right_panel.gd:270-272` | the panel is retired and mounted nowhere (`right_panel.gd:1-9`) |
| `_release_unheld` auto-hand-off | `customer_rep_system.gd:106+`, called `:100` | §11.3 |
| CS role gate | `customer_rep_system.gd:191`, `:101` | replaced by an area gate |
| Missing string `HR_OT_STOP` | referenced `hr_overtime_panel.gd:125`, absent from `strings.csv` | dies with the panel |

### 2c · Deletions that touch save data

| What | Consequence |
|---|---|
| `Character.area_experience` (per-area map, `character.gd:84`) | → scalar `experienceRaw` + `experienceThreshold`; migration takes the max so a nearly-ready employee stays nearly ready |
| `Character.assigned_jobs` holding **area** ids (`character.gd:74`) | → **job** ids; a value migration, not a rename (table §4c) |
| `Character.leave_month` · `leave_until_day` · `leave_taken_year` (`character.gd:61-63`) | → `leaveWeek` + `leaveDeferrals` |
| `Character.overload_days` (`character.gd:75`) | deleted with the tolerance model |
| `Character.overtime_days` (`character.gd:65`) | deleted with the block system |
| `Character.loyalty` · `trust_score` · `equity_pct` · `attention_flag` (`character.gd:90`, `:92`, `:44`, `:96`) | declared reserved, no production readers on employees. **`equity_pct` has a live unit hazard**: `event_manager.gd:616` writes it unscaled and unclamped from event JSON, while `game_state.gd:573-575`, `finance_ozet_view.gd:628-631` and `personal_tab.gd:391` all read it as a 0–1 fraction — an authored `"equity_pct": 5` clamps founder equity to 0% and renders 500% |
| `GameState.area_leads` + the v4→v5 rebuild | `save_manager.gd:798-811` deleted; a migrated legacy save must not resurrect seats |
| `GameState.hr_overtime` · `hr_last_overtime_day` · `hr_last_positive_event_day` (`game_state.gd:293-298`) | `SaveCodec` walks script variables generically, so removing the declarations suffices — but a legacy payload must be tolerated, not crashed on |
| `Character.morale` on founder and mentor | inert writes at `game_state.gd:952`, `character_registry.gd:405` |

### 2d · Document deletions (§0)

| Path | Status | Action |
|---|---|---|
| `GDDs/GDD v2 — 07 · Team & Roles (HR).docx` | removed from the worktree, still tracked | confirm removal; Fable stages it |
| `docs/audits/gdd_conformance/03_ekip.md` | present, 227 lines | delete — named in §0 |
| `docs/audits/skill_system_audit_2026-07-21.md` | present | delete — specifies the retired three-axis employee / five-skill founder model |
| HR "pillars" documents · early spec folders | **not found** | `find` for `*pillar*` returns nothing; nothing to delete |
| `docs/PROJECT_SPEC.md` §4.1–4.3 | present | **not touched** (§9a R4). Recorded because §4 still legislates founder skills on a retired four-axis model (`:233`) and a 1-positive/1-negative trait rule (`:539`), and will contradict rev 11 until someone owns it |
| `docs/CONTENT_GUIDE.md` | **referenced by `CLAUDE.md`, does not exist** | either write it or drop the reference — same class of defect as §0's source-file rule |
| `docs/audits/EKIP_REVERSE_INVENTORY_2026-08-21.md` | present | **keep** — the brief hands it over as a map, and it describes code rather than design. Flagged because a literal reading of §0 catches it |

---

## 3 · New systems

| System | Reads | Writes | Governs | Blocked by |
|---|---|---|---|---|
| **WorkHoursSystem** — three-scope resolver | `companyWorkHours`, `groupWorkHoursOverride{}`, `workHoursOverride`, roster group | — (pure) | §8.1 | roster groups (exist) |
| **Hour economics** — overtime pay, short day, multiplier lookup | `hr.work_hours(kişi)`, `baseSalary` | Finance accrual, morale scaler input | §8.2, §8.3, §7.1 | WorkHoursSystem |
| **JobModel** — five jobs, carrying areas, derived assignability | job table, `ROLE_AREAS` | — (pure) | §12.0, §4.4 | — |
| **EffectiveSkill** — the one output formula | stars, area coef, focus coef, morale band, leadership bonus, trait mult | — (pure) | §4.5 | JobModel + MoraleDrift + §4.2 |
| **MoraleDrift** — base drift, hour multiplier, overload floor, signed scaling, ease-to-target | morale, hours, job count, traits, lead Liderlik | `morale`, `moraleTarget` | §7, §7.1 | WorkHoursSystem |
| **ExperienceLadder** — one bar, growing threshold | `experienceRaw`, total development | `experienceRaw`, `experienceThreshold` | §5.1 | — |
| **PromotionSystem** — one level, title change, 10–25% raise | `level`, `SalaryBand` | `level`, `baseSalary`, `salaryFloor`, `lastPromotionDate`, `employmentHistory` | §9.3 | `level` field |
| **RaiseCooldown** | `lastRaiseDate` | `lastRaiseDate` | §9.2 | — |
| **SeveranceLadder** — ⅓ / 1 / 2 / 3 | `tenureStartDate` | Finance one-off | §11.1 | — |
| **SummerLeave** — week assignment, deferral, return credit | `leaveWeek`, `leaveDeferrals` | `status`, morale | §11.4 | calendar (exists) |
| **CandidateArchetypes** — Uzman / Dengeli / Pazarlık + four invariants | `SalaryBand`, `ROLE_AREAS`, traits | candidate files | §10.2 | `level` field |
| **TitleDerivation** — prefix + role, both languages | `role`, `level` | — (pure) | §3, §3.1 | `level` field |
| **FounderTaskState** — seven ids, **derived** | `assigned_jobs`, active build phase, `pitch_prep_active` (`game_state.gd:108`), `status` | **nothing — computed per draw** | §2.3, §15.1 | JobModel |
| **Read catalogue** — 18 queries + 10 signals | everything above | — | §15.3 | all of the above |

---

## 4 · Data model and save migration

**Target schema version: 7** (current 6, `save_manager.gd:38`).

### 4a · Per-character fields

| §15 field | Today | Action |
|---|---|---|
| `role` | `character.gd:31` | keep |
| `level` | **absent** | add, 0/1/2; derived on migration from the salary band the character sits in |
| `jobTitle` | absent, correctly | keep derived; add prefix machinery |
| `baseSalary` | `monthly_salary` `:43` | rename |
| `salaryFloor` | **absent** | add, init to `baseSalary` |
| `tenureStartDate` | `hire_day` `:60` | rename. Note the deliberate `day + 1` re-stamp at `hr_search_system.gd:221` (rationale `:217-220`) — preserve it |
| `lastRaiseDate` · `lastPromotionDate` | **absent** | add, empty |
| `experienceRaw` | `area_experience` map `:84` | collapse to a scalar — take the max of the per-area values |
| `experienceThreshold` | absent (`EXPERIENCE_MAX 100` flat) | add, computed at migration and on every skill change |
| `assignedJobs[]` | area ids `:74` | remap to job ids (§4c), dedupe, clamp to two |
| `workHoursOverride` | **absent** | add, empty |
| `leaveWeek` · `leaveDeferrals` | `leave_month` `:61` · absent | replace / add |
| `employmentHistory[]` | absent | add, empty, append-only |
| `moraleTarget` | absent | **add** — §7's "drifts toward a target" needs a second number; not in §15's list (§9b Q1) |
| ~~`founderTaskState`~~ | absent | **not a field.** §2.3's seven states are **derived, never stored** (Erdem 2026-08-23) — the same rule §15.1 applies to badges. Every input already exists: build assignment (`assigned_jobs` + `ProductSystem` phase), `pitch_prep_active` (`game_state.gd:108`, written `vc_pitch_system.gd:422`), `status == STATUS_TRAINING` (`hr_constants.gd:802`), and the assignment list for Satış / Destek / Araştırma / Boşta. HR reads them and computes; it does not wait for Product, Sales or Yatırım to write anything |
| dropped | `overload_days` `:75`, `overtime_days` `:65`, `leave_until_day` `:62`, `leave_taken_year` `:63`, `loyalty` `:90`, `trust_score` `:92`, `equity_pct` `:44` (employees), `attention_flag` `:96` | |
| kept as-is | `id`, `character_name`, `category`, `portrait_path`, `traits`, `role_stats`, `status`, `training_days_left`, `training_area`, `trainings_done`, `relationship` (read by `event_modal.gd:254-266`), `morale` (employees) | |

### 4b · Company-level fields

`companyStartHour` (default 9) · `companyWorkHours` (default 8) · `groupWorkHoursOverride{}` (sparse). Three new `GameState` variables. `SaveCodec.game_state_fields()` discovers script variables generically (`save_codec.gd:274-296`) and `SAVE_EXCLUDE_FIELDS` is empty (`game_state.gd:147`), so no codec change is needed.

### 4c · Area → job remap

| Old area id | New job id |
|---|---|
| `product`, `design`, `engineering` | `build` |
| `qa` | `test` |
| `customer_success` | `accounts` |
| `sales` | `sales` |
| `research` | *dropped* |

Collisions are expected (`product` + `engineering` both map to `build`); dedupe, then clamp to two.

**Then validate, and drop rather than repair (Erdem 2026-08-23).** Remapping is not enough, because §4.4 strips two secondaries that exist today — `sales_rep → customer_success` and `customer_rep → sales` (`hr_constants.gd:123-124`). Every remapped job is therefore re-checked against the **new** `ROLE_AREAS` and §4.4's derived assignability table. A job the person can no longer carry is **dropped**, and if that empties the list the person lands on **Boşta**.

- **No silent carry-over.** An assignment that is illegal under rev 11 does not survive because it happened to exist under rev 2.
- **No silent repair.** The migration does not re-seat the person somewhere adjacent, does not pick "the nearest legal job", and does not fall back to `default_area_for_role`. Boşta is a legible, player-fixable state; a quietly invented assignment is not.
- **Every drop is counted.** The done message reports the total and the breakdown by (role, dropped job). A migration that silently changed nothing and a migration that silently changed everything look identical from outside — the count is what separates them.

Worked example: a `customer_rep` assigned to `sales` remaps to the `sales` job, which under §12.0 is carried by the Satış area alone; the role no longer holds Satış, so the job is dropped. A `sales_rep` assigned to `customer_success` remaps to `accounts`, which §12.0 carries by Müşteri İlişkileri **and** Satış — the role holds Satış, so it survives as a primary cell.

### 4d · What happens to a save from the current build

A v6 save loads. `_migrate_v6_to_v7` runs through `_rows(state, "characters")` and: adds the new fields; derives `level` from the band; collapses experience; remaps assignments; converts `leave_month` to a summer `leaveWeek`; **doubles the founder's `role_stats` values** (§2.4's re-seat); and erases `area_leads`, `hr_overtime`, `hr_last_overtime_day`, `hr_last_positive_event_day` **under `state["game_state"]`**, not at top level — the mistake `_migrate_assignments_to_areas` makes at `save_manager.gd:798`/`:810`. Unknown keys are left alone.

**The migration must do the field-filling itself.** Load bypasses `CharacterRegistry.add()` in favour of `insert_raw()` (`save_codec.gd:386` → `character_registry.gd:512-527`), and `add()` is where the semantic defaults live (`:448-457`). A field the migration does not fill restores at its declared default and **stays there forever**; `_validate_shape` only `push_error`s and is explicitly non-blocking (`:471-472`, `:521-522`).

**Falsification test, mandatory.** The new migration case must build its v6 payload **under `registries`** and its GameState keys **under `game_state`** — not the flat shape every existing fixture uses (`endgame_smoke.gd:7496-7512`, `:7546`, `:7599`). That flat shape is precisely why the original bug survived three schema versions (`save_manager.gd:616-618`) and why the lead-seat bug is still alive today.

Also worth fixing while the file is open: `_case_save_roundtrip_fingerprint` seeds with a double `add()` (`endgame_smoke.gd:6468` against `_make_employee`'s own `add()` at `:409`), and asserts only `hire_day` and `run_hires` — never `role_stats`, `assigned_jobs`, `area_experience` or `traits`.

---

## 5 · Seams

### 5a · Query catalogue (§15.3)

| `hr.*` key | Today | Action |
|---|---|---|
| `morale(kişi)` | `Character.morale` read directly | wrap |
| `morale_band(kişi)` | absent | new |
| `headcount()` | `CharacterRegistry.count_employees()` | rename |
| `skill(kişi, alan)` | `c.role_stats[area]`, read at ~20 far sites | wrap |
| `effective_skill(kişi, alan)` | **absent** — three rival computations (§4.5) | new, canonical |
| `status(kişi)` · `is_busy(kişi)` · `is_idle(kişi)` · `job_count(kişi)` · `tenure_days(kişi)` | partial/inline | wrap or new |
| `assigned_to(iş)` | `HRSystem.assigned_to(alan)` — **area-keyed** (`hr_system.gd:128`) | **re-key to job**; 8 call sites: `product_system.gd:460`, `:586`, `:798`, `:981`, `:1015`; `sales_rep_system.gd:36`, `:53`; `customer_rep_system.gd:48` |
| `unstaffed_jobs()` | `unstaffed_areas()` (`hr_system.gd:177`), no production caller | rename + re-key |
| `accounts_of(kişi)` | **absent** — no person → accounts index; `Customer.assigned_to` is the only direction | new |
| `work_hours(kişi)` | **absent** | new. *Brief correction:* `work_hours()` does not exist today, so the signature change it flags has **no callers to break** |
| `work_hours_company()` · `work_hours_overrides()` · `overtime_active(kişi)` · `short_day_active(kişi)` | absent | new |
| `founder_task_state()` *(beyond §15.3's list)* | absent | new — derived, one of §2.3's seven ids; the Kişisel status line's only source |

### 5b · Signals (§15.3)

Exist: `morale_changed` → **`morale_band_changed`** (band edges, which is what §17.3 asks for); `employee_experience_changed` → **`experience_bar_full`** (a distinguishable edge — today the signal is byte-identical for a level-up, a completed training and a capped area); `assignment_changed` ✓ (currently has no listener at all); `character_added`/`character_removed` → **`employee_hired`**/**`employee_departed`**.

New: `employee_eligible_for_promotion`, `raise_requested`, `leave_requested`, `training_started`, `training_completed`.

### 5c · Far-module call sites — converting in this pass

**Yes, all of them, and it is not optional.** Re-keying `assigned_to` from area to job breaks all eight sites above; leaving them ships a build that does not run. The `role_stats` reads convert in the same pass because §4.5 makes their private multiplier stacks illegal — each currently omits the morale band, which is the single largest behavioural change in this rebuild. The heaviest consumer is `product_system.gd` (~30 HR call sites); `customer_rep_system.gd`, `sales_rep_system.gd` and `b2b_sales_system.gd` follow; `sales_system.gd` has **zero** HR reads and is untouched.

One inconsistency to settle while converting: `creation_flow.gd:689` filters SORUMLU candidates by `department_of(role)` while `_phase_crew` (`product_system.gd:460`) filters by assignment. Under §12.0 both become "assigned to the Build job".

`ch06 §1.2`'s rewritten support formula (§17.6) names only Müşteri İlişkileri, while §12.0 says Destek is carried by **Yazılım and** Müşteri İlişkileri — §9b Q2. Interim assumption: sum over both carrying areas.

---

## 6 · UI dependency

Read from the Claude Design project `467a4852-6e13-423a-9e00-805980b1678c`, file `Unicorn Skins.dc.html`. Its palette is the game's own (`ui_tokens.gd:112-155`), so nothing here is a reskin.

### 6a · Designs that exist and are conformant

| Surface | Artboard | Note |
|---|---|---|
| Kadro page | 9b | eight columns match §13.3 one for one |
| Row menu · deep hover · trait badge · status badges · empty states | 1a–1e | 1a already draws §9.2's six-month lock reason |
| Görevler matrix | turn 14 | **five job columns, founder-less** — matches §12.0 |
| Atlas role picker + waiting state | turn 16 | free search, one-week wait, **Pazarlama + İnsan Kaynakları** locked per §10.6 |
| Candidate files | 11b | |
| Training modal | 11c | one screen for employee and founder |
| Zam · Terfi · İşten çıkar | 2a · 2b · 2c | 3–10%, single level with a 10–25% slider, negative-cash as a separate reading — all rev-11 correct |
| Kişisel page | 10a | |
| **Working-hours modal + header chip** | **19a–19d** | Three-scope roster with a KAYNAK column, stepper 5–11, "şirkete dön", "Tümünü şirkete eşitle", the §14 cost block, and a header chip with four states. The brief calls this pending; **it is in the canvas, it matches §8.5, and it is ruled the design** (§9a R3). §8.5's seven per-step hover sentences are added on top of turn 19's chevron indicator |

### 6b · Approved designs that rev 11 overrules — build the GDD, not the pixel

1. **9b · AŞIRI YÜK next to the name.** Named in the brief. Moves to DURUM (§13.3, §12.1).
2. **9b · `EĞİTİM · KİLİTLİ` header button.** §13.2's action group has two members.
3. **turn 14 · "Destek: kimse yok." under the matrix.** §12.2 forbids the empty-job warning by name.
4. **11b · candidate traits coloured green/red.** §6.1: one badge language, one glyph colour — and the engine already forbids any drawing from reading the polarity axis (`hr_constants.gd:564-566`).
5. **11b · commission at 15%.** §10 sets 50% of one month.
6. **turn 16 · level segment labelled "Uzman / Specialist".** §3 and §3.1 seal the middle level as **Orta**, no prefix.
7. **10a · founder traits drawn with names and effects.** §2.6 parks them in a neutral glyph.
8. **9b · role label "TASARIMCI".** §3: **UX/UI Designer**, both languages.
9. **1d · AŞIRI YÜK hover states only the morale cost.** §12.1 requires both costs in one sentence.
10. **§10.4 Atlas role descriptions.** The GDD's table is binding; the canvas copy is a placeholder and says so.
11. **Every salary figure on every artboard.** 9b's roster runs $5,100–5,900/month against a $38,600 payroll, and 19b's burn delta is calibrated to it. Those are the *current* bands, which §9.1 roughly halves. Layout is authoritative; the numbers are not.

### 6c · Surfaces the GDD requires that have no design

| Surface | GDD § | What it must show |
|---|---|---|
| **Founder task-status line** on Kişisel | §2.3, §2.5 | one line, one of seven states — *Bir yapımda çalışıyor · Satışta · Destekte · Araştırmada · Yatırım hazırlığında · Eğitimde · Boşta*. 10a puts a navigation hint where this line belongs (`personal_tab.gd:119`) |
| **Locked third-job cell** | §12.1 | a fifth cell state — visible, unclickable, reason *"En fazla iki iş."* Turn 14 enumerates four states and does not include it |
| **Multi-badge DURUM cell** | §15.1, §13.3 | *"Birden fazla rozet aynı anda görünebilir. Rozetler birbirini bastırmaz."* Every existing artboard shows one chip, and the code shows one by construction (`hr_ledger.gd:299-350`). Two simultaneous badges plus a duration label plus an hour-exception label need a layout ruling |
| **Hour-exception label in DURUM** | §13.3 | `+Ns mesai` / `−Ns kısa`, the quietest item in the column. Not on any artboard |
| **Empty roster group inside the Görevler tab** | §13, §12.3 | 1e covers the Kadro tab; turn 14 covers the zero-employee page; a *group* with no members inside the matrix has no treatment |
| **Founder trait area in neutral glyph** | §2.6 | eight reserved slots, unbound, no names |
| **Promotion lock for a Kıdemli** | §9.3 | 2b shows the menu strip *"En üst seviye"*; confirm that is the final treatment |

Nothing in this list is invented here. Erdem will have them designed.

---

## 7 · Sequencing

**Phase 0 — Gates first. Blocking, no parallelism.**
Sweep all 240 smoke ids (`endgame_smoke.gd:73-336`) with
`tools/smoke_run.sh --all` (built 2026-08-23; the gate now lives in the runner)
and treat any id printing both a `SCRIPT ERROR` line and `SMOKE PASS` as a failure. Then change the runner so a case whose output carries `SCRIPT ERROR` / `Parse Error` / `Compile Error` / `Failed to instantiate` reports FAIL regardless of its return value. Then fix whatever the sweep found. Also verify `--hr-shot=ekip` produces a frame — the visual gate depends on it, and it was reported broken by the ODA centre-viewport rework.

**Phase 1 — Constants and data model, ADDITIVE ONLY (R8).** New names land beside the old
ones: `JOBS`/`JOB_AREAS`/`MAX_JOBS_PER_PERSON`/`FOCUS_MULT_*`, the §7 morale bands, the §7.1
hour table, `SALARY_BANDS_BY_LEVEL` + level/title derivation, the archetype table, the
experience ladder, the summer-leave constants. Value-only re-seats that break no signature
(`SECONDARY_AREA_MULT` 0.7→0.8, `MORALE_FLIGHT_RISK` 25→35, `MORALE_LEAVE_RETURN` 10→15,
`RAISE_MAX_PCT` 15→10, `NEW_HIRE_BADGE_DAYS` 3→14) land here too. **No declaration is
removed and the tree stays green.** Plus `Character` fields, `GameState` company-hours
fields, and the v6→v7 migration with its falsification case. Single-owner, no parallelism.

**Phase 2 — Engine, three parallel tracks.**
- **2a · Jobs + assignment** — JobModel, area→job re-key, the two-job cap on the write side, `assigned_to(iş)`, `unstaffed_jobs()`, the CS area gate.
- **2b · Hours + morale** — WorkHoursSystem, the seven-row table, overtime pay, short day, base drift, signed scaling, overload floor, morale bands.
- **2c · People lifecycle** — experience ladder, training rewrite, promotion, raise cooldown, severance ladder, summer leave, title derivation, candidate archetypes.

*Conflicts to flag, not resolve:* 2a and 2b both touch `hr_system.gd:34-73`; 2b and 2c both touch `hr_morale_system.gd`; all three touch `character_registry.gd` and `hr_constants.gd`.

**Phase 3 — `effective_skill` and the far-module conversion.** Needs 2a (focus), 2b (morale band, hours) and §4.2's coefficients. Touches `product_system.gd`, `sales_rep_system.gd`, `customer_rep_system.gd`, `b2b_sales_system.gd`, `creation_flow.gd`, `game_state.gd`, `skill_check.gd`. Cannot run in parallel with Phase 2.

**Phase 4 — Read catalogue and signals.** Cheap and mechanical. §17.3 says this is Ekip's whole debt to the event engine and it does not wait for the engine.

**Phase 5 — UI, three parallel tracks.**
- **5a · Kadro + Görevler** — `hr_tab.gd`, `hr_ledger.gd`, `hr_assignments.gd`, `hr_ui_shared.gd`
- **5b · Modals** — `hr_action_modal.gd` (+ the new Terfi action), `training_modal.gd`, `hr_atlas_modal.gd`
- **5c · Kişisel** — `personal_tab.gd` + the new status line

**Phase 6 — Working-hours modal** (19a–19d, ruled the design in §9a R3) — after 5a, whose group rendering it reuses. Adds a `--hr-shot=saatler` variant.

**Phase 7 — Deletions, string sweep, visual gate.** Deletions last, so nothing is removed while a caller is mid-conversion. Then `loc_residue` to zero, `--theme-audit` byte-stable, screenshots read against the checklist.

**Smoke rewrite runs alongside, not after.** 66 existing cases assert HR behaviour and most will need rewriting — 23 core (`endgame_smoke.gd:4284-5252`, `:6745-6902`), 7 assignment (`:7216-7489`), 13 Product coupling (`:5345-5694`, `:9081-9182`, `:2020-2328`), 9 Sales/CS coupling (`:5917-6108`, `:2901-2955`), 4 save/migration (`:6517-6581`, `:7490-7595`, `:9191-9231`), 8 UI/retirement guards (`:9238-9421`, `:4070-4266`). Each phase rewrites the cases it invalidates, and every new case is proved by falsification against the pre-change engine before it counts.

---

## 8 · Calibration values

### Adopted verbatim from the GDD
Morale bands 80 / 50 / 35 and their effects +10% / neutral / −15% **[§7]** · the seven-row hour table −1.0 / −0.5 / 0 / 1.0 / 1.1 / 1.3 / 1.5 **[§7.1]** · overload ×1.5 **[§7.1]** · focus 1.00 / 0.50 **[§12.1]** · secondary area ×0.8 **[§4.3]** · leadership +1% output and −2% morale-drop per half star **[§4.2]** · hour range 5–11, default 8, start 09:00 within 06:00–11:00 **[§8.1]** · overtime +50% above 8h **[§8.2]** · training two weeks **[§5.2]** · training ceiling 5.0 stars **[§5.3]** · raise 3–10% with a six-month wait **[§9.2]** · promotion 10–25%, minimum 10% **[§9.3]** · the salary band table **[§9.1]** · severance ⅓/1/2/3 capped **[§11.1]** · commission 50% of one month **[§10]** · one-week search delay **[§10]** · leave two weeks in June–August, defer −5 / +30 days / max 2, return +15 **[§11.4]** · candidate key-area spread ≤1 star, price spread 20–45% **[§10.2]**.

### Chosen here

| # | Constant | Value | Reasoning |
|---|---|---|---|
| C1 | `EXPERIENCE_PER_WORKED_DAY` | **2** | Doubles today's `1` (`hr_constants.gd:810`); the bar must stay visibly alive on a 12 s/day clock. |
| C2 | `EXPERIENCE_BUILD_BONUS` | **+1** | 3/day while a build phase runs — preserves today's build/non-build ratio (`EXPERIENCE_PER_BUILD_DAY 2` vs `1`, `:810-811`) without making non-build work worthless. |
| C3 | `EXPERIENCE_THRESHOLD_BASE` | **40** | with C4. |
| C4 | `EXPERIENCE_THRESHOLD_PER_POINT` | **6** | threshold = 40 + 6 × T, where T = sum of the six areas + Liderlik in raw points. A seeded junior (T≈12) fills in **≈37 working days**; a four-star senior (T≈25) in **≈63**. The 1.7× gap satisfies §5.1's *"belirgin şekilde uzun"* without making a senior untrainable inside a two-year run. Keyed on stats rather than on trainings completed, because a hired five-star has done zero trainings and must still be slow. |
| C5 | `MORALE_BASE_DRIFT_PER_DAY` | **0.25** *(Erdem 2026-08-23)* | 7.5 points a month; 75 → 35 in ≈160 days at 8h. That is what makes the eight-hour day a genuinely *light* pressure rather than a countdown, and it leaves the seven-hour day a real but non-compulsory relief — so the dial stays a tool the player keeps reaching for instead of a setting they park once. Overload at 8h (×1.5) reaches Ayrılabilir in ≈107 days; 11h + overload (×2.25) in ≈72. The earlier 0.5 was justified by that last scenario landing at ≈36 days; 72 is still comfortably inside a run, and 0.5 bought that one reading by making every *unpressured* employee decay twice as fast as the design wants. At 5h the sign flips to +7.5/month. |
| C6 | `MORALE_EASE_PER_DAY` | **3** | §7's *"anında sıçramaz"*. A −15 event lands over five days — the reaction window the section exists to create. |
| C7 | `HOURS_PER_MONTH` | **176** | 22 working days × 8h. One home; the overtime line, the modal preview and Finance's accrual all read it. At any salary this makes three OT hours a day cost ~56% of base pay for +37.5% output — a steep, legible trade. *(The 19b artboard's $412→$521 delta was calibrated against the current salary bands, which §9.1 replaces; it is not a usable cross-check.)* |
| C8 | `TRAINING_FEE_BASE` | **400** | The approved 11c ladder reads $400 / $700 / $1,200 for the first three star buckets. |
| C9 | `TRAINING_FEE_GROWTH` | **1.7** | fee = round(400 × 1.7^floor(points/2)) → 400 · 680 · 1156 · 1965 · 3341. Matches 11c where it shows numbers, and makes the fifth star cost 8× the first — §5.3's *"pahalı"* — without a constant per rung. Replaces `TRAINING_FEE_PER_POINT`, `TRAINING_REPEAT_SURCHARGE` and `TRAINING_LEADERSHIP_MULT` (`hr_constants.gd:821`, `:825-826`), none of which §5.3 authorises. |
| C10 | `NEW_HIRE_BADGE_DAYS` | **14** | Today's `3` (`:793`) is 36 seconds of real time at 1×. Fourteen days survives the one-week Atlas wait plus a settling period. |
| C11 | `MORALE_RAISE_AT_MIN_PCT` / `_MAX_PCT` | **4 / 10** | Anchored at the new 10% ceiling; taken from artboard 2a, which draws 75 → 79 at 3% and 75 → 85 at 10%. Replaces 4/16 (`:771-772`). |
| C12 | `MORALE_PROMOTION_AT_MIN_PCT` / `_MAX_PCT` | **8 / 20** | Linear between 10% and 25%; at 15% this yields +12, which is what artboard 2b draws (59 → 71). |
| C13 | Archetype star profiles | key = **L / L+2 / L+2** for Dengeli / Uzman / Pazarlık, with L = **3 · 5 · 7** raw by level; secondary = **L−1 / L−3 / L−4** (floor 0); Liderlik **1 / 2 / 3** by level ±1 | Uses the full 1-star spread §10.2 allows without exceeding it. Dengeli is never best in the key area and never broken anywhere — which is what makes it the most expensive file. Replaces `BAND_SHAPE` (`hr_constants.gd:677-684`), whose senior tier spans key 7→10, three full stars. |
| C14 | `SALARY_SPREAD_MIN` / `_MAX` | **0.20 / 0.45** | §10.2's band, replacing `SALARY_SPREAD_MAX 0.15` (`:715`) which sits below the GDD's floor. |
| C15 | `FIVE_STAR_CHANCE` | **0.08**, Kıdemli only | Roughly one in twelve senior searches — rare enough to be an event, common enough that a two-year run sees one or two. Ask pinned to the band ceiling. Today `BAND_SHAPE["senior"][2]` reaches 10 deterministically. |
| C16 | `LEAVE_WINDOW_WEEKS` / stride | 13 weeks across June–August, stride **5** | 5 is coprime with 13, so thirteen consecutive hires land on thirteen distinct weeks. The same reasoning as today's month stride (`hr_constants.gd:972-976`), re-based on weeks. |
| C17 | `MORALE_HIRE_START` | **75** (unchanged, `:767`) | keeps a new hire visibly above the neutral band. |
| C18 | Founder ruler re-seat | onboarding values **×2** on write, **plus a per-reader compensation table produced before any value moves** | Neutrality is a claim to be **proved, not asserted** (Erdem 2026-08-23). See C18a. |

### C18a · The founder-reader audit — a gate, not a note

Before a single founder value is doubled, every reader of a founder skill is enumerated and classified **linear · threshold · other**, and the done message states, one by one, how each was preserved. The earlier draft asserted "exactly balance-neutral" from two constants; two counter-examples were already visible in the evidence, which is the whole reason this is a gate:

| Reader | file:line | Class | Preservation |
|---|---|---|---|
| `SkillCheck.chance_for` / `breakdown` | `skill_check.gd:34`, `:46` | **linear** | `SKILL_STEP` 0.15 → **0.075** |
| `SkillCheck.SALES_READ_THRESHOLD` | `skill_check.gd:20` | **threshold** | 2 → **4** |
| `ProductSystem._founder_build_area` → `_speed_for_phase` | `product_system.gd:788-791`, `:540-551` | **linear** | `FOUNDER_SPEED_COEF` 1.0 → **0.5**. *The original C18 missed this: doubling the founder's raw skill would have doubled his build contribution outright.* |
| `HRConstants.experience_gain_mult` (founder as fallback climate lead) | `hr_constants.gd:188-193`, called `hr_system.gd:102` via `:209-221` | **other** — already divides by `AREA_MAX 10` | **Not neutral, and correctly so.** Today a 0–5 founder reads at half the intended range; after the re-seat it reads at full range. Declare the change rather than compensate it. |
| `HRConstants.climate_drop_mult` / `climate_gain_mult` | `:906-913`, read from the founder at `hr_morale_system.gd:240` | **linear** | Moot — §4.2 replaces both with the GDD's per-half-star table, which is authored against the 0–10 ruler. State it anyway so the list is complete. |
| `HRConstants.coordination_for_founder` | `:923-932`, called `product_system.gd:504-506` | **linear** | Replaced by §4.2's output coefficient; re-anchor against 0–10. |
| Pitch beats — `BEAT1/3/4_PUSH_SKILL`, `ANGLE_SKILL`, `LEVER_SKILL` | `pitch_constants.gd:62-65`, `:101`; `pitch_system.gd:247` | **linear via `SkillCheck`** | Covered by `SKILL_STEP`, **but each must be confirmed to route through `chance_for`** rather than reading `get_founder_skill` and doing its own arithmetic. |
| `GameState.get_founder_skill` direct callers | `product_system.gd:791`, `personal_tab.gd:181`, `:187-189` | **presentation / linear** | `personal_tab` becomes correct by construction (the star row stops being capped at 2.5). |
| `FounderConstants.SKILL_CEILING`, `ONBOARDING_CAP`, `POINT_POOL` | `founder_constants.gd:52-54` | **bounds** | `SKILL_CEILING` 5 → **10**. `ONBOARDING_CAP 3` and `POINT_POOL 6` are **untouched** — §2.6 and §17.1 park onboarding; the doubling happens on write, not in the allocation UI. |

The audit is run against the tree, not against this table — this table is what it found so far, and anything it adds is treated the same way.

---

## 9 · Rulings, risks and open questions

### 9a · Rulings taken 2026-08-23 (Erdem)

**R1 — The founder ruler is re-seated in this pass.** §2.4 + §4.1 + §5.3 force the founder onto the shared 0–10 ruler; today he is 0–5 (`founder_constants.gd:53-54`) with his star row capped at 2.5 of 5 (`personal_tab.gd:181` against `hr_constants.gd:182-185`). C18 carries it, **gated on the C18a reader audit**: every reader of a founder skill is enumerated and classified linear / threshold / other *before* a value moves, and the done message states per reader how it was preserved. Neutrality is proved, not asserted — the audit has already caught one reader the two-constant version would have broken (`FOUNDER_SPEED_COEF`, which must halve or the founder's build contribution doubles) and one that is deliberately *not* neutral (`experience_gain_mult`, which today reads the founder at half its intended range). Lands in Phase 1 (storage + migration) and Phase 3 (readers). The onboarding pool and per-skill cap are **not** touched — §2.6 and §17.1 park those.

**R2 — Leave and departures both stay automatic until the event engine lands.** Leave fires on its summer week with no card; departures keep a daily roll. §7.2's warning against a one-directional morale counter is the reason. Both are built so the engine can take them over without a rewrite: the leave state machine emits `leave_requested` and accepts an external accept/defer, and the departure path emits `employee_departed` — the cards are the engine's job (§17.3), the mechanics are ours.

**R3 — Canvas turn 19 (19a–19d) is the working-hours modal design.** Phase 6 builds against it and may start as soon as the roster page (5a) lands. Its KAYNAK column and the four-state header chip are additive to §8.5 and are kept; §8.5's seven per-step hover sentences are added on top of 19's chevron indicator, since §8.5 names them explicitly.

**R8 — Nothing is deleted before its last caller is gone (Erdem 2026-08-23).** The first
build attempt removed `ASSIGNABLE` and `AREA_RESEARCH` in Phase 1 and took 25+ files out of
compilation in one move — a big bang with no green step between start and finish. This plan
already put the deletions in Phase 7; Phase 1 violated its own sequencing. The corrected
shape is a strangler:

1. `JOBS`, `JOB_AREAS` and the JobModel land **beside** `ASSIGNABLE`. Nothing is removed.
2. `hr.assigned_to(iş)` arrives as a new function. The existing `assigned_to(alan)` survives
   as a **thin adapter** derived from the job → carrying-areas table, so all 25 consumers
   keep compiling and keep behaving.
3. Consumers convert **one at a time**. Each conversion is its own green step and the suite
   runs after it.
4. When the last consumer is converted, `ASSIGNABLE` and the adapter die **together** in
   Phase 7, at which point both have zero callers.

The same rule governs every other Phase 1 deletion the first attempt made: the overtime
block constants, `MORALE_BURNOUT`, `BADGE_BURNING_OUT`, `BADGE_OVERLOADED`, `EXPERIENCE_MAX`,
`AREA_TRAIN_CAP`, `SEARCH_RETAINER`, `LEAVE_DAYS`'s month model and the old `SALARY_BANDS`
shape all keep their declarations through Phase 1 and lose them in Phase 7.

The save migration (§4c) is **unaffected** and stays in Phase 1 — the save format does not
go through the adapter.

**The adapter is this pass's debt, not a permanent one.** It is on the Phase 7 list by name
so it cannot be forgotten.

**R4 — Chapter and spec debt is flagged, not fixed.** §17.6's orders against ch01 §5, ch02 §2/§6/§10, ch06 §1.2 and ch12 §8 — and `docs/PROJECT_SPEC.md` §4.1–4.3 (`:233`, `:539`) — are outside this task. The plan lists the exact edits each needs; no `.docx` is touched. The two Ekip-owned document deletions in §2d still happen.

**R5 — The migration drops invalid assignments; it never carries or repairs them silently.** §4.4 strips two secondaries that exist today, so remapping alone would smuggle illegal assignments across the version boundary. Every remapped job is re-validated against the new `ROLE_AREAS`; anything the role can no longer carry is dropped, and an emptied list means **Boşta**. No nearest-legal-job fallback, no `default_area_for_role` rescue. Every drop is counted and the breakdown appears in the done message — see §4c.

**R6 — The founder's task state is derived, never stored.** All seven of §2.3's states are computable from state that exists today: the assignment list, the active build phase, `pitch_prep_active` (`game_state.gd:108`) and `status`. HR reads and computes; it does not add a field and does not wait for Product, Sales or Yatırım to write one. This is §15.1's badge rule applied to the founder.

**R7 — `MORALE_BASE_DRIFT_PER_DAY` is 0.25, not 0.5.** 7.5 points a month; 75 → 35 in ≈160 days at eight hours. The eight-hour day has to read as light pressure rather than a countdown, and the seven-hour day has to stay a real but optional relief — otherwise the dial becomes a setting the player parks once instead of a tool they keep reaching for. Full reasoning and the overload cross-checks in C5.

### 9b · Open questions

**Q1 — `moraleTarget` is a field §15 does not list.** §7 says morale *"hedefe doğru sürüklenir, anında sıçramaz"*, which needs a second number per person. §15's list does not carry one, and §15 says it is the list of fields that must exist today. Adding `moraleTarget` is the minimal reading; a pending-delta accumulator needs the same storage under a worse name. Confirm the addition.

**Q2 — ch06's rewritten support formula is under-specified.** §17.6 rewrites it as `kapasite = throughput × Σ hr.effective_skill(kişi, Müşteri İlişkileri)`. But §12.0 says Destek is carried by **Yazılım and** Müşteri İlişkileri, and §4.4 says a developer works Destek through Yazılım. Does the sum run over both areas per assigned person, or CS only — which would make a developer on the support desk produce nothing? *(Under R4 the chapter is not rewritten here, but the engine still has to pick one.)* Interim assumption if unanswered: **sum over both carrying areas**, because §4.4 states the developer-on-Destek case as a design intent by name.

**Q3 — Two out-of-module defects found while verifying the brief's claim.** (a) `_migrate_sector_ids` still reads the flat path (`save_manager.gd:632-634`), so v1→v2 is a silent no-op on real saves. (b) `event_manager.gd:616` writes `equity_pct` from event JSON unscaled and unclamped while three surfaces read it as a 0–1 fraction. Fix both while the files are open, or leave them for their owners?

**Q4 — Heads-up, not a question: the salary table roughly halves payroll.** §9.1's bands are ~40–60% of the current ones (developer mid `$3,000–6,000` against today's `[8000,12000]`, `hr_constants.gd:645-652`), and the role hierarchy inverts — today `product_manager` outranks `developer` at the junior tier. Combined with the deleted `SEARCH_RETAINER` and a commission rising from 15% to 50%, hiring gets cheaper to sustain and more expensive to do, and runway lengthens materially. The GDD is explicit, so this plan implements it verbatim. Flagged because §4 puts balance tuning out of scope and this will show up in the day-730 probe.

### Risks

- **The area→job re-key is the highest-risk change here.** It touches the save format, eight far-module call sites, the matrix, the experience loop and seven smoke cases at once. Mitigation: Phase 1 lands the job table and the migration *before* any consumer moves, and the migration's falsification case is written first.
- **Morale gaining teeth changes every played run.** After Phase 3 a −15% band applies where nothing applied before, and a base drift exists that did not. The demo's pacing will move. This is what the GDD asks for; it is not a regression and should not be tuned away in this pass.
- **The smoke suite cannot be trusted until Phase 0.** Do not read a green run as evidence about this module before the PASS-on-throw gate is closed. And note the structural blind spot the suite has today: every fixture goes through `CharacterRegistry.add()`, which auto-assigns the default area (`:448-451`), so "holds the role but is not assigned to the area" — the exact state that produces the CS backlog — is untestable as written.
- **235 `HR_*` string keys** are in scope for renames and re-copy, both languages in the same change, `loc_residue` at zero.
- **`--hr-shot` may not produce a frame.** It exists (`main.gd:196-198`, `:707-711`, `:1421-1613`, variants `ekip|atlas|dosyalar|zam|mesai`) but was reported broken by the ODA centre-viewport rework. The visual gate depends on it — a Phase 0 blocker, not a Phase 7 discovery. A `saatler` variant is added in Phase 6.

---

## 10 · Teaching mode

**1 · A named constant is not a mechanic.** `OVERLOAD_MORALE_MULT := 1.6` sat at `hr_constants.gd:146` for weeks, was quoted in a sibling audit as a live morale sink, and had exactly one occurrence in the repository — its own declaration — while shipped copy in two languages promised the cost. The discipline this teaches is to grep the constant, not read the comment. The alternative — trusting a declaration and its neighbours — is how a documented mechanic ships as a lie.

**2 · Dispatch order is design, and it is invisible from both ends.** HR runs at daily slot 3 and sales at slot 4 (`time_manager.gd:258-259`), so a morale beat asking *"was an account signed today?"* can never see one. No line is wrong; the sequence is the bug. Godot's tick model offers no dependency graph — only the order you wrote. rev 11's answer is not to reorder but to remove the dependency: morale now recovers from things HR itself owns. When one system must observe another's *edge*, prefer a signal or a per-edge latch over a slot position, because a slot position is a fact neither end can see.

**3 · One ruler, or two systems drift apart in silence.** Employees run 0–10, the founder runs 0–5, and both render through the same `stars_for` at two points per star. Nothing errors. The founder's star row is simply capped at half the bar, and the Kişisel page has been quietly promising a ceiling the player can never reach. That is the cost of two homes for one measurement — §15.2's whole subject. The fix (double the stored values, halve the step constant that reads them) is trivial today and grows more expensive with every new reader.

**4 · A test that cannot fail is worse than no test.** A GDScript runtime error inside a `-> String` function aborts the body and returns `""`, and `""` is the smoke suite's pass sentinel (`endgame_smoke.gd:339`). The suite documents one case this happened to and fixed (`:4381-4387`). The architectural lesson is about sentinel choice: absence of a signal must never mean success. Had the sentinel been a token the case must set, an aborted body would have produced "unknown" rather than "pass". GDScript offers no try/catch, so watching the output stream for `SCRIPT ERROR` is the available equivalent — and it must live in the runner, not in each case.

**5 · A migration must read the shape the writer writes.** Character migrations spent three schema versions reading `state["characters"]` while saves were written to `state["registries"]["characters"]`. Two smoke cases covered them and both passed, because both called the migration directly with a hand-built flat dictionary: the tests asserted the function's logic and never its *address*. The lesson has a sharp edge, because the same defect is still live twice — once for sector ids (`save_manager.gd:632-634`) and once for the lead seats, which read and write top-level `state` while GameState lives under `state["game_state"]` (`:798`, `:810`). Any migration case worth writing is fed a payload produced by the real writer.

---

## Verification

1. **Phase 0 gate.** Sweep all 240 smoke ids for `SCRIPT ERROR` + `SMOKE PASS` co-occurrence; change the runner to fail on the error tokens; fix what the sweep found; re-run green.
2. **Falsification per new case.** Every new case must be shown to FAIL against the pre-change engine before it is accepted. Case count is derived from the source, never remembered.
3. **Migration.** A v6 payload built under `registries` (characters) and `game_state` (GameState keys) loads, and the case asserts: `level` derived, experience collapsed to a scalar, assignments re-keyed to job ids and clamped to two, `leaveWeek` inside June–August, `area_leads` gone, founder `role_stats` doubled, and no field left at its declared default that the migration was supposed to fill.
3b. **Migration — the drop path.** A separate case seeds a `customer_rep` on the `sales` area and a `sales_rep` on `customer_success`, migrates, and asserts the first lands on **Boşta** with its job dropped and the second keeps `accounts`. It also asserts the drop **count** is reported, not just the state — a silent no-op and a silent rewrite are indistinguishable without it.
3c. **Founder-reader audit.** The C18a table is regenerated from the tree and every row carries its class and its preservation. Two probability spot-checks pin it: `chance_for` on a pre-migration founder and a post-migration founder return the same number, and `_speed_for_phase` returns the same build speed.
4. **Formula.** One case pins `hr.effective_skill` against a hand-computed value across all five multipliers, including a morale band below 50 and a two-job focus split.
5. **Hours.** One case walks the three-scope resolver — company 8 → group 10 → person 6, then "equalise all" — asserting `work_hours(kişi)` at each step and that a personal override survives a group change.
6. **The CS regression.** A case that puts a Müşteri Temsilcisi on payroll and off the `accounts` job, runs 60 days, and asserts the request queue does not accumulate. This is the state today's suite structurally cannot reach.
7. **Runtime.** `--hr-shot=ekip|atlas|dosyalar|zam|saatler` read against the acceptance checklist: nothing crossing its painted bounds, hover as edge glow never a filled rectangle, nothing clipped at a screen edge, no panel larger than twice its content. Iterate until it passes.
8. **Language.** `loc_residue` at zero, `loc_csv_integrity` green, both languages in the same change.
9. **Theme.** `--theme-audit` byte-stable against the pre-change baseline, or the delta explained line by line.
10. **Full run.** `--run-probe` to day 730 completes without a stall, and the run ledger is compared against the pre-change baseline so the morale and salary changes are *measured* rather than assumed.
