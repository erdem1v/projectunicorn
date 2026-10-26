# Kod haritası · DIZIN

Üretildi: git 6f1cd7b · 2026-10-26 · betik `tools/kod_haritasi/uret.py`
Yeniden üret (project-unicorn içinden): `python -I tools/kod_haritasi/uret.py` (<30 sn)
Dosyalar diskteki halidir (kirli ağaç dahil). Elle düzenleme; betiği koş.

Sembol: `LC_ALL=C.UTF-8 grep -P "^ad\t" docs/kod_haritasi/SEMBOLLER.tsv` (Git Bash'te LC_ALL şart) ya da `awk -F'\t' '$1=="ad"' SEMBOLLER.tsv`; Grep aracında desen `^ad\t`.
Sinyal: `grep "^- ad(" DIZIN.md`. Dosya: `grep "yol ·" DIZIN.md`. Kalite adayları: KALITE.md.
Sınırlar: ayrıştırma sözdizimseldir (tür çözümü yok); sinyal eşlemesi ada göre; ölü kod listesi aday.
Bölümler: Autoload'lar · Dosyalar · Sinyaller · Sahneler · Veri dosyaları · Metin anahtarı aileleri. Kalite listeleri: KALITE.md.

## Autoload'lar (14)

- EventBus · scripts/autoload/event_bus.gd
- GameState · scripts/autoload/game_state.gd
- CharacterRegistry · scripts/autoload/character_registry.gd
- CustomerRegistry · scripts/autoload/customer_registry.gd
- ProspectRegistry · scripts/autoload/prospect_registry.gd
- PromiseRegistry · scripts/autoload/promise_registry.gd
- RivalRegistry · scripts/autoload/rival_registry.gd
- InvestorRegistry · scripts/autoload/investor_registry.gd
- TimeManager · scripts/autoload/time_manager.gd
- SaveManager · scripts/autoload/save_manager.gd
- Settings · scripts/autoload/settings.gd
- Localization · scripts/autoload/localization.gd
- AudioManager · scripts/autoload/audio_manager.gd
- MCPRuntime · addons/godot_mcp_runtime/mcp_runtime_autoload.gd · uid://bvdfxyfwqs84q

## Dosyalar (250 .gd)

Biçim: yol · satır · class_name · extends · sinyal · func (iç sınıflar dahil). Autoload dosyalarında class_name yerine [AutoloadAdı].

### scripts/autoload/ (13 dosya, 5121 satır)
- scripts/autoload/audio_manager.gd · 172 · [AudioManager] · Node · 0 sinyal · 17 func
- scripts/autoload/character_registry.gd · 627 · [CharacterRegistry] · Node · 0 sinyal · 50 func
- scripts/autoload/customer_registry.gd · 321 · [CustomerRegistry] · Node · 0 sinyal · 29 func
- scripts/autoload/event_bus.gd · 301 · [EventBus] · Node · 145 sinyal · 0 func
- scripts/autoload/game_state.gd · 1049 · [GameState] · Node · 0 sinyal · 55 func
- scripts/autoload/investor_registry.gd · 145 · [InvestorRegistry] · Node · 0 sinyal · 9 func
- scripts/autoload/localization.gd · 114 · [Localization] · Node · 0 sinyal · 8 func
- scripts/autoload/promise_registry.gd · 187 · [PromiseRegistry] · Node · 0 sinyal · 16 func
- scripts/autoload/prospect_registry.gd · 73 · [ProspectRegistry] · Node · 0 sinyal · 8 func
- scripts/autoload/rival_registry.gd · 208 · [RivalRegistry] · Node · 0 sinyal · 13 func
- scripts/autoload/save_manager.gd · 1297 · [SaveManager] · Node · 0 sinyal · 61 func
- scripts/autoload/settings.gd · 174 · [Settings] · Node · 0 sinyal · 12 func
- scripts/autoload/time_manager.gd · 453 · [TimeManager] · Node · 2 sinyal · 34 func

### scripts/data_models/ (8 dosya, 493 satır)
- scripts/data_models/character.gd · 106 · Character · Resource · 0 sinyal · 0 func
- scripts/data_models/customer.gd · 124 · Customer · Resource · 0 sinyal · 3 func
- scripts/data_models/event.gd · 21 · GameEvent · Resource · 0 sinyal · 0 func
- scripts/data_models/event_choice.gd · 12 · EventChoice · Resource · 0 sinyal · 0 func
- scripts/data_models/promise.gd · 22 · Promise · Resource · 0 sinyal · 0 func
- scripts/data_models/prospect.gd · 111 · Prospect · Resource · 0 sinyal · 6 func
- scripts/data_models/rival.gd · 34 · Rival · Resource · 0 sinyal · 1 func
- scripts/data_models/term_sheet.gd · 63 · TermSheet · Resource · 0 sinyal · 3 func

### scripts/debug/ (11 dosya, 33419 satır)
- scripts/debug/endgame_smoke.gd · 28238 · EndgameSmoke · RefCounted · 0 sinyal · 649 func
- scripts/debug/glyph_audit.gd · 107 · - · SceneTree · 0 sinyal · 6 func
- scripts/debug/kit_probe.gd · 298 · - · RefCounted · 0 sinyal · 10 func
- scripts/debug/loc_residue.gd · 265 · - · SceneTree · 0 sinyal · 9 func
- scripts/debug/office_crowd_probe.gd · 326 · OfficeCrowdProbe · Node · 0 sinyal · 15 func
- scripts/debug/office_pan_probe.gd · 398 · - · RefCounted · 0 sinyal · 17 func
- scripts/debug/product_fixtures.gd · 717 · - · RefCounted · 0 sinyal · 44 func
- scripts/debug/run_probe.gd · 2390 · RunProbe · RefCounted · 0 sinyal · 92 func
- scripts/debug/sprint_probe.gd · 489 · - · RefCounted · 0 sinyal · 19 func
- scripts/debug/tick_probe.gd · 133 · - · Node · 0 sinyal · 3 func
- scripts/debug/write_licenses.gd · 58 · - · SceneTree · 0 sinyal · 2 func

### scripts/events/ (1 dosya, 227 satır)
- scripts/events/event_gate.gd · 227 · EventGate · RefCounted · 0 sinyal · 35 func

### scripts/events/catalog/ (1 dosya, 313 satır)
- scripts/events/catalog/catalog.gd · 313 · EvCatalog · RefCounted · 0 sinyal · 19 func

### scripts/events/core/ (15 dosya, 3825 satır)
- scripts/events/core/arcs.gd · 230 · EvArcs · RefCounted · 0 sinyal · 21 func
- scripts/events/core/budgets.gd · 53 · EvBudgets · RefCounted · 0 sinyal · 6 func
- scripts/events/core/condition.gd · 389 · EvCondition · RefCounted · 0 sinyal · 24 func
- scripts/events/core/delays.gd · 140 · EvDelays · RefCounted · 0 sinyal · 10 func
- scripts/events/core/dice.gd · 65 · EvDice · RefCounted · 0 sinyal · 4 func
- scripts/events/core/effects.gd · 850 · EvEffects · RefCounted · 0 sinyal · 26 func
- scripts/events/core/engine.gd · 804 · EvEngine · RefCounted · 0 sinyal · 36 func
- scripts/events/core/flags.gd · 131 · EvFlags · RefCounted · 0 sinyal · 13 func
- scripts/events/core/history.gd · 210 · EvHistory · RefCounted · 0 sinyal · 21 func
- scripts/events/core/latches.gd · 143 · EvLatches · RefCounted · 0 sinyal · 14 func
- scripts/events/core/queue.gd · 252 · EvQueue · RefCounted · 0 sinyal · 26 func
- scripts/events/core/save.gd · 105 · EvSave · RefCounted · 0 sinyal · 5 func
- scripts/events/core/schedule.gd · 161 · EvSchedule · RefCounted · 0 sinyal · 15 func
- scripts/events/core/signals.gd · 106 · EvSignals · RefCounted · 0 sinyal · 3 func
- scripts/events/core/tuning.gd · 186 · EvTuning · RefCounted · 0 sinyal · 1 func

### scripts/events/gate/ (2 dosya, 649 satır)
- scripts/events/gate/gate.gd · 288 · EvGate · RefCounted · 0 sinyal · 12 func
- scripts/events/gate/scope.gd · 361 · EvScope · RefCounted · 0 sinyal · 19 func

### scripts/events/present/ (5 dosya, 1373 satır)
- scripts/events/present/chips.gd · 484 · EvChips · RefCounted · 0 sinyal · 22 func
- scripts/events/present/papers.gd · 206 · EvPapers · RefCounted · 0 sinyal · 23 func
- scripts/events/present/presenter.gd · 307 · EvPresenter · RefCounted · 0 sinyal · 16 func
- scripts/events/present/tempo.gd · 316 · EvTempo · RefCounted · 0 sinyal · 20 func
- scripts/events/present/ticker.gd · 60 · EvTicker · RefCounted · 0 sinyal · 6 func

### scripts/events/seams/ (8 dosya, 1305 satır)
- scripts/events/seams/seams.gd · 161 · EvSeams · RefCounted · 0 sinyal · 16 func
- scripts/events/seams/seams_finance.gd · 66 · EvSeamsFinance · RefCounted · 0 sinyal · 1 func
- scripts/events/seams/seams_hr.gd · 191 · EvSeamsHR · RefCounted · 0 sinyal · 5 func
- scripts/events/seams/seams_incident.gd · 58 · EvSeamsIncident · RefCounted · 0 sinyal · 1 func
- scripts/events/seams/seams_ported.gd · 194 · EvSeamsPorted · RefCounted · 0 sinyal · 2 func
- scripts/events/seams/seams_product.gd · 343 · EvSeamsProduct · RefCounted · 0 sinyal · 8 func
- scripts/events/seams/seams_sales.gd · 132 · EvSeamsSales · RefCounted · 0 sinyal · 3 func
- scripts/events/seams/seams_world.gd · 160 · EvSeamsWorld · RefCounted · 0 sinyal · 7 func

### scripts/events/tools/ (7 dosya, 3421 satır)
- scripts/events/tools/engine_probe.gd · 700 · EvProbe · RefCounted · 0 sinyal · 17 func
- scripts/events/tools/harness.gd · 424 · EvHarness · RefCounted · 0 sinyal · 10 func
- scripts/events/tools/lint.gd · 1216 · EvLint · RefCounted · 0 sinyal · 44 func
- scripts/events/tools/plausibility.gd · 396 · - · RefCounted · 0 sinyal · 20 func
- scripts/events/tools/plausibility_main.gd · 41 · - · SceneTree · 0 sinyal · 2 func
- scripts/events/tools/vocab_gen.gd · 376 · EvVocabGen · RefCounted · 0 sinyal · 5 func
- scripts/events/tools/why.gd · 268 · EvWhy · RefCounted · 0 sinyal · 8 func

### scripts/main/ (2 dosya, 5708 satır)
- scripts/main/game_shell.gd · 240 · - · Control · 0 sinyal · 13 func
- scripts/main/main.gd · 5468 · - · Node · 0 sinyal · 196 func

### scripts/menu/ (5 dosya, 294 satır)
- scripts/menu/continue_card.gd · 19 · - · Button · 0 sinyal · 1 func
- scripts/menu/credits.gd · 60 · - · Control · 1 sinyal · 5 func
- scripts/menu/godot_card.gd · 35 · - · Control · 1 sinyal · 4 func
- scripts/menu/licenses.gd · 80 · - · Control · 2 sinyal · 5 func
- scripts/menu/main_menu.gd · 100 · - · Control · 2 sinyal · 5 func

### scripts/modals/ (9 dosya, 2817 satır)
- scripts/modals/confirm_modal.gd · 65 · - · Control · 3 sinyal · 4 func
- scripts/modals/ending_scene.gd · 563 · EndingScene · Control · 2 sinyal · 25 func
- scripts/modals/hr_action_modal.gd · 237 · - · Control · 2 sinyal · 10 func
- scripts/modals/save_load_modal.gd · 262 · - · Control · 3 sinyal · 18 func
- scripts/modals/settings_modal.gd · 480 · - · Control · 1 sinyal · 26 func
- scripts/modals/system_menu_modal.gd · 106 · - · Control · 3 sinyal · 9 func
- scripts/modals/term_sheet_table_scene.gd · 437 · TermSheetTableScene · Control · 1 sinyal · 22 func
- scripts/modals/training_modal.gd · 175 · - · "res://scripts/tabs/hr/hr_panel.gd" · 0 sinyal · 7 func
- scripts/modals/work_hours_modal.gd · 492 · - · "res://scripts/tabs/hr/hr_panel.gd" · 0 sinyal · 28 func

### scripts/onboarding/ (2 dosya, 447 satır)
- scripts/onboarding/first_week_doc.gd · 234 · - · PanelContainer · 1 sinyal · 3 func
- scripts/onboarding/onboarding_flow.gd · 213 · - · Control · 2 sinyal · 12 func

### scripts/onboarding/steps/ (4 dosya, 666 satır)
- scripts/onboarding/steps/character_step.gd · 111 · - · OnboardingStep · 0 sinyal · 5 func
- scripts/onboarding/steps/company_step.gd · 105 · - · OnboardingStep · 0 sinyal · 5 func
- scripts/onboarding/steps/origin_traits_step.gd · 332 · - · OnboardingStep · 0 sinyal · 18 func
- scripts/onboarding/steps/step_base.gd · 118 · OnboardingStep · Control · 1 sinyal · 10 func

### scripts/systems/ (72 dosya, 24349 satır)
- scripts/systems/angel_round_system.gd · 52 · AngelRoundSystem · RefCounted · 0 sinyal · 1 func
- scripts/systems/b2b_constants.gd · 286 · B2BConstants · RefCounted · 0 sinyal · 9 func
- scripts/systems/b2b_sales_system.gd · 652 · B2BSalesSystem · RefCounted · 0 sinyal · 43 func
- scripts/systems/cheque_read.gd · 60 · - · RefCounted · 0 sinyal · 3 func
- scripts/systems/company_catalog.gd · 113 · CompanyCatalog · RefCounted · 0 sinyal · 1 func
- scripts/systems/counterpart_system.gd · 101 · CounterpartSystem · RefCounted · 0 sinyal · 9 func
- scripts/systems/customer_rep_system.gd · 380 · CustomerRepSystem · RefCounted · 0 sinyal · 19 func
- scripts/systems/display_settings.gd · 350 · DisplaySettings · RefCounted · 0 sinyal · 27 func
- scripts/systems/endings_copy.gd · 539 · EndingsCopy · RefCounted · 0 sinyal · 31 func
- scripts/systems/endings_system.gd · 527 · EndingsSystem · RefCounted · 0 sinyal · 28 func
- scripts/systems/finance_system.gd · 325 · FinanceSystem · RefCounted · 0 sinyal · 22 func
- scripts/systems/founder_constants.gd · 196 · FounderConstants · RefCounted · 0 sinyal · 9 func
- scripts/systems/graphics_settings.gd · 211 · - · RefCounted · 0 sinyal · 14 func
- scripts/systems/hr_actions.gd · 332 · HRActions · RefCounted · 0 sinyal · 28 func
- scripts/systems/hr_candidate_generator.gd · 276 · HRCandidateGenerator · RefCounted · 0 sinyal · 14 func
- scripts/systems/hr_constants.gd · 1164 · HRConstants · RefCounted · 0 sinyal · 91 func
- scripts/systems/hr_morale_system.gd · 353 · HRMoraleSystem · RefCounted · 0 sinyal · 25 func
- scripts/systems/hr_search_system.gd · 307 · HRSearchSystem · RefCounted · 0 sinyal · 15 func
- scripts/systems/hr_system.gd · 554 · HRSystem · RefCounted · 0 sinyal · 49 func
- scripts/systems/incident_system.gd · 660 · IncidentSystem · RefCounted · 0 sinyal · 51 func
- scripts/systems/infra_system.gd · 254 · InfraSystem · RefCounted · 0 sinyal · 25 func
- scripts/systems/line_gates.gd · 130 · LineGates · RefCounted · 0 sinyal · 10 func
- scripts/systems/look_system.gd · 145 · LookSystem · RefCounted · 0 sinyal · 9 func
- scripts/systems/mail_clock.gd · 121 · MailClock · RefCounted · 0 sinyal · 10 func
- scripts/systems/market_catalog.gd · 217 · MarketCatalog · RefCounted · 0 sinyal · 25 func
- scripts/systems/message_system.gd · 77 · MessageSystem · RefCounted · 0 sinyal · 5 func
- scripts/systems/module_locks.gd · 35 · - · RefCounted · 0 sinyal · 4 func
- scripts/systems/negotiation_system.gd · 276 · NegotiationSystem · RefCounted · 0 sinyal · 13 func
- scripts/systems/news_feed_system.gd · 429 · NewsFeedSystem · RefCounted · 0 sinyal · 19 func
- scripts/systems/office_constants.gd · 109 · OfficeConstants · RefCounted · 0 sinyal · 0 func
- scripts/systems/office_system.gd · 91 · OfficeSystem · RefCounted · 0 sinyal · 12 func
- scripts/systems/people_parts.gd · 165 · PeopleParts · RefCounted · 0 sinyal · 2 func
- scripts/systems/phase_gate_system.gd · 178 · PhaseGateSystem · RefCounted · 0 sinyal · 9 func
- scripts/systems/pitch_constants.gd · 181 · PitchConstants · RefCounted · 0 sinyal · 1 func
- scripts/systems/product_catalog.gd · 241 · ProductCatalog · RefCounted · 0 sinyal · 14 func
- scripts/systems/product_lines.gd · 432 · ProductLines · RefCounted · 0 sinyal · 26 func
- scripts/systems/product_quality.gd · 394 · ProductQuality · RefCounted · 0 sinyal · 34 func
- scripts/systems/product_read.gd · 169 · ProductRead · RefCounted · 0 sinyal · 18 func
- scripts/systems/product_state.gd · 333 · ProductState · RefCounted · 0 sinyal · 43 func
- scripts/systems/product_system.gd · 45 · ProductSystem · RefCounted · 0 sinyal · 6 func
- scripts/systems/quality_model.gd · 37 · QualityModel · RefCounted · 0 sinyal · 2 func
- scripts/systems/research_seam.gd · 100 · ResearchSeam · RefCounted · 0 sinyal · 6 func
- scripts/systems/research_tree.gd · 427 · ResearchTree · RefCounted · 0 sinyal · 31 func
- scripts/systems/rival_catalog.gd · 167 · RivalCatalog · RefCounted · 0 sinyal · 1 func
- scripts/systems/rnd_system.gd · 814 · RnDSystem · RefCounted · 0 sinyal · 56 func
- scripts/systems/rng_streams.gd · 79 · RngStreams · RefCounted · 0 sinyal · 6 func
- scripts/systems/sales_archetypes.gd · 185 · SalesArchetypes · RefCounted · 0 sinyal · 13 func
- scripts/systems/sales_constants.gd · 298 · SalesConstants · RefCounted · 0 sinyal · 10 func
- scripts/systems/sales_faucet_system.gd · 307 · SalesFaucetSystem · RefCounted · 0 sinyal · 19 func
- scripts/systems/sales_finalizer.gd · 108 · SalesFinalizer · RefCounted · 0 sinyal · 6 func
- scripts/systems/sales_ledger.gd · 432 · SalesLedger · RefCounted · 0 sinyal · 48 func
- scripts/systems/sales_meeting_system.gd · 489 · SalesMeetingSystem · RefCounted · 0 sinyal · 32 func
- scripts/systems/sales_name_pool.gd · 103 · SalesNamePool · RefCounted · 0 sinyal · 3 func
- scripts/systems/sales_probes.gd · 337 · SalesProbes · RefCounted · 0 sinyal · 9 func
- scripts/systems/sales_rep_system.gd · 317 · SalesRepSystem · RefCounted · 0 sinyal · 21 func
- scripts/systems/sales_system.gd · 556 · SalesSystem · RefCounted · 0 sinyal · 32 func
- scripts/systems/save_codec.gd · 299 · SaveCodec · RefCounted · 0 sinyal · 16 func
- scripts/systems/seed_constants.gd · 149 · SeedConstants · RefCounted · 0 sinyal · 2 func
- scripts/systems/seed_round_system.gd · 225 · SeedRoundSystem · RefCounted · 0 sinyal · 9 func
- scripts/systems/skill_check.gd · 104 · SkillCheck · RefCounted · 0 sinyal · 8 func
- scripts/systems/sprint_bridges.gd · 343 · SprintBridges · RefCounted · 0 sinyal · 20 func
- scripts/systems/sprint_bugs.gd · 176 · SprintBugs · RefCounted · 0 sinyal · 16 func
- scripts/systems/sprint_catalog.gd · 1052 · SprintCatalog · RefCounted · 0 sinyal · 93 func
- scripts/systems/sprint_prep.gd · 134 · SprintPrep · RefCounted · 0 sinyal · 9 func
- scripts/systems/sprint_system.gd · 1949 · SprintSystem · RefCounted · 0 sinyal · 162 func
- scripts/systems/sprint_timeline.gd · 326 · SprintTimeline · RefCounted · 0 sinyal · 15 func
- scripts/systems/summary_system.gd · 244 · SummarySystem · RefCounted · 0 sinyal · 12 func
- scripts/systems/support_system.gd · 420 · SupportSystem · RefCounted · 0 sinyal · 23 func
- scripts/systems/term_sheet_table_system.gd · 987 · TermSheetTableSystem · RefCounted · 0 sinyal · 57 func
- scripts/systems/time_model.gd · 61 · TimeModel · RefCounted · 0 sinyal · 7 func
- scripts/systems/vc_pitch_system.gd · 1327 · VCPitchSystem · RefCounted · 0 sinyal · 91 func
- scripts/systems/work_hours_system.gd · 337 · WorkHoursSystem · RefCounted · 0 sinyal · 37 func

### scripts/tabs/ (9 dosya, 3982 satır)
- scripts/tabs/events_tab.gd · 369 · - · Control · 0 sinyal · 23 func
- scripts/tabs/finance_tab.gd · 144 · - · Control · 1 sinyal · 9 func
- scripts/tabs/hr_tab.gd · 542 · - · Control · 1 sinyal · 32 func
- scripts/tabs/hunt_tab.gd · 544 · - · Control · 0 sinyal · 27 func
- scripts/tabs/personal_tab.gd · 266 · - · Control · 1 sinyal · 13 func
- scripts/tabs/piyasa_tab.gd · 689 · - · Control · 0 sinyal · 34 func
- scripts/tabs/product_tab.gd · 321 · - · Control · 1 sinyal · 17 func
- scripts/tabs/rnd_tab.gd · 273 · - · Control · 1 sinyal · 14 func
- scripts/tabs/sales_tab.gd · 834 · - · Control · 1 sinyal · 40 func

### scripts/tabs/events/ (1 dosya, 887 satır)
- scripts/tabs/events/mail_pane.gd · 887 · - · ScrollContainer · 0 sinyal · 46 func

### scripts/tabs/finance/ (1 dosya, 590 satır)
- scripts/tabs/finance/finance_ozet_view.gd · 590 · FinanceOzetView · Control · 0 sinyal · 25 func

### scripts/tabs/hr/ (7 dosya, 2114 satır)
- scripts/tabs/hr/hr_assignments.gd · 188 · HRAssignments · RefCounted · 0 sinyal · 8 func
- scripts/tabs/hr/hr_atlas_modal.gd · 490 · - · "res://scripts/tabs/hr/hr_panel.gd" · 0 sinyal · 20 func
- scripts/tabs/hr/hr_dossier.gd · 232 · - · VBoxContainer · 2 sinyal · 13 func
- scripts/tabs/hr/hr_ledger.gd · 453 · HRLedger · RefCounted · 0 sinyal · 23 func
- scripts/tabs/hr/hr_panel.gd · 132 · - · Control · 1 sinyal · 10 func
- scripts/tabs/hr/hr_popover.gd · 113 · HRPopover · Control · 0 sinyal · 8 func
- scripts/tabs/hr/hr_ui_shared.gd · 506 · HRUiShared · RefCounted · 0 sinyal · 32 func

### scripts/tabs/product/ (8 dosya, 2885 satır)
- scripts/tabs/product/area_panel.gd · 232 · AreaPanel · VBoxContainer · 2 sinyal · 8 func
- scripts/tabs/product/overview_view.gd · 96 · - · HBoxContainer · 1 sinyal · 6 func
- scripts/tabs/product/product_model.gd · 1041 · ProductModel · RefCounted · 0 sinyal · 55 func
- scripts/tabs/product/quarter_view.gd · 209 · QuarterView · VBoxContainer · 1 sinyal · 8 func
- scripts/tabs/product/sprint_card.gd · 370 · SprintCard · PanelContainer · 1 sinyal · 18 func
- scripts/tabs/product/sprint_panel.gd · 423 · SprintPanel · HBoxContainer · 1 sinyal · 18 func
- scripts/tabs/product/sprint_ui_shared.gd · 398 · SprintUiShared · RefCounted · 0 sinyal · 31 func
- scripts/tabs/product/type_picker.gd · 116 · TypePicker · VBoxContainer · 1 sinyal · 4 func

### scripts/tabs/rnd/ (5 dosya, 1316 satır)
- scripts/tabs/rnd/rnd_assign_panel.gd · 236 · RnDAssignPanel · VBoxContainer · 2 sinyal · 11 func
- scripts/tabs/rnd/rnd_detail_panel.gd · 272 · RnDDetailPanel · Control · 0 sinyal · 15 func
- scripts/tabs/rnd/rnd_history.gd · 85 · - · Control · 0 sinyal · 6 func
- scripts/tabs/rnd/rnd_tree_view.gd · 433 · RnDTreeView · Control · 1 sinyal · 25 func
- scripts/tabs/rnd/rnd_ui_shared.gd · 290 · RnDUiShared · RefCounted · 0 sinyal · 22 func

### scripts/theme/ (4 dosya, 3304 satır)
- scripts/theme/build_theme.gd · 1528 · - · SceneTree · 0 sinyal · 28 func
- scripts/theme/theme_check.gd · 271 · - · SceneTree · 0 sinyal · 11 func
- scripts/theme/ui_factory.gd · 533 · UiFactory · RefCounted · 0 sinyal · 38 func
- scripts/theme/ui_tokens.gd · 972 · UiTokens · RefCounted · 0 sinyal · 39 func

### scripts/ui/ (1 dosya, 138 satır)
- scripts/ui/menu_backdrop.gd · 138 · - · Control · 1 sinyal · 6 func

### scripts/ui/components/ (20 dosya, 3401 satır)
- scripts/ui/components/bar_kit.gd · 37 · - · RefCounted · 0 sinyal · 3 func
- scripts/ui/components/build_bar.gd · 168 · - · PanelContainer · 0 sinyal · 11 func
- scripts/ui/components/build_bar_model.gd · 46 · - · RefCounted · 0 sinyal · 2 func
- scripts/ui/components/build_hud_panel.gd · 108 · - · Control · 0 sinyal · 6 func
- scripts/ui/components/cash_curve.gd · 272 · CashCurve · Control · 0 sinyal · 16 func
- scripts/ui/components/dialogue_portrait_card.gd · 28 · DialoguePortraitCard · PanelContainer · 0 sinyal · 2 func
- scripts/ui/components/gate_strip.gd · 53 · - · PanelContainer · 0 sinyal · 2 func
- scripts/ui/components/inbox.gd · 570 · - · RefCounted · 0 sinyal · 41 func
- scripts/ui/components/investor_appetite_ui.gd · 40 · InvestorAppetiteUi · RefCounted · 0 sinyal · 3 func
- scripts/ui/components/left_tabs.gd · 326 · - · Panel · 0 sinyal · 19 func
- scripts/ui/components/logo_emblem.gd · 188 · LogoEmblem · Control · 0 sinyal · 11 func
- scripts/ui/components/news_ticker.gd · 237 · - · Panel · 1 sinyal · 13 func
- scripts/ui/components/radial_dial.gd · 95 · RadialDial · Control · 1 sinyal · 10 func
- scripts/ui/components/research_bar.gd · 194 · - · PanelContainer · 0 sinyal · 10 func
- scripts/ui/components/research_bar_model.gd · 86 · - · RefCounted · 0 sinyal · 2 func
- scripts/ui/components/segment_bar.gd · 39 · SegmentBar · Control · 0 sinyal · 3 func
- scripts/ui/components/toast.gd · 94 · - · PanelContainer · 0 sinyal · 4 func
- scripts/ui/components/top_bar.gd · 454 · - · Panel · 0 sinyal · 22 func
- scripts/ui/components/window_frame.gd · 119 · - · PanelContainer · 0 sinyal · 4 func
- scripts/ui/components/window_layer.gd · 247 · - · Panel · 0 sinyal · 16 func

### scripts/ui/meeting/ (5 dosya, 1572 satır)
- scripts/ui/meeting/meeting_panel.gd · 805 · MeetingPanel · Control · 1 sinyal · 38 func
- scripts/ui/meeting/meeting_panel_option.gd · 125 · - · PanelContainer · 2 sinyal · 7 func
- scripts/ui/meeting/meeting_ruler.gd · 122 · MeetingRuler · VBoxContainer · 2 sinyal · 7 func
- scripts/ui/meeting/sales_meeting_adapter.gd · 320 · SalesMeetingAdapter · RefCounted · 0 sinyal · 18 func
- scripts/ui/meeting/vc_meeting_adapter.gd · 200 · VcMeetingAdapter · RefCounted · 0 sinyal · 12 func

### scripts/ui/office/ (19 dosya, 5186 satır)
- scripts/ui/office/meeting_cast.gd · 186 · MeetingCast · Node3D · 2 sinyal · 13 func
- scripts/ui/office/meeting_invite.gd · 198 · MeetingInvite · Control · 2 sinyal · 12 func
- scripts/ui/office/office_actor.gd · 160 · OfficeActor · OfficePerson · 0 sinyal · 6 func
- scripts/ui/office/office_body.gd · 275 · OfficeBody · RefCounted · 0 sinyal · 12 func
- scripts/ui/office/office_camera.gd · 232 · OfficeCamera · Camera3D · 1 sinyal · 15 func
- scripts/ui/office/office_city.gd · 482 · OfficeCity · Node3D · 1 sinyal · 25 func
- scripts/ui/office/office_gesture.gd · 45 · OfficeGesture · SkeletonModifier3D · 0 sinyal · 3 func
- scripts/ui/office/office_hud.gd · 126 · - · Control · 1 sinyal · 7 func
- scripts/ui/office/office_layout.gd · 99 · OfficeLayout · RefCounted · 0 sinyal · 4 func
- scripts/ui/office/office_lighting.gd · 328 · OfficeLighting · RefCounted · 0 sinyal · 12 func
- scripts/ui/office/office_map_card.gd · 164 · - · PanelContainer · 2 sinyal · 3 func
- scripts/ui/office/office_materials.gd · 105 · OfficeMaterials · RefCounted · 0 sinyal · 3 func
- scripts/ui/office/office_notice_stack.gd · 196 · - · VBoxContainer · 0 sinyal · 10 func
- scripts/ui/office/office_people.gd · 763 · OfficePeople · Node3D · 2 sinyal · 48 func
- scripts/ui/office/office_person.gd · 1128 · OfficePerson · Node3D · 0 sinyal · 51 func
- scripts/ui/office/office_travel.gd · 179 · - · Control · 0 sinyal · 11 func
- scripts/ui/office/office_venue.gd · 95 · OfficeVenue · RefCounted · 0 sinyal · 10 func
- scripts/ui/office/office_view.gd · 254 · - · Control · 0 sinyal · 20 func
- scripts/ui/office/person_bust.gd · 171 · PersonBust · Node · 0 sinyal · 9 func

### scripts/util/ (1 dosya, 224 satır)
- scripts/util/fmt.gd · 224 · Fmt · RefCounted · 0 sinyal · 24 func

### tools/office3d/ (1 dosya, 270 satır)
- tools/office3d/bake_nav.gd · 270 · - · SceneTree · 0 sinyal · 14 func

### tools/people/ (3 dosya, 340 satır)
- tools/people/bake_portraits.gd · 16 · - · SceneTree · 0 sinyal · 2 func
- tools/people/portrait_baker.gd · 216 · - · Node · 0 sinyal · 9 func
- tools/people/setup_import.gd · 108 · - · SceneTree · 0 sinyal · 5 func

## Sinyaller (210)

Eşleme ada göredir (alıcı nesne çözülmez); aynı adlı iki sinyal varsa yerler ikisine de yazılır. connect yerlerine .tscn [connection] satırları ve değer olarak geçen sinyal (dizi içi bağ, await) dahil. Uzun satır `  ↳ ad` ile sürer.

### scripts/autoload/event_bus.gd
- cash_changed(new_value: int) · scripts/autoload/event_bus.gd:7
  ↳ cash_changed emit: scripts/autoload/game_state.gd:355
  ↳ cash_changed connect: scripts/tabs/finance/finance_ozet_view.gd:61, scripts/tabs/finance_tab.gd:50, scripts/tabs/hr_tab.gd:75, scripts/ui/components/top_bar.gd:100, scripts/debug/endgame_smoke.gd:4753,20023
- mrr_changed(new_value: int) · scripts/autoload/event_bus.gd:8
  ↳ mrr_changed emit: scripts/autoload/game_state.gd:361
  ↳ mrr_changed connect: scripts/tabs/finance/finance_ozet_view.gd:62, scripts/tabs/finance_tab.gd:50, scripts/tabs/hunt_tab.gd:47, scripts/tabs/sales_tab.gd:76, scripts/ui/components/top_bar.gd:101
- burn_changed(new_value: int) · scripts/autoload/event_bus.gd:9
  ↳ burn_changed emit: scripts/autoload/game_state.gd:366
  ↳ burn_changed connect: scripts/tabs/finance/finance_ozet_view.gd:63, scripts/tabs/finance_tab.gd:51, scripts/tabs/hr_tab.gd:75, scripts/ui/components/top_bar.gd:102
- brand_changed(new_value: int) · scripts/autoload/event_bus.gd:10 · emit: scripts/autoload/game_state.gd:371 · connect: scripts/ui/components/top_bar.gd:104
- reputation_changed(new_value: int) · scripts/autoload/event_bus.gd:11 · emit: scripts/autoload/game_state.gd:376 · connect: scripts/ui/components/top_bar.gd:105
- day_advanced(new_day: int) · scripts/autoload/event_bus.gd:12
  ↳ day_advanced emit: scripts/autoload/game_state.gd:380
  ↳ day_advanced connect: scripts/tabs/hunt_tab.gd:47, scripts/tabs/piyasa_tab.gd:82, scripts/tabs/product_tab.gd:113, scripts/ui/components/build_bar.gd:40, scripts/ui/components/research_bar.gd:53, scripts/ui/components/top_bar.gd:106 +2
- hour_changed(hour: int) · scripts/autoload/event_bus.gd:13
  ↳ hour_changed emit: scripts/autoload/game_state.gd:384
  ↳ hour_changed connect: scripts/tabs/hunt_tab.gd:60, scripts/tabs/sales_tab.gd:82, scripts/ui/components/news_ticker.gd:74, scripts/ui/components/top_bar.gd:107, scripts/debug/endgame_smoke.gd:6493,8294 +3
- phase_changed(new_phase: int) · scripts/autoload/event_bus.gd:14
  ↳ phase_changed emit: scripts/autoload/game_state.gd:393,405
  ↳ phase_changed connect: scripts/tabs/finance/finance_ozet_view.gd:70, scripts/tabs/finance_tab.gd:53, scripts/tabs/hunt_tab.gd:52, scripts/tabs/personal_tab.gd:51, scripts/ui/components/inbox.gd:158, scripts/ui/components/top_bar.gd:108
- runway_recalculated(months: float) · scripts/autoload/event_bus.gd:15
  ↳ runway_recalculated emit: scripts/autoload/game_state.gd:804
  ↳ runway_recalculated connect: scripts/tabs/finance_tab.gd:52, scripts/tabs/hr_tab.gd:76, scripts/ui/components/left_tabs.gd:110, scripts/ui/components/top_bar.gd:103
- equity_changed(investor_pct: int) · scripts/autoload/event_bus.gd:18
  ↳ equity_changed emit: scripts/autoload/game_state.gd:655,666
  ↳ equity_changed connect: scripts/tabs/finance/finance_ozet_view.gd:65, scripts/tabs/personal_tab.gd:51, scripts/tabs/piyasa_tab.gd:82, scripts/ui/office/office_hud.gd:55, scripts/debug/endgame_smoke.gd:4744
- speed_change_requested(speed: int) · scripts/autoload/event_bus.gd:21 · emit: scripts/autoload/save_manager.gd:370, scripts/main/game_shell.gd:121, scripts/main/main.gd:93,420,493,1391 +51 · connect: scripts/autoload/time_manager.gd:81
- night_skipped() · scripts/autoload/event_bus.gd:23
  ↳ night_skipped emit: scripts/autoload/time_manager.gd:192
  ↳ night_skipped connect: scripts/events/tools/plausibility.gd:160, scripts/main/main.gd:478,2312, scripts/ui/office/office_people.gd:86, scripts/ui/office/office_view.gd:64, scripts/debug/endgame_smoke.gd:8297 +3
- clock_batch_ended() · scripts/autoload/event_bus.gd:25
  ↳ clock_batch_ended emit: scripts/autoload/time_manager.gd:205
  ↳ clock_batch_ended connect: scripts/events/core/signals.gd:54, scripts/systems/incident_system.gd:314, scripts/systems/sprint_system.gd:1778, scripts/tabs/rnd_tab.gd:81, scripts/ui/components/research_bar.gd:64 +1
- tab_changed(tab_id: String) · scripts/autoload/event_bus.gd:29
  ↳ tab_changed emit: scripts/main/game_shell.gd:47,174, scripts/main/main.gd:400,582,1174,1177 +54
  ↳ tab_changed connect: scripts/main/main.gd:4764, scripts/ui/components/left_tabs.gd:105, scripts/ui/components/research_bar.gd:63, scripts/ui/components/window_layer.gd:62
- finance_subpage_requested(page_id: String) · scripts/autoload/event_bus.gd:32 · emit: scripts/main/main.gd:4380,4846, scripts/tabs/events/mail_pane.gd:828 · connect: scripts/tabs/finance_tab.gd:58
- goto_tab_requested(tab_id: String, subpage: String) · scripts/autoload/event_bus.gd:34 · emit: scripts/events/core/effects.gd:547 · connect: scripts/main/main.gd:4763
- settings_requested() · scripts/autoload/event_bus.gd:38 · emit: scripts/main/main.gd:2592, scripts/menu/main_menu.gd:56, scripts/modals/system_menu_modal.gd:39, scripts/ui/components/left_tabs.gd:95 · connect: scripts/main/main.gd:88
- confirm_requested(config: Dictionary) · scripts/autoload/event_bus.gd:41
  ↳ confirm_requested emit: scripts/main/main.gd:2609,5231, scripts/modals/save_load_modal.gd:212, scripts/modals/settings_modal.gd:269, scripts/modals/system_menu_modal.gd:78, scripts/modals/term_sheet_table_scene.gd:388 +10
  ↳ confirm_requested connect: scripts/main/main.gd:90
- language_changed(locale: String) · scripts/autoload/event_bus.gd:43
  ↳ language_changed emit: scripts/autoload/localization.gd:88, scripts/main/main.gd:3781
  ↳ language_changed connect: scripts/autoload/character_registry.gd:16, scripts/modals/system_menu_modal.gd:29, scripts/ui/components/build_bar.gd:40, scripts/ui/components/left_tabs.gd:129, scripts/ui/components/news_ticker.gd:79 +8
- palette_changed(colorblind: bool) · scripts/autoload/event_bus.gd:47
  ↳ palette_changed emit: scripts/modals/settings_modal.gd:251,282
  ↳ palette_changed connect: scripts/tabs/hr_tab.gd:85, scripts/ui/components/left_tabs.gd:130, scripts/ui/components/news_ticker.gd:81, scripts/ui/components/top_bar.gd:111, scripts/ui/components/window_layer.gd:66 +2
- character_added(character_id: String) · scripts/autoload/event_bus.gd:50
  ↳ character_added emit: scripts/autoload/character_registry.gd:460
  ↳ character_added connect: scripts/tabs/hr_tab.gd:74, scripts/ui/components/left_tabs.gd:108, scripts/ui/office/office_people.gd:83
- character_removed(character_id: String) · scripts/autoload/event_bus.gd:51
  ↳ character_removed emit: scripts/autoload/character_registry.gd:560
  ↳ character_removed connect: scripts/systems/sprint_system.gd:1493, scripts/tabs/hr/hr_dossier.gd:55, scripts/tabs/hr_tab.gd:74, scripts/ui/components/inbox.gd:161, scripts/ui/components/left_tabs.gd:109 +1
- morale_changed(character_id: String, new_morale: int) · scripts/autoload/event_bus.gd:52
  ↳ morale_changed emit: scripts/autoload/character_registry.gd:624
  ↳ morale_changed connect: scripts/tabs/hr/hr_dossier.gd:49, scripts/tabs/hr_tab.gd:74, scripts/ui/components/inbox.gd:161, scripts/ui/components/left_tabs.gd:107
- employee_experience_changed(character_id: String, new_experience: int) · scripts/autoload/event_bus.gd:54
  ↳ employee_experience_changed emit: scripts/autoload/character_registry.gd:129,181
  ↳ employee_experience_changed connect: scripts/tabs/hr/hr_dossier.gd:49, scripts/tabs/hr_tab.gd:79, scripts/tabs/personal_tab.gd:52
- employee_training_changed(character_id: String, weeks_left: int) · scripts/autoload/event_bus.gd:56
  ↳ employee_training_changed emit: scripts/autoload/character_registry.gd:153,164,180
  ↳ employee_training_changed connect: scripts/tabs/hr/hr_dossier.gd:50, scripts/tabs/hr_tab.gd:79, scripts/tabs/personal_tab.gd:52, scripts/ui/components/build_bar.gd:45, scripts/ui/components/research_bar.gd:59
- employee_promoted(character_id: String, new_level: int) · scripts/autoload/event_bus.gd:58 · emit: scripts/systems/hr_actions.gd:154 · connect: scripts/tabs/hr/hr_dossier.gd:50
- productivity_changed(character_id: String) · scripts/autoload/event_bus.gd:60 · emit: scripts/autoload/character_registry.gd:585,596 · connect: scripts/tabs/hr/hr_dossier.gd:51, scripts/tabs/hr_tab.gd:80
- experience_bar_full(character_id: String) · scripts/autoload/event_bus.gd:66 · emit: scripts/autoload/character_registry.gd:130 · connect: scripts/debug/endgame_smoke.gd:11593
- morale_band_changed(character_id: String, band_id: String) · scripts/autoload/event_bus.gd:69 · emit: scripts/autoload/character_registry.gd:627 · connect: scripts/debug/endgame_smoke.gd:11582
- employee_eligible_for_promotion(character_id: String) · scripts/autoload/event_bus.gd:73 · emit: - · connect: -
- raise_requested(character_id: String) · scripts/autoload/event_bus.gd:76 · emit: - · connect: -
- leave_requested(character_id: String) · scripts/autoload/event_bus.gd:79 · emit: scripts/systems/hr_morale_system.gd:65 · connect: -
- employee_hired(character_id: String) · scripts/autoload/event_bus.gd:81 · emit: scripts/autoload/character_registry.gd:462 · connect: scripts/events/core/signals.gd:28, scripts/systems/sprint_system.gd:1495
- employee_departed(character_id: String) · scripts/autoload/event_bus.gd:82 · emit: scripts/autoload/character_registry.gd:561 · connect: scripts/events/core/signals.gd:27
- training_started(character_id: String, area_key: String) · scripts/autoload/event_bus.gd:83 · emit: scripts/autoload/character_registry.gd:154 · connect: scripts/systems/sprint_system.gd:1496
- training_completed(character_id: String, area_key: String) · scripts/autoload/event_bus.gd:84 · emit: scripts/autoload/character_registry.gd:182 · connect: -
- assignment_changed(character_id: String) · scripts/autoload/event_bus.gd:88
  ↳ assignment_changed emit: scripts/autoload/character_registry.gd:244,285,294,311, scripts/systems/work_hours_system.gd:270,275 +5
  ↳ assignment_changed connect: scripts/systems/sprint_system.gd:1494, scripts/tabs/hr/hr_dossier.gd:51, scripts/tabs/hunt_tab.gd:60, scripts/tabs/rnd_tab.gd:73, scripts/tabs/sales_tab.gd:77, scripts/ui/components/build_bar.gd:41 +2
- hr_day_processed() · scripts/autoload/event_bus.gd:91
  ↳ hr_day_processed emit: scripts/main/main.gd:3527,3557, scripts/systems/hr_system.gd:51, scripts/debug/endgame_smoke.gd:23571,26236,26242
  ↳ hr_day_processed connect: scripts/systems/sprint_system.gd:1492, scripts/tabs/hr/hr_dossier.gd:54, scripts/tabs/hr_tab.gd:76, scripts/tabs/personal_tab.gd:51
- news_stream_changed() · scripts/autoload/event_bus.gd:94 · emit: scripts/systems/news_feed_system.gd:169 · connect: scripts/ui/components/news_ticker.gd:77
- customer_added(customer_id: String) · scripts/autoload/event_bus.gd:97
  ↳ customer_added emit: scripts/autoload/customer_registry.gd:102
  ↳ customer_added connect: scripts/events/core/signals.gd:23, scripts/tabs/finance/finance_ozet_view.gd:73, scripts/tabs/sales_tab.gd:71, scripts/ui/components/inbox.gd:160, scripts/ui/components/top_bar.gd:127
- customer_removed(customer_id: String) · scripts/autoload/event_bus.gd:98
  ↳ customer_removed emit: scripts/autoload/customer_registry.gd:128
  ↳ customer_removed connect: scripts/autoload/promise_registry.gd:21, scripts/tabs/finance/finance_ozet_view.gd:74, scripts/tabs/sales_tab.gd:71, scripts/ui/components/inbox.gd:160, scripts/ui/components/left_tabs.gd:117
- customer_mrr_changed(customer_id: String, new_mrr: int) · scripts/autoload/event_bus.gd:99 · emit: scripts/autoload/customer_registry.gd:140 · connect: -
- customer_seats_changed(customer_id: String, new_seats: int) · scripts/autoload/event_bus.gd:100 · emit: scripts/autoload/customer_registry.gd:155 · connect: scripts/tabs/sales_tab.gd:75, scripts/debug/endgame_smoke.gd:2832
- customer_satisfaction_changed(customer_id: String, new_satisfaction: int) · scripts/autoload/event_bus.gd:101 · emit: scripts/autoload/customer_registry.gd:171 · connect: scripts/tabs/sales_tab.gd:75, scripts/debug/endgame_smoke.gd:2859
- customer_health_changed(customer_id: String, phase: String) · scripts/autoload/event_bus.gd:105
  ↳ customer_health_changed emit: scripts/autoload/customer_registry.gd:186
  ↳ customer_health_changed connect: scripts/events/core/signals.gd:24, scripts/tabs/sales_tab.gd:72, scripts/ui/components/inbox.gd:161, scripts/ui/components/left_tabs.gd:115, scripts/debug/endgame_smoke.gd:3262
- customer_churn_countdown_changed(customer_id: String, weeks: int) · scripts/autoload/event_bus.gd:108 · emit: scripts/autoload/customer_registry.gd:199 · connect: scripts/tabs/sales_tab.gd:72
- customer_churned(customer_id: String) · scripts/autoload/event_bus.gd:109
  ↳ customer_churned emit: scripts/systems/b2b_sales_system.gd:317
  ↳ customer_churned connect: scripts/events/core/signals.gd:25, scripts/tabs/sales_tab.gd:73, scripts/ui/components/left_tabs.gd:116, scripts/debug/endgame_smoke.gd:3259,3605, scripts/debug/run_probe.gd:481
- customer_expanded(customer_id: String, new_seats: int) · scripts/autoload/event_bus.gd:110
  ↳ customer_expanded emit: scripts/systems/b2b_sales_system.gd:458
  ↳ customer_expanded connect: scripts/events/core/signals.gd:26, scripts/tabs/sales_tab.gd:74, scripts/debug/endgame_smoke.gd:4343
- customer_assigned(customer_id: String, employee_id: String) · scripts/autoload/event_bus.gd:111 · emit: scripts/autoload/customer_registry.gd:321 · connect: scripts/tabs/hr_tab.gd:78, scripts/tabs/sales_tab.gd:74
- promise_created(promise_id: String) · scripts/autoload/event_bus.gd:113 · emit: scripts/autoload/promise_registry.gd:77 · connect: scripts/debug/run_probe.gd:482
- promise_kept(promise_id: String) · scripts/autoload/event_bus.gd:114 · emit: scripts/autoload/promise_registry.gd:185 · connect: scripts/debug/endgame_smoke.gd:4162, scripts/debug/run_probe.gd:483
- promise_broken(promise_id: String) · scripts/autoload/event_bus.gd:115
  ↳ promise_broken emit: scripts/autoload/promise_registry.gd:183
  ↳ promise_broken connect: scripts/events/core/signals.gd:29, scripts/debug/endgame_smoke.gd:4189,24062, scripts/debug/run_probe.gd:484
- event_triggered(event_id: String) · scripts/autoload/event_bus.gd:118
  ↳ event_triggered emit: scripts/events/core/engine.gd:565,606
  ↳ event_triggered connect: scripts/events/tools/harness.gd:103, scripts/events/tools/plausibility.gd:158, scripts/tabs/finance/finance_ozet_view.gd:82, scripts/tabs/hr_tab.gd:81, scripts/tabs/hunt_tab.gd:53 +14
- event_resolved(event_id: String, choice_index: int) · scripts/autoload/event_bus.gd:119
  ↳ event_resolved emit: scripts/events/core/engine.gd:631,672
  ↳ event_resolved connect: scripts/autoload/save_manager.gd:63, scripts/main/game_shell.gd:29, scripts/main/main.gd:4761, scripts/systems/incident_system.gd:313, scripts/systems/sprint_system.gd:1467 +13
- modal_requested(event: GameEvent) · scripts/autoload/event_bus.gd:120 · emit: scripts/events/core/engine.gd:607 · connect: scripts/events/tools/harness.gd:99, scripts/main/main.gd:4760, scripts/debug/endgame_smoke.gd:6332,19011
- event_set_aside(event_id: String) · scripts/autoload/event_bus.gd:122
  ↳ event_set_aside emit: scripts/events/core/engine.gd:802
  ↳ event_set_aside connect: scripts/autoload/save_manager.gd:66, scripts/main/main.gd:4762, scripts/tabs/finance/finance_ozet_view.gd:84, scripts/tabs/hr_tab.gd:81, scripts/tabs/hunt_tab.gd:53, scripts/tabs/personal_tab.gd:54 +9
- desk_changed() · scripts/autoload/event_bus.gd:125
  ↳ desk_changed emit: scripts/events/present/papers.gd:44,49,60,98, scripts/systems/mail_clock.gd:72,108
  ↳ desk_changed connect: scripts/tabs/product_tab.gd:114, scripts/ui/components/inbox.gd:157, scripts/ui/components/left_tabs.gd:114, scripts/ui/components/top_bar.gd:116
- messages_changed() · scripts/autoload/event_bus.gd:129 · emit: scripts/events/core/history.gd:81, scripts/systems/message_system.gd:55,69,76 · connect: scripts/tabs/rnd_tab.gd:73, scripts/ui/components/inbox.gd:158
- module_unlocked(module_id: String) · scripts/autoload/event_bus.gd:135 · emit: scripts/events/core/engine.gd:270 · connect: scripts/events/core/signals.gd:41, scripts/debug/endgame_smoke.gd:27096
- build_phase_changed(new_phase: String) · scripts/autoload/event_bus.gd:137
  ↳ build_phase_changed emit: scripts/systems/sprint_system.gd:322,1700, scripts/debug/endgame_smoke.gd:4165,5192
  ↳ build_phase_changed connect: scripts/autoload/promise_registry.gd:15, scripts/events/core/signals.gd:31, scripts/ui/components/build_bar.gd:40, scripts/ui/components/build_hud_panel.gd:49, scripts/ui/components/left_tabs.gd:125 +2
- build_progress_changed() · scripts/autoload/event_bus.gd:139
  ↳ build_progress_changed emit: scripts/systems/product_state.gd:200,210
  ↳ build_progress_changed connect: scripts/tabs/product_tab.gd:112, scripts/ui/components/build_bar.gd:44, scripts/ui/components/build_hud_panel.gd:52, scripts/debug/endgame_smoke.gd:14609
- line_bugs_cleared(line: String, n: int) · scripts/autoload/event_bus.gd:141 · emit: scripts/systems/product_state.gd:211 · connect: scripts/debug/endgame_smoke.gd:14610,22776, scripts/debug/run_probe.gd:488
- infra_changed() · scripts/autoload/event_bus.gd:144 · emit: scripts/systems/product_state.gd:297,305,316 · connect: scripts/tabs/product_tab.gd:115, scripts/debug/run_probe.gd:500
- version_shipped(version: int) · scripts/autoload/event_bus.gd:149
  ↳ version_shipped emit: scripts/systems/sprint_system.gd:323,1701
  ↳ version_shipped connect: scripts/events/core/signals.gd:30, scripts/tabs/finance/finance_ozet_view.gd:72, scripts/tabs/personal_tab.gd:52, scripts/tabs/rnd_tab.gd:76, scripts/ui/components/inbox.gd:162 +6
- bug_confirmed(total_confirmed: int) · scripts/autoload/event_bus.gd:150 · emit: scripts/systems/product_read.gd:152 · connect: scripts/debug/endgame_smoke.gd:15133
- unconfirmed_threshold_crossed(band: String) · scripts/autoload/event_bus.gd:151 · emit: scripts/systems/product_read.gd:155 · connect: scripts/debug/endgame_smoke.gd:15134
- axis_floor_warning(area: String) · scripts/autoload/event_bus.gd:152 · emit: scripts/systems/product_read.gd:162 · connect: scripts/events/core/signals.gd:37, scripts/debug/endgame_smoke.gd:15202
- axis_floor_crossed(area: String) · scripts/autoload/event_bus.gd:153 · emit: scripts/systems/product_read.gd:164 · connect: scripts/events/core/signals.gd:38, scripts/debug/endgame_smoke.gd:15203
- line_upgraded(line_id: String, tier: int) · scripts/autoload/event_bus.gd:154 · emit: scripts/systems/sprint_system.gd:1635 · connect: -
- line_completed(line_id: String) · scripts/autoload/event_bus.gd:155 · emit: scripts/systems/sprint_system.gd:1637 · connect: -
- delighter_shipped(step_id: String) · scripts/autoload/event_bus.gd:156 · emit: scripts/systems/sprint_system.gd:1638 · connect: -
- sprint_planned(number: int) · scripts/autoload/event_bus.gd:160 · emit: scripts/systems/sprint_system.gd:67,203 · connect: scripts/ui/components/inbox.gd:162, scripts/ui/components/top_bar.gd:124
- sprint_started(number: int) · scripts/autoload/event_bus.gd:161
  ↳ sprint_started emit: scripts/systems/sprint_system.gd:172
  ↳ sprint_started connect: scripts/ui/components/inbox.gd:162, scripts/ui/components/top_bar.gd:125, scripts/ui/office/office_people.gd:93, scripts/debug/endgame_smoke.gd:23241, scripts/debug/run_probe.gd:487
- card_phase_changed(card_id: String, phase: int) · scripts/autoload/event_bus.gd:162 · emit: scripts/systems/sprint_system.gd:1241 · connect: -
- card_done(card_id: String) · scripts/autoload/event_bus.gd:163 · emit: scripts/systems/sprint_system.gd:1245 · connect: -
- card_carried_over(card_id: String) · scripts/autoload/event_bus.gd:164 · emit: scripts/systems/sprint_system.gd:411,1698 · connect: -
- sprint_closed(number: int) · scripts/autoload/event_bus.gd:165 · emit: scripts/systems/sprint_system.gd:1704 · connect: scripts/main/game_shell.gd:27, scripts/debug/endgame_smoke.gd:20839, scripts/debug/run_probe.gd:486
- card_decision_requested(card_id: String) · scripts/autoload/event_bus.gd:166 · emit: scripts/systems/sprint_system.gd:1412 · connect: scripts/debug/endgame_smoke.gd:23461,24887,25001,25036,25075,25138 +1
- sprint_auto_started(number: int) · scripts/autoload/event_bus.gd:167 · emit: scripts/systems/sprint_system.gd:1577 · connect: -
- product_state_changed() · scripts/autoload/event_bus.gd:168 · emit: scripts/systems/sprint_system.gd:1766 · connect: scripts/tabs/product_tab.gd:111, scripts/ui/components/build_bar.gd:46
- research_started(node_id: String) · scripts/autoload/event_bus.gd:172
  ↳ research_started emit: scripts/systems/rnd_system.gd:279
  ↳ research_started connect: scripts/tabs/rnd_tab.gd:70, scripts/ui/components/build_hud_panel.gd:49, scripts/ui/components/left_tabs.gd:118, scripts/ui/components/research_bar.gd:49
- research_completed(node_id: String) · scripts/autoload/event_bus.gd:173
  ↳ research_completed emit: scripts/systems/rnd_system.gd:462
  ↳ research_completed connect: scripts/tabs/rnd_tab.gd:70, scripts/ui/components/build_hud_panel.gd:50, scripts/ui/components/left_tabs.gd:119, scripts/ui/components/research_bar.gd:50
- research_frozen(node_id: String) · scripts/autoload/event_bus.gd:174
  ↳ research_frozen emit: scripts/systems/rnd_system.gd:145
  ↳ research_frozen connect: scripts/tabs/rnd_tab.gd:71, scripts/ui/components/build_hud_panel.gd:50, scripts/ui/components/left_tabs.gd:120, scripts/ui/components/research_bar.gd:51
- research_resumed(node_id: String) · scripts/autoload/event_bus.gd:175
  ↳ research_resumed emit: scripts/systems/rnd_system.gd:147
  ↳ research_resumed connect: scripts/tabs/rnd_tab.gd:71, scripts/ui/components/build_hud_panel.gd:50, scripts/ui/components/left_tabs.gd:121, scripts/ui/components/research_bar.gd:52
- node_revealed(node_id: String) · scripts/autoload/event_bus.gd:176 · emit: scripts/systems/rnd_system.gd:481 · connect: scripts/tabs/rnd_tab.gd:72
- hidden_line_unlocked(line_id: String) · scripts/autoload/event_bus.gd:177 · emit: scripts/systems/rnd_system.gd:502 · connect: scripts/tabs/rnd_tab.gd:72
- product_note_issued(day: int) · scripts/autoload/event_bus.gd:179 · emit: scripts/systems/message_system.gd:60 · connect: scripts/main/main.gd:4769, scripts/ui/components/left_tabs.gd:122
- research_progress_changed() · scripts/autoload/event_bus.gd:184 · emit: scripts/autoload/time_manager.gd:402 · connect: scripts/tabs/rnd_tab.gd:73, scripts/ui/components/build_hud_panel.gd:53, scripts/ui/components/research_bar.gd:48
- product_note_read() · scripts/autoload/event_bus.gd:185 · emit: scripts/systems/rnd_system.gd:659 · connect: scripts/ui/components/left_tabs.gd:123
- rnd_node_requested(node_id: String, open_assign: bool) · scripts/autoload/event_bus.gd:189
  ↳ rnd_node_requested emit: scripts/main/main.gd:2490,2504, scripts/tabs/product_tab.gd:302, scripts/ui/components/research_bar.gd:194, scripts/debug/product_fixtures.gd:63
  ↳ rnd_node_requested connect: scripts/tabs/rnd_tab.gd:80
- rival_status_changed(rival_id: String, status: String) · scripts/autoload/event_bus.gd:194 · emit: scripts/autoload/rival_registry.gd:83 · connect: scripts/tabs/finance/finance_ozet_view.gd:79
- rival_advanced() · scripts/autoload/event_bus.gd:195 · emit: scripts/autoload/rival_registry.gd:86 · connect: scripts/tabs/finance/finance_ozet_view.gd:78
- prospect_added(prospect_id: String) · scripts/autoload/event_bus.gd:198 · emit: scripts/autoload/prospect_registry.gd:49 · connect: scripts/tabs/sales_tab.gd:66
- prospect_removed(prospect_id: String) · scripts/autoload/event_bus.gd:199 · emit: scripts/autoload/prospect_registry.gd:73 · connect: scripts/tabs/sales_tab.gd:66
- pitch_requested(prospect_id: String) · scripts/autoload/event_bus.gd:201 · emit: scripts/tabs/sales_tab.gd:412 · connect: scripts/main/main.gd:4765
- pitch_finished() · scripts/autoload/event_bus.gd:203 · emit: scripts/systems/sales_meeting_system.gd:120, scripts/systems/vc_pitch_system.gd:125,387 · connect: scripts/tabs/hunt_tab.gd:48, scripts/tabs/sales_tab.gd:76
- prospect_arrived(prospect_id: String) · scripts/autoload/event_bus.gd:208 · emit: scripts/systems/sales_faucet_system.gd:243 · connect: scripts/tabs/sales_tab.gd:67, scripts/debug/run_probe.gd:498
- lead_expired(prospect_id: String) · scripts/autoload/event_bus.gd:209 · emit: scripts/systems/sales_faucet_system.gd:71 · connect: scripts/tabs/sales_tab.gd:67
- lead_reserved(prospect_id: String) · scripts/autoload/event_bus.gd:210 · emit: scripts/systems/sales_ledger.gd:61 · connect: scripts/tabs/sales_tab.gd:68
- lead_routed(prospect_id: String) · scripts/autoload/event_bus.gd:211 · emit: scripts/systems/sales_ledger.gd:63 · connect: scripts/tabs/sales_tab.gd:68
- lead_unrouted(prospect_id: String) · scripts/autoload/event_bus.gd:212 · emit: scripts/systems/sales_ledger.gd:65 · connect: scripts/tabs/sales_tab.gd:68
- meeting_entered(prospect_id: String) · scripts/autoload/event_bus.gd:213 · emit: scripts/systems/sales_meeting_system.gd:100 · connect: scripts/debug/run_probe.gd:493
- meeting_won(prospect_id: String) · scripts/autoload/event_bus.gd:214 · emit: scripts/systems/sales_meeting_system.gd:322 · connect: -
- meeting_lost(account_key: String, reason: String) · scripts/autoload/event_bus.gd:215 · emit: scripts/systems/sales_ledger.gd:190 · connect: scripts/debug/run_probe.gd:496
- deal_signed(customer_id: String, seats: int, seat_price: int) · scripts/autoload/event_bus.gd:216 · emit: scripts/systems/sales_system.gd:407 · connect: scripts/tabs/sales_tab.gd:70, scripts/debug/run_probe.gd:495
- deal_walked(account_key: String) · scripts/autoload/event_bus.gd:217 · emit: scripts/systems/sales_finalizer.gd:55 · connect: scripts/tabs/sales_tab.gd:70
- rep_deal_closed(rep_id: String, customer_id: String) · scripts/autoload/event_bus.gd:218 · emit: scripts/systems/sales_rep_system.gd:272 · connect: scripts/tabs/sales_tab.gd:70
- rep_deal_lost(rep_id: String, prospect_id: String, area: String) · scripts/autoload/event_bus.gd:219 · emit: scripts/systems/sales_rep_system.gd:255 · connect: scripts/debug/endgame_smoke.gd:8938, scripts/debug/run_probe.gd:497
- rep_discount_requested(rep_id: String, prospect_id: String) · scripts/autoload/event_bus.gd:220 · emit: scripts/systems/sales_rep_system.gd:233 · connect: scripts/debug/endgame_smoke.gd:8675
- pitch_promise_made(account_key: String, feature_id: String) · scripts/autoload/event_bus.gd:221 · emit: scripts/systems/sales_finalizer.gd:100 · connect: -
- pitch_promise_kept(account_key: String) · scripts/autoload/event_bus.gd:222 · emit: scripts/systems/b2b_sales_system.gd:523 · connect: -
- pitch_promise_broken(account_key: String) · scripts/autoload/event_bus.gd:223 · emit: scripts/systems/b2b_sales_system.gd:521 · connect: -
- whale_condition_met(prospect_id: String) · scripts/autoload/event_bus.gd:224 · emit: scripts/systems/sales_faucet_system.gd:96 · connect: -
- weekly_sales_report_issued(closes: int) · scripts/autoload/event_bus.gd:225 · emit: scripts/systems/sales_rep_system.gd:315 · connect: scripts/debug/endgame_smoke.gd:9003,19727
- price_stance_changed(stance: String) · scripts/autoload/event_bus.gd:226 · emit: scripts/systems/sales_ledger.gd:135 · connect: scripts/tabs/sales_tab.gd:69
- rep_band_cap_changed(rep_id: String) · scripts/autoload/event_bus.gd:227 · emit: scripts/systems/sales_ledger.gd:109 · connect: scripts/tabs/sales_tab.gd:69
- mentor_advisory_changed(key: String, args: Dictionary) · scripts/autoload/event_bus.gd:231
  ↳ mentor_advisory_changed emit: scripts/events/core/effects.gd:625, scripts/systems/sprint_bridges.gd:134, scripts/systems/vc_pitch_system.gd:890, scripts/debug/endgame_smoke.gd:6583,23344
  ↳ mentor_advisory_changed connect: scripts/autoload/game_state.gd:346, scripts/tabs/hunt_tab.gd:59, scripts/ui/office/office_notice_stack.gd:43
- headline_added(source: String, line: Dictionary) · scripts/autoload/event_bus.gd:236
  ↳ headline_added emit: scripts/events/core/effects.gd:552, scripts/events/present/ticker.gd:25, scripts/systems/hr_morale_system.gd:41,264, scripts/systems/hr_search_system.gd:306, scripts/systems/hr_system.gd:100 +3
  ↳ headline_added connect: scripts/autoload/time_manager.gd:85, scripts/tabs/hr_tab.gd:75, scripts/ui/components/news_ticker.gd:72, scripts/debug/endgame_smoke.gd:19687
- ticker_live_line(source: String, line: Dictionary) · scripts/autoload/event_bus.gd:239
  ↳ ticker_live_line emit: scripts/systems/news_feed_system.gd:405, scripts/systems/sprint_bridges.gd:89, scripts/systems/summary_system.gd:88,92, scripts/ui/office/office_travel.gd:123
  ↳ ticker_live_line connect: scripts/ui/components/news_ticker.gd:73, scripts/debug/endgame_smoke.gd:1396,1517,26584
- phase_gate_reached(next_phase: int) · scripts/autoload/event_bus.gd:243
  ↳ phase_gate_reached emit: scripts/systems/phase_gate_system.gd:85
  ↳ phase_gate_reached connect: scripts/events/core/signals.gd:36, scripts/tabs/finance/finance_ozet_view.gd:69, scripts/debug/endgame_smoke.gd:74, scripts/debug/run_probe.gd:490
- run_ended(ending_id: String, ending_data: Dictionary) · scripts/autoload/event_bus.gd:245
  ↳ run_ended emit: scripts/systems/endings_system.gd:484
  ↳ run_ended connect: scripts/main/main.gd:4766, scripts/debug/endgame_smoke.gd:75,1875, scripts/debug/run_probe.gd:1200
- milestone_reached(milestone_id: String, ending_data: Dictionary) · scripts/autoload/event_bus.gd:248
  ↳ milestone_reached emit: scripts/systems/endings_system.gd:448
  ↳ milestone_reached connect: scripts/main/main.gd:4767, scripts/debug/endgame_smoke.gd:13532, scripts/debug/run_probe.gd:501
- shutter_changed(weeks_left: int) · scripts/autoload/event_bus.gd:250 · emit: scripts/autoload/game_state.gd:425 · connect: scripts/tabs/finance/finance_ozet_view.gd:80, scripts/tabs/finance_tab.gd:51, scripts/ui/components/top_bar.gd:109
- month_ended(month_close: Dictionary) · scripts/autoload/event_bus.gd:253
  ↳ month_ended emit: scripts/systems/summary_system.gd:126
  ↳ month_ended connect: scripts/autoload/save_manager.gd:62, scripts/tabs/finance/finance_ozet_view.gd:68, scripts/ui/components/top_bar.gd:112, scripts/debug/endgame_smoke.gd:1395, scripts/debug/run_probe.gd:489
- summary_ready(data: Dictionary) · scripts/autoload/event_bus.gd:256 · emit: scripts/systems/message_system.gd:58 · connect: scripts/main/main.gd:4768, scripts/debug/endgame_smoke.gd:1394,1516
- meeting_scene_requested(view_state: Dictionary) · scripts/autoload/event_bus.gd:261 · emit: scripts/systems/vc_pitch_system.gd:104 · connect: scripts/main/main.gd:2088,4571,4770
- sheet_granted(vc_id: String) · scripts/autoload/event_bus.gd:264
  ↳ sheet_granted emit: scripts/systems/vc_pitch_system.gd:417,872
  ↳ sheet_granted connect: scripts/events/core/signals.gd:33, scripts/tabs/finance/finance_ozet_view.gd:75, scripts/tabs/hunt_tab.gd:46, scripts/ui/components/inbox.gd:159
- sheet_expired(vc_id: String) · scripts/autoload/event_bus.gd:265
  ↳ sheet_expired emit: scripts/systems/vc_pitch_system.gd:644
  ↳ sheet_expired connect: scripts/events/core/signals.gd:32, scripts/tabs/finance/finance_ozet_view.gd:76, scripts/tabs/hunt_tab.gd:46, scripts/ui/components/inbox.gd:159
- callback_ready(vc_id: String) · scripts/autoload/event_bus.gd:266 · emit: scripts/systems/vc_pitch_system.gd:889 · connect: scripts/tabs/hunt_tab.gd:46
- meeting_day(vc_id: String) · scripts/autoload/event_bus.gd:267 · emit: scripts/systems/vc_pitch_system.gd:903 · connect: scripts/events/core/signals.gd:35, scripts/tabs/hunt_tab.gd:47
- offer_countdown_changed(weeks_left: int) · scripts/autoload/event_bus.gd:268 · emit: scripts/systems/vc_pitch_system.gd:914 · connect: scripts/ui/components/top_bar.gd:117
- term_table_requested(vc_id: String, stage: String) · scripts/autoload/event_bus.gd:269 · emit: scripts/events/core/effects.gd:579,598, scripts/main/game_shell.gd:163, scripts/tabs/hunt_tab.gd:521 · connect: scripts/main/main.gd:4771
- sheet_walked(vc_id: String) · scripts/autoload/event_bus.gd:270
  ↳ sheet_walked emit: scripts/systems/vc_pitch_system.gd:628
  ↳ sheet_walked connect: scripts/tabs/finance/finance_ozet_view.gd:77, scripts/tabs/hunt_tab.gd:48, scripts/ui/components/inbox.gd:160, scripts/debug/endgame_smoke.gd:1903
- seed_door_opened() · scripts/autoload/event_bus.gd:274 · emit: scripts/systems/seed_round_system.gd:75 · connect: scripts/tabs/finance_tab.gd:53, scripts/tabs/hunt_tab.gd:49
- seed_sheet_granted(vc_id: String) · scripts/autoload/event_bus.gd:275 · emit: scripts/systems/vc_pitch_system.gd:405 · connect: scripts/events/core/signals.gd:34, scripts/tabs/hunt_tab.gd:49
- seed_round_closed(vc_id: String) · scripts/autoload/event_bus.gd:276 · emit: scripts/systems/seed_round_system.gd:183 · connect: scripts/tabs/hunt_tab.gd:49, scripts/ui/components/inbox.gd:162
- office_move_started(office_id: String, arrival_day: int) · scripts/autoload/event_bus.gd:280 · emit: scripts/systems/office_system.gd:69 · connect: scripts/ui/office/office_hud.gd:61
- office_changed(office_id: String) · scripts/autoload/event_bus.gd:281 · emit: scripts/systems/office_system.gd:85 · connect: scripts/ui/office/office_hud.gd:55,62, scripts/ui/office/office_view.gd:63, scripts/debug/endgame_smoke.gd:20693
- day_tick_completed(day: int) · scripts/autoload/event_bus.gd:286
  ↳ day_tick_completed emit: scripts/autoload/time_manager.gd:434
  ↳ day_tick_completed connect: scripts/autoload/save_manager.gd:61, scripts/events/tools/plausibility.gd:159, scripts/tabs/sales_tab.gd:76, scripts/ui/components/inbox.gd:159, scripts/ui/office/office_city.gd:102 +4
- game_loaded(slot_id: String) · scripts/autoload/event_bus.gd:289 · emit: scripts/main/main.gd:5277 · connect: scripts/ui/components/left_tabs.gd:126
- system_menu_requested() · scripts/autoload/event_bus.gd:291 · emit: scripts/main/game_shell.gd:106, scripts/main/main.gd:1964,2595,2617 · connect: scripts/main/main.gd:4772
- save_load_requested(mode: String) · scripts/autoload/event_bus.gd:293 · emit: scripts/main/main.gd:2597,2601, scripts/menu/main_menu.gd:55, scripts/modals/system_menu_modal.gd:37,38 · connect: scripts/main/main.gd:89
- quicksave_requested() · scripts/autoload/event_bus.gd:296 · emit: scripts/main/game_shell.gd:65, scripts/main/main.gd:1940,1945,2622 · connect: scripts/main/main.gd:4773
- quickload_requested() · scripts/autoload/event_bus.gd:297 · emit: scripts/main/game_shell.gd:67, scripts/main/main.gd:1937,1965,1970,1976 · connect: scripts/main/main.gd:4774
- debug_onboarding_retrigger_requested() · scripts/autoload/event_bus.gd:301 · emit: scripts/main/game_shell.gd:144 · connect: scripts/main/main.gd:103

### scripts/autoload/time_manager.gd
- speed_changed(new_speed: int) · scripts/autoload/time_manager.gd:44
  ↳ speed_changed emit: scripts/autoload/time_manager.gd:323,339
  ↳ speed_changed connect: scripts/systems/sprint_system.gd:1521, scripts/ui/components/top_bar.gd:120,121, scripts/ui/office/office_notice_stack.gd:47, scripts/debug/endgame_smoke.gd:13857
- hold_changed() · scripts/autoload/time_manager.gd:46 · emit: scripts/autoload/time_manager.gd:357,363 · connect: scripts/tabs/hunt_tab.gd:55, scripts/ui/components/top_bar.gd:122, scripts/ui/office/office_notice_stack.gd:48

### scripts/menu/credits.gd
- dismissed() · scripts/menu/credits.gd:6 · (ad 7 yerde tanımlı)
  ↳ dismissed emit: scripts/menu/credits.gd:59, scripts/menu/licenses.gd:79, scripts/modals/confirm_modal.gd:64, scripts/modals/hr_action_modal.gd:225,236, scripts/modals/save_load_modal.gd:261 +2
  ↳ dismissed connect: scripts/main/main.gd:5116,5141,5160,5194, scripts/menu/credits.gd:47, scripts/modals/settings_modal.gd:264 +1

### scripts/menu/godot_card.gd
- finished() · scripts/menu/godot_card.gd:6 · emit: scripts/menu/godot_card.gd:35 · connect: scripts/main/main.gd:118, scripts/ui/components/radial_dial.gd:53

### scripts/menu/licenses.gd
- back() · scripts/menu/licenses.gd:7 · emit: scripts/menu/licenses.gd:28 · connect: scripts/menu/credits.gd:44
- dismissed() · scripts/menu/licenses.gd:8 · (ad 7 yerde tanımlı)
  ↳ dismissed emit: scripts/menu/credits.gd:59, scripts/menu/licenses.gd:79, scripts/modals/confirm_modal.gd:64, scripts/modals/hr_action_modal.gd:225,236, scripts/modals/save_load_modal.gd:261 +2
  ↳ dismissed connect: scripts/main/main.gd:5116,5141,5160,5194, scripts/menu/credits.gd:47, scripts/modals/settings_modal.gd:264 +1

### scripts/menu/main_menu.gd
- new_game_requested() · scripts/menu/main_menu.gd:7 · emit: scripts/main/main.gd:2856, scripts/menu/main_menu.gd:54 · connect: scripts/main/main.gd:130
- load_requested(slot_id: String) · scripts/menu/main_menu.gd:8 · emit: scripts/menu/main_menu.gd:53, scripts/modals/save_load_modal.gd:237,239 · connect: scripts/main/main.gd:133,5196 · (ad 2 yerde tanımlı)

### scripts/modals/confirm_modal.gd
- confirmed() · scripts/modals/confirm_modal.gd:11 · emit: scripts/modals/hr_action_modal.gd:224 · connect: scripts/main/main.gd:5136, scripts/onboarding/onboarding_flow.gd:177 · (ad 2 yerde tanımlı)
- alt_selected() · scripts/modals/confirm_modal.gd:12 · emit: - · connect: scripts/main/main.gd:5140
- dismissed() · scripts/modals/confirm_modal.gd:13 · (ad 7 yerde tanımlı)
  ↳ dismissed emit: scripts/menu/credits.gd:59, scripts/menu/licenses.gd:79, scripts/modals/confirm_modal.gd:64, scripts/modals/hr_action_modal.gd:225,236, scripts/modals/save_load_modal.gd:261 +2
  ↳ dismissed connect: scripts/main/main.gd:5116,5141,5160,5194, scripts/menu/credits.gd:47, scripts/modals/settings_modal.gd:264 +1

### scripts/modals/ending_scene.gd
- continue_requested() · scripts/modals/ending_scene.gd:40 · emit: scripts/modals/ending_scene.gd:445 · connect: scripts/main/main.gd:5328
- main_menu_requested() · scripts/modals/ending_scene.gd:41 · emit: scripts/modals/ending_scene.gd:462, scripts/modals/system_menu_modal.gd:63 · connect: scripts/main/main.gd:5161,5329 · (ad 2 yerde tanımlı)

### scripts/modals/hr_action_modal.gd
- confirmed() · scripts/modals/hr_action_modal.gd:15 · emit: scripts/modals/hr_action_modal.gd:224 · connect: scripts/main/main.gd:5136, scripts/onboarding/onboarding_flow.gd:177 · (ad 2 yerde tanımlı)
- dismissed() · scripts/modals/hr_action_modal.gd:16 · (ad 7 yerde tanımlı)
  ↳ dismissed emit: scripts/menu/credits.gd:59, scripts/menu/licenses.gd:79, scripts/modals/confirm_modal.gd:64, scripts/modals/hr_action_modal.gd:225,236, scripts/modals/save_load_modal.gd:261 +2
  ↳ dismissed connect: scripts/main/main.gd:5116,5141,5160,5194, scripts/menu/credits.gd:47, scripts/modals/settings_modal.gd:264 +1

### scripts/modals/save_load_modal.gd
- dismissed() · scripts/modals/save_load_modal.gd:14 · (ad 7 yerde tanımlı)
  ↳ dismissed emit: scripts/menu/credits.gd:59, scripts/menu/licenses.gd:79, scripts/modals/confirm_modal.gd:64, scripts/modals/hr_action_modal.gd:225,236, scripts/modals/save_load_modal.gd:261 +2
  ↳ dismissed connect: scripts/main/main.gd:5116,5141,5160,5194, scripts/menu/credits.gd:47, scripts/modals/settings_modal.gd:264 +1
- save_requested(slot_id: String) · scripts/modals/save_load_modal.gd:15 · emit: scripts/modals/save_load_modal.gd:229 · connect: scripts/main/main.gd:5195
- load_requested(slot_id: String) · scripts/modals/save_load_modal.gd:16 · emit: scripts/menu/main_menu.gd:53, scripts/modals/save_load_modal.gd:237,239 · connect: scripts/main/main.gd:133,5196 · (ad 2 yerde tanımlı)

### scripts/modals/settings_modal.gd
- dismissed() · scripts/modals/settings_modal.gd:16 · (ad 7 yerde tanımlı)
  ↳ dismissed emit: scripts/menu/credits.gd:59, scripts/menu/licenses.gd:79, scripts/modals/confirm_modal.gd:64, scripts/modals/hr_action_modal.gd:225,236, scripts/modals/save_load_modal.gd:261 +2
  ↳ dismissed connect: scripts/main/main.gd:5116,5141,5160,5194, scripts/menu/credits.gd:47, scripts/modals/settings_modal.gd:264 +1

### scripts/modals/system_menu_modal.gd
- dismissed() · scripts/modals/system_menu_modal.gd:18 · (ad 7 yerde tanımlı)
  ↳ dismissed emit: scripts/menu/credits.gd:59, scripts/menu/licenses.gd:79, scripts/modals/confirm_modal.gd:64, scripts/modals/hr_action_modal.gd:225,236, scripts/modals/save_load_modal.gd:261 +2
  ↳ dismissed connect: scripts/main/main.gd:5116,5141,5160,5194, scripts/menu/credits.gd:47, scripts/modals/settings_modal.gd:264 +1
- main_menu_requested() · scripts/modals/system_menu_modal.gd:19 · emit: scripts/modals/ending_scene.gd:462, scripts/modals/system_menu_modal.gd:63 · connect: scripts/main/main.gd:5161,5329 · (ad 2 yerde tanımlı)
- exit_save_requested() · scripts/modals/system_menu_modal.gd:20 · emit: scripts/modals/system_menu_modal.gd:93 · connect: scripts/main/main.gd:5162

### scripts/modals/term_sheet_table_scene.gd
- closed() · scripts/modals/term_sheet_table_scene.gd:17 · (ad 3 yerde tanımlı)
  ↳ closed emit: scripts/main/main.gd:2124, scripts/modals/term_sheet_table_scene.gd:401,409,422, scripts/tabs/rnd/rnd_assign_panel.gd:203, scripts/ui/meeting/meeting_panel.gd:359
  ↳ closed connect: scripts/main/main.gd:5089,5376, scripts/tabs/rnd/rnd_detail_panel.gd:77

### scripts/onboarding/first_week_doc.gd
- picked(field: String, value: Variant) · scripts/onboarding/first_week_doc.gd:7 · (ad 2 yerde tanımlı)
  ↳ picked emit: scripts/onboarding/first_week_doc.gd:134,176, scripts/ui/meeting/meeting_ruler.gd:48
  ↳ picked connect: scripts/onboarding/onboarding_flow.gd:60, scripts/ui/meeting/meeting_ruler.gd:85

### scripts/onboarding/onboarding_flow.gd
- completed() · scripts/onboarding/onboarding_flow.gd:11 · emit: scripts/onboarding/onboarding_flow.gd:203 · connect: scripts/main/main.gd:154
- cancelled() · scripts/onboarding/onboarding_flow.gd:12 · emit: scripts/onboarding/onboarding_flow.gd:172,177 · connect: scripts/main/main.gd:155

### scripts/onboarding/steps/step_base.gd
- changed() · scripts/onboarding/steps/step_base.gd:15 · (ad 2 yerde tanımlı)
  ↳ changed emit: scripts/main/main.gd:2921,4518, scripts/onboarding/steps/character_step.gd:32,53,111, scripts/onboarding/steps/company_step.gd:35 +8
  ↳ changed connect: scripts/onboarding/onboarding_flow.gd:101, scripts/ui/meeting/meeting_panel.gd:274,511

### scripts/tabs/finance_tab.gd
- fit_changed() · scripts/tabs/finance_tab.gd:10 · (ad 7 yerde tanımlı)
  ↳ fit_changed emit: scripts/tabs/finance_tab.gd:48,125, scripts/tabs/hr/hr_dossier.gd:46, scripts/tabs/hr_tab.gd:265, scripts/tabs/personal_tab.gd:50, scripts/tabs/product_tab.gd:187 +4
  ↳ fit_changed connect: scripts/ui/components/window_layer.gd:169

### scripts/tabs/hr/hr_dossier.gd
- close_requested() · scripts/tabs/hr/hr_dossier.gd:11 · emit: scripts/tabs/hr/hr_dossier.gd:83,132 · connect: scripts/ui/components/window_frame.gd:62
- fit_changed() · scripts/tabs/hr/hr_dossier.gd:12 · (ad 7 yerde tanımlı)
  ↳ fit_changed emit: scripts/tabs/finance_tab.gd:48,125, scripts/tabs/hr/hr_dossier.gd:46, scripts/tabs/hr_tab.gd:265, scripts/tabs/personal_tab.gd:50, scripts/tabs/product_tab.gd:187 +4
  ↳ fit_changed connect: scripts/ui/components/window_layer.gd:169

### scripts/tabs/hr/hr_panel.gd
- state_changed() · scripts/tabs/hr/hr_panel.gd:9 · emit: scripts/modals/training_modal.gd:174, scripts/modals/work_hours_modal.gd:491, scripts/tabs/hr/hr_atlas_modal.gd:445,471,489 · connect: scripts/tabs/hr/hr_ui_shared.gd:85

### scripts/tabs/hr_tab.gd
- fit_changed() · scripts/tabs/hr_tab.gd:22 · (ad 7 yerde tanımlı)
  ↳ fit_changed emit: scripts/tabs/finance_tab.gd:48,125, scripts/tabs/hr/hr_dossier.gd:46, scripts/tabs/hr_tab.gd:265, scripts/tabs/personal_tab.gd:50, scripts/tabs/product_tab.gd:187 +4
  ↳ fit_changed connect: scripts/ui/components/window_layer.gd:169

### scripts/tabs/personal_tab.gd
- fit_changed() · scripts/tabs/personal_tab.gd:23 · (ad 7 yerde tanımlı)
  ↳ fit_changed emit: scripts/tabs/finance_tab.gd:48,125, scripts/tabs/hr/hr_dossier.gd:46, scripts/tabs/hr_tab.gd:265, scripts/tabs/personal_tab.gd:50, scripts/tabs/product_tab.gd:187 +4
  ↳ fit_changed connect: scripts/ui/components/window_layer.gd:169

### scripts/tabs/product/area_panel.gd
- action(kind: String, args: Dictionary) · scripts/tabs/product/area_panel.gd:9 · (ad 5 yerde tanımlı)
  ↳ action emit: scripts/tabs/product/area_panel.gd:166,209, scripts/tabs/product/overview_view.gd:47,66,67,89 +17
  ↳ action connect: scripts/tabs/product/area_panel.gd:166, scripts/tabs/product/quarter_view.gd:57, scripts/tabs/product/sprint_panel.gd:362, scripts/tabs/product_tab.gd:70,77,80 +1
- ui_changed(open_area: String) · scripts/tabs/product/area_panel.gd:10 · emit: scripts/tabs/product/area_panel.gd:232 · connect: scripts/tabs/product_tab.gd:71

### scripts/tabs/product/overview_view.gd
- action(kind: String, args: Dictionary) · scripts/tabs/product/overview_view.gd:7 · (ad 5 yerde tanımlı)
  ↳ action emit: scripts/tabs/product/area_panel.gd:166,209, scripts/tabs/product/overview_view.gd:47,66,67,89 +17
  ↳ action connect: scripts/tabs/product/area_panel.gd:166, scripts/tabs/product/quarter_view.gd:57, scripts/tabs/product/sprint_panel.gd:362, scripts/tabs/product_tab.gd:70,77,80 +1

### scripts/tabs/product/quarter_view.gd
- action(kind: String, args: Dictionary) · scripts/tabs/product/quarter_view.gd:8 · (ad 5 yerde tanımlı)
  ↳ action emit: scripts/tabs/product/area_panel.gd:166,209, scripts/tabs/product/overview_view.gd:47,66,67,89 +17
  ↳ action connect: scripts/tabs/product/area_panel.gd:166, scripts/tabs/product/quarter_view.gd:57, scripts/tabs/product/sprint_panel.gd:362, scripts/tabs/product_tab.gd:70,77,80 +1

### scripts/tabs/product/sprint_card.gd
- action(kind: String, args: Dictionary) · scripts/tabs/product/sprint_card.gd:15 · (ad 5 yerde tanımlı)
  ↳ action emit: scripts/tabs/product/area_panel.gd:166,209, scripts/tabs/product/overview_view.gd:47,66,67,89 +17
  ↳ action connect: scripts/tabs/product/area_panel.gd:166, scripts/tabs/product/quarter_view.gd:57, scripts/tabs/product/sprint_panel.gd:362, scripts/tabs/product_tab.gd:70,77,80 +1

### scripts/tabs/product/sprint_panel.gd
- action(kind: String, args: Dictionary) · scripts/tabs/product/sprint_panel.gd:8 · (ad 5 yerde tanımlı)
  ↳ action emit: scripts/tabs/product/area_panel.gd:166,209, scripts/tabs/product/overview_view.gd:47,66,67,89 +17
  ↳ action connect: scripts/tabs/product/area_panel.gd:166, scripts/tabs/product/quarter_view.gd:57, scripts/tabs/product/sprint_panel.gd:362, scripts/tabs/product_tab.gd:70,77,80 +1

### scripts/tabs/product/type_picker.gd
- chosen(subtype: String, name: String) · scripts/tabs/product/type_picker.gd:10 · emit: scripts/tabs/product/type_picker.gd:65 · connect: scripts/tabs/product_tab.gd:101, scripts/debug/endgame_smoke.gd:14215

### scripts/tabs/product_tab.gd
- fit_changed() · scripts/tabs/product_tab.gd:12 · (ad 7 yerde tanımlı)
  ↳ fit_changed emit: scripts/tabs/finance_tab.gd:48,125, scripts/tabs/hr/hr_dossier.gd:46, scripts/tabs/hr_tab.gd:265, scripts/tabs/personal_tab.gd:50, scripts/tabs/product_tab.gd:187 +4
  ↳ fit_changed connect: scripts/ui/components/window_layer.gd:169

### scripts/tabs/rnd/rnd_assign_panel.gd
- started() · scripts/tabs/rnd/rnd_assign_panel.gd:18 · emit: scripts/tabs/rnd/rnd_assign_panel.gd:230,232 · connect: scripts/tabs/rnd/rnd_detail_panel.gd:76
- closed() · scripts/tabs/rnd/rnd_assign_panel.gd:20 · (ad 3 yerde tanımlı)
  ↳ closed emit: scripts/main/main.gd:2124, scripts/modals/term_sheet_table_scene.gd:401,409,422, scripts/tabs/rnd/rnd_assign_panel.gd:203, scripts/ui/meeting/meeting_panel.gd:359
  ↳ closed connect: scripts/main/main.gd:5089,5376, scripts/tabs/rnd/rnd_detail_panel.gd:77

### scripts/tabs/rnd/rnd_tree_view.gd
- selection_changed(node_id: String) · scripts/tabs/rnd/rnd_tree_view.gd:35 · emit: scripts/tabs/rnd/rnd_tree_view.gd:339 · connect: scripts/tabs/rnd_tab.gd:144

### scripts/tabs/rnd_tab.gd
- fit_changed() · scripts/tabs/rnd_tab.gd:28 · (ad 7 yerde tanımlı)
  ↳ fit_changed emit: scripts/tabs/finance_tab.gd:48,125, scripts/tabs/hr/hr_dossier.gd:46, scripts/tabs/hr_tab.gd:265, scripts/tabs/personal_tab.gd:50, scripts/tabs/product_tab.gd:187 +4
  ↳ fit_changed connect: scripts/ui/components/window_layer.gd:169

### scripts/tabs/sales_tab.gd
- fit_changed() · scripts/tabs/sales_tab.gd:17 · (ad 7 yerde tanımlı)
  ↳ fit_changed emit: scripts/tabs/finance_tab.gd:48,125, scripts/tabs/hr/hr_dossier.gd:46, scripts/tabs/hr_tab.gd:265, scripts/tabs/personal_tab.gd:50, scripts/tabs/product_tab.gd:187 +4
  ↳ fit_changed connect: scripts/ui/components/window_layer.gd:169

### scripts/ui/components/news_ticker.gd
- open_changed(open: bool) · scripts/ui/components/news_ticker.gd:53 · emit: scripts/ui/components/news_ticker.gd:108 · connect: scripts/main/game_shell.gd:30

### scripts/ui/components/radial_dial.gd
- spin_finished() · scripts/ui/components/radial_dial.gd:9 · emit: scripts/ui/components/radial_dial.gd:70 · connect: scripts/modals/term_sheet_table_scene.gd:72

### scripts/ui/meeting/meeting_panel.gd
- closed() · scripts/ui/meeting/meeting_panel.gd:19 · (ad 3 yerde tanımlı)
  ↳ closed emit: scripts/main/main.gd:2124, scripts/modals/term_sheet_table_scene.gd:401,409,422, scripts/tabs/rnd/rnd_assign_panel.gd:203, scripts/ui/meeting/meeting_panel.gd:359
  ↳ closed connect: scripts/main/main.gd:5089,5376, scripts/tabs/rnd/rnd_detail_panel.gd:77

### scripts/ui/meeting/meeting_panel_option.gd
- clicked() · scripts/ui/meeting/meeting_panel_option.gd:9 · (ad 2 yerde tanımlı)
  ↳ clicked emit: scripts/ui/meeting/meeting_panel_option.gd:87, scripts/ui/office/office_camera.gd:138
  ↳ clicked connect: scripts/ui/meeting/meeting_panel.gd:678, scripts/ui/office/office_view.gd:62
- hovered(on: bool) · scripts/ui/meeting/meeting_panel_option.gd:10 · emit: scripts/ui/meeting/meeting_panel_option.gd:125 · connect: scripts/ui/meeting/meeting_panel.gd:679

### scripts/ui/meeting/meeting_ruler.gd
- changed(value: int) · scripts/ui/meeting/meeting_ruler.gd:13 · (ad 2 yerde tanımlı)
  ↳ changed emit: scripts/main/main.gd:2921,4518, scripts/onboarding/steps/character_step.gd:32,53,111, scripts/onboarding/steps/company_step.gd:35 +8
  ↳ changed connect: scripts/onboarding/onboarding_flow.gd:101, scripts/ui/meeting/meeting_panel.gd:274,511
- picked(value: int) · scripts/ui/meeting/meeting_ruler.gd:28 · (ad 2 yerde tanımlı)
  ↳ picked emit: scripts/onboarding/first_week_doc.gd:134,176, scripts/ui/meeting/meeting_ruler.gd:48
  ↳ picked connect: scripts/onboarding/onboarding_flow.gd:60, scripts/ui/meeting/meeting_ruler.gd:85

### scripts/ui/menu_backdrop.gd
- live_ready() · scripts/ui/menu_backdrop.gd:9 · emit: scripts/ui/menu_backdrop.gd:138 · connect: scripts/main/main.gd:2740,2769,2826,2855,2894, scripts/onboarding/onboarding_flow.gd:70

### scripts/ui/office/meeting_cast.gd
- founder_seated() · scripts/ui/office/meeting_cast.gd:14 · emit: scripts/ui/office/meeting_cast.gd:152 · connect: scripts/main/main.gd:2024, scripts/ui/office/office_travel.gd:88
- founder_out() · scripts/ui/office/meeting_cast.gd:15 · emit: scripts/ui/office/meeting_cast.gd:155 · connect: scripts/ui/office/office_travel.gd:98

### scripts/ui/office/meeting_invite.gd
- accepted() · scripts/ui/office/meeting_invite.gd:14 · emit: scripts/ui/office/meeting_invite.gd:191 · connect: scripts/main/main.gd:4966
- postponed() · scripts/ui/office/meeting_invite.gd:15 · emit: scripts/ui/office/meeting_invite.gd:198 · connect: scripts/main/main.gd:4967

### scripts/ui/office/office_camera.gd
- clicked(screen_pos: Vector2) · scripts/ui/office/office_camera.gd:8 · (ad 2 yerde tanımlı)
  ↳ clicked emit: scripts/ui/meeting/meeting_panel_option.gd:87, scripts/ui/office/office_camera.gd:138
  ↳ clicked connect: scripts/ui/meeting/meeting_panel.gd:678, scripts/ui/office/office_view.gd:62

### scripts/ui/office/office_city.gd
- road_done() · scripts/ui/office/office_city.gd:14 · emit: scripts/ui/office/office_city.gd:152 · connect: scripts/ui/office/office_travel.gd:82,102

### scripts/ui/office/office_hud.gd
- move_pressed() · scripts/ui/office/office_hud.gd:10 · emit: scripts/ui/office/office_hud.gd:49, scripts/ui/office/office_map_card.gd:147 · connect: scripts/ui/office/office_city.gd:112,379 · (ad 2 yerde tanımlı)

### scripts/ui/office/office_map_card.gd
- cancel_pressed() · scripts/ui/office/office_map_card.gd:8 · emit: scripts/ui/office/office_map_card.gd:133 · connect: scripts/ui/office/office_city.gd:378
- move_pressed() · scripts/ui/office/office_map_card.gd:9 · emit: scripts/ui/office/office_hud.gd:49, scripts/ui/office/office_map_card.gd:147 · connect: scripts/ui/office/office_city.gd:112,379 · (ad 2 yerde tanımlı)

### scripts/ui/office/office_people.gd
- founder_arrived() · scripts/ui/office/office_people.gd:16 · emit: scripts/ui/office/office_people.gd:235 · connect: scripts/ui/office/office_travel.gd:75
- founder_settled() · scripts/ui/office/office_people.gd:17 · emit: scripts/ui/office/office_people.gd:142,239,658 · connect: scripts/main/main.gd:2123, scripts/ui/office/office_travel.gd:106

## Sahneler (39 .tscn)

Biçim: yol · kök düğüm türü (örnek: = miras alınan sahne) · kök betik
- scenes/debug/ThemeProbe.tscn · Control · -
- scenes/main/GameShell.tscn · Control · scripts/main/game_shell.gd
- scenes/main/Main.tscn · Node · scripts/main/main.gd
- scenes/menu/Credits.tscn · Control · scripts/menu/credits.gd
- scenes/menu/GodotCard.tscn · Control · scripts/menu/godot_card.gd
- scenes/menu/Licenses.tscn · Control · scripts/menu/licenses.gd
- scenes/menu/MainMenu.tscn · Control · scripts/menu/main_menu.gd
- scenes/menu/MenuBackdrop.tscn · Control · scripts/ui/menu_backdrop.gd
- scenes/modals/ConfirmModal.tscn · Control · scripts/modals/confirm_modal.gd
- scenes/modals/EndingScene.tscn · Control · scripts/modals/ending_scene.gd
- scenes/modals/HRActionModal.tscn · Control · scripts/modals/hr_action_modal.gd
- scenes/modals/HRAtlasModal.tscn · Control · scripts/tabs/hr/hr_atlas_modal.gd
- scenes/modals/SaveLoadModal.tscn · Control · scripts/modals/save_load_modal.gd
- scenes/modals/SettingsModal.tscn · Control · scripts/modals/settings_modal.gd
- scenes/modals/SystemMenuModal.tscn · Control · scripts/modals/system_menu_modal.gd
- scenes/modals/TermSheetTableScene.tscn · Control · scripts/modals/term_sheet_table_scene.gd
- scenes/modals/TrainingModal.tscn · Control · scripts/modals/training_modal.gd
- scenes/modals/WorkHoursModal.tscn · Control · scripts/modals/work_hours_modal.gd
- scenes/office/OfficeView.tscn · Control · scripts/ui/office/office_view.gd
- scenes/onboarding/OnboardingFlow.tscn · Control · scripts/onboarding/onboarding_flow.gd
- scenes/onboarding/steps/CharacterStep.tscn · Control · scripts/onboarding/steps/character_step.gd
- scenes/onboarding/steps/CompanyStep.tscn · Control · scripts/onboarding/steps/company_step.gd
- scenes/onboarding/steps/OriginTraitsStep.tscn · Control · scripts/onboarding/steps/origin_traits_step.gd
- scenes/tabs/EventsTab.tscn · Control · scripts/tabs/events_tab.gd
- scenes/tabs/FinanceTab.tscn · Control · scripts/tabs/finance_tab.gd
- scenes/tabs/HRTab.tscn · Control · scripts/tabs/hr_tab.gd
- scenes/tabs/PersonalTab.tscn · Control · scripts/tabs/personal_tab.gd
- scenes/tabs/PiyasaTab.tscn · Control · scripts/tabs/piyasa_tab.gd
- scenes/tabs/ProductTab.tscn · Control · scripts/tabs/product_tab.gd
- scenes/tabs/RnDTab.tscn · Control · scripts/tabs/rnd_tab.gd
- scenes/tabs/SalesTab.tscn · Control · scripts/tabs/sales_tab.gd
- scenes/tabs/product/SprintCard.tscn · PanelContainer · scripts/tabs/product/sprint_card.gd
- scenes/ui/components/BuildBar.tscn · PanelContainer · scripts/ui/components/build_bar.gd
- scenes/ui/components/BuildHUDPanel.tscn · Control · scripts/ui/components/build_hud_panel.gd
- scenes/ui/components/DialoguePortraitCard.tscn · PanelContainer · scripts/ui/components/dialogue_portrait_card.gd
- scenes/ui/components/LeftTabs.tscn · Panel · scripts/ui/components/left_tabs.gd
- scenes/ui/components/NewsTicker.tscn · Panel · scripts/ui/components/news_ticker.gd
- scenes/ui/components/ResearchBar.tscn · PanelContainer · scripts/ui/components/research_bar.gd
- scenes/ui/components/TopBar.tscn · Panel · scripts/ui/components/top_bar.gd

## Veri dosyaları (180 .json, data/)

Biçim: yol · boyut · üst düzey anahtarlar (en çok 10)
- data/credits.json · 419 B · {_, year, holder, roles}
- data/events/arcs/fixture_subject.json · 684 B · {id, type, steps, invalidate_when, on_invalidate, _note}
- data/events/arcs/fixture_thesis.json · 491 B · {id, type, restartable, steps, invalidate_when, on_invalidate}
- data/events/arcs/soft_cap_stretch.json · 1.2 KB · {id, type, subject, restartable, steps, invalidate_when, on_invalidate, _note}
- data/events/cards/_fixtures/b2_chips.json · 1.6 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +6}
- data/events/cards/_fixtures/concurrent.json · 611 B · {id, version_scope, category, tick, class, tags, expires_weeks, expire_note, on_expire, latch, +2}
- data/events/cards/_fixtures/first_customer.json · 1.7 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +8}
- data/events/cards/_fixtures/hourly_ambient.json · 1.1 KB · {id, version_scope, category, tick, class, tags, weight, allowed_hours, min_gap_weeks, condition, +7}
- data/events/cards/_fixtures/lint_v3/_bad_c1.json · 1.0 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_o1.json · 1.1 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_o2.json · 973 B · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_o3.json · 996 B · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_o3_delta.json · 1.0 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_o4.json · 1.1 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +4}
- data/events/cards/_fixtures/lint_v3/_bad_o5.json · 1.0 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_o5_ea.json · 1.1 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +4}
- data/events/cards/_fixtures/lint_v3/_bad_p1.json · 1.0 KB · {_port_note, id, schema, category, tick, class, tags, family_subject, delay_weeks, plausibility, +2}
- data/events/cards/_fixtures/lint_v3/_bad_p2.json · 984 B · {_port_note, id, category, tick, class, tags, family, family_subject, delay_weeks, plausibility, +2}
- data/events/cards/_fixtures/lint_v3/_bad_p3.json · 1.2 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +4}
- data/events/cards/_fixtures/lint_v3/_bad_t1.json · 1.1 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +5}
- data/events/cards/_fixtures/lint_v3/_bad_t2.json · 1.1 KB · {_port_note, id, schema, category, tick, class, tags, family, delay_weeks, plausibility, +3}
- data/events/cards/_fixtures/lint_v3/_bad_t3.json · 1.1 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +4}
- data/events/cards/_fixtures/lint_v3/_bad_v1.json · 1.1 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_v2.json · 1.0 KB · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/lint_v3/_bad_v3.json · 977 B · {_port_note, id, schema, category, tick, class, tags, family, family_subject, delay_weeks, +3}
- data/events/cards/_fixtures/paper_crunch.json · 1.9 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +9}
- data/events/cards/_fixtures/paper_design.json · 2.0 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +13}
- data/events/cards/_fixtures/paper_dev.json · 2.2 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +13}
- data/events/cards/_fixtures/paper_founder.json · 1.9 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +13}
- data/events/cards/_fixtures/paper_plain.json · 1.7 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +9}
- data/events/cards/_fixtures/paper_pm.json · 2.0 KB · {id, version_scope, schema, category, tick, class, tags, family, delay_weeks, delay_reason, +13}
- data/events/cards/_fixtures/subject_close.json · 956 B · {version_scope, category, tick, class, expires_weeks, tags, latch, id, _port_note, options, +1}
- data/events/cards/_fixtures/subject_open.json · 1.0 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, arc, scope, +3}
- data/events/cards/_fixtures/subject_reassign.json · 953 B · {version_scope, category, tick, class, expires_weeks, tags, latch, id, _port_note, options, +1}
- data/events/cards/_fixtures/thesis_close.json · 535 B · {id, version_scope, category, tick, class, expires_weeks, tags, latch, options, text}
- data/events/cards/_fixtures/thesis_open.json · 1.3 KB · {id, version_scope, category, tick, class, expires_weeks, tags, latch, options, text, +2}
- data/events/cards/_fixtures/thesis_payoff.json · 945 B · {id, version_scope, category, tick, class, expires_weeks, tags, arc, latch, condition, +2}
- data/events/cards/_fixtures/v3_compile.json · 1.7 KB · {_port_note, id, version_scope, schema, category, tick, class, tags, family, delay_weeks, +6}
- data/events/cards/customer/b2c_refunds.json · 2.5 KB · {id, _note, version_scope, category, tick, class, tags, schema, family, delay_weeks, +10}
- data/events/cards/customer/chargeback.json · 4.0 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +10}
- data/events/cards/customer/cs_escalation.json · 4.9 KB · {_port_note, id, version_scope, category, tick, class, tags, schema, family, family_subject, +12}
- data/events/cards/customer/expansion.json · 2.1 KB · {_port_note, id, version_scope, category, tick, class, tags, schema, system, family, +11}
- data/events/cards/customer/frank_intro.json · 2.4 KB · {id, version_scope, category, sender, tick, class, tags, schema, system, family, +10}
- data/events/cards/customer/incident_month_close.json · 4.3 KB · {id, version_scope, category, tick, class, sender_title, system, tags, schema, family, +10}
- data/events/cards/customer/leak_questions.json · 2.7 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, follows, +11}
- data/events/cards/customer/named_in_leak.json · 3.9 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +11}
- data/events/cards/customer/new_owner.json · 4.4 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +10}
- data/events/cards/customer/new_owner_group.json · 3.0 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, follows, +12}
- data/events/cards/customer/price_break.json · 3.4 KB · {_doc, _wiring_note, _expiry_note, id, version_scope, category, tick, class, tags, schema, +13}
- data/events/cards/customer/release_thanks.json · 3.4 KB · {id, version_scope, category, tick, class, system, tags, schema, family, plausibility, +6}
- data/events/cards/customer/request_complaint.json · 4.3 KB · {version_scope, category, tick, class, tags, schema, system, family, family_subject, plausibility, +12}
- data/events/cards/customer/request_feature.json · 4.6 KB · {version_scope, category, tick, class, tags, schema, system, family, family_subject, plausibility, +12}
- data/events/cards/customer/request_renewal.json · 3.2 KB · {version_scope, category, tick, class, tags, schema, system, family, family_subject, plausibility, +12}
- data/events/cards/customer/retention.json · 6.1 KB · {_port_note, id, version_scope, category, tick, class, tags, schema, family, delay_weeks, +14}
- data/events/cards/customer/security_review.json · 3.2 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +11}
- data/events/cards/founder/company_of_one.json · 1.6 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, delay_reason, +9}
- data/events/cards/founder/domain_name.json · 1.7 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/events/cards/founder/friends_test.json · 1.8 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/events/cards/founder/meetup_talk.json · 2.4 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +9}
- data/events/cards/founder/savings_note.json · 1.6 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, delay_reason, +9}
- data/events/cards/founder/side_contract.json · 2.4 KB · {id, _note, version_scope, category, tick, class, tags, schema, family, delay_weeks, +10}
- data/events/cards/founder/unseen_build.json · 1.6 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, delay_reason, +9}
- data/events/cards/funding/acquisition_offer.json · 3.0 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +8}
- data/events/cards/funding/closing_docs.json · 2.9 KB · {id, version_scope, category, sender, tick, trigger, class, tags, schema, family, +11}
- data/events/cards/funding/closing_docs_diligence.json · 3.8 KB · {id, version_scope, category, sender, tick, trigger, class, tags, schema, family, +12}
- data/events/cards/funding/closing_docs_series_a.json · 3.3 KB · {id, version_scope, category, sender, tick, trigger, class, tags, schema, family, +11}
- data/events/cards/funding/frank_approach_close.json · 2.0 KB · {_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/frank_approach_half.json · 2.4 KB · {_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/frank_approach_near.json · 2.2 KB · {_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/frank_cheque.json · 2.0 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/frank_door_open.json · 2.3 KB · {_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/frank_office_move.json · 1.6 KB · {_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/frank_v1.json · 1.4 KB · {id, version_scope, category, speaker, tick, trigger, class, tags, schema, system, +9}
- data/events/cards/funding/gate_series_a.json · 2.6 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/gate_traction.json · 1.9 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/hire_nudge.json · 1.8 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/last_answer.json · 1.5 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/monthly_update.json · 6.3 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, delay_weeks, +10}
- data/events/cards/funding/portfolio_vendor.json · 3.7 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, delay_weeks, +10}
- data/events/cards/funding/portfolio_vendor_trial.json · 3.0 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, follows, +13}
- data/events/cards/funding/seed_closed.json · 1.3 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/seed_door.json · 1.7 KB · {_worked_example, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/funding/seed_offer.json · 2.5 KB · {_worked_example, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +8}
- data/events/cards/funding/seed_stalled.json · 1.8 KB · {_worked_example, id, version_scope, category, tick, class, tags, schema, system, family, +9}
- data/events/cards/funding/sheet_decision.json · 3.6 KB · {_design, id, version_scope, category, tick, allowed_hours, class, expires_weeks, tags, schema, +9}
- data/events/cards/funding/sheet_expiry.json · 2.2 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +9}
- data/events/cards/funding/shutter_warning.json · 1.6 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/product/b2c_floor_churn.json · 3.2 KB · {id, _note, version_scope, category, tick, class, tags, schema, family, delay_weeks, +11}
- data/events/cards/product/b2c_floor_signal.json · 2.6 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +10}
- data/events/cards/product/incident_checkout.json · 4.1 KB · {id, version_scope, category, tick, class, system, tags, schema, family, family_subject, +10}
- data/events/cards/product/incident_outage_b2b.json · 6.8 KB · {id, version_scope, category, tick, class, sender, sender_desk, system, tags, schema, +11}
- data/events/cards/product/incident_outage_b2c.json · 4.6 KB · {id, version_scope, category, tick, class, sender, sender_desk, system, tags, schema, +11}
- data/events/cards/product/incident_regression.json · 10.4 KB · {id, version_scope, category, tick, class, system, tags, schema, family, family_subject, +9}
- data/events/cards/product/incident_review_storm.json · 5.3 KB · {id, version_scope, category, tick, class, system, tags, schema, family, family_subject, +9}
- data/events/cards/product/launch_leak.json · 2.7 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +9}
- data/events/cards/product/paid_tier.json · 2.3 KB · {id, version_scope, category, sender, tick, class, tags, schema, system, family, +10}
- data/events/cards/product/promise_due.json · 4.4 KB · {id, version_scope, category, tick, class, sender, system, tags, schema, family, +11}
- data/events/cards/product/repeat_reminders.json · 4.3 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +11}
- data/events/cards/product/sprint_design_color_blind.json · 2.8 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +14}
- data/events/cards/product/sprint_design_customer_colors.json · 5.1 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_design_drawings_late.json · 2.8 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +14}
- data/events/cards/product/sprint_design_empty_state.json · 2.7 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_design_empty_state_b2c.json · 2.5 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_design_first_screen.json · 2.8 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_design_gloves.json · 3.1 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_design_notifications.json · 2.5 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_dev_backfill.json · 2.6 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +14}
- data/events/cards/product/sprint_dev_import_tool.json · 3.4 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +14}
- data/events/cards/product/sprint_dev_multi_currency.json · 3.1 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +14}
- data/events/cards/product/sprint_dev_old_phones.json · 3.0 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +14}
- data/events/cards/product/sprint_dev_relogin.json · 2.6 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +14}
- data/events/cards/product/sprint_dev_root_cause.json · 2.5 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +13}
- data/events/cards/product/sprint_dev_security_update.json · 2.4 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +14}
- data/events/cards/product/sprint_dev_shorter_path.json · 2.4 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +13}
- data/events/cards/product/sprint_dev_unasked_rewrite.json · 3.9 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +14}
- data/events/cards/product/sprint_founder_test_pile.json · 3.0 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +13}
- data/events/cards/product/sprint_late.json · 3.6 KB · {id, version_scope, category, tick, class, sender, system, tags, schema, family, +15}
- data/events/cards/product/sprint_late_solo.json · 3.6 KB · {id, version_scope, category, tick, class, sender, system, tags, schema, family, +14}
- data/events/cards/product/sprint_pm_core_first.json · 3.0 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_pm_phone_too.json · 3.5 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_pm_phone_too_b2c.json · 3.5 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_pm_renewal.json · 2.9 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_pm_scope_grew.json · 2.6 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_pm_spec_unclear.json · 3.0 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_pm_spec_unclear_b2c.json · 3.1 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_pm_two_accounts.json · 3.0 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_solo_backup.json · 2.3 KB · {id, version_scope, category, tick, class, tags, schema, family, speaker_role, stage, +13}
- data/events/cards/product/sprint_solo_rushed_code.json · 2.6 KB · {id, version_scope, category, tick, class, tags, schema, family, speaker_role, stage, +12}
- data/events/cards/product/sprint_solo_server_bill.json · 2.8 KB · {id, version_scope, category, tick, class, tags, schema, family, speaker_role, stage, +13}
- data/events/cards/product/sprint_solo_signup_code.json · 2.6 KB · {id, version_scope, category, tick, class, tags, schema, family, speaker_role, stage, +13}
- data/events/cards/product/sprint_solo_watch.json · 2.5 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, speaker_role, +14}
- data/events/cards/product/sprint_test_after_midnight.json · 2.5 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +14}
- data/events/cards/product/sprint_test_coupon.json · 2.8 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_test_devices.json · 2.8 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_test_readonly_delete.json · 3.1 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_test_slow_many.json · 2.7 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_test_slow_many_b2c.json · 2.5 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_test_stock_transfer.json · 3.0 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_test_their_data.json · 2.8 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +15}
- data/events/cards/product/sprint_test_too_much.json · 3.2 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, family_subject, +14}
- data/events/cards/product/sprint_untested_old_screens.json · 3.8 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +13}
- data/events/cards/product/sprint_untested_own_code.json · 2.4 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, speaker_role, +13}
- data/events/cards/product/support_overflow.json · 3.1 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +10}
- data/events/cards/product/working_parts.json · 2.0 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, delay_weeks, +10}
- data/events/cards/rival/copycat.json · 2.8 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +10}
- data/events/cards/rival/copycat_reply.json · 2.6 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, follows, +11}
- data/events/cards/rival/false_partner.json · 4.7 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +10}
- data/events/cards/rival/funding_round.json · 3.1 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/events/cards/rival/price_cut.json · 4.3 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +9}
- data/events/cards/rival/shutdown_notice.json · 3.2 KB · {id, version_scope, category, tick, class, sender, tags, schema, family, delay_weeks, +10}
- data/events/cards/team/burnout.json · 2.5 KB · {id, version_scope, category, tick, class, expires_weeks, tags, schema, system, family, +8}
- data/events/cards/team/conference_trip.json · 3.4 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, family_subject, +12}
- data/events/cards/team/demo_day.json · 1.8 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, delay_reason, +9}
- data/events/cards/team/first_weeks.json · 1.8 KB · {id, version_scope, category, sender, tick, class, tags, family, scope, latch, +7}
- data/events/cards/team/lead_overtime.json · 5.2 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, family_subject, +12}
- data/events/cards/team/outside_offer.json · 2.8 KB · {id, version_scope, category, tick, class, tags, schema, family, family_subject, delay_weeks, +11}
- data/events/cards/team/password_rule.json · 3.9 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, family_subject, +12}
- data/events/cards/team/resignation.json · 1.9 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +8}
- data/events/cards/team/wiped_table.json · 3.0 KB · {id, version_scope, category, sender, tick, class, tags, schema, family, family_subject, +11}
- data/events/cards/unwired/design_round_intro.json · 1.3 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, speaker, latch, +2}
- data/events/cards/unwired/first_ship.json · 1.1 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, speaker, latch, +2}
- data/events/cards/unwired/version_ship.json · 1.5 KB · {_port_note, id, version_scope, category, tick, class, expires_weeks, tags, speaker, latch, +2}
- data/events/cards/world/analyst_guide.json · 2.2 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/events/cards/world/app_placement.json · 2.0 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/events/cards/world/b2c_creator_feature.json · 2.2 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/events/cards/world/final_stretch_comment.json · 3.1 KB · {_worked_example, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +7}
- data/events/cards/world/final_stretch_press.json · 3.0 KB · {_worked_example, id, version_scope, category, tick, class, tags, schema, system, family, +9}
- data/events/cards/world/final_stretch_verdict.json · 2.9 KB · {_worked_example, id, version_scope, category, tick, class, expires_weeks, tags, schema, system, +9}
- data/events/cards/world/newsletter_slot.json · 2.0 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/events/cards/world/trade_fair.json · 2.0 KB · {id, version_scope, category, tick, class, tags, schema, family, delay_weeks, plausibility, +8}
- data/graphics/presets.json · 2.1 KB · {_, presets, detect}
- data/market/companies.json · 30.8 KB · {meta, companies}
- data/market/people.json · 6.1 KB · {people}
- data/product/lines/erp.json · 4.9 KB · {subtype, _doc, _anchor, _telegraph, shared_gate_overrides, lines}
- data/product/lines/note_tool.json · 4.3 KB · {subtype, _doc, _canon, _anchor, lines}
- data/product/lines/shared.json · 3.7 KB · {_doc, _profile_shape, _numbers, _nodes, lines}
- data/product/lines/video_clip.json · 4.5 KB · {subtype, _doc, _usage, _anchor, lines}
- data/product/rivals.json · 5.3 KB · {note_tool, video_clip, erp}
- data/product/sprint.json · 9.2 KB · {sprint_weeks, quarter_weeks, mvp_lines, effort, fix_effort, limit_k, need, roles, role_areas, person_points_week, +27}
- data/techtree/rnd_tree.json · 6.3 KB · {_doc, _stars, _cross, _areas, k_arge, report_period_weeks, nodes, _hidden_doc, _hidden_k3_doc, hidden_lines}

## Metin anahtarı aileleri (833 aile, 3195 anahtar)

Aile = anahtarın ilk iki '_' parçası. Dosyalar: aile önekini metin olarak geçiren .gd/.json (en çok 5). '-' = dinamik kurulmuş olabilir ya da kullanılmıyor.
- ANGEL_CAP_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- ANGEL_CHOICE_* · 3 · data/events/cards/funding/frank_cheque.json
- ANGEL_EVENT_* · 2 · data/events/cards/funding/frank_cheque.json
- ANGEL_MONTH_* · 1 · scripts/systems/angel_round_system.gd
- ANGEL_NUDGE_* · 3 · data/events/cards/funding/hire_nudge.json
- ANGEL_TX_* · 1 · scripts/systems/finance_system.gd
- B2B_CHOICE_* · 17 · data/events/cards/customer/cs_escalation.json, data/events/cards/customer/expansion.json, data/events/cards/customer/request_complaint.json, data/events/cards/customer/request_feature.json +2
- B2B_COMPLAINT_* · 14 · scripts/systems/b2b_constants.gd, scripts/debug/endgame_smoke.gd
- B2B_CONTACT_* · 14 · scripts/systems/b2b_constants.gd, scripts/debug/endgame_smoke.gd
- B2B_DISCOUNT_* · 1 · data/events/cards/customer/request_renewal.json, data/events/cards/customer/retention.json, data/events/cards/rival/false_partner.json, data/events/cards/rival/price_cut.json, scripts/systems/b2b_constants.gd +1
- B2B_EV_* · 14 · data/events/cards/customer/cs_escalation.json, data/events/cards/customer/expansion.json, data/events/cards/customer/request_complaint.json, data/events/cards/customer/request_feature.json +3
- B2B_EXPANSION_* · 1 · data/events/cards/customer/expansion.json
- B2B_LOCK_* · 6 · data/events/cards/customer/cs_escalation.json, data/events/cards/customer/request_complaint.json, data/events/cards/customer/request_feature.json, data/events/cards/customer/retention.json +2
- B2B_RISK_* · 6 · scripts/systems/b2b_sales_system.gd
- BUILD_BUSY_* · 1 · scripts/systems/rnd_system.gd
- BUILD_PHASE_* · 1 · scripts/ui/components/build_bar.gd
- BUILD_SPLIT_* · 1 · scripts/ui/components/build_bar_model.gd, scripts/debug/endgame_smoke.gd
- BUILD_SUPPORT_* · 1 · scripts/ui/components/build_bar.gd
- CHEQUE_NEXT_* · 1 · scripts/ui/components/inbox.gd
- CHEQUE_STEP_* · 5 · scripts/systems/cheque_read.gd
- CHEQUE_TITLE_* · 1 · scripts/systems/cheque_read.gd
- CLOCK_HELD_* · 1 · scripts/autoload/time_manager.gd, scripts/main/game_shell.gd
- CLOCK_HOLD_* · 3 · scripts/autoload/time_manager.gd
- CREDITS_COPYRIGHT_* · 1 · scripts/menu/credits.gd
- CREDITS_LICENSES_* · 1 · scripts/menu/licenses.gd, scripts/modals/settings_modal.gd
- CREDITS_ROLE_* · 5 · data/credits.json
- CREDITS_TITLE_* · 1 · scripts/menu/credits.gd
- DATE_LINE_* · 1 · scripts/ui/components/top_bar.gd, scripts/util/fmt.gd
- DESK_PAPER_* · 10 · scripts/events/present/chips.gd, scripts/tabs/events_tab.gd, scripts/tabs/product/sprint_card.gd, scripts/theme/ui_tokens.gd, scripts/ui/components/inbox.gd +2
- EFFECT_AN_* · 1 · scripts/events/present/chips.gd
- EFFECT_APP_* · 1 · scripts/events/present/chips.gd
- EFFECT_AUDIENCE_* · 3 · scripts/events/present/chips.gd, scripts/debug/endgame_smoke.gd
- EFFECT_AXIS_* · 1 · scripts/events/present/chips.gd
- EFFECT_BRAND_* · 1 · scripts/events/present/chips.gd
- EFFECT_CARD_* · 4 · scripts/events/present/chips.gd, scripts/debug/endgame_smoke.gd
- EFFECT_CASH_* · 1 · scripts/events/present/chips.gd
- EFFECT_CHANCE_* · 1 · scripts/events/present/chips.gd
- EFFECT_CHURN_* · 1 · scripts/events/present/chips.gd
- EFFECT_CONVERT_* · 1 · scripts/events/present/chips.gd
- EFFECT_CUSTOMER_* · 1 · scripts/events/present/chips.gd
- EFFECT_DEPARTURE_* · 1 · scripts/events/present/chips.gd
- EFFECT_EQUITY_* · 1 · scripts/events/present/chips.gd
- EFFECT_EXPAND_* · 1 · scripts/events/present/chips.gd
- EFFECT_FIX_* · 1 · scripts/events/present/chips.gd
- EFFECT_FIXED_* · 2 · scripts/events/present/chips.gd
- EFFECT_FREE_* · 1 · scripts/events/present/chips.gd
- EFFECT_FUND_* · 1 · scripts/events/present/chips.gd
- EFFECT_INVESTOR_* · 1 · scripts/events/present/chips.gd
- EFFECT_LATER_* · 3 · scripts/events/present/chips.gd
- EFFECT_LEAVE_* · 1 · scripts/events/present/chips.gd
- EFFECT_LINE_* · 1 · scripts/events/present/chips.gd
- EFFECT_MARKETING_* · 2 · scripts/events/present/chips.gd
- EFFECT_MORALE_* · 1 · scripts/events/present/chips.gd
- EFFECT_NAMES_* · 1 · scripts/events/present/chips.gd, scripts/debug/endgame_smoke.gd
- EFFECT_NEW_* · 3 · scripts/events/present/chips.gd
- EFFECT_NEXT_* · 2 · scripts/events/present/chips.gd
- EFFECT_NIGHT_* · 1 · scripts/events/present/chips.gd
- EFFECT_NO_* · 1 · scripts/events/present/chips.gd
- EFFECT_ONE_* · 1 · scripts/events/present/chips.gd
- EFFECT_OUTAGE_* · 2 · scripts/events/present/chips.gd
- EFFECT_PACE_* · 3 · scripts/events/present/chips.gd
- EFFECT_PAID_* · 1 · scripts/events/present/chips.gd
- EFFECT_PHASE_* · 2 · scripts/events/present/chips.gd
- EFFECT_PROMISE_* · 4 · scripts/events/present/chips.gd, scripts/debug/endgame_smoke.gd
- EFFECT_REPUTATION_* · 1 · scripts/events/present/chips.gd
- EFFECT_RETAIN_* · 3 · scripts/events/present/chips.gd
- EFFECT_RUN_* · 1 · scripts/events/present/chips.gd
- EFFECT_SATISFACTION_* · 1 · scripts/events/present/chips.gd
- EFFECT_SEATS_* · 1 · scripts/events/present/chips.gd
- EFFECT_SEED_* · 1 · scripts/events/present/chips.gd
- EFFECT_SERVICE_* · 1 · scripts/events/present/chips.gd
- EFFECT_SHIP_* · 2 · scripts/events/present/chips.gd
- EFFECT_SPRINT_* · 4 · scripts/events/present/chips.gd, scripts/debug/endgame_smoke.gd
- EFFECT_TAKES_* · 1 · scripts/events/present/chips.gd
- EFFECT_TEAM_* · 1 · scripts/events/present/chips.gd
- EFFECT_TERM_* · 1 · scripts/events/present/chips.gd
- EFFECT_TEST_* · 1 · scripts/events/present/chips.gd, scripts/debug/endgame_smoke.gd
- EFFECT_TO_* · 1 · scripts/events/present/chips.gd
- EFFECT_TRUST_* · 6 · scripts/events/present/chips.gd, scripts/debug/endgame_smoke.gd
- EFFECT_VC_* · 1 · scripts/events/present/chips.gd
- EFFECT_WORK_* · 3 · scripts/events/present/chips.gd
- ENDING_BADGE_* · 1 · scripts/modals/ending_scene.gd, scripts/ui/components/left_tabs.gd
- ENDING_CARD_* · 6 · scripts/modals/ending_scene.gd
- ENDING_ENGRAVING_* · 1 · scripts/modals/ending_scene.gd
- ENDING_FRANK_* · 1 · scripts/modals/ending_scene.gd
- ENDING_HARD_* · 1 · scripts/modals/ending_scene.gd
- ENDING_MAIN_* · 1 · scripts/modals/ending_scene.gd, scripts/debug/endgame_smoke.gd
- ENDING_MILESTONE_* · 2 · scripts/modals/ending_scene.gd
- ENDING_NEXT_* · 1 · scripts/modals/ending_scene.gd
- ENDING_OPEN_* · 1 · scripts/modals/ending_scene.gd, scripts/debug/kit_probe.gd
- ENDING_RETRY_* · 1 · scripts/modals/ending_scene.gd, scripts/debug/endgame_smoke.gd
- ENDING_RUN_* · 2 · scripts/modals/ending_scene.gd
- ENDING_SAVED_* · 1 · scripts/modals/ending_scene.gd, scripts/debug/kit_probe.gd
- ENDING_SHARE_* · 1 · scripts/modals/ending_scene.gd, scripts/debug/endgame_smoke.gd
- ENDING_SOON_* · 1 · scripts/modals/ending_scene.gd
- ENDING_WISHLIST_* · 1 · scripts/modals/ending_scene.gd, scripts/debug/endgame_smoke.gd
- END_ACQ_* · 14 · scripts/systems/endings_copy.gd
- END_BC_* · 10 · scripts/systems/endings_copy.gd
- END_BK_* · 12 · scripts/systems/endings_copy.gd
- END_BK1_* · 1 · scripts/systems/endings_copy.gd
- END_BK2_* · 3 · scripts/systems/endings_copy.gd
- END_BK3_* · 3 · scripts/systems/endings_copy.gd
- END_BS_* · 14 · scripts/systems/endings_copy.gd, scripts/debug/endgame_smoke.gd
- END_DATE_* · 1 · scripts/systems/endings_copy.gd
- END_EV_* · 6 · data/events/cards/funding/acquisition_offer.json, data/events/cards/funding/shutter_warning.json
- END_FOUNDING_* · 4 · scripts/systems/endings_copy.gd
- END_GENERIC_* · 6 · scripts/systems/endings_copy.gd
- END_HL_* · 1 · scripts/systems/endings_system.gd
- END_LEDGER_* · 1 · scripts/systems/endings_copy.gd
- END_META_* · 14 · scripts/systems/endings_copy.gd, scripts/systems/endings_system.gd, scripts/debug/endgame_smoke.gd
- END_MILLIONS_* · 1 · scripts/systems/endings_copy.gd
- END_RF_* · 19 · scripts/systems/endings_copy.gd, scripts/debug/endgame_smoke.gd
- END_SA_* · 19 · scripts/systems/endings_copy.gd
- END_SPAN_* · 6 · scripts/systems/endings_copy.gd, scripts/debug/endgame_smoke.gd
- END_STAT_* · 15 · scripts/systems/endings_copy.gd, scripts/debug/endgame_smoke.gd
- END_VC_* · 13 · scripts/systems/endings_copy.gd
- EVENT_CHOICE_* · 1 · scripts/tabs/events/mail_pane.gd
- EVENT_TAG_* · 6 · scripts/events/present/chips.gd, scripts/theme/ui_tokens.gd, scripts/ui/components/inbox.gd, scripts/debug/endgame_smoke.gd
- EV_CUSTOMER_* · 39 · data/events/cards/customer/b2c_refunds.json, data/events/cards/customer/chargeback.json, data/events/cards/customer/leak_questions.json, data/events/cards/customer/named_in_leak.json +3
- EV_FOUNDER_* · 29 · data/events/cards/founder/company_of_one.json, data/events/cards/founder/domain_name.json, data/events/cards/founder/friends_test.json, data/events/cards/founder/meetup_talk.json +3
- EV_FUNDING_* · 35 · data/events/cards/funding/closing_docs.json, data/events/cards/funding/closing_docs_diligence.json, data/events/cards/funding/closing_docs_series_a.json, data/events/cards/funding/monthly_update.json +3
- EV_LOCK_* · 2 · data/events/cards/customer/leak_questions.json, data/events/cards/customer/security_review.json, data/events/cards/founder/meetup_talk.json, data/events/cards/funding/portfolio_vendor.json +5
- EV_MODIFIERS_* · 2 · scripts/events/core/dice.gd
- EV_PRODUCT_* · 28 · data/events/cards/product/b2c_floor_churn.json, data/events/cards/product/b2c_floor_signal.json, data/events/cards/product/launch_leak.json, data/events/cards/product/repeat_reminders.json +2
- EV_RIVAL_* · 33 · data/events/cards/rival/copycat.json, data/events/cards/rival/copycat_reply.json, data/events/cards/rival/false_partner.json, data/events/cards/rival/funding_round.json, data/events/cards/rival/price_cut.json +1
- EV_TEAM_* · 46 · data/events/cards/team/burnout.json, data/events/cards/team/conference_trip.json, data/events/cards/team/demo_day.json, data/events/cards/team/first_weeks.json, data/events/cards/team/lead_overtime.json +5
- EV_WORLD_* · 25 · data/events/cards/world/analyst_guide.json, data/events/cards/world/app_placement.json, data/events/cards/world/b2c_creator_feature.json, data/events/cards/world/newsletter_slot.json +1
- FEATURE_LABEL_* · 13 · scripts/systems/b2b_constants.gd, scripts/debug/endgame_smoke.gd
- FIN_BURN_* · 7 · scripts/main/main.gd, scripts/systems/finance_system.gd, scripts/tabs/finance/finance_ozet_view.gd, scripts/debug/endgame_smoke.gd
- FIN_CAP_* · 7 · scripts/onboarding/first_week_doc.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/finance/finance_ozet_view.gd, scripts/ui/components/inbox.gd, scripts/ui/components/top_bar.gd
- FIN_CAPTABLE_* · 4 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_CASH_* · 1 · scripts/tabs/finance_tab.gd
- FIN_CURVE_* · 5 · scripts/ui/components/cash_curve.gd
- FIN_EQUITY_* · 1 · scripts/systems/term_sheet_table_system.gd
- FIN_EXPENSE_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_GOAL_* · 6 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_INCOME_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_MARKET_* · 4 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_MENTOR_* · 4 · scripts/tabs/finance/finance_ozet_view.gd, scripts/ui/office/office_notice_stack.gd
- FIN_MONTHLY_* · 3 · scripts/tabs/finance/finance_ozet_view.gd, scripts/tabs/finance_tab.gd
- FIN_NET_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_NO_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_OFFICE_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_ONETIME_* · 18 · scripts/systems/finance_system.gd, scripts/systems/office_constants.gd
- FIN_PER_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_PHASE_* · 3 · scripts/autoload/game_state.gd
- FIN_PROFIT_* · 4 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_RANGE_* · 3 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_RECENT_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_REQ_* · 2 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_RUNWAY_* · 1 · scripts/tabs/events/mail_pane.gd, scripts/tabs/finance_tab.gd
- FIN_SNOOZE_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_SUBTAB_* · 3 · scripts/tabs/finance_tab.gd, scripts/tabs/hunt_tab.gd
- FIN_TX_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- FIN_VALUATION_* · 1 · scripts/systems/term_sheet_table_system.gd
- FIXTURE_CONCURRENT_* · 1 · data/events/cards/_fixtures/concurrent.json
- FMT_AGO_* · 6 · scripts/util/fmt.gd
- FRANK_ADVISORY_* · 2 · data/events/cards/customer/frank_intro.json, data/events/cards/product/paid_tier.json, scripts/systems/sprint_bridges.gd, scripts/debug/endgame_smoke.gd
- FRANK_APPROACH_* · 5 · data/events/cards/funding/frank_approach_close.json, data/events/cards/funding/frank_approach_half.json, data/events/cards/funding/frank_approach_near.json, data/events/cards/funding/frank_door_open.json +1
- FRANK_DOOR_* · 1 · data/events/cards/funding/frank_door_open.json, scripts/debug/endgame_smoke.gd
- FRANK_OFFICE_* · 3 · data/events/cards/funding/frank_office_move.json
- GATE_ADVANCE_* · 1 · data/events/cards/funding/gate_series_a.json, scripts/debug/endgame_smoke.gd
- GATE_ANSWER_* · 1 · scripts/autoload/time_manager.gd, scripts/modals/save_load_modal.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/rnd/rnd_assign_panel.gd, scripts/tabs/rnd/rnd_detail_panel.gd
- GATE_DECLINE_* · 1 · data/events/cards/funding/gate_series_a.json
- GATE_OPENED_* · 1 · scripts/systems/phase_gate_system.gd, scripts/debug/endgame_smoke.gd
- GATE_SERIES_* · 4 · data/events/cards/funding/gate_series_a.json, scripts/debug/endgame_smoke.gd
- GATE_TRACTION_* · 3 · data/events/cards/funding/gate_traction.json, scripts/debug/endgame_smoke.gd
- GOAL_STEP_* · 2 · scripts/systems/cheque_read.gd
- GOAL_TOAST_* · 1 · scripts/ui/components/inbox.gd
- HEALTH_AT_* · 1 · -
- HEALTH_CHURNING_* · 1 · -
- HEALTH_HEALTHY_* · 1 · -
- HR_AGENCY_* · 1 · scripts/systems/hr_constants.gd
- HR_APPLY_* · 2 · scripts/tabs/hr/hr_ledger.gd
- HR_AREA_* · 7 · scripts/systems/hr_constants.gd, scripts/tabs/hr/hr_ledger.gd, scripts/debug/kit_probe.gd
- HR_ASSIGN_* · 3 · scripts/tabs/hr/hr_assignments.gd
- HR_ATLAS_* · 23 · scripts/systems/hr_search_system.gd, scripts/tabs/hr/hr_atlas_modal.gd, scripts/tabs/hr_tab.gd, scripts/debug/endgame_smoke.gd
- HR_BADGE_* · 4 · scripts/systems/hr_constants.gd, scripts/tabs/hr/hr_ui_shared.gd, scripts/ui/components/inbox.gd, scripts/debug/kit_probe.gd
- HR_CANDIDATE_* · 1 · scripts/tabs/hr_tab.gd
- HR_CARD_* · 4 · scripts/main/main.gd, scripts/tabs/hr/hr_ledger.gd
- HR_CHIP_* · 2 · scripts/tabs/hr_tab.gd
- HR_COL_* · 9 · scripts/modals/work_hours_modal.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/events_tab.gd, scripts/tabs/hr/hr_assignments.gd, scripts/tabs/hr/hr_dossier.gd +3
- HR_COST_* · 3 · scripts/systems/finance_system.gd, scripts/systems/hr_constants.gd
- HR_DOSSIER_* · 4 · scripts/tabs/hr/hr_dossier.gd, scripts/tabs/personal_tab.gd
- HR_DURATION_* · 2 · scripts/util/fmt.gd, scripts/debug/endgame_smoke.gd
- HR_EMPTY_* · 1 · scripts/tabs/hr/hr_assignments.gd, scripts/tabs/hr_tab.gd, scripts/tabs/product/sprint_panel.gd, scripts/debug/kit_probe.gd
- HR_ERR_* · 7 · scripts/systems/hr_actions.gd
- HR_EV_* · 2 · data/events/cards/team/resignation.json
- HR_FILES_* · 1 · scripts/tabs/hr_tab.gd
- HR_FIRE_* · 2 · scripts/modals/hr_action_modal.gd, scripts/tabs/hr/hr_ledger.gd
- HR_FOUNDER_* · 7 · scripts/systems/hr_system.gd, scripts/debug/endgame_smoke.gd
- HR_GROUP_* · 4 · scripts/systems/hr_constants.gd, scripts/debug/kit_probe.gd
- HR_HIRE_* · 3 · scripts/tabs/hr/hr_atlas_modal.gd
- HR_HOURS_* · 36 · scripts/modals/work_hours_modal.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/hr_tab.gd, scripts/debug/kit_probe.gd
- HR_JOB_* · 6 · scripts/systems/hr_constants.gd, scripts/debug/endgame_smoke.gd
- HR_KPI_* · 2 · scripts/tabs/hr_tab.gd
- HR_LABEL_* · 1 · scripts/autoload/event_bus.gd, scripts/systems/hr_constants.gd
- HR_LEGEND_* · 2 · scripts/tabs/hr/hr_assignments.gd
- HR_LEVEL_* · 5 · scripts/systems/hr_constants.gd, scripts/debug/endgame_smoke.gd
- HR_MENU_* · 2 · scripts/tabs/hr/hr_ledger.gd
- HR_NEWS_* · 7 · scripts/systems/hr_morale_system.gd, scripts/systems/hr_search_system.gd, scripts/systems/hr_system.gd, scripts/debug/endgame_smoke.gd
- HR_OPEN_* · 1 · scripts/tabs/hr_tab.gd
- HR_OVERLOAD_* · 1 · scripts/tabs/hr/hr_ui_shared.gd
- HR_PACE_* · 6 · scripts/systems/hr_system.gd, scripts/tabs/hr/hr_ledger.gd
- HR_PER_* · 1 · scripts/tabs/hr/hr_atlas_modal.gd
- HR_PROMOTION_* · 1 · scripts/systems/hr_actions.gd
- HR_RAISE_* · 1 · scripts/systems/hr_actions.gd
- HR_RESIGN_* · 4 · scripts/systems/hr_constants.gd
- HR_ROLE_* · 20 · scripts/autoload/character_registry.gd, scripts/autoload/game_state.gd, scripts/onboarding/first_week_doc.gd, scripts/onboarding/onboarding_flow.gd, scripts/systems/hr_constants.gd +3
- HR_ROW_* · 10 · scripts/events/present/chips.gd, scripts/systems/hr_actions.gd, scripts/tabs/hr/hr_ledger.gd, scripts/tabs/hr_tab.gd
- HR_SEARCH_* · 5 · scripts/main/main.gd, scripts/tabs/hr/hr_assignments.gd, scripts/tabs/hr_tab.gd, scripts/tabs/product/sprint_panel.gd, scripts/debug/kit_probe.gd
- HR_SEARCHING_* · 2 · scripts/tabs/hr_tab.gd
- HR_SKILL_* · 2 · scripts/tabs/hr/hr_assignments.gd
- HR_STATE_* · 8 · scripts/modals/work_hours_modal.gd, scripts/systems/hr_system.gd, scripts/tabs/hr/hr_ui_shared.gd, scripts/debug/kit_probe.gd
- HR_TAB_* · 2 · scripts/tabs/hr_tab.gd, scripts/debug/kit_probe.gd
- HR_TASK_* · 8 · scripts/systems/hr_system.gd, scripts/tabs/hr/hr_ledger.gd, scripts/debug/kit_probe.gd
- HR_TRAINING_* · 10 · scripts/autoload/character_registry.gd, scripts/modals/training_modal.gd, scripts/tabs/hr/hr_ledger.gd, scripts/tabs/personal_tab.gd, scripts/debug/endgame_smoke.gd
- HR_TRAIT_* · 16 · scripts/systems/hr_constants.gd
- HR_WARN_* · 4 · scripts/systems/hr_search_system.gd
- HUNT_BADGE_* · 8 · scripts/tabs/hunt_tab.gd, scripts/ui/meeting/vc_meeting_adapter.gd
- HUNT_CANCEL_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_CB_* · 4 · scripts/systems/vc_pitch_system.gd, scripts/debug/endgame_smoke.gd
- HUNT_CONDITION_* · 1 · scripts/tabs/hunt_tab.gd, scripts/ui/meeting/vc_meeting_adapter.gd
- HUNT_COUNTER_* · 2 · scripts/tabs/hunt_tab.gd
- HUNT_DECISION_* · 1 · scripts/tabs/hunt_tab.gd, scripts/ui/components/inbox.gd
- HUNT_EMPTY_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_EST_* · 4 · scripts/systems/vc_pitch_system.gd, scripts/tabs/hunt_tab.gd
- HUNT_FRANK_* · 1 · scripts/systems/endings_system.gd, scripts/tabs/hunt_tab.gd
- HUNT_LOCKED_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_MEETING_* · 6 · scripts/tabs/hunt_tab.gd
- HUNT_NEXT_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_NO_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_NONE_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_PAGE_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_QUEUED_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_REQUEST_* · 2 · scripts/tabs/hunt_tab.gd
- HUNT_RESCHEDULE_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_ROAD_* · 1 · scripts/tabs/hunt_tab.gd, scripts/debug/endgame_smoke.gd
- HUNT_SEC_* · 3 · scripts/tabs/hunt_tab.gd
- HUNT_SIT_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_THIS_* · 1 · scripts/tabs/hunt_tab.gd
- HUNT_TIER2_* · 1 · scripts/autoload/investor_registry.gd, scripts/tabs/hunt_tab.gd
- HUNT_VALIDITY_* · 2 · scripts/tabs/hunt_tab.gd
- HUNT_WALK_* · 4 · scripts/tabs/hunt_tab.gd
- HUNT_WEEKS_* · 1 · scripts/tabs/hunt_tab.gd
- INBOX_ALL_* · 1 · scripts/tabs/events_tab.gd
- INBOX_CHOICE_* · 1 · scripts/ui/components/inbox.gd
- INBOX_EMPTY_* · 3 · scripts/tabs/events_tab.gd
- INBOX_PANE_* · 1 · scripts/tabs/events/mail_pane.gd
- INBOX_QUEUE_* · 3 · scripts/tabs/events_tab.gd
- INBOX_ROW_* · 2 · scripts/tabs/events_tab.gd, scripts/ui/components/inbox.gd
- INBOX_SOONEST_* · 1 · scripts/tabs/events_tab.gd
- INBOX_SUBJ_* · 2 · scripts/ui/components/inbox.gd
- INBOX_THIS_* · 1 · scripts/tabs/events_tab.gd
- INBOX_UNREAD_* · 1 · scripts/tabs/events_tab.gd
- INBOX_WAITING_* · 1 · scripts/tabs/events_tab.gd
- INV_APPETITE_* · 8 · scripts/ui/components/investor_appetite_ui.gd
- INV_ARCH_* · 4 · scripts/autoload/investor_registry.gd
- INV_CHIP_* · 4 · scripts/autoload/investor_registry.gd
- INV_ROLE_* · 4 · scripts/autoload/investor_registry.gd
- LANG_EN_* · 1 · scripts/modals/settings_modal.gd
- LANG_TR_* · 1 · scripts/modals/settings_modal.gd
- LIC_FONTS_* · 1 · scripts/menu/licenses.gd, scripts/debug/write_licenses.gd
- LIC_FREETYPE_* · 1 · scripts/menu/licenses.gd, scripts/debug/write_licenses.gd
- LIC_GODOT_* · 2 · scripts/menu/licenses.gd, scripts/debug/write_licenses.gd
- LIC_ICONS_* · 1 · scripts/menu/licenses.gd, scripts/debug/write_licenses.gd
- LIC_THIRD_* · 1 · scripts/menu/licenses.gd, scripts/debug/write_licenses.gd
- LOCK_CHIP_* · 1 · scripts/tabs/events/mail_pane.gd
- LOCK_FULL_* · 1 · scripts/modals/ending_scene.gd, scripts/onboarding/steps/origin_traits_step.gd
- MADE_WITH_* · 1 · -
- MAIL_CHOOSE_* · 1 · scripts/tabs/events/mail_pane.gd
- MAIL_CONTINUE_* · 1 · scripts/tabs/events/mail_pane.gd
- MAIL_FINAL_* · 1 · scripts/tabs/events/mail_pane.gd
- MAIL_KEY_* · 1 · scripts/tabs/events/mail_pane.gd
- MAIL_KIND_* · 5 · scripts/tabs/events/mail_pane.gd
- MAIL_REPLY_* · 1 · scripts/tabs/events/mail_pane.gd
- MAIL_RESPOND_* · 1 · scripts/main/main.gd, scripts/tabs/events/mail_pane.gd
- MAIL_RPT_* · 6 · scripts/tabs/events/mail_pane.gd
- MAIL_SELF_* · 1 · scripts/ui/components/inbox.gd
- MAIL_SENDER_* · 4 · data/events/cards/customer/incident_month_close.json, data/events/cards/product/incident_outage_b2b.json, data/events/cards/product/incident_outage_b2c.json, scripts/ui/components/inbox.gd +1
- MAIL_SET_* · 1 · scripts/tabs/events/mail_pane.gd
- MAIL_STAMP_* · 4 · scripts/tabs/events/mail_pane.gd, scripts/tabs/events_tab.gd, scripts/ui/components/inbox.gd
- MAIL_TO_* · 1 · scripts/tabs/events/mail_pane.gd
- MAIL_WITHIN_* · 2 · scripts/tabs/events/mail_pane.gd
- MAIL_YOUR_* · 1 · scripts/tabs/events/mail_pane.gd
- MEETING_ACCEPT_* · 1 · scripts/ui/office/meeting_invite.gd
- MEETING_AT_* · 1 · scripts/ui/meeting/meeting_panel.gd
- MEETING_ATT_* · 4 · scripts/theme/ui_tokens.gd
- MEETING_ATTITUDE_* · 1 · scripts/ui/meeting/meeting_panel.gd
- MEETING_BACK_* · 1 · scripts/ui/office/office_travel.gd
- MEETING_CHIP_* · 4 · scripts/ui/meeting/sales_meeting_adapter.gd, scripts/ui/meeting/vc_meeting_adapter.gd
- MEETING_CONTINUE_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd, scripts/ui/meeting/vc_meeting_adapter.gd
- MEETING_DICE_* · 1 · scripts/ui/meeting/meeting_panel.gd
- MEETING_INVITE_* · 4 · scripts/main/main.gd, scripts/ui/office/meeting_invite.gd
- MEETING_KICKER_* · 3 · scripts/ui/meeting/sales_meeting_adapter.gd, scripts/ui/meeting/vc_meeting_adapter.gd
- MEETING_MARK_* · 1 · scripts/systems/vc_pitch_system.gd
- MEETING_MEMORY_* · 1 · scripts/ui/meeting/meeting_panel.gd
- MEETING_OFFER_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- MEETING_POSTPONE_* · 2 · scripts/main/main.gd, scripts/ui/office/meeting_invite.gd
- MEETING_POSTPONED_* · 4 · scripts/main/main.gd, scripts/ui/office/meeting_invite.gd, scripts/debug/kit_probe.gd
- MEETING_RES_* · 19 · scripts/modals/term_sheet_table_scene.gd, scripts/ui/meeting/meeting_panel.gd, scripts/ui/meeting/sales_meeting_adapter.gd, scripts/ui/meeting/vc_meeting_adapter.gd
- MEETING_RISK_* · 4 · scripts/theme/ui_tokens.gd, scripts/ui/meeting/meeting_panel.gd
- MEETING_ROLE_* · 6 · scripts/modals/term_sheet_table_scene.gd, scripts/systems/counterpart_system.gd, scripts/ui/meeting/meeting_panel.gd
- MEETING_TOWER_* · 1 · scripts/main/main.gd
- MEETING_WITHDRAW_* · 1 · scripts/ui/meeting/meeting_panel.gd
- MENTOR_INTRO_* · 3 · scripts/autoload/game_state.gd, scripts/tabs/events/mail_pane.gd, scripts/ui/components/inbox.gd
- MENTOR_NAME_* · 1 · scripts/autoload/character_registry.gd, scripts/modals/ending_scene.gd, scripts/modals/term_sheet_table_scene.gd, scripts/tabs/finance/finance_ozet_view.gd, scripts/tabs/hunt_tab.gd +1
- MENU_BUILD_* · 3 · scripts/menu/credits.gd
- MENU_CARD_* · 1 · scripts/menu/continue_card.gd
- MENU_CONTINUE_* · 1 · -
- MENU_CREDITS_* · 1 · -
- MENU_LAST_* · 1 · scripts/menu/continue_card.gd, scripts/modals/save_load_modal.gd
- MENU_LOAD_* · 1 · -
- MENU_NEW_* · 1 · -
- MENU_VERSION_* · 1 · scripts/menu/credits.gd
- MILESTONE_FIRST_* · 2 · scripts/autoload/game_state.gd, scripts/tabs/personal_tab.gd
- MILESTONE_FOUNDING_* · 1 · scripts/autoload/game_state.gd, scripts/tabs/personal_tab.gd
- MONTH_1_* · 1 · -
- MONTH_10_* · 1 · -
- MONTH_11_* · 1 · -
- MONTH_12_* · 1 · -
- MONTH_2_* · 1 · -
- MONTH_3_* · 1 · -
- MONTH_4_* · 1 · -
- MONTH_5_* · 1 · -
- MONTH_6_* · 1 · -
- MONTH_7_* · 1 · -
- MONTH_8_* · 1 · -
- MONTH_9_* · 1 · -
- MONTH_AUTO_* · 1 · scripts/systems/summary_system.gd
- MONTH_CLOSED_* · 1 · scripts/systems/summary_system.gd, scripts/debug/endgame_smoke.gd
- MONTH_EVENT_* · 1 · scripts/systems/summary_system.gd
- MONTH_FRANK_* · 5 · scripts/systems/summary_system.gd, scripts/debug/endgame_smoke.gd
- MONTH_HIGHLIGHT_* · 1 · scripts/systems/summary_system.gd
- MONTH_HL_* · 1 · scripts/autoload/game_state.gd
- MONTH_ROW_* · 2 · scripts/tabs/events/mail_pane.gd, scripts/ui/components/inbox.gd
- MONTH_TITLE_* · 1 · scripts/systems/summary_system.gd, scripts/debug/endgame_smoke.gd
- NEG_ACCEPT_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_CAPACITY_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_CONFIRM_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_COUNTER_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_DEAL_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_HOLD_* · 2 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_INSULT_* · 1 · scripts/systems/negotiation_system.gd
- NEG_LAST_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_LOCK_* · 1 · scripts/systems/negotiation_system.gd
- NEG_OFFER_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEG_PATIENCE_* · 1 · scripts/ui/meeting/meeting_panel.gd
- NEG_PRICE_* · 2 · scripts/systems/negotiation_system.gd
- NEG_TITLE_* · 2 · scripts/systems/negotiation_system.gd
- NEG_UNITS_* · 2 · scripts/systems/negotiation_system.gd
- NEG_WALK_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- NEWS_RIVAL_* · 7 · scripts/systems/news_feed_system.gd, scripts/debug/endgame_smoke.gd
- NEWS_S_* · 48 · -
- NOTICE_SRC_* · 2 · scripts/systems/sales_ledger.gd, scripts/systems/summary_system.gd, scripts/debug/endgame_smoke.gd
- NUM_0_* · 1 · scripts/systems/endings_copy.gd
- NUM_1_* · 1 · -
- NUM_10_* · 1 · -
- NUM_11_* · 1 · -
- NUM_12_* · 1 · -
- NUM_2_* · 1 · -
- NUM_3_* · 1 · -
- NUM_4_* · 1 · -
- NUM_5_* · 1 · -
- NUM_6_* · 1 · -
- NUM_7_* · 1 · -
- NUM_8_* · 1 · -
- NUM_9_* · 1 · -
- NUM_DECIMAL_* · 1 · scripts/modals/work_hours_modal.gd, scripts/tabs/hr/hr_atlas_modal.gd, scripts/tabs/product/sprint_ui_shared.gd, scripts/util/fmt.gd
- NUM_GROUP_* · 1 · scripts/util/fmt.gd
- OFFICE_ACT_* · 14 · scripts/systems/hr_system.gd, scripts/ui/office/office_actor.gd
- OFFICE_CARD_* · 10 · scripts/ui/office/office_map_card.gd
- OFFICE_CHIP_* · 1 · scripts/ui/office/office_city.gd
- OFFICE_DESC_* · 4 · scripts/systems/office_constants.gd
- OFFICE_HINT_* · 1 · scripts/ui/office/office_notice_stack.gd
- OFFICE_HOVER_* · 2 · scripts/ui/office/office_city.gd
- OFFICE_MAP_* · 3 · scripts/systems/office_constants.gd, scripts/ui/office/office_city.gd
- OFFICE_MOVE_* · 3 · scripts/systems/office_constants.gd, scripts/ui/office/office_hud.gd, scripts/ui/office/office_map_card.gd
- OFFICE_MOVING_* · 2 · scripts/ui/office/office_hud.gd, scripts/ui/office/office_map_card.gd
- OFFICE_NAME_* · 4 · scripts/onboarding/first_week_doc.gd, scripts/onboarding/steps/origin_traits_step.gd, scripts/systems/office_constants.gd, scripts/debug/kit_probe.gd
- OFFICE_REQ_* · 2 · scripts/main/main.gd, scripts/systems/office_constants.gd, scripts/ui/office/office_map_card.gd
- OFFICE_ROOM_* · 23 · scripts/systems/office_constants.gd
- OFFICE_STATUS_* · 3 · scripts/ui/office/office_map_card.gd
- OFFICE_TIER_* · 3 · scripts/systems/office_constants.gd
- OFFICE_TOAST_* · 3 · scripts/ui/office/office_hud.gd, scripts/debug/kit_probe.gd
- OFFICE_TOOLTIP_* · 1 · scripts/ui/office/office_people.gd
- ONB_BACK_* · 1 · -
- ONB_CANCEL_* · 3 · scripts/onboarding/onboarding_flow.gd
- ONB_COMPANY_* · 2 · scripts/onboarding/steps/company_step.gd
- ONB_DIFF_* · 4 · scripts/onboarding/first_week_doc.gd
- ONB_DIFFICULTY_* · 2 · scripts/onboarding/first_week_doc.gd
- ONB_DOC_* · 5 · scripts/onboarding/first_week_doc.gd
- ONB_EFFECT_* · 7 · scripts/onboarding/steps/origin_traits_step.gd
- ONB_FIRST_* · 1 · scripts/onboarding/first_week_doc.gd
- ONB_FOUNDER_* · 1 · scripts/onboarding/first_week_doc.gd
- ONB_GUIDED_* · 3 · scripts/onboarding/first_week_doc.gd
- ONB_LOGO_* · 3 · scripts/onboarding/steps/company_step.gd
- ONB_NAME_* · 2 · scripts/onboarding/steps/character_step.gd
- ONB_NEXT_* · 1 · scripts/onboarding/onboarding_flow.gd
- ONB_ORIGIN_* · 12 · scripts/onboarding/steps/origin_traits_step.gd, scripts/systems/founder_constants.gd
- ONB_POINTS_* · 1 · scripts/onboarding/steps/origin_traits_step.gd
- ONB_PORTRAIT_* · 1 · scripts/onboarding/steps/character_step.gd
- ONB_PREPARING_* · 1 · -
- ONB_RANDOM_* · 1 · scripts/onboarding/steps/step_base.gd
- ONB_RESET_* · 1 · scripts/onboarding/steps/step_base.gd
- ONB_SKILL_* · 20 · scripts/onboarding/steps/origin_traits_step.gd, scripts/systems/founder_constants.gd
- ONB_SKILLS_* · 2 · scripts/onboarding/steps/origin_traits_step.gd
- ONB_START_* · 1 · scripts/onboarding/onboarding_flow.gd
- ONB_STEP_* · 4 · scripts/onboarding/onboarding_flow.gd, scripts/onboarding/steps/character_step.gd, scripts/onboarding/steps/company_step.gd
- ONB_STEP1_* · 1 · scripts/onboarding/steps/character_step.gd
- ONB_STEP3_* · 1 · scripts/onboarding/steps/company_step.gd
- ONB_TEAM_* · 1 · scripts/onboarding/first_week_doc.gd
- ONB_TRAITS_* · 4 · scripts/onboarding/steps/origin_traits_step.gd
- ONB_WEEK_* · 1 · scripts/onboarding/first_week_doc.gd, scripts/onboarding/onboarding_flow.gd
- ONB_WHY_* · 6 · scripts/onboarding/steps/company_step.gd, scripts/onboarding/steps/origin_traits_step.gd, scripts/systems/founder_constants.gd, scripts/debug/endgame_smoke.gd
- PAPER_GONE_* · 1 · scripts/tabs/events/mail_pane.gd
- PCT_PATTERN_* · 1 · scripts/util/fmt.gd, scripts/debug/endgame_smoke.gd
- PERSONAL_MILESTONES_* · 1 · scripts/tabs/personal_tab.gd
- PERSONAL_MS_* · 3 · scripts/tabs/personal_tab.gd
- PER_CHARISMA_* · 1 · scripts/tabs/hr/hr_ui_shared.gd
- PER_EXPERIENCE_* · 1 · scripts/tabs/personal_tab.gd
- PER_GOAL_* · 2 · scripts/tabs/personal_tab.gd
- PER_NET_* · 1 · scripts/tabs/personal_tab.gd
- PER_NO_* · 1 · scripts/tabs/personal_tab.gd, scripts/tabs/piyasa_tab.gd
- PER_PHASE_* · 1 · scripts/tabs/personal_tab.gd
- PER_TASK_* · 1 · scripts/tabs/personal_tab.gd
- PER_TENURE_* · 2 · scripts/tabs/personal_tab.gd
- PER_TRAITS_* · 1 · scripts/tabs/personal_tab.gd
- PER_VALUATION_* · 1 · scripts/tabs/personal_tab.gd
- PER_WHERE_* · 1 · scripts/tabs/personal_tab.gd
- PITCH_DIFF_* · 3 · scripts/systems/pitch_constants.gd
- PIYASA_ABOUT_* · 56 · scripts/tabs/piyasa_tab.gd
- PIYASA_CARD_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_CEO_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_COL_* · 2 · scripts/tabs/piyasa_tab.gd
- PIYASA_CTX_* · 2 · scripts/tabs/piyasa_tab.gd
- PIYASA_EOY_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_FILTER_* · 4 · scripts/tabs/piyasa_tab.gd
- PIYASA_FOUNDER_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_FOUR_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_IPO_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_KPI_* · 7 · scripts/tabs/piyasa_tab.gd
- PIYASA_LINE_* · 1 · scripts/systems/news_feed_system.gd
- PIYASA_LIST_* · 2 · scripts/tabs/piyasa_tab.gd
- PIYASA_LISTED_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_LISTS_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_MONTH_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_NEWS_* · 3 · scripts/systems/news_feed_system.gd
- PIYASA_RANGE_* · 4 · scripts/tabs/piyasa_tab.gd
- PIYASA_SECTOR_* · 27 · scripts/tabs/piyasa_tab.gd
- PIYASA_SHARE_* · 2 · scripts/tabs/piyasa_tab.gd
- PIYASA_SINCE_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_TAG_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_VALUE_* · 1 · scripts/tabs/piyasa_tab.gd
- PIYASA_WHY_* · 7 · scripts/systems/news_feed_system.gd
- PRODUCT_ACCOUNT_* · 2 · scripts/tabs/product/sprint_ui_shared.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_ADD_* · 2 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_APPROVE_* · 2 · scripts/tabs/product/quarter_view.gd
- PRODUCT_APPROVED_* · 1 · scripts/tabs/product/quarter_view.gd
- PRODUCT_AREA_* · 25 · data/product/sprint.json, scripts/events/seams/seams_product.gd, scripts/systems/sprint_catalog.gd, scripts/tabs/product/area_panel.gd, scripts/tabs/product/product_model.gd +1
- PRODUCT_AREAS_* · 1 · scripts/tabs/product/area_panel.gd
- PRODUCT_AT_* · 1 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_AUDIENCE_* · 2 · scripts/systems/sprint_catalog.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_AUTO_* · 1 · scripts/ui/components/build_bar.gd
- PRODUCT_BUG_* · 2 · scripts/systems/sprint_catalog.gd, scripts/tabs/product/product_model.gd, scripts/ui/components/build_bar.gd, scripts/debug/endgame_smoke.gd, scripts/debug/product_fixtures.gd
- PRODUCT_BUGS_* · 3 · scripts/tabs/product/area_panel.gd, scripts/tabs/product/product_model.gd
- PRODUCT_BUILT_* · 1 · scripts/tabs/product/area_panel.gd
- PRODUCT_CAP_* · 1 · scripts/systems/sprint_catalog.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_CARD_* · 4 · scripts/tabs/product/sprint_card.gd
- PRODUCT_CARRIED_* · 2 · scripts/tabs/product/sprint_card.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_CUSTOMERS_* · 2 · scripts/tabs/product/area_panel.gd
- PRODUCT_DECISION_* · 2 · scripts/tabs/product/sprint_card.gd
- PRODUCT_DELEGATE_* · 1 · scripts/tabs/product_tab.gd
- PRODUCT_DUE_* · 4 · scripts/tabs/product/area_panel.gd, scripts/tabs/product/product_model.gd
- PRODUCT_EDIT_* · 1 · scripts/tabs/product/quarter_view.gd
- PRODUCT_EFFORT_* · 3 · scripts/tabs/product/sprint_card.gd
- PRODUCT_EMPTY_* · 1 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_FALLBACK_* · 1 · scripts/systems/sales_system.gd
- PRODUCT_FIX_* · 1 · scripts/systems/sprint_catalog.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_FLAG_* · 1 · scripts/tabs/product/product_model.gd, scripts/debug/product_fixtures.gd
- PRODUCT_FX_* · 14 · scripts/tabs/product/product_model.gd, scripts/tabs/product/sprint_ui_shared.gd, scripts/debug/endgame_smoke.gd, scripts/debug/product_fixtures.gd
- PRODUCT_GATE_* · 3 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_GO_* · 3 · scripts/main/main.gd, scripts/tabs/product/sprint_card.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_GOAL_* · 7 · scripts/tabs/product/product_model.gd, scripts/debug/product_fixtures.gd
- PRODUCT_HISTORY_* · 4 · scripts/tabs/product/area_panel.gd, scripts/tabs/product_tab.gd
- PRODUCT_IDLE_* · 3 · scripts/tabs/product/product_model.gd
- PRODUCT_IN_* · 2 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_KPI_* · 2 · scripts/tabs/product_tab.gd, scripts/tabs/sales_tab.gd
- PRODUCT_LEAD_* · 9 · scripts/systems/sprint_catalog.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_LEVEL_* · 4 · scripts/systems/sales_meeting_system.gd, scripts/systems/sprint_bridges.gd, scripts/tabs/product/sprint_ui_shared.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_LIVE_* · 1 · scripts/events/catalog/catalog.gd, scripts/events/tools/lint.gd, scripts/events/tools/vocab_gen.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_LOCK_* · 1 · scripts/systems/sprint_catalog.gd
- PRODUCT_MVP_* · 5 · scripts/tabs/product/sprint_panel.gd, scripts/tabs/product_tab.gd
- PRODUCT_NEWS_* · 2 · scripts/systems/sprint_bridges.gd
- PRODUCT_NEXT_* · 3 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_NO_* · 1 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_OV_* · 2 · scripts/main/main.gd, scripts/tabs/product_tab.gd
- PRODUCT_OVER_* · 2 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_PER_* · 1 · scripts/tabs/product/area_panel.gd, scripts/tabs/product/product_model.gd, scripts/tabs/product/sprint_ui_shared.gd
- PRODUCT_PERSON_* · 2 · scripts/tabs/product/sprint_panel.gd, scripts/tabs/product/sprint_ui_shared.gd
- PRODUCT_PHASE_* · 3 · scripts/tabs/product/sprint_card.gd
- PRODUCT_PLAN_* · 2 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_PM_* · 2 · scripts/tabs/product/quarter_view.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_POSSIBLE_* · 1 · scripts/tabs/product/area_panel.gd
- PRODUCT_PRESS_* · 5 · scripts/systems/sprint_bridges.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_PRIORITY_* · 1 · scripts/tabs/product/sprint_card.gd
- PRODUCT_PROMISED_* · 1 · scripts/tabs/product/sprint_card.gd
- PRODUCT_QUARTER_* · 1 · scripts/tabs/product_tab.gd
- PRODUCT_QUEUED_* · 1 · scripts/tabs/product/sprint_card.gd
- PRODUCT_RELEASE_* · 5 · scripts/systems/sprint_bridges.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_REMOVE_* · 1 · scripts/tabs/product/sprint_ui_shared.gd
- PRODUCT_REQUEST_* · 1 · scripts/systems/sprint_catalog.gd
- PRODUCT_REQUESTS_* · 2 · scripts/tabs/product/area_panel.gd
- PRODUCT_RESEARCH_* · 7 · scripts/systems/sprint_catalog.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_RESULT_* · 12 · scripts/systems/sprint_bridges.gd, scripts/systems/sprint_system.gd, scripts/tabs/product/sprint_panel.gd, scripts/tabs/product/sprint_ui_shared.gd, scripts/debug/endgame_smoke.gd +1
- PRODUCT_REVIEW_* · 29 · data/product/sprint.json, scripts/systems/sprint_bridges.gd, scripts/debug/endgame_smoke.gd, scripts/debug/product_fixtures.gd
- PRODUCT_REVIEWS_* · 1 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_RIVAL_* · 1 · scripts/tabs/product/area_panel.gd, scripts/tabs/product/product_model.gd, scripts/debug/product_fixtures.gd
- PRODUCT_ROLE_* · 1 · scripts/tabs/product/product_model.gd, scripts/debug/product_fixtures.gd
- PRODUCT_SERVER_* · 36 · scripts/main/main.gd, scripts/tabs/product/overview_view.gd, scripts/tabs/product/product_model.gd
- PRODUCT_SHIPPED_* · 1 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_SKIP_* · 2 · scripts/main/main.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_SPRINT_* · 2 · scripts/tabs/product/quarter_view.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_STAR_* · 4 · scripts/systems/sprint_catalog.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_START_* · 2 · scripts/main/main.gd, scripts/tabs/product/product_model.gd, scripts/tabs/product/sprint_panel.gd, scripts/debug/product_fixtures.gd
- PRODUCT_STATUS_* · 9 · scripts/tabs/product/sprint_card.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_TAG_* · 1 · scripts/tabs/product/area_panel.gd, scripts/tabs/product/sprint_card.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_TEAM_* · 2 · scripts/tabs/product/product_model.gd, scripts/debug/product_fixtures.gd
- PRODUCT_THIS_* · 2 · scripts/tabs/product/quarter_view.gd, scripts/tabs/product/sprint_panel.gd
- PRODUCT_TIP_* · 2 · scripts/tabs/product/product_model.gd
- PRODUCT_USER_* · 2 · scripts/tabs/product/product_model.gd, scripts/tabs/product/sprint_ui_shared.gd, scripts/debug/endgame_smoke.gd
- PRODUCT_VELOCITY_* · 3 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_VERSION_* · 1 · scripts/tabs/product_tab.gd
- PRODUCT_VIEW_* · 2 · scripts/tabs/product_tab.gd
- PRODUCT_WEEK_* · 1 · scripts/tabs/product/sprint_panel.gd
- PRODUCT_WEEKS_* · 2 · scripts/tabs/product/sprint_card.gd
- PROD_CONFIRM_* · 1 · scripts/tabs/product/type_picker.gd, scripts/debug/endgame_smoke.gd
- PROD_DESIGN_* · 1 · data/events/cards/unwired/design_round_intro.json
- PROD_DEV_* · 1 · scripts/debug/endgame_smoke.gd
- PROD_EV_* · 3 · data/events/cards/unwired/design_round_intro.json, data/events/cards/unwired/first_ship.json, data/events/cards/unwired/version_ship.json
- PROD_FEAT_* · 122 · scripts/debug/endgame_smoke.gd
- PROD_ITER_* · 1 · data/events/cards/unwired/design_round_intro.json
- PROD_LINE_* · 20 · data/product/rivals.json, scripts/systems/product_lines.gd
- PROD_LOCK_* · 3 · scripts/systems/sprint_catalog.gd, scripts/debug/product_fixtures.gd
- PROD_NAME_* · 1 · scripts/tabs/product/type_picker.gd
- PROD_PATH_* · 6 · scripts/tabs/product/type_picker.gd
- PROD_PERCENT_* · 1 · scripts/tabs/rnd/rnd_ui_shared.gd, scripts/ui/components/research_bar.gd
- PROD_RND_* · 69 · scripts/systems/research_seam.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/rnd/rnd_detail_panel.gd, scripts/ui/components/inbox.gd
- PROD_SHIP_* · 4 · data/events/cards/unwired/first_ship.json, data/events/cards/unwired/version_ship.json, scripts/main/main.gd, scripts/systems/sprint_system.gd, scripts/tabs/product/sprint_panel.gd
- PROD_STEP_* · 150 · scripts/systems/b2b_constants.gd, scripts/systems/product_lines.gd, scripts/debug/endgame_smoke.gd
- PROD_TEAM_* · 1 · scripts/tabs/rnd/rnd_assign_panel.gd
- PROD_TO_* · 1 · data/events/cards/unwired/design_round_intro.json
- PROD_TYPE_* · 43 · scripts/systems/product_catalog.gd, scripts/debug/endgame_smoke.gd, scripts/debug/product_fixtures.gd
- PROD_VERSION_* · 1 · scripts/systems/sprint_system.gd, scripts/tabs/product_tab.gd, scripts/debug/product_fixtures.gd
- REC_AM_* · 1 · scripts/tabs/events/mail_pane.gd, scripts/tabs/sales_tab.gd
- REC_SATISFACTION_* · 1 · scripts/tabs/events/mail_pane.gd
- REC_TENURE_* · 1 · scripts/tabs/events/mail_pane.gd
- REP_DROP_* · 1 · scripts/systems/support_system.gd
- REVIEW_SOURCE_* · 2 · data/product/sprint.json
- RND_ABANDON_* · 2 · scripts/tabs/rnd/rnd_detail_panel.gd, scripts/tabs/rnd/rnd_ui_shared.gd, scripts/tabs/rnd_tab.gd, scripts/ui/components/research_bar.gd
- RND_ACTION_* · 2 · scripts/tabs/rnd/rnd_assign_panel.gd
- RND_AREA_* · 1 · scripts/tabs/rnd/rnd_tree_view.gd, scripts/tabs/rnd/rnd_ui_shared.gd, scripts/ui/components/research_bar_model.gd
- RND_ASSIGN_* · 4 · scripts/tabs/rnd/rnd_assign_panel.gd, scripts/tabs/rnd/rnd_ui_shared.gd
- RND_BAR_* · 2 · scripts/tabs/rnd/rnd_ui_shared.gd, scripts/tabs/rnd_tab.gd, scripts/ui/components/research_bar.gd
- RND_COMPLETED_* · 2 · scripts/tabs/events/mail_pane.gd, scripts/tabs/rnd/rnd_detail_panel.gd
- RND_DISCOVERY_* · 1 · scripts/systems/rnd_system.gd, scripts/tabs/events/mail_pane.gd
- RND_EA_* · 1 · scripts/tabs/events/mail_pane.gd
- RND_FAMILY_* · 4 · scripts/tabs/rnd/rnd_ui_shared.gd
- RND_FOUNDER_* · 1 · scripts/tabs/rnd/rnd_assign_panel.gd
- RND_FROZEN_* · 1 · scripts/tabs/rnd/rnd_detail_panel.gd
- RND_HIDDEN_* · 1 · scripts/tabs/events/mail_pane.gd
- RND_HIRE_* · 1 · scripts/main/main.gd, scripts/tabs/rnd/rnd_ui_shared.gd
- RND_HISTORY_* · 1 · scripts/tabs/rnd/rnd_history.gd
- RND_LEGEND_* · 5 · scripts/tabs/rnd_tab.gd, scripts/debug/endgame_smoke.gd
- RND_LOCKED_* · 1 · scripts/tabs/rnd/rnd_tree_view.gd
- RND_NEED_* · 6 · scripts/tabs/rnd/rnd_assign_panel.gd, scripts/tabs/rnd/rnd_ui_shared.gd
- RND_NODE_* · 1 · scripts/tabs/rnd/rnd_detail_panel.gd
- RND_NOTE_* · 29 · scripts/systems/rnd_system.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/rnd/rnd_detail_panel.gd, scripts/ui/components/inbox.gd, scripts/debug/endgame_smoke.gd
- RND_PAUSED_* · 2 · scripts/systems/rnd_system.gd
- RND_PLACE_* · 3 · scripts/tabs/rnd/rnd_ui_shared.gd
- RND_REQ_* · 4 · scripts/tabs/rnd/rnd_assign_panel.gd, scripts/tabs/rnd/rnd_detail_panel.gd
- RND_START_* · 1 · scripts/tabs/rnd/rnd_assign_panel.gd, scripts/tabs/rnd/rnd_detail_panel.gd
- RND_SWITCH_* · 1 · scripts/tabs/rnd/rnd_detail_panel.gd
- RND_TIER_* · 1 · scripts/tabs/rnd/rnd_tree_view.gd
- RND_TREE_* · 3 · scripts/tabs/rnd/rnd_ui_shared.gd, scripts/tabs/rnd_tab.gd, scripts/debug/endgame_smoke.gd
- RND_UNLOCKS_* · 1 · scripts/tabs/events/mail_pane.gd, scripts/tabs/rnd/rnd_detail_panel.gd
- RND_VIEW_* · 2 · scripts/tabs/rnd_tab.gd
- RND_WEEKS_* · 7 · scripts/tabs/rnd/rnd_assign_panel.gd, scripts/tabs/rnd/rnd_detail_panel.gd, scripts/tabs/rnd/rnd_ui_shared.gd, scripts/tabs/rnd_tab.gd, scripts/ui/components/research_bar.gd
- RND_WHO_* · 1 · scripts/ui/components/research_bar.gd
- RUNWAY_CROSS_* · 2 · scripts/systems/summary_system.gd
- RUNWAY_UNIT_* · 2 · scripts/theme/ui_tokens.gd, scripts/debug/endgame_smoke.gd
- SALES_ABOVE_* · 1 · scripts/tabs/sales_tab.gd
- SALES_ACCOUNT_* · 1 · scripts/tabs/sales_tab.gd
- SALES_ACTION_* · 3 · scripts/main/main.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/sales_tab.gd
- SALES_ANS_* · 18 · scripts/systems/sales_probes.gd
- SALES_ARCH_* · 3 · scripts/systems/sales_archetypes.gd, scripts/debug/endgame_smoke.gd
- SALES_B2C_* · 5 · scripts/systems/sales_system.gd, scripts/tabs/sales_tab.gd
- SALES_BAND_* · 5 · scripts/systems/sales_ledger.gd, scripts/systems/sales_rep_system.gd, scripts/tabs/sales_tab.gd, scripts/debug/endgame_smoke.gd
- SALES_BLOCK_* · 6 · scripts/systems/sales_ledger.gd, scripts/debug/endgame_smoke.gd
- SALES_CHIP_* · 4 · scripts/tabs/sales_tab.gd, scripts/ui/components/inbox.gd, scripts/debug/kit_probe.gd
- SALES_CHURN_* · 2 · scripts/tabs/sales_tab.gd
- SALES_CLAUSE_* · 15 · scripts/systems/b2b_constants.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/product/product_model.gd, scripts/tabs/sales_tab.gd, scripts/ui/components/inbox.gd +1
- SALES_CUSTOMERS_* · 3 · scripts/tabs/sales_tab.gd
- SALES_DAYS_* · 2 · scripts/tabs/sales_tab.gd
- SALES_DEAL_* · 6 · scripts/tabs/sales_tab.gd, scripts/ui/meeting/sales_meeting_adapter.gd
- SALES_DESK_* · 2 · scripts/tabs/sales_tab.gd
- SALES_EMPTY_* · 3 · scripts/tabs/sales_tab.gd
- SALES_EXPANSION_* · 1 · scripts/tabs/sales_tab.gd, scripts/ui/components/inbox.gd
- SALES_FLOW_* · 1 · scripts/tabs/sales_tab.gd
- SALES_FOUNDER_* · 1 · scripts/tabs/sales_tab.gd
- SALES_GO_* · 1 · scripts/tabs/sales_tab.gd
- SALES_INNER_* · 3 · scripts/systems/sales_meeting_system.gd, scripts/debug/endgame_smoke.gd
- SALES_LOCK_* · 7 · data/events/cards/customer/cs_escalation.json, data/events/cards/customer/request_complaint.json, data/events/cards/customer/request_feature.json, data/events/cards/customer/retention.json +4
- SALES_LOCKED_* · 1 · scripts/tabs/hr/hr_assignments.gd, scripts/tabs/sales_tab.gd
- SALES_LOG_* · 6 · scripts/autoload/game_state.gd, scripts/systems/sales_system.gd, scripts/tabs/sales_tab.gd
- SALES_LOSS_* · 5 · scripts/systems/sales_meeting_system.gd, scripts/debug/endgame_smoke.gd
- SALES_MEETING_* · 3 · scripts/systems/sales_meeting_system.gd, scripts/ui/meeting/sales_meeting_adapter.gd, scripts/debug/endgame_smoke.gd
- SALES_MEMORY_* · 5 · scripts/systems/sales_ledger.gd, scripts/debug/endgame_smoke.gd
- SALES_MOD_* · 9 · scripts/systems/product_quality.gd, scripts/systems/sales_meeting_system.gd, scripts/debug/endgame_smoke.gd
- SALES_ODDS_* · 1 · scripts/ui/meeting/sales_meeting_adapter.gd
- SALES_ONBOARDING_* · 1 · scripts/tabs/sales_tab.gd
- SALES_PER_* · 1 · scripts/tabs/events/mail_pane.gd, scripts/tabs/sales_tab.gd, scripts/ui/components/inbox.gd
- SALES_PIPELINE_* · 1 · scripts/tabs/sales_tab.gd
- SALES_PORTFOLIO_* · 1 · scripts/tabs/sales_tab.gd
- SALES_PROBE_* · 8 · scripts/systems/sales_meeting_system.gd, scripts/systems/sales_probes.gd, scripts/debug/endgame_smoke.gd
- SALES_PROMISE_* · 4 · scripts/tabs/sales_tab.gd
- SALES_PROSPECTS_* · 1 · scripts/tabs/sales_tab.gd
- SALES_REASON_* · 4 · scripts/tabs/sales_tab.gd, scripts/ui/components/inbox.gd, scripts/debug/endgame_smoke.gd
- SALES_REP_* · 3 · scripts/systems/sales_rep_system.gd, scripts/tabs/sales_tab.gd, scripts/ui/components/inbox.gd, scripts/debug/kit_probe.gd
- SALES_ROUTE_* · 5 · scripts/systems/sales_ledger.gd, scripts/tabs/sales_tab.gd
- SALES_SEAT_* · 1 · scripts/tabs/sales_tab.gd
- SALES_SEATS_* · 1 · scripts/tabs/sales_tab.gd
- SALES_SIGNING_* · 1 · scripts/tabs/sales_tab.gd
- SALES_STAGE_* · 6 · scripts/tabs/sales_tab.gd
- SALES_STANCE_* · 7 · scripts/tabs/sales_tab.gd, scripts/debug/endgame_smoke.gd
- SALES_STEWARD_* · 6 · scripts/main/main.gd, scripts/tabs/events/mail_pane.gd, scripts/tabs/sales_tab.gd
- SALES_STRIP_* · 4 · scripts/tabs/sales_tab.gd
- SALES_TAG_* · 1 · scripts/tabs/sales_tab.gd
- SALES_TENURE_* · 2 · scripts/tabs/sales_tab.gd
- SALES_TICKER_* · 2 · scripts/systems/sales_finalizer.gd, scripts/systems/sales_rep_system.gd, scripts/debug/endgame_smoke.gd
- SALES_WEEKLY_* · 3 · scripts/main/main.gd, scripts/systems/sales_rep_system.gd, scripts/tabs/events/mail_pane.gd, scripts/ui/components/inbox.gd
- SALES_WHALE_* · 2 · scripts/tabs/sales_tab.gd, scripts/ui/meeting/sales_meeting_adapter.gd, scripts/debug/endgame_smoke.gd
- SALES_WIN_* · 1 · scripts/systems/sales_meeting_system.gd, scripts/debug/endgame_smoke.gd
- SAVE_AUTO_* · 1 · scripts/autoload/save_manager.gd
- SAVE_DELETE_* · 4 · scripts/main/main.gd, scripts/modals/save_load_modal.gd
- SAVE_EMPTY_* · 1 · scripts/modals/save_load_modal.gd
- SAVE_ERR_* · 8 · scripts/autoload/save_manager.gd, scripts/main/main.gd, scripts/modals/save_load_modal.gd, scripts/debug/endgame_smoke.gd, scripts/debug/kit_probe.gd
- SAVE_F9_* · 2 · scripts/main/main.gd
- SAVE_GROUP_* · 4 · scripts/modals/save_load_modal.gd
- SAVE_LIST_* · 1 · scripts/modals/save_load_modal.gd
- SAVE_LOAD_* · 3 · scripts/main/main.gd, scripts/modals/save_load_modal.gd
- SAVE_MANUAL_* · 1 · scripts/autoload/save_manager.gd, scripts/main/main.gd
- SAVE_META_* · 4 · scripts/modals/save_load_modal.gd
- SAVE_NEW_* · 1 · scripts/modals/save_load_modal.gd
- SAVE_OVERWRITE_* · 3 · scripts/main/main.gd, scripts/modals/save_load_modal.gd
- SAVE_QUICK_* · 1 · scripts/autoload/save_manager.gd, scripts/debug/kit_probe.gd
- SAVE_SLOT_* · 1 · scripts/util/fmt.gd, scripts/debug/endgame_smoke.gd
- SAVE_TITLE_* · 2 · scripts/modals/save_load_modal.gd
- SAVE_TOAST_* · 6 · scripts/main/main.gd, scripts/debug/kit_probe.gd
- SECTOR_AGENCY_* · 1 · -
- SECTOR_CONSTRUCTION_* · 1 · -
- SECTOR_CONSUMER_* · 1 · -
- SECTOR_ECOMMERCE_* · 1 · -
- SECTOR_EDUCATION_* · 1 · -
- SECTOR_ENTERPRISE_* · 1 · -
- SECTOR_FINANCE_* · 1 · -
- SECTOR_FINTECH_* · 1 · -
- SECTOR_HEALTH_* · 1 · -
- SECTOR_INSURANCE_* · 1 · -
- SECTOR_LEGAL_* · 1 · -
- SECTOR_LOGISTICS_* · 1 · -
- SECTOR_MANUFACTURING_* · 1 · -
- SECTOR_MEDIA_* · 1 · -
- SECTOR_PRODUCTIVITY_* · 1 · -
- SECTOR_REAL_* · 1 · -
- SECTOR_RETAIL_* · 1 · -
- SECTOR_SAAS_* · 1 · -
- SECTOR_SALES_* · 1 · -
- SECTOR_SOCIAL_* · 1 · -
- SECTOR_SOFTWARE_* · 1 · -
- SECTOR_SUBSCRIPTION_* · 1 · -
- SECTOR_TECHNOLOGY_* · 1 · -
- SEED_B1_* · 2 · scripts/systems/vc_pitch_system.gd
- SEED_B2_* · 5 · -
- SEED_B4_* · 7 · scripts/systems/vc_pitch_system.gd
- SEED_BAND_* · 3 · scripts/tabs/hunt_tab.gd, scripts/ui/meeting/vc_meeting_adapter.gd
- SEED_BLOCK_* · 4 · scripts/systems/seed_round_system.gd, scripts/debug/endgame_smoke.gd
- SEED_BOARD_* · 1 · scripts/systems/term_sheet_table_system.gd, scripts/debug/endgame_smoke.gd
- SEED_CAP_* · 1 · scripts/tabs/finance/finance_ozet_view.gd
- SEED_CLOSED_* · 3 · data/events/cards/funding/seed_closed.json, scripts/debug/endgame_smoke.gd
- SEED_DONE_* · 1 · scripts/tabs/hunt_tab.gd
- SEED_DOOR_* · 5 · data/events/cards/funding/seed_door.json, scripts/tabs/hunt_tab.gd, scripts/debug/endgame_smoke.gd
- SEED_EXPECT_* · 6 · scripts/tabs/hunt_tab.gd
- SEED_FRANK_* · 6 · scripts/systems/term_sheet_table_system.gd
- SEED_IMPLIED_* · 1 · scripts/systems/term_sheet_table_system.gd
- SEED_INV_* · 1 · scripts/systems/term_sheet_table_system.gd
- SEED_LEVER_* · 1 · scripts/systems/pitch_constants.gd, scripts/systems/seed_constants.gd, scripts/systems/term_sheet_table_system.gd
- SEED_MONTH_* · 1 · scripts/systems/seed_round_system.gd
- SEED_OFFER_* · 8 · data/events/cards/funding/seed_offer.json, scripts/tabs/hunt_tab.gd, scripts/ui/meeting/vc_meeting_adapter.gd, scripts/debug/endgame_smoke.gd
- SEED_PITCH_* · 5 · scripts/main/main.gd, scripts/tabs/hunt_tab.gd
- SEED_Q_* · 10 · scripts/systems/vc_pitch_system.gd
- SEED_RES_* · 3 · scripts/systems/vc_pitch_system.gd
- SEED_RESULT_* · 2 · scripts/systems/term_sheet_table_system.gd
- SEED_SECTION_* · 1 · scripts/systems/cheque_read.gd, scripts/tabs/hunt_tab.gd, scripts/debug/endgame_smoke.gd
- SEED_STALL_* · 5 · data/events/cards/funding/seed_stalled.json, data/events/cards/world/final_stretch_verdict.json
- SEED_TX_* · 1 · scripts/systems/finance_system.gd
- SEED_WALK_* · 1 · scripts/systems/term_sheet_table_system.gd
- SETTINGS_LANGUAGE_* · 1 · scripts/modals/settings_modal.gd, scripts/debug/endgame_smoke.gd
- SET_AUTOSAVE_* · 4 · scripts/modals/settings_modal.gd
- SET_BLOCKED_* · 1 · scripts/main/main.gd
- SET_CLOSE_* · 1 · -
- SET_COLORBLIND_* · 2 · scripts/modals/settings_modal.gd
- SET_GFX_* · 32 · scripts/modals/settings_modal.gd
- SET_MUSIC_* · 1 · scripts/modals/settings_modal.gd
- SET_MUTE_* · 1 · scripts/modals/settings_modal.gd
- SET_OPEN_* · 1 · scripts/modals/settings_modal.gd
- SET_PAUSE_* · 1 · scripts/modals/settings_modal.gd
- SET_RESET_* · 5 · scripts/main/main.gd, scripts/modals/settings_modal.gd
- SET_RESOLUTION_* · 4 · scripts/modals/settings_modal.gd, scripts/debug/endgame_smoke.gd
- SET_SEC_* · 6 · scripts/modals/settings_modal.gd
- SET_SFX_* · 1 · scripts/modals/settings_modal.gd
- SET_SUMMARY_* · 6 · scripts/modals/settings_modal.gd
- SET_TICKER_* · 1 · scripts/modals/settings_modal.gd
- SET_TITLE_* · 1 · scripts/modals/settings_modal.gd
- SET_UI_* · 3 · scripts/modals/settings_modal.gd, scripts/systems/display_settings.gd
- SET_VOL_* · 3 · scripts/modals/settings_modal.gd
- SET_VSYNC_* · 1 · scripts/modals/settings_modal.gd
- SET_WINDOW_* · 4 · scripts/modals/settings_modal.gd, scripts/systems/display_settings.gd
- SHARE_FLOOR_* · 1 · scripts/autoload/rival_registry.gd, scripts/tabs/piyasa_tab.gd, scripts/debug/endgame_smoke.gd
- SKILL_LABEL_* · 8 · scripts/systems/founder_constants.gd
- SUMMARY_AUTO_* · 3 · scripts/systems/summary_system.gd
- SUMMARY_EVENT_* · 3 · scripts/systems/summary_system.gd
- SUMMARY_HIGHLIGHT_* · 3 · scripts/systems/summary_system.gd
- SUMMARY_RANGE_* · 2 · scripts/systems/summary_system.gd, scripts/debug/endgame_smoke.gd
- SUMMARY_ROW_* · 1 · scripts/tabs/events/mail_pane.gd
- SUMMARY_TITLE_* · 3 · scripts/systems/summary_system.gd
- SUPPORT_RPT_* · 10 · scripts/systems/support_system.gd, scripts/tabs/events/mail_pane.gd, scripts/ui/components/inbox.gd, scripts/debug/endgame_smoke.gd, scripts/debug/run_probe.gd
- SYS_CANCEL_* · 1 · scripts/main/main.gd, scripts/modals/save_load_modal.gd, scripts/modals/system_menu_modal.gd
- SYS_HINT_* · 2 · scripts/modals/system_menu_modal.gd
- SYS_LOAD_* · 1 · -
- SYS_MAIN_* · 1 · scripts/onboarding/onboarding_flow.gd
- SYS_MENU_* · 4 · scripts/modals/system_menu_modal.gd
- SYS_QUIT_* · 5 · scripts/main/main.gd, scripts/modals/system_menu_modal.gd
- SYS_RESUME_* · 1 · -
- SYS_SAVE_* · 1 · scripts/modals/save_load_modal.gd
- SYS_SETTINGS_* · 1 · scripts/main/main.gd
- SYS_SOON_* · 1 · scripts/ui/components/left_tabs.gd
- SYS_TITLE_* · 1 · scripts/modals/system_menu_modal.gd
- TAB_EVENTS_* · 1 · scripts/tabs/events_tab.gd
- TAB_FINANCE_* · 1 · scripts/tabs/finance_tab.gd
- TAB_HR_* · 1 · scripts/tabs/hr_tab.gd, scripts/debug/kit_probe.gd
- TAB_MARKETING_* · 1 · -
- TAB_PERSONAL_* · 1 · scripts/tabs/personal_tab.gd
- TAB_PIYASA_* · 1 · scripts/tabs/piyasa_tab.gd
- TAB_PRODUCT_* · 1 · scripts/tabs/product_tab.gd
- TAB_RND_* · 1 · scripts/systems/finance_system.gd, scripts/tabs/rnd_tab.gd
- TAB_SALES_* · 1 · scripts/tabs/sales_tab.gd
- TAB_SETTINGS_* · 1 · scripts/ui/components/left_tabs.gd
- TERM_BOARD_* · 4 · scripts/systems/term_sheet_table_system.gd, scripts/debug/endgame_smoke.gd
- TERM_CASH_* · 2 · scripts/systems/term_sheet_table_system.gd
- TERM_DIAL_* · 2 · scripts/modals/term_sheet_table_scene.gd
- TERM_FRANK_* · 7 · scripts/systems/term_sheet_table_system.gd
- TERM_INV_* · 15 · scripts/systems/term_sheet_table_system.gd
- TERM_INVESTMENT_* · 1 · scripts/modals/term_sheet_table_scene.gd
- TERM_LEAVE_* · 1 · scripts/modals/term_sheet_table_scene.gd
- TERM_LEVER_* · 3 · scripts/systems/term_sheet_table_system.gd
- TERM_LEVERAGE_* · 1 · scripts/systems/term_sheet_table_system.gd
- TERM_OFFER_* · 1 · scripts/modals/term_sheet_table_scene.gd
- TERM_OTHER_* · 1 · scripts/systems/term_sheet_table_system.gd
- TERM_PATIENCE_* · 1 · scripts/modals/term_sheet_table_scene.gd
- TERM_PUSH_* · 1 · scripts/modals/term_sheet_table_scene.gd
- TERM_RESULT_* · 9 · scripts/modals/term_sheet_table_scene.gd, scripts/systems/term_sheet_table_system.gd
- TERM_SHOW_* · 2 · scripts/modals/term_sheet_table_scene.gd
- TERM_SIGN_* · 3 · scripts/modals/term_sheet_table_scene.gd
- TERM_SPLIT_* · 4 · scripts/systems/term_sheet_table_system.gd
- TERM_TABLES_* · 1 · scripts/systems/term_sheet_table_system.gd
- TERM_WALK_* · 3 · scripts/modals/term_sheet_table_scene.gd
- TICKER_01_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_02_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_03_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_04_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_05_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_06_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_07_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_08_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_09_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_10_* · 1 · scripts/ui/components/news_ticker.gd
- TICKER_SRC_* · 1 · scripts/events/present/ticker.gd
- TOPBAR_BRAND_* · 1 · -
- TOPBAR_DATE_* · 1 · scripts/ui/components/top_bar.gd
- TOPBAR_GATE_* · 2 · scripts/tabs/events/mail_pane.gd, scripts/ui/components/research_bar.gd, scripts/ui/components/top_bar.gd, scripts/ui/office/office_hud.gd
- TOPBAR_IN_* · 1 · scripts/ui/components/top_bar.gd
- TOPBAR_NEXT_* · 7 · scripts/theme/ui_tokens.gd, scripts/ui/components/top_bar.gd
- TOPBAR_NOW_* · 1 · scripts/ui/components/top_bar.gd
- TOPBAR_PAUSE_* · 1 · -
- TOPBAR_PAUSED_* · 1 · scripts/ui/components/top_bar.gd
- TOPBAR_SHUTTER_* · 3 · scripts/tabs/finance_tab.gd, scripts/theme/ui_tokens.gd, scripts/ui/components/top_bar.gd
- TOPBAR_TRIP_* · 1 · scripts/ui/components/top_bar.gd
- TOPBAR_UNIT_* · 1 · scripts/debug/endgame_smoke.gd
- TRAIT_DISCIPLINED_* · 2 · scripts/systems/founder_constants.gd
- TRAIT_LONE_* · 2 · scripts/systems/founder_constants.gd
- TRAIT_MICROMANAGER_* · 2 · scripts/systems/founder_constants.gd
- TRAIT_NETWORKER_* · 2 · scripts/systems/founder_constants.gd
- TRAIT_RESILIENT_* · 2 · scripts/systems/founder_constants.gd
- TRAIT_RISK_* · 2 · scripts/systems/founder_constants.gd
- TRAIT_STUBBORN_* · 2 · scripts/systems/founder_constants.gd
- TRAIT_VISIONARY_* · 2 · scripts/systems/founder_constants.gd
- TRIP_SKIP_* · 1 · scripts/ui/office/office_travel.gd
- UI_CONFIRM_* · 2 · scripts/modals/confirm_modal.gd, scripts/tabs/product/sprint_panel.gd
- UI_CONTINUE_* · 1 · scripts/modals/ending_scene.gd, scripts/debug/endgame_smoke.gd
- UI_DISMISS_* · 1 · scripts/main/main.gd, scripts/modals/confirm_modal.gd, scripts/modals/hr_action_modal.gd, scripts/modals/term_sheet_table_scene.gd, scripts/modals/training_modal.gd +6
- VC_APPROACH_* · 6 · scripts/systems/vc_pitch_system.gd
- VC_B1_* · 3 · scripts/systems/vc_pitch_system.gd
- VC_B2_* · 5 · -
- VC_B3_* · 6 · scripts/systems/vc_pitch_system.gd
- VC_B4_* · 13 · scripts/systems/vc_pitch_system.gd
- VC_BEAT1_* · 1 · scripts/systems/vc_pitch_system.gd
- VC_BEAT2_* · 1 · scripts/systems/vc_pitch_system.gd
- VC_BEAT3_* · 1 · scripts/systems/vc_pitch_system.gd
- VC_BEAT4_* · 1 · scripts/systems/vc_pitch_system.gd
- VC_BLOCK_* · 1 · data/events/cards/funding/seed_offer.json, data/events/cards/funding/sheet_decision.json, scripts/tabs/hunt_tab.gd
- VC_CALLBACK_* · 1 · scripts/systems/vc_pitch_system.gd
- VC_EV_* · 7 · data/events/cards/funding/last_answer.json, data/events/cards/funding/sheet_decision.json, data/events/cards/funding/sheet_expiry.json, scripts/tabs/hunt_tab.gd
- VC_FRANK_* · 6 · scripts/systems/vc_pitch_system.gd, scripts/debug/endgame_smoke.gd
- VC_Q_* · 24 · scripts/systems/vc_pitch_system.gd, scripts/debug/endgame_smoke.gd
- VC_REACT_* · 3 · scripts/systems/vc_pitch_system.gd
- VC_RES_* · 4 · scripts/systems/vc_pitch_system.gd
- VC_WHY_* · 17 · scripts/systems/vc_pitch_system.gd, scripts/debug/endgame_smoke.gd
- WIN_BACK_* · 1 · scripts/main/main.gd, scripts/ui/components/gate_strip.gd
- WIN_CLOSE_* · 1 · scripts/theme/ui_factory.gd
- WIN_PAGE_* · 1 · scripts/ui/components/window_layer.gd
- WIN_READ_* · 1 · scripts/ui/components/window_frame.gd
- WORLD_OUTLET_* · 5 · scripts/systems/endings_copy.gd, scripts/systems/news_feed_system.gd, scripts/theme/ui_tokens.gd, scripts/ui/components/inbox.gd, scripts/debug/product_fixtures.gd
