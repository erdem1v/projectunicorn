# Funding ladder + phase/endings wave — report

**Date:** 2026-08-27 · **Baseline:** `main` @ `8b5bb9e` · **Scope:** GDD v2 ch. 09 §1-3 (the seed
rung), ch. 13 §1-2 (the endings rulings), Frank v6 surfaces 12b and 17+18, plus the two
conformance reports' open items.

The ladder was **savings → Frank's $25,000 → Series A**. It is **savings → Frank → seed →
Series A** now, the seed round is a real term sheet the player signs without the run ending, and
the seven Frank verdict lines that have shipped invisible since they were written finally have a
surface.

---

## 1. Phase 0 — what the reports claimed vs. what was true

The two conformance reports resolve to `7687095`; HEAD was four module rebuilds later. Every
finding was re-verified before it was touched.

| Finding | Status on `8b5bb9e` | What happened |
|---|---|---|
| 06 §2.6a Hunt roster archetype line renders empty | **already fixed** | reported, not re-fixed |
| 06 §2.6b `interrogation_intensity` read nowhere | confirmed dead (5 rows, 0 readers) | **deleted**, with a note saying what to build if the archetype should bite |
| 06 §4.2 "Karizma renamed to influence" | **already fixed** — `charisma` is live | reported |
| 06 §4.4 rejections cost brand + morale | confirmed absent | **built** |
| 10 §2.2 bootstrap win has no Series A term | confirmed | **built** (fifth clause) |
| 10 §2.3 shutter is 7 days | **already fixed** (`SHUTTER_DAYS := 30`) | reported |
| 10 §2.4 D-1 warning needs a live sheet | **mostly fixed** — the `arc_final_stretch` ladder was built after the report | **one hole closed** (below) |
| 10 §2.6 acquisition still reachable | **half fixed** — builder and verb already deleted | **remnant removed** |
| 10 §2.8 IPO / Series B not named | confirmed | **built** |
| 10 §2.10 Frank line never rendered | confirmed | **built** (the strip) |
| 10 §2.11 B2C prints an account count | confirmed | **built** |
| `END_META_BANKRUPTCY_FRANK` says seven | confirmed | **thirty**, number only |
| FRANK_UNWIRED §5 navigation verb | **already fixed** (`goto_tab`) | reused |
| FRANK_ORPHANS §E `ANGEL_CHIP_ACCEPT` asymmetry | **not a defect** — correct per-locale percent side | reported |

---

## 2. Six live defects found beyond the brief — all fixed

1. **`funding.sheet_expiry` printed a literal `{days}` to the player.** The presenter resolves
   `{slot}` from the bound scope and `{seam:ns.name}` from the registry; `{days}` is neither, so
   it survived to the screen inside a Frank line. Audited every card body in `data/events/`
   against its declared slots: **this was the only one**, which is why it went unseen. Fixed by
   moving the body inline in both locales with `{seam:funding.sheet_days_left}` — the shape
   `customer/request_complaint.json` already uses. **New gate:** `card_body_tokens_resolve`
   fails the build if a second one ever appears.

2. **`{investor}` rendered as the raw id.** `EvPresenter._display_name` had arms for employee,
   customer and rival, and none for investor — so every card binding an investor slot said
   "anchor teklifi masada" instead of "Anchor Capital teklifi masada". `funding.sheet_expiry`
   does that on any run that reaches a term sheet.

3. **The B2C aggregate rendered a blank name.** The same function read `Customer.company_name`,
   which is deliberately empty on the userbase record (it carries `name_key` + `name_arg` so a
   save does not freeze one language into it). Now reads `display_name()`.

4. **`finance_ozet_view.gd:190-205` threw on every Finance-tab build.** `_series_a_tooltip()`
   matched `String(cond.type)` over gate leaves that carry `{seam, op, value}` — an invalid-key
   access on a Dictionary. Its three arms were the retired pre-engine vocabulary, so even when
   it did not throw the requirement list was empty. Also dropped a stale `+ 1` that would have
   rendered brand ≥ 26.

5. **Lint silently skipped the dash and trademark checks on every variant body.**
   `String(dict)` has no constructor in Godot 4, so a `{by_seam, variants}` body threw and
   **aborted `_lint_text`**. `funding.gate_series_a` had been in that hole since variant bodies
   landed. `_body_strings` flattens both shapes now.

6. **Lint's documented `flag:` telegraph form was never implemented at runtime.**
   `EvHistory.telegraph_fired` passed the whole string to `EvFlags.has`, so the only spelling
   lint accepts was the one the executor refused. Stripping the prefix makes the documented form
   the working one.

**Two smaller ones:** `hunt_tab.gd` hardcoded the three Turkish prep-focus labels while
`_focus_label()` in the same file resolved the same ids through the CSV; and
`FIN_SUBTAB_INVESTMENT` EN is now **Funding**, the naming decision FRANK_UNWIRED §6 recorded and
never executed (seven landed option labels already say "Go to Funding").

---

## 3. What was built

### The seed rung (W1)

- **`seed_constants.gd`** — the rung's single calibration surface. **`seed_round_system.gd`** —
  the door ratchet, the band derivation, the atomic accept, the expectation reading. It holds
  **no static state**, which is why it needs no entry in `reset_all_owners()`; its header says
  so, because the day someone adds one it must join that list.
- **The door** latches in Traction at MRR ≥ 20,000 and is a **ratchet**: an MRR dip cannot
  re-lock it, because the announcement card is `one_shot` and a page that re-locks can never
  re-announce. It shuts on entering phase 3 — one seed pitch per run.
- **The meeting reuses the Series A scene** with a seed profile: the founder's Karizma is the
  largest term, the revenue yardstick is the seed bar rather than the Series A one, vision gets
  easier and hard metrics harder, and **Beat 4 cannot reject** — conviction buys one of three
  term bands. The reuse is a correctness argument, not a convenience: `SaveManager.can_save()`
  and `reset_all_owners()` already name `VCPitchSystem` and `TermSheetTableSystem`, so a seed
  sitting is provably idle at every save point with **zero edits to either list**.
- **The table** keeps the patience ladder, the dial, the decay and the odds split byte for byte.
  What changes is the lever set behind `levers()`, and the inversion at its heart: at Series A
  the money is derived from valuation × dilution; at seed **the money is the lever** and the
  implied post-money is a derived caption with no row — so ruling 4 is enforced structurally
  rather than by a guard.
- **The refusal is ZOR MOD**: `walk_enabled` false, the row rendered visible and disabled with
  its reason, and `walk()` refusing as a second safety.
- **Accept is atomic and non-terminal**, copying `AngelRoundSystem.accept_offer`'s write order
  exactly — cap table, ledger row, cash last, because `cash_changed` is synchronous and the
  Finance tab repaints inside it.
- **The seed sheet is not in `active_sheets`.** Eight readers walk that array and four would
  have been silently wrong: leverage, the sheet cap, the soft-cap paper's "unsigned offer" line,
  and the cascade defer (a sheet that never expires would have suppressed
  `vc_rejection_cascade` for the whole run).
- **The sealed "Para hesapta" card** was ported field by field and is **byte-exact** (the
  applier read the strings out of the JSON rather than retyping them). The port's real hazard
  was `"trigger_conditions": []`, which means *always eligible* — ported as written it would
  have fired on day 1.

### Series A (W2)

`_make_sheet` stops copying four frozen numbers off the investor row: valuation is **ARR × a
multiple set by the growth band**, nudged by the fund's own archetype word; dilution is
positioned inside 15-25 % the same way. The funds keep their weights, patience, domains and
board positions. The seed lead gets a **+10 conviction** welcome with its own reason line, so
the warmth appears in the breakdown the player already reads.

### Endings (W3) and the buyout card (W4)

- **The fifth bootstrap clause.** `faced_series_a` + the reason that set it, written by the
  funding page's decline, the table's walk, and a 30-day unentered-gate check. Upgrade-only, so
  a later walk overrides an earlier door_open.
- **The soft-cap hole.** The ladder was already sheet-independent; what it missed was the player
  sitting on an **open but unentered** gate at day 640, because the opener refused while
  `series_a_signal == "open"`. Measured in a played run: press, comment and verdict each fire.
- **Frank's strip** sits on the dark gutter beneath the page, outside `_export_paper_png`'s crop
  **by construction** — the shared image is still a newspaper. Uses existing theme variations
  (`QuoteSerifCream` + `DialogueTag`), so **`THEME_STAMP` did not move** and
  `oda_frozen_theme.tres` was not touched.
- **B2C figures.** The ledger gained `market`, `audience`, `paying_users`; the six prose lines
  and the stat rows branch through two helpers. No template prints an account count on a
  consumer run.
- **IPO and Series B** replace the generic tier cards, truthful to the RELEASE SCOPE table.
- **The buyout card** fires on the faced-flag **and** `road_over()` — the guard that keeps its
  sealed first sentence true and stops one walked table from resolving a run with three funds
  still open. `{investor}` is the seed lead; `{valuation}` is ARR × M and `{offer}` is the
  founder's slice, the only mapping under which the shipped sentence is true. "Kendi paramla
  devam" carries **both** consequences, behind one atomic verb.

---

## 4. The one thing that needs a decision

**At MRR 120,000 the Series A door is unreachable — and so is the seed door at 20,000.**
Measured on this tree, seed 424242:

| preset | peak MRR | ending |
|---|---|---|
| `full_run:730:sim` | **$11,911** | `running_on_fumes` |
| `b2c_keep:730:sim` | **$1,800** | `running_on_fumes` |

Neither approaches the *old* $40,000 bar, let alone the new one. `series_a_close` is not
reachable in a played run today, and `profitable_bootstrap` — now itself gated on facing the
Series A decision — is the practical terminal. Calibration Round A measured $39K here; the curve
has moved since Satış rev 6, and nothing in this wave's blast radius is in that loop (the run
probe never books a VC meeting, so the pitch, table and seed systems never execute in it).

**The suite cannot see this**: every case that touches the bar seeds `TRACTION_MRR_TARGET + 1000`
directly and keeps passing. The number is implemented as ruled and the consequence is recorded at
the constant, naming the two honest exits — the band floor (100,000), or landing calibration F1's
prospect-pool work. Both are the playtest gate's call.

**Deviation from the plan, stated rather than buried:** the plan called for a seed step in the
run probe's `full_run` policy so a played run would exercise the rung. I did **not** add it. The
probe never reaches 20,000, so that step would be code that cannot execute — dead policy
masquerading as coverage. The finding above is the honest version of what it was meant to prove.

---

## 5. New and changed dialogue keys — for the director's edit pass

**115 new keys, 1 rewritten.** Every one is TR-canonical with a native EN twin in the same
commit; `loc_residue` is clean and `loc_csv_integrity` passes.

**Seed room — spoken lines** (35)

`SEED_B1_LINE` · `SEED_B1_MONO` · `SEED_B1_MONO_WHY` · `SEED_B2_LINE` · `SEED_B2_METRIC` · `SEED_B2_MONO` · `SEED_B2_TRACTION` · `SEED_B2_VISION` · `SEED_B4_ACK` · `SEED_B4_LINE_HARSH` · `SEED_B4_LINE_STANDARD` · `SEED_B4_LINE_STRONG` · `SEED_B4_MONO_HARSH` · `SEED_B4_MONO_STANDARD` · `SEED_B4_MONO_STRONG` · `SEED_BAND_HARSH` · `SEED_BAND_STANDARD` · `SEED_BAND_STRONG` · `SEED_BLOCK_BUSY` · `SEED_BLOCK_CLOSED` · `SEED_BLOCK_SPENT` · `SEED_BLOCK_TAKEN` · `SEED_Q_CLEAN` · `SEED_Q_CLEAN_MONO` · `SEED_Q_FIRST_CUSTOMERS` · `SEED_Q_FIRST_CUSTOMERS_MONO` · `SEED_Q_HOW_BIG` · `SEED_Q_HOW_BIG_MONO` · `SEED_Q_INSIGHT` · `SEED_Q_INSIGHT_MONO` · `SEED_Q_TEAM_WINS` · `SEED_Q_TEAM_WINS_MONO` · `SEED_RES_HARSH` · `SEED_RES_STANDARD` · `SEED_RES_STRONG`

**Frank at the seed table** (6)

`SEED_FRANK_FINAL` · `SEED_FRANK_LAST_MOVE` · `SEED_FRANK_NEXT_MOVE` · `SEED_FRANK_OPENING` · `SEED_FRANK_RESISTED` · `SEED_FRANK_WON`

**Seed cards** (21)

`SEED_CLOSED_BODY` · `SEED_CLOSED_OK` · `SEED_CLOSED_TITLE` · `SEED_DOOR_BODY` · `SEED_DOOR_GO` · `SEED_DOOR_HINT` · `SEED_DOOR_LINE` · `SEED_DOOR_TITLE` · `SEED_OFFER_BODY_HARSH` · `SEED_OFFER_BODY_STANDARD` · `SEED_OFFER_BODY_STRONG` · `SEED_OFFER_LATER` · `SEED_OFFER_LINE` · `SEED_OFFER_SIT` · `SEED_OFFER_TERMS` · `SEED_OFFER_TITLE` · `SEED_STALL_BODY` · `SEED_STALL_EXPIRE` · `SEED_STALL_READ` · `SEED_STALL_TITLE` · `SEED_STALL_VERDICT`

**Funding page — the seed strip** (19)

`SEED_CAP_ROW` · `SEED_DONE_LINE` · `SEED_EXPECT_GRACE` · `SEED_EXPECT_LABEL` · `SEED_EXPECT_ON_TRACK` · `SEED_EXPECT_STALLED` · `SEED_EXPECT_UNKNOWN` · `SEED_IMPLIED_POST` · `SEED_LEVER_RAISE` · `SEED_MONTH_HIGHLIGHT` · `SEED_PITCH_BUTTON` · `SEED_PITCH_CONFIRM_BODY` · `SEED_PITCH_CONFIRM_OK` · `SEED_PITCH_CONFIRM_TITLE` · `SEED_PITCH_SPENT_LINE` · `SEED_SECTION_TITLE` · `SEED_SIT_DOWN` · `SEED_TX_LABEL` · `SEED_WALK_LOCK`

**Meeting reason lines** (4)

`VC_WHY_FOUNDER_STRONG` · `VC_WHY_FOUNDER_WEAK` · `VC_WHY_SEED_LEAD` · `VC_WHY_SHIPPED`

**Series A room — the repeatable-sales question** (2)

`VC_Q_REPEATABLE` · `VC_Q_REPEATABLE_MONO`

**Ending screen — Frank strip and the two milestones** (7)

`ENDING_CARD_IPO_BODY` · `ENDING_CARD_IPO_TAG` · `ENDING_CARD_IPO_TITLE` · `ENDING_CARD_SERIESB_BODY` · `ENDING_CARD_SERIESB_TAG` · `ENDING_CARD_SERIESB_TITLE` · `ENDING_FRANK_TAG`

**Ending paper — consumer figures, the sale price, the seed's mark** (18)

`END_ACQ_AUDIENCE` · `END_ACQ_AUDIENCE_ONE` · `END_ACQ_PRICE` · `END_BK_AUDIENCE` · `END_BK_AUDIENCE_ONE` · `END_BS_AUDIENCE` · `END_BS_AUDIENCE_ONE` · `END_RF_AUDIENCE` · `END_RF_AUDIENCE_ONE` · `END_RF_SEED_STALLED` · `END_RF_SEED_TAKEN` · `END_SA_AUDIENCE` · `END_SA_AUDIENCE_ONE` · `END_STAT_AUDIENCE` · `END_STAT_PAYING` · `END_STAT_SALE_PRICE` · `END_VC_AUDIENCE` · `END_VC_AUDIENCE_ONE`

**Effect chips** (3)

`EFFECT_RUN_ENDS` · `EFFECT_SEED_TABLE` · `EFFECT_VC_ROAD_CLOSES`


**The one rewrite:** `VC_B2_LINE` asked the *seed* question in the Series A room — "neden sen,
neden şimdi?" — and asked it in the informal register the style law reserves for an earned
moment. The seed room asks it now. Series A asks what a Series A room asks: what makes the
revenue repeat.

**Two language rulings applied**, flagged because they are judgement calls:
- **"Seed" and "Series A" are treated as round NAMES — proper nouns**, unlocalised, the same
  class ch. 09 §1 uses when it lists the ladder. Where a plain Turkish phrase carries the
  meaning ("bu tur", "turu"), it is used instead, so the loanword appears only where the round
  is being named.
- **The growth expectation renders its threshold (10 %), the door does not.** The door is an
  appetite the player infers — the appetite grammar's whole point. The expectation is a promise
  an investor made out loud, and a promise nobody states is not one.

---

## 6. Gates

| gate | result |
|---|---|
| `--event-lint` | **PASS** 0 errors, 0 warnings, 53 cards, 3 arcs |
| `--event-probe` | **PASS** 159/159 |
| `loc_residue.gd` | **CLEAN** 0 hits, 2,616 keys |
| `loc_csv_integrity` · `loc_format_args` · `loc_event_en_coverage` · `loc_format_locale_flip` · `loc_language_switch` · `loc_pick_fallback` | **PASS** |
| `save_roundtrip_fingerprint` | **PASS** |
| new cases | **23/23** |
| full suite | **334/337** — the three reds are INHERITED, proven not assumed |

The three: `b2c_satisfaction_gate_experience` (a quality-axis calibration case) and two
`SAVE_ERR_TOO_OLD` refusals, `save_migration_v7_to_v8` and `trait_migration_real_load`.
They are the same three the previous wave recorded at 311/314.

**How they were proven pre-existing rather than assumed.** The two migration refusals are
pre-existing *by construction*: `MIN_LOADABLE_VERSION` is 10 in `HEAD` and 10 now (this
wave bumped `SCHEMA_VERSION` 11 → 12 and deliberately left the floor alone), and both
fixtures are v5 and v7 — below the floor the event-engine rebuild set. The third was
settled by measurement: the whole wave was stashed (`git stash push -u`), the case run
against a pristine `HEAD` tree, and it failed with the **identical message** —
`experience 10 (axis 28.6) moved satisfaction (49)`. The tree was then restored and
verified byte-for-byte (36 files, 2,435 insertions, 240 deletions before and after; 46
changed entries before and after; the stash list empty).

**A harness note for the next wave.** Long background runs were terminated by the harness
three times at roughly the hour mark, and each termination left a `smoke_run.sh --all`
loop alive with its Godot children — twice they were racing a second runner, which makes
any result from that window untrustworthy. The suite was finished in **foreground chunks
of 14 cases** instead (`chunk.sh <start> <count>`), which fits inside the tool's ten-minute
ceiling and reports each failure immediately. Before every restart the process table was
checked and cleaned — the loop first, then Godot, in that order.

**Save schema 11 → 12.** `MIN_LOADABLE_VERSION` stays at 10: the seed block is seven GameState
vars and two `TermSheet` `@export`s, every one with a declared default, which is exactly the
migration `SaveCodec`'s header describes. A v10 or v11 save arrives with no seed round and
`faced_series_a` false — the truth about that run.

---

## 7. Open items, named not hidden

- **Ch. 01 §3 and ch. 13 §1 CUT the acquisition ending**; this wave's ruling brings it back
  through the sealed Frank card. That is the director's later call — recorded here rather than
  left as two documents disagreeing.
- **Frank's warm intro is still a registry property, not a played decision** (ch. 09 §6). Only
  the `seed_lead` warmth of the relationship model landed.
- **`hard_mode_unlocked` still has no writer**, by design — the locked rows are its telegraph.
- The **em dashes in `END_META_BANKRUPTCY_FRANK`** were left alone. Only the number moved; a dash
  sweep is a different task, and a mechanical character sweep over Frank's voice is exactly what
  the standing ruling against word-blacklists warns about.

---

## 8. F5 guide — what to look at, and how to get there

Everything below is reachable in a debug build. The fastest paths first.

### The seed rung, without playing to it

The door needs Traction phase and MRR at the bar, which a played run does not reach (section 4).
The honest way to see the surfaces today is the harness:

```
godot --path . --tab-shot=finance        # the Finance tab; the Yatırım segment
```

Then, in a live run (`--skip-onboarding`), the debug keys still work: F1 forces the phase gate,
F12 skips onboarding. To see the seed strip you need `GameState.phase == 2` and MRR ≥ 20,000 —
the quickest is the F-key console path used for the other funding fixtures.

**What to look for on Finance › Yatırım once the door opens:**
- The **Yatırım segment is no longer locked** in Traction. It was hard-locked to phase 3.
- A **seed strip** above the two columns: a line saying revenue carries a round (with **no
  figure** — check this), a line saying the fund you pick is the fund you get, then four fund
  buttons.
- The **Series A roster below now says why it is inert** ("Series A Hunt'ta açılır"). It used to
  be a row of four funds with no button and no sentence, because the page was unreachable.
- Picking a fund asks for a confirm — it is irreversible, one pitch per run.

**In the meeting:** it is the same scene, four beats, but the room is different. Beat 2 asks
"neden siz, neden şimdi"; Beat 3 asks where the insight came from / how the first customers found
you / why this team / how big this gets, chosen by the fund's domain and by real state. **Beat 4
never rejects** — it states terms.

**At the table:** row one says **YATIRIM** and moves in $10,000 steps, with **ima edilen
değerleme** underneath it. **MASADAN KALK is visible and greyed**, and its tooltip says why. The
closed-tables counter is absent.

### The ending screen

```
godot --path . --ending-shot=series_a_close
godot --path . --ending-shot=running_on_fumes
godot --path . --ending-shot=bankruptcy3
```

- **Frank's line is on a strip under the paper**, on the dark gutter, attributed to him. Seven
  translated lines that have never been on screen.
- The **right rail names Series B and Halka arz** instead of "TİER 2 · ORTA ÖLÇEK".
- `--ending-shot` also runs the real share-PNG export — open the saved file and check the strip
  is **not** in it. The player shares a newspaper; the mentor's verdict was for them.
- The **bankruptcy verdict says thirty days**.

For the consumer figures, `EndingsCopy.debug_all_view_states()` now carries three B2C twins
(`series_a · b2c`, `profitable_bootstrap · b2c`, `running_on_fumes · b2c`) — those are the papers
that must say KİTLE and ÖDEYEN and must never say MÜŞTERİ.

### The two card repairs worth a look

```
godot --path . --why-fire=funding.sheet_expiry
godot --path . --why-fire=funding.acquisition_offer
```

The first used to render "{days}" to the player and now reads a seam. Both now name the fund by
its display name rather than by `anchor`.

### If something looks wrong

`--why-fire=<card id>` prints the gate step that refused a card, the live values of every seam it
reads, its latch, and what it is waiting on. That is the first thing to run before assuming a
card is broken.
