# PRD · Ana Menü, Açılış Dizisi ve Onboarding

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_ANA_MENU_ONBOARDING.md dosyasını
oku ve uygula."
**Durum:** yardımcı yönetmen taslağı 2026-10-10 gece (H1–H13), sahibin 2026-10-11 yön değişikliğiyle revize (H14–H16 yeni; H1, H2, H4, H5,
H6, H8, H12 güncel). **Erdem 2026-10-11 sabah setleri ve PRD'yi onayladı;** tek değişiklik logo kilidi (H17, §2.7). Görsel yön bölümleri
(§4.4, §10.6) v2 maket setlerinin ölçüleridir; marka her karede H17 kilidiyle değişir. Sahibe 22–28'de öneriler uygulanır.
**Tek cümle:** exe wordmark ve "Godot Engine ile yapıldı" kartıyla açılır, dil kendiliğinden seçilir, dönen oyuncu akşam şehrinin önündeki
menüden tek tıkla kaydına döner, oyundan menüye süreç içinde dönülür, yasal metin Jenerik → Lisanslar'da ve exe'nin yanında durur,
onboarding evdeki sahneye, zorluk seçimine ve yeni amblem sistemine taşınır.
**Çıktı:** main'e 14 commit (AM0, AM1a, AM1b, AM2–AM8, AM9a, AM9b, AM10, AM11; push yok), her biri kendi kapısıyla; `--menu-shot`,
`--backdrop-probe` araçları; 1920×1080 ve 1536×864 TR/EN ekran görüntüleri; Erdem'e ✅/⚠️/❌ listesi ve ölçüm satırları.

Kod kanıtı HEAD `43e0a28`; `5f888b9`'da Onarım 1 ve Sprint `main.gd`'yi `:30`'dan sonra 1–75 satır kaydırdı: çıplak `main.gd` atıfları
`43e0a28`'indir, "@5f888b9" işaretliler yenidir, kayanı işlev adıyla bul; 2026-10-11 eklemelerinin kanıtı `5f888b9`'dadır (öbür dosyalar iki HEAD
arasında değişmedi). Girdiler (`screens/_aday_menu_onboarding/arastirma/`): DENETİM (44 boşluk: D1–D6, L1–L8, M1–M9, S1–S4, A1–A3, O1–O13, X1),
AUDIT = KOD_DENETIMI.md (G1–G26), menü ve onboarding RAPOR'ları; 2026-10-11: `SP` = `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/faa4f53a-2d29-41ac-9ee2-7655fe932cd7/scratchpad/menu/`
altında `SP/v2/menu/` (13 kare) ve `SP/v2/onboarding/` (7 kare; her birinde INDEX + NOTES), kredi araştırması `SP/credits/RAPOR.md`. Commit
kimlikleri `AM` önekli; çıplak `M1–M9` DENETİM'in menü boşluklarıdır. `PRD_ACILIS.md` 0b'nin S28/S29/S50/S51/S54'ü bu task'ındır.

## 0. Kararlar ve bulgu → gereksinim

**Hükümler (yardımcı yönetmen 2026-10-10 gece; sahip yönü 2026-10-11):**
H1 açılış (2026-10-11): boot splash (wordmark, zemin `D_SURFACE_0`) → "Godot Engine ile yapıldı" kartı (kısa, atlanır, aynı zemin) → `MainMenu`.
Godot logosunun CC BY 4.0 atfı ve Godot MIT metni Lisanslar'da; `GODOT_COPYRIGHT.txt` + `LICENSES/` exe'nin yanında; sürüm dolu, menüde sol altta.
H2 `MainMenu` açılışın hedefidir (dil kapısı yok, H14); öğeler Devam (kayıt varken, kart) · Yeni oyun · Yükle (kayıt varken) · Ayarlar · Jenerik ·
Masaüstüne çık; klavye ve kumanda; "Ana menüye dön" süreç içi (`--build=ea` korunur); kaydedilmemiş ilerlemede çıkış onayı, X ve Alt+F4 dahil.
H3 kayıt meta'sında koşu kimliği; Yükle şirkete göre gruplar; oto yedekler ayrı ve başka koşunun yuvasını ezmez; Devam = en yeni yüklenebilir
kayıt; F9 onayı; hafta içi kirli bayrak; yükleme ve kayıt tostları.
H4 arka plan (2026-10-11): `MenuBackdrop` akşam şehri (`city`; AUDIT §3 A) + pişmiş plaka yedeği (B), tek API; ofis içi değil.
H5 müzik: menüde bugünkü parça; Jenerik'te müzik satırı yok; `Döngü Modu.mp3` lisansı atıf isterse Lisanslar'a girer; yayını bekletir, build'i değil.
H6 onboarding (C'den sonra; 2026-10-11): üç adım, yön C "Sahne": ev sahnesi + sekmeli adım kâğıtları + sağda İlk hafta belgesi (A'nın kurucu
dosyası onun içinde); sonuç satırları, beceri kelime etiketleri, Rastgele/Sıfırla, Frank rehber anahtarı, iptal onayı, perde. Ek kurucu yok.
H7 araç: `--menu-shot`, `--backdrop-probe`, `--onboard-shot` uzantısı; yeni smoke yalnız bir menü durum makinesi vakası. H8 görsel yön
(2026-10-11): v2 setleri (`SP/v2/`) AM0'da `screens/ana_menu/` ve `screens/acilis_v2/` olur; §4.4 ve §10.6 onların ölçüleridir.
H9 debug'da `--menu` menüyü zorlar; `--skip-onboarding` sahibin F5'i olarak kalır (§2.4). H11 tuş atama ekranı ayrı task; burada yalnız eksik
kumanda düğmeleri InputMap'e girer (§4.2). H10 köken çipleri (`ONB_ORIGIN_SM_CHIP_PRESS`, `_RESILIENT`) tarif cümlesi olur, okunmayan bayrağa
söz verilmez (§10.2).
H12 (2026-10-11, ters): slogan yok. Oyun sloganı hiçbir karede yok; şirket slogan alanı onboarding'den kalkar (AM9a; `draft.slogan` hiçbir yerde
okunmuyordu, `company_step.gd:62-67`), meta'ya ve perdeye girmez.
H13 PRD_ACILIS §7.4'ün menü dışı sahipsizleri: S31, S35 → Onarım 1 grup F; S41 → Yazar v2.
H14 dil (2026-10-11, öneri; yedek Sahibe 22): açılış yolunda dil kapısı yok; ilk açılışta Steam katmanı varken Steam'in oyun dili, yoksa
`OS.get_locale_language()`; `tr` → TR, başka her şey → EN; yazılır, sonra yalnız Ayarlar'dan değişir (§2.6). `LanguageGate` AM9a'da silinir.
H15 zorluk (2026-10-11; H6'nın dışlamasını kaldırır): Kolay · Normal · Zor yalnız başlangıç kasasını çarpar (Software Inc. gibi); Zor bir koşu
bitince açılır; çarpanlar ve kilit kuralı onay bekliyor (Sahibe 23); başka değiştirici yok (§10.7).
H16 amblem v2 (2026-10-11): `LogoEmblem` şekil · renk · stil · harf ile çizer; addan tohumlu 12 aday + Yeniden üret; kayıt ve meta sözlüğü
taşır; eski `logo_style` eşlenir (§10.8).
H17 logo kilidi (2026-10-11, Erdem kareyi gördü ve onayladı): turuncu kare solda, sağında iki satır "Project" / "Unicorn"; "Project"in büyük
harf üstü karenin üst kenarında, "Unicorn"un taban çizgisi karenin alt kenarında (§2.7). Tek satırlı wordmark ve yığılı kilit (eski kare 12)
kalkar; splash, menü, Jenerik ve onboarding şeridi aynı varlığı kullanır.

| # | Bulgu (kanıt) | Gereksinim |
|---|---|---|
| D1 | `boot_splash/*` yok → Godot logosu, `#242424` zemin (`project.godot:11-17`) | §2.1 |
| D2/D3 | İkon Godot robotu (`project.godot:16`), `.ico` yok; wordmark yok, marka turuncu kare (`ui_tokens.gd:599`, `INDEX.md:15`) | §2.2 |
| D4 · D5 | Sürüm yok, her kayıt `0.0.0-dev` (`save_manager.gd:544-546`) · `_run_args()` `main_args`'ı build'de de okur (`main.gd:122-129`, `project.godot:17`; aynısı `endings_system.gd:386-397`) | §2.3 · §2.4 |
| L1, L2, L6, L7, X1 | Jenerik/lisans ekranı ve anahtarı yok (`strings.csv:261-262`); `.txt` pakete girmez, `export_presets.cfg` yok; eklentiler lisanssız | §2.5, §3 |
| L3, L4, L5, L8 | Müzik, `assets/icons/`, Xbot küçük resimleri kaynaksız; kurgu notu yok | Sahibe 2–5 (L3–L5 yayın engeli) |
| M1/M2, S28 | Menü yok; açılış dil kapısı ya da onboarding (`main.gd:95-101`); modallar yalnız `GameShell/ModalLayer` (`main.gd:3009-3014`) | §4 |
| M3/M4 | "Ana menüye dön" kilitli (`system_menu_modal.gd:29`); son ekranı ANA MENÜ = kayıt + yeniden başlatma (`main.gd:3523-3532`, ACIK 872) | §7 |
| M5 | `OfficeView` koşusuz kurulamaz (`office_people.gd:594-598`); GDD ch12 §6 "Main menu: ODA night scene" | §5 |
| M9 | X/Alt+F4 onaysız; `_autosave_on_close` yalnız `can_save()` iken yazar (`save_manager.gd:64-66, 392-397`) | §8 |
| S1/S2, S29 | Oto yuvalar koşudan bağımsız (`save_manager.gd:426-438`); `_slot_row` meta'sı adı düşürür (`:513-533`) | §6 |
| YENİ-1 · YENİ-2 | `run_active` açılışta `true` (`game_state.gd:126`); menüde kayıt kapısı açık görünür (`save_manager.gd:84-97`) · Hızlı yuva tek ve global (`save_manager.gd:27, 212-213`) | §4.3, §7.1 · §6.2 |
| S3/S4, S51 | "Kaydet ve çık" hızlı yuvayı ezer (`system_menu_modal.gd:74-79`); F9 modal bekçisinden önce (`game_shell.gd:60-67`), onaysız (`main.gd:3424-3428`) | §9.1, §9.3 |
| S50 | `_dirty` yalnız gün tikinde (`save_manager.gd:354-355`); elle kayıt yalnız hatada tost (`save_load_modal.gd:191-204`) | §9.2, §9.3 |
| S54 | Boş adlı kurucuya çevrilmiş ad (`game_state.gd:935-938`); Efektler oynatıcısız (`settings_modal.gd:180`); yolculukta AYARLAR sessiz (`main.gd:3333-3335`) | §9.4 |
| YENİ-3 | Toast gruba yalnız `rail` varken girer (`toast.gd:52-53`) | §4.1 |
| O1–O3, O7–O11 | Eski register (`onboarding_flow.gd:60-63`); iptal yok; sahte 1 sn (`:166-171`); sonuç sayısı, özet, Rastgele, rehber yok | §10 |
| O4–O6 · O12 · O13 | İleri gerekçesi, köken adları, huy metinleri · Zorluk/başlangıç yılı · "Kurucu · 2026" vs 2012 | C (PRD_ACILIS R8) · zorluk H15 (§10.7), yıl kapsam dışı · Sahibe 11 |
| YENİ-4 | Tutorial kancası var (`gate.gd:159-161`, `engine.gd:319`), `tutorial` etiketli kart yok (`git grep '"tutorial"' data/events` boş) | §10.4 |
| YENİ-5 · A3 | Köken çiplerinin bayrakları okunmaz (`scripts/systems/founder_constants.gd:57-58, 63-69`) · Ayarlar'da lisans girişi yok (`settings_modal.gd:214-215`) | Sahibe 10 · §3.1 |
| A1, A2, D6, M6, M7, M8 | Tuş atama, rehber aç/kapa, `use_custom_user_dir`, menüde dil, UI tık sesi, demo istek listesi | H11; Sahibe 8; M6 → H14 (§2.6); D6, M7, M8 ACIK (§15.2) |
| YENİ-6 | İlk açılış dil kapısı (`main.gd:14, 97-110` @5f888b9; `localization.gd:53-54`); Steam katmanı yok (`git grep -n "Steam\." scripts` boş) | §2.6 |
| YENİ-7 | Logo: dört sabit stil, tek renk, tek harf (`logo_emblem.gd:17-62`, `founder_constants.gd:91-97`); `logo_style` dize (`game_state.gd:14, 769`) | §10.8 |
| YENİ-8 | Koşular arası kalıcı bayrak yok (`endings_system.gd:469-483` yalnız koşu durumu yazar); `DEFAULTS` dışı `Settings` anahtarı sıfırlamada kalır (`settings.gd:22-23, 104-110`) | §10.7 |
| YENİ-9 | Ayakta kurucu kurulabilir: `LookSystem.founder(id)` koşusuz (`look_system.gd:27, 116-117`), `OfficePerson.place(…, "idle")` yürümeden durur (`office_person.gd:335-370`); maket sanatında ayakta figür yok | §10.9 |
### 0a. Brief'ten farklar
- **`*.txt` filtresi daraltıldı.** `docs/` da `res://` altında; filtre lisans dosyalarını adıyla sayar (§2.5).
- **`GODOT_COPYRIGHT.txt` motordan yazılır** (elimizdeki kopya 4.6-stable; DENETİM §2.4); koşan 4.6.2 ikilisi sürüm eşliğini garanti eder.
- **Hızlı yuva da koşu başınadır** (YENİ-2); çıkış kayıtları oto dönüşe yazar (S3). **Frank anahtarı kilitli doğar** (YENİ-4).
- **Harness sona kalmaz:** her commit kendi `--menu-shot` durumunu getirir (CLAUDE §11); AM10 toplu çekim ve CLAUDE §12 satırlarıdır. **Dışa
  aktarım iki commit:** şablonlar makinede yok (§2.5); exe kabulleri AM1b'ye ayrılır, AM2–AM11 onu beklemez.
- **TEKRAR DENE dokunulmaz** (`ending_scene.gd:19-20, 514-517` sahip kararı); yeni açılış onu menüye indirir (Sahibe 7).
- **Dil kapısı iki adımda gider:** açılış yolu AM3'te bırakır; sahne C'nin dosyası olduğu için AM9a'da silinir. **`ONB_BACK_TO_MENU`,
  `ONB_START_BTN` yok:** `SYS_MAIN_MENU` (`strings.csv:261`) aynı metni taşır; Kur ve başla var olan `ONB_START`'tır (`:24`).

## 1. Kurallar
- `CLAUDE.md` bağlayıcıdır: §3 (doğrudan main, push yalnız Erdem "push et" deyince; tasarım sabiti "onay bekliyor"; TR metni "TR/EN onay
  bekliyor"; Frank satırı yalnız taslak), §5 (BILINGUAL BIRTH, önce İngilizce, tire yok, `static func` içinde `tr()` yok), §7 (koyu yüzey yalnız
  `D_*`; `menajer_theme.tres` her katman köküne elle), §8–§9 (kısa kod, yerini alan eskisini siler; inceleme aşağıdaki bütçeyle), §10
  (yeni smoke yalnız `menu_state_machine`), §11 (fikstürle ekrana gel, en çok 1 düzeltme turu), §12 (kapı sırası).
- **Ağaç paylaşımlı.** 2026-10-11 sabahı A+B oturumu SPRINT 10–11 ve Onarım 1'in kalanında (`main.gd`, `strings.csv`, Satış/Ekip/Ar-Ge
  dosyaları), C oturumu AÇILIŞ'ın son commit'lerinde (C15, C10, C13). İşe `git status --short` ile başla; kirli dosyada yalnız kendi
  hunk'larını `git apply --cached` ile stage et, kapıları `git checkout-index` ile geçici dizine kurulan commit ağacında koş. `git checkout --
  <yol>`, `reset --hard`, `stash`, `clean` yasak. Yarım düzenleme görünen dosyayı `git show HEAD:./<yol>` ile oku; kayan hunk'ı işlev ya da
  anahtar adıyla yeniden bul.
- **Model ve bütçe (Erdem 2026-10-11).** Kod yazımı Opus. Başka her iş Sonnet ya da Haiku; hangisinin yeteceğine işe bakarak sen karar
  verirsin: inceleme, ekran çekimi ve görsel kabul, kapı ve smoke koşturma, maket, belge ve CSV işi, okuma ve arama. Commit başına en çok bir
  inceleme ajanı, yalnız diff okur; yalnız belge, maket ya da CSV taşıyan commit'te (AM0, AM11) ayrı inceleme yok. Düzeltme en çok bir tur;
  bu PRD'nin istemediği ölçüm, çapraz kontrol ya da ikinci inceleme turu yok. TR+EN çekimi yalnız metni değişen ekranda. Kalite çıtası aynı:
  kapı yeşil olmadan commit yok. Fable kullanılmaz. OS düzeyinde fare/klavye girdisi yok; MCP `inject-mouse-click` bozuk, `call-runtime-method` int
  argüman taşımaz: kabuller `inject-action`/`inject-key` ve §11.1'in argsız `_dbg_*` seam'leriyle koşar. Pencereli koşular sırayla, her biri
  kendi `APPDATA`'sında, önce `tasklist | grep -i godot`; yalnız kendi başlattığın süreci kapat. Ekran istemeyen her koşu `--headless`.
- **Push yalnız sahibin sözüyle.** Her commit: kapılar yeşil → inceleme (bütçeyle) → bulgular düzelir → commit. TR metin taşıyan commit mesajı
  "TR/EN onay bekliyor", tasarım sabiti taşıyan "onay bekliyor" der; sabit §13 değeriyle iner, sahip F5'te çevirir.
- **Ofis dosyalarına dokunulmaz.** `MenuBackdrop` ve onboarding sahnesi ofis sınıflarını (`OfficeLayout`, `OfficeMaterials`, `OfficeLighting`,
  `OfficeCamera`, `OfficePerson`) ve `OfficeView.tscn`'i yalnız okur (§5, §10.9); `World`/`People`/`City` düğüm adları değişirse dur ve raporla.
  `addons/` dokunulmaz (CLAUDE §3); eklentiyi paketlemek preset işidir.
- **Kayıt yazan her koşu fikstür dizininde.** Gerçek `user://saves`'e dokunan harness kolu yoktur (§11.1 ret kuralı).

## 2. Açılış dizisi ve dil (AM1a, AM1b; AM3'te main.gd ve Localization kısmı)
### 2.1 Boot splash ve Godot kartı (D1, H1; DENETİM §3; maket 01, 01b)
- `project.godot [application]`: `boot_splash/image="res://assets/brand/boot_splash.png"`, `boot_splash/bg_color=Color("#100E0B")` (`ui_tokens.gd:468`
  `D_SURFACE_0`, maket `tokens.css:9`), `minimum_display_time=0`, `show_image=true`; editörde Godot görseli kalsın diye `editor_hint` boş
  geçersiz kılması (DENETİM D1, `ps46.xml:302`). Splash: ortada logo kilidi S 128 (§2.7), başka hiçbir şey
  yok (maket 01, marka H17'yle), 1920×1080, maket hattıyla (`tools/boot_splash.html` `lockup.svg`'yi gömer, `render.sh`). Sahip yeni logo
  verirse yalnız `lockup.svg` ve PNG yeniden üretilir.
- **Godot kartı** (sahne AM1a, bağlantı AM3; maket 01b): `scenes/menu/GodotCard.tscn` + `scripts/menu/godot_card.gd`; kök `Control` ALWAYS, tema
  kökte, zemin `D_SURFACE_0`; ortada `assets/brand/godot_logo.svg` (kök `icon.svg`'nin başı, arka kare çıkarılmış, resmî renkler; kök dosya
  silinmeden türetilir; SVG raster'lanır: içe aktarım ölçeği 2, 132 px), altında `MADE_WITH_GODOT` (Plex 500/20, `ink-2`). `GODOT_CARD_S` (§13)
  dolunca ya da herhangi bir tuş, tık, kumanda düğmesiyle biter; süreçte bir kez (menüye dönüşte yok); menüye `MENU_COVER_S` solma. Logo CC BY
  4.0: atfı Lisanslar'da ve `THIRD_PARTY_NOTICES.txt`'te; logo yalnız Godot'u temsil eder, oranı ve rengi bozulmaz (`SP/credits/RAPOR.md` "Logo").
- **Yok (DENETİM §3.2–§3.6):** stüdyo kartı, "bir tuşa bas" ekranı, EULA, yaş ekranı, ışık uyarısı, başlatıcı, dil kapısı. **Kabul:** (a) AM1a:
  `ProjectSettings.get("application/boot_splash/bg_color") == UiTokens.D_SURFACE_0`; `boot_splash.png`'nin dört köşe pikseli `#100E0B`. (b) AM3:
  `--menu-shot=godot_card` ve `=first_frame` köşe pikseli `#100E0B` ±1; `BOOT|card_ms=<n>` `GODOT_CARD_S` ±50 ms; MCP `inject-action ui_accept` →
  iki kare içinde `MENU|state=menu`; `_return_to_menu` sonrası kart yok; menü kökü ilk karede `D_SURFACE_0` örtü, `MENU_COVER_S`'de plakaya
  açılır. (c) Splash oyun içinden yakalanamaz: Erdem'in listesinde.
### 2.2 Uygulama ikonu (D2)
- `config/icon` ve `config/windows_native_icon` = `assets/brand/icon.svg` / `icon.ico` (16, 32, 48, 256 px). Kök `icon.svg` ve `icon.svg.import`
  silinir (kartın logosu önce türetilir). Sahip logosu gelirse yalnız iki dosya değişir.
- **Kabul:** `git grep -n "res://icon.svg"` boş; `git ls-files icon.svg icon.svg.import` boş; `git grep -n icon.svg -- . ":!docs/mockups"` yalnız
  `HARITA.md:341` (AM11'de `assets/brand/icon.svg` olur). AM1b: exe ikonu `[System.Drawing.Icon]::ExtractAssociatedIcon(exe)` → PNG ile rapora.
### 2.3 Sürüm ve build satırı (D4)
- `application/config/version="0.1.0"` (onay bekliyor, §13). Menü sol altı `MENU_VERSION` ("{build} · Sürüm {version}"; `build`
  `EndingsSystem.build_scope()`'tan, `MENU_BUILD_DEMO|EA|FULL`); Jenerik'te aynı satır; kayıt meta'sı `_game_version()` okur. `main._ready` her
  açılışta bir kez `BUILD|version=<v>|scope=<build_scope()>` basar (release dahil; AM3).
- **Kabul:** AM1a: yeni kayıtta `"game_version": "0.1.0"` (headless `-s` ile `build_meta()`). AM3: `--menu-shot=empty` sol altında `Demo · Sürüm 0.1.0`.
### 2.4 Harness bayrakları build'e sızmaz (D5)
- `EndingsSystem.build_scope()` (AM1a) ve `main.gd _run_args()` (AM3) `application/run/main_args`'ı yalnız `OS.has_feature("editor")` iken ekler;
  komut satırı bayrakları değişmez. `main_args`'taki `--skip-onboarding` sahibin editör F5'idir, kalır; komut satırında `--menu` onu yener (H9).
  **Kabul:** editör F5'i bugünkü gibi kabuğa açılır; AM1b: debug şablonla dışa aktarılan exe Godot kartından menüye açılır.
### 2.5 Dışa aktarım ve `LICENSES/` (L2, L7, X1)
- `export_presets.cfg` (yeni): "Windows Demo", "Windows EA" (`custom_features="ea"`), "Windows Full" (`custom_features="full"`;
  `endings_system.gd:380-391`). `include_filter`: `assets/fonts/*/OFL.txt, assets/art/office/icons/LICENSE-lucide.txt, assets/art/people/LICENSES/*,
  assets/licenses/*`. `exclude_filter`: `addons/auto_reload/*, addons/godot_mcp_editor/*, sandbox/*, docs/*, tools/*`. `addons/godot_mcp_runtime`
  autoload'ı (`project.godot:34`) yüzünden pakette kalır, release'de sunucu açmaz (`mcp_runtime_autoload.gd:75-77`); lisans dosyası yok (`git
  ls-files addons | grep -i licen` boş): kaynağı ve lisansı belirlenmeden Lisanslar'da satırı yok, yayın engeli (Sahibe 16).
- `scripts/debug/write_licenses.gd` (yeni, `-s`, `class_name` yok; editör ikilisiyle koşar, şablon gerektirmez): `<çıktı>/LICENSES/` altına
  `GODOT_LICENSE.txt` (`Engine.get_license_text()`), `GODOT_COPYRIGHT.txt` (`get_copyright_info()` bileşen bileşen + `get_license_info()`, Godot
  `COPYRIGHT.txt` biçimi), `THIRD_PARTY_NOTICES.txt` (FreeType + Godot logosu CC BY 4.0 atfı + §3.3 D–F özeti), `fonts/<Aile>-OFL.txt` ×5,
  `LICENSE-lucide.txt`, `CC0/` ×5 (`assets/art/people/LICENSES/`: Quaternius Men, Women, UAL1, UAL2, Mesh2Motion) = **14 dosya** (müzik Sahibe 2
  kapanınca 15). Lisanslar ekranıyla aynı kaynaklardan okur.
- `tools/export_build.sh <preset> <dizin>` (yeni): `"$GODOT" --headless --path . --export-release "<preset>" <dizin>/ProjectUnicorn.exe`, sonra
  `write_licenses.gd -- <dizin>`. Çıktı repo dışında (`C:/Users/erdem/Desktop/unicorn_build/`).
- **Şablonlar 2026-10-10'da kurulu değil** (`%APPDATA%\Godot\export_templates\` boş). AM1a şablonsuz kapanır; AM1b sahip `4.6.2.stable`
  şablonlarını kurunca koşar, kurulmadıysa Done mesajında ⚠️.
- **Kabul AM1a:** `write_licenses.gd` 14 dosya; `GODOT_COPYRIGHT.txt` ilk satırı `4.6.2`, bileşen sayısı `get_copyright_info().size()` rapora.
  **AM1b:** üç preset dışa aktarılır; exe ayrı `APPDATA` ile açılır, `user://logs/godot.log`'da `ERROR` yok ve `BUILD|…|scope=demo|ea|full`
  (preset başına); `.pck` içinde `docs/` yok (boyut ya da liste rapora); MCP release'de kapalıdır, MCP kabulü yok.
### 2.6 Dil kendiliğinden (H14; AM3)
- `Localization._ready` (`localization.gd:18-23`): `--lang=` yoksa ve `is_first_boot()` (`:53-54`) ise `detect_language(steam_lang, os_lang)`
  (statik, saf): `steam_lang` = `Engine.has_singleton("Steam")` iken `Steam.getCurrentGameLanguage()`, değilse ""; boşsa `os_lang` =
  `OS.get_locale_language()`; `"turkish"` ya da `"tr"` → `tr`, başka her şey → `en`; `Settings.set_value("language", …)`, sinyal yok (ağaç
  kurulmadı). `--lang=` önce gelir, yazmaz (`:20-22`). Bugün Steam katmanı yok: OS yolu çalışır. Ayarlar'daki dil seçici kalır.
- `main.gd`: `LANGUAGE_GATE`, `_mount_language_gate`, `is_first_boot` dalı ve `--force-language-gate` (`:14, 97-110` @5f888b9) silinir;
  `LanguageGate.tscn`, `language_gate.gd`, `loc_residue.gd:36` satırı ve HARITA 308-315 AM9a'da.
- **Kabul:** smoke `menu_state_machine` dil bölümü (§11.2); ayrı `APPDATA`'da `settings.json` yokken `--menu-shot=empty` → `BOOT|lang=<l>|source=os`
  ve `settings.json`'da `language`; ikinci açılış `source=stored`; `loc_language_switch` yeşil.

### 2.7 Logo kilidi (H17; AM1a)
- **Geometri** (tek ölçü S = kare kenarı): kare S×S, köşe yarıçapı 0,08·S, bugünkü marka turuncusu (`ui_tokens.gd:599`). Metin Barlow Condensed
  700, boy F = S / 1,68, `ink-1`; iki satır "Project" / "Unicorn", sola yaslı, karenin 0,25·S sağında. Dikeyde "Project"in büyük harf üstü
  (cap 0,70·F) karenin üst kenarında, "Unicorn"un taban çizgisi karenin alt kenarında; satır arası 0,28·F ("j"nin kuyruğu "U"ya değmez).
  Toplam: 0,70·F + 0,28·F + 0,70·F = S.
- **Varlık, canlı metin değil:** `tools/brand/make_lockup.py` (fontTools; `assets/fonts/cond/BarlowCondensed-Bold.ttf` glifleri yola çevrilir,
  OFL buna izin verir) `assets/brand/lockup.svg`'yi yazar ve ölçüyü basar. Splash PNG'si bu SVG'den; menü, Jenerik ve onboarding şeridi
  `TextureRect` ile çizer (SVG içe aktarım ölçeği en büyük gösterim boyunu karşılar). Özel ad: çevrilmez, CSV anahtarı yok, `MenuWordmark`
  varyasyonu açılmaz.
- **Boylar** (§13): splash S 128 (ekran ortası), menü S 96 (1536: 76), Jenerik S 48, onboarding şeridi S 40.
- **Referans:** `docs/mockups/menajer/screens/_aday_menu_onboarding/v2/kilit/` (`menu_lockup.png`, `splash_lockup.png`, geometriyi kuran
  `make.py`); Erdem 2026-10-11'de bu kareleri onayladı.
- **Kabul:** `make_lockup.py` çıktısında kare yüksekliği = "P" büyük harf üstüyle "Unicorn" taban çizgisi arası, ±1 px; `--menu-shot=empty` ve
  `=continue`'da kilit (112, 236) ve boyu 96; splash PNG'de kilidin içerik kutusunun merkezi ekran ortası ±2 px.

## 3. Jenerik ve Lisanslar (AM2; L1, L3–L8, A3)
### 3.1 Yer ve biçim (maket 07, 08)
- `scenes/menu/Credits.tscn` + `scripts/menu/credits.gd` (Jenerik, 880×700), `scenes/menu/Licenses.tscn` + `scripts/menu/licenses.gd` (Lisanslar,
  960×920; 1536'da 960×760): onaylı `modal` kromu (`dlg-h`, `dlg-f`), tema kökte, kök `process_mode = 3`, Esc kapatır. Jenerik'in alt şeridi:
  solda metin düğmesi `CREDITS_LICENSES`, sağda Kapat (`SET_CLOSE`, odak); Lisanslar'ınki Geri (Jenerik'e) · Kapat. Ayarlar → Veri'deki yeni satır
  (`settings_modal.gd:214-215` listesine `CREDITS_LICENSES`) doğrudan Lisanslar'ı açar, Geri'siz. Ölçüler SPEC §9'da yok, onay bekliyor (§13).
- Lisans metinleri **çevrilmez**, çalışma anında motordan ya da paketlenmiş dosyadan okunur; pencere başlıkları anahtardır; gövdeler
  `loc_residue` kapsamına girmez.
### 3.2 Jenerik (maket 07)
- Üstte logo kilidi S 48 (§2.7), altında `MENU_VERSION` (`ink-3`). Rol | ad tablosu (`GridContainer` 2 sütun,
  rol 300; Plex 400/16, ad 600 `ink-1`): `data/credits.json` (yeni; `[{"role": "<anahtar>", "names": [...]}]`; beş taslak rol §12; sahip doldurur);
  adı boş rol çizilmez, dosya boşken tablo yok, maketin "Ad Soyad"ı pakete girmez. Dipte tek renk Godot işareti (`assets/brand/godot_logo_mono.svg`,
  `ink-3`, 24) + `MADE_WITH_GODOT` (Plex 16 `ink-2`); altında `CREDITS_COPYRIGHT` (Plex 14 `ink-3`; `holder` Sahibe 5, boşken satır yok).
- **Yok:** Teşekkür, müzik satırı, bekletme notu, sekme, CC0 teşekkürü (CC0 atıf istemez; dosyalar `LICENSES/CC0/`'da), kurgu notu (Sahibe 5).
### 3.3 Lisanslar (maket 08): tek düz kaydırılan metin
`ScrollContainer` + bölüm başına bir `Label` (autowrap; bölüm başlığı `t-label`), asıl dilinde (İngilizce), sırayla: **A.** `LIC_GODOT_HEAD` +
`Engine.get_license_text()`. **B.** `LIC_FREETYPE` (`year` FreeType telif aralığının sonu). **C.** `LIC_THIRD_PARTY`: önce `LIC_GODOT_LOGO`, sonra
`get_copyright_info()` her bileşen düz metin (ad, `parts[].copyright` satırları, lisans kimliği), sonra `get_license_info()`'nun tekil metinleri.
**D.** `LIC_FONTS`: yalnız preset dışa aktarım listesinde `.ttf/.otf`'si bulunan aileler (JetBrains Mono, Noto Symbols 2 koşullu); telif satırı
her `assets/fonts/{cond,sans,serif,mono,fallback}/OFL.txt`'nin 1. satırı, altında tam metin (gövdeler bayt-eş değil, DENETİM §2.3 D). Ayrılmış Font
Adı "Plex"/"Source": pakete giren font verisi kaynakla bayt-eş mi rapora; değilse Sahibe. **E.** `LIC_ICONS`: Lucide ISC + Feather MIT,
`LICENSE-lucide.txt` tamamı. **F.** Müzik: atıf isteyen lisanssa (Sahibe 2) buraya; kapanana kadar satır yok; **mağaza yayını (Steam) L3, L4, L5
kapanana kadar bloklu.** Katlama, dizin, açıklama yok. `assets/icons/` (L4) ve Xbot küçük resimleri (L5) kaynağı belli olmadan satır yazılmaz;
eksikleri Done mesajı söyler (Sahibe 3, 4).
### 3.4 Kabul
- AM2: `--modal-shot=settings_end` karesinde yeni satır; odak + `inject-action ui_accept` → Lisanslar açık, Geri yok;
  `LIC|components=<n>|licenses=<n>|missing_glyphs=<n>` (gövde yüzü `has_char`), `missing_glyphs` sıfır ya da liste rapora.
- AM3: `--menu-shot=credits` ve `=licenses` TR/EN, 1920 ve 1536: rol tablosu, sürüm, Godot satırı ve işareti; Lisanslar'da Godot MIT, FreeType,
  logo atfı görünür; `ui_down` ×20 → `scroll_vertical` > 0; Geri Jenerik'e döner.

## 4. Ana menü (AM3; M1, M2, M6, S28)
### 4.1 Sahne ve durum makinesi
- Yeni: `scenes/menu/MainMenu.tscn`, `scripts/menu/main_menu.gd`, `scripts/menu/continue_card.gd`. Kök `Control`, `menajer_theme.tres` kökte.
  **`MainMenu.tscn` ve `MenuBackdrop.tscn` kökleri `process_mode = 3` (ALWAYS)**; SubViewport ve kamera kalıtır (`GameShell.tscn:13` deseni): ağaç
  `main.gd:78` `emit(0)` ile duraklatılmıştır (`time_manager.gd:325`), INHERIT yüzey girdi almaz, kamera kaymaz (`office_camera.gd:112-115`),
  eşzamanlı yükleme yoklanmaz.
- Çocuklar: `MenuBackdrop` (§5), düz `CanvasLayer` "ModalLayer" (`GameShell.tscn:69` gibi; menü ve arka planın üstünde, modallar temayı kendi
  kökünde taşır, `SettingsModal.tscn:15`), kendi `CanvasLayer`'ında `Toast`; `rail` = menü kökünde sağ yarıyı kaplayan boş `Control`, böylece
  `toast.gd:52-53` koşulu sağlanır ve `toast.gd` dokunulmaz (YENİ-3).
- `main.gd` açılış yolu (`_ready` `:95-101`): Godot kartı (süreçte bir kez, §2.1) → `_mount_menu()`. YENİ OYUN → `_free_menu()`, `_mount_flow()`.
- **`_free_menu()`** (`MenuBackdrop.stop()` + `queue_free` + `_menu = null`) iki yerden çağrılır: `_teardown_run_ui()` (`main.gd:3604-3621`) ve
  `_swap_to_shell_and_modal()` başı (`:2954`; F12/`_skip_to_shell` menüde 3B'yi kabuğun altında bırakmasın).
- Menüden yükleme `_load_slot`'un kendisidir (`load_requested` → `_load_slot`, `main.gd:3403`): menü yalnız `read_slot` ok olunca `_teardown_run_ui`
  içinde gider (`:3445-3449`); ret durumunda menü kalır ve menü tostu `SAVE_TOAST_NOT_LOADED` + `tr(error_key)`.
- Durumlar: `boot` → `card` → `menu` → (`flow` | `loading` → `shell`); `shell` → `menu` (§7); `flow` → `menu` (§10.5). Geçişler
  `_mount_godot_card()`, `_mount_menu()`, `_mount_flow()`, `_load_slot()`, `_return_to_menu()`.
- **Kabul:** menü → YENİ OYUN → kabuk ilk karesinde `TimeManager.current_speed == 0` ve `get_tree().paused == true` (bugünkü açılışla eş; §7.1);
  `--menu-shot=load` sonrası yüklemede `get_tree().root.find_children("*", "SubViewport", true, false)` içinde backdrop yok.
### 4.2 Öğeler ve gezinme
- Sıra: **Devam** (kart; yalnız yüklenebilir kayıt varken, §6.3) · **Yeni oyun** · **Yükle** (yalnız kayıt varken, yokken gizli; `SaveLoadModal`
  "load") · **Ayarlar** · **Jenerik** (§3) · boşluk · **Masaüstüne çık** (`SYS_QUIT`, onaysız: menüde koşu yok; Sahibe 19). Sol altta yalnız
  `MENU_VERSION`; köşe bandı, dil düğmesi (H14), istek listesi (ACIK, §15.2) yok. Kumanda: varsayılan InputMap'te eksik `ui_*` düğmesi varsa
  `[input]` bölümüne eklenir (H11).
- Dikey odak zinciri, uçlarda sarar; `ui_up`/`ui_down`/`ui_accept`; `ui_cancel` açık modalı kapatır, kökte etkisiz. İlk odak DEVAM, yoksa YENİ
  OYUN. Fare üstüne gelince odak oraya geçer.
- **Kabul:** `--menu-shot=empty` (Devam ve Yükle yok, odak YENİ OYUN) ve `=continue` (kart dolu, odak DEVAM) TR/EN 1920/1536; MCP `inject-action
  ui_down` ağaç duraklatılmışken: kayıtlı ×6 `CONTINUE,NEW,LOAD,SETTINGS,CREDITS,QUIT,CONTINUE`, kayıtsız ×4 `NEW,SETTINGS,CREDITS,QUIT,NEW`
  (`MENU|focus=…|paused=1`); `ui_accept` YÜKLE'de modalı açar, `ui_cancel` kapatır; kumanda: `InputMap.action_get_events("ui_down")` en az bir
  `InputEventJoypadButton` içerir (`[input]` yok, varsayılanlar taşır; `MENU|joy_ui=1`).
### 4.3 Kabuksuz modal katmanı (M2, YENİ-1)
- `_modal_layer()` (`main.gd:3009-3014`) kabuk yoksa menünün ModalLayer'ını döndürür. `settings_requested`, `save_load_requested`,
  `confirm_requested` bağlantıları **`_ready`'nin başında**, `OS.is_debug_build()` bloğundan ve `_run_debug_harness()` (`main.gd:89`) çağrısından
  önce kurulur ve `_wire_modal_signals`'tan (`:2994-3003`) silinir (çift bağlantı olmasın).
- Menü kurulurken `SaveManager.end_run()` (§7.1): `run_active` false, kirli temiz, hız 0. Menüde `cannot_save_reason_key() == "SAVE_ERR_NO_RUN"`,
  `has_unsaved_progress()` false, kapanış hiçbir şey yazmaz.
- **Kabul:** `--menu-shot=load` ve `=settings` (menü üstünde modal, `D_SCRIM`, tema doğru); `--theme-audit=menu` (yeni) eksik varyasyon basmaz;
  logda `GameShell/ModalLayer missing` yok; `--modal-shot=settings`, `=load`, `=confirm` kareleri değişmedi (piksel).
### 4.4 Görsel yön: "Künye kartı" v2 (maket `SP/v2/menu/` 01–11 + INDEX/NOTES; onaylı 2026-10-11, marka H17)
- **Zemin:** akşam şehri kareyi doldurur (§5); sütun okunurluğu ayrı katman (yatay `GradientTexture2D`: x %24'e kadar `surface-0` %85, %64'te
  sıfır; alt %14 hafif karartma), plakaya pişmez. **Sütun:** sol üst sabit `VBoxContainer` (112, 236) (1536: (88, 112)); marka logo kilidi
  S 96 (1536: 76; §2.7); Devam kartı eklenince marka yerinde kalır. **Kalemler** (markanın 48 altında, 1536'da 40): 700/30 `ink-3`, satır 56; tek birincil
  (kayıt yoksa Yeni oyun, varsa Devam kartı) `ink-1` + altında amber 48×3 çizgi (ekrandaki tek amber); klavye odağı başka kalemde `ink-1` + 2 px
  halka; fare üstünde `D_LINE_HOVER`; en uzun kalem "Quit to desktop" ~165 px.
- **Devam kartı** (kare 03): 440 genişlik, `surface-4`, `doc-sm` sağ üst kesik köşe, iç pay 16/24/20, altında 16; "Devam" 700/30 `ink-1` + amber
  çizgi; `line-1` ayraç; amblem 64 (§10.8) + şirket adı 700/26 + `MENU_CARD_LINE` (Plex 15 `ink-2`) + `MENU_LAST_PLAYED` (Plex 14 `ink-3`); kurucu,
  portre, evre, MRR, slogan yok; birincil `Button` (`flat`). **Sol alt:** `MENU_VERSION` `ink-4`, (112, alttan 32) (1536: (88, alttan 24)).
- **Logo kilidi:** her karede H17 kilidi (§2.7); maketlerin tek satırlı markası ve kare 12'nin yığılı kilidi geçersiz. **Açılış → menü:** splash → Godot kartı (aynı zemin) → örtü `MENU_COVER_S`
  ease-out söner, sütun 0 ms; plaka → canlı `MENU_FADE_S`; renk sıçraması yok. **Yok:** slogan, kurucu, künye kartı, sağ alt küme, manşet.
- **Modallar menü üstünde** (`D_SCRIM`): Yükle 760×840 (kare 05, §6.4: kurucusuz grup başlığı, v2 amblem, seçili satırın Yükle'si amber + odak,
  Sil hayalet + onaylı silme); Ayarlar onaylı 640×820, maketle aynı (06; §3.1'in Veri satırı kaydırmada, maket karesinin altındadır); Jenerik 880×700 (07); Lisanslar 960×920 (08); dönüş onayı 520 (09).
- **Kabul:** `--menu-shot=empty|continue|load|settings|credits|licenses|return_confirm` maketle yan yana (CLAUDE §11): sütun ve kart konumu ±4 px,
  kalem satırı 56, amber yalnız birincilde, sol alt sürüm; 1536'da sütun 88, kilit S 76 (kare 10/11); estetik hüküm Erdem'in F5'inde.

## 5. Arka plan: MenuBackdrop (AM4; M5, H4)
- Yeni `scripts/ui/menu_backdrop.gd` + `scenes/menu/MenuBackdrop.tscn` (kök ALWAYS, §4.1). API: `start(office_id: String, minute: float, figure:
  Dictionary = {})`, `signal live_ready`, `func stop()`. **Plaka** (`TextureRect`, `assets/art/menu/backdrop_<office>_<HHMM>.png`,
  `STRETCH_KEEP_ASPECT_COVERED`) ilk karede; **canlı sahne** hazır olunca çapraz geçiş (`MENU_FADE_S`). Menü `start(MENU_OFFICE, MENU_MINUTE)` =
  akşam şehri; onboarding aynı API ile evi ve kurucuyu kurar (§10.9).
- Canlı sahne (AUDIT §3 A): `OfficeView.tscn` ağaca eklenmeden örneklenir, `Viewport3D/SubViewport/World` ayrılır, `People` ve `City` atılır
  (`OfficeView.tscn:63, 122, 125`; emsal `sandbox/asset_lab/lab_scene.gd`); kendi `SubViewport`'unda `OfficeLayout.load(id)` + glb + `_lowest`
  (`office_view.gd:84-88`) + `OfficeMaterials.convert_scene` + `OfficeLighting.new(world)` / `set_layout` / `apply(minute)` +
  `GraphicsSettingsLib.apply_view` (`:190-202`) + `OfficeCamera.fit(bounds, _lowest, id)`. OfficeView yeniden yazılmaz. HUD, giriş, EventBus
  aboneliği, TimeManager bağı yok; saat sabit `minute`. GLB `ResourceLoader.load_threaded_request` ile; ilk kare beklemez. Düşük ön ayarda
  (`settings.gd:36` `graphics_preset == "low"`) yalnız plaka. `stop()` dünyayı serbest bırakır.
- **Şehir** (`city`): nav yok (`office_view.gd:96`). Akşam ışığı motorun kendisidir (kulelerin gece dokusu, yanık camlar, cephe, taç:
  `office_lighting.gd:220-239`); maketin pencere karması gerekmez. Çerçeve `fit` + `fit_zoom *= MENU_CITY_ZOOM` (`OfficeCity._frame_camera` deseni,
  `office_city.gd:261-265`; maketin ×1,75 büyütmesi). `OfficeCity` (kontroller, iğneler, su saati) kurulmaz: su durağan, vapuru `OfficeLighting`
  sürer (`:243-248`). Kayma: `OfficeCamera.focus` iki uç arasında `MENU_DRIFT_S` gidiş-dönüş (isteğe bağlı, Sahibe 28). **Ev** (`home`,
  onboarding): `frame(thumb_targets)` (`:214-215`) + `MENU_STAGE_ZOOM`; ışık dolu (`lighting.anyone_in = true`, istasyonlar `set_station_state(desk,
  true)`, `office_lighting.gd:84, 171`); `figure` doluysa tek `OfficePerson` (§10.9).
- Plaka aynı sahneden: `--menu-shot=bake_plate:<office>:<HHMM>` canlı sahnenin ilk durağan karesini (figürsüz) yazar, `assets/art/menu/`'ye kopyalanır
  (1920×1080 PNG). Maketin plakası gündüz çekiminden pişirildi (`SP/v2/menu/tools/bake_evening.py`); oyununki motorun akşamı, Erdem yan yana bakar.
- **Kabul:** `--backdrop-probe` satırı `BACKDROP|plate_frame=1|live_ms=<n>|fade_ms=<n>|gpu_ms_p50=<n>|gpu_ms_p95=<n>|boot_to_menu_ms=<n>` iki koşu
  (ilk, ısınmış); geçiş öncesi plaka ile sonrası canlı kare (kenar payı 6 px) ortalama mutlak fark ≤ 6/255, yoksa ⚠️; `--menu-shot=plate`, `=live`;
  `graphics_preset=low` ile `live_ms=n/a`; menü → YENİ OYUN sonrası iki kare: `OBJECT_NODE_COUNT` == `--onboard-shot=1` doğrudan kurulumundaki
  sayı (±0), kökte menünün `MenuBackdrop`'u yok, `RenderingServer.get_rendering_info(RENDERING_INFO_TEXTURE_MEM_USED)` menü öncesinin +%5'i içinde.

## 6. Kayıt kimliği, Yükle ve Devam (AM5; S1, S2, S29, YENİ-2)
### 6.1 Koşu kimliği ve meta
- `GameState.run_id: String` (varsayılan ""): taze koşuda `initialize_run` üretir (gerçek saat ms + `get_ticks_usec`, taban 36; `RngStreams`'ten
  çekmez, `^PROBE` baytları değişmez); yüklemede kayıttan (SaveCodec kendisi bulur). Kimliksiz eski kayıt yüklenince yeni kimlik alır; eski
  yuvaları "Eski kayıtlar" grubunda kalır.
- `build_meta()` (`save_manager.gd:225-238`; `company_name`, `day`, `cash` zaten var) ekler: `run_id`, `logo_style` (AM9b'de `logo`, §10.8),
  `saved_msec` (`int(Time.get_unix_time_from_system() * 1000)`). Kurucu meta'ya girmez (menü göstermez). Şema artmaz; eksik anahtar "" / 0.
- `SaveManager._slot_row` (`:513-533`) meta'sı `company_name`, `run_id`, `logo_style` (AM9b'den `logo`), `saved_msec` da taşır (eksikse "";
  `saved_msec` yoksa `unix_time*1000`). `list_slots` (`:120`) önce `saved_msec`'e, eşitlikte `day`'e göre sıralar.
### 6.2 Yuvalar koşu başına
- Kimlikler: `quick_<run_id>`, `auto_<run_id>_<1..3>` (§13), `manual_N` (meta'da `run_id`). `_next_auto_slot_id` (`:426-438`) yalnız aynı koşunun
  oto yuvalarını yuvarlar, en eskiyi meta `saved_msec`'ten seçer (mtime saniyeliktir); `quicksave()` koşunun hızlı yuvasına yazar. Eski `quick`,
  `auto_1..3` okunur, silinmez, yazılmaz. `_label_for` (`:536-541`) yeni kimlikleri bugünkü etiketlerle adlandırır.
- `SAVE_DIR` sabit kalır; `var _dir := SAVE_DIR` + debug seam `SaveManager._use_dir(path)`; `_path_for`/`list_slots` `_dir` okur.
- `SaveManager.list_runs() -> Array`: `list_slots()`'u `run_id`'ye (kimliksizleri `company_name`'e) göre gruplar; grup `{run_id, company_name, logo,
  newest_msec, slots, backups}` (`logo` AM9b'ye dek `logo_style`), en yeni önce; `backups` oto yuvalarıdır.
### 6.3 Devam kartı
- DEVAM = `list_slots()`'un `saved_msec` en büyük yüklenebilir satırı (H3, hangi koşu olursa). Kart (§4.4): `LogoEmblem` (meta `logo`; yoksa
  `logo_style` eşlemesi; ikisi de yoksa adın ilk adayı, §10.8), şirket adı, `MENU_CARD_LINE` (`{week}` = meta `day`, tik bir haftadır; `{cash}`
  `Fmt.money_exact`), `MENU_LAST_PLAYED` (`{when}`: yeni `Fmt.ago(unix)` `scripts/util/fmt.gd`'de anahtar ve sayı döndürür, statik olduğu için `tr()`
  çağırmaz, kart `Fmt.count_key` deseniyle çevirir; 7 günden eskide `_stamp` tarihi, `save_load_modal.gd:161-166`; Sahibe 28). Okunamayan kayıt
  Devam olmaz.
### 6.4 Yükle penceresi
- `SaveLoadModal` yükleme kipinde gruplu: grup başlığı (amblem, ad, son oynanış, `SAVE_GROUP_COUNT`; kurucu yok, maket 05); altında el ve hızlı
  yuvalar en yeni önce; oto yuvalar katlanır `SAVE_GROUP_BACKUPS` alt listesi (BA "Recover saves"). Kayıt kipinde yalnız şimdiki koşunun grubu.
  Modalın `_slot_row` (`save_load_modal.gd:80`; §6.1'dekinden ayrı) ve `_meta_line` (`:146-158`) şirket adını basar.
- Menüden yükleme `_load_slot` (§4.1); `game_loaded` yayılır (B'nin PRD_SPRINT S7 `sync_plan_hold`'u inince o kanca da çalışır).
- Harness fikstürleri: `_shot_saves` (`main.gd:1796-1810`) meta'ya `run_id`/`company_name`/`logo_style` yazar ve iki şirket kurar; `load_delete`
  (`:1737-1738`, bugün `[2]` indeksi) sil düğmesini satırın etiketiyle bulur. `--modal-shot=save|load|load_delete|save_overwrite` AM5'te yeniden çekilir.
- **Kabul:** smoke `menu_state_machine` yuva bölümü (§11.2); `save_roundtrip_fingerprint`, `save_double_load_no_residue`, `save_backup_fallback`,
  `autosave_writes_off_thread`, `bootstrap_milestone_keeps_the_run` yeşil; `--menu-shot=load` (iki şirket, biri eski kayıt, açık yedek grubu)
  TR/EN 1920/1536.

## 7. Ana menüye dön: süreç içi (AM6; M3, M4, H2)
### 7.1 Tek yol
- `SaveManager.end_run()` (yeni) = `_join_write()` + `reset_all_owners()` + `GameState.set_run_active(false)` + kirli bayrak ve damga temiz (§9.2) +
  **son adım `EventBus.speed_change_requested.emit(0)`** (`TimeManager.reset` hızı 1 yapar ve ağacı açar, `time_manager.gd:269-279`;
  `initialize_run` TimeManager'a dokunmaz).
- **Statik denetim (AM6 başı):** `git grep -n "^static var" scripts/systems scripts/autoload` listesi; `reset_all_owners` (`save_manager.gd:280-317`)
  ya da `initialize_run`'da sıfırlanmayan her statik (ör. `SprintSystem`, `EndingsSystem` mandalları, `OfficeSystem`,
  `InfraSystem._warning_consumed_version` `infra_system.gd:101`, `SummarySystem._month_line` `summary_system.gd:45`) ya `end_run`'a eklenir ya rapora
  gerekçeyle yazılır (Sahibe 13).
- `main._return_to_menu()`: `_teardown_run_ui()` → bir kare → `SaveManager.end_run()` → `_mount_menu()`. Shift+F4 (`:3589-3600`) aynı yolun debug
  kısa devresi kalır. `EndingsSystem.build_scope_override` ve komut satırı süreçte kalır: `--build=ea` korunur.
- Sistem menüsü (`system_menu_modal.gd:29`): `MainMenuBtn` kilidi kalkar. Kaydedilmemiş ilerleme yoksa doğrudan döner; varsa 3 yollu onay
  (`:55-71` kalıbı): `SYS_MENU_SAVE` (amber; kaydedilemezken kilitli, gerekçe altında) · `SYS_MENU_DISCARD` (tehlike) · Vazgeç (odak); başlık
  `SYS_MENU_TITLE`, gövde `SYS_MENU_BODY_WEEKS` (`n` = `day` − damga günü, §9.2; `n` 0 ise `SYS_QUIT_BODY`); maket 09.
- Son ekranı ANA MENÜ (`main.gd:3523-3532`): yeni el yuvası korunur (`_keep_run_for_main_menu`, HARITA:92), sonra `_return_to_menu()`;
  `OS.set_restart_on_exit` satırı silinir. ACIK 872 kapanır.
- **Kabul:** smoke `menu_state_machine`; `--menu-shot=return_confirm` (karar yokken ve `:gate`) TR/EN; MCP: EA koşusunda menüye dön → yeni oyun →
  `_dbg_menu_digest().scope == "ea"`; `bootstrap_milestone_keeps_the_run`, `milestone_clock_hold` yeşil.
## 8. Çıkış onayları (AM7; M9)
- `main._ready`: `get_tree().set_auto_accept_quit(false)`. `main._notification(NOTIFICATION_WM_CLOSE_REQUEST)`: kabuk kurulu ve
  `has_unsaved_progress()` ise önce `_on_system_menu_requested()` ile sistem menüsünü takar, sonra onun `_on_quit` gövdesini çağırır
  (`confirm3_gate` yolu, `main.gd:1747-1750`; karar beklerken `main.gd:3354` boş ModalLayer'da onayı reddeder). Onay zaten açıksa yok sayılır;
  onay yine kurulamazsa `get_tree().quit()`: pencere hiçbir hâlde kapanmaz kalmaz. Aksi hâlde `get_tree().quit()`.
- `SaveManager._notification` ve `_autosave_on_close` (`save_manager.gd:64-66, 392-397`) silinir: kapanışta sessiz yazım yerine soru (H2).
  `_exit_tree` yazım beklemesi kalır. Menüde, Godot kartında, onboarding'de ve son ekranında (`run_active` false) X doğrudan kapatır.
- **Kabul:** MCP: kabukta bir hafta oyna → `_dbg_close_request()` → onay açık, süreç yaşıyor; Vazgeç → oyun sürer; "Kaydet ve çık" → oto yuva
  yazılır, süreç biter; karar beklerken aynı seam → onay açık, kare `--modal-shot=confirm3_gate` ile piksel eş; menüde → süreç biter;
  `--modal-shot=confirm3`, `=confirm3_gate` değişmedi.

## 9. F5/F9, kirli bayrak, tostlar, S54 (AM8)
### 9.1 F9 (S4, S51)
- `_on_quickload_requested` (`main.gd:3424-3428`): ModalLayer'da açık modal varsa (onay dahil) hiçbir şey yapmaz (F9 `game_shell.gd:60-67`'de modal
  bekçisinden önce yayılır; `game_shell.gd`'ye dokunulmaz). Koşunun hızlı yuvası yoksa tost `SAVE_TOAST_NOT_LOADED` + `SAVE_ERR_NO_QUICK`; karar ya
  da oturum varsa aynı tost + bugünkü gerekçe; kaydedilmemiş ilerleme varsa tehlike onayı (`SAVE_F9_TITLE`, gövde `SYS_QUIT_BODY`, `SAVE_F9_OK`);
  sonra yükleme ve "Yüklendi" tostu. Sistem menüsünün Kaydet/Yükle satırlarında kısayol ipucu `SYS_HINT_F5` / `SYS_HINT_F9`.
### 9.2 Kirli bayrak (S50)
- `SaveManager` `(day, current_hour)` damgasını `initialize_run` (taze ve yükleme), `save_to_slot` başarısı ve `_on_write_done(ok)`'ta alır;
  `_save_in_background` (`save_manager.gd:400-405`) hour'u da yakalar. `has_unsaved_progress()` = `run_active` ve (`_dirty` ya da damga ≠ şimdi).
  `event_resolved` (`:56`) `_dirty`'yi kaldırır. Saatlik sinyale yeni abone yok (PRD_SAAT §7).
- **Kabul:** taze koşu, 0 saat → `has_unsaved_progress()==false`; bir saat → true; oto kayıt sonrası → false.
### 9.3 Tostlar ve çıkış kaydı
- Her başarılı yükleme (menü, Yükle, F9) yeni kabukta `SAVE_TOAST_LOADED` + `SAVE_TOAST_LOADED_WHEN`; Yükle penceresinden elle kayıt başarıda da
  tost (`save_load_modal.gd:191-195`). Çıkış kayıtları (Kaydet ve çık, Kaydet ve dön) oto dönüşe yazar (`system_menu_modal.gd:74-79`
  `quicksave_requested` yerine `exitsave` yolu).
### 9.4 S54 artıkları
- Kurucu adı: boş girilirse `initialize_run` `GameState.founder_name_default = true` yazar (varsayılan false). `CharacterRegistry`'nin
  `language_changed` dinleyicisi bayrak true ise kurucunun `character_name`'ini `tr("HR_ROLE_FOUNDER")` ile yeniden yazar (`character.gd:16` düz
  `@export`; 37 dosyadaki okuyuculara dokunulmaz).
- Efektler: oynatıcı yokken satır kapalı (`SET_SFX_NONE`, `settings_modal.gd:180`). Yolculukta AYARLAR (`main.gd:3334`) → tost
  `SET_BLOCKED_TRAVEL`; ray düğmesi C'nin (`left_tabs.gd:97`).
- **Kabul:** `--office-shot=home:10:toast` dizisi `f9_none`, `f9_gate`, `f9_confirm`, `f9_modal` hâllerini de çeker; smoke `loc_language_switch`,
  `founder_5skill_init`, `recover_preserves_onboarding` yeşil; MCP: TR'de boş adla koşu → EN → Kişisel "Founder"; `--modal-shot=settings` Efektler
  kilitli; `--travel-shot=home` sırasında `settings_requested` → tost.

## 10. Onboarding yükseltmesi (AM9a, AM9b; C'nin C5, C10, H'si main'de olunca; O1–O3, O7–O11, H6, H15, H16)
### 10.1 Sınırlar
- Üç adım (Karakter · Köken · Şirket), yön C "Sahne". Zorluk yalnız başlangıç kasası (H15). Başlangıç yılı, ek kurucu, 3B karakter yaratıcı, şablon
  kaydet/yükle kapsam dışı (O12). C'nin R8'i (O4–O6) olduğu gibi kalır; bu bölüm onun üstüne kurulur ve R8 kabulünü kırmaz.
### 10.2 İlk hafta belgesi ve sonuç satırları (O7, O8, O10)
- Her adımda sağda sabit **İlk hafta** belgesi (`scripts/onboarding/first_week_doc.gd`, yeni; başlık `ONB_FIRST_WEEK`, sağında `ONB_WEEK_ONE`,
  `GameState.get_date_dict(1)`'den): antet (3. adıma dek kesik 56 kutu + `ONB_DOC_COMPANY_EMPTY`; sonra amblem 56 + şirket adı + `ONB_FOUNDER_LINE`),
  kurucu özeti (portre 80×100, ad, köken satırı ya da `ONB_DOC_STEP2`, huy çipleri `tag-pos`/`tag-risk`, sekiz beceri iki sütunda ad + cetvel +
  puan), Zorluk (§10.7), başlangıç tablosu (Kasa · `ONB_DOC_BURN` · Runway · `ONB_DOC_OFFICE` Ev · `ONB_DOC_TEAM` `ONB_TEAM_SOLO`), dipte rehber
  anahtarı (§10.4). Frank çek listesi yok; ayrı özet ekranı yok (O10 bu belgedir). `draft_changed` dinleyen `PanelContainer`, yazmaz; koşu
  yokken değerler sabitlerden okunur, GameState'ten değil.
- Sayılar yalnız kodun gerçek sonucunu yazar: Kasa = `roundi(origin.starting_cash × DIFFICULTY_CASH_MULT[d])` (`founder_constants.gd:56, 68`, köken
  satırı okunur); Runway `weeks = UiTokens._runway_weeks(GameState.runway_months_for(kasa, -FinanceSystem.starting_daily_burn()))` (`ui_tokens.gd:446-447`,
  `game_state.gd:473-476`), birim TopBar'ınki (`RUNWAY_UNIT_WEEKS`; maketin "ay"ı bağlayıcı değil, Sahibe 23). Köken kartı kasa satırı taşımaz
  (kasanın sahibi zorluk); `ONB_ORIGIN_PLACE` kalır. Okunmayan bayrağa dayanan çipler (`ONB_ORIGIN_SM_CHIP_PRESS`, `_RESILIENT`) tarif cümlesi
  olur, sayı ya da söz taşımaz (H10; TR/EN onay bekliyor).
- **Kabul:** Sıfırdan + Normal için belge runway'i `--skip-onboarding` kabuğunun ilk karesindeki TopBar runway'iyle eş; Kolay/Zor kasası = 10.000 × çarpan.
### 10.3 Beceri kelime etiketleri ve Rastgele/Sıfırla (O9)
- Cetvel sayısının yanında `ONB_SKILL_WORD_0..3` (eşikler §13). Karakter adımında Rastgele (11 gerçek portreden biri + ad; HR aday adı
  üreticisinden) ve Köken adımında Rastgele (huy formülüne uygun huylar + 6 puan, `FounderConstants.validate_traits` geçer) · Sıfırla (adımın
  taslak alanları boş). Rastgele kendi `RandomNumberGenerator`'ını kullanır.
### 10.4 "Frank'le rehberli başla" (O11, YENİ-4)
- Anahtar `ONB_GUIDED` İlk hafta belgesinin dibinde, her adımda; açıkken altında `ONB_GUIDED_NOTE` (susturma gerçektir, `gate.gd:159-162`). Taslağa
  `frank_guided: bool` (`guided` Olay Motoru v3'te harness kipidir, `PRD_OLAY_MOTORU_V3.md:140`). `initialize_run` true ise
  `EvFlags.set_flag("tutorial_active", "onboarding")` (`flags.gd:28`; kanca `gate.gd:159-161`, `engine.gd:319`). Kapsamda `tutorial` etiketli kart
  yoksa anahtar kilitli ve kapalı, gerekçe `ONB_GUIDED_LOCKED`; maketteki "açık" fikstürdür. İçerik ve varsayılan Erdem'in (Sahibe 8).
### 10.5 Vazgeç ve perde (O2, O3)
- Kâğıdın alt bandı (80, `surface-2`): Adım n/3 · Geri · İleri; 3. adımda amber `ONB_START` (var olan anahtar, değeri değişir §12). Perde (maket 07):
  `surface-0`; amblem 112 (§10.8), şirket adı, `ONB_WEEK_ONE`, `ONB_PREPARING` (var), belirsiz çubuk 240; sol altta küçük oyun markası (tek satır, Barlow
  700/16 `ink-3`); slogan yok (H12).
- Üst şeridin sağında hayalet `SYS_MAIN_MENU` + Esc tuş kapağı; taslak boş değilse onay (480, maket 06) `ONB_CANCEL_TITLE`/`ONB_CANCEL_BODY`:
  ikincil `SYS_MAIN_MENU`, birincil ve odak `ONB_CANCEL_STAY` (güvenli varsayılan kalmaktır); adımda Esc aynı yol, modalda Esc = devam. Onay →
  `MenuBackdrop.stop()`, `_flow` serbest → `_mount_menu()`.
- Sahte 1 sn (`onboarding_flow.gd:170`) silinir: perde görünür olunca sahne `stop()` (§10.9), `await RenderingServer.frame_post_draw`, sonra
  `initialize_run`; `_swap_to_shell_and_modal` `_flow`'u `await _mount_shell()` **sonra** serbest bırakır (bugün önce, `main.gd:2954-2958`).
  `ONB|curtain_ms` ilk çizilen perde karesinden kabuğun ilk karesine ölçülür, > 0.
### 10.6 Görsel yön: "Sahne" (maket `SP/v2/onboarding/` 01–07 + INDEX/NOTES; onaylı 2026-10-11)
- **Sahne:** akşam evi tam kare (§10.9); seçilen kurucu odada ayakta, kâğıtlar önünde; kurucuda ad plakası yok. **Üst şerit:** solda oyun markası
  (H17 kilidi, S 40), sağda hayalet `SYS_MAIN_MENU` + Esc. **Kâğıt** (48, 388) 1348×660, `surface-3`, `line-2`; kalkık kâğıt `shadow_window` + sağ
  üst kesik köşe; üstünde üç sekme (C): (1) KARAKTER, (2) KÖKEN · Huy ve yetenek, (3) ŞİRKET · Ad ve logo; şimdiki sekme 53 yüksek; biten sekme
  özetini yazar ("✓ KARAKTER · Deniz" + portre 24, "✓ KÖKEN · Sıfırdan"). **İlk hafta belgesi** (1428, 88) 444×960; bölümler `t-label` + çizgi;
  beceriler iki sütun (ara 24, satır 24, Plex 14); zorluk üç hücre (ara 8); başlangıç tablosunun etiket sütunu 96.
- **Adım 1** (maket 01): başlık + `ONB_STEP1_INTRO`, sağda Rastgele/Sıfırla; ad satırı (`ONB_NAME_LABEL`, giriş 360, 5/40, ipucu `ONB_NAME_HINT`);
  yüz ızgarası `GridContainer` 8 sütun, ara 12, hücre 152×190: 11 gerçek portre (toggle `Button` + `ButtonGroup`, seçili ✓ rozeti 24) + 5
  `ONB_PORTRAIT_SOON` yer tutucu (disabled `Panel`; kesik çizgi `_draw` içinde `draw_dashed_line`, `StyleBoxFlat` kesik çizmez). 16 temiz sığdı.
- **Adım 2** (maket 02–04): C'nin üç sütunu 352 / 400 / kalan, ara 32: Köken (kilitli Mirasyedi / Kurumsal Firari; kasa satırı yok), Huylar,
  Yetenekler (8 satır: ad, cetvel 100, adımlayıcı 32; kalan puan); kelime etiketi (§10.3); yalnız motorda formülü olan üç kartta sonuç satırı
  (Satış: `SALES_READ_THRESHOLD` ve erişim bandı; Liderlik: `LEAD_MORALE_PER_POINT`; Karizma: `CONV_FOUNDER_MAX` dalı), öbür beşi r5 tarifi, aynı
  satır yüksekliği ve tip. **Adım 3** (maket 05): `ONB_STEP3_INTRO`; ŞİRKET ADI giriş 520 (12/40); LOGO başlığı + `ONB_LOGO_CAPTION` + sağda
  ikincil `ONB_LOGO_REROLL` (zar ikonu); 12 amblem 6×2, ara 16, karo 104 (seçili ✓ 22); slogan alanı yok (H12).
- **1536×864** (maket 04): kâğıt (24, 260) 1088×588, sütunlar 300 / 316 / kalan; belge (1136, 80) 376×768; kilitli köken kartı başlık satırına iner,
  huy satırı 40, beceri satırı 51, adımlayıcı 28, tarif Plex Sans Condensed; hiçbir şey kaymaz; en küçük metin 13 mantıksal px.
- **Kabul:** `--onboard-shot=1..3` maketle yan yana: kâğıt ve belge ±4 px, sonuç satırı yalnız üç kartta, ×1,08 payında TR/EN taşma yok (EN en
  genişleri "Customer Success", "Hard opens once you finish a run."), 1536'da kayma yok; iptal ve perde kareleri maketle eş.
- **Port:** r5/C çerçevelerinin `DIALOGUE_BG` ve ham stylebox/renkleri (`onboarding_flow.gd:60-63, 94, 108-112`; `origin_traits_step.gd:35-42`) `D_*`
  token ve varyasyonlara taşınır, `menajer_theme.tres` `OnboardingFlow` köküne atanır; `LanguageGate` sahnesi ve betiği silinir (H14, §2.6).
### 10.7 Zorluk (H15; AM9a)
- `draft.difficulty` ∈ `easy|normal|hard` (varsayılan `normal`); belgede üç toggle `Button` (`ButtonGroup`), başlık `ONB_DIFFICULTY` +
  `ONB_DIFFICULTY_NOTE`; Zor kilitliyken `disabled` + kilit ikonu, satırın altında `ONB_DIFF_HARD_LOCKED`. `FounderConstants.DIFFICULTY_CASH_MULT`
  (yeni, §13). `initialize_run`: `cash = roundi(origin.starting_cash × mult)` (`game_state.gd:775`); `GameState.difficulty: String = "normal"`
  (SaveCodec bulur, `save_codec.gd:180-188`; eski kayıtta anahtar yok → `normal`, `:200-201`). `--skip-onboarding` yükü (`main.gd:248` @5f888b9) ve
  `--run-log` `normal`: ×1,0, `^PROBE` baytları değişmez.
- Zor kilidi: `main._on_run_ended` (`main.gd:3552`, bağlantı `:3070` @5f888b9) `Settings` `runs_finished`'i 1 artırır: profil, kayıt değil; `DEFAULTS`
  dışı anahtar "Varsayılanlara dön"de kalır (`settings.gd:22-23, 104-110`); `_is_harness_arg` taşıyan koşuda (smoke `--endgame-smoke=` dahil,
  `save_manager.gd:446-450`) yazılmaz. Zor açık = `runs_finished ≥ 1`; her son mu yalnız zafer mi Sahibe 23 (cevaba kadar her son, iflas dahil).
- **Kabul:** `--onboard-shot=2:hard_locked` ve `=2:hard_open` (fikstür `Settings`, kendi `APPDATA`); MCP kendi `APPDATA`'sında `_dbg_finish_run()` →
  `settings.json`'da `runs_finished: 1`, menü → YENİ OYUN → Zor açık; Kolay ile kurulan koşunun ilk karesinde TopBar kasası 15.000; `--run-log`
  `^PROBE` baytları AM9a öncesiyle eş.
### 10.8 Amblem v2 (H16; AM9b)
- `LogoEmblem` (`logo_emblem.gd` yeniden yazılır, doku yok): `configure({shape, color, style, glyphs})`. Şekil `circle|hexagon|square|shield|tag|diamond`
  (daire 64-gen; kalkan ve etiket bir kez düzleştirilmiş poligon); renk `LOGO_PALETTE`'in 8 adından biri (§13; yeni `D_EMB_*`, `THEME_STAMP` artar);
  stil `filled` (şekil renkte, harf `surface-1`) · `outline` (çizgi boyun 5/100'ü, harf renkte) · `split` (eğik kesim: açık yarıda koyu harf, rengin
  %26'sı koyu yarıda açık harf; `Geometry2D.clip_polygons` + iki kırpma); `glyphs` 1–2 harf, Barlow Condensed 700, `Fmt.upper`.
- `LogoEmblem.candidates(company_name, reroll) -> Array` (statik, saf): tohum `hash("%s|%d" % [ad, reroll])`, kendi `RandomNumberGenerator`'ı; 12
  aday: her şekil iki, her stil dört, her renk en az bir kez; harf: iki kelime varsa ilk ikisinin baş harfleri, yoksa ilk harf (1 ve 2 harf karışık).
  Aynı ad aynı ilk seti açar; Yeniden üret `reroll + 1`; ad değişince seçili indeks korunur.
- Taslak `logo: Dictionary`, `logo_style`'ın yerine (`company_step.gd`'nin dört kartı, `LOGO_STYLES` `founder_constants.gd:91-97`, `LOGO_STYLE_*`
  silinir). `GameState.logo: Dictionary = {}` (SaveCodec bulur); `initialize_run` yükten yazar; `logo_style` (`game_state.gd:14, 769`) ve
  `--skip-onboarding` yükü (`main.gd:248` @5f888b9) `logo`'ya geçer. Meta: `build_meta()` `logo` yazar, AM5'in `logo_style` alanı silinir.
- Eski kayıt ve meta `LogoEmblem.from_legacy(style, name)`: `minimalist` → daire · çizgi · Kemik, `tech` → altıgen · çizgi · Petrol, `playful` → daire ·
  dolu · Kiremit, `serious` → kare · dolu · Kemik; tek harf (onay bekliyor); ikisi de yoksa `candidates(name, 0)[0]`. Koşu kromunda yok (Sahibe 25).
- **Kabul:** smoke `menu_state_machine` amblem bölümü (§11.2); `onboarding_pages_contract` beklenen anahtarları (`endgame_smoke.gd:5900-5916` HEAD;
  AM9a `slogan`'ı düşürür, AM9b `logo_style` → `logo`); `--onboard-shot=3`, `=3:reroll` TR/EN; `--menu-shot=continue|load` yeniden (biri eski
  `logo_style` kaydı); `save_roundtrip_fingerprint` yeşil; `--theme-contrast-audit` paletle yeşil.
### 10.9 Sahne figürü (AM9a; fizibilite)
- **Var olan:** `LookSystem.founder(portrait_id)` koşusuz görünüm verir (`FOUNDER_LOOKS`, `look_system.gd:27, 116-117`; portreler bu görünümlerden
  render edildi); `OfficePerson.setup(look)` + `place(spot, "idle")` yürümeden ayakta durur, nav gerekmez (`office_person.gd:253, 335-370`;
  `STAND_ACTS.idle` `:30`); kişi `_enter_tree`'de statik `_people`'a girer (`:324-329`). `PersonBust.texture(look, px)` büst verir, başsızda null
  (`person_bust.gd:38-50`). `docs/mockups/menajer/art/`'ta ayakta figür yok; maket büstü (`portraits/founder_05.png`) plakaya koydu.
- **Yol (öneri):** `MenuBackdrop.start("home", MENU_STAGE_MINUTE, LookSystem.founder(id))` (§5): ev + tek `OfficePerson` `MENU_STAGE_POS`'ta `idle`
  (`home.json`'un `stand` noktaları balkon, mutfak, wc: oturma odası için yeni sabit); yüz seçimi `set_figure(look)` ile kişiyi yeniden kurar,
  sahne kalır. **Yedek** (Düşük ön ayar, başsız, canlı hazır olana dek): `backdrop_home_<HHMM>.png` + `assets/art/portraits/founder_NN.png` 384×480
  (930, 66) (1536: 300×375 (720, 62)), maket 01 düzeni; `PersonBust` gerekmez. Perde görünür olunca, `initialize_run`'dan önce `stop()`: statik
  `_people` kabuğun kalabalığına sızmaz.
- **Kabul:** `--onboard-shot=1` (canlı) ve `=1:plate`; `ONB|stage=live|figure=<id>`; yüz değişince bir kare içinde yeni görünüm; kabuk ilk karesinde
  `OfficePerson._people.size()` `--skip-onboarding` kabuğundakiyle eş.
### 10.10 Kabul
- `--onboard-shot=1..3` TR/EN 1920 ve 1536; durumlar `=1:plate`, `=1:cancel`, `=2:random`, `=2:hard_locked`, `=2:hard_open`, `=3:guided_locked`,
  `=3:reroll`, `=curtain`; `--theme-audit=onboard:1..3` temiz; `--theme-contrast-audit` yeşil; smoke `onboarding_pages_contract`,
  `founder_5skill_init`, `alloc_guard` yeşil; MCP `_dbg_onb_random_x20() == 20`; `ONB|curtain_ms=` > 0 (sabit 1000 ms yok).

## 11. Araçlar (AM3'ten itibaren her commit; AM10 kapanış)
### 11.1 Bayraklar ve seam'ler (debug, `main.gd` tabloları `:174-212`)
- `--menu-shot=<empty|continue|first_frame|godot_card|load|settings|credits|licenses|return_confirm[:gate]|plate|live|bake_plate:<ofis>:<HHMM>|all>`:
  fikstür kayıtları `SaveManager._use_dir("user://shot_menu/")`'a yazılır (iki şirket, biri kimliksiz eski kayıt, bir bozuk dosya); `-shot` olduğu
  için oto kayıt kapalı (`save_manager.gd:445`). `MENU|state=|focus=|continue=|groups=|paused=|joy_ui=` satırı. `godot_card`: kartı takar, kare;
  `ui_accept` → iki kare sonra `MENU|state=menu|focus=NEW` ve kare.
- **Ret kuralı:** `--menu-shot` ve kayıt yazan `--modal-shot` türleri, `user://saves` içinde fikstür dışı dosya varsa `MENU|refused=user_saves`
  basıp 1 ile çıkar (tick-probe kuralı, CLAUDE.md:193). Dosya yazan bayraklar listesine girer (CLAUDE §12).
- `--backdrop-probe[=<ofis>:<HHMM>]`: pencereli; hem `bare` (varsayılan `MENU_OFFICE:MENU_MINUTE`) hem `valued` tablosuna girer (`--render-probe`
  deseni, `main.gd:179, 196`); `_is_harness_arg` zaten kapsar (`save_manager.gd:448`). `--onboard-shot=<n>[:<durum>]`: bugünkü kol
  (`main.gd:1815-1829`) C'nin H hunk'ından sonra §10.10'un durum eklerini alır.
- Argsız debug seam'leri (MCP int taşımaz): `main._dbg_close_request()` (`propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)`),
  `main._dbg_menu_digest() -> Dictionary` `{state, focus, scope: EndingsSystem.build_scope(), run_active, unsaved, speed}`, `main._dbg_onb_random_x20()
  -> int` (geçerli taslak sayısı), `main._dbg_finish_run()` (koşuyu `trigger_ending` ile bitirir; yalnız kendi `APPDATA`'sında).
### 11.2 Smoke `menu_state_machine` (tek yeni vaka; kayıt çekirdeği, CLAUDE §10)
`SaveManager._use_dir("user://smoke_menu_state/")`; sonunda dizin silinir, `_dir` geri alınır; gerçek kayıtlara dokunmaz. (1) `initialize_run({seed:
S})` → K0 = `_save_fingerprint` deseni (`endgame_smoke.gd:8369-8381`: `systems.time.current_speed/last_running_speed` = 0, `game_state.run_id`
silinir) + `EndingsSystem` mandalları ve `SprintSystem` durumunun dökümü; üç hafta ilerlet; hızlı + oto yuvalara yaz. (2) `end_run()` → `run_active`
false, `has_unsaved_progress()` false, `cannot_save_reason_key() == "SAVE_ERR_NO_RUN"`, `TimeManager.current_speed == 0`, `get_tree().paused`.
(3) `initialize_run({seed: S})` → K1 == K0; B koşusu dört oto kaydı yazar (yazımlar arası en az 1 `saved_msec` farkı) → A'nın yuvaları bayt-eş.
(4) Devam seçimi = `saved_msec` en büyük yüklenebilir yuva; bozuk dosya Devam olmaz; `list_runs()` iki grup. (5) Dil (AM3): `detect_language("",
"tr") == "tr"`, `("", "de") == "en"`, `("turkish", "en") == "tr"`, `("english", "tr") == "en"`. (6) Amblem (AM9b): `candidates("Unicorn Inc.", 0)`
iki çağrıda eş, 12 aday, şekil ×2, stil ×4, her renk ≥ 1; `reroll` 1 farklı set; dört `from_legacy` eşlemesi. **Falsifikasyon:** `end_run()`'dan
`reset_all_owners()` ve `_next_auto_slot_id` koşu süzgeci ayrı ayrı çıkarılınca vaka düşer (iki koşu rapora, kod geri alınır).

## 12. Metinler (TR/EN onay bekliyor; EN önce yazılır, tire yok)

| Anahtar | EN | TR |
|---|---|---|
| `MENU_CONTINUE` · `MENU_NEW_GAME` · `MENU_LOAD` · `MENU_CREDITS` | Continue · New game · Load · Credits | Devam · Yeni oyun · Yükle · Jenerik |
| `MENU_CARD_LINE` · `MENU_LAST_PLAYED` · `FMT_AGO_MINUTES|HOURS|DAYS` (tekil/çoğul `Fmt.count_key`) | Week {week} · Cash {cash} · Played {when} · {n} minutes ago / {n} hours ago / {n} days ago | Hafta {week} · Kasa {cash} · {when} oynandı · {n} dakika önce / {n} saat önce / {n} gün önce |
| `MENU_VERSION` · `MENU_BUILD_DEMO|EA|FULL` · `MADE_WITH_GODOT` (kart, Jenerik) · `CREDITS_TITLE` · `CREDITS_LICENSES` (düğme, Lisanslar başlığı, Ayarlar satırı) | {build} · Version {version} · Demo / Early Access / Full · Made with Godot Engine. · Credits · Licenses | {build} · Sürüm {version} · Demo / Erken Erişim / Tam sürüm · Godot Engine ile yapıldı. · Jenerik · Lisanslar |
| `CREDITS_ROLE_DESIGN|CODE|WRITING|ART3D|UI` · `CREDITS_COPYRIGHT` | Game design and production · Programming · Writing · 3D office and characters · Interface · © {year} {holder}. All rights reserved. | Oyun tasarımı ve yapım · Programlama · Yazı · 3B ofis ve karakterler · Arayüz · © {year} {holder}. Tüm hakları saklıdır. |
| `LIC_GODOT_HEAD` · `LIC_THIRD_PARTY` · `LIC_FONTS` · `LIC_ICONS` · `LIC_FREETYPE` · `LIC_GODOT_LOGO` | This game uses Godot Engine, available under the following license: · Third-party notices · Fonts · Icons · Portions of this software are copyright © {year} The FreeType Project (https://freetype.org). All rights reserved. · Godot logo by Andrea Calabró, licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). | aynı (İngilizce; Lisanslar gövdesi çevrilmez; logo atfındaki ad Godot README'sinden, sahip onaylar) |
| `SYS_MENU_TITLE` · `SYS_MENU_BODY_WEEKS` · `SYS_MENU_SAVE` · `SYS_MENU_DISCARD` · `SYS_HINT_F5` · `SYS_HINT_F9` | Return to main menu? · {n} weeks have passed since your last save. Unsaved progress will be lost. · Save and return · Return without saving · F5 · F9 | Ana menüye dönülsün mü? · Son kayıttan bu yana {n} hafta geçti. Kaydedilmemiş ilerleme kaybolur. · Kaydet ve dön · Kaydetmeden dön · F5 · F9 |
| `SAVE_GROUP_BACKUPS` · `SAVE_GROUP_LEGACY` · `SAVE_GROUP_COUNT` · `SAVE_TOAST_NOT_LOADED` · `SAVE_ERR_NO_QUICK` · `SAVE_F9_TITLE` · `SAVE_F9_OK` | Autosaves ({n}) · Older saves · {n} saves · Not loaded · This company has no quicksave. · Go back to the quicksave? · Load quicksave | Otomatik yedekler ({n}) · Eski kayıtlar · {n} kayıt · Yüklenmedi · Bu şirketin hızlı kaydı yok. · Hızlı kayda dönülsün mü? · Hızlı kaydı yükle |
| `SET_SFX_NONE` · `SET_BLOCKED_TRAVEL` · `ONB_CANCEL_TITLE` · `ONB_CANCEL_BODY` · `ONB_CANCEL_STAY` | No sound effects yet. · Settings open when the trip ends. · Cancel setup? · Your choices won't be saved. · Continue setup | Henüz ses efekti yok. · Ayarlar yolculuk bitince açılır. · Kurulum iptal edilsin mi? · Seçimlerin kaydedilmez. · Kuruluma devam et |
| `ONB_STEP1_INTRO` · `ONB_NAME_LABEL` · `ONB_NAME_HINT` · `ONB_PORTRAIT_SOON` | The face in the mirror. This is how they will see you in the room behind. · Your name · Leave it empty and you are 'Founder'. · New portrait | Bu, aynada göreceğin yüz. Arkadaki odada seni böyle görecekler. · Adın · Boş bırakırsan 'Kurucu' kullanılır. · Yeni portre |
| `ONB_FIRST_WEEK` · `ONB_WEEK_ONE` · `ONB_FOUNDER_LINE` · `ONB_DOC_COMPANY_EMPTY` · `ONB_DOC_STEP2` · `ONB_DOC_BURN` · `ONB_DOC_OFFICE` · `ONB_DOC_TEAM` · `ONB_TEAM_SOLO` | Week one · «Week 1 · {month} {year}» · «Founder · {name}» · Step 3: name and logo · Origin, traits and skills come in step 2. · Living and tools · Office · Team · Just you | İlk hafta · «Hafta 1 · {month} {year}» · «Kurucu · {name}» · 3. adımda: ad ve logo · Köken, huylar ve yetenekler 2. adımda. · Geçim ve araçlar · Ofis · Ekip · Yalnız sen |
| `ONB_DIFFICULTY` · `ONB_DIFFICULTY_NOTE` · `ONB_DIFF_EASY|NORMAL|HARD` · `ONB_DIFF_HARD_LOCKED` | Difficulty · Sets your starting cash · Easy / Normal / Hard · Hard opens once you finish a run. | Zorluk · Başlangıç kasasını belirler · Kolay / Normal / Zor · Zor, bir koşuyu bitirince açılır. |
| `ONB_GUIDED` · `ONB_GUIDED_NOTE` · `ONB_GUIDED_LOCKED` | Guided start with Frank · In the first weeks Frank's notes reach your inbox and other events wait. · The guide is being written. | Frank'le rehberli başla · İlk haftalarda Frank'in notları gelen kutuna düşer, öteki olaylar bekler. · Rehber yazılıyor. |
| `ONB_STEP3_INTRO` · `ONB_LOGO_CAPTION` · `ONB_LOGO_REROLL` | The name on the door. From now on this is what they will call you. · Made from your name's initials. Pick one or make a new set. · Make new set | Kapıya asılacak isim. Bundan sonra herkes bu adı anacak. · Adın baş harflerinden üretildi. Birini seç ya da yeniden üret. · Yeniden üret |
| Değeri değişen: `ONB_START` (`:24`) · `ONB_LOGO_LABEL` (`:82`) · `ONB_WHY_LOGO` (C) | Found and start · Logo · Pick a logo | Kur ve başla · Logo · Bir logo seç |
| `ONB_ORIGIN_PLACE` · `ONB_EFFECT_SALES|LEAD|CHARISMA` · `ONB_RANDOM` · `ONB_RESET` · `ONB_SKILL_WORD_0..3` | Starting place · {place} · maket 03/04 satırları (`{stars}` şablonlu; Karizma eşik dalı) · Randomize · Reset · None · Weak · Fair · Good | Başlangıç yeri · {place} · maket 03 satırları · Rastgele · Sıfırla · Yok · Zayıf · Yeterli · İyi |

Var olanlar yeniden kullanılır: `SYS_MAIN_MENU` (`strings.csv:261`), `SYS_QUIT` "Masaüstüne çık" (`:263`), `SYS_QUIT_TITLE/BODY` (`:264-265`),
`SYS_CANCEL` (`:268`), `SET_CLOSE` (`:255`), `SAVE_TOAST_LOADED(_WHEN)` (`:300-302`), `RUNWAY_UNIT_WEEKS`. Silinen: `LOGO_STYLE_*` (`:83-86`, AM9b),
`ONB_SLOGAN_LABEL`/`_PLACEHOLDER` (`:87-88`, AM9a). `SYS_SOON` başka yerde yaşıyor, kalır. Ekleme bayt-span (token `[a-z_]+`, iki dilde aynı).

## 13. Tasarım sabitleri (onay bekliyor; değer iner, sahip F5'te çevirir)

| Sabit | Değer | Not |
|---|---|---|
| `application/config/version` · `GODOT_CARD_S` | `0.1.0` · 1,5 sn | sürüm şeması sahibin (maketteki 0.4.0 yer tutucu); kart atlanır, süreçte bir kez (Sahibe 26) |
| `MENU_OFFICE`, `MENU_MINUTE`, `MENU_CITY_ZOOM` | `city`, 19:30 (1170), 1,75 | kabulde `--office-shot=city:19` ile `:20` arasından pencereleri yanık kare seçilir; GDD ch12 §6 "ODA night scene" yerine (§15.2) |
| `MENU_STAGE_MINUTE`, `_POS`, `_ZOOM` · `MENU_DRIFT_S`, `MENU_FADE_S`, `MENU_COVER_S` | 19:30; oturma odası zemin noktası; maket figür kutusu (930, 66) 384×480'e oturan değer · 40 sn gidiş-dönüş, 0,6 sn, 0,2 sn | ev sahnesi (§10.9) · örtü: açılıştan menüye `surface-0` ease-out |
| `DIFFICULTY_CASH_MULT` · Zor kilidi | Kolay 1,5 · Normal 1,0 · Zor 0,6 · `Settings.runs_finished ≥ 1`, her son sayılır | Sıfırdan'da $15.000 / $10.000 / $6.000 (sahip örneği; Sahibe 23) |
| Portre ızgarası · amblem boyları | 16 hücre (11 + 5 yer tutucu), 8×2, 152×190 · karo 104, Devam 64, antet 56, perde 112 | Sahibe 24 · §10.8 |
| `LOGO_PALETTE` (`D_EMB_*`) | Kemik `#E6DED0` · Kiremit `#D9704E` · Zeytin `#A9B25E` · Adaçayı `#82BD9B` · Petrol `#4BA8B0` · Çelik `#7FA2DE` · Leylak `#AC8EDB` · Gül `#DE8DAB` | kömür üstünde orta açık; amber birincil ve `#FFA028` marka gibi okunmaz (Sahibe 25) |
| Oto yuva / koşu · beceri kelime eşikleri · Jenerik · Lisanslar · Yükle (menüde) | 3 · 0 / 1 / 2 / 3+ puan → Yok / Zayıf / Yeterli / İyi · 880×700 · 960×920 (1536'da 960×760) · 760×840 (1536'da gövde kayar) | eski koşuların yuvası budanmaz (Sahibe 6) · cetvel = puan × `RULER_SCALE` (`founder_constants.gd:30`) · pencereler SPEC §9'a girer; kabuktaki Yükle 660×580 kalır |
| Logo kilidi boyu S | splash 128 · menü 96 (1536: 76) · Jenerik 48 · onboarding şeridi 40 | geometri §2.7; Erdem kareyi onayladı, F5'te değişebilir |
| Menü sütunu · marka; onboarding kâğıt · belge | (112, 236) · kilit 96 (1536: (88, 112) · 76); (48, 388) 1348×660 · (1428, 88) 444×960 (1536: (24, 260) 1088×588 · (1136, 80) 376×768) | §4.4, §10.6 |

## 14. Commit sırası ve kapılar

Her commit: `"$GODOT" --headless --path . --event-lint` → `-s res://scripts/debug/loc_residue.gd` → `bash tools/smoke_run.sh loc_csv_integrity` → hedefli
smoke (`for c in <vakalar>; do bash tools/smoke_run.sh "$c" || exit 1; done`) → görsel kabul → inceleme (§1 bütçesi; AM0 ve AM11'de yok) → commit; `class_name` değişirse önce `--headless --import`.

| # | Commit | Bağımlılık | Kapı |
|---|---|---|---|
| AM0 | v2 setleri repoya: `SP/v2/menu/` → `screens/ana_menu/`, `SP/v2/onboarding/` → `screens/acilis_v2/` (HTML, CSS, gen, INDEX, NOTES; PNG gitignore'da; mutlak yollar göreli olur); karelerin markası H17 kilidine çevrilir (01–04, 07, 10, 11;
`v2/kilit/make.py` deseni), `12_logo_varyant` silinir | yok (Erdem onayı 2026-10-11) | `render_all.sh` yeniden üretir, INDEX dosya listesiyle eş; repo dışı yol kalmaz (`grep -r "AppData"` boş) |
| AM1a | `make_lockup.py` + `lockup.svg` (§2.7), splash, Godot kartı sahnesi + `godot_logo.svg`/`_mono.svg`, ikon, sürüm, `build_scope` editör kapısı, preset'ler, `write_licenses.gd`, `export_build.sh` (main.gd yok) | yok | §2.1 (a), §2.2 git satırları, §2.3 AM1a, §2.5 AM1a (14 dosya); `all_scripts_load` |
| AM1b | Dışa aktarım ve exe kabulleri (kod yoksa yalnız rapor) | AM3 + sahip şablonları kurdu | §2.2 ikon, §2.4, §2.5 AM1b; kurulmadıysa Done'da ⚠️ |
| AM2 | Jenerik + Lisanslar + Ayarlar → Veri satırı, `data/credits.json`, CSV | AM1a (sürüm, logo) | §3.4 AM2; `--modal-shot=settings_end` TR/EN |
| AM3 | Ana menü, gezinme, kabuksuz modal katmanı, Godot kartı bağlantısı, açılış hedefi, dil tespiti + kapının açılış yolundan çıkışı, `_run_args` editör kapısı, `BUILD|` satırı, `--menu-shot` iskeleti | AM2; Onarım 1'in main.gd hunk'ları main'de ya da main.gd'de yabancı kirli hunk yok; B-D1/C-H/V7 `valued` satırları komşu, dokunulmaz | §4 kabulleri, §2.1 (b), §2.3 AM3, §2.6, §3.4 AM3; `onboarding_pages_contract`, `loc_language_switch`, `all_scripts_load` |
| AM4 | MenuBackdrop (şehir) + plaka, `--backdrop-probe`, `bake_plate` | AM3 | §5 kabulü; plaka PNG commit'te |
| AM5 | Koşu kimliği, meta, koşu başına yuvalar, `_use_dir`, Yükle gruplama, Devam kartı, `Fmt.ago`, fikstürler | AM3; `save_manager.gd` A bitince | §6 kabulü (vakanın yuva bölümü AM6'da tamamlanır) |
| AM6 | Statik denetim, `end_run`, `_return_to_menu`, sistem menüsü ve son ekranı ANA MENÜ, smoke + falsifikasyon | AM5 | §7 kabulü; yeni vaka + §6.4 listesi |
| AM7 | Çıkış onayları (X, Alt+F4), `_autosave_on_close` silinir | AM6 | §8 kabulü |
| AM8 | F9 onayı ve modal bekçisi, kirli damga, tostlar, çıkış kaydı, ipuçları, S54 | AM7 | §9 kabulü; `speed_save_clamps_to_ladder`, `autosave_writes_off_thread` |
| AM9a | Onboarding Menajer portu + sahne figürü (ev, `MenuBackdrop` `figure`) + adım 1 (16 hücre), 2 ve 3 (slogansız; amblem karoları AM9b'de) + İlk hafta belgesi + zorluk ve Zor kilidi + rehber anahtarı + slogan ve dil kapısı silme + iptal/perde | C5, C10, C'nin H'si main'de; AM4; AM8 | §10.2–§10.7, §10.9, §10.10 (`=3:reroll` hariç) |
| AM9b | Amblem v2 (`LogoEmblem`, aday üretici, adım 3 karoları ve Yeniden üret, palet token'ı, `THEME_STAMP`), `GameState.logo`, meta ve eski eşleme, Devam/Yükle amblemi | AM9a; AM5 | §10.8; `--menu-shot=continue|load` yeniden |
| AM10 | Araç kapanışı: `--menu-shot=all`, `--backdrop-probe` son ölçüm, CLAUDE §12 satırları | AM1a–AM9b | iki koşu, satırlar AM4 ölçümüyle yan yana |
| AM11 | Belgeler (§15.2) | AM1a–AM10 | loc kapıları; `git show --stat` yalnız belgeler |

## 15. Dosyalar ve sahiplik
### 15.1 Dokunulacak dosyalar
- **Yeni:** `docs/mockups/menajer/screens/{ana_menu,acilis_v2}/**` (AM0), `scenes/menu/**` (MainMenu, MenuBackdrop, GodotCard, Credits, Licenses),
  `scripts/menu/**`, `scripts/ui/menu_backdrop.gd`, `scripts/onboarding/first_week_doc.gd` (AM9a), `assets/brand/**` (`lockup.svg`, ikon, iki Godot logosu), `tools/brand/make_lockup.py`,
  `assets/art/menu/**`, `assets/licenses/**` (gerekirse), `data/credits.json`, `scripts/debug/write_licenses.gd`, `tools/export_build.sh`,
  `export_presets.cfg`, `docs/mockups/menajer/screens/modallar_acilis/tools/boot_splash.html`.
- **Paylaşılan, hunk bazlı:** `scripts/main/main.gd` (AM3'ten): `_ready`, `_mount_godot_card`, `_mount_menu`, `_free_menu`, `_mount_language_gate`
  (silinir), `_run_args`, `_modal_layer`, sinyal taşıması, `_teardown_run_ui`, `_swap_to_shell_and_modal`, `_load_slot`, `_on_quickload_requested`,
  `_on_settings_requested`, `_on_milestone_main_menu`, `_on_run_ended` (yalnız `runs_finished`), `_return_to_menu`, `_notification`, `_dbg_*`,
  `_shot_saves`, `--skip-onboarding` yükü, harness kolları (B-D1, C'nin H ve v3 V7 kolları `valued` tablosunda komşu satırdır: kendi satırını ekle).
  - `scripts/autoload/save_manager.gd` (A bitince); `game_state.gd` (yalnız `run_id`, `founder_name_default`, `difficulty`, `logo`, `initialize_run`
    üretimi ve kasa satırı, `_build_founder` ad satırı); `character_registry.gd` (yalnız `language_changed`); `localization.gd` (yalnız ilk açılış
    tespiti); `endings_system.gd` (yalnız `build_scope`); `settings_modal.gd` (yalnız Veri satırı, Efektler kilidi); `system_menu_modal.gd`,
    `save_load_modal.gd`, `SaveLoadModal.tscn` sahipsiz → bu task (PRD_ACILIS §7.4).
  - `scripts/onboarding/**`, `scenes/onboarding/**`, `founder_constants.gd` (yalnız `DIFFICULTY_CASH_MULT` ve `LOGO_STYLES` silinmesi; köken satırları
    okunur): C'nin commit'leri (C5, C10, H; C'nin `:75` hunk'ı) inene kadar dokunulmaz. `logo_emblem.gd` (AM9b), `fmt.gd` (yalnız `ago`),
    `ui_tokens.gd` + `build_theme.gd` + iki tema (yalnız `D_EMB_*`, `THEME_STAMP`). `project.godot`: yalnız `boot_splash/*`,
    `config/icon`, `config/windows_native_icon`, `config/version`; editör yeniden kaydı commit'lenmez.
  - `localization/strings.csv`: yalnız §12 anahtarları, bayt-span; başka oturumca stage'li olabilir, dokunmadan önce bak. `endgame_smoke.gd`: yalnız
    `menu_state_machine` ve `onboarding_pages_contract`'ın beklenen anahtarları (dosya kirli, `M`; yalnız kendi hunk'ın). `loc_residue.gd`: yalnız `:36`.
- **Dokunulmaz:** `scripts/ui/office/**` (okunur), `scenes/office/**`, `art/office3d/**`, `addons/**`, `scripts/main/game_shell.gd`,
  `scripts/ui/components/toast.gd`, `scripts/modals/ending_scene.gd` (Sahibe 7), `scripts/ui/components/left_tabs.gd` (C).
### 15.2 Belgeler (AM11)
- `docs/HARITA.md`: yeni "Ana menü" bölümü (sahne, durum makinesi, Godot kartı, `MenuBackdrop`, Jenerik/Lisanslar, dil tespiti, bayraklar, `_dbg_*`);
  Kayıt (29-38: `run_id`, koşu başına yuvalar, `saved_msec`, `list_runs`, `_use_dir`, `end_run`, çıkış kaydı, kapanış onayı, `logo`, `difficulty`);
  Platform (45-53); Kabuk (81, 92: `_return_to_menu`, `_mount_menu`); Onboarding (306-315: dil kapısı satırları silinir; İlk hafta belgesi, sahne
  figürü, zorluk, amblem v2); `:341` `assets/brand/icon.svg`; Araçlar (`--menu-shot`, `--backdrop-probe`, yuva paylaşan vakalara `menu_state_machine`).
- `GDDs/GUNCELLEMELER.md` ch12: C'nin "§5 Onboarding" maddesinin altına ayrı paragraf (İlk hafta belgesi, sonuç satırları, Rastgele/Sıfırla, rehber
  anahtarı kilitli, zorluk yalnız kasa ve Zor kilidi, amblem v2, slogan yok, dil kendiliğinden, Ana menü + iptal onayı, gerçek perde); yeni madde
  "§6 ODA, 'Main menu: ODA night scene'" (yürürlükteki (onay bekliyor): ana menü akşam şehrinin kişisiz vitrinidir; plaka yedeği; Düşük ön ayarda
  plaka). `:390`'a dokunulmaz.
- `docs/ACIK_ISLER/ACIK_KARARLAR.md`: yalnız 872-875 "ANA MENÜ sonrası" kapanışı + dosya sonuna (Onarım 1'in 107'sinden sonra) ayrı hunk'la yeni madde
  "Menü sonrası açıklar: L5 Xbot küçük resimleri (yayın engeli), D6 `use_custom_user_dir` + göç, M8 Steam istek listesi (menüden düştü, 2026-10-11;
  URL gelince yeri sahibin), M7 UI tık sesi". `CLAUDE.md` §6 Kayıt cümlesine koşu kimliği ve koşu başına yuvalar; §12 bayrak satırları ve "dosya
  yazan bayraklar"a `--menu-shot`; A ve C'nin satırlarına dokunmadan ayrı hunk.

## Sahibe bırakılan kararlar

Erdem 2026-10-11'de PRD'yi onayladı: 22–28'de aşağıdaki öneriler uygulanır; sabitler §13 değeriyle iner, F5'te değişebilir.

1. (kapandı, 2026-10-11, H17) Logo kilidi: kare solda, "Project" / "Unicorn" sağda iki satır; turuncu kare marka olarak kalır, ikon yalnız kare.
2. **Müzik** (L3, M7; soru 5; **yayın engeli**): `Döngü Modu.mp3` kaynağı ve lisansı (AI ise araç lisansı, Steam beyanı); menüye ayrı parça?
3. **`assets/icons/`** (91 SVG; L4, soru 6; **yayın engeli**) kaynağı.
4. **Xbot küçük resimleri** (L5; **yayın engeli**): `assets/art/office/thumb_*.jpg` yeniden üretimi ACIK yeni maddesinde (§15.2).
5. **© satırı, roller, kurgu notu** (L8, soru 9): tüzel kişi; `credits.json` rolleri ve adlar; kurgu notu satırı ve Quaternius (CC0) satırı istenir mi?
6. **Oto yedek** (soru 3): koşu başına 3 kalsın mı; bitmiş ya da eski koşuların yedekleri hiç budanmasın mı?
7. **TEKRAR DENE** (`ending_scene.gd:19-20`): öneri süreç içi `_return_to_menu` + `_mount_flow`; cevaba kadar yeniden başlatma kalır.
8. **Rehberli başlangıç** (O11, soru 7; A2 buna bağlı): Frank'in `tutorial` kartları yazılacak mı; anahtar ilk koşuda açık mı, sonra hatırlanır mı?
9. (kapandı, H9) `--skip-onboarding` kalır; `--menu` bayrağı debug'da menüyü zorlar.
10. (kapandı, H10) Köken çipleri tarif cümlesi olur, bayrak sözü vermez; metin TR/EN onay bekliyor.
11. **Dönem** (O13, soru 8): İlk hafta belgesi ve perde "Hafta 1 · {ay} {yıl}" takvimden okur (bugün 2026), Rakip Dünyası 2012; hangisi kanon?
12. (kapandı, H11) Tuş atama ekranı ayrı task; bu PRD yalnız eksik kumanda düğmelerini InputMap'e ekler (§4.2).
13. (yönlendirildi, H13) S31, S35 → Onarım 1 grup F; S41 → Yazar v2; AM6 statik denetiminin `end_run`'a almadığı statikler A'ya not.
14. (kapandı, 2026-10-11) İstek listesi menüden düştü → ACIK (M8); D6 ve M7 ertelenmiş (§15.2).
15. (kapandı, 2026-10-11) Menü kalemi Jenerik / Credits (`MENU_CREDITS`); pencere Jenerik, alt sayfa Lisanslar.
16. **`godot_mcp_runtime`** (L7; release'de kapalı; **yayın engeli**): kaynağı ve lisansı, ya da yayın kopyasında autoload'u çıkaran export adımı.
17. **Hükümle kapananlar** (itiraz AM5/AM6 öncesi): soru 1 süreç içi dönüş (H2), soru 2 S1–S4 (H3), soru 3'ün Devam yarısı (H3); Steam ekran klavyesi yok.
18. (kapandı, 2026-10-11) Manşet satırı yok; meta'ya `headline` girmez.
19. **Menüden Masaüstüne çık onayı:** varsayılan onaysız (menüde koşu yok); istersen onaylı iki düğmeli onay, tek satır.
20. (kapandı, 2026-10-11) Slogan yok (H12): oyun sloganı hiçbir karede yok, şirket slogan alanı AM9a'da kalkar.
21. **Karizma sonuç satırı** (maket 03): "Yatırımcıyı ikna etmeye yetmez · büyük masa cezası yarıda"; metin TR/EN onay bekliyor.
22. **Dil (H14, öneri):** kapı yok; Steam dili, yoksa OS dili; `tr` → TR, başka her şey → EN; Ayarlar'da seçici. Gerekçe: tahmin çoğu oyuncuda
    doğru, yanlışsa tek Ayarlar satırı; Steam dili zaten sorar. Yedek: ilk açılışta kapı kalır (silme geri alınır, kapı Godot kartından sonra).
23. **Zorluk (H15):** çarpanlar 1,5 / 1,0 / 0,6 ($15.000 / $10.000 / $6.000); öbür kökenler açılınca çarpan mı sabit tutar mı; Zor = her son
    (iflas dahil, bugünkü varsayım) mı yalnız Series A mı; kasadan başka değiştirici; belgede runway birimi hafta (TopBar) mı, maketin ayı mı?
24. **Portreler:** 16 hücre (11 + 5 "Yeni portre") mi, 12 mi, yalnız 11 mi? Yeni portre sahip sanatıdır (`FOUNDER_LOOKS` satırı + render).
25. **Amblem paleti ve yeri:** 8 renk yeni token olarak; amblem koşu kromunda (TopBar, Finans) görünsün mü; eski dört stilin eşlemesi (§10.8).
26. **Godot kartı:** 1,5 sn ve atlanabilirlik; Jenerik'te tek renk işaret (renkli logo yalnız kartta).
27. **Sahne figürü** (§10.9): canlı ev + ayakta 3B kurucu (öneri) mi, plaka üstünde önceden render edilmiş portre mi?
28. **Menü zemini ve Devam zamanı:** plaka motorun akşamı (öneri) mi maketin pişirmesi mi; kayma istenir mi; "2 saat önce" mi tarih-saat mi?

## Erdem'in bakacakları

- Menü F5'te atlanır (Sahibe 9): `export_build.sh "Windows Demo"` exe'siyle ya da geçici boş `main_args` ile bak. Exe: Godot'un açılış logosu yok,
  logo kilidi, tuşla atlanan "Godot Engine ile yapıldı" kartı, renk sıçramasız geçiş, ikon; ilk açılış dili makinenin dili.
- Menü: akşam şehri kareyi dolduruyor, sütun solda; kayıt varken Devam kartı (amblem, ad, hafta, kasa, son oynanış; kurucu yok); yokken Devam ve
  Yükle yok; sol altta sürüm; ok tuşları, Enter; Düşük'te yalnız plaka. Yükle: şirket grupları, katlanan yedekler. Jenerik → Lisanslar düz metin.
- Oyunda Esc → Ana menüye dön ve X/Alt+F4: kaydedilmemişse soru (karar beklerken de); süreç içinde döner, EA koşusu EA kalır. F9: tost kuralları.
- Onboarding: evde ayakta duran kurucu yüz seçince değişiyor, 16 hücre, dolarak ilerleyen İlk hafta belgesi, zorluk (Zor kilitli), üç kartta sonuç
  satırı, Rastgele/Sıfırla, kilitli rehber, 12 amblem + Yeniden üret, iptal onayı, perdede amblem.

## Doğrulama listesi

- [ ] AM0–AM11 ayrı commit (AM9a ve AM9b ayrı), her birinde inceleme ajanının bulguları kapalı.
- [ ] `write_licenses.gd` 14 dosya; `GODOT_COPYRIGHT.txt` 4.6.2; AM1b: üç preset, exe'de `BUILD|…|scope=` doğru, `.pck`'te `docs/` yok.
- [ ] `git grep -n "res://icon.svg"` boş; `icon.svg` yalnız HARITA'da yeni yol; `set_restart_on_exit` (scripts/main), `_autosave_on_close\|SYS_SOON` (`system_menu_modal.gd`, `save_manager.gd`) boş.
- [ ] `git grep -n "LanguageGate\|language_gate\|force-language-gate" -- scripts scenes` boş (AM9a); `git grep -n "LOGO_STYLE\|ONB_SLOGAN" -- scripts localization` boş, `logo_style` yalnız `from_legacy` ve meta eşlemesinde (AM9b).
- [ ] `git grep -n "QUICK_SLOT_ID\b" scripts` yalnız koşu başına kimliği kuran yerde; `menu_state_machine` yeşil, falsifikasyonu iki kez düştü.
- [ ] `--menu-shot=all` TR/EN 1920/1536; `--onboard-shot=1..3` ve yeni durumlar; `--theme-audit=menu`, `onboard:1..3` temiz. `--modal-shot=settings|load|confirm|confirm3|confirm3_gate` değişmedi; `save|load|load_delete|save_overwrite` AM5'te yeniden çekildi. `--backdrop-probe` iki koşu; `plate_frame=1`; geçiş farkı ≤ 6/255; YENİ OYUN sonrası düğüm sayısı `--onboard-shot=1` ile eş.
- [ ] §6.4, §7, §9.4, §10.10 smoke listeleri yeşil; `run_gate.sh` 3/3 (AM6 sonrası bir kez); `^PROBE` baytları AM9a öncesiyle eş.
- [ ] TR metin taşıyan her commit mesajında "TR/EN onay bekliyor"; §13 sabitleri "onay bekliyor".

## Done mesajı

```
ANA MENÜ bitti · main'de AM0–AM11 (<hash listesi>), push yok.
✅/⚠️/❌ Açılış · splash ayarları · Godot kartı card_ms=<n> · ikon · v<sürüm> · LICENSES 14 dosya · GODOT_COPYRIGHT <motor sürümü> · AM1b exe (şablon yoksa ⚠️) · dil source=os lang=<l>, kapı silindi (AM9a)
✅/⚠️/❌ Jenerik/Lisanslar · LIC components=<n> licenses=<n> missing_glyphs=<n> · Ayarlar → Veri girişi
✅/⚠️/❌ Menü · odak sırası (paused=1, joy_ui=1) · Devam kartı · kabuksuz modallar · boot_to_menu_ms=<n>
✅/⚠️/❌ Arka plan (şehir) · plate_frame=1 · live_ms <ilk>/<ısınmış> · gpu p50/p95 <> · geçiş farkı <> · Düşük'te plaka
✅/⚠️/❌ Kayıt · run_id · koşu başına yuvalar · Yükle grupları · menu_state_machine (+ falsifikasyon iki FAIL) · statik denetim <n>
✅/⚠️/❌ Ana menüye dön süreç içi · EA korunur · ACIK 872 kapandı · çıkış onayları (X, Alt+F4, karar beklerken, menü) · F9 / kirli damga / tostlar · S54 üç artık
✅/⚠️/❌ Onboarding · Menajer portu · sahne figürü (canlı/plaka) · İlk hafta belgesi · zorluk + Zor kilidi · sonuç satırları · Rastgele/Sıfırla · rehber kilitli · iptal · curtain_ms <n> · amblem v2 (12 aday deterministik, eski logo_style eşlemesi)
❌ Yayın engeli: müzik · assets/icons · Xbot küçük resimleri · godot_mcp_runtime lisansı (Sahibe 2-4, 16)
Onay bekleyen: §12 metinleri · §13 sabitleri · Sahibe 1–28
```

## Öğretici notlar

- **Lisans uyumu ekran değil metin işidir.** Godot MIT metnin oyunda bir yerde durmasını ister ve motor onu kendisi verir; elle kopya bayatlar. OFL
  "her kopyada" bildirim ister; `.txt` dışa aktarıma ancak filtreyle girer. Godot logosu CC BY 4.0'dır: kullanılınca atıf borcu doğar.
- **Boot splash betikten önce çizilir;** oyun içinden yakalanamaz. Zemini ilk sahneninkine eşitlemek "flaş"ı kaldırır.
- **Duraklatılmış ağaçta yalnız ALWAYS yaşar** (`system_menu_modal.gd:7-10`): açılış `emit(0)` ile ağacı durdurur. **`run_active` "koşu yok" demek
  değildir;** menü kapıyı `end_run` ile kapatır ve hızı 0'a çeker (`TimeManager.reset` 1 yapar).
- **Durum eşitliği yalnız serileşen durumu kanıtlar;** serileşmeyen statik `^static var` denetimiyle bulunur; statik kayıt defteri sahneler arası
  sızar (önizleme `OfficePerson`'u `_people`'a girer). **Koşular arası bilgi profilde yaşar:** `DEFAULTS` dışı `Settings` anahtarı sıfırlamadan sağ çıkar.
- **`set_auto_accept_quit(false)` sonrası her dal `get_tree().quit()`'i kendisi çağırır.** İçeriksiz tutorial bayrağı havuzu susturur. **Ağaca
  eklenmemiş sahne örneği `_ready` koşturmaz:** `OfficeView.tscn`'den `World`'ü ayırmak ışığı ve kamerayı getirir, koşuyu değil.
