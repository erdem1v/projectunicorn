# SONLAR VE GAZETE: TEK BİLEŞEN, İKİ MOD (tasarım notu)

**Tarih:** 2026-09-25
**Hazırlayan:** lokal agent
**Sahip:** Erdem
**Durum:** KISMEN UYGULANDI (`f50d481`, sahip onayı 2026-09-25). Sahibin kararları ve uygulananlar **§U**'da. §1–§4 uygulamadan ÖNCEKİ kodu anlatır; o bölümlerdeki satır numaraları da o hâle göre. K17 (§5), seed ticker (§6) ve D5 (§7) uygulanmadı.
**Kod tabanı (§1–§7):** notun ilk commit'i `3bf7530` (oyun kodu `fc58e7c` + `86e33eb`'teki madde 5 geri alması). Bu kısım için Godot koşulmadı; her bulgu kod okunarak çıkarıldı. §U'daki kanıtlar koşulmuş smoke vakalarıdır.
**Onay bekliyor:** §U.4'teki maddeler ve §5–§7'nin `[ÇALIŞMA]` önerileri.

Kurallar:
- Satır referansları `project-unicorn/` köküne göre.
- `[ÇALIŞMA]` = sahip onayı bekleyen her öneri: sayı ya da yapı (eşik, ad, yer, sıra, seçenek).
- `[çıkarım]` = koddan çıkarıldı, koşulmadı.
- `[doğrulanmadı]` = kodda ya da koşuda gösterilemedi.
- Yeni Frank satırı yazılmadı. Gereken yerde "Frank satırı gerekir (sahip yazar)" yazıyor.
- D1–D13'e yalnız bağımlılık notu olarak değinilir. D tablosunun içeriğine dokunulmaz (`HANDOFF_series_a.md:199`).

---

## 0. Karar (sahip, 2026-09-25)

Kaynak: `HANDOFF_series_a.md:161-171`.

- Series A ve bootstrap sonları gazeteyle gösterilir. Tek bileşen, iki mod.
  - **Son modu** (demo build): Series A bir sondur. Wishlist ve mağaza öğeleri görünür.
  - **Kilometre taşı modu** (EA / tam build): wishlist gizli. İki buton: "Devam et" ve "Ana menü" (kayıt korunur).
- Mod = build bayrağı + son türü.
- Kayıp sonları her build'de son.
- Series A'nın kilometre taşı modu, Perde 3 oynanabilir olana kadar kapalı.
- Manşet imzalanan şartları okur (K17 ile birleşir).
- Seed gazete değil, ticker haberi.
- Bootstrap kilometre taşından sonra 730. gün kayıp sayılmamalı.

---

## U. Uygulama durumu (2026-09-25, `f50d481`)

Sahibin ikinci mesajı ve cevapları bu notun açık kararlarının bir kısmını kapattı. Uygulama `f50d481` commit'inde. Bu bölüm o hâli anlatır; §1–§4 uygulamadan önceki kodu anlatmaya devam eder.

### U.1 Sahibin kararları ve koddaki karşılıkları

| Karar (sahip, 2026-09-25) | Kodda |
|---|---|
| Gazete iki kaleme ayrılır: demo ve normal oyun (EA / tam). Demo olduğu gibi kalır. | `EndingsSystem.ending_mode(id)`. Demo'da her son `ending`; ekran ve ray eskisiyle aynı. |
| EA / tam: kötü sonlar oyunu bitirir. | `bankruptcy`, `brand_collapse`, `vc_rejection_cascade`, `running_on_fumes`: `ending`. |
| EA / tam: pozitif durumlar oyunu bitirmez. | `profitable_bootstrap` → `trigger_milestone`. Gazete bir kez açılır; `run_active`, `ending_id` ve olay kuyruğu değişmez. |
| Series A Perde 3'e kadar son kalır. | `series_a_close` her build'de `ending`. |
| Frank gazetede konuşmasın: demo'da kalsın, EA / tam'da kalksın. | `ending_scene.gd` Frank şeridini yalnız demo'da kurar. |
| Mevcut gazete görünümü bozulmaz. | `_build_paper` değişmedi. Farklar yalnız rayda ve gazetenin altındaki şeritte. |
| 730: (a) sınır kalkar. | `bootstrap_milestone_taken()` true iken `_check_soft_cap` çalışmaz. Telgraf zinciri (`final_stretch_*`, `arc_final_stretch`) `phase.bootstrap_milestone` ile susar. |
| Ana menü: "sanki varmış gibi ekle". | ANA MENÜ koşuyu **elle kayıt slotuna** yazar (`next_manual_slot_id`), sonra oyunu TEKRAR DENE gibi yeniden başlatır. Ana menü sahnesi gelince yalnız yeniden başlatma satırları değişir. |

**Ray, üç durumda** (smoke `ending_paper_modes_on_screen`):

| Öğe | Demo son | EA / tam son | EA / tam kilometre taşı |
|---|---|---|---|
| Frank şeridi | var | yok | yok |
| "SIRADA NE VAR?" + Series B / Halka arz kartları | var | yok | yok |
| WISHLIST'E EKLE | var | yok | yok |
| Koşu satırı "BU RUN: …" | var | var | yok |
| TEKRAR DENE · ZOR MOD · GAZETEYİ PAYLAŞ | var | var | yok |
| KİLOMETRE TAŞI başlığı + "Bu bir son değil. Şirket yoluna devam ediyor." | yok | yok | var |
| DEVAM ET · ANA MENÜ | yok | yok | var (sahibin "iki buton" kararı; paylaş yok) |

**Akış ayrıntıları** (hepsi smoke ile sabit):
- **Saat kilidi.** `TimeManager.hold_clock / release_clock`. Gazete açıkken başka bir yüzeyin (kart, ay özeti, ayarlar) hız geri yüklemesi saati başlatamaz. DEVAM ET kilidi bırakır ve gazeteden önceki hızı geri açar. Vaka: `milestone_clock_hold`.
- **Aynı gün açılmış kart.** Gazete kartın **altına** takılır: önce kart cevaplanır. Aksi hâlde gazete kartı örter, ANA MENÜ de görünmeyen bir karar ekranı yüzünden kaydı reddederdi. Vaka: `milestone_paper_under_card`.
- **Ay özeti.** Sonlardan sonra çalışır (slot 10 > 9), yani gazetenin üstünde açılır. Kapanınca gönderdiği hız isteği kilitte kalır.
- **Mandal.** `GameState.bootstrap_milestone_day`; kayıtla kendiliğinden taşınır, eski kayıtta −1. Gazete koşu başına bir kez açılır. Vaka: `bootstrap_milestone_keeps_the_run`.
- **Demo'da açılan kilometre taşı kaydı.** Mandal ancak build de kilometre taşı modundaysa sayılır (`bootstrap_milestone_taken()`). Demo'da o kayıt demo gibi biter: kazanç ve 730 sınırı geçerli. Vaka: `ending_modes_by_build`.
- **730'u geçen koşunun gazetesi.** Yeni süre ifadesi: `END_SPAN_OVER_TWO_YEARS`, "iki yılı aşkın sürede" / "in over two years" (gün ≥ 745).
- **Kilometre taşından sonra** Series A imzası da satış da hâlâ bir sondur.

### U.2 Build bayrağı

- `EndingsSystem.build_scope()` şu sırayla okur:
  1. Testlerin sabitlemesi `build_scope_override`.
  2. `OS.has_feature("full")`, sonra `OS.has_feature("ea")`. Bunlar dışa aktarma ön ayarındaki özel etiketler.
  3. Yalnız debug build'de `--build=<demo|ea|full>`: komut satırından ya da Project Settings → Application → Run → Main Run Args'tan.
  4. Varsayılan `demo`.
- **Editörde EA akışını oynamak için** Main Run Args'a `--build=ea` eklenir. Smoke ve run probe demo'ya sabitli, bu ayar onları etkilemez.
- `export_presets.cfg` hâlâ yok. EA export'u kurulurken ön ayara `ea` özel etiketi eklenmeli; yoksa export demo gibi davranır.
- **Series A anahtarı kurulmadı.** Perde 3 geldiğinde gerekenler:
  - `ending_mode`'da `series_a_close` için milestone dalı;
  - `sign_table` (`vc_pitch_system.gd`) ve günlük `series_a_closed` yedeğinin `trigger_milestone`'dan geçmesi;
  - bootstrap'takine benzer bir mandal;
  - `investor.series_a_closed` okuyan beş içerik dosyasının yeniden tanımlanması (§3.3).

### U.3 Değişen dosyalar (`f50d481`)

- **Sonlar ve saat:**
  - `scripts/systems/endings_system.gd`: build ve mod çözücü, `trigger_milestone`, `bootstrap_milestone_taken`, iki kısa devre;
  - `scripts/autoload/time_manager.gd`: saat kilidi;
  - `scripts/autoload/game_state.gd`: mandal;
  - `scripts/autoload/event_bus.gd`: `milestone_reached`.
- **Ekran:**
  - `scripts/main/main.gd`: gazeteyi kurma, DEVAM ET, ANA MENÜ;
  - `scripts/modals/ending_scene.gd`: iki mod;
  - `scripts/systems/endings_copy.gd`: süre ifadesi.
- **İçerik ve belgeler:**
  - `scripts/events/seams/seams_world.gd` ve `docs/SEAM_REGISTRY.md`: `phase.bootstrap_milestone`;
  - üç `final_stretch_*` kartı ve `soft_cap_stretch` arkı;
  - `localization/strings.csv`: `ENDING_MILESTONE_HEAD`, `ENDING_MILESTONE_BODY`, `ENDING_MAIN_MENU`, `END_SPAN_OVER_TWO_YEARS`. DEVAM ET için mevcut `UI_CONTINUE`.
  - `docs/design/localization_glossary.md`;
  - üretilmiş `docs/EVENT_SIGNAL_MANIFEST.md` ve `docs/content/events_draft/_vocabulary.md`.
- **Testler:**
  - `scripts/debug/endgame_smoke.gd`: 5 yeni vaka, demo sabitlemesi;
  - `scripts/debug/run_probe.gd`: demo sabitlemesi.
- **Dokunulmayanlar:**
  - `tuning.gd` (`SHIPPED_SCOPES`), `vc_pitch_system.gd`, `save_manager.gd`, `export_presets.cfg`;
  - ayrı bir `release_scope.gd` açılmadı; çözücü `endings_system.gd`'de.

### U.4 Açık kalanlar (onay bekliyor)

1. **Satış (`acquisition`) EA / tam'da son.** Sebep: şirket artık oyuncunun değil. Tonu `soft_win` olduğu için "pozitif durum oyunu bitirmez" kuralına istisna sayılır. Kilometre taşından sonra teklif hâlâ gelebilir. Onay bekliyor.
2. **İki build kaynağı.** `SHIPPED_SCOPES` (kart kapsamı) hâlâ `["demo"]` sabit; build'i okuyan yalnız sonlar. İlk `ea` kapsamlı kart gelmeden bu ikisi tek kaynağa bağlanmalı. Yoksa o kart EA build'de hiç gelmez.
3. **Gazete dışındaki "yakında" izleri.** EA / tam'da hâlâ görünüyorlar:
   - Av sekmesindeki kilitli "— · Tier 2'de / Yakında" satırı;
   - Pazarlama sekmesinin `"lock": "ea"` kilidi.
4. **ANA MENÜ sonrası.** Oyun şirket kurma ekranıyla açılıyor, orada kayıt yükleme girişi yok. Kayıt, yeni oyunda ESC → Yükle ile açılır. Ana menü sahnesi gelince kapanır.
5. **Yeniden başlatma argümanları.** TEKRAR DENE gibi argümansız yeniden başlatır. Debug'da komut satırından verilen `--build=ea` yeniden açılışta düşer. Main Run Args'taki ayar kalır. Kayıt demo'da açılırsa demo gibi davranır (U.1).
6. **Frank ve K17.** K17'nin "Frank'in hüküm satırı" (§5.5) artık yalnız demo gazetesinde görünür. Sahibin "Frank gazetede konuşmasın" yorumuyla birlikte §5.5 yeniden değerlendirilmeli.
7. **§5–§7** (K17, seed ticker, D5) uygulanmadı.

---

## 1. Bugünkü yapı

### 1.1 Tek terminal seam: `trigger_ending`

`EndingsSystem.trigger_ending(ending_id, telegraph, extra = {})` (`scripts/systems/endings_system.gd:408-422`). Sırası:

| # | Adım | Satır |
|---|---|---|
| 1 | Koşu zaten bittiyse döner ("first terminal wins") | `:410-411` |
| 2 | Bilinmeyen id: uyarı, döner | `:412-414` |
| 3 | `_assert_telegraph` (kayıp sonunda telgraf yoksa hata basar, engellemez) | `:415`, `:426-442` |
| 4 | `GameState.set_run_active(false)` | `:416` |
| 5 | `GameState.ending_id = ending_id` | `:417` |
| 6 | `EventGate.flush()`: yalnız kuyruk boşalır, açık kart kalır | `:418`; `scripts/events/event_gate.gd:171-174` |
| 7 | `EventBus.run_ended.emit(...)`, sonra `speed_change_requested.emit(0)` | `:421-422` |

Üretimdeki doğrudan çağrılar (`grep`, 9 yer):
- Günlük tarama: `endings_system.gd:109` (series_a_close yedeği), `:159` (bankruptcy), `:184` (brand_collapse), `:216` (vc_rejection_cascade), `:269` (profitable_bootstrap), `:285` (running_on_fumes).
- Series A imzası: `scripts/systems/vc_pitch_system.gd:529`.
- Kart fiili: `scripts/events/core/effects.gd:612`. Tek kullanıcısı `data/events/cards/funding/acquisition_offer.json:62-64` (`"ending_id": "acquisition"`).
- Hata ayıklama tuşu F3: `scripts/main/game_shell.gd:238`.
- Fonksiyonun yorumu "TEN callers" diyor (`endings_system.gd:401`). `grep` 9 buluyor. Onuncusu `[doğrulanmadı]`.

Günlük tarama sırası (`endings_system.gd:101-121`):
1. `series_a_closed` yedeği (`:108-110`)
2. kepenk (`:111`)
3. marka çöküşü (`:113`)
4. ret zinciri (`:115`)
5. kârlı bootstrap (`:117`)
6. 730 sınırı (`:119`)
7. satın alma penceresi damgası (`:121`)

### 1.2 `ENDINGS` yalnız ton tutuyor

`endings_system.gd:72-98`. Başlık ve Frank satırı CSV'de: `END_META_<ID>_TITLE` / `_FRANK` (`:473-480`; `localization/strings.csv:2090-2103`).

| Son | Ton |
|---|---|
| `series_a_close` | `win` |
| `acquisition` | `soft_win` |
| `bankruptcy` | `loss` |
| `brand_collapse` | `loss` |
| `vc_rejection_cascade` | `loss` |
| `profitable_bootstrap` | `win` |
| `running_on_fumes` | `soft_loss` |

- `_assert_telegraph`, `loss` ve `soft_loss`'u kayıp sayar (`:428`).
- Kararda geçen "kovulma" (`HANDOFF_series_a.md:166`) bugün bir son değil. `ENDINGS`'te 7 id var (`:76-98`).

### 1.3 `run_ended` verisi

- `_build_ending_data` (`endings_system.gd:445-467`) şu anahtarları yazar: `ending_id, title, tone, frank_line, day, cash, mrr, brand, reputation, phase, customers, employees, company_name, founder_name`. Sonra `extra` üstüne yazılır (`:466`).
- Series A imzasında `_sign_extra` şunları ekler: `signed_vc, valuation_m, dilution_pct, board_seats, board_veto, money_raised` (`vc_pitch_system.gd:548-558`).
- Gazete bu ekleri okumaz. Şartları koşu defterinden (`GameState.get_run_ledger()`) okur (`scripts/modals/ending_scene.gd:53`; `scripts/autoload/game_state.gd:327-334`, `:908-912`).
- `signed_vc` koşu defterinde yok. Yalnız veride ve `vc_states[vc].status = "signed"` içinde kalıyor (`vc_pitch_system.gd:527`).
- `run_ended`'e bağlanan tek oyun kodu `scripts/main/main.gd:2532`. Smoke da dinliyor (`scripts/debug/endgame_smoke.gd:72`, `:1841`).

### 1.4 Gazete ve Frank şeridi

- `main.gd:25` gazeteyi yükler: `preload("res://scenes/modals/EndingScene.tscn")`.
- `_on_run_ended` (`main.gd:2930-2944`) sahneyi bir kez kurar (`:2936`) ve hızı geri açmaz. Referans yalnız `_teardown_run_ui` içinde temizlenir (`:3134`). `main.gd:43`: "mounts once, never dismissed back to gameplay".
- `EndingScene.populate` → `EndingsCopy.build` (`ending_scene.gd:51-64`; `scripts/systems/endings_copy.gd:54`). Sahnenin başlığı: "There is no dismiss-back-to-gameplay path: the run is over." (`ending_scene.gd:14-16`).
- **Frank şeridi** gazetenin dışında. Yükteki `frank_line`'ı okur, paylaşılan PNG'ye girmez (`ending_scene.gd:97-109`, `:202-215`).
- **Sağ ray** (`ending_scene.gd:347-447`):
  - "SIRADA NE VAR?" başlığı (`:355`);
  - Series B kartı, rozet `ENDING_BADGE_EA` "ERKEN ERİŞİM'DE" (`:364-366`; `strings.csv:134`);
  - Halka arz kartı, rozet `LOCK_FULL` (`:367-369`);
  - WISHLIST'E EKLE, her sonda görünür (`:371-377`);
  - koşu satırı "BU RUN: {days} GÜN · NORMAL MOD" (`:380`; `strings.csv:140`);
  - eylem satırı: TEKRAR DENE (süreci yeniden başlatır, `:492-495`), ZOR MOD · YAKINDA (kilitli, `:413-418`), GAZETEYİ PAYLAŞ (`:440-445`).
  - "Devam et" ve "Ana menü" yok.
- **HANDOFF'a düzeltme.** `HANDOFF_series_a.md:178` "Gazete sahnesi ve Frank'in şeridi `7946ff3`'te eklendi" diyor. Git'e göre:
  - gazete sahnesi `3ee3963` (2026-07-21) ile geldi (`git log --diff-filter=A -- scripts/modals/ending_scene.gd`);
  - `7946ff3` (2026-08-27) Frank şeridini ekledi (`+func _build_frank_strip`) ve raydaki EA/Tam kartlarını Series B / Halka arz kartlarıyla değiştirdi (`git show 7946ff3 -- scripts/modals/ending_scene.gd`).

### 1.5 Build kapsamı: başka bayrak yok

- `static var SHIPPED_SCOPES: Array = ["demo"]` (`scripts/events/core/tuning.gd:135`). Her build'de aynı. Yorumu: "No release-tier system exists in the codebase" (`:128-130`).
- Tek okuyucusu kart kapısı G2 (`scripts/events/gate/gate.gd:192-194`). Kartta alan yoksa varsayılan `"demo"` (`:192`).
- 43 kart JSON'unun 35'i `demo`, 8'i `fixture`. `ea` ya da `full` kapsamlı kart yok (`grep`, `data/events/cards`).
- Başka build bayrağı yok:
  - `export_presets.cfg` yok (`ls`);
  - `project.godot:15` yalnız motor etiketleri: `config/features=PackedStringArray("4.6", "Forward Plus")`;
  - `scripts/` içinde `OS.has_feature` yok (`grep`);
  - tek ayrım `OS.is_debug_build()`.
- EA kilidi koşulsuz: Pazarlama sekmesi `"lock": "ea"` (`scripts/theme/ui_tokens.gd:583`). Çözücü, boş olmayan her kilidi kilitli sayar (`scripts/ui/components/left_tabs.gd:177-182`).
- Mağaza: `STEAM_PAGE_URL := ""` (`ending_scene.gd:26`). Wishlist butonu basınca bir şey yapmaz (`:498-500`).
- Gazete dışında tek wishlist izi, Av sekmesindeki kilitli "— · Tier 2'de" kartı. Kodun notu: "Locked Tier-2 teaser (wishlist telegraph, §2)" (`scripts/autoload/investor_registry.gd:86-102`). Kart Av sekmesinin fon listesinde görünüyor (`scripts/tabs/hunt_tab.gd:202`). Mağaza bağlantısı başka yerde yok (`grep`).
  - Bu kartın EA / tam build'de ve kilometre taşı modunda ne olacağı açık karar (Açık kararlar 6).
- Ana menü yok. Sahneler `Main` ve açılış akışı (`scenes/onboarding`). Sistem menüsündeki "Ana menüye dön" kapalı, ipucu YAKINDA (`scripts/modals/system_menu_modal.gd:39-42`).

### 1.6 İki modla çelişen bugünkü metinler

| Anahtar | Metin | Sorun |
|---|---|---|
| `END_META_SERIES_A_CLOSE_FRANK` (`strings.csv:2091`) | "İmzaladın. Şimdi asıl iş başlıyor — ama o başka bir oyunun konusu." | Series A kilometre taşı modunda yanlış olur. |
| `ENDING_CARD_SERIESB_BODY` (`strings.csv:2837`) | "Series A oyunu bitirmez. … koşu devam eder." | Series A bugün her build'de koşuyu bitiriyor (`vc_pitch_system.gd:529`). |
| `ENDING_BADGE_EA` (`strings.csv:134`) Series B kartında | "ERKEN ERİŞİM'DE" | GDD ch14 §5 Series B'yi tam sürüme koyuyor ("Full release adds IPO · Series B"). |
| `ENDING_RUN_META` (`strings.csv:140`) | "BU RUN: {days} GÜN · NORMAL MOD" | "NORMAL MOD" zorluk modu (ch14 §2: "Difficulty: Normal + Hard"). Sabit yazılmış; zor mod gelince yanlış olur. Kilometre taşında "BU RUN: {days} GÜN" kısmı da yanlış, çünkü koşu bitmedi (§2.3). |

Eskimiş yorumlar:
- `endings_system.gd:36-39`: "THE SOFT CAP HAS NO TELEGRAPH: the D-1 Frank warning was retired…". İki iddia da eskimiş:
  - final_stretch zinciri telgrafı basıyor (`data/events/cards/world/final_stretch_press.json:22-23`, `:51-52`);
  - D-1'de Frank konuşuyor: `world.final_stretch_verdict`, gün ≥ 729, konuşan `char_mentor_frank` (`final_stretch_verdict.json:14`, `:24-27`). Kartın notu: "Frank speaks once, at D-1, which is GDD v2 ch.13's director ruling preserved" (`:2`).
- `ending_scene.gd:358-362` "RELEASE SCOPE table"a dayanıyor. O tablo `04e79c5` ile CLAUDE.md'den kalktı (`git show 04e79c5^:project-unicorn/CLAUDE.md`, satır 29-48).

---

## 2. Mod seçim tablosu

### 2.1 Tablo

- "Series A anahtarı" = §2.2'deki sabit `[ÇALIŞMA]`. "Perde 3 hazır" olana kadar **kapalı**.
- `[ÇALIŞMA]` işaretli hücreleri kararın metni açıkça söylemiyor.

| Son | Ton | Demo | EA | Tam |
|---|---|---|---|---|
| `series_a_close` | `win` | son | son (anahtar kapalı) / kilometre taşı (anahtar açık) | EA ile aynı |
| `profitable_bootstrap` | `win` | son | kilometre taşı | kilometre taşı |
| `acquisition` | `soft_win` | son | son `[ÇALIŞMA]` | son `[ÇALIŞMA]` |
| `bankruptcy` | `loss` | son | son | son |
| `brand_collapse` | `loss` | son | son | son |
| `vc_rejection_cascade` | `loss` | son | son | son |
| `running_on_fumes` | `soft_loss` | son | son `[ÇALIŞMA]`; bootstrap kilometre taşından sonra bkz. §4 | EA ile aynı |

Notlar:
- `acquisition` için öneri "son" `[ÇALIŞMA]`. Şirket satılınca devam edecek bir koşu yok. Satın almanın v1'de olup olmadığı D1'e bağlı (`ACIK_KARARLAR_D1-D13.md:244`; yalnız bağımlılık notu, D tablosuna dokunmaz).
- `running_on_fumes` tonu `soft_loss` ve kodda kayıp sayılıyor (`endings_system.gd:428`). Bu yüzden "kayıp sonları her build'de son" kuralına giriyor.
- GDD ile kod bugün iki yerde ayrışıyor. Mod tablosu bunları çözmez, yalnız not eder:
  - ch13 §1 "CUT: acquisition. EA: brand_collapse." diyor. İkisi de demo kapsamında bağlı (`acquisition_offer.json:5`; `endings_system.gd:113`).
    - Ama `brand_collapse`'a oynanarak ulaşılamıyor. Şartı olan `active_scandal`'ı true yapan tek yer hata ayıklama tuşu F6 (`game_shell.gd:251`). Kodun notu: "this ending is reachable only via debug" (`endings_system.gd:171-172`).
  - ch13 §1 bootstrap'ı "victory" diye tanımlıyor. EA'da kilometre taşı olması ch13'ün güncellenmesini gerektirir (sahip).

### 2.2 Bayraklar nerede yaşar `[ÇALIŞMA]`

Bugün hiçbiri yok (§1.5). Bu bölümün tamamı öneridir:

1. **Build türü tek kaynaktan okunur.**
   - Her build için bir dışa aktarma ön ayarı (export preset). Ön ayarda özel bir özellik etiketi (feature tag): `demo` / `ea` / `full` (adlar `[ÇALIŞMA]`).
   - Etiket tek yerde `OS.has_feature` ile okunur.
   - Editör ve ekransız koşularda özel etiket bulunmaz `[doğrulanmadı: motor belgesine bakılmadı]`. Yedek olarak varsayılan `demo` kalır.
   - Hata ayıklama build'inde bir komut satırı argümanı eklenebilir. Emsal: `--skip-onboarding` (`main.gd:403-407`, çağrı `:291`; `project.godot:17`).
2. **`SHIPPED_SCOPES` bu kaynaktan türetilir.** Demo'da `["demo"]`, EA'da `["demo", "ea"]`. `static var` kalır, çünkü motor sondası ve smoke onu geçici olarak genişletiyor (`tuning.gd:132-135`; `scripts/events/tools/engine_probe.gd:497-498`).
3. **Series A kilometre taşı anahtarı tek bir sabittir.**
   - Varsayılan `false`. Sahip, Perde 3 içeriği girince elle açar.
   - İleride gelebilecek bir koşu içi `act.current` seam'inden (`docs/design/VIZYON_v1_YANITLAR.md:64-66`, onaysız) türetilmez. O seam oyuncunun hangi perdede olduğunu söyler; bu anahtar ise build'in Perde 3 içeriğini taşıyıp taşımadığını söyler.
4. **Mod çözücü tek fonksiyondur.**
   - Ör. `ending_mode(ending_id) -> "ending" | "milestone"` (ad `[ÇALIŞMA]`).
   - Build türünü, son id'sini ve Series A anahtarını okur.
   - Yeri: küçük, ayrı bir script (ör. `release_scope.gd`, ad `[ÇALIŞMA]`). Sebep: iki okuyucusu olacak: `SHIPPED_SCOPES` ve sonlar.

Onaysız emsal: VIZYON, Series A imzasının Perde 3 için bir geçişe döneceğini ve "Demo/fest build'inde bir build bayrağıyla son olarak" kalacağını söylüyor (`VIZYON_v1_YANITLAR.md:72`). Belge onay bekliyor (`:3`).

"Perde 3"ün tanımı:
- Repodaki tek tanım `VIZYON_v1_YANITLAR.md`'de: "Series A imzası Perde 3'ü açar." (`:61`). Belge "ÖNERİ (Erdem onayı bekler)" statüsünde (`:3`).
- Kavramın kaynağı Erdem'in "Oyun Vizyonu v1" belgesi (31 Ağu 2026; `:7`, `:62`). Bu belge repoda yok `[doğrulanmadı: dosya adı ve metin taraması]`.
- Onaylı GDD'lerde koşu düzeyinde "Perde" geçmiyor `[doğrulanmadı: yalnız metin taraması]`.

### 2.3 Sağ ray, iki modda

| Öğe | Son modu (demo) | Son (EA / tam build) | Kilometre taşı modu (EA / tam) |
|---|---|---|---|
| WISHLIST'E EKLE | görünür (karar) | açık karar | gizli (karar) |
| "SIRADA NE VAR?" + Series B / Halka arz kartları | görünür (bugün) | açık karar | açık karar |
| TEKRAR DENE | görünür | görünür `[ÇALIŞMA]` | gizli `[ÇALIŞMA]`; karar iki buton diyor |
| ZOR MOD · YAKINDA | görünür, kilitli | bugünkü gibi `[ÇALIŞMA]` | gizli `[ÇALIŞMA]` |
| GAZETEYİ PAYLAŞ | görünür | görünür `[ÇALIŞMA]` | görünür `[ÇALIŞMA]` |
| Koşu satırı "BU RUN: {days} GÜN · NORMAL MOD" | görünür | görünür | açık karar; koşu bitmedi |
| Devam et | yok | yok | var (karar) |
| Ana menü (kayıt korunur) | yok | yok | var (karar) |
| Frank şeridi | var | var | var `[ÇALIŞMA]` |

- "Son (EA / tam build)" sütununu karar metni tanımlamıyor. Bu durum EA / tam build'deki her sondur: kayıp sonları, `acquisition` ve anahtar kapalıyken `series_a_close`.
- Karar wishlist ve mağaza öğelerini demo build'e bağlıyor (`HANDOFF_series_a.md:163-164`). "Mod = build bayrağı + son türü" kuralı (`:165`), ray öğelerinin moda değil build'e bağlı olabileceğini gösteriyor. Açık karar (Açık kararlar 6).
- EA build'de Series B kartındaki "ERKEN ERİŞİM'DE" rozeti yanlış okunur (`strings.csv:134`; §1.6).

---

## 3. "Devam et" akışı

### 3.1 `trigger_ending` neden kullanılamaz

`trigger_ending` koşuyu öldürür. Adım adım:

| Adım | Bugün | Kilometre taşı modunda `[ÇALIŞMA]` | Sebep |
|---|---|---|---|
| `set_run_active(false)` | var (`endings_system.gd:416`) | **olmamalı** | Saat durur (`scripts/autoload/time_manager.gd:102`). Hız > 0 isteği reddedilir (`:227-231`). Günlük ve saatlik dağıtım durur (`:254`, `:290`). Kayıt kapanır: `can_save()` false, sebep `SAVE_ERR_NO_RUN` (`scripts/autoload/save_manager.gd:143-144`, `:170-171`). |
| `ending_id` yazmak | var (`:417`) | **olmamalı** | Harness dolu `ending_id`'yi bir son olarak sayar (`scripts/events/tools/harness.gd:132-133`). Kilometre taşı bu sayımı kirletmemeli. |
| `EventGate.flush()` | var (`:418`) | **olmamalı** | Kuyruktaki kartlar veri. Devam eden koşuda yaşamalı (`save_manager.gd:145-154` yorumu). |
| `run_ended` yaymak | var (`:421`) | **olmamalı** | `main.gd` bir kez kurar ve hızı açmaz (`main.gd:2930-2944`). Smoke onu son sayar (`endgame_smoke.gd:72`). |
| `speed_change_requested(0)` | var (`:422`) | **olmalı** | Saat yalnız gazete açıkken durur. |
| `_assert_telegraph` | kazanç için işlem yok (`:429-430`) | gerekmez | Bootstrap ve Series A kazanç tonunda. |

### 3.2 Seam biçimi

İki seçenek:
- **(i) Ayrı bir `trigger_milestone(milestone_id, extra)`.** Önerilen bu `[ÇALIŞMA]`.
  - `trigger_ending`'in sözleşmesi "THE SINGLE TERMINAL SEAM" (`endings_system.gd:397`).
  - Yukarıdaki tabloda duraklatma dışında her adım farklı.
  - Bir bayrakla terminal fonksiyonu terminal olmayan bir şeye çevirmek, o sözleşmeyi bozar.
- **(ii) `trigger_ending(..., milestone = true)`.** Tek giriş noktası kalır, ama fonksiyonun içinde iki ayrı yol olur.

Her iki seçenekte `[ÇALIŞMA]`:
- Çağrı yerleri aynı kalır: tarama (`endings_system.gd:269`) ve imza (`vc_pitch_system.gd:529`). İkisi önce mod çözücüye sorar, sonra ilgili seam'i çağırır.
- Yeni bir sinyal gerekir (ör. `milestone_reached`, ad `[ÇALIŞMA]`). `run_ended`'e dokunulmaz.
- `main.gd` gazeteyi ayrı bir referansla kurar. "Devam et"te kapatır ve hızı geri açar.
  - Emsal: ay özeti kapanışı. Hızı yalnız `GameState.run_active and not EventGate.has_pending()` ise geri açar (`main.gd:2918-2925`).
- Gazete aynı `EndingScene`'dir. Mod, `populate` ile gelen veride taşınır.
- `_build_ending_data` yorumu "Live snapshot — safe because trigger_ending halts the world" diyor (`endings_system.gd:446-448`). Kilometre taşında bu güvence duraklatmadan gelir. Gazete açıkken saat durur.

### 3.3 Mandallar (günlük tarama yeniden tetiklemesin)

- **Bootstrap.**
  - `_check_profitable_bootstrap` her gün yeniden bakılan bir koşul: "A CONDITION evaluated daily, not a crossing." (`endings_system.gd:263-270`).
  - Koşu sürerse ertesi gün yine tetiklenir.
  - Gereken: koşuldan önce okunan bir gün damgası (ör. `bootstrap_milestone_day := -1`, ad `[ÇALIŞMA]`).
  - Emsal: `acq_road_over_day` (`game_state.gd:401`; `endings_system.gd:369-372`).
  - Kayıt kendiliğinden taşır. `SaveCodec` GameState değişkenlerini kendisi bulur (`scripts/systems/save_codec.gd:283-297`). Eski kayıtta alan yoksa yeni koşu varsayılanı kalır (`:300-309`). Şema değişmez.
- **Series A** (anahtar kapalıyken gerekmez; Perde 3 için kayıt):
  - Yedek, `series_a_closed` true oldukça her gün tetikler (`endings_system.gd:108-110`). O yüzden onun da mandalı olmalı `[ÇALIŞMA]`.
  - Beş içerik dosyası `investor.series_a_closed` okuyor: `soft_cap_stretch.json:18-24`, `final_stretch_press.json:39`, `final_stretch_comment.json:29`, `final_stretch_verdict.json:30`, `funding/seed_stalled.json:35`.
  - Series A sonrası sürüp giden bir koşuda bu alanın anlamı yeniden tanımlanmalı.
- **Tarama sırası.** Mandallı bootstrap kontrolü false dönünce aynı gün 730 sınırı ve satın alma damgası çalışır (`endings_system.gd:117-121`). Bu §4'ü ve satın almayı doğrudan ilgilendirir. Satın alma kartı bugün pratikte hiç görünmüyor, çünkü bootstrap önce geliyor (`ACIK_KARARLAR_D1-D13.md:28-29`). Kilometre taşından sonra kârlı bir şirkete satın alma teklifi gelebilir. Bu, K16/D4'ün sıra önerisine ("satın alma yalnız kârlı olmayan şirketlere düşer", `ACIK_KARARLAR_D1-D13.md:94`) ve D1'e bağlı (yalnız bağımlılık notu; D tablosuna dokunmaz). Bkz. Açık kararlar 9.

### 3.4 Kayıt ve "Ana menü"

- `run_active` true kaldığı için kayıt mümkün. Yine de `can_save()` şu durumlarda false:
  - açık olay kartı (`save_manager.gd:155-156`);
  - VC görüşmesi, masa, satış görüşmesi ya da pazarlık (`:157-164`).
- `can_save()` ekrandaki açık pencereye bakmaz (`:135-139`). Otomatik kayıt `day_tick_completed` ile çalışır (`save_manager.gd:483-506`). Bu sinyal dağıtımdan sonra yayılır (`time_manager.gd:282`). Yani kilometre taşı gazetesi açıkken aynı gün otomatik kayıt yazılabilir. Mandal taramada yazıldığı için o kayıt mandalı taşır `[çıkarım]`.
- "Ana menü"nün gidecek yeri yok. Ana menü sahnesi yok, sistem menüsündeki buton kapalı (§1.5). Ana menü gelene kadar ne olacağı açık karar. Seçenekler:
  - kaydet ve çık;
  - kaydet ve süreci yeniden başlat (TEKRAR DENE gibi, `ending_scene.gd:492-495`).
  - Açılış akışından (`scenes/onboarding`) kayıt yüklenebiliyor mu `[doğrulanmadı]`.
- Hangi slota yazılacağı da açık: elle kayıt slotu (`save_manager.gd:185`) ya da otomatik slot.

### 3.5 Aynı gün çakışması

- Ay özeti (slot 10), sonlardan (slot 9) sonra çalışır (`time_manager.gd:266-267`). Bugün yalnız `run_active` false olunca susar (`scripts/systems/month_summary_system.gd:34-35`).
- Kilometre taşında `run_active` true kalır. Gazete ve ay özeti aynı gün üst üste gelebilir.
- Bootstrap bugün normalde ay kapanışının ertesi günü tetikleniyor (smoke `profit_condition_fires`, `endgame_smoke.gd:11741-11769`).
- `faced_series_a` bir ay kapanışı günü true olursa çakışma mümkün `[çıkarım]`.
- Sıralama açık karar. Öneri: gazete ay özetinden sonra açılsın `[ÇALIŞMA]`.

---

## 4. 730. gün, kilometre taşından sonra

### 4.1 Bugün

- `SOFT_CAP_DAY := 730` (`endings_system.gd:41`).
- `_check_soft_cap`, `day >= 730` olan her günde başka bir şarta bakmadan `running_on_fumes` tetikler (`:275-286`).
- Aynı gün kârlılık da sağlanırsa kazanç öne geçer. Sebep tarama sırası (`:39-40`).
- Telgraf zinciri gün ve `series_a_closed == false` şartına bakıyor. Bir de ark içi sıra şartları var: `final_stretch_comment` ve `final_stretch_verdict` arkın açık olmasını, `final_stretch_comment` ayrıca `final_stretch_press`'in ateşlenmiş olmasını istiyor (`final_stretch_comment.json:19-22`, `:33-36`; `final_stretch_verdict.json:20-23`).

| Kart | Tür | Koşul | Mandal |
|---|---|---|---|
| `world.final_stretch_press` | olay motorunun `paper` sınıfı kartı (gazete ekranı değil) | gün ≥ 640 (`final_stretch_press.json:31-44`) | `one_shot` (`:14-16`) |
| `world.final_stretch_comment` | `interrupt` | gün ≥ 700, ark açık, `final_stretch_press` ateşlendi (`final_stretch_comment.json:17-38`) | `one_shot` (`:14-16`) |
| `world.final_stretch_verdict` | Frank konuşur, `interrupt` | gün ≥ 729, ark açık (`final_stretch_verdict.json:18-35`) | `one_shot` (`:15-17`) |

- Ark `restartable: false` (`data/events/arcs/soft_cap_stretch.json:5`). Yalnız `series_a_closed == true` ile söner (`:18-24`).
- Bootstrap kilometre taşından sonra bu üç kart yine gelir. Metinleri de yanlış okunur. Örnek, Frank kartı: "İki yıl oldu. Şirket ayakta, sen ayaktasın, ve kapı hâlâ açılmadı." (`final_stretch_verdict.json:59`).
- `running_on_fumes`'un Frank satırı: "Kaybetmedin. Sadece kazanmadın." (`strings.csv:2103`).
- GDD ch13 §1: "running_on_fumes — the 24-month soft cap is reached with neither victory condition met." ch13 §5: `running_on_fumes` = "you didn't lose, you just didn't win".
- İlgili öneri K15 (canlı teklif varken son gün uzasın) aynı kontrolü değiştiriyor (`ONERI_v3_K1-K32.md:115-116`).

### 4.2 Seçenekler (sahip seçer)

| | (a) Sınır kalkar | (b) Sınır kalır, nötr kapanış | (c) Sınır yeniden başlar |
|---|---|---|---|
| Ne olur | Bootstrap kilometre taşı alınmış koşuda 730 yok. HANDOFF'a göre koşu "yalnız kayıp sonları ya da oyuncunun 'Ana menü' seçimiyle biter" (`HANDOFF_series_a.md:185`). Kodda ise anahtar kapalıyken Series A imzası ve satın alma (D1'e bağlı; yalnız bağımlılık notu) da koşuyu bitirir. (a) bunları da kapatmalı mı, açık karar (Açık kararlar 9-10). | 730'da `running_on_fumes` yerine nötr bir "şirket yaşıyor" kapanışı. | Sınır, kilometre taşı gününden +N ay sonraya kayar. N `[ÇALIŞMA]`, ör. 6. |
| Kod | `_check_soft_cap` mandala bakar (`endings_system.gd:275-286`). | Yeni son id'si ya da varyant. `ENDINGS`'te nötr ton yok (`:76-98`). Yeni gazete kurucusu. | İkinci bir sınır hesabı. Kartlardaki sabit 640/700/729 eşikleri göreli olmalı. |
| İçerik | Üç final_stretch kartına ve arkın `invalidate_when`'ine mandal şartı eklenir. Kartlar GameState alanını yalnız seam üzerinden okur (CLAUDE.md: "every read is a named seam"). Mandal için ya yeni bir seam (emsal `investor.series_a_closed`, `scripts/events/seams/seams_world.gd:121`) ya da bir motor bayrağı (`flag` yaprağı, `scripts/events/core/condition.gd:265-266`) gerekir. Ark 640'tan sonra başladıysa kilometre taşı onu söndürmeli. | Telgraf metni uymuyor ("kapı hâlâ açılmadı"). Yeni ya da koşullu telgraf gerekir. | Kartlar `one_shot`, ark `restartable: false`. Zincir ikinci kez çalışamaz; yeniden kurulmalı. |
| Metin | `_span_phrase` 700 günde "iki yıla yakın" ile tavan yapıyor (`endings_copy.gd:34`, `:499-500`; `strings.csv:2170`). Örneğin 900. günde bir iflas "iki yıla yakın sürede" yazar. Yeni süre anahtarı gerekir (TR+EN). | Yeni manşet, alt başlık, defter satırları. Frank satırı gerekir (sahip yazar): 730'da nötr kapanış. | Yeni sınırda yine `running_on_fumes` gelirse "kazanmadın" sorunu yalnız ertelenir. (b) ile birlikte düşünülmeli. |
| Smoke | `soft_cap_ends_run_at_730` kilometre taşsız koşu için geçerli kalır (`endgame_smoke.gd:11052-11065`). Yeni vaka: kilometre taşından sonra 730'da son yok. | Yeni vaka: kilometre taşlı koşu 730'da nötr kapanır. `_assert_telegraph` yeni tonu kayıp saymazsa telgraf şartı düşer (`:428`). | Yeni vaka: sınır kayar, telgraf yeni sınıra göre gelir. Yoksa I3 hatası basılır (`:440-442`). |
| Risk | Koşunun takvim sonu yok. 730 sonrası denge kalibre edilmedi (ch01 §1: "24 game months soft cap"). Nakit geçmişi halka tampon (`CASH_HISTORY_CAP := 760`, `game_state.gd:218`), en eskiyi atar. 730 sonrası davranış `[doğrulanmadı]`. | "Devam et" 730'dan sonra anlamsız. Bu kapanış modda nasıl görünür, açık. | En karmaşık seçenek. |

Diğer testler:
- `no_calendar_stop_before_cap`, `soft_cap_no_defer_for_sheet`, `soft_cap_paper_names_unsigned_sheet`, `soft_cap_warns_open_hunt` (`endgame_smoke.gd:341-344`). Hepsi kilometre taşsız koşuyu kuruyor `[doğrulanmadı: vaka gövdeleri tek tek okunmadı]`.

### 4.3 Cloud tercihi

- **(a)** `[ÇALIŞMA]`. Sebep: ch13 §5'te `running_on_fumes` "kazanmadın" demek. Bootstrap kilometre taşı ise zaten kazanılmış (`HANDOFF_series_a.md:184-188`).
- ch13 §1'in tanımı da bunu destekliyor: sınır "neither victory condition met" durumu için.
- **Karşı görüş (onaysız öneri belgesi).** VIZYON saati bootstrap oyuncusu için de gün 1'e bağlı tutuyor (`VIZYON_v1_YANITLAR.md:118-126`). Bu, (a)'ya karşı bir görüştür:
  - "Bootstrap oyuncusunun saati olmaz." cümlesi (`:121`) saati seed'den saymamak için bir sebep. Yani belge bootstrap oyuncusunun da saati olsun istiyor.
  - Belge 730'da kârlı şirkete `profitable_bootstrap` veriyor (`:125-126`). Bu, ch13 §1'deki yüzleşme şartıyla ("Profitability alone is not an ending") de çelişiyor.
- **Onaysız emsal.** VIZYON "Perde 3'te 730 kapalıdır." diyor (`:132`). Bu Series A sonrasına (Perde 3) ait; bootstrap kilometre taşı için değil.
- Sahip seçer.

---

## 5. K17: manşet ve Frank hükmü şartları okur

### 5.1 Bugün

- Manşet, alt başlık ve resim altı iki varyant arasında seçiliyor (`endings_copy.gd:83-94`):
  - `founder_friendly` = Series A payı ≤ 18 ve veto yok (`FF_MAX_EQUITY := 18`, `:29`);
  - değilse `aggressive`.
- Koltuk sayısı ve değerleme varyantı etkilemiyor. Yalnız gazetenin defter satırlarında (`:97-105`) ve değerleme istatistik hücresinde (`:120`) görünüyor.
- Açılış şartları `vc_pitch_system.gd:441-465`'te türetiliyor:
  - pay, fonun `term_bands.dilution` sözcüğünden (`:456-458` → `scripts/systems/pitch_constants.gd:187`);
  - kurul, `investor_registry.gd` `opening_terms`'ten (`:459-464`; registry `:36`, `:51`, `:66`, `:81`);
  - değerleme MRR'dan (`:453-455`). Registry'deki `dilution_pct` ve `valuation_m` Series A'da okunmuyor.
- Bu açılışlarla dört fondan üçü hiç itmeden `founder_friendly` okunuyor. Yalnız Anchor (22 + veto) `aggressive`.
- `aggressive` metni devri iddia ediyor: "Kontrol El Değiştirdi", "koltukların çoğu artık yatırımcının" (`strings.csv:1985-1986`). Kodda yönetim kurulu büyüklüğü kavramı yok (`grep board_size` boş). Sabitlere göre kurucu payı %53'ün altına inmez: melek 4 + seed en çok 18 + Series A en çok 25 = 47 `[çıkarım]`.
- Frank satırı kimliğe göre tek satır: `END_META_<ID>_FRANK` (`endings_system.gd:454`, `:478-480`). Şartları okumuyor.
- GDD ch09 §7: "Terms taken (founder-friendly vs aggressive) change the ending copy and Frank's verdict line."
- GDD ch09 §5 kurucu dostu ↔ agresif eksenini yalnız koşulla tanımlıyor: "board seat, veto rights, milestone clauses". Kodda "milestone clauses" yok. Hiçbir GDD eşik vermiyor.

### 5.2 Okunacak alanlar

| Alan | Kaynak | Not |
|---|---|---|
| Series A payı (`equity_pct`) | `game_state.gd:910` | İmzalanan pay |
| Koltuk (`board_seats`) | `:911` | |
| Veto (`board_veto`) | `:912` | |
| Değerleme (`valuation_m`) | `:909` | MRR ile ölçekleniyor (`vc_pitch_system.gd:453-455`), sabit aralığı yok. Eşik girdisi olmasın `[ÇALIŞMA]`. |
| Alınan para (`investment_amount`) | `:908` | Değerleme × pay (`vc_pitch_system.gd:544`) |
| Toplam yatırımcı payı (`investor_equity_pct`) | `:924` | Melek + seed + Series A (`game_state.gd:719-725`) |
| Seed (`seed_lead`, `seed_amount`, `seed_equity_pct`) | `:917-919` | Seed koltuğu kaydedilmiyor. K21/D7 açık (yalnız bağımlılık notu; D tablosuna dokunmaz). |
| İmzalayan fon | yalnız veride `signed_vc` (`vc_pitch_system.gd:549`) | Frank hükmü fona göre değişecekse koşu defterine girmeli (açık karar) |

Öneri `[ÇALIŞMA]`: varyant yalnız **Series A şartlarından** hesaplansın.
- Koşu defteri Series A alanlarını bilerek ayrı tutuyor (`game_state.gd:904-907`).
- Toplam pay zaten istatistik satırında görünüyor (`endings_copy.gd:122`, `:484-492`).
- D7 onaylanırsa seed koltuğu Series A kurul toplamına eklenir (`ACIK_KARARLAR_D1-D13.md:128`; yalnız bağımlılık notu, D tablosuna dokunmaz).

### 5.3 Gerçek aralıklar

| | Değer | Kaynak |
|---|---|---|
| Açılış payı | Nexus 15 · Bosphorus 18 · Meridian 18 · Anchor 22 | `vc_pitch_system.gd:456-458`; `pitch_constants.gd:187` (`low` 15 · `mid` 18 · `high` 22) |
| Açılış kurulu | Anchor 1 koltuk + veto · Bosphorus 1 koltuk · Nexus 0 · Meridian 0 | `vc_pitch_system.gd:459-464`; `investor_registry.gd:36`, `:51`, `:66`, `:81` |
| Başarılı itiş | pay −4, taban 10; değerleme +4M; kurulda önce veto, sonra koltuk düşer | `pitch_constants.gd:140-142`; `scripts/systems/term_sheet_table_system.gd:846-862` |
| Geri alma (K7 "şartlı eşleşme") | pay +4, tavan 25; değerleme −4; kurulda +1 koltuk (en çok 2), sonra veto | `term_sheet_table_system.gd:454-466`, `:95`, `:106`; `pitch_constants.gd:186` |
| Kurul ağırlığı | koltuk + (veto ? 1 : 0), aralık 0–3 | `term_sheet_table_system.gd:426-427` |
| Seed | pay 12–18, tutar 100–150K | `scripts/systems/seed_constants.gd:49-53` |
| Melek | 4, sabit | `scripts/systems/angel_round_system.gd:38-39` |

Koda göre veto koltuksuz kalamaz: itiş önce vetoyu düşürür, geri alma koltuk 2 olmadan vetoyu eklemez `[çıkarım]`.

### 5.4 Eşik önerisi `[ÇALIŞMA]`

- GDD ch09 §7 iki varyant tanımlıyor: kurucu dostu ve agresif. HANDOFF de ikili soruyor (`HANDOFF_series_a.md:189`). Kod da bugün iki varyant kullanıyor (§5.1).
- Birincil öneri bu yüzden iki varyantlı. Değişen yalnız kural.
- Terimler: "pay" = Series A payı (`equity_pct`); "kurul ağırlığı" = koltuk + (veto ? 1 : 0) (§5.3).

**Seçenek A: iki varyant, pay + kurul. Önerilen bu.**

| Varyant | Kural |
|---|---|
| kurucu dostu | pay ≤ 15 **ve** kurul ağırlığı = 0 |
| agresif | geri kalan her şey |

- Bugünkü kuralın biçimi korunur (pay ≤ 18 ve veto yok, `endings_copy.gd:29`, `:83`). Yalnız eşikler değişir: pay 18 → 15, "veto yok" → "kurul ağırlığı 0".
- 15 = `SERIES_A_DIL_MIN` ve Nexus'un açılışı (`pitch_constants.gd:185`, `:187`).
- Açılışlar: Nexus kurucu dostu · Meridian, Bosphorus ve Anchor agresif.
- İtişle değişim `[çıkarım]`:
  - Meridian'da tek pay itişi (18 → 14) kurucu dostu yapar.
  - Bosphorus'ta iki itiş gerekir (pay ve kurul).
  - Anchor'da dört itiş gerekir (iki pay, veto, koltuk).
- Bu kuralda agresif metin dört açılıştan üçünde çıkar. Metnin "kontrol el değiştirdi" iddiası (§5.1) daha sık yanlış okunur (Açık kararlar 15).

**Seçenek B: iki varyant, yalnız kurul (ch09 §5'e en yakın).**

| Varyant | Kural |
|---|---|
| kurucu dostu | kurul ağırlığı = 0 |
| agresif | kurul ağırlığı ≥ 1 |

- ch09 §5 "founder-friendly ↔ aggressive" adını koşul eksenine veriyor: "board seat, veto rights, milestone clauses". Kodda "milestone clauses" yok; bu yüzden tam harfiyen değil.
- Pay hükmü etkilemez. ch09 §5 payı ayrı eksene koyuyor ("Amount and valuation (together: dilution)").
- Açılışlar: Nexus ve Meridian kurucu dostu · Bosphorus ve Anchor agresif.
- Bosphorus'ta tek kurul itişi (koltuk 1 → 0) kurucu dostu yapar `[çıkarım]`.

**Seçenek C: üç varyant ("dengeli"). GDD'yi genişletir; sahip kararı.**

- ch09 §7 iki varyant tanımlıyor. Üçüncü varyant için ch09 §7 güncellenmeli.
- Ek yük: üçüncü bir metin takımı (manşet, alt başlık, resim altı; TR ve EN) ve üçüncü bir Frank satırı (§5.5).
- Yalnız bu seçenek seçilirse örnek kural:

| Varyant | Kural |
|---|---|
| kurucu dostu | pay ≤ 15 **ve** kurul ağırlığı = 0 |
| agresif | pay ≥ 22 **veya** kurul ağırlığı ≥ 2 |
| dengeli | geri kalan her şey |

- 22 = `high` bandı ve Anchor'ın açılışı (`pitch_constants.gd:187`).
- Açılışlar: Nexus kurucu dostu · Meridian ve Bosphorus dengeli · Anchor agresif.

Üç seçenekte de:
- A ve B'de manşet anahtarları zaten var: `END_SA_HEAD_FF`, `END_SA_SUB_FF`, `END_SA_CAP_FF` ve `_AGG` karşılıkları (`strings.csv:1982-1987`). Değişen yalnız kural (`endings_copy.gd:83`).
- C'de üçüncü takım gerekir. TR önce yazılır, EN ayrı yazılır, sahip onaylar.
- `aggressive` metninin "kontrol el değiştirdi" iddiası durumla desteklenmiyor (§5.1). Yeniden yazılması açık karar.
- Metin yeniden yazılırsa manşet sayı basmasın `[ÇALIŞMA]`. Sayılar zaten `END_SA_TERMS` satırında (`strings.csv:1988`).

### 5.5 Frank satırları

- Frank satırı gerekir (sahip yazar): Series A imzası, **kurucu dostu** şartlarla.
- Frank satırı gerekir (sahip yazar): Series A imzası, **agresif** şartlarla.
- Yalnız seçenek C seçilirse: Frank satırı gerekir (sahip yazar): Series A imzası, **dengeli** şartlarla.
- Frank satırı gerekir (sahip yazar): Series A kilometre taşı modu. Bugünkü satır "başka bir oyunun konusu" diyor (`strings.csv:2091`). Perde 3 açılınca gerekir.
- Bootstrap Frank satırı ("Onlara ihtiyacın yokmuş. Gerçek bir şey kurdun.", `strings.csv:2101`) iki modda da doğru okunuyor. Bu bir değerlendirme; sahip onaylar `[ÇALIŞMA]`.
- Seam `[ÇALIŞMA]`: Frank şeridi bugün yükteki `frank_line`'ı okuyor (`ending_scene.gd:202-203`). O da yalnız id'ye bakıyor (`endings_system.gd:478-480`). Varyant, gazeteyi kuran yerde (`EndingsCopy`, `vs.variant`, `endings_copy.gd:86`, `:91`) bir kez hesaplanmalı. Şerit de aynı varyantı okumalı. Aksi hâlde manşet ve hüküm ayrışabilir.

### 5.6 Bootstrap manşeti (K23 ile bağlantı)

- `_bootstrap`'ta manşet, alt başlık ve resim altı şart okumuyor (`endings_copy.gd:294-296`).
- Yalnız B2B istatistik hücresi pay tablosunu okuyor: `_founder_share` → `investor_equity_pct` (`:320`, `:492`). `:315`'teki "reads 100 here — no signed terms on a bootstrap run" yorumu melek ve seed yüzünden eskimiş.
- Manşet ve alt başlık dış para alınmadığını söylüyor: "Kimseye El Açmadan Ayakta", "Dışarıdan tek kuruş almadan…" (`strings.csv:2047-2048`).
- Oysa melek çeki normal modda reddedilemiyor (ch09 §1: "Refusal locked (hard mode)"). Seed alınmış bir koşu da bootstrap'a ulaşabiliyor: kârlılık şartı seed'e bakmıyor (`endings_system.gd:243-260`).
- K23 melek çekini işaretliyor (`ONERI_v3_K1-K32.md:142-143`). Seed'li koşu, K23'ün önerdiği "kurumsal tur almadan" başlığıyla da yanlış kalır, çünkü seed kurumsal bir tur (bu notun bulgusu).
- Koşu defteri gereken alanları taşıyor (`game_state.gd:914-919`). Bootstrap manşeti seed'e göre değişsin mi, açık karar.

### 5.7 Etkilenen smoke vakaları

- `run_ledger`: 18 pay, 1 koltuk, veto yok için `founder_friendly` bekliyor (`endgame_smoke.gd:774`, `:788`). Bu şartlar A'da ve B'de agresif, C'de dengeli olur. Vaka her seçenekte güncellenir.
- `frank_line_renders_outside_the_paper`: her `ENDINGS` anahtarı için `END_META_<ID>_FRANK` istiyor (`endgame_smoke.gd:16777-16793`). Varyant anahtarları da kapsanmalı.
- `table_sign_closes_series_a` yükteki ekleri okuyor (`endgame_smoke.gd:1836-1860`). Yük değişmezse etkilenmez.

---

## 6. Seed ticker haberi

### 6.1 Bugün seed imzasında ne oluyor

- İmza, Series A ile aynı yoldan geçiyor. `sign_table` seed'de `SeedRoundSystem.accept`'e dallanıp dönüyor (`vc_pitch_system.gd:518-520`).
- `accept` sırasıyla (`scripts/systems/seed_round_system.gd:177-195`):
  - pay tablosu (`:186`);
  - nakit (`:187`);
  - `seed_closed_day` (`:188`);
  - ayın olayı "Seed turu kapandı", öncelik 78 (`:190-191`; `strings.csv:2831`);
  - `EventBus.seed_round_closed` (`:192`).
- Yorum: "NO ENDING FIRES." (`:174`).
- Frank kartı `funding.seed_closed`: tek seferlik, seed alındıktan en geç 1 gün sonra (`data/events/cards/funding/seed_closed.json:14-31`). "Tamam" seçeneğinin etkisi yok (`:32-38`). Metni mühürlü (`:3`).
- **Ticker satırı yok.** `accept`, `headline_added` yaymıyor (`seed_round_system.gd:177-195`).
- `seed_round_closed`'u dinleyen tek yer Av sekmesi (`hunt_tab.gd:42`).

### 6.2 Mevcut ticker sistemi

| Parça | Ne yapar | Kaynak |
|---|---|---|
| `EvTicker.push(line_key, priority, context)` | Anahtarı çevirir, `.format` yapmaz, `context`'i kullanmaz. `headline_added` yayar. | `scripts/events/present/ticker.gd:31-36`, `:44` |
| `PRIORITY_PLAYER` | Kaynak "İÇERİDEN"; ayrıca bir kopya tutulur | `ticker.gd:37-41`, `:46`; `strings.csv:2599` |
| `PRIORITY_WORLD` | Kaynak `outlet_name(0)` = "Ekonomi Postası" (gazetenin künyesiyle aynı) | `ticker.gd:47`; `strings.csv:655` |
| Doğrudan yayma | `tr(KEY).format({...})` ile adlı yer tutucu. Tutulan kopya yok. | `scripts/systems/hr_system.gd:547`; `scripts/systems/sales_finalizer.gd:104` |
| Canlı şerit | En çok 6 satır | `scripts/ui/components/news_ticker.gd:48` |
| "Biz" tamponu | 10 satır. Dolunca en **yeni** satır düşer. Akışta %20 sert pay. | `scripts/systems/news_feed_system.gd:32`, `:36`, `:164-179` |
| `TICKER_CAPACITY := 20` | Hiçbir yer okumuyor | `tuning.gd:116` (`grep`) |
| `ticker_push` kart fiili | Var ama hiçbir kart kullanmıyor | `effects.gd:451`; `grep data/events` boş |

- Motor GDD'si §18.2 "kapasite ~20, taşınca en eski düşer" diyor (`GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md:1126`). Bu kodda böyle kurulmamış.
- §18.1: "Ticker hiçbir bilginin TEK kanalı değildir." (`:1120`). Seed için bu zaten sağlanıyor: kart ve ayın olayı var.

### 6.3 Öneri `[ÇALIŞMA]`

- **An:** seed imzası. Tek atomik nokta `SeedRoundSystem.accept`. Fon id'si, tutar ve pay orada elde. İki yer adayı:
  - `accept` içinde, `record_seed_round`'dan sonra;
  - ya da `seed_round_closed` sinyalini dinleyen bir yer. Böylece `accept`'e dokunulmaz.
  - Kartın "Tamam" seçeneğine `ticker_push` eklemek mühürlü metne dokunmaz. Ama yer tutucu kullanamaz ve oyuncu kartı kapatınca yayılır.
- **Kaynak:** açık karar.
  - "Ekonomi Postası" (dünya önceliği) haberi gazetenin sesiyle verir. Ama tutulan kopya yok, tampon dolunca düşebilir.
  - "İÇERİDEN" (oyuncu önceliği) kopyayı tutar. Ama `EvTicker.push` yer tutucu dolduramaz.
- **Metin:** bir anahtar. TR önce, EN ayrı yazılır, sahip onaylar. Adlı yer tutucu kullanılır; yer tutucuya ek gelmez (CLAUDE.md, BILINGUAL BIRTH LAW). Biçim örneği `[ÇALIŞMA]`:
  - `SEED_TICKER_CLOSED`: "{company} seed turunu kapattı. Turun lideri: {fund}."
  - Tutar da yazılsın mı, açık karar.
- **Gazete yok.** `EndingScene` açılmaz. Olay motorunun `paper` kartı da (`scripts/events/present/papers.gd`) kullanılmaz. Bilgi taşıyan, karar istemeyen şey ticker'a aittir (`papers.gd:9`).

---

## 7. D5 ile ilişkisi

Bu bölüm yalnız bağımlılığı anlatır. D5'in içeriğine dokunmaz (`HANDOFF_series_a.md:199`: "Açık maddelere dokunma.").

- D5: "yüzleşme = D4'teki haller + kapıyı 3 kez reddetmek". İnceleme notu: "HANDOFF D bölümündeki gazete ve son kararına bağlı … O karar netleşmeden uygulanmaz." (`ACIK_KARARLAR_D1-D13.md:248`).
- D5'in öneri metni: "3 kez reddetmek bootstrap zaferini açar, ama Series A yolunu kapatmaz." (`:98`).
- B2: bugünkü ekonomide yüzleşme sayılan her şey ertesi gün bootstrap getiriyor (`:23-30`).

Bu karar D5'in kapsamını nasıl değiştiriyor:

| | Demo (son modu) | EA / tam (kilometre taşı modu) |
|---|---|---|
| D5 neyi belirler | Hangi hareket koşuyu kazançla **bitirir** | Hangi hareket kilometre taşı gazetesini açar; koşu **sürer** |
| Geniş tanımın bedeli | Yüksek: B2 yüzünden koşu erken biter | Düşük: koşu devam eder |
| Series A yolu açık kalırsa | Önemsiz: koşu zaten bitti | Oyuncu kilometre taşından sonra Series A imzalayabilir. Anahtar kapalıyken bu bir sondur (§2.1). |

Bugün kodda yüzleşme (yalnız betimleme):
- Tek yazan `walk_table` (`vc_pitch_system.gd:573`). Gelen nedenler:
  - `"declined"` (varsayılan; Av sekmesi ve masadan kalkma: `hunt_tab.gd:443`, `term_sheet_table_system.gd:588`);
  - `"fund_walked"` (`term_sheet_table_system.gd:344`).
- `RANK`'ta `"walked"` ve `"door_open"` var, ama üretim kodunda onları yazan yer yok (`game_state.gd:765`; `grep`). `vc_pitch_system.gd:566-567` yorumu masanın `"walked"` gönderdiğini söylüyor; kod varsayılan `"declined"`'ı gönderiyor.
- `"fund_walked"` bootstrap'ın `faced_ok`'unu açıyor (`endings_system.gd:256`). Satın almanın `road_over`'ı onu saymıyor (`:347`).
- Kapı reddi yalnız `gate_declines` bayrağını artırıyor. Yüzleşmeye girmiyor (`scripts/systems/phase_gate_system.gd:123`).
- `faced_series_a` yalnız yükselir, düşmez (`game_state.gd:760-769`). Bu yüzden kilometre taşı mandalı ayrıca gerekir (§3.3).

Bağımlılık:
- D5'in onayı bu karardan sonra gelir. Kilometre taşı modunda D5'in kapsamı yukarıdaki tablodaki gibi değişir.
- ch13 §7'deki açık soru (hangi haller yüzleşme sayılır) D5 ile kapanır.

---

## Açık kararlar (sahip)

1. §2.1 mod tablosu. EA / tam'da `acquisition` (`soft_win`) ve `running_on_fumes` (`soft_loss`) son mu? Öneri: ikisi de son `[ÇALIŞMA]`. **Uygulama (§U.1):** ikisi de son. `running_on_fumes` bir kayıp. `acquisition` onay bekliyor (§U.4).
2. Build türünün kaynağı: dışa aktarma ön ayarında özellik etiketi ve geliştirme yedeği `[ÇALIŞMA]`, ya da tek bir sabit. **Uygulandı (§U.2):** özellik etiketi + debug `--build=`.
3. Series A anahtarının yeri ve "Perde 3 hazır"ın somut tanımı. Perde tanımı bugün yalnız onaysız VIZYON belgesinde. **Sahip:** Series A Perde 3'e kadar her build'de son. Anahtar sabiti kurulmadı; ne gerektiği §U.2'de.
4. Seam biçimi: ayrı `trigger_milestone()` `[ÇALIŞMA]` ya da `trigger_ending(..., milestone = true)`. **Uygulandı:** ayrı `trigger_milestone()`.
5. Kilometre taşı modunda ray: Series B / Halka arz kartları, TEKRAR DENE, ZOR MOD, koşu satırı (§2.3). **Uygulandı (§U.1):** yalnız başlık, gövde, DEVAM ET ve ANA MENÜ.
6. EA / tam build'de bir **son** açıldığında (kayıp sonları, `acquisition`, anahtar kapalıyken `series_a_close`) WISHLIST'E EKLE ve "SIRADA NE VAR?" kartları görünür mü? Karar wishlist'i demo build'e bağlıyor (`HANDOFF_series_a.md:163-164`). Av sekmesindeki kilitli "Tier 2'de" kartı da aynı soruya girer (§1.5, §2.3). **Gazete için uygulandı:** EA / tam'da ikisi de gizli. Av sekmesi kartı ve Pazarlama kilidi açık (§U.4).
7. "Ana menü": ana menü yokken nereye gider, hangi slota yazar? **Sahip: "sanki varmış gibi".** Uygulama: elle kayıt slotu, ardından yeniden başlatma (§U.1).
8. 730: (a), (b) ya da (c). Cloud tercihi (a) `[ÇALIŞMA]`. VIZYON'daki karşı görüş §4.3'te. **Sahip (a)'yı seçti; uygulandı.**
9. Bootstrap kilometre taşından sonra satın alma teklifinin gelip gelmeyeceği (§3.3). **Bugünkü kod:** gelebilir, kabulü bir sondur (§U.4). K16/D4'ün sıra önerisine (`ACIK_KARARLAR_D1-D13.md:94`) ve D1'e bağlı; yalnız bağımlılık notu, D tablosuna dokunmaz.
10. Bootstrap kilometre taşından sonra Series A imzalanabilir mi? Anahtar kapalıyken bu bir son olur. **Bugünkü kod:** imzalanabilir ve bir sondur (sahibin Perde 3 kararı).
11. Aynı gün ay özeti ve kilometre taşı gazetesi: hangisi önce? Öneri: gazete sonra `[ÇALIŞMA]`. **Uygulama:** gazete önce açılır, ay özeti üstüne gelir; saat kilidi ikisini de taşır (§U.1).
12. K17 kuralı: seçenek A (iki varyant, pay + kurul) mı, B (iki varyant, yalnız kurul) mı? Eşikler `[ÇALIŞMA]`: pay ≤ 15, kurul ağırlığı 0.
13. K17: "dengeli" üçüncü varyantı (seçenek C) istenir mi? GDD ch09 §7'yi genişletir. Üçüncü metin takımı ve üçüncü Frank satırı gerekir.
14. K17: varyant yalnız Series A'dan mı `[ÇALIŞMA]`, bütün pay tablosundan mı? İmzalayan fon koşu defterine girsin mi?
15. K17: `aggressive` metni ("Kontrol El Değiştirdi") yeniden yazılsın mı?
16. Frank satırları (§5.5): kurucu dostu, agresif, Series A kilometre taşı modu; C seçilirse dengeli. Sahip yazar.
17. Bootstrap manşeti seed ya da meleğe göre değişsin mi (K23)?
18. Seed ticker: an (`accept` ya da sinyal dinleyici), kaynak (Ekonomi Postası ya da İÇERİDEN), metin, fon ve tutar adı.
19. `TICKER_CAPACITY`: bağlansın mı, emekliye mi ayrılsın?
20. GDD güncellemeleri:
    - ch13 §1: bootstrap EA'da kilometre taşı. (`endings_system.gd:36-39` yorumu eskimiş, bkz. §1.6. ch13 §1'in D-1 uyarısı `final_stretch_verdict` ile karşılanıyor; o cümle değişmez.)
    - ch09 §7: yalnız seçenek C seçilirse.
    - ch14: build modları.
    - ch13 §4: galeri kilometre taşını sayar mı? Galeri bugün kodda yok; `endings_copy.gd:583` yalnız hata ayıklama.
21. Metin çelişkileri (§1.6): Series B kartının gövdesi ve rozeti, "NORMAL MOD" (zorluk), kilometre taşında koşu satırı.

D5 bu listede yok. Bu karardan sonra ayrıca onaylanır (§7).

## Etkilenecek dosyalar (öneri hâli; gerçekte değişenler §U.3)

| Dosya | Neden |
|---|---|
| yeni: build / mod kaynağı (ör. `release_scope.gd`, ad `[ÇALIŞMA]`) | Build türü, Series A anahtarı, `ending_mode()` |
| `export_presets.cfg` (yeni), `project.godot` | Build başına özellik etiketi |
| `scripts/events/core/tuning.gd` | `SHIPPED_SCOPES` build'den türer |
| `scripts/systems/endings_system.gd` | Mod çözücüye sorma, kilometre taşı seam'i, bootstrap mandalı, `_check_soft_cap` (§4) |
| `scripts/autoload/game_state.gd` | Mandal alanı ve sıfırlama |
| `scripts/autoload/event_bus.gd` | Kilometre taşı sinyali |
| `scripts/main/main.gd` | Kilometre taşı gazetesini kurma ve kapama, hızı geri açma |
| `scripts/modals/ending_scene.gd` | Mod: ray öğeleri, "Devam et", "Ana menü" |
| `scripts/systems/endings_copy.gd` | K17 kuralı; (a) seçilirse süre ifadesi |
| `scripts/systems/vc_pitch_system.gd` | Series A anahtarı açılınca; imzalayan fon kalıcı olursa |
| `scripts/systems/seed_round_system.gd` ya da yeni dinleyici | Seed ticker satırı |
| `scripts/events/seams/seams_world.gd` | Kilometre taşı seam'i (kart koşulları için) |
| `docs/SEAM_REGISTRY.md` | Kilometre taşı seam'i ("every read is a named seam") |
| `docs/EVENT_SIGNAL_MANIFEST.md` | Kilometre taşı sinyali. Üretilmiş dosya: `python tools/gen_signal_manifest.py` ile yeniden üretilir. |
| `data/events/cards/world/final_stretch_{press,comment,verdict}.json`, `data/events/arcs/soft_cap_stretch.json` | Kilometre taşından sonra susma (§4) |
| `scripts/autoload/investor_registry.gd` / `scripts/tabs/hunt_tab.gd` | Yalnız Açık kararlar 6 kilitli "Tier 2'de" kartını build'e bağlarsa |
| `scripts/autoload/save_manager.gd` | "Ana menü" kaydı (yalnız çağrı; mantık değişmeyebilir) |
| `localization/strings.csv` | Butonlar, K17 (C seçilirse dengeli takımı; `aggressive` metni karar olursa), seed ticker, süre anahtarı. Frank satırlarını sahip yazar. |
| `scripts/debug/endgame_smoke.gd` | `run_ledger`, `frank_line_renders_outside_the_paper`, yeni vakalar (kilometre taşı, mandal, 730 sonrası) |
| GDD ch13, ch14; C seçilirse ch09 (sahip) | Tanım güncellemeleri |

## Doğrulanamayanlar

- `endings_system.gd:401`'deki "TEN callers": `grep` 9 üretim çağrısı buluyor.
- Godot özel özellik etiketlerinin editör ve ekransız koşularda bulunmaması: motor belgesine bakılmadı.
- 730 sonrası davranış (tamponlar, haber akışı, takvim): koşulmadı.
- Aynı gün ay özeti ve gazete çakışması; kilometre taşı gazetesi açıkken otomatik kayıt: koddan çıkarım.
- Veto-koltuk ilişkisi, kurucu payı alt sınırı (%53) ve itiş sayıları (§5.4): sabitlerden çıkarım.
- Açılış akışından (`scenes/onboarding`) kayıt yüklenip yüklenemediği.
- "Oyun Vizyonu v1" kaynak belgesinin repoda olmaması: dosya adı ve metin taraması.
- Onaylı GDD'lerde koşu düzeyinde "Perde" geçmemesi: yalnız metin taraması.
