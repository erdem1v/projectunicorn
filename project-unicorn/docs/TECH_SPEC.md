# Project Unicorn — Tech Spec (Godot 4)

Master technical reference for agentic development. The agent reads this at the start of every session, alongside `PROJECT_SPEC.md`.

This document defines architectural decisions and conventions at the **principle level**. It does not contain implementation code — the agent writes all GDScript based on these principles. All decisions here are locked unless explicitly revised in the Decision Log (Section 20).

---

## 1. Project Overview

Project Unicorn is a narrative-strategy game set in the modern tech startup world. The player founds a startup, navigates discourse and crisis, and attempts to close a Series A round. Tone and depth comparable to CK3, Frostpunk, and Disco Elysium, transposed to a 2020s tech setting.

Core characteristics:

- Text-heavy, event-driven gameplay
- UI-driven — no real-time action, no 3D, no physics
- Continuous time at adjustable speed; roughly 150 in-game days equal 60 to 90 minutes per run
- Replay value through 3 origins, 3 subgenres, and trait combinations
- Turkish and English localization at launch
- Target platform: Steam, Windows primary, Mac and Linux secondary

Companion documents:

- `PROJECT_SPEC.md` — the game design master: vision, mechanics, content, systems
- `CLAUDE.md` at project root — the agent session entry point, references this document
- `CONTENT_GUIDE.md` — event writing voice and character bible, added during the content phase

---

## 2. Tech Stack (LOCKED)

| Layer | Choice | Rationale |
|---|---|---|
| Engine | Godot 4.x, latest stable | 2D and UI focused, lightweight, open source |
| Language | GDScript | Python-like, fast to iterate, well suited to this game type |
| UI approach | Control nodes plus Scene hybrid | Layout in scenes, logic in scripts |
| State management | Autoload singletons plus a signal bus | Godot-native global state, no external library needed |
| Save format | JSON via FileAccess | Human-readable, easy to debug and inspect |
| Localization | Godot built-in localization, CSV-based | Native TR and EN support |
| Steam integration | GodotSteam plugin | Achievements, cloud save, rich presence |
| Version control | Git | The `.godot/` cache folder is ignored; scenes, scripts, and data are tracked |

Deliberately not used:

- C# — GDScript is sufficient and faster to iterate for a UI-driven game
- 3D nodes and physics engines — not needed for this game
- External state management libraries — Godot autoloads cover the need
- Godot visual scripting — deprecated, GDScript only

---

## 3. Development Responsibility Model

### 3.1. Initial phase ownership

The agent has full ownership of all Godot-side work: scene creation, node hierarchy, scripts, editor operations through MCP, scene wiring, signal connections, resource setup, and theme configuration.

The developer reviews, learns, and directs. The developer does not need Godot polish skills at this stage and approves milestones rather than individual operations.

### 3.2. Teaching Mode (ACTIVE)

The developer is learning Godot. The agent is fully responsible for Godot work but must operate as a teacher, not a black box.

For every meaningful operation or logical batch of operations, the agent explains four things:

1. What is being created or changed
2. Why this approach, this node type, this pattern was chosen
3. The underlying Godot concept being used — for example "Autoload singleton", "signal", "Control anchor", "scene instancing" — with a one-line explanation
4. If there was a meaningful choice, what the alternatives were and why this one was selected

Rules for these explanations:

- Concise — two to four sentences per operation or batch, never essays
- Batched — related operations are explained together, not every single node addition separately
- Purpose-focused — the goal is that the developer understands the codebase they own, not a full Godot tutorial
- The developer does not approve every step but should always be able to follow the reasoning

### 3.3. Transition plan

As the developer's Godot fluency grows, responsibility for visual polish — anchors, layout fine-tuning, theme adjustments — gradually shifts to the developer. This is a future transition, not initial scope. The Decision Log records when it begins.

### 3.4. Known limitation — agent scene blindness

The agent manipulates scenes through MCP tools but cannot visually see rendered output. Complex visual layout — anchors, margins, container behavior, responsive resizing — is done without sight and may need correction.

Mitigation:

- The agent explains anchor and layout intent explicitly, per Teaching Mode
- The developer runs the scene and reports visual issues
- The agent corrects based on developer feedback
- For visually critical screens, the agent works in small increments with frequent run-and-check cycles

---

## 4. Project Structure

The project follows a clear separation between scenes, scripts, static data, and assets. The intended top-level layout:

- `project.godot` — Godot project file
- `CLAUDE.md` — agent session entry point
- `docs/` — PROJECT_SPEC.md, TECH_SPEC.md, CONTENT_GUIDE.md
- `scenes/` — all scene files, organized by category: `main/`, `ui/`, `ui/components/`, `tabs/`, `modals/`, `desk/`, `onboarding/`
- `scripts/` — all GDScript files, organized into: `autoload/` (singletons), `systems/` (pure logic), `data_models/` (class definitions), `ui/`, `tabs/`, `modals/` (scripts attached to scenes), and `utils/`
- `data/` — static game content as JSON, organized into: `events/` (with `reactive/`, `industry/`, `scandals/` subfolders), `characters/`, `companies/`, `techtree/`, `news/`
- `assets/` — `illustrations/`, `portraits/`, `icons/`, `fonts/`, `audio/`
- `themes/` — the master Godot theme resource
- `localization/` — CSV localization files

### Structure rules

- New scenes go under `scenes/<category>/`, never in the `scenes/` root except the main scene
- A script attached to a scene mirrors that scene's path under `scripts/`
- Pure logic with no scene dependency goes in `scripts/systems/` — these scripts never reference scene nodes
- Data model class definitions go in `scripts/data_models/`
- Static content goes in `data/<category>/`, as JSON, never hardcoded in scripts
- Autoload singletons live in `scripts/autoload/` and are registered in the project settings

---

## 5. Scene Architecture

### 5.1. Control plus Scene hybrid principle

Layout lives in scenes. Node hierarchy, Control anchors, containers, and positioning are set up as `.tscn` scene files in the Godot editor.

Logic lives in scripts. Game behavior, state changes, and signal handling live in GDScript files attached to those scenes.

A scene's script handles its own UI updates and user input, then communicates with autoload singletons for anything global.

### 5.2. Scene hierarchy

The game shell is a single root scene containing five persistent regions plus a modal layer:

- A top bar anchored to the top, holding the persistent stat strip
- A horizontal container filling the remaining space, which holds the left tab column, the center viewport, and the right actor panel
- A news ticker anchored to the bottom
- A modal layer, kept on a separate CanvasLayer, into which modals are instanced on demand

The center viewport swaps its single child at runtime between the desk view and whichever dashboard tab is active.

### 5.3. Scene instancing pattern

- Tab scenes are instanced when the player opens a tab. Whether they are freed on close or kept hidden is decided during performance testing.
- Modals are instanced into the modal layer on demand and freed when closed.
- Only one event modal is active at a time.

### 5.4. Control anchors and responsive layout

- Container nodes — HBoxContainer, VBoxContainer, MarginContainer, GridContainer — are used for automatic layout. Manual position math is avoided.
- Fixed-width elements such as the left tab column and the right panel use a minimum size combined with anchors.
- The center viewport expands to absorb remaining horizontal space.
- All layout must survive window resizing. See Section 14.

---

## 6. State Management

### 6.1. Autoload singletons

Global state lives in autoload singletons registered in the project settings. They load before any scene and persist for the entire session.

| Singleton | Responsibility |
|---|---|
| `GameState` | Core run state: cash, MRR, brand, reputation, day, phase, origin, subgenre, company name, run seed |
| `CharacterRegistry` | All characters — employees, mentor, NPCs — and their relationships and traits |
| `EventManager` | Event queue, event history, scheduled events, eligibility checks |
| `TimeManager` | Game clock, speed control, tick dispatch |
| `SaveManager` | Save and load orchestration, save slot management |
| `Settings` | Display, audio, language, and mentor-enabled preferences |
| `EventBus` | Global signal hub, see Section 13 |

### 6.2. State access rules

- UI scenes read state from singletons. They never keep their own copy of global state.
- State mutations happen only through singleton methods, never through direct field assignment from outside the singleton.
- Every state mutation that the UI needs to react to emits a signal through the EventBus.
- Singletons never reference scene nodes. They emit signals; scenes listen.

This keeps state flow one-directional and predictable: a system calls a singleton method, the singleton updates its data and emits a signal, and any interested scene updates itself in response.

---

## 7. Data Models

Data models are GDScript classes with a defined class name, located in `scripts/data_models/`. They are plain data containers with light helper methods and have no scene dependencies.

The core models the game needs:

- A game data model holding the core run state values
- A character model holding identity, loyalty, morale, relationship, trust, traits, role-specific stats, salary, equity, and attention flag
- An event model holding id, category, localization keys for title and body, illustration path, optional character context, choices, trigger conditions, cooldown, and one-shot flag
- An event choice model holding label, outcome modifiers, optional conditions, and an optional unlock tier
- A company model for customers, rivals, and investors
- A prospect model for sales leads
- A save file model describing the serialized save structure

### Naming caution

GDScript and the Node class reserve some common names. The reserved name `name` belongs to Node, so character names use a distinct field name such as `character_name`. The agent watches for similar collisions and prefixes fields where needed.

---

## 8. Game Loop Architecture

### 8.1. Time system

Time advances continuously at the speed the player selects. One real second equals one in-game hour at 1x speed, so one in-game day passes every 24 seconds at 1x. Available speeds are pause, 1x, 2x, and 4x.

The TimeManager singleton drives this. On each in-game day it advances the day counter and dispatches a tick to all game systems.

### 8.2. System tick order

Each in-game day, the systems tick in a fixed order because some systems depend on the results of others. The order:

1. Product — build progress
2. R&D — research progress
3. HR — morale and churn evaluation
4. Sales — pipeline and auto-deals
5. Finance — revenue and burn applied last among the economic systems
6. Events — eligibility checks and queue management
7. Industry events — scheduled event checks
8. Phase transition check
9. Endings check — last, because it may end the run

### 8.3. System purity

The system scripts in `scripts/systems/` are pure logic. They read state from singletons and call singleton methods to apply changes. They do not touch scene nodes and do not handle UI. This keeps game logic testable and separate from presentation.

---

## 9. Event System

### 9.1. Event definition

Events are defined as JSON files in `data/events/`, split into `reactive/`, `industry/`, and `scandals/` subfolders. Each event file describes its id, category, localization keys, illustration, optional character context, choices, trigger conditions, cooldown, and one-shot flag.

Keeping events as data rather than code means new events can be written and tuned without touching GDScript.

### 9.2. Event resolution flow

The flow from trigger to resolution:

1. The event tick checks all events against their trigger conditions
2. Eligible events enter the event queue
3. The UI picks the highest-priority event from the queue
4. The event modal opens and game time auto-pauses
5. The player selects a choice
6. The choice's outcome modifiers are applied through singleton methods
7. The event moves to history and game time resumes

### 9.3. Choice modifiers

Each choice carries a list of outcome modifiers — changes to cash, brand, MRR, reputation, a character's morale or trust, or a trait reveal. Modifiers are applied through the same singleton methods any system uses, so the UI updates through the normal signal flow.

### 9.4. Locked choices

Some choices are visible but locked, showing a requirement such as a tier unlock, a skill threshold, or a required trait. Locked choices are shown deliberately — they signal depth and drive replay — but cannot be selected until the requirement is met.

---

## 10. Save and Load System

### 10.1. Format

Saves are JSON files written through Godot's FileAccess. JSON is chosen over Godot's binary resource serialization because it is human-readable, which makes debugging and inspecting save state straightforward.

### 10.2. Structure and location

A save file carries a schema version number, a timestamp, a run id, the full game state, all characters, the event queue and history and scheduled events, UI flags, and settings.

Each save slot is one file. An auto-save updates its own file every few in-game days. Save files live in Godot's user data directory, and when running under Steam they are placed where Steam Cloud expects them.

### 10.3. Schema versioning

The save file carries a schema version. When a breaking change to the save structure is made, the version increments and the SaveManager handles migrating older saves. This is recorded in the Decision Log.

### 10.4. Determinism

The game uses a seeded random number generator. The run seed is part of the saved state, so loading a save reproduces the same random sequence. This makes outcomes reproducible and bugs easier to trace.

---

## 11. UI System

### 11.1. Theme

A single master Godot theme resource defines the look of all Control nodes — colors, fonts, and styles for buttons, panels, labels, and other elements. Individual scenes override the theme only when genuinely necessary.

### 11.2. Design tokens

The visual identity — the warm sepia and amber palette, the editorial serif and grotesk sans typography — is defined once in the theme resource and the project's style constants. Scenes reference these tokens rather than hardcoding colors or fonts.

### 11.3. Layout regions

The persistent UI regions are the top stat bar, the left tab column, the center viewport, the right actor panel, and the bottom news ticker. Modals and critical alerts render on a separate canvas layer above everything else.

### 11.4. Progressive disclosure

The interface defaults to summary views and reveals detail on hover or click. This keeps the strategy-game depth accessible rather than overwhelming, which is a core design pillar.

### 11.5. Visual hierarchy

Critical alerts — low cash, a fired scandal, a key employee resignation — stand out through accent color and subtle motion. In the normal state the whole interface stays calm and muted.

---

## 12. Naming Conventions

| Item | Convention | Example |
|---|---|---|
| Scene file | PascalCase, `.tscn` | `EventModal.tscn` |
| Script file | snake_case, `.gd` | `event_manager.gd` |
| Autoload singleton script | snake_case file, PascalCase singleton name | file `game_state.gd`, singleton `GameState` |
| Data model class | snake_case file, PascalCase class name | file `game_event.gd`, class `GameEvent` |
| System script | snake_case | `finance_system.gd` |
| Data file | snake_case, `.json` | `ev_047_lunch_with_mira.json` |

Identifier prefixes for content:

- Event ids: `ev_` followed by a number and a slug
- Character ids: `char_` followed by a slug
- Company ids: `co_` followed by a slug
- Trait ids: `trait_` followed by a slug
- Tech ids: `tech_` followed by subgenre and slug
- Ending ids: `end_` followed by a slug

Variable and function naming follows standard GDScript style: snake_case for variables and functions, PascalCase for class names, ALL_CAPS for constants. Booleans are prefixed with `is_`, `has_`, or `can_`.

---

## 13. Signal Architecture

### 13.1. The EventBus pattern

A dedicated autoload singleton, the EventBus, acts as a global signal hub. Singletons and systems emit signals on the EventBus; scenes connect to those signals to update themselves.

This decouples state from presentation. A singleton that changes cash does not need to know which scenes display cash — it emits a signal, and any scene that cares is listening.

### 13.2. Signal categories

The EventBus carries signals in clear categories:

- State change signals — cash changed, brand changed, day advanced, phase changed
- Event signals — event triggered, event resolved, modal requested
- Character signals — morale changed, relationship changed, employee churned
- UI signals — tab changed, notification raised

### 13.3. Connection rules

- Scenes connect to EventBus signals when they enter the tree and disconnect when they leave it, to avoid dangling connections
- Systems emit signals; they do not connect to them
- Direct node-to-node signal connections are fine for local interactions within a single scene; the EventBus is for cross-scene and global communication

---

## 14. Resolution and Display Support

### 14.1. Target and supported resolutions

The primary design target is 1920 by 1080. The game supports the full range of standard modern resolutions: 1280 by 720 as the minimum, through 1366 by 768, 1600 by 900, 1920 by 1080, 2560 by 1080 ultrawide, 2560 by 1440, 3440 by 1440 ultrawide, and 3840 by 2160. Supported aspect ratios are 16:9 as primary, plus 16:10, 21:9, and 32:9, with the interface letterboxing or anchoring panels to edges on the widest ratios.

### 14.2. Settings menu display options

The settings menu offers a resolution dropdown populated from the OS in fullscreen mode, a display mode choice of fullscreen, borderless, or windowed, a UI scale option ranging from 80 percent to 200 percent, a V-Sync toggle, and a frame rate cap.

### 14.3. Scaling strategy

The UI is built vector-first — scalable Control layouts, scalable typography, and SVG icons where possible — so it scales cleanly across resolutions. Raster artwork is authored at a high master resolution and downscaled per display. The layout is a fluid grid with minimum and maximum constraints rather than pixel-perfect fixed positioning.

### 14.4. Responsive breakpoints

Below 1366 pixels wide the interface enters a compact mode where the right panel collapses into a drawer. From 1366 to 1920 it uses the standard layout. From 1920 to 2560 it uses a more comfortable layout with additional breathing room. Above 2560 it expands, surfacing extra detail and larger artwork. On ultrawide ratios the center stage extends while the side panels stay anchored to the edges with maximum-width caps.

### 14.5. Godot project settings

The project's stretch settings are configured to scale the canvas while keeping aspect, so Control layouts adapt to the window rather than distorting. Exact stretch mode and scale settings are tuned during implementation and recorded in the Decision Log.

---

## 15. Performance Budgets

| Metric | Target |
|---|---|
| Cold start to playable | Under 3 seconds |
| Frame rate | Stable 60 fps |
| Memory footprint | Under 300 MB |
| Save or load operation | Under 200 ms |
| Modal open animation | Under 300 ms |
| Tab switch | Under 100 ms |

These are not stretch goals. Strategy players tolerate depth but not jank.

---

## 16. Steam Integration

Steam features are provided through the GodotSteam plugin.

- Achievements — a set of roughly 12 to 15 achievements for the MVP, unlocked through gameplay milestones
- Cloud save — save files sync through Steam Cloud; the SaveManager writes them where Steam expects
- Rich presence — the player's current day, phase, and MRR are surfaced as Steam status

The Steam integration is isolated behind the SaveManager and a thin Steam wrapper, so the rest of the game does not depend directly on the plugin and the game remains runnable without Steam during development.

---

## 17. Testing Strategy

For a solo project with agentic development, automated testing is minimal and focused. Manual playtesting carries most of the balance and feel validation.

What must have automated tests:

- Financial calculations — burn, revenue, runway
- Skill and charisma rolls — deterministic given a seed
- Phase transition logic
- Save and load round-trip integrity
- Event eligibility — trigger condition evaluation

Everything else is validated through manual playtesting. The agent writes tests for the critical-logic items above as those systems are built.

---

## 18. Localization

The game ships with Turkish and English at launch. Turkish is the canonical authoring language since the writer works in Turkish first; English is a literary translation held to the same quality bar.

All player-facing strings are externalized into Godot's CSV-based localization files under `localization/`, split into UI strings, event strings, and character strings. No player-facing text is hardcoded in scenes or scripts.

Turkish text runs roughly 20 to 30 percent longer than English, so layouts use flexible widths rather than fixed ones. Date and currency formats are locale-aware.

---

## 19. Agentic Workflow

### 19.1. Session entry

At the start of every session the agent reads `CLAUDE.md`, `PROJECT_SPEC.md`, and this document. The agent does not write gameplay code until the relevant specs are understood and locked.

### 19.2. Spec-driven development

Work proceeds spec-first. Before implementing a feature, the agent confirms the design intent against PROJECT_SPEC.md and the technical approach against this document. If either is unclear or missing, the agent asks rather than guessing.

### 19.3. MCP usage

The agent uses the Godot MCP connection to perform all Godot-side work — creating scenes, managing nodes, editing scripts, wiring signals, running scenes for verification. Because the agent cannot see rendered output, it works in small increments on visually critical screens and relies on the developer to run and report.

### 19.4. Teaching Mode

Every session operates in Teaching Mode as defined in Section 3.2. The agent explains what, why, the Godot concept, and the alternatives — concisely and in logical batches.

### 19.5. Drift control

On long sessions the agent re-grounds itself against the specs periodically. Per-directory convention notes may be added in hot zones — scenes, autoloads, systems — to reinforce local conventions. If a session runs long, the agent restarts fresh with a spec re-read rather than drifting.

### 19.6. Scope discipline

The agent stays strictly within the scope defined in PROJECT_SPEC.md. It does not invent features, mechanics, or content. If something seems missing or underspecified, it flags the gap rather than filling it independently.

---

## 20. Decision Log

Architectural decisions and their changes are appended here with date and reason.

| Date | Decision | Reason |
|---|---|---|
| Initial | Engine: Godot 4, language GDScript | Developer's long-term goal is to become a game developer and learn an engine; Godot suits a UI-driven 2D game and is AI-fluent |
| Initial | UI approach: Control nodes plus Scene hybrid | Layout in scenes, logic in scripts — clean separation, editable in the Godot editor |
| Initial | State: Autoload singletons plus signal bus | Godot-native, no external dependency |
| Initial | Save format: JSON via FileAccess | Human-readable and debuggable |
| Initial | Agent has full Godot ownership, Teaching Mode active | Developer is learning Godot; agent works as a teacher, not a black box |
| 2026-05-14 | Stretch mode `canvas_items` + aspect `expand`, base 1920×1080, min window 1280×720 | Vector-first scaling (§14.3) without ultrawide letterboxing — center viewport flexes, side panels stay anchored at fixed widths. Min window enforced at runtime via `Window.min_size`. |
| 2026-05-15 | Day 1 starts at 09:00 in-game (business-day-start convention); subsequent days start at 00:00 | Founder atmosphere — first day kicks off with the business day, not midnight. Trade-off: Day 1 runs 15 in-game hours (15s @ 1x) instead of full 24h. Alternative (display offset so every day reads 09:00) rejected as scheduling bug magnet — day number would desync from midnight rollover. TimeManager holds `INITIAL_HOUR = 9`; GameState owns `current_hour` (§6.1). |
| 2026-05-15 | Onboarding flow architecture — `Main.tscn` instances `OnboardingFlow.tscn` first; `GameShell` only mounts after `GameState.initialize_run(payload)` completes. Single state-write seam shared by flow Confirm and F12 debug skip. Mentor seeded into `CharacterRegistry` defensively via `ensure_mentor()` during initialize_run (idempotent with existing `_seed_debug_characters`). Tree paused from `main.gd._ready()` via `EventBus.speed_change_requested.emit(0)`; unpaused on mentor modal `dismissed` signal. | TopBar/RightPanel paint from GameState in `_ready()` — mounting them before populated state would flash "Unicorn Inc." defaults then re-paint. Alternative considered (overlay onboarding on top of pre-instanced shell) rejected because every shell child would need an "uninitialized" branch and TimeManager would tick against placeholder state. Disabled-card recipe for "Coming Soon" options: `mouse_filter = MOUSE_FILTER_IGNORE` + `focus_mode = FOCUS_NONE` + `modulate.a = 0.45` — beats `Button.disabled = true` which forces Godot's generic disabled stylebox. |
| 2026-05-15 | Event System Foundation pipeline — `EventManager` autoload holds `_all_events` dict + `_queue` + `_history` + `_active_event_id`. JSON-driven content load from `data/events/reactive/*.json` at `_ready`. `daily_tick` slot 6 (after Finance) walks all loaded events, filters by `trigger_conditions` + cooldown + one_shot history, queues eligible sorted by priority desc. `is_condition_met` is the public single-vocabulary evaluator reused by both event triggers and choice `unlock_condition`. `_apply_modifiers` routes every effect through `GameState`/`CharacterRegistry` setters so existing EventBus signals (cash_changed, morale_changed, etc.) drive UI updates one-way. `EventModal.tscn` mounted into `GameShell/ModalLayer` by `main.gd` on `EventBus.modal_requested(event)`; closed on `event_resolved(id, idx)`. Backdrop click does NOT dismiss — player must pick. RNG: bare `randf()` against the global seed set by `GameState.initialize_run` per §10.4. | Pipeline before content — real Event Pool is content-phase work (PROJECT_SPEC §6 World & Drama still TBD). Autoload over RefCounted system because state spans days (queue, history, loaded dict); RefCounted pattern (Finance/HR/Sales) is reserved for stateless per-tick logic. JSON over .tres so future event writers don't open Godot. EventManager has no scene dependency — emits `modal_requested` for a deferred consumer (main.gd); pattern repeats for any future system that needs to ask the UI for something. RNG migration cue: when a second system needs RNG, introduce a `RandomNumberGenerator` instance on GameState seeded from `run_seed` to avoid bare-randf sequencing coupling between systems. Three debug events (`ev_debug_001`/`002`/`003`) exercise the full vocabulary (character context, no context, day+random trigger, cash_below threshold, one_shot, cooldown, locked choices via mirror-shape `unlock_condition`, all five modifier types). |
| 2026-05-16 | UI overhaul tab list — `["product","hr","finance","sales","ops","rnd","personal","events"]` (8 tabs) defined in `scripts/theme/ui_tokens.gd` `UiTokens.TABS`. `EventBus.tab_changed` comment updated to match. | Supersedes PROJECT_SPEC §5.5-5.7 which marked Operations / Dashboard / External as TBD. The UI overhaul mini-spec defines the canonical Bootstrap-to-MVP tab set: `ops` renames `operations` (clarity), `rnd` replaces `dashboard` slot (Dashboard's content folds into TopBar plus per-tab dashboards), `personal` replaces `external` (founder personal track), `events` is a new slot for the events log. Tab IDs are the canonical strings broadcast via `EventBus.tab_changed`; renaming them is a one-time breaking change taken now while no other code consumes the old ids beyond `center_viewport.gd` (also updated). Designer may revise during content phase. |
| 2026-05-16 | Calendar anchor — **Day 1 = Wednesday, January 1, 2025**. `GameState.START_DATE`, `MONTH_ABBR`, `DOW_ABBR` constants plus `get_display_date()` derived getter built on `Time.get_unix_time_from_datetime_dict` + offset. TopBar `DayLabel` reads `"Wed, Jan 1 · 09:00"` format via `_update_day_label()`. | Picked because Jan 1 2025 is a real-world Wednesday so day-of-week renders correctly with no offset hack. Godot built-in date math is deterministic and adds zero dependencies. Derived getter pattern matches the existing `get_runway_months`/`get_daily_revenue`/`get_net_daily_flow` family — date is never stored, always computed from `day` field. |
| 2026-05-16 | Working palette + glyph tokens in `scripts/theme/ui_tokens.gd` (`class_name UiTokens extends RefCounted`) — colors (`ACCENT` amber, `TEXT_PRIMARY` cream, `TEXT_MUTED` tan, `TEXT_DIM`, `POSITIVE`, `NEGATIVE`, `BADGE_BG`), font-size scale (`SIZE_STAT_LABEL` 9 / `SIZE_STAT_VALUE` 15 / `SIZE_STAT_DELTA` 10 etc.), tab glyphs (`▣ ◉ $ ↗ ◇ ⚡ ★ ●`), and the canonical `TABS` definition. | Working-placeholder pass. `themes/master_theme.tres` stays empty; a designer pass migrates the constants into the Theme resource later in one place. Existing inline `.tscn` `Color()` literals are left untouched and migrated only when surrounding lines change. Values used (amber `Color(0.91, 0.733, 0.471, 1)`, cream `Color(0.96, 0.91, 0.82, 1)`, tan `Color(0.78, 0.722, 0.612, 1)`, dim `Color(0.56, 0.494, 0.396, 1)`) are working choices, not locked. Constants file over Theme resource because GDScript consts can be referenced from script code with full IDE autocomplete while .tscn nodes still receive inline literals (Godot cannot import constants into scene resources at parse time). |
| 2026-05-16 | Spec #1: MVP build flow + event engine vocabulary extensions + cap table derived getter. `ProductSystem` at slot 1 (`RefCounted` + static, pattern-matching `FinanceSystem`) with static `active_build: FeatureBuild`. MVP build defaults: 12 in-game days, 2-3 components (min 2 max 3 of 4-card subgenre palette), founder auto-assigned, quality baseline 50. Ship moment is narrative-only: sets `flags["mvp_shipped"] = true` + `flags["product_quality"] = quality` (the persistent product-quality memory future Sales/Pitch systems will read) + `flags["mvp_components"]` (cached for `PostShipView` display), clears `active_build`. **MRR / cash / brand / reputation deltas do NOT occur on ship.** Economic outcomes are reserved for played decision moments per the narrative-strategy design principle — ship is a world-state shift, not a revenue event. Ship moment is a code-built synthetic `GameEvent` injected via new `EventManager.enqueue(event)` method — first non-JSON event path. `ProductTab` has three swappable subtrees (ComponentSelectionView / BuildProgressView / PostShipView); PostShipView is an intentional dead-end for Spec #1 — Find Prospects / Hire / Pitch are later specs. Event engine extensions: `GameState.flags: Dictionary` + `set_flag`/`get_flag`/`has_flag` (no signal emission — flags are read at next eligibility eval, not pushed to UI); new modifier types `set_flag` / `add_character` (idempotent on duplicate id) / `speed_bonus` / `quality_bonus` / `ship_active_build`; new condition types `flag_equals` / `flag_set` / `build_state` / `mvp_shipped`; intra-priority-tier shuffle replaces single `sort_custom` in `EventManager.daily_tick` (uses global seeded RNG per §10.4). Cap table founder equity is derived (`GameState.get_founder_equity = 1.0 − sum(employee equity_pct)`, clamped `[0,1]`) matching the `get_runway_months` derived-getter family. `RightPanel.CapTableSection` repaints on `EventBus.character_added` / `character_removed`; an `EmployeesWithEquityRow` surfaces a count of employees holding equity. Time-pause flow change: mentor dismiss no longer auto-unpauses (`main.gd._on_modal_dismissed`); `ProductTab` emits `speed_change_requested(1)` after successful build commit (manual TopBar unpause remains an escape hatch). `center_viewport.gd` introduces a `TAB_SCENES` preload map and frees / mounts the mapped scene on `tab_changed`, hiding the placeholder `Content` VBox when a real tab scene is active (only `product` ships in Spec #1; other 7 tabs continue using the title-paint placeholder). | Establishes the player's first interactive moment as MVP component selection rather than implicit. Honoring the narrative-strategy principle: ship is a world-state shift unlocking future decision moments, not a revenue event. Synthetic-event-via-enqueue keeps the ship moment routed through the existing `EventModal` flow without authoring a JSON file for what is fundamentally a system-triggered cinematic. Forward-compat on `FeatureBuild` (`equity_impact` / `revenue_share` / `tags` / `quality_modifiers`) mirrors `Character`'s reserved-field pattern; `mrr_potential` field omitted from the model because no economic delta is computed from a build. Bundles the cofounder-event vocabulary so Spec #2 ships content-only without touching the engine. |
| 2026-05-16 | Design philosophy codified: PROJECT_SPEC.md §1 gains explicit positioning ("Software Inc., but the founders are people"); Micro-to-macro player evolution promoted from sub-bullet to primary pillar; new §1.5 Tier Interaction Model section added (Tier 1/2/3 action vocabularies table); §5.1 Product rewritten with 3-level hierarchy (subgenre → sub-product type → features) and 3-phase build flow (iteration / development / polish) per Software-Inc-informed redesign; new §10 Economic Outcome Principle section added (every economic delta requires upstream played decision moment); root CLAUDE.md gains Governing Design Principles preamble as session-entry reading. | Strategic discussions across recent chat sessions clarified design DNA. Codification ensures every future agent session reads canonical philosophy as ground truth before reading any spec. Implementation specs that contradict these principles will be revised; the principles override. |
| 2026-05-16 | Spec #2: MVP build refactor to canonical 3-level hierarchy + 3-phase build. Sub-product type catalog (10 sub-types across AI/SaaS, 5 each) + per-sub-type feature pools (5-7 features each) hardcoded in `scripts/systems/product_catalog.gd`. `FeatureBuild` extended with `current_phase` / `iteration_duration_days` / `polish_duration_days` / `polish_days_remaining` / `bug_count` / `min_estimation_days` / `sub_product_type_id` / `feature_ids`. `ProductSystem.daily_tick` becomes phase-aware (`iteration` → `polish` → `shipped`). Iteration phase reads `GameState.get_founder_skill("tech")` for daily quality growth + bug accumulation. Ship-Early Decision Modal at iteration end (archetypal startup choice — visual weight intentional, separate scene from `EventModal`). Two new modifier types (`commit_to_polish_phase`, `commit_to_ship_early`) and three new condition types (`founder_skill_min`, `build_phase`, `bug_count_above`). All existing Spec #1 vocabulary preserved. Ship moment remains narrative-only per §10 Economic Outcome Principle — `commit_to_ship_early` sets `flags["shipped_rushed"]` and routes through the same flags-only `_trigger_ship_moment` from Spec #1; no economic delta. | Aligns implementation with canonical PROJECT_SPEC §5.1 (post-GDD codification). Player now lives through Software-Inc-grade product development cycle with narrative weight: pain-point framing → sub-product choice → feature pick → duration commit → daily quality emergence → ship-or-polish moment. Sub-product type catalog ships as code constants; JSON externalization to `data/products/` is content-phase work. |
| 2026-05-16 | Spec #3 (Product Tab v3): consolidated `DesignDocumentView` replaces the Spec #2 three-step planning wizard. One screen, three columns — LEFT (Product identity + iteration duration as compact rows, not cards), CENTER (feature grid 2-col), RIGHT (live projection panel: 8 stat rows + mentor advisory). `CommitBar` enables on valid plan (type + 2-4 features + duration). `BuildProgressView` and `PolishProgressView` redesigned: full-width build header, two-column body with phase-segmented progress bar + development feed (left) and status panel + mentor mini (right). New `ProductSystem` static helpers `forecast_quality_ceiling` / `forecast_bug_risk_band` / `forecast_ship_day` — pure read-only projections of existing iteration/polish tick constants (`BASE_QUALITY_GROWTH`, `TECH_QUALITY_MOD`, `BASE_BUG_RATE`, `TECH_BUG_MOD`, `POLISH_QUALITY_BUMP_PER_DAY`, `POLISH_BUG_FIX_PER_DAY`). New `commit_to_ship_from_polish()` method ships mid-polish *without* setting `flags["shipped_rushed"]` (rushed = iteration-end decision only; shortening polish is a different, lighter choice). `ProductCatalog.SUB_PRODUCT_TYPES["ai"][0].pitch` revised for application-layer framing (player builds apps on top of AI infra, never trains foundation models). `PostShipView` untouched; `FeatureBuild` schema and `ProductSystem` build logic untouched; no economic delta on ship (§10 preserved). | Spec #2 shipped functional mechanics in a barren wizard — three near-empty screens, ~900px-tall duration cards, build progress as four lines of floating text. Software Inc.'s Design Document is the explicit visual reference: choices and projected consequences co-visible on one dense surface. Forecast helpers stay next to the system that owns the real logic so forecasts auto-track formula changes. Mid-polish-ship vs iteration-end-rushed-ship separation preserves the narrative weight of the iteration-end choice (a true commitment moment) while letting the player trim polish without semantic consequence. No new mechanics — pure UX surface upgrade. |

---

*End of Tech Spec. For game design questions, see `PROJECT_SPEC.md`. For session entry and agentic workflow, see `CLAUDE.md`.*
