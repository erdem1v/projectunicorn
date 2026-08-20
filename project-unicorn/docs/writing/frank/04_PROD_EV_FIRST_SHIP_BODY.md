# Row 4 · `PROD_EV_FIRST_SHIP_BODY` · the first ship

## Skeleton (inventory row 4, unchanged)
- key `PROD_EV_FIRST_SHIP_BODY` (title `PROD_SHIP_FIRST_READY`, option `PROD_SHIP_PUBLISH`) · id `ev_mvp_ship_moment` · surface EventModal · surface class 3, confirmation card
- trigger: the player pressed Ship on the first finished build → `ProductSystem._trigger_ship_moment(false)` (`product_system.gd:977`, enqueue `:1306-1308`, builder `:1338-1362`); hourly product seam, real hour available (not used)
- options: 1 · `Yayınla` / `Ship it` → `ship_active_build` (sets `mvp_shipped`, stamps `mvp_launch_day`, records version 1; no effect chip). The option is the act of shipping; at card time the build is finished and not yet live.
- render risks: badge reads ÜRÜN (`ship_moment` tag) until the routing fix; `one_shot` inert (injected); fires mid-build by design; subtitle ""

## Whitelist used
- a finished first build exists, awaiting publish; the cursor is on the option ← `_trigger_ship_moment` runs from the launch seam before `ship_active_build`
- Frank is known by name (boot modal, speaker strip)
- a message can sit on the phone unread (the ODA phone is the channel) ← `oda_view.gd` phone anchor
- nothing else asserted: no hour, no day, no weekday, no market, no product name, no counts, no founder name

## TR
İmleç Yayınla'nın üstünde. Telefonda Frank'ten bir mesaj var, ne zaman geldiği belli değil.

"Bugün müydü?"

→ **Yayınla**

## EN
The cursor is on Publish. There's a message from Frank on the phone; no telling when it arrived.

"Is it today?"

→ **Ship it**

## Notes
- Aphorism ledger: 0 / 2 spent.
- `[COND?]`: none.
- Alternative considered and rejected: removing Frank from this surface entirely.
