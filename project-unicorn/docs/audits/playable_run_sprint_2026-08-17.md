# Playable Run Sprint — 2026-08-17

Fire tables, churn autopsy, fixes, and the played-run log. Companion to
`AUDIT_2026-08-06_full_game.md` (which catalogued the bugs) and
`calibration_values_2026-07-17.md` (which catalogued the numbers). This one is the
first document produced by **playing** rather than reading.

Every number below came from `--run-log`, the harness this sprint added
(`scripts/debug/run_probe.gd`). Runs are pinned to seed 424242 and reproducible with the
command printed beside each table.

---

## 0. The instrument

`godot --headless --path . --run-log=<preset>:<days>:<mode>`

Not an assertion harness — a **ledger**. One line per event fire with its injector, one per
choice, one per day of economy state, one per customer per day. `mode=sim` drives
TimeManager's dispatch directly (instant, exact slot attribution); `mode=1..4` uses the real
clock at that speed index, which is the only way to catch a real-time-only defect.

Presets: `b2b_solo` · `b2b_reps` · `b2b_risk(_keep)` · `b2b_slip(_keep)` · `b2c` · `full_run`.
The `_keep` suffix means the founder **builds what he promised**; `b2b_risk` and
`b2b_risk_keep` are the same world and differ only in that, which makes the pair a controlled
experiment rather than two anecdotes.

One production change supports it: all three admission paths in `EventManager` used to reject
a duplicate id **silently**, so a K2-style loop could flood the enqueue path invisibly. They
now print `Dedupe-rejected: <id>` in debug builds. Behaviour untouched; it is what makes
*attempted* repeats countable. **In every run recorded here that counter is 0** — the queue
machinery is clean, and the repeats below are all admission-eligible fires.

---

## 1. Event fire tables

### 1.1 Before / after the Step 2 fixes — 90 days, 5 accounts

| preset | fires | promises | kept | broken | churn | brand d90 | MRR d90 |
|---|---|---|---|---|---|---|---|
| `b2b_solo` before / after | 17 / 17 | 2 / 2 | 0 / 0 | 0 / 0 | 0 / 0 | 50 / 50 | 6300 / 6300 |
| `b2b_reps` before / after | 19 / 19 | 2 / 2 | 0 / 0 | 0 / 0 | 0 / 0 | 50 / 50 | 6300 / 6300 |
| **`b2b_risk`** before / after | 151 / 151 | **142 / 30** | 0 / 0 | **117 / 25** | 0 / 5 | 0 / 0 | 2700 / 68 |
| **`b2b_risk_keep`** before / after | 40 / 39 | **17 / 5** | 17 / 4 | 0 / 1 | **2 / 0** | 44 / 47 | 3360 / 5360 |
| `b2c` before / after | 22 / 22 | — | — | — | 0 / 0 | 98 / 98 | 2190 / 2190 |

The healthy worlds are byte-identical before and after: the fixes touch only the paths the
autopsy indicted.

### 1.2 The JSON ambient pool re-arms at its cooldown floor — `b2c`, 90 days

| id | cooldown | fired on days | verdict |
|---|---|---|---|
| `ev_ps_b2c_producthunt` | 10 | 7, 17, 27, 37, 47, 59, 70, 80 | **SELF-REARMING** |
| `ev_ps_power_user_b2c` | 12 | 14, 29, 42, 55, 68, 81 | **SELF-REARMING** |
| `ev_ps_bug_complaint` | 8 | 4, 25, 46, 69, 88 | **SELF-REARMING (the known K4)** |
| `ev_ps_referral_b2b` | 12 | 7, 25, 37, 50, 65, 84 | **SELF-REARMING** |

All four fire at, or close to, their cooldown floor for the whole run, because their trigger
conditions (`b2c_paid_tier_open`, `audience_above N`, `customer_count_min 1`, `market_type`)
become true once and **never become false again**. This is the director's "sürekli seed": the
two `add_prospect` events between them put a fresh lead on the desk every ~12 days, forever.

No latch can fix this class — the trigger is true by design. Arc-time treatment is a design
decision, recorded here and **not patched**. (Audit Group 6 `[REBUILD-ARC]`.)

---

## 2. Churn-chain autopsy

### 2.1 The controlled pair

Two 90-day runs, identical worlds, differing only in whether the founder honours his word:

| | never build | build every promise |
|---|---|---|
| promises created | 142 | 17 |
| broken | 117 | 0 |
| **churned** | **0** | **2** |
| brand at day 90 | **0** (by day 30) | 44 |

**Building the promised feature lost customers; lying to every customer forever lost none.**
That is the betrayal the director felt, reproduced with numbers.

### 2.2 The chain, link by link (`co_probe_c`, "Marmara İnşaat")

| day | event | state |
|---|---|---|
| 1 | signed | sat 52 · tol 50 · target 31 |
| 2–3 | drifts, streak 1→2 | — |
| 4 | retention fires → **"Söz ver: randevu planlama"** → promise #1, deadline 18 | sat 37→45, countdown cleared |
| 4 | founder starts the v2 build for that exact feature | — |
| 7 | retention fires **again** → promise #2, *same feature* | — |
| 10 | retention fires **again** → promise #3, *same feature* | — |
| 12 | ship → **all three resolve `kept` at once** | sat 31→76 · tol 50→35 · target 31→47 |

| # | link | verdict |
|---|---|---|
| 1 | events fired, in order | **WIRED** |
| 2 | promise created (feature id, deadline) | **BROKEN** — duplicates, §3.1 |
| 3 | resolved `kept` (day 12 ≤ deadline 18) | **WIRED** |
| 4 | satisfaction/tolerance moved on resolution | **WIRED**, but over-rewarded 3× by link 2 |
| 5 | **does a kept promise reach the churn countdown?** | **BROKEN** — §3.2. Reproduced verbatim in `b2b_risk_keep`: `status=kept … countdown=5 phase=risk` |
| 6 | does the account survive? | **DESIGN-GAP** — §5.1 |

### 2.3 Two latent traps found in the same read

- `_tick_at_risk` computes `next_countdown` **locally**: an account in phase `"risk"` with
  `churn_countdown == -1` yields `-2 <= 0` and churns instantly. No live path produces that
  state today; a partial save-restore would. **Not fixed** — reported.
- `_recover` stamped `"active"` unconditionally over the onboarding window. **Fixed** (§3.3).

---

## 3. Fixes

Each was found by a driver run, each fails against the pre-fix engine with a specific
diagnosis, each was falsified by reverting it and watching the case fail.

### 3.1 A word already given may not be given again
`b2b_event_factory.gd` — the retention card and the CS feature-request card now require
`not PromiseRegistry.has_open_for(c.id)`. The rule already existed in the sibling channel
(`pick_request_kind` scores `has_open_for` at −25) but no gate enforced it.
**Falsified:** `SMOKE FAIL promise_no_duplicate_word: the retention card offered a SECOND word while one was still open`

### 3.2 Keeping the word stops the clock, exactly as giving it already did
`b2b_sales_system.gd` — `on_promise_resolved("kept")` now routes its satisfaction bump through
`_recover()`. `accept_promise` (merely *promising*) already cleared the countdown and the risk
streak; *keeping* wrote satisfaction and nothing else, so the clock ran straight through the
delivery. **No number changed** — the bump moved from a bare `set_satisfaction` into `_recover`.
**Falsified:** `SMOKE FAIL promise_kept_stops_countdown: kept promise left the churn countdown running (3)`

### 3.3 A rescue inside the onboarding window stays in onboarding
`b2b_sales_system.gd::_recover` — mirrors what `_tick_healthy`'s risk branch already does.
**Falsified:** `SMOKE FAIL recover_preserves_onboarding: rescue inside the onboarding window stamped 'active'`

---

## 4. Frank's angel round

`scripts/systems/angel_round_system.gd`, TimeManager slot **8a**.

| | |
|---|---|
| trigger | `mvp_shipped` AND `MRR > 2500` (director ruling, revised down from 5,000 — see §5.4) |
| terms | +$25,000 cash, 4% equity |
| latch | `GameState` flag `angel_seed_offered`, stamped **at enqueue** |
| equity home | new `run_angel_amount` / `run_angel_equity_pct` |
| decline | visible-locked, `flag_equals hard_mode_unlocked true` — **no writer for that key exists in the engine** |

Two structural notes worth keeping:

- **`enqueue_front` does not mean "front".** It ends in `_pump_queue`, which mounts
  immediately when nothing is active. With an empty queue the **first** caller owns the screen
  and later ones stack behind it; with a modal already up, the **last** caller pushes to the
  head. Slot order therefore only decides reading order in the empty-queue case. Slot 8a sits
  one line ahead of `PhaseGateSystem` so the money lands before the Series A conversation.
- **The Series A scalars are never overloaded.** `_persist_signed_terms` writes
  `run_equity_pct` by plain assignment; a shared field would be erased by the signature.
  `get_investor_equity_pct()` / `get_total_raised()` compose the two rounds for the cap table
  and the ledger, while the newspaper's valuation sentence stays about the Series A alone.

---

## 5. Calibration notes (observations — no tuning was done)

### 5.1 The B2B book is one number, so it is binary
`_satisfaction_target()` = `axis_score(…, "stability") + trust_offset`. Every account in the
book drifts toward the **same global product number**; `trust_offset` is the only per-account
differentiator that exists, and it decays 0.4/day to zero. Measured in `b2b_solo`: five
accounts of three archetypes converge to the identical satisfaction (51 → 50 → 49 over 70
days) while their tolerances sit at 35–50. There is no middle state — either the product
clears every bar or it clears none.

Consequence for the chain above: delivering a feature raises the target only through the bugs
it fixes, and a *new* feature **seeds bugs** (`FEATURE_BUG_SEED_COEF = 1.0`), so the target can
fall on the day the customer's feature lands.

### 5.2 `İndirim ver` is uncapped and it is the dominant strategy
In the played run, **639 of 681 event fires (94%) were the retention modal, and 628 were
answered with the discount.** It has no use cap (`Oyala` has 2) and cuts MRR 15% every time.
MRR peaked at $7,349 and ended at $2,534 while the book grew to 25 accounts — the player
discounts the company to death and never loses a customer doing it.

### 5.3 The customer's pain is write-once
`pain_feature_id` is set at signing and **never updated**. Once the promised feature ships,
the "Söz ver" row can never return for that account (the factory gates it on the feature being
unshipped), so a delivered account permanently loses the only rescue that costs no revenue.
Before fix 3.2 this was the direct cause of the two churns in §2.1.

### 5.4 The $5,000 bar collided with the Series A gate
The seed's original bar equalled `PhaseGateSystem`'s Traction→Series A condition
(`mrr_above TRACTION_MRR_TARGET - 1`), so both opened on the same day; and at MRR 5,000 a
$25,000 cheque is not a bridge (revenue ~$167/day against ~$250/day burn with one junior).
Ruled down to 2,500. Measured at the new bar: **113 days gross / 167 net** runway at the seed
moment with one junior, against the paper's ~100.

### 5.5 B2C cannot reach the seed bar inside a run
A played B2C autopilot run reached **MRR 135 by day 173** and went bankrupt. Audience growth
barely clears the erosion term for a modest v1, so the B2C path reaches neither the $2,500 seed
bar nor the $5,000 Series A gate within 180 days.

### 5.6 The live event pool's cash costs are large against opening cash
`ev_ps_bug_complaint` −$1,500 · `ev_ps_b2c_producthunt` −$800 · `ev_ps_power_user_b2c` −$600,
against $10,000 opening cash. An autopilot taking the paid option every time went bankrupt on
day 54 purely from event spend. Playing them cash-aware (≤12% of balance) extended the same
run to day 173.

### 5.7 The smoke suite does not pin its RNG seed
`EndgameSmoke.run_case` calls `initialize_run`, which seeds from `Time.get_ticks_msec()`. Any
case whose outcome depends on the ambient pool is therefore a fresh coin flip per invocation —
one of this sprint's new cases passed solo and failed 4 times in 12 before it was made to
force its own precondition. **Testing-hygiene item, not a game bug.**

---

## 6. The played run

`--run-log=full_run:180:4` — day 1, nothing seeded, the founder played by the probe through
the same seams the tab buttons call. **180 in-game days in 275.7 seconds of wall clock.**

| day | beat |
|---|---|
| 2 | v1 build starts (`saas_ops`, 3 features) |
| 19 | ship |
| 20–33 | 6 pitches played, 3 signed |
| **33** | **Frank's seed fires at MRR $2,561 → accepted** |
| **35** | **hire nudge** |
| **38** | **first hire — developer, $6,300/mo** |
| 180 | 25 customers · phase 3 · peak MRR $7,349 |

**Cash waypoints:** start $10,000 → pre-seed trough **$6,412** (day 33) → post-seed **$30,847**
(day 34) → first-hire burn step $50 → $260/day (day 38) → $9,291 at day 180.

**Series A gate: reachable and reached** (phase 3; peak MRR $7,349 against the 5,000 + brand 25
bar).

**Promise-chain replay: 3 created, 3 kept, 0 broken, 0 churn.** Demand → promise → build →
ship → **retained**, in play.

**Per-id fire table:** every one-shot fired exactly once (`ev_angel_frank_seed`,
`ev_angel_hire_nudge`, both phase gates, `ev_ps_first_revenue`, `ev_ps_frank_intro_b2b`, the
ship moment, all six `ev_mvp_*` build events). Expansion fired **exactly once per account
across 25 accounts** — the K2 latch holding at scale. Cooldown events respected their
cooldowns. **Zero dedupe-rejections.**

The one id outside its design is `ev_b2b_retain_*` at 24–49 fires per account (§5.1, §5.2) —
self-rearming, documented, not patched.

---

## 7. Verification

- **Smoke: 164/164 PASS, 0 gate violations.** Runner gates each case on `SMOKE PASS` **and** on
  the absence of `Parse Error|Compile Error|Failed to instantiate`, with a per-case timeout.
  Case count scraped from source (153 + 11 new).
- Every fix falsified: reverted, case failed with the correct diagnosis, restored.
- The seed's one-shot falsified twice — inside `angel_one_shot_falsified` (clear the latch, the
  offer must return) and by reverting the latch guard
  (`SMOKE FAIL angel_one_shot_falsified: the seed scene re-opened on day 3`).
- `loc_residue.gd`: **1433 hits — byte-identical to the documented baseline** at commit
  `a683ab1`. Zero net new residue; `angel_round_system.gd` carries no Turkish literal (all 10
  player-visible strings route through keys).
- Seed card rendered in **both locales** via `--b2b-shot=angel`: the KABUL effect chip
  (`NAKİT +$25K · FRANK'E %4 HİSSE` / `CASH +$25K · 4% TO FRANK`) and the dimmed, chip-less,
  non-interactive REDDET row with its telegraph.

**Caveat on the environment:** this sprint ran on a checkout that a parallel ODA session was
writing to throughout. `scripts/ui/oda/*` was transiently unparseable mid-run (a `monitor_night`
preload against an asset being renamed); those errors are excluded by filename in the suite
gate and are not attributable to this work. No file in this sprint's set overlaps ODA's.
