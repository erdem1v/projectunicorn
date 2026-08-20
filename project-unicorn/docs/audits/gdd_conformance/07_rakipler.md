# Rakipler — GDD v2 conformance

**Date:** 2026-08-20 · **Chapter:** 10 · Rivals & World (DIRECTOR-APPROVED 2026-08-20, with the note that implementation needs its own session first)
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Companions:** `02_satis_ve_pazar.md` (segments and the share column — the hard dependency), `08_event_ve_anlati.md` (the move deck as authored events), `03_ekip.md` (poaching), `06_yatirim.md` (the window).

---

## Verdict

There are 80 rivals in the game and they do exactly one thing: three quality numbers per rival creep upward once a day toward a tier asymptote (`rival_registry.gd:108-124`). That drift feeds exactly one economic channel — the B2C audience term is recentred against the same-subtype startup average, so a product the player stops improving erodes as the field improves around it (`sales_system.gd:230-242`). That single coupling is real, load-bearing and worth keeping.

Everything else the chapter asks for is absent. There is no rival money, no brand strength, no personality, no move deck, and no way for a rival to take revenue. **Market share is a display curve, not a market:** the player share is `mrr / 1_500_000` clamped at 90 (`rival_registry.gd:169`), each rival share is a closed-form function of a catalog seed, a momentum constant and the day number (`:231-249`), and when the named shares overflow they are simply scaled down to fit (`:184-189`). The registry header says so itself — it calls the whole thing a presentation layer (`:139-145`) and records that the wobble does not produce the texture it was meant to (`:238-244`).

Two dead constants mark where the chapter wants mechanics: `RIVAL_SATISFACTION_HOOK = false` guards a `return 0.0` stub (`b2b_constants.gd:23`, `b2b_sales_system.gd:121-122`), and `RIVAL_LURE_ENABLED = false` has **zero readers** anywhere (`b2b_constants.gd:73`).

The chapter closes by saying the module needs its own design session before it can be spec'd, and this report agrees: **share cannot be built before segments exist**, and segments belong to `02_satis_ve_pazar.md`. Rakipler is last in the implementation order for that reason, not because it matters least.

---

## 1. Requirements

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | 3-4 named companies, real trademarks removed (§1) | **80 rivals** — 8 per sub-product-type across 10 subtypes (`rival_catalog.gd:22-31, 43-54, 93-113`): one giant, two established, five startups each. Names are fictional. A run sees the 8 of its own subtype. | **KISMİ** — the count is an order of magnitude off | a day (re-author) |
| 1.2 | Each rival carries **product quality** (§1) | Three axes plus a composite (`rival.gd:21-23, 34-36`), advanced daily by momentum toward a tier asymptote of 100 / 200 / 330 (`rival_registry.gd:16, 108-124`). | **VAR** | — |
| 1.3 | Each rival carries **brand strength** (§1) | Does not exist. | **YOK** | a day |
| 1.4 | Each rival carries **money** (§1) | Does not exist. Ch. 10 §8 lists how rival money is modelled as an open question, so this is expected. | **YOK** | a day |
| 1.5 | Each rival carries **one personality**: aggressive pricer / fast copier / heavy incumbent (§1) | Does not exist. `tier` is the closest thing and it only sets an asymptote. `Rival.founder_name`, `narrative_tags` and `notes` are declared and **never written or read** (`rival.gd:28-30`) — three empty slots where personality would go. | **YOK** | a day |
| 1.6 | They are characters, not curves: they appear in the news, **in accounts mouths**, and in events with names (§1) | News: yes, generated from the share snapshot (`news_feed_system.gd:273-315`). **In accounts mouths: no** — no customer copy references a rival. **In events: no** — there is no rival event of any kind. | **KISMİ** | several days |
| 2.1 | Every segment has share: ours against each rival (§2) | Segments do not exist (`02_satis_ve_pazar.md` 1.1). Share is global, not per segment. | **YOK** | several days, **blocked on segments** |
| 2.2 | Share moves with price, product-axis fit, brand, version age and rival moves (§2) | Share reads none of the five. It is a function of catalog seed, momentum and day for rivals, and of MRR for the player (`rival_registry.gd:164-249`). | **ÇELİŞİYOR** | several days |
| 2.3 | Neglect a segment and share drifts to a named rival; the loss is **visible in the Sales tab**, attributed to a company the player knows (§2) | Nothing drifts, because share is not a stock. The Sales tab makes **zero** references to `RivalRegistry`; share appears only on the ODA board (`oda_view.gd:1144-1236`) and the Product tab bottom strip (`detail_view.gd:543-556`). | **YOK** | a day (surface) after 2.1 |
| 2.4 | Share is zero-sum within a segment in v1 (§2) | The current normalisation is the opposite: the player share is computed independently and the rivals are **scaled to fit around it** (`rival_registry.gd:184-193`), so nobody gains what anyone loses. | **ÇELİŞİYOR** | included in 2.1 |
| 2.5 | Rivals touch **revenue** (§2, the core change) | One channel only, and it is B2C: `_rival_relative_quality` recentres the player quality against the same-subtype **startup** average, feeding both the growth and the erosion terms (`sales_system.gd:202, 220, 230-242`). B2B is explicitly gated off (`b2b_constants.gd:23`). | **KISMİ** | several days |
| 3.1 | A move deck of about six cards, at most one move per month, telegraphed before it lands (§3) | **No move deck, no rival decision function, no rival event JSON.** Nothing in the codebase lets a rival act. | **YOK** | several days |
| 3.2 | Yatırım aldı — their quality ceiling rises (§3) | The ceiling is a static per-tier asymptote (`rival_registry.gd:16`); nothing can raise it. | **YOK** | hours (after the deck) |
| 3.3 | Fiyat kırdı — price pressure in a segment (§3) | No rival price exists, and no player price reads a rival. | **YOK** | a day |
| 3.4 | Özellik çıkardı — their fit in a segment improves (§3) | Quality drifts continuously; there is no discrete release. | **YOK** | hours (after the deck) |
| 3.5 | Kahraman müşterimizi çaldı — a named account leaves (§3) | No mechanism. The seam it would use already exists: `churn_customer` with an explicit `customer_id` (`event_manager.gd:666-690`). | **YOK** | a day |
| 3.6 | Çalışanımıza teklif verdi — an HR event (§3, ch. 07 §7) | No poaching anywhere; `RivalRegistry` never touches `CharacterRegistry`. One line of resignation flavour text mentions an outside offer with no mechanic behind it (`strings.csv:733`). | **YOK** | a day |
| 3.7 | Kriz yaşadı — their share flows to us (§3) | No rival state can worsen; momentum is non-negative and drift is one-directional (`rival_registry.gd:112-117`). | **YOK** | a day |
| 3.8 | Each move has an authored event face and a readable consequence; **no hidden simulation** (§3) | The principle is honoured by accident — there is no simulation at all to hide. The card grammar for the faces exists (`b2b_event_factory.gd`). | **YOK (grammar ready)** | several days |
| 4.1 | The window: a rival accelerating in our segment gives the run urgency; it affects urgency, **not** the investor door (§4) | No window state and no urgency reader. The door is separately over-specified (`04_finans.md` 5.4) but not by rivals. | **YOK** | a day (after moves) |
| 5.1 | The news ticker carries rival moves and world colour (§5) | The ticker carries **generated** rival lines from the share snapshot, gated by a relevance filter — the rival must have moved recently, clear a two-day cooldown, and pass a big-move or near-band test (`news_feed_system.gd:273-315`, consts `:41, 60-61`). Sector colour is 48 authored lines (`:72-126`). Because giants have zero momentum they are **structurally silent** (`:56-59`). | **KISMİ** — colour yes, moves no | a day |
| 5.2 | World events (sector waves, funding climate) are colour only in v1 (§5) | Exactly that — the sector pool is copy with no mechanical effect. | **VAR** | — |
| 6.1 | Sales tab: a share column per segment (§6) | Absent (2.3). | **YOK** | after segments |
| 6.2 | The **rival list lives under the Sales tab**; no new tab (§6) | There is no rival list anywhere, and no rival tab either — so the no-new-tab half holds. | **YOK** | a day |
| 6.3 | Each move is an event card (§6) | No moves, no cards. | **YOK** | included in 3.1 |

---

## 2. Contradictions, expanded

### 2.1 Share is a picture of a market, not a market

`get_market_snapshot()` is a **pure function** — the registry says so at `:139-145` — of the catalog seeds, a per-rival momentum constant, the day number and the player MRR. Player share is `mrr / 1_500_000`; rival shares grow at `seed x (1 + momentum x 0.004 x day)` with a week-blocked hash wobble; if the named shares would exceed what the player leaves, they are scaled down (`:169, 184-193, 231-249`).

Three consequences follow, and all three contradict §2:
- **Nothing the player does moves a rival share** except growing MRR, which pushes everyone down proportionally.
- **No rival can take anything from the player** — there is no channel.
- **Share is not zero-sum**; the residual is dumped into a diğerleri bucket (`:193`).

The registry also records, honestly, that the wobble does not deliver the texture it was written for: the only real jump per run comes when the week index rolls over, around day 70 (`:238-244`).

### 2.2 The one real coupling is worth protecting

`_rival_relative_quality` (`sales_system.gd:230-242`) is the single place a rival affects money, and it is a good mechanic: the benchmark is the same-subtype **startup** average, deliberately excluding giants and incumbents, so the comparison is against companies at the player stage. It is also fragile — it reads the rival table on the retired grown scale through a bridge constant, `RIVAL_TEMPLATE_HALF_SAT = 50` against the player 25 (`quality_model.gd:52, 61`), which calibration logged as **F4**: the rival table needs re-authoring on the new scale, and the owner is this session. Whatever replaces the share model must keep this channel or B2C loses its only source of pressure.

### 2.3 Eighty rivals against three or four

The chapter wants three or four named companies the player comes to know. The catalog has eight per subtype, which is right for a benchmark average and wrong for characters. The likely resolution is two populations: a small **named** cast that acts, appears in events and holds share, and a larger **statistical** field that only exists to set the quality benchmark. That mirrors exactly what §1 of chapter 04 asks for on the customer side — hero accounts on top of a statistical pool — and would let the existing benchmark keep working untouched.

### 2.4 Two dead constants mark the intended seams

`RIVAL_SATISFACTION_HOOK` (`b2b_constants.gd:23`) is a permanently false gate around a `return 0.0` stub — the B2B side of §2. `RIVAL_LURE_ENABLED` (`:73`) has zero readers at all — the account-theft move of §3. Both are honest placeholders; both should be deleted or filled in the same pass, not left as decoration.

---

## 3. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| Rival quality → B2C audience growth and erosion | Rakipler → Satış | `_rival_relative_quality` (`sales_system.gd:230-242`), enabled by `RIVAL_RELATIVE = true` (`:69`). The one real channel. | **present** |
| **Rival pressure → B2B satisfaction** | Rakipler → Satış | **ABSENT, gated off** (`b2b_constants.gd:23`, stub `b2b_sales_system.gd:121-122`). | **absent** |
| **Rival price → our price pressure** | Rakipler → Satış | **ABSENT** on both sides. | **absent** |
| **Rival move → a named account leaves** | Rakipler → Satış | **ABSENT**; the `churn_customer` seam it would use exists. | **absent** |
| **Rival move → an employee is poached** | Rakipler → Ekip | **ABSENT**; `RivalRegistry` never touches `CharacterRegistry`. | **absent** |
| **Rival raise → urgency (the window)** | Rakipler → Yatırım | **ABSENT**; ch. 10 §4 and ch. 09 both want it. | **absent** |
| **Downtime → share loss in a contested segment** | Operasyon → Rakipler | **ABSENT** on both sides. | **absent** |
| Rival share → the news ticker | Rakipler → world | Generated lines behind a relevance filter (`news_feed_system.gd:273-315`). | **present** |
| Rival share → ODA board and the Product strip | Rakipler → Arayüz | Board ladder (`oda_view.gd:1144-1236`), product bottom strip and a seni geçti warning from the **quality** league (`detail_view.gd:543-556, 614-630`). | **present** |
| **Rival share → the Sales tab** | Rakipler → Arayüz | **ABSENT** — the tab does not reference the registry at all. | **absent** |
| Rival status → a dominant-rival check in the VC interrogation | Rakipler → Yatırım | `_rival_ahead()` looks for any DOMINANT rival (`vc_pitch_system.gd:782-787`) — a global boolean satisfied by every giant on day one, marked WORKING PROXY. | **partial** |
| Version age → rival comparison | Ürün → Rakipler | **ABSENT** — version age has no readers at all. | **absent** |

---

## 4. Depends on / depended on by

**Rakipler depends on:** **Satış** for segments — share per segment is meaningless without them, and this is a hard blocker for §2 and §6. **Ürün** for version age, which §2 names as a share input. **Event** for the six move faces, since §3 requires each move to be an authored card rather than a hidden roll.

**Depends on Rakipler:** **Satış** (the share column, hero-account theft, price pressure), **Ekip** (poaching, ch. 07 §7), **Yatırım** (the closing window, ch. 09 and ch. 10 §4), **Event** (the Y8 rival arc in `docs/.md` is six nodes that assume moves exist).

**Can it be decided alone?** No — and the chapter says so. It needs its own session, and that session cannot usefully happen before segments are decided.

---

## 5. UI work

**Sales tab (the rival home, per §6)**
- A **rival list** with, per rival: name, personality, our share against theirs in each contested segment, and what they did most recently.
- A **share column per segment**, with the direction of drift and the name of whoever is taking it.
- When a hero account is stolen, the loss must read as that company taking it, not as generic churn.

**News ticker**
- Rival **moves** as telegraphed lines before they land, distinct from the generated share commentary that exists today.

**Event cards**
- Six move faces, each with a readable consequence and a named company. The retention card grammar is the model.

**ODA board**
- The existing ladder is good and can stay; once segments exist it should say which segment it is showing.

---

## 6. Sizing

| Item | Size | Assumes |
|---|---|---|
| Delete `RIVAL_LURE_ENABLED` and the `_rival_pressure` stub, or fill them | hours | |
| Re-author the rival table onto the new quality scale (calibration F4) | a day | retires the `RIVAL_TEMPLATE_HALF_SAT` bridge |
| Split the cast: 3-4 named actors plus a statistical benchmark field | a day | keeps the B2C channel untouched |
| Rival money and brand as fields | a day | |
| Rival personality (three kinds) driving move selection | a day | |
| **Share as a real per-segment stock**, zero-sum, moved by price, fit, brand, version age and moves | several days | **blocked on segments** |
| **The move deck** (six cards, one per month, telegraph, authored faces) | several days | needs the event engine arcs |
| Kahraman müşteri theft | a day | reuses `churn_customer` |
| Employee poaching | a day | pairs with `03_ekip.md` 2.22 |
| The window as an urgency state | a day | after moves |
| Rival list and share column in the Sales tab | a day | after share |
| B2B rival pressure on satisfaction | a day | after share |

---

## 7. Open questions for the director

All of §8 is still open, and the chapter says implementation needs its own session. Restating them with what this audit adds:

1. **The exact share formula, and how zero-sum interacts with segment regeneration.** These two pull against each other: a regenerating segment is not a fixed pie.
2. **Move probabilities, telegraph length, and how rival money is modelled.**
3. **Can rivals be acquired, or acquire us, in v1?** (Default no; the acquisition ending is cut by ch. 01 §3 — though it is still reachable in code, see `10_sonlar_ve_kosu.md`.)
4. **How much rival state is visible against inferred?** The current board shows exact percentages; a character-driven design might prefer fewer numbers and more news.
5. **How many rivals?** Three or four named actors against the 80 in the catalog. This report recommends two populations rather than deleting 76 rows, so the quality benchmark survives.
6. **Does the B2B satisfaction hook open?** It is the difference between rivals mattering in one market and in both.
