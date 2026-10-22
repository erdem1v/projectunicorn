# Test, harness ve araçlar

Dizi üretildiği git sha: `f3113fa4` (DIZIN.md başlığı, 2026-10-22). Satır numaraları diskteki (kirli ağaç) hâle göredir.

Ne yapar: Oyunun kendi içinde koşan (debug build) smoke süiti, oynanan-koşu probe'ları, ekran görüntüsü ve ölçüm bayrakları ile bunları sarıp geçti/kaldı kararı veren kabuk kapıları.
`main.gd` komut satırını okur, bayrağa göre harness'i kurar ve süreci kendi bitirir; kabuk betikleri (`tools/*.sh`) çıktıyı ayrıştırıp çıkış koduna çevirir. CI yoktur.

## Dosyalar

- `scripts/main/main.gd` (5165): ana sahne; debug bayrak dağıtıcısı (`_run_debug_harness`), tüm `--*-shot` ve ölçüm koşucuları, fikstür tohumlayıcıları
- `scripts/debug/endgame_smoke.gd` (25951): `EndgameSmoke`; 475 vakalı smoke süiti, tek süreç = tek vaka, `SMOKE PASS/FAIL` basar
- `scripts/debug/run_probe.gd` (2420): `RunProbe`; botun oynadığı koşu defteri (`--run-log`), 49 preset, `PROBE ...` satırları
- `scripts/debug/sprint_probe.gd` (425): `--sprint-probe`; Ürün ekranının sprint planını (`plan_outcome`) kapanışla karşılaştırır, uyuşmazlıkta 1
- `scripts/debug/tick_probe.gd` (133): `--tick-probe`; gerçek saatte kare maliyeti (gece, saat adımı, otomatik kayıt) `TICK` satırları
- `scripts/debug/office_crowd_probe.gd` (326): `OfficeCrowdProbe`; ofis kalabalığı sağlığı (`CROWD` satırları) ve ofis çekimlerinin yardımcıları
- `scripts/debug/office_pan_probe.gd` (398): `--pan*`; ofisin 3B görüntüsünü kamera ofsetlerinde kaydeder ve ölçer (`PAN*` satırları)
- `scripts/debug/product_fixtures.gd` (699): Ürün sekmesinin debug kaynağı (mockup c1..c5, kart galerisi, uç durumlar); `--product-shot` besler
- `scripts/debug/kit_probe.gd` (298): `--probe-shot=kit`; koyu kit bileşenlerini durumlarıyla bir pencere gövdesinde dizer
- `scripts/debug/loc_residue.gd` (265): `-s` betiği; Türkçe literal, CSV'de olmayan sahne metni, statikte `tr()` arar, vuruşta sıfır dışı çıkar
- `scripts/debug/glyph_audit.gd` (113): `-s` betiği; oyunun çizebileceği her karakteri yüz ve zincirlere sorar, eksiği `GLYPH|MISS` basar
- `scripts/debug/write_licenses.gd` (58): `-s` betiği; `export_build.sh`in çağırdığı, exe yanına `LICENSES/` yazar
- `scripts/events/tools/` (7 dosya, olay sistemi haritasında ayrıntılı): `EvProbe`, `EvLint`, `EvWhy`, `EvHarness`, `EvVocabGen`, `plausibility.gd`, `plausibility_main.gd`
- `tools/smoke_run.sh` (80): bir vakayı ya da `--all`ı koşar; motor hatası basan vakayı düşürür, `# EXPECT-ERROR` bağışını okur
- `tools/run_gate.sh` (51): oynanan üç koşu (`full_run`, `full_run_b2c`, `full_run_vc_cautious`) bir sonla ve sıfır hata satırıyla bitmeli
- `tools/gate_common.sh` (21): iki kapının ortak Godot bulucusu (`GODOT`), `ERR_TOKENS`, `engine_errors()`
- `tools/plausibility_run.sh` (110): makullük defteri kapısı; koşu başına ayrı süreç ve ayrı `APPDATA`/`HOME`, 40 koşu + `PLAUS LONG`
- `tools/export_build.sh` (13): bir export preset'ini dışa aktarır, sonra `write_licenses.gd`i koşar
- `tools/gen_signal_manifest.py` (226): `event_bus.gd` sinyallerinden ve emit/connect satırlarından `docs/EVENT_SIGNAL_MANIFEST.md` üretir
- `tools/lint_baseline.json`, `tools/lint_v3_frozen.json`: `EvLint`in kabul edilen bulgu tabanı ve v3 dondurma listesi (`lint.gd:36-37`)
- `tools/kod_haritasi/uret.py`: bu haritanın dizin üreticisi (DIZIN.md, SEMBOLLER.tsv, KALITE.md)
- `tools/people/` (`bake_portraits.gd`, `portrait_baker.gd`, `setup_import.gd`, `fix_rig.py`): ofis kişileri ve portre pişirme hattı; test değil, çevrim dışı araç
- `tools/office3d/` (`bake_nav.gd`, `check_export.py`, `run_export.sh`, `serve.py`, JS kaynağı): ofis 3B dışa aktarım hattı, `.gdignore` taşır
- `tools/brand/make_lockup.py`: `assets/brand/` lock-up ve ikon üretir
- `sandbox/asset_lab/` (`asset_lab.gd` 352, `lab_scene.gd` 487, `AssetLab.tscn`): paket asetleriyle kurulan ofisi oyunun kamerası, ışığı ve mürekkebiyle çeken deney sahnesi
  ↳ bayraklar sahne yolundan sonra, `--` ayracı olmadan: `--lab-shot=`, `--lab-ref=`, `--lab-desks=`, `--lab-loader=gltf`, `--lab-gate` (`asset_lab.gd:3-15`); `office_pan_probe.gd`'yi preload eder; oyun kodu değil
- `../.githooks/pre-commit` (git kökü, isteğe bağlı): ilgili yollar sahnelenince `--event-lint` ve `loc_residue` koşturur

## Giriş noktaları

- `Main._ready()` `scripts/main/main.gd:83`: debug build ise (`:95`) `_run_debug_harness()` (`:104`) bayrak bulursa menüyü atlar · motor, ana sahne
- `Main._run_debug_harness()` `scripts/main/main.gd:204`: sırayla `--endgame-smoke=`, `--run-log=`, çıplak bayraklar (`bare`), değerli bayraklar (`valued`) · `_ready`
- `Main._run_args()` `scripts/main/main.gd:175`: komut satırı + editörde `application/run/main_args` ayarı · smoke ve run-log bayrakları bunu da okur
- `Main._flag_value()` `scripts/main/main.gd:183`: `--bayrak=değer` değerini döndürür · tüm koşucular; `--shot-size=`, `--shot-scale=`, `--palette=`, `--pan=` da buradan
- `EndgameSmoke.run_case()` `scripts/debug/endgame_smoke.gd:51`: tohumu 424242'ye ve build kapsamını demoya sabitler, `match case_name` ile vakayı koşar · `main.gd:207`
- `RunProbe.run()` `scripts/debug/run_probe.gd:351`: `<preset>:<hafta>:<mod>[:<tohum>][:replay=|window=|build=]` ayrıştırır, `sim` ise `_run_sim()` (`:1115`) · `main.gd:218`
- `SprintProbe.run()` `scripts/debug/sprint_probe.gd:85`: `--sprint-probe` spec'ini koşar, `bool` döner · `main.gd:258` (`_quit_with`)
- `Main._run_tick_probe()` `scripts/main/main.gd:548`: kayıt dolu kullanıcı dizininde `TICK ERROR` basıp çıkar; `TICK_PROBE.new().run()` (`tick_probe.gd:24`)
- `Main._run_tempo_probe()` `scripts/main/main.gd:466`: haftayı 08:00'den 08:00'e gerçek saatle ölçer, `TEMPO_STOP_DAY` (`:458`, 3) tikinde durur
- `Main._run_render_probe()` `scripts/main/main.gd:389`: sayfa başına kare süresi ve `rebuild_view` ölçer; VSYNC kapatır; sabitler `:377-379`
- `Main._begin_shot()` `scripts/main/main.gd:590`: her çekimin ortak açılışı; pencereli mod, 1920x1080 ya da `--shot-size`, `--palette=cb`, `--shot-scale`
- `Main._seed_run_reproducible()` `scripts/main/main.gd:626`: tohum 424242, `IncidentSystem.rolls=false`; çekimlerin önce/sonra çiftini kıyaslanır yapar
- `Main._finish_shot()` `scripts/main/main.gd:665`: kareyi `user://<ad>[_en][_cb].png` yazar (`:659`) ya da `--theme-audit` ise `AUDIT_BEGIN/END` basar (`_audit_walk` `:3007`)
- `Main._run_why_fire()` `scripts/main/main.gd:288`: `EvWhy.report(kart)`; `_run_event_plausibility()` `:295` `PLAUSIBILITY.run(spec)`
- `Main._skip_to_shell()` `scripts/main/main.gd:5100`: menü ve onboarding'siz kabuk; `--skip-onboarding` (`:107`) ve debug F12 (`:5095`) çağırır
- `GameShell._debug_fkey()` `scripts/main/game_shell.gd:138`: debug build'de Shift+F4/F5/F6 (F4 onboarding'i yeniden tetikler)
- `GameShell.debug_product_apply/act` `scripts/main/game_shell.gd:175-186`: `PRODUCT_FIXTURES` (`:18`) yükleyip Ürün sekmesine `set_source` verir · `main.gd:3760,3784`
- `SaveManager._is_harness_arg()` `scripts/autoload/save_manager.gd:497`: `smoke`, `-shot`, `audit`, `probe`, `run-log`, `plausibility` alt dizili `--` bayrağı harness sayar
- `tools/smoke_run.sh run_one()` `tools/smoke_run.sh:38`: `godot --headless --endgame-smoke=<vaka>`; `list_cases()` (`:27`) vaka listesini `match` tablosundan awk ile çeker
- `tools/run_gate.sh` `tools/run_gate.sh:22-48`: her preset için `--run-log=<preset>:730:sim`; `PROBE END` sayısı, `ending=` ve hata satırı denetler
- `tools/plausibility_run.sh plaus_run()` `tools/plausibility_run.sh:42`: `-s plausibility_main.gd -- --event-plausibility-probe=...`; `PLAUS SUMMARY` okur

## Sinyaller

- `debug_onboarding_retrigger_requested`: yayan `scripts/main/game_shell.gd:144` (Shift+F4) · dinleyen `scripts/main/main.gd:103` -> `_on_debug_onboarding_retrigger` (`:5136`)
- `phase_gate_reached`, `run_ended`: smoke `run_case` her vakada kendi dinleyicisini bağlar (`endgame_smoke.gd:74-75`), `_gate_signals` ve `_endings` dizilerine biriktirir
- `phase_gate_reached`: `scripts/debug/run_probe.gd:490` da dinler (kapı geçişini defterine yazar)
- `night_skipped`, `hour_changed`, `day_advanced`: tempo, tick ve crowd probe'ları ölçüm için dinler (`main.gd:478`, `tick_probe.gd`, `office_crowd_probe.gd`)
- Smoke, 100'ü aşkın sinyali doğrudan `connect` eder (DIZIN.md Sinyaller bölümünde `connect: scripts/debug/endgame_smoke.gd:N` olarak görünür); yeni sinyal eklerken oraya bakın
- Harness'e özel yeni sinyal yoktur; `EventBus.speed_change_requested.emit(idx)` ve `tab_changed.emit(tab)` çekimlerin ve probe'ların tek sürücü yoludur (`main.gd:93`, `:576`)

## Durum ve veri

- `EndingsSystem.build_scope_override` `scripts/systems/endings_system.gd:374`: smoke `run_case` demoya sabitler; `--run-log`/`--sprint-probe` `build=ea|full` ile çevirir
- `IncidentSystem.rolls` `scripts/systems/incident_system.gd:51`: smoke ve çekimlerde `false` (rastgele acil durum yok); gerçek-saat probe modları da zar atmaz
- `MailClock.instant` `scripts/systems/mail_clock.gd:23`: smoke'ta `true` (üretilen şey anında gelir); teslim saati vakaları kendileri `false` yapar
- `SummarySystem.frequency_override` `scripts/systems/summary_system.gd:41`: smoke aylık özeti sabitler
- `SaveManager._autosave_enabled` `scripts/autoload/save_manager.gd:44`: harness bayrağı varsa `_ready`de kapanır (`:67-69`); `--tick-probe` kendisi açar
- `GameState.run_seed`: smoke ve çekimlerde 424242; `RunProbe` dördüncü spec parçasıyla tohumu değiştirir (`run_probe.gd:351+`)
- `RunProbe.PRESETS` `scripts/debug/run_probe.gd:188`: preset adı -> alan sözlüğü (`subtype`, `policy`, `vc`, `staff_cap`, `fix`, `desk`, `core_only`, `server`, `cash`, `accounts`, `staff`); 49 anahtar
- `RunProbe.SMALL_CREW` `run_probe.gd:248`, `GROWTH_ROLES` `:1538`, `seed_crew()` `:2380`: ekip tohumlama; `--sprint-probe team=` ve `--tick-probe team=` da kullanır
- Smoke paylaşılan kayıt yuvaları `manual_9001`/`manual_9002` (`endgame_smoke.gd:9895-9896`); vakalar paralel koşturulmaz
- `tools/lint_baseline.json` `tools/lint_v3_frozen.json`: kabul edilen lint bulguları; `--event-lint=baseline` yeniden yazar
- Çekim PNG'leri `%APPDATA%\Godot\app_userdata\Project Unicorn\` (`user://`); EN `_en`, renk körü `_cb` soneki (`main.gd:654`)
- `docs/EVENT_SIGNAL_MANIFEST.md`, `docs/content/events_draft/_vocabulary.md`: araçların ürettiği belgeler (`gen_signal_manifest.py`, `--event-vocab`)

## Metin anahtarları

- Harness çıktıları (`SMOKE`, `PROBE`, `TICK`, `TEMPO`, `CROWD`, `PAN`, `SPRINTPROBE` vb.) çevrilmez; `scripts/debug/` ve `scenes/debug/` `loc_residue` SKIP listesindedir (`loc_residue.gd:30-33`)
- `main.gd` `scripts/` altında olduğu için Türkçe literal taşıyan fikstür satırları `# LOC-DATA <gerekçe>` işaretini ister (main.gd'de 91 işaret var)
- `product_fixtures.gd` gerçek anahtarları `tr()` ile çözer (`PRODUCT_RESULT_*`, `PRODUCT_REVIEW_*`); metin o anki dilde, özel adlar düz kalır
- `loc_residue.gd` ve `loc_csv_integrity` vakası (`endgame_smoke.gd:316`, gövde `:10859`) `strings.csv` anahtarlarını okur; `glyph_audit.gd` CSV'nin iki dilini okur
- `--lang=tr|en` bayrağını `Localization` okur (`scripts/autoload/localization.gd:20-53`); çekim dosya adına `_en` ekler

## Testler

- Ortam: `export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/` içinden. `gate_common.sh` `GODOT` yoksa PATH'te ve Masaüstü'nde arar, yoksa çıkış 2.
- Bayrak `--` ayıracının ARKASINA konmaz (`smoke_run.sh:10`): `main.gd` `OS.get_cmdline_args()` okur, ayıraçtan sonrası ulaşmaz ve süreç oyunu açıp asılı kalır. İstisna: `-s` girişleri (`--event-plausibility-probe=`) kullanıcı argümanıdır.
- Smoke tek vaka: `bash tools/smoke_run.sh <vaka>`; hepsi: `bash tools/smoke_run.sh --all` (475 vaka, saatler sürer; yalnız push/entegrasyon öncesi). Çıkış 0 yeşil, 1 vaka düştü, 2 harness sorunu. `CASE_TIMEOUT` varsayılan 120 sn.
- Smoke karar kuralı (`smoke_run.sh:38-66`): satırlarda `^ERROR:|SCRIPT ERROR|Parse Error|Compile Error` varsa vaka düşer, `SMOKE PASS` yazsa da; hiç verdict yoksa ya da süre aşıldıysa düşer.
- `# EXPECT-ERROR <ileti parçası>` match kolunda kuralı bilerek bozan vakayı bağışlar; parça hiç basılmazsa "stale marker" ile düşer (örnek: `founder_5skill_init`, `endgame_smoke.gd:171`).
- Vaka ailesi önekleri (475 vaka): sales 34, event 33, sprint 25, hr 23, save 21, b2b 19, seed 14, paper 14, loc 14, promise 13, incident 10, product 9, cs 9; kalan 237 vaka daha küçük ailelerde (market, hotfix, angel, research ...).
- `all_scripts_load` (`endgame_smoke.gd:324,12310`) `scripts/` ve `scenes/` altındaki her `.gd`yi ayrık GDScript kopyasıyla derler; `addons/` kapsam dışı. `ResourceLoader.load` ve `reload()` motoru düşürür, kullanmayın.
- Oynanan koşu kapısı: `bash tools/run_gate.sh` (3 preset x 730 hafta, `RUN_TIMEOUT` 900). Tek koşu: `"$GODOT" --headless --path . --run-log=full_run:730:sim[:seed][:window=11-13][:build=ea|full]`.
- `RunProbe` yalnız defter basar, her zaman 0 çıkar; `^PROBE` satırları aynı tohum, binary ve `--lang=tr` ile bayt-deterministiktir. Hata `PROBE ERROR`dır. Gerçek saat modları `1|2|3`.
- Sprint planı: `--sprint-probe=hours=<h>:cards=<1|2>:ticks=<t>[:team=][:market=][:fixture=][:build=][:planms=1]`; `SPRINTPROBE PRED/CLOSE/SKIP/MVP/LOAD/SUMMARY/PAPER/PLANMS`; adsız uyuşmazlıkta 1.
- Ölçüm: `--tempo-probe=<hız>[:shell]` (`TEMPO`), `--tick-probe=<hız>[:<pencere>][:accounts=][:team=]` (`TICK`, ayrı `APPDATA` ister), `--render-probe[=<sekme>:...]`, `--office-crowd-probe=<ofis>:<kişi>:<hız>`.
- Çekim ailesi (pencereli, `valued` tablosu `main.gd:242-276`): `--tab-shot`, `--modal-shot`, `--onboard-shot`, `--office-shot=<ofis>:<saat>[:ek]`, `--event-shot`, `--ending-shot`,
  `--vc-shot`, `--sales-shot`, `--negotiation-shot`, `--meeting-shot`,
  `--invite-shot`, `--product-shot`, `--hr-shot`, `--finance-shot`, `--personal-shot`, `--rnd-shot`, `--b2b-shot`, `--inbox-shot`, `--menu-shot`, `--travel-shot`, `--clock-shot`, `--day-shot`, `--probe-shot[=menajer|kit]`.
- Çıplak bayraklar (`bare` tablosu `main.gd:225-236`): `--event-probe`, `--event-lint`, `--event-vocab`, `--render-probe`, `--sales-shot`, `--probe-shot`, `--display-check`, `--backdrop-probe`, `--theme-contrast-audit`.
- Motor araçları: `--event-lint[=baseline]`, `--why-fire=<kart>`, `--event-harness=random:seeds=N:weeks=M|guided`, `--event-plausibility=<spec>`;
  makullük kapısı `bash tools/plausibility_run.sh` (`SEEDS`, `WEEKS`, `JOBS`, `LONG_SEEDS` ortam değişkenleri).
- Doğrulama sırası (CLAUDE.md §12): `--event-lint` -> `-s res://scripts/debug/loc_residue.gd` -> `smoke_run.sh loc_csv_integrity` -> hedefli smoke; tam süit yalnız entegrasyonda.
- Yeni görsel yüzey: önce `--<yüzey>-shot`, sonra `--theme-audit=<sekme|modal:<tür>|onboard:<adım>>` ile çözülmüş tema değerleri (kare yok, `AUDIT_BEGIN/END` satırları).

## Dikkat

- `--` ayıracı tuzağı: harness bayrağını ayıraçtan sonra yazarsanız `main.gd` görmez, oyun açılır ve süreç asılı kalır (`smoke_run.sh:10`).
- Throwing case geçer görünür: GDScript'te try/catch yok, çalışma hatası gövdeyi keser ve `""` döner; bu yüzden hata yakalama kabuktadır (`smoke_run.sh:4-9`). Smoke'u `SMOKE PASS` satırına bakarak değil `smoke_run.sh` ile koşun.
- `--endgame-smoke` süreci MCP editör yolunda canlı bırakır (log okunsun diye); CLI'da `get_tree().quit()` çağrılır (`main.gd:205-212`). Harness bayrakları yalnız debug build'de çalışır.
- `SaveManager._is_harness_arg` alt dizi eşleşmesidir: bayrak adı `smoke/-shot/audit/probe/run-log/plausibility` içeriyorsa otomatik kayıt, ekran ayarı ve `runs_finished` sayacı kapanır
  (`main.gd:4995`, `display_settings.gd:88`).
  `--display-check` bilerek hiçbirini içermez, gerçek pencereyi sürmesi gerekir.
- Kayıt yazan harness'ler: `--tick-probe` (`auto_*` yuvaları, kayıt varsa reddeder), `--modal-shot=save*|load*` (`_saves_refused` `main.gd:2671`), `--menu-shot` (`user://shot_menu/`),
  `--display-check` (`settings.json`). Hepsini ayrı `APPDATA` ile koşun.
- Smoke'un paylaşılan yuvaları `manual_9001/9002`: bu yuvaya yazan vakalar paralel koşulursa birbirini bozar; `--all` sırayla koşar, elle paralel koşuda koruma yoktur (HARITA, Araçlar).
- `--import` sonrası sınıf önbelleği tuzağı: sıra import -> ısınma koşusu -> kapı. Bayat `.ctex` yeni sanatı gizler (hafıza: godot-import-cache-gotchas). `plausibility.gd` bu yüzden yoldan yüklenir, `--import` istemez.
- `RunProbe` tek süreçte statik durum biriktirir (`run_probe.gd:302-330`); bir süreçte yalnız bir koşu. Makullük kapısı bu yüzden koşu başına ayrı süreç ve ayrı `APPDATA`/`HOME` açar.
- `full_run*` botu kuralları ve politikaları PRESETS alanlarıdır; bot politikasını değiştirmek ölçülen ekonomiyi değiştirir. Eski ve yeni `PROBE` defterini karşılaştırırken tohum, build ve `--lang=tr` aynı olmalı.
- Görsel çekim headless'ta no-op olur; `_begin_shot` pencere moduna geçer (varsayılan kenarlıksız mod boyut atamasını yutar). Çekim kare yazmadan önce `settle` (0.4 sn) bekler; `--shot-scale` 0.15 sn sonra uygulanır.
- Tam smoke bellek baskısı altında yarıda kalabilir (Faz A raporu); arka plan kabuğu biçilirse Godot alt ağacı yetim kalır (hafıza: bg-shell-memory-reap). Erdem 2026-10-06: "push et" = doğrudan push, öncesinde tam smoke yok.
- Paylaşılan ağaçta ikinci oturum yazabilir: harness koşusu `user://`ı ve ağacı paylaşır; sahipsiz değişikliği commit etmeyin, `git checkout -- <yol>` kullanmayın (hafıza: shared-tree-revert-rule).
- `endgame_smoke.gd` 25951 satırdır; okurken `grep -n "_case_<ad>"` ile gidin, tam dosyayı okumayın. `SEMBOLLER.tsv` vaka fonksiyonlarını (`_case_*`) listeler.
- `.githooks/pre-commit` yalnız lint ve `loc_residue` koşar, `git config core.hooksPath .githooks` ile elle açılır; smoke'u commit kancasına koymayın (kanca yorumu bunu zaten söyler).

## Bir değişiklik yaparken

- Yeni smoke vakası: `endgame_smoke.gd` `match case_name` tablosuna kol ekle (`:78-587`), `_case_<ad>() -> String` yaz (boş = geçti); `smoke_run.sh` listeyi tablodan okur, ayrıca kayıt gerekmez. Yeni vakayı önce bozup düştüğünü gösterin.
- Kuralı bilerek bozan vaka eklersen kola `# EXPECT-ERROR <ileti parçası>` yaz; parça basılmazsa vaka "stale marker" ile düşer.
- Yeni harness bayrağı: `main.gd` `bare` ya da `valued` tablosuna ekle (`:225-276`), `_run_*` koşucusunu yaz, adı `_is_harness_arg` alt dizilerinden birini içersin
  (yoksa otomatik kayıt açık kalır); CLAUDE.md §12 ve HARITA Araçlar'ı güncelle.
- Yeni `PROBE` kaydı ya da preset: `run_probe.gd` başlık yorumundaki çıktı sözleşmesini (`:25-101`) ve `PRESETS`i (`:188`) güncelle; `run_gate.sh` `PRESETS` dizisi ve `PROBE END` ayrıştırması (`run_gate.sh:19,30`) bozulmasın.
- Motor hata belirteci değişirse (`ERR_TOKENS`) yalnız `tools/gate_common.sh:9` değişir; `smoke_run.sh`, `run_gate.sh` ve `plausibility_run.sh` aynı süzgeci kullanır.
- Yeni `EventBus` sinyali ya da emit/connect: `python tools/gen_signal_manifest.py` ile `docs/EVENT_SIGNAL_MANIFEST.md`yi yenile; kod haritası için `python -I tools/kod_haritasi/uret.py`.
- `RunProbe` ya da `OfficeCrowdProbe` yardımcısını (`seed_crew`, `seed_staff`) yeniden adlandırırsan `main.gd`, `sprint_probe.gd` çağrılarını da tara; smoke özel fonksiyonları doğrudan çağırır.
- Sahne düğümü ya da metin anahtarı adı değişirse smoke vakaları ve çekimler düğümü adıyla bulur (`find_child`, `get_node`); `endgame_smoke.gd` ve `main.gd`'de ara, sonra `loc_csv_integrity` ve `all_scripts_load` koştur.
- Yeni kayıt şeması ya da yuva: `manual_9001/9002` kullanan kayıt vakalarını (`save_*`, `legacy_v12_*`) ve `--tick-probe`un `list_slots().is_empty()` korumasını gözden geçir.

## HARITA'da bayat

- HARITA Araçlar bölümünde (`docs/HARITA.md:380-392`) bu sistemle ilgili kodda bulunmayan ad ya da bayrak bulunamadı: preset, kayıt türü, bayrak ve fonksiyon adları kodla eşleşti.
- Eksik, bayat değil: HARITA `tools/` satırı (`:390`) `plausibility_run.sh` ve `lint_v3_frozen.json`u saymaz; `plausibility_run.sh` yalnız olay araçları satırında (`:389`) geçer.
- `.githooks/pre-commit` yorumu "278-case smoke suite ... takes hours" der; süit bugün 475 vakadır (HARITA dışı, aynı alan).
