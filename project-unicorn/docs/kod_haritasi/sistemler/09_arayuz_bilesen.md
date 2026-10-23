# Arayüz bileşenleri, tema, pencereler, menü ve ilk kullanım

Dizin sha: f3113fa4 (DIZIN.md başlığı; yollar:satırlar o dizinin kirli ağaç halinden okundu). Yeniden üret: `python -I tools/kod_haritasi/uret.py`.
Kapsam: scripts/ui (office hariç), scripts/theme, scripts/modals, scripts/menu, scripts/onboarding, metin anahtarı okuma deseni. Ofis 3B: 06_ofis.md. Kabuk kökü `main.gd`/`game_shell.gd`: 01_cekirdek.md.

Ne yapar: Oyunun 2B kabuğunu (üst bar, sol ray, pencere katmanı, haber şeridi, yüzen kartlar, toast), modalları, ana menüyü, ilk kullanım akışını ve görüşme panelini çizer.
Her yüzey oyun durumunu yazmaz, sistemlerden okur ve olaylara EventBus ile bağlanır. Renk, boyut ve yüz `UiTokens`tan, Control üretimi `UiFactory`den gelir; `build_theme.gd` iki .tres temayı üretir.
Oyuncu metni `tr(ANAHTAR)` ile `localization/strings.csv`den okunur; ayrı bir Control ağacı kuran statik yardımcılar `TranslationServer.translate` kullanır.

## Dosyalar
- `scripts/theme/ui_tokens.gd` (972): `UiTokens`; tüm renkler, SIZE_* merdiveni, krem palet, koyu dil `D_*`, `TABS`, `THEME_STAMP`, renk körü anahtarı ve `D_` yardımcıları
- `scripts/theme/ui_factory.gd` (533): `UiFactory`; statik Control üreticileri (label, pill, badge, kart, avatar, `D_tag`, `D_kpi`, `D_seg_tabs`, `D_said`, `D_stars`) hep tema varyasyonu adlarıyla
- `scripts/theme/build_theme.gd` (1521): `-s` betiği; UiTokens'tan `themes/master_theme.tres` (krem) ve `themes/menajer_theme.tres` (koyu) üretir, FontVariation sarmalarını kurar (koyu yüzler Archivo'nun değişken yüzü, yedek Plex)
- `scripts/theme/theme_check.gd` (270): tema denetçisi (eksik öğe, içerik payı, WCAG kontrastı) ve koyu temanın `contrast_audit` kapısı
- `scripts/ui/components/top_bar.gd` (458): üst bar; iki satırlık metrik ızgarası, gün/saat/hafta çubuğu, hız tuşları, Sıradaki ve karar kapısı yuvası
- `scripts/ui/components/left_tabs.gd` (326): sol ray; `UiTokens.TABS` ile sahne düğmeleri, kilit, rozet sayaçları, simge kipi
- `scripts/ui/components/window_layer.gd` (247): `CenterViewport`un betiği; bir birincil ve bir ayrıntı pencereyi ofisin üstünde sabit yuvalarda açar
- `scripts/ui/components/window_frame.gd` (119): pencere kabuğu (`WindowPanel`, kapatma glifi, ortak başlık bandı, karar beklerken salt okunur şerit)
- `scripts/ui/components/gate_strip.gd` (53): karar beklerken pencerenin üstündeki "geri dön" şeridi
- `scripts/ui/components/inbox.gd` (570): gelen kutusunun tek görünüm modeli (statik, durumsuz); Olaylar penceresi, bildirim yığını, kapı yuvası ve rozet bunu okur
- `scripts/ui/components/toast.gd` (94): kabuğun tek toast'ı (grup `toast`); son ekranda raya gömülü ve eylemli sürüm
- `scripts/ui/components/news_ticker.gd` (237): alt haber şeridi; gerçek zamanda sola kayar, oyun duraklasa da akar, aç/kapa hücresi
- `scripts/ui/components/build_hud_panel.gd` (108): sağ üstteki yüzen kart yığınının taşıyıcısı; görünürlük, sürükleme, pencere altında gizlenme
- `scripts/ui/components/build_bar.gd` (168) + `build_bar_model.gd` (46): DESTEK kartı ve türetilmiş modeli (yayındaki ürün, açık hata sayısı)
- `scripts/ui/components/research_bar.gd` (194) + `research_bar_model.gd` (86): ARAŞTIRMA kartı ve modeli (Ar-Ge GDD §5.6)
- `scripts/ui/components/bar_kit.gd` (37): iki yüzen kartın ortak parçaları (glif, satır, kısalan yazı); `class_name` yok, preload edilir
- `scripts/ui/components/cash_curve.gd` (272): `CashCurve`; nakit eğrisi, projeksiyon ve hover; yalnız piksel geometrisi, ekonomi hesaplamaz
- `scripts/ui/components/logo_emblem.gd` (188): `LogoEmblem`; çizilen şirket amblemi (6 şekil, 3 stil), `candidates` ile addan 12 aday
- `scripts/ui/components/segment_bar.gd` (39): `SegmentBar`; onboarding beceri cetveli · `radial_dial.gd` (95): `RadialDial`; term sheet itme kadranı
- `scripts/ui/components/investor_appetite_ui.gd` (40): `InvestorAppetiteUi`; Seri A kapısının tek oyuncuya görünen okuması (etiket + tek satır)
- `scripts/ui/components/dialogue_portrait_card.gd` (28): `DialoguePortraitCard`; 4:5 portre kartı; kodda ve sahnede kullanan yok (bkz. HARITA'da bayat)
- `scripts/ui/meeting/meeting_panel.gd` (805): `MeetingPanel`; satış ve VC görüşmesinin dok paneli (baş, dökümcük, güverte), adaptörün adımlarını oynatır
- `scripts/ui/meeting/meeting_panel_option.gd` (125): güvertedeki seçenek kartı (tuş, etiket, zar, kilit) · `meeting_ruler.gd` (122): `MeetingRuler`; fiyat cetveli
- `scripts/ui/meeting/sales_meeting_adapter.gd` (320) ve `vc_meeting_adapter.gd` (200): sistemin görünümünü panelin "adım" sözlüğüne çevirir (RefCounted)
- `scripts/ui/menu_backdrop.gd` (138): menü ve onboarding'in arkasındaki 3B yer (ofis sahnesi, kişisiz, sabit saatte); `live_ready` sinyali
- `scripts/menu/main_menu.gd` (100): ana menü (Devam, Yeni oyun, Yükle, Ayarlar, Jenerik, Çık) tek odak zinciri · `continue_card.gd` (19): Devam kartı
- `scripts/menu/godot_card.gd` (35): "Godot ile yapıldı" kartı · `credits.gd` (60): Jenerik (`data/credits.json`) · `licenses.gd` (80): düz lisans metni
- `scripts/modals/confirm_modal.gd` (65): genel onay · `hr_action_modal.gd` (237): zam/terfi/izin/çıkarma onayı (kaydırıcılı) · `system_menu_modal.gd` (106): ESC menüsü
- `scripts/modals/settings_modal.gd` (480): altı bölümlü canlı Ayarlar · `save_load_modal.gd` (262): Kaydet/Yükle, iki kip · `ending_scene.gd` (563): `EndingScene`; Ekonomi Postası ve dönüm noktası kâğıdı
- `scripts/modals/term_sheet_table_scene.gd` (437): `TermSheetTableScene`; tam ekran term sheet masası, sistemin `view_state`ini boyar
- `scripts/modals/training_modal.gd` (175) ve `work_hours_modal.gd` (492): HR paneli modalları; `scripts/tabs/hr/hr_panel.gd`i genişletir, PanelLayer'a `HRUiShared.mount_panel_modal` ile takılır
- `scripts/onboarding/onboarding_flow.gd` (213): ilk kullanım akışı, `draft` sahibi · `first_week_doc.gd` (235): yandaki "ilk hafta" belgesi
- `scripts/onboarding/steps/step_base.gd` (118): `OnboardingStep` sözleşmesi · `character_step.gd` (111) · `origin_traits_step.gd` (332) · `company_step.gd` (105)
- Sahneler: `scenes/ui/components/` (TopBar, LeftTabs, NewsTicker, BuildBar, BuildHUDPanel, ResearchBar, DialoguePortraitCard, `avatar_bust.gdshader`), `scenes/menu/` (5 tscn, `menu_grade.gdshader`)
- Sahneler (devam): `scenes/modals/` (10 tscn; HRAtlasModal'ın betiği `scripts/tabs/hr/hr_atlas_modal.gd`), `scenes/onboarding/` (OnboardingFlow, 3 adım), `scenes/debug/ThemeProbe.tscn`
- Veri: `themes/master_theme.tres`, `themes/menajer_theme.tres` (üretilmiş, elle düzenlenmez), `localization/strings.csv`, `data/credits.json`; debug: `scripts/debug/kit_probe.gd`, `glyph_audit.gd`
- Dışarıda ama ayrılmaz: portre ve kişi büstü `scripts/ui/office/person_bust.gd` (`PersonBust`), kurucu/Frank portre yolları `scripts/systems/founder_constants.gd`, ekran ölçüsü `scripts/systems/display_settings.gd`

## Giriş noktaları
- `Main._mount_godot_card()` `scripts/main/main.gd:114`: açılışta bir kez, boot splash ile menü arasında · `_ready` (main.gd) sonunda; kart `finished` verince `_mount_menu()` `main.gd:126`
- `Main._mount_menu()` `main.gd:126`: menüyü kurar, `SaveManager.end_run()` der · açılıştan, `_return_to_menu()` `main.gd:145` ve reddedilen yüklemeden
- `Main._mount_flow()` `main.gd:151`: Yeni oyun'da `OnboardingFlow` kurar, `completed` → `_swap_to_shell_and_modal` `main.gd:4419` · `main_menu.gd` `new_game_requested`
- `Main._modal_layer()` `main.gd:4475`: modalların takıldığı katman (`GameShell/ModalLayer` ya da menünün kendi ModalLayer'ı) · bütün modal yolları
- `Main._on_settings_requested()` `main.gd:4801`: hızı 0 yapar, `SettingsModal` takar; kurucu yolculuktayken toast söyler · `EventBus.settings_requested` (bağlantı `main.gd:88`)
- `Main._on_confirm_requested(config)` `main.gd:4821`: `config.modal == "hr_action"` ise `HRActionModal`, yoksa `ConfirmModal`; sonra `populate(config)` · `EventBus.confirm_requested` (`main.gd:90`)
- `Main._on_system_menu_requested()` `main.gd:4849`: ESC menüsü · `EventBus.system_menu_requested` (`main.gd:4469`; yayan `game_shell.gd:106`); X ve Alt+F4 `_notification` `main.gd:4869`
- `Main._on_save_load_requested(mode)` `main.gd:4884`: `SaveLoadModal` takar, add_child sonrası `populate(mode)` · `EventBus.save_load_requested` (`main.gd:89`)
- `Main._on_run_ended()` `main.gd:4993` ve `_on_milestone_reached()` `main.gd:5014`: `EndingScene` takar, `populate(data)` · `EventBus.run_ended` ve `milestone_reached`
- `Main._on_term_table_requested()` `main.gd:5056`: `TermSheetTableScene` takar; `closed` → `_close_term_table()` `main.gd:5080` · `EventBus.term_table_requested`
- `Main._open_meeting(adapter, side, place)` `main.gd:4782`: yolculuktan sonra `MeetingPanel` takar, `open(adapter, cast)`; `_close_meeting` `main.gd:4793` · `_open_sales_meeting` `:4769`, `_on_meeting_scene_requested` `:4759`
- `HRUiShared.mount_panel_modal()` `scripts/tabs/hr/hr_ui_shared.gd:78`: Eğitim ve Çalışma Saatleri modallarını `PanelLayer`a takar, `populate(args)` · `hr_ledger.gd:368`, `personal_tab.gd:96`, `hr_tab.gd:386`
- `WindowLayer.open_primary(tab_id)` `window_layer.gd:75`: sekme penceresini kurar, öncekini `on_page_closing` ile bırakır · `EventBus.tab_changed` (bağlantı `window_layer.gd:62`)
- `WindowLayer.open_detail(kind, payload)` `window_layer.gd:100`: ayrıntı penceresi (`DETAILS`: `hr_dossier`) · grup `window_layer` üzerinden ofis ve sayfalar
- `WindowLayer.close_top()` `window_layer.gd:114`: Esc'in kapattığı en üst pencere · `GameShell._input` `game_shell.gd:100`
- `WindowLayer.set_veiled()` `window_layer.gd:130` ve `set_under()` `:177` ve `panel_rect()` `:186`: görüşme yolculuğunda pencereleri gizler, PanelLayer paneli altındaki pencereyi kısar · `main.gd` yolculuğu, HR panelleri
- `WindowFrame._init(body, on_close, guarded)` `window_frame.gd:33`: sayfanın `frame_options` sözlüğünü okur (variation, pad, owns_close, theme, title, kpi) · `window_layer.gd:93,103`
- `TopBar._ready()` `top_bar.gd:98` ve `_queue_refresh()` `:154` → `_refresh()` `:171`: metrik, gün, kapı ve saat bloklarını boyar · EventBus sinyalleri ve TimeManager (aşağıda)
- `TopBar.show_meeting(phase, place)` `top_bar.gd:162` ve `blink_held()` `:348`: yolculuk/masa/ev satırı ve tutuş yanıp sönmesi · `main.gd` (grup `top_bar`) ve `game_shell.gd`
- `LeftTabs._ready()` `left_tabs.gd:62`, `_paint()` `:138`, `_is_locked()` `:258`, `set_bottom_clearance()` `:271`: ray satırı durumları ve rozetleri · `game_shell.gd` düzeni, EventBus sinyalleri
- `Toast.show_toast(head, sub, glyph, tone)` `toast.gd:75` ve `set_action()` `:58`: toast gösterir · `get_tree().call_group(&"toast", &"show_toast", ...)`: main.gd, game_shell.gd:130, ending_scene, mail_pane, office_hud
- `Inbox.show(item_id)` `inbox.gd:31`, `items()` `:42`, `desk()` `:76`, `counts()` `:167`, `mark_read()` `:191`: gelen kutusu · TopBar `top_bar.gd:133`, WindowFrame, `events_tab.gd`, `mail_pane.gd`, ofis bildirim yığını
- `NewsTicker.set_open(value)` `news_ticker.gd:97`: şeridi açar/kapar, `Settings.ticker_open` yazar · aç/kapa hücresi ve Ayarlar (`settings_modal.gd:281`)
- `BuildHUDPanel.set_map_open()` `build_hud_panel.gd:59` ve `set_window_cover()` `:65`: grup `office_overlays`; kartlar `fingerprint()` boşsa yığın gizli · `office_view.gd`, `window_layer.gd:237`
- `MeetingPanel.open(adapter, cast)` `meeting_panel.gd:125`, `pick(id)` `:146`, `proceed()` `:169`, sinyal `closed` `:19`: panel oynatır, seçimi adaptöre iletir · `main.gd:4782`
- `SalesMeetingAdapter._init(prospect_id)` `sales_meeting_adapter.gd:51`, `start` `:56`, `pick` `:81`, `select` `:102`, `proceed` `:109`, `end_sitting` `:117` · `MeetingPanel` ve `main.gd:4769`
- `VcMeetingAdapter._init(view_state)` `vc_meeting_adapter.gd:40`, `start` `:49`, `pick` `:61`, `proceed` `:91`, `withdraw` `:98`, `end_sitting` `:103` · `MeetingPanel` ve `main.gd:4759`
- `OnboardingFlow._commit()` `onboarding_flow.gd:192`: perdeyi çizer, sahneyi durdurur, `GameState.initialize_run(draft)` `game_state.gd:769`, `completed` · `_on_next()` `onboarding_flow.gd:155` son adımda
- `OnboardingStep` sözleşmesi `step_base.gd`: `prefill` `:23`, `invalid_reason` `:28`, `is_valid` `:32`, `collect_payload` `:36`, `roll` `:40` · yalnız `onboarding_flow.gd:92` (`_mount_step`) çağırır
- `MenuBackdrop.start(office_id, minute, figure)` `menu_backdrop.gd:40`, `stop()` `:65`, `set_figure()` `:75` · `main_menu.gd` (MenuBackdrop sahnede), `onboarding_flow.gd:70`, `main.gd:138`
- `UiFactory.make_person_avatar(name, look, px, grey)` `ui_factory.gd:106` → `PersonBust.texture(look, px)` `person_bust.gd:38` · meeting_panel.gd:576, term_sheet_table_scene.gd:110,224
- `UiFactory.make_mentor_avatar(px)` `ui_factory.gd:111`: Frank'in önceden render edilmiş portresi · meeting_panel.gd:428, term_sheet_table_scene.gd:245
- `UiTokens.set_colorblind(on)` `ui_tokens.gd:317`, `D_variation(name)` `:971`: palet anahtarı; çağıran `Settings`/`settings_modal.gd:249`, sonra `EventBus.palette_changed`
- `BuildTheme._initialize()` `build_theme.gd:42` → `_menajer(master)` `:421`: iki temayı yazar · elle: `godot --headless --path . -s res://scripts/theme/build_theme.gd`
- `ThemeCheck.contrast_audit(th, T)` `theme_check.gd:156`: koyu temanın kontrast kapısı · `main.gd:235` (`--theme-contrast-audit`); `missing()` `theme_check.gd:44`, `unset_margins()` `:71`, `contrast()` `:83`

## Sinyaller
- `dismissed`: modallar yayar (tanım `confirm_modal.gd:13`, `hr_action_modal.gd:16`, `save_load_modal.gd:14`, `settings_modal.gd:16`, `system_menu_modal.gd:18`, `credits.gd:6`, `licenses.gd:8`) · `main.gd:4813,4838,4857,4891` ve menü
- `confirmed` / `alt_selected`: `confirm_modal.gd:11,12`, `hr_action_modal.gd:15` · `main.gd:4833,4837` (`config.on_confirm`, `on_alt`), `onboarding_flow.gd:177` (iptal onayı)
- `save_requested(slot_id)` / `load_requested(slot_id)`: `save_load_modal.gd:15,16`; `main_menu.gd:8` yayar · `main.gd:4892,4893` ve `main.gd:133` (`_load_slot` `:4950`)
- `main_menu_requested` / `exit_save_requested`: `system_menu_modal.gd:19,20` (yayın `:63`, `:93`); `ending_scene.gd:41` · `main.gd:4858,4859,5026`
- `continue_requested`: `ending_scene.gd:40` (yayın `:445`) · `main.gd:5025` (`_on_milestone_continue`)
- `closed`: `meeting_panel.gd:19`, `term_sheet_table_scene.gd:17` · `main.gd:4786` (`_close_meeting`), `main.gd:5073` (`_close_term_table`)
- `new_game_requested`: `main_menu.gd:7` (yayın `:54`) · `main.gd:130` · `finished`: `godot_card.gd:6` (yayın `:35`) · `main.gd:118` · `back`: `licenses.gd:7` · `credits.gd:44`
- `completed` / `cancelled`: `onboarding_flow.gd:11,12` (yayın `:203`, `:172,177`) · `main.gd:154,155` · `live_ready`: `menu_backdrop.gd:9` (yayın `:138`) · `main.gd:2867`, `onboarding_flow.gd:70`
- `changed`: `step_base.gd:15` · `onboarding_flow.gd:_mount_step` · `picked(field, value)`: `first_week_doc.gd:7` · `onboarding_flow.gd:_ready` (taslağı yazar, `_refresh`)
- `open_changed(open)`: `news_ticker.gd:53` (yayın `:108`) · `game_shell.gd:30` (`_lay_ticker`) · `spin_finished`: `radial_dial.gd:9` (yayın `:70`) · `term_sheet_table_scene.gd:72`
- `clicked` / `hovered(on)`: `meeting_panel_option.gd:9,10` · `meeting_panel.gd:678,679` · `changed(value)`: `meeting_ruler.gd:13` · `meeting_panel.gd:511`
- EventBus'tan dinlenenler: `tab_changed` (`window_layer.gd:62`, `left_tabs.gd:105`, `research_bar.gd:63`), `language_changed` (`window_layer.gd:67`, `top_bar.gd:110`, `left_tabs.gd:129`, `news_ticker.gd:79`, `system_menu_modal.gd:29`)
- EventBus'tan dinlenenler (devam): `palette_changed` (`window_layer.gd:66`, `top_bar.gd:111`, `left_tabs.gd:130`, `news_ticker.gd:81`)
- `event_triggered`/`event_resolved`/`event_set_aside`/`desk_changed` dinleyenler: `top_bar.gd:113-116`, `left_tabs.gd` (Olaylar rozeti), `window_frame.gd:56-58` (salt okunur şerit)
- TopBar saat: `TimeManager.speed_changed` ve `hold_changed` (`top_bar.gd:120-122`); hız tuşları `EventBus.speed_change_requested` yayar (`top_bar.gd:129`)
- UI'nin yaydığı EventBus sinyalleri: `tab_changed` (`left_tabs.gd` `_on_tab_button` `:235`, `window_frame.gd` kapatma), `settings_requested` (`left_tabs.gd:95`, `main_menu.gd:56`, `system_menu_modal.gd:39`)
- UI'nin yaydığı (devam): `confirm_requested` (`settings_modal.gd:269`, `save_load_modal.gd:212`, `system_menu_modal.gd:78`, `term_sheet_table_scene.gd:388`), `save_load_requested`, `palette_changed` (`settings_modal.gd:251,282`)

## Durum ve veri
- UI kendi başına oyun durumu tutmaz: `Inbox`, `BuildBarModel`, `ResearchBarModel` her okumada sistemlerden türetir (`derive()` + `fingerprint()` `build_bar_model.gd:26,45`, `research_bar_model.gd:42,83`)
- Onboarding `draft` sözlüğü `onboarding_flow.gd:36`: founder_name, portrait_id, origin_id, trait_ids, skill_alloc, company_name, logo, logo_reroll, difficulty, frank_guided; tek doğru kaynak, `initialize_run`a kadar GameState'e yazılmaz
- `GameState`ten okunanlar: `company_name`, `get_date_dict`, `day`, `phase`, `messages`, `desk_arrivals`, `founder_portrait`, `logo` (ContinueCard `row.meta.logo`), `vc_states`, `active_sheets` (en çok `top_bar.gd`, `inbox.gd`)
- Kalıcı kullanıcı ayarları `user://settings.json` (`Settings.DEFAULTS` `settings.gd:24`): `window_mode`, `ui_scale`, `colorblind_palette`, `ticker_open`, `master_volume`, `music_*`, `sfx_volume`, `pause_unfocused`, `language`
- `runs_finished` profil sayacı `Settings` anahtarı, `main.gd:4996`'da artar; Onboarding Zor kipi açılışını buradan okur (`first_week_doc.gd:15`)
- Tema sürümü: `UiTokens.THEME_STAMP := 38` `ui_tokens.gd:44`; .tres'in gömülü `UiTokensStamp.stamp` sabiti ile `main.gd:99-100` karşılaştırılır (debug uyarısı)
- Tema yolu: `UiTokens.MENAJER_THEME` `ui_tokens.gd:450`; proje teması `project.godot` `theme/custom` = `master_theme.tres`; Menajer teması taşınan her alt ağacın köküne ve her CanvasLayer köküne elle atanır
- Boyut merdiveni: `SIZE_MICRO 9 … SIZE_DISPLAY 22` `ui_tokens.gd:196-203`, editorial `SIZE_ED_*` `:208-212`, koyu `D_FS_12 … D_FS_40` `:603-614`; term sheet sütunu `D_STAGE` `:816`
- `UiTokens.TABS` `ui_tokens.gd:294`: id sırası = `LeftTabs.tscn` düğme sırası; `lock: "ea"` bu yapıda kilitli sekme; sekme başlığı anahtarı `TAB_` + ID büyük harf (`left_tabs.gd:145`, `window_layer.gd:246`)
- Pencere boyları `WindowLayer.SPECS` `window_layer.gd:38` (1920×1080 tabanı), `EDGE 24` `:43`; sekme sahneleri `TAB_SCENES` `:13`; ekran eşiği `DisplaySettings.COMPACT_SHELL_BELOW 1680` `display_settings.gd:72`
- Kabuk ölçüleri: TopBar 64 px (`TopBar.tscn` custom_minimum_size), NewsTicker 40 px (`NewsTicker.tscn`), katmanlar PanelLayer 9, ModalLayer 10, ToastLayer 11 (`GameShell.tscn`)
- Önemli sabitler: `Toast` IN 0,2 / HOLD 2,4 / OUT 0,2 sn (`toast.gd:11-13`); `MeetingPanel.DOCK_SHARE 0.34` `meeting_panel.gd:31`; `MainMenu.MENU_OFFICE "city"`, `MENU_MINUTE 1170` `main_menu.gd:13,14`; `GODOT_CARD_S 1.5` `godot_card.gd:8`
- JSON: `data/credits.json` (Jenerik), `themes/*.tres` (üretilmiş). Lisans gövdeleri çalışma anında motordan okunur (`licenses.gd`), çevrilmez

## Metin anahtarları
- Okuma deseni: `tr("ANAHTAR")` (Object'lerde), birleşik metin `tr(KEY).format({ad: değer})` yalnız adlı yer tutucu
- Statik fonksiyonda `TranslationServer.translate(KEY)` (`inbox.gd`, `investor_appetite_ui.gd`, `ui_tokens.gd`, `ui_factory.gd`); `_t()` yardımcısı bu sistemde yok, `Fmt._t` `scripts/util/fmt.gd:17`
- Yükleme: `Localization._ready()` `localization.gd:18` CSV'yi (`keys,tr,en`) `_load_csv_translations` `:91` ile ayrıştırır; `set_language()` `:82` `EventBus.language_changed` yayar
- Büyük harf: `Fmt.upper()` (Türkçe İ kuralı, `LOANWORD_STEMS`), `UiTokens.tr_upper` eski ad `ui_tokens.gd:395`; para/yüzde/tarih `Fmt.*`; `Localization.pick(tr, en)` `localization.gd:76` yalnız olay JSON'u için
- Sahne metni anahtarın kendisidir; sekme adı `TAB_*`, yerleşik ailelerin sayısı DIZIN.md "Metin anahtarı aileleri"nde. Burada okunan aile önekleri (kod literallerinden sayıldı):
- `SET_*`, `LANG_*`, `SETTINGS_*` → `settings_modal.gd` · `SYS_*` → `system_menu_modal.gd` · `SAVE_*`, `GATE_*`, `MENU_*` → `save_load_modal.gd`, `continue_card.gd` · `CREDITS_*`, `LIC_*` → `credits.gd`, `licenses.gd`
- `ONB_*` (+ dinamik `ONB_SKILL_WORD_*`, `ONB_EFFECT_*`, `LOCK_*`) → `origin_traits_step.gd`, `first_week_doc.gd`, `onboarding_flow.gd`, `company_step.gd`, `character_step.gd`, `step_base.gd`
- `MEETING_*`, `NEG_*` → `sales_meeting_adapter.gd`, `meeting_panel.gd`, `vc_meeting_adapter.gd` · `TERM_*` → `term_sheet_table_scene.gd` · `INV_*` → `investor_appetite_ui.gd` · `ENDING_*` → `ending_scene.gd`
- `HR_*` (çalışma saati, eğitim) → `work_hours_modal.gd`, `training_modal.gd` · `TOPBAR_*`, `FIN_*` → `top_bar.gd`, `cash_curve.gd` · `TICKER_*` → `news_ticker.gd` · `TAB_*`, `WIN_*` → `left_tabs.gd`, `window_*.gd`
- `DESK_*`, `INBOX_*`, `MAIL_*`, `SALES_*`, `EVENT_*`, `WORLD_*`, `MENTOR_*`, `GOAL_*`, `CHEQUE_*` → `inbox.gd` · `BUILD_*`, `PRODUCT_*`, `RND_*`, `PROD_*` → `build_bar.gd`, `research_bar.gd` · `UI_*` → ortak modal düğmeleri
- Kurallar: CLAUDE.md §5 (önce İngilizce, tire yok, `static func` içinde `tr()` yok) ve `docs/design/localization_glossary.md`; strings.csv tek tırnak konvansiyonu yok, bayt-aralığı ile düzenlenir (hafıza: strings-csv-surgery)

## Testler
- Smoke (`bash tools/smoke_run.sh <vaka>`, kaynak `scripts/debug/endgame_smoke.gd` eşleme tablosu): `rail_tabs_match_scene_order` `:411`, `topbar_speed_cluster_three_rungs` `:403`, `menu_state_machine` `:303` (ana menü)
  ↳ `menu_has_one_path` `:200` ana menüyü değil Ekip satır menüsünü sınar (08_sekmeler.md)
- Smoke (devam): `onboarding_pages_contract` `:182`, `ui_scale_ladder_fits_settings` `:314`, `loc_language_switch` `:366`, `loc_csv_integrity` `:316`, `ending_paper_modes_on_screen` `:396`, `star_ruler_contract` `:418`
- Smoke (devam): `work_hours_three_scopes` `:426`, `work_hours_draft_commits` `:427`, `hr_training_locks` `:188`, `inbox_no_night_stamp` `:362`, `build_percent_single_source`, `rnd_rail_open_with_locked_tree` `:461`, `all_scripts_load`
- Kapılar: `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` (oyuncu metni kaçakları), `-s res://scripts/theme/theme_check.gd [--theme=<yol>]`, `--theme-contrast-audit`, `-s res://scripts/debug/glyph_audit.gd`
- Görsel kabul (pencereli, Godot MCP; `main.gd`): `--tab-shot` `:2338`, `--modal-shot` `:2539`, `--menu-shot` `:2691`, `--onboard-shot` `:2858`, `--meeting-shot` `:4255`, `--clock-shot` `:2196`
- Görsel kabul (devam): `--theme-audit=<sekme|modal:<tür>|onboard:<adım>>` `:2908`, `--vc-shot=<tür>[:shell]` `:3999`, `--negotiation-shot` `:4351`, `--invite-shot` `:2124`, `--inbox-shot` `:1107`
- Görsel kabul (devam): `--ending-shot` `:3602`, `--probe-shot[=menajer]` `:2927` (ThemeProbe), `--backdrop-probe` `:2788`, `--render-probe` `:389`
- Ortak bayraklar: `--lang=tr|en`, `--shot-size=GxY`, `--shot-scale=1.25`, `--palette=cb` (`main.gd:597`). Kayıt yazan `--modal-shot=save*|load*` ve `--menu-shot` ayrı `APPDATA` ile koşar (CLAUDE.md §12)
- Debug seam'leri (argsız, MCP): `_dbg_menu_digest()` `main.gd:5129`, `_dbg_close_request()` `:5106`, `_dbg_finish_run()` `:5124`, `_dbg_onb_random_x20()` `:5111`; `kit_probe.gd` `--probe-shot=kit` koyu kitin durumlarını çizer
- CLAUDE.md §10: arayüz doğrulaması smoke'la değil görsel kabulle yapılır; yeni UI smoke vakası yazılmaz

## Dikkat
- Yeni `class_name` paylaşılan checkout'ta başka oturumların headless koşusunu düşürür: bu sistemde `window_frame`, `gate_strip`, `inbox`, `toast`, `bar_kit`, `build_bar_model` yol ile `preload` edilir (dosya başlıklarında yazılı)
- `static func` içinde `tr()` derlenir ama çalışırken ölür (CLAUDE.md §5, `loc_residue`); `Inbox`, `InvestorAppetiteUi`, `UiTokens` `TranslationServer.translate` kullanır
- Modal yaşam döngüsü: `add_child` SONRA `populate()` (`@onready` ancak o zaman dolu; `main.gd:4840,4895,5006,5028`), kök `process_mode = 3` (ALWAYS, duraklamada da tıklanır), ESC `_unhandled_input` ile kapatır
- Modal tekilliği `main.gd` alanlarında (`_confirm_modal`, `_settings_modal`, `_system_menu`, `_save_load_modal`): açıkken ikinci istek sessizce düşer; karar beklerken yalnız modalın kendi sorusu geçer (`main.gd:4825`)
- Dil/palet değişiminde: pencereler `WindowLayer._rebuild` ile boşaltılıp yeniden kurulur (`window_layer.gd:156`); modaller (system_menu hariç) canlıyken yeniden çevrilmez; kendi `_retranslate` sahibi `settings_modal.gd:374`
- Tema üretilmiştir: token ya da `build_theme.gd` değişince `THEME_STAMP` artar ve iki .tres yeniden üretilir (CLAUDE.md §7); ham `Color(...)`/boyut yazılmaz; sahne ve script yalnız yerleşimin sahibidir
- Menajer teması CanvasLayer ve açılır pencere kalıtımını keser: her katman kökü kendi `theme`ini taşır
- `BuildBar`/`ResearchBar` teması `BuildHUDPanel` kökünden çözülür (kendi tscn'lerinde yok); EndingScene krem kalır (`EndingScene.tscn`da menajer yok)
- Hafıza: Godot tema motoru tuzakları (ata tema önceliği, `has_font`, `set_theme(String)` yasağı) `godot-theme-engine-facts.md`; HBox asgari-boyut tuzağı ve `CACHE_MODE_IGNORE` motoru düşürür: `ekip-rev11-closing-round.md`
- TopBar sütunları TR ve EN'in en geniş değerinden ölçülüdür ve her yazı taban çizgisine konur (`GRID` `top_bar.gd:24`, `_put()` `:401`); yeni metin kalıbı en geniş değeri aşarsa hafta çubuğu kayar. Yenileme `_queue_refresh` ile birleşir
- Hız tuşlarının adları (`PauseBtn`, `Speed1Btn`..`Speed3Btn`) sahnede ve `top_bar.gd:72` `speed_btns` dizisinde sabit; `topbar_speed_cluster_three_rungs` onları okur
- Ray: `LeftTabs.tscn` düğme sırası `UiTokens.TABS` ile aynı olmalı (`rail_tabs_match_scene_order`); kilit gerekçe satırı yalnız `lock` taşıyan satırlarda `_ready`de eklenir (`left_tabs.gd:76-92`)
- Karar beklerken (`EventGate.active_id() != ""`) Olaylar dışı her pencere salt okunur: `WindowFrame` sayfa gövdesine tıklamayı keser (`window_frame.gd:106`), `GateStrip` geri yolu verir; pencere ModalLayer'a ASLA konmaz (Space/1-4'ü yutar)
- Portre: kişi büstü `PersonBust` tek stüdyolu ofscreen SubViewport'tur, kare başına tek portre çizer; başsız modda `null` döner ve avatar baş harflere düşer (`person_bust.gd:38-39`, `ui_factory.gd:123`)
- Büst önbelleği (look imzası, piksel boyutu) anahtarlıdır (`person_bust.gd:41`): aynı kişi iki boyutta iki ayrı iş kuyruğa girer, doku çizilene kadar boştur
- Frank ve kurucu portreleri önceden render edilmiş PNG (`FounderConstants.portrait_path`, `assets/art/portraits/`); kurucuda 11 kimlik `PORTRAIT_IDS`
- Kalabalık satır ölçümü için `--render-probe=hr:<kişi>` (`main.gd:389`) kare maliyetini ve doku belleğini basar
- Onboarding yerleşimi iki değerli tablolardır (`PAPER`, `DOC`, `BUST` `onboarding_flow.gd:24-27`; 1080 yüksek ve daha kısa): yeni öğe ikisine de eklenir; `main_menu.gd` `COLUMN`/`LOCKUP_S` aynı desen
- `NewsTicker` `PROCESS_MODE_ALWAYS`tır ve gerçek zamanda akar; `_exit_tree` bağlantıları elle koparır (`news_ticker.gd:85`); yeni `EventBus` bağlantısı eklersen kopar
- Menü arka planı düşük grafik ön ayarında yalnız plakadır (`menu_backdrop.gd`); canlı sahne `live_ready` verince plakayı örter. Plaka dosyaları `assets/art/menu/backdrop_<ofis>_<HHMM>.png`
- `inject-mouse-click` MCP aracı kırık, int arg marshal olmaz: UI doğrulaması argsız seam'lerle ve OS tıkıyla yapılır (hafıza: godot-mcp-runtime-verification)

## Bir değişiklik yaparken
- Yeni sekme ya da sekme sırası: `UiTokens.TABS` `ui_tokens.gd:294` + `scenes/ui/components/LeftTabs.tscn` düğme sırası + `window_layer.gd` `TAB_SCENES` `:13` ve `SPECS` `:38` + `TAB_<ID>` CSV anahtarı + `rail_tabs_match_scene_order`
- Yeni renk, boyut ya da varyasyon: `ui_tokens.gd` token'ı (+ gerekirse `D_` renk körü ikizi) → `build_theme.gd` varyasyonu → `THEME_STAMP` artır → iki .tres'i yeniden üret → `theme_check.gd` ve `--theme-contrast-audit`
- Yeni modal: sahne + betik (`scenes/modals/`, `scripts/modals/`), `dismissed` sinyali, `populate()`, `process_mode 3`, kökünde `menajer_theme`
- Yeni modal (devam): `main.gd` içine sabit + `_on_*_requested` + EventBus sinyali (`event_bus.gd`); PanelLayer modalı için `HRUiShared.mount_panel_modal`
- Pencerede yeni sayfa: sayfa betiği `frame_options`, `on_escape()`, `on_page_closing()`, `on_panel_over()`, `fit_changed`/`close_requested` sinyalleri ile `WindowFrame`e bağlanır; boyutu `SPECS`ten
- Ek EventBus sinyali dinlersen: `python tools/gen_signal_manifest.py` (üretici `EventBus.<ad>.connect` biçimini okur; `top_bar.gd` bu yüzden bağlantıları tek tek yazar) ve DIZIN'i yeniden üret
- Onboarding adımı eklemek: `OnboardingStep` sözleşmesi (`prefill`, `collect_payload`, `invalid_reason`), `STEPS` `onboarding_flow.gd:15`, `STEP_NAME_KEYS` `:20`, `draft` alanı `:36`
- Onboarding adımı (devam): `FirstWeekDoc.show_draft`, `GameState.initialize_run` yükü, `onboarding_pages_contract`
- Görüşme paneli için yeni adım alanı: adaptörün adım sözlüğü (`sales_meeting_adapter.gd`, `vc_meeting_adapter.gd`) + `meeting_panel.gd` `_frame`/`_settle` + `--meeting-shot` fikstürü
- Görüşme kuralı panelde değil `SalesMeetingSystem`, `VCPitchSystem`, `NegotiationSystem`dedir; panel yalnız adımı çizer
- Avatar ya da portre davranışı: `UiFactory.make_person_avatar`/`make_bust` `ui_factory.gd:106,142` + `avatar_bust.gdshader` + `PersonBust` (Ofis, 06_ofis.md)
- Avatar çağıranları: `meeting_panel.gd:576`, `term_sheet_table_scene.gd:110,224`, Ekip ve Gelen kutusu satırları
- Yeni oyuncu metni: `strings.csv` TR+EN aynı anda (anahtar bayt-aralığı ile eklenir), `tr()` ile oku, sonra `loc_residue.gd` ve `loc_csv_integrity`

## HARITA'da bayat
- HARITA "Tema ve UI kiti": "`DialoguePortraitCard`'ı onboarding'in karakter adımı kullanır"; `character_step.gd` onu kullanmaz, portreyi doku olarak koyar (`character_step.gd:55`)
  ↳ `DialoguePortraitCard` sınıfını yalnız kendi tscn'si referanslar (kodda `new`, `preload` ya da sahne örneği yok)
- HARITA "Onboarding": akış `Footer/Reason`a yazar; sahnede düğüm `Paper/Col/Foot/Row/Reason` (`OnboardingFlow.tscn:121`, kodda `%Reason`)
