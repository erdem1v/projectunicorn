> **Kaynak:** cloud session, 2026-09-25. Onaylanan öneri v3.
> **Durum:**
> - 0A'daki K1–K12 uygulandı: commit'ler `2cbbcd8`, `28d5edc`, `8e49dbd`, `de6ab7f`.
> - 0B'deki K13–K32 AÇIK.
> - İçerideki "Uygulama planı" ve "7b" bölümleri o turun planıydı; tarihsel.

# Series A kapanışı, VC sistemleri ve toplantı diyalogları: öneri v3

## Bu sürümde ne değişti

- Yorumların §0'a **KARAR** olarak işlendi.
- Yorum atmadığın maddeler **AÇIK** bölümünde duruyor.
- İstediğin Frank satırlarını yazdım (§6). Neyi yazdığımı madde madde belirttim.
- Düzeltilen satırlar:
  - "Sabrı inceliyor" yanlış bir ifadeydi. Yerine "Sabrı tükeniyor" geldi.
  - Meridian'ın iki satırı yeniden yazıldı. "Faster" bir ürün metriği değil; demoda çökme de bu oyunun ürününe uymuyor.

**Kapsam (güncellendi, Erdem: "uygula"):** Karara bağlanan K1–K12, açık kararlara bağlı olmayan doğrulanmış hatalar ve §6'daki Frank satırları uygulanır. K13–K32'ye dokunulmaz.

### Uygulama planı

**Kurallar:**
- Çalışma dalı `claude/sharp-dirac-lev32p`; her küme ayrı bir commit olur. `main`'e push yalnız "push et" denirse yapılır.
- Worktree açılmaz.
- Kümeler sırayla işlenir, çünkü hepsi `strings.csv` ve `vc_pitch_system.gd`'yi paylaşıyor.

**Kümeler (sırayla):**

1. **Masa** (`term_sheet_table_system.gd`, masa arayüzü)
   - Seed masasında `LEVERS` yerine `levers()` kullanılır.
   - K12: isteklilik (E) modeli kurulur. Sabır 0'a inince fon ya masadan kalkar ya son teklifini "al ya da bırak" diye koyar. Seed'de kalkma yok, her zaman son teklif gelir.
   - Her itişten sonra fonun sesiyle bir bant satırı gelir (§5.4, "Sabır tükenirken" satırları).
   - K7: "Diğer teklifi göster" eylemi eklenir; fonun cevabı dinamik hesaplanır.
2. **Av ve teklif** (`vc_pitch_system.gd`, `hunt_tab.gd`, `pitch_constants.gd`, funding kartları, `endings_system.gd`)
   - K5: teklif süresi 10 iş günü.
   - K6: oturmadan önce tahmini aralık gösterilir.
   - K8: bekleme sırası görünür olur.
   - K10: süre dolunca kapatılamaz bir karar kartı gelir.
   - K4: görüşme iptal ve erteleme.
   - K11: masadan kalkma zincire sayılmaz.
   - Hatalar: geri çağrı döngüsü ve temiz sorudaki ihtimal.
   - Frank'in soğuk çıkış satırları (§6.2).
3. **Kapı** (`phase_gate_system.gd`, `gate_series_a.json` koşulları, gösterim yerleri, `run_probe.gd`)
   - K1–K2: kapı yalnız MRR ≥ 120K$.
   - K3: çubuk ve "n/3" kalkar.
   - ODA'ya dokunulursa `--theme-audit=oda` önce/sonra karşılaştırılır; fark yalnız kaldırılan alt ağaçta kalmalı.
   - Frank'in yaklaşma kartları (§6.1): her biri koşuda bir kez; "kapı açıldı" satırı `gate_series_a`'dan önceki bir gün gelir.
4. **Satış** (`sales_meeting_system.gd`)
   - İç ses görünür olur.

**Yürütme:**
- Her küme için:
  - uygulama ana modelde yapılır;
  - kapılar haiku ile, düşük eforla koşar;
  - diff incelemesi sonnet ile yapılır;
  - en fazla 2 düzeltme turu olur;
  - ardından commit atılır.
- Eski kuralı test eden smoke vakaları güncellenir. Küme başına en fazla 1 yeni smoke vakası eklenir.

**Doğrulama:**
- Her küme:
  - `--event-lint`;
  - `loc_residue.gd`;
  - `loc_csv_integrity`;
  - ilgili smoke vakaları;
  - kapı kümesinde ek olarak `--event-probe`.
- Sonda bir kez:
  - tam smoke (`psmoke.sh`). Baseline'da zaten kırmızı iki vaka var: `save_migration_v7_to_v8` ve `trait_migration_real_load`.
  - 5 tohumla `--run-log=full_run:700:sim:<seed>`: kapının açıldığı gün, teklif ve imza durumu, script hatası.

Sonuçta kısa bir rapor hazırlanır: yapılanlar, seçilen ayar sabitleri, sapmalar.

**Etiketler:**
- ✅ = kodu bizzat okudum.
- 🔎 = okuyucu ajan raporu, doğrulanmadı.

---

## 0A. Karara bağlananlar

| # | Konu | Karar |
|---|---|---|
| K1 | Series A kapı eşiği | 120K$ MRR kalır. Büyüme serisi kalkar. Ölçüm sonrası gerekirse düşürülür. |
| K2 | Marka tabanı | Kapıdan kalkar. Kapı yalnız MRR. Marka görüşmede inanca etki eder. |
| K3 | Kapı göstergesi | Çip kalır. Çubuk ve "n/3" sayısı kalkar. Frank'in eşiğe yaklaşma satırları eklenir; **satırları ben yazdım (§6.1)**. |
| K4 | Görüşme ayarlama | Aynı anda 1 görüşme. İptal ve erteleme eklenir; fona göre küçük bir inanç cezası olur. |
| K5 | Teklif süresi | **Sabit 10 iş günü.** Takvimde hafta içi zaten var (`game_state.gd` gerçek hafta gününü hesaplıyor); geri sayım yalnız hafta içini sayar. Bugünkü 14 takvim günü yaklaşık aynı süre ama "iş günü" dili daha net. |
| K6 | Teklif kartı | Oturmadan önce **tahmini aralık** gösterilir: yaklaşık değerleme ve yaklaşık pay. Net sayı yok, yönetim kurulu şartı yok. Ayrıntı masada açılır. |
| K7 | Fonlar arası yarış | "Diğer teklifi göster" eylemi eklenir. Tepki sabit bir kişilik tablosundan gelmez, **dinamik** hesaplanır (§4.2). |
| K8 | En fazla 2 canlı teklif | Kalır. Bekleme sırası oyuncuya görünür yapılır. |
| K9 | Reddeden fonun geri dönmesi | Kararı bana bıraktın. **Karar: dönmez.** Red kalıcı kalır. K10 ile birlikte "fon kapısı bir kez kapanır" kuralı sade ve ağırlıklı kalıyor. ch09 §6'daki "geri dönebilir" cümlesi GDD'den çıkarılır. |
| K10 | Süresi dolan teklif | Süre dolunca otomatik kapanmaz. **Karar kartı gelir:** "Masaya otur ya da reddet." Oyuncu reddederse fon kalıcı kapanır. Bu kart ertelenemez (§4.1). |
| K11 | Masadan kalkma | Fon kapanır, ama reddedilme zincirine sayılmaz. |
| K12 | Masa risk modeli | Her itiş sabrı düşürür. Sabır 0'a inince fon iki şeyden birini yapar: **masadan kalkar** ya da **son karşı teklifini** "al ya da bırak" diye koyar. Hangisinin olacağı dinamik hesaplanır (§4.2). |

---

## 0B. Açık kararlar (yorum bekliyor)

Her maddede soru, önerim ve kısa gerekçe var.

**K13. Kilometre taşı maddesi (Series B köprüsü)**
- **Önerim:** şimdilik not olarak kalsın.

**K14. Reddedilme zinciri**
- Bugünkü durum ✅:
  - sayım kümülatif;
  - masadan kalkma da sayılıyor;
  - sessizce yazılan `pivot_offer_made` mandalı zinciri hiç çalıştırmıyor.
- **Önerim:**
  - Sayım "üst üste" olsun: başarılı bir teklif sayacı sıfırlar.
  - Masadan kalkma sayılmasın (K11 ile uyumlu).
  - Pivot mandalı, kartı yazılana kadar kaldırılsın.

**K15. 730. gün sınırı canlı teklifleri yok sayıyor ✅**
- **Önerim:** Canlı teklif varken son gün, K10 karar kartı gelene kadar uzasın.

**K16. Satın alınma sonunun koşulu**
- Bugün yalnız masadan kalkmakla açılıyor ✅.
- **Önerim:** "Series A'yla yüzleşmiş olmak" red, K10'da reddetme ya da masadan kalkma ile de sağlansın.

**K17. Kapanış sonu şartlara göre değişsin mi? (ch09 §7)**
- **Önerim:** Evet. Frank'in hüküm satırı imzalanan şartları okusun.
- İstersen bu satırları da yazarım.

**K18. Seed teklifinin süresi**
- Bugün hiç dolmuyor 🔎.
- **Önerim:** Series A ile aynı kural uygulansın: 10 iş günü, sonra K10 karar kartı.

**K19. Seed teklifini reddetme / bootstrap yolu**
- **Önerim:** "Şimdilik hayır" seçeneği eklensin. Seed kapısı yeniden açılmaz, ama bootstrap sonu açık kalır.

**K20. Seed'de 1. vuruşta çekilmek tek hakkı yakıyor ✅**
- **Önerim:** Bunu hata sayalım; çekilmek hak yakmasın.

**K21. Seed masasındaki yönetim kurulu kaldıracı sahte ✅**
- **Önerim:** Kalıcı yapılsın. Seed'de verilen koltuk Series A'da o fonun inancını ve masadaki yönetim kurulu şartını etkiler.

**K22. Seed odası "şimdi değil" diyebilsin mi?**
- **Önerim:** Evet. Sert bandın altında bir kez geri çevirebilsin ve seed hakkını geri versin.

**K23. Frank'in çeki reddedilemiyor ✅; bootstrap başlığı yanlış**
- **Önerim:** Başlık "kurumsal tur almadan" olarak düzeltilsin. Zor mod sonraya kalsın.

**K24. Görüşme girdileri**
- **Önerim:** Görüşme büyümeyi (son 3 ay), churn oranını ve brüt marjı da okusun.
- MRR ölçütü bugün 40K$; 120K$ bandına taşınsın.

**K25. Satışta hakaretin maliyeti**
- Bugün hakaretin maliyeti, masadan kalkmakla aynı ✅.
- **Önerim:** 60 gün kilit olsun ve şirket hafızasına yazılsın.

**K26. Satışta baskın strateji ✅**
- **Önerim:** Aynı teklif tekrarlanınca karşı teklif sabit kalsın ve alıcının sabrı 2 düşsün.

**K27. "SON RAKAM" butonu masayı kayıpla kapatıyor ✅**
- **Önerim:** Buton, teklifi "son teklif" olarak göndersin. Alıcı ya kabul eder ya kalkar.

**K28. Satış arketipleri**
- **Önerim:** Satın alma birimi, kurucu-sahip, kurumsal BT ve fiyat avcısı eklensin. Toplam 7 arketip olur.

**K29. Fon arketipleri**
- **Önerim:** Koddaki dörtlü (metrik / ekip / anlatı / ürün) kalsın, ch09 buna göre güncellensin.

**K30. Vuruş sırası fona göre değişsin mi?**
- **Önerim:** Evet, fon başına 3–4 vuruş.

**K31. İçerik turu kapsamı**
- **Önerim:** Önce yaklaşık 150 satırlık MVP, sonra yaklaşık 425 satırın tamamı.

**K32. Frank'in kalan yüzeyleri**
- K3 ve soğuk çıkış yazıldı (§6).
- Kalanlar:
  - K10 karar kartı;
  - masada fona özel satırlar;
  - kapanış hükmü (K17);
  - "diğer teklifi göster" anında tek satır.
- **Önerim:** Bunları da ben yazayım, sen düzelt.

---

## 1. Oyuncu bugün ne yapabiliyor (doğrulanmış)

| Soru | Cevap |
|---|---|
| Teklif alıp bekletebilir miyiz? | **Evet** ✅. 14 gün (`SHEET_VALIDITY_DAYS`). K5 ile 10 iş günü olacak. |
| Kaç teklif bekletilebilir? | En fazla 2 canlı ✅. 3. teklif sıraya girer; slot boşalınca taze süre alır. |
| Süre dolunca ne olur? | Fon kalıcı kapanır, ama red sayılmaz ✅. K10 ile karar kartına dönüşecek. |
| Uyarı var mı? | Evet ✅: ≤3 günde kırmızı geri sayım, TopBar çipi, Frank'in `sheet_expiry` ve `last_answer` kartları. |
| Bekleyen teklif pazarlık gücü verir mi? | Yalnız pasif ✅: inanca +15; masada açılış değerlemesine +4M$ ve itiş ihtimallerine +10 puan. |
| Teklifleri birbirine karşı oynayabilir miyiz? | Hayır ✅. K7 ile eklenecek. |
| Teklifin rakamları oturmadan görünür mü? | Hayır, yalnız bant sözcüğü ✅. K6 ile tahmini aralık görünecek. |
| Aynı anda kaç görüşme? | 1 ✅. İptal yok; tek çıkış 1. vuruşta çekilmek. |
| Hazırlık var mı? | Var ✅: 3 odak, 2 gün, +2 bonus. |
| Masada ne olur? | Yalnız imza ya da kalkma ✅. Kayıt yok, zaman durur. |
| Kapanan fon geri açılır mı? | Hayır ✅. K9 ile böyle kalacak. |
| Kapı daveti reddedilebilir mi? | Evet, sınırsız ✅. 5 günde bir yeniden sorulur. |
| Seed | 1 deneme; oda reddedemez; teklif dolmaz 🔎; masadan kalkılamaz ✅. |
| Series A imzası | Koşuyu anında bitirir ✅. |
| Değerleme | ARR × 8 / 11 / 14; çarpan büyüme bandına göre ✅. |

**Fonlar (kod ✅):**

| Fon | Değerleme | Pay | Yönetim kurulu | Sabır |
|---|---|---|---|---|
| Anchor (metrik) | +%15 | %22 | koltuk + veto | 3 |
| Nexus (ekip) | −%20 | %15 | temiz | 4 |
| Bosphorus (anlatı, sıcak tanıştırma +12) | 0 | %18 | 1 koltuk | 2 |
| Meridian (ürün) | +%25 | %18 | temiz | 2 |

---

## 2. Hatalar ve açıklar

### Bizzat doğrulananlar ✅

1. **Seed masası Series A kaldıraçlarını çiziyor.** `select_lever` ve `_lever_views` `LEVERS` sabitini okuyor, `levers()` fonksiyonunu değil. Sonuç: "DEĞERLEME $0M" satırı çıkıyor, "raise" seçilemiyor. **Kritik.**
2. **Masada itiş risksiz.** K12 ile çözülüyor.
3. **Seed'de 1. vuruşta çekilmek hakkı yakıyor.** Av sekmesinde yatırımcı adı da boş kalıyor.
4. **Seed yönetim kurulu kaldıracı sahte.**
5. **Geri çağrı döngüsü:** koşul karşılanmadan yeniden istenebiliyor, bu da bedava ikinci deneme demek.
6. **Skandal içeriği ölü.** `unmanaged_major_scandal` bayrağına hiç yazılmıyor. Bu yüzden şunlar hiç devreye girmiyor:
   - skandal geri çağrısı (koşulu hep karşılanmış sayılıyor);
   - −12 inanç cezası;
   - Nexus'un skandal sorusu;
   - `HUNT_CB_SCANDAL` satırı.
7. **Zincir çalışmıyor.** Sebep sessiz pivot mandalı.
8. **`faced_series_a` yalnız masadan kalkınca yazılıyor** ve değeri hep "declined" oluyor.
9. **Temiz soruda gösterilen ihtimal, atılan zarla eşleşmiyor.**
10. **Satış tarafı:**
    - hakaret ile masadan kalkmanın maliyeti aynı;
    - teklifi tekrarlamak karşı teklifi yükseltiyor;
    - "SON RAKAM" masayı kayıpla kapatıyor;
    - iç ses hiç görünmüyor;
    - 54 `PH:` yer tutucu satır duruyor.
11. **Frank'in çeki reddedilemiyor.** Bu yüzden bootstrap başlığı yanlış.

### Okuyucu raporu, doğrulanmadı 🔎

- `VC_Q_SOLO` hiç çıkmıyor.
- MRR ölçütü 60K$ üstünde doyuyor.
- Seed'deki açı işareti ile gösterilen ihtimaller uyuşmuyor.
- `run_investment_amount` yanlış hesaplanıyor: pre-money değer post-money gibi kullanılıyor.
- 1. vuruş "Algı" olarak etiketli, ama zar Karizma ile atılıyor.
- Başarısız 1. vuruştan sonra VC "Beni ikna etmedi" diyor; oysa kurucu henüz konuşmadı.
- İç ses gelecek zamanda konuşuyor ("soracak"), ama soru o sırada zaten soruluyor.
- Av sekmesi görüşmeden sonra yenilenmiyor.
- `meeting_day` butonunun etiketi yanlış.
- Masadan kalkma onayında "Diğer teklifler durur" yazıyor; bu yanlış.
- Seed görüşmesi `run_pitches` sayacını artırıyor.
- Seed teklifinin süresi hiç dolmuyor.
- `_sheet_for`, Series A teklifi yerine seed teklifini seçiyor.

---

## 3. Tasarım sorunları (özet)

1. **Bekletmenin anlamı yok.** Teklifi görmek, karşılaştırmak ya da kullanmak mümkün değil. K5–K8 bunu çözüyor.
2. **Masada karar yok.** Risk olmadığı için doğru hamle hep aynı. K12 bunu çözüyor.
3. **Seed'de karar yok.** Açık kararlar K18–K22.
4. **Başarısızlığın sonu çalışmıyor.** Açık karar K14.
5. **Görüşme GDD'nin istediği girdileri okumuyor.** Açık karar K24.
6. **Diyalog tekrar ediyor** (§5).

---

## 4. Yeniden tasarım

### 4.1 Av

**Teklif kartı (K6):**
- Görünenler: fon adı, tahmini değerleme aralığı, tahmini pay aralığı ve kalan iş günü.
- Örnek: "Değerleme ~16–20M$ · Pay ~%18–24 · 7 iş günü".
- Aralık teklifin gerçek değerini içerir ama tam ortasında durmaz, yani aralıktan tahmin edilemez.
- Yönetim kurulu şartı gösterilmez.

**Süre bilgisi (K5):** Düz bilgilendirme olarak gösterilir, fon sesi kullanılmaz: "Teklif süresi: 10 iş günü."

**Hatırlatmalar:**
- 3 iş günü kala mevcut `sheet_expiry` kartı gelir.
- Son gün `last_answer` kartı gelir.

**Süre dolunca: karar kartı (K10).**
- Kart kapatılamaz ve iki seçeneği vardır:
  - "Masaya otur": masa hemen açılır.
  - "Reddet": fon kalıcı kapanır.
- Kartın gövdesi fon adını ve tahmini aralığı yeniden gösterir.

**İptal ve erteleme (K4):**
- Görüşme iptal edilebilir ya da ertelenebilir; ikisi de o fonun inancından küçük bir düşüş getirir.
- Görüşme ertelenirse aynı gün başka bir görüşme ayarlanamaz.

### 4.2 Masa: dinamik sabır ve "diğer teklifi göster"

Tek bir iç değer her şeyi yönetir: fonun **istekliliği (E)**, 0–100 arası.

**Başlangıç değeri:** görüşmedeki inanç + fonun bu şirkete verdiği önem.
- Fon ürün odaklıysa (Meridian), ürün güçlüyse E yüksek başlar.
- Fon metrik odaklıysa (Anchor), MRR ve churn iyiyse E yüksek başlar.

**İtiş (push):**
1. Başarı ihtimali bugünkü gibi hesaplanır.
2. Başarısız itiş sabrı 1 düşürür.
3. İstenen iyileştirme ne kadar büyükse E o kadar düşer.

**Sabır 0'a inince (K12):**
- **E ≥ eşik:** Fon son karşı teklifini koyar. Oyuncunun istediği ile fonun tavanı arasında bir yerdedir. Seçenekler yalnız "İmzala" ve "Kalk".
- **E < eşik:** Fon masadan kalkar ve kalıcı kapanır.
- Eşik fona göre değişir: sabrı kısa fon daha kolay kalkar.
- Oyuncu bunu önceden okuyabilir. Her itişten sonra fonun tepki satırı E'nin bandını söyler:
  - rahat;
  - gerginleşiyor;
  - "Sabrı tükeniyor."

**"Diğer teklifi göster" (K7, masada bir kez):**
- Fonun cevabı üç şeyden hesaplanır:
  - **Fark:** diğer teklif, bu fonun önemsediği kaldıraçta ne kadar iyi? Anchor değerlemeye, Nexus paya, Bosphorus yönetim kuruluna, Meridian değerlemeye bakar.
  - **E:** fonun istekliliği.
  - **Kalan sabır.**
- Olası sonuçlar:
  - **Eşler:** kendi kaldıracında farkı kısmen ya da tamamen kapatır. E yüksek ve fark küçükse olur.
  - **Karşılığında şart ister:** farkı kapatır ama başka bir kaldıraçta geri alır (Anchor koltuk ister). E orta düzeydeyse olur.
  - **Yerinde durur:** hiçbir şey değişmez, E düşer.
  - **Kalkar:** yalnız E düşük ve fark büyükse olur. "O zaman onlarla git."
- Oyuncu sonucu önceden tam bilmez. Ama fonun tepki bandı ve kartın tahmini aralığı yeterli ipucu verir.
- Bu hamle blöf değil, gerçek teklifi gösterir. Blöf ileride eklenebilir.

### 4.3 Seed
- Açık kararlar: K18–K22.
- Seed masasının kaldıraçları raise / dilution / board olarak düzeltilir.
- Seed masasına da §4.2'deki "sabır 0 → son teklif" kuralı uygulanır. Seed masasında masadan kalkma kapalı, ama K19 kabul edilirse "şimdilik hayır" seçeneği gelir.

### 4.4 Görüşme girdileri
- Açık karar: K24.
- Skandal bayrağına ya bir yazar bağlanır ya da skandal içeriği kaldırılır.

---

## 5. Diyalog sistemi: tekrarı öldürmek

### 5.1 Teşhis
- **Satış:**
  - Her slotta tek satır var ve hepsi `PH:` yer tutucu.
  - Tepki, açılış ve gerekçeli kapanış slotları yok.
  - Soru sırası sabit.
  - Eşit adaylar gün numarasının tek/çiftliğine göre seçiliyor.
  - Yalnız 3 arketip var.
- **VC ve seed:**
  - 4 sabit vuruş.
  - Açılış 1 satır; tepkiler 3 satır ve iki oda arasında ortak.
  - Fonların kendi sesi yok.
  - Soru deterministik.
  - Geri çağrı görüşmesi aynı metni oynatıyor.
- **Masa:** yatırımcı tek cümle konuşuyor.

### 5.2 Model

Üç oda aynı dört parçayı paylaşır: **iskelet**, **havuzlar**, **seçim** ve **hafıza**.

**Seçim kuralı:**
1. Koşulu tutan adaylar alınır.
2. En spesifik aday kazanır.
3. Eşitlikte en uzun süredir söylenmemiş olan seçilir.
4. Hâlâ eşitse şirkete ya da fona bağlı bir tohum kullanılır.

Yeni motor gerekmiyor: koşullar `EventGate.condition_met` ve `SalesProbes.facts_for` ile yazılır, havuzlar JSON olur ve lint'ten geçer.

**Eklenecek slotlar:**
- açılış;
- tepki;
- konu geçişi;
- gerekçeli kapanış;
- görünür iç ses;
- soğuk çıkışta Frank (§6.2).

### 5.3 Biçim kişiliğe göre değişir
- **Satış arketipleri:** hızlı alıcı önce fiyat sorar; temkinli alıcı referans ister; titiz alıcı yanlış cevapta sahneyi keser.
- **VC:**
  - Anchor metrikle açar.
  - Nexus ekip üzerine uzun bir "odayı oku" vuruşu yapar.
  - Bosphorus Frank üzerinden açar, tek ama derin bir soru sorar.
  - Meridian ürünün kullanımını sorar.
- **Soru önceden sezdirilir:** "Odayı oku" başarılıysa sorgunun konusu önceden görünür.

### 5.4 Fon ses kartları (EN; TR lokalizasyonu yazım turunda)

**Anchor: rakam, soğuk, kısa.** Onaylandı ✔
- Açılış: *"I read your numbers on the way in. Let's start where they get thin."*
- İyi tepki: *"Fine. That holds."*
- Kötü tepki: *"That's a story. I asked for a number."*
- Sabır tükenirken: *"We can keep doing this. Our terms get worse while we do."*

**Nexus: ekip, sıcak, meraklı.**
- Açılış: *"Before the deck. Who was the second person you hired, and why them?"*
- İyi tepki: *"That's the answer of someone who's been in the room at 2 a.m."*
- Kötü tepki: *"You said 'I' four times. Where's the team in this?"*
- Sabır tükenirken: *"I'm on your side. My partners are counting."*

**Bosphorus: ilişki, anlatı, Frank'i tanır.**
- Açılış: *"Frank says you don't sleep. Tell me what keeps you up."*
- İyi tepki: *"Now that's a company I can explain on Monday."*
- Kötü tepki: *"You've told me what it does. Tell me why it matters."*
- Sabır tükenirken: *"Let me call Frank before either of us says something final."*

**Meridian: ürün, sabırsız.** Yeniden yazıldı. Artık ürünün kullanımını, benimsenmesini ve kalıcılığını okuyor.
- Açılış: *"Skip the slides. Show me what a customer does on their first Monday."*
- İyi tepki: *"People use this without being told to. That's rare."*
- Kötü tepki: *"Half your accounts log in once a week. What are they paying you for?"*
- Sabır tükenirken: *"We have other meetings this week."*

**Satış arketipi örnekleri:**
- *ops_cautious* açılış: *"We've been burned by a tool like this once. Tell me what happens on a bad Tuesday."*
- *finance_brisk* açılış: *"Price first. If that works, we'll talk about the rest."*
- Geri dönen şirket: *"Last time it was the outages. What's changed?"*

### 5.5 Bütçe
- **Satış:** yaklaşık 230 satır.
- **VC:** yaklaşık 110 satır.
- **Seed:** yaklaşık 60 satır.
- **Masa:** yaklaşık 25 satır ve Frank satırları.
- **MVP:** yaklaşık 150 satır.
- **Ölçüt:** 30 toplantıda yüksek frekanslı hiçbir satır 2 kereden fazla görünmez.

---

## 6. Yazdığım Frank satırları (taslak, düzeltmen için)

**Ne yazdım:** K3 için kapıya yaklaşma satırları (4 eşik) ve soğuk çıkış satırları (fon başına 1, genel 2). Kaynak mevcut Frank sesi: kısa, "biz" diliyle, pratik, duygusuz ama sahiplenen (`seed_closed`, `sheet_expiry`, `last_answer`).

**Yerleşim ve kurallar:**
- Satırlar Frank'in mesajı olarak gelir.
- Her eşik koşuda bir kez görünür.
- MRR eşiğin altına düşüp tekrar geçerse aynı satır tekrar gelmez.
- Satırlar sayı söylemez; ch08 §5'in "ilerleme çubuğu yok" kuralına uyar.

### 6.1 Kapıya yaklaşma (K3)

**~%50 (60K$ MRR)**
- EN: *"Halfway there. Don't look at the door yet. Look at the churn."*
- TR: *"Yolun yarısı. Kapıya bakma daha. Churn'e bak."*

**~%75 (90K$ MRR)**
- EN: *"People are starting to ask about you. Nobody calls yet. They will."*
- TR: *"Soran var artık. Arayan yok, ama arayacaklar."*

**~%90 (108K$ MRR)**
- EN: *"Close now. Clean up whatever you don't want asked about."*
- TR: *"Yaklaştık. Sorulmasını istemediğin ne varsa şimdi topla."*

**Kapı açıldı** (mevcut `gate_series_a` kartından önce, aynı gün değil)
- EN: *"The numbers carry a round now. When you're ready, we sit down."*
- TR: *"Rakamlar artık bir turu taşır. Hazır olduğunda masaya otururuz."*

### 6.2 Soğuk çıkış (görüşme reddiyle bittiğinde, kısa ve kuru)

**Anchor**
- EN: *"They wanted a number you didn't have. Go get it."*
- TR: *"Onlar bir rakam istedi, sende yoktu. Git bul."*

**Nexus**
- EN: *"They weren't buying the product. They were buying you. Think about that."*
- TR: *"Ürünü değil seni aldılar ya da almadılar. Bunu düşün."*

**Bosphorus**
- EN: *"I'll hear about this one. Let me handle it."*
- TR: *"Bunu bana sorarlar. Ben hallederim."*

**Meridian**
- EN: *"They opened the product and closed it. That's the whole meeting."*
- TR: *"Ürünü açtılar, kapattılar. Toplantı bu."*

**Genel 1**
- EN: *"One no. Not the last one. Don't carry it into the next room."*
- TR: *"Bir hayır. Sonuncusu olmayacak. Sonraki odaya taşıma."*

**Genel 2** (zincirde 2. red)
- EN: *"Two in a row. The next one decides a lot. Take your time."*
- TR: *"Üst üste iki. Sıradaki çok şey belirler. Acele etme."*

---

## 7. Önerilen sıra

1. **0B'deki açık kararlar:** K13–K32.
2. **Hata turu:** §2'deki ✅ maddeler. Önce seed masası.
3. **Kapı:** K1–K3 ve Frank satırları. Ardından ölçüm: `full_run` × 15 tohum.
4. **Av ve masa:** K4–K12 ve §4.1–4.2 (dinamik E modeli).
5. **Seed:** K18–K22.
6. **Konuşma altyapısı:** slotlar, seçim, hafıza.
7. **Yazım turu 1:** MVP, yaklaşık 150 satır. Önce EN, sonra TR.
8. **Yazım turu 2:** arketipler, soru havuzları.

---

## 7b. Test ve doğrulama bütçesi (yorumun: "testte daha az token")

**Büyük iş akışı yok.** 161 ajanlık doğrulama turu gibi geniş koşular yapılmaz.

**Doğrulama ve okuma işleri ucuz modelle yapılır:**
- Kod okuma ve hata doğrulama Haiku ile yapılır. Sonuçlar tek bir özet olarak döner.
- Sonnet yalnız gerekirse devreye girer.
- Tasarım ve yazım işleri ana modelde kalır.

**Ölçüm daha hafif koşulur:**
- Varsayılan: `full_run` × 5 tohum.
- 15 tohum yalnız kapı eşiği (K1) kararı için koşulur.
- Çıktının tamamı değil, yalnız özet satırları okunur.

**Kapılar:**
- Her committe yalnız dokunulan alanın hızlı kapıları koşulur: lint, `loc_csv_integrity` ve ilgili smoke.
- `smoke_run.sh --all` yalnız turun sonunda bir kez koşulur.

---

## 8. Yorumlarının ele alınışı

| Yorum | Karşılığı |
|---|---|
| K1, K2, K4, K8, K11 "ok" | 0A'ya karar olarak işlendi. |
| K3 "ok, satırları da yaz" | §6.1'e yazıldı. |
| K5 "sabit 10 iş günü" | Karar olarak işlendi. |
| K6 "tam miktar yerine aralık" ve §4.1 "tahmini olsun, net sayı ya da board gösterme" | §4.1'deki teklif kartı buna göre yeniden yazıldı. |
| K7 "dinamik olsun" | §4.2: istekliliğe dayalı dinamik model. |
| K9 "no need ama sen bilirsin" | Karar: dönmez. |
| K10 "reminder atalım, karar ver; reddederse bye bye" | §4.1'deki karar kartı. |
| K12 "sabır 0 → kalkar ya da al-ya-da-bırak" | §4.2. |
| "inceliyor ne?" | Haklısın, böyle bir ifade yok. "Sabrı tükeniyor" oldu. |
| "Fonun sesine gerek yok, düz bilgi" | §4.1: süre düz bilgi olarak gösteriliyor. |
| "Soğuk çıkış Frank: sen yaz, belirt" | §6.2. |
| Anchor "nice" | Olduğu gibi kaldı. |
| Meridian "faster metrik değil" ve "demoda crash olmaz" | Satırlar ürün kullanımı üzerine yeniden yazıldı (§5.4). |
