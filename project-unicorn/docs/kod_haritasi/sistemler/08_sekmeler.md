# Arayüz sekmeleri (scripts/tabs/)

Dizin sürümü: git `f3113fa4` (DIZIN.md başlığı) · 2026-10-22 · satır numaraları bu ağaçtaki dosyalara göredir (kirli ağaç dahil).

Ne yapar: Sekmeler, ofisin üstünde `WindowLayer`'ın açtığı dokuz pencere sayfasıdır (Ürün, Satış, Ekip, Finans+Yatırım, Piyasa, Kişisel, Ar-Ge, Olaylar). Sayfa durumu sistemlerden okur ve çizer.
Hesap yapmaz; eylemi sisteme verir. Yatırım ("av") sayfası `hunt_tab.gd`'dir, sahnesizdir ve Finans penceresi içinde kurulur. Karar beklerken pencereler yalnız okunur.

## Dosyalar

Sekme kökleri (scripts/tabs/):
- `scripts/tabs/product_tab.gd` (321): Ürün penceresi kabuğu: başlık KPI'ları, GENEL BAKIŞ/SPRINT/ÇEYREK şeridi, yerel `_ui` durumu, eylem yönlendirme (`_act`).
- `scripts/tabs/sales_tab.gd` (834): Satış: fiyat duruşu, boru hattı (lead belgesi), satış masası, son hareketler, müşteri portföyü, canlı B2C kitle sayfası.
- `scripts/tabs/hr_tab.gd` (542): Ekip: Kadro/Görevler görünümleri, Atlas ve Mesai panel açıcıları, satır menüsü, yapı anahtarıyla yerinde boyama.
- `scripts/tabs/finance_tab.gd` (144): Finans kabuğu: nakit/net/runway KPI'ları, ÖZET|YATIRIM şeridi, Yatırım kilidi (`_yatirim_locked`).
- `scripts/tabs/hunt_tab.gd` (544): Yatırım sayfası: Frank şeridi, seed turu kartı, yatırımcı listesi, teklifler, bekleyen toplantı (VC sistemlerinin ince arayüzü).
- `scripts/tabs/rnd_tab.gd` (273): Ar-Ge kabuğu: AĞAÇ|GEÇMİŞ şeridi, koşan araştırma satırı, ağaç yapı anahtarı, seçili düğümü bayrakla saklama.
- `scripts/tabs/events_tab.gd` (369): Olaylar (gelen kutusu): süzgeçli liste, gün ayraçları, klavye gezintisi; modeli `Inbox`'tadır, okuma bölmesi `mail_pane.gd`.
- `scripts/tabs/piyasa_tab.gd` (689): Piyasa: üç karo, süzgeç çipleri, sıralı liste, rapor kartı, yıl sonu satırları, 13H/1Y/5Y/Tümü grafiği; salt okunur.
- `scripts/tabs/personal_tab.gd` (266): Kişisel: kurucunun portresi, görev, deneyim, beceri, huy, kilometre taşları, evre hedefi, hisse ve değerleme.

Alt klasörler:
- `scripts/tabs/events/mail_pane.gd` (885): Okuma bölmesi: kart/mesaj/hatırlatıcı/Ar-Ge notu; seçenek grameri, karar `EventGate.resolve`, sender avatarı, konu hapı.
- `scripts/tabs/finance/finance_ozet_view.gd` (590): `FinanceOzetView`: Özet sayfası (kasa eğrisi, işlemler, hisse tablosu, hedef, akış, gider dağılımı, Frank notu, rakip ligi).
- `scripts/tabs/hr/hr_ledger.gd` (453): `HRLedger`: Kadro sütunları, başlık, satır, satır menüsü eylemleri ve onayları (`action_list`, `run_action`).
- `scripts/tabs/hr/hr_assignments.gd` (188): `HRAssignments`: Görevler matrisi (kim hangi işte), kutu hâlleri, lejant; kurucu yok.
- `scripts/tabs/hr/hr_atlas_modal.gd` (484): Atlas paneli: rol/seviye seçimi ve aday dosyaları, işe alım ve masa şeridi (`hr_panel.gd`'den türer).
- `scripts/tabs/hr/hr_panel.gd` (132): Ekip penceresinin PanelLayer paneli tabanı (Atlas, Eğitim, Mesai); `button`, `spring`, `spaced`, `seat`.
- `scripts/tabs/hr/hr_dossier.gd` (232): Ekip dosyası: kişinin ayrıntı penceresi (`DETAILS["hr_dossier"]`), kişi ayrılınca kendini kapatır.
- `scripts/tabs/hr/hr_popover.gd` (113): `HRPopover`: çapaya bağlı tek açılır panel (satır menüsü, zam kutusu, sorumlu seçici).
- `scripts/tabs/hr/hr_ui_shared.gd` (506): `HRUiShared`: koyu tablo kiti (`D_*`), rozetler, moral, deneyim, durum hücresi, `mount_panel_modal`; tabloların dışında da kullanılır.
- `scripts/tabs/product/product_model.gd` (1034): `ProductModel`: sprint ekranının görünüm sözleşmesi; `live()` GameState/SprintSystem'den Dictionary kurar.
  Başlık yorumu yeni ekranın alanlarını da tanımlar: `founder`, `requests`, `modules`, `prep`, çeyreğin saati, merkez ve sonraki sütun eklemeleri, kart satırı; düzeltme işinin efora girişi ve gösterim kuralı.
- `scripts/tabs/product/sprint_panel.gd` (423): `SprintPanel`: orta (bu sprint) ve sağ (sonraki sprint) sütunlar; başlık/alt sabit, kart yığını kayar.
- `scripts/tabs/product/sprint_card.gd` (370): `SprintCard`: tek kart (`State`, `Look` kipleri); yalnız sözlüğünü çizer, düğme olaylarını `action` ile yayar.
- `scripts/tabs/product/sprint_ui_shared.gd` (398): `SprintUiShared`: ortak statik parçalar (label, box, pad, avatar, kapasite çubuğu); Ürün dışında 10+ dosya kullanır.
- `scripts/tabs/product/area_panel.gd` (232): `AreaPanel`: sol panel: Geçmiş, Müşteriler, alan akordeonu, açık hatlar, aday kartları.
- `scripts/tabs/product/quarter_view.gd` (209): `QuarterView`: ÇEYREK görünümü: hedef şeridi, dar alan paneli, altı sprint sütunu, onay düğmeleri.
- `scripts/tabs/product/overview_view.gd` (96): GENEL BAKIŞ kâğıdı (şimdilik yalnız Sunucu bloğu; Azalt düğmesi kapasite 0 birimdeyken `server.decrease.off` ile kapalı); class_name yok.
- `scripts/tabs/product/type_picker.gd` (116): `TypePicker`: MVP öncesi tek ekranlık tür ve ad seçici (iki pazar sütunu, kart pazarı da seçer); taslak `SprintSystem`'e yazılır, onay `chosen` olur.
- `scripts/tabs/rnd/rnd_tree_view.gd` (433): `RnDTreeView`: aile sütunları (3 satır kafes), karolar, seçili düğümün kartı alanı.
- `scripts/tabs/rnd/rnd_detail_panel.gd` (272): `RnDDetailPanel`: düğüm kartı (durumlar, gereksinim çipleri, Başlat/Duraklat/Vazgeç).
- `scripts/tabs/rnd/rnd_assign_panel.gd` (236): `RnDAssignPanel`: kartın içindeki atama paneli (alan grupları, onay kutuları, yüzler).
- `scripts/tabs/rnd/rnd_history.gd` (85): Ar-Ge geçmişi: not ve keşif postaları, gelen kutusunun satır ve bölmesini yeniden kullanır; class_name yok.
- `scripts/tabs/rnd/rnd_ui_shared.gd` (290): `RnDUiShared`: Ar-Ge'nin statik parçaları (karo durumu, ret satırı, yıldızlı metin, bağlantılar); `research_bar` da kullanır.

Bağlı dosyalar (kapsam dışı ama sekmeyi çalıştırır):
- `scenes/tabs/{ProductTab,SalesTab,HRTab,FinanceTab,PiyasaTab,PersonalTab,RnDTab,EventsTab}.tscn` ve `scenes/tabs/product/SprintCard.tscn`: sekme sahneleri (Yatırım sahnesizdir).
- `scripts/ui/components/window_layer.gd` (pencere yöneticisi), `window_frame.gd` (çerçeve, karar kapısı süzgeci), `inbox.gd` (Olaylar modeli).

## Giriş noktaları

Sekme sözleşmesi (sayfanın taşıdığı, çerçevenin çağırdığı):
- `WindowLayer.open_primary(tab_id)` `scripts/ui/components/window_layer.gd:75`: `tab_changed` gelince sekme sahnesini kurar, eskiye `on_page_closing` yayar · `window_layer.gd:62` bağlar, çok yerden emit edilir.
- `frame_options` (title, kpi, pad) `scripts/ui/components/window_frame.gd:34`: çerçeve sayfa ağaca girmeden okur · tüm sekmeler `_init`'te kurar.
- `fit_height()` + `fit_changed` `window_layer.gd:168,222-225`: pencere içerik kadar uzar · finance_tab:72, hr_tab:185, personal_tab:66, product_tab:135, rnd_tab:103, sales_tab:168, hr_dossier:75.
- `on_page_closing()` `window_layer.gd:80`: propagate_call ile sayfaya ve torunlarına · product_tab:129, rnd_tab:97, events_tab:95.
- `on_escape()` `window_layer.gd:115`: Esc önce açık seçeneği indirir · yalnız events_tab:89 (mail_pane.gd:80'e iletir).
- `on_panel_over(on)` `window_layer.gd:181`: PanelLayer paneli açılınca amber eylemi bırakır · hr_tab:191.
- `populate(payload)` `window_layer.gd:107`: ayrıntı penceresi (`DETAILS` `window_layer.gd:24`) · hr_dossier:62.
- `ProductTab.set_source(src)` `scripts/tabs/product_tab.gd:121`: debug fikstür kaynağı · game_shell.gd:176, main.gd:2235 (null = canlı model).

Ürün:
- `ProductTab._ready()` `scripts/tabs/product_tab.gd:49`: sekme açılınca görünümleri kurar, 5 EventBus sinyaline bağlar (:111-115) · WindowLayer.
- `ProductTab._rebuild()` `product_tab.gd:141`: her değişimde modelden baştan kurar; `_queue_rebuild` (:310) call_deferred ile tekler · sinyaller ve `_on_action`.
- `ProductModel.live()` `scripts/tabs/product/product_model.gd:138`: GameState.product + SprintSystem/ProductState'ten model · product_tab.gd:145, sprint_probe.gd:295.
  Planlamada ve koşarken tek oynatma (`SprintSystem.timeline`) merkezin `close_at`, `progress`, `crew`, `suggest`, `candidates` ve sonraki sütunun `load`, `carried` alanlarını besler.
- `ProductTab._on_action(kind, args)` `product_tab.gd:261`: kart/panel eylemlerini `_act` (:277) ile SprintSystem/InfraSystem'e verir · tüm alt panellerin `action` sinyali.
- `ProductTab.open_area(area_id)` `product_tab.gd:250`: DESTEK kartı alanı açık açar; görünümü `_set_ui` ile SPRINT yapar, böylece son açık sayfa hatırlanır ("edit" eylemi de) · `SprintUiShared.open_product_area` `sprint_ui_shared.gd:333`.
- `ProductTab._hold_clock(on)` `product_tab.gd:317`: sürüm notu açıkken saati tutar (`HOLD_RELEASE_NOTE` :16) · `_rebuild`, `on_page_closing`.

Ekip:
- `HRTab._ready()` `scripts/tabs/hr_tab.gd:67`: `_build`, 15 sinyal (:73), grup `HRLedger.VIEWS_GROUP` · WindowLayer.
- `HRTab._refresh()` `hr_tab.gd:197`: KPI'ları yazar; `_compute_structure_key` (:218) değişmediyse yerinde boyar, değiştiyse `_rebuild` (:242) · `_on_state_changed`.
- `HRTab.open_atlas()` `hr_tab.gd:390`: Atlas panelini açar · product_tab.gd:305, hr_tab.gd (Atlas şeridi, boş grup, Görevler).
- `HRTab.hold_person(id, on)` `hr_tab.gd:520`: dosyası/diyaloğu açık kişinin satırını seçili tutar · hr_dossier.gd:59,66, hr_action_modal.gd:66,147, training_modal.gd:31,42.
- `HRLedger.run_action(host, emp, action)` `scripts/tabs/hr/hr_ledger.gd:356`: zam, terfi, izin, çıkarma, eğitim, dosya · satır menüsü ve dosya (`action_list` :270).
- `HRPopover.mount(anchor, dark)` `scripts/tabs/hr/hr_popover.gd:99`: tek açılır panel · hr_tab `_open_actions` hr_tab.gd:489, sales_tab.gd:675.
- `HRUiShared.mount_panel_modal(host, path, on_changed)` `hr_ui_shared.gd:78`: Atlas/Mesai/Eğitim panellerini kurar · hr_tab.gd:386,392, hr_ledger.gd:368, personal_tab.gd:96.

Satış, Finans, Yatırım:
- `SalesTab._refresh()` `scripts/tabs/sales_tab.gd:174`: KPI, duruş, boru hattı, masa, günlük, portföy (B2C'de `_paint_b2c` :259) baştan çizilir · `_on_state_changed`.
- `FinanceTab._show_page(id)` `scripts/tabs/finance_tab.gd:114`: ÖZET/YATIRIM seçer, Yatırım kilitliyse döner · `finance_subpage_requested` (:58), şerit.
- `FinanceOzetView.cap_table(parent)` `scripts/tabs/finance/finance_ozet_view.gd:451` (static): hisse tablosu · personal_tab.gd:207.
- `HuntTab._refresh()` `scripts/tabs/hunt_tab.gd:102`: sayfayı baştan kurar; görünmezken `_on_changed` (:82) yalnız `_stale` işaretler · VC/seed sinyalleri.
- `HuntTab._sit_button` `hunt_tab.gd:520`: "Masaya otur" `term_table_requested` yayar (:521) · main.gd:4702 bağlar.

Ar-Ge, Olaylar, Piyasa, Kişisel:
- `RnDTab.select_node(id)` `scripts/tabs/rnd_tab.gd:114`: düğümü seçer · `rnd_node_requested` (:80; product_tab.gd:302, research_bar), `_ready` (:60) gizli seçimi tüketir.
- `RnDTab._refresh()` `rnd_tab.gd:190`: `_compute_structure_key` (:209) değişince `RnDTreeView.rebuild`, yoksa `repaint` · `_on_state_changed` (call_deferred).
- `RnDTreeView.select(id, open_assign)` `scripts/tabs/rnd/rnd_tree_view.gd:334`: karo seçimi, `selection_changed` yayar (:339) · karo tıkı, rnd_tab.
- `EventsTab.select(item_id)` `scripts/tabs/events_tab.gd:77`: öğeyi okuma bölmesinde açar · `Inbox.show` (inbox.gd:31) `call_group(&"inbox", &"select")` ile.
- `EventsTab._refresh()` `events_tab.gd:145`: listeyi `Inbox.items()`'ten kurar; `_queue_refresh` (:139) karede bir kez · `Inbox.connect_changes` (:70).
- `MailPane.populate(item, mode)` `scripts/tabs/events/mail_pane.gd:54`: kipler live/preview/history/rnd · events_tab.gd:163, rnd_history.gd, main.gd:1447.
- `MailPane._choose(idx)` `mail_pane.gd:488`: yalnız live kipte `EventGate.resolve` · seçenek düğmesi/Enter. `open_paper` (:528) → `EventGate.open_paper`.
- `PiyasaTab._build()` `scripts/tabs/piyasa_tab.gd:99`: katalogdan baştan kurar (`_queue_build` :94 sonraki karede) · day_advanced, equity_changed (:82).
- `PersonalTab._build()` `scripts/tabs/personal_tab.gd:70`: sütunları baştan kurar · 9 sinyal (:51).

Statik yardımcılar (dışarıdan çağrılır):
- `MailPane.avatar(from, px)` `mail_pane.gd:834`, `topic_pill(key)` `:857` · sprint_card.gd:270, events_tab.gd:268. `EventsTab.row/band` (static) · rnd_history.gd.

## Sinyaller

Sekmelerin tanımladığı sinyaller (DIZIN.md "Sinyaller" bölümü):
- `fit_changed`: yayan finance_tab:10, hr_tab:22, personal_tab:23, product_tab:12, rnd_tab:28, sales_tab:17, hr_dossier:12 · dinleyen `window_layer.gd:169` (`_place`).
- `close_requested`: yayan `scripts/tabs/hr/hr_dossier.gd:83,132` · dinleyen `window_frame.gd:62`.
- `state_changed`: yayan Atlas/Eğitim/Mesai panelleri (hr_atlas_modal.gd:439,465,483; training_modal.gd:174; work_hours_modal.gd:491) · dinleyen `hr_ui_shared.gd:85`.
- `action(kind, args)`: yayan area_panel:9, overview_view:7, quarter_view:8, sprint_card:15, sprint_panel:8 · dinleyen product_tab.gd:70,77,80, area_panel.gd:166, quarter_view.gd:57, sprint_panel.gd:362.
- `ui_changed(open_area)`: yayan `area_panel.gd:232` · dinleyen `product_tab.gd:71`. `chosen(subtype, name)`: yayan `type_picker.gd:65` · dinleyen `product_tab.gd:101`.
- `started` / `closed`: yayan `rnd_assign_panel.gd:230,232` / `:203` · dinleyen `rnd_detail_panel.gd:76,77`. `selection_changed(node_id)`: yayan `rnd_tree_view.gd:339` · dinleyen `rnd_tab.gd:144`.

Sekmelerin yaydığı EventBus sinyalleri:
- `tab_changed`: product_tab.gd:298-304, sales_tab.gd:295, mail_pane.gd:824,830, hr_atlas_modal.gd:168, sprint_ui_shared.gd:334, rnd_ui_shared.gd:149 · dinleyen window_layer.gd:62.
- `pitch_requested` sales_tab.gd:412 (dinleyen main.gd:4696) · `term_table_requested` hunt_tab.gd:521 (main.gd:4702) · `rnd_node_requested` product_tab.gd:302 (rnd_tab.gd:80).
- `finance_subpage_requested` mail_pane.gd:826 (dinleyen finance_tab.gd:58) · `confirm_requested` hunt_tab.gd:234,479, hr_tab.gd:337, hr_ledger.gd:376-425, hr_atlas_modal.gd:453,472 (main.gd:90).

Sekmelerin dinlediği EventBus sinyalleri (hepsi `_exit_tree`'de ya da düğümle birlikte kopar):
- Ürün `product_tab.gd:111-115`: product_state_changed, build_progress_changed, day_advanced, desk_changed, infra_changed.
- Finans `finance_tab.gd:49-58`: cash/mrr/burn_changed, shutter_changed, runway_recalculated, phase_changed, seed_door_opened, finance_subpage_requested. Özet `finance_ozet_view.gd:60`: ek equity/month_ended/sheet_*/rival_*.
- Yatırım `hunt_tab.gd:45-61`: sheet_*, callback_ready, meeting_day, day_advanced (:47), pitch_finished, seed_*, phase_changed, event_*, TimeManager.hold_changed, mentor_advisory_changed, hour_changed, assignment_changed.
- Ekip `hr_tab.gd:73-85`: character_added/removed, morale_changed, hr_day_processed, customer_assigned, employee_*, productivity_changed, event_*, palette_changed. Dosya `hr_dossier.gd:54-55`: hr_day_processed, character_removed.
- Satış `sales_tab.gd:65-82`: prospect_*, lead_*, deal_*, customer_* (9 sinyal), price_stance_changed, mrr_changed, day_tick_completed, pitch_finished, assignment_changed, event_*, hour_changed.
- Ar-Ge `rnd_tab.gd:69-81`: research_*, node_revealed, hidden_line_unlocked, assignment_changed, messages_changed, event_*, version_shipped, rnd_node_requested, clock_batch_ended.
- Kişisel `personal_tab.gd:51`: equity, phase, hr_day_processed, employee_experience/training, version_shipped, event_*. Piyasa `piyasa_tab.gd:82`: day_advanced, equity_changed.
- Olaylar `events_tab.gd:70` → `Inbox.connect_changes` (`scripts/ui/components/inbox.gd:156-163`, 19 sinyal: desk_changed, event_*, messages_changed, sprint_*, version_shipped ...).

## Durum ve veri

- Sekmeler kayıt şeması tanımlamaz (`scripts/tabs` içinde SaveManager yok); okudukları durum sistemlerde: `GameState.product` (`product_model.gd:139`), `ProductState`, `SprintSystem`, `HRSystem`, `CharacterRegistry`.
- Yerel durum sayfaya aittir ve dil/palet değişiminde kaybolur (WindowLayer yıkıp kurar, `window_layer.gd:66-67,156`): hr_tab `_view`/`_collapsed`, piyasa `_filter`/`_selected`, finance `_current`.
- İstisnalar: `ProductTab._last_view` (static, `product_tab.gd:22`, kayda yazılmaz) ve `GameState.flags["rnd_selected"]` (`rnd_tab.gd:64-65,99`, `_ready`'de tüketilip silinir).
- Diğer bayraklar: `finance_runway_warn_snooze_until_day` (`finance_ozet_view.gd:21,479,499`, ertele 2 hafta); `b2c_paid_tier_open`, `b2c_price`, `b2c_audience_history` yalnız okunur (`sales_tab.gd:261-275`).
- Düzen sabitleri: `WindowLayer.SPECS` `window_layer.gd:38` (Ürün/Piyasa 1424×928, Ekip 1352×928, Finans 1344×720, Satış 1280×760, Ar-Ge 1280×928, Kişisel 1000×928, Olaylar 1240×900, dosya 320×928).
- Tablo sabitleri: `HRLedger.COMPACT_FROM = 12` (`hr_ledger.gd:16`), `TABLE_W` 1302 (:8), `COLUMNS` (:10) ve `COLUMNS_COMPACT` (:13); `HRAssignments.W` ve `W_JOBS` (`hr_assignments.gd:16-17`).
- Boyut belirteçleri `scripts/theme/ui_tokens.gd`: `TABS` :294, `D_H_WIN_CTL` :653, `D_W_AREAS` :696, `D_W_PICKER` :698, `D_W_INVESTORS` :744, `D_H_HUNT_HEAD` :746, `D_H_PERSONAL_BODY` :766, `D_H_RND_HISTORY` :780, `D_AVATAR_*` :672-797.
- Sayfa sabitleri: Olaylar `LIST_W` 400/`ROW_H` 96 (`events_tab.gd:12-16`); Satış `SAT_MID` 50/`HISTORY_WEEKS` 26/`LOG_ROWS` 5 (`sales_tab.gd:20-29`); Piyasa `NEW_WEEKS` 4/`SHARE_FLOOR` 0,1 (`piyasa_tab.gd:15-19`).
- Diğer sabitler: Finans özeti `RUNWAY_WARN_MONTHS` 6/`TX_SHOWN` 8 (`finance_ozet_view.gd:19-22`); `MailPane.ENTER_GUARD_MS` 400/`AVATAR` 40 (`mail_pane.gd:20-21`); Atlas `W_SEARCH` 1440/`W_FILES` 1560 (`hr_atlas_modal.gd:25-26`).
- JSON'u sekmeler doğrudan okumaz (`scripts/tabs` içinde FileAccess/res://data yok); sistemler okur:
  Ar-Ge `data/techtree/rnd_tree.json` (ResearchSeam), Piyasa `data/market/{companies,people}.json` (`market_catalog.gd:18-19`), sprint `data/product/sprint.json`.
- Portre: `UiFactory.make_person_avatar(ad, look, çap, gri)` `scripts/theme/ui_factory.gd:106` oyundaki `PersonBust.texture(look, çap)` bustunu çizer, look boşsa baş harfleri; Frank `make_mentor_avatar` :111 (önceden işlenmiş portre).

## Metin anahtarları

Anahtarlar `localization/strings.csv`'de (sütunlar keys,tr,en); sekmeler `tr("ANAHTAR")` ile okur, statik dosyalar `TranslationServer.translate` ile. Aile önekleri ve okuyan dosyalar:
- `TAB_*` (TAB_PRODUCT, TAB_SALES, TAB_HR, TAB_FINANCE, TAB_PIYASA, TAB_PERSONAL, TAB_RND, TAB_EVENTS): her sekmenin `_init` içindeki `frame_options.title`.
- `PRODUCT_*` / `PROD_*` (PRODUCT_VIEW, PRODUCT_OV, PRODUCT_CARD, PRODUCT_SERVER, PRODUCT_FX, PROD_PATH/NAME/TYPE):
  product_tab, product_model, sprint_panel, sprint_card, sprint_ui_shared, area_panel, quarter_view, type_picker, overview_view.
- `SALES_*`: sales_tab (STEWARD, LOG, STRIP, STANCE, ROUTE, CHIP, B2C, PROMISE, BAND, ACTION), mail_pane (SALES_PER/ACTION/WEEKLY/STEWARD/CLAUSE), hr_assignments (SALES_LOCKED).
- `HR_*` (HR_COL, HR_CARD, HR_ROW, HR_ATLAS 26 kullanım, HR_HOURS, HR_TAB, HR_KPI, HR_STATE, HR_BADGE, HR_ASSIGN, HR_LEGEND, HR_DOSSIER): hr_tab, hr_ledger, hr_assignments, hr_atlas_modal, hr_dossier, hr_ui_shared, personal_tab, events_tab.
- `FIN_*` (FIN_GOAL, FIN_PROFIT, FIN_MARKET, FIN_CAPTABLE, FIN_RANGE, FIN_MENTOR, FIN_SUBTAB, FIN_CASH, FIN_MONTHLY, FIN_RUNWAY): finance_tab, finance_ozet_view, mail_pane; `ANGEL_CAP_*` ve `SEED_CAP_*` özette.
- `HUNT_*` (BADGE, MEETING, WALK, SEC, EST, COUNTER, REQUEST...), `SEED_*` (PITCH, EXPECT, OFFER, DOOR, DONE, BAND), `VC_BLOCK_*`, `VC_EV_*`, `MENTOR_NAME`: yalnız hunt_tab (HUNT_BADGE/CONDITION ayrıca vc_meeting_adapter).
- `RND_*` (LEGEND, VIEW, TREE, WEEKS, REQ, NEED, FAMILY, PLACE, ASSIGN, ABANDON, COMPLETED, NOTE, HISTORY, FROZEN...): rnd_tab, rnd_ui_shared, rnd_detail_panel, rnd_assign_panel, rnd_history, rnd_tree_view, mail_pane.
- `INBOX_*`, `MAIL_*` (KIND, RPT, STAMP, REPLY...), `DESK_PAPER_*`, `GATE_ANSWER_*`, `PAPER_GONE_*`, `SUPPORT_RPT_*`, `MONTH_ROW_*`: events_tab, mail_pane (INBOX_* ayrıca inbox.gd).
- `PIYASA_*` (KPI, RANGE, FILTER, SHARE, LIST, COL, ABOUT, CTX_<yıl>...): yalnız piyasa_tab; bağlam satırı yıla göre `PIYASA_CTX_%d`, yoksa `PIYASA_CTX_2012`.
- `PER_*`, `PERSONAL_MS_*`, `MILESTONE_*`: personal_tab (hedef `PER_GOAL_TRACTION` / `PER_GOAL_SERIES_A`, taş notları `MILESTONE_NOTES` personal_tab.gd:17-20).
- Ortak: `UI_DISMISS`, `UI_CONFIRM`, `NUM_DECIMAL`, `TOPBAR_SHUTTER`, `TOPBAR_GATE`. Anahtar çözülmezse ekranda ham token çıkar (`loc_residue` yakalar).

## Testler

Smoke (tek vaka: `bash tools/smoke_run.sh <vaka>`; tam süit yalnız push öncesi, CLAUDE.md §10, §12). Arayüz doğrulaması esas olarak görsel kabuldür.
- Ekip: `hr_active_filters`, `hr_overload_badge`, `gorevler_has_no_founder`, `menu_has_one_path` (HRLedger/HRPopover sabitlerini ve silinen `W_MENU`, `_place_notch`, `_draw_notch` adlarını sınar, endgame_smoke.gd:14323).
- Ürün: `product_bug_rows_read_the_store`, `fit_star_context`, `capacity_step_immediate`, `sprint_fix_card_clears_its_line`, `sprint_fix_preview_matches_close`,
  `line_impact_names_the_accounts`, `paper_card_trim`, `sprint_follow_card_cannot_be_removed`, `sprint_timeline_matches_play_out` (hepsi ProductModel/SprintUiShared okur).
- Ar-Ge: `rnd_rail_open_with_locked_tree`, `split_bars_name_their_cause` (RnDUiShared). Yatırım: `hunt_offer_lifecycle` (endgame_smoke.gd:2095). Olaylar: `mail_pending_survives_save` (:6542).
- Kabuk: `rail_tabs_match_scene_order` (endgame_smoke.gd:4451), `clock_resumes_only_by_player` (:13700; product_tab ve hunt_tab'ı örnekler), `all_scripts_load`, `loc_product_derived_keys`.
- Görsel (pencereli, PNG `%APPDATA%\Godot\app_userdata\Project Unicorn\`): `--tab-shot=<product|sales|hr|finance|piyasa[:durum]|personal|marketing|rnd|events>` `main.gd:2338`; `--lang=tr|en`, `--palette=cb`, `--shot-size=GxY`.
- Sekmeye özel: `--product-shot=<c1..c5|cards|flow|edge:<ad>|live:<tür>>` (:3704), `--hr-shot=` (:3301), `--finance-shot=` (:3173), `--personal-shot=` (:2378),
  `--rnd-shot=` (:2416), `--inbox-shot=` (:1107), `--sales-shot=` (:1474), `--vc-shot=hunt*` (:3999); hepsi `scripts/main/main.gd`.
- Kontrast ve kit: `--theme-audit=<sekme>`, `--theme-contrast-audit`, `--probe-shot=kit` (`scripts/debug/kit_probe.gd`, Ekip satır ızgarasını örnekler). Ürün fikstürü: `scripts/debug/product_fixtures.gd`.
- Metin kapıları: `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` ve `bash tools/smoke_run.sh loc_csv_integrity`. Godot yolu `$GODOT` (CLAUDE.md §12); komutlar `project-unicorn/`'dan.

## Dikkat

- Karar beklerken (`EventGate.active_id() != ""`) pencereler yalnız okunur: `window_frame.gd:106-119` tıkları yutar,
  `gate_reads` meta'lı denetim geçer. Okuma amaçlı yeni denetime meta ekle; eylem denetimini `disabled` yap (sales_tab/hunt_tab `off`/`_off`).
- Olaylar penceresi kapıdan muaftır (`window_layer.gd:93`, `guarded = false`); cevap yalnız `MailPane._choose` → `EventGate.resolve` ile gider ve yalnız live kipte.
- Gün sınırı: `day_advanced` günlük tiklerden ÖNCE atılır (hr_tab.gd:13, sales_tab.gd:12, rnd_tab.gd:16 uyarır). HR `hr_day_processed`, Satış `day_tick_completed`, Ar-Ge `research_progress_changed` kullanır.
- Ürün ve Piyasa `day_advanced`'e bağlıdır ama yeniden kurmayı ertelerler (`call_deferred`, `process_frame` ONE_SHOT). 
  Yatırım sayfası ise `day_advanced`'e doğrudan bağlıdır (hunt_tab.gd:47); kalan-hafta sayaçları bir tik geriden okunabilir (doğrulanmadı).
- Dil ve palet değişince WindowLayer sayfayı yıkıp yeniden kurar (`window_layer.gd:66-67`); sekmeden ayrıca bağlanma, yoksa çift kurulum olur (rnd_tab.gd:20-21). Yerel durum kaybolur; korunacaksa bayrak ya da static gerekir.
- Ürün sekmesi `fit_height()` ÇEYREK dışında `INF` döner (product_tab.gd:135-139). Sayfa boyunu `SPECS` ve `fit_height` birlikte belirler; yeni sayfada ikisine de bak.
- Statik fonksiyonlarda `tr()` çalışmaz; SprintUiShared, RnDUiShared, MailPane statikleri `TranslationServer.translate` kullanır. Çözülmeyen anahtar kendine döner ve ham token olarak görünür.
- `HBoxContainer` bir çocuğun asgari boyutunu kırpmaz; sabit sütun için hücreyi düz `Control` + `clip_contents` yap
  (hafıza: ekip-rev11-closing-round; kanon `work_hours_modal._pin`). `HRLedger` sütun hücreleri `_span` ile genişlik alır (hr_ledger.gd:66).
- Kalabalık kadroda hiyerarşi: Kadro `COMPACT_FROM = 12` kişide sıkı kipe geçer (hr_ledger.gd:16, hr_tab.gd:255); liste kendi içinde kayar ve pencere `fit_height` ile `SPECS` boyuna kadar uzar. Avatar çapları `D_AVATAR_*` merdivenindedir.
- `MailPane.avatar` yalnız `px <= AVATAR (40)` iken Frank'in önceden işlenmiş portresini kullanır (mail_pane.gd:836-837); daha büyük çapta look/mono kutuya düşer.
- Sekmeler arası çapraz çağrı kırılgan: `product_tab._act("hire")` (product_tab.gd:304-305) ve `SprintUiShared.open_product_area` (sprint_ui_shared.gd:334-335) `tab_changed` senkron kurduğu varsayımıyla sayfa gövdesine metot çağırır.
- `GameState.flags["rnd_selected"]` kayıtlı `flags` içinde durur (rnd_tab.gd:99); pencere kapanıp oyun kaydedilirse bayat seçim kayda sızabilir (`_ready` onu bir sonraki açılışta siler).
- `SprintUiShared` ve `HRUiShared` sekme dışında da çağrılır (modals, ui/meeting, ui/office, ui/components: sırasıyla 11 ve 14 dosya); imza değişikliği bu dosyaları kırar. `FinanceOzetView` `cash_curve.gd` ve Kişisel'den çağrılır.
- Karar sonrası `_act` + `_refresh` (hunt_tab.gd:536) sinyali olmayan eylemler için elle yeniden çizer; yeni Yatırım eylemi sinyal yaymıyorsa aynı deseni kullan.
- Chrome kuralı ve token yasası: ham `Color(...)`/ham boyut yok, `D_*` token'ları (CLAUDE.md §7); koyu pencere `menajer_theme`'i `frame_options.title` ile alır (window_frame.gd:36-38).
- `product_tab.gd` ve `hunt_tab.gd` kirli ağaçta olabilir (`git status`: product_tab Oct 22 21:43); başka bir oturum yazıyorsa satır numaraları kayar, `uret.py` ile dizini yenile.

## Bir değişiklik yaparken

- Yeni sekme ya da pencere boyu: `UiTokens.TABS` (ui_tokens.gd:294), `WindowLayer.TAB_SCENES` (window_layer.gd:13) ve `SPECS` (:38), `scenes/tabs/<Ad>Tab.tscn`, `TAB_<AD>` anahtarı, `left_tabs.gd`, smoke `rail_tabs_match_scene_order`.
- Sprint kartı alanı ya da düğmesi: `ProductModel` (sözleşme, `BUTTONS` product_model.gd:126; `follow` kartı Kaldır almaz, `_card`) + `SprintCard.setup`
  + `scripts/debug/product_fixtures.gd` (fikstür aynı alanı taşımalı) + `ProductTab._act` + ilgili `PRODUCT_*` anahtarları.
- Satır menüsü eylemi (Ekip): `HRLedger._action_specs`/`run_action` (hr_ledger.gd:283,356), `hr_dossier.gd` (aynı kapı), `HRActions` sistemi ve smoke `menu_has_one_path`.
- Kadro sütunu: `HRLedger.COLUMNS`/`COLUMNS_COMPACT`/`TABLE_W` (hr_ledger.gd:8-16), `HRAssignments.W`, `scripts/debug/kit_probe.gd` `W`, Ekip pencere eni `SPECS["hr"]`.
- Yeni bir sistem sinyali sayfayı etkiliyorsa: ilgili sekmenin `_signals` listesine (tablo yukarıda) ekle, `_exit_tree`'de kopar, karar kapısı etkisi varsa `event_*` üçlüsünü de dinle.
- Metin ekleme: `localization/strings.csv`'ye tr+en birlikte (bayt-splice, strings-csv-surgery notu), çevirisiz anahtar `loc_residue`'u düşürür.
- Olaylar okuma bölmesi: `mail_pane.gd` kipleri `Inbox.items()` öğe alanlarına bağlı (inbox.gd:42); öğe alanı eklersen `Inbox`, `MailPane`, `Ar-Ge geçmişi` (`rnd_history.gd`) ve `--inbox-shot` durumlarına bak.
- Ar-Ge ağacı karosu ya da düğüm durumu: `RnDUiShared.tile_state` (rnd_ui_shared.gd:182), `RnDTab._compute_structure_key` (rnd_tab.gd:209; yeni durum anahtara girmezse yerinde boyama yeniden kurmaz), `research_bar_model.gd`.
- Yatırım sayfası eylemi: `VCPitchSystem`/`SeedRoundSystem` çağrısı + `HuntTab._act` (hunt_tab.gd:536) + `--vc-shot=hunt*` ile görsel kabul + `hunt_offer_lifecycle`.

## HARITA'da bayat

- `docs/HARITA.md:158` Ürün DESTEK maddesi `MailPane._support_report` der; `MailPane` adlı sınıf yok, `scripts/tabs/events/mail_pane.gd` class_name taşımaz, fonksiyon `mail_pane.gd:688`'dedir.
- `docs/HARITA.md:141` Ürün "Yer" satırı `scripts/tabs/product/overview_view.gd`'yi saymaz (dosya var, 95 satır; satır 155 GENEL BAKIŞ'ı anlatır): bayat değil, eksik kayıt.
