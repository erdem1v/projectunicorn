---
name: event-layer-audit-2026-08-21
description: Frank runtime verification + full non-Frank event inventory delivered 2026-08-21 — the measured findings that the revision pass will act on
metadata: 
  node_type: memory
  type: project
  originSessionId: 778f19fb-f6d1-4eff-9024-fc401d40ae21
  modified: 2026-08-21T13:54:52.901Z
---

Two READ-ONLY reports delivered 2026-08-21 against working tree `9908a8b`, nothing fixed:
`docs/audits/FRANK_VERIFY_2026-08-21.md` (+ its 6,388-line run log) and
`docs/audits/EVENT_INVENTORY_2026-08-21.md` (28 entries, 2,349 lines).

**The numbering trap — do not lose this.** `FRANK_VOICE_INVENTORY.md` numbers surfaces
run-chronologically; `Frank Diyalogları · v6.md` numbers cards 1–18 + strips 19–25. They agree
through 12 then SWAP BLOCKS (v6 13–18 = inventory 20–25; v6 19–25 = inventory 13–19). Inventory
row 24 is `ev_pivot_offer`; **v6 surface 24 is `DEAL_PROMPT_LINE`**. Erdem's task numbering = v6.

**Frank, measured over 8 runs / 2,290 simulated days:**
- Fired: surfaces 3, 4, 5 (×3), 6, 9, 10, 11 in `full_run:730` (terminal `profitable_bootstrap`
  day 275, 62 cards); 7 in the b2c presets; 12 only in `b2c_keep`.
- **Never reachable without hand-driving: 13, 14, 15 (the whole VC arc) and 16 (shutter).** Cash
  never went negative in ANY preset — `b2c_neglect` ends day 365 with $42,225 and MRR 0.
- Inert 12b / 17+18 / 24 confirmed silent (falsification cases PASS). But **17+18 renders literal
  `{investor}` `{valuation}` `{offer}` on screen** — the builder never calls `.format()`.
- **`HR_ROLE_MENTOR` = "Operating Partner" in BOTH CSV columns**, and it is what renders on every
  Frank surface; the correct `MENTOR_ROLE` = "OPERASYON ORTAĞI" is overwritten at runtime by
  `mentor_intro_modal.gd:20` / `event_modal.gd:262`. One-row fix, visible on the first screen.
- Opening card says *"Saat onu beş geçiyor"* while the TopBar reads **09:00** (`INITIAL_HOUR := 9`),
  in both locales. Live em dashes: `GATE_ADVANCE`, `GATE_SERIES_A_BODY_0`, and two NOT on
  FRANK_UNWIRED's list — **`PROD_EV_VERSION_SHIP_BODY`** (fires 3×/run) and `ANGEL_MONTH_HIGHLIGHT`.
- Surfaces **2 and 5 are live, undocumented and still in the pre-v6 voice** (v6 says Frank was
  removed from both; he was not).

**Event layer, the two numbers that matter:**
- **COPY LIE on 27 of 28 entries, one repeated shape**: a label names the resource the player
  spends and the engine charges a different one, or nothing. `Çıkışı ertele` postpones nothing
  (no `delay_days`); `Vakit harca, cila çek` spends no time; `Kabul et — özellik sözü ver`
  creates no promise; `Görmezden gel`'s "Müşteri kaybı" chip loses no B2C customer.
- **`Büyüt` (ev_b2b_expand)**: S1-1's daily re-fire is **CLOSED** (`Customer.last_expansion_day`
  latch, stamped on both answers). The free-MRR pump is NOT — +$360/+$720/+$1,440 per click,
  permanent, zero cost, against an alternative literally chipped `DEĞİŞİKLİK YOK`. 25 clicks in the
  played run = **~$11.7K/month, ~36 % of the run's final $32,495 MRR**.
- Repeat offenders: `ev_ps_referral_b2b` 16×/275d identical fiction; `ev_ps_bug_complaint` **42× in
  365d**; `ev_b2b_retain` **87× across 5 accounts** in a year.
- **`ev_hr_ship_glow` and `ev_hr_big_signing` are STRUCTURALLY UNREACHABLE** — both test "today"
  (`days_since_last_ship()==0`, `acquired_on_day == day`) but the only caller runs at slot 3 of the
  hour-0 boundary, before any ship or signing is recorded that day. The morale system's whole
  recovery channel is effectively silent.
- Pacing: 62 cards / 275 days, but **two ids are 41 of them**; the last 63 days are four referrals.
  Only **17 fires** are authored non-repeating content and all land before day 120.
- Answer to "are there ten revisable events": **yes, eleven**, and nothing new needs writing. The
  gap is trigger spread, not content — no card's trigger says "the company is large and settled".

Method worth reusing: `--run-log=<preset>:<days>:sim` battery + a scratchpad `-s` shot driver +
a Workflow that extracts then ADVERSARIALLY VERIFIES (308 verdicts → 14 flag reversals, 37 number
corrections, published as a ledger inside the report rather than folded in silently).

Related: [[project-unicorn-current-stage]], [[frank-v6-landing-pass]],
[[godot-mcp-runtime-verification]], [[b2b-sales-system]]
