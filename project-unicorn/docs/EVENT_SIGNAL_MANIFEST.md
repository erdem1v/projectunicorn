# EVENT SIGNAL MANIFEST

**GENERATED — do not hand-edit.** Regenerate with `python tools/gen_signal_manifest.py`.
Source: `scripts/autoload/event_bus.gd`, every `.gd` under `scripts/`, `EvSignals.BINDINGS` and the card triggers.
Last generated 2026-10-04.

Authority: [`GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`](<../GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md>) §15. The read side of
the same idea is the seam list in [`content/events_draft/_vocabulary.md`](content/events_draft/_vocabulary.md) §b.

## Why this is generated

§15.1 asks for a static manifest of emitter, listeners and payload. Hand-keeping that
for 143 signals guarantees drift, and drift here is not cosmetic: §15.2 makes "a declared
signal with no emit point" a lint error, so the manifest is the lint rule's input.

## Headline numbers

| | count |
|---|---|
| Signals declared | **143** |
| Declared with **no production emitter** | **2** |
| Emitted with **no production listener** | **71** |

The second number is the §15.2 violation set. The third is **not** a defect: the Ekip,
Ürün, Ar-Ge and Satış modules publish their read-surface signals ahead of any consumer,
so the engine finds a vocabulary rather than having to discover one.

The event engine connects signals by NAME at runtime, which a static scan for `.connect(`
cannot see. `EvSignals.install()` (`scripts/events/core/signals.gd`) connects exactly the `trigger.signal` of the
cards the catalogue loads from `data/events/cards/`, and this generator reads the same cards. Today that
is 3 signal(s): `axis_floor_crossed`, `axis_floor_warning`, `customer_health_changed`. They are listed as `EvSignals (card trigger)` and are not counted
as unheard.

`EvSignals.BINDINGS` is an allowlist of the 13 signals a card MAY trigger on. A binding
alone connects nothing, so the others are listed as `EvSignals (bindable)` and still
count as unheard.

## §15.2 violations — declared, never emitted

- **`employee_eligible_for_promotion(character_id: String)`** — no emit site anywhere.
- **`raise_requested(character_id: String)`** — no emit site anywhere.

## Every signal

`E` = production emit sites · `L` = production listen sites. Debug-only sites are
excluded from both counts and shown in the notes column when they are all a signal has.


### State change signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `cash_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `mrr_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `burn_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `brand_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `reputation_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `day_advanced` | `new_day: int` | game_state | 1 | 3 | product_tab · research_bar · top_bar |
| `hour_changed` | `hour: int` | game_state | 1 | 1 | top_bar |
| `phase_changed` | `new_phase: int` | game_state | 2 | 2 | finance_tab · top_bar |
| `runway_recalculated` | `months: float` | game_state | 1 | 2 | left_tabs · top_bar |
| `equity_changed` | `investor_pct: int` | game_state | 2 | 0 | — |

### UI / time signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `speed_change_requested` | `speed: int` | game_shell · main · endings_system · product_tab · top_bar | 23 | 1 | time_manager |
| `night_skipped` | `—` | time_manager | 1 | 4 | main · office_people · office_view |
| `clock_batch_ended` | `—` | time_manager | 1 | 1 | signals |
| `tab_changed` | `tab_id: String` | game_shell · main · product_tab · mail_pane · inbox · left_tabs · research_bar · window_layer · office_notice_stack | 33 | 3 | main · left_tabs · window_layer |
| `finance_subpage_requested` | `page_id: String` | main · mail_pane | 3 | 1 | finance_tab |
| `goto_tab_requested` | `tab_id: String, subpage: String` | effects | 1 | 1 | main |

### Settings signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `settings_requested` | `—` | main · system_menu_modal · left_tabs | 3 | 1 | main |
| `confirm_requested` | `config: Dictionary` | main · save_load_modal · settings_modal · system_menu_modal · term_sheet_table_scene · hr_tab · hunt_tab · hr_atlas_modal · hr_ledger | 14 | 1 | main |
| `language_changed` | `locale: String` | localization | 1 | 8 | left_tabs · news_ticker · research_bar · top_bar · window_layer · meeting_invite · office_city · office_notice_stack |
| `palette_changed` | `colorblind: bool` | settings_modal | 2 | 7 | hr_tab · left_tabs · news_ticker · top_bar · window_layer · office_city · office_notice_stack |

### Character signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `character_added` | `character_id: String` | character_registry | 1 | 2 | left_tabs · office_people |
| `character_removed` | `character_id: String` | character_registry | 1 | 4 | sprint_system · hr_dossier · left_tabs · office_people |
| `morale_changed` | `character_id: String, new_morale: int` | character_registry | 1 | 1 | left_tabs |
| `employee_experience_changed` | `character_id: String, new_experience: int` | character_registry | 2 | 0 | — |
| `employee_training_changed` | `character_id: String, weeks_left: int` | character_registry | 3 | 2 | build_bar · research_bar |
| `employee_promoted` | `character_id: String, new_level: int` | hr_actions | 1 | 0 | — |
| `experience_bar_full` | `character_id: String` | character_registry | 1 | 0 | — |
| `morale_band_changed` | `character_id: String, band_id: String` | character_registry | 1 | 0 | — |
| `employee_eligible_for_promotion` | `character_id: String` | — | 0 | 0 | — |
| `raise_requested` | `character_id: String` | — | 0 | 0 | — |
| `leave_requested` | `character_id: String` | hr_morale_system | 1 | 0 | — |
| `employee_hired` | `character_id: String` | character_registry | 1 | 0 | EvSignals (bindable) |
| `employee_departed` | `character_id: String` | character_registry | 1 | 0 | EvSignals (bindable) |
| `training_started` | `character_id: String, area_key: String` | character_registry | 1 | 0 | — |
| `training_completed` | `character_id: String, area_key: String` | character_registry | 1 | 0 | — |
| `assignment_changed` | `character_id: String` | character_registry · work_hours_system | 11 | 2 | research_bar · office_people |
| `hr_day_processed` | `—` | hr_system | 1 | 2 | sprint_system · hr_dossier |
| `news_stream_changed` | `—` | news_feed_system | 1 | 1 | news_ticker |

### Customer signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `customer_added` | `customer_id: String` | customer_registry | 1 | 0 | — |
| `customer_removed` | `customer_id: String` | customer_registry | 1 | 2 | promise_registry · left_tabs |
| `customer_mrr_changed` | `customer_id: String, new_mrr: int` | customer_registry | 1 | 0 | — |
| `customer_seats_changed` | `customer_id: String, new_seats: int` | customer_registry | 1 | 0 | — |
| `customer_satisfaction_changed` | `customer_id: String, new_satisfaction: int` | customer_registry | 1 | 0 | — |

### B2B lifecycle / relationship signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `customer_health_changed` | `customer_id: String, phase: String` | customer_registry | 1 | 1 | left_tabs · EvSignals (card trigger) |
| `customer_churn_countdown_changed` | `customer_id: String, weeks: int` | customer_registry | 1 | 0 | — |
| `customer_churned` | `customer_id: String` | b2b_sales_system | 1 | 1 | left_tabs · EvSignals (bindable) |
| `customer_expanded` | `customer_id: String, new_seats: int` | b2b_sales_system | 1 | 0 | EvSignals (bindable) |
| `customer_assigned` | `customer_id: String, employee_id: String` | customer_registry | 1 | 0 | — |
| `promise_created` | `promise_id: String` | promise_registry | 1 | 0 | — |
| `promise_kept` | `promise_id: String` | promise_registry | 1 | 0 | — |
| `promise_broken` | `promise_id: String` | promise_registry | 1 | 0 | EvSignals (bindable) |

### Event signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `event_triggered` | `event_id: String` | engine | 1 | 4 | left_tabs · top_bar · window_frame · office_hud |
| `event_resolved` | `event_id: String, choice_index: int` | engine | 2 | 7 | save_manager · main · sprint_system · left_tabs · top_bar · window_frame · office_hud |
| `modal_requested` | `event: GameEvent` | engine | 1 | 1 | main |
| `event_set_aside` | `event_id: String` | engine | 1 | 6 | save_manager · main · left_tabs · top_bar · window_frame · office_hud |
| `desk_changed` | `—` | papers | 4 | 3 | product_tab · left_tabs · top_bar |

### Inbox messages

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `messages_changed` | `—` | message_system | 2 | 0 | — |

### Build / product signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `build_phase_changed` | `new_phase: String` | sprint_system | 1 | 2 | promise_registry · left_tabs · EvSignals (bindable) |
| `build_progress_changed` | `—` | product_system | 1 | 2 | build_bar · build_hud_panel |
| `infra_changed` | `—` | product_state | 2 | 0 | — |

### GDD ÜRÜN rev 6.1 §19 · OKUMA YÜZEYİNİN SİNYALLERİ

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `version_shipped` | `version: int` | sprint_system | 1 | 1 | rnd_tab · EvSignals (bindable) |
| `fix_run_started` | `confirmed: int` | support_system | 1 | 0 | — |
| `fix_run_finished` | `shipped: int, remaining: int` | support_system | 1 | 0 | — |
| `bug_confirmed` | `total_confirmed: int` | product_read | 1 | 0 | — |
| `unconfirmed_threshold_crossed` | `band: String` | product_read | 1 | 0 | — |
| `axis_floor_warning` | `axis: String` | product_read | 1 | 0 | EvSignals (card trigger) |
| `axis_floor_crossed` | `axis: String` | product_read | 1 | 0 | EvSignals (card trigger) |
| `line_upgraded` | `line_id: String, tier: int` | sprint_system | 1 | 0 | — |
| `line_completed` | `line_id: String` | sprint_system | 1 | 0 | — |
| `delighter_shipped` | `step_id: String` | sprint_system | 1 | 0 | — |
| `phase_bar_raised` | `phase: int` | product_read | 1 | 0 | — |

### Sprint

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `sprint_planned` | `number: int` | sprint_system | 2 | 0 | — |
| `sprint_started` | `number: int` | sprint_system | 1 | 1 | office_people |
| `card_phase_changed` | `card_id: String, phase: int` | sprint_system | 1 | 0 | — |
| `card_done` | `card_id: String` | sprint_system | 1 | 0 | — |
| `card_carried_over` | `card_id: String` | sprint_system | 2 | 0 | — |
| `sprint_closed` | `number: int` | sprint_system | 1 | 1 | game_shell |
| `card_decision_requested` | `card_id: String` | sprint_system | 1 | 0 | — |
| `sprint_auto_started` | `number: int` | sprint_system | 1 | 0 | — |
| `product_state_changed` | `—` | sprint_system | 1 | 2 | product_tab · build_bar |

### GDD AR-GE MODÜLÜ §10 · OKUMA YÜZEYİNİN SİNYALLERİ

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `research_started` | `node_id: String` | rnd_system | 1 | 2 | left_tabs · research_bar |
| `research_completed` | `node_id: String` | rnd_system | 1 | 2 | left_tabs · research_bar |
| `research_frozen` | `node_id: String` | rnd_system | 1 | 2 | left_tabs · research_bar |
| `research_resumed` | `node_id: String` | rnd_system | 1 | 2 | left_tabs · research_bar |
| `node_revealed` | `node_id: String` | rnd_system | 1 | 0 | — |
| `hidden_line_unlocked` | `line_id: String` | rnd_system | 1 | 0 | — |
| `product_note_issued` | `day: int` | rnd_system | 1 | 1 | left_tabs |
| `research_progress_changed` | `—` | time_manager | 1 | 2 | build_hud_panel · research_bar |
| `product_note_read` | `—` | rnd_system | 1 | 1 | left_tabs |
| `rnd_node_requested` | `node_id: String, open_assign: bool` | research_bar | 1 | 1 | rnd_tab |

### Rival signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `rival_status_changed` | `rival_id: String, status: String` | rival_registry | 1 | 0 | — |
| `rival_advanced` | `—` | rival_registry | 1 | 0 | — |

### Prospect / pitch signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `prospect_added` | `prospect_id: String` | prospect_registry | 1 | 0 | — |
| `prospect_removed` | `prospect_id: String` | prospect_registry | 1 | 0 | — |
| `pitch_requested` | `prospect_id: String` | sales_tab | 1 | 1 | main |
| `pitch_finished` | `—` | sales_meeting_system · vc_pitch_system | 3 | 0 | — |

### SATIŞ rev 6 §14 · the module's signal vocabulary

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `prospect_arrived` | `prospect_id: String` | sales_faucet_system | 1 | 0 | — |
| `lead_expired` | `prospect_id: String` | sales_faucet_system | 1 | 0 | — |
| `lead_reserved` | `prospect_id: String` | sales_ledger | 1 | 0 | — |
| `lead_routed` | `prospect_id: String` | sales_ledger | 1 | 0 | — |
| `meeting_entered` | `prospect_id: String` | sales_meeting_system | 1 | 0 | — |
| `meeting_won` | `prospect_id: String` | sales_meeting_system | 1 | 0 | — |
| `meeting_lost` | `account_key: String, reason: String` | sales_ledger | 1 | 0 | — |
| `deal_signed` | `customer_id: String, seats: int, seat_price: int` | sales_system | 1 | 0 | — |
| `deal_walked` | `account_key: String` | sales_finalizer | 1 | 0 | — |
| `rep_deal_closed` | `rep_id: String, customer_id: String` | sales_rep_system | 1 | 0 | — |
| `rep_discount_requested` | `rep_id: String, prospect_id: String` | sales_rep_system | 1 | 0 | — |
| `pitch_promise_made` | `account_key: String, feature_id: String` | sales_finalizer | 1 | 0 | — |
| `pitch_promise_kept` | `account_key: String` | b2b_sales_system | 1 | 0 | — |
| `pitch_promise_broken` | `account_key: String` | b2b_sales_system | 1 | 0 | — |
| `whale_condition_met` | `prospect_id: String` | sales_faucet_system | 1 | 0 | — |
| `weekly_sales_report_issued` | `closes: int` | sales_rep_system | 1 | 0 | — |
| `price_stance_changed` | `stance: String` | sales_ledger | 1 | 0 | — |
| `rep_band_cap_changed` | `rep_id: String` | sales_ledger | 1 | 0 | — |

### Mentor / ticker signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `mentor_advisory_changed` | `key: String, args: Dictionary` | effects · vc_pitch_system | 2 | 3 | game_state · hunt_tab · office_notice_stack |
| `headline_added` | `source: String, text: String` | effects · ticker · hr_morale_system · hr_search_system · hr_system · sales_ledger · sprint_bridges | 8 | 2 | time_manager · news_ticker |
| `ticker_live_line` | `source: String, text: String` | sprint_bridges · summary_system · office_travel | 4 | 1 | news_ticker |

### Endgame signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `phase_gate_reached` | `next_phase: int` | phase_gate_system | 1 | 0 | EvSignals (bindable) |
| `run_ended` | `ending_id: String, ending_data: Dictionary` | endings_system | 1 | 1 | main |
| `milestone_reached` | `milestone_id: String, ending_data: Dictionary` | endings_system | 1 | 1 | main |
| `shutter_changed` | `weeks_left: int` | game_state | 1 | 1 | top_bar |
| `month_ended` | `month_close: Dictionary` | summary_system | 1 | 2 | save_manager · top_bar |
| `summary_ready` | `data: Dictionary` | main · summary_system | 2 | 1 | main |

### Meeting panel — MeetingPanel

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `meeting_scene_requested` | `view_state: Dictionary` | vc_pitch_system | 1 | 3 | main |

### VC Pitch / Series A Hunt signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `sheet_granted` | `vc_id: String` | vc_pitch_system | 2 | 0 | — |
| `sheet_expired` | `vc_id: String` | vc_pitch_system | 1 | 0 | EvSignals (bindable) |
| `callback_ready` | `vc_id: String` | vc_pitch_system | 1 | 0 | — |
| `meeting_day` | `vc_id: String` | vc_pitch_system | 1 | 0 | EvSignals (bindable) |
| `offer_countdown_changed` | `weeks_left: int` | vc_pitch_system | 1 | 1 | top_bar |
| `term_table_requested` | `vc_id: String, stage: String` | effects · game_shell · hunt_tab | 4 | 1 | main |
| `sheet_walked` | `vc_id: String` | vc_pitch_system | 1 | 0 | — |

### Seed round (GDD v2 ch. 09 §3) — the middle rung. One publisher each.

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `seed_door_opened` | `—` | seed_round_system | 1 | 1 | finance_tab |
| `seed_sheet_granted` | `vc_id: String` | vc_pitch_system | 1 | 0 | — |
| `seed_round_closed` | `vc_id: String` | seed_round_system | 1 | 0 | — |

### Office

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `office_move_started` | `office_id: String, arrival_day: int` | main · office_system | 2 | 1 | office_hud |
| `office_changed` | `office_id: String` | main · office_system | 2 | 2 | office_hud · office_view |

### Save / system-menu signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `day_tick_completed` | `day: int` | time_manager | 1 | 1 | save_manager |
| `game_loaded` | `slot_id: String` | main | 1 | 1 | left_tabs |
| `system_menu_requested` | `—` | game_shell · main | 2 | 1 | main |
| `save_load_requested` | `mode: String` | main · system_menu_modal | 3 | 1 | main |
| `quicksave_requested` | `—` | game_shell · main | 3 | 1 | main |
| `quickload_requested` | `—` | game_shell · main | 2 | 1 | main |

### Debug signals (OS.is_debug_build only; emitter game_shell.gd)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `debug_onboarding_retrigger_requested` | `—` | game_shell | 1 | 1 | main |
