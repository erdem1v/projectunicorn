# Ekip — GDD v2 conformance

**Date:** 2026-08-20 · **Chapters:** 07 · Team & Roles (HR) and 02 · Founder & People Model
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Companions:** `01_urun.md` (build team, support contention), `02_satis_ve_pazar.md` (sales capacity, account ownership), `05_operasyon.md` (coverage), `09_arayuz_ve_oda.md` (onboarding, Kişisel tab).

---

## Verdict

HR is deep where the GDD does not ask for depth and empty where it does. Morale, overtime, the Atlas search, the candidate generator with its non-dominance invariant, training and resignation are all built and calibrated. What chapters 02 and 07 ask for is a different **shape**: one shared skill model for founder and employees, and an **assignment screen** that says who is doing what.

Neither exists. Employees carry three generic axes (`expertise`, `pace`, `rapport`) and the founder carries five different ones (`tech`, `sales`, `negotiation`, `leadership`, `influence`); the two sets are deliberately key-locked apart (`character_registry.gd:336-359`). Four of the six role skills the GDD names exist only as **role tags that select which formula reads the generic axes**, and two — Pazarlama and Operasyon — do not exist in any form.

The assignment gap is the more expensive one, because three other modules are blocked behind it: the support-vs-build tension (ch. 03 rev 4 §8), sales capacity (ch. 04 §2) and the coverage threshold (ch. 06 §1.3) are all statements about *who is occupied*, and there is no occupancy in the code. The only contention that exists is a company-level divisor counting **jobs, not people** (`product_system.gd:242-259`).

Two chapter-internal conflicts need a director ruling before implementation: **the interview step** (ch. 02 §9 wants one, ch. 07 §2 removes it) and **training length** (ch. 02 §7 says three weeks, ch. 07 §5 says one).

Finally, one live defect worth surfacing early: **firing and sending someone on holiday are currently unreachable.** `HRActions.fire` and `send_on_vacation` are fully implemented, severance and all, but the only UI that dispatched their action ids was the retired employee card; the ledger row sends only `ACTION_RAISE` (`hr_ledger.gd:213-215` against `hr_employee_card.gd:122-140`).

---

## 1. Requirements — the people model (ch. 02)

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | The founder uses **the same skill card as every employee** (02 §1, §2) | Two disjoint models sharing one field. Employees: three axes 0-9 (`hr_constants.gd:24-29`). Founder: five skills, 0-3 at creation with a documented ceiling of 5 (`founder_constants.gd:19, 23-27`). Key-locked apart on purpose (`character_registry.gd:336-359`). | **ÇELİŞİYOR** | several days |
| 1.2 | Six role skills, 0-10, each feeding one system with one lever (02 §2) | **None exist as stored numbers.** Geliştirme, Tasarım, Satış and Müşteri Başarısı exist only as role ids that decide which formula reads `expertise`/`pace` (`hr_constants.gd:79-89`). **Pazarlama and Operasyon do not exist at all** — no role, no axis, no system; the only trace is a zero-valued burn line with no writer (`finance_system.gd:38-39`). | **YOK** | several days |
| 1.3 | Plus one meta, **Hız**; 7 numbers per person (02 §2) | `AXIS_PACE` exists and is consumed in five places (build pace, lead rate, CS throughput, CS capacity, tester tempo) — but as one of three peers, not as a meta over six role skills. | **KISMİ** | included in 1.2 |
| 1.4 | **Uyum is not a number**; compatibility lives in traits (02 §2) | `AXIS_RAPPORT` (UYUM) is a stored 0-9 number and a load-bearing one: it drives the employee-lead coordination multiplier (`hr_constants.gd:667-675`) and morale resilience. | **ÇELİŞİYOR** | a day (fold into traits or retire) |
| 1.5 | Display as **stars, 5 at half-star resolution**; raw 0-10 on deep hover (02 §3) | Bare integers in a ledger table (`hr_ledger.gd:80-83, 130-137`). No star widget for people anywhere; `SegmentBar` is a 5-slot bar used only for founder skills in onboarding (`origin_traits_step.gd:300-303`). | **YOK** | a day |
| 1.6 | Closed card shows name · role · role-fit ★ · key skill ★ — two values, nothing else (02 §3) | The ledger row shows eight columns: name+role, three axis integers, an experience bar with a percentage, a status cell, salary, and a morale bar with a number (`hr_ledger.gd:53-99`). | **ÇELİŞİYOR** | a day |
| 1.7 | Open card / hover: 1 key + 2 supporting skills, Hız, trait icons, an explicit expand for the rest (02 §3) | There is no open card. `HREmployeeCard.build()` — the whole renderer — is **dead code** with no caller; `hr_tab.gd` still carries a vestigial `_expanded_id` that nothing consumes (`:35, 157, 446-449`). Row click opens the raise popover instead. | **YOK** | a day |
| 1.8 | Never a six-column skill table (02 §3) | Not violated today (three skill columns), but the ledger is the wrong grammar for what replaces it. | **VAR (by accident)** | — |
| 1.9 | **Liderlik**: morale ceiling + team output multiplier, and explicitly **not** hiring (02 §4) | Exactly this, and wired: morale climate scaling (`hr_morale_system.gd:254-261`, curves `hr_constants.gd:632-639`) and build coordination when the founder leads (`product_system.gd:310-312`, curve `hr_constants.gd:649-658`). It touches nothing else. | **VAR** | — |
| 1.10 | **Karizma**: pitch and fundraising probability and terms, and scandal/PR outcomes (02 §4) | Charisma was **renamed away** in the 2026-07-16 skill rename (`founder_constants.gd:8-20`); reading the old key raises `push_error` (`game_state.gd:576-577`). Its fundraising half lives on as `influence` (`pitch_constants.gd:59-62, 89`). The scandal half has nowhere to land: `GameState.active_scandal` has no writer outside a debug key. | **KISMİ** | a day (rename plus a scandal reader) |
| 1.11 | Founder stats must **not** gate hiring or candidate quality (02 §4) | Verified clean. Candidate axes come from `BAND_SHAPE` rotated by index (`hr_candidate_generator.gd:108-113, 178-196`), the seed is day + hires + role + band (`:162-173`), salary is a pure function of band and shape (`:201-258`). No founder term anywhere. | **VAR** | — |
| 1.12 | Traits are modifiers only, shown as icons (02 §8) | Traits exist with real effects for employees (`hr_constants.gd:262-303`), several of them wired (`coordination_bonus`, `no_team_bonus`, `non_lead_mult`). They are **not shown on the team page at all** — trait chips render only on the Atlas candidate card (`hr_ui_shared.gd:175-198` from `hr_atlas_modal.gd:293`). **Founder traits are structurally inert:** `product_system.gd:308-312` looks up founder trait ids in the *employee* trait table, which can never match. | **KISMİ**, with a real bug | hours (bug) + a day (icons) |
| 1.13 | The founder holds **one job at a time** — building, selling or fundraising — with the others locked-visible and a reason (02 §5) | **Absent.** The founder is a constant presence, never scheduled: he always contributes `1.0 x tech` to every build phase (`product_system.gd:338-341`), is always in the quality average (`:368-370`), is always the base of the capacity pool (`:172`), and joins product-dev overtime as a constant, unpaid, morale-free presence (`hr_overtime_system.gd:296-301`). Nothing refuses a founder action because he is busy with another. | **YOK — the Bootstrap pressure has no carrier** | several days |
| 1.14 | Delegation is hiring: a sales hire frees the founder from selling (02 §5) | Reps add throughput but the founder was never occupied, so nothing is freed (`sales_rep_system.gd:91-200`). | **YOK** | included in 1.13 |
| 1.15 | Founder **energy / burnout**: one bar, falls with overtime and long solo stretches, rises with rest and delegation; low energy gives a temporary skill penalty and triggers events; reads in Kişisel and as a TopBar/ODA badge (02 §6) | **Absent, and deliberately so today.** Two files state it: founder burnout is out of demo scope (`hr_morale_system.gd:228-231`, `hr_overtime_system.gd:274-276`). The founder carries `morale = 50` written once (`game_state.gd:911`) and read by nothing — `apply_delta` returns early for him (`hr_morale_system.gd:227-232`) and the average excludes him (`:304-317`). | **YOK** | several days |
| 1.16 | Kişisel tab: net worth = equity percent x last valuation, plus all-time peak; energy bar; founder card; current assignment (02 §10) | The tab exists in the rail but has **no page** — it falls through to the İçerik yolda placeholder (`center_viewport.gd:100, 122-157`). None of the four contents exist. Valuation is stored only on a signed Series A (`game_state.gd:253`), so there is nothing to multiply before then. | **YOK** | several days — see `09_arayuz_ve_oda.md` |
| 1.17 | Living costs are removed from burn; personal money does not exist (02 §1) | `burn_breakdown` still carries `founder: 50` labelled Kurucu yaşam gideri (`finance_system.gd:37`, `strings.csv:1475`) and it is **100 percent of the day-1 burn**. Personal cash correctly does not exist. | **ÇELİŞİYOR** — owned by `04_finans.md` | hours |

---

## 2. Requirements — the team module (ch. 07)

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 2.1 | Four roles in v1: Geliştirici · Tasarımcı · Satışçı · Müşteri Başarısı (07 §1) | **Six** hireable roles exist: `product_manager`, `designer`, `developer`, `tester`, `sales_rep`, `customer_rep` (`hr_constants.gd:79-89`). Product Manager and Tester are extra; both carry real mechanics (PM design bonus and experience ceiling, tester beta multipliers). | **ÇELİŞİYOR** — two roles must be cut or absorbed | a day |
| 2.2 | Pazarlamacı and Operasyon uzmanı are locked-visible, opening in EA (07 §1) | Neither role exists, so neither can be shown locked. The Atlas role grid renders exactly the six above (`hr_atlas_modal.gd:96-99`). | **YOK** | hours (two locked cards) |
| 2.3 | Pazarlama and Operasyon **skills** exist on a person but are not read in v1 (07 §1) | Neither skill exists. | **YOK** | included in 1.2 |
| 2.4 | Hiring: Atlas retainer → 2-4 days → 3 candidates (07 §2) | Exactly this. Retainer 600 charged up front and never refunded (`hr_constants.gd:472`, `hr_search_system.gd:159`), arrival derived from the stored seed inside 2-4 days (`:399-406`), three files (`hr_constants.gd:476`), delivered as a ticker line rather than a modal (`hr_search_system.gd:374-387`). | **VAR** | — |
| 2.5 | Candidate card: role-fit ★ + the role key skill + 1-2 traits (07 §2) | The card shows three labelled axis chips with raw integers, salary ask, trait chips with effect tooltips, commission and a runway before/after line (`hr_atlas_modal.gd:256-318`). Right information, wrong resolution — no role-fit star, no key-skill emphasis. | **KISMİ** | a day |
| 2.6 | **No interview step** (07 §2) — but ch. 02 §9 asks for one that costs founder time | There is no interview today (verified: `SkillCheck` is never invoked in any `hr_*.gd`). So the code matches ch. 07 and contradicts ch. 02. **Director ruling needed.** | **VAR** for ch. 07 / **YOK** for ch. 02 | hours to note; a day if ch. 02 wins |
| 2.7 | Offer → a single-step negotiation inside the salary band, slider grammar → accept or reject (07 §2) | **No negotiation.** The generated salary is copied verbatim into the hire (`hr_search_system.gd:194, 204`). The only salary lever in the game is the post-hire raise. | **YOK** | a day (the raise slider is the pattern to copy) |
| 2.8 | Salary band = role x skill level (07 §2) | `SALARY_BANDS[role][band]` with three discrete bands (`hr_constants.gd:420-427`), placed inside a narrow window by axis shape (`hr_candidate_generator.gd:201-258`). | **VAR** | — |
| 2.9 | **One assignment screen** with six jobs: build team, support, account ownership, sales, research, cost/debt work (07 §3) | **The screen does not exist, and four of the six jobs do not exist.** What exists: a single build **lead** dropdown (`creation_flow.gd:714-730`) and CS **account ownership** (`Customer.assigned_to`, seam `customer_registry.gd:343-357`, picker in the *Sales* tab at `sales_tab.gd:395-425`). Support, sales, research and cost work have no assignment at all. | **YOK — the module central gap** | several days |
| 2.10 | **One person, one job**, founder included (07 §3) | No exclusivity anywhere. `Character` has no `assigned_to` / `busy` field. A single developer simultaneously speeds the build, reduces live bug wear, hunts beta bugs, counts as capacity headcount and accrues experience, with no check (`product_system.gd:315-335, 364-379, 769`). | **YOK** | several days |
| 2.11 | An unassigned person stands idle, still draws salary, and this must be visible as a **Boşta** badge (07 §3) | No idle state exists — statuses are `active` / `on_leave` / `training` only (`hr_constants.gd:558-564`), and active means at work, never assigned. The CS desk is explicitly designed so a fresh hire never idles (`customer_rep_system.gd:14-17`). | **YOK** | hours (after 2.9) |
| 2.12 | Per-role standard capacity, and overload costs morale and output (07 §4) | Partly, and only on two desks. CS accounts per rep: `3 + floor(pace/3)`, so 3 to 6 (`b2b_constants.gd:202-209`), enforced by auto-release and auto-delegate (`customer_rep_system.gd:120-165`). Sales: **no per-person cap** — the caps are company-level (2 leads/day, 8 open prospects, `b2b_constants.gd:305-306`). Developer on build **and** support: does not exist, because support is not an assignment. Designer on multiple versions: only one build can exist at a time. | **KISMİ** | several days (after 2.9) |
| 2.13 | The person card reads Yük 7/5 with a direction arrow (07 §4) | Nothing renders load on the team page. The CS roster count is fed into the tab structure key with a comment claiming the card prints it (`hr_tab.gd:160-164`) — the card that printed it is dead. | **YOK** | hours (after 2.12) |
| 2.14 | Morale inputs: overtime, load overrun, success and failure moments, Liderlik, events. **Salary fairness is not an input** (07 §4) | Nine inputs exist and are correct in kind: overtime tiers −2/−4/−7 (`hr_constants.gd:765-769`), leave returns, raises, a teammate fired −5, weekly trait peers, positive events for ship / big signing / calm stretch, event modifiers, CS refuse −10 (`hr_morale_system.gd:190-214`, `hr_actions.gd:105, 224-227`, `b2b_constants.gd:199`). **Load overrun is missing** because load does not exist. Salary fairness is correctly absent — nothing compares pay to band, peers or market. | **KISMİ** | included in 2.12 |
| 2.15 | Low morale lowers Hız, then becomes flight risk (07 §4) | Flight risk and resignation are real: burnout at 40, flight risk at 25 (`hr_constants.gd:527-528`), a counter that freezes rather than resets during leave (`hr_morale_system.gd:124-145`), a roll from day 10 that becomes certain at 14 (`:479-493`). **But morale does not lower output** — no formula multiplies pace or expertise by morale. | **KISMİ** | hours |
| 2.16 | Training: money + the person away, +1 in a chosen skill, diminishing on repeat (07 §5; ch. 02 §7 says three weeks, ch. 07 says one) | Real: fee 500, five days away, `EXPERTISE_CAP = 8`, requires experience at maximum (`hr_constants.gd:574-576`, `character_registry.gd:103-142`, `hr_system.gd:107-115`). **Two divergences:** it always raises UZMANLIK — the player cannot choose the skill — and there is no diminishing return on repeats. Length is five days, matching neither chapter. | **KISMİ** | a day |
| 2.17 | Mentorluk: a high-skill teammate lifts a low-skill one, passively (07 §5) | Only a morale nudge: the `mentors_peers` trait gives +2 department morale weekly (`hr_constants.gd:271-273`). **No skill transfer of any kind.** | **YOK** | a day |
| 2.18 | Learn by doing: the assigned job raises its skill slowly (07 §5) | `experience` 0-100 accrues +1/day, +2 during a build (`hr_constants.gd:571-573`, `hr_system.gd:79-85`), and converts to +1 UZMANLIK only through paid training. It is not per-skill and not tied to the job, because there are no jobs. | **KISMİ** | a day (after 2.9) |
| 2.19 | **A raise-demand event** at one year served or a skill level-up; the demand may sit above the median (07 §6) | **Absent.** `HREventFactory` builds exactly five events: resignation, overtime valve, calm stretch, big signing, ship glow (`hr_event_factory.gd:29-90`). No JSON event asks for money. The raise exists only as a **player-initiated** action. | **YOK** | a day |
| 2.20 | The raise decision is a counter-offer on a slider; low offer lowers morale and raises flight risk; refusal risks departure (07 §6) | The slider exists and is good — 3 to 15 percent with a live preview of salary, payroll and morale before and after (`hr_actions.gd:43-108`, `hr_tab.gd:466-524`). It is attached to the wrong trigger: the player chooses to open it, so there is no refusal branch and no morale penalty for a low counter. | **KISMİ** | a day (after 2.19) |
| 2.21 | Flight-risk badge from low morale and sustained overload (07 §7) | Badge exists and is derived, never stored (`hr_morale_system.gd:283-301`), surfaced as a count on the rail (`left_tabs.gd:139`) and as a name on the ODA post-it (`oda_view.gd:1333-1345`). Overload half is missing (2.12). | **KISMİ** | — |
| 2.22 | A **rival poaching offer** event; decide between a counter-offer and letting them go (07 §7) | **Absent.** No poaching mechanic; `RivalRegistry` never touches `CharacterRegistry`. The closest thing is one line of resignation flavour text (`strings.csv:733`) with no mechanic behind it. | **YOK** | a day (needs the rival move deck) |
| 2.23 | A departing person leaves their jobs empty and team capacity falls; **no knowledge-loss penalty** (07 §7) | The no-penalty half is already right. The vacating half is partly right: CS accounts return to the founder on the next reconcile (`customer_rep_system.gd:113-119`), and a stale build lead falls back to founder coordination loudly rather than silently (`product_system.gd:295-312`). There are no other assignments to vacate. | **KISMİ** | — |
| 2.24 | Founder has no salary; burn = salaries + tools + serving cost (07 §6) | Founder salary is correctly 0 (`game_state.gd:909`). The burn composition is wrong on two of three lines — see `04_finans.md`. | **KISMİ** | owned by Finans |

---

## 3. Contradictions, expanded

### 3.1 Two skill models, and neither is the one the GDD wants

**The code decided:** employees are role-typed with three generic axes; the founder is a different creature with five named skills on a different scale. The split is enforced deliberately (`character_registry.gd:336-359`, `character.gd:14-18`).

**The GDD now rules** (02 §2): one card for everyone — six role skills 0-10 plus Hız, seven numbers per person, each skill feeding exactly one system with one lever.

**What the migration actually costs.** It is not a rename. Every formula that reads `expertise` or `pace` has to choose *which* role skill it now reads, and there are roughly fifteen such call sites: build speed and bug rate (`product_system.gd:315-343, 705-721`), iteration ceilings (`:551-565`), tester multipliers (`:390-400`), lead generation and warming (`sales_rep_system.gd:91-176`), CS capacity, dampening and throughput (`b2b_constants.gd:202-224`, `customer_rep_system.gd:64-82`), and the pitch rolls (`pitch_system.gd:246-248, 314`). The candidate generator (`BAND_SHAPE` and the non-dominance invariant) has to be re-derived for seven numbers instead of three. The save schema changes shape for every character.

**One thing the migration gets for free:** the GDD forbids founder stats from gating hiring, and that already holds.

### 3.2 There is no assignment layer, and three modules are waiting on it

**The code decided:** contention is a company-level divisor over *jobs*: `capacity_demand()` counts a bug sprint, a VC prep and an active build, and `capacity_speed_factor()` divides build speed by it (`product_system.gd:242-259`). No person is ever occupied.

**The GDD now rules** (07 §3): one screen, six jobs, one person per job, the founder included, with an idle badge on anyone unassigned.

**Who is blocked:**
- `01_urun.md` 8.4 — starting a version pulls the team off support. Unimplementable without occupancy.
- `02_satis_ve_pazar.md` 2.3 — sales capacity is the number of people assigned to selling.
- `05_operasyon.md` 1.3 — coverage is accounts divided by covering heads, and a covering head is someone *assigned* to support.
- `02` ch. 02 §5 — the founder holding one job is the same mechanism seen from the founder side.

This is why Ekip is first in the implementation order. Every other pressure system in the GDD is expressed in terms of who is occupied.

### 3.3 The founder is everywhere at once

Chapter 02 §5 is a tight little design: the founder holds one job, the others show locked with a reason, and hiring is how you buy your way out. The code gives the founder full participation in everything simultaneously, and the one place it models him being busy — `pitch_prep_active` adding a capacity slot (`vc_pitch_system.gd:397`) — only slows the *build*, never blocks a founder action.

Note what this costs the demo specifically: chapter 01 §5 names founder time as **the** Bootstrap pressure. Bootstrap currently has no time pressure at all.

### 3.4 Interview: the two chapters disagree

Ch. 02 §9 wants a three-stage reveal — shortlist shows role-fit and an approximate key skill, an **interview costing founder time** reveals the exact 1+2 and one or two traits, and the full card comes after hire. Ch. 07 §2 says the interview step was removed and the card says what it says. The code has no interview. A ruling is needed before the Atlas flow is redesigned, because the two produce different candidate cards.

### 3.5 Fire and Vacation are unreachable

`HRActions.fire` (`hr_actions.gd:212-234`) computes severance, charges Finance, drops −5 morale on everyone else and removes the record. `send_on_vacation` likewise. **Neither can be invoked**: the only producers of `ACTION_FIRE` and `ACTION_VACATION` were `hr_employee_card.gd:132, 139`, and that renderer is dead. The ledger row sends only `ACTION_RAISE` (`hr_ledger.gd:213-215`). Whatever the new team page looks like, it has to re-expose these two.

### 3.6 Dead weight to clear while the module is open

`HREmployeeCard` in full (`hr_employee_card.gd:25-159`), and with it `HRUiShared.badge_row`, `HRSystem.tenure_line`, `HRSystem.leave_line`, the YENİ badge path and `HRConstants.is_new_hire`. Also `HRUiShared.lines_block` (zero callers), `HRSearchSystem.current_band` (zero callers), the computed-but-never-displayed `preview_search["axis_meaning"]` with its twelve CSV rows (`strings.csv:711-722`), `HROvertimeSystem.KEY_STARTED_DAY`, `founder_participates()` (zero callers), and `Character.loyalty` / `relationship` / `trust_score` / `attention_flag`.

Three stale comments actively mislead: `hr_constants.gd:256-258` calls three trait effects DORMANT that are in fact wired; `hr_overtime_system.gd:22-25` and `hr_morale_system.gd:250-253` say coupling work is still pending when it has landed; `game_state.gd:241` says no fire or quit seam exists when both do.

---

## 4. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| Team skills → build speed, ceiling, bug rate | Ekip → Ürün | Dense: `product_system.gd:315-343` (speed), `:551-565` (ceilings), `:705-721` (bugs), `:390-400` (beta), `:891-900` (PM bonus), `:295-312` (coordination). | **present** |
| **Occupancy → support coverage** | Ekip → Ürün / Operasyon | **ABSENT** — the finding in 3.2. | **absent** |
| Rep skills → lead rate, warming, autonomous close | Ekip → Satış | `sales_rep_system.gd:91-200`. | **present** |
| **Assigned sellers → sales capacity** | Ekip → Satış | **ABSENT** — headcount adds supply, never a ceiling. | **absent** |
| CS skills → churn dampening, request throughput, escalation | Ekip → Satış | `b2b_constants.gd:202-224`, `customer_rep_system.gd:64-82, 230-249`. | **present** |
| Account ownership | Ekip ↔ Satış | Real, and the only true person-to-thing assignment in the game: `Customer.assigned_to`, auto-delegation above the founder cap of 4, a manual picker with load and capacity per rep (`customer_rep_system.gd:87-165`, `sales_tab.gd:395-425`). | **present** |
| Salaries and overtime → burn | Ekip → Finans | One-way daily **pull** at Finance slot 5, never a push (`finance_system.gd:134-143`; HR ticks at slot 3). | **present** |
| One-time HR costs | Ekip → Finans | Retainer, commission, severance, training through `apply_one_time_cost` (`hr_search_system.gd:159, 223`, `hr_actions.gd:221`, `hr_system.gd:113`). No affordability gate except training. | **present** |
| Liderlik → morale climate and coordination | Kişisel → Ekip / Ürün | `hr_morale_system.gd:254-261`, `product_system.gd:310-312`. | **present** |
| **Karizma → pitch terms and scandal outcomes** | Kişisel → Yatırım / Event | **PARTIAL** — the fundraising half survives as `influence`; the scandal half has no writer to read. | **partial** |
| **Founder energy → skill penalty and events** | Kişisel → all | **ABSENT.** | **absent** |
| HR events | Ekip → Event | Five factory builders and three modifiers (`hr_departure`, `hr_overtime_stop`, `hr_overtime_continue`) routed through HR seams (`event_manager.gd:624-641`). | **present** |
| **Raise demand, rival poaching** | Ekip ← Event | **ABSENT** — neither event exists. | **absent** |
| Product sprint pressure → hiring signal | Ürün → Ekip | `needs_engineer` → OVERLOADED badge → cleared by a developer hire (`product_system.gd:844-855`, `hr_search_system.gd:224-228`). | **present** |
| Headcount → VC meeting inputs | Ekip → Yatırım | `count_developers`, employees-empty (`vc_pitch_system.gd:653-661`), the `first_engineer` callback (`:293`). | **present** |
| Attention count → rail badge | Ekip → Arayüz | `HRSystem.attention_count()` (`hr_system.gd:170-183`) → `left_tabs.gd:139`. | **present** |
| **Employee equity** | Ekip → Finans | Hard-zeroed at hire by design (`hr_search_system.gd:205`), so the cap-table employee row is permanently empty. | **absent by decision** |

---

## 5. Depends on / depended on by

**Ekip depends on:** almost nothing. The skill model and the assignment screen can both be designed without waiting for another module — the six skills are named by ch. 02 §2, and the six jobs by ch. 07 §3. The only inbound dependency worth naming is that the **cost/debt job** and the **research job** name work that does not exist yet (Operasyon and the research slot), so those two rows of the assignment screen ship inert or wait.

**Depends on Ekip:** **Ürün** (support contention, build roster, the skill formulas), **Satış** (sales capacity, account ownership), **Operasyon** (coverage), **Kişisel/Arayüz** (founder card, energy badge, onboarding skill allocation), **Event** (raise demand, poaching, morale beats).

**Can it be decided alone?** Yes — and it must be decided first.

---

## 6. UI work

**Team page (replaces the ledger)**
- Closed row: name · role · role-fit ★ · key-skill ★. Two values, per ch. 02 §3.
- Open state: the role key skill plus its two supporting skills, Hız, trait icons, and an explicit expand for the remaining three skills. Raw 0-10 only on deep hover.
- Per person: **current job**, **load** as `7/5` with a direction, morale, salary, and a **Boşta** badge when unassigned.
- Fire and Vacation must be reachable again (3.5).

**Assignment screen (new, the module centrepiece)**
- Six jobs down one axis, people down the other, one person per job, founder included as a row.
- Each job states its effect in the player vocabulary: build speed and ceiling; ticket resolution and response time; account satisfaction and risk cards; lead handling and closing; a locked feature opened; serving cost and debt reduced.
- Assignment lists filtered to the job 1+2 skills, side by side, so the comparison is possible without a six-column table.
- Leaving support empty has to be visible **on this screen**, since that is where the player creates the situation.

**Atlas / hiring**
- Candidate card at the same resolution as the team page: role-fit ★, key skill, one or two traits.
- A salary negotiation step: one slider inside the band, the same grammar as the raise popover.
- Two locked role cards for Pazarlamacı and Operasyon uzmanı, with a Coming Soon reason.
- If ch. 02 §9 wins the interview ruling, the card needs a pre-interview state (approximate values) and a post-interview state (exact).

**Kişisel tab (new page)**
- Founder card on the same skill grammar, plus Liderlik and Karizma.
- **Energy bar** with its thresholds.
- Current assignment, and what it locks.
- Net worth as equity percent x last valuation, with the all-time peak.

**Events**
- Raise demand and rival poaching are event cards, so their copy and their locked-option reasons belong to the event pass.

---

## 7. Sizing

| Item | Size | Assumes |
|---|---|---|
| Re-expose Fire and Vacation | hours | the actions are already built |
| Founder-trait lookup bug (`product_system.gd:308-312`) | hours | |
| Two locked role cards (Pazarlamacı, Operasyon uzmanı) | hours | |
| Delete the dead card renderer and its five orphaned helpers | hours | |
| Boşta badge | hours | after the assignment layer |
| Yük 7/5 readout | hours | after per-role load |
| Morale lowers Hız | hours | one multiplier, one call site |
| Star display at half-star resolution | a day | needs the 0-10 model first |
| Salary negotiation at offer | a day | copy the raise slider |
| Raise-demand event + counter-offer branch | a day | |
| Training: choose the skill, add diminishing returns, settle the length | a day | |
| Mentoring as real skill transfer | a day | |
| Rival poaching event | a day | needs the rival move deck (`07_rakipler.md`) |
| Candidate card at the new resolution | a day | |
| **Six-skill model migration** (storage, generator, ~15 formula call sites, save schema) | several days | the single largest item; everything else in the module sits on it |
| **Assignment screen and one-person-one-job** | several days | second largest; three other modules are blocked on it |
| Per-role load and capacity, with morale consequences | several days | after the assignment screen |
| Founder one-job-at-a-time, with locked-visible reasons | several days | after the assignment screen |
| Founder energy / burnout bar and its events | several days | needs a Kişisel page to live on |
| Kişisel tab page | several days | see `09_arayuz_ve_oda.md` |

---

## 8. Open questions for the director

1. **Interview: in or out?** Ch. 02 §9 wants one costing founder time; ch. 07 §2 says it was removed. The two produce different candidate cards, so this blocks the Atlas redesign.
2. **Training length.** Ch. 02 §7 says three weeks, ch. 07 §5 says one, the code does five days. Also: should the player choose which skill rises? Today it is always UZMANLIK.
3. **Product Manager and Tester.** Ch. 07 §1 lists four roles; the code has six, and both extras carry real mechanics (the PM experience-axis bonus and ceiling, the tester beta multipliers). Cut them, fold their effects into the four, or amend the chapter?
4. **UYUM.** Ch. 02 §2 says compatibility is not a number and lives in traits; the code has `rapport` as a load-bearing 0-9 axis feeding lead coordination. Retire it into traits, or keep it as a seventh number?
5. **Standard capacity numbers** (07 §9) — CS accounts is [WORKING 5] against a code ladder of 3-6; the salesperson opportunity cap does not exist yet.
6. **Raise band and slider range** (07 §9) — the demand may sit above the median, e.g. 13-15 percent while the market is 8-10.
7. **Idle warning** (07 §9) — an automatic warning for an unassigned employee, or only the badge?
8. **Skill growth pace** (02 §7) — a starting employee moves about one tier over 24 months. With a 0-10 scale and a soft cap decision deferred to first playtest, this is the number that decides whether training or learn-by-doing is the main channel.
