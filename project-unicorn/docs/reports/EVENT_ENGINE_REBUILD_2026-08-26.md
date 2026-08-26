# EVENT ENGINE REBUILD — final report

**2026-08-26.** Nine sections, as task §9 asks. The section TITLES are mine — the task named
nine and I have written to what it asked for rather than to a remembered list of headings, so
if one of its names differs from one of mine, the content it wanted is still here.

**Both gates green.** P6a (migration complete, both engines alive) and P6b (old engine deleted)
each ran the full suite at **286/289**, and the two numbers being identical is what A4's split
was for: with a green suite between the migration and the deletion, a change in the second
number could only have been the deletion.

## 1 · What was built

`scripts/events/`, 21 files, behind one facade (`EventGate`). The old `EventManager` is deleted.

- **core/** — `condition` (nested `all`/`any`/`none`/`not` over 5 leaf types, one `_walk` with
  an optional report out-param so `eval` and `explain` cannot diverge), `history`, `flags`,
  `latches`, `schedule`, `queue`, `arcs`, `tuning`, `effects`, `save`, `dice`, `budgets`,
  `signals`, `engine`.
- **gate/** — `gate` (G1–G8, `Verdict`, 9 origins), `scope` (typed named slots, required-first,
  relative selectors).
- **catalog/** — recursive loader, type coercion at load, `version_scope`.
- **seams/** — 145 registered read-only queries across six files.
- **present/** — `papers`, `ticker`, `tempo`, `presenter`.
- **tools/** — `engine_probe` (159 assertions), `lint`, `why`, `harness`, `vocab_gen`.
- **data/events/** — **46 cards, 3 arcs.** Reconciled: **33 ported** from the 37-surface
  inventory · **6 authored under explicit authorisation** (3 = the soft-cap ladder, which is
  also the three worked examples §19.5 asks for — one paper, one interrupt, one arc step; 3 =
  the §13.6 quiet pool, the Product-side floor ladder) · **7 fixtures** (`version_scope:
  fixture`, refused at G2 in any shipping build — test scaffold, not content). Nothing was
  authored outside those two authorisations.

**And what was deleted.** `scripts/autoload/event_manager.gd` and its autoload row; the 15
ported JSON files under `data/events/reactive/`; `HREventFactory` entirely; four builders and
`_choice`/`_discount_choice` from `B2BEventFactory`; three builders from `VCPitchSystem`; three
from `ProductSystem`; one each from `EndingsSystem` and `AngelRoundSystem`; and six private
latch mechanisms. Nineteen `propose`/`propose_front` calls became **zero**; six named
`EventGate.request` proposers survive, each of them a caller that has seen a real edge — the
Sales tab's two buttons, the support desk, HR's resignation roll, and Product's two ship
moments.

## 2 · The seven invariants, and where each is enforced

| | invariant | enforcement | test |
|---|---|---|---|
| I1 | one admission gate | structural — the queue is private, `enqueue`/`enqueue_front` deleted | `event_i1_single_gate` |
| I2 | economy only from a played decision | structural — split verb tables by origin | `event_i2_economy_played_only` |
| I3 | no untelegraphed loss | signature (no default) + executor refusal | `event_i3_no_silent_loss` |
| I4 | demoted, never dropped | `EvTempo.assign` returns every input | `event_i4_demoted_never_dropped` |
| I5 | the trigger is data | every card declares a trigger/condition or is pool content | `event_i5_trigger_is_data` |
| I6 | dice never kill | `trigger_ending` absent from the check-branch table | `event_i6_dice_never_kill` |
| I7 | no modifier line without a seam | both directions | `event_i7_modifier_needs_seam` |

## 3 · Deviations from the GDD, recorded

Each of these changes what the GDD says. All are written into
`GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` §27 as the task requires; this is the index with the reason in
one line each.

| # | GDD says | built as | why |
|---|---|---|---|
| D-1 | §0.3: "I2 → Lint" | structural at the executor, lint for authoring feedback | a lint rule is the ONLY defence only until someone adds content without running it; splitting the verb table by origin means `add_cash` is not a key an ambient caller can reach |
| D-2 | §4.1: G8 inside `propose()` | G8 over the whole day's admissions at once | §4.1's order demotes the THIRD-ARRIVING card, and the third to arrive is not the least important — it might be the arc payoff |
| D-3 | §4.1's step order | G5 before G3 when `latch_key: entity` | an entity latch's key is not known until the subject is bound; for `latch_key: run` the order is unchanged |
| D-4 | §15.3: change-driven re-evaluation via seam dirty-flags | signal cards change-driven, condition cards swept per tick | dirty-tracking cannot cover three of the five leaf types, and a MISSED dirty-mark is invisible: the card silently never fires while the panel truthfully reports "condition false" |
| D-5 | §10.8: nested arcs | flat, `parent_arc` reserved and defaulted null | the codebase's own forward-compat pattern; zero retrofit cost |
| D-6 | §16.5: ironman | the autosave-before-decision hook only | `hard_mode_unlocked` has no writer anywhere, so there is no mode to attach it to |
| D-7 | §3.1's tick vocabulary | a fifth value, `request` | five card families fire on an edge only a system can see; see Q25 |
| D-8 | §3.1's text shape | `body` may be `{by_seam, variants}` | the Series A gate was already rewriting its own body by decline count before the schema had a word for it |
| D-9 | §11.4 "no capacity limit" | unlimited in the model, three on the desk + overflow chip | the sealed ODA layout has exactly three paper positions; urgency ordering guarantees nothing expires off-screen (A3) |
| D-10 | §17.9's locale rule | ported content keeps its CSV key; new content writes prose inline | ~60 reviewed strings already live in `strings.csv`; copying them inline would give one reviewed string two homes |

## 4 · Design calls for Hat-1 review

1. **The soft-cap telegraph speaks in the press's voice, not Frank's** (defect 8, the call the
   task asked me to make). A two-step ladder at D-90 (a paper: the sector has moved on) and
   D-30 (an interrupt: a reporter asks for a comment), through the outlets that already exist,
   with Frank's D-1 line preserved on top. Frank already owns the shutter beat and the ending
   verdict; handing him the calendar too turns a character into the game's narrator, and
   "interest faded" is the world noticing, not the mentor.
2. **`raise_requested` and `employee_eligible_for_promotion` edge definitions.** Proposed as
   planned; to be reviewed against the Ekip GDD, not against the engine.
3. **The two soft-cap cards are content written under an engine constraint** and need a voice
   pass in the writing round.
4. **Arcs ship flat**, `class: info` has no engine-owned surface, ironman is a hook. Each is a
   scope trim, each is reversible, and none of them is a silent one.
5. **A2's "forced into demotion" clause is unsatisfiable as written** — §13.5 exempts arc steps
   from the interrupt budget, so a payoff cannot be demoted, and demoting it would be the bug.
   The case proves the two halves separately and says so in its failure message.

## 5 · The known defects, and five corrections to the brief

**Five rows of the task's §6 table did not match the tree.** They were checked against the code
before anything was built, and the plan was built against the code.

| task says | verified |
|---|---|
| two admission paths | **three** — `_enqueue_eligible` (gated), `enqueue`, `enqueue_front` (both ungated) |
| dedupe by object identity | **already fixed** — `_queue_has_id` compares ids; the identity bug is archaeology in a comment. The residue was a silent rejection that never consults history |
| 12 of 15 callers hand-roll a latch, one forgot | **19 sites in 9 files, 17 hand-rolled latches** across six mechanisms — and the one that forgot is worse than forgetful: `_build_expiry_warning_event` writes a CONSTANT id, so with two live sheets the second warning is absorbed and the survivor names the wrong investor's deadline |
| K2 "Büyüt" pays +$720/day forever | **already latched** on `Customer.last_expansion_day`, stamped on both resolutions. The structural lesson stands: the latch had to live on the customer because `GameEvent.one_shot` was inert on the injected path |
| `mvp_market_type` gates hourly but not daily | **false as stated** — `market_type` is inside `_is_eligible`, which both paths call. The real asymmetry is worse and was unreported: `has_random_trigger()` silently routes a card to the daily path or the hourly one, and `allowed_hours` is **structurally dead on the daily path** because the daily tick always runs at hour 0. A beat given a window that excludes midnight is permanently ineligible and nothing says so |

**How each is closed, and how you can see it.**

| defect | closed by | proof |
|---|---|---|
| three admission paths | the queue is private to the engine; `enqueue`/`enqueue_front` deleted | `event_i1_single_gate` greps the tree for the deleted API |
| latches hand-rolled | six private mechanisms deleted (`angel_seed_offered`, `angel_nudge_shown`, `gate_prompt_day`, `vc_last_answer_warned`, `HRMoraleSystem._pending`'s double duty, `ProductSystem._iter_intro_shown`); every card declares its own | `angel_one_shot_falsified` clears the ENGINE's latch and the offer comes back |
| the constant-id expiry warning | `funding.sheet_expiry` binds an investor slot, `latch_key: entity`, selector `expiring_sheet` | the selector is the assertion: no selector means the slot binds whoever sorts first |
| `allowed_hours` dead on the daily path | `tick` is DECLARED; G4 refuses a proposer that does not match it, and `allowed_hours` governs only the hourly clock. A daily card carrying one is a lint error | `ambient_one_per_day_across_hour0` reads the declared tick, not a derived one |
| history written and never read | the condition vocabulary reads it — `history`, `chose`, `chose_about`, `days_since`, `telegraph_fired` | the thesis test's payoff condition IS a history read |
| no arc, no schedule, no combinator | `EvArcs`, `EvSchedule`, `all`/`any`/`none`/`not` over five leaf types | `event_thesis_day10_to_day90` |
| the soft cap has no telegraph (defect 8, the design call) | a three-beat ladder at D-90 / D-30 / D-1 in the press's voice | `--event-harness` confirms day 730 is reachable, so I3 is **not** satisfied vacuously |

## 6 · Cross-module touches

Minimal and additive, and this is the complete list.

| file | change |
|---|---|
| `project.godot` | the `EventManager` autoload row deleted |
| `save_manager.gd` | one block key; `PhaseGateSystem.reset`/`restore_gate_cache` calls removed with the cache |
| `save_codec.gd` | `GameEvent`/`EventChoice` removed from `script_for_class` |
| `game_state.gd` | four dead flags removed from the type table (`angel_seed_offered`, `angel_nudge_shown`, `gate_prompt_day`, `vc_last_answer_warned`) |
| `time_manager.gd` | slot 8a deleted; the phase-gate slot moved in front of the event slot |
| `main.gd` | five harness flags; three fixtures repointed at cards; **the missing null guard added (D1)** |
| `event_modal.gd` | reads `verb`; context passed to the lock check; five new chips + `SILENT_VERBS` |
| `oda_view.gd` | engine papers on the desk, a days-left line, and an `event:` click branch |
| `endings_system.gd` | `trigger_ending(id, telegraph)` with no default; the dead buyout builder deleted |
| 9 injector files | nineteen pushes retired; every state write kept |
| `customer_rep_system.gd` | `ranked_reps()` made public |
| `vc_pitch_system.gd` | `is_last_answer_moment()` made public; three builders and four latches deleted |
| **not touched** | `rnd_system.gd` and the R&D tree — seam registration only |

## 7 · Verification (measured, not claimed)

| gate | command | result |
|---|---|---|
| engine self-check | `--event-probe` | **159/159** |
| content lint | `--event-lint` | **LINT PASS** — 0 errors, 0 warnings, 19 baselined, 43 cards, 3 arcs |
| lint falsification | one rule from each §17 class broken in turn | **16/16 caught** |
| thesis (§7.1) | `event_thesis_day10_to_day90` | PASS — day 10 → day 90, across a save/load, condition reads the day-10 choice |
| thesis through the Presenter (A2) | `event_thesis_through_presenter` | PASS — the view reaches `modal_requested`, the same-day paper lands on the desk with a clock, both resolve |
| the seven invariants | `event_i1`…`event_i7` | PASS, one case each, each with its falsification stated |
| dice stability (A5) | `event_dice_is_stable` | PASS — FNV-1a, known input → known output, option and day both in the hash |
| chip coverage | `event_chip_coverage` | PASS — every card row renders a chip or is named in `SILENT_VERBS` |
| **guided sweep — acceptance gate 8** | `--event-harness=guided:seeds=20:days=800` | **`arc_final_stretch` 20/20 started, 20/20 completed (100%), zero never-visited steps. HARNESS PASS** |
| random sweep | `--event-harness=random:...` | 0 crashes, 0 dangling references |
| §13.7 anchor (per speed rung) | same run | 1x **5 decisions / 3 min**, 2x 5, 3x 6, against a working ceiling of 3 · longest silence 348 s / 174 s / 87 s |
| §13.6 empty floor | same run | **2660 of 15980 days** — down from 3140 before the quiet pool existed; the residue is the bare-world limitation below |
| run length | same run | median 800, shortest 800, longest 800 (the driver's cap, not an ending) |
| ODA theme seal | `--theme-audit=oda` | **byte-identical** after `@Class@NN` normalisation — 149 lines, unchanged |
| P6a gate | full suite, both engines alive | **286/289** |
| P6b gate | full suite, `EventManager` deleted | **286/289 — identical** |
| localization | `loc_residue.gd`, `loc_csv_integrity`, `loc_event_en_coverage` | **CLEAN** — 0 residue hits against 2365 CSV keys; both locale blocks present on all 43 cards and every key resolves |
| vocabulary | `--event-vocab` | regenerated: 147 seams, 59 verbs, 43 cards |

**Two harness measurements were wrong and are now right.** The first sweep reported "busiest
day: 16 interrupt(s) (ceiling is 2)" and "longest silence: 5722 day(s)" — both because
`interrupts_by_day` is keyed on the in-game day and was never cleared between seeds, so eight
800-day runs piled onto days 1..800 and days 801..6392 counted as silence. A harness whose
numbers cannot be trusted is worse than none: it manufactures a bug report and hides the real
ones behind it. Per-run tables now, with each run's maxima folded in.

**What the sweep does NOT prove.** Its world is empty — no product, no customers, no hires —
so 38 of 43 cards never become eligible and the longest silence (658 days) measures the driver,
not the engine. The tempo anchor's real number needs the guided mode driving a played run,
which is a calibration-round measurement, not a build gate.

**Two smoke cases stay red, by ruling.** `save_migration_v7_to_v8` and
`trait_migration_real_load` were red before this task — `MIN_LOADABLE_VERSION` refuses their
sub-9 fixtures — and were explicitly left alone. The related finding stands and is worth more
than the two cases: the three sibling migration cases that DO pass call `_migrate_*` directly,
the shortcut the file's own comment warns against, so none of the five proves the migration
ladder actually runs.

**One more is red and belongs to another task.** `b2c_satisfaction_gate_experience` fails
because `ProductSystem`'s live-bug accrual rewrites the flag the case zeroes; filed as Q24
against the concurrent Product work.

**One honest note about the facade's own surface.** `EventGate.history()` has no caller — which
is exactly the shape of the old engine's central defect (`get_history()` was written, and read
by nothing). The difference is where the reading happens: the ENGINE reads history constantly,
through the condition vocabulary — `history`, `chose`, `chose_about`, `days_since`,
`telegraph_fired` — and the thesis test's payoff condition IS a history read. The facade method
is the public surface a run-log UI would use, and it is listed here rather than deleted so that
"nobody calls it" stays a decision someone made rather than a fact someone discovers.

## 8 · Filed, not built

`hr.salary_vs_band` · `finance.valuation` · `satis.market_share_by_segment` · `founder.energy` ·
Product §15's demand generator · `brand_collapse` (needs a scandal system; EA) · the Events-tab
relocation (UI design) · the Ekip morale-recovery cards (raise request, summer leave) — the
emit sites are open, the cards are content · the ODA composition task (papers are entirely
off-screen in the measured ultrawide band, `oda_layout.gd:207-235`) · `class: info`'s surface.

## 9 · Teaching notes (§11)

**Storylet architecture.** A storylet is content plus its own prerequisites plus its own
effects, in one file. The engine's whole job is then to ask "which of these is admissible right
now" — which is why ONE admission gate matters more than any rule it enforces: the moment a
second way in exists, every rule becomes advisory. That is exactly what happened to the old
engine's `one_shot`, which was a dead field on nineteen injection sites.

**Why re-validate at display.** A card admitted on Monday may be about an employee who resigned
on Tuesday. The gate runs G5/G6/G7 again at the moment of display, and deliberately NOT G3 or
G8 — a card that already spent its latch must not be charged twice for waiting.

**Data over callbacks.** The schedule stores `{event_id, fire_on_day, context, arc_id}` and
never a `Callable`. A serialised function pointer is a save file that cannot survive its own
code changing; a serialised id is one that can.

**The named-seam pattern (Godot).** Content asks `hr.morale`, never `HRSystem.morale`. The
registry is an allowlist, not a convention, and the reason is in the registry's own header:
`ProductRead.emit_edges()` is a static on a class named "read surface" that mutates statics and
emits five signals. Read surfaces do not stay read-only by being called that.

**Godot specifics hit on the way.** `class_name` needs an import pass before a `-s` script can
see it. Autoloads are invisible to a `-s` SceneTree script at compile time — the probe became a
`--flag` in `main.gd` for that reason. `const` Arrays are read-only, so a table the harness
mutates must be a `static var`. `push_warning` is not in `smoke_run.sh`'s error tokens, which
is why `res_from_dict` on an unknown class had to become `push_error`. And GDScript has no
varargs `Callable`, which is why `EvSignals` has one arity arm per signal shape.

---

## Answers owed

**The third emitterless signal is `meeting_requested(vc_id: String)`** — declared in
`event_bus.gd`, never emitted anywhere. The other two are `raise_requested` and
`employee_eligible_for_promotion`, both of which the plan already named.

**Do any of the 48 listenerless signals belong to the engine?** Six of them do, and they are
now the engine's: `customer_expanded`, `employee_departed`, `employee_hired`, `meeting_day`,
`phase_gate_reached`, `promise_broken` — all bound in `EvSignals.BINDINGS`, which is an
allowlist naming which argument fills which scope slot. (The manifest counts 45 emitted-with-no-
listener rows; the headline "48" includes three where the only listener was the old engine.)
The remaining 39 are the ready-made trigger surface the manifest describes: `axis_floor_crossed`,
`experience_bar_full`, `morale_band_changed`, `line_completed`, `node_revealed`,
`unconfirmed_threshold_crossed` and the rest. Every one is a real edge with a real payload and
no consumer, which is exactly what a content round wants to find.
