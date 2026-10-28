# Test sistemi denetimi ve yeniden tasarım önerisi

Tarih: 2026-10-28. Ölçümler `f06bed6f` üzerinde yapıldı (bugünkü HEAD `219a534f`; smoke dosyası değişmedi, hâlâ 29.471 satır ve 513 vaka). Godot çalıştırılmadı, repoya dokunulmadı.

İşaretler: **[GÖRÜŞ]** benim yargım. **(varsayım)** ölçülmemiş tahmin. **[DEĞERLENDİREMEM]** kanıtı yok.

**Terimler.** *Vaka*: tek bir test. *Fikstür*: testin kendi kurduğu hazır oyun durumu. *Kapı*: commit ya da push öncesi geçmesi gereken kontrol. *Değişmez*: oyunda hiçbir koşulda bozulmaması gereken kural. *Shell*: oyunun ekranı, yani düğmeler, sayfalar ve pop-up'lar.

---

## 1. Sonuç

- Diğer modelin eleştirisi kısmen doğru [GÖRÜŞ]. Asıl sorun testlerin "eski" olması değil. Sorun, yanlış şeyi ölçmeleri.
- Son 10 haftada 19 oyuncuya görünen hata bulundu. **Testler bunların hiçbirini yakalamadı.** 10'unu oynayan biri, 5'ini kod okuyan biri buldu.
- **Neden 1: Ekran hiç sınanmıyor.** Testler oyunu ekransız koşuyor. Düğme, pop-up ve ekrandaki sayı hiçbir kapıda yok. 19 hatanın 8'i burada: 4'ü doğrudan arayüz, 4'ünde ise test oyuncunun izlediği yolu değil, başka bir iç fonksiyonu sınıyordu.
- **Neden 2: Testler gerçek oyunda olmayan temiz bir dünyada koşuyor.** Mail anında gelir, zar kapalıdır, fikstürde churn yoktur. 19 hatanın 8'i burada: 5'i fikstür, 3'ü uzun koşu ya da olay dizisi eksikliği. Uzun koşu kapısı yalnız "oyun çökmeden bir sona vardı mı" diye bakıyor.
- **Neden 3: Paket büyük ve yavaş, bu yüzden tam koşulmuyor.** 513 vaka, 29.471 satır, sırayla en az 51 dakika. 31 vakalık örneklemde vakaların %45'i formül sayısını ya da iç yapıyı sabitliyor. 2 vaka hatanın kendisini şart koşuyordu.
- **Öneri:** Test sayısını artırmak değil, test türünü değiştirmek. Küçük bir pilotla başla: olay kartı fiil denetimi ve 3 "oyuncu yolu" testi. Pilot değerini kanıtlarsa devam.

---

## 2. Bugünkü sistem

| Katman | Ne ölçüyor | Süre | Token maliyeti | Neyi kaçırıyor |
|---|---|---|---|---|
| `--event-lint` | Olay kartlarının şekli; fiil listede var mı | [DEĞERLENDİREMEM] | Bulgu başına 2 satır | Fiilin oyunda bir karşılığı var mı. Bugün 6 fiilin karşılığı yok (aşağıda). |
| `loc_residue` + `loc_csv_integrity` | Metin anahtarları; TR ve EN aynı `{yer tutucu}`ları taşıyor mu | [DEĞERLENDİREMEM] | Az | Yer tutucunun gerçekten dolup dolmadığı. Kart gövdesinde `{days}` oyuncuya basıldı (#19). |
| Smoke (`endgame_smoke.gd`, 513 vaka) | Sistem kuralları, formüller, kayıt göçleri. Ekran kurulmuyor. | Vaka ~6 sn (Mac). Tam paket sırayla ≥51 dk. Eski Windows ölçümü vaka başı ~30 sn. | Geçen vaka 1 satır, `--all` ~5k token. Ama dosya 1,67 MB; okunamıyor, her iş grep ile gezinme istiyor. | Ekran; zaman içindeki sonuç; gerçek oyun durumu (anında mail, zar kapalı). |
| `run_gate.sh` (3 uzun bot koşusu) | Çökmeden bir sona varıyor mu | ~80 sn | 4 satır. Ham defter 155.819 satıra çıkabiliyor. | Hangi son geldiği, churn, gelir. B2B hesapların hepsinin 4 haftada gitmesi bu yüzden kaçtı (#12). |
| `plausibility_run.sh` (44 koşu) | Ekrana gelen olay kartları şemanın kurallarına uyuyor mu | ~30 sn (4 paralel iş) | Birkaç yüz ile 1.000+ satır (~520 FIRE satırı) | Ekran; kart seçildikten sonra oyuncunun gördüğü sonuç [GÖRÜŞ]. |
| `--event-probe` | Motorun 160 iddiası, tek açılışta | Kısa | ~175 satır; her PASS'i basıyor | "week 2 G4" satırı sürekli kırmızı ve normal sayılıyor. |
| `--sprint-probe` | Sprint planı ile kapanış uyuşuyor mu | Kısa | Az | Uyuşmazlıklar (17/20, 29/33) kabul edilerek geçiyor. |
| Çekimler (22 `*-shot` bayrağı) | PNG üretir | Ekranlı, sırayla | Görüntü okumak pahalı (varsayım) | Hiçbir geçti/kaldı kapısına bağlı değil. Kendi dünyasını kurmayan çekim yanlış kareyi onayladı (#11). |
| Görsel kabul (Godot MCP) | Göz ile ekran | Dakikalar | Ekran görüntüleri pahalı (varsayım) | Yalnız bakılan ekran. Fikstür yanlışsa yanlış dünyayı onaylar. |

**Oyuncunun gözüyle üç örnek:**
- **Zam (#3).** Test "bu kişiye zam verilebilir mi?" diye sordu ve doğru cevabı aldı. Menü ise başka bir fonksiyona soruyordu ve o fonksiyon bekleme süresini bilmiyordu. Sen menüde "Zam"ı açık gördün, onay sessizce başarısız oldu.
- **"PH:" satırları (#2).** 54 satış satırı oyuncuya "PH:" önekiyle göründü. İlgili test satırın "PH:" ile başlamasını şart koşuyordu. Yani test hatayı koruyordu.
- **Masa (#5).** Test "masa doluyken arama başlatılamaz" kuralını sınadı. Arama sürerken dolu ofise taşınınca 13 masaya 14 kişi alındı. İşe alma anı hiç sınanmamıştı.

---

## 3. Önerilen yapı

Altı katman. Her katmanın tek bir sorusu var.

| Katman | Soru | Örnek (oyuncunun gözüyle) | Ne zaman | Süre (varsayım) |
|---|---|---|---|---|
| **K0 Veri ve bağlantı** | Kartlar, metinler, kataloglar hem doğru şekilde mi, hem oyunda bir karşılığa bağlı mı? | "Eğitime gönder" seçeneği olan kart, bu fiilin oyunda karşılığı yoksa oyuna giremez. Kart metninde `{days}` kalamaz. Oyuncu metninde "PH:" olamaz. | Her commit | <30 sn, tek açılış |
| **K1 Mantık** | Bir sistem kuralı doğru mu? Açık yoldan sorulur. | "Masa doluyken işe alım reddedilir": aramanın başında da, işe alma anında da. | Her commit (dokunulan sistem); push'ta tümü | Vaka ~6 sn, paralel |
| **K2 Oyuncu yolu** | Ekran kurulur, düğmeye basılır, pop-up açılır, ekrandaki sayı okunur. | Bekleme süresinde "Zam" satırı kapalı görünür. Sprint ekranının "sığıyor" dediği kart puan alır. Olay kartındaki "Eğitime gönder", senin kendi "Eğitime gönder" düğmenin açtığı pop-up'ı açar. | Her commit (ilgili ekran); push'ta tümü | Vaka ~6–10 sn |
| **K3 Uzun koşu değişmezleri** | 3–4 bot koşusu boyunca her hafta "asla" kuralları tutuyor mu? Koşulardan biri gerçek koşulda: mail gerçek saatle, zar açık. | Gazetedeki B2B müşteri sayısı aktif hesap sayısına eşit. Her kepenk bölümünde uyarı gelir. Hesap gidince "Söz ver" yeniden açılır. Kartta ve üst barda runway aynıdır. | Push öncesi; playtest öncesi | ~2–3 dk |
| **K4 Tekrar oynatma** | Playtest'te bulunan hata, aynı tohum ve aynı kararlarla tekrar kurulabiliyor mu? | Kurucu gece ile sprint arasında "Yapımda görev alıyor" yazdıysa, o an tekrar kurulur ve vaka olur. | Hata bulundukça | Değişir |
| **K5 Görsel kabul** | Göz ile: metin taşıyor mu, doğru dil mi, logda hata var mı? | Bugünkü §11 kuralı aynen kalır. | Ekrana dokunan her task | Dakikalar |

**Katman kuralları:**
- **K0:** Lint yalnız "fiil listede mi" diye bakmaz. "Fiilin uygulayıcısı var mı" diye de bakar. Bugün uygulayıcısı olmayan 6 fiil var: `add_customer`, `change_salary`, `convert_audience`, `fire_employee`, `open_paid_tier`, `start_training`. Bu, olay kartlarında çalışmayan etkiler sorunun teknik karşılığı. Bu fiilleri bağlamak ayrı bir iş. K0 ise bağlanmamış fiili taşıyan kartın oyuna girmesini engeller. Böylece CLAUDE.md §5'teki `[VOCAB?]` kuralı uygulanmış olur.
- **K1:** Vaka açık yoldan sorar. Özel bir iç fonksiyonu yalnız gerekçe yazarak çağırır. Fikstür gerçek oyunda olabilecek bir durumdur. Formül sayısını değil, kuralın yönünü sınar. Örnek: "0,5 katsayısı" değil, "aşırı yük çıktıyı düşürür". Gereken sayı koddaki ayar sabitinden okunur.
- **K2:** Piksel karşılaştırması yok. Düğüm ağacı okunur: metin, görünürlük, düğmenin bağlı olduğu yer. Sabit süre beklenmez; koşul sağlanana kadar beklenir (Riot'un dersi [S22]). Yeni K2 vakası bir hafta "karantinada" koşar, sonra kapıya girer.
- **K3:** Yalnız "asla" kuralları tasarım onayı gerektirmez. Eşikli kural tasarım sabitidir: örneğin "imzalanan hesapların ortalama ömrü en az X hafta". CLAUDE.md §3 gereği önce onay listesine gider. Plausibility kapısı bu katmanda aynen kalır.
- **K4:** Factorio'nun dersi [S6–S9]: playtest'te bulunan hata, tohum ve karar kaydı olarak regresyon testine döner. "Altın özet" (her haftanın KPI özetini saklayıp farkı göstermek) en sona kalır. Kalibrasyon sık değişirken bu tür kayıtlar gürültü üretir ve fark okunmadan onaylanır [S10–S13]. Oyunda bir karar kaydı olup olmadığını bilmiyorum [DEĞERLENDİREMEM].

**19 kaçak hata hangi katmana düşerdi** [GÖRÜŞ; pilot bunların bir kısmını gerçekten kanıtlar]:

| Katman | Kaçak hatalar |
|---|---|
| K0 Veri ve bağlantı | #19 (kolsuz fiil, `{days}`), #2 ("PH:") |
| K2 Oyuncu yolu | #3 (zam menüsü), #5 (13 masaya 14 kişi), #6 (memnuniyet çipi bir tikte siliniyor), #15 (satış sayfası kilidi), #16 (Frank'in portresi), #17 (sprint "sığıyor"), #18 (kurucu durum satırı) |
| K3 Uzun koşu + gerçek koşul | #7 (gazete müşteri sayısı), #8 (Frank'in çeki, gece notu), #10 (bot emekli ürün kuruyor), #11 (runway 9999), #12 (hesaplar 4 haftada gidiyor), #13 (kepenk uyarısı), #14 ("Söz ver" kilidi) |
| Gerçek kayıt dosyasıyla yükleme | #4 (göçler hiçbir şey yapmıyordu) |
| Rastgele kart sırası denemesi | #9 (düzeltme kartı sırası) |
| Kural: test hatayı şart koşamaz | #1 (Ar-Ge notu), #2 |

**Araç seçimi: bugünkü koşucuyu geliştir, framework'e şimdilik geçme** [GÖRÜŞ].
1. 19 kaçağın hiçbiri araç yüzünden kaçmadı. Sorun neyin ölçüldüğü ve hangi dünyada ölçüldüğü. GUT da gdUnit4 de bunu kendiliğinden çözmez.
2. 513 vakayı yeni bir araca taşımak büyük ve riskli bir iş. Oyuncuya hiçbir değer üretmez.
3. Framework `addons/` içine girer. CLAUDE.md §3 bu klasörü üçüncü taraf kod sayıyor. Ayrıca sürümü Godot sürümüne sıkı bağlı. gdUnit4 v6.2.x Godot 4.5–4.7.1'i hedefliyor [S1], proje 4.6.3'te. Her Godot yükseltmesinde eşleşme gerekir.
4. K2 için gereken şey Godot'nun kendi araçlarıyla yazılabilir: shell'i kurmak, düğmenin sinyalini tetiklemek, koşul beklemek ve düğümün metnini okumak.
5. **Karar noktası:** Pilotta K2 vakası yazmak zor ya da kırılgan çıkarsa, gdUnit4'ün Scene Runner'ı tek bir vakayla denenir. Scene Runner fare ve klavye taklidi ile sinyal beklemeyi hazır veriyor [S1][S2]. gdUnit4'ün bu projede gopeak eklentileriyle birlikte sorunsuz çalıştığını bilmiyorum [DEĞERLENDİREMEM].
6. JUnit raporu şu an değer katmıyor, çünkü CI yok.

---

## 4. `endgame_smoke.gd` için somut plan

| Grup | Vaka | Satır | Ne yapılır | Neden | Onay |
|---|---|---|---|---|---|
| Ölü göç vakaları: `save_migration_v3_to_v4`, `v4_to_v5`, `v6_to_v7`, `v6_to_v7_drops`, `loc_save_sector_migration` | 5 | ~283 | Silinir. `save_manager.gd:1063-1297`'deki ~235 satır ölü kod da gider. | Yükleyici 10'dan eski kaydı reddediyor (`save_manager.gd:23`). Bu koda hiçbir yoldan varılmıyor. Dosya, kodu yalnız bu vakalar için tuttuğunu kendisi söylüyor. | Sen |
| Kalan eski kayıt göç ailesi (`save_v10…v19_*`, `legacy_v12_*`, `save_drops_retired_*` vb.) | 16 | ~1.380 | Karar 2'ye göre: ya silinir, ya gerçek kayıt dosyasıyla tek vakaya iner. | Vakalar elle şekillendirilmiş kayıtla iç fonksiyonu çağırıyor. #4 tam bu yüzden kaçtı. | Sen |
| Veri ve lint vakaları: `all_scripts_load`, `loc_csv_integrity`, `market_catalog_lint`, `event_lint_v3_rules`, `event_plausibility_compiles`, `product_lines_catalog_loads`, `rnd_tree_loads_and_validates` | 7 | ~280 (varsayım) | K0'a taşınır, hepsi tek açılışta koşar. | Her biri ayrı Godot açılışı (~6 sn) ödüyor. Taşımada denetim kaybolmaz. | Not ile |
| Birleşme: `loc_b2b/b4/b5/sales/product_derived_keys` | 5 → 1 | | Tek bir veri güdümlü vaka olur. | Beşi de aynı kalıbı sınıyor. | Not ile |
| Birleşme: `locale_switch` + `loc_language_switch`; `bankruptcy` + `terminal_kills_gate`; `promise_relock_after_break` + `promise_row_locked_after_break` | 6 → 3 | | Her çift bir vakaya iner. | Aynı kuralı sınıyorlar. | Not ile |
| Birleşme: `walk_not_a_rejection` + `table_walk_not_a_rejection` | 2 → 1 | | Oyuncunun yolu olan `table_walk_*` kalır. | İlki iç fonksiyonu sınıyor. | Not ile |
| Kaynak metni okuyan 7 vaka (ör. `topbar_speed_cluster_three_rungs`) | 7 | | K2'ye çevrilir. "3 tuşuna bas, hız 3 mü bak." | Bugün kaynak kodda bir metin arıyor, tuşa basınca ne olduğuna bakmıyor. | Ajan |
| 16 `# EXPECT-ERROR` bağışı | 16 | | Tek tek gözden geçirilir. "Kural bozulunca hata basmalı" mı, yoksa susturulmuş bir hata mı? | Susturulmuş hata yalancı yeşil üretir. | Ajan, rapor sana |
| F sınıfı (formül sabitleme) | Örneklemde %19; tahmini 47–186 vaka | | Dokunuldukça kuralın yönüne çevrilir. Toplu dönüşüm yapılmaz. | Kalibrasyonda kırılıyorlar, oyuncu akışını kanıtlamıyorlar. | Kural |
| İ sınıfı (iç yapı) | Örneklemde %26; 105 vaka özel üyelere 412 kez erişiyor | | Dokunuldukça açık yola taşınır. Kayıt gidiş-dönüş ve olay motoru çekirdeği olduğu gibi kalır. | İç yapı değişince boşuna kırılıyorlar. | Kural |
| O ve K sınıfı (oyuncu kuralı) | Örneklemde %55 | | **Kalır.** | Paketin değerli kısmı. | — |
| Adlar ve düzen | Tümü | | Dosya sistem başına dosyalara bölünür (`tests/sales_*.gd` gibi). Tarih bölümleri ("Hotfix Turu 1", "Bug cleanup") kalkar. `hotfix_*` sistem önekine geçer; `destek_`/`support_`, `bug_`/`bugs_`, `gate_*` birleşir. | Değişikliğe göre test seçimi tek kurala iner. Ajan 1,67 MB'lık dosyada gezinmez. | Ajan |

**İlk turun kazancı (varsayım):** Yaklaşık 36–40 vaka smoke'tan çıkar ya da taşınır. Bu, ~2.000–2.500 satır test ve ~235 satır ölü üretim kodu eder. Bu turun asıl kazancı vaka sayısı değil; paketin hızı ve neyi ölçtüğü.

**Yeni kurallar** (§10 için öneri):
- Yeni vaka oyuncunun gördüğü sonucu sınar. Fikstür gerçek oyunda olabilecek bir durumdur.
- **Bir vaka bilinen bir hatayı şart koşamaz.** Özellik henüz yoksa vaka "bekliyor: <özellik>" diye işaretlenir. Özellik gelince ya da tarih dolunca koşucu vakayı kırmızıya çevirir. #1 ve #2 bu kuralla önlenirdi.
- Normalleşmiş kırmızı yoktur. Kırmızı ya düzeltilir ya da gerekçeli ve tarihli kabul listesine yazılır. Süresi dolan kabul yeniden kırmızı olur. Lint'in taban dosyası buna örnek.
- `endgame_smoke.gd`'ye yeni vaka eklenmez; vakalar sistem dosyalarına yazılır.
- Kod review (§9) iki soru ekler: "Bu vaka oyuncunun gördüğünü mü sınıyor?" ve "Bu fikstür oyunda olabilir mi?"

---

## 5. Ajan verimi

**Token nereye gidiyor?** Smoke'un kendi çıktısı küçük: vaka başına 1 satır. Asıl yük şu kalemlerde:

| Kaynak | Bugün | Öneri | Tahmini kazanç (varsayım) |
|---|---|---|---|
| CLAUDE.md, her oturumda yükleniyor | 48,9 KB. Test ve kapı bölümleri 17,6 KB; §12 tek başına 16,6 KB, çoğu çekim bayrağı başvurusu. | §10–§12 yaklaşık 3 KB'lık kısa kurallara iner. Bayrak başvurusu `10_test_harness.md`'ye taşınır ve yalnız gerektiğinde okunur. | Oturum başına ve CLAUDE.md'yi yükleyen her alt ajanda ~14 KB, kabaca 4–6k token. Türkçe metinde 1 token ≈ 2,5–3,5 karakter varsayıldı. |
| Plausibility kapısı | Birkaç yüz ile 1.000+ satır | Geçerse 1 satır. Kalırsa ilk FAIL ve özet. | Koşu başına ~10–25k token (satır başı ~20–25 token varsayıldı) |
| `--event-probe` | ~175 satır, her PASS basılıyor | Geçerse 1 satır | Koşu başına ~3–4k token |
| Smoke `--all` | 513 satır, ~5k token | Geçerse 1 satır | ~5k token |
| Ham `--run-log` | 155.819 satıra kadar | Ajan hiçbir zaman ham defteri okumaz; özet aracı okur. | Bir okumada bağlamın taşmasını önler |
| 1,67 MB'lık smoke dosyası | Grep ile gezinme | Sistem başına dosya | [DEĞERLENDİREMEM]. Ölçmedim. Beklenen etki: daha az yanlış yer ve daha az tekrar arama. |
| Geç bulunan hatalar | 19 kaçak; her biri ayrı bir onarım turu (`PRD_ONARIM_0/1`) | Hatalar commit anında yakalanır. | Muhtemelen en büyük kalem [GÖRÜŞ]. Rakam veremem [DEĞERLENDİREMEM]. |

**Çıktı biçimi.** Tek giriş noktası: `tools/test.sh hizli | tam | gece`.

Geçerse tek satır yazar:
```
✓ hizli · 38 vaka · 0 hata · 1 dk 42 sn
```
Kalırsa yalnız ilk hatayı yazar (en fazla ~30 satır), tam log bir dosyaya gider:
```
✗ hizli · 38 vaka · 1 hata · 1 dk 40 sn
hr_raise_row_closed_in_cooldown   tests/hr_cases.gd:212
  beklenen: "Zam" satırı kapalı · görülen: açık
tam log: <dosya yolu>
```
Çıkış kodu anlamlıdır: 0 yeşil, 1 kırmızı, 2 araç sorunu. Kırpma kararını model değil araç verir; `| head` gibi kırpmalar tekrar koşuya yol açıyor [S33].

**Değişikliğe göre seçim:**
- **Bugün:** Hangi vakaların koşulacağını ajan, elle tutulan bir önek haritasından tahmin ediyor.
- **Öneri:** Tek bir tablo, dosya yolunu sisteme ve sistemi test dosyasına bağlar. Örneğin `scripts/sales/…` değişirse `tests/sales_*.gd` koşar.
- **Her zaman koşanlar:** K0 ve ~15 vakalık bir çekirdek set: kayıt gidiş-dönüş, iflas, olay motoru temeli.
- **Tam paket şart:** Seçim bazen gereken testi atlar [S35]. Bu yüzden tam paket push'ta ya da düzenli olarak koşmaya devam eder.

**Hız:**
- **Bugün:** Tam paket sırayla ≥51 dk sürüyor.
- **Paralel koşu:** Her işe ayrı kullanıcı dizini verilir; `plausibility_run.sh` bunu zaten yapıyor. 4 paralel işle ~470 vaka × 6 sn / 4 ≈ **12 dk** (varsayım; paralelde yavaşlama olursa 15–20 dk).
- **Tek süreçte toplu koşu:** Daha büyük bir kazanç mümkün. Bugün her vaka ayrı süreç açıyor, çünkü GDScript bir vakanın hatasını aynı süreç içinde yakalayamıyordu (`smoke_run.sh:4-8`). Bu Mac'teki Godot 4.6.3 ikilisinde hata yakalayan Logger arayüzü (`OS.add_logger`) var; ikilide adını gördüm. Bununla vakalar tek açılışta koşabilir. Vakalar arası durum sızıntısı ölçülmeden önerilmez [DEĞERLENDİREMEM]. Başarılı olursa tam paket birkaç dakikaya iner.
- **Hızlı katman:** K0, dokunulan sistemin dosyası ve çekirdek set. Hedef 2 dakikanın altı (varsayım).

**Zorunlu kılma.** CLAUDE.md'deki bir talimata ajan "çoğu zaman" uyar, her zaman değil [S32]. Commit'ten önce `test.sh hizli`'yi kendiliğinden koşturan bir kontrol (hook) bunu garanti eder. `.githooks/pre-commit` bugün kapalı; açmak senin kararın.

---

## 6. Geçiş planı

| Adım | Ne | Kim | Model | Düşünme | Süre (varsayım) | Neden |
|---|---|---|---|---|---|---|
| 0 | Bu raporu oku, aşağıdaki 5 kararı ver. | Sen | — | — | 20 dk | §3: silme ve kural değişikliği onaysız yapılmaz. |
| 1 | **Pilot.** (a) K0 bağlantı denetimi: her olay fiilinin uygulayıcısı var mı, her `{yer tutucu}` doluyor mu, oyuncu metninde "PH:" var mı. (b) 3 K2 vakası: zam menüsü (#3), satış sayfası saat kilidi (#15), sprint "sığıyor" = puan (#17). (c) `test.sh hizli` ve tek satır çıktı. **Kanıt:** Her K2 vakası, ilgili düzeltme geçici olarak geri alınınca kırmızıya döner. K0 bugünkü 6 kolsuz fiili bulur. | Ajan, ayrıca review ajanı | Opus | yüksek | 1 oturum (3–4 saat) | Yeni yöntemin bugünkü 513 vakanın kaçırdığını yakaladığını ucuza kanıtlar. |
| 2 | Pilot sonucu: tek sayfa. Hangi kaçak yakalandı, süre, çıktı satırı. Devam ya da dur. | Sen | — | — | 10 dk | Değer kanıtlanmadan büyük işe girilmez. |
| 3 | Smoke'u 4 paralel işe böl. Probe ve plausibility geçerse 1 satır bassın. `test.sh hizli/tam/gece` tek giriş olsun. | Ajan | Sonnet | orta | 1 oturum | Harness değişikliği §3'e göre serbest. Tam paket 51 dk'dan ~12 dk'ya iner. |
| 4 | CLAUDE.md §10–§12'yi kısa kurallara indir. Bayrak başvurusunu `10_test_harness.md`'ye taşı. Eskimiş sayıları düzelt (475 → 513 vaka vb.). | Ajan taslak, sen onay | Sonnet | düşük | 30 dk | Her oturumda ~14 KB daha az bağlam. |
| 5 | Silme ve birleştirme tasarım notu (§4 tablosu). Her silinen vaka için "bunu artık ne koruyor" sütunu. Onaydan sonra uygulama. | Ajan not, sen onay, ajan uygulama | Opus not, Sonnet uygulama | orta | 1 oturum | §3: test emekliye ayırmak onaydan sonra. |
| 6 | `endgame_smoke.gd`'yi sistem başına dosyalara böl. Önekleri düzelt. Yol → sistem tablosunu kur. | Ajan | Sonnet | düşük | 1 oturum | Seçim kural olur, ajan dev dosyada gezinmez. |
| 7 | K3: `run_gate.sh` "asla" kurallarını her hafta iddia etsin. Bir koşu gerçek koşulda olsun (mail gerçek saatle, zar açık). Eşikli kurallar ayrı onay listesine gitsin. | Ajan; eşikler için sen | Opus | yüksek | 1–2 oturum | 19 kaçağın 7'si bu katmana düşüyor. |
| 8 | K2'yi 20–30 vakaya çıkar: 19 kaçağın kalanı. Olay kartı fiilleri bağlandıkça her biri için "kart = senin düğmen" vakası. | Ajan | Opus | orta | 2 oturum, işlere yayılı | Ekran bağlantısı bugün hiçbir kapıda yok. |
| 9 | Tek süreçte toplu koşu denemesi. Ölçülecek: süre ve vakalar arası sızıntı. | Ajan | Opus | yüksek | 1 oturum | Başarılı olursa tam paket birkaç dakikaya iner. |
| 10 | Sonra: K4 tekrar oynatma. Altın özet en sona. | Ajan | Opus | yüksek | Değerlendirilir | Kalibrasyon sık değişirken altın özet gürültü üretir. |
| Sürekli | F ve İ vakaları dokunuldukça dönüşür. Test hatayı şart koşamaz. Normalleşmiş kırmızı yok. | Her ajan, review | — | — | — | Toplu dönüşüm yerine iş içinde iyileşme. |

**Senin vereceğin kararlar:**
1. **Yön.** Bu yapıyla, önce pilotla başlayalım mı?
2. **Eski kayıt göçleri.**
   - (a) Demo öncesi eski kayıt desteği bırakılır. 21 vaka ve ölü kod gider. Senin eski playtest kayıtların açılmaz.
   - (b) Göçler kalır, ama vakalar gerçek kayıt dosyasını gerçek yükleyiciden açan tek bir vakaya iner.
   - [GÖRÜŞ]: (a). Oyun henüz oyuncuya çıkmadı; bu bir çıkarım, kontrol et.
3. **Tam paket ne zaman koşsun?** "Push et" dediğinde arka planda ~12 dk mı, yoksa haftada bir mi? 2026-10-06 kararın şu: push öncesi tam smoke yok.
4. **Otomatik kontrol.** Commit'ten önce `test.sh hizli` kendiliğinden koşsun mu?
5. **Framework.** Şimdilik yok, bu benim önerim. Pilot zorlanırsa gdUnit4 tek bir vakayla denensin mi?

---

## 7. Pre-mortem: bu geçiş başarısız olursa

1. **Yarım kalır, iki sistem yan yana yaşar.**
   - **Ne olur:** Eski smoke ile yeni `test.sh` çelişir. Ajanlar hangisini koşacağını şaşırır.
   - **Erken uyarı:** İki hafta sonra yeni vakalar hâlâ `endgame_smoke.gd`'ye ekleniyor.
   - **Önlem:** Adım 3'ten itibaren tek giriş `test.sh`; eski komutlar onun içinden çağrılır. Eski dosyaya ekleme yasağı CLAUDE.md'ye yazılır.
2. **K2 vakaları kırılgan çıkar, ajanlar onları susturur.**
   - **Ne olur:** Ekrandaki bir düğümün adı değişince vaka kırılır. Bekleme süresi tutmaz. Ajan vakayı geçici olarak kapatır.
   - **Erken uyarı:** Aynı vaka bir haftada 2+ kez "düzeltildi". Bekleyen ya da bağışlanan vaka sayısı artıyor.
   - **Önlem:** Düğüm adı yerine sabit bir test kimliği kullanılır. Sabit bekleme yok, koşul beklenir. Yeni vaka bir hafta karantinada koşar. Normalleşmiş kırmızıya sıfır tolerans.
3. **Değişmezler ve altın özet tasarım sabitine dönüşüp onay sürecini tıkar.**
   - **Ne olur:** Her kalibrasyonda eşik ya da kayıt güncellenir, fark okunmadan onaylanır [S11–S14].
   - **Erken uyarı:** Bir ayda 3+ "eşik güncellendi" commit'i.
   - **Önlem:** K3'te yalnız "asla" kuralları serbesttir. Eşikli kurallar `[WORKING]` sabitinden okunur ve onay listesine gider. Altın özet ancak `UPDATE_GOLDEN=1` ve bir gerekçe satırıyla güncellenir; en sona kalır.

---

## 8. Kaynak sicili

"Açıldı: evet" yalnız içeriği gerçekten okunan sayfalar için yazıldı. Rare'in konuşma özeti (glasp.co) 403 verdi, aşılmadı. Sea of Thieves konuşmasının ayrıntılarını doğrulayamadım. Meta'nın test seçimi sistemi için birincil kaynak bulunamadı.

| S# | Kaynak | Yayıncı | Tarih | Güven | Açıldı |
|---|---|---|---|---|---|
| S1 | https://github.com/godot-gdunit-labs/gdUnit4 | godot-gdunit-labs | erişim 2026-10-28 | Yüksek | evet |
| S2 | https://store.godotengine.org/asset/mikeschulze/gdunit4/ | Godot Asset Store | ? | Orta | hayır |
| S3 | https://godotengine.org/asset-library/asset/1709 | Godot Asset Library (GUT) | ? | Orta | hayır |
| S4 | https://tessl.io/registry/testland/godot-gut-tests/1.4.17/files/references/cli.md | tessl | ? | Düşük | hayır |
| S5 | https://gut.readthedocs.io/en/v9.7.1/search.html | GUT docs | v9.7.1 | Orta | hayır |
| S6 | https://factorio.com/blog/post/fff-47 | Wube Software | 2014 | Orta | hayır |
| S7 | https://factorio.com/blog/post/fff-60 | Wube Software | 2014 | Orta | hayır |
| S8 | https://cf-www.factorio.com/blog/post/fff-62 | Wube Software | 2014 | Orta | hayır |
| S9 | https://direct.factorio.com/blog/post/fff-415 | Wube Software | 2024 | Orta | hayır |
| S10 | https://sitepen.com/blog/snapshot-testing-benefits-and-drawbacks | SitePen | ? | Orta | hayır |
| S11 | https://qaskills.sh/blog/snapshot-testing-governance-guide | qaskills | ? | Düşük | hayır |
| S12 | https://testwithpinpoint.com/blog/snapshot-testing-guide | Pinpoint | ? | Düşük | hayır |
| S13 | https://notes.lesleylai.info/Concepts/approval-testing | Lesley Lai | ? | Düşük | hayır |
| S14 | https://discourse.thecodewhisperer.com/t/how-not-to-write-golden-master-tests/338 | J.B. Rainsberger | ? | Orta | hayır |
| S15 | https://github.com/eth-brownie/brownie/blob/v1.16.0/docs/tests-hypothesis-stateful.rst | Brownie docs | v1.16.0 | Orta | hayır |
| S16 | https://codesync.global/media/stateful-property-based-testing/ | Code Sync | ? | Orta | hayır |
| S17 | https://www.offerzen.com/blog/ensuring-that-my-super-fast-simulation-was-simulating-the-right-thing-property-based-testing | OfferZen | ? | Orta | hayır |
| S18 | https://www.zealynx.io/glossary/invariant-testing | Zealynx | ? | Düşük | hayır |
| S19 | https://80.lv/articles/gdc-using-ai-controlled-players-to-test-the-division/ | 80.lv | 2019 | Orta | hayır |
| S20 | https://www.gdconf.com/news/come-gdc-inside-look-ai-built-playtest-battlefield-v-0 | GDC | 2019 | Orta | hayır |
| S21 | https://www.gdcvault.com/play/1034678/AI-Summit-Building-ML-Bots | GDC Vault (Ubisoft La Forge) | 2024 | Orta | hayır |
| S22 | https://www.riotgames.com/en/news/automated-testing-league-legends | Riot Games | 2016-02-26 | Yüksek | evet |
| S23 | https://gdconf.com/news/sea-thieves-devs-share-automated-testing-tips-gdc-2019 | GDC | 2019 | Yüksek (içerik sığ) | evet |
| S24 | https://gdcvault.com/play/1026366/Automated-Testing-of-Gameplay-Features | GDC Vault (Rare) | 2019 | Yüksek (varlık) | hayır |
| S25 | https://www.unrealengine.com/events/unreal-fest-europe-2019/automated-testing-at-scale-in-sea-of-thieves | Epic / Unreal Fest | 2019 | Orta | hayır |
| S26 | https://modl.ai/?p=3381 | modl.ai (satıcı) | ? | Düşük | hayır |
| S27 | https://www.martinfowler.com/bliki/TestPyramid.html | Martin Fowler | 2012 | Yüksek | hayır |
| S28 | https://www.abratabia.com/game-testing/visual-testing.php | Abratabia | ? | Düşük | hayır |
| S29 | https://arxiv.org/pdf/2208.02335v1 | arXiv | 2022 | Orta | hayır |
| S30 | https://gitnation.com/contents/visual-regression-under-the-hood | GitNation | ? | Orta | hayır |
| S31 | https://bugnet.io/blog/how-to-use-visual-snapshot-testing-for-game-ui-regressions | Bugnet | ? | Düşük | hayır |
| S32 | https://code.claude.com/docs/en/best-practices | Anthropic | erişim 2026-10-28 | Yüksek | evet |
| S33 | https://www.humanlayer.dev/blog/context-efficient-backpressure | HumanLayer | 2025-12-09 | Yüksek (görüş yazısı) | evet |
| S34 | https://huang.isis.vanderbilt.edu/cs8395-f23/paper/google-testing-icse-seip-17.pdf | Google / ICSE-SEIP | 2017 | Orta | hayır |
| S35 | https://docs.datadoghq.com/tests/test_impact_analysis/ | Datadog | ? | Orta | hayır |
| S36 | https://www.datacamp.com/tutorial/how-to-reduce-token-usage-in-ai-coding-agents | DataCamp | ? | Düşük | hayır |
| S37 | https://blog.openreplay.com/cut-token-usage-ai-coding-agents/ | OpenReplay | ? | Düşük | hayır |

Ham fetch çıktısı: `/Users/tugbauysal/.claude/projects/-Users-tugbauysal-Desktop-project-steam/6d15b35f-66f1-4e87-b274-dc8c31d2f7b4/tool-results/toolu_01Qj9bUt1i2ckf7FqPRSDQAu.txt`
