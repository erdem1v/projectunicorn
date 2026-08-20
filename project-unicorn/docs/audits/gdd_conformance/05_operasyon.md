# Operasyon — GDD v2 conformance

**Date:** 2026-08-20 · **Chapter:** 06 · Operations (DIRECTOR-APPROVED 2026-08-20)
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Companions:** `01_urun.md` (DESTEK card, publish flow, tech debt), `04_finans.md` (the cost line and gross margin), `03_ekip.md` (coverage, the assignment layer), `02_satis_ve_pazar.md` (satisfaction inputs).

---

## Verdict

**This module does not exist.** Not partially, not in stub form — at `7687095` the whole of `scripts/` outside `debug/` returns zero hits for serving cost, hosting, provider or COGS, one hit for coverage (an unrelated localization test) and three for support load, all of them **tombstone comments recording that the field was deleted** because nothing read it (`customer.gd:54-55`, `b2b_constants.gd:55-59`, `b2b_sales_system.gd:378-380`). Tech debt exists as one boolean consumed once. Incidents do not exist in any form.

That makes Operasyon the largest build in the audit — and the most load-bearing, because chapter 01 §5 names its forces as **the** Traction pressure: costs that scale with customers, support load, and coverage hires. Today none of the three exists, which is why Calibration Round A measured profitability arriving in month 8-9 instead of 18-20 (**F2**: nothing scales cost with revenue).

The good news is architectural. Chapter 06 §0 rules that Operations has **no tab** — its forces live inside Ürün (the DESTEK card), Finans (the cost line) and Ekip (the coverage ratio). That decision is already half-honoured by accident: there is no Ops system to put in a tab. It is also half-violated: **an `ops` tab exists in the rail** (`ui_tokens.gd:531`) and opens an İçerik yolda placeholder. Removing it is hours of work and should happen early, so nobody builds toward it.

One conflict to record: §1.1 lists "move a feature from free to paid" among the player answers to serving cost. Ch. 03 **rev 4 §11 cuts that mechanic entirely**. Rev 4 is later, so the answer set is: raise price, assign someone to cost optimisation, change tier or capacity.

---

## 1. Requirements

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 0.1 | **No Operasyon tab**; forces fold into Ürün, Finans and Ekip (§0) | An `ops` tab exists in the rail (`ui_tokens.gd:531`, button `LeftTabs.tscn:283-343`), fully clickable, opening the generic placeholder (`center_viewport.gd:100, 122-157`). No Ops system exists behind it. | **ÇELİŞİYOR** (the tab must go) | hours |
| 1.1 | `serving_cost = provider_fixed(tier) + unit_cost(tier) x usage` (§1.1) | **Nothing.** No formula, no constant, no burn id, no string key. | **YOK** | several days |
| 1.2 | usage = paying customers + free users + B2C audience activity (§1.1) | No usage aggregate exists. The only per-user quantity that reaches a system is `b2c_audience`, and it produces **bugs**, not money, through post-ship wear (`product_system.gd:760-778`). A B2B run has no usage quantity at all. | **YOK** | a day (after per-feature usage weight lands — `01_urun.md` 2.6) |
| 1.3 | Product type changes the slope: AI steep, SaaS shallow (§1.1) | Subtype exists and carries `price_tendency` and axis weights (`product_catalog.gd:20-46, 162-215`) but no cost slope. | **YOK** | hours (once 1.1 exists) |
| 1.4 | Free users cost money and produce no revenue (§1.1) | They produce no revenue, correctly. They cost nothing. | **YOK** | included in 1.1 |
| 1.5 | Player answers to serving cost: raise price · **move a feature free→paid** · assign an engineer to cost optimisation · change tier or capacity (§1.1) | Raise price exists (B2C only). **Free→paid is cut by ch. 03 rev 4 §11** and should be struck from this list. Cost-optimisation work does not exist as a job. Tier and capacity do not exist. | **KISMİ / chapter conflict** | see 1.9 and `03_ekip.md` 2.9 |
| 1.6 | Reader: a Finans burn line named Servis maliyeti, plus gross margin at the monthly close called out as a delta with a cause (§1.1) | Neither the line nor the margin exists — `04_finans.md` 1.3 and 2.2. | **YOK** | owned by Finans |
| 1.7 | `load = a x active_accounts + b x live_bugs + c x version_age` (§1.2) | **Nothing.** `support_load` was a `Customer` field written twice and read never; it was deleted with a tombstone (`customer.gd:54-55`). All three inputs exist as numbers — active accounts (`customer_registry.gd:47-52`), live bugs (`game_state.gd:76`), version age (stamped once and unread, `product_system.gd:1243-1245`) — but nothing combines them. | **YOK** | several days |
| 1.8 | `capacity = throughput x assigned_heads x Müşteri Başarısı x Hız` (§1.2) | A CS desk throughput formula exists and is close in spirit: `0.5 + 0.15 x pace` per rep, stacked with a 0.6 rank decay and an overtime multiplier (`customer_rep_system.gd:64-82`, consts `b2b_constants.gd:340-341`). But it is throughput for a **request queue**, not capacity against a load figure, and `assigned_heads` counts only `customer_rep` employees — no other role can cover support (`customer_rep_system.gd:91, 181`). | **KISMİ** | a day (after the assignment layer) |
| 1.9 | load above capacity worsens response time, which lowers satisfaction, which produces risk cards and churn in B2B and sours word of mouth in B2C (§1.2) | **The chain does not exist.** B2B satisfaction reads product stability plus trust only (`b2b_sales_system.gd:96-106`); B2C reads the experience axis and live bugs (`sales_system.gd:414-428`). Neither has a load, latency or staffing term. An absorbed request grants zero satisfaction **by deliberate design** (`customer_rep_system.gd:258-259`), and the only latency-shaped constant, `CS_ESCALATE_AFTER_DAYS = 3` (`b2b_constants.gd:347`), decides who sees the card, not how the account feels. | **YOK** | several days |
| 1.10 | Reader: a load-against-capacity bar on the DESTEK card, and a HUD pip (§1.2) | No DESTEK card exists (`01_urun.md` 1.2). | **YOK** | a day (after the card) |
| 1.11 | `coverage = active_accounts / covering_heads`, founder included (§1.3) | **No coverage concept exists.** Two adjacent numbers do: `cs_capacity(pace) = 3 + floor(pace/3)` per rep (`b2b_constants.gd:202-209`) and `FOUNDER_DIRECT_CAP = 4` for founder-held accounts (`:195`, used `customer_rep_system.gd:128-135`). Both govern *delegation*, not decay. | **YOK** | a day |
| 1.12 | Past the threshold, uncovered accounts decay in satisfaction (§1.3) | Nothing decays for lack of cover. The only per-account modifier of drift is `cs_dampen`, which **slows erosion for covered accounts** rather than accelerating it for uncovered ones (`b2b_constants.gd:218-224`, `b2b_sales_system.gd:76-82`). Same direction, half the mechanism. | **YOK** | a day |
| 1.13 | Three ways out: hire (burn up), assign the founder (locking build, sell or fundraise), accept the decay (§1.3) | Hiring exists. **Assigning the founder to support does not exist** — the founder is a constant presence with no job (`03_ekip.md` 1.13). Accepting decay is free because there is no decay. | **YOK** | several days (blocked on the assignment layer) |
| 1.14 | Reader: a Kapsam ratio in Ekip with amber and red, and a badge when red (§1.3) | No ratio, no badge. The badge **mechanism** exists (`left_tabs.gd:151-158`) and HR already feeds it a count, so the plumbing is there. | **YOK** | hours (after 1.11) |
| 1.15 | Tech debt rises with fast shipping: short TASARIM, shipping at cap, shipping with many remaining bugs (§1.4) | Tech debt is **one boolean**, `tech_debt_birikti` (`game_state.gd:86`), written only by two authored event JSONs and never by any shipping behaviour. Round count, effort cap and remaining bugs do not touch it. | **YOK** | a day |
| 1.16 | Tech debt raises serving cost, live bug rate and incident probability (§1.4) | It does exactly one thing, once: `+5` bugs at the dev-to-beta transition (`product_system.gd:534-539`, consumed `:632`). No cost term, no rate term, no incident term. | **YOK** | a day (after 1.15) |
| 1.17 | Paid down by assigning someone, competing with V2 (§1.4) | No such job (`03_ekip.md` 2.9). | **YOK** | included in the assignment layer |
| 1.18 | Reader: one meter on the DESTEK card with a two-line tooltip (§1.4) | Tech debt is **invisible everywhere**. An orphan CSV key `BUILD_TECH_DEBT` (`strings.csv:429`) has zero code references. | **YOK** | hours (after the card) |
| 2.1 | Altyapı is a step in the publish flow, before Yayınla, re-asked at each version (§2) | There is no publish flow at all (`01_urun.md` 9.1). | **YOK** | several days |
| 2.2 | Provider = service quality: three fictional foreign-named providers setting reliability, latency floor, unit price and **enterprise eligibility** (§2.1) | Nothing. No provider entity, no names, no tier. Enterprise accounts are separately unreachable anyway — `SCALE_DEMO_MAX = 3` gates 4-5 star accounts behind a flag no gameplay code sets (`b2b_constants.gd:24, 62-68`). | **YOK** | several days |
| 2.3 | Capacity is independent of provider, scalable at any time; under-provisioned degrades response and raises incident risk, over-provisioned wastes cash (§2.2) | Nothing. The word capacity in this codebase means the build-job divisor (`product_system.gd:233-259`) or a CS rep account ceiling — neither is infrastructure. | **YOK** | several days |
| 2.4 | Incident probability = f(provider reliability, capacity headroom, tech debt, live bugs); never random alone; telegraphed by a health indicator turning red (§2.3) | No incident probability, and three of its four inputs do not exist. | **YOK** | several days |
| 3.1 | One incident type: telegraphed risk state over weeks → an event on a **named** account or audience → a response choice on the existing risk-card UI (§3) | No incidents. The **UI grammar is ready**: the retention card is exactly this shape — a named speaker, a body in that account voice, three or four costed options with locked rows carrying reason lines (`b2b_event_factory.gd:24-82`). An incident card would be a fifth builder in the same file. | **YOK** | several days |
| 3.2 | Three responses: yangını söndür (pull people off the build, V2 stalls) · telafi et (credit or discount, hits margin) · oyalama yok (accept the satisfaction and brand hit) (§3) | Two of the three have seams already: a discount is `apply_discount` (`b2b_sales_system.gd:324-340`) and doing nothing is the existing `b2b_retain_ignore` (`:343-347`). **Pulling people off the build has no seam** — that is the assignment layer again. | **KISMİ** | a day (after the assignment layer) |
| 3.3 | Rare: at most one in the demo, a few per full run; consequences hit satisfaction, churn and margin, never instant loss (§3) | — | **YOK** | included in 3.1 |
| 5.1 | **First bite:** the first ops decision lands at the first CANLI/DESTEK transition — publish v1, pick a provider and capacity with almost no money, first accounts arrive, and the moment the player wants to start V2 they meet who covers support. No money needed for it to bite (§5) | None of the four beats exists: no publish infra step, no DESTEK transition, no coverage question, no founder lock. | **YOK** | the module as a whole |
| 6.1 | v1 excludes uptime/SLA meters, contractual penalties, a compliance system, on-call, data and privacy, capacity planning UI beyond one control, an Operasyon Müdürü, multi-region (§6) | None of these exists, so nothing has to be removed. | **VAR (zero work)** | zero |

---

## 2. Contradictions, expanded

### 2.1 The Operasyon tab exists and must not

Ch. 06 §0 is emphatic: no tab, and it gives the reasoning — the only comparable game with a dedicated ops screen is criticised for it, and a thin tab would read as filler in a 60-90 minute demo. The rail nevertheless carries `ops` (`ui_tokens.gd:531`) with an icon, a localized label and a placeholder page. Ch. 12 §1 also has no Operasyon in its tab list. **Remove it early**, before any of this module is built, so nobody designs a screen for it.

Removing a rail entry is not free of hazards: badge indices in `left_tabs.gd:139, 146, 149` are hard-coded integers keyed to positions, so anything removed above index 7 silently misroutes badges. See `09_arayuz_ve_oda.md` for the full touch-list.

### 2.2 Free-to-paid is listed as an answer to serving cost, and rev 4 cut it

Ch. 06 §1.1 lists four player answers to a rising serving cost, one of them "move a feature from free to paid". Ch. 03 **rev 4 §11** cuts per-feature free/paid packaging outright and says not to re-introduce it. Rev 4 is the later document. The surviving answers are: **raise price · assign someone to cost optimisation · change the infra tier or capacity.** Worth noting because three answers instead of four makes cost optimisation and the tier choice carry more weight than the chapter assumed.

### 2.3 The deleted field is the right shape and was deleted for the right reason

`Customer.support_load` existed, was written twice, read never, and had no registry seam; it was removed in Task 2b with a tombstone (`customer.gd:54-55`) and a matching one for its helper (`b2b_constants.gd:55-59`). That was correct at the time. The lesson for the rebuild is the one the tombstone states: the field is worthless until something **reads** it. Build the reader — response time feeding satisfaction — in the same pass as the field, or it will be deleted again.

### 2.4 Every input to §1 already exists as a number; nothing combines them

This is the module cheapest good news. `load` wants active accounts (`customer_registry.gd:47-52`), live bugs (`game_state.gd:76`) and version age (`product_system.gd:1243-1245`) — all three are live values today, and only version age needs re-shaping. `coverage` wants active accounts over covering heads, and the head count exists as a role query. `serving_cost` wants a usage aggregate, which needs one new per-feature field. The work is in the **wiring and the readers**, not in inventing quantities.

### 2.5 Two of the four forces are blocked on the same thing

Coverage (§1.3) and the incident response yangını söndür (§3) both require the ability to say *this person is on support and not on the build*. So does §5 first bite. That is `03_ekip.md` §2.9-2.11 — the assignment screen and one-person-one-job. Operasyon cannot be finished before it, which is why the implementation order puts Ekip first and pairs Operasyon with Finans afterwards.

---

## 3. Seams

Because the module is greenfield, almost every row is an **absent** seam. That is the point of the table: these are the connections the rest of the GDD assumes exist.

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| **Usage → serving cost** | Ürün → Operasyon | **ABSENT.** Needs per-feature usage weight (`01_urun.md` 2.6) and a usage aggregate over paying, free and audience activity. | **absent** |
| **Serving cost → burn** | Operasyon → Finans | **ABSENT.** One burn id and one writer (`finance_system.gd:34-47`). | **absent** |
| **Serving cost → gross margin** | Operasyon → Finans | **ABSENT**, and it is the reason margin cannot exist (`04_finans.md` 2.2). | **absent** |
| **Live bugs → support load** | Ürün → Operasyon | **ABSENT.** The live bug count exists (`game_state.gd:76`). | **absent** |
| **Active accounts → support load and coverage** | Satış → Operasyon | **ABSENT.** The count exists (`customer_registry.gd:47-52`). | **absent** |
| **Version age → support load** | Ürün → Operasyon | **ABSENT**, and version age is itself absent as a usable number. | **absent** |
| **Load vs capacity → response time → satisfaction** | Operasyon → Satış | **ABSENT.** The deliberate zero-credit rule for absorbed requests (`customer_rep_system.gd:258-259`) is the design decision that would need revisiting. | **absent** |
| **Coverage → satisfaction decay** | Operasyon → Satış | **ABSENT.** `cs_dampen` is the mirror image and covers only assigned accounts. | **absent** |
| **Coverage → hiring trigger** | Operasyon → Ekip | **ABSENT** as coverage, **present** as an analogue: `needs_engineer` after three bug sprints in twenty days drives the AŞIRI YÜKLÜ badge and is cleared by a developer hire (`product_system.gd:844-855`, `hr_search_system.gd:224-228`). The pattern to copy. | **absent (analogue exists)** |
| **Assigned heads → support capacity** | Ekip → Operasyon | **PARTIAL.** The CS desk reads `customer_rep` headcount and pace (`customer_rep_system.gd:39-82`), but no other role can cover support and there is no assignment layer. | **partial** |
| **Founder assigned to support** | Ekip → Operasyon | **ABSENT** — the founder holds no job. | **absent** |
| **Tech debt → serving cost, bug rate, incident probability** | Operasyon ↔ Ürün | **ABSENT** in all three directions; debt is one boolean with one consumer. | **absent** |
| **Short design, shipping at cap, shipping buggy → tech debt** | Ürün → Operasyon | **ABSENT.** Debt is written only by two event JSONs. | **absent** |
| **Provider grade → enterprise eligibility** | Operasyon → Satış | **ABSENT**, and the enterprise tier it would gate is itself unreachable (`b2b_constants.gd:24`). | **absent** |
| **Capacity headroom → incident probability and response time** | Operasyon → Satış / Event | **ABSENT.** | **absent** |
| **Incident → event card** | Operasyon → Event | **ABSENT.** The card grammar exists (the retention family, `b2b_event_factory.gd:24-82`); the event vocabulary has no incident effect. | **absent** |
| **Incident compensation → margin** | Operasyon → Finans | **ABSENT**; the discount seam it would reuse exists (`b2b_sales_system.gd:324-340`). | **absent** |
| **Downtime → share loss in a contested segment** | Operasyon → Rakipler | **ABSENT** on both sides. | **absent** |

---

## 4. Depends on / depended on by

**Operasyon depends on:**
- **Ekip** — the assignment layer, for covering heads, the founder lock and the cost-optimisation job. Hard blocker for §1.3, the §1.4 payback and §3.
- **Ürün** — per-feature usage weight, a real version-age number, a DESTEK card to host the load and debt readers, and a publish flow to host the Altyapı step. Hard blocker for §1.1, §1.2 and §2.
- **Satış** — the active account count (already there) and the willingness to add a satisfaction input.

**Depends on Operasyon:**
- **Finans** — the serving-cost line and therefore gross margin, the §4 close-screen cause, and the F2 re-tune. Total dependency.
- **Sonlar** — the profit predicate reads margin; ch. 01 §5 Traction pressure is this module.
- **Satış** — support responsiveness as an account need.
- **Event** — the incident family and the coverage-red trigger.

**Can it be decided alone?** The *shapes* can be designed now — the four forces, the two infra axes and the incident grammar are all specified in the chapter. The *wiring* cannot start before Ekip and Ürün land. Design it with Finans in the same sitting, since the two share the margin and the close screen.

---

## 5. UI work

Ch. 06 §0 forbids a tab, so every reader below belongs to a screen someone else owns.

**Ürün — the DESTEK card** (new; `01_urun.md` owns the card itself)
- **Support load against capacity** as a bar, with the three contributors legible: accounts, live bugs, version age.
- **Tech debt** as a single meter with a two-line tooltip — what raised it, what it costs.
- **Capacity headroom** with a health state that turns red **before** an incident can fire. §2.3 requires the telegraph, so this is not decoration.

**Ürün — the publish flow** (new)
- **Altyapı step**: provider as a three-way choice with reliability, latency floor, unit price and enterprise eligibility stated in player vocabulary, and **capacity as an independent control** the player can move at any time afterwards. Both pre-filled at each version, with a line about what this version will consume.
- The chapter is explicit that a cheap provider with high capacity is a legitimate strategy, so the screen must not read as a quality ladder.

**Finans**
- A **Servis maliyeti** burn line, and gross margin at the monthly close with a delta and a cause.

**Ekip**
- A **Kapsam** ratio with amber and red states, plus a rail badge when red.

**Events**
- The incident card reuses the risk-card grammar with a named account or audience; each of the three responses needs a visible cost chip, and yangını söndür must state what it stalls.

---

## 6. Sizing

| Item | Size | Assumes |
|---|---|---|
| Remove the `ops` rail tab | hours | mind the hard-coded badge indices |
| Strike free-to-paid from the §1.1 answer list | zero (document only) | director confirms rev 4 wins |
| Tech debt as a number, written by short design, shipping at cap and shipping buggy | a day | |
| Tech debt readers: serving cost, bug rate, incident probability | a day | after serving cost and incidents |
| **Serving cost** (formula, tier and unit constants, usage aggregate, burn line, subtype slope) | several days | needs per-feature usage weight from Ürün |
| **Support load and capacity** (formula, readers, response time) | several days | needs the DESTEK card and the assignment layer |
| Response time feeding satisfaction, both markets | a day | reverses the deliberate zero-credit rule |
| **Coverage** (ratio, threshold, decay, HR readout, badge) | several days | needs covering heads from the assignment layer |
| **Altyapı** (provider entity, three fictional providers, capacity control, publish step, re-ask per version) | several days | needs the publish flow |
| Enterprise eligibility gate | a day | the enterprise tier is separately unreachable today |
| **Incidents** (risk state, telegraph, event card, three responses) | several days | reuses the retention card grammar |
| Incident compensation feeding margin | hours | reuses the discount seam |
| Re-tune the profit streak against the new cost curve | a day | owned by Finans, caused by this module |

---

## 7. Open questions for the director

1. **Is the AI-versus-SaaS product-type choice available in the demo?** (§7.) The chapter calls it the strongest form of the fix and notes that it doubles the tuning surface — it is what makes the cost slope a decision rather than a fact.
2. **One incident in the demo, or zero?** (§7.) Zero means the whole incident family is EA and this module shrinks by several days.
3. **How aggressive is the coverage threshold?** (§7; the chapter says it must trip well before 25 accounts.) This number decides when the first support hire is forced, so it sets the shape of Traction.
4. **Provider names** (§7, content pass), and whether a fourth self-hosted option exists later.
5. **Does the free-to-paid line come out of §1.1?** Rev 4 cuts the mechanic; confirm the chapter text follows.
6. **Serving-cost magnitude.** F2 says nothing scales cost with revenue and profitability arrives about nine months early. Whatever slope is chosen must be tuned against `full_run:730` before the profit streak is re-tuned, or the two changes will chase each other.
