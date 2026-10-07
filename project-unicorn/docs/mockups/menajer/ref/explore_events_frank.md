**Report: event/inbox pipeline and Frank portrait (read-only investigation)**

Root: `C:/Users/erdem/Desktop/project steam/project-unicorn/`. All paths below are relative to it. Nothing was written, edited or run that changes state.

---

## TASK A: How events reach the player today, and what an inbox needs

### A1. The pipeline, end to end
1. **Entry.** There is one way in: `EventGate.request(id, ctx)` (`scripts/events/event_gate.gd:16-17`), which calls `EvEngine.request` (`scripts/events/core/engine.gd:541-556`).
   - If this instance's paper is already on the desk, the paper is opened instead (`engine.gd:544-548`).
   - Otherwise `EvGate.propose` runs, then `_admit`, then `_step_assign_classes`, then `pump()`.
   - Ticks call `EventGate.daily_tick` / `hourly_tick` (`time_manager.gd:360`, `:386`). The daily order is steps a–l (`engine.gd:57-73`): paper expiry, flag expiry, arc invalidation, schedule, arc steps, signal drain, sweep, pool, floor, class assignment, pump.
2. **Admission.** `_admit` (`engine.gd:374-393`):
   - **A paper is never queued.** It goes to `EvPapers.place` with an absolute expiry tick (`engine.gd:379-383`, `present/papers.gd:22-33`).
   - Interrupts and info cards go to `EvQueue.admit` (`core/queue.gd:33-45`).
   - The latch is spent at admission.
3. **Tempo.** `EvTempo.assign` (`present/tempo.gd:37-77`):
   - An interrupt over the per-tick ceiling is demoted to paper, never dropped (invariant I4, `tempo.gd:66-72`).
   - It is pulled out of the queue onto the desk (`engine.gd:357-360`).
   - Cards tagged critical, terminal_warning, or that are arc steps are exempt and never demoted (`tempo.gd:100-102`).
4. **Show.** `pump()` (`engine.gd:414-438`):
   - Does nothing while a card is active or while `TimeManager.is_batching()` is true (meeting skip or night).
   - When a batch ends, `clock_batch_ended` re-pumps (`events/core/signals.gd:44-46`).
   - Order is §11.2 over the whole queue: terminal → expiring → critical → interrupt → paper → info → ambient, ties broken by admitted day then id (`queue.gd:19`, `:56-89`).
   - Each card is revalidated at show time. If it fails, it is dropped silently and history records `dropped` (`engine.gd:427-433`).
   - `_announce` emits `event_triggered` and `modal_requested(EvPresenter.build_view(...))` (`engine.gd:444-446`).
5. **View.** `EvPresenter.build_view` (`present/presenter.gd:34-68`):
   - Builds a throwaway `GameEvent`. Text is resolved only here, in the live locale.
   - `character_id` is the card's `speaker`, otherwise the employee/founder in scope (`presenter.gd:50-51`, `:100-105`). Customer cards have no person, so they get no avatar.
   - Each option carries its `requires` lock, its locked reason, and its effects (used only for chips).
6. **Mount.** `main.gd` connects `modal_requested` to `_on_event_modal_requested` (`scripts/main/main.gd:1879`, `:1912-1934`):
   - During the founder's trip (`_in_transit`) the card is deferred via `_card_waiting` and shown on return (`main.gd:1913-1915`, `:2088-2090`).
   - Otherwise it stores `_pre_event_speed`, emits speed 0, and instances `EventModal.tscn` into `GameShell/ModalLayer` (CanvasLayer 10; `scenes/main/GameShell.tscn:65-66`).
   - It refuses to stack a second card (`main.gd:1925-1931`).
7. **Modal build.** `scripts/modals/event_modal.gd`:
   - Full-rect dimmer `SCRIM_MODAL` that stops the mouse (`:78-83`); centred 780-wide `ModalCard` (`:87-94`).
   - Header: source chip from `_source_tag` (`:196-216`) plus "KARAR · {date}" or "ÖZET · {date}" (date only, no hour; `:158-160`). A trailing `· HH:MM` subtitle has its hour rewritten live (`:178-188`).
   - Serif title and body; speaker strip with a 24 px avatar, name · role, relationship pill and two traits (`:221-241`, `:247-263`).
   - Choice cards with effect chips from `_describe_modifier` (`:357-422`). Unlabelled fiiller (effect verbs) are covered by `SILENT_VERBS` (`:19-23`).
   - Locked options show at 50 % alpha with the live reason first, the authored reason as fallback, then `LOCK_CHIP` (`:330-340`).
   - Footer `EVENT_CHOICE_PERMANENT` = "Seçim kalıcıdır · Oyun duraklatıldı" (`localization/strings.csv:1520`). It is hidden for a readout, i.e. one option with no modifiers (`event_modal.gd:133-148`).
   - `process_mode = 3` (`scenes/modals/EventModal.tscn`).
   - **There is no close or cancel path.** A click calls `EventGate.resolve` (`:344-349`).
8. **Resolve.** `EvEngine.resolve` (`engine.gd:452-507`):
   - Final scope check, effects (dice through `run_check_branch`), then `EvHistory.record`, `EvPapers.remove`, `clear_active`, arc advance.
   - `event_resolved` is emitted before the next `pump()`.
   - `main._on_event_resolved` frees the modal. It gives the speed back only if `!has_pending()`, no term table is open and nothing is in transit; the summary modal restores its own speed (`main.gd:1937-1949`, `_restore_speed` at `:1907-1909`).

### A2. Pause behaviour
- **Speed 0 pauses the tree.** It is not `hold_clock` (`time_manager.gd:292-303`); NewsTicker is ALWAYS so it keeps scrolling (`:13`).
  - Space and 1–4 are swallowed while ModalLayer has children (Guard 2, `scripts/main/game_shell.gd:66-69`). Esc never reaches the system menu over a card (`main.gd:2196-2197`).
  - `hold_clock` / `release_clock` swallow every speed > 0 request (`time_manager.gd:297`, `:307-314`). Today only the milestone paper (`main.gd:2351`) and the product release note (`tabs/product_tab.gd:254`) use it.
- **Saving is blocked while a card is active** (`autoload/save_manager.gd:68-78`). The queue is saved; the active card is not. A blocked autosave retries on `event_resolved` (`save_manager.gd:331-333`). A load always comes back paused (`time_manager.gd:283-287`).
- **Cards opened from a meeting choice** (term table): the surface inherits the card's speed (`main.gd:1952-1957`).
- **Milestone paper** sits under an active card (`main.gd:2356-2360`).
- **Terminal end:** `EvQueue.flush` drops queued cards; the active card resolves normally (`queue.gd:178-182`).
- **Period summary modal** pauses at speed 0 and restores itself (`main.gd:2304-2323`).
- **R&D cards** mount on PanelLayer (layer 9) **without pausing** (`main.gd:2217-2236`).

### A3. Queueing, and "timed" decisions
- One card is on screen at a time (GDD engine §11.3, `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md:822-830`). The rest wait in `EvQueue`. `EvQueue.admit` counts absorbed duplicates (`queue.gd:33-37`).
- **No decision is timed in real time** ("No countdown", `event_modal.gd:6-7`; no timer, countdown or seconds field in any live card). Time limits are in weeks:
  - Paper expiry uses an absolute `expires_on` (`papers.gd:27-29`).
  - In a paper's last week (if its life is more than 1 week) it is re-queued as a budget-exempt interrupt (`engine.gd:120-130`, `papers.gd:61-94`).
  - On expiry: `on_expire` runs, history records `expired`, and `expire_note` goes to the ticker (`engine.gd:91-117`).
- **Live content is 32 cards** (excluding `_fixtures` and `unwired`): 23 interrupt, 5 paper, 1 info.
  - Papers: customer expansion and the three request cards, `funding.seed_stalled`, `world.final_stretch_press`.
  - Info: `sales.weekly_summary`.
  - Interrupt: the remaining 26. 16 live cards have Frank as speaker. Most are single-option beats: `frank_approach_*`, `door_open`, `office_move`, `gate_traction`, `hire_nudge`, `seed_door`, `seed_closed`, `sheet_expiry`, `shutter_warning`, `last_answer`, `final_stretch_verdict`. Almost all are `critical`, so never demotable.
- **Other non-engine "timed" things:**
  - Term sheets: validity 3 weeks; desk reminder plus TopBar offer chip (`top_bar.gd:182`); `funding.sheet_decision` is hourly and critical.
  - VC call: rings in the office and can be postponed once (`main.gd:1983-1991`, `:2033-2039`).
  - Acquisition card window: 1 week.

### A4. The Olaylar tab today
- `scripts/tabs/events_tab.gd` (77 lines) in a fixed 900×640 window (`ui/components/window_layer.gd:27-28`). It shows a title, a "Frank'ten not" section (`EVENTS_FRANK_HEADER`) and a "MASADA" list (`EVENTS_DESK_HEADER`, empty text `EVENTS_DESK_EMPTY`; `strings.csv:164`, `:2619-2620`).
- **Frank section:** only the single latched line `GameState.mentor_line_key` / `mentor_line_args` (`events_tab.gd:44-49`; `autoload/game_state.gd:297-306`). It has no avatar.
- **There is no event log or history.** No UI reads `EvHistory`; the only readers are `endings_system.gd:501` (`telegraph_fired`) and the probe.
  - ch11 §6 asks for this: "Run history becomes readable (today it is written and never read)".
  - ch12 §9 still lists "whether the events log lives in Kişisel or in the right panel" as an open decision.
- **Rail badge:** `EventGate.queue_size()` (`ui/components/left_tabs.gd:13`, `:138-139`).
  - **Defect:** papers are never queued (`engine.gd:379-381`) and the queue drains straight into a modal, so the badge is about 0 even when the desk is full.
  - It refreshes only on `event_triggered` and `event_resolved`, not on `day_tick_completed`, which is when papers land.

### A5. Desk papers and notice cards
`scripts/ui/components/desk_papers.gd` is the single home for desk rows; it gives each row a dot, a tag, a title and weeks left (`:69-85`). There are two kinds of paper:
1. **Engine papers** come from `EventGate.desk_papers` → `EvPresenter.desk_papers` (`presenter.gd:115-129`).
   - Fields: id = instance key, title, category, `weeks_left`, `expiring`.
   - A click calls `EventGate.open_paper`, which revalidates, `mark_opened`, sets the card active and announces it, so time stops (`engine.gd:585-601`).
   - **Defect against GDD §11.4** ("kapatıldığında masaya döner", i.e. when closed it returns to the desk): an opened paper has no close button, so the player must decide.
   - `EvPapers` already stores `opened_before` and `admitted_day` (`papers.gd:18-33`, `:48-50`), so a read flag exists but is not exposed.
2. **Derived reminders** have no clock; a click goes to the owning tab (`desk_papers.gd:26-52`):
   - Phase gate ready → Finance.
   - Active term sheets, with weeks left or `HUNT_DECISION_DUE` → Finance / yatirim.
   - Atlas candidate files ready → HR.
   - Each B2B account in lifecycle "expansion" → Sales. This can duplicate the `customer.expansion` paper card.
- **B2B risk and HR flight risk are not desk rows.**
  - B2B risk shows as the Sales rail badge (`b2b_sales_system.gd:322-328`) plus the `customer.retention` interrupt, triggered by the `customer_health_changed` signal.
  - Flight risk shows as the HR badge (`hr_system.gd:406-419`, `hr_ui_shared.gd:136-139`) plus `team.resignation` after `RESIGN_WINDOW` (`hr_morale_system.gd:316-327`).
- **Refresh signals** for both surfaces: `desk_papers.gd:59-64`.
- **Office notice stack** (`ui/office/office_notice_stack.gd`): bottom-right, 340 wide, at most 4 cards plus a "+N" badge that turns amber if a hidden card is expiring (`:9-10`, `:50-81`). Frank's line comes first, with an **initials avatar** (`:59-60`); clicking it opens the Events tab.
- **Text defect:** the TR `DESK_PAPER_GATE_TITLE` contains "—" (`strings.csv:146`); this is open item ACIK 68 (`docs/ACIK_ISLER/ACIK_KARARLAR.md:1438-1449`).

### A6. Non-decision channels
- **Ticker.**
  - `NewsFeedSystem`: 3–5 lines per week, sektör / rakip / biz split 50/30/≤20, `STREAM_CAP` 30, `BIZ_BUFFER_CAP` 10. When the buffer is full the newest line is dropped (`systems/news_feed_system.gd:27-38`, `:151-171`, `:305-311`).
  - The state lives in `GameState.news_feed` and is saved, but lines are **resolved text frozen in the language they were emitted in** (`:309`).
  - The strip (`ui/components/news_ticker.gd`) keeps the 6 newest live lines (`:41`, `:75-81`). `ticker_live_line` lines are shown once and never archived (`:14-20`).
  - `headline_added` emitters:
    - HR: training done, leave, back from leave (`hr_system.gd:98`, `hr_morale_system.gd:46`, `:250`).
    - Atlas files ready (`hr_search_system.gd:277`).
    - Newsworthy signing (`sales_ledger.gd:241`).
    - Product press line (`sprint_bridges.gd:164`; it stores `{key, args, outlet}`, which is the language-safe pattern).
    - Engine `ticker_push` / `notify` (`effects.gd:384-400`).
  - `ticker_live_line` emitters: month close and runway threshold (`summary_system.gd:85-91`), rival launch (`sprint_bridges.gd:136`), "Nasıl geçti?" after a meeting (`office_travel.gd:97`).
- **EvTicker `held`.** Player-outcome lines `{day, key, text}` (`events/present/ticker.gd:11-26`) are saved (`core/save.gd:33`) but **never read by any UI**. GDD §18.1 says the ticker is never the only channel.
- **SummarySystem.**
  - The payload is built at slot 0 and emitted at slot 10 (`systems/summary_system.gd:55-93`). Fields: title, range, MRR/cash/team/brand from→to, runway, highlight, footer, `frank_line` (`:175-202`, rules `:238-254`).
  - **The payload is not persisted.** `month_history` (numbers) is, so monthly rows could be rebuilt.
  - `MonthSummaryModal` has a Frank row with a 40 px "FK" initials avatar (`scenes/modals/MonthSummaryModal.tscn:109-147`).
- **Frank beats that are not decisions:**
  - `MentorIntroModal` on a new run only (`main.gd:1853-1860`): 48 px "FK" initials (`MentorIntroModal.tscn:55-70`, `strings.csv:533`), `MENTOR_NAME` / `MENTOR_ROLE`, `MENTOR_INTRO_*`.
  - The `mentor_advisory` fiil latches a single line (`effects.gd:462-467`; used by `frank_intro` and `paid_tier`; also `vc_pitch_system.gd:864`). **There is no list of past advisories.**
  - Frank lines are also embedded in surfaces:
    - Hunt title strip (`tabs/hunt_tab.gd:11`, `:71`, `:85`)
    - Finance mentor card (`tabs/finance/finance_ozet_view.gd:431-442`, `:755-769`)
    - Term table monologue (`modals/term_sheet_table_scene.gd:230-233`, `:334`)
    - VC meeting "quiet" result line (`ui/meeting/vc_meeting_adapter.gd:145-154`)
    - Ending strip (`modals/ending_scene.gd:193-204`)
  - The 12 single-option Frank interrupts in A3 are beats too.
- **Info card defect.** The `sales.weekly_summary` card's `_doc` says it "doesn't stop time", but class `info` goes to `EvQueue` (`engine.gd:384`), so it mounts as a **pausing modal** (`data/events/cards/customer/weekly_summary.json`; raised from `sales_rep_system.gd:246-260`).
- **R&D:** discovery card and first monthly note on PanelLayer (`main.gd:2217-2253`). Only the latest note is kept (`rnd_system.gd:489-500`, `:589-616`).
- **Toasts:** VC postpone (`ui/office/meeting_invite.gd:90-96`, `:172-190`), office move (`ui/office/office_hud.gd:57-62`, `:105-114`), ending share (`ending_scene.gd:399-403`).
- **TopBar chips:** offer countdown, shutter, sprint auto-start (`ui/components/top_bar.gd:30-31`, `:173-199`).

### A7. What an inbox needs

**Row sources that exist today:**

| Row kind | Source | Persisted? | Gaps |
|---|---|---|---|
| Pending decision (active) | `EventGate.active_card()` (`event_gate.gd:56-60`) | Not savable while active | Must block like today |
| Pending decision (queued) | `EvQueue.entries()` (`queue.gd:150-151`) | Yes | No sender, no preview |
| Waiting papers | `EvPapers` (key, event_id, context, expires_on, admitted_day, opened_before) | Yes | `desk_papers` drops sender, preview and the read flag |
| Reminders | `DeskPapers.gather` | Derived | No timestamp, no read state |
| Past decisions and outcomes | `EvHistory.rows()`: `{event_id, day, resolution chosen/expired/dropped, option_id, outcome_id, entities, deltas, arc_id}` (`core/history.gd:28-48`, no pruning) | Yes, ids only | See risks below |
| Player-outcome lines | `EvTicker._held` | Yes | Text frozen, no context |
| News | `NewsFeedSystem.get_stream()` (30 newest, `:176-181`) | Yes | Text frozen in emission language; live-only lines never stored |
| Summaries | `month_history` | Numbers only | Payload not stored |
| Frank lines | `mentor_line_key` | Last line only | No history |
| R&D note | `RnDSystem` | Latest only | No history |

Rendering risks for past-decision rows:
- **Departed people and customers are erased** (`character_registry.gd:548-556`, `customer_registry.gd:124`), so `_display_name` falls back to the raw id (`presenter.gd:80-97`).
- **`{seam:…}` in a body resolves live**, so re-rendering an old body shows today's numbers (`presenter.gd:177-199`).
- `deltas` have a per-fiil shape and need a new describer. `_describe_modifier` reads unresolved effects and the active context (`event_modal.gd:429-432`).
- The comment that the ending screen reads deltas (`history.gd:40-41`) is stale.

**Persistence and schema:**
- **Persistence options:**
  - A new `GameState` var is saved automatically by `SaveCodec`, which finds script vars (`systems/save_codec.gd:180-215`). It needs a meaningful default and a reset in `initialize_run` (as in `game_state.gd:843-844`).
  - Extra keys in the engine block load through `.get` defaults. `EvSave.BLOCK_VERSION` 1 refuses a mismatch (`core/save.gd:16-17`, `:44-48`).
  - Changing the history row shape is a motor §7.1 / §16.1 change, so it needs a §27 note.
  - `SaveManager.SCHEMA_VERSION` 15 / `MIN_LOADABLE_VERSION` 10 (`save_manager.gd:16`, `:23`). A bump is needed only if old saves are backfilled through `_migrate_16`, for example building an inbox from `EvHistory`.
  - A static store must be added to `reset_all_owners` (`save_manager.gd:245-278`).
- **Language law:** store ids, keys and args, never text (CLAUDE.md §5). Converting headline emitters to `{key, args}` changes the `headline_added(source, text)` signal (`event_bus.gd:219`).

**Rules an inbox must keep:**
- **Engine invariants I1–I7** (`GDD… rev 2.md:39-51`):
  - I1: single gate, so the inbox can only display; it must never build or apply cards.
  - I2: economic change only from a played choice.
  - I3: no loss without a telegraph.
  - I4: nothing is dropped; demotion is interrupt → paper only.
  - I5: triggers stay in card data.
  - I6: dice never kill.
  - I7: every modifier has a named seam behind it.
- **§11.1** (`:793-799`): interrupt = blocking, time stops; paper = time flows; info = badge or report; ambient = ticker.
- **§11.3** (`:822-830`): one modal at a time; ALWAYS process mode; no card shown during a batch.
- **§11.4** (`:831-837`): weeks left visible; last-week highlight only when life is more than 1 week; daily cards never show an hour; an opened paper returns to the desk when closed.
- **§12.1** (`:866-870`): only things with a clock are papers; information goes to a tab or the ticker.
- **§12.4** (`:899-916`): no silent expiry.
- **§18.1**: the ticker is never the only channel.
- **CLAUDE.md §5 / ch11:**
  - Every option has a visible cost; costless only for an explicit beat.
  - Locked options stay visible with a reason that does not state its own wisdom.
  - No tab or UI instructions in card text; going somewhere is the `goto_tab` fiil and chip (`event_modal.gd:41`).
  - Verdicts only in Frank's mouth.
  - Chips only from `_describe_modifier`.
  - Bilingual keys; no dashes.
- **ch14 §7:** the large Frank modal is retired; Frank uses the same card grammar as everyone.
- **Canon** (`docs/content/events_draft/Frank Diyalogları · v6.md:634-640`): Frank's channel is "mesaj ve telefon". This supports mail.

**Architectural traps if the decision opens inside a WindowLayer window instead of ModalLayer:**
- WindowLayer windows deliberately keep the speed keys alive (`window_layer.gd:5-7`), so a `hold_clock("event")` is needed.
- Esc goes to `close_top` and the rail switches tabs (`window_layer.gd:58-73`). An active interrupt must survive that.
- Saving stays blocked while `active_id` is set.
- Closing a paper needs a new engine API, e.g. `clear_active` without writing history.
- The trip veil (`set_veiled`) and `_card_waiting` path, milestone ordering and `_restore_speed` state machine must still work.

**Smoke pins on these surfaces:**
- `event_modal.gd` is loaded by path in smoke for `_source_tag` (`debug/endgame_smoke.gd:3516`), `_describe_modifier` (`:10743`) and `SILENT_VERBS` (`:13458`).
- `main._event_modal` (`:11276-11313`).
- `EventGate.desk_papers(8)` is read in several cases.

---

## TASK B: Frank's portrait, how others are portrayed, and a pre-render pipeline

### B1. Frank's identity and every place he is drawn
- **Created in** `CharacterRegistry.ensure_mentor` (`autoload/character_registry.gd:396-408`):
  - id `char_mentor_frank`, name `MENTOR_NAME` = "Frank Köseoğlu" (`strings.csv:1559`), role "Operating Partner" (`:470`, `:1560`).
  - **No `look`.**
  - `portrait_path = res://assets/art/investors/portrait_frank.webp`: a painted 1408×1760 RGB image (same size as the founder images), lossless, no mipmaps (`.webp.import`). Per `character.gd:19-23`, only Frank carries `portrait_path`.
- **Draw sites:**
  - **Painted portrait used only here:** the event-modal speaker strip, a 24 px circle (`event_modal.gd:247-263`; source chip MENTOR at `:210`).
  - **Initials "FK":** MentorIntroModal 48 px (`MentorIntroModal.tscn:55-70`), MonthSummaryModal 40 px (`MonthSummaryModal.tscn:114-130`), office notice stack (`office_notice_stack.gd:59-60`).
  - **Text only, no face:** Events tab (`events_tab.gd:21-27`), Hunt strip, Finance mentor card, term table, VC result line, ending strip (`ending_scene.gd:193-204`, tag `ENDING_FRANK_TAG`).
  - No scene references the asset (grep over scenes); only `character_registry.gd:407` does.
- **Save compatibility:** Frank's record is serialised with the registries (`save_codec.gd:254-273`). On restore `ensure_mentor` is skipped (`game_state.gd:870-881`), so **old saves carry the old `portrait_path`**.
  - If the file is moved or renamed, old saves fall back to initials (`event_modal.gd:249`).
  - It needs a load-time overwrite (next to `fill_missing_looks`, `save_manager.gd:237`) or a constant instead of a per-save path.
- **Docs that pin the painted portrait:**
  - GUNCELLEMELER ch14 §7: "Boyalı kurucu portresi, Frank ve VC yüzeyleri değişmez" (`GDDs/GUNCELLEMELER.md:375-378`).
  - ACIK 94: "Frank'in portresi kaldı" (`ACIK_KARARLAR.md:1222-1229`).
  - HARITA: `assets/art/investors/ (Frank'in portresi)` (`docs/HARITA.md:192`).
  - ch14 §7 docx: "Frank has a portrait".

### B2. How everyone else is portrayed
- **Founders:** 11 painted webp files (`assets/art/founders/founder_01..11.webp`, 1408×1760).
  - Used on the Kişisel page (`personal_tab.gd:203-205`) and in onboarding through `DialoguePortraitCard` (260×325, 4:5; `ui/components/dialogue_portrait_card.gd`; `character_step.gd:90`, `:128`; `company_step.gd:186`).
  - In 3D the founder is hand-matched to the chosen painting via `LookSystem.FOUNDER_LOOKS` (`systems/look_system.gd:19-44`, `:103-104`). This is ACIK 92 (`ACIK_KARARLAR.md:1549-1555`).
- **Employees and candidates:** 3D busts through `UiFactory.make_person_avatar` → `PersonBust.texture(look, px)` (`theme/ui_factory.gd:101-141`). Sizes in use: 24, 30, 32, 34, 44 (hr_ledger, assignments, atlas, training, dossier).
- **VCs and prospects:** from the meeting-flow task. `CounterpartSystem` gives each fund 3 people (lead / partner / analyst), drawn once and saved in `GameState.investor_people`; prospect people are drawn from the id each time.
  - Looks are kept apart from the people around them but **not issued** (`systems/counterpart_system.gd:4-11`, `:31-37`, `:64-81`).
  - Shown as busts in the meeting panel (96 px, `ui/meeting/meeting_panel.gd:24`, `:530-542`) and on the term table (64 px, `term_sheet_table_scene.gd:17`, `:96-105`, `:305`).
  - The four painted fund portraits were deleted (ACIK 94).

### B3. What a "look" is, and can Frank have one
- **A look is a dictionary** `{sex, head, body, legs, feet, skin, hair, top, top2, tie, bottom, shoe, height, girth, glasses}` with only bools, ints and strings (`look_system.gd:48-68`).
  - Parts come from `PeopleParts` (`systems/people_parts.gd`).
  - `signature()` is the sorted key=value string (`:123-126`). Uniqueness is checked against `GameState.issued_looks` and the people around (`:83-98`). `_stamp_look` registers it (`character_registry.gd:524-531`).
- **Frank can have a fixed look**, like `FOUNDER_LOOKS`:
  - Jacket style (`m_suit` body, legs, feet; `people_parts.gd:111-114`), tie palette (`:147`).
  - Grey hair is hair palette index 7, `#8f8a85` (`:139`). `m_king` has a white-hair head with the crown dropped (`:22`); `m_worker` has a moustache (`:23`).
  - Glasses are built in code (`office_body.gd:24-29`).
  - **Uniqueness:** reserve Frank's signature, either in `LookSystem._unique` or registered at run start plus a backfill on load. Otherwise an employee or counterpart could match him exactly; counterparts only check `around`.
- **License:** Quaternius Ultimate Modular Men/Women 2022 plus UAL1/UAL2 and Mesh2Motion, all CC0 per the bundled texts in `assets/art/people/LICENSES/`. No attribution needed (`assets/art/people/README.md`). Memory notes the quaternius.com site has said QAL v1.0 since 2026-08-28, but the archived package text is CC0.

### B4. Existing render tools and their limits
- **`PersonBust`** (`scripts/ui/office/person_bust.gd`) is an in-game off-screen studio:
  - SubViewport with its own world, transparent background, MSAA 4×.
  - Orthographic camera: `FRAME` 0.5 m tall, `TURN` 0.42, `RISE` 0.12, `HEAD_DROP` 0.03; pose `ual1/Idle` @0.4 s; noon light from `OfficeLighting.CS` (`:11-22`, `:49-89`).
  - The office ink quad uses `cutout = true` and `vignette = 0` (`:77-89`).
  - `SUPERSAMPLE` = 2 (`:11`); one render per frame; cached by look@px.
  - **Returns null when headless** (`:35-37`). It writes to an ImageTexture, never to disk.
  - Output is **premultiplied alpha**; `avatar_bust.gdshader` un-premultiplies and masks the circle (`scenes/ui/components/avatar_bust.gdshader`).
  - Body: `OfficeBody.build` with `office_toon` (`outline_only`, vertex colour; `ui/office/office_body.gd:44-60`; shader `scenes/office/shaders/office_toon.gdshader`).
- **Ink width is fixed in screen pixels:** `uniform float texel = 1.15` (`scenes/office/shaders/office_ink.gdshader:15`, used `:69`). The depth threshold adapts (`:84-85`); line width does not.
  - At the 96 px × 2 = 192 px maximum used today the outline is fine. At 512–1024 (rendered at 1024–2048) it becomes a hairline.
  - **A large render must scale `texel` with render size.** It is never overridden today.
- **Founders sheet:** `--office-shot=<office>:<hour>:founders` lays the 11 paintings beside their busts at 88 px (`main.gd:667-760`, `:732-733`; `debug/office_crowd_probe.gd:18`, `:227-242`). It is a screen-grab to user:// via `_save_shot` (`main.gd:477-480`), not an asset exporter.
- **Other tools, none of which export portraits:**
  - `tools/office3d/` is the Three.js → GLB office export (Chrome, esm.sh; `tools/office3d/README.md`); no portrait or bust code in `src/*.js`.
  - `tools/people/` contains `fix_rig.py` and `setup_import.gd` for rig and import only.
  - `sandbox/ui_lab/` (untracked) is the theme lab plus `docs/audits/UI_OVERRIDES.md` (an override inventory useful for the redesign).
  - **No existing tool writes a bust PNG into `res://`.**

### B5. What a pre-rendered Frank pipeline would look like
1. A fixed `FRANK_LOOK` constant next to `LookSystem.FOUNDER_LOOKS`.
2. A tool script under `tools/people/` modelled on `bake_nav.gd`'s `-s` driver. It must run **windowed**, because the studio is null when headless. Windowed runs go one at a time (CLAUDE.md §12).
   - It reuses the PersonBust setup with a 4:5 frame (to match `DialoguePortraitCard` / the old 1408×1760 format if used large), scaled `texel`, chosen pose and turn.
   - It saves straight-alpha PNG, or premultiplied if it will still go through `make_bust`.
3. Asset home: `assets/art/investors/`, or rename the folder and update `character_registry.gd:407` / HARITA.
   - Import settings: lossless, and decide on mipmaps. Godot's default LINEAR canvas filter never samples mips unless the node uses `LINEAR_WITH_MIPMAPS`; mips over-blur at 0.3–0.5 scale. `make_bust` forces `TEXTURE_FILTER_LINEAR` (`ui_factory.gd:133`).
   - So either export per-size PNGs (24/40/48/64/96 at 2×, plus a large hero image) or a large image plus mipmaps plus a filter override.
   - Re-renders rewrite `.import` to defaults, so check the sidecars.
4. A README row (source look, tool, date, sha256) like `assets/art/people/README.md`. The CC0 parent licence already sits in `LICENSES/`.
5. A save fix for the stale `portrait_path` (B1).
6. Retire `portrait_frank.webp` in the same commit (CLAUDE.md §8). Update GUNCELLEMELER ch14 §7, ACIK 94, HARITA:192 and the `character.gd:19-21` comment.
7. Decide what replaces the "FK" initials (`UI_AVATAR_INITIALS`) at 40/48 px and the text-only Frank strips.

### B6. Is Frank ever a 3D character?
**No.**
- The office draws only the founder plus `employees_by_hire` (`ui/office/office_people.gd:556-560`).
- Meetings stage counterpart looks plus the founder (`ui/office/meeting_cast.gd:57-63`; `office_travel.gd:66`).
- Frank has no look.
- Canon rule "Frank sahnede görünmez" (`ACIK_KARARLAR.md:1710-1714`; `Frank Diyalogları · v6.md:634-640`): the scene never shows him; his channel is message and phone.
- A pre-rendered portrait used as a message sender fits that rule. A 3D Frank in the office or meeting room would break it.