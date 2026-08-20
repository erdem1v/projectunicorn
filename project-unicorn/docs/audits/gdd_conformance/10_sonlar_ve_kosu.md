# Sonlar ve koşu — GDD v2 conformance

**Date:** 2026-08-20 · **Chapters:** 01 · The Run (spine), 13 · Endings & Progression, 14 · Scope
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Companions:** `04_finans.md` (shutter, Artıda streak, margin), `06_yatirim.md` (the Series A moment), `05_operasyon.md` (the Traction pressure this chapter demands).

---

## Verdict

Calibration Round A moved this module a long way in the right direction two days before the chapters were written. The **730-day soft cap** is in (`endings_system.gd:36`), the calendar wall is gone, `running_on_fumes` was rewritten as a catch rather than a fork, and **profitability became a condition rather than a crossing** — an Artıda streak with a margin and an MRR clause, evaluated daily (`:206-226`).

Three things are wrong, and one of them is the chapter central ruling.

**`profitable_bootstrap` fires without any Series A moment.** Ch. 13 §1 is explicit: profitability alone is not an ending; the player must have reached the investor table and chosen the bootstrap path. The predicate checks a six-month streak, a margin, an MRR floor and a scandal flag — **no phase check, no rejection count, no sheet, no gate state** (`endings_system.gd:206-226`). It can fire in phase 1, before the Traction gate has ever opened, to a player who never opened the Yatırım sub-page (which is itself locked until phase 3).

**`acquisition` is still reachable.** Ch. 01 §3 cuts it and says to remove it from the reachable set and from the copy. The offer still generates in phase 3 inside a brand band of 30-50 with at least one rejection (`endings_system.gd:244-255`), and accepting fires the ending (`event_manager.gd:754-756`).

**No phase re-tightens the runway.** Ch. 01 §5 makes this a law — in no phase may a competent policy reach cash rises, no decisions left. Grepping every reader of `GameState.phase` finds gates, copy, a sub-tab lock, news weighting, dots and save meta. **Not one finance, HR, sales or product system reads it.** Burn does not rise, salaries do not scale, no investor expectation appears. The forces that would do this work are Operasyon serving cost and support load, and they do not exist.

Two smaller items: **Frank closing line is composed and never rendered** — seven translated strings ship invisible — and the **B2C customer-count bug** ch. 13 §2 logs is real and worse than logged: two templates print `1`, four print `0`.

---

## 1. Requirements — the run (ch. 01)

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | Full run: 24 game months soft cap, [WORKING 730 days] (§1) | `SOFT_CAP_DAY := 730` (`endings_system.gd:36`), replacing the retired 180-day wall (`:30-35`). | **VAR** | — |
| 1.2 | Demo slice: Bootstrap into Traction, 60-90 real minutes, containing at least one turn of **every** pressure loop (§1, ch. 14 §1-2) | The phases and the ladder exist. The pressure set does not: serving cost, support load, the coverage threshold, tech debt as a force, a rival move, an incident and the infra choice are all absent (`05_operasyon.md`), and the founder assignment lock is absent (`03_ekip.md` 1.13). Of the eight items ch. 14 §2 lists under the full pressure set at shallow depth, **one** — tech debt — exists in any form, and only as a boolean. | **YOK** | the sum of Operasyon and Ekip |
| 1.3 | Bootstrap → Traction: product shipped plus first paying customers (§2) | `mvp_shipped` + at least one customer + MRR above zero (`phase_gate_system.gd:36-44`). | **VAR** | — |
| 1.4 | Traction → Series A Hunt: the appetite signal turns AÇIK, **and a closing window exists** (§2) | The signal exists as a three-state read (`phase_gate_system.gd:191-213`). **The window does not** — no rival move, no urgency state (`07_rakipler.md` 4.1). Note ch. 08 §5 separately rules the door is MRR only, which conflicts with this section; see `04_finans.md` 5.4. | **KISMİ** | several days |
| 1.5 | The number is never shown; the signal is (§2) | Enforced. `TRACTION_MRR_TARGET = 40_000` is never rendered (`sales_system.gd:44-47`), and the tooltip says gelir çıtası wordlessly. | **VAR** | — |
| 1.6 | Phases are one-way (§2) | Twice over: the gate ratchets and never re-evaluates once latched (`phase_gate_system.gd:14-16, 107-108`), and `advance_phase()` refuses anything but a forward move through an open gate (`game_state.gd:346-359`). `set_phase()` exists only as a save-restore and debug backdoor and says so. | **VAR** | — |
| 1.7 | The transition is a **played** decision, not a systemic one (§2, ch. 01 §9) | The gate opens a latch and queues a Frank scene; only the player confirm calls `advance_phase` (`phase_gate_system.gd:119-132`, `event_manager.gd:740-743`). Declining costs nothing but escalates the body copy on a five-day reminder (`:135-145, 266-276`). | **VAR** | — |
| 1.8 | **Each phase re-tightens runway** (§2, §5) | **Nothing.** Every reader of `GameState.phase` is a gate, a piece of copy, a sub-tab lock, news weighting, phase dots or save meta. No economic system reads it. Burn is five categories with no phase term (`finance_system.gd:34-40`); salaries have none (`hr_constants.gd`). | **YOK — a stated law with no implementation** | several days |
| 1.9 | Bootstrap pressure: founder time (sell against build against hire) plus cash (§5) | Cash pressure exists. **Founder time does not** — the founder is a constant presence in everything simultaneously (`03_ekip.md` 1.13). | **KISMİ** | several days, owned by Ekip |
| 1.10 | Traction pressure: costs that scale with customers, support load, coverage hires, rival share (§5) | **None of the four exists.** | **YOK** | owned by Operasyon and Rakipler |
| 1.11 | Series A Hunt pressure: spending ahead of revenue, the window closing, term-sheet stakes (§5) | Term-sheet stakes exist and are real. Spending ahead of revenue is possible but not rewarded or punished differently by phase. The window does not exist. | **KISMİ** | — |
| 1.12 | Difficulty: v1 is **Normal only**; Easy and Hard derived later by modifiers (ch. 01 §6) — **but ch. 14 §2 says Normal + Hard ship in the demo** | Neither exists. There is no difficulty concept in the codebase at all. The two chapters disagree; ch. 14 is later. | **YOK / chapter conflict** | several days |
| 1.13 | Both markets in v1; 2 B2B + 2 B2C subtypes, others locked-visible (§7, ch. 14 §2) | Both markets are real and play differently. The catalog carries **10** subtypes across two pools with no locked-visible treatment (`product_catalog.gd:20-46`). | **KISMİ** | a day |
| 1.14 | Both markets must be able to reach both endings (§7) | Not currently true for B2B: calibration **F1** measured the prospect pool running dry at about 25 accounts and 39,000 MRR, so the appetite signal reaches ISINIYOR in month 3 and falls back to KAPALI by month 7 — **AÇIK is unreachable on the B2B path inside 24 months**. The chapter calls this a calibration failure rather than a design choice. | **ÇELİŞİYOR** | owned by Satış segments |
| 1.15 | Origin: Self-Made only, others locked-visible; subgenres AI and SaaS, Social locked (§8) | Origins are exactly right — three cards, two visible-locked with a lock chip and a reason (`origin_traits_step.gd:112-137`). Subgenre is never asked; it defaults to `ai` and is written through by the committed product (`game_state.gd:709-711`), and the `social` pool is empty (`product_catalog.gd:45`). | **VAR** | — |

---

## 2. Requirements — endings (ch. 13)

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 2.1 | `series_a_close` — victory, fires when a term sheet is signed (§1) | `sign_table` sets `series_a_closed`, persists the terms and fires the ending in the same frame (`vc_pitch_system.gd:305-314`), with a daily backstop (`endings_system.gd:83-84`). | **VAR** | — |
| 2.2 | `profitable_bootstrap` — victory, **gated behind the Series A moment**: the player must have reached the investor table and chosen the bootstrap path. Profitability alone is not an ending (§1) | The predicate is four clauses — a six-month Artıda streak, a window margin at or above 15, MRR at or above 20,000, and no unmanaged scandal — evaluated **daily**, with no phase check and no investor-path term (`endings_system.gd:206-226`, consts `:43-45`). A player who never opens the Yatırım sub-page can win it. | **ÇELİŞİYOR — the chapter central ruling** | a day |
| 2.3 | `bankruptcy` — the 30-day shutter reaches zero (§1) | The mechanism is right, the number is 7 (`endings_system.gd:25, 116-136`). See `04_finans.md` 6.1. | **KISMİ** | hours |
| 2.4 | `running_on_fumes` — the 24-month soft cap with neither victory met; **Frank warns at D-1** (§1) | The cap is right and unconditional (`endings_system.gd:231-239`). The D-1 warning exists but **only fires if a term sheet is live** (`vc_pitch_system.gd:493-499`, `pitch_constants.gd:83`) — so a player with no offer gets no warning that the run ends tomorrow, which is the case the ending is named for. | **KISMİ** | hours |
| 2.5 | `vc_rejection_cascade` — kept in v1, hard to reach in the demo (§1) | Kept and reachable by two routes: the scan at three rejections with no live sheet or meeting, or declining the pivot offer (`endings_system.gd:158-180`, `event_manager.gd:759-761`). | **VAR** | — |
| 2.6 | **CUT: acquisition** — remove from the reachable set and from the copy (§1, ch. 01 §3) | Still present as an ending id (`endings_system.gd:51-73`), still offered in phase 3 within a brand band of 30-50 after at least one rejection (`:244-255`), still accepted into a terminal (`event_manager.gd:754-756`), and it still has a full newspaper template and copy family (`endings_copy.gd:127-155`). Declining it also sets a flag the VC interrogation later reads (`:383`, `vc_pitch_system.gd:669-670`). | **ÇELİŞİYOR** | a day (remove the reachable path, keep or retire the copy) |
| 2.7 | EA: `brand_collapse` (§1) | Present in the table but **dead in play**: it requires `GameState.active_scandal`, a field with **no production writer** — only a debug key sets it (`endings_system.gd:141-153`, `game_shell.gd:265`). The code says so at `:142-143`. Correct outcome for v1, wrong reason. | **VAR by accident** | — |
| 2.8 | LOCKED-VISIBLE: IPO and Series B — shown, not reachable (ch. 01 §3) | Neither exists as an id, and the ending screen right rail shows two locked tier cards for EA and FULL (`ending_scene.gd:313-318`) — a telegraph, but not the two named milestones. | **KISMİ** | hours |
| 2.9 | The newspaper metaphor stays (§2) | It stays and it is good: masthead, dateline with an issue number, headline, subhead, engraving, a four-figure stat block and two balanced prose columns, with a quiet-closure variant for a phase-1 bankruptcy (`ending_scene.gd:119-281`, `endings_copy.gd`). | **VAR** | — |
| 2.10 | **Frank line is rendered on its own strip, outside the newspaper** — today it exists in the data and is never shown (§2) | Confirmed exactly. `_build_ending_data` puts `frank_line` in the payload from `END_META_<ID>_FRANK` (`endings_system.gd:284, 399-400`), and `EndingsCopy._common()` **never reads it** — the only consumers are two defensive fallbacks for an unknown ending id. **All seven translated Frank lines ship invisible.** Calibration logged this as **F6**. | **YOK** | hours |
| 2.11 | **B2C runs must report audience and paying users, not an account count** (§2) | The bug is real and cuts both ways. `profitable_bootstrap` and `running_on_fumes` print `customers_active`, which for a B2C run is the single aggregate record — **1** (`endings_copy.gd:310, 362`). The other four templates print `customers_signed`, whose only writer is the B2B signing path — **0** (`game_state.gd:218`, `sales_system.gd:394`). Meanwhile the real population lives in `b2c_audience` and the aggregate record seats, neither of which is in the run ledger. Every prose line conditioned on `customers_signed > 0` is silently dropped on B2C runs. | **ÇELİŞİYOR** | a day |
| 2.12 | Run summary table: months survived · versions shipped · accounts or audience+paying · peak MRR · headcount · net worth · funding taken (Frank / seed / Series A with dilution) · accounts lost · notable events (§3) | The screen shows **four stat cells**, chosen per ending (`endings_copy.gd:118-364`). Present across the set: months, customers (wrongly, 2.11), headcount, MRR, investment, valuation, founder share, rejections, pitches, brand. **Absent: versions shipped, peak MRR, net worth, funding taken as a ladder, accounts lost as a general row, notable events.** `run_peak_mrr` is latched (`game_state.gd:303-304`) and read by no template. | **KISMİ** | a day |
| 2.13 | Endings gallery: which endings you have seen. That is all (§4) | Does not exist. There is no cross-run persistence of seen endings, and no main menu to host a gallery. | **YOK** | a day |
| 2.14 | No meta progression, no permanent unlocks (§4) | Correct — none exists. | **VAR** | — |
| 2.15 | Tone separation across the four endings (§5) | Held: each template has its own headline, subhead, engraving caption and stat set, and the phase-1 bankruptcy gets a deliberately quiet below-the-fold notice instead of the full ceremony (`endings_copy.gd:206-220`). | **VAR** | — |
| 2.16 | The demo ends when the Series A decision resolves; signing closes the run with the victory ending (ch. 14 §1) | True for signing. The other resolutions — walking the table, declining the round — do not end the run, which is correct for the bootstrap path but means the demo cut point is not a single moment. | **KISMİ** | — |

---

## 3. Contradictions, expanded

### 3.1 The bootstrap victory has no Series A moment in it

**The code decided** (Calibration Round A §9): profitability is a condition, not a crossing. Four clauses, checked every day, sitting after the cascade check and before the soft cap so a same-day tie goes to the win (`endings_system.gd:88-95, 206-226`).

**The GDD now rules** (ch. 13 §1): *profitability alone is not an ending; refusing the round and staying profitable is.* The player must have reached the investor table and chosen the bootstrap path — declined a term sheet, walked out of a meeting, or declined the door.

**Why this matters more than a gate.** Ch. 01 §4 makes the two victory paths diverge **by play, not by a funding card**: a player who keeps burn inside revenue ends bootstrap, one who spends ahead opens the window. Ch. 13 then adds the requirement that the bootstrap player must have *faced* the choice, so that the ending reads as a refusal rather than an accident. Today it reads as an accident — and it can fire in Bootstrap, before the Yatırım sub-page has even unlocked (`finance_tab.gd:86`).

**What has to exist:** a run-level state recording that the Series A decision was faced, written by the three qualifying moments (`06_yatirim.md` owns which ones count), and a fifth clause on the predicate. Cheap once the ruling is made.

### 3.2 Acquisition is cut and still reachable

Ch. 01 §3 says remove it from the reachable set **and from the copy**. In code the offer generator, the terminal, the newspaper template, the copy family and a downstream flag read all still exist. It is not merely a leftover: declining the offer sets `acquisition_offer_rejected`, which the VC narrative interrogation later reads (`endings_system.gd:383`, `vc_pitch_system.gd:669-670`), so removal touches two systems.

The decision to make is whether the *copy* is retired too. Ch. 01 says yes; the newspaper template is complete and would be cheap to keep dormant for EA.

### 3.3 No phase re-tightens runway, and this is a law

Ch. 01 §5 states it as a law with a test: *in no phase may a competent policy reach cash rises, no decisions left. If it can, the phase is under-pressured and must be fixed before content.* `CLAUDE.md` Calibration Law 1 says the same thing in stronger terms.

The full census of `GameState.phase` readers is: the gate table, the appetite signal, the acquisition offer gate, the ending payload, ending copy selection, the Finance sub-tab lock, the news pool weighting, the TopBar dots and name, the ODA goal card, one event condition (used only by a debug fixture with an impossible value), save meta, and the deal-prompt guard. **No economic system is in that list.**

The three forces the GDD assigns to this job all live elsewhere: serving cost and support load (Operasyon), coverage hires (Ekip and Operasyon), rival share (Rakipler). So the fix is not in this module — but the **test** belongs here, and it should be run as a probe pass once those land.

### 3.4 Frank closing line is written, translated, and never displayed

Seven `END_META_*_FRANK` rows exist in the CSV and are composed into the ending payload. `EndingsCopy._common()` builds the view state **without a `frank_line` key**, and each of the seven templates writes its own headline and subhead. The only readers are two defensive fallbacks for an unknown ending id. A comment at `endings_copy.gd:319-322` claims the `running_on_fumes` verdict is the Frank line; the code does not do it.

Ch. 13 §2 says the line goes on its own strip **outside** the newspaper, because the paper bans mentor attribution. That is a small, well-specified piece of UI and the data is already there.

### 3.5 The B2C ending reports the wrong number twice over

`customers_active` counts registry records with an active status. B2C keeps **one** aggregate record (`sales_system.gd:24, 268-289`), so the number is 1 once the paid tier opens and 0 before. `customers_signed` is incremented only by the B2B signing path, so it is permanently 0 on a B2C run.

Result: a successful B2C bootstrap prints **1 MÜŞTERİ**; a B2C Series A close prints **0 MÜŞTERİ**; and six conditional prose lines keyed on `customers_signed > 0` never appear, so the ledger box falls back to generic filler more often on B2C runs than B2B ones.

The fix is a ledger addition, not a rewrite: audience and paying users are both live values (`b2c_audience`, and seats on the aggregate record) and neither is in `get_run_ledger()`.

### 3.6 Two chapters disagree about difficulty

Ch. 01 §6: **v1 is Normal only**, with Easy and Hard derived by modifiers afterwards, and Hard locked-visible until then. Ch. 14 §2: **Normal and Hard ship in the demo**, Hard as modifiers over the calibrated Normal. Neither exists in code. Ch. 14 is the later document; ch. 14 §8 also asks whether Hard ships tuned or as a rough modifier pass, which suggests it is genuinely undecided.

---

## 4. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| Cash below zero → shutter → bankruptcy | Finans → Sonlar | `_tick_shutter` (`endings_system.gd:116-136`). | **present** |
| Artıda streak and window margin → the bootstrap win | Finans → Sonlar | `profitability_signal()` (`endings_system.gd:206-216`) reading `game_state.gd:512-533`. | **present** |
| **The Series A moment → the bootstrap win** | Yatırım → Sonlar | **ABSENT** — the predicate has no investor term (3.1). | **absent** |
| Term sheet signed → the victory ending | Yatırım → Sonlar | `sign_table` fires it directly (`vc_pitch_system.gd:314`). | **present** |
| Rejections → the cascade | Yatırım → Sonlar | `vc_rejections` at three, deferred while a sheet or meeting is live (`endings_system.gd:158-180`). | **present** |
| Soft cap → `running_on_fumes` | time → Sonlar | Unconditional at day 730 (`:231-239`); the ledger carries unsigned sheets so the paper can name what was left on the table. | **present** |
| **Soft-cap D-1 warning** | Yatırım → Sonlar | **PARTIAL** — fires only when a sheet is live (`vc_pitch_system.gd:493-499`). | **partial** |
| **Phase → economic pressure** | Sonlar → all | **ABSENT** — the law in 3.3. | **absent** |
| Gate conditions → the phase transition | Satış / Ürün / Finans → Sonlar | `phase_gate_system.gd:36-60`, evaluated daily at slot 8. | **present** |
| **The closing window → Hunt urgency** | Rakipler → Sonlar | **ABSENT** — no rival moves. | **absent** |
| Terminal → queue flush and clock freeze | Sonlar → Event / time | `flush_queue()` then `speed_change_requested(0)` (`endings_system.gd:268-272`); `TimeManager` refuses any unpause afterwards. | **present** |
| Run ledger → the newspaper | all → Sonlar | `get_run_ledger()` is the single read seam, recomputed on demand (`game_state.gd:610-675`). | **present** |
| **Audience and paying users → the ledger** | Satış → Sonlar | **ABSENT** — both live values are outside `get_run_ledger()` (3.5). | **absent** |
| **Frank verdict → the screen** | Sonlar → Arayüz | **ABSENT** — composed, never read (3.4). | **absent** |
| Versions shipped, peak MRR, net worth → the summary | Ürün / Finans / Kişisel → Sonlar | `product_ships` and `peak_mrr` are in the ledger and **no template reads them**; net worth has no producer. | **partial** |
| Endings seen → a gallery | Sonlar → meta | **ABSENT** — no cross-run persistence. | **absent** |

---

## 5. Depends on / depended on by

**Sonlar depends on:** **Yatırım** (the Series A moment state that gates the bootstrap win, and the ending it fires), **Finans** (shutter, streak, margin), **Operasyon and Rakipler** (the per-phase pressure the law demands), **Satış** (the B2C population figures the paper needs).

**Depends on Sonlar:** nothing downstream — it is the terminal module. But ch. 01 is the spine every other chapter defers to, so its **rulings** (the four endings, the soft cap, the pressure law, both markets reaching both endings) are constraints on everyone.

**Can it be decided alone?** The endings themselves yes — the acquisition cut, the bootstrap gate, the Frank strip, the B2C figures and the summary table are all self-contained. The **pressure law** cannot: it is a test this module runs over work done in Operasyon, Ekip and Rakipler.

---

## 6. UI work

**Ending screen**
- **Frank line on its own strip, outside the newspaper.** The data is already in the payload; the paper bans mentor attribution, so it needs its own band.
- **The run summary becomes a table**, not four cells: months survived · versions shipped · accounts or audience and paying users · peak MRR · headcount · net worth · funding taken as a ladder with dilution · accounts lost · notable events.
- **B2C runs report audience and paying users.** No template may print an account count for a consumer run.
- Retire or dormant the acquisition template, per the cut.
- **IPO and Series B as locked-visible milestones**, distinct from the current generic EA and FULL tier cards.

**Endings gallery**
- Which endings have been seen, and nothing else. Needs a home — main menu or Kişisel (§7 open).

**Elsewhere**
- The D-1 warning must reach a player with no term sheet.
- If difficulty ships, it needs a place in the run-start flow and a line in the ending meta.

---

## 7. Sizing

| Item | Size | Assumes |
|---|---|---|
| Frank line on its own strip | hours | the payload already carries it |
| D-1 warning fires without a live sheet | hours | |
| Shutter 7 → 30 | hours | owned by Finans |
| Remove the acquisition reachable path | a day | also touches the VC interrogation flag |
| Bootstrap win gated on the Series A moment | a day | needs the ruling on which states qualify |
| B2C ledger figures (audience, paying users) and template fixes | a day | |
| Run summary as a full table | a day | net worth needs a producer |
| Endings gallery | a day | needs a main menu or a Kişisel home |
| IPO and Series B locked-visible cards | hours | |
| Difficulty as modifiers (Normal, Hard) | several days | after the chapter conflict is resolved |
| **Per-phase runway tightening** | several days | not this module work — Operasyon, Ekip, Rakipler — but its **test** belongs here |
| The pressure-law probe pass | a day | run `--run-log=full_run:730` per phase and check the law |

---

## 8. Open questions for the director

1. **Which states count as having faced the Series A decision?** (§7.) Declined a term sheet, walked out of a meeting, declined the door — the chapter lists all three as candidates. This is the ruling that unblocks 3.1.
2. **Does the endings gallery live in the main menu or in Kişisel?** (§7.) There is no main menu today.
3. **Difficulty: Normal only (ch. 01 §6) or Normal and Hard (ch. 14 §2)?** And if Hard ships, tuned or as a rough modifier pass (ch. 14 §8)?
4. **Is the acquisition copy retired too, or kept dormant for EA?** Ch. 01 §3 says remove it from the copy; the template is complete and would cost nothing to keep unreachable.
5. **Exact demo event count** inside the 40-60 band (ch. 14 §8).
6. **Both markets must reach both endings** (ch. 01 §7). Today B2B cannot reach AÇIK within 24 months because the prospect pool exhausts (calibration F1). Confirm that segments and pool regeneration are the fix rather than lowering the bar.
7. **The pressure law needs a test.** Ch. 01 §5 says a phase that fails it must be fixed **before content**. Worth agreeing now what the probe looks like — a `full_run:730` pass reporting decisions per week and cash trajectory per phase would do it.
