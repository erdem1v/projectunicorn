# EVENT DECK DELETE — 2026-08-31

The playtest was firing content written for a different game. This is the pass that removed it.
Thirty cards live, sixteen deleted, three smoke cases repointed, no straddler parked, no engine
file touched.

---

## 0 · What the earlier pass did

**Nothing. No delete or quarantine pass ever ran.** Established from the repo, not assumed:

| evidence | reading |
|---|---|
| `docs/reports/` holds three files: `EVENT_ENGINE_REBUILD_2026-08-26.md`, `SALES_REV6_DELIVERY.md`, `FUNDING_LADDER_WAVE_2026-08-27.md` | no delete / quarantine / classification report exists |
| `docs/plans/` holds three: two `EKIP_REBUILD*`, one `SALES_REBUILD_2026-08-26.md` | no deck-cleanup plan exists |
| `git log --diff-filter=D -- data/events` | two deleting commits only, both accounted for below |
| `git reflog -20`, `git stash list`, `git branch -a`, `git worktree list` | linear history, no stash, one branch, one worktree — no lost work to recover |
| `git status` at `7946ff3` | clean tree; nothing half-applied was waiting |

The two deleting commits are the **port**, not a cleanup:

- `cc952e4` *Olay motoru yeniden kuruldu* deleted the whole old `data/events/reactive/` tree
  (21 files) and rebuilt it as `data/events/cards/`. That is the engine rebuild the brief names as
  the dividing line — the cards it produced are the ones this pass judges.
- `7946ff3` deleted `data/events/unwired/ev_seed_closed.json`, promoted to `funding/seed_closed.json`.

**An existing classification table does exist, and it is reusable but not as it stands.**
`docs/EVENT_MIGRATION_LEDGER.md`, whose verdicts come from `docs/audits/EVENT_INVENTORY_2026-08-21.md`.
Its ruling was the director's own, dated 2026-08-25: *port and repair, delete the worst.* It graded
PORT+REPAIR 15 · DELETE 3 · HOLD 1 · PORT (code-built) 11 families · RETIRE 4. **Its headline finding
is the reason this pass exists**: COPY LIE on 27 of 28 entries — the label names a resource and the
engine charges a different one — and the ledger chose to repair the prose rather than replace the
cards. Playtesting has overturned that call. The ledger stays as the record of a migration that did
happen; it is corrected by `docs/EVENT_ID_MAP.md`, which now names every right-hand id that no
longer exists.

**Live deck at `7946ff3`, verified against HEAD rather than taken from the brief:**
`--event-lint` printed `LINT PASS 0 error(s), 0 warning(s), 19 baselined, 53 card(s), 3 arc(s)`.
The 53 is 46 authored cards plus 7 `version_scope: fixture` engine-test cards that gate step G2
refuses in any shipping build.

### What the deck was actually doing to the playtest

Two seeded 120-day runs on a pristine `7946ff3` checkout (`--run-log=<preset>:120:sim`):

| run | cards fired | of which legacy flavour |
|---|---|---|
| `full_run` (B2B, day 1, nothing seeded) | 31 | **19 (61 %)** |
| `b2c` | 26 | **24 (92 %)** |

In a B2C playtest, twenty-four of the twenty-six cards the player answered were content written
before the engine rebuild. That is the damage report, and it is the argument for deleting rather
than repairing again.

---

## 1 · Classification

Every card at `7946ff3`, in exactly one class. **FRANK** is a text-protection class: the card's
prose is in the sealed v6 corpus (`speaker: char_mentor_frank`, or a row of
`docs/writing/FRANK_VOICE_INVENTORY.md`). **MECHANIC-SURFACE** is everything else live that is a
system's speaking mouth. Both are live and untouched.

**On the one collision worth naming.** The brief files "funding and gate cards (including the seed
rung and the acquisition card)" under MECHANIC-SURFACE, and every one of them is also sealed Frank
prose. They are listed as FRANK because that is the stricter promise — do not edit a line — and the
reason column carries the mechanical fact too, so nothing is lost. The verdict is identical either
way: live, untouched. That the two classes overlap so heavily is itself a finding:
**Frank never speaks decoratively in the shipped build.** He speaks at a gate, a ship, a door or an
ending, and nowhere else.

### FRANK — 18 cards · live, untouched

| id | title | class | reason |
|---|---|---|---|
| `customer.frank_intro` | An old friend | FRANK | corpus; also the only first B2B lead |
| `funding.acquisition_offer` | Acquisition offer | FRANK | corpus; only `trigger_ending` on disk |
| `funding.frank_cheque` | Frank's offer | FRANK | corpus; only `angel_accept` |
| `funding.gate_series_a` | The Series A table | FRANK | corpus; phase gate |
| `funding.gate_traction` | The first payment | FRANK | corpus; phase gate |
| `funding.hire_nudge` | A company of one | FRANK | corpus; onboarding |
| `funding.last_answer` | Time's up | FRANK | corpus; terminal telegraph |
| `funding.meeting_day` | The big day | FRANK | corpus; only `start_vc_meeting` |
| `funding.seed_closed` | The money's in | FRANK | corpus; seed rung |
| `funding.seed_door` | The door is open | FRANK | corpus; seed rung |
| `funding.seed_offer` | The offer is on the table | FRANK | corpus; only `open_seed_table` |
| `funding.sheet_expiry` | The offer on the table | FRANK | corpus; sheet clock |
| `funding.shutter_warning` | In the red | FRANK | corpus; bankruptcy telegraph |
| `product.design_round_intro` | A decision at the design table | FRANK | corpus; only `enter_development` |
| `product.first_ship` | First version is live | FRANK | corpus; only `ship_active_build` |
| `product.paid_tier` | About the price | FRANK | corpus; onboarding |
| `product.version_ship` | v{version} is live | FRANK | corpus; ship moment |
| `world.final_stretch_verdict` | Frank calls | FRANK | corpus; closes the soft-cap arc |

### MECHANIC-SURFACE — 12 cards · live, untouched

| id | title | class | reason |
|---|---|---|---|
| `customer.cs_escalation` | Account manager warning | MECHANIC-SURFACE | rep-warning |
| `customer.expansion` | Growth opening | MECHANIC-SURFACE | only `b2b_expand` |
| `customer.request_complaint` | Customer complaint | MECHANIC-SURFACE | request-channel |
| `customer.request_feature` | Customer request | MECHANIC-SURFACE | request-channel |
| `customer.request_renewal` | Renewal signal | MECHANIC-SURFACE | request-channel |
| `customer.retention` | Account at risk | MECHANIC-SURFACE | retention |
| `funding.seed_stalled` | The quarterly note | MECHANIC-SURFACE | seed-rung |
| `sales.price_break` | PH: A question of price | MECHANIC-SURFACE | price-break |
| `sales.weekly_summary` | PH: Weekly sales summary | MECHANIC-SURFACE | weekly-summary |
| `team.resignation` | A departure | MECHANIC-SURFACE | only `employee_leaves` |
| `world.final_stretch_comment` | They want a comment | MECHANIC-SURFACE | arc-step |
| `world.final_stretch_press` | Sector Telegraph · the annual file | MECHANIC-SURFACE | arc-opener |

### LEGACY-FLAVOR — 16 cards · DELETED

| id | title | class | reason |
|---|---|---|---|
| `customer.bug_complaint` | This does not work | LEGACY-FLAVOR | old-customer |
| `customer.power_user` | An early admirer | LEGACY-FLAVOR | old-customer |
| `customer.referral` | The boss's friend | LEGACY-FLAVOR | old-customer |
| `customer.showcase_feature` | A window in the shop front | LEGACY-FLAVOR | old-customer |
| `product.competitor_signal` | A rival announced something similar | LEGACY-FLAVOR | old-build |
| `product.critical_bug` | You found a bug of the kind that… | LEGACY-FLAVOR | old-build |
| `product.early_launch_pressure` | A voice inside says 'ship now' | LEGACY-FLAVOR | old-build |
| `product.early_user_feedback` | Unsolicited feedback from someone you know | LEGACY-FLAVOR | old-build |
| `product.final_polish` | A small chance to polish | LEGACY-FLAVOR | old-build |
| `product.integration_broken` | Something is not working | LEGACY-FLAVOR | old-build |
| `product.quiet_version_age` | The version | LEGACY-FLAVOR | old-version |
| `product.scope_creep` | This feature runs deeper than I thought | LEGACY-FLAVOR | old-build |
| `product.solo_dev_fatigue` | Heavy on your own | LEGACY-FLAVOR | old-build |
| `product.tech_debt_callout` | The debt sends its invoice | LEGACY-FLAVOR | old-build |
| `team.quiet_late_light` | A light still on | LEGACY-FLAVOR | team-flavour |
| `world.quiet_runway_glance` | The arithmetic | LEGACY-FLAVOR | world-flavour |

### Not deck — 7 engine-test fixtures (+1 added), untouched

`fixture.concurrent` · `fixture.subject_open` · `fixture.subject_close` · `fixture.subject_reassign` ·
`fixture.thesis_open` · `fixture.thesis_payoff` · `fixture.thesis_close`. All carry
`version_scope: fixture`, which G2 refuses in every shipping build, so no player has met one. They
are counted by `--event-lint` and are not part of the deck. `fixture.hourly_ambient` was added by
this pass and is explained under **Repointings**.

### Straddlers parked: none

Three cards were weighed and none needed the `# DESIGN-PARKED:` tag.

- **`customer.referral`** creates prospects and a promise, which looks load-bearing. It is the sole
  channel for neither: `customer.frank_intro` also spawns a lead, `SalesSystem` and
  `CustomerRepSystem` run the autonomous pipeline, and `promise_create` survives on four live cards.
  It is an old customer card (`ev_ps_referral_b2b`) with no phase guard. Deleted.
- **`product.paid_tier`** reads like a nudge card and would have gone but for
  `FRANK_VOICE_INVENTORY.md` row 7: it is Frank's, and sealed. Kept as FRANK.
- **`customer.expansion`** is the only card on disk carrying `b2b_expand`, and `main.gd:639` and
  `sales_tab.gd:549` both name it. Sole entry to a system verb. Kept.

---

## 2 · Deletion mechanics

**Localization keys: none to delete.** Each of the sixteen carries its prose inline in both locales
inside the JSON — that is the Faz-2 shape for card content — so no `strings.csv` row belonged to any
of them. Proven twice: a scan of the deleted set's CAPS tokens found exactly one,
`B2B_LOCK_PROMISE_OPEN`, which four surviving cards also use; and `loc_residue` reports
`csv_keys=2616` before and after, unchanged.

**System code naming a deleted id: none.** A repo-wide scan for card-id literals
(`"(customer|product|team|world|funding|sales)\.[a-z_]+"`) found every reference under
`scripts/systems/`, `scripts/tabs/` and `scripts/main/` pointing at a card that survives. The only
two references anywhere were in the smoke suite, and both were repointed. No dead call to remove.

**Two flags lost their only writer, and this is declared rather than fixed.**
`critical_bug_unfixed` was written only by `product.critical_bug`; `tech_debt_birikti` only by
`product.integration_broken` and `product.tech_debt_callout`. Both are read by `ProductSystem`
(`product_system.gd:1213`, `:1704`, `:1726`) and one by `seams_product.gd:96`. Those reads now
evaluate false until the new deck writes them again. **No code was touched**: the brief says zero
engine file edits, the reads are correct code with no content behind them, and
`EvEffects.GAME_FLAG_WHITELIST` still admits both names, so re-wiring is one card away. Recorded
here so the deck author knows those two verbs are waiting.

**The lint ratchet fell 19 → 1, and the shape of the fall checks the classification.** Eighteen of
the nineteen baselined findings were `17.8 body contains a dash` across eight cards, and every one
of those eight is in the deleted set. The rule this project bans hardest had been baselined almost
exclusively for legacy flavour. The one survivor is the fixture arc's reachability warning.

---

## 3 · Repointings

Three smoke cases named a deleted card. None was deleted; all three still assert what they asserted.

**1 · `bug_complaint_costs_audience_not_cash` → `complaint_never_charges_cash`.**
It carried Calibration Round A §7 — a complaint costs audience and satisfaction, never cash. The
ruling outlived its card, so it is asserted in the two places that survived it. Half one renders the
**live** `customer.request_complaint` and proves no row of it charges cash. Half two drives the
deleted card's three effect rows through `EventGate.debug_apply_effects` on a bound userbase
subject, so the arithmetic they pinned — satisfaction +10 then +6, brand +2 then −1, a −3 % and −1 %
slice of the audience, then churn — still has a case while the new deck is unwritten. Renamed
because the old name named a card that no longer exists.

**2 · `event_i4_demoted_never_dropped`.** It needs six copies of any catalogued, non-exempt
interrupt to over-fill the day's budget; it used `product.critical_bug`. It now uses
`customer.retention` — live, `class: interrupt`, and neither `critical` nor `terminal_warning` nor
arc-bound, so §13.5 does not exempt it from the budget. One line, same claim.

**3 · `ambient_one_per_day_across_hour0` — repointed, and stronger than it was.** This one had no
live path at all: every authored `tick: hourly` card was legacy flavour, so after the delete the
hourly pool is empty and the case would have failed on `total == 0`. The brief's rule says an absent
live path means the card was really MECHANIC-SURFACE — but the claim here is about the **engine's
clock**, not about content, and keeping a legacy B2C card alive to feed a test would have left in
place the exact damage this pass exists to remove. So the subject moved to
`data/events/cards/_fixtures/hourly_ambient.json`, admitted by widening `SHIPPED_SCOPES` for the
length of the case and narrowing it again — the idiom `event_thesis_day10_to_day90` already uses two
functions further down the same file.

Reading the old case closely turned up a defect while repointing it. Its comment calls the hour-0
rollover *"the boundary this case exists for"*, but its three subjects sat in `allowed_hours` windows
of 9–18, 18–22 and 20–23. **Not one of them could ever fire at hour 0**, so the branch was never
reached and the case had been passing on daytime fires alone. The fixture sits in
`allowed_hours: [0, 0]`, so every fire it produces is a rollover fire, and a new assertion
(`at_hour_zero == 0` → fail) makes the boundary something the case can lose.

---

## 4 · What this leaves thin, said out loud

The point of the pass is that the deck is now small. Two consequences are worth writing down for
whoever authors the replacement.

- **The quiet floor (§13.6) has no content.** All three `tag: quiet` cards were legacy flavour and
  are gone, so `EvEngine._step_floor` finds nothing and, after three empty attempts, pushes the
  warning it was built to push: *"the floor has found nothing 3 times running — the quiet pool is
  too thin"*. That is the engine reporting a content hole correctly, not a regression. No test
  asserts the floor finds a card, and the suite is green.
- **`customer.retention` doubled its share of the run.** Across the 120-day `full_run` it went from
  5 fires to 10, because it now takes pool slots the legacy cards used to eat. The B2B deck is thin;
  the B2C deck is thinner, at two cards fired in a 120-day B2C run.

---

## 5 · Verification

### 5.1 A seeded 120-day run fires no legacy flavour card

Same two presets, same seed, before and after — `--run-log=<preset>:120:sim`, `PROBE TALLY` lines.

| | `full_run` before | `full_run` after | `b2c` before | `b2c` after |
|---|---|---|---|---|
| total fires | 31 | **16** | 26 | **2** |
| legacy-flavour fires | 19 | **0** | 24 | **0** |

**After, `full_run` fires:** `customer.expansion` 1 · `customer.frank_intro` 1 ·
`customer.retention` 10 · `funding.frank_cheque` 1 · `funding.gate_traction` 1 ·
`funding.hire_nudge` 1 · `product.design_round_intro` 1 · `product.first_ship` 1. Four Frank beats,
one phase gate, three mechanic surfaces, nothing else.
**After, `b2c` fires:** `funding.gate_traction` 1 · `product.paid_tier` 1.

### 5.2 Endings

Every previously reachable ending remains reachable. Endings are driven by `EndingsSystem`; the only
card on disk carrying `trigger_ending` is `funding.acquisition_offer`, which is live, and the only
card carrying a terminal telegraph the endings read is `funding.shutter_warning`, also live. No
deleted card carried `trigger_ending`, `decline_buyout`, `advance_phase`, `start_arc`, `advance_arc`
or `end_arc`. The soft-cap arc's three cards are all live. Ending coverage is asserted by the suite
(`bankruptcy`, `shutter_recovery`, `brand_collapse`, `pivot_accept`, `pivot_decline`,
`buyout_needs_the_road_over`, `soft_cap_ends_run_at_730`, `b2c_ending_reports_audience` and the rest),
and it is green.

### 5.3 Gates

| gate | before | after |
|---|---|---|
| `--event-lint` | PASS · 0 E · 0 W · 19 baselined · 53 cards · 3 arcs | **PASS · 0 E · 0 W · 1 baselined · 38 cards · 3 arcs** |
| `--event-probe` | PASS · 159 passed, 0 failed | **PASS · 159 passed, 0 failed** |
| `loc_residue` | 0 hits · CLEAN · csv_keys 2616 | **0 hits · CLEAN · csv_keys 2616** |

38 cards = 30 live deck + 8 fixtures.

### 5.4 Full suite

`tools/smoke_run.sh --all`, one Godot boot per case, `CASE_TIMEOUT=150`. The runner fails a case
on an engine error line as well as on its verdict, so a throwing case cannot pass silently:

```
SMOKE SUMMARY 334/337 passed
FAILED: b2c_satisfaction_gate_experience save_migration_v7_to_v8 trait_migration_real_load
```

**Three reds, at the inherited baseline, proven rather than assumed.** A pristine `7946ff3`
checkout was copied into a scratch directory *before any file was touched*, and the three cases
were run there afterwards. All three fail on that untouched tree with byte-identical messages:

| case | message on pristine `7946ff3` | message after this pass |
|---|---|---|
| `b2c_satisfaction_gate_experience` | `experience 10 (axis 28.6) moved satisfaction (49)` | identical |
| `save_migration_v7_to_v8` | `read_slot refused the v7 fixture: SAVE_ERR_TOO_OLD` | identical |
| `trait_migration_real_load` | `the v5 fixture did not load: SAVE_ERR_TOO_OLD` | identical |

None is event-coupled. The first is a quality-model calibration bar; the other two are save
fixtures that aged past the migration floor when the schema moved to v11 in the sales rev 6 work.
Nothing in this pass touched a save, a schema, or the quality model.

**One post-run edit, declared.** After the suite finished, a pair of em dashes inside a
pre-existing comment was restored — the patch script had rewritten them as hyphens, which was a
gratuitous change to prose this pass had no business editing. That block is now byte-identical to
the original. `complaint_never_charges_cash` and `all_scripts_load` were re-run green afterwards;
a comment cannot change a result, and the parse gate confirms it.


---

## 6 · Files

**Deleted (16)** — every path under `data/events/cards/`:
`customer/bug_complaint.json` · `customer/power_user.json` · `customer/referral.json` ·
`customer/showcase_feature.json` · `product/competitor_signal.json` · `product/critical_bug.json` ·
`product/early_launch_pressure.json` · `product/early_user_feedback.json` ·
`product/final_polish.json` · `product/integration_broken.json` · `product/quiet_version_age.json` ·
`product/scope_creep.json` · `product/solo_dev_fatigue.json` · `product/tech_debt_callout.json` ·
`team/quiet_late_light.json` · `world/quiet_runway_glance.json`

**Added (1)** — `data/events/cards/_fixtures/hourly_ambient.json`, engine-test content.

**Changed (5)** — `scripts/debug/endgame_smoke.gd` (three repointings) ·
`tools/lint_baseline.json` (19 → 1, regenerated) ·
`docs/content/events_draft/_vocabulary.md` (regenerated; it also absorbed seam and verb drift that
predates this pass, 147 → 162 seams and 59 → 61 verbs, from the funding-ladder wave) ·
`docs/EVENT_ID_MAP.md` (records which arrows now point at nothing) ·
`data/events/cards/_fixtures/README.md` (the new fixture, and a stale line saying only the probe
widens `SHIPPED_SCOPES`).

**Untouched:** every file under `scripts/systems/`, `scripts/events/`, `scripts/autoload/`,
`scripts/tabs/`, `scripts/main/`, and `localization/strings.csv`.
