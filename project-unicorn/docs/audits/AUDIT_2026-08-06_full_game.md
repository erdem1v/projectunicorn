# Full Game Audit — 2026-08-06

**Type:** READ-ONLY audit (no fixes, no refactors, no numeric tuning) · **Scope:** the whole game, surfaces 1-45 · **Deliverable:** this file only.

**HEAD:** `cb20a18cdd6bba4e512f119589f4f19b2128b1ad` (main, "debug: Font Duruşması type specimen") **+ uncommitted working tree** — the ODA quality round (v2.1) and everything layered on `b8bd29f` since. `THEME_STAMP = 4`; no stale-theme warning on debug boot.
**Duration:** ~7 h wall clock (15:24 preflight → 22:35 delivery), 2026-08-06.
**Runs executed:** 4 live runs across 4 world configurations + 135 headless smoke cases + 4 determinism probes + 50 screenshot harness invocations.

---

## Tree state at audit time

The audit measured a **frozen tree**. Newest non-`.godot` write at the start was `localization/strings.csv` at **15:40:03**; the same file was still the newest at **22:15**, unchanged. No source file was modified by this audit, and no other session wrote to the checkout during it.

Uncommitted layers present (all landed before the audit began): HR module + HR tab UI · Finance Tab v1 · task 2b (autonomous sales + MT request channel) · Tema Çekirdeği · HR/Finans F5 fixes + iteration restore + `ITER_*` ceilings · Dünya İnandırıcılığı (CompanyCatalog, market share, NewsFeedSystem) + its ticker/board binding · ODA merkez görünüm · ODA kalite fix v2.1.

**Read-only compliance:** zero source files modified · zero git commands run · zero new files in the tree except this report. Screenshot harnesses wrote to `user://` (outside the repo), which is the existing verification path. Every temporary artifact lives in the session scratchpad.

---

## Executive summary

**124 distinct findings: 0 S0 · 8 S1 · 57 S2 · 59 S3.** (131 findings were filed across nine work-streams — 133 entries less one verified design-intent and one cross-filed duplicate; seven more were the same defect found independently from two directions and are merged here, which is itself a blast-radius signal.) Two findings carry `[REBUILD-ARC]`.

Nothing crashes. Nothing softlocks. There is no S0 in this build — the run always completes, the clock never stalls in normal play, and the 135-case smoke suite is 135/135 green. What the inventory found instead is a game whose **engine is largely honest and whose surfaces frequently are not**, plus three places where a real economic rule leaks.

### The three root causes with the widest blast radius

**1. The event system has two doors, and only one of them has locks.** `EventManager.enqueue()` / `enqueue_front()` bypass every suppression the engine owns — the build-safe gate, `one_shot`, `cooldown_days`, `allowed_hours`, and the entire trigger set — and never write to `_history`; `_pump_queue` re-validates nothing before showing an event. **40 of the game's 71 live choices can only reach the player through that unlocked door.** Twelve of the fifteen callers hand-roll a private latch to compensate, in six different shapes; one caller has no latch that survives its own resolution, and that one caller is K2. Separately, `_history` records `{id, day, choice}` and `get_history()` has zero callers, so no content can know that it already happened — which is why a referral event fires three times with byte-identical fiction while the cooldown works exactly as coded. *(D1-03, D1-04 — both `[REBUILD-ARC]`.)*

**2. `mvp_market_type` gates the hourly path but never the daily one.** `SalesSystem.daily_tick` calls the entire B2B chain behind an `mvp_shipped` check with no market check, so **hiring one salesperson in a B2C run starts a full parallel B2B economy** — real leads, real contracts, real MRR, and the complete B2B lifecycle including K2. That mixed portfolio then unlocks a second class of bug: every default customer selector (`get_lowest_satisfaction_customer`, `get_min_satisfaction`) is market-blind, so a B2C consumer-support event can credit — or, through "Görmezden gel", **instantly delete** — a B2B enterprise contract, bypassing the visible churn countdown the B2B engine's own header calls inviolable. *(C-02, C-03, C-04, D1-06.)*

**3. Cost and benefit are charged on different clocks.** Overtime pay and morale are charged only in `HROvertimeSystem.daily_tick`; the speed multiplier is consumed hourly by the build. A block started and stopped inside one in-game day therefore delivers real speed for **$0 and zero morale** — two clicks, repeatable daily. The same split silently under-delivers every honest block by exactly the hour it was started. The code believes this is impossible: its justification comment describes a daily read that no longer exists anywhere in the tree. *(A-07, A-08.)*

Behind those three sits a fourth pattern that is not a single root cause but is the most *numerous*: **the UI asserts things the state contradicts.** The TopBar renders MRR $60,000 as "$6" (a clipped label, not a bad formatter). An effect chip promises "-$1K" and charges $1,500. The ODA monitor prints "SİSTEM SAKİN · UYARI YOK" four lines under "HATA 12". A decision card prints "Kararlılık 10 / tavan 8". The ending newspaper tells a player who never earned a cent that "there was revenue". A permanently disabled button is labelled "ZOR MOD AÇILDI" — *unlocked*, past tense. Each is small; together they are the reason a player cannot trust the numbers.

### If only one thing could be fixed: K2, the expansion loop

`_tick_healthy` tests a **monotone state** (`day − acquired_on_day ≥ 45`) instead of an **edge**, and both resolutions of the expansion event return the account to exactly the state that test passes — while `acquired_on_day` never moves. The event therefore re-fires **every day, forever**, on every matured account, through both branches. Reproduced live on two accounts across days 83-92: declining brought the identical event back the next day; accepting brought the "BÜYÜMEK İSTİYOR" badge back the next day.

It is the first fix because it is three bugs at once. It is an **economy break** — "Büyüt" carries no cash, satisfaction, or reputation cost and no cooldown, so a single matured mid-tier account is +6 seats and **+$720 MRR per day, indefinitely, for one click**, which is precisely the "permanently solve money" failure Calibration Law 1 exists to forbid. It is a **pacing break** — at 4× speed the run degenerates into clicking the same modal every day (observed 10+ consecutive daily pauses). And it is a **queue leak** — because the dedupe compares object identity and the factory returns a fresh event each call, unresolved copies accumulate without bound. The fix is contained (a per-account "last expansion" field and a latch), needs nothing from the event-rebuild arc, and has a deterministic repro.

### What surprised me

**Systems that are better than expected.** The B2B lifecycle is the strongest engine in the build: two-layer satisfaction, tolerance seeding, a visible churn countdown that recovery genuinely resets, and a promise ledger with kept/partial/broken resolution wired to satisfaction, tolerance, a decaying trust offset and brand. Its arithmetic is exact — a live run's brand moved 50 → 43, which is precisely 2 × (−2 churn) + 1 × (−3 broken promise), landing at the real moments and not at the choices. The news mixer hits 0.503 / 0.297 / 0.200 against 50/30/20 targets over 90 days with a provably correct look-ahead cap. The pause/restore state machine survived dozens of cycles including queue chains and a modal stacked over another modal. **K1 turned out to be stale as reported**: the promise machinery exists end-to-end and works; its real residue is a UI gap, not a missing system.

**Load-bearing in a way nobody planned.** Two things: `EventManager._history` is the only memory the game has of what a player decided, and *nothing can read it* — the player is the only entity in the system that remembers. And **process relaunch is load-bearing infrastructure**: the codebase relies on an OS restart to clear roughly twelve owners of static state, which is exactly the job the mandatory SaveManager will inherit. The one in-place restart that exists (Shift+F4) already demonstrates the failure — taken with a modal open it strands the active-event id, which kills the event pipeline for the life of the process and silently suppresses every other modal's speed restore.

**A correction to my own evidence.** My determinism probe reported byte-identical fingerprints across four runs, and I initially presented that as proof of tick purity. It is weaker than it looked: the probe never ships a product, so its B2C economy never ticks, and its build parks at the iteration gate on day 3 — from day 4 the fingerprint is a constant plus a daily sum, identical *by construction*. Tick purity and same-seed reproduction still pass; the RNG-sequence half of the claim has never been instrumented. It is filed as a finding against the instrument (A-13), not quietly dropped.

---

## Coverage map

All 45 surfaces from the task's §4 were visited. A surface marked CLEAN was traced to its readers, not skimmed.

| # | Surface | Result |
|---|---|---|
| 1 | Onboarding (pages, skill allocation, locked origins, confirm path) | **FINDINGS (11)** |
| 2 | Time engine (day/hour advance, speed ladder, pause) | **FINDINGS (1)** |
| 3 | Daily tick dispatch (slot order, dependencies) | **FINDINGS (4)** |
| 4 | Hourly tick dispatch | **FINDINGS (4)** |
| 5 | Cash / runway / burn derivation chain | **FINDINGS (4)** |
| 6 | `burn_breakdown` categories | **FINDINGS (1)** |
| 7 | MRR accrual / push / pull | **FINDINGS (3)** |
| 8 | Founder burn, salary total, overtime cost | **FINDINGS (3)** |
| 9 | Runway boundaries (zero cash, negative net, zero employees) | **FINDINGS (4)** |
| 10 | HR search flow (bands, generation, salary spread, non-dominance) | **CLEAN** |
| 11 | Hire / decline / take-none (fees, refunds, confirm stacking) | **FINDINGS (2)** |
| 12 | Raise / vacation / fire (state writes, morale, ledger) | **CLEAN** |
| 13 | Overtime blocks (cost, morale, night forcing) | **FINDINGS (1)** |
| 14 | The three axes + founder traits | **FINDINGS (2)** |
| 15 | Attention flags / badges | **FINDINGS (1)** |
| 16 | Product creation flow | **FINDINGS (2)** |
| 17 | Build phases (Tasarım → Geliştirme → Beta → ship) | **CLEAN** |
| 18 | Iteration loop (rounds, effort, park, diminishing returns) | **CLEAN** |
| 19 | Quality axes and the ceiling formula | **FINDINGS (1)** |
| 20 | Ship moment (world state + every consumer) | **CLEAN** |
| 21 | B2B (prospects, dedup ledger, pitch, close, terms) | **FINDINGS (6)** |
| 22 | B2C (repeat behaviour) | **FINDINGS (4)** |
| 23 | Autonomous sales + MT request channel | **FINDINGS (2)** |
| 24 | Retention / expansion / churn incl. "Kendi haline bırak" | **FINDINGS (6)** |
| 25 | Customer health states and transitions | **FINDINGS (3)** |
| 26 | Finance tab (every number traced to a live source) | **FINDINGS (3)** |
| 27 | ARTIDA / negative states / formatting | **FINDINGS (2)** |
| 28 | "TUR AÇ · SERIES A" locked-only in demo | **CLEAN** |
| 29 | Event engine (pool, triggers, repeat bans, cooldowns) | **FINDINGS (6)** |
| 30 | Every event's every choice (the dead-choice sweep) | **FINDINGS (10)** |
| 31 | Event timing (hourly, day boundaries, modals, pause) | **FINDINGS (4)** |
| 32 | Character context binding | **FINDINGS (2)** |
| 33 | NewsFeedSystem + ticker | **FINDINGS (3)** |
| 34 | RivalRegistry / market share | **FINDINGS (3)** |
| 35 | Registries (customer / character / prospect / promise) | **FINDINGS (5)** |
| 36 | 65-company / 13-sector world | **FINDINGS (2)** |
| 37 | ODA (anchors, papers, monitor, ✕) | **FINDINGS (4)** |
| 38 | Tab navigation + `milestones` pseudo-tab | **FINDINGS (3)** |
| 39 | Modals and dialogs (open, close, ESC, stacking, focus) | **FINDINGS (5)** |
| 40 | Pause-gated UI (`process_mode`) | **FINDINGS (2)** |
| 41 | Save / load | **FINDINGS (2)** |
| 42 | Signal hygiene | **FINDINGS (7)** |
| 43 | Stale callers (Green Tree Rule) | **FINDINGS (4)** |
| 44 | Determinism | **FINDINGS (3)** |
| 45 | Localization | **FINDINGS (7)** |

No surface was BLOCKED. Surface 28 is CLEAN as a **demo** contract: "TUR AÇ · SERİES A" renders greyed and non-interactive, and the Yatırım sub-page is phase-3 gated.

---

## Method

**Code reading** was the primary instrument — every finding below is anchored to `file.gd:line` re-verified against the live tree, and every claim of a dead write was traced to the *absence of a reader*, not merely to the write.

**Nine parallel work-streams**, each inheriting the same read-only contract and evidence format: economy/ticks · HR+product · sales/customers · event engine · the dead-choice sweep · world/news/rivals · shell/ODA/modals · cross-cutting (signals, stale callers, determinism, localization) · onboarding. Findings were merged centrally and deduplicated by root cause.

**Smoke suite:** 135 cases, count scraped from source (not memory), one process per case, 30 s per-case timeout — **135/135 PASS**, no warnings or errors in any case log. Two findings are filed *against the suite itself* (A-13, A-14): no case reproduces the engine's real daily/hourly interleave, which is precisely why the two overtime bugs pass 135/135.

**Screenshot harnesses:** 50 invocations across every kind (`--oda-shot` ×4, `--tab-shot` ×8, `--hr-shot` ×6, `--product-shot` ×4, `--finance-shot` ×3, `--modal-shot` ×3, `--onboard-shot` ×3, `--ending-shot` ×10, `--b2b-shot` ×3, `--event-shot` ×3, sales, pitch, probe). **Every PNG was read**, not merely produced — several findings exist only because a rendered frame contradicted the code.

**Four live runs**, all decisions made through real input paths (OS-level clicks on choice cards, keyboard for dialogue scenes, the real dismiss handlers for modals):

| Run | World | Depth reached | What it produced |
|---|---|---|---|
| **V** | vanilla, seed 424242 (pinned) | day 1 → **180**, terminal reached | burn exact at $50/day for 180 days; 5 month summaries on true calendar boundaries; **zero reactive events in 180 days**; `running_on_fumes` fired at day 180 with cash still positive |
| **B2C** | shipped B2C (fabricated levers, organic engine after) | ~day 46, MRR 0 → 1,020 | **K3 and K4 both reproduced live**; paid-tier beat fired with the tier already open; real brands in live copy |
| **B2B** | shipped B2B, organic pitches | ~day 121, 2 signed → 2 churned | **K2 reproduced on both branches**; promise created, broken, and priced exactly; brand arithmetic exact |
| **D** | control (real-boolean seeding) | day 96, **3 concurrent customers**, 5 employees | resolved the frank-intro question decisively; phase gate 1→2 verified end-to-end |

**Determinism probes:** `--tempo-probe` at speeds 1, 1, 3, 4 — wall-clock within TECH_SPEC tolerance and fingerprints byte-identical, with the honest caveat recorded above and filed as A-13.

**Two corrections to my own working notes** are recorded in the inventory rather than silently dropped: a "silently swallowed pitch request" that turned out to be my own malformed prospect id (retired as a negative result, F-14), and a flag-typing claim I first asserted, then retracted, then re-established by controlled experiment with the reachability analysis that makes it a save/load constraint rather than a live bug (G-13 note / Group 9).

Three briefing numbers I supplied to the work-streams were **wrong and were corrected by the people I gave them to**, which is recorded here because an audit that hides its own errors is worth less than one that does not: the event bus declares **64** signals, not 77; the runtime `process_mode` assignments number **7**, not 8; and the "synthesized minute" theory for event timestamps was wrong — the minutes are static strings in the event JSON, which is simpler and worse.

---

## Phase A — Inventory

Sorted S0 → S3, and within a level by blast radius. Every entry carries location, repro, expected/actual and a confidence label. `CONFIRMED` = reproduced in a live run **or** traced end-to-end from write to reader. `SUSPECTED` = code-read only, stated as such.

### S0 — crash / softlock / progress-blocking

**None.** Four runs to depth (one to the day-180 terminal), 135/135 smoke, 50 harness invocations: no crash, no softlock, no unreachable progression. Stated as a result, not a gap.

---

### S1 — wrong state (the numbers lie, or a decision does nothing)

#### S1-1 · K2 · The expansion event re-fires every day, forever, through both branches — and "Büyüt" is an unbounded free MRR pump · CONFIRMED
**Surfaces** 24 (blast radius 21/23/25/29) · **Root cause shared with** S1-2's engine half · charter C-01 + D1-03 row 3.
**Location** `scripts/systems/b2b_sales_system.gd:206-219` (`_tick_healthy`, promotion at `:216-219`) · `:310-324` (`expand()` → phase back to `"active"` at `:323-324`) · `:327-332` (`decline_expansion()` → same at `:331-332`) · `scripts/autoload/event_manager.gd:171-184` (`enqueue` bypasses cooldown/one_shot by design) · `:180` (dedupe is `Array.has` on an Object = reference identity) · `scripts/systems/b2b_event_factory.gd:62` (`GameEvent.new()` per call defeats it) · second unlatched path `scripts/tabs/sales_tab.gd:360-362` · static input `Customer.acquired_on_day` (`scripts/data_models/customer.gd:39`, written once at `sales_system.gd:292`, never moved).
**Repro** 1) Ship B2B, sign an account. 2) Advance to signing-day + 45 with satisfaction ≥ tolerance. 3) "Büyüme fırsatı" fires — pick **either** choice. 4) Advance one day: the identical event fires again. Repeat forever. *Live:* run B2B, days 83-92, both accounts, both branches.
**Expected** An expansion opportunity is a once-per-maturity-window moment; declining settles the account for a cooling period, accepting restarts the clock.
**Actual** A daily, permanent, cost-free MRR faucet plus a daily forced modal.
**Root cause** `_tick_healthy` tests a *monotone predicate* (`day − acquired_on_day ≥ 45`), not an edge; both resolutions restore the exact state that predicate passes; nothing records that an expansion moment happened (`Customer` has no such field, and `run_customers_expanded` is a run total never read back as a latch). All four conditions — monotone test, un-latching resolutions, `enqueue`'s bypass, identity dedupe — are required, which is why expansion is the only looping caller of fifteen.
**Reader-chain** `_tick_healthy` → `set_lifecycle_phase` (emits) → Sales-tab "BÜYÜMEK İSTİYOR" badge **and** ODA desk paper (`oda_view.gd:1297-1302`, one per expansion account) **and** `enqueue` → modal → `expand()` → `set_seats`/`set_mrr` → `reflect_mrr` → TopBar/runway/Finance. Player-visible at every hop.
**Economic weight** "Büyüt" carries no cost modifier at all (`b2b_event_factory.gd:74-77`): +`expansion_seats` seats and +seats × `EXPANSION_PER_SEAT_MRR` (120) MRR per day per matured account — +6 seats / +$720 per day for a mid-tier account, indefinitely, for one click. Calibration Law 1's named failure mode, and inside the task's explicit balance carve-out ("a value that produces a BROKEN state: infinite money").

#### S1-2 · The entire B2B desk runs inside a B2C market — one hire mints enterprise contracts in a consumer game · CONFIRMED (traced end-to-end; not live-reproduced)
**Surfaces** 23/21/22 · charter C-02.
**Location** `scripts/systems/sales_system.gd:91-99` — `daily_tick`'s only gate is `if GameState.get_flag("mvp_shipped", false)` (`:94`); `B2BSalesSystem.daily_tick()` is called at `:96` with **no `mvp_market_type` check**, while `hourly_tick` (`:104-110`) *does* branch on market · `scripts/systems/b2b_sales_system.gd:23-43` · `sales_rep_system.gd:32-38` and `customer_rep_system.gd:180-185` (both gate on headcount only) · `hr_constants.gd:92` (both commercial roles offered in every run).
**Repro** 1) Build and ship a B2C sub-product (`ai_assistant`). 2) Hire a Satış Uzmanı. 3) Advance ~10-20 days. → B2B prospect cards for İnşaat/Lojistik/Sigorta companies appear in a consumer run, and MRR rises from a signed contract with no pitch ever played.
**Expected** The B2B desk is inert in a B2C market (or the role is not offered).
**Actual** A full parallel B2B revenue economy and lifecycle — including S1-1's expansion loop and enterprise retention modals — inside a consumer-app run. The sector affinity falls through to the 8-sector fallback because a B2C sub-type is not a key in `SECTOR_AFFINITY`, so real B2B leads are minted from the B2C product's own feature pool.
**Root cause** `mvp_market_type` gates the hourly path and the Sales-tab layout but was never added to the daily dispatch; Task 2b's two rep systems were bolted onto `B2BSalesSystem.daily_tick` and inherited its `mvp_shipped`-only gate.
**Reader-chain** `SalesRepSystem._close` → `add_b2b_customer` → registry + Finance transaction + `_mrr_bridge` → TopBar / runway / Finance "SON İŞLEMLER". Player-visible.
**Note** This is the *enabler* for S2-1 (market-blind targeting): without it, a mixed portfolio is unreachable.

#### S1-3 · Overtime started and stopped inside one day is free build speed — $0 pay, zero morale · CONFIRMED (traced end-to-end)
**Surfaces** 3/8/13 · charter A-07.
**Location** `scripts/systems/hr_overtime_system.gd:72-114` (`daily_tick` → `_tick_department` is the **only** place pay `:105` and morale `:103` are charged) vs `:153-161` (`stop()` → `_end_block` erases the record, and `:166-168` documents that the record's *presence* is the running state) vs `scripts/systems/product_system.gd:457` (the multiplier is consumed **hourly**). UI reachability: `scripts/tabs/hr/hr_overtime_panel.gd:93` (start) and `:117` (stop) — two clicks.
**Repro** 1) ≥1 product_dev employee, a build in development. 2) HR → Ek mesai → start a block at ~10:00. 3) Let ~10 in-game hours pass (6.25 real seconds at 4×). 4) Press "Bitir" before midnight. 5) Repeat daily.
**Expected** Overtime costs money and morale for every day of speed bought — the played-cost principle `can_start`'s own comment invokes (`:123-127`).
**Actual** The build accrued effort at ×1.30 for ~10 hourly ticks and the player paid nothing: `burn_breakdown["overtime"]` stays 0 and participant morale is untouched, because the next daily tick finds an empty `hr_overtime` and returns at `:79-80`.
**Root cause** Cost is charged on a daily boundary; benefit is consumed on the hourly tick. Any block whose whole life fits between two daily ticks bills zero. The code explicitly believes this is impossible — `:200-202` argues "a start-and-stop inside one day is a pure loss… slot 1 has already run, so no speed is gained" — but that depends on a **daily** slot-1 read of `speed_multiplier` that no longer exists anywhere in the tree.
**Why the suite is silent** `endgame_smoke.gd:4110-4132` performs this exact sequence (start → 24 hourly ticks → `stop()`) and asserts only that the multipliers reset. See S2-38.

#### S1-4 · Founder traits are a dead onboarding choice whose copy states concrete mechanics · CONFIRMED
**Surfaces** 14/1 · charter B-01.
**Location** `scripts/systems/founder_constants.gd:37-48` (catalog + the RESERVED comment) · `localization/strings.csv:50-64` (the effect strings) · grep-verified zero readers.
**Repro** Pick "Disiplinli" (effect shown: *"Geliştirme süreleri kısalır"*) and accept the forced negative at two positives (e.g. "Mikroyönetici — Ekip morali daha hızlı erir"). Play any build, any morale event. Grep the tree for the eight trait ids: outside onboarding the only hits are smoke validations of the *selection formula* and fixtures.
**Expected** Chosen founder traits modify something — the strings promise build speed, morale erosion, even R&D frequency, in the indicative mood.
**Actual** No system reads any founder trait id. `Character.traits` on the founder is written and never consumed. **Employee** traits do work; the founder catalog does not.
**Root cause** `FounderConstants` marks the effects RESERVED ("wiring real modifiers is a separate backend task") — but the onboarding UI carries none of the game's "KİLİTLİ / yakında" telegraph grammar, so the player reads live promises. One trait even implies the unbuilt R&D system.
**Severity note** Filed S1 as a dead choice the player is told is live. Ambiguity acknowledged: the code marks it design-pending — but the pending-ness is invisible to the player, unlike every other Coming-Soon lock in the game.

#### S1-5 · "Oyala" past its hidden 2-use cap charges brand −1 and does nothing · CONFIRMED
**Surfaces** 30/24 · charter D2-01.
**Location** `scripts/systems/b2b_sales_system.gd:262-263` (early return) · `scripts/systems/b2b_constants.gd:52` (`RETAIN_DELAY_MAX_USES := 2`) · `scripts/systems/b2b_event_factory.gd:40-43` (the choice is built unconditionally with `brand −1` riding).
**Repro** Same account crosses into Risk a third time (or the player re-opens retention via the Sales tab's "İlgilen →", which is unlatched — see S2-12) after two prior "Oyala" picks. The card renders identically: "Kısa vadeli hamle" + "Marka −1". Pick it → `hold()` hits its cap and returns without incrementing `retain_stalls` or extending the countdown, while the separate `brand` modifier still applies.
**Expected** A capped stall is telegraphed (locked, relabelled, or at minimum a changed badge), or it costs nothing.
**Actual** The player pays brand −1 and receives nothing; nothing on the card, in the body, or in any log says the customer stopped falling for it.
**Reader-chain** brand → `set_brand` → TopBar (the cost is real and visible) · countdown → **not written** (no reader ever sees a change). This is the sweep's "costs a resource and returns nothing measurable" fail condition.

#### S1-6 · A promise outlives the customer it was made to, and still charges brand when it breaks · CONFIRMED
**Surfaces** 35/24 · charter E-04.
**Location** `scripts/autoload/promise_registry.gd:88-104` (`tick_deadlines` has no customer-liveness check) · `scripts/systems/b2b_sales_system.gd:231-238` (`_remove_lost` never touches PromiseRegistry) · `:375-385` (the "broken" branch — `GameState.set_brand(...)` at `:384` and the `b2b_broke_<id>` flag write at `:385` sit **outside** the `if c != null` guard that protects every customer-side write at `:378-383`).
**Repro** 1) Sign a B2B account. 2) Let it slide to Risk; take "Söz ver" → a Promise is created (verified live in run B2B). 3) Do not build the feature. 4) Let the account churn *before* the deadline. 5) Wait for `deadline_day`.
**Expected** The promise dies with the account; the churn brand hit is the whole price.
**Actual** The orphan still resolves to "broken", emits `promise_broken`, and applies a second brand hit for a company that no longer exists on any screen. Meanwhile the Product tab keeps rendering `SÖZ VERİLDİ · **Müşteri** · <feature> · N gün` — the literal fallback at `detail_view.gd:462-465`, because the customer lookup returns null — counting down for a company that left days ago.
**Reader-chain** Both ends reach the player: a promise row for a ghost customer, and a brand drop with no event, no modal and no attributable cause.
**Live corroboration** Run B2B's brand arithmetic (50 → 43) is exact, so nothing double-fired there — but only because the promise happened to break *before* the account churned. The reverse ordering is unguarded.

#### S1-7 · `is_auto_closable` returns true when the lead has no mapped pain — the §10 concession gate opens on the most uncertain case · CONFIRMED
**Surfaces** 23 · charter C-03.
**Location** `scripts/systems/sales_rep_system.gd:130-133` — `if p.pain_feature_id == "": return true`, before `mvp_components` is ever consulted.
**Repro** Any path that yields an empty `pain_feature_id` (`b2b_sales_system.gd:391-395` returns `""` when the sub-type id is empty or its feature pool is empty — both reachable, including via the `add_prospect` event modifier), then let a hired rep warm the lead to `AUTO_CLOSE_PROGRESS`.
**Expected** An unmappable pain is the *conservative* case → route to the founder's played pitch, because the rule the comment states is "if the pain maps to a feature the product has NOT shipped, closing it means promising it — and giving the company's word is the founder's act."
**Actual** It is the *permissive* case → autonomous close, with `mvp_components` never checked. The §10 gate opens precisely where the engine knows least.
**Note** Smoke `sales_concession_deal_surfaces` covers only the non-empty branch, so the suite is green on a gate with an open side.

#### S1-8 · The `mrr` modifier is a documented, badged phantom with no apply branch · CONFIRMED (latent)
**Surfaces** 30 · charter D2-02.
**Location** Badge `scripts/modals/event_modal.gd:419` · documented shape `scripts/data_models/event_choice.gd:13` (`{"type": "mrr", "delta": -500}`) · `scripts/autoload/event_manager.gd:386-603` `_apply_modifiers` has **no `"mrr"` case** and falls through to the `push_warning` default at `:602-603`.
**Repro** Author any choice per the data-model docstring → the modal renders a coloured "MRR −$500" chip; on resolve the modifier no-ops with only a debug warning.
**Expected** Vocabulary that exists in the data-model contract *and* in the badge table exists in the dispatcher — or in neither.
**Actual** The badge and the docstring promise an economic delta the engine cannot apply. (A raw `GameState.mrr` write would anyway be reverted by the MRR bridge; the correct route is `customer_mrr_delta`, which exists and is badged.)
**Why it is filed** Zero live content uses it today, so no live dead choice — this is the loaded trap, and it is the same class as the K3 finding: **the modal will happily badge what the engine cannot do.**

---

### S2 — visibly wrong behaviour

Grouped by root cause. Every entry is CONFIRMED unless marked otherwise.

#### Family A — the display contradicts the state (12)

**S2-1 · TopBar MRR is clipped: $60,000 renders as "$6".** `scenes/ui/components/TopBar.tscn:82-86`. The formatter is innocent — `UiTokens.format_money_chip` returns "$60K" correctly. `StatCol_MRR/ValueLabel` sets `clip_text = true` **without** a `custom_minimum_size`, so Godot forces min-width 1 and the column collapses to the width of its 9 px "MRR" caption; everything past ~2 glyphs is cut. `StatCol_Cash` has the same `clip_text` **plus** `custom_minimum_size = Vector2(104, 0)` at `:56`, which is why cash renders in full. Three screenshots catch the TopBar and the Finance "Gelir" row (both rendering `GameState.mrr`) in one frame: **$1** vs +$1.9K · **$4** vs +$4.0K · **$6** vs **+$60.0K**. Four more live confirmations across two runs. Every other TopBar cell carries no `clip_text` and is clean. *MRR is the primary traction metric and a phase-gate/ending input.*

**S2-2 · Effect chips understate money by up to a third: −$1,500 renders "NAKİT -$1K".** `scripts/modals/event_modal.gd:507-512` — `int(abs_v / 1000)` truncates. Shot-verified on `ev_ps_bug_complaint`'s "İade + özür dile" (JSON delta `-1500`), and numerically confirmed live (cash 6,500 → 4,881 across the choice plus six daily nets). Systemic: the same formatter feeds the retention-discount chip (15 % of MRR) and the expansion chip (seats × $120). The chip is the single source of cost truth per the EFFECT-VISIBILITY RULE.

**S2-3 · A decision card prints "Kararlılık 10 / tavan 8" with no qualifier.** `quality_model.gd:64-67` binds the ceiling **only** to iteration-round gains (`product_system.gd:584-604`, scope stated at `:589-590`); the commit stamp, event `dimension_delta`, the PM bonus, the strengthen bonus and v2 inheritance all sit outside it by design. Per-path verdict: iteration rounds **hold**; the other five **can exceed**. So the task's surface-19 requirement ("cannot be exceeded through any path") **fails as stated** — but the engine is internally consistent and self-documented, so the defect is the **display**: shot-confirmed "Kararlılık 10 / tavan 8" on `product_shot_tracker.png`, and the intro event teaches "tavanı ekip belirler" while the number on screen already exceeds it. Rendered in two UI sites plus the event copy.

**S2-4 · The ODA monitor prints "SİSTEM SAKİN · UYARI YOK" four lines under "HATA 12".** `scripts/ui/oda/oda_view.gd:920-922` — both arms of the outer ternary return `ODA_MONITOR_CALM`, so the `bugs == 0` term can never change the output and `ODA_MONITOR_WARN` is near-unreachable. With stability 70 the "healthy" test holds up to **43 live bugs**, so the monitor claims "no warnings" across that entire range. Shot-verified on `oda_shot_day.png` (the default screen).

**S2-5 · "ZOR MOD AÇILDI" labels a permanently disabled button, on every ending.** `scripts/modals/ending_scene.gd:362-367` (`disabled = true`, tooltip "Yakında") · `localization/strings.csv:146`. The label is past-tense — *unlocked* — and its own tooltip contradicts it. Visible in all ten ending shots. **This retires the open design question** raised during the live run ("is the hard-mode unlock ending-agnostic?"): there is no unlock, on any ending, ever. *(Filed independently by two work-streams — A-04 and F-03 — merged here.)*

**S2-6 · The "Running on Fumes" ending tells a $0-revenue run that revenue existed.** `scripts/systems/endings_copy.gd:330`. `_fumes` builds its ledger pool with three *conditioned* lines (`:326`, `:328`, `:331`) and one **unconditioned** line at `:330` — "Gelir vardı, ama ne kâr ne de yeni bir tur için yeterliydi." `_assemble` tops the pool up to `MIN_LEDGER_LINES = 4`, so on a zero-activity run the false line is **guaranteed** to render. Reproduced live in run V, printed directly under a stat row reading **MRR $0**. The sibling `_bootstrap` ending carries the same shape but is unreachable below a revenue floor, so it cannot lie. *This is the demo's conversion screen.*

**S2-7 · Event subtitles assert a clock the TopBar contradicts 40 px away.** The `· HH:MM` in an event header is a **static string in the event JSON** (`ev_ps_bug_complaint.json:6` = "Destek kutusu · 16:48"), copied verbatim by the loader and rendered by `event_modal.gd:166-169`; the engine has no minute concept at all. `top_bar.gd:188` renders the live hour in the same frame. Shot-proof: `oda_shot_event.png` shows TopBar **09:00** beside modal **11:14**. *The authoring discipline is otherwise real and should be preserved — all 13 windowed stamps sit inside their own `allowed_hours`, and all 3 clock-less beats correctly omit the clock.* Deviation is bounded by window width, up to ±9 h.

**S2-8 · The same build's progress renders two different percentages on screen at once.** `scripts/tabs/product/portfolio_view.gd:155` uses `round()`; `scripts/ui/components/build_hud_panel.gd:178` uses `floor()`; both read the single source `product_system.gd:395-399`, and the floating HUD is visible over any open tab page. At `build_progress() = 0.4761` the portfolio badge reads **%48** while the HUD reads **%47**. No shared formatter exists for build percent, unlike every other derived display in the codebase. *(Found by the duplicate-information merge, not by any single work-stream.)*

**S2-9 · Runway reads "0 ay" with six days of cash left.** `ui_tokens.gd:480-486` renders `str(int(round(months)))`, so cash $8,597 against −$1.4 K/day (0.20 months ≈ 6 days) prints a bare **0**, which reads as insolvency while the company is solvent for most of a week. Live screenshot, run D. Same frame lights the Finance rail badge.

**S2-10 · Runway ignores the sign of cash, so "ARTIDA" can render while the bankruptcy counter runs.** `scripts/autoload/game_state.gd:273-289` branches only on `daily_net`; neither branch asks whether cash is negative. Reachable because `apply_one_time_cost` has no affordability gate (documented at `finance_system.gd:126-127`) and a build commit costs $500-$2,000 against a $10,000 start. A net-positive company that commits a build it cannot afford lands at cash < 0 with net ≥ 0 → the shutter counter starts and the TopBar paints **`KEPENK: 7 GÜN`** in red two cells from **`RUNWAY Artıda`** in green, while the Finance tab spells it out: *"Gider gelirin altında; kasa erimiyor."* — with the treasury below zero. Variant (b): cash < 0 and net < 0 prints a negative month count. **SUSPECTED** — traced write → derive → format → paint, not yet caught in a screenshot; run request filed.

**S2-11 · The Finance transactions log books a signing's monthly MRR as a cash movement.** Write `scripts/systems/sales_system.gd:319-322`, render `finance_ozet_view.gd:506-534`. `İşe alım −$600` is real cash; `Ferrum Endüstri +$1,100` is the customer's **monthly MRR** — not one dollar entered the treasury at signing. Both render identically (signed, coloured, no unit) in a card that sits directly under the cash curve. The write site admits it in a comment. Shot-verified.

**S2-12 · "Bu ay nakit akışı" is a run-rate projection, not month-to-date.** Title `finance_ozet_view.gd:251`, data `finance_system.gd:223-230`. `tab_shot_finance.png` shows the 5th of April with a full 30 days of flow while "SON İŞLEMLER" beside it reads "Henüz işlem yok". The data function's own comment says "run-rate", so this is a labelling drift at the UI edge. *(Cross-check performed: the daily and monthly presentations agree exactly at three independent artifact points — the arithmetic is sound.)*

#### Family B — event engine (7)

**S2-13 · `enqueue` / `enqueue_front` bypass every suppression the engine owns · `[REBUILD-ARC]`.** `scripts/autoload/event_manager.gd:171-201` runs four checks (`run_active`, null, identity dedupe, active-id) and skips the build-safe gate, `one_shot`, `cooldown_days`, `allowed_hours` and the entire trigger set; neither injector writes `_history`, and `_pump_queue` (`:623-635`) re-validates nothing. **40 of 71 live choices can only arrive this way.** Complete caller inventory with substitute latches: **12 of 15 carry a correct private latch, 2 are deliberately unlatched player actions, 1 has none that survives its own resolution** (expansion → S1-1). The declarative JSON vocabulary is therefore unavailable to 56 % of the game's choices, and six systems re-invent suppression in six shapes. *Tagged as architecture, not as fifteen callers: there is no "add the missing guard" on this path because the guard surface does not exist.*

**S2-14 · `_history` records an index and nothing else, so events repeat with identical fiction · `[REBUILD-ARC]`.** `event_manager.gd:34` + `:162` (the single append) + `:232-234` (`get_history()` — **zero callers**). Live: `ev_ps_referral_b2b` fired days 48 / 61 / 79 against `cooldown_days: 12` — *the cooldown worked exactly as coded* — and on days 61 and 79 the same GM opens the same email with the same sentence, with no acknowledgement that the founder already said yes and already paid $400. Same shape for the complaint event at days 32 / 40. **The distinguishing test applied:** can the fix be written in existing vocabulary? Paid-tier (S2-15) → yes → wire. Remembering a prior acceptance → no key to write, no reader to read it → architecture.

**S2-15 · `ev_ps_b2c_paid_tier` fires with the tier already open, narrating "nobody pays yet" while MRR flows.** `data/events/reactive/ev_ps_b2c_paid_tier.json:10-13` — the whole trigger set is `market_type` + `audience_above 15`; there is no not-open guard. Reproduced live (run B2C, day 33), ~10 s after the first-revenue beat, body text reading *"kimse para vermiyor — çünkü daha istemedin"* against live MRR. **The obvious one-line fix is a trap:** `flag_equals … value:false` evaluates `null == false` → false and would gate the event off forever, because the flag is only ever written `true` and "closed" is *absent*, not false. Only `value:null` works, and only by an implicit contract. Beat ordering vs `first_revenue` is priority-accidental (8 vs 6); no dependency vocabulary exists.

**S2-16 · Every default customer target is market-blind: a B2C event can delete a B2B contract.** `event_manager.gd:538-542` and `:505-517` resolve to `CustomerRegistry.get_lowest_satisfaction_customer()`; that selector and `get_min_satisfaction()` (`customer_registry.gd:93-111`) filter on `status` only, never `market_type`. So in a mixed portfolio (reachable via S1-2) the consumer-support event `ev_ps_bug_complaint` can be *armed* by an unhappy B2B account, can land its satisfaction bump on that account, and — via "Görmezden gel" → `churn_customer` — takes the B2B branch and **removes the contract outright**: no risk streak, no countdown, no retention decision, none of the visible machinery the B2B engine's header (`b2b_sales_system.gd:13-14`) calls inviolable. `_resolve_customer_target` supports `primary_b2b` but has no B2C selector, and `churn_customer` accepts no target at all.

**S2-17 · `flag_set` tests key presence, not truth; and the vocabulary has no negation.** `event_manager.gd:257-258` → `has_flag`. A flag explicitly set to `false` still satisfies it — live instance `ev_mvp_dev_002_tech_debt_callout.json:11`, whose own choice 1 sets that key to `false`. **Latent, not live:** the event is `one_shot` and is the only `flag_set` user, so the mis-read is masked. It becomes live the moment any non-one_shot event uses `flag_set`. Related: there is no `flag_unset` / `flag_not_equals` / `not` and no OR in the AND-loop, which is the vocabulary hole behind S2-15.

**S2-18 · Shift+F4 leaves the entire EventManager alive; taken with a modal open it kills the event pipeline for the process.** `event_manager.gd:32-47` (five state vars) · `game_state.gd:419-534` (`initialize_run` contains **zero** EventManager references) · `main.gd:1737-1768` · `game_shell.gd:56-63`. Unlike its four siblings, Shift+F4 has **no ModalLayer guard**: pressed with an event modal up it frees the shell without resolving, so `_active_event_id` stays set forever → `_pump_queue` returns early on every call (no event modal ever mounts again) and `has_pending()` is permanently true, so the settings, confirm and month-summary dismiss handlers all skip their speed restore forever, leaving the game paused. In run 2, `_history` also survives, so all 12 one-shot beats stay consumed. `EventManager` has no `reset()` at all. Debug-gated — but this is the daily mockup workflow.

**S2-19 · Manual Sales-tab triggers re-open an exclusive decision without limit.** `scripts/tabs/sales_tab.gd:339-341` (retention) and `:360-362` (expansion) — the only guard is `EventManager._active_event_id == ""`, a UI script reading a private engine field. The engine's own retention enqueue *is* latched to one decision per risk episode; the button breaks that contract, letting a player harvest three of four options from one moment and, past the hidden cap, pay brand −1 per click (this is what makes S1-5 easy to hit).

#### Family C — sales, customers, retention (9)

**S2-20 · B2C satisfaction is frozen in two of its four regimes — the mechanical reason the complaint event never self-heals.** `scripts/systems/sales_system.gd:333-347`. The whole B2C health model is two ±1 terms (`stability ≥ 70` → +1; `bugs > 5` → −1), so **stability < 70 with ≤ 5 bugs nets exactly zero** — the ordinary mid-game state of a decent product, in which *no player lever moves B2C satisfaction at all*. Since `get_min_satisfaction()` is the sole input to the `customer_satisfaction_below` trigger, a run seeded under 60 has `ev_ps_bug_complaint` **permanently armed**, re-firing at exactly its 8-day cooldown forever — which is precisely the live K4 repro (day 32 → day 40, identical copy). Second defect in the same six lines: **bugs are counted twice**, because the stability input already folds bugs in via `effective_stability`. The B2B engine documents avoiding exactly this.

**S2-21 · Repeatable "once-in-a-lifetime" B2C beats compound the audience without bound.** `ev_ps_b2c_producthunt.json` (cd 10) and `ev_ps_power_user_b2c.json` (cd 12), both `one_shot: false`, with trigger terms that are **monotone once satisfied** — and `convert_audience` actively grows the audience the threshold tests. So a launch beat that in fiction happens once re-fires every ~10-13 days for the rest of the run with byte-identical copy, each time adding 25 % of the current audience. Same class as K4, opposite sign: a permanent positive faucet. Together the two are the whole of surface 22's repeat problem.

**S2-22 · A promise can be created for a feature the product already ships.** `b2b_event_factory.gd:35-39`, `:222-225`, `:258-261` all pass `c.pain_feature_id` to `b2b_promise_create` with no check that the feature is unshipped, while `pick_pain_feature` draws from the **whole** pool. Two wrong outcomes: **free win** — the ship-coupling resolves *any* open promise whose feature is in the live set, so the promise flips to "kept" on the next ship of anything, collecting +15 satisfaction / +6 trust for work already done; or **unfair loss** — if nothing ships within 14 days the same promise breaks (−20 satisfaction, −12 trust, brand −3) and the modal never offered "we already ship that". The rest of the codebase already treats "pain already live" as a first-class state.

**S2-23 · Rescuing an account from Risk re-classifies it as an expansion opportunity in the same tick.** `b2b_sales_system.gd:206-219` — `set_lifecycle_phase` writes through to the same instance, so line `:216` re-reads what `:213` just wrote. A ≥45-day account that recovers goes **risk → active → expansion inside one `_tick_healthy` call**, and "Ekibimiz büyüyor, sistemi başka birimlere de yaymak istiyoruz" fires the same day the customer was talked out of leaving. Secondary, same block: an *onboarding* account that dips and recovers is silently set to "active", ending onboarding early while the satisfaction model keeps amplifying — phase and model disagree for the rest of the window.

**S2-24 · The autonomous-close path has no market gate** — see S1-2; filed there.

**S2-25 · `Customer.status` has one reachable value and `"churning"` is written and destroyed on the same line.** `customer.gd:33`, `:44`; `b2b_sales_system.gd:235-237`. `status` is never written outside its default, yet seven registry queries filter on it — dead code guarding a condition that is always true. `lifecycle_phase = "churning"` is set at `:235` and the record is erased at `:237`, so `sales_tab`'s documented `"churning"` → calm-card mapping **can never render**.

**S2-26 · Firing a rep leaves their accounts pointing at a deleted employee until the next morning.** `hr_actions.gd:209-231` and `character_registry.gd:296-306` perform no assignment cleanup; the repair (`reconcile_assignments`) is tick-scheduled, not event-driven — and `EventBus.character_removed` **is** emitted with nothing listening. In that window the same card contradicts itself: the steward row prints `SORUMLU: —` while the row still renders in the calm "somebody is on it" treatment, and `founder_managed_count()` undercounts the founder's book. *(The economy stays honest — the dampening lookup correctly returns 0.)*

**S2-27 · The MT request channel and stewardship are correct — but "cannot fire in a B2C market" does not hold.** Full verification recorded: per-account latch, 22-day phase-strided cadence, company-wide weekly escalation ceiling with retry-not-drop, zero-customer and pre-ship both impossible. The single caveat is S1-2. *Recorded as a near-clean surface so the fix does not disturb what works.*

**S2-28 · Prospect provenance is written and never read; every pitch claims Frank introduced the lead.** `pitch_system.gd:212-213` hard-codes the referral fiction in the intro stage, while `Prospect.source` (`prospect.gd:39`) and `Customer.acquisition_source` have **zero readers**. Shot-verified on `pitch_shot.png`, where the lead was created by the founder's own search.

#### Family D — shell, input, navigation (8)

**S2-29 · Focused chrome eats Space and Enter under every non-focus-grabbing modal.** `game_shell.gd:131-137` (Guard 2 deliberately returns *without* marking the key handled, so modals can see Esc) + `TopBar.tscn:288-312` (5 speed buttons, no `focus_mode`) + `LeftTabs.tscn` (9 rail buttons, `focus_mode` appears nowhere in the file). Click a speed button, let an event fire, press Space → the still-focused button consumes `ui_accept` and fires: **the clock starts running underneath a mandatory event modal**, or the page behind it navigates. The `FOCUS_NONE` discipline exists already on `tab_page_chrome`'s ✕ (documented as the "Kepenk blind-close ban") and was never extended to the chrome. Affects EventModal, MeetingScene, FrankPopup, TermSheetTable, HRAtlas, HRPopover. **One-line fix.**

**S2-30 · HRAtlasModal and HRPopover cover the screen without pausing — the clock runs and Space/1-4 are dead.** `hr_atlas_modal.gd:9-10` states the no-pause policy; `hr_tab.gd:356-370` mounts full-rect into ModalLayer, so the dimmer covers the TopBar (speed buttons unclickable) *and* Guard 2 kills the keyboard. The clock ticks at 4× through the entire hire decision with no way to stop it. *Correction to the working brief: **Esc does work** — Guard 2 deliberately preserves `_unhandled_input`.* The policy is sound for a tab *page* (pages live outside ModalLayer); these are the only surfaces that keep it *inside* ModalLayer, which is the one place it stops working.

**S2-31 · The intro tour's scrim does not cover the chrome — a first-time player can start the clock behind it.** `oda_view.gd:1568-1578` parents the tour to OdaView inside CenterViewport (deliberately, to stay out of ModalLayer), so its dim rects cover only the centre region while TopBar and the rail stay live. *Negative result recorded: the keyboard hole I suspected **does not exist** — `oda_tour.gd:92-103` really does swallow Space/1-4/Esc and, by reverse `_input` order, reaches them first.*

**S2-32 · Navigating away hides the tour but never dismisses it.** `center_viewport.gd:53-54` hides OdaView; `_input` dispatch is not gated by visibility, so the invisible tour keeps consuming Space/1-4/Esc for the rest of the session — the player's first Esc appears to do nothing (it silently finishes the tour) and the second closes the page — and returning to ODA makes the tour **reappear mid-run** at its old step.

**S2-33 · The tab router destroys in-progress work with no confirmation.** `center_viewport.gd:43-46` frees the page on **every** `tab_changed`, including `""`. A half-built product — chosen type, ticked features, typed name — is gone on Esc, ✕ or a tab click. Double-Esc is the cruellest path: the first Esc only releases the LineEdit focus, so the second one — the key that everywhere else means "cancel this dialog, keep my work" — is the destructive one. The codebase already uses `ConfirmModal` for exactly this class of loss elsewhere. *The same free-and-rebuild is what makes S3 language-refresh self-healing, so the fix must be a dirty-state guard, not "stop freeing pages".*

**S2-34 · Eight rail labels are hardcoded English, in two places, next to a Turkish "Ayarlar".** `LeftTabs.tscn` baked text + a second English copy in `ui_tokens.gd:343-354` (rendered as the placeholder page title). No CSV key exists, and `left_tabs` is not connected to `language_changed`, so the toggle cannot move them even if keys were added. *(Filed independently by two work-streams — F-07 and G-16 — merged.)*

**S2-35 · A shipped language toggle produces a mixed-language game.** `settings_modal` offers EN; only the 237 keyed strings flip. **English after switching:** onboarding, ODA + tour + ticker, most of the Sales tab, ending chrome, settings. **Still Turkish:** *every event modal in the game* (chrome, all 21 event bodies, every choice label, every effect badge), Product + build wizard, HR, Finance, Hunt/VC, MeetingScene, Term Sheet Table, month summary, ConfirmModal, MentorIntro, FrankPopup, BuildHUD, every composed news line, all 65 company backgrounds, all product/feature names, all 8 ending titles. The honest framing: this is not an incomplete retrofit, it is a setting that promises something the build cannot keep.

**S2-36 · Screenshot harnesses reach into tab-page privates through `Node`-typed variables.** Eight sites in `main.gd` (`_flow._mount_step`, `tab._open_atlas`, `tab._expanded_id`, `tab._rebuild`, `tab._navigate` ×3, `scene._export_paper_png`). All eight resolve today; the finding is the coupling — this is the exact shape that silently broke `--hr-shot` and `--product-shot` when the ODA rework renamed `_current_tab_node`, and that break stayed invisible until someone ran the shots. *Because the receivers are dynamically typed, a rename fails silently instead of as a parse error.*

#### Family E — economy and tick dispatch (5)

**S2-37 · Overtime pay/bonus symmetry is broken by exactly the hour the block started.** `hr_overtime_system.gd:192-205` vs `product_system.gd:453-459`. Because the daily tick for day *X* runs *before* any hourly tick while `day == X`, a block started at hour *H* delivers `24N − H` bonus-hours against *N* paid nights. Start at 09:00 → 37.5 % of a day's bonus never arrives; start at 23:00 → a 3-day block delivers ~2.04 days for 3 nights' pay. The file asserts "exactly block_days of bonus against exactly block_days paid nights" — true under the daily read the comment describes, which no longer exists. *S1-3 is the other half of this root cause.*

**S2-38 · No smoke case reproduces the engine's real daily/hourly interleave.** `endgame_smoke.gd:198-200` — `_sim_day()` runs `advance_day` + the daily dispatch and **no hourly tick at all**; the three hand-rolled shapes elsewhere in the suite each miss a different half, and none places the daily tick where the engine places it (**between hour 0 and hour 1**). That single placement is what creates both S1-3 and S2-37 — and the coupling case even performs the S1-3 exploit sequence and asserts only that the multipliers reset. *135/135 is silent on every cross-boundary interaction.*

**S2-39 · The determinism probe's hourly economy never runs.** `main.gd:234-274` seeds a world it believes is shipped (it is not — `SalesSystem.hourly_tick` gates all B2C work on `mvp_shipped`), and the build it starts parks at the iteration band edge on day 3. From day 4 the fingerprint is a constant plus a daily sum, so the four runs are identical **by construction**, not by tick purity. The wall-clock half of the probe remains valid; the tick-purity half should be re-run after the probe is fixed before it is cited again. *Filed against my own primary determinism evidence.*

**S2-40 · The run seed is unrecordable, unreadable and unpersisted.** `game_state.gd:527-528` — `run_seed = Time.get_ticks_msec()`, i.e. process uptime; absent from `get_run_ledger()`'s 33 keys; never printed; never persisted (SaveManager is a 4-line stub). Across four live runs it could not be obtained once. **Corroborating evidence from the codebase itself:** the team needed a reproducible seed twice and both times had to overwrite it *after the fact* (`main.gd:248-249` and `:509-511`), which is the missing parameter proven by workaround.

**S2-41 · One shared global RNG stream whose consumption order depends on content.** Four consumers draw from the single `seed()`ed stream. `_ordered_by_priority` shuffles each priority group — *n−1 draws per group*, i.e. **how many events happen to be eligible that day** — and `_is_eligible` short-circuits, so a `random` condition placed *after* a state condition consumes a draw only when the state passes. **Re-ordering the conditions array inside a JSON event file therefore re-rolls the world** for every later consumer that day, including the player's pitch rolls. The codebase already diagnosed this (`event_manager.gd:26-28` migration cue, repeated in TECH_SPEC §20) and half-honoured it: HRMoraleSystem built its own salted stream, leaving the EventManager↔SkillCheck coupling untouched.

#### Family F — onboarding (6)

**S2-42 · The default founder name is the English "Founder", and it is written into run state.** Five places including the persisted `game_state.gd:558-560`; the TR CSV row embeds the English word; no loc key exists, so it is untranslatable in either direction. The Turkish label the codebase already has (`"founder": "Kurucu"`) is used as the *null fallback* on the very same line in the SORUMLU dropdown. *(Filed twice — H-01 and G-22 — merged.)*

**S2-43 · The two locked origins carry different coming-soon promises.** `founder_constants.gd:68` (`ONB_LOCKED_FULL` → "TAM SÜRÜMDE") vs `:71` (`ONB_LOCKED_SOON` → "ÇOK YAKINDA"), although CLAUDE.md puts **both** extras in FULL. One of the two badges is a release promise the roadmap does not make. Shot-confirmed on `onboard_shot_2.png`.

**S2-44 · `logo_style` is a mandatory gate with zero readers; `slogan` is write-only.** The player cannot advance without choosing, and nothing ever reads the choice.

**S2-45 · The founder portrait is a dead choice whose page copy promises otherwise.** The page says it is "the face you'll see in the mirror"; the only live read (`b2b_pitch_meeting.gd:134`) uses it as an *exclusion* filter so a prospect's rep does not share the founder's portrait.

**S2-46 · Language cannot be changed before or during onboarding.** `settings_requested` is only connected in `_swap_to_shell_and_modal`; there is no gear in the flow, TR is the hard default and no OS-locale detection exists — so a player who wants English must first play the entire onboarding in Turkish.

**S2-47 · On the dark onboarding register, a *disabled* button is the brightest control on screen.** `DialogueGhost` has no `disabled` stylebox and falls back to the light-body `SURFACE_DISABLED`; the commit button's disabled state is `SURFACE_SUNKEN` — both over `DIALOGUE_BG #191614`. Not in the theme sweep ledger's sanctioned list, and the same inversion lands on TermSheetTable and EndingScene.

#### Family G — world, news, rivals (5)

**S2-48 · Real trademarks ship as rival product names.** `rival_catalog.gd:34-45` contains **`"Asana"`** (the market *giant* of `saas_project_mgmt`) and **`"Stripe+"`** (giant of `saas_billing`), plus `Cursor+`, `Junie`, `MonDay`, `Datadoggo`, `Trellium`, `Sentrio`, `Lookera`, `Pinelake`. The trademark sweep that already cleaned `CompanyCatalog` (which documents replacing two Turkish trademarks) never ran over `RivalCatalog`. Rendered on the ODA board, the ticker and the Product tab — three player-visible surfaces, one of them the marketing screenshot. *Distinct exposure class from a brand mentioned in flavour copy: these are competitor **entities** in a commercial product on the same market as the trademark holder.*

**S2-49 · `RIVAL_BIG_MOVE_PCT` is unreachable, so an entire news branch is dead.** The gate is 0.75 pp of weekly share movement; the model's maximum weekly delta for **any** row is 0.34 pp (giants have momentum 0 and cannot move at all). So `(heavy and big)` is never true and `big` never contributes to the startup branch either: **no giant, established or holding can ever produce a headline, in any run, at any player share.** Measured against the system's own 90-day dump: 104 rival lines, four distinct names, one startup producing 40 of them (38 %), every two days. The neighbouring epsilon was tuned against measured 0.03-0.10 pp motion — one order of magnitude below the gate.

**S2-50 · "Biz" milestone headlines are silently dropped.** A drop-oldest buffer (cap 10) meets a rate-limited drain (the 20 % cap allows ≈0.7 biz lines/day), so a backlog silently eats the *earliest* announcements: 11 of 81 milestones never reached the stream in the 90-day dump, matching the arithmetic exactly. Reachable in real runs — every autonomous close and every leave emits one. *Partially masked: the ticker shows the line once immediately; what is lost is its place in the persistent archive.*

**S2-51 · The ODA board renders the market's third-largest slice as an unranked footnote below the player's 0.3 % row.** `oda_view.gd:1119-1144` appends `others` (12.8 %) after the sort as a dim `MicroLabel`, beneath a row an order of magnitude smaller, while the visible ranked rows sum to 63 % and only the footnote closes the gap to 100. The residual has no rank, so the ladder grammar has nowhere to put it. *(Filed twice — E-03 and F-13 — merged; the arithmetic was reproduced exactly from a live frame.)*

**S2-52 · Churn permanently shrinks the prospectable world.** A signed company's name is appended to `b2b_signed_company_names` and **never removed** (the only reset is a new run), and the affinity pool is 4-8 sectors × 5 companies, so the cold pipeline is a **lifetime** cap of 20 / 25 / 40 companies depending on sub-type. The append-only behaviour is *documented design intent* for the demo ("win-back is a future dedicated path") — the finding is that it collides with the LOCKED endless Early-Access scope, and that the exhausted-pool copy ("herkes ya müşterin ya masanda") is false after any churn. **Raised as an open question, scored S2 only for the copy.**

#### Family H — remaining (5)

**S2-53 · The `--modal-shot` harness is dead: three byte-identical bare-ODA PNGs.** `main.gd:682-712` mounts GameShell directly and never runs the signal-wiring block that lives only in `_swap_to_shell_and_modal`, so all three emitted signals have zero listeners. Re-verified this session: identical MD5 `d92234b6…`, 1,288,937 B each; the confirm shot read visually is the plain room. **These are the team's modal baselines** — any theme or layout regression in ConfirmModal, SettingsModal or MonthSummaryModal passes a byte-diff against them. Two sibling harnesses already hand-wire around exactly this.

**S2-54 · The left-rail HR badge has no refresh trigger for search-state transitions.** `left_tabs.gd:59-65` subscribes to morale and roster signals only; files delivery emits `headline_added` and dismissal emits nothing. With zero employees — the common first-hire case — the badge can stay dark until the hire itself, so the player misses the arrival beat they paid $600 for.

**S2-55 · The Atlas hire button is disabled on affordability, contradicting the engine's documented contract.** `hr_atlas_modal.gd:282-293` disables "İŞE AL" when cash < commission, while `hr_search_system.gd:28-31` states there is deliberately **no affordability gate** — "an economic warning instead of a disabled button" — and every sibling money action (build commit, severance, retainer) may push cash negative through the bankruptcy channel. The search-start footer in the same modal gets it right, so one modal follows two philosophies.

**S2-56 · Day-dependent employee-card lines go stale.** `hr_tab.gd:130-147`'s rebuild key has no `GameState.day` term, so "İzinde · 7 gün kaldı" shows 7 for the whole leave, "Yarın başlıyor" survives into the first working day, and the YENİ badge outlasts its window — until any unrelated structural change forces a rebuild.

**S2-57 · UYUM is near-decorative yet displayed and priced on every candidate.** Census: UZMANLIK 11 read sites, HIZ 7, **UYUM exactly 1** (build-lead coordination, employee leads only). For the two commercial roles it is structurally unreadable — they can never be leads and no sales/CS formula touches it, which both files state on purpose — yet the salary premium counts it, so the dearest file in a batch can be dearest *because* of a stat that will never enter a formula for the role it was bought for. The axis comment promises "moral dayanıklılığı"; that half is carried entirely by traits.

---

### S3 — cosmetic, wording, dead surfaces

All CONFIRMED unless marked. Grouped by family; each row carries its anchor and the one-line expected/actual.

#### Dead or unreachable surfaces (14)

| # | Finding | Location | Expected → Actual |
|---|---|---|---|
| S3-1 | `one_time_today` is a fully dead parallel ledger | `finance_system.gd:55-63, 89, 137, 179-182` | a written+cleared dict feeds a UI → **zero callers**; its documented consumer is satisfied by the *other* ledger (`transactions`), which is the one rendered |
| S3-2 | `get_display_date()` is dead English-date code | `game_state.gd:335-342` | either the TopBar uses it (and it must be Turkish) → **zero call sites**; the ODA rework moved the date to Turkish and left the getter, keeping two English tables alive to serve it *(filed twice — A-06/G-21 — merged)* |
| S3-3 | `axis_meaning` preview key produced, consumed nowhere | `hr_search_system.gd:259-261`, table `hr_constants.gd:112-119` | per-role axis meanings surface at pick time → nothing renders them; the three axis chips have no legend anywhere (compounds S2-57) |
| S3-4 | `meeting_requested` declared, never emitted, never connected | `event_bus.gd:158` | Hunt emits → VCPitch listens → the direct-call refactor replaced the hop and left the declaration |
| S3-5 | `music_enabled_changed` / `music_volume_changed` fire into the void | `audio_manager.gd:88, 99` | "so any UI can reflect state without polling" → the one consumer polls at open |
| S3-6 | `rival_added` has no live consumer | `rival_registry.gd:25` → only `right_panel.gd:89` | something repaints on roster seed → its only subscriber is the retired panel |
| S3-7 | `phase_gate_reached` has no non-debug consumer | `phase_gate_system.gd:87` | a surface flashes on the gate → only the smoke suite listens; the player learns via the enqueued event |
| S3-8 | Retired RightPanel still ships (277-line script + 539-line scene, 13 dead connects) | `right_panel.gd`, `RightPanel.tscn` | retired UI is deleted or pruned → both remain and generate false positives for future audits *(the header banner is honest — documented dead code)* |
| S3-9 | `get_player_rank_in_startup_league`'s composed sentence is dead | `rival_registry.gd:60-73` | the Turkish rank string renders somewhere → its only renderer was the retired panel; the live strip prints share instead |
| S3-10 | `TICKER_09` / `TICKER_10` unreachable | `news_ticker.gd:124-129` | all ten ambient lines reachable → the fill loop always restarts at index 0 and breaks at 8, so indices 8-9 never append; cold start is byte-identical every run |
| S3-11 | `_pending_outcome` is dead state with a stale contract comment | `vc_pitch_system.gd:38` | "set at Beat-4 resolve, applied on result close" → never written; outcomes apply immediately inside `_resolve_beat4` |
| S3-12 | Self-Made's three perk chips are unwired | onboarding origin catalog | perks modify something → distinct catalog from S1-4's traits, same dead end |
| S3-13 | "kurucu da dahil" participants line is unreachable | `hr_overtime_system.gd:249-254`, `hr_overtime_panel.gd:39-43` | the card says the founder pulls product_dev nights → `founder_participates` requires an *active* block but the line renders only *pre-start*, so it is dead in both branches |
| S3-14 | "WISHLIST'E EKLE" is a styled, enabled, rendered no-op | `ending_scene.gd:26, 321-326, 442-444` | primary CTA does something → `STEAM_PAGE_URL` is `""`; *documented decision (store page pending)*, filed because it is dead-but-rendered UI on the shipping-candidate screen, and its sibling locked control uses a disabled state instead |

#### Wording, copy and label drift (16)

| # | Finding | Location | Expected → Actual |
|---|---|---|---|
| S3-15 | "AYIN OLAYI" has only five submitters, so most months read "Sakin bir ay" | `game_state.gd:244-249`; callers in phase/gate/shutter/acquisition/ship only | the month's biggest event → nothing in the customer, HR, sales or fundraising lifecycle ever submits one; live: a month with two risk flips, a discount, daily expansion spam and a churn reported "Sakin bir ay" |
| S3-16 | Portfolio counts a product and its own next version as "2 ürün" | `portfolio_view.gd:70-73` | 1 product, 1 in development → `shipped + build_active` |
| S3-17 | Fumes prose says "altı aydan kısa sürede" on a run that is exactly six months | `endings_copy.gd:412-419` vs `:393-396` | 180 days = six months → the same paper prints "6" and "under 6" about one span **(SUSPECTED — wording judgement)** |
| S3-18 | Empty roster footer prints "ORTALAMA MORAL 0" | `hr_tab.gd:187-194` | "—" or omit on an empty team → literal 0 reads as catastrophe on a 0-100 scale |
| S3-19 | The exhausted-pool line lies after any churn | `strings.csv:104`, `sales_tab.gd:186-187` | "herkes ya müşterin ya masanda" → a churned company is neither |
| S3-20 | Raw English relationship pill "NEUTRAL" on every character event | `event_modal.gd:214-215`; field `character.gd:60` | a Turkish label like its neighbours → the raw enum, and since its only writer is a modifier with zero live users the chip is *also* permanently constant *(filed twice — D1-07/C-16 — merged)* |
| S3-21 | "Self-Made" is the only English origin name | onboarding origin catalog | Turkish canonical → English proper-noun-styled label |
| S3-22 | `HATA` vs `Açık hata` for the same count | ODA monitor vs Product portfolio row | one noun → two (not simultaneous, so no contradiction) |
| S3-23 | `convert_audience` chip says "dönüşüm", state is an audience spike | `event_modal.gd:450` | chip matches the Economy-v2 model → pre-v2 vocabulary survived |
| S3-24 | Cancelled-search retainers render as "İşe alım" rows | `finance_system.gd:135-137` | a burnt retainer reads as its own thing → shares the hire label |
| S3-25 | The skill-ceiling telegraph is effectively invisible | onboarding step | the cap is legible → rendered at `VEIL_FAINT` 3 % white |
| S3-26 | Trait copy is permissive where the validator is mandatory | onboarding traits step | copy matches the rule → over-cap clicks are silently ignored |
| S3-27 | Two locked onboarding controls, two different lock grammars | see S2-43 | one telegraph → "TAM SÜRÜMDE" vs "ÇOK YAKINDA" |
| S3-28 | `dev_002`'s second choice re-sets a flag its own trigger requires | `ev_mvp_dev_002_tech_debt_callout.json:11, 34` | meaningful modifier → a no-op write (harmless; noted so nobody counts a second debt stack) |
| S3-29 | Burn units labelled inconsistently across three renderings | TopBar `/d` chip · Finance `Gider` (×30) · tooltip `$/gün` | consistent units → the unit only reappears inside a tooltip |
| S3-30 | `HR` on the rail contradicts the project's own "İK" vocabulary | `LeftTabs.tscn`, `event_bus.gd:127` | one vocabulary → the headline source string already uses İK and the page is called "Ekip sayfası" |

#### Write-through, seams and hygiene (13)

| # | Finding | Location | Expected → Actual |
|---|---|---|---|
| S3-31 | `cs_escalated` and `retain_stalls` are written raw, outside the registry seam | `b2b_sales_system.gd:156, 160, 163, 264, 297` | a `CustomerRegistry` seam like the other twelve fields → direct writes; both are **latches**, so a future save/load or UI binding inherits an unseamed write |
| S3-32 | Debug harness writes `Customer.assigned_to` raw | `main.gd:1283` | via `assign_customer` (which also sets `cs_pinned` and emits) → the seam would have refused it pre-`add`, so the raw write papers over a missing "assign at creation" affordance |
| S3-33 | `CharacterRegistry.add()` drops on id collision and the caller cannot tell | `character_registry.gd:242-267` | the caller learns → returns `void`, `push_warning`s |
| S3-34 | `_validate_shape` is non-blocking, so an invalid Character enters the registry | `character_registry.gd:249, 270-293` | reject or repair → validates for side effect only **(design-intent, recorded as answer to the question)** |
| S3-35 | Live code reaches across modules into `_`-private members | `pitch_system.gd:168`, `sales_tab.gd:340/361`, `product_system.gd` ×5 | public seams → private members are the contract; *statically typed, so a rename is a loud parse error* |
| S3-36 | `BuildHUDPanel` connects `day_advanced` with an un-disconnectable lambda | `build_hud_panel.gd:86, 92-100` | connect/disconnect symmetry → 5 connects, 4 disconnects; the anonymous Callable has no handle |
| S3-37 | `_event_signals_wired` guards two different connect sets | `main.gd:1317-1329` vs `:596-598` | one flag, one set → the shot path sets the same flag after wiring only one signal **(SUSPECTED — not reachable today)** |
| S3-38 | `PromiseRegistry.reset()` has zero callers | `promise_registry.gd:67-68` | the debug restart clears it → promises survive an in-place restart; the restart's own comment lists other registries but not this one |
| S3-39 | The debug restart does not reset customer / prospect / promise registries | `main.gd:1735-1736, 1762` | a restart-style reset leaves nothing pointing at the dead run → only `CharacterRegistry.reset()` runs **(documented-known)** |
| S3-40 | The debug restart leaks six dialogue-state fields | `main.gd:34-39` vs `:1737-1768` | all modal state cleared → `_meeting_scene`, `_frank_popup`, `_term_table`, `_pre_dialogue_speed`, `_deal_prompt_vc`, `_pending_deal_prompt_vc` survive, so run 2's first meeting choice can be misrouted |
| S3-41 | Seven of eighteen `file:LINE` comment citations point at the wrong lines | incl. `hr_search_system.gd:44` (318 lines off), `endgame_smoke.gd:3706`, `finance_system.gd:55` | a citation still points → three land on **semantically unrelated code**, which is worse than a stale number because the reader believes what they find |
| S3-42 | Nine live comments still name the retired RightPanel as an active reader | `main.gd:8`, `character_registry.gd:8/24`, `customer_registry.gd:7/55/162/177`, `rival_registry.gd:5`, `customer.gd:30/87` | comments follow the retirement → two assert readers that do not exist *(counter-example: `oda_view.gd`'s provenance citations are exactly correct)* |
| S3-43 | `b2c_audience` flips between float and int, discarding the sub-unit accumulator | `sales_system.gd:137-138` vs `:232-234`, `:493`, `event_manager.gd:512` | the float accumulator survives (its stated purpose) → every event-driven change truncates it and changes the stored type; a save-schema hazard |

#### Content, world and data (9)

| # | Finding | Location | Expected → Actual |
|---|---|---|---|
| S3-44 | Real brands are load-bearing in live event copy | `ev_ps_first_revenue.json:6/9` (Stripe), `ev_ps_b2c_producthunt.json:5/6/9` (Product Hunt, Slack), `ev_ps_power_user_b2c.json:6` (X / Twitter), `ev_mvp_iter_002:5` (Twitter), plus `product_catalog.gd:145-171` | a fictional world (65 invented companies, invented outlets) → four event files, five catalog lines and one rival name carry live trademarks; "X / Twitter" also dates the fiction. **Flagged as a release-blocker candidate despite S3 severity — this is the one cosmetic item with legal surface area** |
| S3-45 | `warning_flags` is copied at signing but never populated | `prospect.gd:22` → `sales_system.gd:290` | the documented values ("slow_payer", "picky") are reachable → always empty at both ends |
| S3-46 | Fixture company "Kule Lojistik" is not in the catalog and is filed under the wrong sector | `main.gd:1068-1075` vs `company_catalog.gd:113` ("Kule **Finans**") | baseline screenshots draw names from the single fiction source → the ending fixture invents one and stamps both fixture customers "Sigorta"; harness-only, and it is the provenance answer for a live sighting |
| S3-47 | Five of seven B2B sub-types have no `SECTOR_AFFINITY` entry | `b2b_constants.gd:219-222` | "product type shapes your world" → implemented for 2 of 7; the rest silently take the 8-sector fallback |
| S3-48 | The ambient rate model undershoots the authored `chance` by 7-20 % | `event_manager.gd:99, 350-352` | the JSON number is the daily probability → per-hour normalization makes it 1−(1−p/n)ⁿ; worst on the highest-chance event. *Also: a lower-priority event that rolled successfully in the same hour has its success discarded, and the day is then closed to it* |
| S3-49 | The ≤1-ambient-per-day throttle leaks by one at the hour-0 rollover | `time_manager.gd:117-126` + `event_manager.gd:91-104` | one ambient per calendar day → the hour-0 tick stamps the throttle to *yesterday*, so a day can take two. Same root: cooldown arithmetic at hour 0 is one short |
| S3-50 | Events badge and ODA phone dot both count the event currently on screen | `left_tabs.gd:148-149`, `oda_view.gd:964-965` | events *waiting* → `event_triggered` fires while the event is still queued, and `_pump_queue` emits nothing they listen to, so both read stale-by-one until resolve |
| S3-51 | `needs_engineer` never decays | set `product_system.gd:769-780`, cleared only by hiring a developer | a pressure signal reflecting present overload → a windowed setter with a purchase-only clearer, so AŞIRI YÜKLÜ badges can persist for the rest of the run **(SUSPECTED)** |
| S3-52 | Duplicate CS escalation possible while the first is still queued | `b2b_sales_system.gd:155-163` | one escalation per episode → the latch clears on recovery even with the modal unresolved; the second answer re-applies brand −3 and morale −10 **(SUSPECTED — needs an unresolved queue across ≥2 days)** |

#### Tooling, docs and remaining (7)

| # | Finding | Location | Expected → Actual |
|---|---|---|---|
| S3-53 | TECH_SPEC's determinism sentence is false on all three clauses | `docs/TECH_SPEC.md:281` vs `save_manager.gd` | "seed is part of the saved state; loading reproduces the sequence" → there is no saved state, the seed is not in it, and the sequence is content-coupled |
| S3-54 | The compiled `.translation` binaries are stale **and inert** | `localization/*.translation`, `project.godot` | either current or absent → stale *and* never registered (no translations entry; the autoload parses the CSV itself). **They do not matter functionally — delete or gitignore so they stop lying about the pipeline** |
| S3-55 | Onboarding shots are hardcoded to 1920×1080 while the declared minimum is 1280×720 | `main.gd:720` | baselines cover the minimum → page 2's ScrollContainer has horizontal scroll DISABLED, so overflow there is clipped, not scrollable **(run request filed)** |
| S3-56 | Employee-card trait chips carry no effect tooltip | `hr_employee_card.gd:107-108` | the hover reveal that candidate files already have → bare labels post-hire, when the effects matter most for raise/vacation previews |
| S3-57 | Stale Esc rationale names a handler that no longer exists | `game_shell.gd:138-146` | the comment names a live handler → `oda_view.gd` has no `_unhandled_input` at all. *Verified harmless: with a page open Esc takes the normal close route; the only dead case is Esc in the room, where a no-op is correct* |
| S3-58 | A language switch does not re-translate an open page or any mounted modal | four `language_changed` listeners only | the visible page re-renders → only TopBar, ticker, ODA and Finance Özet repaint. *Self-healing because the router rebuilds pages, which is why it is S3* |
| S3-59 | `pitch_requested` for a stale prospect fails silently | `pitch_system.gd:185-189` | feedback on a dead lead → `push_warning` + `false`, no modal, no toast. **Unreachable from real UI** (the tab repaints on `prospect_removed`) — recorded as the residual of a retired suspicion, not inflated |

---

## Dead-choice sweep

**Row count: 71 live choices, recounted from source, zero drift from the expected total.** 16 live JSON events / 31 choices (9 build events × 2, paid-tier 1, producthunt 2, bug-complaint 3, first-revenue 1, frank-intro 1, power-user 2, referral 3) + 40 code-built (B2B factory 17, HR factory 6, Product 4, phase gates 4, endings 5, VC 4). The three `ev_debug_*` fixtures (9 further choices) are annexed as NOT-LOADED — the loader skip was re-verified at `event_manager.gd:654-655`.

**Verdicts: WIRED 56 · PARTIAL 7 · BEAT 8 · DEAD 0 · DUPLICATE 0.** No live GameEvent choice is outright dead. The eight BEATs are exactly the sanctioned single-choice beats. **§10 check: no row carries an economic delta without the played choice as its origin.** The one true mechanical duplicate in the game is not in this pool — it is in the B2B pitch beats (`pitch_system.gd:215-219`, intro choices 1 and 3 both grant +1 with no other difference).

Reader-chain shorthand used below: **[CASH]** `set_cash` → TopBar/Finance · **[BRAND]**/**[REP]** → TopBar + audience flow + gates · **[DIM]**/**[BUG]**/**[DELAY]** → build axes/bug counter/effort → tracker → launch stamp → economy · **[SATc]** `set_satisfaction` → sales-tab health + risk machinery · **[AUD]** → audience → derived MRR → TopBar · **[MOR]** → morale → HR cards/attention/resign odds · **[PROM]** → PromiseRegistry → detail-view rows + ODA dates + request scoring → resolution effects.

### A · Live JSON pool (16 events / 31 choices)

| Event id | Choice (TR) | Claimed | Traced → reader | Verdict |
|---|---|---|---|---|
| ev_mvp_bugfix_001_critical_bug | Çıkışı ertele, çöz | Hata −6 · Kararlılık +4 · Nakit −$150 | [BUG][DIM][CASH] | WIRED |
| ev_mvp_bugfix_001_critical_bug | Bırak, gönder | **Marka −2 only** (set_flag chip-silent) | `critical_bug_unfixed` → **+5 bugs at launch** + [BRAND] | **PARTIAL** (hidden cost) |
| ev_mvp_bugfix_002_early_launch_pressure | Bir tur daha temizlik | Hata −4 · Kararlılık +2 · Nakit −$100 | [BUG][DIM][CASH] | WIRED |
| ev_mvp_bugfix_002_early_launch_pressure | Hazır olmasa da çık | Marka −1 | [BRAND]; does **not** ship (launch stays player-gated — honest, Beta parks indefinitely) | WIRED |
| ev_mvp_bugfix_003_final_polish | Vakit harca, cila çek | Deneyim +5 · Nakit −$80 | [DIM][CASH] | WIRED |
| ev_mvp_bugfix_003_final_polish | Yeterince iyi — devam | Deneyim −2 · Hata +1 | [DIM][BUG] | WIRED |
| ev_mvp_dev_001_integration_broken | Gece boyu uğraş | Kararlılık +6 · +1 gün | [DIM][DELAY] | WIRED |
| ev_mvp_dev_001_integration_broken | Geçici çözüm | −2 gün · Hata +2 (debt flag silent) | [DELAY][BUG] + `tech_debt_birikti` → **+5 bugs at dev→beta** | **PARTIAL** (hidden deferred cost) |
| ev_mvp_dev_002_tech_debt_callout | Dur, düzelt | Kararlılık +6 · +2 gün | [DIM][DELAY] + flag clear (silent **benefit**) | WIRED |
| ev_mvp_dev_002_tech_debt_callout | Üstüne eklemeye devam | −1 gün · Hata +2 | [DELAY][BUG] + redundant no-op flag write (S3-28) | WIRED |
| ev_mvp_dev_003_solo_dev_fatigue | Bugün kendine ver | +1 gün · Kararlılık +2 | [DELAY][DIM] | WIRED |
| ev_mvp_dev_003_solo_dev_fatigue | Zorla, kahve yap | −1 gün · Hata +2 | [DELAY][BUG] | WIRED |
| ev_mvp_iter_001_scope_creep | Düzgün yap | Deneyim +6 · +2 gün | [DIM][DELAY] | WIRED |
| ev_mvp_iter_001_scope_creep | Kırp, yüzeyi koru | −1 gün · Hata +3 | [DELAY][BUG] | WIRED |
| ev_mvp_iter_002_competitor_signal | Tasarımı eğ | İnovasyon +5 · +2 gün | [DIM][DELAY] | WIRED |
| ev_mvp_iter_002_competitor_signal | Kendi yolundan sapma | Marka +2 · İnovasyon −2 | [BRAND][DIM] | WIRED |
| ev_mvp_iter_003_early_user_feedback | Önerileri ciddiye al | Deneyim +6 · +2 gün · Nakit −$100 | [DIM][DELAY][CASH] | WIRED |
| ev_mvp_iter_003_early_user_feedback | Vizyonuna sadık kal | −1 gün · Marka +1 · Deneyim −2 | [DELAY][BRAND][DIM] | WIRED |
| ev_ps_b2c_paid_tier | Cetveli aç | no chip · signpost | `mentor_advisory` → ODA monitor + hunt tab (does **not** open the tier — the ruler is the lever, §10-correct) | BEAT 1/8 |
| ev_ps_b2c_producthunt | Çık — görünürlüğü al | Dönüşüm %25 · Marka +3 · Kitle +20 · Nakit −$800 | convert_audience [AUD] + [BRAND] + [AUD] + [CASH] | WIRED |
| ev_ps_b2c_producthunt | Pas geç | Kitle +6 | [AUD] | WIRED |
| ev_ps_bug_complaint | İade + özür dile | **"NAKİT -$1K"** (actual −$1,500) · Memnuniyet +20 | [CASH] + [SATc] via the **market-blind** lowest-satisfaction target | **PARTIAL** (badge lie S2-2; target S2-16) |
| ev_ps_bug_complaint | Hızlı düzeltme sözü ver | Memnuniyet +8 · Nakit −$300 | [CASH] + [SATc]; **the promised fix is recorded nowhere** | **PARTIAL** (K3 row) |
| ev_ps_bug_complaint | Görmezden gel | Müşteri kaybı · Marka −2 | churn: B2C → audience −15 % (record persists) / B2B → **remove outright** + [BRAND] | WIRED (but S2-16) |
| ev_ps_first_revenue | Bir nefes al | no chip | `mentor_advisory` → ODA monitor | BEAT 2/8 |
| ev_ps_frank_intro_b2b | Tamam — hazırlanayım | Yeni aday | `add_prospect` → spawn → sales-tab lead card **(verified live in run D: 2→3)** | BEAT 3/8 (carries real effect) |
| ev_ps_power_user_b2c | Tanıtım yaz | Marka +4 · Kitle +25 · Nakit −$600 | [BRAND][AUD][CASH] | WIRED |
| ev_ps_power_user_b2c | Sessiz kal | Kitle +5 | [AUD] | WIRED |
| ev_ps_referral_b2b | Kabul et — **özellik sözü ver** | Yeni aday · Nakit −$400 | add_prospect + [CASH]; **the promised feature creates no promise object** (machinery exists, unused) | **PARTIAL** (verbal-commitment class) |
| ev_ps_referral_b2b | Pazarlık et — söz verme | Yeni aday | add_prospect (smaller lead — honest) | WIRED |
| ev_ps_referral_b2b | Reddet | İtibar +2 | [REP] | WIRED |

### B · Code-built events (40 choices)

| Event id | Choice (TR) | Claimed | Traced → reader | Verdict |
|---|---|---|---|---|
| ev_b2b_retain_&lt;cid&gt; | Söz ver: '&lt;özellik&gt;' | Müşteri kalır · söz borcu · İtibar +1 | [PROM] + satisfaction bump (**silently halved** if the customer was let down before) + risk cleared + [REP] | WIRED (deadline + halving invisible at pick) |
| ev_b2b_retain_&lt;cid&gt; | Oyala | Kısa vadeli hamle · Marka −1 | uses 1-2: stall++ and countdown +3 d → visible · **use 3+: nothing, while brand −1 lands** | **PARTIAL → DEAD past cap (S1-5)** |
| ev_b2b_retain_&lt;cid&gt; | İndirim ver | Müşteri kalır · MRR −$X · İtibar −1 | discount → set_mrr + reflect → TopBar + [SATc] + [REP] | WIRED |
| ev_b2b_retain_&lt;cid&gt; | Kendi haline bırak | müdahale yok · sayaç işlemeye devam eder | documented no-op; countdown keeps ticking, brand −2 lands at the **real** churn | WIRED (sanctioned no-op — **verified honest**) |
| ev_b2b_expand_&lt;cid&gt; | Büyüt | Koltuk +N · MRR +$M | expand → seats+mrr+reflect+counter → tab/TopBar — **no cost modifier at all (S1-1)** | WIRED (but the faucet) |
| ev_b2b_expand_&lt;cid&gt; | Şimdilik gerek yok | Değişiklik yok | phase → active — **which re-arms the loop (S1-1)** | WIRED (but the faucet) |
| ev_b2b_escalation_&lt;cid&gt; | Tamam, sözü tut | Müşteri kalır · söz borcu · yol haritasına eklenir | honor → [PROM] + latch cleared. *Chip oversells: promise ledger yes, build-flow marker no* | WIRED |
| ev_b2b_escalation_&lt;cid&gt; | Hayır, yapmıyoruz | Müşteriyi kaybet · Marka −3 · &lt;CS&gt; −10 | remove + counter + [BRAND] + [MOR] | WIRED |
| ev_b2b_request (complaint) | İndirim ver | Müşteri kalır · MRR −$X · Memnuniyet +8 | discount + [SATc] **target-threaded** (smoke-pinned) | WIRED |
| ev_b2b_request (complaint) | Düzeltme sözü ver | Müşteri kalır · söz borcu | [PROM] — **the B2B fix-promise IS recorded; the contrast row to K3** | WIRED |
| ev_b2b_request (complaint) | Açıkla ve reddet | Memnuniyet −3 | [SATc] | WIRED |
| ev_b2b_request (renewal) | Yenilemeyi görüş | Memnuniyet +6 | [SATc]; the "renewal table" itself is fiction-only (no contract state exists) | WIRED |
| ev_b2b_request (renewal) | İndirimle bağla | MRR −$X · Memnuniyet +8 | discount + [SATc] | WIRED |
| ev_b2b_request (renewal) | Beklet | Memnuniyet −5 | [SATc] | WIRED |
| ev_b2b_request (feature) | Söz ver: '&lt;özellik&gt;' | Müşteri kalır · söz borcu | [PROM] | WIRED |
| ev_b2b_request (feature) | Önceliklendir | Memnuniyet +4 | [SATc]; **"priority" is recorded nowhere** | **PARTIAL** (verbal-commitment class) |
| ev_b2b_request (feature) | Şimdilik olmaz | Memnuniyet −6 | [SATc] | WIRED |
| ev_hr_resign_&lt;eid&gt; | Anlaşıldı | &lt;Ad&gt; ayrılıyor | confirm_departure → registry remove (counter, emits) → roster/HR tab | WIRED (single-choice by design — the roll already happened) |
| ev_hr_valve_&lt;eid&gt; | Mesaiyi durdur | Ek mesai durur | stop → block erased → burn/speed multipliers cease | WIRED |
| ev_hr_valve_&lt;eid&gt; | Devam et | Mesai sürer · istifa riski artar | note_valve_continued → run-persistent flag → resign odds (**chip names the hidden mechanic honestly**) | WIRED |
| ev_hr_calm_stretch | İyi | Ekip +N | morale_all_employees → [MOR] ×all **(verified live, run D)** | WIRED |
| ev_hr_big_signing | Hak ettiler | Ekip +N | same | WIRED |
| ev_hr_ship_glow | Devam | Ekip +N | same | WIRED |
| ev_mvp_ship_moment | Yayınla | no chip | ship_active_build → mvp_shipped + components + version history + month highlight → the whole post-ship economy; **no economic delta rides (§10 clean)** | BEAT 4/8 |
| ev_mvp_version_ship_moment | Yayına devam | no chip | same seam, version-aware | BEAT 5/8 |
| ev_mvp_iter_decision_intro | Bir tur daha (4 gün) | Bir tasarım turu · 4 gün (chip reads the live constant) | advance_iteration → round countdown → gains toward team ceilings → tracker | WIRED |
| ev_mvp_iter_decision_intro | Geliştirmeye geç | Geliştirme başlar | enter_development → phase flip + emits | WIRED |
| ev_phase_gate_traction | Hazırız — geçelim | no chip (zero economic delta by design) | advance_phase → guarded ratchet → phase_changed → TopBar/tab locks **(verified live, run D: phase 1→2)** | WIRED |
| ev_phase_gate_traction | Henüz değil | no chip | on_gate_declined → decline counter → escalating reminder copy (the next reminder body **is** the reader) | WIRED |
| ev_phase_gate_series_a | Hazırız — geçelim | as gate 1 | same | WIRED |
| ev_phase_gate_series_a | Henüz değil | as gate 1 | same | WIRED |
| ev_shutter_warning | Anlaşıldı | no chip | empty modifiers; the counter was set by the system before the modal and is visible in the TopBar | BEAT 6/8 |
| ev_pivot_offer | Pivot — devam ediyoruz | no chip | on_pivot_accepted → pivot_used + VC hunt purged → run continues to D180 | WIRED |
| ev_pivot_offer | Hayır. Bitti. | no chip | trigger_ending("vc_rejection_cascade") → run ends | WIRED |
| ev_acquisition_offer | Kabul et — sat | no chip | trigger_ending("acquisition") → ending screen | WIRED |
| ev_acquisition_offer | Reddet — devam | no chip | `acquisition_offer_rejected` → **real reader** in the VC interrogation line; run continues | WIRED |
| ev_vc_meeting_prompt | Toplantıya gir | no chip | begin_meeting → pending consumed + MeetingScene mounts | WIRED |
| ev_vc_meeting_prompt | Bugün değil (randevu yanar) | no chip · label states the cost | pending_meeting.clear → VC stays open, re-requestable (**label honest: the appointment burns, not the VC**) | WIRED |
| ev_sheet_expiry_warning | Anlaşıldı | no chip | empty modifiers; the countdown ticks elsewhere | BEAT 7/8 |
| ev_vc_d179_warning | Anlaşıldı | no chip | empty modifiers; pure warning | BEAT 8/8 |

### C · Annex — `ev_debug_*` fixtures (NOT LOADED, 9 choices)

Reachable only through `--event-shot`. Recorded because they prove the lock rendering: `ev_debug_002`'s third choice renders dimmed, chip-less and unclickable with the badge "REPUTATİON 10+ GEREKLİ" (an English word, fixture-only), and `ev_debug_003`'s second choice is a permanently locked "not implemented" telegraph. One fixture choice claims a hire it does not perform — fixture-grade, listed so it is not mistaken for live content.

### Modifier wiring matrix — the vocabulary gaps

43 keys audited (42 apply branches + 1 phantom). **One badged-but-unapplied key:** `mrr` (S1-8). **Six apply branches with zero live content users:** `add_character`, `seats`, `customer_mrr_delta`, `open_paid_tier`, and the two deliberately deprecated aliases `speed_bonus` / `quality_bonus`. **Ten silent keys** (no chip by design), of which `set_flag` is the one that carries **hidden costs** — the two build-debt flags worth +5 bugs each. And structurally: **no event path can write `mvp_live_bug_count`** (verified writer list: hourly wear, sprint tick, launch snapshot, plus debug), while `bug_delta` early-returns when no build is active — so the engine has no vocabulary for "an event fixes live bugs", which is the systemic half of K3.

---

## Known-bug dossiers (K1-K4)

**K1 — promise ↔ build disconnect: STALE AS REPORTED.** The machinery exists and works end-to-end: promises are created from four choice rows, carry a real deadline, resolve **kept** on ship via `mvp_components` membership, **partial** when late, **broken** on deadline — and the outcomes drive satisfaction (±15/−20/−5), tolerance, a decaying trust offset (+6/−2/−12) and brand −3, plus a credibility flag that halves the next promise's goodwill. Three UI readers render them. All smoke-pinned; a promise was created, broken and priced exactly in the live B2B run. Promise text comes from **real feature data** (`pain_feature_id` drawn from the shipped product's own catalog pool), and promised ids **can** reach the version build. **The accurate residue is a perception gap (S2 in Family A/C):** at the one decision point where the promise is redeemable — the v2 feature picker — the promise is invisible (`creation_flow.gd` has zero promise references) and cross-labelled, because promise surfaces render the Turkish feature label while the picker's title is the catalog's **English** name, with no shared string. Keeping a promise therefore requires out-of-game memory. Blast radius: accidental promise-breaking feeds the game's most durable B2B damage channel, driven by a UI gap rather than a player decision. Plus two lifecycle holes: S1-6 (promise outlives the customer) and S3-38 (`reset()` uncalled).

**K2 — repeat ban not applied: CONFIRMED, and it is one caller, not the engine.** Full dossier at S1-1. The repeat ban *exists* and is *correctly wired* for the JSON pool; the expansion event never passes through it because `enqueue` bypasses eligibility by design and its owning system's latch does not survive its own resolution. Reproduced live on both branches. **Blast radius answer: this is the visible tip of a class, but the class is smaller than it looks** — 12 of 15 injectors carry a correct private latch, so the same weakness produces exactly one live loop today. The *class* risk is the maintenance tax: every future code-built event must re-invent suppression.

**K3 — bug-fix event has no effect: PARTIALLY ACCURATE, reframed.** The literal seed is false for the live tree: on `ev_ps_bug_complaint`'s paid choice both modifiers land (cash −300 real and visible; satisfaction +8 with real, if weak, readers — and *not* overwritten, since B2C drift is incremental). Reproduced live: **cash charged, `mvp_live_bug_count` unchanged at 8.** The true findings underneath are three: the fix *commitment* is recorded nowhere (while B2B has a full ledger for exactly that — the contrast row is in the sweep table); the cash chip understates the charge by a third (S2-2); and **the engine structurally cannot express "an event fixes live bugs"**. Not one unwired modifier — a vocabulary gap shared with the `mrr` phantom.

**K4 — B2C event repeats: CONFIRMED, and it is a SECOND root cause, not K2's.** The JSON cooldown works exactly as coded (fired day 32 → day 40 = the 8-day minimum). It re-arms because **its trigger conditions never stop being true**: `churn_customer`'s B2C branch erodes the audience but leaves the aggregate record alive, so `customer_count_min` holds; and B2C satisfaction is **frozen** in the ordinary mid-game regime (S2-20), so a run seeded below 60 has the event permanently armed while the paid "fix" is the only thing that can move the number. Same repeat symptom as K2, entirely different mechanism — K2 is a missing latch, K4 is a self-perpetuating trigger.

---

## Duplicate-information findings

22 pairs were merged from all nine work-streams and sorted by consequence. The full register is in the audit's working notes; the ones that matter:

**Can actually disagree (fix these):** build progress rendered with `round()` in one place and `floor()` in another, both on screen (S2-8) · MRR in three formats, two of them wrong (S2-1) · event time-of-day from a static string beside the live clock (S2-7) · the iteration decision card showing **two** axes in the floating HUD and **three** in the tab — and the HUD was observed omitting exactly the axis that was over its ceiling.

**Redundant, one should go:** monthly net twice on one Finance screen (survivor: the headline) · customer count twice on the Sales tab ~90 px apart (survivor: the column header, which labels the list it counts) · "+1" twice inside one strip (survivor: the net cell, which carries both halves) · the YENİ badge beside a "yeni müşteri" tenure line (survivor: the badge) · player market share twice on one ODA card (survivor: the SEN row) · `one_time_today` vs `transactions` (survivor: `transactions`) · eight tab names in two English sources (survivor: **neither** — both should point at one CSV key set).

**Correct duplication, both survive:** runway in the TopBar and on the Finance page — this is the sanctioned chrome/page split, and crucially **there is no drift risk because both call the single formatting home**, which is also why S2-9 is wrong in two places and fixable in one · pending-event count on the rail badge and the ODA phone dot · churn countdown in the modal and the portfolio · promise deadline in the detail view and the ODA dates board · the iteration-decision buttons in the teaching modal and the tracker · salary on the HR card and in the raise popover.

One duplicated **algorithm** is worth separating from the duplicated *facts*: the "nearest rival above" backwards walk is implemented twice (`oda_view.gd` and `detail_view.gd`). That is the real drift risk on surface 34, and it belongs in the registry beside `format_share`.

---

## Phase B — fix plan

Prose only, no code. Grouped by shared root cause first, shared file surface second. Effort: **S** ≈ under an hour · **M** ≈ half a day · **L** ≈ multi-day.

### Group 1 — K2, the expansion loop · S1-1 · Effort M
**Fix.** Add a per-account "last expansion moment" field to `Customer`, written by **both** `expand()` and `decline_expansion()` through a new `CustomerRegistry` seam, and gate the `_tick_healthy` promotion on it. **Do not reuse `acquired_on_day` as the latch** — it feeds the tenure display, the renewal tenure score and the delegation ordering, so moving it corrupts three readers. Decide the counter-pressure for "Büyüt" separately (it currently has no cost of any kind) — that part is an Open Question, not a bug fix.
**Files.** `data_models/customer.gd` · `autoload/customer_registry.gd` · `systems/b2b_sales_system.gd` · `systems/b2b_constants.gd` · `tabs/sales_tab.gd` (the manual trigger must respect the same latch).
**Risk / callers that move with it.** Every reader of the `"expansion"` phase: the Sales-tab badge, the ODA desk paper (one per expansion account), and the event factory. A new persisted field appears — coordinate with Group 9's save schema. **If the latch lands only in the daily sweep and not on the Sales-tab button, the loop stays open.**
**Dependencies.** None. This should land first.
**Verification.** Extend the existing expansion smoke case with a second day asserting **no** re-fire on *both* branches; re-run the live repro at day 83.

### Group 2 — the market-gating cluster · S1-2, S1-7, S2-16 · Effort M
**Fix, in three layers.** (a) Gate the daily B2B chain on `mvp_market_type` (or gate the two rep systems on it). (b) Make the default customer selectors market-aware — thread the event's own `market_type` through `_resolve_customer_target`, which already supports a `primary_b2b` selector but has no B2C equivalent, and give `churn_customer` a target at all. (c) Flip the empty-pain branch of `is_auto_closable` to the conservative default: an unmappable pain routes to the founder's pitch.
**Files.** `systems/sales_system.gd` · `systems/b2b_sales_system.gd` · `systems/sales_rep_system.gd` · `systems/customer_rep_system.gd` · `autoload/customer_registry.gd` · `autoload/event_manager.gd` · possibly `systems/hr_constants.gd` if the roles are hidden in a B2C run.
**Risk.** (a) makes CS stewardship unreachable in B2C — correct, but confirm it is intended. (b) touches the modifier layer the sweep table maps, so every `satisfaction_delta` row needs re-checking. **Fixing (a) alone removes the *reachability* of (b) and (c) but leaves both latent** — do all three.
**Dependencies.** Sequence after Group 1 if both touch `b2b_sales_system.gd` in the same window.

### Group 3 — overtime accounting · S1-3, S2-37 · Effort M
**Fix.** Charge on the same clock as the benefit: accrue pay and morale hourly per participant, or charge a partial-day amount on `stop()` for hours already consumed. **Rewrite the justification comment with the fix** — it currently describes a daily read that no longer exists, and that stale comment is what made the bug invisible.
**Files.** `systems/hr_overtime_system.gd` (+ its header) · `systems/finance_system.gd` (the pull assumes a day-stamped total) · `tabs/hr/hr_overtime_panel.gd` (the preview promises the full block).
**Risk.** The Finance pull is day-stamped and self-verifying; an hourly accrual must not double-charge across the boundary. `bug_multiplier` is read on the same hourly path and should move consistently.
**Dependencies.** **Group 8 first** — this cannot be regression-proofed until the smoke driver reproduces the real interleave.

### Group 4 — the display-lies batch · S2-1 … S2-12 · Effort S each, one batch
Cheap, player-facing, and verifiable in one screenshot pass. Add a `custom_minimum_size` to the MRR cell (S2-1). Fix the chip formatter's integer division (S2-2). Label or clamp the ceiling display (S2-3 — **wording decision, see Open Questions**). Delete the dead ternary arm or add the third monitor string (S2-4). Retitle the hard-mode chip to a locked telegraph (S2-5). Gate the fumes revenue line on actual revenue and write a no-revenue alternative (S2-6). Drive the event subtitle's clock from `current_hour` or drop `· HH:MM` from all 13 subtitles (S2-7) — **preserve the authoring discipline, which is currently correct**. Give build-percent one shared formatter (S2-8). Render sub-month runway as days or "<1 ay" (S2-9), and guard the negative-cash branch in the same single home (S2-10). Decide whether a signing books as cash at all (S2-11) and retitle the run-rate card (S2-12).
**Risk.** Pure presentation. The only shared surface is the money formatting family — verify S2-1 and S2-2 touch different helpers before batching them. Re-shoot the affected harnesses afterwards.

### Group 5 — promise lifecycle integrity · S1-6, S2-22, K1 residue, S3-38 · Effort M
**Fix.** Remove (or void) promises when their customer is erased, and move the brand and flag writes **inside** the existing null guard — the guard is already there for every other write in that function. Refuse promise creation for an already-shipped feature. Mark promised features in the v2 picker and share one label source between the promise surfaces and the catalog.
**Files.** `autoload/promise_registry.gd` · `systems/b2b_sales_system.gd` · `systems/b2b_event_factory.gd` · `tabs/product/creation_flow.gd` · `systems/product_catalog.gd`.
**Risk.** The kept/partial/broken numbers are smoke-pinned — do not disturb them. The picker change collides with Group 7's draft-loss work in the same file.
**Note.** The null-guard half of S1-6 is **S effort and can ship immediately**, independently of the rest.

### Group 6 — event-engine architecture · S2-13, S2-14 (+ S2-17) · `[REBUILD-ARC]` · Effort L
**Do not half-fix this in the cleanup round.** Arc-time direction: one admission path that re-validates at display time; **id-based rather than identity-based** queue dedupe; per-event resolution memory that content can read; and `flag_unset` / `not` in the condition vocabulary. One cheap thing may be worth doing before the arc regardless: id-based queue dedupe would close K2's queue flood, the double-modal from the manual triggers, and the duplicate-escalation suspicion in one line — **but the state latch (Group 1) is still the real K2 fix**, which is exactly why Group 1 is written as a caller-side change that does not wait for this.

### Group 7 — shell input and navigation discipline · S2-29 … S2-33 · Effort S-M
**Fix.** `focus_mode = FOCUS_NONE` on the five TopBar speed buttons and the nine rail buttons — the same treatment `tab_page_chrome` already documents (S2-29, one line, do it first). Dismiss the intro tour on visibility change or tab change, and decide whether its scrim should cover the chrome (S2-31/S2-32). Add a dirty-state guard before the tab router frees a page with unsaved input (S2-33) — **a guard, not "stop freeing pages", because the free-and-rebuild is what makes the language refresh self-healing**. Decide whether the Atlas and popover should pause the clock or stay out of ModalLayer (S2-30).
**Files.** `TopBar.tscn` · `LeftTabs.tscn` · `oda_view.gd` · `oda_tour.gd` · `center_viewport.gd` · `creation_flow.gd` · `hr_atlas_modal.gd` / `hr_popover.gd` / `hr_tab.gd`.

### Group 8 — instrument repairs · S2-38, S2-39, S2-53 · Effort S-M · **do these early**
They change nothing in the game and everything in what the team can see. Add a `_sim_day_full()` that mirrors the real boundary drain (`hourly 1..23 → hourly 0 → advance_day → daily`) and re-point the economy and HR cases at it. Ship the tempo probe's product and drive its build past the iteration gate so the probe measures what its comment claims — **then re-run before citing tick purity again**. Wire the three missing signal connections in `--modal-shot` (two sibling harnesses already do it) and re-shoot all three baselines.

### Group 9 — reset and persistence debt · S2-18, S3-38 … S3-40 · Effort S now / L for SaveManager
**Now.** Give Shift+F4 the ModalLayer guard its four siblings already have; add `EventManager.reset()` and `PromiseRegistry.reset()`; clear the six dialogue-state fields the restart currently misses.
**Later — this is the SaveManager task's scope.** The twelve-owner volatile-state table in the working notes is the serialization checklist. Two design constraints fall out of this audit: **flag typing must be pinned in the schema** (the two layers already disagree — event conditions coerce through `bool()` while systems use plain truthiness, so a String-typed flag satisfies one and fails the other, demonstrated by controlled experiment), and **the seed must become an input rather than a side effect**, surfaced read-only and persisted, with per-stream generators whose *state* is saved rather than one global `seed()`.

### Group 10 — content and world integrity · S2-48 … S2-52, S3-44 · Effort S-M
Run one trademark sweep across all three name pools — rival catalog, product catalog and event copy (**recommend doing this regardless of severity ordering; it is the one item with legal surface area**). Recalibrate the rival "big move" threshold to the model's real scale, or the giants can never make news. Give the milestone buffer a drop-newest or a higher drain so announcements stop vanishing. Rank or relabel the ODA board's residual row.

### Group 11 — language law · S2-34, S2-35, S2-42, S3-20, S3-44, S3-54 · Effort M-L
Key the rail and TopBar captions and connect `left_tabs` to `language_changed` (both halves are needed). Map the relationship enum and the budget band through label tables, the pattern the codebase already uses for roles and badges. Give the default founder name a key and the Turkish word the codebase already has. Delete or gitignore the stale, inert `.translation` binaries. **Then decide the bigger question below.**

---

## Suggested cleanup sequencing

**Batch 0 — instruments (Group 8).** Nothing later can be honestly regression-proofed until the smoke driver reproduces the real tick interleave and the two false-green harnesses are repaired. Small, and it changes what every later batch can prove.

**Batch 1 — the economy S1s (Groups 1, 2, 3).** K2 first: it is the one the director already saw, it breaks Calibration Law 1, it is self-contained, and it has a deterministic repro. Then the market-gating cluster, then overtime accounting. **Add the trademark sweep here** on non-technical grounds.

**Batch 2 — the display-lies family (Group 4) plus the one-line focus fix from Group 7.** One screenshot-verified sweep; every item is S-effort and player-facing. This is the batch that makes the numbers trustworthy again.

**Batch 3 — promise integrity (Group 5) and the rest of Group 7.**

**Batch 4 — world/content integrity (Group 10) and the language law (Group 11).**

**Batch 5 — the cheap half of reset debt (Group 9).**

**Deferred to the event-rebuild arc — Group 6 `[REBUILD-ARC]`.** Do not patch the enqueue bypass or the history model in cleanup. Note deliberately: **no S1 in this report depends on that arc.**

**Deferred to SaveManager — the real half of Group 9**, with the volatile-state table as its scope and the flag-typing and seed constraints as design inputs.

---

## Open questions for the director

These are design calls, not bugs. No decision was made here.

1. **What should "Büyüt" cost?** Fixing K2's latch stops the loop but leaves expansion as pure upside — free seats and MRR for one click. Should it carry a cash, satisfaction, or delivery cost, or a per-account limit?
2. **The ceiling label.** The engine's "ceiling binds only iteration-round gains" doctrine is internally consistent, but the card prints "Kararlılık 10 / tavan 8". Relabel it ("tur kazancı tavanı"), clamp the display, or extend the ceiling to the commit stamp? The third option is a real mechanics change.
3. **Should the two commercial HR roles exist in a B2C run at all?** Gating the daily dispatch fixes the bug either way, but hiding the roles is a different player-facing answer than letting them be hired and do nothing.
4. **The lifetime prospect pool.** Signed names are burned permanently by documented design ("win-back is a future dedicated path"), which caps the cold pipeline at 20-40 companies *for the whole run*. That is fine for a 180-day demo and structurally incompatible with the LOCKED endless Early-Access scope. Win-back path, larger pool, or accept the ceiling for now?
5. **The EN language toggle.** It is shipped and selectable today and produces a mixed-language UI: roughly 237 strings flip while 1,400+ do not. Gate the toggle until the sweep lands, or commit to finishing the sweep?
6. **Founder traits and the other dead onboarding choices.** Traits, `logo_style`, `slogan` and the portrait are all presented as consequential and read by nothing. Wire them, or give them the game's existing "yakında" telegraph grammar so the player is not told a promise?
7. **Is 180 days of a no-build run supposed to be event-silent?** Run V fired zero reactive events in 180 days because the whole pool is gated behind having a build or a shipped product. Not a bug — but it collides with Calibration Law 2's "no stretch over 60-90 seconds without a meaningful decision".
8. **Hard mode.** The chip says "AÇILDI" on every ending and is permanently disabled. Retitle to a locked telegraph, or is an unlock actually planned for the demo?

---

## Verification checklist (§17)

1. **Zero source files modified, zero git commands, one file written.** Confirmed. The tree's newest non-`.godot` write was `localization/strings.csv` at 15:40:03 before the audit and was still that file at the same timestamp at 22:15. The only file this audit created is this report.
2. **All 45 surfaces appear in the coverage map**, each marked CLEAN or FINDINGS(n). No surface omitted; none BLOCKED. *(Surface 1 was missing from my initial work-stream split and was covered by a dedicated late pass rather than being marked clean unaudited.)*
3. **K1-K4 each reproduced or resolved, root-caused, blast radius assessed.** K1 stale-as-reported (machinery works; residue is a perception gap). K2 confirmed live on both branches, root-caused to one caller of fifteen. K3 partially accurate, reframed to three underlying defects, cash-charge reproduced live. K4 confirmed live and shown to be a **second, different** root cause from K2.
4. **Sweep table: 71 rows, one per live choice**, recounted from source with zero drift, plus a 9-row NOT-LOADED annex. Verdict counts stated.
5. **Every finding carries location, repro, expected/actual and a confidence label.** SUSPECTED entries are marked inline (S2-10, S3-17, S3-37, S3-51, S3-52).
6. **Findings sorted S0 → S3 and grouped by shared root cause.** Seven cross-filed duplicates merged, with the double-filing noted as a blast-radius signal.
7. **`[REBUILD-ARC]` applied to two findings** (S2-13 enqueue bypass, S2-14 history model), each with a one-line justification of why it is architecture rather than a missing wire, and the distinguishing test stated.
8. **Every Phase B entry has** proposed fix, files touched, risk with caller impact, effort and dependencies.
9. **Long runs: 4 runs, 4 world configurations**, to day 180 / ~46 / ~121 / 96. Depth target (shipped product + ≥3 customers + ≥1 churn) met across the set: run B2B reached 2 signed and 2 churned with the full promise lifecycle; run D reached 3 concurrent customers with 5 employees. **Seeds:** run V pinned at 424242; the other three used the engine's own seed, which **cannot be read out of a live process** — that inability is itself finding S2-40.
10. **Full smoke suite run once: 135/135 PASS**, case count scraped from source. **Two findings filed against the suite** (S2-38 no case reproduces the real tick interleave — which is why the two overtime bugs pass; S2-39 the determinism probe measures a constant). Individual fabrication sites were checked and judged legitimate fixtures.
11. **Every screenshot produced was read.** 50 harness invocations; observations recorded per shot. Several findings exist only because a rendered frame contradicted the code (S2-1, S2-3, S2-4, S2-7, S2-51, S3-20). Three PNGs were byte-identical, which *is* the S2-53 finding.
12. **Localization sweep complete.** Dead keys: **0 of 237**. Missing keys: **0**. Hardcoded player-facing strings: **1,417+ across 86 files** (a lower bound — the heuristic requires a Turkish-specific character) plus 141 live baked `.tscn` literals, against 237 keys; `tr()` appears in only 15 files and in **zero** system or autoload scripts.
13. **Duplicate-information sweep complete**: 22 pairs, both locations each, sorted into can-drift / redundant / sanctioned with a survivor named.
14. **Open questions contain only design calls.** Eight listed; none decided here.
15. **Report written to** `docs/audits/AUDIT_2026-08-06_full_game.md`. Nothing else created in the tree.
16. **STOP.** No cleanup started. Holding for director review.

---

*End of audit. No repair work has begun and none will begin from this document — the cleanup round is a separate, approved task.*
