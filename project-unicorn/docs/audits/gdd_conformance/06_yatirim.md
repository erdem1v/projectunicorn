# Yatırım — GDD v2 conformance

**Date:** 2026-08-20 · **Chapter:** 09 · Funding & Investors (supersedes ch. 01 §4)
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Companions:** `04_finans.md` (the door, the cap table), `10_sonlar_ve_kosu.md` (series_a_close, the cascade), `03_ekip.md` (Karizma), `08_event_ve_anlati.md` (Frank as an event card).

---

## Verdict

This is the module in the best shape relative to what the GDD asks. Frank cheque matches chapter 09 §1 almost to the dollar — $25,000 for 4 percent at an MRR threshold, one played decision, no term sheet, refusal structurally locked (`angel_round_system.gd:35-37, 146-155`). The four named funds with distinct archetypes exist, the meeting is a real decision scene with conviction seeded from run state, and the term-sheet table with its patience pips and per-lever skill checks is built and calibrated.

Three things are missing, and one of them is the chapter reason for existing.

**There is no seed round.** The ladder is savings → Frank → Series A. Grep for seed_round, series_b or IPO across `scripts/` returns zero implementation hits. Chapter 09 §2 argues the seed exists to teach the term-sheet mechanic before the run-deciding use of it, and to open the mid-game so the second and third hires and the enterprise infra tier are affordable. Both arguments are about the demo's shape, not about content volume, so this is a structural gap rather than a nice-to-have.

**Relationships do not carry.** Each fund holds a status word (`vc_pitch_system.gd:695-698`), and the two states the chapter cares most about — *seeded you* and *you negotiated hard* — have nowhere to live. Frank cannot be recorded as a prior investor at all, and a hard negotiation is wiped when the sitting closes (`term_sheet_table_system.gd:418`).

**Term sheets are table constants.** Amount, valuation, dilution, board seat and veto are copied verbatim from the investor row (`investor_registry.gd:29, 45, 61, 77`) and never derived from the run. The only run-state input is a leverage notch of +$4M when a second sheet is live.

One naming casualty: **Karizma no longer exists.** It was renamed to `leadership` in July, and its fundraising half now lives as `influence` (`founder_constants.gd:8-20`). Chapter 09 §4 says Karizma speaks in the meeting; something does, under another name.

---

## 1. Requirements

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | Rung 0: the founder starts with personal savings, about $10K (§1) | `STARTING_CASH := 10000` on the self_made origin (`founder_constants.gd:52, 64`), applied at `game_state.gd:720`. Against a $50/day baseline that is roughly 200 days. | **VAR** | — |
| 1.2 | Rung 1: **Frank** — friends and family, a small cheque at an MRR threshold, **not a round**: one decision, no term sheet, no negotiation (§1) | Exactly this. `MRR_THRESHOLD = 2500`, `CASH_AMOUNT = 25_000`, `EQUITY_PCT = 4` (`angel_round_system.gd:35-37`); trigger is shipped plus MRR (`:53-56`); it is a one-choice event card, not a table (`:122-161`); the accept path is atomic — cap table, ledger, cash, latch (`:166-189`). | **VAR** | — |
| 1.3 | Refusing Frank is **locked** (hard mode) (§1) | The REDDET · ZOR MOD row is visible and structurally locked: `unlock_condition` reads `hard_mode_unlocked`, a flag with **no writer anywhere** (`angel_round_system.gd:154`, `game_state.gd:120-123`), and the choice carries zero modifiers as a second safety (`:146`). | **VAR** | — |
| 1.4 | Frank becomes a shareholder and stays the mentor and door-opener (§1) | Shareholder yes — the angel slice is a separate scalar with its own cap-table row (`game_state.gd:266`, `finance_ozet_view.gd:640-641`). Mentor yes. **Door-opener no** — see 6.4. | **KISMİ** | — |
| 1.5 | Rung 2: **Seed** — a real round from one of the four existing VCs, with a term sheet (§1) | **Does not exist.** No seed id in the endings table, the investor registry, `PitchConstants` or `strings.csv`. The ladder is savings → Frank → Series A. | **YOK** | several days |
| 1.6 | Rung 3: Series A from the **same four VCs**, so relationships carry (§1) | The four funds are shared by construction — there is only one pool (`investor_registry.gd:17-100`). | **VAR** | — |
| 1.7 | No new investor characters for seed; the pool stays four named funds with distinct archetypes: relationship / numbers / vision / follower (§1) | Four funds plus one locked Tier-2 teaser. Their domains are `metrics` (Anchor), `team` (Nexus), `narrative` (Bosphorus), `product` (Meridian) — four archetypes, but **not the four the chapter names**: there is no follower, and team and product are extra. | **KISMİ** | hours (re-cast) or amend the chapter |
| 2.1 | The seed teaches dilution, valuation and terms before the Series A table (§2) | Not possible today — the term-sheet table is met exactly once, at the run-deciding moment. | **YOK** | included in 1.5 |
| 2.2 | Seed money is what lets the player hire the second and third person and take the enterprise infra tier (§2) | Frank $25K is the only mid-game money. The enterprise infra tier does not exist (`05_operasyon.md` 2.2). | **YOK** | — |
| 3.1 | Seed trigger: Traction phase, door opens on **MRR only** (§3, ch. 08 §5) | The Series A door reads MRR **and** a 3-month growth streak **and** brand (`phase_gate_system.gd:47-60`). See `04_finans.md` 5.4 — this is a live contradiction and also a GDD-internal one against ch. 01 §2. | **ÇELİŞİYOR** | hours after the ruling |
| 3.2 | Frank line in Finance tells the player the door is MRR (§3) | The Finance surface is the appetite chip, which ch. 08 §5 retires in favour of exactly this line (`04_finans.md` 5.1). | **YOK** | owned by Finans |
| 3.3 | Seed flow: meeting → term sheet → accept / negotiate once / decline (§3) | The flow exists for Series A and is reusable wholesale: meeting (`vc_pitch_system.gd:67-249`), sheet grant (`:256-278`), table (`term_sheet_table_system.gd`), sign or walk (`:127-142`). | **KISMİ** — the flow is there, the rung is not | several days |
| 3.4 | Accepting seed brings a growth expectation the run is judged against; a stall now reads as failure (§3) | No expectation state exists. `running_on_fumes` is the 730-day soft cap regardless of whether money was taken (`endings_system.gd:231-239`). | **YOK** | a day |
| 3.5 | Declining keeps the bootstrap path open, and the fund remembers (§3) | Declining a *meeting* is stateless — `decline_vc_meeting` just clears the pending meeting with a raw field write (`event_manager.gd:767-769`). Walking a *table* is remembered as `walked` and costs a cascade point (`vc_pitch_system.gd:346-353`). | **KISMİ** | a day |
| 4.1 | The meeting is 2-3 beats, a decision scene (§4) | Five beats: read the room, narrative angle, interrogation, resolve, result (`vc_pitch_system.gd:167-249`). Richer than asked, and it works — but three beats is the chapter budget, so this is a trim decision rather than a build. | **KISMİ** | hours (trim) or amend |
| 4.2 | What speaks in the meeting: founder **Karizma**, the last three months growth, churn, margin, product state, and whether Frank made a warm introduction (§4) | Conviction seeding reads MRR against a reference, brand distance, shutter, gross runway, scandal, a live sheet as leverage, warm intro, a product-domain match and a callback bonus (`vc_pitch_system.gd:115-160`). **Growth over three months: absent** (the streak exists in `GameState` but the meeting does not read it). **Churn: only as a proxy** — `run_customers_lost` in the interrogation (`:644`), marked WORKING PROXY at `:20`. **Margin: absent.** **Karizma: renamed** — the persuasion checks read `influence` (`pitch_constants.gd:59-62`). | **KISMİ** | a day |
| 4.3 | Outcome: a term sheet, or **not now** and retryable; three rejections in a row can reach `vc_rejection_cascade` (§4) | Exactly this. Won at conviction 70, rejected under 40, and an ılık middle forks to a callback or a risky push (`vc_pitch_system.gd:214-243`). `CASCADE_TABLES := 3` is the single home (`endings_system.gd:28`), displayed as a closed-tables counter (`hunt_tab.gd:257-266`). | **VAR** | — |
| 4.4 | Repeated rejections cost brand and morale (§4) | They cost a cascade point and nothing else — no brand hit, no morale hit on rejection (`vc_pitch_system.gd:297-299`). | **YOK** | hours |
| 4.5 | Each archetype weights the inputs differently, so the same numbers produce different receptions (§4) | Real and load-bearing: per-fund `weights` set the narrative-angle difficulty (`investor_registry.gd:22-77`, applied `vc_pitch_system.gd:180`), and `domain` selects the interrogation family (`:632-639`) and the callback type (`:288-294`). | **VAR** | — |
| 5.1 | One term-sheet object at seed and Series A (§5) | `TermSheet` is generic (`term_sheet.gd:14-26`) and the table is state-driven (`term_sheet_table_system.gd:60-76`), so a seed rung reuses both unchanged. | **VAR (ready for reuse)** | — |
| 5.2 | Two axes: amount and valuation together are dilution (§5) | Present as three fields — `valuation_m`, `dilution_pct`, and money raised derived as `valuation x 1e6 x dilution / 100` (`term_sheet_table_system.gd:145-148`). | **VAR** | — |
| 5.3 | One condition axis: founder-friendly ↔ aggressive — board seat, veto rights, milestone clauses (§5) | Board seat and veto exist and are pushable in a fixed order, veto first then the seat (`term_sheet_table_system.gd:305-309`). **Milestone clauses do not exist.** The friendly/aggressive reading is derived only at the ending screen (`endings_copy.gd:29, 83-94`), not shown during the negotiation. | **KISMİ** | a day |
| 5.4 | The numbers should reflect the round, not a fixed table (§5, implied by bigger numbers at Series A) | `opening_terms` is copied verbatim from the investor row (`investor_registry.gd:29, 45, 61, 77`) with one run-state input, a +$4M leverage notch for a second live sheet (`term_sheet_table_system.gd:68-70`). Nothing reads MRR, traction, brand or team. | **KISMİ** | a day |
| 5.5 | Player: accept · **negotiate once** (risky; the fund can walk or harden terms) · decline (§5) | Accept and decline are exact (`term_sheet_table_system.gd:127-142`). Negotiation is **not once** — the player may push any lever repeatedly, paying self-damping odds (−0.12 per prior attempt on that lever) and one patience pip per failure until patience hits zero (`:100-123, 157-166`). **The fund never walks and never hardens terms**; the worst case is that pushing locks. | **ÇELİŞİYOR** | a day |
| 6.1 | Every fund holds a state: **seeded you** / passed on you / you declined them / **you negotiated hard** (§6) | Eight status values exist: open, offered, pending_sheet, callback, rejected, expired, walked, signed (`vc_pitch_system.gd:695-698` and its writers). **Passed** maps to rejected; **you declined** maps partly to walked, but declining a meeting leaves no trace. **Seeded you** cannot exist without a seed. **Negotiated hard** is sitting-local and wiped at close (`term_sheet_table_system.gd:418`); only run-wide push counters survive (`game_state.gd:244-245`). | **KISMİ** | a day |
| 6.2 | At Series A this state shifts reception: a fund that seeded you leads more easily, one you walked from is colder, one that passed may return if the numbers changed (§6) | Closed statuses **block** re-approach outright rather than shifting reception (`vc_pitch_system.gd:373-375`). The one warmth mechanic is the callback re-entry bonus of +10 conviction (`:151-153`). `meeting_count` is incremented and **read by nothing** (`:377`) — a free slot for exactly this memory. | **KISMİ** | a day |
| 6.3 | Frank warm introduction is a **played decision**: accept his intro for an easier room at one named fund, or go alone (§6) | `warm_intro` is a **static registry property** — Bosphorus has it, the others do not (`investor_registry.gd:62`) — worth +12 conviction (`vc_pitch_system.gd:145-147`). The player never decides anything. | **ÇELİŞİYOR** | a day |
| 7.1 | Closing Series A is the victory ending; the valuation at close is recorded (§7) | `sign_table` sets `series_a_closed`, persists five term fields and fires the ending in the same frame (`vc_pitch_system.gd:305-314, 320-329`). | **VAR** | — |
| 7.2 | Personal net worth reads the closing valuation (§7, ch. 02 §10) | The valuation is stored (`game_state.gd:253`) but the Kişisel tab has no page to read it (`09_arayuz_ve_oda.md`). | **YOK** | owned by Arayüz |
| 7.3 | Terms taken change the ending copy and Frank verdict line (§7) | The ending copy branches founder-friendly against aggressive on equity and veto (`endings_copy.gd:29, 83-94`). **Frank verdict line never renders** — the payload carries it and no template reads it (`10_sonlar_ve_kosu.md`). | **KISMİ** | hours, owned by Sonlar |

---

## 2. Contradictions, expanded

### 2.1 The seed rung is missing, and the machinery for it already exists

Everything a seed round needs is built: a meeting scene with per-archetype weighting, a term-sheet object, a negotiation table, a sign seam, and per-fund state. What is missing is the **rung** — a second, earlier invocation with smaller numbers, a Traction-phase trigger, and consequences that do not end the run.

The two arguments in §2 are worth restating because they decide priority. First, the term-sheet table is currently a **first-and-only** encounter with a decisive mechanic: the player meets dilution, valuation, board seats and patience for the first time at the moment the run resolves. Second, Frank $25,000 is the only mid-game money, which is why the second and third hires are rare in practice — and why the enterprise infra tier, when it exists, would be unaffordable.

Implementation is mostly parameterisation: a rung id on the sheet, smaller opening terms, a non-terminal accept path that moves cash rather than firing an ending, and a growth-expectation flag.

### 2.2 Negotiation is repeatable; the chapter says once

`push()` may be called on any lever as long as patience lasts, and the cost of pushing is a shrinking win probability (`PUSH_DECAY = 0.12` per prior attempt on that lever) plus a patience pip on failure (`term_sheet_table_system.gd:100-123, 157-166`). §5 says **negotiate once**, and adds two consequences that do not exist: the fund can **walk**, and it can **harden** terms.

The difference is tonal as much as mechanical. Repeatable pushing with decaying odds is an optimisation puzzle; one push that might blow up the deal is a decision. If §5 is implemented literally, the patience pips become a different object — one shot with a visible risk — and `run_pushes_attempted` / `run_pushes_won` (`game_state.gd:244-245`) lose their meaning.

### 2.3 Frank warm intro is a property, not a decision

§6 makes the introduction a played moment: accept it and one named fund is warmer, go alone and the room is cold. The code has Bosphorus permanently carrying `warm_intro: true` (`investor_registry.gd:62`) worth +12 conviction. Nothing is chosen, and Frank does not act.

This is also the cheapest way to make §1.4 door-opener true, and it fits the event grammar the game already has — a Frank card with two costed options, one of which spends a relationship rather than money.

### 2.4 Relationships hold a status, not a relationship

The eight status values are a state machine for *reachability*, not a memory of *how it went*. The gaps that matter for §6:
- **seeded you** — impossible without a seed rung.
- **negotiated hard** — the push counts are sitting-local and wiped at `_reset()` (`term_sheet_table_system.gd:418`).
- **declined a meeting** — leaves no trace at all.
- **passed, may return if the numbers changed** — a rejected fund is permanently unreachable (`vc_pitch_system.gd:373-375`) rather than colder.

`meeting_count` is already written and never read, so the field to hold this is half there.

### 2.5 The archetypes are four, but not the four named

The chapter names relationship / numbers / vision / follower. The code has narrative (Bosphorus, the relationship fund in all but name), metrics (Anchor), team (Nexus) and product (Meridian). **Vision** maps loosely onto the narrative angle, but there is no **follower** — the fund that only moves once someone else has. A follower archetype would need a state read of other funds, which is a small addition on top of the existing per-fund state and would give §6 something concrete to carry.

### 2.6 Two small live defects

`hunt_tab.gd:102` reads `inv.get("archetype_line", "")`, but the registry stores `archetype_key` (`investor_registry.gd:22`) — **the archetype line on every roster card renders empty**. The correct accessor exists and is used correctly elsewhere (`vc_pitch_system.gd:803`). And `interrogation_intensity` (`investor_registry.gd:26, 38, 58, 74`) is declared on all four funds and read nowhere.

---

## 3. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| MRR → the door | Satış → Yatırım | `phase_gate_system.gd:53` plus a growth streak and brand, which §5 of ch. 08 says must not gate. | **present, over-specified** |
| MRR, brand, runway, shutter → meeting conviction | Finans/Satış → Yatırım | `seed_conviction()` reads nine inputs (`vc_pitch_system.gd:115-160`). | **present** |
| **Three-month growth and margin → the meeting** | Finans → Yatırım | **ABSENT.** The growth streak exists in `GameState` (`:497-507`) and the meeting never reads it; margin does not exist. | **absent** |
| Churn → the meeting | Satış → Yatırım | **PROXY only** — `run_customers_lost`, marked WORKING PROXY (`vc_pitch_system.gd:20, 644`). | **partial** |
| Product state → the meeting | Ürün → Yatırım | `mvp_shipped` for a domain match (`:148`), live bug count and the weakest quality axis in the interrogation (`:676-684`). | **present** |
| Headcount → the meeting and the callback | Ekip → Yatırım | `count_developers`, employees-empty (`:653-661`), the `first_engineer` callback (`:293`). | **present** |
| **Karizma → probability and terms** | Kişisel → Yatırım | **RENAMED** — `influence` carries the persuasion half (`pitch_constants.gd:59-62, 89`); no stat named Karizma exists. | **partial** |
| VC prep → build speed | Yatırım → Ürün | `pitch_prep_active` adds a capacity job, slowing the build (`vc_pitch_system.gd:397`, `product_system.gd:246-247`). The **only** place fundraising costs anything. | **present** |
| Angel money → cash and cap table | Yatırım → Finans | `record_angel_round` plus `apply_one_time_income`, in that order (`angel_round_system.gd:182-183`). | **present** |
| Series A signing → cap table and ending | Yatırım → Finans / Sonlar | Five fields persisted by plain assignment, then the ending fires in the same frame (`vc_pitch_system.gd:320-329, 314`). Signing **moves no cash** — correct, since the run ends. | **present** |
| Rejections → the cascade ending | Yatırım → Sonlar | `vc_rejections` at 3 (`endings_system.gd:28, 158-180`), deferred while a sheet or meeting is live. | **present** |
| **Rejections → brand and morale** | Yatırım → Satış / Ekip | **ABSENT** (§4 asks for both). | **absent** |
| **Frank warm intro as a played decision** | Yatırım ↔ Event | **ABSENT** — a static registry property. | **absent** |
| **Growth expectation after taking money** | Yatırım → Sonlar | **ABSENT** — no expectation state; the soft cap is unconditional. | **absent** |
| Valuation → net worth | Yatırım → Kişisel | Stored (`game_state.gd:253`), no reader — the Kişisel page does not exist. | **absent (consumer side)** |
| Meeting and sheet moments → events | Yatırım → Event | Three synthetic Frank cards: meeting prompt, sheet expiry, soft-cap warning (`vc_pitch_system.gd:794-867`). | **present** |
| **Rival raised money → urgency** | Rakipler → Yatırım | **ABSENT** — no rival moves exist (`07_rakipler.md`). Ch. 10 §4 wants this as the window. | **absent** |

---

## 4. Depends on / depended on by

**Yatırım depends on:** **Finans** for the door reading and the Frank note surface; **Satış** for MRR, growth and churn as meeting inputs; **Ekip** for Karizma (or whatever replaces it) and headcount; **Rakipler** for the closing-window urgency in ch. 10 §4.

**Depends on Yatırım:** **Sonlar** — `series_a_close` and `vc_rejection_cascade` both originate here, and ch. 13 §1 makes `profitable_bootstrap` conditional on having **faced** the Series A decision, which is a state this module must expose. **Kişisel** for net worth.

**Can it be decided alone?** Mostly yes. The seed rung, the negotiation grammar, the relationship model and the warm intro are all internal decisions. The one hard external dependency is the door ruling in `04_finans.md` 5.4.

---

## 5. UI work

**Finance › Yatırım (the Hunt page)**
- Per-fund cards need the **relationship state in words**, not a status badge: seeded you, passed, you walked, you pushed hard. That is what §6 asks the player to reason about.
- Fix the empty archetype line (2.6).
- If a follower archetype lands, its card must show what it is waiting for.

**The meeting**
- Whatever the beat count settles at, the room needs to show **what is speaking**: the last three months of growth, churn, margin, product state, and whether Frank opened the door. Today the top three conviction reasons are surfaced (`vc_pitch_system.gd:155-159`) — the right idea, the wrong list.

**The term-sheet table**
- If negotiation becomes once-only, the screen changes shape: one push, a visible risk that the fund walks or hardens, and no patience ladder.
- Show the founder-friendly ↔ aggressive reading **during** the negotiation, not only in the ending copy.
- Milestone clauses, if they ship, are a third axis.

**Seed (new)**
- The same table with smaller numbers, plus a consequence line the player reads before accepting: cash in, equity out, and a growth expectation the run will be judged against.

**Frank warm intro (new)**
- One event card, two options, one of which names a fund.

---

## 6. Sizing

| Item | Size | Assumes |
|---|---|---|
| Fix the empty archetype line on Hunt cards | hours | |
| Delete `interrogation_intensity` | hours | |
| Rejections cost brand and morale | hours | |
| Door becomes MRR-only | hours | after the ch. 08 §5 ruling |
| Relationship state gains seeded / declined / pushed-hard, and shifts reception instead of blocking | a day | `meeting_count` is a free slot |
| Frank warm intro as a played event | a day | |
| Meeting reads growth, churn and margin properly | a day | margin needs serving cost first |
| Negotiate-once with walk and harden | a day | replaces the patience ladder |
| Term-sheet numbers derived from run state | a day | |
| Milestone clauses as a third condition | a day | |
| Growth expectation after taking money | a day | |
| **Seed rung** (trigger, smaller terms, non-terminal accept, consequences) | several days | reuses meeting, sheet, table and sign wholesale |
| Re-cast the four archetypes to relationship / numbers / vision / follower | a day | follower needs a cross-fund state read |

---

## 7. Open questions for the director

1. **Seed amount, valuation and dilution** (§9) — [WORKING]. Must be enough for two or three hires plus infra headroom, and small enough that Series A still matters.
2. **Does a seed-stage rejection feed the cascade counter, or only Series A rejections?** (§9.)
3. **Can the player skip seed entirely and still reach Series A comfortably?** (§9; the chapter target is yes, but harder.)
4. **Negotiate once, literally?** (§5.) If yes, the patience ladder and both push counters are retired and the table is re-shaped.
5. **The four archetypes.** The chapter names relationship / numbers / vision / follower; the code has narrative / metrics / team / product. Re-cast, or amend the chapter?
6. **Karizma.** Ch. 02 §4 and ch. 09 §4 both name it; the code renamed it away in July and the fundraising half is `influence`. Restore the name, or accept `influence` as its carrier?
7. **The door ruling** — MRR only (ch. 08 §5) against MRR plus growth plus brand (ch. 01 §2). Also listed in `04_finans.md`; it is the same decision.
