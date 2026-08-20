# Satış ve pazar — GDD v2 conformance

**Date:** 2026-08-20 · **Chapters:** 04 · Market & Sales (primary); 10 · Rivals & World §2 (share); 03 rev 4 §3 (B2C tiers, B2B contract price)
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Companions:** `07_rakipler.md` (share mechanics), `03_ekip.md` (sales capacity), `05_operasyon.md` (support responsiveness), `docs/audits/calibration_round_A_2026-08-19.md` (findings F1, F3, F5).

---

## Verdict

Chapter 04 was written with a good eye for what already works, and most of its KEEP list is genuinely kept — the account lifecycle, the retention card with its new discount cap and risk hysteresis, the pitch as the close moment, compounding B2C word of mouth. What it asks for beyond that is one large structural change and several smaller ones. The large change is **segments**: today there is no market model at all. B2B is a finite pool of 65 named companies that permanently depletes, and the run only ever sees the 20-25 of them whose sector matches the product. Calibration Round A already measured the consequence and logged it as **F1**: the competent policy plateaus at ~25 accounts and ~$39K MRR from month 7 because the pool runs dry, which is why the Series A door is unreachable on the B2B path inside 24 months.

The second structural absence is **sales capacity**. Leads arrive at a fixed 2 per 5 days from a button whether or not anyone is selling, and nothing anywhere caps how many the player can work. Chapter 01 §5 makes founder time the Bootstrap pressure; that pressure has no carrier on this side.

One correction to the chapter itself: §5 lists B2B price band by scale x segment under EXISTS. It does not exist — price comes from the archetype band alone, and scale and sector reach tolerance, not money. That row is a gap, not a keep.

---

## 1. Requirements

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | Market is segments, not a list: ~5 B2B sectors, ~3 B2C audience segments (04 §1) | No segment entity exists. B2B has 13 sector **ids** (`b2b_constants.gd:99-101`) used for labels, voice, contact and tolerance bonus only. B2C is a single float, `b2c_audience` (`game_state.gd:96`). | **YOK** | several days |
| 1.2 | Each segment carries addressable size, interest, our share, rival share, saturation, slow regeneration (04 §1) | None of the six exists. The nearest analogue to size is the per-sector company list (5 names each, `company_catalog.gd:28-120`); the nearest to share is a display curve that reads no segment (`rival_registry.gd:164-196`). | **YOK** | several days |
| 1.3 | Named hero accounts sit on top of a statistical pool; **the pool never exhausts** (04 §1) | The opposite. 65 named companies, 13 sectors, and a run sees only the 4-5 affinity sectors for its subtype (`b2b_constants.gd:231-234, 249-250`) — 20-25 companies. Every signed name is permanently excluded, churn included (`pitch_system.gd:117-124`, `game_state.gd:230`, comment `pitch_system.gd:47-48`). When the pool dries, `spawn_prospect` returns null and the tab shows havuz kuru (`sales_tab.gd:186-187`). | **ÇELİŞİYOR** — this is calibration finding **F1** | several days |
| 2.1 | Leads per month = f(segment pool, marketing spend + brand, referrals, version/interest) (04 §2) | Two producers, neither reads any of those four. Founder button: **2 leads per 5 days**, flat (`sales_tab.gd:13-14, 473-485`). Sales rep: `0.06 x decayed HIZ sum x overtime` per day, daily cap 2, pipeline soft cap 8 (`sales_rep_system.gd:91-114`, consts `b2b_constants.gd:304-306`). Brand, marketing and version age are not read anywhere in lead generation. | **ÇELİŞİYOR** | several days |
| 2.2 | Lead → opportunity → close as stages (04 §2) | No stage field on `Prospect` (`prospect.gd:12-40`). One progress scalar, `warm_progress`, advanced only by reps (`sales_rep_system.gd:158-176`). A prospect is open or gone. | **YOK** | a day |
| 2.3 | **Sales capacity** = people assigned to sales (hires + founder when assigned); no capacity means no new accounts (04 §2) | **Absent.** The only founder throttle is a flat 2-day meeting cooldown (`pitch_system.gd:17, 196-197, 342`). Rep headcount raises supply and adds an autonomous close; it never caps the player. With zero reps the desk returns early (`sales_rep_system.gd:33-34`) and leads sit inert forever. | **YOK** | several days (needs the Ekip assignment layer) |
| 2.4 | Unworked leads wait, then cool and drop (04 §2) | No ageing of any kind. `warm_progress` only increases (`sales_rep_system.gd:170`); `Prospect.spawned_on_day` is written (`pitch_system.gd:99`) and **read by nothing**; nothing removes a lead except signing, losing or an auto-close. A CALLBACK deliberately leaves the lead in the pool forever (`pitch_system.gd:368`). | **YOK** | a day |
| 2.5 | KEEP the pitch flow as the close moment (04 §2) | Four beats, kept and intact: intro / value / pricing / close (`pitch_system.gd:215-278`), rendered through the shared MeetingScene (`b2b_pitch_meeting.gd:88-118`). | **VAR** | — |
| 2.6 | Close probability from the Satış skill; deal size by scale x segment (04 §2) | Close: `SkillCheck.resolve(sales, base + delta + difficulty_stars − 1, accum + warm bonus)` (`pitch_system.gd:314-316`), formula `skill_check.gd:14-18`. Reads founder `sales` and `influence` only — no employee skill enters a roll (`sales_rep_system.gd:143-145`). Deal size: **archetype band only**, not scale x segment (`pitch_system.gd:358-360`, `customer_archetypes.gd:21-46`). | **KISMİ** | a day |
| 2.7 | CHANGE the find_prospects auto-spawn (04 §2) | Still exactly as the chapter describes it: 2 per 5 days regardless of who is selling (`sales_tab.gd:13-14`). | **ÇELİŞİYOR (by the chapter own instruction)** | included in 2.1 |
| 3.1 | KEEP satisfaction with tolerance by scale x sector (04 §3) | Two visible layers plus a hidden third. Satisfaction drifts toward a target at `SAT_DRIFT_STEP = 3`/day, x1.5 inside onboarding (`b2b_sales_system.gd:68-81`). Tolerance seeded `33 + (scale-1) x 9 + sector bonus` (`b2b_constants.gd:40-52`; construction/health +5, insurance +3 at `:43-45`) — re-seated by Calibration Round A §1. | **VAR** | — |
| 3.2 | KEEP risk streak, risk phase, churn countdown (04 §3) | `risk_streak` increments daily under tolerance; risk at 3 consecutive days (`b2b_constants.gd:10`); countdown 7 days (`:19`); churn at zero (`b2b_sales_system.gd:173-192`). | **VAR** | — |
| 3.3 | KEEP the retention card: Söz ver / Oyala / İndirim ver (**cap 2, 21-day hysteresis**) / Kendi haline bırak (04 §3) | All four rows exist (`b2b_event_factory.gd:24-82`). **Discount cap 2** is real and enforced on both channels through `RETAIN_DISCOUNT_MAX_USES` (`b2b_constants.gd:81`), counted via the registry seam (`customer_registry.gd:312-320`), and the capped row renders **visible, dimmed, inert, with a lock chip** (`b2b_event_factory.gd:315-321`, `event_modal.gd:337-345, 381-395`). **21-day risk re-entry hysteresis** is real (`RISK_REENTRY_DAYS`, `b2b_constants.gd:18`, gate `b2b_sales_system.gd:183-184`). | **VAR** | — |
| 3.4 | KEEP one retention gate shared by sweep and button (04 §3) | `can_offer_retention(c)` (`b2b_sales_system.gd:216-223`) is asked by both the daily sweep (`:200-204`) and the İlgilen button (`sales_tab.gd:342-344`). | **VAR** | — |
| 3.5 | KEEP expansion (04 §3) | Gate `can_offer_expansion` — active, never expanded, 45 days mature (`b2b_sales_system.gd:269-274`), shared by sweep and button. Applies seats plus `EXPANSION_PER_SEAT_MRR = 120` (`:371-387`). | **VAR** | — |
| 3.6 | KEEP referral (04 §3) | Not a mechanic. One authored event, `ev_ps_referral_b2b.json`, gated on `customer_count_min 1` and a 30 percent roll — **a delighted account and a barely-alive one are equally likely to refer**. `Customer.acquisition_source` documents a referral value (`customer.gd:42`) that nothing ever writes. | **KISMİ** | a day |
| 3.7 | KEEP CS escalation (04 §3) | One escalation per crossing of `CS_ESCALATION_SAT = 35` for assigned accounts, re-armed on recovery (`b2b_sales_system.gd:149-163`); honour or refuse (`b2b_event_factory.gd:111-134`). | **VAR** | — |
| 3.8 | ADD account memory: promises kept/broken, discounts used, incidents (04 §3) | **Two of three.** Promises: `trust_offset` (−12 broken, decaying 0.4/day, `b2b_constants.gd:373-376`) plus the per-account flag `b2b_broke_ID` (`b2b_sales_system.gd:459, 481`). Discounts: `retain_discounts` with a registry seam (`customer.gd:61`). **Incidents: absent** — no incident exists to remember. Also absent: renewal dates (`Customer.renewal_day` is declared and dead, `customer.gd:96`; ODA names the gap at `oda_view.gd:1387-1389`). | **KISMİ** | a day |
| 3.9 | **A broken promise locks Söz ver** for that account, with a visible reason (04 §3) | It does not. The promise row is gated only on having an unshipped pain feature and no currently open promise (`b2b_event_factory.gd:58-60`). A serial promise-breaker may keep promising indefinitely at half credit (`b2b_sales_system.gd:305-308`). This is calibration finding **F3**: 23 cards, 23 promises, 20 broken, **0 churn** — the unsalvageable account never leaves. | **YOK** | hours (the lock grammar exists — copy the discount row pattern) |
| 3.10 | ADD account needs: feature asks tied to **version age** (04 §3) | Feature asks exist (`pain_feature_id`, `b2b_sales_system.gd:486-504`) but are tied to what is unshipped, never to age. Version age is not read by anything (see `01_urun.md` seam table). | **YOK** | a day (blocked on version age) |
| 3.11 | ADD account needs: **support responsiveness** as a satisfaction input (04 §3) | Only as the absence of a penalty. An absorbed request grants **zero** satisfaction, deliberately (`customer_rep_system.gd:258-259`); an ignored escalation costs −6 (`b2b_constants.gd:319`) but only because the player clicked it away. **Nothing measures response latency against satisfaction.** | **YOK** | a day (needs support load) |
| 4.1 | KEEP B2C growth: marketing + word of mouth on satisfaction − churn, compounding both ways (04 §4) | Word of mouth is real and compounding: `grow += audience x 0.005 x max(0, sat − 60)/100`, and base growth scales by `clamp(sat/50, 0.3, 1.0)` (`sales_system.gd:90-93, 200-221`). Churn is proportional to audience (`:220`). **Marketing is not an input** — no marketing spend exists; the growth terms are base, quality, brand and reputation. | **KISMİ** — marketing is EA (ch. 14 §4) | — |
| 4.2 | KEEP the paid tier; conversion hit by bugs and price (04 §4) | `conversion_rate = clamp(0.35 x optimal/price, 0.02, 0.60) x max(0.4, 1 − bugs x 0.02)` (`sales_system.gd:507-515`) — the bug term is Calibration Round A §6. A price rise also takes an immediate audience haircut (`:518-526`). | **VAR** | — |
| 4.3 | ADD an audience-drop **edge** so B2C churn is a visible moment (04 §4) | Three modifiers can move the audience down (`churn_customer` B2C branch −15 percent, `audience_delta` with a signed pct, `event_manager.gd:666-690, 719-727`), and `ev_ps_bug_complaint.json` uses them. But there is **no edge condition** — nothing can trigger *on* a drop, because every condition in the vocabulary is a level (see `08_event_ve_anlati.md`). | **KISMİ** | a day |
| 5.1 | B2B price band by scale x segment (04 §5, listed as EXISTS) | **It does not exist.** Deal MRR is `lerp(band.low, band.high, price_mult) x mrr_mult` where the band keys on **archetype** only (`pitch_system.gd:358-360`, `customer_archetypes.gd:61-63`). `scale` reaches tolerance (`b2b_constants.gd:48-52`) and CS request difficulty (`customer_rep_system.gd:226`); `industry` reaches tolerance, names and voice. Neither touches money. | **YOK** (the chapter row is mistaken) | a day |
| 5.2 | B2C monthly price panel with conversion projection (04 §5) | Present and good: slider, three-zone spectrum, floor and optimal marks behind a Satış gate, and a four-figure projection SEÇİLEN / ÖDEYEN / MRR / DÖNÜŞÜM computed by the pure `estimate_price_change` (`pricing_panel.gd:153-292`, `sales_system.gd:539-554`). | **VAR** | — |
| 5.3 | **Price changes take effect with a lag** (04 §5) | No lag, and deliberately so: `apply_b2c_price` writes the flags, applies the hike haircut and re-derives MRR **in the same call** (`sales_system.gd:557-583`). B2B discount and expansion are equally immediate (`b2b_sales_system.gd:337-339, 375-377`). | **ÇELİŞİYOR** | a day |
| 6.1 | Sales tab: KEEP the B2B account list at FM density (04 §6) | Present: three card variants (calm / risk / expansion) with badges, MRR, seats, tenure, churn countdown, an in-voice risk reason and a steward line (`sales_tab.gd:299-368, 441-446`), attention-sorted (`:273, 285-289`). | **VAR** | — |
| 6.2 | ADD a pipeline panel: leads, opportunities, capacity gauge, unworked leads (04 §6) | None of the four. The prospect column is a flat list with one count (`sales_tab.gd:131`); `pipeline_optimistic_mrr()` exists but renders in **Finance** (`finance_system.gd:342`); `lead_rate_per_day()` is public for the UI and has **no UI caller** (`sales_rep_system.gd:91-92`). | **YOK** | a day (after 2.3) |
| 6.3 | ADD a share column per segment, B2B and B2C (04 §6, §7) | No segment aggregation anywhere in the tab; the tab makes **zero** references to `RivalRegistry`. Share appears only on the ODA board and the Product tab strip. | **YOK** | see `07_rakipler.md` |
| 7.1 | Rival share visible here; share moves with interest, price, version age, rival moves (04 §7) | Share is a closed-form function of catalog seed, momentum and day, normalised against player MRR (`rival_registry.gd:164-249`). It reads no interest, no price, no version age, and there are no rival moves. | **ÇELİŞİYOR** | several days — `07_rakipler.md` |

---

## 2. Contradictions, expanded

### 2.1 The market is a name pool that empties, and the GDD wants a market that regenerates

**The code decided:** every company a run can ever sign is a hand-written name in `CompanyCatalog` (65 names, 13 sectors, `company_catalog.gd:28-120`). A run touches only the affinity sectors of its subtype (`b2b_constants.gd:231-234`), so the true addressable pool is 20-25. Signing removes a name permanently — and churn does **not** return it (`pitch_system.gd:47-48, 117-124`).

**The GDD now rules** (04 §1): named hero accounts sit *on top of* a statistical pool; the pool never exhausts; growth is bounded by economics, not by content.

**This is already measured.** Calibration Round A finding **F1**: the competent policy plateaus at 25 accounts and about 39,000 MRR from month 7, pitches stop around day 176 because the pool is dry, expansions are the only MRR after that, and the Series A signal falls back from ISINIYOR to KAPALI in month 7. The Series A bar was left at 40,000 by ruling; the pool is the thing that must move.

**What it costs:** a segment entity with size, penetration and a regeneration rate; prospect generation that draws from the segment rather than from a name list; and hero accounts kept as authored cards layered on top. The 65 names stay — they become the memorable minority, not the entire supply.

### 2.2 Nobody has to sell for leads to arrive, and nothing limits how many can be worked

**The code decided:** the founder button spawns 2 prospects per 5 days (`sales_tab.gd:13-14`), a rate that exists whether the founder is building, pitching a VC or asleep. Reps add supply on top. The only throttle on the player is a 2-day cooldown between meetings (`pitch_system.gd:17`).

**The GDD now rules** (04 §2, and chapter 01 §5): sales capacity is the number of people assigned to selling, the founder counts only while assigned to it, unworked leads cool and drop, and with no capacity there are no new accounts however much marketing spends.

**Why it is the second-biggest item in this module:** it is where founder time becomes the Bootstrap pressure. Without it, "sell vs build vs hire" is not a trade — the player can do all three. Implementing it needs the Ekip assignment layer first, which is why the two modules are ordered together.

### 2.3 Every account shares one satisfaction target

`_satisfaction_target` is `global effective stability + this account trust_offset` (`b2b_sales_system.gd:96-106`). With no promise outstanding, `trust_offset` is 0 and **every account in the book has the identical target**. The file says so itself at `:109-114`. The GDD asks for per-account needs — feature asks tied to version age (3.10) and support responsiveness (3.11) — and those are exactly the two terms that would give an account a life of its own. Both are absent, and both depend on work owned elsewhere (version age in Ürün, support load in Operasyon).

### 2.4 Price is immediate on both sides

Rev 4 and chapter 04 §5 both want a lag. The code is emphatic in the other direction: `apply_b2c_price` re-derives MRR in the same frame so the change is felt now (`sales_system.gd:557-583`). Whichever way the director rules, it should be ruled once for B2C price, B2B discount and expansion together, since all three write MRR immediately today.

### 2.5 Two write-through violations to clean up in passing

`c.retain_stalls += 1` (`b2b_sales_system.gd:319`) and `c.cs_escalated = ...` (`:157, 160, 163, 358`) are raw field pokes. Every neighbouring field on the same object has a registry seam (`customer_registry.gd:312-341`). Cheap to fix while the module is open, and the WRITE-THROUGH LAW in `CLAUDE.md` asks for it.

### 2.6 The Oyala cap is invisible while the İndirim cap is exemplary

`RETAIN_DELAY_MAX_USES = 2` is enforced silently inside the seam (`b2b_sales_system.gd:317-318`), but the row is appended with no `unlock_condition` (`b2b_event_factory.gd:66-69`). Past the cap the player pays brand −1 for a documented no-op with no lock chip and no reason line — the exact grammar the discount row was given. One-line asymmetry, worth closing when the retention card is next touched.

---

## 3. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| MRR → cash | Satış → Finans | `SalesSystem._mrr_bridge()` is the single sink (`sales_system.gd:168-171`); `FinanceSystem` divides by 30 (`finance_system.gd:151`). Public re-entry `reflect_mrr()` (`:177-178`). | **present** |
| Pipeline → cash projection | Satış → Finans | `pipeline_optimistic_mrr()` at weight 0.5 feeds the green curve (`sales_system.gd:321-333`, `finance_system.gd:342`). | **present** |
| **CAC / cost to serve** | Satış → Finans | **ABSENT.** Sales activity never touches cash — no acquisition cost, no commission, no per-customer cost. Signing writes no transaction row, deliberately (`sales_system.gd:399-403`). | **absent** |
| Product quality and bugs → satisfaction, conversion, audience | Ürün → Satış | Three real channels (`b2b_sales_system.gd:101`, `sales_system.gd:200-221, 507-515`). | **present** |
| **Version age → interest and feature asks** | Ürün → Satış | **ABSENT** — nothing reads `mvp_launch_day` outside a display badge. | **absent** |
| Shipped features → pain features and promises | Ürün → Satış | `pick_pain_feature` (`b2b_sales_system.gd:486-504`); `PromiseRegistry` resolves on ship (`promise_registry.gd:112-123`). | **present** |
| Rep skills → leads, warming, autonomous close | Ekip → Satış | `sales_rep_system.gd:91-200`, capped at 600 MRR and only for already-shipped pain features (`:119-138`). | **present** |
| CS skills → churn dampening, request throughput | Ekip → Satış | `cs_dampen(expertise)` on downward drift only (`b2b_constants.gd:218-224`, `b2b_sales_system.gd:76-93`); desk throughput (`customer_rep_system.gd:64-82`). | **present** |
| **Sales capacity → lead throughput** | Ekip → Satış | **ABSENT** — headcount adds supply, never a ceiling. | **absent** |
| **Support load / coverage → satisfaction** | Operasyon → Satış | **ABSENT.** `support_load` was deliberately deleted as a field nothing read (`customer.gd:54-55`, `b2b_constants.gd:55-59`); coverage does not exist. | **absent** |
| **Serving cost per account or per user** | Satış → Finans | **ABSENT** — see `05_operasyon.md`. | **absent** |
| Retention, expansion, CS cards → events | Satış → Event | Eight `b2b_*` modifiers, all routed through `B2BSalesSystem` seams (`event_manager.gd:773-791`); four factory builders (`b2b_event_factory.gd`). The densest authored-event surface in the game. | **present** |
| Churn and promises → brand | Satış → world | `CHURN_BRAND −2` (`b2b_sales_system.gd:282`), `PROMISE_BROKEN_BRAND −3` (`:480`), stall −1, CS refuse −3. | **present** |
| Signings and closes → morale and news | Satış → Ekip / ticker | Big-signing morale beat (`hr_morale_system.gd:542-554`); rep closes push a ticker headline (`sales_rep_system.gd:197-198`). Nothing from the customer desk, retention, churn or promises reaches the ticker. | **partial** |
| **Rival share → account loss** | Rakipler → Satış | **ABSENT and gated off.** `RIVAL_SATISFACTION_HOOK = false` (`b2b_constants.gd:23`) guards a `return 0.0` stub (`b2b_sales_system.gd:121-122`); `RIVAL_LURE_ENABLED` (`:73`) has zero readers. | **absent** |
| Brand → B2C growth and the Series A door | Satış ↔ world | Brand is read by audience growth (`sales_system.gd:205`), the phase gate (`phase_gate_system.gd:56`), VC conviction (`vc_pitch_system.gd:127`) and the collapse ending. **Nothing the player can spend on moves it.** | **present but unbuyable** |

---

## 4. Depends on / depended on by

**Satış depends on:** **Ekip** (sales capacity, account ownership — the assignment layer), **Ürün** (version age, quality, feature asks), **Operasyon** (support responsiveness), **Rakipler** (per-segment share). It is the most downstream of the economy modules and should be decided after those four.

**Depends on Satış:** **Finans** (MRR is the only recurring income), **Yatırım** (the door and every meeting input read revenue and growth), **Sonlar** (both victory conditions read MRR), **Event** (the retention, expansion and CS family).

**Can it be decided alone?** Partly. Pricing, account memory, the promise lock and the retention grammar can be settled on their own. Segments, lead flow and capacity cannot — they are joint decisions with Ekip and Rakipler.

---

## 5. UI work

**Sales tab, B2B**
- A **pipeline panel**: leads by stage, opportunities in flight, a **capacity gauge** (worked against workable), and how many leads are cooling untouched with the days left before they drop.
- A **segment view**: for each segment its size, our share, the named rival share, and whether it is saturating. This is where neglect a segment and share drifts to a company you know becomes visible.
- On each account card: promise state including **a locked Söz ver with its reason**, discounts used out of two, and a support-responsiveness reading once one exists.
- The **rival list** lives here (ch. 10 §6), not on a tab of its own.

**Sales tab, B2C**
- The funnel as a funnel: free users, conversion, paying users, churn. The numbers exist but are scattered across the pricing panel and the Product tab.
- Segment share alongside it.
- The audience-drop moment needs somewhere to land other than a modal.

**Pricing surfaces**
- B2B needs a price the player can see and, per ch. 03 rev 4, set at Konsept and at publish.
- If price gains a lag, both panels must show pending against effective, or the lag will read as a bug.

---

## 6. Sizing

| Item | Size | Assumes |
|---|---|---|
| Broken promise locks Söz ver, with reason line | hours | reuses the discount lock grammar exactly |
| Oyala cap made visible | hours | same |
| Two write-through fixes (`retain_stalls`, `cs_escalated`) | hours | |
| Referral becomes satisfaction-driven rather than a flat roll | hours | |
| Lead cooling and drop | a day | needs `spawned_on_day` to gain a reader |
| Lead and opportunity staging | a day | |
| B2B price by scale and sector | a day | pairs with the Ürün price move |
| Price lag on both sides | a day | one ruling, three call sites |
| Pipeline panel and capacity gauge | a day | **after** sales capacity exists |
| **Sales capacity** (assigned sellers cap throughput) | several days | **blocked** on the Ekip assignment layer |
| **Segments** (entity, size, interest, share, saturation, regeneration) | several days | the single largest item in this module |
| Hero accounts layered over the statistical pool | a day | after segments |
| Account needs: feature asks by version age | a day | blocked on version age (Ürün) |
| Account needs: support responsiveness | a day | blocked on support load (Operasyon) |
| Per-segment share column | a day | blocked on `07_rakipler.md` |
| B2C audience-drop edge condition | a day | needs an edge in the event vocabulary |

---

## 7. Open questions for the director

1. **Segment counts and regeneration rate** (04 §9) — 5 B2B sectors and 3 B2C segments are [WORKING]; regeneration is the number that decides whether finding F1 is actually fixed.
2. **Can rivals steal hero accounts?** (04 §9, default yes as a rival move.) The cheapest way to make share loss feel like a loss.
3. **Lead cooling time** (04 §9) [WORKING].
4. **Price lag length**, and whether it applies to B2B discounts and expansions as well as B2C price.
5. **Promise cap** (calibration director question 2): mirror the discount cap at two open promises per account, or let a broken promise remove the row outright? This report recommends the second — it is what 04 §3 asks for.
6. **`RISK_REENTRY_DAYS` 21 against 28** (calibration director question 1): 21 gives 11 retention cards in the slip preset against a target under 10; 28 gives 7. Still unanswered.
7. **Enterprise scale.** `SCALE_DEMO_MAX = 3` (`b2b_constants.gd:24`) gates 4-5 star accounts behind a flag no gameplay code ever sets, so the enterprise archetype and its 3000-8000 band are unreachable (calibration finding F10). Confirm Tier-2 accounts stay out of the demo.
