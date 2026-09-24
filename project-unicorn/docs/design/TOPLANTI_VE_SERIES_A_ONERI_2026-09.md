# Toplantı diyalogları ve Series A kapanışı — öneri paketi (2026-09)

## Bağlam

Erdem'in istedikleri:
1. `claude/sharp-dirac-lev32p` dalı `main`'e push edilsin.
2. Büyüme serisi Series A kapı şartı olmaktan çıksın; kapı MRR'a bağlansın.
3. Satış, seed ve VC sahnelerindeki diyalog tekrarının araştırılması ve nasıl değiştirileceğine dair ayrıntılı bir hazırlık.
4. Series A kapanışıyla ilgili değişiklik önerileri.

Kod değişikliği ya da test yok; bu tur yalnız öneri.

Statü: ÖNERİ. Kod değişikliği içermez; kararlar Erdem'in.

**Bu belgeyle birlikte yapılanlar:**
- (a) `git push origin claude/sharp-dirac-lev32p:main`. Önce `origin/main`'in dalın atası olduğu doğrulanır; öyleyse fast-forward olur, merge commit oluşmaz. Değilse push yapılmaz ve sorulur.
- (b) Bu belgenin `docs/design/TOPLANTI_VE_SERIES_A_ONERI_2026-09.md` olarak repoya eklenip push edilmesi. Yalnız belge; kod değişmez.

---

## A. Teşhis: tekrar neden hissediliyor

Üç sahne de "durumdan cümle seçen sahne" olarak tasarlanmış (Satış GDD §1, §5.1, §11.2; ch09 §4). Motor iskeleti de doğru kurulmuş: en spesifik kural kazanıyor, koşu hafızası var. **Eksik olan içerik ve üç yapısal slot.**

**Satış toplantısı:**
- Her slotta tek metin var: 8 soru, 23 cevap, 1 kazanç satırı, 5 kayıp satırı, 3 arketip satırı. GDD §11.2 slot başına 3–12 varyant istiyor.
- Bütün satırlar hâlâ `PH:` yer tutucusu taşıyor; yazım turu hiç yapılmadı.
- **Tepki slotu yok.** Cevap verilince yeni soru anında geliyor. GDD §5.1.1'e göre "ana geri bildirim müşterinin tepki satırıdır".
- **Açılış satırı yok.** Kazanç satırı hep aynı ("Sorularım bitti. Rakamı konuşalım.") ve koltuk sayısından söz etmiyor.
- Soru sırası özgüllükle sabitleniyor. Masaların yaklaşık yarısı `ops_cautious` ve orada ilk soru hep kararlılık.
- Cevap satırları hep aynı sırada. Eşit adaylar arasındaki seçim, gün numarasının tek/çiftliğine göre yapılıyor.
- 3 arketip var, GDD 6–8 istiyor. Finans alıcısının kendine ait sorusu yok. Mizaç, balina, geri dönen şirket ve balina şartı hiçbir soruyu koşullamıyor.
- İç ses yazılmış ama bir hata yüzünden hiç görünmüyor (`view_state` iki kez çağrılıyor ve ilkinde tüketiliyor).
- Oda sanatı her zaman aynı (Bosphorus odası).

**VC ve seed:**
- 4 sabit vuruş, aynı sırada: Odayı oku → Anlatı → Sorgu → Kapanış.
- Açılış satırı 1 tane; Anlatı sorusu 1 tane; 3 anlatı seçeneği ve 3 sorgu duruşu sabit.
- Tepki satırı 3 tane ve iki odada ortak.
- **Fonların kendi sesi yok.** Anchor ile Meridian'ın anlatı ağırlıkları bile aynı.
- Sorgu sorusu deterministik: aynı zayıflık her fonda, her denemede aynı soruyu getiriyor. Seed'de her fonun yalnız 2 sorusu var.
- Geri çağrılan (callback) görüşme birebir aynı metni oynatıyor; `meeting_count` hiçbir yerde okunmuyor.
- Tasarım belgesinin istediği iki şey kurulmamış: Odayı oku vuruşunda sorunun önceden sezdirilmesi ("Skandalı soracak") ve soğuk çıkışta Frank'in tek satırı.
- Term sheet masasında yatırımcı tek cümle konuşuyor. Frank'in satırları fona göre değil, masa durumuna göre değişiyor.

---

## B. Referans çerçeve: tekrarı öldüren tekniklerin kısa sentezi

| Kaynak | Teknik | Bize uyarlanışı |
|---|---|---|
| Valve · Elan Ruskin, "Dynamic Dialog" (GDC 2012) | Kural tabanlı cümle seçimi: çok sayıda koşul, en spesifik kural kazanır, konuşulan her şey "fact" olarak hafızaya yazılır | Satış GDD §11.2 bu modelin kendisi; eksik olan havuz derinliği ve hafıza fact'leri |
| Failbetter · kaliteye dayalı anlatı (storylet) | Her cümle, bir durum koşuluna bağlı küçük bir birim | Her soru ve tepki bir storylet: sahip olduğu koşul kadar "ağır" |
| Hades | Büyük havuz, "en son ne zaman söylendi" önceliği, bir kez söylenenin işaretlenmesi, olaya özel satırın genel satırı ezmesi | En son kullanılana göre seçim ve "özel satır genel satırı ezer" kuralı |
| Disco Elysium | İç sesin bir karakter olması, kısa ve koşullu araya girmesi | İç ses bütçeli, somut ve duruma bağlı (GDD ¶68) |
| Griftlands | Pazarlık/ikna, karşı tarafın kişiliğiyle değişen bir mekanik | Arketip ve fon kişiliği yalnız metni değil, sahnenin biçimini (vuruş sırası, soru sayısı) de değiştirmeli (GDD ¶65: "şekil ezberlenemez") |
| Crusader Kings III | Aynı olay, karakterin huyuna göre farklı seçenek ve farklı ses | Fon ve arketip ses kartları; seçenek listesi kişiliğe göre açılıp kapanır |

**Sonuç:** Bizim GDD'lerimiz doğru modeli zaten tarif ediyor. Yeni bir sistem icat etmeye gerek yok. Yapılacak iş dört katman:

1. **Slotlar:** tepki, açılış, geçiş ve kapanış slotlarını eklemek.
2. **Havuzlar:** her slota varyant havuzu koymak.
3. **Seçim:** en spesifik kural ve en son kullanılana göre seçim.
4. **Biçim:** sahnenin iskeletini kişiliğe göre değiştirmek.

---

## C. Öneri: üç oda için ortak bir "konuşma dilbilgisi"

### C1. Tek model, üç oda
Satış, seed ve VC aynı dört parçayı paylaşır; farkları yalnız içerikte olur:
- **Slot sırası (iskelet)**, kişiliğe göre değişir.
- **Havuzlar:** her slota aday satırlar.
- **Seçim kuralı:**
  1. Koşulu tutan adaylar alınır.
  2. En çok koşula sahip olan kazanır (özel satır genel satırı ezer).
  3. Eşitlikte bu koşuda en uzun süredir söylenmemiş olan seçilir.
  4. Hâlâ eşitse şirkete ya da fona bağlı tohum kullanılır. Gün tohumu kullanılmaz.
- **Hafıza:** söylenen her satır kaydedilir. Koşu hafızası (kaç kez, en son ne zaman), şirket hafızası ve fon hafızası ayrı tutulur.

**Altyapı için yeniden kullanım:** Satırların koşulları, olay motorunun koşul değerlendiricisiyle (`EvCondition` / `EventGate.condition_met`) ve toplantının kendi "fact" sözlüğüyle (`SalesProbes.facts_for`, VC tarafında `_conviction_*` sebepleri) yazılabilir. Havuzlar kart gibi JSON veri olur ve lint'ten geçer; yeni bir motor gerekmez.

### C2. Eklenecek slotlar (üç odada)

| Slot | Ne yapar | Kaynak |
|---|---|---|
| **Açılış** | Karşı taraf seni ne biliyorsa onu söyleyerek başlar: haber, referans müşteri, önceki toplantı, Frank'in tanıştırması | GDD §10 örneği, ¶119 |
| **Tepki** (en önemlisi) | Her cevaptan sonra kısa satır: cevap tipi × sonuç bandı × kişilik | GDD ¶67 ana geri bildirim |
| **Konu geçişi** | "Peki, başka bir şey…" türü köprü; bazen karşı taraf konuyu kendisi değiştirir | ¶65 biçim değişir |
| **Kapanış** | Kazanç: gerekçeli ve koltuk sayısını söyler. Kayıp: sebebi söyler; iki ile üç varyant | ¶70 |
| **İç ses** | Bütçeli ve somut gözlem; hatası düzeltilip görünür yapılır | ¶68 |
| **Çıkışta Frank** (yalnız VC) | Soğuk çıkışta tek satır. Frank korpusu Erdem'in; satırları Erdem yazar | VC tasarım §4 |

### C3. Biçim çeşitliliği: iskelet kişiliğe göre değişir

**Satış, arketip mizacına göre:**
- *Hızlı* (finance_brisk): önce fiyat sorusu; soru sayısı bir kısa; erken "rakamı konuşalım".
- *Temkinli* (ops_cautious): kararlılık derinliği; referans ister, tanıdık müşteri adı duyunca yumuşar.
- *Titiz* (tech_exacting): merdiven ve kilitli kademe; yanlış bir "güç göster" cevabı sahneyi keser.
- **GDD'nin istediği 6–8 arketibe çıkış:** mevcut 3 arketibe şu 3–4 aday eklenir. Her birinin oynanışı değiştirmesi şart (§11.1).
  - Satın alma birimi (bürokratik; belge ve süreç sorar).
  - Kurucu-sahip (duygusal; güven sorar, sen'e geçer).
  - Kurumsal BT (güvenlik ve sağlayıcı).
  - Fiyat avcısı (pazarlıkta sabırsız, düşük kızgınlık eşiği).
- **Balina ve geri dönen şirket:**
  - Balinanın şartı masada sorulan ilk konu olur.
  - Geri dönen şirket geçen seferki sebebi anarak açar ("Geçen sefer kesintileri konuşmuştuk. Değişen ne?").
  - Hafıza satırı her soruda değil, yalnız açılışta görünür.
- **Soru havuzu 8'den 14–16'ya çıkar.** Adaylar: entegrasyon, veri taşıma, eğitim, sözleşme süresi, referans müşteri, fiyat artışı geçmişi, rakip karşılaştırması ("X firması daha ucuz"; rakip sistemi okunur).

**VC, fon kişiliğine göre** (ch09 §1: "each VC archetype weights the inputs differently"):
- Vuruşlar sabit dört adım olmaz; fonun sırası değişir:
  - *Anchor* (rakam): doğrudan metrikle açar, anlatı vuruşu kısa, sorgu iki soru.
  - *Nexus* (ekip): kurucuyu ve ekibi sorar; "odayı oku" uzun.
  - *Bosphorus* (ilişki): Frank üzerinden ve hikâyeyle açar; sorgu yumuşak ama tek soruda derine iner.
  - *Meridian* (ürün): canlı demo vuruşu (ürün ekseni okunur); sabırsızdır.
- **Soru ön-sezdirmesi (tasarımın istediği):** "Odayı oku" başarılıysa sorgunun konusu önceden görünür ("Churn'ü soracak"). Oyuncu hazırlıklı girer.
- **Soru havuzu:** fon başına 3'ten 5–6'ya çıkar. Aynı zayıflık farklı fonda farklı cümleyle ve farklı açıdan sorulur. Aynı fona ikinci kez girildiğinde sorulmamış soru öne geçer.
- **Tepki satırları:** fon başına 3 bant × 3 varyant.
- **Kapanış:** fonun sesiyle, gerekçeli.

**Seed:**
- Açılış "Otur. Yarım saatimiz var." yerine fon başına 2–3 açılış.
- Soru havuzu fon başına 2'den 4'e çıkar. Seed, VC'nin küçük ve daha samimi versiyonu; sen/siz geçişi burada kazanılabilir.

**Term sheet masası:**
- Yatırımcı fon sesiyle konuşur: her itiş sonucuna tepki, 2–3 varyant.
- Frank'in satırları masa durumuna ek olarak fonu da okur ("Anchor kontrolü sever, koltuğu zorlama" gibi). Bu satırları Erdem yazar.

### C4. Hafıza (ch09 §6 ve Satış §9)
- **Şirket hafızası:** kayıp sebebi zaten tutuluyor. Buna eklenecekler: hakaret, masadan kalkma, imzalı referans. Açılış ve tepki bunları okur.
- **Fon hafızası (ch09 §6):**
  - Durumlar: seed'i açtı / geri çevirdi / sen geri çevirdin / sert pazarlık yaptın.
  - Geri çeviren fon, rakamlar değiştiyse geri dönebilir (bugün kalıcı olarak kapanıyor).
  - Dönüşte açılış geçmişi anar.
- **Koşu hafızası:** `sales_line_memory` evet/hayır yerine sayı ve son gün tutar. En son kullanılana göre seçimi besler.

### C5. İçerik bütçesi (EN önce, TR lokalizasyon)

| Oda | Slotlar | Yaklaşık satır (EN) |
|---|---|---|
| Satış | açılış 6 arketip × 3; soru 14 × 2 ifade; cevap ~40; tepki (5 cevap tipi × 3 bant × 2) + arketip özel ~30; kapanış kazanç 6 × 2, kayıp 5 × 3; iç ses 12; hafıza 8 | ~230 |
| VC | 4 fon × (açılış 3, anlatı sorusu 2, sorgu 6, tepki 9, kapanış 4) + ön-sezdirme 12 | ~110 |
| Seed | 4 fon × (açılış 2, sorgu 4, tepki 6, kapanış 3) | ~60 |
| Masa | 4 fon × yatırımcı 6 + Frank (Erdem) | ~25 + Frank |
| **Toplam** | | **~425 satır × 2 dil** |

Bu, iki aşamalı bir yazım turu demek:
1. **MVP:** tepki, açılış ve kapanış slotları + VC fon sesleri. Yaklaşık 150 satır; tekrar hissinin çoğunu keser.
2. **Derinlik:** yeni arketipler, soru havuzları ve hafıza satırları.

Ölçüt GDD §11.6: 30 toplantılık simülasyonda yüksek frekanslı hiçbir satır 2 kereden fazla görünmez. Aracı yazım turunda kurulur; şimdi test yok.

---

## D. Series A kapanışı: değişiklik önerileri

**D1. Kapı yalnız MRR'a bağlanır (Erdem'in kararı, ch08 §5 ile uyumlu).**
- Büyüme serisi ve marka tabanı kapı şartından çıkar.
- Büyüme, ch08'in dediği gibi "kapının açılıp açılmadığını değil, koşulları" belirler. Bu yol kodda zaten var: değerleme çarpanı, son üç ayın büyüme bandından (8/11/14×) geliyor.
- Marka, görüşme inancına etkisiyle yaşamaya devam eder.
- Kapı eşiği 120K$ bandında kalabilir; ölçümde 237–491. günler arasında aşılıyor. Karar: bandın ortası mı, tabanı (100K$) mı.

**D2. Kapı göstergesi.** ch08 §5 çip, ilerleme çubuğu ve yüzde istemiyor; tek satır Frank sesi istiyor. Bugün çip, ODA'da çubuk ve "büyüme n/3 ay" gösteriliyor. Büyüme şartı kalkınca "n/3" zaten anlamsızlaşır.
- **Önerim:** çip kalsın (okunurluk) ama çubuk ve sayı kalksın, yerine Frank'in tek satırı gelsin. Bu satırları Erdem yazar.

**D3. Görüşme, churn ve marjı okusun (ch09 §4).** Bugün inanç yalnız MRR, marka, runway ve skandalı okuyor. Önerilen ekler:
- son üç ayın büyümesi (serinin yerini alır);
- churn oranı;
- brüt marj (altyapı faturası sonrası).

Böylece büyüme kapıdan çıkınca masada anlam kazanır.

**D4. Term sheet masası: ch09 §5 ile uyum.**
- GDD'nin istediği: kabul / bir kez pazarlık (fon yürüyebilir ya da şartları sertleştirebilir) / red.
- Bugünkü durum: sabır havuzuyla çoklu itiş; fon hiç yürümüyor, şartları hiç sertleştirmüyor.
- **Önerim:** çoklu itiş kalsın ama sabır bittiğinde fonun iki yanıtı olsun:
  - "son teklif" (bugünkü);
  - kişiliğe göre şart sertleştirme (Anchor koltuk ister) ya da masadan kalkma.
- Kilometre taşı maddesi (milestone clause) Series B'ye köprü olarak eklenir.

**D5. Reddedilme zinciri (ch09 §4 "üst üste üç").** Bugün sayım kümülatif, masadan kalkmak da sayılıyor ve bağlanmamış pivot mandalı zinciri engelliyor. Öneri:
- sayım "üst üste" olsun;
- oyuncunun kendi masadan kalkması sayılmasın;
- pivot mandalı ya bağlansın ya kaldırılsın.

**D6. Fon ilişkileri (ch09 §6).**
- Geri çeviren fon, MRR belirgin artınca (ör. +%30) yeniden görüşmeye açılır.
- Frank'in tanıştırması statik bir bayrak değil, oynanan bir karar olur. Frank'in bu yüzeyini Erdem yazar.

**D7. Kapanış sonu.** ch09 §7'ye göre alınan şartlar Frank'in hüküm satırını da değiştirmeli. Bugün "founder-friendly" ve "aggressive" için aynı satır var ve içinde uzun tire var. Frank korpusu olduğu için Erdem'in işi.

**D8. Kapanış penceresi (ch01 §2 "a closing window (rival/market)").** Kurulmamış. Öneri: rakip bir tur açıklayınca kısa bir "pencere" başlar (inanç +, süre sınırlı). Rakip sistemi gelince; şimdilik not.

**D9. Hatalar (bu turda düzeltilmedi, listeleniyor):**
- **Seed masası satırları Series A kaldıraçlarını çiziyor.** `term_sheet_table_system.gd:304, 126` `LEVERS`'ı kullanıyor, `levers()`'ı değil. Seed "raise" satırı seçilemiyor, yanlış kaldıraç itilebiliyor. **Kritik.**
- Temiz soruda gösterilen oran, atılan zarla eşleşmiyor (`vc_pitch_system.gd:292, 805`).
- Seed görüşmesinden ilk vuruşta çekilmek tek seed hakkını yakıyor (`seed_round_system.gd:111`).
- Satış iç sesi hiç görünmüyor (`view_state` iki kez çağrılıyor).
- Oda sanatı hep aynı; `locked_tier2` satırında sabit kodlanmış Türkçe metin var.

---

## E. Önerilen sıra

1. **Karar oturumu (Erdem, ~30 dk):** D1–D6 (kapı, gösterge, görüşme girdileri, masa modeli, zincir, fon ilişkileri) ve C3'teki arketip listesi.
2. **Hata düzeltme turu:** D9. Küçük iş; özellikle seed masası kritik.
3. **Konuşma altyapısı:** C1–C2. Slotlar, havuz seçimi, hafıza; mevcut koşul değerlendiricisi yeniden kullanılır.
4. **Yazım turu 1 (MVP):** tepki, açılış ve kapanış slotları + 4 fonun sesi. ~150 satır, EN önce.
5. **Kapı ve masa değişiklikleri (D1–D5)** ve ardından ölçüm.
6. **Yazım turu 2:** yeni arketipler, soru havuzları, hafıza satırları.

---
