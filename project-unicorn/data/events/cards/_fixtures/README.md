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

`hourly_ambient.json` is the newest of these and the one that needs a reason on the page.
Every AUTHORED `tick: hourly` card was removed as legacy flavour, and the deck that replaces
them has not been written. `ambient_one_per_day_across_hour0` asserts something about the
ENGINE's clock rather than about content, so it cannot wait on content: it gets a fixture
instead. The fixture sits in `allowed_hours: [0, 0]` deliberately,
because hour 0 is the last hourly dispatch of a day and belongs to the NEXT calendar day, so
every fire it produces is a rollover fire. The three cards it replaced sat in daytime windows
and could never reach that branch at all.

**Do not** make a card inert by other means. `data/events/unwired/README.md` lists what happens
when you try: an empty condition fires on day 1, an empty option list mounts a modal that can
never be resolved and disables saving, and an invented condition type warns on every tick
forever.
