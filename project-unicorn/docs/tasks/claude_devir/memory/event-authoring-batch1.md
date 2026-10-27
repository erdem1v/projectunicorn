---
name: event-authoring-batch1
description: "Event Pool v1 authoring task; the design doc lives at project-unicorn/docs/.md (hidden filename); Batch 1 (_vocabulary + Y5 Frank) delivered 2026-08-19, uncommitted, director rulings recorded"
metadata: 
  node_type: memory
  type: project
  originSessionId: 847a4214-406e-4b64-9e70-7dec822f7cfe
  modified: 2026-08-19T05:24:10.608Z
---

**Phase 2: one-scene-per-turn RETIRED 2026-08-19 (division of labour changed: I produce structurally correct raw material + a defect report, Erdem and the director do the editorial pass; write plain, do not decorate, they rewrite the prose anyway). Delivered: `docs/writing/frank/ALL_SCENES_DRAFT.md` (rows 7 to 25) + `STRUCTURAL_DEFECTS.md` (34 findings, classes A to H). Earlier per-scene files: rows 4, 6. (Superseded note, kept for history: one scene per turn; Erdem rules and often replaces the body verbatim): row 4 and row 6 delivered in `docs/writing/frank/`. STANDING RULE from Erdem: no dashes (—, –, or hyphen-as-punctuation) in any event body, ever; gate every delivered body with a grep. Surface classes: scenes (4–8 lines) · standing strips (1–2 sentences, must survive repetition) · class 3 confirmation cards (≤3 lines incl. option; row 4 reference). New vocab need reported: `navigate_to_tab{tab}` (a card that hands the player something should put them where they use it). Next: row 7 ev_ps_b2c_paid_tier.**

**SUPERSEDED 2026-08-19 by the Frank Voice Pass** (Erdem's task: inventory first at `docs/writing/FRANK_VOICE_INVENTORY.md`, then ONE scene per turn in `docs/writing/frank/`, A/B/C retired, 'three sentences ≤10 words' retired, aphorism budget 2/run, TR first then EN literary translation with the same images, open on something physical the founder sees, facts arrive in dialogue, Frank asks a question, no narrator stinger, gap at the end; reference = the approved Y5.1 alarm scene in the brief). World facts that surprised us: weekdays EXIST (Day 1 = Thu 1 Jan 2026) but are only visible ≥1600px; every daily beat fires at hour 00 in a night-lit room; END_META_*_FRANK has no surface; MentorIntroModal double-mounts and mounts on load (6edace1).

**EVENT POOL DESIGN v1 is `project-unicorn/docs/.md`** (a file literally named `.md`, invisible to plain `ls`; the task calls it `EVENT_POOL_DESIGN_v1.md`). 9 arcs Y1–Y9, ~40 nodes, spine-not-texture, node format §7.

Batch 1 delivered 2026-08-19; **revision 1 prose was rejected 1/10** (stage business: props, body narration, similes, staged silences). Revision 2 same day: every non-sealed body in A/B/C (A message · B record/count · C voice), Frank ≤3 sentences ≤10 words, no props/hands/coats/cups/cards/pens/chairs, no body narration of Frank, the world speaks through game facts; Y5.4b deleted, Y5.3/Y5.4 pure beats, Y5.5 two options (not wired until `vc_warm_intro`), Y5.6 five lines. Files: `docs/content/events_draft/_vocabulary.md` + `Y5/` (README, Y5.1–Y5.6). **Rev 2 was also rejected (dead on the page: forms and fillers). Rev 3 (same day) writes to what the sealed texts do: every sentence a specific fact that implies more (a minute, a count, a day, a name), the sting an absence/detail, Frank with one turn per node, invented details allowed if facts; each node's A/B/C share one implication (Y5.1 he watched the pitch closer than you; Y5.2 he watches your numbers; Y5.5 he spoke to the VC before you). The Y5.2 sample was approved before the rest was written.** Director picks A/B/C per node before Y1; if rev 3 fails, Erdem writes the bodies and I keep mechanics/EN skeleton. Next arcs in order: Y1 Promise → Y2 Fragile Account → Y3 Rival → Y4 First Hire → Y7 → Y8 → Y6 → Y9; **stop after each arc for the director's read; his rejections become law lines.**

Director rulings 2026-08-19: Y5.2 "Variant A" = rewrite of the existing seed card (same $25K/4 %, REDDET stays locked); Y5.4 body sealed verbatim ("Duydum. Gitti değil mi…" / "I heard. They left…"); Y5.6 = 4 verdicts, "soft cap" = `running_on_fumes` (calibration package reroutes soft cap there); acquisition/brand_collapse/vc_rejection_cascade are EA follow-ups; no em/en dashes anywhere in drafts (task law overrides the repo's newspaper-only rule).

**Voice law v2 (binding for all later arcs):** no props, no present-tense body narration of NPCs, no similes/metaphors/aphorisms beyond sealed lines, Frank ≤3 sentences ≤10 words, facts the game knows over invented detail, last TR sentence shortest, sealed texts byte-exact with nothing added around them, A/B/C alternatives per node for the director. Self-check = banned-word grep + sentence counter + narration grep + dash grep + sealed byte-match, results pasted in the report.

**Why:** the doc's filename is a trap (an hour was lost searching for it); the batch cadence and rulings are not derivable from the repo.
**How to apply:** open `docs/.md` first; read `_vocabulary.md` §c/§e before writing any node (no slots, no wired hooks, 43 modifiers/27 conditions); mark gaps `[VOCAB?]`/`[COND?]`, never invent. Related: [[localization-tr-en-task]], [[project-unicorn-current-stage]].


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Event authoring Batch 1 → Frank Voice Pass](event-authoring-batch1.md) — Y-arc task STOPPED 2026-08-19; Pool Design is `docs/.md` (hidden filename); Frank inventory at `docs/writing/FRANK_VOICE_INVENTORY.md` (26 rows, whitelist per row); Phase 2 = one scene per turn on Erdem's call; weekdays exist (Day 1 = Thu 1 Jan 2026), daily beats fire at hour 00
