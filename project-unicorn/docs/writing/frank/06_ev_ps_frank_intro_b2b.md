# Row 6 · `ev_ps_frank_intro_b2b` · the first B2B door

## Skeleton (inventory row 6, unchanged; option effects amended per ruling)
- id `ev_ps_frank_intro_b2b` (`data/events/reactive/ev_ps_frank_intro_b2b.json`) · surface EventModal · speaker `char_mentor_frank` · a one-option card that is not surface class 3 (the player did nothing; the card opened and the world changed)
- trigger: daily beat slot 7; `mvp_shipped == true ∧ market_type == "b2b"`; `one_shot` live (JSON path, enforced through `_history`); hour 00; subtitle "Telefon" (clock-free)
- options: 1 → `add_prospect{archetype: "mid", source: "frank_intro"}` (chip `Yeni aday` / `A new prospect`; the lead is spawned at resolve and may be null if the sector pool is exhausted) + `mentor_advisory{text}` (no chip; TR-only today) + **`[VOCAB?] navigate_to_tab{tab: "sales"}`** (the option is now a navigation: it must route the player to the Sales tab on click; no such modifier exists)
- render risks: fires the moment a B2B product ships; customers and prospects may be 0; the prospect's identity does not exist at fire time; advisory text has no `_en`

## Whitelist used
- `mvp_shipped` is true: the product is live; Frank can have seen it
- market is B2B
- the option spawns a lead with `source = frank_intro`; the pitch copy already has that prospect quoting Frank (`PITCH_S0_NPC`), so an arranged introduction matches state
- Frank holds 0 %: no stake, no favour owed, none stated
- not used: hour, day, weekday, counts (customers, prospects, MRR), founder name, product name, the lead's company

## TR
Ürün yayında. Telefon çalıyor, arayan Frank.

"Eski bir dostuma senin üründen bahsettim. İşine yarayabileceğini düşünüyor. Bir görüşme ayarladım. Hazırlıklı git."

Kapatıyor.

→ **Satış'a git**

## EN
The product is live. The phone rings, and it's Frank.

"I mentioned your product to an old friend of mine. He thinks it might be useful to him. I've set up a meeting. Go prepared."

He hangs up.

→ **Go to Sales**

## Notes
- Aphorism ledger: 0 / 2 spent. `[COND?]` the `mentor_advisory` payload still needs an `_en` sibling; wording written with row 22.
- `[VOCAB?] navigate_to_tab{tab}`: a card that hands the player something should be able to put them where they use it; a prospect that appears in a tab the player must go find is a card that gave them homework. The pattern recurs (hire nudge → HR, runway warning → Finance, term sheet → the table), so build it generic, not special-cased for Sales. Read-only here; reported for the dev track.
- Alternative considered and rejected: Frank naming the company on the call, impossible because the lead does not exist until the option resolves.
