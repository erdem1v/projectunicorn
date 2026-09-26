# `data/events/cards/_fixtures/` — engine test content

These cards exist to exercise the engine, not to be played. Every one carries
`"version_scope": "fixture"`, which is **not** in `EvTuning.SHIPPED_SCOPES` — so gate step G2
refuses them in any normal run, structurally, on the same mechanism that keeps Early Access
content out of the demo pool.

That is deliberate: one mechanism, not two. A second "is this a test card" flag would be a
second thing to forget.

The probe (`--event-probe`) widens `SHIPPED_SCOPES` for its own run and narrows it again
afterwards, and three smoke cases do the same for the length of one case
(`event_thesis_day10_to_day90`, `event_thesis_through_presenter`,
`ambient_one_per_day_across_hour0`). Nothing in production code does, and nothing should:
the widening is always paired with a restore in the same function.

`hourly_ambient.json` is the subject of `ambient_one_per_day_across_hour0`, which asserts
something about the ENGINE's clock rather than about content, so it gets a fixture instead of
waiting on authored content. It sits in `allowed_hours: [0, 0]` deliberately: hour 0 is
the last hourly dispatch of a day and belongs to the NEXT calendar day, so every fire it
produces is a rollover fire.

**Do not** make a card inert by other means: an empty condition is TRUE (§5.3) and fires on
day 1, a card with no options mounts a modal that can never be dismissed and so disables
saving (SaveManager.can_save refuses while an event is active), and an unrecognised condition
leaf evaluates FALSE with a push_error on every evaluation.
