> **Kaynak:** cloud session, 2026-09-25. Açık kararlar araştırması.
> **Durum:** HİÇBİR MADDE UYGULANMADI.
> **Kural:** "Sahip yorumu" sütunu dolmadan bu belgedeki hiçbir maddeye dokunulmaz.

# Açık kararlar araştırması: K14 · K16 · K20–K22 · K24 · K32 · Frank aralığı

**Bu belge ne:**
- Altı açık başlık için araştırma ve öneri. Uygulama yok; onaylarsan uygulanır.
- Kaynaklar:
  - GDD ch08 §5, ch09 §2–§7, ch13 §1 ve §7;
  - kod: `endings_system.gd`, `seed_round_system.gd`, `seed_constants.gd`, `vc_pitch_system.gd`, `term_sheet_table_system.gd`;
  - `docs/writing/FRANK_UNWIRED.md`;
  - Frank'in mevcut satırları (`strings.csv`);
  - 5 ölçüm koşusunun logları (`scratchpad/runs/final_*.log`).

## 0. Önce üç bulgu (kararları değiştiriyor)

**B1. GDD ile kod bir yerde çelişiyor.**
- ch13 §1: *"CUT: acquisition."* (onay tarihi 2026-08-20)
- Ama 2026-08-27'de senin Frank v6 metninle satın alma kartı (`funding.acquisition_offer`) bağlandı ve çalışır durumda.
- Hangisi geçerli? Buna sen karar vermelisin. K16'nın cevabı buna bağlı (§2).

**B2. Ekonomi, "yüzleşme" kararını çok ağırlaştırıyor.**
- Ölçüm koşularında kapı açıldığında (261–442. günler) durum şu:
  - kârlı ay serisi 9–10;
  - marj yaklaşık %75. Örnek, tohum 1, 305. gün: gelir 116.659, gider 28.447.
- Yani `profitable_bootstrap`'ın beş şartından dördü zaten karşılanmış; eksik olan tek şart "Series A kararıyla yüzleşti" (`faced_ok`).
- Sonuç: yüzleşme sayılan her şey (masadan kalkmak, reddetmek) **ertesi gün koşuyu bootstrap zaferiyle bitiriyor**. Tarama sırasında bootstrap, satın alma penceresinden önce geliyor.
- Bu yüzden bugünkü ekonomide satın alma teklifi pratikte hiç görünmez.
- Bu bir kalibrasyon sorunu. ch08 §2 "marj ölçekle görünür biçimde düşmeli" diyor, ölçüm tersini gösteriyor. Ayrı bir iş olarak not ediyorum, burada çözmüyorum.

**B3. Seed'in "garanti basamak" olması senin 2026-08-27 hükmün; Frank'in metni de buna dayanıyor.**
- Kanıtlar:
  - `SEED_FRANK_OPENING`: "Teklif duruyor, kaçmıyor."
  - `SEED_FRANK_FINAL`: "…bu turu imzalıyoruz."
  - `seed_constants.gd:131`: "ruling 6 — the rung is guaranteed".
  - Seed masasında kalkma butonu "ZOR MOD" diye kilitli (Frank'in çeki gibi).
- K22'nin ("şimdi değil") cevabı bu yüzden "hayır".

## 1. K14: Reddedilme zinciri ve pivot mandalı

**Bugün:**
- Sayım kümülatif (`vc_rejections`, `endings_system.gd:190`).
- MRR ≥ 2.000$ ve nakit > 0 ise sessizce `pivot_offer_made` yazılıyor (`:205-212`). Bu mandalın kartı Frank v6'da satın alma kartına birleştirildi; birleşme sonrası bu yoldan hiçbir şey açılmıyor.
- Sonuç: sağlıklı bir şirkette zincir **hiç** çalışmıyor.
- Av sekmesindeki telgraf ise çalışıyor: `HUNT_FRANK_LINE` "Kapanan masa: {n}. Üçüncüde yol biter."

**Tasarım dayanakları:**
- ch09 §4: *"three in a row can reach vc_rejection_cascade"*, yani **üst üste**.
- ch13 §1: *"kept in v1, hard to reach in the demo."*
- Senin telgraf cümlen "yol biter" diyor, "oyun biter" demiyor.

**Öneri: "yol biter" ile "oyun biter"i ayır.**
1. **Sayım üst üste:** her Series A görüşme reddi +1. Bir teklif alındığında (sheet verildiğinde) sayaç 0'a döner.
   - Masada fonun kalkması (K12) da bir red, sayılır.
   - Oyuncunun kalkması ve K10'da reddetmesi sayılmaz (K11 ile aynı mantık).
   - Seed odası reddedemediği için seed zincire girmez. Bu, ch09 §9'daki açık soruyu da kapatır.
2. **Üçüncü redde yol kapanır.** Canlı teklif, bekleyen teklif ya da görüşme varken beklenir (bugünkü kural).
3. **Şirket sağlamsa** (MRR ≥ `PIVOT_MRR_MIN` ve kepenk yok):
   - oyun bitmez;
   - Series A yolu kapanır (`pivot_used`, bugünkü `on_pivot_accepted` davranışı);
   - Frank bir satırla bunu söyler (§6'da taslak F5);
   - Av sekmesinde mevcut "yol kapandı" satırı görünür;
   - koşu bootstrap ve 730. gün sonuna doğru devam eder.
4. **Şirket de çöküyorsa** (MRR tabanın altında ya da kepenk başlamışsa): `vc_rejection_cascade` sonu gelir, telgrafı `HUNT_FRANK_LINE`.
5. Sessiz `pivot_offer_made` mandalı silinir.

**Neden:** ch13'ün "demo'da zor ulaşılır" dediği son korunuyor. Sağlıklı bir şirket üç redle ölmüyor, ama cezası gerçek: Series A artık yok. Senin "Üçüncüde yol biter" cümlen de harfiyen doğru oluyor.

**Dosyalar:**
- `endings_system.gd` (`_check_vc_cascade`);
- `vc_pitch_system.gd`: red sayacının yazıldığı yerler ve teklif verilince sıfırlama;
- `strings.csv`: F5.

## 2. K16: Satın alma koşulu

**Önce B1 cevaplanmalı.**
- **Satın alma v1'de yoksa (ch13):** kart kapatılır (tetik koşulu kalıcı false), `acquisition` sonu listede kalır ama ulaşılmaz, ch13 aynen geçerli.
- **Satın alma v1'de varsa** (Frank v6 kartı; ch13 güncellenmeli), önerim şu.

**"Yol bitti" (`road_over`) şu durumların herhangi birinde doğru olsun** (bugün yalnız masadan kalkma):
1. Oyuncu masadan kalktı (bugünkü).
2. Oyuncu K10'da teklifi reddetti.
3. Fon masadan kalktı (K12).
4. Bütün fonlar kapandı (reddetti ya da süresi doldu).
5. Üçüncü red yolu kapattı (K14, şirket sağlam).

Ortak şart bugünkü gibi: açık fon, canlı ya da bekleyen teklif, görüşme kalmamış olmalı. Böylece kartın mühürlü ilk cümlesi "Series A turu kapandı, ortada anlaşma yok" her durumda doğru kalıyor.

**Korunanlar:**
- `seed_taken` şartı. Arayan kişi seed'in lideri; seed yoksa arayacak kimse yok.
- 10 günlük pencere.

**B2 ile ilişkisi:** Şirket kârlıysa yol kapandığı an bootstrap zaferi gelir, satın alma yalnız kârlı olmayan şirketlere düşer. Bu tutarlı bir ayrım: kendi ayakları üstünde duran şirket kalır, duramayan satılır. Önerim bu sırayı bilinçli olarak korumak.

**ch13 §7'deki açık soru, "yüzleşme sayılan haller":**
- Önerim: yukarıdaki 1–5 artı **kapı davetini 3 kez reddetmek**. `gate_series_a` gövdesinin üç artan varyantı var; üçüncü "Henüz değil", oyuncunun bilinçli seçimi.
- 3 kez reddetmek bootstrap zaferini açar, ama Series A yolunu kapatmaz. Oyuncu daha sonra yine gidebilir; o zamana kadar zafer çoktan gelmiş olabilir.

**Dosyalar:**
- `endings_system.gd` (`road_over`, `profitability_signal`);
- `vc_pitch_system.gd` (`mark_faced_series_a` çağrı yerleri);
- `phase_gate_system.gd` (ret sayısı).

## 3. K20–K22: Seed

### K20. 1. vuruşta çekilmek tek hakkı yakıyor

**Bugün:**
- `begin_pitch` görüşmeden önce `seed_pitch_used = true` yazıyor (`seed_round_system.gd:111`).
- Yorumu: "mid-meeting quit cannot hand it back".
- Ama görüşmede kayıt zaten kapalı, yani önceki bir kaydı yüklemek hakkı geri veriyor. Kural yalnız dürüst oyuncuyu cezalandırıyor.
- Av şeridinde yatırımcı adı boş kalıyor.

**Öneri:**
- 1. vuruşta çekilmek hakkı **geri versin**, ama o fon seed için kapansın ("odadan çıktın").
- Ch09 §6 ilişki hafızasına "sen onları bıraktın" durumu yazılsın. Bu durum Series A'da o fonun inancını −5 düşürür.
- Böylece "odayı oku, beğenmezsen başka fona git" bir bedelle mümkün olur: bir fonu kaybedersin ve ilişki soğur. Bedava fon gezme olmaz.
- Çekilme onayında bu bedel yazsın; boş ad hatası düzelsin.

### K21. Seed yönetim kurulu (bugün kilitli)

**Dayanak:** ch09 §2 seed'in amacını "sonu önceden öğretmek" diye koyuyor. §5'e göre koşul ekseni (koltuk ve veto) aynı nesne. §7'ye göre alınan şartlar sonu değiştiriyor.

**Öneri: kalıcı yap.**
- `record_seed_round` koltuk ve veto bilgisini de yazsın. Finans'taki pay tablosunda görünsün: "Yönetim kurulu: {fon} 1 koltuk · veto".
- Seed masasında board satırının kilidi kalksın.
- Series A masasında yönetim kurulu satırı **toplamı** göstersin (seed koltuğu + yeni istenen). Sonun metni (K17) toplamı okusun.
- Yeni bir mekanik yok. Koltuğun bedeli görünür ve kalıcı olur, ama oyunun başka bir sistemine dokunmaz.

**Alternatif:** satırı seed masasından tamamen kaldırmak. Daha basit, ama seed'in "öğretme" amacı zayıflar.

### K22. Seed odası "şimdi değil" desin mi

**Öneri: hayır** (B3).
- Senin hükmün (garanti basamak) ve Frank'in mühürlü satırları buna dayanıyor.
- Oyuncunun seed'deki kararı K20 (fon değiştirme bedeli) ve K21 (koltuk pazarlığı) ile gerçek bir karara dönüşüyor.
- ch09 §3'ün "decline" maddesi (bootstrap yolu) zaten K19 olarak ayrı duruyor; bu listede değil.

## 4. K24: Görüşmenin girdileri ve MRR ölçütü

**Bugün:**
- Series A inancı MRR / 40K oranını okuyor ve oran 1,5'te kırpılıyor; 60K'da doyuyor (`vc_pitch_system.gd:166`).
- Kapıya gelen herkes MRR teriminde +20 ile, yani tavandan başlıyor.
- Büyüme, churn ve marj hiç okunmuyor.
- Beat 3 sorusu kümülatif kayıp sayacına bakıyor, bu yüzden churn sorusu neredeyse her zaman geliyor.

**Tasarım dayanakları:**
- ch08 §5: *"the door is MRR only; growth, churn and margin decide how the meeting goes and what terms come out."*
- ch09 §4: *"Each VC archetype weights the inputs differently."*

**Veri hazır, yeni ölçüm gerekmiyor:**

| Girdi | Kaynak |
|---|---|
| Büyüme | `GameState.get_mom_growth_avg_pct(3)` (değerleme bandının okuduğu aynı ortalama) |
| Churn | `month_history[].customers_lost` farkı, son 3 kapanış, dönem başı hesap sayısına bölünür |
| Marj | `GameState.get_window_margin_pct(3)` |
| Ürün | hata sayısı, kalite eksenleri (E uyumunun okuduğu aynı alanlar) |
| Ekip | geliştirici sayısı, kadro |

**Öneri:** MRR seviyesi terimi kalkar, yerine fonun ağırlıklandırdığı beş girdi gelir. Her girdi −1 ile +1 arasına normalleşir.

| Girdi | −1 | 0 | +1 |
|---|---|---|---|
| Büyüme (3 aylık ort.) | ≤ %0 | %5 | ≥ %20 |
| Churn (3 ay, hesap oranı) | ≥ %15 | %5 | %0 |
| Brüt marj (3 ay) | ≤ %0 | %30 | ≥ %60 |
| Ürün | canlı hata ve zayıf eksen | — | hatasız, bütün eksenler ≥ 40 |
| Ölçek (MRR / kapı) | — | 1,0× | ≥ 2,0× |

Fon ağırlıkları (±1'deki puan, [ÇALIŞMA]):

| Fon | Büyüme | Churn | Marj | Ürün | Ölçek | Ekip |
|---|---|---|---|---|---|---|
| Anchor (metrik) | 10 | 10 | 6 | 2 | 4 | 0 |
| Nexus (ekip) | 4 | 4 | 4 | 2 | 2 | 8 |
| Bosphorus (anlatı) | 6 | 2 | 2 | 2 | 6 | 2 |
| Meridian (ürün) | 4 | 8 | 4 | 10 | 2 | 0 |

- Bosphorus'un marka ve sıcak tanıştırma terimleri kalır. Karizma zaten vuruş zarlarında.
- **Beat 3 sorusu**, o fonun ağırlıklı en zayıf girdisinden seçilir. Churn sorusu gerçek bir churn oranına bakar, growth_flat sorusu büyüme < %5 olunca gelir. Böylece "sorulacak soru"yu oyuncu kendi rakamlarından okuyabilir.
- **"Neden" satırları** (`VC_WHY_*`) ağırlıklı en büyük iki girdiyi söyler. Yeni anahtarlar gerekecek: büyüme, churn ve marj için iyi/zayıf, TR+EN.
- **Seed odası:** aynı girdiler, seed ağırlıklarıyla (kurucu ağırlıklı, ruling 2). MRR ölçütü kapıda kalır (20K).

**Kalibrasyon uyarısı (B2):**
- Bugünkü koşularda marj her zaman +1. Büyüme %11–14, yani 0 ile +0,6 arası.
- Ortalama inanç bugünkünden birkaç puan düşer, dağılım genişler. `CONV_BASE` bir kez ölçümle ayarlanmalı (5 tohum).

**Dosyalar:**
- `vc_pitch_system.gd` (`_conviction_series_a`, `_conviction_seed`, `_sorgu_*`);
- `pitch_constants.gd` ve `seed_constants.gd` (tek ayar bloğu);
- `strings.csv`.

## 5. Frank'in yaklaşma satırları arasındaki aralık

**Ölçüm (5 koşu):**
- Frank bir koşuda 22–25 kart konuşuyor.
- Yaklaşma satırları, sürüm çıkışındaki Frank satırlarıyla bir gün arayla üst üste biniyor. Örnekler: 227/228 ve 247/248.
- Beş koşunun beşinde de "kapı açıldı" satırı ile `gate_series_a` art arda iki günde geliyor.
- Neden: kartlar `critical` etiketli, bu yüzden haftalık funding kotası (7 günde 1) onlara uygulanmıyor.

**Dayanak:** ch08 §5 bu bilgiyi açılır pencere olarak değil, **Finans'ta tek satırlık Frank notu** olarak tasarlamış ("KAPALI/ISINIYOR/AÇIK çipinin yerine", ilerleme çubuğu yok, yüzde yok). Bu not hiç yapılmadı.

**Öneri A (tercihim):**
1. %50, %75 ve %90 satırları **Finans'taki Frank notuna** taşınır. Not sessizce güncellenir, açılır pencere çıkmaz; yalnız sekmede küçük bir "yeni" işareti belirir.
   - Not seed kapısında da çalışır (ch08 §5 iki kapıyı da kapsıyor).
   - Senin ch08'deki satırların ("Yirmi beş binin altında kimse telefonu açmaz." vb.) kapalı ve ısınıyor durumlarını doldurur.
2. **"Kapı açıldı" açılır pencere olarak kalır.** `gate_series_a` en erken **3 gün** sonra gelir. Aynı hafta iki Frank penceresi olmaz; oyuncu kapıyı gördükten sonra düşünme payı kalır.
3. Çip kalır (K3 kararı). Not, çipin yanındaki satır olur.

**Öneri B (açılır pencere kalsın istersen):**
- Yaklaşma kartlarına iki koşul eklenir:
  - son 7 günde başka Frank kartı konuşmamış olmalı;
  - önceki yaklaşma satırından bu yana en az 14 gün geçmiş olmalı.
- Bantlar "tam bu adım" yerine "en az bu adım ve sonraki satır henüz konuşmadı" olur. Böylece gecikmiş satır atlanmaz, geç gelir.
- `gate_series_a` yine en erken 3 gün sonra.

## 6. K32: Frank'in kalan yüzeyleri (taslak, önce EN, TR yerelleştirme; hepsini sen düzeltirsin)

**Ses referansı:** `TERM_FRANK_*`, `SEED_FRANK_*`, `seed_closed`. Kısa, "biz" diliyle, pratik, duygusuz ama sahiplenen.

| # | Yüzey | EN | TR |
|---|---|---|---|
| F1 | K10 karar kartı (bugün konuşmacısız) | "They gave us ten working days. Sit down or say no. Don't make them ask twice." | "On iş günü verdiler. Ya masaya otur ya hayır de. İkinci kez sordurma." |
| F2 | Fon masadan kalktı (K12) | "They left. That's what happens when you ask for more than they came with." | "Kalktılar. Getirdiklerinden fazlasını isteyince böyle olur." |
| F3 | "Diğer teklifi göster" (K7) | "Now they know. Watch what they do with it." | "Artık biliyorlar. Bakalım ne yapacaklar." |
| F4a | Masa açılışı · Anchor | "Anchor cares about control more than price. Give on the number, hold on the seat." | "Anchor için kontrol fiyattan önemli. Rakamda esne, koltukta dur." |
| F4b | Masa açılışı · Nexus | "Nexus is slow and remembers everything. Don't push the same thing twice." | "Nexus yavaş karar verir, hiçbir şeyi unutmaz. Aynı şeyi iki kez zorlama." |
| F4c | Masa açılışı · Bosphorus | "Bosphorus bought the story. If you push, push on the board, not the money." | "Bosphorus hikâyeyi aldı. Zorlayacaksan paraya değil, kurula yüklen." |
| F4d | Masa açılışı · Meridian | "Meridian has three more meetings this week. Get to the point." | "Meridian'ın bu hafta üç görüşmesi daha var. Sadede gel." |
| F5 | Yol kapandı (K14, üçüncü red, şirket sağlam) | "That was the third. No more tables this year. The company is still standing, and so are you." | "Bu üçüncüydü. Bu yıl başka masa yok. Şirket ayakta, sen de ayaktasın." |
| F6 | Seed'de 1. vuruşta çekilme onayı (K20) | "Walk out now and this fund is done with us for the seed. The others are still there." | "Şimdi çıkarsan bu fon seed'de bizimle işini bitirir. Diğerleri hâlâ orada." |

**Notlar:**
- F4a–d mevcut `TERM_FRANK_OPENING`'in ("İlk teklifleri bu. Zorla.") fona özel varyantlarıdır; eşleşme olmazsa genel satır çıkar.
- K17 kapanış hükmü (şartlara göre) bu listede yok, çünkü sormadın. İstersen onu da yazarım.
- `FRANK_UNWIRED.md` §4'teki "teklif e-postası" akışı (e-posta, 3 gün, 30 günlük sayaç) senin eski tasarımın. K5 ve K10 ile çelişiyor. Önerim: o akış emekliye ayrılsın, metni (`VC_EV_DEAL_*`) K10 kartına ya da teklifin geldiği ana taşınsın. Karar senin.

## 7. Karar listesi (evet / hayır / başka)

| # | Karar | Önerim | İnceleme notu | Sahip yorumu |
|---|---|---|---|---|
| D1 | Satın alma v1'de var mı? (B1) | Karar senin. Varsa ch13 güncellenir. | öneri "satın alma v1'de VAR". ch13'teki CUT kararı 31 Ağustos kapsam değişikliğinden önceydi. Onaylanırsa ch13 §1 güncellenir. | |
| D2 | K14: sayım üst üste; teklif sayacı sıfırlar; üçüncü red "yol biter"; şirket çöküyorsa `vc_rejection_cascade` | Evet |  | |
| D3 | K14: sessiz pivot mandalı silinir | Evet |  | |
| D4 | K16: "yol bitti" 5 hali kapsar (kalkma, K10 reddi, fonun kalkması, bütün fonlar kapandı, üçüncü red) | Evet (D1 = var ise) |  | |
| D5 | ch13 §7: yüzleşme = D4'teki haller + kapıyı 3 kez reddetmek | Evet | HANDOFF D bölümündeki gazete ve son kararına bağlı (bootstrap artık kilometre taşı olabilir). O karar netleşmeden uygulanmaz. | |
| D6 | K20: 1. vuruşta çekilmek hakkı geri verir, o fon seed'de kapanır, Series A'da −5 | Evet |  | |
| D7 | K21: seed koltuk ve vetosu kalıcı, pay tablosunda görünür, Series A masasında toplam | Evet |  | |
| D8 | K22: seed odası "şimdi değil" demez | Evet (hayır demez) |  | |
| D9 | K24: MRR seviyesi yerine fon ağırlıklı beş girdi; Beat 3 sorusu en zayıf girdiden | Evet | Eksikler: (1) Ekip girdisinin −1/0/+1 tanımı yok. (2) Ürün girdisinin 0 değeri tanımsız. (3) Marj bugünkü ekonomide her zaman +1, bilgi taşımıyor. (4) CONV_BASE ayarı HANDOFF C ölçümünden sonra yapılır. | |
| D10 | Frank aralığı: Öneri A (Finans notu + kapı penceresi + 3 gün) ya da B | A |  | |
| D11 | F1–F6 taslakları | Senin düzeltmenle | (1) Hepsi TR önce yeniden yazılacak. (2) F4 satırları E modelinden türetilmeli. F4c, Bosphorus'a karşı en pahalı hamleyi öğütlüyor: board Bosphorus'un kendi kaldıracı. F4a, Anchor'ı kontrol odaklı anlatıyor, ama K7'de Anchor değerlemeye bakıyor; ya satır ya model değişecek. (3) F5 "bu yıl" diyerek dönüş vaat ediyor, oysa D2'de yol kalıcı kapanıyor. (4) F2 suçlayıcı; kısaltılacak. | |
| D12 | Eski "teklif e-postası" akışını emekliye ayır | Evet |  | |
| D13 | B2 kalibrasyonu (marj %75, bootstrap anında geliyor) ayrı bir iş olarak açılsın | Evet |  | |

**Uygulama sırası (onaylarsan):**
1. D2–D5 (sonlar ve zincir).
2. D6–D8 (seed).
3. D9 (görüşme girdileri) ve ölçüm.
4. D10–D12 (Frank ve Finans notu).

**Doğrulama:**
- Her adımda lint, loc ve ilgili smoke vakaları (haiku).
- D9 sonrası 5 tohumla `--run-log` ölçümü: inanç dağılımı, teklif oranı, kapı günü.

---



## 8. E modeli: ölçüm isteği (inceleme notu)

- Sorun: Başlangıç E=70 ve sabrı 2 olan fonlar (Bosphorus, Meridian; kalkma eşiği 55) iki başarısız itişte masadan kalkıyor.
- Ölçüm hedefi: saf bir oyuncuda masaların en fazla yaklaşık %25'i kalkmayla bitsin.
- Lokal agent ölçer ve raporlar; sabitleri değiştirmez.
- Sabitler: `term_sheet_table_system.gd` EAGERNESS bloğu. Değerleri PUSH_ONCESI_KONTROL.md §7'de.
