# GDD güncellemeleri

Bu ek, bir .docx GDD'nin kesinleşmiş sahip kararlarının ya da kodun gerisinde kaldığı yerleri kaydeder.
**Bir GDD ile bu dosya ayrışırsa bu dosya geçerlidir.** .docx güncellendiğinde ilgili madde buradan silinir.
Buraya yalnız kesinleşmiş olan girer; açık sorular `../docs/ACIK_ISLER/ACIK_KARARLAR.md`'dedir ve her maddede
"açık" diye anılan kısım bu dosyanın kuralı değildir. Olay motorunun ve zaman modelinin (`GDD — ZAMAN MODELİ.md`)
md'leri doğrudan güncellenir, burada yer almaz.

Her madde: **Bölüm ve madde** · Eski metin (özet) · Yürürlükteki kural · Kaynak. ONERI_v3'ün K numaraları
`git show 6e3e190:project-unicorn/docs/handoff/ONERI_v3_K1-K32.md` ile okunur.

## GDD v2 — 01 · The Run (spine)

- **§1 Length and slice, "Full run" satırı**
  - Eski metin: Tam koşunun yumuşak tavanı 24 oyun ayıdır [WORKING 730 gün]; bir son daha önce ateşlenirse koşu erken biter.
  - Yürürlükteki kural: Bir oyun günü (tik) bir haftadır. Yumuşak tavan 104 haftadır (`EndingsSystem.SOFT_CAP_WEEK` [WORKING]); takvimde 728 gün, yaklaşık 24 ekonomi ayı (ay 30 gün). Bir son daha önce ateşlenirse koşu yine erken biter.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §1, §4; sahip kararı 2026-09-27/28.

- **§1 Length and slice, "Demo slice" satırı; §10 Open items, 1. madde**
  - Eski metin: Demo Bootstrap'tan Traction'ın içine kadar sürer; kesim noktası Traction içinde bir yerdir ve ch13/14'e bırakılmıştır.
  - Yürürlükteki kural: Demo Bootstrap → Traction → Series A boyunca sürer ve Series A kararı sonuçlanınca biter; imza koşuyu zafer sonuyla kapatır. Seed ara basamaktır, kesim noktası değildir. §10'un ilk maddesi kapanmıştır. 60 ile 90 dakikalık [WORKING] hedef ve "her baskı döngüsünden en az bir tur" şartı kalır. 1×'te varsayılan mesaiyle bir hafta yaklaşık 90 gerçek saniye sürdüğü için hedef, duraklama ve toplantı süresi hariç, yaklaşık 40 ile 60 oyun haftasıdır. Açık: son kümesi, "Series A kararıyla yüzleşti" sayılan haller (D5), build kapsamı ve EA/tam davranışı.
  - Kaynak: ch14 §1; GDDs/README (ch01 §1 → ch14 §1–§2); CLAUDE.md §1; `GDD — ZAMAN MODELİ.md` §2; sahip kararı 2026-09-27/28.

- **§4 Funding ladder, gövdenin 2. ve 3. paragrafı**
  - Eski metin: Frank Series A öncesindeki tek çektir; ara seed töreni ve seed yatırımcı karakteri yoktur, oyuncu Frank'in parası ve gelirle doğrudan Series A'ya koşar.
  - Yürürlükteki kural: Merdiven kurucunun birikimi → Frank'in MRR eşiğinde gelen tek çeki (tur değil, tek karar, term sheet yok) → mevcut dört VC'den biriyle term sheet'li seed → aynı dört VC ile Series A. Seed için yeni yatırımcı karakteri eklenmez. Açık: seed'in atlanması (ch09 §9), seed'in reddi, süresi ve "şimdi değil" sonucu (K18–K22), fon arketipleri (K29).
  - Kaynak: ch09 durum satırı ("Supersedes chapter 01 §4") ve §1; ch14 §2; CLAUDE.md §1–§2.

- **§9 Non-negotiables, 3. madde ("TR canonical, EN literary" yarısı)**
  - Eski metin: Oyuncu metninde Türkçe kanoniktir, İngilizce onun edebi karşılığıdır.
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. Her metin bir anahtar olarak doğar (`localization/strings.csv`, `keys,tr,en`). "No dashes in copy" yarısı değişmez. Metni kimin yazdığı açık karardır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

## GDD v2 — 02 · Founder & People Model

- **§2 Skill model (everyone)**
  - Eski metin: Altı rol yeteneği (Geliştirme, Tasarım, Satış, Müşteri Başarısı, Pazarlama, Operasyon) ve meta Hız; kişi başına 7 sayı.
  - Yürürlükteki kural: Altı alan vardır: Ürün, Tasarım, Yazılım, Test, Satış, Müşteri İlişkileri (her biri 0–10 ham). Liderlik herkeste, Karizma yalnız kurucuda bulunur. Meta Hız kaldırılmıştır; hız Ekip §4.5'in etkin çıktı formülünün sonucudur. Pazarlama ve Operasyon alan değildir. Çalışan 7 sayı (altı alan + Liderlik), kurucu 8 sayı (+ Karizma) taşır.
  - Kaynak: Ekip GDD §0.1, §4, §4.5, §17.6; GDDs/README (ch02 §2 → Ekip).

- **§3 Display (the complexity rule)**
  - Eski metin: Roller Geliştirici, Tasarımcı, Satışçı, MB/Destek, Pazarlamacı, Operasyon; her rolün bir anahtar + iki destek yeteneği var; kapalı kart rol uyumu ★ + anahtar yetenek ★ gösterir.
  - Yürürlükteki kural: Altı rol, üç seviyede (Junior / Orta / Kıdemli): Yazılım Mühendisi, Ürün Yöneticisi, Test Mühendisi, UX/UI Designer, Satış Temsilcisi, Müşteri Temsilcisi. Her rolün bir ana alanı (×1,0) ve varsa bir ikincil alanı (×0,8) vardır; eşleme Ekip §4.4'te mühürlüdür. Kapalı satır ana alanı, varsa ikincil alanı ve Liderlik'i gösterir; altı alanın tamamı açılmış detayda ve Kişisel'de görünür. Yıldız: 0–10 ham → 5★, yarım yıldız çözünürlüğü; ham değer yalnız derin hover'da. Atama Görevler matrisidir (satır kişi, sütun iş; kişi başına en çok iki iş).
  - Kaynak: Ekip GDD §0, §3, §4.1, §4.3, §4.4, §12, §12.0, §12.1.

- **§4 Founder-only, Liderlik satırı**
  - Eski metin: Liderlik yalnız kurucuya ait bir sayıdır; işe alım araması ajans/Atlas retainer'ında kalır.
  - Yürürlükteki kural: Liderlik herkeste bulunur; yalnız Karizma kurucuya özgüdür. Yapım başına bir ekip lideri atanır ve liderin Liderlik yıldızı alanın toplam çıktısını ölçekler (yüzde ekranda yazmaz). Atlas araması ücretsizdir, retainer yoktur; tek ücret işe alımda bir aylık maaşın %50'si komisyondur. Açık: moral düşüşünü ve deneyim kazancını hangi Liderlik'in ölçeklediği (ACIK_KARARLAR 2 ve 7).
  - Kaynak: Ekip GDD §4, §4.2, §10.

- **§5 Founder assignment (founder time), dört madde**
  - Eski metin: Kurucu aynı anda tek iş tutan bir çalışandır (yapım, satış ya da fon toplama); atanmışken öbür eylemler "Kurucu satışta" türü gerekçelerle kilitlidir.
  - Yürürlükteki kural: Kurucu bir işgücü birimi değildir: Görevler matrisinde ve Kadro'da yer almaz. Kural "her şeyi yapabilir, aynı anda yapamaz"dır; kısıt bir yasak değil bir sonuçtur. Aktif yapımı taşıyabilecek kimse boş değilse yapım durur ve "Kimse üzerinde değil." ya da "Ekip başka işte." gerekçesiyle okunur (kişi adı yok). Meşguliyet tek modeldir: izin · eğitim · (kurucu) yatırım hazırlığı · (kurucu) toplantı oturumu; ilk üçü Ekip §2.2'nin listesidir, toplantı oturumunu (satış toplantısı, seed ve Series A pitch'i, term sheet masası; yalnız sahne açıkken) kod ekler (`HRSystem.is_busy`). Ara kademe ya da yarı hız yoktur. Kurucunun görev durumları Ekip §2.3'tedir; araştırma dışlayıcı bir iştir (Ar-Ge §5.0). Kurucu eylemlerine "Kurucu satışta" türü kilit gerekçesi yoktur. Toplantıların zaman modeli ve kurucuya haftalık maliyeti Satış §5.0 maddesindedir.
  - Kaynak: Ekip GDD §0.1, §2, §2.1–§2.3, §12, §17.6; Ar-Ge GDD §5.0; Satış GDD §5.0; `GDD — ZAMAN MODELİ.md` §8; sahip kararı 2026-09-27/28.

- **§6 Energy / burnout (founder), bölümün tamamı**
  - Eski metin: Kurucunun enerji barı mesai ve "her şeyi kurucu yapıyor" dönemlerinde düşer; düşük enerji yetenek cezası verir, olay tetikler, TopBar/ODA rozeti olur.
  - Yürürlükteki kural: Kurucu enerji barı ne bu sürümde ne sonrasında vardır; §6 iptal edilmiştir. Kurucunun morali de yoktur; ek mesaide moral kaybı ya da yorgunluk cezası almaz. Uzun günün bedeli azalan verimdir: sekizi aşan her saat yarım saatlik çıktı verir ve bu eğri kurucuya da uygulanır; Ekip §17.5'in "kurucunun uzun gün verimi" park maddesi böylece kapanmıştır (Ekip §8.2 maddesi).
  - Kaynak: Ekip GDD §2, §17.6; GDDs/README (ch02 §6 → Ekip); `GDD — ZAMAN MODELİ.md` §9; sahip kararı 2026-09-27/28.

- **§7 Growth, "Primary: learn by doing" ve "Secondary: training course" satırları**
  - Eski metin: Birincil büyüme işbaşında öğrenmedir; eğitim kursu nakde mal olur, kişiyi [WORKING 3 hafta] uzaklaştırır ve bir yetenekte +1 verir.
  - Yürürlükteki kural: İşbaşı öğrenme emeklidir. Deneyim alan bazlı olmayan tek bir 0–100 bardır ve kendiliğinden yıldıza dönüşmez; tek çıkışı eğitimdir. Bar dolunca eğitim açılır: kişi iki hafta eğitimde kalır (meşgul), dönüşte seçilen alanda +½ yıldız kazanır, bar sıfırlanır, eski görevine döner. Seçilebilir alanlar ana alan, varsa ikincil alan ve Liderlik'tir; kurucu yedi alanın hepsinde eğitilebilir, Karizma eğitilemez. Bedel hedef alanın mevcut seviyesine göre kademelenir; tavan 5,0★. "Tertiary: mentoring" ve "Pace target" satırları bu maddenin konusu değildir.
  - Kaynak: Ekip GDD §5.1–§5.4.

- **§9 Hiring reveal; §12 Open decisions, 2. madde (mülakat bedeli)**
  - Eski metin: Kısa liste rol uyumu ve anahtar yeteneği gösterir; kurucu zamanına mal olan mülakat tam yetenekleri ve huyları açar; retainer'lı arama değişmez. §12 mülakatın bedelini açık bırakır.
  - Yürürlükteki kural: Mülakat ve maaş pazarlığı yoktur; aday ya alınır ya alınmaz. Atlas araması ücretsizdir; aday listesi bir hafta sonra gelir, her aramada sabit üçlü arketip (Uzman / Dengeli / Pazarlık) gösterilir. Aday kartı: ad, unvan, rol açıklaması, yetenekler (her zaman beş yıldız), tek huy, maaş talebi; komisyon ve runway etkisi İŞE AL'dan önce okunur. Tek ücret işe alımda bir aylık maaşın %50'si komisyondur. §12'nin mülakat bedeli sorusu kapanmıştır.
  - Kaynak: Ekip GDD §10, §10.2, §10.3.

- **§10 Personal tab (v1), 2. satır**
  - Eski metin: Kişisel sekmesi net varlığın yanında enerji barını (§6), kurucu kartını ve mevcut atamayı taşır.
  - Yürürlükteki kural: Kişisel sayfasında enerji barı, moral, maaş ve kıdem tazminatı yoktur. İçeriği Ekip §2.5'tedir: kurucu kartı, yedi yetenek (altı alan + Liderlik), ayrı gösterilen Karizma, deneyim barı ve "Eğitime gönder" eylemi, mevcut görev durumu. Açık: net varlık ve değerleme satırı (`finance.valuation()` seam'i).
  - Kaynak: Ekip GDD §2.5, §17.6; GDDs/README (ch02 §10 → Ekip).

- **§11 Ripples, 1. ve 2. madde; §12 Open decisions, 1. ve 3. madde**
  - Eski metin: Onboarding kurucunun 7+2 sayısını kurar; HR işi chapter 07'dedir. Açık kararlar: Hız görünür mü, rol başına anahtar+2 eşlemesi.
  - Yürürlükteki kural: Kurucu sekiz sayı taşır: altı alan + Liderlik + Karizma; Hız, Pazarlama ve Operasyon yoktur. Chapter 07'nin yerini Ekip GDD'si alır. §12'nin Hız sorusu (Hız kaldırıldı) ve rol eşlemesi sorusu (Ekip §4.4'te mühürlü) kapanmıştır. §11'in yaşam gideri maddesi de kapanmıştır: yaşam gideri yoktur, kurucunun 1. gündeki 50 $/gün'ü Araçlar kaleminin tabanıdır (ch08 §1 maddesi).
  - Kaynak: Ekip GDD §0, §2.5, §4, §4.4; GDDs/README (chapter 07 → Ekip); sahip kararı 2026-10-02 (7).

## GDD — ÜRÜN MODÜLÜ (`GDD v2 — 03 · Product Lifecycle.docx`, rev 6.1)

- **§0 YÜRÜRLÜK ("kayıt şeması v9"); §22.5, 1. paragraf; §24'ün §22.5 notu**
  - Eski metin: Kayıt şeması v9'dur; ağaçtaki değer 8, Ürün paketi v9'a çıkarır. v9 altındaki kayıt açıkça reddedilir; v1–v8 göç merdiveni ağaçta durur.
  - Yürürlükteki kural: `SaveManager.SCHEMA_VERSION` 15, `MIN_LOADABLE_VERSION` 10. v10 altındaki her kayıt (v9 dahil) `SAVE_ERR_TOO_OLD` ile reddedilir ve state teslim edilmez. Yükleyicide dört göç sırayla çalışır: v10 kayıtlarında Satış rev 6 göçü, v10–v12 kayıtlarında ofis göçü (Frank'in çekini almış koşu İş hanında, öbürü Ev'de açılır), v13 ve altındaki kayıtlarda haftalık zaman modeli göçü (`_migrate_14`: gün damgaları haftaya, gün sayaçları hafta sayacına çevrilir; kurallar `GDD — ZAMAN MODELİ.md` §10'dadır), v14 ve altındaki kayıtlarda sprint göçü (`_migrate_15`, Ürün rev 7 bölümünün kayıt maddesi). v1–v8 göç dalları yükleyiciden kaldırılmıştır. §22.5'in geri kalanı (açık mesaj, alan listeleri) yerinde kalır.
  - Kaynak: cc952e4 (şema v10, eski kayıtlar bilerek öldü); 82bfcbd; Erdem, 2026-09-27 görev kararı (izometrik ofis; şema v13); `GDD — ZAMAN MODELİ.md` §10; sahip kararı 2026-09-27/28 (eski kayıt göçle açılır, şema v14); sahip kararı 2026-10-01 (Ürün rev 7, şema v15); CLAUDE.md §6; §24'ün "inşa bittiğinde kod öncüdür" kuralı.

- **§2 YAŞAM DÖNGÜSÜ, "Build bar hiç kaybolmaz" cümlesi**
  - Eski metin: HUD, tracker, ODA monitörü ve Ürün sekmesi aynı renderer'ı çizer.
  - Yürürlükteki kural: Aynı renderer'ın iki ev sahibi vardır: yüzen BuildHUD ve Ürün sayfasındaki izleyici kartı. ODA monitörü yoktur. BuildHUD bir çubuğu doluyken ofiste de, açık pencerenin üstünde de görünür. Cümlenin geri kalanı (bar hiç kaybolmaz; canlı ürün ve aktif yapım iki bardır) değişmez.
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis); ch12 §3 maddesi.

- **§2 YAŞAM DÖNGÜSÜ, İptal paragrafı ("harcanan günler yanar"); §3 KONSEPT, "Maliyet dürüstlüğü" satırı; §6.0 EforTavanı, "Süre ~N gün" önizlemesi**
  - Eski metin: TASARIM'da iptal edilen yapımın harcanan günleri yanar; Konsept önizlemesi "Toplam efor · süre · bittiğinde kasada $X kalır" der ve süreyi gün olarak tahmin eder ("Süre ~N gün").
  - Yürürlükteki kural: Süreler hafta verisidir. Yapım süresi tahmini kalan efor / (günlük yapım hızı × 7) olarak hafta cinsinden yukarı yuvarlanır ("~N hafta"); önizlemenin kasa satırı hafta sayısı × 7 günlük net akıştır. İptalde yanan süre hafta okunur. Yapım hızı (efor/gün) gün verisi olarak kalır (§6.1 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §4; sahip kararı 2026-09-27/28.

- **§5 TASARIM, tur süresi (bölüm sessiz) ve "Erken geçiş" maddesi**
  - Eski metin: Turlar otomatik akar, en fazla 4; bölüm bir turun ne kadar sürdüğünü söylemez. "Geliştirmeye geç →" ilk günden itibaren basılabilir.
  - Yürürlükteki kural: Bir TASARIM turu bir hafta, yani bir tik sürer (`ProductSystem.ITER_ROUND_WEEKS` 1); dört tur dört haftadır. "Geliştirmeye geç →" ilk haftadan itibaren basılabilir. Turun efor maliyeti ve cila merdiveni değişmez.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§5 TASARIM, "Ters çevrilme yasağı" son cümlesi; §12.12, 45 kimlik kademesi maddesinin son cümlesi**
  - Eski metin: K(n+1) ≥ K(n) × 1,6 kısıtı kademelerin ham eksen puanına uygulanır.
  - Yürürlükteki kural: Kısıt ağırlıklı katkıya (ham puan × Kano katsayısı) uygulanır. Mühürlü merkezlerde (4 · 9 · 12) ağırlıklı katkılar 4,0 · 7,2 · 14,4, oranlar 1,80 ve 2,00'dir; ham puana uygulansaydı mühürlü K3 merkezi 12 kırılırdı. Katalog yüklenirken denetlenir, ihlal eden hat reddedilir.
  - Kaynak: aynı belgenin §24'ü, §12.4 notu (direktör hükmü 2026-08-25); cc952e4.

- **§6.1 Efor modeli, iki formül satırı ve "Saat normalizasyonu" paragrafı; §24'ün §6.1 notu**
  - Eski metin: Kişinin günlük katkısı etkin çıktı × saat/8'dir; yapım hızı (efor/gün) taşıyıcıların toplamı × K_EFOR'dur; saat normalizasyonu 5 ile 11 saat arasında ölçülmüş cebirsel bir özdeşliktir.
  - Yürürlükteki kural: saat/8 teriminin yerini saat verimi alır: min(saat, 8)/8 + max(saat − 8, 0) × 0,5/8 (Ekip §8.2 maddesi). Sekiz saat ve altında eski normalizasyonla aynıdır; sekizi aşan her saat yarım verir. Yapım hızı ve K_EFOR gün verisidir; her tik bunun 7 günlük payını uygular, saatlik tikte 7/24'ünü. Toplantı atlamasının saatlerinde kurucu 1 − 24/40 = 0,4 katsayıyla sayılır, yani bir toplantı kurucunun haftalık çıktısından saat/40 alır (Satış §5.0 maddesi). Kurucu herkes gibi sayılır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §8, §9; sahip kararı 2026-09-27/28.

- **§7 BETA, keşif formülü ve "satır sayaçları + geçen günü gösterir" cümlesi; §22'nin "keşif azalması (6 × 0,85^gün)" girdisi**
  - Eski metin: Günlük keşif = 6 × 0,85^(beta_günü) × Test çarpanları [K]; BETA satırı sayaçları ve geçen günü gösterir.
  - Yürürlükteki kural: Formül ve sabitleri gün verisidir ve eski gün adımlı kalibrasyonu korur: saatlik tikte sönüm, saatin kapsadığı takvim günleri üzerinden tam gün basamaklarıyla integre edilir. Test çarpanı 1,0 iken ilk hafta yaklaşık 27,2 hata bulunur, fazın tamamı 40'a yaklaşır (0,85); `test_automation` düğümünden sonra (0,90) 31,3 ve 60. BETA satırı geçen gün yerine BETA'nın kaçıncı haftasında olunduğunu gösterir.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3; sahip kararı 2026-09-27/28.

- **§8.2 Doğrulama, formülden sonraki iki cümle**
  - Eski metin: Kurucu masaya yalnız Destek'e atanarak girer; Destek'e kimse atanmamışsa masa kapalıdır.
  - Yürürlükteki kural: Masa kadrosu Destek işine atananlar ile pasif ilgideki kurucudan oluşur. Kurucu Destek'e yine atanabilir. Ayrıca ürün canlıyken, kurucu aktif, meşgul değil (izin, eğitim, yatırım hazırlığı, toplantı oturumu) ve hiçbir işe atanmamışsa atanmadan kadroya girer; katkısı temsilcilerinkine eklenir, doğrulama (Müşteri İlişkileri) ve düzeltme koşusu (Yazılım) aynı kadro üzerinden toplanır. Saklanan durum yoktur; okuma kendiliğinden başlar ve biter. Masa yalnız Destek'e kimse atanmamışken kurucu da meşgulse, başka bir işe atanmışsa ya da ürün canlı değilse kapalıdır. "Kurucuyu masaya oturt" fiili yoktur.
  - Kaynak: 8b5bb9e (Destek hattı reworku B1–B2, yönetmen hükümleri).

- **§8.2 Doğrulama, §8.3 İki kademeli zarar ve §8.4 Düzeltme koşusu, oran satırları**
  - Eski metin: Doğrulama/gün = 0,8 × Σ etkin Müşteri İlişkileri × saat/8; zarar her 10 bildirim için −0,6/gün ve −0,3/gün, tavan −2,0/gün; düzeltme/gün = 1,2 × Σ etkin Yazılım × saat/8.
  - Yürürlükteki kural: Oranlar ve katsayılar gün verisidir; her tik 7 günlük payını uygular, saatlik iş akışında 7/24'ünü. saat/8 terimi saat verimidir (§6.1 maddesi). Zarar tavanı önce günlük değere uygulanır, sonra 7 ile çarpılır: tik başına en çok −14 memnuniyet. Toplantı atlamasının saatlerinde masadaki kurucu 0,4 katsayıyla sayılır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §8; sahip kararı 2026-09-27/28.

- **§9 CANLI HATA AKIŞI MODELİ, akış formülü, "Yeni kod terimi" ve "İlgi" maddeleri; §22'nin "τ=21" ve "ilgi yarı ömrü (30 gün)" girdileri**
  - Eski metin: Gelen bildirim/gün formülünde yeni kod terimi e^(−sürüm_yaşı/21) ile, yani yaklaşık 3 haftada söner; ilginin yarı ömrü 30 gündür.
  - Yürürlükteki kural: Akış formülü gün verisidir, tik başına 7 günlük payı uygulanır. Sürekli zaman sabitleri hafta birimiyle tam bölünür, yuvarlanmaz: τ 3 hafta (`SupportSystem.INFLOW_TAU` 3,0), ilginin yarı ömrü 30/7 ≈ 4,29 hafta (`INTEREST_HALF_LIFE`). Akıştaki sürüm yaşı haftadır ve yayın saatinin kesrini taşır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §4; sahip kararı 2026-09-27/28.

- **§10 YAYIN AKIŞI, "yeni fiyat bir sonraki günden itibaren işler", "Fatura günlük olarak burn'e işler" ve aşım satırı; §24'ün §10 notu**
  - Eski metin: Sağlayıcı değişince yeni fiyat bir sonraki günden işler; fatura günlük (aylık/30) burn'e işler; aşımda memnuniyet −0,8/gün, §8.3'ün −2,0 tavanı içinde.
  - Yürürlükteki kural: Yeni fiyat bir sonraki tikte işler. Fatura burn'e günlük oran olarak (aylık/30) işler; kasadan her tik bu oranın 7 günlük payı düşer (ch08 §1 maddesi). Aşım zararı gün verisidir ve tik başına 7 günlük payıyla, §8.3'ün tavanı içinde uygulanır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §6; sahip kararı 2026-09-27/28.

- **§11.3 Pazar çıtası, "Okuma formülü" paragrafı (ilgili: §11.2 "üç hat")**
  - Eski metin: Çıta faz başına tek sabit sayıdır (12,0 / 13,2 / 14,5) ve her eksen için aynıdır.
  - Yürürlükteki kural: Faz çıtası (12,0 · 13,2 · 14,5; faz başına +%10 [K]) üç hat × K1'e kalibredir ve eksen başına okunur: çıta_eksen = çıta_faz × (üründe o eksende fiilen var olan hat sayısı) / 3. Katalog hatları her zaman sayılır; gizli (Ar-Ge) hat ilk kademesi yayınlandığında sayıya girer, açıldığında değil. Ölçeklenen okumadır; ekonominin kullandığı gerçekleşen değer değişmez. eksen_okuması = round(100 × gerçekleşen_eksen / çıta_eksen), 0–120.
  - Kaynak: Ar-Ge GDD rev 1.7 §4.5 (mühürlü) ve YÜRÜRLÜK satırı.

- **§11.3 Pazar çıtası, "Ticker" maddesi ("~10 günde bir [K]")**
  - Eski metin: Çıta başlıkları ticker'a seyrek, yaklaşık 10 günde bir düşer.
  - Yürürlükteki kural: Çıta başlıklarının ayrı bir sıklık sabiti yoktur; haber şeridinin havuzundan gelirler. Şerit tik başına, yani haftada 3 ile 5 satır basar (`NewsFeedSystem.WEEKLY_LINES_MIN/MAX`).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§12.5 Kapı deseni, K3 maddesinin son iki cümlesi; §12.9, "Ar-Ge inmeden önce" cümlesi**
  - Eski metin: Ar-Ge gelmediği için K3'ün araştırma kapısı hep false döner; → Araştır bağlantısı edilgendir.
  - Yürürlükteki kural: Ar-Ge indi. K3'ün araştırma parçası `research.completed(<düğüm>)` okur; düğüm tamamlanınca parça karşılanır. → Araştır bağlantısı Ar-Ge ağacı açılmadan önce (v1 yayınından önce) edilgendir; v1'den sonra canlıdır ve Ar-Ge sekmesini o düğüm seçili hâlde açar.
  - Kaynak: Ar-Ge GDD §2 (ağaç v1'den sonra açılır, mühürlü), §13.6 ve "Bağlayıcı ilişkiler".

- **§12.12 İçerik yazım şartnamesi, "Dil ve lokalizasyon" paragrafı (yalnız dil sırası)**
  - Eski metin: İçerik TR (kanonik, önce yazılır) + EN (edebi çeviri).
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. Her metin bir anahtar olarak doğar; anahtarlar ve kimlikler İngilizcedir. Aynı bölümün "agent yazar, final cilası bizden" cümlesi açık karara bağlıdır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

- **§13 AR-GE SEAM'İ, 2.–5. cümleler; §23 AÇIK İŞLER, 1. madde**
  - Eski metin: Demoda 6 isimli + 6–10 sisli düğüm; aileler Capability · Platform · Practice · Design; araştırma bir atama sütunu değildir; Ar-Ge GDD'si henüz yazılmamıştır.
  - Yürürlükteki kural: Ağacı Ar-Ge GDD'si (rev 1.7) yönetir: 4 aile × 5 yuva (kök, iki dal, iki devam), 20 düğüm; ağacın şekli baştan görünür, açığa çıkmamış yuvalar kilitli durur. Aile kimlikleri iç kimliktir; ekrandaki başlıklar İŞLEV · PLATFORM · SÜREÇ · TASARIM. Araştırma Ekip'in iş listesinde dışlayıcı bir iştir (Ar-Ge §5.0). Eşikler: kök ★1, dal ★2, devam iki alanda ★2 + ★2 (8 devam düğümü). Hız: araştırma/gün = Σ_kişi [max(effective_skill(kişi, gereken alanlar)) × saat verimi] × K_ARGE (1,0 [K]); kişi başına tek katkı; saat verimi Ekip §8.2 maddesindedir. Hız gün verisidir, her tik 7 günlük payını ekler ve süre tahmini haftadır (Ar-Ge §5.4 maddesi). Aile → alan eşlemesi aynıdır. §23'ün ilk maddesi kapanmıştır.
  - Kaynak: Ar-Ge GDD rev 1.7 §3, §5.0, §5.2, §5.4; GDDs/README; `GDD — ZAMAN MODELİ.md` §3, §9; sahip kararı 2026-09-27/28.

- **§15 TALEP ÜRETİMİ, "balayı H = 45 gün [K]" ve orta hesabın en erken talep ayı**
  - Eski metin: Talep faz × müşteri kademesi × 45 günlük balayı ile üretilir; orta hesap en erken 2. ya da 3. ayda ister.
  - Yürürlükteki kural: Üretecin süreleri hafta birimiyle yazılır: balayı H 6 hafta [K] (45 gün ÷ 7, en yakın haftaya yuvarlanmış); "2. ya da 3. ay" ekonomi ayıdır (ay 30 gün). Üreteç henüz bağlı değildir (Ar-Ge §6.4 şerhi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §4; sahip kararı 2026-09-27/28.

- **§24 İNŞA NOTLARI, §12.5 notunun son cümlesi (ERP K3)**
  - Eski metin: Ar-Ge'nin "ERP kayıt-arama K3" vaadine karşılık `line_erp_ledger_k3` ruling gelene dek `semantic_index`'e bağlıdır.
  - Yürürlükteki kural: Ruling geldi. `line_erp_ledger` ERP'nin kimlik Kararlılık hattıdır ve K3'ü `bug_tracker`'a bağlıdır. `semantic_index`'in ERP K3'ü `line_erp_intake_k3`'tür. Öbür ERP K3'leri: cashflow → `analytics_engine`, stock → `design_system`, invoicing → `scalable_backend`. Düğüm kimliklerinin tek kaynağı Ar-Ge GDD'sidir.
  - Kaynak: Ar-Ge GDD YÜRÜRLÜK satırı (rev 1.5, rev 1.6), §4.5.1, "Bağlayıcı ilişkiler".

## Ürün rev 7 · sprint döngüsü (sahip kararı 2026-10-01)

Bu bölüm ch03'ün yapım ve canlı ürün yüzeylerinin, ch12 §3 ve §5'in yerine geçer. Ayrıntılı kural kaynağı
`../docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md`'dir (PRD); PRD ile bu bölüm ayrışırsa bu bölüm geçerlidir. Ajanın verdiği
ve sahip onayı bekleyen kararlar `../docs/ACIK_ISLER/ACIK_KARARLAR.md` 96'dadır; onlar bu bölümün kuralı değildir.

- **ch03 §2 YAŞAM DÖNGÜSÜ, §3 KONSEPT, §10 YAYIN AKIŞI, §16 Frank şeridi, §17 Ürün Monitörü ve Portföy; ch12 §3 Build bar; ch12 §5 onboarding'in Konsept'e açılan sonu**
  - Eski metin: Ürün Konsept ekranında kurulur (yol → tip → özellikler → ad · sorumlu ekip · onay); yapım TASARIM turlarından, GELİŞTİRME'den ve BETA'dan geçer ve yayın akışıyla çıkar (v1: fiyat · altyapı · onay; v2+: tek tık YAYINLA). Canlı ürün sayfası Frank şeridini, Ürün Monitörünü (üçgen, kapasite bloğu, fiyat paneli) ve Portföy'ü taşır. Build bar'ın iki ev sahibi BuildHUD ve Ürün sayfasındaki izleyici kartıdır. Onboarding Konsept'e açılır.
  - Yürürlükteki kural: Ürün sprint sprint geliştirilir. Ürün sekmesi tek ekrandır: başlık satırı, SPRINT görünümü (solda alanlar, ortada bu sprint, sağda sonraki sprint) ve ÇEYREK görünümü. Konsept ekranı, TASARIM/GELİŞTİRME/BETA fazları, iptal, yayın akışı, fiyat paneli, kapasite bloğu, Frank şeridi, Ürün Monitörü, üçgen ve Portföy yoktur. Ürünün pazarı, türü ve adı MVP'den önce Ürün sekmesinin tür seçicisinde seçilir; onboarding değişmez ve ofiste biter. Tür seçilene kadar Ürün sekmesi yalnız tür seçiciyi gösterir. BuildHUD'da yapım kartı yoktur: yayındaki ürünün DESTEK kartı (doğrulanmış hatalar, düzeltme koşusu) ve Ar-Ge çubuğu kalır; Ürün sayfası çubuk taşımaz.
  - Kaynak: sahip kararı 2026-10-01 (1, 2, 4, 9); PRD §1, §2, §3.9.

- **Bölüm yok: Ürün rev 7 geçişinin sahip kararları**
  - Eski metin: GDD bu kararları içermez.
  - Yürürlükteki kural: (1) Faz B tam yapılır: önce sistemler, sonra eski sekme ve geçiş bayrağı silinir; sprint ekranı Ürün sekmesinin kendisidir. (2) Eski yapım motoru (Konsept, tasarım turları, geliştirme, beta, yayın, yapım kaydı, yapımı başlatan ve iptal eden fiiller, yapım lideri ataması, eski hata "sprint"i, BuildBar'ın yapım fazları) onu sınayan smoke vakalarıyla birlikte silinir; eski motoru araç olarak kullanan 13 vaka sprint motoruna taşınır. (3) Ticket doğrulanmış hatadır (`mvp_bugs_confirmed`). Ürün, doğrulanmış hataları yeteneklere deterministik hash'le dağıtan bir ticket defteri tutar; ticket kapatan düzeltme kartı ve ticket açan hatalı çıkış sayacı yeni `ProductState.adjust_confirmed` seam'iyle yazar. DESTEK'in üretim ve düzeltme koşusu kodu değişmez. (4) Ürünün türü (alt-tür, pazar, ad) MVP'den önce Ürün sekmesinde seçilir; onboarding değişmez. (5) B2C fiyatı ve altyapı otomatiktir: Gelir alanının "Ücretli plan" kartı ücretli katmanı en iyi fiyatla açar; altyapı MVP'de önerilen birimle (bulut) kurulur ve her sürümde önerilen pay kadar büyür. (6) MVP, herhangi üç kimlik yeteneğinin K1'e ulaşmasıdır: CANLI v1.0. (7) İçerik (alan cümleleri, ticket başlıkları, sesler, basın, gerçekleşen sonuç cümleleri, lider cümlesi, rakip tablosu) ajan taslağıdır, TR/EN onay bekler. (8) K1, K2, K3'teki yıldız kapıları (kişi ve toplam ★) kilit olarak kalır: kart KİLİTLİ görünür, gerekçe üzerine gelince okunur; K3'ün Ar-Ge kilidi de kalır. (9) BuildHUD'dan yapım kısmı (eski fazlar, "Yayınla") gider; DESTEK'in düzeltme koşusu kartı ve Ar-Ge çubuğu kalır.
  - Kaynak: sahip kararı 2026-10-01.

- **ch03 §2–§9 ve §15, yapım ve canlı ürün kuralları (yerine sprint döngüsü)**
  - Eski metin: Yapım efor ve hızla (efor/gün) ilerler, fazlar oyuncu kararıyla geçilir, yayın oyuncunun onayıyla olur; hata yapım sırasında tohumlanır ve BETA'da bulunur; talep üreteci bağlı değildir.
  - Yürürlükteki kural: Sprint iki tiktir (iki hafta): başlatıldığı tik 1. hafta, ertesi tik 2. hafta, sonraki günlük tikte kapanır. Yetenek mevcut ürün hattıdır, kademesi `ProductState.line_tier` (0–3), adımı `<hat>_k<n>`. Alanlar: Çekirdek (beş kimlik hattı), Onboarding & Erişim (mobil ve gizli self-serve hattı), Büyüme (B2C) ya da Entegrasyonlar (B2B) (entegrasyon hattı), Güven & Ölçek (güvenlik ve dayanıklılık hatları), Gelir (yalnız B2C, tek kademeli "Ücretli plan"); B2B'de Gelir yerine Müşteriler satırı durur. Alan seviyesi yeteneklerin kademe ve cila ortalamasıdır, yarıma yuvarlanır; beklenti fazdan okunur, rakip çıkışı onu artırır; durum Yok · Zayıf · Yeterli · Güçlü. Kartlar: özellik (sonraki kademe), düzeltme (yetenek başına bir kart, açık ticket'larını kapatır; 3+ ticket acildir), araştırma (alan başına "kullanıcıyla görüş"; çıkınca Sesler'e satır ekler, bir sprint gizlenir), talep (B2B), Ücretli plan; cila kartı üretilmez. Kapasite ekipten okunur: aktif kurucu ve ürün tarafındaki aktif çalışanlar (Ürün, Tasarım, Yazılım, Test alanından biri ana ya da ikincil alanı olan), Ar-Ge'deki ve izindeki hariç. Kişi puanı haftada 2 × beceri bandı (rolün ana alanı) × moral bandı × saat verimi; kurucu 1,0, moralsiz, dört role (Ürün, Tasarım, Yazılım, Test) uyar. Kapasite = toplam × 2 hafta; "+" %125'te kapanır. Otomatik atama her hafta başı açgözlüdür, kişi haftada tek kart; fazına uyan kişi yoksa faz yarım hızla yürür; Test'e uyan kimse yoksa uyarı çipi çıkar ve testsiz biten kart hatalıdır. Kademenin lisans bedeli kartın sprinti başlarken bir kez alınır. Kapanışta biten kartlar sürüme girer, etkileri uygulanır, bitmeyenler ilerlemesiyle sonraki sprinte devreder, sürüm notu yazılır. Üç kimlik yeteneği K1'e gelince sürüm CANLI v1.0'dır (`mvp_shipped`, `version_shipped(1)`, `build_phase_changed("shipped")`); sonra araştırma dışında en az bir kart çıkaran her kapanış +0.1'dir (v1.9'dan sonra v2.0); MVP'den önceki kapanışlar sürüm çıkarmaz. Sürümde eksen puanı `mvp_innovation` / `mvp_stability` / `mvp_experience`'a yazılır. Hatalı kart yayına girince %40 ihtimalle (beta kanalından %20) bir ticket açar. Beta açıkken biten kartlar bir sprint bekler, sürüm bir sprint gecikir. Sürüm notu "Beklenen"i kapanışta, "Gerçekleşen"i bir gün sonra yazar. Planlamada ya da sürüm notunda bir gün geçerse sprint liderin önerisiyle kendiliğinden başlar ve TopBar'a not düşer. Lider en yüksek Liderlik'li aktif çalışandır, yoksa kurucu; önerisi sırasıyla verilmiş sözlerin kartları (son tarihi yakın önde), son tarihi en yakın talep, B2C'de Ücretli plan, en zayıf alanın en iyi kartı ve açık acil düzeltmelerdir, kalan yeri kapasiteyi dolduran kartlar doldurur; küçük ekipte tek kartı araştırma olan alan en zayıf sayılmaz. ÇEYREK altı sprinttir: Ürün Yöneticisi varken üç sprintlik plan önerir (hedef alan ağırlıklı), oyuncu onaylar ya da düzenler; PM yoksa görünüm kilitlidir. B2B talebi müşterinin sektör arketipinden alan seçer, imzadan bir sprint sonra ve her yenilemeden altı sprint önce doğar, son tarihi dört sprinttir, değeri yıllık gelirdir; zamanında çıkan talep "memnun" işaretlenir, Satış ekonomisine yazılmaz. Rakip tablosu statiktir (`data/product/rivals.json`): çıkış alan çipine, sonraki sütunun bayrağına, haber bandına ve beklentiye düşer. Karar kartları (iki yol, geride kalan kart, dış destek) koşan bir kart için sprintin 2. haftasının tikinde koşu tohumlu deterministik hash'le istenir; karar bekleyen kart ilerlemez. Aynı sprintte saat çarpanları çarpılarak yığılır. Sürüm notu açıkken Ürün sekmesi saati tutar; pencere kapanınca bırakır, not durumda kalır; kapanan sprint Ürün sekmesini açar.
  - Kaynak: sahip kararı 2026-10-01; sahip kararı 2026-10-02 (2, 9); PRD §3.1–§3.11; `data/product/sprint.json`.

- **Bölüm yok: sprint döngüsünün çalışma değerleri**
  - Eski metin: GDD bu değerleri içermez.
  - Yürürlükteki kural: Hepsi [WORKING], evleri `data/product/sprint.json` ve `data/product/rivals.json`'dur. Sprint 2 hafta · çeyrek 6 sprint · MVP 3 kimlik hattı · efor K1 3, K2 5, K3 8, düzeltme 1 (3+ ticket'ta 2), araştırma 1, talep kademe eforu, Ücretli plan 3 · faz payları özellik ve talep 20/60/20, düzeltme 0/70/30, araştırma Ürün 100 · kişi puanı haftada 2, beceri bandı ham ≤3 → 0,75, ≤6 → 1,0, üstü 1,25, kurucu 1,0 · rolsüz faz hızı %50 · kapasite tavanı %125 · hatalı çıkış %40, beta %20 · beklenti Bootstrap 1, Traction 2, Series A 2; rakip +0,5 (en çok +1), rakip penceresi 3 sprint · cila +0,5 (en çok 1) · acil eşik 3 ticket · araştırma 5 kullanıcı · talep son tarihi 4 sprint, ilk talep imzadan 1 sprint sonra, yenilemeden 6 sprint önce, sözleşme 52 hafta · PM ufku 3 sprint, hedef alan ×1,5, zayıf PM 0,8× kart, hedef şeridi 10 kare (çizgi 5) · karar oranı 0,35 · saat çarpanı 0,5–1,5 · etki ağırlıkları (kademe 1, seviye 2, rakip farkı 1, talep 2, MVP 3, ticket 0,5, uyarı 2, araştırma 0) · arketip → alan (Hevesli → Çekirdek, Fiyat-avcısı → Entegrasyonlar, Bürokratik → Güven & Ölçek, öbürleri → Onboarding). Açık: küçük ekip eşiği (sprint en çok 2 K1 alıyorsa) ve kalibrasyon turunun öbür değerleri (ACIK_KARARLAR 97).
  - Kaynak: sahip kararı 2026-10-01; sahip kararı 2026-10-02 (9); PRD §4.

- **ch03 §0 ve §22.5 (kayıt), Ürün yapımının kayıtta taşınması**
  - Eski metin: Kayıt, sürmekte olan yapımı (`systems.product.active_build`) ve yapım bayraklarını taşır.
  - Yürürlükteki kural: Ürün durumu `GameState.product`'tadır (sprint, sonraki sprint, kartlar, sürüm notu ve sürüm listesi, cila, ticket defteri, talepler, rakip çıkışları, çeyrek); yazarı `SprintSystem`'dir, köprüsü `SprintBridges` yalnız ticket defterini, talepleri ve rakip çıkışlarını yazar. Şema 15'tir. `_migrate_15` v14 kaydını taşır: türü seçilmiş koşu Sprint 1 planlamasında açılır; sürmekte olan yapımın planlanan her kademesi bir özellik kartıdır (tasarımı dolu, geliştirmesi yapımın vardığı yerde, lisansı ödenmiş); hattın şimdiki kademesinin damgası cilaya döner (1,0'ın üstü 0,5; 1,11 ve üstü 1,0); sürüm geçmişi sürüm listesine geçer; yapım ve bayrakları (`creation_draft`, `cancelled_build_prefill`, `product_path_frank_seen`, `mvp_sprint_*`, `mvp_bug_sprint_*`, `bug_count_at_bugfix_start_*`, `mvp_bug_count_at_launch`) düşer; yapımın gizli hataları, tasarım eforu, beta ve iterasyon durumu taşınmaz; doğrulanmış hatalar kalır ve ilk günlük tik onları yeteneklere dağıtır. Türü seçilmemiş koşu tür seçiciyle açılır.
  - Kaynak: sahip kararı 2026-10-01; PRD §3.10 (PRD'nin "v9 → v10"u kodda v14 → v15'tir).

- **Bölüm yok: silinen ve GDD'de adı geçen öğeler**
  - Eski metin: Aşağıdakiler ch03, ch12, Ekip ve olay motoru belgelerinde adıyla geçer.
  - Yürürlükteki kural: Silinmiştir. ch03 §2–§3: yapım kaydı `FeatureBuild`, faz modeli ve "aynı anda tek yapım" kilidi, İptal ve serbest iptal haftası, Konsept akışı (yol, tip, özellik seçimi, ad, sorumlu ekip paneli, maliyet ve süre önizlemesi, taslağın korunması), yapım lideri ataması (`set_build_lead`). ch03 §5–§7: TASARIM turları ve tur tavanları, efor modeli ve yapım hızı (`K_EFOR`, faz taşıyıcıları), yapımda hata tohumlama, BETA keşfi ve test çarpanları, eski hata "sprint"i. ch03 §10: yayın akışı ve yayın fiilleri (`launch`, `ship_active_build`), fiyat paneli (`PriceSlider` varyasyonu), altyapı adımı ve kapasite bloğu (sağlayıcı adı ve kalite satırları, doluluk yüzdesi, öneri satırı). ch03 §12.9 hat listesi ekranı (kilit gerekçesi kartta kalır). ch03 §16 Frank şeridi (`ChromeButton` varyasyonu); şeridin Frank anahtarları CSV'de kalır (ACIK_KARARLAR 96). ch03 §17 Ürün Monitörü, üçgen (`TriangleRadar`, Deneyim ekseni rengi) ve Portföy; "Ücretsiz kullanıcı" toplamı (`CustomerRegistry.get_total_users`). ch03 §19 ve olay motoru: `build_started`, `build_paused`, `build_resumed`, `build_iteration_decision_pending` sinyalleri; `urun.phase`, `urun.build_active`, `urun.build_progress`, `urun.build_paused`, `urun.iteration_round` seam'leri; `dimension_delta`, `bug_delta`, `delay_weeks` (ürün gecikmesi), `ship_active_build`, `enter_development`, `enter_beta` fiilleri; G4'ün build-safe denetimi ve kartların `build_safe` etiketi (olay motoru md §27.10). `product.first_ship`, `product.version_ship`, `product.design_round_intro` kartları `data/events/cards/unwired/`'a taşındı (metin korunur, havuzda değil). ch12 §3 BuildBar'ın yapım fazları, faz ikonları ve "Yayınla" kararı; Ürün sayfasındaki izleyici kartı. Ekip §4.2 ve §17.2: yapım başına ekip ataması ve yapım ekibi lideri. Silinmeyip bağlı olmayanlar: Liderlik'in çıktıyı ölçeklemesi ve koordinasyon çarpanı (Ekip §4.2, §17.2; `HRSystem.leadership_output_mult`, `HRConstants.coordination_for_founder` / `coordination_for_lead`) kodda kalır, yalnız smoke okur, sprint puanına girmez; yeniden yuva listesi `../docs/ACIK_ISLER/ISLER.md`'nin "Ürün rev 7" bölümündedir.
  - Kaynak: sahip kararı 2026-10-01 (2, 9); PRD §5.9.

- **Bu dosyanın bu bölümle hükümsüz kalan maddeleri**
  - Eski metin: Aşağıdaki maddeler silinen yapım akışını anlatır.
  - Yürürlükteki kural: Ürün rev 7 bölümü geçerlidir. ch02 §4 maddesinin "Yapım başına bir ekip lideri atanır … ölçekler" cümlesi (lider yalnız sprint önerisini verir, çıktıyı ölçeklemez); ch02 §5 maddesinin "Aktif yapımı taşıyabilecek kimse boş değilse yapım durur …" cümlesi (sprinte uyan kimse yoksa kapasite 0'dır ve sprint başlamaz); ch03'ün §2 "Build bar hiç kaybolmaz", §2/§3/§6.0 İptal ve süre önizlemesi, §5 TASARIM tur süresi, §7 BETA keşfi maddeleri; §6.1 maddesinin yapım hızı ve K_EFOR kısmı (saat verimi kuralı Destek, Ar-Ge ve sprint puanı için kalır); §12.5 maddesinin "→ Araştır bağlantısı" cümlesi (K3'ün Ar-Ge kilidi kalır); §15 TALEP ÜRETİMİ maddesi (B2B talebi bu bölümdeki kuraldır); ch06 §2 maddesinin "Altyapı adımı v1 yayın akışında sorulur … kapasite bloğundan yönetilir" cümleleri (altyapı otomatiktir; sağlayıcı ve birim etkileri değişmez); ch06 §4 Finans maddesinin "brüt marj canlı ürünün kapasite bloğunda okunur" yarısı (brüt marjın bugün yüzeyi yoktur); ch12 §3 maddesi; Ekip §5.1 maddesinin "geliştirme fazı koşarken +1" kısmı (o hafta bir sprint kartında çalışana +1); Ekip §17.2 maddesinin kaldıraç tablosu ve ekip lideri akışı.
  - Kaynak: sahip kararı 2026-10-01.

## Kalibrasyon turu · ürün rev 7 (2026-10-02/03)

Bu bölüm ürün rev 7'nin ardından yapılan kalibrasyon turunun sahip kararlarını ve değişen kuralları kaydeder. Servis
maliyetinin kuralı ch06 §1.1 ve ch08 §1 maddelerindedir. Turun ölçülen değerleri, kartları ve ajan kararları
`../docs/ACIK_ISLER/ACIK_KARARLAR.md` 97'de, ölçümün tutmayan ve açık kalan yerleri 98–102'dedir; onlar bu bölümün
kuralı değildir.

- **Bölüm yok: kalibrasyon turunun sahip kararları**
  - Eski metin: GDD bu kararları içermez.
  - Yürürlükteki kural: (1) Söz sprinte bağlanır: son tarih bir sonraki planlanabilir sprintin sonudur; söz planlamada görünür ve lider onu önce önerir; kırık sözden sonra o hesaba hemen yeni söz açılmaz. (2) MVP yaklaşık 6. haftadadır: kurucu üç fazı da (Tasarım, Yazılım, Test) yapar, Ürün rolü araştırma kartı içindir; MVP üç kimlik hattıyla kalır; MVP öncesine karar olayları eklenir. (3) B2C iki sona da ulaşabilir (ch01 §7): iflas etmez, Traction'a çıkar; profitable_bootstrap ve Series A kapısı (120K MRR, sahibin kilidi, değişmez) ulaşılabilirdir. (4) Geç oyunun baskısı sistem ve olaylarla kurulur: ch08'in boş gider kalemleri bağlanır (kişi başı araçlar, müşteriyle ölçeklenen servis maliyeti), Traction ve Series A Hunt'ta nakit maliyetli kartlar gelir; ofis kirası bağlanmaz (2026-09-27 kararı). (5) Servis maliyeti, 2026-09-27/28'deki "servis maliyeti yalnız sunucu faturasıdır" kuralını geri alır. (6) "Gelirin önünde harcama" kabul edilir: yeni hesap ilk 4 haftasında gelirinin bir katı kadar servis maliyeti taşır; karar Traction için 0,5×, Series A Hunt için 3× dedi. (7) Kurucunun 50 $/gün'ü Araçlar kaleminin tabanıdır. (8) Kırık söz kilidi sürelidir: o hesaba 8 hafta yeni söz verilmez. (9) Kurucu çarpanı 1,0'dır: tek kurucunun sprinti 4 puandır, 1 puan pay kalır, MVP 7. tiktedir. (10) Söz ancak sığarsa verilir: söz satırı yalnız adım planlanabilir sprintin boş kapasitesine sığıyorsa açıktır; kilit gerekçesi "Bir sonraki sprintte buna yer yok."; kural bütün söz satırlarına ve satış toplantısındaki söze uygulanır. (11) B2C'de önce bot destek masasını erken doldurur ve yeniden ölçülür; kapı yine kapalıysa fiyatın her sürümde güncellenmesi ayrıca sorulur. Ölçümde kapı açıldı, soru doğmadı: fiyat ücretli plan açılınca bir kez konur. (12) Faz 3'ün ölçütü "runway sonlu" değil "karar kalır"dır: rakip fonlaması ve pencere kartları tekrarlanır, gelirin önünde harcama seçeneği sunan kart eklenir, sabit gider artmaz.
  - Kaynak: sahip kararı 2026-10-02 (1–12).

- **Satış §6 söz kuralları: sözün son tarihi, kırılması ve yeniden söz**
  - Eski metin: Söz verildiği günden iki haftalıktır (`B2BConstants.PROMISE_DEADLINE_WEEKS` 2) ve vade tiki dahil sayılır; kırık sözden sonra aynı hesaba hemen yeni söz verilebilir.
  - Yürürlükteki kural: Ürün türü seçilmişse söz sprinte bağlıdır. Sözün sprinti, verildiği anda planlanabilir ilk sprinttir: sprint planlamadaysa bu sprint, koşuyorsa bir sonraki (`SprintSystem.plannable_sprint`, talebin son tarihiyle aynı hesap; `Promise.due_sprint`). O sprint kapanınca adım canlı değilse söz kırılır; adımın kartı betada bekliyorsa bir sprint pay verilir. O kapanışa kadar çıkan adım sözü tutar. Satış kartı sözü "Sprint N sonuna kadar" okur; planlamada sözlü kart "söz verildi" damgasını, etki satırında ve öngörüde müşterinin adını taşır; lider sözlü kartları önce önerir. Tür seçilmeden verilen söz hafta kuralıyla kalır. Söz yalnız sığarsa verilir: adımın kalan puanı ile o sprinte borçlu, henüz planlanmamış açık sözlerin adımları (her adım bir kez sayılır) planlanabilir sprintin boş kapasitesine sığmalıdır (`SprintSystem.fits_plannable`); sığmıyorsa bütün söz satırları (elde tutma, Müşteri Başarısı tırmanması, talep kartları, rakibin fiyat kırması) ve satış toplantısının söz cevabı "Bir sonraki sprintte buna yer yok." gerekçesiyle kilitlidir. Söz kırılınca o hesaba 8 hafta yeni söz verilmez (`B2BConstants.PROMISE_RELOCK_WEEKS`; gerekçe "Bu hesaba verdiğin son söz tutulmadı."); kilit kalktıktan sonra verilen söz memnuniyete yarım katkı yapar. Kırık sözün cezaları değişmez. ACIK_KARARLAR 80 kapanmıştır.
  - Kaynak: sahip kararı 2026-10-02 (1, 8, 10).

- **Bölüm sessiz: B2C memnuniyetinin kayması (Ürün ch03, Satış §3.1)**
  - Eski metin: GDD B2C memnuniyetinin kaymasını sayıyla tanımlamaz. Kod, deneyim ekseni 40'a (`SATISFACTION_QUALITY_GATE`) ulaşınca memnuniyeti günde +1, canlı hata 5'i aşınca günde −1 kaydırıyordu; 40'ın gerekçesi yoktu (ACIK_KARARLAR 34).
  - Yürürlükteki kural: B2C memnuniyeti deneyim ekseni puanına doğru kayar, B2B'nin birinci katmanı gibi: hedef deneyim okumasıdır, memnuniyet hedefe günde en çok bir adım yaklaşır ve hedefte durur; canlı hata `SATISFACTION_BUG_GATE`'in (5) üstündeyken üstüne bir itiş düşülür, yani birikim memnuniyeti hedefin altında tutar. Adım ve itiş gün verisidir, tik başına 7 günlük payı uygulanır (`SalesSystem.SATISFACTION_DRIFT_PER_DAY`, `SATISFACTION_BUG_PUSH_PER_DAY` [WORKING]). Eşik kapısı yoktur. ACIK_KARARLAR 34 kapanmıştır. Açık: adım ve itiş değerleri (97).
  - Kaynak: sahip kararı 2026-10-02 (3).

- **Bölüm sessiz: B2C ürün değerinin genişlik ve derinlik girdisi (Ürün ch03)**
  - Eski metin: Ürün değeri yayınlanan düz özelliklerin sayısını ve karmaşıklığını okuyordu (`mvp_components`); hat ürünlerinde liste boş olduğu için bu katkı 0'dı (ACIK_KARARLAR 43).
  - Yürürlükteki kural: Ürün değeri (ücretli planın açılış fiyatı, dönüşüm, zam tepkisi, fiyat duyarlılığı) genişliği açık hat sayısından (`ProductState.lines_open`), derinliği canlı kullanım ağırlığı toplamından (`usage_weight_total`) okur; ağırlıklar [WORKING] (`SalesSystem.VALUE_FEATURE_COEF`, `VALUE_COMPLEXITY_COEF`). Aşınmanın ve hata riskinin karmaşıklık terimi bu maddenin konusu değildir. Açık: ağırlıklar (97) ve 43'ün kalanı.
  - Kaynak: sahip kararı 2026-10-02 (3).

- **Ürün ch03 §9 "İlgi" maddesi (bölüm sessiz: B2C kitlesinde ilginin yeri)**
  - Eski metin: İlgi sürümün tazeliğidir; bölüm B2C kitle formülünde hangi terime girdiğini söylemez. Kod ilgiyi yalnız B2B musluğunda okuyordu.
  - Yürürlükteki kural: İlgi B2C'nin taban kazanımını da çarpar, B2B musluğunun okuduğu bantla (`SalesConstants.interest_mult`): taze sürüm kullanıcı çeker, yaşlanan sürüm akışı yavaşlatır. Ağızdan ağıza büyüme ve churn ilgiyi okumaz.
  - Kaynak: Ürün GDD (ch03) §9; sahip kararı 2026-10-02 (3).

- **ch08 §1 Burn, "araçlar" satırı; ch02 §11 yaşam gideri**
  - Eski metin: Burn maaşlar, araçlar, servis ve pazarlamadan oluşur; bölüm araçların tutarını vermez. Ekip GDD §9.1'de yaşam gideri yoktur. Kodda araçlar kalemi yoktu; 1. günün bütün burn'ü 50 $/gün'lük "kurucu yaşam gideri" kalemiydi (ACIK_KARARLAR 21).
  - Yürürlükteki kural: Araçlar, işin döndüğü yazılım, lisans ve donanımın aylık faturasıdır: evre tabanı + evre oranı × bordrodaki çalışan; kurucu çalışan sayılmaz, izindekiler sayılır (koltukları ödenir). Aylık değerler Bootstrap 1.500 + 150, Traction 1.500 + 300, Series A Hunt 5.500 + 500 $ (`FinanceSystem.TOOLS_BASE_MONTHLY`, `TOOLS_PER_EMPLOYEE_MONTHLY` [WORKING]). Kurucunun 1. gündeki 50 $/gün'ü bu kalemin Bootstrap tabanıdır: 1. günün burn'ü ve runway'i değişmez (10K $ ile ~6,6 ay); ayrı bir kurucu yaşam gideri kalemi yoktur. Kalem finans tikinde maaşlarla birlikte çekilir ve burn'e günlük oran olarak işler; işe alım önizlemesi ve işten çıkarma onayı araç farkını da gösterir. ACIK_KARARLAR 21 kapanmıştır.
  - Kaynak: sahip kararı 2026-10-02 (4, 7); Ekip GDD §9.1.

- **ch08 §1 tek seferlik giderler ve §4 ay defteri (bölüm sessiz: olay kartının nakdi)**
  - Eski metin: Bölüm olay kartlarının nakit hareketinin hangi deftere yazıldığını söylemez. Kod kasayı doğrudan yazıyordu; tutar ay defterine, kâr serisine ve işlem listesine girmiyordu.
  - Yürürlükteki kural: Olay kartının nakdi (`add_cash`) Finans'ın tek seferlik kapısından geçer: eksi tutar tek seferlik giderdir (ay defterinin giderine ve işlem listesine yazılır), artı tutar tek seferlik gelirdir (işlem listesine yazılır). Kart, işlem listesindeki satırın adını `FinanceSystem.ONE_TIME_LABELS`'tan seçer; etiketsiz ya da bilinmeyen etiketli kart olay lint'inde hatadır (olay motoru md §27.11). Açık: artı tutarın ay gelirine yazılmaması (97).
  - Kaynak: sahip kararı 2026-10-02 (4).

## GDD v2 — 06 · Operations

- **§1.1 Servis maliyeti, formül satırı, "Product type changes the slope" cümlesi ve "Reader" satırı**
  - Eski metin: serving_cost = provider_fixed(tier) + unit_cost(tier) × usage; ürün tipi eğimi belirler; okuyucu Finans'ın "Servis maliyeti" burn satırı ve ay kapanışındaki brüt marjdır.
  - Yürürlükteki kural: Servis maliyeti iki kalemdir: sunucu faturası ve müşteriyle ölçeklenen servis maliyeti. (1) Sunucu faturası = satın alınan kapasite birimi × sağlayıcının birim fiyatı. Birim fiyatı pazara göredir: B2C 1.000 kullanıcı/ay, B2B 50 koltuk/ay başına (Yerel 35/30, Bulut 55/45, Kurumsal Bulut 85/70 [K]). Faturada sabit sağlayıcı ücreti ve kullanımla orantılı terim yoktur. Kullanım faturaya dolulukla girer: doluluk = kullanıcı ya da koltuk / etkin kapasite; etkin kapasite = birim / yük; yük = 1 + Σ kullanım ağırlığı / 20 [K]. (2) Servis maliyeti, büyüyen müşteri defterine hizmet etmenin aylık bedelidir: B2B'de hesap başı 45 $ + koltuk başı 8 $ × yük, ayrıca ilk 4 haftasındaki (onboarding) her hesap için MRR'ı × evre katı ("gelirin önünde harcama": Bootstrap 0, Traction 0,25, Series A Hunt 3); B2C'de 1.000 kitle başı 700 $ × yük (`InfraSystem.SERVICE_PER_ACCOUNT_B2B`, `SERVICE_PER_SEAT_B2B`, `SERVICE_PER_1K_USERS_B2C`, `ONBOARDING_MRR_MULT` [WORKING]). Ağır (AI) özellikler iki kaleme de yük üzerinden biner; ürün tipi eğimi buradan değiştirir. Canlı ürün yokken iki kalem de 0'dır. İkisi de burn'e günlük oran olarak (aylık/30; "servers" ve "service" kalemleri) işler; kasadan her tik (hafta) bu oranın 7 günlük payı düşer (ch08 §1 maddesi). Brüt marj = MRR − sunucu faturası − servis maliyeti. Okuyucu Finans'ın gider dökümü ve brüt marjdır; ay kapanışı ekran açmaz, dönem özeti Ayarlar'da seçilen sıklıkla gelir (ch08 §4 maddesi). Açık: Traction katı (sahip kararı 6 0,5× dedi, ölçüm 0,25 verdi) ve servis değerleri (ACIK_KARARLAR 97).
  - Kaynak: Ürün GDD rev 6.1 §10 (mühürlü) ve §23 ("Operasyon — KAPANDI"); `GDD — ZAMAN MODELİ.md` §3, §6; sahip kararı 2026-09-27/28; sahip kararı 2026-10-02 (4, 5, 6).

- **§1.2 Destek yükü, formül satırı, "load > capacity" satırı ve "Reader" satırı**
  - Eski metin: yük = a·aktif_hesap + b·canlı_hata + c·sürüm_yaşı; kapasite = throughput × atanan × Müşteri Başarısı × Hız; aşımda yanıt süresi kötüleşir.
  - Yürürlükteki kural: Destek iki sayaçla çalışır: GELEN BİLDİRİM ve DOĞRULANMIŞ HATA. Doğrulama/gün = 0,8 × Σ Müşteri İlişkileri etkin çıktısı × saat verimi [K]; düzeltme/gün = 1,2 × Σ Yazılım etkin çıktısı × saat verimi [K]; saat verimi sekiz saate kadar saat/8'dir, sekizi aşan her saat yarım verir (Ekip §8.2 maddesi); Hız yoktur. Yük tarafı Ürün §9'un GELEN akışıdır. Ayrı bir yanıt süresi sayısı yoktur; zarar iki kademelidir: doğrulanmamış her 10 GELEN için −0,6/gün, doğrulanmış açık her 10 için −0,3/gün, tavan −2,0/gün [K]. Oranlar ve zarar gün verisidir; her tik 7 günlük payını uygular, tavan önce günlük değere uygulanır (tik başına en çok −14). Toplantı atlamasının saatlerinde masadaki kurucu 0,4 katsayıyla sayılır (Satış §5.0 maddesi). Okuyucu DESTEK barının iki sayacı ve ısınma çizgisidir (20/40). Açık: akıştaki taşınan hata teriminin uygulanışı (ACIK_KARARLAR 45).
  - Kaynak: Ekip GDD §17.6; GDDs/README (ch06 §1.2 → Ekip §17.6); Ürün GDD rev 6.1 §8.1–§8.5, §9; `GDD — ZAMAN MODELİ.md` §3, §8, §9; sahip kararı 2026-09-27/28.

- **§2 Altyapı giriş cümlesi, §2.1 Provider, §2.2 Capacity; §7 Open decisions, 4. madde**
  - Eski metin: Üç kurgusal sağlayıcı (Northwind / Halcyon / Vireo) güvenilirlik ve gecikme tabanını belirler; yetersiz kapasite kesinti olasılığını artırır; altyapı adımı her sürümde sorulur; sağlayıcı adları açıktır.
  - Yürürlükteki kural: Sağlayıcılar Yerel Sağlayıcı, Bulut Sağlayıcı, Kurumsal Bulut'tur; birim fiyatı ve kalite etkisiyle ayrışırlar (Yerel: GELEN ×1,25; Bulut: nötr). Sağlayıcı canlıda her an bedelsiz değişir, yeni fiyat bir sonraki tikte işler; kapasite her an ±1 birim, cezasız. Doluluk %80–100'de kapasite çubuğu sararır; %100'ün üstünde memnuniyet −0,8/gün (gün verisi, tik başına 7 günlük payı), GELEN ×1,5, B2C edinim ×0,6 [K]. Etkiler deterministiktir; rastgele kesinti yoktur. Altyapı adımı v1 yayın akışında sorulur (B2C: Fiyat → Altyapı → Onay; B2B: Altyapı → Onay); v2+ tek tık YAYINLA'dır. Sağlayıcı ve kapasite canlı ürünün kapasite bloğundan yönetilir. §7'nin adlar sorusu kapanmıştır. Açık: kurumsal güven koşulu (ACIK_KARARLAR 4), kapasite uyarı kartı (42), 0 birimde tek adımlı ALTYAPI (55), §2.3 ve §3'ün kesinti olayları.
  - Kaynak: Ürün GDD rev 6.1 §10 (mühürlü), §23, §24 (direktör hükmü 2026-08-25); `GDD — ZAMAN MODELİ.md` §3; sahip kararı 2026-09-27/28.

- **§4 Links, "HR (02/07)" satırı; §1.3 "assign the founder … lock"; §5 First bite, "the founder lock"**
  - Eski metin: HR Operasyon ve Müşteri Başarısı yeteneklerini okur; kurucu atama kilidi (yapım/satış/fon toplama) vardır.
  - Yürürlükteki kural: Operasyon bir yetenek ya da alan değildir. Destek işini Müşteri İlişkileri (doğrulama) ve Yazılım (düzeltme) taşır. Kurucu kilidi yoktur; kısıt bir yasak değil bir sonuçtur: kurucu yeni yapıma geçer ve Destek boş kalırsa GELEN birikir, memnuniyet erir. §5'in "ilk ısırığı" budur.
  - Kaynak: Ekip GDD §2.1, §4, §12.0; Ürün GDD rev 6.1 §8.2, §8.4, §8.6.

- **§4 Links, "Finance (08)" satırı ("monthly close deltas")**
  - Eski metin: Operasyonun Finans yüzeyi servis maliyeti satırı, brüt marj ve ay kapanışındaki deltalardır.
  - Yürürlükteki kural: Ay kapanışı ekran açmaz ve delta göstermez (ch08 §4 maddesi). Ayarlar'dan sıklığı seçilen dönem özeti MRR, nakit, ekip ve marka değişimini okur; servis maliyeti deltası taşımaz. Sunucu faturası ve servis maliyeti Finans'ın gider dökümünde ("servers" ve "service" kalemleri), brüt marj canlı ürünün kapasite bloğunda okunur.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §6; sahip kararı 2026-09-27/28; sahip kararı 2026-10-02 (5).

## GDD v2 — 08 · Finance & Economy

- **§1 Burn, 4. satır (servis maliyeti)**
  - Eski metin: Servis maliyeti Ops'tan gelir: sağlayıcı kademesinin sabit ücreti + birim × kullanım.
  - Yürürlükteki kural: Servis maliyeti iki kalemdir: sunucu faturası (kapasite birimi × sağlayıcının birim fiyatı, Ürün §10; burn'ün "servers" kalemi) ve müşteriyle ölçeklenen servis maliyeti (hesap, koltuk ve kitle başı bedel ile yeni hesabın ilk 4 haftasındaki gelirin önünde harcama; burn'ün "service" kalemi). Formüller ch06 §1.1 maddesindedir. Canlı ürün yokken ikisi de 0'dır; burn'e günlük oran (aylık/30) olarak işler, kasadan her tik bunun 7 günlük payı düşer. Araçlar kalemi "Kalibrasyon turu · ürün rev 7" bölümündedir. Açık: brüt marj (§2).
  - Kaynak: Ürün GDD rev 6.1 §10, §23; `GDD — ZAMAN MODELİ.md` §3, §6; sahip kararı 2026-09-27/28; sahip kararı 2026-10-02 (4, 5, 6).

- **§1 Burn, 1. satırdaki tek seferlik giderler ("Atlas retainer"); §8 Links, "HR (07)" satırı**
  - Eski metin: Tek seferlik burn'de Atlas retainer'ı var; HR chapter 07 olarak ve retainer maliyetiyle anılır.
  - Yürürlükteki kural: Retainer yoktur. Atlas araması ücretsizdir; işe alımın tek bedeli, işe alım anında tek seferlik gider olarak düşen bir aylık maaşın %50'si komisyondur. Eğitim bedeli hedef alanın mevcut seviyesine göre kademelenir, tek seferlik giderdir. §8'in HR satırı: maaşlar, işe alım komisyonu, eğitim, zamlar (Ekip GDD). Parantezdeki "lisans" ve "kesinti telafisi" kalemleri bu maddenin konusu değildir.
  - Kaynak: Ekip GDD §0, §5.3, §9.2, §10.

- **§1 Burn ve §2 Revenue (bölüm sessiz: nakdin hangi adımla aktığı)**
  - Eski metin: Bölüm burn'ü ve geliri aylık kalemlerle tanımlar; nakdin kasaya hangi sıklıkla işlediğini söylemez.
  - Yürürlükteki kural: Bir tik bir haftadır. Aylık kalemler (MRR, maaşlar, araçlar, sunucu faturası, servis maliyeti) günlük orana çevrilir (÷30; ekonomi ayı `TimeModel.DAYS_PER_MONTH` 30) ve her tik bunun 7 günlük payını uygular: kasa += 7 × (round(MRR / 30) − günlük burn). Bu çarpımın tek yeri finans tikidir (`FinanceSystem.daily_tick`); maaş, araçlar, sunucu faturası, servis maliyeti ve ek mesai günlük oran olarak kalır. Tek seferlik giderler anında düşer. TopBar'ın burn ve net rakamları canlı aylık hızdır (/ay).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §6; sahip kararı 2026-09-27/28.

- **§3 Health readouts, "Runway" ve "Artıda serisi" satırları (bölüm sessiz: uyarının anı)**
  - Eski metin: Runway mevcut burn'de kalan aydır; Artıda serisi ay sayar; bölüm uyarının ne zaman verildiğini söylemez.
  - Yürürlükteki kural: Runway ay birimiyle kalır (kasa / günlük net açık / 30); 1 ayın altında kalan hafta okunur. Artıda serisi ay kapanışlarıyla sayılır (§4 maddesi). Uyarılar özet sıklığından bağımsız ve anındadır: runway 3 ayın altındayken Finans sekmesi rozet taşır; runway 3 ya da 1 ay eşiğini aşağı geçtiği tikte haber bandına tek satır düşer (`FinanceSystem.RUNWAY_ALERT_MONTHS` [3, 1] [WORKING]). Satır her eşiği inişte bir kez duyurur; runway eşiğin 0,5 ay üstüne çıkınca ya da sonsuz olunca eşik yeniden kurulur (`RUNWAY_ALERT_REARM_MONTHS`). Kepenk kartı ve TopBar kepenk sayacı da anındadır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §6; sahip kararı 2026-09-27/28.

- **§4 Monthly close (one screen)**
  - Eski metin: Her ay tek bir kapanış ekranı açılır: gelir, gider dökümü, net, brüt marj ve değişimin nedeni, kasa ve runway, Artıda serisi, ayın üç önemli olayı.
  - Yürürlükteki kural: Ay kapanışı sessizdir ve ekran açmaz. Bir hafta, Perşembe'sinin düştüğü aya aittir; ay 4 ya da 5 haftadır ve yeni ayın ilk tikinin başında, o haftanın akışından önce kapanır. Kapanışta ay defteri kapanır, TopBar'ın aylık rakamları yenilenir ve haber bandına tek satır düşer (`MONTH_CLOSED_TICKER`: "{month} kapandı · MRR {mrr} · nakit {delta}"); satır yalnız canlı akar, arşive girmez. Özet ekranı ayrı bir dönem özetidir; sıklığı Ayarlar'dan seçilir: haftalık, aylık, çeyreklik ya da yıllık, varsayılan çeyreklik (`summary_frequency`, `SummarySystem`). Çeyrek Ocak, Nisan, Temmuz ya da Ekim'e dönen ayda, yıl Ocak'a dönen ayda kapanır. Dönem özeti ekran değil, Olaylar gelen kutusunda Muhasebe'den gelen bir mesajdır: MRR, kasa, ekip (kurucu dahil), marka ve runway satırları dönemin başı ve sonuyla, ve dönemin olayı. Mesaj kutuda kendiliğinden açılır ve oyunu duraklatır; kutudan çıkınca hız döner.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §5, §6; sahip kararı 2026-09-27/28; olay motoru GDD rev 2 §27.14; sahip kararı 2026-10-02 (Olaylar gelen kutusu).

- **§6 Shutter, 1. ve 2. satır; §9 Open decisions, 1. madde**
  - Eski metin: Kasa sıfırın altına inince 30 günlük kepenk sayacı başlar [WORKING; 21'e inebilir]; TopBar'da "Kepenk: 23 gün" görünür. §9 kepenk uzunluğunu 30 mu 21 mi diye sorar.
  - Yürürlükteki kural: Kepenk 4 haftadır (`EndingsSystem.SHUTTER_WEEKS` [WORKING]); sayaç hafta sayar ve TopBar'da kalan haftayı gösterir. Sıfıra inen sayaç iflas sonudur. Frank sayacın başında bir kez konuşur. §9'un sorusu hafta birimiyle sorulur: 4 hafta mı 3 hafta mı.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

## GDD v2 — 09 · Funding & Investors

Bu bölümdeki maddeler yalnız Series A içindir; seed akışı (§3, §4 "not now") ACIK_KARARLAR'daki "Seed garanti basamaktır" ve K18–K22'de açıktır. §4'ün oturum süresi ve saat atlaması maddesi seed pitch'ini ve seed masasını da kapsar.

- **§4 The meeting (bölüm sessiz: görüşme ayarlama)**
  - Eski metin: Bölüm aynı anda kaç görüşme olabileceğini, iptali ve ertelemeyi söylemez.
  - Yürürlükteki kural: Aynı anda tek görüşme ayarlanır. Görüşme iptal edilebilir ya da ertelenebilir; ikisi de o fonun bir sonraki görüşmesinde küçük bir inanç cezası bırakır [K].
  - Kaynak: sahip kararı K4 (ONERI_v3 §0A, "uygula"); 28d5edc.

- **§4 The meeting (bölüm sessiz: görüşmenin zamanı ve saate etkisi)**
  - Eski metin: Bölüm görüşmenin ne zaman yapıldığını, ne kadar sürdüğünü ve oyun saatine etkisini söylemez.
  - Yürürlükteki kural: Series A görüşmesi talepten bir hafta sonraya ayarlanır (`PitchConstants.MEETING_LEAD_WEEKS` 1); ertelenen görüşme aynı süre kadar kayar. Hazırlık bir hafta sürer ve yalnız görüşmeye en az bir hafta varken başlatılabilir (`PREP_WEEKS`, `PREP_MIN_WEEKS_BEFORE` 1); bir haftalık randevuda bu, randevunun alındığı haftadır. Görüşme (seed ve Series A pitch'i) ve term sheet masası birer oturumdur: oturum açıkken saat durur ve kurucu meşguldür. Oturum bitince saat oturumun süresi kadar ileri atlar: pitch 2 saat, masa 1 saat [WORKING] (`MEETING_HOURS`, `TERM_TABLE_HOURS`); ilk vuruşta çekilen görüşme yarım süre, 1 saat yer; koşuyu bitiren imzada atlama olmaz. Atlama kurucunun mesai bitimini ve gece yarısını geçmez, kalanı gece atlaması taşır; atlanan saatler kurucunun haftalık çıktısından saat/40 payını alır (Satış §5.0 maddesi). Tek giriş kapısı (`WorkHoursSystem.sitting_open`, satış toplantısıyla ortak): gece ise ya da saat, kurucunun mesai bitiminden oturum süresi çıkarılınca kalan saati geçmişse görüşme ve masa açılmaz; giriş yüzeyleri nedenli kilit gösterir. Bu oturumlar satış toplantılarının haftalık tavanına sayılmaz. Kurucu oturuma ofisten çıkıp şehir haritası üzerinden gider (ch12 ofis kademesi maddesi). Series A görüşmesinin haftası gelince fon arar ve oyuncu görüşmeyi bir kez erteleyebilir; seed pitch'inin çağrısı yoktur (`GDD — ZAMAN MODELİ.md` §8.6).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4, §8; sahip kararı 2026-09-27/28; görüşme akışı kararları (Erdem, 2026-09-28/29: her görüşmede davet, VC çağrısı bir kez ertelenir, seed çağrısız).

- **§4 The meeting, 1. satır ("a decision scene"; bölüm sessiz: masadaki kişiler ve sunum)**
  - Eski metin: Görüşme bir karar sahnesidir; kimin konuştuğunu, fonun kimlerle masaya oturduğunu ve sahnenin nasıl sunulduğunu söylemez.
  - Yürürlükteki kural: Görüşme ayrı bir sahne değildir: kabuğun içinde, toplantı odasında (ch12 ofis kademesi maddesi) masa ve sağda görüşme paneliyle oynanır; üst bar, ray ve haber bandı görünür ama tıklanmaz. Her fonun üç kişisi masadadır: lider (fonun unvanıyla), ortak ve analist. Kişiler koşu başında tohumdan çekilir (ad, cinsiyet, 3B görünüm) ve kayda girer; adları koşunun başlangıç diline göre Türkçe ya da İngilizce havuzdan gelir. Açılışı ve kapanışı lider, anlatıyı ortak konuşur; sorgu fonun alanına göre analistten (metrik, ürün) ya da ortaktan gelir, seed odasında ortaktan. Panel konuşanın portresini, TUTUM'u (ikna 0–100; sözcükleri sıcak ≥70, ılık ≥40, temkinli ≥25 [WORKING], soğuk; 70 ve 40 kuralın sınırlarıdır), HAFIZA'yı (fonun hatırladığı ilk neden), konuşma dökümünü ve seçenekleri gösterir. Zarlı seçenek yalnız risk sözcüğünü gösterir (güvenli ≥0,62, riskli ≥0,40, tehlikeli [WORKING]); yüzde ve etkenleri (beceri, hazırlık, oda zorluğu) "ZAR ATILACAK" ipucundadır. Sonuç kartı sonucu, masaya etkisini, liderle ilişkinin önce ve sonrasını ve fonun hafızasına yazılanı gösterir. Fonun kişileri 3B bust'larıyla görünür: görüşme panelinde, toplantı odasında ve term sheet masasında (lider). Kurallar ve sonuçlar değişmez. Başlangıç dili kuralı satış muhataplarına (Satış §5.1.1 maddesi) ve işe alım adaylarına da uygulanır; mevcut çalışanların adları değişmez. Açık: eşikler ve tasarımdan sapmalar (ACIK_KARARLAR 93), metin (95).
  - Kaynak: görüşme akışı kararları 1–3, 6–8 (Erdem, 2026-09-28/29; Claude Design "Yatırımcı Görüşmesi v3"); 1888fe4, eba2140, cf80260.

- **§5 Term sheet (bölüm sessiz: teklifin süresi, sayısı ve gösterimi)**
  - Eski metin: Bölüm teklifin ne kadar geçerli kaldığını, aynı anda kaç teklif olabileceğini ve teklifin masadan önce nasıl gösterildiğini söylemez.
  - Yürürlükteki kural: Teklif 3 hafta geçerlidir (`PitchConstants.SHEET_VALIDITY_WEEKS` 3): verildiği tikten itibaren 3 tik canlı kalır, karar 4. tikte gelir. Hafta sonu ve iş günü yoktur; K5'in 10 iş günü ve yalnız hafta içini sayan geri sayımı kalkmıştır. Süre uyarısı (uyarı kartı ve üst bardaki teklif çipi) son 2 haftada görünür (`WARNING_WEEKS` 2), son cevap kartı (`funding.last_answer`) son haftada gelir. Bütün geri sayımlar (masadaki kâğıt, Yatırım sekmesi, üst bar çipi, olay kapsamı) tek sayıyı okur: kalan hafta (`TermSheet.weeks_left`). Bu, ACIK_KARARLAR'ın 58. maddesini kapatır: masadaki kâğıt takvim günü, öbür Series A geri sayımları iş günü sayıyordu; artık tek birim haftadır. Aynı anda en çok 2 canlı teklif olur; fazlası bekler ve bekleme sırası oyuncuya görünür (K8). Masaya oturmadan önce teklif net sayı değil tahmini aralık gösterir: yaklaşık değerleme ve yaklaşık pay; yönetim kurulu şartı ve ayrıntı masada açılır (K6).
  - Kaynak: sahip kararları K6, K8 (ONERI_v3 §0A, "uygula"); 28d5edc; `GDD — ZAMAN MODELİ.md` §1, §4; sahip kararı 2026-09-27/28 (K5'in yerine 3 hafta).

- **§5 Term sheet, 3. satır ("accept · negotiate once · decline")**
  - Eski metin: Oyuncu kabul eder, bir kez pazarlık eder (riskli: fon kalkabilir ya da şartları sertleştirebilir) ya da reddeder.
  - Yürürlükteki kural: Series A masasında oyuncu fonun sabır havuzuna karşı birden çok kez itebilir. Her itiş görünür ihtimalli bir kontroldür; başarısız itiş sabrı 1 düşürür. Sabır 0'a inince fon, istekliliğine (E) göre ya son karşı teklifini "al ya da bırak" diye koyar (yalnız İmzala / Kalk) ya da masadan kalkar; kalkan fon koşu boyunca kapanır (K12). Oyuncu masada bir kez öbür canlı Series A teklifini gösterebilir; fonun cevabı (eşler / şartla eşler / yerinde durur / kalkar) dinamik hesaplanır (K7). Süresi dolan teklif kendiliğinden kapanmaz; ertelenemez bir karar kartı "Masaya otur / Reddet" sorar, reddedilen fon kalıcı olarak kapanır (K10). Açık: bu kapanmaların reddedilme zincirine sayımı (K14), E modelinin sabitleri, kilometre taşı maddesi (K13).
  - Kaynak: sahip kararları K7, K10, K12 ve ONERI_v3 §4.1–§4.2 ("uygula"); 2cbbcd8, 28d5edc.

- **§6 Relationships carry, 2. paragrafın son cümlesi ("a fund that passed may return")**
  - Eski metin: Seni geri çeviren fon, rakamların değişirse Series A'da geri dönebilir.
  - Yürürlükteki kural: Reddeden fon geri dönmez; red koşu boyunca kalıcıdır ve cümle çıkar (K9). Series A'da bir fonun kapısı bir kez kapanır: görüşmede reddeden fon, masadan kalkan fon (K12), süresi dolan teklifi karar kartında reddedilen fon (K10) ve oyuncunun masadan kalktığı fon (K11) koşu boyunca kapanır. §4'ün "not now" geri çağrısı red değildir. Açık: §6'nın öbür durumları (seed'de çekilme ve ret, K20), Frank'in tanıştırması, reddedilme zinciri (K14).
  - Kaynak: sahip kararları K9, K10, K11 (ONERI_v3 §0A, "uygula"); 28d5edc.

## GDD v2 — 11 · Events & Narrative

- **§5 Triggers, son cümle ("Ambient texture events: at most one per day")**
  - Eski metin: Ambient doku olayları günde en fazla bir kez düşer ve ekonomik ağırlık taşımaz.
  - Yürürlükteki kural: Olay sayılarındaki "gün" oyun günüdür, yani bir tik, bir hafta; "günde en fazla bir" tik başına okunur. Ekonomik ağırlık yasağı değişmez. Günlük tetikler haftanın 00:00 devrinde, gece atlamasının içinde değerlendirilir; atlanan gece saatlerinde yalnız kritik saatlik kart kapıdan geçer. Gece atlaması ve toplantı atlaması sürerken kart gösterimi ertelenir; adım bitince kartlar önem sırasıyla gelir, yani günlük kartları oyuncu haftanın başında, 08:00'de görür. Kesinti bütçesi tik başına 2'dir (`EvTuning.MAX_INTERRUPTS_PER_DAY`), kategori kotaları bir haftalık pencerede sayılır (`CATEGORY_QUOTA_WEEK`). Açık (ACIK_KARARLAR): olay kartlarının haftanın başında toplu gelmesi.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §7; sahip kararı 2026-09-27/28.

- **§6 Memory, 3. madde ("today it is written and never read")**
  - Eski metin: Koşu geçmişi yazılıyor ama hiç okunmuyor; okunur hâle getirmek hedeftir.
  - Yürürlükteki kural: Hedef gerçekleşti. Her çözüm geçmişe bir satır yazar (tik, yani oyun haftası; çözüm türü, seçenek, sonuç, özneler); koşul sözlüğünün history yaprakları (`fired`, `fire_count`, `chose`, `weeks_since`, `resolution`; motor §5.2) onu okur; Olaylar gelen kutusu onu oyuncuya gösterir (cevaplanan ve süresi dolan kararlar seçilen seçenek ve etki çipleriyle listede kalır; ch12 §9 maddesi); son ekranı ve haber bandı da okuyabilir. Süre okuyan yapraklar hafta sayar. Parantez çıkar.
  - Kaynak: olay motoru GDD rev 2 §5.2, §7.1–§7.3; `GDD — ZAMAN MODELİ.md` §1, §3; sahip kararı 2026-09-27/28.

- **§7 Voice, 1. satır ("TR canonical … EN native and not a translation")**
  - Eski metin: Oyuncu metninde Türkçe kanoniktir; İngilizce çeviri değil, özgün yazılır.
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. Her metin bir anahtar olarak doğar. §7'nin geri kalanı (Edgü kesimi, Frank'in sesi, yasaklar, mühürlü referans metinler) değişmez. Metni kimin yazdığı açık karardır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

- **§10 Open decisions, 3. madde (isimli slot mu sabit ad mı); ilgili §2 cümlesi**
  - Eski metin: Tekrarlanan müşteri olaylarının isimli hesap slotuyla mı sabit isimlerle mi yazılacağı açıktır.
  - Yürürlükteki kural: Kartlar ihtiyaç duydukları varlıkları isimli kapsam slotlarıyla bildirir (aynı tipten birden çok varlık varsa slot adı zorunlu); müşteri kartları bağlanan hesabı metinde `{customer}` ile anar, sabit isim yoktur. Aynı kart her özne için ayrı bir örnek olarak yaşar (motor GDD §20 A6, E2). Madde §10'dan düşer. Açık: seçicili tarama kartı (ACIK_KARARLAR 9), öznesi giden kağıdın süre dolumu (13).
  - Kaynak: olay motoru GDD rev 2 §4.3, §17.12, §26 madde 4; 8c914ec.

## GDD v2 — 12 · UI Surfaces & ODA

- **§1 Tabs (v1), "Events: no separate tab; events arrive as modals from the room (the phone)" cümlesi**
  - Eski metin: Olayların ayrı sekmesi yoktur; her olay oyuncuya ODA'daki telefondan gelen bir modal olarak ulaşır.
  - Yürürlükteki kural: Olaylar rayda kendi sekmesi olan bir gelen kutusudur: solda liste, sağda okuma bölmesi. Liste bekleyen kararı, kuyruktaki kart sayısını, masadaki kâğıtları, dikkat isteyen hesap ve çalışanları, mesajları ve geçmiş kararları gösterir; satır gönderen, konu rozeti, konu, ilk satır ve kalan hafta ya da tarih taşır; Tümü, Bekleyen ve Okunmamış süzgeçleri sayılarıyla durur. Okuma bölmesi mail gibi okunur: gönderen başlığı, gövde, imza ve "Cevabın" altında seçenekler (tek açık seçenek hazır durur; birden fazlasında önce seçilir, sonra "Seç"; kilitli seçenek gerekçesiyle görünür; kalıcılık satırı). Kart metni değişmez: konu kartın başlığıdır, gönderen kartın bağlamından türetilir. Olayların dört sunum sınıfı vardır: interrupt karar kapısıdır, kutu kartın üstünde açılır ve saat cevaba kadar tutulur, bu sürede başka her pencere yalnız okunur (olay motoru md §11.3); paper masada bir kâğıttır, kutuda ve ofisin sağ altındaki bildirim yığınında bekler, "Cevapla" ile açılınca karar gibi davranır, Esc onu masaya geri koyar, kalan süresi üzerinde görünür; info bir sekme rozeti ya da kutuda mesajdır; ambient haber bandına düşer. Acil olmayan karar kartları masada kâğıt olarak bekler. Frank'in tanışması ve dönem özeti kutuda kendiliğinden açılır ve oyunu duraklatır. Üst çubuk bekleyen kararı "Cevap bekliyor" yuvasında gösterir; yuva karara döner. Olaylar için telefon yoktur; telefon yalnız görüşme davetinde çalar (ofis kademesi maddesi). §1'in Ar-Ge sekmesi cümlesi bu maddenin konusu değildir; olay günlüğünün yeri §9 maddesindedir.
  - Kaynak: olay motoru GDD rev 2 §11.1, §11.3, §11.4, §27.14; Erdem, 2026-09-27 görev kararı (izometrik ofis); sahip kararı 2026-10-02 (Menajer Masası, Olaylar gelen kutusu).

- **§2 Centre and frame, "Centre view = ODA", "TopBar carries …" ve "Right panel carries today's items and warnings" cümleleri**
  - Eski metin: Merkez görünüm ODA'dır; TopBar tarih, kasa, MRR, runway, varsa kepenk sayacı ve hızı (1×/2×/3×) taşır; sağ panel günün işlerini ve uyarılarını taşır.
  - Yürürlükteki kural: Merkez görünüm izometrik 3B ofistir (`OfficeView`). Sekmeler tam sayfa değildir, ofisin üstünde sabit yuvalı pencereler olarak açılır (EU4/CK3 düzeni): aynı anda bir birincil pencere ve ona bağlı bir ayrıntı penceresi (ör. Ekip dosyası); pencereler sürüklenmez, ×, Esc ya da sekmeye tekrar tık kapatır. Ofis pencerelerin arkasında görünür ve etkileşimli kalır. Sağ panel yoktur: masadaki kâğıtlar ofisin sağ altındaki bildirim yığınında ve Olaylar sekmesinde durur. Hedef ve pazar payı kartları Finans Özet'te, kilometre taşları Kişisel'dedir. ODA ve açılış turu emeklidir. TopBar'ın tarih satırı hafta numarası, ay, yıl ve saati yazar (ör. Hafta 14 · Nisan 2026 · 09:00); hafta numarası o haftanın Perşembe'sinin yıl içindeki haftasıdır ve yıl başında 1'e döner. Hız dört basamaklıdır: 1×, 2×, 3×, 4× (tuşlar 1 ile 4). Burn ve net canlı aylık hızdır (/ay); kepenk sayacı hafta sayar. Haber bandı cümlesi yürürlüktedir; ay kapanışının ve runway eşiğinin tek satırları da bandan geçer (ch08 §3 ve §4 maddeleri).
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis); `GDD — ZAMAN MODELİ.md` §2, §5, §6; sahip kararı 2026-09-27/28.

- **§3 Build bar, "One widget, three hosts (BuildHUD, tracker card, ODA monitor)" cümlesi**
  - Eski metin: Tek widget, üç ev sahibi: BuildHUD, izleyici kartı, ODA monitörü.
  - Yürürlükteki kural: Tek widget, iki ev sahibi: BuildHUD ve Ürün sayfasındaki izleyici kartı. BuildHUD bir çubuğu doluyken hep görünür: ofiste de, açık pencerenin üstünde de. §3'ün geri kalanı değişmez.
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis).

- **§6 ODA, bölümün tamamı**
  - Eski metin: v1 mühürlü 2B plakalarla çıkar; 3B spike'ın plakaları onaylanırsa plaka olarak yerlerini alır, v1'de gerçek zamanlı 3B yoktur. Ana menü ODA'nın gece sahnesidir. ODA monitörü (build bar), telefonu (olaylar buraya gelir) ve odanın gündüzden geceye tonunu taşır.
  - Yürürlükteki kural: v1'de gerçek zamanlı 3B ofis vardır: Ev, İş hanı, Plaza katı, Depo loft ve ofis seçimi için şehir haritası. Geometri tasarımın kendi kodundan dışa aktarılır; oyun kamerayı, ışığı, kişileri ve haritayı canlı sürer. Işık oyun saatini izler (tasarımın gün boyu renk senaryosu); gündüz ve gece tonunu ofisin ışığı taşır. Kişiler gerçek kadrodur; her biri kendine özgü bir görünümle çizilir ve gerçek zamanlı ambiyanstır. Geliş ve çıkış oyun saatine bağlıdır: herkes başlangıçtan biraz sonra gelir (kişiye ve haftaya göre tohumlu, bazı haftalar geç) ve bitişinden biraz önce çıkar; kurucu şirketin mesai penceresini izler. Yürüyüş vaktinde varacak kadar önce başlar; 90 dakikalık gecikmeyle bile varamayacak olan sabah açılışının kararmasında masasında oturur hâlde gelir. Kapıdan tek tek çıkılır; sırası günün sonundan sonraya düşen ya da günü yürüyüşe yetmeyecek kadar kısa olan masasında kalır ve gece kararmasında kesilir. Aradaki her şey ambiyans saniyesiyle akar (gerçek saniye × oyun hızı, en fazla 2×; duraklatınca her şey donar): kahve ve tuvalet molası (dolu tezgâhta kuyruk), masa ziyareti, satışçının kabini, öğle yemeği, masa başı küçük hareketler, ekip toplantıları ve Depo loft'ta 17:00 all-hands. Ev'de yalnız kurucu çizilir; çalışanlar uzaktan çalışır ve ilk taşınmayla ofiste görünür. Kurucu Ev'de pencere bitiminde yatağına yürür, başlangıçta kalkıp masasına gider. Bütün ritim sayıları [WORKING] (`OfficeConstants`, onay bekliyor: ACIK_KARARLAR 91). Gösterilen gün haftanın temsili iş günüdür: hafta 08:00'de başlar; mesai bittiğinde (en geç 00:00) ofis boşalınca gecenin kalanı tek seferde atlanır, gece saatleri simüle edilir, ekran kısa bir kararmayla 08:00 ışığına döner ve hız değişmez. Gece kapısı yalnız kapıya ya da yatağa yürüyenleri bekler (en fazla 3,5 gerçek saniye); içeride kalan herkes kısa bir kararmanın altında kesilir. 1×'te varsayılan 09:00 ile 17:00 mesaisiyle bir hafta yaklaşık 90 gerçek saniye sürer (2× 45, 3× 30, 4× 22,5 saniye). Mesai penceresi böylece görünen günün tamamıdır; ACIK_KARARLAR'ın 63. maddesi (1×'te 12 saniyelik günde 8 saatlik mesai 4 saniyeye sığıyor, ofis hızlandırılmış film gibi görünüyordu) bu tempoyla kapanmıştır. Kişiye tıklamak Ekip dosyasını açar. Monitörün yerini BuildHUD (§3), telefonun yerini Olaylar sayfası ve bildirim yığını (§1) alır. Ana menünün görüntüsü bu maddenin konusu değildir.
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis); `GDD — ZAMAN MODELİ.md` §2, §7; sahip kararı 2026-09-27/28; ofis karakterleri görev kararları ve Ev'de uzaktan çalışma kararı (Erdem, 2026-09-28).

- **§7 Visual language, "Terminal language stays: mono type, hairline rules, amber accent, no filled hover rectangles (edge glow only)" cümlesi**
  - Eski metin: Terminal dili kalır: mono yazı, ince çizgi, amber vurgu; hover dolgulu dikdörtgen değil, yalnız kenar ışımasıdır.
  - Yürürlükteki kural: Arayüzün dili Menajer Masası'dır: sıcak kömür tonunda koyu yüzeyler, açık mürekkep, yoğun tablolar; Olaylar gelen kutusu gibi okunur. Yazı Barlow Condensed (başlık, gezinme, büyük harf etiket, düğme, damga), IBM Plex Sans (veri, gövde, sayı; dar sütunda IBM Plex Sans Condensed) ve Source Serif 4'tür (Frank'in sözleri, köken alıntıları, gazete); JetBrains Mono çıkar ve bu üçlü 2026-08-03'teki Set A kararının yerini alır. Amber dolgu yalnız açık yüzeyin tek birincil eylemindedir, çerçeve ya da yazı olarak yalnız saat durumunu gösterir (cevap bekleyen karar, çalışan hız tuşu, görüşme daveti); seçili öğe amber olmaz. Kırmızı yalnız tehlikededir; hisse, indirim ve düşüş mürekkeple gösterilen bedeldir. Hover kenardır, dolgu değil; seçili öğe mürekkeptir (yükselmiş yüzey ve satırın sol kenarında işaret); odak temalı halkadır. Her anlamlı rengin ikinci bir kanalı (biçim ya da söz) ve renk körü ikizi vardır. Son ekranındaki gazete krem kalır, oyunun tek diegetik adasıdır. Geçiş ekran ekran yapılır; krem dil taşınmamış ekranlarda son adıma kadar yaşar. UI ölçek merdiveni ve çözünürlük cümlesi bu maddenin konusu değildir.
  - Kaynak: Erdem, 2026-10-02 kararları (yön Menajer Masası; yazı Barlow Condensed, IBM Plex Sans ve Source Serif 4; gazete krem; tasarım sistemi ve ikon ailesi onayı).

- **§8 Links, "Finans → tab + monthly close"**
  - Eski metin: Finans'ın yüzeyi sekme ve aylık kapanıştır.
  - Yürürlükteki kural: Ay kapanışı ekran açmaz. Finans'ın ay yüzeyi sessiz ay kapanışıdır (haber bandı satırı, TopBar'ın aylık rakamları) ve Ayarlar'dan sıklığı seçilen dönem özetidir (ch08 §4 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §6; sahip kararı 2026-09-27/28.

- **§9 Open decisions, 1. madde ("Whether the events log lives in Kişisel or in the right panel"); §1 "An events log lives inside Kişisel [WORKING]" cümlesi**
  - Eski metin: Olay günlüğünün Kişisel'de mi sağ panelde mi yaşayacağı açık karardır; §1 onu çalışma değeri olarak Kişisel'e koyar.
  - Yürürlükteki kural: Madde kapandı. Olay günlüğü Olaylar gelen kutusudur: cevaplanan ve süresi dolan her karar seçilen seçenek, sonucun etki çipleri ve damgasıyla (Cevaplandı, Ayrıldı ya da Süresi doldu ve haftası) listede kalır; mesajlar da oradadır. Kişisel'de olay günlüğü yoktur; sağ panel yoktur (§2 maddesi).
  - Kaynak: olay motoru GDD rev 2 §7.3, §27.14; sahip kararı 2026-10-02 (Olaylar gelen kutusu).

- **§8 Links, "Kişisel → founder card, energy, net worth, events log"**
  - Eski metin: Kişisel yüzeyi kurucu enerjisini de taşır.
  - Yürürlükteki kural: Kurucu enerji barı yoktur ve olmayacaktır; satırdan "energy" çıkar. Kişisel sayfasında moral de yoktur. Olay günlüğü Olaylar'dadır (§9 maddesi). Net varlık bu maddenin konusu değildir.
  - Kaynak: Ekip GDD §2, §2.5, §17.6; GDDs/README (ch12 §8 → Ekip §17.6).

- **Bölüm yok: ofis kademesi, taşınma ve toplantı yolculuğu**
  - Eski metin: GDD ofis kademesini, taşınmayı ve kurucunun toplantıya gidişini tanımlamaz.
  - Yürürlükteki kural: Şirket Ev'de başlar; kademe Ev → İş hanı → Plaza katı → Depo loft. İlk taşınmayı Frank'in çekinden sonra Frank'in kartı önerir. Taşınma şehir haritasından oyuncu eliyle yapılır; kapılar tasarımın şartlarıdır (Frank'in çeki, kasa, ekip, marka), taşınma 1 hafta sürer (`OfficeConstants.MOVE_WEEKS`), Ev'e dönüş yoktur. Bu turda kira, depozito ve nakliye kasadan düşmez, `FinanceSystem`'in "office" kalemi 0 kalır; harita kartı bu tutarları bilgi olarak gösterir. Görüşmelere davetle gidilir: satışta "Görüşmeye git", Series A'da görüşme haftasının çağrısı ofiste kurucunun başının üstünde telefonu çaldırır ve davet kartı Kabul et / Ertele sorar (ch09 §4 ve Satış §5.0 maddeleri). Şehir haritası kurucunun toplantı yolculuğunun sahnesidir: satış toplantısına, seed ve Series A pitch'ine ve term sheet masasına giderken kurucu masasından kalkıp çıkışa yürür (en fazla 1,5 saniye izlenir) ve en yakın iki oturan çalışan başını ona çevirir; kısa bir kararmadan sonra harita kontrolsüz yol kipinde açılır. Mevcut ofisle yatırımcı kulesi arasına kesikli, yukarı kavisli bir yol çizilir, kurucunun bust'lı diski yol boyunca ilerler, iki binanın üstünde çip durur (mevcut ofis; karşı tarafın yeri ve lideri), varışta kulenin tacı parlar. Bütün görüşmeler tek yerde geçer: yatırımcı kulesinin en üst katındaki cam toplantı odası; karşı taraf masada oturur, kurucu asansörden yürüyüp oturur ve görüşme paneli açılır. Yolculuk boyunca saat durur; açık pencereler gizlenir ama kapanmaz. Tık ya da Esc yolculuğu atlar. Dönüşte harita üzerinden geri yol çizilir, kurucu girişten masasına yürür, en yakın oturan çalışan başını kaldırır ve haber bandına "{ad}: Nasıl geçti?" düşer; atlama mesai bitimine indiyse gece başlar. Bütün sayılar [WORKING] (`OfficeConstants`, `OfficeCity.ROAD_OUT` / `ROAD_HOME`, `office_travel.gd`); yolculuk görsel kabulde doğrulanır. Açık: kira ve ekonominin bağlanması (ACIK_KARARLAR 60), Frank'in kart metni (69), tek oda ve tek kule (94).
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis); `GDD — ZAMAN MODELİ.md` §4, §8; sahip kararı 2026-09-27/28; görüşme akışı kararları (Erdem, 2026-09-28/29).

## GDD v2 — 13 · Endings & Progression

- **§1 Endings in v1, "bankruptcy" ve "running_on_fumes" satırları; "profitable_bootstrap" satırındaki "six Artıda months"**
  - Eski metin: İflas 30 günlük kepenk sayacı sıfıra inince gelir; running_on_fumes 24 aylık yumuşak tavanda gelir ve Frank D−1'de uyarır; bootstrap zaferi altı Artıda ayı ister.
  - Yürürlükteki kural: Kepenk 4 haftadır (`EndingsSystem.SHUTTER_WEEKS` [WORKING]) ve sayaç hafta sayar; Frank'in onaylı iflas satırındaki gün değeri 4 hafta × 7 = 28'dir. Yumuşak tavan 104 haftadır (`SOFT_CAP_WEEK` [WORKING]); D−1 bir hafta öncedir: Frank'in hükmü 103. haftada gelir (`world.final_stretch_verdict`), telgraf merdiveni 91. ve 100. haftada başlar (`final_stretch_press`, `final_stretch_comment`). Altı Artıda ayı ay kapanışlarıyla sayılır (`PROFIT_STREAK_MONTHS` 6 [WORKING]); ay 4 ya da 5 haftadır (ch08 §4 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4, §6; sahip kararı 2026-09-27/28.

## GDD v2 — 14 · Scope (v1 / EA / Full)

- **§7 Portrait policy, "Employees: no faces" satırı ve olay kartı cümlesi; "Frank has a portrait"**
  - Eski metin: Çalışanların yüzü yoktur: baş harf ve renk. Olay kartı kaynağının küçük dairesi çalışanda baş harftir; Frank'te ve portreli karakterlerde portredir.
  - Yürürlükteki kural: Çalışan, aday ve kurucu, baş harf dairesinin gösterildiği her kartta ofisteki 3B görünümünden çekilmiş bir bust ile görünür (Ekip kadrosu, dosya, görevler, eğitim, Atlas dosyaları, olay kartının kaynağı). Adayın görünümü dosyada doğar; işe alınan aynı kişi ofise yürür. Yağlı boya portreler emeklidir: Frank'in ve 11 kurucunun portresi, büstlerle aynı 3B karakter sisteminden önceden render edilmiş sabit portredir. Kurucu onu açılışta seçer (kurucu seçimi, şirket adımı) ve Kişisel sayfasında görür; ofiste aynı görünüşle durur. Frank'in görünüşü sabittir (gri sakal ve saç, gri takım, bordo kravat); gri saçı sakallı bir başta (kendi başı ya da bıyığı saç renginden boyanan baş) yalnız onundur, hiçbir çalışan, aday ya da görüşmedeki muhatap onu taşımaz; eski kayıtta taşıyanın görünüşü yüklemede yeniden çekilir. Frank sahnede görünmez; portresi olay kartının kaynağında, tanışmada, dönem özetinde ve bildirim yığınında durur. VC'ler ve müşteri muhatapları 3B bust'larıyla görünür (ch09 görüşme maddesi). Görünümü olmayan (eski dosya) baş harfle kalır.
  - Kaynak: ofis karakterleri görev kararı 5 (Erdem, 2026-09-28); arayüz yeniden tasarımı kararları 2, 12 ve 13 (Erdem, 2026-10-02).

- **§1 Demo / v1 cut point, "Target session" cümlesi**
  - Eski metin: Hedef oturum 60 ile 90 dakikadır.
  - Yürürlükteki kural: Hedef 60 ile 90 dakika [WORKING] kalır. 1×'te varsayılan mesaiyle (09:00 ile 17:00) bir oyun haftası yaklaşık 90 gerçek saniyedir (2× 45, 3× 30, 4× 22,5 saniye); hedef 1×'te, duraklama ve toplantı süresi hariç, yaklaşık 40 ile 60 oyun haftasına denk gelir. Yumuşak tavan 104 haftadır (ch01 §1 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §2; sahip kararı 2026-09-27/28.

- **§2 In the demo, 2. madde (alt-tipler ve derinlik); §8 Open decisions, 3. madde**
  - Eski metin: Demo 2 B2B + 2 B2C alt-tipiyle çıkar; derinlik alt-tip başına düz özellik listesinden gelir (eksen başına 3, eksen başına bir araştırma kilitli). Hangi alt-tiplerin seçileceği açıktır.
  - Yürürlükteki kural: Demo alt-tipleri mühürlüdür: Not & Bilgi Aracı ve Video Klip Aracı (B2C), ERP (B2B). B2B'nin ikinci slotu ruling bekler ve tip ekranında kilitli kart olarak durur. Tip ekranında yol başına 3 kilitli kart gösterilir (B2C: Kod Yazan Asistan, Görsel Düzenleyici, Yapay Zeka Asistanı; B2B: Kurumsal Arama, CRM, açık slot). Derinlik hat modelinden gelir: alt-tip başına 9 hat (5 kimlik + 4 paylaşılan, eksen başına 3), her hat 3 isimli kademe (K1–K3); düz katalog kaldırılmıştır. Araştırma kilidi her hattın K3 kademesidir (Ar-Ge düğümü + yıldız). §8'in alt-tip sorusu, ikinci B2B slotu dışında kapanmıştır. Açık: teknoloji borcu, düz katalog kodunun silinmesi (ACIK_KARARLAR 44).
  - Kaynak: Ürün GDD rev 6.1 §12.1, §12.3, §12.11 (mühürlü; direktörün 2026-08-25 kürasyonu), §23.

## GDD — EKİP MODÜLÜ (rev 11)

- **§2 KURUCU, "Şirket çalışma saatini devralır … tam verimle çalışır" ve "Kısa günün moral faydasından da yararlanmaz" maddeleri; §2.2 meşguliyet listesi (toplantı oturumu)**
  - Eski metin: Kurucu şirket çalışma saatini devralır; ek mesaide moral cezası ve mesai ücreti almaz, saatleri tam verimle çalışır; çalışma süresinin onun üzerindeki tek etkisi çıktısının saatle orantılı değişmesidir. Meşguliyet listesi izin, eğitim ve (kurucu) yatırım hazırlığıdır.
  - Yürürlükteki kural: Kurucu şirket penceresini devralır, istisna alamaz, moral cezası ve mesai ücreti almaz. Saatin çıktısına etkisi herkesle aynı azalan verim eğrisidir (§8.2 maddesi): sekizi aşan her saat yarım verir. Ofiste şirket penceresini izler (ch12 §6 maddesi). Toplantı oturumu (satış toplantısı, seed ve Series A pitch'i, term sheet masası) sahne açıkken kurucuyu meşgul eder; bu durum kayda girmez. Oturum bitince saat oturumun süresi kadar atlar ve atlanan saatler kurucunun o haftaki çıktısından saat/40 payını alır (Satış §5.0 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §8, §9; sahip kararı 2026-09-27/28.

- **§2.2 meşguliyet listesi; §2.3 "Araştırmada · Meşgul mü: Hayır"; §12.0 "Araştırma sütunu yoktur"; §12.1 odak tablosu; §17.6 "Kod temizliği" 7. madde**
  - Eski metin: Araştırma bir atama hedefi değildir, sütunu yoktur; kurucu araştırırken yapımı durmaz; iki işe atanan kişi her zaman 0,50/0,50 böler; araştırma atama id'si silinecekler arasındadır.
  - Yürürlükteki kural: Araştırma Ekip'in iş listesinde bir iştir ve dışlayıcıdır. Araştırmaya atanan kişinin o sıradaki tek işi araştırmadır: 0,50/0,50 odak bölmesine girmez, başka işe çıktı vermez; öbür atamaları silinmez, duraklar ve araştırma duraklayınca ya da bitince kaldıkları yerden devam eder. Kurucu için de böyledir: araştıran kurucu ürün yapmaz; tek başınaysa aktif yapım duraklar ve yapım barı sebebini yazar. Araştırma sürerken yeni bir yapım başlatılırsa araştırma duraklar ve sebebi yazılır (Ar-Ge §5.6.1). Atama düğümün kendisinde yapılır; Görevler matrisinde araştırma sütunu salt okunur görünür. Araştırma atama id'si kalıcıdır.
  - Kaynak: Ar-Ge GDD rev 1.7 §0 "Bağlayıcı ilişkiler" (meşguliyet kuralının sahibi Ar-Ge'dir), §5.0 (mühürlü), §5.6.1.

- **§2.6 3. madde; §17.1 3. madde ("Karizma ne işe yarar"), yalnız satış ayağı**
  - Eski metin: Karizmanın işlevi onboarding turunda karara bağlanacak açık bir iştir.
  - Yürürlükteki kural: Karizmanın satış işlevi mühürlüdür: satış işi kapatır, Karizma kapıyı açar ve kötü anı kurtarır. Satış toplantısında iki anı vardır: "Yönü çevir" fiili yalnız kurucuda Karizma varsa açılır; lig üstü kapıda Karizma yıldız uyumsuzluğu cezasını kısmen siler [K]. Başka hiçbir satış formülüne girmez; pazarlık (Perde 2) tamamen Satış'ındır. Yatırım tarafındaki işlevi, kurucu unvanı ve huyları bu maddenin konusu değildir.
  - Kaynak: Satış GDD rev 6.1 "Bağlayıcı ilişkiler" ve §5.1 (mühürlü).

- **§4.5 Etkin çıktı formülü, "günlük katkı" satırı**
  - Eski metin: Günlük katkı = etkin çıktı × kişinin o günkü çalışma saati.
  - Yürürlükteki kural: Saat terimi saat verimidir: min(saat, 8)/8 + max(saat − 8, 0) × 0,5/8 (`HRConstants.hours_output_mult`, `TimeModel.OVERTIME_HOUR_YIELD` 0,5 [WORKING]); sekiz saat 1,0, beş saat 0,625, on bir saat 1,1875, on altı saat 1,5 verir. Günlük katkı gün verisidir; her tik (hafta) onun 7 günlük payını uygular, saatlik tikte 7/24'ünü. İzindeki ve eğitimdeki çalışanın katkısı sıfırdır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §9; sahip kararı 2026-09-27/28.

- **§5.1 Deneyim, birikim hızı; §5.2 ve §5.5 eğitim süresi; §15.2 "Eğitim süresi → tek bir gün sabiti"**
  - Eski metin: Deneyim birikim hızı bir kalibrasyon yüzeyidir; eğitim iki hafta sürer; modal "iki hafta" ifadesini gün sayısından türetir ve eğitim süresinin tek evi bir gün sabitidir.
  - Yürürlükteki kural: Deneyim birikimi gün verisidir (çalışılan gün başına 2, geliştirme fazı koşarken +1; `EXPERIENCE_PER_WORKED_DAY`, `EXPERIENCE_BUILD_BONUS`) ve her tik 7 günlük payını ekler; gün başına 1'lik taban önce uygulanır, yani tik başına en az 7. Eğitim 2 haftadır; tek evi hafta sabitidir (`HRConstants.TRAINING_WEEKS` 2) ve ekrandaki süre metni bu sabitten türetilir.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §4; sahip kararı 2026-09-27/28.

- **§6 HUYLAR, SADIK ve GÖZÜ YÜKSEKTE satırları; §7 MORAL, "Ayrılabilir" bandı (bölüm sessiz: istifanın zamanı ve ihtimali)**
  - Eski metin: SADIK düşük moralde istifa ihtimalini düşürür, GÖZÜ YÜKSEKTE tutma ihtimalini düşürür; moral 35'in altında "Ayrılabilir" rozeti yanar. Bölüm istifanın ne zaman ve hangi ihtimalle geldiğini söylemez.
  - Yürürlükteki kural: Moral 35'in altında kaldığı her hafta kişinin kaçma riski sayacı bir artar; moral eşiği geçince sayaç sıfırlanır. Sayaç 2 haftaya varınca tek bir istifa zarı atılır (`RESIGN_WINDOW_MIN_WEEKS` 2): ihtimal 1 − (1 − 0,25 × huy çarpanı)^4 (`RESIGN_CHANCE_PER_DAY` 0,25 [WORKING], `RESIGN_ROLL_DAYS` 4). Huysuz çalışanda %68,4, SADIK'ta (×0,6) %47,8, GÖZÜ YÜKSEKTE'de (×1,6) %87,0. 3. haftada istifa kesindir (`RESIGN_WINDOW_MAX_WEEKS` 3). İstifa olay kartıyla gelir (§11.3).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§7 MORAL, taban düşüş hızı; §7.1 saat ↔ çarpan tablosu; §15.2 "Tablo yedi satırdır"**
  - Eski metin: Taban düşüş hızı günlük bir kalibrasyon değeridir; saat ↔ çarpan tablosu 5 ile 11 saat arası yedi satırdır (11 saat ×1,5) ve tek kopyası vardır.
  - Yürürlükteki kural: Taban sürüklenme ve toparlanma adımı gün verisidir (`MORALE_BASE_DRIFT_PER_DAY` 0,25, `MORALE_EASE_PER_DAY` 3,0) ve her tik 7 günlük payını uygular. Tablo 12 ile 16 saat için uzar: ×1,7, ×1,9, ×2,1, ×2,3, ×2,5; toplam on iki satırdır ve tek kopyası `HRConstants.HOUR_MORALE_MULT`'tur. Aşırı yük çarpanı ve yön duyarlılığı değişmez.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §9; sahip kararı 2026-09-27/28.

- **§8.1 Çalışma aralığı: aralık tablosu, başlangıç saati cümlesi, "Mesai bitiminde hava kararır" paragrafı ve "Tavan neden 11" paragrafı**
  - Eski metin: Süre 5 ile 11 saat, tam saat adımı; başlangıç yalnız şirket kapsamında, varsayılan 09:00, aralık 06:00 ile 11:00 [çalışma değeri]. Mesai bitiminde hava kararır, monitör kapanmaz, gece kriz olayı düşebilir. 11 saatlik tavanın gerekçesi İş Kanunu md.63'tür: en fazla üç saat ek mesai, en fazla +%37,5 çıktı.
  - Yürürlükteki kural: Başlangıç aralığı 08:00 ile 11:00'dir (`HRConstants.START_HOUR_MIN` = `TimeModel.WEEK_START_HOUR` 8, `START_HOUR_MAX` 11), varsayılan 09:00. Süre 5 ile 16 saat arasıdır; okunurken 24 − başlangıç ile kırpılır, yani bitiş en geç 00:00'dır (`WORK_HOURS_MAX` 16, `TimeModel.WORKDAY_LATEST_END` 24). Ücret, moral, verim, pencere ve modal aynı kırpılmış sayıyı okur. 11 saatlik yasal tavan gerekçesi kalkar; uzun günün bedeli moral çarpanı (§7.1 maddesi), mesai ücreti (§8.2) ve azalan verimdir (§8.2 maddesi). Mesai bitince gece gelir: ofis boşalınca gecenin kalanı atlanır, hafta 08:00'de başlar ve atlanan gece saatleri simüle edilir. Atlamanın tek girdisi günün bitişidir: kurucunun ve ofisteki aktif çalışanların bitişlerinin en geçi, en geç 00:00 (`WorkHoursSystem.workday_end`). Atlanan gecede yalnız kritik saatlik olay kartı kapıdan geçer (ch11 §5 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §7, §9; sahip kararı 2026-09-27/28.

- **§8.2 Ek mesai, moral çarpanı satırı ve "saatleri tam verimle çalışır" cümlesi; §8.4 Süre değişikliğinin getirisi; §17.5 "Kurucunun uzun gün verimi" park maddesi**
  - Eski metin: Sekizi aşan saatler %50 fazla ücretle ödenir; moral çarpanı 9, 10 ve 11 saat için kademelidir; kurucu saatleri tam verimle çalışır. Getiri saatin kendisidir: 11 saat orantılı olarak fazla üretir, ayrı hız çarpanı yoktur. §17.5 kurucunun bedelsiz uzun gününü park edilmiş bir açık sayar; playtest gerekli gösterirse azalan saat verimi eğrisiyle ele alınacaktır.
  - Yürürlükteki kural: Sekizi aşan her saat yarım saatlik çıktı verir (`TimeModel.OVERTIME_HOUR_YIELD` 0,5 [WORKING]): çıktı = min(saat, 8)/8 + max(saat − 8, 0) × 0,5/8. 11 saat 1,1875 (önceki 1,375), 16 saat 1,5 verir; sekizin altı saatle orantılı kalır (5 saat 0,625). Eğri kurucuya da uygulanır; kurucu yine moral cezası ve mesai ücreti almaz. Ücret kuralı (sekizi aşan saat 1,5×) ve moral çarpanı tablosu (§7.1 maddesi) yürürlüktedir. Ayrı hız bonusu ve ek mesai kalite cezası hâlâ yoktur. §17.5'in park maddesi bu eğriyle kapanmıştır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §9; sahip kararı 2026-09-27/28.

- **§8.5 Çalışma saatleri modali: durum dili, hover tablosu ve bedel listesindeki "Günlük burn" deltası**
  - Eski metin: 9 ile 11 saat amber okunur; 5 ile 11 arası her kademenin kendi hover cümlesi vardır; bedel listesinin deltası günlük burn'dür ($412 → $587).
  - Yürürlükteki kural: Sürgü ve bitiş saati 00:00'a kadar uzar; 9 ile 16 saat amber okunur. 11 saate kadar her kademenin kendi hover cümlesi vardır; 12 ile 16 saat tek bir ortak cümleyi paylaşır ve satır en fazla üç amber işaret çizer. Bedel listesinin deltası aylık burn'dür (TopBar'ın canlı aylık hızı, /ay). Açık: ortak cümle ve üç işaret tavanı görsel kabul ve metin onayı bekliyor (ACIK_KARARLAR 88).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §6, §9; sahip kararı 2026-09-27/28.

- **§9.2 Zam, 3. madde; §11.1 Kıdem tazminatı, "Tamamlanmış yıl"; §15 VERİ MODELİ, `tenureStartDate` ve `lastRaiseDate`**
  - Eski metin: Aynı çalışana altı ay geçmeden yeni zam verilemez; kıdem tamamlanmış yıldan okunur; iki tarih alanı zam beklemesini ve kıdemi taşır.
  - Yürürlükteki kural: Zam beklemesi 26 haftadır (`RAISE_COOLDOWN_WEEKS` 26); kıdem yılı 52 haftadır (`TimeModel.WEEKS_PER_YEAR` 52), tazminat tablosu aynen. Tarih alanları tik, yani hafta damgasıdır (`hire_day`, `last_raise_day`).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §1, §4; sahip kararı 2026-09-27/28.

- **§10 İŞE ALIM, 2. paragraf; §10.5 YENİ rozeti; §15.1 "YENİ ← işe alım tarihi son N gün içinde"**
  - Eski metin: Aday listesi aramadan bir hafta sonra gelir; YENİ rozeti bir süre taşınır ve son N gün içinde işe alınana türetilir.
  - Yürürlükteki kural: Aday listesi aramanın ertesi tikinde, yani bir hafta sonra gelir (`SEARCH_ARRIVAL_WEEKS` 1). YENİ rozeti işe alım haftasında ve ardından 2 hafta görünür (`NEW_HIRE_BADGE_WEEKS` 2); rozet yine saklanmaz, işe alım damgasından türetilir.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§10.2 "Beş yıldızlı aday" paragrafı ve son paragraf; §17.4 8. madde**
  - Eski metin: Aday üreteci rol ayırmaz; yıldız dağılımı ve huy olasılıkları tek bir kalibrasyon yüzeyidir; beş yıldızlı aday Kıdemli bantta nadiren çıkar.
  - Yürürlükteki kural: Üreteç Satış Temsilcisi için role duyarlıdır. Satış yıldız eğrisi öbür rollerden yarım kademe aşağıdadır: Junior merkezi ★1–1,5 (★2 aramaların ~%25'inde ve üçlüde tek adayda), Orta ★2, Kıdemli ★3; ★3,5 nadirdir. Demo aday tavanı ★3,5 [ÇALIŞMA]; beş yıldızlı Satış adayı çıkmaz. Tuzak-huy yasağı: faydası o rolün işlerinde ateşlenemeyen huy o rolün havuzuna girmez; Satış havuzunda GERÇEK LİDER ve TİTİZ yoktur. Üçlü arketip yapısı Satış için de geçerlidir.
  - Kaynak: Satış GDD rev 6.1 §11.7, §11.8 (mühürlü, Ekip üretecine taşan hüküm).

- **§10.4 son cümle; §17.5 3. madde (Müşteri Temsilcisinin B2C rolü)**
  - Eski metin: Müşteri Temsilcisinin B2C'deki rolü karara bağlanmamıştır.
  - Yürürlükteki kural: B2C'de hesap sahipliği yoktur, bildirimler kitleden gelir. Müşteri İlişkileri'nin B2C rolü Destek işinde GELEN bildirimi doğrulanmış hataya çevirmek ve Ürün §8.3'ün yanıt etkisidir. Destek iki pazarda aynı mekanikle çalışır; doğrulama unvana değil, Destek'e atananların Müşteri İlişkileri etkin çıktısına bağlıdır.
  - Kaynak: Ürün GDD rev 6.1 §8.6 ("Ekip §17.5'in park maddesi burada kapanır") ve YÜRÜRLÜK satırı.

- **§11.4 Yıllık izin, "Süre", "Zamanlama" ve "Erteleme" maddeleri**
  - Eski metin: Her çalışanın yılda iki hafta (10 iş günü) izni vardır; izinler Haziran ile Ağustos arasına dağıtılır; erteleme talebi 30 gün sonra yeniden getirir.
  - Yürürlükteki kural: İzin 2 haftadır (`LEAVE_WEEKS` 2); iş günü kavramı yoktur. Yaz penceresi Haziran, Temmuz ve Ağustos'un haftalarıdır: 2026 ve 2027'de 13 Perşembe, yani 13 tik, 2028'de 14; izin haftası ilk 13'ünden biridir (`HRConstants.LEAVE_WEEK_COUNT` 13). Erteleme aralığı 4 haftadır (`LEAVE_DEFER_WEEKS` 4); izin talebi olayı henüz bağlı olmadığı için sabitin okuyucusu yoktur.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4, §5; sahip kararı 2026-09-27/28.

- **§13.3 Satır, "Satırın herhangi bir yerine tıklamak menüyü açar" maddesi**
  - Eski metin: Satırın herhangi bir yerine tıklamak menüyü açar; rozetler, çipler ve ikonlar dahil satırın hiçbir noktası tıklamayı yutmaz.
  - Yürürlükteki kural: Kadro satırında ad ve avatar hücresine tıklamak Ekip dosyası penceresini açar: kişinin ayrıntı penceresi (kimlik, şu an ne yaptığı, huy, yetenekler, durum ve satır menüsünün aksiyonları). Satırın geri kalanına tıklamak menüyü açar. Aksiyonlar iki yüzeyde de aynı kapıdan, aynı gerekçe ve sonuç metniyle geçer. Ekip dosyası ofiste bir kişiye tıklanınca da açılır.
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis; Ekip dosyası penceresi).

- **§13.3 Satır, DURUM sütunu ("Eğitimde · N gün", "İzinde · N gün"); §14 MODAL KURALLARI, bedel listesi örneği ("7 gün kapasite dışı")**
  - Eski metin: Süreli durumlar kalan gün sayısıyla okunur; bedel listesi örneğinde kapasite dışı süre gündür.
  - Yürürlükteki kural: Süreli durumlar kalan haftayı sayar ("Eğitimde · N hafta", "İzinde · N hafta"); bedel listesinde kapasite dışı süre hafta okunur. Metinler süre sabitinden türetilir (§16).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§15 VERİ MODELİ, tarih alanları; §15.3 Okuma yüzeyi, `hr.tenure_days` ve `hr.work_hours` ("günlük saat")**
  - Eski metin: Kişi kaydı tarih alanları taşır; katalogda `hr.tenure_days` şirketteki günü, `hr.work_hours` kişinin devraldığı günlük saati döndürür.
  - Yürürlükteki kural: Tarih alanları (işe alım, son zam, son terfi, izin dönüşü) tik damgasıdır; süre sayaçları haftadır (`training_weeks_left`, `flight_risk_weeks`). `hr.tenure_days` sorgusunun yerini `hr.tenure_weeks` alır (şirketteki hafta). `hr.work_hours` kişinin mesai süresini saat olarak döndürür; bu, haftanın temsili iş gününün süresidir. Eski kayıt v14 göçüyle açılır (Ürün §0 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §1, §10; sahip kararı 2026-09-27/28.

- **§16 DİL KURALLARI, 1. madde ve 3. maddenin ikinci cümlesi**
  - Eski metin: "Türkçe kanonik dildir. İngilizce edebî yerelleştirmedir." "TR ve EN aynı commit'te dolar."
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. "TR ve EN aynı commit'te dolar" kuralı kalktı; tüm ekran metninin anahtarlar üzerinden gitmesi sürer. TR metni onaysız değişmez. §16'nın öbür maddeleri değişmez.
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §3, §5.

- **§17.2 Ürün GDD'sinde kapanacaklar, 1. ve 2. madde**
  - Eski metin: Alanların hangi ürün kaldıracını oynattığı ve yapım başına ekip ataması ile ekip lideri akışı açık iştir.
  - Yürürlükteki kural: İkisi de Ürün GDD rev 6.1'de kapandı. Kaldıraç tablosu Ürün §6.2'dedir: Ürün inovasyon tavanını ve yol haritası/özellik kapılarını, Tasarım deneyim tavanını, Yazılım yapım hızını, geliştirmede hata oranını ve destekte düzeltme hızını, Test beta keşif hızını ve Kararlılık tabanını oynatır; Satış ve Müşteri İlişkileri ürün inşasını kapılamaz. Yapım başına ekip seçimi Ürün §3'tedir (çoklu seçim, kurucu dahil; seçilenlerden bir lider). Lider yapım sürerken ayrılırsa yapım lidersiz sürer ve bara "Lider yok." notu düşer; oyuncu yeni lider atayabilir. Açık: liderin moral ve deneyim etkisi (ACIK_KARARLAR 2 ve 7).
  - Kaynak: Ürün GDD rev 6.1 "Bağlayıcı ilişkiler", §3, §6.2.

- **§17.3 "Olay motorunun borcu" (1. paragraf; kazanılacak üç şeyin 1. ve 2. maddesi; mimari düzeltme paragrafı; bekleyen içeriğin 5. maddesi)**
  - Eski metin: Motor insanları göremez: koşul tiplerinden yalnız biri kişiye dokunur, motor sinyale abone değildir, karakter hedef seçicisi yoktur; ayrılma olayı motor hazır olmadan yazılmaz.
  - Yürürlükteki kural: Eski EventManager emekliye ayrıldı; yerine olay motoru rev 2 kuruldu (tek giriş `EventGate.request`). Motorun `employee` kapsam tipi ve tip-güvenli seçicisi, kurucu için ayrı `founder` tipi, kişi başına `entity_seam` koşulları, sinyal katmanı ve Ekip'in isimli sorgu seam'leri vardır. "En düşük moralli çalışan" ve "en yeni işe alınan" seçicileri kuruludur; ayrılma employee kapsamlı bir olay kartıyla sunulur. Açık: "şu alanın lideri" seçicisi yok; HR yazma etkileri bağlı değil (ACIK_KARARLAR 14); `hr.raise_edge` ve `hr.promotion_edge` kenarları.
  - Kaynak: olay motoru GDD rev 2 başlık satırı, §4.3, §5.2, §6.5, §15; cc952e4.

- **§17.3 bekleyen içeriğin "Haftalık özet / brifing yüzeyi" maddesi; §17.4 Kalibrasyon yüzeyleri: başlangıç saati aralığı, §7.1 tablosu ve "YENİ rozetinin kaç gün taşındığı"**
  - Eski metin: Haftalık özet ya da brifing yüzeyi motor hazır olmadan yazılmayacak içeriktir; kalibrasyon yüzeyleri 06:00 ile 11:00 başlangıç aralığını, yedi satırlık saat ↔ çarpan tablosunu ve YENİ rozetinin gün sayısını sayar.
  - Yürürlükteki kural: Dönem özeti Ayarlar'dan haftalık sıklıkta da açılabilir (ch08 §4 maddesi); Ekip'e özgü brifing içeriği bu maddenin konusu değildir. Kalibrasyon yüzeyleri: başlangıç aralığı 08:00 ile 11:00, saat ↔ çarpan tablosu on iki satır (5 ile 16 saat), YENİ rozetinin hafta sayısı, saat verimi (`OVERTIME_HOUR_YIELD`) ve istifa zarı (`RESIGN_CHANCE_PER_DAY`, `RESIGN_ROLL_DAYS`).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §6, §9; sahip kararı 2026-09-27/28.

- **§17.5 5. madde ("Build dışı alanlarda ekip lideri"), yalnız Satış masası; §4.2'nin §17.5 göndermesi (Satış için)**
  - Eski metin: Satış, Destek ve Hesap masalarında liderin ne yapacağı karara bağlanmamıştır.
  - Yürürlükteki kural: Satış masasında demoda lider yoktur; alanın moral iklimi kurucunun Liderliğinden okunur. Satış masası lideri bir EA seam'idir. Destek ve Hesap masası ayakları açıktır.
  - Kaynak: Satış GDD rev 6.1 §7.4 ("Ekip §17.5 kapanışı"), §16.

## GDD — AR-GE MODÜLÜ (rev 1.7; §2 rev 1.8)

- **§0 YÜRÜRLÜK durum satırı; §13.6 "Bilinen liste", 4. madde ("Rail kilidi derleme sabiti")**
  - Eski metin: Ray kilidi bir derleme sabitidir ve v1 yayınında kalkacak biçimde duruma bağlanmalıdır; §0 rev 1.8'i anmaz.
  - Yürürlükteki kural: Madde kapandı. Ray öğesi ilk günden normal bir sekmedir: YAKINDA rozeti yok, sönük değil, tıklaması yutulmaz. Ağacın v1 kapısı sayfadadır: v1 yayınlanmadan önce sayfa yalnız "Ar-Ge, ilk sürümünü yayınladıktan sonra açılır." satırını gösterir, ilk sürüm yayınlanınca ağaç açılır. Derleme sabiti ve ray kilidi yoktur. §0'ın durum satırı rev 1.8'i (§2: kapı sayfada, ray normal sekme) sayar. ch12 §1 ve ch14 §3'ün güncellenmesi açık karardır.
  - Kaynak: aynı belgenin §2'si (rev 1.8, mühürlü); GDDs/README; cc952e4.

- **§5.4 Hız; §5.5 Süre önizlemesi ("~9 gün"); §8 EKRAN, kart örneği ve "Tek sayı gün tahminidir"**
  - Eski metin: araştırma/gün = Σ_kişi [max(etkin çıktı, gereken alanlar) × saat/8] × K_ARGE; kart gereken alanın yanında gün tahmini yazar ("Ürün ★2 · ~9 gün · Kurucu") ve atama değiştikçe tahmin güncellenir; ekrandaki tek sayı gün tahminidir.
  - Yürürlükteki kural: Formül ve K_ARGE gün verisidir; saat/8 terimi saat verimidir (Ekip §8.2 maddesi). Her tik günlük hızın 7 günlük payını ekler. Toplantı haftasında kurucunun terimi 1 − (haftanın toplantı saati / 40) ile çarpılır (Satış §5.0 maddesi). Tahmin haftadır: kalan efor / (günlük hız × 7), ekranda yukarı yuvarlanır, en az 1 hafta. Ekrandaki tek sayı hafta tahminidir ve atama değiştikçe anında güncellenir.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §8, §9; sahip kararı 2026-09-27/28.

- **§5.6.2 ODA odasında donmuş araştırma (MÜHÜRLÜ)**
  - Eski metin: Oyuncu ODA'dayken yüzen tracker gizlenir ve cam ürün barını gösterir; odadaki oyuncunun donmuş araştırması hiçbir yüzeyde görünmez, ona ulaşan tek yüzey ray rozetidir.
  - Yürürlükteki kural: ODA yoktur. Yüzen tracker (BuildHUD) bir çubuğu doluyken ofiste de görünür; donmuş araştırma orada kendi çubuğunda durur. Ray rozeti donmuş araştırmayı okunmamış raporla aynı yuvada saymayı sürdürür.
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis; BuildHUD ofiste de görünür); ch12 §3 maddesi.

- **§6.1 Ne olduğu ("30 günde bir"); §8.5 KAYIT ("30 günlük sayaç"); §13 KALİBRASYON YÜZEYLERİ ("rapor periyodu 30 gün"); §13.5 DEMO KAPSAMI ("kurucunun 30+ gün ürün yapmaması")**
  - Eski metin: Aylık ürün notu user_research'ten sonra 30 günde bir [K] gelir; kayıt son raporun gününü (30 günlük sayaç) saklar; demo kapsamı devam seviyesini kurucunun 30 günden fazla ürün yapmamasıyla ölçer.
  - Yürürlükteki kural: Ürün notu 4 haftada bir gelir (`report_period_weeks` 4 [K], `data/techtree/rnd_tree.json`); kayıt son raporun tikini saklar. "Aylık" adı kalır; ekonomi ayı 30, rapor aralığı 28 takvim günüdür. §13.5'in ölçüsü hafta birimiyle 4 haftadan fazladır.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§6.1 Ne olduğu, "Teslim biçimi (MÜHÜRLÜ)" paragrafı; §5.8 Tamamlanma, "Kısa bir keşif kartı düşer" cümlesi**
  - Eski metin: Koşunun ilk raporu bir kez modal olarak açılır ve raporun bundan sonra Ar-Ge sekmesinde bulunacağını söyler; sonraki raporlar modal açmaz, Ar-Ge sekmesinde yaşar, ODA masasına kâğıt düşmez. Araştırma tamamlanınca kısa bir keşif kartı düşer.
  - Yürürlükteki kural: Ürün notu ve keşif Olaylar gelen kutusunda mesajdır; modal açılmaz, ilk rapor da açmaz. Ürün notu onu yazan Ürün Yöneticisi ya da Tasarımcının sesiyle gelir; keşif, düğüme atanmış ilk kişinin (yoksa kurucunun) sesiyle gelir ve konusu düğümün adıdır. Mesaj oyunu durdurmaz, listede okunmamış olarak bekler. Rapor Ar-Ge sekmesinde de yaşar; okunmuş sayılması iki yüzeyde ortaktır ve Ar-Ge'nin ray rozeti okunmamış raporu saymayı sürdürür. Kart metni (§6.3'ün üç sinyali, §5.8'in beat'i), ikilem kuralı ve masaya kâğıt düşmemesi değişmez.
  - Kaynak: olay motoru GDD rev 2 §27.13, §27.14; sahip kararı 2026-10-02 (Olaylar gelen kutusu, mesaj dönüşümü).

- **§12.2 Ses ve dil, 1. cümlenin ikinci yarısı ("içerik TR (kanonik) + EN (edebi)")**
  - Eski metin: Ar-Ge'nin oyuncu metninde Türkçe kaynak metindir ve önce yazılır, İngilizce edebi karşılığıdır.
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. Her metin bir anahtar olarak doğar; anahtarlar İngilizcedir. §12.2'nin geri kalanı değişmez. Metni kimin yazdığı açık karardır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

## GDD — SATIŞ MODÜLÜ (rev 6.1 · İNŞA SÜRÜMÜ)

- **§3 MUSLUK, "Akış" satırı; §4 BORU HATTI, "Lead ömrü" ve "Dönüş kilidi" maddeleri; §12 "Süresi dolan lead" satırı; §17 "lead ömrü (7) · dönüş kilidi (30)"**
  - Eski metin: Akış haftalık oranlarla gelir (taban 3, atanmış temsilci başına +2); çalışılmayan lead 1 hafta bekler; süresi dolan şirket 30 günden önce dönmez; kalibrasyon listesi lead ömrünü 7, dönüş kilidini 30 gün sayar.
  - Yürürlükteki kural: Haftalık oranlar her tike doğrudan düşer; lead'ler haftanın başında toplu gelir (tik başına en çok 14, `SalesConstants.FAUCET_TICK_MAX` [K]). Lead ömrü 1 haftadır (`LEAD_LIFE_WEEKS` 1 [K]). Süre dolumu temsilci masasından sonra süpürülür: lead dolduğu tikte de temsilci masasına girebilir, hafta içinde doğan lead (olay kartından gelen) ertesi tikin masasına ulaşır. Dönüş kilidi 4 haftadır (`RETURN_LOCK_WEEKS` 4 [K]). Açık (ACIK_KARARLAR 79): hafta içinde doğan lead'e ek hafta kararının bu sırayla karşılanması.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§5.0 Zaman modeli ve sahne sınırı (MÜHÜRLÜ): "Kapanışta saat 2 saat atlar", "Tempo" ve "Giriş kapısı" maddeleri; §12 "Kurucu toplantıda" iki satırı, "Mesai bitimine 2 saatten az" ve "Aynı gün ikinci toplantı" satırları; §19 "günde-1 mesai-başı hak"**
  - Eski metin: Toplantı tam sahne değişimidir; kapanışta saat 2 saat atlar ve atlanan saatler kurucu katkısı sıfır sayılarak simüle edilir (kurucu tek işçiyse taşıdığı iş ilerlemez). Kurucu günde bir toplantıya girer, hak her mesai başında yenilenir; mesai bitimine 2 saatten az kala giriş kapalıdır. Aynı gün ikinci toplantı kapalıdır, hak yarın mesai başında gelir.
  - Yürürlükteki kural: Toplantı tam sahne değişimi değildir: kabuğun içinde, ofis görünümünde toplantı odası ve sağda görüşme paneliyle oynanır (§5.1.1 maddesi); üst bar, ray ve haber bandı görünür ama tıklanmaz. Oturum atomiktir; açıkken saat durur ve kurucu meşguldür (bu durum kayda girmez). Satış sekmesindeki "Görüşmeye git" pencereyi kapatır ve ofiste telefonu çaldırır: Kabul et toplantıya götürür, Ertele kartı kapatır ve telefon çalmaya devam eder. Kapanışta saat toplantının süresi kadar, 2 saat [K] ileri atlar (`SalesConstants.MEETING_SKIP_HOURS`); atlanan saatler gerçek saatlik yoldan simüle edilir (`TimeManager.advance_hours`), kesirli saat korunur. Atlama kurucunun mesai bitimini ve gece yarısını geçmez; kalan saatleri gece atlaması taşır. "Kurucu katkısı sıfır" kuralı kalkar: toplantı kurucunun o haftaki çıktısından saat/40 payını alır (`TimeModel.WEEK_WORK_HOURS` 40 [WORKING]); 2 saatlik toplantı haftalık kurucu çıktısının %5'i, dört toplantı %20'sidir. Saatlik sistemlerde (yapım, destek masası) kurucu atlanan saatlerde 1 − 24/40 = 0,4 katsayıyla sayılır; günlük sistemlerde (Ar-Ge birikimi) kurucu terimi 1 − (haftanın toplantı saati / 40) ile çarpılır; sayaç yeni haftada sıfırlanır. "Günde bir toplantı" kuralı kalkar: bir hafta en fazla 4 satış toplantısı taşır (`SalesConstants.MEETINGS_PER_WEEK` 4 [WORKING]), mesai uzunluğundan bağımsız; sayaç yeni haftada sıfırlanır ve beşinci giriş "hafta dolu" nedeniyle kapalıdır. Giriş gece ve kurucunun mesai bitimine 2 saatten az kala kapalıdır (`MEETING_ENTRY_CUTOFF_HOURS` 2 [ÇALIŞMA]). Kurucu toplantıya ofisten çıkıp şehir haritası üzerinden gider ve döner (ch12 ofis kademesi maddesi). Seed ve Series A pitch'i ile term sheet masası aynı atlama ve pay kuralıyla çalışır ama bu tavana sayılmaz (ch09 §4 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §8; sahip kararı 2026-09-27/28; görüşme akışı kararları (Erdem, 2026-09-28/29: her görüşmede davet, görüşme kabuğun içinde).

- **§5.1.1 Sahne kurgusu, "Sahne sunumu (MÜHÜRLÜ — rev 6.1)" ilk cümlesi; §0 YÜRÜRLÜK'teki rev 6.1 notu**
  - Eski metin: Solda toplantı ortamı ve karşı tarafın kimlik bloğu, sağda diyalog sütunu.
  - Yürürlükteki kural: Solda 3B toplantı odası: muhataplar masada oturur, kurucu gelip oturur, bakışlar ve jestler konuşmayı izler. Sağda krem görüşme paneli, VC görüşmesiyle aynı düzen. Panelin başında konuşan muhatabın 3B bust'ı, adı, rolü ve şirketi, yıldız satırı ve tek satırlık arketip durur; balina şartı rozeti başlık satırındadır. Altında TUTUM (iğnenin sözcüğü: sıcak, ılık, temkinli, soğuk; yanında "İkna %n", üstüne gelince nedenler: sessiz iğne), HAFIZA satırı, kayan konuşma dökümü ve numaralı seçenekler. Perde 2 aynı panelde sürer: TUTUM'un yerini sabır kutuları, seçeneklerin üstünü cetvel ve anlaşma satırları alır. Oda, portre ve başlık perde değişiminde yerinden oynamaz. Masada adayın yıldızı kadar kişi (1–3: satın alma sorumlusu, ekip yöneticisi, finans direktörü) oturur; kişiler aday kimliğinden tohumlanır, kayda girmez, adları koşunun başlangıç dilinin havuzundan gelir. Sorular masada sırayla dağılır, kapanışı satın alma sorumlusu konuşur. Paragrafın geri kalanı (terminal grameri yasağı dahil) yürürlüktedir.
  - Kaynak: direktör hükmü, 754a822; görüşme akışı kararları 2, 3, 8 (Erdem, 2026-09-28/29; Claude Design "Yatırımcı Görüşmesi v3"); cf80260.

- **§5.3 Perde 2, "Onay şeridi (MÜHÜRLÜ)" maddesinin sonu ("→ İmzala"); §16 örneğinin son adımı**
  - Eski metin: Kabulde onay şeridi koltuk × fiyat = MRR ve doluluk okumasını gösterir, oyuncu İmzala ile imzalar.
  - Yürürlükteki kural: Kabulde masa kapanır ve sonuç kartı gelir: bant ("Anlaşma imzalandı"), masaya etkisi (koltuk × fiyat = MRR · Kapasite), liderle ilişki ve varsa verilen söz; Devam imzayı işler (`SalesFinalizer.apply`) ve oturumu kapatır. Ayrı bir İmzala düğmesi yoktur. Karar cümlesi ve replik yine yoktur. Kayıp, fiyattan kalkış ve hakaret de aynı sonuç kartıyla biter.
  - Kaynak: görüşme akışı kararları (Erdem, 2026-09-28/29; Claude Design "Yatırımcı Görüşmesi v3" sonuç kartı); cf80260.

- **§5.3 Perde 2, "Kalk her an açık … 30 gün kilidi"; §12 "Pazarlıktan Kalk" satırı**
  - Eski metin: Pazarlıktan kalkmak nötr bir ayrılıştır ve 30 günlük kilit [ÇALIŞMA] bırakır, iz bırakmaz.
  - Yürürlükteki kural: Kalk kilidi 4 haftadır (`SalesConstants.WALK_LOCK_WEEKS` 4 [ÇALIŞMA]); ayrılış yine nötr ve izsizdir.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§7.2 İşleme süresi (MÜHÜRLÜ); §7.5 "Premium işleme süresini uzatır [K +%30]"; §17'nin işleme süresi girdisi**
  - Eski metin: Temsilci tek müşteri işler ve boru hattında işlemenin kaçıncı gününde olduğu görünür; süre kendi ligde 6 ile 7, bir alt ligde 3 ile 4, iki alt ligde 2 ile 3 gündür [K]; moral, odak ve saat süreyi `hr.effective_skill` üzerinden oynatır; Premium süreyi %30 uzatır.
  - Yürürlükteki kural: İşleme bir süre değil, tik başına kapanma ihtimalidir (`SalesConstants.PROCESS_CLOSE_CHANCE` [WORKING]): kendi ligde %50, bir alt ligde %75, iki alt ligde %100; her işleme tikinde tohumlu bir zar atılır (`RngStreams`). Beklenen süre 2 / 1,33 / 1 haftadır. Premium ihtimali 1,3'e böler (`PROCESS_PREMIUM_PENALTY` 0,30 [K]); beklenen süre yine ×1,3 uzar. Temsilcinin etkin çıktısı (moral, odak, saat) artık süreyi oynatmaz. Açık (ACIK_KARARLAR): temsilci çıktısının işleme süresine etkisinin kalkması.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§7.3 Sunum, "Haftalık satış özeti … 7 günde bir"; §17 "haftalık özet günü"**
  - Eski metin: Haftalık satış özeti yalnız kapanışları taşıyan bir bilgi kartıdır ve 7 günde bir gelir [ÇALIŞMA].
  - Yürürlükteki kural: Haftalık satış özeti her tikte, yani her hafta değerlendirilir (`SalesConstants.WEEKLY_SUMMARY_INTERVAL_WEEKS` 1 [ÇALIŞMA]). Olay kartı değil gelen kutusu mesajıdır: masanın kapanış yaptığı haftada o haftanın kapanış satırları ve defterdeki hesap sayısı, yazıldığı anki hâliyle gönderilir (`SalesRepSystem`, `MessageSystem`); masanın satırı kapatan temsilcinin adını taşır. Saati durdurmaz, olay kuyruğuna girmez.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §3, §4; sahip kararı 2026-09-27/28; Erdem, 2026-10-02 kararı (karar dışı anlar gelen kutusuna taşınır, haftalık satış özeti oyunu durdurmaz).

- **§7.6 Kapanış modeli ve fiyat-kırma kartı: "işlemenin son günlerinde", "30 gün kilit", "HAYIR DİYEMEZ'li temsilcide kart daha sık [K]"; §17 "kart tetik günü + HAYIR DİYEMEZ çarpanı"**
  - Eski metin: Premium'da fiyat-duyarlı arketiplerde işlemenin son günlerinde fiyat-kırma kartı düşer; fiyatta kalınca deal düşer ve 30 günlük kilit gelir; HAYIR DİYEMEZ'li temsilcide kart daha sık düşer.
  - Yürürlükteki kural: İşlemenin sabit bir süresi olmadığı için "son günler" yoktur: Premium'da fiyat-duyarlı arketip her işleme tikinde zardan önce değerlendirilir ve kart lead başına en çok bir kez düşer. 30 günlük kilit 4 hafta okunur. HAYIR DİYEMEZ'in kartı sıklaştırma bağı kalkmıştır. Kartın bağlanması hâlâ olay paketindedir; o güne dek kart inerttir. Açık (ACIK_KARARLAR): HAYIR DİYEMEZ'in fiyat-kırma bağı.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §4; sahip kararı 2026-09-27/28.

- **§11.5 Üretim hattı, "TR kanonik önce, EN edebi sonra tek pastada"; §11.9 Üslup yasaları, 9. madde ("TR kanonik önce yazılır")**
  - Eski metin: Türkçe kanoniktir ve önce yazılır; İngilizce sonra, tek pastada yazılır.
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. "Tek pastada" şartı kalktı; her metin yine bir anahtar olarak doğar. Çeviri kokusu yasağı sürer: İngilizce sözdizimiyle kurulmuş Türkçe cümle katalogdan geçmez. §11.5'in geri kalanı (PH yer tutucusu, düzyazıyı kimin yazdığı) açık karara bağlıdır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

- **§13 Kayıt, ilk paragraf (kaydedilen alanlar listesi)**
  - Eski metin: Listede koşunun ilk 3★ hesabına dair bir kayıt yok.
  - Yürürlükteki kural: Liste "koşunun ilk 3★ hesabı" ile genişler (§7.3 haber değeri; churn hesabı defterden siler, koşudan silmez). Kodda `GameState` bayrağı `sales_first_top_star_id`: ilk 3★ imzada `SalesSystem.add_b2b_customer` yazar, `SalesLedger.is_newsworthy_signing` okur.
  - Kaynak: f4b3460 (ACIK_KARARLAR 3. madde kapandı; kodun doc yorumu ve §7.3 "koşunun ilk 3★'ı").

- **§13 Kayıt, "günlük toplantı hakkı", "geliş günü" ve "Şema bir sürüm artar"**
  - Eski metin: Kayıt günlük toplantı hakkını, lead'in geliş gününü ve temsilcinin işleme gününü taşır; şema bir sürüm artar.
  - Yürürlükteki kural: Günlük hak yerine haftalık satış toplantısı sayacı kaydedilir (`GameState.sales_meetings_week`: tik ve sayı). Kurucunun haftalık toplantı saati (`founder_meeting_hours`) haftalık payın tek kaynağıdır ve yeni haftada sıfırlanır. Lead ve işleme damgaları tiktir. Toplantıdaki meşguliyet kayda girmez. Şema v14'tür (Ürün §0 maddesi).
  - Kaynak: `GDD — ZAMAN MODELİ.md` §8, §10; sahip kararı 2026-09-27/28.

- **§14 OKUMA YÜZEYİ, `sales.lead_days_left` ve `sales.meeting_available_today` sorguları**
  - Eski metin: Katalog lead'in kalan gününü ve kurucunun bugünkü toplantı hakkını okur.
  - Yürürlükteki kural: Sorgu adları haftaya döner: `sales.lead_days_left` yerine `sales.lead_weeks_left`; günlük hak olmadığı için `sales.meeting_available_today` düşer. İkisi de henüz bağlı değildir.
  - Kaynak: `GDD — ZAMAN MODELİ.md` §1, §8; sahip kararı 2026-09-27/28.
