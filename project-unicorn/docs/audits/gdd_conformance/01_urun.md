# Ürün — GDD v2 conformance

**Date:** 2026-08-20 · **Chapter:** 03 · Product Lifecycle (**rev 4**, DIRECTOR-APPROVED 2026-08-20)
**Baseline:** `main` @ `7687095`, working tree clean. Every `file:line` resolves to that commit.
**Companions:** `05_operasyon.md` (serving cost, support load, infra), `03_ekip.md` (assignment, the second team), `02_satis_ve_pazar.md` (interest, feature asks), `docs/audits/calibration_round_A_2026-08-19.md`.

---

## Verdict

The build pipeline itself is the best-built system in the game: four phases, real formulas, a single-renderer build bar with three hosts and a smoke case proving they agree. What rev 4 asks for is almost entirely *outside* that pipeline — a fifth phase that persists after ship, an intent declared at Konsept, a decaying discovery curve, a triage loop, an infrastructure step at publish, and above all the support-vs-build tension that gives the module its pressure. None of those exist. The good news is the removals: rev 4 cuts per-feature free/paid packaging and the beta-user program, and **neither was ever built**, so those lines are zero work rather than delete work.

The single most consequential finding: **starting a build costs the live product nothing.** Post-ship bug wear reads the full active developer roster whether or not those developers are on a build (`product_system.gd:769`), so a v3 build in progress reduces live bugs exactly as much as an idle team would. Rev 4 §8 is the reason coverage and the second hire bite; today there is nothing to bite.

---

## 1. Requirements

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | Konsept → TASARIM → GELİŞTİRME → BETA → CANLI/DESTEK (§1) | Four phases exist as strings on `FeatureBuild.current_phase`: `planning / iteration / development / bugfix / shipped` (`feature_build.gd:46-49`). Labels via CSV (`creation_flow.gd:41-44`). | **KISMİ** — the first four are there, the fifth is not | — |
| 1.2 | **DESTEK is permanent**; after publish the assigned team stays on the live product until the next version starts (§1) | `ship_active_build()` sets `current_phase = "shipped"` and **nulls `active_build`** (`product_system.gd:1253-1256`). Post-ship life is flag state (`mvp_*`), not a phase. No team is "on" anything. | **YOK** — grep for a `DESTEK`/support phase returns nothing product-side | several days |
| 1.3 | The build bar never disappears; shows the current phase including support, on HUD, tracker, ODA monitor, Product tab (§1) | One renderer, three hosts, proven by smoke `build_bar_hosts_agree` (`endgame_smoke.gd:2833-2900`). But `BuildBarModel.derive()` returns `false` outside the three build phases (`build_bar_model.gd:111-112`), so after ship the bar draws nothing (`build_bar.gd:163-164`), the HUD card hides itself (`build_hud_panel.gd:162-165`), the tracker view is freed by the router (`product_tab.gd:132-137`), and the ODA block is hidden (`oda_view.gd:1009`). | **KISMİ** — the widget is right, its lifetime is wrong | a day |
| 2.1 | Konsept sets: name · market · subtype · **version intent** · features · **price** · **team assignment** (§2) | Name (`creation_flow.gd:701-713`), market (step 1, `:208-223` — used only to filter the type grid, never stored), subtype (`:319-339`), features (`:471-545`), and **one lead** via an OptionButton (`:714-730`). | **KISMİ** | — |
| 2.2 | Version intent declared at Konsept (§2, §4) | **Nothing.** No `intent` / `version_type` / `release_type` field, no flag, no UI. The only relative is emergent and comment-only: a v-build with an empty `typed_new` is called "hardening" at `product_system.gd:118, 1154` and seeds 0 bugs — not labelled, not selected, not displayed. | **YOK** | several days |
| 2.3 | Price is part of Konsept (§2, §3) | Price is **post-ship only** and B2C-only: the ruler lives in `pricing_panel.gd`, mounted by the shipped-product detail view (`detail_view.gd:293-296`), single write seam `SalesSystem.apply_b2c_price` (`pricing_panel.gd:299`). B2B price is set once inside the pitch from the archetype band (`pitch_system.gd:358-360`). | **ÇELİŞİYOR** — the code puts price after ship; the GDD puts it at Konsept and again at publish | a day |
| 2.4 | Team assignment at Konsept, founder included (§2) | One `SORUMLU` dropdown → `assigned_engineer_id` **and** `lead_engineer_id` (`product_system.gd:1042-1043`). Everyone else contributes implicitly by role: `_phase_pace_sum` walks every active employee whose role is in `PHASE_CREW[phase]` (`:315-335`, table `:282-286`). | **KISMİ** — one lead, no roster, no exclusivity | several days (owned by `03_ekip.md`) |
| 2.5 | Feature catalog: 3 per axis × 3 axes = 9 per subtype, one per axis research-locked (§2) | 10 subtypes, **61 features**, 6 per subtype (7 for `ai_code_copilot`) — `product_catalog.gd:70-152`. Features are not grouped by axis; each carries a `dimension_contribution` to one or two axes. Research-locked: **4 features in the whole catalog** (`:93, 101, 125, 131`), not one per axis per subtype. | **KISMİ** — right order of magnitude, wrong shape | a day |
| 2.6 | Per feature: raw axis points, build effort, licence cost, research flag, **usage weight** (§2) | `complexity`, `efor`, `cost`+`cost_source` (11 rows only), `dimension_contribution`, `requires_research` all present (`product_catalog.gd:48-61`). Also `pull`, `stakes`, `tags`: **dead data, zero readers**. **`usage weight` does not exist.** | **KISMİ** — usage weight is what Operasyon's serving cost needs | hours + see `05_operasyon.md` |
| 2.7 | Research slot inside Product: assign a developer, time + cost, feature unlocks (§2) | `requires_research` has two readers, both cosmetic: a locked badge (`creation_flow.gd:501-509`) and an exclusion from the pool-exhaustion test (`:826-834`). No R&D system exists — `TimeManager._tick_rnd()` is `pass` (`time_manager.gd:307-308`), `data/techtree/` is empty. | **KISMİ** — the lock renders, nothing can open it | a day |
| 3.1 | The player sets a price; that is the whole decision (§3) | True for B2C once the tier is open: one slider, one commit (`pricing_panel.gd:99-102, 292-300`). | **VAR** | — |
| 3.2 | B2C free tier and paid tier exist as facts of the world, not a configured package (§3) | Exactly that: `b2c_audience` is the free population, `b2c_paid_tier_open` + `b2c_price` are the paid side (`game_state.gd:96-98`). Conversion `clamp(0.35 × optimal/price, 0.02, 0.60) × max(0.4, 1 − bugs×0.02)` (`sales_system.gd:507-515`) — driven by price, product value and bugs, as asked. | **VAR** | — |
| 3.3 | No per-feature free/paid flags, no packaging screen, no usage limits, no paid-only gating, no paywall-backlash events (§3, §11) | **The mechanic never existed.** No `free`/`paid`/`tier`/`plan` key on any of the 61 feature rows; the full record shape is documented at `product_catalog.gd:48-61`. | **VAR (nothing to remove)** | zero |
| 3.4 | B2B: contract price by scale and sector (§3) | Price comes from the **archetype band** only — small 200-500 / mid 800-2000 / enterprise 3000-8000 (`customer_archetypes.gd:21-46`), placed by the pitch's price beat (`pitch_system.gd:358-360`). `scale` reaches tolerance and request difficulty, never price; `industry` reaches tolerance, names and voice, never price. | **ÇELİŞİYOR** — `02_satis_ve_pazar.md` owns the fix | a day |
| 3.5 | Rename "deneyen" → "Ücretsiz kullanıcı" everywhere: monitor, pricing panel, event copy (§3) | Complete surface, and it is small: `PROD_TRYING_CAP` (`strings.csv:1235`, "DENEYEN"/"TRYING IT") and `PROD_ROW_B2C` (`:1126`), rendered at `detail_view.gd:260, 465` and `portfolio_view.gd:139, 144`. Event copy: `ev_ps_b2c_paid_tier.json:11` ("Birkaç yüz kişi deniyor") and `:41` ("trying it"). | **rename** | hours |
| 4.1 | Three version intents with different length, content and effect (§4) | Absent — see 2.2. No length modifier, no phase-skipping, no per-intent effect. | **YOK** | several days |
| 4.2 | Kararlılık: no new features, live bug pool ↓, Kararlılık ↑, tech debt ↓, incident risk ↓ | The **bug sprint** is the nearest thing (`product_system.gd:799-841`) but it is a separate flag-based mode, not a version, and it clears live bugs at a flat 4/day with no tech-debt or incident term. | **KISMİ** | — |
| 4.3 | Bakım: targeted fixes, open bugs ↓ fast | Same sprint, same limits. | **KISMİ** | — |
| 5.1 | TASARIM: auto-advancing rounds, max 4 (§5) | `ITER_MAX_ROUNDS := 4` (`product_system.gd:71`), rounds chain themselves `_end_round → _start_next_round` (`:576-577`), park at the cap (`:578-579, 651-656`). | **VAR** | — |
| 5.2 | One refilling bar; round as text "Tur 2", cap "Tur 4 · son" (§5) | Exactly this, and it is new: one track, no cells (`build_bar.gd:7-10, 176-187`); fill empties and refills per round (`build_bar_model.gd:59-71`); captions `BUILD_ROUND_OF` / `BUILD_ROUND_LAST` (`strings.csv:431-432`). | **VAR** | — |
| 5.3 | Diminishing gains (§5) | `QualityModel.grow(current, raw, asymptote)` against per-axis ceilings (`quality_model.gd:79-82`, applied `product_system.gd:659-679`, ceilings `:551-565`). | **VAR** | — |
| 5.4 | "Geliştirmeye geç →" from the end of round 1 (§5) | `can_enter_development()` = `iteration_count >= 2 or iteration_decision_pending` (`product_system.gd:595-600`); round 2 starts in the same tick round 1 ends, so the button opens the instant the 20 % band fills. | **VAR** | — |
| 5.5 | Mid-round develop abandons the partial round (§5) | Gains apply only at round end (`product_system.gd:604-606`); tooltip `BUILD_HALF_ROUND_TOOLTIP` "Yarım tur sayılmaz" (`strings.csv:438`). | **VAR** | — |
| 5.6 | **Short design = more tech debt** (§5) | No link exists. Tech debt is a boolean written only by two event JSONs (`ev_mvp_dev_001`, `ev_mvp_dev_002`); round count never touches it. The cost of a short design today is purely the forgone `grow()` applications. | **YOK** | hours (once debt is numeric) |
| 6.1 | GELİŞTİRME: one bar to the effort cap; parks at cap; "Beta'ya geç →" (§6) | `cap = 0.80 × total_efor` (`product_system.gd:491-492`); at cap `working = false`, effort and bug accrual both stop, burn continues (`:496, 526-529`); exit only via `enter_beta()` (`:619-648`); the bar reads `BUILD_DEV_READY` (`build_bar.gd:191-192`). | **VAR** | — |
| 6.2 | Speed from **Geliştirme + Hız** (§6) | `speed = max(1.0, (1.0 × founder tech + 0.25 × Σ developer HIZ) × coordination(lead))` (`product_system.gd:338-343`). "Hız" is the employee `AXIS_PACE`; "Geliştirme" does not exist as a skill — the founder side reads `tech`, the employee side reads a role tag. | **KISMİ** — blocked on the Ekip skill model | see `03_ekip.md` |
| 6.3 | Bugs accrue inverse to Geliştirme (§6) | `rate = max(0.010, complexity × 0.006 − team_expertise × 0.005)` (`product_system.gd:705-721`), expertise being the weighted `UZMANLIK` average, lead ×1.5. Same substitution problem as 6.2. | **KISMİ** | see `03_ekip.md` |
| 7.1 | BETA is a **counter**, not a bar: BULUNAN / ÇÖZÜLEN / KALAN (§7) | Both exist, in different hosts. The BuildBar draws a **draining track** `bugs_remaining / bugs_start` plus a "HATA {n}" chip (`build_bar_model.gd:117-118`, `build_bar.gd:198-200, 228-240`). The three counters live on the HUD card (`build_hud_panel.gd:204-207`) and as a line on the tracker (`creation_flow.gd:866-868`). | **ÇELİŞİYOR** — the bar must become the counter | hours |
| 7.2 | **Discovery decays sharply**; zero is never reached (§7) | Discovery is **flat**: `find += 6.0/day × tester multipliers × capacity` (`product_system.gd:682-702`, `BETA_BUG_FIND_PER_DAY := 6.0` at `:135`). Nothing scales with elapsed time or with bugs remaining — the only "decay" is the hidden pool running out, which means **zero IS reachable** and waiting for it is currently rational. | **ÇELİŞİYOR** — this inverts the intended trade | a day |
| 7.3 | The **whole assigned team** hunts bugs (§7) | Testers only, in practice. `tester_find_mult` reads only `ROLE_TESTER` UZMANLIK (`product_system.gd:390-393`), `tester_tempo_mult` only tester HIZ (`:396-400`); both are exactly 1.0 with no tester. `PHASE_CREW["bugfix"]` includes developers (`:285`) but they only move the effort percentage, not find or fix. The comment at `:397-398` claiming otherwise is wrong. | **ÇELİŞİYOR** | hours |
| 7.4 | Shipping finds bugs faster than testing, so "ship early and fix in support" is legitimate (§7) | Post-ship wear (`:760-778`) is a *creation* rate, not a discovery rate, and it is far slower than beta's 6/day. Without a decaying beta curve there is no crossover, so the strategy the chapter wants to legitimise is dominated. | **YOK** | a day (falls out of 7.2) |
| 7.5 | Tooltip on ship: "{n} hata canlıya taşınır" (§7) | Exactly that, on both hosts: `BUILD_SHIP_TOOLTIP_BUGS` (`strings.csv:435`), set at `creation_flow.gd:869-870` and `build_hud_panel.gd:208-209`. **Bug:** it prints `b.bug_count` before `launch()` adds `CRITICAL_BUG_LAUNCH_PENALTY = 5` (`product_system.gd:940-942, 961`), so it under-reports by 5 whenever `critical_bug_unfixed` is set. | **VAR** (with a 1-line bug) | hours |
| 8.1 | After publish the team **stays on the product in DESTEK** (§8) | See 1.2. There is no post-ship assignment of any kind. | **YOK** | several days |
| 8.2 | Incoming reports are **triaged, fixed and patched** (§8) | No per-bug entity exists. `mvp_live_bug_count` is one integer (`game_state.gd:76`). The only operation is the bulk **bug sprint** (`product_system.gd:799-841`) — no triage, no validate/reject, no patch. | **YOK** | several days |
| 8.3 | Live inflow = f(usage, tech debt, version age, features shipped) (§8) | `rate = max(0.002, b2c_audience x 0.00004 + shipped_complexity x 0.0012 − team_expertise x 0.005)` (`product_system.gd:760-778`). **Usage: partial** — B2C audience only, so a B2B product's usage term is always 0. **Features shipped: yes**, via complexity. **Tech debt: no. Version age: no.** | **KISMİ** | a day |
| 8.4 | **Starting a new version pulls the team off support**; unmanned support means bugs pile up, satisfaction falls, complaints and incidents become likelier (§8) | **Nothing.** Wear reduction reads the full active developer roster with no build check (`:769`). Nothing decrements a support capacity when a build starts. B2B satisfaction reads product stability + trust only (`b2b_sales_system.gd:96-106`); B2C reads the experience axis and live bugs (`sales_system.gd:414-428`). Neither has a staffing term. The B2B support desk is a different department (`DEPT_CUSTOMER`) and never consults `ProductSystem`. | **YOK — the module central pressure is absent** | several days |
| 8.5 | With more people the player can split: one group builds, another supports (§8) | No allocation layer exists to split. See `03_ekip.md` section 6. | **YOK** | several days (owned by Ekip) |
| 8.6 | "V2 geliştir →" reopens Konsept (§8) | The detail view "Geliştir · v{n}" action card routes to the creation flow in version mode (`detail_view.gd:303-322, 528-541`). | **VAR** | — |
| 9.1 | Publish flow: 1. Fiyat · 2. Altyapı (provider + capacity) · 3. Confirm, re-asked each version, pre-filled (§9) | There is **no publish flow**. The Ship button calls `ProductSystem.launch()` directly with no dialog (`creation_flow.gd:910-914`, `build_hud_panel.gd:215-219`); the only `confirm_requested` in the module is build *cancellation*. The nearest thing to a confirm is the one-choice ship-moment event modal (`product_system.gd:1338-1362`), which has no decline branch. | **YOK** | several days (Altyapı owned by `05_operasyon.md`) |
| 10.1 | Ürün Monitörü fields (§10) | Field-by-field table in section 4 below. Of the asked fields: 5 present, 4 partial, 6 absent. | **KISMİ** | a day |
| 11.1 | Do not re-introduce per-feature free/paid, packaging screen, usage limits, paid-only gating, paywall backlash (§11) | None of it exists. | **VAR (zero work)** | zero |
| 11.2 | Do not re-introduce **the beta-user program** (§11) | Never existed — no `beta_user` / `beta_channel` / `opt_in` vocabulary anywhere in `scripts/`, `data/` or `localization/`. Beta is purely internal QA. | **VAR (zero work)** | zero |
| 11.3 | Users find bugs only after ship, through normal live inflow (§11) | Already true — post-ship wear is the only user-facing bug source (`product_system.gd:760-778`). | **VAR** | — |

---

## 2. Contradictions and removals, expanded

### 2.1 BETA is a draining bar, and its discovery does not decay

**The code decided:** the beta bar empties as bugs are fixed (`build_bar_model.gd:117-118`, drawn `build_bar.gd:198-200`), and finding runs at a flat `BETA_BUG_FIND_PER_DAY := 6.0` (`product_system.gd:135, 690`) until the hidden pool is exhausted.

**The GDD now rules** (§7): a counter, not a bar; discovery decays sharply; zero is never reached, and waiting for it is the trap; shipping finds bugs faster than testing because live users hit them.

**Why this is one decision and not two.** A flat rate over an exhaustible pool makes waiting in Beta strictly optimal — you can always reach zero, and reaching zero costs only calendar days. A decaying rate over an inexhaustible pool makes waiting a losing race, which is what turns shipping with 9 open into a real decision and what makes rev 4 §8 fast, focused build is itself a virtue true. **Retire:** the `bugs_start` denominator flag `bug_count_at_bugfix_start_<id>` (`product_system.gd:641-644`) and the `beta_fill` branch. **Build:** a decay term on the find rate, and an inflow that keeps the hidden pool non-empty.

### 2.2 There is no DESTEK phase, so there is no support-vs-build tension

**The code decided:** ship nulls the build (`product_system.gd:1256`). Everything after that is loose flags. Post-ship bug wear reduces itself using `_team_expertise_avg` over the development crew — **the full active roster, with no availability check** (`:769`).

**The GDD now rules** (§1, §8): DESTEK is a first-class phase the team occupies; starting a new version pulls them out of it; with nobody covering, bugs pile up and satisfaction falls.

**What has to exist for this to be expressible:** a fifth phase the build bar renders; an assignment layer where a person is in the build team or in support, not both — that is `03_ekip.md` section 6, and it is the true blocker; and a coverage reader that satisfaction and incident probability consult — `05_operasyon.md` section 1.2. Until the assignment layer exists this requirement cannot be implemented at all, which is why Ekip comes first in the implementation order.

**Second-order defect to fix in the same pass:** a build parked in Beta indefinitely still counts a full capacity slot (`capacity_demand()` at `product_system.gd:248` has no park exclusion), so a player who never ships permanently halves every bug sprint they run. Almost certainly unintended, and it is the only build-to-support penalty in the code today.

### 2.3 Price sits after ship; the GDD puts it at Konsept and at publish

**The code decided:** B2C price is a post-ship ruler (`pricing_panel.gd`, mounted `detail_view.gd:293-296`), opened as a side effect of the first commit (`sales_system.gd:568`); B2B price is decided inside the pitch (`pitch_system.gd:358-360`) and never revisited except by discount and expansion.

**The GDD now rules** (§2, §9): price is a Konsept field and step 1 of the publish flow, re-asked at each version and pre-filled.

The pricing panel is also one of the three named surfaces for the Ücretsiz kullanıcı rename, so the rename and the price move touch the same file. Do them together.

### 2.4 Usage weight does not exist, and Operasyon needs it

Rev 4 §2 lists usage weight as a per-feature field; §13 says usage feeds serving cost, free-tier users included. The catalog has no such field (`product_catalog.gd:48-61`), and there is no serving cost to feed (`05_operasyon.md`). This is one field plus one summation, but it sits on the critical path for the Finans gross-margin headline, so it should land **with** Operasyon rather than after it.

### 2.5 Removals that cost nothing

Rev 4 §11 reads like a delete list. It is not: **per-feature free/paid flags, the packaging screen, usage limits, paid-only gating, the paywall-backlash family and the beta-user program were never built.** The evidence is the feature record shape (`product_catalog.gd:48-61`; all 61 rows carry exactly id, complexity, efor, pull, stakes, optional cost and cost_source, dimension_contribution, requires_research, tags) and an empty grep for the beta-channel vocabulary. The only live free/paid concept is product-level and correct per §3: one boolean plus one price.

What **is** worth deleting while in the area: `pull`, `stakes` and `tags` on all 61 features — declared with documented semantics at `product_catalog.gd:52-53`, read by nothing.

---

## 3. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| Features → one-time cost | Ürün → Finans | `FinanceSystem.apply_one_time_cost(ProductCatalog.sum_cost(new features), build_commit)` (`product_system.gd:1070`, v-build `:1168`). No affordability gate — cash may go negative (`:1068-1069`). | **present** |
| **Usage → serving cost** | Ürün → Operasyon → Finans | **ABSENT.** No usage weight, no serving cost, no COGS. Needs: per-feature usage weight, a usage aggregate (paying + free + audience activity), and a burn category. | **absent** |
| Quality and bugs → B2C audience | Ürün → Satış | `QualityModel.shipped_normalized()` feeds `_audience_delta_per_hour` (`sales_system.gd:200-221`); effective stability = stability − 0.8 × bugs (`quality_model.gd:123-124`). | **present** |
| Live bugs → conversion | Ürün → Satış | `bug_factor = max(0.4, 1 − bugs × 0.02)` (`sales_system.gd:507-515`) — added by Calibration Round A §6. | **present** |
| Product stability → B2B satisfaction | Ürün → Satış | `_satisfaction_target = axis_score(economy_dims, stability) + trust_offset` (`b2b_sales_system.gd:96-106`). Global, identical for every account. | **present but undifferentiated** |
| **Version age → interest / feature asks** | Ürün → Satış | **ABSENT.** `mvp_launch_day` is stamped once at the *first* ship and never overwritten (`product_system.gd:1243-1245`); it is read only for the display badge (`detail_view.gd:435-436`). No satisfaction, interest or rival comparison consumes it. §1 version age decays interest has no carrier. | **absent** |
| Shipped features → feature asks | Ürün → Satış | `pick_pain_feature` walks the catalog skipping shipped features (`b2b_sales_system.gd:486-504`); promise resolution reads `mvp_components` (`promise_registry.gd:112-123`). | **present** |
| **Bugs → support load** | Ürün → Operasyon | **ABSENT.** No support-load concept; the field was deliberately deleted (`customer.gd:54-55`). | **absent** |
| **Tech debt → incidents** | Ürün → Operasyon | **ABSENT** in both halves: debt is one boolean consumed once at `enter_beta` (`product_system.gd:534-539`), and no incident system exists. | **absent** |
| Team skills → speed, ceiling, bugs | Ekip → Ürün | Dense and real: speed (`product_system.gd:338-343`), ceilings (`:551-565`), bug rate (`:705-721`), tester multipliers (`:390-400`), PM bonus (`:891-900`), coordination (`:295-312`), overtime (`:501, 716`). | **present** |
| **Build occupancy → support availability** | Ürün ↔ Ekip | **ABSENT** — the finding in 2.2. Capacity is a *job* divisor (`product_system.gd:242-259`), never a person allocation. | **absent** |
| Sprint pressure → hiring signal | Ürün → Ekip | `needs_engineer` after 3 sprints in 20 days (`product_system.gd:844-855`) → AŞIRI YÜKLÜ badge (`hr_morale_system.gd:350-356`) → cleared by a developer hire (`hr_search_system.gd:224-228`). | **present** |
| Build phase → event eligibility | Ürün → Event | While a build runs, only `build_safe`-tagged events or ones with a matching `build_phase` condition can fire (`event_manager.gd:450-470`). Nine `ev_mvp_*` events ride this. | **present** |
| Ship → event | Ürün → Event | `_trigger_ship_moment` enqueues a synthetic one-choice modal (`product_system.gd:977, 1306-1362`). | **present** |
| **Version intent → everything** | Ürün → all | **ABSENT** — no intent to propagate. | **absent** |
| `mvp_shipped` → phase gate, angel round | Ürün → Sonlar / Yatırım | `phase_gate_system.gd:39`, `angel_round_system.gd:54`. | **present** |
| Product quality → rival comparison | Ürün ↔ Rakipler | `_rival_relative_quality` recentres against same-subtype startup rivals (`sales_system.gd:230-242`) — the one real rival-to-economy channel. | **present** |

---

## 4. Ürün Monitörü — field by field (§10)

| Asked | Today | Where |
|---|---|---|
| price | B2C in the pricing panel chip; **B2B absent** (inert Fiyatlandır · SATIŞ İLE card) | `pricing_panel.gd:182-184`; `detail_view.gd:317-322` |
| MRR | B2B MRR KATKISI present; **B2C only as a slider projection**, no live readout | `detail_view.gd:276, 462-463`; `pricing_panel.gd:273` |
| ücretsiz kullanıcı | present as DENEYEN — the rename target | `detail_view.gd:260, 465` |
| paying users (B2C) | **only as a projection** at the slider price | `pricing_panel.gd:270` |
| accounts (B2B) | present, MÜŞTERİ | `detail_view.gd:275, 457-461` |
| churn | **absent** from the Product tab entirely | — |
| satisfaction | **absent** from the detail view; an up/flat/down arrow exists only on the portfolio card | `portfolio_view.gd:133-138` |
| interest / demand | **absent** as a named metric; `b2c_audience` doubles as it | — |
| open bugs | present — DURUM cell, trend pill, risk band | `detail_view.gd:261, 430-434, 423-426` |
| version | present (badge + SÜRÜMLER line) | `detail_view.gd:403, 509-525` |
| age | present **but it is product age labelled with the current version number** | `detail_view.gd:435-436` |
| last intent | **absent** (concept does not exist) | — |
| tech debt | **absent from every UI**; orphan CSV key `BUILD_TECH_DEBT` at `strings.csv:429` | — |
| support load vs capacity | **absent** | — |
| capacity headroom | **absent as a number** — only the yarı hız boolean suffix | `creation_flow.gd:860-861` |
| gross margin | **absent everywhere**; no serving cost exists to compute it against | see `04_finans.md` |

---

## 5. Depends on / depended on by

**Ürün depends on:**
- **Ekip** for the skill model (Geliştirme / Tasarım / Hız as real numbers rather than role tags) and, critically, for the **assignment layer** — §8 support-vs-build tension is unbuildable without one person, one job. Ürün cannot be finished before Ekip.
- **Operasyon** for serving cost (which needs usage weight from here), support load (which needs live bugs from here) and the Altyapı publish step. These two modules should be specified together; Operasyon has no tab and lives half inside this one.
- **Finans** only for the one-time cost seam, which already works.

**Depends on Ürün:**
- **Satış** — version age feeds interest and feature asks; bugs feed complaints; the whole B2C economy reads product quality.
- **Operasyon** — every one of its four forces takes an input from here (usage, bugs, debt, capacity).
- **Sonlar** — `mvp_shipped` gates the Traction transition.
- **Event** — nine authored events ride `build_phase`; the ship moment is a synthetic event.

**Can it be decided alone?** The pipeline half (intent, beta counter, discovery decay, publish flow) yes. The DESTEK half no — it is a joint decision with Ekip and Operasyon.

---

## 6. UI work

What has to appear, not how it is laid out.

**Konsept screen** (`creation_flow.gd`, steps 1-3 plus the commit card)
- A **version intent** choice for every version after v1: three options with their content and expected length, and a readable statement of the trade — a Kararlılık release holds quality but loses attention.
- **Price** as a Konsept field, pre-filled from the last version.
- **Team assignment** as a real picker, not a single lead: who is on the build, who stays on support, with the consequence of leaving support empty stated on the screen.
- Feature rows need a **usage weight** reading, so the player can see that a feature will cost money per user forever.
- The research slot needs an actionable state: which developer, how long, how much. Today the badge is inert.

**Build tracker / HUD / ODA monitor** (one widget, three hosts)
- A **fifth phase state, DESTEK**, with its own reading — not a progress bar, since support does not complete. Live bug inflow against the team fix rate is the honest pair.
- BETA becomes a **counter**: BULUNAN / ÇÖZÜLEN / KALAN, with the shape of the decay legible enough that it is slowing down reads without a chart.
- While a build runs and support is unmanned, the bar must say so. This is the surface that makes §8 felt.

**Publish flow** (new)
- Three steps: price · infrastructure (provider + capacity) · confirm. Pre-filled at each version, and the confirm carries the hata canlıya taşınır number **after** the critical-bug penalty.

**Ürün Monitörü** (`detail_view.gd`)
- Add: churn, satisfaction, interest/demand, tech debt (as a meter, not a boolean), support load vs capacity, capacity headroom, gross margin, last version intent.
- Fix: age must be **version** age, not product age; B2C needs a live MRR and a live paying-user count, not only projections; B2B needs its price shown.
- Rename: DENEYEN becomes Ücretsiz kullanıcı in the two CSV rows, the two render sites and the one event body.

---

## 7. Sizing

| Item | Size | Assumes |
|---|---|---|
| deneyen rename (2 CSV rows x 2 locales, 2 call sites, 1 event body) | hours | slot id renamed too, for hygiene |
| Ship-tooltip off-by-5 fix | hours | — |
| BETA bar becomes a counter | hours | the counters already exist on the HUD card |
| Beta discovery decay + inexhaustible pool | a day | includes re-tuning `BETA_BUG_FIND_PER_DAY` against a probe run |
| Version intent (field, Konsept UI, per-intent length and effect, monitor readout) | several days | interest reset needs a version-age number to reset |
| Version age as a real per-version number, read by interest | a day | |
| Per-feature usage weight + catalog re-author to 9 per subtype | a day | catalog re-author can ride the same pass |
| Research slot made real | a day | needs the assignment layer for assign a developer |
| Publish flow (3 steps, pre-filled) | a day | **excluding** Altyapı, which is `05_operasyon.md` |
| Price moves to Konsept and publish | a day | touches the pricing panel, so pair with the rename |
| DESTEK as a fifth phase (state, bar host, router) | several days | |
| Triage and patch loop (per-bug records or a validated-bug pool) | several days | |
| Support-vs-build contention | several days | **blocked** on the Ekip assignment layer |
| Tech debt as a number, fed by short design and shipping at cap | a day | |
| Monitor field additions | a day | each field needs its producer to exist first |
| Delete `pull` / `stakes` / `tags` dead fields | hours | |

---

## 8. Open questions for the director

1. **§8 [WORKING] — can a build be paused to put the team back on support?** The chapter direction is yes, keeping partial progress, with version age continuing to run. Confirm, because it adds a paused state to the build machine and a word to the bar vocabulary.
2. **§14 — team ceiling formula.** Still open from rev 3. Today it is `4.0 x founder tech + min(sum of role UZMANLIK x 2.0, 18.0)` (`product_system.gd:551-565`); it must be re-derived once the six-skill model lands.
3. **§14 — patch cadence: automatic, or an explicit Yama yayınla?** Decides whether DESTEK needs a button at all.
4. **§14 — does the B2C paid tier open automatically at first revenue, or by a played decision?** Today it opens as a side effect of the first price commit (`sales_system.gd:568`), and `ev_ps_b2c_paid_tier.json` is a one-option advisory that sets nothing. If it should be played, that event needs a real modifier.
5. **§2 versus the catalog.** The chapter asks for 9 features per subtype (3 per axis) with one research lock per axis; the catalog has 6 per subtype and 4 research locks in total. Confirm the re-author — it is content work as much as code.
6. **Which two B2B and two B2C subtypes ship?** (ch. 14 §8.) The catalog carries 10; the demo needs 4 and the rest locked-visible.
