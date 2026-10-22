# A5 · Bizde ne var: Erdem'in vizyonu ile elimizdeki tasarım, kod ve açık işler
2026-10-19 · salt okunur iç inceleme (searches=0) · kod `main` @ `9a0dff9c`; çalışma ağacı kirli (Faz Q sürüyor), ona dokunulmadı.
Etiketler: [kod] dosya:satır okundu · [belge] belgede yazılı · [hesap] ben hesapladım · [çıkarım] kanıttan çıkardığım yorum · [kanıtsız] ölçüm ya da kaynak yok · [bulamadım].
Bot sayıları `R15_BIZIM_DONGU.md`'den (10 tohum, bot "hızlı ve düşünmeyen" oyuncu); insan oturumu yok (R15 §1.5).

## 0. Özet (bulgu sırasıyla, en önemlisi önce)
1. **Erdem'in "1-2 uzaktan çalışan" isteği bugünkü kodun davranışıdır.** Evde işe alımın masa sınırı yok (`HRSearchSystem.can_start` yalnız "aynı anda tek arama" der, `hr_search_system.gd:61-63`) ve Ev'deyken alınan çalışan eve gelmez, uzaktan çalışır (`office_people.gd:11-12`; sahip kararı 9, 2026-09-28). Çelişki kodda değil planda: Faz C'nin C9'u ("masa sayısı işe alım tavanı, Ev 1 masa, ilk çalışan İş hanı") henüz yazılmadı ve 2026-10-19'da askıya alındı (`c_taslak/PLAN_C.md:101`). Düzeltmenin bedeli sıfır: kod yok.
2. **Aynı istek yeni değil.** 31 Ağustos "Oyun Vizyonu v1" belgesinin (Erdem) yanıt dosyası git'te duruyor (`6e3e190:project-unicorn/docs/design/VIZYON_v1_YANITLAR.md`). Orada uzaktan çalışan formülü ve "P1'de remote tavanı 2 (ev tek masa: sen + iki ekran)" (#6), üç perde (Perde 1 mikro, Perde 3 yönetim kurulu), Series A'nın son değil geçiş olması, Series B, IPO, yetki devri, haber motoru, rakip savaşı var. Belgenin kendisi repoda yok, yanıt onay almadı, 26 Eylül'de silindi (`79152570`). Bugün kodda iki iz kaldı: `endings_system.gd:353-356` ("Series A, Perde 3 oynanabilir olana kadar her build'de son") ve `ACIK_KARARLAR.md:897, 1963`.
3. **"Birinci saat ile 20. saat farklı olsun" vaadinin 20. saati bugün tasarlı değil.** Oyun Series A imzasında biter (her build, `endings_system.gd:353-356`); yumuşak tavan 104 hafta, 1×'te saf saat 39 dk (`GUNCELLEMELER.md` ch14 §1). Bot Series A'yı 21-27 dk saf saatte imzalıyor. GDD'nin Series A sonrası için söylediği: kilitli-görünür IPO, Series B, ikinci ürün; "Full release adds: IPO, Series B, makro ekonomi, diplomasi katmanı" (ch14 §5). VP, lobicilik, hisse alma, devir zinciri için tasarım yok; yalnız alan rezervleri var (§4).
4. **"Ofis fiilen seed'e bağlı" algısı bugün yanlış, Faz C'den sonra doğru olacak.** Bugün İş hanı şartı Frank'in çeki + kasada $6.500; taşınma bedelsiz, kira yok (`office_constants.gd:31-34`, `office_system.gd:46-54`). C kira $4.000/ay getirince ve ilk çalışanı İş hanı'na bağlayınca çek ile seed arasındaki dar pencereye ($4.000 + maaş) sabit gider biner. ACIK_KARARLAR 98 bunun sonucunu ölçmüş: bu pencereye eklenen her gider en az bir tohumu seed'den önce iflas ettirdi (iflas 30.-35. tikte; tik = hafta). Uzaktan işe alım bu riski kökünden kaldırır [çıkarım].
5. **Başlangıç kasası sorusunun yarısı Faz C ile kendiliğinden çözülüyor.** Bugün tek kurucunun gideri $1.500/ay araç tabanı (runway 6,6 ay, `finance_system.gd:12-15`). C bu satırı, kurucu maaşını ve servis giderini siliyor; MVP öncesi gider sıfır olur. Para ilk işe alımda ve kirada başlar. $50.000 sorusu "ilk işe alım kaç ay yaşatır" sorusudur (§5.3 tablo [hesap]). Zorluk kadranı zaten var: Kolay ×1,5 ($15.000), Normal $10.000, Zor ×0,6 (`founder_constants.gd:56-59`).
5b. **Veri uyuşmazlığı:** bot bugün en düşük kasayı $5.800-6.400 gösteriyor (R15 §4.6), yani para kıtlığı ölçmüyor; Erdem "başı çok zor" diyor. Zorluğun nedeni (para mı, ne yapacağını bilmemek mi) ölçülmedi [kanıtsız]. İlk saat insan oturumu bunu ayırır.
6. **Görev sistemi sorusu iki kez daraltılmış durumda.** "Görev yok, hiç kimseden" (Rakip PRD karar A, 2026-10-06) 2026-10-10'da "para verenin şartı serbest" diye daraltıldı ve Frank'in çeki 5 adımlı şart listesi olarak kodlandı (`cheque_read.gd:25-47`). Seed için 2 adım var (Traction, $20.000 MRR); seed yolu başlayınca ya da kapanınca liste boşalıyor ve TopBar "Sıradaki" yazacak bir şey bulamıyor: seed ile Series A arası ~40 hafta adlı hedef yok (`cheque_read.gd:20-23`, R15 §3.2). ONERI_TUR1'in "paranın şartı" omurgasından Garaj kısmı uygulandı, Çekiş (seed şartları) ve Masa (Series A odası okur) kısımları yapılmadı. "Frank'le rehberli başla" anahtarı onboarding'de var ama kilitli, çünkü `tutorial` etiketli sıfır kart var (`first_week_doc.gd:172-178`).
7. **Olay envanteri:** 128 demo kapsamlı + 1 EA kartı. Aşama bildirimine göre 71 kart her aşamada; yalnız Bootstrap 9, yalnız Traction 16, yalnız Series A 7. GDD'nin dokuz arkından yalnız biri (`soft_cap_stretch`) gerçek ark. Remote çalışan, ekipman, işe başlama, bordro, sözleşme konulu sıfır kart. "İlk kez kurucu" sürprizi işleyen yaklaşık 20 kart var (%15), çoğu şirketin tek kişilik olduğu evrede (§6).
8. **Erken oyun (bot, 1×):** MVP hf7 (2,6 dk), ilk imza hf9, Traction kapısı hf10, Frank çeki B2B hf12-13 / B2C hf22-24, seed B2B hf18-21 (6,8-7,9 dk) / B2C hf50-55 (19-21 dk), Series A kapısı hf58-60. Bot hiç ofis taşımıyor; ilk işe alımı çekten sonra yapıyor (§7).
9. **Dosya tarihi kontrolü:** 15 .docx'in tarihleri 19 Ağustos - 27 Eylül; 7 Ekim dökümlerinden sonra değişen .docx yok. Dökümden sonra değişen üç .md var: OLAY MOTORU rev 2 (125.942 → 205.445 B, 19 Ekim), ZAMAN MODELİ (50.972 → 57.550 B, 18 Ekim), GUNCELLEMELER (127.233 → 192.335 B, 18 Ekim). Bu üçü için canlı dosyayı okudum (motor md'sini tam okumadım, §9).

## 1. Erdem'in vizyonu, madde madde
Durum: **Tasarlı** (belgede kararlaştırılmış) · **Kısmen** · **Çelişir** · **Boş**. "Kod" sütunu bugünkü davranışı söyler.
| # | Vizyon maddesi | Tasarım (nerede) | Kod | Çelişen karar / not | Durum |
|---|---|---|---|---|---|
| 1 | 1. saat ile 20. saat farklı; her evre yeni kural | Evre başına baskı yasası: ch01 §5; "her evre yeni kural" OYNANIS_HUKMU §1.1; Perde 1/2/3 yalnız VIZYON yanıtında | Üç evre (Bootstrap/Traction/Series A) var; yeni kural evre geçişinde pazar beklentisi (Q) ve sonlu runway; Series A sonrası evre yok | Perde kavramı onaysız silinmiş belgede; "demo vaadi" ile "20 saat" arasında ürün ölçüsü tanımsız | **Kısmen** (ilk 40 dk tasarlı, 20 saat boş) |
| 2 | Başta her şeyi kurucu yönetir | ch02 §5 (kurucu her şeyi yapabilir, aynı anda yapamaz); Ekip GDD §2 | Kurucu satış, sprint, VC; solo sprint kartları (7); kurucu sprint puanı %80 (görüşme payı) | Kurucu enerji barı iptal (GUNCELLEMELER ch02 §6) | **Tasarlı, kodda** |
| 3 | Planlamayı PM'e devret | Faz D Karar 12 (çeyrek hedefi PM'siz de seçilir, devir PM'siz açılmaz); PRD_SPRINT B7 (devir yalnız aktif PM'e) | Bugün: devir PM'le açık, çeyrek yalnız PM'le (satır atıfları PRD_FAZ_D Karar 12'den: `sprint_system.gd:592-594`, `product_model.gd:411-413`; yeniden doğrulamadım); D kodlanmadı | Erdem 18 Ekim: "çeyrek hedefi PM'siz olabilir, devret PM'siz açılamaz" (uyumlu) | **Tasarlı, kodda kısmen** |
| 4 | Departmanlara VP alınır, VP rapor sunar | Yok. Atlas'ta "in-house İK" ve "Pazarlama" kilitli-görünür kartlar (Ekip GDD §10.6); ch14 §4 "Pazarlama/Operasyon Müdürü delegasyonu" EA; Loft'ta "VP odaları" yalnız oda adı (`office_constants.gd:57`); VIZYON yanıtı #8: İK Perde 3 başı | Rol kataloğunda VP yok (6 rol); EA takımı ertelendi (QCD D5); `coordination_for_lead` okuyucusuz (Faz D §7) | Ekip GDD §4.2: "uzun vadede liderlik işlerin otomatize edilmesinin yolu" tek cümle | **Boş** (iki kapı ucu, içerik yok) |
| 5 | Kurucu olaylarla meşgul, olaylar gidişatı etkiler | Motor GDD rev 2, ch11 (dokuz ark × 4-6 düğüm, sistem kenarlarına bağlı olay), ch11 §6 hafıza | Motor tam (`EventGate`, seam, bayrak hafızası); 128 kart; 1 gerçek ark | ch11 arkları kartlara dağıldı (`family` freni); kart hacmi ch14 hedefini (40-60) 2-3 kat aştı, ark sayısı 1/9 | **Kısmen** (motor hazır, yazım ince) |
| 6 | Diplomasi simülasyonumsu katman | ch14 §5 "diplomacy-style layer" Full release; başka tanım yok | Yok. Alt yapı: VC başına ilişki hafızası ve kalıcı kapanma (GUNCELLEMELER ch09 §6), `NegotiationSystem` tip-bağımsız masa | Piyasa PRD §3.9: "Perde 3 mekaniği burada tasarlanmaz" | **Boş** (tek satır GDD) |
| 7 | Series A→B'de ürün yaşam döngüsü çalışanlara devredilir | Ürün GDD §17: ikinci ürün slotu "KİLİTLİ · Series A sonrası"; Ar-Ge "ağaç şirkete aittir, EA'de ikinci ürün aynı ağaçtan çeker"; ch01 Series B kilitli-görünür | Sprint motoru tek ürün; ikinci ürün yok; Series A imzası koşuyu bitirir | Kod yorumu: Series A, Perde 3 oynanabilene kadar son | **Boş** |
| 8 | Plutocracy gibi lobicilik | Yok (Plutocracy repoda yalnız Piyasa maketi referansı ve "Perde 3 referans oyun", Rakip PRD hafıza kaydı 2026-10-06) | Yok. Piyasa PRD §3.9 alan rezervi: `shares_outstanding`, `free_float_pct`, `parent_company_id`, `delisted_week`, `mna` ShockLog türü (kullanılmıyor) | Piyasa kararı C: "oyuncu eylemleri çapalara asla geri beslemez" (hisse alma ile gerilim) | **Boş** (veri rezervi) |
| 9 | Ödül anı: kendi ürününün ödül kazanması, "o yılın en iyisi" (Software Inc. tadı); "ürünüm çok başarılı + yatırım" | Ürün ödülü ya da yıllık sıralama tasarımı yok. En yakın: sonlar gazetesi ve galeri (ch13), Piyasa'da şirket değeri, ödemeli `world.analyst_guide` ("alıcı rehberi") kartı | Sonlar ve gazete var; sanat yer tutucu, WISHLIST adresi boş (`ending_scene.gd:34,171`); ödül sistemi yok | Doruk formalite (9/10 imza, 0 zorlama, R15 §3.3) | **Boş** (kutlama anı yok; "yatırım alma" anı var ama formalite) |
| 10 | Kazancı yatırıma, altına, hisseye çevirme (Software Inc.) | Perde 3 rezervleri (hisse almak, rakip almak, oyuncu IPO'su, kurucu zengin listesi), Piyasa PRD §3.9 | Net değer satırı Kişisel'de; alım/satım yok | ch02 §10: kişisel nakit ve yaşam tarzı kademeleri kesik; milyarder listesi demo dışı, "sonra, büyük" | **Boş** |
| 11 | Orta oyun baskısı: yeni ofise geçince kira | Faz C Karar 3 (İş hanı $4.000, Plaza $8.000, Loft $18.000, masa=tavan, maaş ×1,5) | Kod yok: kira bugün 0, taşınma bedelsiz (`office_system.gd:46`); ACIK 60 kapalıydı "bedelsiz kalır" (2026-10-11), Erdem 18 Ekim'de tersine çevirdi | ACIK 98: seed öncesi pencerede ek gider iflas üretir | **Tasarlı, kodlanmadı** |
| 12 | Pazarlama sistemi (B2C'de runway baskısı) | Brief #5 Hybrid (hamle destesi + Marka stoku + varlık kadranı); ONERI_TUR1 §2.4 (kanal başına 3, karne, seed'le açılır); ch14 §4 EA; ACIK_ISLER #3 | Pazarlama sekmesi EA kilitli (`ui_tokens.gd:294-304`); beş "ödemeli yer" kartı ilkel pazarlama (`trade_fair` -$30K, `app_placement`, `newsletter_slot`, `analyst_guide`, `b2c_creator_feature`) | Marka bugün yalnız düşüyor, kaynağı yok (ONERI §2.4); ACIK 108 "gerilim gider tarafında aranır" | **Kısmen** (araştırma+öneri var, PRD yok) |
| 13 | Kalibrasyon | OYNANIS_HUKMU §3 kapıları; "onay bekliyor" sabit yığını (EL_KITABI: 185) | Q, C, D PRD'leri kapı taşıyor; zorluk kadranı yalnız başlangıç nakdi | İnsan oturumu yok | **Kısmen** |
| 14 | Ar-Ge derinleşmeli ("manasız yer tutuyor") | Ar-Ge GDD §11 EA seam'leri (paralel araştırma, düğüm artışı, patent, rakip araştırması); Rakip PRD §2.2 (Ar-Ge ağacı yıllarla genişler, AI dalı 2015+ etiketi); ACIK_ISLER #10 (kart sayısını Ar-Ge'ye bağla) | 20 düğüm, deterministik; 4'ünün okuyucusu yok: `cicd`, `accessibility`, `semantic_index`, `analytics_engine` (`research_seam.gd:29,35,40,48`) | Ar-Ge GDD: "Ar-Ge puan ekonomisi değildir" (tasarım niyeti, derinleşmeyi yön olarak sınırlar) | **Kısmen** |
| 15 | Satış ve VC yazımı derin, çeşitli, tekrarsız; başlarda satışta başarısızlık | ACIK_ISLER #2; ONERI_TUR1 §2.6 (K31 MVP ~150 satır, "en uzun süredir söylenmemiş" seçimi); Q karar Q2 (ürün uyumu zarı + satışçı maili); Faz C imza kapısı (kayıp nedeni cümlesi) | Satış ~176 + toplantı 61 + pazarlık 19; VC 104 + seed 85 + masa 61 anahtar. PH satırları temizlendi (O5 `43e0a28`). Bot en kötü cevapla %98 kazanıyor (R15 §8.3); VC 9/10 imza | Erdem 18 Ekim: satış görüşmesi "yine diyalog zenginleştirme" işi, ayrı | **Kısmen** (çeşitlilik ve kaybetme yok) |
| 16 | Başlangıç kasası $10.000 → belki $50.000 | ch01 §4 "[WORKING; calibration may raise it]", ch02/09 "~$10K [WORKING]"; zorluk ×1,5/×0,6 | `STARTING_CASH := 10000` (`founder_constants.gd:56`); Kolay $15.000 | C: kurucu maaşı yok (Erdem), araç gideri kalkıyor; VIZYON #4 "kendine maaş bağla" onaysız | **Tasarlı, esnek** |
| 17 | Evde 1-2 uzaktan çalışan | VIZYON #6 (cap 2, koordinasyon ×0,85, kontrol maliyeti) onaysız; sahip kararı 9 (2026-09-28) kodlu | Evde sınırsız işe alım, çalışan uzaktan (`office_people.gd:11-12`); remote cezası/cap yok | **Faz C C9** (masa=tavan, ev 1 masa) ve Erdem'in 18 Ekim onayı "masa sayısı kadar çalışan" | **Çelişir** (§5.1) |
| 18 | Seed'i yakına al | ch09 §2 (seed orta oyunu açar, 2-3 işe alım + altyapı payı) ; kapı `DOOR_MRR` $20.000 [ÇALIŞMA], zarf 15-25K (`seed_constants.gd:21`) | Seed B2B hf18-21, B2C hf50-55; "seed garanti basamaktır" (reddedilemez, ACIK_KARARLAR 1973) | ch09 §9 hedefi "seed atlanıp Series A'ya varılabilir (evet, daha zor)" ile kod çelişir | **Kısmen** (kaldıraç tek sabit) |
| 19 | Ofis geçişi seed sonrasına | Bugün: Frank çeki + $6.500; C PRD §10 önerisi: çek şartı kalkar, kasa $6.500 yeter | Kod bugünkü kural; Frank EA kartı "gerçek ofis bul" (`funding.frank_office_move`, version_scope ea, çek sonrası) | Frank kartı ve `hire_nudge` ("ilk işe alımı bul") çek sonrası ilk işe alımı Ev'de tarif ediyor | **Çelişir** (§5.2) |
| 20 | Öğretici: Frank'le görev (Big Ambitions) | ONERI_TUR1 §2.1-2.3; PRD_ACILIS (5 adım şart listesi); onboarding `ONB_GUIDED` | Çek listesi + Sıradaki yuvası + ofis kartı kodlu; rehber anahtarı kilitli, `tutorial` kartı 0; ofis/pencere turu yok (ISLER "İlk açılış rehberi yok") | Rakip PRD karar A (daraltıldı); ONERI'nin "kurucunun defteri" adım-adım ses katmanı yok, adımlar nötr tek satır (`CHEQUE_STEP_*`, strings.csv:189-193) | **Kısmen** |
| 21 | Görev sistemi olmalı mı | Erdem 18 Ekim: "tutorial ve görev sistemi eklenecek, yatırımcı görevleri, mod, rakip sistemi; araştırılacak" (ERDEM_QCD_CEVAP); ACIK_ISLER #6 | Yok (§5.4) | Karar A (v6) hâlâ metinde "görev yok, hiçbir zaman" der | **Çelişir** (belge içi, §5.4) |
| 22 | Series A'ya kadar alınacak rakip firma | Yok. GDD ch10 §8: "rakipler satın alınabilir mi: varsayılan hayır"; Perde 3 rezervi | Hafif rakipler Piyasa PRD I2 (yapılmadı); `funding.acquisition_offer` (bizi satın alma) var | Ölçek: seed $100-150K, Series A ~ $2-6M [hesap: değerleme $14-24M × %15-25]; Series A öncesi rakip alımı bütçe dışı [çıkarım] | **Boş** |
| 23 | Olay tonu ve çıta (laptop örneği) | feedback-incident-and-card-writing madde 6 (2026-10-19), ch11 §3-§7, yazar ajanı rubriği (≥7) | Motor örneği taşıyabilir (§6.4); kart yok | Faz C "araç gideri kalkar" ile uyumlu (§5.7) | **Boş** (motor hazır) |
| 24 | B2C kalır | Erdem 19 Ekim öğle; Faz E pazaryeri (PRD_URUN_DERINLIK) | B2C bugün not/video uygulaması; fiyat kolu yok, sayfa salt okunur; haftaların %65'i kartsız | EL_KITABI önerisi "demo yalnız B2B" Erdem tarafından reddedildi | **Tasarlı, B2C orta oyunu boş** |
| 25 | Demo 1. saat-20. saat farkını hissettirebilir mi | Hiçbir belgede "fark" ölçütü yok; demo tanımı dört yerde dört biçim (§5.6) | Demo = Series A kararı; bot 21-27 dk | — | **Boş** (ölçüt yok) |

## 2. Dosya tarihleri ve dökümden sonra değişenler
- `GDDs/*.docx` (15, MARKETING araştırması dahil): 19 Ağu - 27 Eyl tarihli; 7 Ekim dökümlerinden önce. Döküm ile aynı kabul edildi [çıkarım; içerik sağlaması yapmadım].
- `GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` 19 Ekim 01:16, 205.445 B (dökümde 125.942 B). `GDD — ZAMAN MODELİ.md` 18 Ekim 04:37. `GUNCELLEMELER.md` 18 Ekim 21:48.
- Yürürlük sırası (`GDDs/README.md`): `.docx` ile `GUNCELLEMELER.md` ayrışırsa ek belge geçerli. Ek belgenin geçersiz kıldığı yerlerden bu rapora girenler: 30 gün kepenk → 4 hafta, 730 gün → 104 hafta, kurucu enerji barı iptal, Hız/Pazarlama/Operasyon yeteneği iptal, demo kesim noktası Series A kararı.

## 3. GDD ve ek belgelerin okunuşu: Series A'ya kadar tasarlı olanın özeti
- Koşu omurgası (ch01 + GUNCELLEMELER): üç evre tek yönlü; hiçbir evrede "kasa artıyor, karar yok" olmamalı (§5). Fon: birikim → Frank ($25.000, %4, MRR $2.500, tek karar) → seed (4 VC'den biri, term sheet, $100-150K, %12-18, kapı MRR $20.000) → Series A (aynı 4 VC, kapı MRR $120.000, %15-25) [kod: `angel_round_system.gd:27-29`, `seed_constants.gd:21,42-47`, `sales_system.gd:46`, `pitch_constants.gd:171-172`].
- Sonlar: `series_a_close` (zafer), `profitable_bootstrap` (yalnız Series A kararıyla yüzleşip reddedene), `bankruptcy`, `running_on_fumes`, `vc_rejection_cascade`; acquisition GDD'de KESİK ama kodda ve kartlarda canlı (`funding.acquisition_offer`; ACIK_KARARLAR "satın alma v1'de var mı (D1)").
- Pressure law (ch01 §5): Bootstrap = kurucu zamanı + nakit; Traction = müşteriyle ölçeklenen maliyet + rakip payı; Series A Hunt = gelirden önce harcama + pencere kapanışı + term sheet. R15 bunun Traction'da tutmadığını gösteriyor (sonlu runway %5,9, Series A'da %0).
- Ekip ve devir: altı rol × 3 seviye, kurucu "bir işgücü birimi değildir", yapım başına ekip lideri, Faz D ile PM'e planlama devri ve çeyrek hedefi (50 kişide asıl karar), EA takımı ertelendi.

## 4. GDD'nin Series A sonrası (EA ve tam oyun) için söyledikleri
| Konu | Ne diyor | Kaynak | Bugün |
|---|---|---|---|
| Aşamalar | Demo: Bootstrap → Traction → Series A. EA: pazarlama, Ops derinliği, rakip derinliği, olay hacmi ×3, vergi, meta ilerleme, kalan alt-tür/köken. Full: IPO, Series B, makro ekonomi, diplomasi katmanı, ek köken | ch14 §1-§5 | Yalnız demo davranışı; build etiketi (demo/ea/full) var ama davranış farkı tek: kârlı bootstrap EA'da "milestone" (Devam et, 730 tavanı kalkar) (`endings_system.gd:353-369,423`) |
| Series A | Zafer sonu. Perde 3 oynanabilene kadar her build'de son | ch13 §1; `endings_system.gd:353-356` | Aynı |
| Series B / IPO | Kilitli-görünür, ulaşılamaz | ch01 §3 | Sistem yok; kilitli görünümün hangi yüzeyde durduğunu doğrulamadım |
| Ikinci ürün | Slot "KİLİTLİ · Series A sonrası", altında "Erken Erişim içeriği" | Ürün GDD §17 (mühürlü) | Yok |
| Devretme | Pazarlama/Operasyon Müdürü delegasyonu (EA); "FM kalıbı: devret / kontrol al" (Brief #5); lider-otomasyon tek cümle; İK rolü kilitli kart | ch14 §4; MARKETING research; Ekip GDD §4.2, §10.6 | Yalnız PM planlama devri (Faz D). Delegasyon ilkesi: "devretme yeteneği ekibin kalitesine bağlı" (Brief #5, FM) |
| VP | Yok. VIZYON yanıtı #6: "lider +2, VP +N" cap; #8: İK Perde 3 başı | `6e3e190` VIZYON_v1_YANITLAR | Loft'ta "VP odaları" (oda adı) |
| Lobicilik | Yok | — | Yok |
| Diplomasi | "diplomacy-style layer", Full | ch14 §5 | Yok |
| Sonlar (sonrası) | EA: `brand_collapse`; gallery; meta ilerleme "ayrı tasarım turu" | ch13 §1, §4 | `brand_collapse` kodda var (`BRAND_COLLAPSE_FLOOR := 15`) |
| Zaman | Full: perde 1 haftalık tik; perde 2+ `days_per_tick` kabalaşır (2 hf, ~ay); 3-10. yıllar ~2,5-4 saate sıkışır; AI ~10-11. yıl | Rakip PRD §2.2 (onaylı) | Kodda yok; dönem göçü I3 yapılmadı |
| Dönem | Koşu 5 Oca 2012; demo 2012-13; AI yalnız sezdirilir | Rakip PRD karar B | Kod hâlâ 2026 (`START_DATE`, game_state.gd:8) |
| Perde 3 rezervleri | Hisse almak, rakip satın almak, NPC birleşmeleri, kurucu zengin listesi, oyuncunun IPO'su | Rakip PRD §3.9 | Veri alanları (şimdilik atıl) |
| EA süresi | "EA'da oyun 20 yıl oynanabilir" (kart tekrarı gerekçesi) | feedback-incident-and-card-writing madde 4 | Tasarımda sayı yok |
- **Oyun Vizyonu v1 (31 Ağustos) özeti**, yalnız yanıt dosyasının aktardığı kadarıyla: Perde sınırları funding'e bağlı (seed imzası Perde 2'yi, Series A imzası Perde 3'ü açar); Perde 1 = kurucunun yalnızlığı; 730 gün Perde 2 saati; remote çalışan −%15 ve cap 2; ofis kataloğu; İK Perde 3 başı; run kartı; teknik borç Perde 3'te "yeniden yaz mı" kararı; tükenmişlik ark olarak (metre değil); Series B Perde 3; yetki devri, haber motoru, rakip savaşı, IPO sonraki tasarım oturumları (yanıtın §4 sırası). Orijinal metin kayıp [bulamadım].

## 5. Çelişkiler
### 5.1 Evde 1-2 uzaktan çalışan ↔ Faz C C9
- Erdem'in 19 Ekim isteği: evde çalışırken 1-2 uzaktan çalışan alınsın (Frank'in parasıyla), seed'e yakın.
- Faz C PRD (18 Ekim) Karar 3: "masa sayısı işe alım tavanı; Ev 1 masa; ilk işe alım taşınmadır; $4.000 kira ilk çalışanla başlar" (`PRD_FAZ_C_URUN_HESAP.md:135-146`). Erdem 18 Ekim: "ofisteki masa sayısı kadar çalışan olabilir. Bu zaten böyle bir limit" (ERDEM_QCD_CEVAP §1). PM'in aynı belgedeki notu: ev 1 masa olduğu için ilk işe alım İş hanına taşınmak demektir (§2.2 C2); Erdem §2'yi "okay letsgo" ile bütün olarak onayladı, "ilk çalışan = taşınma" sonucu ayrıca tartışılmadı [çıkarım]. İstek ile onay arası bir gün.
- Üç mevcut karar uzaktan işe alımı destekliyor: (a) sahip kararı 9 (2026-09-28), (b) `funding.hire_nudge` ("Parayı hızlanman için koydum, ilk çalışanını bul", çekten 1 hafta sonra, `headcount == 0`), (c) VIZYON yanıtı Ekip GDD'yi "ekip tavanı yoktur" diye aktarıyor (Ekip GDD dökümünde bu cümleyi bulamadım, ama tavan koyan madde de yok); Ev'in tek masası kurucunun (`office_constants.gd:19`). Karşıt karar: yalnız 18 Ekim.
- Kod etkisi: C9 yazılmadı. PLAN_C "C9 ve E1'deki İş hanı sorusu kesinleşmez; E1'de açık madde" der. Çelişki kâğıt üzerinde. PRD tavanın ve botun taşınma politikasının aynı commit'te girmesini şart koşuyor (bugün bot ofis taşımıyor; yoksa koşu işe alamaz, PRD_FAZ_C C9 risk notu).
- Maliyet farkı [hesap, gelir hariç, ×1,5 bantlarıyla]: junior geliştirici $3.000-4.500/ay (ort. $3.750; komisyon = aylık maaşın %50'si, `hr_constants.gd:717`); İş hanı'nda ilk çalışan $4.000 kira ile $7.000-8.500/ay (PRD_FAZ_C satır 153); evde uzaktan $3.000-4.500/ay.
- Açık tasarım noktaları (kodda ve belgede yok): remote'un verim/iletişim bedeli (VIZYON #6 −%15 koordinasyon ×0,85, "uzaktakinin morali görünmez", istifa riski yüksek) ; evdeki tavan (VIZYON #6: P1'de 2); ofise taşınınca remote'un eve gelmesi; ekipman gideri.

### 5.2 "Ofis seed sonrası" ↔ bugünkü kural
- Bugün: İş hanı şartı = Frank'in çeki (`angel`) + kasa ≥ $6.500 (`office_constants.gd:31-34`). Plaza = 12 çalışan + $45.000 + marka 40; Loft = 35 + $110.000 + marka 70. Taşınma 1 hafta, bedelsiz.
- ACIK 60 (2026-10-11, Erdem) taşınmayı bedelsiz bıraktı; 18 Ekim Faz C kiraları getirdi ($4.000 / $8.000 / $18.000) ve Plaza şartı "10 kişi (sen dahil)". C PRD §10: İş hanı'nın Frank şartı E1'e ölçümle gidecek; PM önerisi şartı kaldırmak (kasada $6.500 yeter).
- Zaman: bot çeki B2B hf12-13, seed hf18-21; arada 6-8 hafta. B2C'de çek hf22-24, seed hf50-55 (26-33 hafta). Kira $4.000 bu pencereye biniyor. B2C medyan MRR hf30 $4K, kasa $28K (R15 §4.6): İş hanı + junior ($7.750/ay) net −$3.750/ay [hesap], uzaktan junior ≈ MRR'a eşit.
- ACIK 98 kanıtı: "çek ile seed arası ek gider taşımıyor"; Traction gider kaldıraçlarını üst uca çeken her ayar en az bir tohumu seed'den önce iflas ettirdi (iflas 30.-35. tik). ACIK 108: gerilim "gider tarafında aranır" (opsiyon A: faza bağlı gider: ofis, araç, pazarlama). Yani Erdem'in "ofis seed sonrası olabilir" sezgisi ile ölçümler aynı yönde.
- Seed bir "garanti basamak": reddedilemez, teklif dolmaz (ACIK_KARARLAR 1973, 2026-08-27). Ch09 §9 ise "seed'i atlama: evet" hedefliyor. Erdem'in "seed'i yakına al" kaldıracı tek sabit: `DOOR_MRR`.

### 5.3 Başlangıç kasası (para tablosu, gelir hariç, komisyon dahil [hesap])
Komisyon: junior geliştirici ort. $3.750 maaşın %50'si ≈ $1.875 tek sefer.
| Kasa | Çalışan | Aylık burn | Yaklaşık yaşam (ay) |
|---|---|---|---|
| $10.000 (Normal) | 1 uzaktan junior | $3.750 | (10.000-1.875)/3.750 ≈ 2,2 |
| $10.000 | 1 junior + İş hanı | $7.750 | ≈ 1,0 (kasa şartı $6.500 ile birlikte okunmalı) |
| $35.000 (kasa + Frank $25.000) | 1 uzaktan junior | $3.750 | ≈ 8,8 |
| $35.000 | 1 junior + İş hanı | $7.750 | ≈ 4,3 |
| $50.000 (Erdem'in fikri) | 1 uzaktan junior | $3.750 | ≈ 12,8 |
| $50.000 | 1 junior + İş hanı | $7.750 | ≈ 6,2 |
- Faz C'den sonra MVP öncesi burn sıfır ve MVP sonrası yalnız sunucu: C PRD "evdeki tek kurucunun MVP'den önce gideri yoktur" der. Bugünkü $1.500/ay araç tabanı (Bootstrap runway kapısı 6,7 ay) kalkınca "Bootstrap runway" kapısı anlamsız kalır [çıkarım]. $50.000 isteği bugünkü baskıya bir tepki olabilir; C sonrası ölçülmeden karar verilmemeli.
- GDD $10.000'u [WORKING] işaretler; ch01 §4 "calibration may raise it". Kolay mod $15.000 zaten var. $50.000 Normal'i beş kat yapar; Normal'in %65 kazanma hedefi (ch01 §6) bu kasayla ölçülmedi [kanıtsız].
- Bot en düşük kasa: B2B $5.800-6.400 (hf10), B2C $4-5K (hf19) [MEMNUNIYET_SIM §4.1, R15 §4.6]. Yani botlar $10.000 ile iflas etmiyor; insan oturumu yok.

### 5.4 Öğretici ve görev: "görev yok" kararı ↔ ONERI_TUR1 ↔ Erdem'in son sözü
| Tarih | Söz | Kaynak |
|---|---|---|
| 2026-10-06 | "Görev yok, hiç kimseden, hiçbir zaman." (v5 M1-M3 görevleri "çok ağır" diye rafa kalktı) | Rakip PRD karar A |
| 2026-10-07 | ONERI_TUR1: görev sistemi yok, "paranın şartları" var; Frank'in çek şartları öğretici, seed fonunun 3 şartı + iki dilim orta oyun, Series A odası şartları okur; talimat kurucunun defterinden, Frank yalnız kendi çekinde | scratchpad `ONERI_TUR1.md` §2.1-2.4 |
| 2026-10-10 | Daralma onayı: "Frank'in çeki 5 adımlık şart listesidir, görev sistemi değildir; görev yok hükmü 'para verenin şartı serbest' diye daralır." Kodlandı (ChequeRead) | PRD_ACILIS §0 |
| 2026-10-18 | Erdem: "oyuna bir görev sistemi, yani tutorial ve görev sistemi eklenecek ... seed yatırımla beraber yatırımcı görevleri" (araştırılacak konu) | ERDEM_QCD_CEVAP §1, ACIK_ISLER #6 |
| 2026-10-19 | Big Ambitions'taki gibi Frank'le görev + öğretici karışımı sorusu | bu istek |
- Sonuç: üç hüküm birbirini kapsıyor: ONERI'nin "paranın şartı" = zaten daraltılmış karar A. Rakip PRD'nin ana metni ve §1 tablosu hâlâ "görev yok, hiçbir zaman" der; daraltma yalnız bir notta. İki yeni görev biçimi (rakip yarışı "X'i yakala", mod) v5'te reddedilen M1-M3 ile örtüşebilir; ayrım yazılmalı [çıkarım].
- Yapılmış: çek listesi, TopBar Sıradaki, ofis kartı, 5 adım (tür, ilk sprint, yayın, ilk ödeyen, MRR $2.500). Yapılmamış: seed şartları (3 sonuç şartı, 2 dilim), Series A odasının şartları okuması, "büyüme/sakin" seçimi, kepenk verbleri, kayıp otopsisi, kurucunun defteri ses katmanı, `tutorial` kartları, ilk-kez-görülen açıklama mesajları.
- Seed ile Series A arası TopBar boş; hedefi "adlı" yapan ilk şey seed şartları (OYNANIS_HUKMU §6 madde 3).

### 5.5 Series A: son mu, geçiş mi
- GDD ch01/ch13/ch14: Series A imzası zafer sonu. Kod: aynı. Erdem'in 19 Ekim vizyonu ve 31 Ağustos vizyonu: Series A geçiş (Perde 3). `endings_system.gd:353-356` kendi yorumunda iki hükmü birleştiriyor: "Perde 3 oynanabilene kadar".
- `profitable_bootstrap` EA'da kilometre taşı (Devam et); `series_a_close` her build'de son. Yani EA'da bootstrap yolu oyuncuyu 20. saate taşıyabiliyor, venture yolu taşıyamıyor [çıkarım]. Bu asimetri ch01 §7 ("iki yol da kazanılabilir ve okunabilir olmalı") ile gerilimli.
- Demo tanımı: ch14 §1 Series A kararı (60-90 dk); CLAUDE.md §1 aynı; ONERI_TUR1 §2.5 seed imzası (45-60 dk); EL_KITABI önerisi "Series A daveti, yalnız B2B, 40-60 dk"; Erdem 19 Ekim: B2C demodan çıkmaz. Bot Series A 21-27 dk saf saat (R15 §0 madde 1); 60-90 dk hedefi pauzlarla dolacak.

### 5.6 Diğer çelişkiler ve boşluklar
- **Kurucu maaşı:** Erdem 18 Ekim "gerek yok"; VIZYON #4 "seed'de kendine maaş bağla" onaysız. ch02/ch08 zaten maaş yok. Çelişki yok.
- **İK/rol:** Atlas'ta in-house İK kilitli kart (Ekip GDD §10.6, 2026-08-23); VIZYON #8 "İK Perde 3 başı". Pazarlama rolü de kilitli. ONERI_TUR1 §2.4: "Pazarlama bir yetenek alanı değil, v1'de yetenek yok" (Ekip rev 11). Brief #5: Pazarlama skill + Pazarlama Müdürü. Üç belge üç farklı yol [belge].
- **EA takımı ertelendi** (QCD D5) ↔ Erdem'in "her ekip bazında lider" fikri (ERDEM_QCD_CEVAP D1): VP katmanı için doğal yer burası; ertelenmiş ve nedeni ölçüm (takımlı düzen takımsızdan yavaş, D_MODEL_v3 §3.14).
- **Sektör 13** (Erdem: Tekstil/Medya kalsın) ↔ hüküm 11: kararı Erdem verdi, Q1 13 sektör.
- **Ofis kartı küçük resimleri** Xbot kaynaklı, lisansı doğrulanmadı (ACIK 109): yayın engeli, vizyonla ilgisiz ama mağaza ekranlarını etkiler.

### 5.7 "Araç gideri kalkıyor" ↔ laptop olayı (uyum)
- Bugünkü `TOOLS_PER_EMPLOYEE_MONTHLY` kalemi "yazılım, lisans ve donanım" diye tanımlı (`finance_system.gd:8-11`): çalışan başına $150/ay gizli ekipman payı. Erdem'in "göremediğim, yönetemediğim gider olmasın" ilkesiyle Faz C bunu siliyor. Bilgisayar olayı ekipman maliyetini oyuncunun gördüğü ve karar verdiği tek seferlik gidere çevirir: ilke ile uyumlu, çelişmez [çıkarım].

## 6. Olay envanteri
Kaynak: `data/events/cards/*/*.json` çalışma ağacı (19 Ekim). 134 JSON (fikstür hariç): 128 demo kapsamlı, 1 EA (`funding.frank_office_move`), 1 taslak (`funding.frank_v1`), 1 emekli (`team.first_weeks`), 3 `unwired/` (katalog dışı). Aşama = kartın `plausibility.phase_band` bildirimi; fiili kapı koşul ağacıdır [belge].
### 6.1 Kategori × aşama (kart sayısı, aşamada yer alan)
| Kategori | Toplam | Bootstrap (solo/ekipli) | Traction | Series A |
|---|---|---|---|---|
| customer (müşteri) | 17 | 11 / 12 | 17 | 13 |
| founder (kurucu) | 7 | 7 / 6 | 0 | 0 |
| funding (fon, Frank, kapılar) | 24 (+1 taslak) | 6 / 5 | 19 | 9 |
| product (ürün, sprint, acil durum) | 59 | 57 / 56 | 58 | 54 |
| rival (rakip) | 6 | 2 / 2 | 5 | 3 |
| team (ekip) | 8 (+1 emekli) | 0 / 5 | 8 | 4 |
| world (dünya) | 8 | 4 / 4 | 6 | 8 |
| Toplam (129) | | 87 / 90 | 113 | 91 |
- Yalnız tek aşamada geçerli: Bootstrap 9 (founder 7, funding 1, product 1), Traction 16 (funding 11, customer 2, team 2, rival 1), Series A 7 (funding 4, world 2, rival 1). Her aşamada geçerli 71 (product 52, customer 10, world 4, team 3, funding 2). Bootstrap+Traction 13, Traction+Series A 13.
- `product` 59 kartın 46'sı sprint kâğıdı (rol sesli karar: tasarımcı 8, geliştirici 10, PM 8, testçi 9, kurucu 7, sistem/karma 4); 13'ü acil durum, B2C zemin, yayın ve destek kartı. Sprint kâğıtlarında bot 46'nın 27'sini hiç görmedi (R15 §4.1).
- Arklar: `data/events/arcs/` içinde 1 gerçek ark (`soft_cap_stretch`) ve 2 fikstür. ch11 dokuz ark × 4-6 düğüm planlamıştı; R15 §5.3: rakip/pazar şoku ve kısa ark yok (rakip kartı 2: `price_cut` 4,3, `funding_round` 3,7 / koşu).
- Hacim: ch14 demo hedefi 40-60 düğüm; mevcut 128. EA hedefi ×3 (~150-180).

### 6.2 Aşama başına kart ve karar yoğunluğu (bot, R15 §4.4)
| | Bootstrap | Traction | Series A |
|---|---|---|---|
| B2B karar/hf | 0,98 | 4,25 | 3,78 |
| B2B kartsız hafta | %60 | %3 | %12 |
| B2C karar/hf | 1,23 | 1,26 | 1,48 |
| B2C kartsız hafta | %52 | %65 | %53 |
| B2B durma/hf | 0,65 | 1,72 | 1,41 |
Karar kartı çoğunlukla müşteri istek/tutma/genişleme (B2B kartların %66'sı); B2C'de ilk 7 hafta ve orta oyun sessiz.

### 6.3 "İlk kez kurucu" durumlarını işleyen kartlar (benim sınıflamam [çıkarım])
- Kurucu evresi (7): `founder.domain_name` (kısa alan adı mı), `friends_test` (arkadaşlara ilk gösterim), `meetup_talk`, `side_contract` (yan iş, sprint saatini yer), ve seçeneksiz üç beat: `company_of_one`, `savings_note`, `unseen_build` (+ `product.working_parts` beat).
- Solo işletme sürprizi (9): `sprint_solo_backup` (yedek yok), `_license`, `_rushed_code`, `_server_bill` (sunucu faturası ikiye katlandı), `_signup_code` (kod gelmiyor), `_watch` (müşteri her hafta görmek istiyor), `sprint_late_solo`, `product.support_overflow` (destekte kimse yok, hc 0), `product.launch_leak` (yayında açık).
- Para ve hukuk "ilk kez" (4): `funding.closing_docs` (114 sayfa belge, 3 yol: hukuk bürosu / okuyup avukata sor / kendin oku), `closing_docs_series_a`, `customer.chargeback` (muhasebeci bankaya iade yaptırdı), `customer.security_review` (güvenlik anketi).
- Frank'in ilk adımları: `funding.frank_intro` (customer kategorisinde), `gate_traction` ("ilk ödeme geldi, notu çerçeveledim"), `frank_cheque`, `hire_nudge` (ilk işe alım; seçenek tek: İK'ya git), `frank_office_move` (EA, seçenek tek).
- Toplam yaklaşık 20 kart (%15). Seçenekli ve ilk-kez-kurucu temalı olanlar 10'u geçmez (domain, friends_test, meetup, side_contract, closing_docs ×2, chargeback, security_review, sprint_solo ×6).
- **İşe alım deneyimi:** ilk çalışanla ilgili tek kart `team.first_weeks` emekli (retired, `version_scope: retired`). İlk işe alımdan hc=3'e kadar ateşleyebilen `team` kartı: `burnout`, `conference_trip`, `password_rule`, `resignation` (hepsi hc≥1). `team.outside_offer`, `lead_overtime`, `demo_day`, `wiped_table` hc≥3.
- **Hiç yok:** uzaktan çalışan, çalışana ekipman (bilgisayar), işe başlama haftası, bordro, sözleşme, hukuk, sigorta, ofis kirası/taşınma (taşınma kartı yalnız Frank'in `frank_office_move` beat'i, EA), eş çalışma alanı, ilk işten çıkarma, kurucu tükenmişliği (iptal), yatırımcı güncelleme ritüeli (var: `funding.monthly_update`, seed sonrası). Haber şeridinde tek satır "Uzaktan çalışma tartışması bitmedi" (`NEWS_S_OFIS_TARTI`), ekranda kart değil.

### 6.4 Erdem'in laptop örneği için motorda ne hazır, ne eksik
- Hazır: `office.current == "home"` ve `hr.headcount` seam'leri (`_vocabulary.md:229,313`); `hr.tenure_weeks` entity seam'i; `newest_hire` seçici (retired `first_weeks` kartı kullanıyordu); `add_cash` fiili; tek seferlik bedel örüntüsü (`urun.paper_test_phones` "birkaç test telefonu, bir kez, dolar"); `family` freni; çip kuralı (bedel sayıyla çipte yazar).
- Eksik: "çalışan uzaktan mı" seam'i yok (`office.current == home` ile türetilir); remote çalışana bağlı bedel/verim/iletişim fiili yok (VIZYON #6 formülü kodlanmadı); ekipman bedelinin kaynağı (`TOOLS_PER_EMPLOYEE_MONTHLY`) Faz C'de siliniyor; tetik zamanı "işe alımdan sonra bir hafta" için `hr.tenure_weeks <= N` koşulu mevcut.
- Çıta kuralları (hafıza): seçenek somut hamle, bedel olayın öznesine düşer, bedava çıkış yok, doğal tam cümle, kart tekrarı çok seyrek (feedback-event-option-quality, -incident-and-card-writing).

## 7. Bugünkü erken oyun zaman çizelgesi
Bot, `main @ 889b9b8` (Faz A+B sonrası), 10 tohum; 1 hafta = 22,5 sn (1×), duraklamalar hariç (R15 §2.1, §3.1; CLAUDE.md §6). Saf saat = hafta × 22,5 sn.
| Olay | B2B hafta | B2C hafta | Saf saat (B2B) |
|---|---|---|---|
| Tür seçimi + Sprint 1 | 1 | 1 | 0,4 dk |
| MVP yayını (v1.0) | 7 (`full_run_7.log`) | — [bulamadım: B2C yayın haftası ayrı yazılmamış] | 2,6 dk |
| Frank'in tanıştırması (ilk lead) | 8 | — | 3,0 dk |
| İlk imza / ilk ödeyen | 9 | — [bulamadım: B2C ilk ödeyen haftası ayrı yazılmamış] | 3,4 dk |
| Traction kapısı | 10-12 | 10 | 3,8-4,5 dk |
| Frank'in çeki ($25K, %4) | 12-13 | 22-24 | 4,5-4,9 dk |
| İlk işe alım (bot) | çekten sonra, STAFF_LADDER MRR eşiği (test uzmanı $3K, satış $4K MRR) | çekten sonra | ~hf13+ |
| Seed (MRR $20K, $100-150K) | 18-21 | 50-55 | 6,8-7,9 dk |
| İlk ofis taşınması | bot hiç taşımıyor | hiç | ölçü yok |
| Series A kapısı (MRR ~$120K) | 58-60 | 75-84 | 21,8-22,5 dk |
| Series A imzası | 57-71 (9/10) | log yok | 21-27 dk |
- Süre dağılımı: Bootstrap (hf1-9) 3,4 dk saf saat; Traction B2B 51 hf (19 dk), B2C 69 hf (26 dk); Series A B2B 0,4-1,9 dk (R15 §3). Kasa medyan hf14/hf20/hf30/hf52: B2B $31K/$146K/$150K/$224K; B2C $6K/$5K/$28K/$87K. MRR hf30/hf52: B2B $52K/$102K; B2C $4K/$20K.
- "İlk ofis": bot ofis taşıma politikası yok (R15 §1.2); kural açısından en erken an Frank'in çeki ve $6.500 kasa (B2B hf12-13). Kira yokken taşınma bedelsiz. İnsan oyuncunun gerçek anı ölçülmedi [kanıtsız]; C0s iki hâlli ölçüm yazacak (PRD_FAZ_C satır 586) ve Q bitince koşacak.
- İnsan süresi: Rehberli bölüm tahmini B2B 20-30 dk, B2C 30-40 dk (ONERI_TUR1 §2.3, 1× + kararlar) [hesap, ölçülmedi].
- 20. saat için bir ölçü yok: 104 hafta 39 dk saf saat; Full'de 3-10. yıllar 2,5-4 saat (Rakip PRD §2.2). Erdem'in andığı 10-20 saatlik oturum, 104 haftalık koşunun saf saatinin yaklaşık 15-30 katıdır [hesap: 600-1200 dk / 39 dk]; tasarımda o süreyi dolduracak içerik ya da tavan yok.

## 8. Boşluklar listesi (roadmap girdisi, sıra önerisi değil)
1. Series A sonrası: Perde 3'ün tanımı, ikinci ürün, yetki devri zinciri (VP/İK), lobicilik/diplomasi, hisse/yatırım ve rakip alımı. Hiçbiri tasarlı değil; tek yazılı dayanak ch14 §5 listesi ve Piyasa PRD §3.9 alan rezervleri.
2. Uzaktan çalışan modeli: cap, verim/iletişim bedeli, ekipman gideri, ofise geçince eve gelme; Faz C C9 kararı bunu bekliyor.
3. Seed sonrası ve orta oyun hedefi: seed şartları (3 sonuç şartı, iki dilim), Series A odasının şartları okuması; seed ile Series A arası ~40 hafta adlı hedef yok.
4. Pazarlama: Brief #5 + ONERI §2.4 var, PRD yok; B2C orta oyun karar kolu yok (fiyat, sunucu: Faz C/E).
5. Olay yazımı: ilk-kez-kurucu temalı remote/ekipman/bordro/hukuk kartları; ark sayısı 1/9; Series A sonrası içerik sıfır; havuzun yarısı hiç gelmiyor (RAPOR_B: 27/46).
6. Doruk ve kayıp: Series A formalite, ret `faced_series_a` yazmıyor, "Üçüncüde yol biter" yalan, TEKRAR DENE yok (R15 §5.4, §8.7).
7. Öğretici: `tutorial` kartı 0, rehber kilitli, ofis/pencere turu yok, ilk-kez-görülen açıklamalar yok, terim sözlüğü yok.
8. Satış ve VC: kaybetme ihtimali ve çeşitlilik (%98 kazanç), VC masası 0 zorlama, fon seçimi çözülmüş (Bosphorus 6 oturumun 5'inde teklif verdi).
9. Ar-Ge: 4 okuyucusuz düğüm; derinlik yok; "ürün kart sayısını Ar-Ge'ye bağla" kararı yok.
10. Vitrin: ses (tek MP3), gazete sanatı, `steam_appid`, Xbot küçük resimleri lisansı, AI beyanı (ACIK_ISLER #15, #16, ACIK 109).
11. İnsan oturumu: 14. haftanın ötesini oynayan insan yok (R15 §1.5); "başı çok zor" gözlemi ölçülmedi.

## 9. Kapsam ve sınırlar
- Doğrudan okunanlar: GDD v2 ch01, 02, 06, 08, 09, 10, 11, 12, 13, 14 (dökümler tam); GUNCELLEMELER (ch01, ch02, ch08, ch09, ch13, ch14 bölümleri tam, kalanı başlıklarla); ONERI_TUR1 tam; OYNANIS_HUKMU tam; ACIK_ISLER (faz_cde ve ACIK_ISLER/ISLER) tam; CLAUDE.md §1-§13; PRD_EKIP_VERIM_DESTEK tam; R15 tam; PRD_RAKIP_DUNYASI §0-§2, §3.9 ve karar tablosu; PRD_ACILIS §0 ve `cheque_read.gd`; PRD_FAZ_C satır 40-170, 580-700; PRD_FAZ_D §1, §2 (Karar 11-12), §7; hafıza kayıtlarının dizinde ilgili olanları.
- Yalnız grep/başlıkla okunanlar: Ürün, Ekip, Ar-Ge, Satış, Pazarlama GDD dökümleri (post-Series A ve devir terimleri için); PRD_URUN_DERINLIK (özet, §6, başlıklar); PRD_ANA_MENU_ONBOARDING (§10.4, §10.7); OLAY MOTORU md (kart sayımı ve hafıza kayıtları üzerinden); `ACIK_KARARLAR.md` (2.124 satırın ilgili maddeleri: 60, 98, 108, 109, 897-903, 1950-1980).
- Okunmayanlar: `.docx` dosyalarının kendisi (dökümler kullanıldı); `PRD_OLAY_MOTORU_V3`, `PRD_YAZAR_AJANI_V2`; `faz_ab` klasörü; `R1-R8` (EL_KITABI'nde özetli); `D_MODEL_v3`, `D_SIM_v3`.
- Ölçü sınırı: bot sayıları "hızlı ve düşünmeyen" politikadır; kart sayıları üst, karar çeşitliliği alt sınırdır (R15 §1.3). Para tablosu [hesap] ve gelir içermez. Kart sınıflamam (§6.3) benim yorumumdur.
- Yazma kuralı: tek yazılan dosya bu rapordur; hiçbir kaynak dosya, git ya da Godot'a dokunulmadı. Arka planda başka oturumlar Faz Q'yu yazıyor; CLAUDE.md okurken başka oturum tarafından değişti (B2C kalite bağlamı satırları), bu rapordaki atıfları etkilemiyor.
- `docs/strateji/ANA_RESIM.md` PLAN_C'de Erdem'e gidecek karar yeri olarak anılıyor; bugün dizinde yok.
