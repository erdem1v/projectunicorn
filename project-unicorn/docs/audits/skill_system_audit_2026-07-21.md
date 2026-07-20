# Skill System Audit — 2026-07-21

Read-only inventory, prerequisite for the HR Core spec (employee 3-axis skills UZMANLIK/HIZ/UYUM
alongside the founder's strategic 5-skill set). Ground-truth map of everything the skill machinery
touches today, so (a) founder↔employee bridge multipliers are written on facts and (b) the Character
data migration doesn't break existing readers. **Zero changes were made.** Every entry: what —
`file:line` — who reads/writes — formula/effect. Paths relative to `project-unicorn/`. Flags:
`[INLINE]` = literal outside a constants block · `[DIVERGENCE]` = same concept in 2+ homes ·
`[RESERVED]` = declared, zero consumers · `[DRIFT]` = moved/changed since the calibration audit
(docs/audits/calibration_values_2026-07-17.md §8, the baseline this audit re-verifies).

**Tree state at audit time (uncommitted changesets present, audited LIVE):**
1. **Product Tab Rev3 efor/hız package** — product_system.gd / quality_model.gd / product_catalog.gd /
   feature_build.gd modified; untracked `scripts/tabs/product/` split (creation_flow, pricing_panel, …);
   product_tab.gd + BuildHUDPanel modified. This changeset is the source of most §1 drift.
2. **Ending Screen "Ekonomi Postası" + Run Ledger** — untracked EndingScene.tscn / ending_scene.gd /
   endings_copy.gd / assets/endings/; EndingModal.tscn + ending_modal.gd deleted; endings_system.gd +
   game_state.gd (run_* counters, get_run_ledger) modified.
3. **B2B pitch → MeetingScene migration** — untracked b2b_pitch_meeting.gd (view-adapter);
   PitchDialogueModal.tscn + pitch_dialogue_modal.gd deleted; pitch_system.gd / sales_tab.gd modified.
4. Editorial/localization touches (3 reactive-event JSONs, strings.csv/.translations, ENDGAME_DESIGN.md)
   + untracked calibration audit, triangle_radar.gd, lock.svg. None of these carry skill logic.
5. Mid-audit, a CONCURRENT session (calibration-constants centralization sweep) dropped untracked
   `scripts/debug/fmt_probe.gd` (+.uid) into the tree — a formatter byte-diff probe, no skill logic;
   not part of this audit's writes.

---

## §1 Founder skill read points (complete map)

### The read seam and the check grammar

- **`GameState.get_founder_skill(skill_name)`** — scripts/autoload/game_state.gd:237-247 — THE single
  accessor; reads `founder.role_stats.get(skill_name, 0)` (:247) off the registry founder (:244).
  Unknown key silently returns 0; the OLD_SKILLS tripwire (:242-243) push_errors on renamed keys
  markets/charisma/politics (FounderConstants.OLD_SKILLS — scripts/systems/founder_constants.gd:20).
- SkillCheck grammar — scripts/systems/skill_check.gd — `chance = clamp(0.45 + skill×0.15 + bonus×0.10
  − difficulty×0.15, 0.05, 0.95)`: consts :14-19, `chance_for` :23-27, `breakdown` :33-45 (term-sheet
  odds-split UI), `roll_against` :51-57 (externally-composed odds; honors `debug_skill_force`),
  `resolve` :60-82 (band grammar :85-96: crit_success ≥+0.40 · success ≥+0.15 · near_pass · near_miss ·
  fail ≤−0.15 · crit_fail ≤−0.40). Every mechanical skill read below flows through one of these or a
  direct `get_founder_skill` compare.
- `SALES_READ_THRESHOLD = 2` — skill_check.gd:20; `can_read_prospect()` :99-101 — the one threshold-gate
  read (sales ≥ 2), not a roll.
- Skill display labels: FounderConstants.SKILL_LABEL_KEYS — founder_constants.gd:89-93, `skill_label`
  :111-114 (CSV/TranslationServer); delegate `PitchConstants.skill_label` — scripts/systems/pitch_constants.gd:117-118;
  consumed by the term-sheet odds split (scripts/systems/term_sheet_table_system.gd:162).

### tech — 3 live formula families (all product) **[DRIFT: one removed, one added since 2026-07-17]**

1. **Team/build speed (Rev3 efor/hız — NEW since the calibration audit).** Build duration is now
   `total_efor / (team_speed × capacity_factor)`, and founder tech is the speed's core term:
   - `_tech_of(member_id)` — scripts/systems/product_system.gd:161-170 — ""/"founder"/founder-id →
     `get_founder_skill("tech")` (:164-166); unknown id falls back to founder tech (:167-169); employee →
     `role_stats.get("tech", ENGINEER_DEFAULT_TECH)` (:170; default 2 — :30, 0-5 scale).
   - `_speed_for_lead(lead_id)` — :173-186 — `speed = SPEED_LEAD_WEIGHT(1.0 — :27) × tech(lead)` (:180)
     `+ SPEED_ASSIST_WEIGHT(0.5 — :28) × founder tech` when the founder isn't lead (:181-182)
     `+ 0.5 × tech(each other Engineer)` (:183-185), floored at `SPEED_MIN = 1.0` (:29, :186).
   - Consumers: `team_speed` :189-192 → hourly efor spend `team_speed × f / 24` (:262-263);
     `estimated_days_remaining` :199-204 (in-tab tracker + HUD "~N gün");
     `estimate_build_days` :207-214 (pre-commit projection); `apply_speed_bonus` day→efor conversion
     for delay_days event modifiers (:732-740).
   - Modifier size: at cap-3 founder solo, speed 3 efor/day vs tech-0 solo speed 1 (SPEED_MIN floor) —
     a 3× build-duration swing; each engineer adds +0.5×tech(default 2)=+1.0.
2. **Dev-phase bug accrual (reducer).** `_accrue_bugs_hourly` — product_system.gd:326-336 — founder tech
   read :330; `rate/hour = max(BUG_FLOOR 0.010, Σcomplexity × 0.006 − tech × 0.005)` :331 (consts
   :54-56). **Founder-only read — runs even when an employee engineer is lead** (no lead-tech term).
3. **Post-ship wear (reducer).** `_post_ship_wear_hourly` — product_system.gd:354-369 — founder tech read
   :360; `rate/hour = max(WEAR_FLOOR 0.002, audience × 0.00004 + complexity × 0.0012 − tech × 0.005)`
   :361 (consts :83-86). Founder-only; engineers contribute nothing to wear reduction.

**[DRIFT — REMOVED]** The calibration audit's first tech formula — dev stability growth
`raw = 1.5 + tech × 0.75/day` (old product_system.gd:276-277, TECH_STAB_COEF) — **no longer exists**.
Rev3 made the quality axes deterministic: stamped at commit from feature `dimension_contribution`
sums (`projected_axes` — product_system.gd:449-467; start_build :600-603; start_version_build :690-698),
constant through the build except event `dimension_delta`. No phase-growth constants remain (per-day
ITER_/DEV_ consts deleted; `PHASE1_AXIS_ASYMPTOTE` deleted — scripts/systems/quality_model.gd:47-48).
Also renamed: third axis **usability → experience** (`QualityModel.AXES` — quality_model.gd:29).

### sales

- **B2B pitch, value stage** — scripts/systems/pitch_system.gd:184 ("Dürüst ol", diff 1) and :186 ("Onun
  derdine odaklan", diff 0) — resolved `SkillCheck.resolve(skill, diff, _accum_bonus)` :236; pass → bonus
  +2, fail → −1 (:238).
- **B2B pitch, close stage** — all three close choices read sales — pitch_system.gd:212-214 — resolved
  :252-253: `resolve("sales", CLOSE_BASE_DIFFICULTY 1 (:19) + close_diff_delta + difficulty_stars − 1,
  _accum_bonus)`; band → SIGNED / SIGNED×0.85 (near_pass) / CALLBACK (near_miss) / LOST (:272-281).
  Rendered through the untracked MeetingScene adapter (scripts/systems/b2b_pitch_meeting.gd) which does
  **no skill reads of its own** — all checks stay in PitchSystem.
- **Prospect-read gate (sales ≥ 2)** — skill_check.gd:99-101 — consumers:
  - pitch_system.gd:117 — pricing-stage value hint (`_pitch_value_hint` :114-127; below gate: "körlemesine
    teklif" line, no per-seat range).
  - pitch_system.gd:162-163 — intro-stage reveal of hidden `budget_band` + `real_need`.
  - scripts/tabs/product/pricing_panel.gd:150 and :257 **[DRIFT — new home]** — B2C pricing card: optimal
    price shows "belirsiz" below the gate (:162), band paint + projection gated (:164-167). These sites
    lived in the old product_tab monolith at the calibration audit; now in the untracked Rev3 split.
- **Term-sheet valuation lever** — `LEVER_SKILL = {"valuation": "sales", …}` — pitch_constants.gd:87;
  diff 0 (:91); composed at term_sheet_table_system.gd:147-156 (`breakdown(skill, diff, leverage)` :151,
  −0.12/prior push :152, floor 0.05 :153-155); rolled via `roll_against` :95. Base 45% + 15pp/point.
- **VC Beat-2 non-vizyon angles (metrik/traction)** — fallback "sales" in `ANGLE_SKILL` —
  pitch_constants.gd:62 — routed `_angle_skill` scripts/systems/vc_pitch_system.gd:672-675, resolved :164
  (diff from investor weights :162, prep bonus :163/:678-683).
- Odds-% display reads: vc_pitch_system.gd:693-695 (`chance_for` → "%N" strings on beat choices).
- Debug grants: main.gd:388 (product-shot detail_b2c sets `role_stats["sales"] = 2`); smoke threshold
  flips scripts/debug/endgame_smoke.gd:2357-2361; SkillCheck parity cases :1061-1062, :1097.

### negotiation — sole read confirmed

- **Term-sheet dilution lever** — pitch_constants.gd:87 (`"dilution": "negotiation"`), diff 1 (:91) —
  same composition path term_sheet_table_system.gd:147-156. Smoke asserts the mapping
  (endgame_smoke.gd:2344-2353). No other reader anywhere (full-repo `get_founder_skill` +
  SkillCheck-callsite sweep).

### influence

- **VC Beat 1 "Odayı oku"** — `BEAT1_SKILL` pitch_constants.gd:59 — resolved vc_pitch_system.gd:152
  (diff ORTA — pitch_constants.gd:53); success reveals the tell (favored angle + Sorgu target).
- **VC Beat 3 Sorgu postures** — `BEAT3_SKILL` pitch_constants.gd:60 — resolved vc_pitch_system.gd:184
  (posture diffs :686-690; prep "prova"+dürüst bonus :183).
- **VC Beat 4 "Masayı zorla"** — `BEAT4_PUSH_SKILL` pitch_constants.gd:61 — resolved
  vc_pitch_system.gd:213 (diff ZORLU :54; fail = hard RET).
- **Beat-2 vizyon angle** — `ANGLE_SKILL {"vizyon": "influence"}` — pitch_constants.gd:62 → :164.
- **B2B pitch "Vizyon sat"** — pitch_system.gd:185 (diff VALUE_BASE_DIFFICULTY+1) → :236.
- **Term-sheet board lever** — pitch_constants.gd:87 (`"board": "influence"`), diff 2 (:91) — hardest
  lever (base 15%).

### leadership — ZERO mechanical reads (confirmed)

- Full-repo sweep of `get_founder_skill` call sites + SkillCheck skill strings + `LEVER_SKILL`/beat
  consts: **no site passes "leadership"**. It exists only as storage (game_state.gd:452-454), onboarding
  UI column, and debug-payload zero (main.gd:904 comment + :908 `"leadership": 0`).

### Generic vocabulary

- Event condition `founder_skill_min` — scripts/autoload/event_manager.gd:266-267 — evaluator exists;
  **no live event JSON uses it** (repo-wide grep over data/: zero hits).
- Prep bonus (modifies checks, not a read): `PREP_BONUS = 2` SkillCheck units (≈+20pp) —
  pitch_constants.gd:68 — applied beat-2 via `_beat2_bonus` (vc_pitch_system.gd:678-683) and beat-3
  dürüst (:183).

### Drift ledger vs calibration audit §8 (2026-07-17)

| §8 entry (old) | Today |
|---|---|
| tech → dev stability growth `1.5 + tech×0.75` (product_system.gd:276-277) | **REMOVED** — Rev3 deterministic axes (projected_axes :449-467) |
| — | **NEW** tech → team speed `_tech_of`/`_speed_for_lead` :161-186 (lead 1.0 / assist 0.5, floor 1.0) |
| tech → dev bug rate at :304 | moved → :330-331 (same formula) |
| tech → wear at :334 | moved → :360-361 (same formula) |
| prospect-read UI in product_tab | moved → scripts/tabs/product/pricing_panel.gd:150/:257 (untracked split) |
| B2B pitch reads :184/:186/:252 | unchanged lines; renderer swapped to b2b_pitch_meeting.gd (no own reads) |
| VC beat/lever routing pitch_constants.gd:59-62/:87 | unchanged |
| skill_alloc validation "game_state.gd:230-231" | moved → get_founder_skill :242-243; alloc validation now :455-460 |
| Stale comments flagged | **still present**: origin_traits_step.gd:9 ("8 points"), pitch_system.gd:9-12 ("markets/charisma") |

---

## §2 Onboarding skill allocation structure

### Constants (single home: scripts/systems/founder_constants.gd)

- `SKILLS = [tech, sales, negotiation, leadership, influence]` — :19; `OLD_SKILLS` tripwire list :20.
- `POINT_POOL = 6` — :23 (all must be spent; İleri gated). `ONBOARDING_CAP = 3` — :26 (per-skill max at
  creation). `SKILL_CEILING = 5` — :27 — underlying max; 4-5 only via **unbuilt** HR founder training;
  at 5 the SkillCheck 0.95 clamp caps anyway.
- Guards: `alloc_remaining` :118-122 (canonical keys only); `validate_alloc` :127-135 (only canonical
  keys, each 0..3, remaining == 0); smoke truth table endgame_smoke.gd:2301-2316 (under-pool, over-pool,
  cap-4, legacy key all rejected).

### Payload shape → GameState

- Onboarding draft — scripts/onboarding/onboarding_flow.gd:34-43 — `skill_alloc` starts
  `{tech:0, sales:0, negotiation:0, leadership:0, influence:0}` (:39), `trait_ids: []` (:38); page 2
  writes both via `collect_payload` — scripts/onboarding/steps/origin_traits_step.gd:413-418
  (`{origin_id, trait_ids, skill_alloc}`); `prefill` :392-403; `is_valid` :406-410 = origin unlocked +
  `validate_traits` + `alloc_remaining == 0` (İleri blocks on unspent points — smoke :2418-2426).
  **[DIVERGENCE — stale comment]** origin_traits_step.gd:9 still says "8 points"; code reads POINT_POOL 6.
- Commit: onboarding_flow.gd:220 `GameState.initialize_run(draft)` — the single seam (plus F12
  `_skip_to_shell` — scripts/main/main.gd:895-897 with `_debug_payload()`).
- `initialize_run` roster block — game_state.gd:416-424: `ensure_mentor()` :417, `_build_founder(payload)`
  → `CharacterRegistry.add` :418-419, month-1 snapshot :423, `run_hires = 0` re-zero :424 (founder add
  must not count as hire; category "founder" already excluded at the registry seam).
- `_build_founder` — game_state.gd:427-465:
  - `skill_alloc` read :428; trait array build + `validate_traits` push_error :431-435.
  - Founder Character: id `char_founder` :443, role "Founder" :445, category "founder" :446,
    `monthly_salary 0` :447, `equity_pct 100.0` :448, `morale 50` :449.
  - **skill_alloc lands in `f.role_stats`** :452-461 — stats dict built over FounderConstants.SKILLS
    :453-454 (missing keys → 0); stale payload key push_error :455-457; `validate_alloc` push_error
    :458-460 (does NOT block — founder is still built); `f.traits` :462.
- Debug payload parity — main.gd:900-914: alloc `{tech 2, sales 2, negotiation 1, leadership 0,
  influence 1}` (:908, sums to 6), traits `["visionary","stubborn"]` (:909). Smoke harness passes it —
  main.gd:81 `EndgameSmoke.run_case(smoke_case, _debug_payload())`; twin copy in the smoke onboarding
  case endgame_smoke.gd:2386-2391 **[DIVERGENCE — two hand-maintained copies of the canonical debug
  alloc]**.

### Downstream readers of the allocated values

Storage is `founder.role_stats` — every mechanical read goes through `get_founder_skill`
(game_state.gd:237-247). Complete caller list (verified sweep):
- skill_check.gd:24 (`chance_for`), :34 (`breakdown`), :81 (resolve result field), :101 (prospect read).
- product_system.gd:166, :169 (`_tech_of` founder branches), :182 (founder-as-assist), :330 (dev bugs),
  :360 (wear).
- pricing_panel.gd:150, :257 (B2C optimal-price gate).
- event_manager.gd:267 (`founder_skill_min` condition — no live event).
- Debug/verification: endgame_smoke.gd:2281-2284 (payload assert + legacy-key tripwire),
  main.gd via SkillCheck only.
Direct `role_stats` writes outside init (debug only): main.gd:388; smoke :1483, :2357/:2360.
Smoke shape-lock: endgame_smoke.gd:2264-2298 — role_stats must hold EXACTLY the 5 canonical keys
(:2270-2275), sum == POINT_POOL (:2276-2280), legacy read returns 0 (:2284).

### trait_ids — RESERVED, storage-only (confirmed)

- Catalog: 4 positive + 4 negative — founder_constants.gd:39-48; formula 1-2 pos, ≤1 neg, 2 pos → exactly
  1 neg — :33-34, `validate_traits` :140-162; smoke truth table endgame_smoke.gd:2319-2341.
- Stored at game_state.gd:462 into `Character.traits` (scripts/data_models/character.gd:39). **No system
  consumes trait effects** (founder_constants.gd:37-38 comment; repo sweep: only validation, storage, and
  the event `add_character` copy path event_manager.gd:439-443 touch `.traits`). Origin `reserved_flags`
  equally set-but-unconsumed (game_state.gd:405-406).

---

## §3 Employee data shape today

### The Character model — scripts/data_models/character.gd (all fields)

- Identity: `id` :23 · `character_name` :24 · `role: String` (free-form) :25 · `category` :26
  ("founder" | "employee" | "mentor" | "npc").
- Compensation: `monthly_salary: int` :29 · `equity_pct: float` :30.
- `morale: int = 50` :33 (clamped 0..100 at the registry seam).
- Reserved (declared, defaults): `loyalty 50` :36 · `relationship "neutral"` :37 · `trust_score 0` :38 ·
  `traits: Array[String]` :39 · `role_stats: Dictionary` :40 · `attention_flag` :41 (FLIGHT_RISK |
  BURNING_OUT | OVERLOADED | PROMO | CO_FOUNDER_TRACK — no writer/reader).
- **[DIVERGENCE — role_stats scale]** character.gd:40's example comment says `{"tech": 60,
  "leadership": 30}` (0-100), but live convention is **tech 0-5** (founder cap 3, employee default 2 —
  product_system.gd:30) while **cs_skill is 0-100** (55 seeded — main.gd:186; /25 per capacity slot,
  /200 dampen — b2b_constants.gd:188-195). Two scales in one dict, comment matches neither exclusively.

### Role strings in live use (case-sensitive matching)

- "Founder" — game_state.gd:445. "Engineer" — matcher `count_engineers` scripts/autoload/character_registry.gd:74-82
  (`c.role == "Engineer"` :80; header note :76-77 "hire flow gelince tek sabite bağlanmalı"); creation-flow
  SORUMLU filter scripts/tabs/product/creation_flow.gd:675; team-speed loop product_system.gd:184.
- `ROLE_CUSTOMER_SUCCESS := "Müşteri Başarı"` — character_registry.gd:57 (also the on-screen label) —
  matcher `get_customer_success` :60-67 (category "employee" AND role match), `count_customer_success`
  :70-71. CS is an employee TYPE distinguished by role, not category (:61-62).
- "Designer" (debug seed :221), "Operating Partner" (ensure_mentor :115), "Mentor" (debug seed :199)
  **[DIVERGENCE — two mentor role strings across the two seed paths]**.
- `event_modal` shows `c.role` raw in the speaker strip ("%s · %s") — scripts/modals/event_modal.gd:70.

### How employees are seeded today (no hire flow exists)

- `DEBUG_SEED := false` — character_registry.gd:26 — normal runs start with **zero employees**;
  `_seed_debug_characters` :192-225 (off): Frank :196-202, Debug Engineer A $6000/morale 60 :209-216,
  Debug Designer B $5000/morale 40 :218-225. **Neither debug employee carries `role_stats`** — their
  tech reads fall to `ENGINEER_DEFAULT_TECH = 2` (product_system.gd:30, :170).
- Event modifier `add_character` — event_manager.gd:416-446 — full field copy with defaults (salary 0
  :433, morale 50 :435, `role_stats` raw dict :444, traits :439-443). **No live event JSON uses it**
  (data/ grep: zero hits) — machinery-only; badge string exists (event_modal.gd:250).
- Shot/smoke seeds: CS "Burcu Çetin" $5000 + `{"cs_skill": 55}` — main.gd:180-188 (b2b-shot),
  `_shot_customer` CS rep (no salary/skills) :467-474; smoke `_make_cs` endgame_smoke.gd:2020-2030,
  engineers :1494-1499 (no role_stats → default tech), :2028.
- The only gameplay `CharacterRegistry.add` caller is the founder (game_state.gd:419). `add` seam
  :136-149 — employee category increments `run_hires` :144-148; `remove` :152-162 increments
  `run_departures` :158-160 (reads 0 — no fire/quit flow).

### Mentor special-casing (Frank must never read as hireable staff)

Frank is distinguished by **`category == "mentor"`**, id `char_mentor_frank` (ensure_mentor —
character_registry.gd:103-120; idempotent, direct insert so no `character_added` fires :108-110).
Every staff surface filters him out via category, not name:
- `get_employees` :49-54 (category == "employee") — the base filter every §4 consumer iterates.
- Payroll `get_total_monthly_salaries` :125-131 — employees only; mentor salary 0 anyway :117.
- `run_hires` counting — add() :144-148 — mentor never passes add() (:109-110), founder excluded by
  category.
- Morale drift — scripts/systems/hr_system.gd:22-28 iterates get_employees (mentor excluded).
- Capacity/count_engineers :74-82 — get_employees-based; mentor can never be an "Engineer".
- Equity `get_founder_equity` — game_state.gd:228-234 — employees only.
- Team size display — scripts/systems/month_summary_system.gd:77-79 (`1 + employees`; comment: "mentor
  is an advisor, not team"); ending data scripts/systems/endings_system.gd:261; run ledger
  game_state.gd:294.
- Dedicated accessors: `get_mentor` :85-89 → right_panel.gd:117, mentor_intro_modal.gd:16;
  `get_founder` :92-98 (category "founder").
Migration rule that follows: **any new role/department typing must keep category as the
founder/mentor/staff discriminator** — role strings are display+matcher today, category is the guard.

---

## §4 Systems reading employee attributes (complete consumer list)

For each: fields read → formula → what breaks if Character fields are renamed/role-typed.

1. **Build capacity pool** — product_system.gd:121-149 —
   `capacity_total = CAPACITY_BASE 1 (:99) + count_engineers()` (:121-123; registry :74-82 reads
   `category`+`role=="Engineer"`); `capacity_demand` :126-134 = sprint flag + `pitch_prep_active` +
   active build (1 each); `capacity_speed_factor = min(1, total/demand)` :137-143; UI projection
   :146-149. *Breaks on:* role string rename (case-sensitive :80), category retyping. Headcount only —
   no skill/morale term.
2. **Team speed (Rev3)** — product_system.gd:173-192 — reads `id`, `role=="Engineer"` (:184),
   `role_stats.tech` default 2 (:170, :185). *Breaks on:* role rename, `tech` key rename, scale change
   (formula assumes 0-5; a 0-100 UZMANLIK would 20× build speed).
3. **needs_engineer signal** — `_record_sprint_and_check_engineer` — product_system.gd:431-442 — ≥3
   sprints in 20 days (:93-94) → `set_flag("needs_engineer", true)` :442. **[RESERVED — write-only]**:
   zero readers in scripts AND data (repo grep) — no Frank line, no event condition consumes it yet.
   The HR spec's natural first hook.
4. **CS churn dampen (B2B Stage D)** — scripts/systems/b2b_sales_system.gd:39-59 — per-customer, NOT
   headcount: `assigned_to != ""` → downward satisfaction drift × `cs_dampen(skill)` (:49-50; upward
   recovery full-strength); `_cs_skill_of` :55-59 reads `role_stats.get("cs_skill", 0)` off the assigned
   Character. `cs_dampen = clamp(1 − skill/200 [INLINE], 0.4, 1.0)` — scripts/systems/b2b_constants.gd:193-195.
   *Breaks on:* `cs_skill` key rename or 0-100→0-5 rescale (dampen and capacity formulas both assume
   0-100).
   - **[RESERVED trio]** `cs_capacity(skill) = 3 + skill/25` — b2b_constants.gd:188-190,
     `FOUNDER_DIRECT_CAP = 4` — :181, `founder_managed_count()` — b2b_sales_system.gd:269-276: **zero
     callers each** (the delegation-prompt UI they were built for isn't wired). Likewise
     `CustomerRegistry.assign_customer` — scripts/autoload/customer_registry.gd:236 — has **no gameplay
     caller** (debug shots/smoke only): CS delegation is mechanically live but unreachable in normal play
     (no hire flow, no assign flow).
   - CS escalation path — b2b_sales_system.gd:98-114 (below `CS_ESCALATION_SAT 35` — b2b_constants.gd:182
     → one escalation, re-arms on recovery) → event speaker is the real CS Character
     (scripts/systems/b2b_event_factory.gd:85-108, `character_id = cs.id` :94); refuse choice carries
     `{"type": "morale", character_id: cs.id, delta: −10}` + brand −3 (:102-106; consts :184-185);
     smoke :2066-2099.
5. **Salary → Finance** — scripts/systems/finance_system.gd:42-43 — daily pull
   `get_total_monthly_salaries()` (registry :125-131, `category=="employee"` + `monthly_salary`) → 
   `burn_breakdown["salaries"] = round(monthly/30)`. *Breaks on:* category retyping; **an İZİNDE status
   must be filtered here or leave is fully paid** (no status field exists — §5).
6. **Morale readers/writers** — HRSystem drift ±1/day toward 50, dead-band ±1 —
   hr_system.gd:22-36 (iterates get_employees; writes via `set_morale` seam registry :174-186, clamp
   0-100, emits `morale_changed`); event modifiers `morale` / `morale_all_employees` —
   event_manager.gd:400-409; HR tab badge = count(morale < 40) — scripts/ui/components/left_tabs.gd:116-121;
   badge label uses the character's first name — event_modal.gd:223, `_char_first` :272-278.
7. **Equity** — `get_founder_equity` = 1 − Σ employee `equity_pct` — game_state.gd:228-234; cap-table
   card right_panel.gd:250-263 (counts employees with equity > 0).
8. **Headcount displays / conditions** — month_summary_system.gd:77-79 (team = 1 + employees);
   endings_system.gd:261 (ending data); game_state.gd:294 (run ledger "employees"); VC Sorgu team domain
   — vc_pitch_system.gd:624-627 (`count_engineers()==0` → "no_engineers"; `get_employees().is_empty()` →
   "solo"); callback condition `first_engineer` = count_engineers ≥ 1 — :711.
9. **Event character context** — event_modal.gd:62-72 — `get_character(event.character_id)`; renders
   `character_name · role` :70 and the `relationship` pill :72 (the only `.relationship` read in the
   game). *Breaks on:* role becoming an id (raw string is displayed).
10. **SORUMLU (lead) selector** — creation_flow.gd:668-679 — founder + every `role=="Engineer"` employee;
    selection id → `b.lead_engineer_id` (product_system.gd:594) → team-speed lead.
11. **Sales tab steward line** — scripts/tabs/sales_tab.gd:308-315 — `character_name` of the assigned CS.
12. Unreferenced fields: `loyalty` / `trust_score` / `attention_flag` — written only by the (unused)
    add_character copy path (event_manager.gd:436-445, game_state.gd:463-464 comment); zero readers.
    Safe to repurpose/retype with no reader migration.

---

## §5 Collision & migration list (today's Character shape → HR design target)

Target per the HR design brief: typed `role`, `department`, 3 axes **UZMANLIK / HIZ / UYUM** (internal
keys `expertise` / `pace` / `rapport` — English identifiers, **proposal**), trait list, `hire_day`,
`leave_month`, status **AKTİF / İZİNDE**. Delta against character.gd:22-41:

| Target field | Today | Action + every reader that must change |
|---|---|---|
| `role` (typed) | Free String, case-sensitive matchers | Convert to role-id + display key. Touch: registry :80 ("Engineer"), :65 (ROLE_CUSTOMER_SUCCESS :57), creation_flow.gd:675, team-speed product_system.gd:184, seeds (registry :199/:212/:221, main.gd:183/:471, smoke :1497/:2024), display event_modal.gd:70. Registry :76-77 already demands "tek sabit" when the hire flow lands. |
| `department` | **ABSENT** (category ≠ department — category is founder/employee/mentor/npc :26) | Pure addition; keep `category` as the founder/mentor guard (§3). Zero existing readers. |
| 3 axes | `role_stats` per-role heterogeneous dict: founder {5 strategic keys, 0-5}; engineer {`tech`, 0-5, default 2}; CS {`cs_skill`, 0-100} | **Key collision:** UZMANLIK folds over BOTH `tech` and `cs_skill` — on two different scales [DIVERGENCE, §3]. Pick ONE scale; recalibrate whichever side loses: 0-5 → cs formulas (/25 slots, /200 dampen — b2b_constants.gd:188-195); 0-100 → speed/bug/wear terms (product_system.gd:180-186/:331/:361) and ENGINEER_DEFAULT_TECH :30. Readers to migrate: product_system.gd:170/:185 (`tech`), b2b_sales_system.gd:59 (`cs_skill`). No in-code precedent exists for `pace`/`rapport`; `expertise` has the two precedents above — the proposed keys are fine, but the migration must decide whether `tech`/`cs_skill` become `expertise` per-department or stay role-specific under a facade. Also fix the misleading 0-100 example comment character.gd:40. |
| — (founder coexistence) | Founder's 5 strategic skills live in the SAME `role_stats` dict employees will hold the 3 axes in | `get_founder_skill` returns 0 for any unknown key with no error (game_state.gd:247) except OLD_SKILLS — a founder accidentally given employee axes (or vice versa) is silent. Smoke locks the founder dict to exactly 5 keys (endgame_smoke.gd:2270-2275) — extend the same exact-key lock to employee shapes, or namespace them. |
| trait list | `traits: Array[String]` exists :39 — founder-only in practice, effects unwired (§2) | Reusable as-is. `validate_traits` is founder-formula-specific (2 pos → exactly 1 neg — founder_constants.gd:140-162); employee traits need their own validator/catalog. add_character copies raw (event_manager.gd:439-443). |
| `hire_day` | **ABSENT** — only the aggregate `run_hires` counter (game_state.gd:79, registry :148) | Add field; stamp inside `CharacterRegistry.add` (:136-149) so event hires + future flow both get it. Precedent pattern: `Customer.acquired_on_day`. |
| `leave_month` | **ABSENT** | Add; `remove()` seam ready (registry :152-162, run_departures :158-160, `character_removed` emit). |
| status AKTİF/İZİNDE | **ABSENT**. `attention_flag` :41 is a different concept (HR attention states, reserved) — do NOT overload it | Add a distinct `status`. **Every `get_employees` consumer must then decide AKTİF-filtering** (İZİNDE currently would: draw full salary finance :42-43; count in capacity :121-123 and team speed :183-185; keep CS dampen b2b :49-50; drift morale hr :23; count in badges left_tabs :118, team size month_summary :79, endings :261, ledger :294, VC sorgu :624-627, callback :711, equity :232, captable right_panel :255, SORUMLU list creation_flow :674). Recommend a `get_active_employees()` sibling so callers opt in explicitly. |
| Save schema | Character is an @export Resource; SaveManager not built | New fields are forward-compatible by design (character.gd:14-17); migration cost is reader-side only. |

### Known issue: ending-shot harness `trait_ids/skill_alloc` push_error

- **Cause:** the five screenshot harnesses call `GameState.initialize_run({})` with an EMPTY payload —
  main.gd:167 (b2b-shot), :216 (sales-shot), **:275 (ending-shot)**, :338 (product-shot), :431
  (pitch-shot). `_build_founder({})` then fires BOTH validators: `validate_traits([])` fails (needs ≥1
  positive — founder_constants.gd:156) → push_error game_state.gd:434-435, and `validate_alloc({})`
  fails (`alloc_remaining = 6 ≠ 0` — founder_constants.gd:135) → push_error game_state.gd:458-460.
  Non-blocking: the founder is still built with all-zero skills (:452-454 defaults) — screenshots are
  correct, logs are noisy. Same accepted noise in smoke's non-founder cases (endgame_smoke.gd:1911,
  :2244).
- **Silencing payload shape:** any dict where `skill_alloc` holds the 5 canonical keys summing to 6 with
  each ≤ 3, and `trait_ids` satisfies the trait formula — i.e. exactly `_debug_payload()`
  (main.gd:905-914: `{tech 2, sales 2, negotiation 1, leadership 0, influence 1}` +
  `["visionary","stubborn"]`). The smoke entry point already routes it (main.gd:81); the five shot
  harnesses just don't. One-line fix per harness when a write pass is authorized:
  `initialize_run(_debug_payload())`.

---

## §6 Bridge candidate points (founder → operational output)

Every formula where the founder currently contributes to operational output — the exact seams where
`founder strategic skill × coefficient → operational contribution` multipliers will be defined.
"Explicit" = a founder skill is in the formula; "implicit" = the founder participates as skill-free
headcount/labor.

1. **Build speed — EXPLICIT (tech).** `_speed_for_lead` — product_system.gd:180-182 — founder tech ×1.0
   as lead, ×0.5 as assist. **The bridge shape already exists**: `SPEED_LEAD_WEIGHT` :27 /
   `SPEED_ASSIST_WEIGHT` :28 are literally founder-coefficient constants; the HR spec can generalize
   them per-person (employee HIZ axis feeding the same slot `_tech_of` fills today).
2. **Capacity pool — IMPLICIT (headcount).** Founder = flat `CAPACITY_BASE 1` — product_system.gd:99,
   :121-123 — regardless of any skill; sprint / pitch prep / build each demand 1 (:126-134; prep
   occupying the founder is the one place founder TIME is modeled — :130-131). Natural leadership-bridge
   target (delegation raising effective capacity).
3. **Dev bug reduction — EXPLICIT (tech), founder-ONLY.** :330-331 — reads founder tech even when an
   employee is lead. Asymmetry to resolve in the HR spec: should the lead's UZMANLIK take this slot
   (with a founder bridge on top), or stay founder-global?
4. **Post-ship wear reduction — EXPLICIT (tech), founder-ONLY.** :360-361 — engineers contribute nothing
   to live-product wear. Same asymmetry as #3.
5. **Bug sprint / BETA rates — IMPLICIT, skill-free flat rates.** `SPRINT_BUG_FIX_PER_DAY 4` :89 (sprint
   demands capacity but its RATE ignores who works), `POLISH_BUG_FIX_PER_DAY 4` :47, `BETA_BUG_FIND_PER_DAY
   6.0` :71. Candidates for UZMANLIK/tech scaling once employees do the fixing.
6. **B2B selling — EXPLICIT (sales/influence), founder does ALL of it.** Value/close checks read founder
   skills (pitch_system.gd:184-186, :236, :252-253); prospect read gate (:117, :162; pricing_panel
   :150/:257). No sales-rep role exists — a future AE/sales hire needs its own check subject + a founder
   coefficient.
7. **Founder-managed customer success — IMPLICIT, skill-FREE.** Unassigned accounts (`assigned_to == ""`)
   erode at full strength — b2b_sales_system.gd:49-50 gives the dampen ONLY to CS-assigned; no founder
   skill (sales? leadership?) dampens founder-managed erosion, and `FOUNDER_DIRECT_CAP 4` +
   `founder_managed_count` are declared-unwired (§4.4). The founder-as-CS bridge is a green field with
   its cap already named.
8. **Fundraising table — EXPLICIT (influence/sales/negotiation), inherently founder-personal.** VC beats
   (vc_pitch_system.gd:152/:164/:184/:213), levers (term_sheet_table_system.gd:147-156). Not a bridge
   target (the founder IS the operator here) — listed for completeness.
9. **Morale/team output — NO channel exists.** Leadership has zero reads (§1); HR drift is autonomous
   (hr_system.gd:31-36, ±1/day toward 50); morale affects NOTHING mechanically today (no productivity
   term reads it — §4.6 consumers are display/badge/ledger). The leadership bridge's natural home:
   leadership × coefficient → morale floor/drift target, morale → HIZ/UYUM modifier.
10. **Compensation/equity frame** — founder salary 0 / equity 100 − Σ employees (game_state.gd:447-448,
    :228-234) — the payroll-pressure side any hiring bridge trades against (finance pull §4.5).

Summary for the spec: today the founder's operational contribution is **explicit and skill-based** in
build speed, bug/wear reduction, and all selling; **implicit and skill-free** in capacity, sprint labor,
and customer stewardship; and **absent** exactly where the HR module wants to live (leadership → team,
morale → output, delegation caps). The three unwired seams already pointing at HR — `needs_engineer`
(product_system.gd:442), `FOUNDER_DIRECT_CAP`/`cs_capacity` (b2b_constants.gd:181/:188), and
`SKILL_CEILING 4-5 via founder training` (founder_constants.gd:27) — are the contact points the HR Core
spec should wire first.

---

*Report generated by read-only audit (2026-07-21); every cited line verified against the live working
tree this session. No repo file other than this report was created or modified.*
