---
name: unresolvable-card-token-class
description: Card bodies can carry tokens nothing resolves — they reach the player as literal braces; the gate is card_body_tokens_resolve
metadata: 
  node_type: memory
  type: project
  originSessionId: d1c4e074-d2f5-43b6-a4d0-15191be8fbc3
  modified: 2026-08-27T09:43:20.494Z
---

`EvPresenter._interpolate` resolves exactly two token shapes in a card body:

- `{slot}` — from a **declared scope slot**, via `_display_name(type, id)`
- `{seam:ns.name}` — from the **seam registry**

**Anything else survives to the screen as literal braces.** No gate caught this before
2026-08-27: `loc_csv_integrity` only checks that TR and EN carry the *same* token set, not that
anything can answer them.

Found in the wild: `funding.sheet_expiry` rendered a literal `{days}` inside a Frank line
(`VC_EV_OFFER_EXPIRING_BODY`). An audit across every card body in `data/events/` found it was
the **only** live instance — and that the sealed `END_EV_ACQ_BODY` would have made it three more
the moment the buyout card was wired.

**Two structural facts that decide the fix shape:**
- `{seam:}` **cannot live in the CSV** — `loc_csv_integrity` counts braces against `[a-z_]+`
  tokens and rejects the `:` and `.`. So a body needing a live number moves **inline into the
  card in both locales** (the shape `customer/request_complaint.json` uses). Title and option
  labels stay CSV keys.
- `_display_name` had **no investor arm** until 2026-08-27, so every card binding an investor
  slot rendered the raw id (`anchor`, not `Anchor Capital`). It also read `Customer.company_name`,
  which is deliberately EMPTY on the B2C aggregate record (it carries `name_key` + `name_arg`).

**How to apply:** the gate is the smoke case **`card_body_tokens_resolve`** — it walks every card
body (CSV-keyed and inline, both locales, including `by_seam` variants) and fails on any token
that is neither a declared slot nor a registered seam. Run it after any card-content change. If
you add a new entity type to `EvScope`, add its `_display_name` arm in the same commit.

Related: [[card-text-token-rules]], [[strings-csv-surgery]], [[frank-v6-landing-pass]]
