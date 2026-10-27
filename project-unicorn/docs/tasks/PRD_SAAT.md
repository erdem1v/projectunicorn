# PRD · SAAT: üç basamaklı hız, tek duraklatma kuralı, akıcı saat

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_SAAT.md dosyasını oku ve uygula."
**Durum:** sahip kararları onaylı (Erdem, 2026-10-10); açık sorular yardımcı yönetmen hükümleriyle kapandı (2026-10-10:
ortak düzeltmeler, A1–A16, B-D1/B-D2/B-D5, C-1/C-10/C-11, çapraz denetim U1/U2/U4/U9/U11, son hükümler F1/F2/F8–F11).
Açık kalanlar "Sahibe bırakılan kararlar"da: A10 sabitleri, §4.4 TR/EN tablosu (§4.7 dahil), sahipsiz parçalar.
**Tek cümle:** saat yalnız oyuncunun elinde akar; dört basamak üçe iner; saat ve hafta çubuğu akıcı okunur; gece ve
saatlik takılmalar kaldırılır.
**Çıktı:** main'e 10 küçük commit (+ koşullu K9b ve §4.7, push yok), her biri kendi kapısıyla; `--tick-probe` ölçüm aracı; Erdem'e ✅/⚠️/❌
listesi, ölçüm satırları ve 1920×1080 ekran görüntüleri.

Kod kanıtı HEAD `0fe77fc` üzerindedir (F8, §1 "Canlı ağaç"). R1 (duraklatma denetimi) ve R4 (kare maliyeti) atıfları yalnız
gerekçedir, repoda yoktur. Bağlayıcı hükümler: yardımcı yönetmen 2026-10-10 (A1–A16, çapraz denetim eki U1–U11, son
hükümler F1–F11). Sayılar R4'ün başsız CPU ölçümleridir (yüklü makine, aralık).

---

## 0. Sahip kararları ve bulgular

| # | Bulgu (kanıt) | Gereksinim |
|---|---|---|
| S1 | Merdiven beş giriş: `time_model.gd:9` `[0.0, 2.5, 1.25, 2.5 / 3.0, 0.625]`; 4× düğmesi `TopBar.tscn:210`, `top_bar.gd:71`; tuş `game_shell.gd:79` | §2: 1×/2×/3×, 4× her yerden kalkar |
| S2 | Sistem kodu saati 12 yerden yeniden başlatıyor: `main.gd:2857` (`_restore_speed`, 9 çağrı: 2916, 2948, 3083, 3194, 3213, 3242, 3263, 3399, 3449), `main.gd:3105`, `:3130`, `product_tab.gd:257`; `resume_if_paused` (`time_manager.gd:322-324`) üretimde çağrılmıyor | §3: Model S, yalnız oyuncu girdisi hız > 0 yazar |
| S3 | Sürüm notu tutuşunda tuş sessizce yutulur (`time_manager.gd:297-298`); geri bildirim yalnız karar kartında (`game_shell.gd:109-115`); TopBar tutuşun nedenini söylemez, duraklı hâli göstermez | §4: `HOLD_LABELS`, "DURDU" satırı, genel geri bildirim |
| S4 | Pencere odağı kaybolunca yalnız ses kısılır (`audio_manager.gd:144`), saat akar | §5: odak kaybında duraklat, ayarlanabilir, varsayılan açık |
| S5 | Saat yazısı ve hafta çubuğu tam saatten çizilir: `top_bar.gd:281` `"%02d:00"`, `:323` `clampf(GameState.current_hour…)`; ışık ve kişiler zaten dakikadan akar (`office_view.gd:174-175`) | §6: `HH:MM` 5 dakikalık, çubuk ondalık saatten |
| S6 | Saatlik adımın maliyeti UI yayılımı: B2C saatte 3 tam `TopBar._refresh` (`top_bar.gd:88-104`); Finans açıkken gizli Yatırım sayfası her MRR değişiminde yeniden kurulur (`hunt_tab.gd:74-75`, 10–14 ms); Özet 10–13,5 ms (`finance_ozet_view.gd:59-61,95-98`); Piyasa haftada 75–126 ms senkron (`piyasa_tab.gd:82-85`) | §7: birleştirme ve görünürlük kapısı |
| S7 | Gece karesi 60–165 ms; kesilecek kimse yoksa kararma yok ve toplu adım aydınlık görünümde koşar (`office_people.gd:109-111`); ilk saatlik tik 64 ms (katalog tembel yükü); otomatik kayıt 14–21 ms ana iş parçacığında (`save_manager.gd:195`) | §8: hep kararma, ısınma, kayıt yazımı işçi iş parçacığında |
| S8 | Saat sınırı ve gece karesini ölçen araç yok; `--office-crowd-probe` bu kareleri bilerek atar (`office_crowd_probe.gd:104-107,112-114`) | §9: `--tick-probe` |
| S9 | Tutuş altında görüşme açılabiliyor ve bedava: `_can_step` tutuşta adım atmaz (`time_manager.gd:142-143`), oturumun saatleri koşmaz; giriş yalnız kart kapısına bakar (`main.gd:3028` `active_id`, `:3065` ve `:3424` `_gate_shut`); seed pitch'i (`hunt_tab.gd:225` → `seed_round_system.gd:108-109`) hakkı harcar ve görüşmeyi açar | §4.5 (A11): her tutuşta giriş kapalı, neden görünür |
| S10 | Boş `systems.time` bloğu 1×'te koşarak yüklenir: `reset()` hız 1, ağaç açık (`time_manager.gd:246-256`); `from_dict` boş blokta döner (`:270-271`); `_restore_systems` boş `systems`'te hiç çağırmaz (`save_manager.gd:319-322`) | §3.5 (A7): yükleme her zaman duraklı |
| S11 | Oturumdan dönüşte `travel_home` kurucuyu kapıya koyar ve hemen döner (`office_travel.gd:94-105`); yürüyüş yalnız saat koştuğu için görünür (`main.gd:3130` emit; `office_people.gd:206` `_k = _pace(current_speed)`) | §3.6 (A4): masaya kadar ağaç koşar |

**Onaylı (Erdem, 2026-10-10):** `SECONDS_PER_HOUR` `[0.0, 2.5, 1.25, 2.5 / 3.0]` (hafta 22,5 / 11,25 / 7,5 sn); Model S
(§3: sistem yüzeyi yalnız durdurur); odak kaybında duraklat, `pause_unfocused` varsayılan açık (§5); `CLOCK_STEP_MIN` 5
oyun dakikası; gece adımından önce hep kararma, `CUT_FADE_S` değişmez; otomatik kayıt 00:00 adımında yakalanır, işçide
yazılır, `AUTOSAVE_MIN_REAL_SECONDS` 10 değişmez; kapılar gece karesi ≤ 60 ms, saatlik adım ≤ 3 ms, Finans açık B2C saat
karesi ≤ 8 ms ve sonraki kare ≤ 16,7 ms (A8); dönüşte masaya kadar ağaç koşar (A4); tutuşta görüşme kapalı (A11).

**Onay bekliyor (SAHİBE):** §4.4 TR/EN tablosu, `SYS_RESUME` "Oyuna dön / Back to game" dahil (F11; onaydan sonra
uygulanır, §4.7). A10: `PAUSE_BLINK_S` 0,8 sn (alfa 1,0 ↔ 0,45), onaya kadar uygulanmaz (§4.3, CLAUDE §3); ilk saatlik
adım ≤ 16,7 ms, onaya kadar ölçülür ve raporlanır, kapı değil.

## 0b · Senaryo pürüzleri

Kaynak `play/SCENARIO_SNAGS.md`, task sütunu "SAAT"; kimlikler o dosyanın (§0'ın S1–S11'i değil), kanıt `0fe77fc`'de
yeniden doğrulandı (F8). Kapsam dışı: S45 (`ONARIM_1_ADAYLARI` §1, mini task B); S20, S43 yıldızlı ve aynı listede.

| id | sev | başlık | kanıt | karşılayan gereksinim |
|---|---|---|---|---|
| S03 | major | Kapanış gecesi kart sürüm notunun yerini alır, tutuş düşer, sonraki sprint görünmeden başlar (task "SPRINT (touches SAAT hold)") | Kart penceresi Ürün'ü kapatınca `on_page_closing` sürüm notu tutuşunu bırakır (`product_tab.gd:111-114`); `_open_after_gate` yalnız goto_tab'ı ve dönüm kâğıdını açar (`main.gd:2921-2931`); sürüm kipinde ertesi tik liderin planıyla başlar (`sprint_system.gd:37-39,673-684`) | **§3.7 (F2): kapı çözülünce Ürün yeniden açılır** (B buna dayanır); §3 Model S (bırakma saati başlatmaz), §3.1 sessiz `hold_clock` (U1), §3.3 `:114` silinir, §4.1 `sprint_plan` sırası; tutuşun moda bağlanması B'nin (PRD_SPRINT S7), ölen sayfa (`Inbox.show`) C'nin (F5) |
| S30 | major | Mesai bitişine inen oturumun dönüşünde duraklı oyuncuya gece ve haftalık tik koşuyor | `_return_to_office` dondurup `emit(last_running_speed)` der (`main.gd:3129-3130`); gecede `_advance_real` donmaya bakmaz, geceyi yalnız hız 0 bekletir (`time_manager.gd:87-105`, `:102-103`); out1 T2 `freezes=[travel]` altında gün 1→2 | §3.2 (`3129-3130` satırı) + §3.6 gece dönüşü; S30 kabulü §3.6'ya eklendi |
| S39 | minor | Görüşme zili tutuş değil ve sessizce düşüyor | Zil düz `emit(0)` (`main.gd:3041-3043`); Ertele tostu "Telefon çalmaya devam ediyor." (`strings.csv:1794`), kesimde `_end_call` sessiz (`main.gd:2995-2996`, `:3058-3061`); VC'de düşen çağrı cezasız yeniden çalar (`vc_pitch_system.gd:756-765`) | YENİ → §4.6 satış düşüşü tostu (F1 onaylı; VC dalı sessiz kalır); VC cezası ve "Gelen arama" çerçevesi sahipsiz → Sahibe bırakılan kararlar |
| S42 | minor | Saat durumu arayüzü tutarsız: yutulan tuş, başlatmayan "Devam", kapıda donan kurucu, bayat ofis kartı | Sürüm notu tutuşu tuşu sessiz yutar (`time_manager.gd:297-298`), tuşlar yalnız kapı/görüşmede pasif (`top_bar.gd:242-243`); "Devam" önceki 0 hızı geri verir (`main.gd:3254,3263`); ofis kartı yalnız kurulurken okur (`office_map_card.gd:29-33`) | tuş: §4.2/§4.3; kurucu: §3.6; "Devam": YENİ → §4.7 (F11, TR/EN onay bekliyor); ofis kartı → Onarım 1, D grubu (F1; Sahibe bırakılan kararlar) |
| S52 | minor | "Her hafta" özet her tik saati durdurur ve Olaylar'ı açar, satır bunu söylemez | `_on_summary_ready` → `_open_note` hız 0 + `INBOX.show` (`main.gd:3340-3341`, `:2954-2961`); haftalıkta her tik `due` (`summary_system.gd:62-64`); satırın notu yok (`settings_modal.gd:191-194`) | YENİ → §5.1 (`SET_SUMMARY_FREQ_NOTE`, A1'in 5. anahtarı, F10) |

## 1. Kurallar

- `CLAUDE.md` bağlayıcıdır: §3 (main, push yok, sabit ve TR metin onayı), §5, §7, §8 (yerini alan eskisini siler), §9
  (commit öncesi ayrı ajan incelemesi), §10 (yeni smoke yalnız çekirdek mantık), §11 (görsel kabul, en çok 2 tur), §12.
- **Canlı ağaç.** Grafik işi `0fe77fc`'de commit'lendi ve ağaç temizlendi; bu düzeltme turunun sonunda yeniden yabancı,
  commit'lenmemiş iş belirdi (`office_camera.gd`, `office_view.gd:214`; A'nın dosyaları değil, `office_view.gd:174-175` kaymadı). Satır
  numaraları `0fe77fc`'ye göredir; o commit'in kaydırdığı `main.gd` (`:1539` sonrası), `settings.gd`, `settings_modal.gd`,
  `SettingsModal.tscn`, `strings.csv`, `office_view.gd` ve HARITA (43-56 ve sonrası) atıfları yeniden doğrulandı (F8); HEAD
  ilerlediyse önce yeniden oku. Kural kalır: işe `git status --short` ile başla; kirli dosyada yalnız kendi hunk'ların
  (`git apply --cached`), kapılar `git checkout-index` ağacında; `git checkout -- <yol>`, `reset --hard`, `stash`, `clean` yasak.
  Alt ajanlar Opus ya da Sonnet. OS düzeyinde fare/klavye yok; pencereli koşular sırayla, kendi `APPDATA`'sında, önce `tasklist | grep -i godot`.
- Dosya sahipliği: "Dokunulacak dosyalar". Başka dosya gerekirse dur ve raporla.
- **Sıra kesin: A → B → C**; A önce iner. Paylaşılan dosyalar (hükümler §0):
  - `main.gd`: saat, hız, tutuş, çağrı (F1), kapı sonrası (F2) ve ısınma yolları A'nın; B ve C onlara dokunmaz. Her task harness kolunu (bayrak tablosu,
    `_run_*`) AYRI hunk ekler; B (B-D1) ve C (C-1) A'nın commit'inden sonra. `_run_tempo_probe`'un tohum satırları
    (`main.gd:413-422`) K2'de `_seed_tempo_state()`'e taşınır; B-D1'in tempo başlatma satırı ve `:421-422` yorumunun
    yeni yeri orasıdır (B, A'dan sonra ayrı hunk).
  - `endgame_smoke.gd`: A yalnız §10 vakaları; A başka task'ın vakasını kırarsa A düzeltir ve raporlar.
  - `finance_ozet_view.gd`: A sinyal tablosu (`:57-85`) ve tek alıcısı `_on_state_changed` (`:95-98`; sinyal birleştirmenin
    parçası, Ek hükmüyle onaylı). C yalnız `_refresh_goal` (`:294-325`), A'dan sonra. `localization/strings.csv`: A yalnız
    kendi anahtarları (A1'in beşi, §5.1'inki dahil, F10; onaylanırsa §4.7'nin değeri, F11), bayt-span.
  - A'nın dosyalarına sonra gelen hunk'lar: B `HOLD_LABELS` sonuna `"sprint_plan"` (K4 sonrası), `game_shell.gd _ready`'ye
    `SprintSystem.sync_plan_hold()` (B-D2; kendi bekçisiyle, U1), `tick_probe.gd` tutuş kolu (U2). C `top_bar.gd`'de
    Sıradaki dalı (C-11, C-19), `_refresh_brand`, `_ready`'ye 4 bağlantı (`sprint_planned`, `sprint_started`,
    `version_shipped`, `customer_added`; K7'nin `_queue_refresh`'ine), hepsi K10 sonrası (U9). C'nin Boşluk ipucu DURDU
    satırıyla birlikte yaşar; tıklanmaz, `request_speed()` çağırmaz, hız yazmaz (C-10, U4).
  - Belgeler: `docs/HARITA.md:85` (A: TopBar durum satırı, `blink_held`; C: ray kilidi, marka, Sıradaki) ve
    `GDDs/GUNCELLEMELER.md` ch12 (A: `:380`'deki TopBar cümlesi, U11 metni; C o satıra dokunmaz, yeni §5 paragrafı). Satırı
    baştan yazan yok; her task yalnız kendi cümlesini değiştirir, dosya kirliyse hunk bazlı stage (`git apply --cached`).

## 2. Merdiven 1×/2×/3× (S1)

- **Ne:** `time_model.gd:9` → `[0.0, 2.5, 1.25, 2.5 / 3.0]   # pause / 1× / 2× / 3× [WORKING]`. `TopBar.tscn:210-214`
  `Speed4Btn` düğümü silinir; `top_bar.gd:66-72` dizisinden `$TimeBlock/Speed4Btn` çıkar. `game_shell.gd:79` silinir,
  `:71` yorumunun hız kısmı "1-3" (MeetingPanel seçimi 1-5 kalır, `meeting_panel.gd:48`). `office_travel.gd:171`'den
  `KEY_4, KEY_KP_4` çıkar (A2, tek satır). `main.gd:352-357` `--render-probe`, `_run_day_shot` (`:1327`, `:1337`
  `seconds_per_tick(speed)` dizi taşması) ve `_run_office_crowd_probe` (`:1371` denetimsiz `last_running_speed`) hızı
  merdiven dışındaysa tempo deseniyle reddeder (`main.gd:404-407`); `:1320`, `:1354` yorumları "speed 1-3". Belgelerdeki
  4× (A13): HARITA 91, 92, 104, 167; `GUNCELLEMELER.md:380`; ACIK_KARARLAR 104(8)(9) (§11).
- **Kayıt göçü yok:** `time_manager.gd:282` `last_running_speed`'i `size() - 1`'e kırpar; 4'te kaydedilmiş oyun 3×'e döner.
  `hours_per_real_second(4)` 0 döner (`:73`).
- **Kabul:** `speed_ladder` yeni tabloyla yeşil; `topbar_speed_cluster_three_rungs` yeşil; `office_pace_linear` yeşil;
  `--tempo-probe=1`, `=2`, `=3` her `TEMPO` satırında `dev` ±%2 içinde (hedef 22500 / 11250 / 7500 ms); `--day-shot=home:1`
  `--lang=tr` ve `--lang=en` ilk karesinde TopBar II, 1×, 2×, 3×; `--day-shot=home:4` reddedilir, çökmez.

## 3. Tek kural: saati yalnız oyuncu akıtır (S2)

**Kural (Model S, R1 §6).** `current_speed > 0` yalnız oyuncu girdisiyle yazılır: Space, 1–3 tuşları, TopBar düğmeleri
(`game_shell.gd:116-119`, `top_bar.gd:109-110`). Sistem yüzeyi yalnız durdurur (`hold_clock` ya da `emit(0)`).
`release_clock` hiçbir şey başlatmaz. Değişmez: tutuş varsa `current_speed == 0`.

**Oyuncu hız isteğinin tek evi (K3).** `game_shell.gd:108-119` `func request_speed(idx := -1) -> void` olur: önce
bekçi (bugün kapı `:109-115`; K4'te `TimeManager.is_clock_held()` → `say_held()`, §4.2), sonra `idx < 0` ise Space anlamı
(`0 if current_speed > 0 else last_running_speed`) ve tek `emit`. Space ve 1–3 tuşları onu çağırır. C'nin Boşluk ipucu
satırı (PRD_ACILIS R4, C-10) tıklanmaz ve hız yazmaz (U4).

**3.1 `time_manager.gd`**
- `:321-324` `resume_if_paused` silinir. `func holds() -> Array` (`_holds.keys()`) dışa açılır (§4.1, §4.5 okur).
- `hold_clock` (`:307-309`) başında `if _holds.has(reason): return` (U1): aynı nedenle ikinci çağrı sessizdir, yeniden
  `emit(0)` ve ağaç durdurma yok (`:306` "Idempotent" yorumu doğru olur). ProductTab ve B'nin `sync_plan_hold`'u her
  yeniden kurulumda çağırır; `_begin_shot`'ın elle açtığı ağaç (`main.gd:456`) ikinci çağrıda kapanmaz.
- `:221-226` → `freeze_clock(reason: String, tree_runs := false)`; `_freezes[reason] = tree_runs`. `tree_runs` ise
  `get_tree().paused = false`. `thaw_clock` silinen dondurma `tree_runs` taşıyorsa `get_tree().paused = current_speed == 0`.
- `:302` → `get_tree().paused = speed == 0 and not _freezes.values().has(true)`.
- Dondurma ağacı yalnız `tree_runs` ile ellenir. Neden: `_begin_shot` ağacı hız 0'da elle açar (`main.gd:456`); her
  freeze/thaw'da ağacı yeniden hesaplamak shot koşularını durdurur (`SHOT_FREEZE`, `main.gd:34`).
- Yorumlar bugünkü nedeni söyler: `:13-14`, `:41-44` ("tutan bırakır, saati oyuncu başlatır"), `:46-48`, `:312`.

**3.2 `main.gd` çağrı listesi (R1 §6, HEAD'de doğrulandı)**

| Satır | Bugün | Yeni |
|---|---|---|
| 40-41, 50-60 | 7 `_pre_*_speed` alanı ve yorumu | silinir |
| 2853-2857 | `_restore_speed` | silinir |
| 2876-2880 | kartın bulduğu hızı yakalar | silinir; `:2881` `hold_clock` kalır |
| 2915-2917 | cevapta hızı geri verir | silinir; `_settle_gate` yalnız bekçi + `_open_after_gate()` (§3.7) |
| 2946-2949 | gelen kutusundan çıkınca not hızı döner | silinir; `:2945` `EventGate.set_aside()` kalır |
| 2958-2959 | not hızı yakalar | silinir; `:2960` `emit(0)` kalır |
| 2975-2981 | `_claim_pre_dialogue_speed` | silinir; çağrıları `:3177`, `:3432` `TimeManager.release_clock(EVENT_CLOCK_HOLD)` olur |
| 2997 | satış dalı (`_process`) sızan yakalamayı temizler | silinir (yakalama yok) |
| 3018 | VC çağrısı hızı yakalar | silinir; `:3019` `emit(0)` kalır |
| 3041-3043 | satış çağrısı yakalar | `if invite.can_ring(): EventBus.speed_change_requested.emit(0)` |
| 3082-3084 | Ertele hızı geri verir | silinir; telefon saat duruk çalmaya devam eder (A5; ACIK 104(5) kapanır) |
| 3104-3105 | `freeze` + `emit(last_running_speed)` | `TimeManager.freeze_clock(TRAVEL_FREEZE, true)` |
| 3111-3112 | `emit(0)`, `thaw` | kalır (Hunt düğmesinden saat koşarken başlayan yolculuk masada durur) |
| 3129-3130 | `freeze` + `emit(last_running_speed)` | `TimeManager.freeze_clock(TRAVEL_FREEZE, true)`; `:3133` thaw kurucu yerine varınca (§3.6), ağacı yeniden durdurur |
| 3194-3195, 3449-3450 | oturum kapanınca hız döner | silinir |
| 3204, 3213-3214 / 3224, 3242-3243 / 3254, 3263-3264 | Ayarlar, onay, sistem menüsü yakalar ve geri verir | yakalama ve geri verme silinir; `emit(0)` kalır |
| 3380, 3395-3400 | dönüm kâğıdı yakalar; DEVAM ET hızı geri verir | silinir; DEVAM ET = kâğıt kalkar + `release_clock` (`:3394`) |
| 3502-3508 | `_pre_*` sıfırlaması | silinir |
| 2803-2804, 2888-2891, 2910-2911, 2940-2941, 3022-3026, 3076-3077, 3338-3339, 3366-3368, 3439-3440 | geri verme anlatan yorumlar | bugünkü nedeni söyler ya da silinir |
| 770-774, 837 | `--inbox-shot=flow` "saat yeniden koşar" | "karar verilir, saat durmuş kalır" (A15): adım 9 `speed=0` basar; adım 10: `key.call(KEY_SPACE)` → `running` |

**3.3 `product_tab.gd` (yalnız üç yer)**
- `:22` `_held_speed` silinir; `:109-114` yorum düzelir, `:114` silinir.
- `:245-258` → `on` ise `TimeManager.hold_clock(HOLD_RELEASE_NOTE)`, değilse `release_clock`. Emit yok, bekçi yok:
  her `_rebuild`'deki ikinci `hold_clock` §3.1'de sessizdir (U1).
- `:147` `_hold_clock(m.center.mode == "release")` değişmez; iki PRD de dokunmaz. Plan tutuşu B'nin
  `SprintSystem.sync_plan_hold`'undadır (PRD_SPRINT S7), ProductTab'a girmez.

**3.4 Sonuçlar (kabul edilmiş, oyuncuya görünür)**
- Karar cevabı, kâğıt, dönem özeti, sürüm notu, Ayarlar, onay, sistem menüsü, Ertele, oturum ve masa kapanışı sonrası
  saat durur. Oyuncu Space'e basar.
- Sprint kapanışı: sürüm notu tutuşu kalkınca saat durur (`game_shell.gd:42-45` Ürün'ü açar, not tutar).
- **Kabul:** yeni smoke `clock_resumes_only_by_player` (§10) her yol için bir assert ile yeşil; güncellenen beş vaka yeşil;
  `--inbox-shot=flow` GATEFLOW adım 9 `speed=0 held=false`, adım 10 `speed=1`; `--travel-shot` `speed=0` satırları. Model S
  kanıtı bunlardır; `bash tools/run_gate.sh` 3/3 yalnız regresyondur (bot saati TimeManager'dan sürer, main işleyicileri
  bağlı değil: `run_probe.gd:631-645`, `:685-686`).

**3.5 Yükleme her zaman duraklı (S10, A7).** `time_manager.gd:269-287` `from_dict`: boş blok yalnız saat ve
`last_running_speed` geri yüklemesini atlar; kuyruk (`current_speed = 0`, ağaç duraklı, `speed_changed.emit(0)`) her
yüklemede koşar. `save_manager.gd:319-330`: `TimeManager.from_dict(sys.get("time", {}))` boş `systems` dönüşünün (`:321-322`)
önüne alınır. `reset()` (`:246-256`) değişmez: A7 yalnız yüklemeyi kapsar. Önce hızı 1 varsayıp `from_dict({})`'e
uğrayan smoke vakaları taranır (`grep -n "from_dict({})\|apply_loaded_state"`), sonuç rapora.
- **Kabul:** `clock_resumes_only_by_player` içinde `TimeManager.reset()` + `from_dict({})` → `current_speed == 0` ve ağaç
  duraklı; üç kayıt vakası (§8.3) yeşil.

**3.6 Oturumdan dönüş: masaya kadar ağaç koşar (S11, A4; pürüz S30).**
- `office_people.gd`: yeni `signal founder_settled` (`:15` yanında); `founder_back()` (`:130-133`) `_returning = true`
  der. `_physics_process` (`:206`): `founder_away or _returning` iken `_k = TRIP_K` (gidişteki gibi, saat donuk, hız 0).
  `_process` (`:211-214` deseni): `_returning` ve kurucu yerleşmiş, yürümüyor ve kapıda değilken (`is_walking()`,
  `spot`) bir kez `founder_settled` yayar, `_returning = false`.
- Yürüyüşsüz dönüş `_process`'i beklemez: başsız ya da `not _layout.staffed()` iken `_process` hiç koşmaz (`:162`,
  `:165-166`), `founder_back()` `founder_settled`'ı `call_deferred` ile yayar; `_place` kurucuyu yürüyüşsüz koyarsa
  (`:626-629`, want boş: gece ya da mesai dışı, `:253`) `_returning = false` + yayın.
- Gece dönüşü (toplantı mesai bitişine indi, `time_manager.gd:153-154`): `office_empty()` `_returning` iken `false`;
  gece kapısı donmaya bakmadan her karede okunur (`time_manager.gd:97-99`), §8.1 kararması yoksa yürüyüşün üstüne düşer.
- `office_travel.gd` `travel_home` (`:94-105`): `founder_back()` ile `_end()` arasına `await _until(_people.founder_settled,
  SEAT_S)` (yeni sabit yok). Esc (`_skipped`, `:168-170`) ya da tavan: `_people.seat_founder_now()` (yeni: `_walk_back =
  false` + `_place`), sonra `_end()`; kurucu kapıda kalmaz.
- `main.gd` `_return_to_office` (`:3122-3133`): `freeze_clock(TRAVEL_FREEZE, true)` → `await travel_home` → `thaw`
  (ağaç durur, hız 0), emit yok. `_run_travel_shot` (`:1263-1266`) paneli kapatınca `founder_settled`'a bağlanır,
  `_in_transit` false olana dek kare çeker (tavan `TRAVEL_SHOT_BACK`), sonra `TRAVEL|settled ms=<sinyale kadar>
  capped=<sinyal gelmediyse 1> speed=<n> day=<GameState.day> night=<0|1>` basar (üretim kodu basmaz).
- S30 ayrı kod istemez: dönüşte emit yok, gece hız 0'da bekler (`time_manager.gd:102-103`); yolda tuşları `office_travel.gd:171`
  yutar, düğmeler `show_meeting("home")` ile pasif. `_advance_real`'a ek bekçi yazılmaz (CLAUDE §8); kanıt `day=`.
- Uygulanamazsa dur, sayıyla raporla (A'nın raporu, sahibe soru değil); kapıda donan çözüm commit'lenmez.
- **Kabul:** `--travel-shot=ishani` ve `=home` dönüş kareleri: kurucu kapıdan masaya (Ev'de yerine) yürür; `TRAVEL|settled`
  `capped=0 speed=0`; gece varyantı (`--travel-shot=ishani:night`, saat = kurucu bitişi − `MEETING_HOURS`, shot kolu A'nın)
  `capped=0`, kararma yürüyüş bitmeden başlamaz, `day` panel kapanışındakiyle aynı ve `night=1` (S30: dönüşte gece ve
  haftalık tik koşmaz; HEAD'de gün 1→2); `--office-crowd-probe=ishani:6:1` CROWD satırları değişmedi.

**3.7 Kapı çözülünce Ürün yeniden açılır (pürüz S03, F2).** Kapanış gecesi kart Ürün'ün yerini alır (`main.gd:2885`
`INBOX.show`; kapanan sayfa tutuşu bırakır, `product_tab.gd:111-113`); `_open_after_gate` (`main.gd:2921-2931`) yalnız
goto_tab'ı ve dönüm kâğıdını açar, not bir daha görünmez. goto_tab dalına `elif SprintSystem.is_typed() and
SprintSystem.mode() in ["release", "plan"]: EventBus.tab_changed.emit("product")` eklenir: goto_tab kazanır (kartta
oyuncunun seçimi; tutuş TopBar'da adıyla durur, §4.3), kâğıt dalı değişmez. `is_typed()` şart: `mode()` tür seçilmeden de
`"plan"` döner (`sprint_system.gd:308-313`), yoksa her erken kart ve `--inbox-shot=flow` adım 9 Ürün'e döner. Çağıranlar
`_settle_gate` (`:2918`) ve `_close_term_table` (`:3451`); sırada kart varken açılmaz (`:2923`). B'den önce Ürün'ün
`_rebuild`'i tutuşu yeniden alır (`product_tab.gd:147`), B'de tutuş moddan gelir (PRD_SPRINT S7, B-K2). **B buna dayanır:**
notu kapıdan sonra gösteren bu satırdır; B'nin S03 kabulü A'nın K4'ünden sonra koşar.
- **Kabul:** `--clock-shot=gate` (§9.2) TR/EN: `CLOCKSHOT|gate` satırında `window=product`, `mode=release`, `speed=0`,
  `holds` `product_release_note` içerir; karede Ürün ve "SÜRÜM NOTU AÇIK". Sahtelik: dalı sil → `window=events`, `holds` boş.

## 4. Tutuş etiketleri ve duraklı hâl (S3)

**4.1 `time_manager.gd`**
- `signal hold_changed` (yalnız küme gerçekten değişince; `hold_clock` yeni nedende, `release_clock` var olan nedende).
- `const HOLD_LABELS := {"event": "GATE_ANSWER_FIRST", "milestone_paper": "CLOCK_HOLD_MILESTONE",
  "product_release_note": "CLOCK_HOLD_RELEASE_NOTE"}`. Anahtar `hold_clock` nedenidir. B kendi satırını tablonun SONUNA
  ekler (`"sprint_plan": "CLOCK_HOLD_SPRINT_PLAN"`, PRD_SPRINT S7).
- `func hold_label() -> String`: tablo sırası önceliktir; tutulan ilk nedenin anahtarı (`event` > `milestone_paper` >
  `product_release_note` > `sprint_plan`), tabloda olmayan neden tutuluyorsa `"CLOCK_HELD"`. Sürüm notu ile B'nin plan
  tutuşu aynı anda tutulur (B-K2); "son alınan" kuralı sırayı gece toplu adımına bırakırdı.

**4.2 `game_shell.gd:108-115`** → `request_speed`'in bekçisi (§3) `if TimeManager.is_clock_held(): say_held()`.
`func say_held()`: TopBar'ı yakar (`blink_held`) ve en çok 3 sn'de bir tost basar (bugünkü `:111-114`): başlık
`CLOCK_HELD`, gövde `tr(TimeManager.hold_label())`; kart tutuşunda metin bugünküyle aynıdır (`GATE_ANSWER_FIRST`).
GameShell `_ready`'de `add_to_group(&"game_shell")`; başka dosya tostu `get_tree().call_group(&"game_shell", &"say_held")`
ile ister (ikinci tost yazılmaz; smoke'un `_stand_in_shell`'inde no-op, `endgame_smoke.gd:11988-11995`). `:87-88` yorumu
`_pre_*` yerine bugünkü nedeni söyler.

**4.3 `top_bar.gd` + `TopBar.tscn`**
- Yeni `$TimeBlock/State` Label (`KeySmall`, metinsiz doğar). Kural, öncelik sırasıyla: görüşme (`_held()`) ya da kart
  kapısı varsa gizli; tutuş varsa `tr(TimeManager.hold_label())`; `run_active` ve hız 0 ise `TOPBAR_PAUSED`; yoksa gizli.
  Metin TopBar'ın öbür `KeySmall` satırları gibi `Fmt.upper(tr(...))` alır (`:252` `$GateLabel`); CSV karışık harfli kalır.
- Duraklı ve tutuşsuzken II (`PauseBtn`) `modulate:a` 1,0 ↔ 0,45, `PAUSE_BLINK_S` ile yanıp söner: **onaya kadar
  yazılmaz** (A10, CLAUDE §3); K4 yalnız DURDU satırını getirir. Onay K4'ten önce gelirse K4'e, sonra gelirse ayrı küçük
  commit'e girer: Tween TopBar'ındır (GameShell ALWAYS, `GameShell.tscn:13`), hız > 0 ya da tutuşta durur.
- `:242-243` → `b.disabled = gated or held or TimeManager.is_clock_held()`.
- `blink_gate` (`:269-274`) → `blink_held`: kapı varken `GateFrame`, yoksa `State` yanıp söner.
- `TimeManager.hold_changed` → `_refresh` (K7 `_queue_refresh`'e alır); `speed_changed` → `_apply_speed_visual` + durum satırı.
- Yerleşim (bağlayıcı): TopBar 64 px sabit. `KEYS_Y` 16→10, `CLOCK_LINE` 41→35 (`top_bar.gd:45,56`); `State` taban
  çizgisi 58, sol kenarı saatin solu, genişliği bloğun iç genişliği. GRID `time` 335→291 ve 269→235 (bir tuş +
  `KEY_GAP`: tamda 44, sıkışıkta 34 px; `:21-24`, `:57`).
- **Kabul:** `--clock-shot=paused|held|released|compact` (§9.2) TR ve EN 1920×1080'de: satır taşmıyor, kesilmiyor, tuşlarla
  çakışmıyor; `held`'de tuşlar pasif; `compact` (1280×720) satır üç noktasız ya da Erdem onaylı kısaltma.

**4.4 Metinler (TR/EN onay bekliyor, SAHİBE; önce İngilizce; `localization/strings.csv`'ye bayt-span ekleme: A1'in beş anahtarı, F10)**

| Anahtar | EN | TR |
|---|---|---|
| `TOPBAR_PAUSED` | PAUSED · Space to resume | DURDU · Boşluk ile sürdür |
| `CLOCK_HOLD_RELEASE_NOTE` | Release note open | Sürüm notu açık |
| `CLOCK_HOLD_MILESTONE` | Milestone open | Dönüm noktası açık |
| `SET_PAUSE_UNFOCUSED` | Pause when unfocused | Odak kaybında duraklat |
| `SET_SUMMARY_FREQ_NOTE` (§5.1, A1'in 5. anahtarı, F10) | Each summary stops the clock and opens Events. | Her özet saati durdurur ve Olaylar'ı açar. |
| `SYS_RESUME` (var olan değer değişir, §4.7, F11: onaydan sonra) | Resume → Back to game | Devam → Oyuna dön |

Var olanlar yeniden kullanılır: `CLOCK_HELD` (Saat kilitli), `GATE_ANSWER_FIRST` (`event` tutuşu), §4.6'da `SALES_BLOCK_*`.
"Space" TR metinde kullanılmaz (izinli ödünç listesinde değil, CLAUDE §5; A3). Yeni anahtarlar yer tutucu taşımaz.

**4.5 Tutuşta görüşmeye giriş kapalı (S9, A11; B'nin D5 sorusu)**
Herhangi bir tutuş sayılır (`event`, `milestone_paper`, `product_release_note`, B'nin `sprint_plan`'ı). Dört giriş:
- `main.gd` `_meeting_refused() -> bool`: `TimeManager.is_clock_held()` ise `call_group(&"game_shell", &"say_held")` (§4.2)
  ve `true`. "Görüşmeye git" `_on_pitch_requested` (`:3027-3029`) ve term sheet masası `_on_term_table_requested`
  (`:3423-3425`) başında ilk satırdır; bugünkü sessiz dönüşler (`active_id`, `_gate_shut`, `_in_transit`) arkasında kalır.
- Telefon kabulü (satış ve VC): `MeetingInvite._accept` (`meeting_invite.gd:183-185`) `stop()`'tan önce
  `if TimeManager.is_clock_held(): call_group(...say_held); return`; zil ve kart kalır, `_call` korunur. Ret
  `main._on_call_accepted`'da olamaz: `_accept` zili ve kartı önce kapatır (`:119-124`), main'in VC dalı yeniden
  çaldırmaz (`main.gd:2990-2993`), çağrı ölür.
- Seed pitch (Yatırım > fon düğmesi; onaylı, F12): `hunt_tab.gd:191-193` `_seed_block` önce `TimeManager.is_clock_held()` ise
  `TimeManager.hold_label()` döner; düğmeler pasif, neden altında yazılı (`:177-187`), `_confirm_seed_pitch` (`:218`) onayı
  açmaz. HuntTab `TimeManager.hold_changed`'e `_on_changed` ile bağlanır (görünmezken §7.2). `_on_meeting_scene_requested`
  düzeyinde ret yetmez: hak `seed_round_system.gd:108` ile zaten harcanmıştır.
- İstisna: kartın kendi seçeneği masayı açarken (`EventGate.resolving()`, `_gate_shut` `:2971-2972`) `event` tutuşu
  sayılmaz; K3 sonrası `:3177`/`:3432`'deki `release_clock(EVENT_CLOCK_HOLD)` onu bırakır.
- **Kabul:** `clock_resumes_only_by_player` içinde `hold_clock("smoke_hold")` altında: geçerli prospect
  (`SalesFaucetSystem.spawn`) ile `_on_pitch_requested` → `SalesMeetingSystem.is_active() == false`; canlı sheet ile
  `_on_term_table_requested` → `TermSheetTableSystem.is_active() == false`; `preload(hunt_tab.gd).new()._seed_block(<vc>)
  == TimeManager.hold_label()` (düğüm ağaca girmez, `free()`). Sahtelik: ret satırını sil → `SalesMeetingSystem.is_active()`
  true, vaka düşer. Telefon: `--invite-shot=held` (A'nın kolu; kart açıkken
  `hold_clock` + `invite._accept()`, `is_ringing()` false ise `_shot_fail`). `--clock-shot=held` tutuş altında
  `_on_pitch_requested` çağırır, tost karesi `clock_shot_held_meet[_en].png` TR/EN.

**4.6 Düşen satış çağrısı söylenir (pürüz S39; F1 onaylı, `main.gd` çağrı yolları A'nın).** Zil düz duraklatma kalır, tutuş olmaz: Ertele "çalmaya devam eder" (A5)
saat akarken çalmayı ister. Eksik olan düşüşün sesi: saat akınca çağrı kesimde sessiz biter (`main.gd:2994-2996`, `:3058-3061`).
- `_ring_call` (`:3048`; atama `:3050`) `_call`'a `"place": place` ekler. `_process` satış dalı: `why := SalesLedger.meeting_block_reason(_call.id)`
  boş değilse tost (başlık `_call.place`, gövde `tr(why)`: onaylı `SALES_BLOCK_*`, yeni anahtar yok; glif mevcut
  `assets/icons/util/` ikonu, renk `UiTokens.D_ACCENT`), sonra `_end_call()`. VC dalı (`:2991-2993`) sessiz kalır (F1): düşen
  VC çağrısı ertesi uygun gün yeniden çalar (`vc_pitch_system.gd:756-759`), "kaçtı" yanlış olur.
- **Kabul:** `--invite-shot=lapse` (`=held` ile aynı hunk): satış zili çalar, `advance_hours(n)` saati kurucu bitişi −
  `SalesConstants.MEETING_ENTRY_CUTOFF_HOURS` + 1'e taşır, iki kare; `INVITE|lapse|ringing=0|why=SALES_BLOCK_TOO_LATE`,
  tost karesi `invite_shot_lapse[_en].png` TR/EN. Sahtelik: tost satırı silinince kare tostsuz.

**4.7 Sistem menüsünün "Devam"ı (pürüz S42; F11, SAHİBE).** K3'ten sonra menüyü kapatmak saati başlatmaz (§3.2);
`SYS_RESUME` "Devam / Resume" (`strings.csv:255`, `SystemMenuModal.tscn:86`) sürmeyi vaat eder. "Oyuna dön / Back to game"
§4.4 TR/EN onay tablosunda; onaydan sonra uygulanır. Onay K4'ten önceyse K4'ün CSV hunk'ına bayt-span değer, sonraysa ayrı küçük commit. **Kabul:** `--modal-shot=system` TR/EN.

## 5. Odak kaybında duraklat (S4)

- `settings.gd:44-46` Oyun bloğuna `"pause_unfocused": true,   # TimeManager reads it`.
- `time_manager.gd` `_notification(what)`: `NOTIFICATION_APPLICATION_FOCUS_OUT` ve ayar açık ve `focus_pause_armed`
  ise `_on_speed_change_requested(0)`. Odak dönünce hiçbir şey olmaz (Model S). `var focus_pause_armed` `_ready`'de bir
  kez `not` harness olur: `OS.get_cmdline_args()` içinde `SaveManager._is_harness_arg` (`save_manager.gd:401-407`;
  `display_settings.gd:92` aynı yolu kullanır). Alan açıktır ki `--clock-shot=focus_out` onu kurabilsin (`--clock-shot`
  `-shot` içerir, harness sayılır).
- `NOTIFICATION_WM_WINDOW_FOCUS_OUT` kullanılmaz: açılır menü (OptionButton) ayrı penceredir ve onu da tetikler.
- `settings_modal.gd:186-194` Oyun bölümüne `CheckButton` satırı `SET_PAUSE_UNFOCUSED` (`_mute_toggle` deseni,
  `:181-183`); `_sync_from_state` (`:274-294`) değeri basar.
- **Kabul:** shot'lar duraklı açılır (`main.gd:87`), DURDU karesi tek başına kanıt değildir. `--clock-shot=focus_out`:
  `emit(1)`, `TimeManager.focus_pause_armed = true`, `get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)`,
  `CLOCKSHOT|focus_out|before=1|after=<hız>` basar; kabul `after=0` ve DURDU karesi. `=focus_out_off` aynı adımlar
  öncesinde `Settings.set_value("pause_unfocused", false)` (izole APPDATA) ile `after=1`. `--modal-shot=settings_end` TR/EN
  satır görünür: `0fe77fc`'den beri Grafik bölümü (ön ayar + 13 satır, `settings_modal.gd:32-47`, `:149-166`) Oyun'u ilk
  karenin altına iter, `end` sona kaydırır (`main.gd:1613-1615`). Erdem pencereli oyunda Alt+Tab ile bakar.

**5.1 Özet sıklığı satırı bedelini söyler (pürüz S52; F10 onaylı).** Özet saati durdurur, gelen kutusunu açar (`main.gd:3340-3341` →
`_open_note` `:2954-2961`); durduranlar aynı kalır (brief madde 3), "Her hafta" her tik bir duruştur (`summary_system.gd:62-64`).
`settings_modal.gd:194`'ten sonra `_note(_game_body, "SET_SUMMARY_FREQ_NOTE")` (`:206` deseni); anahtar A1'in beşincisi (F10),
metni §4.4'te onay bekler. **Kabul:** `--modal-shot=settings_end` TR/EN not Özet sıklığının altında, taşmıyor.

## 6. Akıcı saat ve hafta çubuğu (S5)

- `top_bar.gd` `_process`: `m := int(TimeManager.day_minute()) / CLOCK_STEP_MIN * CLOCK_STEP_MIN`; değişince
  `$TimeBlock/Clock.text = "%02d:%02d" % [(m / 60) % 24, m % 60]`. `_refresh_time` (`:281`) aynı yardımcıyı çağırır.
- `_draw_week` (`:323`) → `clampf(TimeManager.day_minute() / 60.0, start, end)`; `_process` "şimdi" işaretinin tam piksel
  x'i değişince `queue_redraw()`. Dolgu (`:326`) ve elmas (`:334-337`) aynı `now`'u okur.
- `% 24`: 24:00'te biten mesaide akümülatör 24'te bekler (`time_manager.gd:213-216`), yazı 00:00.
- Sıradaki satırı (`:209`) saatlik kalır. Maliyet kare başına bir okuma (R4 §4A).
- **Kabul:** `DAYSHOT` satırına (`main.gd:1343-1345`) `|label=<$TimeBlock/Clock.text>` eklenir. `--day-shot=home:1` her
  karede `label` == `clock`'un 5 dakikaya indirilmişi `% 24` (DAYSHOT `clock` `% 24` almaz: 24:00'te `label` 00:00);
  ardışık iki karede `label` ve çubuk ucu x'i farklı. `--clock-shot=paused` 1 sn arayla iki kare, iki `label` aynı.

## 7. Yenileme birleştirme (S6)

**7.1 TopBar.** `:88-104`'teki 17 bağlantı ve `_on_offer_countdown_changed`'in `_refresh` çağrısı (`:122`) `_queue_refresh`'e
gider: `_dirty = true`, ilkse `_refresh.call_deferred()`. `_refresh` sonunda `_dirty = false`. Satırlar
`EventBus.x.connect(queue)` biçiminde tek tek kalır, döngüye çevrilmez (`:86`: manifest üreticisi bu biçimi okur).
Doğrudan çağıranlar (`show_meeting` `:127-129`, `resized`, `main.gd:765,1502,1600` `call_group`) senkron kalır. Toplu
adımda 18–53 yenileme bire iner (R4 §2.3). `is_batching()` dalı yok (A12).
**7.2 HuntTab.** `_on_changed` (`hunt_tab.gd:74-75`), `_on_advisory` (`:80-82`) ve `_on_gate_input` (`:85-88`)
görünmezken (`not is_visible_in_tree()`) yalnız `_stale = true` der. `visibility_changed` görünür olunca ve `_stale` ise bir
kez `_refresh()`. `finance_tab.gd:118-119` sayfanın kendi `visible`'ını değiştirir, sinyal o düğümde gelir.
**7.3 Özet.** `_on_state_changed` (`finance_ozet_view.gd:95-98`): görünmezse döner (bugünkü gibi); görünürse kirli bayrak
ve `get_tree().process_frame` tek seferlik bağlantı (`product_tab.gd:149-150` deseni). Yenileme saat adımının
karesinden sonraki karede koşar; aynı karedeki `cash` + `mrr` + `burn` bire iner. Yenileme o karede 10–13,5 ms kalır;
iki kare ayrı ölçülür (A8). Özet kartlarının artımlı boyanması bu task'ın dışındadır.
**7.4 Piyasa.** `piyasa_tab.gd:82-85` sinyalleri `_queue_build`'e (aynı `process_frame` deseni); `:88-90` aynı callable'ı
koparır. Haftalık kurulum (75–126 ms) gece karesinden ayrı kareye taşınır, yok olmaz (A9). Artımlı kurulum ayrı iştir:
K7 ACIK_KARARLAR'a yeni açık madde yazar (ölçüm ve gerekçe; mevcut maddelere dokunulmaz).
- **Kabul:** `--tick-probe=1` `TICK|refresh` satırı gece başına TopBar yenilemesi ≤ 2; `--tick-probe=1:finance` saat
  karesi p95 ≤ 8 ms ve `TICK|after_hour` max ≤ 16,7 ms; `--tick-probe=1:piyasa` gece karesinde Piyasa kurulumu yok
  (`TICK|night` max penceresiz değere ±10 ms).

## 8. Gece: kararma, ısınma, otomatik kayıt (S7)

**8.1 Hep kararma.** `office_people.gd:103-111`: `cutting` kalkar. Kapıdan ya da yatağa yürüyen varsa `false` (`:107-108`);
yoksa `_fade == null and _k > 0.0` iken `_view.fade(true, …)` başlar (`:112-113`), bitince `true`. Uzak düzenler
(`city`, `meet`, `office_layout.gd:10`) ve başsız koşu bugünkü gibi hemen `true` (`:99-100`). Duraklıyken (`_k == 0`)
kararma başlamaz; TimeManager zaten bekler (`time_manager.gd:102-103`). Yorum `:95-97` düzelir.
Etki: 1×'te hafta 0,25 sn, 3×'te 0,083 sn uzar; oran korunur (ACIK_KARARLAR 104(9)).
**8.2 Isınma.** `func _warm_catalogs()`: `EvCatalog.ensure_loaded()` (`catalog.gd:32`) ve `SprintCatalog.load_data()`
(`sprint_catalog.gd:24`; yalnız çağrı, B'nin dosyasına dokunulmaz). `_mount_shell` (`main.gd:2811-2817`) ve
`_mount_shot_shell` (`:496-501`) ikisi de kabuk kurulunca çağırır; `--tick-probe` ikincisinden geçer, ısınmayı ancak
böyle ölçer. İlk saatlik tik 64 ms; `TICK|first_hour` K2 tabanı (ısınmasız) ile K8 (ısınmalı) aynı kurulum yolundan
karşılaştırılır (≤ 16,7 ms onay bekliyor, A10); ilk gece ayrıca basılır.
**8.3 Otomatik kayıt işçi iş parçacığında (`save_manager.gd`).**
- `:183-192` `_payload()` olur; `save_to_slot` (`:179-198`) onu kullanır ve senkron kalır (el ile kayıt, hızlı kayıt,
  smoke, ANA MENÜ).
- `_try_autosave` (`:364-373`): `_write_task != -1` ise döner (bekleyen kalır). Değilse yuvayı seçer
  (`_next_auto_slot_id()`), `_save_in_background(slot)`'u çağırır; çağrı anında `_autosave_pending = false`,
  `_last_autosave_msec = now`. `_save_in_background(slot)`: ana iş parçacığında `_payload().duplicate(true)` ve
  `GameState.day`; sonra `WorkerThreadPool.add_task` içinde `JSON.stringify(payload, "\t", false)` +
  `_write_atomic(path, text)`, bitince `_on_write_done.call_deferred(ok, day)`.
- `_on_write_done`: `_write_task != -1` ise `wait_for_task_completion`, sonra `-1`; `ok` ve gün aynıysa `_dirty = false`,
  `ok` değilse `_autosave_pending = true`.
- `_join_write()` (bekler, aynı temizliği yapar): `save_to_slot`, `read_slot` (`:120`), `list_slots` (`:102`),
  `delete_slot` (`:205`), `apply_loaded_state` (`:232`) ve `_autosave_on_close` (`:377-379`) başında.
- Yakalama 00:00 adımında kalır (SENKRON KURALI `time_manager.gd:20-25`). Kayıt toplu adımın sonuna taşınmaz: adım
  sonunda pompalanan kart `can_save()`'i kapatır (`:81-82`) ve kayıt cevap tıkına kayar (R4 §4 C2).
- **Kabul:** yeni smoke `autosave_writes_off_thread` (§10); `save_roundtrip_fingerprint`, `save_continuity_seeded`,
  `save_double_load_no_residue` yeşil; `--tick-probe=1` `TICK|night` max ≤ 60 ms (bugün 60–165), `TICK|save` `async=1`
  ve `frame_ms` ≤ gece kapısı.

**8.4 Gece dilimleme (koşullu, A6).** Yalnız K9 sonrası `--tick-probe=1` ve `=3` `TICK|night` max iki koşuda da > 60 ms
ise: önce rapor (`each=` dizisi, kareyi kimin tuttuğu), sonra K9b: yalnız gece yolunda (`time_manager.gd:97-105` →
`skip_night` `:161-168`) kare başına adım tavanı (`_run_batch(mini(steps, K), 0.0, false)`; `K` teknik sabit); dilimler
boyunca `is_batching()` doğru (`engine.gd:421`), `clock_batch_ended` (`:181`) ve `night_skipped` (`:168`) yalnız son
dilimden sonra, 00:00 adımı atomik. ≤ 60 ms tutarsa K9b yazılmaz, raporda "gerekmedi".

## 9. Ölçüm ve görsel araçlar (S8)

**9.1 `--tick-probe=<hız>[:<pencere>]`** (`scripts/debug/tick_probe.gd`, `class_name` yok, `main.gd`'de `preload`).
- `main.gd:190-219` sözlüğüne `"--tick-probe=": _run_tick_probe`. Tohum `_seed_run_reproducible` + tempo durumu:
  `main.gd:413-422` `_seed_tempo_state()` olur, tempo ve tick aynı yardımcıyı çağırır.
- Başsız koşar; `_begin_shot()` + `_mount_shot_shell()`; `<pencere>` varsa (`piyasa` ise önce `_seed_piyasa("")`,
  `main.gd:1389-1390` deseni) `tab_changed.emit(<pencere>)`. `OS.low_processor_usage_mode_sleep_usec = 0` (başsızda kare
  başına 6,9 ms uyku yoksa kare süresine biner). `SaveManager._autosave_enabled = true` (bayrak `probe` içerdiği için
  kapanır; gece ölçümü kaydı içermeli).
- 5 hafta gerçek saat. Kart gelirse `RunProbe._drain_modals()` (`run_probe.gd:516`, botun cevabı; kopyası yazılmaz) ve
  hızı yeniden basar (oyuncu gibi). Başka tutuş ya da duraklama: pencereyi kapatır, hızı basar, pencereyi yeniden açar.
  Tutuş sürüyorsa ya da `SprintSystem.mode() == "plan"` ise `SprintSystem.apply_lead()` + `start()` çağırır (oyuncu gibi,
  HEAD'de var `sprint_system.gd:111,188,312`; B-D1 "harness sprinti kendisi başlatır"; B sonrası plan tutuşunu da
  kaldırır). Yine kalkmazsa `TICK|stall hold=<neden>` basar ve çıkar. Müdahale kareleri sayılmaz.
- Kare süresi: ardışık iki `process_frame` arasındaki `Time.get_ticks_usec()` farkı. Sınıf o aralıkta yayılan sinyalden:
  `night_skipped` → `night`; `hour_changed` (gece değil) → `hour`; hour/night karesinden sonraki kare → `after_hour` /
  `after_night`; ısınmadan sonraki ilk hour → `first_hour`. TopBar sayacı: `top_bar.gd` `var refresh_count := 0`,
  `_refresh` başında `+= 1` (yalnız ölçüm; probe `night_skipped`'te farkı alır). Kayıt karesi: `SaveManager._write_task
  != -1` ise `async=1`. Çıktı:
  `TICK START speed=<n> win=<id> udir=<user dir>` · `TICK|hour|n=|p50=|p95=|max=` · `TICK|after_hour|max=` ·
  `TICK|night|n=|max=|each=<ms;…>` · `TICK|after_night|max=` · `TICK|first_hour=` · `TICK|refresh|topbar_per_night=` ·
  `TICK|save|frame_ms=|async=<0|1>` · `TICK|over16|n=` · `TICK END`.
- **Kabul:** aynı tohumla iki koşu aynı kare sınıflarını sayar (`n=` eşit); `udir` izole dizin.
**9.2 `--clock-shot=<running|paused|held|released|gate|focus_out|focus_out_off|compact>`** (`main.gd`, `_begin_shot` deseni).
`running` iki farklı dakikada iki kare. `held`: `_seed_product_live("b2c_mvp")` → `_mount_shot_shell()` →
`EventBus.tab_changed.emit("product")` + iki kare; `TimeManager.holds()` `product_release_note` içerir; ayrıca §4.5 tost
karesini (`_meet`) çeker. `released`: aynısı, ardından `SprintSystem.plan_next()` + `apply_lead()` + `start()` (B-D1;
sayfanın kendi `"plan_next"` eylemi, `product_tab.gd:222`) ve `get_first_node_in_group(&"window_layer").get_current_page_body().set_source(null)` + bir kare: B'den
önce ve sonra kare aynı DURDU hâlidir. `debug_product_act` kullanılmaz: canlı tohumda `_product_source` boştur ve döner
(`game_shell.gd:169-172`). `gate` (§3.7): `held`'in kurulumu + `_shot_card("funding.frank_cheque", {}, GameState.current_hour)`
(`main.gd:841-845`) + `EventGate.resolve(EventGate.active_id(), 0)` (`event_gate.gd:23`) + bir kare; satır
`CLOCKSHOT|gate|window=<id>|mode=<SprintSystem.mode()>|holds=<TimeManager.holds()>|speed=<n>` (`id` pencere katmanının
`_primary_id`'si, `window_layer.gd:49`; B sonrası `holds` B'nin tutuşunu da taşır, `window=product` aynı). `focus_out` / `focus_out_off` §5. `compact` 1280×720. PNG `clock_shot_<durum>[_en].png`. Kol
main.gd'ye ayrı hunk olarak girer; B ve C'nin kolları ondan sonra (§1).

## 10. Smoke değişiklikleri (`scripts/debug/endgame_smoke.gd`)

| Vaka | Değişiklik |
|---|---|
| `speed_preserve` (`:87`, `:1222-1237`) | `resume_if_paused` yerine Space anlamı: `emit(0)` sonra `emit(TimeManager.last_running_speed)` → 2, ağaç açık; yorum `:1223-1226` silinir |
| `speed_ladder` (`:194`, `:7103-7142`) | `want` 4 giriş, ileti "pause + 1x/2x/3x"; `:7136-7141` `emit(last_running_speed)` |
| `milestone_clock_hold` (`:348`, `:11960-11985`) | `:11972-11975` silinir (A16); bırakmadan sonra `current_speed == 0` assert'i, sonra `emit(2)` tutar |
| `event_gate_holds_clock` (`:350`, `:12003-12031`) | `:12026-12027` → `current_speed != 0` ise FAIL ("cevap saati başlattı") |
| `milestone_paper_waits_for_card` (`:349`, `:12082-12083`) | DEVAM ET sonrası `current_speed == 0` |
| `speed_save_clamps_to_ladder` (`:352`, `:12152-12154`) | `emit(TimeManager.last_running_speed)` → `top` |
| `topbar_speed_cluster_four_rungs` (`:353`, `:12162-12183`) | ad `topbar_speed_cluster_three_rungs`; `PauseBtn`, `Speed1-3Btn` var, `Speed4Btn` yok; `top_bar.gd` `Speed4Btn` içermez; `game_shell.gd` `KEY_3, KEY_KP_3: speed_idx = 3` içerir, `KEY_4` içermez |
| yeni `clock_resumes_only_by_player` | `_stand_in_shell` (`:11988`; `host._shell` ona) ile her yüzey için: hız 2 → kendi açılış yolu → kapanış → `current_speed == 0`. Açılışı sürülenler: kart (`_on_event_modal_requested` → `_on_event_resolved`; kâğıt kenara `_on_event_set_aside`), not (önce `GameState.messages`'a `{kind: "intro", id: …}` fikstürü; `_open_note("intro")` + `_on_tab_changed("hr")`, `:2955-2957` boş listede döner), DEVAM ET, Ayarlar (`_on_settings_requested`), onay (`_on_confirm_requested({})`), sistem menüsü (`_on_system_menu_requested`), sonra `_on_*_dismissed`. Açılışı sürülemeyenler (zil `_meeting_invite()` ister, office_view yok): önce `emit(0)` (zilin/yolculuğun yaptığı), sonra Ertele (`_call = {"kind": "sales", "id": …}` + `_on_call_postponed`) ve oturum (`host._meeting_panel = MeetingPanel.new()`, `end_sitting()`'i boş RefCounted stub; `_close_meeting` `:3189` null panelde çöker; `_travel_on = false`, `_return_to_office` beklemez). ProductTab `_hold_clock(true/false)` ve `on_page_closing`; tutuş altında `emit(2)` yutulur; `emit(4)` reddedilir (WARNING, ERROR değil); `reset()` + `from_dict({})` → 0 (§3.5); U1: `hold_clock("smoke_hold")`, `get_tree().paused = false`, ikinci `hold_clock("smoke_hold")` → ağaç açık, `speed_changed` yayılmadı; K4'te §4.5 assert'leri. Sahtelik: `_on_settings_dismissed`'e `emit(2)` ekle → vaka düşer |
| yeni `autosave_writes_off_thread` | `_save_in_background("smoke_async")` (oyuncunun `auto_*` yuvasına değil), `_write_task != -1`, `_join_write()`, `read_slot` aynı `day`; uçuşta `save_to_slot` önce bekler; yuva silinir. Sahtelik: `_join_write`'ı boşalt → okuma ya eski ya boş |

HARITA 91-92'nin sabit ad listesi ve kayıt yuvası paylaşan vaka listesi güncellenir. Bu tablonun dışındaki vakaya A
dokunmaz; kırarsa düzeltir ve raporlar (§1).

## 11. Belgeler

- `GDDs/GDD — ZAMAN MODELİ.md`: §1.2 (`:50-51`) `freeze_clock(neden, tree_runs)` ve "saat yalnız oyuncuyla akar" hükmü
  (A14; sistem yüzeyi durdurur, kapanış başlatmaz, odak kaybı durdurur, yükleme duraklı döner); §2 tablo (`:79`, `:92-98`) ve `:104` üç basamak, 1–3
  tuşları, kayıtta 1–3 kırpma; §6.5 (`:440-446`) yazım işçi iş parçacığında; §8.5 madde 0 (`:586-589`) "Ertele kartı
  kapatır, telefon saat duruk çalar" (A5), madde 7 (`:602-605`) "perde kalkar, kurucu saat donukken masasına yürür, sonra saat duruk kalır;
  atlama mesai bitişine indiyse yürüyüş olmaz, gece saat duruk bekler"; tutuşta görüşmeye giriş kapalı (A11) aynı bölüme.
  4× ve eski kararma kuralının öbür yerleri (A13): `:20`, `:330`, `:489`, `:504-511` (§7.4: içeride kalan "kesilir" →
  hep kararma, K8), `:608` (tuşlar 1-3).
- `docs/ACIK_ISLER/ACIK_KARARLAR.md` (yalnız hükmün yetkilendirdiği maddeler, CLAUDE §3): 104(5) (`:1527-1530`) kapanır
  (A5); 104(8)(9) 4× → 3× (A13); yeni madde 105: Piyasa artımlı kurulumu (A9), numarası commit anında sıradaki boş numara
  (HEAD'de 105); B'nin B-K8 maddesi ondan sonra gelir. Yardımcı yönetmene rapor (dokunulmaz): 85(2) yolculukta düğmeler
  kapalı (`top_bar.gd:242-243`); 104(1)(2) 4× rakamları; 104(10) K7 ölçümü; `GUNCELLEMELER.md:390`, `:434` 4× taşıyor
  (A14 yalnız ch12 §2 der).
- `GDDs/GUNCELLEMELER.md` ch12 §2 (`:380`): yalnız TopBar cümlesi (A14, U11): "Hız dört basamaklıdır: 1×, 2×, 3×, 4× (tuşlar
  1 ile 4)." → "Hız üç basamaklıdır; saat yalnız oyuncu sürdürünce akar." C bu satıra dokunmaz (ch12 §5'e ayrı paragraf).
- `docs/HARITA.md`: 19 (merdiven, `tree_runs`), 25 (`--tick-probe`, `--clock-shot`), 33 (autosave işçisi), 84 ("Olaylar'dan
  çıkınca hız döner" silinir, `blink_held`, kapıdan sonra Ürün §3.7), 85 (TopBar durum satırı), 86 ("Ertele yeniden açar" →
  "Ertele saati başlatmaz, telefon saat duruk çalar", A5), 91-92, 104 ("4×'te 16"), 167 (`hr:40:3`).
- `CLAUDE.md` §6 (`:80-81`) merdiven ve 3×'te 7,5 sn; §12 tempo satırının yanına `--tick-probe`, `--clock-shot`; davet
  satırına `held|lapse`; `--inbox-shot=flow` cümlesinde "karar verilir, saat döner" → "karar verilir, saat durmuş kalır" (A15).

## 12. Commit sırası

Her commit: ayrı ajan incelemesi (CLAUDE §9) → bulgular düzelir → kapılar yeşil → commit. Hedefli smoke `bash
tools/smoke_run.sh <vaka>`; CSV'ye dokunan commit önce `--event-lint`, `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` (smoke vakası değil), `loc_csv_integrity`.

| # | Commit | Dosyalar | Kapı |
|---|---|---|---|
| K1 | Saat: hız merdiveni üç basamak | `time_model.gd`, `TopBar.tscn`, `top_bar.gd` (dizi), `game_shell.gd:79`, `office_travel.gd:171`, `main.gd` (357, 1320, 1327-1337, 1354, 1371), smoke `speed_ladder` + `topbar_speed_cluster_three_rungs`, CLAUDE §6, Zaman Modeli §2, HARITA 19/91/92/104/167, ACIK 104(8)(9) | smoke `speed_ladder`, `topbar_speed_cluster_three_rungs`, `office_pace_linear`, `speed_day_invariant`, `speed_save_clamps_to_ladder`, `all_scripts_load`; `--tempo-probe=1`, `=2`, `=3` ±%2; `--day-shot=home:1 --lang=tr` ve `--lang=en` ilk kare |
| K2 | Araç: `--tick-probe` | `tick_probe.gd` (yeni), `main.gd` (dağıtım, `_seed_tempo_state`), `top_bar.gd` (`refresh_count`, tek satır), CLAUDE §12, HARITA 25 | `--tick-probe=1`, `=1:finance`, `=3` iki kez; çıktı commit mesajına **taban** olarak yazılır |
| K3 | Saat: yalnız oyuncu başlatır | `time_manager.gd` (§3.1 sessiz `hold_clock` dahil, §3.5), `game_shell.gd` (`request_speed`), `main.gd` (§3.2, `_return_to_office`, `_run_travel_shot`), `product_tab.gd` (§3.3), `save_manager.gd` (§3.5, tek hunk), `office_people.gd` + `office_travel.gd` (§3.6), smoke (beş güncelleme + `clock_resumes_only_by_player`, U1 assert'i), Zaman Modeli §1.2/§8.5, ACIK 104(5), HARITA 19/84/86, CLAUDE §12 flow cümlesi, GUNCELLEMELER ch12 §2 `:380` (U11 cümlesi) | §3 kabulü (3.5, 3.6 dahil); `--inbox-shot=flow`; `--travel-shot=ishani`, `=home`, `=ishani:night` (`day=` aynı, S30); `run_gate.sh` 3/3 (regresyon) |
| K4 | Saat: tutuşun nedeni, duraklı hâl, tutuşta görüşme kapalı, kapıdan sonra Ürün | `time_manager.gd` (§4.1), `game_shell.gd` (`say_held`, grup), `top_bar.gd`, `TopBar.tscn`, `localization/strings.csv` (3 anahtar; §4.7 onaylıysa `SYS_RESUME` değeri), `main.gd` (`--clock-shot`, `--invite-shot=held|lapse`, §3.7 `_open_after_gate`, §4.5, §4.6 `_ring_call` + `_process` satış dalı), `meeting_invite.gd` (`_accept`), `hunt_tab.gd` (`_seed_block`, `hold_changed`), smoke `clock_resumes_only_by_player` (§4.5 assert'leri), Zaman Modeli §8.5 (A11), HARITA 84/85 | lint + loc kapıları; `--clock-shot` TR/EN (`gate`: `window=product`, S03); `--inbox-shot=flow` adım 9 değişmedi; `--invite-shot=held`, `=lapse` TR/EN; §4.7 onaylıysa `--modal-shot=system` TR/EN; commit mesajı "TR/EN onay bekliyor" |
| K5 | Saat: odak kaybında duraklat, özet notu | `time_manager.gd`, `settings.gd`, `settings_modal.gd` (§5, §5.1), `localization/strings.csv` (`SET_PAUSE_UNFOCUSED`, `SET_SUMMARY_FREQ_NOTE`), Zaman Modeli §1.2 | loc kapıları; `--clock-shot=focus_out` (`after=0`), `=focus_out_off` (`after=1`); `--modal-shot=settings_end` TR/EN (iki satır) |
| K6 | Üst bar: akıcı saat ve hafta çubuğu | `top_bar.gd` | `--day-shot=home:1` ve `=plaza:3` kareleri |
| K7 | Üst bar ve Finans: yenileme birleştirme | `top_bar.gd`, `hunt_tab.gd`, `finance_ozet_view.gd` (`:57-85`, `:95-98`), `piyasa_tab.gd`, ACIK yeni madde (A9) | `--tick-probe` §7 kabulü; `--tab-shot=finance`, `=piyasa` K6 commit'inin karesiyle piksel aynı (TopBar dahil) |
| K8 | Gece: hep kararma ve ısınma | `office_people.gd:95-114`, `main.gd` (`_warm_catalogs`, iki mount) | `--day-shot=home:1` kararma karesi; `--tick-probe=1` `first_hour` (K2 tabanına karşı, rapora); `--office-crowd-probe=ishani:6:1` CROWD satırları değişmedi |
| K9 | Kayıt: otomatik kayıt yazımı işçi iş parçacığında | `save_manager.gd`, smoke `autosave_writes_off_thread`, Zaman Modeli §6.5, HARITA 33 | §8.3 kabulü; üç kayıt vakası |
| K9b | Saat: gece dilimleme (koşullu, §8.4) | `time_manager.gd` (gece yolu) | yalnız K9 sonrası `TICK|night` > 60 ms ise, rapordan sonra; `--tick-probe=1`, `=3` iki kez; `--day-shot=home:1` kararma |
| K10 | Belgeler: kapanış | kalan HARITA satırları, Zaman Modeli kalan 4× yerleri (§11) | `--tick-probe` son ölçüm; `run_gate.sh` 3/3; dokunulan smoke vakaları bir kez daha |

Push yok; yalnız dokunulan vakalar (CLAUDE §10). B ve C'nin A'ya bağlı hunk'ları K10'dan sonra (§1). §4.7 onayı K4'ten
sonraysa ayrı küçük commit (`strings.csv` tek değer; loc kapıları, `--modal-shot=system` TR/EN).

## Dokunulacak dosyalar

`scripts/systems/time_model.gd`, `scripts/autoload/time_manager.gd`, `scripts/main/game_shell.gd`, `scripts/main/main.gd`,
`scripts/ui/components/top_bar.gd`, `scenes/ui/components/TopBar.tscn`, `scripts/tabs/product_tab.gd` (yalnız `:22`,
`:109-114`, `:245-258`), `scripts/tabs/hunt_tab.gd` (§7.2; §4.5), `scripts/tabs/finance/finance_ozet_view.gd`, `scripts/tabs/piyasa_tab.gd`,
`scripts/ui/office/office_people.gd` (yalnız `:95-114` kararma ve §3.6 kurucu dönüşü, A4'ün gereği: `:15`, `:130-133`, `:203-214`,
`:622-629` ve yeni `seat_founder_now`), `scripts/ui/office/meeting_invite.gd` (yalnız `_accept`, §4.5),
`scripts/autoload/save_manager.gd`, `scripts/autoload/settings.gd`, `scripts/modals/settings_modal.gd`,
`scripts/debug/endgame_smoke.gd` (yalnız §10), `scripts/debug/tick_probe.gd` (yeni), `localization/strings.csv` (yalnız
A1'in 5 anahtarı, F10; onaylanırsa §4.7'nin `SYS_RESUME` değeri, F11), `scripts/ui/office/office_travel.gd` (yalnız `:171`,
A2, ve `travel_home` `:94-105`, A4'ün gereği), `GDDs/GDD — ZAMAN MODELİ.md`, `GDDs/GUNCELLEMELER.md` (yalnız `:380`'in TopBar
cümlesi, U11), `docs/ACIK_ISLER/ACIK_KARARLAR.md`, `docs/HARITA.md`, `CLAUDE.md` (§6, §12). `main.gd`'de A saat, hız, tutuş,
çağrı, kapı sonrası ve ısınma yollarının ve kendi harness kollarının sahibidir (§3.7 `_open_after_gate`, F2; §4.6
`_ring_call` + `_process` satış dalı, F1); `finance_ozet_view.gd`'de yalnız `:57-85` ve `:95-98` (Ek hükmüyle onaylı).
B'nin A dosyasına hunk'ı (A yazmaz): `scripts/debug/tick_probe.gd` tutuş kolunda kapıda `publish()`, release'te
`plan_next()` (U2; K2 sonrası tek hunk, B commit 7). B ve C'nin öbür hunk'ları §1'de.

## Sahibe bırakılan kararlar

§0 "onay bekliyor" satırları (A10) ve §4.4 TR/EN tablosu: A1'in beş anahtarı ve `SYS_RESUME` "Oyuna dön / Back to game"
(F11, onaydan sonra uygulanır, §4.7). Öbürleri hükümle gövdeye işlendi (F1 §4.6, F2 §3.7, F10 §5.1). Ek olarak:
- **→ Onarım 1** (D grubu, F1; A dokunmaz): S42 ofis kartı `office_map_card.gd:29-33` yalnız kurulurken okur (`office_city.gd:99-100`), harita saati tutmaz.

**→ Onarım 1** (F12; A dokunmaz), S39'un A'nın dosyası olmayan iki parçası:
- S39 · VC: düşen VC çağrısı cezasız yeniden çalar (`vc_pitch_system.gd:756-765`), ceza yalnız `postpone_call`'da (`:771-778`).
- S39 · çerçeve: istenen görüşme "Gelen arama · {hour}:00" ile çalar (`strings.csv:1788`, `meeting_invite.gd:95-163`; TR/EN).

## Erdem'in bakacakları

- TopBar: II, 1×, 2×, 3×; saat `HH:MM` akıyor; çubuk ucu kayıyor (saatlik sıçrama yok).
- Duraklıyken "DURDU · BOŞLUK İLE SÜRDÜR" (EN "PAUSED · SPACE TO RESUME"; II yanıp sönmesi onaya bağlı); sürüm notunda
  "SÜRÜM NOTU AÇIK" ve pasif tuşlar; notu kapatınca saat duruk; notun yerini alan kart cevaplanınca Ürün geri açılır (§3.7).
- Her shot artık duraklı açılır: `--tab-shot` ve öbür kareler DURDU satırını taşır (taban görüntüler değişir).
- Alt+Tab: oyun durur; Ayarlar > Oyun'da "Odak kaybında duraklat" kapatılınca durmaz.
- Ev'de mesai sonu kısa kararma (`--day-shot=home:1`); oturum dönüşü: kurucu masasına yürür, saat duruk (A4).
- Sürüm notu ya da plan açıkken "Görüşmeye git": görüşme açılmaz, tost nedeni söyler (A11).
- Düşen satış zili tostla nedenini söyler (§4.6, F1); Ayarlar > Oyun'da özet notu (§5.1, F10); "Devam" etiketi onaya bağlı (§4.7, F11).

## Doğrulama listesi

- [ ] K1–K10 ayrı commit, her birinde inceleme ajanının bulguları kapalı.
- [ ] `TimeModel.SECONDS_PER_HOUR` 4 giriş; repoda `Speed4Btn`, `KEY_4` (hız anlamında), `resume_if_paused`,
      `_restore_speed` kalmadı; `grep -rn "_pre_[a-z_]*_speed\|_held_speed" scripts/` boş (rapora).
- [ ] `grep -rn "speed_change_requested.emit" scripts/ | grep -v scripts/debug/ | grep -v "emit(0)"` yalnız
      `GameShell.request_speed`, `top_bar.gd:110` ve main.gd harness kolları (`_run_render_probe`, `_run_tempo_probe`,
      `_gate_flow`, `_run_travel_shot`, `_run_invite_shot`, `_run_day_shot`, `_run_tick_probe`, `_run_clock_shot`); rapora.
- [ ] §12 tablosunun her kapısı yeşil; `--tick-probe` taban (K2) ve son (K10) yan yana; K9b commit'li ya da "gerekmedi" (A6).
- [ ] Görsel kabul TR ve EN, 1920×1080 ve 1280×720: `--clock-shot` sekiz durum, `--day-shot=home:1`, `--modal-shot=settings_end`.
- [ ] §0b: S03 `--clock-shot=gate` `window=product`; S30 `--travel-shot=ishani:night` `day=` aynı, `night=1`; S39
      `--invite-shot=lapse` tostlu; S52 not satırı; S42 "Devam" uygulandı ya da "onay bekliyor"; U1 `hold_clock` ikinci çağrıda sessiz (smoke).

## Done mesajı

```
SAAT bitti · main'de K1–K10 (<hash listesi>), push yok.
✅/⚠️/❌ Merdiven 1×/2×/3× · tempo 1× <ms> (<dev>), 2× <ms>, 3× <ms>
✅/⚠️/❌ Saat yalnız oyuncuyla · clock_resumes_only_by_player + 5 vaka yeşil · run_gate 3/3
✅/⚠️/❌ Oturum dönüşü masaya kadar · TRAVEL|settled <ms> · Yükleme duraklı · from_dict({}) → 0
✅/⚠️/❌ Duraklı hâl, tutuş nedeni, tutuşta görüşme kapalı · clock_shot_*.png (TR/EN)
✅/⚠️/❌ Odak kaybında duraklat · CLOCKSHOT focus_out after=0, focus_out_off after=1 · Ayarlar satırı
✅/⚠️/❌ Akıcı saat · day_shot_home_1_NN.png
✅/⚠️/❌ Takılmalar · gece max <taban> → <son> ms · saat p95 <> → <> · Finans saat p95 <> → <>, after_hour <> · ilk saat <>
Gece dilimleme (K9b): <commit | gerekmedi> · <K9 sonrası gece max>
✅/⚠️/❌ Pürüzler · S03 gate window=<> · S30 day=<> night=<> · S39 lapse tostu · S52 not · S42 Devam <commit | onay bekliyor>
Onay bekleyen: metinler TOPBAR_PAUSED, CLOCK_HOLD_RELEASE_NOTE, CLOCK_HOLD_MILESTONE, SET_PAUSE_UNFOCUSED,
SET_SUMMARY_FREQ_NOTE, SYS_RESUME · sabitler (A10)
PAUSE_BLINK_S 0,8 sn (uygulanmadı), ilk saatlik adım ≤ 16,7 ms · yardımcı yönetmene: ACIK 85(2), 104(1)(2)(10), GUNCELLEMELER :390/:434
```

## Öğretici notlar

- **SENKRON KURALI** (`time_manager.gd:20-25`): işçi yalnız hazır sözlüğü metne ve diske çevirir; yakalamayı taşımak
  saati kendisiyle çelişen bir kayda yazar.
- **Tutuş, duraklatma, dondurma.** Tutuş hızı 0 yapar, oyuncunun hız isteğini yutar; bırakmak hiçbir şey başlatmaz. Düz
  duraklatma (`emit(0)`: notlar, telefon zili, Ayarlar) altında Space çalışır. Dondurma birikimi durdurur, ağaca yalnız
  `tree_runs` ile dokunur; gece dondurması onu almaz: duraklatma gece yürüyüşünü de durdurmalı (`time_manager.gd:50-52`).
- **İş parçacığı.** `_capture_systems` (`save_manager.gd:307-316`) canlı dizi paylaşabilir: işçiye yalnız `duplicate(true)`;
  her `add_task` tam bir kez `wait_for_task_completion`; işçi `GameState`'e, ağaca, sinyale dokunmaz, `call_deferred` ile döner.
- **Odak bildirimi** duraklıyken de gelir (MCP'de izole `settings.json`'da `pause_unfocused` false). Her ölçümü iki kez
  koş (R4'te tempo bir kez %+11,9 saptı). `--tick-probe` `auto_*` yazar: izole `APPDATA` (`TICK START udir=`).
- `call_deferred` aynı karenin sonunda, `process_frame` tek seferlik bağlantı sonraki karede koşar. `visibility_changed`
  yalnız düğümün kendi `visible`'ı değişince gelir.
- **Smoke tuzakları.** `emit(4)` `push_warning` basar, vakayı düşürmez; `topbar_speed_cluster_*` kaynak metni okur: adı ve
  dizgiyi aynı commit'te değiştir.
