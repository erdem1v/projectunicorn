# `data/events/cards/_fixtures/` — engine test content

These cards exist to exercise the engine, not to be played. Every one carries
`"version_scope": "fixture"`, which is **not** in `EvTuning.SHIPPED_SCOPES` — so gate step G2
refuses them in any normal run, structurally, on the same mechanism that keeps Early Access
content out of the demo pool.

That is deliberate: one mechanism, not two. A second "is this a test card" flag would be a
second thing to forget.

The probe (`--event-probe`) widens `SHIPPED_SCOPES` for its own run and narrows it again
afterwards. Nothing else does.

**Do not** make a card inert by other means. `data/events/unwired/README.md` lists what happens
when you try: an empty condition fires on day 1, an empty option list mounts a modal that can
never be resolved and disables saving, and an invented condition type warns on every tick
forever.
