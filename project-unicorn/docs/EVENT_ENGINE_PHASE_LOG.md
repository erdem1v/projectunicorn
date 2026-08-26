# EVENT ENGINE REBUILD — phase log

One line of state per phase exit, appended never rewritten. The full account is the final
report; this file is what makes a bad morning cheap.

Plan approved 2026-08-25 with amendments A1-A7 and six directives.

| # | phase | smoke | state |
|---|---|---|---|
| — | plan approved | — | 10 phases after the two design reviews; strangler replaced by a facade; schema v10 |
| P0 | ground truth | 276/278 (2 pre-existing reds, see below) | GDD converted in-tree, seam registry + signal manifest written, six documents repointed |
| P0.5 | EventGate facade | *(running)* | 165 code lines across 18 files repointed; 7 new test seams; `all_scripts_load` PASS |

---

## P0 · Ground truth — closed 2026-08-25

**Delivered**

- `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` — the .docx converted in full (27 sections, all tables, the
  63-row edge-case matrix, schema listings fenced as code). It is now the live authority; the
  .docx is archival and `GDDs/README.md` says so and why. `§27 · İNŞA NOTLARI` is open.
- `docs/SEAM_REGISTRY.md` — five modules plus `phase. rival. investor. time. founder.`, each
  row VAR / OKUNUYOR / YOK with file:line, and ten `YOK` items filed against owning modules.
- `docs/EVENT_SIGNAL_MANIFEST.md` — **generated**, `python tools/gen_signal_manifest.py`.
  110 signals; **3** with no production emitter; **48** emitted with no listener.
- Stale-document sweep: `docs/.md` → `docs/design/EVENT_POOL_DESIGN_v1.md` (six referencing
  documents repointed); superseded banners on `gdd_conformance/08_event_ve_anlati.md` and
  `_vocabulary.md`; `TECH_SPEC.md` §9's four false claims corrected; `PROJECT_SPEC.md` §6's
  Event Pool row un-TBD'd; `CLAUDE.md`'s three-month-stale tail corrected and the engine docs
  linked from Document References.

**Discovered**

- **The signal count is 3, not 2.** `meeting_requested` has no emitter either, alongside the
  two the GDD names. It is a VC-side signal, filed rather than adopted.
- **The smoke baseline was already red, in two cases, before this task touched anything.**
  `save_migration_v7_to_v8` and `trait_migration_real_load` write sub-9 save fixtures and load
  them through the *real* path; `MIN_LOADABLE_VERSION := 9` (`save_manager.gd:48`) refuses them
  with `SAVE_ERR_TOO_OLD` before the migration ladder is reached. Reproduced on demand. Their
  three sibling cases still pass because they call `_migrate_*` directly — which is exactly the
  shortcut `endgame_smoke.gd:8758` warns against, so the two honest cases are the ones that
  broke. Not caused here, and recorded now so it is not mistaken for rebuild damage later.
  Decision on them lands with the schema bump in P1.

**Process slip, recorded because the rule was mine.** I started the baseline suite and then
edited the tree while it was running, which invalidates the run — the exact rule my own notes
carry from 2026-07-29. Killed at 55/278 (0 failures, all pre-change). The suite was restarted
after the P0.5 edits were complete and the tree was frozen for its duration.

## P0.5 · The facade — in progress

`scripts/events/event_gate.gd`. Every system, tab, modal, autoload and harness now reaches the
event layer through one address. Behaviour is byte-identical: every function is a forward.

**Why a facade instead of two live engines** — the approved plan said strangler, and the
review overturned it on evidence. `main.gd:2275-2290` mounts the event modal with no
`_event_modal != null` guard, alone among that file's eight modal openers; it is safe only
because there is exactly one `_active_event_id`. A second engine orphans a modal in ModalLayer,
`game_shell.gd:151-153` guards on a **child count**, and `event_modal.gd` has no `ui_cancel` —
so the orphan takes Space, 1/2/3 and Esc with it, permanently. No pause, no system menu, no
save, no quit. The facade makes the swap reversible instead.

**Repointed:** 165 code lines across 18 files — 19 injection sites, 7 pause-arbitration sites
in `main.gd`, 4 UI counts, 5 production callers of `is_condition_met` (which is a public
service, not an event-only API), save/load, both ticks, and both harnesses.

**Seven test seams added** rather than leaving the suite coupled to private fields:
`queued_ids` · `queued_cards` · `instances_of` · `queue_position_of` · `catalogue_card` ·
`debug_inject_queued` · `debug_apply_effects`. Sixteen smoke lines reached into `_queue`,
`_all_events` and `_apply_modifiers` directly; they now name what they want and survive the
swap.

**Comments were deliberately left naming `EventManager`.** They carry rationale written against
the engine that is still the one running. They move with the code under them, phase by phase —
the project's own GRANDFATHERED convention.

## P0.5 · The facade — CLOSED 2026-08-25

**Verified.** `all_scripts_load` PASS. All **37 event-coupled smoke cases green** — every case
in the suite that names `EventManager`, a card id, or the queue helpers. The two known
pre-existing reds are unrelated to events and unchanged.

The full 278-case suite was started twice and killed twice: the first run because I edited the
tree underneath it, the second because it was pacing at ~3.5 hours and the change under test is
a pure forward. Verifying the 37 cases that actually touch the changed surface is the honest
gate for this phase; the full suite runs at the next natural boundary, where the save schema
also moves.

## P1 · Engine core — in progress

`scripts/events/` — 20 files, ~4,000 lines. Compiles; **88/88 engine assertions pass**
(`--event-probe`).

**Landed:** `EvCatalog` (recursive loader, `unwired/` excluded by name) · `EvSeams` +
five namespace files (**125 seams registered**) · `EvCondition` · `EvHistory` · `EvFlags` ·
`EvLatches` · `EvScope` · `EvSchedule` · `EvQueue` · `EvPapers` · `EvArcs` · `EvGate` (G1–G7) ·
`EvTuning` · `EvProbe`.

**The thesis primitive works.** A condition can now read a choice made earlier in the run —
`{"history": "chose", "event": …, "option": …}` — which is the exact query the old engine had
no way to ask, and the reason `get_history()` had zero callers.

**Design decisions taken while building, each with its reason in the file header:**

- **Cards are plain Dictionaries, never Resources.** The old engine had to serialise whole
  cards because factories minted synthetics the catalogue never knew; the new engine has none,
  so the save holds ids. That also keeps them out of `SaveCodec.script_for_class`, whose
  unknown-class path is a `push_warning` — not in `smoke_run.sh`'s error tokens, so an
  unregistered card class would have been silent data loss with a green suite.
- **The condition evaluator has two entry points over one recursion.** `eval()` short-circuits
  (§5.3); `explain()` collects every failing leaf (§5.4). Two implementations would eventually
  disagree, and a debug panel that disagrees with the gate sends you looking in the wrong place.
- **Blame is a tree, not a leaf.** A failing `none` means a child *passed*, which a single
  `failed_leaf` field cannot express. Asserted.
- **Leaf enumeration ships with nesting, not after it.** `phase_gate_system.gd:200-215` walks
  the gate's condition array switching on leaf type to build the player's Series A readout — it
  consumes the vocabulary's shape, not its result.
- **Condition literals are coerced at load against the seam's declared type.** Godot's JSON
  parser returns `TYPE_FLOAT` for every number, so `{"op":"in","value":[1,2,3]}` would silently
  never match an int seam.
- **G5 runs before G3 when the latch is entity-keyed**, because the key needs the subject.
  Deviation from §4.1's listed order, recorded for §27.
- **The seam registry is an explicit allowlist**, not "any static on a read-surface class" —
  `ProductRead.emit_edges()` is a static on Ürün's read catalogue that mutates statics and
  emits five signals, and §5.3 bans side effects during evaluation.

**Bug found and fixed in my own code by the probe:** a card declaring `max_fires` was also
inheriting the default 30-day cooldown, so a `max_fires: 2` card could never reach its second
fire. §3.1 writes the latch field as alternatives (`one_shot | max_fires:N | cooldown_days:N`),
not a stack; the default now applies only to a card that declares no brake at all.

**Files touched outside the engine:** `main.gd` — one additive block wiring `--event-probe`,
following the `--endgame-smoke` pattern exactly.

## P1 · Engine core — CLOSED 2026-08-25

**Scope run:** targeted. `all_scripts_load` PASS · save family 4/4 · endings family 6/6 ·
`--event-probe` **109/109**.

**Three invariants stopped being promises.**

- **I2 is structural.** The effect vocabulary is split by origin into four tables:
  `run_played` (full) · `run_expire` (economy, negative sign checked *at dispatch*) ·
  `run_ambient` (neutral only) · `run_check_branch` (no terminal, which is also how I6 stops
  being lint-only). `add_cash` is not a *key* in the ambient table, so an ambient caller cannot
  reach it by authoring, by accident, or by a refactor that forgets. §0.3 lists I2 as
  lint-enforced; lint could never have covered `open_negotiation`, whose effect list does not
  exist until runtime.
- **I3 moved onto `EndingsSystem.trigger_ending`'s signature**, which now takes a `telegraph`
  argument **with no default**. Guarding the executor would have covered 2 of its 10 call
  sites; this covers all ten, and made every one of them a compile error until somebody decided
  what warns the player. It asserts rather than blocks — §0.3 asks for "lint + runtime assert",
  and stranding a player mid-run over a content gap is worse than the gap. All six ending smoke
  cases stayed green.
- **I6** falls out of the same table split: `trigger_ending` is not in the check-branch
  vocabulary, so §17.5's first lint rule became a second line of defence rather than the only
  one.

**Schema is v10, and it is a deliberate break.** `MIN_LOADABLE_VERSION` moved to 10 too: every
v9 save is refused with `SAVE_ERR_TOO_OLD`. A v9→v10 migration cannot produce a correct run —
`history[].id` maps to "one_shot consumed" and nothing else maps at all, so arcs would restore
as never-started while their opening cards restored as already-played. `save_v9_product_state`
was renamed and repointed **in the same change**, and its aging fixture now tests the current
boundary (v9→v10) instead of one two versions stale.

**A6 confirmed:** no narrative flag changes storage location. The only two flags content writes
today (`tech_debt_birikti`, `critical_bug_unfixed`) are read by `ProductSystem` from
`GameState` and stay there, becoming named effect verbs rather than moving house. Asserted in
the probe.

**Also landed:** `EvEffects` · `EvSave` (with a `verify_no_resources` walk asserting no
Resource ever reaches the engine block) · `EvTicker` · `EvBudgets`. Two verbs the old engine
wanted and never had: `goto_tab` (seven landed card options whose buttons went nowhere) and
`ticker_push` (no modifier could leave a trace in the feed).

**`add_mrr` is refused rather than implemented.** There is no aggregate-MRR write seam —
`SalesSystem.reflect_mrr()` derives it from the customer book daily, so a raw write is reverted
by the next tick. The old engine shipped an `mrr` *chip* with no dispatcher arm behind it,
which showed the player a number nothing applied. The verb now says so out loud.

## P2 · Arcs, schedule, executor — the thesis phase

**Scope run:** `--event-probe` **159/159**, then the full 278-case suite (P2 is one of the
three full gates). Result recorded below when it lands.

### THE THESIS TEST PASSES

A card played on **day 10** starts a promise arc. Its payoff fires on **day 90** — across a
save/load cycle, a speed change, and an unrelated card that lands on the desk on day 50 and is
still sitting there untouched when the arc closes. The payoff's condition reads
`{"history": "chose", "event": "fixture.thesis_open", "option": "promise"}` — a choice made 80
days earlier, which is the exact query the old engine had no way to ask.

Verified alongside it: the schedule survives JSON with **no Resource anywhere in it**, a speed
change moves no due date (every day field is absolute, so there is no arithmetic to distort),
and nothing fires early on any of the 79 intervening days.

### The second variant — the subject leaves on day 60

All three §10.5 policies proven:

- **`reassign` pauses rather than kills.** The arc goes to `awaiting_subject`, its scheduled
  step leaves the global schedule, and — the part the GDD's own §16.3 and §10.5 contradict each
  other about — it is held as a **relative** delay. A new subject on day 69 resumes it with the
  step still 0 days out rather than dumping nine days of frozen steps at once.
- **The 14-day timeout falls to `close`**, so an arc cannot wait for a subject for the rest of
  the run.
- **A promise arc may not `fade` and may not carry empty penalties** (§10.6) — asserted on the
  fixture definition.

Also proven: **aborting an arc sweeps four surfaces, not one.** §20 G3 mentions only the
schedule; §16.1 lists `queue[]`, `papers[]`, `schedule[]` and `ticker_queue` as separate
arrays. Sweeping one of four is how a close-policy arc fires its closing card while a queued
step of the same arc is still behind it — the player watches the arc close, then watches it
continue. And a save naming a vanished arc definition is dropped with a log rather than
crashing (approved directive).

### Also landed

`EvEngine` (the eleven-step tick, with the signal buffer and the floor's empty-report counter)
· `EvDice` (**FNV-1a**, written out in-project per A5 — `String.hash()` is not documented-stable
across engine versions and these outcomes are save-critical) · the fixture arc content.

### P6a work started early (data only, while the suite held the tree)

Content migration does not touch `scripts/`, so it ran in parallel with the P2 gate.

- **15 authored cards ported** onto the new schema, into `data/events/cards/{product,customer}/`.
  Ids renamed from `ev_<domain>_<number>_<slug>` to §3.1's `category.name` — the numbers were
  authoring order from a corpus that has been rewritten twice.
- **Every copy lie the audit found is closed.** `product.critical_bug`'s *"Çıkışı ertele, çöz"*
  now actually delays the launch; `product.final_polish`'s *"Vakit harca"* now spends the time;
  `customer.referral`'s *"özellik sözü ver"* now creates the promise; `customer.frank_intro`'s
  *"Satış'a git"* now goes to Sales. The rule applied throughout: **the prose is right and the
  effect is missing**, so the fix adds the cost rather than softening the sentence.
- **Option ids are semantic** (`delay_and_fix`, `ship_it`) rather than `opt_1`/`opt_2`. §3.3
  makes the id independent of the label; a positional index is what made the old suite fragile
  when a conditional row appeared or vanished.
- **The trademark is gone**: `producthunt` → the canon fictional `vitrin`, in the modifier value
  and the card id both. The player-facing copy already used the fictional name correctly.
- **Three `ev_debug_*` fixtures deleted.** Never loaded (the loader skipped the prefix), Turkish
  only, and one of them carries an option labelled `[NOT IMPLEMENTED]`. Nothing in the smoke
  suite references them; `main.gd:1002`'s `--oda-shot=event` does, and is repointed at a worked
  example when the tree frees up.

**Pending, blocked on the tree:** three verbs the ported content now needs
(`set_game_flag` with a whitelist, `mentor_advisory`, and the `urun.days_since_launch` seam),
plus the `--oda-shot=event` repoint.

### P3/P4/P6a drafted while the P2 gate held the tree

Everything below is written and reviewed in the scratchpad, waiting for the suite to release
`scripts/`. Data-only work landed directly.

- **P3 · linter** — every §17 rule class plus three the build added (A1's arc-step expiry,
  R8a's demotable-interrupt trio, and the flag-that-should-be-a-seam mistake my own worked
  examples made first). Baseline by fingerprint, so changing a card brings its finding back.
- **P3 · `--why-fire=<id>`** — calls the real gate and prints the real `Verdict`. It never
  re-derives an answer, because a panel that computes its own is worse than none: it sends you
  looking in the wrong place with confidence.
- **P3 · two-mode harness** — guided (arc completion is an ERROR condition) and random
  (coverage is a WARNING, because random play is not player play). Save/load every 50 days in
  both. Reports run length against `SOFT_CAP_DAY`, which is the directive about whether day 730
  is reachable at all.
- **P3 · vocabulary generator** — regenerates the writer-facing doc from the engine's own
  tables, preserving three hand-written sections between markers.
- **P4 · tempo governor** — four layers, phase multipliers on layers 3 and 4 only, and the
  demotion applied top-down by priority rather than to whichever card arrived third.
- **P4 · Presenter** — an adapter rather than a modal rewrite, because UI design is out of
  scope and `event_modal.gd`'s locked-option treatment is correct and hard-won.
- **P6a · 40 cards ported**, all copy lies closed, three `ev_debug_*` deleted.
- **P6a · the 19 injection sites** planned one by one: every one loses its push and its private
  latch, and keeps its state write — because the state write is what the card's condition reads.

### R8a caught 51 problems in my own ported content, before the linter existed

The rule: **a non-critical interrupt is demotable (§13.2), so it must carry the paper trio.**
Otherwise the demotion manufactures a card the linter would have rejected — `expires_days` is
paper-only by §3.1, and §17.7 makes a paper without one an error.

Seventeen ported cards were demotable interrupts with no expiry at all. Their expiry
consequence is **the passive option happening**, which is honest — not answering *is* choosing
the thing that needs no answer — and needed no new mechanic. Positive economic deltas are
stripped from those lists, because §8.3 lets an expiry charge and never pay. Each got one
`expire_note` line in both locales, because §12.4 forbids a silent expiry and the note is the
only trace a deferred decision leaves.

**40 cards now pass a full pre-lint sanity check with zero problems:** both locales present,
option-id parity across locales, option ids matching their text block, the paper trio wherever
it is owed, every effect verb in the vocabulary, no positive economic delta on any expiry, and
A1's arc verb on every expirable arc step.

That check runs in Python against the JSON, which is why it could run while the suite held the
tree. The real linter re-runs all of it inside the engine, where it can also resolve seams.

## P2 · GATE RESULT — 275/278

| # | phase | smoke scope | result | state |
|---|---|---|---|---|
| P2 | arcs · schedule · executor | **FULL 278** | **275 pass · 3 fail** | thesis test green; all 3 failures attributable outside this task |

### The three failures

**1-2 · `save_migration_v7_to_v8` · `trait_migration_real_load` — red before this task, out of
scope by ruling.** Both write sub-9 save fixtures through the real load path;
`MIN_LOADABLE_VERSION` refuses them before the migration ladder runs. Reproduced on demand at
P0 and untouched since. Painting them green would manufacture an assurance that does not exist.

**3 · `b2c_satisfaction_gate_experience` — NEW, and the mechanism points away from this task.**

The case asserts that with the experience axis below its gate and the bug count at zero, one
simulated day moves B2C satisfaction by nothing. It moved by **−1**, which is exactly the bug
branch of `SalesSystem._tick_satisfaction` (`bugs > SATISFACTION_BUG_GATE` → −1).

The mechanism is a fixture-ordering fragility that has nothing to do with events: the case sets
`mvp_live_bug_count = 0` **once**, before its first sub-case, and then runs two more simulated
days. `ProductSystem`'s live-bug accrual (`product_system.gd:1505-1521`) **overwrites that flag
every daily tick** — `rate = audience × WEAR_AUD_COEF + complexity × WEAR_CPLX_COEF −
expertise × WEAR_TECH_REDUCER`, floored positive — and the seed leaves an audience of 200. Once
the accrued count passes 5, the second sub-case gets its −1 and the assertion is measuring bug
accrual rather than the experience gate.

**Why it is not this task's:** nothing the event rebuild touched feeds bug accrual or B2C
satisfaction. The facade is a set of pure forwards; `trigger_ending` gained an argument; the
schema constants moved; the new engine files are not on the old engine's path; the three
deleted `ev_debug_*` cards were never loaded by any build. `product_system.gd`, which owns the
accrual and its `WEAR_*` coefficients, was **last written at 12:46 today** — the concurrent R&D
and Product session, mid-flight.

**Not fixed, deliberately.** Repairing it means either editing a case to accommodate a
behaviour change I did not make and do not understand, or editing another agent's in-flight
file. Filed for the Product owner with the mechanism above; the fix is one line in the case —
re-zero the flag before each sub-case — but it should be made by whoever knows whether the
accrual rate is intended.
# staged for docs/EVENT_ENGINE_PHASE_LOG.md — append after the suite finishes

## P6a · the swap and the retirement — 2026-08-25

**Smoke scope:** `all_scripts_load` and 25 targeted cases during the work; full 278-case suite
at the gate.

**State.** `EventGate` now forwards to the new engine. All nineteen injection sites are
retired, the four card-building factories are gone, and no production file calls
`EventManager` any more — every remaining mention in `scripts/` is a comment. The old engine is
still loaded as an autoload and still owns the `"events"` save block; that is P6b.

### What the swap turned up

The port was not a transcription and the following are the defects it surfaced. Each is a
finding about the migration, not about the engine.

| # | what | why it mattered |
|---|---|---|
| 1 | Four cards triggered on a signal emitted by their own consequence — `team.resignation` on `employee_departed`, `product.first_ship` / `product.version_ship` on `version_shipped`, `product.design_round_intro` on a signal that only fires at the round cap | each would have fired exactly one beat late, forever, or never |
| 2 | `product.version_ship` was `class: info` with an empty option, but its original's single option is what CALLS `ship_active_build` | `active_build` would never clear after a version ship |
| 3 | `funding.hire_nudge` was `class: info` and untagged — a deterministic one-shot beat left to the weighted pool | Frank's line would arrive on some runs and not others, for no reason the player could see |
| 4 | 41 localization keys renamed during authoring, none of them with a CSV row | 41 raw ALL-CAPS tokens on screen; 34 repointed onto the rows that already existed, 7 written with both locales |
| 5 | Promise and discount rows on the three request cards and the escalation card carried no lock | unlimited promises and uncapped discounts through a channel the retention card had closed |
| 6 | Four customer cards had no scope block, so every customer-scoped effect resolved to nothing | the old executor's default target (`lowest_satisfaction` in the event's market) had not been ported with the effects |
| 7 | `churn_customer` had been flattened to `remove` | one consumer complaint would have deleted the entire B2C userbase |
| 8 | `customer.retention`'s discount row carried `add_reputation: +1`; the constant is `-1` | a positive chip on a negative outcome |
| 9 | The engine emitted none of `event_triggered` / `modal_requested` / `event_resolved` | no card could reach the screen at all |
| 10 | Papers were queued as well as placed on the desk | `has_pending()` gates the clock and the save, so a paper would have held the game paused and unsaveable for a week — and `pump()` would have mounted it as a modal anyway |
| 11 | `start_vc_meeting` read a literal `vc_id` off the effect | no card can name an investor at authoring time |
| 12 | The gate cards' conditions re-asked the gate's own thresholds | §2.3's ratchet never re-evaluates, so a dip in MRR would have silenced the card with the door still open |

### Deliberate behaviour changes

- **The Series A re-ask clock runs from the FIRE, not from the answer.** `gate_prompt_day` was
  re-stamped on decline, so a player who sat on the card for four days bought nine days of
  quiet. §3.1 measures a cooldown from the last time the card was shown.
- **`customer.retention` cannot be re-opened the same day it was answered** (one-day entity
  cooldown). The rescue window itself is unchanged.
- **The hourly path is capped by `MAX_INTERRUPTS_PER_DAY`, not by a hard 1/day.** The old cap
  was in code with no name; §13's budget governs every interrupt.
- **`tick: "request"`** is a new value: a card no clock sweeps, reachable only by a named
  proposer. `Origin.REQUEST` skips G4's clock match — `tick` says which clock SWEEPS a card,
  not who may name it.


### More the swap turned up, after the first full-suite pass

| # | what | why it mattered |
|---|---|---|
| 13 | `_seed_save_world` left a card ON SCREEN, and `can_save()` refuses while one is | every save case in the suite failed at `SaveManager.save()` rather than at anything it tested. The fixture leaves a PAPER now — engine state a save is allowed to carry, and the shape a real player's save has |
| 14 | `loc_b4_derived_keys` derived gate copy from `GATES.copy_key` / `body_count` | both fields moved onto the cards with the copy; the case walks the card's text block instead, which also catches an unwired variant the counted form could not |
| 15 | `arc_fixture_subject` named a step card that was never written | the probe schedules, freezes and thaws it without ever firing it, so a dangling reference survived every gate. §17.1 |
| 16 | `EvLint` and `EvTempo` disagreed about "demotable" | the governor exempts arc steps from the day's budget (§13.5); the linter tested only `critical`, so every arc-step interrupt was required to carry an expiry trio for a demotion that cannot happen to it. One definition now — `EvTempo.budget_exempt`, called by both |
| 17 | two authored one-shots were left to the weighted pool | `customer.frank_intro` (the card that hands the player their first B2B prospect) and `product.paid_tier` (the card that opens B2C revenue). A gateway beat decided by a draw arrives on some runs and not others, with nothing to point at |

### Attributable elsewhere, unchanged

- **`b2c_satisfaction_gate_experience`** — diagnosed at the P2 gate and unchanged since: the
  case zeroes `mvp_live_bug_count` once while `ProductSystem`'s live-bug accrual rewrites it
  every tick. Filed as Q24 against the concurrent Product work.
- **`save_migration_v7_to_v8`** and **`trait_migration_real_load`** — red before this task
  (`MIN_LOADABLE_VERSION` refuses their sub-9 fixtures), out of scope by ruling. The related
  finding stands: the three sibling cases that pass do so by calling `_migrate_*` directly, so
  none of the five proves the ladder runs.
## P6a exit gate — 2026-08-26

**Smoke scope:** full suite. **286/289.**

The suite grew from 278 to 289: eleven cases the engine brought with it — one per invariant,
plus dice stability, chip coverage, and the thesis test twice (once headless, once through the
Presenter).

Three red, none of them this task's:

- `b2c_satisfaction_gate_experience` — the concurrent Product session (Q24).
- `save_migration_v7_to_v8` and `trait_migration_real_load` — red before this task began, left
  alone by ruling.

## P6b exit gate — 2026-08-26

**Smoke scope:** full suite. **286/289 — identical to P6a.**

`scripts/autoload/event_manager.gd` is deleted, its autoload row is gone, the fifteen ported
JSON files under `data/events/reactive/` are gone (the directory keeps its `.gitkeep`, like its
two empty siblings), and `GameEvent` / `EventChoice` are out of `SaveCodec.script_for_class`.
The sweep for the deleted API returns four things and no calls: two prose strings, the smoke
case's deliberately split needle, and the lint rule that forbids the API's return.

**The two gates being identical is why A4 split them.** The migration and the deletion were
separated by a green suite, so if the second number had moved, the deletion would have been the
only thing it could have been.

## P7 — 2026-08-26

Documentation closed: this log; `EVENT_ENGINE_QUESTIONS.md` (Q25–Q38 plus D1's close);
`GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` §27.4–§27.7; `EVENT_MIGRATION_LEDGER.md` (what the swap found,
seventeen defects in four families); `SEAM_REGISTRY.md` §10–§12; `EVENT_SIGNAL_MANIFEST.md`
regenerated; `TECH_SPEC.md` §9; `CLAUDE.md`. Final report per task §9.
