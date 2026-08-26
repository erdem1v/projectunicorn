# EVENT ENGINE REBUILD — questions I did not stop to ask

Every item is something I would have surfaced. Instead: what I would have asked, the call I
made, and **how expensive it is to reverse** — which is the number that decides whether a
morning needs to act on it or can just note it.

Reversal cost legend: **cheap** = a constant or one file · **moderate** = a day's work ·
**expensive** = re-touches content or save shape.

---

## Q1 · Smoke cadence per phase

**Would have asked:** whether every phase should pay the full 278-case suite (~3.5 h) or run
targeted cases and gate fully at boundaries.
**Call:** settled by ruling after I asked once — targeted per phase, full suite at exactly
three gates: **P2 exit, P6a exit, P6b exit.**
**Reversal:** cheap. It is a scheduling choice, not a code one.

## Q2 · Phase numbering after the facade replaced the strangler

**Would have asked:** which phase now does the swap, since there is no coexistence window.
**Call:** the new engine cannot drive the game until content exists for it, so the facade's
internals swap **in P6a, together with the migration** — they are the same act. Everything
before that is verified through `--event-probe` and the harness against the three worked
example cards, not against the live corpus. That keeps the suite from sitting broadly red
across four phases, which is the failure mode `endgame_smoke.gd:12452` explicitly warns about.
**Consequence for A2:** the thesis test through the real Presenter lands at **P4 exit**
(presentation), driven with the worked example cards. The substance is unchanged — real
Presenter, real modal path, payoff forced into demotion at least once.
**Consequence for P6b:** its shape shrank. There is no `main.gd` OR-guard to remove, because
there was never a second engine. P6b is: delete `event_manager.gd`, arm the lint rule, done.
**Reversal:** moderate.

## Q3 · `max_fires` and the default cooldown

**Would have asked:** does a card declaring `max_fires: 2` also inherit the default 30-day
cooldown?
**Call:** no. §3.1 writes the latch as `one_shot | max_fires:N | cooldown_days:N` — alternatives,
not a stack — so the default applies only to a card that names no brake at all. "How many times
ever" and "how soon again" are different questions, and the second one is `min_gap_days`
(§13.3 layer 1). My own probe caught the stacked version: a `max_fires: 2` card could never
reach its second fire.
**Reversal:** cheap — one function, `EvLatches._cooldown_of`.

## Q4 · Cards as Dictionaries rather than Resources

**Would have asked:** should the new card type be a Resource like `GameEvent` was?
**Call:** no. §16.1 persists ids, and the new engine has no synthetic cards, so a card never
round-trips. Plain Dictionaries also stay out of `SaveCodec.script_for_class` — whose
unknown-class path is a `push_warning`, which is **not** in `smoke_run.sh`'s error-token list,
so an unregistered card class would have been silent data loss with a green suite.
**Reversal:** expensive. It shapes the loader, the queue and the save block.

## Q5 · G5 before G3 for entity-keyed latches

**Would have asked:** §4.1 lists the gate as G3 then G5, but an entity-keyed latch is keyed on
the subject, and the subject comes out of G5.
**Call:** for `latch_key: entity`, G5 runs first. For `latch_key: run` — the default and the
majority — G3 stays first where it is cheap. The ordering's intent (cheap filters early) is
kept; the dependency is honoured. Recorded for §27.
**Reversal:** cheap.

## Q6 · `version_scope` with no release-tier system in the codebase

**Would have asked:** how should G2's "demo / EA / full" check work when the tree has no tier
concept at all (`grep` finds none, and `hard_mode_unlocked` has no writer either)?
**Call:** one constant, `EvTuning.SHIPPED_SCOPES = ["demo"]`, and a `version_scope` field on
the card defaulting to `demo`. Content marked `ea`/`full` stays out of the pool without anyone
having to build a tier system first. Same forward-compatible shape as §11.6's tutorial hook.
**Reversal:** cheap.

## Q7 · The engine's flags versus `GameState.flags`

**Would have asked:** the old `set_flag` modifier could write any of the ~83 registered
`GameState` flags, which is a card reaching past every seam into another domain's state —
exactly what the WRITE-THROUGH LAW forbids. Do I keep that?
**Call:** no. `set_flag` writes the engine's own store; anything touching system state gets a
named effect verb through the owning system's seam. **Nothing moves storage** — the only two
flags content writes today (`tech_debt_birikti`, `critical_bug_unfixed`) are genuinely read by
`ProductSystem` and stay exactly where they are, becoming named verbs rather than changing
house. That matters for A6: a flag that changed location would be looked for in the wrong place
by any save written before the move, and the condition would silently read false.
**Reversal:** moderate.

## Q8 · Selector determinism

**Would have asked:** should "the lowest-morale employee" break ties randomly?
**Call:** no. Every selector is deterministic, ties broken by id. A reload must not be able to
reshuffle who a card is about — §9.3 closes save-scumming on the dice, and leaving it open on
the *subject* would be the same exploit through a different door.
**Reversal:** cheap.

## Q9 · The two red save-migration cases

**Would have asked:** repoint them, fix them, or leave them?
**Call:** settled by ruling — **leave them red, out of scope, do not touch.** Marked "red before
this task". The related finding, which is the more useful half: their three sibling cases pass
only by calling `_migrate_*` directly, the shortcut `endgame_smoke.gd:8758` warns against — so
**none of the five actually proves the migration ladder runs end to end.** That is a finding
for the save owner, not a repair for this task.
**Reversal:** n/a.

---

## Defects found in other modules, filed not fixed

### D1 · `main.gd:2275-2290` mounts the event modal with no null guard

`_on_event_modal_requested` assigns `_event_modal` without checking it is null first. It is the
**only** modal opener in that file that does not — settings (`:2324`), confirm (`:2352`),
system menu (`:2392`), month summary (`:2543`), ending (`:2580`), meeting (`:2610`), term table
(`:2674`) and the R&D card (`:2424`) all guard.

It is safe today only by accident: `_pump_queue` refuses to pump while a card is active, so the
signal cannot fire twice. That makes it a **latent fragility, not a live bug** — but the thing
protecting it lives in a different file, and anything that ever emits `modal_requested` twice
orphans a `Control` in `ModalLayer` with no pointer to it. `game_shell.gd:151-153` then guards
on a child *count*, so Space, 1/2/3 and Esc die permanently; `event_modal.gd` has no
`_unhandled_input` and no `ui_cancel`, so there is no keyboard way out. No pause, no system
menu, no save, no quit.

**Not fixed here** — it is `main.gd`'s modal lifecycle, not the event engine, and a one-line
guard added mid-rebuild would be indistinguishable from rebuild damage if it ever misbehaved.
**Cost to fix: minutes.** One `if _event_modal != null: return`.

### D2 · `game_shell.gd:149-150` documents an Esc path that does not exist

The comment says an event modal's own `ui_cancel` closes it. `event_modal.gd` has neither
`_unhandled_input` nor any `ui_cancel` handler — only `_on_choice_input`. An event modal is
unconditionally modal and always has been. The comment is the only thing that says otherwise.
**Not fixed** — it is a comment in another module's input router. **Cost: one line.**

## Q10 · Where the tempo budget assigns a card's class

**Would have asked:** §4.1 puts G8 inside `propose()`, which demotes the *third-arriving* card
of the day.
**Call:** collect the day's admissions and assign classes top-down by §11.2 priority at step
(j) of the tick, not per proposal. The third card to arrive is not the least important one — it
might be the arc payoff, and demoting a payoff because two rival-news cards happened to be
proposed earlier is precisely what I4 exists to prevent. Deviation from §4.1's placement,
recorded for §27.
**Reversal:** cheap — one function, `EvEngine._step_assign_classes`.

## Q11 · Signals buffer instead of proposing inline

**Would have asked:** the GDD does not say when a signal-triggered card is proposed.
**Call:** signals fire during slots 1-6, while Product, HR and Sales are still moving, so
proposing inline would admit a slot-1 edge before Finance had run. They buffer and drain at
step (f), in emission order. `time_manager.gd:357-368` already documents this hazard for the
old engine — "on a day when two systems both inject, the FIRST caller owns the modal" — and
AngelRoundSystem is dispatched before PhaseGateSystem purely to work around it. Buffering turns
an ordering accident into data.
**Reversal:** moderate.

## Q12 · The sweep, versus seam-level dirty-flagging

**Would have asked:** §15.3 wants change-driven re-evaluation; is a per-tick sweep a violation?
**Call:** signal-triggered cards ARE change-driven — proposed from the handler. Condition
cards are swept once per tick, never per frame. Dirty-flagging cannot cover three of the five
leaf types: `days_since_flag` depends on the day counter, so its cards are unconditionally
dirty every tick and the whole Frank corpus is built on that primitive; a selector like "the
lowest-morale employee" is dirty on every morale signal. And a missed dirty-mark is
**invisible** — the card silently never fires while the panel truthfully reports "condition
false", which is the same failure class as `get_history()` having no callers. Acceptance gate
14's hard requirement (never per-frame) holds. The deviation from the letter is deliberate.
**Reversal:** moderate — `depends_on` can be generated from the tree later if the harness ever
measures a cost.

## Q13 · `EvTuning.SHIPPED_SCOPES` is a `static var`, not a `const`

**Would have asked:** nothing, but it looks wrong at a glance and deserves a note.
**Call:** the probe widens it to admit `fixture`-scope cards for its own run and narrows it
again. A `const` Array is read-only in GDScript. That is the only sanctioned mutation;
production code reads and never writes.
**Reversal:** cheap.

## Q14 · Fixture content lives in the shipped tree

**Would have asked:** where should engine test content live?
**Call:** `data/events/cards/_fixtures/`, with `"version_scope": "fixture"` on every card. G2
refuses them structurally in any normal build — the same mechanism that keeps EA content out
of the demo pool, rather than a second "is this a test" flag that could be forgotten. Proven
by an assertion that the fixture card is refused at G2 with the scope list untouched.
**Reversal:** cheap.

## Q15 · The soft-cap telegraph — voice and shape (task §6 defect 8)

**Would have asked:** who warns the player that the run is nearly over, and how loudly?
**Call:** a **three-rung ladder in the press's voice, with Frank's D-1 line preserved on top**,
built as a `world` arc so the three beats are one thing rather than three unrelated cards.

- **D-90 · a paper.** The Sector Telegraph's annual file lists the cohort; most names have a
  round, an acquisition or a closure beside them, and yours still says what it said on day one.
  Low stakes, 30 days to answer, no cost either way. The point is that the player *hears the
  clock*, not that they act.
- **D-30 · an interrupt.** A reporter wants a comment for the year-end round-up. Both options
  cost something real and neither is the wise one.
- **D-1 · Frank.** One line, one option, no cost.

**Why not Frank for all three.** He already owns the shutter beat and the ending verdict. Give
him the calendar as well and a character becomes the game's narrator — and "interest faded" is
precisely the *world* noticing, not the mentor. GDD v2 ch.13 rules that Frank warns at D-1, and
that ruling is kept rather than replaced; the press ladder sits under it.

**Verification owed:** `SOFT_CAP_DAY` is 730. If no real run gets near it this is content
nobody sees and I3 is satisfied vacuously. The harness sweep reports mean and longest run
length for exactly this reason.

**These are also GDD §19.5's three worked examples** — one interrupt, one paper, one arc step,
each with a complete bilingual text block. One piece of work, two deliverables, and the
examples are real shipping content rather than throwaway samples.

**Needs a voice pass in the writing round.** They were written under an engine constraint by
the engine's author, not by the writer.
**Reversal:** cheap for the copy, moderate for the ladder's shape.

## Q16 · No GitHub Actions workflow

**Would have asked:** already settled by ruling. Recorded for completeness.
**Call:** dropped. One folder, one branch, no pull-request flow for a workflow to trigger on.
The `.githooks/pre-commit` hook is the whole mechanical gate; enabling it is one `git config`
command left for Erdem, because an agent may not run git here.
The hook runs the content linter and the localization residue check, and **deliberately does
not** run the 278-case suite — a commit hook that takes hours only teaches people `--no-verify`.
**Reversal:** cheap.

## Q17 · A bug in my own worked examples, caught by writing them

**Would have asked:** nothing — but it is the best argument for §19.5 existing, so it is worth
recording. My first draft of all three cards used `{"flag_unset": "series_a_closed"}`. That
flag is `GameState` state, not engine memory, so the engine's store has never heard of it and
`flag_unset` would have read **true forever** — the cards would have fired correctly right up
until the player closed a Series A, and then kept firing.

This is exactly the failure §19.5 predicts: "the schema works on paper and jams in practice,
and we want to see that at the plan stage rather than at card 12". It jammed at card 1.

Fixed to read `investor.series_a_closed` through its seam, and it becomes a lint rule: a
`flag`/`flag_unset` leaf naming something that is a registered seam is almost always this
mistake.
**Reversal:** n/a, already fixed.

## Q18 · 42 dash violations in copy I did not write

**Would have asked:** the ported cards carry 42 em dashes — 16 in bodies, 26 in option labels.
§17.8 makes a dash in a card body a build-stopping **E**. Do I rewrite them?

**Call:** no, and the linter does not pretend they are fine either.

- **Rewriting is out of scope.** Task §5.2 puts content authoring outside this rebuild, and
  these are director-approved bodies from the 2026-07-14 editorial pass. The dash ban arrived
  *after* them (Content Laws, then the Frank v6 pass), which is why `FRANK_ORPHANS.md` already
  tracks the remaining live dashes as known open work rather than as damage.
- **Baselining them as accepted would be dishonest.** §17.10's baseline is for *warnings*
  ("bilinen ve kabul edilmiş **uyarılar**"), and burying 16 build-stopping errors in it would
  manufacture an assurance that does not exist — which is the same objection that keeps the two
  red migration cases red.

**So the linter distinguishes inherited copy from new copy, mechanically.** Every ported card
carries `_ported_from`. A dash finding on a card with that marker is reported as **W, with the
old id named and a note that it is filed to the writing round**. A dash on a card without it is
**E**. New content cannot acquire the defect; old content cannot hide it.

The count is printed every run and **may only fall** — the same ratchet shape as
`LOC_EVENT_EN_PENDING`, which is already the project's idiom for exactly this situation.

**One correction to my own first draft of the rule:** §17.8 says *"Kart gövdesinde tire"* — the
card BODY. Option labels are not named. I had linted labels as errors too, which was stricter
than the spec. Labels are W regardless of provenance, because the audit's separate finding
about them is real and worth surfacing: **13 of 40 choice labels are `action — justification`,
and several of those justifications pre-judge the choice for the player**, which the EVENT
AUTHORING LAW forbids outright ("no choice pre-labels its own wisdom"). That is a writing-round
job with a real editorial reason, not a punctuation cleanup.
**Reversal:** cheap — one branch in the linter.

## Q19 · A paper's last-day warning — a second card, or the same one louder?

**Would have asked:** §12.4 says *"son 1 günde kalan kağıt için `class: interrupt` bir uyarı
kartı ateşlenir"*. Read one way that is a second card with its own text.
**Call:** the paper itself is promoted to `interrupt` on its last day. A separate warning card
would need its own body, its own translation rows and its own lint exemptions **for every paper
in the game**, and the player's experience is identical either way: the thing they deferred is
now in front of them. It also composes correctly with §13.5, which exempts the last-day warning
from the tempo budget — a promoted paper carries that exemption instead of competing for an
interrupt slot with the cards that arrived today.
**Caught by re-reading my own draft**, which proposed a card id (`<id>.last_call`) that no
catalogue entry carries. It would have failed silently at G1 every time, and a paper would have
expired with no warning at all.
**Reversal:** cheap.

## Q20 · `set_game_flag` and the two-name whitelist

**Would have asked:** the ported product cards write `tech_debt_birikti` and
`critical_bug_unfixed`, which `ProductSystem` genuinely reads. Do I keep a generic flag verb?
**Call:** no. A whitelisted verb admitting **exactly those two names**, refusing anything else
loudly. The old `set_flag` could write any of ~83 registered GameState keys — a card reaching
past every seam into another domain's state, which the WRITE-THROUGH LAW forbids outright. Two
authored cards walked through that door and both are legitimate; the door narrows to them.
Adding a third name is a design decision someone makes on purpose, not a string someone types.
**Reversal:** cheap — one constant.

## Q21 · Ported text keeps its CSV key

**Would have asked:** §3.2 puts card text inside the card. The code-built families' text is
already in `strings.csv` — about 60 rows, reviewed, and gated by `loc_csv_integrity`.
**Call:** a text value matching `^[A-Z][A-Z0-9_]{2,}$` resolves through `TranslationServer`;
anything else is literal prose. New content writes prose inline (the GDD's shape), ported
content keeps its key until the writing round rewrites it. Copying 60 reviewed strings into
JSON would give each one two homes, and they would drift the first time either moved.
**A deviation from §3.2, taken knowingly.**
**Reversal:** moderate — it is one branch in the Presenter, but undoing it means writing 60
strings into JSON by hand.

## Q22 · Variant text, narrowly

**Would have asked:** the Series A gate rewrites its own body by decline count today
(`phase_gate_system.gd:266-276`). The schema has no word for that, and
`EVENT_POOL_DESIGN_v1` §5.7 asks for variant text generally.
**Call:** `body` may be `{by_seam, variants}`. Delivered for the one card that already needs
it rather than as a general facility — a missing variant falls back to the lowest key, so a
seam growing past the authored range degrades to the first body rather than to an empty card.
The general §5.7 request (2-3 bodies so a repeating card never reads twice the same) stays
filed; this is not it.
**Reversal:** cheap.

## Q23 · The Sales tab's two buttons survive, as proposers

**Would have asked:** "İlgilen →" and "Büyüt" let the player pull a card forward. Is that a
second admission path?
**Call:** they survive, and they go through the gate like everything else —
`EvEngine.request(id, context)`. A player asking to deal with an account now is a real thing
and deleting it would be a feature loss nobody asked for. What goes is the *bypass*: those two
sites reached into `EventManager._active_event_id` **from a tab** to make their own push safe,
which is the shape I1 exists to delete. The gate refuses a duplicate on its own.
**Reversal:** cheap.

## Q24 · A third smoke failure appeared that is not mine

**Would have asked:** `b2c_satisfaction_gate_experience` fails at the P2 gate. Do I fix it?
**Call:** no. Diagnosed, filed, untouched.

The case measures the experience gate but is actually measuring **live-bug accrual**: it zeroes
`mvp_live_bug_count` once and then simulates three days, while `ProductSystem` rewrites that
flag on every daily tick. Once the accrued count passes 5, the bug branch of
`SalesSystem._tick_satisfaction` fires and satisfaction drifts −1 where the case expects 0.

Nothing in the event rebuild feeds bug accrual or B2C satisfaction, and `product_system.gd` —
which owns both the accrual and its `WEAR_*` coefficients — was last written **at 12:46 today**
by the concurrent Product/R&D session.

Fixing it would mean editing either a case to accommodate a behaviour change I did not make, or
another agent's file while they are in it. The fix is one line (re-zero the flag before each
sub-case) and it belongs to whoever knows whether the current accrual rate is intended.
**Reversal:** n/a — nothing was changed.

---

## P6a · the swap (2026-08-25 / 26)

Each entry: what I would have asked, the call I made instead, and what reversing it costs.

### Q25 · `tick: "request"` — a fifth clock, or a card with no clock?

**Would have asked:** three families (the CS request branches, the ship moments, the design-round
beat, the resignation) fire on an edge a SYSTEM knows and nothing else can see. Signal? Pool?

**Call:** a fifth `tick` value, `"request"`, meaning *no clock sweeps this card; a named
proposer is the only way in*. `Origin.REQUEST` skips G4's clock match entirely — `tick` says
which clock SWEEPS a card, not who may name it — so the Sales tab's buttons can also name a
`tick: daily` card. Lint accepts the fifth value; the sweep and the pool skip it by string
mismatch, which they already did.

**Reversal:** cheap. It is one string in five card files and one match arm.

### Q26 · Four cards triggered on a signal their own consequence emits

**Would have asked:** nothing — this is a defect, not a question. Recorded because the plan
named `employee_departed` for `team.resignation` and I implemented the plan before reading the
emitter.

`employee_departed` is emitted by `CharacterRegistry.remove`, which `team.resignation`'s own
option CALLS. `version_shipped` is emitted at the END of `ship_active_build`, which
`product.first_ship`'s option calls. `build_iteration_decision_pending` is emitted `false` at
two sites and `true` only at the round cap, so `product.design_round_intro` would have fired at
the wrong end of the ladder. All four are `tick: request` now.

**Reversal:** n/a — the alternative was a beat that fires one step late forever.

### Q27 · The Series A re-ask clock now runs from the FIRE, not from the answer

**Would have asked:** `gate_prompt_day` was re-stamped on decline, so the five-day silence
started when the player answered. The engine's cooldown starts when the card is SHOWN.

**Call:** kept the engine's semantics. A player who sat on the card for four days used to buy
nine days of quiet; §3.1 measures a cooldown from the last fire, and the smoke case now says so
in as many words.

**Reversal:** moderate. It would mean spending the latch at resolution rather than at
admission, which changes the meaning of `cooldown_days` for every card, not just this one.

### Q28 · `customer.retention` cannot be re-opened the same day it was answered

**Would have asked:** `B2BEventFactory`'s comment says the player may reopen İlgilen before
expiry and still rescue. A one-day entity cooldown forbids re-opening the card *just* answered.

**Call:** one-day cooldown. Re-opening the card you answered a second ago is an undo, not a
decision, and the latch is what §3.1 exists for. The rescue window itself — the account is in
Risk with its countdown running — is untouched, and the smoke case proves the reopen works a
day later.

**Reversal:** trivial (one number in one card file).

### Q29 · The hourly cap is `MAX_INTERRUPTS_PER_DAY`, not a hard one-per-day

**Would have asked:** `_case_ambient_one_per_day_across_hour0` pinned the old engine's
hard-coded 1/day cap on the hourly path.

**Call:** §13's budget governs every interrupt regardless of which clock raised it; the old cap
was in code with no name and no home in the GDD. The case reads `EvTuning.MAX_INTERRUPTS_PER_DAY`
so raising it in the calibration pass will not make the case lie. What the case still pins is
the thing that was actually fragile: the hour-0 rollover.

**Reversal:** trivial, but re-introducing a per-path cap means two tempo rules, which is what
§13 exists to prevent.

### Q30 · I3 is enforced in the EXECUTOR as well as on the signature

**Would have asked:** `EndingsSystem._assert_telegraph` is deliberately loud and never
blocking — refusing there would strand a run whose bankruptcy is already arithmetically
certain. But then no card-driven terminal is actually STOPPED.

**Call:** the executor refuses; the system path stays loud and non-blocking. The stakes differ:
nothing a system computes is at risk in the executor, only what an author wrote, and a card
that ends the run off a telegraph that never fired is content that must not ship. Two
enforcement points, two different jobs.

**Reversal:** trivial, and the smoke case `event_i3_no_silent_loss` documents both halves.

### Q31 · `funding.hard_mode` — a seam over GameState, not a `flag` leaf

**Would have asked:** `hard_mode_unlocked` is a reserved GameState key with no writer anywhere.
A `flag` leaf asks the ENGINE's FlagStore, which is a different place.

**Call:** a seam. This is §19.5's failure exactly — a condition that reads the wrong store is
false forever and looks like a design decision — and the port had walked into it twice (the
other was the hire nudge's delay, which now reads `funding.angel_days_since_accept`).

**Reversal:** trivial. Recorded because it is the second instance of one mistake, which makes
it a pattern rather than a slip: **a ported condition must be checked against the store the
value actually lives in, not against the name it used to have.**

### Q32 · Papers are not queued

**Would have asked:** `_admit` placed a paper on the desk AND in the queue.

**Call:** the desk only. `has_pending()` gates the clock and the save, so a paper left on the
desk for its full week would have held the game paused and unsaveable for seven days — and
`pump()` mounts whatever the queue ranks first, so it would have arrived as a modal anyway,
which is the opposite of §11.4.

**Reversal:** n/a — the alternative does not work.

### Q33 · The four scope-less customer cards

**Would have asked:** the old executor's default target for every customer verb was
`get_lowest_satisfaction_customer(<the event's market>)`, computed at apply time. Port the
default, or make the subject explicit?

**Call:** explicit. Four cards gained a required `customer` slot. A required slot can REFUSE
the card when there is nobody for it to be about; the old default could not — it silently
no-opped and the player watched a decision change nothing.

**Reversal:** trivial per card, but the class of bug it closes is the reason to keep it.

### Q34 · The chip builder reads `verb`, and "no chip" is now a smoke failure

**Would have asked:** nothing — `event_modal._describe_modifier` keys on `type`, cards carry
`verb`, so every chip on every card would have been empty. CLAUDE.md's EFFECT-VISIBILITY RULE
would have been violated by forty cards at once with nothing to catch it.

**Call:** read `verb` first with a six-entry alias table for the renamed ones, add labels for
the five effects that move the player or the run, and name the bookkeeping verbs in
`SILENT_VERBS` — so "not in the table" means a bug rather than a judgement call. A new smoke
case, `event_chip_coverage`, walks every card row and fails on any verb that is neither
labelled nor listed.

**Reversal:** n/a. Recorded because the rule was previously enforced by whoever remembered, and
now it is enforced by the suite.

---

## Defects filed, not fixed

**D3 · `EndingsSystem._assert_telegraph` cannot be observed from a smoke case.** It reports
through `push_error`, and the runner's stderr gate turns any `push_error` into a failed case —
so a case that wanted to assert "the assert fired" would have to fail to pass. The executor's
refusal is testable and is what `event_i3_no_silent_loss` asserts. The system-path half stays
proven only by the signature check.

**D4 · `class: info` has no surface.** After the two cards that were wrongly classed `info`
moved to `interrupt`, no card in the catalogue is `info`. `EvPresenter.surface_for` maps it to
`"badge"` and nothing reads that. It is R11's accepted trim — the badge belongs to the owning
module, not to the engine — but it means the class is schema-only and untested.

---

## D1 — REVERSED: the guard was added after all

D1 above says "not fixed here", and the reason it gave was sound at the time: a one-line guard
added mid-rebuild would be indistinguishable from rebuild damage if it ever misbehaved.

That reasoning expired with the swap. `main.gd` now has exactly one thing that can emit
`modal_requested` — `EvEngine._announce` — so a guard cannot be confused with anything: if it
ever fires, the engine emitted twice for one card, and that is a fact worth a `push_error`
rather than an orphaned `Control`. The guard frees the stale modal before mounting the new one,
so the failure mode degrades from "no pause, no menu, no save, no quit" to "one card was
skipped and the log says which".

The filing stands as the record of the defect; this is its close.

---

## The linter's first run, and what it found

### Q35 · The soft-cap ladder could never have run

**Not a question — a defect in my own content, found by the tool built to find it.**

`world.final_stretch_press` was step ONE of `arc_final_stretch` and the only thing that could
have started it. §10.10 keeps an arc step out of the pool, so the step could not fire until the
arc ran and the arc could not run until the step fired. The linter reported it as "arc
'arc_final_stretch' is never started by any card", which is the same deadlock stated from the
other side.

That is the ENTIRE soft-cap telegraph — the design call the task specifically asked me to make
(defect 8) — sitting in the tree as unreachable content. The press card comes out of the step
list and becomes the arc's OPENER, starting it on either branch: read, or expired unread,
because the sector moving on is not conditional on the founder reading about it.

**Reversal:** n/a. Recorded because it is the clearest argument for the linter existing: three
gates, a probe and a full smoke suite all passed over a beat that could not fire, and §17.2's
reachability rule found it on its first run.

### Q36 · A `class: ambient` card carrying money — the half of I2 only lint can see

**Would have asked:** the executor's origin tables are the wall for I2, but they are keyed on
where the effect list came FROM. An option's effects always run as `played`, whatever the
card's class. So a `class: ambient` card — a ticker line the player never answers — with a
paying option is money with no decision, and the executor cannot tell.

**Call:** a fourth clause on §17.3. This is the one half of I2 that has to be lint, and saying
so is better than pretending the wall is complete.

**Reversal:** trivial.

### Q37 · Two harness numbers were lies

`interrupts_by_day` is keyed on the in-game day and was never cleared between seeds, so eight
800-day runs piled onto days 1..800: "busiest day: 16 interrupt(s) (ceiling is 2)" was eight
runs each honouring a ceiling of two. The silence sweep walked the TOTAL day count against a
per-run table, so "longest silence: 5722 day(s)" counted days that never existed.

Fixed rather than filed, because a harness whose numbers cannot be trusted is worse than no
harness: it manufactures a bug report and hides the real ones behind it. The corrected figures
are in the report.

### Q38 · `musteri.is_assigned` was the wrong gate on the request family

The three CS-request cards required the account to have a named steward. The old builder took
the DESK LEAD — `build_cs_request(c, reps[0])` — so the channel never depended on that, and
requiring it meant the card was refused at G7 for every founder-managed account while
CustomerRepSystem's own log recorded an escalation. A system that says it escalated and a
player who sees nothing is the exact failure the "why didn't this fire" panel exists to
diagnose; here it was the panel's own content that was wrong.
### Q39 · `loc_residue` went red on the engine, and the fix was to teach it what an address is

The event engine introduced **59 residue hits** — 57 of them the seam namespaces
(`musteri.`, `urun.`, `arge.`, `destek.`), which are Turkish words written in ASCII and are
therefore exactly what `loc_residue` hunts for.

**Would have asked:** per-line `# LOC-DATA` on 57 lines, a file-level skip, or teach the gate?

**Call:** teach the gate one shape. A literal matching `lower_snake.lower_snake` is a
namespaced identifier — an address into the read surface — and the gate already exempts
`res://` and `user://` on precisely that reasoning. It cannot hide player copy: nothing a
player reads looks like `musteri.is_at_risk`. Exempting the SHAPE rather than the files also
keeps the checker looking at the real strings in the same file, which is the reason its own
header gives for preferring per-line marks to a SKIP.

The two remaining hits were developer-facing Turkish inside English strings — a seam
description ("0 Junior / 1 Orta / 2 Kıdemli") and a lint message ("zar öldürmez") — and both
were reworded to English, which §8's "codebase English only" asks for anyway. One bare
`"musteri"` namespace literal in a match arm carries a `# LOC-DATA` mark.

`loc_residue` exits **CLEAN**, 0 hits, 2365 CSV keys.

**Reversal:** trivial, and the exemption is one regex with its reasoning above it.
---

## Corrections and closures after the first review pass (2026-08-26)

### C1 · `b2c_satisfaction_gate_experience` — my attribution was wrong

I reported it as "the concurrent Product session". That was a guess presented as a finding.

**The receipt:** it is in the P0 baseline, taken before this task's first edit —
`SMOKE SUMMARY 267/278` with eleven reds, this among them. Eight of those eleven went green
during the task without my touching them, which is evidence that *other work was landing in the
shared tree*; it is not evidence about this case in particular. What is true and checkable:
**red before I started, cause not diagnosed by me, not caused by this task.**

The mechanism I claimed — `_post_ship_wear_hourly` rewriting `mvp_live_bug_count` every tick —
cannot be it: that function runs on the HOURLY path and the case drives `_sim_day()`, which
dispatches only the daily slots.

### C2 · Acceptance gate 8 had never been measured

Reported as "random mode only". The truth is worse and better: **guided mode could not have
produced a number.** Three harness defects, all found by trying to answer the question:

1. `arcs_started` / `arcs_completed` were fields in `Result` that **nothing ever wrote**. The
   guided report reads them, so its completion table printed 0/0 whatever the engine did.
2. `_drain` answered only cards in the QUEUE. A paper waits on the desk; the harness never
   picked one up — so any arc whose opener is a paper could never start, and
   `arc_final_stretch`'s opener is exactly that.
3. The gate's target set included fixture arcs, which are refused at G2 in any build that does
   not ship fixtures: permanently 0%, permanently red, for a reason unrelated to content.

### C3 · And the engine gap those fixes exposed

With the harness able to see, `arc_final_stretch` started 20/20 and completed **0/20**.

`_step_tick_proposals` skips any card with an `arc` — "arc steps come from the arc, never from
a sweep" — and `pool_candidates` excludes them too (§10.10). **Nothing else proposed them.** An
arc's steps could reach the player by exactly one route: a previous step calling
`schedule_event`. `fixture.thesis_payoff` does that, which is why the thesis test passed and why
nothing noticed. `arc_final_stretch`'s steps do not, so the soft-cap ladder stopped after its
first rung with every gate green.

`Origin.ARC_STEP` was in the enum with nothing raising it. `EvEngine._step_arc_steps()` now
raises it: the card at each live arc's current step is PROPOSED — G3 still latches it, G6 still
guards it, G7 still asks its condition, which is how the D-30 beat waits for day 700 while its
arc has been live since 640.

**After the fix: `arc_final_stretch` 20/20 started, 20/20 completed, zero never-visited steps.
HARNESS PASS.**

### C4 · §13.7's anchor was the wrong number

"Busiest day 2 against a ceiling of 2" is `MAX_INTERRUPTS_PER_DAY` — the daily budget, a
different rule. §13.7 measures the densest THREE REAL MINUTES and the longest silence in real
seconds, and three minutes is a different number of in-game days on every speed rung
(`SECONDS_PER_DAY` = [0, 12, 6, 3] → 15 days at 1x, 30 at 2x, 60 at 3x). The harness now
reports the anchor per rung, plus the empty-floor counter, which was a field with no writer.

### C5 · The quiet pool did not exist

§13.6's floor had a mechanism and no content: the floor was reached and found nothing on
**3140 of 15980 simulated days**, one day in five, and `_floor_empty_streak` was warning into a
void. Three `tag: quiet` cards authored to §13.6's own rules (read live state, no economy, two
low-stakes options). Longest silence fell from **629 in-game days to 29**.

### C6 · I7's boundary, and A3's fallback

`SkillCheck.breakdown()` returns `base` / `skill` / `bonus` — free-text keys, not seam names, so
a modifier line keyed on them could never resolve. `EvDice.contributions_from_breakdown()` is
the boundary the directive asked for; `base` is dropped deliberately (it is the difficulty, not
a modifier).

A3's ordering guarantee holds for up to three urgent papers by construction. The case it cannot
cover is four, where the fourth runs its clock down behind the chip — so the chip now carries
urgency, which is the fallback A3 named.
