# Finans — GDD v2 conformance

**Date:** 2026-08-20 · **Chapter:** 08 · Finance & Economy (DIRECTOR-APPROVED 2026-08-20)
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Director ruling applied on top of the file:** §1 burn is **maaşlar + araçlar + servis maliyeti**. Marketing is out. The `.docx` §1 line still reads "+ marketing" because the file was not re-saved; §4 already lists the expense breakdown without it, so the ruling makes the chapter internally consistent rather than changing it.
**Companions:** `05_operasyon.md` (serving cost — the blocker for margin), `06_yatirim.md` (the door and the cap table), `10_sonlar_ve_kosu.md` (shutter, Artıda streak).

---

## Verdict

Finance is a well-built ledger sitting on an economy with no cost of revenue. Cash, the daily tick, the transactions log, the cash curve with two projections, the cap table, the monthly close and the month history are all real and mostly right. Two things are missing, and they are the same thing seen twice.

**There is no serving cost.** Grep across `scripts/` for serving, hosting, provider, COGS or cost-of-revenue returns nothing. Every dollar of MRR is pure margin. This is why **gross margin — the headline number of §2, the one that must visibly fall as the product scales — has nothing to compute from**, and why the code substitutes a *net* margin over closed months (`GameState.get_window_margin_pct`, `game_state.gd:523-533`) into the bootstrap-win predicate. Calibration Round A measured the consequence and logged it as **F2**: profitability arrives in month 8-9 against a target of 18-20, with a window margin near 80 percent, because nothing scales cost with revenue.

The burn table is wrong on three of five lines: `founder: 50` is the living-cost line ch. 02 §1 deletes and is currently **100 percent of the day-1 burn**; `araçlar` does not exist (the old tools literal was deliberately deleted as unbacked); `servis maliyeti` does not exist at all. `marketing` and `office` are zero-valued hooks with no writer.

One requirement was satisfied and then overruled a day later: the **KAPALI / ISINIYOR / AÇIK chip** shipped in Calibration Round A §3 and is mounted on three surfaces. §5 replaces it with Frank's one-line investor note. That is a removal, not a gap.

---

## 1. Requirements

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | burn = **maaşlar** + araçlar + servis maliyeti (§1, as ruled) | `salaries` exists and is correct: pulled daily from `CharacterRegistry.get_total_monthly_salaries()` and divided by 30 (`finance_system.gd:35, 137-138, 213-218`). Paid leave is deliberate — the sum is not status-filtered (`character_registry.gd:296-299`). | **VAR** | — |
| 1.2 | burn includes **araçlar** (tooling, subscriptions, accounting) (§1) | **Absent, and deliberately deleted.** `finance_system.gd:22-27` records that the old `tools(7) / office(25) / legal(11) / misc(7)` literals were removed because nothing in the engine backed them; a recurring tooling cost is explicitly deferred at `:168-176`. | **YOK** | hours (id, `BURN_IDS`, TR+EN row, a writer) |
| 1.3 | burn includes **servis maliyeti** (§1) | **Absent in every form.** No id, no constant, no writer, no string key. | **YOK** | several days — owned by `05_operasyon.md` |
| 1.4 | Founder living costs **removed**; no founder salary (§1, ch. 02 §1) | Founder salary is correctly 0 (`game_state.gd:909`). But `founder: 50` is still in the table (`finance_system.gd:37`), labelled Kurucu yaşam gideri (`strings.csv:1475`), and it is the **entire** day-1 burn — `starting_daily_burn()` returns 50 (`finance_system.gd:119-124`) and a smoke case pins that number (`endgame_smoke.gd:1621-1623`). | **ÇELİŞİYOR** | hours, plus a re-tune |
| 1.5 | Marketing is not a burn line (director ruling) | `marketing: 0` exists with no gameplay writer — `set_burn_category` has zero production callers (`finance_system.gd:38, 228-235`). Same for `office: 0`. | **KALDIRILACAK** | hours |
| 1.6 | One-off costs: Atlas retainer, eğitim, lisans, kesinti telafisi (§1) | Three of four exist through one seam: retainer and commission (`hr_search_system.gd:159, 223`), training (`hr_system.gd:113`), severance (`hr_actions.gd:221`), and feature licence cost at build commit (`product_system.gd:1070, 1168`). **Kesinti telafisi** has no source because incidents do not exist. | **KISMİ** | — |
| 2.1 | revenue = Σ B2B account MRR + (B2C paying x price); discounts reduce account MRR (§2) | Exactly this. `_mrr_bridge()` sums active customers and is the single sink (`sales_system.gd:168-171`); B2C derives `paying x price` onto one aggregate record (`:250-255`); discounts write through `CustomerRegistry.set_mrr` (`b2b_sales_system.gd:337-339`). | **VAR** | — |
| 2.2 | **brüt marj = (revenue − servis maliyeti) / revenue**, the headline number that must visibly fall as the product scales (§2) | Does not exist and **cannot** exist yet. There is no cost side, and `compute_total_burn()` is one undifferentiated sum with no COGS/opex classification (`finance_system.gd:221-225`, `BURN_IDS` at `:47`). What does exist is a **net** margin — Σnet ÷ Σincome over the last six closed months (`game_state.gd:523-533`), read by exactly one caller, the bootstrap-win predicate (`endings_system.gd:211`), and surfaced to the player only as the word marj ince (`finance_ozet_view.gd:219-220`). | **YOK** | a day, **after** serving cost exists |
| 2.3 | Free users generate usage cost and no revenue (§2) | Free users generate no revenue, correctly. They generate **no cost either** — the only thing audience produces is post-ship bug wear (`product_system.gd:760-778`), which is bugs, not money. | **YOK** | owned by `05_operasyon.md` |
| 3.1 | Health readout: **runway** (§3) | Present in three places: the TopBar with an ARTIDA branch and a hover note (`top_bar.gd:180-195`), the Finance headline stat (`finance_ozet_view.gd:245-247, 458-469`), and a mentor warning card under six months (`:405-425`). Net runway is the canonical lens (`game_state.gd:447-452`); VC surfaces deliberately use gross. | **VAR** | — |
| 3.2 | Health readout: **brüt marj with trend** (§3) | Absent — see 2.2. No margin figure is ever printed. | **YOK** | a day |
| 3.3 | Health readout: **Artıda serisi** (default-alive streak, months) (§3) | Present and exactly right. An Artıda month is `net > 0 AND red_days == 0` (`game_state.gd:512-519`), and the Finance card prints `Artıda · {streak}/{need} ay` with the failing half named when the streak completes but the ending has not fired (`finance_ozet_view.gd:207-224`, `strings.csv:1956`). | **VAR** | — |
| 3.4 | Only three readouts; burn multiple, CAC payback, LTV:CAC and magic number are EA (§3) | None of the four exists. | **VAR** | — |
| 4.1 | Monthly close on **one screen**: revenue, expense breakdown, net, gross margin with delta and cause, cash and runway, Artıda streak, the month three notable events (§4) | The modal shows five delta rows — MRR, Kasa, Ekip, Marka, Runway (no chip) — plus one AYIN OLAYI highlight and one Frank line (`month_summary_modal.gd:38-67`, payload `month_summary_system.gd:86-106`). **Missing:** the expense breakdown, net as a line, gross margin and its cause, the Artıda streak, and two of the three notable events. Ekip and Marka are extra rows the chapter does not ask for. | **KISMİ** | a day |
| 4.2 | Expense breakdown by line: maaşlar / araçlar / servis maliyeti / tek seferlikler / **Vergi (locked, EA)** (§4) | A breakdown exists but on the **Finance tab**, not the close screen, and it renders only non-zero recurring categories (`finance_ozet_view.gd:343-350, 552-579` from `get_burn_breakdown_pct`). Today that is exactly one row, Kurucu yaşam gideri at 100 percent, until the first hire. **One-time charges never appear in it** — `get_one_time_today()` has zero callers, contradicting the comment at `finance_system.gd:172-176`. No tax row, locked or otherwise. | **KISMİ** | a day |
| 4.3 | Gross margin with a **delta and a cause** ("müşteri arttı, servis maliyeti arttı") (§4) | No margin, therefore no delta and no cause. The month payload has no per-category figures to build a cause from — `month_history` stores `expense` as a single integer (`game_state.gd:199, 488-491`). | **YOK** | a day (needs a per-category month record) |
| 4.4 | A month ledger of past months to read trends from (§4, implied) | Exists and is new: `month_history` keeps 12 closed months of `{start_day, end_day, mrr_close, income, expense, net, red_days}` (`game_state.gd:199-207`), with three readers — MoM growth streak, profitable-month streak and window margin (`:497-533`). **`MONTH_HISTORY_CAP = 12` holds only half of a 24-month run.** | **VAR**, with a cap to revisit | hours |
| 5.1 | **Frank investor note replaces the KAPALI / ISINIYOR / AÇIK chip** (§5) | The chip shipped one day before the chapter: `investor_appetite_ui.gd` renders a three-state chip plus one line, mounted on **three** surfaces — the Finance title row (`finance_ozet_view.gd:166-186`), the Product detail traction strip (`detail_view.gd:228-249`) and the ODA board goal card (`oda_view.gd:1109-1120`). | **KALDIRILACAK** | a day (three mount points plus copy) |
| 5.2 | Four states in Frank voice: before first revenue, kapı kapalı, ısınıyor, açık (§5) | The states exist as engine truth (`PhaseGateSystem.series_a_signal()`, `phase_gate_system.gd:191-213`) and the copy is close in shape (`INV_APPETITE_*`, `strings.csv:1942-1950`), but it is UI voice, not Frank voice, and there is no before-first-revenue state — phase 1 shows a generic too-early line. | **KISMİ** | a day (content pass) |
| 5.3 | Hover adds one line on deal quality: growth, churn, margin. No checklist, no progress bar, no percentages (§5) | The opposite today. The Finance tooltip enumerates the three gate conditions and **prints two of their numbers** — `{n} ay üst üste büyüme` and `Marka >= {n}` (`finance_ozet_view.gd:189-204`, `strings.csv:1951`) — and every mount point draws a **progress bar** from `sig.progress` (`finance_ozet_view.gd:178`, `detail_view.gd:442`, `oda_view.gd:1119`). | **ÇELİŞİYOR** | a day |
| 5.4 | **The door is MRR only.** Growth, churn and margin decide how the meeting goes, never whether the door opens (§5) | The Series A gate requires three things: MRR at or above the bar, a 3-month streak at 12 percent MoM, and brand at or above 25 (`phase_gate_system.gd:47-60`, consts `:29-30`). Two of the three are exactly what §5 says must not gate the door. Note this also disagrees with **ch. 01 §2**, which describes the signal as MRR bar plus sustained growth plus brand — see the open questions. | **ÇELİŞİYOR** | hours to change, but it is a design ruling first |
| 5.5 | The bar number is never shown (§5) | Correct and enforced: `TRACTION_MRR_TARGET = 40_000` is never rendered (`sales_system.gd:44-47`, `phase_gate_system.gd:26-28`); the tooltip says gelir çıtası wordlessly (`strings.csv:1951`). One leak elsewhere: the VC callback target prints a dollar figure (`hunt_tab.gd:286-287`), but that is a per-fund callback, not the door. | **VAR** | — |
| 6.1 | Shutter: cash below zero starts a **30-day** countdown [WORKING; may tighten to 21] (§6) | The countdown is **7 days** — `SHUTTER_DAYS := 7` (`endings_system.gd:25`), started on the first day cash is negative and decremented daily, bankruptcy at zero (`:116-136`). | **ÇELİŞİYOR** (a number, not a mechanism) | hours plus a calibration run |
| 6.2 | Visible in the TopBar as "Kepenk: N gün" (§6) | Exactly that, in `negative_bright`, hidden while inactive (`top_bar.gd:251-256`, `strings.csv:407`). | **VAR** | — |
| 6.3 | The window is for recovery: collect early at a discount, let someone go, downgrade infra, close a deal (§6) | Two of the four are reachable: let someone go — except **firing is currently unreachable from the UI** (`03_ekip.md` 3.5) — and close a deal. Collect-early does not exist; downgrade infra does not exist. A loan is named as an extension socket at `endings_system.gd:121-123` and left unbuilt. | **KISMİ** | a day |
| 6.4 | Frank speaks once at the start of the countdown (§6) | `ev_shutter_warning` is enqueued to the front on the first shutter day (`endings_system.gd:126`, built `:302-326`); it re-fires on a *later* shutter, which reads as correct. | **VAR** | — |
| 7.1 | Taxes are not in v1; the expense line exists **locked and visible** so the system can ship in EA without redesigning the close screen (§7) | No tax concept and no locked row anywhere. | **YOK** | hours (a locked row on the close screen) |

---

## 2. Contradictions and removals, expanded

### 2.1 The economy has no cost of revenue, so the headline number cannot exist

**The code decided:** burn is five categories, of which only salaries and overtime have writers, and none of them scales with customers, users or usage (`finance_system.gd:34-47`). MRR is applied to cash undiminished (`:151`).

**The GDD now rules** (§2): gross margin is `(revenue − servis maliyeti) / revenue`, and it is the number that *must visibly fall as the product scales* — the explicit repair for money stops mattering.

**Two consequences, both already measured.** Calibration finding **F2**: profitability arrives in month 8-9 against a target of 18-20, and `PROFIT_MIN_MARGIN_PCT = 15` never binds, because the window margin sits near 80 percent. And ch. 01 §5 asks every phase to re-tighten runway; nothing in the code reads `GameState.phase` for any economic purpose (see `10_sonlar_ve_kosu.md`), so serving cost is currently the **only** anti-snowball force the GDD actually specifies.

**Order of work:** serving cost (Operasyon) → burn line → gross margin → the close screen cause line → re-tune the profit streak. Doing margin before serving cost produces a number that is always about 100 percent.

### 2.2 The burn table is wrong on three lines out of five

| Line | Today | Should be |
|---|---|---|
| `salaries` | correct, pulled daily | keep |
| `overtime` | correct mechanically, but not a line the chapter names | fold into maaşlar, or keep and amend the chapter |
| `founder: 50` | the living-cost line, and the whole day-1 burn | **delete** (ch. 02 §1) |
| `marketing: 0` | no writer | **delete** (director ruling) |
| `office: 0` | no writer | **rename and revive as araçlar**, with a writer |

Deleting `founder` drops day-1 burn from 50 to 0 and breaks the smoke case at `endgame_smoke.gd:1621-1623`, so it needs an araçlar figure landing in the same pass or the opening runway becomes infinite. **Migration hazard:** `from_dict` restores category by category onto the starting table (`finance_system.gd:107-112`), so renaming an id silently drops the saved value rather than crashing.

### 2.3 The appetite chip is retired by a chapter written one day after it shipped

Calibration Round A §3 built the three-state signal, deliberately hiding the number and painting a state instead. §5 keeps that principle and changes the voice: one line from Frank, in the Finance tab, teaching the rule without printing the number, with a single hover line about deal quality.

**What has to go:** `investor_appetite_ui.gd` and its three mount points, the progress bar drawn from `sig.progress` at all three, and the tooltip that prints the growth-months and brand numbers (`finance_ozet_view.gd:189-204`). **What stays:** `PhaseGateSystem.series_a_signal()` as the engine truth — Frank reads the same state machine, he just says it differently. Note the ODA board and the Product tab lose their appetite readout entirely under §5, since the note is a Finance surface; confirm that is intended.

### 2.4 The door reads three things; the chapter says one

`phase_gate_system.gd:47-60` gates Series A on MRR, a growth streak and brand. §5 rules that the door is MRR only. This is **also a conflict inside the GDD**: ch. 01 §2 describes the appetite signal as MRR bar plus sustained growth plus brand, which is what the code does. Ch. 08 is later and more specific, so this report treats it as governing and raises the conflict rather than picking a side. The practical difference is large: growth and brand currently *block* the Hunt phase; under §5 they would only shape the meeting and the terms.

### 2.5 The shutter is 7 days, not 30

A pure number change (`endings_system.gd:25`), but not a trivial one: 30 days is a different mechanic in feel — it is long enough for the four recovery moves §6 names to be playable, where 7 is barely long enough to close a deal. Two of those four moves do not exist (collect early, downgrade infra) and a third is currently unreachable (firing). Tighten to 21 or hold at 30 is a calibration question; making the window usable is a design one.

### 2.6 Cap-table surfaces disagree

Three formulas for the founder share coexist:
- Finance tab: `100 − investors − employees` (`finance_ozet_view.gd:630`) — correct.
- Ending newspaper: `100 − investor_equity_pct` (`endings_copy.gd:435`) — ignores employees. Harmless only because hires get 0 equity by design (`hr_search_system.gd:205`); the moment an event grants equity, the two disagree.
- `GameState.get_founder_equity()` (`game_state.gd:540-546`) — `1.0 − employee equity`, **no investor term at all**, returning a 0-1 fraction. Its only reader is the retired RightPanel, so it is effectively dead and would report 100 percent on the very run that closed a Series A.

Angel and Series A are correctly kept as separate scalars with derived totals (`game_state.gd:257-266, 549-558`), and the Finance rows print Melek and Yatırımcılar separately (`finance_ozet_view.gd:640-644`) — that part is right and should survive any rework.

---

## 3. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| MRR → daily revenue → cash | Satış → Finans | `daily_revenue = round(mrr / 30)`, `net = revenue − burn`, one `set_cash` per day (`finance_system.gd:151-164`). | **present** |
| Salaries and overtime → burn | Ekip → Finans | One-way daily pull at slot 5 (`finance_system.gd:134-143`), HR having settled at slot 3. | **present** |
| One-time HR and product costs → cash and ledger | Ekip / Ürün → Finans | `apply_one_time_cost` sums per label, records a transaction, accrues the month expense, then sets cash last (`finance_system.gd:178-192`). | **present** |
| **Serving cost → burn** | Operasyon → Finans | **ABSENT** — the module central gap. | **absent** |
| **Usage → serving cost** | Ürün → Operasyon → Finans | **ABSENT** — no per-feature usage weight, no usage aggregate. | **absent** |
| **Incident compensation (kesinti telafisi)** | Operasyon → Finans | **ABSENT** — no incidents. | **absent** |
| **Gross margin → the close screen and the win condition** | Finans → Sonlar | **ABSENT** as gross; a **net** window margin feeds the bootstrap predicate instead (`game_state.gd:523-533` → `endings_system.gd:211`). | **partial, wrong quantity** |
| Artıda streak → the bootstrap win | Finans → Sonlar | `get_profitable_month_streak()` (`game_state.gd:512-519`) → `profitability_signal()` (`endings_system.gd:206-216`). Displayed on the Finance card. | **present** |
| Cash below zero → shutter → bankruptcy | Finans → Sonlar | `_tick_shutter` (`endings_system.gd:116-136`); TopBar chip; a queued phase gate is pulled while it runs (`phase_gate_system.gd:156-167`). | **present** |
| Cash and gross runway → VC conviction | Finans → Yatırım | Shutter −15, thin runway −8 (`vc_pitch_system.gd:132-137`, `pitch_constants.gd:21-22`); the meeting stat strip and the term-table footer print gross runway (`:527-531`, `term_sheet_table_system.gd:379-385`). | **present** |
| The door reading | Finans → Yatırım | `series_a_signal()` painted by the appetite chip on three surfaces. §5 replaces the surface, keeps the engine. | **present, being replaced** |
| Angel and Series A → cap table | Yatırım → Finans | `record_angel_round` emits `equity_changed` (`game_state.gd:561-568`); Series A persists five fields by plain assignment (`vc_pitch_system.gd:320-329`). Series A signing **moves no cash** — the run ends in the same frame. | **present** |
| Pipeline → the optimistic curve | Satış → Finans | `pipeline_optimistic_mrr()` at weight 0.5 (`sales_system.gd:321-333`, `finance_system.gd:342`). | **present** |
| **Event cash deltas → the transactions log** | Event → Finans | **ABSENT.** The `cash` modifier writes `GameState.set_cash` directly (`event_manager.gd:553-554`), bypassing `record_transaction`, so event money never appears in Son işlemler. | **absent** |
| **Phase → burn** | Sonlar → Finans | **ABSENT.** Nothing reads `GameState.phase` for any economic purpose. Ch. 01 §5 asks each phase to re-tighten runway; see `10_sonlar_ve_kosu.md`. | **absent** |

---

## 4. Depends on / depended on by

**Finans depends on:** **Operasyon** for serving cost — and that dependency is total, since gross margin, the §4 cause line and the F2 re-tune all sit behind it. **Ekip** for the salary pull (already working) and for the living-cost deletion to be safe. **Satış** for MRR.

**Depends on Finans:** **Yatırım** (the door, cash and runway as meeting inputs, the cap table), **Sonlar** (shutter, Artıda streak, margin), **Ürün** (only the one-time cost seam).

**Can it be decided alone?** The surfaces yes — the close screen, Frank note and the burn table can all be designed now. The **numbers** cannot: margin, the profit streak and the shutter length are only meaningful once serving cost exists. Decide the screens with Operasyon in the same sitting.

---

## 5. UI work

**Finance tab, Özet**
- Replace the appetite chip with **Frank one-line note**, four states, and one hover line about deal quality — no bar, no checklist, no numbers.
- Add **gross margin with its trend** as the second health readout, next to runway and the Artıda streak.
- The expense breakdown needs to show araçlar and servis maliyeti as real lines, and to include today one-time charges (or say plainly that it does not).
- Remove the two numbers the tooltip currently prints (growth months, brand floor).

**Monthly close (one screen, §4)**
- Revenue · expense breakdown by line including a **locked, visible Vergi row** · net · **gross margin with delta and cause** · cash and runway · **Artıda streak** · the month **three** notable events.
- The cause line ("müşteri arttı, servis maliyeti arttı") needs per-category month totals, which `month_history` does not store today.
- Decide whether Ekip and Marka rows stay; the chapter does not ask for them.

**TopBar**
- Kepenk countdown already correct; only the number changes.

**Elsewhere**
- The Product detail traction strip and the ODA goal card lose the appetite chip. Decide what, if anything, replaces it there.

---

## 6. Sizing

| Item | Size | Assumes |
|---|---|---|
| Delete `marketing` and `office` hooks | hours | |
| Delete the founder living-cost line | hours | must land with araçlar or the opening runway breaks |
| Add araçlar as a real burn line with a writer | hours | |
| Shutter 7 → 30 (or 21) | hours | plus one calibration run |
| Locked Vergi row on the close screen | hours | |
| Retire the appetite chip from three surfaces | a day | |
| Frank investor note, four states plus hover | a day | copy is a content pass |
| Door becomes MRR-only | hours | after the director ruling |
| Month record gains per-category expense | a day | prerequisite for the cause line |
| Monthly close screen rebuild to §4 | a day | |
| Gross margin (compute, display, trend) | a day | **blocked** on serving cost |
| Serving cost as a burn line | several days | owned by `05_operasyon.md` |
| Re-tune the profit streak and margin threshold against F2 | a day | after serving cost |
| Cap-table formula unification (three formulas to one) | hours | |
| Event cash deltas routed through the transactions log | hours | |
| `MONTH_HISTORY_CAP` raised to cover a 24-month run | hours | |

---

## 7. Open questions for the director

1. **The door: MRR only (§5) or MRR + growth + brand (ch. 01 §2)?** The two chapters disagree and the code implements the second. This ruling changes what blocks the Hunt phase.
2. **Shutter length: 30 or 21** (§9), against 7 today. And which of the four recovery moves must actually exist for the window to be playable — collect early and downgrade infra do not, and firing is currently unreachable.
3. **Frank three lines** (§9) — exact wording, sealed voice, content pass.
4. **Does araçlar split into two lines in EA** (§9), tooling against accounting?
5. **Overtime as a burn line.** The chapter names three lines; the code has a fourth with a real writer. Fold it into maaşlar or amend the chapter.
6. **Do the Product tab and the ODA board keep an investor readout** once the appetite chip is retired, or does the door become a Finance-only surface?
7. **Profit streak and margin threshold** are [WORKING] at 6 months and 15 percent with a 20,000 MRR floor (`endings_system.gd:43-45`). They were tuned in a world with no serving cost; both need re-deriving once one exists.
