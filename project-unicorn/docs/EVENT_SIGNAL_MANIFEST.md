# EVENT SIGNAL MANIFEST

**GENERATED — do not hand-edit.** Regenerate with `python tools/gen_signal_manifest.py`.
Source: `scripts/autoload/event_bus.gd` plus every `.gd` under `scripts/`. Last generated 2026-08-27.

Authority: [`GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`](../GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md) §15. The read side of
the same idea is [`SEAM_REGISTRY.md`](SEAM_REGISTRY.md).

## Why this is generated

§15.1 asks for a static manifest of emitter, listeners and payload. Hand-keeping that
for 128 signals guarantees drift, and drift here is not cosmetic: §15.2 makes "a declared
signal with no emit point" a lint error, so the manifest is the lint rule's input.

## Headline numbers

| | count |
|---|---|
| Signals declared | **128** |
| Declared with **no production emitter** | **3** |
| Emitted with **no production listener** | **66** |

The second number is the §15.2 violation set. The third is **not** a defect, and it
is smaller than it looks: the event engine listens to SIX of them through
`EvSignals.BINDINGS` — `customer_health_changed`, `customer_expanded`,
`employee_departed`, `employee_hired`, `meeting_day`, `phase_gate_reached` and
`promise_broken` — connecting each by NAME at runtime, which a static scan for
`.connect(` cannot see. So this table undercounts the engine and always will.

The rest are not a defect either: three
modules deliberately publish their read-surface signals ahead of any consumer so the
engine finds a vocabulary rather than having to discover one (`event_bus.gd:76-79`,
`:175-179`, `:196-197`). Those 48 are the engine's ready-made trigger surface.

## §15.2 violations — declared, never emitted

- **`employee_eligible_for_promotion(character_id: String)`** — no emit site anywhere.
- **`raise_requested(character_id: String)`** — no emit site anywhere.
- **`meeting_requested(vc_id: String)`** — no emit site anywhere.

## Every signal

`E` = production emit sites · `L` = production listen sites. Debug-only sites are
excluded from both counts and shown in the notes column when they are all a signal has.


### State change signals (§13.2)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `cash_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `mrr_changed` | `new_value: int` | game_state | 1 | 3 | capacity_block · top_bar · oda_view |
| `burn_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `brand_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `reputation_changed` | `new_value: int` | game_state | 1 | 1 | top_bar |
| `day_advanced` | `new_day: int` | game_state | 1 | 3 | main · top_bar · oda_view |
| `hour_changed` | `hour: int` | game_state | 1 | 2 | top_bar · oda_view |
| `phase_changed` | `new_phase: int` | game_state | 2 | 3 | finance_tab · top_bar · oda_view |
| `runway_recalculated` | `months: float` | game_state | 1 | 2 | left_tabs · top_bar |
| `equity_changed` | `investor_pct: int` | game_state | 1 | 0 | — |

### UI / time signals (§13.2)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `speed_change_requested` | `speed: int` | game_shell · main · endings_system · top_bar · oda_tour | 25 | 1 | time_manager |
| `tab_changed` | `tab_id: String` | effects · game_shell · main · rnd_card_modal · creation_flow · detail_view · left_tabs · research_bar · tab_page_chrome · oda_view | 25 | 5 | game_shell · build_hud_panel · center_viewport · left_tabs · oda_tour |
| `finance_subpage_requested` | `page_id: String` | effects · oda_view | 2 | 1 | finance_tab |

### Settings / audio signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `settings_requested` | `—` | main · system_menu_modal · left_tabs | 3 | 2 | main |
| `confirm_requested` | `config: Dictionary` | main · save_load_modal · settings_modal · system_menu_modal · term_sheet_table_scene · hr_tab · hunt_tab · hr_atlas_modal · creation_flow | 16 | 3 | main |
| `music_enabled_changed` | `enabled: bool` | audio_manager | 1 | 0 | — |
| `music_volume_changed` | `volume: float` | audio_manager | 1 | 0 | — |
| `language_changed` | `locale: String` | localization | 1 | 5 | center_viewport · news_ticker · top_bar · oda_tour · oda_view |
| `palette_changed` | `colorblind: bool` | settings_modal | 2 | 3 | center_viewport · top_bar · oda_view |

### Character signals (§13.2)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `character_added` | `character_id: String` | character_registry | 1 | 1 | left_tabs |
| `character_removed` | `character_id: String` | character_registry | 1 | 1 | left_tabs |
| `morale_changed` | `character_id: String, new_morale: int` | character_registry | 1 | 2 | left_tabs · oda_view |
| `employee_experience_changed` | `character_id: String, new_experience: int` | character_registry | 2 | 0 | — |
| `employee_training_changed` | `character_id: String, days_left: int` | character_registry | 3 | 0 | — |
| `employee_promoted` | `character_id: String, new_level: int` | hr_actions | 1 | 0 | — |
| `experience_bar_full` | `character_id: String` | character_registry | 1 | 0 | — |
| `morale_band_changed` | `character_id: String, band_id: String` | character_registry | 1 | 0 | — |
| `employee_eligible_for_promotion` | `character_id: String` | — | 0 | 0 | — |
| `raise_requested` | `character_id: String` | — | 0 | 0 | — |
| `leave_requested` | `character_id: String` | hr_morale_system | 1 | 0 | — |
| `employee_hired` | `character_id: String` | character_registry | 1 | 0 | — |
| `employee_departed` | `character_id: String` | character_registry | 1 | 0 | — |
| `training_started` | `character_id: String, area_key: String` | character_registry | 1 | 0 | — |
| `training_completed` | `character_id: String, area_key: String` | character_registry | 1 | 0 | — |
| `assignment_changed` | `character_id: String` | character_registry · work_hours_system | 12 | 0 | — |
| `hr_day_processed` | `—` | hr_system | 1 | 1 | oda_view |
| `news_stream_changed` | `—` | news_feed_system | 1 | 1 | news_ticker |

### Customer signals (§13.2)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `customer_added` | `customer_id: String` | customer_registry | 1 | 1 | oda_view |
| `customer_removed` | `customer_id: String` | customer_registry | 1 | 3 | promise_registry · left_tabs · oda_view |
| `customer_mrr_changed` | `customer_id: String, new_mrr: int` | customer_registry | 1 | 0 | — |
| `customer_seats_changed` | `customer_id: String, new_seats: int` | customer_registry | 1 | 0 | — |
| `customer_satisfaction_changed` | `customer_id: String, new_satisfaction: int` | customer_registry | 1 | 0 | — |

### B2B lifecycle / relationship signals (B2B Sales System)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `customer_health_changed` | `customer_id: String, phase: String` | customer_registry | 2 | 2 | left_tabs · oda_view |
| `customer_churned` | `customer_id: String` | b2b_sales_system | 1 | 1 | left_tabs |
| `customer_expanded` | `customer_id: String, new_seats: int` | b2b_sales_system | 1 | 0 | — |
| `customer_assigned` | `customer_id: String, employee_id: String` | customer_registry | 1 | 0 | — |
| `promise_created` | `promise_id: String` | promise_registry | 1 | 0 | — |
| `promise_kept` | `promise_id: String` | promise_registry | 1 | 0 | — |
| `promise_broken` | `promise_id: String` | promise_registry | 1 | 0 | — |

### Event signals (§13.2)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `event_triggered` | `event_id: String` | engine | 1 | 2 | left_tabs · oda_view |
| `event_resolved` | `event_id: String, choice_index: int` | engine | 2 | 3 | main · left_tabs · oda_view |
| `modal_requested` | `event: GameEvent` | engine | 1 | 2 | main |

### Build / product signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `build_phase_changed` | `new_phase: String` | product_system | 7 | 4 | promise_registry · build_hud_panel · left_tabs · oda_view |
| `build_iteration_decision_pending` | `pending: bool` | product_system | 3 | 0 | — |
| `build_progress_changed` | `—` | product_system | 9 | 2 | build_hud_panel · oda_view |
| `infra_changed` | `—` | product_state | 2 | 1 | capacity_block |

### GDD ÜRÜN rev 6.1 §19 · OKUMA YÜZEYİNİN SİNYALLERİ

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `version_shipped` | `version: int` | product_system | 1 | 1 | rnd_tab |
| `build_started` | `build_id: String` | product_system | 1 | 0 | — |
| `build_paused` | `reason_key: String` | product_read | 1 | 0 | — |
| `build_resumed` | `—` | product_read | 1 | 0 | — |
| `fix_run_started` | `confirmed: int` | support_system | 1 | 0 | — |
| `fix_run_finished` | `shipped: int, remaining: int` | support_system | 1 | 0 | — |
| `bug_confirmed` | `total_confirmed: int` | product_read | 1 | 0 | — |
| `unconfirmed_threshold_crossed` | `band: String` | product_read | 1 | 0 | — |
| `axis_floor_warning` | `axis: String` | product_read | 1 | 0 | — |
| `axis_floor_crossed` | `axis: String` | product_read | 1 | 0 | — |
| `line_upgraded` | `line_id: String, tier: int` | product_system | 1 | 0 | — |
| `line_completed` | `line_id: String` | product_system | 1 | 0 | — |
| `delighter_shipped` | `step_id: String` | product_system | 1 | 0 | — |
| `phase_bar_raised` | `phase: int` | product_read | 1 | 0 | — |

### GDD AR-GE MODÜLÜ §10 · OKUMA YÜZEYİNİN SİNYALLERİ

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `research_started` | `node_id: String` | rnd_system | 1 | 2 | build_hud_panel · left_tabs |
| `research_completed` | `node_id: String` | rnd_system | 1 | 2 | build_hud_panel · left_tabs |
| `research_frozen` | `node_id: String` | rnd_system | 1 | 2 | build_hud_panel · left_tabs |
| `research_resumed` | `node_id: String` | rnd_system | 1 | 2 | build_hud_panel · left_tabs |
| `node_revealed` | `node_id: String` | rnd_system | 1 | 0 | — |
| `hidden_line_unlocked` | `line_id: String` | rnd_system | 1 | 0 | — |
| `product_note_issued` | `day: int` | rnd_system | 1 | 3 | main · left_tabs |
| `research_progress_changed` | `—` | time_manager | 1 | 1 | build_hud_panel |
| `product_note_read` | `—` | rnd_system | 1 | 1 | left_tabs |
| `rnd_node_requested` | `node_id: String, open_assign: bool` | creation_flow · research_bar | 2 | 1 | rnd_tab |
| `rnd_card_requested` | `kind: String, data: Dictionary` | main · rnd_system | 4 | 2 | main |

### Rival signals (Product Lifecycle Part 1)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `rival_added` | `rival_id: String` | rival_registry | 1 | 0 | — |
| `rival_status_changed` | `rival_id: String, status: String` | rival_registry | 1 | 1 | oda_view |
| `rival_advanced` | `—` | rival_registry | 1 | 1 | oda_view |

### PostShip / sales signals

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `prospect_added` | `prospect_id: String` | prospect_registry | 1 | 0 | — |
| `prospect_removed` | `prospect_id: String` | prospect_registry | 1 | 0 | — |
| `pitch_requested` | `prospect_id: String` | sales_tab | 1 | 1 | main |
| `pitch_finished` | `—` | sales_meeting_system | 1 | 0 | — |
| `prospect_arrived` | `prospect_id: String` | sales_faucet_system | 1 | 0 | — |
| `lead_expired` | `prospect_id: String` | sales_faucet_system | 1 | 0 | — |
| `lead_reserved` | `prospect_id: String` | sales_ledger | 1 | 0 | — |
| `lead_routed` | `prospect_id: String` | sales_ledger | 1 | 0 | — |
| `meeting_entered` | `prospect_id: String` | sales_meeting_system | 1 | 0 | — |
| `meeting_won` | `prospect_id: String` | sales_meeting_system | 1 | 0 | — |
| `meeting_lost` | `account_key: String, reason: String` | sales_ledger | 1 | 0 | — |
| `deal_signed` | `customer_id: String, seats: int, seat_price: int` | sales_system | 1 | 0 | — |
| `deal_walked` | `account_key: String` | sales_finalizer | 2 | 0 | — |
| `rep_deal_closed` | `rep_id: String, customer_id: String` | sales_rep_system | 1 | 0 | — |
| `rep_discount_requested` | `rep_id: String, prospect_id: String` | sales_rep_system | 1 | 0 | — |
| `pitch_promise_made` | `account_key: String, feature_id: String` | sales_finalizer | 1 | 0 | — |
| `pitch_promise_kept` | `account_key: String` | b2b_sales_system | 1 | 0 | — |
| `pitch_promise_broken` | `account_key: String` | b2b_sales_system | 1 | 0 | — |
| `whale_condition_met` | `prospect_id: String` | sales_faucet_system | 1 | 0 | — |
| `weekly_sales_report_issued` | `closes: int` | sales_rep_system | 1 | 0 | — |
| `price_stance_changed` | `stance: String` | sales_ledger | 1 | 0 | — |
| `rep_band_cap_changed` | `rep_id: String` | sales_ledger | 1 | 0 | — |
| `mentor_advisory_changed` | `text: String` | effects · vc_pitch_system | 2 | 2 | hunt_tab · oda_view |
| `headline_added` | `source: String, text: String` | effects · ticker · hr_morale_system · hr_search_system · hr_system · sales_finalizer · sales_rep_system | 9 | 2 | time_manager · news_ticker |

### Endgame signals (ENDGAME_DESIGN.md §2/§3)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `phase_gate_reached` | `next_phase: int` | phase_gate_system | 1 | 0 | — |
| `run_ended` | `ending_id: String, ending_data: Dictionary` | endings_system | 1 | 1 | main |
| `shutter_changed` | `days_left: int` | game_state | 1 | 1 | top_bar |
| `month_ended` | `summary_data: Dictionary` | month_summary_system | 3 | 2 | main |

### Cinematic dialogue shell (Spec 5) — MeetingScene

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `meeting_scene_requested` | `view_state: Dictionary` | game_shell · vc_pitch_system | 4 | 1 | main |

### VC Pitch / Series A Hunt signals (Spec 4 / VC_PITCH_DESIGN.md §7)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `sheet_granted` | `vc_id: String` | vc_pitch_system | 2 | 1 | oda_view |
| `sheet_expired` | `vc_id: String` | vc_pitch_system | 1 | 1 | oda_view |
| `callback_ready` | `vc_id: String` | vc_pitch_system | 1 | 0 | — |
| `meeting_day` | `vc_id: String` | vc_pitch_system | 1 | 0 | — |
| `meeting_requested` | `vc_id: String` | — | 0 | 0 | — |
| `offer_countdown_changed` | `days_left: int` | vc_pitch_system | 1 | 1 | top_bar |
| `term_table_requested` | `vc_id: String` | effects · game_shell · hunt_tab | 3 | 1 | main |
| `sheet_walked` | `vc_id: String` | vc_pitch_system | 1 | 1 | oda_view |

### Save / system-menu signals (SaveManager task)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `day_tick_completed` | `day: int` | time_manager | 1 | 1 | save_manager |
| `game_loaded` | `slot_id: String` | main | 1 | 1 | left_tabs |
| `system_menu_requested` | `—` | game_shell · main | 2 | 2 | main |
| `save_load_requested` | `mode: String` | main · system_menu_modal | 3 | 2 | main |
| `quicksave_requested` | `—` | game_shell | 1 | 1 | main |
| `quickload_requested` | `—` | game_shell | 1 | 1 | main |

### Debug signals (OS.is_debug_build only; emitter game_shell.gd)

| signal | payload | emitter(s) | E | L | listener(s) |
|---|---|---|---|---|---|
| `debug_onboarding_retrigger_requested` | `—` | game_shell | 1 | 1 | main |
