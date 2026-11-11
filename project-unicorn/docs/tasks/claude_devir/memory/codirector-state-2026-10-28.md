---
name: codirector-state-2026-10-28
description: "Co-director state on the laptop (Mac), 2026-10-28: two parallel sessions briefed (URUN_ARAYUZU D0–D8, OLAYLAR O0–O2), verified MCP recipe, pending Erdem items"
metadata:
  type: project
---

**Setup.** Laptop is an Apple M1 with 8 GB. Clone at `~/Desktop/project steam/Project Unicorn`. Local commit `f06bed6f`
(not pushed) holds:
- PRD E1–E7;
- ORTAK_CALISMA §9;
- `docs/tasks/dizustu/mac_env.sh`;
- GOREV_DIZUSTU_URUN_2026-10-28;
- GOREV_DIZUSTU_OLAYLAR_IKON_2026-10-28.

**Verified MCP recipe** (2026-10-28):
- Start the game from a scratch copy with `gd` (own HOME, windowed). The MCPRuntime autoload listens on 127.0.0.1:7777;
  the first Godot process to bind takes the port.
- gopeak `runtime-status` (projectPath = the copy) connected, and `capture-viewport` worked.
- Don't use gopeak `editor-run`: it gets no HOME isolation.
- `pkill -f <path>` doesn't match because cwd is not on the command line; use `kill <pid>`.
- Import of a fresh copy takes about 34 s. Free memory with nothing running is about 2 GB.
- `/usr/bin/env bash` is 3.2: no `mapfile`; `export -f` works in bash but not zsh.

**Plan review.** Two Opus reviewers, 2026-10-28; both briefs were "not executable" until fixed. The main fixes now in the
briefs:
- The "a ile deneyelim" reading is ambiguous: it could mean Q2 widening the window, or §3(a) of the UE page. D3 waits for
  my "D3 başla" and I asked Erdem to confirm.
- Met requests are filtered out of the left column (`product_model.gd:287`). The met row's lifetime, sort order and fold
  count go to Erdem with the D1 frames.
- `uk_a.patch` reserved width for an empty slot; that gets fixed.
- `a4_two_pm` is ERP-only, so the B2C icons need `b2c_live`.
- `assets/icons` has no known source (L4 release blocker). Lucide is the only licensed fallback.
- O2 share definition: sat + PROMISE_BROKEN_SAT + target shift (ledger hit + raised bar). No drift, no forgiveness, no
  onboarding floor. Rewrite `promise_break_chain`, delete `satisfaction_after_break` if dead, re-shoot the 2 cards and
  republish the Olaylar page.

**Waiting on Erdem:**
- confirm "a" (D3);
- E5 form plus the met-row rule;
- icon picks;
- UM's 3 questions;
- the 3 Olaylar points;
- goal display;
- ACIK 14 rest, CLAUDE.md, project.godot, history rewrite, Sales R&D;
- the TR/EN round and priorities.

The UM thread was answered and resolved.

**Erdem's answers, later on 2026-10-28.**
- Window widening (D3) confirmed; I sent "D3 başla" to URUN_ARAYUZU, which is `project-steam-88`. OLAYLAR is
  `project-steam-39`.
- Q8, goal display: B is OK. Put it behind a button near "?"/settings like Planet Zoo, opening its own view. Design study
  workflow `hedef-gosterimi-tasarim` is running: 3 directions (rail / top bar / help hub) plus a judge; PNGs go to
  scratchpad `hedef_tasarim/`.
- Q9, verbs: wire `start_training` and `fire_employee` to the player flows. That is O3 in the OLAYLAR brief, commit
  `aa66f3e0`.
  - `add_customer` conflicts with the 10-26 rule "olay imzalatmaz, teklif verir". `add_prospect` and `prospect_offer`
    already exist. My rec: drop `add_customer`.
  - `convert_audience` and `open_paid_tier` are in the vocabulary's economic list, but no card uses them. My rec: remove
    them from the vocabulary and the GDD. That is Erdem's call (CLAUDE.md §2).
- Q10, paper rate: Erdem asks whether we need a rule at all. Research workflow `olay-sikligi-arastirmasi` is running
  (EU4/CK3, RimWorld, management games, FTL/Reigns, failures).
- Q11 `project.godot` stays. Q12: no history rewrite. Q13: Sales/CS R&D parked to the end.
- Q14 TR/EN: the texts he approved stay. Changed options get reviewed during playtests; no separate text round.
- Test suite: Erdem says the tests are old-fashioned, gates pass and the game still breaks, so the suite needs an
  overhaul. Audit workflow `test-sistemi-denetimi` is running and will propose a redesign with a step table.
- Playtest: Erdem asked me to playtest in parallel after these jobs, answering events. It needs the ekran lock and one
  Godot slot.
- Konuşulacaklar page:
  - Republished on this account at https://claude.ai/artifact/64Xu9gTrmkZ2z7hwj2qne2 from
    `docs/strateji/konusulacaklar/index.html`. It still carries its 10-23 content plus a banner.
  - Update workflow `konusulacaklar-guncelle` writes scratchpad `konusulacaklar_v2.html`. Review it, copy it over the repo
    file, republish to the same path.
  - The old account's artifacts are not listed on this account.
- Lesson: I committed `f06bed6f` and `aa66f3e0` with a plain `git add`/`commit` while the agents ran. Only my file was
  staged, which I checked. Next time take the `kapi` lock (ORTAK §3/§9).
- **Memory, 18:30.** The Mac reached pressure level 2 (warn) with swap at 1.4/2 GB. Three claude processes use about 300 MB
  each, and Chrome holds about 800 MB across several processes. The 1,500 MB gate had stalled every Godot run.
  - Fix `219a534`: the gate now follows `kern.memorystatus_vm_pressure_level`. At level 1 up to 2 Godot processes run; at
    level 2, 1; at level 4, none. Free memory must be at least 1,000 MB.
  - `godots` now uses `pgrep -x Godot`. With `pgrep -f` it also counted waiting shells.
  - Sourcing the file in zsh returned 1 because it ended in `&&`. It now ends in `if … fi`.
  - Commits now go through the kapi lock and a private index (ORTAK §3).
- **Pages published 2026-10-28, all waiting on Erdem's decisions.**
  - Konuşulacaklar v2: https://claude.ai/artifact/64Xu9gTrmkZ2z7hwj2qne2, 113 topics; source
    `docs/strateji/konusulacaklar/index.html`.
  - Test Sistemi Denetimi: https://claude.ai/artifact/R39g2xRDjaxymGMdhxXbEJ.
    - Finding: 19 player-visible bugs escaped in 10 weeks and the tests caught none.
    - 5 decisions: pilot first (rec yes); old saves (rec a, drop them); full suite weekly and before playtests (rec b);
      pre-commit hook if fast is under 2 minutes; no framework for now.
  - Olay Sıklığı Araştırması: https://claude.ai/artifact/S2xbq9s9wEUrc6Y14a1EEa.
    - No game writes "X% of turns" as a rule.
    - 3 decisions: B, principle plus dated measurement (rec now); fix the 18 papers that never fire, 8 of them designer
      papers (rec now); C1/C2 (dice slot, max silence) after the playtest.
    - Verified in code: a sprint that closes in week 1 never rolls the paper dice (`sprint_system.gd` ~1323).
  - Plandaki İstek Biçimi (E5 frames from URUN D1): https://claude.ai/artifact/XJ28zrtzJHLRzXkGMbxnQp.
    - 4 questions: form, my rec (2) card status; met row lasts about 2 weeks; "Bu sprintte"; date under the name.
    - N2 items b and c go into the E5 commit without asking.
- Goal-display design workflow `wiemfsy8f` is still running.
- **Goal panel design study done.** Page: https://claude.ai/artifact/9oNyACLjckt4VMtBauqU7i.
  - Directions: A rail, B top bar, C rail plus help. The judge scored A 23, C 23, B 21.
  - My rec is the combined design: A's place above AYARLAR, C's closed row "4/5" with a segmented bar, B's panel order
    (current goal big with bar and "Satış'a git", then the ladder, then the locked Seed list).
  - 4 questions: which design; Frank's quote only in the portrait tooltip; hide the row when no list; Help tab later.
  - B is out because it costs top-bar space in compact mode (`COMPACT_SHELL_BELOW` 1680) and collides with
    `office_notice_stack`.
  - Sources are in `docs/tasks/dizustu/raporlar/hedef_paneli/`.
- **Done 2026-10-28:**
  - URUN D2/UK is `eebf909`; I checked a frame.
  - OLAYLAR O1 icon sheet: https://claude.ai/artifact/EjbzWnnw7aR3uPGaFSiN2t. Rec: door, puzzle, sprout, banknote (Lucide, marked "set dışı").
  - O2 7c is `87e06d68` (slip 72→41).
  - O3 "Olaylar 8" is `b2639465`: start_training and fire_employee wired, satisfaction_next_tick deleted. New TR/EN keys
    EFFECT_TRAINING and EFFECT_FIRED wait for approval.
  - I settled 3 of URUN's 4 D4 questions myself: fix-card full text wraps, "S{n}" becomes "Sprint {n}", the UM short
    names stay. Question 1 (narrow stage bars hide the number and faces) goes to Erdem on the D7 page, with a frame for
    (a) and for (b) the number outside the bar; my rec is (b).
- **Playtest delegated to OLAYLAR (project-steam-39), first harness fix (PersonBust wait):**
  - Run: fresh B2B ERP, 30 weeks or 2 h, answering events like a player.
  - It logs the paper silence and speaker spread (Erdem's two questions).
  - Output in `docs/tasks/dizustu/raporlar/playtest_2026-10-28/` plus an artifact.
  - It yields the ekran lock to URUN D3.
- **2026-11-02, laptop turn ends.** Erdem: "bu bilgisayarda devam etmeyeceğiz", Antalya desktop from tomorrow, push now.
  - I gave both sessions permission to write to git: URUN commits D3 UE1, D5 UM1 and D4a U7; OLAYLAR commits the
    harness fix and the playtest report.
  - Playtest page: https://claude.ai/artifact/QjpxDNSNgfDt3KzT3VBGE8.
    - 30 weeks in 66 min; 5 bugs found; papers only from the founder/Frank in weeks 1–12.
    - The longest paper gap was H22→H29.
  - URUN's U8 page: https://claude.ai/artifact/Wqm2PqBZQXcuGjJzyotNvz.
  - Handoff `docs/tasks/DEVIR_MASAUSTU_2026-11-02.md`. Memory and this transcript go back into
    `docs/tasks/claude_devir/` for kur_windows.ps1.
  - The iCloud question went unanswered and is moot, since the Mac is not used further.
