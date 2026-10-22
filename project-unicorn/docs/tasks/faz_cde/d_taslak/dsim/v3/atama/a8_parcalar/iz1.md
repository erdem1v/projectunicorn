**Kurulum** (Erdem'in 25. maddesi, sayılar benim seçimim). 3 geliştirici: A 4 yıldız (Yazılım 15,4 puan/hf), B ve C 3 yıldız (11,6 puan/hf); üçü de her kartın gereksinimini karşılıyor, üçü de testi yan işte (0,7 hızla) yapabiliyor. Sprintte 3 kart, plan sırasıyla:

- **Büyük**: 100 puanlık Yazılım işi, gereksinim 2 yıldız. İki kişiyle (A ve bir 3 yıldızlı: 27 puan/hf) 3,7 hafta sürer, yani 2 sprinte sığar; üç kişiyle bile 2,6 hafta sürer, yani ilk sprintte bitmesi mümkün değildir.
- **Küçük 1** ve **Küçük 2**: 10 puanlık Yazılım işi, gereksinim 1 yıldız. Bir 3 yıldızlı kişi her birini 0,86 haftada bitirir.
- Her kartın Test işi 0,5 puan, Tasarım işi yok. Hata zarı kapalı (örnek yalnız atamayı gösteriyor). 4 hafta (2 sprint) oynatıldı. Büyük kart plan sırasında ilk (kötü durum: ilk kart herkesi toplayabilir).

Tablo hücresi: o haftada kişinin kart (aşama) başına harcadığı hafta kesri; "boşta" iş bulunamayan süre (4. haftadaki boşluklar örnekte başka kart kalmadığı içindir). Son satırdaki "P, satır seçimi eski kuralla" tanı koludur (§4.3).

{{dosya:out8/iz1.txt}}

**Okuma.**

- **R, Tarif ve T_plan aynı şeyi yapıyor ve Erdem'in anlattığı şey bu.** İlk iki hafta üç kişi de büyük kartın Yazılımında; küçük kartlar h2,59'a kadar başlamıyor, üçü de ikinci sprintte bitiyor (büyük h3,03, küçük 1 h3,10, küçük 2 h3,23). Neden: R'de plan sırasının başındaki kart kadro tavanını (13 kişi) doldurur; Tarif ve T_plan'da en önde duran kart "tavan kadar en iyi kişi"yi alır. Kadro tavanı ekibin üç kişisinden büyük olduğu için kimse artmaz, küçük kartlar boşa çıkar. "Kalır" yüzünden Tarif ve T_plan'da kimse yarıda çıkıp küçük karta da geçemez.
- **P ikisini ayırıyor.** Büyük kartın ufku ikinci sprintin sonu (üç kişi bile ilk sprintte bitiremez); bu ufku tutturmak için A ve C yetiyor (27 puan/hf, 3,7 hafta). Üçüncü kişi B kalan kartlara gidiyor: küçük 1'in Yazılımı (h0,00-0,86), küçük 2'nin Yazılımı (h0,86-1,72), sonra ikisinin testi (h1,72-1,87); B küçük 2'ye hafta sonunu beklemeden, küçük 1 biter bitmez geçiyor (reaktif katman). Küçük kartlar **ilk sprintte** bitiyor (h1,80 ve h1,87), büyük kart ikinci sprintte (h3,21). Erdem'in beklediği desenle aynı: ikisi büyük kartta, biri küçük 1 sonra küçük 2.
- **İlke.** Büyük kartın karmaşıklığı (100 puan × 2 yıldız) küçüklerinkinden (10 × 1) büyük; en iyi kişi A büyük kartta. Küçük kartlar 3 yıldızlı kişiye gidiyor.
- **Bedel yok denecek kadar küçük, ama var.** Büyük kart P'de 0,18 hafta geç bitiyor (h3,21; ötekilerde h3,03), çünkü B büyük karta h1,87'den önce girmiyor. Üç kartın hepsinin bittiği an hemen hemen aynı (h3,21 ve h3,23): toplam iş ve kişi-hafta aynı, yalnız sıra değişiyor; kazanç iki küçük kartın bir sprint erken (ilk sprintte) teslim edilmesi.
- **Satır seçimi neden gerekli.** P'nin satır seçimini eski kurala (plan sırasındaki en önde açık satır) çevirince (tablonun son kolu) B küçük kartlara aynı şekilde gidiyor ama bitirdiği kartların testini yapmıyor, büyük kartın yazılımına yardıma gidiyor; küçük kartlar h3,18'de, ikinci sprintte bitiyor. Küçük kartı yazılımı bitmiş ama testi bekleyen "iş bitmiyor" durumu budur.
- **Büyük kart planda sonda olursa** (iz 1b: küçük 1, küçük 2, büyük) R'nin küçük kartlarının yazılımı ilk haftada biter ama testleri büyük kartın yazılımı bitene kadar yapılmaz (küçükler h3,18, büyük h3,16); Tarif'te küçükler h3,03 ve h3,23'te. P'de küçük kartlar h0,93 ve h1,00'de, büyük kart h3,21'de bitiyor.

**İz 1b: aynı kartlar, büyük kart planda sonda.**

(A9 incelemesi: ilk sürümde P'nin bu tablosu, ileri oynatmada denenen ama seçilmeyen yerleşimlerin atamalarını da gerçek izin arasına yazıyordu; `a8iz.py` düzeltildi, tablo yeniden üretildi. Bitiş saatleri değişmedi.)

{{dosya:out8/iz1b.txt}}
