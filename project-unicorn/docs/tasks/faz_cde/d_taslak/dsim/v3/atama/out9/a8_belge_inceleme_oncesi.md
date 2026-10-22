# A8 · Proaktif ve reaktif sprint planlayıcısı

21 Ekim 2026 · Faz D, adım A8 · Godot koşturulmadı; oyun koduna, `strings.csv`'ye, `data/`'ya, `project.godot`'a dokunulmadı; git'te durum değişmedi. Yeni kod yalnız `d_taslak/dsim/v3/atama/` altında (`a8plan.py` planlayıcı, `a8run.py`, `a8tab.py`, `a8test.py`, `a8iz.py`, `a8rapor.py`); `dsim3.py`, `a3core.py` ve `hata2.py` değişmedi. Bu işin ilk adımı olarak `A6_HATA_MODELI.md`'nin sonuna "Karar (2026-10-21)" bölümü eklendi (Erdem'in 24. kararı ve yardımcı yönetmenin hacim kararı: biçim K-E, ölçek `c` [WORKING], kartlar yenilenene kadar K-H, `c` = 0,212); bu belgenin bütün ölçümleri K-H ile koşar.
Girdiler: `ERDEM_KARARLAR_2026-10-20.md` "24–31 cevapları" madde 25 (atama proaktif ve reaktif olmalı) ve önceki 18-21; `A3_OLCUM.md`, `A4_TASARIM.md`, `A6_HATA_MODELI.md`. Sayıların hepsi koşulardan gelir; ham sonuçlar `atama/out8/`'de. R, Tarif ve T_plan kolları A6'nın kayıtlarından (`out6/ana/H`) okunur; bu kodla yeniden koşulunca aynı sonucu verdikleri `a8test.py regress` ile doğrulandı (§6).

**Okuma anahtarı.** *P* = bu belgenin planlayıcısı. *R* = bugünkü kural (D0s'un önerdiği okuma). *Tarif* = Erdem'in atama tarifi (A6'daki T: en yüksek gereksinimli karta en iyiler, "kalır", PM'de en basit kart en zayıf PM, hata modeli K-H). *T_plan* = A6'nın tanı kolu (tarifin yalnız 1. adımında "en önde duran kart" gereksinim yerine plan sırasıyla seçilir; öneri değil, nedeni ayırmak içindi). *Plan sırası* = sprint planındaki kart sırası (devreden, söz, düzeltme, yeni kartlar). *Gereksinim* = kartın istediği yıldız. *Kalır* = kişi kartın aşamasına girince aşama bitene kadar orada kalır. *Oynatma* = motorun bir sprinti (ya da kalan kısmını) baştan sona bir kez hesaplaması. Ölçütler: *MVP haftası* üç MVP kartının da teslim edildiği ilk sprintin bittiği hafta (en erken 2); *açık hata* sprint sonlarında canlı üründe duran hatanın medyanı; *kaçan söz* vadesi gelen söz kartlarından vadeyi kaçıranların payı (yalnız kaynaklı arz); *boşta* iş bulamayan insan zamanının payı, iki sayı: **PM hariç / PM dahil** (PM'in boş zamanı hazırlığa gider; kartta çalışmayan PM zamanı ikinci sayıda boşta görünür, 1 ve 3 kişide PM yok, tek sayı); *teslim* haftada teslim edilen kart puanı; *doğan hata* pencerede kartlarda ortaya çıkan toplam hata. *Eşli fark* = aynı 20 tohumda iki kolun farkının ortalaması ± ortalamanın standart hatası, parantezde "farkın eksi çıktığı tohum / 20". Tablolarda ondalık nokta kullanılır (A3 ve A6 gibi). `[GÖRÜŞ]` benim yargım, `[DEĞERLENDİREMEM]` veri yok.

## 0. Erdem için: oyuncunun ekranında ne oluyor

Kısa sürüm: P'yi (yeni planlayıcı) bugünkü kural R'nin ve Erdem'in tarifinin yanında 20 tohumla ölçtüm. Tablolar §1'de, adım adım iki örnek §2 ve §3'te.

1. **Sprint, başında baştan sona kuruluyor.** Oyuncu sprint ekranında "+" ile kart ekledikçe sistem sprintin iki haftasını bir kez baştan sona oynatır; kimin hangi hafta hangi kartın hangi aşamasında çalışacağını, hangi kartın ne zaman biteceğini kendisi yerleştirir. Ekrandaki tahmin ile sprintin gerçek akışı aynı kodla hesaplanır: P'nin 12 hücre × 20 tohum koşusunun hepsinde tahmin farkı 1e-6'nın altında (en büyük 7,1e-15), ve her hafta başı plan seçimi tahmin oynatmasından geldiği gibi gerçek oynatmada kullanıldı (§6).
2. **Büyük kart herkesi toplamıyor; Erdem'in örneğini sistem kendisi kuruyor (§2).** 3 geliştirici (4, 3, 3 yıldız), plan sırasında önde bir büyük kart (iki kişiyle iki sprint) ve iki küçük kart (bir kişiyle haftadan kısa). P iki kişiyi büyük karta koyuyor; üçüncü kişi önce küçük kart 1'i, o bitince küçük kart 2'yi, sonra ikisinin testini yapıyor. Küçük kartlar ilk sprintte bitiyor (h1,80 ve h1,87), büyük kart ikinci sprintte (h3,21). R, Tarif ve T_plan üçü de üç kişiyi büyük karta yığıyor; küçük kartlar h2,6'ya kadar başlamıyor ve üçü de ikinci sprintte bitiyor (büyük h3,03, küçükler h3,10 ve h3,23). Büyük kart P'de 0,18 hafta geç bitiyor; karşılığında iki küçük kart bir sprint erken teslim oluyor.
3. **MVP gecikmesi "ileriye bakmama"dan değil, tarifin ilk adımının sırasından geliyor.** 3 kişide MVP Tarif'te ortalama 6,4. haftada (20 tohumun 20'sinde R'den geç), R'de 4,0. Kartları plan sırasıyla seçen T_plan'da 4,0, P'de 4,0, ileri oynatması kapalı P'de 4,0: kaymayı kapatan şey "en zor kart önce" sırasını "plan sırası"na çevirmek. İleriye bakma 3 kişide bir şey eklemiyor (§3). 6 kişide ise ekliyor: MVP R'de 4,0, Tarif'te 5,1, P'de 2,2 (ileri oynatmasız P'de 4,0). Kaynaklı arzda 6 kişide R 2,4, P 2,2.
4. **Açık hata ve kaçan söz R'den kötü değil, Tarif'ten belirgin iyi.** Kaynaklı arz, 3 kişi: açık hata P 10,9, R 14,5, Tarif 32,4; eşli fark P−R -3,6 ± 0,5 (19/20). Kaçan söz 3 kişide P 18,1%, R 17,7%, Tarif 27,2%; 6 kişide P 1,3%, R 1,1%, Tarif 6,1%. 25 ve 50 kişide P'nin açık hatası R'den biraz fazla (sınırsız arz +0,5 ve +0,7), Tarif'ten az.
5. **Kimse boşta kalmıyor, ama bir bedel var: gereksinim kapısı teslimi düşürüyor.** PM hariç boşta payı R ile aynı düzeyde (eşli fark 12 kişide 0,3 pp ± 0,0 pp (0/20); kaynaklı 3 kişide P daha az boşta: -3,7 pp ± 0,6 pp (19/20)). Teslim P−R: 12 kişide -1,8, 25 kişide -2,8, 50 kişide -0,7 puan/hf (kaynaklı 50 kişide +2,3). Bu kaybın nedeni "gereksinimin altındaki kişi o karta girmez" ilkesi: aynı planlayıcıda kapı kaldırılınca P, R'nin 12 ve 25 kişide +1,4 ve +2,0 üstüne çıkıyor (§4.4). Tarif'e göre 50 kişide P +9,3 puan/hf (kaynaklı: +33,2) önde.
6. **İlke uygulanıyor.** Gereksinimin altındaki kişiye düşen Yazılım işi P'de sıfır (R'de 6 kişide 7,7%, 12 kişide 3,6%). Doğan hata P−R: 12 / 25 / 50 kişide -4,5 / -9,3 / -26,4 (R'ye göre %3-5 az). Karmaşık işe iyi kişi gitmesi doğrudan ölçüldü (§4.5): karmaşıklık ile ekibin ortalama yıldızı arasındaki korelasyon R'de sıfıra yakın (en çok 0,19), P'de 0,15-0,50. Ama "karmaşık kart daha iyi kişilere" yer değişimi adımı tek başına ölçülebilir ek kazanç vermiyor (§4.3); kazanç büyük ölçüde gereksinim kapısından ve "en az kişilik ekip" boyutlamasından geliyor [GÖRÜŞ]; kartların karmaşıklık farkı küçük (A6 §5).
7. **Reaktif: biri plandan yavaşsa plan o an yeniden kurulur.** Bir aşama bitince boşalan kişi hemen sıradaki uygun karta geçer (iz 1'de B, küçük kart 1'in yazılımı biter bitmez küçük kart 2'ye geçiyor; hafta başını beklemiyor). Plan oynatmasına göre bir kişinin hızı %40 düşerse o haftanın seçimi önbellekten gelmez, planlayıcı gerçek hızla yeniden kurar (§6, tepki testi).
8. **Maliyet ve hafif kip.** Sprint başına yaklaşık 18 oynatma (hafta başı iki seçim, her biri 8 seçenek ve bir yer değişimi karşılaştırması). Bu makinede, Python'da, 50 kişide sprint planı 0,53 sn (kaynaklı arzda 0,57 sn); tek oynatma yaklaşık 30 ms. İleri oynatmasız hafif kip (tek seçenek, tek oynatma) var; bedeli 6 kişide MVP'nin 4,0. haftada kalması, kaynaklı 6 kişide kaçan sözün 6,3% olması (tam P'de 1,3%), kaynaklı 50 kişide tam P'nin hafif kipten +8,8 puan/hf fazla teslim etmesi (§4.3).

## 1. Tek tablo

20 tohumun ortalaması, hata modeli K-H. Ekip büyüklüğü 1, 3, 6, 12, 25, 50 kişi. "Tarif" sütunları A6'nın T kolu. Boşta sütununda iki sayı varsa ilki PM hariç, ikincisi PM dahil.

**Kaynaklı arz** (80 hafta, pencere 21-80; söz kartları açık)

| Ekip | P MVP | P açık | P söz | P boşta | P teslim | R MVP | R açık | R söz | R boşta | R teslim | Tarif MVP | Tarif açık | Tarif söz | Tarif boşta | Tarif teslim |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 8.5 | 8.8 | 79.0% | 8.1% | 5.6 | 8.5 | 8.7 | 79.6% | 8.0% | 5.6 | 8.5 | 7.9 | 81.8% | 8.7% | 5.7 |
| 3 | 4.0 | 10.9 | 18.1% | 13.7% | 21.2 | 4.0 | 14.5 | 17.7% | 17.4% | 19.7 | 4.4 | 32.4 | 27.2% | 17.0% | 21.4 |
| 6 | 2.2 | 7.7 | 1.3% | 2.4% / 13.6% | 47.9 | 2.4 | 8.8 | 1.1% | 2.2% / 13.6% | 47.6 | 4.9 | 8.8 | 6.1% | 1.2% / 12.8% | 48.2 |
| 12 | 2.1 | 7.3 | 0.2% | 1.9% / 13.1% | 100.0 | 2.3 | 8.4 | 0.0% | 0.9% / 12.2% | 101.5 | 4.0 | 11.2 | 2.8% | 1.8% / 13.0% | 99.2 |
| 25 | 2.0 | 8.3 | 0.0% | 2.6% / 8.5% | 238.5 | 2.0 | 8.2 | 0.0% | 1.6% / 7.9% | 243.5 | 2.1 | 13.0 | 1.3% | 3.0% / 8.9% | 236.2 |
| 50 | 2.0 | 11.2 | 0.0% | 7.9% / 16.4% | 431.2 | 2.0 | 10.9 | 0.0% | 7.5% / 16.8% | 428.9 | 2.0 | 14.0 | 0.4% | 12.1% / 21.4% | 398.0 |

**Sınırsız arz** (60 hafta, pencere 21-60; söz kartı yok)

| Ekip | P MVP | P açık | P boşta | P teslim | R MVP | R açık | R boşta | R teslim | Tarif MVP | Tarif açık | Tarif boşta | Tarif teslim |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 6.3 | 6.0 | 24.8% | 4.5 | 6.3 | 6.0 | 24.8% | 4.5 | 6.3 | 6.0 | 24.8% | 4.5 |
| 3 | 4.0 | 8.2 | 17.4% | 20.5 | 4.0 | 8.3 | 17.2% | 20.7 | 6.4 | 10.1 | 18.9% | 20.8 |
| 6 | 2.2 | 8.2 | 3.5% / 12.1% | 49.5 | 4.0 | 8.3 | 3.0% / 11.7% | 49.0 | 5.1 | 9.4 | 2.4% / 11.0% | 50.5 |
| 12 | 2.1 | 9.3 | 0.4% / 8.5% | 107.2 | 2.2 | 9.6 | 0.1% / 8.4% | 109.0 | 4.6 | 11.8 | 0.2% / 8.3% | 108.4 |
| 25 | 2.1 | 10.3 | 0.3% / 2.7% | 261.6 | 2.2 | 9.9 | 0.0% / 2.8% | 264.4 | 2.3 | 13.2 | 0.3% / 2.7% | 260.9 |
| 50 | 2.0 | 13.3 | 2.9% / 4.9% | 514.5 | 2.0 | 12.6 | 2.8% / 5.5% | 515.2 | 2.0 | 14.2 | 4.4% / 6.4% | 505.1 |

Aynı tablo, tanı kolu T_plan yanında (P, T_plan, R):

**Kaynaklı arz** (80 hafta, pencere 21-80; söz kartları açık)

| Ekip | P MVP | P açık | P söz | P boşta | P teslim | T_plan MVP | T_plan açık | T_plan söz | T_plan boşta | T_plan teslim | R MVP | R açık | R söz | R boşta | R teslim |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 8.5 | 8.8 | 79.0% | 8.1% | 5.6 | 8.5 | 8.8 | 79.0% | 8.1% | 5.6 | 8.5 | 8.7 | 79.6% | 8.0% | 5.6 |
| 3 | 4.0 | 10.9 | 18.1% | 13.7% | 21.2 | 4.0 | 14.2 | 14.9% | 15.4% | 20.6 | 4.0 | 14.5 | 17.7% | 17.4% | 19.7 |
| 6 | 2.2 | 7.7 | 1.3% | 2.4% / 13.6% | 47.9 | 4.0 | 8.3 | 1.9% | 1.4% / 12.7% | 47.8 | 2.4 | 8.8 | 1.1% | 2.2% / 13.6% | 47.6 |
| 12 | 2.1 | 7.3 | 0.2% | 1.9% / 13.1% | 100.0 | 3.9 | 8.1 | 0.0% | 1.8% / 13.0% | 99.4 | 2.3 | 8.4 | 0.0% | 0.9% / 12.2% | 101.5 |
| 25 | 2.0 | 8.3 | 0.0% | 2.6% / 8.5% | 238.5 | 2.0 | 8.1 | 0.0% | 2.2% / 8.2% | 238.0 | 2.0 | 8.2 | 0.0% | 1.6% / 7.9% | 243.5 |
| 50 | 2.0 | 11.2 | 0.0% | 7.9% / 16.4% | 431.2 | 2.0 | 10.8 | 0.0% | 8.5% / 17.4% | 422.1 | 2.0 | 10.9 | 0.0% | 7.5% / 16.8% | 428.9 |

**Sınırsız arz** (60 hafta, pencere 21-60; söz kartı yok)

| Ekip | P MVP | P açık | P boşta | P teslim | T_plan MVP | T_plan açık | T_plan boşta | T_plan teslim | R MVP | R açık | R boşta | R teslim |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 6.3 | 6.0 | 24.8% | 4.5 | 6.3 | 6.0 | 24.8% | 4.5 | 6.3 | 6.0 | 24.8% | 4.5 |
| 3 | 4.0 | 8.2 | 17.4% | 20.5 | 4.0 | 8.3 | 17.4% | 20.6 | 4.0 | 8.3 | 17.2% | 20.7 |
| 6 | 2.2 | 8.2 | 3.5% / 12.1% | 49.5 | 4.0 | 8.3 | 3.5% / 12.3% | 49.2 | 4.0 | 8.3 | 3.0% / 11.7% | 49.0 |
| 12 | 2.1 | 9.3 | 0.4% / 8.5% | 107.2 | 2.2 | 9.5 | 0.1% / 8.3% | 107.4 | 2.2 | 9.6 | 0.1% / 8.4% | 109.0 |
| 25 | 2.1 | 10.3 | 0.3% / 2.7% | 261.6 | 2.2 | 9.9 | 0.1% / 2.5% | 261.2 | 2.2 | 9.9 | 0.0% / 2.8% | 264.4 |
| 50 | 2.0 | 13.3 | 2.9% / 4.9% | 514.5 | 2.0 | 12.4 | 3.0% / 5.0% | 513.3 | 2.0 | 12.6 | 2.8% / 5.5% | 515.2 |

### 1.1 Eşli farklar (P, R, Tarif ve T_plan'a göre)

Eksi işaret MVP, açık hata, kaçan söz, boşta, doğan hata ve kaçan hatada P lehine, teslimde P aleyhinedir. Parantezde farkın eksi çıktığı tohum sayısı.

*MVP haftası*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − R | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -0.1 ± 0.1 (1/20) | -0.1 ± 0.1 (1/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -0.2 ± 0.1 (2/20) | -0.2 ± 0.1 (2/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) |
| P − T | +0.0 ± 0.0 (0/20) | -2.4 ± 0.2 (20/20) | -2.9 ± 0.2 (20/20) | -2.5 ± 0.2 (20/20) | -0.2 ± 0.1 (2/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -0.4 ± 0.2 (4/20) | -2.7 ± 0.2 (20/20) | -1.9 ± 0.1 (19/20) | -0.1 ± 0.1 (1/20) | +0.0 ± 0.0 (0/20) |
| P − T_plan | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -0.1 ± 0.1 (1/20) | -0.1 ± 0.2 (2/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -1.8 ± 0.1 (18/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) |

*Açık hata*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − R | +0.0 ± 0.0 (0/20) | -0.1 ± 0.2 (7/20) | -0.1 ± 0.2 (10/20) | -0.3 ± 0.2 (9/20) | +0.5 ± 0.2 (3/20) | +0.7 ± 0.3 (4/20) | +0.1 ± 0.2 (4/20) | -3.6 ± 0.5 (19/20) | -1.1 ± 0.3 (15/20) | -1.1 ± 0.2 (17/20) | +0.1 ± 0.2 (7/20) | +0.3 ± 0.2 (5/20) |
| P − T | +0.0 ± 0.0 (0/20) | -1.9 ± 0.4 (16/20) | -1.2 ± 0.3 (17/20) | -2.5 ± 0.3 (19/20) | -2.9 ± 0.3 (19/20) | -0.9 ± 0.2 (15/20) | +0.8 ± 0.4 (6/20) | -21.5 ± 2.3 (20/20) | -1.1 ± 0.3 (16/20) | -3.9 ± 0.4 (20/20) | -4.7 ± 0.3 (20/20) | -2.8 ± 0.3 (20/20) |
| P − T_plan | +0.0 ± 0.0 (0/20) | -0.2 ± 0.2 (11/20) | -0.1 ± 0.3 (9/20) | -0.2 ± 0.2 (8/20) | +0.4 ± 0.3 (6/20) | +0.9 ± 0.3 (2/20) | +0.0 ± 0.0 (0/20) | -3.3 ± 0.6 (18/20) | -0.6 ± 0.3 (11/20) | -0.8 ± 0.2 (15/20) | +0.2 ± 0.2 (6/20) | +0.4 ± 0.2 (4/20) |

*Kaçan söz (yalnız kaynaklı arz; pp = yüzde puanı)*

| Fark (a − b) | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|
| P − R | -0.5 pp ± 0.9 pp (2/20) | 0.4 pp ± 2.9 pp (10/20) | 0.2 pp ± 0.8 pp (3/20) | 0.2 pp ± 0.2 pp (0/20) | 0.0 pp ± 0.0 pp (0/20) | 0.0 pp ± 0.0 pp (0/20) |
| P − T | -2.7 pp ± 2.2 pp (10/20) | -9.0 pp ± 2.0 pp (17/20) | -4.7 pp ± 1.8 pp (10/20) | -2.6 pp ± 0.8 pp (8/20) | -1.3 pp ± 0.7 pp (4/20) | -0.4 pp ± 0.4 pp (1/20) |
| P − T_plan | 0.0 pp ± 0.0 pp (0/20) | 3.2 pp ± 2.5 pp (6/20) | -0.6 pp ± 0.9 pp (6/20) | 0.2 pp ± 0.2 pp (0/20) | 0.0 pp ± 0.0 pp (0/20) | 0.0 pp ± 0.0 pp (0/20) |

*Boşta (PM hariç)*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − R | 0.0 pp ± 0.0 pp (0/20) | 0.1 pp ± 0.2 pp (10/20) | 0.5 pp ± 0.2 pp (3/20) | 0.3 pp ± 0.0 pp (0/20) | 0.3 pp ± 0.0 pp (0/20) | 0.0 pp ± 0.1 pp (9/20) | 0.1 pp ± 0.1 pp (3/20) | -3.7 pp ± 0.6 pp (19/20) | 0.1 pp ± 0.2 pp (7/20) | 1.1 pp ± 0.2 pp (1/20) | 1.0 pp ± 0.1 pp (2/20) | 0.4 pp ± 0.1 pp (7/20) |
| P − T | 0.0 pp ± 0.0 pp (0/20) | -1.5 pp ± 0.4 pp (16/20) | 1.1 pp ± 0.1 pp (0/20) | 0.2 pp ± 0.1 pp (6/20) | -0.0 pp ± 0.0 pp (10/20) | -1.5 pp ± 0.1 pp (20/20) | -0.6 pp ± 0.6 pp (12/20) | -3.3 pp ± 0.7 pp (17/20) | 1.2 pp ± 0.2 pp (0/20) | 0.1 pp ± 0.2 pp (7/20) | -0.4 pp ± 0.2 pp (14/20) | -4.2 pp ± 0.2 pp (20/20) |
| P − T_plan | 0.0 pp ± 0.0 pp (0/20) | -0.1 pp ± 0.2 pp (11/20) | -0.0 pp ± 0.2 pp (10/20) | 0.2 pp ± 0.0 pp (1/20) | 0.2 pp ± 0.0 pp (0/20) | -0.2 pp ± 0.1 pp (12/20) | 0.0 pp ± 0.0 pp (0/20) | -1.8 pp ± 0.4 pp (17/20) | 1.0 pp ± 0.2 pp (2/20) | 0.1 pp ± 0.2 pp (7/20) | 0.3 pp ± 0.1 pp (4/20) | -0.5 pp ± 0.1 pp (17/20) |

*Boşta (PM dahil)*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − R | 0.0 pp ± 0.0 pp (0/20) | 0.1 pp ± 0.2 pp (10/20) | 0.3 pp ± 0.2 pp (5/20) | 0.1 pp ± 0.1 pp (8/20) | -0.1 pp ± 0.0 pp (15/20) | -0.7 pp ± 0.1 pp (19/20) | 0.1 pp ± 0.1 pp (3/20) | -3.7 pp ± 0.6 pp (19/20) | 0.1 pp ± 0.2 pp (8/20) | 0.9 pp ± 0.2 pp (3/20) | 0.7 pp ± 0.2 pp (4/20) | -0.4 pp ± 0.1 pp (16/20) |
| P − T | 0.0 pp ± 0.0 pp (0/20) | -1.5 pp ± 0.4 pp (16/20) | 1.0 pp ± 0.1 pp (0/20) | 0.3 pp ± 0.1 pp (3/20) | -0.0 pp ± 0.1 pp (12/20) | -1.5 pp ± 0.1 pp (20/20) | -0.6 pp ± 0.6 pp (12/20) | -3.3 pp ± 0.7 pp (17/20) | 0.9 pp ± 0.2 pp (3/20) | 0.1 pp ± 0.2 pp (9/20) | -0.3 pp ± 0.2 pp (12/20) | -5.0 pp ± 0.2 pp (20/20) |
| P − T_plan | 0.0 pp ± 0.0 pp (0/20) | -0.1 pp ± 0.2 pp (11/20) | -0.2 pp ± 0.2 pp (12/20) | 0.2 pp ± 0.1 pp (3/20) | 0.2 pp ± 0.0 pp (1/20) | -0.2 pp ± 0.1 pp (13/20) | 0.0 pp ± 0.0 pp (0/20) | -1.8 pp ± 0.4 pp (17/20) | 1.0 pp ± 0.2 pp (2/20) | 0.2 pp ± 0.2 pp (9/20) | 0.3 pp ± 0.2 pp (6/20) | -1.0 pp ± 0.1 pp (18/20) |

*Teslim (puan/hf)*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − R | +0.0 ± 0.0 (0/20) | -0.2 ± 0.1 (7/20) | +0.5 ± 0.2 (1/20) | -1.8 ± 0.3 (17/20) | -2.8 ± 0.7 (18/20) | -0.7 ± 0.6 (13/20) | -0.0 ± 0.0 (2/20) | +1.5 ± 0.3 (3/20) | +0.3 ± 0.2 (8/20) | -1.5 ± 0.3 (17/20) | -5.0 ± 0.5 (19/20) | +2.3 ± 0.7 (4/20) |
| P − T | +0.0 ± 0.0 (0/20) | -0.3 ± 0.2 (10/20) | -1.1 ± 0.3 (13/20) | -1.1 ± 0.3 (13/20) | +0.8 ± 0.6 (8/20) | +9.3 ± 0.8 (0/20) | -0.1 ± 0.1 (8/20) | -0.1 ± 0.2 (11/20) | -0.3 ± 0.3 (12/20) | +0.8 ± 0.3 (5/20) | +2.3 ± 0.6 (4/20) | +33.2 ± 0.9 (0/20) |
| P − T_plan | +0.0 ± 0.0 (0/20) | -0.1 ± 0.1 (6/20) | +0.2 ± 0.3 (4/20) | -0.1 ± 0.2 (8/20) | +0.5 ± 0.5 (7/20) | +1.2 ± 0.5 (5/20) | +0.0 ± 0.0 (0/20) | +0.6 ± 0.2 (3/20) | +0.1 ± 0.2 (9/20) | +0.6 ± 0.3 (7/20) | +0.5 ± 0.5 (8/20) | +9.1 ± 0.7 (0/20) |

*Doğan hata (pencerede toplam; ilkenin ölçüsü)*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − R | +0.0 ± 0.0 (0/20) | +0.2 ± 0.8 (9/20) | -2.7 ± 1.5 (10/20) | -4.5 ± 2.2 (14/20) | -9.3 ± 2.4 (16/20) | -26.4 ± 3.1 (20/20) | +0.1 ± 0.4 (1/20) | +2.8 ± 1.7 (8/20) | -4.1 ± 2.1 (11/20) | -6.6 ± 2.5 (15/20) | -3.5 ± 3.3 (11/20) | -5.5 ± 4.6 (12/20) |
| P − T | +0.0 ± 0.0 (0/20) | +0.3 ± 1.0 (9/20) | -3.5 ± 1.8 (14/20) | +1.1 ± 1.4 (8/20) | +0.2 ± 1.8 (9/20) | +6.8 ± 3.7 (9/20) | -0.9 ± 1.0 (11/20) | +1.7 ± 1.6 (8/20) | -2.5 ± 1.6 (13/20) | -6.4 ± 2.7 (16/20) | -0.3 ± 3.8 (10/20) | +39.7 ± 7.2 (3/20) |
| P − T_plan | +0.0 ± 0.0 (0/20) | +0.5 ± 1.1 (11/20) | +0.8 ± 1.6 (9/20) | -0.9 ± 2.2 (9/20) | -6.1 ± 2.1 (15/20) | -3.0 ± 3.8 (10/20) | +0.0 ± 0.0 (0/20) | +0.6 ± 1.7 (10/20) | +2.5 ± 1.7 (7/20) | -7.0 ± 2.9 (14/20) | -3.5 ± 4.1 (13/20) | +2.5 ± 5.4 (12/20) |

*Sürüme kaçan hata (pencerede toplam)*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − R | +0.0 ± 0.0 (0/20) | -0.4 ± 0.9 (12/20) | -1.2 ± 1.5 (10/20) | +0.9 ± 1.9 (9/20) | +1.4 ± 2.1 (6/20) | -10.8 ± 2.9 (16/20) | +0.1 ± 0.3 (1/20) | -0.1 ± 1.6 (9/20) | -2.2 ± 1.7 (11/20) | -0.8 ± 2.0 (13/20) | +1.9 ± 3.0 (10/20) | +3.5 ± 4.1 (7/20) |
| P − T | +0.0 ± 0.0 (0/20) | +0.8 ± 1.0 (6/20) | +0.5 ± 1.3 (9/20) | +3.6 ± 1.4 (6/20) | +3.3 ± 1.7 (5/20) | +3.3 ± 3.0 (7/20) | -1.4 ± 0.9 (13/20) | -0.8 ± 1.7 (11/20) | +2.9 ± 1.4 (6/20) | +0.5 ± 1.8 (7/20) | +4.3 ± 2.5 (5/20) | +22.2 ± 3.7 (2/20) |
| P − T_plan | +0.0 ± 0.0 (0/20) | +0.1 ± 1.1 (11/20) | -0.8 ± 1.3 (13/20) | +0.1 ± 1.9 (9/20) | +1.3 ± 1.7 (9/20) | +2.0 ± 2.7 (9/20) | +0.0 ± 0.0 (0/20) | -0.1 ± 1.7 (10/20) | +1.7 ± 1.5 (6/20) | -3.2 ± 1.7 (12/20) | +2.4 ± 2.8 (7/20) | +4.8 ± 3.1 (9/20) |

### 1.2 Düz sayılarla doğan hata ve kaçan hata

*Doğan hata*

| Kol | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **P (yeni planlayıcı)** | 8.7 | 33.5 | 58.2 | 123.0 | 271.6 | 549.0 | 16.2 | 48.2 | 87.2 | 164.1 | 382.1 | 758.0 |
| R (bugünkü kural) | 8.7 | 33.2 | 61.0 | 127.5 | 281.0 | 575.5 | 16.1 | 45.5 | 91.2 | 170.7 | 385.7 | 763.5 |
| Tarif (A6, Erdem'in tarifi) | 8.7 | 33.2 | 61.8 | 121.9 | 271.4 | 542.2 | 17.1 | 46.5 | 89.7 | 170.4 | 382.4 | 718.2 |
| T_plan (tanı kolu) | 8.7 | 33.0 | 57.5 | 124.0 | 277.8 | 552.1 | 16.2 | 47.6 | 84.7 | 171.1 | 385.6 | 755.5 |

*Sürüme kaçan hata*

| Kol | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **P (yeni planlayıcı)** | 6.8 | 25.1 | 37.4 | 63.1 | 122.2 | 232.1 | 12.7 | 33.6 | 52.0 | 81.0 | 171.3 | 320.9 |
| R (bugünkü kural) | 6.8 | 25.5 | 38.5 | 62.2 | 120.8 | 242.8 | 12.6 | 33.8 | 54.3 | 81.8 | 169.5 | 317.4 |
| Tarif (A6, Erdem'in tarifi) | 6.8 | 24.3 | 36.9 | 59.5 | 119.0 | 228.8 | 14.1 | 34.5 | 49.2 | 80.5 | 167.0 | 298.7 |
| T_plan (tanı kolu) | 6.8 | 24.9 | 38.1 | 63.0 | 121.0 | 230.1 | 12.7 | 33.8 | 50.4 | 84.2 | 168.9 | 316.1 |

### 1.3 Okuma

- **MVP.** 3 kişide Tarif MVP'yi R'den geç çıkarıyor (6,4 hafta, R 4,0); P R ile aynı (+0,0 ± 0,0 (0/20)). 6 kişide P öne geçiyor: sınırsız arzda P 2,2, R 4,0, Tarif 5,1 (P−R -1,8 ± 0,1 (18/20)); kaynaklı arzda P 2,2, R 2,4, Tarif 4,9. 12 kişide P ve R aynı, Tarif 4,6 haftada. 25 ve 50 kişide hepsi ilk sprintte (2. hafta). 1 kişide seçilecek bir şey yok, hepsi aynı.
- **Açık hata.** Kaynaklı arzda P R'den 3 kişide -3,6, 6 kişide -1,1, 12 kişide -1,1 az (eşli: -3,6 ± 0,5 (19/20) / -1,1 ± 0,3 (15/20) / -1,1 ± 0,2 (17/20)); sınırsız arzda 3-12 kişide fark ayırt edilemiyor. 25 ve 50 kişide P R'den biraz fazla: +0,5 ± 0,2 (3/20) ve +0,7 ± 0,3 (4/20) (kaynaklı: +0,1 ± 0,2 (7/20) ve +0,3 ± 0,2 (5/20)). Tarif'e göre P her büyüklükte (1 kişi hariç) az: kaynaklı 3 kişide -21,5 ± 2,3 (20/20).
- **Kaçan söz** (kaynaklı arz). P ile R ayırt edilemiyor: 3 kişi 0,4 pp ± 2,9 pp (10/20), 6 kişi 0,2 pp ± 0,8 pp (3/20), 12 kişi 0,2 pp ± 0,2 pp (0/20). Tarif'e göre azalma: 3 kişide -9,0 pp ± 2,0 pp (17/20), 6 kişide -4,7 pp ± 1,8 pp (10/20), 12 kişide -2,6 pp ± 0,8 pp (8/20). 3 kişide söz kaçırma her kolda yüksek (P 18,1%, R 17,7%, Tarif 27,2%); P bunu düzeltmiyor, yalnız Tarif'in artışını (T_plan gibi) geri alıyor.
- **Boşta.** P ile R arasında yüzde puanı mertebesinde fark var, yön ekibe göre değişiyor: PM hariç, sınırsız arzda 6 / 12 / 25 kişide P R'den 0,5 pp / 0,3 pp / 0,3 pp fazla boşta; kaynaklı 3 kişide -3,7 pp (P daha az boşta), kaynaklı 12 / 25 kişide 1,1 pp / 1,0 pp fazla. [GÖRÜŞ] Fazlanın kaynağı büyük olasılıkla gereksinim kapısı (yetmeyen kişi karta girmez); bu ayrıca ölçülmedi. PM dahil sayıda 50 kişide P R'den -0,7 pp az.
- **Teslim.** P−R: 3 / 6 kişide -0,2 / +0,5; 12 / 25 / 50 kişide -1,8 ± 0,3 (17/20) / -2,8 ± 0,7 (18/20) / -0,7 ± 0,6 (13/20) (sınırsız); kaynaklı 12 / 25 / 50 kişide -1,5 ± 0,3 (17/20) / -5,0 ± 0,5 (19/20) / +2,3 ± 0,7 (4/20). Tarif'e göre P 50 kişide +9,3 puan/hf (kaynaklı +33,2) önde, 3-12 kişide ayırt edilemiyor.
- **Doğan hata.** P−R: 6 / 12 / 25 / 50 kişide -2,7 ± 1,5 (10/20) / -4,5 ± 2,2 (14/20) / -9,3 ± 2,4 (16/20) / -26,4 ± 3,1 (20/20) (sınırsız); 12-50 kişide R'ye göre %3-5 az; "karmaşık kart daha iyi kişilere" yer değişimi adımı ayrıca ölçülebilir kazanç vermiyor (§4.3), yani kazanç büyük ölçüde gereksinim kapısından gelir [GÖRÜŞ]. P−Tarif: 6 kişide -3,5 ± 1,8 (14/20), 12 / 25 kişide ayırt edilemiyor (+1,1 ± 1,4 (8/20) / +0,2 ± 1,8 (9/20)); 50 kişide P'nin doğan hatası daha fazla (+6,8 ± 3,7 (9/20)), çünkü Tarif'ten +9,3 puan/hf fazla iş teslim ediyor.

## 2. İz 1: Erdem'in örneği birebir

**Kurulum** (Erdem'in 25. maddesi, sayılar benim seçimim). 3 geliştirici: A 4 yıldız (Yazılım 15,4 puan/hf), B ve C 3 yıldız (11,6 puan/hf); üçü de her kartın gereksinimini karşılıyor, üçü de testi yan işte (0,7 hızla) yapabiliyor. Sprintte 3 kart, plan sırasıyla:

- **Büyük**: 100 puanlık Yazılım işi, gereksinim 2 yıldız. İki kişiyle (A ve bir 3 yıldızlı: 27 puan/hf) 3,7 hafta sürer, yani 2 sprinte sığar; üç kişiyle bile 2,6 hafta sürer, yani ilk sprintte bitmesi mümkün değildir.
- **Küçük 1** ve **Küçük 2**: 10 puanlık Yazılım işi, gereksinim 1 yıldız. Bir 3 yıldızlı kişi her birini 0,86 haftada bitirir.
- Her kartın Test işi 0,5 puan, Tasarım işi yok. Hata zarı kapalı (örnek yalnız atamayı gösteriyor). 4 hafta (2 sprint) oynatıldı. Büyük kart plan sırasında ilk (kötü durum: ilk kart herkesi toplayabilir).

Tablo hücresi: o haftada kişinin kart (aşama) başına harcadığı hafta kesri; "boşta" iş bulunamayan süre (4. haftadaki boşluklar örnekte başka kart kalmadığı içindir). Son satırdaki "P, satır seçimi eski kuralla" tanı koludur (§4.3).

**R (bugünkü kural)**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Kucuk2 yazilim 0,04 | Kucuk2 yazilim 0,17; Kucuk2 test 0,05; boşta 0,77 |
| B | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Buyuk test 0,04 | Kucuk2 yazilim 0,17; boşta 0,83 |
| C | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk2 yazilim 0,41 | Buyuk test 0,03; Kucuk1 test 0,07; boşta 0,90 |

Kartlar: Buyuk biter h3,03 (sprint 2); Kucuk1 biter h3,10 (sprint 2); Kucuk2 biter h3,23 (sprint 2)

**Tarif (Erdem'in tarifi)**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Kucuk2 yazilim 0,04 | Kucuk2 yazilim 0,17; Kucuk2 test 0,05; boşta 0,77 |
| B | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Buyuk test 0,04 | Buyuk test 0,03; Kucuk1 test 0,07; boşta 0,90 |
| C | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk2 yazilim 0,41 | Kucuk2 yazilim 0,17; boşta 0,83 |

Kartlar: Buyuk biter h3,03 (sprint 2); Kucuk1 biter h3,10 (sprint 2); Kucuk2 biter h3,23 (sprint 2)

**T_plan (tanı kolu)**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Kucuk2 yazilim 0,04 | Kucuk2 yazilim 0,17; Kucuk2 test 0,05; boşta 0,77 |
| B | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Buyuk test 0,04 | Buyuk test 0,03; Kucuk1 test 0,07; boşta 0,90 |
| C | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk2 yazilim 0,41 | Kucuk2 yazilim 0,17; boşta 0,83 |

Kartlar: Buyuk biter h3,03 (sprint 2); Kucuk1 biter h3,10 (sprint 2); Kucuk2 biter h3,23 (sprint 2)

**P (yeni planlayıcı)**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,15; Buyuk test 0,05; boşta 0,79 |
| B | Kucuk1 yazilim 0,86; Kucuk2 yazilim 0,14 | Kucuk2 yazilim 0,72; Kucuk1 test 0,07; Kucuk2 test 0,07; Buyuk yazilim 0,13 | Buyuk yazilim 1,00 | Buyuk yazilim 0,15; boşta 0,85 |
| C | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,15; boşta 0,85 |

Kartlar: Buyuk biter h3,21 (sprint 2); Kucuk1 biter h1,80 (sprint 1); Kucuk2 biter h1,87 (sprint 1)

**P, satır seçimi eski kuralla**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,11; Buyuk test 0,05; boşta 0,84 |
| B | Kucuk1 yazilim 0,86; Kucuk2 yazilim 0,14 | Kucuk2 yazilim 0,72; Buyuk yazilim 0,28 | Buyuk yazilim 1,00 | Buyuk yazilim 0,11; Kucuk1 test 0,07; boşta 0,82 |
| C | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,11; Kucuk2 test 0,07; boşta 0,82 |

Kartlar: Buyuk biter h3,16 (sprint 2); Kucuk1 biter h3,18 (sprint 2); Kucuk2 biter h3,18 (sprint 2)

**Okuma.**

- **R, Tarif ve T_plan aynı şeyi yapıyor ve Erdem'in anlattığı şey bu.** İlk iki hafta üç kişi de büyük kartın Yazılımında; küçük kartlar h2,59'a kadar başlamıyor, üçü de ikinci sprintte bitiyor (büyük h3,03, küçük 1 h3,10, küçük 2 h3,23). Neden: R'de plan sırasının başındaki kart kadro tavanını (13 kişi) doldurur; Tarif ve T_plan'da en önde duran kart "tavan kadar en iyi kişi"yi alır. Kadro tavanı ekibin üç kişisinden büyük olduğu için kimse artmaz, küçük kartlar boşa çıkar. "Kalır" yüzünden Tarif ve T_plan'da kimse yarıda çıkıp küçük karta da geçemez.
- **P ikisini ayırıyor.** Büyük kartın ufku ikinci sprintin sonu (üç kişi bile ilk sprintte bitiremez); bu ufku tutturmak için A ve C yetiyor (27 puan/hf, 3,7 hafta). Üçüncü kişi B kalan kartlara gidiyor: küçük 1'in Yazılımı (h0,00-0,86), küçük 2'nin Yazılımı (h0,86-1,72), sonra ikisinin testi (h1,72-1,87); B küçük 2'ye hafta sonunu beklemeden, küçük 1 biter bitmez geçiyor (reaktif katman). Küçük kartlar **ilk sprintte** bitiyor (h1,80 ve h1,87), büyük kart ikinci sprintte (h3,21). Erdem'in beklediği desenle aynı: ikisi büyük kartta, biri küçük 1 sonra küçük 2.
- **İlke.** Büyük kartın karmaşıklığı (100 puan × 2 yıldız) küçüklerinkinden (10 × 1) büyük; en iyi kişi A büyük kartta. Küçük kartlar 3 yıldızlı kişiye gidiyor.
- **Bedel yok denecek kadar küçük, ama var.** Büyük kart P'de 0,18 hafta geç bitiyor (h3,21; ötekilerde h3,03), çünkü B büyük karta h1,87'den önce girmiyor. Üç kartın hepsinin bittiği an hemen hemen aynı (h3,21 ve h3,23): toplam iş ve kişi-hafta aynı, yalnız sıra değişiyor; kazanç iki küçük kartın bir sprint erken (ilk sprintte) teslim edilmesi.
- **Satır seçimi neden gerekli.** P'nin satır seçimini eski kurala (plan sırasındaki en önde açık satır) çevirince (tablonun son kolu) B küçük kartlara aynı şekilde gidiyor ama bitirdiği kartların testini yapmıyor, büyük kartın yazılımına yardıma gidiyor; küçük kartlar h3,18'de, ikinci sprintte bitiyor. Küçük kartı yazılımı bitmiş ama testi bekleyen "iş bitmiyor" durumu budur.
- **Büyük kart planda sonda olursa** (iz 1b: küçük 1, küçük 2, büyük) R'nin küçük kartlarının yazılımı ilk haftada biter ama testleri büyük kartın yazılımı bitene kadar yapılmaz (küçükler h3,18, büyük h3,16); Tarif'te küçükler h3,03 ve h3,23'te. P'de küçük kartlar h0,93 ve h1,00'de, büyük kart h3,21'de bitiyor.

**İz 1b: aynı kartlar, büyük kart planda sonda.**

**R (bugünkü kural)**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Kucuk1 yazilim 0,37; Buyuk yazilim 0,63 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,11; Buyuk test 0,05; boşta 0,84 |
| B | Kucuk1 yazilim 0,37; Kucuk2 yazilim 0,25; Buyuk yazilim 0,38 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,11; Kucuk1 test 0,07; boşta 0,82 |
| C | Kucuk2 yazilim 0,62; Buyuk yazilim 0,38 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,11; Kucuk2 test 0,07; boşta 0,82 |

Kartlar: Kucuk1 biter h3,18 (sprint 2); Kucuk2 biter h3,18 (sprint 2); Buyuk biter h3,16 (sprint 2)

**Tarif (Erdem'in tarifi)**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Kucuk2 yazilim 0,04 | Kucuk2 yazilim 0,17; Kucuk2 test 0,05; boşta 0,77 |
| B | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk1 yazilim 0,37; Kucuk1 test 0,04 | Kucuk1 test 0,03; Buyuk test 0,07; boşta 0,90 |
| C | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,59; Kucuk2 yazilim 0,41 | Kucuk2 yazilim 0,17; boşta 0,83 |

Kartlar: Kucuk1 biter h3,03 (sprint 2); Kucuk2 biter h3,23 (sprint 2); Buyuk biter h3,10 (sprint 2)

**P (yeni planlayıcı)**

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| A | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,15; Buyuk test 0,05; boşta 0,79 |
| B | Kucuk2 yazilim 0,58; Buyuk yazilim 0,42 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,15; boşta 0,85 |
| C | Kucuk1 yazilim 0,37; Kucuk2 yazilim 0,21; Buyuk yazilim 0,28; Kucuk1 test 0,07; Kucuk2 test 0,07 | Buyuk yazilim 1,00 | Buyuk yazilim 1,00 | Buyuk yazilim 0,15; boşta 0,85 |

Kartlar: Kucuk1 biter h0,93 (sprint 1); Kucuk2 biter h1,00 (sprint 1); Buyuk biter h3,21 (sprint 2)

## 3. İz 2: "3 kişi + 4 kart", MVP'nin 4. haftadan 6. haftaya kaydığı gerçek tohum

**Kurulum.** A6 §4.1'deki tohum: S2 ekibi (3 kişi), sınırsız arz, tohum 1, hata modeli K-H. Kurucu (Tasarım, Yazılım ve Test'in hepsinde 2 yıldız hızında; ekipte testi yapabilen tek kişi), Deniz (Yazılım 3 yıldız, testi yapamaz), Ece (Tasarım 2 yıldız). İlk sprintin planı **4 kart**: üç MVP kartı (15 puan, kapısız: kart 1, 2, 3; yıldızlı) ve 25 puanlık kart 4 (2. kademe; Tasarım 1 ve Yazılım 2 yıldız kilitli). Plan sırası 1, 2, 3, 4. Tabloda kişinin adının yanındaki üç sayı Tasarım / Yazılım / Test yıldızı.

20 tohumun ortalaması: MVP haftası Tarif'te 6,4 (16 tohumda 6., 4 tohumda 8. hafta), R'de 4,0, T_plan'da 4,0, ileri oynatmasız P'de 4,0, P'de 4,0; R, T_plan ve P 20 tohumun 20'sinde tam 4. haftada. Aşağıdaki iz 1. tohum.

**R (bugünkü kural)** · S2, tohum 1 · MVP haftası 4 · teslim 20.5 puan/hf · açık hata (medyan) 9.0

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| Kurucu(2.0*/2.0*/2.0*) | kart2* (15p) tasarim 0,23; kart2* (15p) yazilim 0,50; kart2* (15p) test 0,27 | kart1* (15p) yazilim 0,45; kart1* (15p) test 0,35; kart2* (15p) test 0,08; kart3* (15p) test 0,13 | kart3* (15p) test 0,45; kart4 (25p) yazilim 0,20; kart4 (25p) test 0,34 | kart4 (25p) test 0,24; kart4 (25p) yazilim 0,15; kart5 (15p) test 0,35; kart7 (15p) yazilim 0,26 |
| Deniz(0.0*/3.0*/2.5*) | boşta 0,23; kart2* (15p) yazilim 0,50; kart1* (15p) yazilim 0,27 | kart3* (15p) yazilim 0,69; boşta 0,17; kart4 (25p) yazilim 0,14 | kart4 (25p) yazilim 0,66; kart5 (15p) yazilim 0,34 | kart5 (15p) yazilim 0,26; kart6 (15p) yazilim 0,60; boşta 0,14 |
| Ece(2.0*/0.0*/0.0*) | kart1* (15p) tasarim 0,58; kart3* (15p) tasarim 0,23; kart4 (25p) tasarim 0,19 | kart4 (25p) tasarim 0,86; boşta 0,14 | kart5 (15p) tasarim 0,44; kart6 (15p) tasarim 0,56 | kart6 (15p) tasarim 0,02; kart7 (15p) tasarim 0,58; boşta 0,40 |

Biten kartlar (sprint sonu haftası, kart, puan; * = MVP kartı): h2 kart1* 15p, h2 kart2* 15p, h4 kart3* 15p, h4 kart4 25p, h4 kart5 15p, h6 kart6 15p, h6 kart7 15p

**Tarif (Erdem'in tarifi)** · S2, tohum 1 · MVP haftası 6 · teslim 19.8 puan/hf · açık hata (medyan) 11.0

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 | Hafta 5 | Hafta 6 |
|---|---|---|---|---|---|---|
| Kurucu(2.0*/2.0*/2.0*) | kart4 (25p) tasarim 0,52; kart2* (15p) tasarim 0,23; kart4 (25p) yazilim 0,24 | kart4 (25p) yazilim 0,17; kart2* (15p) yazilim 0,50; kart1* (15p) yazilim 0,34 | kart1* (15p) yazilim 0,48; kart3* (15p) test 0,52 | kart3* (15p) test 0,06; kart4 (25p) test 0,58; kart1* (15p) test 0,35; kart2* (15p) test 0,01 | kart2* (15p) test 0,34; kart8 (25p) yazilim 0,66 | kart8 (25p) yazilim 0,03; kart9 (15p) yazilim 0,56; kart8 (25p) test 0,41 |
| Deniz(0.0*/3.0*/2.5*) | boşta 0,52; kart4 (25p) yazilim 0,48 | kart4 (25p) yazilim 0,17; kart2* (15p) yazilim 0,50; kart3* (15p) yazilim 0,34 | kart3* (15p) yazilim 0,35; kart5 (15p) yazilim 0,60; kart6 (15p) yazilim 0,05 | kart6 (15p) yazilim 0,56; kart7 (15p) yazilim 0,44 | kart7 (15p) yazilim 0,16; kart8 (25p) yazilim 0,84 | kart8 (25p) yazilim 0,03; kart4 (25p) yazilim 0,11; kart9 (15p) yazilim 0,45; kart10 (15p) yazilim 0,41 |
| Ece(2.0*/0.0*/0.0*) | kart4 (25p) tasarim 0,52; kart1* (15p) tasarim 0,48 | kart1* (15p) tasarim 0,10; kart3* (15p) tasarim 0,23; boşta 0,66 | kart6 (15p) tasarim 0,50; kart7 (15p) tasarim 0,50 | kart7 (15p) tasarim 0,08; boşta 0,92 | kart10 (15p) tasarim 0,01; boşta 0,99 | boşta 1,00 |

Biten kartlar (sprint sonu haftası, kart, puan; * = MVP kartı): h4 kart1* 15p, h4 kart3* 15p, h6 kart2* 15p, h6 kart4 25p

**T_plan (tanı kolu)** · S2, tohum 1 · MVP haftası 4 · teslim 20.5 puan/hf · açık hata (medyan) 8.0

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| Kurucu(2.0*/2.0*/2.0*) | kart2* (15p) tasarim 0,23; kart2* (15p) yazilim 0,50; kart2* (15p) test 0,27 | kart2* (15p) test 0,08; kart3* (15p) yazilim 0,92 | kart3* (15p) yazilim 0,01; kart1* (15p) test 0,35; kart3* (15p) test 0,58; kart4 (25p) test 0,06 | kart4 (25p) test 0,52; kart4 (25p) yazilim 0,48 |
| Deniz(0.0*/3.0*/2.5*) | boşta 0,23; kart2* (15p) yazilim 0,50; kart1* (15p) yazilim 0,27 | kart1* (15p) yazilim 0,33; boşta 0,53; kart4 (25p) yazilim 0,14 | kart4 (25p) yazilim 0,81; kart5 (15p) yazilim 0,19 | kart5 (15p) yazilim 0,41; kart6 (15p) yazilim 0,59 |
| Ece(2.0*/0.0*/0.0*) | kart1* (15p) tasarim 0,58; kart3* (15p) tasarim 0,23; kart4 (25p) tasarim 0,19 | kart4 (25p) tasarim 0,86; boşta 0,14 | kart5 (15p) tasarim 0,44; kart6 (15p) tasarim 0,56 | kart6 (15p) tasarim 0,02; kart7 (15p) tasarim 0,58; boşta 0,40 |

Biten kartlar (sprint sonu haftası, kart, puan; * = MVP kartı): h2 kart2* 15p, h4 kart1* 15p, h4 kart3* 15p, h6 kart4 25p, h6 kart5 15p, h6 kart6 15p, h6 kart7 15p

**P (yeni planlayıcı)** · S2, tohum 1 · MVP haftası 4 · teslim 19.5 puan/hf · açık hata (medyan) 9.0

| Kişi | Hafta 1 | Hafta 2 | Hafta 3 | Hafta 4 |
|---|---|---|---|---|
| Kurucu(2.0*/2.0*/2.0*) | kart1* (15p) tasarim 0,58; kart1* (15p) yazilim 0,42 | kart1* (15p) yazilim 0,40; kart1* (15p) test 0,35; kart2* (15p) test 0,26 | kart2* (15p) test 0,09; kart3* (15p) test 0,58; kart4 (25p) yazilim 0,03; kart4 (25p) test 0,29 | kart4 (25p) test 0,29; kart4 (25p) yazilim 0,15; kart5 (15p) test 0,35; kart7 (15p) yazilim 0,21 |
| Deniz(0.0*/3.0*/2.5*) | boşta 0,23; kart2* (15p) yazilim 0,77 | kart2* (15p) yazilim 0,09; kart3* (15p) yazilim 0,69; kart4 (25p) yazilim 0,22 | kart4 (25p) yazilim 0,71; kart5 (15p) yazilim 0,29 | kart5 (15p) yazilim 0,31; kart6 (15p) yazilim 0,60; boşta 0,09 |
| Ece(2.0*/0.0*/0.0*) | kart2* (15p) tasarim 0,23; kart3* (15p) tasarim 0,23; kart4 (25p) tasarim 0,53 | kart4 (25p) tasarim 0,51; boşta 0,49 | kart5 (15p) tasarim 0,09; kart6 (15p) tasarim 0,58; kart7 (15p) tasarim 0,33 | kart7 (15p) tasarim 0,26; boşta 0,74 |

Biten kartlar (sprint sonu haftası, kart, puan; * = MVP kartı): h2 kart1* 15p, h4 kart2* 15p, h4 kart3* 15p, h4 kart4 25p, h4 kart5 15p, h6 kart6 15p, h6 kart7 15p

**Okuma.**

- **Kayma nerede başlıyor.** Tarif'in 1. haftasında Kurucu ve Ece **kart 4'ün tasarımına** giriyor (h0,00-0,52); tarifin 1. adımı "en yüksek gereksinimli kart önce" olduğu için planın en büyük ve tek kilitli kartı öne geçiyor, MVP kartlarının tasarımı 0,52'de başlıyor; Deniz ilk 0,52 hafta boşta. Kart 4'ün yazılımı ve testi de Kurucu'yu ve tek testçi sırasını tutuyor: MVP kartlarından kart 2 ancak h6'da bitiyor. R ve T_plan MVP kartlarının tasarımını h0,00'da başlatıyor (R: Ece kart 1'e, Kurucu kart 2'ye); kart 4'ün tasarımı MVP kartlarından sonraya, h0,81-1,86 arasına kalıyor.
- **İleriye bakmama mı?** Hayır, doğrudan değil. T_plan ileriye bakmayan, yalnız 1. adımda plan sırasını koruyan bir kol; MVP'yi tam 4. haftaya indiriyor (20 tohumun 20'sinde). P'nin ileriye bakması 3 kişide bunun üstüne bir şey eklemiyor (P ve ileri oynatmasız P da 20 tohumun 20'sinde 4. hafta). Kaymayı yaratan, planın en büyük kartının öne alınmasıdır; "iki kişi büyük işe gitti" ailesinden aynı hata, ama çaresi ileriye bakma değil sıranın plana bağlanması. P bunu hem sıralamayla hem boyutlandırmayla kapatıyor.
- **Neden 2. hafta olmuyor.** Üç MVP kartı toplam 45 puan, ekibin iki haftalık kapasitesi 57,6 puan; ama Test'i yalnız Kurucu yapıyor (11 puan, 1,3 hafta), Yazılım'ı yalnız Deniz ile Kurucu, aşamalar sıralı: hiçbir kol 20 tohumun hiçbirinde üç MVP kartını ilk sprintte bitiremiyor. Bu tohumda R ilk sprintte iki MVP kartını (1 ve 2) bitiriyor, P bir kartı (1); üçüncüsü ikisinde de h4'te. MVP haftası aynı, ilk sprintte bitirilen MVP kartı sayısı R'de bir fazla.
- **P bu tohumda R'den bir MVP kartı geride.** İlk sprintte R kart 1 ve kart 2'yi, P yalnız kart 1'i bitiriyor (kart 2 ve 3 h4'te); MVP haftası aynı (4). P'nin 8 seçeneği ilk haftada bu planı şöyle puanlıyor (`a8dbg.py`, plan puanı: sprintte biten kartlar, sıra ağırlığı 1,00 / 0,85 / ...): ufuk payı seçeneklerinin beşi (üçü normal, ikisi saklamalı) yalnız kart 1'i bitiriyor (1,00); kadro tavanı, T_plan ve saklamalı kadro tavanı yalnız kart 2'yi bitiriyor (0,85). R'nin deseni iki kartı bitiriyor (1,00 + 0,85 = 1,85) ve P'nin seçenek kümesinde yok. [GÖRÜŞ] Bu tek tohum, P'nin 3 kişide R'den üstün olduğunu değil, Tarif'in kaymasını kapattığını gösterir; 20 tohumda üç kolun MVP'si aynı (4,0) ve teslimde fark -0,2 ± 0,1 (7/20).

## 4. Planlayıcının kuralı ve plan süresi

### 4.1 Kural

Planlayıcı iki katmandır: her atama anında çalışan bir **dağıtım kuralı** (reaktif) ve her hafta başında kuralın seçeneklerini ileri oynatıp en iyisini seçen **sprint planı** (proaktif). İkisi de aynı motoru (`week3`) kullanır; ayrı bir "tahmin motoru" yoktur.

**Dağıtım kuralı** (kod: `a8plan.py`, `alloc_p8` ve `assign_e8`). Atama anı: sprint başı, her hafta başı ve bir kartın aşaması bittiği her an (kişi boşalır, kural o anda yeniden çalışır). Her satır (Tasarım, Yazılım, Test) için, boşta olan kişilerle:

1. **Ufuk.** Her kartın o aşaması için "en geç ne zamana kadar bitmeli" bulunur. Kart, başka iş yokmuş gibi her aşamada kadro tavanı kadar en iyi uygun kişiyle (gereksinimi karşılayanlarla) bitirilirse ne kadar sürer? Bu süre bu sprinte sığıyorsa ufuk sprintin sonudur; sığmıyorsa kartın bitebileceği ilk sprintin sonudur (Erdem'in büyük kartı için 4. haftanın sonu). Aşamaya, kartın kalan işindeki payı kadar süre düşer.
2. **En az kişilik ekip.** Kartlar **plan sırasıyla** dolaşılır. Her karta, aşamasını ufkunda bitirecek hızı tutturan **en az kişilik** ekip ayrılır (kartta zaten çalışanlar sayılır; %5 pay vardır, bir tutam eksikle bir kişi fazlaya sıçranmasın diye). Boşta kimse kalmadıysa sıradaki kartlar bekler; kişi boşalınca yine plan sırasıyla dolar. Büyük kart herkesi toplamaz: yalnız ufkunu tutturacak kadarını alır.
3. **Kimse boşta kalmaz.** Ekipler kurulunca artan kişiler kartları plan sırasıyla kadro tavanına kadar doldurur (kartı hızlandırır). Yalnız gereksinimi karşılamayan kişi boşta kalabilir.
4. **İlke (Karar 19).** Gereksinimin altındaki kişi hiçbir adımda karta girmez. Ekipler belirlendikten sonra, kartların ufuk hızını bozmayan yer değişimleriyle daha karmaşık kartın (puan × gereksinim büyük olan) ekibi daha iyi kişilerden olur, basit kart zayıfları alır. Yani ilke "aynı plan amacını tutan seçenekler arasında" işler; plan amacı ilkenin önündedir.
5. **Satır seçimi.** Birden çok işi yapabilen kişi (kurucu, testi de yapan geliştirici) önce ihtiyacı karşılanmamış kartın satırına girer; "asıl işi" olan kişi ikincil işi olan kişiden önce yerleşir. Böylece "herkes büyük kartın yazılımına yığıldı, biten kartın testini yapan yok" olmaz.
6. **Kalır.** Kişi bir kartın aşamasına girince aşama bitene kadar orada kalır (sprint ve hafta sınırını aşar). Kural bunu bilerek kurar: ekip büyüklüğü ve ufuk, kimin ne kadar süre kilitleneceğini hesaba katar (§4.1'deki "saklamalı" seçenekler).

**Sprint planı** (kod: `week8`, `decide`, `rollout`). Her hafta başında (sprint başı ve 2. hafta başı) planlayıcı, dağıtım kuralının **8 seçeneğini** o haftadan sprint sonuna aynı motorla ileri oynatır (kopya kartlar, gerçek puanlar, gerçek hata zarı akışı, çekme kuralı dahil) ve **plan puanına** göre en iyisini seçer:

| Seçenek | Anlamı |
|---|---|
| ufuk payı 1,0 / 0,7 / 0,45 | Aşama ufkun tamamını (tam zamanında), %70'ini ya da %45'ini kullanacak şekilde boyutlanır; pay küçüldükçe karta daha çok kişi girer, kart daha erken biter, daha az kart aynı anda yürür. |
| kadro tavanı | Kartlar plan sırasıyla kadro tavanı kadar kişi alır (R'nin doldurması gibi, ama gereksinime uyar). |
| T_plan | Tarifin 1. adımı plan sırasıyla (A6 tanı kolu). |
| ufuk payı 1,0 / 0,45 / kadro tavanı, **saklamalı** | Yukarıdakilerin, asıl işi başka satırda sprintte hâlâ bekleyen ikincil kişiyi (örneğin Yazılım satırında testçi) o satıra kilitlemeyen hâli. |

Plan puanı sırayla: (a) sprintte bitirilen kartlar, plan sırasına göre ağırlıklı (her sıra bir öncekinin %85'i; 8'den fazla kartlı planda düşüş yumuşatılır ki ilk 8 sıranın toplam düşüşü planın uzunluğundan bağımsız kalsın ve büyük ekibin sondaki kartları da sayılsın); (b) boşta kalan insan-hafta (aradaki fark kapasitenin %3'ünün altındaysa "aynı"); (c) ilerleme (%2 altında "aynı"); (d) eşitlikte **ilke puanı** (iş × kartın karmaşıklığı × kişinin yıldızı toplamı büyük olan). Seçilen seçeneğin yer değişimli hâli, yer değişimsiz hâline göre plan puanında gerçekten kötüyse yer değişimsiz hâl seçilir (ilke yalnız eşitlikte işler). Söz kartı plan sırasında zaten öndedir (öneri sırası, Karar 12) ve ayrıca öne alınmaz (Karar 20).

**Tahmin = sonuç.** Plan oynatması (sprint planı ekranındaki tahmin) ve gerçek oynatma aynı fonksiyonu çalıştırır. Hafta başı seçimi durumun bir imzasına (kartların ilerlemesi, kişilerin hızları, kimin nerede kilitli olduğu) bağlı olarak saklanır: plan oynatması seçimi hesaplar, gerçek oynatma aynı durumu görünce aynı seçimi kullanır (hesaplamadan). Durum plandan sapmışsa (örneğin biri plandan yavaş çalışmışsa) imza tutmaz ve planlayıcı o hafta seçimi yeniden hesaplar: **reaktif yeniden kurma** budur (§6, tepki testi). Kuralın içinde rastgelelik yoktur; hata zarı kartın kimliğine bağlı ayrı akıştır ve planlayıcı onu atama kararına sokmaz.

### 4.2 Plan süresi

Bir sprint planı hafta başı iki seçim yapar (sprint başı ve 2. hafta başı); her seçimde 8 seçenek ve yer değişimli/değişimsiz karşılaştırması için bir ek oynatma, yani **sprint başına yaklaşık 18 oynatma** (seçilen seçenek T_plan ise yer değişimi karşılaştırması yapılmaz; tek kişilik ekipte seçenek olmadığı için 0). Oynatmalar kalan süreyi oynatır (ilk seçimde sprintin tamamı, ikincisinde yarısı). Süre bu makinede, Python'da, tek işlemcide ölçüldü (oyunun kendi dilinde farklı olur; Godot koşturulmadı, §7):

| Ekip | Arz | oynatma / sprint | plan süresi (sn / sprint) | tek oynatma (ms) |
|---|---|---|---|---|
| 1 | sınırsız | 0.0 | 0.000 | 0.0 |
| 1 | kaynaklı | 0.0 | 0.000 | 0.0 |
| 3 | sınırsız | 18.0 | 0.011 | 0.6 |
| 3 | kaynaklı | 18.0 | 0.017 | 0.9 |
| 6 | sınırsız | 17.9 | 0.028 | 1.6 |
| 6 | kaynaklı | 17.9 | 0.034 | 1.9 |
| 12 | sınırsız | 17.8 | 0.059 | 3.3 |
| 12 | kaynaklı | 17.8 | 0.066 | 3.7 |
| 25 | sınırsız | 17.7 | 0.187 | 10.5 |
| 25 | kaynaklı | 17.7 | 0.216 | 12.2 |
| 50 | sınırsız | 17.7 | 0.531 | 29.9 |
| 50 | kaynaklı | 17.8 | 0.573 | 32.3 |

Oyunun plan ekranı her "+" tıklamasında yeniden hesaplar. Bu hesabın üç parçası var: kartın sprinte girip girmeyeceğini bakan alım sınaması (R ve Tarif'te de aynı, burada ölçülmedi), tahmin oynatması ve P'nin seçimi. P'nin payı yukarıdaki tablodur; ileri oynatmasız hafif kip (`P_sabit`, tek seçenek, tek oynatma) ne kazandırıp ne kaybettirdiği §4.3'te.

### 4.3 Ne işe yarıyor: kapatarak ölçüm

Aynı 20 tohum, 3, 6 ve 12 kişi (sınırsız ve kaynaklı arz). `P_sabit` = ileri oynatma yok (her hafta tek seçenek: ufuk payı 1,0, yer değişimli); `P_core5` = saklama seçenekleri yok (5 seçenek); `P_ns` = ileri oynatma yok ve yer değişimi yok; `P_np` = "kalır" kapalı (tanı); `T_plan_np` = T_plan'ın "kalır" kapalı hâli (tanı).

*MVP haftası*

| Kol | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| R (bugünkü kural) | 4.0 | 4.0 | 2.2 | 4.0 | 2.4 | 2.3 |
| T_plan (tanı kolu) | 4.0 | 4.0 | 2.2 | 4.0 | 4.0 | 3.9 |
| T_plan, "kalır" kapalı (tanı) | 4.0 | 4.0 | 2.3 | 4.0 | 2.6 | 3.7 |
| **P (yeni planlayıcı)** | 4.0 | 2.2 | 2.1 | 4.0 | 2.2 | 2.1 |
| P, ileri oynatma yok (tek seçenek) | 4.0 | 4.0 | 2.7 | 4.0 | 4.0 | 2.3 |
| P, saklama seçeneği yok | 4.0 | 4.0 | 2.1 | 4.0 | 4.0 | 2.3 |
| P, ileri oynatma ve yer değişimi yok | 4.0 | 4.0 | 2.7 | 4.0 | 4.0 | 2.3 |
| P, "kalır" kapalı | 4.0 | 2.4 | 2.1 | 4.0 | 2.2 | 2.0 |

*Açık hata*

| Kol | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| R (bugünkü kural) | 8.3 | 8.3 | 9.6 | 14.5 | 8.8 | 8.4 |
| T_plan (tanı kolu) | 8.3 | 8.3 | 9.5 | 14.2 | 8.3 | 8.1 |
| T_plan, "kalır" kapalı (tanı) | 8.4 | 8.2 | 9.5 | 15.0 | 8.4 | 8.1 |
| **P (yeni planlayıcı)** | 8.2 | 8.2 | 9.3 | 10.9 | 7.7 | 7.3 |
| P, ileri oynatma yok (tek seçenek) | 8.5 | 9.2 | 9.6 | 10.9 | 8.4 | 8.0 |
| P, saklama seçeneği yok | 8.2 | 8.2 | 9.1 | 10.9 | 7.7 | 7.6 |
| P, ileri oynatma ve yer değişimi yok | 8.5 | 8.8 | 9.9 | 10.9 | 8.4 | 7.8 |
| P, "kalır" kapalı | 8.1 | 8.0 | 9.2 | 10.5 | 7.3 | 7.0 |

*Teslim (puan/hf)*

| Kol | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| R (bugünkü kural) | 20.7 | 49.0 | 109.0 | 19.7 | 47.6 | 101.5 |
| T_plan (tanı kolu) | 20.6 | 49.2 | 107.4 | 20.6 | 47.8 | 99.4 |
| T_plan, "kalır" kapalı (tanı) | 20.6 | 49.4 | 108.0 | 20.1 | 47.4 | 99.8 |
| **P (yeni planlayıcı)** | 20.5 | 49.5 | 107.2 | 21.2 | 47.9 | 100.0 |
| P, ileri oynatma yok (tek seçenek) | 20.4 | 49.5 | 106.7 | 21.3 | 47.5 | 99.1 |
| P, saklama seçeneği yok | 20.5 | 49.6 | 107.5 | 21.2 | 48.1 | 100.2 |
| P, ileri oynatma ve yer değişimi yok | 20.4 | 49.7 | 107.2 | 21.3 | 47.2 | 99.3 |
| P, "kalır" kapalı | 20.5 | 49.8 | 107.7 | 21.6 | 48.1 | 100.1 |

*Kaçan söz (kaynaklı arz)*

| Kol | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|
| R (bugünkü kural) | 17.7% | 1.1% | 0.0% |
| T_plan (tanı kolu) | 14.9% | 1.9% | 0.0% |
| T_plan, "kalır" kapalı (tanı) | 15.7% | 1.4% | 0.0% |
| **P (yeni planlayıcı)** | 18.1% | 1.3% | 0.2% |
| P, ileri oynatma yok (tek seçenek) | 20.3% | 6.3% | 0.0% |
| P, saklama seçeneği yok | 18.1% | 2.6% | 0.3% |
| P, ileri oynatma ve yer değişimi yok | 20.3% | 7.4% | 0.5% |
| P, "kalır" kapalı | 17.4% | 3.3% | 0.0% |

*Doğan hata*

| Kol | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| R (bugünkü kural) | 33.2 | 61.0 | 127.5 | 45.5 | 91.2 | 170.7 |
| T_plan (tanı kolu) | 33.0 | 57.5 | 124.0 | 47.6 | 84.7 | 171.1 |
| T_plan, "kalır" kapalı (tanı) | 33.0 | 58.4 | 123.4 | 47.9 | 85.1 | 168.6 |
| **P (yeni planlayıcı)** | 33.5 | 58.2 | 123.0 | 48.2 | 87.2 | 164.1 |
| P, ileri oynatma yok (tek seçenek) | 32.5 | 58.5 | 122.6 | 47.0 | 84.2 | 167.3 |
| P, saklama seçeneği yok | 33.5 | 58.1 | 121.2 | 48.2 | 83.0 | 165.2 |
| P, ileri oynatma ve yer değişimi yok | 32.5 | 58.4 | 122.0 | 47.0 | 85.8 | 167.7 |
| P, "kalır" kapalı | 31.7 | 57.6 | 119.0 | 47.0 | 81.4 | 166.6 |

Eşli farklar (bir seçeneğin ya da adımın etkisi; her satır a − b):

*MVP haftası*

| Fark (a − b) | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| P − P_sabit | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -0.6 ± 0.2 (6/20) | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -0.2 ± 0.1 (2/20) |
| P − P_core5 | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -0.2 ± 0.1 (2/20) |
| P_sabit − P_ns | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) |
| P − P_np | +0.0 ± 0.0 (0/20) | -0.2 ± 0.1 (2/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.1 ± 0.1 (0/20) |
| T_plan − T_plan_np | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -0.1 ± 0.1 (1/20) | +0.0 ± 0.0 (0/20) | +1.4 ± 0.2 (0/20) | +0.2 ± 0.1 (0/20) |

*Açık hata*

| Fark (a − b) | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| P − P_sabit | -0.3 ± 0.2 (11/20) | -1.0 ± 0.3 (15/20) | -0.3 ± 0.3 (11/20) | +0.0 ± 0.4 (9/20) | -0.7 ± 0.2 (14/20) | -0.7 ± 0.2 (14/20) |
| P − P_core5 | +0.0 ± 0.0 (0/20) | -0.0 ± 0.3 (4/20) | +0.2 ± 0.3 (8/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.1 (7/20) | -0.3 ± 0.2 (10/20) |
| P_sabit − P_ns | +0.0 ± 0.0 (0/20) | +0.3 ± 0.2 (4/20) | -0.2 ± 0.4 (9/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.2 (7/20) | +0.2 ± 0.3 (6/20) |
| P − P_np | +0.1 ± 0.2 (8/20) | +0.2 ± 0.3 (8/20) | +0.1 ± 0.2 (8/20) | +0.5 ± 0.3 (7/20) | +0.4 ± 0.1 (3/20) | +0.3 ± 0.2 (4/20) |
| T_plan − T_plan_np | -0.1 ± 0.1 (7/20) | +0.1 ± 0.3 (7/20) | +0.0 ± 0.2 (7/20) | -0.8 ± 0.7 (13/20) | -0.2 ± 0.3 (11/20) | -0.1 ± 0.2 (7/20) |

*Teslim (puan/hf)*

| Fark (a − b) | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| P − P_sabit | +0.1 ± 0.2 (5/20) | -0.1 ± 0.2 (7/20) | +0.6 ± 0.3 (4/20) | -0.1 ± 0.2 (10/20) | +0.4 ± 0.3 (7/20) | +0.8 ± 0.3 (4/20) |
| P − P_core5 | +0.0 ± 0.0 (0/20) | -0.2 ± 0.2 (7/20) | -0.2 ± 0.2 (8/20) | +0.0 ± 0.0 (0/20) | -0.2 ± 0.2 (13/20) | -0.2 ± 0.2 (12/20) |
| P_sabit − P_ns | +0.0 ± 0.0 (0/20) | -0.2 ± 0.2 (7/20) | -0.6 ± 0.3 (9/20) | +0.0 ± 0.0 (0/20) | +0.3 ± 0.2 (10/20) | -0.1 ± 0.4 (10/20) |
| P − P_np | -0.0 ± 0.1 (3/20) | -0.3 ± 0.2 (9/20) | -0.4 ± 0.2 (10/20) | -0.4 ± 0.1 (13/20) | -0.3 ± 0.2 (11/20) | -0.1 ± 0.3 (11/20) |
| T_plan − T_plan_np | -0.1 ± 0.1 (4/20) | -0.1 ± 0.2 (6/20) | -0.6 ± 0.3 (10/20) | +0.5 ± 0.2 (6/20) | +0.4 ± 0.3 (7/20) | -0.4 ± 0.4 (11/20) |

*Doğan hata*

| Fark (a − b) | 3 kişi | 6 kişi | 12 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|
| P − P_sabit | +1.1 ± 1.1 (7/20) | -0.2 ± 2.0 (10/20) | +0.5 ± 1.9 (9/20) | +1.3 ± 1.7 (8/20) | +3.0 ± 1.4 (5/20) | -3.2 ± 2.1 (12/20) |
| P − P_core5 | +0.0 ± 0.0 (0/20) | +0.1 ± 1.6 (7/20) | +1.9 ± 2.4 (5/20) | +0.0 ± 0.0 (0/20) | +4.1 ± 1.3 (4/20) | -1.1 ± 2.0 (12/20) |
| P_sabit − P_ns | +0.0 ± 0.0 (0/20) | +0.1 ± 1.1 (11/20) | +0.6 ± 1.8 (7/20) | +0.0 ± 0.0 (0/20) | -1.6 ± 1.3 (9/20) | -0.3 ± 2.0 (9/20) |
| P − P_np | +1.8 ± 0.9 (5/20) | +0.7 ± 1.5 (9/20) | +4.1 ± 2.4 (6/20) | +1.3 ± 2.0 (8/20) | +5.8 ± 1.3 (2/20) | -2.5 ± 2.3 (11/20) |
| T_plan − T_plan_np | -0.1 ± 0.7 (7/20) | -0.9 ± 1.3 (11/20) | +0.6 ± 1.5 (10/20) | -0.2 ± 2.0 (9/20) | -0.5 ± 2.2 (8/20) | +2.5 ± 2.7 (8/20) |

*Kaçan söz (yalnız kaynaklı arz)*

| Fark (a − b) | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|
| P − P_sabit | -2.2 pp ± 2.8 pp (12/20) | -5.0 pp ± 1.0 pp (15/20) | 0.2 pp ± 0.2 pp (0/20) |
| P − P_core5 | 0.0 pp ± 0.0 pp (0/20) | -1.3 pp ± 0.8 pp (7/20) | -0.1 pp ± 0.4 pp (1/20) |
| P_sabit − P_ns | 0.0 pp ± 0.0 pp (0/20) | -1.0 pp ± 1.6 pp (6/20) | -0.5 pp ± 0.3 pp (2/20) |
| P − P_np | 0.7 pp ± 3.1 pp (5/20) | -2.0 pp ± 1.2 pp (5/20) | 0.2 pp ± 0.2 pp (0/20) |
| T_plan − T_plan_np | -0.8 pp ± 2.4 pp (8/20) | 0.5 pp ± 0.8 pp (3/20) | 0.0 pp ± 0.0 pp (0/20) |

Kapatma ölçümleri (aynı 20 tohum). `P_rp` = tam P, satır seçimi eski kuralla (plan sırasındaki en önde açık satır; "ihtiyaç önde" satır seçimi kapalı):

*P − P_rp* (satır seçiminin etkisi)

| Ölçü | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|---|---|---|---|---|
| MVP haftası | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) |
| açık hata | -0.1 ± 0.1 (2/20) | -0.3 ± 0.2 (10/20) | +0.5 ± 0.2 (5/20) | +0.0 ± 0.2 (6/20) | +0.2 ± 0.2 (8/20) | -3.0 ± 0.5 (18/20) | -0.2 ± 0.2 (10/20) | -0.1 ± 0.2 (10/20) |
| teslim (puan/hf) | -0.1 ± 0.1 (3/20) | -0.3 ± 0.2 (7/20) | -0.2 ± 0.3 (8/20) | -0.1 ± 0.4 (7/20) | -0.4 ± 0.6 (10/20) | +1.0 ± 0.2 (3/20) | +0.0 ± 0.2 (11/20) | +0.1 ± 0.2 (7/20) |
| doğan hata | -0.4 ± 0.3 (4/20) | +0.7 ± 1.3 (8/20) | +0.1 ± 2.4 (7/20) | -0.1 ± 2.3 (8/20) | +2.2 ± 2.3 (6/20) | +3.2 ± 1.4 (3/20) | +1.9 ± 1.8 (10/20) | -0.5 ± 3.1 (11/20) |
| kaçan hata | -0.3 ± 0.2 (5/20) | +0.3 ± 1.0 (10/20) | +0.7 ± 1.6 (10/20) | +0.4 ± 1.7 (7/20) | -3.2 ± 3.3 (11/20) | +1.7 ± 1.4 (6/20) | +4.5 ± 1.1 (3/20) | +0.5 ± 1.9 (10/20) |

**Okuma.** Her adım ayrı ayrı sorulduğunda:

1. **Plan sırası** (T_plan, A6): Tarif'in MVP, söz ve açık hata bedellerinin nedeni. 3 kişide MVP 6,4 → 4,0, kaynaklı 3 kişide açık hata 32,4 → 14,2 (A6 §4.4). P bu sırayı korur.
2. **İleri oynatma** (P − P_sabit; eksi = P lehine MVP, açık hata ve söz için): MVP haftası 6 kişide -1,8 (her iki arzda aynı), 12 kişide -0,6 (sınırsız); açık hata 6 kişide -1,0 (sınırsız), kaynaklı 6 ve 12 kişide -0,7 / -0,7; kaynaklı 6 kişide kaçan söz -5,0 pp; kaynaklı 50 kişide teslim +8,8 puan/hf. Karşılığı: 25 ve 50 kişide sınırsız arzda açık hata P'de +0,5 / +0,7 daha fazla (hafta başı seçim sprint ölçüsüne bakıyor, açık hata sprintten uzun bir şey; A3'ün usta aramasında da aynı yön). 3 kişide ve 25 kişide MVP, söz ve teslimde fark yok.
3. **Saklama seçenekleri** (P − P_core5): 6 kişide MVP haftası -1,8 (her iki arzda); başka hücrede ayırt edilemiyor. Mikro test: Yazılım satırında testçi, asıl işi (test) sprintte beklerken yazılıma kilitlenmez.
4. **Satır seçimi** ("ihtiyaç önde", P − P_rp): kaynaklı 3 kişide açık hata -3,0 ± 0,5 (18/20), teslim +1,0 ± 0,2 (3/20); başka hücrede ayırt edilemiyor. Erdem'in örneğinde (§2) küçük kartların testinin sprint içinde yapılabilmesi buna bağlı: eski satır seçimiyle (`P_rp`) iz 1'de küçük kartlar h3,18'de, ikinci sprintte biter, çünkü geliştiriciler büyük kartın yazılımını sürdürür ve biten kartların testi onun bitmesini bekler; ihtiyaç önde kuralıyla h1,80 ve h1,87'de, ilk sprintte biter.
5. **Yer değişimi** ("karmaşık kart daha iyi kişilere", `P_sabit` − `P_ns`; ikisi de ileri oynatmasız ve satır seçimi aynı): doğan hata 6 / 12 kişide +0,1 ± 1,1 (11/20) / +0,6 ± 1,8 (7/20), 25 / 50 kişide -2,6 ± 2,1 (12/20) / -3,4 ± 3,3 (12/20); teslim, MVP ve açık hatada da fark yok. Yani bu kart verisiyle adımın ölçülebilir ek kazancı yok (§7).
6. **"Kalır"** (P − P_np; T_plan − T_plan_np): T_plan'da "kalır" MVP'yi kaynaklı 6 kişide +1,4 hafta geciktiriyor (T_plan'da kilidi bilen bir şey yok); P'de aynı bedel yok (P − P_np: MVP +0,0; açık hata +0,4, teslim -0,3 puan/hf). Yani kilit P'de küçük bir bedel taşıyor (kaynaklı 3-12 kişide açık hata en çok +0,5, teslim en çok −0,4 puan/hf); planlayıcı kilidi bilerek kurunca T_plan'ın MVP bedeli yok oluyor.
7. **Plan puanı sırası** (`ρ`): 0,5 / 0,85 / 1,0 arasında MVP, açık hata, teslim ve doğan hata ayırt edilemiyor; kaçan söz yalnız ρ = 1,0'da (her kart eşit) biraz kötü (kaynaklı 6 kişide 3,1%, ρ = 0,85'te 1,3%).

| Kol | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi |
|---|---|---|---|
| **P (yeni planlayıcı)** | 18.1% | 1.3% | 0.2% |
| P, plan puanı sırası sert (ρ = 0,5) | 18.6% | 1.4% | 0.0% |
| P, plan puanında her kart eşit (ρ = 1) | 20.8% | 3.1% | 0.0% |

**Hafif kip (ileri oynatmasız P, `P_sabit`) tüm hücrelerde** (aynı dağıtım kuralı, her hafta tek seçenek, plan başına 1 oynatma; plan ekranı her "+" tıklamasında yeniden hesaplarken ucuz yol):

*MVP haftası*

| Kol | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R (bugünkü kural) | 6.3 | 4.0 | 4.0 | 2.2 | 2.2 | 2.0 | 8.5 | 4.0 | 2.4 | 2.3 | 2.0 | 2.0 |
| **P (yeni planlayıcı)** | 6.3 | 4.0 | 2.2 | 2.1 | 2.1 | 2.0 | 8.5 | 4.0 | 2.2 | 2.1 | 2.0 | 2.0 |
| P, ileri oynatma yok (tek seçenek) | 6.3 | 4.0 | 4.0 | 2.7 | 2.1 | 2.3 | 8.5 | 4.0 | 4.0 | 2.3 | 2.1 | 2.0 |

*Açık hata*

| Kol | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R (bugünkü kural) | 6.0 | 8.3 | 8.3 | 9.6 | 9.9 | 12.6 | 8.7 | 14.5 | 8.8 | 8.4 | 8.2 | 10.9 |
| **P (yeni planlayıcı)** | 6.0 | 8.2 | 8.2 | 9.3 | 10.3 | 13.3 | 8.8 | 10.9 | 7.7 | 7.3 | 8.3 | 11.2 |
| P, ileri oynatma yok (tek seçenek) | 6.0 | 8.5 | 9.2 | 9.6 | 9.9 | 12.6 | 8.8 | 10.9 | 8.4 | 8.0 | 8.3 | 11.1 |

*Teslim (puan/hf)*

| Kol | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R (bugünkü kural) | 4.5 | 20.7 | 49.0 | 109.0 | 264.4 | 515.2 | 5.6 | 19.7 | 47.6 | 101.5 | 243.5 | 428.9 |
| **P (yeni planlayıcı)** | 4.5 | 20.5 | 49.5 | 107.2 | 261.6 | 514.5 | 5.6 | 21.2 | 47.9 | 100.0 | 238.5 | 431.2 |
| P, ileri oynatma yok (tek seçenek) | 4.5 | 20.4 | 49.5 | 106.7 | 261.8 | 513.7 | 5.6 | 21.3 | 47.5 | 99.1 | 238.4 | 422.4 |

*Kaçan söz (kaynaklı arz)*

| Kol | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|
| R (bugünkü kural) | 79.6% | 17.7% | 1.1% | 0.0% | 0.0% | 0.0% |
| **P (yeni planlayıcı)** | 79.0% | 18.1% | 1.3% | 0.2% | 0.0% | 0.0% |
| P, ileri oynatma yok (tek seçenek) | 79.0% | 20.3% | 6.3% | 0.0% | 0.0% | 0.0% |

Eşli farklar (P − P_sabit):

*MVP haftası*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − P_sabit | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -0.6 ± 0.2 (6/20) | +0.0 ± 0.0 (0/20) | -0.3 ± 0.2 (3/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.0 (0/20) | -1.8 ± 0.1 (18/20) | -0.2 ± 0.1 (2/20) | -0.1 ± 0.1 (1/20) | +0.0 ± 0.0 (0/20) |

*Açık hata*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − P_sabit | +0.0 ± 0.0 (0/20) | -0.3 ± 0.2 (11/20) | -1.0 ± 0.3 (15/20) | -0.3 ± 0.3 (11/20) | +0.5 ± 0.2 (5/20) | +0.7 ± 0.3 (4/20) | +0.0 ± 0.0 (0/20) | +0.0 ± 0.4 (9/20) | -0.7 ± 0.2 (14/20) | -0.7 ± 0.2 (14/20) | -0.1 ± 0.1 (7/20) | +0.1 ± 0.2 (6/20) |

*Teslim (puan/hf)*

| Fark (a − b) | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P − P_sabit | +0.0 ± 0.0 (0/20) | +0.1 ± 0.2 (5/20) | -0.1 ± 0.2 (7/20) | +0.6 ± 0.3 (4/20) | -0.1 ± 0.5 (10/20) | +0.8 ± 0.7 (7/20) | +0.0 ± 0.0 (0/20) | -0.1 ± 0.2 (10/20) | +0.4 ± 0.3 (7/20) | +0.8 ± 0.3 (4/20) | +0.1 ± 0.5 (10/20) | +8.8 ± 0.6 (0/20) |

*Kaçan söz (yalnız kaynaklı arz)*

| Fark (a − b) | kaynaklı 1 kişi | kaynaklı 3 kişi | kaynaklı 6 kişi | kaynaklı 12 kişi | kaynaklı 25 kişi | kaynaklı 50 kişi |
|---|---|---|---|---|---|---|
| P − P_sabit | 0.0 pp ± 0.0 pp (0/20) | -2.2 pp ± 2.8 pp (12/20) | -5.0 pp ± 1.0 pp (15/20) | 0.2 pp ± 0.2 pp (0/20) | 0.0 pp ± 0.0 pp (0/20) | 0.0 pp ± 0.0 pp (0/20) |

### 4.4 Gereksinim kapısının teslim bedeli

P'nin 12 ve 25 kişide R'ye göre teslim kaybı (-1,8 ± 0,3 (17/20) ve -2,8 ± 0,7 (18/20)) nereden geliyor? Aynı planlayıcıda gereksinim kapısını kaldırınca (`P_gyok`: her kişi her karta girebilir; yalnız tanı için) teslim:

| Kol | 12 kişi | 25 kişi | kaynaklı 12 kişi |
|---|---|---|---|
| R (bugünkü kural) | 109.0 | 264.4 | 101.5 |
| T_plan (tanı kolu) | 107.4 | 261.2 | 99.4 |
| **P (yeni planlayıcı)** | 107.2 | 261.6 | 100.0 |
| P, gereksinim kapısı yok (tanı) | 110.4 | 266.5 | 101.0 |

| Fark (a − b) | 12 kişi | 25 kişi | kaynaklı 12 kişi |
|---|---|---|---|
| P_gyok − R | +1.4 ± 0.3 (1/20) | +2.0 ± 0.4 (1/20) | -0.5 ± 0.3 (12/20) |
| P − R | -1.8 ± 0.3 (17/20) | -2.8 ± 0.7 (18/20) | -1.5 ± 0.3 (17/20) |
| P − P_gyok | -3.1 ± 0.3 (20/20) | -4.8 ± 0.4 (19/20) | -1.0 ± 0.3 (15/20) |

Yani kayıp planlayıcının değil "gereksinimin altındaki kişi o karta girmez" ilkesinin bedeli: kapı kalkınca P, R'nin 12 ve 25 kişide +1,4 ve +2,0 puan/hf üstüne çıkıyor (kapı varken -1,8 ve -2,8). R'de Yazılım işinin 12 kişide 3,6%, 25 kişide 1,4% gereksinimin altındaki kişiye gidiyor; bu iş P'de ya başka kişiye ya da hiçbir kişiye düşüyor. (`P_gyok`'ta hata sayıları karşılaştırılamaz: kapı kalkınca hata modelinin gereksinimi de değişir.)

### 4.5 İlkenin ölçüsü: karmaşık iş kime gidiyor

Teslim edilen özellik kartlarında kartın karmaşıklığı (puan × Yazılım gereksinimi) ile kartın Yazılım işini yapanların iş payı ağırlıklı ortalama yıldızı arasındaki korelasyon ve en karmaşık çeyrekle en basit çeyreğin ortalama yıldız farkı (`a8ilke.py`; 6 ve 12 kişide 8 tohum, 25 kişide 4 tohum; 50 kişi çok yavaş olduğu için bu ölçüde yok; tohum sayısı az olduğundan değerler yön gösterir, tablo gibi okunmamalı):

```
R       S3: karmasiklik-yildiz korelasyonu -0.002 | en karmasik ceyrek ortalama yildiz 2.80, en basit ceyrek 2.54 (fark +0.26) | tohum 8
T       S3: karmasiklik-yildiz korelasyonu 0.553 | en karmasik ceyrek ortalama yildiz 3.10, en basit ceyrek 2.14 (fark +0.96) | tohum 8
T_plan  S3: karmasiklik-yildiz korelasyonu 0.578 | en karmasik ceyrek ortalama yildiz 3.16, en basit ceyrek 2.06 (fark +1.10) | tohum 8
P       S3: karmasiklik-yildiz korelasyonu 0.477 | en karmasik ceyrek ortalama yildiz 3.25, en basit ceyrek 1.98 (fark +1.27) | tohum 8
R       S4: karmasiklik-yildiz korelasyonu -0.094 | en karmasik ceyrek ortalama yildiz 3.02, en basit ceyrek 2.38 (fark +0.64) | tohum 8
T       S4: karmasiklik-yildiz korelasyonu 0.438 | en karmasik ceyrek ortalama yildiz 3.33, en basit ceyrek 2.08 (fark +1.25) | tohum 8
T_plan  S4: karmasiklik-yildiz korelasyonu 0.339 | en karmasik ceyrek ortalama yildiz 3.22, en basit ceyrek 2.19 (fark +1.03) | tohum 8
P       S4: karmasiklik-yildiz korelasyonu 0.498 | en karmasik ceyrek ortalama yildiz 3.50, en basit ceyrek 2.01 (fark +1.49) | tohum 8
R       PR|S3: karmasiklik-yildiz korelasyonu 0.023 | en karmasik ceyrek ortalama yildiz 2.73, en basit ceyrek 2.30 (fark +0.43) | tohum 8
T       PR|S3: karmasiklik-yildiz korelasyonu 0.325 | en karmasik ceyrek ortalama yildiz 2.88, en basit ceyrek 1.78 (fark +1.09) | tohum 8
T_plan  PR|S3: karmasiklik-yildiz korelasyonu 0.195 | en karmasik ceyrek ortalama yildiz 2.88, en basit ceyrek 2.11 (fark +0.77) | tohum 8
P       PR|S3: karmasiklik-yildiz korelasyonu 0.273 | en karmasik ceyrek ortalama yildiz 3.00, en basit ceyrek 1.94 (fark +1.06) | tohum 8
R       PR|S4: karmasiklik-yildiz korelasyonu 0.191 | en karmasik ceyrek ortalama yildiz 3.10, en basit ceyrek 2.37 (fark +0.74) | tohum 8
T       PR|S4: karmasiklik-yildiz korelasyonu 0.234 | en karmasik ceyrek ortalama yildiz 3.13, en basit ceyrek 2.27 (fark +0.85) | tohum 8
T_plan  PR|S4: karmasiklik-yildiz korelasyonu 0.109 | en karmasik ceyrek ortalama yildiz 3.04, en basit ceyrek 2.49 (fark +0.55) | tohum 8
P       PR|S4: karmasiklik-yildiz korelasyonu 0.262 | en karmasik ceyrek ortalama yildiz 3.21, en basit ceyrek 2.27 (fark +0.93) | tohum 8
R       S5: karmasiklik-yildiz korelasyonu 0.044 | en karmasik ceyrek ortalama yildiz 3.07, en basit ceyrek 2.31 (fark +0.76) | tohum 4
T       S5: karmasiklik-yildiz korelasyonu 0.253 | en karmasik ceyrek ortalama yildiz 3.13, en basit ceyrek 2.23 (fark +0.90) | tohum 4
T_plan  S5: karmasiklik-yildiz korelasyonu 0.105 | en karmasik ceyrek ortalama yildiz 3.02, en basit ceyrek 2.30 (fark +0.72) | tohum 4
P       S5: karmasiklik-yildiz korelasyonu 0.372 | en karmasik ceyrek ortalama yildiz 3.24, en basit ceyrek 2.19 (fark +1.04) | tohum 4
R       PR|S5: karmasiklik-yildiz korelasyonu 0.176 | en karmasik ceyrek ortalama yildiz 3.07, en basit ceyrek 2.52 (fark +0.55) | tohum 4
T       PR|S5: karmasiklik-yildiz korelasyonu 0.137 | en karmasik ceyrek ortalama yildiz 3.05, en basit ceyrek 2.60 (fark +0.46) | tohum 4
T_plan  PR|S5: karmasiklik-yildiz korelasyonu 0.062 | en karmasik ceyrek ortalama yildiz 3.02, en basit ceyrek 2.69 (fark +0.33) | tohum 4
P       PR|S5: karmasiklik-yildiz korelasyonu 0.150 | en karmasik ceyrek ortalama yildiz 3.08, en basit ceyrek 2.60 (fark +0.48) | tohum 4
```

Sıfıra yakın korelasyon ilkenin işlemediği, pozitif korelasyon karmaşık işe daha iyi kişilerin gittiği anlamına gelir. Okuma: R'de korelasyon sıfıra yakın (en çok 0,19); P'de her hücrede pozitif (0,15 ile 0,50), sınırsız arzda 12 ve 25 kişide dört kolun en yükseği, 6 kişide Tarif ve T_plan'ın altında ama en karmaşık çeyrekle en basit çeyrek arasındaki yıldız farkı P'de en büyük (1,27); kaynaklı arzda P ile Tarif arasındaki fark küçük.

## 5. Yorum ve [GÖRÜŞ]

Ölçüm ayrı, görüş ayrı: "Ölçüm" satırları yukarıdaki bölümlerden sayıdır, "[GÖRÜŞ]" satırları benim okumamdır, karar Erdem'indir.

1. **Erdem'in 25. maddesindeki durum gerçek ve üç kolda da var.** Ölçüm (§2): 3 geliştirici, büyük kart planda ilk; R, Tarif ve T_plan üç kişiyi birden büyük karta yığıyor, küçük kartlar h2,6'ya kadar bekliyor, hepsi ikinci sprintte bitiyor; büyük kart planın sonundaysa R'de küçük kartların yazılımı biter ama testleri büyük kartın yazılımı bitene kadar yapılmaz (h3,18). P iki kişiyi büyük karta, üçüncüyü küçük kartlara veriyor; küçükler ilk sprintte biter (büyük kart planın başında h1,80 ve h1,87, sonunda h0,93 ve h1,00). [GÖRÜŞ] Çare iki parça: (a) her kart yalnız bitebileceği sprintin ufkunu tutturacak kadar kişi alır (büyük kart herkesi toplamaz); (b) bir kişi bir kartın yazılımını bitirince, o kartın testi büyük bir kartın yazılımına yığılmadan önce yapılır (satır seçimi ihtiyaca göre). İkincisi bu örnekte küçük kartları ilk sprinte sokan şey; ilk parçayla tek başına olmuyor.
2. **MVP'nin 4'ten 6. haftaya kayması "ileriye bakmama"dan çok tarifin sırasından geliyor; ileriye bakma 6 kişide ayrı bir kazanç.** Ölçüm: 3 kişide Tarif 6,4, T_plan 4,0, P 4,0 (§3); ileri oynatmasız P da 4,0. 6 kişide R 4,0, P 2,2, ileri oynatmasız P 4,0: fark saklama seçeneklerinden (asıl işi başka satırda bekleyen testçiyi yazılıma kilitlememek). [GÖRÜŞ] Erdem'in sezgisi (sistem ileriye bakmıyor) iki yerde doğru: tarifin 1. adımı büyük kartı öne alırken kalan işi görmüyor (T_plan'ın çözdüğü şey); "kalır" kilidi birini yanlış yere kilitlediğinde (6 kişi) ancak ileri oynatma görüyor (P'nin çözdüğü şey). 3 kişide ikincisi gerekmedi.
3. **P demo ölçeğinde (3-12 kişi) R'nin yerini alabilir; 12-25 kişide teslimde %1-2 bedeli var ve nedeni ilke.** Ölçüm (§1): 3-12 kişide MVP, açık hata, kaçan söz ve boşta P ile R'de aynı ya da P lehine (kaynaklı 3 kişide açık hata -3,6); teslim 12 / 25 kişide -1,8 / -2,8 puan/hf (R'ye göre -1,7% / -1,1%); 50 kişide R düzeyi. Kayıp gereksinim kapısından (§4.4: kapı kalkınca P, R'nin üstünde). [GÖRÜŞ] Bu bedel Karar 19'un doğrudan sonucu ("gereksinimin altındaki kişi o karta girmez"); karar değişmedikçe P'nin yapabileceği bir şey yok. Kapı yerine "altındaki kişi girebilir ama daha çok hata sokar" modeli (A6'nın negatif Δ eğrisi) başka bir tasarım ve burada ölçülmedi.
4. **İlke işliyor, ama asıl işi kapı ve "en az kişilik ekip" yapıyor; yer değişimi adımı ek kazanç vermiyor.** Ölçüm: gereksinim altı Yazılım işi P'de 0 (R'de 6 / 12 kişide 7,7% / 3,6%); karmaşıklık-yıldız korelasyonu (§4.5) R'de sıfıra yakın (en çok 0,19), P'de her ölçülen hücrede pozitif (0,15-0,50) ve Tarif düzeyinde; yer değişimi kapatılınca (`P_ns`) doğan hata, kaçan hata, açık hata ve teslimde fark yok (§4.3). [GÖRÜŞ] Yer değişimi adımı kodda tutulabilir (maliyeti ihmal edilebilir, ilkeyi plan amacının ardından uygular), ama bugünkü kart verisinde (Yazılım kilidi en çok 2 yıldız, özellik kartlarının çoğu 40 puan) görünür etki beklenmemeli; 3-5 yıldız isteyen kartlar gelince yeniden ölçülmeli.
5. **Hafif kip bir seçenek, ama her yerde değil.** Ölçüm: tam P sprint başına 18 oynatma, 3-12 kişide ≤ 0,07 sn, 50 kişide 0,53 sn (kaynaklı 0,57 sn) Python'da. İleri oynatmasız P (1 oynatma) 6 kişide MVP haftasını tam P'den +1,8 hafta geride bırakıyor, kaynaklı 6 kişide kaçan söz tam P'den 5,0 pp fazla; 25 kişide MVP ve teslimde fark yok, açık hata hafif kip lehine (+0,5 ± 0,2 (5/20)); 50 kişide sınırsız arzda tam P'nin açık hatası hafif kipinkinden +0,7 fazla, kaynaklı arzda tam P teslimde +8,8 puan/hf önde. [GÖRÜŞ] Küçük ekipte (≤ 12 kişi) tam P, hesabı hiç pahalı değil ve kazancı var; büyük ekipte karar oyun içi hesap süresine bağlı (ölçülmedi, §7). Plan ekranında gösterilen tahmin ile uygulanan plan aynı kipi kullanmalı; ekranda hafif kip, uygulamada tam P "tahmin = sonuç"u bozar.
6. **"Kalır" P ile pahalı değil, ama oyuncuya görünmeli.** Ölçüm: P'de kalır kapatılınca MVP, teslim ve açık hata fark etmiyor (§4.3: P − P_np açık hata kaynaklı 3 / 6 / 12 kişide +0,5 / +0,4 / +0,3, teslim -0,4 / -0,3 / -0,1); aynı kilit T_plan'da MVP'yi kaynaklı 6 kişide +1,4 hafta geciktiriyor. [GÖRÜŞ] Planlayıcı kilidi kuralın içinde bilerek kuruyor; oyuncu ekranda "kim hangi kartın hangi aşamasına kilitli ve ne zaman çıkacak" satırını görmeli, yoksa plan oyuncuya bir kara kutu olur (UI işi, bu belgenin dışı).
7. **GDD'ye yazılacak tek cümle.** [GÖRÜŞ] "Her kart, bitebileceği ilk sprintte biter; o sprintte ona yetecek en az sayıda kişi girer, kalan kişiler plan sırasındaki öbür kartlara gider; kişi kartın aşamasında aşama bitene kadar kalır." Bu cümle Erdem'in 25. maddesindeki örneği ve "2 kişi, 2 sprint" fikrini tarif ediyor.

**Erdem'e iki sade soru.**

- *Gereksinim kapısı teslimi düşürmeye değer mi?* Örnek: 12 kişilik ekipte bugünkü kural (R) Yazılım işinin 3,6% kadarını gereksinimi karşılamayan kişiye veriyor; P vermiyor. Kapıyı kaldırmak (`P_gyok`) 12 kişide teslimi haftada +3,1 puan (+2,9%) artırıyor, 25 kişide +4,8 puan (+1,9%); karşılığında gereksinimin altındaki kişi hata oranı yüksek işi yapıyor (A6'nın modeli: gereksinimin 1 yıldız altı, oranı 0,14'ten 0,28'e çıkarır). (A) Kapı kalsın (Karar 19 aynen; bedel 12-25 kişide teslimin yaklaşık %1-3'ü). (B) Kapı yumuşasın: altındaki kişi girebilir, hata oranı yüksek; teslim R düzeyine çıkar, doğan hata artar. Benim önerim (A); (B) ayrı bir tasarım adımı.
- *Plan sırasındaki ilk kart hep ilk bitmek zorunda mı?* Örnek: sprintte büyük kart ilk, iki küçük kart sonra. (A) Plan sırası kimin ilk bitireceğini değil kimin önce kişi alacağını belirler; büyük kart yalnız ufkunu tutturacak kadar kişi alır, küçükler önce biter (P). (B) İlk kart herkesi alır, sırayla biter (bugünkü R). Ölçüm (A)'yı destekliyor: iki küçük kart bir sprint erken teslim oluyor, büyük kart 0,18 hafta geç, toplam iş aynı. Karar Erdem'in.

## 6. Doğrulama

| Doğrulama | Beklenen | Bulunan | Sonuç |
|---|---|---|---|
| Regress: planlayıcı kodu yüklü, atama kipi "p8" değilken R, Tarif (K-H ve bugünkü hata modeli) ve T_plan kolları A6'nın kayıtlarıyla (S1-S6 ve kaynaklı S2-S4, ilk 5 tohum; 25 ve 50 kişide 1 tohum) | 0 fark | 10.730 metrik, 0 fark (`out8/a8_regress.txt`) | GEÇTİ |
| Planlayıcı kodunun son hâliyle kayıtlı P ve P_sabit sonuçlarının yeniden koşusu (3 tohum × 8 hücre) | 0 fark | 1.176 metrik, 0 fark (`out8/a8_tekrar.txt`) | GEÇTİ |
| P_r85 (P'nin aynı ayarı, ayrı koşu) = P | 0 fark | 5.400 metrik, 0 fark (`out8/a8_dogrula.txt`) | GEÇTİ |
| Mikro testler: Erdem'in örneği (büyük kart 2 kişi, küçük kart 1 kişi, 3. kart bekler); büyük iş 2 kişiye sığmayınca 3 kişi; gereksinimin altındaki kişi girmez; karmaşık karta en iyi kişi (yer değişimi); plan sırası ve havuz bitince bekleme; saklama; `t_full`; `_pick_crew` (tek yeten en zayıf, en küçük toplamlı yeten çift, yetmeyen istek) | 12/12 | 12/12 (`out8/a8_micro.txt`) | GEÇTİ |
| Sahte bozma (testler boş değil): gereksinim kapısı kapatılınca, yer değişimi kapatılınca, saklama etkisizleştirilince, tek yeten kişi hep en güçlü seçilince | her bozmada en az 1 mikro vaka düşmeli | düşen vaka sayısı 2 / 1 / 1 / 1; bozmasız 0 (`out8/a8_falsify.txt`) | GEÇTİ |
| Tahmin = sonuç | ≤ 1e-6 | 1.620 koşunun (81 dosya, 20 tohum) hepsinde en büyük fark 7,1e-15 | GEÇTİ |
| P'de hafta başı seçimi gerçek oynatmada plan oynatmasından önbellekle gelir (durum aynıysa) | her koşuda önbellek isabeti × 2 = hafta başı sayısı | ihlal eden koşu 0 | GEÇTİ |
| Tepki: Erdem'in örneğinde gerçek oynatmada hız sapması yok | iki hafta da önbellekten, ilerleme plan = gerçek | 2/2 hafta önbellekten; ilerleme [55,543; 10,5; 10,5] ikisinde de | GEÇTİ |
| Tepki: A'nın hızı 2. haftada %40 düşük (plan bilmiyordu) | o hafta önbellek tutmaz, planlayıcı yeniden kurar | 1 hafta önbellekten, 1 hafta yeniden kuruldu; gerçek ilerleme [51,04; 10,0; 10,0] (plan [55,543; 10,5; 10,5]) | GEÇTİ |
| "Kalır": hafta sonunda aşaması süren kartta olan kişi sonraki hafta başı aynı kartta (S4, tohum 1) | P'de 0 değişim | P: sprint içi 0/166, sprint sınırı 0/151; R: 90/171 ve 67/149 | GEÇTİ |
| Determinizm: aynı hücre iki kez | aynı sonuç | aynı (`a8test.py determ`) | GEÇTİ |
| Gereksinimin altındaki Yazılım işi P kollarında | 0 | 0 koşuda var; R'de 6 / 12 / 25 / 50 kişide 7,7% / 3,6% / 1,4% / 2,4% | GEÇTİ |
| Bulunan hata ≤ doğan hata | 0 ihlal | 0 | GEÇTİ |
| Her hücrede 20 tohum | 20 | 81 dosyanın hepsinde 20 | GEÇTİ |

Ham çıktılar `out8/`'de: `a8_regress.txt`, `a8_micro.txt`, `a8_falsify.txt`, `a8_react.txt`, `a8_kalir.txt`, `a8_determ.txt`, `a8_dogrula.txt`, `a8_secim.txt`.

**Tepki testinin ham çıktısı** (Erdem'in örneği; gerçek oynatmada 2. hafta A'nın hızı %40 düşük; tablo kişi başına süre, h = hafta):

```
-- sapma_yok onbellekten gelen hafta 2 yeniden kurulan hafta 0 | gercek ilerleme [55.543, 10.5, 10.5] | plan ilerlemesi [55.543, 10.5, 10.5]
  A        h0.00-h2.00 Buyuk (Yazilim)
  B        h0.00-h0.86 Kucuk1 (Yazilim); h0.86-h1.72 Kucuk2 (Yazilim); h1.72-h1.80 Kucuk1 (Test); h1.80-h1.87 Kucuk2 (Test); h1.87-h2.00 Buyuk (Yazilim)
  C        h0.00-h2.00 Buyuk (Yazilim)
-- sapma onbellekten gelen hafta 1 yeniden kurulan hafta 1 | gercek ilerleme [51.04, 10.0, 10.0] | plan ilerlemesi [55.543, 10.5, 10.5]
  A        h0.00-h2.00 Buyuk (Yazilim)
  B        h0.00-h0.86 Kucuk1 (Yazilim); h0.86-h1.72 Kucuk2 (Yazilim); h1.72-h2.00 Buyuk (Yazilim)
  C        h0.00-h2.00 Buyuk (Yazilim)
REACT GECTI
```

**Hangi seçenek kazanıyor** (`a8sec.py`, ilk 3 tohum, hafta başı seçim sayısı ve payı): tek bir seçenek baskın değil, bu yüzden aramanın bir işi var.

```
S2 secim sayisi 180 | yer degisimsiz secilen 0 | ufuk payi 1.00 129 (%72), kadro tavani 27 (%15), ufuk payi 0.70 16 (%9), ufuk payi 0.45 8 (%4)
S3 secim sayisi 180 | yer degisimsiz secilen 0 | kadro tavani 57 (%32), ufuk payi 1.00 45 (%25), ufuk payi 0.70 22 (%12), kadro tavani + saklama 19 (%11), ufuk payi 0.45 17 (%9), ufuk payi 1.00 + saklama 13 (%7), T_plan 4 (%2), ufuk payi 0.45 + saklama 3 (%2)
S4 secim sayisi 180 | yer degisimsiz secilen 1 | ufuk payi 1.00 52 (%29), kadro tavani 30 (%17), T_plan 25 (%14), ufuk payi 0.45 21 (%12), kadro tavani + saklama 18 (%10), ufuk payi 0.70 17 (%9), ufuk payi 1.00 + saklama 11 (%6), ufuk payi 0.45 + saklama 6 (%3)
S5 secim sayisi 180 | yer degisimsiz secilen 3 | kadro tavani + saklama 42 (%23), ufuk payi 1.00 29 (%16), T_plan 27 (%15), kadro tavani 24 (%13), ufuk payi 0.45 + saklama 17 (%9), ufuk payi 0.45 15 (%8), ufuk payi 0.70 15 (%8), ufuk payi 1.00 + saklama 11 (%6)
PR|S3 secim sayisi 240 | yer degisimsiz secilen 0 | ufuk payi 1.00 76 (%32), kadro tavani 44 (%18), ufuk payi 1.00 + saklama 31 (%13), ufuk payi 0.70 30 (%12), kadro tavani + saklama 22 (%9), ufuk payi 0.45 17 (%7), T_plan 11 (%5), ufuk payi 0.45 + saklama 9 (%4)
```

## 7. Bitmeyenler ve sınırlar

- **Arama yalnız hafta başında ve yalnız kuralın 8 seçeneği arasında.** Aşama bitişlerinde (olay düzeyinde) seçenek karşılaştırması ve kişi başına yerleşim araması yapılmadı. A3'ün usta oyuncu araması (kişi → kart tercih listeleri üzerinde yerel arama, sprint başına 33-123 oynatma) sprint ölçüsünü iyileştirdi ama 60 haftalık sonucu R ve tarifin üstüne çıkarmadı (A3 §2.3); bu yüzden aynı yönde bir olay düzeyi aramayı yazmadım. [DEĞERLENDİREMEM]: olay düzeyinde bir arama 3 kişide MVP'yi 4. haftadan öne çekebilir mi, ölçülmedi.
- **Seçenek kümesi elle seçildi.** 8 seçenek (ufuk payı 1,0 / 0,7 / 0,45, kadro tavanı, T_plan, üçü saklamalı); başka seçenek kümeleri (örneğin satır başına ayrı seçenek, 0,7'li saklama) denenmedi. Plan puanının sırası (`ρ`), bosta ve ilerleme toleransları (%3, %2) koşulardan önce ben seçtim; yalnız `ρ` için 0,5 / 0,85 / 1,0 karşılaştırması var (§4.3) ve fark yok denecek kadar küçük; tolerans duyarlılığı ölçülmedi.
- **Çok sprintli ufuk kural düzeyinde.** Kartın "bitebileceği ilk sprint" hesabı var (Erdem'in 2 sprintlik büyük kartı), ama sprint planı ileri oynatması yalnız bu sprinti oynatır; ikinci sprintte kimin ne yapacağını aramaz. Çok sprintli ileri oynatma, A3'ün de belirttiği gibi, 60 haftalık sonuçta kazanç göstermedi ve maliyeti sprint sayısıyla katlanır.
- **Simülasyonda kâğıt, acil durum, söz olayı ve işe alım/ayrılış yok** (A3, A6 ile aynı). Reaktif katmanın bu olaylarla etkileşimi ölçülmedi; yalnız "kişi plandan yavaş" sapması denendi (§6, tepki testi). Oyundaki acil durum "sprinti durdur" hattın düzeltme kartını sprintin başına alır (`CLAUDE.md` §6 Acil durum): planlayıcı kartı sıradan bir kart olarak görür ve kalan haftayı yeniden kurar; bu yolun kendisi bu belgede simüle edilmedi.
- **"Kalır" kilidi ve oyun içi acil kart.** Kişi aşama bitene kadar kilitli; acil bir kart (düzeltme, söz olayı) sprint ortasında gelirse kilitli kişiler o anda alınamaz, yalnız boşalanlar kullanılır. P'nin kuralı bunu bilerek kuruyor (saklama seçenekleri, ufuk hesabı) ama acil kartın kendisi simülasyonda yok.
- **Oyun içi hesap süresi ölçülmedi.** Godot koşturulmadı; yukarıdaki süreler Python'dadır. Oyunun kendi dilinde (GDScript) bir oynatmanın maliyeti farklıdır; hafif kip (`P_sabit`, tek oynatma) bu yüzden ayrıca ölçüldü. Plan ekranı yeniden hesabında alım sınaması (R ve Tarif'te de var) ayrıca maliyet katar, burada ölçülmedi.
- **Yer değişimi (ilke) adımının ölçülebilir etkisi yok.** `P_sabit` − `P_ns` (§4.3): doğan hata, kaçan hata, açık hata ve teslimde 20 tohumda ayırt edilemiyor. Nedeni büyük olasılıkla kartların karmaşıklık farkının küçüklüğü (A6 §5: Yazılım kilidi en çok 2 yıldız, özellik kartlarının çoğu 40 puan) [GÖRÜŞ]; kart verisi genişleyince (3-5 yıldız isteyen kartlar) adımın etkisi büyüyebilir, o zaman yeniden ölçülmeli.
- **PM tarafı** A6'nın (i) okuması aynen (en karmaşık kart en iyi PM'e, en basit kart en zayıf PM'e); planlayıcı PM'i seçenek aramasına katmıyor. PM hazırlığı sprint içinde bağımsız işler.
- **Test yakalaması** (karmaşık kartı en iyi testçi) ölçülmedi (A6 §7 ile aynı).
- **Hata zarı planı bilir.** Plan oynatması ile gerçek oynatma aynı kart kimliğinden aynı zar akışını çeker (A3 ve A6'nın "tahmin = sonuç" tanımı); planlayıcı zarın sonucunu atama kararında kullanmaz ama rollout'lar (ileri oynatmalar) test bitişinde çıkan düzeltme işini görür. Oyunda zar test bitince atılır; plan o an yeniden kurulur, bu da kural olarak mümkün (imza tutmaz); ayrıca ölçülmedi.
- **Gürültü.** 20 tohum; ayırt edilemeyen farklar yukarıda belirtildi. Ablasyon tabloları 3, 6, 12 kişide (P_sabit tüm hücrelerde, P_ns ve P_rp 25-50 kişide de); P_np ve P_core5 yalnız 3, 6, 12 kişide; P_gyok yalnız 12 ve 25 kişide.

## 8. Yeniden üretim

Klasör: `docs/tasks/faz_cde/d_taslak/dsim/v3/atama/`. Hepsi `python -I`, en çok 2 işçi, her python çağrısı 9 dakikanın altında (`chain8.sh` 420 sn bütçeli çağrıları eksik iş kalmayana dek tekrarlar; sonuçlar önbellekli).

```
python -I a8test.py micro ; python -I a8test.py falsify ; python -I a8test.py react ; python -I a8test.py determ ; python -I a8test.py kalir
python -I a8test.py regress 5            # a8plan yüklü, p8 kapalı: R, T, T_plan A6 kayıtlarıyla 0 fark
bash run_a8.sh                           # H1 P (12 hücre, 20 tohum) · H2 ablasyon (P_sabit, P_core5, P_ns, P_np; 6 hücre) · H3 P_gyok
bash run_a8d.sh ; bash run_a8e.sh ; bash run_a8f.sh   # H4-H5 P_sabit tüm hücreler, P_ns büyük ekipler (ilk koşu satır seçimi kuralını yanlış taşıdığı için H8'de yeniden koşuldu) · H6 ρ duyarlılığı · H7 T_plan_np
bash run_a8g.sh                          # H8 P_ns (ileri oynatma ve yer değişimi yok; 10 hücre) · H9 P_rp (satır seçimi eski kural; 8 hücre)
bash chain8.sh ana H P_r5 "S2,S3,S4,PR|S2,PR|S3,PR|S4" 20   # ρ = 0,5
python -I a8test.py tekrar               # kayıtlı P sonuçları son kodla yeniden koşulunca aynı mı
python -I a8sec.py "S2,S3,S4,S5,PR|S3" 3 > out8/a8_secim.txt ; python -I a8dbg.py S2 1 P 2   # hangi seçenek kazanıyor ; bir tohumda seçenek puanları
python -I a8ilke.py S4 8 ; python -I a8ilke.py "PR|S5" 4    # ilke ölçüsü (out8/a8_ilke.txt)
python -I a8test.py dogrula              # tohum sayısı, tahmin = sonuç, gereksinim altı iş, bulunan <= doğan
python -I a8iz.py iz1 R,T,T_plan,P,P_rp > out8/iz1.txt ; python -I a8iz.py iz1b R,T,P > out8/iz1b.txt ; python -I a8iz.py iz2 S2 1 R,T,T_plan,P > out8/iz2.txt
python -I a8rapor.py                     # bu belge (ATAMA/A8_PROAKTIF_PLAN.md), a8_metin.md ve a8_parcalar/ şablonlarından
```

Tek hücre: `python -I a8run.py one P S3 1 H` (kol, senaryo, tohum, kalibrasyon). Kollar (`a8run.py`, `ARMS`): `P` ana planlayıcı; `P_sabit` ileri oynatma yok; `P_core5` saklama seçeneği yok; `P_ns` ileri oynatma ve yer değişimi yok; `P_np` "kalır" kapalı; `T_plan_np` T_plan'ın "kalır" kapalı hâli; `P_gyok` gereksinim kapısı yok (tanı); `P_r1`, `P_r5`, `P_r85` plan puanı sırası ağırlığı 1,0 / 0,5 / 0,85 (ana kol 0,85, `P_r85` onun yeniden koşusu); `P_rp` satır seçimi eski kuralla. R, Tarif (`T`) ve `T_plan` A6'nın kolları (`a6run.py`).

Dosyalar: `a8plan.py` (planlayıcı: `alloc_p8` dağıtım kuralı, `assign_e8` satır seçimi, `week8` hafta başı seçimi, `rollout`, `plan_score`, `select`), `a8run.py` (koşucu), `a8test.py` (doğrulama), `a8iz.py` (izler), `a8sec.py`, `a8dbg.py`, `a8ilke.py` (tanı sayımları), `a8x.py`, `a8cmp.py` (geliştirme sırasında hızlı karşılaştırma), `a8tab.py` ve `a8rapor.py` (tablolar ve bu belge), `a8_metin.md` ve `a8_parcalar/` (belge şablonu), `chain8.sh`, `run_a8*.sh`, `out8/` (ham sonuçlar, günlükler, izler).
