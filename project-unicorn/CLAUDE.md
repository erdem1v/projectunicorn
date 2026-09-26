# Project Unicorn — ajan giriş noktası
Bu dosya bugün geçerli kuralları ve gerçekleri taşır. Kod haritası: `docs/HARITA.md`.

## 1. Oyun bugün
Oyuncu bir teknoloji girişimi kurar ve onu Series A'ya taşımaya çalışır; oyun Türkçe ve İngilizce oynanır. Koşu
tek yönlü üç evreden geçer: Bootstrap → Traction → Series A Hunt. Her evre runway'i yeniden daraltır; hiçbir evrede
yetkin bir oyun "kasa artıyor, karar kalmadı" noktasına varmamalıdır. İki pazar farklı oynanır: B2B (hesaplar,
sözleşmeler) ve B2C (kitle, ağızdan ağıza). Fon merdiveni: kurucunun birikimi → Frank'in MRR eşiğinde gelen tek
çeki (tur değil, tek karar) → dört VC'den biriyle term sheet'li seed → aynı dört VC ile Series A. Series A imzası
zaferdir. Kasa eksiye düşünce 30 günlük [WORKING] kepenk sayacı başlar; sıfıra inerse şirket iflas eder. Yumuşak
tavan 24 oyun ayıdır ([WORKING] 730 gün). Demo Bootstrap'tan Series A kararının sonuçlanmasına kadar sürer, 60–90
dakika [WORKING] hedefler. Sonların tam kümesi, koşulları ve demo/EA/full farkı GDD ile kodda ayrışıyor: `docs/ACIK_KARARLAR.md`.

## 2. Tasarım otoritesi
- Otorite `GDDs/`'dir: v2 bölümleri (ch01–14), modül GDD'leri (Ürün ch03 dosyasındadır; Ekip, Ar-Ge, Satış) ve
  olay motoru için `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`. Hangi dosyanın yürürlükte olduğu `GDDs/README.md`'de.
- Motor md'si makineyi, ch11 olay içeriğini yönetir; eşittirler. Kod md'den ayrılırsa ayrılık md'nin §27'sine yazılır.
- Bir GDD ötekini açıkça geçersiz kılabilir: ch09 → ch01 §4; Ekip → ch02 §2/§6/§10, ch01 §5, ch06 §1.2, ch12 §8.
- GDD sessiz, belirsiz ya da açıkça çözülmemiş biçimde çelişkiliyse **dur ve sor**. Mekanik, içerik, mimari icat edilmez.
- [ÇALIŞMA] / [WORKING] / [K] işaretli sayı kalibrasyon girdisidir; kodda tek bir ayar sabitinde durur.
- GDD'de adı ya da kuralı geçen ama henüz bağlı olmayan kod ve içerik, bağlı değil diye silinmez.
- GDD ile kod ya da sahip kararı arasındaki bilinen ayrılıklar `docs/ACIK_KARARLAR.md`'dedir; burada anlatılmaz.

## 3. Çalışma kuralları
- İş doğrudan `main`'e commit'lenir; dal, worktree, rebase yok. Gerekli görünürse dur ve sor. Push yalnız Erdem
  "push et" dediğinde yapılır; "geri al" revert demektir. Bir kapı, onu iddia eden commit'ten önce yeşildir.
- Tasarım sabiti (ayar değeri, eşik, isteklilik (E) modeli sabitleri, kapı ya da toplantı ağırlığı) değişikliği raporda
  **"onay bekliyor"** altında listelenir. Önce tasarım notu yazılır; uygulama, test emekliye ayırmak dahil, onaydan sonra.
- Kalibrasyonda ölç ve raporla, sabit değiştirme. Harness ya da bot değişikliği serbesttir, ayrı raporlanır.
- `docs/ACIK_KARARLAR.md`'deki açık maddelere dokunulmaz; onaylananlar tek tek uygulanır.
- TR metni onaysız değişmez; onay bekleyen metin commit mesajında "TR/EN onay bekliyor" diye işaretlenir. Frank'in
  külliyatı Erdem'indir: yeni Frank satırı yalnız taslaktır, onaysız ekrana çıkmaz.
- Rapor: madde madde ✅ / ⚠️ / ❌ + kanıt (dosya:satır, commit, test adı). Tahmin yazılmaz.
- Godot MCP eklentisi ve git kökündeki `.mcp.json` kalır. `addons/` üçüncü taraf koddur, dokunulmaz.

## 4. Oyuncuya görünen metin
- **BILINGUAL BIRTH LAW.** Oyuncuya görünen her metin bir anahtar olarak doğar; TR ve EN aynı commit'te dolar. TR
  kanoniktir ve önce yazılır; EN çeviri değil, aynı sahnenin İngilizce yazılmış hâlidir. Anahtarlar
  `localization/strings.csv`'de (`keys,tr,en`); `Localization` autoload'u CSV'yi açılışta okur.
- Script ve sahnede oyuncuya görünen literal yazılmaz; sahne metni anahtarın kendisidir. Birleşik metin
  `tr(KEY).format({ad})`: yalnız adlı yer tutucu, `%s`/`%d` yok, araya giren değer ek almaz (`Sözleşme: {company}`
  olur, `{company}'nin sözleşmesi` olmaz), CSV değerinde çıplak süslü parantez yok. Durumda metin değil id saklanır.
  Özel adlar çevrilmez. `static func` içindeki `tr()` derlenir ama çalışırken ölür.
- **LANGUAGE INTEGRITY LAW.** `docs/design/localization_glossary.md` bağlayıcıdır. TR metinde İngilizce yalnız izinli
  ödünç kelimelerde kalır: pitch, startup, demo, momentum, MRR, runway, churn, burn, laptop, mail, VC ve özel adlar.
  Tek metinde dil karışmaz. Oyuncuya görünen hiçbir metinde tire (— –) yoktur (ch01 §9).
- Motorun bilmediği etki ya da koşul taslakta `[VOCAB?]` / `[COND?]` kalır ve kart bağlanmaz (ch11 §3). Oyuncu
  metnini kimin yazdığı açık karardır (`docs/ACIK_KARARLAR.md`).
- Kartlar `text.tr` ve `text.en` bloklarını aynı id kümesiyle taşır. Her seçenek gerçek bir kaynağa mal olur ve
  sonucu arayüzde görünür bir yere düşer; bedelsiz seçenek yalnız açık bir "beat"tir. Metin gözlemler, hüküm vermez;
  hüküm yalnız Frank'in ağzındadır (ch11 §7). Kilitli seçenek gerekçesiyle görünür; gerekçe kendi bilgeliğini söylemez
  ("Fiyatlarını zaten iki kez indirdin", "Bu hesabı fiyat değil ürün tutar" değil). Gerçek marka, UI talimatı, sekme
  ya da düğüm adı yok. Gün sınırında ateşlenen kart saat yazmaz. Seçeneğin anlattığını modifier'ları yapar.
- **EFFECT-VISIBILITY RULE.** Modifier oyuncuya okunur etiketle gösterilir, iç kodla değil. Etki çipini kuran tek yer
  `event_modal._describe_modifier`; bilinçli etiketsiz fiiller `SILENT_VERBS`'te, `event_chip_coverage` smoke'u zorlar.

## 5. Mimari
- Godot 4.6 (Forward Plus), yalnız GDScript. Ana sahne `scenes/main/Main.tscn`; `main.gd` açılışı, modal montajını
  ve debug bayraklarını taşır. Tasarım tabanı 1920×1080; `DisplaySettings.BASE_VIEWPORT` bunu elle yansıtır.
- Autoload'lar (`project.godot` sırası): EventBus, GameState, CharacterRegistry, CustomerRegistry, ProspectRegistry,
  PromiseRegistry, RivalRegistry, InvestorRegistry, TimeManager, SaveManager, Settings, Localization, AudioManager;
  sonra `MCPRuntime` (`addons/godot_mcp_runtime`, MCP köprüsü).
- `scripts/systems/` statik `RefCounted` sınıflardır; TimeManager saatlik ve günlük tiki dağıtır, EventBus sinyal
  merkezidir. Zaman merdiveni `TimeManager.SECONDS_PER_DAY = [0, 12, 6, 3]`: duraklat / 1× / 2× / 3×.
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
- Kayıt: JSON; `SaveManager.SCHEMA_VERSION` 12, `MIN_LOADABLE_VERSION` 10. `SaveCodec` GameState değişkenlerini ve
  modellerin `@export` alanlarını kendisi bulur; eski kayıtta varsayılan göç yerine geçtiği için yeni alan anlamlı
  varsayılan taşır. Statik durum tutan sistem `SaveManager.reset_all_owners`'a girer. RNG tohumludur (`RngStreams`).

## 6. UI ve tema — UI/STYLE LAW
1. **Sözlük `UiTokens`'ındır.** Her renk palet tablosunda adlıdır; her boyut merdivendendir (`SIZE_MICRO 9 · META 10
   · SMALL 11 · DATA 12 · BODY 13 · LEAD 15 · TITLE 16 · DISPLAY 22`; editorial `SIZE_ED_* 24 · 26 · 32 · 44 · 52`).
   Ham `Color(...)` ya da ham boyut yazılmaz; duruma bağlı stil helper'dan okunur (`delta_color`, `badge_palette`, …).
2. **`themes/master_theme.tres` üretilmiştir.** Üretici `"$GODOT" --headless --path . -s
   res://scripts/theme/build_theme.gd` (temiz checkout önce `--import`). Token ya da `build_theme.gd` değişikliği
   aynı commit'te `UiTokens.THEME_STAMP`'i artırır ve temayı yeniden üretir; debug açılışı bayat damgada uyarır.
   **`themes/oda_frozen_theme.tres` dondurulmuştur:** `OdaView.tscn` ve `oda_tour.gd` takar; kopyalanmaz,
   düzenlenmez, yeniden üretilmez. Gömülü damgası 5'tir; THEME_STAMP ile arası beklenir, kapatılmaz. ODA'nın
   doğrudan okuduğu renkler `ODA_*` donmuş register'ındadır; ODA tint'lerini yalnız `oda_view.gd` okur.
3. **Token'ı tema öğesine çeviren tek dosya `build_theme.gd`'dir.** Skala boyutun, varyasyon yüz ve rengin sahibidir.
4. **Sahne ve script yalnız yerleşimin sahibidir** (anchor, separation, margin, min-size); boyut, renk, stylebox
   taşımaz, `theme_type_variation`'a uzanır ya da yenisini ekler. Mevcut literal, çevresi değişince taşınır.
- Görsel dil Terminal'dir: mono yazı, hairline çizgi, amber vurgu; hover dolgu değil kenar parıltısıdır. Sayfa
  `#0D1115`, kabuk `#07090B`, `CREAM == INK`. Açık iki ada: gazete (`PaperPanel`, `PAPER_INK_*`) ve ODA'nın teması.
- **Chrome kuralı.** `Chrome*` (koyu kabuk ailesi) `master_theme`'de TopBar, MonthSummary, LeftTabs ve
  TabPageChrome'da; ODA'nınki donmuş temadan çözülür. Satış sekmesi ve pazarlık sahnesindeki kullanım
  `docs/ACIK_KARARLAR.md`'de açık karardır; listeye yeni yüzey eklemek ayrı karardır.
- ODA kapısı `--theme-audit=oda`: kanıt satır sayısı değil diff'tir. `@Sınıf@NN` sayaçları normalize edildikten sonra
  değişiklik hedeflenen alt ağaçta kalır, dışı bayt-aynıdır.

## 7. Kapılar ve araçlar
`export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/`'dan. CI yok.
- **Sıra:** `"$GODOT" --headless --path . --event-lint` (kabul edilen bulgu gerekçesiyle `tools/lint_baseline.json`'a;
  onu `--event-lint=baseline` yazar, doğrulamada koşulmaz)
  → `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` → `bash tools/smoke_run.sh loc_csv_integrity`
  → hedefli smoke (`smoke_run.sh <vaka>`, önekler HARITA'da) → tam smoke (`--all` ya da vaka listesi `xargs -P 2`).
- Motor: `--event-probe`, `--why-fire=<kart id>`, `--event-harness=random:seeds=N:days=M | guided[:seeds=N:days=M]`,
  `--event-vocab` (`_vocabulary.md`'yi üretir, KEEP bloğu kalır); `python tools/gen_signal_manifest.py`.
- Probe: `--run-log=<preset>:<gün>:sim[:<seed>]`, preset'ler `RunProbe.PRESETS`'te. Karar değil defter basar;
  `^PROBE` satırları aynı seed, aynı binary ve `--lang=tr` ile bayt-deterministiktir.
- Smoke ve probe demo yapısına sabitlidir; EA akışı editörde Main Run Args'a `--build=ea` yazılarak oynanır.
- Görsel kontrol (pencereli): `--<yüzey>-shot=<tür>` ailesi (tab, modal, onboard, oda, event, ending, vc, sales,
  negotiation, meeting, product, hr, finance, b2b), `--probe-shot`, `--theme-audit=<id>`, `--shot-size=GxY`,
  `--lang=tr|en` (kayıtlı dili ezer). PNG'ler `%APPDATA%\Godot\app_userdata\Project Unicorn\`'a iner; EN `_en` alır.
- Git kökündeki `.githooks/pre-commit` lint ve `loc_residue`'yu koşar; etkin değildir, etkinleştirmek sahibin kararıdır.

**Tuzaklar**
- Bayrak `--` ayracının arkasına konmaz: `main.gd` `OS.get_cmdline_args()` okur, `--` sonrası sessizce düşer.
- Ajanın Git Bash'inde `$USER` boştur; `GODOT` export edilmezse `smoke_run.sh` "unbound variable" ile düşer.
- Smoke, shot ve probe `user://`'ya yazar; kayıt yuvası paylaşan vakalar paralelde çakışır (liste HARITA'da).
  `APPDATA` başka bir dizine verilirse `user://` oraya taşınır: her koşuya ayrı dizin gerçek kayıtları korur ve
  paralel koşuyu güvenli kılar.
- `xargs -P 2` altında `CASE_TIMEOUT=300` verilir; varsayılan 120 sahte FAIL üretir. `--run-log` her zaman 0 ile çıkar;
  başarılı koşunun çıktısında tam olarak bir `PROBE END` satırı vardır. `class_name` eklenince, silinince ya da adı
  değişince headless koşulardan önce `--headless --import` çalıştırılır.
- Editör `.tres` ve `project.godot`'u yeniden kaydeder (uid ekler, yorum siler); fark sahip onaylamadan commit'lenmez.
- ODA piksel hash'i iki değer arasında gidip gelir; ODA için `--theme-audit=oda` kullanılır.
- Dosya yazan bayraklar: `--event-lint=baseline` (taban dosyası), `--event-vocab` (`_vocabulary.md`), `--oda-shot=tour`
  ve `--display-check` (ayarlar), `--modal-shot=saveload` (hızlı kayıt), `--ending-shot` (zaman damgalı gazete PNG'si).
- Bazı smoke vakaları kaynak metni ve özel adları okur; ad değiştirmeden önce vakayı bul. `event_bus.gd`'deki
  `# --- X ---` başlıkları manifest bölümleri, `# LOC-DATA` işaretleri `loc_residue` istisnalarıdır; silinmez.

## 8. Belgeler
- `docs/HARITA.md` — dizin → sistem → sahip → giriş noktası → smoke öneki → probe kayıt türü.
- `docs/ACIK_KARARLAR.md` — sahip onayı bekleyen maddeler, GDD'ye işlenmemiş sahip kararları.
- `docs/content/` — Frank külliyatı ve üretilmiş `events_draft/_vocabulary.md` (güncel seam ve fiil listesi).
- `docs/writing/` — Frank yazım çalışma dosyaları. `docs/design/localization_glossary.md` — TR↔EN terim kanonu.
- `docs/EVENT_SIGNAL_MANIFEST.md` — üretilmiş sinyal manifesti (motor GDD §15.1); elle düzenlenmez.
- `GDDs/README.md` — GDD otorite haritası. `tools/oda3d/README.md` — ODA 3D plaka hattı ve yeniden üretimi.
- Kaynak dosya ağaçta olmayan bir belgeye atıf yapmaz (Ekip GDD §17.6).
