# Narrative-State Desync Map — State Coherence Audit

**Date:** 2026-07-14 · **Type:** READ-ONLY audit (no fixes, no refactors, no numeric tuning) · **Scope:** live tree `project-unicorn\` only (the untracked `project-unicorn-OLD-backup\` is excluded).

## Context

Three windowed-playtest symptoms looked isolated but share one disease — **writes that bypass the domain system that owns the state**, so the game's narrative *says* one thing while the state *does* another:

1. A B2B seat-upsell event appeared to add value, but the Top Customers panel showed no seat increase.
2. New features grant Kararlılık (stability) on add — contradicting the build-tracker law "Yeni feature = yeni bug" (first-time code must **cost** stability).
3. Runway displays "∞" whenever net cashflow is non-negative — amateurish for the target audience.

This report maps **every** such disconnection before anything else is built on top. Fix *directions* appear in §F; they are directions only — each becomes a separate approved task. Sibling report: `event_editorial_audit_2026-07-14.md` (content quality).

### Method
Three parallel read-only exploration passes (events, features+runway, cross-system) plus firsthand reads of the analytical core (`game_state.gd`, `event_manager.gd`, `sales_system.gd`, `customer_registry.gd`, `finance_system.gd`, `product_system.gd`, `quality_model.gd`, `top_bar.gd`, `event_modal.gd`) and firsthand grep-verification of every top finding.

**Event pool reality:** `data\events\reactive\` holds 22 JSON files; the loader (`event_manager.gd:30,552-573`) scans only that one directory and skips any `ev_debug_*` file (`:566-567`), so **19 events load**. `data\events\industry\` and `data\events\scandals\` contain only `.gitkeep` — empty. Absence-of-findings is stated explicitly where it applies.

---

## SECTION A — Event write-through violations

The dispatcher is **mostly clean**: `EventManager._apply_modifiers` (`event_manager.gd:386-533`) routes almost every modifier through the owning system. Full verified dispatch table:

| modifier `type` | line | routing |
|---|---|---|
| `cash` | 394-395 | `GameState.set_cash` (setter, emits) — cash has no other owner; legitimate |
| `mrr` | 396-397 | **`GameState.set_mrr(mrr+delta)` DIRECT** — bypasses registry bridge (§A.4, §E-C.1). Unused by any JSON. |
| `brand` | 398-399 | `GameState.set_brand` |
| `reputation` | 400-401 | `GameState.set_reputation` |
| `morale` | 402-408 | `CharacterRegistry.set_morale` |
| `morale_all_employees` | 409-411 | `CharacterRegistry.set_morale` loop |
| `set_flag` | 412-417 | `GameState.set_flag` (many are orphan writes — §A.2) |
| `add_character` | 418-448 | `CharacterRegistry.add` |
| `dimension_delta` | 450-452 | `ProductSystem.apply_dimension_delta` |
| `bug_delta` | 453-455 | `ProductSystem.apply_bug_delta` |
| `delay_days` / `speed_bonus` | 456-461 | `ProductSystem.apply_speed_bonus` |
| `quality_bonus` | 462-463 | `ProductSystem.apply_dimension_delta("innovation",…)` |
| `ship_active_build` | 464-465 | `ProductSystem.ship_active_build` |
| `add_prospect` | 467-468 | `PitchSystem.spawn_prospect` |
| `churn_customer` | 469-481 | B2C: `SalesSystem.add_b2c_audience(−15%)`; B2B: `CustomerRegistry.remove` + `run_customers_lost++` + re-derive MRR |
| `customer_mrr_delta` | 482-488 | `CustomerRegistry.set_mrr(b2bs[0])` then re-derive `GameState.mrr` (§A.3 target issue) |
| `satisfaction_delta` | 489-493 | **direct `Customer.satisfaction =`** on lowest-satisfaction customer (§E-C.2) |
| `audience_delta` / `convert_audience` / `open_paid_tier` | 494-504 | `SalesSystem.*` |
| `mentor_advisory` | 505-506 | `EventBus.mentor_advisory_changed` |
| `advance_phase` / `phase_gate_decline` | 508-514 | `GameState.advance_phase` / `PhaseGateSystem.on_gate_declined` |
| `accept_acquisition` / `accept_pivot` / `decline_pivot` | 515-523 | `EndingsSystem.*` |
| `start_vc_meeting` / `decline_vc_meeting` | 524-530 | `VCPitchSystem.begin_meeting` / clear `pending_meeting` |
| unknown | 531-532 | `push_warning` (no-op) |

The violations are four kinds.

### A.1 — Narrative claims a domain change the modifiers never make

**Seat-upsell (`ev_ps_expansion_b2b`, title "Seat artırımı") — the worked example.** Body: *"Ekibimde daha çok kişi kullanmak istiyor. Koltuk ekleyebilir miyiz?"* All three choices are narrated around **adding seats**:

| choice | narrative claim | modifiers (actual writes) |
|---|---|---|
| "Önerilen fiyattan ekle" | add seats at list price | `customer_mrr_delta +600`, `satisfaction_delta −5` |
| "Pazarlık et — daha fazla iste" | add seats, negotiate up | `customer_mrr_delta +1000`, `satisfaction_delta −12` |
| "Bedavaya ver — ilişki kıymetli" | give seats free | `satisfaction_delta +10` |

**No choice changes seat count.** There is **no `seats` modifier type anywhere** in `_apply_modifiers`. `Customer.seats` exists (`customer.gd:30`) and is written only at B2B signing (`sales_system.gd:238`, `_seats_for_archetype` → enterprise 40 / mid 12 / else 4) and B2C paying-user derivation (`sales_system.gd:184`) — never by an event.

- *Correction to the reported symptom.* The current code uses `customer_mrr_delta`, which **does** route through `CustomerRegistry.set_mrr` then re-derives `GameState.mrr` (`event_manager.gd:487-488`), so the MRR change **does** update and persist. The real defect is sharper than "added cash, MRR not recomputed": **seats never move**, the flat +600/+1000 is untethered from any per-seat price, and the Top Customers / RightPanel display (which shows per-customer `seats`) therefore shows no seat change — exactly the observed symptom, but the cause is a **missing seat seam**, not a raw cash write.

**Cofounder offers (`ev_mvp_cofounder_offer_dev` / `_iter`).** Body promises *"yarısı onun, eşit söz hakkı, yarın sabah farklı bir şirket"* (half the company, equal say). **Both** choices write only flags (`cofounder_offer_accepted`+`cofounder_offer_source` / `cofounder_offer_declined`). No `add_character`, no equity change, no cash, no morale. A cofounder joining is a domain change (a Character + an equity split) the modifiers never make. (Also §A.2, and a deletion candidate in the editorial report.)

### A.2 — Choices that "click into nothing" (write-only narrative flags, no reader)

Verified by grep across `scripts\` **and** `data\events\` (as trigger conditions): these flags are **set by event choices but read by nothing** — no system, no other event's `flag_set`/`flag_equals` gate. Each such branch's only distinct effect is a dead flag:

| flag | set by (event · file) | reader |
|---|---|---|
| `cofounder_offer_accepted` / `_source` / `_declined` | cofounder_offer_dev/_iter | **none** |
| `founder_fatigue` | dev_001, dev_003 | **none** |
| `founder_recovery` | dev_003 | **none** |
| `scope_creep_kirpildi` | iter_001 | **none** |
| `pivot_versus_rakip` | iter_002 | **none** |
| `early_feedback_dinlendi` | iter_003 | **none** |
| `polish_one_more_pass` / `launch_pressure_kabul` | bugfix_002 | **none** |
| `first_revenue_seen` | ps_first_revenue | **none** |
| `pricing_prompt_seen` | ps_b2c_paid_tier | **none** |
| `hotfix_promised` | ps_bug_complaint | **none** |
| `feature_debt` | ps_referral_b2b | **none** |

Contrast (NOT orphans): `tech_debt_birikti` is read (`product_system.gd:190`) and gates `ev_mvp_dev_002`; `critical_bug_unfixed` is read (`product_system.gd:500`).

Most of these choices also carry real modifiers (bug/delay/cash), so the choice is not *fully* inert — but the narrative distinction the flag was meant to carry forward (fatigue, a promise made, a cofounder joined) has **no downstream payoff**. Fully-inert branches — the shutter / VC-expiry / D-179 "Anlaşıldı" acknowledgements and acquisition-decline — are informational beats and likely intentional; noted, not condemned.

### A.3 — Wrong-target mutations (state changes on the wrong record)

- `customer_mrr_delta` mutates `b2bs[0]` — the *first* B2B account (`event_manager.gd:484`).
- `satisfaction_delta` mutates `get_lowest_satisfaction_customer()` (`event_manager.gd:490`).

In multi-customer state these are two different accounts, and neither is guaranteed to be the customer named in the event fiction. The seat-upsell can therefore grow one account's MRR while docking a *different* account's satisfaction.

### A.4 — Latent bypass seam (implemented, currently unused)

The `"mrr"` modifier (`event_manager.gd:396-397`) does `GameState.set_mrr(GameState.mrr + delta)` directly, outside the CustomerRegistry→SalesSystem bridge. **No shipped JSON uses it** (grep of `data\events` for an `mrr` modifier: zero hits). If authored it would be silently reverted on the next tick by `_mrr_bridge` (`sales_system.gd:113-114`). See §E-C.1 / §E-D.1.

### A.5 — Choice-UI blindness (coherence note; also in the editorial report)

`event_modal._describe_modifier` (`event_modal.gd:141-170`) renders effect badges but returns `{}` (no badge) for `set_flag`, `churn_customer`, `add_prospect`, `convert_audience`, `mentor_advisory`, `open_paid_tier`, `add_character`, and every endgame type. Those effects are invisible at decision time. It *does* show "Müşteri MRR" + "Memnuniyet" badges, so the seat-upsell choice shows MRR/satisfaction badges under seat-promising text.

### A.6 — Synthetic (code-built) events

Built via `GameEvent.new()`, enqueued directly (`enqueue`/`enqueue_front`), bypassing the JSON loader + eligibility + history append (`event_manager.gd:171-201`); resolved via the `_active_event` fallback (`:155-156`).

| id | source | choices → modifiers |
|---|---|---|
| `ev_mvp_ship_moment` | product_system.gd:845-869 | "Ship'le" → `ship_active_build` |
| `ev_mvp_version_ship_moment` | product_system.gd:818-842 | "Yayına devam" → `ship_active_build` |
| `ev_phase_gate_traction` / `_series_a` | phase_gate_system.gd:161-192 | "Hazırız — geçelim" → `advance_phase`; "Henüz değil" → `phase_gate_decline` |
| `ev_shutter_warning` | endings_system.gd:271-295 | "Anlaşıldı" → **[] (no modifiers)** |
| `ev_pivot_offer` | endings_system.gd:298-326 | "Pivot…" → `accept_pivot`; "Hayır. Bitti." → `decline_pivot` |
| `ev_acquisition_offer` | endings_system.gd:329-359 | "Kabul et — sat" → `accept_acquisition`; "Reddet — devam" → `set_flag acquisition_offer_rejected` (orphan, §E-A.4) |
| `ev_vc_meeting_prompt` | vc_pitch_system.gd:710-735 | "Toplantıya gir" → `start_vc_meeting`; "Bugün değil" → `decline_vc_meeting` |
| `ev_sheet_expiry_warning` | vc_pitch_system.gd:738-758 | "Anlaşıldı" → **[]** |
| `ev_vc_d179_warning` | vc_pitch_system.gd:761-780 | "Anlaşıldı" → **[]** |

The three `[]` acknowledgements are single-option informational beats (intentional).

---

## SECTION B — Dimension-effect design-law check

**Law under test:** "Yeni feature = yeni bug" — first-time code must **cost** stability (Kararlılık), never grant it.

**Structural fact:** "Kararlılık" is the display label of the engine `stability` quality axis (`quality_model.gd:34`; per-subtype relabels at `product_catalog.gd:156-204`). Exactly three axes: `["innovation","stability","usability"]` (`quality_model.gd:29`). A feature's `dimension_contribution.stability` is a **relative build-steering weight** (`product_catalog.gd:62-71` → `FeatureBuild.get_dimension_weights` → `ProductSystem._shaped_raw :415-418`), not a fixed on-add delta.

### B.1 — Every feature grants stability (54/54 violations under the literal law)

All 54 features in `FEATURE_POOLS` (`product_catalog.gd:72-146`) carry a **strictly positive `stability` weight**. No feature has stability ≤ 0; no feature-add path subtracts stability. Full table (id · complexity · innovation / **stability** / usability):

**ai_assistant (b2c)** — `:74-79`: chat 2·0.5/**1.0**/3.0 · memory 3·2.0/**2.0**/1.0 · tools 4·3.0/**0.5**/1.0 · voice 3·2.0/**0.5**/2.0 · image 4·3.0/**0.5**/1.0 · streaming 2·0.5/**1.0**/2.5
**ai_photo_editor (b2c)** — `:82-87`: bg_removal 2·1.0/**1.0**/3.0 · inpaint 4·3.0/**0.5**/1.5 · upscale 3·2.0/**1.0**/2.0 · style_transfer 3·3.0/**0.5**/2.0 · batch 3·0.5/**2.0**/2.0 · filters 1·1.0/**1.0**/3.0
**ai_code_copilot (b2c)** — `:90-96`: autocomplete 3·1.5/**2.0**/3.0 · chat 2·1.0/**1.0**/3.0 · refactor 4·2.5/**2.0**/1.0 · explain 2·1.0/**1.0**/3.0 · test_gen 3·1.5/**3.0**/1.0 · multi_file 5·3.0/**1.0**/1.0 · diff_review 4·2.0/**2.0**/1.5
**ai_vector_search (b2b)** — `:99-104`: embed_api 3·1.5/**3.0**/1.0 · search_api 3·1.0/**3.0**/1.0 · filter 3·1.0/**2.0**/2.0 · dashboard 2·1.0/**1.0**/3.0 · scaling 5·1.0/**3.5**/0.5 · sdk 2·1.0/**1.5**/3.0
**saas_project_mgmt (b2b)** — `:107-112`: tasks 2·0.5/**1.5**/3.0 · gantt 3·1.0/**1.0**/2.5 · comments 2·0.5/**1.0**/2.5 · integrations 4·1.0/**3.0**/1.5 · automation 4·2.5/**1.5**/2.0 · reporting 3·1.0/**1.5**/2.5
**saas_crm (b2b)** — `:115-120`: contacts 2·0.5/**2.0**/2.5 · pipeline 3·1.0/**1.5**/3.0 · email 4·1.0/**3.0**/1.5 · forecast 3·2.5/**1.0**/1.5 · mobile 4·1.5/**1.5**/3.0 · call_log 3·2.5/**1.5**/1.5
**saas_analytics (b2b)** — `:123-128`: dashboards 3·1.0/**1.5**/3.0 · query 4·1.5/**2.0**/2.5 · alerts 3·2.0/**2.0**/1.5 · share 2·1.0/**1.5**/2.5 · etl 5·1.0/**3.5**/1.0 · embed 4·2.5/**2.0**/1.5
**saas_billing (b2b)** — `:131-136`: subscriptions 3·0.5/**3.0**/1.5 · invoice 2·0.5/**2.0**/2.0 · tax 5·0.5/**4.0**/0.5 · dunning 3·1.5/**3.0**/1.0 · webhooks 3·1.0/**3.0**/1.0 · proration 4·0.5/**3.5**/1.0
**saas_dev_tools (b2b)** — `:139-144`: cli 2·1.0/**1.5**/3.0 · api 3·1.0/**3.0**/1.5 · docs 3·1.0/**1.0**/3.0 · ci_plugin 4·1.5/**3.0**/1.5 · logs 3·1.5/**2.5**/1.5 · sandbox 3·1.5/**2.5**/2.0

Subgenre `social` is declared empty (`product_catalog.gd:59`). Worst offenders by raw stability weight: `saas_bill_tax` **4.0** (`:133`); `ai_vec_scaling` / `saas_an_etl` / `saas_bill_proration` **3.5** (`:103/:127/:136`); then ten at **3.0**.

Under the law's literal test — "flag every feature granting Kararlılık on add" — **every feature is a violation.**

### B.2 — The full stability economy (where the cost actually lives)

The intended *cost* is **not on the feature record** — it is delivered indirectly through bugs.

**Grants / growth (raw stability up):**
- Development-phase passive tick: `DEV_STAB_BASE := 1.5` + `tech · TECH_STAB_COEF(0.75)` every hour of `development` (`product_system.gd:55-57,273`).
- Feature-mix shaping amplifies it per selected feature (`_shaped_raw :415-418`).
- Strengthen (pool-deepening) bonus when the dominant axis is stability (`:436-443`, `STRENGTHEN_FLAT_PER_DAY := 1.5`).
- Event `dimension_delta` (axis=stability, +): dev_001 **+6**, dev_002 **+6**, dev_003 **+2**, bugfix_001 **+4**, bugfix_002 **+2** (`event_manager.gd:450-452` → `product_system.gd:763-770`).
- Launch/v2 carry-over persists it up (`product_system.gd:517,684`); rivals grow it (`rival_registry.gd:84`); debug sets it (`endgame_smoke.gd:112`).

**Costs / erosion (the only reducers):**
- Bugs erode **effective** stability: `effective_stability = max(0, stability − 0.8·bug_count)` (`quality_model.gd:98-99,50`). The economy reads this (`economy_dims_from_flags :129`).
- Bug accrual (development phase only) `_accrue_bugs_hourly` (`:295-305`); tech-debt→bugs (`:187-192`); critical-bug launch penalty (`:70,500`); post-ship wear (`:310-325`).
- Early-ship haircut multiplies all axes down (`:492`).

**Verdict:** building a first-time feature **grows** the raw Kararlılık axis (via `DEV_STAB_BASE` + the always-positive feature weights); the only thing pushing it down is bugs eroding *effective* stability — a separate, tunable channel. Whether net effective stability rises or falls is a numbers question (out of scope). Structurally, the model **grants raw Kararlılık on build**, in tension with "first-time code must cost stability."

---

## SECTION C — Runway computation & display

### C.1 — Primary computation (the ∞ source)
`GameState.get_runway_months()` (`game_state.gd:196-201`):
```
var daily_net := float(get_net_daily_flow())
if daily_net >= 0.0:
    return INF
return cash / (-daily_net) / float(DAYS_PER_MONTH)   # 30
```
`get_net_daily_flow = round(mrr/30) − daily_burn` (`:190-194`). **Any non-negative net — including exact break-even (net == 0) — returns ∞**; the finite path is reachable only when net is strictly negative. Emitted via `_emit_runway` (`:239-240`) from `set_cash/set_mrr/set_daily_burn`.

### C.2 — A second, divergent runway formula
`VCPitchSystem._runway_days()` (`vc_pitch_system.gd:629-631`): `int(cash / max(burn,1))`, **ignores revenue entirely**, never ∞, returns 0 at cash ≤ 0. Used for the thin-runway pitch penalty (`:117`) and the meeting stat strip (`:470`). A second source of truth that can disagree with the top bar (also §E-D.5).

### C.3 — Every display / consumption site (a single presentation fix must cover all)

| # | site | file:line | ∞ handling |
|---|---|---|---|
| 1 | Top bar (HUD) | top_bar.gd:134-140 | `months == INF` → text "∞", unit label hidden |
| 2 | Month-summary builder | month_summary_system.gd:77-83 | INF encoded as sentinel `-1` (else months→days). Self-test fixture hardcodes `999` at `:101` (not live) |
| 3 | Month-summary modal | month_summary_modal.gd:66-67 | `runway_days < 0` → "∞" else "%d gün" |
| 4 | Left-tab finance badge | left_tabs.gd:146-149 | `INF < 3.0` is false → **no warning dot** (∞ treated healthy) |
| 5 | VC meeting stat strip | vc_pitch_system.gd:470 | uses the C.2 integer formula; never ∞ (divergent) |

Non-display references (no runway rendered): `product_tab.gd:820-825` (rows hidden), `phase_gate_system.gd:49-52` (runway deliberately excluded as a gate condition).

**Root:** `game_state.gd:199`. A single presentation fix touches sites 1-4; site 5 is a separate formula that also needs reconciling (§E-D.5).

---

## SECTION D — Event timing & editorial inventory

### D.1 — Firing model & the hourly-timing question (no violation found)

A firing-window rule **exists**. Two paths (`event_manager.gd`):
- **Beats** (no `random` trigger) evaluate at the daily tick (`daily_tick :56-73`), firing the moment conditions hold, at the day boundary.
- **Ambient** (`random` trigger) evaluate hourly (`hourly_tick :78-106`), gated by optional `allowed_hours:[start,end]` (`:337-342,595-599`; `start>end` wraps midnight), throttled to **≤1 ambient/day** (`_ambient_fired_day :91,104`). Per-hour `chance` is normalized back to per-day probability (`:99,373-383`).

Every ambient event carries a plausible window (business hours for opportunities, evening for consumer buzz, deliberate night windows for crises). Beats have no window and fire at the day boundary or at the triggering action. **No odd-hour ambient firing problem exists.** Dedup is solid (`_queue.has` + `_active_event_id` + `_history`; `one_shot` + `cooldown_days`). The only fiction-vs-clock concern (deterministic beats that assert a clock in copy but have no window) is a copy issue covered in the editorial report (Class 3).

### D.2 — Live pool inventory (19 loaded events)

Legend: A = ambient (random), B = beat (no random). Modifiers abbreviated; `→flag` = `set_flag`.

| id | trigger conditions | allowed_hours | cd | one-shot | pri | choices → modifiers |
|---|---|---|---|---|---|---|
| ev_mvp_iter_001_scope_creep | build_phase iteration · random .35 | [22,2] | 12 | ✓ | 0 | "Düzgün yap" → usab+6, delay+2 · "Kırp" → delay−1, bug+3, →scope_creep_kirpildi |
| ev_mvp_iter_002_competitor_signal | build_phase iteration · random .25 | [8,11] | 21 | ✓ | 0 | "Eğ" → inno+5, delay+2, →pivot_versus_rakip · "Sapma" → brand+2, inno−2 |
| ev_mvp_iter_003_early_user_feedback | build_phase iteration · random .25 | [16,20] | 18 | ✓ | 0 | "Ciddiye al" → usab+6, delay+2, cash−100, →early_feedback_dinlendi · "Sadık kal" → delay−1, brand+1, usab−2 |
| ev_mvp_dev_001_integration_broken | build_phase development · random .30 | [1,4] | 14 | ✓ | 0 | "Doğru yap" → stab+6, delay+1, →founder_fatigue · "Geçici çözüm" → delay−2, bug+2, →tech_debt_birikti |
| ev_mvp_dev_002_tech_debt_callout | build_phase development · flag_set tech_debt_birikti · random .25 | [13,17] | 16 | ✓ | 0 | "Dur, düzelt" → stab+6, delay+2, tech_debt=false · "Devam" → delay−1, bug+2, tech_debt=true |
| ev_mvp_dev_003_solo_dev_fatigue | build_phase development · random .20 | [6,9] | 20 | ✓ | 0 | "Dinlen" → delay+1, stab+2, →founder_recovery · "Zorla" → delay−1, bug+2, →founder_fatigue |
| ev_mvp_bugfix_001_critical_bug | build_phase bugfix · random .40 | [18,23] | 14 | ✓ | 1 | "Ertele, çöz" → bug−6, stab+4, cash−150 · "Bırak, gönder" → →critical_bug_unfixed, brand−2 |
| ev_mvp_bugfix_002_early_launch_pressure | build_phase bugfix · random .30 | [9,12] | 15 | ✓ | 0 | "Bir tur daha" → bug−4, stab+2, cash−100, →polish_one_more_pass · "Çık" → brand−1, →launch_pressure_kabul |
| ev_mvp_bugfix_003_final_polish | build_phase bugfix · random .25 | [21,1] | 12 | ✓ | 0 | "Cila çek" → usab+5, cash−80 · "Yeterince iyi" → usab−2, bug+1 |
| ev_mvp_cofounder_offer_dev | build_phase development · day_min 10 · random .15 | [14,17] | 0 | ✓ | 2 | "Kabul" → →cofounder_offer_accepted+_source · "Reddet" → →cofounder_offer_declined |
| ev_mvp_cofounder_offer_iter | build_phase iteration · day_min 10 · random .15 | [14,17] | 0 | ✓ | 2 | (identical to _dev) |
| ev_ps_first_revenue | mrr_above 0 (B) | — | 0 | ✓ | 8 | "Bir nefes al" → →first_revenue_seen, mentor_advisory |
| ev_ps_frank_intro_b2b | mvp_shipped · market_type b2b (B) | — | 0 | ✓ | 5 | "Hazırlanayım" → add_prospect mid, mentor_advisory |
| ev_ps_b2c_paid_tier | market_type b2c · audience_above 15 (B) | — | 0 | ✓ | 6 | "Cetveli aç" → →pricing_prompt_seen, mentor_advisory |
| ev_ps_bug_complaint | customer_count_min 1 · customer_satisfaction_below 60 · random .5 | [9,18] | 8 | ✗ | 2 | "Refund" → cash−1500, sat+20 · "Hot-fix" → sat+8, cash−300, →hotfix_promised · "Görmezden gel" → churn_customer, brand−2 |
| ev_ps_expansion_b2b | market_type b2b · customer_count_min 1 · random .25 | [10,16] | 14 | ✗ | 1 | (see §A.1) |
| ev_ps_referral_b2b | market_type b2b · customer_count_min 1 · random .3 | [9,17] | 12 | ✗ | 1 | "Kabul — feature sözü" → add_prospect mid, cash−400, →feature_debt · "Pazarlık" → add_prospect small · "Reddet" → rep+2 |
| ev_ps_b2c_producthunt | market_type b2c · flag_set b2c_paid_tier_open · audience_above 30 · random .4 | [20,23] | 10 | ✗ | 1 | "Launch et" → convert_audience 25%, brand+3, aud+20, cash−800 · "Pas geç" → aud+6 |
| ev_ps_power_user_b2c | market_type b2c · customer_count_min 1 · audience_above 40 · random .3 | [18,22] | 12 | ✗ | 0 | "Tanıtım yaz" → brand+4, aud+25, cash−600 · "Sessiz kal" → aud+5 |

Not loaded (loader skips `ev_debug_*`): `ev_debug_001_engineer_workload`, `ev_debug_002_press_inquiry`, `ev_debug_003_cash_warning`. `data\events\industry\` and `scandals\` are empty.

*Provenance note:* `ev_ps_b2c_producthunt` gates on `flag_set b2c_paid_tier_open`; that flag is set by `SalesSystem.open_b2c_paid_tier` / `apply_b2c_price` (`sales_system.gd:213-214,414-415`), not by any event — the pricing-prompt event only sets `pricing_prompt_seen`. Provenance is intact (the player setting a price opens the tier), but the two flags are easy to conflate.

### D.3 — Editorial register (summary; full treatment in the editorial report)
Structural timing/dedup is coherent. Register/copy issues (tutorial-voice advisories, UI-tab names in NPC mouths, English-laden scene-setting, an incoherent metaphor, mixed TR/EN) are inventoried exhaustively in `event_editorial_audit_2026-07-14.md`.

---

## SECTION E — Cross-system connection map

### E.0 — GameState field inventory (`game_state.gd`)
- **Identity:** company_name `:19` · origin `:20` · subgenre `:21` · logo_style `:22` · slogan `:23` · founder_name `:24` · run_seed `:25`
- **Core economy:** cash `:28` · mrr `:29` · daily_burn `:30` · brand `:31` · reputation `:32` · day `:33` · current_hour `:34` · phase `:35`
- **Flags:** flags `:40` (set/get/has `:176-186`)
- **Endgame ledger:** run_active `:45` · ending_id `:46` · phase_gate_ready `:47` · pending_next_phase `:48` · series_a_closed `:49` · shutter_days_left `:50` · vc_rejections `:51` · pivot_used `:52` · active_scandal `:53` · unmanaged_major_scandal `:54` · cash_went_negative `:55` · brand_low_since_day `:56` · net_history_90 `:57`
- **Month summary:** month_ledger `:64` · month_highlight_text `:67` · month_highlight_priority `:68`
- **Run counters:** run_customers_signed `:75` · run_customers_lost `:76` · run_hires `:77` · run_departures `:78` · run_scandals_total `:79` · run_scandals_managed `:80` · run_pushes_attempted `:81` · run_pushes_won `:82`
- **VC/Series A:** vc_states `:89` · active_sheets `:90` · pending_meeting `:91` · prep `:92` · run_pitches `:93` · run_sheets_won `:94`
- **Write seams (only sanctioned mutation):** set_cash `:98` (latches cash_went_negative `:101`) · set_mrr `:105` · set_daily_burn `:110` · set_brand `:115` · set_reputation `:119` · advance_day `:125` · set_current_hour `:129` · set_phase `:133` · advance_phase `:141` · set_run_active `:157` · set_shutter_days_left `:162` · submit_month_highlight `:167` · set_flag `:176`
- **Derived getters (no storage):** get_daily_revenue `:190` · get_net_daily_flow `:193` · get_runway_months `:196` · get_founder_equity `:203` · get_founder_skill `:212`

There is **no** `GameState.customers` / `seats` / `headcount` field — counts derive from the registries, removing a whole class of mirror.

### E.1 — Per-system WRITES / READS / seams (condensed)

| system | key WRITES | key READS | seam methods |
|---|---|---|---|
| **SalesSystem** (`sales_system.gd`) | `set_mrr` via `_mrr_bridge :114` + inline `:248`; flags b2c_audience `:128,224,420`, b2c_price/paid_tier `:213-214,414-415`; `run_customers_signed++ :247`; `CustomerRegistry.set_seats :184`/`set_mrr :185`/`add :206,246` | mrr, brand `:141`, reputation `:142`, flags, `get_total_mrr :112`, rivals, QualityModel | daily/hourly_tick, add_b2b_customer, add_b2c_audience, apply_b2c_price, open_b2c_paid_tier |
| **CustomerRegistry** | `_customers` via add `:129`/remove `:140`/set_mrr `:147`/set_seats `:159` (set_seats emits **no** signal) | iterated by get_total_mrr `:57`, get_total_seats `:84`, get_active, etc. | add/remove/set_mrr/set_seats |
| **CharacterRegistry** | `_characters` via add `:119` (**`run_hires++ :131`**), remove, set_morale `:151` | get_employees, count_engineers, get_founder, get_total_monthly_salaries | add/remove/set_morale/ensure_mentor |
| **FinanceSystem** | `set_daily_burn :48`, `set_cash(cash+net) :55`, `burn_breakdown["salaries"] :43` | salaries, daily_burn, mrr, cash | daily_tick, set_burn_category, compute_total_burn |
| **ProductSystem** | ~30 `mvp_*` flags (`:510-538`, `:789-800`, `:355-382`, `:519-523`), needs_engineer `:399`, tech_debt `:192`; submit_month_highlight `:792` | founder tech skill, mvp_* flags, count_engineers | start_build, start_version_build, launch, ship_active_build, apply_dimension_delta/bug_delta/speed_bonus, start_bug_sprint |
| **PhaseGateSystem** | phase_gate_ready `:83`, pending_next_phase `:84`, gate flags; submit_month_highlight | phase, run_active, shutter_days_left, day, conditions via is_condition_met | daily_tick, on_gate_declined, on_shutter_started/cleared |
| **EndingsSystem** | net_history_90 `:94-96`, brand_low_since_day `:101-103`, set_shutter_days_left, pivot_used `:177`, ending_id `:236`, set_run_active(false) `:235`, flags pivot_offer_made/acquisition_offer_made | cash, brand, mrr, vc_rejections, pivot_used, active_scandal, unmanaged_major_scandal, cash_went_negative, net_history_90, series_a_closed, active_sheets/pending_meeting/vc_states, get_active().size, get_employees().size | daily_tick, trigger_ending, on_pivot_accepted |
| **VCPitchSystem** | series_a_closed `:289`, vc_rejections++ `:279,298`, active_sheets/pending_meeting/prep/vc_states, run_pitches++ `:229`, run_sheets_won++ `:239`, flags pitch_prep_active/vc_d179_warned | mrr, brand, cash, reputation, daily_burn, shutter_days_left, run_customers_lost, **`mvp_bug_count` :607,670** (§E-B.1), **`acquisition_declined` :599** (§E-B.2), mvp axes, count_engineers, get_active, rivals | begin_meeting, advance, request_meeting, start_prep, sign_table, walk_table, daily_tick, on_pivot |
| **MonthSummarySystem** | month_ledger `:39`, month_highlight `:46-47` | mrr/cash/brand, get_runway_months `:80`, get_date_dict, get_employees().size | daily_tick, snapshot |
| **PitchSystem** | flag next_pitch_day `:254`; `SalesSystem.add_b2b_customer :274`; ProspectRegistry add/remove | day, SkillCheck, product_value | spawn_prospect, begin, get_stage, choose |
| **EventManager** | cross-domain via `_apply_modifiers` (§A table) | conditions (day/phase/cash/brand/rep/flags/mvp/customer/mrr/audience/satisfaction) | resolve_choice, enqueue, is_condition_met |
| **TimeManager** | set_current_hour, advance_day; dispatch order `:146-164` (Product1→HR3→Sales4→Rivals→Finance5→Events6→PhaseGate8→VCPitch8b→Endings9→MonthSummary10) | run_active | tick |
| **ProspectRegistry / RivalRegistry / InvestorRegistry** | own dicts; RivalRegistry.advance_all mutates rival axes `:76` | — | queries |
| **QualityModel / EventBus** | none (pure) / signal hub (`build_iteration_decision_pending :57` DEPRECATED, no emitter) | mvp_* flags | grow, normalized, effective_stability, etc. |

### E-A — Orphan writes (written, never read in production)
1. `mvp_quality` flag — written `product_system.gd:532`, read nowhere (the "not-yet-migrated reader" never existed). Also a stale mirror (§E-D.6).
2. `mvp_innovation_prev` / `_stability_prev` / `_usability_prev` — written `:510-512` for a version-delta display never wired; no reader.
3. Run counters `run_customers_signed` (`sales_system.gd:247`), `run_hires` (`character_registry.gd:131`), `run_pitches` (`vc_pitch_system.gd:229`), `run_sheets_won` (`:239`) — read only by `endgame_smoke.gd`. Await the unbuilt newspaper-ending screen (`EndingsSystem._build_ending_data :250-264` does not include them).
4. `acquisition_offer_rejected` flag — written `endings_system.gd:352`, read nowhere (pairs with §E-B.2).
5. B2B `Customer.seats` — written `sales_system.gd:238`; its aggregate reader `CustomerRegistry.get_total_seats()` (`:84`) is **never called**. (Per-customer seats *are* shown in RightPanel; the B2B *total* is stored but never surfaced.)
6. Inert reserved fields (declared+reset only): `run_departures`, `run_scandals_total`, `run_scandals_managed`, `run_pushes_attempted`, `run_pushes_won` (`game_state.gd:78-82`).

### E-B — Orphan reads (read, nothing writes them) — HIGHEST IMPACT
1. **`mvp_bug_count`** read at `vc_pitch_system.gd:607` (product interrogation) and `:670` (`bugs_under` callback). Production writes `mvp_bug_count_at_launch` (`product_system.gd:519`) and `mvp_live_bug_count` (`:522`) — never the bare key. Only `endgame_smoke.gd:675,691` sets it. **VCPitch always sees 0 bugs** → the bug interrogation line never fires and `bugs_under` is auto-satisfied. Correct pattern used everywhere else: `quality_model.gd:133`, `sales_system.gd:265`, `product_tab.gd:1458` read `mvp_live_bug_count` with an `mvp_bug_count_at_launch` fallback.
2. **`acquisition_declined`** read at `vc_pitch_system.gd:599` (refused-acquisition narrative branch). Nothing writes it — the decline path writes `acquisition_offer_rejected` (`endings_system.gd:352`). **Key-name mismatch → the branch is dead.** (This orphan read + §E-A.4's orphan write are two halves of one broken link.)

### E-C — Bypass writes (one domain writing another's state without the owning seam)
1. `"mrr"` modifier (`event_manager.gd:397`) writes MRR outside the registry→bridge; reverted next tick (`sales_system.gd:113-114`). Unused today; live latent seam.
2. **No `set_satisfaction` seam.** `Customer.satisfaction` is poked raw by two domains — `event_manager.gd:492` and `sales_system.gd:273` (+ creation `:204,240`) — no signal, no owner, while `set_mrr`/`set_seats` route through the registry.
3. MRR-bridge logic (`GameState.set_mrr(CustomerRegistry.get_total_mrr())`) is hand-copied at 3 sites — `sales_system.gd:248`, `event_manager.gd:481,488` — instead of the single `_mrr_bridge()` seam (`sales_system.gd:111`).
4. Debug backdoors (`game_shell.gd`, `OS.is_debug_build` only): `set_mrr` (`:159,166,177`, reverted next `_mrr_bridge`); **`GameState.day = 179`** (`:169,173`) bypasses `advance_day()` `:125` → no `day_advanced` signal; direct endgame-field writes (`:147-176`). Debug-scoped, but they mutate other domains' fields directly.

### E-D — Stale mirrors (same fact stored twice, can drift)
1. `GameState.mrr` (cached) vs sum of active `Customer.mrr` (`get_total_mrr :57`) — reconciled every tick by `_mrr_bridge`, but `CustomerRegistry.set_mrr` alone does **not** update `GameState.mrr`; drifts until the next tick / a missed inline bridge call.
2. `GameState.daily_burn` (cached) vs `FinanceSystem.burn_breakdown` sum — reconciled once/day (`finance_system.daily_tick:47-48`); `set_burn_category` (`:68`, the future marketing-spend seam) mutates the breakdown **without** refreshing `daily_burn` → runway/TopBar/VCPitch read a stale burn until the next daily tick.
3. Payroll: `burn_breakdown["salaries"]` vs `CharacterRegistry.get_total_monthly_salaries()` — self-heals daily; a same-day hire/fire isn't reflected until the next tick.
4. B2C paying users: the userbase `Customer.seats/.mrr` cache vs the `b2c_audience`→derivation (`sales_system.gd:182-185`) — refreshed hourly; drifts within the hour / when un-priced (`:178`).
5. Two runway sources: `get_runway_months()` (`game_state.gd:196`, revenue-aware, ∞) vs `VCPitchSystem._runway_days()` (`vc_pitch_system.gd:629`, cash/burn only) — can disagree on screen (also §C.2).
6. Legacy quality triple-store: `FeatureBuild.quality` ↔ axis composite (synced `product_system.gd:446-450`) + the frozen `mvp_quality` flag (orphan §E-A.1) that cannot track post-ship wear.

---

## SECTION F — Priority ranking (top 10 by player-facing damage)

Fix *direction* only — each is a separate approved task after review.

1. **Seat-upsell changes MRR but never seats** (`ev_ps_expansion_b2b`; no `seats` modifier; `get_total_seats` orphan). *Dir:* add a seat-granting modifier routed through a `CustomerRegistry` seat seam (emit a signal); price the upsell off seats × rate.
2. **Cofounder decision is fully inert** — accept vs decline both write only dead flags. *Dir:* accept → `add_character` + equity split via a seam (or gate downstream content on the flag so the choice pays off). *(Editorial report recommends deletion until the system exists.)*
3. **VCPitch reads `mvp_bug_count` (never written) → always 0 bugs** — silently disables the Series-A product interrogation + `bugs_under` callback. *Dir:* read `mvp_live_bug_count` (fallback `mvp_bug_count_at_launch`) like every other consumer.
4. **VCPitch `acquisition_declined` dead branch** — reads a key the decline path never writes (`acquisition_offer_rejected`). *Dir:* unify the flag key.
5. **Runway shows ∞ at net ≥ 0** (`game_state.gd:199`, break-even included) + a divergent cash/burn formula (`vc_pitch_system.gd:629`). *Dir:* qualify the ∞ presentation across the 4 display sites (e.g. "kârlı" / cash-only fallback) and reconcile the two formulas' semantics.
6. **Design-law inversion: features grant Kararlılık** — every feature carries positive stability weight and `development` passively grows the axis; the only cost is indirect bug erosion. *Dir:* model a first-build stability cost (bugs and/or a raw debit at add), or restate the law.
7. **Orphan narrative flags (~14 across 9 events)** — fatigue / promises / feedback set flags nothing reads. *Dir:* wire readers (start with `hotfix_promised`, `feature_debt`) or remove the dead writes so choices carry consequence.
8. **No `set_satisfaction` seam** — two domains poke `Customer.satisfaction` raw, unsignalled. *Dir:* add a registry `set_satisfaction` that emits; route both callers through it.
9. **Expansion/complaint modifiers hit the wrong customer** — `customer_mrr_delta`→`b2bs[0]`, `satisfaction_delta`→lowest-satisfaction, neither is the fiction's account. *Dir:* thread a target `customer_id` through the modifier.
10. **Stale burn mirror + latent `mrr` bypass + triplicated bridge** — `set_burn_category` doesn't refresh `daily_burn`; a raw `mrr` modifier would evaporate; bridge logic copied to 3 sites. *Dir:* refresh `daily_burn` in `set_burn_category`; retire/guard the `mrr` modifier; centralize the bridge in `_mrr_bridge()`.

Lower-ranked but noted: orphan run-counters awaiting the newspaper ending; the debug `GameState.day` backdoor skipping `day_advanced`; `[NOT IMPLEMENTED]` copy in dead debug fixtures.

---
*Read-only audit. No code changed. Fix directions are directions only, pending separate approval.*
