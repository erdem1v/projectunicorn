# Faz C · C0q Q'dan sonra tazeleme

Taban: Q'nun son commit'i `910ad1f` (HEAD, `git rev-parse HEAD`). C0 haritası ve C0v ekleri `fc6b392`'ye göreydi. Okuma `git archive 910ad1f`
ve `git archive fc6b392` kopyalarından ve `git diff -U0 fc6b392..910ad1f -- project-unicorn`'dan yapıldı; çalışma ağacı okunmadı, hiçbir oyun
dosyasına yazılmadı, Godot koşmadı. Girdiler: `RAPOR_Q.md`, `q_calisma/R_DEFTER.md`, `PRD_FAZ_C_URUN_HESAP.md`, `PLAN_C.md`, `W1_METINLER.json`.
Çıktılar: bu belge; yerinde güncellenen `C0_HARITA.md` ve `C0v_ADIM_EKLERI.md` (değişen satırlar "(C0q)" ile işaretli).
Kanıt biçimi: `dosya:satır` 910ad1f'ya göredir; kod ile RAPOR_Q çelişirse kod yazılır ve fark işaretlenir.

## 0. Özet
- **Fark:** 69 dosya, +4173 −2058 (`git diff --stat fc6b392..910ad1f -- project-unicorn`). Haritalarda adı geçen 117 kod/veri dosyasından 39'u değişti, 78'i değişmedi (§2, her biri `git diff --quiet` ile doğrulandı).
- **Satır atıfları:** haritalardaki atıfların Q'nun dosyalarındaki hepsi 910ad1f'ya taşındı. 692 satır ucunun 665'inde eski ve yeni satırın metni birebir aynı; 27'sinde satırın kendisi Q'da değişti (içerik değişti, §3.3'te †). Kalan elle düzeltilen satırlar §3.3 sonunda.
- **Sözleşme:** RAPOR_Q §7.1'in adları kodda var; imza ve davranış farkı 4 yerde (§1.2). En önemlisi: Q'nun `market_ref` yenilemesi `next_renewal_day`'de değil `SprintBridges.tick_requests`'te, 12 haftalık pencerede.
- **RAPOR_Q §7.2:** listedeki 4 dosyada (`b2b_constants.gd`, `incident_system.gd`, `negotiation_system.gd`, `vc_meeting_adapter.gd`) 910ad1f'ya dek fark yok. Haritada olmayan 13 dosya §1.3'te eklendi.
- **Adım etkisi:** en çok C3a ve C3b etkilendi (§4). C1, C2, C4, C9 girdisi kod olarak değişmedi, yalnız satırlar kaydı.
- **Sorular:** C0v'nin 22 sorusundan 5'i Q yüzünden genişledi ya da kısmen çözüldü (§7.1); 9 yeni soru doğdu (23-31). RAPOR_Q §1'in üç ❌'inin C'ye etkisi §7.3'te.
- **C9** askıda: C9'a dayanan her sonuç "C9 kararına bağlı" diye işaretli (§8).

## 1. Q'nun sözleşmesi

### 1.1 Tablo
| Ad | Gerçek imza (dosya:satır @910ad1f) | Ne döner | Okuyan C adımı |
|---|---|---|---|
| `ProductQuality.fit` | `product_quality.gd:261` `fit(ctx: Dictionary) -> Dictionary`; `fit_from_levels(levels, ctx)` `:268` | {value 0-100, match, capped, weakest_emphasis, loss_area, note [{area, word}], label_key} | C3a C3b C5 |
| `ProductQuality.account_fit` | `:246` `account_fit(c: Customer) -> Dictionary` | `fit` alanları + `market_value` (aynı hesabın bugünkü satırla U'su); beklenti `c.market_ref`, boşsa bugünkü satır | C3a C5 C6 C8 |
| `ProductQuality.prospect_fit`, `prospect_ctx` | `:216` `prospect_fit(p: Prospect)`, `:211` `prospect_ctx(p)` | `fit` alanları; bağlam yıldız ve sektör, `rivals: true` (`:359-360`) | C3b |
| `ProductQuality.expectation` | `:118` `expectation(area: String, ctx := {}) -> float` | alanın beklentisi 0-3 (0: bu müşteri bakmaz); ctx `market`, `star`, `audience`, `sector`, `rivals`, `subtype` | C5 C6 |
| `ProductQuality.word`, `word_for`, `is_enough` | `:142` `word(area, ctx := {})`, `:133` `word_for(lvl, expect)`, `:147` `is_enough(area, ctx)` | `"none"`/`"weak"`/`"enough"`/`"strong"`; bool | C3b C5 C6 |
| `ProductQuality.serves` | `:153` `serves(area: String) -> int` | alanın referansı karşıladığı en büyük yıldız 0-3 | C6 |
| `ProductQuality.area_row` | `:194` `area_row(area: String) -> Dictionary` | {area, word, tone (`pos`/`neutral`/`warn`), sentence, squares 0-10, faint_from}; okuyan ekran yok (`area_row` tek tanım, `area_panel.gd:79` ayrı `_add_area_row`) | C6 |
| `ProductQuality.market_ref_for` | `:206` `market_ref_for(star: int, sector: String, subtype := ProductState.subtype()) -> Dictionary` | {alan: beklenti}, rakipsiz | C3a C5 |
| `ProductQuality.close_chance` | `:233` `close_chance(p: Prospect) -> float` | `loss_area` boşsa 1,0; değilse `CLOSE_CURVE` (`:30`) | C3b |
| `ProductQuality.used_areas`, `uses_area` | `:85` `used_areas(sector) -> Array`, `:91` `uses_area(sector, area) -> bool` | ağırlığı ≥ `USE_AREA_MIN` 0,15 (`:27`) olan alanlar: Çekirdek ve sektörün iki vurgusu | C3a |
| `ProductQuality.weights`, `emphasis`, `level` | `:66` `weights(market, sector)`, `:79` `emphasis(sector)`, `:96` `level(area, tiers := {})` | ağırlıklar (toplam 1); [vurgu 1, vurgu 2]; yuvarlanmamış seviye | C3a C5 C6 |
| `ProductQuality.next_star`, `next_ratio`, `weakest_area`, `market_fit` | `:163`, `:172`, `:179`, `:222` | yıldız; oran; alan kimliği ya da `""`; `int` | C6 |
| `CustomerRegistry.set_market_ref` | `customer_registry.gd:229` `set_market_ref(customer_id, ref: Dictionary) -> void` | yok; sinyalsiz, bilinmeyen kimlikte `push_warning`; çağıranlar `sales_system.gd:386` (imza) ve `sprint_bridges.gd:35-36` | C3a C5 |
| `Customer.market_ref` | `customer.gd:79` `@export var market_ref: Dictionary = {}` | {} = kopya yok, `account_fit` bugünkü satırı okur | C3a C5 |
| `SalesRepSystem.lost_area` | `sales_rep_system.gd:239` `lost_area(lead: Prospect) -> String` | `""` = imza; değilse `prospect_fit(lead).loss_area`; zar adayın kendi zarı (`SALT_REP_CLOSE` 449, `sales_constants.gd:280`) | C3b |
| `SalesRepSystem._close`, `_lose` | `:258`, `:245` | `_close` `:259`'da `lost_area`'yı çağırır; kayıpta `_lose` (`SalesFinalizer.lose`, haftada tek mail, `rep_deal_lost`) | C3b |
| `SalesFinalizer.lose` | `sales_finalizer.gd:47` `lose(lead_id, account, reason, target, lock_weeks) -> void` | `SalesLedger.report_loss` + `_leave` (kilit, aday kaydı silinir, `deal_walked`) | C3b |
| `EventBus.rep_deal_lost`, `meeting_lost`, `rep_deal_closed` | `event_bus.gd:219` `(rep_id, prospect_id, area)`, `:215` `(account_key, reason)`, `:218` `(rep_id, customer_id)` | `meeting_lost` `SalesLedger.report_loss`'tan (`sales_ledger.gd:190`) satışçı kaybında da yayılır; ayırt etmek için `rep_deal_lost` | C3b |
| `SalesLedger` | `repitch_blocked` `:346`, `record_loss` `:414`, `lost_week` `:421`, `loss_target` `:198`, `memory_line` `:203` | bool; satır ekler; satırları verip sıfırlar; alan kimliği; metin | C3b C7 |
| `B2BSalesSystem.satisfaction_target` | `b2b_sales_system.gd:144` `satisfaction_target(c) -> int` → `_target_on` `:149` | `clampi(round(account_fit.value − min(0,3 × account_bugs, 20)`, onboarding tabanı varsa `max(·, tol + 2)`, `+ trust)`, 0, 100)` | C3a |
| `B2BSalesSystem.account_bugs` | `:171` | `used_areas` hatlarındaki açık hata toplamı, `ProductState.costed` | C3a |
| `SalesSystem.signing_satisfaction_seed` | `sales_system.gd:420` `signing_satisfaction_seed(prospect: Prospect) -> int` | `prospect_fit(prospect).value`; taban `max(tol + 10, 50)` işlevde değil `add_b2b_customer`'da (`:371-372`) | C3b |
| `SalesSystem.add_b2b_customer` | `:344` `(prospect, seats, seat_price, satisfaction, source := "founder_pitch", discount := 0.0) -> Customer` | imza aynı; imzada `set_market_ref` (`:386`) | C3b C4 |
| `SalesSystem.b2c_quality`, `b2c_satisfaction_target` | `:222`, `:428` | `fit(B2C_FIT_CTX).value × 5/7`; Çekirdek ve İlk Kullanım uyumu | C3a (B2C ölçümü) |
| `SaveCodec.RETIRED_PRODUCT_FLAGS` | `save_codec.gd:25` | `["mvp_innovation", "mvp_stability", "mvp_experience", "mvp_step_realization"]`; her yüklemede `_decode_flags` düşürür (`:240-241`) | C3a (bayrak ekleyen göçler) |
| Şema 18 göçü | `save_manager.gd:16` `SCHEMA_VERSION := 18`, `:204-205` `if version < 18: _migrate_17(state)`, `:969` `_migrate_17`, `:992` `_retire_stability` | B2B hesaba `market_ref`; `stability` kayıp nedeni → `weak_area`/`trust` | C3a (kol `:206`, `_migrate_18`) |
| `ProductRead` taban merdiveni | `product_read.gd:97` `floor_ratios()`, `:109` `floor_state(ratio)`, `:116` `worst_floor()`; seam'ler `seams_product.gd:89-102` | `urun.floor_state`, `urun.floor_area`, `urun.trust_level` | C1 (kart koşulu `launch_leak`/`password_rule`) |
| `ProductLines.work_profile`, `ResearchTree.hidden_line_profile` | `product_lines.gd:333`, `research_tree.gd:414`; `ProductLines.memo` `:53` | `"dev"`/`"test"`/`"design"`; `capabilities` önbelleği (`reload` `:73`, `register_runtime_line` `:378` boşaltır) | D |
| `SalesFaucetSystem.product_strength` | `sales_faucet_system.gd:165` | `market_fit(STAR_MAX) ÷ FIT_SCALE` | C3b |
| `Rival.composite` | `rival.gd:35` `composite() -> float` | argümansız; `RivalCatalog.COMPOSITE_AXES` `rival_catalog.gd:33` | - |

### 1.2 RAPOR_Q §7.1 ile kod arasındaki farklar
1. **`set_market_ref` çağrı yeri.** RAPOR_Q: "imzada ve `SprintBridges.next_renewal_day`'in yenileme açılışında". Kod: `next_renewal_day` (`sprint_bridges.gd:62`) saf hesaptır; yenilemede yazan `tick_requests`'in içindeki `if GameState.day == renewal - lead` (`:35-36`), `lead` = `request.before_renewal_weeks` 12 hafta.
2. **`satisfaction_target`.** RAPOR_Q: "`account_fit.value` − açık hata bedeli + `trust_offset`". Kod ayrıca onboarding tabanını uygular (`b2b_sales_system.gd:159-160`, `ONBOARDING_GRACE_WEEKS` ve `_MARGIN`), yuvarlar ve 0-100'e keser (`:161`). Kayma (`_drift`) ve `_tick_satisfaction` aynıdır.
3. **`signing_satisfaction_seed`.** RAPOR_Q parantezi (taban tol + 10, en az 50) işlevin değil `add_b2b_customer`'ın özelliğidir (`sales_system.gd:371-372`).
4. **"C'nin imza kapısı `_close`'ta zardan önce buraya (`lost_area`)".** Kapı `lost_area`'nın içine değil, `_close`'taki çağrının önüne girer (`sales_rep_system.gd:259`); `lost_area` zarı ve `loss_area`'yı bilir, kapıyı bilmez.
Diğer adlar ve imzalar RAPOR_Q ile aynı. `area_row`'u okuyan ekran yok (RAPOR_Q'nun iddiası doğru).

### 1.3 RAPOR_Q §7.2 ortak dosya listesi ↔ C0_HARITA
Listedeki dosyalardan C0_HARITA'da hiç anılmayanlar (C0q'da §19 ile eklendi): `sales_constants.gd`, `product_lines.gd`, `product_quality.gd` (yeni), `rival.gd`, `rival_catalog.gd`, `rival_registry.gd`, `quality_model.gd`, `vc_meeting_adapter.gd` (diff boş), `sales_archetypes.gd`, `message_system.gd`, `b2c_floor_churn.json`, `shutdown_notice.json`, `b2c_creator_feature.json`. Listede olup 910ad1f'ya dek farkı olmayanlar: `b2b_constants.gd`, `incident_system.gd`, `negotiation_system.gd`, `vc_meeting_adapter.gd` (`git diff --quiet`: çıkış 0).

## 2. Q'nun dokunmadığı dosyalar
C0_HARITA ve C0v'de adı geçen 78 dosyanın hepsi için `git diff --quiet fc6b392..910ad1f -- <yol>` çıkış 0 verdi: satırları aynı kalır.

| Dosya | Haritada anılma | `git diff fc6b392..910ad1f` |
|---|---|---|
| `data/events/cards/_fixtures/b2_chips.json` | 1 | boş |
| `data/events/cards/customer/chargeback.json` | 1 | boş |
| `data/events/cards/customer/expansion.json` | 1 | boş |
| `data/events/cards/customer/leak_questions.json` | 1 | boş |
| `data/events/cards/customer/named_in_leak.json` | 1 | boş |
| `data/events/cards/customer/release_thanks.json` | 1 | boş |
| `data/events/cards/customer/request_complaint.json` | 1 | boş |
| `data/events/cards/customer/request_feature.json` | 6 | boş |
| `data/events/cards/customer/request_renewal.json` | 4 | boş |
| `data/events/cards/customer/retention.json` | 2 | boş |
| `data/events/cards/customer/security_review.json` | 1 | boş |
| `data/events/cards/funding/frank_office_move.json` | 3 | boş |
| `data/events/cards/product/incident_outage_b2b.json` | 2 | boş |
| `data/events/cards/product/incident_outage_b2c.json` | 1 | boş |
| `data/events/cards/product/sprint_pm_renewal.json` | 2 | boş |
| `data/events/cards/team/lead_overtime.json` | 1 | boş |
| `scripts/autoload/character_registry.gd` | 3 | boş |
| `scripts/autoload/promise_registry.gd` | 1 | boş |
| `scripts/autoload/time_manager.gd` | 16 | boş |
| `scripts/debug/kit_probe.gd` | 2 | boş |
| `scripts/debug/sprint_probe.gd` | 3 | boş |
| `scripts/events/core/effects.gd` | 17 | boş |
| `scripts/events/core/signals.gd` | 1 | boş |
| `scripts/events/gate/scope.gd` | 4 | boş |
| `scripts/events/present/chips.gd` | 5 | boş |
| `scripts/events/seams/seams_hr.gd` | 3 | boş |
| `scripts/events/seams/seams_incident.gd` | 3 | boş |
| `scripts/events/seams/seams_ported.gd` | 2 | boş |
| `scripts/events/seams/seams_sales.gd` | 4 | boş |
| `scripts/events/seams/seams_world.gd` | 1 | boş |
| `scripts/events/tools/lint.gd` | 3 | boş |
| `scripts/events/tools/plausibility.gd` | 3 | boş |
| `scripts/onboarding/first_week_doc.gd` | 7 | boş |
| `scripts/systems/b2b_constants.gd` | 10 | boş |
| `scripts/systems/customer_rep_system.gd` | 13 | boş |
| `scripts/systems/finance_system.gd` | 10 | boş |
| `scripts/systems/founder_constants.gd` | 1 | boş |
| `scripts/systems/hr_actions.gd` | 3 | boş |
| `scripts/systems/hr_candidate_generator.gd` | 1 | boş |
| `scripts/systems/hr_search_system.gd` | 7 | boş |
| `scripts/systems/hr_system.gd` | 3 | boş |
| `scripts/systems/incident_system.gd` | 23 | boş |
| `scripts/systems/infra_system.gd` | 21 | boş |
| `scripts/systems/negotiation_system.gd` | 3 | boş |
| `scripts/systems/office_constants.gd` | 9 | boş |
| `scripts/systems/office_system.gd` | 9 | boş |
| `scripts/systems/product_system.gd` | 3 | boş |
| `scripts/systems/research_seam.gd` | 2 | boş |
| `scripts/systems/summary_system.gd` | 2 | boş |
| `scripts/systems/support_system.gd` | 17 | boş |
| `scripts/tabs/finance/finance_ozet_view.gd` | 3 | boş |
| `scripts/tabs/finance_tab.gd` | 1 | boş |
| `scripts/tabs/hr/hr_atlas_modal.gd` | 9 | boş |
| `scripts/tabs/hr_tab.gd` | 2 | boş |
| `scripts/tabs/product/area_panel.gd` | 5 | boş |
| `scripts/tabs/product/quarter_view.gd` | 1 | boş |
| `scripts/tabs/product/sprint_card.gd` | 1 | boş |
| `scripts/tabs/product/sprint_panel.gd` | 1 | boş |
| `scripts/tabs/product/sprint_ui_shared.gd` | 1 | boş |
| `scripts/tabs/product/type_picker.gd` | 1 | boş |
| `scripts/tabs/product_tab.gd` | 7 | boş |
| `scripts/theme/build_theme.gd` | 1 | boş |
| `scripts/theme/ui_tokens.gd` | 1 | boş |
| `scripts/ui/components/build_bar.gd` | 2 | boş |
| `scripts/ui/components/left_tabs.gd` | 4 | boş |
| `scripts/ui/components/top_bar.gd` | 3 | boş |
| `scripts/ui/office/office_city.gd` | 7 | boş |
| `scripts/ui/office/office_hud.gd` | 5 | boş |
| `scripts/ui/office/office_layout.gd` | 3 | boş |
| `scripts/ui/office/office_map_card.gd` | 11 | boş |
| `scripts/ui/office/office_people.gd` | 4 | boş |
| `themes/menajer_theme.tres` | 1 | boş |
| `tools/gate_common.sh` | 1 | boş |
| `tools/gen_signal_manifest.py` | 4 | boş |
| `tools/lint_baseline.json` | 3 | boş |
| `tools/plausibility_run.sh` | 4 | boş |
| `tools/run_gate.sh` | 3 | boş |
| `tools/smoke_run.sh` | 2 | boş |

## 3. Q'nun değiştirdiği dosyalar

### 3.1 Özet (haritalarda adı geçenler)
| Dosya | Satır | Q'nun yaptığı | C adımı |
|---|---|---|---|
| `data/events/cards/product/launch_leak.json` | +3 −3 | koşul `urun.trust_level == 0` | - |
| `data/events/cards/team/password_rule.json` | +3 −3 | koşul `urun.trust_level == 0` | - |
| `data/product/sprint.json` | +0 −2 | `expectation` ve `archetypes` anahtarları silindi | C5 C6 (yeni anahtar eklenecek dosya) |
| `data/techtree/rnd_tree.json` | +9 −9 | `design_system` etkisi `design_effort`; gizli hatlarda `axis` → `profile` | - |
| `localization/strings.csv` | +35 −47 | 20 anahtar eklendi, 32 silindi, 15 metin değişti (§3.4) | C2 C3 C5 C6 C9 |
| `scripts/autoload/customer_registry.gd` | +10 −0 | `set_market_ref` (`:229`) | C3a C5 |
| `scripts/autoload/event_bus.gd` | +3 −3 | `rep_deal_lost` eklendi; `axis_floor_*(area)`; `phase_bar_raised` silindi | C3b |
| `scripts/autoload/game_state.gd` | +2 −5 | dört eksen/damga bayrağı `FLAG_TYPES`'tan çıktı; `sales_weekly_loss_rows`, `sales_loss_mail_day` girdi | C3a C7 |
| `scripts/autoload/save_manager.gd` | +39 −4 | şema 18, `_migrate_17`, zincir kolu `:204-205`, `_migrate_15` profil okuması | C3a |
| `scripts/data_models/customer.gd` | +7 −0 | `market_ref: Dictionary` (`:74-80`) | C3a C5 |
| `scripts/debug/endgame_smoke.gd` | +2132 −550 | 26 yeni, 6 silinen vaka; 69 işlev gövdesi değişti | hepsi |
| `scripts/debug/product_fixtures.gd` | +1 −1 | İlk Kullanım adı | C6 |
| `scripts/debug/run_probe.gd` | +342 −144 | yeni PROBE satırları, `desk`/`core_only`/`product` kolları, `B2B_PRODUCTS`, `_check_b2b_fixture` | C1 C3a C3b C5 C9 |
| `scripts/events/seams/seams_product.gd` | +13 −19 | `urun.axis_*`/`urun.floor_<eksen>` yerine `urun.floor_state`, `urun.floor_area`, `urun.trust_level` | C1 (kart koşulları) |
| `scripts/main/main.gd` | +213 −38 | `_seed_accounts_state` (`:513-540`), `_seed_floor_world`, `_stage_desk_losses`, shot türleri; eksen bayrakları silindi | C1 C3a C3b C8 |
| `scripts/systems/b2b_sales_system.gd` | +8 −7 | `_target_on` ürün terimi `account_fit(c).value`; `account_bugs` üyeliği `ProductQuality.used_areas` | C3a |
| `scripts/systems/hr_constants.gd` | +2 −2 | yalnız iki alan yorumu (`:12-13`) | C9 |
| `scripts/systems/message_system.gd` | +1 −1 | yalnız başlık yorumu | C7 |
| `scripts/systems/product_quality.gd` | +394 −0 | Q sözleşmesi: seviye, beklenti, U, hesap ve aday uyumu, zar eğrisi, `area_row` | C3a C3b C5 C6 |
| `scripts/systems/product_read.gd` | +43 −61 | eksen okuması silindi; `floor_ratios`, `floor_state`, `worst_floor` | - |
| `scripts/systems/product_state.gd` | +0 −45 | `axis_readings`, `realized_dims`, damga işlevleri silindi | - |
| `scripts/systems/research_tree.gd` | +15 −14 | `experience_effort` → `design_effort`; gizli hat `profile` denetimi | C1 (A7 değişmez) |
| `scripts/systems/sales_constants.gd` | +7 −6 | `LOSS_STABILITY` → `LOSS_WEAK_AREA`; `QUALITY_STRENGTH_*` 0,6/1,0; `SALT_REP_CLOSE` 449 | C3b |
| `scripts/systems/sales_faucet_system.gd` | +12 −17 | `product_strength` = `market_fit(3) ÷ 70`; `_roll_star(nth, mix)`; sektör çekiminde ikinci karıştırma turu | C3b |
| `scripts/systems/sales_finalizer.gd` | +11 −3 | `lose` (`:47`); `sign_deal` tohumu `(lead)` | C3b |
| `scripts/systems/sales_ledger.gd` | +38 −4 | `loss_target`, `memory_line`, `repitch_blocked`, `record_loss`, `lost_week` | C3b C7 |
| `scripts/systems/sales_meeting_system.gd` | +51 −28 | `_ctx`/`_fit`, `urun.product_fit` katkısı, `LOSS_WEAK_AREA`, itiraz ve alan adı | C3b |
| `scripts/systems/sales_probes.gd` | +51 −17 | vurgu soruları, `facts_for` yeni alanları, `answer_key` | C3b |
| `scripts/systems/sales_rep_system.gd` | +43 −12 | `lost_area` (`:239`), `_lose` (`:245`), `_close` zar dalı (`:259`), haftalık özet kayıp satırları | C3b C7 |
| `scripts/systems/sales_system.gd` | +86 −81 | B2C kalite/memnuniyet `ProductQuality`'den; `signing_satisfaction_seed(prospect)`; imzada `set_market_ref` (`:386`) | C1 C3a C3b |
| `scripts/systems/save_codec.gd` | +6 −0 | `RETIRED_PRODUCT_FLAGS` (`:25`), `_decode_flags` döngüsü (`:240-241`) | C3a |
| `scripts/systems/sprint_bridges.gd` | +10 −16 | `push_axes` silindi; `tick_requests` alan = vurgu 1 ve `set_market_ref` (`:35-36`); `press_line`/`actual_sentence` `ProductQuality` | C1 C5 C6 |
| `scripts/systems/sprint_catalog.gd` | +95 −89 | `expectation`/`area_word`/`word_for` `ProductQuality`'ye taşındı; `capabilities` önbellekli; `display_level`, `_standing`, `recent_hits`, `max_tier` | C6 |
| `scripts/systems/sprint_system.gd` | +5 −6 | `_go_public` `push_axes` çağrısı silindi; `_close` seviye `ProductQuality.level` | C1 C5 |
| `scripts/systems/term_sheet_table_system.gd` | +4 −5 | `E_FIT_PRODUCT_DIMS` anlamı: eksik alan yok | - |
| `scripts/systems/vc_pitch_system.gd` | +3 −17 | `weakest_area`; `_weakest_dimension` silindi | - |
| `scripts/tabs/events/mail_pane.gd` | +33 −26 | `sales_loss` kolu; rapor tablosu yalnız kapanış varsa | C7 |
| `scripts/tabs/product/product_model.gd` | +7 −7 | `_area` ve `_goal` `ProductQuality`'yi okur (`:150`, `:163`, `:443`) | C6 |
| `scripts/tabs/sales_tab.gd` | +2 −1 | `_lead_actions` (`:397-398`) tek satır | C8 |
| `scripts/ui/components/inbox.gd` | +24 −3 | `sales_loss` türü, `lost_body`, `lost_line`, haftalık raporda kayıp satırı | C3b C7 |
| `scripts/ui/meeting/sales_meeting_adapter.gd` | +14 −8 | `urun.product_fit` çipi, `_say`, itiraz satırı | C3b |
| `tools/lint_v3_frozen.json` | +0 −2 | `product.b2c_floor_signal` ve `product.b2c_floor_churn` çıktı | C3a C5 C6 |

Haritalarda adı geçmeyen değişenler: `"GDDs/GDD \342\200\224 OLAY MOTORU (EVENT ENGINE) rev 2.md"`, `CLAUDE.md`, `GDDs/GUNCELLEMELER.md`, `data/events/cards/product/b2c_floor_churn.json`, `data/events/cards/product/b2c_floor_signal.json`, `data/events/cards/rival/shutdown_notice.json`, `data/events/cards/world/b2c_creator_feature.json`, `data/product/lines/erp.json`, `data/product/lines/note_tool.json`, `data/product/lines/shared.json`, `data/product/lines/video_clip.json`, `docs/ACIK_ISLER/ACIK_KARARLAR.md`, `docs/ACIK_ISLER/ISLER.md`, `docs/EVENT_SIGNAL_MANIFEST.md`, `docs/HARITA.md`, `docs/content/events_draft/_vocabulary.md`, `docs/design/localization_glossary.md`, `scripts/autoload/rival_registry.gd`, `scripts/data_models/prospect.gd`, `scripts/data_models/rival.gd`, `scripts/systems/line_gates.gd`, `scripts/systems/product_catalog.gd`, `scripts/systems/product_lines.gd`, `scripts/systems/product_quality.gd.uid`, `scripts/systems/quality_model.gd`, `scripts/systems/rival_catalog.gd`, `scripts/systems/sales_archetypes.gd`.

### 3.2 Silinen, taşınan, anlamı değişen adlar
| Ad (eski) | Durum @910ad1f |
|---|---|
| `SalesArchetypes.uses_axis`, `of_sector`, `USE_AXIS_MIN`, `axis_weights`, `step_appetite`, `priorities` | silindi; yerine `ProductQuality.used_areas`/`uses_area` (`sales_archetypes.gd` sektör listelerine `health`, `textile`, `media` eklendi) |
| `SalesSystem.signing_satisfaction_seed()` | anlamı değişti: `(prospect)` parametreli, `prospect_fit.value` |
| `SprintBridges.push_axes` | silindi (K7b) |
| `SprintCatalog.expectation`, `area_word`, `word_for`, `_raw_level`, `_max_tier` | taşındı: `ProductQuality.expectation`, `word`, `word_for`, `level`; `max_tier` açık adla `sprint_catalog.gd:674` |
| `ProductRead.axis_reading`, `market_word`, `market_floors`, `axis_floor_state` | silindi; yerine `floor_ratios`, `floor_state`, `worst_floor` |
| `ProductState.axis_readings`, `realized_dims`, `stamp_step`, `step_realization`, `line_realization` | silindi |
| `QualityModel` ürün kısmı (`axis_score`, `dims_from_flags`, `shipped_normalized`, `AXES` okuması) | silindi; `grow`, `composite_quality`, `DEFAULT_AXES` rakip için kaldı |
| `SalesConstants.LOSS_STABILITY` | `LOSS_WEAK_AREA` (`sales_constants.gd:206`) |
| `SalesSystem._rival_relative_quality` | silindi; `b2c_quality()` |
| `urun.axis_innovation/stability/experience`, `urun.floor_<eksen>` | silindi; `urun.floor_state`, `urun.floor_area`, `urun.trust_level`; `urun.axis_reading` seam değil katkı kimliğiydi, şimdi `urun.product_fit` |
| `EventBus.phase_bar_raised` | silindi; `axis_floor_warning/crossed` parametresi alan kimliği |
| `VCPitchSystem._weakest_dimension`, `E_FIT_PRODUCT_DIM_FLOOR` | silindi; `ProductQuality.weakest_area` |
| `LineGates.above_gate_bonus`, `ProductLines.axis_of`, `AXIS_OWNER_AREA`, `weighted_points`, `net_gain` | silindi |
| `Rival.composite(quality_axes)` | `composite()` |
| `sprint.json` `expectation`, `archetypes` | silindi |
| `ProductState`/`GameState` bayrakları `mvp_innovation`, `mvp_stability`, `mvp_experience`, `mvp_step_realization` | silindi, yüklemede düşürülür |
| `B2BConstants.*` (`SIGNING_SAT_*`, `TOLERANCE_*`, `B2B_BUG_SAT_*`, `ONBOARDING_GRACE_*`) | dosya değişmedi; ölçek U oldu, RAPOR_Q §4.1 "onay bekliyor" |
| Smoke: `above_gate_bonus_ladder`, `axis_reading_replaces_not_adds`, `b2b_v1_lands_mid_band`, `b2c_satisfaction_drifts_to_experience`, `quality_half_sat_25`, `rival_relative_uses_template_half_sat` | silindi (`b2c_...` → `b2c_satisfaction_drifts_to_fit`) |

### 3.3 Satır eşlemesi (eski fc6b392 → yeni 910ad1f)
Taşınan her atıf için. † = satırın numarası aynı ama içeriği Q'da değişti. Bir satır ucu iki sürümde birebir aynı metni gösterir (makine denetimi, §9).
- `GUNCELLEMELER.md`: 277-279→284-286, 365-367→372-374, 393-395→400-402, 403-405→410-412, 260-264→266-270, 309-311→316-318, 333-336→340-343, 376-378→383-385, 834-839→847-852, 311→318, 309-310→316-317
- `HARITA.md`: 229→230, 234-235→235-236, 205-222→205-223, 214→215, 216→217, 220-222→221-223, 229-236→230-237, 234→235, 235→236, 236→237, 234-236→235-237
- `_vocabulary.md`: 385→382, 670-671→667-668
- `b2b_sales_system.gd`: 197-198→198-199, 203-216→204-217
- `endgame_smoke.gd`: 15778-15779→17189-17190, 14003→14710, 15787-15788→17198-17199, 13610→14320, 15771→17182, 15820→17231, 15739-15752→17150-17163, 18505→19915, 15774-15779→17185-17190, 2766→2791, 2801→2826, 2831→2856, 2933→2958, 3011→3036, 3032→3057, 6909→7237, 6986→7314, 7136→7464, 7305→7633, 17939→19349, 4267→4597, 13835→14545, 18418→19828, 7013→7341, 7397→7725, 9493→10266, 6614→6942, 581-590→599-608, 594-595→612-613, 3217→3332, 5440→5768, 692→710, 15717→17128, 19525→20938, 20240→21653, 20394→21807, 17442→18854, 17399→18811, 23208→24641, 3120→3145, 21254→22667, 21285→22699, 22789→24220, 15775→17186, 15739→17150, 15756→17167, 15862-15863→17273-17274, 15881-15882→17292-17293, 14606→16023, 23027-23028→24461-24462, 1479→1504, 6649→6977, 7654→7982, 7687-7688→8015-8016, 10884→11657, 12509→13223, 15539→16950, 16425-16432→17837-17844, 21371-21379→22785-22793, 21404→22818, 14661→16073
- `game_state.gd`: 82-83→77-78, 899→896, 794→791, 792→789, 321→318, 896→893, 100-101→95-96, 488-491→485-488, 302→299
- `inbox.gd`: 215→216, 214-217→215-218, 217→218, 113-125→114-126, 18→18-19, 295→296, 121-123→122-124
- `localization_glossary.md`: 169-184→174-189
- `mail_pane.gd`: 719→726, 145→146
- `main.gd`: 2922→3014, 2921→3013, 2917-2922→3009-3014, 2943→3035, 3644-3645→3742-3743, 3865→4030, 2937→3029, 3056→3148, 3064→3156, 3083→3175, 3073→3165, 692→725, 1383→1447, 673→706, 681→714, 1383-1390→1447-1454, 3966-3981→4141-4156, 657→690, 2933→3025, 2940→3032, 3345→3437, 3617→3717, 1103→1156, 2921-2922→3013-3014
- `product_model.gd`: 163† 
- `product_read.gd`: 90→67, 89-90→66-67
- `product_state.gd`: 148→121, 27-28→26-27, 301-323→274-296, 301-324→274-297, 197-202→170-175, 312-324→285-297
- `research_tree.gd`: 305-309→306-310, 49-52† , 307-309→308-310
- `run_probe.gd`: 613→776, 413→492, 425→504, 438→517, 467→546, 412→491, 465→544, 408-438→487-517, 441-483→520-562, 558→689, 56-59→103-106, 1235→1431, 1221→1417, 1154-1238→1350-1434, 1217-1218→1413-1414, 1232→1428, 589→721, 590→722, 1823→2065, 501-512→580-591, 572-592→703-724, 1868→2062, 296→374, 566→697, 92-117→154-179, 1688-1700→1906-1918, 702-754→879-931, 755-775→932-952, 683-689→860-866, 540-575→673-706, 602-617→765-781, 1214-1238→1410-1434, 29-76→29-133, 513-525→592-658, 526-539→659-672, 1154-1210→1350-1406, 1242-→1438-, 698-699→875-876, 974→1153, 989→1168, 1045-1075→1232-1262, 1232-1234→1428-1430, 92-119→154-186, 1694-1702→1912-1922, 1242-1255→1438-1451, 1240-1241→1436-1437, 27-76→27-133, 437-438→516-517, 508-509→587-588, 576-592→707-724, 1214-1237→1410-1433
- `sales_faucet_system.gd`: 279-280→274-275, 274-280→269-275, 277-279→272-274
- `sales_finalizer.gd`: 84→92
- `sales_probes.gd`: 73→77, 72→76, 70-71→74-75
- `sales_rep_system.gd`: 238→268
- `sales_system.gd`: 366-374→364-372, 421-424→417-421, 184→195
- `sales_tab.gd`: 545-546→546-547, 545→546, 557-568→558-569, 600-629→601-630, 472-505→473-506, 647-649→648-650, 564-565→565-566, 511-525→512-526, 529-551→530-552, 573-595→574-596, 634-659→635-660, 666-→667-, 647-658→648-659, 535→536, 598→599, 546→547
- `save_codec.gd`: 218-236→222-242, 197-215→201-219, 62-78→66-82, 198-199→202-203, 74-77→78-81, 245-252→251-258
- `save_manager.gd`: 16† , 373-382→375-384, 322-355→324-357, 377→379, 395→397, 299→301, 303→305, 1124-1128→1159-1163, 721→723, 724→726, 815→817, 22† , 385-400→387-402, 302→304
- `seams_product.gd`: 122-123→116-117, 120-121→114-115, 236-238→230-232, 125-126→119-120, 296-298→290-292
- `sprint.json`: 137→135, 53→52, 50-52→49-51, 39→38, 44→43, 51→50, 76→75
- `sprint_catalog.gd`: 720→719, 719-720→718-719, 143-165→130-151, 375→360, 728→727, 216→202, 229-236→215-222, 289-291→275-277, 345→331, 372→357, 438-446→423-431, 521-522→506-507, 778→782, 897→903
- `sprint_system.gd`: 1533→1532, 1532→1531, 1530-1533→1529-1532, 1517-1533→1517-1532
- `strings.csv`: 2936→2926, 3036→3026, 3037→3027, 1447→1444, 1448→1445, 3047→3037, 2727→2730, 2717→2720, 2720→2723, 2741→2744, 2765-2771→2768-2774, 2730→2733, 2742→2745, 2224→2221, 2787-2936→2790-2926, 1444-1448→1441-1445, 2471-2475† , 3210-3215→3198-3203, 2716-2764→2719-2767, 2223-2224→2220-2221, 1662→1659, 3365-3387→3353-3375, 2361→2358, 2028→2025, 2360→2357, 2436→2434
- `term_sheet_table_system.gd`: 536→535

Smoke vakaları (işlev başlangıcı): `infra_capacity_moves_both_ways` 13803→14513, `infra_heavy_step_costs_capacity` 13850→14560, `infra_overage_applies_and_stops` 13886→14596, `infra_local_provider_tradeoff` 13935→14645, `incident_gap_and_spread` 15771→17182, `incident_checkout_fix_card` 16367→17779, `incident_defer_ends_with_line` 16420→17832, `incident_regression_fixture` 16266→17678, `inbox_no_night_stamp` 6003→6331, `incident_scale` 15820→17231, `save_v10_product_state` 14520→15950, `bug_cost_b2b_account_lines` 22977→24409, `destek_empty_desk_piles_up` 13625→14335, `_seed_support_fixture` 13597→14308, `support_inflow_is_bug_free` 23110→24542, `neglect_reputation_below_zero` 23130→24562, `founder_not_double_counted` 13410→14121, `hotfix_founder_takes_support_desk` 5224→5554, `support_desk_rates_stack` 5344→5674, `rnd_tree_loads_and_validates` 14661→16073, `burn_day1_breakdown` 2766→2791, `burn_refresh_same_tick` 2801→2826, `burn_tools_and_service` 2831→2856, `marketing_push_burns_and_ends` 2933→2958, `runway_net_status` 3011→3036, `gross_runway_months` 3032→3057, `hr_search_cycle` 6909→7237, `hire_preview_counts_inherited_overtime` 6986→7314, `hr_leave_cycle` 7136→7464, `hr_raise_and_leave` 7305→7633, `seed_sign_is_not_terminal` 17939→19349, `angel_accept_is_atomic` 4267→4597, `loc_b4_derived_keys` 11607→12375, `loc_language_switch` 11699→12467, `save_v13_day_stamps_migrate` 2144→2169, `office_move_gates_and_save` 18418→19828, `hr_search_cancel_dismiss` 7013→7341, `hr_frank_guard` 7397→7725, `hr_candidate_invariants` 6614→6942, `hr_constants_contract` 7545→7873, `promotion_and_raise_gate` 10824→11597, `look_registry_unique_and_saved` 9493→10266, `satisfaction_seam_emits` 2727→2752, `b2b_lifecycle_and_countdown` 3062→3087, `b2b_onboarding_grace_floor` 3120→3145, `b2b_satisfaction_leaves_b2c_identical` 3183→3299, `b2b_promise_kept_on_ship` 3684→4016, `b2b_promise_broken_on_deadline` 3710→4042, `promise_kept_stops_countdown` 4703→5033, `promise_broken_penalty` 8578→9350, `promise_break_chain` 20166→21579, `promise_extend_once` 20123→21536, `recover_preserves_onboarding` 4762→5092, `risk_reentry_hysteresis` 12430→13144, `risk_exit_stamps_day` 12459→13173, `discount_cap_two_uses` 12411→13125, `discount_row_locked_past_cap` 12480→13194, `owned_account_erodes_slower` 5407→5737, `_erosion_over_a_day` 5440→5768, `coupling_cs_dampen_axis` 7947→8275, `b2b_cs_absorbs_routine` 3781→4113, `cs_request_absorption_by_expertise` 8455→9227, `event_trust_delta_lasting` 15508→16919, `paper_colors_two_arrivals` 21340→22754, `paper_trust_until_ships` 21386→22800, `event_amount_seam` 15463→16874, `event_chip_coverage` 15430→16841, `event_history_chip_matches_live` 5831→6159, `sales_save_roundtrip_rev6` 17442→18854, `sales_seat_price_stamp_and_expansion` 17399→18811, `bugs_leave_sales_and_vc_alone` 23208→24641, `cs_renewal_floor` 22789→24220, `cs_request_kind_state_driven` 8970→9743, `cs_request_throughput_by_pace` 8502→9274, `next_renewal_day_one_place` 21254→22667, `paper_renewal_card_first` 21285→22699, `sprint_request_on_time_met` 19544→20957, `_seed_open_request` 19525→20938, `sprint_late_for_requests` 20769→22182, `paper_speaker_is_assignee` 20844→22257, `_request_cards_up` 4660→4990, `release_thanks_each_kind` 23330→24835, `release_thanks_limits` 23378→24883, `release_thanks_incident_scope` 23421→24926, `_met_request` 23298→24803, `b2b_expansion_moves_seats_mrr_counter` 3866→4197, `b2b_expansion_no_refire` 4946→5276, `b2b_cs_escalation_refuse` 3813→4144, `complaint_never_charges_cash` 12330→13044, `promise_no_duplicate_word` 4580→4910, `promise_row_locked_after_break` 20355→21768, `promise_row_locked_when_no_room` 20394→21807.

Elle düzeltilenler (satır eşlemesi yetmedi): `run_probe.gd` `_bug_penalty` `:1788` ve `_seed_stability_fixture` `:1804-1823` silindi (yerine `B2B_PRODUCTS` `:1982`, `_check_b2b_fixture` `:1995-2019`, `_seed_b2b_world` `:2022-2082`); PROBE satırları işlev başına (`_on_churn` `:580`, `_on_signed` `:592`, `_log_state` `:673`, `_log_customers` `:707`, `_log_uflux` `:734`, `_log_b2c` `:765`, `_log_areas` `:800`); `sprint.json:131` (`archetypes`) silindi; `inbox.gd:18` iki satıra uzadı (`:18-19`); `endgame_smoke.gd` `b2b_v1_lands_mid_band` silindi, `b2c_satisfaction_drifts_to_experience` `b2c_satisfaction_drifts_to_fit` oldu (`:12533`).

### 3.4 CSV (`localization/strings.csv`)
- **Eklenen 20:** `SALES_MEETING_OBJECTION` 2418, `SALES_PROBE_PROBE_EMPHASIS_TRUST` 2458, `SALES_PROBE_PROBE_EMPHASIS_INTEGRATIONS` 2459, `SALES_PROBE_PROBE_EMPHASIS_ONBOARDING` 2460, `SALES_LOSS_WEAK_AREA` 2471, `SALES_MEMORY_WEAK_AREA` 2476, `SALES_LOCK_EMPHASIS_ENOUGH` 2481, `SALES_LOCK_ONBOARDING_ENOUGH` 2485, `SALES_ANS_PROBE_EMPHASIS_A_STRENGTH` 2487, `SALES_ANS_PROBE_EMPHASIS_A_ADMIT` 2488, `SALES_ANS_PROBE_EMPHASIS_A_CHARISMA` 2489, `SALES_REP_LOST_TITLE` 2520, `SALES_REP_LOST_BODY` 2521, `SALES_WEEKLY_LOST` 2522, `PRODUCT_STAR_NONE` 2915, `PRODUCT_STAR_SKIPPED` 2916, `PRODUCT_STAR_SERVES` 2917, `PRODUCT_STAR_TOP` 2918, `PRODUCT_AUDIENCE_ENOUGH` 2919, `PRODUCT_AUDIENCE_OUTGROWN` 2920.
- **Metni değişen 15** (yeni satır): `SALES_REASON_STABILITY` 145, `HR_AREA_MEANING_PRODUCT_MANAGER_PRODUCT` 463, `HR_AREA_MEANING_PRODUCT_MANAGER_DESIGN` 464, `HR_AREA_MEANING_DESIGNER_DESIGN` 465, `HR_AREA_MEANING_DESIGNER_PRODUCT` 466, `PROD_RND_NODE_ONBOARDING_FLOW` 586, `PROD_TYPE_ERP_TRADEOFF` 1153, `PROD_PATH_B2B_DESC` 1170, `VC_Q_WEAK_DIM` 1296, `VC_Q_WEAK_DIM_MONO` 1297, `PROD_RND_NODE_BUG_TRACKER_UNLOCK` 2215, `PROD_RND_NODE_DESIGN_SYSTEM_UNLOCK` 2225, `SALES_ARCH_OPS_CAUTIOUS_LINE` 2455, `PRODUCT_AREA_ONBOARDING` 2905, `PRODUCT_AREA_ONBOARDING_SHORT` 2906.
- **Silinen 32:** `PROD_AXIS_INNOVATION`, `PROD_AXIS_STABILITY`, `PROD_AXIS_EXPERIENCE`, `SALES_PROBE_PROBE_STABILITY_RECORD`, `SALES_LOSS_STABILITY`, `SALES_MEMORY_STABILITY`, `SALES_LOCK_AXIS_STABILITY`, `SALES_LOCK_AXIS_EXPERIENCE`, `SALES_ANS_PROBE_STABILITY_RECORD_A_STRENGTH`, `SALES_ANS_PROBE_STABILITY_RECORD_A_ADMIT`, `SALES_ANS_PROBE_STABILITY_RECORD_A_CHARISMA`, `PRODUCT_AREA_CORE_WEAK`, `PRODUCT_AREA_CORE_ENOUGH`, `PRODUCT_AREA_CORE_STRONG`, `PRODUCT_AREA_ONBOARDING_NONE`, `PRODUCT_AREA_ONBOARDING_WEAK`, `PRODUCT_AREA_ONBOARDING_ENOUGH`, `PRODUCT_AREA_ONBOARDING_STRONG`, `PRODUCT_AREA_GROWTH_NONE`, `PRODUCT_AREA_GROWTH_WEAK`, `PRODUCT_AREA_GROWTH_ENOUGH`, `PRODUCT_AREA_GROWTH_STRONG`, `PRODUCT_AREA_INTEGRATIONS_NONE`, `PRODUCT_AREA_INTEGRATIONS_WEAK`, `PRODUCT_AREA_INTEGRATIONS_ENOUGH`, `PRODUCT_AREA_INTEGRATIONS_STRONG`, `PRODUCT_AREA_TRUST_NONE`, `PRODUCT_AREA_TRUST_WEAK`, `PRODUCT_AREA_TRUST_ENOUGH`, `PRODUCT_AREA_TRUST_STRONG`, `EV_PRODUCT_B2C_FLOOR_SIGNAL_BODY`, `EV_PRODUCT_B2C_FLOOR_CHURN_BODY`.
- Satır numarası kayması: `FIN_BURN_TOOLS` 3036→3026, `FIN_BURN_SERVICE` 3037→3027, `HR_ROW_TOOLS` 3047→3037, `FIN_BURN_OFFICE`/`_SERVERS` 1447-1448→1444-1445, `PRODUCT_AREA_OVER_CAPACITY` 2936→2926, `OFFICE_*` 2717-2742→2720-2745, `B2B_EV_RENEWAL_*` ve `B2B_CHOICE_*` 767-786 aynı, `B2B_EV_REQ_*_EXPIRED` 2360-2361→2357-2358, `PRODUCT_CUSTOMERS*` 2788-2791→2791-2794, `EFFECT_SATISFACTION` 1662→1659, `EFFECT_TRUST_*` 3365-3387→3353-3375.
- `PRODUCT_AREA_CORE_*` ve beş alanın 19 sözcük cümlesi silindi; `PRODUCT_AREA_REVENUE_*` kaldı. C0_HARITA §15'in "sil" sütunu bunlardan hiçbirini içermiyordu: çakışma yok.

## 4. Adım etkisi
Her adımda önce Q'nun dokunmadığı girdi, sonra değişen girdi.

### C1 · Sunucu
- Değişmeyen: `infra_system.gd`, `incident_system.gd`, `support_system.gd`, `time_manager.gd`, `finance_system.gd`, `product_tab.gd` (diff boş); C0v C1 eki satırları aynı.
- `_go_public` `sprint_system.gd:1519-1532`; `push_axes` yok. `on_release` `sprint_bridges.gd:71-76` (kapasite satırı `:75`), `on_mvp` `:125`.
- `acquisition_multiplier` çarpanı `sales_system.gd:195`; `_audience_delta_per_hour(quality := b2c_quality())` `:188`. B2C kalite saatte bir bir kez okunur (`hourly_tick` `:151-163`).
- Sağlayıcı/kapasite okuyucuları: `sales_probes.gd:74-77`, `sprint_catalog.gd:718-719`, `seams_product.gd:114-120`.
- Tik bütçesi: 330 hesaplı gece tiki 133,6 ms, kapı 148,2 (RAPOR_Q §3, K9). C1'in saatlik otomatik ayar çağrısı ve C8'in tablosu bu payın içinde ölçülür.
- Bot: `PRESETS` `run_probe.gd:154-185` Q'nun `desk`/`core_only`/`product` anahtarlarını taşır; C1'in `server_*` kolları yeni anahtar (`server`) ekler, çakışma yok. `PROBE END` sonuna `u_unexplained_weeks` eklendi (`:1071`); C1'in sunucu alanları ondan sonra gelir. `_run_the_company` `:1438`.
- Fikstür: `incident_gap_and_spread` `:17182`, `_incident_world` `:17150` hâlâ kapasite yazmaz; `_seed_sprint_live` (`:19915`) artık üç Çekirdek hattını K1'e koyar (`_seed_mvp_lines`). C0v'nin "fikstür kapasite almalı" hükmü sürer.
- Görsel: `--tab-shot=product` Q'dan önce de kırık (RAPOR_Q §9/13); Sunucu bloğu `--product-shot=live:<tür>` ile. Yeni Q türleri `b2b_mvp`, `b2b_mature`, `b2b_quarter` (`main.gd:3598-3612`). `--tick-probe=<hız>:accounts=<n>` (`main.gd:513-540`) 330 hesaplı ERP dünyası kurar: yük senaryosu için kullanılabilir.

### C2 · Giderler
- Değişmeyen: `finance_system.gd`, `hr_actions.gd`, `hr_search_system.gd`, `first_week_doc.gd`, `finance_ozet_view.gd`; hepsi aynı satırda.
- Kayan yalnız ikincil yerler: CSV (`FIN_BURN_TOOLS` 3026, `FIN_BURN_SERVICE` 3027, `HR_ROW_TOOLS` 3037, `ONB_DOC_BURN` 101 aynı), smoke (`burn_day1_breakdown` `:2791`, `burn_tools_and_service` `:2856`, `summary_frequency_ticks` `:1504`), `PROBE MONTH_BURN` `run_probe.gd:498-516`, `GATE` `:520-568`, belge payı: HARITA `:230`/`:235-237`, GUNCELLEMELER `:284-286`, `:372-374`, `:383-385`, `:400-402`, `:410-412`, glossary `:48-50` aynı.

### C3a · Memnuniyet defteri
- **Değişmeyen yapı:** `_tick_customer` `:48`, `_tick_satisfaction` `:73`, `_drift` `:96`, `satisfaction_next_tick` `:81`, `satisfaction_after_break` `:88`, onboarding tabanı `:182-195`, `add_trust_drain` `:198`, `charge_trust_drains` `:204`, `_recover` `:423`, `on_promise_resolved` `:438` aynı; Q yalnız iki şeyi değiştirdi: ürün terimi ve `account_bugs` üyeliği.
- **Ürün terimi hazır:** toplamın "Ürün uyumu" terimi `ProductQuality.account_fit(c).value` (`b2b_sales_system.gd:155`). C3a'nın yeni olanı: Açık hata terimi `min(3 × H, 60)` (Q'nun `account_bugs` adedi 0,3 × adet, tavan 20 olarak duruyor, `B2B_BUG_SAT_*` onay bekliyor) ve yoğunluk H için `used_areas` × `ProductState.open_bugs_by_line()` × `SprintCatalog.capabilities`.
- **`trust_offset` envanteri @910ad1f** (hepsi C3a'da gider ya da deftere döner): yazıcı `customer_registry.gd:219-226`, `b2b_sales_system.gd:52-53,216,459,470,480`, `effects.gd:436`, `incident_system.gd:493`, `main.gd:1454`; okuyucu `b2b_sales_system.gd:91,145,191`, `effects.gd:688`, `incident_system.gd:580`, `customer_rep_system.gd:335`, `inbox.gd:218`, `run_probe.gd:588,721`, `customer.gd:61`, smoke 46 satır (45'ti). Q yeni okuyucu eklemedi.
- **Kayıt:** `SCHEMA_VERSION` 18 → 19 (`save_manager.gd:16`), kol `:206`, işlev `_migrate_18`; Q'nun `_migrate_17` kolundan sonra çalışır. `market_ref` göçte dokunulmaz, ama JSON'dan sayı olarak döner (R_DEFTER K2): karşılaştırmalar sayısal. `RETIRED_PRODUCT_FLAGS` her yüklemede göçlerden sonra uygulanır.
- **Smoke:** Q'nun `b2b_account_reads_fit` (`:3215`: hedef = `account_fit`, tohum, taban, `satisfaction_next_tick`), `bug_cost_b2b_account_lines` (`:24409`, `target` = fit − maliyet + trust), `account_uses_area_rule`, `save_v17_market_ref`, `fit_account_ref` C3a'nın silip yeniden kuracağı varsayımları içerir (`onboarding_floor`, `trust_offset`, `satisfaction_next_tick`). `b2b_onboarding_grace_floor` (`:3145`) Q'da +96/−5 yeniden yazıldı, C3a yine siler.
- **Fikstür:** `_seed_b2b` (`:710`) artık ERP'yi K2'de kurar; `_sign_fixture` (`:599`) imzası aynı. Bot: `_check_b2b_fixture` (`run_probe.gd:1995-2019`) `B2BSalesSystem._target_on` ve `onboarding_floor_until` okur, `b2b_*` presetlerinin niyetini denetler; C3a yeniden yazar (`PROBE FIXTURE` `:2016`).
- **PROBE:** `PROBE SAT target` artık defterin ortalama uyumu (`run_probe.gd:726`), `PROBE CUST target` `satisfaction_target` (`:719`), `PROBE UFLUX` (`:734-759`) `account_fit` değişimini sürüm/yenileme ile açıklar.
- **Açıklar:** adsız U düşüşü (Ar-Ge gizli hat, yeni soru 24), C3a-C3b aralığı (25), B2C destek zararı (26), `risk_reason` alanı (28).

### C3b · İmza değeri ve kapısı
- **Kapının yeri:** `sales_rep_system.gd:259` (`var lost: String = lost_area(lead)`) önüne; kurucu yolunda `SalesMeetingSystem._derive_loss_reason` `:343` / `_lose` `:326`. Kayıp ortak yol `SalesFinalizer.lose` `:47`.
- **Kapı payı ölçümü** (RAPOR_Q §7.4, imzada U < tol + 10; `PROBE FIT u=` = `prospect_fit.value`): `fix_worst` 2★ %8,5 (12/142), 3★ %57 (4/7); masalı 2★ %4,9 (15/309), 3★ %11,9 (21/176); `quality_core` 2★ %73,7 (70/95); 1★ %0. Eşik: `seed_tolerance` 33 + 9 × (yıldız − 1) + sektör payı (`b2b_constants.gd:39-52`) → kapı 1★ 43-48, 2★ 52-57, 3★ 61-66.
- **Zar tabanı:** kapıyı geçen adayın `CLOSE_CURVE` ihtimali 1★ %36-46, 2★ %54-63, 3★ %70-78 (eğri `product_quality.gd:30`; hesap §9). K6 "en az %60" 1★'ta ve 2★'ın alt ucunda bağlar. RAPOR_Q §1/2: masalı `fix_worst`'te satışçı kapanış kaybı 0/328.
- **Çağıranlar:** `add_b2b_customer` ve `signing_satisfaction_seed` çağıranları §3.3 ve C0v C3b eki (yeni: `main.gd:533`, smoke `:15458,18818,18841,18873,20947,21662,21817`).
- **Silinecek:** `signing_satisfaction_seed(prospect)`, `add_b2b_customer`'ın `satisfaction` parametresi ve `:371-372` tabanı, `SIGNING_SAT_MIN`. `b2b_v1_lands_mid_band` Q'da silindi: yazılacak yok.
- **Aday kartı:** `sales_tab.gd:323-376` Q'da değişmedi; Q aday kartı için anahtar yazmadı (yeni soru 31). Kayıt mesajı: `sales_loss` {rep, company, area}; `inbox.gd:335-346` `lost_body`/`lost_line` yalnız eksik alan metnini okur: açık hata varyantı için mesaja neden alanı gerekir.
- **Smoke:** `bugs_leave_sales_and_vc_alone` (`:24641`) Q'da yeniden yazıldı; kapı onun okuma listesinin (`signing_seed`, `_derive_loss_reason`, `repitch_blocked`, …) dışında kalmalı (soru 16).
- **PROBE:** `PROBE FIT/REPLOSS/MLOSS/LEAD` (`run_probe.gd:611,634,620,641`) kapı kaybıyla çakışmaz; C3b'nin ayrı alanı bunlara eklenir.

### C4 · Kurumsal madde
- Değişmeyen: `infra_system.gd` (`meets_enterprise_trust`, `blocks_enterprise_signature`), `sales_faucet_system.gd:269-275` balina koşulu, `sales_ledger.gd:360`, `sales_meeting_system.gd:157`, `sales_probes.gd:75`.
- `add_b2b_customer` imzası aynı; `Customer`'a madde alanları `market_ref`'in (`:79`) ardına eklenir. Fikstür: `_seed_b2b` 1★ aday kurar; C4 vakası 3★ hesap ister (`_sign_fixture` yıldızı adaydan alır).

### C5 · Yenileme
- **`market_ref` tetikleyicisi:** `sprint_bridges.gd:35-36`, 12 haftalık pencere; taşıma smoke `fit_account_ref` (`:15497`) ve `PROBE UFLUX` (`run_probe.gd:750`) ile birlikte değişir. Tetikleyici bugün 1★/2★/3★ hepsi için; C6'nın 3★ süzgeci bu satırı kapsamaz.
- `next_renewal_day` `:62`, `decision_renewal_saved` (`sprint_system.gd:482`), `customer_rep_system.gd`, `request_renewal.json`, kesinti yuvası (`sprint_system.gd:564`, `:1261-1276`) Q'da değişmedi; kayıtlar aynı.
- Sektör eğilimi için 13 sektör kimliği: `ProductQuality.TABLE` (`:48-62`) = `B2BConstants.SECTORS` listesi (13); `textile` ve `media` satırları onay bekliyor.
- Kayıp yolu: `SalesFinalizer.lose` yalnız aday kaybı içindir; hesap kaybı hâlâ `_remove_lost` (A19).
- Mesaj kalıbı: `sales_loss` (Q) ve `sales_week` aynı üç yerde (`inbox.gd:18-19`, `mail_pane.gd:137,148`).
- `sprint.json` `request` bloğu `:38`; Q `expectation` ve `archetypes` anahtarlarını sildi, C yeni anahtarları aynı dosyaya ekler.

### C6 · Genel Bakış ve istekler
- `area_row` hazır ve okunmuyor; Sürüm bloğu satırları onu çizer. Beklentisi 0 olan alanda `squares` 0, `word` `strong` (soru 29).
- Alan cümleleri Q'nun: `PRODUCT_STAR_*`, `PRODUCT_AUDIENCE_*` (`strings.csv:2915-2920`); 19 alan×sözcük cümlesi silindi (alanlara özgü tat gitti; RAPOR_Q §9/4 Erdem'e).
- B2C ürün sayfası referansı kitle yıldızı ile 2★'ın büyüğü: B2C Sürüm bloğunda küçük kitlede de 2★ okunur.
- İstek alanı vurgu 1 (`sprint_bridges.gd:41`); `request_area_follows_emphasis` yeni vaka. `thank` `:190` aynı.
- `product_model.gd` Q'da yalnız `_area`/`_goal` (`:150`, `:163`, `:443`); `area_panel.gd` aynı. Görsel: `live:b2b_mvp|b2b_mature|b2b_quarter` var.

### C7 · Destek raporu
- `_tick_weekly_summary` `sales_rep_system.gd:301`; kayıplı hafta da rapor açar; mesaj türü `sales_loss` kalıbı `message_system.gd:5`, `inbox.gd:18-19,311-316`, `mail_pane.gd:137,148`. `support_system.gd` aynı.

### C8 · HESAPLAR
- `sales_tab.gd` Q'da yalnız `:397-398`; ötesi +1 kaymış (`_paint_portfolio` `:512`, `_account_card` `:530`, `_satisfaction_row` `:601`, `_account_foot` `:635`, `_open_steward_picker` `:667`).
- 330 hesaplı dünya hazır: `main.gd:513-540`. Hesap başına `account_fit` maliyeti: R_DEFTER K4b 175 µs/hesap, `capabilities` önbelleğiyle K9'da gece tiki 133,6 ms; tablonun satır başına çağrısı ayrıca ölçülür.

### C9 · Maaş, masa, taşınma, bot (askıda: C9 kararına bağlı)
- Q'nun dokunduğu: `hr_constants.gd:12-13` iki yorum; `HR_AREA_MEANING_*` dört metin (okuyucusuz, RAPOR_Q §9/6). Ofis, Atlas, `hr_search_system.gd`, `finance_system.gd` aynı.
- Bot: `_hire_after_the_seed` `run_probe.gd:1410`, `STAFF_LADDER` `:1350`; Q'nun `desk` kolu `_desk_ceiling` `:1292`. Debug arama çağrıları `main.gd:3029,3148,3156,3175`, komisyon `:3165`.

## 5. Smoke, PROBE, preset

### 5.1 Q'nun yeni ve silinen vakaları
- **Yeni 26:** `account_uses_area_rule`, `b2b_account_reads_fit`, `b2c_audience_reads_fit`, `b2c_satisfaction_drifts_to_fit`, `fit_account_ref`, `fit_scale`, `fit_star_context`, `floor_ladder_areas`, `product_area_row`, `product_fit_table`, `product_line_profiles`, `product_quality_sector_table`, `request_area_follows_emphasis`, `rival_composite_table`, `rnd_design_discount_reads_profile`, `sales_emphasis_question`, `sales_meeting_reads_fit`, `sales_rep_close_chance`, `sales_rep_close_die`, `sales_rep_loss_mail`, `sales_sectors_all_produce_leads`, `sales_star_mix_reads_fit`, `sales_weak_area_loss`, `save_retired_product_flags`, `save_v17_market_ref`, `vc_weakest_area` (`_case_` işlevi sayısı 445 → 465).
- **Silinen 6:** `above_gate_bonus_ladder`, `axis_reading_replaces_not_adds`, `b2b_v1_lands_mid_band`, `b2c_satisfaction_drifts_to_experience` (adı değişti), `quality_half_sat_25`, `rival_relative_uses_template_half_sat`.
- **Q'nun gövdesini değiştirdiği, C'nin dokunacağı vakalar:** `b2b_lifecycle_and_countdown`, `b2b_onboarding_grace_floor`, `b2b_satisfaction_leaves_b2c_identical`, `b2b_cs_absorbs_routine`, `b2b_cs_escalation_refuse`, `owned_account_erodes_slower`, `coupling_cs_dampen_axis`, `promise_broken_penalty`, `risk_exit_stamps_day`, `bug_cost_b2b_account_lines`, `bugs_leave_sales_and_vc_alone`, `sales_save_roundtrip_rev6`, `next_renewal_day_one_place`, `sprint_request_on_time_met`, `infra_local_provider_tradeoff`, `rnd_tree_loads_and_validates`, `save_v10_product_state`, `incident_night_hold_resumes`, `neglect_reputation_below_zero`; yardımcılar `_seed_b2b`, `_seed_risk_account`, `_seed_support_fixture`, `_seed_open_request`, `_seed_sprint_live`.

### 5.2 PROBE satırları (`run_probe.gd`)
`PROBE LEAD` `:641` (id arch sector star phase u loss), `PROBE SIGN` `:603` (+ sector arch tol phase areas), `PROBE FIT` `:611`, `PROBE REPLOSS` `:634` (satışçı kaybı), `PROBE MLOSS` `:620` (kurucu kaybı), `PROBE UFLUX` `:734` (changed release renewal unexplained), `PROBE AREAS` `:800`, `PROBE VCQ` (`_log_vcq`), `PROBE FIXTURE` `:2016`, `PROBE B2C` `u=` `aud_star=` `:770`, `PROBE SAT target` `:726`, `PROBE END u_unexplained_weeks` `:1071`. `PROBE SHIP` eksen alanlarını basmıyor.

### 5.3 Preset'ler ve komutlar (RAPOR_Q §7.3, §5; `PRESETS` `run_probe.gd:154`)
`full_run_fix_worst_desk` (anahtar `desk`), `full_run_quality_core`, `full_run_quality_core_desk` (`core_only`), `full_run_vc_product`, `full_run_b2c_vc_product` (`vc: product`). C'nin kullanacağı: A'nın `full_run_fix_{none,worst,due,off}` ve `full_run_b2c_fix_*` (C3a kapıları), `_desk` kolları (satışçı payı, kapı payı), `full_run_vc_cautious` (`run_gate`). Komutlar: `--run-log=<preset>:104:sim:<tohum> --lang=tr` (tohum 7 ve 11, koşu başına ayrı `APPDATA`, en çok iki paralel), `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1[:market=b2b]`, `--tick-probe=3` ve `--tick-probe=3:accounts=330`.

## 6. W1 çakışması
Q'nun gerçek CSV'si (`strings.csv` farkı, §3.4) W1_METINLER.json'un 242 öğesiyle karşılaştırıldı. Anahtar ailesi çakışması yok (`SALES_SAT_*`, `SALES_ACCOUNTS_*`, `SALES_SIGN_*`, `SALES_LOSS_BUGS_*`, `SALES_SECTOR_*`, `MAIL_SUPPORT_*`, `HR_ATLAS_DESK_*`, `PRODUCT_OV_*`, `PRODUCT_SERVER_*`, `B2B_CLAUSE_*`, `B2B_RENEW_*`, `B2B_BUDGET_*` önekleriyle başlayan satır 910ad1f CSV'sinde 0).

| W1 id | Q anahtarı | İlişki | Öneri |
|---|---|---|---|
| `loss.bugs_rep` | `SALES_REP_LOST_BODY` (`:2521`), konu `SALES_REP_LOST_TITLE` (`:2520`) | aynı mail, farklı neden (açık hata ↔ eksik alan); slotlar `{company}`, `{area}` aynı | W1'de kalsın; yalnız `loss_area` boşken kullanılır. Konu Q'nun |
| `loss.bugs_summary_row` | `SALES_WEEKLY_LOST` (`:2522`) | ikiz satır, aynı slotlar | W1'de kalsın |
| `loss.bugs_meeting` | `SALES_LOSS_WEAK_AREA` (`:2471`) | görüşme kayıp cümlesinin ikizi | W1'de kalsın |
| `sat.term_fit` | `SALES_MOD_PRODUCT_FIT` (`label_key`), `PRODUCT_LEVEL_*` (`:2786-2789`) | `{areas}` Q'nun `note`'undan; Q etiketi küçük harf | W1'de kalsın; sözcükler Q'nun |
| `ov.stability_head` | `PROD_AXIS_STABILITY` silindi | çakışma kalktı | W1'de kalsın |
| `ov.release_*` | `PRODUCT_STAR_*`, `PRODUCT_AUDIENCE_*` (alan cümleleri) | W1 alan cümlesi yazmıyor | çakışma yok |
| `renew.outcome_switch` `{area}` | `PRODUCT_AREA_*_SHORT` | `weakest_emphasis` kimliği kısa adla yazılır; ONBOARDING kısa adı "İlk kullanım" | W1 metninde "onboarding" geçmiyor: etkilenmez |
| `sign.mail_line*` | yok | Q imza maili yazmadı | W1'de kalsın |
| aday kartı U sözcüğü | `label_key` + `note` + `PRODUCT_LEVEL_*` | W1'de yok, Q'da hazır cümle yok | yeni soru 31 |
| "alan sözcüğü", "sektör cümlesi" | `PRODUCT_LEVEL_*` var; sektör cümlesi anahtarı yok | W1'de ikisi de yok | W1'den düşecek madde yok; sektör cümlesi gerekiyorsa yeni madde |

## 7. E1

### 7.1 C0v'nin 22 sorusu
| # | Konu | Q sonrası durum |
|---|---|---|
| 1, 2, 3 | yük çarpanı, tavan, kapasite sayısı | değişmedi (`incident_system.gd`, `infra_system.gd` diff boş) |
| 4 | `incident_playbook` | değişmedi; yalnız `research_tree.gd:52` adı `design_effort` |
| 5, 6, 7, 8 | masa, taşınma, Plaza/Loft sayımı, onboarding belgesi | değişmedi; **C9 kararına bağlı** |
| 9 | gelen kutusu hatırlatıcısı | genişledi: `risk_reason` her koşulda Güven & Ölçek der (yeni 28) |
| 10 | iki pencere | genişledi: `market_ref` yenilemesi 12 haftalık pencerede, smoke ve PROBE onu sınıyor |
| 11, 12 | istek kartı yolu, kayıp sayacı | değişmedi (istek alanı vurgu 1 oldu) |
| 13 | B2C destek zararı | genişledi: Q'nun C10 kalibrasyonu zararlı dünyada koştu (yeni 26) |
| 14, 15 | destek raporu gönderen, `per_sprint` | değişmedi |
| 16 | satış hatayı okur | genişledi: vaka Q'da yeniden yazıldı |
| 17, 18, 19 | madde tiki, balina koşulu, "Müşteriler" şeridi | değişmedi |
| 20 | PROBE alanları | kısmen çözüldü: `PROBE SIGN by=` ve `desk` kolları satışçı payını ölçülebilir kılıyor; saat durması açık |
| 21, 22 | "Hayır diyemez", "Söz ver" +8 | değişmedi |

### 7.2 Q sonrası doğan sorular (C0v'de 23-31)
23. **İmza kapısı hangi U'yu okur?** `prospect_fit` rakip penceresi dahil (`product_quality.gd:359-360`), hesap `account_fit` rakipsiz `market_ref` (`:246`); Q'nun kapı payı ölçümü `prospect_fit.value`. Öneri: kapı `prospect_fit`, imza değeri `account_fit`.
24. **Ar-Ge gizli hat açılışında hesabın U'su adsız düşer** (RAPOR_Q §4.2/8, §7.4; `PROBE UFLUX` bunu `unexplained` sayar: `run_probe.gd:750-752`). Öneri: Ar-Ge tamamlanması açıklayıcı olay sayılır, ipucundaki "Ürün uyumu" satırı `note` ile alanın yeni hâlini söyler.
25. **C3a ile C3b arası.** Zayıf ürünle imzalanan 2★/3★ hesap C3a'dan sonra ilk tikte U'ya iner (`R_DEFTER` K4b: gün 27, sat 43 / tol 51). Öneri: C3a'nın A kapıları `desk` kollarıyla koşar; sıra aynı.
26. **B2C: destek zararı silinince C10 kalibrasyonu.** Öneri: C3a sonrası `full_run_b2c_fix_*` tohum 7 ve 11, 26/52/104. hafta kitle sapması ölçülür (RAPOR_Q: 18/24).
27. **Zar tabanı %60 ve `CLOSE_CURVE`.** Kapıyı geçen aday ihtimali 1★ %36-46, 2★ %54-63, 3★ %70-78 (§4). Öneri: `max(close_chance, 0,60)` yalnız kapıyı geçende; eğri Q'nun onay bekleyen sabiti, dokunulmaz.
28. **`risk_reason` alanı.** Öneri: neden defterin en büyük olumsuz satırı; "Ürün uyumu" ise `account_fit(c).loss_area` kısa adıyla; `SALES_REASON_STABILITY` silinir.
29. **`area_row` çizimi.** Beklentisi 0 alanda kare 0 ve `word` "strong". Öneri: gri "—".
30. **Görsel kabul aracı.** `--tab-shot=product` kırık; öneri: `--product-shot=live:<tür>`.
31. **Aday kartı sözcüğü.** Q anahtar yazmadı; `SalesMeetingSystem._fit_line` (`:210`) özel ve oturum durumuna bağlı. Öneri: cümle kurma kısmı adayı parametre alan işleve çıkarılır, yeni anahtar yok.

### 7.3 Q'nun onay bekleyenlerinden ve Erdem'e sorularından C'yi bağlayanlar
- **Sabitler (RAPOR_Q §4.1):** `TOLERANCE_BASE` 33, `TOLERANCE_PER_SCALE` 9, `SECTOR_TOLERANCE_BONUS`, `SIGNING_SAT_OVER_TOL` 10 (kapının payı), `SIGNING_SAT_MIN` 50, `B2B_BUG_SAT_PER/CAP`, `ONBOARDING_GRACE_MARGIN`: C3a/C3b bunları siler ya da okur; hepsi Q'da onaysız. `CLOSE_CURVE`, `QUALITY_STRENGTH_LOW/HIGH`, `RATIO_CAP`, `CORE_3`, `EMPHASIS_3`, `REST_3`, `PAGE_STAR`, `AUDIENCE_STARS`, `textile`/`media` satırı: U'nun aralığını belirler (C3a, C3b, C6).
- **Kurallar (§4.2):** 4 (eksik alan varsa kayıp nedeni hep `weak_area`; kapının açık hata nedeni yalnız `loss_area` boşken), 6 (kurucunun kaybı özet satırı; "Temsilciye ver" kapalı), 7 (`area_row` 0 beklenti), 8 (gizli hat → U düşer: soru 24).
- **Metinler (§4.3):** Ürün sayfası ve görüşme anahtarları Q'nun onay bekleyen metni; C bunlara yaslanır, silmez.
- **§9 soru 1 (Çekirdek 1,25 mi 1,5 mi):** C3a "oynanış riski 1" (bakımlı üründe memnuniyet 92-96) ve C3b kapı hedefleri U'nun doyumuna bağlı; kapı payı ölçümü 1,25 ile alındı. C0s ve E2 hangi değerle koşacağını bilmeli.
- **§9 soru 4:** alanlara özgü tat C6'nın Sürüm bloğu cümleleri.
- **§9 soru 6:** `HR_AREA_MEANING_*` okuyucusuz; C9'un Atlas kilit cümleleri W1'de bunlara dayanmıyor (**C9 kararına bağlı**).
- **§9 soru 13:** `--tab-shot=product` kırık (soru 30).
- RAPOR_Q §1'in üç ❌'i:
  1. B2B hızı ve 2★ doyumu: C'nin imza kapısı geldikten sonra erken haftalar yeniden ölçülür (RAPOR_Q §1/1); E2 bu karşılaştırmayı yapar.
  2. Satışçı zarı neredeyse hiç atılmıyor (0/328, masalı `fix_worst`): C3b'nin kapısı bu boşluğu doldurur; PRD Karar 6 "ürün kaynaklı kayıp bakımlı üründe %5-20" hedefi için kapı payı 2★ %4,9-8,5, 3★ %11,9: hedef alt sınırda.
  3. B2C eğrisi 18/24: C3a'nın B2C destek zararı kararı bu sayıyı oynatır (soru 26).
- §7.4'ün açıkları: `Inbox.risk_reason` → soru 28 (C3a/C8); donuk `market_ref` → soru 24 (C3a/C5); `risk_exit_stamps_day` uyum terimine duyarsız → C3a vaka `risk_exit_stamps_day` (`:13173`) toplam terimli okumaya göre yeniden kurulur.

## 8. C9 kararına bağlı olanlar
Erdem evde 1-2 uzaktan çalışan istiyor; karar `docs/strateji/ANA_RESIM.md` üzerinden gelecek. Aşağıdakiler karara bağlı: C9'un tamamı (masa tavanı, Plaza şartı, taşınma, maaş bandı, bot kolları `cash_spend`/`cash_hoard`, `PROBE DECISION`), C0v sorular 5-8 (masa katalog/3B, aday taşınma, Plaza/Loft sayımı, onboarding belgesi), İş hanı'nın Frank şartı, `office_hud.gd:98` nefesi, `funding/frank_office_move.json`, `hr_atlas_modal.gd` kilit cümleleri, C2'nin `fin.office_tip` ipucunun görünürlüğü, botun `_hire_after_the_seed` eşiği (`run_probe.gd:1428-1430`).

## 9. Doğrulama
- `git rev-parse HEAD` = `910ad1f1d51d35295b426c6e43ffcb85643e50fd`; `git diff --stat fc6b392..910ad1f -- project-unicorn`: 69 dosya, +4173 −2058.
- 78 dosya `git diff --quiet fc6b392..910ad1f -- <yol>` çıkış 0 (§2). RAPOR_Q §7.2'den `b2b_constants.gd`, `incident_system.gd`, `negotiation_system.gd` aynı komutla çıkış 0; `vc_meeting_adapter.gd` `--numstat`'ta yok.
- Satır taşıma: her atıf için `git diff -U0` hunk ofsetleriyle eski satır → yeni satır; uç satırların eski ve yeni dosyadaki metni karşılaştırıldı: 692 ucun 665'i birebir aynı, 27'si içerik değişikliği (†). Smoke vakaları için işlev imzası satırı yeni dosyada aranıp bulundu (96 vaka; ikisi silindi).
- `CLOSE_CURVE` ihtimalleri: noktalar (40; 0,30), (55; 0,60), (70; 0,85), (80; 0,95) arası doğrusal; U = 43, 48, 52, 57, 61, 66 için 0,36 / 0,46 / 0,54 / 0,63 / 0,70 / 0,78.
- Çakışma denetimi: W1 öneklerinin 910ad1f CSV'sinde karşılığı 0 (§6).
