# `data/events/cards/_fixtures/` — engine test content

These cards exist to exercise the engine, not to be played. Every one carries
`"version_scope": "fixture"`, which is **not** in `EvTuning.SHIPPED_SCOPES` — so gate step G2
refuses them in any normal run, structurally, on the same mechanism that keeps Early Access
content out of the demo pool.

That is deliberate: one mechanism, not two. A second "is this a test card" flag would be a
second thing to forget.

The probe (`--event-probe`) widens `SHIPPED_SCOPES` for its own run and narrows it again
afterwards, and the smoke cases whose subject is a fixture do the same for the length of one
case (grep `SHIPPED_SCOPES.append`). Nothing in production code does, and nothing should:
the widening is always paired with a restore in the same function.

`hourly_ambient.json` is the subject of `ambient_hourly_never_at_night`, which asserts
something about the ENGINE's clock rather than about content, so it gets a fixture instead of
waiting on authored content. It sits in `allowed_hours: [10, 10]` deliberately: the week
starts at 08:00 and no workday ends before 13:00, so hour 10 lies inside every workday and the
fixture is a live non-critical hourly card. Night hours refuse such a card at the gate; that
refusal is asserted on its own.

**Do not** make a card inert by other means: an empty condition is TRUE (§5.3) and fires in
week 1, a card with no options mounts a modal that can never be dismissed and so disables
saving (SaveManager.can_save refuses while an event is active), and an unrecognised condition
leaf evaluates FALSE with a push_error on every evaluation.

`lint_v3/` holds the linter's own counter-examples, one per schema v3 rule, and they are the one
place here that does **not** carry `version_scope: fixture` — that scope is exactly what exempts a
card from those rules, so a card meant to break one must ship-scope itself. What keeps them out of
the catalogue is the `_bad_` filename instead. `event_lint_v3_rules` reads each file, normalises it
and asserts it produces its own rule.
