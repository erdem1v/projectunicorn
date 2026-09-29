# Project Unicorn — ajan giriş noktası
Bu dosya bugün geçerli kuralları ve gerçekleri taşır. Kod haritası: `docs/HARITA.md`.

## 1. Oyun bugün
Oyuncu bir teknoloji girişimi kurar ve onu Series A'ya taşımaya çalışır; oyun Türkçe ve İngilizce oynanır. Koşu
tek yönlü üç evreden geçer: Bootstrap → Traction → Series A Hunt. Her evre runway'i yeniden daraltır; hiçbir evrede
yetkin bir oyun "kasa artıyor, karar kalmadı" noktasına varmamalıdır. İki pazar farklı oynanır: B2B (hesaplar,
sözleşmeler) ve B2C (kitle, ağızdan ağıza). Fon merdiveni: kurucunun birikimi → Frank'in MRR eşiğinde gelen tek
çeki (tur değil, tek karar) → dört VC'den biriyle term sheet'li seed → aynı dört VC ile Series A. Series A imzası
zaferdir. Kasa eksiye düşünce 4 haftalık [WORKING] kepenk sayacı başlar; sıfıra inerse şirket iflas eder. Yumuşak
tavan 104 oyun haftasıdır ([WORKING], yaklaşık 24 ay). Demo Bootstrap'tan Series A kararının sonuçlanmasına kadar
sürer, 60 ile 90 dakika [WORKING] hedefler. Sonların tam kümesi, koşulları ve demo/EA/full farkı GDD ile kodda
ayrışıyor: `docs/ACIK_ISLER/ACIK_KARARLAR.md`.

## 2. Tasarım otoritesi
- Otorite `GDDs/`'dir: v2 bölümleri (ch01–14), modül GDD'leri (Ürün ch03 dosyasındadır; Ekip, Ar-Ge, Satış) ve
  olay motoru için `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`, zaman modeli için `GDDs/GDD — ZAMAN MODELİ.md`.
  Hangi dosyanın yürürlükte olduğu `GDDs/README.md`'de.
- GDD ile `GDDs/GUNCELLEMELER.md` çelişirse ek belge geçerlidir.
- Motor md'si makineyi, ch11 olay içeriğini yönetir; eşittirler. Kod md'den ayrılırsa ayrılık md'nin §27'sine yazılır.
- Bir GDD ötekini açıkça geçersiz kılabilir: ch09 → ch01 §4; Ekip → ch02 §2/§6/§10, ch01 §5, ch06 §1.2, ch12 §8.
- GDD sessiz, belirsiz ya da açıkça çözülmemiş biçimde çelişkiliyse **dur ve sor**. Mekanik, içerik, mimari icat edilmez.
- [ÇALIŞMA] / [WORKING] / [K] işaretli sayı kalibrasyon girdisidir; kodda tek bir ayar sabitinde durur.
- GDD'de adı ya da kuralı geçen ama henüz bağlı olmayan kod ve içerik, bağlı değil diye silinmez.
- GDD ile kod ya da sahip kararı arasındaki bilinen ayrılıklar `docs/ACIK_ISLER/ACIK_KARARLAR.md`'dedir; burada anlatılmaz.

## 3. Çalışma kuralları
- İş doğrudan `main`'e commit'lenir; dal, worktree, rebase yok. Gerekli görünürse dur ve sor. Push yalnız Erdem
  "push et" dediğinde yapılır; "geri al" revert demektir. Bir kapı, onu iddia eden commit'ten önce yeşildir.
- Tasarım sabiti (ayar değeri, eşik, isteklilik (E) modeli sabitleri, kapı ya da toplantı ağırlığı) değişikliği raporda
  **"onay bekliyor"** altında listelenir. Önce tasarım notu yazılır; uygulama, test emekliye ayırmak dahil, onaydan sonra.
- Kalibrasyonda ölç ve raporla, sabit değiştirme. Harness ya da bot değişikliği serbesttir, ayrı raporlanır.
- `docs/ACIK_ISLER/ACIK_KARARLAR.md`'deki açık maddelere dokunulmaz; onaylananlar tek tek uygulanır.
- TR metni onaysız değişmez; onay bekleyen metin commit mesajında "TR/EN onay bekliyor" diye işaretlenir. Frank'in
  külliyatı Erdem'indir: yeni Frank satırı yalnız taslaktır, onaysız ekrana çıkmaz.
- Rapor: madde madde ✅ / ⚠️ / ❌ + kanıt (dosya:satır, commit, test adı). Tahmin yazılmaz.
- Godot MCP eklentisi ve git kökündeki `.mcp.json` kalır. `addons/` üçüncü taraf koddur, dokunulmaz.

## 4. Verimlilik
Hızlı ve doğru çalış. Süreyi uzatan ya da token harcayan gereksiz işlem yapma: ihtiyacın olmayan dosyayı okuma,
gerekmeyen testi koşma, aynı şeyi iki kez doğrulama. Bir şeyi bulmak için önce `docs/HARITA.md`.

## 5. Oyuncuya görünen metin
- **BILINGUAL BIRTH LAW.** Oyuncuya görünen her metin bir anahtar olarak doğar. Anahtarlar
  `localization/strings.csv`'de (`keys,tr,en`); `Localization` autoload'u CSV'yi açılışta okur.
- **Önce İngilizce.** Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil,
  sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır.
- Script ve sahnede oyuncuya görünen literal yazılmaz; sahne metni anahtarın kendisidir. Birleşik metin
  `tr(KEY).format({ad})`: yalnız adlı yer tutucu, `%s`/`%d` yok, araya giren değer ek almaz (`Sözleşme: {company}`
  olur, `{company}'nin sözleşmesi` olmaz), CSV değerinde çıplak süslü parantez yok. Durumda metin değil id saklanır.
  Özel adlar çevrilmez. `static func` içindeki `tr()` derlenir ama çalışırken ölür.
- **LANGUAGE INTEGRITY LAW.** `docs/design/localization_glossary.md` bağlayıcıdır. TR metinde İngilizce yalnız izinli
  ödünç kelimelerde kalır: pitch, startup, demo, momentum, MRR, runway, churn, burn, laptop, mail, VC ve özel adlar.
  Tek metinde dil karışmaz. Oyuncuya görünen hiçbir metinde tire (— –) yoktur (ch01 §9).
- Motorun bilmediği etki ya da koşul taslakta `[VOCAB?]` / `[COND?]` kalır ve kart bağlanmaz (ch11 §3). Oyuncu
  metnini kimin yazdığı açık karardır (`docs/ACIK_ISLER/ACIK_KARARLAR.md`).
- Kartlar `text.tr` ve `text.en` bloklarını aynı id kümesiyle taşır. Her seçenek gerçek bir kaynağa mal olur ve
  sonucu arayüzde görünür bir yere düşer; bedelsiz seçenek yalnız açık bir "beat"tir. Metin gözlemler, hüküm vermez;
  hüküm yalnız Frank'in ağzındadır (ch11 §7). Kilitli seçenek gerekçesiyle görünür; gerekçe kendi bilgeliğini söylemez
  ("Fiyatlarını zaten iki kez indirdin", "Bu hesabı fiyat değil ürün tutar" değil). Gerçek marka, UI talimatı, sekme
  ya da düğüm adı yok. Gün sınırında ateşlenen kart saat yazmaz. Seçeneğin anlattığını modifier'ları yapar.
- **EFFECT-VISIBILITY RULE.** Modifier oyuncuya okunur etiketle gösterilir, iç kodla değil. Etki çipini kuran tek yer
  `event_modal._describe_modifier`; bilinçli etiketsiz fiiller `SILENT_VERBS`'te, `event_chip_coverage` smoke'u zorlar.

## 6. Mimari
- Godot 4.6 (Forward Plus), yalnız GDScript. Ana sahne `scenes/main/Main.tscn`; `main.gd` açılışı, modal montajını
  ve debug bayraklarını taşır. Merkez görünüm `scenes/office/OfficeView.tscn`'dir (SubViewport'ta 3B ofis); sekmeler
  üstünde `WindowLayer` pencereleridir. Tasarım tabanı 1920×1080; `DisplaySettings.BASE_VIEWPORT` bunu elle yansıtır.
- Autoload'lar (`project.godot` sırası): EventBus, GameState, CharacterRegistry, CustomerRegistry, ProspectRegistry,
  PromiseRegistry, RivalRegistry, InvestorRegistry, TimeManager, SaveManager, Settings, Localization, AudioManager;
  sonra `MCPRuntime` (`addons/godot_mcp_runtime`, MCP köprüsü).
- `scripts/systems/` statik `RefCounted` sınıflardır; TimeManager saatlik ve günlük tiki dağıtır, EventBus sinyal
  merkezidir.
- **Zaman.** Bir oyun günü (tik) bir haftadır; hafta sonu yoktur. `GameState.day`, sistemlerin `daily_tick`'i ve
  `EventBus.day_advanced` adlarını korur ve tik sayar; her tik 24 saatlik tik ve bir günlük tik taşır. Zaman
  sabitlerinin ve birim dönüştürücülerinin tek evi `TimeModel`'dir: süre hafta verisidir ve `TimeModel.ticks()` ile
  okunur, `*_PER_DAY` oranları gün verisi kalır ve tikte `TimeModel.per_tick()` ile ×7 uygulanır. Hız merdiveni
  `TimeModel.SECONDS_PER_HOUR = [0.0, 10.0, 5.0, 10.0 / 3.0, 2.5]` saniye / oyun saati: duraklat / 1× / 2× / 3× / 4×
  [WORKING]. Hafta 08:00'de başlar; varsayılan mesaide (09:00'dan 17:00'ye) hafta 1×'te 90, 4×'te 22,5 saniye sürer.
  Mesai bitip ofis boşalınca gecenin saatleri tek toplu adımda koşar (`TimeManager.skip_night`); saati dışarıdan
  ileri taşıyan öbür kapı `TimeManager.advance_hours(n)`'dir (toplantı kapanışı, smoke, probe).
- Ay kapanışı sessizdir: günlük dağıtımın 0. yuvasında ay defteri kapanır ve `EventBus.month_ended` yayılır; haber
  şeridine 10. yuvada tek satır düşer; modal açılmaz. Özet modalı oyuncunun seçtiği sıklıkta gelir (`summary_frequency`:
  haftalık, aylık, çeyreklik ya da yıllık; varsayılan çeyreklik; `SummarySystem`, `EventBus.summary_ready`).
- **WRITE-THROUGH LAW.** Hiçbir olay, modal ya da UI başka bir alanın durumunu doğrudan yazmaz; değişiklik durumun
  sahibinin seam'inden geçer ve UI'nin dinlediği yerde seam sinyal yayar. Seam yoksa kurulur, alan "bir kereliğine"
  yazılmaz. Seam'ler: müşteri → `CustomerRegistry.set_mrr / set_seats / set_satisfaction / add / remove` (yayar);
  toplam MRR yalnız `SalesSystem.reflect_mrr()`; kasa, burn, marka, itibar → `GameState.set_*`; faz →
  `GameState.advance_phase()` (`set_phase` yalnız kayıt ve debug içindir); karakter → `CharacterRegistry.*`; ürün ve
  build → `ProductSystem.*`; tek seferlik gider → `FinanceSystem.apply_one_time_cost`. `GameState.flags` sistem
  durumudur: içerik ona sahibin adlı fiiliyle yazar (tek kapı `set_game_flag` beyaz listesi); motorun kendi hafızası
  `EvFlags`'tadır.
- Olay motoru autoload değil; tek girişi statik `EventGate.request(event_id: String, context: Dictionary = {})`.
  Sistem kartın adını verir, kartı kurmaz. Kartlar `data/events/cards/<kategori>/` altında JSON'dur ve
  `version_scope` ile `EvTuning.SHIPPED_SCOPES`'a göre süzülür (`_fixtures/` yalnız test içindir); arklar
  `data/events/arcs/`'ta. İçerik durumu yalnız `scripts/events/seams/`'ten okur. Invariant'lar: motor GDD §0.3.
- Gelir: B2B hesabı kurucunun oynadığı satış toplantısı ve pazarlıkla ya da atanmış temsilcinin işlediği lead'le
  kazanılır. B2C'de kitle her oyun saatinde iki yönlü değişir; MRR ödeyen kullanıcı × fiyat olarak saatlik türetilir.
- Kayıt: JSON; `SaveManager.SCHEMA_VERSION` 14, `MIN_LOADABLE_VERSION` 10. `SaveCodec` GameState değişkenlerini ve
  modellerin `@export` alanlarını kendisi bulur; eski kayıtta varsayılan göç yerine geçtiği için yeni alan anlamlı
  varsayılan taşır. Statik durum tutan sistem `SaveManager.reset_all_owners`'a girer. RNG tohumludur (`RngStreams`).

## 7. UI ve tema — UI/STYLE LAW
1. **Sözlük `UiTokens`'ındır.** Her renk palet tablosunda adlıdır; her boyut merdivendendir (`SIZE_MICRO 9 · META 10
   · SMALL 11 · DATA 12 · BODY 13 · LEAD 15 · TITLE 16 · DISPLAY 22`; editorial `SIZE_ED_* 24 · 26 · 32 · 44 · 52`).
   Ham `Color(...)` ya da ham boyut yazılmaz; duruma bağlı stil helper'dan okunur (`delta_color`, `badge_palette`, …).
2. **`themes/master_theme.tres` üretilmiştir.** Üretici `"$GODOT" --headless --path . -s
   res://scripts/theme/build_theme.gd` (temiz checkout önce `--import`). Token ya da `build_theme.gd` değişikliği
   aynı commit'te `UiTokens.THEME_STAMP`'i artırır ve temayı yeniden üretir; debug açılışı bayat damgada uyarır.
3. **Token'ı tema öğesine çeviren tek dosya `build_theme.gd`'dir.** Skala boyutun, varyasyon yüz ve rengin sahibidir.
4. **Sahne ve script yalnız yerleşimin sahibidir** (anchor, separation, margin, min-size); boyut, renk, stylebox
   taşımaz, `theme_type_variation`'a uzanır ya da yenisini ekler. Mevcut literal, çevresi değişince taşınır.
- Görsel dil: mono yazı, hairline çizgi, amber vurgu; hover dolgu değil kenardır (`ACCENT_DEEP`, kartta `BORDER_HOVER`).
  Gövde krem kâğıttır (sayfa `#F6F1E6`, kart ve pencere `#FBF7EE`, `INK` `#2B2722`); çerçeve koyudur (`#07090B`:
  TopBar, NewsTicker, MonthSummary bandı) ve `CREAM*`, `*_CHROME`, `*_BRIGHT` okur; sinematik koyu register
  (`DIALOGUE_*`) de `CREAM*` ve `VEIL_*_CHROME`. Tek ada gazetedir (`PaperPanel`, kendi `PAPER_*` merdiveni). 3B
  ofisin renkleri UI token'ı değil sahne verisidir: `OfficeConstants`, `scripts/ui/office/`, `scenes/office/shaders/`.
- **Chrome kuralı.** `Chrome*` (koyu kabuk ailesi) yalnız TopBar, MonthSummary, NewsTicker ve Ürün sayfasının Frank
  şeridinde (`ChromeButton`) kullanılır. Satış sekmesinin `ChromeTabButton`'ı açık karardır
  (`docs/ACIK_ISLER/ACIK_KARARLAR.md`); yeni yüzey eklemek ayrı karardır.

## 8. Kod yazımı
Kod tabanı şiştiği için her iş pahalılaştı; yeni kod aynı hataları tekrarlamaz.
- Kısa ve doğrudan yaz. Tek yerde kullanılan sarmalayıcı ya da yardımcı, tek gerçeklemeli "genel" yapı, okunurluk
  kazandırmayan ara değişken yazılmaz. Uzun if/elif zinciri yerine `match` ya da sözlük.
- Aynı işi yapan ikinci fonksiyon yazılmaz: önce var olan evi ara (`Fmt`, `UiFactory`, `HRUiShared`, `UiTokens`,
  `ProductSystem.live_bug_count`, `SalesConstants.mix` …). Kopyala-yapıştır blok yok.
- İmkânsız durum için savunma kontrolü yazılmaz; null ve sınır kontrolü yalnız gerçekten gelebilen değer içindir.
- Yerini alan kod eskisini aynı commit'te siler. Ölü fonksiyon, sabit, alan, sinyal, CSV anahtarı, asset, smoke vakası
  bırakılmaz; yoruma alınmış kod ve debug `print` commit'lenmez.
- Yorum yalnız bugünkü NEDENİ söyler. Tarihçe ("eskiden", "emekli", tarihler), görev ve karar etiketleri, satır
  numarası, ağaçta olmayan belgeye atıf, kodu tekrar eden yorum yazılmaz; tarihçe git'tedir. JSON `_` notları da öyle.
- İş bittiğinde rapor, plan ya da ölçüm dosyası repoya konmaz.

## 9. Kod review
Her commit'ten önce diff, ayrı bir agent tarafından kıdemli bir mühendis gözüyle incelenir; yalnız diff okunur. Soru:
bu kod en kısa ve en açık doğru hâlinde mi?
- İki satırda yazılabilecek şey on satırda mı yazılmış?
- HARITA'daki mevcut bir yardımcı yeniden mi yazılmış?
- İleride lazım olur diye eklenmiş soyutlama, parametre ya da dal var mı?
- Olamayacak durumlar için savunma, tarihçe anlatan ya da kodu tekrar eden yorum var mı?

Bulgular düzeltilir, sonra commit. Neden: şişen kod bir sonraki task'ın keşfini yavaşlatır ve pahalılaştırır.

## 10. Test
Mevcut smoke ve probe paketi eski ve gereğinden büyük; yalın bir paketle değiştirilecek (ayrı bir task). O zamana kadar:
- Her commit'te yalnız dokunulan sistemin ilgili vakalarını koş; tam paketi yalnız push öncesi.
- Yeni smoke vakası yalnız çekirdek mantık için (ekonomi, kayıt, olay motoru) ve ancak gerçekten gerekiyorsa. Arayüz
  doğrulaması smoke'la değil, görsel kabulle yapılır.

## 11. Görsel kabul
Oyuncunun gördüğü bir şeyi ekleyen ya da değiştiren her task, commit'ten önce oyunda görsel olarak doğrulanır (Godot
MCP). UI'a dokunmayan mantık değişiklikleri hariç.
- Task'taki kabul senaryosunu oyna; yoksa değiştirdiğin ekran için kısa bir senaryo yaz ve rapora koy.
- Ekrana fikstürle gel, oyunu baştan oynama.
- Kontrol: öğe yerinde mi, metin taşıyor ya da kesiliyor mu, doğru dilde mi, logda hata var mı. Rapora ekran
  görüntüleriyle koy.
- En fazla 2 düzeltme turu; sonra sorunu ekran görüntüsüyle raporla, commit etme.

## 12. Kapılar ve araçlar
`export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/`'dan. CI yok.
- **Sıra:** `"$GODOT" --headless --path . --event-lint` (kabul edilen bulgu gerekçesiyle `tools/lint_baseline.json`'a;
  onu `--event-lint=baseline` yazar, doğrulamada koşulmaz)
  → `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` → `bash tools/smoke_run.sh loc_csv_integrity`
  → hedefli smoke (`smoke_run.sh <vaka>`, önekler HARITA'da); tam smoke (`--all`) yalnız push öncesi.
- Motor: `--event-probe`, `--why-fire=<kart id>`, `--event-harness=random:seeds=N:weeks=M | guided[:seeds=N:weeks=M]`,
  `--event-vocab` (`_vocabulary.md`'yi üretir, KEEP bloğu kalır); `python tools/gen_signal_manifest.py`.
- Probe: `--run-log=<preset>:<hafta>:sim[:<seed>]`, preset'ler `RunProbe.PRESETS`'te. Karar değil defter basar;
  `^PROBE` satırları aynı seed, aynı binary ve `--lang=tr` ile bayt-deterministiktir.
- Tempo: `--tempo-probe=<hız>[:shell]` gerçek saatle koşar, her haftayı 08:00'den 08:00'e ölçer ve
  `TimeModel.seconds_per_tick` hedefinden sapmayı basar. Çıplak hâli headless'tır ve yalnız saati ölçer; `:shell`
  pencerelidir, kabuğu ve ofisi kurar, gece çıkış kapısının maliyetini de ölçer.
- Smoke ve probe demo yapısına sabitlidir; EA akışı editörde Main Run Args'a `--build=ea` yazılarak oynanır.
- Görsel kontrol (pencereli): `--<yüzey>-shot=<tür>` ailesi (tab, modal, onboard, office, event, ending, vc, sales,
  negotiation, meeting, product, hr, finance, b2b), `--probe-shot`, `--theme-audit=<sekme>`, `--shot-size=GxY`,
  `--lang=tr|en` (kayıtlı dili ezer). PNG'ler `%APPDATA%\Godot\app_userdata\Project Unicorn\`'a iner; EN `_en` alır.
  Ofis: `--office-shot=<home|ishani|plaza|loft|city|meet>:<saat>[:<ek>]`, ek `full|card|<sekme>|hr_dossier|crowd40|
  founders|nav|crown|cast` (`crowd40` kırk kişilik kadro, `LOOKS` satırı ve dört yakın kare; `founders` portre ile
  bust yan yana; `nav` fırınlanmış zemin; `meet` toplantı odası, `cast` bakış, duruş ve jest dizisi;
  `city:<saat>:crown` kulenin tacı). Görüşme paneli: `--meeting-shot=<tür>` (satış `probe|locked|won|lost|handoff`,
  VC `open|sorgu|sheet|callback|ret|seed|long`), `--negotiation-shot=<open|countered|insult|confirm>`; en dar dok
  `--shot-scale=1.25`. Kişilerin bir günü gerçek saatle: `--office-crowd-probe=<ofis>:<kişi>:<hız>` (sıçrama,
  duraklatmada kıpırtı, takılma, çakışma, kapı ve kesme, kuyruk, toplantı, gece kapısı; `CROWD` satırları ve
  `crowd_<ofis>_<kişi>_<hız>_NN.png`). Kurucunun toplantı yolculuğu: `--travel-shot=<home|ishani|plaza|loft>[:vc]`
  (10:00'da satış toplantısına, `:vc` ile Series A görüşmesine davet, gidiş, panel ve dönüş;
  `travel_shot_<ofis>[_vc]_NN.png` dizisi). Bir hafta gerçek
  saatle: `--day-shot=<ofis>:<hız>` (08:00'den çıkış ve gece atlamasıyla ertesi 08:00'e,
  `day_shot_<ofis>_<hız>_NN.png` ve kare başına `DAYSHOT` satırı).
- **Ekran kartı.** Ekranlı Godot koşuları (shot, tema denetimi, görsel kabul) paralel değil sırayla koşar; ekran
  gerektirmeyen her koşu `--headless`.
- Git kökündeki `.githooks/pre-commit` lint ve `loc_residue`'yu koşar; etkin değildir, etkinleştirmek sahibin kararıdır.

**Tuzaklar**
- Bayrak `--` ayracının arkasına konmaz: `main.gd` `OS.get_cmdline_args()` okur, `--` sonrası sessizce düşer.
- Smoke, shot ve probe `user://`'ya yazar; kayıt yuvası paylaşan vakalar paralelde çakışır (liste HARITA'da).
  `APPDATA` başka bir dizine verilirse `user://` oraya taşınır: her koşuya ayrı dizin gerçek kayıtları korur ve
  paralel koşuyu güvenli kılar.
- `xargs -P 2` altında `CASE_TIMEOUT=300` verilir; varsayılan 120 sahte FAIL üretir. `--run-log` her zaman 0 ile çıkar;
  başarılı koşunun çıktısında tam olarak bir `PROBE END` satırı vardır. `class_name` eklenince, silinince ya da adı
  değişince headless koşulardan önce `--headless --import` çalıştırılır.
- Editör `.tres` ve `project.godot`'u yeniden kaydeder (uid ekler, yorum siler); fark sahip onaylamadan commit'lenmez.
- Dosya yazan bayraklar: `--event-lint=baseline` (taban dosyası), `--event-vocab` (`_vocabulary.md`), `--display-check`
  (ayarlar), `--modal-shot=saveload` (hızlı kayıt), `--ending-shot` (zaman damgalı gazete PNG'si).
- Bazı smoke vakaları kaynak metni ve özel adları okur; ad değiştirmeden önce vakayı bul. `event_bus.gd`'deki
  `# --- X ---` başlıkları manifest bölümleri, `# LOC-DATA` işaretleri `loc_residue` istisnalarıdır; silinmez.

## 13. Belgeler
- `docs/HARITA.md` — dizin → sistem → sahip → giriş noktası → smoke öneki → probe kayıt türü.
- `docs/ACIK_ISLER/` — açık işlerin tek yeri: `ACIK_KARARLAR.md` sahip onayı bekleyen maddeler ve GDD'ye işlenmemiş
  sahip kararları, `ISLER.md` kararlaştırılmış ama yapılmamış işler.
- `docs/content/` — Frank külliyatı ve üretilmiş `events_draft/_vocabulary.md` (güncel seam ve fiil listesi).
- `docs/writing/` — Frank yazım çalışma dosyaları. `docs/design/localization_glossary.md` — TR↔EN terim kanonu.
- `docs/EVENT_SIGNAL_MANIFEST.md` — üretilmiş sinyal manifesti (motor GDD §15.1); elle düzenlenmez.
- `GDDs/README.md` — GDD otorite haritası. `tools/office3d/README.md` — ofis 3B dışa aktarım hattı ve yeniden üretimi.
- Kaynak dosya ağaçta olmayan bir belgeye atıf yapmaz (Ekip GDD §17.6).
