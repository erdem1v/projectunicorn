# Erdem'in kararları · 2026-10-20 tur

Tek kaynak: Q, C ve D'nin bütün karar sorularının Erdem'in verdiği cevapları. Yardımcı yönetmen soru soruldukça yazar.
Her satır: soru · Erdem'in cevabı · kimin işine düşer.

## Çalışma şekli
- Öneriler toplu kabul edilmez; her karar Erdem'indir.
- Faz C ve D kod adımları beklemede: önce müşteri beklentisi algoritması araştırması (sürüyor, `wf_75952d14-dd3`), sonra atama araştırması (D'nin oturumuna verilecek), sonra yol haritası güncellenir.
- Bitmiş maket ve kareler MD olarak değil görsel olarak sunulur.

## Daha önce verilmiş ve geçerli (2026-10-19)
- Ofis yalnız paraya bağlanır; Frank çeki şartı kalkar. Evde 1–2 uzaktan çalışan alınabilir. Oyuncuya kredi seçeneği sunulur. → C9 bu kararla yeniden yazılır.

## Atama (D) · Erdem'in tarifi, araştırılacak
- Kartın iki ölçüsü: büyüklük ve gereksinim (en az hangi beceri). Büyük modül birkaç sprint sürebilir (ileride eklenecek kart türü).
- Sprint planında bütün ekip kullanılır; planın toplam büyüklüğü ve ekip büyüklüğü birlikte düşünülür.
- Gereksinimi en yüksek karta gereksinimi karşılayan en iyi kişiler gider ve kart bitene kadar kalır; kalan kartlara o kartı bitirmeye yeten en düşük beceri; tek kişinin yetmediği işe iki kişi; kimse boşta kalmaz.
- PM tarafı aynı: gereksinimi yüksek karta en iyi PM, bitene kadar; küçük kartlara yeten en düşük yıldızlı PM, sırayla.
- Araştırılacak: (1) atamayı kim yapar (oyuncu elle, PM'e devir, sistem; ekip büyüklüğüne göre değişebilir; Erdem'in ilk düşüncesi orta ekipte elle güzel olabilir); (2) boşta kalma ve verim: görünür mü, oyuncunun optimizasyonu mu, böyle bir mekanik olmalı mı.
- Bu tarif D'nin K1–K7, P1–P2, U1–U7, T1–T2 sorularını kapsar; onlar araştırmadan sonra.

## C · Sunucu
1. Sunucu dolunca: **A** — dolu sunucu yalnız kesinti ihtimalini artırır; ekranda yazan kat aynen uygulanır (tavan yük çarpanını yutmaz). Bilgi: Yerel'de 12 hata ve %104 yükte haftalık kesinti %75 olur. (C0v E1 soru 1, 2)
2. Sunucu fiyatı: **bugünkü kalsın** — B2B Standart $120 / 50 koltuk, B2C $250 / 1.000 kullanıcı. Gider payı hedefi (%8–12) bu fiyatla tutmaz; hedef değil fiyat esastır.
3. Ofise taşınmanın peşin bedeli: **iki aylık kira** (İş hanı $8.000, Plaza $16.000, Loft $36.000). Ofisin tek şartı para (İncil); kişi, marka, Frank çeki şartları yok. → C9
4. Ar-Ge "Olay el kitabı" (`incident_playbook`) düğümü: **kalksın.** → C1 (rnd_tree.json, research_tree.gd, metin anahtarları)
- Para hedefleri (runway 4,2 ay, 40 haftalık açık): "ilk çalışan taşınır" kuralıyla ölçülmüştü; evde 2 uzaktan, kirasız kuralıyla C yeniden ölçer. Soru değil.

## Genel kural (Erdem 2026-10-20)
- Yapılan her değişiklikte eski sistemler kontrol edilir: dokunulan, okunan her yer düzeltilir; eski kod silinir ya da düzeltilir. Temiz iş.
- Olabildiğince basit tutulur; konuştukça yeni sistem eklenmez.
- Takvim skandalı: oyun 2012'de başlar (Piyasa 2012 verisini gösteriyor, `PIYASA_CTX_2012`, `data/market/companies.json`), ama `game_state.gd:8` START_DATE 2026. Düzeltilir, tarihi okuyan her yer (metin, mail, smoke, olay) denetlenir. → Q

## C · Ürün sayfası, satış, hesaplar
5. Sunucu kapasitesi: satın alınan kapasite = kullanılabilen kapasite. Ağır kademedeki "etkin kapasite" farkı kalkar; basit tut.
6. Masalar: 3B esas. İlk ofis (İş hanı) 12 masa (10 masada biri yarım görünüyor; 3B 12'ye göre düzeltilir); Plaza 38, Loft 70. Evden uzaktan çalışan sınırı KALKAR (2 kişi tavanı yok); oyuncu istediği zaman ofise geçer. Belli bir MRR eşiği ya da seed sonrası Frank "ofis tutmalıyız" maili atar (eşik sonra konuşulacak). → C9
7. İlk hafta belgesi: aylık gider "$0" yazar; runway satırı "sonsuz" yazmaz. Runway gösterimi araştırılır: diğer oyunlar nasıl gösteriyor; kârdaki şirkette runway yazılır mı ("kârda" mı, yalnız eksideyken mi görünür). → C (küçük araştırma)
8. Gelen kutusundaki "bu hesap ayrılabilir" hatırlatıcısı: kalır (playtest'te yeniden bakılacak).
9. Müşteri isteği: temsilci şartı kalkar. Temsilci yoksa istek müşterinin mailiyle gelir; Müşteri İlişkileri'nde temsilci varsa istek temsilcinin ağzından gelir ("ilgilendiğim şu hesaptan böyle bir talep var").
10. Kayıplar: sebebi ne olursa olsun müşteri kaybı kayıptır, sayılır. Yatırımcı "kaç müşteri kaybettin" değil "müşterilerinin yüzde kaçını tutabiliyorsun" diye sorar: VC'nin churn sorgusu müşteri tutma oranına döner, oran düşükse soru gelir.
11. Destek raporu: Müşteri İlişkileri'nin en yüksek puanlı temsilcisi gönderir; temsilci yoksa rapor gelmez. (Not: kodda Destek işi ile Müşteri İlişkileri ayrı; Erdem'e soruldu.)
12. "Yerel" sunucu adı kalkar (B2B ürün yerel sunucuda olmaz, kafa karıştırır): kademeler ucuz / Standart / Kurumsal gibi adlandırılır. Büyük müşterinin "verilerimiz yalnız kurumsal sunucuda" şartı hem ucuzda hem Standart'ta geçerli.
13. Standart'ta kesinti ihtimali PRD'deki gibi ×0,5. Kurumsal'a geçiş sözleşmeyle bağlanır, geri dönüş yok.
14. Satışçı raporu: bütün satırlar görünür.
15. Atlas "boş masa yok" şeridi: sarı uyarı rengi.
16. C'nin "onay bekliyor" sabitleri PRD değerleriyle girer; ölçüm turunda sorun çıkaranlar Erdem'e gelir.

## Q · Metin ve belge
17. Alanlara özgü cümleler geri gelmez.
18. Frank'in okuyucusuz 4 satırı (PROD_TIP_WEAK, PROD_TIP_GOOD, PROD_DESIGN_CEILING_NOTE, PROD_ITER_CEILING_NOTE) silinir.
19. Okuyucusuz 10 İK cümlesi (HR_AREA_MEANING_*) silinir.
20. VC_B1_CHOICE: "Odayı oku." / "Read the room." (ya da "Atmosferi oku"). Ayrıca incelenecek: bu seçenek ne değiştiriyor, karizmaya mı bağlanmalı, gerek var mı (yol haritasına madde).
21. Zar ipucu büyük harfle başlar.
22. Belge temizliği: önerilen yapılır; oyunda olmayan eski mekanikler silinir; oyunu etkileyen bir şey çıkarsa Erdem'e getirilir.
23. Faz PRD'leri repoya alınmaz; bütün ajanlar yerelde okuyabiliyor.

## D · Sprint metinleri ve fiyat
24. Dışarıdan iş (outsource, `paper.contract_per_point`) mekaniği tamamen kalkar; kodu, verisi, metni temizlenir. → Q şimdi yapar (D'ye bilgi)
25. Müşteri istek kartının adı müşterinin istek kâğıdının konusundan gelir (B). Erdem iki seçeneği tam anlamadığını söyledi.
26. Taşma yokken darboğaz satırı bir şey yazmaz. Darboğaz konusu atama/verim araştırmasına girer: zayıf planlamada "bu plana göre şurada darboğaz oluşabilir" gösterimi.
27. Çeyrek hedefi yokken: "Bu çeyrek: hedef yok".
28. Kart bilinen hatalarla çıkınca sürüm notu yazar: "{kart} bilinen {n} hatayla çıktı" tonunda; bilerek yayınlandı, sürümü durduran hata değil.

## Çalışma
29. Teknik sorular: Erdem anlamadı, yeniden soruldu.
30. Metinler: araştırma ve tasarım bittikten sonra tek metin turu; bugünkü metinler büyük ölçüde kabul. Yeni olay yazımı yok; araştırma sonrası yazılmış kartlar küçük modifier değişiklikleriyle kullanılabiliyorsa kullanılır, kullanılamıyorsa Erdem'e bildirilir.

## Kod sırası (aynı ağaçta aynı anda tek yazan)
1. Q (şimdi, kısa): 2012 düzeltmesi, 18–22, 24 (outsource kaldırma).
2. C (Q "bitti" deyince): beklentiye bağlı OLMAYAN adımlar C1 (sunucu), C2 (giderler), C4 (kurumsal madde), C7 (destek raporu), C9 (ev/ofis) bu kararlarla. C3a, C3b, C5, C6, C8 beklenti tasarımını bekler.
3. D: kod yok; atama/verim araştırması (Godot'suz).

## Beklenti araştırması sonucu (2026-10-20)
- Tasarım "Pazar merdiveni": sayfa https://claude.ai/artifact/1BH7xv4xkAFVnsvYcJGkS3, ham belge yardımcı yönetmenin scratchpad'inde `beklenti/SENTEZ_BEKLENTI.md` (+ R1–R6, T1, T2).
- Erdem'e K1–K9 soruldu (cevap bekleniyor); H1–H14 itiraz edilirse değişir.
- Q'nun §9 soru 1 (2★ Çekirdek), satışçı hiç kaybetmiyor, derinlik kartı açmazı bu tasarımla konusuz.

## Pazar merdiveni K1–K9 cevapları (Erdem 2026-10-20) — tasarım reddedildi, derin araştırma
- Genel: araştırmalar sığ kaldı (yalnız oyun mekaniği); gerçek ERP pazarı önce araştırılır, sorular araştırmadan SONRA gelir.
- K1: beklenti metrik olarak gösterilmez (çirkin). Müşteri ilişki iyi, ürün düzenli gelişiyor, istekler karşılanıyorsa beklentinin görünür büyümesine gerek yok; büyüyen müşteri zaman zaman yeni şey ister.
- K2: kopyalama mekaniği YOK. Rakipler bizim gibi şirket: aynı kart listesi / Ar-Ge ağacını kendi büyüklüğü ve çalışan dağılımıyla yürütür; dev yüksek başlar, aynı yol haritası, geçmek uzun sürer; fark hız, verim, satış, destek ve Ar-Ge'de öne geçmekle (ör. YZ döneminde ilk atılım). Oyuncuya liderlik/kopyalanma bilgisi verilir mi: ayrı soru, araştırılır.
- Sektörler: ya yalnız ad kalır ya modüllerle anlam kazanır (sağlık firması lojistik modülü almaz); satış görüşmesinde müşteri modülleri ve koltuk sayısını söyler, oyuncu teklif verir. Araştırılır.
- K3: koltuk artışı beklentiyi artırmaz; koltuk müşterinin büyüklüğüne ve memnuniyetine bağlı artar ya da artmaz; her müşteri büyümez; 1★ sürekli koltuk almaz. Beklenti yenilemede şart ("rakiplerde olan şu alanınız zayıf, yenilerken istiyoruz") ya da yıl ortası istek olarak gelir.
- K4: tavan çok uzak; SAP gibi yıllar süren geliştirme; Ar-Ge ve yıla bağlı kilitler (YZ dönemi vb.); oyunun bitiş yılı var (ör. 2030); erken yılda tavana varılamaz, 2020'de o dönemin tavanı.
- K5: takvim sıkışmaz; hafta süresi sonra kalibre (1×'te 40–50 sn olabilir), şimdi dokunulmaz.
- K6: rakip sürümleri ERP'de sektör standardı oluşturur; büyük hesap özellikli ürüne yönelir; ürün standarda göre okunur: mevcut müşteri "standardın çok altındaki şunu getirin yoksa gideriz", yeni müşteri "bu modül bizim için önemli, sizde istediğimiz seviyede değil". Standardın büyümesi ve gösterimi araştırılır.
- K7: geliştirilmeyen ürünün görünür cezası olmalı (edge-case deneyen oyuncu, "geliştirmesem de olur" yorumu istenmez); hata mı yeni özellik mi, tasarlanır.
- K8: %60 tabanı kalkar. Satışçı yıldızının etkisi araştırılır (hesap büyüklüğüne oranla kapanış ihtimali, süre, başka neler). → C
- K9: yıldız koltukla uyumlu (KOBİ 3–10, dev 100–1.000); yenilemede değişebilir; her yenilemede koltuk değişmez.
- Yıldız ölçeği: **5 yıldıza çıkar** (bugün 1–3).
- Araştırma YENİ oturumda (200 arama): görev `pazar2/BRIEF.md`, iş akışı `pazar2/pazar2.js`, çıktı `pazar2/out/`.

## C9 cevapları (Erdem, C oturumunda verdi; C bildirdi 2026-10-20)
- Ofise taşınmanın getirisi: yalnız itibar sıçraması; taşınınca marka bir kez yükselir (örnek İş hanı +3, Plaza +6, Loft +10). "Mesai az yorar" ve "kalabalık kaybı" seçilmedi.
- Masa tavanı: evde sınırsız, ofiste masa kadar. Masadan büyük ekiple taşınan oyuncu, masa boşalana ya da büyük ofise geçene kadar işe alamaz.
- Runway yalnız eksideyken görünür; gider yokken ve kârdayken satır çıkmaz. (Önceki karar 7'nin araştırma maddesi böylece kapandı.)
- Kredi: sonra, ayrı tasarım.
- C'nin kendi kararları: her ofis kademesi markayı koşuda bir kez verir, aşağı taşınınca geri alınmaz; "uzaktan çalışmanın bedeli" ve kredi ISLER'e açık iş. Oynanış uyarısı (C → Erdem): uzaktan bedel gelene kadar evde kalmak baskın strateji.
- C'nin sırası: C2 → C1 → C4 → C7 → C9a → C9b → 3B; Q "bitti" demeden başlamaz.

## C2 ekonomi ölçümü (C bildirdi, 2026-10-20; ayrıntı c_taslak/msim/out/c0s_econ_e1.md)
- Evde kirasız: ilk işe alımda runway 9 ay ✅; ilk 40 hafta en derin açık evde 23 bin (bandın biraz altı), seed'de taşınırsa 41 bin ✅.
- ⚠️ Araç ve servis gideri silinince orta ve geç oyun belirgin rahatlıyor: evre 3'te ayda ~40–53 bin gider kalkıyor, evre 2'de kasa hiç 4 ayın altına inmiyor, evre 3 neti bugünün 2–5 katı. CLAUDE.md §1 "kasa artıyor, karar kalmadı" kuralına risk.
- ⚠️ Masa tavanıyla seed'de İş hanı'na taşınan bot hf 52'de masayı dolduruyor, Plaza'ya hf 82'de varıyor: ~30 hafta işe alım kapalı. Evde kalmak daha da baskın.
- Yardımcı yönetmen: ikisi de gelir modeline (Pazar 2: modül × koltuk teklifi, 5★) bağlı; Pazar 2 sentezinden sonra gelir + gider birlikte ele alınacak. C sabit değiştirmiyor; E2'de gerçek koşuyla Erdem'e gidecek.

## 1–23 cevapları (Erdem 2026-10-20 gece)
Genel (bağlayıcı, her ajan):
- Soru ancak araştırmanın ne bulduğu ve sorunun nereden çıktığı bir iki cümleyle özetlendikten sonra sorulur. Seçenekleri neye göre değiştiğini göstermeyen soru sorulmaz ("5 mi 7 mi 10 mu" gibi).
- Görsel tutarlılık (büyük harf, tire, hiyerarşi) ve göç SORULMAZ, yapılır. Her değişiklik bütün göçüyle gelir.
- Bir şey değişince arkada kalan eski kod, belge, açık karar silinir; ölü şey bırakılmaz (klasördeki eski belgeler ajanları şaşırtıyor, token yakıyor).
- Boşta ajan istenmiyor; işler bitsin, sonra düzgün bir playtest. Çalışma düzeni ve bir kod denetimi (audit review) işler bitince ayrıca ele alınacak.
Pazar 2:
1. Sektör: B modül profili; iyi kurgulanmalı ve iyi araştırılmalı.
2. Modül sayısı: CEVAPSIZ. Erdem: "neye göre 5/7/10, bana bir şey sunmadan soruyorsunuz." → Pazar 2 her sayının neyi değiştirdiğini gösterir.
3. Bitiş yılı 2030 ya da 2035.
4. Önde olan: yıllık bir sıralama/rapor fikri: ürün çıkınca medyadan puan, yılın ürünü ödülü gibi; ya da sektör dergisinin listesi ("en çok kullanıcısı olan ERP", küresel). Pazar 2 bu fikirle tasarlar.
5. İstek yalnız 3★ ve üstü; 4–5★ 3★'tan daha sık. Demoda 5★'a erişim çok zor olmalı (playtest'te bakılacak).
6. Koltuk bantları A: 3–10 / 10–30 / 30–100 / 100–300 / 300–1.000.
7. Satışçı en çok bir yıldız üstüne gidebilir, şansı düşer.
8. Modül fiyatı olsun; ama asıl soru: oyuncu fiyatı neye göre belirler, kodda ne kadar kolay. → araştırılır.
9. Dev geç oyunda geçilebilir (oyunun amacı); erken oyunda geçmek çok zor, hatta imkânsız.
10. Anlaşılmadı ("bilinen yol" indirimi) → açıklamayla yeniden gelir.
11. Ayrı ceza yok: ürün eskir, memnuniyet ve ilgi düşer; o yeter. ("2018'den sonra" ayrımı anlamsız bulundu.)
Q:
12. A: sprint gecikmesi yeter. Kart müşteri sözüne bağlıysa gecikme müşteriyi etkiler (söz olayı zaten var). "Çizildiği gibi yap" metni yanlış: "Tasarlandığı gibi yap" / "Konuştuğumuz gibi yap" tonunda yeniden yazılır.
13. A: dışarıdan hizmetin her biçimi kalkar (testçi kâğıdı, lisans kâğıdı, kartlardaki dışarıdan uzman giderleri); suistimal edilebilir.
14. Tire kalkar (hiçbir yerde tire yok). "Ve daha fazlası" etiketi anlaşılmadı; bariz şeyin altına açıklama/disclaimer istenmez → Q nerede çıktığını gösterir, gereksizse kaldırır.
15. Evet; bu tür soru sorulmaz, düzeltilir.
16. Göç yazılır.
17. Ajanlar seçer → yardımcı yönetmen: A (böyle kalsın, ek iş yok).
D:
18. Erdem sordu: araştırıldı mı? → özetle yeniden soruldu.
19. İlke: karmaşık / yüksek gereksinimli işe en iyiler, basit ve hata riski düşük işe zayıflar. Hata, işin karmaşıklığıyla ölçeklenmeli: 3 sprintlik işte en çok 100 hata çıkabiliyorsa 3★ 20, 5★ 10 hata üretir; en çok 5 hata çıkabilecek basit işte 1★ ile 5★ arasında fark küçüktür. → D hata modelini buna göre kurar ve yeniden ölçer.
20. B: söz kartı öne geçmez; risk darboğaz satırında.
21. Aynı ilke PM için: en karmaşık iş en iyi PM'e, en basit kart en zayıf PM'e. (B'yi de fena bulmadı.) → D ilkeyi uygular, ölçümle getirir.
22. B, ama metin "3 sprinttir" değil; "bu sorun N sprinttir sürüyor" tonunda.
23. ACIK_KARARLAR 102 silinir.
18. A: atamayı sistem yapar, Erdem'in tarif ettiği kuralla (karmaşık işe en iyiler, basit işe zayıflar; hata karmaşıklıkla ölçeklenir); elle atama yok. (2026-10-21)
- K13 belge temizliği izni: Erdem Q'nun penceresinde kendisi veriyor.
- 14 "Ve daha fazlası": yardımcı yönetmenin kararı: en etkili 4 etken kalır, katlanan satır "+N etken daha" yazar, ipucu kalanları sıralar (TR/EN onay bekliyor).
- Q K13 bitti (c6160c89): ACIK_KARARLAR ve ISLER temizlendi, 16 madde silindi, ~50 madde bugünkü koda göre yeniden yazıldı.
- Yardımcı yönetmen kararı (Erdem'in "ölü şey silinir" kuralı + Karar 30): ACIK 99 silinir (belirti C'nin E2'sinde ölçülür); Frank'in okuyucusuz 17 CSV satırı + 89'daki 2 anahtar + PROD_DESIGN_DECISION_BODY silinir; "TR/EN onay bekliyor" metin maddeleri kabul sayılıp silinir; ISLER C-07, INT-9, hata trendi zinciri ve C-13 silinir; okuyucusuz CSV anahtarları süpürülür. Erdem itiraz ederse revert.
- D'nin iki sorusu (24 toplam hata ölçeği, 25 kartın sırası) Erdem'e soruldu.
- Pazar 2 tur 2 Erdem'in isteğiyle (haftalık limit) DURDURULDU (2026-10-21). Bitenler `pazar2/out/tur2/`: 8 araştırma kolu (M modül sayısı, F1/F2 fiyat, S1/S2 sıralama, Y bitiş yılı, B bilinen yol, P sektör profili), K2 kod/içerik, V2 doğrulama, SIM_RAPOR_1 (G1 ❌ dev 2015'te hatlarının çoğunda tavanda; iki parçalı efor N=10'da düzeltiyor · G5 ❌ açık istek kartı sprint başına 8-10, şartlı yenileme güçlü botlarda ~%0 · G8 ✅). Yarım: sim 2. tur (rapor yok), SORU_PAKETI_2 yazılmadı. O oturumun aramaları 181/200. Devam: limit yenilenince yeni oturumda sentez + SORU_PAKETI_2.

## 24–31 cevapları (Erdem 2026-10-21)
24. Hata modeli: ilkenin biçimi kalır (büyük işte hata ihtimali yüksek, ekip kalitesi belirler). Hatanın iki katına çıkması Erdem'e göre sorun değil; sayı kalibrasyon işi, kartlar zaten baştan elden geçecek. Kararı yardımcı yönetmene bıraktı → yardımcı yönetmen: biçim Erdem'in sayılarıyla (K-E), ölçek c [WORKING]; kart sistemi yeniden yazılana kadar toplam hacim bugünkü (K-H, c 0,212) kalır ki playtest'in ekonomisi ve hata sınırları bozulmasın; kartlar yenilenince c kalibre edilir.
25. Atama proaktif ve reaktif olmalı: "iki kişi büyük işte, biri birinde, bir kart boşta, iş bitmiyor" saçmalığı olmamalı. Örnek: 3 geliştirici, 3 kart; büyük kart 2 kişiyle 2 sprintte biter, iki küçük kartı 1 kişi haftada birer bitirir → sistem bunu kendisi kurar. MVP gecikmesinin nedeni büyük olasılıkla bu proaktiflik eksikliği → D yeniden değerlendirir (sprint düzeyinde ileriye bakan plan, kart bitince yeniden dağıtım).
26. 10 modül. Sektörler 10 modülle anlam kazanır; oyuncu hedef sektör seçebilir, sektörlerin müşteri tiplerinin artı ve eksileri olabilir (sonraki konu). ERP ve e-ticaret ileride ayrıntılandırılacak.
27. Evet: kademeler dönemle açılır; ilk kademeler biraz artırılır. Ar-Ge ağacı geliştirme tavanını sürekli yükseltir; dönem geçişleriyle Ar-Ge'ye yeni şeyler gelir (ör. YZ furyası; araştırması yapılınca ek ürün geliştirme tavanı). 2-3 yılda bütün ERP'nin bitmesi oyunu öldürüyor.
28. Bitiş 2030 (içerik geliştikçe süre artabilir ya da azalabilir; demo 2030'u görmez).
29. B: yıllık rapor (en büyükler ve en hızlı büyüyenler; bir derginin ya da vakfın yıllık listesi) + modül bazında ödül/değerlendirme (B2B'de "en iyi şu modül"). Sıklık sorusu: yardımcı yönetmen → yıllık, raporla aynı anda. B2C'de modül ödülü yok; yalnız en büyük ve en hızlı büyüyen platformlar.
30. Fiyat: oyuncuyu yormaz, angarya olmaz. Ucuz / standart / pahalı üç seçenek, her birinin önerilen fiyatı var; oyuncu birini seçer, teklif gider. Koltuk başı fiyat; anlaşma = koltuk × fiyat. Önerilen fiyat müşterinin istediği modüllerden ve o modüllerin kalitesinden hesaplanır (dandik modül ucuzlatır, iyi modül pahalandırır). 5★'ın yüksek geliri sorun değil (5★ bağlamak zaten çok zor). Hesaplamanın nasıl olacağı araştırılır; daha iyi öneriye açık.
31. Bilinen yol: güzel fikir ama uygulaması zor → şimdilik yok.
- Pazar 2: cevaplara göre hızlı mini araştırma (eksikleri kapat) + sentez; sim 2. turun yorumu; sentezdeki "940 hafta" ve e-Fatura hatalarının düzeltilmesi.

## Yardımcı yönetmenin kararları (2026-10-22, Erdem'in "nasıl ilerlememiz gerekiyorsa ilerleyelim" sözü ve genel kurallarıyla)

- C2c: kâr hâlindeki `funding.monthly_update`'in başlığı ve şıkları da değişir (genel kural: dokunulan her yer düzeltilir). Metin TR/EN onayı metin turunda.
- C7b: destek raporunda önceki en kötü hattın düzeltilmesiyle olan değişim yeni rapor sayılmaz (PRD: rapor yalnız yeni bir şey olunca); önce/sonra raporlu hafta sayısı ölçülür, hâlâ haftaların yarısından fazlaysa "en az 2 hata farkla öne geçme" eşiği de eklenir.
- C'nin kalan adımları (C3a, C3b, C5, C6, C8) `pazar2/out/SENTEZ_ERP_PAZARI.md` §14.2'ye göre yeniden planlanır (`c_taslak/PLAN_C_P2.md`); ayrı PRD yazılmaz.
- Şema numarası: ilk inen adım sıradaki numarayı alır (göç zinciri `version < N`).
- D: PM seçimi Erdem'in kuralıyla (A); "zor işe en iyiler" Test'te de işler; ileri oynatma beklenen hatayla; tek alım sınaması; plan süresi tıklamada ve sprint başı gecede ≤ 100 ms (aşarsa önce karelere bölünür); D0s2 ve D0p ölçüm turları düşer (ölçüm turu yok kuralı); devret önerisi düşer; c oyunun bugünkü hata hacmine kalibre edilir (Karar 24'ün gerekçesi); A4 tasarımcı kararları [WORKING] girer ve M2 görsel sayfasında Erdem'e sorulur.
- Erdem'de bekleyen: Q'nun K20 kapı yolu, İş hanı 12. masa karesi, Frank'in ofis kartı metni, Pazar 2'nin 10 kapanış simülasyonu, D'nin C ile paralel kod yazması, eşikli gönder kipi ayarı (M2 sayfasında).
- C, PLAN_C_P2 (20 adım, ~71 ajan saati): C0p ve W2 başlar; kod adımları Erdem'in iki şerit "evet"i ve Q K20 commit'inden sonra. Kapsam C'de: 10 modül, profiller, 5 yıldız, rakip şirketler, havuz, dönem tavanı, yıllık rapor. §8 madde 13 açık: görüşmedeki cetvel, sabır ve karşı teklif B2B pazarlık PRD'sine kadar silinmez, C3b-4'ün görüşme akışı zincirin sonunda. Madde 8: Risk geri sayımı ve Oyala sentezle silinir (Erdem'e bilgi). Madde 22: C0v önerileri [WORKING], "onay bekliyor". C3a-2 ile C3b-2 arası tek parça, arada push yok.

## Erdem'in cevapları ve yön düzeltmesi (2026-10-22 öğleden sonra)

- **Yön:** Yalnız tam tanımlı (ne ve nasıl net) işler ajanlara gider. Bir sistem değişikliğinde netleşmeyen her şey park edilir ve listelenir; o sistemin PRD'si ayrıntılı yazılır, sonra kod. Sentez PRD yerine geçmez. Yukarıdaki "C, PLAN_C_P2" maddesindeki onaylar ve C'nin §8 varsayılanları GERİ ALINDI; C3a-1 … C12 park. D'nin A4 kararları [WORKING] girmez, park ve M2 sayfasıyla Erdem'e.
- **B2B fiyat/pazarlık (Erdem'in kastı):** premium fiyatın dolar cinsinden önerilen bir fiyatı olur, pazarlık bunun üzerinden döner. Ayrıntısı satış ve pazarlık PRD'sinde.
- Q: çalışma klasöründe kapı koşabilir; Q bitmeli.
- İş hanı: üçüncü küme öbür kümeler gibi dört koltuklu (öbür kümeler kopyalanır). Masa sayısı 12/13 sorusu Erdem'de.
- Frank'in ofis kartı: onay, son cümle ("Kirayı iki ay peşin isterler, imzadan önce kasana bak.") kalkar; metin "…şirkete düzgün bir ofis bul." ile biter. Kart demoya açılır.
- Pazar 2: 10 kapanış simülasyonu koşabilir.
- D: C'yi beklemeden, çakışmıyorsa paralel kod yazabilir (yalnız tam tanımlı adımlar).
