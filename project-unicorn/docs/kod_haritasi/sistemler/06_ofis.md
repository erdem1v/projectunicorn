# Ofis ve 3B ofis · dizin git f3113fa4

Ne yapar: Şirketin çalıştığı ofis merdiveni (Ev, İş hanı, Plaza, Loft) kasa, kira, masa ve marka sıçraması olarak `office_system.gd` + `office_constants.gd`'dedir; oyuncunun gördüğü 3B ofis `scripts/ui/office/`'dedir.
3B taraf Three.js'ten dışa aktarılan GLB ve yan JSON'u yükler, günün ışığını oyun saatine bağlar, kadroyu fırınlanmış zeminde yürütür; şehir haritası ofis seçer, kurucunun toplantı yolculuğu ve davet de burada oynanır.
Dışa aktarım hattı çevrim dışıdır (`tools/office3d/`); oyun yalnız çıktılarını yükler.

## Dosyalar

Sistem (durum ve katalog):
- `scripts/systems/office_system.gd` (91): ofis durumunun tek yazarı; taşınma, peşin kira, masa sayımı, marka sıçraması, günlük kira satırı
- `scripts/systems/office_constants.gd` (108): `CATALOG` (masa, kira, marka, oda anahtarları) ve ofis insanlarının tempo sabitleri (hepsi [WORKING])

Görünüm kökü ve sahne:
- `scenes/office/OfficeView.tscn` (149): Viewport3D/SubViewport/World (Camera3D, ışıklar, SceneRoot, InkPass, People, City) + Overlay (NoticeStack, Tooltip)
- `scenes/office/shaders/office_toon.gdshader` (44), `office_ink.gdshader` (104), `office_sky.gdshader` (19): toon dolgu, mürekkep kenar geçişi, gökyüzü
- `scripts/ui/office/office_view.gd` (254): yerleşimi yükler/değiştirir, ışığı sürer, işaretçiyi kameraya/kişilere/haritaya yönlendirir, kararma ve soluklaşma

Yerleşim, malzeme, ışık, kamera:
- `scripts/ui/office/office_layout.gd` (99): yan JSON'un (`art/office3d/<id>.json`) tipli okuyucusu: noktalar, cam saatleri, asansör, harita vuruşları
- `scripts/ui/office/office_materials.gd` (105): GLB yüzeylerini toon/mürekkep görünümüne çevirir, adlı malzemeleri ışık için geri verir
- `scripts/ui/office/office_lighting.gd` (328): tasarımın gün renk senaryosu (`CS`) oyun dakikasında; masa lambaları, ekranlar, ışık lekeleri
- `scripts/ui/office/office_camera.gd` (232): ortografik izometrik kamera, sürükleme, tekerlek, `LOCKS` zoom/kaydırma kilidi, odaklama

Kişiler:
- `scripts/ui/office/office_people.gd` (763): kadro ve günün ritmi: geliş-çıkış, molalar, kuyruk, toplantılar, gece kapısı, kurucunun yolculuğu
- `scripts/ui/office/office_person.gd` (1128): bir gövde: NavigationAgent3D yürüyüşü, oturma/yatma, klip durum makinesi, eller (IK), bakış, LOD
- `scripts/ui/office/office_actor.gd` (160): kadrodan biri: karakter, koltuk, durum, kafa üstü ikon, halkalar, tıklama kutusu
- `scripts/ui/office/office_body.gd` (275): Quaternius parçalarını tek deriye birleştirir, görünümün renklerini köşe rengine yazar
- `scripts/ui/office/office_gesture.gd` (45): omurga eğimi, baş eğimi ve bakışı animasyonun üstüne bindiren SkeletonModifier3D
- `scripts/ui/office/office_venue.gd` (95): ortak mola yerleri, kimin tuttuğu, kahve ve WC kuyrukları
- `scripts/ui/office/person_bust.gd` (171): arayüz avatarları için ekran dışı büst stüdyosu (`PersonBust.texture`)

Şehir haritası, taşınma arayüzü:
- `scripts/ui/office/office_city.gd` (482): şehir haritası: bina bağlama, çipler, hover kartı, seçim, trafik, kurucunun yolu (`road`)
- `scripts/ui/office/office_map_card.gd` (158): seçili ofisin kartı (ne getirir, peşin kira, taşı düğmesi)
- `scripts/ui/office/office_hud.gd` (126): taşı düğmesi (sol alt), taşınma sayacı, taşınma ve varış toast'ı
- `scripts/ui/office/office_notice_stack.gd` (196): sağ üstte gelen kutusu önizlemesi (Frank'in satırı, keşif, bekleyen kâğıtlar, hedef listesi toast'ı)

Toplantı ve yolculuk:
- `scripts/ui/office/office_travel.gd` (179): kurucunun dış toplantıya gidiş-dönüş yolculuğu (sınıf adı yok; `OfficeView.travel`)
- `scripts/ui/office/meeting_cast.gd` (186): `meet` odasındaki kişiler: oturuş, bakış, konuşma, jest, kalem
- `scripts/ui/office/meeting_invite.gd` (198): ofiste çalan telefon, amber halka ve arama kartı (Kabul et / Ertele)

Varlıklar:
- `art/office3d/` (6 yer: home, ishani, plaza, loft, city, meet): her biri `<id>.glb` + `<id>.json`; `<id>_nav.tres` city hariç 5 yerde; 79 içe aktarıcı dokusu `<id>_<n>.png`
- `assets/art/office/`: harita kartı küçük resimleri `thumb_<id>.jpg` (4) ve kafa üstü ikonlar `icons/*.svg` (9, Lucide)
- `assets/art/people/` (q22 gövdeler 36 dosya, anims: ual1, ual2, m2m_addon): ofis kişilerinin gövdeleri ve klipleri

Çevrim dışı araçlar (yalnız yapı; `.gdignore` Godot'yu dışarıda tutar):
- `tools/office3d/README.md`, `DESIGN_SOURCE.md`: hat, tuzaklar, düğüm/malzeme/JSON sözleşmesi; tasarım kaynağı, bayt-kopya kuralı ve deltalar
- `tools/office3d/export_office.html` (38), `export_office.js` (303): Chrome'da çalışan dışa aktarım sayfası (altı yeri GLB+JSON yazar)
- `tools/office3d/neighbourhood.js` (698): home, ishani ve loft çevresine mahalle kurar (bake'ten önce)
- `tools/office3d/src/*.js` (9 modül, 3.1 bin satır): tasarımın Three.js modüllerinin kopyası (`office-sim-v12.js` 1363 en büyüğü)
- `tools/office3d/run_export.sh` (49), `serve.py` (69), `check_export.py` (193): koşucu, yerel kayıt sunucusu, çıktı sözleşme denetimi
- `tools/office3d/bake_nav.gd` (270): `<id>_nav.tres` zemin fırınlayıcı (SceneTree betiği)

Ofisi sınayan hata ayıklama araçları (kapsam dışı ama giriş noktası):
- `scripts/debug/office_crowd_probe.gd` (326): kalabalık probe'u ve `seed_staff`; `scripts/debug/office_pan_probe.gd` (398): kamera kaydırma ölçümü

## Giriş noktaları

Sistem:
- `OfficeSystem.daily_tick()` `scripts/systems/office_system.gd:76`: her günlük tikte, FinanceSystem'den önce · `scripts/autoload/time_manager.gd:409`
- `OfficeSystem.move_to(id)` `scripts/systems/office_system.gd:63`: taşınmayı başlatır, peşin kira düşer · `scripts/ui/office/office_city.gd:385`
- `OfficeSystem.can_move_to(id)` `scripts/systems/office_system.gd:57`: tek şart para, ev hedef olamaz · `scripts/ui/office/office_map_card.gd:125`
- `OfficeSystem.hiring_closed()` `scripts/systems/office_system.gd:40`: ofiste masa dolunca işe alım kapanır · `scripts/systems/hr_search_system.gd:64,100,207`
- `OfficeSystem.desks_free()` `scripts/systems/office_system.gd:35`, `desks_taken()` `:30` · `scripts/tabs/hr/hr_atlas_modal.gd:49`, `scripts/ui/office/office_map_card.gd:68,99`
- `OfficeSystem.brand_jump(id)` `scripts/systems/office_system.gd:51`, `reached()` `:46`: kademeye ilk varışın marka puanı · `scripts/ui/office/office_hud.gd:63`, `office_map_card.gd:82`
- `OfficeSystem.upfront(id)` `scripts/systems/office_system.gd:25`: peşin kira (`UPFRONT_MONTHS` × kira) · `office_map_card.gd:34`, `can_move_to`, `move_to`

Görünüm:
- `OfficeView._ready()` `scripts/ui/office/office_view.gd:49`: sahne açılışında; ışık, `cast`, `travel`, `invite` kurulur · `scenes/main/GameShell.tscn:43`, `scripts/ui/menu_backdrop.gd:50`
- `OfficeView.load_layout(id, road)` `scripts/ui/office/office_view.gd:86`: ofis/city/meet yükler, zemin ve bağlantıları kurar · `office_changed` sinyali (`:63`), `OfficeTravel._blink` (`office_travel.gd:144`)
- `OfficeView._process()` `scripts/ui/office/office_view.gd:180`: her karede `OfficeLighting.apply(TimeManager.day_minute())` ve hover
- `OfficeView.apply_graphics()` `scripts/ui/office/office_view.gd:196`: ayar, yeniden boyutlama, yeni yerleşim · `GraphicsSettings.apply_view`
- `OfficeView.set_safe_left` `:131`, `set_dimmed` `:143`, `set_veiled` `:137`: raya göre çerçeve, pencere altında soluklaşma, yolculukta örtü · `scripts/ui/components/window_layer.gd:209,238,135`
- `OfficeView.select_person` `office_view.gd:172`, `clear_selection` `:176`: dosya açılınca halka · `scripts/ui/components/window_layer.gd:109,152`
- `OfficeView.close_map()` `office_view.gd:73`, `open_map()` `:79`: karar açılınca harita kapanır · `scripts/main/main.gd:4736`
- `OfficeView.fade(dark, time)` `office_view.gd:150`: 3B görüntüyü karartır · `scripts/ui/office/office_people.gd:119` (gece kapısı)
- `OfficeLayout.load(id)` `scripts/ui/office/office_layout.gd:37`: yan JSON'u okur · `office_view.gd:89`, `menu_backdrop.gd`
- `OfficeMaterials.convert_scene()` `scripts/ui/office/office_materials.gd:26` ve `stations()` `:56` · `office_view.gd:95-96`
- `OfficeLighting.set_layout()` `scripts/ui/office/office_lighting.gd:137`, `apply(t)` `:178` · `office_view.gd:96,181`
- `OfficeCamera.fit()` `scripts/ui/office/office_camera.gd:49`, `refit()` `:75`, `frame()` `:96`, `focus()` `:112`, `handle_input()` `:126` · `office_view.gd:55,220-221`

Kişiler:
- `OfficePeople.set_layout(layout, view)` `scripts/ui/office/office_people.gd:173`: yeni yerleşimde kadro donar, zemin hazır olunca yerleşir · `office_view.gd:119`
- `OfficePeople._on_map_changed()` `scripts/ui/office/office_people.gd:722`: zemin navigasyon haritasına girince `_sync(true)` ile herkesi yerleştirir · `NavigationServer3D.map_changed`
- `OfficePeople._sync(cut)` `scripts/ui/office/office_people.gd:598`: kadro (CharacterRegistry) ile aktörleri, masaları ve hayaletleri eşler · `character_added/removed` (`:83-84`)
- `OfficePeople.office_empty()` `scripts/ui/office/office_people.gd:110`: gece kapısı · `TimeManager.register_night_gate` (`:100`, `time_manager.gd:264`)
- `OfficePeople.pick()` `:203`, `hover()` `:208`, `select()` `:216` · `office_view.gd:185,228`
- `OfficePeople.send_founder_out()` `:125`, `founder_back()` `:138`, `seat_founder_now()` `:147`, `nearest_to_founder()` `:161` · `scripts/ui/office/office_travel.gd:69,104,107`
- `OfficePerson.setup(look)` `scripts/ui/office/office_person.gd:253`, `place()` `:335`, `go_to()` `:372`: gövde kurulur, yerleştirilir, yürütülür · `office_actor.gd:88`, `menu_backdrop.gd:_stand_figure`
- `OfficeActor.setup_actor(c)` `scripts/ui/office/office_actor.gd:84`, `decorate(icon_size)` `:104` · `office_people.gd:_sync`, `_process`
- `OfficeBody.build(look)` `scripts/ui/office/office_body.gd:42`, `mesh_of()` `:68` · `office_person.gd:257`, `person_bust.gd`
- `PersonBust.texture(look, px)` `scripts/ui/office/person_bust.gd:38`: arayüz avatarı için büst · `scripts/theme/ui_factory.gd:107`, `scripts/tabs/events/mail_pane.gd:276`
- `PersonBust.drawing()` `scripts/ui/office/person_bust.gd:53`: verilmiş bir portre hâlâ çizilmeyi bekliyor mu (salt okunur) · `live:a4_*` shot'ı yüzler bitmeden kareyi kaydetmez (`main.gd` `_product_a4_ready`)

Harita, toplantı, yolculuk:
- `OfficeCity.set_layout()` `scripts/ui/office/office_city.gd:105`: harita yerleşimi yüklenince binaları bağlar, HUD'u kurar · `office_view.gd:121`
- `OfficeCity.open()` `:184`, `close()` `:198`, `pick()` `:156`, `hover()` `:161`, `road(out, tower_label)` `:130` · `office_hud.gd` (`move_pressed`), `office_view.gd`, `office_travel.gd`
- `OfficeTravel.travel_out()` `scripts/ui/office/office_travel.gd:65`, `travel_home()` `:95` · `scripts/main/main.gd:4951,4972` (`_leave_office` `:4708`, `_return_to_office` `:4729`)
- `MeetingCast.stage()` `scripts/ui/office/meeting_cast.gd:58`, `walk_in()` `:82`, `walk_out()` `:89`, `frame_table()` `:75`, `look` `:98`, `post` `:104`, `speak` `:117`, `gesture` `:126`
  · `scripts/ui/office/office_travel.gd:85-97`, `scripts/ui/meeting/meeting_panel.gd:342`, `scripts/main/main.gd:4404`
- `MeetingInvite.ring(spec)` `scripts/ui/office/meeting_invite.gd:96`, `stop()` `:120`, `can_ring()` `:133` · `scripts/main/main.gd:4899` (`_ring_call` `:4659`)
- `OfficeNoticeStack.dock_below(rect)` `scripts/ui/office/office_notice_stack.gd:63`: BuildHUD'un bittiği yerin altına yerleşir · `scripts/ui/components/build_hud_panel.gd`
- `bake_nav.gd _initialize()` `tools/office3d/bake_nav.gd:35`: her yerin zemini; `godot --headless -s res://tools/office3d/bake_nav.gd [-- id ...]`

## Sinyaller

EventBus (ofis alanı):
- `office_move_started(office_id, arrival_day)`: yayan `scripts/systems/office_system.gd:69` (tanım `event_bus.gd:280`) · dinleyen `scripts/ui/office/office_hud.gd:61`
- `office_changed(office_id)`: yayan `scripts/systems/office_system.gd:85` (tanım `event_bus.gd:281`) · dinleyenler `office_hud.gd:62`, `office_view.gd:63`, `scripts/debug/endgame_smoke.gd`
- `night_skipped`: yayan `scripts/autoload/time_manager.gd:190` · ofis tarafı dinleyenler `office_people.gd:86`, `office_view.gd:64` (kararma 08:00 ışığına açılır)
- Ofisin dinlediği öbürleri: `character_added/removed`, `assignment_changed`, `sprint_started`, `clock_batch_ended` (`office_people.gd:83-93`); `day_tick_completed`, `language_changed`, `palette_changed` (`office_city.gd:100-102`)

Düğüm sinyalleri:
- `clicked(screen_pos)`: yayan `scripts/ui/office/office_camera.gd:138` (tanım `:8`) · dinleyen `office_view.gd:62`
- `move_pressed`: yayan `office_hud.gd:49` (tanım `:10`) ve `office_map_card.gd:128` (tanım `:9`) · dinleyen `office_city.gd:112,379`
- `cancel_pressed`: yayan `scripts/ui/office/office_map_card.gd:113` · dinleyen `office_city.gd:378`
- `road_done`: yayan `scripts/ui/office/office_city.gd:152` · `await` eden `office_travel.gd:82,102`
- `founder_arrived`: yayan `scripts/ui/office/office_people.gd:235` · `await` eden `office_travel.gd:75`
- `founder_settled`: yayan `scripts/ui/office/office_people.gd:142,239,658` · `office_travel.gd:106`, `scripts/main/main.gd:2096` (probe)
- `founder_seated`: yayan `scripts/ui/office/meeting_cast.gd:152` · `office_travel.gd:88`, `scripts/main/main.gd:1997`
- `founder_out`: yayan `scripts/ui/office/meeting_cast.gd:155` · `office_travel.gd:98`
- `accepted` / `postponed`: yayan `scripts/ui/office/meeting_invite.gd:191` / `:198` · dinleyen `scripts/main/main.gd:4897,4898`

## Durum ve veri

- `GameState.office_id` (varsayılan `"home"`), `office_move_to` (`""`), `office_move_day` (`-1`): `scripts/autoload/game_state.gd:305-307`; sıfırlama `:890-892` (`initialize_run` içinde); tek yazar `OfficeSystem`
- `GameState` bayrağı `offices_reached` (dizi): `OfficeSystem.FLAG_REACHED` `scripts/systems/office_system.gd:9`; `reached()` `:46` bayraksız eski kayıtta bulunulan ofisi (Ev'de boş) varılmış sayar
- `OfficeConstants.CATALOG` `scripts/systems/office_constants.gd:17`: home 1 masa 0 kira; ishani 13 / 4.000 / marka 3; plaza 38 / 8.000 / 6; loft 70 / 18.000 / 10 (kurucu bir masa tutar)
- `OfficeConstants.MOVE_WEEKS := 1` `:10`, `UPFRONT_MONTHS := 2` `:12`: taşınma süresi ve peşin kira; `MOVE_WEEKS` metni `OFFICE_MAP_SUB` satırında yazılı
- Tempo sabitleri `OfficeConstants` `:64-103`: `PACE_MINUTES` (sahibin), `AVOID_MAX_K`, `ANIM_LOOP_MAX`, `TRIP_K`, geliş/çıkış sapmaları, mola ağırlıkları, öğle penceresi, `ALL_HANDS_MINUTE`, `NIGHT_WAIT_S`; halka renkleri `:107-108`
- Kayıt: `SaveManager.SCHEMA_VERSION` 19 (`scripts/autoload/save_manager.gd:16`); `_migrate_13` `:654` eski kayda `office_id` yazar (cheque alınmışsa `ishani`); `office_move_day` gün damgasıdır, `:676` listesinde yeniden tabanlanır
- Mali iz: `FinanceSystem.apply_one_time_cost(.., "office_upfront")` `office_system.gd:66`; kira `FinanceSystem.set_burn_category("office", rent)` `:91`
- Görünüm kaydı: `Character.look` (kadro), `GameState.issued_looks` (`game_state.gd:203`, eşsizlik) ve `CharacterRegistry._stamp_look` (`character_registry.gd:526`); `LookSystem` / `PeopleParts` kapsam dışı
- Yan JSON alanları (`art/office3d/<id>.json`): `bounds`, `maxN`, `spots`, `meetRooms`, `elevNear`, `elevPanels`, `panes`, `glows`, `mapHits`, `meetHit`, `table`, `pen`, `lanes`,
  `thumbTargets`, `materials` (tam tablo `tools/office3d/README.md`)
- `maxN` katalogla eştir: ishani 12, plaza 37, loft 69, home 1 (çalışan masası; `spots.desk` kurucu dahil); kodda masa sayısı yoktur, `OfficePeople._sync` JSON'dan okur (`:598`)
- Fırınlanmış zemin `art/office3d/<id>_nav.tres` (meta `links`: merdiven ve kapı bağlantıları); GLB boyları: loft 38 MB, plaza 18, ishani 8.8, meet 5.9, home 5.4, city 4.4
- Gruplar (sözleşme): `office_view` (kök, `OfficeView.tscn:40`), `office_overlays` (`set_map_open` alanlar), `notice_stack`, `window_layer`, `toast`, `game_shell`
- Sabitler: `OfficeLayout.AWAY := ["city", "meet"]` `office_layout.gd:10` (kadrosuz yerler); `OfficeCamera.LOCKS` `office_camera.gd:24`; `OfficePerson.LOD` `office_person.gd:144`; `OfficeActor.ICONS` `office_actor.gd:9`

## Metin anahtarları

- `OFFICE_NAME_*`, `OFFICE_DESC_*`, `OFFICE_TIER_*`, `OFFICE_ROOM_*` (kartın oda listesi): `office_constants.gd` katalogu; `office_map_card.gd:48,79` okur; `OFFICE_NAME_*` ayrıca `first_week_doc.gd`, `origin_traits_step.gd`
- `OFFICE_CARD_*`, `OFFICE_STATUS_*`, `OFFICE_REQ_*`, `OFFICE_MOVE_*`: `office_map_card.gd` (kart); `OFFICE_REQ_*` ayrıca `scripts/main/main.gd`
- `OFFICE_MAP_*`, `OFFICE_HOVER_*`, `OFFICE_CHIP_*`: `office_city.gd` (başlık, yükleniyor, hover kartı, çipler)
- `OFFICE_MOVE_BTN/TIP`, `OFFICE_MOVING_*`, `OFFICE_TOAST_*`: `office_hud.gd` (düğme, sayaç, toast; marka satırı `OFFICE_TOAST_BRAND`)
- `OFFICE_ACT_*` (14 durum) ve `OFFICE_TOOLTIP`: `office_actor.gd` (`status_key()` anahtarı durum adından kurar) ve `office_people.gd:212`; `OFFICE_ACT_SLEEP/PLAN` ayrıca `scripts/systems/hr_system.gd:223,232`
- `OFFICE_HINT_*`: `office_notice_stack.gd` (Boşluk ipucu); `FIN_MENTOR_*` aynı dosyada Frank satırı, `GOAL_TOAST` hedef listesi toast'ı
- `MEETING_INVITE_*`, `MEETING_ACCEPT_*`, `MEETING_POSTPONE(D)_*`: `meeting_invite.gd` (ve `scripts/main/main.gd`); `MEETING_BACK_ASK` ve `TRIP_SKIP_HINT`: `office_travel.gd:123,132`
- `FRANK_OFFICE_*` (3): `data/events/cards/funding/frank_office_move.json` kartı (taşınma önerisi, ofis tarafı değil olay tarafı)

## Testler

Smoke (`bash tools/smoke_run.sh <vaka>`; bayrak `--` ardına konmaz):
- `office_move_gates_and_save` `scripts/debug/endgame_smoke.gd:20153`: para kapısı, peşin bir kez, kira varış haftasında, kayıt turu
- `desk_cap_blocks_hire` `endgame_smoke.gd:20249`: evde sınır yok, ofiste masa dolunca arama kapanır, büyük ofiste açılır
- `office_brand_once` `endgame_smoke.gd:20323`: ilk varışta +3/+6/+10, ikincide ve aşağı taşınmada 0, kayıttan sonra tek sefer
- `office_pace_linear` `endgame_smoke.gd:8351`: `k` oyun hızıyla doğrusal, tavansız
- `look_registry_unique_and_saved` `endgame_smoke.gd:10356`: görünümler eşsiz, kayıtta korunur
- Kişiler, ışık, kamera, harita smoke'ta YOK (başsız çalışmada kişiler çizilmez); arayüz doğrulaması görsel kabulledir (CLAUDE.md §11)

Pencereli görsel ve ölçüm (bayrak `main.gd` tablosunda, `:271-276`; PNG `%APPDATA%\Godot\app_userdata\Project Unicorn\`):
- `--office-shot=<home|ishani|plaza|loft|city|meet>:<saat>[:full|card|crowd40|founders|nav|crown|cast|toast|...]` `scripts/main/main.gd:1760`
- `--office-shot ... --pan=<adım;...>`, `--pan-set`, `--pan-gpu`: kamera kaydırma ve GPU süresi (`scripts/debug/office_pan_probe.gd`, `main.gd:1886`)
- `--office-crowd-probe=<ofis>:<kişi>:<hız>` `main.gd:2304`: sıçrama, takılma, kapı, kuyruk, toplantı, gece kapısı (`CROWD` satırları)
- `--travel-shot=<ofis>[:vc|:night]` `main.gd:2030`, `--invite-shot=<ring|card|vc|...>` `main.gd:2112`, `--day-shot=<ofis>:<hız>` `main.gd:2266`
- Dışa aktarım denetimi: `python tools/office3d/check_export.py [id ...]` (sözleşme ihlalinde çıkış 1); zemin: `bake_nav.gd` (giriş zeminde değilse çıkış 1)
- Dışa aktarım: `bash tools/office3d/run_export.sh [durum_dizini] [sorgu]` (ağ ve ön plan Chrome gerekir); sorgu `only=<id,..>`, `thumbs=0`

## Dikkat

- Başsız (headless) koşuda `OfficePeople` kimseyi çizmez ve `office_empty()` hemen `true` döner (`office_people.gd:110,762`): smoke ve `--run-log` ofis hareketini hiç sınamaz
- `office_empty()` yan etkilidir: gece kapısı sorulurken ilk geçişte görüntüyü karartmaya başlar (`office_people.gd:119`); kapıyı salt-okunur sanmayın
- `OfficeSystem.daily_tick` sırası kritik: `OfficeSystem` Finans'tan önce çalışır (`time_manager.gd:409-410`); varış haftası yeni kirayı ödemelidir ve `office.current` seam'i bugünün ofisini okur
- `daily_tick` içinde `offices_reached` bayrağı `office_id` değişmeden SABİTLENİR (`office_system.gd:80`); marka sıçraması `office_changed` yayıldıktan SONRA alınır, dinleyiciler onu gelecek diye okur (`office_hud.gd:63`)
- Katalog masa sayısı ile JSON `maxN` eşleşmek zorundadır (13 = 12 + kurucu); dışa aktarım masa sayısını değiştirirse `CATALOG`, HARITA ve CLAUDE.md §Ofis birlikte güncellenir
- Ev'de masa sınırı yoktur (`hiring_closed` Ev'de `false`, `office_system.gd:41`) ve yalnız kurucu çizilir; ekip masadan büyükken taşınmak serbesttir (herkes gelir)
- Her GLB/JSON dışa aktarımından sonra `<id>_nav.tres` yeniden fırınlanır; eski zemin kişileri eski duvarların arasından yürütür. Şehir fırınlanmaz (kimse yürümez)
- Dışa aktarım sırası: run_export → check_export → `--headless --import` → ısınma koşusu → kapı. `--import` sonraki ilk koşuyu class-cache hatasıyla düşürebilir (hafıza: godot-import-cache-gotchas)
- GLB içine gömülü dokular koşudan koşuya bayt değiştirir; yalnız `only=` olmadan alınan TAM koşu commit'lenir, kaynağı değişmeyen yerin GLB'si repodakiyle aynı çıkmalıdır, yoksa koşu yinelenir
- `tools/office3d/src/` tasarımın bayt-bayt kopyasıdır; değişebilen tek şey `DESIGN_SOURCE.md` tablosundaki deltalardır (`tools/office3d` işaretli bloklar). Geometriye elle dokunulmaz
- Godot düğümlere ve malzemelere ADLA bağlanır (`station_<i>_lamp`, `pane_<i>`, `frame_<id>`, `pin`, `ferry`...); içe aktarma ipucu sonekleri (`_col`, `_noimp`, `_occ`) adlarda yasak (README "Bağlama sözleşmesi")
- `OfficeCamera.LOCKS` (`office_camera.gd:24`) mahallenin kapsadığı kareden ölçülmüştür; `neighbourhood.js` ya da builder ölçüleri değişirse yeniden ölçülmeli, yoksa kamera mahalle dışını gösterir
- `MenuBackdrop` `OfficeView.tscn`'in düğüm yollarına (`Viewport3D/SubViewport`, `World/People`, `World/City`, `Camera3D`, `SceneRoot`) sabit bağlıdır (`menu_backdrop.gd:52-56,117`); adı değiştirmek menüyü düşürür
- `OfficePerson` statik durum tutar (`_links`, `_lanes`, `_waiting`, `_people`; `office_person.gd:173-185`); `set_links` her yerleşimde sıfırlar, menü figürü ve `MeetingCast` aynı statikleri paylaşır
- `OfficeActor.status_key()` anahtarı durum adından kurar (`"OFFICE_ACT_" + status.to_upper()`): yeni durum = CSV anahtarı (TR+EN) + `ICONS` girdisi (`office_actor.gd:9`) + `OfficePeople.ERRANDS`/`JOB_WORK`
- `PersonBust.texture` başsız koşuda `null` döner (`person_bust.gd:38`); çağıranlar baş harf yedeğine düşer (`UiFactory.make_avatar`). Stüdyo karede tek portre çizer, önbellek görünüm imzası + piksele göredir
- Kurucu ve Frank portreleri `assets/art/portraits/`'e `tools/people/bake_portraits.gd` ile pişirilir (pencereli); görünüş, kadraj ya da ışık değişince yeniden üretilir
- Kişi pozları ekranda küçüldükçe seyrekleşir (`LOD`, `office_person.gd:144`); ekran dışı olanlar `OFF_SCREEN` karede bir poz alır. Bir kareyi ölçerken `full_rate` ya da yakın kamerayı unutmayın
- `OfficeConstants` içindeki sayılar sahibin onayını bekler ([WORKING]): `PACE_MINUTES` hariç ve İş hanı'nın masası hariç; sahibin onayı olmadan yeni sayı sabitlenmez

## Bir değişiklik yaparken

- Katalog (masa, kira, marka, peşin) değişirse: `office_constants.gd` + `art/office3d/<id>.json` `maxN` (yeniden dışa aktarım) + `OFFICE_DESC_*`/`OFFICE_MAP_SUB` metinleri + CLAUDE.md §Ofis + HARITA "Ofis (3B)"
  Okuyanlar `hr_atlas_modal.gd:49`, `finance_ozet_view.gd:396`; smoke: üç ofis vakası (`office_move_gates_and_save`, `desk_cap_blocks_hire`, `office_brand_once`)
- Yeni ofis kademesi eklenirse: `CATALOG`; `tools/office3d/export_office.js` (builder, `setTier`) + `bake_nav.gd` `OFFICES`; `OfficeCamera.LOCKS`; `OFFICE_NAME/TIER/DESC/ROOM_*` (TR+EN); `thumb_<id>.jpg`
  Ayrıca `city.json` `mapHits`, seam `office.current` (`scripts/events/seams/seams_world.gd:135`) ve menü plakaları
- GLB/JSON yeniden üretilirse: `run_export.sh` → `check_export.py` → `--import` + ısınma → `bake_nav.gd` → `--office-shot=<ofis>:<saat>[:nav]` ile bak; `--office-shot=<ofis>:<saat>:crowd40` kalabalığı görsel doğrular
- Kişiye yeni iş/durum/mola eklenirse: `OfficePeople.JOB_WORK`, `ERRANDS`, `WORK_BODY`, `SPRINT_WORK` + `OfficeActor.ICONS` ve `assets/art/office/icons/` + `OFFICE_ACT_*` CSV
  Poz için `OfficePerson.SEAT_HANDS`/`STAND_ACTS`; sına: `--office-crowd-probe`
- Yeni klip/poz için: `OfficePerson.LIBS`, `LOOPED`, `_state_machine()` (`office_person.gd:1042`); gövde ya da renk için `OfficeBody` + `LookSystem`/`PeopleParts` + `PersonBust` önbelleği + `tools/people/bake_portraits.gd`
- Işık ya da gün renkleri: `OfficeLighting.CS` `office_lighting.gd:13` tasarım kaynağıyla (`office-sim-v12.js` `CS`) eş tutulur; malzeme rolleri `OfficeMaterials.EMITTERS`; gece görünümü `office_sky.gdshader` / `office_ink.gdshader`
- Toplantı/yolculuk akışı: `office_travel.gd` + `meeting_cast.gd` + `meeting_invite.gd` + `scripts/main/main.gd` (`_leave_office` `:4708`, `_return_to_office` `:4729`, `_ring_call` `:4659`)
  Ayrıca `scripts/ui/meeting/meeting_panel.gd`; sına: `--travel-shot` ve `--invite-shot`
- `OfficeView.tscn` düğüm adı/yapısı değişirse: `menu_backdrop.gd`, `window_layer.gd:56` (`$OfficeView`), `office_pan_probe.gd`, `main.gd` yol dizeleri (`Viewport3D/SubViewport/World/City` `main.gd:1789`) ve grup adları birlikte güncellenir
- Ofis durumu alanı eklenirse: `GameState` alanı + `initialize_run` sıfırlaması (`game_state.gd:890`) + kayıt göçü (`save_manager.gd`, şema sürümü) + yalnız `OfficeSystem` yazar; `office_move_gates_and_save` vakası kayıt turunu sınar

## HARITA'da bayat

- `docs/HARITA.md:129` Ofis: gün tohumu `OfficeConstants.SALT_DAY` denir; sabit kodda `SalesConstants.SALT_DAY` (`scripts/systems/sales_constants.gd:282`), `OfficePeople` onu oradan okur (`office_people.gd:548`)
- `docs/HARITA.md:127` Ofis: `OfficeView.current_layout` denir; kodda böyle üye yok, yerleşim `OfficeView.layout` alanındadır (`office_view.gd:31`)
- Bayat değil, eksik: `docs/HARITA.md:403` dışa aktarım çıktılarını `home, ishani, plaza, loft, city` sayar; `meet` (görüşme odası, `art/office3d/meet.*`) listede yok, README ve `export_office.js:31` altı yeri yazar
