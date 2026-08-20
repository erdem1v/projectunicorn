# Structural Research — B2B & B2C Product Lifecycle Redesign

**Date:** 2026-08-18 · **Type:** Research + design proposal · **Read-only** (no source, fixture, baseline or git change)
**Builds on:** `product_lifecycle_consult_2026-08-17.md` (lifecycle map, W1–W10, R1–R10) and
`playable_run_sprint_2026-08-17.md` (fire tables, churn autopsy, played run, calibration notes).
**Anchor:** working tree at `a683ab1`, 2026-08-18.

---

## Executive verdict

**B2C is not mis-tuned, it is mis-shaped, and it needs a rebuild of one formula rather than a
revision of many:** audience *growth* is an absolute constant per hour while audience *churn* is
proportional to audience, so the entire consumer economy is a fixed point rather than a growth
curve — measured, MRR peaks at ~$3,900 around day 45–60 and decays to $1,245 by day 179 **while
brand climbs to its maximum of 100**. **B2B is genuinely salvageable by revision**, because the
expensive parts — named companies, hidden tolerance, promises bound to real feature ids, a
watched churn countdown — are already built and correct; what is missing is that all of it hangs
off *one global number*, and the container that would give each account a life of its own
(the contract) does not exist. The two loops share one precondition that is neither of them:
**a played product is born 15–30 points below every account's bar** (`axis_score(13) = 20.6`
against tolerances of 35–50), so the retention loop is the default state of competent play, and
every communication fix shipped before that is corrected will make the game *better at
explaining* a product the world is contractually obliged to hate. **What I would do first,
in this order: (1) the three-lever quality re-seat, (2) the contract object, (3) the B2C growth
term** — the first unblocks the second, and the third is independent and can run in parallel.
The single most valuable structural insight in this report is that **three of our four worst
symptoms are one missing noun**: the contract is where renewal, price, seats, discount, promise
cadence and churn all belong, and without it they have scattered into six ad-hoc systems that
each re-fire forever.

---

## §1 · Problem inventory, reconciled

The two prior documents use different numbering. This maps them so nothing is fixed twice or
contradicted.

| This report | Consult | Sprint | Status after my verification |
|---|---|---|---|
| P7 played product below tolerance | **W1** | §5.1 | **Confirmed and worse** — see below |
| P8 book is one number | W3 (partly) | §5.1 | Confirmed |
| P9 weekly promises | — | §2 autopsy | Confirmed; fixed symptom, not cause |
| P10 uncapped discount | — | **§5.2** | Confirmed (628 uses / run) |
| P11 pain write-once | — | §5.3 | Confirmed |
| P12 no contract lifecycle | — | — | **New; the unifying gap** |
| P13 retention is a leak | W1 symptom, R5 | §5.1 | Confirmed |
| P14 İnovasyon dead on B2B | **W3** | 0c | Confirmed |
| P15 no B2B product event | **W2** | — | Confirmed |
| P1–P6 B2C | W2, W3 | §5.5, §5.6 | **P1 root cause newly identified** |
| P16 report card / picker / ceiling / Beta | **W4–W8, W10** | — | Consult owns these; I concur, no re-proposal |
| P17 test hygiene | — | §5.7 | Confirmed |

### Where I disagree with the consult

**Consult R1 is right in direction and under-scoped in magnitude.** It proposes dropping
`NORMALIZE_HALF_SAT` 50 → ~25 and re-seating the tolerance band. I verified the arithmetic and
it does not close the gap:

- `normalized_quality(c) = 100c/(c+50)` (`quality_model.gd:46, 85-87`).
- **`axis_score` normalizes a SINGLE RAW AXIS, unweighted** (`:96-97`). The per-sub-type
  `QUALITY_AXES` weights therefore **never touch** the B2B satisfaction target — they enter only
  `composite_quality`, i.e. B2C and rival ranking. The consult does not state this and it matters:
  no amount of per-type weighting will ever differentiate B2B accounts.
- The `saas_ops` unlocked pool yields stability: integration **7**, reporting 3, scheduling 3,
  workflow 0, mobile 0. `field` (**7**) is `requires_research: true` → locked in demo. **A
  3-feature demo v1 caps at raw stability 13**, not the consult's 18.
- `axis_score(13) = 20.6`; with 4 live bugs ≈ **19**. Tolerances: 35 (small) → 45–50 (mid/
  enterprise + sector bonus). **Every account is born 15–30 points under its bar.**
- At `HALF_SAT = 25`: `axis_score(13) = 34.2` — **still under the 35 floor** and far under 45.

**Therefore the re-seat needs three levers, not one** (§3.B1). The constant's own comment
(`:44-45`) nominates a second — "a global catalog contribution scale" — and the research-lock
placement is the third, because *which* features are locked sets the demo's stability ceiling.

---

## §2 · Genre research

Per class: the game that does it best, the mechanic, numbers where published, what makes it fun,
what makes it fail. Time scale is always ours (1 day = 1 day).

### A · Customer identity & satisfaction models — **best: Crusader Kings III**

CK3's opinion is **not a scalar**. Each character holds an opinion of each other character
composed of a *stack of named modifiers*, each with a source and many with their own decay rate:
Diplomacy skill contributes −8…+92, "Broken Truce" −50, "Attacked An Ally" −25, same dynasty +5,
"Bastard" −15; Tyranny decays at **−0.25/month**, and perks change that decay to −0.15 or −0.05.
Personality traits (Boldness, Compassion, Greed, Honor, Vengefulness…) additionally steer AI
behaviour without contributing a number at all.
([CK3 Wiki — Opinion](https://ck3.paradoxwikis.com/Opinion), [Modifiers](https://ck3.paradoxwikis.com/Modifiers))

**Why it is fun:** the player can *read the reasons*. A vassal is not "at 34" — he is "at 34
because you broke a truce, he is Vengeful, and he has not forgotten the war". Identical
situations play differently because the modifier stacks differ.
**Why it fails when copied badly:** with >10 modifiers CK3 stops displaying them; an unreadable
stack is the same as a scalar.
**Transfer:** our `trust_offset` is a single anonymous float decaying 0.4/day — CK3's primitive
with the identity removed. Turning it into a short list of named, dated, decaying entries is a
data-shape change, not a new system.

### B · Contract lifecycle — **best: Football Manager**

FM's contract is the reference model in games. Its transferable parts: a **term with an expiry
date**; a **renewal window** rather than a renewal moment — community consensus is to open talks
**at least 18 months before expiry**, because a player entering the final year gains decisive
leverage; **wage demands that move with performance and status**; and **clauses/bonuses as
trade goods** that let you lower the headline number by giving away something you value less
(appearance fees for squad players, goal bonuses for strikers, release clauses, optional
extensions).
([gamepressure FM contract negotiations](https://www.gamepressure.com/footballmanager2016/contract-negotiations/za8378),
[FMInside — clauses & bonuses to avoid](https://fminside.net/guides/financial-guides/53-clauses-bonuses-to-avoid-during-contract-negotiations),
[Operation Sports — the art of negotiating](https://www.operationsports.com/the-art-of-negotiating-in-football-manager-26/))

**Why it is fun:** the negotiation is a *multi-dimensional trade*, so there is no single right
answer, and the expiry clock converts a static roster into a calendar of pressure.
**Why it fails:** FM's own community complains that final-year leverage is so strong it collapses
into a forced sale — a renewal system with no middle outcome becomes binary.
**Real-world sanity check:** B2B SaaS annual retention sits in the **high 80s to ~90%**, monthly
churn median **3.5%** (top performers <2%), and **NRR by segment: enterprise 118%, mid-market
108%, SMB 97%**.
([Pavilion 2025 B2B SaaS benchmarks](https://www.joinpavilion.com/resource/b2b-saas-performance-benchmarks),
[Optifai NRR by segment](https://optif.ai/learn/questions/b2b-saas-net-revenue-retention-benchmark/),
[Userlens retention benchmarks](https://userlens.io/blog/retention-benchmarks-for-b2b-saas-in-2025))
That NRR split is the single most useful number in this report: **enterprise accounts should
grow past 100% of their signed value over time; SMB accounts should slowly shrink.** It gives the
ruled "tier-dependent by contract value" an empirical shape rather than an invented one.

### C · Promise / roadmap commitments — **best: Football Manager (and its failure is our bug)**

FM lets players extract promises (playing time, signings, sales) and tracks them to an outcome.
Breaking one escalates: the player distances himself, then forces an exit; break enough board
promises and you are sacked. Crucially **you get one or two chances to make amends** before the
consequence lands.
([MGW — consequences of a broken or failed promise](https://guides.magicgameworld.com/football-manager-2021-what-are-the-consequences-of-a-broken-or-failed-promise/))

**Why it fails — and this is our exact bug, already shipped in someone else's game:** FM24's
tracker is full of reports that promises *never clear* — the demand persists even when satisfied,
and the only resolution is to remove the player.
([SI community bug tracker — "promises never go away and can't be kept"](https://community.sports-interactive.com/bugtracker/previous-versions/football-manager-2024-early-access-bugs-tracker/press-conferences-club-vision-player-interaction-and-staff/players-constantly-complaining-promises-never-go-away-and-cant-be-kept-r19100/),
[SI forums — Broken Promises](https://community.sports-interactive.com/forums/topic/390662-broken-promises/))
**Transfer:** a promise must have a *terminal state that is visible*, and the thing that generated
it must stop generating it. Our P11 (pain feature write-once) is precisely FM's defect.

### D · Retention as pressure that resolves — **best: Frostpunk**

Frostpunk's contract is that pressure rises, you answer, and the answer *works* — Discontent and
Hope are twin meters with visible causes and visible responses, and the game reaches a resolution
(the storm ends, or you lose). **Why it fails when copied badly:** Software Inc.'s support system
demonstrates the anti-pattern — unresolved tickets accumulate overnight and crater reputation so
fast that a full day of answering cannot recover the loss, which players describe as
unrecoverable rather than pressuring.
([Software Inc. — support/reputation discussions](https://steamcommunity.com/app/362620/discussions/0/485623406958884072/))
**Transfer:** our retention modal is the Software Inc. failure mode, not the Frostpunk pattern:
29 identical decisions, no state change, no terminal.

### E · B2C growth engines — **best: Game Dev Tycoon**

GDT separates *quality* from *reach*. A review score is computed against a hidden "True Score"
that is **relative to your own past games**, so standing still is a decline; **hype** accumulated
before release sets the initial sales spike (`h = H/500`, capped at 1); fans convert reviews into
a durable audience; and sales then **decay along a curve** rather than holding.
([GDT Wiki — Sales Algorithm](https://gamedevtycoon.fandom.com/wiki/Sales_Algorithm),
[Review Algorithm](https://gamedevtycoon.fandom.com/wiki/Review_Algorithm/1.4.4),
[Shapes — GDT mechanics](https://shapes.inc/fandom/game-dev-tycoon/game-mechanics))
*(The Fandom pages return HTTP 402 to automated fetches; the above is from search-surfaced
summaries of those pages, not a direct read — flagged rather than presented as a verbatim source.)*

**Why it is fun:** the release is an *event with a spike*, and the spike is earned before launch.
**Why it fails:** relative-to-your-own-past scoring makes late-game scores compress.
**Transfer — the critical one:** GDT's audience compounds (fans beget sales beget fans). **Ours
does not compound at all** (§3.C1).

### F · Event economies — **best: Software Inc.; anti-pattern well documented**

The "pay-or-suffer" card is the genre's known bad grammar: a choice whose only axis is cash
converts every event into a tax. Software Inc. instead ties event pressure to *state you manage*
(ticket volume scales with the number of buyers, so success itself generates the pressure).
**Transfer:** our live pool is nine cash deltas, **all outflows** (sprint §5.6), against $10K
opening cash — an autopilot taking the paid option every time went bankrupt on day 54.

### G · Costs that scale with success — **best: Startup Company**

Startup Company makes hosting a first-class managed system: server racks, and distinct
**database / cache / web** server types that must be configured and cooled as user load rises;
players describe the core tension as reaching maximum potential users *before* the servers can
carry them.
([Startup Company — server setup discussions](https://steamcommunity.com/app/606800/discussions/0/1777136225039070458/),
[Server Setup Help](https://steamcommunity.com/app/606800/discussions/0/1648791520853772629/))
Software Inc. adds the second half: **support headcount scales with buyers**, because the same
bug is reported by many customers.
**Why it is fun:** growth creates its own bill, so money keeps mattering (our Calibration Law 1).
**Why it fails:** if the bill is purely mechanical upkeep with no decision, it is a tax with extra
clicks — the tiers must be a *choice* (over-provision early vs. risk an outage).

### H · Axis differentiation — **best: Game Dev Tycoon**

GDT's Topic × Genre matrix makes some pairings "Great Combinations" with a significant score
multiplier, and each genre weights Design vs Tech differently — so the same effort produces
different results in different markets, and the weights are *shown*.
**Transfer:** we already have the data (`QUALITY_AXES`, per-sub-type weights, İnovasyon ×1.4 on
`ai_assistant` vs ×0.7 on `saas_billing`) and render it nowhere — and, per my verification, it
does not reach B2B satisfaction at all.

### I · Post-ship product life — **best: Software Inc.**

The product ages, the market moves, and you patch or you sequel; support and reputation are the
channels through which the world tells you the product is decaying. Recent builds separated
support-ticket simulation from support tasks and broadened reputation sources (licences, patents,
frameworks, publishers, awards).
([Software Inc. Steam news/patch notes](https://steamdb.info/app/362620/patchnotes/),
[coredumping.com](https://softwareinc.coredumping.com/))
**Transfer:** ours has the aging (hourly wear, rivals advancing daily) and none of the telling —
zero of seven post-ship events mention the product (consult W2).

---

## §3 · Proposals

One recommendation per problem. Unified mechanics are named as such.

### B2B

#### **B1 · The three-lever quality re-seat** — solves P7 · **DEMO-cheap, calibration-risky**
*Supersedes consult R1, which is under-scoped.*

Move three things together, then re-measure:
1. `QualityModel.NORMALIZE_HALF_SAT` 50 → **~25** (`quality_model.gd:46`).
2. `B2BConstants.TOLERANCE_BASE` / `TOLERANCE_PER_SCALE` re-seated so a played v1 lands at the
   **middle** of the tolerance spread, not under its floor.
3. **Research-lock placement** — `saas_ops` currently locks `field` (stability 7), one of only
   two high-stability features in the pool, which sets the demo's stability ceiling at 13.
   Spread locks across complexity bands so no pool has its dominant axis locked away.

**Why three:** `HALF_SAT = 25` alone yields 34.2 against a 35 floor and a 45 mid bar. Levers 2 and
3 do most of the work; lever 1 alone is a rounding error dressed as a fix.
**Reader:** `_satisfaction_target` (`b2b_sales_system.gd:96-106`) and every economic consumer.
**Verify:** `--run-log=b2b_solo:90:sim` and `b2b_slip:90:sim` — target is `b2b_slip`'s retention
count falling from 65 into single digits **without** `b2b_risk` becoming survivable.
**Precondition for everything else on B2B. Nothing after this is worth shipping before it.**

#### **B2 · The Contract object** — solves **P12 + P9 + P10 + P11** together · **DEMO-medium**
*The unifying noun. This is the most valuable single item in the report.*

A `Contract` bound to each B2B account, adopting the **already-reserved, currently-dead
`Customer.renewal_day`** (`customer.gd:88` — written and read by nobody; its own comment says
"next renewal event fires — next spec"):

| field | meaning |
|---|---|
| `signed_day`, `term_days = 365` | uniform annual (ruled) |
| `renewal_day` | `signed_day + term_days` — **the field already exists** |
| `seats`, `price_per_seat` | contract value = seats × price; **MRR becomes derived, not stored** |
| `discount_pct` | set by the player at signing/renewal only |
| `promises_this_term` | the cadence latch that kills P9 |
| `grievances: Array` | CK3-shaped named, decaying entries (see B3) |

**What it kills, structurally rather than by patch:**
- **P9 (weekly promises):** promise cadence becomes *per term*. One demand per contract year for
  mid/enterprise; **small accounts never demand features** (ruled) — bugs and price only.
- **P10 (uncapped discount):** the ad-hoc `İndirim ver` retention row is **retired**. Discount
  moves to signing and renewal as a *player* lever. Today's 628 in-run uses become ≤2.
- **P11 (pain write-once):** a delivered pain is *closed by the term*; the next term opens a new
  demand. FM's defect (promises that never clear) is designed out rather than inherited.
- **P12:** the lifecycle exists.

**The renewal moment, as a played decision** (FM's grammar, our clock): the renewal **window**
opens ~60 days before `renewal_day` (FM's 18-months-before-expiry, scaled to our year). The
customer states **how many seats they want next term** — up or down, driven by their satisfaction
and the account's NRR tier. The player sets **price per seat**. The trade is real in both
directions: lock a large seat count at a soft price, or hold price and risk the account walking.

**Tier behaviour from the SaaS benchmarks, not invented:** enterprise trends **NRR ~118%**
(seats grow), mid-market **~108%**, small **~97%** (slow shrink). Neglect is then
**tier-dependent by contract value** (ruled) for free — losing one enterprise contract costs more
than losing five small ones, because the value is in the contract, not the headcount.

**Churn is redefined, and this is the ruled order — churn first:** **churn = non-renewal at term
end.** Early termination exists but is **rare and expensive**, reserved for severe product
failure (sustained critical bug load / a broken promise on a flagship account). This single change
converts B2B loss from a 3-day countdown that fires forever into an **annual verdict the player
can see coming for 60 days** — Frostpunk's "pressure that resolves" instead of Software Inc.'s
overnight-ticket trap.

**Touches:** `customer.gd` (fields ride the generic property walker — see §6), `b2b_sales_system`,
`b2b_event_factory`, `b2b_constants`, `sales_system.add_b2b_customer`, `pitch_system` (B3).
**Breaks:** `mrr` becomes derived; every raw `set_mrr` caller must route through the contract.
**Reference:** Football Manager contracts; SaaS NRR benchmarks for the tier shapes.

#### **B3 · Pre-signing feature conditions** — ruled · **DEMO-cheap**
At pitch, a prospect may condition signing: *"add X within N days and we sign."* Reuses
`PromiseRegistry` **pre-contract** — the machinery already binds a named company to a real feature
id with a deadline (`promise_registry.gd:56-70`), and nothing in it requires a `Customer` to
exist; it needs the promise keyed to a prospect id that survives conversion at signing.
**Why it is good design and not just a ruling:** it makes the *product roadmap* a sales lever
before revenue exists, which is the one thing a pre-traction founder actually trades. It also
gives `pain_feature_id` a job at the only moment it is currently ignored.
**Reference:** FM's pre-signing promises during transfer negotiation.

#### **B4 · Per-account grievance ledger** — solves **P8 + P13 + P14** · **DEMO-medium**
Replace the single anonymous `trust_offset` float with a short **list of named, dated,
decaying entries** — CK3's shape, our decay primitive:

```
satisfaction_target = base(product) + Σ grievances + archetype_bias
```

- `base(product)` keeps Kararlılık as the largest coefficient (ruled), adds **Deneyim as a
  standing secondary term** (today it decays out in ~3 days), and — per the ruling — **İnovasyon
  moves to attraction, not retention**: it feeds prospect discovery rate and prospect quality in
  `PitchSystem`, where enterprise leads notice an innovative product but stability still decides
  whether they stay. That is P14 solved without making İnovasyon a fourth retention knob.
- `archetype_bias` finally reads the **already-written, already-dead `Customer.warning_flags`**
  (`"slow_payer" | "picky" | "kompromat_opportunity"` — written at `sales_system.gd:311`, read by
  **nobody**). "Picky" is a tolerance bias waiting for a reader.
- Grievances are **player-readable**: "Söz tutulmadı (−12, 18 gün kaldı)". This is what makes ten
  accounts feel like ten companies without ten times the systems (P8), and what turns the
  retention modal from a timer into a person (P13).

**Scaling note:** grievances are bounded (cap ~5/account, oldest evicted) so the per-account cost
stays O(1) — see §6.

#### **B5 · Retention becomes a window, not a drip** — solves P13 · **DEMO-cheap**
With B2 in place the every-3-days modal is structurally gone; what remains is a per-account
**cooldown (10–14 days)** and escalating copy that names the real cause ("bu hesabı tutan şey
ürünün kararlılığı, indirim değil"). After the cap the account slides to its renewal verdict
without further modals. *(This is consult R5, which I endorse unchanged — but note it is a
symptom cap; B1 and B2 are the cure.)*

#### **B6 · One B2B product event family** — solves P15 · **DEMO-medium**
`ev_ps_bug_complaint` is `market_type: b2c`-gated, so a B2B product can decay without limit and
the pool never says a word (consult W2/A.6). Add the B2B mirror, spoken by a **named account**
about a **named feature**, gated on `product_bug_risk` — the one thing no other game in the genre
has (consult §"unclaimed ground").

### B2C

#### **C1 · Give the audience a compounding term** — solves **P1** · **DEMO-medium**
*This is the B2C rebuild, and it is one formula.*

Measured today (`sales_system.gd:160-175`):
```
grow/hour  = (0.08 + q·0.006 + brand·0.004 + rep·0.01) × price_mult     ← ABSOLUTE
churn/hour = 0.0002 · max(0, 42 − q) · audience                          ← PROPORTIONAL
```
Growth is a constant trickle; churn scales with what you have. The audience therefore has a hard
equilibrium at `A_eq = grow / (0.0002·(42 − q))` and **cannot compound**. Worse, `q` is
rival-relative (`_rival_relative_quality:184-196`) and startup rivals advance daily, so `A_eq`
*shrinks* over a run.

**Measured consequence** (`--run-log=b2c:180:sim`):

| day | 1 | 15 | 30 | 60 | 90 | 120 | 150 | 179 |
|---|---|---|---|---|---|---|---|---|
| MRR | 975 | 2,040 | **3,510** | 3,945 | 2,190 | 1,440 | 1,005 | 1,245 |
| brand | 50 | 57 | 67 | 84 | 98 | 100 | 100 | 100 |

**MRR peaks around day 45–60 and decays by two-thirds while brand maxes out.** No lever the
player holds can bend this, because the only lever is price and the problem is shape.

**Do:** add a **word-of-mouth term proportional to audience and gated on satisfaction**, so a
loved product compounds and a disliked one does not:
```
grow/hour += audience · WOM_COEF · max(0, satisfaction − WOM_GATE)/100
```
with `WOM_COEF` small enough that the compounding is visible over weeks, not hours, and the
existing proportional churn remains the counterweight. This is GDT's fans-beget-sales loop and
the reason its release curve feels alive.
**Verify:** `--run-log=b2c:180:sim` — the target is MRR **monotonically rising** through day 180
for a maintained product, and still decaying for a neglected one.

#### **C2 · Decision → outcome event grammar** — solves **P2 + P3** · **DEMO-medium**
Ruled, and the research supports it. Today: one card, click, `+audience`. Proposed, in two beats:
1. **Decision:** *Product Hunt'a çık / çıkma.* Joining costs cash and a build-week of attention;
   not joining costs nothing. **No outcome is stated.**
2. **Outcome (separate modal, 1–3 days later):** driven by **product state**, not by the click —
   quality, bug load, Deneyim. "Beğendiler" → a real audience spike. "İlgilenmediler" → the cash
   is spent and nothing arrives.

**Why this is the important half of the ruling:** it converts events from a tax into a *bet on
your own product*, which is the only thing that makes an event feel like a founder's decision.
It is also GDT's hype→release grammar with our clock.

**Trigger realism (P3):** the four ambients today re-arm at their cooldown floor forever
(measured: producthunt 16×, power_user 13×, bug_complaint 9× in 180 days). Gate them on **phase +
one-shot-per-milestone** instead of a cooldown: Product Hunt is an *early-phase* beat that stops
being offered once MRR is serious. "You cannot join Product Hunt weekly" (ruled) becomes a
trigger property, not a tuning value.

#### **C3 · Cost types must match what they represent** — solves P2 · **DEMO-cheap**
A bug complaint costs **users/MRR (churn)**, not −$1,500 cash (ruled). Refunds barely exist in
consumer SaaS. The modifier vocabulary already has the right verbs (`churn_customer`,
`convert_audience`, `audience`) — this is a re-authoring of the pool against the correct cost
type, then a recalibration of amounts. Do the type first; the numbers are meaningless until the
kind is right.

#### **C4 · Bugs must hit sales, not only satisfaction** — solves P4 (partly) · **DEMO-cheap**
Today bugs reach the economy only through `effective_stability` → the composite → audience.
Add live bugs as a term in **`conversion_rate`** (`sales_system.gd:455`), so a buggy product
converts worse as well as growing slower. Software Inc.'s grammar: buyers generate the complaints
that suppress buying.
**Reader:** `_derive_b2c_mrr:201-209`. **Player-visible:** the pricing ruler's live projection
already renders conversion — it will move.

#### **C5 · Operations: costs that scale with success** — solves **P5** · **DEMO-medium**
Ruled, and the rail already reserves an **Ops tab slot** (`UiTokens.TABS`, index 4).
Three sinks, all seamless, all reading the burn-category seam that already exists
(`FinanceSystem.set_burn_category`, `burn_breakdown`):
- **Servers with capacity tiers** — a decision, not a tax: over-provision early (waste cash) or
  run hot (risk an outage event that costs users). Startup Company's rack grammar, one dimension
  instead of three.
- **Support headcount** scaling with users (Software Inc.: tickets scale with buyers).
- **Marketing spend** — the `marketing` burn category is already declared and 0 with a TODO
  (`finance_system.gd:38`).
- **Some features carry recurring infra/API cost** (ruled): the catalog **already has
  `cost_source: "api"` on exactly the right rows** (`ai_assistant_voice` $800, `ai_assistant_image`
  $1200) — today charged once at commit. Making a subset recurring is a field-semantics change,
  not a new system.
**Why:** without this, B2C runway reads `INF` from day 11 and cash rises forever (consult Lens C,
Law 1 fail).

#### **C6 · Revenue-generating moments** — ruled · **DEMO-cheap**
The live pool has **no positive cash and no positive audience event that is earned**. Add the
launch burst (ship → a real spike sized by product quality), the "N new users arrived" milestone
reaction, and milestone beats. These are C2's *outcome* modals — not a separate system.

### Shared

#### **S1 · The report card** — P16 · **DEMO-cheap** — consult R2, endorsed unchanged
`mvp_innovation_prev` / `_stability_prev` / `_experience_prev` are stamped at every launch
(`product_system.gd:908-910`) with a comment naming the intended reader, and have **zero
readers**. Render the delta. Highest value per line in either document.

#### **S2 · The v2 picker context header** — P16 · **DEMO-medium** — consult R3, endorsed
With B2 in place it gets stronger: the picker shows *which contract* wants the feature and *how
many days until that contract's renewal*.

#### **S3 · Ceiling label, Turkish feature names, `bet` on the type card** — P16 · **DEMO-cheap**
Consult R4/R7/R8/R10-partial, endorsed. No re-proposal.

#### **S4 · Pin the smoke seed** — P17 · **DEMO-cheap**
`EndgameSmoke.run_case` never pins `run_seed`, so any ambient-touching case is a coin flip
(sprint §5.7; one case failed 4 in 12). One line.

---

## §4 · Run structure & pacing

**Ruled:** goal-terminated, not calendar-terminated. Endings — Series A · Profitable &
self-sustaining · bankruptcy · **soft cap ~24 months** as a narrative non-win. Ladder becomes
**1× / 2× / 3×** (4× removed).

### The clock arithmetic

`TimeManager.SECONDS_PER_DAY = [0.0, 12.0, 6.0, 3.0, 1.5]` (`time_manager.gd:43`). Removing 4×
leaves **1× = 12 s/day · 2× = 6 s/day · 3× = 3 s/day**. Pure clock time for a run of N days is
`N/5` minutes at 1×, `N/10` at 2×, `N/20` at 3×.

| horizon | 1× | 2× | 3× |
|---|---|---|---|
| 12 months (365 d) | 73 min | 36 min | **18 min** |
| 14 months (425 d) | 85 min | 43 min | 21 min |
| 18 months (548 d) | 110 min | 55 min | 27 min |
| 24 months (730 d) | 146 min | 73 min | **37 min** |

### The finding that matters

**Run length alone cannot hit CLAUDE.md's 60–90 minute demo target**, because the same run is
18 or 73 minutes depending purely on which speed the player holds. The variable that actually
sets session length is **decision density**, because every decision pauses the clock.

Modelling a decision at ~15 s of real reading/choosing time, at the ruled **2–3 per in-game
week**, calibrated against **3×** (ruled):

| target | in-game weeks | decisions @2.5/wk | decision time | + 3× clock | **session** |
|---|---|---|---|---|---|
| Series A @ 12 mo | 52 | 130 | 33 min | 18 min | **51 min** |
| Series A @ 14 mo | 61 | 152 | 38 min | 21 min | **59 min** |
| Series A @ 16 mo | 70 | 174 | 44 min | 24 min | **68 min** |
| Profitability @ 18 mo | 78 | 196 | 49 min | 27 min | **76 min** |
| Soft cap @ 24 mo | 104 | 260 | 65 min | 37 min | **102 min** |

### Proposed numbers

- **Series A reachable at month 12 for a strong run; typical competent run months 14–16.**
  That is the band that lands the demo in the 60–90 minute box at 3×, and it is plausible
  founder-time (a seed-stage company raising an A 14 months after first revenue).
- **Profitable & self-sustaining at months 18–20** — deliberately *later* than Series A, because
  bootstrapping to profit should be the slower, harder road (and it is the hard-mode REDDET
  path's target).
- **Soft cap at 24 months.** With uniform annual contracts this is the minimum cap at which the
  renewal system is genuinely *seen*: an account signed in month 3 renews in month 15 and again
  at 27 — so a 24-month cap shows **one renewal per account, two for early signings**. A cap of
  18 months would leave the whole contract lifecycle unexercised in the demo; 24 is the smallest
  number that pays for the feature.
- **Decision budget: 2.5/in-game-week**, the midpoint of the ruling, as the tuning target.

### What must change for the bar to sit there

**Measured today:** in the played B2B run, MRR first crossed the Series A bar of $5,000 on
**day 77 ≈ month 2.5** (`--run-log=full_run:180:4`). That is **~5.5× too early** for a month-14
target.

**My recommendation: raise the bar, do not slow the curve.** Reaching $5K MRR in ten weeks is
plausible founder-time and it *feels* good; the defect is that $5K MRR is an absurdly low Series A
bar (real Series A rounds sit orders of magnitude above it). Slowing the revenue curve to stretch
2.5 months into 14 would make the early game feel dead — which is exactly the Calibration Law 2
failure the consult already found in GELİŞTİRME. Raising the bar keeps the early climb brisk and
puts the work in the middle game, where B2's contract renewals and C5's scaling costs now live.

**Caveat, stated rather than papered over:** `EndingsSystem.RUN_END_DAY = 180` hard-stops every
run today, so the 24-month structure **cannot be measured end-to-end** with the current engine.
The month-14 and month-18 figures above are extrapolations from a measured slope, not
measurements. The first implementation step should be to lift the wall and re-measure.

---

## §5 · Revision plan

Ordered so each step is playable and testable. Each names its preset and the number that must move.

### Demo cut

| # | Step | Preset | Number that must move |
|---|---|---|---|
| **1** | **B1** three-lever quality re-seat | `b2b_slip:90:sim` / `b2b_solo:90:sim` | retention fires **65 → <10**, `b2b_risk` still fails |
| **2** | Lift `RUN_END_DAY`; goal-terminated run + soft cap | `full_run:730:sim` | run reaches a **goal ending**, not a calendar wall |
| **3** | **B2** Contract object (+ renewal window, seats/price, discount moved) | `full_run:730:sim` | discount uses **628 → ≤2/account**; ≥1 renewal observed |
| **4** | **C1** compounding audience term | `b2c:180:sim` | MRR **monotonic to day 180** (today: peaks d60, −68%) |
| **5** | **B4** grievance ledger + archetype bias (reads `warning_flags`) | `b2b_solo:90:sim` | per-account satisfaction **spread > 0** (today: all converge to one number) |
| **6** | **C2 + C3 + C6** event grammar, cost types, revenue moments | `b2c:180:sim` | fires/week → **2–3**; ≥1 positive-cash/audience outcome |
| **7** | **C5** Ops costs (servers/support/marketing/recurring API) | `b2c:180:sim` | runway **finite** past day 11 |
| **8** | **B3** pre-signing conditions · **B5** retention window · **B6** B2B product event | `full_run:730:sim` | ≥1 conditioned signing; retention ≤1/account/fortnight |
| **9** | **S1 · S3 · S4** report card, labels, seed pin | screenshots + suite | suite deterministic across 12 repeats |

**Steps 1 and 2 are prerequisites for everything.** Step 4 is independent of 1–3 and can run in
parallel by a second pair of hands.

### Honestly EA

- **C5 at full depth** (three server types, cooling, outage events) — one capacity dimension in
  the demo, Startup Company's full rack in EA.
- **B4 at full depth** (relationship arcs, references, competitive displacement).
- Multi-product, R&D unlock ledger, `stakes` as the reputation-damage multiplier (consult R10).
- **Thousands of accounts.** The demo needs tens; §6 reserves the shape so EA does not rewrite.

---

## §6 · Data shapes to reserve now

Cheap only if decided before the demo ships.

1. **`Customer` fields ride the generic property walker.** `SaveCodec.res_to_dict` (`:91-103`)
   walks `get_property_list()` for `STORAGE|SCRIPT_VARIABLE`, so **any new `@export var` on
   `Customer` round-trips automatically** — no schema work for B2's contract fields. Two hazards:
   JSON re-types every number to float on load, and `Array[String]` typed arrays need explicit
   coercion on the way back.
2. **Adopt `renewal_day`, do not invent a field.** It already exists (`customer.gd:88`) with zero
   readers and a comment reserving it for exactly this spec.
3. **Reserve the contract as a nested Resource now**, even if the demo only fills three fields —
   `res_to_dict` recurses through nested Resources already (the `GameEvent.choices` precedent),
   so a `Contract` sub-resource costs nothing today and avoids a migration later.
4. **Grievances: bounded list, oldest-evicted, cap ~5.** Reserve the array now. Unbounded
   per-account history is the one shape that will not scale to thousands of accounts.
5. **`warning_flags` already exists and is dead** — use it as the archetype-bias channel rather
   than adding a parallel field.
6. **Flag namespaces** in `GameState.FLAG_TYPES` before the demo ships (the typing block at
   `:60-121` warns why): `ops_server_tier`, `ops_support_headcount`, `rnd_unlocked_<feature_id>`
   (consult §7), `b2c_wom_*`.
7. **Indexing.** `CustomerRegistry` stores a `Dictionary id→Customer` and **every query is a full
   scan** (`get_all`, `get_by_market` and six siblings all `for c in _customers.values()`).
   That is fine at tens and quadratic-ish in aggregate at thousands once per-tick and per-refresh
   callers stack. Reserve a **market-keyed index** maintained by the existing `add`/`remove`
   seams — cheap now, invasive later.
8. **MRR becomes derived** (`seats × price_per_seat × (1 − discount)`). Reserve that direction
   now, because every current raw `set_mrr` caller becomes a contract mutation, and the
   `SalesSystem.reflect_mrr()` bridge is the single place that must keep its contract.

---

## §7 · Open questions

Only where a design call genuinely cannot be inferred.

1. **Where does the Series A bar land after §4's "raise the bar" recommendation?** I can propose
   the *month*; the *number* depends on whether the game keeps 1:1 real dollars at Series A scale
   (real A rounds imply ~$1–2M ARR, which breaks the solo-founder fantasy) or accepts a
   deliberately compressed scale. This is a fiction-vs-realism call, not an engineering one.
2. **Does the profitability ending require sustained profit or a single crossing?** "Profitable &
   self-sustaining" could be N consecutive profitable months (the `net_history_90` ring buffer
   already exists) or a threshold crossing. The former is better design; the latter is what the
   engine currently supports.
3. **Should an outage (C5) be able to *end* a run?** Servers that can fail are only a real
   decision if under-provisioning can genuinely cost you — but a consumer-facing hard loss late
   in a 24-month run may be too punishing for the demo.

---

*Read-only research. No source, fixture, baseline, screenshot-harness or git state was changed.
Measurements are reproducible with the `--run-log` commands quoted inline (seed pinned 424242).
Genre claims are cited; where a source could not be fetched directly it is labelled as such.*
