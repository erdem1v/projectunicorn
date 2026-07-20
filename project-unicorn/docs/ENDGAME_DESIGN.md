# ENDGAME_DESIGN.md — Phase Transition Engine, Endings & Term Sheet Negotiation

**Status:** Canonical design (Hat-1 approved, 2026-07-13)
**Owner:** Erdem + Claude (co-directors)
**Consumers:** Fable + developer agents. Specs derive from this document; where a spec conflicts with this document, this document wins until Erdem revises it.
**Revision rule:** Anything here is a current working answer, not a contract. Erdem can revise any value or structure at any time.

**Session decisions (Erdem, 2026-07-13, during Spec 1+2 planning):**
1. Ending screen retry = process relaunch (`OS.set_restart_on_exit`); in-place reset deferred to SaveManager session.
2. §4.6 "net-positive last 90 days" = **cumulative** 90-day net sum > 0 (ring buffer), not "no negative day".
3. §4.5 pivot aftermath: rejection counter stays at 3 — **VC path permanently closed** after pivot; only route left is the Day-180 fork.
4. Legacy `ev_ps_traction_ready.json` deleted outright; gate scene copy written fresh.

---

## 0. Design thesis

Two principles govern everything below:

- **Every ending is earned.** A losing player must think "those were my decisions," never "that was unfair." Therefore every terminal condition is visible, trackable, and recoverable before it fires. Death never comes as a surprise — it comes from a counter the player watched.
- **Every run mathematically ends.** Daily burn erodes cash continuously + Day 180 is a hard stop. With these two guarantees no run can become a zombie. Everything else is earned endings layered on top of this safety net.

The ending screen is not the last screen of the game — it is the demo's conversion moment. A Next Fest player who reaches it either wishlists or closes the game. Design accordingly.

---

## 1. Run skeleton

| Phase | Median window | Emotional register | Exit |
|---|---|---|---|
| Bootstrap | D1 – ~D45 | Survival. First product, first customer, first hire. Every dollar hurts. | Gate 1 |
| Traction | ~D45 – ~D120 | Repeatability. Churn, scale pressure, scandal risk grows. | Gate 2 |
| Series A Hunt | ~D120 – D180 | A hunt on a ticking clock. Runway melting, pitch calendar full, every meeting is a final. | Terminal (win/lose) |
| Day 180 | — | Hard stop. | Time-out fork (§4.6) |

Day numbers are medians, not walls — transitions are gate-driven; a fast player may enter Traction by D30. The only fixed wall is Day 180. (Working value: 180. Revisit if playtests miss the 60–90 min target.)

### 1.1 Month-End Summary (pacing instrument)

At the end of every in-game month, a single-screen summary: deltas (MRR, cash, headcount, brand), the month's biggest event, one dry line from Frank. Six beats across a run. Doubles as the data accumulator for the run summary on the ending screen (§6).

---

## 2. Phase Transition Engine (daily tick slot 8)

### 2.1 Core separation: gate vs. transition

- **Gate = systemic.** Slot 8 evaluates the current phase's exit condition every day. When satisfied: set `GameState.phase_gate_ready = true`, emit `EventBus.phase_gate_reached(next_phase)`. The phase does NOT change.
- **Transition = played.** The gate signal queues a high-priority deterministic Frank scene (not from the ambient event pool). The player confirms inside the scene; only then does `GameState.advance_phase()` run and `phase_changed` broadcast. `advance_phase()` is the single write seam for phase state.

Phase transitions produce no economic delta (no §10 violation) but are still bound to a played decision — no free-progress feel.

### 2.2 Gates (conditions are fields; numeric values are working placeholders)

**Gate 1 — Bootstrap → Traction.**
Condition (working): first product shipped AND first real customer signed AND MRR > 0.
Subgenre-agnostic: B2C bar-fill and B2B signature feed the same evaluator. This kills the known `ready_for_traction` bug (previously `_check_traction` only ran in the B2C branch) architecturally — the fix lives here, not as a patch.
Frank beat (placeholder tone): "Bir şey sattın. Demek ki alan var. Şimdi soru şu: tekrar yapabilir misin?"

**Gate 2 — Traction → Series A Hunt.**
Condition (working): MRR ≥ traction threshold AND brand ≥ floor.
Runway is deliberately NOT a gate condition. A "broke founders can't fundraise" rule creates deadlock (the player who most needs money is locked out). Instead, low runway makes pitches harder (feeds the negotiation odds, §5). Frank at the door: "Runway'in dar. Girebilirsin, ama masada kokusunu alırlar."
The traction threshold itself needs recalibration ($5K MRR is far below a real Series A ~$1–2M ARR; map against game-time compression). Calibration item — numbers last.

**Gate 3 — Series A Hunt → ending.** No gate; the phase resolves through terminals (§4).

### 2.3 Ratchet rule

Once a gate opens, it stays open. MRR dipping back below the threshold does not re-lock it; phases never regress. (Otherwise the player is forced into a "hover above the line" micro-game — tycoon reflex, not our grammar.)

### 2.4 Frank scene behavior

- Queued as high-priority deterministic beat; reuses the existing EventModal surface (no new UI). The future Disco-style meeting-scene upgrade applies here later, together with the pitch scene.
- Player may decline ("henüz değil") — no penalty, but the next phase's vocabulary stays locked.
- Reminder cadence: Frank re-prompts every N days (working: 5) with escalating dryness. Third reminder: "Beklemek de bir karar. Kirasını sen ödüyorsun."

---

## 3. Endings Evaluator (daily tick slot 9)

Slot 9 scans terminal conditions daily. On trigger: emit `run_ended(ending_id, ending_data)`, set `GameState.run_active = false`, halt the tick loop. The ending screen listens to this signal (demo: simple summary modal first; cinematics are content/polish phase).

**Decoupling principle:** the evaluator listens to GameState fields (`series_a_closed`, cash, brand, …), never to systems. Whoever writes the field later (VC pitch system, brand system) plugs in with zero retrofit.

Two trigger classes:

- **Class A — instant terminals:** fired by a played moment (signature, acceptance), do not wait for the daily tick.
- **Class B — scanned terminals:** detected by the daily slot-9 scan.

---

## 4. Ending taxonomy — 7 endings

### 4.1 Series A Close — Hard Win (Class A)

Trigger: term sheet signed at the negotiation table (§5).
Variants are not chosen or rolled — they are the photograph of the table the player left. Low dilution + no board seat reads as Founder-Friendly; high valuation + veto given reads as Aggressive. The ending screen copy and the Tier 2 seed (board war vs. clean cap table) derive from the actual signed terms.

### 4.2 Acquisition — Soft Win (Class A) — IN for demo (Erdem, 2026-07-13)

Trigger context (working): brand 30–50 AND phase = Series A Hunt AND ≥1 pitch rejected — the "struggling but not failing" band. Arrives as an event → decision modal: accept = instant soft win ("you sold, but you didn't quite win" register); reject = run continues.
The design value is in the drama of refusing, which costs nothing extra. Cheap to build: one event + one modal + one screen.

### 4.3 Bankruptcy (Class B) — with the Shutter Counter

Cash < 0 does not kill instantly. It starts a visible red counter in the TopBar: "Kepenk: 7 gün." (Working value: 7. Erdem: maybe 10 or 14 — calibration item.)

- Cash returning positive resets the counter.
- Counter reaching zero = shutter down, bankruptcy ending.
- Frank, the evening it starts: "Kırmızıdasın. Yedi günün var. Ya bir şey sat, ya bir şey kes."
- Extension socket: the counter is designed so a future loan / friends-and-family cash injection mechanic can reset it. Loan mechanic itself is DEFERRED BACKLOG — do not build now. Reserve the seam only. Frank's line gains a third clause ("ya da birinden borç iste") when the mechanic ships.

### 4.4 Brand Collapse (Class B)

Trigger (working): brand < 15 AND no recovery for 30 days AND active scandal. Rarest ending; must be avoidable. Demo: trigger exists, routes to the shared loss screen framework (no bespoke cinematic yet).

### 4.5 VC Rejection Cascade (Class B) — with the escape hatch

Trigger: 3 pitch tables closed without signature (see §5.5 for what "closed" means) AND pivot window closed.
Escape hatch: at the third closed table, if metrics are alive (working: MRR ≥ threshold AND cash positive), Frank offers the pivot: "Belki bu yıl değil. Belki bu şirket değil. Ama sen bitmedin." → player may pivot to the bootstrap path; run continues to Day 180 with a shot at Profitable Bootstrap (§4.6). If metrics are dead, cascade = loss screen.
A hidden corridor from lose to win — the player who discovers it writes our Steam review for us.

### 4.6 Time-out fork (Class B, Day 180)

Reaching Day 180 is not an ending — it is an evaluation:

- Conditions met (working: cash never went below zero AND net-positive last 90 days AND no unmanaged major scandal AND MRR ≥ threshold) → **Profitable Bootstrap** (rare win, indie-hero register): "Onlara ihtiyacın yokmuş. Gerçek bir şey kurdun."
- Conditions not met → **Running on Fumes** (soft loss): calendar keeps flipping, founder puts head on desk, soft fade. "Kaybetmedin. Sadece kazanmadın."

Same trigger moment, two opposite emotions; the collision resolves inside the design.

### 4.7 Win budget (against the ~70% pillar — calibration targets, not promises)

| Outcome | Target share |
|---|---|
| Series A Close (hard win) | ~45–50% |
| Acquisition (soft win) | ~8–10% |
| Profitable Bootstrap (rare win) | ~5–8% |
| **Total wins** | **~60–68%** |
| Bankruptcy | ~15% |
| Running on Fumes | ~10% |
| Brand Collapse + Cascade | ~5–7% |

Numbers come from playtest; the budget exists now so we know what we are tuning.

---

## 5. Series A Hunt & the Term Sheet Table

### 5.1 Hunt phase structure

- **InvestorRegistry:** 4–5 VC firms, each with a personality + term preference (e.g., founder-friendly but low-valuation; aggressive but generous; sector-specific). Mirrors the Character/CustomerRegistry pattern, including forward-compat fields.
- **Pitch** = reuse of the proven B2B SkillCheck meeting grammar (Disco interior monologue + dialogue). No new interaction pattern; the proven one at maximum stakes. Upgrades to the meeting-room scene together with B2B when that ships.
- **Pitch outcome:** TERM_SHEET / REJECTED / CALLBACK ("grow the metrics, come back"). Rejection counter visible in Hunt UI: "2/3." The cascade is never a surprise.
- Dramatic engine of the phase: pitch calendar vs. runway, both on screen, both counting.

### 5.2 The Term Sheet Table — push-your-luck negotiation

Successful pitch → the VC puts an opening offer on the table. Three levers, all visible:

| Lever | Example opening | Player pushes |
|---|---|---|
| Valuation | $18M | up |
| Dilution | 22% | down |
| Board | 1 seat + veto | remove seat / drop veto |

The opening offer is written by run state: MRR, brand, runway, scandal history, and leverage (§5.4). The 180 days the player already played determine the quality of the table before it opens — §10 at macro scale.

Loop — each turn the player does one of:

- **SIGN** — take the table as-is. Always available, always safe.
- **PUSH one lever** — a visible-odds skill check (Disco register: "Zorlu — %58"). Player confirms → the roll runs. Roll presentation = the dial (The Great Rebellion reference): needle spins, lands green or red. The dial lives here as presentation of a chosen move, not as a one-shot fate machine. (Same dial language may later back-port to pitch SkillChecks.)
  - Success: the lever moves the player's way.
  - Failure: lever doesn't move AND VC patience drops by one.

### 5.3 Patience & the final offer

Visible patience gauge (working: 3–4 units; pool size may scale with founder skill — high charisma = the VC stays at the table longer. Working call.).
When patience hits zero the VC does not withdraw — the table locks into a take-it-or-leave-it final offer: sign what's on the table, or walk. Walking = the table counts as closed (feeds the cascade counter §4.5). The player always holds something until the last moment; what loses the run is greed, not the table.

### 5.4 Leverage

A second term sheet in hand (from another VC) grants a significant bonus to all push odds. Frank at the table: "İki teklifin var. Bunu onlar da biliyor."
This single rule makes the 3-pitch calendar tactical: sign the first offer, or risk the clock for a second table? Runway melts, patience counts, calendar narrows — three systems squeezing each other.

### 5.5 What counts as a "closed table" (cascade accounting)

REJECTED pitch = closed. Walking from a final offer = closed (counts fully, not half — working call: the cascade definition is "3 tables closed," regardless of how). CALLBACK ≠ closed.

### 5.6 Skill philosophy (Erdem, locked)

VC archetypes set the slope, never lock a door. A high-skill founder can win both high valuation and founder-friendly terms at the same table. Archetype shapes the opening offer and patience; skill + nerve does the climbing.

---

## 6. Ending screen anatomy (one framework, seven content sets)

- **Newspaper headline** — variant-specific (victory front page for wins; single column under a shuttered-storefront photo for bankruptcy).
- **Run summary** — 4–5 lines compiled from Month-End Summary data ("12 müşteri, 2 kayıp / 5 hire, 1 churn / 3 skandal, 2'si yönetildi / $4M @ $22M valuation, %18 dilution").
- **Frank reflection** — 1–2 sentences, NPC register (short, dry). Tone benchmark: "Kompromat'ı leak etmek yerine VC favor'una çevirsen daha iyi olabilirdi. Ya da olmazdı. Bilmiyoruz."
- **Retry block** — "Tekrar dene" / "Farklı subgenre" / "Hard mode unlocked" (her ending'de görünür — kayıplar dahil; demo'da visible-locked).
- **Tier 2/3 teaser + Wishlist CTA** — on every ending, losses included.

Demo ships the framework with simple layouts; 30–45s variant cinematics are content/polish phase.

---

## 7. Zero-gap ledger — resolved edge cases (copy into specs verbatim)

1. **Priority chain (multiple triggers, same day):** Class A (instant) > Class B (scanned). Within Class B: Bankruptcy > Brand Collapse > Cascade > Time-out fork. (Day 180 + shutter counter expiring same day → Bankruptcy; the more specific wins.)
2. **Terminal > gate:** if the run ends, any queued Frank transition scene dies. Slot order is already 8→9, but if slot 9 fires, that day's pending scenes are cancelled.
3. **World stops after terminal:** `run_active = false` → slots 1–8 do not run, event queue flushes, ticker freezes. No MRR accrues behind the ending screen (otherwise run-summary numbers contradict the screen — classic missed bug).
4. **Ratchet × shutter interaction:** if the shutter counter starts while a gate is open, the Frank transition scene is held — he cannot say "hazırsın, büyü" and "7 günün var" simultaneously. Shutter resolves or run ends; then the transition returns.
5. **Acquisition × shutter:** an acquisition offer CAN arrive while the shutter counter runs — deliberate ("sell while sinking" is the demo's most bittersweet decision moment). Working call.
6. **Pause-gated UI:** ending screen, Frank scenes, shutter modal, term sheet table — all must be clickable while SceneTree is paused → `process_mode = ALWAYS (3)`, stated explicitly in every relevant spec (known agent trap; they default to INHERIT).
7. **Serialized state** (fields defined now, SaveManager plugs in later): phase, phase_gate_ready, shutter counter day, VC rejection count, pivot window flag, patience per table (if table can persist across a save — working call: table is a single sitting, no mid-table save; field reserved anyway), run_active, ending_id. Forward-compat pattern.
8. **Debug hooks:** F-key forcing for every ending (7 endings × testability). `series_a_closed` must be settable via debug before the VC pitch system exists — the hard win is testable from day one.
9. **Fields, not systems:** slot 9 reads GameState fields; it never knows who wrote them. VC pitch ships later, writes the field, endings connect automatically. Zero retrofit.
10. **Frank scene reminders don't stack:** one pending transition scene maximum; reminders re-surface the same scene, never queue duplicates.
11. **Decision-modal focus:** default focus must never rest on a choice/decision control; `ui_accept` must never blind-confirm a decision (Kepenk-warning incident, 2026-07-13). Single non-destructive continue buttons (e.g. the Month-End Summary's DEVAM ET) are the explicit exception and MAY take default focus. *(Status note: EventModal is structurally compliant — choice cards are focus-less, mouse-only PanelContainers.)*

---

## 8. UI surface map & mockup plan

| Surface | New/Reuse | Mockup needed? |
|---|---|---|
| Slot 8/9 engines | New, logic-only | No |
| Frank gate scenes | Reuses EventModal | No (upgrades later with meeting-scene) |
| Shutter counter, rejection counter, phase indicator | Small TopBar elements | No — spec-level, UiTokens |
| Term Sheet Table | New interaction surface (levers, patience, push bar, dial, SIGN/PUSH/WALK) | Yes — Claude Design |
| Ending screen (newspaper) | New; top wishlist-conversion asset | Yes — Claude Design |
| Month-End Summary | New, single screen | Yes — same Claude Design session |

Mockups do NOT block Specs 1–2. Engines land first with placeholder modals; the three mockups follow (Claude Design → Erdem picks by eye → screenshot + spec → agent).

---

## 9. Sequencing

1. This document → canon (done).
2. Narrow read-only audit (Fable): current state of TimeManager slots 8/9, GameState.phase writability, exact location of `_check_traction` B2C branch, EventBus signal inventory. Output: dated markdown in `docs/audits/`.
3. **Spec 1 — Phase Transition Engine (slot 8):** gate evaluator (subgenre-agnostic), `phase_gate_reached`, `advance_phase()` seam, Frank scene hook (placeholder line), B2B traction gate fix.
4. **Spec 2 — Endings Evaluator (slot 9):** terminal scan, `run_ended`, `run_active` halt, Bankruptcy + shutter counter, Series A close flag listener, Brand Collapse + Cascade guards routed to shared loss framework, time-out fork, debug F-keys, simple summary modal.
5. Claude Design session: Term Sheet Table + Ending screen + Month-End Summary.
6. UI specs on top of picked mockups; then VC pitch system (writes `series_a_closed` for real); then calibration pass (thresholds, win budget, shutter length).

**Deferred backlog (unchanged + one addition):** loan/credit mechanic (shutter escape hatch seam reserved), HR hire flow → R&D → skill tree, SaveManager, multi-product, support/ticket system, build-flow tutorial, event system full rebuild, pitch modal → Disco meeting-scene, Sales post-signature B2B lifecycle.

---

## 10. Open calibration items (numbers last — do not tune before the skeleton runs)

- Traction MRR threshold (game-time compression mapping)
- Shutter counter length (7 vs 10 vs 14 days)
- Patience pool size + skill scaling
- Push odds formula (skill + context + leverage weights)
- Win budget percentages (§4.7)
- Day 180 wall (only if 60–90 min target misses)
- Gate 2 brand floor value

---

## Package 5 Canon (2026-07-14) — Runway model + feature bug-seeding + localization

**Runway is TWO distinct, both-real metrics — never one bare number:**
- **Net Runway** (shell TopBar / Month-End summary): revenue-aware, `cash ÷ (daily_burn − daily_revenue)` in months. When `net_burn ≤ 0` (break-even or better) it is **default alive** — shown as **"Kârlı"** (TR) / **"Default Alive"** (EN), never "∞". Finance-badge warning only on low FINITE months, never on profitability. Single presentation helper: `UiTokens.net_runway_parts` / `net_runway_text`.
- **Gross Burn Runway** (VC pitch): cash-only, `cash ÷ daily_burn` in months, always finite — the "if revenue went to zero, how long do you last?" question a VC actually asks. Labeled **"Brüt Runway"** (TR) / **"Gross Burn Runway"** (EN). `VCPitchSystem._gross_runway_months`.
- The distinct **labels** are what keep "Kârlı" (shell) and "Brüt Runway: 8 ay" (pitch) from reading as a contradiction. Never show an unlabeled runway number in the pitch.

**"Yeni feature = yeni bug" is enforced by complexity-based bug-seeding at build commit:** each NEW feature entering a build seeds `round(complexity × FEATURE_BUG_SEED_COEF)` bugs (`product_system.gd`), flowing through the normal `bug_count → effective_stability → mvp_live_bug_count` channel — separate from the hourly dev-phase accrual. The **hardening / "sağlamlaştırma" path seeds ZERO feature bugs** (only `typed_new` seeds; a strengthen-only version build has none) — the deliberate "features = risk, hardening = safety" strategic axis. Working value: `FEATURE_BUG_SEED_COEF := 1.0`.

**Localization:** Turkish is canonical; English is the literary translation via Godot `TranslationServer` + `localization/strings.csv` (loaded at runtime by the `Localization` autoload), with a language toggle in Settings. See CLAUDE.md LANGUAGE INTEGRITY LAW (reframed 2026-07-14).
