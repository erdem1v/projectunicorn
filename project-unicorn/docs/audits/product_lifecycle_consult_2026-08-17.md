# Product Lifecycle — Consulting Review

**Date:** 2026-08-17 · **Type:** Consulting review (read-only; no source, fixture, baseline or git change)
**Scope:** create → build → ship → iterate → v2/v3 → post-ship life
**Anchor:** working tree at `a683ab1` (branch `terminal-ui-reskin`), snapshot 11:02 TSS. See *Evidence and its limits* for the live-tree caveat.

---

## Executive verdict

The product loop is **well-built and badly wired to the player**: the creation flow is the best decision surface in the game, the build phases carry real trade-offs, and post-ship the engine already does everything the director wants it to do — pressure accumulates, a version genuinely silences it, and the world reacts. The failure is not that post-ship is dead; it is that **post-ship is mute and mis-calibrated**: no event in the game ever points at the product, so the only way to learn any of it is to voluntarily open a tab, and the one number the whole post-ship economy reads (Kararlılık, through a saturation curve tuned for a retired quality model) lands so low on a genuinely-played product that every B2B account is born below its tolerance and enters a retention modal loop that re-fires every three days forever. The three axes are not three axes: **Kararlılık is the game, İnovasyon and Deneyim are one fungible bucket that only B2C reads**, and Deneyim's only B2B contribution is erased by the satisfaction drift in about three days. The strongest evidence that the design is right and only the communication is missing is a controlled pair of 90-day runs that differ in nothing but whether the founder built what he promised: **65 retention modals versus 1**, no expansions versus all five, no Series A versus Series A.

**The one thing I would change first:** re-scale `QualityModel.NORMALIZE_HALF_SAT` (and the B2B tolerance band with it) so a played v1 lands inside the tolerance window instead of under it. It is one constant the code already flags as wrong, and until it moves, every other improvement to this loop is decoration on a product the world is contractually obliged to hate.

---

## Evidence and its limits

| Lens | Instrument | Coverage |
|---|---|---|
| A — engine | Code trace, every claim anchored `file.gd:line` against the 11:02 snapshot | Complete |
| B — player | **Hand-driven** windowed run (OS-level clicks), creation → build → ship → pricing, plus **bridge-driven** `--run-log` probes ×6 at 90 days, plus 4 in-engine `--product-shot` frames read | Creation→ship played; v2 picker **not clicked** (see below) |
| C — director | Calibration Laws + reference games | Complete |

**Three honest limits.**

1. **The v2/v3 picker was never clicked.** I reached its entry point (the "v2'yi geliştir" card on the live product page) in the played run and read its code path in full, but the hand-driven lane was stopped before I opened it. Everything I say about the v2 picker's *contents* is a code claim (`creation_flow.gd:102-108, 735-789, 808-816`), not an observed frame. The v2 **arc** — build, ship, and its effect on the world — *was* played, by the bridge (`b2b_slip_keep`, `b2b_risk_keep`).
2. **The hand-driven lane was stopped early, for two reasons.** A parallel session launched its own windowed Godot instances, which stole foreground from mine; my screen-capture then photographed a non-game window belonging to the user (deleted immediately, unread beyond recognising it was not the game). That method is unsafe on a shared desktop and I abandoned it rather than retry. The same collision rotated away my run's Godot log, so the mid-run death of my first instance is undiagnosable.
3. **The tree moved under this audit.** `b2b_sales_system.gd` (10:50), `b2b_event_factory.gd` (10:49), `main.gd` (10:55) and `run_probe.gd` (10:46) were written minutes before the snapshot by the Playable Run Sprint, whose own plan records "**B2B axes deadness** — Recorded, not this sprint — design-session material." This report is that design session. The two anchors this report leans on hardest were **re-verified after the trace and still hold**: `_satisfaction_target` at `b2b_sales_system.gd:96-106` and `_maybe_enqueue_retention` at `:194`. Other anchors in those four files should be re-checked before acting on them; the product engine itself (`product_system.gd`, `quality_model.gd`, `product_catalog.gd`, `sales_system.gd`, all product tab views) has been stable since 07-08 Aug and is safe to quote.

Probe commands (seed pinned at 424242, reproducible line-for-line):

```
--run-log=b2c:90:sim   --run-log=b2b_solo:90:sim
--run-log=b2b_slip:90:sim   --run-log=b2b_slip_keep:90:sim
--run-log=b2b_risk:90:sim   --run-log=b2b_risk_keep:90:sim
--product-shot=detail_b2c|detail_b2b|portfoy|beta
```

---

# Lens A — the lifecycle map

## A.1 The decision points, in play order

| # | Decision | Seam | What it writes | Reversible? |
|---|---|---|---|---|
| 1 | B2C vs B2B path | UI only, resolved by type pick | — | **No** (screen says so) |
| 2 | Sub-product type | `start_build` → `GameState.set_subgenre` (`product_system.gd:991-993`) | `mvp_sub_product_type_id`, `mvp_market_type`, subgenre | No |
| 3 | Feature set | `start_build` (`:961`) | `feature_ids`, axes via `projected_axes`, `bug_count` via `_seed_feature_bugs`, one-time cash | No |
| 4 | Product name | `start_build` arg | `mvp_product_name` | No |
| 5 | **Sorumlu** (build lead) | `assigned_engineer_id`/`lead_engineer_id` (`:1001-1002`) | speed via `_lead_coordination`, quality via `_team_expertise_avg` | No (never re-written) |
| 6 | **Design round: one more, or go** | `advance_iteration` / `enter_development` (`:576`, `:592`) | `iteration_count`, axis growth toward team ceilings | Ratchet |
| 7 | Build events ×9 | `apply_dimension_delta` / `apply_bug_delta` / `apply_speed_bonus` | axes, bugs, total_efor | No |
| 8 | **Ship** (Beta → Yayınla) | `launch()` (`:884`) | the whole `mvp_*` block | No |
| 9 | Price (B2C only) | `apply_b2c_price` (`sales_system.gd:498`) | `b2c_price`, audience hike reaction | Yes |
| 10 | Bug sprint | `start_bug_sprint` (`:758`) | live bug count, capacity demand | — |
| 11 | **v2/v3 feature set** | `start_version_build` (`:1040`) | union features, seeded axes, inherited + new bugs | No |
| 12 | Cancel build | `cancel_build` (`:1137`) | discards; prefill preserved | — |

Decisions 6 and 11 are the two the director's frame is about. Decision 5 (**Sorumlu**) is the quietest real decision in the game — it sets both build speed and product quality, and is never surfaced again after commit.

## A.2 The write → reader → surface table

This is the core Lens A deliverable. "Surface" means: can the player ever see the consequence?

### Live and surfaced

| State | Written by | Read by | Player sees it |
|---|---|---|---|
| `mvp_stability` | `launch():915` | `effective_stability` → `economy_dims_from_flags` → **everything** | Yes — radar, "ETKİN KARARLILIK 9/14", health dot |
| `mvp_innovation` / `mvp_experience` | `launch():914,916` | `composite_quality` weights only (+ display) | Yes as a number; **no**, as a consequence |
| `mvp_live_bug_count` | wear/sprint/launch | `effective_stability`, `health_state`, `product_bug_risk`, VC sorgu, satisfaction ticks | Yes — "6 BUG · ARTIYOR" pill |
| `mvp_components` | `ship_active_build():1208` | `_shipped_total_complexity` (wear), `product_value`, promise ship-coupling, `pick_pain_feature` | Indirectly |
| `mvp_version` / `mvp_version_history` | `launch():924`, `:1205` | `_versions_line`, `hr_morale_system:330`, run ledger | Yes — "SÜRÜMLER v1 · Oca 2026 · CANLI → v2 · planlanmadı" |
| `b2c_audience` | hourly tick | `_derive_b2c_mrr`, wear | Yes — "DENEYEN 108" |
| Promises | `PromiseRegistry.create` | `_promise_offset` → satisfaction target; ship-coupling → kept | Yes — "SÖZ VERİLDİ Ege Sigorta · sistem entegrasyonu · 12 gün" |

### Written and never read — the dead list

| State / field | Written | Readers | Note |
|---|---|---|---|
| **`pull` (1-5)** | every feature row in `product_catalog.gd` | **none** | Documented as "audience draw". Nothing draws. |
| **`stakes` (1-5)** | every feature row | **none** | Documented as "reputation damage multiplier if this area breaks". Nothing breaks. |
| **`bet`** | every sub-type | **none** | The founder-voice market bet. The catalog header claims it is "shown as the type card's two lines"; the card renders `desc_tr` + `plus_minus_tr` instead. |
| **`pitch`** | every sub-type | **none** | |
| **`mvp_innovation_prev` / `_stability_prev` / `_experience_prev`** | `launch():908-910` | **none** | The write's own comment: *"so the detail view can show a version-over-version delta"*. The detail view has no such reader. **This is the director's report card, already stamped at exactly the right moment, and never displayed.** |
| **`bug_count_at_bugfix_start_<id>`** | `_tick_build_hourly:523` | **none** | Comment: *"so the tracker can read 'started with M, shipped with N'"*. No tracker reads it. |
| `strengthened_feature_ids` | `start_version_build:1095` | `creation_flow.gd:98` only (re-checking rows in the locked view) | A version's "we deepened X" is not recorded anywhere the player can read afterwards. |

Four catalog fields and four state writes with zero readers. Two of them are precisely the primitives the "report card" proposal needs.

### Read but not surfaced

- **Per-sub-type axis weights** (`QUALITY_AXES`, `product_catalog.gd:200-253`). İnovasyon is worth **2× Kararlılık** on `ai_assistant` (1.4 vs 0.7) and **0.44×** on `saas_billing` (0.7 vs 1.6). `get_quality_axes` returns `weight` alongside `display_label`; every consumer uses the label and **nobody renders the weight**. The player cannot learn which axis their market pays for, ever.
- **`iteration_axis_ceilings()`** is rendered, but as a bare "tavan" (see A.4).

## A.3 The axes read-map (the Step 0c substitute)

**İnovasyon** — mechanical readers:
1. `composite_quality` weight → `shipped_normalized` → `_audience_delta_per_hour` (B2C audience) and `product_value` (B2C price/conversion). `sales_system.gd:161, 402`.
2. `_rival_relative_quality` benchmark — same composite. `:184`.
3. `VCPitchSystem._weakest_dimension():736` → **one flavour line** in a VC interrogation, and it is shadowed: `_sorgu_product():663` returns the bug line first whenever `mvp_live_bug_count > 0`, which is nearly always.

**There is no B2B mechanical reader of İnovasyon anywhere in the codebase.**

**Kararlılık** — readers: `effective_stability` (`quality_model.gd:101`) feeds `economy_dims_from_flags`, therefore *every* economic consumer; **plus** it is the sole term of `B2BSalesSystem._satisfaction_target` (`b2b_sales_system.gd:96-106`), the B2C satisfaction gate (`sales_system.gd:358`), half the B2B signing seed, `health_state`, `product_bug_risk`, and the VC bug sorgu. It is the axis.

**Deneyim** — readers:
1. `composite_quality` weight → same B2C channel as İnovasyon.
2. `_ensure_b2c_record():217` — seeds the B2C aggregate customer's satisfaction, **once**, at first record creation.
3. `PitchSystem.signing_satisfaction_seed():326` — **half** of a B2B account's satisfaction *at signing*.

### The falsification (Calibration Law 4: "could a playtester who ignored this axis still win?")

- **İnovasyon — YES, trivially.** On B2B it has zero mechanical effect. On B2C it enters only through the weighted composite, where it is **perfectly substitutable** with Deneyim: for `ai_assistant`, +1 İnovasyon = +1.08 Deneyim. Ignoring it costs nothing a Deneyim pick cannot replace.
- **Deneyim — YES.** Same fungibility on B2C. On B2B its only effect is the signing seed, and that effect has a **half-life of about three days**: satisfaction is seeded at `(stab_score + exp_score)/2` and then drifts toward a target of `stab_score` alone at `SAT_DRIFT_STEP` 3/day, amplified ×1.5 during onboarding. A 10-point Deneyim advantage at signing is fully erased by day 3.
- **Kararlılık — NO.** Everything reads it.

**Conclusion: the game does not have three axes. It has one axis (Kararlılık) and a two-slot fungible bucket that only the B2C branch reads.** The player is asked to make a three-way trade-off that the engine collapses into one-and-a-half.

## A.4 The ceiling label (S2-3, reproduced live twice)

`iteration_axis_ceilings()` bounds **only** iteration-round gains (`_apply_iteration_round_gains:618`, via `QualityModel.grow`). The commit stamp, event `dimension_delta`, the PM bonus, the strengthen bonus and v2 inheritance all sit outside it **by design** and the engine documents this. The defect is the display. Observed in the played run: the *teaching* modal — the one moment the game explains the mechanic — printed

> "İnovasyon 10 / tur kazancı tavanı 8 — tavanı tur sayısı değil, masadaki ekip belirler."

and four in-game days later the tracker read **İnovasyon 15 / 8 · Deneyim 13 / 8**. The `--product-shot=beta` frame shows **Kararlılık 10 / 8** on the same card. The first thing a player learns about product quality is a rule the screen is simultaneously violating.

## A.5 Beta has no decision

`_tick_beta_hourly:641` finds hidden bugs at `BETA_BUG_FIND_PER_DAY` 6/day and fixes them at `POLISH_BUG_FIX_PER_DAY` 4/day, both automatic. The only action in Beta is "Yayınla", and the build **parks indefinitely** at 100% with no auto-ship. So waiting is strictly dominant and free apart from burn: wait long enough and bugs reach zero. In the played run I deliberately took the two "ship it rough" branches (`HATA +3`, `HATA +2`) and still shipped with **0 bugs**.

The archetypal startup decision that `PROJECT_SPEC §5.1` calls "**THE** archetypal startup decision" — ship now vs polish — is therefore not in the game. It exists as a spec paragraph and as an event (`ev_mvp_bugfix_002_early_launch_pressure`), but the phase structure removes its teeth.

## A.6 The post-ship event pool, counted

| Pool | Files | Of which repeatable |
|---|---|---|
| Build-phase (`ev_mvp_*`) | 9 | 0 |
| Post-ship (`ev_ps_*`) | **7** | 3 |
| — of those, B2B | **2** | 1 (`referral_b2b`) |

`ev_ps_bug_complaint` — the only "your product is bad" event in the game — is gated `market_type: b2c`. **A B2B product can decay without limit and the event pool never says a word about it.** Everything a B2B founder hears post-ship comes from the B2B factory, and it talks about *accounts*, never about the *product*.

Not one of the seven post-ship events mentions a version, a rival shipping, or an axis.

---

# Lens B — shadow playthrough log

**Run 1 — hand-driven, B2C**, `--skip-onboarding --audit-play`, OS-level clicks, 1920×1080 client. Verbatim entries.

**Day 1 · Frank's intro.** *Chose:* dismiss. *Expected:* to be pointed at a goal. *Saw:* "Product sekmesine geç, neye oynayacağını seç." *Felt:* oriented — and then immediately confused, because the tab he named reads **"Product"** in English while he speaks Turkish, and the board behind him says "To Traction: Ship + first customer + first revenue" while the monitor says "Awaiting development / ALL QUIET." The mentor is the only Turkish thing on screen. (Also: naming a UI tab in fiction is what the Event Authoring Law in `CLAUDE.md` forbids.)

**Day 1 · Portfolio.** *Saw:* "0 ürün", one button, and "KİLİTLİ · Series A sonrası". *Felt:* good — the locked second slot is an honest coming-soon telegraph. 95% of the screen is empty, which for a Football-Manager-density target is a missed first impression.

**Day 1 · 01 YOL (B2C vs B2B).** *Chose:* B2C. *Expected:* a flavour choice. *Saw:* two cards with genuinely different consequences ("Kitle kendiliğinden büyür / Kullanıcı başına küçük gelir / Kaprisli" vs "Kontrat başına yüksek gelir / Satışı sen yaparsın / Müşteri tutmak iş ister"), Frank underneath, and the line "Sonradan değişmez." *Felt:* **this is the best decision screen in the game.** I knew what I was choosing, why it mattered, and that I couldn't take it back.

**Day 1 · 02 TİP.** *Chose:* Yapay Zeka Asistanı. *Saw:* three cards, each with a category, a one-liner, sector chips and an honest downside. *Felt:* confident. *Note:* the B2C side offers **3** types against B2B's **7**, and the founder-voice `bet` line written for every type ("Refik'in üşendiği nişi kap") is not on the card — the flattest of the four available strings is.

**Day 1 · 03 ÖZELLİKLER — the first real friction.** *Chose:* Chat Interface, Conversation Memory, Voice Mode. *Expected:* to pick features. *Saw:* feature rows headed **"Conversation Memory"**, **"Tool Use"**, **"Voice Mode"** — English names on an otherwise entirely Turkish screen — each with an excellent dense info line ("Efor 7 · İnovasyon +5 · Kararlılık +3 · Hata riski: Orta"), grouped under **İNOVASYON · 0/4** and **DENEYİM · 0/2**. *Felt:* two things at once. The information density is genuinely FM-grade and I respect it. But **there was no KARARLILIK group at all** — no feature in this product type has stability as its dominant axis — and nothing told me why a whole category was missing, or that on *this* product type İnovasyon is worth double Kararlılık. And when the preview said "İnovasyon +10", I had no idea whether 10 was good. There is no rival bar, no market average, no referent of any kind. **Picking three features felt like allocating points on an unlabelled scale, and I chose by reading the prose, not the numbers.**

**Day 1 · Commit.** *Saw:* "Toplam efor 20 · Maliyet $800 · Süre ~10 gün", "Bittiğinde kasada $8.700 kalır", and a SORUMLU dropdown reading "Founder". *Felt:* the cash projection is excellent and I trusted it. I did not understand that the dropdown I skipped past was setting both my build speed and my product's quality.

**Day 3 · Tasarım masasında karar.** *Chose:* one more round. *Expected:* a clear price/benefit. *Saw:* "İnovasyon 10 / tur kazancı tavanı 8 — tavanı tur sayısı değil, masadaki ekip belirler." *Felt:* **taught a rule and shown it broken in the same sentence.** I concluded either the ceiling was fake or the number was. I clicked "Bir tur daha" essentially at random, and I could not tell you what it bought me.

**Days 3-7 · Three build events.** *Chose:* take the feedback (DENEYİM +6 / +2 GÜN / NAKİT −$100); bend toward the rival's gap (İNOVASYON +5 / +2 GÜN); trim scope (−1 GÜN / HATA +3). *Felt:* **the best minute-to-minute writing in the loop.** Real trade-offs, effects on visible badges, and one of them named a rival — *Meridyen* — by name. This is the Software Inc. cadence with a Disco voice on top, and it works.

**Day 7 · Into development.** Tracker now reads **İnovasyon 15 / 8 · Kararlılık 4 / 8 · Deneyim 13 / 8**. *Felt:* the ceiling label is now actively misleading me.

**Days 10-20 · GELİŞTİRME.** *Felt:* **this is the dead stretch.** The screen is the feature list I already chose, greyed out, plus a progress bar. Two events in ten in-game days. Nothing to decide, nothing to read, nothing changing except a percentage. Calibration Law 2's "no 60-90 seconds without a meaningful decision" is not met here.

**Day 34 · The live product page.** *Saw:* a genuinely good screen — radar, "0 BUG · SABİT", "V1 · 10 GÜN CANLI", TRACTION'A DOĞRU with MRR $570/$5.000, a pricing ruler with optimal marked and live paying-user projection, "SÜRÜMLER v1 · Oca 2026 · CANLI → v2 · planlanmadı", two action cards, a red strip reading "**pazar payı <%0,1 · Echo Desk %0,5 · Echo Desk seni geçti**", and Frank: "Zayıf yanın İnovasyon · v2'te onu güçlendir, Echo Desk'i yakala."

*Felt:* **relief, then irritation.** Relief because everything the director says is missing is on this page: the world moved, a named rival passed me, and the mentor told me exactly what to do about it. Irritation because **I only saw it by accident.** Between shipping and that moment the game sent me nothing — no event, no notification, no badge. Frank told me to go to Sales after shipping; had I obeyed him, Echo Desk would have passed me and I would never have known. The information exists; the summons does not.

Two smaller notes: shipping with 0 bugs after deliberately choosing two "leave it broken" branches told me Beta doesn't matter. And Frank's advice is `argmin` with no threshold (`detail_view.gd:620`) — İnovasyon 15 against 18/18 is a 3-point gap on an unbounded scale, so he will always name an axis, even on a balanced product. Advice that always fires is not advice.

**Run 2 (bridge) — the controlled pair.** `b2b_slip` and `b2b_slip_keep` share an identical world and differ only in whether the founder builds and ships what he promised. Ninety days each:

| | `b2b_slip` (word not kept) | `b2b_slip_keep` (word kept) |
|---|---|---|
| Retention modals | **65** (29 + 29 + 7 across three accounts) | **1** |
| Expansion offers | 3 | **5** |
| Version ships | 0 | 1 |
| Series A gate | not reached | **reached** |
| `probe_b`'s MRR, day 2 → 86 | $800 → **$26** | — |
| `probe_b`'s tolerance, day 2 → 86 | 50 → **75** (ratchets +5 per broken promise) | — |

The `b2b_slip` transcript is the director's complaint in raw form: a retention modal for the same customer on days 6, 9, 12, 15, 18, 21 … every three days for ninety days, answered with a 15% discount each time, the account never leaving and never recovering, its revenue bled from $800 to $26. **Twenty-nine identical decisions that changed nothing.**

And `b2b_slip_keep` is the answer already working: bug sprint on day 2, promised feature committed day 4, shipped day 14, promise resolved `kept`, one retention modal in three months. **The loop the director wants is already built. The game just never tells the player it exists.**

---

# Lens C — director assessment

## Against the five Calibration Laws

**1 · Money must never stop mattering — MIXED.** In the played run runway went 7→5 months across one v1 and stayed a live pressure; the build commit charging API/licence cash up front (`start_build:1029`) with "Bittiğinde kasada $8.700 kalır" is exactly right. But the B2C probe's runway reads `INF` from **day 11** onward and cash *rises* for the rest of the run. Post-ship B2C has no sink; MRR is derived from audience and audience only falls when quality drops below `EROSION_THRESHOLD`. **Pass pre-ship, fail post-ship.**

**2 · No dead time — FAIL in one specific place.** GELİŞTİRME. Days 10-20 of my run had two decisions. Everything else in the loop is well-paced.

**3 · Choices must visibly change state — FAIL, and this is the headline.** The `b2b_slip` transcript is 29 consecutive decisions with no visible state change. Meanwhile the product's version-over-version delta (`mvp_*_prev`) is stamped at every launch and shown nowhere. **The engine computes the visible change and then throws it away.**

**4 · Systems must be load-bearing — FAIL for two of three axes.** See A.3. A playtester who ignored İnovasyon entirely could win any run; on B2B they could ignore both İnovasyon and Deneyim.

**5 · Replayability is structural — PASS on the input side, weak on the output side.** Ten sub-types × 6-7 features × per-type axis weights is real divergence. But because the weights are never shown and the composite collapses two axes into one bucket, two different product types play more similarly than they read.

## Against the references

**Software Inc. (the system reference) — adapted well, then abandoned at ship.** Design → development → polish with quality from process is faithfully rebuilt, and the efor/hız model is better than Software Inc.'s bar-fill because time is *derived* from work and team rather than dialled. But Software Inc.'s post-ship loop — the product ages, the market moves, you patch or you sequel — is where their game keeps its grip, and it is exactly where ours goes quiet.

**Frostpunk (pressure) — the pressure exists and is not recoverable.** Frostpunk's contract is that pressure rises, you answer, and the answer *works*. In `b2b_slip` the pressure rises, you answer 29 times, and nothing works — because the only lever that moves the satisfaction target is product stability, and no retention modal ever says so. That is not Frostpunk pressure; it is a leak.

**CK3 (character weight) — the loop's weakest borrowing.** Customers have hidden tolerance, a trust ledger, a pain feature and a name from a 65-company catalog — the ingredients of character. But the retention modal presents them as a churn timer, not a person, and the same account produces the same modal 29 times. CK3 would never let a vassal's grievance repeat verbatim.

**Disco Elysium (voice) — genuinely achieved, inside the build only.** The nine build events are well-written, specific, and have real trade-offs. The 4:1 ratio of build-phase to B2B post-ship events is the entire problem in one number.

**Football Manager (readable density) — the best thing in the loop.** `feature_info_line` — "Efor 7 · İnovasyon +5 · Kararlılık +3 · Hata riski: Orta" — is exactly FM's grammar. The pricing ruler with optimal marked and live projection is FM-grade. **Do not touch either.**

## What the loop could do that none of them do

Software Inc. has no mentor and no customers who *speak*. CK3 has no product. **The unclaimed ground is a product whose quality is voiced by named characters who wanted specific things from it** — the promise system already binds a named company to a named feature with a deadline. Nobody in the genre has that. It is 80% built and 0% surfaced.

---

# Answers to the brief

## 1 · Strengths — do not break these

1. **The creation flow (01 YOL → 02 TİP → 03 ÖZELLİKLER).** Irreversibility stated up front, consequences in plain language, mentor voice, dense per-feature info, live radar, honest cash projection. Best decision surface in the game.
2. **`projected_axes` as the single source** for preview, commit stamp and v2 preview (`product_system.gd:821`). Structural "what you see is what you ship".
3. **The nine build events.** Real trade-offs, visible effect badges, one names a rival by name.
4. **The player-gated iteration park** (`:576`, `:592`). The build waits for a human; burn keeps running. Correct grammar, and the same grammar as the Beta park.
5. **The capacity pool** (`capacity_speed_factor:247`). Sprint and build compete for the same people; the cost of parallelism is legible and derived in one place.
6. **The watched churn countdown.** Churn is never instant; recovery always resets it.
7. **The efor/hız model.** Duration derived from work ÷ team, phase-sensitive crew, fresh every hour so a mid-build hire lands immediately.
8. **The pricing ruler** (B2C). Optimal marked, floor marked, live paying/MRR/conversion projection, and a reversible decision.
9. **The live product page's world-awareness** — market-share strip, named rival who passed you, promise rows with countdowns.

## 2 · Weaknesses, ranked by review damage

**W1 · A played product is born below every B2B tolerance (calibration).**
*Mechanism:* `normalized_quality(c) = 100c/(c+50)` (`quality_model.gd:87`). My played v1 reached raw Kararlılık 18 → `axis_score` = 100·18/68 = **26.5**. `B2BSalesSystem._satisfaction_target` = that number. `B2BConstants.seed_tolerance` floors at **35** (scale 1) and rises 5/scale plus sector bonus. So a played B2B v1 starts *every* account below tolerance → `RISK_TRIGGER_DAYS` 3 → retention modal on day ~4 of every account's life, forever. The catalog header and `NORMALIZE_HALF_SAT`'s own comment both already flag this: deterministic sums normalize to ~12-20 where the retired grown-axis model produced ~25-35, and the B2B tolerance band was tuned against the old numbers.
*Symptom:* the `b2b_slip` transcript — 29 identical modals per account, MRR bled to nothing, account never leaves.
*Violates:* Law 3 (choices visibly change state), Law 2 (repeated content), Frostpunk's recoverability.

**W2 · Nothing ever summons the player to the product.**
*Mechanism:* seven post-ship events, two of them B2B, none mentioning a version, a rival ship, or an axis; `ev_ps_bug_complaint` is `market_type: b2c` only. The product page is pure pull.
*Symptom:* "I only saw Echo Desk pass me because I happened to be standing on the tab." The director's "nothing about the product reaches me" is precisely this and nothing else.
*Violates:* Law 3, Law 4.

**W3 · Two of three axes are not load-bearing, and their weights are invisible.**
*Mechanism:* A.3. İnovasyon has no B2B reader; Deneyim's B2B effect decays in ~3 days; on B2C the two are perfectly fungible inside the composite; `weight` is returned by `get_quality_axes` and rendered by nobody.
*Symptom:* "picking three features felt like allocating points on an unlabelled scale."
*Violates:* Law 4 explicitly.

**W4 · The version has no report card — although the data is already stamped.**
*Mechanism:* `mvp_innovation_prev` / `_stability_prev` / `_experience_prev` written at `launch():908-910` with a comment naming the intended reader; zero readers. Same for `bug_count_at_bugfix_start_<id>`.
*Symptom:* v2 ships, a one-paragraph Frank modal fires, and the run continues identically. Nothing tells you the bet paid off.
*Violates:* Law 3.

**W5 · The v2 picker drops every piece of context that would motivate it.**
*Mechanism:* `creation_flow.gd` has zero references to promises, rivals, complaints or Frank's advice. Confirmed by search, and visible as the shape of `_update_dynamic():735-789`, which renders only efor/cost/days/cash/risk/axes.
*Symptom:* the director's sentence, verbatim: "I build v2 because it is v2 time."
*Cross-label:* the product page shows the promise as "sistem entegrasyonu" (`B2BConstants.FEATURE_LABEL_TR`); the picker lists the same feature as "**System Integration**" (the catalog's English `name`). Keeping your word requires out-of-game memory *and* a translation.

**W6 · The ceiling label teaches a rule the screen breaks.** (A.4, S2-3.) Rendered in three places plus the teaching modal's copy.

**W7 · GELİŞTİRME is dead time.** (A.5, Lens B days 10-20.)

**W8 · Beta has no decision; the spec's "archetypal startup decision" is absent.** (A.5.)

**W9 · Four catalog fields are inert.** `pull`, `stakes`, `bet`, `pitch`. `stakes` in particular is a designed-but-unbuilt system: "reputation damage multiplier if this area breaks."

**W10 · Feature names are English on a Turkish screen** — at the *first* product decision, not only in the v2 picker.

## 3 · The "why am I doing this" test

Every action a player may perform without knowing why it matters. **This is the priority list.**

| Action | Why the player can't know |
|---|---|
| **Choosing Sorumlu at commit** | Sets build speed *and* product quality (`_lead_coordination`, `_team_expertise_avg`). Rendered as an unlabelled dropdown defaulting to "Founder". Never mentioned again. |
| **Balancing İnovasyon vs Deneyim** | They are fungible inside the composite and the weights are never shown. |
| **Raising İnovasyon on a B2B product** | It has no B2B reader at all. |
| **Taking another design round** | The gain is bounded by a ceiling the screen displays incorrectly, and the round's actual effect is never reported after the fact. |
| **Waiting in Beta** | Free and strictly dominant; the player cannot tell that waiting is the whole decision. |
| **Answering a retention modal for the 12th time** | Nothing the modal offers moves the satisfaction target; only fixing the product does, and no modal says so. |
| **Running a bug sprint** | The card says "kararlılık geri gelir" but never shows the before/after. |
| **Picking v2 features** | No promise, no rival, no complaint, no Frank line is present at the moment of choosing. |
| **Choosing a product type at all** | The market-bet line written for each type (`bet`) is not rendered. |

## 4 · Do the axes matter?

Answered in full at A.3. Short form: **İnovasyon — no** (B2B: zero readers; B2C: fungible). **Deneyim — barely** (B2B: ~3-day half-life; B2C: fungible). **Kararlılık — yes, it is the entire post-ship economy.** Law 4 fails for two of three.

## 5 · Are features identities or stat bags?

**Today: stat bags with excellent prose.** The evidence is `pull` and `stakes` — the two fields that would make a feature a *thing the world reacts to* (draws users, breaks loudly) both exist on every row and are read by nothing. A feature contributes integers to a composite and complexity to a bug seed. Nothing else in the world knows it exists.

**The exception, and it is a big one:** on B2B, `pain_feature_id` binds a *named company* to a *specific unshipped feature* with a deadline, and shipping it resolves the promise through `mvp_components` membership (`promise_registry.gd:112-125`). **That is a feature as an identity** — Ege Sigorta wants system integration, by name, by a date. It is the single most valuable mechanism in the loop and it is invisible at the one screen where it would change a decision.

## 6 · Post-ship life, and the director's frame

**Does anything pull the player back?** The product page pulls (rival passed, Frank line, bug pill, promise countdown). **Nothing pushes.** Zero of seven post-ship events point at the product.

**What is the pressure model today?** Two, and they are lopsided. B2C: a slow quality-vs-rival erosion that is real but silent, plus three repeating events (in 90 days: producthunt ×8, power_user ×6, bug_complaint ×5 — 19 of 24 total fires). B2B: an every-3-days retention modal that is not pressure but a leak.

**Is "pressure → answer → report card" the right fix?** **Yes, and I'd sharpen it in three ways.**

1. **The pressure already accumulates — don't build a new pressure system, surface the one you have.** Unkept promises ratchet tolerance (+5 each), rivals advance daily, wear accrues hourly, trust decays. All of it is real and all of it is invisible between versions. The work is a readout, not an engine.
2. **The report card is already stamped.** `mvp_*_prev` is written at every launch for exactly this purpose. This is the cheapest high-value item in the entire report.
3. **Where I disagree: the director's frame is necessary but not sufficient, and on its own it will make W1 worse.** "Which pressure do I silence" presupposes that silencing works. Under today's calibration a B2B account's pressure *cannot* be silenced by any version — the target is stability, a played product's stability normalizes to ~26, and tolerance floors at 35. Ship the picker rework first and the player will make an informed choice that still fails, which reviews worse than an uninformed choice that fails. **Order matters: calibration (W1) before communication (W2/W5).**

**One alternative I considered and rejected:** making the *retention modal itself* the pressure readout ("this account is 9 points under its bar; +12 Kararlılık would clear it"). It is cheaper, but it puts the loop's most important information inside the surface that already fires 29 times — the spam becomes load-bearing. The version picker is the right home because it is the surface the player *chose* to open.

## 7 · R&D compatibility

**The data shape survives. Do not rewrite anything.** Specifically:

- `requires_research` already exists on every feature row and has exactly **two readers, both UI** (`creation_flow.gd:488` draws the lock badge; `:814` excludes locked rows from the pool-exhaustion test so a v-build can never deadlock). **There is no R&D engine to unbuild** — the slot is reserved, not mis-built. The `--product-shot=beta` frame shows the locked row rendering correctly today ("Field Connectivity … ARAŞTIRMA GEREKLİ", dimmed, non-interactive).
- Feature pools are per-sub-type dicts; axis weights are a parallel dict keyed by sub-type. Adding an unlock ledger changes neither.
- `projected_axes` is agnostic to *why* a feature is available.

**What must be reserved now, so the demo page becomes the EA page unchanged:**

1. **Keep the unlock as a filter on the same pool, never a second currency.** The single rule that preserves the page.
2. **Change the locked badge copy to carry the promise:** "ARAŞTIRMAYLA AÇILIR · TAM SÜRÜMDE". Today it reads "ARAŞTIRMA GEREKLİ", which describes a gate the demo player can never open and never explains that a later build will.
3. **Reserve a flag namespace now** (e.g. `rnd_unlocked_<feature_id>`) and register it in `GameState.FLAG_TYPES`, so saves written by the demo load in EA. This is a save-schema decision and is cheap only if made before the demo ships.
4. **Widen the lock beyond complexity-5.** Only 5 features carry `requires_research`, all cx-5, so the demo's locked slots cluster in one visual band. Spread them so every pool shows 1-2 locked rows at mixed complexity — the "same page with more open" reads better.
5. **`_pool_exhausted` already excludes locked rows.** Keep that; it is what stops a v-build from deadlocking in the demo.

**One warning:** the R&D *tab* is already in the left rail and opens a bare "Content on the way" placeholder, with no lock styling — unlike the portfolio's honest "KİLİTLİ · Series A sonrası". A demo player will click it. Either give it the locked treatment or remove it from the rail.

## 8 · The demo cut

**Smallest set that makes the loop feel intentional in 60-90 minutes** (all DEMO-cheap or DEMO-medium; details and costs in the next section):

- **R1** re-scale `NORMALIZE_HALF_SAT` + B2B tolerance band *(cheap, one constant + one table — the highest-value change in this report)*
- **R2** version report card from the already-stamped `mvp_*_prev` *(cheap)*
- **R3** context header on the v2 picker: open promises, rival who passed, complaint count *(medium)*
- **R4** fix the ceiling label wording in three sites + the intro event *(cheap)*
- **R5** rate-limit the retention modal per account and escalate its copy *(cheap)*
- **R6** one push notification per post-ship pressure event *(medium)*
- **R7** show the per-type axis weight on the feature screen *(cheap)*
- **R8** Turkish feature names *(cheap; belongs to Localization Phase 2)*

**Honestly EA work, not demo:** making İnovasyon and Deneyim mechanically distinct (R9); wiring `pull` and `stakes` (R10); the B2B product-complaint event family; giving GELİŞTİRME its own decision cadence; multi-product.

---

# Recommendations

One recommendation per weakness. No options.

### R1 · Re-scale the quality→economy curve so a played v1 lands inside the tolerance window
**Weakness:** W1. **Cost: DEMO-cheap** (one constant + one 6-row table), **calibration-risky** — re-run the B2B probes after.
**Do:** drop `QualityModel.NORMALIZE_HALF_SAT` from 50 toward ~25 (the value the constant's own comment nominates) **and** re-seat `B2BConstants.TOLERANCE_BASE`/`TOLERANCE_PER_SCALE` against the resulting numbers, targeting a played v1 at roughly the *middle* of the tolerance spread rather than under its floor.
**Why:** `axis_score(18) = 26.5` against a tolerance floor of 35 means the retention loop is not a failure state the player entered, it is the default state of a competently played product. Every other fix in this list is decoration until this moves.
**Touches:** every economic reader at once (audience, price, satisfaction, VC sorgu, health bands). **Verify with:** `--run-log=b2b_solo:90:sim` and `b2b_slip:90:sim` — the target is `b2b_slip`'s retention count falling from 65 into single digits *without* `b2b_risk` becoming survivable.
**Reference:** none — this is pure calibration.

### R2 · Ship the version report card from data you already stamp
**Weakness:** W4. **Cost: DEMO-cheap.**
**Do:** on the live product page, render the version-over-version delta from `mvp_innovation_prev`/`_stability_prev`/`_experience_prev` beside the current axes ("v2 · İnovasyon +6 · Kararlılık +2 · Deneyim −1"), and the bug delta from `bug_count_at_bugfix_start_<id>` ("başladı 14 · çıktı 3"). Add the ~2-week follow-up beat the director asked for as a Frank line keyed off `mvp_version_history`'s last entry.
**Why:** the writes exist, the comments name this exact reader, and it converts a version from an expense into an outcome. Highest value per line of code in this report.
**Touches:** `detail_view.gd` only. **Breaks:** nothing.
**Reference:** Football Manager's post-match report.

### R3 · Give the v2 picker a context header
**Weakness:** W5. **Cost: DEMO-medium.**
**Do:** above the feature grid in `v2` mode, render three lines: open promises (company + feature + days, using the **Turkish** label and marking the matching row in the grid), the rival who passed you and on which axis, and the standing complaint/bug pressure. Mark the promised feature's row with a "SÖZ VERİLDİ" badge.
**Why:** this is the whole of "I build v2 because it is v2 time". The promise already binds a named company to a real feature id; the picker just has to look. It also closes the cross-label gap by rendering one label in both places.
**Touches:** `creation_flow.gd` (read-only additions), `B2BConstants.feature_label`. **Breaks:** nothing.
**Reference:** CK3's decision screen showing who wants what before you choose.

### R4 · Rename the ceiling, don't re-scope it
**Weakness:** W6. **Cost: DEMO-cheap.**
**Do:** change the label from "tavan" to what it actually bounds — "tur kazancı sınırı" / "bu turların getirebileceği en fazla" — in the three render sites plus `_build_iter_decision_intro_event`'s copy, and show it as a *gain budget* ("bu tur +1 · kalan 4") rather than as a bound on the axis total.
**Why:** the engine is internally consistent and self-documented; the defect is purely the word. Do **not** extend the ceiling to cover the commit stamp — that would break `projected_axes`'s preview==ship guarantee, which is one of the loop's best properties.
**Touches:** `creation_flow.gd:867`, the floating HUD, `product_system.gd:1343`. **Breaks:** nothing.

### R5 · Rate-limit and escalate the retention modal
**Weakness:** W1's symptom. **Cost: DEMO-cheap.**
**Do:** a per-customer cooldown on `_maybe_enqueue_retention` (10-14 days), and make the second and third occurrences *different copy* that names the real cause — "bu hesabı tutan şey ürünün kararlılığı, indirim değil". After the cap, the account slides to churn without further modals.
**Why:** 29 identical modals is the single most review-damaging thing in the loop, and a repeated decision that changes nothing trains the player to stop reading. Rate-limiting also makes W1's calibration error *visible as a loss* instead of an endless nag.
**Touches:** `b2b_sales_system.gd:194` (owned by the Playable Run Sprint — coordinate). **Breaks:** the churn rate rises; that is intended and is what R1 is for.
**Reference:** Frostpunk — pressure you cannot answer must resolve, not repeat.

### R6 · One push per post-ship pressure event
**Weakness:** W2. **Cost: DEMO-medium.**
**Do:** three pushes, reusing the existing event pipeline: (a) a rival passes you on your product type → an event, not just a strip that appears if you look; (b) live bugs cross `product_bug_risk == "yuksek"` → an event, on **both** market types (today `ev_ps_bug_complaint` is B2C-gated); (c) a promise crosses 3 days remaining → an event. Each one-shot per occurrence with a real cooldown, each ending on a choice that can navigate to the product.
**Why:** the product page is already good. It needs a doorbell, not a renovation.
**Touches:** `data/events/reactive/` (+3 files, TR+EN per the Bilingual Birth Law), trigger types for rival-passed and bug-risk. **Breaks:** event budget — pair with R5 so total modal volume falls.

### R7 · Show the market's axis weights where features are chosen
**Weakness:** W3's readability half. **Cost: DEMO-cheap.**
**Do:** render `QUALITY_AXES` weights on the feature screen as the market's priorities — "Bu pazarda: İnovasyon ×1.4 · Deneyim ×1.3 · Kararlılık ×0.7" — and reuse the same line on the type card at step 02, so the type choice is legible *before* it is irreversible.
**Why:** the data is already returned by `get_quality_axes` and thrown away by every caller. It is the only thing that makes two product types play differently, and it is currently a secret.
**Touches:** `creation_flow.gd`, `product_ui_shared.gd`. **Breaks:** nothing.
**Reference:** Football Manager's role suitability.

### R8 · Turkish feature names
**Weakness:** W10. **Cost: DEMO-cheap**, but **owned by Localization Phase 2** — hand it over, don't do it here.
**Do:** localization keys for all 71 feature `name` values (10 pools, 6-7 each); render the Turkish name everywhere and keep the English as the internal id.
**Why:** it is the first thing a Turkish player reads on the first product decision, and it is the mechanical cause of the promise cross-label gap in R3.

### R9 · Give İnovasyon and Deneyim one mechanical job each — EA
**Weakness:** W3. **Cost: EA.**
**Do:** exactly what the director's frame proposes, and no more. İnovasyon → a term in new-customer arrival (B2C audience *acquisition* rather than the shared composite) and in rival differentiation. Deneyim → a *standing* term in the B2B satisfaction target, not just the signing seed, so it stops decaying to nothing in three days. Kararlılık keeps churn/bugs.
**Why:** this is the correct fix and it is not demo work: it changes three economies at once and needs its own calibration pass. Until then, R7 at least makes the current single-bucket reality honest.
**Note:** the cheapest half of this — adding Deneyim as a standing term in `_satisfaction_target` — is a two-line change and could be pulled into the demo if the calibration pass in R1 has budget for it. I would not do both in one pass.

### R10 · Wire `stakes`, retire `pull`, render `bet` — EA (except `bet`)
**Weakness:** W9. **Cost: `bet` is DEMO-cheap; the rest is EA.**
**Do now:** render `bet` on the type card at step 02 — the founder-voice market bet is written for all ten types and is better copy than the line currently shown. **Do in EA:** make `stakes` the reputation-damage multiplier its comment promises (a bug in a high-stakes feature costs brand, not just stability), which is also what turns a feature into an identity. **Retire `pull`** or fold it into R9's İnovasyon acquisition term — it duplicates what the axis should do.

---

## Do not touch

Things that work, that a well-meaning fix could ruin:

1. **`projected_axes` as the single source** for preview, commit and v2 preview. Any "make the ceiling apply everywhere" fix breaks the preview==ship guarantee. Fix the label (R4), never the scope.
2. **The player-gated iteration park.** Do not add an auto-advance "for pacing". The park *is* the decision.
3. **The Beta park with no auto-ship.** Same reason. (Beta's missing *decision* is a separate problem — add a decision, don't remove the park.)
4. **The capacity pool.** It is the single place parallel-work cost is derived, and both the tick and the UI projection read it. Do not special-case sprints out of it.
5. **The `_recover` seam on promise-kept** (`b2b_sales_system.gd:430`). The comment explains a real bug that was fixed here: promising rescued the account, delivering did not. Both paths must keep going through `_recover`.
6. **The R1≡R6 shared-delta contract** (`_audience_delta_per_hour` feeding both the tick and `growth_band`). It is why "büyüyor/eriyor" can never contradict the motion.
7. **`feature_info_line` and the pricing ruler.** The best readable-density work in the game.
8. **The 01 YOL screen.** Do not add a third path, do not soften "Sonradan değişmez."
9. **`_pool_exhausted` excluding research-locked rows.** It is what stops a v-build from deadlocking; R&D work must preserve it.

---

## Open questions — design calls I cannot infer

1. **After R1, should a *bad* B2B product be survivable at all?** `b2b_risk` is unsalvageable by construction and `b2b_slip` is recoverable. Which is the intended demo default — is a neglected product supposed to cost you the book, or only bleed it?
2. **Should İnovasyon do anything on B2B at all** (R9), or is "consumer rewards novelty, enterprise rewards reliability" the intended, stated asymmetry? If the latter, the fix is copy on the 01 YOL card, not code — and that is DEMO-cheap.
3. **Does the demo want a ship-now-vs-polish decision in Beta** (restoring `PROJECT_SPEC §5.1`'s "archetypal startup decision"), or is Beta deliberately a breather between the build and the ship moment?
4. **How many post-ship modals per week is the target?** R5 and R6 push in opposite directions and I have no target number to tune against. The `b2c` 90-day run's 24 fires is almost certainly too few; `b2b_slip`'s 65 is certainly too many.

---

*Read-only review. No source, fixture, baseline or git state was changed. Probe logs and read frames are retained in the session scratchpad under `audit/`; all screenshot harness output is in `%APPDATA%\Godot\app_userdata\Project Unicorn\`.*
