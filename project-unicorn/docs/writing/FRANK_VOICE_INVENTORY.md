# FRANK VOICE INVENTORY — every place Frank speaks or is quoted in the shipped build

**Phase 1 of the Frank Voice Pass. Read-only. No prose here.** One table row + one block per occurrence; the block's job is the **world-fact whitelist**: what the engine can prove at the instant the line fires. Anything not on a whitelist cannot appear in that scene's prose; anything a scene would need but the engine cannot guarantee is flagged `[COND?]`.

Snapshot: working tree at `1867213` (branch `localization-phase2`), 2026-08-19. A concurrent Build Bar session is editing `localization/strings.csv`, `scripts/autoload/event_manager.gd`, `scripts/modals/event_modal.gd`, `scripts/systems/product_system.gd` today; line numbers are as of this read. The shipped text itself is **not reproduced** (ruling 1: it is not a reference); each row carries the key and a gist of the line's job only.

**Definition used.** "Frank speaks" = the line is in Frank's mouth or the card/strip is rendered as his (speaker `char_mentor_frank`, a Frank-captioned strip, a Frank-attributed advisory). Name-plates, ledger rows, effect chips, and other characters talking *about* Frank are excluded and listed in §4.

**Aphorism ledger (Phase 2, 2 per run, endings exempt):** spent 0 / 2.

---

## 0. Global facts every whitelist inherits

**Calendar (real, provable).** `GameState.START_DATE = {2026, 1, 1}`; `GameState.day` counts from 1; `get_date_dict(for_day)` returns Godot's datetime dict including `weekday` (`scripts/autoload/game_state.gd:10-13, 504-511`). So **Day 1 = Thursday 1 January 2026**; the year advances; months are real (28/30/31). Anchors: day 32 = Sun 1 Feb · day 60 = Sun 1 Mar · day 91 = Wed 1 Apr · day 121 = Fri 1 May · day 152 = Mon 1 Jun · day 180 = Mon 29 Jun 2026. Strings: `DOW_0..6` (Paz/Pzt/Sal/Çar/Per/Cum/Cmt), `DATE_LINE {dow}, {day} {mon} {year}` (`strings.csv:380-387`), months `MONTH_1..12`.
**Weekday is provable but NOT guaranteed visible:** the top bar prints it only at logical width ≥ 1600 (`scripts/ui/components/top_bar.gd:107 COMPACT_BELOW := 1600`, `:239-241`, `:249-250`); below that the clock is `{day} {mon} · {hour}:00`. Rule for prose: a weekday is a fact the player may never have seen → every use is `[COND?] weekday visible at this viewport`, or it stays out of Frank's mouth.

**Hour.** Day 1 starts at 09:00 (`time_manager.gd:45 INITIAL_HOUR := 9`); every later day starts at 00:00. **Every daily-tick beat fires while `current_hour == 0`** (`time_manager.gd:115-143`: `set_current_hour(0)` → `_dispatch_hourly_tick(0)` → `advance_day()` → `_dispatch_daily_tick()`). There are no minutes (`event_modal.gd:178-181`). ODA room lighting at hour 0 is **night** (`scripts/ui/oda/oda_view.gd:832-842`); an active overtime block forces night at any hour. Hourly ambients know the real hour; none of the Frank occurrences below is an hourly ambient, so **no Frank scene has a usable hour except the two ship moments and the design-round intro (hourly product seams, hour = the real hour)**.

**Daily slot order** (`time_manager.gd:245-279`): 1 Product · 2 R&D stub · 3 HR · 4 Sales · 5 Rivals · 6 Finance · **7 EventManager (JSON beats)** · 8 News · **9 Angel (8a)** · **10 PhaseGate (8)** · **11 VC (8b)** · **12 Endings (9)** · **13 MonthSummary (10)**. `enqueue_front` does not mean front: the first enqueue of the day mounts immediately and owns the modal; later ones queue behind (`time_manager.gd:344-355`, `event_manager.gd:804-816`). The month-summary modal stacks **on top of** an open event modal (`main.gd:2160-2169`). Every modal mount stops the clock (`main.gd:1951` etc.); a load always comes back paused (`time_manager.gd:206-214`).

**Modal chrome.** Event modal header = `KARAR · GÜN {day}` (day only, `event_modal.gd:163-166`, `strings.csv:1661`); footer `Seçim kalıcıdır · Oyun duraklatıldı`. Subtitle: only a ` · HH:MM` tail is rewritten to the live hour (`_live_subtitle`, `event_modal.gd:178-206`); every synthetic Frank card sets `subtitle = ""`; the three JSON Frank beats carry clock-free subtitles. Source badge: tags win over speaker (`event_modal.gd:209-226`): `endgame` → PİYASA, `phase_gate` → MENTOR, `ship_moment` → ÜRÜN, else `char_mentor_frank` → MENTOR. **Angel offer, shutter, pivot, acquisition cards therefore read PİYASA though Frank speaks.**

**Identity.** Frank Köseoğlu (`MENTOR_NAME`, proper noun, identical both locales), role label "Operating Partner" in both locales (`HR_ROLE_MENTOR`, `strings.csv:446`), id `char_mentor_frank`, category `mentor`, salary 0, equity 0 until the angel round (`character_registry.gd:270-289`). Name + role are printed at boot (`mentor_intro_modal.gd:15-20`) and on every Frank speaker strip (`event_modal.gd:241-254`) → **the player knows his full name and title from minute one.** Frank is excluded from `get_employees()`, payroll, and the month-summary "Ekip" count. `res://assets/art/investors/portrait_frank.webp` does not exist; FrankPopup renders "FK" initials (`frank_popup.gd:125-127`).
Founder: `founder_name` is optional and may be `""` (renders as "Kurucu"/"Founder", `game_state.gd:812-817`) → **Frank can never be sure of the founder's name.** Company name is required and non-empty (`company_step.gd:210-214`). Origin is always `self_made` (Sıfırdan / Self-Made) in the demo; the other two are locked (`founder_constants.gd:56-72`); starting cash $10.000; `subgenre` defaults `"ai"` and means nothing until a build starts.

**Never a fact anywhere:** weather, season, minutes, named neighbourhoods (live subtitles are rooms/channels: Mutfak masası, Masa başı, Yatak odası, Ofis, Telefon, Mesaj, E-posta, Akış, Kasadar bildirimi…), character schedules (the hourly schedule slot is `pass`, `time_manager.gd:402-404`), `departures` and `scandals_*` counters (always 0), `hard_mode_unlocked` (no writer), trait effects (stored, unconsumed), leadership skill reads. Canon proper nouns you may use: Vitrin (the showcase platform of the Product Hunt analogue), Kasadar (payment provider), Ekonomi Postası · TeknoGündem · Girişim Bülteni · Sektör Telgrafı (outlets), Atlas Seçme & Yerleştirme (HR agency), the four VC names.

**Always provable when Frank speaks:** `day`, date dict, `current_hour`, `cash`, `mrr`, `daily_burn`, net daily flow, runway months, `brand`, `reputation`, `phase`, `company_name`, `origin`, `CustomerRegistry.get_active().size()`, `CharacterRegistry.get_employees().size()`, every `FLAG_TYPES` key (`game_state.gd:58-130`), the `run_*` ledger counters (`game_state.gd:530-589`), `shutter_days_left`, `vc_rejections`, `active_sheets` / `pending_meeting`, HR search state, `mvp_*` product flags once a build exists.

**Surface class 3 — confirmation cards.** A card that confirms a decision the player already made (they walked to the button; the card appeared) carries no choice, so it carries no scene. Ceiling: 3 lines including the option. Row 4 is the reference. Distinct from scenes (a real decision) and standing strips (repeated status). Emotional weight does not license length.

### Render risks and copy-vs-engine defects found while reading (ranked; none fixed here)
1. **MentorIntroModal double-mounts on every new run and mounts on save load.** `main.gd:1874-1882` instantiates it after `await _mount_shell()`, which already instantiates it at `:1924-1926`; `_load_slot` goes through `_mount_shell()` at `:2147`. Regression from `6edace1` (2026-08-08); the comment at `:1885-1889` says the opposite of what the code does.
2. **`END_META_*_FRANK` (7 ending verdicts) has no surface.** Built into `ending_data.frank_line` (`endings_system.gd:241, 356-357`) but `EndingsCopy.build` sets every subhead from its own `END_*_SUB*` key; `frank_line` is read only in the unknown-id fallback (`endings_copy.gd:53-66`) and `ending_scene.gd:509` fallback. The ending screen has no Frank voice.
3. **`ev_sheet_expiry_warning` uses one id for up to two sheets** (`vc_pitch_system.gd:435`, `SHEET_WARN_ID :23`, `MAX_SHEETS 2`): two sheets at `days_left == 3` on the same day → the second warning is dedupe-dropped silently.
4. **The mentor-advisory latch is not persisted** (`oda_view.gd:115`, no to_dict); a load rebuilds the shell → the phone dot and the Events-page "Frank'ten not" vanish.
5. **`ev_mvp_iter_decision_intro` option 1 is now a no-op** (Build Bar tree: `product_system.gd:1396-1397`, `advance_iteration` retired): a two-option card where one option changes nothing.
6. **Blind terminal/irreversible choices** (no effect chip): pivot decline ends the run, acquisition accept ends the run, "Bugün değil" forfeits the meeting, first-ship "Yayınla" publishes the product (`event_modal.gd:526` returns `{}` for those types).
7. **`mentor_line` / `mentor_choice` are never set by any live event** → the MENTOR TAVSİYESİ tab and mentor quote row never render.
8. **Copy asserts facts the engine does not guarantee:** `END_EV_ACQ_BODY` "cuma akşamı" (fires at hour 00 on any weekday); `ev_ps_b2c_paid_tier` "birkaç yüz kişi" (gate is audience > 15); `HUNT_FRANK_LINE` "dört masa" (`CASCADE_TABLES := 3`, roster 5 incl. one locked); `FIN_MENTOR_QUOTE` "altı ay" hardcoded in words (`RUNWAY_WARN_MONTHS` is a constant elsewhere).
9. The angel hire nudge (priority 3) can take the modal ahead of a priority-10 gate the same morning (slot 8a before 8; the queue never re-sorts a pumped card).

Counts: **26 occurrences** (variant families counted once) · **7 with NO SURFACE** (the seven `END_META_*_FRANK`) + 3 dead CSV twins and 7 unrendered ending titles listed in §4 · **38 `[COND?]` flags** (§2, one per bullet).

---

## 1. Inventory table (run-chronological)

| # | key / id | surface | trigger (file:line) | moment | function | options | render risk |
|---|---|---|---|---|---|---|---|
| 1 | `MENTOR_INTRO_BODY` (+ `MENTOR_INTRO_CTA`) | boot modal `MentorIntroModal.tscn` | onboarding `completed` → `_swap_to_shell_and_modal`, `main.gd:1865-1882`; also F12 `:2410`, Shift+F4 `:2440` | the player has just named the company, picked a portrait and a skill spread; the clock is paused at day 1, 09:00; nothing has been built | Frank's first word: why he is here and what the founder must do alone | 1 (`Hadi başlayalım`), no state | **double-mount on new run; fires on save load** (`:1924-1926`, `:2147`) |
| 2 | `PROD_MENTOR_LINE` | cream Frank strip in the product path picker, `creation_flow.gd:217-218, 283-310` | first visit to the B2C/B2B path step while flag `product_path_frank_seen` is false | the player is choosing between Kitle (B2C) and Kontrat (B2B) for the first build | Frank frames the one irreversible choice without picking | 1 (`UI_OK`) → `set_flag product_path_frank_seen` | none; never returns after the flag (persisted) |
| 3 | `PROD_EV_ITER_DECISION_BODY` (`ev_mvp_iter_decision_intro`) | EventModal | end of design round 1, `product_system.gd:568-579` (hourly `_tick_build_hourly :511-516`), latch `_iter_intro_shown :179` | the first design round has just completed; round 2 has already started when the card renders | Frank explains that rounds return less each time and people matter more than rounds | 2: `PROD_ITER_KEEP_GOING` → **no modifiers**; `PROD_TO_DEVELOPMENT_PLAIN` → `enter_development` (chip `Geliştirme başlar`) | **option 1 is a no-op** (Build Bar tree); `one_shot` inert (injected), real latch serialized; fires mid-build by design; real hour available |
| 4 | `PROD_EV_FIRST_SHIP_BODY` (`ev_mvp_ship_moment`) | EventModal | launch seam `_trigger_ship_moment(false)`, `product_system.gd:977, 1306-1308`; build `:1338-1362` | the first build finished its phases; the player pressed Ship | the first version goes live with Frank watching; the next job (a payer) is named | 1: `PROD_SHIP_PUBLISH` → `ship_active_build` (**no chip**) | badge reads ÜRÜN not MENTOR (`ship_moment` tag); `one_shot` inert; real hour available |
| 5 | `PROD_EV_VERSION_SHIP_BODY` (`ev_mvp_version_ship_moment`) | EventModal | same seam with `is_version = true`, `:1311-1335` | a v2+ build just shipped | Frank marks growth and warns of new surface | 1: `PROD_SHIP_CONTINUE` → `ship_active_build` (no chip) | fires once per version ship by design |
| 6 | `ev_ps_frank_intro_b2b` (`data/events/reactive/ev_ps_frank_intro_b2b.json`) | EventModal | daily beat slot 7; `mvp_shipped ∧ market_type b2b`, one_shot | the B2B product has just shipped; there may be no customer and no lead yet | Frank opens the first door: a lead from his own network | 1 → `add_prospect{mid, frank_intro}` (chip `Yeni aday`) + `mentor_advisory` (no chip, raw TR) | hour 00; `_history` serialized so no refire on load; the lead's name is unknown until the choice resolves |
| 7 | `ev_ps_b2c_paid_tier` (`data/events/reactive/ev_ps_b2c_paid_tier.json`) | EventModal | daily beat slot 7; `market_type b2c ∧ audience_above 15`, one_shot | the free audience just passed fifteen people; no price is set | Frank says it is time to charge | 1 → `mentor_advisory` only (no chip; **no `open_paid_tier`**) | body claims "birkaç yüz" at audience > 15; not gated on tier-not-open (unprovable); hour 00 |
| 8 | `ev_ps_first_revenue` (`data/events/reactive/ev_ps_first_revenue.json`) | EventModal | daily beat slot 7; `mrr_above 0`, one_shot | the first dollar of MRR has just appeared | the first-revenue beat: "you are a company now" | 1 → `mentor_advisory` only (no chip) | **same-day collision with the Traction gate** is near-guaranteed (both need MRR > 0); this card wins the modal, the gate queues behind; hour 00 |
| 9 | `ev_phase_gate_traction` (`GATE_TRACTION_TITLE`, `GATE_TRACTION_BODY_0`, `GATE_TRACTION_BODY_1`, `GATE_TRACTION_BODY_2`, `GATE_ADVANCE`, `GATE_DECLINE`) | EventModal | slot 8 `phase_gate_system.gd:94-122`; `mvp_shipped ∧ customer_count_min 1 ∧ mrr_above 0`; re-prompt every 5 days `:125-134` | first customer and first MRR exist; the player is asked to change gear | the phase gate: Frank asks whether it can be done again | 2: `GATE_ADVANCE` → `advance_phase` (no chip); `GATE_DECLINE` → `phase_gate_decline` (no chip, no penalty) | variant = `gate_declines` clamped to 2 (three bodies); held while shutter runs; can stack behind #8 / #10 / #11 the same morning; hour 00 |
| 10 | `ev_angel_frank_seed` (`ANGEL_EVENT_*`, `ANGEL_CHOICE_*`) | EventModal | slot 8a `angel_round_system.gd:61-70, 112-119`; `mvp_shipped ∧ mrr_above 2499`; latch `angel_seed_offered` before enqueue | MRR has just crossed $2.500 for the first time; the company still runs on the founder's money | the cheque: $25.000 for 4 %, asked once | 2: `KABUL` → `angel_accept` (chip cash + equity, accent); `REDDET · ZOR MOD` locked on `hard_mode_unlocked` (no writer) | badge reads PİYASA; can collide with the Traction gate (angel wins by slot); hour 00 |
| 11 | `ev_angel_hire_nudge` (`ANGEL_NUDGE_*`) | EventModal + HR rail badge | slot 8a `:73-89`; `angel_seed_accepted_day > 0 ∧ day ≥ +2 ∧ employees == 0`; latch `angel_nudge_shown` | two days after taking the cheque, still alone | Frank's nudge to hire | 1: `Bakacağım`, no modifiers | priority 3 can take the modal ahead of a p10 gate; HR search may already be open (not checked); burned silently if a hire happened; hour 00 |
| 12 | `ev_phase_gate_series_a` (`GATE_SERIES_A_TITLE`, `GATE_SERIES_A_BODY_0`, `GATE_SERIES_A_BODY_1`, `GATE_SERIES_A_BODY_2`, `GATE_ADVANCE`, `GATE_DECLINE`) | EventModal | slot 8; `mrr_above 4999 ∧ brand_above 24` (`phase_gate_system.gd:43-46`) | MRR ≥ $5.000 and brand ≥ 25 for the first time; the hunt can open | the Series A gate: the clock starts | 2 as #9 | as #9; `_BODY_2` is byte-identical to the Traction `_BODY_2` by design |
| 13 | `MONTH_FRANK_SHUTTER`, `MONTH_FRANK_BURNING_BUT_SELLING`, `MONTH_FRANK_SHRINKING`, `MONTH_FRANK_GOOD`, `MONTH_FRANK_ANOTHER` | MonthSummaryModal `%FrankLine` (FK avatar row) | slot 10 on the 1st of each calendar month (`month_summary_system.gd:28-38`); selector `:112-127` | the month just closed; the summary is on screen | Frank's one-line verdict on the month | none (modal's own DEVAM ET) | first-match order shutter → burning-but-selling → shrinking → good → another; stacks on top of any event modal the same tick; suppressed if a terminal fired today |
| 14 | `FIN_MENTOR_QUOTE` (+ `FIN_MENTOR_WARNING`, `_WRAPPED`) | Finance › Özet mentor card, `finance_ozet_view.gd:346-366, 595-606` | runway < 6.0 months and not snoozed | the player opened Finance with thin runway | Frank's runway warning | 1: `FIN_SNOOZE` → flag `finance_runway_warn_snooze_until_day = day + 14` | "altı ay" hardcoded in words; returns when the snooze expires if still thin |
| 15 | `PROD_TIP_BUGS`, `PROD_TIP_WEAK`, `PROD_TIP_GOOD` | Product Detail Frank strip (`QuoteSerif`), `detail_view.gd:337-339, 557-558`; selector `product_ui_shared.gd:109-116` | every repaint of Product Detail after ship | the player is looking at the live product's numbers | Frank's standing read of the product (bugs → rival → fine) | none | repainted constantly; `PROD_TIP_WEAK` names the **quality** passer, not the share neighbour |
| 16 | mentor-advisory latch (`ODA_EVENTS_FRANK_HEADER` "Frank'ten not" + the advisory text) | ODA phone dot + Events page quote, `oda_view.gd:115, 661-663, 1040-1057`, `center_viewport.gd:139-150` | `EventBus.mentor_advisory_changed` from the `mentor_advisory` modifier (#6, #7, #8) or `VC_CALLBACK_REOPENED` (`vc_pitch_system.gd:463`) | after one of those cards resolved | Frank's last sentence waits on the phone | none | **lost on load**; advisory texts live as raw TR literals in JSON (no `_en`); overwrites the Hunt strip (#17) |
| 17 | `HUNT_FRANK_LINE` | Hunt tab title-bar strip, `hunt_tab.gd:28, 51-57` | Hunt tab open (phase 3) | the hunt is open, the player is on the Hunt page | standing one-liner about the tables | none | "Dört masa" vs `CASCADE_TABLES := 3`; reverts to default on tab rebuild; overwritten by any advisory |
| 18 | `DEAL_PROMPT_LINE` (+ `_SIT`, `_VALIDITY`, `_DEFER`) | **FrankPopup** (`scenes/modals/FrankPopup.tscn`), `main.gd:2297-2344` | `EventBus.sheet_granted` ∧ `phase ≥ 3` ∧ sheet exists ∧ no other modal/scene up | a VC has just handed over a term sheet | Frank on the phone: sit now or pocket it and shop | 2: `open_table` → `term_table_requested`; `defer` → nothing (sheet keeps ticking) | not persisted (a pending prompt is dropped by save); `_deal_prompt_vc` routing hazard S3-40; portrait asset missing (FK fallback) |
| 19 | `TERM_FRANK_WON`, `TERM_FRANK_RESISTED`, `TERM_FRANK_LAST_MOVE`, `TERM_FRANK_OTHER_TABLE`, `TERM_FRANK_NO_TABLE`, `TERM_FRANK_OPENING`, `TERM_FRANK_NEXT_MOVE` | TermSheetTableScene Frank label, `term_sheet_table_scene.gd:320` | state machine `term_sheet_table_system.gd:270-291` over `_state` | the player is at the negotiation table | Frank's whisper over the levers | none (commentary) | 7 variants; `{lever}`/`{investor}` filled; no trigger latch |
| 20 | `VC_EV_MEETING_BODY` (`ev_vc_meeting_prompt`) | EventModal (Frank-tagged) | slot 8b `vc_pitch_system.gd:476-483`; `pending_meeting` day reached; `prompted` latch | the meeting day the player booked has arrived | Frank says go in; the investor's archetype line is quoted inside | 2: `VC_EV_ENTER_MEETING` → `start_vc_meeting` (no chip); `VC_EV_SKIP_MEETING` → `decline_vc_meeting` (**no chip**, forfeits) | body quotes the investor (`{line}` = `INV_ARCH_*`), so two voices on one Frank card; removed on pivot; hour 00 |
| 21 | `VC_EV_OFFER_EXPIRING_BODY` (`ev_sheet_expiry_warning`) | EventModal (Frank-tagged, quote unattributed) | slot 8b `:427-435`; a sheet at `days_left == 3` | a term sheet has three days left | Frank: decide | 1: `VC_EV_ACK` | **shared id across sheets → second warning dropped**; priority 9 (only Frank card under 10); hour 00 |
| 22 | `VC_EV_LAST_DAY_BODY` (`ev_vc_d179_warning`) | EventModal | slot 8b `:493-497`; `day == 179 ∧ active_sheets ≠ ∅`; latch `vc_d179_warned` | the day before the Day-180 fork, with an offer in hand | Frank: sign today or not at all | 1: `VC_EV_ACK` | hour 00; queues behind any angel/gate card that day |
| 23 | `END_EV_SHUTTER_BODY` (`ev_shutter_warning`) | EventModal | slot 9 `endings_system.gd:96-106`; first day `cash < 0` | cash has just gone negative; a 7-day counter started | Frank: sell something or cut something | 1: `VC_EV_ACK` | re-arms after a recovery (by design); badge PİYASA; pulls a queued gate card; hour 00 |
| 24 | `END_EV_PIVOT_BODY` (`ev_pivot_offer`) | EventModal | slot 9 `:138-160`; `vc_rejections ≥ 3 ∧ no sheet/meeting ∧ pivot_used false ∧ mrr ≥ 2000 ∧ cash > 0`; latch `pivot_offer_made` | the third VC rejection just landed | Frank: maybe not this year, not this company, but not you | 2: `END_EV_PIVOT_ACCEPT` → `accept_pivot`; `END_EV_PIVOT_DECLINE` → **terminal** `vc_rejection_cascade` (no chip) | blind terminal choice; hour 00; body formats `{day}` = 180 |
| 25 | `END_EV_ACQ_BODY` (`ev_acquisition_offer`) | EventModal | slot 9 `:201-212`; `phase == 3 ∧ 30 ≤ brand ≤ 50 ∧ vc_rejections ≥ 1`; latch `acquisition_offer_made`; **not shutter-gated** | a buyer's mail arrived after at least one VC said no | Frank: selling is not a defeat | 2: `END_EV_ACQ_ACCEPT` → **terminal** `acquisition` (no chip); `END_EV_ACQ_DECLINE` → `set_flag acquisition_offer_rejected` (no chip) | **body asserts "cuma akşamı"** at hour 00 on any weekday; can queue behind the shutter warning the same tick; badge PİYASA |
| 26 | `END_META_SERIES_A_CLOSE_FRANK`, `END_META_ACQUISITION_FRANK`, `END_META_BANKRUPTCY_FRANK`, `END_META_BRAND_COLLAPSE_FRANK`, `END_META_VC_REJECTION_CASCADE_FRANK`, `END_META_PROFITABLE_BOOTSTRAP_FRANK`, `END_META_RUNNING_ON_FUMES_FRANK` (7) | **NO SURFACE** (`endings_copy.gd:53-66` overrides; `ending_scene.gd:509` fallback only) | `trigger_ending`, `endings_system.gd:228-254` | the run just ended | Frank's verdict on the run | none | authored, localized, never rendered; the paper bans mentor attribution (`endings_copy.gd:19-26`) |

**Companion keys per row** (titles, option labels, wrappers; same surface as the row, no separate trigger): row 1 `MENTOR_INTRO_CTA` · row 3 `PROD_DESIGN_DECISION_TITLE`, `PROD_ITER_KEEP_GOING`, `PROD_TO_DEVELOPMENT_PLAIN`, `PROD_ITER_CEILING_NOTE` · row 4 `PROD_SHIP_FIRST_READY` (title), `PROD_SHIP_PUBLISH`, `PROD_SHIP_FIRST_TITLE` (month highlight) · row 5 `PROD_SHIP_VERSION_TITLE`, `PROD_SHIP_CONTINUE` · row 10 `ANGEL_EVENT_TITLE`, `ANGEL_EVENT_BODY`, `ANGEL_CHOICE_ACCEPT`, `ANGEL_CHOICE_REFUSE`, `ANGEL_CHOICE_REFUSE_LOCK` · row 11 `ANGEL_NUDGE_TITLE`, `ANGEL_NUDGE_BODY`, `ANGEL_NUDGE_ACK` · row 14 `FIN_MENTOR_WARNING`, `FIN_MENTOR_QUOTE_WRAPPED`, `FIN_SNOOZE` · row 18 `DEAL_PROMPT_SIT`, `DEAL_PROMPT_VALIDITY`, `DEAL_PROMPT_DEFER` · row 20 `VC_EV_MEETING_TITLE`, `VC_EV_ENTER_MEETING`, `VC_EV_SKIP_MEETING` · row 21 `VC_EV_OFFER_EXPIRING_TITLE`, `VC_EV_ACK` · row 22 `VC_EV_LAST_DAY_TITLE`, `VC_EV_ACK` · row 23 `END_EV_SHUTTER_TITLE`, `VC_EV_ACK` · row 24 `END_EV_PIVOT_TITLE`, `END_EV_PIVOT_ACCEPT`, `END_EV_PIVOT_DECLINE` · row 25 `END_EV_ACQ_TITLE`, `END_EV_ACQ_ACCEPT`, `END_EV_ACQ_DECLINE`.

---

## 2. Whitelist blocks (one per row; `G` = provable at fire time)

### 1 · `MENTOR_INTRO_BODY` — boot modal
World-fact whitelist:
- day == 1, hour == 09:00, clock paused ← `game_state.gd:639-640`, `main.gd:84, 1929-1934`
- phase 1 Bootstrap; cash $10.000; MRR 0; brand 50; reputation 0 ← `game_state.gd:634-641`, `founder_constants.gd:52`
- origin `self_made` (the only playable) ← `founder_constants.gd:56-72`
- company name exists and is non-empty; founder portrait, logo style chosen ← `company_step.gd:210-214`, `founder_constants.gd:78-88`
- **no product, no build, no customer, no employee**; roster = founder + Frank ← `game_state.gd:712, 768-776`
- Frank's name and title are on screen in this very modal ← `mentor_intro_modal.gd:15-20`
- founder's skill spread (6 points) and trait pair are stored ← `main.gd:2418-2427`, `game_state.gd:805-810`
- it is Thursday 1 January 2026 (provable) ← `game_state.gd:10-13`
Not provable here: founder's name (may be empty) · what Frank saw before (the "Vitrin pitch" is inherited fiction, not state) · anything about the coming product or market · that the modal is shown once (defect 1: it double-mounts and mounts on load).
- `[COND?]` once-per-new-run guarantee (needs the `main.gd:1880-1882` duplicate removed and the load path to skip the mount)
- `[COND?]` founder name non-empty (if Frank is to use it)
- `[COND?]` origin variants (only if heir/corporate_refugee ever unlock)

### 2 · `PROD_MENTOR_LINE` — path-picker strip
Whitelist: a build is being created and the player is on the market step; `product_path_frank_seen` is false (first time) ← `creation_flow.gd:217-218`; no product has shipped yet ← creation flow precedes any build; phase 1; hour = real hour (player action, not a tick). Not provable: which path they lean to; day (any); cash above or below anything. `[COND?]` none needed (a strip with one OK).

### 3 · `ev_mvp_iter_decision_intro` — design round 1 ended
Whitelist: an active build exists; its first design round just completed and **round 2 has already started** ← `product_system.gd:568-579`; the build's innovation value and ceiling are readable (`PROD_ITER_CEILING_NOTE {inn, inn_max}` is appended from live state, `:1378-1388`); hour = real hour of the hourly tick; `mvp_shipped` may be true (a v2 build) or false (the MVP) — **not guaranteed either way**; Frank is or is not a shareholder (unknown). Not provable: employees, MRR, customers. Fires once per run (`_iter_intro_shown`, serialized).
- `[COND?]` is this the MVP or a later version (`mvp_shipped`) — needed if Frank's line should differ
- `[COND?]` a second option that does something (today `PROD_ITER_KEEP_GOING` has no modifier)

### 4 · `ev_mvp_ship_moment` — first ship
Whitelist: an active build existed and the player pressed Ship; `ship_active_build` will set `mvp_shipped`, stamp `mvp_launch_day`, record version 1 ← `product_system.gd:1236-1258`; market type is set (`mvp_market_type` b2b/b2c) ← build commit; product name and sub-type exist (`mvp_product_name`, `mvp_sub_product_type_id`); hour = real hour; MRR == 0 and customers == 0 are overwhelmingly likely but **not asserted** (B2C MRR derives only after the paid tier opens; B2B needs a pitch). Not provable: employees (0 or more), cash level, day. No hour in subtitle.
- `[COND?]` customers == 0 / MRR == 0 at first ship (true in practice; not gated)

### 5 · `ev_mvp_version_ship_moment` — v2+ ship
Whitelist: `mvp_shipped` already true; `mvp_version` ≥ 1 before this ship, becomes ≥ 2; version history array; live bug count flag exists; market type set; hour real. Not provable: customers, MRR, rivals' position, employees.
- `[COND?]` live bug count at ship (readable as `mvp_live_bug_count`, but whether the new version reduced or added bugs is not computed at this seam)

### 6 · `ev_ps_frank_intro_b2b` — Frank opens the first B2B door
Whitelist: `mvp_shipped` true; `mvp_market_type == "b2b"`; product name known; hour 00; **customers may be 0 and prospects may be 0** (not gated); MRR typically 0; phase 1. After the choice: one `mid` prospect spawns with `source = frank_intro` (may return null if the sector pool is exhausted, `pitch_system.gd:42-47`). Not provable: the lead's company name at fire time (does not exist yet); employees.
- `[COND?]` prospects == 0 (if the scene wants "you have no one to call")
- `[COND?]` the spawned company's name in the text (would need the spawn to happen before the body renders)
- `[COND?]` `mentor_advisory` `_en` sibling (the advisory it leaves on the phone is TR-only today)

### 7 · `ev_ps_b2c_paid_tier` — time to price it
Whitelist: `mvp_market_type == "b2c"`; `b2c_audience > 15.0` (float) ← `event_manager.gd:421-424`; `mvp_shipped` true; hour 00; default price constant 15 exists but **no price is set by this card** (only an advisory; the ruler is in Product). Not provable: that the paid tier is still closed (no `flag_unset` condition); the audience count beyond "> 15" (it is typically ~16, not "a few hundred"); MRR (0 while the tier is closed).
- `[COND?]` `b2c_paid_tier_open == false` at fire (a `flag_unset` or explicit false write)
- `[COND?]` audience figure in the text (readable, but the card must render the live float, not a literal)

### 8 · `ev_ps_first_revenue` — the first dollar
Whitelist: `mrr > 0`; ≥ 1 active customer record (MRR is Σ over active customers, `sales_system.gd:127-131`); market type known; `mvp_shipped` true in practice; hour 00; the phase gate is about to open the same morning (its conditions are satisfied; this card is slot 7, the gate slot 8). Not provable: whether the payer is a person (B2B account) or the aggregate userbase record (B2C: `{product} kullanıcıları`); the amount; employees.
- `[COND?]` B2B vs B2C variant (market type is readable; the JSON has one body)
- `[COND?]` the first customer's name (readable for B2B via `CustomerRegistry.get_active()[0]`, but no slot substitution exists)

### 9 · `ev_phase_gate_traction` — Bootstrap → Traction
Whitelist: `mvp_shipped`; ≥ 1 active customer; MRR > 0; phase == 1; `phase_gate_ready == true`; `pending_next_phase == 2`; no shutter running; hour 00; `gate_declines` readable (0 on first show, 1, 2+); `gate_prompt_day` readable; 5-day re-prompt. Not provable: employees (0 is common here); angel offered/accepted; cash/runway; customer count beyond 1.
- `[COND?]` decline count in Frank's mouth is legal (it is readable and selects the body)
- `[COND?]` "you are alone" (employees == 0 is readable but not guaranteed)

### 10 · `ev_angel_frank_seed` — the cheque
Whitelist: `mvp_shipped`; MRR ≥ 2500 ← `angel_round_system.gd:35, 53-56`; ≥ 1 active customer; MRR is on the top bar; **Frank holds 0 % until KABUL** (`run_angel_equity_pct == 0`); terms $25.000 / 4 % are constants (`:36-37`); the cheque is written only on accept (`accept_offer :166-189`, ledger label `Melek yatırımı · Frank`); REDDET is locked and unreachable; hour 00; phase usually 2 but not asserted. Not provable: employees; whether the Traction gate is on screen the same morning (possible); cash level.
- `[COND?]` phase == 2 at the offer (usually; not gated)
- `[COND?]` a reachable REDDET (hard mode has no writer)

### 11 · `ev_angel_hire_nudge` — still alone
Whitelist: `angel_seed_accepted_day > 0` (the cheque was taken); `day ≥ accepted_day + 2`; `employees == 0` ← `:73-89`; the $25.000 is already in the till and Frank holds 4 % ← `accept_offer`; the HR rail badge is lit ← `hr_system.gd:176-182`; hour 00. Not provable: **whether an Atlas search is already open or candidate files are waiting** (`HRSearchSystem` state is not read; `hr_constants.gd:510-512`); cash (≥ $25.000 plus whatever was there, minus two days of burn).
- `[COND?]` HR search state (idle / searching / files_ready) — the line should not tell someone mid-search to "go hire"
- `[COND?]` `mentor_advisory` surface if the nudge should leave a phone note (none today)

### 12 · `ev_phase_gate_series_a` — Traction → Series A Hunt
Whitelist: MRR ≥ 5000 ← `sales_system.gd:29`; brand ≥ 25; phase == 2; `phase_gate_ready`, `pending_next_phase == 3`; no shutter; hour 00; `gate_declines` readable; runway deliberately not a condition (`phase_gate_system.gd:47`). Not provable: employees; angel state; customer count; VC roster knowledge (the hunt has not opened).
- `[COND?]` runway band in Frank's mouth (readable, not gated; if used it must be the live number)

### 13 · `MONTH_FRANK_*` — month-end verdict
Whitelist: it is the 1st of a calendar month (day 32/60/91/121/152 in a 180-day run) at hour 00; the closed month's name; `month_ledger` deltas: Δmrr, Δcash, Δteam (founder + employees, ≥ 1), Δbrand, customers signed/lost ← `month_summary_system.gd:40-56, 77-83`; the selector's branch is therefore known per variant (shutter active; cash down + MRR up; MRR down; all four up; else). Not provable: anything outside the ledger snapshot; the variant cannot name a customer or a person.
- `[COND?]` none (each variant's condition is exact); note the default branch ("another month") must be true for any non-matching month, including a terrible one.

### 14 · `FIN_MENTOR_QUOTE` — runway warning
Whitelist: runway_months finite and < 6.0 ← `finance_ozet_view.gd:25, 595-598`; not snoozed (or snooze expired); the player is on Finance › Özet; the live runway figure and KASA/BURN are on the same page. Not provable: the cause (payroll vs no revenue); whether the angel cheque is taken.
- `[COND?]` the "six months" figure must read the constant, not a literal (today it is a literal)

### 15 · `PROD_TIP_*` — product strip
Whitelist: `mvp_shipped`; `product_bug_risk()` band (`dusuk/orta/yuksek`) ← `product_system.gd:1294-1301`; the quality passer's name if any (`_rival_passed_name`) ← `detail_view.gd:542-543`; weakest axis id; next version number. Not provable: share-table neighbour (separate value); customer sentiment.
- `[COND?]` none; strings are state-fed.

### 16 · mentor-advisory latch — the phone note
Whitelist: an advisory text was emitted by #6/#7/#8 or by the VC callback reopening; the phone dot is lit while the latch is non-empty; the Events page prints it under "Frank'ten not". Not provable after a load: **nothing** (the latch is empty again). Not provable: that the player ever opened the Events page.
- `[COND?]` persistence of the latch (serialize `_mentor_line`)
- `[COND?]` `_en` sibling for every advisory text

### 17 · `HUNT_FRANK_LINE` — hunt strip
Whitelist: phase 3; the roster has 4 pitchable VCs + 1 locked; `vc_rejections` and `CASCADE_TABLES == 3` are readable. Not provable: "dört masa" as a rule (the rule is three closed tables end the road).
- `[COND?]` the strip should be state-fed (closed/total) rather than a literal

### 18 · `DEAL_PROMPT_LINE` — FrankPopup after a sheet
Whitelist: phase ≥ 3; a specific VC (`display_name`) just granted a sheet; its validity days (`SHEET_VALIDITY_DAYS` 14, live `days_left`); no other modal is up; the table can be opened now. Not provable: a second sheet (it may or may not exist; `_other_live_vc()` is readable if needed); runway.
- `[COND?]` leverage (second live sheet) in Frank's mouth is readable, not guaranteed

### 19 · `TERM_FRANK_*` — table whispers
Whitelist: table state (`IDLE / PUSH_SUCCESS / PUSH_FAILURE / PATIENCE_ZERO`), last lever, patience current/max, whether another live VC exists and its name, tables closed `{closed}/3`, money raised, kasa/runway text ← `term_sheet_table_system.gd:184-217, 270-291`. Not provable: the investor's mood beyond patience.
- `[COND?]` none.

### 20 · `ev_vc_meeting_prompt` — meeting day
Whitelist: a booked meeting for a named VC whose day has come; the VC's archetype line; prep state; hour 00. Not provable: the founder's readiness; the outcome.
- `[COND?]` remove the investor's quoted line from a Frank card (two voices), or re-attribute it

### 21 · `ev_sheet_expiry_warning` — three days left
Whitelist: a named VC's sheet has exactly 3 days left ← `pitch_constants.gd:73`; hour 00. Not provable: whether a second sheet also expires today (its warning is dropped).
- `[COND?]` per-sheet id so both warnings can fire

### 22 · `ev_vc_d179_warning` — the day before the fork
Whitelist: `day == 179` (Sun 28 Jun 2026, provable); ≥ 1 active sheet; hour 00; tomorrow is the Day-180 fork (`RUN_END_DAY 180`). Not provable: which way the fork goes.
- `[COND?]` none.

### 23 · `ev_shutter_warning` — in the red
Whitelist: `cash < 0` for the first time since the last recovery; `shutter_days_left` just set to 7 ← `endings_system.gd:19, 96-106`; the counter is on the top bar (`FIN_SHUTTER_COUNTDOWN`); a queued gate card was pulled; hour 00. Not provable: MRR band; whether a recovery happened before (the card re-arms).
- `[COND?]` first-time vs repeat shutter (readable only by keeping a counter; none today)

### 24 · `ev_pivot_offer` — the third no
Whitelist: `vc_rejections ≥ 3`; no active or pending sheet, no pending meeting; `pivot_used == false`; MRR ≥ 2000; cash > 0; phase 3; hour 00; `{day}` = 180. Not provable: which three VCs; the founder's wish.
- `[COND?]` none (the gate is tight).

### 25 · `ev_acquisition_offer` — the buyer's mail
Whitelist: phase == 3; 30 ≤ brand ≤ 50; `vc_rejections ≥ 1`; `acquisition_offer_made` just latched; hour 00; **the weekday is whatever the calendar says that day** (provable, arbitrary). Not provable: "cuma akşamı" (defect 8); the offer figure (none exists in state: accept simply triggers the ending).
- `[COND?]` an offer amount in state if Frank is to name a figure
- `[COND?]` weekday/evening wording (only if the trigger were moved to a Friday-evening hourly path)

### 26 · `END_META_*_FRANK` — verdicts (no surface)
Whitelist (from `ending_data` + run ledger, `endings_system.gd:232-254`, `game_state.gd:530-589`): ending id; day; cash; MRR; brand; reputation; phase; customers active; employees; company name; founder name (may be ""); signed terms (`equity_pct`, `board_seats`, `board_veto`, `valuation_m`, `investment_amount`); founder-friendly = `equity ≤ 18 ∧ not veto` (`endings_copy.gd:29, 81`); angel amount/pct (4 % if taken); `months alive = ceil(day/30)`; bankruptcy = exactly 7 days in the red (`SHUTTER_DAYS`); running_on_fumes = Day 180 fork with one of the four win conditions failed (`cash_went_negative`, 90-day net ≤ 0, unmanaged scandal (always false), MRR < 5000). Not provable: anything rendered (no surface).
- `[COND?]` a surface (a Frank strip on `EndingScene`, or a pre-terminal beat)
- `[COND?]` which win condition failed for running_on_fumes (computable at the fork, not stored)

---

## 3. Where the Frank voice is missing today (no occurrence, by design or by gap)
- Ending screen (row 26 has no surface).
- HR: no Frank text anywhere (`hr_system.gd:29-31` excludes him from every employee path); the nudge's rail badge is the only HR touch.
- News ticker: no Frank line, no Frank quote (`news_feed_system.gd`, `TICKER_*`, `NEWS_*`).
- Save load: the advisory latch and any pending FrankPopup are lost.

## 4. Excluded consciously (Frank named, not Frank speaking)

| key / place | why excluded |
|---|---|
| `MENTOR_NAME`, `MENTOR_ROLE`, `MENTOR_ROLE_LINE`, `HR_ROLE_MENTOR`, `PROD_MENTOR_TAG`, `UI_AVATAR_INITIALS` (FK), `ODA_MENTOR_TAG_FALLBACK`, `EVENT_TAG_MENTOR`, `EVENT_MENTOR_ADVICE` | identity, caption and badge strings; no voice |
| `PROD_READY_TALK_FRANK` | Product Detail badge ("HAZIR · FRANK'LE KONUŞ"), a signpost to the gate card |
| `ODA_TOUR_PHONE_DESC` | tour narrator describing the phone as Frank's channel |
| `ANGEL_TX_LABEL`, `ANGEL_CAP_ROW`, `ANGEL_CHIP_ACCEPT`, `ANGEL_MONTH_HIGHLIGHT`, `GATE_OPENED` | ledger row, cap-table row, effect chip, month highlights (narrator) |
| `VC_WHY_WARM_INTRO` | odds-breakdown reason chip |
| `INV_ARCH_BOSPHORUS` ("İlişki adamı. Kapıyı Frank açar.") | investor archetype descriptor; also injected as `{line}` into row 20's body (borderline, attributed to the investor) |
| `PITCH_INNER_CLOSED`, `PITCH_S0_INNER`, `PITCH_S0_NPC` | the founder's inner voice / the prospect speaking about Frank |
| `PROD_SHIP_FIRST_BODY`, `PROD_SHIP_VERSION_BODY`, `PROD_DESIGN_DECISION_BODY` (+ `PROD_DESIGN_CEILING_NOTE`) | dead CSV twins with zero readers |
| `END_META_SERIES_A_CLOSE_TITLE`, `END_META_ACQUISITION_TITLE`, `END_META_BANKRUPTCY_TITLE`, `END_META_BRAND_COLLAPSE_TITLE`, `END_META_VC_REJECTION_CASCADE_TITLE`, `END_META_PROFITABLE_BOOTSTRAP_TITLE`, `END_META_RUNNING_ON_FUMES_TITLE` | ending titles (narrator, not Frank) and, like the `_FRANK` twins, never rendered (`ending_data.title` read only in the same fallback paths) |
| `scripts/debug/endgame_smoke.gd` (`frank_line` assertions, `:905-906`) | test surface only |
| `scenes/ui/components/RightPanel.tscn` hardcoded "Frank Köseoğlu / OPERATING PARTNER" + an English quote | retired scene, never instantiated (`loc_residue.gd:49` skips it) |
| `data/events/reactive/ev_debug_003_cash_warning.json` | `ev_debug_*` files are skipped by the loader (`event_manager.gd:835-836`) |
| `frank_popup.gd:124-143 debug_fixture`, `month_summary_system.gd:94-108 debug_force_summary` | LOC-DATA shot fixtures |
| `docs/content/events_draft/Y5/*` | unshipped drafts; not a reference (ruling 1) |

## 5. Counts
26 occurrences (families counted once: 3 gate bodies ×2, 5 month lines, 3 product tips, 7 term whispers, 7 ending verdicts) · 7 with no surface (row 26) + 3 dead twins + 7 unrendered titles · 38 `[COND?]` flags · 9 render/copy defects ranked in §0.

Stop. Waiting for the first scene to be named.
