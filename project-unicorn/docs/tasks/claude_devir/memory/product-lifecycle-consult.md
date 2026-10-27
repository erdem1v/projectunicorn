---
name: product-lifecycle-consult
description: "Product loop consulting review 2026-08-17 — findings, the one calibration number that gates everything, and which lanes are safe for playtesting"
metadata: 
  node_type: memory
  type: project
  originSessionId: d9c5753e-688f-4c57-88a5-b2b9ed7d2429
  modified: 2026-08-17T08:29:21.616Z
---

**Product Lifecycle consulting review delivered 2026-08-17** → `docs/audits/product_lifecycle_consult_2026-08-17.md` (English, read-only, anchored to `a683ab1`).

**The verdict:** the loop is well-built and badly wired to the player. Post-ship is not dead — it is *mute and mis-calibrated*.

**The one number that gates every other fix (R1):** `QualityModel.NORMALIZE_HALF_SAT = 50` is scaled for the retired grown-axis model. `normalized_quality(c)=100c/(c+50)`, so a genuinely played v1 (raw Kararlılık ~18) yields `axis_score` **26.5**, while `B2BConstants.seed_tolerance` floors at **35**. `B2BSalesSystem._satisfaction_target` IS that score → **every B2B account is born below tolerance** → `RISK_TRIGGER_DAYS`=3 → a retention modal every 3 days forever. Do not ship v2-picker/report-card work before this moves; an informed choice that still fails reviews worse than an uninformed one.

**Axes truth (Calibration Law 4 fails 2 of 3):** İnovasyon has **zero** B2B mechanical readers; Deneyim's only B2B effect is half the `PitchSystem.signing_satisfaction_seed`, erased by the drift toward a stability-only target in **~3 days**. On B2C both enter only via the weighted composite → perfectly fungible. Per-type `QUALITY_AXES` weights are returned by `get_quality_axes` and **rendered by nobody**.

**Already-stamped, never-read (the cheap wins):** `mvp_innovation_prev/_stability_prev/_experience_prev` (written `product_system.gd:908-910`, comment names the intended reader) and `bug_count_at_bugfix_start_<id>` (`:523`) — the director's "report card" is ~90% built. Also fully dead catalog fields: **`pull`, `stakes`, `bet`, `pitch`** (zero readers each).

**The proof the design is right:** controlled probe pair, identical worlds, differing only in whether the founder built what he promised — `b2b_slip` **65** retention modals / 0 expansions / no Series A vs `b2b_slip_keep` **1** modal / 5 expansions / Series A reached.

**Playtest lane safety (learned the hard way):**
- `--run-log=<preset>:<days>:<mode>` (RunProbe) is the reliable bridge; presets `b2c, b2b_solo, b2b_risk(_keep), b2b_slip(_keep)`, seed pinned 424242.
- **Do NOT drive the game with OS-level clicks + screen capture on this machine.** Parallel sessions launch their own windowed Godot instances and steal foreground; my capture then photographed one of Erdem's own windows (deleted unread). Use `--product-shot=<kind>` instead — it captures the game's own viewport internally, no screen grab.
- Add a `--audit-*` flag to any hand-driven launch: `SaveManager._is_harness_run()` substring-matches `audit`, so autosave stays off and Erdem's save slots are untouched.
- Godot keeps only ~5 rotated logs; a parallel session's runs will rotate yours away within minutes.

Related: [[project-unicorn-current-stage]], [[concurrent-session-hazard]], [[godot-mcp-runtime-verification]], [[b2b-sales-system]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Product lifecycle consult](product-lifecycle-consult.md) — 2026-08-17 review; NORMALIZE_HALF_SAT=50 puts every played B2B product under tolerance (gates all other product fixes); İnovasyon/Deneyim not load-bearing; report-card data already stamped; no OS-click playtesting on this machine · **HALF_SAT re-seat DONE 2026-08-19 in Calibration Round A (branch calibration-round-a, not merged)**
