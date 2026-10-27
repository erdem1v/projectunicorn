# Arayüz bileşenleri, tema, pencereler, menü ve ilk kullanım

Dizin sha: f3113fa4 (DIZIN.md başlığı; yollar:satırlar o dizinin kirli ağaç halinden okundu). Yeniden üret: `python -I tools/kod_haritasi/uret.py`.
Kapsam: scripts/ui (office hariç), scripts/theme, scripts/modals, scripts/menu, scripts/onboarding, metin anahtarı okuma deseni. Ofis 3B: 06_ofis.md. Kabuk kökü `main.gd`/`game_shell.gd`: 01_cekirdek.md.

Ne yapar: Oyunun 2B kabuğunu (üst bar, sol ray, pencere katmanı, haber şeridi, yüzen kartlar, toast), modalları, ana menüyü, ilk kullanım akışını ve görüşme panelini çizer.
Her yüzey oyun durumunu yazmaz, sistemlerden okur ve olaylara EventBus ile bağlanır. Renk, boyut ve yüz `UiTokens`tan, Control üretimi `UiFactory`den gelir; `build_theme.gd` iki .tres temayı üretir.
Oyuncu metni `tr(ANAHTAR)` ile `localization/strings.csv`den okunur; ayrı bir Control ağacı kuran statik yardımcılar `TranslationServer.translate` kullanır.
Kaynak (GDD): Tema ve UI kiti ch12 · Ana menü, açılış dizisi ve Jenerik ch12 §6 · Kabuk ch12 · Görüşme paneli ch09 §4 ve Satış §5 · Onboarding ch02 ve ch12.
Sahipler (Tema): `UiTokens`, `UiFactory`. Sahipler (Ana menü): sahne betikleri sınıf adı taşımaz; `main.gd` kurar ve bağlar (`_mount_godot_card`, `_mount_menu`, `_free_menu`, `_mount_flow`),
  ↳ `_state` açılışın evresini tutar (`card`, `menu`, `flow`, `loading`).
Sahipler (Kabuk): `main.gd` (ana sahne kökü), `game_shell.gd` (`GameShell.tscn`), `window_layer.gd` (`CenterViewport`, grup `window_layer`); `window_frame.gd`, `inbox.gd` ve `mail_pane.gd` yolla preload edilir (sınıf adı yok).
Sahipler (Görüşme paneli): `MeetingPanel`, `MeetingRuler`, `VcMeetingAdapter`, `SalesMeetingAdapter`; seçenek kartı `meeting_panel_option.gd` (sınıf adı yok, panel preload eder). Sahipler (Onboarding): `OnboardingStep`, `LogoEmblem`,
  ↳ `SegmentBar`; kurallar `FounderConstants`'ta (04_ekip.md).

## Dosyalar
- `scripts/theme/ui_tokens.gd` (1022): `UiTokens`; tüm renkler, SIZE_* merdiveni, krem palet, koyu dil `D_*`, `TABS`, `THEME_STAMP`, renk körü anahtarı ve `D_` yardımcıları
- `scripts/theme/ui_factory.gd` (543): `UiFactory`; statik Control üreticileri (label, pill, badge, kart, avatar, `D_tag`, `D_kpi`, `D_seg_tabs`, `D_said`, `D_stars`) hep tema varyasyonu adlarıyla
- `scripts/theme/build_theme.gd` (1620): `-s` betiği; UiTokens'tan `themes/master_theme.tres` (krem) ve `themes/menajer_theme.tres` (koyu) üretir,
  FontVariation sarmalarını kurar (koyu yüzler Archivo'nun değişken yüzü; yedek Plex, sonra Noto Sans Symbols 2)
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
- Sahneler: `scenes/ui/components/` (TopBar, LeftTabs, NewsTicker, BuildBar, BuildHUDPanel, ResearchBar, `avatar_bust.gdshader`), `scenes/menu/` (5 tscn, `menu_grade.gdshader`)
- Sahneler (devam): `scenes/modals/` (10 tscn; HRAtlasModal'ın betiği `scripts/tabs/hr/hr_atlas_modal.gd`), `scenes/onboarding/` (OnboardingFlow, 3 adım), `scenes/debug/ThemeProbe.tscn`
- Veri: `themes/master_theme.tres`, `themes/menajer_theme.tres` (üretilmiş, elle düzenlenmez), `localization/strings.csv`, `data/credits.json`; debug: `scripts/debug/kit_probe.gd`, `glyph_audit.gd`
- Dışarıda ama ayrılmaz: portre ve kişi büstü `scripts/ui/office/person_bust.gd` (`PersonBust`), kurucu/Frank portre yolları `scripts/systems/founder_constants.gd`, ekran ölçüsü `scripts/systems/display_settings.gd`

## Giriş noktaları
- `Main._mount_godot_card()` `scripts/main/main.gd:114`: açılışta bir kez, boot splash ile menü arasında · `_ready` (main.gd) sonunda; kart `finished` verince `_mount_menu()` `main.gd:126`
- `Main._mount_menu()` `main.gd:126`: menüyü kurar, `SaveManager.end_run()` der · açılıştan, `_return_to_menu()` `main.gd:145` ve reddedilen yüklemeden
- `Main._mount_flow()` `main.gd:151`: Yeni oyun'da `OnboardingFlow` kurar, `completed` → `_swap_to_shell_and_modal` `main.gd:4664` · `main_menu.gd` `new_game_requested`
- `Main._modal_layer()` `main.gd:4720`: modalların takıldığı katman (`GameShell/ModalLayer` ya da menünün kendi ModalLayer'ı) · bütün modal yolları
- `Main._on_settings_requested()` `main.gd:5046`: hızı 0 yapar, `SettingsModal` takar; kurucu yolculuktayken toast söyler · `EventBus.settings_requested` (bağlantı `main.gd:88`)
- `Main._on_confirm_requested(config)` `main.gd:5066`: `config.modal == "hr_action"` ise `HRActionModal`, yoksa `ConfirmModal`; sonra `populate(config)` · `EventBus.confirm_requested` (`main.gd:90`)
- `Main._on_system_menu_requested()` `main.gd:5094`: ESC menüsü · `EventBus.system_menu_requested` (`main.gd:4714`; yayan `game_shell.gd:106`); X ve Alt+F4 `_notification` `main.gd:5114`
- `Main._on_save_load_requested(mode)` `main.gd:5129`: `SaveLoadModal` takar, add_child sonrası `populate(mode)` · `EventBus.save_load_requested` (`main.gd:89`)
- `Main._on_run_ended()` `main.gd:5238` ve `_on_milestone_reached()` `main.gd:5259`: `EndingScene` takar, `populate(data)` · `EventBus.run_ended` ve `milestone_reached`
- `Main._on_term_table_requested()` `main.gd:5301`: `TermSheetTableScene` takar; `closed` → `_close_term_table()` `main.gd:5325` · `EventBus.term_table_requested`
- `Main._open_meeting(adapter, side, place)` `main.gd:5027`: yolculuktan sonra `MeetingPanel` takar, `open(adapter, cast)`; `_close_meeting` `main.gd:5038` · `_open_sales_meeting` `:4780`, `_on_meeting_scene_requested` `:4770`
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
- `MeetingPanel.open(adapter, cast)` `meeting_panel.gd:125`, `pick(id)` `:146`, `proceed()` `:169`, sinyal `closed` `:19`: panel oynatır, seçimi adaptöre iletir · `main.gd:5027`
- `SalesMeetingAdapter._init(prospect_id)` `sales_meeting_adapter.gd:51`, `start` `:56`, `pick` `:81`, `select` `:102`, `proceed` `:109`, `end_sitting` `:117` · `MeetingPanel` ve `main.gd:5014`
- `VcMeetingAdapter._init(view_state)` `vc_meeting_adapter.gd:40`, `start` `:49`, `pick` `:61`, `proceed` `:91`, `withdraw` `:98`, `end_sitting` `:103` · `MeetingPanel` ve `main.gd:5004`
- `OnboardingFlow._commit()` `onboarding_flow.gd:192`: perdeyi çizer, sahneyi durdurur, `GameState.initialize_run(draft)` `game_state.gd:769`, `completed` · `_on_next()` `onboarding_flow.gd:155` son adımda
- `OnboardingStep` sözleşmesi `step_base.gd`: `prefill` `:23`, `invalid_reason` `:28`, `is_valid` `:32`, `collect_payload` `:36`, `roll` `:40` · yalnız `onboarding_flow.gd:92` (`_mount_step`) çağırır
- `MenuBackdrop.start(office_id, minute, figure)` `menu_backdrop.gd:40`, `stop()` `:65`, `set_figure()` `:75` · `main_menu.gd` (MenuBackdrop sahnede), `onboarding_flow.gd:70`, `main.gd:138`
- `UiFactory.make_person_avatar(name, look, px, grey)` `ui_factory.gd:106` → `PersonBust.texture(look, px)` `person_bust.gd:38` · meeting_panel.gd:576, term_sheet_table_scene.gd:110,224
- `UiFactory.make_mentor_avatar(px)` `ui_factory.gd:111`: Frank'in önceden render edilmiş portresi · meeting_panel.gd:428, term_sheet_table_scene.gd:245
- `UiTokens.set_colorblind(on)` `ui_tokens.gd:317`, `D_variation(name)` `:972`: palet anahtarı; çağıran `Settings`/`settings_modal.gd:249`, sonra `EventBus.palette_changed`
- `BuildTheme._initialize()` `build_theme.gd:42` → `_menajer(master)` `:421`: iki temayı yazar · elle: `godot --headless --path . -s res://scripts/theme/build_theme.gd`
- `ThemeCheck.contrast_audit(th, T)` `theme_check.gd:156`: koyu temanın kontrast kapısı · `main.gd:235` (`--theme-contrast-audit`); `missing()` `theme_check.gd:44`, `unset_margins()` `:71`, `contrast()` `:83`

## Sinyaller
- `dismissed`: modallar yayar (tanım `confirm_modal.gd:13`, `hr_action_modal.gd:16`, `save_load_modal.gd:14`, `settings_modal.gd:16`, `system_menu_modal.gd:18`, `credits.gd:6`, `licenses.gd:8`) · `main.gd:5058,5083,5102,5136` ve menü
- `confirmed` / `alt_selected`: `confirm_modal.gd:11,12`, `hr_action_modal.gd:15` · `main.gd:5078,5082` (`config.on_confirm`, `on_alt`), `onboarding_flow.gd:177` (iptal onayı)
- `save_requested(slot_id)` / `load_requested(slot_id)`: `save_load_modal.gd:15,16`; `main_menu.gd:8` yayar · `main.gd:5137,5138` ve `main.gd:133` (`_load_slot` `:4961`)
- `main_menu_requested` / `exit_save_requested`: `system_menu_modal.gd:19,20` (yayın `:63`, `:93`); `ending_scene.gd:41` · `main.gd:5103,5104,5271`
- `continue_requested`: `ending_scene.gd:40` (yayın `:445`) · `main.gd:5270` (`_on_milestone_continue`)
- `closed`: `meeting_panel.gd:19`, `term_sheet_table_scene.gd:17` · `main.gd:5031` (`_close_meeting`), `main.gd:5318` (`_close_term_table`)
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
- `runs_finished` profil sayacı `Settings` anahtarı, `main.gd:5241`'da artar; Onboarding Zor kipi açılışını buradan okur (`first_week_doc.gd:15`)
- Tema sürümü: `UiTokens.THEME_STAMP := 40` `ui_tokens.gd:44`; .tres'in gömülü `UiTokensStamp.stamp` sabiti ile `main.gd:99-100` karşılaştırılır (debug uyarısı)
- Ürün sol sütunu: ölçüler `D_W_LEFT` 288, `D_BOX_MONO` 24, `D_H_KEY_CAND` 24, `D_W_STAGE_STRIP` 168, `D_H_STAGE_STRIP` 6, `D_PLANNED_ALPHA` (planlı talep), `D_TAKEN_ALPHA` (planlı ya da damgalı aday);
  ↳ aşama bantları `D_ST_DESIGN/DEV/TEST` ve `UiTokens.D_stage(aşama)`.
- Yüzler: `d_wide_b` (Archivo 800, genişlik 118: modül işareti `MonoMark`) ve `d_wide_sb_caps` (650, genişlik 110, harf aralığı 1: göz başlığı `Eyebrow`); `d_num` (650/108, tablo rakamları: Kapasite'nin `CapFigure` sayısı).
- Sembol yedeği: koyu zincirler Archivo, Plex, `symbols_flat` (Noto Sans Symbols 2'nin kendi RID'li yüzü: ★ ☆ ✓ ▾ ⌛ ✕).
  Satır yüksekliği yedeğin metriğinden de gelir: `UiFactory.flatten_symbol_face()` (`main.gd` `_ready`) yüzün ascent/descent'ini 9 ile 52 px arasında sıfırlar.
  Krem zincirler düz Noto dosyasıyla biter, metriği dokunulmaz; `build_theme.gd` `_bare` ve `_line_h()` koyu kutunun payını yedeksiz hesaplar. `glyph_audit` her zinciri sınar.
- Sprint başlığı ve Kapasite ölçüleri: `D_H_SPRINT_HEAD`, `D_H_CAP_HEAD`, `D_H_CAP_ROW` 56, `D_H_CAP_TRACK`, `D_CAP_FILL_INSET`, `D_W_CAP_{TIP,LABEL,NUMBER,BADGE}`,
  `D_W_FACE_SLOT`, `D_STAR_CHIP`, `D_AWAY_ALPHA`, `D_NOTCH_QUARTER`, `D_WEEK_BAR`, `D_BUSY_BAR`, `D_HATCH`, `D_CREW_OVERLAP`; renkler `D_stage_edge/fill/ghost`, `D_hatch_base`.
  ↳ Sağ sütun ve alt şerit: `D_W_NEXT` 300 (sağ sütun, her dilde bu genişlik), `D_H_FOOT` 68, `D_W_START` 204, `D_W_PROGRESS` 300 ve `D_W_PROGRESS_BAR` 120 (en azları), `D_H_LOAD_BAR` 4, `D_W_LOAD_NUM` 64, `D_H_NEXT_STRIP` 8.
  ↳ Devirli koşuda ilerleme çubuğu `D_W_PROGRESS_BAR_TIGHT` 90'a iner, kutu içeriği kadardır (PM'in adı kesilmez).
  ↳ Orta sütun artık kalanı alır (`D_SPRINT_COLUMNS` silindi).
- Pano (kart satırı ve zaman ekseni) ölçüleri: `D_W_CARD_INFO` 312, `D_W_TIMELINE` 396, `D_TIMELINE_WEEKS` 2.6 (sprintin iki haftası ve sonrakinin ilk 0,6'sı), `D_H_BOARD_HEAD`, `D_H_CARD_ROW` 56 ve `_TWO` 74,
  `D_CARD_NAME_SHORT` 22, `D_H_STAGE_BAR` 30, `D_STAGE_BAR_PAD`, `D_W_TICK_BOX`, `D_NOW_HEAD`, `D_W_CARD_SLOT`, `D_RISK_BAR`, `D_ASK_DISC`, `D_H_BOARD_SECTION`, `D_H_BOARD_FADE`, `D_ROW_ALPHA`, `D_GHOST_ALPHA`;
  ↳ çubuk ve izler: `D_STAGE_BAR_MIX` (zemin payları), `D_STAGE_BAR_EDGE` (kenar alfası), `D_SHADOW_ALPHA`, `D_SHADOW_FOOT_ALPHA`, `D_H_SHADOW`, `D_SPILL_LINE`, `D_SPILL_STEP`, `D_EARLY_STRIPE`, `D_EARLY_PERIOD`, `D_MEET_LIGHT/DARK/EDGE`,
  `D_MEET_PERIOD`; renkler `D_stage_bar(aşama, tür)` ve `D_stage_bar_edge(aşama, tür)`.
- Bu bloğun varyasyonları yalnız koyu temadadır: `SprintTitle`, `MvpVersion`, `HeadMeta`, `CrewTotal`, `GoalPick(+Set)`, `QuarterNotch(+Past, +Now)`, `WeekBar`, `FaceRing`,
  `StarChip`, `ClusterStars`, `AwayLabel`, `CapBlock`, `CapRow(+Hot)`, `CapStage`, `CapUnit`, `CapFigure`, `CapTeam`, `CapBadgeOver(+Ink)`, `CapStreak(+Ink)`; panonun: `CardEffort`, `StageNum`, `AxisLabel`, `MoreHint`,
  `SprintRow(+Hover, +Cand, +CandHover, +Late(+Cb))`, `RowActs`, `RowKey`, `MoreHintPill(+Late(+Cb))`, `GhostRow`;
  alt şeridin ve sağ sütunun: `DelegateBox(+Hover, +Locked)`, `ProgressBox`, `ProgressFigure`, `NextTitle`, `NextBox`, `NextCard`, `PrepRow(+Tight)`, `FaceGhost`, `LoadNum`, `CarriedRow`, `CarriedRest`.
- `StagePaint` (`scripts/tabs/product/stage_paint.gd`): StyleBox'ın çizemediği izler (şeritli taşma, kesikli çizgi, üç satırın ayracı, çubuklar) için tek Control; `kind` StringName, ölçü ve renk token'dan, yerleşim sahibinde.
  Kapasite: `groove`, `busy`, `bracket`. Pano: `grid` (hafta ayracı, sprint sonu çizgisi, sonraki sprintin çizgili zemini), `now` (şimdiki an çizgisi ve üçgeni), `early` (erken kapanışın taralı alanı), `bar` (aşamanın çubuğu:
  plan, koşan, biten, bekleyen, sprint dışı, hayalet; sol başta dolgu), `label` (çubuğun ikonu ve sayısı: sığmazsa önce ikon sonra sayı düşer), `wait` (bekleme noktalı çizgisi), `shadow` (PM'in gölgesi), `meet` (görüşme taraması),
  `tick` (önden biten aşamaların tek tik kutusu, son bitenin renginde; kutudaki işaret ve renk `BoardRow` sürer), `risk` (hata göstergesi), `ask` ("?" işareti), `fade` (alttaki hapın arkasında solma).
  Sağ sütun: `load` (bir aşamanın yük çubuğu, ekipten taşarsa uyarı rengi), `seg` (sonraki sprintin kartının bir aşama payı, önden yapılan kısmı aşamanın renginde dolu; tek tik kutusu kuralı yalnız panoda).
  `StagePaint.spill` ve `hatch` taramanın statik çizimidir (`SprintNext.CarryRow` da kullanır). `StagePaint.part(kind, aşama, spec, rect)` panonun öğesini kurar;
  `set_bar(spec)` saat ilerleyince çubuğun hâlini, dolgusunu ve yazısını değiştirir. Çizimi `spec` sürer; ipucu için `tooltip_text` öğeye yazılır (`grid`, `now`, `label`, `fade` fareyi görmezden gelir).
- Sol sütunun varyasyonları yalnız koyu temadadır (master taşımaz, `theme_check` ikisinde geçer): `RequestRow` (+`Hover`, `Planned`), `ModuleRow` (+`Hover`, `Open`), `ModuleCandidate`, `DueChip`, `DueChipSoon`, `MoreLink`
  ↳ `MonoBox` HR ve posta ile ortaktır.
- Tema yolu: `UiTokens.MENAJER_THEME` `ui_tokens.gd:450`; proje teması `project.godot` `theme/custom` = `master_theme.tres`; Menajer teması taşınan her alt ağacın köküne ve her CanvasLayer köküne elle atanır
- Boyut merdiveni: `SIZE_MICRO 9 … SIZE_DISPLAY 22` `ui_tokens.gd:196-203`, editorial `SIZE_ED_*` `:208-212`, koyu `D_FS_12 … D_FS_40` `:603-614`; term sheet sütunu `D_STAGE` `:817`
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
- Smoke (`bash tools/smoke_run.sh <vaka>`, kaynak `scripts/debug/endgame_smoke.gd` eşleme tablosu): `rail_tabs_match_scene_order` `:414`, `topbar_speed_cluster_three_rungs` `:406`, `menu_state_machine` `:303` (ana menü)
  ↳ `menu_has_one_path` `:200` ana menüyü değil Ekip satır menüsünü sınar (08_sekmeler.md)
- Smoke (devam): `onboarding_pages_contract` `:182`, `ui_scale_ladder_fits_settings` `:314`, `loc_language_switch` `:366`, `loc_csv_integrity` `:316`, `ending_paper_modes_on_screen` `:396`, `star_ruler_contract` `:418`
- Smoke (devam): `work_hours_three_scopes` `:426`, `work_hours_draft_commits` `:427`, `hr_training_locks` `:188`, `inbox_no_night_stamp` `:362`, `build_percent_single_source`, `rnd_rail_open_with_locked_tree` `:461`, `all_scripts_load`
- Kapılar: `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` (oyuncu metni kaçakları), `-s res://scripts/theme/theme_check.gd [--theme=<yol>]`, `--theme-contrast-audit`, `-s res://scripts/debug/glyph_audit.gd`
- Görsel kabul (pencereli, Godot MCP; `main.gd`): `--tab-shot` `:2338`, `--modal-shot` `:2539`, `--menu-shot` `:2691`, `--onboard-shot` `:2858`, `--meeting-shot` `:4255`, `--clock-shot` `:2196`
- Görsel kabul (devam): `--theme-audit=<sekme|modal:<tür>|onboard:<adım>>` `:2908`, `--vc-shot=<tür>[:shell]` `:3999`, `--negotiation-shot` `:4351`, `--invite-shot` `:2124`, `--inbox-shot` `:1107`
- Görsel kabul (devam): `--ending-shot` `:3602`, `--probe-shot[=menajer]` `:2927` (ThemeProbe), `--backdrop-probe` `:2788`, `--render-probe` `:389`
- Görsel (Tema): `--theme-audit=<sekme id | modal:<tür> | onboard:<adım>>` yüzeyi `--tab-shot`, `--modal-shot`, `--onboard-shot` gibi kurar, kare yazmaz; her Control'ün çözülmüş değerlerini, içerik payını `cm`,
  ↳ en küçük boyunu `min` ve öğeyi çözen temayı `src` (`o` override, `a:<tema>` ata teması, `p` proje teması, `d` motor varsayılanı), Control'ün kendi üstüne koyduğu her tema öğesini `ov` basar; `--probe-shot` (ThemeProbe),
  ↳ `--probe-shot=menajer` (koyu temanın master dışı her varyasyonundan bir örnek), `--probe-shot=kit` (koyu kitin bileşenleri durumlarıyla: Ekip satır ızgarası, etiketler, bedel, toast'lar, odak halkası),
  ↳ `--theme-contrast-audit` (başsız; koyu temanın her metin rengi çizildiği her zeminde ve `D_` yardımcılarının renkleri iki palette, `CONTRAST` satırları; düşen çiftte 1), `--tab-shot=`, `--shot-size=`
- Görsel (Ana menü): `--menu-shot=<empty|continue|first_frame|godot_card|load|settings|credits|licenses|plate|live|return_confirm[:gate]|all>` açılışı oyuncunun gördüğü gibi kurar ve kare başına
  ↳ `MENU|state=|focus=|continue=|groups=|paused=|joy_ui=` basar; `continue` ve `load` fikstür kayıtlarının üstünde koşar (yükleme penceresi oto yedekleri açık); `first_frame` menünün örtü altındaki ilk karesi,
  ↳ `godot_card` kartı çerçeveler (sonra `ui_accept`, iki kare sonra menü), `live` canlı sahnenin solmasını bekler, öbürleri plakada durur; `return_confirm` `--modal-shot=return_confirm[_gate]`'e gider;
  ↳ `all` her türü kendi pencereli sürecinde koşar ve `MENU|all|kind=|exit=` basar; `--menu-shot=bake_plate:<ofis>:<HHMM>` canlı sahneyi plaka olarak yazar (`assets/art/menu/`'ye kopyalanır);
  ↳ 1536×864 kareler 1920 pencerede `--shot-scale=1.25` ile çekilir; ayrıca `--theme-audit=menu`, `--modal-shot=settings_end` (Veri satırı); `--menu-shot` fikstür kayıtlarını `user://shot_menu/`'ye yazar;
  ↳ `user://saves`'te kayıt varsa `MENU|refused=user_saves` basıp 1 ile çıkar, ayrı `APPDATA` ister
- Ölçüm (Ana menü): `--backdrop-probe[=<ofis>:<HHMM>]` (pencereli; çıplak hâli menünün akşam şehri): `BACKDROP|plate_frame=|live_ms=|fade_ms=|gpu_ms_p50=|gpu_ms_p95=|boot_to_menu_ms=`,
  ↳ plaka ile canlı karenin ortalama mutlak farkı `BACKDROP|plate_vs_live=` (≤ 6/255) ve YENİ OYUN'dan sonra `BACKDROP|new_game|nodes=|backdrop=|tex_pct=`. Düşük ön ayarda yalnız plaka durur, ölçümler `n/a` olur;
  ↳ probe kabuk ve onboarding kurmaz (kayıt türü yok)
- Görsel (Kabuk): `--tab-shot=<product|sales|hr|finance|piyasa[:<durum>]|personal|rnd|marketing|events>` (pencere ofisin önünde; `<sekme>:cheque` ve `<sekme>:seed` sekmeyi hedef listelerinin ilk haftasında açar: çekin 2/5'i,
  ↳ seed listesinin 0/2'si), `--modal-shot=confirm|confirm3|confirm3_gate|return_confirm|return_confirm_gate|f5_gate`; `confirm` tohum görüşmesinin onayı, `confirm3` sistem menüsünün üstünde çıkış onayı,
  ↳ haftalar kaydedilmemişken (`confirm3_gate` karar beklerken), `return_confirm` aynısı Ana menüye dön onayı, `f5_gate` karar beklerken F5; `--office-shot=<ofis>:<saat>:toast` (06_ofis.md), `--shot-size=`, `--skip-onboarding`. Ölçüm:
  ↳ `--render-probe[=<sekme>[:<kişi>[:<hız>]]]` (`--shot-size=` ile) kabuğu tek pencere boyutunda kurar, kare maliyetini ve doku ve video belleğini basar; `<kişi>` kadroyu o sayıya doldurur,
  ↳ `<hız>` saati o hızda en az üç oyun saati koşturur, `rebuild_view` taşıyan sayfanın tam yeniden kuruluş karesini `REBUILD_MS` basar
- Görsel (Görüşme paneli): `--meeting-shot=<probe|locked|won|lost|handoff|economy|frank|emph_trust|emph_integrations|emph_onboarding|weak_core|die|focus|returning>` (satış): `probe` ilk soru,
  ↳ `locked` kilitli cevabı olan soruya ve kilit satırına kadar, `won` müşterinin kesimine kadar oynanır (Devam teklife), `lost` kayba (sonuç kartı), `handoff` Devam'dan Perde 2'ye;
  ↳ `economy` Ekonomik sunucuda kapasitesini aşan ürünle 3★ masa, kesime kadar oynanır ve Perde 2'ye geçer: yük sorusu yok, onay şeridinin uyarı satırı sunucu maddesini söyler,
  ↳ `MEETINGSHOT|economy|load=|asked=` yükü ve sorulan aileleri basar; `frank` Satış'ı ve Karizma'sı sıfır kurucunun karşısına Frank'in tanıştırdığı 2★ adayı oturtur,
  ↳ ilk soruda iğnenin hover satırlarının seam'lerini `MEETINGSHOT|frank|mods=…` basar; `emph_*` sektörü sabit 2★ masa vurgu sorusunu üç biçimiyle sorar (alanı Güven için kurulu: güçlü cevap açık; ikisi için boş: kilit satırı);
  ↳ `weak_core` Çekirdek'i en zayıf alan olan 3★ masa (sorunun üstünde itiraz, güçlü cevabın altında kilit satırı); `returning` Entegrasyonlar yüzünden kaybedilmiş 2★ masa geri geldi (başlıktaki hafıza satırı);
  ↳ `die` aynı masa bir cevap sonra, teklife geç seçeneğinin zarı üstünde: ipucu satırı alanı ve sözcüğünü söyler, dört satırdan sonrası "+N etken daha", kalanlar İkna'nın ipucunda;
  ↳ `focus` `die`'ın masası, Güven en üst kademede ve Güven üstüne bir kart vurgusu (`SalesMeetingSystem.set_pitch_focus`) çalışırken: "Bu çeyreğin vurgusu" satırı yalnız zarın ipucunda yaşadığından kare ipucu açıkken çekilir;
  ↳ `MEETINGSHOT|focus|<satır>` ipucunun o satırını (listede değilse "(not among the hover's lines)"), `MEETINGSHOT|focus_lines|` ipucunun bütün satırlarını basar;
  ↳ ipucunun her satırı büyük harfle başlar (VC'nin beceri çipi `HRUiShared.skill_label`, "+ Karizma"), katlanan satır boş kategori etiketiyle öbür etkenlerin metin satırında durur; kare hover'ı göstermez;
  ↳ `won` ve `handoff` ile `--negotiation-shot=<open|countered|insult|last|confirm>` ürünü her hattı K2 yapar, masa kazanılsın diye; VC:
  ↳ `--meeting-shot=<open|sorgu|sheet|callback|ret|seed|long>` (`open:tip` ve `sorgu:tip` zar taşıyan ilk seçeneğin ipucunu açar): `open` Odayı Oku, HAFIZA satırı ve çekilme düğmesi, `sorgu` üçüncü vuruş,
  ↳ `sheet` kazanılmış odanın sonuç kartı, `callback` ılık odanın geri araması ve şartı; `ret` soğuk odanın reddi, bedeli ve Frank'in çıkışı, `seed` seed odasının sonuç kartı,
  ↳ `long` ılık odanın kapanış vuruşu ve altındaki bütün öncekiler (panelin alabildiği en çok; en dar dok için `--shot-scale=1.25`);
  ↳ `--travel-shot=<ofis>[:vc|:night]` (06_ofis.md) ve `--invite-shot=<ring|card|vc|postpone|postpone_vc|held|lapse|lapse_vc>`: İş hanında arama (not yığını üç satırlı: halka, açık kart, fonun kartı), satışın ve fonun ertelenmesi,
  ↳ tutuş altında reddedilen Kabul et, kesime düşen satış çağrısının tostu ve `INVITE|lapse` satırı. Tostsuz düşen fon çağrısının erteleme bedeli `INVITE|lapse_vc|ringing=…|penalty=…` satırı;
  ↳ düşüşlerde önce `invite_shot_<tür>_ring` karesi, sonra `invite_shot_<tür>`
- Görsel (Onboarding): `--onboard-shot=<1|2|3>[:<durum>]` | `curtain` (durumlar `1:plate`, `1:cancel`, `2:random`, `2:hard_locked`, `2:hard_open`, `3:guided_locked`, `3:reroll`; `2` taslakta bir beceriye 2 dağıtım puanı yazar:
  ↳ cetvelde 4); kurulumun düğüm sayısını `ONB|nodes=|tex_mib=` basar, sahne gelince `ONB|stage=live|figure=`; `--theme-audit=onboard:<1|2|3>`, `--inbox-shot=intro`;
  ↳ `project.godot` `main_args`'taki `--skip-onboarding` doğrudan kabuğa geçer; probe onboarding'i atlar (kayıt türü yok)
- Ortak bayraklar: `--lang=tr|en`, `--shot-size=GxY`, `--shot-scale=1.25`, `--palette=cb` (`main.gd:597`). Kayıt yazan `--modal-shot=save*|load*` ve `--menu-shot` ayrı `APPDATA` ile koşar (CLAUDE.md §12)
- Debug seam'leri (argsız, MCP): `_dbg_menu_digest()` `main.gd:5374`, `_dbg_close_request()` `:5117`, `_dbg_finish_run()` `:5135`, `_dbg_onb_random_x20()` `:5122`; `kit_probe.gd` `--probe-shot=kit` koyu kitin durumlarını çizer
- CLAUDE.md §10: arayüz doğrulaması smoke'la değil görsel kabulle yapılır; yeni UI smoke vakası yazılmaz

## Dikkat
- Yeni `class_name` paylaşılan checkout'ta başka oturumların headless koşusunu düşürür: bu sistemde `window_frame`, `gate_strip`, `inbox`, `toast`, `bar_kit`, `build_bar_model` yol ile `preload` edilir (dosya başlıklarında yazılı)
- `static func` içinde `tr()` derlenir ama çalışırken ölür (CLAUDE.md §5, `loc_residue`); `Inbox`, `InvestorAppetiteUi`, `UiTokens` `TranslationServer.translate` kullanır
- Modal yaşam döngüsü: `add_child` SONRA `populate()` (`@onready` ancak o zaman dolu; `main.gd:5085,5140,5251,5273`), kök `process_mode = 3` (ALWAYS, duraklamada da tıklanır), ESC `_unhandled_input` ile kapatır
- Modal tekilliği `main.gd` alanlarında (`_confirm_modal`, `_settings_modal`, `_system_menu`, `_save_load_modal`): açıkken ikinci istek sessizce düşer; karar beklerken yalnız modalın kendi sorusu geçer (`main.gd:5070`)
- Dil/palet değişiminde: pencereler `WindowLayer._rebuild` ile boşaltılıp yeniden kurulur (`window_layer.gd:156`); modaller (system_menu hariç) canlıyken yeniden çevrilmez; kendi `_retranslate` sahibi `settings_modal.gd:374`
- Tema üretilmiştir: token ya da `build_theme.gd` değişince `THEME_STAMP` artar ve iki .tres yeniden üretilir (CLAUDE.md §7); ham `Color(...)`/boyut yazılmaz; sahne ve script yalnız yerleşimin sahibidir
- Menajer teması CanvasLayer ve açılır pencere kalıtımını keser: her katman kökü kendi `theme`ini taşır
- Çerçeve (TopBar, NewsTicker) koyu temayı okur: iki sahnenin kökünde `menajer_theme.tres` atanmıştır ve çerçevenin yazı ile düğme varyasyonları (`HeroValue`, `ClockLabel`, `SpeedKey`, `TickerToggle` …) o temada tanımlıdır.
  ↳ Krem temadaki koyu yüzeyler gövdeyle değişen her rengi `*_CHROME` ikizinden okur (`ACCENT_CHROME`, `INK_*_CHROME`, `VEIL_*_CHROME`)
- `BuildBar`/`ResearchBar` teması `BuildHUDPanel` kökünden çözülür (kendi tscn'lerinde yok); EndingScene krem kalır (`EndingScene.tscn`da menajer yok)
- Hafıza: Godot tema motoru tuzakları (ata tema önceliği, `has_font`, `set_theme(String)` yasağı) `godot-theme-engine-facts.md`; HBox asgari-boyut tuzağı ve `CACHE_MODE_IGNORE` motoru düşürür: `ekip-rev11-closing-round.md`
- TopBar sütunları TR ve EN'in en geniş değerinden ölçülüdür ve her yazı taban çizgisine konur (`GRID` `top_bar.gd:24`, `_put()` `:401`); yeni metin kalıbı en geniş değeri aşarsa hafta çubuğu kayar. Yenileme `_queue_refresh` ile birleşir
  ↳ `_refresh` ızgarayı `GRID[int(_compact)]`'ten kopyalar; RUNWAY hücresi gizliyken (`UiTokens.D_runway_reading().text == ""`) çizgi, ikinci metrik grubu ve gün bloğu onun bıraktığı boşluğu kapatır; `_refresh_brand`, `_refresh_metrics`,
  ↳ `_refresh_day`, `_refresh_gate` ve `_refresh_time` yürürlükteki ızgarayı `_g` alanından okur
- Hız tuşlarının adları (`PauseBtn`, `Speed1Btn`..`Speed3Btn`) sahnede ve `top_bar.gd:72` `speed_btns` dizisinde sabit; `topbar_speed_cluster_three_rungs` onları okur
- Ray: `LeftTabs.tscn` düğme sırası `UiTokens.TABS` ile aynı olmalı (`rail_tabs_match_scene_order`); kilit gerekçe satırı yalnız `lock` taşıyan satırlarda `_ready`de eklenir (`left_tabs.gd:76-92`)
- Karar beklerken (`EventGate.active_id() != ""`) Olaylar dışı her pencere salt okunur: `WindowFrame` sayfa gövdesine tıklamayı keser (`window_frame.gd:106`), `GateStrip` geri yolu verir; pencere ModalLayer'a ASLA konmaz (Space/1-4'ü yutar)
- Portre: kişi büstü `PersonBust` tek stüdyolu ofscreen SubViewport'tur, kare başına tek portre çizer; başsız modda `null` döner ve avatar baş harflere düşer (`person_bust.gd:38-39`, `ui_factory.gd:123`)
- Büst önbelleği (look imzası, piksel boyutu) anahtarlıdır (`person_bust.gd:41`): aynı kişi iki boyutta iki ayrı iş kuyruğa girer, doku çizilene kadar boştur
- Frank ve kurucu portreleri önceden render edilmiş PNG (`FounderConstants.portrait_path`, `assets/art/portraits/`); kurucuda 11 kimlik `PORTRAIT_IDS`
- Kalabalık satır ölçümü için `--render-probe=hr:<kişi>` (`main.gd:389`) kare maliyetini ve doku belleğini basar
- Onboarding yerleşimi iki değerli tablolardır (`PAPER`, `DOC`, `BUST` `onboarding_flow.gd:24-27`; 1080 yüksek ve daha kısa): yeni öğe ikisine de eklenir; `main_menu.gd` `COLUMN`/`LOCKUP_S` aynı desen
- Onboarding'in neden etiketi alt şeritteki `Paper/Col/Foot/Row/Reason` düğümüdür (`OnboardingFlow.tscn:121`, kodda `%Reason`); karakter adımı portreyi doku olarak koyar (`character_step.gd:55`, `FounderConstants.portrait_path`),
  ↳ ayrı bir portre kartı bileşeni yoktur
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
