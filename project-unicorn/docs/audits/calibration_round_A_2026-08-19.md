# Calibration Round A + Cleanup — 2026-08-19

**Date:** 2026-08-19 · **Type:** Calibration package (post-localization, no deferrals) · **Branch:** `calibration-round-a` (worktree `../project-steam-calib`) from `1867213`, one commit per section
**Instrument:** `--run-log=<preset>:<days>:sim` (RunProbe, seed 424242, same preset before/after every numeric change) · smoke cases counted from source · `loc_residue.gd` · TR/EN shot matrix read by eye
**Companions:** `product_lifecycle_consult_2026-08-17.md` (the diagnosis), `playable_run_sprint_2026-08-17.md` (the instrument), `lifecycle_structural_research_2026-08-18.md` (the structure). This document is the measured answer to their shared first ask: *move the constants before touching the design*.

---

## 0. Executive summary

Fifteen code commits + this report. Every numeric change below is proven by a before → after probe pair at the same seed and at least one falsification (revert one line, watch the right case fail with the right diagnosis, restore). Every new player-facing string was born TR+EN in the commit that needed it (`loc_residue` 0 hits, 1,774 → 1,793 keys, no dashes in new copy).

| What the consult measured at `1867213` | After this package (same seed, same presets) |
|---|---|
| A played B2B v1 lands 15–30 points under every account (`axis(13)=20.6` vs bars 40–50) | The competent v1 reads target **55** against bars 42/45/51/56 → ~60 % of a demo book satisfied at ship; the weak v1 reads 42 → ~20 % (§1) |
| `full_run:180` · 630 retention modals (one account 49), 619 discount answers, 25.8 modals/week, peak MRR $7,333 → $3,051 at the day-180 wall | `full_run:730` · 16 retention cards in 275 days (max 5 per account, ≤ 1 per 30 days), 4 discount answers, **1.9 modals/week** (median 2, max 5 — inside the 2–3/week budget), MRR $38,983 plateau, `MRR_end/peak = 1.0` |
| Run stops on day 180 regardless of state | No calendar stop; `SOFT_CAP_DAY` 730 → `running_on_fumes` ("İlgi Söndü / Interest Faded") only if no ending fired; the played run ends **`profitable_bootstrap` on day 275** |
| Series A bar $5,000 (gate crossed day 74) | Bar $40,000 + 3 months ≥ 12 % MoM + brand; the number is never rendered — Finance/product/ODA paint `KAPALI · ISINIYOR · AÇIK`. Played B2B: ISINIYOR month 3, back to KAPALI month 7, AÇIK never (plateau $39K, prospect pool exhausted — Layer B finding, bar not lowered) |
| B2C audience is a fixed point | Word of mouth compounds on satisfaction both ways: maintained fixture $975 → $47,310 MRR in 180 days (AÇIK day 124); neglected 645 → 15 |
| `İndirim ver` uncapped, harvestable through the Sales tab | Cap 2 per account on both channels, 21-day risk hysteresis, the row stays visible and locked with a reason; the button and the sweep share one gate |

Gates at HEAD: smoke **210/211 from source** (the one failure `ui_scale_ladder_fits_settings` is pre-existing at `1867213` and belongs to another session's uncommitted `display_settings.gd`, see section 7) · `loc_residue` 0 · `loc_csv_integrity` + `loc_format_args` PASS · 71 shot kinds × TR/EN re-taken (142 launches, 0 script errors) and every changed surface read · `--theme-audit=oda` byte-same (124 lines, md5-equal against a base worktree under identical user settings) → ODA untouched per law.

---

## 1. Table per section

Presets are `--run-log=<preset>:<days>:sim`, seed 424242. "Base" = `1867213`, "After" = the section's commit; "Final" = HEAD where it differs because later sections moved the same number again.

### §0 · Worktree, baselines, harness hygiene — `e35ccac` + `f337e65`
| Item | Before | After |
|---|---|---|
| `SaveManager._is_harness_run` | did not match `--run-log` → probe runs autosaved fixture worlds into the player's slots | `_is_harness_arg(arg)` static (flags only: `smoke|-shot|audit|spec|run-log`); smoke `harness_sniffer_matches_run_log` |
| Baseline probes | `b2b_solo:90` 2 retention · `b2b_slip:90` 65 (7/29/29) + 51 discount picks · `b2b_slip_keep` 1 · `b2b_risk:90` 142 + 112 discounts, MRR 2,700 → 68, 0 churn · `b2c:180` peak 4,275@d48 → 1,185 · `full_run:180` 630/619/25.8 per week · `full_run:730` **stops day 180** (calendar wall proven) | — |

### §1 · Played product born inside the tolerance band (three levers together) — `0d34201`
| Constant / formula | Before → After | Preset · number before → after | Verdict |
|---|---|---|---|
| `QualityModel.NORMALIZE_HALF_SAT` | 50 → **25** | axis(raw): 6→19.4 · 13→34.2 · 17→40.5 · 31→55.4 (was 13→20.6, 31→38.3) | ✓ |
| `B2BConstants.TOLERANCE_BASE / PER_SCALE` | (35, 5) → **(33, 9)** [ÖLÇ] — bars small 42 · small+insurance 45 · mid/enterprise 51 · +health/construction 56 | measured T_good 55 / T_bad 42 (see section 2 of this report) | ✓ |
| `saas_ops_field.requires_research` | true → **false** (the unlocked 3-feature demo v1 capped at raw 13; now 17) | competent set integration+field+scheduling: catalog 17 + build events +14, Beta cleared → raw 31, 0 bugs at ship d25 | ✓ |
| `SalesSystem.SATISFACTION_QUALITY_GATE` + axis | 70 on STABILITY → **40 on EXPERIENCE** (director ruling; consumer pools have ≤ 3 stability raw) | B2C satisfaction drift +1/day now reachable for a played B2C v1 | ✓ |
| `QualityModel.RIVAL_TEMPLATE_HALF_SAT` (bridge) | — → **50** (rivals are authored on the retired grown scale; one reader `_rival_relative_quality`) | played v1 rival-relative `q` ≈ 38–40 instead of ~22 | ✓ (Layer B: re-author the table) |
| `PROD_FEAT_SAAS_OPS_FIELD_VOICE` EN | copy of MOBILE's line → rewritten | — | ✓ |
| `b2b_slip:90` retention | 65 → 57 (≤ 2 accounts under) → **11 final** (§8 hysteresis: 5/5/1, cadence d4·25·46·67·88) | target "< 10": **missed by 1** — knob `RISK_REENTRY_DAYS` 28 gives 7 (director Q1) | ~ |
| `b2b_slip_keep:90` | 1 → **0**; 5/5 satisfied from day 7 | — | ✓ |
| `b2b_solo:90` `PROBE SAT` | 5/5 always (old scale) → 4/5 d2 (signing seed) · **2/5 d7–d60 · 1/5 d90** as bugs accrue; ≥ 2 distinct phases at d90 | — | ✓ states spread |
| `b2b_risk:90` | 142 cards, 0 churn → 23 cards (all "Söz ver"), **0 churn**, 0/5 satisfied from d14, MRR flat 2,700 | target "≥ 4 churns" **not met** — the promise channel is uncapped (finding F3) | ✗ → Layer B |
| `b2b_risk_keep:90` | — → 10 cards, 5 discounts, 5/5 satisfied from d45, MRR 5,894 | the rescue path works in ~40 days | ✓ |
| `full_run:180` | retention 630 → **28** (max 11), discounts 619 → 22, modals/week 25.8 → **2.96**, peak MRR 7,333 → **32,970**, d180 MRR 3,051 → 32,833, ending running_on_fumes → profitable_bootstrap (old fork) | — | ✓ |
| `full_run_weak:180` | — → MRR 30,836, retention 55 (max 14) | the weak set catches up through versions | info |
| `b2c:180` side-effects | peak 4,275@d48 → 3,675@d39; d180 1,185 → 1,050; `q` 40.4 → 22.1 (bugs 0 → 47, no sprints), sat 41 → 83 | handed to §5/§6 | info |
| Smoke | +5: `quality_half_sat_25`, `b2b_v1_lands_mid_band` (three-levers guard with the measured raws), `field_unlocked_for_saas_ops`, `b2c_satisfaction_gate_experience`, `rival_relative_uses_template_half_sat`; 80 affected cases 80/80 | — | — |

Probe work in the same commit: presets `full_run_weak`, `b2c_keep`, `b2c_neglect`; competent policy builds integration+field+scheduling and waits in Beta (bugs ≤ 3 or 5 days); fixtures are derived **by formula from intent lines** (solo: axis mid of [T_small+3, T_mid) with 4 bugs → raw 26.3; slip: T_mid+2 live with 9 bugs → raw 35.4, clears to 58.6; risk: T_small−8 with 14 bugs → raw 12.9) with a `PROBE FIXTURE` line and a `PROBE ERROR fixture drifted` self-check; new lines `PROBE SHIP`, `PROBE SAT satisfied=k/n target=`, and `aud/sat/bugs/q` on `PROBE STATE`.

### §2 · Calendar wall off · soft cap → `running_on_fumes` rewritten — `abc9617`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `EndingsSystem.RUN_END_DAY` 180 + `_check_day180_fork` + `NET_WINDOW` 90 + `GameState.net_history_90` + `cash_went_negative` | retired (ruling: `month_history` replaces the 90-day ring; per-month `red_days == 0` replaces the lifetime latch) | `full_run:730` runs to day 730 (base stopped at 180) | ✓ |
| `SOFT_CAP_DAY` | — → **730** [WORKING]; scan order cascade → profitability → soft cap → acquisition; **no deferral for a live sheet** (VC_PITCH_DESIGN ledger 16) | ends `running_on_fumes` day 730 when nothing else fired; `run_ledger.unsigned_sheets` | ✓ |
| D-1 warning | `DAY180_WARN_DAY` 179 / `_tick_d179` / flag `vc_d179_warned` → `SOFT_CAP_WARN_DAY := SOFT_CAP_DAY − 1` / `_tick_soft_cap_warning` / `ev_vc_soft_cap_warning` / flag `vc_soft_cap_warned` | smoke `soft_cap_warning_day` | ✓ |
| `running_on_fumes` paper | id/tone kept; all `END_RF_*` rewritten in the "investors lost interest" register; title **"İlgi Söndü / Interest Faded"**; Frank = Y5.6 verbatim; `_span_phrase` gains "bir yılı aşkın / iki yıla yakın" (`OVER_YEAR_DAYS` 380, `TWO_YEAR_DAYS` 700); unsigned-sheet line | `--ending-shot=running_on_fumes` TR/EN (alias sets day 730 + one unsigned sheet) read clean | ✓ |
| `END_EV_PIVOT_BODY` | last paragraph: no `{day}`, no dash; `{months}` = `PROFIT_STREAK_MONTHS` | — | ✓ |
| `CASH_HISTORY_CAP` | 200 → 760 | — | ✓ |
| Measured at §2 | `full_run:730` → day 730 `running_on_fumes`; MRR 32.5K@d180 → plateau 33–34K (peak 34,386@d221) → 32.6K@d730 (book stops at 25 accounts); cash 64K@180 → 511K@730; retention 92 (two accounts 36/43), fires/week 1.75 | the profitability condition (§9) fires long before the cap on this policy | info |
| Smoke | `fork_win/fork_loss` retired; +5 `soft_cap_ends_run_at_730`, `no_calendar_stop_before_cap`, `soft_cap_no_defer_for_sheet`, `soft_cap_warning_day`, `soft_cap_paper_names_unsigned_sheet`; 44/44 | — | — |

### §3 · Series A bar to canon — number hidden, signal visible — `9300600`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `GameState.month_history` | — → ring of 12 all-INT closes `{start_day, end_day, mrr_close, income, expense, net, red_days}` pushed by `MonthSummarySystem._close_fiscal_month()` (slot 10, before the recap emit; accruals via `accrue_month_flow` from the finance tick and `accrue_month_expense` from one-time costs; angel income is financing → not accrued); getters `get_mrr_growth_streak(pct)` (integer compare, prev ≤ 0 never counts), `get_profitable_month_streak()`, `get_window_margin_pct(n)`; `run_ledger` += `months_closed, profit_streak`; one-day lag (close at slot 10, readers next day) accepted and documented | smoke `month_history_close_and_cap`, `growth_streak_semantics`, `month_history_save_typing` | ✓ |
| Condition `mrr_growth_streak {value, pct}` | — → in `is_condition_met` | — | ✓ |
| Gate 2→3 | `mrr_above 4999` → `mrr_above bar−1` + `mrr_growth_streak 3 @ 12 %` (`GROWTH_STREAK_MONTHS`, `GROWTH_MIN_PCT` [WORKING]) + `brand_above 24` | `series_a_gate_needs_streak` (falsification guard) | ✓ |
| `SalesSystem.TRACTION_MRR_TARGET` | 5,000 → **40,000** [ÖLÇ rule → band floor]; never rendered as a figure; `TRACTION_CUSTOMER_TARGET` + `traction_progress()` retired; `SEED_MRR_REFERENCE` follows | played B2B peak $34.4K (§3 commit) / $38,983 (HEAD) < bar | ✓ (bar not lowered — ruling) |
| `PhaseGateSystem.series_a_signal()` | — → `{state closed|warming|open, mrr_ok, streak_ok, brand_ok, streak, streak_need, mrr_progress, progress}` — the single home | `series_a_signal_states` | ✓ |
| UI | Finance: disabled "TUR AÇ · SERIES A" button → `INV_APPETITE_TITLE` + chip (`KAPALI` muted / `ISINIYOR` amber / `AÇIK` positive) + line (`INV_APPETITE_LINE "Gelir çıtası {bar} · büyüme {streak}/{need} ay"` with `INV_BAR_BELOW/CLEARED`; `_TOO_EARLY` phase 1, `_GATE_OPEN`, `_HUNT`), tooltip lists the gate rows without numbers (`FIN_REQ_MRR_BAR`, `FIN_REQ_GROWTH`, `FIN_REQ_BRAND`); repaints on `month_ended/phase_gate_reached/phase_changed` · Product detail traction strip: title/chip/bar = `sig.progress`/line (`PROD_MRR_OF_TARGET`, `PROD_TOWARD_TRACTION` retired) · ODA goal card phase 2: `ODA_GOAL_SIGNAL "{state} · büyüme {streak}/{need} ay"` + progress bar, refreshed on day advance, no new nodes | `--finance-shot=ozet|signal`, `--product-shot=detail_b2b|detail_b2c`, `--oda-shot=day` TR/EN read; `--theme-audit=oda` byte-same | ✓ |
| `full_run:730` signal | — → closed → **ISINIYOR day 91** (month 3, growth +247 %), streak 4 months (m3–m6: 247/64/41/15 %), **back to KAPALI day 213** (m7 +3.9 %), AÇIK never | target "ISINIYOR/AÇIK month 12–16": ISINIYOR early (m3), AÇIK unreachable on the B2B path inside 24 months → finding F1 | ✗ → Layer B |
| `b2c_keep:180` signal | — → ISINIYOR day 60, **AÇIK day 124** (bar + 3-month streak) | the B2C path can cross the bar (fixture head start: 200 audience, $60K) | info |
| VC fixtures | `_seed_b2b(6000)` → `_seed_b2b_series_a()` (bar + 1,000) + `_seed_month_closes` / `_seed_growth_streak` for the five VC cases, `gate2`, `angel_fires_at_crossing` | 53 affected cases 53/53 | ✓ |
| Old $5K checkpoint | no phase system needs an early-traction checkpoint (gate 1 = shipped + 1 customer + MRR > 0) | report only | — |

### §5 · B2C growth compounding, both directions — `b4dd193`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `_audience_delta_per_hour` | absolute growth vs proportional churn (fixed point) → `grow *= clamp(sat/WOM_MULT_PIVOT, WOM_MULT_MIN, 1)` · `grow += audience · WOM_COEF · max(0, sat − WOM_SAT_GATE)/100`; `sat` = the B2C aggregate record's satisfaction (50 when no record → pre-launch flow untouched); churn term unchanged; `growth_band()` follows | — | ✓ |
| `WOM_COEF` [ÖLÇ] sweep (`b2c_keep:180`, 30-day MRR means M1..M6) | 0.000 → 2083/3704/3828/3411/2849/2198 (peak month 2, −43 %) · 0.003 → …13082/10229 (falls m5–6) · 0.004 → …27465/23723 (falls m6) · **0.005 → 2506/9429/23964/44528/64502/66614 (monotone; smallest passing)** · 0.007 → …246,846 · 0.010 → …4.4M (explodes) | `M_{k+1} ≥ 0.98·M_k` ∀k and `M6 = max` at 0.005 only | ✓ |
| `WOM_SAT_GATE 60 · WOM_MULT_PIVOT 50 · WOM_MULT_MIN 0.3` [WORKING] | — | `b2c_neglect:180` MRR 645 → 15 (audience 200 → 7, sat 0); `b2c` (legacy fixture, no sprints, 47 bugs) 3,150 → 600/month | neglect collapses ✓ |
| "weeks, not hours" | — | day-30 audience ratio WOM/no-WOM **1.5**, month-1 MRR ratio 1.2 | ✓ |
| Smoke | +2 `b2c_wom_needs_satisfaction`, `b2c_growth_multiplier_floor`; 23/23 | — | — |

### §6 · Bugs hit conversion — `b94b66d`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `SalesSystem.conversion_rate` | price curve only → `× max(BUG_CONV_FLOOR 0.4, 1 − live_bugs · BUG_CONV_COEF 0.02)` after the price clamp, re-clamped [WORKING: 10 bugs ≈ −20 %, 30+ bugs −60 %] | `--product-shot=detail_b2c` (5 bugs) DÖNÜŞÜM **%32** vs new `detail_b2c_buggy` (15 bugs) **%24**, TR/EN | ✓ |
| Probe | — | `b2c:180` (no sprints, bugs 60 → 97) day-180 MRR 1,710 → 690; `b2c_keep` (bugs ≤ 6) unchanged; audience curves identical (conversion does not touch audience) | ✓ |
| Smoke | +1 `conversion_bug_penalty` (expectation rebuilt from `product_value()` per bug level — bugs also lower the optimal price); 10/10 | — | — |

### §7 · Bug-complaint cost TYPE + copy — `23f8265`
| Item | Before → After | Verdict |
|---|---|---|
| `audience_delta` modifier | absolute only → gains `pct` (proportional, signed; mirrors `convert_audience`); badge `EFFECT_AUDIENCE_PCT "Kitle {pct}" / "Audience {pct}"` (locale `Fmt.percent`, sign colour) | ✓ |
| `ev_ps_bug_complaint.json` | two cash rows (−1,500 / −300) → **no cash**: "Herkesin önünde cevap ver" (satisfaction +10 · brand +2 · audience −3 %) · "Özelden yaz, konuyu kapat" (+6 · −1 · −1 %) · "Görmezden gel" (churn_customer · brand −2); title/subtitle (16:48 inside [9,18])/body/descriptions rewritten TR + EN, no dashes, no tab names, no refund | `--event-shot=ev_ps_bug_complaint` TR/EN read ✓ |
| Smoke | +2 `bug_complaint_costs_audience_not_cash` (every row: cash unchanged, satisfaction/audience move), `audience_pct_modifier`; 16/16 | — |

### §8 + §13 · Retention cap + hysteresis + locked row · one gate — `df178f1`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `Customer` | — → `@export retain_discounts: int = 0`, `@export last_risk_exit_day: int = -1`; registry seams `set_retain_discounts`, `set_last_risk_exit_day` | ride the SaveCodec walker | ✓ |
| `RETAIN_DISCOUNT_MAX_USES` | — → **2** [WORKING]; `apply_discount` guards past the cap on both channels (retention card + CS-request rows) | `full_run:730` discounts 87 → **4** (≤ 2 per account) | ✓ |
| `RISK_REENTRY_DAYS` | — → **21** [WORKING]; `_recover` and `_tick_healthy` stamp the exit; `_tick_at_risk` keeps counting the streak but refuses re-entry inside the window | retention fires per account `max30 ≤ 1`; `full_run:730` retention 92 → **43** (final 16/275 d), fires/week 1.27, MRR plateau 39,050, `MRR_end/peak` **1.0** | ✓ |
| Locked row | discount rows get `unlock_condition {"type": "b2b_discounts_below", "customer_id", "value": 2}` (new condition) + `description = B2B_DISCOUNT_SPENT_DESC` when spent ("İki kez indirim verdin. Bu hesabı fiyat değil ürün tutar." / EN), chip `KİLİTLİ` | `--b2b-shot=retention_capped` TR/EN read | ✓ |
| §13 `B2BSalesSystem.can_offer_retention(c)` | the Sales-tab `İlgilen` button was gated only on "no active modal" (harvest) → ONE gate (b2b · active · phase risk · countdown ≥ 0 · not delegated+escalated) used by `_maybe_enqueue_retention` and the button | smoke `retention_gate_shared`, `manual_retention_respects_cap` | ✓ |
| Presets | `b2b_slip` 57 → **11** · `b2b_solo` 87 → 16 · `b2b_risk` 142 → 23 | knob note: `RISK_REENTRY_DAYS` 28 → slip 7 | ~ (Q1) |
| Smoke | +6 `discount_cap_two_uses`, `risk_reentry_hysteresis`, `risk_exit_stamps_day`, `discount_row_locked_past_cap`, `retention_gate_shared`, `manual_retention_respects_cap`; 73/73 | — | — |

### §9 · Profitability = a condition, not a crossing — `ae6f63c`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `EndingsSystem` | day-180 fork on `net_history_90` → `profitability_signal()` single home `{streak, need, streak_ok, margin_pct, margin_ok, mrr_ok, scandal_ok, met}`; `_check_profitable_bootstrap()` daily after the cascade, before the soft cap; `PROFIT_STREAK_MONTHS 6 · PROFIT_MIN_MARGIN_PCT 15 · BOOTSTRAP_WIN_MRR 20,000` [all WORKING] (decoupled from the Series A bar); Artıda month = net > 0 AND red_days == 0 | `full_run:730` → 6th Artıda close day 274 → ending **day 275 (month 9)**, window margin ~80 %; `full_run_weak:730` → day 245 (ships 6 days earlier, first Artıda close one month earlier) | target months 18–20: **early by ~9 months** — the margin clause never binds because nothing scales cost with revenue (finding F2) |
| Finance | `_profit_progress` `FIN_PROFIT_PROGRESS "Artıda · {streak}/{need} ay"` (+ `_QUAL_MARGIN/_QUAL_SCALE` when the streak is complete but blocked; hidden until ≥ 1 close; tooltip `FIN_PROFIT_NOTE`) | `--finance-shot=signal` "Artıda · 4/6 ay" TR/EN read | ✓ |
| Ending copy | `END_BS_*` reviewed (no 180-day assumption); `END_BS_STREAK` line when `profit_streak > 0`; F8 seeds 6 Artıda closes; Ctrl+F9 → `SOFT_CAP_DAY − 1` | `--ending-shot=profitable_bootstrap` TR/EN | ✓ |
| Smoke | +2 `profit_condition_fires` (close day + 1; paper names the streak), `profit_predicate_margin_scale_red`; 23/23 | — | — |

### §10 · Speed ladder 1×/2×/3× — code + UI — `7aecd35`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `TimeManager.SECONDS_PER_DAY` | `[0, 12, 6, 3, 1.5]` → **`[0, 12, 6, 3]`** | `--tempo-probe=3` → 3,001–3,002 ms/day; `--tempo-probe=4` → "bad speed index 4" | ✓ |
| Bindings / UI | `game_shell` KEY_4 removed (4 inert, 1–3 work); `TopBar.tscn` `Speed4Btn` deleted; `top_bar.gd` 4-entry array (index == speed index); `oda_tour`/`event_bus`/`save_manager`/`run_probe` comments | `--tab-shot=finance` TR/EN: three chips + pause, nothing crossing | ✓ |
| Saves | stored `last_running_speed` 4 → clamps to 3 through the existing `clampi(…, size()−1)` | smoke `speed_save_clamps_to_ladder` | ✓ |
| Docs | TECH_SPEC §8.1 + Decision Log, PROJECT_SPEC :64/:254; **CLAUDE.md Law 2 "Fast 4x" left untouched** (law text — Q4) | — | — |
| Smoke | `speed_ladder` 4 entries/top 3/4 rejected; +2 `speed_save_clamps_to_ladder`, `topbar_speed_cluster_three_rungs`; 9/9 | — | — |

### §11 · Smoke RNG pin — `aad2f21`
| Item | Before → After | Measure |
|---|---|---|
| `EndgameSmoke.run_case` | `initialize_run` seeded from `Time.get_ticks_msec` → `payload["seed"] = 424242` when absent (a case that wants its own seed says so) | `angel_fires_at_crossing` ×12: **4 fails/12 → 12/12**; guard `smoke_seed_pinned` reads the seed from the ledger |

### §14 · S3-48 ambient rate model + hour-0 proof — `305e938`
| Item | Before → After | Measure | Verdict |
|---|---|---|---|
| `EventManager._is_eligible` | per-hour roll `chance / window_hours` (daily ≈ 1 − (1 − p/n)^n, 7–20 % under the authored number; bug_complaint 0.5 → ~0.40) → `hourly_chance(p, n) = 1 − (1 − p)^(1/n)` exact (0.5 over a 10-hour window → 0.0670/h, not 0.05/h); daily path rolls `p` as written; ≤ 1 ambient/day and priority order unchanged (S3-49 `slot_day` was already in place) | `--run-log=b2c:90:sim` and **real clock** `b2c:90:3` (4.5 min): ambient (random-trigger) cards per calendar day **max 1**, **0 at hour 0** (14 ambient cards / 90 days: producthunt 7, power_user 6, bug_complaint 1; beats such as `first_revenue`/`paid_tier` may share a day by design) | ✓ |
| Smoke | +2 `ambient_hourly_chance_exact`, `ambient_one_per_day_across_hour0` (30 full engine days, hour-0 slot credited to the new day); 17/17 | — | — |

### §15 · Giant headline / decision-log momentum field — verified absent (ruling)
Searched `giant`, `headline`, `momentum`, `decision_log`, `manşet`, `ivme` across scripts, scenes, themes, data, CSV, audits, plans; read the tab/oda/month/pitch/ending/event shots. Nothing dev-only with a momentum field exists. The final 71-kind TR/EN eye pass (section 7 of this report) found **no player-visible dev placeholder**; the only placeholder-like text in the whole matrix is the Ekonomi Postası image slot "GÖRSEL YAKINDA / ART COMING SOON", which is designed copy present at `1867213`.

### §16 · S2-33 draft-loss guard (PRESERVE, zero strings) — `f759479`
| Item | After | Measure |
|---|---|---|
| `center_viewport._on_tab_changed` | `_current_page.propagate_call("on_page_closing")` before `queue_free` (the free-and-rebuild stays — it is what makes language/palette refresh self-healing) | smoke `creation_draft_survives_navigation` (instantiate, dirty draft, close through the router seam, re-mount ProductTab → same step/type/features/name; clean flows stash nothing) |
| `creation_flow` | `on_page_closing()` stashes a dirty, unlocked, non-v2 draft `{step, market, type, features, name}` into the typed `creation_draft` flag; `draft_state()`; prefill accepts `market`; cleared on commit | covers Esc / ✕ / rail / ODA click-through / palette / language |
| `product_tab._ready` | consumes `creation_draft` after `cancelled_build_prefill` (only while no build is active and the MVP has not shipped) | 15/15 |

### §12 · Held-back strings — `719485f`
`SET_RESOLUTION_BORDERLESS` TR "Kenarlıksız mod her zaman ekranın doğal çözünürlüğünde çalışır." / EN "Borderless mode always runs at the display's native resolution." — the settings modal's `_resolution_note_key` picks it the moment it resolves (mechanism verified: the "HENÜZ YOK" note is history). `TOPBAR_UNIT_PER_DAY` `/g` · `/d` confirmed shipped (director approval). Smoke `borderless_note_key_exists`. TECH_SPEC Decision Log row 2026-08-19 (11 decisions + measured result).

### §4 · Frank seed — verified (report only)
`full_run:730`: ship day 25 → first revenue day 34 (`ev_ps_first_revenue` + traction gate) → `ev_angel_frank_seed` **day 40 at MRR $2,625** (> 2,500; once; $25K / 4 %, accepted → cash $30,400) → `ev_angel_hire_nudge` day 42 → first hire (developer, $6,300/mo) day 42. Seed-moment runway: net was already Artıda ($87/day revenue vs $50/day founder burn → INF); with the junior on payroll the gross runway is $29,451 / $260 per day ≈ **113 days**, net ≈ 170 days — "~100+ days with one junior" holds.

---

## 2. Where each [ÖLÇ] / [WORKING] landed

| Constant | Tag | Landed | The measurement that chose it |
|---|---|---|---|
| `B2BConstants.TOLERANCE_BASE / TOLERANCE_PER_SCALE` | [ÖLÇ] | **33 / 9** | `--run-log` T_good = 55 (competent v1: integration+field+scheduling, catalog 17 + build events +14, Beta-cleared raw 31) and T_bad = 42 (weak set, catalog 6 + events +12, sprinted raw 18.3). The director's fractions for the probe's 5-account book (2 small · 2 mid+sector · 1 enterprise: ~60 % satisfied for a good v1, ~20 % for a bad one) pin T_mid ∈ (50, 55] and T_small ∈ (39, 42]; the **smallest** per-scale step satisfying both is 9, BASE = T_small − PER = 33 → bars 42/45/51/56. (The plan's first-guess formula `PER = round(T_good − T_bad) − 2` would have given (31, 11); the rule as written in the constant's comment is the one applied.) |
| `SalesSystem.TRACTION_MRR_TARGET` | [ÖLÇ] | **40,000** (band floor) | Rule: the smallest $40–80K band value the competent policy does not cross before month 12; if none is crossed by month 24, the band floor. Played B2B peaks $34.4K (§3 commit) / $38,983 (HEAD) and plateaus → floor. The B2C maintained fixture crosses $40K on day 124 and the gate opens — the bar is reachable, the B2B revenue curve is the finding (F1). |
| `SalesSystem.WOM_COEF` | [ÖLÇ] | **0.005** | sweep {0, 0.003, 0.004, 0.005, 0.007, 0.010} on `b2c_keep:180`; 0.005 is the smallest value whose 30-day MRR means are monotone with M6 = max; 0.007+ explodes. |
| `SalesSystem.SATISFACTION_QUALITY_GATE` | rule-derived | **40** on the EXPERIENCE axis | axis(20 − 0.8 · `SATISFACTION_BUG_GATE`) = 39.0 → a raw-20 v1 at the bug gate counts as maintained; axis ruling by the director. |
| `EndingsSystem.SOFT_CAP_DAY` | [WORKING] | 730 | canon "goal-terminated run, soft cap"; the played run never reaches it. |
| `PhaseGateSystem.GROWTH_STREAK_MONTHS / GROWTH_MIN_PCT` | [WORKING] | 3 / 12 | canon "3-month MoM ≥ 12 % streak"; played B2B holds a 4-month streak (m3–m6). |
| `SalesSystem.WOM_SAT_GATE / WOM_MULT_PIVOT / WOM_MULT_MIN` | [WORKING] | 60 / 50 / 0.3 | neglect collapses, legacy no-sprint declines, maintained compounds. |
| `SalesSystem.BUG_CONV_COEF / BUG_CONV_FLOOR` | [WORKING] | 0.02 / 0.4 | %32 → %24 at 5 → 15 bugs on the pricing panel. |
| `EndingsSystem.PROFIT_STREAK_MONTHS / PROFIT_MIN_MARGIN_PCT / BOOTSTRAP_WIN_MRR` | [WORKING] | 6 / 15 / 20,000 | fires month 9 (competent) / month 8 (weak); margin ~80 % never binds (F2). |
| `B2BConstants.RETAIN_DISCOUNT_MAX_USES / RISK_REENTRY_DAYS` | [WORKING] | 2 / 21 | discounts 87 → 4 and `max30 ≤ 1` per account; slip 11 (28 days → 7). |
| `QualityModel.RIVAL_TEMPLATE_HALF_SAT` | bridge | 50 | keeps rival-relative `q` ≈ 40 for a played v1 until the rival table is re-authored (F4). |
| Bug-complaint choice numbers | [WORKING] | +10/+2/−3 % · +6/−1/−1 % · churn/−2 | cost type, not size, was the ask. |
| `running_on_fumes` title | [WORKING] | "İlgi Söndü / Interest Faded" | director ruling at plan review. |
| `brand_above 24` on the Series A gate | pre-existing working floor | unchanged | played run brand clears it. |
| Signing grace (contingency) | [WORKING], **not applied** | — | In 275 played days exactly one card (day 38) fell inside a signing window, and that account's target (55) was already under its bar (56); the d88–d99 cluster is 3 accrued bugs tipping the pickiest accounts (target 53 vs 54/56) and v3 on day 94 silences it — the intended loop. One-line knob (`day − acquired_on_day < RISK_TRIGGER_DAYS` → no streak) if the director wants zero signing-window cards. |

---

## 3. Needs mechanics (Layer B — measured, not touched)

- **F1 · B2B revenue-curve slope / prospect pool.** The competent policy plateaus at 25 accounts / ~$39K MRR from month 7: `find_prospects` adds +2 every 5 days, pitches stop after ~day 176 because the catalog-bound pool (65 companies / 13 sectors, dedup by signature) is exhausted; expansions (25) are the only MRR after that. Consequences: the Series A signal turns ISINIYOR in month 3 and falls back to KAPALI in month 7; AÇIK is unreachable on the B2B path inside 24 months; the bar stays at $40K (ruling). Wants: pool regeneration / Tier-2 accounts (`SCALE_DEMO_MAX` 3 gates scale 4–5; a scale-5 bar is 69 under the new band → raw stability ≈ 56, out of v1–v4 reach) / a price ladder. The B2C path crosses the bar (fixture with a head start).
- **F2 · Profitability arrives in month 8–9, target 18–20.** Window margin ~80 % because nothing scales cost with revenue (founder burn $50/day + salaries only; no hosting/COGS per account or per audience). `PROFIT_MIN_MARGIN_PCT` 15 never binds. Wants an operating-cost floor that grows with the book before the streak length is re-tuned.
- **F3 · The promise channel is the next uncapped lever.** `b2b_risk:90`: 23 cards, 23 × "Söz ver", 20 broken, **0 churn** — a broken promise costs sat −20 / brand −3 / tolerance +5 but every new promise `_recover`s the account and clears the countdown, so an unsalvageable account never leaves. Mirror of what §8 did for discounts (cap, or broken-promise → no further promise row) — design decision.
- **F4 · Rival TEMPLATE re-authoring.** `RIVAL_TEMPLATE_HALF_SAT := 50` is a bridge: the rival table (`rival_catalog.gd`, startups raw 30–82, asymptote 100) is authored on the retired grown scale; a static played product drifts `q` 40 → 28 over 180 days against rival growth. Owner: the world/rival session.
- **F5 · B2C pools have almost no stability rows and no version cadence.** The experience-axis ruling makes satisfaction reachable, but the no-sprint `b2c` fixture accrues 47–97 bugs in 180 days and decays (3,330 → 465); only the sprint policy compounds. Wants bug decay / a version cadence for B2C (and stability rows in the consumer pools).
- **F6 · Frank's verdict line has no render surface.** `END_META_RUNNING_ON_FUMES_FRANK` (= Y5.6 verbatim) lives in the CSV; EndingScene does not paint the `_FRANK` meta today (Batch-1 rebuild owns that).
- **F7 · Event vocabulary doc.** Three additions for `docs/content/events_draft/_vocabulary.md` (the other session's draft folder — not touched from this branch): modifier `audience_delta {pct}` (proportional, signed), conditions `mrr_growth_streak {value, pct}` and `b2b_discounts_below {customer_id, value}`.
- **F8 · `PIVOT_MRR_MIN` 2,000 vs the $40K bar.** The pivot ending's "metrics are alive" floor is still $2K; pivot stays reachable at any MRR ≥ 2K with cash > 0 after the cascade. Consistent with its semantics; flagged because every other revenue number moved.
- **F9 · `SEED_MRR_REFERENCE` follows the bar.** VC conviction seeding is now relative to $40K (at gate-open parity with before); an early pitch at $5–15K MRR starts with low conviction, which is the intended reading of "too early".
- **F10 · Tier-2 bars.** Under (33, 9) a scale-4 account needs 60 and scale-5 69 — unreachable until a v3+ ceiling; gated today by `SCALE_DEMO_MAX` 3.

---

## 4. The played run — `--run-log=full_run:730:sim` (seed 424242, HEAD)

**Beats.** v1 build day 2 (integration + field + scheduling) → Beta wait → **ship day 25** (stability 31.0 · innovation 9.0 · experience 5.4 · 0 bugs) → first revenue + traction gate day 34 → **Frank seed day 40** (MRR $2,625, accepted) → hire nudge + **developer hired day 42** → v2 day 44 (+mobile, exp 16.4) → ISINIYOR day 91 → v3 day 94 (+workflow) → v4 day 108 (+reporting, stability 34, exp 30.4) → KAPALI day 213 → **6th Artıda close day 274 → `profitable_bootstrap` day 275** (cash $174,697, 25 accounts, 1 employee, phase 2).

| Month | close day | MRR close | income | expense | net | MoM | growth streak | Artıda streak |
|---|---|---|---|---|---|---|---|---|
| 1 | 32 | 0 | 0 | 3,350 | −3,350 | — | 0 | 0 |
| 2 | 60 | 4,050 | 2,462 | 6,725 | −4,263 | — | 0 | 0 |
| 3 | 91 | 14,040 | 7,655 | 8,060 | −405 | +247 % | 1 | 0 |
| 4 | 121 | 22,960 | 18,315 | 7,800 | +10,515 | +64 % | 2 | 1 |
| 5 | 152 | 32,410 | 29,432 | 8,060 | +21,372 | +41 % | 3 | 2 |
| 6 | 182 | 37,183 | 35,235 | 7,800 | +27,435 | +15 % | 4 | 3 |
| 7 | 213 | 38,623 | 39,165 | 8,060 | +31,105 | +3.9 % | 0 | 4 |
| 8 | 244 | 38,983 | 40,269 | 8,060 | +32,209 | +0.9 % | 0 | 5 |
| 9 | 274 | 38,983 | 38,970 | 7,800 | +31,170 | 0.0 % | 0 | **6** |

**Waypoints (day · cash · MRR · customers · appetite):** 30 · 6,500 · 0 · 0 · KAPALI → 60 · 26,257 · 4,475 · 7 → 90 · 24,844 · 14,040 · 12 → 120 · 34,262 · 22,960 · 17 · ISINIYOR (1/3) → 150 · 53,755 · 30,710 · 22 (2/3) → 180 · 80,016 · 37,183 · 25 (3/3) → 210 · 109,198 · 38,623 · 25 (4/3) → 240 · 139,532 · 38,983 · 25 · KAPALI → 270 · 169,502 → 275 · 174,697. Cash trough $6,450 (day 31); MRR peak $38,983 (day 213); `MRR_end/peak` 1.0; churns 0; promises 6 kept / 6 open.

**Cards.** 75 fires in 275 days = **1.9 / week** (40 weeks: mean 1.88, median 2, max 5, six zero weeks). Per id: `ev_b2b_expand_*` 25 · `ev_ps_referral_b2b` 17 · `ev_b2b_retain_*` 16 (8 accounts: 1/1/1/1/1/1/5/5; `max30` 1; days 38 · 88 ×3 · 92 · 99 · 121 · 138 · 155 · 172 · 189 · 206 · 223 · 240 · 257 · 274 — the two 5-card accounts are the 56-bar mid+sector pair riding the 21-day cadence) · `ev_mvp_version_ship_moment` 3 · one each of `ev_mvp_ship_moment`, `ev_ps_first_revenue`, `ev_phase_gate_traction`, `ev_ps_frank_intro_b2b`, `ev_angel_frank_seed`, `ev_angel_hire_nudge`, `ev_mvp_dev_001/003`, `ev_mvp_bugfix_001/002/003`, `ev_mvp_iter_001/002`, `ev_mvp_iter_decision_intro`. Picks: Büyüt 25 · referral accept 17 · Oyala 6 · İndirim ver 4 · Söz ver 6. `PROBE SAT`: d45 3/3 · d60 7/7 · d90 8/12 · d120 16/17 · d180 25/25.

**Base for contrast (`full_run:180` at `1867213`):** 664 fires / 180 days = 25.8 / week, `ev_b2b_retain_*` 630 (one account 49), discount picks 619, MRR 7,333 → 3,051, cash 9,099, `running_on_fumes` on the day-180 wall.

**`full_run_weak:730` (legacy set, immediate launch):** ships day 19 with 15 bugs; `profitable_bootstrap` day 245 (first Artıda close one month earlier than the competent run because revenue starts earlier); MRR peak 32,141 (day 211) → 28,605 after **2 churns** (days 215, 232: the 56-bar accounts, sat 53 vs tol 56, countdown to zero — the first genuine passive churns a played run has shown); retention 22, discounts 8, stalls 11, 2.2 fires/week.

---

## 5. Strings

New keys (25, all TR+EN in the commit that needed them): `END_RF_STAYED_STANDING` (renamed from `END_RF_JUST_MADE_IT`), `END_RF_UNSIGNED_SHEET`, `END_SPAN_OVER_YEAR`, `END_SPAN_NEAR_TWO_YEARS` (§2) · `INV_APPETITE_TITLE/_CLOSED/_WARMING/_OPEN/_LINE/_TOO_EARLY/_GATE_OPEN/_HUNT`, `INV_BAR_BELOW`, `INV_BAR_CLEARED`, `FIN_REQ_MRR_BAR`, `FIN_REQ_GROWTH`, `ODA_GOAL_SIGNAL` (§3) · `EFFECT_AUDIENCE_PCT` (§7) · `B2B_DISCOUNT_SPENT_DESC` (§8) · `FIN_PROFIT_PROGRESS/_QUAL_MARGIN/_QUAL_SCALE/_NOTE`, `END_BS_STREAK` (§9) · `SET_RESOLUTION_BORDERLESS` (§12).
Rewritten: all `END_RF_*` rows + `END_META_RUNNING_ON_FUMES_TITLE` ("İlgi Söndü" / "Interest Faded") + `_FRANK` (Y5.6 verbatim), `END_EV_PIVOT_BODY` last paragraph (`{months}`), `PROD_FEAT_SAAS_OPS_FIELD_VOICE` EN, `ev_ps_bug_complaint.json` (TR + `_en`).
Removed: `END_RF_JUST_MADE_IT`, `PROD_MRR_OF_TARGET`, `PROD_TOWARD_TRACTION`, `ODA_GOAL_MRR`, `FIN_REQ_MRR`, `FIN_OPEN_ROUND_SERIES_A`.
Glossary rows added: Yatırımcı iştahı ↔ Investor appetite · KAPALI · ISINIYOR · AÇIK ↔ CLOSED · WARMING · OPEN · Gelir çıtası ↔ Revenue bar · Artıda · n/6 ay ↔ Default Alive · n/6 mo.
CSV 1,774 → 1,793 keys; `loc_residue` 0 hits at every section commit and at HEAD.

---

## 6. Falsification log (one per section, each restored)

| § | Reverted | Observed | Restored |
|---|---|---|---|
| 0 | `run-log` dropped from the sniffer list | `harness_sniffer_matches_run_log` FAIL with the right diagnosis | ✓ |
| 1 | lever 2 (tolerance back to 35/5) | `b2b_v1_lands_mid_band` FAIL "good v1 axis 55.4 is outside [mid 45, mid+sector 50)"; `b2b_slip:90` 62 cards | ✓ |
| 2 | `SOFT_CAP_DAY = 180` | `full_run:400` ends day 180 `running_on_fumes` | ✓ |
| 3 | streak condition removed from the gate | `series_a_gate_needs_streak` FAIL (gate opens on MRR alone) | ✓ |
| 5 | `WOM_COEF = 0` | `b2c_wom_needs_satisfaction` FAIL "the compounding term is off"; keep curve back to a month-2 peak | ✓ |
| 6 | `BUG_CONV_COEF = 0` | `conversion_bug_penalty` FAIL | ✓ |
| 7 | a cash row put back into the JSON | `bug_complaint_costs_audience_not_cash` FAIL "a cash row survived" | ✓ |
| 8 | `RETAIN_DISCOUNT_MAX_USES = 99` | `discount_cap_two_uses` FAIL "third discount went through"; `full_run:365` discounts 4 → 16 | ✓ |
| 13 | button bypasses `can_offer_retention` | `retention_gate_shared` FAIL | ✓ |
| 9 | margin clause dropped | `profit_predicate_margin_scale_red` FAIL "thin margin should block" | ✓ |
| 10 | `--tempo-probe=4` | "bad speed index 4" (ladder has no rung 4) | — |
| 11 | seed pin removed | `angel_fires_at_crossing` 4/12 fails → pinned 12/12 | ✓ |
| 14 | `p/n` approximation | `ambient_hourly_chance_exact` FAIL "the engine still uses the p/n approximation" | ✓ |
| 16 | stash line removed | `creation_draft_survives_navigation` FAIL "on_page_closing stashed nothing" | ✓ |
| 12 | — | key resolves in both locales (`borderless_note_key_exists`) | — |
| 15 | — | absent by search; eye pass over 71 kinds × 2 locales | — |

---

## 7. Gates at HEAD

- **Smoke:** 211 cases counted from source (`211` registry arms == `211` `_case_` functions), gated runner (PASS only on `SMOKE PASS <case>` with no `Parse Error|Compile Error|Failed to instantiate`, 120 s per case): **210/211 PASS**. The one failure, `ui_scale_ladder_fits_settings` ("top step 150% leaves a 720px logical viewport; Settings panel is 820px"), fails identically at `1867213`: the 820 px panel + the case landed in that commit, while the removal of 1.50 from `UI_SCALE_STEPS` is the other session's **uncommitted** `display_settings.gd` in the main checkout. Not touched here (an ownerless change is not committed from this branch) — Q3.
- **Localization:** `loc_residue.gd` → `LOC RESIDUE: 0 hit(s) [CLEAN] (csv_keys=1793)`; `loc_csv_integrity`, `loc_format_args` PASS in the suite.
- **Shot matrix:** 71 kinds × TR/EN = 142 launches, 0 script errors, every baseline kind present (the 58-pair baseline set of `1867213`, every TR-only kind now also in EN, + the new kinds `--b2b-shot=retention_capped`, `--finance-shot=signal`, `--product-shot=detail_b2c_buggy`, `--oda-shot=signal`). Every changed surface read by eye in both locales: Finance title row (chip + line + tooltip) in phase 1 ("Series A henüz masada değil") and phase 2 ("ISINIYOR · Gelir çıtası altında · büyüme 3/3 ay" + "Artıda · 4/6 ay"), TopBar speed cluster (pause + three rungs, nothing crossing), the retention card with the locked discount row and its reason line, the rewritten `running_on_fumes` paper (730 days, "iki yıla yakın", the unsigned sheet), `profitable_bootstrap`, the bug-complaint event (no cash badge, `KİTLE −%3 / AUDIENCE −3%`), the product traction strip (b2b / b2c / buggy: DÖNÜŞÜM %32 → %24), the Sales tab `İlgilen` button on a live countdown, the ODA goal card in phase 1 (`TRACTION'A 3/3`) and phase 2 (`ISINIYOR · büyüme 3/3 ay` / `WARMING · growth 3/3 mo`, progress bar). Nothing clipped, hover = edge only (the EN bug-complaint frame caught the first row hovered: outline only), no dev placeholder visible. The `--oda-shot=signal` kind (phase-2 seed, same four closes as `--finance-shot=signal`) was added in the final commit because no existing ODA fixture is phase 2.
- **ODA:** `--theme-audit=oda` 124 lines; a first comparison against the morning's base dump differed on exactly two `bg:` values, both `UiTokens.oda_health_green()` readers — that is the `colorblind_palette` entry of the SHARED `user://settings.json`, which another session flipped at 13:41 (the audit prints the palette in force, not the theme). Re-run against a temporary base worktree at `1867213` under the same settings: **md5-equal** (`b6a595c4…`), before and after the harness edit above → ODA excluded from the pixel diff per law, nothing to unfreeze.
- **Harness hygiene:** per-case timeout, fatal-error grep, PNG copies out of the shared `user://` immediately after each run; no project file edited while a suite was in flight.

---

## 8. Director questions

1. **`RISK_REENTRY_DAYS` 21 vs 28.** `b2b_slip:90` lands at 11 cards (target < 10); 28 days gives 7 (cadence d4·32·60·88). 21 was kept as the [WORKING] value ("three weeks to move the cause"). Raise, or accept 11?
2. **Promise cap (F3).** Mirror §8 on "Söz ver" (e.g. 2 open promises per account, or a broken promise removes the row) — or leave the risk preset's "never churns" as the price of the player's choice?
3. **`ui_scale_ladder_fits_settings` at base.** The fix is the other session's uncommitted `display_settings.gd` (1.50 removal). Merge order: their commit first, then this branch; or accept one red case until then?
4. **CLAUDE.md Law 2 "Fast 4x".** The ladder is 1×/2×/3× in code, UI and docs; the law text still says 4x. Law text is director-owned — amend?
5. **Title [WORKING]** "İlgi Söndü / Interest Faded" shipped per the plan-review ruling; confirm as canon or send a replacement and it is one CSV row.
6. **Signing grace.** One signing-window card in 275 days (section 2, last row). Leave as is (recommended) or add the one-line grace?
7. **Merge notes vs the Build Bar session.** As of 14:20 on 2026-08-19 the main checkout (`localization-phase2` @ `1867213`) carries that session's UNCOMMITTED work on 21 files ("Build Bar 2026-08-19": `BuildBar.tscn`/`build_bar.gd`/`build_bar_model.gd` new, `BuildHUDPanel`, `product_system.gd` retires `advance_iteration` and adds `enter_beta`, `display_settings.gd` 1.50 removal, `theme_sweep_ledger.md`, untracked `docs/.md`, `docs/content/events_draft/`). Ten of them are also touched by this branch → textual merges expected in: `docs/TECH_SPEC.md` (Decision Log rows), `localization/strings.csv` (25 new + rewritten rows here), `scripts/autoload/event_bus.gd` (comments), `scripts/autoload/event_manager.gd` (conditions + `hourly_chance`, `_is_eligible` signature), `scripts/debug/endgame_smoke.gd` (36 cases + registry block + VC fixture helpers), `scripts/debug/run_probe.gd` (presets/fixtures/lines), `scripts/main/main.gd` (shot kinds + ending alias), `scripts/modals/event_modal.gd` (`_describe_modifier` audience pct), `scripts/tabs/product/creation_flow.gd` (§16 draft guard), `scripts/ui/oda/oda_view.gd` (`_refresh_goal` phase 2 + day refresh). None of this branch's code calls `advance_iteration` (RunProbe's Beta wait reads phase/bugs only), but smoke cases from `1867213` that still call it will need their retirement; the whole suite must run once after the merge, counted from source.

---

## 9. Not in this task (recorded, untouched)

Rival TEMPLATE table · prospect pool / revenue slope · operating-cost floor · promise cap · B2C stability rows / version cadence · EndingScene `_FRANK` surface · `_vocabulary.md` · CLAUDE.md law text · the other session's `display_settings.gd` · ODA art/scene (theme audit byte-same) · main fast-forward (git is the director's).

**Commits on `calibration-round-a`:** `e35ccac` §0 · `f337e65` §0b · `0d34201` §1 · `abc9617` §2 · `9300600` §3 · `b4dd193` §5 · `b94b66d` §6 · `23f8265` §7 · `df178f1` §8+§13 · `ae6f63c` §9 · `7aecd35` §10 · `aad2f21` §11 · `305e938` §14 · `f759479` §16 · `719485f` §12 + Decision Log · final: this report + `--oda-shot=signal`.
