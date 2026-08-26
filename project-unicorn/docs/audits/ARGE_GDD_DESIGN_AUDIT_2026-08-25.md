# Ar-Ge GDD — Design Audit

**Date:** 2026-08-25 · **Type:** Design audit + comparative research · **Read-only** (no source, data, fixture, baseline, save or git change; nothing run)
**Under audit:** `GDDs/GDD — AR-GE MODÜLÜ .docx` rev 1 / rev 1.2, status *DİREKTÖR ONAYI BEKLİYOR* 2026-08-24
**Read against:** `GDD v2 — 03 · Product Lifecycle.docx` rev 6.1 · `GDD — EKİP MODÜLÜ vson.docx` · `GDD v2 — 01 · The Run (spine)` · the working tree
**Live-tree caveat:** the Ürün rebuild is being written into this same checkout right now. Every code claim below is against the tree as read on 2026-08-25; `product_system.gd`, `product_lines.gd`, `line_gates.gd`, `research_seam.gd` and `data/product/lines/*.json` are that agent's live files and should be re-checked before acting on any line number.

---

## Executive verdict

**The design is good, and its three sealed decisions are all correct.** No research currency, no linear chain, and shape-visible/content-hidden are each the right answer to a well-known failure in this genre, and §5's flow — one active research, live day estimate that moves as you toggle people, freeze-don't-burn on pause, no RNG, no countdown, no penalty — is the most disciplined decision surface any module in this game has been given on paper. §3.1's fairness rule is already enforced in code. The module is a genuine consumer of the Ekip seams rather than a second HR system, and it is the sole gate on 9 K3s per subtype, so on paper it is the best-integrated system we have.

**It has one hole that is not a polish item: nothing in either GDD makes research cost the player anything.** §1 stakes the whole module on one sentence — *"birini masadan kaldırıp araştırmaya verirsin, o kişi o süre boyunca ürün yapmaz"* — and neither document contains a rule that produces it. Ekip §12.0 says in as many words that research is not a job (`HRConstants.JOBS` holds exactly five ids, `job_count` reads `assigned_job_ids`), so an employee on Build who is also put on research keeps `focus 1.00` and delivers **full output to both at once**, and never picks up the AŞIRI YÜK morale cost. For the founder it is worse: Ar-Ge §7 promises *"kurucu tek işçi, araştırmaya geçiyor → aktif yapım oto-duraklar (Ekip §2.1)"*, but Ekip §2.3's own table rules **Araştırmada · Meşgul mü: Hayır**, and §2.1 pauses on *busy* or *unassigned* — so the founder researches for free too. The module's premise is false in both directions, and no document owns the seam.

**And one scope problem: more than half of what the doc asks somebody to write cannot be reached inside the slice it was written for.** Ar-Ge opens at v1 ship — day 25 in the measured reference run (`calibration_round_A_2026-08-19.md` §Beats) — and the demo cuts inside Traction. All 8 continuation nodes, all 4 cross-family links (the doc's best structural idea, MÜHÜRLÜ), all 4 hidden lines (12 authored tiers) and, under the strict reading, the whole of §6 sit past where a demo player will stop. A player who spends the entire Traction period on one family and ships almost nothing can touch one continuation; a player who plays the game will not.

**The one thing I would fix first:** make research occupy people — `job_count` +1 for a researching employee, and research clears the founder's build assignment exactly the way `pitch_prep_active` already excludes them at `product_system.gd:386`. It is hours of work, it needs no new system, and until it lands every other judgement in this report is about a module that costs nothing.

**Verdict on scope:** sufficient for the demo after P1 (hours) and a director ruling on P2. Everything else in this report is triage, not a blocker.

### Scores

| # | Dimension | Score | One line |
|---|---|---|---|
| 1 | First contact | **7** / 10 | Best entry point in the game — you arrive holding a thing you want. Nothing names the skill cost before you press Start. |
| 2 | The decision | **6** / 10 | The family choice is a real trade; staffing collapses it to one or two live options, and one of the four families is dominated. |
| 3 | Cost legibility | **8** / 10 | Live day estimate per assignment is exactly right. It prices the research, not the build you stopped. |
| 4 | Pacing across a run | **4** / 10 | Silent through all of Bootstrap by design; its second half is outside the demo slice. Weakest dimension by a distance. |
| 5 | Payoff | **6** / 10 | Unlocks land hard and are worth more than the doc admits. Three nodes move numbers the game explicitly refuses to show. |
| 6 | Replay value | **6** / 10 | 3–6 of 20 is structural. The fog is spent after run 1; one dominant pair is discoverable. |
| 7 | Failure modes | **5** / 10 | No RNG, no burn, no countdown — the rules are respected. Three unwarned traps survive anyway. |
| 8 | Integration | **7** / 10 | Load-bearing on paper, free in practice. Fix G1 and this is an 8–9. |
| | **Overall** | **6** / 10 | Good design, two real holes, cheap fixes. |

---

## Evidence and its limits

| Lens | Instrument | Coverage |
|---|---|---|
| A — document | Full text of Ar-Ge rev 1.2, Ürün rev 6.1, Ekip vson, Run spine, extracted from the `.docx` sources | Complete |
| B — code | Read-only trace of the seams Ar-Ge will sit on: `research_seam.gd`, `line_gates.gd`, `product_lines.gd`, `quality_model.gd`, `hr_system.gd`, `hr_constants.gd`, `hr_candidate_generator.gd`, `founder_constants.gd`, `time_manager.gd`, `save_manager.gd`, `build_bar_model.gd`, `build_hud_panel.gd`, `oda_view.gd`, `oda_layout.gd`, `ui_tokens.gd`, `data/product/lines/*.json` | Complete for the seams; the Ürün rebuild is live under it |
| C — measured play | `docs/audits/calibration_round_A_2026-08-19.md` — the 730-day competent B2B run, its beats, waypoints and card counts | Borrowed, not re-run |
| D — comparison | Seven reference games plus two design-theory sources, cited at the bottom | Complete |

**Three honest limits.**

1. **Nothing was run.** No smoke, no probe, no shot, no editor. Every number below is arithmetic over document constants and read code, or a quotation from the calibration report. Where I compute, I show the computation so it can be checked without running anything.
2. **The tree moved under this audit and is still moving.** `research_seam.gd`, `line_gates.gd`, `product_lines.gd`, `product_state.gd`, `infra_system.gd`, `support_system.gd` and `data/product/lines/` are untracked or modified files belonging to the in-flight Ürün rebuild. Claims that lean on them are marked. Two of them are load-bearing for this audit and both were read twice: `ResearchSeam.NODES` (the 20 ids, verbatim from Ar-Ge §4) and `ProductLines._validate_step` (the §3.1 fairness guard).
3. **The demo cut point is not fixed.** Run spine §10 lists it as an open item ("Exact demo cut point inside Traction"). My pacing arithmetic assumes the demo ends somewhere in day 90–120 of the reference run. If the cut lands later, G2 shrinks; it does not disappear, because the continuation chain is 3 nodes deep in effort before the two-area rule is even tested.

---

# Part 1 — The eight dimensions

## 1 · First contact — 7/10

**What works, and it is the best thing in the document.** §2 refuses an opening card and routes first contact through the *→ Araştır* link on a locked K3 in the Konsept feature list. The player therefore arrives at the tab already holding a concrete want — "I want AI on my notes tool" — with the tree opening on that node, selected. That is a substantially better first contact than a tech tree can normally buy, and it is the correct application of the no-advisory-UI rule: the game never says *go research*; the lock line the player was already reading says which door is shut.

rev 1.2's reversal on hidden slots is also right. "Açığa çıkmamış düğüm ekranda hiç yoktur" would have taught a first-time player that Ar-Ge is four researches. Twenty countable slots, four coloured columns, five deep, with `?` in the unopened ones, answers *how big is this* in one glance, which is the first question and the one the old rule got wrong.

**What is missing.** The card in §8 says three things — what it is, what it opens, and *"Ürün alanı · ~9 gün (Kurucu) · GPU kirası $600"*. Two costs are absent from that line and both bite on first contact:

- **The build you are about to stop.** §5.5 claims the day estimate delivers this: *"Oyuncu yapımı durdurmanın bedelini karar anında görür."* It does not. A research that takes 9 days tells you nothing about what those 9 days cost, and the founder-only case (the whole of Bootstrap) is a *stop*, not a slowdown. The card needs one more clause, and it is a clause the engine can already compute.
- **Who can do it at all.** "Ürün alanı" names the area but never the threshold, and the threshold is not written anywhere in the document (see G11). A player whose founder put six points into Yazılım and Satış opens a Capability node and reads "Ürün alanı · ~∞".

**Timing.** The tab appears at v1 ship, which in the reference run is day 25 and is simultaneously: ship moment, price decision, infrastructure decision, hata tooltip, first revenue four days later. §2's argument for opening it there is sound (opening earlier is a trap) but it means the tab's arrival is the fifth new thing in one screen-minute. The rail badge is the mitigation and it already exists in code.

## 2 · The decision — 6/10

**The axis is real.** Choosing a family is choosing which of your people stops working, and because §5.4 reads speed from the family's own area, the four families price differently for the same company. That is a genuinely good trade and it is not a trade any of the reference games make (see Part 3).

**Three things collapse it.**

**Staffing decides for you.** Family → area is Capability→Ürün, Platform→Yazılım, Practice→Test, Design→Tasarım. Ekip §4.4's role table means a Yazılım Mühendisi carries Yazılım and Test and *nothing else* — `HRConstants.can_hold_area` returns false, and `HRSystem.effective_skill` returns `0.0` at `hr_system.gd:401`. In the measured competent run the company has exactly one employee at day 275, a developer. So Capability and Design are **founder-only** for the entire run and Platform and Practice are the only two families with a second pair of hands. §5.6's showcase flow — *"Tasarım fazı biten bir tasarımcıyı araştırmaya kaydırmanın yolu budur"* — assumes a designer the reference run never hires.

**One family is dominated.** Grepping every K3 requirement in the shipped content: `scalable_backend` ×5, `ai_engine` ×5, `design_system` ×4, `semantic_index` ×2, `security_cert` ×2, `data_model` ×1, `analytics_engine` ×1. Seven nodes. **The entire PRACTICE family gates nothing visible in any subtype** — not one K3 in `note_tool.json`, `video_clip.json`, `erp.json` or `shared.json` names `bug_tracker`, `cicd`, `test_automation`, `incident_playbook` or `self_service`. Practice is a pure coefficient family whose four coefficients are all invisible (see dimension 5). A player who never opens it loses no content. That is the load-bearing question applied *inside* the module, and one quarter of the tree fails it.

**Nothing is given up.** §5.7 lets you switch nodes freely with progress conserved and no penalty. That is correct under the recoverable-pressure rule and I would not remove it. But combined with §5.1's single-active rule it means the player has parallel research with a manual round-robin, and a min-maxer can park four nodes at 99% and land them together. §5.1's stated purpose — *"sekme 30 saniyelik bir ziyaret olmalı, bir iş kalemi değil"* — is not what free switching produces. At 3–6 nodes per run this is theoretical rather than harmful; I note it as a shape, not a defect.

## 3 · Cost legibility — 8/10

The strongest engineering in the document. §5.5's live day estimate recomputed as the player toggles people is the correct instrument, §8's *"Yüzde, puan, 'araştırma gücü' gibi ikinci bir sayı yoktur. Tek sayı gün tahminidir"* is the correct discipline, and the cash gate writes its own reason rather than greying out silently.

**The arithmetic is in a good band, and that is worth stating plainly.** With `hr.effective_skill` returning raw points (0–10) and `K_ARGE = 1,0`:

```
research/day     = raw × area_coef × focus × morale × 1,0      (at 8h)
build effort/day = raw × area_coef × … × 8/12 = raw × 0,667
```

A founder who put three onboarding points into one column carries raw 6 (`FounderConstants.RULER_SCALE = 2`, cap 3):

| | effort | days at raw 6 | days at raw 2 |
|---|---|---|---|
| `data_model` / `bug_tracker` (kök) | 40 | 6,7 | 20,0 |
| `scalable_backend` / `design_system` (kök) | 50 | 8,3 | 25,0 |
| branch nodes | 70–80 | 11,7–13,3 | 35–40 |
| `ai_engine` / `security_cert` | 90 | 15,0 | 45,0 |

Against that, a three-step v2 (≈20 effort) with four design turns (`EforTavanı × 0,08` each) is ≈26 effort ≈ **6,6 days** at the same raw 6. **One root research costs about one whole version.** That is a legible, painful, correctly-sized price, and the branch/continuation tier at 70–90 correctly reads as a bet rather than a purchase. The 3–6 target in §13 checks out too: six nodes at 40+50+70+70+70+90 = 390 effort ≈ 65 solo days out of a 275-day run.

**The two points off.** The card prices the research and not the stop (see dimension 1), and the cash side is thin — three of twenty nodes carry cash at all ($600 / $400 / $900), so §5.3's cash gate and §7's *"Kasada $600 yok."* row fire in maybe one run in three. Worth knowing before someone builds a whole modal state for it. For calibration: the reference run's cash trough is **$6,450 on day 31**, six days after Ar-Ge opens, so `security_cert`'s $900 is 14% of the worst moment in the run. That is a real bite and correctly placed.

## 4 · Pacing across a run — 4/10

The weakest dimension, and the gap is structural rather than tunable.

**Bootstrap is silent by design.** §2 opens the tab at v1 ship. In the reference run: ship day 25, Traction gate day 34, first hire day 42. So Ar-Ge has nothing to say for the first ~9% of the run and the whole of the phase whose named pressure is *founder time* — the exact pressure the module is built to express. §2's justification is sound and I would not move the gate. But it means the module's answer to "does it have something to say in every phase" is *no, and deliberately*.

**The second half is outside the slice.** Run spine §1: *"Demo slice: Bootstrap → into Traction, ~60–90 real minutes."* Taking the reference run's own beats, a player who invests seriously reaches **2–4 nodes before day 120**, all of them kök or dal. To reach one continuation node you need its root and its branch first (Capability: 40 + 70 = 110 effort ≈ 18 solo days) plus the continuation itself (70–90) plus a second area at strength. That is 200 effort — 30+ days of a founder not building — inside a window where the reference run ships v2 (day 44), v3 (day 94) and v4 (day 108). It is not impossible. It is incompatible with playing the game.

What that puts outside the demo:

| Content | Amount | Where it lives |
|---|---|---|
| Continuation nodes | 8 of 20 | §4.1–4.4 |
| Cross-family conditions | **all 4** (MÜHÜRLÜ, §3) | devam-B only |
| Hidden lines | **all 4** = 12 authored tiers | §4.5 |
| Two-area requirement | **never tested** | §5.2 |
| Monthly product note | strict reading: never fires | §6 |

The four cross-family links are the document's single best structural idea — the thing that stops the tree being four independent lists and the thing that answers the beeline problem (Part 3). **They are all on devam-B nodes and therefore invisible in the demo.** Likewise §5.2's two-area rule, which is the mechanic that makes the tree "yapısal olarak ekip işi": it never gets exercised.

This does not mean the design is wrong. It means the demo is being asked to pay for a second half it will not show, and §12.1's content bill is priced for the full tree. That is a scope ruling, not a defect — but it has to be *made*, and the document does not make it.

## 5 · Payoff — 6/10

Genuinely split, and both halves are bigger than the document says.

**The good half is bigger than advertised.** §4.5's hidden lines are described in one line each as "yeni gizli hat". What they actually do, traced through `quality_model.realized_axis`: `register_runtime_line` appends the new line to `_by_subtype[subtype]` (`product_lines.gd:498-503`), and `realized_axis` iterates `ProductLines.line_ids(subtype)` — so a hidden line is a **fourth line on an axis the bar was calibrated for at three**. Shipping its K1 adds `4 × 1,0 = 4,0` to that axis's realized value. Against `PHASE_BAR[3] = 14,5` that is:

```
Δreading = 100 × 4,0 / 14,5 = +27,6 points
```

versus a normal K1→K2 upgrade, which nets `(9 × 0,8) − (4 × 1,0) = +3,2` raw = **+22,1 points**. **The first tier of a hidden line is worth more than upgrading an existing line, because it adds where every other tier replaces.** That is a superb payoff and it is completely undocumented — see G6, because it is also uncalibrated and it lopsides the triangle.

**The bad half is three nodes that move numbers the game refuses to show.** §1 sets the rule: *"Her düğüm ya bir içerik kilidi açar ya oyuncunun zaten ekranda gördüğü bir katsayıyı oynatır."* Checked node by node:

| Node | Effect | Is the player shown it? |
|---|---|---|
| `cicd` | hata/efor 0,45 → 0,35 | **No.** Development bugs are hidden, and Ürün §7 seals it: *"Hata havuzunun büyüklüğü oyuncuya asla tahmin edilmez; sürpriz kanoniktir."* |
| `test_automation` | BETA keşif sönümü 0,85 → 0,90 | **No.** Ürün §7 forbids a percentage on the BETA line, and one run gives no baseline to compare against. |
| `bug_tracker` | doğrulama verimi 0,8 → 1,0 | **Barely.** The GELEN/DOĞRULANMIŞ counters move faster; the coefficient is never on screen. |
| `incident_playbook` | aşım zararı −0,8 → −0,5 | **Only in overage**, a state the game teaches you to avoid. |

Four of the five Practice nodes are unobservable, and §5.8's discovery card is deliberately mute about mechanics — *"sayı tablosu değil, bir beat"*. So the player's total evidence that `cicd` did anything is a two-line paragraph about a build server. The tone rule is right; the consequence is that a third of the tree pays in a currency the player cannot see. Note that the attribution law does not forbid saying so: the state exists, so the card is permitted to name it.

**One ordering note.** `_tick_rnd()` is slot 2 in `time_manager._dispatch_daily_tick`, after `_tick_product()` (which now also runs `SupportSystem.daily_tick()` and `InfraSystem.daily_tick()`) and before `_tick_hr()`. A node completing on day N that moves a Support or Infra constant therefore takes effect on day N+1. Harmless, but it makes an already-invisible payoff one day later.

## 6 · Replay value — 6/10

**Structural replay is real and it comes from three places.** 3–6 of 20 nodes means no run sees the tree; that mirrors Ürün §12.10's 9–14 of 27 tiers and is the same good bet. The founder's six onboarding points across eight columns (`POINT_POOL = 6`, `ONBOARDING_CAP = 3`) genuinely reshape *which families are openable at all* — a Ürün/Yazılım founder and a Tasarım/Test founder play different trees, and that is a better replay engine than the tree itself. Hire order compounds it.

**What depreciates.** §3's fog is a first-run instrument: the shape is public from second one and the *contents* are fixed and canon, so by run 3 the player knows all twenty nodes and the fog is decoration. The four cross-family links are what would still be doing work in run 3 — and they are the part the demo cannot reach (dimension 4). So the demo's replay value is carried almost entirely by the founder-build and hire-order variation, not by the tree.

**One dominant pair.** Two of the four hidden lines land on **Deneyim** (`Kendi Kendine Servis` via `self_service`, `Uyarlanabilir Arayüz` via `personalization`). Taking both gives that axis five lines against three for the others, and per dimension 5 each is worth +27,6 reading points at K1. That is discoverable, it is optimal, and it is the shape Soren Johnson warns about. One of the two should move axis.

## 7 · Failure modes — 5/10

**The document takes the standing rules seriously and mostly delivers on them.** §5.7 freezes rather than burns, with the reason given: *"Yanacak olsa kimse başlamaz (kurtarılabilir baskı)."* §11 rules out research failure and RNG explicitly on the unwarned-loss rule. §7's edge table names sixteen cases and writes the reason line for each. §3.1's fairness rule is not just prose — `ProductLines._validate_step` enforces it at load (`product_lines.gd:300-305`, calling `ResearchSeam.may_gate_visible_step`), so a content file that hangs a visible K3 off a continuation node fails loudly. That is better than most of our sealed rules manage.

**Three traps survive.**

**A bar that never moves.** §5.3 says *"kurucu daima listede"*. §5.4's rate is `Σ hr.effective_skill(...)`. `hr_system.gd:396-398` returns `0.0` when the area's raw points are 0. A founder with zero Test who is checked onto `bug_tracker` produces **0 research/day**: the bar sits at 0%, §5.7's "Kimse üzerinde değil." does not fire because someone *is* on it, and §5.5's live estimate divides by zero. §7's table has no row for it. This is the cleanest unwarned loss in the design: the player commits days to a bar that will never fill and nothing tells them.

**Six points, closed families.** The founder spends 6 points over 8 columns with a per-column cap of 3, so at least two areas are zero and realistically three or four are. If Tasarım is one of them and no designer is hired, `design_system` is unreachable — and `design_system` is the binding K3 node for **Mobil & Erişim in all three subtypes** (`ResearchSeam.SHARED_LINE_NODES`), gates an identity K3 in each subtype, and is the cross-condition for **two of the four** hidden lines. A telegraphed, visible, locked K3 is therefore unreachable for a reason §3.1's fairness rule does not check — the rule validates *tree depth* at load and never validates *staffing* at runtime. It is recoverable (hire a designer; or train the founder, which Ekip §5.2's founder exception permits from zero) so it is not a wall. It is unwarned, and it is unwarned at the one moment it could have been cheap to warn: onboarding.

**§6's report has no author, or the wrong one.** §6.2: *"Sesi, şirketteki en yüksek Ürün ya da Tasarım yıldızına sahip çalışan (kurucu hariç). Böyle biri yoksa rapor gelmez."* `hr_candidate_generator._skills_for` fills **every** area of **every** employee with the archetype's `rest_v` plus a rotation bump — so a sales rep has nonzero raw Ürün. Read as written (`hr.skill > 0`) the rule picks whoever happens to have the highest number in an area they are forbidden to work in, and the fiction collapses: a customer rep writes the product research note. Read as intended (`can_hold_area`) only a product_manager or a designer qualifies — and the reference run hires neither, so **the largest single feature in the document never fires in the run we calibrated against.** Both readings are broken; the document has to pick one and then live with it out loud.

## 8 · Integration — 7/10, conditional

**On paper it is the best-integrated module we have.** It is the only gate on 9 K3s per subtype; the Ürün rebuild has already built its half of the seam and validates against it; `ResearchSeam.NODES` carries the 20 ids verbatim from §4 with the placement rule; `ResearchSeam.NODE_EFFECTS` already maps each coefficient node to the system that owns the arithmetic, so §9's single-source rule survives contact. It reads Ekip rather than duplicating it — no second assignment ledger, no research skill, no second speed formula. It also opens content for Satış (`security_cert`'s whale signature condition, `accessibility`'s optional enterprise condition) and for Ops (`scalable_backend`'s load divisor). The plumbing is right.

**But the load-bearing question answers badly today.** *Can a player win while ignoring Ar-Ge?* §7 already concedes yes — *"koşu kazanılabilir kalır; tüm K3'ler kapalıdır"* — and prices the neglect as a rising bar. That is a defensible answer *if* research costs something, because then ignoring it is a choice with an upside. Today it costs nothing (G1), which means the honest answer is worse than the doc's: a player can have the K3s **and** the versions, because the founder and the employees work both jobs for free. Fix G1 and this dimension is an 8–9.

**One direction is missing entirely.** Ar-Ge reads Ekip and writes to Ürün. Nothing writes to Ar-Ge — no event moves it, no customer demand points at a node, no rival action changes its value, and the world never mentions it. §6's monthly note is the only inbound channel in the design and it is the part that may never fire. For a narrative-strategy game that is the gap that matters most after G1: research is currently a thing the player does *to* the game rather than a thing the game has an opinion about.

---

# Part 2 — Gaps, ranked by player impact

### G1 · Research costs nobody anything · **CRITICAL** · cheap to fix
`HRConstants.JOBS` is `["build", "test", "support", "accounts", "sales"]`; `HRSystem.job_count` reads `assigned_job_ids.size()`; `focus_mult` reads `job_count`. Research is in none of it, and Ekip §12.0 says so on purpose: *"Araştırma sütunu yoktur."*
**What breaks.** An employee on Build + research keeps `focus 1,00` and delivers full output to both, and `is_overloaded` stays false so the ×1,5 morale drift never lands. The founder is worse: Ar-Ge §7 cites Ekip §2.1 for the auto-pause, but §2.1 fires on *busy* (leave / training / pitch prep, §2.2) or on *nobody assigned*, and Ekip §2.3's table rules **Araştırmada · Meşgul mü: Hayır**. There is no rule anywhere that removes the founder from the build.
**How a player notices.** They don't — that is the problem. They notice that research is free, and then that it is always correct to research.
**Cost to fix.** Hours. See P1.

### G2 · Half the module is outside the demo slice · **HIGH** · needs a ruling, not code
8 continuation nodes, 4 cross-family links, 4 hidden lines (12 tiers), the two-area rule and probably §6 all sit past a realistic demo cut. §12.1 bills content for all of it — 20 names, 20 discovery cards, 12 hidden-line tiers, ~24 report lines — in two languages.
**How a player notices.** They don't. They see twenty slots, open three, and stop, which is the intended feeling. The cost is ours, not theirs: we write and localise a second half nobody sees.
**Cost.** Zero if the answer is "accept it and cut the content bill"; a day if we move content down the tree.

### G3 · §6's author test is broken in both readings · **HIGH** · cheap
As traced in dimension 7. Either a sales rep writes the product note, or the largest feature in the document never fires in the reference run.
**Cost.** One sentence in the GDD plus one line of code, *plus* a scope decision about §6.

### G4 · Zero-skill assignment: a bar that never moves · **HIGH** · cheap
`effective_skill` returns 0 for an area at raw 0 (founder) or for a role that cannot hold the area (employee). Nothing in §5, §7 or §8 covers Σ = 0. §5.5's estimate divides by it.
**How a player notices.** They start a research, come back three days later, and it is still at 0%.
**Cost.** Hours. Card refuses to start, names the area, and §7 gains a row.

### G5 · Six onboarding points can silently close a family and a binding K3 · **MEDIUM-HIGH**
Detailed in dimension 7. Recoverable via hiring or founder training, so it is not a wall — but the only warning is §7's *"Bu alanda kimse yok."* which appears at the moment of the attempt, after the player has already built a product around a K3 they cannot open.
**Cost.** Cheap — the locked slot and the node card carry the area; see P3.

### G6 · A hidden line is a fourth line on a three-line axis, and nobody owns it · **MEDIUM-HIGH**
Ürün §11.2 defines the latent axis as a sum *"üç hat üzerinden"*, and `PHASE_BAR = {1: 12,0 · 2: 13,2 · 3: 14,5}` is exactly three lines at K1 (`3 × 4,0 = 12,0`). `realized_axis` iterates all lines including runtime ones, so a hidden line permanently raises that axis's ceiling by ~+27,6 reading points at the Series A bar while the bar itself does not move. Neither GDD mentions this. Two of the four land on Deneyim.
**How a player notices.** As a reward, which is fine — until the triangle whose *"tek okuması asimetrisidir"* (Ürün §17, MÜHÜRLÜ) becomes asymmetric *because they did well*. The instrument's meaning inverts.
**Cost.** Cheap as a ruling; free if the answer is "yes, and it is intended" plus one axis reassignment.

### G7 · The PRACTICE family opens no content in any subtype · **MEDIUM**
Zero of the shipped K3 requirements name a Practice node. All four of its coefficient effects are invisible (dimension 5). The family is therefore both content-free and evidence-free.
**How a player notices.** They open it once, feel nothing, and never open it again.
**Cost.** Cheap — bind one visible K3 to `bug_tracker` (a kök node, so §3.1 is satisfied) and the family stops being dominated.

### G8 · §6.1's ODA paper cannot be expressed by today's desk · **MEDIUM**
`OdaView._gather_papers` is a **stateless derivation** from live state with `PAPER_CAP = 3` and a fixed priority: gate → term sheet → Atlas → one paper per B2B account in expansion. It has no unread concept, no persistence, and the expansion source is unbounded (the reference run fires `ev_b2b_expand_*` 25 times). §6.1 needs a stored, dismissible, unread-flagged artifact that survives a save, and it needs a slot it will not be pushed out of.
**How a player notices.** The rail badge says there is a report; the desk does not show it.
**Cost.** Medium — new paper state plus a priority ruling.

### G9 · §8.5's save list misses §6 entirely · **MEDIUM** · cheap
The six persisted items cover the tree and nothing else. Not persisted: the last report's issue day (the 30-day clock), the pending report and its unread flag, and whether the first-report tutorial modal has already been shown. A save/load either loses the report or re-shows the tutorial.
**Cost.** Three keys. `SCHEMA_VERSION` is already 9 and `MIN_LOADABLE_VERSION` is 9, so this is free *if* Ar-Ge ships in the same package as the Ürün rebuild, as both documents say it will.

### G10 · "Three bars side by side" — the hosts hold one · **MEDIUM**
`BuildHUDPanel` is a single `$Root/BuildBar` at a fixed `CARD_W = 360`; `OdaView` holds a single `_mon_bar` inside the monitor glass, itself inside a frozen theme with a byte-compared `--theme-audit=oda` gate and the D4 layout standard. `BuildBarModel`'s phase enum is a four-value **product-phase** machine (`design/development/beta/support`) derived from ProductSystem seams — research is not a product phase, so it is a second bar type, not a fifth value. §5.6 assumes all of this is free.
**Cost.** Medium in the tab; expensive and risky in the ODA glass. See P7 for the cheap honest version.

### G11 · Node star thresholds are unspecified · **MEDIUM** · cheap
§5.2 says kök/dal want *"tek alan"* and devam wants two, offers *"Örnek: Ürün ★2 + Yazılım ★2"*, and points at Ürün §12.6 for the ★N = raw ≥ 2N ruler. But §4's tables carry no requirement column, §12.1's content spec does not list requirements among the things to write, and §13's calibration surface does not include them. §7 then writes a reason line — *"Yazılım ★2 gerekiyor."* — for a threshold no node owns. Meanwhile §5.3's filter (*"gereken alan(lar)da yıldızı olan çalışanları listeler"*) is ambiguous in a way that matters: every employee has nonzero raw points in every area, so read literally the filter lists everyone and does nothing.
**Cost.** Cheap: one column in the §4 tables and one clarifying sentence in §5.3.

**A related note on §5.2's intent.** *"İleri araştırma yapısal olarak ekip işidir; tek kişiyle ağacın derinine inilmez."* As written the rule does not produce that: a founder who spends 3+3 onboarding points on Ürün and Yazılım holds ★3 in both and satisfies the example gate alone. If the intent is two *people*, the rule has to say people, not areas.

### G12 · §13's calibration list has four orphans and one contradiction · **LOW** · cheap
- `GELEN taban 0,2→0,12` in §13 vs `0,2 → 0,14` in §4.3. `ResearchSeam.NODE_EFFECTS` already picked 0.14.
- `lisans −%40/−%50` — only `model_optimization`'s −%40 exists.
- `sağlayıcı fiyatı −%15` — no node produces it.
- `marka ×1,25` — no node produces it.
- `düğüm eforları (40 / 50–90 / 60)` — no node has effort 60. The actual set is {40, 50, 70, 80, 90}.
A calibration gate would be testing numbers nothing reads.

### G13 · §5.1's single-research rule is not binding · **LOW**
Free switching with conserved progress and no cost is parallel research at a slower clock. Correct under the recoverable-pressure rule; just not the constraint §5.1 thinks it is.

### G14 · The rail's lock is a compile-time constant · **LOW** · cheap
`UiTokens.TABS` carries `"locked": true` on `rnd` and `LeftTabs._is_locked` reads the const directly; the comment at `ui_tokens.gd:560` still reads *"RELEASE SCOPE: Marketing and R&D are EARLY ACCESS systems"*. §2 needs the lock to lift at v1 ship, so it has to become a state read. The `rail_tabs_match_scene_order` smoke case guards order, not lock state.

---

# Part 3 — How other games do this, and what it says about ours

## What the field does

**RimWorld — research is colonist-time at a bench, and the opportunity cost *is* the mechanic.** The community's standing debate is whether to put a second colonist on research full-time or to make one super-researcher better, and benches are treated as bottlenecks worth power and floor space. This is our closest cousin and it validates §1's core claim. It also shows what we are missing: in RimWorld the researcher is *unambiguously removed* from other work by the job system. Ours is not (G1).

**Software Inc — research is a project staffed by matching-skill designers.** You need three-star designers of the relevant discipline; the start menu tells you exactly how many and of what kind; complexity varies by field; a new tech level appears every January; finishing lets you patent for royalties. Structurally this is our design almost exactly — and Ürün §8.4 already cites Software Inc by name for the fix run. Two differences matter. We drop the annual clock, which is right: it paces research by calendar rather than by play, and our whole module is about play-time. And **Software Inc shows the staffing requirement on the start screen, which is precisely what G11 leaves unwritten in ours.**

**Startup Company — a Researcher role generates research points; points buy feature and component unlocks.** This is the design §1 explicitly forbids, and forbidding it is correct: a point economy turns research into an idle accumulator, decouples it from the assignment decision, and creates the "how do I get more points" question that has no interesting answer.

**Game Dev Tycoon — research points from engines and post-mortems, spent on game tech *and* staff training.** The community complaints are instructive: it is unclear how to earn points, and the two sinks compete opaquely, with reviewers wishing the game-tech and staff tracks had been separated into defined routes. We avoid both problems by having no currency at all.

**Frostpunk 1/2 — workshops, engineers, time, heatstamps.** Two criticisms land directly on us. On FP2: *"most research choices are just tiny trade-offs between stats, with not enough things that really change gameplay rather than just shifting numbers around."* That is §1's ban on "+%5 hız" nodes, arrived at independently — and it is exactly what our Practice family is (G7). On FP1: the tree is *too short*, finished in a few weeks, prompting requests for repeatable techs. Ours is the mirror image: not too short, too long for its slice (G2).

**Anno 1800 — research points from scholars' needs; assigned engineer workforce sets the speed.** We take the assigned-workforce-sets-speed half and reject the points half. Right call on both.

**Civilization / Soren Johnson on the beeline.** The classic tech tree buys clarity and pays in determinism: once players know the path to a technology, veterans make identical choices every game. Johnson's line — *"given the opportunity, players will optimize the fun out of a game"* — and the observation that **Civ 1 answered it by offering only a random subset of available techs**, which Civ 2 onward abandoned. **Surviving Mars** revived that answer at scale: 67 breakthroughs of which only a subset appear per map, plus randomised depth within each field, explicitly for replayability.

## Where ours sits

| Difference from the field | Verdict |
|---|---|
| No research currency at all | **Deliberate improvement.** Startup Company and GDT both show what a currency costs: it decouples research from the decision that makes it interesting. |
| Cost is people-days in a matching skill area | **Deliberate improvement**, and our sharpest fit. RimWorld and Software Inc both do it; neither also makes the *family → area* choice a per-company trade the way §5.4 does. |
| Single active research, no lab, no queue | **Acceptable trade.** Buys §5.1's 30-second visit; loses the lab-building layer, correctly parked to EA (§11). |
| Fixed tree, randomness explicitly rejected (§3) | **Acceptable trade.** Randomness is the field's standard answer to the beeline and it is genuinely effective (Civ 1, Surviving Mars). We buy canon consistency and the no-unwarned-loss rule instead. Worth recording that we are paying for replayability with 20 nodes and a 3–6 budget rather than with a shuffle — and that this only works if the 14 you do not take are interesting, which G7 and G2 both undercut. |
| Fog-of-tree as the anti-beeline device | **Deliberate improvement, with a shelf life.** Staged reveal plus four cross-family conditions is a real third answer and better suited to a narrative game than a shuffle. But the fog is spent after run 1, and the cross-links — the part that would keep working — are the part the demo cannot reach. |
| No patents, no licensing, no rival research | **Acceptable trade.** Software Inc's patent royalties are a second economy; §11 parks it correctly. |
| Required staffing not shown before Start | **Mistake.** Software Inc has shipped the fix for a decade and it is one line of card copy (G11, P3). |
| A coefficient-only family whose coefficients are invisible | **Mistake**, and one our own §1 already legislated against. It is FP2's exact critique, arrived at from the inside. |
| Deterministic: no failure, no random outcome, no penalty | **Deliberate improvement** and non-negotiable under our rules. Worth noting we give up the one thing Surviving Mars gets from randomness — a *different* research story each run — and must therefore get that story from the founder build and the hire order instead. Which, per dimension 6, we actually do. |

---

# Part 4 — Proposals

Each is tagged **cheap** (hours) · **medium** (a day) · **expensive** (more). Nothing here proposes a new system; where a proposal comes close I say so.

### P1 · Make research occupy people — **cheap** · *do this one first*
**Employees:** `HRSystem.job_count(c)` returns `assigned_job_ids.size() + (1 if researching)`. `focus_mult` then applies automatically through `effective_skill`, so Build + research becomes 0,50 / 0,50 with no second change, and `is_overloaded` starts firing so the ×1,5 morale drift lands. Ekip §12.1's two-job cap then correctly refuses a third — add the row to Ar-Ge §7 with its reason line.
**Founder:** starting a research clears the founder's build assignment. The precedent already exists and is one line away: `product_system.gd:386` already excludes the founder from build output while `pitch_prep_active` is set. The build bar then reports *"Kimse üzerinde değil."* in the grammar it already has, and §1's headline sentence becomes true.
**Alternative worth putting to the director:** give the founder the 0,50 split too, so research *slows* the build rather than stopping it. Softer, more recoverable, and arguably better play. §1 asks for the stop. Erdem's call — but the document currently describes the stop and produces neither.
**Player gains:** the module acquires a price. Everything else in this report is downstream of it.

### P2 · Rule on the demo's second half — **cheap as a ruling**, medium if we move content
Three options:
**(a)** Move one cross-family link and one hidden line down to dal level for the demo. §3.1's load-time guard only forbids *visible K3s* on continuation nodes; hidden lines and cross conditions are unconstrained, so this does not break the sealed rule.
**(b)** Loosen the continuation prerequisite for the demo — a devam opens when *either* branch of its family completes.
**(c)** Accept it, write it down, and **cut the demo content bill accordingly**: 8 continuation names, 8 discovery cards and 12 hidden-line tiers become EA work.
**Recommended: (c) plus exactly one hidden line moved to a dal node**, so the mechanic is seen once. It saves the most content money and it is honest about what the demo is.

### P3 · Name the requirement before Start — **cheap**
Add the area and its threshold to the node card next to the day estimate — `Ürün ★2 · ~9 gün · Kurucu` — and put the bare area name on the locked slot (`Tasarım`, next to the `?`). Requires P8's requirement column to exist.
**Closes G4, G5 and G11 at once**, is one card-copy change, and is the thing Software Inc does that we do not.

### P4 · Fix §6's author, then decide whether §6 ships — **cheap**, but it carries a scope decision
Read `HRConstants.can_hold_area(role, "product"|"design")`, not the raw star. Then accept the consequence out loud: the report needs a PM or a designer on payroll, and the reference run hires neither. Put that in `user_research`'s *"Açtığı şey"* line so the player learns it **before** spending 70 effort, not after.
If §6 is kept for the demo, it also needs G8 (paper state) and G9 (save keys). If the demo cut makes it unreachable anyway, the honest move is to defer §6 with §4.5 under P2(c) — it is the single largest chunk of authored content in the document.

### P5 · Give the Practice family something to open, and let the card speak — **cheap**
**Bind one visible K3 to `bug_tracker`.** It is a kök node, so §3.1's guard passes, and the family stops being dominated. One edit to `shared.json` or to one identity line per subtype.
**Let a coefficient node's discovery card name what moved**, in the game's own vocabulary and without a number: *"Artık bildirimleri sıraya girdikleri gün açıyoruz."* The attribution law permits it — the state exists — and §5.8's dry observational register survives intact. Today `cicd` and `test_automation` pay in a currency with no denomination.

### P6 · Rule on the fourth line — **cheap**, but it is a ruling and it should be made before content
Decide whether a hidden line raises its axis ceiling (it does today: +27,6 reading points at the Series A bar, more than any K1→K2 upgrade) or whether `PHASE_BAR` scales with the open line count. Either answer is fine; silence is not, because the number is already live in `realized_axis`. If the answer is "yes, intended", say so in §4.5 and let the discovery card be proud of it — it is the best payoff in the tree.
**And move one of the two Deneyim hidden lines to Kararlılık**, so the deepest research in the game does not deform the triangle whose only reading is its asymmetry.

### P7 · Scope the third bar honestly — **medium**, or free if we cut it
§5.6's "three bars side by side" is a container change in two hosts, one of which is the ODA monitor glass behind a frozen theme and a byte-compared audit gate.
**Cheapest honest version:** the research bar lives in the Ar-Ge tab plus §8's one-line strip plus the rail badge, and does **not** join the floating tracker or the ODA glass in the demo. Write that down as a scope cut rather than discovering it during implementation.
**If it must be in the tracker:** `BuildHUDPanel` is the safer of the two hosts — a VBox at `CARD_W` — and the ODA glass should be left alone.

### P8 · Housekeeping — **cheap**
Add a requirement column to the four §4 tables (area + stars per node, ~20 cells). Resolve §13's 0,14 / 0,12 contradiction in favour of §4.3 (which the code already took). Delete §13's three orphan calibration surfaces (`lisans −%50`, `sağlayıcı fiyatı −%15`, `marka ×1,25`) and correct the effort set to {40, 50, 70, 80, 90}. Add §6's three save keys to §8.5. Add §7 rows for: assigned-but-zero-skill, and third-job refusal. Settle §5.2's people-vs-areas wording. Fix the two stale cross-references to the discovery card: §5.6 (the bar section) points at itself for the completion beat, and §12.1's *"20 keşif kartı (§5.6)"* repeats it — the card lives in §5.8.

### Not proposed, and why
- **A research queue, a lab, parallel research.** §11 parks all three correctly. A queue in particular would undo §5.1's reason for existing.
- **Research points, partial refunds, failure chances, node randomisation.** Each is either forbidden by a standing rule or was considered and rejected in the document with a reason I agree with.
- **An inbound channel from the world into Ar-Ge** — a rival's move or a customer's demand pointing at a node. This is the gap I most want closed (dimension 8) and it is the one proposal that would need a new system, so it is out of scope. Recording it for EA: §6.3's *"Beliren teknoloji"* line is the seam it would attach to.

---

# Part 5 — Noticed, outside this audit's scope, not touched

1. **Every K3 lock line in the Product tab currently prints a raw English id.** `ResearchSeam.name_key` derives `PROD_RND_NODE_<ID>`; `strings.csv` contains **zero** such keys; `node_name()` falls back to the raw id by design. So today a Turkish screen renders `Kilit: Ar-Ge "ai_engine" ✗ → Araştır`. This belongs to the in-flight Ürün package and may already be queued there. Reported, not touched.
2. **`_tick_rnd()` ordering.** Slot 2, after `_tick_product()` (which now also runs `SupportSystem` and `InfraSystem`) and before `_tick_hr()`. A node completing on day N that moves a Support or Infra constant takes effect on day N+1, and research speed on day N reads yesterday's morale. Both are consistent with the tree's existing one-day-lag conventions; noting them so nobody diagnoses them twice.
3. **Save schema timing.** `SCHEMA_VERSION` is already 9 and `MIN_LOADABLE_VERSION` is 9. If Ar-Ge ships in the same package as the Ürün rebuild — as both GDDs say — its keys are free. If it ships later against live v9 saves, it needs a default-on-load path or a bump.
4. **`ui_tokens.gd:560`** still documents R&D as an Early Access system, which contradicts Ar-Ge §2 and Ürün §13. One comment.
5. **Two Ar-Ge rules are already implemented and correct**, which is worth saying so nobody re-does them: §3.1's fairness guard (`product_lines.gd:300-305`) and §12.5's binding shared-line K3 map (`product_lines.gd:234-241`, validated against `ResearchSeam.SHARED_LINE_NODES`).
6. **`erp.json` carries a `shared_gate_overrides` block.** ERP's shared-line K3s keep the binding *node* but change the *star* requirement, which is what Ürün §12.10's ERP telegraph asks for. Consistent with §12.5 as far as I read it; flagging only because the two rules are adjacent and easy to conflate.

---

## Sources

- [Research — Software Inc. Wikia](https://software-inc.fandom.com/wiki/Research) · [Research and Patenting guide (Steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=2932573233)
- [Researcher — Startup Company Wiki](https://startupcompany.fandom.com/wiki/Researcher) · [Getting Started — Startup Company Wiki](https://startupcompany.fandom.com/wiki/Getting_Started)
- [Game Dev Tycoon — research points discussion (Greenheart forum)](https://forum.greenheartgames.com/t/lack-of-research-points/5203) · [Review — sineadaharold.com](https://sineadaharold.com/2014/05/25/game-dev-tycoon/)
- [Technology Tree — Frostpunk Wiki](https://frostpunk.fandom.com/wiki/Technology_Tree) · [Idea Tree — Frostpunk 2](https://frostpunk-2.game-vault.net/wiki/Idea_Tree) · [Expansion of the research tree (Steam discussion)](https://steamcommunity.com/app/323190/discussions/0/1631916406862134163/)
- [Research — RimWorld Wiki](https://rimworldwiki.com/wiki/Research) · [A thought about research (Steam discussion)](https://steamcommunity.com/app/294100/discussions/0/3828665107793128805/)
- [Soren Johnson's designer notes about the tech tree — CivFanatics](https://civfanatics.com/2021/08/18/soren-johnsons-designer-notes-about-the-tech-tree/)
- [Technology Trees: Freedom and Determinism in Historical Strategy Games — Game Studies](https://www.gamestudies.org/1201/articles/tuur_ghys)
- [Breakthrough — Surviving Mars Wiki](https://survivingmars.paradoxwikis.com/Breakthrough) · [Dev Diary 7: For Science! — Haemimont Games](https://www.haemimontgames.com/dev-diary-7-for-science/)
- [Research Institute — Anno 1800 Wiki](https://anno1800.fandom.com/wiki/Research_Institute) · [DevBlog: Scholars and Research — Anno Union](https://www.anno-union.com/devblog-scholars-and-research/)
