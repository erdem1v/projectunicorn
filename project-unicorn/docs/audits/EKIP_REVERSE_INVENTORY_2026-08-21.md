# EKİP MODULE — REVERSE INVENTORY

**Type:** READ-ONLY inventory. Nothing was edited, no git command was run, the game was not launched.
**Tree:** working tree as it stood on **2026-08-22**, audited as it stands. The module is live: 39 comments inside the HR files are dated 2026-08-21 or 2026-08-22, and one retirement (`TATİLE GÖNDER`) landed the morning of the audit.
**Direction:** code → GDD. The previous audit ran GDD → code.
**Sibling reports:** `gdd_conformance/03_ekip.md` (superseded, see §0.2), `EVENT_INVENTORY_2026-08-21.md`, `FRANK_VERIFY_2026-08-21.md`.

---

## §0 · Why this document exists, and what it is worth

The previous Ekip audit asked, of each GDD line, whether the code honoured it. Every finding it could produce was therefore a *shape of a GDD line* — VAR, KISMİ, YOK, ÇELİŞİYOR. A mechanic that lives in the code and that no GDD line points at cannot land in any of those four buckets. It was not missed. It was **structurally outside the count**.

This audit walks the other way. It enumerates what the code does to people, then asks what governs each item. **380 items** were enumerated and given a verdict.

| Verdict | Count | Meaning |
|---|---:|---|
| **UNGOVERNED** | 106 | No GDD line points at this at all |
| **UNGOVERNED · PHANTOM CITATION** | 33 | No GDD line — and the code cites a governing document that does not exist |
| **DIVERGENT** | 77 | A GDD line describes it and the code does something else |
| **GOVERNED** | 155 | A GDD line describes it and the code honours it |
| *Refuted during verification* | 9 | Claims that did not survive a second reader — listed in §7 |

**139 of 380 items — better than one in three — have no design authority behind them.** That is the design agenda, and it is §1.

### §0.1 · Method, and what it cannot tell you

**Read the body, never the name.** Every claim carries a `file:line`. No claim rests on a filename, a function name or a comment. This is not a formality: the module's comments are unusually rich *and stale in places*. `character.gd:80-83` lists `relationship` among the fields "nothing reads"; `event_modal.gd:254-266` reads it. `hr_system.gd:311-315`'s caller comment says HR "applies baseline morale drift"; the drift was deleted, not tuned.

**Adversarial verification.** Every UNGOVERNED and DIVERGENT claim was handed to a second reader whose only job was to refute it — find the governing GDD line, or the caller that makes a "dead" path live. 225 claims were attacked; **9 did not survive** and are reported in §7 rather than quietly dropped. Several survivors came back *stronger* than filed, and where that happened the stronger version is what §1 and §2 report.

**Static reading only** (ruling: Erdem). No `--endgame-smoke`, no `--run-log`, no Godot execution. Every claim of the form "this fires" or "this can never fire" is **reachability argued from source and from a traced caller chain**, not observed behaviour. Where source alone could not settle a question, the report says so instead of guessing. This is the audit's main limitation and it is stated once here rather than hedged in every row.

**A `[WORKING]` tag is not a gap.** In the GDD it means "value not yet balance-passed" — such a line still counts as GOVERNED. In the code it is a design-status marker, not a TODO. This module has no TODO convention at all; searching for one returns nothing and would have produced a false all-clear.

### §0.2 · The previous audit is not merely non-authoritative — it is stale

`gdd_conformance/03_ekip.md` is baselined at `7687095` and states that employees carry three generic axes (`expertise`/`pace`/`rapport`), that no assignment screen exists, that there is no Kişisel page, and that `HRActions.fire` is unreachable. **All four are now false.** The module was rebuilt in three commits — `18d27e3` (engine: three axes → six areas plus job assignment), `9908a8b` (Ekip · Kişisel · hiring UI), `fe2e439` (fixes, eight traits). Its §8 "open questions for the director" are largely answered by that rebuild.

Nothing in this report is sourced from it.

**And it contains a live instance of the exact failure this audit was commissioned to catch.** Yesterday's sibling report, `EVENT_INVENTORY_2026-08-21.md:924`, lists "the 1.6x `OVERLOAD_MORALE_MULT`" among the morale sinks a player must use to drive someone under 25. A whole-repo grep for `OVERLOAD_MORALE_MULT` returns **exactly one line — its own declaration** at `hr_constants.gd:146`. It has never had a reader. A named constant was read as a mechanic.

### §0.3 · The governing corpus, and a hole in it

Primary: **ch.02 · Founder & People Model**, **ch.07 · Team & Roles (HR) rev 2**.
Secondary, each of which legislates people: ch.01 §5, ch.03 §2/§8, ch.04 §2, ch.06 §1.2–1.3, ch.08 §1/§4, ch.10 §3, ch.11 §3/§5, ch.12 §4/§8, ch.14 §7.

Three chapters legislate the same people differently. That is §3.

And the corpus has a hole that shapes everything below it: **64 comments across 11 source files cite a "design doc" that is not in the repository.** §1.0 is about that.

---

## §1 · UNGOVERNED — the design agenda

Ordered by how much each affects play. Every entry states what it does, what it currently costs the player, and **what would break if it were removed** — because some of these are load-bearing and some are debris, and the name does not tell you which.

The full 139 are in the appendices. This section carries the ones that decide how a run plays.

### §1.0 · The framing finding: a governing document that does not exist

`grep -rn "design doc" --include=*.gd scripts/` returns **64 hits across 11 files**. Four of them name it outright — "**HR design doc**" at `character.gd:48` (§6), `hr_candidate_generator.gd:4` (§3), `hr_overtime_system.gd:4` (§7b), `hr_search_system.gd:4` (§2/§3). The other 60 say "design doc" alone.

Cited sections run **§1, §2, §3, §4, §5, §6, §7, §7b, §8, §12, §12.3, §12.8**.

They are one document, and this is checkable rather than assumed: **§8 means leave-and-capacity in five separate files** — `hr_morale_system.gd:104` and `:375` (nobody is asked to approve leave), `character_registry.gd:414` (the salary pull is deliberately not status-filtered, because leave is paid), `b2b_sales_system.gd:95` ("capacity/CS contribution stops"), `product_system.gd:239` (capacity). Section numbers that carry consistent meaning across five files are not five authors coining the same label.

**There is no such document under `docs/`.** `docs/.md` — the hidden filename — is the Event Pool Design. Ruling taken (Erdem): treat it as phantom.

This is not a documentation complaint. It decides what is designed:

- **`RAISE_MAX_PCT := 15` is marked `# üst sınır — ONAYLI (design doc §12.3)`** (`hr_constants.gd:1004`). An approval is recorded against a document nobody can open. The raise band is the single number that decides whether a raise is a real cost, and its authority is unverifiable.
- The **entire overtime system** — blocks, pay rate, speed bonus, bug penalty, morale tiers, the safety valve — cites §7b and nothing else.
- The **entire annual-leave system** cites §8 and nothing else; the word `izin`/`leave`/`tatil` appears in no GDD chapter about employees at all.
- The **candidate generator**, including the non-dominance invariant that makes the three Atlas files a real choice, cites §3.

Everything in §1.1 marked **PHANTOM** is in this class. It is a distinct condition from "nobody wrote this down": the code believes someone did.

### §1.1 · The undesigned mechanics that move a run

---

#### U1 · Ek mesai — the entire overtime system · **PHANTOM (§7b)**

The largest unlegislated surface in the module: a repeatable purchase of speed, priced in cash, morale and bugs.

**What it does.** Department-wide blocks of 3, 7 or 14 days (`OVERTIME_BLOCKS`, `hr_constants.gd:1030`), started from a department header. While a block runs, that department's work speeds up by **+30%** falling to **+15%** from day 8 (`OVERTIME_SPEED_BONUS_EARLY/LATE`, `:1034-1036`), and in `product_dev` the bug rate is multiplied by **1.25** (`OVERTIME_BUG_MULT`, `:1037`). Consumed hourly on the build (`product_system.gd:718`, `:977`) and daily by the two other desks — `sales_rep_system.gd:91-95` and `customer_rep_system.gd:92`. **The payoff surface is three desks wide, not one.**

**What it costs.** Per participant per night: **40% of a daily wage** (`OVERTIME_PAY_PCT 0.40`, `:1040`), accrued to a static that Finance pulls two slots later into its own `overtime` burn line (`finance_system.gd:143`). Morale: **−2** through day 3, **−4** through day 7, **−7** thereafter, cumulative, scaled by trait and by the founder's Liderlik climate. The founder joins `product_dev` nights, is never paid and takes no morale hit — but a **solo** founder cannot start a block at all, because `can_start` requires a non-empty participant list and says why: *"for product_dev it would let a solo founder buy speed with nothing but bug risk"* (`hr_overtime_system.gd:149-159`).

**What breaks if removed.** Load-bearing on both sides. It is the module's only speed-for-morale trade, the only cost-bearing use of the `DEPARTMENTS` table, the only feeder of the flight-risk chain in a demo-length run, and the sole reason the valve event family exists.

**The only GDD word on overtime anywhere** is ch.07 §7's morale-input list — *"Girdiler: fazla mesai · aşırı yüklenme · …"* — which presupposes overtime exists and legislates nothing about it. No blocks, no lengths, no pay rate, no speed gain, no bug penalty, no scope, no valve.

---

#### U2 · The overtime safety valve, and the permanent invisible penalty behind it · **PHANTOM (§7b)**

**What it does.** When a participant drops under the flight-risk line mid-block, a modal fires — once per person per block — offering *"Mesaiyi durdur"* or *"Devam et"* (`hr_overtime_system.gd:355-377`). It is the only automatic HR modal a normal run reliably produces.

**What it costs.** *Durdur* forfeits the remaining speed bonus. *Devam et* writes a **run-long, per-person flag** (`hr_overtime_system.gd:380-398`) that adds `RESIGN_VALVE_PENALTY 0.15` to that person's daily resignation roll — raising it from 0.25 to 0.40, a **60% relative increase, for the rest of the run**. The scope is deliberate and documented: *"the block ending does not unsay it"* (`:386-391`).

**Nothing on any screen ever shows the flag again, and no action clears it.** Not a raise, not training, not leave. `HROvertimeSystem.reset` touches only the three pay statics.

**What breaks if removed.** *Devam et* becomes a free option — a modal presenting a costless upside, which is exactly what ch.11 §4's cost law forbids. The valve would still fire and still stop the block on the other branch.

ch.11 §5's list of legal trigger edges — churn, phase change, incident, raise demand, rival move, version ship, coverage red, promise broken — contains nothing like this.

---

#### U3 · Yıllık izin — automatic annual leave · **PHANTOM (§8)**

**The entire annual-leave subsystem is absent from the GDD.** A grep of all thirteen chapters for `izin` / `tatil` / `leave` / `vacation` returns one line, and it is ch.10's "a named account leaves".

**What it does.** A leave month is stamped on every hire from a coprime stride so consecutive hires spread across ten different months (`character_registry.gd:455-457` → `hr_constants.gd:979-989`). When that month arrives the employee goes on **7 days of paid leave with no player approval** (`hr_morale_system.gd:113-121`). Capacity, speed, CS contribution and overtime eligibility all stop; salary does not, because `get_total_monthly_salaries()` is deliberately not status-filtered (`character_registry.gd:412-421`).

**What it costs.** Full salary for seven days of zero output, in a demo whose entire pressure is capacity. A ticker line announces it (`HR_NEWS_ON_LEAVE_MONTH`); nothing ever warns in advance, and nothing anywhere tells the player when a given person's leave month falls — the one function that could say it, `HRConstants.leave_month_label`, **has no caller** since `preview_vacation` was retired.

**What breaks if removed.** `MORALE_LEAVE_RETURN +10` disappears, and `hr_constants.gd:758-760` names it as one of only **three** morale recovery channels in a system with no self-healing. Given the state of the other two (§2, D5/D6), removing leave would leave the player's wallet as very nearly the only way morale ever goes up.

---

#### U4 · Severance, and the whole player-initiated firing

**What it does.** `İşten çıkar` on the row menu removes an employee immediately and pays **one month's salary per full year served, minimum one month** (`SEVERANCE_MIN_MONTHS 1`, `DAYS_PER_YEAR 365`, `hr_constants.gd:1005-1024`), plus **−5 morale to every remaining employee** (`MORALE_FIRE_TEAM`).

**Where the GDD stands.** ch.08 §6 licenses letting someone go and ch.08 §1 enumerates one-off costs — *"Atlas retainer, eğitim, lisans, kesinti telafisi"*. **Severance is not among them.** ch.07 §9 covers departures exclusively as *events* — resignation, poaching — and never as a player verb. The firing exists; its price does not.

**What breaks if removed.** The player loses the only way to reduce headcount by choice. Everything else that removes a person is engine-driven.

---

#### U5 · The Atlas hire commission — a second fee nobody legislated · **PHANTOM (§2)**

**What it does.** `SEARCH_COMMISSION_PCT := 0.15` (`hr_constants.gd:711`) charges **15% of the first month's salary** on a completed hire, on top of the non-refundable `SEARCH_RETAINER 600`.

**Where the GDD stands.** ch.07 §6 legislates exactly one payment: *"Atlas ajansına retainer ödenir → 2–4 gün sonra 3 aday."* ch.08 §1's one-off list names the retainer and not a commission. On a $6,300 developer the commission is **$945** — larger than the retainer, and invisible in both chapters.

**What breaks if removed.** Hiring gets meaningfully cheaper at the top of the salary band, and the band's own pressure — pay more, get more — loses the multiplier that makes an expensive hire expensive twice.

---

#### U6 · The two-ceiling training split

**What it does.** Paid training stops at `AREA_TRAIN_CAP 8` — four stars — while learning by doing reaches `AREA_MAX 10`, five stars (`hr_constants.gd:815`, `:54`). The gap is deliberate and the comment says so: *"para her şeyi satın alamaz."*

**Where the GDD stands.** ch.07 §8 legislates training's price shape, its two-week length and its diminishing returns — all GOVERNED and all honoured. It says nothing about a ceiling, and nothing about the fifth star being unpurchasable. This is the module's sharpest economic statement about money and it was never put to a director.

**What breaks if removed.** The one thing cash cannot buy in this module becomes buyable, and hiring a top-band candidate loses its only structural advantage over training a cheap one.

---

#### U7 · The action menu is the only door — and it has a dead zone on the two chips players click most · **PHANTOM (§7)**

**What it does.** One left-click anywhere on a ledger row opens a popover carrying **Zam · Eğitim · İşten çıkar**. `hr_actions.gd:4` cites the phantom doc for the menu's very existence: *"The three employee-card actions (design doc §7)"* — one of which has since been retired.

**The defect.** `_placement_badge` sets the **BOŞTA** and **AŞIRI YÜK** chips to `MOUSE_FILTER_STOP` (`hr_ledger.gd:221`, `:227`), and `_pass_clicks_through` exempts any tooltip-carrying child (`:171-172`). A click landing on either chip is swallowed and **the menu does not open**. These are the two chips that tell the player this person needs attention. The convention being broken is written down one file away and obeyed there for the trait icon: *"PASS, STOP DEĞİL: STOP tooltip'i çalıştırır ama satır tıklamasını YUTAR"* (`hr_ui_shared.gd:135-143`).

**What breaks if removed.** Three of the module's five player actions become unreachable. The header EĞİTİM button is not a substitute — it opens on `eligible[0]` without asking who (§6, O4).

ch.07 §3 and ch.02 §3 describe a closed row and an open card. Neither describes an action menu.

---

#### U8 · Ordering as unwritten law: HR is slot 3, and it decides which governed events exist

**What it does.** `_dispatch_daily_tick` runs thirteen slots in a fixed order — product(1) → rnd(2) → **HR(3)** → sales(4) → rivals → finance → … (`time_manager.gd:249-268`). Inside HR, nine steps run in a fixed order of their own (`hr_system.gd:34-73`). At the day boundary, `_dispatch_hourly_tick(0)` fires **before** `advance_day()` (`time_manager.gd:138-144`).

No chapter legislates any of it, and it is not the kind of thing a chapter should. It is here because **this ordering is currently deciding which governed features exist.** HR at slot 3 can never observe anything the player resolved in a modal that day, and can never observe an account signed at slot 4. That is the entire mechanism behind D5 and D6 below — two of the three morale-recovery beats the GDD asks for are dead for no reason other than dispatch position.

**What breaks if removed.** There is no HR day at all: no leave, no overtime billing, no experience, no resignation clock.

---

#### U9 · Four HR system fields, and one HR skill seam, live outside the module

`hr_search`, `hr_overtime`, `hr_last_overtime_day` and `hr_last_positive_event_day` are declared on `GameState` (`game_state.gd:293-298`) under a stated "fields not systems" rule that buys free save coverage — `SaveCodec` discovers every script variable rather than reading a whitelist. `HRSearchSystem` holds **no statics at all**; its entire state machine is one of those dictionaries. Separately, `GameState.get_founder_skill` is the single door to every founder number in the game, carrying the only tripwire that screams when a renamed skill key would otherwise silently read 0 — and **two in-scope readers bypass it**: `product_system.gd:791` and `personal_tab.gd:183,188`.

Ungoverned, correctly — no chapter should legislate storage. Recorded because deleting either would remove hiring, overtime and every founder roll in the run.

---

### §1.2 · The rest

The remaining 130 ungoverned items are in the appendices with the same three questions answered for each. They fall into four groups:

- **Undesigned state** (28 rows, Appendix B) — including four fields nothing reads: `loyalty`, `trust_score`, `attention_flag` and `equity_pct` on employees. `attention_flag` is the interesting one: it is declared *and deliberately never written*, because one String cannot hold two simultaneous badges, so badges are derived instead (`hr_morale_system.gd:261-279`). Reserved and dead look identical from outside, which is why they are all listed.
- **Ungoverned numbers** (109 rows, Appendix D) — every constant governing people. No chapter names a constant, so "ungoverned" here is expected and mostly harmless; the rows that matter are flagged **PHANTOM** or carry a duplicate-value flag.
- **Infrastructure** (save/load, RNG, run reset, signal plumbing) — ungoverned because no chapter should govern it. Listed for completeness, not as an agenda.
- **Absent seams** — these are §4.

### §1.3 · Values with more than one home

Pass 1d was asked to flag any value that appears in more than one place. Five did, and two of them can produce a lie.

**Duplicates with teeth:**

- **`TRAINING_DAYS := 14` and the string `"iki hafta" / "two weeks"`.** The training modal prints its duration from the fixed copy key `HR_TRAINING_DURATION_WEEKS` (`strings.csv:356`), used at `training_modal.gd:147` and `:206`, with **no computed fallback**. Retune `TRAINING_DAYS` and the modal keeps saying "two weeks" in both languages while the engine does something else. The overtime block labels do not have this problem — they fall back to a computed day count — so the module already knows the right pattern and does not use it here.
- **`MORALE_MIN 0` / `MORALE_MAX 100` and the write clamp's bare literals.** The constants are declared with the comment *"Bounds mirror `CharacterRegistry.set_morale`'s clamp"* (`hr_constants.gd:762-764`) and are read by `scaled_delta` and the morale bar. The actual write does `clampi(value, 0, 100)` with literals (`character_registry.gd:598`), and its own comment calls that a *"Placeholder clamp range"*. The preview promises against one home and the write enforces another; they agree today by coincidence.

**Duplicates that are only hygiene:**

- **`HRLedger.DENSE_BELOW 1600` / `TopBar.COMPACT_BELOW 1600` / `DisplaySettings`' prose "eşik 1600"** — three homes for one breakpoint. The HR comment admits it: *"mantıksal genişlik eşiği (top_bar ile aynı sayı)"*.
- **The founder's one-area lock is the bare literal `1`, enforced twice** and named nowhere — `assign_area` refuses with `"founder_busy"` (`character_registry.gd:221-223`) and `_validate_shape` `push_error`s at `size() > 1` (`:507-509`). The asymmetry against employees is correct and governed (ch.07 §4 permits multiple areas, §5 prices them), so what is missing is a name, not a rule.
- **Seven id arrays re-type as string literals the constants declared immediately above them**, all inside `hr_constants.gd`: `AREAS`, `EMPLOYEE_SKILL_KEYS`, `ASSIGNABLE`, `EMPLOYEE_ROLES`, `DEPARTMENTS`, `ROSTER_GROUPS`, `BANDS`.
---

## §2 · DIVERGENT — a GDD line describes it and the code does something else

77 rows survived verification. Ordered by how much each affects play. Full set in the appendices.

---

### D1 · Aşırı yüklenme never costs a single morale point — and both languages promise that it does

**GDD ch.07 §5:** *"Aşırı yük kısa süre tolere edilir, uzun sürerse **moral düşer** ve kaçma riskine gider."* The chapter goes further and dictates the hover copy: *"verimi düşer ve **morali normalden hızlı erir**."* §7 lists *aşırı yüklenme* as the second of five morale inputs.

**Code:** overload moves output and nothing else. `tick_overload` counts consecutive multi-area days (`hr_system.gd:224-232`); `overload_bites` trips after `OVERLOAD_TOLERANCE_DAYS 5` and gates `OVERLOAD_OUTPUT_MULT 0.75` (`:153-156`, `:245-246`). `HRConstants.OVERLOAD_MORALE_MULT := 1.6` — documented in place as *"multiplier on NEGATIVE morale deltas"* — **has exactly one occurrence in the entire repository: its own declaration** at `hr_constants.gd:146`. `scaled_delta`, the single morale scaler, folds in the team-decay trait and the founder's Liderlik climate and never asks about `overload_days` or `assigned_jobs.size()`.

So §5's chain — *overload → morale falls → flight risk* — is severed at the first link. Carrying two areas forever is a flat 25% output haircut with no path to a resignation.

**And the player is told otherwise, in both shipped languages.** `strings.csv:380`:

> `HR_OVERLOAD_HINT` — *"Birden fazla işte çalışıyor: verimi düşer ve morali normalden hızlı erir."* / *"Working more than one job: output drops and morale erodes faster than normal."*

Shown from two surfaces (`hr_ledger.gd:220`, `hr_assignments.gd:122`). The first clause is true. The second has never been true. `overload_bites`'s own docstring quotes §5's *"moral düşer"* directly above a function that gates output.

*Six independent rows in this audit reached this conclusion; one un-attacked GOVERNED row asserted the opposite and is wrong — see §7.*

---

### D2 · Low morale never lowers output — the three-stage ladder starts at stage two

**GDD ch.07 §7:** *"**Düşük moral çıktıyı düşürür**, sonra kaçma riski rozetine, sonra istifaya gider."*

**Code:** no production output formula reads `Character.morale`. `ProductSystem._phase_area_sum` multiplies `role_stats × output_mult_for_area × two traits` (`product_system.gd:509-537`); `SalesRepSystem._diminished_sum` (`:64-81`) and `CustomerRepSystem.throughput_of` (`:74-92`) do the same on their side. An exhaustive scan of `.morale` reads outside `hr_morale_system` finds only writes, clamps, previews, repaint hooks and the flight-risk threshold.

Morale's only mechanical consequence in the entire game is crossing 25 and feeding the resignation roll. The first rung of the governed ladder is missing, which means morale is currently a countdown to one binary event rather than a performance curve.

**Taken with D1 this is the module's central defect:** the GDD's two named consequences of unhappiness — slower work, faster erosion under load — are both absent, so the morale system reads as instrumentation for a single quit-or-not roll.

---

### D3 · The team lead cannot be appointed — the branch that would let the player choose is unreachable

**GDD ch.07 §2:** *"Liderlik: ekip lideri **atanan çalışanın** altındaki ekibin verimlilik modifier'ını, moral düşüş hızını ve deneyim kazanım hızını etkiler."* **§9:** *"Ekip lideri istifa etti, **yerine kim geçiyor?**"*

**Code:** `HRSystem.area_lead()` (`hr_system.gd:187-205`) is documented as *"Açık seçim kazanır; yoksa o alandaki en yüksek Liderlik; hiç kimse yoksa kurucu"* — explicit choice wins, else highest Liderlik, else the founder. The explicit choice reads `GameState.area_leads`. **Nothing in production code ever writes an entry into that dictionary.** Every touch in the repo is a removal or a reset: `release_area_leads()` erases (`game_state.gd:600-608`), `.clear()` on run start (`:803`), `CharacterRegistry.remove` calls the eraser (`character_registry.gd:546`), and a v4→v5 save migration rebuilds it from a retired `job_leads` key that itself has no live writer (`save_manager.gd:810`).

In every fresh run the first branch is dead and leadership is **entirely automatic**. No UI control anywhere sets it. The code now states the omission as policy — `game_state.gd:252-253`: *"SEÇİM SEAM'İ YOK ve bu bilinçli: onaylı tasarımda lider seçme arayüzü çizilmemiş."*

This is the collision class the brief named: one function, a comment promising a player choice, and a branch that cannot be entered. It also makes §9's successor question structurally unanswerable — there is no seat to fill.

*Hazard worth noting:* `SaveCodec` captures `GameState` variables generically, so a migrated legacy save can carry lead seats a fresh run cannot create.

---

### D4 · Liderlik has four readers and they read three different people

One GDD sentence (ch.07 §2, quoted in D3) gives **one** lead three effects: efficiency, morale-drop rate, and experience rate. The code has three different sources:

| Effect | Whose Liderlik is read | Where |
|---|---|---|
| Morale climate (drop *and* gain scaling) | **the founder**, always | `hr_morale_system.gd:243`, applied `:248-250` |
| Experience gain rate | the **derived area lead** | `hr_system.gd:102` |
| Mentor trait bonus (`lead_experience_mult`) | the **derived area lead**, per area | `hr_system.gd:116-118` |
| Build coordination | the **build lead picked in the creation flow**, falling back to the founder | `product_system.gd:495-506` |

The effect the GDD is most explicit about — *"moral düşüş hızını"* — is the one that does not read a lead at all. And "lead" means at least three distinct things in this codebase: the unappointable per-area lead (D3), the per-build `lead_engineer_id`, and the founder as implicit climate leader. `lead_engineer_id` is additionally documented as **stale**: *"commit'ten sonra lead_engineer_id'yi kimse yeniden yazmıyor, yani sorumlu işten çıkarılmış ya da izne çıkmış olabilir"* (`product_system.gd:490-493`).

---

### D5 & D6 · Two of the three morale-recovery beats can never fire, for no reason but dispatch position

**GDD ch.07 §7** names *"başarı ve başarısızlık anları (**sürüm çıktı**, hesap kaybedildi, kesinti)"* among morale inputs.

Both beats are fully written and wired. Neither can happen.

- **Ship glow** (+6 to every employee) requires `days_since_last_ship() == 0` (`hr_morale_system.gd:189-192`, `:307-314`). `mvp_version_history` is appended only by `ProductSystem.ship_active_build`, whose only production caller is the ship-moment modal's own modifier (`event_manager.gd:666-667`) — a mid-day player click. HR's tick runs at the day boundary, after `advance_day()`, so the stamp is always at least one day old. **No slot position could fix this one**; the write happens between ticks.
- **Big signing** (+4 to everyone, for an account at or above `BIG_SIGNING_MRR 1500`) requires `acquired_on_day == GameState.day` (`:538-551`). Accounts are created either mid-day by a played pitch or by `SalesRepSystem` at **slot 4** — one slot *after* HR's slot 3 (`time_manager.gd:256-262`). The equality is never true when the check runs.

The asymmetry is provable inside one function: `days_since_last_ship()` *can* return a fresh number because `ProductSystem` is slot 1, one slot before HR — the trigger just asks for a value that a modal writes later. One line of `tick_positive_events` is alive; the next two are dead.

**What this leaves.** Morale never self-heals by design (`hr_system.gd:15-21`; the drift was deleted, not tuned). The recovery channels the code names are *"aksiyonlar + izin + pozitif moral event'leri"*. Of the three positive events only **calm stretch** survives — 21 days with no overtime and team morale under 70, at most once per fortnight. So in practice the entire upward channel is: the calm stretch, a leave return (U3, ungoverned), and the player's wallet.

---

### D7 · A departure vacates the work, never asks who takes it — and hands the accounts to the founder, which §9 forbids by name

**GDD ch.07 §9:** *"Ayrılan kişinin işleri boşalır ve oyuncuya sorulur: 'Melisa gitti, müşterilerine kim bakacak?' … Kart oyuncuyu ilgili sayfaya yönlendirir. **Otomatik kurucuya devir varsayılan değildir.**"*

**Code:** `CharacterRegistry.remove` does clear `assigned_jobs` and release lead seats (`:530-548`), so the work is genuinely vacated. But `HREventFactory.build_resignation` ships a **single acknowledgement choice** with one `hr_departure` modifier (`hr_event_factory.gd:29-42`) — no question, no successor pick, no routing to Satış or Ekip.

And the account half is answered automatically, in the direction the chapter explicitly rules out. `CustomerRepSystem._release_unheld` (`customer_rep_system.gd:120-129`) walks every B2B account and, where the owner is gone or inactive, executes `CustomerRegistry.assign_customer(c.id, "")` — **the leaver's whole book falls to the founder on the next daily tick**, with the pin destroyed alongside it (*"A pin does NOT survive its rep leaving"*). `_delegate_excess` may then redistribute some of it a night later. The player is never asked the question the chapter writes out verbatim, and the engine answers it twice, silently, beginning with the forbidden default.

---

### D8 · The founder energy bar does not exist, and three approved chapters still require it

**ch.02 §6** legislates it in full — one bar, falls with overtime and long solo stretches, rises with rest and delegation, low energy gives a temporary skill penalty and triggers events, reads in Kişisel and as a TopBar/ODA badge. **ch.02 §10** lists *"Energy bar (§6)"* among Kişisel's contents. **ch.12 §8** lists *"Kişisel → founder card, energy, net worth, events log"*.

**Code:** no `energy` field, no system, no UI, no threshold vocabulary. A repo-wide grep for `energy`/`enerji` hits only 3D lighting. `HRMoraleSystem.apply_delta` returns immediately for any `category != "employee"` and says why — *"founder burnout is out of demo scope"* (`hr_morale_system.gd:211-218`) — so the founder has no morale channel either; the `morale = 50` written onto him at `game_state.gd:952` is inert. `HROvertimeSystem.participants()` structurally excludes him, so overtime costs him nothing.

**This is not superseded law.** ch.07 rev 2 is *silent* on founder energy, and silence is not repeal; §10 hands Personal back to ch.02. The exact seam it would attach to already exists and is a pure read with nothing on the other end: `founder_participates()` (`hr_overtime_system.gd:300-305`) has **zero production readers**.

---

### D9 · The raise is a proactive purchase, not the reactive negotiation §9 describes

**GDD ch.07 §9:** *"**Zam talebi event'i**: bir yılını dolduran ya da seviye atlayan çalışan açar; talep medyanın üstünde olabilir. Karar slider ile **karşı teklif**; **düşük teklif moral düşürür ve kaçma riskini artırır**."*

**Code:** the raise is player-initiated, unconditional and one-way. Row menu → slider 3–15% → `HRActions.apply_raise`. `can_raise` refuses only non-staff, zero salary, or a rounding no-op — **no cooldown, no per-year gate, unboundedly repeatable**. The only morale outcome is a **gain**, lerped +4 to +16, and it is multiplied by the founder's Liderlik climate, so a high-Liderlik founder buys more morale per dollar.

There is no demand event, no median, no counter-offer, and no low-offer penalty. A repo-wide grep for `raise_demand|zam talebi|counter_offer|poach|rakip teklif` across `.gd/.json/.csv/.tscn` returns two trait-copy strings and nothing else.

What ships is an always-available, repeatable morale purchase priced in future burn. The designed downside half is absent. This is the same shape that got `TATİLE GÖNDER` retired ten lines below it in the same file (`hr_actions.gd:118-128`); the raise survived that sweep.

---

### D10 · "AŞIRI YÜKLÜ" is two different conditions, and in English they are the same word

**GDD ch.07 §5** defines the overload badge by multi-area assignment. ch.12 §4's badge list contains no engineer-shortage badge.

**Code:** there are two chips.

- The governed one, `HR_BADGE_OVERLOADED_JOBS`, derives from `HRSystem.is_overloaded` — genuinely `assigned_jobs.size() > 1` (`hr_ledger.gd:217-218`).
- The one that feeds `attention_count` and lights the left-rail badge, `BADGE_OVERLOADED`, derives from `is_capacity_overloaded()` — which is `GameState.get_flag("needs_engineer")` and **never touches `assigned_jobs`** (`hr_morale_system.gd:271-279`, `:328-334`). It is a company-wide signal rendered as a per-person badge, handed to every `product_dev` employee at once.

That flag is set by three bug-sprints in a 20-day window and cleared by exactly one thing: hiring a `role_developer` (`hr_search_system.gd:224-228`). Hire a tester, a PM or a designer and every product-development employee wears a red attention badge indefinitely.

`strings.csv:378` and `:550` render the two as **"OVERLOADED"** and **"Overloaded"**. An English player has no way to tell which badge they are reading.

---

### D11 · A phase change while the founder is in training leaves him permanently unassigned

Two separately governed features collide and produce a state the model has no name for: a founder holding **zero** jobs, with no player-side cure.

`ProductSystem._reseat_founder` calls `clear_areas` then `assign_area` (`product_system.gd:405-419`). `clear_areas` has no status check (`character_registry.gd:244-252`); `assign_area` refuses with `"inactive"` for any status other than `STATUS_ACTIVE` (`:221`). Send the founder to training — itself governed, ch.07 §3, and the button is right there on Kişisel (`personal_tab.gd:284-289`) — then let the build advance a phase. His area is wiped, the re-seat `push_error`s, and nothing reassigns him: not training completion (`character_registry.gd:185-198` sets status and stops), not the Görevler matrix, which iterates `get_employees()` and has no founder row and says so — *"KURUCU BURADA YOK … oyuncunun onu taşıyacağı bir kapı yok"*.

He then contributes no build speed and, since the 2026-08-22 change that made the founder a learner skips anyone with empty `assigned_jobs` (`hr_system.gd:101-102`), **accrues no experience either** — while the Kişisel card draws him an experience bar. The only cure is the next phase transition.

---

### D12 · The sales desk closes small deals with no played moment

**GDD ch.04 §2:** *"Pitch flow (existing PitchSystem) is the close moment; **KEEP**."* **ch.01 §9:** *"Every economic outcome comes from a played decision moment."*

The desk's *existence* is governed — ch.07 §4's job table reads *"Satış | Satış | lead işleme, **kapanış**"*, so closing is an authorised effect of staffing the Satış area. What diverges is that anything whose band ceiling is at or under `AUTONOMOUS_CLOSE_MRR_MAX 600`, and whose pain maps to a shipped feature, is closed by the desk itself with **no pitch played** (`sales_rep_system.gd:167-209`). Everything above 600 correctly warms for the founder instead.

*Far side not audited — the pipeline and band economics belong to ch.04.*

---

### D13 · The CS desk is gated by job title and worked by area

ch.07 §2's whole thesis is that work is gated by **area**, never by role name — *"Alan adları rol adı değildir … QA yoksa mühendis test edebilir."*

`CustomerRepSystem` gates the entire desk on `count_active_by_role(ROLE_CUSTOMER_REP) == 0` (`:42-57`, `:101-103`) while every worker lookup underneath reads `HRSystem.assigned_to(AREA_CUSTOMER_SUCCESS)`. Two failure directions, both confirmed in the bodies:

- **Gate open, desk empty.** Move the customer_rep off the CS area and requests keep opening on the 22-day cadence with zero throughput. `_escalate` returns on an empty rep list **before** clearing the latch (`:310-315`), so every account accumulates one permanently-open request that will never be re-stamped or cleared — and re-seating anyone later releases the whole backlog at once, throttled only by the weekly cap.
- **Gate shut, worker available.** A `sales_rep` legally assigned to `customer_success` (their secondary area under `ROLE_AREAS`) would work the desk, but with no `customer_rep` on payroll the gate shuts it.

---

### D14 · Training offers an employee three areas out of seven, and the chapter grants all of them

**GDD ch.07 §8:** *"Oyuncu **hangi alanın** yükseleceğini seçer."* No restriction. ch.07 §2 sells the whole area model on cross-cover — *"QA yoksa mühendis test edebilir, tasarımcı yoksa PM tasarıma bakabilir."*

**Code:** the engine agrees with the chapter — `trainable_keys()` returns all seven (six areas plus Liderlik, Karizma excluded), and both engine gates were opened on 2026-08-22 so the founder became trainable and Liderlik became trainable (`character_registry.gd:131-137`). **The modal narrows it.** `TrainingModal._rows_for` gives the **founder all seven** and an **employee only three** — key area, secondary area, Liderlik (`training_modal.gd:160-167`).

So a developer can never be trained toward Satış or Müşteri Başarısı. The player cannot buy the cross-cover that §2 offers as the reason the area model exists; they can only get it by hiring. The narrowing is deliberate and cites the approved screen (*"11c birebir"*), which makes this a conflict between an approved chapter and an approved mockup rather than an oversight.

---

## §3 · CHAPTER CONFLICT — where the GDD disagrees with itself

Not code verdicts. These are places where two approved chapters legislate the same thing differently, so no implementation can satisfy both. Listed because an auditor must not silently retire a GDD line.

**C1 · The skill model.** ch.02 §2 (approved 2026-08-20): six skills — Geliştirme · Tasarım · Satış · Müşteri Başarısı · **Pazarlama** · **Operasyon** — plus meta **Hız**; seven numbers per person. ch.07 rev 2 §2 (approved 2026-08-21, marked *"Supersedes rev 1"*): six **areas** — Ürün · Tasarım · Yazılım · **Test** · Satış · Müşteri Başarısı — plus **Liderlik**, founder also Karizma, and explicitly *"Hız (pace) skill'i kaldırıldı."* The code follows ch.07 and cites it by name (`character.gd:56-59`). **Ruling applied in this report: ch.07 is operative; ch.02 §2 and the §3 display rule built on it are stale and need a rewrite.**

**C2 · ch.06 still computes with a deleted skill.** ch.06 §1.2's support-capacity formula is *"capacity = throughput × assigned_heads × Müşteri Başarısı × **Hız**"* — a skill ch.07 removed the day after ch.06 was approved.

**C3 · ch.01 still charges a removed cost.** ch.01 §5 lists Bootstrap pressure as *"founder time … + cash (**living costs** + first salaries before revenue)"*. ch.02 §1 and ch.08 §1 both remove living costs outright.

**C4 · The interview.** ch.02 §9 wants a reveal step costing founder time. ch.07 §6 says *"Mülakat yok."* The code has none, so it satisfies ch.07.

**C5 · Trait count per employee.** ch.07 §6's candidate card carries *"1–2 trait"*. The code settled on exactly one on 2026-08-22, deliberately, and allows that one to be purely negative (`hr_constants.gd:538-549`).

**C6 · Founder trait status.** ch.07 §12 still lists *"Kurucu trait'leri bugün çalışmıyor (kod kurucu trait'ini çalışan tablosunda arıyor)"* as an open item. That bug was closed on 2026-08-21 (`product_system.gd:498-501`). The chapter's own open-items list is behind the code.

**C7 · The founder's third job.** ch.02 §5 gives the founder three jobs — building, selling, fundraising. Building and selling are real `ASSIGNABLE` ids; fundraising has no id anywhere, so the Hunt is outside the assignment model that ch.07 §4 defers to §5 for.

---

## §4 · Part 3a — Seams

*Does this module lack a field, signal or hook another module needs to talk to it properly?*

**Yes, and one absence dominates: the event engine cannot see people.**

### S1 · The event engine has no HR condition, and structurally cannot have one

`EventManager.is_condition_met` implements **29 condition types** (`event_manager.gd:368-457`). **Exactly one touches a person** — `founder_skill_min` — and it reads the founder only. There is no condition for morale, headcount, employee skill, status, idle, overload, tenure, training or overtime.

The reason is deeper than a missing key: **`EventManager` subscribes to zero `EventBus` signals.** It appears in the file only as an emitter, at seven sites. Every condition is a *pull*, evaluated at daily/hourly eligibility time. So `morale_changed`, `employee_experience_changed`, `assignment_changed`, `character_added`, `character_removed` and `hr_day_processed` all exist, all fire, and **none of them can ever arm an authored event.**

**Who needs it:** the event engine, immediately. ch.11 §5 requires events to hook to system edges and names eight; **two of the eight — "raise demand" and "coverage red" — have no readable key at all**. ch.11 §1 lists nine arcs of which two (Y3 team life, Y4 hiring) are people arcs, and ch.11 §2 budgets *"4–5 on the team side"*. ch.07 §9's two named events are both unbuildable for this reason. Because `EventModal` reuses `is_condition_met`, ch.11 §8's locked-visible choices also cannot be locked on a team condition.

**If added later:** every HR event written before it lands must be rewritten, and the pull-based eligibility model needs either a signal subscription or a per-edge latch — a change to the engine, not to Ekip.

### S2 · No character-target selector for event effects

The customer side has `_resolve_customer_target` with `primary_b2b`/`primary_b2c` selectors and a documented fallback (`event_manager.gd:836-846`), serving four modifier branches. The person side has nothing: `morale`, `hr_departure` and `hr_overtime_continue` take a **literal `character_id`** and warn-and-skip on an unknown one.

An author therefore cannot write *"the most burnt-out employee"*, *"the newest hire"*, *"a random developer"* or *"the lead of the engineering area"*. This is why the only authored per-person event in the tree targets a fixture id.

### S3 · No HR write modifiers beyond morale and departure

**Who needs it:** the event engine. No modifier raises a salary, sends someone on leave, assigns an area, starts training, fires anyone, or changes a skill. `HRActions.apply_raise` is reachable only from the Ekip card, so ch.07 §9's raise slider ships as a page action rather than an event — the chapter asks for it inside a card and the vocabulary law (ch.11 §3) forbids writing the card until the effect exists.

### S4 · No level-up edge distinguishable from a reset

`add_area_experience` returns `true` on a `+1` but emits `employee_experience_changed(id, 0)` — **byte-identical** to the signal a completed training and a capped area emit. The bool return is discarded by its only caller (`hr_system.gd:122`). ch.07 §9 names "seviye atlayan çalışan" as one of the two raise-demand triggers; that moment is currently unobservable outside `CharacterRegistry`.

### S5 · Operasyon never calls the two seams built for it

`HRSystem.covering_heads()` and `HRSystem.unstaffed_areas()` have **no production callers**. Their only callers anywhere are three lines in the smoke suite (`endgame_smoke.gd:7248-7254`), which assert that the seams return the right answer — so they are tested and unused. ch.06 §1.3 legislates a coverage ratio with amber/red and ch.12 §4 wants a coverage-red badge; there is no ratio, no colour, no badge, and no *"Destek: kimse yok"* line, which ch.07 §4 asks for by name. `covering_heads`'s own docstring concedes the ratio *"BU TURDA HESAPLANMIYOR"*.

*(The audit's own first pass reported these as having "zero callers", which was wrong — the smoke callers exist. Corrected in final review; the finding survives because a smoke assertion is not a consumer.)*

The seams exist and are correct. **This is a wiring gap, not a modelling one** — the cheapest item in this section.

### S6 · Ürün reads people by reaching in, not through a seam

`ProductSystem` pulls each assigned `Character` and reads `c.role_stats[area_key]` and `c.traits` itself (`product_system.gd:519-540`, `:568-600`), as do `SalesRepSystem`, `CustomerRepSystem` and `B2BSalesSystem`. There is no `HRSystem.skill_for(person, area)` and no person-scoped trait seam that knows which catalog a person belongs to — six far-module sites call `HRConstants.trait_mult(c.traits, "<key>")` with the catalog implicit and the effect key hardcoded at the call site.

**If the skill model changes again** — and it has changed twice in six weeks — every one of these call sites is a separate edit with no compiler help. That implicit-catalog lookup is precisely the mechanism ch.07 §12 records as broken for founder traits; the specific bug was fixed, the shape that produced it was not.

### S7 · No employee-side skill check

`SkillCheck.resolve / roll_against / chance_for` take a skill **name** and read `GameState.get_founder_skill` — there is no subject parameter. `PitchSystem`'s close rolls (`:298`, `:314`) therefore run on the **founder's** Satış no matter which rep owns the account. Employee areas only ever feed continuous multipliers, never a discrete pass/fail. ch.04 §2's *"Close probability = Satış skill of whoever sells"* has no way to name whoever sells.

### S8 · Finance needs nothing it does not have — but its HR costs have no home

Payroll is a clean single pull: `CharacterRegistry.get_total_monthly_salaries()` (`finance_system.gd:137`), summing `monthly_salary` for `category == "employee"` with **no status filter**, so leave and training are fully paid — deliberate, and documented. Overtime is a second, separate pull. Severance, training fees, the retainer and the commission are one-off charges through `apply_one_time_cost`.

The seam works. What is absent is any way to ask **"what did people cost this month?"** — the one-time labels live in Finance's vocabulary (`finance_system.gd:66-72`) and nothing groups them back to Ekip. ch.08 §4's monthly close enumerates *maaşlar / araçlar / servis maliyeti / tek seferlikler*, and the overtime line the code creates is not among them.

### S9 · Satış has who-is-on-an-account, and no reverse index

`Customer.assigned_to` holds a character id and `EventBus.customer_assigned` is a clean signal consumed by both tabs. What is missing is the other direction: there is no person → accounts index, so answering *"what does this person own?"* means walking the customer registry — which is exactly what the departure question in D7 would need.

---

## §5 · Part 3b — Mechanics

**The honest answer is short, and it starts with what is *not* missing.**

Four of the five things one would naturally list here — a raise-demand negotiation, a rival poaching offer, the founder energy bar, and a morale-to-output link — are **already in the GDD and simply unbuilt**. They belong to §2, not here; proposing them as new ideas would be inventing an agenda that already exists.

What the module genuinely lacks is not features. It is **consequence**. Morale has almost no teeth: it does not touch output (D2), overload does not feed it (D1), and two of its three recovery beats cannot fire (D5/D6). Cash is currently the only currency with real edges. So the three below are chosen because they make *people* scarce rather than money, and because each creates a decision the player actually makes.

---

**M1 · Give `area_leads` a door.**
**What it is:** let the player appoint the lead of an area — the seat that already exists and has no writer (D3).
**The decision it creates:** the first people-vs-people trade in the module. Appointing your strongest engineer as lead raises everyone's learning rate under them and, once D1/D2 are repaired, slows the team's morale erosion — but ch.07 §2 makes the lead's Liderlik the lever, and Liderlik is not Yazılım, so the best worker is often the wrong lead. That is a real choice with no dominant answer.
**Cost to build:** small, and it is mostly deletion of a gap. `GameState.area_leads` exists, `area_lead()` already prefers it, the derivation is the fallback, `release_area_leads` already handles departures, and `experience_gain_mult` / `lead_experience_mult` are wired. What is missing is one control in the Görevler matrix and one writer. **It closes three governed gaps at once** — ch.07 §2's *atanan çalışan*, §9's successor question, and ch.02 §7's mentoring as a played act rather than a derived one.

---

**M2 · Let the player pull one person out of an overtime block.**
**What it is:** make the valve a three-way — stop the block, continue everyone, or **send this one person home**.
**The decision it creates:** today the valve asks a question whose answers are both about the whole department, while the modal is about one named person who is about to quit. The player can sacrifice the sprint or sacrifice the person, and nothing in between. A per-person exit turns a binary into a triage decision — who can I afford to keep burning — and it prices the answer in exactly the resource overtime is supposed to be spending.
**Cost to build:** moderate. The block record is department-keyed and `participants()` is computed per department, so this needs a per-block exclusion set. Everything else — the modal, the flag, the resignation penalty — already exists.

---

**M3 · Rest as a played cost (conditional).**
**What it is:** a replacement for the retired `TATİLE GÖNDER`, priced in **days rather than cash**: pull a person or a department off work for N days and recover morale.
**The decision it creates:** a genuine build-speed-versus-team-health trade at a moment when the player can least afford it. Note the history — the original was retired on 2026-08-22 precisely because a cash-free `+20` was a fountain the player could re-run weekly (`hr_actions.gd:118-128`). Pricing it in lost days rather than in nothing is what makes it a decision instead of a button.
**Cost to build:** small — `STATUS_ON_LEAVE`, `send_on_leave` and the return-morale credit all exist and the manual branch is still wired (§6, O2).
**Explicitly conditional:** this is worth nothing until D2 lands. While low morale costs no output, buying morale back buys nothing, and the mechanic would be a tax with no upside. **Do not build M3 before morale has teeth.**

---

## §6 · Part 4 — Open work

### O1 · Ten functions defined and never called

Verified by whole-repo grep across `.gd`, `.tscn` and `.md`, not just `scripts/`:

| File | Function | Line |
|---|---|---|
| `hr_constants.gd` | `cost_label_training()` | 729 |
| `hr_constants.gd` | `leave_month_label()` | 992 |
| `hr_constants.gd` | `roles_in_group()` | 389 |
| `hr_constants.gd` | `section_ids_in_department()` | 410 |
| `hr_constants.gd` | `section_label()` | 381 |
| `hr_search_system.gd` | `current_band()` | 122 |
| `hr_candidate_generator.gd` | `_unused_count()` | 375 |
| `hr_actions.gd` | `_current_year()` | 254 |
| `character_registry.gd` | `get_in_department()` | 332 |
| `character_registry.gd` | `get_in_section()` | 345 |

The two `character_registry` entries are the roster-returning siblings of counting functions that *are* used. `leave_month_label` is the one with a play consequence: it is the only function that could tell a player when their employee's leave month falls (U3), and it lost its caller when `preview_vacation` was deleted.

### O2 · The manual-vacation path was retired at the hand and is still fully wired

`hr_tab.gd:815-818` records `_confirm_vacation` / `_do_vacation` as EMEKLİ (2026-08-22); `hr_actions.gd:118-128` records `can_send_on_vacation` / `preview_vacation` / `send_on_vacation` as deleted. But `HRMoraleSystem.send_on_leave(emp, days, is_manual)` keeps its third parameter, and **every caller in the repository passes `false`** — the one production caller is the automatic annual leave at `hr_morale_system.gd:121`; the seven debug and harness callers all pass `false` too.

So `was_manual` (`:92`) is permanently false, and the following are unreachable in production:

- `MORALE_VACATION_RETURN := 20` (`hr_constants.gd:769`) — never applied
- `VACATION_DAYS := 7` (`:1006`) — no reader at all
- `REASON_VACATION_RETURN` (`:742`) — never emitted
- `HR_NEWS_ON_HOLIDAY` and `HR_WHENCE_HOLIDAY` — **two strings shipped in both TR and EN** (`strings.csv:854`, `:860`) that can never render
- the `hr_manual_leave_<id>` flag family — written only to `false`

This is the cleanest instance of two implementations of one behaviour coexisting: annual leave and manual vacation share one door, and only one of them can walk through it.

### O3 · Dead-by-construction: event priorities that order nothing

`hr_event_factory.gd:37`, `:52` and `:100` set event priorities of 9, 10 and 4. `EventManager._ordered_by_priority` is called from exactly two places, both on the JSON-loaded path. `EventManager.enqueue` — the only door all three HR families use — appends directly. **HR card order is pure FIFO arrival order.** The valve precedes a same-day resignation only because overtime is HR sub-step 5 and thresholds is sub-step 6. *(This one was itself a corrected finding — see §7.)*

### O4 · The EĞİTİM header button never asks who

`_open_training_picker` opens the modal on `eligible[0]` (`hr_tab.gd:383-390`), with the reason stated: *"Kişi seçme adımı onaylı tasarımda ÇİZİLMEDİ, o yüzden icat edilmiyor."* Deliberate, and correct not to invent UI — but it means a header button silently picks a person for the player. Its lock state is also frozen at `_ready`.

### O5 · The input dead zone on the BOŞTA and AŞIRI YÜK chips

See U7. A documented convention (`hr_ui_shared.gd:135-143`) obeyed for the trait icon and broken for both state chips in the same row.

### O6 · `founder_participates()` — a seam with nothing on either end

`hr_overtime_system.gd:300-305` has zero production readers. `hr_overtime_panel.gd:42-45` explains that its UI suffix was left unreachable in both branches deliberately. It is also the exact seam ch.02 §6's *"falls with overtime"* would attach to (D8).

### O7 · The v4→v5 lead-seat migration is a no-op

`save_manager.gd:798-811` rebuilds `area_leads` from a legacy `job_leads` key that has no live writer anywhere — so on any save produced by current code it migrates nothing. It is simultaneously the only thing in the repo that can put an entry into `area_leads` (D3).

### O8 · Four stale comments that contradict their own code

- `character.gd:80-83` lists `relationship` as reserved and unread; `event_modal.gd:254-266` reads it.
- `time_manager.gd:311-315` says HR "applies baseline morale drift"; the drift was deleted (`hr_system.gd:15-21`).
- `time_manager.gd` describes nine daily slots; the body runs thirteen.
- Three files describe `HRSystem.daily_tick` as seven steps; the body runs nine. A reader budgeting the tick from the comment will not go looking for `tick_overload`, `tick_experience` or `tick_training` — which is one plausible route by which the `OVERLOAD_MORALE_MULT` hole (D1) survived this long.

### O9 · Two ch.07 §4 jobs have no consumer

`AREA_RESEARCH` is in `ASSIGNABLE` and clickable in the matrix, but **no production code reads it** — `hr_constants.gd:138` says so in the declaration itself, `# TÜKETİCİSİ YOK (Ürün turunun işi)` — and `tick_experience` explicitly skips it — *"Araştırma bir YETENEK değil"* — so a person parked there produces nothing **and learns nothing**. The **Maliyet/borç** job from §4's table has no id anywhere at all, which leaves ch.06 §1.4's *"paid down by assigning someone to it"* with no assignment to make.

### O10 · A retired surface still in the file set

`right_panel.gd:270-272` still reads employee `equity_pct` although the surface was retired in the ODA rework (`event_bus.gd:132`), and `RightPanel.tscn` sits on the localization sweep's explicit skip list as a `# RETIRED surface` (`loc_residue.gd:49`). Dead weight rather than a defect, but it is a live reader of an Ekip field on a screen no player reaches.

---

## §7 · Corrections — claims that did not survive verification

225 UNGOVERNED and DIVERGENT claims were handed to a second reader whose only job was to refute them. **Nine did not survive.** They are recorded here rather than dropped, because a reader deserves to know what the process caught.

| # | Claim | Why it fell |
|---|---|---|
| 1 | *The `morale` event modifier has no live producer* | It has one: `b2b_event_factory.gd:131`'s "Reddet" choice, enqueued from production at `b2b_sales_system.gd:175-179`. |
| 2 | *`ev_debug_001` fires automatically and its morale effects are free* | `event_manager.gd:886-887` skips every `ev_debug_*` file at load. The card is never in the live pool. **(Two separate rows fell to this.)** |
| 3 | *HR event priorities (9/10/4) order the card queue* | They order nothing — `enqueue` bypasses `_ordered_by_priority` entirely. A pure name-over-body error, now re-filed as O3. |
| 4 | *"Which team is this person on" has two conflicting answers* | Over-broad. `can_hold_area` + `assign_area` make the failure case unreachable for any player. |
| 5 | *An overtime/search state signal is missing* | Compensated where it is consumed: `oda_view.gd:629` polls hourly and the comment names the gap. |
| 6–9 | Four double-counts | Two rows each for the raise-demand gap, the slot-3 finding, and the `needs_engineer` flag; the stronger version was kept in each case. |

**One error was *not* caught by the refutation pass and was found in final review.** The GOVERNED row for `verb.assign.area` states that "after `OVERLOAD_TOLERANCE_DAYS` 5 the morale cost bites". It does not — see D1. GOVERNED rows were not sent to refutation, which is a gap in this audit's method: **conformance findings got less scrutiny than non-conformance findings.** Six other rows independently reached the correct conclusion and the constant was verified by direct grep, so the report follows the majority. Any future audit should attack its GOVERNED rows too.

---

## §8 · What the code could not tell us

Stated gaps, per the rule that an unanswerable question is itself a finding.

1. **Whether any of this actually fires in a played run.** Runtime verification was ruled out. Every "fires" / "never fires" claim here is reachability argued from source and traced caller chains. D5, D6 and D3 are the ones that would most benefit from a `--run-log` confirmation; the argument for each is structural (dispatch position, absent writer) rather than statistical, which is why they are reported with confidence — but they are not *observed*.
2. **Whether the phantom design doc ever existed.** The section numbering is internally consistent across five files, which is evidence of a real document rather than invented citations, but the audit cannot recover it or date it.
3. **Whether `loyalty`, `trust_score` and `attention_flag` are reserved or dead.** From outside the two are indistinguishable. `attention_flag` is documented as deliberately unwritten; the other two carry no such note.
4. **What "tier" means in ch.02 §7's pace target** (*"~one tier over 24 months"*). The corpus never defines it. Read as a star, the code runs ~3.6× fast; read as a salary band, the comparison does not resolve. The divergence in Appendix C is filed under the star reading and says so.

---

## Appendices — the full inventory

All 380 enumerated items, each with its verdict. The nine refuted rows are omitted here and reported in §7 instead.

Within each appendix, rows are ordered **UNGOVERNED · PHANTOM CITATION → UNGOVERNED → DIVERGENT → GOVERNED**, so the undesigned surface reads first.

Row fields: what the code actually does (read from the body, not the name) · what it costs the player · what would break if it were removed · the GDD line if one exists · what the second reader found · `file:line` evidence.

`*Verification:*` records the adversarial pass. Where it reads "Confirmed in the body by a second reader; claim unchanged", a refuter tried to kill the row and could not. Where it carries a CORRECTION or a NARROWED note, the row shown is already the corrected version.

For GOVERNED rows the verification line is omitted, because GOVERNED rows were not sent to refutation — a known gap in this audit's method, discussed in §7.

---

### Appendix A — Player verbs (pass 1a)

41 entries, ungoverned first.


**`verb.event.valve_stop` — Olay secimi: 'Mesaiyi durdur' (overtime safety valve)**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — the humane half of an ungoverned mechanic; it is what keeps overtime from being a silent staff-destroyer, and no chapter knows it exists.  
No GDD chapter contains an overtime safety valve; the code's authority is the phantom doc twice over — hr_event_factory.gd:45 ("Overtime safety valve: a CHOICE, never a silent exclusion (design doc §7b)") and hr_overtime_system.gd:353. The mechanism is sound on its own terms: _maybe_enqueue_valve (:355-377) fires when a participant crosses HRConstants.is_flight_risk (morale < 25) on a mesai night, once per person per block, latched in block[valve_fired] because EventManager.enqueue bypasses _is_eligible so the event's own one_shot does nothing (documented hr_event_factory.gd:10-19). Choice 1 carries {"type":"hr_overtime_stop"} and routes to HROvertimeSystem.stop at event_manager.gd:644-645. Priority 10, tagged build_safe. It does sit on a genuine system edge, which is the shape ch.11 §5 asks for ("Events hook to system edges"), and its cost is visible in the copy — but the edge itself (flight risk crossed DURING overtime) is not one of the edges §5 enumerates, and the subsystem it interrupts is unlegislated.  
*Costs the player:* The stopped day bills in full (see verb.overtime.stop) and the block's speed bonus ends. No cash beyond that, no morale beyond the day's tier.  
*If removed:* The only automatic protection against overtime running a person all the way to resignation. Without it a block continues to its full length regardless of who breaks, and RESIGN_VALVE_PENALTY / valve_continued_for lose their only producer.  
*Verification:* eal choices, routing at event_manager.gd:644-645 and :646-650. NARROWING: "the subsystem it interrupts is unlegislated" overstates. A full GDD grep for mesai/overtime across all 13 chapters returns exactly one governing line — ch.07 rev 2 §7 line 90, "Girdiler: fazla mesai · aşırı yüklenme · ..." — so overtime EXISTING as a morale cost IS governed. What is ungoverned is everything else: blocks, department units, pay, the valve and the continue penalty. The UNGOVERNED_PHANTOM verdict for the valve EVENT stands (§7 names no valve; ch.11 §5's edge list contains no such edge), but the sentence should say "the rest of the subsystem", not "the subsystem".  
Evidence: `scripts/systems/hr_event_factory.gd:45-63` · `scripts/systems/hr_overtime_system.gd:353-377` · `scripts/autoload/event_manager.gd:644-645` · `scripts/systems/hr_constants.gd:876-882` · `GDD ch.11 §5 (edge list does not contain this edge)`


**`verb.overtime.start` — EK MESAI BASLAT (3 gun / 1 hafta / 2 hafta)**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — the largest unlegislated cost surface in the module: a repeatable cash+morale+bug purchase of build speed that the founder can take for free, with a diminishing-return schedule and a …  
An entire economic subsystem with cash, morale and quality costs and a speed benefit, and no GDD text at all. The only GDD mention of overtime anywhere is ch.07 §7's morale-input LIST ("Girdiler: fazla mesai · asiri yuklenme · ..."), which presupposes overtime exists but legislates nothing about it: no blocks, no lengths, no pay rate, no speed gain, no bug penalty, no department scope, no safety valve. Every one of those numbers is instead sourced to the non-existent HR design doc "§7b": hr_overtime_system.gd:4, :260, :353; hr_constants.gd:286, :1028. Live model: OVERTIME_BLOCKS [3,7,14] days, department-wide over HRConstants.DEPARTMENTS (three, not the four roster groups), OVERTIME_SPEED_BONUS_EARLY 0.30 falling to LATE 0.15 from OVERTIME_DIMINISH_DAY 8, OVERTIME_PAY_PCT 0.40 of a daily wage per participant per night, morale tiers 2/4/7 by day index, OVERTIME_BUG_MULT 1.25 in product_dev only. The founder participates in product_dev nights, is never paid and takes no morale hit (he is not in participants(), hr_overtime_system.gd:268-305) — which additionally leaves ch.02 §6's founder energy bar ("One bar. Falls with overtime...") with nothing at all: no energy system exists in the codebase.  
*Costs the player:* Per participant per night: overtime_daily_pay = 40% of a daily wage (OVERTIME_PAY_PCT 0.40), accrued to a static stamp FinanceSystem pulls at slot 5. Morale: -2 through day 3, -4 through day 7, -7 thereafter, cumulative, scaled by the ISKOLIK trait multiplier and the founder's Liderlik climate. Quality: bug rate x1.25 while a product_dev block runs. Founder cost: ZERO — free speed for a solo founder.  
*If removed:* Load-bearing on both sides. ProductSystem._phase_speed reads the overtime bonus at product_system.gd:715 ("Ek mesai KAZANCI yalniz BURADA uygulanir"); FinanceSystem pulls the accrued pay; HRMoraleSystem's flight-risk chain is fed by it; the valve event family (verb.event.valve_stop / valve_continue) exists only to interrupt it; hr_tab's structure key folds per-department day_index. Deleting it removes the module's only speed-for-morale trade and the only cost-bearing use of the DEPARTMENTS …  
*Verification:* CORRECTION to costs_player: "free speed for a solo founder" is FALSE. HROvertimeSystem.can_start (hr_overtime_system.gd:149-159) returns false unless participants(dept_id) is non-empty, and its own comment names the exact case the row asserts: "for product_dev it would let a solo founder buy speed with nothing but bug risk" (:157). A solo founder cannot start a block at all; the founder rides free only ON TOP of a paying crew. STRENGTHENED: founder_participates() (hr_overtime_system.gd:300-305) — the seam the header calls the founder's "CONSTANT PRESENCE" — has ZERO production readers (whole-repo grep: only its own declaration, a comment at :275, and a comment in hr_overtime_panel.gd:42 …  
Evidence: `scripts/systems/hr_overtime_system.gd:1-10` · `scripts/systems/hr_overtime_system.gd:119-181` · `scripts/systems/hr_overtime_system.gd:268-350` · `scripts/systems/hr_constants.gd:1022-1048` · `scripts/tabs/hr/hr_overtime_panel.gd:24-101` · `scripts/systems/product_system.gd:715`


**`verb.overtime.stop` — EK MESAI DURDUR (early stop)**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — the escape hatch on the module's largest ungoverned cost; its billing rule is the difference between overtime being a trade and being free speed.  
No GDD line describes stopping an overtime block because no GDD line describes starting one (see verb.overtime.start); the file's authority is the phantom "design doc §7b" (hr_overtime_system.gd:4). HROvertimeSystem.stop (:184-204) ends the block and, if block[charged_day] != GameState.day, runs _charge_day(fire_valve=false, to_carry=true) so the day being stopped bills in full — the fix for a same-day start/stop free-speed exploit (the comment at :188-195 records that the old copy was true "fazlasiyla", because the speed bonus is consumed on the HOURLY tick while the cost was charged only on the daily one). _end_block(was_stopped=true) zeroes overtime_days and erases the record; a manual stop emits no news line, only the natural end does. Where it DOES satisfy a GDD law it does so well: ch.11 §4's visible-reader requirement is met before the click by HR_OT_EARLY_STOP ("Erken durdurabilirsin; baslanan gun tam ucretlenir, sonrasi icin bedel uretmez").  
*Costs the player:* The day being stopped bills in full — its 40%-of-daily-wage pay per participant rides _pay_carry into tomorrow's Finance pull, and its full tiered morale drop (2/4/7 by day index) lands immediately. Nothing already paid is refunded.  
*If removed:* Load-bearing for the valve: verb.event.valve_stop routes into this exact function through the hr_overtime_stop modifier (event_manager.gd:644-645), so removing it kills the engine-fired safety valve as well as the manual control, and a started block could only end by running its full 3/7/14 days.  
*Verification:* d` (:433). The _pay_carry mechanism at :70-74 and :84-86 is what makes the stopped day actually reach Finance — the row understates this: without the carry the late bill would be wiped by the next day's reset, so the fix is two mechanisms, not one.  
Evidence: `scripts/tabs/hr/hr_overtime_panel.gd:104-127` · `scripts/systems/hr_overtime_system.gd:184-204` · `scripts/systems/hr_overtime_system.gd:119-145` · `scripts/systems/hr_overtime_system.gd:425-446` · `scripts/systems/hr_overtime_system.gd:4` · `GDD — no chapter mentions overtime blocks`


**`verb.row.open_menu` — Defter satirina tikla → kisi aksiyonlari menusu**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — sole entry point for three player verbs, and it has a live input dead zone on exactly the two chips a player is most likely to click (the badges telling them this person needs attention).  
The GDD legislates the three actions this menu hosts (zam ch.07 §9, egitim ch.07 §8, "let someone go" ch.08 §6) but never legislates how they are reached: ch.07 §3 and ch.02 §3 describe a closed row and an open card / hover, never an action menu. The code's authority for the menu is the phantom doc — hr_actions.gd:4 reads "The three employee-card actions (design doc §7): ZAM YAP, TATILE GONDER, ISTEN CIKAR" (and one of those three has since been retired at the hand, see verb.vacation). Implementation: the whole LedgerRow is the anchor, the ... column was retired, one left-click opens an HRPopover on PanelLayer with Zam · Egitim · [hairline] · Isten cikar. INPUT DEAD ZONE: _placement_badge sets the BOSTA / ASIRI YUK chips to MOUSE_FILTER_STOP (hr_ledger.gd:221, :227) and _pass_clicks_through skips any tooltip-carrying child (:171-172), so a click landing on those two chips is swallowed and the menu does not open — contradicting the rule stated one file over at hr_ui_shared.gd:135-143 ("STOP tooltip'i calistirir ama satir tiklamasini YUTAR — ve R1'den sonra menuyu acan TEK yol o tiklama").  
*Costs the player:* Nothing to open; no clock pause (hr_popover.gd:20-22 deliberately does not touch TimeManager).  
*If removed:* This is the SOLE reachable door to three of the module's five player actions — raise, fire and per-person training. The header EGITIM button is not a substitute (it picks the target silently and its lock state is frozen at _ready, see verb.train.header), and no other surface anywhere calls _open_raise / _confirm_fire / _confirm_training for an employee. Maximally load-bearing.  
*Verification:* The input dead zone is confirmed exactly and is worse than a coincidence — it is a documented rule being broken one file away. hr_ledger.gd:221 and :227 set both chips to MOUSE_FILTER_STOP; _pass_clicks_through (:165-173) exempts any tooltip-carrying child at :171-172, so nothing rescues them; the card's own gui_input is bound at :103 with card.mouse_filter = STOP at :104, so a STOP child consumes the click outright. hr_ui_shared.gd:135-143 states the rule and OBEYS it for the trait icon (`node.mouse_filter = Control.MOUSE_FILTER_PASS` at :142) with the comment "PASS, STOP DEĞİL: STOP tooltip'i çalıştırır ama satır tıklamasını YUTAR". Two chips in the same row, one convention, one …  
Evidence: `scripts/tabs/hr/hr_ledger.gd:96-104` · `scripts/tabs/hr/hr_ledger.gd:165-173` · `scripts/tabs/hr/hr_ledger.gd:216-229` · `scripts/tabs/hr_tab.gd:650-710` · `scripts/tabs/hr/hr_ui_shared.gd:135-143` · `scripts/systems/hr_actions.gd:4`


**`verb.search.cancel` — ARAYISI IPTAL ET (cancel a search in flight)**  
**UNGOVERNED · PHANTOM CITATION** · LOW — it changes nothing economically (the money is already gone) and only shortens a 2-4 day wait the player was not being charged for.  
ch.07 §6 seals the flow ("Muhurlu akis, dokunulmaz") as retainer -> 2-4 days -> 3 candidates and provides no abort. The code adds one, on the authority of the phantom doc: hr_search_system.gd:164 reads "Iptal: the retainer is NOT refunded — pesin ucret yanmistir (design doc §2)". Path: hr_tab.gd:340 -> _on_cancel_search :345-356 emits confirm_requested with a bound method (no "modal" key, so main.gd mounts ConfirmModal not HR_ACTION_MODAL) -> _do_cancel_search -> HRSearchSystem.cancel_search :163-170, which returns false unless state == SEARCHING and otherwise just _clear()s the dict (:395-399). The price is stated to the player before the click: HR_SEARCH_CANCEL_BODY = "Atlas arayisi kapanir. Pesin odenen {amount} iade edilmez.", which satisfies ch.11 §4's visible-reader rule even though no chapter authorises the option.  
*Costs the player:* No new charge. The already-burned SEARCH_RETAINER $600 stays burned — cancelling buys back nothing but the ability to start a different search. Side cost: opening the confirm pauses the clock (main.gd:2228) and restores it on dismiss.  
*If removed:* Nothing structural. Without it a search in flight simply resolves after its 2-4 day SEARCH_ARRIVAL delay and the player uses dismiss_files instead, which is also free of new charges. cancel_search has exactly one production caller (hr_tab._do_cancel_search). This is the most removable verb in the module.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr_tab.gd:340-361` · `scripts/systems/hr_search_system.gd:163-170` · `scripts/systems/hr_search_system.gd:395-399` · `scripts/systems/hr_search_system.gd:164` · `scripts/main/main.gd:2220-2252` · `GDD ch.07 rev 2 §6`


**`verb.vacation` — TATILE GONDER — EMEKLI (retired 2026-08-22)**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — an unlegislated engine channel removes a paid employee from every capacity read for a week with no player control and, on the Gorevler screen, no visible refusal (see verb.assign.area's …  
Neither the retired player verb nor the automatic annual leave that replaced it has any GDD line: no chapter mentions izin, holiday or leave. Both are phantom-cited — MORALE_VACATION_RETURN 20 to "design doc §7" (hr_constants.gd:769), the automatic channel to "§8" (hr_morale_system.gd:104: "Izin ayi geldiginde calisan OTOMATIK izne cikar, oyuncu onayi istenmez", and :375: "nobody is asked to APPROVE leave"). The verb was removed at the hand, not at the counter: hr_tab.gd:815-818 records the deletion of _confirm_vacation/_do_vacation and hr_actions.gd:116-128 records the deletion of can_send_on_vacation/preview_vacation/send_on_vacation, with the reasoning that removing the year latch would have turned MORALE_VACATION_RETURN +20 into a morale fountain paid only in capacity. What survives and RUNS: CharacterRegistry.add assigns every hire a leave_month; tick_leave_departures (:121) calls send_on_leave(is_manual=false) when that month arrives; the person is STATUS_ON_LEAVE for VACATION_DAYS 7, out of capacity, out of overtime, out of assigned_to(), unpickable as a steward or build lead — and still fully on payroll (character_registry.gd:414 documents that get_total_monthly_salaries is deliberately not status-filtered because annual leave is PAID leave, phantom-cited to "§8"). What survives and does NOT run: the is_manual branch, FLAG_MANUAL_LEAVE_PREFIX, tick_leave_returns' was_manual branch, MORALE_VACATION_RETURN — reachable only from the --hr-shot harness (main.gd:1703), kept deliberately for a future event channel.  
*Costs the player:* The retired verb: nothing, it cannot be reached. The surviving automatic channel: seven days of one employee's capacity per year, taken without asking, while their full salary keeps being pulled into burn — and it silently changes the answer to every status gate for a week (training refused, assignment click refused with no UI, steward and build-lead pickers drop them).  
*If removed:* The retired verb's residue is debris EXCEPT that send_on_leave and tick_leave_returns are the automatic channel's own machinery — deleting the is_manual branch alone is safe, deleting send_on_leave is not. The automatic channel itself is load-bearing: it is the only producer of STATUS_ON_LEAVE, which product_system.gd:239, b2b_sales_system.gd:95 and character_registry.gd:324 all read as "out of capacity".  
*Verification:* th is_manual=false — hr_morale_system.gd:121 and main.gd:1703 (the --hr-shot harness); the other six are endgame_smoke. CORRECTION to two evidence citations (M1): b2b_sales_system.gd:95 and product_system.gd:239 are COMMENT lines, not code. The real STATUS_ON_LEAVE gates are b2b_sales_system.gd:100 (`cs.status != HRConstants.STATUS_ACTIVE`) and, for capacity, count_active_in_department → get_active_employees (character_registry.gd:65-81); product_system.gd:243 reads the count, :239 only describes it. The mechanism is exactly as the row states; only the line numbers point at prose.  
Evidence: `scripts/tabs/hr_tab.gd:813-818` · `scripts/systems/hr_actions.gd:115-128` · `scripts/systems/hr_morale_system.gd:103-121` · `scripts/systems/hr_morale_system.gd:358-380` · `scripts/systems/hr_constants.gd:769` · `scripts/autoload/character_registry.gd:414`


**`verb.confirm.dismiss` — Onay modalini VAZGEC / ESC ile kapat (undo before commit)**  
**UNGOVERNED** · MEDIUM — pure UI plumbing, but it owns the clock-speed restore for every destructive action in the module.  
No chapter legislates confirm modals; ch.12 §2 says only "Current layout is accepted as-is for now". The code's contract: hr_action_modal.gd:235-243 (ui_cancel -> _close) plus a VAZGEC button focused by default at :87 ("varsayilan odak GUVENLI tarafta"); dismissed -> main.gd._on_confirm_dismissed :2246-2252 restores _pre_confirm_speed, which main.gd:2228-2229 stored and set to 0 when the confirm opened. Honest failure path: _on_commit :226-232 calls the bound commit and, if it returns false, RETURNS WITHOUT CLOSING ("motor reddettiyse modal ACIK kalir; sessiz kapanma yalan olurdu"). INCONSISTENT PATTERN: training_modal._on_send (:227) calls _close() unconditionally, so the same module answers the same question two ways — one modal stays open on engine refusal, the other closes silently.  
*Costs the player:* Nothing. It is the safe path, and it is the mechanism that gives the clock back after every HR confirm.  
*If removed:* Load-bearing beyond undo. Four destructive HR paths route through EventBus.confirm_requested (cancel-search, dismiss-files, raise, fire) and every one of them pauses the clock at main.gd:2228; _on_confirm_dismissed is the only restore for the ESC/VAZGEC exit. Remove it and the game sits at speed 0 after any abandoned HR confirm.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/modals/hr_action_modal.gd:85-87` · `scripts/modals/hr_action_modal.gd:226-243` · `scripts/main/main.gd:2220-2252` · `scripts/modals/training_modal.gd:222-227`


**`verb.event.add_character` — Olay secimi: add_character (event-spawned hire) — HICBIR URETICISI YOK**  
**UNGOVERNED** · LOW — unreachable, but it is a fully built bypass around the chapter's sealed hiring flow sitting one JSON line away from being live.  
No chapter authorises hiring outside Atlas — ch.07 §6 is emphatic that the hiring flow is the sealed Atlas one ("Muhurlu akis, dokunulmaz") and ch.02 §9 adds "Search mechanics (retainer, candidate count) unchanged". event_manager.gd:596-633 nonetheless carries a complete 38-line branch that constructs a Character (role defaulting to ROLE_DEVELOPER, role_stats to HRConstants.default_employee_skills(), traits to ["picks_it_up_fast"]) and calls CharacterRegistry.add. A repo-wide grep finds the string only in this branch, in event_modal.gd:538 (the effect badge EFFECT_NEW_TEAMMATE), and in CharacterRegistry's two explanatory comments (:436, :458). No event JSON in data/events/ contains it. If it ever fired it WOULD get the full hire stamps (hire_day, leave_month, default area, run_hires++) because those live inside add() rather than in the hire flow — which is why they were put there.  
*Costs the player:* Nothing — no producer. Note the copy-lie it would enable, already recorded by the prior event audit: ev_debug_001's third option reads "Yardimci bir muhendis daha al" and carries only a cash modifier, hiring nobody. That file is unloaded, so it is not a live lie today.  
*If removed:* Nothing in production. Deleting the branch would leave event_modal.gd:538's EFFECT_NEW_TEAMMATE badge unreachable (harmless) and would foreclose the only non-Atlas hire path — which ch.07 §6 arguably wants foreclosed.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/event_manager.gd:596-633` · `scripts/modals/event_modal.gd:538` · `scripts/autoload/character_registry.gd:434-463` · `GDD ch.07 rev 2 §6` · `GDD ch.02 §9`


**`verb.files.escape` — ESC / disari tiklama ile dosyalari KAPATMAK (non-destructive exit)**  
**UNGOVERNED** · MEDIUM — the cheapest correct play (leave, check runway, come back) exists but is invisible, so the presented choice is hire-now-or-lose-$600.  
ch.07 §6 legislates the Atlas flow as retainer -> 2-4 days -> 3 candidates -> "kabul edilir ya da edilmez", and says nothing about the offer persisting, expiring, or being set aside. The code adds a third exit with no counterpart in any chapter: _unhandled_input (hr_atlas_modal.gd:475-478) calls _close() = queue_free() without touching state, so GameState.hr_search keeps state=files_ready and its generated files array, HRSystem.attention_count keeps counting +1 (hr_system.gd:363-364), and the ODA desk keeps its Atlas paper (oda_view.gd:1382-1386). It is unlabelled: the search step carries an explicit VAZGEC button (:234), the FILES step builds only the destructive 'Hicbirini alma' (:272-277), so a player who does not try ESC sees only the exit that burns the retainer. Against ch.01 §9's "Locked choices are visible, never hidden" the shape is inverted — here it is an AVAILABLE choice that is hidden.  
*Costs the player:* Nothing. It is the only free way to leave the candidate files on the table — the only way to go read Finance before committing to a salary and a 15% commission.  
*If removed:* The files-ready state would become unleaveable except by hiring or by dismissing (which burns the $600 retainer), and two surfaces would lose the only state they point at: the +1 on the left-rail attention badge and the ODA desk's Atlas paper both exist solely to say "files are still waiting". Load-bearing for those two, and for player agency at the most expensive decision in the module.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr/hr_atlas_modal.gd:230-234` · `scripts/tabs/hr/hr_atlas_modal.gd:272-277` · `scripts/tabs/hr/hr_atlas_modal.gd:475-482` · `scripts/systems/hr_system.gd:358-371` · `scripts/ui/oda/oda_view.gd:1382-1386` · `GDD ch.07 rev 2 §6 (flow described; no set-aside state)`


**`verb.oda.paper_atlas` — ODA masasindaki ATLAS kagidina tikla (navigation only)**  
**UNGOVERNED** · LOW — navigation duplicate; the only ODA surface pointing at the Ekip module and it triggers nothing.  
ch.12 §6 enumerates what ODA hosts — "the monitor (build bar), the phone (events arrive here), and the room's day->night tint" — and ch.12 §8 gives Ekip's surfaces as "tab + badges". A desk paper is in neither list. _gather_papers (oda_view.gd:1382-1386) appends {id:"atlas", target:"hr"} while HRSearchSystem.has_files_ready(), with the file count in the title; the card's gui_input (:1461, :1489-1494) emits anchor_clicked and EventBus.tab_changed. The code is careful about what it is not: "Kagit akis TETIKLEMEZ — yalniz navigasyon" (:1364). SIBLING SURFACE, NOT A VERB: the corkboard post-it names the first employee carrying any badge (_refresh_postit :1333-1346) but is a Label with no input handler — it points at a person the player cannot click, which is the exact inverse of ch.12 §4's "clicking goes to the exact row".  
*Costs the player:* Nothing.  
*If removed:* Nothing. It duplicates the left-rail badge's +1 for a waiting candidate file (hr_system.gd:363-364) and reaches the same page. Pure convenience; the only cost of deletion is that ODA loses one of its live signals.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/ui/oda/oda_view.gd:1333-1346` · `scripts/ui/oda/oda_view.gd:1358-1386` · `scripts/ui/oda/oda_view.gd:1489-1494` · `GDD ch.12 §6` · `GDD ch.12 §8`


**`verb.onboard.portrait` — Kurucu portresi sec (onboarding sayfa 1)**  
**UNGOVERNED** · LOW — a purely cosmetic onboarding step with no chapter behind it; harmless, but it is the first choice the player makes and it means nothing.  
ch.12 §5 enumerates the reworked onboarding as "founder creation (name, origin, skills — archetype pick or point distribution, chapter 02 §2) -> first product Konsept -> Frank's intro"; ch.02 §1 gives founder identity as "Name + origin". A portrait step is in neither, and ch.14 §7's portrait policy enumerates who has faces (employees: none; VCs and customer-side characters: yes; Frank: yes) without naming the founder at all. The code ships an 11-cell portrait grid (FounderConstants.PORTRAIT_IDS, with a comment noting the mockup showed 12 and 11 assets exist); character_step.gd:90-120 sets _portrait_id, collect_payload :167-171 carries founder_portrait into GameState.initialize_run. NAME-COLLISION worth recording: the pick lands on GameState.founder_portrait, NOT on Character.portrait_path — personal_tab._portrait() :213-235 resolves the path separately through FounderConstants.portrait_path(GameState.founder_portrait), with the divergence documented in place at :224-226. So the founder record and the founder card answer 'which portrait' from two different fields.  
*Costs the player:* Nothing. Cosmetic, no mechanical reader anywhere; no skill, event, pitch or ending line reads founder_portrait.  
*If removed:* personal_tab._portrait() would need a fallback and character_step.is_valid() (:163-164) would lose its only gate — though that gate can never fire, because prefill pre-selects the first portrait (:156-158). Nothing mechanical breaks.  
*Verification:* + origin') and ch.12 §5 ('name, origin, skills') both omit a portrait step. Ungoverned confirmed. The name-collision is worse than the row states: Character.portrait_path is a REAL, USED field — character_registry.gd:406 and :620 both write `portrait_path = MENTOR_PORTRAIT` for Frank — so the registry carries two different conventions for 'which portrait', one on the model (Frank) and one on GameState (the founder), documented in place at personal_tab.gd:224-226. Prefill really does make is_valid() unfireable (character_step.gd prefill selects PORTRAIT_IDS[0] when empty).  
Evidence: `scripts/onboarding/steps/character_step.gd:90-120` · `scripts/onboarding/steps/character_step.gd:151-171` · `scripts/systems/founder_constants.gd:103-110` · `scripts/tabs/personal_tab.gd:213-235` · `GDD ch.12 §5` · `GDD ch.02 §1`


**`verb.promote` — TERFI / ORTAKLIK YOLU — hic var olmadi**  
**UNGOVERNED** · LOW — two words in a comment; no surface, no cost, no consequence.  
No chapter contains a promotion, a title ladder or a co-founder track. The nearest GDD text is ch.07 §9's raise trigger "bir yilini dolduran ya da seviye atlayan calisan", where "seviye atlayan" means a skill level-up (ch.07 §8 learn-by-doing), not a title change — and that trigger has no code either (see verb.raise). character.gd:96 declares attention_flag with the vocabulary comment "FLIGHT_RISK | BURNING_OUT | OVERLOADED | PROMO | CO_FOUNDER_TRACK", and the field is superseded and deliberately unwritten (:93-95). HRConstants defines exactly three badge ids plus BADGE_NEW (:777-791); PROMO and CO_FOUNDER_TRACK have no constant, no severity entry, no label key, no producer, no reader. Precision on the phantom question (M5): character.gd DOES cite the non-existent HR design doc, but at :48 and about morale drift, not about this field — so this row is plain UNGOVERNED, not UNGOVERNED_PHANTOM.  
*Costs the player:* Nothing. The field is never written in any reachable path.  
*If removed:* Nothing. attention_flag has exactly one writer in the entire codebase — event_manager.gd:631, inside the add_character branch, which itself has zero producers. Badges are derived by HRSystem.badges_for. Deleting the field and the two orphan vocabulary words is behaviour-neutral. Pure debris.  
*Verification:* E_NEW (hr_constants.gd:777-791), and PROMO / CO_FOUNDER_TRACK appear nowhere but the comment at character.gd:96. The M5 precision is right and verified: character.gd:48 reads "...leave return (HR design doc §6)" and is about morale drift, not this field.  
Evidence: `scripts/data_models/character.gd:89-96` · `scripts/systems/hr_constants.gd:774-791` · `scripts/autoload/event_manager.gd:631` · `GDD — no chapter mentions promotion or a co-founder track`


**`verb.area_lead.pick` — ALAN SORUMLUSU sec — hicbir zaman var olmadi (M2 collision, confirmed)**  
**DIVERGENT** · HIGH — a GDD-mandated player choice is absent, and the one Liderlik lever that is wired reads the wrong person (founder instead of area lead), so hiring a high-Liderlik teammate cannot slow anyone's …  
GDD: ch.07 rev 2 §2 (Skill areas) and §9 (departures); ch.02 §4  

> Liderlik: ekip lideri atanan calisanin altindaki ekibin verimlilik modifier'ini, moral dusus hizini ve deneyim kazanim hizini etkiler. Mentorluk ayri bir trait ya da sistem degildir; Liderlik'in icindedir.

"Ekip lideri ATANAN calisan" presupposes an assignment act, and §9 makes the replacement an explicit player question ("Ekip lideri istifa etti, yerine kim geciyor?" ... "ekip icin Ekip"). No such surface exists. HRSystem.area_lead (hr_system.gd:187-206) reads GameState.area_leads, but that dictionary has NO production writer: game_state.gd:254 declares it, :600-608 release_area_leads only erases, :803 clears, save_manager.gd:810 rebuilds it inside a v4->v5 migration off a RETIRED job_leads table that itself has no writer, and endgame_smoke.gd:7330 writes it in a test. game_state.gd:252-253 says so outright: "SECIM SEAM'I YOK ve bu bilincli". The lead is therefore always DERIVED — highest Liderlik among people assigned to the area, else the founder. Second, larger divergence on the same §2 sentence: of the three levers the team lead's Liderlik is supposed to move, only TWO are wired to the lead (deneyim kazanim hizi via tick_experience hr_system.gd:102-122; verimlilik via coordination_for_lead on the build lead). The third — moral dusus hizi — is wired to the FOUNDER's Liderlik globally, not the area lead's: hr_morale_system.gd:236-251 reads GameState.get_founder_skill("leadership") for climate_drop_mult/climate_gain_mult on EVERY morale movement in the game. Note also the code's own two comments disagree (hr_system.gd:188-190 reads as a live rule; game_state.gd:252-253 is the accurate one).  
*Costs the player:* Nothing today — the choice cannot be made. The consequence is invisible: which teammate multiplies an area's learning rate is decided by the engine from Liderlik scores the player never compares, and morale climate is bought entirely at onboarding through the founder's Liderlik column.  
*If removed:* HRSystem.area_lead's first branch (GameState.area_leads lookup) is dead in every fresh run and could be deleted with no behavioural change; the derived fallback is what actually runs and IS load-bearing (tick_experience's experience_gain_mult and the GERCEK LIDER mentor multiplier both read it).  
*Chapter conflict:* ch.02 §4 legislates founder Liderlik as "morale ceiling + team output multiplier" (a CEILING); ch.07 rev 2 §2 legislates the assigned team lead's Liderlik as a morale DECAY RATE. The code implements neither cleanly: a rate multiplier sourced from the founder. ch.07 is operative, so ch.02 §4's ceiling clause is overridden and must not be retired silently.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:187-206` · `scripts/autoload/game_state.gd:248-254` · `scripts/autoload/game_state.gd:600-608` · `scripts/autoload/save_manager.gd:795-812` · `scripts/systems/hr_morale_system.gd:228-254` · `scripts/systems/hr_system.gd:89-122`


**`verb.event.resign_ack` — Olay secimi: istifayi kabul et (hr_departure)**  
**DIVERGENT** · HIGH — the departure is the module's designed decision moment and the code makes it a one-button acknowledgement; the vacated work silently becomes nobody's.  
GDD: ch.07 rev 2 §9 (Raises and departures)  

> Ayrilma bir event anidir. Ayrilan kisinin isleri bosalir ve oyuncuya sorulur: "Melisa gitti, musterilerine kim bakacak?" / "Ekip lideri istifa etti, yerine kim geciyor?" Kart oyuncuyu ilgili sayfaya yonlendirir (musteri sahipligi icin Satis, ekip icin Ekip). Otomatik kurucuya devir varsayilan degildir.

The GDD mandates a two-beat departure: the event fires, then the player is ASKED who takes over, and the card routes them to Satis or Ekip. The code delivers beat one only — HREventFactory.build_resignation (hr_event_factory.gd:29-42) builds a SINGLE-choice acknowledgement whose modifier is {"type":"hr_departure"}; event_manager.gd:636-643 calls HRMoraleSystem.confirm_departure, which charges team morale and calls CharacterRegistry.remove (:530-548). remove() CLEARS assigned_jobs and calls release_area_leads — so the jobs are vacated exactly as §9 says, but nobody is asked to refill them and no card routes anywhere. The "ekip lideri istifa etti, yerine kim geciyor?" question is doubly unbuildable: there is no area-lead seam to write to (see verb.area_lead.pick). Compliant fragments: no auto-handover to the founder for AREAS; no knowledge-loss/tech-debt penalty (§9's "Bilgi kaybi / teknik borc cezasi yok"); SEVERANCE_ON_RESIGN = 0. UNGOVERNED addition: _charge_departure (hr_morale_system.gd:410-416) drops every remaining employee by MORALE_FIRE_TEAM 5, plus trait_sum("departure_morale_extra") (a further -5 for GERCEK LIDER carriers) — a departure penalty ch.07 §9 does not name.  
*Costs the player:* No severance. Team-wide morale -5 per remaining employee, up to -10 where a GERCEK LIDER trait carrier is on the roster; plus the lost headcount, its payroll relief, and its vacated areas (which nothing tells the player about — see verb.unassign.area).  
*If removed:* This choice IS the removal: the roll in _maybe_resign only ENQUEUES; without the resolution branch the employee stays on payroll forever and the enqueued event re-fires. Load-bearing.  
*Verification:* MUCH worse than reported. The row hedges "no auto-handover to the founder for AREAS" — correct for areas, but the ACCOUNT half of §9 IS auto-handed to the founder, which is the exact default §9 forbids. CustomerRepSystem._release_unheld (scripts/systems/customer_rep_system.gd:106-135), run from B2BSalesSystem.daily_tick, reads every B2B account and at :126-128 does `var rep := CharacterRegistry.get_character(c.assigned_to); if rep == null ...: CustomerRegistry.assign_customer(c.id, "")` — the leaver's whole book goes to the founder on the next daily tick, and the comment at :112-113 says the pin dies with it ("A pin does NOT survive its rep leaving"). Then _delegate_excess (:138-175) may …  
Evidence: `scripts/systems/hr_event_factory.gd:29-42` · `scripts/systems/hr_morale_system.gd:383-416` · `scripts/systems/hr_morale_system.gd:468-494` · `scripts/autoload/event_manager.gd:636-643` · `scripts/autoload/character_registry.gd:530-548` · `GDD ch.07 rev 2 §9`


**`verb.event.valve_continue` — Olay secimi: 'Devam et' (keep them on overtime)**  
**DIVERGENT** · MEDIUM — one of the two halves of an engine-fired decision carries an unbounded, permanent, entirely unreadable penalty, which is exactly the shape ch.11 §4 exists to forbid.  
GDD: ch.11 §4 (Cost law)  

> Every option costs a real resource and has a visible reader (a chip and a place in the UI where the consequence appears). An option with no cost is only valid if it is explicitly a "beat" (single-option scene). No free upside.

The option's cost is real and permanent but has NO reader anywhere. HROvertimeSystem.note_valve_continued (:380-398) writes GameState flag "hr_valve_continued_<id>" and it survives for the REST OF THE RUN, not the block (the code says so at :386-391); HRMoraleSystem._maybe_resign reads it back through HRConstants.resign_chance, adding RESIGN_VALVE_PENALTY 0.15 on top of RESIGN_CHANCE_PER_DAY 0.25 x trait multiplier (hr_constants.gd:958-964). An exhaustive grep for valve_continued / hr_valve across .gd, .csv and .json finds exactly five live sites: the event_manager apply branch, the GameState flag-type table, the two HROvertimeSystem functions, the HRMoraleSystem read, and endgame_smoke — no ledger row, no chip, no tooltip, no badge, no Kisisel line. The player is never shown that this person's resignation odds rose by 60% relative and stayed risen. Only GameState.flags.clear() at initialize_run removes it. The event this option sits in is itself ungoverned (see verb.overtime.start; the valve is phantom-cited to "design doc §7b" at hr_event_factory.gd:45 and hr_overtime_system.gd:353), but ch.11 §4 is a universal law over every option in the game and this option breaks it.  
*Costs the player:* +0.15 flat added to that person's daily resignation chance, permanently, invisibly. Everything else about the block continues unchanged.  
*If removed:* HRConstants.resign_chance's second parameter and HROvertimeSystem.valve_continued_for would become dead; the valve event would need a single-choice "beat" shape. Nothing else reads the flag.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_event_factory.gd:59-62` · `scripts/autoload/event_manager.gd:646-650` · `scripts/systems/hr_overtime_system.gd:380-407` · `scripts/systems/hr_morale_system.gd:481-489` · `scripts/systems/hr_constants.gd:952-964` · `scripts/autoload/game_state.gd:140`


**`verb.hire` — ISE AL · ${salary}/AY (hire a candidate)**  
**DIVERGENT** · HIGH — hiring is the module's primary economic act and its price is roughly double what the GDD's cost enumeration contains, on the authority of a document that does not exist.  
GDD: ch.07 rev 2 §6 (Hiring); ch.08 §1 (Burn)  

> Atlas ajansina retainer odenir → 2–4 gun sonra 3 aday. Muhurlu akis, dokunulmaz. ... Mulakat yok. Maas pazarligi yok. Uretilen maas kabul edilir ya da edilmez.

The ACT is compliant: no interview, no negotiation, the generated salary is taken or not (hr_search_system.gd:184-234). The ECONOMICS are not. The GDD names exactly one payment to Atlas — the retainer — and ch.08 §1 enumerates the run's one-off costs as "(Atlas retainer, egitim, lisans, kesinti telafisi)". The code charges a SECOND, usually larger fee at hire: HRConstants.commission_for(salary) = round(salary x SEARCH_COMMISSION_PCT 0.15), through FinanceSystem.apply_one_time_cost(..., "hire") at hr_search_system.gd:223, under the same ledger label as the retainer so the two are not even separable in Finance. The double fee is declared canon on the authority of the phantom doc: hr_constants.gd:704 reads "Cift ucret (design doc §2, KANON): pesin retainer + ise alimda komisyon" (repeated at hr_search_system.gd:157). Further ungoverned stamps inside CharacterRegistry.add / hire(): MORALE_HIRE_START 75, hire_day forced to GameState.day + 1 ("a hire starts the NEXT day at full performance" — no ramp, no GDD line), leave_month_for() assigning an annual-leave month, and the auto-assignment of default_area_for_role into assigned_jobs (which quietly pre-answers the ch.07 §4 Gorevler decision for the player). Boundary recorded: a developer hire clears GameState flag "needs_engineer"; salary enters burn by EXISTING in the registry (Finance PULLS get_total_monthly_salaries, never pushed).  
*Costs the player:* Retainer $600 (SEARCH_RETAINER, already sunk) PLUS commission 15% of the offered monthly salary at the moment of hire — for a $4,000 mid-band hire that is $600 more on top of the $600 already burned, i.e. the true cost of one hire is ~1,200 + first month's salary. Then permanent payroll. UI adds an affordability gate the engine explicitly declined to have (hr_search_system.gd:28-31 vs hr_atlas_modal.gd:368-372).  
*If removed:* The only production path that creates an employee. Everything downstream (payroll, capacity, coverage, stewardship, morale, endings headcount) has no other source; the one alternative branch, event_manager's add_character, has zero producers.  
*Chapter conflict:* ch.02 §9 legislates a shortlist/CV then an "Interview (costs founder time): exact 1+2 + 1–2 traits" reveal ladder; ch.07 rev 2 §6 (one day later, Supersedes rev 1) rules "Mulakat yok" and shows the full card on the candidate file. The code follows ch.07: no interview, no founder-time cost, exact axes printed on the file. ch.02 §9's interview and its founder-time price are overridden, and with …  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_search_system.gd:184-234` · `scripts/systems/hr_search_system.gd:157` · `scripts/systems/hr_constants.gd:704-716` · `scripts/autoload/character_registry.gd:426-463` · `scripts/tabs/hr/hr_atlas_modal.gd:288-387` · `GDD ch.07 rev 2 §6`


**`verb.onboard.traits` — Kurucu huylari sec (max 2 olumlu + 1 olumsuz)**  
**DIVERGENT** · MEDIUM — the choice is prominent, permanent and completely inert; it teaches the player that founder identity matters when it does not.  
GDD: ch.02 §8 (Traits) and §1; ch.07 rev 2 §12 (Acik isler)  

> Modifiers only (skill, rate, probability, morale); never a hidden skill number; shown as icons with tooltips. No trait duplicates a skill's job.

Founder traits modify nothing. founder_constants.gd:64-65 states it ("RESERVED: trait EFFECTS are consumed by no system yet") and a repo-wide grep for the eight ids finds only endgame_smoke.gd, main.gd's debug payload and personal_tab's icon-catalog comment — no formula reads them. The GDD itself records the defect at ch.07 rev 2 §12: "Kurucu trait'leri bugun calismiyor (kod kurucu trait'ini calisan tablosunda ariyor) — donulecek", so this is a KNOWN divergence with a scheduled return, not a discovery — but it is still a divergence from §8's binding rule and it is the single largest inert choice in onboarding. Second divergence on ch.02 §1: the GDD says "Traits from the existing catalog (~12 positive / 12 negative)"; FounderConstants.TRAITS holds EIGHT (4 positive: visionary, disciplined, networker, resilient; 4 negative: stubborn, micromanager, risk_blind, lone_wolf). Contrast the EMPLOYEE side, which fully honours §8: eleven effect keys with real readers (resign_chance_mult, experience_mult, lead_experience_mult, overtime_morale_mult, departure_morale_extra, dept_morale_decay_mult, bug_rate_mult, speed_mult, output_mult, promise_chance_mult, satisfaction_bonus — enumerated with their readers at hr_constants.gd:492-533). Caps TRAIT_MAX_POSITIVE 2 / TRAIT_MAX_NEGATIVE 1 and the Software-Inc "2 positives force exactly 1 negative" formula are ungoverned additions; clicks past the cap are silently ignored (origin_traits_step.gd:247).  
*Costs the player:* Nothing, in either direction — the negative trait the formula forces the player to take is as inert as the positives. A choice presented as a permanent identity trade-off that has no mechanical consequence anywhere.  
*If removed:* Nothing mechanical. The only readers of the founder's traits array are personal_tab's icon row and the smoke suite; Character.traits on the founder feeds no formula (HRConstants.trait_mult is only ever called with employee trait ids).  
*Verification:* ast the cap at origin_traits_step.gd:246-250, ch.02 §1 "~12 positive / 12 negative" verbatim, ch.07 rev 2 §12 verbatim. PRECISION: "no formula reads them" is loose in a way that matters. Formulas DO read the founder's traits array — HRConstants.trait_mult(c.traits, "output_mult"/"speed_mult") runs over him at sales_rep_system.gd:76-79 whenever HRSystem.assigned_to(AREA_SALES) includes him, and trait_mult(c.traits, "bug_rate_mult") at product_system.gd:982 whenever he is seated on Yazılım (which _reseat_founder does automatically in the development phase). Both return the neutral 1.0 because the ids live in the wrong catalog — which is exactly ch.07 §12's stated cause and the subject of …  
Evidence: `scripts/onboarding/steps/origin_traits_step.gd:241-272` · `scripts/systems/founder_constants.gd:58-79` · `scripts/tabs/personal_tab.gd:238-255` · `scripts/systems/hr_constants.gd:492-533` · `GDD ch.02 §1` · `GDD ch.02 §8`


**`verb.rail.hr_badge` — Sol raydaki EKIP sekmesi + dikkat rozeti**  
**DIVERGENT** · HIGH — the badge is the module's only off-page telegraph, and the two governed conditions most likely to end a run quietly (coverage red, raise demand) are the two it cannot show.  
GDD: ch.12 §4 (Attention badges); ch.06 §1.3 (Kapsam)  

> Flight risk · load over capacity · coverage red · infra capacity full · account at risk · raise demand · locked opportunity (Marka/infra gate). A badge is a number on the tab in the rail; clicking goes to the exact row.

Form is right, contents and destination are not. HRSystem.attention_count() (hr_system.gd:358-371) = people carrying any derived badge + 1 if a candidate file waits + 1 if the angel round closed and the roster is empty. The derived badge set is exactly three (hr_constants.gd:777-791): FLIGHT_RISK, BURNING_OUT, OVERLOADED. Against ch.12 §4's list: flight risk PRESENT; overload present and separately governed by ch.07 §5 ("asiri yuklenme rozeti"); coverage red ABSENT — grep for coverage/kapsam across hr_tab.gd, scripts/tabs/hr/ and hr_system.gd returns nothing, so ch.06 §1.3's mandated "Reader: HR 'Kapsam' ratio with amber/red; badge when red" has no code at all, and HRSystem.unstaffed_areas() has zero production readers (only endgame_smoke.gd:7251); raise demand ABSENT (no raise-demand event exists, see verb.raise). Two counted items are not in the GDD's list at all: the waiting Atlas file and the "you are still alone after the angel round" nudge. "Clicking goes to the exact row" is not implemented — left_tabs.gd:186-190 sets the number and the tab click opens the page. The Ekip page header deliberately shows a DIFFERENT number (attention_people_count) and HR_SUMMARY prints headcount / average morale / payroll (hr_tab.gd:277-294), so the Kapsam ratio is absent from the header too.  
*Costs the player:* Nothing directly; the mis-set costs the player the two warnings the GDD says the rail must carry — an unmanned support/CS area and a pending raise demand — while adding a nag about an unspent angel cheque.  
*If removed:* attention_count is the only reader of the derived badge array outside the ledger row; removing it would leave FLIGHT_RISK/BURNING_OUT/OVERLOADED visible only to a player already standing on the Ekip page, i.e. the resignation window (10-14 days) would have no off-page telegraph at all.  
*Verification:* two ungoverned items counted; no row targeting — left_tabs._on_tab_button at :103-110 only opens/closes the page). TWO CORRECTIONS, both worse for the module than the row states. (1) "The Ekip page header deliberately shows a DIFFERENT number (attention_people_count)" is FALSE. hr_tab._paint_summary (hr_tab.gd:277-294) sets `_summary.text = tr("HR_SUMMARY")` with count/morale/payroll only (strings.csv:411 = ÇALIŞAN {count} · ORTALAMA MORAL {morale} · AYLIK MAAŞ YÜKÜ {payroll}); its own comment records that the attention sentence was removed. Repo grep: `attention_people_count` appears ONLY at hr_system.gd:361 (its internal use by attention_count) and :374 (its declaration) — it is dead …  
Evidence: `scripts/ui/components/left_tabs.gd:186-190` · `scripts/systems/hr_system.gd:349-384` · `scripts/systems/hr_constants.gd:774-791` · `scripts/tabs/hr_tab.gd:277-294` · `scripts/systems/hr_system.gd:177-184` · `GDD ch.12 §4`


**`verb.raise` — Zam yap (give a raise, 3-15% slider)**  
**DIVERGENT** · HIGH — an unconditional, repeatable, one-way morale purchase replaces a designed two-sided negotiation; and the ch.11 §5 "raise demand" edge is dark, removing one of the two HR event families the GDD …  
GDD: ch.07 rev 2 §9 (Raises and departures); ch.11 §5 (Triggers); ch.07 §7  

> Zam talebi event'i: bir yılını dolduran ya da seviye atlayan çalışan açar; talep medyanın üstünde olabilir. Karar slider ile karşı teklif; düşük teklif moral düşürür ve kaçma riskini artırır. (Event yazımının konusu, chapter 11.)

The GDD's raise is REACTIVE: an employee opens a demand event on a one-year anniversary or a level-up, the demand can exceed the median, and the player's slider is a COUNTER-OFFER whose downside branch (low offer -> morale down, flight risk up) is half the mechanic. The code's raise is PROACTIVE and unconditional: menu row 1 on any employee at any time (hr_tab.gd:694-710 -> _open_raise :780-796 -> HRActions.apply_raise hr_actions.gd:98-112), slider 3-15% (RAISE_MIN_PCT/RAISE_MAX_PCT, both phantom-cited to "design doc §7" and "§12.3" at hr_constants.gd:1003-1004), and the ONLY morale outcome is a GAIN lerped +4..+16 (raise_morale_gain :1004-1010). There is no demand event, no median, no counter-offer, no low-offer penalty branch anywhere; grep finds no raise-demand producer in data/events or in any *_event_factory. ch.11 §5 lists "raise demand" as one of the system edges events must hook to — that edge has no event. Also missing on the same §9: the rakip teklifi (poaching) event, which ch.10 §3 also names ("Calisanimiza teklif verdi (HR event, chapter 07 §7)"). Compliant fragment: ch.07 §7's "Maas adaleti girdi degildir (zam ayri bir olaydir, §9)" holds — no salary-fairness term feeds morale anywhere.  
*Costs the player:* Permanent payroll increase only; no cash at the moment of the raise. It reaches burn on the next FinanceSystem daily tick through the salary PULL (character_registry.gd:412-421). Because the player initiates it and the only morale outcome is positive, a raise is today a pure, always-available morale purchase priced in future burn — the GDD's downside half is absent.  
*If removed:* HRActions.apply_raise is called only by hr_tab._do_raise; CharacterRegistry.set_salary has no other production caller. Removing it costs the module its only upward morale lever that the player controls directly (the other three positive-morale channels are engine-fired events on cooldown).  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr_tab.gd:694-710` · `scripts/tabs/hr_tab.gd:780-810` · `scripts/systems/hr_actions.gd:43-112` · `scripts/systems/hr_constants.gd:1000-1010` · `GDD ch.07 rev 2 §9` · `GDD ch.11 §5`


**`verb.sales.pick_steward` — Hesap sahibini degistir (account-owner picker) — BOUNDARY into Satis**  
**DIVERGENT** · MEDIUM — the verb works and the cap is honoured, but the eligible pool ignores the Gorevler screen, which decouples the module's own assignment decision from one of the five jobs §4 says it governs.  
GDD: ch.07 rev 2 §4 (job table) and §5 (capacity rule); ch.06 §1.3  

> Hesap sahipligi | Musteri Basarisi · Satis | hesap memnuniyeti, risk kartlari

The GDD makes account ownership an AREA job: the eligible pool is whoever the player has assigned to the Musteri Basarisi or Satis area on the Gorevler screen, and ch.06 §1.3 uses the same model for coverage ("covering head = anyone assigned to support/CS, founder included"). The code makes it a ROLE filter instead: sales_tab.gd:405 lists CharacterRegistry.get_active_by_role(HRConstants.ROLE_CUSTOMER_REP), so (a) a Musteri Temsilcisi who is assigned to no area at all is still offered as a steward, and (b) a person with Satis-area stars can NEVER be one, which the GDD's table explicitly allows. Two eligibility models therefore run side by side in the same module: assignment-based for build/test/support capacity, role-based for stewardship. Compliant fragment: the capacity CAP is exactly ch.07 §5's "tek istisna" — B2BConstants.cs_capacity(role_stats[customer_success]) gates the picker with SALES_STEWARD_FULL (sales_tab.gd:410-415), and reps on leave or in training are filtered out by get_active_by_role. BOUNDARY RECORDED at CustomerRegistry.assign_customer / EventBus.customer_assigned; the far side (satisfaction, churn, delegation sweep) not audited.  
*Costs the player:* No cash. The rep's roster fills toward cap; over cap, ch.07 §5's stated consequence (auto-handover or satisfaction loss) is the far side.  
*If removed:* hr_tab subscribes to customer_assigned specifically so the MT card's live account count repaints (hr_tab.gd:70-72) and folds CustomerRepSystem.roster_size into its structure key (:222-223). Removing the picker leaves stewardship entirely to the nightly _delegate_excess pass, i.e. no played decision at all — which ch.01 §9 forbids.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/sales_tab.gd:371-429` · `scripts/autoload/character_registry.gd:276-298` · `scripts/tabs/hr_tab.gd:70-72` · `scripts/tabs/hr_tab.gd:219-223` · `GDD ch.07 rev 2 §4` · `GDD ch.07 rev 2 §5`


**`verb.search.pick_role` — Rol sec (Atlas Adim 1)**  
**DIVERGENT** · MEDIUM — the roster of hirable roles is correct for a B2B run; the divergence costs the demo its coming-soon telegraph and mis-locks two roles in B2C.  
GDD: ch.07 rev 2 §1 (Roles in v1); ch.11 §8; ch.01 §9  

> Demo kapsami disi (EA): Pazarlama rolleri, in-house IK calisani. Ikisi de Atlas'ta kilitli-gorunur kart olarak durur.

The GDD names exactly which two role cards must sit LOCKED-VISIBLE in the Atlas. Neither exists: EMPLOYEE_ROLES is a flat six-id array (hr_constants.gd:258) = product_manager, designer, developer, tester, sales_rep, customer_rep, and hr_atlas_modal.gd:106-107 builds the grid from that array, so no Pazarlama card and no in-house IK card is ever drawn. Meanwhile the lock machinery that DOES exist locks two roles the GDD ships unlocked: role_lock_reason_key (hr_constants.gd:432-450) returns HR_ROLE_LOCK_SALES for sales_rep and HR_ROLE_LOCK_CS for customer_rep whenever ProductSystem.has_b2b_product() is false — an engine-derived market gate with no GDD line behind it (ch.07 §1 lists both roles as v1 roles without a market condition). So the Atlas telegraphs the wrong future: it hides the two EA roles entirely and, in a B2C run, greys out two roles the demo is supposed to ship. Compliant fragment: the lock GRAMMAR is right — a locked card gets 0.6 modulate, a lock glyph and the reason printed in amber, and no gui_input is connected (hr_atlas_modal.gd:184-193), matching ch.11 §8's "shown locked with a reason line. Never hidden"; the engine back-stop at hr_search_system.gd:137-139 agrees.  
*Costs the player:* Nothing at the click. The cost is informational: a B2C player is told two shipped roles are unavailable, and no player is ever told the full game will add Pazarlama and IK.  
*If removed:* EMPLOYEE_ROLES is load-bearing beyond this screen — HRCandidateGenerator derives its seed index from find() on that array and the smoke contract asserts its size (hr_constants.gd:436-440), so the array cannot be filtered without reshuffling every candidate pool in the game.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:258` · `scripts/systems/hr_constants.gd:432-450` · `scripts/tabs/hr/hr_atlas_modal.gd:96-108` · `scripts/tabs/hr/hr_atlas_modal.gd:140-194` · `scripts/systems/hr_search_system.gd:132-142` · `GDD ch.07 rev 2 §1`


**`verb.train.header` — Ekip basligindaki EGITIM dugmesi — KISI SECTIRMEZ**  
**DIVERGENT** · MEDIUM — a prominent header control that spends money on an unnamed person and whose lock state lies for the whole life of the page instance.  
GDD: ch.07 rev 2 §8 (Training); ch.01 §9  

> Sure iki hafta; kisi o sure boyunca calisamaz. Oyuncu hangi alanin yukselecegini secer.

ch.07 §8 makes training a per-PERSON commitment (that person cannot work for two weeks) whose one player-facing choice is the AREA. This control adds a second, unstated choice and makes it for the player: _open_training_picker (hr_tab.gd:383-390) takes _eligible_for_training()[0], and because get_employees() iterates _characters.values() (character_registry.gd:54-62) that is Dictionary insertion order = HIRE ORDER, so the target is the earliest-hired eligible employee, with no name shown before the modal opens. The code says so on purpose at :384-386 ("Kisi secme adimi onayli tasarimda CIZILMEDI, o yuzden icat edilmiyor"). Against ch.01 §9's "Every economic outcome comes from a played decision moment": the tiered fee and the two weeks of lost capacity are committed against a person the player did not pick. STALE GATE compounding it: _build_training_control() is called exactly once, from _build_chrome() in _ready (hr_tab.gd:149-150); neither _refresh nor _rebuild nor _rebuild_forced rebuilds it, so on a fresh run the header reads EGITIM · KILITLI and hiring the first employee from the Atlas — which routes back through _on_atlas_changed -> _refresh() — does NOT relight it. The button only tells the truth after the player leaves the Ekip tab and returns. The founder can never be its target (get_employees excludes category "founder").  
*Costs the player:* Nothing to press. Once through, the same tiered fee and 14 days of lost capacity as any training block — spent on whoever happens to be first in the registry.  
*If removed:* Nothing: the row menu (verb.train.rowmenu) and the Kisisel footer (verb.train.founder) are the real doors and cover every trainable person including the founder. This control is the least load-bearing of the three entry points and the only one that chooses for the player.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr_tab.gd:149-150` · `scripts/tabs/hr_tab.gd:369-390` · `scripts/tabs/hr_tab.gd:195-208` · `scripts/autoload/character_registry.gd:54-62` · `GDD ch.07 rev 2 §8` · `GDD ch.01 §9`


**`verb.unassign.area` — Gorevler matrisinde isaretli kareyi KALDIR (unassign)**  
**DIVERGENT** · MEDIUM — the verb works, but the consequence the GDD explicitly requires this screen to show is invisible, so unstaffing support is a silent decision.  
GDD: ch.07 rev 2 §4 (Assignment)  

> Hangi isin bos kaldigi bu ekranda gorunur (or. "Destek: kimse yok") — oyuncu o durumu burada yarattigi icin uyari burada durur.

The unassign act itself is exactly §4 ("Atanmamis kisi bosta durur ve maas yer — 'Bosta' rozeti" is honoured: BOSTA chip on the row, full payroll via the non-status-filtered get_total_monthly_salaries, and zero learning because tick_experience skips an empty assigned_jobs at hr_system.gd:100-101). What is missing is the sentence the GDD attaches to it. HRSystem.unstaffed_areas() exists (hr_system.gd:177-184) and returns exactly the "Destek: kimse yok" data, but a repo-wide grep finds ONE caller and it is endgame_smoke.gd:7251 — no production surface renders it, and hr_system.gd:178-179 documents the omission as intentional. The only signal the player gets is an empty column in the matrix they must notice unaided; there is no warning line, no chip, no confirm on emptying an area, and (per verb.rail.hr_badge) no coverage badge either. So the GDD's stated reason for putting the warning on this screen — "oyuncu o durumu burada yarattigi icin" — is unserved at the exact moment it applies.  
*Costs the player:* No cash at the click. The real cost is deferred and unannounced: the person keeps eating salary while learning nothing, and whatever job the area fed (support, test, sales, stewardship) silently loses its head.  
*If removed:* unassign_area is called only from hr_tab._on_assignment_toggled and by ProductSystem._reseat_founder's clear_areas path. Removing the player-facing half would make every assignment permanent, which would break the Gorevler screen's whole premise (§4 lets one person hold several areas and lets the player move them).  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr_tab.gd:572-590` · `scripts/autoload/character_registry.gd:234-241` · `scripts/systems/hr_system.gd:100-101` · `scripts/systems/hr_system.gd:177-184` · `scripts/debug/endgame_smoke.gd:7251` · `GDD ch.07 rev 2 §4`


**`verb.assign.area` — Gorevler matrisinde bir kareyi ISARETLE (assign an area)**  
**GOVERNED**  
GDD: ch.07 rev 2 §4 (Assignment) and §5 (Asiri yuklenme)  
Matches the chapter closely. One row per person, checkable boxes, multiple areas allowed; seven columns from HRConstants.ASSIGNABLE = the six AREAS + research, which is §4's job table row "Arastirma (ozellik kilidi) | Urun · Tasarim · Yazilim | kilitli ozellik acilir" (and ch.03 §2's research slot). Eligibility is exactly §2's star logic — can_hold_area refuses an area the person has no stars in, drawn as a genuinely dashed non-clickable square with HR_ASSIGN_NOT_YOUR_AREA ("Bu kisinin bu alanda yildizi yok"), which is §2's "QA yoksa muhendis test edebilir" rule read backwards. §5 is honoured: a second area produces the overload badge and OVERLOAD_OUTPUT_MULT 0.75 on output and learning, overload_days accrues, and after OVERLOAD_TOLERANCE_DAYS 5 the morale cost bites — §5's "Asiri yuk kisa sure tolere edilir, uzun surerse moral duser ve kacma riskine gider", with the weights properly …  
Evidence: `scripts/tabs/hr/hr_assignments.gd:135-188` · `scripts/tabs/hr/hr_assignments.gd:195-218` · `scripts/tabs/hr_tab.gd:572-590` · `scripts/autoload/character_registry.gd:210-231` · `scripts/autoload/event_bus.gd:72` · `scripts/systems/hr_system.gd:143-156`


**`verb.assign.founder_move` — KURUCUYU tasi — matriste YOK (unreachable branch in hr_tab)**  
**GOVERNED**  
GDD: ch.07 rev 2 §4 (Assignment); ch.02 §5  
The ABSENCE is what the chapter mandates and the code delivers it: HRAssignments.build iterates get_employees(), which filters category == "employee", and the file header states the removal outright (hr_assignments.gd:28-31: "KURUCU BURADA YOK ... Kurucu bir atanabilir isci DEGIL"). The founder's single area is written by the engine instead — GameState._build_founder seeds assigned_jobs = [_founder_start_area(stats)] (game_state.gd:969) and ProductSystem._reseat_founder re-seats him per build phase via clear_areas + assign_area (product_system.gd:405-415) — and Kisisel READS it, which is the second half of the same sentence. DEBRIS: hr_tab.gd:580-582 still carries a documented 'founder moves, is not refused' branch that no caller can reach, and hr_assignments.gd:11-13 still describes a 'KURUCU BANDI en ustte (10b)' that :28-31 of the same file contradicts. OPEN BOUNDARY QUESTION worth …  
Evidence: `scripts/tabs/hr_tab.gd:566-590` · `scripts/tabs/hr/hr_assignments.gd:11-13` · `scripts/tabs/hr/hr_assignments.gd:28-47` · `scripts/systems/product_system.gd:405-415` · `scripts/autoload/game_state.gd:969` · `GDD ch.07 rev 2 §4`


**`verb.build.pick_lead` — SORUMLU sec (build lead picker) — BOUNDARY into Urun**  
**GOVERNED**  
GDD: ch.03 §2 (Konsept); ch.07 rev 2 §2 and §4  
ch.03 §2 puts "team assignment (founder included)" in Konsept and ch.07 §4's job table gives Build ekibi its levers ("hiz, tavan, bug orani"). The picker (creation_flow.gd:679-695) is item 0 = the founder, then every get_active_employees() member whose department_of(role) == DEPT_PRODUCT_DEV; on-leave and in-training people are excluded by get_active_employees, which is the correct reading of the status rules. The lead's Liderlik feeds _speed_for_lead through HRConstants.coordination_for_lead (COORD_MIN 0.85 -> COORD_MAX 1.20), with a separate neutral-at-zero coordination_for_founder curve so putting the CEO in charge is never a speed tax — that is §2's verimlilik modifier, correctly wired. BOUNDARY RECORDED, far side not audited. Two things worth carrying: (1) the pick writes NO Character field — the id lands on FeatureBuild.lead_engineer_id, so the Ekip module sees nothing and no …  
Evidence: `scripts/tabs/product/creation_flow.gd:679-695` · `scripts/tabs/product/creation_flow.gd:860-866` · `scripts/systems/product_system.gd:486-500` · `scripts/systems/hr_constants.gd:917-947` · `GDD ch.03 §2` · `GDD ch.07 rev 2 §2`


**`verb.event.morale_all` — Olay secimi: morale_all_employees (uc pozitif HR event'i)**  
**GOVERNED**  
GDD: ch.07 rev 2 §7 (Morale); ch.11 §5  
The chapter's input list is the specification and two of the three producers are literally on it: build_ship_glow fires on "surum cikti", build_big_signing on a large account signing (a basari ani), and build_calm_stretch on a long quiet stretch (not on the list, an addition). ch.11 §5's edge-binding rule is satisfied — these hook to ship, signing and an overtime-free streak, not to calendar rolls. Fired one per tick by tick_positive_events (:176-200) behind POSITIVE_EVENT_COOLDOWN_DAYS with a deterministic freshest-cause-first order; the cooldown stamp GameState.hr_last_positive_event_day doubles as the once-only latch, stamped at ENQUEUE not at resolve, because EventManager.enqueue bypasses _is_eligible and a synthetic event ignores one_shot. Morale lands through the single seam so the trait decay multiplier and Liderlik climate fold in exactly once. WHAT IS MISSING FROM THE SAME …  
Evidence: `scripts/systems/hr_event_factory.gd:66-90` · `scripts/systems/hr_morale_system.gd:176-200` · `scripts/systems/hr_morale_system.gd:509-522` · `scripts/autoload/event_manager.gd:587-589` · `scripts/systems/hr_constants.gd:758` · `GDD ch.07 rev 2 §7`


**`verb.files.dismiss` — Hicbirini alma (dismiss the candidate files)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 (Hiring)  
"...ya da EDILMEZ" is this verb, and the code implements the refusal exactly: no interview to skip, no negotiation to decline, just take one of the three at the printed salary or take none. HRSearchSystem.dismiss_files (:173-179) charges nothing ("no commission, no charge of any kind") and clears the state machine; the sunk retainer is the whole cost of a throwaway search, and the confirm says so before the click (HR_ATLAS_CLOSE_BODY: "Hicbirini almazsan arayis kapanir ve pesin odenen {amount} geri gelmez"), satisfying ch.11 §4's visible-reader rule. The confirm deliberately mirrors hr_tab's bound-method contract because ConfirmModal goes to ModalLayer/layer 10 while the Atlas sits on PanelLayer/layer 9, so it always draws on top (comment at hr_atlas_modal.gd:437-440).  
Evidence: `scripts/tabs/hr/hr_atlas_modal.gd:272-277` · `scripts/tabs/hr/hr_atlas_modal.gd:436-453` · `scripts/systems/hr_search_system.gd:173-179` · `GDD ch.07 rev 2 §6` · `GDD ch.11 §4`


**`verb.fire` — Isten cikar (dismiss an employee)**  
**GOVERNED**  
GDD: ch.08 §6 (Shutter); ch.07 rev 2 §9  
"Let someone go" is the only GDD sentence that makes firing a player verb, and it frames it as a CASH-RECOVERY move during the 30-day shutter. The code implements it as a cash-NEGATIVE move: HRConstants.severance_amount = monthly_salary x max(1, floor(days_served/365)), i.e. SEVERANCE_MIN_MONTHS 1, charged through FinanceSystem.apply_one_time_cost BEFORE the removal (hr_actions.gd:186-189, ordering deliberate). Severance appears in no chapter and is absent from ch.08 §1's one-off enumeration ("Atlas retainer, egitim, lisans, kesinti telafisi"); its authority is the phantom doc (hr_constants.gd:1019, "design doc §7"). can_fire is deliberately NOT gated on affordability (hr_actions.gd:136-138) — severance may push cash negative, and the preview says so through the negative_after flag, the only thing the modal paints red. So during a shutter, firing to recover deepens the hole first and …  
Evidence: `scripts/tabs/hr_tab.gd:702-707` · `scripts/tabs/hr_tab.gd:821-841` · `scripts/systems/hr_actions.gd:135-202` · `scripts/autoload/character_registry.gd:530-548` · `scripts/systems/hr_constants.gd:1011-1019` · `GDD ch.08 §6`


**`verb.onboard.name` — Kurucu adini yaz**  
**GOVERNED**  
GDD: ch.02 §1 (Founder identity); ch.12 §5 (Onboarding)  
Free text; collect_payload (character_step.gd:167-171) returns founder_name stripped into GameState. Note the divergence-adjacent detail: is_valid() (:163-164) gates only on the portrait, NOT on the name, so a blank founder name is accepted — personal_tab compensates at :160-163 by falling back to Character.character_name ("debug kosularinda bos olabilir; Character her zaman bir ad tasiyor, o yuzden kart asla adsiz cizilmez"). Same shape as verb.onboard.portrait: the founder's display identity lives in two fields (GameState.founder_name and Character.character_name) with the UI choosing between them.  
Evidence: `scripts/onboarding/steps/character_step.gd:163-171` · `scripts/tabs/personal_tab.gd:156-163` · `GDD ch.02 §1` · `GDD ch.12 §5`


**`verb.onboard.origin` — Koken sec (Sifirdan / Mirasyedi / Kurumsal Firari)**  
**GOVERNED**  
GDD: ch.01 §8; ch.02 §1; ch.14 §3; ch.09 §1  
Three chapters say the same thing and the code does it: _make_origin_card (origin_traits_step.gd:96-142) connects gui_input ONLY on the unlocked path, and locked origins get the disabled-card recipe with a LOCK_FULL / LOCK_SOON pill — ch.11 §8's "shown locked with a reason line. Never hidden". Starting cash is FounderConstants.STARTING_CASH 10000, matching ch.09 §1's "the founder starts with personal savings [WORKING ~$10K]". So the choice is a one-option choice BY DESIGN, not by omission. UNGOVERNED RESIDUE inside it: initialize_run SETS reserved_flags ["origin_press_sympathy", "origin_low_capital"] and founder_constants.gd:81-82 records that they are "consumed nowhere yet" — and the self_made card advertises three chips (RESILIENT / LOW_CAPITAL / PRESS) whose effects those dead flags were to carry, so the card promises three modifiers the run does not have.  
Evidence: `scripts/onboarding/steps/origin_traits_step.gd:88-148` · `scripts/systems/founder_constants.gd:79-101` · `scripts/tabs/personal_tab.gd:123-126` · `GDD ch.01 §8` · `GDD ch.02 §1` · `GDD ch.14 §3`


**`verb.onboard.skills` — Kurucu yeteneklerini dagit (6 puan, sutun basina max 3, 8 sutun)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (Skill areas); ch.12 §5 (Onboarding); ch.02 §11  
FounderConstants.SKILLS = the six AREAS + leadership + charisma (founder_constants.gd:36-38) — exactly ch.07 rev 2 §2, including Karizma being founder-only, and the retired Hiz is gone (OLD_SKILLS is the fossil record and GameState.get_founder_skill push_errors on it). ch.12 §5's "skills — archetype pick or point distribution" is satisfied by the point distribution. POINT_POOL 6 (all must be spent), ONBOARDING_CAP 3, SKILL_CEILING 5 are unstated by any chapter and are marked [WORKING] in place, with the live calibration risk written honestly at founder_constants.gd:43-53 (6 points now spread over EIGHT columns instead of five, so the founder has more true zeros). _build_founder (game_state.gd:955-969) key-locks and validates, then seeds f.assigned_jobs = [_founder_start_area(stats)] — the founder's opening job derived from where he weighted himself. BOUNDARY: Liderlik is the module's …  
*Chapter conflict:* ch.02 §2 rules six SKILLS (Gelistirme, Tasarim, Satis, Musteri Basarisi, PAZARLAMA, OPERASYON) plus one meta HIZ = "7 numbers", and ch.02 §11 says onboarding must set "the 7+2 numbers"; ch.07 rev 2 §2 (Supersedes rev 1, approved one day later) rules six AREAS (Urun, Tasarim, Yazilim, TEST, Satis, Musteri Basarisi) plus Liderlik plus founder-only Karizma, and states "Hiz (pace) skill'i …  
Evidence: `scripts/onboarding/steps/origin_traits_step.gd:276-330` · `scripts/systems/founder_constants.gd:36-56` · `scripts/systems/founder_constants.gd:173-186` · `scripts/autoload/game_state.gd:955-969` · `scripts/systems/hr_morale_system.gd:228-254` · `GDD ch.07 rev 2 §2`


**`verb.sales.steward_founder` — Hesabi KURUCUYA geri ver**  
**GOVERNED**  
GDD: ch.06 §1.3 (Kapsam); ch.07 rev 2 §9  
"Assign the founder" is exactly this verb: sales_tab.gd:421-429 sets Customer.assigned_to = "" (founder-held) with pinned=true, and the pin is load-bearing and documented at :424-425 — without it CustomerRepSystem._delegate_excess re-delegates the next morning and the player's choice evaporates, which is also the code's honouring of ch.07 §9's "Otomatik kurucuya devir varsayilan degildir" read in the other direction (the automatic sweep must not override an explicit hand). When the account is already founder-held the row is a disabled SALES_STEWARD_CURRENT. BOUNDARY RECORDED at CustomerRegistry.assign_customer; the satisfaction/coverage consequences are the far side and not audited.  
Evidence: `scripts/tabs/sales_tab.gd:421-429` · `scripts/systems/customer_rep_system.gd:101-126` · `GDD ch.06 §1.3` · `GDD ch.07 rev 2 §9`


**`verb.search.commission` — ARAYIS BASLAT · $600 (commission an Atlas search)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 (Hiring); ch.08 §1 (Burn)  
Every term of the sentence is implemented: SEARCH_RETAINER 600 charged once via FinanceSystem.apply_one_time_cost(600, "hire") at hr_search_system.gd:159 and never refunded; arrival_day = day + _arrival_delay(seed) bounded by SEARCH_ARRIVAL_MIN_DAYS 2 and MAX 4; CANDIDATE_COUNT 3. ch.08 §1 carries the cost class explicitly ("one-off costs (Atlas retainer, ...)"). The amount itself is unstated in the GDD, i.e. a calibration input, not a divergence. NOTABLE COLLISION INSIDE A GOVERNED VERB: hr_search_system.gd:28-31 declares "NO AFFORDABILITY GATE, deliberately ... preview_search carries the economic warning instead of a disabled button", but hr_atlas_modal.gd:250-252 disables the CTA on `affordable` anyway — the UI enforces a gate the engine explicitly declined. The module holds three different affordability policies: this one (engine says no gate, UI gates), verb.fire (engine honours …  
Evidence: `scripts/tabs/hr/hr_atlas_modal.gd:239-255` · `scripts/systems/hr_search_system.gd:128-160` · `scripts/systems/hr_search_system.gd:28-31` · `scripts/systems/hr_constants.gd:710-716` · `GDD ch.07 rev 2 §6` · `GDD ch.08 §1`


**`verb.search.open_atlas` — Atlas'i ac (+ ISE ALIM BASLAT / DOSYALARI AC / bos satirdaki inline / ODA kagidi)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 (Hiring); ch.12 §2  
The Atlas surface itself is the chapter's, and the two-step shape (SEARCH step / FILES step, branched from HRSearchSystem.get_state() at hr_atlas_modal.gd:72-79) mirrors the two halves of §6's sentence. Four controls, one target — Ekip header (hr_tab.gd:151), the search strip when files are ready (:324), the empty-group row's inline ghost (:471 -> hr_ledger.gd:186) and the Gorevler empty state (hr_assignments.gd:42) — all landing on _open_atlas :610-631, which mounts on PanelLayer, add_childs FIRST then populates. UNGOVERNED BY DESIGN AND WORTH RECORDING: the clock is NOT paused. The comment at :611-617 records that PanelLayer was chosen over ModalLayer precisely so Space and 1-4 keep working, i.e. the game keeps running at whatever speed while the player reads candidate files — no chapter asks for or forbids this, and it is the opposite of every confirm modal in the module …  
Evidence: `scripts/tabs/hr_tab.gd:151` · `scripts/tabs/hr_tab.gd:610-637` · `scripts/tabs/hr/hr_ledger.gd:177-188` · `scripts/tabs/hr/hr_assignments.gd:42` · `scripts/tabs/hr/hr_atlas_modal.gd:67-79` · `GDD ch.07 rev 2 §6`


**`verb.search.pick_band` — Butce bandi sec (Atlas Adim 2)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 (Hiring)  
HRConstants.BANDS (junior/mid/senior) x role feeds HRConstants.salary_band(role, band), which is literally "rol x seviye"; the [WORKING] marks the numbers as calibration input, not the rule (M3). _band_card (hr_atlas_modal.gd:198-226) sets _selected_band and rebuilds. The band drives the generated quotes and therefore the 15% commission bracket. The modal shows NO runway line at this step — a deliberate documented deviation from the mockup (hr_atlas_modal.gd:12-15: economic context belongs on the candidate card where a concrete salary exists), which no chapter contradicts. The 'three discrete options, not a slider' shape is phantom-cited to "design doc §2" at hr_constants.gd:632, but the band concept itself is the GDD's.  
Evidence: `scripts/tabs/hr/hr_atlas_modal.gd:110-115` · `scripts/tabs/hr/hr_atlas_modal.gd:198-226` · `scripts/systems/hr_constants.gd:634-637` · `scripts/systems/hr_constants.gd:687-694` · `GDD ch.07 rev 2 §6`


**`verb.train.commit` — EGITIME GONDER · ${fee} (start a training block)**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 (Training); ch.08 §1  
Four clauses, four matches. Tiered fee: training_fee = round((TRAINING_FEE 500 + value x TRAINING_FEE_PER_POINT 220) x (1 + repeats x TRAINING_REPEAT_SURCHARGE 0.35) x 1.35 for Liderlik) — hr_constants.gd:816-838, the values [WORKING] per M3. Two weeks: TRAINING_DAYS 14, STATUS_TRAINING, and the person is genuinely out of everything (capacity, overtime, assigned_to, experience accrual). Player picks the area: verb.train.pick_area. Diminishing on repeat: implemented as a RISING PRICE (35% surcharge per repeat) rather than a shrinking gain — the gain stays a flat +1 to AREA_TRAIN_CAP 8 — which is the same economics per dollar and is the only reading the code offers; worth noting as an interpretation, not a deviation. Fee charged via FinanceSystem.apply_one_time_cost(fee, "training"), which is ch.08 §1's "one-off costs (... egitim ...)". This is the ONE place in the module where …  
*Chapter conflict:* ch.02 §7 rules "training course = cash + person unavailable [WORKING 3 weeks] -> +1 in one skill; diminishing on repeat"; ch.07 rev 2 §8 (approved one day later, Supersedes rev 1) rules "Sure iki hafta". Code follows ch.07 with TRAINING_DAYS 14. ch.02 §7's three-week figure is overridden and must not be silently retired.  
Evidence: `scripts/modals/training_modal.gd:145-157` · `scripts/modals/training_modal.gd:222-227` · `scripts/systems/hr_system.gd:288-303` · `scripts/autoload/character_registry.gd:154-198` · `scripts/systems/hr_constants.gd:812-838` · `GDD ch.07 rev 2 §8`


**`verb.train.founder` — Kisisel sayfasinda EGITIME GONDER (founder training)**  
**GOVERNED**  
GDD: ch.07 rev 2 §3 and §10 (Links); ch.02 §10  
Placement is exactly as legislated — the control is on the founder card footer in Kisisel (personal_tab.gd:258-290), not on the Ekip page, and ch.07 §10's Links row repeats it ("Personal (02): kurucu karti, kurucunun skill'leri ve egitimi, mevcut gorev"). It opens the same TrainingModal, which shows the founder six areas + Liderlik instead of the employee's two-plus-Liderlik — sanctioned by §3's own reason for moving him off the Ekip page ("kurucunun her alanda puani var, Ekip sayfasini sisirir"). The founder is a real participant in the training machinery: HRSystem.tick_training explicitly appends him to the loop (hr_system.gd:264-276) BECAUSE omitting him left him suspended in STATUS_TRAINING forever, and tick_experience appends him too. Same MISLEADING_REASON as the row menu: while the founder IS in training this button greys with "Bu alan tavanda." BOUNDARY: a founder in training is …  
Evidence: `scripts/tabs/personal_tab.gd:258-314` · `scripts/systems/hr_system.gd:89-98` · `scripts/systems/hr_system.gd:264-285` · `scripts/modals/training_modal.gd:160-171` · `GDD ch.07 rev 2 §3` · `GDD ch.07 rev 2 §10`


**`verb.train.pick_area` — Egitim modalinda ALAN sec (row click)**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 and §3  
One sentence, one implementation. _skill_row (training_modal.gd:174-219) connects the click handler ONLY when trainable and sets _selected; rows come from _rows_for(c) — founder gets HRConstants.trainable_keys() (six areas + Liderlik), employee gets role_key_area + role_secondary_area + SKILL_LEADERSHIP deduped, which is §3's "yalniz o rolun anahtar alani ve varsa ikincil alani" plus §2's "Ek olarak herkeste Liderlik". Untrainable rows print "—" for the fee, HR_TRAINING_AT_CAP in the duration column, carry that as tooltip and take mouse STOP, so a capped area cannot be selected — and here the cap reason is the TRUE reason (the check is role_stats[area] < AREA_TRAIN_CAP with the area supplied), unlike the entry-point buttons. The target star column shows min(current+1, AREA_TRAIN_CAP), with the comment at :192-194 recording that the mockup's full-star step was calibration text and the …  
Evidence: `scripts/modals/training_modal.gd:123-124` · `scripts/modals/training_modal.gd:160-219` · `scripts/autoload/character_registry.gd:135-150` · `scripts/systems/hr_constants.gd:846-857` · `GDD ch.07 rev 2 §8` · `GDD ch.07 rev 2 §3`


**`verb.train.rowmenu` — ... menusunde 'Egitime gonder' (per-person entry point)**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 (Training)  
The real per-person door, and the one that matches the chapter: the person is named before anything is committed and the player then chooses the area. Spec at hr_tab.gd:698-701 -> _confirm_training :395-409 mounts TrainingModal on PanelLayer with populate(emp.id). Meta column prints HR_TRAINING_DURATION_WEEKS = "iki hafta", byte-matching §8. MISLEADING REASON, against ch.11 §8's "shown locked with a reason line": the greyed row and its tooltip always print HR_TRAINING_AT_CAP ("Bu alan tavanda.") — but CharacterRegistry.can_train(id) with no area (character_registry.gd:135-150) returns the same false for status != STATUS_ACTIVE, so a person who is simply on leave or already in training is told a cap story. The engine carries no reason string here (can_train is bool-only), which is exactly the case HRUiShared.disabled_button's own doc-comment says must be answered by a preview_* …  
Evidence: `scripts/tabs/hr_tab.gd:690-710` · `scripts/tabs/hr_tab.gd:393-409` · `scripts/autoload/character_registry.gd:135-150` · `scripts/tabs/hr/hr_ui_shared.gd:402-411` · `GDD ch.07 rev 2 §8` · `GDD ch.11 §8`


**`verb.view.switch` — KADRO / GOREVLER segment degistir**  
**GOVERNED**  
GDD: ch.07 rev 2 §4 (Assignment)  
Byte-for-byte the chapter: two segments, Kadro the default, Gorevler the assignment matrix. _make_segment (hr_tab.gd:476-483) -> _show_view -> _rebuild_forced, a full teardown and rebuild rather than a `visible` toggle, and _rebuild (:258-263) hides the ledger column header and mounts HRAssignments.build for the assignments view. Early-returns if already on that view. Stale line recorded: the file header at :8 still says "Router YOK", corrected fifteen lines later at :31-36 — self-documented, harmless.  
Evidence: `scripts/tabs/hr_tab.gd:31-36` · `scripts/tabs/hr_tab.gd:243-274` · `scripts/tabs/hr_tab.gd:476-490` · `GDD ch.07 rev 2 §4`


---

### Appendix B — State that describes a person (pass 1b)

52 entries, ungoverned first.


**`char.hire_day` — Character.hire_day**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — it silently prices the fire button, and the price runs against ch.08 §6's recovery lever.  
Stamped by add() (character_registry.gd:442) then deliberately RE-STAMPED to day+1 by the hire flow because a hire starts the next day (hr_search_system.gd:217-221); insert_raw refuses to re-stamp and names re-stamping as the bug it exists to avoid (:513-517). Its live consumers are both unlegislated. (a) SEVERANCE: hr_actions.gd:146/:184 compute days_served → HRConstants.severance_months (hr_constants.gd:1018-1027), a rule whose only stated authority is 'design doc §7' at :1019. No chapter mentions severance; ch.08 §1's one-off list is 'Atlas retainer, eğitim, lisans, kesinti telafisi'. (b) The 3-day YENİ badge (hr_constants.gd:863-867 → hr_ledger.gd:336) and the roster sort tiebreak (hr_tab.gd:461-462). NOT a founder field — personal_tab.gd:128-130 computes founder tenure from GameState.day instead. Notably, ch.07 §9's 'bir yılını dolduran' raise-demand condition is the one GDD clause that WOULD read tenure, and nothing implements it.  
*Costs the player:* At least one month's salary, every time. severance_months floors at SEVERANCE_MIN_MONTHS 1, and preview_fire deliberately allows the charge to push cash negative (hr_actions.gd:139-141). This directly complicates ch.08 §6, which offers 'let someone go' as a way to SURVIVE a cash-below-zero shutter: firing during the shutter deepens the hole first.  
*If removed:* Severance collapses to a constant (or zero), the YENİ badge fires for everyone or no one, and the roster sort loses its tiebreak. Nothing else reads it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/character_registry.gd:439-442` · `scripts/systems/hr_search_system.gd:217-221` · `scripts/systems/hr_constants.gd:1018-1027 (severance rule cited to the non-existent design doc §7)` · `scripts/systems/hr_actions.gd:142-148, :180-202` · `GDD 08 §1, §6`


**`char.leave_month` — Character.leave_month**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — a silent, unannounced, uncontrollable 7-day loss of a person the player is still paying, in a demo whose whole pressure is capacity.  
THE ENTIRE ANNUAL-LEAVE SUBSYSTEM IS ABSENT FROM THE GDD. A grep of all thirteen chapters for izin / tatil / leave / vacation returns nothing (the only 'leave' hit is ch.10's 'a named account leaves'). Its stated authority is the phantom doc: hr_morale_system.gd:104 and :375 cite 'design doc §8', as do character_registry.gd:324 and :414 and hr_overtime_system.gd:270. Mechanically: assigned once at hire from a coprime stride so consecutive hires spread out (character_registry.gd:455-457 → hr_constants.gd:979-989, MIN_GAP 2 + STRIDE 7 over a 10-month span), read by exactly one line (hr_morale_system.gd:113) which sends the person on LEAVE_DAYS 7 of PAID leave the month it comes up, with no player approval ('oyuncu onayı istenmez'). NOTHING RENDERS IT: HRConstants.leave_month_label (hr_constants.gd:992-999) has zero callers since preview_vacation was retired (hr_actions.gd:115-128).  
*Costs the player:* Full salary for 7 days of zero output, silently. get_total_monthly_salaries is deliberately NOT status-filtered (character_registry.gd:412-421) because the leave is paid, while assigned_to() drops the person from every formula (hr_system.gd:141-148). The player is never told when it will happen or that it happened for a reason.  
*If removed:* Annual leave never fires. That kills MORALE_LEAVE_RETURN +10, which hr_constants.gd:758-760 names as one of only THREE morale recovery channels ('aksiyonlar + izin + pozitif moral event'leri') in a system with no self-healing. It also removes an uncontrollable capacity hole.  
*Verification:* -115 inside tick_leave_departures; get_total_monthly_salaries's deliberate non-filter at character_registry.gd:412-421. CORRECTION IN THE ROW'S FAVOUR: it is not fully silent on the way in — send_on_leave's else branch (hr_morale_system.gd:379-380) emits HR_NEWS_ON_LEAVE_MONTH to the ticker. But that is a non-modal news line with no month, no duration and no advance warning, and nothing anywhere ever tells the player WHEN a given person's leave month will come, because leave_month_label — the one function that could say it — has no caller.  
Evidence: `scripts/data_models/character.gd:61` · `scripts/autoload/character_registry.gd:455-457` · `scripts/systems/hr_constants.gd:979-999` · `scripts/systems/hr_morale_system.gd:104-121` · `grep of all 13 GDD chapters for izin|tatil|leave|vacation: no governing line`


**`char.leave_taken_year` — Character.leave_taken_year**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — invisible, but it is the only bound on the ungoverned leave drain.  
Once-per-year latch stamping the calendar year the annual leave was consumed. One writer (hr_morale_system.gd:373, inside send_on_leave, stamping for both the automatic and the now-dead manual path) and one reader (:115, the guard that skips anyone already on leave this year). LIVE, not dead — hr_actions.gd:115-128 retired only the PLAYER-FACING writer (TATİLE GÖNDER), and hr_tab.gd:815-818 confirms 'leave_taken_year'a dokunan bir oyuncu eylemi ARTIK YOK' while both engine sides stayed intact. Its comment at :116-120 notes the latch is also what makes the returns-before-departures tick order safe on its own. Phantom authority, same §8 citations as the rest of the leave block.  
*Costs the player:* Nothing directly — it CAPS the cost, holding annual leave to once per calendar year per person.  
*If removed:* The month test at :113 would re-fire every single day of the leave month, so a person whose leave month came round would be sent on a fresh 7-day leave daily — an unbounded capacity sink. Strongly load-bearing despite having no player-facing writer.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:63` · `scripts/systems/hr_morale_system.gd:370-373, :113-121` · `scripts/systems/hr_actions.gd:115-128` · `scripts/tabs/hr_tab.gd:815-818`


**`char.leave_until_day` — Character.leave_until_day**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — it is the only part of the leave system the player can actually see (the İZİNDE · N gün chip), and the chip is the sole explanation offered for the missing capacity.  
Absolute run day the current leave ends; no seam exists, the leave owner writes the field directly (hr_morale_system.gd:369, cleared to 0 at :90; ownership claimed at :16). Read at :86 to hold the person out and at :344 to produce days_until_return, which HRSystem.leave_line (hr_system.gd:387-395) turns into the ledger's İZİNDE chip (hr_ledger.gd:318). Same phantom authority as its siblings — hr_morale_system.gd:375 cites 'design doc §8'. send_on_leave refuses days<=0 (:364-365) and is idempotent against a running leave (:366-367), so the field cannot be extended by re-entry.  
*Costs the player:* It IS the cost of char.leave_month, expressed as a countdown: seven paid days out of every formula, per employee, per year.  
*If removed:* The leave would never end — tick_leave_returns (hr_morale_system.gd:84-99) reads only this field to decide who comes back, so the person would stay STATUS_ON_LEAVE forever and the +10 return bonus would never pay.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:62` · `scripts/systems/hr_morale_system.gd:358-380, :337-344, :84-99` · `scripts/systems/hr_system.gd:387-395` · `scripts/tabs/hr/hr_ledger.gd:318`


**`char.overtime_days` — Character.overtime_days**  
**UNGOVERNED · PHANTOM CITATION** · LOW — pure dead state; recorded only because it is the one field a reader would assume drives overtime pay and does not.  
A per-person counter of days worked in the CURRENT overtime block, incremented on every billed night (hr_overtime_system.gd:133) and zeroed at both ends of a block (:456, from start() at :177 and _end_block() at :431). Its owner file cites 'HR design doc §7b' (:4) and no GDD chapter mentions a per-person overtime count. The ONLY production read is the equality guard inside its own reset: `if department_of(emp.role) == dept_id and emp.overtime_days != 0` (:455). A whole-repo grep across .gd/.tscn/.json/.csv finds no other consumer; the remaining hits are endgame_smoke.gd:4823-4824 asserting the reset. The pay, the morale drop and the speed bonus are all computed from the BLOCK's day_index (:121-138), never from this field.  
*Costs the player:* Nothing. It is accumulated, persisted by SaveCodec reflection, and never reaches a formula, a badge or a screen.  
*If removed:* Nothing but one smoke assertion. Removing it changes no pay, no morale, no speed, no bug rate and no display — the per-person overtime history is genuinely debris.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:65` · `scripts/systems/hr_overtime_system.gd:133, :449-456, :35-37` · `scripts/systems/hr_overtime_system.gd:121-138 (pay/morale read day_index, not this field)`


**`state.flag_manual_leave` — GameState.flags["hr_manual_leave_<character_id>"]**  
**UNGOVERNED · PHANTOM CITATION** · LOW — dead branch, no reachable behaviour.  
Per-person marker distinguishing a manual vacation from the automatic annual leave, because the two owe different return bonuses. Both are absent from the GDD; MORALE_VACATION_RETURN's own declaration cites 'design doc §7' (hr_constants.gd:769), as do hr_morale_system.gd:92 and :371. The TRUE branch is dead: both callers of send_on_leave pass is_manual = false (hr_morale_system.gd:121, main.gd:1703) because the TATİLE GÖNDER action was removed, so `was_manual` at :88 is always false and MORALE_VACATION_RETURN 20 is unreachable — only MORALE_LEAVE_RETURN 10 ever pays. hr_actions.gd:115-128 records why the action died (R3 ruled the manual vacation must not consume the annual latch, which made it unlimited and turned it into a capacity-priced morale fountain — 'Kalibrasyon Yasası 1'in adıyla yasakladığı şekil') and states the branch is kept on purpose for a future event channel.  
*Costs the player:* Nothing. It is always false and its only effect would be to double a morale bonus that no live path can request.  
*If removed:* Nothing observable. Delete it and every leave return pays MORALE_LEAVE_RETURN 10, which is what happens today. Pure debris with a documented future intent.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_morale_system.gd:46-51, :88-99, :358-380` · `scripts/systems/hr_actions.gd:115-128` · `scripts/systems/hr_constants.gd:769` · `scripts/autoload/game_state.gd:139`


**`state.flag_valve_continued` — GameState.flags["hr_valve_continued_<character_id>"]**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — a permanent, invisible, per-person penalty produced by a single modal click, and the only lasting consequence the overtime system leaves behind.  
No chapter describes an overtime safety-valve event or a per-person resignation penalty; ch.11 §5's list of legal trigger edges (churn, phase change, incident, raise demand, rival move, version ship, coverage red, promise broken) contains nothing like it. The authority cited is 'design doc §7b' (hr_overtime_system.gd:353, hr_event_factory.gd:45). Mechanism: when a person under MORALE_FLIGHT_RISK is in a running block, build_overtime_valve raises a two-choice modal (hr_event_factory.gd:47-64); answering 'Devam et' routes through the hr_overtime_continue modifier (event_manager.gd:646-650) to note_valve_continued (hr_overtime_system.gd:380-398), which sets a RUN-LONG, PER-PERSON flag. valve_continued_for (:401-407) is read by hr_morale_system.gd:481-482 → HRConstants.resign_chance (:960-964), which adds RESIGN_VALVE_PENALTY 0.15 to that person's daily roll. Scope is deliberately per-run, not per-block (:386-391: 'the block ending does not unsay it'); a different, self-clearing latch (`valve_fired`, :45/:373-376) prevents repeat modals inside one block.  
*Costs the player:* One click raises that employee's daily resignation chance from 0.25 to 0.40 (+60% relative) for the REST OF THE RUN, un-repairable by any action — raises, training and leave do not clear it. Nothing on any screen shows the flag afterwards.  
*If removed:* The 'Devam et' choice becomes a free option — the modal would then present a costless upside, which is precisely what ch.11 §4's cost law forbids. The valve event itself would still fire and stop the block on the other choice.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_overtime_system.gd:57-59, :353, :380-407` · `scripts/systems/hr_morale_system.gd:481-482` · `scripts/systems/hr_constants.gd:960-964` · `scripts/systems/hr_event_factory.gd:45-64` · `GDD 11 §4, §5 (nearest lines — neither authorises this)`


**`state.hr_last_overtime_day` — GameState.hr_last_overtime_day**  
**UNGOVERNED · PHANTOM CITATION** · LOW — a single cursor behind one placeholder beat whose copy the content sprint is expected to replace anyway.  
Cursor for the 'sakin dönem' recovery beat, which no chapter describes and which does not correspond to any edge in ch.11 §5's list; hr_constants.gd:1071 cites 'design doc §6 + §12.8'. Stamped at the end of _charge_day on every day a block actually runs, even when the crew is empty (hr_overtime_system.gd:142-144). Exactly one reader: days_since_last_overtime (hr_morale_system.gd:298-304), `GameState.day - maxi(hr_last_overtime_day, 1)` — the maxi is the deliberate 0-means-never handling, safe only because the trigger is a >= test (:299-303). Consumed at :197-199 against CALM_STRETCH_DAYS 21 with the CALM_STRETCH_MAX_MORALE 70 gate so a happy team does not get free morale.  
*Costs the player:* Nothing. It gates a +5 team morale gift after 21 overtime-free days.  
*If removed:* The calm-stretch beat never fires, removing one of the three recovery channels named at hr_constants.gd:758-760. It would also make the recovery unconditional if removed carelessly, since the reader's fallback treats 0 as day 1.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:297` · `scripts/systems/hr_overtime_system.gd:142-144` · `scripts/systems/hr_morale_system.gd:197-199, :298-304` · `scripts/systems/hr_constants.gd:1068-1076`


**`state.hr_last_positive_event_day` — GameState.hr_last_positive_event_day**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — it is the only bound on the game's only automatic morale recovery, and one of its three triggers is a legal ch.11 §5 edge while two are not.  
Cooldown cursor AND once-only latch for the three positive morale beats. No chapter defines these beats or a cooldown; the nearest lines are ch.07 §10's 'Events (11): … moral olayları' and ch.11 §5's edge list, of which only 'version ship' matches one beat (SHIP_GLOW). The cited authority is the phantom doc — hr_constants.gd:1071 and hr_event_factory.gd:66 both cite 'design doc §6 + §12.8'. Written at ENQUEUE, not at resolve (hr_morale_system.gd:517-522), so an unread beat still blocks the next one; read at :509-514 with `<= 0` returning true so the first beat is never gated, otherwise POSITIVE_EVENT_COOLDOWN_DAYS 14. It doubles as the once-only latch because the three factory events share fixed ids (hr_event_factory.gd:73/:80/:87) and enqueue() bypasses one_shot entirely (:10-14). All three events are single-option beats, which keeps them legal under ch.11 §4's 'a beat may have no cost' exception.  
*Costs the player:* Nothing — these are the giving side: +5 calm stretch, +4 big signing, +6 ship glow, applied to the whole team through morale_all_employees.  
*If removed:* Catastrophic for the loop, in the other direction: hr_morale_system.gd:177 calls these THE RECOVERY CHANNEL and notes morale never self-heals. Without the latch the same beat re-fires daily on a standing condition (a calm stretch stays true once reached), turning a bounded recovery into an unbounded morale fountain.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:298` · `scripts/systems/hr_morale_system.gd:176-199, :509-522` · `scripts/systems/hr_event_factory.gd:8-19, :66-91` · `scripts/systems/hr_constants.gd:1068-1080` · `GDD 11 §4, §5; GDD 07 rev 2 §10`


**`cand.note_index` — candidate["note_index"]**  
**UNGOVERNED** · LOW — correctly unrendered debris; the card matches the GDD without it.  
ch.07 §6 enumerates the candidate card exactly — 'rol uyum yıldızı + anahtar alan + varsa ikincil alan + 1–2 trait' — and a file note is not among the four. The generator still produces one: _take_unused_index (hr_candidate_generator.gd:417-424) picks a deduped index into a 12-line pool, stored as an INDEX so no language freezes into state (hr_constants.gd:1141-1144, resolving HR_FILE_NOTE_<i+1>). hr_search_system.gd:361 resolves it into preview_hire['note'] and NOTHING consumes that key; hr_atlas_modal.gd:285-287 states outright that the approved design removed the quote and that the old code had been reading a `note` key the raw file never carried. The only other reader in the repo is endgame_smoke.gd:4393-4409.  
*Costs the player:* Nothing.  
*If removed:* Nothing on screen. Twelve localised CSV rows (HR_FILE_NOTE_1..12) would become orphans, and one smoke case would need retiring.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_candidate_generator.gd:129-130, :417-424` · `scripts/systems/hr_search_system.gd:361` · `scripts/tabs/hr/hr_atlas_modal.gd:285-287` · `GDD 07 rev 2 §6`


**`char.attention_flag` — Character.attention_flag**  
**UNGOVERNED** · LOW — dead field. The governance question it raises belongs to the derived badges, which cover one of ch.12 §4's seven entries.  
The FIELD is reserved, superseded and unread: one writer (event_manager.gd:632, an event-authored hire), zero readers, and endgame_smoke.gd:5069-5070 asserts it stays unwritten. The supersession is stated three times (character.gd:93-95, hr_constants.gd:774-776, hr_system.gd:352-355) — badges are DERIVED because one String cannot hold two simultaneous badges. The live derivation (hr_morale_system.gd:261-279 → hr_system.gd:351-355 → hr_ledger.gd:342, hr_ui_shared.gd:258-264, oda_view.gd:1339) returns three ids worst-first. Against ch.12 §4's badge list ('Flight risk · load over capacity · coverage red · infra capacity full · account at risk · raise demand · locked opportunity') only Flight risk matches; BURNING_OUT is an extra, OVERLOADED is the needs_engineer flag under a borrowed name, and coverage red / raise demand / account at risk / infra capacity full / locked opportunity have no HR-side source. The field's own declared vocabulary also names PROMO and CO_FOUNDER_TRACK, which exist in no constant table anywhere in the repo.  
*Costs the player:* Nothing. Never written in production, never read.  
*If removed:* Nothing. SaveCodec persists it by reflection only (save_codec.gd:97/:126), and reflection is not a reader.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:93-96` · `scripts/autoload/event_manager.gd:632` · `scripts/systems/hr_morale_system.gd:261-279` · `scripts/systems/hr_constants.gd:774-787` · `GDD 12 §4`


**`char.id` — Character.id**  
**UNGOVERNED** · LOW — invisible infrastructure, with one deterministic copy-selection side effect.  
Pure plumbing; no chapter mentions character ids. Convention `char_<slug>` per TECH_SPEC §12, never rewritten after creation. Employees get `char_emp_<day>_<run_hires>` (hr_search_system.gd:200); the founder and mentor get fixed ids. CharacterRegistry.add refuses a null/empty id and an id collision with a warning and no insert (character_registry.gd:427-432); there is no format validator anywhere. One player-visible coupling worth noting: hr_constants.gd:1110-1114 hashes the id to pick a person's resignation and valve voice line, so the id silently decides which sentence they speak.  
*Costs the player:* Nothing.  
*If removed:* The module. Every registry lookup, every latch (pending departure, valve flag, manual-leave flag), every UI ref dictionary and every synthetic event id (hr_event_factory namespaces per character to avoid suppressing a JSON event, :16-18) is keyed on it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:29` · `scripts/autoload/character_registry.gd:426-432` · `scripts/systems/hr_search_system.gd:200` · `scripts/systems/hr_constants.gd:1110-1114`


**`char.loyalty` — Character.loyalty**  
**UNGOVERNED** · LOW — declared-and-never-used reserve.  
No chapter defines a loyalty stat for staff (ch.09 §6's 'Relationships carry' is about VC funds, not employees). One writer — event_manager.gd:618, the add_character event modifier — and zero readers. A whole-repo grep over .gd/.tscn/.json/.csv returns only the declaration (character.gd:90), three doc lines (character.gd:22, save_codec.gd:16, game_state.gd:971) and two unrelated prose uses about CUSTOMER loyalty (b2b_constants.gd:179, b2b_sales_system.gd:461). Persisted by SaveCodec's generic property walker alone.  
*Costs the player:* Nothing.  
*If removed:* Nothing, except the save schema's forward-compatibility intent stated at character.gd:20-23. No formula, condition, badge or screen touches it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:90` · `scripts/autoload/event_manager.gd:618` · `scripts/systems/save_codec.gd:13-26, :97`


**`char.trust_score` — Character.trust_score**  
**UNGOVERNED** · LOW — declared-and-never-used reserve with an unenforced range.  
No chapter defines a trust score for staff. One writer (event_manager.gd:620), zero readers; the whole-repo grep returns only the declaration, three doc lines and the write. Its declared -100..100 range is enforced NOWHERE — event_manager.gd:620 writes whatever the JSON says, unclamped, which under ch.11 §3's vocabulary law means an authored event can write a value no engine rule bounds.  
*Costs the player:* Nothing.  
*If removed:* Nothing. Same reserve class as loyalty.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:92` · `scripts/autoload/event_manager.gd:620` · `scripts/systems/save_codec.gd:13-26`


**`state.flag_debug_hr_force` — GameState.flags["debug_hr_force"]**  
**UNGOVERNED** · LOW — test scaffolding.  
Debug-build-only override for the resignation roll, read at hr_morale_system.gd:500-506: 'pass' returns true and 'fail' returns false, both gated on OS.is_debug_build(); otherwise the draw is RngStreams.get_stream(STREAM_HR_MORALE).randf(). Written by the smoke harness only. Same shape as the sibling debug_skill_force (game_state.gd:131) used by SkillCheck; the named-stream split (:58-66) exists so an HR roll can never displace an event-deck draw.  
*Costs the player:* Nothing — inert in a release build.  
*If removed:* The smoke suite loses deterministic resignation coverage; nothing in a shipped run changes.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:130-132` · `scripts/systems/hr_morale_system.gd:497-506, :58-66`


**`state.flag_needs_engineer` — GameState.flags["needs_engineer"] (BOUNDARY: Ürün → Ekip)**  
**UNGOVERNED** · MEDIUM — it is the only hiring pressure signal in the game, and it borrows ch.07 §5's vocabulary for a different condition, which is a ch.11 §3 vocabulary-law hazard.  
No chapter describes a bug-sprint-frequency pressure signal. The nearest lines are ch.12 §4's badge list ('load over capacity') and ch.06 §1.2's support load — but neither is this flag: ProductSystem sets it when ENGINEER_SPRINT_THRESHOLD bug sprints land inside ENGINEER_WINDOW_DAYS (product_system.gd:1117-1125), which is neither support load nor coverage. HR then renders a COMPANY-level condition as a PER-PERSON badge: hr_morale_system.gd:328-334 is_capacity_overloaded reads the flag and badges_for (:271-278) hands BADGE_OVERLOADED to every STATUS_ACTIVE product_dev member. That badge is labelled AŞIRI YÜKLÜ — the same words ch.07 §5 gives to the person-level 2+-area condition, which the row chip draws from a completely different source (HRSystem.is_overloaded at hr_ledger.gd:217, hr_assignments.gd:119, hr_tab.gd:533). Two conditions, one Turkish word, two independent code paths. hr_search_system.gd:224-228 clears the flag when a ROLE_DEVELOPER is hired ('the answer clears the question').  
*Costs the player:* Nothing in cash or morale. It costs attention: an amber badge on every engineer and product manager, and it is the only in-game prompt to hire an engineer.  
*If removed:* BADGE_OVERLOADED loses its only source and disappears from the attention channel entirely (attention_count, the left-rail badge, oda_view.gd:1339). The Ürün→Ekip boundary would go silent — this bool is the whole of it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:90` · `scripts/systems/product_system.gd:1117-1125` · `scripts/systems/hr_morale_system.gd:271-278, :328-334` · `scripts/systems/hr_search_system.gd:224-228` · `GDD 12 §4 (nearest badge line — does not cover this)`


**`state.run_departures` — GameState.run_departures**  
**UNGOVERNED** · LOW — a counter with a single consumer, carrying two comments that would mislead the next reader.  
ch.13 §3's run-summary list has no departures row ('accounts lost' is customers). Written by the removal seam only, reading category BEFORE the erase (character_registry.gd:537-538, :547), reached from HRMoraleSystem.confirm_departure (:404) and HRActions.fire (hr_actions.gd:201). Exactly one reader: game_state.gd:682 inside get_run_ledger. TWO COMMENTS ARE STALE AND SAY THE OPPOSITE — character_registry.gd:534-535 ('Reads 0 today — no fire/quit flow calls remove() with an employee yet') and game_state.gd:655 ('run_departures reads 0 until a fire/quit flow exists') are both FALSE: hr_actions.fire and confirm_departure are live player-reachable paths and endgame_smoke.gd:4561-4570/:4595-4617 asserts the increment. A second M1 case in this module.  
*Costs the player:* Nothing.  
*If removed:* One number in the run ledger. Nothing gates on it, no ending reads it, no screen currently prints it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:243, :650-655, :682` · `scripts/autoload/character_registry.gd:530-548` · `scripts/systems/hr_actions.gd:196-201` · `scripts/systems/hr_morale_system.gd:383-404` · `GDD 13 §3`


**`state.run_hires` — GameState.run_hires**  
**UNGOVERNED** · MEDIUM — invisible, but it silently owns candidate-pool variety, which is a stated v1 replay-value source (ch.13 §4: 'replay value in v1 comes from run variance (market, rivals, hire pool, event …  
One counter answering four questions, none of them legislated. ch.13 §3's run-summary list (months survived · versions shipped · accounts · peak MRR · headcount · net worth · funding taken · accounts lost · notable events) contains headcount, not hires. Incremented inside add()'s employee branch (character_registry.gd:461), so an event-spawned hire counts too; deliberately NOT incremented by insert_raw (:512-517, so loading a run does not inflate its own counter). Read as: the leave-month spreader's hire_ordinal (:438 → :457), the employee id suffix `char_emp_<day>_<run_hires>` (hr_search_system.gd:200), a candidate-seed term SEED_HIRES_STRIDE × run_hires (hr_candidate_generator.gd:170), and the run ledger's 'hires' (game_state.gd:681).  
*Costs the player:* Nothing directly. Indirectly it is what makes each search return DIFFERENT people — the seed is (role, band, day, run_hires), so without it every search of the same role and band would return the same three files.  
*If removed:* Three things break at once and they are hard to see: candidate variety collapses, employee ids can collide within a single day, and leave months bunch onto the same month. The four-way overload means changing WHEN it increments moves all three together.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:238, :681` · `scripts/autoload/character_registry.gd:434-461` · `scripts/systems/hr_candidate_generator.gd:161-172` · `scripts/systems/hr_search_system.gd:196-200` · `GDD 13 §3, §4`


**`cand.role` — candidate["role"] and the hireable-role gate**  
**DIVERGENT** · HIGH — the Atlas's role menu is the wrong menu in both directions: two governed cards missing, two ungoverned locks present.  
GDD: ch.07 rev 2 §1 and §6; ch.01 §9  

> Demo kapsamı dışı (EA): Pazarlama rolleri, in-house İK çalışanı. İkisi de Atlas'ta kilitli-görünür kart olarak durur. […] Kilitli iki rol kartı: Pazarlama, in-house İK.

The six hireable ids match ch.07 §1 exactly (product_manager, designer, developer, tester, sales_rep, customer_rep). The LOCK does not. HRConstants.EMPLOYEE_ROLES is a flat six with no Pazarlama and no İK entry, and hr_atlas_modal.gd:106 iterates exactly that array — so the two roles the GDD requires to stand in the Atlas as locked-visible cards are absent entirely, against ch.01 §9's 'Locked choices are visible, never hidden'. In their place the code locks TWO SHIPPING roles the GDD never locks: role_lock_reason_key (hr_constants.gd:432-454) returns HR_ROLE_LOCK_SALES / HR_ROLE_LOCK_CS for sales_rep and customer_rep whenever ProductSystem.has_b2b_product() is false, and hr_search_system.gd:137-139 refuses them engine-side.  
*Costs the player:* In a B2C run, two of six roles are unbuyable — the player pays the $600 retainer only for the four that remain, and never sees the two EA cards that were supposed to telegraph the full game.  
*If removed:* The field itself is load-bearing (key/secondary area, salary band, BAND_SHAPE peak, card label all derive from it). The market-gated lock is what stops a B2C run minting enterprise prospects with no pitch — removing it re-opens a bug named in place at hr_constants.gd:437-440.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:248-258` · `scripts/systems/hr_constants.gd:432-454` · `scripts/tabs/hr/hr_atlas_modal.gd:106, :141-185` · `scripts/systems/hr_search_system.gd:132-139` · `GDD 07 rev 2 §1, §6; GDD 01 §9`


**`cand.traits` — candidate["traits"]**  
**DIVERGENT** · MEDIUM — a one-clause range violation, but it halves the texture of the only pre-hire information the player gets.  
GDD: ch.07 rev 2 §6 (Hiring)  

> Aday kartı: rol uyum yıldızı + anahtar alan + varsa ikincil alan + 1–2 trait.

The generator emits exactly ONE trait per file and the validator refuses two: _pick_traits (hr_candidate_generator.gd:323-347) draws a single id, re-checks with HRConstants.validate_employee_traits and push_errors on failure (:345-346), and CharacterRegistry re-checks on add (:487-489). The batch-level design above it is careful and unlegislated-but-sound: _cost_carriers (:296-320) decides for the WHOLE batch of three how many carry a cost-bearing trait (TRAIT_COST_SHARE 0.5 plus a seeded fractional draw), with a seeded start index so the cost trait is not always on the same card. So the card can never show the upper half of §6's '1–2'.  
*Costs the player:* Indirectly — the cost-bearing trait is priced into nothing (the salary premium reads the skill shape only, hr_candidate_generator.gd:261-291), so a hard trait is a free downside the player must read on the card.  
*If removed:* The hire's whole trait payload; Character.traits is written from this key (hr_search_system.gd:209 via _traits_copy).  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_candidate_generator.gd:296-347` · `scripts/systems/hr_constants.gd:538-551, :587-600` · `scripts/systems/hr_search_system.gd:209, :424-430` · `GDD 07 rev 2 §6`


**`char.assigned_jobs` — Character.assigned_jobs**  
**DIVERGENT** · HIGH — Araştırma is a visible, choosable, permanently inert assignment, and tech-debt paydown has no lever at all.  
GDD: ch.07 rev 2 §4 (Assignment) — with ch.06 §1.1/§1.4 and ch.03 §2 on the two missing rows  

> Görevler sekmesinde her kişi bir satırdır; satırda çalışabileceği alanlar işaretlenir. Bir kişiye birden fazla alan verilebilir. […] Araştırma (özellik kilidi) | Ürün · Tasarım · Yazılım | kilitli özellik açılır […] Maliyet/borç işi | Yazılım | servis maliyeti ↓, teknik borç ↓ […] Atanmamış kişi boşta durur ve maaş yer — "Boşta" rozeti.

The mechanic matches (multi-area assignment, empty array = derived Boşta, founder hard-locked to one via the 'founder_busy' refusal at character_registry.gd:224-227, per ch.02 §5) — but two of §4's SEVEN table rows are unreachable through this field. (a) `research` is in ASSIGNABLE (hr_constants.gd:139-140) and its own declaration says 'TÜKETİCİSİ YOK'; a repo-wide grep finds AREA_RESEARCH only in hr_constants and save_manager's key list, and hr_system.gd:112-115 skips it for experience — so assigning a person to Araştırma costs their capacity and unlocks nothing, while ProductCatalog's requires_research features (product_catalog.gd:59) stay locked. (b) 'Maliyet/borç işi' has NO id at all: ASSIGNABLE is the six areas plus research, so ch.06 §1.1's 'assign an engineer to cost optimisation' and §1.4's 'Paid down by assigning someone to it' have no assignable slot. hr_constants.gd:126-137 records the ruling that collapsed Build/Destek/Hesap/Maliyet, but the GDD text still legislates them.  
*Costs the player:* A person parked on Araştırma draws full salary, banks no experience, contributes to no formula and blocks nothing — a fully paid null assignment the UI presents as a real column.  
*If removed:* Everything. This array IS the assignment system: build crews (product_system.gd:352-445), sales capacity, CS coverage (hr_system.covering_heads), experience gain, overload, the lead derivation and build_bar's repaint all read it.  
*Chapter conflict:* ch.07 §4's table is headed 'İş' and lists seven jobs; the approved skin (hr_constants.gd:126-137) rules the unit is the AREA. Four job ids were retired against a GDD line that still names them.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:67-74` · `scripts/autoload/character_registry.gd:201-252` · `scripts/systems/hr_constants.gd:126-140` · `scripts/systems/hr_system.gd:110-115` · `GDD 07 rev 2 §4; GDD 06 §1.1, §1.4`


**`char.equity_pct` — Character.equity_pct**  
**DIVERGENT** · LOW — the divergent formula is behind a retired surface; the live risk is a latent unit collision on an ungoverned employee-equity channel.  
GDD: ch.02 §10; ch.09 §3 and §5  

> Net worth = equity % × last valuation (set at Frank, updated at Series A) — one line + all-time peak. […] Consequences of accepting: cash in, equity out, and a growth expectation the run is judged against.

One field, two units, and the only reader that used the field's own founder value is retired. game_state.gd:951 writes the founder 100.0 (percent); game_state.gd:569-575 get_founder_equity sums EMPLOYEE equity_pct as a 0..1 fraction and returns 1.0 − that, ignoring the founder's own record AND all investor dilution. That function has exactly ONE caller — right_panel.gd:266 — and RightPanel is retired (main.gd:1054, oda_view.gd:1241 'RightPanel emekli'; nothing instantiates RightPanel.tscn), so the founder's stored 100.0 has no live reader at all and endings_copy.gd:429 explicitly refuses get_founder_equity. The two LIVE surfaces agree with each other and with ch.09 (finance_ozet_view.gd:627-634 and personal_tab.gd:388-393 both compute 100 − investors − employees on the 0..1 contract). Employee equity is a live event-writable channel (event_manager.gd:616) that NO chapter authorises — hr_search_system.gd:205 and character.gd:44 say so by citing 'the HR design', i.e. the phantom doc, and finance_ozet_view.gd:619 notes the option pool does not exist in the engine.  
*Costs the player:* Nothing today (employees are always 0.0). The exposure is that one event modifier can write an unclamped employee equity in either unit and two surfaces will read it as a fraction.  
*If removed:* The two cap-table bars and personal_tab's net-worth line would lose their employee slice; founder % and net worth themselves come from GameState.run_angel_equity_pct / run_equity_pct and would be unaffected.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:951, :569-575` · `scripts/ui/components/right_panel.gd:266 (retired surface — main.gd:1054)` · `scripts/tabs/finance/finance_ozet_view.gd:627-634` · `scripts/tabs/personal_tab.gd:388-393` · `GDD 02 §10; GDD 09 §3`


**`char.morale` — Character.morale**  
**DIVERGENT** · HIGH — morale is binary in play (fine, or about to quit), so overtime and overload cost the player nothing measurable until someone resigns.  
GDD: ch.07 rev 2 §7 (Morale)  

> Düşük moral çıktıyı düşürür, sonra kaçma riski rozetine, sonra istifaya gider.

The three-step chain is implemented as TWO steps. Morale drives badges (hr_morale_system.gd:261-279) and the resignation clock (:124-145, :468-494) — but NOTHING reads morale as an output term. Verified by grep over the whole repo: `.morale` appears in character_registry, event_manager, game_state, main, run_probe and the HR/UI files only; product_system.gd, sales_rep_system.gd, customer_rep_system.gd, b2b_sales_system.gd and finance_system.gd never read it, and HRSystem.output_mult_for_area (hr_system.gd:235-247) multiplies only area_fatigue_mult × OVERLOAD_OUTPUT_MULT. HRMoraleSystem.average_morale() has exactly two callers: its own calm-stretch trigger (:198) and the Ekip header (hr_tab.gd:291). The GDD's other §7 clauses ARE honoured: the input list (fazla mesai, aşırı yüklenme, event'ler, lider Liderliği) is the real writer set, and there is no autonomous drift (hr_constants.gd:758).  
*Costs the player:* Nothing until 25. A team at morale 26 produces exactly as much as a team at 100; the only cost of neglect is the flight-risk window that starts at 25 and the 0.25/day resignation roll after 10 days under it.  
*If removed:* Load-bearing for departures only. Remove morale and the resignation channel, the two badges, the raise action's payoff, the three positive events and the annual-leave return bonus all die — but no production number would move.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:235-247 (output_mult_for_area reads no morale term)` · `scripts/systems/hr_morale_system.gd:261-279 (badges_for)` · `scripts/systems/hr_morale_system.gd:282-293 (average_morale — two callers, both display/trigger)` · `grep '\.morale' over scripts/ returns no hit in product_system.gd / sales_rep_system.gd / customer_rep_system.gd / b2b_sales_system.gd / finance_system.gd` · `GDD 07 rev 2 §7`


**`char.overload_days` — Character.overload_days**  
**DIVERGENT** · HIGH — overload is the GDD's designed reason to hire a second person, and its escalation to flight risk is missing.  
GDD: ch.07 rev 2 §5 (Aşırı yüklenme)  

> Hover metni oyuncuya durumu anlatır: bu çalışan birden fazla alanda çalışıyor; verimi düşer ve morali normalden hızlı erir. […] Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider.

The counter, the tolerance and the OUTPUT half are all correct: tick_overload counts active-only days (hr_system.gd:224-232), overload_bites trips past OVERLOAD_TOLERANCE_DAYS 5 (:153-156) and output_mult_for_area applies OVERLOAD_OUTPUT_MULT 0.75 (:245-246). The MORALE half does not exist. HRConstants.OVERLOAD_MORALE_MULT = 1.6 ('multiplier on NEGATIVE morale deltas', hr_constants.gd:146) has ZERO readers in the entire repo — a grep returns only its own declaration. hr_morale_system.gd contains no overload term at all (its only 'overload' hits, :271-278 and :328-334, are the unrelated needs_engineer capacity badge). So §5's second consequence — 'morali normalden hızlı erir', and therefore the whole path to 'kaçma riskine gider' — never fires from overload.  
*Costs the player:* 25% of one person's output in that area after five days. Zero morale. Since morale is also not an output term (see char.morale), stacking areas on one person is a mild, purely local production tax with no escalation.  
*If removed:* Only the 0.75 output multiplier and the row's AŞIRI YÜKLÜ chip (hr_ledger.gd:217, hr_assignments.gd:119, hr_tab.gd:533). Nothing else reads it.  
*Verification:* rload' hits are is_capacity_overloaded (:328-334) and its badge use (:271-278), both the unrelated needs_engineer flag. CORRECTION to breaks_if_removed: the AŞIRI YÜKLÜ chips at hr_ledger.gd:217, hr_assignments.gd:119 and hr_tab.gd:533 all read HRSystem.is_overloaded (hr_system.gd:149-150, `assigned_jobs.size() > 1`), NOT overload_days. The counter's ONLY reader in the entire repo is overload_bites (:153-156) → output_mult_for_area (:245-246). Delete the field and the chip is untouched; only the 0.75 multiplier dies. The field is even less load-bearing than the row says.  
Evidence: `scripts/systems/hr_constants.gd:142-147 (OVERLOAD_MORALE_MULT declared)` · `grep 'OVERLOAD_MORALE_MULT' over scripts/ returns only hr_constants.gd:146` · `scripts/systems/hr_system.gd:224-232, :153-156, :235-247` · `scripts/systems/hr_morale_system.gd:261-279 (no overload term)` · `GDD 07 rev 2 §5`


**`char.relationship` — Character.relationship**  
**DIVERGENT** · MEDIUM — reachable in normal play on two modals, purely presentational, and the stale 'reserved' header is exactly the trap M1 warns about.  
GDD: ch.01 §9 (non-negotiables); ch.14 §7 (event modal grammar)  

> TR canonical, EN literary; no dashes in copy. […] Event modal grammar is uniform: every event card shows a small circular avatar of its source — initials for employees (e.g. "MA" for Mert Aksoy), the portrait for Frank and for portrait-carrying characters.

No chapter defines a relationship stat for staff, and ch.14 §7 enumerates the event card's speaker strip as avatar + name; the code adds a fourth element that prints an internal English token as player-facing copy. event_modal.gd:263-264 calls UiTokens.relationship_palette(c.relationship) then UiFactory.make_pill(c.relationship, ...) — the RAW field value, with no tr() and no label table. Every registry-character event reaches it (event_modal.gd:247-248 routes any non-empty character_id to _render_registry_character), and both live HR events set one: hr_event_factory.gd:39 (resignation) and :54 (overtime valve). Since event_manager.gd:619 is the ONLY writer, every employee, the founder and Frank hold the default forever — so a Turkish build draws a pill reading 'neutral' on the two most consequential HR modals in the game. Confirms M1: character.gd:20-23 still lists this field as reserved.  
*Costs the player:* Nothing mechanically; it costs the fiction. The word 'neutral' appears untranslated on the resignation card in a TR-canonical build.  
*If removed:* Only the pill. No formula, no condition and no other surface reads the field; deleting the two lines at event_modal.gd:263-264 removes a player-visible language violation and changes no behaviour.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:20-23, :91` · `scripts/autoload/event_manager.gd:619` · `scripts/modals/event_modal.gd:253-266` · `scripts/systems/hr_event_factory.gd:39, :54` · `GDD 01 §9; GDD 14 §7`


**`char.traits` — Character.traits**  
**DIVERGENT** · MEDIUM — the founder's trait picks are a visible onboarding decision with no consequence, and the card can never show the second trait the GDD promises.  
GDD: ch.07 rev 2 §6 and §12; ch.02 §1 and §8  

> Aday kartı: rol uyum yıldızı + anahtar alan + varsa ikincil alan + 1–2 trait. […] Traits from the existing catalog (~12 positive / 12 negative), shown as icons. […] Modifiers only (skill, rate, probability, morale); never a hidden skill number; shown as icons with tooltips.

Three separate departures. (a) COUNT: TRAIT_COUNT = 1 and validate_employee_traits actively REJECTS a second (hr_constants.gd:547, :587-600, enforced at character_registry.gd:487-489) against §6's '1–2 trait'. (b) CATALOG SIZE: eight traits (hr_constants.gd:492-533), not ch.02 §1's ~24, and `polarity` was replaced by `carries_cost` (hr_constants.gd:466-478) so the positive/negative split ch.02 §1 names no longer exists. (c) FOUNDER: FounderConstants.TRAITS is a separate 8-entry catalog with a separate validator (founder_constants.gd:66-75, :188-210) and NONE of its ids appears in HRConstants.TRAITS, so every trait_mult over a founder returns 1.0 — the founder's traits modify nothing, against ch.02 §8's 'Modifiers only'. ch.07 §12 records this last one as a known open item: 'Kurucu trait'leri bugün çalışmıyor (kod kurucu trait'ini çalışan tablosunda arıyor) — dönülecek.' Employee traits themselves are fully wired to eleven real effects (experience, overtime morale, dept decay, departure morale, resign chance, build speed/output/bugs, sales, promise chance, satisfaction).  
*Costs the player:* Employee traits are a live pricing input (the generator puts the cost-bearing kind on roughly half the files). Founder traits cost the player an onboarding decision that buys nothing.  
*If removed:* Employee side is deeply load-bearing — eleven formulas across HR, Ürün, Satış and B2B read it. Founder side could be deleted today with zero behavioural change.  
*Chapter conflict:* ch.02 §1 specifies a ~12/12 positive-negative catalog; ch.07 §2 moves Uyum into traits and §6 caps the card at 1–2. The code implements eight traits, exactly one per employee, split by cost rather than polarity.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:492-547, :587-600` · `scripts/systems/founder_constants.gd:63-75, :188-210` · `scripts/autoload/character_registry.gd:487-489` · `scripts/autoload/event_manager.gd:621-631` · `GDD 07 rev 2 §6, §12; GDD 02 §1, §8`


**`state.area_leads` — GameState.area_leads**  
**DIVERGENT** · HIGH — Liderlik is the one skill the GDD hangs three separate team effects on, and the player has no lever over who carries it.  
GDD: ch.07 rev 2 §2 and §9  

> Liderlik: ekip lideri atanan çalışanın altındaki ekibin verimlilik modifier'ını, moral düşüş hızını ve deneyim kazanım hızını etkiler. […] Ayrılma bir event anıdır. […] 'Ekip lideri istifa etti, yerine kim geçiyor?' Kart oyuncuyu ilgili sayfaya yönlendirir (müşteri sahipliği için Satış, ekip için Ekip). Otomatik kurucuya devir varsayılan değildir.

§2's 'ekip lideri ATANAN çalışan' and §9's 'yerine kim geçiyor?' both presuppose a seat the player fills. No production code ever writes an entry: the only write in the repo is save_manager.gd:810's v4→v5 migration from a `job_leads` key that was never a GameState field in this codebase. release_area_leads (game_state.gd:600-608) and .clear() (:803) only erase. So HRSystem.area_lead's first branch (hr_system.gd:191-196) is dead in a fresh run and the lead is always DERIVED — highest Liderlik among that area's assignees, else the founder (:197-206). The declaration admits it at game_state.gd:252-253. §9's replacement question is therefore unaskable: the resignation event carries a single acknowledge choice (hr_event_factory.gd:39) and the seat silently re-derives.  
*Costs the player:* Nothing — and that is the defect. The lead is free and automatic, so ch.07 §2's leadership lever costs no decision.  
*If removed:* Nothing today. Delete the dictionary and area_lead falls straight through to the derived branch, which is the branch that actually runs. Its readers (experience_gain_mult at hr_system.gd:102, lead_experience_mult at :116-119, product_system.gd:504 coordination) never see the explicit path.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:245-254` · `scripts/systems/hr_system.gd:187-206` · `scripts/autoload/save_manager.gd:798-811` · `scripts/systems/hr_event_factory.gd:29-41` · `GDD 07 rev 2 §2, §9`


**`state.hr_overtime` — GameState.hr_overtime**  
**DIVERGENT** · HIGH — it is the largest single production lever in the module and the GDD legislates only its morale side effect.  
GDD: ch.07 rev 2 §7 (the only GDD line naming overtime); ch.02 §6  

> Girdiler: fazla mesai · aşırı yüklenme · başarı ve başarısızlık anları (sürüm çıktı, hesap kaybedildi, kesinti) · lider Liderliği · event'ler.

The GDD names 'fazla mesai' exactly once, as one of five MORALE INPUTS, and ch.02 §6 names it once more as a drain on the (unbuilt) founder energy bar. The code makes it a full department-level production system with four levers the GDD never grants it: +30%/+15% build speed (hr_constants.gd:1046-1048 → product_system.gd:718), ×1.25 bug rate on product_dev (:1050 → product_system.gd:977), a 40%-of-daily-salary cash accrual (:1053, see state.overtime_pay_statics) and a per-person safety-valve event with a permanent resignation penalty (see state.flag_valve_continued). Three block lengths [3,7,14] (:1030), tiered morale drops of 2/4/7 per day (:1055-1059). Its authority is the phantom doc: hr_overtime_system.gd:4 (§7b), :260, :270, :353 and hr_constants.gd:286, :1028 all cite an 'HR design doc §7b' that does not exist in the repo (M5). The morale half IS consistent with ch.07 §7; everything else is unlegislated.  
*Costs the player:* Real and stacked: OVERTIME_PAY_PCT 0.40 × daily salary per participant per night, 2-7 morale per person per day, and 25% more bugs in product_dev. Bought with a click on a department header.  
*If removed:* Load-bearing in three places: ProductSystem's speed and bug multipliers read it every tick (product_system.gd:718, :977), FinanceSystem pulls its accrual as burn slot 'overtime' (finance_system.gd:143), and hr_tab/oda_view render its running state.  
*Chapter conflict:* ch.07 §7 treats overtime purely as a morale input; ch.08 §1's burn equation has no overtime term. Neither chapter describes a block machine, its speed/bug levers or its valve event.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:296` · `scripts/systems/hr_overtime_system.gd:40-51, :162-181, :254-263` · `scripts/systems/hr_constants.gd:1026-1064` · `scripts/systems/product_system.gd:718, :977` · `GDD 07 rev 2 §7; GDD 02 §6`


**`state.overtime_pay_statics` — HROvertimeSystem._pay_today / _pay_stamped_day / _pay_carry**  
**DIVERGENT** · MEDIUM — the money is correct and visible at monthly close, but it is a burn category no chapter authorises, alongside two more (severance, hiring commission).  
GDD: ch.08 §1 (Burn); ch.07 rev 2 §10  

> burn = maaşlar + araçlar + servis maliyeti+ marketing plus one-off costs (Atlas retainer, eğitim, lisans, kesinti telafisi). […] Finance (08): maaşlar, retainer, eğitim, zamlar; kurucu maaşı yok, yaşam maliyeti yok.

ch.08 §1 states burn as a CLOSED equation and ch.07 §10 restates the HR→Finance list as maaşlar, retainer, eğitim, zamlar. The code publishes a fifth recurring burn category, 'overtime', pulled every day by FinanceSystem.daily_tick (finance_system.gd:143 ← hr_overtime_system.gd:308-313), accruing OVERTIME_PAY_PCT 0.40 × (monthly_salary / 30) per participant per night (hr_constants.gd:1064, hr_overtime_system.gd:134-138). The engineering around it is careful and self-documenting (the stamp is self-verifying against GameState.day, so the statics are deliberately excluded from the save at hr_system.gd:334-339, and _pay_carry exists because an early stop lands after Finance has already pulled) — the divergence is that the category exists at all. The same closed list also has no room for the severance charge (hr_actions.gd:190) or the 15% hiring commission (hr_search_system.gd:223).  
*Costs the player:* A real, invisible-until-monthly-close burn line. Three engineers on a 7-day block at $8K each costs roughly 3 × 107 × 7 ≈ $2,240 on top of payroll.  
*If removed:* FinanceSystem would read a permanent 0 for burn_breakdown['overtime'] and overtime would become free in cash while still costing morale — which is exactly the shape ch.11 §4's cost law forbids.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_overtime_system.gd:62-75, :79-86, :308-313` · `scripts/systems/finance_system.gd:143` · `scripts/systems/hr_constants.gd:1064` · `scripts/systems/hr_system.gd:333-339` · `GDD 08 §1; GDD 07 rev 2 §10`


**`state.pending` — HRMoraleSystem._pending (departure latch) and the departure moment it gates**  
**DIVERGENT** · HIGH — a departure is the module's most expensive event and it currently arrives as a notification, not as the decision ch.07 §9 specifies.  
GDD: ch.07 rev 2 §9 (Raises and departures)  

> Ayrılma bir event anıdır. Ayrılan kişinin işleri boşalır ve oyuncuya sorulur: "Melisa gitti, müşterilerine kim bakacak?" / "Ekip lideri istifa etti, yerine kim geçiyor?" Kart oyuncuyu ilgili sayfaya yönlendirir (müşteri sahipliği için Satış, ekip için Ekip). Otomatik kurucuya devir varsayılan değildir.

The latch itself is correct and load-bearing: it holds the once-only guard in the SYSTEM because enqueue() bypasses GameEvent.one_shot entirely (hr_event_factory.gd:10-14), and without it the 0.25/day roll would re-fire daily and silently inflate the real odds. But the moment it gates does not ask the GDD's question. build_resignation (hr_event_factory.gd:29-41) is a one-line farewell with a SINGLE choice whose only modifier is `hr_departure`; the areas then vacate silently (character_registry.gd:545 clears assigned_jobs, game_state.gd:600-608 erases any lead seat) and no card routes the player to Satış or Ekip. §9's 'Bilgi kaybı / teknik borç cezası yok' IS honoured, and SEVERANCE_ON_RESIGN 0 matches 'no payout on a quit'.  
*Costs the player:* The whole person, with no decision attached: one acknowledge button, their assignments emptied, their accounts unowned, and no prompt telling the player any of it happened.  
*If removed:* Delete _pending and the same employee re-rolls a resignation every single day while the queued event sits unread — the RESIGN_CHANCE_PER_DAY contract collapses. It is genuinely load-bearing; the divergence is in the event, not the latch.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_morale_system.gd:67-72` · `scripts/systems/hr_morale_system.gd:468-494` · `scripts/systems/hr_event_factory.gd:29-41` · `scripts/autoload/character_registry.gd:530-548` · `GDD 07 rev 2 §9`


**`cand.axes` — candidate["axes"]**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 and §2  
Built by walking AREAS so the result always satisfies the registry key-lock whatever BAND_SHAPE looks like (hr_candidate_generator.gd:177-224). The band shape is read BY MEANING, not by position (:178-184): shape[0] → the role's KEY area, shape[1] → SECONDARY, shape[2] → every other area — which is what stops a rotation putting a Designer's peak in Satış. §2's 'tek kişilik ekipte boşluk kalmaz' is produced deliberately: candidate k gets +1 on the k'th off-role area (:215-217) so the three files differ qualitatively, not only in price. Liderlik comes from the shape floor as rest_v - 1 + rotation (:222-223), NOT from the role, so 'a candidate who happens to lead well is a find, not a job description' — consistent with §2 putting Liderlik on everyone. Re-validated at :113-114 and again on add (character_registry.gd:484-486).  
Evidence: `scripts/systems/hr_candidate_generator.gd:112-114, :177-224` · `scripts/systems/hr_constants.gd:677-686` · `scripts/systems/hr_search_system.gd:412-421` · `GDD 07 rev 2 §2, §6`


**`cand.band` — candidate["band"]**  
**GOVERNED**  
GDD: ch.07 rev 2 §6  
The band as a player decision is governed and live — it selects SALARY_BANDS and BAND_SHAPE inside generate(), and hr_constants.gd:632 states the design rule that it is three DISCRETE options rather than a slider. What is dead is the COPY stored on each file: hr_search_system.gd:357-358 puts it into preview_hire as `band` and `band_label` and neither key is consumed — hr_atlas_modal reads only warnings, affordable, commission, runway_before and runway_after (:249-250, :366-383), taking its own band label from _selected_band (:219/:246). The waiting strip deliberately omits it (hr_tab.gd:328-330: 'Bant oyuncunun verilmiş kararı, burada tekrarlanmaz'), which is also why HRSearchSystem.current_band() (:122-123) has zero callers.  
Evidence: `scripts/systems/hr_candidate_generator.gd:122` · `scripts/systems/hr_search_system.gd:355-358, :122-123` · `scripts/tabs/hr_tab.gd:328-337` · `scripts/systems/hr_constants.gd:632-637` · `GDD 07 rev 2 §6`


**`cand.name` — candidate["name"]**  
**GOVERNED**  
GDD: ch.14 §7; ch.07 rev 2 §6  
First + last, deduplicated across the batch of three via _take_unused (hr_candidate_generator.gd:360-372) drawing from HRConstants.FIRST_NAMES and LAST_NAMES with distinct salts (SALT_FIRST_NAME 11 / SALT_LAST_NAME 23) so the surname is not tied to the first name. Read by hr_atlas_modal.gd:318 (initials) and :322 (label), copied into preview_hire (:359) and into Character.character_name on hire (hr_search_system.gd:201). An exhausted pool returns '' (:372), so a broken name pool yields a blank-named candidate rather than a crash. The generation and dedup rules themselves are unlegislated; the GDD governs only that employees are known by name and initials.  
Evidence: `scripts/systems/hr_candidate_generator.gd:115-120, :360-372` · `scripts/tabs/hr/hr_atlas_modal.gd:318-322` · `scripts/systems/hr_search_system.gd:201` · `GDD 14 §7`


**`cand.salary` — candidate["salary"]**  
**GOVERNED**  
GDD: ch.07 rev 2 §6  
A narrow centred window inside role × band, priced off the profile so a strictly better file always costs strictly more — which is the arithmetic that keeps the set non-dominated (hr_candidate_generator.gd:229-291: window from _salary_window with SALARY_SPREAD_MAX 0.15, premium from _shape_premium with SALARY_PEAK_PREMIUM 0.10, rounded to SALARY_ROUND_TO 50). No negotiation path exists anywhere, matching §6. NOTE for the ledger, not a verdict change: the hire charges a SECOND fee the GDD does not name — SEARCH_COMMISSION_PCT 0.15 of the first month's salary at hr_search_system.gd:223, whose only stated authority is 'Çift ücret (design doc §2, KANON)' at hr_constants.gd:704, and ch.08 §1's one-off list is 'Atlas retainer, eğitim, lisans, kesinti telafisi'.  
Evidence: `scripts/systems/hr_candidate_generator.gd:124, :229-291` · `scripts/systems/hr_search_system.gd:194-223` · `scripts/systems/hr_constants.gd:704-711, :753-761` · `GDD 07 rev 2 §6; GDD 08 §1`


**`cand.shape` — Candidate file — the dictionary shape**  
**GOVERNED**  
GDD: ch.07 rev 2 §6; ch.02 §9  
Candidates are NOT Characters: seven-key transient Dictionaries produced by a PURE function of (role, band, seed) (hr_candidate_generator.gd:88-140), stored in GameState.hr_search['files'] and destroyed by _clear() on hire, dismiss or cancel. CANDIDATE_COUNT 3 matches §6. No RNG at all (:30-35) — every varying field is integer arithmetic on the stored seed, so a mid-search reload cannot reshuffle a table the player was already considering. The 'mühürlü akış' is additionally protected by a post-condition: is_non_dominated_set push_errors if any file is >= on every axis AND <= on price (:143-158), non-blocking, which is what keeps the three files a real choice rather than a ranking. §6's 'Mülakat yok' is honoured by construction — there is no interview step anywhere in the flow.  
*Chapter conflict:* ch.02 §9 requires an interview costing founder time ('Interview (costs founder time): exact 1+2 + 1–2 traits'); ch.07 rev 2 §6, approved one day later, states 'Mülakat yok.' The code follows ch.07. ch.02 §9's three-stage reveal (approximate on the shortlist, exact after interview) is therefore also overridden — the Atlas card shows exact numbers immediately.  
Evidence: `scripts/systems/hr_candidate_generator.gd:30-40, :88-158` · `scripts/systems/hr_search_system.gd:377-399, :95-102` · `scripts/systems/hr_constants.gd:712-714` · `GDD 07 rev 2 §6; GDD 02 §9`


**`char.area_experience` — Character.area_experience**  
**GOVERNED**  
GDD: ch.07 rev 2 §8; ch.02 §7  
Per-area counters {area_id: 0..EXPERIENCE_MAX 100}; filling grants +1 in that area and resets (character_registry.gd:96-123). Both §8 clauses are implemented: growth follows the ASSIGNMENT (a per-area dict specifically so someone alternating two areas does not bank one pool, character.gd:77-84), and the lead's Liderlik raises the rate through HRConstants.experience_gain_mult (hr_system.gd:102, :120-122, gain = base × lead_mult × load_mult × own_mult × mentor_mult, floored at 1). ch.02 §7's tertiary 'mentoring' is folded in per ch.07 §2's ruling that mentorship lives inside Liderlik — the area lead's lead_experience_mult trait applies to everyone in that area including the carrier (:116-119). Guards: non-AREAS keys are rejected (:103-104) so Liderlik and `research` never bank experience, and a capped area pins at EXPERIENCE_MAX and banks nothing (:117). The founder joins the loop as a …  
Evidence: `scripts/autoload/character_registry.gd:96-123, :434-454` · `scripts/systems/hr_system.gd:89-122` · `scripts/systems/hr_constants.gd:805-812` · `scripts/tabs/hr/hr_ledger.gd:262-278` · `GDD 07 rev 2 §8; GDD 02 §7`


**`char.category` — Character.category**  
**GOVERNED**  
GDD: ch.07 rev 2 §3; ch.02 §5; ch.09 §1  
The founder/employee/mentor split the three chapters require is carried by this one String, and every HR gate is a category test rather than a role test — who draws salary (character_registry.gd:412-421), who can be fired or raised (hr_actions.gd:212-218: 'FRANK VE KURUCU DOKUNULMAZ'), whose morale moves (hr_morale_system.gd:213-218), who appears on the Ekip page, who participates in overtime (hr_overtime_system.gd:290-293 screams if a non-employee reaches the roster). The declared fourth value 'npc' is written NOWHERE in the repo. There is no enum validator: _validate_shape branches on the value (character_registry.gd:480, :490) and never rejects an unknown one, so an authored event writing an unknown category would fall through both branches silently.  
Evidence: `scripts/data_models/character.gd:32` · `scripts/autoload/character_registry.gd:434, :480-490` · `scripts/systems/hr_actions.gd:212-218` · `scripts/systems/hr_overtime_system.gd:290-293` · `GDD 07 rev 2 §3; GDD 02 §5; GDD 09 §1`


**`char.character_name` — Character.character_name**  
**GOVERNED**  
GDD: ch.14 §7; ch.02 §1; ch.07 rev 2 §9  
The player-facing name everywhere a person is drawn — ledger, assignment matrix, training modal, event modal speaker strip, ODA, creation flow, sales tab, and the two HR ticker lines. Named character_name rather than name to dodge Node.name (TECH_SPEC §7). For the FOUNDER it is only a fallback: GameState.founder_name is read first at personal_tab.gd:160-162, and game_state.gd:943 falls back to tr('HR_ROLE_FOUNDER') when onboarding leaves it blank. Generated names come from FIRST_NAMES/LAST_NAMES with distinct salts so the surname is not tied to the first name, deduped inside a batch (hr_candidate_generator.gd:115-120, :360-372); an exhausted pool yields '' rather than a crash. No validator anywhere.  
Evidence: `scripts/data_models/character.gd:30` · `scripts/autoload/game_state.gd:938-947` · `scripts/tabs/personal_tab.gd:160-162` · `scripts/systems/hr_candidate_generator.gd:115-120, :360-372` · `GDD 14 §7; GDD 02 §1`


**`char.flight_risk_days` — Character.flight_risk_days**  
**GOVERNED**  
GDD: ch.07 rev 2 §7  
The clock between §7's second and third step. Incremented daily under MORALE_FLIGHT_RISK 25 and reset when morale recovers (hr_morale_system.gd:137-144). Deliberately FREEZES rather than resets while on leave — tick_thresholds skips anyone ON_LEAVE (:130-135) — so neglect cannot be laundered by a holiday, the same grammar as tick_overload. Read only by the resignation roll: <=0 returns, <RESIGN_WINDOW_MIN_DAYS 10 no roll, >=RESIGN_WINDOW_MAX_DAYS 14 forces chance to 1.0 (:475-483). The boundary comparison lives in ONE place (HRConstants.is_flight_risk, :879-880) so the counter, the badge and the overtime valve cannot disagree about it. Never displayed — the player sees the derived KAÇMA RİSKİ badge, never the day count, which matches §5's 'Sayı gösterilmez; rozet ve hover açıklaması yeterlidir' grammar.  
Evidence: `scripts/data_models/character.gd:64` · `scripts/systems/hr_morale_system.gd:124-145, :468-494` · `scripts/systems/hr_constants.gd:953-956, :875-880` · `GDD 07 rev 2 §7`


**`char.keylock` — THE KEY-LOCK (CharacterRegistry._validate_shape)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2  
The validator is that sentence expressed as code (character_registry.gd:466-509, called from add() at :433 and insert_raw() at :526). :477-479 is a retired-key tripwire over RETIRED_SKILL_KEYS ['expertise','pace','rapport'] (hr_constants.gd:66) — i.e. §2's deleted Hız screams instead of loading as a dropped key. :480-489 enforces the employee 7; :490-497 enforces the founder 8; :498-509 checks assignment shape for everyone including the founder's one-area cap (ch.02 §5). Non-blocking by design: the record still lands and the log carries the defect. The lock exists because a mismatch would otherwise be SILENT — get_founder_skill returns 0 for an unknown key (game_state.gd:611-621) and SaveCodec drops unknown keys by design (character_registry.gd:474-476).  
Evidence: `scripts/autoload/character_registry.gd:466-509, :433, :526` · `scripts/systems/hr_constants.gd:61-109` · `scripts/systems/founder_constants.gd:36-40` · `GDD 07 rev 2 §2`


**`char.monthly_salary` — Character.monthly_salary**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 and §10; ch.08 §1  
Bands are literally role × tier (SALARY_BANDS, hr_constants.gd:645-676, narrowed to a centred window at hr_candidate_generator.gd:237-258). The founder and the mentor are hard-zero (game_state.gd:950, character_registry.gd:403/:619), matching 'kurucu maaşı yok'. Finance PULLS rather than HR pushing: get_total_monthly_salaries (character_registry.gd:412-421) → finance_system.gd:137, converted to a daily figure by DAYS_PER_MONTH. The pull is deliberately NOT status-filtered because annual leave is paid — an ungoverned rule inherited from the phantom doc (:414). CharacterRegistry.set_salary is the only sanctioned write seam and emits NO SIGNAL (:560-572, the omission documented at :564-567), which hr_tab.gd:807-809 compensates for by forcing a rebuild after a raise.  
Evidence: `scripts/systems/hr_constants.gd:645-676` · `scripts/autoload/character_registry.gd:412-421, :560-572` · `scripts/systems/finance_system.gd:137` · `scripts/autoload/game_state.gd:950` · `GDD 07 rev 2 §6, §10; GDD 08 §1`


**`char.portrait_path` — Character.portrait_path**  
**GOVERNED**  
GDD: ch.14 §7 (Portrait policy, revised 2026-08-20)  
Implemented exactly, and the empty case is the DESIGNED case — character.gd:33-37 cites this GDD section in place. Written only for the mentor (character_registry.gd:406 and :620, both = MENTOR_PORTRAIT); nothing writes it for an employee (hire() at hr_search_system.gd:196-209 does not touch it, add_character reads no such key, _build_founder leaves it default). Exactly one reader: event_modal.gd:259 → _make_avatar (:294-310), which loads a texture only if the path is non-empty AND ResourceLoader.exists, otherwise drawing initials. The founder is an intentional bypass: his portrait lives in GameState.founder_portrait, resolved via FounderConstants.portrait_path at personal_tab.gd:224-226, which documents the bypass in place.  
Evidence: `scripts/data_models/character.gd:33-38` · `scripts/autoload/character_registry.gd:406` · `scripts/modals/event_modal.gd:259, :294-310` · `scripts/tabs/personal_tab.gd:224-226` · `GDD 14 §7`


**`char.role` — Character.role**  
**GOVERNED**  
GDD: ch.07 rev 2 §1 and §2  
EMPLOYEE_ROLES is exactly the six §1 roles (hr_constants.gd:248-258), plus ROLE_FOUNDER and ROLE_MENTOR which are never employees. §2's 'roles are titles' is implemented literally: role stores no numbers and derives department, section, key+secondary area (ROLE_AREAS, :117-124), salary band, assignment eligibility and every label. The key+secondary shape follows §2's two verbatim examples (Product Manager → Ürün/Tasarım, Software Engineer → Yazılım/Test); the other four rows are the symmetric completion. _validate_shape push_errors a non-employee role on an 'employee' but does not block the insert (character_registry.gd:481-483), and event_manager.gd:611-613 defaults an omitted role to ROLE_DEVELOPER. Documented namespace collision at hr_constants.gd:68-70: 'sales' is simultaneously an area id, a department id and a group id, with ROLE_SALES_REP a fourth thing.  
Evidence: `scripts/systems/hr_constants.gd:248-258, :117-124, :68-70` · `scripts/autoload/character_registry.gd:480-483` · `scripts/autoload/event_manager.gd:611-613` · `GDD 07 rev 2 §1, §2`


**`char.role_stats` — Character.role_stats**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 and §3  
Exact match. AREAS is the six §2 ids (hr_constants.gd:37), EMPLOYEE_SKILL_KEYS adds leadership (:43-44), FounderConstants.SKILLS adds charisma (:36-37). §3's display rule is enforced structurally: hr_ui_shared.area_stars_row (:38-51) draws ONLY the role's key and secondary area, so four of an employee's six numbers are never shown on a row. The ruler follows ch.02 §3 exactly — AREA_MIN 0 / AREA_MAX 10 with STAR_MAX 5 and POINTS_PER_STAR 2 (hr_constants.gd:46-59), i.e. '0–10 → 0–5★' at half-star resolution. Two growth channels write it in place: add_area_experience +1 capped at AREA_MAX (character_registry.gd:120) and tick_training +1 capped at AREA_TRAIN_CAP 8 (:191).  
Evidence: `scripts/systems/hr_constants.gd:32-59` · `scripts/systems/founder_constants.gd:36-37` · `scripts/tabs/hr/hr_ui_shared.gd:38-51` · `scripts/autoload/character_registry.gd:96-123, :188-198` · `GDD 07 rev 2 §2, §3; GDD 02 §3`


**`char.status` — Character.status**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 (Training) — for two of the three values  
STATUS_ACTIVE and STATUS_TRAINING implement §8 exactly: begin_training sets the status (character_registry.gd:174), tick_training restores it (:195), and get_active_employees (:79) is the lens every capacity formula uses, so a trainee is out of build crews, sales, CS and overtime for the full TRAINING_DAYS 14. The THIRD value, STATUS_ON_LEAVE, serves the entirely ungoverned annual-leave subsystem (see char.leave_month) — hr_constants.gd:798-802 explains why it cannot be folded into training: sharing a value would misfire the annual-leave latch and the leave-return morale reward. set_status validates against the three constants and push_errors on anything else (:583-586) but emits NO signal, and two writers bypass it entirely (:174, :195 — the training owner, deliberately) plus main.gd:1849-1851 (debug fixture writing status on EVERY registry character). Name collision worth recording: …  
Evidence: `scripts/data_models/character.gd:59` · `scripts/autoload/character_registry.gd:575-587, :164-198, :79` · `scripts/systems/hr_constants.gd:795-802` · `scripts/main/main.gd:1849-1851` · `GDD 07 rev 2 §8`


**`char.training_area` — Character.training_area**  
**GOVERNED**  
GDD: ch.07 rev 2 §8  
The player's choice, stored. Written by begin_training behind an is_trainable_key guard that push_errors an untrainable target (character_registry.gd:169-173), consumed at completion (:188-193: +1 capped at AREA_TRAIN_CAP 8, trainings_done bumped, that area's experience zeroed), then cleared. The trainable set is the six areas plus Liderlik, with Karizma deliberately excluded (hr_constants.gd:840-850) — consistent with §8 saying 'alan'. UI GAP, worth recording though §8 does not require a readout: once the modal closes nothing names the area under training — hr_ledger.gd:313-316 and hr_assignments.gd:113-116 render only the day count, so for fourteen days the player can see that someone is training but not at what.  
Evidence: `scripts/data_models/character.gd:87` · `scripts/autoload/character_registry.gd:164-198` · `scripts/systems/hr_constants.gd:840-850` · `scripts/tabs/hr/hr_ledger.gd:313-316` · `GDD 07 rev 2 §8`


**`char.training_days_left` — Character.training_days_left**  
**GOVERNED**  
GDD: ch.07 rev 2 §8  
TRAINING_DAYS = 14 with the GDD line quoted at the constant (hr_constants.gd:813, '(5 idi)' recording the correction). Set by begin_training (character_registry.gd:172), decremented by tick_training (:184), and >0 makes the person passive through STATUS_TRAINING. Signalled properly (employee_training_changed at :175/:186/:196 → hr_tab.gd:75, personal_tab.gd:34, build_bar.gd:84) and rendered as the amber 'EĞİTİMDE · N gün' chip (hr_ledger.gd:313-316, hr_assignments.gd:113-116). Tick order is load-bearing and reasoned in place: tick_experience runs BEFORE tick_training (hr_system.gd:56-61), because the reverse lets the completion-day reset be immediately re-credited.  
Evidence: `scripts/data_models/character.gd:86` · `scripts/autoload/character_registry.gd:164-198` · `scripts/systems/hr_constants.gd:813` · `scripts/systems/hr_system.gd:54-61, :264-285` · `GDD 07 rev 2 §8`


**`char.trainings_done` — Character.trainings_done**  
**GOVERNED**  
GDD: ch.07 rev 2 §8; ch.02 §7  
One writer (character_registry.gd:192, on completion) and one reader (:158-159 → HRConstants.training_fee, hr_constants.gd:829-837), where repeat = 1.0 + trainings_done × TRAINING_REPEAT_SURCHARGE 0.35 on top of the tiered base (TRAINING_FEE 500 + current value × TRAINING_FEE_PER_POINT 220). Both §8 clauses are paid through the single fee channel, argued in place at hr_constants.gd:823-827: the GRANT stays +1 because an integer ruler reads no other way, so what diminishes is the price of that same +1. ch.02 §7's '+1 in one skill; diminishing on repeat' supports that reading. Surfaces at training_modal.gd:203-205, charged at hr_system.gd:297-301. Never displayed as a count.  
Evidence: `scripts/autoload/character_registry.gd:188-192, :153-159` · `scripts/systems/hr_constants.gd:823-837` · `scripts/systems/hr_system.gd:297-301` · `GDD 07 rev 2 §8; GDD 02 §7`


**`founder.charisma` — role_stats["charisma"] — the founder-only key**  
**GOVERNED**  
GDD: ch.02 §4; ch.07 rev 2 §2; ch.09 §4  
Founder-only as §2 requires (absent from EMPLOYEE_SKILL_KEYS), and read only by the funding layer — pitch_constants.gd:62-65 (BEAT1/BEAT3/BEAT4_PUSH/ANGLE 'vizyon') and :101 LEVER_SKILL {dilution, board}, resolved through SkillCheck → GameState.get_founder_skill. No HR-module code reads it. Two structural notes: it is UNGROWABLE after onboarding — is_trainable_key excludes it (hr_constants.gd:849-850, matching §8's 'alan' wording and the approved training table) and add_area_experience rejects non-AREAS keys (character_registry.gd:103-104) — so it is frozen at 0..ONBOARDING_CAP 3 on a 0-10 ruler for the whole run. And ch.02 §4's second half ('scandal/PR outcomes; crisis events read Karizma', restated as a ripple at ch.02 §11) has no reader on the event side; that is a chapter-11 boundary, recorded not audited.  
Evidence: `scripts/systems/founder_constants.gd:38, :43-56` · `scripts/systems/hr_constants.gd:840-850` · `scripts/autoload/character_registry.gd:169-173, :103-104` · `scripts/systems/pitch_constants.gd:62-65, :101` · `GDD 02 §4, §11; GDD 09 §4`


**`founder.identity_outside` — Founder identity living OUTSIDE Character**  
**GOVERNED**  
GDD: ch.02 §1; ch.01 §8; ch.12 §5  
The DATA the GDD requires exists; the GDD is indifferent to where it lives, and it lives in GameState rather than on the Character. founder_name (game_state.gd:26) WINS over Character.character_name at personal_tab.gd:160-162; founder_portrait (:27) is resolved via FounderConstants.portrait_path at personal_tab.gd:224-226, which documents that Character.portrait_path is deliberately not used; origin (:22) is read at personal_tab.gd:123-125. ch.01 §8's Self-Made-only lock and ch.02 §1's locked-visible others are content gates, and the origin correctly carries no mechanical effect — but the code declares reserved_flags that go further than nothing: initialize_run SETS them (game_state.gd:840-841) and origin_press_sympathy / origin_low_capital are declared in FLAG_TYPES (:127-128) with no reader anywhere, which founder_constants.gd:81-82 states in place.  
Evidence: `scripts/autoload/game_state.gd:22-27, :127-128, :840-841` · `scripts/tabs/personal_tab.gd:123-125, :160-162, :224-226` · `scripts/systems/founder_constants.gd:81-92` · `GDD 02 §1; GDD 01 §8`


**`founder.shape` — Founder shape — FounderConstants.SKILLS (8 keys) vs employee (7)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 and §3; ch.02 §5  
Eight keys = the employee seven plus charisma (founder_constants.gd:36-37), built at game_state.gd:945-973 and inserted through CharacterRegistry.add. §3's separation holds: the founder is filtered out of the Ekip roster and carried by personal_tab. ch.02 §5's one-job hard lock is enforced at the assignment seam ('founder_busy', character_registry.gd:224-227), and the starting area is the highest of product/design/engineering with a deterministic tie-break (game_state.gd:555-566). ASYMMETRIES with employees, all deliberate: no salary, no leave, no morale mechanic, no badges, no portrait_path, no hire_day, and no seeded area_experience keys — add() seeds those only inside its employee branch (:434, :448-457). TWO UNENFORCED CONSTANTS worth the balance pass: FounderConstants.SKILL_CEILING 5 (:54) is enforced NOWHERE after onboarding — training raises him to AREA_TRAIN_CAP 8 and experience …  
*Chapter conflict:* ch.02 §1/§4 gives the founder TWO founder-only numbers (Liderlik + Karizma); ch.07 rev 2 §2 moves Liderlik onto everyone and leaves only Karizma founder-only. The code follows ch.07.  
Evidence: `scripts/autoload/game_state.gd:945-973, :555-566` · `scripts/systems/founder_constants.gd:36-56` · `scripts/autoload/character_registry.gd:434-457, :224-227` · `GDD 07 rev 2 §2, §3; GDD 02 §5`


**`state.hr_search` — GameState.hr_search**  
**GOVERNED**  
GDD: ch.07 rev 2 §6; ch.02 §9  
The whole hiring state machine in one Dictionary: idle → searching → files_ready → (hire|dismiss) → idle, where an EMPTY dict IS idle so .clear() is a complete reset. Every §6 number matches: SEARCH_RETAINER 600 charged once up front, arrival_day = day + SEARCH_ARRIVAL_MIN_DAYS 2..MAX 4 DERIVED rather than rolled (hr_search_system.gd:402-409), CANDIDATE_COUNT 3. Persistence is by the stored SEED, not the files (:144-147), so a mid-search reload returns the same three people. One rule inside it has phantom-only authority: the retainer is NOT refunded on cancel (:157, :164, cited to 'design doc §2') — ch.07 §6 says only that a retainer is paid. No signal exists (hr_tab.gd:636 notes hr_search_state_changed does not exist), so the modal notifies the tab by hand.  
Evidence: `scripts/autoload/game_state.gd:295` · `scripts/systems/hr_search_system.gd:34-42, :144-160, :377-409` · `scripts/systems/hr_constants.gd:710-714, :747-750` · `GDD 07 rev 2 §6; GDD 02 §9`


---

### Appendix C — Automatic behaviour (pass 1c)

65 entries, ungoverned first.


**`auto.leave_departure` — Annual leave — employee leaves automatically when their month arrives**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — real when it fires (a build head or an account owner vanishes with only a ticker line), but sparse: day 1 is 1 Jan 2026 and with LEAVE_MONTH_MIN_GAP 2 a January-hired roster only reaches …  
NO GDD CHAPTER MENTIONS LEAVE AT ALL — a full-corpus search for izin / tatil / yıllık / leave returns zero hits outside ch.02 §6's founder 'rest'. The code's governing citation is the non-existent HR design doc §8, cited at hr_morale_system.gd:104 ('İzin ayı geldiğinde çalışan OTOMATİK izne çıkar, oyuncu onayı istenmez (design doc §8)'), :375, character_registry.gd:324 and :414, hr_overtime_system.gd:270, product_system.gd:239 and b2b_sales_system.gd:95 — seven files across four modules take a behaviour from a document that does not exist. tick_leave_departures sends any ACTIVE employee on LEAVE_DAYS 7 the first day of their leave month with no approval and no modal; STATUS_TRAINING employees are skipped and silently forfeit that year's leave with nothing re-queuing it (hr_morale_system.gd:103-121).  
*Costs the player:* 7 days of that person's output while their salary keeps flowing — roughly 7/30 of a monthly salary for zero work — plus, for a CS rep, the immediate release of their entire account book and the loss of satisfaction dampening on every account they held  
*If removed:* the +10 return bonus, the leave-aware exclusions in four other modules (build capacity at product_system.gd:239, engineer capacity at character_registry.gd:324, overtime participants, CS expertise) all become dead branches; nothing else depends on it, so the subsystem is self-contained but deeply wired  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `Full-corpus check: zero hits for izin/tatil/yıllık/leave across all 13 GDD chapters` · `M5 phantom citations: scripts/systems/hr_morale_system.gd:104, :375; scripts/autoload/character_registry.gd:324, :414; scripts/systems/hr_overtime_system.gd:270; scripts/systems/product_system.gd:239; scripts/systems/b2b_sales_system.gd:95` · `scripts/systems/hr_morale_system.gd:103-121, :358-380` · `scripts/systems/hr_constants.gd:967-989` · `scripts/autoload/game_state.gd:13`


**`auto.leave_month_assign` — Annual-leave month stamped automatically at hire**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — it is the seed of every leave event, and the deterministic stride is what makes leave reachable at all inside a short run  
CharacterRegistry.add stamps leave_month for every category=='employee' record that arrives without one, via HRConstants.leave_month_for(hire_month, hire_ordinal): offset = LEAVE_MONTH_MIN_GAP 2 + (LEAVE_MONTH_STRIDE 7 × hire_ordinal) % 10, wrapped onto (hire_month-1+offset)%12+1, where hire_ordinal is GameState.run_hires before the increment (character_registry.gd:434-461, hr_constants.gd:979-989). The player is never asked and never sees the choice. The same block stamps hire_day = today, which HRSearchSystem.hire then deliberately re-stamps to day+1 so a hire starts the next day (hr_search_system.gd:217-221). No GDD line anywhere; the leave subsystem is cited to the phantom design doc §8.  
*Costs the player:* nothing at hire; it silently commits 7 paid absent days at a date the player never chose and cannot see being chosen  
*If removed:* tick_leave_departures would never match any month, so the whole leave subsystem would go dark — no absences, no return bonus, no CS book release  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `M5: the leave subsystem's governing citation is the non-existent HR design doc §8 (scripts/systems/hr_morale_system.gd:4, :104)` · `scripts/autoload/character_registry.gd:434-461` · `scripts/systems/hr_constants.gd:979-989` · `scripts/systems/hr_search_system.gd:217-221`


**`auto.leave_return` — Leave return — status flip + morale credit, first step of the HR day**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — it is one of only three automatic upward morale movements that can actually fire, but it is gated on the same sparse leave calendar  
tick_leave_returns runs first so the restored `active` is what the rest of the day reads: it flips status, clears leave_until_day, clears the manual-vacation flag, applies +MORALE_LEAVE_RETURN 10 scaled by the founder's Liderlik climate gain (cap ×1.50) and clamped at 100, and emits a ticker headline (hr_morale_system.gd:79-100). No GDD line; cited to the phantom design doc §7/§8. The was_manual +20 branch is dead (auto.vacation_return_dead).  
*Costs the player:* nothing — it is a +10 morale gift on the return day  
*If removed:* anyone sent on leave would stay STATUS_ON_LEAVE forever: out of capacity, out of overtime, unable to be assigned (assign_area refuses non-ACTIVE), and permanently frozen on the flight-risk counter. This is the single most load-bearing line of the leave subsystem  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `M5 phantom citations: scripts/systems/hr_morale_system.gd:4 ("yıllık izin (§8)"), :92` · `scripts/systems/hr_morale_system.gd:79-100` · `scripts/systems/hr_constants.gd:768-769, :911-913`


**`auto.overtime_autoend` — Overtime block ends itself on the final night**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — a safety property rather than a felt beat, but it is the only thing bounding the module's largest cost  
After _charge_day, _tick_department compares day_index against _block_length and calls _end_block(dept, was_stopped=false), erasing the record, zeroing every department member's overtime_days over get_employees() (not participants(), so an on-leave member cannot carry a stale count into the next block) and emitting a non-modal ticker line (hr_overtime_system.gd:104-107, :425-457). Block lengths are HRConstants.OVERTIME_BLOCKS [3, 7, 14] (:1030) — cited to the phantom design doc §7b (hr_constants.gd:1028). Today's pay stamp is deliberately NOT cleared here because Finance pulls it two slots later; clearing on end would work the final night for free. No GDD line describes overtime blocks, their lengths, or a self-terminating block.  
*Costs the player:* nothing — it is the mechanism that STOPS the morale and cash drain  
*If removed:* a started block would run forever: unbounded morale drain at the day-8+ rate of 7/night, unbounded 40% pay, and the escalating drop ladder with no upper edge  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `M5 phantom citations: scripts/systems/hr_overtime_system.gd:4; scripts/systems/hr_constants.gd:1028 ("Üç blok; departman başlığından başlatılır ... (design doc §7b)")` · `scripts/systems/hr_overtime_system.gd:104-107, :425-457` · `scripts/systems/hr_constants.gd:1030`


**`auto.overtime_coupling_boundary` — BOUNDARY · Overtime's speed and bug multipliers are consumed hourly, not daily**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — it is the single largest player-controlled multiplier on the game's central bar, and the asymmetry (benefit consumed hourly, cost billed daily) is what made same-day start/stop free until …  
HROvertimeSystem owns speed_multiplier/bug_multiplier as state and applies neither (hr_overtime_system.gd:235-265). ProductSystem._tick_build_hourly reads the product_dev speed multiplier up to 24× a day (product_system.gd:713-720, whose comment cites 'design doc §7b'); _accrue_bugs_hourly reads bug_multiplier (:973-982); the two desks read their own departments' daily. Speed = 1 + overtime_speed_bonus(day_index) → +30% for day_index 0..7, +15% from 8; bugs ×OVERTIME_BUG_MULT 1.25, product_dev only. NO GDD LINE exists for an overtime speed bonus or an overtime bug penalty — ch.07 §7 names 'fazla mesai' only as a morale input, and no chapter grants overtime an output effect. The code's governing citation is the non-existent HR design doc §7b (M5).  
*Costs the player:* morale (−2/−4/−7 per participant per night, trait- and climate-scaled) plus round(monthly/30 × 0.40) cash per participant per night, in exchange for +30% build speed and +25% bug seeding  
*If removed:* overtime becomes pure cost with zero benefit and no rational player would ever start a block; the build ladder's fast lane disappears and every governed build-speed lever collapses back to headcount and skill  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `M5 phantom citation at scripts/systems/hr_overtime_system.gd:4 and :260, and scripts/systems/product_system.gd:715 ("Ek mesai KAZANCI yalnız BURADA uygulanır (design doc §7b)")` · `scripts/systems/hr_overtime_system.gd:235-265, :184-204` · `scripts/systems/product_system.gd:713-720, :973-982` · `GDD ch.07 rev 2 §7 line 90 (overtime named only as a morale input)`


**`auto.overtime_pay_pull` — Overtime pay reaches burn by a Finance PULL two slots later**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — a real and repeatable cash drain, but one that appears in a burn category the finance chapter's expense law does not list  
FinanceSystem.daily_tick writes burn_breakdown['overtime'] = HROvertimeSystem.pay_accrued_today() at slot 5; HR never pushes a burn category (finance_system.gd:129-148, hr_overtime_system.gd:62-95). The stamp is self-verifying — a restored save reads 0 until the next tick re-stamps — and _pay_carry exists for one edge only: an early stop during hours 1..23 bills the day after Finance already pulled, so that money rides to tomorrow. NO GDD LINE covers overtime pay. ch.08 §1's burn enumeration is closed and does not contain it ('burn = maaşlar + araçlar + servis maliyeti+ marketing plus one-off costs (Atlas retainer, eğitim, lisans, kesinti telafisi)'), and ch.07 §10's Finance link lists 'maaşlar, retainer, eğitim, zamlar' with no mesai; ch.08 §4's monthly-close expense rows likewise. Verified: FinanceSystem.BURN_IDS carries 'overtime' as its own line (finance_system.gd:47). The accrual it pulls is authored under the phantom design doc §7b.  
*Costs the player:* round(monthly_salary / 30 × OVERTIME_PAY_PCT 0.40) per participant per billed night, landing in burn as a line ch.08 does not name  
*If removed:* overtime becomes free money-wise — all speed, no cash cost — leaving morale as its only price and making a permanent block strictly correct play  
*Verification:* ed at :83-85. ch.08 §1 line 4 and §4 line 18 and ch.07 §10 line 107 all quoted verbatim and none contains overtime. ONE CAVEAT WORTH PRE-EMPTING: a reader could argue overtime pay falls under ch.08 §4's "maaşlar" row. The code forecloses that — it is a separate BURN_ID with its own CSV label (strings.csv:1517 "Ek mesai / Overtime"), so get_burn_breakdown_pct (:308-325) renders it as its own expense row. SAME STRENGTHENING AS state.overtime_pay_statics: the identical table also publishes `"founder": 50` / FIN_BURN_FOUNDER "Kurucu yaşam gideri", a line ch.08 §1 and ch.02 §1 both explicitly deleted.  
Evidence: `M5 phantom citation at scripts/systems/hr_overtime_system.gd:4 (§7b)` · `GDD ch.08 §1 line 4 and §4 line 18 (closed enumerations, no overtime row); GDD ch.07 rev 2 §10 line 107` · `scripts/systems/finance_system.gd:129-148, :47 (verified BURN_IDS includes "overtime")` · `scripts/systems/hr_overtime_system.gd:62-95, :308-313`


**`auto.overtime_valve` — Overtime safety valve — an automatic modal, once per person per block**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — it is the felt shape of the overtime bargain and the only reliable HR beat in a demo-length run  
_maybe_enqueue_valve fires immediately after tonight's morale drop lands, for any participant now under the flight-risk line, once per person per block, offering 'Mesaiyi durdur / Devam et' (hr_overtime_system.gd:355-377). The latch lives in the block record because EventManager.enqueue bypasses _is_eligible entirely, so the GameEvent's own one_shot is inert and HREventFactory builds a fresh instance per call (event_manager.gd:644-650). It uses the same HRConstants.is_flight_risk call the badge uses, so a modal without a badge is structurally impossible. NO GDD LINE describes this event. Checked: ch.12 §4 governs the flight-risk BADGE, not a modal; ch.11 §5's trigger-edge list (churn, phase change, incident, raise demand, rival move, version ship, coverage red, promise broken) does not contain it, though the valve obeys §5's grammar (a system edge, not a calendar roll) and §4's cost law. Its code cites the phantom HR design doc §7b.  
*Costs the player:* an interruption plus a real fork: 'Mesaiyi durdur' forfeits the remaining speed bonus, 'Devam et' adds RESIGN_VALVE_PENALTY 0.15 to that person's daily resignation chance for the rest of the run  
*If removed:* a 14-day block would drive a participant from MORALE_HIRE_START 75 through the flight-risk line with no interruption at all; it is the only automatic modal the HR module reliably produces in a normal run, and the only place the overtime decision is re-put to the player  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `M5 phantom citations at scripts/systems/hr_overtime_system.gd:4, :353 and scripts/systems/hr_event_factory.gd:45` · `scripts/systems/hr_overtime_system.gd:355-377` · `scripts/systems/hr_event_factory.gd:47-63` · `scripts/autoload/event_manager.gd:644-650` · `scripts/systems/hr_constants.gd:879-880` · `GDD ch.12 §4 line 10 (badge governed, modal not); GDD ch.11 §5 line 13 (edge list)`


**`auto.overtime_valve_memory` — "Devam et" memory raises that person's resignation odds for the whole run**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — it is the only run-long consequence any HR choice writes, and the player has no surface that reads it back  
note_valve_continued writes GameState.flags['hr_valve_continued_<id>'] = true (hr_overtime_system.gd:380-407); HRMoraleSystem reads it through valve_continued_for on every resignation roll and adds RESIGN_VALVE_PENALTY 0.15 to the daily chance, clamped 0..1 (hr_constants.gd:956-964, hr_morale_system.gd:481-482). It persists for the rest of the run by design — the block ending does not unsay it — survives save/load on GameState.flags, and dies only with initialize_run's flags.clear(). No GDD line. Nearest governed grammar is ch.11 §6 ('Nodes write flags; later nodes read them (arc memory)'), which this obeys, and ch.11 §4's cost law, which it satisfies — but no chapter describes the valve or its memory.  
*Costs the player:* a permanent +0.15/day resignation chance on that person (0.25 → 0.40 baseline, a 60% increase), invisible on every card  
*If removed:* 'Devam et' would become a free answer with no downstream cost, violating ch.11 §4's no-free-upside law and making the valve a pure interruption  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `M5 phantom citations: scripts/systems/hr_overtime_system.gd:4, :353` · `scripts/systems/hr_overtime_system.gd:380-407` · `scripts/systems/hr_constants.gd:956-964` · `scripts/systems/hr_morale_system.gd:481-482` · `GDD ch.11 §6 line 15 (flag-memory grammar obeyed)`


**`auto.vacation_return_dead` — MORALE_VACATION_RETURN (+20) and the manual-leave flag are unreachable**  
**UNGOVERNED · PHANTOM CITATION** · LOW — provably unreachable; its only live cost is that forget_employee still cleans a flag nobody sets  
TATİLE GÖNDER was retired on 2026-08-22 and every surviving call site passes is_manual = false: HRMoraleSystem.tick_leave_departures (:121) and main.gd:1703 (a --hr-shot debug fixture). GameState.flags therefore only ever writes hr_manual_leave_<id> = false, so tick_leave_returns always takes the +10 branch and MORALE_VACATION_RETURN 20, REASON_VACATION_RETURN and VACATION_DAYS 7 are unreachable (hr_actions.gd:115-128, hr_morale_system.gd:88-98, hr_constants.gd:769, :1006). The retirement reason is recorded in-body: without a once-per-year latch the action was a repeatable +20 morale fountain (Calibration Law 1). NO GDD LINE — the action and its constants are cited to the phantom HR design doc §7 (hr_constants.gd:769, hr_morale_system.gd:92, :371).  
*Costs the player:* nothing — the action no longer exists and the branch cannot be reached  
*If removed:* nothing whatsoever; deleting MORALE_VACATION_RETURN, VACATION_DAYS, REASON_VACATION_RETURN, the is_manual parameter and the hr_manual_leave_<id> flag would change no observable behaviour. This is debris, not load-bearing  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `M5 phantom citations: scripts/systems/hr_constants.gd:769; scripts/systems/hr_morale_system.gd:92, :371` · `scripts/systems/hr_actions.gd:115-128` · `scripts/systems/hr_morale_system.gd:88-98, :121` · `scripts/systems/hr_constants.gd:1006`


**`auto.departure_team_charge` — A resignation costs the remaining team morale — but firing uses a DIFFERENT formula**  
**UNGOVERNED** · MEDIUM — it is a genuine cascade mechanic on a small roster: one loss at −5 can move a three-person team measurably toward the flight-risk line  
NO GDD LINE makes a departure a morale input. ch.07 §7's list is closed ('fazla mesai · aşırı yüklenme · başarı ve başarısızlık anları (sürüm çıktı, hesap kaybedildi, kesinti) · lider Liderliği · event'ler') and a colleague leaving is not among them; §9 governs the departure moment but says nothing about the survivors' morale. Verified body: _charge_departure hits every other employee with MORALE_FIRE_TEAM 5 plus round(abs(trait_sum(departure_morale_extra))) — 10 for a GERÇEK LİDER (takes_them_under −5) — while HRActions.fire open-codes its own loop with the flat 5 and never reads the trait (hr_morale_system.gd:399-416 vs hr_actions.gd:190-195). So the same constant is applied through two formulas and GERÇEK LİDER's extra grief is charged on a resignation and not on a dismissal. The in-body comment asserting parity with the fire path ('İşten çıkarma bunu zaten yapıyordu') is stale (M1).  
*Costs the player:* −5 morale to every remaining employee on any departure, −10 if the leaver carried GERÇEK LİDER; scaled by team decay and the founder's Liderlik climate like any other negative  
*If removed:* a resignation would leave no trace in the room at all, which is exactly the hole the 2026-08-21 change was written to close; the cascade risk (one departure pushing others toward flight risk) would disappear with it  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §7 line 90 (closed input list, no departure entry); §9 line 101 (silent on survivors)` · `scripts/systems/hr_morale_system.gd:399-416 (verified body: MORALE_FIRE_TEAM + trait extra)` · `scripts/systems/hr_actions.gd:190-195 (flat constant, no trait)` · `scripts/systems/hr_constants.gd:770, :508-512`


**`auto.forget_employee` — Leaver latch cleanup**  
**UNGOVERNED** · LOW — invisible hygiene; the flag half is already cleaning something nothing sets (auto.vacation_return_dead)  
Verified body: forget_employee erases the _pending entry and sets hr_manual_leave_<id> = false while the id is still meaningful, called by confirm_departure and by HRActions.fire before remove() (hr_morale_system.gd:419-426). NOT cleaned here: the run-long hr_valve_continued_<id> flag (keyed per person, outlives the record harmlessly) and area_leads, which CharacterRegistry.remove clears via GameState.release_area_leads. No GDD line touches latch hygiene.  
*Costs the player:* nothing  
*If removed:* a stale _pending entry would survive the person: HRActions._block_reason would refuse card actions on a re-used id and the resignation roll would skip it forever. Load-bearing but small  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_morale_system.gd:419-426 (verified body)` · `scripts/autoload/character_registry.gd:544-548` · `scripts/autoload/game_state.gd:600-608`


**`auto.hire_default_area` — Fresh hire is auto-assigned to their own key area**  
**UNGOVERNED** · MEDIUM — it is the difference between a hire that works immediately and a hire the player must remember to seat, and it silently pre-answers the screen ch.07 §4 makes the player's  
CharacterRegistry.add appends HRConstants.default_area_for_role(role) when the record arrives unassigned — product_manager→product, designer→design, developer→engineering, tester→qa, sales_rep→sales, customer_rep→customer_success — and zero-fills area_experience for all six AREAS in the same block (character_registry.gd:448-454, hr_constants.gd:164-167). The founder gets no zero-fill (category 'founder'), harmless only because add_area_experience defaults a missing key to 0. NO GDD LINE describes a hire-time default. Checked: ch.07 §4 legislates assignment as a player act on the Görevler screen ('Görevler sekmesinde her kişi bir satırdır; satırda çalışabileceği alanlar işaretlenir') and legislates the idle state as its complement ('Atanmamış kişi boşta durur ve maaş yer — "Boşta" rozeti'), so the engine pre-marking one box is an addition to that grammar rather than a contradiction of it — the Boşta state stays reachable by unticking.  
*Costs the player:* nothing; it hands the player a working hire from day one and removes the first assignment decision  
*If removed:* every fresh hire would arrive with empty assigned_jobs: zero output, zero learn-by-doing, and invisible to the build crew, sales desk and CS desk sums until the player opens Görevler — i.e. a hire that quietly does nothing while eating salary  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §4 lines 49, 75 (player-marked areas; Boşta as the complement)` · `scripts/autoload/character_registry.gd:448-454` · `scripts/systems/hr_constants.gd:164-167, :117-124`


**`auto.new_hire_badge` — YENİ tag — automatic, and it lasts 5 days not 3**  
**UNGOVERNED** · LOW — decoration only, and its off-by-two against its own constant's name is a magnitude note, not a defect  
HRConstants.is_new_hire(hire_day, today) returns `today <= hire_day + NEW_HIRE_BADGE_DAYS 3` (hr_constants.gd:863-867), and because HRSearchSystem.hire re-stamps hire_day to GameState.day + 1 (:217-221) the tag is visible on the purchase day plus four more — 5 days for an Atlas hire, 4 for an add_character event hire. The two-sided test is intentional (on purchase day today < hire_day). NO GDD LINE: ch.12 §4's badge enumeration has no new-hire entry, and BADGE_NEW is deliberately kept out of badges_for so it cannot light the rail badge (hr_constants.gd:792-793).  
*Costs the player:* nothing  
*If removed:* nothing mechanical; the ledger loses a cosmetic 'this person is new' marker  
*Verification:* -channel reason. Day count re-derived: purchase day D gives hire_day D+1, so the test holds for D through D+4 = 5 days. CORRECTION: the "4 for an add_character event hire" half describes nothing reachable — no shipped event uses the add_character modifier (whole-repo grep), so 5 days is the only real answer today. ch.12 §4 line 10's badge list confirmed to have no new-hire entry.  
Evidence: `scripts/systems/hr_constants.gd:863-867, :792-793` · `scripts/systems/hr_search_system.gd:217-221` · `scripts/tabs/hr/hr_ledger.gd:336` · `GDD ch.12 §4 line 10 (badge list has no new-hire entry)`


**`auto.positive_calm_stretch` — Calm stretch — the ONE positive event that can actually fire**  
**UNGOVERNED** · HIGH — it is the only thing standing between the current morale model and a strictly one-way drain  
Fires when days_since_last_overtime() >= CALM_STRETCH_DAYS 21 and average_morale() < CALM_STRETCH_MAX_MORALE 70, giving +CALM_STRETCH_MORALE 5 to every employee through the morale_all_employees modifier (hr_morale_system.gd:196-199, :282-304; hr_event_factory.gd:72-76). days_since_last_overtime measures from GameState.hr_last_overtime_day or from day 1 when no block ever ran. NO GDD LINE names a rest or quiet-period morale recovery: ch.07 §7's input list is 'fazla mesai · aşırı yüklenme · başarı ve başarısızlık anları · lider Liderliği · event'ler', and the generic 'event'ler' entry is the closest touch — it licenses the channel, not this trigger. Self-limiting by design: a team at MORALE_HIRE_START 75 that never works overtime never sees it.  
*Costs the player:* nothing; it is a pure gift of +5 to everyone, at most once per 14 days  
*If removed:* the module's ONLY reachable automatic morale recovery disappears — the other two positive beats are structurally dead — leaving leave returns (rare in a demo-length run) and player-paid actions as the entire upward channel, and making morale monotonically decreasing in practice  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_morale_system.gd:196-199, :282-304` · `scripts/systems/hr_event_factory.gd:72-76` · `scripts/systems/hr_constants.gd:1074-1076` · `GDD ch.07 rev 2 §7 line 90 (no rest/quiet input named)`


**`auto.resign_latch` — Pending-departure latch (_pending) — the anti-double-roll seal**  
**UNGOVERNED** · MEDIUM — invisible when working, and directly distorts the one authored probability in the module when absent  
A successful roll appends the id to HRMoraleSystem._pending BEFORE the enqueue and the roll is skipped for anyone in it; it is cleared by forget_employee from confirm_departure or HRActions.fire (hr_morale_system.gd:67-72, :479-494). It lives in the SYSTEM rather than on the event because EventManager.enqueue bypasses _is_eligible, so the GameEvent's one_shot is inert and enqueue dedupes only on the same instance. It also blocks all three card actions via HRActions._block_reason. Saved in to_dict/from_dict even though provably empty at every save point today, so the schema does not depend on another module's gate staying strict. EDGE: enqueue() silently returns when not GameState.run_active (event_manager.gd:200-214), which would burn the latch with no modal — only reachable post-terminal. No GDD line touches any of this.  
*Costs the player:* nothing  
*If removed:* the roll would repeat every day while the modal waits, silently pushing the effective odds far above the authored per-day chance — the player would be punished for not reading a modal promptly, and ch.11 §4's visible-reader law would be broken by an invisible compounding  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_morale_system.gd:67-72, :479-494, :443-461` · `scripts/autoload/event_manager.gd:200-214`


**`auto.rng_streams` — HR's only RNG is one named stream, resumable from a save**  
**UNGOVERNED** · LOW — invisible, but it is why a healthy team's run is byte-reproducible and why save/load does not re-dice a pending departure  
The single random draw in the entire automatic HR surface is the resignation roll, from RngStreams.STREAM_HR_MORALE (hr_morale_system.gd:497-506). Search arrival, candidate generation, the request cadence and both desks are derived, never rolled. Reset order is load-bearing: HRSystem.reset() → reset_rng() runs from initialize_run AFTER run_seed is assigned, and SaveCodec.restore_systems then runs RngStreams.from_dict() AFTER initialize_run so a LOAD restores the saved position over that re-key rather than replaying from birth. No GDD line; the nearest touch is ch.11 §5's 'not to random calendar rolls', which this satisfies by having almost no rolls at all.  
*Costs the player:* nothing  
*If removed:* sharing a stream with the event deck would let a resignation roll displace event draws, making the deck's order depend on how neglected the team is; losing the restore order would replay the stream from birth on every load  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_morale_system.gd:497-506, :429-440` · `scripts/systems/hr_system.gd:317-327` · `scripts/systems/hr_search_system.gd:50-58` · `scripts/autoload/save_manager.gd:375-416` · `GDD ch.11 §5 line 13`


**`auto.run_reset` — Run-boundary reset of the HR statics**  
**UNGOVERNED** · LOW — only bites on in-process restarts, which is exactly the path the developer uses most  
HRSystem.reset(), called from GameState.initialize_run after flags clear and run_seed is set, clears HRMoraleSystem._pending, re-keys the HR stream, and clears HROvertimeSystem's three pay statics (hr_system.gd:317-327, hr_overtime_system.gd:412-420). HRSearchSystem holds no statics — its state is GameState.hr_search. initialize_run separately clears hr_search, hr_overtime, hr_last_overtime_day, hr_last_positive_event_day, area_leads, run_hires and run_departures (game_state.gd:801-833, :883). No GDD line (no save/run-lifecycle chapter exists in the corpus).  
*Costs the player:* nothing  
*If removed:* a fresh process would be fine, but the debug onboarding re-trigger reuses the process and would pull the previous run's overtime pay stamp into day-1 burn, and a previous run's pending departure would block a new employee sharing the id  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:317-327` · `scripts/systems/hr_overtime_system.gd:412-420` · `scripts/autoload/game_state.gd:801-833, :883`


**`auto.save_surface` — HR's save payload is exactly one latch**  
**UNGOVERNED** · LOW — currently a no-op with a documented reason to exist  
HRSystem.to_dict/from_dict carry only HRMoraleSystem's _pending list (hr_system.gd:330-346, hr_morale_system.gd:443-461). Overtime blocks ride GameState.hr_overtime, the search rides GameState.hr_search, and the three overtime pay statics are deliberately excluded as self-verifying single-day scratch (hr_overtime_system.gd:333-339). _pending is provably empty at every save point today because SaveManager.can_save refuses while EventManager.has_pending(), and it is saved anyway so the schema does not depend on another module's gate staying that strict. No GDD chapter covers saves.  
*Costs the player:* nothing  
*If removed:* nothing today, by construction; it would break the moment can_save is relaxed, which is precisely the coupling the inclusion is defending against  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:330-346` · `scripts/systems/hr_morale_system.gd:443-461` · `scripts/systems/hr_overtime_system.gd:333-339`


**`auto.search_idle_noop` — Search tick is a true no-op when idle**  
**UNGOVERNED** · LOW — an invariant rather than a mechanic, but it is what makes 'no search' a real state instead of a special case  
The first line of HRSearchSystem.daily_tick returns unless state == SEARCH_SEARCHING (hr_search_system.gd:62-67), so a run that never opens the Ekip page consumes zero generator work and zero RNG. An EMPTY GameState.hr_search dictionary reads as idle by construction via get_state's default (:77-80), which is what makes initialize_run's hr_search.clear() a complete reset (game_state.gd:830). No GDD line; the sealed-flow clause of ch.07 §6 governs the flow's shape, not its idle behaviour.  
*Costs the player:* nothing  
*If removed:* the generator would run against an empty record every day and a cleared search could read as a live one; the clear-is-a-reset property would be lost  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_search_system.gd:62-67, :77-80` · `scripts/autoload/game_state.gd:830`


**`auto.training_flightrisk_asymmetry` — Training is "mechanically the same as leave" everywhere except the resignation clock**  
**UNGOVERNED** · MEDIUM — low frequency (needs morale under 25 at the moment training starts) but a total loss of a paid, multi-week investment when it lands  
HRConstants declares STATUS_TRAINING to be 'İzinde ile mekanik olarak aynı (kapasite dışı, mesai dışı, SORUMLU seçilemez)' (hr_constants.gd:795-802). tick_thresholds skips only STATUS_ON_LEAVE (hr_morale_system.gd:127-135), so an in-training employee keeps accruing flight_risk_days and can be rolled into a resignation while paid-and-parked in a course the player bought. tick_overload uses get_active_employees() and DOES freeze for training (hr_system.gd:228), and HROvertimeSystem.participants() also excludes them — so training behaves like leave in two of three counters and unlike it in the third. NO GDD LINE settles it either way: ch.07 §8 says only 'kişi o süre boyunca çalışamaz', which is about working, not about resigning; ch.07 §7's ladder applies to everyone, which is arguably what the code does. The collision is with the constant's own doc-comment, not with the chapter.  
*Costs the player:* the training fee (TRAINING_FEE 500 base + 220 per existing point, ×1.35 for Liderlik, +35% per repeat) plus 14 days of absence, all of which can be lost to a resignation on day 10 of that same absence  
*If removed:* freezing the counter during training would make a course a shelter from neglect; leaving it as-is keeps neglect chargeable but lets the player lose a purchase mid-delivery  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:795-802 (the doc-comment the body contradicts)` · `scripts/systems/hr_morale_system.gd:127-135 (skips ON_LEAVE only)` · `scripts/systems/hr_system.gd:228 (overload freezes for training)` · `GDD ch.07 rev 2 §8 line 94 (silent on resignation during training)`


**`chain.count_mismatch` — "Seven HR steps" — three files say seven, the body runs nine**  
**UNGOVERNED** · LOW — no runtime effect, listed because M1 makes stale testimony a finding in its own right  
HRSystem's header, HRSearchSystem's header and the hr_day_processed signal doc all describe 'seven HR steps' (hr_system.gd:44-61, hr_search_system.gd:6-9, event_bus.gd:73); the body makes NINE calls, because tick_overload, tick_experience and tick_training were added later and none of the three prose counts was updated. No GDD line covers internal documentation.  
*Costs the player:* nothing  
*If removed:* nothing — it is prose. Its cost is comprehension: a reader budgeting the tick from the comment will not look for tick_overload, tick_experience or tick_training at all, which is exactly how the OVERLOAD_MORALE_MULT hole (auto.overload_no_morale) survived  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:44-61 (nine calls under a 'seven steps' header)` · `scripts/systems/hr_search_system.gd:6-9` · `scripts/autoload/event_bus.gd:73`


**`chain.hr_order` — HRSystem.daily_tick — nine steps, fixed order, then hr_day_processed**  
**UNGOVERNED** · HIGH — it is the spine every other automatic row hangs from  
tick_leave_returns → tick_leave_departures → tick_overload → HRSearchSystem.daily_tick → HROvertimeSystem.daily_tick → tick_thresholds → tick_positive_events → tick_experience → tick_training, then EventBus.hr_day_processed as the last line (hr_system.gd:34-73, event_bus.gd:79). The ordering carries real rulings read from the body: returns before departures so status is settled; overload before thresholds so today's load is priced today; thresholds after overtime so tonight's mesai starts the flight-risk count today; training last so a completion-day experience reset cannot be re-credited the same day. hr_day_processed exists because EventBus.day_advanced fires inside advance_day, before these nine steps. NO GDD LINE touches step order or the signal.  
*Costs the player:* nothing directly; the order decides whether a given day's overtime night counts toward flight risk that same day  
*If removed:* the entire automatic HR surface stops. Individual reorderings are load-bearing: thresholds before overtime would delay every resignation clock by a day, and training before experience would double-credit a completion day  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:34-73` · `scripts/autoload/event_bus.gd:79`


**`chain.rollover` — Day rollover — the only clock that starts the HR day**  
**UNGOVERNED** · HIGH — every automatic row in this pass is downstream of this one branch  
One branch in TimeManager._drain_boundaries drives the whole HR day: at `GameState.current_hour >= HOURS_PER_DAY - 1 and _in_game_hours >= float(HOURS_PER_DAY)` it fires _dispatch_hourly_tick(0) at :141 BEFORE GameState.advance_day() at :142, then _dispatch_daily_tick (time_manager.gd:124-147). Anything stamped during the hour-0 hourly tick therefore carries YESTERDAY's day number. NO CHAPTER legislates this. The adjacent facts are governed: ch.01 §1 sets the run in days ('24 game months soft cap [WORKING 730 days]') and ch.12 §2 puts date and speed in the TopBar ('TopBar carries date, cash, MRR, runway, shutter countdown when active, and speed (1×/2×/3×)') — and the speed ladder only changes SECONDS_PER_DAY, never the order.  
*Costs the player:* nothing  
*If removed:* no HR day exists at all — no leave, no overtime billing, no experience, no resignation clock. The hourly(0)-before-advance_day ordering specifically is what makes 'was it stamped today?' unanswerable to any slot-3 reader  
*Verification:* ourly_tick(0)`, :142 `GameState.advance_day()`, :143 `_dispatch_daily_tick()`, all in one while-loop iteration. The row understates the blast radius: this ordering is now confirmed to be the direct mechanical cause of TWO other rows in this batch (auto.positive_ship_glow's ship-glow AND the big-signing beat), because it guarantees that anything stamped with GameState.day between two daily ticks is already one day old when the slot-3 reader asks "was it today?". The file itself documents the sibling trap at :276-283 (day_advanced fires before the twelve slots) without noticing that hourly(0) creates the mirror-image one. No chapter governs it: ch.01 §1 line 4 and ch.12 §2 line 6 confirmed as …  
Evidence: `scripts/autoload/time_manager.gd:124-147, :138-144, :249-283` · `GDD ch.01 §1 line 4; GDD ch.12 §2 line 6`


**`chain.slot3` — Daily slot order — HR is slot 3, Finance slot 5**  
**UNGOVERNED** · HIGH — an unwritten ordering law is currently deciding which governed morale events exist  
_dispatch_daily_tick calls thirteen slots in a fixed order: product(1) → rnd(2, empty pass) → HR(3) → sales(4) → rivals → finance → events → industry → angel → phase → pitch → endings → month summary (time_manager.gd:249-268), early-returning unless GameState.run_active. Finance PULLS payroll and overtime pay from HR two slots later rather than HR pushing a burn category. NO CHAPTER legislates intra-day ordering. ch.07 §10's Links do govern the cross-module direction ('Finance (08): maaşlar, retainer, eğitim, zamlar'), and the pull honours it. The _tick_hr comment claiming HR 'applies baseline morale drift' (:311-315) is stale: the drift was deleted, not tuned (hr_system.gd:15-21).  
*Costs the player:* nothing directly  
*If removed:* HR would not tick at all. Reordering is what would bite: HR at slot 3 can never observe anything a player resolves in a modal that day, which is the sole reason auto.positive_ship_glow and auto.positive_big_signing are dead, and moving Finance before HR would bill yesterday's payroll against today's roster  
*Verification:* )` then `HROvertimeSystem.pay_accrued_today()`), and the stale _tick_hr comment at :311-315 against hr_system.gd:15-21. CORRECTION to breaks_if_removed: slot position is the sole reason only ONE of the two dead positive beats is dead. Moving HR after slot 4 would revive auto.positive_big_signing (SalesRepSystem creates accounts at slot 4, b2b_sales_system.gd:43, so acquired_on_day would equal GameState.day). It would NOT revive auto.positive_ship_glow: ship_active_build runs from the event modal's modifier mid-day (event_manager.gd:666-667), so no slot position inside the day-boundary tick can ever see "today's" ship. The ordering law decides one of the two, not both.  
Evidence: `scripts/autoload/time_manager.gd:249-268, :308-309, :311-315 (stale comment)` · `scripts/systems/hr_system.gd:15-21 (drift deleted)` · `GDD ch.07 rev 2 §10 line 107 (Finance link honoured by the pull)`


**`obs.experience_bar_refs` — DENEYIM barinin yerinde-boyama referanslari OKUNMUYOR (render defect)**  
**UNGOVERNED** · MEDIUM — ch.02 §7 makes assignment a growth decision, and the readout the player would use to judge that decision is silently stale.  
The MECHANIC is governed — ch.07 §8's "Learn-by-doing: atandigi alanin deneyimi yavas yukselir; lider Liderligi bu hizi artirir" and ch.02 §7's "Primary: learn by doing (assignment = growth decision)". The SURFACE is not: ch.07 §3 legislates only what the closed row shows of a person's SKILLS ("Kapali satirda yalniz o rolun anahtar alani ve varsa ikincil alani gorunur"), and no chapter asks for an experience progress bar; the live row (hr_ledger.gd:96-155) additionally carries task, status chips, a trait icon, salary and a morale bar, none of which any chapter specifies. The defect: HRLedger._experience_cell writes refs["experience_bar"] and refs["experience_label"] (hr_ledger.gd:291-292) and a repo-wide grep finds NO reader for either key. hr_tab._refresh (:195-208) takes the in-place branch when the structure key is unchanged and calls only HRUiShared.repaint_morale(refs, morale), which reads refs["bar"] / refs["value"] — the two keys morale_row writes into the SAME dictionary. _compute_structure_key (:211-227) folds in search state, per-department overtime day_index, MT roster sizes and per-employee id/status/salary/badge-severity, but NOT area_experience. So on a quiet day neither employee_experience_changed (subscribed at :73-75 with a comment saying it exists precisely so the bar does not go a day stale) nor hr_day_processed can move the bar. One dictionary, two naming conventions, one of them dead.  
*Costs the player:* Nothing in cash; it costs information. The only readout of the module's primary growth mechanic shows a stale figure on exactly the days nothing else changes — which is most days.  
*If removed:* Deleting the two orphan keys breaks nothing (no readers). Deleting the CELL would remove the only surface anywhere that shows employee learn-by-doing progress; the founder's equivalent survives only because personal_tab rebuilds the whole page on every signal (personal_tab.gd:48-49).  
*Chapter conflict:* ch.02 §3 rules the closed HR-list card is "name · role · role-fit ★ · the role's key skill ★. Two values, nothing else" and "Never a six-column skill table in v1"; ch.07 rev 2 §3 replaces this with key area + secondary area and "Altı alan hicbir zaman duz sira olarak gosterilmez". The live row exceeds BOTH (name, role, two areas + Liderlik, task, experience, status, trait, salary, morale = nine …  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr/hr_ledger.gd:271-293` · `scripts/tabs/hr/hr_ledger.gd:96-155` · `scripts/tabs/hr_tab.gd:73-75` · `scripts/tabs/hr_tab.gd:195-227` · `scripts/tabs/hr/hr_ui_shared.gd:200-253` · `GDD ch.07 rev 2 §8`


**`auto.area_lead_derivation` — area_lead's explicit-choice branch is unreachable in a fresh run**  
**DIVERGENT** · HIGH — leadership is a named lever on efficiency, morale decay and learning speed, and the player has no way to point it at anyone  
GDD: ch.07 rev 2 §2 (and §9)  

> Liderlik: ekip lideri atanan çalışanın altındaki ekibin verimlilik modifier'ını, moral düşüş hızını ve deneyim kazanım hızını etkiler. — and §9: "Ekip lideri istifa etti, yerine kim geçiyor?"

The GDD legislates an ASSIGNED team lead ('ekip lideri atanan çalışan') and a departure card that asks the player who succeeds a lead. HRSystem.area_lead (hr_system.gd:185-204) reads GameState.area_leads for that explicit choice — and nothing in production ever writes an entry into it. The only touches are release_area_leads() erasing (game_state.gd:600-608), .clear() in initialize_run (:803), and a v4→v5 save migration rebuilding it from a retired `job_leads` key that itself has no live writer (save_manager.gd:798-811). Every run therefore silently falls through to 'highest Liderlik among people assigned to that area, else the founder'. SaveCodec captures GameState variables generically (save_codec.gd:274-295), so a migrated legacy save could hold seats a fresh run cannot create.  
*Costs the player:* nothing to set; the player never gets the governed choice of who leads an area, and the resignation card never asks  
*If removed:* deleting the dead first branch changes no behaviour at all; deleting the derivation would drop the experience multiplier and the build coordination multiplier to their neutral values  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §2 line 42; §9 line 101` · `scripts/systems/hr_system.gd:185-204 (verified body: picked_id from GameState.area_leads, then highest leadership, then founder)` · `scripts/autoload/game_state.gd:254, :600-608, :803` · `scripts/autoload/save_manager.gd:798-811` · `scripts/systems/save_codec.gd:274-295`


**`auto.badge_overloaded_collision` — "AŞIRI YÜKLÜ" is two things and the attention badge is the one unrelated to overload**  
**DIVERGENT** · HIGH — ch.12 §4 rules that a badge is a number you click to reach the exact row, and this one points at people whose state is not what the badge is named for  
GDD: ch.07 rev 2 §5 (with ch.12 §4)  

> Bir kişiye birden fazla alan verildiğinde satırında aşırı yüklenme rozeti çıkar. Sayı gösterilmez; rozet ve hover açıklaması yeterlidir.

The GDD's overload badge is defined by multi-area assignment. HRConstants.BADGE_OVERLOADED — the badge that feeds attention_count — is derived from is_capacity_overloaded(), which reads the COMPANY-wide GameState flag `needs_engineer` and never touches assigned_jobs (hr_morale_system.gd:271-279, :328-334, verified body). needs_engineer is set by ProductSystem._record_sprint_and_check_engineer (3 bug sprints in a 20-day window) and cleared by exactly one thing: hiring a role_developer through HRSearchSystem.hire (:224-228). It is therefore sticky — hire a tester, PM or designer and every product_dev employee wears a red attention badge forever. The governed badge does exist, but as a separate UI chip (HR_BADGE_OVERLOADED_JOBS, hr_ledger.gd:217-218) derived from HRSystem.is_overloaded. Neither ch.12 §4's closed badge list nor ch.07 §5 contains an engineer-shortage badge.  
*Costs the player:* a permanently lit rail badge that cannot be cleared except by hiring one specific role; no mechanical cost  
*If removed:* removing the needs_engineer badge would leave attention_count reading only flight risk, burnout and the two nudges; the governed overload chip is independent and would survive  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §5 line 79; GDD ch.12 §4 line 10 (closed badge list, no engineer-shortage entry)` · `scripts/systems/hr_morale_system.gd:271-279, :328-334 (verified: reads the needs_engineer flag)` · `scripts/systems/product_system.gd:1114-1125 (flag writer)` · `scripts/systems/hr_search_system.gd:224-228 (only clearer: hiring a developer)` · `scripts/tabs/hr/hr_ledger.gd:217-218 (the real overload chip)`


**`auto.cs_escalate_stale` — Unworked requests escalate to the player after 3 days**  
**DIVERGENT** · MEDIUM — it is the only visible consequence of an unmanned desk, and the weekly cap means the consequence saturates well below the pressure ch.06 §1.2 describes  
GDD: ch.06 §1.2  

> load > capacity → response time worsens → satisfaction falls → risk cards / churn (B2B), word-of-mouth sours (B2C).

The code implements the chain's first and last links and skips the middle one. _escalate_stale escalates any request open for CS_ESCALATE_AFTER_DAYS 3 (customer_rep_system.gd:290-318), and _escalate refuses over CS_ESCALATION_WEEKLY_CAP 2 inside CS_ESCALATION_WINDOW_DAYS 7 (rolling, pruned from GameState.cs_escalation_days) — over budget the request stays OPEN and retries tomorrow, deferred but never dropped. What does not exist is the governed intermediate cost: slow response applies NO automatic satisfaction penalty. An understaffed desk therefore produces at most two interruptions a week and, once the cap is hit, a backlog that costs nothing at all until someone works it. BOUNDARY: the far side (satisfaction, risk cards, churn) is ch.04's and was not audited.  
*Costs the player:* up to two modal interruptions per week; beyond that, nothing  
*If removed:* understaffing the CS area would become entirely free, since absorption is silent and the satisfaction link is already missing  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.06 §1.2 line 13` · `scripts/systems/customer_rep_system.gd:290-318, :278-287` · `scripts/systems/b2b_constants.gd:340-349`


**`auto.cs_gate_role_vs_area` — The CS desk's gate asks about ROLE, its work asks about AREA**  
**DIVERGENT** · HIGH — account ownership is one of the seven governed jobs, and whether it runs at all currently depends on a job title rather than the assignment the player made  
GDD: ch.07 rev 2 §2 and §4 (job table)  

> §2: "Herkes altı alanda puan taşır. Alan adları rol adı değildir" ... "QA yoksa mühendis test edebilir, tasarımcı yoksa PM tasarıma bakabilir." — §4 table: "Hesap sahipliği | Müşteri Başarısı · Satış | hesap memnuniyeti, risk kartları"

The chapter's whole thesis is that work is gated by AREA, never by job title, and §4's table explicitly lets the Satış area own accounts. The code gates the entire CS desk on a ROLE headcount: reconcile_assignments and CustomerRepSystem.daily_tick both return early on count_active_by_role(ROLE_CUSTOMER_REP) == 0 (customer_rep_system.gd:42-57, :101-103), while every worker lookup underneath reads HRSystem.assigned_to(AREA_CUSTOMER_SUCCESS). Two failure directions: (A) a customer_rep moved off the CS area leaves the gate OPEN — _open_due_requests keeps stamping requests on the 22-day cadence but throughput is 0 and _escalate returns on an empty rep list without clearing the latch, so the backlog grows forever and then escalates in a lump (bounded at 2/week) when someone is re-seated; (B) a sales_rep legally assigned to customer_success (their secondary area under ROLE_AREAS, hr_constants.gd:117-124) is in _ranked and would work the desk, but with no customer_rep on payroll the gate shuts it.  
*Costs the player:* in case (A) support requests accumulate invisibly; in case (B) a paid, correctly-assigned person does nothing  
*If removed:* removing the role gate would let any Müşteri Başarısı-assigned person run the desk, which is what §4's table describes; removing the area lookups would strand the role gate with no workers  
*Verification:* Both failure directions confirmed in the bodies, and direction (A) is worse than filed. _escalate (customer_rep_system.gd:301-318) checks the weekly budget, then does `var reps = _ranked(...); if reps.is_empty(): return` at :310-312 — returning BEFORE `CustomerRegistry.set_support_request(c.id, -1)` at :315. The latch is the customer's own support_request_since_day, so with the CS area unstaffed every b2b account accumulates one permanently-open request that _open_due_requests (:198-208) will never re-stamp and _escalate will never clear; re-seating anyone then releases the whole backlog, throttled only by CS_ESCALATION_WEEKLY_CAP. Direction (B) confirmed: _ranked (:42-58) reads …  
Evidence: `GDD ch.07 rev 2 §2 lines 17-41; §4 job table lines 63-65` · `scripts/systems/customer_rep_system.gd:42-57, :101-103, :190-195, :198-208, :301-318` · `scripts/systems/hr_constants.gd:117-124 (ROLE_AREAS: sales_rep carries customer_success as secondary)`


**`auto.cs_open_requests` — Support requests open themselves on a deterministic per-account cadence**  
**DIVERGENT** · MEDIUM — support volume is the reason to staff the area, and it currently scales only with account count  
GDD: ch.06 §1.2  

> load = a·active_accounts + b·live_bugs + c·version_age; capacity = throughput × assigned_heads × Müşteri Başarısı × Hız [WORKING].

The governed load formula has three terms; the code's inflow has one. _open_due_requests stamps one open request per b2b account every B2BConstants.CS_REQUEST_INTERVAL_DAYS 22, phase-offset per account by cs_request_phase so the book does not file on the same morning, with no RNG anywhere (customer_rep_system.gd:198-208, b2b_constants.gd:331-336). live_bugs and version_age contribute nothing to ticket inflow, so a buggy, ageing product generates exactly as much support work as a clean new one. The latch is support_request_since_day, state this system owns, never an event property — correct, since enqueue bypasses one_shot and cooldown. NOTE against ch.11 §5 ('Events hook to system edges ... not to random calendar rolls'): the cadence is not random but it is a calendar, and the two governed non-calendar terms are the missing ones.  
*Costs the player:* one request per account per 22 days, absorbed silently or escalated  
*If removed:* the CS desk would have no work at all and the whole Müşteri Başarısı area would idle; the escalation channel would go dark  
*Verification:* NG, interval 22 at b2b_constants.gd:331 and CS_PHASE_STRIDE 9 at :336 (coprime with 22, same trick as the leave month). PRECISION the row omits: the whole channel is gated on a HIRE, not merely on accounts — CustomerRepSystem.daily_tick returns at :191-192 unless count_active_by_role(ROLE_CUSTOMER_REP) > 0, so a founder-only run generates zero tickets. That makes the divergence from ch.06 §1.2 larger, not smaller: the governed formula has three load terms and no headcount gate on INFLOW (headcount belongs to `capacity`), while the code has one load term and a headcount gate on inflow.  
Evidence: `GDD ch.06 §1.2 line 12; GDD ch.11 §5 line 13` · `scripts/systems/customer_rep_system.gd:198-208` · `scripts/systems/b2b_constants.gd:331-336` · `scripts/autoload/customer_registry.gd:294-301`


**`auto.experience_levelup` — Experience fill → automatic +1 in that area, counter resets**  
**DIVERGENT** · HIGH — growth speed decides whether a first hire is still the right hire at month 12, and the current rate is roughly 3.6× the only stated target  
GDD: ch.02 §7 (pace target); mechanism governed by ch.07 rev 2 §8  

> Pace target: a starting employee moves ~one tier over 24 months [WORKING]. Decay above a soft cap: decide after first playtest.

The mechanism is governed and built: CharacterRegistry.add_area_experience is the single writer, converting a filled counter into +1 role_stats point and zeroing it (character_registry.gd:96-123), refusing any key outside HRConstants.AREAS so Liderlik never accrues by doing. The RATE diverges from the only pace clause in the corpus. Verified constants: EXPERIENCE_MAX 100, EXPERIENCE_PER_DAY 1, POINTS_PER_STAR 2 (hr_constants.gd:809-812, :58-59) → one star costs ~200 assigned days before multipliers, ~100 during continuous build phases. Over the 24 months ch.02 §7 names (ch.01 §1's 730-day soft cap) that is ~3.6 stars, not ~1. Both sides are [WORKING] under M3, so this is a calibration-grade divergence on an explicitly uncalibrated number, not a defect. ch.07 rev 2 §8 restates only the direction ('deneyimi yavaş yükselir') and does not supersede the pace clause. Two ceilings, deliberately: this free channel reaches AREA_MAX 10 while paid training stops at AREA_TRAIN_CAP 8.  
*Costs the player:* nothing — it is the free growth channel; the cost is the assignment decision itself  
*If removed:* training becomes the only way anyone improves, and ch.02 §7's 'Primary: learn by doing' channel disappears along with the reason to keep a person on one area  
*Chapter conflict:* ch.02 §7 sets the pace target (~one tier / 24 months, [WORKING]) and also lists mentoring as a separate tertiary channel; ch.07 rev 2 §8 restates learn-by-doing without any pace figure and §2 folds mentoring into Liderlik. ch.07's silence on pace does not repeal ch.02 §7, so the pace clause stands as the operative target.  
*Verification:* EA_TRAIN_CAP 8 at :815, single writer add_area_experience character_registry.gd:96-123 refusing non-AREAS keys at :103. PRECISION on the 3.6× figure, which is a FLOOR, not a point estimate: (a) the rate stacks — hr_system.gd:120-121 multiplies base × lead_mult (≤1.5, hr_constants.gd:188-193) × own_mult (ÇABUK KAPAR 1.5) × mentor_mult (GERÇEK LİDER 1.5), so a well-led fast learner under a mentor in a build phase runs at up to 6.75/day, a full star in ~30 days; (b) a two-area person accrues in BOTH areas at 0.75 each (hr_system.gd:103, :110-122), i.e. 1.5× total throughput, not a split. CAVEAT: "tier" is never defined in the corpus, so tier=star is the row's reading; if tier means the …  
Evidence: `GDD ch.02 §7 line 56; GDD ch.07 rev 2 §8 line 97; GDD ch.01 §1 line 4 (730 days)` · `scripts/autoload/character_registry.gd:96-123` · `scripts/systems/hr_constants.gd:809-818 (verified EXPERIENCE_MAX 100 / PER_DAY 1 / PER_BUILD_DAY 2)` · `scripts/systems/hr_constants.gd:46-59 (verified AREA_MAX 10, POINTS_PER_STAR 2)`


**`auto.experience_overload_gate_mismatch` — Overload penalises LEARNING from day 1 but OUTPUT only after day 5**  
**DIVERGENT** · MEDIUM — it silently taxes exactly the short, deliberate double-assignments §5 says are tolerated  
GDD: ch.07 rev 2 §5  

> Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider.

One constant, two gating rules. tick_experience computes load_mult as `1.0 if assigned_jobs.size() <= 1 else OVERLOAD_OUTPUT_MULT` with no tolerance check at all (hr_system.gd:103), while output_mult_for_area gates the same 0.75 behind overload_bites, i.e. overload_days > OVERLOAD_TOLERANCE_DAYS 5 (:153-156, :244-247). So a second assignment costs 25% of learning from its first day and 25% of output only from its sixth. §5 rules the tolerance explicitly, and overload_bites' own comment states 'bedel toleranstan SONRA başlar' — the learning path contradicts both the chapter and the code's own stated rule.  
*Costs the player:* ×0.75 experience for the first five days of every multi-area assignment, invisibly (no badge is lit yet in that window)  
*If removed:* n/a — aligning the gate would restore §5's tolerance; the constant itself is load-bearing on the output path  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §5 line 81` · `scripts/systems/hr_system.gd:103, :153-156, :244-247` · `scripts/systems/hr_constants.gd:144-145`


**`auto.morale_no_output_effect` — Low morale never lowers output**  
**DIVERGENT** · HIGH — the first and most legible rung of the governed ladder is missing, so morale reads as a hidden countdown to a resignation modal rather than as a felt production cost  
GDD: ch.07 rev 2 §7  

> Düşük moral çıktıyı düşürür, sonra kaçma riski rozetine, sonra istifaya gider.

The three-stage ladder starts at stage two. No production formula reads Character.morale: ProductSystem._phase_area_sum multiplies role_stats × output_mult_for_area × two traits (product_system.gd:509-537); SalesRepSystem._diminished_sum and CustomerRepSystem.throughput_of do the same on their side. Morale's only mechanical consequence is the flight-risk threshold at 25 and the resignation it feeds (hr_morale_system.gd:124-145). Every other morale reader in the repo is a repaint hook or a modifier that writes.  
*Costs the player:* nothing — morale can sit at 26 forever with full output  
*If removed:* n/a — governed behaviour absent; nothing to remove  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §7 line 91` · `scripts/systems/product_system.gd:509-537 (build sum: no morale term)` · `scripts/systems/sales_rep_system.gd:64-81` · `scripts/systems/customer_rep_system.gd:74-92` · `scripts/systems/hr_morale_system.gd:124-145 (the only consumer of the number)`


**`auto.overload_no_morale` — Overload never costs a single morale point**  
**DIVERGENT** · HIGH — a permanently double-assigned employee pays 25% output forever and can never reach the resignation ladder, so the module's single stated punishment for over-assignment does not exist  
GDD: ch.07 rev 2 §5 (and §7 input list)  

> Model: ana alanında çalışmak normal, ikincil alanında çalışmak daha yorucudur. Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider. Sayısal ağırlıklar [WORKING], kalibrasyonda belirlenir. — and §5's mandated hover copy: "bu çalışan birden fazla alanda çalışıyor; verimi düşer ve morali normalden hızlı erir." — and §7: "Girdiler: fazla mesai · aşırı yüklenme · ..."

Overload moves output only. HRConstants.OVERLOAD_MORALE_MULT = 1.6 is declared and documented as 'multiplier on NEGATIVE morale deltas' and has exactly one occurrence in the repo: its own declaration (hr_constants.gd:142-146). scaled_delta (hr_morale_system.gd:228-254), the single morale scaler, folds in _team_decay_mult and the founder Liderlik climate and never asks about overload_days or assigned_jobs.size(). So §5's chain 'aşırı yük → moral düşer → kaçma riskine gider' and §7's second named morale input are both severed at the first link.  
*Costs the player:* ×0.75 output past 5 days; zero morale, therefore zero flight risk from overload  
*If removed:* n/a — the governed behaviour is already absent; deleting OVERLOAD_MORALE_MULT would only remove a dead constant and the last trace that the rule was ever intended  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §5 lines 79-81 (badge, hover copy, tolerance, morale, kaçma riski)` · `GDD ch.07 rev 2 §7 line 90 (aşırı yüklenme listed as a morale input)` · `scripts/systems/hr_constants.gd:142-146 (OVERLOAD_MORALE_MULT declared, no reader)` · `scripts/systems/hr_morale_system.gd:228-254 (scaled_delta: team decay + climate only)` · `scripts/systems/hr_system.gd:224-247 (tick_overload writes the counter; only output_mult_for_area reads it)`


**`auto.positive_big_signing` — Big signing can never fire in a real run**  
**DIVERGENT** · HIGH — the second of the two positive beats is dead for the same ordering reason, leaving one reachable recovery channel in the whole module  
GDD: ch.07 rev 2 §7  

> Girdiler: ... başarı ve başarısızlık anları (sürüm çıktı, hesap kaybedildi, kesinti) ...

A large new account is a 'başarı anı' under §7's governed input class (stated caveat: it is not one of the three parenthetical examples, which are ship / account lost / outage — so the governance here is by class, not by name). _big_signing_today requires a Customer with acquired_on_day == GameState.day at slot-3 time (hr_morale_system.gd:193-195, :538-551). Every writer of acquired_on_day runs strictly later: sales_system.gd:286 (B2C aggregate) and :372 (add_b2b_customer, shared by the played pitch and the rep auto-close), reached from slot 4 or from a modal. A customer stamped on day N is first visible to HR on N+1, when the equality fails.  
*Costs the player:* nothing; the wired +4 never arrives  
*If removed:* nothing observable would change today  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §7 line 90` · `scripts/systems/hr_morale_system.gd:193-195, :538-551` · `scripts/systems/sales_system.gd:286, :372` · `scripts/systems/b2b_sales_system.gd:33-43`


**`auto.positive_ship_glow` — Ship glow can never fire in a real run**  
**DIVERGENT** · HIGH — the one morale reward the player earns by doing the game's central act (shipping) is structurally unreachable; static-ordering argument, not runtime-verified per instruction  
GDD: ch.07 rev 2 §7  

> Girdiler: fazla mesai · aşırı yüklenme · başarı ve başarısızlık anları (sürüm çıktı, hesap kaybedildi, kesinti) · lider Liderliği · event'ler.

'sürüm çıktı' is named in the GDD's morale input list and the code has the beat wired (+SHIP_GLOW_MORALE 6 to every employee) but its trigger is days_since_last_ship() == 0, i.e. a ship stamped TODAY (hr_morale_system.gd:189-192, :307-314). mvp_version_history is appended only by ProductSystem.ship_active_build (:1521-1542), whose only production caller is the ship_moment modal's modifier inside EventManager._apply_modifiers (event_manager.gd:666-667) — a player click, which lands after slot 13 of that day. HR runs at slot 3, and the hour-0 hourly tick fires before advance_day (time_manager.gd:138-144), so the value HR reads is always 1 or more.  
*Costs the player:* nothing; the governed +6 recovery never arrives  
*If removed:* nothing observable would change today — that is exactly the finding  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §7 line 90 ("sürüm çıktı")` · `scripts/systems/hr_morale_system.gd:189-192, :307-314` · `scripts/systems/product_system.gd:1521-1542` · `scripts/autoload/event_manager.gd:666-667` · `scripts/autoload/time_manager.gd:138-144`


**`auto.remove_vacates_jobs` — A departure vacates the leaver's areas — but the card never asks who takes over**  
**DIVERGENT** · HIGH — the departure is the module's terminal consequence and the GDD's design for it is a routed decision moment, which is exactly the half that is missing  
GDD: ch.07 rev 2 §9  

> Ayrılma bir event anıdır. Ayrılan kişinin işleri boşalır ve oyuncuya sorulur: "Melisa gitti, müşterilerine kim bakacak?" / "Ekip lideri istifa etti, yerine kim geçiyor?" Kart oyuncuyu ilgili sayfaya yönlendirir (müşteri sahipliği için Satış, ekip için Ekip). Otomatik kurucuya devir varsayılan değildir.

Two of the three clauses are honoured structurally: CharacterRegistry.remove clears assigned_jobs and calls GameState.release_area_leads(id) before erasing (character_registry.gd:530-548), and there is no automatic hand-over to the founder. The third is absent: HREventFactory.build_resignation ships a single acknowledgement choice with no question and no routing (hr_event_factory.gd:29-42), so the player is told someone left and is never asked who covers them. The successor question is doubly unanswerable because the lead seat the GDD asks about is itself unreachable (auto.area_lead_derivation).  
*Costs the player:* the leaver's areas silently go empty; a delegated CS book falls back to the founder on the next reconcile and a build crew shrinks with no prompt  
*If removed:* removing the vacate would leave a dead id holding areas and an area-lead seat; removing the acknowledgement event would let a person vanish with no beat at all  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §9 line 101` · `scripts/autoload/character_registry.gd:530-548` · `scripts/systems/hr_event_factory.gd:29-42 (single acknowledgement choice)` · `scripts/autoload/game_state.gd:600-608`


**`auto.sales_rep_desk_boundary` — BOUNDARY · The sales desk generates and warms leads automatically, and closes routine ones**  
**DIVERGENT** · HIGH — it is where a hiring decision turns directly into revenue, and the revenue currently arrives without the played moment the spine chapter makes non-negotiable  
GDD: ch.04 §2 (with ch.01 §9)  

> Sales capacity = number of people assigned to sales (sales hires + founder when assigned to selling, chapter 02 §5). Unworked leads wait, then cool and drop. No capacity = no new accounts, whatever marketing spends. ... Pitch flow (existing PitchSystem) is the close moment; KEEP.

The capacity half is governed and honoured exactly: SalesRepSystem gates on the SATIŞ AREA being staffed, the founder counts when assigned, and with nobody assigned the whole file returns before touching state (sales_rep_system.gd:32-41). Lead generation and warming follow §2's lead→opportunity→close shape with no RNG. The close half diverges: anything whose archetype band ceiling is at or under AUTONOMOUS_CLOSE_MRR_MAX 600 and whose pain maps to a shipped feature is closed by the desk itself at AUTO_CLOSE_PROGRESS 1.0 (:167-209), with no pitch played — against §2's "Pitch flow ... is the close moment; KEEP" and ch.01 §9's non-negotiable "Every economic outcome comes from a played decision moment." Everything above 600 correctly warms for the founder instead. FAR SIDE NOT AUDITED: the pipeline, band and pain-mapping economics are ch.04's.  
*Costs the player:* the rep's salary; in exchange, sub-600 MRR accounts arrive with no decision moment  
*If removed:* removing the auto-close leaves the desk as a pure warm-up engine and every account back through the pitch; removing the desk removes all B2B lead flow, since find_prospects auto-spawn was retired per §2  
*Verification:* NARROWED by a GDD line the first reader did not cite. ch.07 rev 2 §4's job table, lines 66-68, reads "Satış | Satış | lead işleme, kapanış" — closing IS a governed effect of staffing the Satış area. So the desk's existence and its closing role are authorised; what diverges is only that the close happens with NO played moment, against ch.04 §2 "Pitch flow (existing PitchSystem) is the close moment; KEEP" and ch.01 §9. The row should quote §4 so the finding reads as "unplayed close", not "unauthorised desk". Everything else verified in the body: the AREA gate at sales_rep_system.gd:32-36 (not the role), the founder counted through _ranked (:46-58) exactly as ch.02 §5 asks, the §10 gate at …  
Evidence: `GDD ch.04 §2 lines 8-11; GDD ch.01 §9 line 38` · `scripts/systems/sales_rep_system.gd:32-41, :100-123, :128-147, :167-209` · `scripts/systems/b2b_constants.gd:291-319`


**`auto.training_founder_reseat_collision` — A build phase change while the founder is in training leaves him permanently unassigned**  
**DIVERGENT** · HIGH — reachable from two ordinary player actions, silent, and unrecoverable through any screen the GDD gives the player  
GDD: ch.02 §5 (with ch.07 rev 2 §3 and §4)  

> ch.02 §5: "The founder is an employee who holds ONE job at a time: building a version, selling, or fundraising (Hunt)." — ch.07 §4: "Kurucu bu ekranda görünmez ama kurucunun mevcut görevi Kişisel'de okunur ve bir işe atandığında diğer eylemler gerekçesiyle kilitlenir (chapter 02 §5)."

Two separately governed features collide and produce a state the model has no name for: a founder holding ZERO jobs with no player-side cure. ProductSystem._reseat_founder calls clear_areas then assign_area (product_system.gd:405-419); clear_areas has no status check (character_registry.gd:244-252) while assign_area refuses with 'inactive' for any status != STATUS_ACTIVE (:210-231). Send the founder to training — itself governed by ch.07 §3 ('kurucunun kartı, skill'leri ve eğitimi Kişisel sayfasındadır') — then advance the build phase, and his area is wiped, the re-seat push_errors, and nothing reassigns him, including at training completion. He then contributes no build speed, accrues no experience, and build_paused() can stall the build. The Görevler matrix iterates get_employees() and so has no founder row (hr_assignments.gd:32-47), and _reseat_founder is the only writer of his assignment: the next phase transition is the only cure.  
*Costs the player:* the founder's entire build contribution and his learn-by-doing for the rest of the phase, on top of the training fee already paid  
*If removed:* the collision cannot be 'removed' — either guard (skip the clear while non-ACTIVE, or re-seat on training completion) closes it; removing _reseat_founder entirely would break the governed one-job-at-a-time model  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.02 §5 lines 43-47; GDD ch.07 rev 2 §3 line 46, §4 line 76` · `scripts/systems/product_system.gd:405-419 (clear then assign), call sites :854, :905, :1363, :1462` · `scripts/autoload/character_registry.gd:210-231 (assign_area refuses non-ACTIVE), :244-252 (clear_areas unguarded)` · `scripts/tabs/hr/hr_assignments.gd:32-47 (matrix iterates get_employees — no founder row)` · `scripts/autoload/character_registry.gd:135-150`


**`auto.attention_count` — Left-rail HR badge — three automatic sources, one number**  
**GOVERNED**  
GDD: ch.12 §4 (with ch.12 §8)  
HRSystem.attention_count sums people carrying any badge, plus 1 for a waiting candidate file, plus 1 for Frank's hire nudge; attention_people_count is the PEOPLE-only sibling used by the Ekip header (hr_system.gd:358-384). The nudge fires when GameState.flags[AngelRoundSystem.FLAG_ACCEPTED_DAY] > 0 and get_employees() is empty — a signpost that clears itself on the first hire and that nothing reads as a requirement. REMAINDER: neither of the two non-people addends is one of ch.12 §4's enumerated badge classes, and neither has an 'exact row' to click through to, which is the half of §4's rule they cannot satisfy.  
Evidence: `GDD ch.12 §4 line 10, §8 line 20` · `scripts/systems/hr_system.gd:358-384` · `scripts/systems/angel_round_system.gd:40, :184` · `scripts/systems/hr_search_system.gd:83-86`


**`auto.badges_derived` — Attention badges are DERIVED every read, never stored**  
**GOVERNED**  
GDD: ch.12 §4 (with ch.07 rev 2 §5)  
HRSystem.badges_for → HRMoraleSystem.badges_for returns worst-first: FLIGHT_RISK (morale < 25), BURNING_OUT (morale < 40), OVERLOADED (hr_morale_system.gd:261-279). Character.attention_flag is declared and deliberately never written, because one String cannot hold two simultaneous badges (character.gd:93-96). Thresholds come from the single comparison home is_burning_out / is_flight_risk, so counter, badge and valve can never disagree — which is what ch.12 §4's click-to-the-exact-row rule requires. BADGE_NEW is informational and kept out of badges_for so it cannot light the rail. TWO REMAINDERS: ch.12 §4's list is an enumeration and BADGE_BURNING_OUT (morale < 40) has no entry in it — an addition, not a divergence; and the third badge is not the governed overload one (auto.badge_overloaded_collision).  
Evidence: `GDD ch.12 §4 line 10; GDD ch.07 rev 2 §5 line 79` · `scripts/systems/hr_morale_system.gd:261-279` · `scripts/systems/hr_system.gd:351-355` · `scripts/systems/hr_constants.gd:774-793` · `scripts/data_models/character.gd:93-96`


**`auto.confirm_departure` — confirm_departure — the only door a resignation leaves the roster through**  
**GOVERNED**  
GDD: ch.07 rev 2 §9 (with ch.08 §1)  
Verified body: the hr_departure modifier on the resignation event's single choice clears the latch, guards that the target is category 'employee' (push_error and abort otherwise, so the founder and Frank can never leave through this path), charges the remaining team, then calls CharacterRegistry.remove (hr_morale_system.gd:383-404). SEVERANCE_ON_RESIGN is 0 — consistent with ch.08 §1's one-off cost list, which names Atlas retainer, eğitim, lisans and kesinti telafisi and no severance — and with §9's 'Bilgi kaybı / teknik borç cezası yok'. The removal itself increments GameState.run_departures, clears assigned_jobs and calls release_area_leads. What is missing is §9's ASK, scored on auto.remove_vacates_jobs.  
Evidence: `GDD ch.07 rev 2 §9 lines 101-102; GDD ch.08 §1 line 4` · `scripts/systems/hr_morale_system.gd:383-404 (verified body)` · `scripts/autoload/character_registry.gd:530-548` · `scripts/systems/hr_event_factory.gd:29-42` · `scripts/autoload/event_manager.gd:636-643`


**`auto.cs_dampen_boundary` — BOUNDARY · The assigned rep automatically slows satisfaction erosion**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 and §4  
B2BSalesSystem._tick_satisfaction multiplies any NEGATIVE drift by B2BConstants.cs_dampen(rep's Müşteri Başarısı) whenever the account has an assigned_to, and again by the HAYIR DİYEMEZ trait's satisfaction_bonus; upward recovery stays full strength (b2b_sales_system.gd:68-102). Verified: cs_dampen = clamp(1 − CS_DAMPEN_PER_POINT 0.055 × area, CS_DAMPEN_MIN 0.4, 1.0), so a top rep roughly halves erosion (b2b_constants.gd:219-227). An ON-LEAVE rep dampens NOTHING (_cs_expertise_of returns 0 for status != ACTIVE), so leave has an immediate customer-side cost — a leave-subsystem consequence with no GDD line behind it. FAR SIDE NOT AUDITED: churn and lifecycle are ch.04's.  
Evidence: `GDD ch.07 rev 2 §2 line 38, §4 lines 63-65` · `scripts/systems/b2b_sales_system.gd:68-102` · `scripts/systems/b2b_constants.gd:219-227 (verified cs_dampen)` · `scripts/systems/hr_constants.gd:518-522`


**`auto.cs_delegate_excess` — CS auto-DELEGATION — only the founder's excess is handed over**  
**GOVERNED**  
GDD: ch.07 rev 2 §5 (with ch.06 §1.3)  
'aşımda hesaplar otomatik devrolur' is exactly what this does. _delegate_excess hands out only what exceeds FOUNDER_DIRECT_CAP, oldest account first, into rep free slots ranked by Müşteri Başarısı, filtered to unassigned, unpinned accounts in CS_ASSIGNABLE_PHASES [active, risk, expansion] — so the founder onboards every new account personally (customer_rep_system.gd:138-175). Deliberately not 'fill every rep on hire', which would strip accounts the founder is comfortably holding. ONE DEVIATION FROM THE CHAPTER'S SHAPE, verified: FOUNDER_DIRECT_CAP is a flat 4 (b2b_constants.gd:195) rather than being derived from the founder's own Müşteri Başarısı the way every employee's cap is — §5's rule is stated 'kişi başına' and the founder is a person carrying that area. The flat value is inside the [WORKING 3–6] band, so the divergence is in the derivation, not the number.  
Evidence: `GDD ch.07 rev 2 §5 line 82; GDD ch.06 §1.3 line 16` · `scripts/systems/customer_rep_system.gd:138-175, :97-104` · `scripts/systems/b2b_constants.gd:195 (verified FOUNDER_DIRECT_CAP 4, flat), :327`


**`auto.cs_escalation_beat_boundary` — BOUNDARY · A delegated account raises one rep-voiced escalation when it sinks**  
**GOVERNED**  
GDD: ch.07 rev 2 §4 and §7 (with ch.11 §5)  
B2BSalesSystem._tick_cs_escalation enqueues one modal per crossing when a delegated account falls under CS_ESCALATION_SAT 35, latched on c.cs_escalated and re-armed when it recovers (b2b_sales_system.gd:158-179) — a system-edge trigger in ch.11 §5's grammar, and the 'risk kartları' half of §4's table. The refusal branch applies −B2BConstants.CS_REFUSE_MORALE 10 to the CS EMPLOYEE through the `morale` modifier (b2b_event_factory.gd:131, event_manager.gd:571-586) — one of only two authored per-character morale writes in the whole game and the ONLY reachable one, the other being the inert ev_debug_001. Separate from the request channel. FAR SIDE NOT AUDITED: satisfaction and churn are ch.04's.  
Evidence: `GDD ch.07 rev 2 §4 lines 63-65, §7 line 90; GDD ch.11 §5 line 13` · `scripts/systems/b2b_sales_system.gd:158-179` · `scripts/systems/b2b_constants.gd:196-199` · `scripts/systems/b2b_event_factory.gd:131` · `scripts/autoload/event_manager.gd:571-586`


**`auto.cs_release_unheld` — CS auto-RELEASE — accounts fall back to the founder without the player acting**  
**GOVERNED**  
GDD: ch.07 rev 2 §5 (with ch.06 §1.3)  
The cap and the automatic hand-over are both built, and the number lands exactly inside the [WORKING 3–6] band: verified B2BConstants.cs_capacity = CS_BASE_CAPACITY 3 + floor(Müşteri Başarısı / CS_PACE_PER_SLOT 3), ladder 0-2→3, 3-5→4, 6-8→5, 9→6 (b2b_constants.gd:189-212). _release_unheld runs first inside reconcile_assignments and unassigns any account whose rep is missing, not ACTIVE, or beyond the current cap, clearing its pin; pinned accounts are walked first so a player pin cannot lose a race against dictionary order (customer_rep_system.gd:97-135). UNGOVERNED REMAINDER: the rep.status != STATUS_ACTIVE branch means an annual-leave day releases that rep's entire book, and annual leave has no GDD line at all.  
Evidence: `GDD ch.07 rev 2 §5 line 82; GDD ch.06 §1.3 line 16` · `scripts/systems/customer_rep_system.gd:97-135` · `scripts/systems/b2b_constants.gd:189-212 (verified ladder and CS_BASE_CAPACITY 3)` · `scripts/systems/b2b_sales_system.gd:36-37`


**`auto.cs_work_queue` — The desk works the queue automatically: absorb or escalate**  
**GOVERNED**  
GDD: ch.06 §1.2 (with ch.07 rev 2 §2)  
The capacity side of §1.2 is built with the right factors. _work_the_queue spends a daily budget over open requests oldest-first: budget = banked progress + Σ over rank-ordered reps of (CS_THROUGHPUT_BASE 0.5 + 0.15 × Müşteri Başarısı) × REP_STACK_DECAY^rank, × HROvertimeSystem.speed_multiplier(DEPT_CUSTOMER) (customer_rep_system.gd:247-276, :83-92). Two deliberate readings of the formula: the Hız term is correctly absent because ch.07 rev 2 §2 deleted the skill, and assigned_heads is rank-decayed rather than linear (an ungoverned choice). Each request is absorbed or escalated by difficulty (1 + 2 if the pain feature is unshipped + 2 if satisfaction < tolerance + scale − 1) against a ceiling of CS_ABSORB_BASE 3 + top rep's Müşteri Başarısı. Absorption credits NO satisfaction on purpose and is genuinely silent — only a sales-log row. At most one request's worth of idle capacity banks.  
Evidence: `GDD ch.06 §1.2 line 12; GDD ch.07 rev 2 §2 lines 36-40` · `scripts/systems/customer_rep_system.gd:247-276, :225-244, :83-92` · `scripts/systems/b2b_constants.gd:342-348`


**`auto.desk_market_gate` — BOUNDARY · Both autonomous desks only run on a SHIPPED B2B product**  
**GOVERNED**  
GDD: ch.04 §1 and §4 (market split)  
SalesSystem.daily_tick reaches B2BSalesSystem only when flags['mvp_shipped'] and mvp_market_type == 'b2b'; B2BSalesSystem re-checks mvp_shipped (sales_system.gd:131-153, b2b_sales_system.gd:23-25). The gate's own comment records why it was added: without it one Satış Uzmanı in a consumer run minted and closed enterprise contracts with no pitch ever played — i.e. the gate is what keeps the code inside ch.04 §4's B2C model, which has no account or sales-capacity term. CONSEQUENCE WORTH RECORDING: ch.07 §4's job table lists 'Satış | Satış | lead işleme, kapanış' and 'Hesap sahipliği | Müşteri Başarısı · Satış' with no market qualifier, so in a B2C run a Satış Uzmanı and a Müşteri Temsilcisi are pure payroll with literally zero mechanical effect — the CS delegation, the request channel and the whole rep desk never tick.  
Evidence: `GDD ch.01 §7 line 31; GDD ch.04 §4 line 18; GDD ch.07 rev 2 §4 table lines 63-68` · `scripts/systems/sales_system.gd:131-153` · `scripts/systems/b2b_sales_system.gd:23-25`


**`auto.experience_accrual` — Learn-by-doing — daily experience per ASSIGNED AREA, founder included**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 (with §2 and ch.02 §7)  
Built as written, including the Liderlik term. tick_experience credits every ACTIVE employee plus the founder in each assigned area: base EXPERIENCE_PER_DAY 1 (or EXPERIENCE_PER_BUILD_DAY 2 while any build phase runs) × experience_gain_mult(lead's Liderlik, 1.0→EXPERIENCE_LEAD_BONUS_MAX 1.5) × load_mult × trait_mult(experience_mult) × trait_mult(mentor's lead_experience_mult), floored at 1 (hr_system.gd:89-122). Idle people learn nothing, matching §4's 'Atanmamış kişi boşta durur'; on-leave and in-training people are excluded via get_active_employees. Multiple assignments do not split the gain — each area is credited separately. `research` accrues nothing since it is not in HRConstants.AREAS, so §4's Araştırma job grows no one. UNGOVERNED DETAIL: EXPERIENCE_PER_BUILD_DAY 2 applies to EVERYONE while a build runs, including sales and CS staff who are not on the build.  
*Chapter conflict:* ch.02 §7 lists mentoring as a separate tertiary channel ('Tertiary: mentoring (a high-skill teammate lifts a low-skill one)'); ch.07 rev 2 §2 overrides it with 'Mentorluk ayrı bir trait ya da sistem değildir; Liderlik'in içindedir.' The code satisfies neither cleanly: it reads the Liderlik term AND a GERÇEK LİDER trait carrying lead_experience_mult 1.5, i.e. mentoring as exactly the separate …  
Evidence: `GDD ch.07 rev 2 §8 line 97, §2 line 42; GDD ch.02 §7 lines 53-55` · `scripts/systems/hr_system.gd:89-122, :308-312` · `scripts/systems/hr_constants.gd:809-812, :188-193`


**`auto.experience_founder_traits_inert` — The founder as derived area lead can never grant the mentor bonus**  
**GOVERNED**  
GDD: ch.07 rev 2 §12  
The GDD books this exact defect as a known open item, in the exact terms the code exhibits. tick_experience asks HRSystem.area_lead(area) for a mentor and then HRConstants.trait_mult(mentor.traits, 'lead_experience_mult') (hr_system.gd:116-121); area_lead falls back to the founder when nobody is assigned (:187-206, verified); founder traits come from FounderConstants.TRAITS (visionary/disciplined/…), which shares no id with HRConstants.TRAITS, so the lookup silently returns 1.0 (founder_constants.gd:63-75). His LİDERLİK does feed through, because experience_gain_mult reads role_stats['leadership'] which FounderConstants.SKILLS contains — only his TRAITS are inert. ProductSystem records the same defect as already fixed on its own side ('trait_has kurucunun id'lerini ÇALIŞAN tablosunda arıyordu ve DAİMA false dönüyordu', product_system.gd:498-506); it survives here.  
Evidence: `GDD ch.07 rev 2 §12 line 117` · `scripts/systems/hr_system.gd:116-121, :187-206` · `scripts/systems/founder_constants.gd:63-75` · `scripts/systems/product_system.gd:498-506 (same defect, fixed there)`


**`auto.flight_risk_accrual` — Flight-risk counter — +1 per consecutive day under morale 25**  
**GOVERNED**  
GDD: ch.07 rev 2 §7 (with ch.12 §4)  
tick_thresholds walks get_employees(), increments flight_risk_days for anyone under MORALE_FLIGHT_RISK 25 and zeroes it otherwise, then hands them to _maybe_resign (hr_morale_system.gd:124-145). The step moves NO morale — a quiet bad day costs the player time, not points. On-leave people are skipped so the counter FREEZES rather than resets: a holiday cannot launder neglect and cannot answer it either. In-training people are NOT skipped (auto.training_flightrisk_asymmetry). The threshold comes from the single comparison home is_flight_risk, so the counter, the badge and the overtime valve can never disagree about the boundary — which is what ch.12 §4's click-to-the-exact-row rule needs.  
Evidence: `GDD ch.07 rev 2 §7 line 91; GDD ch.12 §4 line 10` · `scripts/systems/hr_morale_system.gd:124-145, :27-34` · `scripts/systems/hr_constants.gd:870-880`


**`auto.lead_leadership_for` — Lead-Liderlik lookup takes the BEST lead across a person's areas**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (with §8)  
Verified body: area_lead_leadership_for returns the highest Liderlik among the leads of all areas the person holds, skipping the case where they are their own lead (hr_system.gd:209-221). It feeds experience_gain_mult, 1.0 at Liderlik 0 → EXPERIENCE_LEAD_BONUS_MAX 1.5 at 10. The in-body rationale is that taking the WORST lead would bill the overload decision twice, since §5 already penalises it. Applied once per person, whereas the GERÇEK LİDER mentor multiplier is asked per AREA — two granularities in one loop, deliberately. Its input is the derived lead, so the branch the GDD actually legislates (an assigned lead) never participates (auto.area_lead_derivation).  
Evidence: `GDD ch.07 rev 2 §2 line 42, §8 line 97` · `scripts/systems/hr_system.gd:209-221 (verified body)` · `scripts/systems/hr_system.gd:102-121` · `scripts/systems/hr_constants.gd:188-193`


**`auto.morale_no_drift` — There is no autonomous morale drift — deleted, not tuned to zero**  
**GOVERNED**  
GDD: ch.07 rev 2 §7  
§7's input list is a closed enumeration and passive drift is not in it, so the absence conforms. Verified by enumeration of writers: the only writers of Character.morale are CharacterRegistry.set_morale (from apply_delta, and from event_manager.gd:586 for non-employees) and the raw field assignment in _build_founder/_seed_debug_characters. tick_thresholds explicitly moves no morale (hr_morale_system.gd:140-145). The old ±1/day-toward-50 tick was removed rather than zeroed so a future reader has nothing to switch back on (hr_system.gd:15-21). STALE COMMENT (M1): TimeManager's slot comment still says HR 'applies baseline morale drift' (time_manager.gd:312-313).  
Evidence: `GDD ch.07 rev 2 §7 line 90 (closed input list)` · `scripts/systems/hr_system.gd:15-21` · `scripts/systems/hr_morale_system.gd:21-25, :140-145` · `scripts/autoload/time_manager.gd:312-313 (stale)`


**`auto.morale_seam` — apply_delta / scaled_delta — the single morale scaler every automatic channel passes through**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (with ch.02 §8)  
Every automatic morale movement lands here and the Liderlik term is folded in exactly once: negative deltas × _team_decay_mult (product of dept_morale_decay_mult 1.25 per TAT KAÇIRAN teammate in the same department, carrier and on-leave excluded) × climate_drop_mult = clamp(1 − 0.05×Liderlik, 0.50, 1.0); positive deltas × climate_gain_mult = clamp(1 + 0.05×Liderlik, 1.0, 1.50); then clamped by CharacterRegistry.set_morale to 0..100 (hr_morale_system.gd:206-254, hr_constants.gd:883-913). The TAT KAÇIRAN term is a trait acting as a rate modifier, which is what ch.02 §8 permits. A scaled negative that rounds below half a point is DROPPED, not rounded to −1, explicitly so the deleted drift cannot grow back. Non-employees return early: the founder and Frank have no morale machine.  
*Chapter conflict:* ch.02 §4 defines Liderlik as 'morale ceiling + team output multiplier'; ch.07 rev 2 §2 (operative) redefines it as an efficiency modifier plus morale-decay rate plus experience rate. The code implements ch.07: MORALE_MAX is a flat 100 for everyone and no ceiling exists.  
Evidence: `GDD ch.07 rev 2 §2 line 42; GDD ch.02 §8 line 58, §4 line 40` · `scripts/systems/hr_morale_system.gd:206-254, :160-173` · `scripts/systems/hr_constants.gd:883-913` · `scripts/autoload/character_registry.gd:590-602`


**`auto.overload_accrual` — Overload counter — +1/day while carrying 2+ areas**  
**GOVERNED**  
GDD: ch.07 rev 2 §5  
The counter is the implementation of 'kısa süre tolere edilir': tick_overload increments Character.overload_days for every ACTIVE employee holding more than one assigned area and resets to 0 the moment they hold one or none (hr_system.gd:224-232, verified body). On-leave AND in-training people neither accrue nor reset — the counter FREEZES, matching the flight-risk grammar. Written through CharacterRegistry.set_overload_days, which does not emit; unassign_area/clear_areas also zero it directly.  
Evidence: `GDD ch.07 rev 2 §5 line 81` · `scripts/systems/hr_system.gd:224-232` · `scripts/autoload/character_registry.gd:255-259, :234-252`


**`auto.overload_bite_output` — Overload bites OUTPUT after 5 days — and only output**  
**GOVERNED**  
GDD: ch.07 rev 2 §5  
The output half of §5 is built, and the two-tier model ('ana alan normal, ikincil alan yorucu') is honoured by two separate multipliers: OVERLOAD_OUTPUT_MULT 0.75 once overload_bites is true (2+ areas AND overload_days > OVERLOAD_TOLERANCE_DAYS 5) on top of SECONDARY_AREA_MULT 0.7 when working outside the key area (hr_system.gd:149-156, :235-260; hr_constants.gd:144-147, :217-225). Consumers: ProductSystem._phase_area_sum:529 and :802, SalesRepSystem._diminished_sum:77, HRSystem.area_sum_for:259. The tolerance is the implementation of 'kısa süre tolere edilir'; both weights are [WORKING] and therefore governed-but-uncalibrated per M3. The morale half of the same sentence is not built (auto.overload_no_morale).  
Evidence: `GDD ch.07 rev 2 §5 lines 80-81` · `scripts/systems/hr_system.gd:149-156, :235-260` · `scripts/systems/hr_constants.gd:144-147, :217-225`


**`auto.overtime_day_charge` — Overtime block — one billed night per day, per department**  
**GOVERNED**  
GDD: ch.07 rev 2 §7 (morale input only)  
GOVERNED FOR ONE OF ITS THREE EFFECTS. The morale cost is exactly what §7 names: _charge_day drops every participant by overtime_morale_drop(day_index) = 2 (days 1-3), 4 (4-7), 7 (8+), multiplied by the carrier's overtime_morale_mult trait and then by team decay and climate inside apply_delta (hr_overtime_system.gd:119-144, hr_constants.gd:1042-1066). UNGOVERNED REMAINDER, no GDD counterpart anywhere: the department-block structure and OVERTIME_BLOCKS [3,7,14]; the pay channel at OVERTIME_PAY_PCT 0.40 of daily salary; the speed/bug multipliers (auto.overtime_coupling_boundary). ch.08 §1's burn enumeration does not contain overtime pay. The founder is structurally absent from participants() — never paid, never tired — which is the same hole as conflict.ch02_founder_energy. A full 14-day block costs one participant 6+16+49 = 71 RAW morale points, enough on its own to take a fresh hire …  
*Chapter conflict:* ch.02 §6 makes overtime the primary input to a founder energy bar that does not exist and from which the founder is structurally excluded here; ch.07 rev 2 §7 makes overtime an employee morale input, which is the half that is built  
Evidence: `GDD ch.07 rev 2 §7 line 90; GDD ch.02 §6 line 49; GDD ch.08 §1 line 4 (burn enumeration omits overtime pay)` · `scripts/systems/hr_overtime_system.gd:79-107, :119-144, :268-297` · `scripts/systems/hr_constants.gd:1042-1066`


**`auto.payroll_pull` — Payroll burns automatically every day, on-leave staff included**  
**GOVERNED**  
GDD: ch.08 §1 (with ch.07 rev 2 §4 and §10)  
FinanceSystem.daily_tick pulls CharacterRegistry.get_total_monthly_salaries() and converts it once via daily_salary_for into burn_breakdown['salaries'] (finance_system.gd:137-138, :213-218). The founder contributes 0 and is category 'founder' so the sum skips him; Frank is category 'mentor' and likewise excluded — matching ch.07 §10 exactly. The idle-employee clause is honoured because the sum is headcount-based, not assignment-based. UNGOVERNED REMAINDER: the registry sum is deliberately NOT status-filtered so annual leave is paid leave — and annual leave has no GDD line at all (see auto.leave_departure). BOUNDARY NOTED, far side not audited: FinanceSystem.BURN_IDS is ['salaries','overtime','founder','marketing','office'] (finance_system.gd:47), which contains a 'founder' key and no 'araçlar'/'servis maliyeti' naming — a Finance-module question.  
Evidence: `GDD ch.08 §1 lines 4-5; GDD ch.07 rev 2 §4 line 75, §10 line 107` · `scripts/systems/finance_system.gd:137-138, :213-218, :47 (verified BURN_IDS)` · `scripts/autoload/character_registry.gd:412-421` · `scripts/autoload/game_state.gd:952`


**`auto.positive_gate` — Positive morale events — one per tick, freshest cause first, 14-day cooldown**  
**GOVERNED**  
GDD: ch.07 rev 2 §7 and §10 (with ch.11 §5)  
The recovery channel the GDD's input list implies. tick_positive_events returns on an empty roster or an unexpired cooldown, then tests three triggers in a deterministic freshest-first order and fires at most one (hr_morale_system.gd:176-199) — which also satisfies ch.11 §5's 'at most one per day' texture ceiling. The cooldown stamp IS the once-only latch, because the factory ids are shared rather than per-character and a synthetic event ignores one_shot; it is stamped at ENQUEUE, not at resolve, so an unread beat still blocks the next one. Morale lands only when the player reads the modal, via the morale_all_employees modifier — never from this file, which keeps ch.11 §4's played-cost grammar. POSITIVE_EVENT_COOLDOWN_DAYS 14 is ungoverned.  
Evidence: `GDD ch.07 rev 2 §7 line 90, §10 line 108; GDD ch.11 §5 line 13` · `scripts/systems/hr_morale_system.gd:176-199, :509-522` · `scripts/systems/hr_constants.gd:1069-1080` · `scripts/autoload/event_manager.gd:587-589`


**`auto.positive_placeholder_status` — hr_constants.gd:1069 is NOT a stub — the numbers are live, only the copy is placeholder**  
**GOVERNED**  
GDD: ch.14 §2 (with ch.11 §3)  
Placeholder copy awaiting the director's content pass is exactly the division of labour ch.14 §2 legislates, so the header's '(placeholder)' is a governed state, not a defect. Read against the bodies: CALM_STRETCH_DAYS/MORALE/MAX_MORALE, BIG_SIGNING_MRR/MORALE, SHIP_GLOW_MORALE and POSITIVE_EVENT_COOLDOWN_DAYS are all genuinely consumed by tick_positive_events and HREventFactory (hr_constants.gd:1069-1080, hr_morale_system.gd:176-199, hr_event_factory.gd:66-90). Per M3 the label means 'not balance-passed', not 'undesigned'. WARNING FOR THE CONTENT SPRINT: two of the three triggers are dead for a structural reason unrelated to the copy, so replacing the wording alone would ship two beats that still never appear.  
Evidence: `GDD ch.14 §2 line 9; GDD ch.11 §3 line 9` · `scripts/systems/hr_constants.gd:1069-1080` · `scripts/systems/hr_morale_system.gd:176-199` · `scripts/systems/hr_event_factory.gd:66-90`


**`auto.reseat_comment_contradiction` — hr_assignments.gd's header contradicts itself about the founder**  
**GOVERNED**  
GDD: ch.07 rev 2 §4 (with §3)  
The GDD settles the question and the BODY obeys it: build() iterates CharacterRegistry.get_employees(), which excludes category 'founder' (hr_assignments.gd:37, character_registry.gd:54-62). The defect is documentation only, and self-contradictory: lines 11-13 describe a 'KURUCU BANDI en üstte (10b): yıldızsız satır, yalnız işaretlenebilir kutular, yedi alan da onun', while lines 27-31 of the same header say 'KURUCU BURADA YOK (R1, 2026-08-21). Ne satır, ne kutu, ne salt-okunur bant.' Under M1 this matters operationally, because the first comment is the one a reader hits first and it is the comment that would make them believe auto.training_founder_reseat_collision has a manual workaround. It does not.  
Evidence: `GDD ch.07 rev 2 §4 line 76, §3 line 46` · `scripts/tabs/hr/hr_assignments.gd:11-13, :27-31, :37` · `scripts/autoload/character_registry.gd:54-62`


**`auto.reseat_founder` — _reseat_founder — the engine reassigns the founder without the player acting**  
**GOVERNED**  
GDD: ch.02 §5 (with ch.07 rev 2 §4 and ch.01 §5)  
The one-area lock is enforced structurally: on every build phase transition assigned_jobs is cleared and exactly one area is assigned — start_build → iteration (product_system.gd:1363), enter_development → development (:854), enter_beta → bugfix (:905), start_version_build → iteration (:1462) — with an early-out when he already holds precisely that area, and a second enforcement in assign_area's founder_busy branch (character_registry.gd:221-223). Which area comes from _founder_phase_area (:438-447). NOT called on ship_active_build or cancel_build, so after a ship he stays where the last phase left him. The engine performing the seating with no player gate (R1, 2026-08-21) is consistent with ch.07 §4's 'Kurucu bu ekranda görünmez' and with ch.01 §5's founder-time pressure being expressed as which activity he is in, not which area inside it.  
Evidence: `GDD ch.02 §5 lines 43-47; GDD ch.07 rev 2 §4 line 76; GDD ch.01 §5 line 23` · `scripts/systems/product_system.gd:405-419, :438-447, :298-305` · `scripts/autoload/character_registry.gd:221-223`


**`auto.resign_roll` — Resignation roll — days 10-13 a coin flip, day 14 a certainty**  
**GOVERNED**  
GDD: ch.07 rev 2 §7 (with §9)  
The ladder's third rung, built as specified. _maybe_resign runs every integer guard before touching RNG, then rolls once per day inside the window: chance = RESIGN_CHANCE_PER_DAY 0.25 × trait_mult(resign_chance_mult) [SADIK ×0.6, GÖZÜ YÜKSEKTE ×1.6] + 0.15 for a 'Devam et' answer, clamped 0..1, forced to 1.0 at RESIGN_WINDOW_MAX_DAYS 14 so a neglected employee can never become immortal (hr_morale_system.gd:468-506). Numbers are ungoverned — the GDD gives no window or per-day chance, not even as [WORKING]. Draws come only from RngStreams.STREAM_HR_MORALE, so a healthy team consumes zero draws and an HR roll can never displace the event deck's stream. STALE COMMENT (M1): the constant claims '~%76 birikimli', which counts five rolls; the body rolls four times (days 10-13) and is certain on day 14, so the true cumulative is 100%.  
Evidence: `GDD ch.07 rev 2 §7 line 91; §9 line 101` · `scripts/systems/hr_morale_system.gd:468-506` · `scripts/systems/hr_constants.gd:949-964`


**`auto.search_arrival` — Atlas candidate files arrive automatically, 2-4 days after commissioning**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 (with ch.02 §9)  
Exact match, including both numbers. HRSearchSystem.daily_tick delivers CANDIDATE_COUNT 3 generated files when GameState.day reaches the stored arrival day, flips state to files_ready and emits one ticker line (hr_search_system.gd:62-72), with SEARCH_ARRIVAL_MIN_DAYS 2 / MAX 4 (hr_constants.gd:710-716). The delay is DERIVED from the seed stored at commission time by _arrival_delay (LCG, modulus 100003 / multiplier 16807 / increment 4711), never rolled, so a reload cannot re-dice the wait and no RNG stream is touched — which is how a 'mühürlü akış' stays sealed across a save. Nothing is enqueued as a modal; arrival is a ticker line.  
Evidence: `GDD ch.07 rev 2 §6 line 84; GDD ch.02 §9 line 62` · `scripts/systems/hr_search_system.gd:62-72, :377-392, :402-409` · `scripts/systems/hr_constants.gd:710-716`


**`auto.training_tick` — Training countdown and completion — automatic, founder included**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 (with §3 for the founder)  
TRAINING_DAYS 14 matches 'iki hafta' exactly, with the in-body note 'rev 2 §8: "Süre iki hafta" (5 idi)'. tick_training walks get_employees() plus the founder, decrements training_days_left, and on completion raises the chosen key by +1 capped at AREA_TRAIN_CAP 8, bumps trainings_done, zeroes that area's experience, returns status to ACTIVE and emits a ticker headline (hr_system.gd:264-285). It runs LAST in the HR day so a completion-day reset cannot be re-credited the same day. The founder was folded in because get_employees() excludes him and he would otherwise hang in STATUS_TRAINING forever — which is ch.07 §3's founder-training clause honoured. INTERPRETATION WORTH RECORDING: 'Tekrarında azalan getiri' is implemented on the PRICE axis, not the gain — the gain is always +1 and TRAINING_REPEAT_SURCHARGE 0.35 compounds the fee instead (hr_constants.gd:1020-1024, verified). …  
*Chapter conflict:* ch.02 §7 says 'training course = cash + person unavailable [WORKING 3 weeks] → +1 in one skill; diminishing on repeat'; ch.07 rev 2 §8 (operative, approved one day later) says 'Süre iki hafta'. Code follows ch.07. ch.02's three-week figure is recorded, not retired.  
Evidence: `GDD ch.07 rev 2 §8 lines 93-96, §3 line 46; GDD ch.02 §7 line 54` · `scripts/systems/hr_system.gd:264-285` · `scripts/autoload/character_registry.gd:180-198` · `scripts/systems/hr_constants.gd:813-826 (verified TRAINING_DAYS 14, AREA_TRAIN_CAP 8), :1020-1024 (repeat surcharge on price)`


---

### Appendix D — Numbers (pass 1d)

108 entries, ungoverned first.


**`num.morale_vacation_return` — MORALE_VACATION_RETURN (20)**  
**UNGOVERNED · PHANTOM CITATION** · LOW.  
Cited '(design doc §7)' at hr_constants.gd:769 — no such document, and no chapter contains manual vacation. Reachable only through send_on_leave(is_manual = true); HRActions' TATİLE GÖNDER trio was removed 2026-08-22 (:115-128) precisely because dropping the leave_taken_year latch would have made this a repeatable morale fountain. Every surviving caller passes false (hr_morale_system.gd:121, main.gd:1703).  
*Costs the player:* Nothing — unreachable.  
*If removed:* Nothing in production; only the is_manual arm at hr_morale_system.gd:95-98 loses its positive branch. Kept deliberately for a future event channel that is out of scope.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:769` · `scripts/systems/hr_morale_system.gd:95-98` · `scripts/systems/hr_actions.gd:115-128`


**`num.overtime_blocks` — OVERTIME_BLOCKS [3, 7, 14]**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — overtime is the largest morale sink and the only player-driven build-speed lever in the module, and no chapter describes it.  
Cited to 'design doc §7b' (hr_overtime_system.gd:4, hr_constants.gd:1027) — no such document. The ONLY overtime sentence in the whole GDD corpus is ch.07 §7's word 'fazla mesai' in the morale input list; ch.02 §6's overtime clause is about founder ENERGY, a system that is not built. No chapter describes blocks, lengths, department scope, a start button, or a valve.  
*Costs the player:* Committing a department for 3/7/14 nights. A 14-night block on three product-dev people at ~$8,000/mo each costs 3 × 14 × round(8000/30 × 0.40) = $4,494 cash and 6+16+49 = 71 raw morale points per head — more than MORALE_HIRE_START 75 gives a fresh hire.  
*If removed:* HROvertimeSystem.start validates against the array (:165-168) and hr_overtime_panel.gd:48 builds one card per entry; with it empty no block can ever start, taking the speed bonus, bug multiplier, pay accrual, morale ladder, the valve, RESIGN_VALVE_PENALTY and CALM_STRETCH_DAYS unreachable with it. Soft duplicate: the three values live again as CSV keys HR_OVERTIME_BLOCK_3/7/14 (strings.csv:552-554), with a computed-day fallback.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1030` · `scripts/systems/hr_overtime_system.gd:465-472` · `localization/strings.csv:552-554`


**`num.overtime_bug_mult` — OVERTIME_BUG_MULT (1.25)**  
**UNGOVERNED · PHANTOM CITATION** · MEDIUM — the quality side of the overtime bargain, and it applies to one department only.  
Same 'design doc §7b' citation. ch.03 §6 governs the bug rate as a skill reading — 'bugs accrue at a rate inverse to Geliştirme' — with no time-pressure term, and ch.07 §2 gives the lever to Yazılım. bug_multiplier returns 1.25 only while DEPT_PRODUCT_DEV is on overtime and 1.0 otherwise (:259-265).  
*Costs the player:* 25% more bugs accrued during a product-dev block, which surface as live bugs at ship — ch.03 §7's '{n} hata canlıya taşınır' tooltip is where the player eventually reads them.  
*If removed:* product_system.gd:977 loses its overtime term and rushing a build costs only cash and morale, never quality — which removes the one consequence that makes overtime a trade rather than a pure speed purchase, and the only reason not to run it permanently in Ürün Geliştirme.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1037` · `scripts/systems/hr_overtime_system.gd:259-265` · `scripts/systems/product_system.gd:977`


**`num.overtime_pay` — OVERTIME_PAY_PCT (0.40) and the /30 divisor**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — a recurring cash cost outside ch.08's burn definition, on a hidden second calendar.  
Cited to 'design doc §7b'. ch.08 §1's burn definition — 'burn = maaşlar + araçlar + servis maliyeti+ marketing plus one-off costs (Atlas retainer, eğitim, lisans, kesinti telafisi)' — lists neither overtime pay nor any recurring HR cost beyond maaşlar. The accrual is pulled into the salary line by Finance two slots later (finance_system.gd:143), so it reaches the player as payroll he did not set.  
*Costs the player:* round(monthly_salary / 30.0 × 0.40) per participant per night — $107/night for an $8,000/mo employee, accrued in _charge_day (hr_overtime_system.gd:134-138).  
*If removed:* overtime_daily_pay returns 0; Finance's pull adds nothing and overtime becomes free in cash, leaving morale as its only cost. Separately, the inline 30.0 at :1066 shadows GameState.DAYS_PER_MONTH := 30, declared at game_state.gd:7 as 'the single home for the monthly -> daily conversion' and read properly by finance_system.gd:218 — a calibration pass moving the month length would move payroll and MRR and silently leave overtime pay behind.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1038-1040` · `scripts/systems/hr_constants.gd:1064-1066` · `scripts/autoload/game_state.gd:7` · `scripts/systems/finance_system.gd:213-218`


**`num.overtime_speed` — OVERTIME_SPEED_BONUS_EARLY (0.30) / LATE (0.15) / DIMINISH_DAY (8)**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — the only lever that buys build/sales/CS throughput with money and morale instead of headcount.  
Same 'design doc §7b' citation. ch.03 §6 governs build speed as 'speed from Geliştirme + Hız' — a skill reading, not a time-purchase.  
*Costs the player:* Nothing directly — this is the benefit side. It is what the cash and morale above buy: +30% for the first seven nights, +15% from the eighth.  
*If removed:* speed_multiplier returns 1.0 always; ProductSystem's hourly build tick (product_system.gd:718) and both rep desks (sales_rep_system.gd:95, customer_rep_system.gd:71) read no bonus, so overtime becomes pure cost and no rational player starts a block — which silently removes the whole subsystem the way deleting OVERTIME_BLOCKS would.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1034-1036` · `scripts/systems/hr_constants.gd:1049-1053` · `scripts/systems/hr_overtime_system.gd:235-256`


**`num.search_commission_pct` — SEARCH_COMMISSION_PCT (0.15)**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — the dominant cash cost of the hire decision, landing exactly in the Bootstrap squeeze, authorised by nothing.  
hr_constants.gd:704 sources the two-fee structure to 'Çift ücret (design doc §2, KANON)' — the non-existent HR design doc. ch.07 §6 names only the retainer ('Atlas ajansına retainer ödenir → 2–4 gün sonra 3 aday'), ch.02 §9 says 'Search mechanics (retainer, candidate count) unchanged', and ch.08 §1's one-off list names 'Atlas retainer' and no placement fee.  
*Costs the player:* round(accepted first-month salary × 0.15), charged once on the hire (hr_search_system.gd:223) — ~$1,425 for a mid developer, i.e. more than twice the $600 retainer and the largest single hiring cost in the game.  
*If removed:* commission_for returns 0; hiring gets roughly 70% cheaper at the moment of hire and preview_search/preview_hire lose the second term of their total (:283-284, :337). ch.01 §5's Bootstrap pressure ('cash ... first salaries before revenue') loses its sharpest spike, since the commission lands in the same week as the first salary.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:704` · `scripts/systems/hr_constants.gd:711` · `scripts/systems/hr_constants.gd:753-754` · `scripts/systems/hr_search_system.gd:223`


**`num.severance_on_resign` — SEVERANCE_ON_RESIGN (0)**  
**UNGOVERNED · PHANTOM CITATION** · LOW.  
Cited '(design doc §6)'. No chapter mentions severance at all, on resignation or otherwise. The only occurrence outside the declaration is a COMMENT in confirm_departure explaining why nothing is charged (hr_morale_system.gd:396). No code path reads the symbol — the behaviour is the absence of a call, not a multiplication by zero.  
*Costs the player:* Nothing.  
*If removed:* Nothing. Worse than debris: it is a live lie, because setting it to a non-zero value would pay nobody.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:957` · `scripts/systems/hr_morale_system.gd:396-397`


**`num.area_train_cap` — AREA_TRAIN_CAP (8)**  
**UNGOVERNED** · HIGH — the single line keeping hiring economically necessary, and the hidden cause of four dead endpoint constants.  
No chapter caps paid training below the ruler top. ch.07 §8 gives the player a graded fee and free choice of area with no ceiling; ch.02 §7's 'Decay above a soft cap: decide after first playtest' is an open decision about growth decay, not a training limit. The two-channel design stated at hr_constants.gd:816-818 — money stops at four stars, the fifth comes only from doing the work or hiring a senior — is a code ruling.  
*Costs the player:* It is what money cannot buy: past 8 the only routes to five stars are ~100 worked days per point (EXPERIENCE_MAX at EXPERIENCE_PER_DAY 1) or paying Atlas for a senior file.  
*If removed:* can_train (character_registry.gd:145,150) and tick_training's mini(cur+1, cap) (:191) lose their ceiling and paid training runs to AREA_MAX 10 — a $5,000/mo junior becomes a five-star specialist for cash and the hire-vs-train trade collapses. It is ALSO the de facto Liderlik ceiling, because leadership is not in AREAS so the free channel refuses it (character_registry.gd:103): removing it would simultaneously un-orphan CLIMATE_DROP_FLOOR, CLIMATE_GAIN_CAP, COORD_MAX and …  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:815-818` · `scripts/autoload/character_registry.gd:135-150` · `scripts/autoload/character_registry.gd:191`


**`num.assignment_matrix_sizes` — HRAssignments / HRAtlasModal / TrainingModal / HRPopover / PersonalTab layout numbers**  
**UNGOVERNED** · LOW.  
ch.12 §7 grandfathers layout ('UI scale ladder and resolution handling stay as shipped'); no chapter carries a pixel. W_WHO 430 / W_STATE 210 / CELL 22; PANEL_SEARCH 1440 / PANEL_FILES 1560; PANEL_MIN 760 and five column widths 190/120/150/120/120; LIFT 6.0 / EDGE_MARGIN 12.0 / MIN_WIDTH 268; RIGHT_COL_WIDTH 620 / MIN 430 / PORTRAIT 150×186; SHELL_W 420.  
*Costs the player:* Nothing.  
*If removed:* The four HR screens lose their fixed grids; ch.07 §3's closed-row rule and §4's one-row-per-person matrix would still hold but nothing would align. Owned by the scripts per the UI law, no balance meaning.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr/hr_assignments.gd:23-25` · `scripts/tabs/hr/hr_atlas_modal.gd:27-28` · `scripts/modals/training_modal.gd:22` · `scripts/tabs/personal_tab.gd:21-23`


**`num.badge_severity` — BADGE_SEVERITY (FLIGHT_RISK 3 / BURNING_OUT 2 / OVERLOADED 1)**  
**UNGOVERNED** · LOW — ordering only, but on a full roster it decides whether the player sees the resignation coming.  
ch.12 §4 lists the badges and how they surface ('A badge is a number on the tab in the rail; clicking goes to the exact row') but never ranks them. badge_severity() returns 0 for anything else, explicitly including BADGE_NEW (:857-860).  
*Costs the player:* Nothing.  
*If removed:* HRUiShared.worst_badge_severity (hr_ui_shared.gd:258) loses its comparator and the Ekip ledger can no longer float attention rows to the top — a person inside the 10-14 day resignation window would sit wherever roster order puts them, on a page whose whole job is to surface exactly that.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:781-787` · `scripts/systems/hr_constants.gd:857-860` · `scripts/tabs/hr/hr_ui_shared.gd:258`


**`num.block_first_day` — BLOCK_FIRST_DAY (1) + block record keys**  
**UNGOVERNED** · LOW.  
Overtime plumbing. Day_index is 1-based; a fresh record starts at 0 and the first tick advances it. Used as the loop floor in preview_block (:339), the opening-rate index (:346) and the defensive floor in _block_length (:459-462). KEY_STARTED_DAY (:44) is self-marked RESERVED, written by start() (:172), read by nothing.  
*Costs the player:* Nothing.  
*If removed:* _block_length loses its floor, so a corrupt block_days of 0 could make a block immortal — the stated reason for the constant. KEY_STARTED_DAY specifically: nothing breaks.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_overtime_system.gd:42-51` · `scripts/systems/hr_overtime_system.gd:459-462`


**`num.calm_stretch` — CALM_STRETCH_DAYS (21) / MORALE (5) / MAX_MORALE (70)**  
**UNGOVERNED** · MEDIUM — one of only three positive morale channels in a system that never recovers on its own.  
ch.07 §7's success-moment clause names 'sürüm çıktı, hesap kaybedildi, kesinti' — a calm stretch is not an event, it is the ABSENCE of one. No chapter rewards not acting. Delivered as a single-option beat through HREventFactory.build_calm_stretch (:75), which satisfies ch.11 §4's beat carve-out but is still a free upside against ch.01 §9's 'Every economic outcome comes from a played decision moment.'  
*Costs the player:* Nothing — a free +5 to every employee for three weeks of not running overtime, gated only on team average morale being under 70.  
*If removed:* hr_morale_system.gd:197-199's third positive branch goes. Morale has no self-recovery by design (hr_constants.gd:757-759, 'Kendiliğinden toparlanma yoktur'), so a player who has not shipped and has not signed a $1,500+ account would have no channel back up from an overtime block except a paid raise or the annual leave return.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1074-1076` · `scripts/systems/hr_morale_system.gd:197-199` · `scripts/systems/hr_event_factory.gd:72-76`


**`num.coord_natural_leader` — COORD_NATURAL_LEADER_BONUS (0.05) / COORD_MAX_WITH_TRAIT (1.25)**  
**UNGOVERNED** · LOW.  
No chapter names a natural-leader trait or a raised coordination ceiling; ch.07 §2 in fact closes the door ('Mentorluk ayrı bir trait ya da sistem değildir'). Both are gated on the has_natural_leader parameter of coordination_for_founder (:923) and coordination_for_lead (:935), and the ONLY production caller passes the literal false on both branches (product_system.gd:504, :506).  
*Costs the player:* Nothing — the branches never execute in a shipped run.  
*If removed:* Nothing in production. Only endgame_smoke.gd:5215 passes true, so one smoke case would need rewriting. Debris left by the eight-trait set retiring the axis.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:897-898` · `scripts/systems/product_system.gd:498-506` · `scripts/systems/hr_constants.gd:930-932`


**`num.copy_pool_counts` — RESIGN_VOICE_COUNT (4) / VALVE_VOICE_COUNT (3) / FILE_NOTES_COUNT (12)**  
**UNGOVERNED** · LOW.  
ch.11 §7 governs voice, never pool sizes. The lines moved to strings.csv, leaving the size behind as a modulus; the CSV holds 4 / 3 / 12 rows today, so a second home for a number the CSV already implies.  
*Costs the player:* Nothing.  
*If removed:* resign_voice_line / valve_voice_line / file_notes_line lose their modulus and index past the CSV rows, so every resignation card and every candidate file note would print a raw translation key.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1092` · `scripts/systems/hr_constants.gd:1101` · `scripts/systems/hr_constants.gd:1141` · `scripts/systems/hr_constants.gd:1095-1115`


**`num.count_active_developers` — CharacterRegistry.count_active_developers**  
**UNGOVERNED** · LOW.  
A byte-identical reimplementation of count_active_by_role(ROLE_DEVELOPER) (:290-298). Its comment claims 'Kapasite havuzu (ProductSystem.capacity_total)' reads it; capacity_total actually reads count_active_in_department (product_system.gd:243). Grep confirms the only callers are endgame_smoke.gd:937, 4559, 4574, 4637, 5024.  
*Costs the player:* Nothing.  
*If removed:* Five smoke assertions fail; no production path is affected. A duplicate counter kept alive by tests alone, carrying a stale claim about its own reader.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/character_registry.gd:322-329` · `scripts/autoload/character_registry.gd:290-298` · `scripts/systems/product_system.gd:243`


**`num.debug_event_morale` — Morale deltas hardcoded in event JSON**  
**UNGOVERNED** · LOW today, because the only carriers are debug events.  
ch.11 §3's vocabulary law is satisfied — 'An event may only use effects the engine knows', and morale / morale_all_employees both exist — but no chapter or constants file owns the MAGNITUDES. ev_debug_001 carries +5 / -3 / +3 on a named character; ev_debug_003 carries -3 on all employees. Both route through EventManager into HRMoraleSystem.apply_delta (:583-589), so trait and climate scaling still applies to an authored number.  
*Costs the player:* ±3 to ±5 morale per firing, and only in debug events today.  
*If removed:* The two debug events lose their morale modifiers; nothing in a shipped run depends on them. The finding is structural rather than about these two files: the authored-event layer is the one HR-touching surface with no constants home at all, so every future authored morale beat will be a hand-typed number outside hr_constants.gd's stated single-home rule.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `data/events/reactive/ev_debug_001_engineer_workload.json:20` · `data/events/reactive/ev_debug_003_cash_warning.json:20` · `scripts/autoload/event_manager.gd:587-589`


**`num.debug_seed_numbers` — Debug-seed HR numbers outside HRConstants**  
**UNGOVERNED** · LOW for play; MEDIUM as a calibration hazard, because a balance anchor is stored in a debug fixture.  
_seed_debug_characters carries hand-typed salaries 6000/5000, morale 60/40, seed_skills(role, 4, 3) and fixed traits (character_registry.gd:630-654); main.gd's shot harness carries a five-person roster with salaries 9800/7400/11200/6900/8300 and morale 72/38/61/22/55 (:1667-1681), plus seeds at :562-567, :1758-1762, :2049-2051 and an experience seed of EXPERIENCE_MAX-1 (:1501). Mentor morale 50, salary 0 (:403-405).  
*Costs the player:* Nothing in a normal run — all of it sits behind debug flags and the shot harness.  
*If removed:* The shot harness and the two debug characters lose their files, so endgame_smoke and every --hr-shot capture asserting against them fails. Note one is NOT debris: the eng key-area value of 4 is documented as the effort ANCHOR (0.25 × 4 = 1.0 effort/day) that EMPLOYEE_SPEED_COEF was derived from (:628-629) — a live balance reference living inside a debug seed.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/character_registry.gd:626-654` · `scripts/main/main.gd:1663-1695` · `scripts/main/main.gd:1500-1501`


**`num.default_employee_skills` — default_employee_skills()**  
**UNGOVERNED** · MEDIUM — a flat 5 across all six areas beats every junior and most mid generated files outside their key area (mid rest is 3-4), so an event hire is a better all-rounder than anyone the player pays …  
ch.07 §6 governs hiring through Atlas only and calls that flow sealed ('Mühürlü akış, dokunulmaz'); an event-spawned hire is outside every chapter. Six areas at 5, Liderlik at 2. Sole production reader is EventManager's add_character modifier default (:628-629).  
*Costs the player:* Whatever the event's own JSON names as salary — the skill file itself is free, and it is a flat 2½ stars in ALL six areas.  
*If removed:* add_character would hand CharacterRegistry a character with no role_stats; validate_employee_skills (hr_constants.gd:92) and _validate_shape (character_registry.gd:480-499) would both fail and push_error, leaving a malformed employee on the roster.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:81-85` · `scripts/autoload/event_manager.gd:628-629`


**`num.dense_below` — HRLedger.DENSE_BELOW (1600) vs TopBar.COMPACT_BELOW (1600)**  
**UNGOVERNED** · LOW — layout only, but three statements of one number in three files.  
The nearest line is ch.12 §7, which grandfathers rather than specifies: 'UI scale ladder and resolution handling stay as shipped.' The HR file's own comment admits the duplicate — 'mantıksal genişlik eşiği (top_bar ile aynı sayı)' — and DisplaySettings restates it a third time as prose, 'eşik 1600' (:97).  
*Costs the player:* Nothing.  
*If removed:* HRLedger falls back to wide widths at every resolution; the six wide columns plus the trait column total 1330px before padding, so on a 1366-wide logical viewport the Ekip ledger overflows.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr/hr_ledger.gd:34` · `scripts/ui/components/top_bar.gd:106` · `scripts/systems/display_settings.gd:97`


**`num.founder_onboarding_cap` — FounderConstants.ONBOARDING_CAP (3)**  
**UNGOVERNED** · HIGH — the only shape constraint on the opening skill card, and in Bootstrap the founder is the entire team (ch.01 §5).  
ch.12 §5 fixes only the flow ('founder creation (name, origin, skills — archetype pick or point distribution, chapter 02 §2)') and ch.02 §11 only that onboarding 'must set the 7+2 numbers'. No chapter caps a per-skill allocation. Enforced in validate_alloc (:181), the onboarding plus-button gate (origin_traits_step.gd:362, :378), and as SegmentBar's fillable count (segment_bar.gd:17).  
*Costs the player:* It is the shape of the founder the player starts the run with: Liderlik cannot exceed 3 at creation, so coordination_for_founder opens at 1.00-1.06 and climate_drop_mult at 0.85, and no area can open above 3 (1½ stars).  
*If removed:* A player could put all six points in one column: a founder with Yazılım 6 on day 1, at FOUNDER_SPEED_COEF 1.0 producing ~6.0 effort/day against the ~3.0 the tech-3 solo anchor was derived from (product_system.gd:41-47) — doubling the Bootstrap build rate the whole product economy is calibrated on.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/founder_constants.gd:53` · `scripts/onboarding/steps/origin_traits_step.gd:362-378` · `scripts/ui/components/segment_bar.gd:17`


**`num.generator_mixer` — MIX_MODULUS / MULTIPLIER / INCREMENT / SALT_STRIDE**  
**UNGOVERNED** · LOW.  
Determinism plumbing, declared explicitly as arithmetic and not tunables (:12-14, :43-48). The file is barred from randi/randf.  
*Costs the player:* Nothing.  
*If removed:* Candidate generation would need RNG, so a save/load could reshuffle files already on the desk (the identity of people the player is choosing between changes across a reload) and HR would displace the event deck's random stream. Load-bearing for save integrity, not for balance.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_candidate_generator.gd:43-52` · `scripts/systems/hr_candidate_generator.gd:352-357`


**`num.generator_salts` — Nine per-field salts + SALT_CANDIDATE_STRIDE**  
**UNGOVERNED** · LOW.  
Determinism plumbing. SALT_POSITIVE_COUNT (53) is declared and never used — the count draw moved to SALT_NEGATIVE_COUNT (:314) when the trait rule collapsed to TRAIT_COUNT 1.  
*Costs the player:* Nothing.  
*If removed:* With one salt the three files' name, surname, note and trait would move in lockstep and the pool would read as one repeating person. SALT_POSITIVE_COUNT specifically: nothing breaks, it has no reader.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_candidate_generator.gd:54-64` · `scripts/systems/hr_candidate_generator.gd:314`


**`num.group_overtime_host` — GROUP_OVERTIME_HOST**  
**UNGOVERNED** · MEDIUM — it is the door to the module's largest lever, and one of the four groups deliberately has no door.  
Part of the ungoverned overtime system; ch.12 §1 gives Ekip a tab and no overtime surface. product_design -> product_dev, development -> '', sales -> sales, customer_success -> customer (:327-332). Ürün Geliştirme spans two roster groups but has one block, so the button sits on the first group only. Read by overtime_dept_for_group (:397-399).  
*Costs the player:* Nothing directly — it decides only where the start button lives. The consequence is that a player scanning the 'development' group header finds no overtime control at all.  
*If removed:* overtime_dept_for_group returns '' for every group and no block can be started from any roster header — the whole overtime subsystem loses its entry point on the Ekip page.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:324-332` · `scripts/systems/hr_constants.gd:397-399`


**`num.id_lists_retyped` — AREAS / EMPLOYEE_SKILL_KEYS / ASSIGNABLE / EMPLOYEE_ROLES / DEPARTMENTS / ROSTER_GROUPS / BANDS**  
**UNGOVERNED** · LOW.  
Source hygiene; no chapter touches file layout. Seven arrays re-type as string literals the consts declared immediately above them, all inside hr_constants.gd.  
*Costs the player:* Nothing.  
*If removed:* The ARRAYS are the load-bearing half, not the consts: validate_employee_skills iterates EMPLOYEE_SKILL_KEYS, the Görevler matrix iterates ASSIGNABLE, and HRCandidateGenerator derives its seed index from find() on EMPLOYEE_ROLES (:167), so deleting them breaks validation, the assignment screen and every candidate pool. The consts are the redundant half; a rename of one would silently leave the array behind.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:31-44` · `scripts/systems/hr_constants.gd:248-258` · `scripts/systems/hr_constants.gd:283-287` · `scripts/systems/hr_constants.gd:634-637`


**`num.lead_member_weights` — ProductSystem.LEAD_EXPERTISE_WEIGHT (1.5) / MEMBER_EXPERTISE_WEIGHT (1.0)**  
**UNGOVERNED** · MEDIUM — invisible to the player, load-bearing for the calibration of two other constants.  
Boundary row. ch.07 §2 gives Liderlik the team-efficiency modifier and the code already implements that separately as coordination_for_lead; this is a SECOND, undeclared lead advantage inside the quality average. No chapter weights a lead's own skill higher in a team mean.  
*Costs the player:* Nothing directly; it means the lead's area score counts 1.5× in the average that seeds bugs at commit (product_system.gd:973) and drives live wear (:1039), so the same engineer lowers bugs more as lead than as a member.  
*If removed:* _team_area_avg becomes a flat mean and the solo-founder equivalence proved at :559-567 ((1.5×tech)/1.5 = tech) breaks — which matters because BUG_TECH_REDUCER and WEAR_TECH_REDUCER were deliberately NOT rescaled during the area migration on the strength of that identity. Every bug and wear number in the game would move silently.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:559-598` · `scripts/systems/product_system.gd:973` · `scripts/systems/hr_constants.gd:228-242`


**`num.leave_days` — LEAVE_DAYS (7) — automatic annual leave**  
**UNGOVERNED** · HIGH — the largest uncontrollable capacity shock in the module, hitting ch.03 §8's support-vs-build tension and ch.06 §1.3's coverage threshold at a month the player never chose.  
Annual leave appears in NO chapter. ch.07 has no leave section and §7's morale input list does not include it; ch.08 §1's burn definition does not carve out paid absence; ch.06 §1.3's coverage counts heads without a leave state. The whole system is a code invention: the leave month is assigned at hire, the employee leaves automatically, and the player is never asked (hr_constants.gd:968-970).  
*Costs the player:* Seven paid days per employee per year during which salary keeps flowing — get_total_monthly_salaries is deliberately not status-filtered (character_registry.gd:414-416) — while capacity, build speed, CS coverage and overtime participation all stop. On a five-person team that is 35 person-days a year of paid absence the player cannot decline or schedule.  
*If removed:* send_on_leave gets leave_until_day = day + 0, so nobody is ever actually absent and the whole automatic-leave system becomes a no-op; MORALE_LEAVE_RETURN's +10 would fire the same day it starts, turning it into a free annual morale gift. Downstream, ProductSystem.capacity_total, HRSystem.assigned_to and the CS desk all read STATUS_ACTIVE and would stop seeing the dip.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:970` · `scripts/systems/hr_morale_system.gd:358-369` · `scripts/autoload/character_registry.gd:414-416`


**`num.leave_month_distribution` — LEAVE_MONTH_MIN_GAP (2) / LEAVE_MONTH_STRIDE (7)**  
**UNGOVERNED** · MEDIUM — it is what keeps an ungoverned capacity shock from arriving all at once.  
Same ungoverned system as LEAVE_DAYS. leave_month_for walks the allowed span of 12 - 2 = 10 months, not 12, so a January hire can never draw January (:979-989); the stride must stay coprime with that span (7 with 10 gives ten distinct offsets, 5 would give two). Called from CharacterRegistry.add with hire_ordinal = run_hires (:455-457).  
*Costs the player:* Nothing directly; it decides WHICH month each hire vanishes for a week, and guarantees it is never their first two months.  
*If removed:* leave_month_for collapses and consecutive hires land on the same month — or, in the naive form the comment records, on the hire month itself, sending a new hire on annual leave the day after starting. The team would go on leave in one week rather than as a drip, turning a distributed shock into a single company-wide outage.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:970-989` · `scripts/autoload/character_registry.gd:455-457`


**`num.ledger_widths` — HRLedger column widths (wide / dense) + morale bar sizes**  
**UNGOVERNED** · LOW.  
ch.07 §3 and §4 fix WHAT the row shows, never how wide; ch.12 §7 grandfathers resolution handling. Wide 370/260/140/160/150/160, dense 300/232/104/140/118/124, W_TRAIT 90, W_MENU retired 2026-08-22. Paired with MORALE_BAR_WIDTH 150 / DENSE 92 / HEIGHT 6 and CHIP_RADIUS 3 / PAD_X 7 / PAD_Y 3.  
*Costs the player:* Nothing.  
*If removed:* Rows and header lose their shared grid and the two-mode density switch. The comment at hr_ledger.gd:35-41 records a measured instance of exactly this class of bug: until 2026-08-22 the rows read these constants and the header did not.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/hr/hr_ledger.gd:19-46` · `scripts/tabs/hr/hr_ui_shared.gd:22-27`


**`num.migrate_area_floor` — SaveManager.MIGRATE_AREA_FLOOR (2) and the rapport/2 conversion**  
**UNGOVERNED** · LOW — save compatibility only, no effect on a new run.  
No chapter addresses save migration. Every non-key, non-secondary area gets 2 when a three-axis employee is rebuilt (:713); old UYUM becomes Liderlik at clampi(rapport / 2, AREA_MIN, AREA_MAX) (:716-717), an integer halving with no named constant; the founder's old tech is copied unchanged onto all four technical areas (:743-749). The legacy tables are deliberately local and frozen (:43-46).  
*Costs the player:* Nothing in a fresh run.  
*If removed:* Pre-area saves load with employees failing validate_employee_skills and _validate_shape, producing push_errors and a broken roster. The frozen tables are also what stop a live constant change from retro-corrupting an old save.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/save_manager.gd:42-46` · `scripts/autoload/save_manager.gd:704-728` · `scripts/autoload/save_manager.gd:877-888`


**`num.morale_bounds` — MORALE_MIN (0) / MORALE_MAX (100)**  
**UNGOVERNED** · LOW — the write path does not read them.  
No chapter states a morale scale; ch.02 §6's founder energy bar with '[WORKING thresholds]' is a different, unbuilt system. The declared constants are read only by scaled_delta (:254) and the morale bar (hr_ui_shared.gd:222-223), while the actual WRITE clamp uses bare literals — character_registry.gd:598 writes clampi(value, 0, 100) and its comment calls the range a 'Placeholder clamp range' with no reference to the constants the HR file claims it mirrors.  
*Costs the player:* Nothing — it is the ruler everything else is denominated in.  
*If removed:* Morale stays bounded, because the enforcing clamp is the literal pair elsewhere; what breaks is the preview promise (the constants exist so a preview cannot over-promise past the ceiling) and the morale bar's denominator. The constants are the redundant half of this duplicate.  
*Verification:* Verified with unusual precision. MORALE_MIN 0 / MORALE_MAX 100 at hr_constants.gd:763-764, and a repo-wide grep finds exactly two readers: hr_morale_system.gd:253 (inside scaled_delta's return clamp) and hr_ui_shared.gd:222-223 (the morale bar's min/max). The enforcing write is a bare literal — character_registry.gd:598 `var clamped: int = clampi(value, 0, 100)` — under a comment at :591-593 calling it a 'Placeholder clamp range' that 'mirrors brand' and citing PROJECT_SPEC §9, with no reference to the HR constants that claim at :762 to mirror IT. Two files each believe the other is the source. ch.02 §6's founder energy bar is indeed a different, unbuilt system.  
Evidence: `scripts/systems/hr_constants.gd:761-764` · `scripts/autoload/character_registry.gd:590-602` · `scripts/systems/hr_morale_system.gd:254`


**`num.morale_fire_team` — MORALE_FIRE_TEAM (5)**  
**UNGOVERNED** · HIGH — the entire non-cash cost of ch.08 §6's 'let someone go' recovery move, and the only thing that makes a resignation hurt beyond the lost head.  
ch.07 §7's morale input list is explicit and closed — 'fazla mesai · aşırı yüklenme · başarı ve başarısızlık anları (sürüm çıktı, hesap kaybedildi, kesinti) · lider Liderliği · event'ler' — and a colleague leaving is not on it. ch.07 §9 treats departure as an event moment and adds only 'Bilgi kaybı / teknik borç cezası yok'.  
*Costs the player:* -5 morale on every other employee including those on leave, on every departure — firing (hr_actions.gd:190-195) AND resignation (hr_morale_system.gd:410-416, added 2026-08-21). With GERÇEK LİDER the cost is 5 + round(abs(-5)) = 10. On a five-person team one firing costs 20 morale points across the room.  
*If removed:* HRActions.fire's room-wide apply and its two preview lines (:163, :174-175) go, and _charge_departure becomes a no-op; departures become free to the survivors, removing the only structural brake on firing as a cash lever and on letting a flight-risk person go rather than paying a raise.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:770` · `scripts/systems/hr_actions.gd:190-195` · `scripts/systems/hr_morale_system.gd:399-416`


**`num.morale_hire_start` — MORALE_HIRE_START (75) vs the event hire's 50**  
**UNGOVERNED** · MEDIUM — it silently doubles or halves how much overtime and departure damage a new person can absorb, depending on which door they came through.  
No chapter states a starting morale, or a morale scale at all. Written by HRSearchSystem.hire (:206) and promised by preview_hire (:325); the other hire path ignores it — EventManager's add_character modifier defaults morale to a bare literal 50 (event_manager.gd:617), matching Character.gd:49 and the mentor seed (character_registry.gd:405). One semantic, two values, two files.  
*Costs the player:* Nothing at hire; it sets the headroom the person arrives with. 75 leaves 50 points above MORALE_FLIGHT_RISK 25; the event hire arrives with 25 — half the buffer, for the same job.  
*If removed:* Character.gd:49's default 50 takes over everywhere and every Atlas hire starts halfway to the flight-risk badge; a single 14-night overtime block (71 raw) would drive a fresh hire to zero, so the module's main lever could not be used on new staff at all.  
*Verification:* CORRECTION that lowers play_impact from MEDIUM to LOW: there is no second door. The event-hire path at event_manager.gd:596-633 never executes — a whole-repo grep for `add_character` finds no event JSON using the modifier, and only data/events/reactive/ is loaded (event_manager.gd:32, :872-893). So no person in a shipped run can arrive at 50; every hire comes through hr_search_system.gd:206 at MORALE_HIRE_START 75. The row's hygiene finding stands exactly as written (one semantic, two values, two files: hr_constants.gd:767, event_manager.gd:617, character.gd:49, character_registry.gd:405, game_state.gd:952) and its breaks_if_removed counterfactual is sound — 71 raw from a 14-night block …  
Evidence: `scripts/systems/hr_constants.gd:767` · `scripts/systems/hr_search_system.gd:206` · `scripts/autoload/event_manager.gd:617` · `scripts/data_models/character.gd:49`


**`num.morale_leave_return` — MORALE_LEAVE_RETURN (10)**  
**UNGOVERNED** · MEDIUM — a recurring free morale gift in a system the code declares has no self-recovery.  
Part of the ungoverned annual-leave system; no chapter contains leave or a return bonus. Applied by tick_leave_returns through apply_delta with REASON_LEAVE_RETURN (:95-98), so the trait and climate scaling folds in once.  
*Costs the player:* Nothing — a free +10 per employee per year, on top of seven days of paid absence the player did not authorise.  
*If removed:* tick_leave_returns' positive arm goes; annual leave becomes pure capacity loss with no compensation, which would make it a straight negative event rather than a wash. It is the second of only four upward morale channels (leave return, calm stretch, big signing, ship glow) plus the paid raise.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:768` · `scripts/systems/hr_morale_system.gd:95-98`


**`num.name_pools` — FIRST_NAMES (16) / LAST_NAMES (14)**  
**UNGOVERNED** · LOW mechanically; it is the sole source of the avatar identity ch.14 §7 requires.  
ch.14 §7 legislates faces, not names. Marked WORKING content and LOC-DATA (proper nouns, not localised). Drawn by _take_unused with a deterministic forward walk so no two files in a batch share a name; at CANDIDATE_COUNT 3 neither pool can exhaust.  
*Costs the player:* Nothing.  
*If removed:* _take_unused has nothing to walk and every candidate is nameless — which also removes the source of the initials grammar ch.14 §7 mandates: 'initials for employees (e.g. "MA" for Mert Aksoy)'.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1126-1135` · `scripts/systems/hr_candidate_generator.gd:360-372`


**`num.new_hire_badge_days` — NEW_HIRE_BADGE_DAYS (3)**  
**UNGOVERNED** · LOW.  
ch.12 §4's badge list contains no YENİ chip. is_new_hire uses a two-sided test (today <= hire_day + 3) because HRSearchSystem stamps hire_day to tomorrow (hr_search_system.gd:221). BADGE_NEW is deliberately kept out of badges_for so it cannot inflate attention_count (:789-791).  
*Costs the player:* Nothing — informational only.  
*If removed:* hr_ledger.gd:336-337 stops drawing the chip and nothing else changes; attention_count and the rail badge are untouched by design. Pure decoration.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:789-793` · `scripts/systems/hr_constants.gd:863-867` · `scripts/tabs/hr/hr_ledger.gd:336-337`


**`num.positive_event_cooldown` — POSITIVE_EVENT_COOLDOWN_DAYS (14)**  
**UNGOVERNED** · MEDIUM — it sets the ceiling on the only recovery channel a morale system with no decay offers.  
No chapter rate-limits morale beats. ch.11 §5's 'Ambient texture events: at most one per day, and they never carry economic weight' is a different cap and does not apply, because these beats carry morale. _positive_off_cooldown treats 0 as 'never fired' (:509-514) and _fire_positive stamps at ENQUEUE, not at resolve (:517-522), so an unread beat still blocks the next.  
*Costs the player:* Nothing directly; it caps morale recovery at roughly +6 per fortnight against an overtime ladder that can take 71 in fourteen nights.  
*If removed:* _fire_positive would enqueue a beat every day its condition holds, and because the three factory ids are shared and a synthetic event ignores one_shot (hr_event_factory.gd:10-14), the deck would fill with duplicate cards — this latch is the only thing preventing that.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1080` · `scripts/systems/hr_morale_system.gd:509-522`


**`num.rep_stack_decay` — B2BConstants.REP_STACK_DECAY (0.6)**  
**UNGOVERNED** · HIGH — it is what stops hiring from being a monotonic win, and it is stated in no chapter.  
Boundary row. ch.04 §2 defines capacity as a headcount — 'Sales capacity = number of people assigned to sales (sales hires + founder when assigned to selling)' — and nothing anywhere prices the second and third head lower. Applied in SalesRepSystem._diminished_sum (:64-81) for both desks, alongside output_mult_for_area and the output_mult/speed_mult traits.  
*Costs the player:* Rank-0 counts full, rank-1 0.6, rank-2 0.36 — three sales reps are worth 1.96 effective heads, not 3. The player pays three salaries for under two people's throughput.  
*If removed:* _diminished_sum becomes a plain sum and lead generation, warming and CS throughput scale linearly with hires — which is exactly the state ch.01 §5's law forbids: 'in no phase may a competent policy reach "cash rises, no decisions left"'. It is the main brake on buying growth with headcount.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/b2b_constants.gd:287-291` · `scripts/systems/sales_rep_system.gd:64-81`


**`num.resign_valve_penalty` — RESIGN_VALVE_PENALTY (0.15)**  
**UNGOVERNED** · HIGH — the only consequence attached to one of the module's two decision modals, and it is permanent and invisible.  
No chapter contains the overtime valve. ch.07 §7 names 'fazla mesai' as a morale input and §9 makes departure an event, but a separate additive, permanent, per-person resignation-probability memory is nowhere in the corpus. hr_overtime_system.gd:380-398 states the mechanism itself: 'Nothing else happens: they stay on the block.'  
*Costs the player:* +0.15 daily resignation chance for the rest of the run, for anyone the player answered 'Devam et' to. Stacked on RESIGN_CHANCE_PER_DAY 0.25 that is 0.40/day inside the 10-14 day window — ~87% cumulative before the day-14 certainty instead of 68%. The flag rides GameState.flags and dies only with initialize_run.  
*If removed:* resign_chance loses its second term (:962-963) and the valve modal's 'Devam et' becomes an option with NO cost at all — the morale is already charged by _charge_day, so nothing else attaches to it. That puts the card in direct breach of ch.11 §4's cost law, 'Every option costs a real resource and has a visible reader ... No free upside.'  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:956` · `scripts/systems/hr_constants.gd:960-964` · `scripts/systems/hr_overtime_system.gd:380-407`


**`num.salary_peak_premium` — SALARY_PEAK_PREMIUM (0.10)**  
**UNGOVERNED** · LOW — the money is small; the ordering property it guarantees is not.  
No chapter prices a sharp profile above a flat one. Applied as 0.10 × clamp((peak + total) / (AREA_MAX × 4), 0, 1) at hr_candidate_generator.gd:291; the peak term is the 'sharp specialist costs more' rule and the total term is what keeps a strictly better file from also being cheaper.  
*Costs the player:* At most 10% over the window floor for the sharpest of three files — tens of dollars a month at junior, low hundreds at senior.  
*If removed:* All three quotes collapse to the same rounded number and a strictly dominant candidate could also be the cheapest, which is the non-domination property the generator is built around.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:716` · `scripts/systems/hr_candidate_generator.gd:261-291`


**`num.salary_round_to` — SALARY_ROUND_TO (50)**  
**UNGOVERNED** · LOW.  
Presentation granularity; no chapter mentions rounding. Used by _salary_for (:233), _salary_window's inward ceil/floor (:256-257) and _round_to/_ceil_to/_floor_to (:395-410). The comment states why it is not 100: at $100 the tightest junior window cannot hold three distinct quotes.  
*Costs the player:* At most $25/month of rounding noise per hire.  
*If removed:* Quotes land on raw ints — cosmetically ugly and mechanically harmless, EXCEPT that _salary_window's inward rounding is what keeps both window bounds legal inside the band.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_candidate_generator.gd:80-83` · `scripts/systems/hr_candidate_generator.gd:233`


**`num.salary_spread_max` — SALARY_SPREAD_MAX (0.15)**  
**UNGOVERNED** · MEDIUM — it is what keeps the three-file choice about who they are rather than what they cost.  
ch.07 §6 governs the band ('Maaş bandı = rol × seviye [WORKING]') and says the quoted salary is take-it-or-leave-it ('Mülakat yok. Maaş pazarlığı yok'); the spread WITHIN one search's three files is in no chapter. Read by _salary_window to cut a narrow, band-centred window (hr_candidate_generator.gd:252) and asserted by the smoke suite (endgame_smoke.gd:4415).  
*Costs the player:* Caps the priciest of three files at 15% over the cheapest — for a mid developer window that is roughly $1.35k/month of spread across the whole shortlist.  
*If removed:* _salary_window loses its width and the three quotes spread across the entire band (mid developer $8,000-$12,000, 50% apart). Price would become the dominant axis of the shortlist decision instead of skill shape — which is what ch.07 §6's three-card grammar (star, key area, secondary, trait) is built to make the decision about.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:715` · `scripts/systems/hr_candidate_generator.gd:246-260`


**`num.seed_strides` — SEED_DAY_STRIDE (7) / HIRES (13) / ROLE (101) / BAND (17)**  
**UNGOVERNED** · LOW.  
seed = 7·day + 13·run_hires + 101·(role_index+1) + 17·(band_index+1) at :169-172, stored on GameState.hr_search at commissioning (hr_search_system.gd:147-155).  
*Costs the player:* Nothing.  
*If removed:* Two searches on the same day for different roles or bands would return identical people, and the stored seed would no longer reproduce the same three files after a reload.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_candidate_generator.gd:66-72` · `scripts/systems/hr_candidate_generator.gd:161-172`


**`num.severance` — SEVERANCE_MIN_MONTHS (1) / DAYS_PER_YEAR (365)**  
**UNGOVERNED** · HIGH — the price of the only HR lever ch.08 §6 gives a player in the bankruptcy window, and it appears in no chapter's cost list.  
No chapter mentions severance. ch.08 §1's one-off list is closed — 'Atlas retainer, eğitim, lisans, kesinti telafisi' — and severance is not on it. ch.08 §6 names 'let someone go' as a shutter recovery move and attaches no cost to it. ch.07 §9 covers departures as event moments and says only 'Bilgi kaybı / teknik borç cezası yok'.  
*Costs the player:* max(1, floor(days_served / 365)) months of that person's salary, in cash, charged through FinanceSystem.apply_one_time_cost BEFORE the removal (hr_actions.gd:184-189) — $9,500 the instant you fire a mid developer.  
*If removed:* preview_fire's headline number (:146-148) and fire's charge go; firing becomes instantly cash-positive, which directly inverts ch.08 §6's shutter window — 'birini bırak' would buy runway for free instead of costing a month of burn today to save burn tomorrow. Note DAYS_PER_YEAR 365 sits beside GameState.DAYS_PER_MONTH 30 (12×30 = 360): two calendars, unreconciled, so seniority crosses a year five days after the game's twelfth month.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1005-1007` · `scripts/systems/hr_constants.gd:1018-1024` · `scripts/systems/hr_actions.gd:184-189`


**`num.shape_premium_ceiling` — _shape_premium ceiling = AREA_MAX × 4 (40)**  
**UNGOVERNED** · LOW — small money, but it is the sole load-bearer of the three-distinct-quotes invariant, on a documented margin that is now stale and thinner than it reads.  
ch.07 §6 governs the band; nothing governs a premium divisor. Live value 40 (hr_candidate_generator.gd:288), while the comment block above it (:272-276) still works the margin at /36 — 'junior 5000·0.10·4/36 = 55.6 · mid 7600·0.10·3/36 = 63.3 · senior 10800·0.10·3/36 = 90.0', true at AREA_MAX 9. At 40 those become 50.0 / 57.0 / 81.0, so the junior figure now sits exactly ON SALARY_ROUND_TO (50) rather than above it — the safety line the same comment names as protecting the distinct-quote invariant. The invariant survives only because the real anchor is the centred window_low (developer/junior 6150), not the band floor of 5000 the comment quotes.  
*Costs the player:* The divisor going 36 -> 40 cut every quoted salary's premium term by 10% — the whole channel through which the AREA_MAX 9 -> 10 change moved money.  
*If removed:* _shape_premium is the ONLY differentiator inside _salary_for (asked = window_low × (1 + premium), verified at :230-233), so without it all three quotes round onto one number and the distinct-salary assertion the smoke enforces fails outright.  
*Verification:* ed salaries, because _shape_premium prices against AREA_MAX × 4. Taken deliberately (Erdem 2026-08-21)". Worth adding a precision the row is slightly hard on itself about: at /40 the junior figure lands at exactly 50.0, and since _round_to (:395-398) is round(x/50)*50, two raw values exactly one step apart can still never collapse — so the invariant holds at the boundary rather than by luck of the centred window. The comment at :281 ("the migration moved zero lira") is the line that is now simply false. SALARY_PEAK_PREMIUM 0.10 (hr_constants.gd:716) and SALARY_ROUND_TO 50 (generator :83) confirmed.  
Evidence: `scripts/systems/hr_candidate_generator.gd:288` · `scripts/systems/hr_candidate_generator.gd:272-276` · `scripts/systems/hr_candidate_generator.gd:230-233` · `scripts/systems/hr_constants.gd:47-53`


**`num.skillcheck_bands` — SkillCheck margin bands + SALES_READ_THRESHOLD (2)**  
**UNGOVERNED** · MEDIUM — the read gate silently prices one onboarding point at 'can you see the sales game'.  
No chapter describes outcome bands or a read gate. All four band literals are inline in _band (:94-105), not named constants: margin >= 0.40 crit_success, >= 0.15 success, else near_pass; <= -0.40 crit_fail, <= -0.15 fail, else near_miss.  
*Costs the player:* SALES_READ_THRESHOLD 2 is a hard information gate — a founder with Satış below 2 cannot read a prospect at all (pitch_system.gd:161, :222), which is one full star of the founder's opening allocation spent to see the sales tab properly.  
*If removed:* _band's thresholds go and every check resolves to a bare pass/fail with no near-miss framing, flattening the pitch and VC scenes' copy; can_read_prospect would either always or never allow a read, removing a founder-skill gate on ch.04 §6's pipeline surface.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/skill_check.gd:20` · `scripts/systems/skill_check.gd:94-110` · `scripts/systems/pitch_system.gd:161`


**`num.skillcheck_probabilities` — SkillCheck BASE_CHANCE / SKILL_STEP / BONUS_STEP / DIFFICULTY_STEP / MIN / MAX**  
**UNGOVERNED** · HIGH — the widest-read HR-adjacent formula in the game, governing both victory paths, and it is authored nowhere.  
No chapter describes a skill-check formula. ch.04 §2 states a link ('Close probability = Satış skill of whoever sells') and ch.09 §4 lists inputs ('What speaks: founder Karizma, the last three months' growth, churn, margin, product state'), neither a curve nor a clamp. Base 45%, +15%/skill point, +10%/bonus, -15%/difficulty, clamped 5-95%.  
*Costs the player:* It is the entire conversion of a founder skill point into an outcome: each point is +15 percentage points, so four points separate near-certain failure from near-certain success on the same check.  
*If removed:* chance_for (:32-36) and breakdown (:42-54) lose every term, and with them PitchSystem's close rolls (pitch_system.gd:298, :314), the whole VC meeting (vc_pitch_system.gd:171, :183, :203, :232) and TermSheetTableSystem's lever odds (:105, :161-165). The founder's skill card stops mattering anywhere a check is rolled — including the run's final decision.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/skill_check.gd:14-19` · `scripts/systems/skill_check.gd:32-36` · `scripts/systems/vc_pitch_system.gd:171-232` · `scripts/systems/term_sheet_table_system.gd:105`


**`num.tech_reducers` — BUG_TECH_REDUCER / WEAR_TECH_REDUCER (both 0.005)**  
**UNGOVERNED** · MEDIUM — the whole skill-to-quality channel, split across two identical constants that must move together.  
Boundary row. ch.03 §6 governs the direction ('bugs accrue at a rate inverse to Geliştirme') and ch.07 §2 gives Test 'canlı bug aşınması', but no chapter carries a coefficient. Same number, two homes, two formulas.  
*Costs the player:* Nothing directly; these are the two coefficients converting team quality into bug accrual and live wear.  
*If removed:* Both formulas lose their skill term outright — bugs and wear become flat regardless of who is assigned, severing the two levers ch.07 §2 gives Yazılım and Test. The named hazard is narrower: a calibration pass changing one and not the other would break the equivalence at product_system.gd:559-567 that justified leaving both unscaled.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:116` · `scripts/systems/product_system.gd:162` · `scripts/systems/product_system.gd:559-567`


**`num.trait_share_resolution` — TRAIT_SHARE_RESOLUTION (100)**  
**UNGOVERNED** · LOW.  
Arithmetic resolution, declared in the generator rather than HRConstants on purpose (:12-14). CANDIDATE_COUNT 3 × TRAIT_COST_SHARE 0.5 = 1.5, so whole = 1 and remainder = 50; a seed draw under 50 adds a second carrier (:310-315).  
*Costs the player:* Nothing directly — it decides whether a given search yields one or two liability-carrying candidates.  
*If removed:* _cost_carriers loses its fractional remainder and the carrier count freezes at 1 every search, halving the variance of the three-file spread.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_candidate_generator.gd:74-78` · `scripts/systems/hr_candidate_generator.gd:308-320`


**`num.vacation_days` — VACATION_DAYS (7)**  
**UNGOVERNED** · LOW.  
No chapter contains manual vacation. Zero readers anywhere in scripts/, including the smoke suite. Orphaned by the same 2026-08-22 deletion; HRActions._current_year (:254-255), which only that action used, is orphaned with it.  
*Costs the player:* Nothing.  
*If removed:* Nothing whatsoever. Pure debris.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:1006` · `scripts/systems/hr_actions.gd:115-128` · `scripts/systems/hr_actions.gd:254-255`


**`num.assignable` — ASSIGNABLE (7 ids) and AREA_RESEARCH**  
**DIVERGENT** · HIGH — Araştırma is a visible, clickable cell in the Görevler matrix that silently discards a person's whole working day, and the tech-debt/serving-cost lever ch.06 promises does not exist.  
GDD: ch.07 rev 2 §4 (job table) + ch.03 §2  

> Araştırma (özellik kilidi) | Ürün · Tasarım · Yazılım | kilitli özellik açılır — and, on the same table, Maliyet/borç işi | Yazılım | servis maliyeti ↓, teknik borç ↓

Two of §4's seven jobs are not delivered. (a) research IS assignable but has no consumer: the const AREA_RESEARCH is referenced only by the smoke suite, the literal appears in production only inside ASSIGNABLE itself and the save-migration table, no formula reads assignment to it, and tick_experience skips it (hr_system.gd:114) — a person parked on Araştırma produces nothing, learns nothing and unlocks no feature, while ch.03 §2 still gates one feature per axis behind 'Araştırma gerekir'. (b) Maliyet/borç işi has no slot at all: nothing in ASSIGNABLE lets a player put an engineer on serving cost or tech debt, which ch.06 §1.1 and §1.4 both name as the player's decision against those two forces. Also DUPLICATE: the const at :138 is shadowed by the re-typed literal at :140.  
*Verification:* se. "Araştırma is a visible, CLICKABLE cell in the Görevler matrix that silently discards a person's whole working day" is FALSE. HRConstants.can_hold_area (hr_constants.gd:170-179) lets an employee hold only their KEY or SECONDARY area, and ROLE_AREAS (:117-124) maps all six roles onto the six real areas — none to "research". hr_assignments._cell (:146-149) returns _dashed_cell() with no Button whenever can_hold_area is false, so every employee's Araştırma cell is drawn dashed and refuses the click. can_hold_area admits only category == "founder" (:177-178), and the founder has no row in the matrix (hr_assignments.gd:113-118) and no writer but _reseat_founder, which only ever assigns …  
Evidence: `scripts/systems/hr_constants.gd:138-140` · `scripts/systems/hr_system.gd:112-115` · `scripts/autoload/save_manager.gd:53`


**`num.climate_gain` — CLIMATE_GAIN_PER_POINT (0.05) / CLIMATE_GAIN_CAP (1.50)**  
**DIVERGENT** · MEDIUM — it is one of only two founder-Liderlik levers that actually reach a formula.  
GDD: ch.02 §4  

> Liderlik: morale ceiling + team output multiplier.

ch.02 §4 gives founder Liderlik a morale CEILING. No ceiling exists anywhere in the code: MORALE_MAX is a flat 100 for everyone and climate_gain_mult instead multiplies POSITIVE deltas by clamp(1 + 0.05·L, 1.0, 1.50) in scaled_delta's positive branch (:249-250). ch.07 rev 2 §2 names only the fall rate ('moral düşüş hızını'), so amplifying recovery has no line in the operative chapter either. The cap needs Liderlik 10; the reachable maximum with AREA_TRAIN_CAP 8 is 1.40.  
*Chapter conflict:* ch.02 §4 legislates a morale ceiling; ch.07 rev 2 §2 legislates a morale-fall-rate modifier and no ceiling. Code implements neither a ceiling nor a fall-only reading — it scales both directions.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:892-893` · `scripts/systems/hr_constants.gd:911-913` · `scripts/systems/hr_morale_system.gd:249-250`


**`num.engineer_signal` — ENGINEER_SPRINT_THRESHOLD (3) / ENGINEER_WINDOW_DAYS (20)**  
**DIVERGENT** · MEDIUM — the badge the player is taught to read as 'this person has too many jobs' fires on a whole team that may each hold exactly one.  
GDD: ch.07 rev 2 §5; ch.12 §4  

> Bir kişiye birden fazla alan verildiğinde satırında aşırı yüklenme rozeti çıkar. / Flight risk · load over capacity · coverage red · infra capacity full · account at risk · raise demand · locked opportunity

§5 defines the overload badge as a per-person consequence of holding more than one area. The code additionally paints BADGE_OVERLOADED on EVERY active product_dev member from a company-level signal — three bug sprints inside 20 days sets needs_engineer (product_system.gd:170-171), HRMoraleSystem.is_capacity_overloaded reads the flag (:328-334) and badges_for hands the chip to the whole department (:275-278), regardless of how many areas any of them holds. ch.12 §4 lists 'load over capacity' as its own separate badge; here it is merged onto the overload chip. Cleared by hiring a developer (hr_search_system.gd:224-228). Threshold lives in ProductSystem, badge lives in HRConstants.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:170-171` · `scripts/systems/hr_morale_system.gd:328-334` · `scripts/systems/hr_morale_system.gd:275-278`


**`num.founder_skill_ceiling` — FounderConstants.SKILL_CEILING (5)**  
**DIVERGENT** · MEDIUM — the player allocates points against a visual ruler that misstates the scale by 2×.  
GDD: ch.02 §2 and §3; ch.07 rev 2 §3  

> Six role skills, each 0–10 internally / Scale shown to the player: stars, 5 stars at half-star resolution (0–10 → 0–5★). / Yıldız gösterimi, 5 yıldız yarım-yıldız çözünürlüğünde. Ham 0–10 yalnız derin hover'da.

The constant declares the founder's underlying maximum as 5 and its comment says founder training is a 'LATER task, not built'; that task shipped 2026-08-22 and clamps at AREA_TRAIN_CAP 8 (character_registry.gd:150, :191) while the free channel clamps at AREA_MAX 10 (:116). Nothing enforces 5. Its ONLY reader is SegmentBar's segment count (segment_bar.gd:16), so the onboarding screen draws a FIVE-segment ruler for a skill the rest of the game draws as five stars over ten points — the founder's creation screen shows a different ruler from every other surface. Three ceilings for one ruler: 5, 8, 10, and the one named CEILING is the one nothing enforces.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/founder_constants.gd:53-56` · `scripts/autoload/character_registry.gd:131-150` · `scripts/ui/components/segment_bar.gd:16`


**`num.founder_traits` — FounderConstants.TRAITS + TRAIT_MAX_POSITIVE / TRAIT_MAX_NEGATIVE**  
**DIVERGENT** · MEDIUM — the founder card shows icons that do nothing; onboarding asks the player to pick them.  
GDD: ch.02 §8 (requirement); ch.07 rev 2 §12 (the GDD's own log of the failure)  

> Modifiers only (skill, rate, probability, morale); never a hidden skill number; shown as icons with tooltips. / Kurucu trait'leri bugün çalışmıyor (kod kurucu trait'ini çalışan tablosunda arıyor) — dönülecek.

The eight founder traits carry only id/polarity/name_key/effect_key — no numeric axis of any kind — and the file states the whole mechanical status itself: 'trait EFFECTS are consumed by no system yet' (:64-65). ch.02 §8 requires every trait to be a modifier; none of these is. Two tables named TRAITS with two validators enforcing contradictory formulas (validate_traits wants >=1 positive and forces exactly 1 negative at 2 positives; validate_employee_traits wants exactly 1 of any polarity), and 'polarity' survives here after being retired on the employee side (hr_constants.gd:463).  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/founder_constants.gd:58-75` · `scripts/systems/founder_constants.gd:188-210` · `scripts/systems/hr_constants.gd:463-468`


**`num.morale_burnout` — MORALE_BURNOUT (40) / TÜKENİYOR**  
**DIVERGENT** · HIGH — the whole morale economy (overtime, overload, departures, positive beats) buys and spends a number that never touches output; only the resignation tail bites.  
GDD: ch.07 rev 2 §7  

> Düşük moral çıktıyı düşürür, sonra kaçma riski rozetine, sonra istifaya gider.

The ladder's FIRST rung does not exist. Grep for morale across product_system.gd, sales_rep_system.gd, customer_rep_system.gd and hr_system.gd returns only comments about overtime — there is no morale term in any output, speed, throughput or capacity formula. MORALE_BURNOUT 40 is asked only through is_burning_out (:875-876), whose two readers are badges_for (a chip) and morale_color (a colour). Low morale therefore costs the player nothing until it crosses MORALE_FLIGHT_RISK 25 and the resignation counter starts. Also: TÜKENİYOR is not on ch.12 §4's badge list.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:765` · `scripts/systems/hr_constants.gd:870-876` · `scripts/systems/hr_morale_system.gd:267-270` · `grep 'morale' scripts/systems/product_system.gd → 0 formula hits`


**`num.overload_morale_mult` — OVERLOAD_MORALE_MULT (1.6)**  
**DIVERGENT** · HIGH — removes the escalation §5 designs the badge around; carrying two areas forever is a pure 25% output haircut with no path to resignation.  
GDD: ch.07 rev 2 §5 + §7  

> Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider. / Girdiler: fazla mesai · aşırı yüklenme · başarı ve başarısızlık anları ...

The constant is declared and read by nothing. HRMoraleSystem.scaled_delta folds in _team_decay_mult and climate_drop_mult only (:242-254); no overload term exists anywhere in the morale path. §7 names aşırı yüklenme as a morale INPUT and §5 makes 'moral düşer' the whole reason overload escalates to flight risk — neither is implemented. Overload costs output (after tolerance) and nothing else.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:146` · `scripts/systems/hr_morale_system.gd:242-254`


**`num.overload_output_mult` — OVERLOAD_OUTPUT_MULT (0.75)**  
**DIVERGENT** · MEDIUM — the output half works as designed; the experience half is a phantom penalty the player is told about (§5 hover) and never pays.  
GDD: ch.07 rev 2 §5  

> Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider. Sayısal ağırlıklar [WORKING], kalibrasyonda belirlenir.

§5 legislates ONE tolerated grace period before any overload cost. The code applies the same constant through two different gates: output_mult_for_area applies it only when overload_bites() is true, i.e. after OVERLOAD_TOLERANCE_DAYS 5 (hr_system.gd:245-246); tick_experience applies it the moment assigned_jobs.size() > 1 with no tolerance check at all (:103). On the experience path it is additionally inert by arithmetic — round(1×0.75)=1, round(2×0.75)=2, then maxi(gain,1) at :122 — so the un-toleranced penalty costs zero anyway. Same number, two meanings of 'overloaded', one of them a no-op.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:145` · `scripts/systems/hr_system.gd:103` · `scripts/systems/hr_system.gd:120-122` · `scripts/systems/hr_system.gd:245-246`


**`num.role_lock_gate` — role_lock_reason_key — the B2B hiring gate**  
**DIVERGENT** · MEDIUM — it caps the reachable roster at four roles in a B2C run and removes the two cards the GDD uses to telegraph the full game.  
GDD: ch.07 rev 2 §6 + §1; ch.01 §9  

> Kilitli iki rol kartı: Pazarlama, in-house İK. / Demo kapsamı dışı (EA): Pazarlama rolleri, in-house İK çalışanı. İkisi de Atlas'ta kilitli-görünür kart olarak durur.

The GDD names exactly two locked role cards and the code locks two DIFFERENT roles for a different reason: sales_rep and customer_rep return a lock key unless ProductSystem.has_b2b_product() (hr_constants.gd:432-455), enforced engine-side at hr_search_system.gd:137-139. Pazarlama and in-house İK are not in EMPLOYEE_ROLES at all, so they are absent rather than locked-visible — against ch.01 §9 'Locked choices are visible, never hidden' and §1's explicit 'Atlas'ta kilitli-görünür kart olarak durur'. The B2B gate itself has no GDD line anywhere.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:432-455` · `scripts/systems/hr_search_system.gd:132-142` · `scripts/systems/hr_candidate_generator.gd:167`


**`num.trainable_keys` — trainable_keys() and the modal's narrowing**  
**DIVERGENT** · MEDIUM — it removes retraining as a strategy: the only way to move a person into a different area is to hire someone else.  
GDD: ch.07 rev 2 §8 + §3  

> Oyuncu hangi alanın yükseleceğini seçer.

trainable_keys() returns all seven (six areas + Liderlik, Karizma excluded) and both engine gates opened 2026-08-22 — the founder became trainable and Liderlik became trainable (character_registry.gd:131-137). But TrainingModal offers an EMPLOYEE only three of the seven: key area + secondary area + Liderlik (training_modal.gd:160-167), while the founder gets all seven (:164). §8 gives the player free choice of area with no restriction; a developer cannot be trained in Satış or Müşteri Başarısı, which also closes the cross-cover §2 sells as the point of the area model.  
*Verification:* g clamps at AREA_TRAIN_CAP 8 (character_registry.gd:150, :191; hr_constants.gd:815-818), so §8's free choice of area is narrowed twice — by which area, and by how far.  
Evidence: `scripts/systems/hr_constants.gd:840-850` · `scripts/autoload/character_registry.gd:126-150` · `scripts/modals/training_modal.gd:160-167`


**`num.trait_counts` — TRAIT_COUNT (1) / TRAIT_MAX_COST (1) / TRAIT_COST_SHARE (0.5)**  
**DIVERGENT** · MEDIUM — halves the trait information on every candidate card, which is one of only four things §6 lets the player read before paying.  
GDD: ch.07 rev 2 §6; ch.02 §1 and §9  

> Aday kartı: rol uyum yıldızı + anahtar alan + varsa ikincil alan + 1–2 trait. / Traits from the existing catalog (~12 positive / 12 negative), shown as icons.

§6 and ch.02 §9 both say 1–2 traits per file; TRAIT_COUNT is 1 and validate_employee_traits enforces exactly one (:587-600), so a two-trait candidate is impossible. The catalog is 8 entries (3 free + 5 costed) against ch.02 §1's ~24. TRAIT_COST_SHARE 0.5 means half of generated files carry a pure liability with no upside — an explicit Erdem balance decision (:538-543) with no GDD line. TRAIT_MIN_POSITIVE / TRAIT_MAX_POSITIVE were removed 2026-08-21 with zero readers.  
*Verification:* CORRECTION on one claim; the rest holds. "TRAIT_COST_SHARE 0.5 means half of generated files carry a PURE LIABILITY with no upside" is wrong. `carries_cost: true` marks a TWO-SIDED trait, not a bad one: takes_them_under is lead_experience_mult 1.5 AND departure_morale_extra −5; double_checker is bug_rate_mult 0.5 AND speed_mult 0.85; cant_say_no is promise_chance_mult 1.6 AND satisfaction_bonus +5; bag_packed is resign_chance_mult 1.6 AND output_mult 1.15 (hr_constants.gd:508-533). Only mood_buster is one-sided. The generator states the rule outright: "R4 iyi/kötü ayrımını kaldırdı … Ayrım artık görevin kendi Cost sütunundan türetiliyor" (hr_candidate_generator.gd:296-300). Half of files …  
Evidence: `scripts/systems/hr_constants.gd:538-551` · `scripts/systems/hr_candidate_generator.gd:308-320` · `scripts/autoload/save_manager.gd:931-932`


**`num.trait_takes_them_under` — TRAIT takes_them_under (GERÇEK LİDER)**  
**DIVERGENT** · MEDIUM — doubles the lead's effect on learning through a channel §2 explicitly closed.  
GDD: ch.07 rev 2 §2  

> Liderlik: ekip lideri atanan çalışanın altındaki ekibin verimlilik modifier'ını, moral düşüş hızını ve deneyim kazanım hızını etkiler. Mentorluk ayrı bir trait ya da sistem değildir; Liderlik'in içindedir.

§2 forbids exactly this construct by name. The code ships lead_experience_mult 1.5 on a TRAIT, read by HRSystem.tick_experience's mentor_mult (:116-119) — so an area's learning speed depends on whether the lead happens to carry GERÇEK LİDER, on top of the Liderlik curve §2 says already contains mentoring. departure_morale_extra -5 makes their exit cost 10 rather than 5 (hr_morale_system.gd:414-416).  
*Chapter conflict:* ch.02 §7 authorises mentoring as its own growth channel — 'Tertiary: mentoring (a high-skill teammate lifts a low-skill one)' — while ch.07 rev 2 §2 dissolves it into Liderlik. The code implements ch.02's channel but gates it on a trait neither chapter names.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:508-512` · `scripts/systems/hr_system.gd:116-119` · `scripts/systems/hr_morale_system.gd:410-416`


**`num.area_max` — AREA_MAX (10)**  
**GOVERNED**  
GDD: ch.02 §2 and §3; ch.07 rev 2 §3  
The 2026-08-21 raise 9 -> 10 moved the code ONTO the GDD, not away from it — at 9 the top of the ruler was 4½ stars and five could never fill. The documented side effect is real: _shape_premium prices against AREA_MAX × 4, so the divisor went 36 -> 40 and every quoted salary's premium term fell ~10%. The UNDOCUMENTED side effect is that five Liderlik-normalised endpoints became unreachable, because Liderlik is not in AREAS (character_registry.gd:103) and caps at AREA_TRAIN_CAP 8.  
Evidence: `scripts/systems/hr_constants.gd:47-54` · `scripts/systems/hr_candidate_generator.gd:288` · `scripts/autoload/character_registry.gd:116`


**`num.area_min` — AREA_MIN (0)**  
**GOVERNED**  
GDD: ch.02 §2; ch.07 rev 2 §3  
Structural floor, not a balance knob. Clamps in validate_employee_skills, seed_skills, the generator, _dominates' missing-key default and the save migration.  
Evidence: `scripts/systems/hr_constants.gd:46` · `scripts/systems/hr_constants.gd:98` · `scripts/systems/hr_candidate_generator.gd:390`


**`num.band_shape` — BAND_SHAPE (three [key, secondary, rest] profiles per band)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 and §2; ch.02 §3  
Peak on the key area, one below on the secondary, a floor elsewhere — the §2 shape. The senior peak went to 10 on 2026-08-22 because the five-star ruler both display sections mandate is otherwise unreachable by any candidate in the game. Read BY MEANING since rev 2, not by position. Consequence: the third senior profile's Liderlik is 7, the highest any hire can carry.  
Evidence: `scripts/systems/hr_constants.gd:654-684` · `scripts/systems/hr_candidate_generator.gd:177-224`


**`num.big_signing` — BIG_SIGNING_MRR (1500) / BIG_SIGNING_MORALE (4)**  
**GOVERNED**  
GDD: ch.07 rev 2 §7  
A success moment under §7's general clause, though §7's parenthetical names only ship, account loss and incident. _big_signing_today scans CustomerRegistry for acquired_on_day == today with mrr >= 1500, largest wins, with NO market_type filter — so in a B2C run, which has audiences rather than acquired accounts, this beat can never fire and the team loses one of its three positive channels. Boundary into ch.04 recorded, not audited.  
Evidence: `scripts/systems/hr_constants.gd:1077-1078` · `scripts/systems/hr_morale_system.gd:538-551` · `scripts/systems/hr_event_factory.gd:79-83`


**`num.candidate_count` — CANDIDATE_COUNT (3)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6; ch.02 §9  
Verbatim, and load-bearing in three places: the generator loop, _cost_carriers (whose free-trait pool of 3 exactly suffices at 3 and would not at 4), and preview_search. The code records that 'dar havuz' was retired as a band name because it implied fewer candidates — the band is a budget level, not a pool size, which matches §6's flat 'üç aday' in every band.  
Evidence: `scripts/systems/hr_constants.gd:714` · `scripts/systems/hr_candidate_generator.gd:108` · `scripts/systems/hr_candidate_generator.gd:326-330`


**`num.capacity_base` — ProductSystem.CAPACITY_BASE (1)**  
**GOVERNED**  
GDD: ch.02 §5; ch.03 §8; ch.06 §1.3  
capacity_total = 1 + count_active_in_department(DEPT_PRODUCT_DEV). The widening from developers-only is right per ch.07 §4's build row ('Ürün · Tasarım · Yazılım alanları'). One gap: it counts the DEPARTMENT, not the ASSIGNMENT, so a designer sitting idle in product_dev still adds capacity — §4 makes the assignment the unit. On-leave and in-training people are correctly excluded via STATUS_ACTIVE.  
Evidence: `scripts/systems/product_system.gd:172-176` · `scripts/systems/product_system.gd:237-243` · `scripts/autoload/character_registry.gd:311-319`


**`num.climate_drop` — CLIMATE_DROP_PER_POINT (0.05) / CLIMATE_DROP_FLOOR (0.50)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 and §7  
clamp(1 - 0.05·L, 0.50, 1.0) applied in scaled_delta's negative branch — precisely §2's 'moral düşüş hızı'. The floor is dead as a bound: it needs Liderlik 10, while the founder starts capped at ONBOARDING_CAP 3 and can only train to AREA_TRAIN_CAP 8, giving 0.60 as the true best case. Note the reading is the FOUNDER's Liderlik, while §2's sentence is about 'ekip lideri atanan çalışan'.  
Evidence: `scripts/systems/hr_constants.gd:890-891` · `scripts/systems/hr_constants.gd:906-908` · `scripts/systems/hr_morale_system.gd:240-248`


**`num.coord_curves` — COORD_MIN (0.85) / COORD_MAX (1.20) / COORD_FOUNDER_NEUTRAL (1.0)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2; ch.02 §4  
Two curves — founder neutral at 0 rising to COORD_MAX, employee-lead lerping the full ruler — both read by ProductSystem._lead_coordination. Two findings recorded here rather than as separate rows. (1) Neither endpoint is attainable: a founder tops out at Liderlik 8 -> 1.16, an employee lead at 7 (or 8 trained) -> 1.13, because both normalise by AREA_MAX 10. Comments at :812, :926 and :939-940 all still say 'Liderlik 9'. (2) M2-class collision: §2 and §9 both assume an APPOINTED lead ('ekip lideri atanan çalışan', 'Ekip lideri istifa etti, yerine kim geçiyor?'), but nothing in production ever writes GameState.area_leads, so HRSystem.area_lead's explicit-choice branch is unreachable in a fresh run and the lead is always the highest-Liderlik fallback — the player never appoints anyone and never answers the succession question §9 writes.  
Evidence: `scripts/systems/hr_constants.gd:895-903` · `scripts/systems/hr_constants.gd:923-946` · `scripts/systems/product_system.gd:495-506` · `scripts/systems/hr_system.gd:187-205`


**`num.cs_desk_coefs` — B2BConstants customer-desk coefficients on a person's Müşteri Başarısı**  
**GOVERNED**  
GDD: ch.07 rev 2 §5 and §2; ch.06 §1.2 and §1.3  
Boundary row, and the tightest match in the whole audit: CS_BASE_CAPACITY 3 + int(cs / CS_PACE_PER_SLOT 3) yields the ladder 3 / 4 / 5 / 6 — exactly §5's '[WORKING 3–6]' band, with AREA_MAX 10 also landing on 6 so the band still holds. CS_DAMPEN_PER_POINT 0.055 with CS_DAMPEN_MIN 0.4 (the comment's worked '1 - 9·0.055 = 0.505' is now 0.45 at AREA_MAX 10, still above the floor, so the floor stays structurally unreachable as designed). CS_THROUGHPUT_BASE 0.5 + 0.15/point, CS_ABSORB_BASE 3, FOUNDER_DIRECT_CAP 4, CS_ESCALATION_SAT 35, CS_ESCALATION_WEEKLY_CAP 2, CS_REQUEST_INTERVAL_DAYS 22, CS_PHASE_STRIDE 9, CS_ESCALATE_AFTER_DAYS 3, CS_REQUEST_IGNORE_SAT -6.  
*Chapter conflict:* ch.06 §1.2's capacity formula multiplies by Hız, the axis ch.07 rev 2 §2 deleted; the code reads Müşteri Başarısı alone and treats CS_PACE_PER_SLOT as an area reading, so the constant name is a ch.02 fossil.  
Evidence: `scripts/systems/b2b_constants.gd:189-228` · `scripts/systems/b2b_constants.gd:325-350` · `scripts/systems/customer_rep_system.gd:79-80` · `scripts/systems/customer_rep_system.gd:244`


**`num.cs_refuse_morale` — CS_REFUSE_MORALE (10) / CS_REFUSE_BRAND (3)**  
**GOVERNED**  
GDD: ch.11 §4; ch.07 rev 2 §7; ch.04 §3  
Boundary row. Refusing a CS employee's promise emits {'type':'morale','character_id':cs.id,'delta':-10}, routed by EventManager into HRMoraleSystem.apply_delta for employees so trait and climate scaling still apply. It is the cost ch.11 §4 requires of that option — and the largest single non-overtime morale hit in the game. Its home is b2b_constants.gd, not HRConstants, against hr_constants.gd:10-11's stated rule.  
Evidence: `scripts/systems/b2b_constants.gd:198-199` · `scripts/systems/b2b_event_factory.gd:131` · `scripts/autoload/event_manager.gd:583-586`


**`num.experience_lead_bonus_max` — EXPERIENCE_LEAD_BONUS_MAX (1.5)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 and §8  
The mechanic is exactly §8's sentence, but the declared ceiling is unpayable: experience_gain_mult normalises by AREA_MAX 10, so 1.5 needs Liderlik 10, and 10 is unreachable — leadership is not in AREAS so the free channel refuses it (character_registry.gd:103), paid training caps at 8, and the best generated file carries 7. Real reachable maximum 1 + 0.5×0.8 = 1.40. Its own comment still says 'Liderlik 9'daki lider', correct at AREA_MAX 9.  
Evidence: `scripts/systems/hr_constants.gd:812` · `scripts/systems/hr_constants.gd:188-193` · `scripts/autoload/character_registry.gd:103`


**`num.experience_max` — EXPERIENCE_MAX (100)**  
**GOVERNED**  
GDD: ch.07 rev 2 §8; ch.02 §7  
ch.02 §7's pace target is the governed anchor to score the value against: 100 points at EXPERIENCE_PER_DAY 1 is 100 worked days per free +1, so a continuously assigned person gains ~2-3 points over a typical 275-day run — roughly the one tier §7 asks for, before the build-day doubling and the lead, own-trait and mentor multipliers push it faster. A capped area holds the counter full and stops.  
Evidence: `scripts/systems/hr_constants.gd:809` · `scripts/autoload/character_registry.gd:105-123` · `scripts/tabs/hr/hr_ledger.gd:278-287`


**`num.experience_per_day` — EXPERIENCE_PER_DAY (1) / EXPERIENCE_PER_BUILD_DAY (2)**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 and §4; ch.02 §7  
Idle people are skipped entirely (:100-101), which is the second half of §4's idle sentence — being idle loses tomorrow as well as today, a consequence §4 does not state. The build-phase doubling (b.current_phase in iteration/development/bugfix) has no GDD line. The founder was added as a learner 2026-08-22, correct under ch.02 §1 ('Same skill card as every employee'). The maxi(gain, 1) floor at :122 is an inline literal and the only HR number in the orchestrator, against hr_constants.gd:10-11's single-home rule.  
Evidence: `scripts/systems/hr_constants.gd:810-811` · `scripts/systems/hr_system.gd:89-122`


**`num.founder_asset_counts` — PORTRAIT_IDS (11) / LOGO_STYLES (4) / ORIGINS (3) / three 8-entry label tables**  
**GOVERNED**  
GDD: ch.01 §8; ch.14 §3; ch.14 §7  
The load-bearing half is verbatim in two chapters: three origins, two locked (heir LOCK_FULL, corporate_refugee LOCK_SOON). The rest has no line. Notably ch.14 §7's portrait policy legislates employees, VCs, customer-side characters and Frank — and never the FOUNDER's own portrait, so PORTRAIT_IDS' 11 entries (against a mockup showing 12; the comment names the missing founder_12.webp) and LOGO_STYLES' 4 sit outside it. The three 8-entry skill-label tables are deliberately not collapsed into HRConstants.area_label because they are lowercase sentence fragments against Title Case column headers.  
Evidence: `scripts/systems/founder_constants.gd:83-115` · `scripts/systems/founder_constants.gd:117-144`


**`num.founder_job_cap` — The founder's one-area lock (value 1, never named)**  
**GOVERNED**  
GDD: ch.02 §5; ch.07 rev 2 §4  
Enforced twice as an inline structural test with no constant: assign_area refuses a second area with 'founder_busy' (:221-223) and _validate_shape push_errors at size > 1 (:507-509). can_hold_area grants the founder all seven areas and notes the limit is by COUNT, not by which one. The asymmetry is also governed — §4 explicitly permits multiple areas per employee ('Bir kişiye birden fazla alan verilebilir') and §5 prices it, so there is correctly no MAX_JOBS for staff.  
Evidence: `scripts/autoload/character_registry.gd:221-223` · `scripts/autoload/character_registry.gd:507-509` · `scripts/systems/hr_constants.gd:170-179`


**`num.founder_point_pool` — FounderConstants.POINT_POOL (6)**  
**GOVERNED**  
GDD: ch.02 §11; ch.12 §5  
Point distribution as a mechanism is governed by both chapters; the pool SIZE of 6 is in neither. Held at 6 through the area migration on purpose so a founder who used to put 3 in tech now puts 3 in engineering and every formula reads the same number — and the file flags the consequence itself as a live calibration candidate: six points over EIGHT columns means many more true zeros than over five.  
*Chapter conflict:* ch.02 §11 requires onboarding to set 'the 7+2 numbers' — ch.02 §2's six skills plus Hız, plus Liderlik and Karizma = nine columns. ch.07 rev 2 §2 leaves eight (six areas + Liderlik + Karizma). The code follows ch.07, which is precisely what stretches an unchanged pool of 6 over a different column count.  
Evidence: `scripts/systems/founder_constants.gd:42-52` · `scripts/systems/founder_constants.gd:166-183`


**`num.founder_starting_cash` — FounderConstants.STARTING_CASH (10000)**  
**GOVERNED**  
GDD: ch.09 §1; ch.01 §4  
Verbatim in both chapters. Single home for the origin catalog and GameState's defaults, referenced by the self_made origin; the two locked origins carry no starting_cash at all, correct under ch.01 §8. Boundary to Finance — recorded, not audited.  
Evidence: `scripts/systems/founder_constants.gd:77-98`


**`num.iteration_ceiling_coefs` — ITER_CEIL_FOUNDER_COEF / ROLE_COEF / ROLE_CAP / ROUND_DAYS / MAX_ROUNDS / AXIS_AREA**  
**GOVERNED**  
GDD: ch.03 §5 and §14; ch.07 rev 2 §2 and §4  
ITER_MAX_ROUNDS 4 matches §5's 'max 4' verbatim (the director ruling of 2026-08-19 moved 12 -> 4, i.e. onto the chapter). The ceiling formula itself is explicitly an open decision in ch.03 §14, so [WORKING] is the correct state. ITER_CEIL_AXIS_AREA maps experience<-design, which §2's table states verbatim ('Tasarım ... Deneyim ekseni'), and innovation<-product, a fair read of 'özellik kararları' — but stability<-engineering is named by no chapter; §2 gives Yazılım only speed and bug rate. Founder term reads zero unless the founder is on the build.  
Evidence: `scripts/systems/product_system.gd:63-96` · `scripts/systems/product_system.gd:785-802`


**`num.key_set_sizes` — EMPLOYEE_SKILL_KEYS (7) vs FounderConstants.SKILLS (8)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2  
Exactly the rev 2 arithmetic: employee 6 + Liderlik = 7, founder 6 + Liderlik + Karizma = 8, enforced by validate_employee_skills' size test and _validate_shape. RETIRED_SKILL_KEYS ['expertise','pace','rapport'] is the tripwire. Stale: character.gd:14 and :55 still document the ruler as '0-9'.  
*Chapter conflict:* ch.02 §2 legislates a different seven — 'Plus one meta: Hız (time-to-complete of the assigned work). Total stored per person: 7 numbers' — six skills including Pazarlama and Operasyon plus Hız, with Liderlik and Karizma founder-only per ch.02 §4. ch.07 rev 2 §2 deletes Hız ('Hız (pace) skill'i kaldırıldı'), drops Pazarlama and Operasyon as skills, adds Ürün and Test, and moves Liderlik onto …  
Evidence: `scripts/systems/hr_constants.gd:43-44` · `scripts/systems/founder_constants.gd:36-37` · `scripts/data_models/character.gd:14`


**`num.morale_flight_risk` — MORALE_FLIGHT_RISK (25)**  
**GOVERNED**  
GDD: ch.07 rev 2 §7; ch.12 §4  
One comparison, three readers, deliberately shared: badges_for, tick_thresholds' counter, and the overtime valve's trigger — the valve comment states that an employee warned by a modal with no badge on their card would be a bug. This is the rung of §7's ladder that actually bites, since the first rung (output) is unimplemented.  
Evidence: `scripts/systems/hr_constants.gd:766` · `scripts/systems/hr_constants.gd:879-880` · `scripts/systems/hr_overtime_system.gd:368-371`


**`num.morale_raise_curve` — MORALE_RAISE_AT_MIN_PCT (4) / MORALE_RAISE_AT_MAX_PCT (16)**  
**GOVERNED**  
GDD: ch.07 rev 2 §9, with §11 naming the band open  
raise_morale_gain lerps between the endpoints across the RAISE_MIN_PCT..RAISE_MAX_PCT span. preview_raise runs the figure through scaled_delta so the card shows the real post-trait, post-climate number rather than the raw lerp.  
Evidence: `scripts/systems/hr_constants.gd:771-772` · `scripts/systems/hr_constants.gd:1010-1015` · `scripts/systems/hr_actions.gd:69`


**`num.overload_tolerance_days` — OVERLOAD_TOLERANCE_DAYS (5)**  
**GOVERNED**  
GDD: ch.07 rev 2 §5, with §11 naming it open  
overload_bites tests overload_days > 5. The badge is drawn from day 1 regardless, which §5 also governs ('Bir kişiye birden fazla alan verildiğinde satırında aşırı yüklenme rozeti çıkar' — tied to holding the areas, not to the cost), so badge and cost deliberately disagree by five days.  
Evidence: `scripts/systems/hr_constants.gd:144` · `scripts/systems/hr_system.gd:153-156`


**`num.overtime_morale_tiers` — OVERTIME_MORALE_TIERS (-2 / -4 / -7)**  
**GOVERNED**  
GDD: ch.07 rev 2 §7  
§7 names fazla mesai FIRST in the morale input list, so that overtime costs morale is governed even though everything else about the overtime system is not. The escalating three-tier structure and the magnitudes trace only to the phantom 'design doc §7b'. Applied per participant in _charge_day, scaled by the carrier's overtime_morale_mult BEFORE apply_delta so team-decay and climate are not double-applied; preview_block sums the ladder tier by tier rather than hardcoding a block total.  
Evidence: `scripts/systems/hr_constants.gd:1041-1046` · `scripts/systems/hr_constants.gd:1056-1061` · `scripts/systems/hr_overtime_system.gd:119-132`


**`num.pm_experience` — PM_EXPERIENCE_PER_POINT (0.5) / PM_EXPERIENCE_CAP (3.0)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2  
Boundary row, and the closest a coefficient comes to being verbatim: §2's table hands Tasarım the Deneyim axis and this is that hand-off, min(design_total × 0.5, 3.0) over _build_area_sum(AREA_DESIGN). The magnitude has no line and the code flags it HIGH LEVERAGE itself: v1 composites sit around 7-12, so a flat +3 on one axis is a 10-15% move in normalized quality, shipping at the design's working ceiling.  
Evidence: `scripts/systems/product_system.gd:53-58` · `scripts/systems/product_system.gd:1162-1175`


**`num.product_speed_coefs` — FOUNDER_SPEED_COEF (1.0) / EMPLOYEE_SPEED_COEF (0.25) / SPEED_MIN (1.0)**  
**GOVERNED**  
GDD: ch.03 §6; ch.07 rev 2 §2 and §4  
Boundary row. Both coefficients were DERIVED from equivalence anchors rather than chosen: founder tech-3 solo = 3.0 effort/day, pace-4 employee = 1.0 effort/day. Two exist because the founder lives in the 0-3 band and employee files in the 5-8 band of the same ruler. The comment still calls the ruler '0-9' and still names the retired axis HIZ.  
*Chapter conflict:* ch.03 §6 makes build speed a function of 'Geliştirme + Hız'; ch.07 rev 2 §2 deleted Hız outright ('Hız (pace) skill'i kaldırıldı') and renamed Geliştirme to Yazılım. The code follows ch.07, leaving ch.03 §6's formula sentence naming an axis that no longer exists.  
Evidence: `scripts/systems/product_system.gd:41-50` · `scripts/systems/product_system.gd:540-551`


**`num.raise_bounds` — RAISE_MIN_PCT (3) / RAISE_MAX_PCT (15) + PCT_DIVISOR**  
**GOVERNED**  
GDD: ch.07 rev 2 §9, with §11 naming the band open  
The slider is configured straight off the constants (hr_tab.gd:792-793) and _clamp_pct clamps rather than rejects. TWO gaps worth recording under a GOVERNED verdict: (a) §9 makes the raise an EVENT the EMPLOYEE opens after a year or a level-up, and the counter-offer is the answer to a demand — the code has it as a player-initiated card action available any time, with no demand event and no median to beat; (b) RAISE_MAX_PCT's 'ONAYLI' tag sources to 'design doc §12.3', the phantom document, not to the GDD. PCT_DIVISOR 100.0 is a denominator, declared as such.  
Evidence: `scripts/systems/hr_constants.gd:1003-1004` · `scripts/systems/hr_actions.gd:36` · `scripts/systems/hr_actions.gd:246-251` · `scripts/tabs/hr_tab.gd:792-793`


**`num.resign_chance_per_day` — RESIGN_CHANCE_PER_DAY (0.25)**  
**GOVERNED**  
GDD: ch.07 rev 2 §7  
STALE COMMENT tested: :955 claims '~%76 birikimli', but with the window as coded — rolls on days 10, 11, 12, 13 then certainty on 14 — the pre-certainty cumulative is 1 - 0.75^4 = 68.4%. 76% would require five rolls. Composed in resign_chance with the trait multiplier and the valve penalty.  
Evidence: `scripts/systems/hr_constants.gd:955` · `scripts/systems/hr_constants.gd:960-964` · `scripts/systems/hr_morale_system.gd:477-490`


**`num.resign_window` — RESIGN_WINDOW_MIN_DAYS (10) / MAX_DAYS (14)**  
**GOVERNED**  
GDD: ch.07 rev 2 §7 and §9  
The mechanism is §7's third rung; the 10-14 length itself traces only to the phantom doc ('kanon aralık', :954). _maybe_resign returns before the RNG until flight_risk_days >= 10 and hard-sets chance = 1.0 at >= 14 with an INLINE literal (:483-489) rather than a named constant. The counter freezes rather than resets while on leave.  
Evidence: `scripts/systems/hr_constants.gd:953-954` · `scripts/systems/hr_morale_system.gd:475-489`


**`num.role_areas` — ROLE_AREAS (six role → {key, secondary} rows)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 and §3  
rev 2 supplies two rows verbatim (product_manager, developer); the other four — designer, tester, sales_rep, customer_rep — are Erdem's symmetric completion of 2026-08-21, recorded in code (:114-116) and in no chapter. Worth pairing with num.secondary_area_mult: ROLE_AREAS defines a secondary, but area_fatigue_mult never reads it.  
*Chapter conflict:* ch.02 §3 gives a different mapping entirely — 'Role → key + 2 supporting [WORKING]: Geliştirici = Geliştirme + Tasarım + Operasyon · Tasarımcı = Tasarım + Geliştirme + Pazarlama · Satışçı = Satış + Müşteri Başarısı + Pazarlama · MB/Destek = Müşteri Başarısı + Satış + Operasyon · Pazarlamacı = Pazarlama + Satış + Tasarım · Operasyon = Operasyon + Geliştirme + Müşteri Başarısı' — key plus TWO …  
Evidence: `scripts/systems/hr_constants.gd:117-124` · `scripts/systems/hr_constants.gd:170-179`


**`num.salary_bands` — SALARY_BANDS (18 [low, high] pairs)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6  
Literally role × band: six roles × three bands = 18 pairs, plus a [5000, 8000] fallback. Marked 'ALL WORKING — the balance pass owns these', which per M3 is a calibration state, not an absence of design.  
Evidence: `scripts/systems/hr_constants.gd:643-652` · `scripts/systems/hr_constants.gd:687-689`


**`num.sales_desk_coefs` — B2BConstants sales-desk coefficients on a person's Satış**  
**GOVERNED**  
GDD: ch.04 §2; ch.07 rev 2 §2 and §4; ch.01 §9  
Boundary row. LEAD_PER_PACE_POINT 0.06 (anchored against the founder's own 0.40/day button), LEAD_DAILY_MAX 2, PIPELINE_SOFT_CAP 8, WARM_PER_EXPERTISE_POINT 0.05 divided by difficulty_stars, WARM_BONUS_MAX 2, AUTO_CLOSE_MRR_FRAC 0.5, AUTO_CLOSE_MRR_PER_EXPERTISE 0.04. AUTONOMOUS_CLOSE_MRR_MAX 600 is the ceiling above which a rep may not close unplayed — the code cites a spec §10, but ch.01 §9's non-negotiable is the real law behind it and the cap satisfies it exactly. Constant names still say PACE, an axis §2 deleted.  
Evidence: `scripts/systems/b2b_constants.gd:302-319` · `scripts/systems/sales_rep_system.gd:102-197`


**`num.search_arrival_window` — SEARCH_ARRIVAL_MIN_DAYS (2) / MAX_DAYS (4) + arrival mixer**  
**GOVERNED**  
GDD: ch.07 rev 2 §6  
Verbatim. _arrival_delay picks inside the closed interval from the stored seed rather than rolling, so a reload cannot change when the files land; the three mixer constants are declared arithmetic-not-tunable. Surfaced to the player in preview_search.  
Evidence: `scripts/systems/hr_constants.gd:712-713` · `scripts/systems/hr_search_system.gd:50-57` · `scripts/systems/hr_search_system.gd:402-409`


**`num.search_retainer` — SEARCH_RETAINER (600)**  
**GOVERNED**  
GDD: ch.07 rev 2 §6; ch.08 §1; ch.02 §9  
Charged once through FinanceSystem.apply_one_time_cost(..., 'hire') at commissioning and explicitly not refunded on cancel (:163-170) or dismiss (:173-179) — the non-refund rule has no GDD line but is the only thing making the search a decision rather than a free look.  
Evidence: `scripts/systems/hr_constants.gd:710` · `scripts/systems/hr_search_system.gd:159`


**`num.secondary_area_mult` — SECONDARY_AREA_MULT (0.7)**  
**GOVERNED**  
GDD: ch.07 rev 2 §5 (value [WORKING] per §5 and §11)  
NAME COLLISION worth recording: area_fatigue_mult (:217-225) never reads ROLE_AREAS.secondary. It returns 1.0 for the founder and for the role's key area and 0.7 for EVERYTHING ELSE — so a developer working Test (their actual ikincil alan) is charged exactly the same as a developer working Satış, an area §5 does not price at all. The constant's name and ROLE_AREAS both promise a three-tier model; the function is binary. Feeds ProductSystem._phase_area_sum, _build_area_sum, HRSystem.area_sum_for and SalesRepSystem._diminished_sum.  
Evidence: `scripts/systems/hr_constants.gd:147` · `scripts/systems/hr_constants.gd:217-225` · `scripts/systems/hr_system.gd:244`


**`num.seed_expertise` — SEED_EXPERTISE_PIVOT (5.0) / SLOPE (0.12) / MULT_MIN (0.5) / MULT_MAX (1.6)**  
**GOVERNED**  
GDD: ch.07 rev 2 §2; ch.03 §6  
Boundary row. Fed by _team_area_avg(AREA_ENGINEERING, lead), i.e. the engineering team's weighted average, at the at-commit bug seed. Magnitudes have no line; the home is legitimate under hr_constants.gd:228-242's explicit split rule (a formula's coefficients live beside its arithmetic).  
Evidence: `scripts/systems/product_system.gd:127-130` · `scripts/systems/product_system.gd:973` · `scripts/systems/hr_constants.gd:239`


**`num.ship_glow` — SHIP_GLOW_MORALE (6)**  
**GOVERNED**  
GDD: ch.07 rev 2 §7  
'sürüm çıktı' verbatim. Fires when days_since_last_ship() == 0, read off the mvp_version_history flag ProductSystem appends to. Ranked first of the three positive beats, ahead of a signing and a calm stretch. Note the mirror half of §7's clause is missing: 'hesap kaybedildi' and 'kesinti' have no morale constant and no beat.  
Evidence: `scripts/systems/hr_constants.gd:1079` · `scripts/systems/hr_morale_system.gd:187-199` · `scripts/systems/hr_event_factory.gd:86-90`


**`num.star_ruler` — STAR_MAX (5) / POINTS_PER_STAR (2)**  
**GOVERNED**  
GDD: ch.02 §3; ch.07 rev 2 §3  
stars_for(points) = clamp(points/2, 0, 5). Half-star resolution over 0-10 means 1 point = half a star and 2 points = one star, exactly POINTS_PER_STAR. One home, so ledger, matrix, founder card and training modal cannot disagree.  
Evidence: `scripts/systems/hr_constants.gd:56-59` · `scripts/systems/hr_constants.gd:182-185` · `scripts/ui/components/star_rating.gd:26`


**`num.tester_coefs` — TESTER_FIND / TEMPO / SPRINT coefficients**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 and §4; ch.03 §7  
Boundary row, and correctly modelled: all three read HRSystem.area_sum_for(AREA_QA), i.e. ASSIGNMENT to Test rather than the tester ROLE, which is exactly §4's unit. The constant names still say PACE and EXPERTISE, axes §2 deleted.  
*Chapter conflict:* ch.02 §2's six skills contain no QA or Test axis at all (Geliştirme · Tasarım · Satış · Müşteri Başarısı · Pazarlama · Operasyon), so the entire Test area — and every coefficient reading it — exists only under ch.07 rev 2 §2.  
Evidence: `scripts/systems/product_system.gd:139-148` · `scripts/systems/product_system.gd:604-616` · `scripts/systems/product_system.gd:1065`


**`num.training_days` — TRAINING_DAYS (14)**  
**GOVERNED**  
GDD: ch.07 rev 2 §8  
Sourced verbatim in code (was 5). DUPLICATE with teeth: TrainingModal prints the duration from the fixed copy key HR_TRAINING_DURATION_WEEKS (:147), whose CSV value is the literal 'iki hafta' / 'two weeks' (strings.csv:356) with no computed fallback — changing TRAINING_DAYS silently makes the modal lie, unlike the overtime block labels, which do fall back to a computed day count.  
*Chapter conflict:* ch.02 §7 legislates a different duration: 'Secondary: training course = cash + person unavailable [WORKING 3 weeks] → +1 in one skill; diminishing on repeat.' Three weeks vs ch.07 rev 2's two. The code follows ch.07.  
Evidence: `scripts/systems/hr_constants.gd:813` · `scripts/autoload/character_registry.gd:172` · `scripts/modals/training_modal.gd:147` · `localization/strings.csv:356`


**`num.training_fee_curve` — TRAINING_FEE (500) / PER_POINT (220) / REPEAT_SURCHARGE (0.35) / LEADERSHIP_MULT (1.35)**  
**GOVERNED**  
GDD: ch.07 rev 2 §8, with §11 naming the tiers open; ch.02 §7; ch.08 §1  
One home: round((500 + 220·current) × (1 + 0.35·repeats) × (1.35 if leadership)). The design grammar recorded at :822-824 resolves §8's ambiguity by paying diminishing returns in the PRICE, always +1 point — a defensible reading of both chapters. TRAINING_LEADERSHIP_MULT is the one sub-item with no GDD line: it cites the approved training-table mockup, not a chapter. Charged through apply_one_time_cost(fee, 'training') and only then does training start.  
Evidence: `scripts/systems/hr_constants.gd:814` · `scripts/systems/hr_constants.gd:819-837` · `scripts/systems/hr_system.gd:294-303`


**`num.trait_bag_packed` — TRAIT bag_packed (GÖZÜ YÜKSEKTE) — resign_chance_mult 1.6, output_mult 1.15**  
**GOVERNED**  
GDD: ch.02 §8  
A probability and a rate modifier. The output arm is the one that brushes §8's 'No trait duplicates a skill's job', since raw output is what skill points buy — but it is expressed as a multiplier rather than a hidden point, which §8's second clause is what forbids.  
Evidence: `scripts/systems/hr_constants.gd:523-527` · `scripts/systems/product_system.gd:535`


**`num.trait_cant_say_no` — TRAIT cant_say_no (HAYIR DİYEMEZ) — promise_chance_mult 1.6, satisfaction_bonus 5**  
**GOVERNED**  
GDD: ch.02 §8; ch.04 §3  
A probability modifier on the promise card's frequency plus a flat satisfaction add. STALE COMMENT tested and found wrong: the table's own reader note at hr_constants.gd:480 names CustomerRepSystem; the actual readers are B2BEventFactory (:194) and B2BSalesSystem (:86).  
Evidence: `scripts/systems/hr_constants.gd:518-522` · `scripts/systems/b2b_sales_system.gd:86` · `scripts/systems/hr_constants.gd:480`


**`num.trait_double_checker` — TRAIT double_checker (TİTİZ) — bug_rate_mult 0.5, speed_mult 0.85**  
**GOVERNED**  
GDD: ch.02 §8; ch.07 rev 2 §2  
Two rate modifiers, permitted by §8, but sitting directly on Yazılım's two stated levers — the closest any shipped trait comes to §8's no-duplication clause. Unstated compounding: _accrue_bugs_hourly multiplies once PER CARRIER (product_system.gd:981-982), so two TİTİZ engineers give 0.25× bugs, a swing no skill spread can match and no chapter authorises.  
Evidence: `scripts/systems/hr_constants.gd:513-517` · `scripts/systems/product_system.gd:981-982` · `scripts/systems/product_system.gd:534`


**`num.trait_last_one_out` — TRAIT last_one_out (İŞKOLİK) — overtime_morale_mult 0.5**  
**GOVERNED**  
GDD: ch.02 §8; ch.07 rev 2 §7  
A morale modifier narrowed to the one input §7 names first. Applied inside _charge_day (:130-131) and NOT inside apply_delta, so the team-decay and climate multipliers are not double-counted — deliberately narrower than the retired pressure_proof, which hit every morale drop.  
Evidence: `scripts/systems/hr_constants.gd:502-506` · `scripts/systems/hr_overtime_system.gd:126-132`


**`num.trait_loyal` — TRAIT loyal (SADIK) — resign_chance_mult 0.6**  
**GOVERNED**  
GDD: ch.02 §8  
A probability modifier, exactly one of §8's four permitted axes. Composed in resign_chance via trait_mult and consumed by _maybe_resign. Magnitude has no line.  
Evidence: `scripts/systems/hr_constants.gd:494-497` · `scripts/systems/hr_constants.gd:960-964`


**`num.trait_mood_buster` — TRAIT mood_buster (TAT KAÇIRAN) — dept_morale_decay_mult 1.25**  
**GOVERNED**  
GDD: ch.02 §8; ch.07 rev 2 §2  
A morale modifier, and the clearest instance of §2's Uyum-into-traits migration. _team_decay_mult multiplies per same-department carrier, excluding self and anyone on leave (:160-173), into scaled_delta's negative branch. The table itself records the unbuilt half: 'ŞİKAYETİN KENDİSİ (olay kartı) BAĞLANMADI: içerik henüz yazılmadı' (:531).  
Evidence: `scripts/systems/hr_constants.gd:528-532` · `scripts/systems/hr_morale_system.gd:160-173`


**`num.trait_picks_it_up_fast` — TRAIT picks_it_up_fast (ÇABUK KAPAR) — experience_mult 1.5**  
**GOVERNED**  
GDD: ch.02 §8  
A rate modifier on the carrier's OWN learning, which keeps it distinct from ch.07 §2's Liderlik (the lead's effect on the team) and so clear of §8's no-duplication clause. Also the fallback trait EventManager gives a trait-less event hire (:631) and the deterministic fallback of the save migration (:926-928).  
Evidence: `scripts/systems/hr_constants.gd:498-501` · `scripts/systems/hr_system.gd:105`


---

### Appendix E — Boundaries, absent seams, name collisions

105 entries, ungoverned first.


**`xing.finance.overtime_pull` — Finans ← Ekip · overtime accrual pull**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — it is a recurring, unbudgeted cash drain in the phase where runway is the whole game.  
burn_breakdown['overtime'] = HROvertimeSystem.pay_accrued_today(), pulled two slots after HR stamps it; self-verifying via _pay_stamped_day. ch.08 §1's burn is 'maaşlar + araçlar + servis maliyeti + marketing plus one-off costs' and ch.07 §10's Finance link is 'maaşlar, retainer, eğitim, zamlar' — overtime pay appears in neither, yet it is a first-class BURN_ID. The rate is phantom-cited (hr_constants.gd:1028, 'design doc §7b').  
*Costs the player:* OVERTIME_PAY_PCT := 0.40 — 40% of each participant's daily salary for every day of a 3/7/14-day block, charged into the burn ring under its own line.  
*If removed:* The overtime block becomes free money-wise; only morale would price it. FinanceSystem.daily_tick loses one of five BURN_IDS and the Finance burn ring loses a line the player can currently read. HROvertimeSystem's three deliberately-unsaved statics (_pay_today, _pay_stamped_day, _pay_carry) become pointless.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/finance_system.gd:139-143` · `scripts/systems/hr_overtime_system.gd:308-313` · `scripts/systems/hr_constants.gd:1040`


**`xing.product.overtime_multipliers` — Ürün ← Ekip · overtime speed and bug multipliers**  
**UNGOVERNED · PHANTOM CITATION** · HIGH — it is the game's only 'spend morale and money for speed' lever, and its entire payoff is undesigned.  
ProductSystem reads HROvertimeSystem.speed_multiplier(DEPT_PRODUCT_DEV) every build hour and bug_multiplier() in bug accrual. Named seams both times. NO chapter states that overtime raises build speed or bug rate: ch.07 §7 names 'fazla mesai' only as a morale input, ch.02 §6 only as an energy drain (and energy does not exist). The constants live under a phantom citation — hr_constants.gd:1028 'Üç blok … (design doc §7b)', hr_overtime_system.gd:4 'Ek mesai (HR design doc §7b)'.  
*Costs the player:* OVERTIME_SPEED_BONUS_EARLY 0.30 / LATE 0.15 bought with OVERTIME_BUG_MULT 1.25 on product_dev bug rate, OVERTIME_PAY_PCT 0.40 of daily salary per participant per day, and the OVERTIME_MORALE_TIERS drop; blocks are 3/7/14 days.  
*If removed:* The two multipliers are the ONLY upside of an overtime block. Delete them and the player pays cash, morale and a valve event for literally nothing — the feature becomes a pure penalty. Readers: product_system.gd:718 (hourly speed) and :977 (bug accrual); nothing else consumes them.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:718` · `scripts/systems/product_system.gd:977` · `scripts/systems/hr_constants.gd:1028-1042` · `scripts/systems/hr_overtime_system.gd:4`


**`absent.character_target_selector` — ABSENT · _resolve_character_target for event modifiers**  
**UNGOVERNED** · HIGH — it blocks two of ch.11 §1's nine arcs (Y3 team life, Y4 hiring) and ch.11 §2's '4–5 on the team side'.  
The customer side has _resolve_customer_target with 'primary_b2b'/'primary_b2c' selectors and a documented fallback; the person side has nothing — morale and hr_* modifiers accept a literal character_id only. No chapter names a selector mechanism (ch.11 §10 asks only whether repeated customer events use named slots).  
*Costs the player:* Nothing today — no authored node reaches a real person, so no cost is ever charged.  
*If removed:* Nothing (it does not exist). Its absence is what makes the one authored per-person node inert: an author literally cannot write 'the most burnt-out employee', 'the newest hire', 'a random developer' or 'the lead of the engineering area'. Every HR event written before a selector lands must be rewritten.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/event_manager.gd:817-840` · `scripts/autoload/event_manager.gd:571-576` · `data/events/reactive/ev_debug_001_engineer_workload.json`


**`absent.hr_cost_seam` — ABSENT · an HR cost category / a 'what did people cost this month' seam**  
**UNGOVERNED** · MEDIUM — the player can read that $2,000 went to 'İşe alım' today but never what people cost this month.  
burn_breakdown carries salaries and overtime; severance, training, retainer and commission exist only as one_time_today labels and transaction rows. ch.08 §1 and §4 legislate maaşlar and tek seferlikler as SEPARATE lines and never ask for an HR total, so no chapter is violated — but ch.07 §10's Finance link ('maaşlar, retainer, eğitim, zamlar') has no single reader. BOUNDARY NOTE (Finans, not audited): MonthSummarySystem's payload carries one flat `expense` and no tek seferlikler breakdown at all, so ch.08 §4's expense breakdown is unbuilt on the far side.  
*Costs the player:* Nothing extra — the money is already charged through apply_one_time_cost; only the attribution is missing.  
*If removed:* Nothing (it does not exist). Its absence means the Finance burn ring never attributes hiring, firing or training to people, and no screen totals what the team cost this month across the five channels. When a recurring HR cost lands (benefits, per-head office) it needs a sixth BURN_ID plus a second FinanceSystem pull, because the write-through law forbids HR pushing a burn category.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/finance_system.gd:33-46` · `scripts/systems/finance_system.gd:63-73` · `scripts/systems/month_summary_system.gd:53-59`


**`absent.removal_listener` — ABSENT · any non-UI listener on character_removed**  
**UNGOVERNED** · MEDIUM — it is the structural cause of both stale-id hazards in the report.  
EventBus.character_removed is consumed by exactly five files, all UI. No chapter legislates signal wiring; the CONSEQUENCE is legislated (ch.07 §9's hand-off question) and is recorded as DIVERGENT under xing.sales.stale_rep_heals_late and xing.product.lead_engineer_id.  
*Costs the player:* Nothing directly.  
*If removed:* Nothing (it does not exist). Its absence is why two modules hold Ekip ids that go stale: FeatureBuild.lead_engineer_id is never cleared and Customer.assigned_to survives until the next daily reconcile. The mitigation in place is CharacterRegistry.remove hardcoding the two cleanups it happens to know about (clear assigned_jobs, call GameState.release_area_leads) — exactly the pattern a listener would replace. A third module holding an id needs another hardcoded line.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/character_registry.gd:530-548` · `scripts/systems/product_system.gd:490-495` · `scripts/autoload/event_bus.gd:61`


**`absent.reserved_fields` — ABSENT readers · loyalty, trust_score, attention_flag**  
**UNGOVERNED** · LOW — inert fields.  
Three Character fields written by the add_character event modifier and read by nothing in production. attention_flag is explicitly superseded by HRSystem.badges_for yet the modifier still writes it, so an author can set a badge value nothing will display. `relationship` is the fourth field in the same 'reserved' block and IS read (event_modal.gd:263-264), so the comment is stale for exactly one of four. Note ch.02 §2 and ch.07 §2 both retired the fit axis ('Uyum … trait'lere devredildi'), which is what these hidden per-person numbers would have been.  
*Costs the player:* Nothing.  
*If removed:* Nothing. Zero production readers each; only an add_character modifier can set them and no authored node uses add_character. Pure debris, and it is debris that invites an author to set a value with no effect.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:89-96` · `scripts/autoload/event_manager.gd:616-632` · `scripts/systems/hr_system.gd:351-355`


**`absent.reverse_index` — ABSENT · a person→accounts reverse index**  
**UNGOVERNED** · LOW — performance only, at demo-scale account counts.  
CustomerRepSystem.roster_size(rep_id) scans the whole B2B book per rep, and _delegate_excess calls it once per rep inside a loop. Ekip owns the person but stores no back-pointer, so the only source of truth is a linear scan of a Satış registry. No chapter legislates data structures.  
*Costs the player:* Nothing.  
*If removed:* Nothing (it does not exist). Its absence costs an O(reps × accounts) scan on every hr_tab structure-key computation, i.e. on every repaint of the Ekip page (hr_tab.gd:222-223), plus the same inside the daily delegation loop. Correctness is unaffected.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/customer_rep_system.gd:179-186` · `scripts/systems/customer_rep_system.gd:160-166` · `scripts/tabs/hr_tab.gd:222-223`


**`absent.salary_signal` — ABSENT · employee_salary_changed**  
**UNGOVERNED** · LOW — a one-day lag on a burn line, invisible in practice.  
CharacterRegistry.set_salary emits nothing and says so: the signal 'belongs here as EventBus.employee_salary_changed(id, value)' but is 'deliberately not declared yet rather than shipped with no listener'. No chapter legislates signals.  
*Costs the player:* Nothing.  
*If removed:* Nothing (it does not exist). Finance works only because it PULLS payroll every daily tick, so a raise reaches the burn line within one day; hr_tab repaints only because _compute_structure_key happens to include emp.monthly_salary. A ch.07 §9 raise-demand event that must repaint immediately would need it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/character_registry.gd:560-572` · `scripts/systems/finance_system.gd:136-138` · `scripts/tabs/hr_tab.gd:224`


**`absent.skill_getter` — ABSENT · a named 'this person's number in this area' getter**  
**UNGOVERNED** · LOW in play — zero effect on a running game; the cost is entirely maintenance and it has already been paid once.  
There is no HRSystem.area_value(c,key). Twelve far-module sites index c.role_stats themselves across product_system, sales_rep_system, customer_rep_system, b2b_sales_system and sales_tab. No chapter legislates accessors.  
*Costs the player:* Nothing.  
*If removed:* Nothing (it does not exist) — but nothing is protected either. The 2026-08-21 area migration already billed the cost twice: role_stats.get(key,0) returns a silent 0 for a renamed key, so _validate_shape had to grow a RETIRED_SKILL_KEYS tripwire AND SaveManager a 100-line migration, precisely because far modules read raw keys. The next skill-model change repeats both and touches 12 files instead of one.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:525` · `scripts/autoload/character_registry.gd:466-479` · `scripts/autoload/save_manager.gd:669-772`


**`absent.status_signal` — ABSENT · employee_status_changed**  
**UNGOVERNED** · LOW today — a latent cost that only bills when the HR event surface arrives.  
CharacterRegistry.set_status writes and validates but emits no signal, though its own comment lists five systems that read `status`. No chapter legislates signals.  
*Costs the player:* Nothing.  
*If removed:* Nothing (it does not exist). Nothing breaks TODAY because leave transitions happen only inside the slot-3 tick and hr_day_processed fires afterwards. It breaks the moment an event can send someone on leave mid-day — the design intent HRMoraleSystem.send_on_leave's is_manual branch is being kept for (hr_actions.gd:126-128): B2B accounts would keep eroding at the un-dampened rate and every screen would lie until the next daily tick.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/character_registry.gd:575-587` · `scripts/systems/customer_rep_system.gd:106-113` · `scripts/systems/hr_actions.gd:115-128`


**`collision.assigned_to` — NAME COLLISION · assigned_to means two different things**  
**UNGOVERNED** · LOW — no play effect; a comprehension trap for the next reader.  
Customer.assigned_to is a FIELD holding one character id; HRSystem.assigned_to(area_id) is a FUNCTION returning every Character on an area. Both appear inside customer_rep_system.gd — the function at :48, the field at :124,:126,:149,:183 — so one file reads the name as both 'who owns this account' and 'who works this area' within 130 lines. No chapter legislates naming.  
*Costs the player:* Nothing.  
*If removed:* Nothing — it is a readability hazard, not a mechanism. Both symbols are individually load-bearing; only the shared name is debris. A reader scanning for the assignment model finds the Satış field first, which is how a prior audit mis-modelled the module.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/customer.gd:53` · `scripts/systems/hr_system.gd:129` · `scripts/systems/customer_rep_system.gd:48` · `scripts/systems/customer_rep_system.gd:124-126`


**`collision.cost_labels` — NAME COLLISION · two homes for one-time charge labels**  
**UNGOVERNED** · LOW — one confirm-card line; the real cost is a comment that lies about which home wins.  
HRConstants.cost_label_hire/_severance/_training exist AND FinanceSystem.ONE_TIME_LABELS maps the same three ids to the same three CSV keys. The actual apply_one_time_cost calls pass raw ids, so cost_label_hire() and cost_label_training() have ZERO readers and cost_label_severance() has exactly one (the fire preview card). hr_search_system.gd:17 and hr_actions.gd:24-25 CITE the HRConstants functions as the contract while the code beneath passes the raw id.  
*Costs the player:* Nothing.  
*If removed:* Deleting cost_label_hire() and cost_label_training() changes nothing. Deleting cost_label_severance() blanks the severance line on the İŞTEN ÇIKAR confirm card. Two-thirds debris, one-third load-bearing — and the two headers that cite them are false documentation of the live contract.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:718-731` · `scripts/systems/finance_system.gd:63-73` · `scripts/systems/hr_actions.gd:22-25`


**`collision.equity_pct` — NAME COLLISION · equity_pct is a percent for the founder and a fraction for everyone else**  
**UNGOVERNED** · LOW today — dormant, but it silently destroys the Kişisel and Finans cap tables the first time an event author uses the obvious units.  
game_state.gd:951 writes f.equity_pct = 100.0 while every reader treats the value as a 0..1 fraction: get_founder_equity returns clamp(1.0 − sum(emp.equity_pct),0,1) and both cap tables multiply by 100.0 (finance_ozet_view.gd:629 states the contract, '0..1 kesir'). No chapter defines an employee equity field at all, so nothing governs its units.  
*Costs the player:* Nothing today — the founder's 100.0 is never read and hires are 0.0.  
*If removed:* Deleting the employee side changes nothing visible (see xing.finance.captable). The hazard is additive, not subtractive: the day an add_character event ships {'equity_pct': 5} meaning five percent, get_founder_equity clamps the founder to 0 and BOTH cap tables collapse to zero founder ownership. The field name says pct, the readers say fraction, the one writer that fills it says pct.  
*Verification:* :631 ("kurucu sözleşmesiyle aynı 0..1 kesir"); hires are hard-coded 0.0 at hr_search_system.gd:205 and character.gd:44. PRECISION on the hazard's timing: the additive danger the row describes requires an add_character event to exist, and none does today (whole-repo grep) — so the trap is armed but no author can currently spring it. That makes the row correctly labelled 'dormant' and arguably worth fixing before the first such event is written, which is exactly what it says.  
Evidence: `scripts/autoload/game_state.gd:951` · `scripts/autoload/game_state.gd:571-575` · `scripts/tabs/finance/finance_ozet_view.gd:626-633` · `scripts/autoload/event_manager.gd:616`


**`collision.leadership_not_an_area` — NAME COLLISION · leadership is in EMPLOYEE_SKILL_KEYS but not in AREAS**  
**UNGOVERNED** · MEDIUM — paid training is the sole route to the one number that multiplies the entire team.  
is_trainable_key accepts 'leadership'; add_area_experience refuses it because it tests HRConstants.AREAS.has(area_key). ch.07 §8 says 'Oyuncu hangi alanın yükseleceğini seçer' and Liderlik is explicitly not one of the six alanlar (ch.07 §2 adds it 'Ek olarak'), so no chapter says how Liderlik grows at all.  
*Costs the player:* TRAINING_FEE 500 base + TRAINING_FEE_PER_POINT 220 × current points, ×TRAINING_LEADERSHIP_MULT 1.35, ×(1+0.35 per repeat) — plus TRAINING_DAYS 14 of a person drawing full salary and producing nothing.  
*If removed:* If Liderlik left is_trainable_key it would have NO growth channel: it is not assignable, so learn-by-doing can never touch it. Every lead's coordination curve, the morale climate and the experience-gain bonus would be frozen at hire value for the whole run. Load-bearing. hr_ledger's experience bar reads the first assigned area, so Liderlik progress is invisible either way.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:840-851` · `scripts/autoload/character_registry.gd:103-104` · `scripts/systems/hr_constants.gd:813-826`


**`stale.attention_people_count` — STALE · attention_people_count's stated consumer does not exist**  
**UNGOVERNED** · LOW — the badge works; only the rationale is dead.  
Its docstring says it is 'the Ekip header's N dikkat gerektiriyor', split from attention_count so the page would not double-count candidate files. hr_tab's header (_rebuild_header, :285-297) prints count, average morale and payroll — no attention number. The only caller is attention_count itself.  
*Costs the player:* Nothing.  
*If removed:* attention_count() calls it at hr_system.gd:361, so deleting it breaks the left-rail Ekip badge. Load-bearing through exactly one caller — but its stated reason for existing (a second, header-facing count) is gone, so the split it justifies is now arbitrary.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:374-384` · `scripts/tabs/hr_tab.gd:285-297`


**`stale.comments` — STALE COMMENTS · four load-bearing comments contradict the code**  
**UNGOVERNED** · LOW — no play effect; high cost to anyone reading the module.  
(1) character.gd:89-92 lists `relationship` as 'declared, not used' — event_modal.gd:263-264 reads it. (2) character_registry.gd:534-535 says remove() 'Reads 0 today — no fire/quit flow calls remove() with an employee yet' — HRActions.fire (:201) and HRMoraleSystem.confirm_departure (:404) both do, and game_state.gd:655 repeats the claim about run_departures. (3) time_manager.gd:311-312 says HR 'applies baseline morale drift' — the drift was DELETED and hr_system.gd:15-21 says so at length. (4) creation_flow.gd:686-687 says the coordination multiplier comes from the lead's UYUM — UYUM was retired and product_system.gd:504 reads SKILL_LEADERSHIP.  
*Costs the player:* Nothing.  
*If removed:* Nothing mechanically. Their cost is comprehension: two of the four assert that a mechanism has no readers when it does, which is exactly the failure mode the brief's M1 rule exists to prevent and the reason the prior audit was wrong.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:89-92` · `scripts/autoload/character_registry.gd:533-535` · `scripts/autoload/time_manager.gd:310-312` · `scripts/tabs/product/creation_flow.gd:686-687`


**`stale.dead_helpers` — STALE · three dead helpers left by retired features**  
**UNGOVERNED** · LOW — no play effect.  
HRActions._current_year survived the TATİLE GÖNDER removal; HRMoraleSystem.days_since_last_signing was superseded by _big_signing_today, which tick_positive_events actually calls; HRConstants.trait_has is referenced only inside a product_system comment explaining why its founder branch was dead code. None has a production caller.  
*Costs the player:* Nothing.  
*If removed:* Nothing at all — three functions with zero production callers. Unambiguous debris. Note trait_has is the accessor that WOULD have exposed the founder-catalog collision if anything had called it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_actions.gd:254-255` · `scripts/systems/hr_morale_system.gd:317-325` · `scripts/systems/hr_constants.gd:624-629`


**`stale.job_leads_migration` — STALE/BROKEN · the v4→v5 lead-seat migration is a no-op on a real save**  
**UNGOVERNED** · LOW today — it becomes a data-loss bug the day area_leads gains a writer.  
_migrate_assignments_to_areas reads state.get('job_leads') at the TOP LEVEL and writes state['area_leads'] at the top level, but a real save keeps GameState fields under state['game_state']. So the whole if-block is skipped, state.erase('job_leads') erases nothing, and the seats are dropped. Characters were rescued from exactly this bug (save_manager.gd:614-620 confesses 'v3'ten beri KARAKTER GÖÇLERİNİN HEPSİ sessiz no-op'tu'); the lead table never got the same treatment. The smoke fixture at endgame_smoke.gd:7511 builds a FLAT dict, so the test exercises the fallback path and passes.  
*Costs the player:* Nothing — the seats it would carry have no writer to fill them.  
*If removed:* Nothing. It is already inert on every real save, and area_leads has no production writer, so the value it fails to migrate is always empty. Pure debris that reads as load-bearing — and a green smoke case that proves the wrong path.  
*Verification:* Dead on BOTH ends, not just the read — the row understates it. Read end: `var leads: Dictionary = state.get("job_leads", {})` (save_manager.gd:798) goes to the TOP level, while SaveManager.save_to_slot writes GameState fields under state["game_state"] (:253, `"game_state": SaveCodec.capture_game_state()`), so the if-block at :799 never enters and `state.erase("job_leads")` at :811 erases nothing. Write end: even if it entered, `state["area_leads"] = rebuilt_leads` (:810) writes at the top level, while the restore path applies only state["game_state"] through SaveCodec.apply_game_state (game_state.gd:852, save_codec.gd:298-310) — so the rebuilt seats could never reach GameState even in the …  
Evidence: `scripts/autoload/save_manager.gd:796-812` · `scripts/autoload/save_manager.gd:611-627` · `scripts/debug/endgame_smoke.gd:7511`


**`xing.events.add_character` — Event engine → Ekip · add_character writes 12 Character fields directly**  
**UNGOVERNED** · MEDIUM — inert today, but it is the one path that could put a free employee (or a cap-table-breaking equity value) into a run without a played cost.  
The modifier constructs a Character inside EventManager — 13 direct field writes — then calls CharacterRegistry.add. It defaults role to ROLE_DEVELOPER, role_stats to default_employee_skills() and traits to ['picks_it_up_fast'], and sets no assigned_jobs, no hire_day, no leave_month, no area_experience for a founder-category payload. No chapter describes an event granting staff; ch.07 §6 makes Atlas the sealed hiring flow ('Mühürlü akış, dokunulmaz'), which this bypasses entirely.  
*Costs the player:* Nothing — no retainer, no commission, no cash. The stamped monthly_salary starts drawing from the next slot-5 payroll pull, so the only cost is one the event author sets.  
*If removed:* Nothing today: a repo-wide grep of data/events/ finds ZERO add_character modifiers. It is a loaded, unused door — and it is also the only writer of equity_pct on an employee, which is what makes collision.equity_pct dangerous rather than dormant.  
*Verification:* CORRECTION on the shape claim, hazard intact. "sets no assigned_jobs, no hire_day, no leave_month, no area_experience" is true of the MODIFIER but not of the outcome. CharacterRegistry.add (:432-459) stamps hire_day, seeds assigned_jobs from HRConstants.default_area_for_role, zero-fills area_experience across AREAS and assigns leave_month for any `category == "employee"` payload — and its own comment at :435-437 says the stamps live there "so an event-spawned hire (add_character modifier) gets them too". Only a non-employee payload skips them. So the record it produces is well formed, not half built; the hazard is purely that it is FREE (no retainer, no commission, no played cost, bypassing …  
Evidence: `scripts/autoload/event_manager.gd:596-633` · `scripts/autoload/character_registry.gd:426-463`


**`xing.finance.captable` — Finans UI ← Ekip · cap table employee slice**  
**UNGOVERNED** · LOW — an always-empty slice on two screens.  
finance_ozet_view sums emp.equity_pct over get_employees() and repaints on character_added/character_removed; GameState.get_founder_equity() does the same sum. ch.09 §5/§8 govern the cap table and dilution, but NO chapter grants an employee equity — ch.07 §6's compensation is 'Maaş bandı = rol × seviye', salary only. Hires are always created with 0.0 (hr_search_system.gd:205), so the slice is structurally empty.  
*Costs the player:* Nothing — always zero today.  
*If removed:* Both cap tables (Finans and Kişisel) render identically, since the employee sum is always 0; get_founder_equity() would stop subtracting an always-zero term. Pure debris today — with the caveat that it is the field an add_character event can fill, which is what turns collision.equity_pct from dormant into live.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/finance/finance_ozet_view.gd:626-633` · `scripts/autoload/game_state.gd:571-575` · `scripts/systems/hr_search_system.gd:205`


**`xing.finance.hr_reads_burn_static` — Ekip ← Finans · preview_hire reads a Finance STATIC directly**  
**UNGOVERNED** · LOW — a projection line on a card the GDD specified without it.  
HRSearchSystem.preview_hire reads FinanceSystem.burn_breakdown['salaries'] off the static var rather than through the documented readonly-snapshot seam get_burn_breakdown(). It also calls FinanceSystem.daily_salary_for(), which IS the seam exposed for this preview. ch.07 §6 lists the candidate card's contents — 'rol uyum yıldızı + anahtar alan + varsa ikincil alan + 1–2 trait' — and a burn projection is not among them.  
*Costs the player:* Nothing — a preview read.  
*If removed:* The candidate card's post-hire burn projection loses its base and could report only the delta. No engine state changes; nothing else reads it. Debris-adjacent, and it is one of two places in Ekip that reach past a Finance seam.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_search_system.gd:344-345` · `scripts/systems/finance_system.gd:212-217` · `scripts/systems/finance_system.gd:238-240`


**`xing.funding.angel_nudge` — Funding ↔ Ekip · the hire nudge crosses both ways**  
**UNGOVERNED** · LOW — a one-time pointer, easily missed and costing nothing.  
AngelRoundSystem suppresses its nudge if get_employees() is non-empty (a registry seam); HRSystem.attention_count reaches for AngelRoundSystem.FLAG_ACCEPTED_DAY and calls GameState.get_flag itself — a cross-module constant reference, not a seam. ch.09 §1 states the INTENT ('Frank … keeps the player alive and lets the first hire happen') but no chapter defines a nudge, and ch.12 §4's badge list has no entry for it.  
*Costs the player:* Nothing — a +1 on the Ekip rail badge until the first hire.  
*If removed:* The rail badge drops by one after the angel cheque lands and AngelRoundSystem's suppression check becomes moot. No economic change, no state change. Debris with a teaching purpose.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/angel_round_system.gd:78-89` · `scripts/systems/hr_system.gd:358-371`


**`xing.funding.team_domain` — Funding ← Ekip · VC team-domain questions**  
**UNGOVERNED** · MEDIUM — it silently converts hiring into a funding gate.  
VCPitchSystem._sorgu_team asks count_developers()==0 then get_employees().is_empty(); the 'first_engineer' callback asks count_developers()>=1. Named seams only, using the leave-INCLUSIVE lens deliberately. ch.09 §4 ENUMERATES what speaks in the meeting — 'founder Karizma, the last three months' growth, churn, margin, product state, and whether Frank made a warm introduction' — and headcount is not on that list; ch.07 §10's Links table names no Funding edge either.  
*Costs the player:* Founder time and cash indirectly: a run with no developer scores worse in a pitch domain, making a hire a hidden prerequisite for the Series A the GDD never states.  
*If removed:* _sorgu_team loses its question and the 'first_engineer' callback becomes dead; the pitch's domain scoring shifts by one term (far side not audited). Nothing in Ekip changes. It is the cleanest far-module crossing in the codebase and also the least anchored.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/vc_pitch_system.gd:697-707` · `scripts/systems/vc_pitch_system.gd:793`


**`xing.gamestate.flags` — GameState flags · four HR-owned flag families**  
**UNGOVERNED** · MEDIUM — invisible until the once-only latch fails.  
hr_manual_leave_<id>, hr_valve_continued_<id>, needs_engineer and debug_hr_force are written and read straight off GameState.flags. ch.11 §6 governs event flags as arc memory ('Nodes write flags; later nodes read them'), not HR's private latches. Two of the four embed a run-generated character id, so no authored JSON can name them; has_flag tests key PRESENCE and set_flag(key,false) leaves the key, so flag_set on hr_manual_leave_* stays true after the leave ends.  
*Costs the player:* Nothing directly — they are latches, not charges.  
*If removed:* The manual-leave marker is how the module knows which return bonus is owed (MORALE_VACATION_RETURN 20 vs the smaller automatic one), and the valve latch is what keeps the overtime safety-valve event once-only. Delete them and a manual vacation pays the wrong bonus and the valve event can re-fire every block. Load-bearing, but they are the only HR state an event condition could theoretically see, and the id-keyed ones are unreachable from authored JSON.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_morale_system.gd:51` · `scripts/systems/hr_overtime_system.gd:59` · `scripts/autoload/game_state.gd:407-411`


**`xing.gamestate.founder_skill_seam` — GameState · get_founder_skill is the founder skill seam (with a tripwire)**  
**UNGOVERNED** · HIGH — it is the single door to the numbers that decide every roll in the run.  
Reads founder.role_stats[key] and push_errors on any FounderConstants.OLD_SKILLS key. No chapter legislates accessors. Two in-scope readers bypass it and lose the tripwire: ProductSystem._founder_build_area (:791) and personal_tab (:183,:188).  
*Costs the player:* Nothing — a read path.  
*If removed:* Everything founder-driven stops: ProductSystem's ceiling/quality reads (:551,:583), all four SkillCheck entry points (every pitch, term-sheet and prospect roll in the game), and HRMoraleSystem's Liderlik climate (:240). The OLD_SKILLS tripwire — the only guard that a renamed founder key screams instead of loading as 0 — goes with it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:611-621` · `scripts/systems/skill_check.gd:33` · `scripts/systems/product_system.gd:791` · `scripts/tabs/personal_tab.gd:181-190`


**`xing.gamestate.hr_fields` — GameState · four HR system fields live outside the module**  
**UNGOVERNED** · HIGH — these four fields ARE the storage of hiring and overtime, even though the architecture is invisible.  
hr_search, hr_overtime, hr_last_overtime_day and hr_last_positive_event_day are declared on GameState and written by direct field assignment from the owning HR system. No chapter legislates where run state lives; the 'fields not systems' rule (game_state.gd:293-294) buys free save coverage and costs encapsulation.  
*Costs the player:* Nothing — a storage choice, invisible in play.  
*If removed:* Total loss of two player systems: HRSearchSystem holds no statics at all, so the Atlas search state machine has no other home, and HROvertimeSystem's block state is GameState.hr_overtime. Deleting them removes hiring and overtime and their save coverage. Fully load-bearing.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:293-298` · `scripts/systems/hr_search_system.gd:148-156` · `scripts/systems/hr_overtime_system.gd:169-174`


**`xing.main.debug_writes` — main.gd · debug fixtures write Character fields raw**  
**UNGOVERNED** · LOW — no play effect; it does mean some approved screenshots depict impossible states.  
The shot harnesses build employees field-by-field, back-date hire_day, force c.status and c.training_days_left on EVERY character, poke the founder's role_stats['sales'], and set Customer.assigned_to directly — bypassing set_status, begin_training and CustomerRegistry.assign_customer (which would emit customer_assigned). main.gd:1849-1851 puts the MENTOR and the FOUNDER into STATUS_TRAINING, a state no production path can produce. No chapter covers debug harnesses.  
*Costs the player:* Nothing in a real run — reachable only behind --hr-shot / --product-shot flags.  
*If removed:* The screenshot harnesses lose their fixtures and the approved shot baselines cannot be regenerated. No production path changes. Debris in play, load-bearing for the design-verification gate — and the shapes it produces are the shapes the baselines are approved against, including states the engine cannot reach.  
*Verification:* haracterRegistry.get_founder().role_stats["sales"]` directly; :1697 back-dates hire_day after add() has stamped it. ONE CORRECTION IN THE HARNESS'S FAVOUR: it is not uniformly raw — main.gd:1703 goes through HRMoraleSystem.send_on_leave and :1502-1505 through CharacterRegistry.add_area_experience and begin_training, both with in-body notes saying the seam was chosen deliberately. The raw writes are the exception, which makes the r2 fixture's blanket status write the sharper finding.  
Evidence: `scripts/main/main.gd:1685-1708` · `scripts/main/main.gd:1849-1851` · `scripts/main/main.gd:1960`


**`xing.month.team_size` — Month summary ← Ekip · team size**  
**UNGOVERNED** · LOW — a from/to number on a screen the GDD did not ask to carry it.  
MonthSummarySystem._team_size returns 1 + get_employees().size() and stamps it into the ledger as 'employees' and into the close payload as team {from,to}. ch.08 §4 enumerates the monthly close — 'Revenue · expense breakdown … · net · gross margin … · cash and runway · Artıda streak · the month's three notable events' — and team size is not in it. (ch.13 §3 does require headcount, but on the ENDING screen, which is xing.endings.headcount.)  
*Costs the player:* Nothing — a display number.  
*If removed:* One line on the monthly close disappears and the ledger's 'employees' key goes unused. Nothing reads it downstream. Debris-adjacent: it is the only place the run shows headcount month over month, but no system depends on it.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/month_summary_system.gd:109-111` · `scripts/systems/month_summary_system.gd:69` · `scripts/systems/month_summary_system.gd:99`


**`xing.product.founder_areas` — Ürün ← Ekip · founder assignment read three ways**  
**UNGOVERNED** · MEDIUM — the reads are correct; what is missing is a named getter, which is why three copies of one question exist.  
_founder_on_build, _founder_phase_area and _reseat_founder each iterate founder.assigned_jobs directly (:412, :433, :445). HRSystem.assigned_to() would answer the same question but filters status and returns a list rather than answering 'is this one person on area X'. No chapter legislates accessors; the underlying rule (the founder counts only while assigned) is ch.02 §5 + ch.03 §2.  
*Costs the player:* Nothing — read paths.  
*If removed:* _founder_on_build gates whether the founder's areas enter the build at all — it is read by _founder_build_area (:791) and by the phase sums, so removing it decouples the founder from build output entirely and a Bootstrap run with no hires builds at zero speed. _founder_phase_area feeds _reseat_founder. All three are load-bearing.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:412` · `scripts/systems/product_system.gd:433` · `scripts/systems/product_system.gd:445`


**`xing.product.phase_assignees` — Ürün ← Ekip · phase_assignees reaches into assigned_jobs**  
**UNGOVERNED** · MEDIUM — it decides whether a build runs while the team is away.  
phase_assignees() iterates CharacterRegistry.get_all() and tests c.category and c.assigned_jobs.has() itself, deliberately bypassing HRSystem.assigned_to because that seam filters STATUS_ACTIVE and would make 'nobody assigned' and 'everyone away' identical. No chapter legislates accessors, and none states whether an away person keeps their assignment (ch.07 §8 governs only that they cannot work).  
*Costs the player:* Nothing — a read path.  
*If removed:* Two readers, both real: product_system.gd:365 builds the phase crew and :376 answers 'is anybody on this phase at all'. Delete it and the build either credits nobody or credits people on leave and in training. Load-bearing, and it is the module's de facto status-inclusive assignment getter because Ekip offers none.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:344-356` · `scripts/systems/product_system.gd:365` · `scripts/systems/hr_system.gd:129-140`


**`xing.save.area_migration` — Save/load → Ekip · v3→v4 does dict-key surgery on HR's serialized shape**  
**UNGOVERNED** · MEDIUM — affects existing saves only, but silently zeroes an entire team when it fails.  
_migrate_character_areas rewrites role_stats from {expertise,pace,rapport} to six areas + leadership, converts `experience` into per-area area_experience, and back-fills assigned_jobs and training_area — hardcoding HR's mapping rules (expertise→key area, pace→secondary, rapport/2→Liderlik) inside a save file. No chapter covers migration.  
*Costs the player:* Nothing.  
*If removed:* Every pre-2026-08-21 save loads with retired keys; _validate_shape's RETIRED_SKILL_KEYS tripwire push_errors and every area reads a silent 0, collapsing team output to the founder. Load-bearing for old saves only. Its real cost is forward: the next skill-model change needs a second copy of the model's semantics written into save_manager.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/save_manager.gd:669-772` · `scripts/autoload/character_registry.gd:466-479`


**`xing.save.assignment_migration` — Save/load → Ekip · v4→v5 maps retired job ids onto areas**  
**UNGOVERNED** · MEDIUM — old saves only, but it silently empties every desk.  
_migrate_assignments_to_areas rewrites assigned_jobs from the seven retired job ids to area ids, dedupes, and zeroes overload_days when the result is a single area. It carries its own _LEGACY_JOB_AREAS table and resolves multi-area jobs by reading the holder's role_stats — a second home for 'which area does this person work this job from'. No chapter covers migration.  
*Costs the player:* Nothing.  
*If removed:* v4 saves load with job ids that ASSIGNABLE does not contain, so every person reads as idle: no build crew, no sales desk, no CS desk, and a spurious overload flag on anyone who held a multi-area job. Load-bearing for old saves.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/save_manager.gd:774-796` · `scripts/autoload/save_manager.gd:815-830`


**`xing.save.characters` — Save/load ← Ekip · roster capture and raw restore**  
**UNGOVERNED** · HIGH — without it the game has no continuity across sessions.  
SaveCodec captures every Character via res_list_to_json and restores through CharacterRegistry.insert_raw rather than add(), whose header lists the four bugs add() would cause on load: re-stamped hire_day, re-assigned leave_month, inflated run_hires, and a character_added emit into a detached shell. _validate_shape still runs. No GDD chapter covers save/load.  
*Costs the player:* Nothing — persistence.  
*If removed:* No roster survives a load: every employee, their skills, assignments, morale, tenure and salary vanish, and the run reloads as a solo founder. Maximally load-bearing.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/save_codec.gd:361-388` · `scripts/autoload/character_registry.gd:512-527`


**`xing.save.hr_systems` — Save/load ← Ekip · HRSystem is the one door for HR system state**  
**UNGOVERNED** · MEDIUM — a save at the wrong moment cancels a resignation.  
HRSystem.to_dict returns only {'morale': HRMoraleSystem.to_dict()} — the pending-departure latch; everything else rides GameState. HROvertimeSystem's three statics are deliberately excluded with a stated argument, HRSearchSystem holds none, and HRSystem.reset() runs on both initialize_run and load. No chapter covers save/load.  
*Costs the player:* Nothing.  
*If removed:* The pending-departure latch is lost across a save/load, so an employee one confirmation away from resigning silently stays employed — the run's most consequential HR moment can be erased by saving. Load-bearing for exactly one value.  
*Verification:* "PROVABLY empty at every save point today … SaveManager.can_save() refuses while EventManager.has_pending()" — and that is FALSE. can_save (save_manager.gd:110-135) gates on `EventManager._active_event_id != ""` at :130 and its own comment at :120-129 says it deliberately does NOT use has_pending, because that would make the queue serialisation unreachable. A resignation that has been enqueued but not yet SHOWN therefore sits in _pending across a perfectly legal save. So the door is not belt-and-braces: it is load-bearing in reachable play, which makes the row's HIGH-stakes framing an understatement rather than a counterfactual.  
Evidence: `scripts/systems/hr_system.gd:330-346` · `scripts/autoload/save_manager.gd:375` · `scripts/systems/hr_overtime_system.gd:412-420`


**`xing.ui.oda` — ODA ← Ekip · post-it, overtime chip, light state, Atlas paper**  
**UNGOVERNED** · MEDIUM — ODA is the default screen, so these four are the readings most players see most often.  
OdaView reads badges_for over get_employees for the post-it name, HROvertimeSystem.is_active/day_index for the chip AND the night-light state, and HRSearchSystem.has_files_ready/get_files for the desk paper. Named seams plus one direct emp.character_name. ch.12 §6 names only the monitor, the phone and the day→night tint as ODA's hosted objects; none of these four is in any chapter.  
*Costs the player:* Nothing — all four are display.  
*If removed:* The room loses its only people signal. The Atlas desk paper is a primary discovery path for 'your candidate files arrived' (the alternative is the rail badge number); the light state is the only ambient cue that an overtime block is running; the post-it is the only place a distressed employee is named outside the Ekip tab. Nothing economic changes. Repaint hooks are hr_day_processed and morale_changed only, so all four go stale mid-day (see absent.overtime_signal).  
*Verification:* trusted over a handler body. "Repaint hooks are hr_day_processed and morale_changed only, so all four go stale mid-day" is false. oda_view._on_hour_changed (:627-629) fires every in-game hour and calls `_eval_light(false)` AND `_refresh_overtime_chip()`, carrying the comment "mesai sinyali yok — saatlik poll (motor boşluğu)" — naming exactly the engine gap the row assumes is unfilled. _refresh_papers additionally runs on _on_day_advanced (:633) and on six other hooks (:645, :667, :682, :686, :690). Only the post-it depends on hr_day_processed + morale_changed alone, and morale_changed covers every FLIGHT_RISK/BURNING_OUT transition, leaving only the needs_engineer-derived OVERLOADED badge …  
Evidence: `scripts/ui/oda/oda_view.gd:589-590` · `scripts/ui/oda/oda_view.gd:835-845` · `scripts/ui/oda/oda_view.gd:1333-1360` · `scripts/ui/oda/oda_view.gd:1382-1386`


**`absent.assignable_consumers` — ABSENT · consumers for two ch.07 §4 jobs**  
**DIVERGENT** · HIGH — a legal, unmarked player move deletes a paid employee's entire contribution.  
GDD: ch.07 §4; ch.06 §1.4; ch.03 §2  

> ch.07 §4 table: 'Araştırma (özellik kilidi) | Ürün · Tasarım · Yazılım | kilitli özellik açılır' and 'Maliyet/borç işi | Yazılım | servis maliyeti ↓, teknik borç ↓'.

AREA_RESEARCH is in ASSIGNABLE and clickable, but nothing reads it and tick_experience explicitly skips it ('Araştırma bir YETENEK değil') — a person parked there produces nothing AND learns nothing. The Maliyet/borç job has no id anywhere; ch.06 §1.4's 'paid down by assigning someone to it' has no assignment to make.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:138-140` · `scripts/systems/hr_system.gd:110-115` · `scripts/systems/hr_system.gd:177-184`


**`absent.employee_skillcheck` — ABSENT · any employee-side skill check**  
**DIVERGENT** · HIGH — hiring a great Satış Temsilcisi does not improve a single close roll.  
GDD: ch.04 §2  

> 'Lead → opportunity → close. Close probability = Satış skill of whoever sells; deal size by scale × segment.'

SkillCheck.resolve/roll_against/chance_for take a skill NAME and read GameState.get_founder_skill — there is no subject parameter. PitchSystem's close rolls (pitch_system.gd:298, :314) therefore run on the FOUNDER's Satış no matter which rep is on the account. Employee areas only ever feed continuous multipliers, never a discrete pass/fail.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/skill_check.gd:32-36` · `scripts/systems/pitch_system.gd:298` · `scripts/systems/pitch_system.gd:314`


**`absent.founder_energy` — ABSENT · the founder energy/burnout bar**  
**DIVERGENT** · HIGH — the founder is the only actor in Bootstrap and has no fatigue cost at all.  
GDD: ch.02 §6; ch.02 §10; ch.12 §8  

> ch.02 §6: 'One bar. Falls with overtime and long "founder does everything" stretches; rises with rest and delegation. Low energy: temporary skill penalty + triggers events (mistake, bad call, health). Reads in Personal and as a TopBar/ODA badge at thresholds.'

No `energy` field on Character, no system, no UI, no threshold vocabulary. HRMoraleSystem.apply_delta actively refuses non-employees ('founder burnout is out of demo scope'), so the founder has no morale channel either. ch.07 §10 hands Personal back to ch.02, so nothing supersedes the clause.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:28-96` · `scripts/systems/hr_morale_system.gd:211-218` · `scriptsts/tabs/personal_tab.gd:52-108`


**`absent.hr_conditions` — ABSENT · the entire HR condition family**  
**DIVERGENT** · HIGH — it is why ch.11's Y3 'team life' and Y4 'hiring' arcs have no engine to hook to; nothing the team does can arm an event.  
GDD: ch.11 §5; ch.07 §9; ch.11 §1  

> ch.11 §5: 'Events hook to system edges — churn, phase change, incident, raise demand, rival move, version ship, coverage red, promise broken — not to random calendar rolls.' ch.07 §9: 'Zam talebi event'i: bir yılını dolduran ya da seviye atlayan çalışan açar.'

is_condition_met implements 29 keys; none reads morale, headcount, employee skill, status, idle, overload, tenure, training, search or overtime. Two of the eight mandated edges (raise demand, coverage red) have no key. The two triggers ch.07 §9 names are both unreadable: hire_day is read only by hr_ledger's YENİ badge, and there is no level-up edge.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/event_manager.gd:368-457` · `scripts/autoload/character_registry.gd:355-366` · `scripts/systems/hr_constants.gd:863-867`


**`absent.hr_write_modifiers` — ABSENT · every HR write modifier except morale and departure**  
**DIVERGENT** · HIGH — three of ch.07 §9's four named moments (zam talebi, rakip teklifi, the routing card) cannot exist.  
GDD: ch.07 §9  

> 'Karar slider ile karşı teklif; düşük teklif moral düşürür ve kaçma riskini artırır.' … 'Ayrılan kişinin işleri boşalır ve oyuncuya sorulur: "Melisa gitti, müşterilerine kim bakacak?" … Kart oyuncuyu ilgili sayfaya yönlendirir.'

No modifier raises a salary, sends someone on leave, assigns an area, starts training, fires, or changes a skill. HRActions.apply_raise is reachable ONLY from the Ekip card (hr_tab.gd:805), so ch.07 §9's raise slider ships as a page action, not an event. build_resignation ships one acknowledgement choice with a single hr_departure modifier — no successor pick, no account hand-off, no navigation.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/event_manager.gd:557-807` · `scripts/systems/hr_event_factory.gd:29-42` · `scripts/autoload/character_registry.gd:560-572`


**`absent.levelup_signal` — ABSENT · a level-up edge distinguishable from a reset**  
**DIVERGENT** · HIGH — it is one of the two triggers ch.07 §9 requires and neither is readable.  
GDD: ch.07 §9  

> 'Zam talebi event'i: bir yılını dolduran ya da seviye atlayan çalışan açar.'

add_area_experience returns true on a +1 but emits employee_experience_changed(id, 0) — byte-identical to the signal a completed training and a capped area emit. The bool return is discarded by its only caller (hr_system.gd:122). The one moment the GDD names as a raise trigger is unobservable outside CharacterRegistry.  
*Verification:* CORRECTION on one clause, core intact. add_area_experience (character_registry.gd:96-123) returns true on a +1 and emits `employee_experience_changed(id, 0)` (:121); tick_training's completion emits the identical `(id, 0)` (:196-197); the bool return is discarded by its sole caller, hr_system.gd:120-122. But a CAPPED area emits `(id, EXPERIENCE_MAX)` — i.e. `(id, 100)` — at :117-120, not `(id, 0)`. The collision is with training completion only, which is enough to make the level-up edge unobservable outside CharacterRegistry, so the finding stands as written minus the capped-area clause. Also confirmed: no other signal distinguishes it — assignment_changed, morale_changed and …  
Evidence: `scripts/autoload/character_registry.gd:96-123` · `scripts/autoload/character_registry.gd:196-197` · `scripts/systems/hr_system.gd:120-122`


**`absent.ops_readers` — ABSENT · Operasyon never calls the two seams built for it**  
**DIVERGENT** · HIGH — coverage is one of ch.01 §5's Traction pressures and ch.06 §5's 'first bite'; the player is never told they are uncovered.  
GDD: ch.06 §1.3; ch.12 §4; ch.07 §4  

> ch.06 §1.3: 'coverage = active_accounts ÷ covering_heads … Reader: HR "Kapsam" ratio with amber/red; badge when red.' ch.07 §4: 'Hangi işin boş kaldığı bu ekranda görünür (ör. "Destek: kimse yok").'

HRSystem.covering_heads() and HRSystem.unstaffed_areas() have zero callers anywhere outside their own file (verified by repo grep). There is no Kapsam ratio, no amber/red, no coverage-red badge, and no 'Destek: kimse yok' line — the matrix's blank column is left to speak for itself. covering_heads' own docstring concedes the ratio 'BU TURDA HESAPLANMIYOR'.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_system.gd:167-184`


**`absent.overload_morale` — ABSENT · the overload MORALE cost**  
**DIVERGENT** · HIGH — half the price of the multi-area bargain is missing, and the UI tells the player it is being charged.  
GDD: ch.07 §5  

> 'Model: ana alanında çalışmak normal, ikincil alanında çalışmak daha yorucudur. Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider.' Hover: 'verimi düşer ve morali normalden hızlı erir.'

HRConstants.OVERLOAD_MORALE_MULT := 1.6 has ZERO readers. tick_overload counts days and overload_bites gates OVERLOAD_OUTPUT_MULT (0.75) after OVERLOAD_TOLERANCE_DAYS (5) — output only. scaled_delta folds in the team-decay trait and the Liderlik climate and nothing else. hr_assignments.gd:122 and hr_ledger.gd:220 show the player HR_OVERLOAD_HINT, which promises the erosion.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:142-147` · `scripts/systems/hr_morale_system.gd:228-254` · `scripts/tabs/hr/hr_assignments.gd:119-122`


**`absent.trait_getter` — ABSENT · a person-scoped trait effect seam**  
**DIVERGENT** · HIGH — same failure as collision.trait_catalogs, seen from the seam side; six call sites must be retrofitted.  
GDD: ch.07 §12; ch.02 §8  

> ch.07 §12: 'Kurucu trait'leri bugün çalışmıyor (kod kurucu trait'ini çalışan tablosunda arıyor) — dönülecek.'

Six far-module sites call HRConstants.trait_mult(c.traits,'<effect_key>') with the catalog implicit and the effect-key string hardcoded at the call site. No HRSystem.trait_effect(c,key) exists that knows which catalog the person belongs to, which is precisely the mechanism ch.07 §12 describes as broken. The GDD records it as an open item; it is unfixed.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/sales_rep_system.gd:76-79` · `scripts/systems/hr_constants.gd:603-612` · `scripts/systems/founder_constants.gd:63-75`


**`collision.skill_ceiling` — NAME COLLISION · three answers to 'how high can a skill go'**  
**DIVERGENT** · MEDIUM — the founder's opening card is built on a different ruler than the one the game then runs on.  
GDD: ch.02 §2; ch.07 §3  

> ch.02 §2: 'Six role skills, each 0–10 internally.' ch.07 §3: 'Yıldız gösterimi, 5 yıldız yarım-yıldız çözünürlüğünde. Ham 0–10 yalnız derin hover'da.'

Three constants answer one question: HRConstants.AREA_MAX 10 (learn-by-doing), AREA_TRAIN_CAP 8 (paid training, now also the founder's since the training gate opened at character_registry.gd:131-134), FounderConstants.SKILL_CEILING 5. SKILL_CEILING's only reader is SegmentBar.segments, whose only user is the onboarding allocator (origin_traits_step.gd), which distributes POINT_POOL 6 across FIVE skills at cap 3 — a founder can therefore be created with at most 3/10 in any area while ch.07 §2 gives everyone six areas plus Liderlik.  
*Verification:* CORRECTION — the row fell into the M1 trap it was written to catch. "the onboarding allocator … distributes POINT_POOL 6 across FIVE skills" is FALSE. origin_traits_step.gd iterates FounderConstants.SKILLS at :34, :279 and :373, and SKILLS is EIGHT keys — `["product","design","engineering","qa","sales","customer_success","leadership","charisma"]` (founder_constants.gd:36-37). The "5 skills" figure comes only from the stale header comment at origin_traits_step.gd:9; FounderConstants' own comment at :50-51 contradicts it outright ("6 points now spread over EIGHT columns instead of five"). EVERYTHING ELSE HOLDS AND WAS VERIFIED: three ceilings (AREA_MAX 10 at hr_constants.gd:54, AREA_TRAIN_CAP …  
Evidence: `scripts/systems/hr_constants.gd:46-54` · `scripts/systems/founder_constants.gd:53-56` · `scripts/ui/components/segment_bar.gd:16` · `scripts/onboarding/steps/origin_traits_step.gd:9`


**`collision.trait_catalogs` — NAME COLLISION · Character.traits, two catalogs, one field**  
**DIVERGENT** · HIGH — the founder's four positive and four negative traits are decorative in the one place they should bite.  
GDD: ch.02 §1; ch.02 §8; acknowledged in ch.07 §12  

> ch.02 §8: 'Modifiers only (skill, rate, probability, morale); never a hidden skill number.' ch.07 §12: 'Kurucu trait'leri bugün çalışmıyor (kod kurucu trait'ini çalışan tablosunda arıyor) — dönülecek.'

Employees draw from HRConstants.TRAITS (8 ids), the founder from FounderConstants.TRAITS (8 different ids), and both sit in one Array[String]. trait_mult/trait_sum/trait_has return the neutral value for an id they do not know, so every founder trait is silently 1.0/0.0. Live site: sales_rep_system.gd:78-79 runs both multipliers over the founder whenever he is on AREA_SALES.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/hr_constants.gd:492-536` · `scripts/systems/founder_constants.gd:66-75` · `scripts/systems/sales_rep_system.gd:76-79`


**`conflict.02.founder_three_jobs` — ch.02 §5 three founder jobs vs the two-area implementation**  
**DIVERGENT** · HIGH — same mechanism as xing.funding.founder_lock_offsite, recorded here as the chapter-level clause.  
GDD: ch.02 §5; ch.07 §4  

> ch.02 §5: 'The founder is an employee who holds ONE job at a time: building a version, selling, or fundraising (Hunt).'

The one-at-a-time lock is enforced faithfully (assign_area returns 'founder_busy'; _validate_shape push_errors on >1 area), and building and selling are real areas. Fundraising is not — see xing.funding.founder_lock_offsite. Two of three jobs are in the model.  
*Chapter conflict:* ch.02 §5 states it; ch.07 §4 defers ('Kurucu bu ekranda görünmez ama kurucunun mevcut görevi Kişisel'de okunur … chapter 02 §5') and adds nothing, so neither chapter owns the missing third job.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/character_registry.gd:221-223` · `scripts/autoload/character_registry.gd:507-509` · `scripts/systems/hr_constants.gd:139-140`


**`conflict.02.net_worth` — ch.02 §10 net worth line vs the shipped Kişisel page**  
**DIVERGENT** · MEDIUM — a headline v1 Personal readout is permanently blank.  
GDD: ch.02 §10; ch.09 §7; ch.12 §8  

> ch.02 §10: 'Net worth = equity % × last valuation (set at Frank, updated at Series A) — one line + all-time peak.' ch.09 §7: 'Valuation at close is recorded and read by Personal net worth (chapter 02 §10).'

personal_tab renders PER_VALUATION, PER_NET_WORTH and PER_PEAK_VALUE as three literal em dashes. GameState.run_valuation_m is written only at term-sheet signature, at which moment the run ends, and there is no all-time-peak seam. The equity percent above them IS computed. ch.07 §10 hands Personal back to ch.02, so nothing supersedes the clause.  
*Chapter conflict:* Not a conflict — an unbuilt ch.02 clause that ch.07 §10 explicitly defers back to ch.02 and ch.09 §7 reaffirms.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/personal_tab.gd:14-18` · `scripts/tabs/personal_tab.gd:388-395` · `scripts/autoload/game_state.gd:264-268`


**`conflict.02.traits_catalog_size` — ch.02 §1 '~12 positive / 12 negative' vs the shipped catalogs**  
**DIVERGENT** · MEDIUM — trait variance is the main source of run-to-run difference between two files of the same role.  
GDD: ch.02 §1; ch.07 §6  

> ch.02 §1: 'Traits from the existing catalog (~12 positive / 12 negative), shown as icons.' ch.07 §6: 'Aday kartı: rol uyum yıldızı + anahtar alan + varsa ikincil alan + 1–2 trait.'

FounderConstants.TRAITS holds 4 positive + 4 negative, roughly a third of ch.02 §1's promise, and ch.07 supersedes nothing about founder traits. HRConstants.TRAITS holds 8 employee traits and TRAIT_COUNT := 1, overriding ch.07 §6's '1–2' downward with a recorded director decision.  
*Chapter conflict:* ch.02 §1 sets the founder catalog size; ch.07 §6 sets the per-candidate count. Neither number is the shipped one.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/founder_constants.gd:66-75` · `scripts/systems/hr_constants.gd:492-551`


**`conflict.ch02_founder_energy` — ch.02 §6's founder energy bar does not exist**  
**DIVERGENT** · HIGH — ch.01 §5 makes founder time the entire Bootstrap pressure, and the bar is the only governed thing that would make delegation a need rather than a preference  
GDD: ch.02 §6 (still live: ch.02 §10 and ch.12 §8 both require the reader)  

> One bar. Falls with overtime and long "founder does everything" stretches; rises with rest and delegation. Low energy: temporary skill penalty + triggers events (mistake, bad call, health). Not a nag; no pop-up per point. Reads in Personal and as a TopBar/ODA badge at thresholds. [WORKING thresholds]

Nothing of this exists. HRMoraleSystem.apply_delta returns immediately for any category != 'employee' (hr_morale_system.gd:211-218), so the founder has no morale/energy channel at all, and HROvertimeSystem.participants() structurally excludes him (:268-305) so overtime costs him nothing. CORRECTION TO THE INVENTORY'S FRAMING: this is not superseded law. ch.07 rev 2 is merely silent on founder energy, and silence is not repeal — ch.02 §10 still lists 'Energy bar (§6)' as a Kişisel element and ch.12 §8 still lists 'Kişisel → founder card, energy, net worth, events log'. Three approved chapters therefore still require it.  
*Costs the player:* nothing — the founder is inexhaustible; he can hold a build area for 730 days at full output with no cost of any kind  
*If removed:* n/a — unbuilt. Its absence is what makes founder_participates() a pure read with no attached cost and what removes the intended ceiling on 'founder does everything' play  
*Chapter conflict:* ch.02 §6 + §10 + ch.12 §8 legislate a founder energy bar with a low-energy skill penalty and events; ch.07 rev 2 is silent (it does not supersede the clause, it simply does not restate it). Recorded so the line is not retired by silence.  
*Verification:* ts log") all stand, and ch.07 rev 2 §10 line 109 hands Personal back to ch.02 rather than superseding it — so the row's correction to the inventory's framing is right. apply_delta's early return for non-employees is at hr_morale_system.gd:213-218 and says so outright ("founder burnout is out of demo scope"); participants() excludes him structurally at :275-280. CITE FIX: founder salary 0 is game_state.gd:950, not :952 (:952 is `f.morale = 50`, a field nothing reads for the founder — apply_delta refuses him, so that 50 is itself inert). Add: founder_participates (hr_overtime_system.gd:300-305) is the exact seam ch.02 §6's "falls with overtime" would attach to, and it is a pure read with …  
Evidence: `GDD ch.02 §6 lines 48-51; §10 line 65` · `GDD ch.12 §8 line 20` · `scripts/systems/hr_morale_system.gd:211-218 (non-employees return early)` · `scripts/systems/hr_overtime_system.gd:268-305 (founder never a participant)` · `scripts/autoload/game_state.gd:952 (founder salary 0)`


**`conflict.ch07_raise_and_poach_events` — §9's two automatic people-events do not exist**  
**DIVERGENT** · HIGH — two of the module's four governed event beats are missing, and with them the only pressure that makes a good employee expensive over time  
GDD: ch.07 rev 2 §9 (reinforced by ch.12 §4 and ch.10 §3)  

> Zam talebi event'i: bir yılını dolduran ya da seviye atlayan çalışan açar; talep medyanın üstünde olabilir. Karar slider ile karşı teklif; düşük teklif moral düşürür ve kaçma riskini artırır. — Rakip teklifi event'i: bir rakip ya da dışarıdan bir şirket çalışana teklif verir; karşı teklif ya da bırak.

Neither trigger exists. No reader of tenure raises an event (HRConstants.DAYS_PER_YEAR 365 is consumed only by severance_months, hr_constants.gd:1019), and no reader of trainings_done or of a role_stats delta raises one either. The only authored HR events are HREventFactory's three families — resignation, overtime valve, three positive beats (hr_event_factory.gd:24-91) — plus the phantom ev_debug_001. HRActions.apply_raise (hr_actions.gd:98-112) exists as a purely player-initiated action with no automatic demand upstream of it, and RAISE_MIN_PCT/RAISE_MAX_PCT already carry the slider band §9 describes. Three chapters ask for this: ch.12 §4 lists 'raise demand' among the attention badges, and ch.10 §3's rival move deck contains 'Çalışanımıza teklif verdi (HR event, chapter 07 §7)'.  
*Costs the player:* nothing — salaries never rise on their own and no rival ever competes for a person, so a well-paid hire is permanently free of wage pressure  
*If removed:* n/a — absent; the slider action and its constants would become fully unreachable content if apply_raise's card were also removed  
*Chapter conflict:* ch.12 §4 requires a 'raise demand' attention badge and ch.10 §3 requires 'Çalışanımıza teklif verdi' as a rival move card that fires as an HR event — both point at the same unbuilt pair, so the gap is triple-governed rather than conflicting  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §9 lines 99-100` · `GDD ch.12 §4 line 10 (raise demand badge)` · `GDD ch.10 §3 line 15 (rival poaching move)` · `scripts/systems/hr_event_factory.gd:24-91` · `scripts/systems/hr_constants.gd:1002-1024` · `scripts/systems/hr_actions.gd:98-112`


**`conflict.ch07_ship_and_loss_moments` — §7's success-and-failure moments reach morale in only one direction**  
**DIVERGENT** · HIGH — it is the compound reason the module reads as a slow drain rather than as a responsive team simulation  
GDD: ch.07 rev 2 §7  

> Girdiler: fazla mesai · aşırı yüklenme · başarı ve başarısızlık anları (sürüm çıktı, hesap kaybedildi, kesinti) · lider Liderliği · event'ler. Maaş adaleti girdi değildir (zam ayrı bir olaydır, §9).

Of the five governed inputs: overtime works; aşırı yüklenme does not (auto.overload_no_morale); 'sürüm çıktı' is wired but unreachable; 'hesap kaybedildi' has no morale hook at all (B2BSalesSystem._churn touches no Character, b2b_sales_system.gd:46-55); 'kesinti' (outage/incident) has no system in the repo at all; lider Liderliği and event'ler work. Net: on a normal day the only automatic morale movement a run can produce is an overtime night, a leave return and a departure's grief — and two of the three absent inputs are the POSITIVE ones, which is why the practical morale curve is one-directional despite a recovery channel existing on paper.  
*Costs the player:* morale falls from overtime and departures and effectively never recovers on its own except through the calm-stretch beat  
*If removed:* n/a — the missing half is the finding  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `GDD ch.07 rev 2 §7 line 90` · `scripts/systems/hr_morale_system.gd:176-199 (the whole positive channel)` · `scripts/systems/hr_constants.gd:1069-1080` · `scripts/systems/b2b_sales_system.gd:46-55 (churn touches no Character)`


**`gdd.ch02.energy` — GAP — ch.02 §6 founder Energy / burnout has no field**  
**DIVERGENT** · HIGH — it is the founder-side half of the game's central pressure loop, entirely absent.  
GDD: ch.02 §6 and §10; ch.12 §8  

> One bar. Falls with overtime and long "founder does everything" stretches; rises with rest and delegation. Low energy: temporary skill penalty + triggers events (mistake, bad call, health). Not a nag; no pop-up per point. Reads in Personal and as a TopBar/ODA badge at thresholds. [WORKING thresholds]

No state exists. character.gd:28-96 is the complete @export list and carries no energy field. The nearest candidate is closed to the founder by three independent structures: HRMoraleSystem.apply_delta returns silently for any non-employee (hr_morale_system.gd:213-218), every morale reader iterates get_employees() which filters category == 'employee' (character_registry.gd:54-62), and the founder is deliberately excluded from HROvertimeSystem.participants() so he can never be paid or tired (:274-280), his presence modelled instead as the constant founder_participates() (:300-305). The founder's stored morale 50 (game_state.gd:952) is inert. ch.12 §8 lists 'energy' among Kişisel's required surface rows; personal_tab.gd draws none.  
*Costs the player:* Nothing — which inverts ch.01 §5's Bootstrap pressure law: 'founder does everything' is currently free forever, so delegation (ch.02 §5's stated purpose of hiring) buys time but never relief.  
*If removed:* Nothing to remove. Recorded because ch.12 §8 rules that a system with no surface row is not shippable, and this is a chapter-02 system with neither state nor surface.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/data_models/character.gd:28-96` · `scripts/systems/hr_morale_system.gd:213-218` · `scripts/systems/hr_overtime_system.gd:268-305` · `scripts/autoload/game_state.gd:952` · `GDD 02 §6, §10; GDD 12 §8`


**`xing.events.conditions` — Event engine ← Ekip · the condition surface, enumerated**  
**DIVERGENT** · HIGH — the whole team layer is invisible to the narrative engine.  
GDD: ch.11 §5; ch.11 §8  

> 'Events hook to system edges — churn, phase change, incident, raise demand, rival move, version ship, coverage red, promise broken — not to random calendar rolls.'

29 condition types; exactly one touches a person (founder_skill_min, founder only) and zero touch an employee. The list still carries day_min/day_max/random, i.e. the calendar rolls ch.11 §5 rules out, and lacks two of the eight named edges. Because EventModal reuses is_condition_met, ch.11 §8's locked-visible choices also cannot be locked on a team condition.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/event_manager.gd:368-457` · `scripts/autoload/event_manager.gd:369`


**`xing.events.no_signal_wiring` — Event engine ← Ekip · no signal subscription at all**  
**DIVERGENT** · HIGH — it is the root cause behind absent.hr_conditions and absent.levelup_signal.  
GDD: ch.11 §5  

> 'Events hook to system edges … not to random calendar rolls.'

EventManager connects to zero EventBus signals; EventBus appears in the file only as an emitter at seven sites. Every condition is a pull evaluated at daily/hourly eligibility time, so employee_experience_changed, morale_changed, assignment_changed, character_added/removed and hr_day_processed can never arm an authored event. This is the structural reason no HR edge can exist.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/event_manager.gd:164` · `scripts/autoload/event_manager.gd:867` · `scripts/autoload/event_bus.gd:60-79`


**`xing.funding.founder_lock_offsite` — Funding · the founder's third job is NOT in the assignment model**  
**DIVERGENT** · HIGH — the one-job-at-a-time lock is the whole Bootstrap pressure loop (ch.01 §5) and one third of it is unenforced.  
GDD: ch.02 §5 (ch.07 §4 defers to it)  

> 'The founder is an employee who holds ONE job at a time: building a version, selling, or fundraising (Hunt). While assigned, the other actions are locked-visible with a reason ("Kurucu yeni sürümde" / "Kurucu satışta" / "Kurucu yatırımcı turunda").'

Fundraising is not an assignable id: HRConstants.ASSIGNABLE holds six areas plus research and no fundraising. VCPitchSystem sets flags['pitch_prep_active'] and only ProductSystem._is_free reads it, so the founder can be on AREA_SALES and in pitch prep at the same time and the Görevler matrix cannot show it.  
*Chapter conflict:* ch.02 §5 names three jobs; ch.07 §4 hands the sentence back to ch.02 and adds nothing, so neither chapter closes the gap.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/vc_pitch_system.gd:422` · `scripts/systems/product_system.gd:334-340` · `scripts/systems/hr_constants.gd:139-140`


**`xing.gamestate.area_leads` — GameState · area_leads stores HR leadership outside the module**  
**DIVERGENT** · HIGH — coordination, morale climate and experience gain all hang off a lead the player is never allowed to choose.  
GDD: ch.07 §2; ch.07 §9  

> ch.07 §2: 'Liderlik: ekip lideri atanan çalışanın altındaki ekibin verimlilik modifier'ını, moral düşüş hızını ve deneyim kazanım hızını etkiler.' ch.07 §9: '"Ekip lideri istifa etti, yerine kim geçiyor?"'

The GDD's lead is APPOINTED (atanan) and re-appointed by the player on a departure. Nothing in production ever writes GameState.area_leads — only release_area_leads erases, .clear() at :803, and a save migration that is itself a no-op. The first branch of HRSystem.area_lead is unreachable in a fresh run, so the lead is always the highest-Liderlik person on the area or the founder. game_state.gd:251-253 states it: 'SEÇİM SEAM'İ YOK ve bu bilinçli'.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/autoload/game_state.gd:246-254` · `scripts/systems/hr_system.gd:187-206` · `scripts/autoload/game_state.gd:600-608`


**`xing.product.capacity` — Ürün ← Ekip · build capacity pool**  
**DIVERGENT** · HIGH — it is the throttle on every build hour and it ignores the player's assignment.  
GDD: ch.07 §4; ch.03 §8  

> ch.07 §4: 'Build ekibi (aktif sürüm) | Ürün · Tasarım · Yazılım alanları | hız, tavan, bug oranı.' ch.03 §8: 'With more people, the player can split: one group builds, another supports.'

capacity_total() = CAPACITY_BASE(1) + count_active_in_department(DEPT_PRODUCT_DEV) — by ROLE, not by assigned_jobs. It feeds capacity_speed_factor(), a concurrency divisor. So capacity and build speed answer 'who is on the build' with two different rulers, and the GDD's split-by-assignment never reaches capacity. ch.03 §14 still lists 'Team ceiling formula' as an open decision.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:237-243` · `scripts/systems/product_system.gd:262-268` · `scripts/autoload/character_registry.gd:311-319`


**`xing.product.creation_flow` — Ürün UI ← Ekip · SORUMLU picker**  
**DIVERGENT** · HIGH — the game ships two lead concepts, one appointable but per-build and outside the module, one per-area with no writer.  
GDD: ch.07 §2; ch.07 §9  

> ch.07 §2: 'Liderlik: ekip lideri atanan çalışanın altındaki ekibin verimlilik modifier'ını … etkiler.'

The GDD's lead is appointed PER AREA and re-appointed on departure. The only lead appointment in the game is per BUILD, made at Konsept, stored in a Ürün resource (FeatureBuild.lead_engineer_id) that Ekip cannot see or invalidate. The picker also re-decides eligibility in the UI via HRConstants.department_of instead of asking the engine.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/tabs/product/creation_flow.gd:681-692` · `scripts/systems/product_system.gd:1334`


**`xing.product.lead_engineer_id` — Ürün → holds an Ekip id · FeatureBuild.lead_engineer_id**  
**DIVERGENT** · HIGH — the coordination multiplier on the active build silently reverts to the founder's neutral value when the lead resigns.  
GDD: ch.07 §9  

> 'Ayrılan kişinin işleri boşalır ve oyuncuya sorulur: … "Ekip lideri istifa etti, yerine kim geçiyor?"'

start_build/start_version_build stamp a Character.id into the FeatureBuild resource and nothing ever rewrites or invalidates it. CharacterRegistry.remove clears assigned_jobs and releases area_leads but does not touch lead_engineer_id; _lead_coordination resolves a dead id to the founder branch by luck, which its own comment at :490-495 admits. The successor question is never asked.  
*Verification:* CORRECTION to one word: "by luck" is wrong. _lead_coordination (product_system.gd:484-506) has an explicit guard — `if lead != null and lead.category == "employee" and lead.status == STATUS_ACTIVE` at :502 — and falls to coordination_for_founder at :505-506 deliberately; the comment at :490-493 says the SILENT fall-through was the OLD behaviour and was fixed. Everything load-bearing survives: start_build stamps lead_engineer_id at product_system.gd:1334 and nothing rewrites or invalidates it (grep confirms no other writer); CharacterRegistry.remove (:530-548) clears assigned_jobs and releases area_leads but never touches it; ch.07 §9's successor question is never asked. Also confirmed: the …  
Evidence: `scripts/systems/product_system.gd:1334` · `scripts/data_models/feature_build.gd:45` · `scripts/autoload/character_registry.gd:530-548`


**`xing.product.reseat_founder` — Ürün → Ekip · _reseat_founder WRITES the assignment layer**  
**DIVERGENT** · HIGH — it can silently close the sales channel between two player actions.  
GDD: ch.03 §2; ch.02 §5; ch.02 §7  

> ch.03 §2 Konsept: 'Name · market (B2B/B2C) · subtype (2+2 in v1) · version intent · feature selection · price · team assignment (founder included).' ch.02 §7: 'Primary: learn by doing (assignment = growth decision).'

On every phase turnover ProductSystem calls CharacterRegistry.clear_areas(founder) then assign_area(phase area) — the only far-module write into the assignment layer in the codebase. A founder the player deliberately put on AREA_SALES is silently pulled off selling when a build phase changes, which in Bootstrap is the only sales capacity there is (ch.04 §2).  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/systems/product_system.gd:405-418` · `scripts/autoload/character_registry.gd:210-252`


**`xing.sales.stale_rep_heals_late` — Satış ← Ekip · a departed rep's accounts heal only on the next reconcile**  
**DIVERGENT** · HIGH — it deletes a named decision moment and hides a churn risk behind an invisible reconcile.  
GDD: ch.07 §9  

> 'Ayrılan kişinin işleri boşalır ve oyuncuya sorulur: "Melisa gitti, müşterilerine kim bakacak?" … Otomatik kurucuya devir varsayılan değildir.'

_release_unheld hands every orphaned account back to the founder silently on the next B2BSalesSystem.daily_tick — the exact automatic founder hand-off the GDD says is not the default. No card, no question, and until that tick the accounts carry a dead character id.  
*Verification:* appens on the player's modal acknowledge, at any hour, and nothing touches Customer.assigned_to until the next morning. PRECISION: the code writes `CustomerRegistry.assign_customer(c.id, "")` at :128 — an UNASSIGN, not an explicit founder hand-off; "" is what the model elsewhere reads as founder-held (_delegate_excess, :138-140), so the outcome is the GDD's forbidden automatic founder transfer, but the line does not name the founder. Pins die with it (:113, :128), which is an extra silent loss the row does not mention.  
Evidence: `scripts/systems/customer_rep_system.gd:106-134` · `scripts/autoload/character_registry.gd:530-548`


**`xing.ui.right_panel_retired` — RightPanel ← Ekip · a RETIRED surface still in the file set**  
**DIVERGENT** · LOW — dead code, but the GDD surface it implemented is also gone.  
GDD: ch.12 §2; ch.12 §9  

> ch.12 §2: 'Right panel carries today's items and warnings.' ch.12 §9 open decision: 'Whether the events log lives in Kişisel or in the right panel.'

ch.12 still legislates a right panel, and both of its Ekip crossings (get_mentor().character_name, the equity_pct>0 cap-table row) are unreachable: RightPanel.tscn is instantiated nowhere, main.gd:1054 records its retirement in the ODA rework and loc_residue.gd:49 lists it as a retired, unswept surface.  
*Verification:* Confirmed in the body by a second reader; claim unchanged.  
Evidence: `scripts/ui/components/right_panel.gd:126-128` · `scripts/main/main.gd:1054` · `scripts/debug/loc_residue.gd:49`


**`conflict.02.closed_card` — CHAPTER CONFLICT · ch.02 §3 'Two values, nothing else' vs the shipped ledger row**  
**GOVERNED**  
GDD: ch.07 rev 2 §3 (operative)  
hr_ledger renders name, role, key + secondary areas, Liderlik, a trait cell, salary, a morale bar with a number, an experience bar and up to three status chips. ch.07 §3's 'yalnız' scopes to the six AREAS — Liderlik is added 'Ek olarak' in §2 and is not one of them — so the six-column ban is honoured and the extra columns are not areas.  
*Chapter conflict:* ch.02 §3: 'Closed card (HR list): name · role · role-fit ★ · the role's key skill ★. Two values, nothing else.' OVERRIDDEN: ch.07 §3 restates only the six-column ban, not the two-value limit, so the shipped row is legal under the operative chapter and illegal under ch.02. ch.02 §3's 'role-fit ★' as a displayed value also has no implementation — role fit is a generation-time shape, not a rendered …  
Evidence: `scripts/tabs/hr/hr_ledger.gd:100-172` · `scripts/tabs/hr/hr_ui_shared.gd:53-66`


**`conflict.02.interview` — CHAPTER CONFLICT · ch.02 §9 interview step vs ch.07 §6 'Mülakat yok'**  
**GOVERNED**  
GDD: ch.07 rev 2 §6 (operative)  
HRSearchSystem runs idle → searching → files_ready → hire|dismiss with no interview state and no founder-time cost; SEARCH_ARRIVAL_MIN_DAYS 2 / MAX 4 and CANDIDATE_COUNT 3 match §6 exactly, and the file shows role, key/secondary areas, salary and traits at once.  
*Chapter conflict:* ch.02 §9: 'Shortlist/CV: role-fit ★ + key skill (approximate). Interview (costs founder time): exact 1+2 + 1–2 traits. Post-hire: full card.' OVERRIDDEN AND RECORDED: the three-stage reveal, the approximate-then-exact ladder, and ch.02 §12's open decision 'Interview cost currency (default: founder time, one day)'. Losing the interview also removes one of the few founder-TIME costs outside …  
Evidence: `scripts/systems/hr_search_system.gd:36-42` · `scripts/systems/hr_search_system.gd:113-165` · `scripts/systems/hr_constants.gd:710-714`


**`conflict.02.key_plus_two` — CHAPTER CONFLICT · ch.02 §3 'key + 2 supporting' vs ch.07 §3 'key + secondary'**  
**GOVERNED**  
GDD: ch.07 rev 2 §3 (operative)  
HRConstants.ROLE_AREAS stores exactly {key, secondary}; can_hold_area refuses any third area; HRUiShared.area_stars_row renders exactly those two and cites rev 2 §3 for the six-column ban.  
*Chapter conflict:* ch.02 §3 gives an explicit key+2 map per role: 'Geliştirici = Geliştirme + Tasarım + Operasyon · Tasarımcı = Tasarım + Geliştirme + Pazarlama · Satışçı = Satış + Müşteri Başarısı + Pazarlama · MB/Destek = Müşteri Başarısı + Satış + Operasyon · Pazarlamacı = Pazarlama + Satış + Tasarım · Operasyon = Operasyon + Geliştirme + Müşteri Başarısı.' OVERRIDDEN AND RECORDED: the whole table, including the …  
Evidence: `scripts/systems/hr_constants.gd:117-124` · `scripts/systems/hr_constants.gd:170-180` · `scripts/tabs/hr/hr_ui_shared.gd:39-51`


**`conflict.02.leadership_founder_only` — CHAPTER CONFLICT · ch.02 §4 'Liderlik is founder-only' vs ch.07 §2 'herkeste Liderlik'**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (operative)  
SKILL_LEADERSHIP is in EMPLOYEE_SKILL_KEYS; only FounderConstants.SKILL_CHARISMA stays exclusive.  
*Chapter conflict:* ch.02 §4 lists both as founder-only: 'Liderlik: morale ceiling + team output multiplier. NOT hiring.' OVERRIDDEN CLAUSE RECORDED: the code implements no morale CEILING — it implements a climate MULTIPLIER on morale deltas (CLIMATE_DROP_PER_POINT 0.05, floor 0.50) read off the FOUNDER's Liderlik, and the team output multiplier is the employee lead's coordination curve. ch.02 §4's 'NOT hiring' …  
Evidence: `scripts/systems/hr_constants.gd:41-44` · `scripts/systems/hr_morale_system.gd:236-250` · `scripts/systems/product_system.gd:486-507`


**`conflict.02.mentoring` — CHAPTER CONFLICT · ch.02 §7 mentoring as a tertiary channel vs ch.07 §2 'Liderlik'in içindedir'**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (operative)  
There is no skill-lifting mechanic. What exists is a LEARNING-RATE multiplier — experience_gain_mult(lead's Liderlik), neutral at 0 and capped at EXPERIENCE_LEAD_BONUS_MAX 1.5, plus the GERÇEK LİDER trait's lead_experience_mult — applied in tick_experience. Nobody's skill is raised by anybody else's skill; only the speed of their own counter changes.  
*Chapter conflict:* ch.02 §7: 'Tertiary: mentoring (a high-skill teammate lifts a low-skill one).' OVERRIDDEN AND RECORDED: the lift itself is gone. The two channels ch.02 §7 keeps (learn by doing, training) are both implemented; the third is folded into a rate on the first.  
Evidence: `scripts/systems/hr_system.gd:89-122` · `scripts/systems/hr_constants.gd:188-194` · `scripts/systems/hr_constants.gd:513-517`


**`conflict.02.pace` — CHAPTER CONFLICT · ch.02 §2 meta skill Hız vs ch.07 §2 'Hız kaldırıldı'**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (operative)  
The code follows ch.07 and actively defends it: 'pace' sits in HRConstants.RETIRED_SKILL_KEYS and CharacterRegistry._validate_shape push_errors on any record still carrying it; save_manager migrates it away.  
*Chapter conflict:* ch.02 §2: 'Plus one meta: Hız (time-to-complete of the assigned work). Total stored per person: 7 numbers.' TWO FURTHER CHAPTERS STILL CARRY HIZ, both approved 2026-08-20, one day BEFORE ch.07 rev 2: ch.03 §6 'speed from Geliştirme + Hız' and ch.06 §1.2 'capacity = throughput × assigned_heads × Müşteri Başarısı × Hız'. So the retirement is unrecorded in three chapters, not one. ch.02's '7 …  
Evidence: `scripts/systems/hr_constants.gd:60-66` · `scripts/autoload/character_registry.gd:474-479` · `scripts/autoload/save_manager.gd:696-712`


**`conflict.02.skill_list` — CHAPTER CONFLICT · ch.02 §2 six skills vs ch.07 rev 2 six areas**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (operative)  
HRConstants.AREAS holds exactly ch.07's six. FounderConstants mirrors them.  
*Chapter conflict:* ch.02 §2 names Geliştirme/Tasarım/Satış/Müşteri Başarısı/PAZARLAMA/OPERASYON, each feeding 'exactly one system with one lever'. OVERRIDDEN AND RECORDED: 'Pazarlama — channel efficiency (leads per spend)' and 'Operasyon — infra cost optimisation, incident response' have no key, no formula and no reader anywhere. Both overrides are corroborated elsewhere in the corpus — ch.06 §0 ships Operations as …  
Evidence: `scripts/systems/hr_constants.gd:27-44` · `scripts/systems/founder_constants.gd:35-40`


**`conflict.02.training_weeks` — CHAPTER CONFLICT · ch.02 §7 'WORKING 3 weeks' vs ch.07 §8 'Süre iki hafta'**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 (operative)  
HRConstants.TRAINING_DAYS := 14, whose comment records the change ('rev 2 §8: "Süre iki hafta" (5 idi)').  
*Chapter conflict:* ch.02 §7: 'training course = cash + person unavailable [WORKING 3 weeks] → +1 in one skill; diminishing on repeat.' Both chapters agree on the shape (cash + unavailability + one point + diminishing returns) and differ only on duration, 21 vs 14 days. Worth recording: the code's own history says the shipped value was 5 days before this rev, i.e. NEITHER chapter's number was ever live until …  
Evidence: `scripts/systems/hr_constants.gd:813`


**`conflict.ch02_liderlik_ceiling` — ch.02 §4's "Liderlik = morale CEILING" is not what the code implements**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (operative)  
The code implements ch.07's three jobs exactly and none of ch.02's ceiling: climate_drop_mult = clamp(1 − 0.05×L, 0.50, 1.0) on every negative delta, climate_gain_mult = clamp(1 + 0.05×L, 1.0, 1.50) on every positive one, coordination_for_founder (neutral at 0 → 1.20) and coordination_for_lead (0.85 → 1.20, two-sided), plus experience_gain_mult (hr_constants.gd:883-946). MORALE_MAX is a flat 100 for everyone regardless of Liderlik (:763-764), so no ceiling exists anywhere.  
*Chapter conflict:* ch.02 §4: "Liderlik: morale ceiling + team output multiplier." ch.07 rev 2 §2 (operative): efficiency modifier + morale-decay rate + experience rate. The code implements ch.07; ch.02's ceiling clause is overridden and recorded here rather than retired.  
Evidence: `GDD ch.02 §4 line 40; GDD ch.07 rev 2 §2 line 42` · `scripts/systems/hr_constants.gd:883-946, :763-764` · `scripts/systems/hr_morale_system.gd:236-250`


**`conflict.ch02_skill_model` — ch.02 §2's six skills + meta Hız are overridden by ch.07 rev 2**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (operative)  
The code carries the ch.07 set: HRConstants.AREAS and EMPLOYEE_SKILL_KEYS are the six areas plus leadership (hr_constants.gd:31-43, :66-110), and RETIRED_SKILL_KEYS [expertise, pace, rapport] is an active tripwire that push_errors on any surviving record (character_registry.gd:477-479). Hız's deletion is honoured downstream — B2BConstants.cs_capacity was re-seated onto Müşteri Başarısı for exactly this reason (b2b_constants.gd:203-212). RECORDED, NOT RETIRED: ch.02 §2's Pazarlama and Operasyon skills have no home in code at all, and ch.02 §3's 'Role → key + 2 supporting' mapping table is still live GDD text with no implementation.  
*Chapter conflict:* ch.02 §2 rules six role skills (Geliştirme · Tasarım · Satış · Müşteri Başarısı · Pazarlama · Operasyon) plus a meta Hız, 7 numbers per person, and ch.02 §3 fixes a role→key+2 mapping [WORKING]. ch.07 rev 2 §2, approved one day later and marked 'Supersedes rev 1', replaces them with six AREAS (Ürün · Tasarım · Yazılım · Test · Satış · Müşteri Başarısı) plus Liderlik and states 'Hız (pace) skill'i …  
Evidence: `GDD ch.02 §2 lines 8-31, §3 line 38; GDD ch.07 rev 2 §2 lines 16-41` · `scripts/systems/hr_constants.gd:31-43, :66-110` · `scripts/autoload/character_registry.gd:477-479` · `scripts/systems/b2b_constants.gd:203-212 (Hız deletion honoured downstream)`


**`conflict.ch02_training_weeks` — Training duration — ch.02 says 3 weeks, ch.07 says two, code says 14 days**  
**GOVERNED**  
GDD: ch.07 rev 2 §8 (operative)  
HRConstants.TRAINING_DAYS = 14 with the in-body note 'rev 2 §8: "Süre iki hafta" (5 idi)' (verified, hr_constants.gd:813). Code follows the operative chapter. The related ch.02 §7 pace clause is a separate matter and is scored on auto.experience_levelup.  
*Chapter conflict:* ch.02 §7: "Secondary: training course = cash + person unavailable [WORKING 3 weeks] → +1 in one skill; diminishing on repeat." ch.07 rev 2 §8: "Süre iki hafta." Code: 14 days. Recorded so ch.02's three-week figure is not silently retired.  
Evidence: `GDD ch.02 §7 line 54; GDD ch.07 rev 2 §8 line 94` · `scripts/systems/hr_constants.gd:813 (verified TRAINING_DAYS 14 with the rev 2 note)`


**`gdd.ch02.leadership_founder_only` — CHAPTER CONFLICT — ch.02 §4 makes Liderlik founder-only; the code puts it on everyone**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (OPERATIVE)  
SKILL_LEADERSHIP is a member of EMPLOYEE_SKILL_KEYS (hr_constants.gd:41-44); every generated candidate carries a value (hr_candidate_generator.gd:222-223) and seed_skills writes it for hand-built rosters (:213). The key now does TWO DIFFERENT JOBS depending on whose record it sits on. EMPLOYEE Liderlik → area_lead selection (hr_system.gd:200), area_lead_leadership_for → HRConstants.experience_gain_mult (:220, :188-193), and product_system.gd:504 coordination_for_lead. FOUNDER Liderlik → the morale CLIMATE coefficient via climate_drop_mult/climate_gain_mult (hr_morale_system.gd:240, hr_constants.gd:906-921) and product_system.gd:506. Of §2's three promised effects, two are live (verimlilik modifier, deneyim kazanım hızı) and the third (moral düşüş hızı) is live only through the founder's climate coefficient, never through the AREA LEAD's Liderlik — hr_morale_system.gd:236-239 marks this …  
*Chapter conflict:* ch.02 §4 lists BOTH Liderlik and Karizma under 'Founder-only' and defines Liderlik as 'morale ceiling + team output multiplier' — a founder-only number. ch.07 rev 2 §2 moves Liderlik onto every person and keeps only Karizma founder-only. The code follows ch.07; ch.02 §4's 'morale ceiling' phrasing is also not implemented as a ceiling but as a two-sided multiplier on deltas.  
Evidence: `scripts/systems/hr_constants.gd:39-44, :884-921` · `scripts/systems/hr_candidate_generator.gd:218-223` · `scripts/systems/hr_morale_system.gd:236-250` · `scripts/systems/hr_system.gd:187-221` · `GDD 02 §4 vs GDD 07 rev 2 §2`


**`gdd.ch02.skillset` — CHAPTER CONFLICT — ch.02 §2 skill set vs the code's areas**  
**GOVERNED**  
GDD: ch.07 rev 2 §2 (OPERATIVE — 'Supersedes rev 1', approved 2026-08-21)  
The code follows ch.07 exactly (hr_constants.gd:32-44), and it does not merely ignore ch.02 — it actively TRIPWIRES the retired keys: 'pace' sits in RETIRED_SKILL_KEYS (:66) and _validate_shape push_errors on any record still carrying it (character_registry.gd:477-479), while FounderConstants.OLD_SKILLS does the same for the founder's pre-rename names (game_state.gd:616-617).  
*Chapter conflict:* ch.02 §2 stores seven numbers per person: Geliştirme, Tasarım, Satış, Müşteri Başarısı, PAZARLAMA, OPERASYON plus the meta HIZ. ch.07 rev 2 §2 stores a different seven. OVERRIDDEN ch.02 CLAUSES, recorded rather than retired: (a) 'Pazarlama' as a stored skill — no key exists; the Pazarlama ROLE survives only as an EA lock in ch.07 §1/§6, and even that card is absent from the code (see cand.role). …  
Evidence: `scripts/systems/hr_constants.gd:32-44, :61-66` · `scripts/autoload/character_registry.gd:477-479` · `scripts/systems/hr_constants.gd:117-124` · `GDD 02 §2, §3 vs GDD 07 rev 2 §2` · `GDD 03 §6 and GDD 06 §1.2 still cite the deleted Hız`


**`xing.ekip.reads_product` — Ekip → Ürün · two pull-reads back across the boundary**  
**GOVERNED**  
GDD: ch.07 §7; ch.07 §8  
HRSystem._build_phase_running calls ProductSystem.get_active_build() to double the daily experience rate (EXPERIENCE_PER_DAY 1 → EXPERIENCE_PER_BUILD_DAY 2, both [WORKING]); HRMoraleSystem._latest_ship reads mvp_version_history for the ship-glow beat, which is §7's 'sürüm çıktı' verbatim. hr_ledger also reads get_active_build()/BUILD_AREAS to caption the experience bar.  
Evidence: `scripts/systems/hr_system.gd:306-312` · `scripts/systems/hr_morale_system.gd:525-535` · `scripts/systems/hr_constants.gd:810-811`


**`xing.endings.headcount` — Endings ← Ekip · headcount in the ending payload and the run ledger**  
**GOVERNED**  
GDD: ch.13 §3  
EndingsSystem._payload writes 'employees': get_employees().size(); GameState.get_run_ledger writes employees/hires/departures, maintained by CharacterRegistry.add/remove. Named seams. Headcount is the only people number that reaches an ending — no morale, no skill, no assignment. (ch.13 §3's net worth line is the one absent column, recorded at conflict.02.net_worth.)  
Evidence: `scripts/systems/endings_system.gd:301` · `scripts/autoload/game_state.gd:679-683`


**`xing.events.hr_pushes` — Ekip → event engine · five synthetic events**  
**GOVERNED**  
GDD: ch.07 §9; ch.07 §10  
HREventFactory builds resignation ('ayrılma anı'), the overtime valve, the calm stretch, big signing and ship glow ('moral olayları'); HRMoraleSystem and HROvertimeSystem hand them to EventManager.enqueue. TWO of §10's four families are missing entirely — zam talebi and rakip teklifi (see absent.hr_conditions / absent.hr_write_modifiers). enqueue BYPASSES _is_eligible, so one_shot, cooldown and build_safe do nothing and every once-only latch is held inside the HR system instead. This is the only channel by which the team reaches the modal queue.  
Evidence: `scripts/systems/hr_event_factory.gd:8-19` · `scripts/systems/hr_morale_system.gd:492-494` · `scripts/systems/hr_overtime_system.gd:371-377`


**`xing.events.modal_speaker` — Event modal ← Ekip · speaker strip reads four Character fields**  
**GOVERNED**  
GDD: ch.14 §7  
_render_registry_character reads character_name, portrait_path, role, relationship and the first two traits. The avatar and trait icons are ch.14 §7 and ch.02 §8. The `relationship` pill is an UNGOVERNED rider: it renders a five-state fit label (ally/friendly/neutral/wary/hostile) that no chapter defines and that sits uneasily with ch.02 §2's 'team compatibility lives in traits/tags (v1: not surfaced)'. This is also the site that falsifies character.gd:89-92's 'declared, not used', and _trait_label is the only place in the codebase that resolves against BOTH trait catalogs.  
Evidence: `scripts/modals/event_modal.gd:252-266` · `scripts/modals/event_modal.gd:329-338` · `scripts/data_models/character.gd:89-92`


**`xing.events.modifiers` — Event engine → Ekip · the modifier surface, enumerated**  
**GOVERNED**  
GDD: ch.11 §3; ch.07 §7; ch.07 §9  
44 modifier types, six person-touching: morale (routes to HRMoraleSystem.apply_delta for employees), morale_all_employees, add_character, hr_departure, hr_overtime_stop, hr_overtime_continue. All six use named seams except add_character. Every one maps to a ch.07 §7 or §9 input ('event'ler', 'fazla mesai', 'Ayrılma bir event anıdır'). hr_departure only CONFIRMS a resignation the morale machine already latched. What the list cannot do is recorded separately in absent.hr_write_modifiers.  
Evidence: `scripts/autoload/event_manager.gd:557-807` · `scripts/autoload/event_manager.gd:571-589` · `scripts/autoload/event_manager.gd:636-649`


**`xing.finance.hr_reads_cash` — Ekip ← Finans/GameState · affordability and runway reads**  
**GOVERNED**  
GDD: ch.02 §7; ch.07 §8; ch.08 §3  
send_to_training gates on GameState.cash; the Atlas and card previews read cash, daily_burn, net daily flow and runway_months through named seams. fire() and hire() are deliberately NOT affordability-gated — no chapter rules either way, and hiring past your runway stays a legal (losing) move.  
Evidence: `scripts/systems/hr_system.gd:294-303` · `scripts/systems/hr_search_system.gd:241-290` · `scripts/modals/training_modal.gd:153`


**`xing.finance.one_time_costs` — Ekip → Finans · four one-off charges**  
**GOVERNED**  
GDD: ch.08 §1; ch.07 §10  
Retainer, commission (both labelled 'hire'), severance and the training fee all leave through FinanceSystem.apply_one_time_cost. TWO of the four have NO GDD line and are phantom-cited: the 15% hire commission (hr_constants.gd:704, 'Çift ücret (design doc §2, KANON)') and severance at 1 month per full year (hr_constants.gd:1019, 'design doc §7'). None of the four enters burn_breakdown — they land in one_time_today plus the transactions log, and BURN_IDS has no 'hr' category.  
Evidence: `scripts/systems/hr_search_system.gd:159` · `scripts/systems/hr_actions.gd:189` · `scripts/systems/finance_system.gd:33-46` · `scripts/systems/hr_constants.gd:704-714`


**`xing.finance.payroll_pull` — Finans ← Ekip · payroll pull**  
**GOVERNED**  
GDD: ch.08 §1; ch.07 §4; ch.07 §10  
FinanceSystem.daily_tick pulls get_total_monthly_salaries() into burn_breakdown['salaries'] at slot 5. Verified NOT status-filtered — the loop tests only category=='employee', so on-leave and in-training people keep drawing pay (paid leave, deliberate). The founder is category 'founder' with salary 0, matching ch.08 §1. IN: employee monthly_salary including raises. NOT IN: founder, mentor, severance, training, retainer, commission, overtime.  
Evidence: `scripts/systems/finance_system.gd:136-138` · `scripts/autoload/character_registry.gd:412-421`


**`xing.gamestate.founder_construction` — GameState · builds the founder Character itself**  
**GOVERNED**  
GDD: ch.12 §5; ch.02 §11  
_build_founder assigns id, name, role, category, salary, equity_pct, morale, role_stats, assigned_jobs and traits directly, then calls CharacterRegistry.add. It picks the founder's opening AREA itself via _founder_start_area rather than HRConstants.default_area_for_role — no chapter says which job the founder starts on. It does not initialise area_experience: that block in add() sits inside the category=='employee' guard, so the founder's counters are created lazily by add_area_experience.  
Evidence: `scripts/autoload/game_state.gd:928-973` · `scripts/autoload/game_state.gd:555-568` · `scripts/autoload/character_registry.gd:434-457`


**`xing.product.area_sum_wrapper` — Ürün ← Ekip · _area_sum → HRSystem.area_sum_for**  
**GOVERNED**  
GDD: ch.07 §2; ch.03 §7  
A one-line wrapper over HRSystem.area_sum_for(area_id), the module's own multiplied-sum contract; tester_find_mult and tester_tempo_mult read AREA_QA through it. This is the one clean crossing on the Ürün side — WHO and the multiplier both come from the engine — and the model the other twelve should follow.  
Evidence: `scripts/systems/product_system.gd:598-616` · `scripts/systems/hr_system.gd:250-260`


**`xing.product.founder_build_area` — Ürün ← Ekip · founder ceiling contributions**  
**GOVERNED**  
GDD: ch.02 §5; ch.03 §2  
_founder_build_area returns founder.role_stats[area] but only while _founder_on_build() — the founder contributes exactly when assigned, as governed. It reads role_stats directly instead of GameState.get_founder_skill, bypassing that seam's OLD_SKILLS tripwire.  
Evidence: `scripts/systems/product_system.gd:784-791` · `scripts/autoload/game_state.gd:611-618`


**`xing.product.is_free` — Ürün ← Ekip · _is_free reads Character.status**  
**GOVERNED**  
GDD: ch.07 §8; ch.02 §5  
_is_free() gates on c.status != STATUS_ACTIVE and on the founder-only flag pitch_prep_active. The training leg is ch.07 §8 verbatim and the pitch-prep leg is ch.02 §5's fundraising lock — implemented as a flag rather than an area (xing.funding.founder_lock_offsite). The third status, STATUS_ON_LEAVE, comes from the annual-leave subsystem, which no chapter describes and which is phantom-cited throughout hr_morale_system ('design doc §8').  
Evidence: `scripts/systems/product_system.gd:334-340` · `scripts/systems/hr_constants.gd:796-802`


**`xing.product.lead_coordination` — Ürün ← Ekip · _lead_coordination reads Liderlik off the lead**  
**GOVERNED**  
GDD: ch.07 §2  
The coordination multiplier (COORD_MIN 0.85 → COORD_MAX 1.20, 1.25 with Doğal lider) reads lead.role_stats[SKILL_LEADERSHIP] plus lead.category and lead.status; the founder branch goes through GameState.get_founder_skill. Two paths to one number. The 'verimlilik modifier'ı' clause is implemented faithfully; the 'atanan' half of the same sentence is not (see xing.gamestate.area_leads), and the header at :490-493 confesses the stale-lead hazard.  
Evidence: `scripts/systems/product_system.gd:486-507` · `scripts/systems/hr_constants.gd:895-903`


**`xing.product.phase_area_sum` — Ürün ← Ekip · the build speed sum**  
**GOVERNED**  
GDD: ch.07 §2; ch.03 §6  
_phase_area_sum multiplies each crew member's own-area points by HRSystem.output_mult_for_area (a named seam that applies SECONDARY_AREA_MULT 0.7 and the overload 0.75) and by two HRConstants.trait_mult lookups on c.traits. Ürün therefore knows two Ekip internals by name: the shape of role_stats and the trait effect keys 'speed_mult'/'output_mult'.  
*Chapter conflict:* ch.03 rev 4 §6 (approved 2026-08-20) still sources speed from 'Geliştirme + Hız'; ch.07 rev 2 §2 (2026-08-21) deleted Hız and renamed Geliştirme to Yazılım. The code follows ch.07. This is the SAME override as conflict.02.pace appearing in a third chapter.  
Evidence: `scripts/systems/product_system.gd:513-541` · `scripts/systems/hr_system.gd:235-247`


**`xing.product.phase_crew_skills` — Ürün ← Ekip · _phase_crew / _best_phase_area read role_stats**  
**GOVERNED**  
GDD: ch.07 §2; ch.07 §5  
Ürün picks each person's strongest area inside a phase by comparing c.role_stats values itself (:461,:463,:477), using HRSystem.assigned_to for WHO. The multi-area cover and its secondary-rate price are both governed; the AUTO-PICK-BEST rule itself has no GDD sentence — ch.07 §4 has the player mark areas, not the engine choose among them.  
Evidence: `scripts/systems/product_system.gd:456-483`


**`xing.product.seed_expertise` — Ürün ← Ekip · at-commit bug seed**  
**GOVERNED**  
GDD: ch.07 §2; ch.03 §6  
_seed_expertise_mult averages engineering-area points over the assigned crew, EXCLUDING the founder (:1022), and pivots the at-commit bug seed against SEED_EXPERTISE_PIVOT/_SLOPE. Seam for WHO, direct role_stats and category for the numbers.  
Evidence: `scripts/systems/product_system.gd:1008-1026`


**`xing.product.team_area_avg` — Ürün ← Ekip · bug/wear quality average**  
**GOVERNED**  
GDD: ch.07 §2  
_team_area_avg weights the lead ×1.5 (LEAD_EXPERTISE_WEIGHT) and members ×1.0 over HRSystem.assigned_to(area), reading each c.role_stats[area] and the founder via get_founder_skill. It feeds _accrue_bugs_hourly on AREA_ENGINEERING and post-ship wear on AREA_QA — both levers named verbatim in the §2 table.  
Evidence: `scripts/systems/product_system.gd:577-596` · `scripts/systems/product_system.gd:973`


**`xing.product.trait_bug_rate` — Ürün ← Ekip · TİTİZ reduces bug rate**  
**GOVERNED**  
GDD: ch.02 §8; ch.07 §2  
_accrue_bugs_hourly walks HRSystem.assigned_to(AREA_ENGINEERING) and multiplies the rate by HRConstants.trait_mult(c.traits,'bug_rate_mult') per person — a rate modifier on a lever the Yazılım area already owns, which is the edge of §8's no-duplication rule. Seam for WHO, direct c.traits for the effect, key string living in Ürün.  
Evidence: `scripts/systems/product_system.gd:981-983` · `scripts/systems/hr_constants.gd:603-612`


**`xing.sales.assigned_to` — Satış ← Ekip · Customer.assigned_to holds a Character id**  
**GOVERNED**  
GDD: ch.07 §4; ch.04 §8  
Customer.assigned_to is a Character id string; CustomerRegistry.assign_customer is the single writer and emits EventBus.customer_assigned. The write seam lives on the SATIŞ side, so Ekip has no say in who is assigned and no notification when it changes; hr_tab subscribing to customer_assigned to repaint the MT card is the only place Ekip listens to a Satış signal.  
Evidence: `scripts/data_models/customer.gd:53` · `scripts/autoload/customer_registry.gd:350-357` · `scripts/tabs/hr_tab.gd:72`


**`xing.sales.b2b_traits` — Satış ← Ekip · two trait axes read from the B2B side**  
**GOVERNED**  
GDD: ch.02 §8  
B2BSalesSystem softens satisfaction erosion by trait_sum(rep.traits,'satisfaction_bonus') — a rate modifier — and B2BEventFactory biases request kind by trait_mult(rep.traits,'promise_chance_mult') — a probability modifier. Both are exactly the modifier classes ch.02 §8 permits. The effect-key strings are hardcoded in the Satış files (see absent.trait_getter).  
Evidence: `scripts/systems/b2b_sales_system.gd:78-90` · `scripts/systems/b2b_event_factory.gd:189-195`


**`xing.sales.cs_capacity_home` — Satış ← Ekip · the per-rep account cap lives in B2BConstants**  
**GOVERNED**  
GDD: ch.07 §5  
B2BConstants.cs_capacity(points) returns CS_BASE_CAPACITY + points/CS_PACE_PER_SLOT, giving the ladder 0-2→3, 3-5→4, 6-8→5, 9+→6 — exactly inside §5's [WORKING 3–6] band — and over-cap accounts auto-delegate, matching 'otomatik devrolur'. Read from three Satış files and one Satış UI. Where the constant LIVES is not a GDD matter, but note HRConstants.gd:224-236 declares which coefficients live elsewhere and does not list cs_capacity, so the one headcount cap ch.07 owns is absent from HRConstants.  
Evidence: `scripts/systems/b2b_constants.gd:202-212` · `scripts/systems/customer_rep_system.gd:130` · `scripts/systems/hr_constants.gd:224-236`


**`xing.sales.cs_desk` — Satış ← Ekip · the customer desk**  
**GOVERNED**  
GDD: ch.07 §2; ch.06 §1.2  
CustomerRepSystem ranks reps via HRSystem.assigned_to(AREA_CUSTOMER_SUCCESS) then reads role_stats[customer_success] for capacity, throughput, dampening and the absorb ceiling — precisely the three levers ch.07 §2 assigns to that area. Overtime enters through a named seam.  
*Chapter conflict:* ch.06 §1.2 (approved 2026-08-20) multiplies capacity by Hız; ch.07 rev 2 §2 (approved 2026-08-21) states 'Hız (pace) skill'i kaldırıldı'. ch.06's formula still names a skill that no longer exists — the same override recorded in conflict.02.pace, but in a chapter that is NOT ch.02.  
Evidence: `scripts/systems/customer_rep_system.gd:42-92` · `scripts/systems/customer_rep_system.gd:126-166`


**`xing.sales.cs_escalation_event` — Satış → event engine, carrying an Ekip Character**  
**GOVERNED**  
GDD: ch.04 §3; ch.14 §7  
B2BSalesSystem._enqueue_cs_escalation resolves c.assigned_to to a Character through a named seam and hands it to B2BEventFactory.build_cs_escalation; the Character then crosses into the event layer as a speaker, which is what gives the card its initials avatar.  
Evidence: `scripts/systems/b2b_sales_system.gd:174-179` · `scripts/systems/customer_rep_system.gd:318`


**`xing.sales.rep_desk` — Satış ← Ekip · the sales desk (founder included)**  
**GOVERNED**  
GDD: ch.04 §2; ch.02 §5  
SalesRepSystem gates the whole channel on HRSystem.assigned_to(AREA_SALES) being non-empty, then ranks by role_stats[sales] with overload/secondary/trait multipliers. The founder IS in the list because assigned_to includes category 'founder' — exactly as ch.04 §2 requires, and exactly where the founder-trait collision bites (collision.trait_catalogs). BOUNDARY, not audited: ch.04 §2 also says find_prospects auto-spawn must be REPLACED by lead flow + capacity.  
Evidence: `scripts/systems/sales_rep_system.gd:34-98` · `scripts/systems/sales_rep_system.gd:205-207`


**`xing.sales.tab` — Satış UI ← Ekip · account owner column and MT strip**  
**GOVERNED**  
GDD: ch.04 §6; ch.07 §5  
sales_tab renders the owning rep's name from get_character(c.assigned_to) and prints load/cap using B2BConstants.cs_capacity(rep.role_stats[customer_success]) — the reader for ch.07 §5's cap, which §5 itself gives no surface. get_character/get_active_by_role are seams; character_name and role_stats are direct reads.  
Evidence: `scripts/tabs/sales_tab.gd:379-382` · `scripts/tabs/sales_tab.gd:405-409`


**`xing.ui.hr_tab` — Ekip UI · hr_tab is the module's action surface**  
**GOVERNED**  
GDD: ch.07 §4; ch.12 §1  
Subscribes to 11 signals, renders the Kadro ledger and the Görevler matrix exactly as §4 specifies, and dispatches every player action through engine seams (assign_area/unassign_area, HRActions.apply_raise/fire). Direct reaches are display-only. It reads CustomerRepSystem.roster_size — a Satış read inside the Ekip page. Its own header admits the gap at :62-64: 'mesai ve arayış durumu için sinyal YOK (motorda yok)'. Note İŞTEN ÇIKAR has no GDD line in ch.02 or ch.07 (§9 covers only resignations and poaching) and is phantom-cited at hr_actions.gd:4 'design doc §7'.  
Evidence: `scripts/tabs/hr_tab.gd:62-84` · `scripts/tabs/hr_tab.gd:565-590` · `scripts/tabs/hr_tab.gd:784-838`


**`xing.ui.left_tabs` — Left rail ← Ekip · the attention badge**  
**GOVERNED**  
GDD: ch.12 §4  
LeftTabs sets the HR badge to HRSystem.attention_count() and reconnects on morale_changed / character_added / character_removed — the mechanism is exactly as specified. The MEMBERSHIP differs: it counts flight risk (governed), plus burning out, the needs_engineer badge, waiting candidate files and the angel nudge (none in §4's list), while two entries §4 does list — coverage red and raise demand — cannot exist at all (absent.ops_readers, absent.hr_conditions).  
Evidence: `scripts/ui/components/left_tabs.gd:72-74` · `scripts/systems/hr_system.gd:358-371`


**`xing.ui.modals` — Ekip UI · TrainingModal and HRActionModal**  
**GOVERNED**  
GDD: ch.07 §8; ch.11 §4  
TrainingModal calls HRSystem.send_to_training and previews via can_train/training_fee_for — all four §8 clauses are implemented (FEE_PER_POINT 220 tiering, TRAINING_DAYS 14, player picks the area, REPEAT_SURCHARGE 0.35). HRActions returns a `rows` array of delta/fact/rule records so the confirm card never recomputes a consequence, which is ch.11 §4's 'visible reader' discipline. TrainingModal duplicates send_to_training's own cash gate by reading GameState.cash directly.  
Evidence: `scripts/modals/training_modal.gd:145-175` · `scripts/modals/hr_action_modal.gd:1-25` · `scripts/systems/hr_actions.gd:56-95`


**`xing.ui.personal_tab` — Ekip UI · Kişisel is the founder's card**  
**GOVERNED**  
GDD: ch.07 §3; ch.02 §10; ch.12 §1  
Renders all six areas + Liderlik + Karizma as stars, founder traits from FounderConstants, tenure, phase ladder, cap table and an EĞİTİME GÖNDER button — the four things ch.07 §3 sends here. TWO governed elements are missing and have their own rows: the energy bar (absent.founder_energy) and net worth (conflict.02.net_worth). It reads founder.role_stats directly rather than get_founder_skill, bypassing the OLD_SKILLS tripwire, and reads GameState.founder_portrait because the founder's portrait is not in Character.portrait_path.  
Evidence: `scripts/tabs/personal_tab.gd:30-39` · `scripts/tabs/personal_tab.gd:180-198` · `scripts/tabs/personal_tab.gd:224-226`
