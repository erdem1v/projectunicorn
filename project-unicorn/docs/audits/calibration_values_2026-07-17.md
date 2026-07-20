# Calibration Values Audit — 2026-07-17

Read-only audit, prerequisite for the economy-curve redesign (CLAUDE.md CALIBRATION LAWS;
1:1 real-dollar scale + Frank-angel seed beat; 180d → ~1-2yr extension pending). This is the
"what do the numbers actually say today" map: every tuning value, with `file:line` and what it
drives. **Zero changes were made.** Flags: `[INLINE]` = hardcoded literal outside a
constants/const block; `[DIVERGENCE]` = the same concept encoded in 2+ places; `[DEAD]` =
declared but consumed by no live formula. All paths relative to `project-unicorn/`.
Method: full-source verification of every cited line (this session), plus an instrumented
headless run for §5 tempo (measured, not estimated). The parallel `project-unicorn-OLD-backup/`
tree is excluded.

---

## §1 Economy floor

### Starting state (per origin + run init)

- `starting_cash = 10000` — scripts/systems/founder_constants.gd:60 — self_made (only playable origin) opening cash.
- heir / corporate_refugee: **no economic fields** (locked) — founder_constants.gd:62-67 — reads fall back to 10000.
- `cash: int = 10000` [INLINE] — scripts/autoload/game_state.gd:29 — pre-run default.
- `cash = origin.get("starting_cash", 10000)` [INLINE fallback] — game_state.gd:281 — initialize_run seed.
- **[DIVERGENCE]** 10000 lives in 3 homes (founder_constants.gd:60 + the two game_state literals). Consistent today; an origin-catalog change does not update the literals.
- Run-init resets (game_state.gd:282-288): `mrr=0` :282 · `daily_burn=50` [INLINE] :283 · `brand=50` :284 · `reputation=0` :285 · `day=1` :286 · `current_hour=9` :287 · `phase=1` :288.
- Founder character: `monthly_salary=0`, `equity_pct=100.0`, `morale=50` — game_state.gd:379-381 — founder draws no salary; equity derived as `1 − Σ employee.equity_pct` (game_state.gd:216-222).
- Clamps: brand 0-100 — game_state.gd:121-123; reputation −10..100 — game_state.gd:125-129.
- Origin `reserved_flags` `[origin_press_sympathy, origin_low_capital]` — founder_constants.gd:61, set at game_state.gd:337-338 — RESERVED, consumed nowhere.

### Daily burn — baseline and every component

- `daily_burn: int = 50` [INLINE] — game_state.gd:31 (default) and :283 (init) — ~$1,500/mo → ~6.6-month opening runway.
- `burn_breakdown` — scripts/systems/finance_system.gd:26-33 — the computed source; **sums to 50**:
  - `salaries = 0` — :27 — overwritten daily from CharacterRegistry pull.
  - `tools = 7` — :28 — SaaS/hosting (~$210/mo).
  - `office = 25` — :29 — coworking desk (~$750/mo).
  - `marketing = 0` — :30 — TODO (future marketing-spend mechanic mutates via set_burn_category).
  - `legal = 11` — :31 — retainer/accountant (~$330/mo).
  - `misc = 7` — :32 — software/supplies (~$210/mo).
- **[DIVERGENCE]** starting burn 50 is a hand-maintained mirror of Σ breakdown; game_state literals and finance_system can desync until the first finance daily tick overwrites `GameState.daily_burn` (finance_system.gd:46-48).
- Salary pull: `salaries = round(monthly_salaries / 30)` — finance_system.gd:42-43.
- `DAYS_PER_MONTH := 30` — finance_system.gd:20 — monthly→daily conversion (salaries + MRR).
- `DAYS_PER_MONTH := 30` — game_state.gd:7 — **[DIVERGENCE]** second home (comment cross-references finance). Meanwhile month BOUNDARIES use real 28/30/31-day calendar months via `get_date_dict` (game_state.gd:238-245, anchor `START_DATE = 2026-01-01` :12; month_summary_system.gd:30-32 closes a month when the rollover lands on the 1st). Two "month" concepts by design — flag for the curve redesign.
- Daily revenue: `round(mrr / 30)` — game_state.gd:203-204 (display) and finance_system.gd:51 (applied); net applied once via `set_cash(cash + net)` — finance_system.gd:54-55.

### Per-employee salary values (no hire flow exists — debug/event-driven only)

- Debug engineer `monthly_salary = 6000` — scripts/autoload/character_registry.gd:208 (DEBUG_SEED path).
- Debug designer `monthly_salary = 5000` — character_registry.gd:217.
- Mentor `monthly_salary = 0` — character_registry.gd:195 — advisor, not payroll.
- Debug CS hire `monthly_salary = 5000`, `cs_skill = 55` [INLINE] — scripts/main/main.gd:174-175 — F-key escalation shot.
- Event-driven hire salary default 0 — scripts/autoload/event_manager.gd:433 (`add_character` modifier).
- Payroll sum = employees only (mentor/founder excluded) — character_registry.gd:125-131.

### Runway — three presentations [DIVERGENCE]

- **NET runway (canonical shell)**: `INF if net ≥ 0 else cash / (−net) / 30` — game_state.gd:209-214 — revenue-aware.
- "Kârlı" / "Default Alive" threshold = **net daily flow ≥ 0** (runway INF) — scripts/theme/ui_tokens.gd:216-219 (`net_runway_parts`: INF → `RUNWAY_PROFITABLE` string, unit hidden; else whole months) — consumed by TopBar (scripts/ui/components/top_bar.gd:136-142) and Finance tab.
- **GROSS runway, months**: `cash / burn / 30`, always finite, 0 if cash ≤ 0 — scripts/systems/vc_pitch_system.gd:649-653 — the VC's "if revenue → 0" lens; also gates the thin-runway seed penalty.
- **GROSS runway, days**: `floor(cash / burn)` shown as "Runway: N gün" [INLINE] — scripts/systems/term_sheet_table_system.gd:346-349 — a third unit (days) at the term-sheet table.

### Money formatting [DIVERGENCE — three formatters]

- `UiTokens.format_money` — ui_tokens.gd:196-209 — declared "the single convention going forward": <$1K exact · ≥$1K one-decimal K · ≥$1M one-decimal M · ≥$10M clean → no decimal.
- `TopBar._fmt_money` — top_bar.gd:211-219 — legacy: has a `≥10000 → no-decimal K` branch UiTokens lacks; MRR/burn/net chips.
- `TopBar._fmt_cash_full` — top_bar.gd:225-234 — cash always exact with manual comma grouping (no rounding).

---

## §2 Product / build

### Phase machinery — scripts/systems/product_system.gd

- `ITERATION_LENGTH_DAYS = 4` — :24 — length of one design-iteration round.
- `DEVELOPMENT_DAYS_BASE = 6` — :25 — dev-phase span = base + total feature complexity (:623).
- `MAX_VERSION_FEATURES = 8` — :27 — cap on a version build's union feature count.
- `STRENGTHEN_MAX_PER_VERSION = 2` — :33 — pool-deepening picks per version.
- `STRENGTHEN_FLAT_PER_DAY = 1.5` — :34 — flat per-day dominant-axis bonus per strengthened feature.
- `POLISH_BUG_FIX_PER_DAY = 4` — :35 — bugs cleared/day during bugfix (BETA fix rate).
- `HOURS_PER_BUILD_DAY = 24` — :36 — quality/bugs accrue hourly (daily_raw / 24).
- `CANCEL_FREE_DAYS = 1` — :86 — first-day cancel is narrative-"free".
- v1 feature-count validation **2-4** [INLINE] — :580 (product_tab mirrors the 4 at scripts/tabs/product_tab.gd:657/:695/:861).
- `min_estimation_days = max(5, total_complexity + 2)` — :625 (v1) and :727 (v2).
- v2 duration: `V2_DEV_DAYS_BASE = 3` — :94; `V2_COMPLEXITY_FACTOR = 1.5` — :95; `version_dev_days = 3 + ceil(effort_complexity × 1.5)` — :741-748 (effort = new + strengthened only, not the union — :722-725).
- Capacity pool: `CAPACITY_BASE = 1` — :119 — `capacity_total = 1 + count_engineers` (:136); sprint, pitch prep, and an active build each demand 1; speed factor `min(1, total/demand)` (:158).

### Bug seeding & accrual

- **`FEATURE_BUG_SEED_COEF = 1.0`** — product_system.gd:50 — at-commit "new feature = new bug" seed. Formula `_seed_feature_bugs = Σ round(feature.complexity × 1.0)` over NEW features — :314-322. v1 seeds all selected features (:616); v2 seeds only newly added (:712); hardening seeds 0.
- Dev-phase hourly accrual: `rate = max(BUG_FLOOR, Σcomplexity·BUG_COMPLEXITY_COEF − tech·BUG_TECH_REDUCER)` — :304.
  - `BUG_COMPLEXITY_COEF = 0.006` — :42; `BUG_TECH_REDUCER = 0.005` — :43; `BUG_FLOOR = 0.010` — :44.
- `TECH_DEBT_BUG_PENALTY = 5` — :46 — tech-debt flag converts to real bugs at dev→bugfix.
- `CRITICAL_BUG_LAUNCH_PENALTY = 5` — :74 — applied at launch if `critical_bug_unfixed` (:517-518).
- `BETA_BUG_FIND_PER_DAY = 6.0` — :79 — hidden bugs surfaced per BETA day (fixed at POLISH rate 4/day).

### Quality growth per phase (raw/day, shaped by feature mix)

- `ITER_INNO = 2.0` — :57; `ITER_USAB = 1.5` — :58 — iteration grows innovation + usability (no bugs in iteration).
- `DEV_STAB_BASE = 1.5` — :59; `DEV_USAB = 1.0` — :60 — development grows stability + usability.
- `TECH_STAB_COEF = 0.75` — :61 — dev stability raw = `1.5 + tech × 0.75` (:276-277) — founder tech's biggest lever.
- BETA/bugfix: axes LOCKED (no growth consts — removed; recovery is visible only through effective stability as bugs fall) — :62-65 comment.
- Feature-mix shaping: `raw × (DIM_BASE_SHARE + DIM_FEATURE_SHARE × axis_share × 3)`; `DIM_BASE_SHARE = 0.5` — :69, `DIM_FEATURE_SHARE = 0.5` — :70 — equal mix is neutral ×1.0.
- Early ship haircut: `EARLY_SHIP_AXIS_HAIRCUT = 0.5` — :82 — all axes × `(1 − 0.5 × unfinished_ratio)` (:504-510); bypasses grow() deliberately.

### Normalization / asymptote / erosion — scripts/systems/quality_model.gd

- `NORMALIZE_HALF_SAT = 50.0` — :41 — composite that maps to normalized 50; decides where a shipped v1 lands on the 0-100 band. `normalized = 100·c/(c+50)` — :82-84 (strictly <100).
- `PHASE1_AXIS_ASYMPTOTE = 110.0` — :45 — per-axis soft ceiling; `grow(current, raw, asym) = current + raw·(1 − current/asym)` — :61-64. **[DIVERGENCE]** the comment (:44) promises "later versions raise this per-version," but it is one flat const — v1/v2/v3 all asymptote at 110. There is **no explicit v1→v2→v3 gain table**: version growth is emergent (v2 seeds axes from the live product — product_system.gd:707-709 — and regrows under the same raws/asymptote; strengthen adds `STRENGTHEN_FLAT_PER_DAY` + weight redistribution).
- `BUG_STABILITY_COEF = 0.8` — :50 — `effective_stability = max(0, stability − 0.8 × bug_count)` (:98-99); softened from 1.5 (Part 2B).
- `STRENGTHEN_CONTRIB_FACTOR = 3.0` — scripts/data_models/feature_build.gd:143 — strengthened feature's dimension weights ×3 (redistribution; other axes' share drops) (:151-171; equal 1/3 fallback :166).
- Axes born at 0.0 — product_system.gd:611-613 / feature_build.gd:58-60 — a v1 climbs from nothing.

### Post-ship wear (usage-driven bug accrual) — product_system.gd

- Rate = `max(WEAR_FLOOR, audience·WEAR_AUD_COEF + complexity·WEAR_CPLX_COEF − tech·WEAR_TECH_REDUCER)` per hour — :334.
  - `WEAR_AUD_COEF = 0.00004` — :103; `WEAR_CPLX_COEF = 0.0012` — :104; `WEAR_TECH_REDUCER = 0.005` — :105; `WEAR_FLOOR = 0.002` — :106.
- Bug sprint: `SPRINT_BUG_FIX_PER_DAY = 4` — :109; duration `clamp(ceil(bugs/4), MIN_SPRINT_DAYS=1, MAX_SPRINT_DAYS=7)` — :110-111, :354-356.
- HR bridge: `ENGINEER_SPRINT_THRESHOLD = 3` sprints within `ENGINEER_WINDOW_DAYS = 20` → needs_engineer signal — :113-114.

### Feature catalog — scripts/systems/product_catalog.gd

- Sub-product types (:20-61): b2c = ai_assistant / ai_photo_editor(`volume`) / ai_code_copilot; b2b = ai_vector_search(`premium`) / saas_project_mgmt / saas_crm / saas_analytics / saas_billing / saas_dev_tools(`premium`) / saas_ops(`neutral`); `social` pool empty (:63). **COST FIELD: ABSENT** — no build-cost/price field on any type or feature (the curve redesign's efor/cost fields have no current home).
- Every feature: `complexity` (drives duration + bug seed), `pull` 1-5 (audience draw), `stakes` 1-5 (rep-damage mult), `dimension_contribution {innovation, stability, usability}` (steers axis growth), `requires_research: false` everywhere.

Format: **cx/pull/stakes — inno,stab,usab** (FEATURE_POOLS :76-158):

| Pool | Feature | Values |
|---|---|---|
| ai_assistant | chat :78 | 2/4/2 — 0.5,1.0,3.0 |
| | memory :79 | 3/4/3 — 2.0,2.0,1.0 |
| | tools :80 | 4/5/5 — 3.0,0.5,1.0 |
| | voice :81 | 3/4/3 — 2.0,0.5,2.0 |
| | image :82 | 4/4/4 — 3.0,0.5,1.0 |
| | streaming :83 | 2/3/1 — 0.5,1.0,2.5 |
| ai_photo_editor | bg_removal :86 | 2/5/2 — 1.0,1.0,3.0 |
| | inpaint :87 | 4/5/4 — 3.0,0.5,1.5 |
| | upscale :88 | 3/4/3 — 2.0,1.0,2.0 |
| | style_transfer :89 | 3/4/2 — 3.0,0.5,2.0 |
| | batch :90 | 3/3/3 — 0.5,2.0,2.0 |
| | filters :91 | 1/3/1 — 1.0,1.0,3.0 |
| ai_code_copilot | autocomplete :94 | 3/5/4 — 1.5,2.0,3.0 |
| | chat :95 | 2/4/2 — 1.0,1.0,3.0 |
| | refactor :96 | 4/4/4 — 2.5,2.0,1.0 |
| | explain :97 | 2/3/1 — 1.0,1.0,3.0 |
| | test_gen :98 | 3/3/3 — 1.5,3.0,1.0 |
| | multi_file :99 | 5/4/5 — 3.0,1.0,1.0 |
| | diff_review :100 | 4/4/4 — 2.0,2.0,1.5 |
| ai_vector_search | embed_api :103 | 3/3/4 — 1.5,3.0,1.0 |
| | search_api :104 | 3/3/4 — 1.0,3.0,1.0 |
| | filter :105 | 3/3/3 — 1.0,2.0,2.0 |
| | dashboard :106 | 2/2/2 — 1.0,1.0,3.0 |
| | scaling :107 | 5/3/5 — 1.0,3.5,0.5 |
| | sdk :108 | 2/3/3 — 1.0,1.5,3.0 |
| saas_project_mgmt | tasks :111 | 2/4/2 — 0.5,1.5,3.0 |
| | gantt :112 | 3/3/2 — 1.0,1.0,2.5 |
| | comments :113 | 2/3/2 — 0.5,1.0,2.5 |
| | integrations :114 | 4/4/4 — 1.0,3.0,1.5 |
| | automation :115 | 4/4/3 — 2.5,1.5,2.0 |
| | reporting :116 | 3/3/2 — 1.0,1.5,2.5 |
| saas_crm | contacts :119 | 2/3/3 — 0.5,2.0,2.5 |
| | pipeline :120 | 3/4/3 — 1.0,1.5,3.0 |
| | email :121 | 4/4/5 — 1.0,3.0,1.5 |
| | forecast :122 | 3/3/2 — 2.5,1.0,1.5 |
| | mobile :123 | 4/4/3 — 1.5,1.5,3.0 |
| | call_log :124 | 3/3/3 — 2.5,1.5,1.5 |
| saas_analytics | dashboards :127 | 3/4/3 — 1.0,1.5,3.0 |
| | query :128 | 4/4/3 — 1.5,2.0,2.5 |
| | alerts :129 | 3/3/3 — 2.0,2.0,1.5 |
| | share :130 | 2/3/3 — 1.0,1.5,2.5 |
| | etl :131 | 5/4/5 — 1.0,3.5,1.0 |
| | embed :132 | 4/4/4 — 2.5,2.0,1.5 |
| saas_billing | subscriptions :135 | 3/3/4 — 0.5,3.0,1.5 |
| | invoice :136 | 2/3/3 — 0.5,2.0,2.0 |
| | tax :137 | 5/2/5 — 0.5,4.0,0.5 |
| | dunning :138 | 3/3/4 — 1.5,3.0,1.0 |
| | webhooks :139 | 3/3/4 — 1.0,3.0,1.0 |
| | proration :140 | 4/2/5 — 0.5,3.5,1.0 |
| saas_dev_tools | cli :143 | 2/3/2 — 1.0,1.5,3.0 |
| | api :144 | 3/4/5 — 1.0,3.0,1.5 |
| | docs :145 | 3/4/3 — 1.0,1.0,3.0 |
| | ci_plugin :146 | 4/3/4 — 1.5,3.0,1.5 |
| | logs :147 | 3/3/3 — 1.5,2.5,1.5 |
| | sandbox :148 | 3/3/3 — 1.5,2.5,2.0 |
| saas_ops | workflow :151 | 4/4/3 — 2.5,1.5,2.0 |
| | reporting :152 | 3/3/2 — 1.0,1.5,3.0 |
| | integration :153 | 5/4/5 — 1.0,3.5,1.0 |
| | scheduling :154 | 3/4/3 — 1.0,2.0,2.5 |
| | field :155 | 5/4/5 — 2.0,3.0,1.5 |
| | mobile :156 | 4/4/3 — 1.5,1.5,3.0 |

Per-type quality-axis market weights (QUALITY_AXES :168-221; **inno / stab / usab**, renamed labels noted):

- ai_assistant :170 — 1.4 / 0.7 / 1.3
- ai_photo_editor :175 — 1.3 / 0.6 / 1.4
- ai_code_copilot :180 — 1.0 / 1.4 / 0.9 (usab → "Editör Akışı")
- ai_vector_search :185 — 0.8 / 1.6 / 0.9 (stab → "Veri Güvenliği & Ölçek", usab → "Entegrasyon Kolaylığı")
- saas_project_mgmt :191 — 0.8 / 1.1 / 1.3
- saas_crm :196 — 0.8 / 1.2 / 1.2
- saas_analytics :201 — 1.1 / 1.2 / 0.9
- saas_billing :206 — 0.7 / 1.6 / 0.9 (stab → "Doğruluk & Güvenlik")
- saas_dev_tools :211 — 1.1 / 1.4 / 0.9 (usab → "Entegrasyon Kolaylığı")
- saas_ops :216 — 0.9 / 1.5 / 1.1 (stab → "Saha Güvenilirliği")

Display-only inline values (product_tab.gd): feature contribution card scale ×2.0 [INLINE] :821; "traction ready" chip = `phase >= 2` :1344; pricing slider max = `max(optimal×3, floor+4)` [INLINE] :1933 (static fallback max 100 :2012).

HR: **no build-speed/productivity modifier exists** — dev throughput = ProductSystem capacity only; HR contributes just baseline morale drift **±1/day toward 50**, dead-band ±1 — scripts/systems/hr_system.gd:31-36.

---

## §3 Revenue / customers

### B2C — scripts/systems/sales_system.gd

Base:
- `B2C_PRICE_DEFAULT = 15` — :23 — $/user/mo fallback when paid tier opens.
- `SATISFACTION_QUALITY_GATE = 70` — :26 — effective-stability axis ≥ 70 → B2C satisfaction +1/day.
- `SATISFACTION_BUG_GATE = 5` — :27 — live bugs > 5 → −1/day (drift ±1/day total — :283-297).
- `TRACTION_MRR_TARGET = 5000` / `TRACTION_CUSTOMER_TARGET = 8` — :29-30 — **display-only** progress bar now (`traction_progress = clamp(max(mrr/5000, customers/8),0,1)` :306-309); the real gate lives in PhaseGateSystem (§4).

Hourly audience flow (bidirectional; MRR derives from audience):
- `HOURLY_AUD_BASE = 0.08` — :39 — base growth/hour.
- `HOURLY_AUD_QUALITY_COEF = 0.006` — :40 — per rival-relative quality point.
- `HOURLY_AUD_BRAND_COEF = 0.004` — :41 — per brand point.
- `HOURLY_AUD_REPUTATION_COEF = 0.01` — :42 — per raw reputation point (−10..100).
- `HOURLY_AUD_BUG_COEF = 0.03` — :43 — **[DEAD]** (bugs flow via effective stability now).
- Growth formula — :147-151; × price multiplier; minus churn term.
- `RIVAL_RELATIVE = true` — :48 — quality term recentered vs startup-league rival average: `clamp(50 + (player_nq − startup_avg), 0, 100)` — :168-180.

Erosion / churn:
- `CHURN_COEF = 0.0002` — :59 — per-audience-member rate.
- `EROSION_THRESHOLD = 42.0` — :60 — churn = `0.0002 × max(0, 42 − quality_term) × audience` — :158.

Value algorithm (worth → optimal price):
- `VALUE_BASE = 4.0` — :66; `VALUE_QUALITY_COEF = 0.12` — :67; `VALUE_FEATURE_COEF = 1.2` — :68; `VALUE_COMPLEXITY_COEF = 0.6` — :69; `VALUE_BUG_COEF = 0.5` — :70 **[DEAD]**; `VALUE_FLOOR_RATIO = 0.5` — :71; `TENDENCY_MULT = {premium 1.35, neutral 1.0, volume 0.8}` — :72.
- `optimal = round(max(1, 4 + nq×0.12 + features×1.2 + complexity×0.6) × tendency_mult)` — :330-335.

Conversion / hike / price sensitivity:
- `CONVERSION_BASE = 0.35` (at optimal), `CONVERSION_MIN = 0.02`, `CONVERSION_MAX = 0.60` — :76-78; `rate = clamp(0.35 × optimal/price, …)` — :379-384. Paying = `round(audience × rate)`; MRR = paying × price — :185-193.
- Hike churn: `clamp(raise_ratio×0.6 + above_optimal×0.5, 0, CHURN_MAX=0.45)` — :387-395 — the **0.6 / 0.5** are [INLINE]; `CHURN_MAX` :81.
- Audience price multiplier: `clamp(optimal/price, AUD_PRICE_MULT_MIN=0.4, AUD_PRICE_MULT_MAX=1.8)` — :85-86, :398-403.
- B2C aggregate record's satisfaction seeds from the usability axis — :201.
- `growth_band` verbal thresholds [INLINE]: ≤ −0.1 "eriyor" · < 0.15 "duruyor" · ≥ 0.6 "hızlı büyüyor" — :463-473.
- Initial B2B seats live in this file [INLINE match]: enterprise **40** / mid **12** / else **4** — :274-278.

### B2B constants — scripts/systems/b2b_constants.gd

Stage A (lifecycle):
- `ONBOARDING_DAYS = 30` — :9 — first-impressions window after signing.
- `RISK_TRIGGER_DAYS = 3` — :10 — consecutive days under tolerance → Risk phase.
- `CHURN_COUNTDOWN_DAYS = 7` — :11 — visible "Churn'e ~N gün" counter length.
- `EXPANSION_MATURE_DAYS = 45` — :12 — active + this old → expansion-eligible.
- `SAT_DRIFT_STEP = 3` — :13 — max satisfaction move/day toward the product-health target.
- `ONBOARDING_AMP = 1.5` — :14 — onboarding swing amplifier (ceil(3×1.5) = 5/day).
- `RIVAL_SATISFACTION_HOOK = false` — :15 — OFF (no rival system).
- `SCALE_DEMO_MAX = 3` — :16 — demo caps scale; 4-5 gated behind `b2b_high_scale_unlocked`.
- Tolerance seed = `clamp(TOLERANCE_BASE 35 + (scale−1)×TOLERANCE_PER_SCALE 5 + sector_bonus, 0, 100)` — :18-19, :26-30.
- `SECTOR_TOLERANCE_BONUS = {İnşaat 5, Sağlık 5, Sigorta 3}` — :21-23.
- `support_load = clamp(scale, 1, 5)` — :33-35; `roll_scale` bases: enterprise **5** / mid **3** / else **2** — :38-48.

Stage B (retention):
- `COMPLAINT_BUG_GATE = 6` — :52 — live bugs above → product-complaint family eligible.
- `RIVAL_LURE_ENABLED = false` — :53 — OFF.
- `RETAIN_DELAY_MAX_USES = 2` — :54 — "Oyala" works twice, then ignored (b2b_sales_system.gd:198-199).
- `RETAIN_DELAY_DAYS = 3` — :55 — countdown pushed out per stall.
- `RETAIN_DISCOUNT_PCT = 0.15` — :56 — "İndirim ver" MRR cut fraction.
- `RETAIN_SAT_BUMP = 8` — :57 — relief from a discount/promise; **halved (int/2 = 4) if a prior promise to that customer was broken** — b2b_sales_system.gd:186-189.
- Brand/rep riders: `RETAIN_PROMISE_REP = 1` :59 · `RETAIN_DELAY_BRAND = −1` :60 · `RETAIN_DISCOUNT_REP = −1` :61 · `CHURN_BRAND = −2` :62 (applied at the actual churn moment — b2b_sales_system.gd:163).

Stage C (promises):
- `PROMISE_DEADLINE_DAYS = 14` — :169 (event-modifier default also 14 — event_manager.gd:547/:556).
- `PROMISE_KEPT_SAT = +15` :170 · `PROMISE_KEPT_TOLERANCE = +5` :171 · `PROMISE_BROKEN_SAT = −20` :172 · `PROMISE_BROKEN_TOLERANCE = −5` :173 · `PROMISE_BROKEN_BRAND = −3` :174 · `PROMISE_PARTIAL_SAT = −5` (late ship) :175 — applied at b2b_sales_system.gd:290-311.
- Promise clock: deadline = `day + max(days,1)` — scripts/autoload/promise_registry.gd:57; kept if shipped `day ≤ deadline` else partial — :83; open past deadline breaks — :91.

Stage D (Customer Success):
- `cs_capacity(skill) = CS_BASE_CAPACITY 3 + floor(skill / CS_SKILL_PER_SLOT 25)` — :179-180, :188-190.
- `FOUNDER_DIRECT_CAP = 4` — :181 — founder-managed accounts before the delegation prompt.
- `CS_ESCALATION_SAT = 35` — :182 — CS-managed account below → one escalation (re-arms on recovery — b2b_sales_system.gd:98-107).
- `cs_dampen(skill) = clamp(1 − skill/200, CS_DAMPEN_MIN 0.4, 1.0)` — :183, :193-195 — the **200** is [INLINE]. Applied to downward drift only (b2b_sales_system.gd:49-50).
- `CS_REFUSE_BRAND = 3` (drop) :184 · `CS_REFUSE_MORALE = 10` (drop) :185.

Stage E (2nd product / prospects / expansion):
- `SECTOR_AFFINITY` — :202-205 — ai_vector_search → [Teknoloji, E-ticaret, Medya, Finans]; saas_ops → [İnşaat, Lojistik, Sağlık, Sigorta, Üretim]; 8-sector fallback :206.
- Prospect value band = archetype band-mid × `VALUE_BAND_LOW_FRAC 0.65` / `VALUE_BAND_HIGH_FRAC 1.15` — :211-212 (applied pitch_system.gd:75-78).
- `EXPANSION_SEATS = {small 3, mid 6, enterprise 12}` — :215; `EXPANSION_PER_SEAT_MRR = 120` — :216 — upsell adds seats × $120 MRR + support_load +1 (b2b_sales_system.gd:246-258).

### B2B pitch / prospect generation — scripts/systems/pitch_system.gd + sales_tab

- `PITCH_COOLDOWN_DAYS = 2` — :17 — between pitches (set at :270, outcome-independent).
- **`MRR_BANDS`** — :22-26 — per-customer signed-MRR bands: small **200-500** · mid **800-2000** · enterprise **3000-8000**. Signed MRR = `lerp(low, high, price_mult) × mrr_mult` — :286-288.
- Archetype difficulty stars: enterprise **4** / mid **2** / else **1** — :85-89; budget band high/mid/low — :92-96.
- Value-premium position = `clamp((optimal − 4.0) / 24.0, 0, 1)` — :101-105 — **[INLINE][DIVERGENCE]** re-encodes `SalesSystem.VALUE_BASE` (4.0) plus a magic 24.0 span.
- Recommended price window = value position **±0.18** [INLINE] — :108-111; off-window price shifts close difficulty ±1 — :246-250.
- Stage numbers: intro approach bonuses 1/0/1 — :171-173; value-stage diffs base/+1/−1 — :184-186 (pass → bonus +2, fail → −1 — :238); pricing `price_mult` 1.0/0.55/0.2 with close_diff +2/0/−1 — :198-200 (default 0.55 — :45); close choices diff 0/−1/+1 with `mrr_mult` 1.0/0.9/1.1 — :212-214.
- Close check: `SkillCheck.resolve("sales", CLOSE_BASE_DIFFICULTY 1 + close_diff_delta + difficulty_stars − 1, bonus)` — :19, :252-253.
- Outcome map: crit/success → SIGNED; near_pass → SIGNED with `mrr_mult ×= 0.85`; near_miss → CALLBACK (prospect stays); else LOST — :272-281.
- B2B initial satisfaction seed = `round((stability + usability)/2)` (effective dims), +5 on crit — :266-268, :289.
- Prospect determinism: `n = day×7 + count×13` [INLINE] — :54 — picks industry/company/pain deterministically.
- **`FIND_PROSPECTS_COOLDOWN_DAYS = 5`** — scripts/tabs/sales_tab.gd:13; `FIND_PROSPECTS_COUNT = 2` — :14; archetype mix `"mid" if (day+i) % 3 == 0 else "small"` [INLINE] — :363 (enterprise never spawns via Find).

### Data-model defaults

- Customer: `satisfaction = 70` — scripts/data_models/customer.gd:35; `scale = 1` :45; `tolerance = 50` (HIDDEN; overwritten by seed at signing) :46; `churn_countdown = −1` :47; `support_load = 1` :50. Health bands: ≥60 healthy / ≥30 at_risk / else churning — :66-72.
- Prospect: `archetype = "small"` — scripts/data_models/prospect.gd:16; `scale = 1` :17; `difficulty_stars = 1` :21; value bands 0 until set :24-25.
- `CustomerRegistry.DEBUG_SEED = false` — scripts/autoload/customer_registry.gd:24 — Nordica/Palmiye/Beykoz test customers off in normal runs.

---

## §4 Traction & phase gates

Single gate table `GATES` — scripts/systems/phase_gate_system.gd:27-58; conditions evaluated by `EventManager.is_condition_met` daily (slot 8); **one branch serves both B2C and B2B** (kills the old B2C-only `_check_traction` bug — comment :14-16; removal confirmed at sales_system.gd:300-304).

Bootstrap (1) → Traction (2) — :28-42, event `ev_phase_gate_traction`:
- `mvp_shipped = true` — :32 — first product shipped.
- `customer_count_min = 1` — :33 — ≥1 real customer (B2C aggregate record counts).
- `mrr_above = 0` — :34 — MRR strictly > 0.
- No cash/brand/runway condition on this gate.

Traction (2) → Series A Hunt (3) — :43-56, event `ev_phase_gate_series_a`:
- `mrr_above = 4999` — :47 — i.e. **MRR ≥ 5000** (comment ties to SalesSystem.TRACTION_MRR_TARGET).
- `brand_above = 24` — :48 — i.e. **brand ≥ 25** (working floor).
- Runway deliberately NOT a condition — :49 — low runway feeds pitch odds instead (deadlock avoidance).

Phase 3 has **no exit gate** — :57 — run resolves only through EndingsSystem terminals.

Mechanics:
- `REMIND_INTERVAL_DAYS = 5` — :23 — Frank re-prompt cadence once a gate latches (`gate_prompt_day` flag :86, re-armed on decline :113-114).
- Ratchet: once open, conditions never re-checked — :70-72; latch = `phase_gate_ready` + `pending_next_phase` (game_state.gd:48-49).
- Transition is played: `advance_phase()` — game_state.gd:154-167 — the single gameplay phase-write seam; forward-only; month-highlight priority **80** [INLINE] :166. Gate-open highlight priority **70** [INLINE] — phase_gate_system.gd:89.
- Gate scene held while the Kepenk runs — :93-94, :101-102 (§7.4 interplay).

**[DIVERGENCE] the "5000 MRR" bar has FOUR independent homes:** phase_gate_system.gd:47 (4999 → ≥5000, the real gate) · sales_system.gd:29 (TRACTION_MRR_TARGET, display bar) · pitch_constants.gd:17 (SEED_MRR_REFERENCE, conviction seeding) · endings_system.gd:25 (BOOTSTRAP_WIN_MRR, Day-180 win). No shared constant; `PIVOT_MRR_MIN = 2000` (endings_system.gd:24) is a fifth, separate MRR floor.

---

## §5 Time & speed

### Tick engine — scripts/autoload/time_manager.gd

- `SPEED_MULTIPLIERS = [0.0, 1.0, 2.0, 4.0]` — :37 — pause/1x/2x/4x.
- `HOURS_PER_DAY = 24` — :38; `INITIAL_HOUR = 9` — :39 — Day 1 starts 09:00 (first day = 15 in-game hours).
- Accumulator: `_in_game_hours += multiplier × delta` — :74 — **1x: 1 real second = 1 in-game hour** (no separate SECONDS_PER_HOUR const; implicitly 1.0).
- Default speed 1x — :41; pause = speed 0 → `get_tree().paused` — :132; dead run can't unpause — :124-128.

### Measured tempo (instrumented headless run, 2026-07-17 — real wall clock, full system dispatch live)

| Speed | measured ms/in-game-hour | measured real s/day | derived (code) |
|---|---|---|---|
| 1x | 982.4 | 23.58 | 24.0 |
| 2x | 500.1 | 12.00 | 12.0 |
| 4x | 250.1 | 6.00 | 6.0 (pure-4x day boundary measured 5996-6000 ms) |

Measurement matches derivation (1x sample's −0.4s is first-frame noise). At these rates a 180-day run = **72 min at 1x / 36 min at 2x / 18 min at 4x** of pure clock time.

### Run length

- `RUN_END_DAY = 180` — scripts/systems/endings_system.gd:20 — the only encode of the hard wall (Day-180 fork).
- `DAY180_WARN_DAY = 179` — scripts/systems/pitch_constants.gd:81 — Frank "yarın son gün" warning (vc_pitch_system.gd:458-462).
- `GameState.day` is unbounded (advance_day :131-133); nothing else knows about 180. Calendar anchor `START_DATE = {2026,1,1}` — game_state.gd:12.

### Tick responsibilities

Daily dispatch order (time_manager.gd:146-164; order is load-bearing — endings last): 1 Product :153 · 2 RnD (TODO) :154 · 3 HR :155 · 4 Sales (satisfaction + B2B lifecycle + MRR bridge) :156 · 5 Rivals :157 · 6 Finance (burn/revenue/cash) :158 · 7 Events (beats) :159 · industry (TODO) :160 · 8 PhaseGate :161 · 8b VCPitch :162 · 9 Endings :163 · 10 MonthSummary :164. Debug tempo print (Δms between daily ticks) — :166-170.

Hourly dispatch (time_manager.gd:175-183): Product (build growth/bugs, post-ship wear) :180 · Sales (B2C audience + derived MRR) :181 · Events (ambient pool + windows) :182 · schedule (TODO) :183. Day rollover order: hour-0 hourly tick → advance_day → daily tick — :100-105.

### allowed_hours windows in use

Parser: `[start, end]` inclusive; start > end wraps midnight — event_manager.gd:643-650. Windows in data/events/reactive/: dev_001 [1,4] · dev_003 [6,9] · iter_002 [8,11] · bugfix_002 [9,12] · bug_complaint [9,18] · referral_b2b [9,17] · dev_002 [13,17] · iter_003 [16,20] · power_user [18,22] · bugfix_001 [18,23] · producthunt [20,23] · bugfix_003 [21,1] (wraps) · iter_001 [22,2] (wraps). 13 of 16 live events are windowed.

---

## §6 Events

### Pool & trigger machinery

- Live reactive pool = **16 events** (loader confirmed: "[EventManager] Loaded 16 events"); the 3 `ev_debug_*` files are fixtures explicitly skipped — event_manager.gd:616-617. `data/events/industry/` and `data/events/scandals/` are **empty** (.gitkeep only) — no industry-event schedule exists.
- Ambient throttle: **≤1 random-trigger event enters the queue per day** — event_manager.gd:47, :91-106.
- Chance normalization: JSON `chance` means per-DAY probability; each in-window hourly roll uses `chance / window_length_hours` (24 if unwindowed) — :86-99.
- Beats (no random trigger) fire on the daily path the moment conditions hold, no cap — :56-73.
- Modifier defaults [INLINE]: add_prospect archetype "small" :466 · B2C churn_customer erodes **15% of audience** :474-475 · open_paid_tier price 15 / initial_pct 0.1 :508 · b2b promise deadline default 14d :547/:556.

### Per-event calibration (16 live; trigger → cooldown/priority → choice effects)

1. `ev_ps_power_user_b2c` — b2c, customer≥1, audience>40, random **0.30**; hours [18,22]; cd 12; pri 0. C1: brand **+4**, audience **+25**, cash **−600**. C2: audience **+5**.
2. `ev_ps_b2c_producthunt` — b2c, flag paid_tier, audience>30, random **0.40**; [20,23]; cd 10; pri 1. C1: convert_audience **pct 0.25**, brand **+3**, audience **+20**, cash **−800**. C2: audience **+6**.
3. `ev_ps_frank_intro_b2b` — beat: mvp_shipped, b2b; one_shot; pri 5. C1: add_prospect (mid) + mentor_advisory (no economic delta).
4. `ev_ps_first_revenue` — beat: mrr>0; one_shot; pri 8. Advisory only.
5. `ev_ps_b2c_paid_tier` — beat: b2c, audience>15; one_shot; pri 6. Advisory only (opens pricing decision).
6. `ev_ps_referral_b2b` — b2b, customer≥1, random **0.30**; [9,17]; cd 12; pri 1. C1: add_prospect (mid), cash **−400**. C2: add_prospect (small). C3: reputation **+2**.
7. `ev_ps_bug_complaint` — b2c, customer≥1, satisfaction<60, random **0.50**; [9,18]; cd 8; pri 2. C1: cash **−1500**, satisfaction **+20**. C2: satisfaction **+8**, cash **−300**. C3: churn_customer (−15% audience), brand **−2**.
8. `ev_mvp_dev_001_integration_broken` — dev phase, random **0.30**; [1,4]; cd 14; one_shot. C1: stability **+6**, delay **+1**. C2: delay **−2**, bug **+2**, set tech_debt.
9. `ev_mvp_dev_002_tech_debt_callout` — dev, flag tech_debt, random **0.25**; [13,17]; cd 16; one_shot. C1: stability **+6**, delay **+2**, clear flag. C2: delay **−1**, bug **+2**, set flag.
10. `ev_mvp_dev_003_solo_dev_fatigue` — dev, random **0.20**; [6,9]; cd 20; one_shot. C1: delay **+1**, stability **+2**. C2: delay **−1**, bug **+2**.
11. `ev_mvp_bugfix_001_critical_bug` — bugfix, random **0.40**; [18,23]; cd 14; one_shot; pri 1. C1: bug **−6**, stability **+4**, cash **−150**. C2: set critical_bug_unfixed (→ +5 bugs at launch), brand **−2**.
12. `ev_mvp_bugfix_002_early_launch_pressure` — bugfix, random **0.30**; [9,12]; cd 15; one_shot. C1: bug **−4**, stability **+2**, cash **−100**. C2: brand **−1**.
13. `ev_mvp_bugfix_003_final_polish` — bugfix, random **0.25**; [21,1]; cd 12; one_shot. C1: usability **+5**, cash **−80**. C2: usability **−2**, bug **+1**.
14. `ev_mvp_iter_001_scope_creep` — iteration, random **0.35**; [22,2]; cd 12; one_shot. C1: usability **+6**, delay **+2**. C2: delay **−1**, bug **+3**.
15. `ev_mvp_iter_002_competitor_signal` — iteration, random **0.25**; [8,11]; cd 21; one_shot. C1: innovation **+5**, delay **+2**. C2: brand **+2**, innovation **−2**.
16. `ev_mvp_iter_003_early_user_feedback` — iteration, random **0.25**; [16,20]; cd 18; one_shot. C1: usability **+6**, delay **+2**, cash **−100**. C2: delay **−1**, brand **+1**, usability **−2**.

### Magnitude ranges across the live pool

- **Cash** (9 deltas, ALL outflows): −1500 … −80, median **−300**. No positive cash exists in the live pool (the +5000 rescue is debug-only).
- **Brand** (7): −2 … +4, median +1.
- **MRR**: no direct `mrr` modifier anywhere (Economy Model v2 — MRR is derived). B2C driver = audience deltas: +5/+6/+20/+25 (median 13) + one `convert_audience pct 0.25`.
- **Morale**: none in the live pool (debug-only).
- **Satisfaction**: +8 / +20 (bug_complaint) + one churn. **Reputation**: +2 (once).
- Build deltas: stability {+2,+4,+6} · usability {−2,+5,+6} · innovation {−2,+5} · bug {−6,−4,+1,+2,+3} · delay_days {−2,−1,+1,+2}.

Excluded debug fixtures (never loaded): ev_debug_001 (morale ±, cash −2000/−8000), ev_debug_002 (brand ±), ev_debug_003 (cash_below 30000 → cash **+5000**).

---

## §7 Endgame / pitch / term sheet

### Kepenk (shutter) + endings — scripts/systems/endings_system.gd

- `SHUTTER_DAYS = 7` — :19 — countdown; starts when `cash < 0` (:108-115), decrements each negative day, 0 → bankruptcy (:120-123); cash ≥ 0 fully resets (:124-127). Highlight priority **90** [INLINE] :116.
- `RUN_END_DAY = 180` — :20 — Day-180 fork (§5).
- `BRAND_COLLAPSE_FLOOR = 15` / `BRAND_COLLAPSE_WINDOW = 30` — :21-22 — brand < 15 for 30 days with `active_scandal` → loss (:133-145); `active_scandal` is RESERVED (no scandal system) → ending is debug-only today.
- `CASCADE_TABLES = 3` — :23 — closed tables → cascade. **[DIVERGENCE]** also defined at pitch_constants.gd:76 (UI label "Kapanan masa: N/3"); endings owns the real gate.
- `PIVOT_MRR_MIN = 2000` — :24 — metrics-alive floor: at 3 rejections with `mrr ≥ 2000 and cash > 0` Frank offers the pivot instead of the loss (:165-172); pivot closes VC path permanently (:175-183). Cascade defers while any sheet/meeting is live (:156-157).
- `BOOTSTRAP_WIN_MRR = 5000` — :25 — Day-180 WIN branch needs: never cash-negative AND full 90-day buffer with `net_sum > 0` AND no unmanaged scandal AND `mrr ≥ 5000` (:196-208) → profitable_bootstrap; else running_on_fumes.
- `NET_WINDOW = 90` — :26 — daily-net ring buffer length (:92-96).
- 7 endings (ENDINGS :30-66): series_a_close (win) · acquisition (soft_win) · bankruptcy (loss) · brand_collapse (loss) · vc_rejection_cascade (loss) · profitable_bootstrap (win) · running_on_fumes (soft_loss). Daily scan priority: series_a → shutter → brand → cascade → day180 → acquisition-offer (:69-87).
- Acquisition offer (non-terminal) [INLINE thresholds]: `phase == 3` AND `30 ≤ brand ≤ 50` AND `vc_rejections ≥ 1`, once — :213-224 (highlight 90 :223).

### Conviction zones & seeding — scripts/systems/pitch_constants.gd

- `ZONE_BOUNDS = [40, 70]` / `ILIK_MIN = 40` / `WON_MIN = 70` — :11-13 — Soğuk 0-39 / Ilık 40-69 / Kazanıldı 70-100. Won grants sheet; <40 cold RET; Ilık forks callback-vs-force (vc_pitch_system.gd:540-561). **[DIVERGENCE/INLINE]** `[40, 70]` re-hardcoded as fallback in scripts/ui/components/conviction_track.gd:16/:24/:26 and scripts/modals/meeting_scene.gd:63/:183/:209; the canonical path passes `PitchConstants.ZONE_BOUNDS` (vc_pitch_system.gd:489).
- Seeding (applied vc_pitch_system.gd:97-142): `SEED_BASE = 20` :16 · `SEED_MRR_REFERENCE = 5000` :17 with `SEED_MRR_MAX_BONUS = 20` :18 (delta = `(clamp(mrr/5000,0,1.5) − 0.5) × 20` — :103-105) · `SEED_BRAND_FLOOR = 50` :19 with `SEED_BRAND_MAX = ±12` :20 (delta = `(brand − 50) × 0.4` clamped — the **0.4** is [INLINE] :109) · `SEED_SHUTTER_PENALTY = −15` :21 · `SEED_THIN_RUNWAY_PENALTY = −8` :22 (trigger: gross runway < **1.0** month [INLINE] :117) · `SEED_SCANDAL_PENALTY = −12` :23 · `SEED_LEVERAGE_BONUS = +15` :24 · `SEED_WARM_INTRO_BONUS = +12` :25 (Bosphorus) · `SEED_DIMENSION_MATCH_BONUS = +8` :26 (Meridian × mvp_shipped) · `SEED_CALLBACK_BONUS = +10` :27.

### Meeting beats — pitch_constants.gd

- Difficulty ints: `DIFF_KOLAY 1 / DIFF_ORTA 2 / DIFF_ZORLU 3 / DIFF_CETIN 3` — :30-33.
- Beat 2 Anlatı: success **+15..+25** (near_pass..crit — :36-37), fail **−5** :38.
- Beat 3 Sorgu: Dürüst **+20/−8** diff ORTA :41-43 · Spin **+28/−15** diff ZORLU :44-46 · Geçiştir **+5/−5** diff KOLAY with `GECISTIR_CAP = 65` (deflection can never win the room) :47-50.
- Beat 1 diff ORTA :53; "Masayı zorla" diff ZORLU (fail = hard RET) :54.
- Skill routing: BEAT1/BEAT3/BEAT4 = "influence" :59-61; `ANGLE_SKILL {vizyon: influence}`, fallback "sales" :62.
- Prep: `MEETING_LEAD_DAYS = 3` :65 · `PREP_DAYS = 2` :66 · `PREP_MIN_DAYS_BEFORE = 2` :67 · `PREP_BONUS = 2` SkillCheck units (≈ +20pp on the focused angle — vc_pitch_system.gd:662-667) :68.
- Callbacks: `CALLBACK_MRR_GROWTH_PCT = 20` :77 (target = meeting-day MRR × 1.20 — vc_pitch_system.gd:273) · `CALLBACK_BUGS_UNDER = 3` :78. By domain: metrics→mrr_growth · product→bugs_under · team→first_engineer(1) · else→scandal_resolved — vc_pitch_system.gd:270-276; met check :691-697.

### Sheet economy & the table

- `SHEET_VALIDITY_DAYS = 14` — pitch_constants.gd:71 — expiry = granted_day + 14 (scripts/data_models/term_sheet.gd:16, vc_pitch_system.gd:256); expiry is NOT a rejection (:395-399).
- `MAX_SHEETS = 2` — :72 — 3rd win becomes delayed delivery (vc_pitch_system.gd:238-248, delivered when a slot frees :404-414).
- `WARNING_DAYS = 3` — :73 — expiry-warning event + TopBar countdown chip (vc_pitch_system.gd:400-401, :451-455).
- Levers: `LEVER_SKILL {valuation: sales, dilution: negotiation, board: influence}` — :87; `LEVER_DIFF {0, 1, 2}` — :91.
- Push steps: `VAL_STEP = +$4M` :93 · `DIL_STEP = −4pp` :94 · `DIL_FLOOR = 10%` :95 · board = fixed sequence veto-then-seat (term_sheet_table_system.gd:275-286).
- `PUSH_DECAY = 0.12` — :98 — −12pp per prior push to that lever (counts every attempt); `PUSH_ODDS_FLOOR = 0.05` — :99. Odds composed at term_sheet_table_system.gd:147-156.
- Leverage (second live sheet): `LEVERAGE_BONUS_UNITS = 1` (= +10pp on ALL pushes) :101 · `LEVERAGE_OPEN_NOTCH = +$4M` opening valuation :102 (applied term_sheet_table_system.gd:58-60) · derived, never stored (term_sheet.gd:35-39).
- Money raised = `valuation_m × 1,000,000 × dilution_pct / 100` — term_sheet_table_system.gd:135-138 (same math vc_pitch_system.gd:308).
- `DIAL_SPIN_SECS = 0.8` — :104 — push-roll presentation.
- Patience: pool copied from the VC at grant (vc_pitch_system.gd:258); one pip lost per failed push; zero locks pushing (term_sheet_table_system.gd:106-112).

### SkillCheck odds — scripts/systems/skill_check.gd

- `chance = clamp(BASE_CHANCE 0.45 + skill×SKILL_STEP 0.15 + bonus×BONUS_STEP 0.10 − difficulty×DIFFICULTY_STEP 0.15, MIN 0.05, MAX 0.95)` — :14-19, :23-27.
- Result bands: crit_success margin ≥ +0.40 · success ≥ +0.15 · near_pass; crit_fail ≤ −0.40 · fail ≤ −0.15 · near_miss — :85-96.
- `SALES_READ_THRESHOLD = 2` — :20 — Satış ≥ 2 reveals prospect budget/real-need (:99-101).
- Per-lever table base odds (difficulty folded into "temel" — :33-45): valuation **45%** · dilution **30%** · board **15%**; +15pp per skill point, +10pp leverage, −12pp per prior push, floor 5%.

### Investor archetypes — scripts/autoload/investor_registry.gd (weights = Beat-2 angle → diff; lowest = favored angle, revealed by Beat-1 success :129-138)

| VC | domain | weights (metrik/vizyon/traction) | interrogation | patience | opening terms | warm_intro |
|---|---|---|---|---|---|---|
| Anchor Capital :18-33 | metrics | **1**/3/2 | mid | **3** :27 | **$18M / 22% / 1 seat + veto** :29 | no |
| Nexus Ventures :34-49 | team | 2/2/**1** | mid | **4** :43 | **$10M / 15% / clean board** :45 | no |
| Bosphorus Partners :50-65 | narrative | 3/**1**/2 | soft | **2** :59 | **$14M / 18% / 1 seat, no veto** :61 | **yes** :62 (+12 seed) |
| Meridian Growth :66-81 | product | **1**/3/2 | hard | **2** :75 | **$16M / 18% / 0 seats** :77 | no |
| locked_tier2 :83-99 | — | — | — | 0 | — | teaser only, excluded from roster (:117-122) |

Weakest-dimension "weak" floor = raw axis < **40.0** [INLINE] — vc_pitch_system.gd:700-708; B2B concentration proxy = one customer > **50%** of MRR [INLINE] — :711-719.

---

## §8 Founder

### Allocation & caps — scripts/systems/founder_constants.gd

- `SKILLS = [tech, sales, negotiation, leadership, influence]` — :19 (OLD_SKILLS tripwire :20 — renamed keys push_error at game_state.gd:230-231).
- `POINT_POOL = 6` — :23 — onboarding points, all must be spent (Erdem 2026-07-16: 8 over-equipped the early game).
- `ONBOARDING_CAP = 3` — :26 — per-skill max at creation.
- `SKILL_CEILING = 5` — :27 — underlying max; 4-5 only via unbuilt HR training; at 5 the SkillCheck clamp (0.95) caps anyway.
- `TRAIT_MAX_POSITIVE = 2` / `TRAIT_MAX_NEGATIVE = 1` — :33-34 — Software-Inc formula: 2 positives force exactly 1 negative.
- **[DIVERGENCE — stale comment]** scripts/onboarding/steps/origin_traits_step.gd:9 still says "8 points across 5 skills"; the code reads POINT_POOL = 6 correctly.

### Traits — ALL UNWIRED

`TRAITS` — founder_constants.gd:39-48 — positive: visionary, disciplined, networker, resilient; negative: stubborn, micromanager, risk_blind, lone_wolf. RESERVED: no system consumes trait effects (:37-38 comment; storage only at game_state.gd:362-367). Origin `reserved_flags` equally unconsumed (§1).

### Skill effects currently WIRED (every read + modifier size)

**tech** (3 formulas, all product):
- Dev stability growth: `raw = 1.5 + tech × 0.75`/day — product_system.gd:276-277 (TECH_STAB_COEF :61).
- Dev bug rate: `− tech × 0.005`/hour (floor 0.010) — product_system.gd:304 (:43).
- Post-ship wear: `− tech × 0.005`/hour (floor 0.002) — product_system.gd:334 (:105).

**sales**:
- Every SkillCheck with skill "sales": +15pp/point (skill_check.gd:15).
- Prospect read gate: sales ≥ **2** reveals budget/real-need — skill_check.gd:20, :99-101.
- B2B pitch value stage ("Dürüst ol", "Onun derdine odaklan") and close stage — pitch_system.gd:184/:186, :252.
- VC Beat-2 non-vizyon angles (metrik/traction) — pitch_constants.gd:62 fallback, vc_pitch_system.gd:656-659.
- Term-sheet **valuation** lever — pitch_constants.gd:87.

**negotiation**: term-sheet **dilution** lever — pitch_constants.gd:87. (Sole read.)

**influence**:
- VC Beat 1 "Odayı oku", Beat 3 postures, Beat 4 "Masayı zorla" — pitch_constants.gd:59-61.
- Beat-2 vizyon angle — pitch_constants.gd:62; B2B pitch "Vizyon sat" — pitch_system.gd:185.
- Term-sheet **board** lever — pitch_constants.gd:87.

**leadership**: **UNWIRED — zero mechanical reads.** (Debug founder payload allocates it 0 — main.gd:695.)

Generic: event JSON condition `founder_skill ≥ value` exists in the vocabulary — event_manager.gd (condition evaluator); no live event uses it yet.

---

## Consolidated flag ledger (for the curve redesign's centralization pass)

**Divergences (same concept, multiple homes):**
1. "5000 MRR" bar in 4 files, no shared constant (§4) + separate 2000 pivot floor.
2. `CASCADE_TABLES = 3` twice — endings_system.gd:23 (real) vs pitch_constants.gd:76 (UI).
3. Conviction bounds [40,70] — canonical pitch_constants.gd:11 vs hardcoded fallbacks in conviction_track.gd:16/:24/:26 + meeting_scene.gd:63/:183/:209.
4. Starting burn 50: hand-mirror (game_state.gd:31/:283) vs computed Σ breakdown (finance_system.gd:26-33).
5. Starting cash 10000 in 3 homes (game_state.gd:29/:281, founder_constants.gd:60).
6. Runway in three presentations: NET months + "Kârlı" (game_state.gd:209-214 / ui_tokens.gd:216-219), GROSS months (vc_pitch_system.gd:649-653), GROSS **days** (term_sheet_table_system.gd:346-349).
7. Three money formatters (ui_tokens.gd:196-209 · top_bar.gd:211-219 · top_bar.gd:225-234) with different thresholds.
8. `DAYS_PER_MONTH = 30` twice (game_state.gd:7, finance_system.gd:20) while month boundaries use real calendar months (game_state.gd:238-245).
9. Satisfaction: B2C ±1/day gated model (sales_system.gd:283-297) vs B2B ±3/day drift-to-target with hidden tolerance (b2b_*) — same field, two rate models.
10. "Churn" = three unrelated mechanisms: B2C proportional erosion (CHURN_COEF), B2C hike reaction (churn_fraction), B2B watched countdown.
11. Five independent small/mid/enterprise tables: initial seats 40/12/4 (sales_system.gd:274-278) · expansion seats 3/6/12 (b2b_constants.gd:215) · MRR bands (pitch_system.gd:22-26) · roll_scale 2/3/5 (b2b_constants.gd:38-48) · difficulty 1/2/4 + budget (pitch_system.gd:85-96). No shared archetype registry.
12. `VALUE_BASE 4.0` re-encoded inline in pitch_system.gd:105 (with magic 24.0 span).
13. `PHASE1_AXIS_ASYMPTOTE` flat vs comment promising per-version raise (quality_model.gd:44-45); no v1→v2→v3 gain table exists.
14. Stale comments: origin_traits_step.gd:9 ("8 points"), pitch_system.gd:9-11 header (old "markets/charisma" skill names).

**Dead constants:** `VALUE_BUG_COEF 0.5` (sales_system.gd:70), `HOURLY_AUD_BUG_COEF 0.03` (sales_system.gd:43).

**Notable inline values (not in any constants block):** starting burn/cash literals (game_state.gd:29/:31/:281/:283) · hike churn 0.6/0.5 (sales_system.gd:395) · growth_band bands −0.1/0.15/0.6 (sales_system.gd:467-472) · B2C seats 40/12/4 (sales_system.gd:274-278) · v1 feature cap 2-4 (product_system.gd:580 + product_tab 4s) · Find-Prospects %3 modulo mix (sales_tab.gd:363) · prospect determinism day×7+count×13 (pitch_system.gd:54) · price window ±0.18 (pitch_system.gd:110-111) · cs_dampen /200 (b2b_constants.gd:194) · B2C event-churn 15% (event_manager.gd:475) · brand seed ×0.4 + thin-runway <1.0 (vc_pitch_system.gd:109/:117) · weak-axis floor 40.0 + concentration 50% (vc_pitch_system.gd:708/:717) · acquisition band 30/50 + rejections≥1 (endings_system.gd:216-221) · month-highlight priorities 70/80/90 (phase_gate_system.gd:89, game_state.gd:166, endings_system.gd:116/:223) · contribution display ×2.0 (product_tab.gd:821) · slider max optimal×3 (product_tab.gd:1933).

**Structural absences the curve redesign must add homes for:** no cost/efor field on features or types (product_catalog.gd); no positive-cash event in the live pool; no hire flow (salaries are debug/event-only); no industry-event schedule; leadership skill and all 8 traits unwired.

---

## The 10 values that most control run pacing (one-page summary)

1. **1 real second = 1 in-game hour at 1x** (time_manager.gd:37-39,:74; measured 23.6/12.0/6.0 s/day at 1x/2x/4x). The base clock every other number is felt through: a 180-day run is 72/36/18 minutes of pure clock. Calibration Law 2 (≤60-90s between decisions) is arithmetic against this value.
2. **`RUN_END_DAY = 180`** (endings_system.gd:20). The wall the whole economy curve is stretched across; the pending 1-2yr extension changes this one number and every slope below must re-tune against it.
3. **Starting cash 10000 + burn 50/day** (founder_constants.gd:60, finance_system.gd:26-33). The opening pressure clock: exactly ~200 days of gross runway — i.e. the whole 180-day run is survivable with zero revenue. On a 1:1 dollar scale, the ratio cash/burn (~6.6 months) is what matters, not the absolutes.
4. **The 5000-MRR bar** (phase_gate_system.gd:47 + 3 other homes). Gates BOTH the mid-game phase change (Traction→Series A, with brand ≥ 25) and the Day-180 bootstrap win. The single most load-bearing revenue number in the game.
5. **B2B revenue quanta: MRR bands 200-500 / 800-2000 / 3000-8000 × cooldowns 5d (Find) + 2d (pitch)** (pitch_system.gd:22-26, sales_tab.gd:13, pitch_system.gd:17). Together they cap the B2B MRR slope: ~2 leads per 5 days, one pitch per 2 days, mostly small/mid → reaching 5000 MRR takes roughly 4-8 signed accounts and ≥3-4 weeks of game time.
6. **B2C flow: HOURLY_AUD_BASE 0.08 + coefs / CONVERSION_BASE 0.35 / price 15** (sales_system.gd:39-43,:76,:23). The B2C MRR slope: audience growth per hour × conversion × price. MRR 5000 at default price needs ~333 paying users ≈ ~950 audience at optimal-price conversion.
7. **Build duration: DEVELOPMENT_DAYS_BASE 6 + Σcomplexity, iterations 4d each, v2 = 3 + 1.5×new-complexity** (product_system.gd:24-25,:94-95,:623). Decides what fraction of the 180 days one product consumes (~16-24 days for a typical v1 = ~10-13% of the run) and therefore how many build↔sell cycles a run holds.
8. **SkillCheck grammar: base 45%, ±15pp per skill/difficulty step, +10pp bonus, clamp 5-95%** (skill_check.gd:14-19). With POINT_POOL 6 / cap 3, every dialogue in the game (B2B pitch, VC beats, term-sheet pushes) resolves through this one line; a 3-point specialist hits 90% on their home lever, a 0-point founder 45%.
9. **SHUTTER_DAYS = 7** (endings_system.gd:19). The loss clock: how long negative cash is survivable. Interacts directly with #3 (burn) and #5/#6 (revenue slopes) to set how punishing a mid-run dip is.
10. **B2B retention clock: SAT_DRIFT_STEP 3/day → tolerance 35+5/scale → RISK 3 days → countdown 7 days** (b2b_constants.gd:9-19). End-to-end, a neglected account takes ~2-3 weeks from healthy to churned — this chain sets the recurring decision cadence (and MRR volatility) of the entire post-ship B2B game.

*Report generated by read-only audit; measurement scripts lived in the session scratchpad and touched nothing in the repo.*
