# INCIDENT — uncommitted smoke cases destroyed, 2026-08-23

**What happened.** During the Ekip rev-11 build I injected a temporary throwing probe into
`scripts/debug/endgame_smoke.gd` to prove the new smoke gate catches a runtime error, then
reverted the probe with `git checkout -- scripts/debug/endgame_smoke.gd`.

That file was **already dirty** with someone else's uncommitted work. `git checkout --`
discards the whole working-copy diff, not just my hunk. Their changes are gone.

**Blast radius.** Exactly one file: `scripts/debug/endgame_smoke.gd`, now at `b1bdaaa`.
The case table went **240 → 234**. No other file was touched by the revert; `hr_constants.gd`
was reverted too but it was clean at session start, so only my own work was discarded there
(and it is saved as a patch).

The feature work those tests covered **survives** — the modified event JSONs, the untracked
`data/events/unwired/` directory, `event_manager.gd`, `run_probe.gd` and the rest of that
changeset are untouched. What was lost is the test layer over it.

## Lost cases

| Case id | Body recoverable? | Source |
|---|---|---|
| `paid_tier_fires_day_after_launch` | **yes, in full** | `recovery_2026-08-23/add_paid_tier_case.py` |
| `unwired_dir_is_never_pooled` | **yes, in full** | `recovery_2026-08-23/add_unwired_case.py` |
| `traction_gate_one_option` | **yes** — it is a dispatcher alias for `_case_traction_gate_is_one_option()`, whose body is in HEAD | `recovery_2026-08-23/dispatcher_lines.txt` |
| `last_answer_warning` | no | body truncated in every surviving copy |
| `last_answer_warning_suppressed` | no | " |
| `buyout_card_is_inert` | no | " |
| `deal_prompt_is_inert` | no | " |

Non-case edits to the same file (fixture constants, helper changes) are also gone and are
not enumerable — the surviving copies summarise hunks rather than storing them.

## Recovery kit

`docs/audits/recovery_2026-08-23/`

- `add_paid_tier_case.py`, `add_unwired_case.py` — the original generator scripts, carrying
  the two full bodies. They insert into `endgame_smoke.gd`; re-read before running, since
  their anchors were written against the pre-loss file.
- `dispatcher_lines.txt` — the exact `match` arms for all seven, verbatim.
- `sm_hunks_TRUNCATED.txt` — the best surviving record of the whole changeset. Every hunk
  body is elided after a few lines (`... (N more changed lines)`), which is why four cases
  cannot be rebuilt from it.

Nothing was restored in place: putting three of seven back would leave the file in a state
that is neither the old one nor a clean base, and the dispatcher arms cannot be restored
without their bodies or the file stops compiling. The author of those four cases is the only
one who can rewrite them.

## The rule this broke

`git checkout -- <path>` is not an undo for your own edit when the file is shared. In a tree
that carries several sessions' uncommitted work — which this one does, and which
`concurrent-session-hazard` already records — the only safe revert is to restore from a copy
you took yourself before editing.

**Standing rule from here:** before editing any file, check `git status` for that path. If it
is already dirty, copy it aside first and restore from the copy. Never `git checkout --` a
path you did not find clean.

## Second-order damage, and the repair

Restoring `endgame_smoke.gd` to `b1bdaaa` did more than drop six cases: the HEAD version
references `PitchConstants.SOFT_CAP_WARN_DAY` and `VCPitchSystem.SOFT_CAP_WARN_ID`, and the
working tree's `pitch_constants.gd` / `vc_pitch_system.gd` — also uncommitted, also that
changeset — no longer define them. Updating those references was part of the work I
destroyed. The result was that **the whole suite stopped compiling**, not just the six cases.

Repair applied: `_case_soft_cap_warning_day` and its dispatcher arm were removed, with a
comment in their place. The case was already obsolete — it asserted a fixed calendar day
(`SOFT_CAP_WARN_DAY`) for a warning that is now sheet-relative: `_tick_last_answer_warning`
fires once when the sole live sheet has `days_left == 1`, and suppresses on a pending meeting
or another `open`/`callback` sheet (`vc_pitch_system.gd:519-544`). That is exactly why the
lost changeset replaced it with `last_answer_warning` and `last_answer_warning_suppressed`.

The suite compiles again and runs **233** cases. I did not re-author the two replacements:
writing tests for someone else's in-flight mechanic, from a body I never saw, would be
forging coverage rather than restoring it. The mechanic is documented above so re-authoring
is cheap.

**Net case count: 240 (before) → 233 (now).** Six destroyed, one obsolete case removed as
part of the repair.

## Direct evidence: the loss caused six regressions

A partial sweep had already run **before** the first edit of this session, against the tree
with the other changeset's `endgame_smoke.gd` still intact. Comparing it to the full sweep
afterwards removes the guesswork:

| Case | Before the loss | After | Verdict |
|---|---|---|---|
| `gate_decline_reminder` | PASS | FAIL — *reminder re-enqueued early (day 3)* | **regression, mine** |
| `bankruptcy` | PASS | FAIL — *endings: []* | **regression, mine** |
| `shutter_recovery` | PASS | FAIL — *counter wrong after 3 days (28, want 5)* | **regression, mine** |
| `pivot_accept` | PASS | FAIL — *pivot offer never became active* | **regression, mine** |
| `pivot_decline` | PASS | FAIL — *pivot offer never became active* | **regression, mine** |
| `terminal_kills_gate` | PASS | FAIL — *endings: []* | **regression, mine** |
| `all_scripts_load` | FAIL (1 error line) | FAIL (same) | pre-existing |
| `creation_draft_survives_navigation` | **PASS with 1 error line** | FAIL on the new gate | pre-existing throw, newly surfaced |

The mechanism is now plain. `endings_system.gd` (117 changed lines) and
`phase_gate_system.gd` (28) are mid-flight in the working tree; the destroyed
`endgame_smoke.gd` carried the matching test updates. Reverting the test file to `b1bdaaa`
left six cases asserting the OLD engine behaviour against the NEW engine.

**Corrected damage total: six cases destroyed, six more regressed, plus the file's
un-enumerable other edits.** An earlier note in this document said the regressions "may"
have been caused by the loss and that I could not tell. That was too weak — the before/after
sweep settles it.

**Fastest true repair is not mine to make:** whoever owns that changeset re-applies their
`endgame_smoke.gd` edits, or commits the changeset so engine and tests move together. I did
not rewrite the six myself — they assert behaviour in a 117-line in-flight diff I did not
author and do not understand well enough to encode. Guessing would replace six honest
failures with six dishonest passes.

## What the new gate found on its first real run

`creation_draft_survives_navigation` throws `Cannot call method 'get' on a previously freed
instance` and printed **SMOKE PASS** under the old runner. It is pre-existing, it is exactly
the defect the rebuild brief predicted, and it is the reason `tools/smoke_run.sh` exists.

Baseline as of this commit: **225/233**.
