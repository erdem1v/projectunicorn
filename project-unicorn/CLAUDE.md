# Project Unicorn — Agent Session Entry Point

## Project Summary

Project Unicorn is a narrative-strategy startup simulator built in Godot 4 + GDScript. The player founds a tech startup and navigates ~150 in-game days (≈60-90 min real time) across three phases — Bootstrap → Traction → Series A Hunt — managing Product, HR, Finance, and Sales while responding to reactive events and cinematic moments (scandals, VC pitches, term sheet negotiations). Endings include Series A close (Founder-Friendly / Aggressive variants), acqui-hire, profitable bootstrap, bankruptcy, brand collapse, VC rejection cascade, and time-out. Tone and depth comparable to CK3 / Frostpunk / Disco Elysium, transposed to a 2020s tech setting. Target platform Steam (Windows primary, Mac / Linux secondary), TR + EN at launch.

---

## Governing Design Principles

Before reading the rest of this document or any spec, internalize these principles. They are the design DNA of Project Unicorn and override any specific spec or instruction if a conflict arises.

1. **Project Unicorn is "Software Inc., but the founders are people."** Strategy game, not tycoon. We take Software Inc.'s product development backbone (iteration → development → polish, quality from process, ship trade-offs) and adapt each step as event-driven narrative decisions. Disco Elysium voice + CK3 character weight + Frostpunk pressure layer on top.

2. **Every economic outcome comes from a played decision moment.** No auto-revenue, no auto-progress, no system-event-as-economic-delta. If a change would touch cash, MRR, brand, reputation, customer count, or any other economic field, ask: "what specific player decision earned this?" If no decision moment exists upstream of the delta, no delta. Flag the question rather than introducing auto-progress silently.

   *Revision note (Economy Model v2): B2C revenue is now **derived auto-flow** — MRR updates continuously (hourly) from the player-managed **audience + price** levers, not tycoon spontaneous income, and the audience is **bidirectional** so bad management still erodes it (MRR can fall; runway stays a threat). The principle's intent holds — every delta traces to a played lever — but the literal "no auto-revenue" is relaxed to "no auto-revenue **untethered from player levers**." B2B stays pitch-driven. See [`docs/PROJECT_SPEC.md`](docs/PROJECT_SPEC.md) §10 Revision.*

3. **Micro-to-macro player evolution is the killer differentiator.** Same player, evolving interaction grammar as the company scales across the three release tiers. Tier 1 = micromanage. Tier 2 = delegate, set policy, intervene on exceptions. Tier 3 = macro decisions only. Plan all Tier 1 systems with Tier 2/3 in mind even when shipping Tier 1 alone — data shapes, save schemas, and event vocabularies should anticipate the trillion-dollar version.

4. **Narrative-strategy means decision over optimization.** When in doubt between a path that creates a story moment and a path that adds a stat, favor the story moment. Numbers serve narrative weight, not the other way around.

5. **Reference points.** When making design judgment calls, anchor on Crusader Kings III (character-driven decisions, event-rich), Frostpunk (recoverable pressure, moral weight, atmosphere of constraint), Disco Elysium (interior life, dialogue as gameplay), Football Manager (readable dense UI, sim depth without action), Software Inc. (product development mechanics adapted from their proven backbone). The first four define our voice; the fifth defines our system reference.

These principles are non-negotiable for design decisions. Implementation can flex; design DNA cannot.

---

## RELEASE SCOPE (LOCKED — July 2026, supersedes any older tier/scope notes)

The game ships in three stages. Each stage has a different NATURE, not just more content. Never build a feature that contradicts the stage it ships in. (Where this reframes Governing Design Principle 3's "Tier 1/2/3 release tiers" — DEMO = Tier 1, EARLY ACCESS = Tier 2, FULL = Tier 3 — this table is authoritative on what each stage IS and what ships when.)

| | DEMO | EARLY ACCESS | FULL |
|---|---|---|---|
| Nature | Campaign (an authored arc) | Living-company sandbox | Sandbox + new grammar |
| Arc | Bootstrap → Traction → Series A close = clean VICTORY ending | Series A close OPENS endless flow; Series B = milestone-NOT-ending | → IPO → macro phase |
| Ends? | Yes — Series A close is a real victory screen | NO — play continues until bankruptcy or the player stops; new runs give varied experiences | No — adds the IPO gate and macro grammar |
| Tabs | Core set | ALL core tabs open (Product, HR incl. founder training, Finance/Yatırım, Sales, Marketing system, R&D first layer, Ops) | + macro systems (regulation, politics, mega-corp) |
| Duration | 60-90 min, kolay-orta difficulty (challenge felt, always fair) | 6-8+ hours, open-ended | 10-12+ hours |
| In-game time | ~part of year 1 | ~1-2 years (curve redesign pending) | ~2+ years |

Hard rules that follow from this table:
- **Series B is a MILESTONE, never an ending.** It grants money + prestige + RAISED expectations (bigger burn, investor pressure) and play continues. Never wire Series B to trigger_ending.
- **IPO is OUT of Early Access** — it ships in FULL because it changes the play grammar (macro). In EA, IPO appears as a VISIBLE-LOCKED gate that opens when valuation crosses a threshold: "IPO yolu açıldı — tam sürümde." This is the strongest Coming-Soon telegraph in the game: the player's own company reaches a door it cannot enter yet.
- **The endless flow must stay alive** (see Calibration Law 1): post-Series-A play is kept under pressure by rival evolution, product aging/bug accrual, the raised post-Series-B bar, and the valuation league. If you build any of these systems, they are load-bearing for EA — not decoration.
- **SaveManager is MANDATORY** (EA cannot ship without it; the demo needs it too). A resolution/optimization polish pass (1080p / 1440p / 4K) is required scope, not nice-to-have.
- **EA v0.1 may ship with the endless CORE** (post-Series-A flow, HR hiring wave, valuation + league, Series B milestone, Save) and land Marketing / R&D / multi-product via early updates. When cutting for v0.1, cut depth, never the endless flow itself.
- Extra origins (Varis, Kurumsal Mülteci) remain FULL-only; they stay visible-locked in demo/EA.

---

## CALIBRATION LAWS (LOCKED — genre research July 2026, the 90%+ vs 75-80% divide)

Genre research across Game Dev Tycoon (94%), Software Inc (94%), Suzerain (93%) vs Startup Company (80%), The Meter is Running (76%), This Is the President (68%) established five laws. They bind DESIGN decisions now, and the numeric calibration pass later.

1. **Money must NEVER stop mattering.** The genre's #1 score-killer is the economy collapsing into number-growing once the player is rich. Every phase must RE-TIGHTEN the runway: bigger team = bigger payroll, rising investor expectations, rival pressure. Build anti-snowball mechanics and make them LEGIBLE — the player must SEE the rising bar (never an opaque hidden score). If a feature would let the player permanently "solve" money, redesign it.
2. **Match run length to content depth; kill dead time.** Never pad in-game days with repeated content. No stretch of play should run >60-90 seconds without a meaningful decision (outside deliberate breathers). Fast 4x that compresses dead days + auto-slow when a decision arrives is the target grammar.
3. **Choices must visibly change game state.** Every major outcome (pitch result, Series A close, retention outcome) must be traceable by the player to visible state — runway, traction, satisfaction, sentiment — never delivered by a hidden aggregate that can contradict the player's narrative. (§10 already forbids un-played economic outcomes; this law adds: the CAUSE must be readable.)
4. **Systems must be load-bearing.** If a player can win while ignoring an entire subsystem, that subsystem must be integrated (its neglect must cascade) or cut. Interconnection is the measured difference between the 94% and 80% games in our genre.
5. **Replayability is structural, not padding.** Runs diverge through varied event-deck order, hire pools, rival/investor mixes, and product-type starts — and off-meta strategies must be viable. Never manufacture replay value by repeating the same content.

Playtest tripwires (when the calibration pass runs): a naive policy winning >60-70% of runs, or players reporting the last third as "autopilot," means the economy has collapsed — retune before adding content. In-game duration is being extended from 180 days to ~1-2 years (tier-dependent) with the MRR/traction curve reshaped against realistic startup timelines; until that curve redesign lands, treat all pacing/threshold numbers as provisional and keep them in single tuning surfaces.

---

## Content & Language Laws (LOCKED — Editorial Package 4, 2026-07-14)

These govern all player-facing text and event authoring. They are enforcement rules, not suggestions.

**LANGUAGE INTEGRITY LAW.** Turkish is canonical; English is a literary translation delivered via the localization layer (Godot `TranslationServer` + `localization/strings.csv`, language toggle in Settings — Package 5). **No MIXED TR/EN inside a single player-facing string** (that original intent stands) — full-language EN via the locale switch is correct. Within the Turkish canonical text, English tech terms appear only where they are genuine Turkish-tech loanwords founders actually say — the ruled accepted set is: `pitch, startup, demo, momentum, MRR, runway, churn` (plus proper nouns and the established loanwords `laptop, mail, VC`). Everything else translates to its clean Turkish form (e.g. bug→hata, feature→özellik, feedback→geri bildirim, roadmap→yol haritası, deadline→son tarih, build→geliştirme, push→gönder/yayınla, launch→çıkış/lansman). English lives only in code and specs, never on screen.

**EVENT AUTHORING LAW.** No fake choices. No choice pre-labels its own wisdom (don't tell the player which path is "mantıklı"/"pratik"/right). Effects are shown in readable Turkish, never as internal codes. No event implies an unbuilt system. Time-of-day fiction must match a real firing window — or omit the clock entirely (deterministic beats fire at the day boundary, so they must not assert a specific `· HH:MM`). NPC register stays short and dry; monologue stays coherent. Never name an internal UI node or tab in fiction — a mentor guides as a person ("satış tarafına bak"), not as a UI manual ("Sales sekmesine tıkla").

**EFFECT-VISIBILITY RULE.** Modifiers are shown to the player in readable Turkish labels via `event_modal._describe_modifier` (`scripts/modals/event_modal.gd`), never as internal codes. It is the single place effect badges are built. For choices carrying 2+ effects, prefer a future hover/tooltip reveal over cramming inline (EU4/CK3 grammar) — the tooltip pattern is a pending follow-up (badge chips currently use `mouse_filter = MOUSE_FILTER_IGNORE`).

---

## State Coherence — WRITE-THROUGH LAW (LOCKED — 2026-07-14)

No event, modal, or UI may mutate another domain's state directly. Every domain change goes
through the owning system's **seam** — a method on the system that owns that state — and the
seam **emits a signal** wherever the UI reacts to it. If a needed seam doesn't exist, **build
it**; never write the field directly "just this once." And **every event choice's narrative
claim must match its modifiers** — if the copy says "koltuk ekle," the modifiers add seats.

Owning seams (write through these, never the raw field):
- Customers → `CustomerRegistry.set_mrr / set_seats / set_satisfaction / add / remove` (each emits).
- Aggregate MRR → `SalesSystem.reflect_mrr()` (the single customer-MRR→GameState bridge).
- Cash / brand / reputation / burn / phase → `GameState.set_*` setters.
- Characters → `CharacterRegistry.*`. Product / build → `ProductSystem.*`.

**Worked cautionary example (the disease this law cures).** An event titled *"Koltuk artırımı"*
promised the customer more seats, but its modifier only bumped MRR by a flat number — the seat
count never moved, because **no seat seam existed** and the code poked the field (or a cached
mirror) directly. The fix was not to poke harder; it was to build `CustomerRegistry.set_seats`
(emitting `customer_seats_changed`) and route a `seats` modifier through it, so the seat display
finally moves and the fiction matches the state. Raw cross-domain writes also create **stale
mirrors** — e.g. a raw `mrr` write is silently reverted by the next MRR-bridge tick — another
reason the seam, not the field, is the only sanctioned write. Future specs must name their
seams; future events must match claims to modifiers.

---

## Document References

- **Game design master:** [`docs/PROJECT_SPEC.md`](docs/PROJECT_SPEC.md) — vision, pillars, mechanics, content, systems, win/lose conditions, endings
- **Technical constitution:** [`docs/TECH_SPEC.md`](docs/TECH_SPEC.md) — architecture, conventions, decisions (LOCKED unless Decision Log §20 revised)
- **Content guide:** `docs/CONTENT_GUIDE.md` — *not yet created.* Will be added during the content phase (event writing voice, character bible).

---

## Agentic Workflow Rule (CRITICAL — TECH_SPEC §19)

**At the start of every session, read this file + `docs/PROJECT_SPEC.md` + `docs/TECH_SPEC.md` before doing anything else. Do not write gameplay code until both specs are understood and locked.**

If a spec is missing, contradictory, or ambiguous, **stop and ask** — never guess. Spec-driven development is non-negotiable.

---

## Tech Stack (LOCKED — TECH_SPEC §2)

- **Engine:** Godot 4.x (latest stable; current `project.godot` config_version=5, features `4.6 Forward Plus`)
- **Language:** GDScript only (no C#, no visual scripting)
- **UI:** Control nodes + Scene hybrid (layout in `.tscn`, logic in `.gd` scripts attached to scenes)
- **State:** Autoload singletons + EventBus signal hub
  - Planned singletons: `GameState`, `CharacterRegistry`, `EventManager`, `TimeManager`, `SaveManager`, `Settings`, `EventBus`
- **Persistence:** JSON via FileAccess, schema-versioned, seeded RNG (deterministic replay)
- **Steam:** GodotSteam plugin — achievements, Cloud Save, Rich Presence; isolated behind `SaveManager` so dev runs work without Steam
- **Localization:** Godot CSV-based — TR canonical, EN literary translation

---

## Teaching Mode (ACTIVE — TECH_SPEC §3.2)

The developer is learning Godot. The agent owns Godot-side work fully but operates as a teacher, not a black box. For every meaningful operation or logical batch, the agent explains four things — concisely (2-4 sentences, batched):

1. **What** is being created or changed
2. **Why** this approach / node type / pattern was chosen
3. The underlying **Godot concept** (e.g. "Autoload singleton", "Control anchor", "scene instancing") with a one-line explanation
4. If there was a meaningful choice, what **alternatives** were considered and why this one won

---

## Scope Discipline (TECH_SPEC §19.6)

The agent stays strictly within `PROJECT_SPEC.md`. **It does not invent mechanics, content, or architecture.** If something is underspecified, flag it; do not fill it independently.

`PROJECT_SPEC.md §8` lists current Open Questions & Inconsistencies (Corporate Refugee origin, Find prospects cooldown, World & Drama mechanics, Term Sheet negotiation, Operations / Dashboard systems, Visual Identity, UI wireframes). These are blockers for the affected features — do not implement around them.

---

## Current Project State

- `project.godot` config/name = `"Project Unicorn"`, Godot 4.6 Forward Plus
- `docs/PROJECT_SPEC.md` ✅
- `docs/TECH_SPEC.md` ✅
- `CLAUDE.md` ✅ (this file)
- `icon.svg` (default Godot icon — replace during Visual Identity phase)
- No scenes, no scripts, no data, no theme, no autoloads, no localization files yet
- TECH_SPEC §4 directory layout (`scenes/`, `scripts/`, `data/`, `assets/`, `themes/`, `localization/`) **not yet created** — pending skeleton review with the developer

---

## Next Step

Skeleton planning: walk the developer through the proposed `scenes/` + `scripts/` + `data/` + `themes/` + `localization/` skeleton (TECH_SPEC §4), the autoload registration list (TECH_SPEC §6.1), and the order of first scenes to build (Onboarding flow per `PROJECT_SPEC.md §3.1` is the natural first target). **No gameplay code until that plan is approved.**

---

## What this project is NOT (yet)

- No scenes, scripts, or resources committed
- No `CONTENT_GUIDE.md` — content phase not yet started
- TBD sections in `PROJECT_SPEC.md` are not to be implemented around — block the affected feature and surface the gap
- No Godot MCP operations performed yet — first MCP work begins after skeleton approval
