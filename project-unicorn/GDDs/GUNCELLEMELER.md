# GDD güncellemeleri

Bu ek, bir .docx GDD'nin kesinleşmiş sahip kararlarının ya da kodun gerisinde kaldığı yerleri kaydeder.
**Bir GDD ile bu dosya ayrışırsa bu dosya geçerlidir.** .docx güncellendiğinde ilgili madde buradan silinir.
Buraya yalnız kesinleşmiş olan girer; açık sorular `../docs/ACIK_ISLER/ACIK_KARARLAR.md`'dedir ve her maddede
"açık" diye anılan kısım bu dosyanın kuralı değildir. Olay motorunun md'si doğrudan güncellenir, burada yer almaz.

Her madde: **Bölüm ve madde** · Eski metin (özet) · Yürürlükteki kural · Kaynak. ONERI_v3'ün K numaraları
`git show 6e3e190:project-unicorn/docs/handoff/ONERI_v3_K1-K32.md` ile okunur.

## GDD v2 — 01 · The Run (spine)

- **§1 Length and slice, "Demo slice" satırı; §10 Open items, 1. madde**
  - Eski metin: Demo Bootstrap'tan Traction'ın içine kadar sürer; kesim noktası Traction içinde bir yerdir ve ch13/14'e bırakılmıştır.
  - Yürürlükteki kural: Demo Bootstrap → Traction → Series A boyunca sürer ve Series A kararı sonuçlanınca biter; imza koşuyu zafer sonuyla kapatır. Seed ara basamaktır, kesim noktası değildir. §10'un ilk maddesi kapanmıştır. 60–90 dakika [WORKING] hedefi ve "her baskı döngüsünden en az bir tur" şartı kalır. Açık: son kümesi, "Series A kararıyla yüzleşti" sayılan haller (D5), build kapsamı ve EA/tam davranışı.
  - Kaynak: ch14 §1; GDDs/README (ch01 §1 → ch14 §1–§2); CLAUDE.md §1.

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
  - Yürürlükteki kural: Kurucu bir işgücü birimi değildir: Görevler matrisinde ve Kadro'da yer almaz. Kural "her şeyi yapabilir, aynı anda yapamaz"dır; kısıt bir yasak değil bir sonuçtur. Aktif yapımı taşıyabilecek kimse boş değilse yapım durur ve "Kimse üzerinde değil." ya da "Ekip başka işte." gerekçesiyle okunur (kişi adı yok). Meşguliyet tek modeldir: izin · eğitim · (kurucu) yatırım hazırlığı · (kurucu) satış toplantısı; ilk üçü Ekip §2.2'nin listesidir, satış toplantısını kod ekler (Satış §5.0, `HRSystem.is_busy`). Ara kademe ya da yarı hız yoktur. Kurucunun görev durumları Ekip §2.3'tedir; araştırma dışlayıcı bir iştir (Ar-Ge §5.0). Kurucu eylemlerine "Kurucu satışta" türü kilit gerekçesi yoktur. Satış toplantısının zaman modeli Satış §5.0'dadır.
  - Kaynak: Ekip GDD §0.1, §2, §2.1–§2.3, §12, §17.6; Ar-Ge GDD §5.0; Satış GDD §5.0.

- **§6 Energy / burnout (founder), bölümün tamamı**
  - Eski metin: Kurucunun enerji barı mesai ve "her şeyi kurucu yapıyor" dönemlerinde düşer; düşük enerji yetenek cezası verir, olay tetikler, TopBar/ODA rozeti olur.
  - Yürürlükteki kural: Kurucu enerji barı ne bu sürümde ne sonrasında vardır; §6 iptal edilmiştir. Kurucunun morali de yoktur; ek mesaide moral kaybı ya da yorgunluk cezası almaz (uzun gün veriminin bedelsizliği Ekip §17.5'te park edilmiş bir açıktır).
  - Kaynak: Ekip GDD §2, §17.6; GDDs/README (ch02 §6 → Ekip).

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
  - Yürürlükteki kural: Kurucu sekiz sayı taşır: altı alan + Liderlik + Karizma; Hız, Pazarlama ve Operasyon yoktur. Chapter 07'nin yerini Ekip GDD'si alır. §12'nin Hız sorusu (Hız kaldırıldı) ve rol eşlemesi sorusu (Ekip §4.4'te mühürlü) kapanmıştır. Açık: §11'in yaşam gideri maddesi (ACIK_KARARLAR 21).
  - Kaynak: Ekip GDD §0, §2.5, §4, §4.4; GDDs/README (chapter 07 → Ekip).

## GDD — ÜRÜN MODÜLÜ (`GDD v2 — 03 · Product Lifecycle.docx`, rev 6.1)

- **§0 YÜRÜRLÜK ("kayıt şeması v9"); §22.5, 1. paragraf; §24'ün §22.5 notu**
  - Eski metin: Kayıt şeması v9'dur; ağaçtaki değer 8, Ürün paketi v9'a çıkarır. v9 altındaki kayıt açıkça reddedilir; v1–v8 göç merdiveni ağaçta durur.
  - Yürürlükteki kural: `SaveManager.SCHEMA_VERSION` 12, `MIN_LOADABLE_VERSION` 10. v10 altındaki her kayıt (v9 dahil) `SAVE_ERR_TOO_OLD` ile reddedilir ve state teslim edilmez. v10 kayıtlarında yalnız Satış rev 6 göçü çalışır; v1–v8 göç dalları yükleyiciden kaldırılmıştır. §22.5'in geri kalanı (açık mesaj, alan listeleri) yerinde kalır.
  - Kaynak: cc952e4 (şema v10, eski kayıtlar bilerek öldü); 82bfcbd; CLAUDE.md §6; §24'ün "inşa bittiğinde kod öncüdür" kuralı.

- **§5 TASARIM, "Ters çevrilme yasağı" son cümlesi; §12.12, 45 kimlik kademesi maddesinin son cümlesi**
  - Eski metin: K(n+1) ≥ K(n) × 1,6 kısıtı kademelerin ham eksen puanına uygulanır.
  - Yürürlükteki kural: Kısıt ağırlıklı katkıya (ham puan × Kano katsayısı) uygulanır. Mühürlü merkezlerde (4 · 9 · 12) ağırlıklı katkılar 4,0 · 7,2 · 14,4, oranlar 1,80 ve 2,00'dir; ham puana uygulansaydı mühürlü K3 merkezi 12 kırılırdı. Katalog yüklenirken denetlenir, ihlal eden hat reddedilir.
  - Kaynak: aynı belgenin §24'ü, §12.4 notu (direktör hükmü 2026-08-25); cc952e4.

- **§8.2 Doğrulama, formülden sonraki iki cümle**
  - Eski metin: Kurucu masaya yalnız Destek'e atanarak girer; Destek'e kimse atanmamışsa masa kapalıdır.
  - Yürürlükteki kural: Masa kadrosu Destek işine atananlar ile pasif ilgideki kurucudan oluşur. Kurucu Destek'e yine atanabilir. Ayrıca ürün canlıyken, kurucu aktif, meşgul değil (izin, eğitim, yatırım hazırlığı, satış toplantısı) ve hiçbir işe atanmamışsa atanmadan kadroya girer; katkısı temsilcilerinkine eklenir, doğrulama (Müşteri İlişkileri) ve düzeltme koşusu (Yazılım) aynı kadro üzerinden toplanır. Saklanan durum yoktur; okuma kendiliğinden başlar ve biter. Masa yalnız Destek'e kimse atanmamışken kurucu da meşgulse, başka bir işe atanmışsa ya da ürün canlı değilse kapalıdır. "Kurucuyu masaya oturt" fiili yoktur.
  - Kaynak: 8b5bb9e (Destek hattı reworku B1–B2, yönetmen hükümleri).

- **§11.3 Pazar çıtası, "Okuma formülü" paragrafı (ilgili: §11.2 "üç hat")**
  - Eski metin: Çıta faz başına tek sabit sayıdır (12,0 / 13,2 / 14,5) ve her eksen için aynıdır.
  - Yürürlükteki kural: Faz çıtası (12,0 · 13,2 · 14,5; faz başına +%10 [K]) üç hat × K1'e kalibredir ve eksen başına okunur: çıta_eksen = çıta_faz × (üründe o eksende fiilen var olan hat sayısı) / 3. Katalog hatları her zaman sayılır; gizli (Ar-Ge) hat ilk kademesi yayınlandığında sayıya girer, açıldığında değil. Ölçeklenen okumadır; ekonominin kullandığı gerçekleşen değer değişmez. eksen_okuması = round(100 × gerçekleşen_eksen / çıta_eksen), 0–120.
  - Kaynak: Ar-Ge GDD rev 1.7 §4.5 (mühürlü) ve YÜRÜRLÜK satırı.

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
  - Yürürlükteki kural: Ağacı Ar-Ge GDD'si (rev 1.7) yönetir: 4 aile × 5 yuva (kök, iki dal, iki devam), 20 düğüm; ağacın şekli baştan görünür, açığa çıkmamış yuvalar kilitli durur. Aile kimlikleri iç kimliktir; ekrandaki başlıklar İŞLEV · PLATFORM · SÜREÇ · TASARIM. Araştırma Ekip'in iş listesinde dışlayıcı bir iştir (Ar-Ge §5.0). Eşikler: kök ★1, dal ★2, devam iki alanda ★2 + ★2 (8 devam düğümü). Hız: araştırma/gün = Σ_kişi [max(effective_skill(kişi, gereken alanlar)) × saat/8] × K_ARGE (1,0 [K]); kişi başına tek katkı. Aile → alan eşlemesi aynıdır. §23'ün ilk maddesi kapanmıştır.
  - Kaynak: Ar-Ge GDD rev 1.7 §3, §5.0, §5.2, §5.4; GDDs/README.

- **§24 İNŞA NOTLARI, §12.5 notunun son cümlesi (ERP K3)**
  - Eski metin: Ar-Ge'nin "ERP kayıt-arama K3" vaadine karşılık `line_erp_ledger_k3` ruling gelene dek `semantic_index`'e bağlıdır.
  - Yürürlükteki kural: Ruling geldi. `line_erp_ledger` ERP'nin kimlik Kararlılık hattıdır ve K3'ü `bug_tracker`'a bağlıdır. `semantic_index`'in ERP K3'ü `line_erp_intake_k3`'tür. Öbür ERP K3'leri: cashflow → `analytics_engine`, stock → `design_system`, invoicing → `scalable_backend`. Düğüm kimliklerinin tek kaynağı Ar-Ge GDD'sidir.
  - Kaynak: Ar-Ge GDD YÜRÜRLÜK satırı (rev 1.5, rev 1.6), §4.5.1, "Bağlayıcı ilişkiler".

## GDD v2 — 06 · Operations

- **§1.1 Servis maliyeti, formül satırı ve "Product type changes the slope" cümlesi**
  - Eski metin: serving_cost = provider_fixed(tier) + unit_cost(tier) × usage; ürün tipi eğimi belirler.
  - Yürürlükteki kural: Sunucu faturası = satın alınan kapasite birimi × sağlayıcının birim fiyatı. Birim fiyatı pazara göredir: B2C 1.000 kullanıcı/ay, B2B 50 koltuk/ay başına (Yerel 35/30, Bulut 55/45, Kurumsal Bulut 85/70 [K]). Sabit sağlayıcı ücreti ve kullanımla orantılı terim yoktur. Fatura burn'e günlük işler (aylık/30). Kullanım faturaya dolulukla girer: doluluk = kullanıcı ya da koltuk / etkin kapasite; etkin kapasite = birim / yük; yük = 1 + Σ kullanım ağırlığı / 20 [K]. Ağır (AI) özellikler maliyete yük üzerinden biner.
  - Kaynak: Ürün GDD rev 6.1 §10 (mühürlü) ve §23 ("Operasyon — KAPANDI").

- **§1.2 Destek yükü, formül satırı, "load > capacity" satırı ve "Reader" satırı**
  - Eski metin: yük = a·aktif_hesap + b·canlı_hata + c·sürüm_yaşı; kapasite = throughput × atanan × Müşteri Başarısı × Hız; aşımda yanıt süresi kötüleşir.
  - Yürürlükteki kural: Destek iki sayaçla çalışır: GELEN BİLDİRİM ve DOĞRULANMIŞ HATA. Doğrulama/gün = 0,8 × Σ Müşteri İlişkileri etkin çıktısı × saat/8 [K]; düzeltme/gün = 1,2 × Σ Yazılım etkin çıktısı × saat/8 [K]; Hız yoktur. Yük tarafı Ürün §9'un GELEN akışıdır. Ayrı bir yanıt süresi sayısı yoktur; zarar iki kademelidir: doğrulanmamış her 10 GELEN için −0,6/gün, doğrulanmış açık her 10 için −0,3/gün, tavan −2,0/gün [K]. Okuyucu DESTEK barının iki sayacı ve ısınma çizgisidir (20/40). Açık: akıştaki taşınan hata teriminin uygulanışı (ACIK_KARARLAR 45).
  - Kaynak: Ekip GDD §17.6; GDDs/README (ch06 §1.2 → Ekip §17.6); Ürün GDD rev 6.1 §8.1–§8.5, §9.

- **§2 Altyapı giriş cümlesi, §2.1 Provider, §2.2 Capacity; §7 Open decisions, 4. madde**
  - Eski metin: Üç kurgusal sağlayıcı (Northwind / Halcyon / Vireo) güvenilirlik ve gecikme tabanını belirler; yetersiz kapasite kesinti olasılığını artırır; altyapı adımı her sürümde sorulur; sağlayıcı adları açıktır.
  - Yürürlükteki kural: Sağlayıcılar Yerel Sağlayıcı, Bulut Sağlayıcı, Kurumsal Bulut'tur; birim fiyatı ve kalite etkisiyle ayrışırlar (Yerel: GELEN ×1,25; Bulut: nötr). Sağlayıcı canlıda her an bedelsiz değişir, yeni fiyat ertesi günden işler; kapasite her an ±1 birim, cezasız. Doluluk %80–100'de kapasite çubuğu sararır; %100'ün üstünde memnuniyet −0,8/gün, GELEN ×1,5, B2C edinim ×0,6 [K]. Etkiler deterministiktir; rastgele kesinti yoktur. Altyapı adımı v1 yayın akışında sorulur (B2C: Fiyat → Altyapı → Onay; B2B: Altyapı → Onay); v2+ tek tık YAYINLA'dır. Sağlayıcı ve kapasite canlı ürünün kapasite bloğundan yönetilir. §7'nin adlar sorusu kapanmıştır. Açık: kurumsal güven koşulu (ACIK_KARARLAR 4), kapasite uyarı kartı (42), 0 birimde tek adımlı ALTYAPI (55), §2.3 ve §3'ün kesinti olayları.
  - Kaynak: Ürün GDD rev 6.1 §10 (mühürlü), §23, §24 (direktör hükmü 2026-08-25).

- **§4 Links, "HR (02/07)" satırı; §1.3 "assign the founder … lock"; §5 First bite, "the founder lock"**
  - Eski metin: HR Operasyon ve Müşteri Başarısı yeteneklerini okur; kurucu atama kilidi (yapım/satış/fon toplama) vardır.
  - Yürürlükteki kural: Operasyon bir yetenek ya da alan değildir. Destek işini Müşteri İlişkileri (doğrulama) ve Yazılım (düzeltme) taşır. Kurucu kilidi yoktur; kısıt bir yasak değil bir sonuçtur: kurucu yeni yapıma geçer ve Destek boş kalırsa GELEN birikir, memnuniyet erir. §5'in "ilk ısırığı" budur.
  - Kaynak: Ekip GDD §2.1, §4, §12.0; Ürün GDD rev 6.1 §8.2, §8.4, §8.6.

## GDD v2 — 08 · Finance & Economy

- **§1 Burn, 4. satır (servis maliyeti)**
  - Eski metin: Servis maliyeti Ops'tan gelir: sağlayıcı kademesinin sabit ücreti + birim × kullanım.
  - Yürürlükteki kural: Servis maliyeti sunucu faturasıdır: kapasite birimi × sağlayıcının birim fiyatı (Ürün §10). Canlı ürün yokken 0'dır; günlük (aylık/30) "servers" burn kalemine işler. Açık: §1'in geri kalan burn bileşimi (ACIK_KARARLAR 21) ve brüt marj (§2).
  - Kaynak: Ürün GDD rev 6.1 §10, §23.

- **§1 Burn, 1. satırdaki tek seferlik giderler ("Atlas retainer"); §8 Links, "HR (07)" satırı**
  - Eski metin: Tek seferlik burn'de Atlas retainer'ı var; HR chapter 07 olarak ve retainer maliyetiyle anılır.
  - Yürürlükteki kural: Retainer yoktur. Atlas araması ücretsizdir; işe alımın tek bedeli, işe alım anında tek seferlik gider olarak düşen bir aylık maaşın %50'si komisyondur. Eğitim bedeli hedef alanın mevcut seviyesine göre kademelenir, tek seferlik giderdir. §8'in HR satırı: maaşlar, işe alım komisyonu, eğitim, zamlar (Ekip GDD). Parantezdeki "lisans" ve "kesinti telafisi" kalemleri bu maddenin konusu değildir.
  - Kaynak: Ekip GDD §0, §5.3, §9.2, §10.

## GDD v2 — 09 · Funding & Investors

Bu bölümdeki maddeler yalnız Series A içindir; seed akışı (§3, §4 "not now") ACIK_KARARLAR'daki "Seed garanti basamaktır" ve K18–K22'de açıktır.

- **§4 The meeting (bölüm sessiz: görüşme ayarlama)**
  - Eski metin: Bölüm aynı anda kaç görüşme olabileceğini, iptali ve ertelemeyi söylemez.
  - Yürürlükteki kural: Aynı anda tek görüşme ayarlanır. Görüşme iptal edilebilir ya da ertelenebilir; ikisi de o fonun bir sonraki görüşmesinde küçük bir inanç cezası bırakır [K].
  - Kaynak: sahip kararı K4 (ONERI_v3 §0A, "uygula"); 28d5edc.

- **§5 Term sheet (bölüm sessiz: teklifin süresi, sayısı ve gösterimi)**
  - Eski metin: Bölüm teklifin ne kadar geçerli kaldığını, aynı anda kaç teklif olabileceğini ve teklifin masadan önce nasıl gösterildiğini söylemez.
  - Yürürlükteki kural: Teklif sabit 10 iş günü geçerlidir; geri sayım yalnız hafta içini sayar (K5). Aynı anda en çok 2 canlı teklif olur; fazlası bekler ve bekleme sırası oyuncuya görünür (K8). Masaya oturmadan önce teklif net sayı değil tahmini aralık gösterir: yaklaşık değerleme ve yaklaşık pay; yönetim kurulu şartı ve ayrıntı masada açılır (K6).
  - Kaynak: sahip kararları K5, K6, K8 (ONERI_v3 §0A, "uygula"); 28d5edc.

- **§5 Term sheet, 3. satır ("accept · negotiate once · decline")**
  - Eski metin: Oyuncu kabul eder, bir kez pazarlık eder (riskli: fon kalkabilir ya da şartları sertleştirebilir) ya da reddeder.
  - Yürürlükteki kural: Series A masasında oyuncu fonun sabır havuzuna karşı birden çok kez itebilir. Her itiş görünür ihtimalli bir kontroldür; başarısız itiş sabrı 1 düşürür. Sabır 0'a inince fon, istekliliğine (E) göre ya son karşı teklifini "al ya da bırak" diye koyar (yalnız İmzala / Kalk) ya da masadan kalkar; kalkan fon koşu boyunca kapanır (K12). Oyuncu masada bir kez öbür canlı Series A teklifini gösterebilir; fonun cevabı (eşler / şartla eşler / yerinde durur / kalkar) dinamik hesaplanır (K7). Süresi dolan teklif kendiliğinden kapanmaz; ertelenemez bir karar kartı "Masaya otur / Reddet" sorar, reddedilen fon kalıcı olarak kapanır (K10). Açık: bu kapanmaların reddedilme zincirine sayımı (K14), E modelinin sabitleri, kilometre taşı maddesi (K13).
  - Kaynak: sahip kararları K7, K10, K12 ve ONERI_v3 §4.1–§4.2 ("uygula"); 2cbbcd8, 28d5edc.

- **§6 Relationships carry, 2. paragrafın son cümlesi ("a fund that passed may return")**
  - Eski metin: Seni geri çeviren fon, rakamların değişirse Series A'da geri dönebilir.
  - Yürürlükteki kural: Reddeden fon geri dönmez; red koşu boyunca kalıcıdır ve cümle çıkar (K9). Series A'da bir fonun kapısı bir kez kapanır: görüşmede reddeden fon, masadan kalkan fon (K12), süresi dolan teklifi karar kartında reddedilen fon (K10) ve oyuncunun masadan kalktığı fon (K11) koşu boyunca kapanır. §4'ün "not now" geri çağrısı red değildir. Açık: §6'nın öbür durumları (seed'de çekilme ve ret, K20), Frank'in tanıştırması, reddedilme zinciri (K14).
  - Kaynak: sahip kararları K9, K10, K11 (ONERI_v3 §0A, "uygula"); 28d5edc.

## GDD v2 — 11 · Events & Narrative

- **§6 Memory, 3. madde ("today it is written and never read")**
  - Eski metin: Koşu geçmişi yazılıyor ama hiç okunmuyor; okunur hâle getirmek hedeftir.
  - Yürürlükteki kural: Hedef gerçekleşti. Her çözüm geçmişe bir satır yazar (gün, çözüm türü, seçenek, sonuç, özneler); koşul sözlüğünün history yaprakları (`fired`, `fire_count`, `chose`, `days_since`, `resolution`; motor §5.2) onu okur; son ekranı ve haber bandı da okuyabilir. Parantez çıkar.
  - Kaynak: olay motoru GDD rev 2 §5.2, §7.1–§7.3.

- **§7 Voice, 1. satır ("TR canonical … EN native and not a translation")**
  - Eski metin: Oyuncu metninde Türkçe kanoniktir; İngilizce çeviri değil, özgün yazılır.
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. Her metin bir anahtar olarak doğar. §7'nin geri kalanı (Edgü kesimi, Frank'in sesi, yasaklar, mühürlü referans metinler) değişmez. Metni kimin yazdığı açık karardır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

- **§10 Open decisions, 3. madde (isimli slot mu sabit ad mı); ilgili §2 cümlesi**
  - Eski metin: Tekrarlanan müşteri olaylarının isimli hesap slotuyla mı sabit isimlerle mi yazılacağı açıktır.
  - Yürürlükteki kural: Kartlar ihtiyaç duydukları varlıkları isimli kapsam slotlarıyla bildirir (aynı tipten birden çok varlık varsa slot adı zorunlu); müşteri kartları bağlanan hesabı metinde `{customer}` ile anar, sabit isim yoktur. Aynı kart her özne için ayrı bir örnek olarak yaşar (motor GDD §20 A6, E2). Madde §10'dan düşer. Açık: seçicili tarama kartı (ACIK_KARARLAR 9), öznesi giden kağıdın süre dolumu (13).
  - Kaynak: olay motoru GDD rev 2 §4.3, §17.12, §26 madde 4; 8c914ec.

## GDD v2 — 12 · UI Surfaces & ODA

- **§1 Tabs (v1), "Events: … arrive as modals from the room (the phone)" cümlesi; §6 ODA, 3. madde ("the phone")**
  - Eski metin: Her olay oyuncuya ODA'daki telefondan gelen bir modal olarak ulaşır.
  - Yürürlükteki kural: Olayların dört sunum sınıfı vardır: interrupt engelleyen modaldır (zaman durur, telefondan açılır); paper ODA masasında bir kağıttır, açılınca modal gibi davranır, kalan süresi üzerinde görünür; info bir sekme rozeti ya da rapordur; ambient haber bandına düşer. Acil olmayan karar kartları masada kağıt olarak bekler. §1'in Ar-Ge sekmesi cümlesi ve olay günlüğünün yeri (§9) bu maddenin konusu değildir.
  - Kaynak: olay motoru GDD rev 2 §11.1, §11.4.

- **§8 Links, "Kişisel → founder card, energy, net worth, events log"**
  - Eski metin: Kişisel yüzeyi kurucu enerjisini de taşır.
  - Yürürlükteki kural: Kurucu enerji barı yoktur ve olmayacaktır; satırdan "energy" çıkar. Kişisel sayfasında moral de yoktur. Net varlık ve olay günlüğü bu maddenin konusu değildir.
  - Kaynak: Ekip GDD §2, §2.5, §17.6; GDDs/README (ch12 §8 → Ekip §17.6).

## GDD v2 — 14 · Scope (v1 / EA / Full)

- **§2 In the demo, 2. madde (alt-tipler ve derinlik); §8 Open decisions, 3. madde**
  - Eski metin: Demo 2 B2B + 2 B2C alt-tipiyle çıkar; derinlik alt-tip başına düz özellik listesinden gelir (eksen başına 3, eksen başına bir araştırma kilitli). Hangi alt-tiplerin seçileceği açıktır.
  - Yürürlükteki kural: Demo alt-tipleri mühürlüdür: Not & Bilgi Aracı ve Video Klip Aracı (B2C), ERP (B2B). B2B'nin ikinci slotu ruling bekler ve tip ekranında kilitli kart olarak durur. Tip ekranında yol başına 3 kilitli kart gösterilir (B2C: Kod Yazan Asistan, Görsel Düzenleyici, Yapay Zeka Asistanı; B2B: Kurumsal Arama, CRM, açık slot). Derinlik hat modelinden gelir: alt-tip başına 9 hat (5 kimlik + 4 paylaşılan, eksen başına 3), her hat 3 isimli kademe (K1–K3); düz katalog kaldırılmıştır. Araştırma kilidi her hattın K3 kademesidir (Ar-Ge düğümü + yıldız). §8'in alt-tip sorusu, ikinci B2B slotu dışında kapanmıştır. Açık: teknoloji borcu, düz katalog kodunun silinmesi (ACIK_KARARLAR 44).
  - Kaynak: Ürün GDD rev 6.1 §12.1, §12.3, §12.11 (mühürlü; direktörün 2026-08-25 kürasyonu), §23.

## GDD — EKİP MODÜLÜ (rev 11)

- **§2.2 meşguliyet listesi; §2.3 "Araştırmada · Meşgul mü: Hayır"; §12.0 "Araştırma sütunu yoktur"; §12.1 odak tablosu; §17.6 "Kod temizliği" 7. madde**
  - Eski metin: Araştırma bir atama hedefi değildir, sütunu yoktur; kurucu araştırırken yapımı durmaz; iki işe atanan kişi her zaman 0,50/0,50 böler; araştırma atama id'si silinecekler arasındadır.
  - Yürürlükteki kural: Araştırma Ekip'in iş listesinde bir iştir ve dışlayıcıdır. Araştırmaya atanan kişinin o sıradaki tek işi araştırmadır: 0,50/0,50 odak bölmesine girmez, başka işe çıktı vermez; öbür atamaları silinmez, duraklar ve araştırma duraklayınca ya da bitince kaldıkları yerden devam eder. Kurucu için de böyledir: araştıran kurucu ürün yapmaz; tek başınaysa aktif yapım duraklar ve yapım barı sebebini yazar. Araştırma sürerken yeni bir yapım başlatılırsa araştırma duraklar ve sebebi yazılır (Ar-Ge §5.6.1). Atama düğümün kendisinde yapılır; Görevler matrisinde araştırma sütunu salt okunur görünür. Araştırma atama id'si kalıcıdır.
  - Kaynak: Ar-Ge GDD rev 1.7 §0 "Bağlayıcı ilişkiler" (meşguliyet kuralının sahibi Ar-Ge'dir), §5.0 (mühürlü), §5.6.1.

- **§2.6 3. madde; §17.1 3. madde ("Karizma ne işe yarar"), yalnız satış ayağı**
  - Eski metin: Karizmanın işlevi onboarding turunda karara bağlanacak açık bir iştir.
  - Yürürlükteki kural: Karizmanın satış işlevi mühürlüdür: satış işi kapatır, Karizma kapıyı açar ve kötü anı kurtarır. Satış toplantısında iki anı vardır: "Yönü çevir" fiili yalnız kurucuda Karizma varsa açılır; lig üstü kapıda Karizma yıldız uyumsuzluğu cezasını kısmen siler [K]. Başka hiçbir satış formülüne girmez; pazarlık (Perde 2) tamamen Satış'ındır. Yatırım tarafındaki işlevi, kurucu unvanı ve huyları bu maddenin konusu değildir.
  - Kaynak: Satış GDD rev 6.1 "Bağlayıcı ilişkiler" ve §5.1 (mühürlü).

- **§10.2 "Beş yıldızlı aday" paragrafı ve son paragraf; §17.4 8. madde**
  - Eski metin: Aday üreteci rol ayırmaz; yıldız dağılımı ve huy olasılıkları tek bir kalibrasyon yüzeyidir; beş yıldızlı aday Kıdemli bantta nadiren çıkar.
  - Yürürlükteki kural: Üreteç Satış Temsilcisi için role duyarlıdır. Satış yıldız eğrisi öbür rollerden yarım kademe aşağıdadır: Junior merkezi ★1–1,5 (★2 aramaların ~%25'inde ve üçlüde tek adayda), Orta ★2, Kıdemli ★3; ★3,5 nadirdir. Demo aday tavanı ★3,5 [ÇALIŞMA]; beş yıldızlı Satış adayı çıkmaz. Tuzak-huy yasağı: faydası o rolün işlerinde ateşlenemeyen huy o rolün havuzuna girmez; Satış havuzunda GERÇEK LİDER ve TİTİZ yoktur. Üçlü arketip yapısı Satış için de geçerlidir.
  - Kaynak: Satış GDD rev 6.1 §11.7, §11.8 (mühürlü, Ekip üretecine taşan hüküm).

- **§10.4 son cümle; §17.5 3. madde (Müşteri Temsilcisinin B2C rolü)**
  - Eski metin: Müşteri Temsilcisinin B2C'deki rolü karara bağlanmamıştır.
  - Yürürlükteki kural: B2C'de hesap sahipliği yoktur, bildirimler kitleden gelir. Müşteri İlişkileri'nin B2C rolü Destek işinde GELEN bildirimi doğrulanmış hataya çevirmek ve Ürün §8.3'ün yanıt etkisidir. Destek iki pazarda aynı mekanikle çalışır; doğrulama unvana değil, Destek'e atananların Müşteri İlişkileri etkin çıktısına bağlıdır.
  - Kaynak: Ürün GDD rev 6.1 §8.6 ("Ekip §17.5'in park maddesi burada kapanır") ve YÜRÜRLÜK satırı.

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

- **§17.5 5. madde ("Build dışı alanlarda ekip lideri"), yalnız Satış masası; §4.2'nin §17.5 göndermesi (Satış için)**
  - Eski metin: Satış, Destek ve Hesap masalarında liderin ne yapacağı karara bağlanmamıştır.
  - Yürürlükteki kural: Satış masasında demoda lider yoktur; alanın moral iklimi kurucunun Liderliğinden okunur. Satış masası lideri bir EA seam'idir. Destek ve Hesap masası ayakları açıktır.
  - Kaynak: Satış GDD rev 6.1 §7.4 ("Ekip §17.5 kapanışı"), §16.

## GDD — AR-GE MODÜLÜ (rev 1.7; §2 rev 1.8)

- **§0 YÜRÜRLÜK durum satırı; §13.6 "Bilinen liste", 4. madde ("Rail kilidi derleme sabiti")**
  - Eski metin: Ray kilidi bir derleme sabitidir ve v1 yayınında kalkacak biçimde duruma bağlanmalıdır; §0 rev 1.8'i anmaz.
  - Yürürlükteki kural: Madde kapandı. Ray öğesi ilk günden normal bir sekmedir: YAKINDA rozeti yok, sönük değil, tıklaması yutulmaz. Ağacın v1 kapısı sayfadadır: v1 yayınlanmadan önce sayfa yalnız "Ar-Ge, ilk sürümünü yayınladıktan sonra açılır." satırını gösterir, ilk sürüm yayınlanınca ağaç açılır. Derleme sabiti ve ray kilidi yoktur. §0'ın durum satırı rev 1.8'i (§2: kapı sayfada, ray normal sekme) sayar. ch12 §1 ve ch14 §3'ün güncellenmesi açık karardır.
  - Kaynak: aynı belgenin §2'si (rev 1.8, mühürlü); GDDs/README; cc952e4.

- **§12.2 Ses ve dil, 1. cümlenin ikinci yarısı ("içerik TR (kanonik) + EN (edebi)")**
  - Eski metin: Ar-Ge'nin oyuncu metninde Türkçe kaynak metindir ve önce yazılır, İngilizce edebi karşılığıdır.
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. Her metin bir anahtar olarak doğar; anahtarlar İngilizcedir. §12.2'nin geri kalanı değişmez. Metni kimin yazdığı açık karardır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

## GDD — SATIŞ MODÜLÜ (rev 6.1 · İNŞA SÜRÜMÜ)

- **§5.1.1 Sahne kurgusu, "Sahne sunumu (MÜHÜRLÜ — rev 6.1)" ilk cümlesi; §0 YÜRÜRLÜK'teki rev 6.1 notu**
  - Eski metin: Solda toplantı ortamı ve karşı tarafın kimlik bloğu, sağda diyalog sütunu.
  - Yürürlükteki kural: Oda arka planda kalır. Karşı tarafın kimlik bloğu (portre ya da baş harf madalyonu, ad, yıldız satırı, tek satırlık arketip, varsa balina şartı rozeti) sağdaki diyalog sütununun başında durur; VC pitch sahnesiyle aynı kompozisyon. Altında tek bir içerik bölgesi vardır: Perde 1 onu doldurur, Perde 2 içeriğini cetvel, sabır kutuları ve onay şeridine çevirir. Oda, portre ve başlık perde değişiminde yerinden oynamaz. Paragrafın geri kalanı yürürlüktedir.
  - Kaynak: direktör hükmü, 754a822 ("kimlik bloğu sütunun BAŞINDA, VC pitch sahnesiyle aynı kompozisyonda").

- **§11.5 Üretim hattı, "TR kanonik önce, EN edebi sonra tek pastada"; §11.9 Üslup yasaları, 9. madde ("TR kanonik önce yazılır")**
  - Eski metin: Türkçe kanoniktir ve önce yazılır; İngilizce sonra, tek pastada yazılır.
  - Yürürlükteki kural: Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil, sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır. "Tek pastada" şartı kalktı; her metin yine bir anahtar olarak doğar. Çeviri kokusu yasağı sürer: İngilizce sözdizimiyle kurulmuş Türkçe cümle katalogdan geçmez. §11.5'in geri kalanı (PH yer tutucusu, düzyazıyı kimin yazdığı) açık karara bağlıdır ("Oyuncu metnini kim yazar").
  - Kaynak: sahip kararı 2026-09-26, 61f38bc; CLAUDE.md §5.

- **§13 Kayıt, ilk paragraf (kaydedilen alanlar listesi)**
  - Eski metin: Listede koşunun ilk 3★ hesabına dair bir kayıt yok.
  - Yürürlükteki kural: Liste "koşunun ilk 3★ hesabı" ile genişler (§7.3 haber değeri; churn hesabı defterden siler, koşudan silmez). Kodda `GameState` bayrağı `sales_first_top_star_id`: ilk 3★ imzada `SalesSystem.add_b2b_customer` yazar, `SalesLedger.is_newsworthy_signing` okur.
  - Kaynak: f4b3460 (ACIK_KARARLAR 3. madde kapandı; kodun doc yorumu ve §7.3 "koşunun ilk 3★'ı").
