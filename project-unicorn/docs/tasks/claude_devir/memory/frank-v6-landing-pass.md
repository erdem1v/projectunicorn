---
name: frank-v6-landing-pass
description: "Frank v6 document landed 2026-08-20 — all text in, rulings taken, inertness mechanism, and the open-work manifest"
metadata: 
  node_type: memory
  type: project
  originSessionId: 954101b2-26e4-4348-828b-cca7aeee9b88
  modified: 2026-08-20T19:42:15.406Z
---

**2026-08-20.** `docs/content/events_draft/Frank Diyalogları · v6.md` is the **single source of
truth** for every Frank Köseoğlu line. It was landed whole: 64 text pairs / 128 strings,
byte-exact both locales, verified by a diff script rather than by eye. Open work lives in
`docs/writing/FRANK_UNWIRED.md` (7 entries — Erdem tracks this file); everything Frank-voiced
still in the build but outside the document is in `docs/writing/FRANK_ORPHANS.md`.

**Erdem's rulings from this pass (binding):**

1. **Placeholder names become ASCII engine tokens in both locales**; prose stays byte-exact.
   Forced by the CSV gate — see [[strings-csv-surgery]].
2. **Replace, do not run in parallel.** New text takes the old card's place; the old *card*
   closes, **never the ending behind it**. Smoke cases that reached an ending through a retired
   card get **repointed, not deleted**, and every one gets listed.
3. **New conditions are built generic**, not per-flag. `days_since_flag{key, days}` reads any
   stored day-flag; absent flag is FALSE, never day 0. A trigger must stay in the event file —
   splitting it between JSON and GDScript makes the file lie about when its card fires.
4. **No ScrollContainer on the opening modal.** Resize the panel; a scrollbar on the first
   screen a player sees is a design failure. Visual acceptance gate: take the shot, **read it
   yourself**, verify no clipping and the CTA on screen, iterate until it passes. "Shot taken"
   is not verification.
5. Surface 24 lost its `{investor}` token entirely — **Turkish suffixes take vowel harmony and
   consonant assimilation from the preceding word and the engine cannot inflect**, so
   `{investor}'dan` is wrong for most of the roster. General rule for TR copy.
6. `SHUTTER_DAYS` 7 → 30.

**Inertness, two mechanisms, both demonstrated not assumed:**
- **JSON:** `data/events/unwired/` — `EventManager.EVENTS_DIR` is one constant, the scan does
  not recurse, nothing else opens `data/events/`. `loc_event_en_coverage` scans it anyway so
  both locales stay enforced. **Never** use `trigger_conditions: []` (that means *always
  eligible*, fires day 1) or `choices: []` (soft-locks the modal queue and disables saving).
- **Code-built cards:** builder exists, nothing calls it; proven by grep plus a falsification
  smoke case that drives the old trigger conditions and asserts the id never reaches the queue.

**Two latent bugs found by running with a stricter gate** (grep each case for
`Parse Error|Compile Error|SCRIPT ERROR` as well as `SMOKE FAIL` — a case can print PASS with a
script error inside it): `PhaseGateSystem.GATES[0].bodies` in `gate_decline_reminder` (a key
that never existed) and `f["note"]` in `hr_candidate_invariants` (**pre-existing, HR module,
left for its owner**).

Fixture gotcha: `run_probe.gd` seeds `mvp_shipped` directly and never went through
`ship_active_build`, so it never stamped `mvp_launch_day` — any `days_since_flag` trigger was
dead in the probe until the fixtures were made to stamp it.


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Frank v6 landing pass](frank-v6-landing-pass.md) — 2026-08-20: doküman tek gerçek kaynak, 128 string byte-exact indi; 6 ruling (ASCII token, replace-not-parallel, generic condition, scrollbar yasak + görsel kabul kapısı, TR ek uyumu → token yok, SHUTTER 7→30); inertness iki mekanizma; FRANK_UNWIRED.md açık iş listesi
