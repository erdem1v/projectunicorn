# `data/events/unwired/` — finished text, no system yet

Event files in here are **complete and reviewed**: both locales, final wording, final options.
What they do not have is a trigger, because the mechanic they belong to has not been built.

**They cannot fire, structurally.** `EventManager.EVENTS_DIR` is a single constant pointing at
`res://data/events/reactive/`, the scan does not recurse, and nothing else in the codebase
opens `data/events/`. A file here never reaches `_all_events`, so it never reaches the
eligibility pass, the queue, or `_history`. That is a different thing from a card whose
conditions happen to be false today, which is luck rather than a guarantee.

**They are still gated as shipped content.** `endgame_smoke.gd`'s `loc_event_en_coverage`
scans this directory alongside `reactive/`, so a TR-only card cannot sit here quietly and
surface in English the day someone wires it.

**Do not** try to make a card inert by other means:
- `"trigger_conditions": []` means *always eligible* and fires on day 1.
- `"choices": []` mounts a modal that can never be resolved, which permanently blocks the
  event queue and disables saving.
- An invented condition type warns on every daily tick, forever.

## What is in here

| file | surface | waiting on |
|---|---|---|
| `ev_seed_closed.json` | Frank v6 · 12b "Seed kapandı" | the seed round: there is no seed rung between Frank's angel cheque and Series A, so there is no moment for this card to confirm |

Per-surface detail, including what attaching it will take: `docs/writing/FRANK_UNWIRED.md`.
