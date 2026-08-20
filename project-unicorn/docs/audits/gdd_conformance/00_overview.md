# GDD v2 conformance — overview

**Date:** 2026-08-20 · **Baseline:** `main` @ `7687095`, working tree clean apart from one `.docx`. Every citation in this set resolves to that commit.
**Sources:** the thirteen chapters in `GDDs/`, with two director rulings applied on top — ch. 03 is **rev 4** (free/paid packaging and the beta-user program cut, deneyen renamed, the support-vs-build tension stated), and ch. 08 §1 burn is **maaşlar + araçlar + servis maliyeti**, marketing removed. Also cited throughout: `docs/.md` (Event Pool Design v1) and `docs/audits/calibration_round_A_2026-08-19.md`.

A note on the baseline. Everything that used to live on side branches — Calibration Round A, the Build Bar rework, the ODA 3D art migration — was merged and pushed on 2026-08-20 (`e30fa81`, 36 commits), and the new DELIVERY LAW retires branches and worktrees. So there is exactly one code state, and no exists-on-another-branch caveat anywhere in these reports.

---

## The ten modules, one line each

| Module | State |
|---|---|
| **[Ürün](01_urun.md)** | The build pipeline is the best-built system in the game; everything rev 4 adds sits outside it — no DESTEK phase, no version intent, no publish flow, a beta curve that does not decay, and **no cost at all to pulling the team off support**. |
| **[Satış ve pazar](02_satis_ve_pazar.md)** | The account lifecycle is kept and freshly calibrated, discount cap and hysteresis included; but there is **no market model** — a finite 65-company pool that permanently depletes — and **no sales capacity**, so leads arrive whether or not anyone sells. |
| **[Ekip](03_ekip.md)** | Deep morale, overtime, hiring and training on the **wrong shape**: two disjoint skill models, four of the six role skills existing only as role tags, and **no assignment layer at all** — which blocks three other modules. |
| **[Finans](04_finans.md)** | A good ledger over an economy with **no cost of revenue**, so the headline gross margin cannot be computed; burn is wrong on three of five lines; and the appetite chip shipped one day before ch. 08 §5 retired it. |
| **[Operasyon](05_operasyon.md)** | **Does not exist.** Zero hits for serving cost, coverage or incidents; the one support-load field was deliberately deleted. The largest build in the audit, and the one ch. 01 §5 names as the Traction pressure. |
| **[Yatırım](06_yatirim.md)** | The closest match to its chapter — Frank cheque, four funds, meeting and term-sheet table all built. Missing: **the seed rung**, relationships that carry, and terms derived from run state. |
| **[Rakipler](07_rakipler.md)** | Eighty rivals whose quality drifts upward and touches revenue through exactly one B2C channel. **Share is a display curve**, not a market; there is no move deck. Needs its own design session, and it cannot start before segments exist. |
| **[Event ve anlatı](08_event_ve_anlati.md)** | A competent single-event dispatcher where the GDD wants a storylet engine: 28 conditions and **not one system edge**, no arcs, no readable history, no slots, and an injection path that bypasses every gate. |
| **[Arayüz ve ODA](09_arayuz_ve_oda.md)** | The shell is in good shape, and the speed ladder, the build bar and the ODA plates all landed correctly. The rail carries **two tabs the GDD removes and misses one it adds**, badges have almost no producers, and onboarding is missing its middle beat. |
| **[Sonlar ve koşu](10_sonlar_ve_kosu.md)** | The soft cap and the profitability condition are right. **The bootstrap win has no Series A moment in it**, acquisition is cut and still reachable, Frank closing line never renders, and **no phase re-tightens the runway** — a stated law with no implementation. |

No Marketing report: ch. 14 §4 puts it in EA, and `GDDs/MARKETING MODULE resarch.docx` is the source for when that starts. Its seams appear inside Satış and Finans.

---

## The three findings that shape everything else

**1. There is no occupancy.** No person in the game is ever *busy*. The only contention is a company-level divisor counting jobs, not people (`product_system.gd:242-259`). Four separate GDD requirements are the same sentence seen from four angles: the support-vs-build tension (ch. 03 rev 4 §8), sales capacity (ch. 04 §2), the coverage threshold (ch. 06 §1.3), and the founder holding one job (ch. 02 §5). None can be built until Ekip has an assignment layer.

**2. There is no cost of revenue.** Every dollar of MRR is pure margin. That single absence takes out ch. 08 §2 gross margin, the ch. 08 §4 close-screen cause line, ch. 06 §1.1 in full, and ch. 01 §5 Traction pressure — and it is why calibration measured profitability arriving about nine months early (finding F2).

**3. The event engine cannot hear the systems.** `EventManager` subscribes to nothing; every system-fired card is a direct injection that bypasses eligibility. So churn, promise broken, phase change, coverage red, raise demand and rival move all exist as edges in code and are unreachable from content — which is exactly what the nine-arc pool design needs.

---

## Implementation order

Argued from the dependency picture in the ten reports, not from importance.

**0. Housekeeping first — hours, not days.** Remove the `ops` tab, add and lock `marketing`, re-order the rail. Re-expose Fire and Vacation in HR. Fix the double MentorIntroModal mount, the source-badge order that makes Frank cards read PİYASA, the empty archetype line on Hunt cards, and the ship tooltip that under-reports by five. These are cheap, several are visible defects today, and they stop other work building toward surfaces that are going away.

**1. Ekip.** The skill model and the assignment screen. Everything downstream is expressed in terms of who is occupied, and the six role skills are read by roughly fifteen formulas across Ürün, Satış and Operasyon — the longer that migration waits, the more call sites it touches. Ekip depends on nothing.

**2. Ürün.** Version intent, the DESTEK phase, the beta counter with a decaying curve, the publish flow, per-feature usage weight, version age as a real number. The support-vs-build tension lands here but only becomes possible after step 1.

**3. Operasyon and Finans together.** They share the margin, the close screen and the burn table, and neither is finishable alone: gross margin cannot exist before serving cost, and serving cost has no meaning without a burn line to land in. This is also the step that satisfies the ch. 01 §5 Traction pressure, so the pressure-law probe should run at the end of it.

**4. Satış ve pazar.** Segments, lead flow with capacity, account memory, the promise lock, price lag. Needs Ekip (capacity), Ürün (version age) and Operasyon (support responsiveness) in place, which is why it is fourth despite carrying the most requirements.

**5. Yatırım.** The seed rung, relationships that carry, the warm intro as a played decision. Mostly self-contained; its one external blocker is the door ruling in ch. 08 §5.

**6. Sonlar ve koşu.** The bootstrap gate, the acquisition cut, the Frank strip, the B2C ledger figures, the run summary. Depends on Yatırım for the Series A moment state.

**7. Rakipler.** Last, because share per segment is meaningless before segments exist — and because ch. 10 §8 asks for its own design session first.

**In parallel from the start: the event engine.** One admission path, signal triggers, history reads, slots, variant text and the budget governor depend on no other module. Its *vocabulary extensions* track the others as they land — an incident effect cannot exist before incidents do.

**Also in parallel, late: Arayüz.** The rail is step 0. Onboarding waits for Ekip and Ürün. Badges come last, because each of the seven kinds needs its producing system.

---

## Rulings needed before implementation starts

These block work rather than merely shaping it.

| # | Question | Blocks |
|---|---|---|
| 1 | **The investor door: MRR only (ch. 08 §5) or MRR + growth + brand (ch. 01 §2)?** The two chapters disagree; the code implements the second. | Finans, Yatırım, Sonlar |
| 2 | **Which states count as having faced the Series A decision?** (ch. 13 §7.) | Sonlar, Yatırım |
| 3 | **Interview step: in (ch. 02 §9) or out (ch. 07 §2)?** They produce different candidate cards. | Ekip |
| 4 | **Product Manager and Tester** — ch. 07 §1 lists four roles; the code has six, both extras carrying real mechanics. | Ekip |
| 5 | **Do repeated customer events use named slots in v1?** (ch. 11 §10.) Slots are several days of engine work; fixed names are zero. | Event |
| 6 | **Difficulty: Normal only (ch. 01 §6) or Normal and Hard (ch. 14 §2)?** | Sonlar |
| 7 | **Is the AI-versus-SaaS product-type choice in the demo?** (ch. 06 §7.) It decides whether the cost slope is a decision or a fact. | Operasyon, Ürün |
| 8 | **One incident in the demo, or zero?** (ch. 06 §7.) Zero shrinks Operasyon by several days. | Operasyon, Event |
| 9 | **Is the Events tab really removed** (ch. 12 §1)? It currently hosts the queue badge, the ODA phone target and Frank latched mentor line. | Arayüz, Event |
| 10 | **Training length** — three weeks (ch. 02 §7) against one (ch. 07 §5); the code does five days. | Ekip |

Two more that are cheap to answer and worth answering early: whether the acquisition **copy** is retired along with the reachable path (ch. 01 §3), and whether the chapter text for ch. 06 §1.1 drops the free-to-paid line that rev 4 cut.

---

## Cross-module seam matrix

Every seam the GDD implies, listed once. **Present** means a real mechanism with a citation; **partial** means it exists in a weaker or narrower form than the chapter describes; **absent** means nothing carries it. Absent rows are the ones that bite later, so they are listed with the same weight as the present ones.

### Ürün as producer

| → Consumer | Seam | Mechanism today | State |
|---|---|---|---|
| Finans | Feature licence cost at commit | `apply_one_time_cost(sum_cost, build_commit)` — `product_system.gd:1070, 1168` | **present** |
| Operasyon | **Usage → serving cost** | no usage weight, no aggregate, no cost | **absent** |
| Operasyon | **Live bugs → support load** | bug count exists (`game_state.gd:76`), nothing reads it as load | **absent** |
| Operasyon | **Short design / ship at cap / ship buggy → tech debt** | debt is written only by two event JSONs | **absent** |
| Satış | Quality and bugs → B2C audience, conversion, B2B satisfaction | `sales_system.gd:200-221, 507-515`; `b2b_sales_system.gd:101` | **present** |
| Satış | **Version age → interest and feature asks** | `mvp_launch_day` stamped once, read only for a display badge | **absent** |
| Satış | Shipped features → pain features and promise resolution | `b2b_sales_system.gd:486-504`; `promise_registry.gd:112-123` | **present** |
| Ekip | Sprint pressure → hiring signal | `needs_engineer` → OVERLOADED badge → cleared on hire | **present** |
| Ekip | **Build occupancy → who is unavailable** | capacity counts jobs, not people | **absent** |
| Event | Build phase → event eligibility, and the ship moment | `event_manager.gd:450-470`; `product_system.gd:1306-1308` | **present** |
| Sonlar | `mvp_shipped` → the Traction gate | `phase_gate_system.gd:39` | **present** |
| Rakipler | Version age → rival release comparison | version age has no readers | **absent** |

### Satış as producer

| → Consumer | Seam | Mechanism today | State |
|---|---|---|---|
| Finans | MRR → daily revenue → cash | `sales_system.gd:168-171` → `finance_system.gd:151` | **present** |
| Finans | Pipeline → the optimistic curve | `pipeline_optimistic_mrr()` at weight 0.5 | **present** |
| Finans | **CAC or cost to serve** | sales activity never touches cash | **absent** |
| Operasyon | Active accounts → load and coverage | the count exists; nothing consumes it as load | **absent** |
| Ekip | Big signing → a morale beat | `hr_morale_system.gd:542-554` | **present** |
| Ekip | CS refuse → rep morale | `b2b_event_factory.gd:131` | **present** |
| Yatırım | MRR, growth, churn → the door and the meeting | door `phase_gate_system.gd:53`; conviction `vc_pitch_system.gd:121-124` | **present** |
| Yatırım | **Three-month growth and margin → the meeting** | the streak exists in `GameState` and the meeting never reads it; margin does not exist | **absent** |
| Event | Retention, expansion, CS cards | eight `b2b_*` seams, four factory builders | **present** |
| Sonlar | MRR → both victory conditions | `endings_system.gd:45, 212` | **present** |
| Sonlar | **Audience and paying users → the ending ledger** | neither is in `get_run_ledger()`; the paper prints 1 or 0 | **absent** |
| world | Churn and promises → brand | `b2b_sales_system.gd:282, 480` | **present** |

### Ekip as producer

| → Consumer | Seam | Mechanism today | State |
|---|---|---|---|
| Ürün | Skills → build speed, ceilings, bug rate, beta tempo | `product_system.gd:315-343, 551-565, 705-721, 390-400` | **present** |
| Ürün | **Assignment → who is on the build** | one lead dropdown; the rest is implicit by role | **partial** |
| Satış | Rep skills → lead rate, warming, autonomous close | `sales_rep_system.gd:91-200` | **present** |
| Satış | Account ownership | `Customer.assigned_to`, picker in the Sales tab | **present** |
| Satış | **Assigned sellers → sales capacity** | headcount adds supply, never a ceiling | **absent** |
| Operasyon | CS heads → support capacity | throughput exists; only `customer_rep` can cover | **partial** |
| Operasyon | **Covering heads → coverage** | coverage does not exist | **absent** |
| Finans | Salaries and overtime → burn; four one-time costs | daily pull `finance_system.gd:134-143`; `apply_one_time_cost` | **present** |
| Event | Resignation, valve, positive beats | five factory builders, three modifiers | **present** |
| Event | **Raise demand, rival poaching** | neither event exists | **absent** |
| Arayüz | Attention count → rail badge | `hr_system.gd:170-183` → `left_tabs.gd:139` | **present** |
| Yatırım | Headcount → meeting inputs and a callback | `vc_pitch_system.gd:653-661, 293` | **present** |
| all | **Founder holds one job** | the founder is a constant presence everywhere | **absent** |
| Kişisel | Liderlik → morale climate and coordination | `hr_morale_system.gd:254-261`; `product_system.gd:310-312` | **present** |
| Yatırım / Event | **Karizma → terms and scandal outcomes** | renamed to `influence`; the scandal half has no writer | **partial** |
| all | **Founder energy → skill penalty and events** | no energy concept | **absent** |

### Operasyon as producer — every row absent, which is the point

| → Consumer | Seam | Mechanism today | State |
|---|---|---|---|
| Finans | **Serving cost → burn**, and therefore gross margin | no id, no writer, no formula | **absent** |
| Finans | **Incident compensation → margin** | no incidents; the discount seam it would reuse exists | **absent** |
| Satış | **Load vs capacity → response time → satisfaction** | absorbed requests grant zero satisfaction by design | **absent** |
| Satış | **Coverage → uncovered accounts decay** | `cs_dampen` is the mirror image, and only for covered accounts | **absent** |
| Satış | **Provider grade → enterprise eligibility** | no provider; the enterprise tier is separately unreachable | **absent** |
| Ürün | **Tech debt → serving cost, bug rate, incident probability** | debt is one boolean with one consumer | **absent** |
| Ekip | **Coverage red → hiring trigger** | absent as coverage; `needs_engineer` is the analogue to copy | **absent** |
| Event | **Incident card, coverage-red trigger** | no incidents, no coverage | **absent** |
| Rakipler | **Downtime → share loss in a contested segment** | absent on both sides | **absent** |

### Finans as producer

| → Consumer | Seam | Mechanism today | State |
|---|---|---|---|
| Yatırım | Cash and gross runway → conviction, and the door reading | `vc_pitch_system.gd:132-137`; `series_a_signal()` | **present** |
| Sonlar | Cash below zero → shutter → bankruptcy | `endings_system.gd:116-136` | **present** |
| Sonlar | Artıda streak and window margin → the bootstrap win | `endings_system.gd:206-216` | **present** |
| Sonlar | **Gross margin** as the quantity the win reads | a *net* window margin stands in | **partial, wrong quantity** |
| Arayüz | Runway → TopBar and a rail badge | `top_bar.gd:180-195`; `left_tabs.gd:141-146` | **present** |
| Ürün / Satış | **Phase → burn or any economic pressure** | nothing economic reads `GameState.phase` | **absent** |

### Yatırım as producer

| → Consumer | Seam | Mechanism today | State |
|---|---|---|---|
| Finans | Angel money → cash and the cap table | `angel_round_system.gd:182-183` | **present** |
| Finans | Series A terms → the cap table | `vc_pitch_system.gd:320-329` | **present** |
| Ürün | VC prep → build capacity | `pitch_prep_active` adds a job | **present** |
| Sonlar | Signing → `series_a_close`; rejections → the cascade | `vc_pitch_system.gd:314`; `endings_system.gd:158-180` | **present** |
| Sonlar | **The Series A moment → the bootstrap gate** | the predicate has no investor term | **absent** |
| Satış / Ekip | **Rejections → brand and morale** | rejections cost only a cascade point | **absent** |
| Kişisel | Valuation → net worth | stored; no page reads it | **absent (consumer side)** |
| Event | Meeting, expiry and soft-cap cards | three synthetic Frank cards | **present** |

### Rakipler as producer

| → Consumer | Seam | Mechanism today | State |
|---|---|---|---|
| Satış | Rival quality → B2C growth and erosion | `sales_system.gd:230-242` — the one real channel | **present** |
| Satış | **Rival pressure → B2B satisfaction** | gated off behind a false constant and a `return 0.0` stub | **absent** |
| Satış | **Price pressure, hero-account theft, per-segment share** | no moves, no share stock | **absent** |
| Ekip | **Poaching** | `RivalRegistry` never touches `CharacterRegistry` | **absent** |
| Yatırım | **A rival raised → the closing window** | no window state | **absent** |
| world | Share → the news ticker, the ODA board, the Product strip | `news_feed_system.gd:273-315`; `oda_view.gd:1144-1236` | **present** |
| Arayüz | **Share → the Sales tab** | the tab never references the registry | **absent** |

### Event engine as producer and consumer

| Direction | Seam | Mechanism today | State |
|---|---|---|---|
| all → Event | **System edge → trigger** | eighteen hard-coded injections stand in for a vocabulary | **absent** |
| Event → all | Effects reaching the economy | 43 dispatcher arms, nearly all through owning seams | **present** |
| Satış → Event | Account memory readable as a condition | one condition only, `b2b_discounts_below` | **partial** |
| Event → Event | Arc memory | `set_flag` / `flag_set`, used once in the whole corpus | **partial** |
| Event → Event | **Run history readable** | `get_history()` has zero callers | **absent** |
| Event → world | **Headline push** | no modifier can write to the ticker | **absent** |
| Event → Arayüz | Phone dot, buzz, and the modal born from the phone | `oda_view.gd:655-657`; `event_modal.gd:56-76` | **present** |

### Arayüz as consumer

| ← Producer | Seam | Mechanism today | State |
|---|---|---|---|
| Ekip | Flight risk, load over capacity | folded into one HR number | **partial** |
| Satış | Account at risk | state exists, the Sales tab has no badge refresh | **partial** |
| Operasyon | **Coverage red, infra capacity full** | no producers | **absent** |
| Ekip | **Raise demand** | the event does not exist | **absent** |
| all | **Locked opportunity** | five locked telegraphs exist, none badges a tab | **absent** |
| all | **Badge → the exact row** | `tab_changed` carries only a tab id | **absent** |

---

## How to read a module report

Each of the ten follows the same shape: a one-paragraph verdict, a requirement table with a verdict and a size per row, the contradictions expanded with both sides cited, the module seams, what it depends on and what depends on it, the UI work described as **information rather than layout**, sizing, and the open questions for the director. The UI section is the one to hand to Claude Design; the requirement table and the contradictions are the ones to read before deciding how a module should work.

Verdict vocabulary: `VAR` already there · `KISMİ` partial · `YOK` missing · **`ÇELİŞİYOR`** the code holds a decision the GDD now overrules · **`KALDIRILACAK`** the code holds a mechanic a later chapter cuts.
