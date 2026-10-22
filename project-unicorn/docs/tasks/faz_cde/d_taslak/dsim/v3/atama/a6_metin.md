# A6 · Karmaşıklığa ölçeklenen hata modeli ve tarifin yeniden ölçümü

21 Ekim 2026 · Faz D, adım A6 · Godot koşturulmadı; oyun koduna, `strings.csv`'ye, `data/`'ya, `project.godot`'a dokunulmadı; git'te durum değişmedi. Yeni kod yalnız `d_taslak/dsim/v3/atama/` altında (`hata2.py`, `a6*.py`); `dsim3.py` ve `a3core.py` değişmedi.
Girdiler: `ERDEM_KARARLAR_2026-10-20.md` D bölümü 19-22, `A3_OLCUM.md`, `A4_TASARIM.md` (sonundaki inceleme notu). Sayıların hepsi koşulardan ya da hesaptan gelir; ham sonuçlar `atama/out6/`'da.

**Okuma anahtarı.** *Tarif* = Erdem'in atama tarifi (A3'ün `erdem` kipi) + Karar 20 (söz kartı öne geçmez) + Karar 21 (PM'de en karmaşık kart en iyi PM'e, en basit kart en zayıf PM'e). *R* = bugünkü kural (D0s'un önerdiği okuma). *Doğan hata* = kartta ortaya çıkan, *yakalanan* = testin bulduğu, *kaçan* = testten kaçıp sürüme giren, *açık hata* = sprint sonlarında canlı üründe duran hata (medyan). *Eşli fark* = aynı 20 tohumda iki kolun farkının ortalaması ± ortalamanın standart hatası, parantezde "farkın eksi çıktığı tohum / 20". *K-H* = hacim-nötr kalibrasyon (ana ölçüm); *K-E* = Erdem'in örneği birebir (yan ölçüm). Tablolarda ondalık nokta kullanılır (A3 gibi). `[GÖRÜŞ]` benim yargım, `[DEĞERLENDİREMEM]` veri yok.

<<tbl sabitler>>

### 0.1 İlk koşudan sonra yapılan değişiklikler (açık kayıt)

§0 yukarıdaki hâliyle ilk koşudan önce yazıldı (dosya zamanı ve özet `out6/a6_sira.txt`'de). Sonradan değişen tek sabit satırı:

- **Satır 10, `c` (K-H): 0,212.** 6 kişilik ekipte (S3), R kolu, sınırsız arz, 21-60. hafta, 20 tohum: bugünkü modelin ortalama toplam doğan hatası 59,8 (beklenen değeri 60,1); yeni modelde `c = 0,212` ile gerçekleşen 61,0 (+%1,9), beklenen 59,6 (−%0,8): ±%2 içinde. Deneme tablosu §6'da. Not: 0,205 ve 0,215 de aralıktaydı; 0,212 ana koşular başlamadan seçildi ve sonradan değiştirilmedi (gerçekleşen değer Poisson gürültüsü taşır, bu yüzden hem beklenen hem gerçekleşen değere bakıldı).

Uygulama notları (sabit değişmedi, metin netleşti): satır 12'deki "kol 15 hariç" ifadesi satır 16'yı (Δ_PM kolu) kastediyordu; satır 14'teki "bir üstteki uygun PM'e kayar" kuralı kodda "en yakın uygun ve hazırlık zamanı kalan PM, eşitlikte daha yüksek yıldızlı" olarak yazıldı; PM zamanı kalmayan kart hazırlanmadan kalır (R'deki gibi); BK kolunda ilk adımdan sonra ekibi olan kartlar ikinci adımda atlanır (artan kişiler yardım adımına gider).

Sonradan eklenenler (yeni tasarım sabiti değil, ölçüm kolları; hepsi "onay bekliyor" kapsamı dışı, çünkü oyuna girecek bir şey değil):

- **`T_plan` (tanı kolu, tarif değil):** tarifin 1. adımında "en önde duran kart" gereksinime göre değil plan sırasına göre seçilir. Yalnız §4'teki üç bedelin nedenini ayırmak için; öneri olarak okunmamalı.
- **Gereksinim kuvveti duyarlılığı:** `p = 0` (tavan yalnız puana bağlı, `c = 0,297`) ve `p = 2` (`c = 0,137`); her ikisi de aynı hacim-nötr kuralla kalibre edildi.
- **Tanı sayımları** (`a6hata.py`, `a6mvp.py`, `a6soz.py`, `a6tani.py`, `a6hiza.py`): kayıt altına alınmayan ek sayımlar; komutları §8'de.

## 1. Erdem için özet

1. **Modeli kurdum; senin örneğin birebir tutuyor.** Her kartın bir "hata tavanı" var: kartın puanı × kartın istediği yıldız (kilidi olmayan kart 1★ sayılır). Kartı gereksinimini tam karşılayan kişi yaparsa tavanın %20'si kadar hata çıkar; gereksinimin 2 yıldız üstündeki kişi yaparsa %10'u. Senin örneğinde tavan 100 olan işte 3★ kişi 20, 5★ kişi 10 hata sokuyor (testle doğrulandı); tavanı 5 olan basit işte 1★ kişi 1,0, 5★ kişi 0,25 hata sokuyor, yani fark üç çeyrek hata (karmaşık örnekte fark 10 hata).
2. **Oyuncunun ekranında ne değişir.** Simülasyonun kartlarında Yazılım kilidi en çok 2★ (3★ ya da 5★ isteyen kart yok; A7 incelemesi). Hacim-nötr ayarla (K-H, aşağıda) simülasyonun en zor kartını (40 puan, 2★ Yazılım kilidi) 2★ geliştirici yaparsa beklenen hata 3,4; 4★ geliştirici yaparsa 1,7. Kilitsiz 40 puanlık kartta (1★ sayılır) 1★ kişi 1,7, 4★ kişi 0,6; kilitsiz 15 puanlık küçük kartta 1★ kişi 0,64, 5★ kişi 0,16 hata sokar. Yani zor kartta yıldız farkı hatayı ikiye böler (1,7 hatalık fark), basit kartta fark yarım hata. Bugünkü modelde aynı iki fark 0,4 (40 puan, 2★ → 4★) ve 0,3 (15 puan, 1★ → 5★) hata. Kart ipucuna "bu iş en çok N hata çıkarabilir" yazılabilir; bu sayı kartın puanından ve kilidinden okunur.
3. **Tavanı senin sayılarınla birebir bağlamak hata hacmini ikiye katlar; ana ölçümü hacim-nötr yaptım.** Senin örneğinden çıkan tavanla (K-E, `c = 0,479`) bugünkü R kuralıyla 6 kişilik ekipte bugünkünün <<raw oran_E_S3>> katı, 50 kişilik ekipte <<raw oran_E_S6>> katı hata doğar (hücrelere göre 1,8-2,3 kat). Ekonomi ve A'nın hata sınırları bozulmasın diye ana tabloyu bugünkü toplam hatayı veren ayarla (K-H, `c = 0,212`) hesapladım; K-E §2.3'te. Kolların sıralaması iki ayarda aynı: yani aşağıdaki bulgular ayar seçimine bağlı değil. Bu "iki kat" "3 sprintlik iş" tanımıma çok bağlı (A7 incelemesi): 3 sprint süren işi "Yazılım aşaması tek başına 3 sprint süren kart" diye okursak `c = 0,264` olur ve hacim bugünkünün 1,23 katı (6 kişi) / 1,20 katı (50 kişi); senin 3★ işini simülasyonun en zor kartına (2★) eşlersek `c = 0,718` ve 2,82 katı (6 kişi).
4. **İlke tarifte çalışıyor ama kazancı küçük.** Tarifte gereksinimin altındaki kişiye hiç iş düşmüyor (R'de Yazılım işinin 6 kişide %<<raw altinda_R_S3>>'si, 12 kişide %<<raw altinda_R_S4>>'sı gereksinimin altındaki kişiye gidiyor). Doğan hata R'ye göre 12 / 25 / 50 kişide <<pc dogan T R H S4>> / <<pc dogan T R H S5>> / <<pc dogan T R H S6>> (eşli fark <<df dogan T R H S4>> / <<df dogan T R H S5>> / <<df dogan T R H S6>> hata); 3 ve 6 kişide ayırt edilemiyor (<<df dogan T R H S2>> / <<df dogan T R H S3>>). Sürüme kaçan hata 50 kişide <<pc kacan T R H S6>>. Kazanç küçük, çünkü R de zaten "en hızlı kişi en büyük karta" diye zor kartlara iyi kişi veriyor ve ekiplerde Yazılım işinin çoğu dar bir yıldız aralığında yapılıyor (A3 §2.2: 25 kişide Geliştirme işinin %62'si 2,5-3,5★ kişilerde). A7 incelemesi iki neden daha ölçtü: (1) kartlarda karmaşıklık farkı küçük: Yazılım kilidi en çok 2★ ve sınırsız arzda ölçüm penceresindeki özellik kartlarının hepsi 40 puan (6 kişide kartların %68'i kilitsiz, %32'si 2★ kilitli), yani en karmaşık özellik kartının tavanı en basitininkinin yalnız 2 katı; (2) kazancın bir kısmı benim seçtiğim "gereksinimin altındaki kişi daha çok hata sokar" uzatmasından (§0 satır 3) geliyor: bu uzatma kaldırılınca (Δ < 0'da oran 0,20'de kalır) tarifin doğan hata farkı 12 kişide −5,7 ± 1,9'dan −2,5 ± 2,0'a (ayırt edilemez), 25 kişide −9,6 ± 2,0'dan −8,2 ± 2,4'e, 50 kişide −33,3 ± 4,0'dan −23,3 ± 3,3'e iniyor; 6 kişide tarif R'den fazla hata üretiyor (+2,4 ± 1,0; kaynaklı arzda +5,6 ± 2,1).
5. **Açık hata hâlâ tarifte yüksek ve nedeni hata üretimi değil.** Açık hata R'ye göre 3 / 6 / 12 / 25 / 50 kişide <<df acik T R H S2>> / <<df acik T R H S3>> / <<df acik T R H S4>> / <<df acik T R H S5>> / <<df acik T R H S6>> (R: <<lv acik R H S2>> / <<lv acik R H S3>> / <<lv acik R H S4>> / <<lv acik R H S5>> / <<lv acik R H S6>>); kaynaklı arzda 3 kişide <<df acik T R H PR_S2>> (R: <<lv acik R H PR_S2>>, tarif: <<lv acik T H PR_S2>>). Kart başına doğan ve kaçan hata tarifte R'den fazla değil (3 kişi, kaynaklı: 100 puanda doğan hata tarifte <<raw hata_T_PRS2_dogan100>>, R'de <<raw hata_R_PRS2_dogan100>>). Fark düzeltme kartlarının akışında: düzeltme kartı girişten teslime 3 kişide (kaynaklı) <<raw hata_T_PRS2_fixwait>> hafta (R: <<raw hata_R_PRS2_fixwait>>), çünkü tek testçinin (3 kişide kurucu) sırası tarifin 1. adımındaki "en yüksek gereksinimli kart önce" sırasıyla büyük özellik kartlarına gidiyor ve küçük düzeltme kartı testte haftalarca bekliyor (§4); 6-25 kişide gecikme daha küçük (sınırsız arzda <<raw fixwait_T_S3>> / <<raw fixwait_T_S4>> / <<raw fixwait_T_S5>> hafta, R <<raw fixwait_R_S3>> / <<raw fixwait_R_S4>> / <<raw fixwait_R_S5>>). Bu adımı plan sırasıyla değiştiren tanı kolunda (`T_plan`) 3 kişide MVP <<lv mvp T_plan H S2>> hafta (R <<lv mvp R H S2>>), kaynaklı açık hata <<lv acik T_plan H PR_S2>> (R <<lv acik R H PR_S2>>), 6 kişide kaçan söz %<<lv soz T_plan H PR_S3>> (R %<<lv soz R H PR_S3>>): demo ölçeğindeki üç bedelin üçü de tarifin kendi sırasından, hata modelinden değil.
6. **PM tarafı.** Karar 21'in (i) okuması (en basit kart en zayıf PM; tarifin ana okuması) A3'ün PM kuralından ("yeten en düşük yıldızlı PM") belirgin iyi: A3'ün PM'ine göre teslim 12 / 25 / 50 kişide <<dm teslim T E H S4>> / <<dm teslim T E H S5>> / <<dm teslim T E H S6>>, doğan hata <<dm dogan T E H S4>> / <<dm dogan T E H S5>> / <<dm dogan T E H S6>>. (ii) okuması ("zor karta en iyi PM, kalanlar boştaki en iyi PM sırayla") (i)'den biraz iyi ya da aynı: teslim 12 / 25 / 50 kişide <<dm teslim T_zor T H S4>> / <<dm teslim T_zor T H S5>> / <<dm teslim T_zor T H S6>> puan/hf, doğan hata <<dm dogan T_zor T H S4>> / <<dm dogan T_zor T H S5>> / <<dm dogan T_zor T H S6>> (teslim farkı 12 ve 25 kişide standart hatanın 2,3 ve 3,7 katı, ayırt edilebilir; 50 kişide teslim ve üç ekipte doğan hata farkı standart hatanın 0,1-1,9 katı, ayırt edilemiyor); 6 kişide tek PM var, ikisi aynı. PM'in hata azaltmasını Δ_PM'e bağlamak (`T_d`, `T_zord`) hiçbir şeyi ayırt edilir ölçüde değiştirmiyor. [GÖRÜŞ] (ii) basit olan ve (i)'den kötü olmayan: PM kuralını tek cümleye indirir, zayıf PM'i "en basit karta" bağlayan ek mantık gerekmez; (i) istenirse bedeli teslimde %1'den az.
7. **"Kalan kartlar büyükten küçüğe" kolu (`BK`) kötü.** MVP 25 ve 50 kişide <<lv mvp BK H S5>> / <<lv mvp BK H S6>> haftaya kayıyor (R: <<lv mvp R H S5>> / <<lv mvp R H S6>>), açık hata R'den 12 kişide <<dm acik BK R H S4>> fazla, kaynaklı arzda 6 kişide kaçan söz %<<lv soz BK H PR_S3>> (R %<<lv soz R H PR_S3>>). Küçük MVP kartları büyük kartların arkasında aç kalıyor.
8. **Kayıp sayıyla (Karar 21: ilke uygulanır, kayıp büyükse söylenir).** Tarif R'ye göre: teslim 12 / 25 / 50 kişide <<pc teslim T R H S4>> / <<pc teslim T R H S5>> / <<pc teslim T R H S6>>, kaynaklı arzda <<pc teslim T R H PR_S4>> / <<pc teslim T R H PR_S5>> / <<pc teslim T R H PR_S6>> (50 kişide <<dm teslim T R H PR_S6>> puan/hf); açık hata 12 / 25 / 50 kişide <<pc acik T R H S4>> / <<pc acik T R H S5>> / <<pc acik T R H S6>>; MVP 3 / 6 / 12 kişide <<dm mvp T R H S2>> / <<dm mvp T R H S3>> / <<dm mvp T R H S4>> hafta geç; kaçan söz 6 kişide %<<lv soz T H PR_S3>> (R %<<lv soz R H PR_S3>>). Kazanç: doğan hata 12-50 kişide %3-6 az. Bu kayıpların kaynağı §4'te adını koyduğum sıra kuralı, ilkenin kendisi değil.

**Erdem'e iki sade soru** (cevapla tarif ve ölçüm yeniden düzenlenir):

- *Hata tavanı kaç olsun?* Örnek: 6 kişilik ekipte simülasyonun en zor kartını (40 puan, 2★ Yazılım kilidi) 2★ geliştirici yapıyor. (A) Hacim-nötr (K-H): kartın beklenen hatası 3,4, oyunun toplam hata miktarı bugünkü kadar kalır, ekonomi ve A'nın hata sınırları değişmez. (B) Senin 100 / 20 / 10 sayıların birebir (K-E): aynı kartın beklenen hatası 7,7, oyunda bugünkünün <<raw oran_E_S3>> katı hata doğar (bu kat "3 sprintlik iş"in nasıl okunduğuna bağlı: 1,2 ile 2,8 kat arası, madde 3); hata sınırları ve düzeltme maliyeti yeniden kalibre edilmeli. Benim önerim (A); (B) seçilirse c'nin ölçeği ve düzeltme maliyeti Faz D'nin ayrı işi olur.
- *Tarifin 1. adımı plan sırasını bozsun mu?* Örnek: 3 kişilik ekipte ilk sprintin planında üç küçük MVP kartı ve bir büyük kart var; tarif en çok kilit isteyen büyük karta tasarımcıyı ve kurucuyu koyuyor, MVP 4. haftada değil 6. haftada çıkıyor. (A) Tarif aynen: "en zor karta en iyiler önce" (ilke korunur, MVP gecikir, düzeltmeler bekler). (B) Plan sırası önce, gereksinim yalnız kimin gideceğini belirler (ilke yumuşar, üç bedel kalkar). Ölçüm (B)'yi destekliyor.

## 2. Ana tablo (K-H, hacim-nötr)

20 tohumun ortalaması. "Teslim" puan/hf; "açık" sprint sonlarındaki açık hatanın medyanı (ortalaması); "söz" vadesi gelen söz kartlarından kaçanların payı (yalnız kaynaklı arz). Sınırsız arzda pencere 21-60. hafta, kaynaklı arzda 21-80. hafta.

<<tbl ana_H>>

**Aynı tablo, Erdem'in sayıları birebir (K-E, `c = 0,479`; hata hacmi bugünkünün yaklaşık iki katı):**

<<tbl ana_E>>

**Eşli farklar (K-H).** Tarif − R:

*Teslim (puan/hf)*

<<tbl df_H_teslim>>

*Açık hata*

<<tbl df_H_acik>>

*Doğan hata (pencerede toplam)*

<<tbl df_H_dogan>>

*Sürüme kaçan hata (pencerede toplam)*

<<tbl df_H_kacan>>

*Kaçan söz (yalnız kaynaklı arz)*

<<tbl df_H_soz>>

*MVP haftası*

<<tbl df_H_mvp>>

*Boşta (PM hariç)*

<<tbl df_H_bosta>>

Okuma: tarifin R'ye farkı **teslimde** 6 kişide <<dm teslim T R H S3>> (önde), 12 kişide <<dm teslim T R H S4>>, 25'te <<dm teslim T R H S5>>, 50'de <<dm teslim T R H S6>> (kaynaklı arzda 50 kişide <<dm teslim T R H PR_S6>>) puan/hf; **doğan hatada** 12-50 kişide %3-6 az (önde); **açık hatada** her ölçekte (1 kişi hariç) daha fazla; **MVP'de** 3-12 kişide 1-2,5 hafta geç; **kaçan sözde** 3 kişide <<dm soz T R H PR_S2>>, 6 kişide <<dm soz T R H PR_S3>> daha çok kaçırıyor. `BK` her sütunda tariften ya aynı ya kötü (MVP 25 ve 50 kişide <<dm mvp BK T H S5>> / <<dm mvp BK T H S6>> hafta).

### 2.1 Doğan hata ve kaçan hata, düz sayılarla (K-H)

Doğan hata:

<<tbl lv_H_dogan>>

Sürüme kaçan hata:

<<tbl lv_H_kacan>>

### 2.2 MVP haftası, boşta ve gereksinimin altında çalışan iş (K-H)

<<tbl lv_H_mvp>>

<<tbl lv_H_bosta>>

Gereksinimin altındaki kişiye düşen Yazılım işi payı (tarif ve `BK`'de tanım gereği 0):

<<tbl lv_H_altinda>>

### 2.3 Erdem'in sayıları birebir (K-E)

Tavan senin örneğinden (`c = 0,479`): bugünkünün katı kadar hata doğuyor (doğan hata oranı, yeni ÷ bugünkü, R kolu):

<<tbl oran>>

Ana tablonun K-E hâli §2'nin başında. K-E'de tarif − R eşli farkları (teslim, açık hata, doğan hata, kaçan söz):

<<tbl df_E_teslim>>

<<tbl df_E_acik>>

<<tbl df_E_dogan>>

<<tbl df_E_soz>>

Okuma: K-E'de doğan hata R kolunda bugünkünün 6 kişide <<raw oran_E_S3>>, 50 kişide <<raw oran_E_S6>> katı (tüm hücrelerde 1,8-2,3 kat); düzeltme akışı aynı kaldığı için açık hata her kolda büyüyor (R, 12 kişide <<lv acik R E S4>>; K-H'de <<lv acik R H S4>>). **Kolların sırası K-H ile aynı:** tarif R'den açık hatada geride (12 / 25 / 50 kişide <<df acik T R E S4>> / <<df acik T R E S5>> / <<df acik T R E S6>>), MVP'de 3-12 kişide <<dm mvp T R E S2>> / <<dm mvp T R E S3>> / <<dm mvp T R E S4>> hafta geride, kaynaklı arzda 3 kişide açık hata <<dm acik T R E PR_S2>> ve 6 kişide kaçan söz <<dm soz T R E PR_S3>>; doğan hatada 25 ve 50 kişide önde (<<df dogan T R E S5>> / <<df dogan T R E S6>>). `BK` bütün bunlarda daha kötü (25 kişide açık hata <<lv acik BK E S5>>, 6 kişide kaçan söz %<<lv soz BK E PR_S3>>). Yani sonuçlar ayarın seçiminden bağımsız; ayar yalnız hata sayılarının büyüklüğünü oynatıyor.

### 2.4 Bugünkü hata modeliyle aynı kollar (referans)

Tarifi ve R'yi bugünkü hata modeliyle (yapım kalitesi 1 ÷ √Y) de koşturdum (`BK` referansı atlandı); böylece "kolun farkı hata modelinden mi, atama kuralından mı" ayrılır.

<<tbl ana_0>>

Tarif − R, bugünkü modelde:

<<tbl df_0_acik>>

<<tbl df_0_dogan>>

<<tbl df_0_soz>>

Okuma: teslim, açık hata ve MVP farkları bugünkü hata modelinde de aynı yönde ve benzer büyüklükte (ör. 3 kişide kaynaklı açık hata <<df acik T R 0 PR_S2>>, yeni modelde <<df acik T R H PR_S2>>; 50 kişide teslim <<dm teslim T R 0 S6>> / <<dm teslim T R H S6>>); yani bu bedeller hata modelinden gelmiyor. Kaçan söz farkı aynı yönde ama yarı büyüklükte (6 kişide <<dm soz T R 0 PR_S3>> → <<dm soz T R H PR_S3>>). Yeni modelin kattığı: doğan hata farkı; bugünkü modelde tarif R'den 12-25 kişide ayırt edilemiyor (<<df dogan T R 0 S4>> / <<df dogan T R 0 S5>>), yeni modelde 12-50 kişide önde (<<df dogan T R H S4>> / <<df dogan T R H S5>> / <<df dogan T R H S6>>).

### 2.5 Gereksinim kuvveti duyarlılığı (p = 0, 1, 2; her biri aynı kuralla hacim-nötr kalibre)

`p`, tavanın gereksinimle ne kadar hızlı büyüdüğü (`T = c × puan × R^p`). `p = 0`: tavan yalnız puana bağlı (ilke "karmaşıklık = büyüklük" olur); `p = 1`: ana ayar; `p = 2`: zor işin tavanı çok daha yüksek. 6 kişide (S3) bugünkü toplam doğan hata her birinde korundu (`c`: 0,297 / 0,212 / 0,137).

| p | Doğan hata, tarif − R, 12 kişi | Doğan hata, tarif − R, 50 kişi | Açık hata, tarif − R, 12 kişi | Açık hata, tarif − R, 3 kişi (kaynaklı) | MVP haftası 3 kişi: R / tarif / `T_plan` | Kaçan söz 6 kişi (kaynaklı): R / tarif / `T_plan` |
|---|---|---|---|---|---|---|
| 0 | <<pc dogan T R 0.297@0 S4 @duy>> (<<df dogan T R 0.297@0 S4 @duy>>) | <<pc dogan T R 0.297@0 S6 @duy>> (<<df dogan T R 0.297@0 S6 @duy>>) | <<df acik T R 0.297@0 S4 @duy>> | <<df acik T R 0.297@0 PR_S2 @duy>> | <<lv mvp R 0.297@0 S2 @duy>> / <<lv mvp T 0.297@0 S2 @duy>> / <<lv mvp T_plan 0.297@0 S2 @duy>> | %<<lv soz R 0.297@0 PR_S3 @duy>> / %<<lv soz T 0.297@0 PR_S3 @duy>> / %<<lv soz T_plan 0.297@0 PR_S3 @duy>> |
| 1 (ana) | <<pc dogan T R H S4>> (<<df dogan T R H S4>>) | <<pc dogan T R H S6>> (<<df dogan T R H S6>>) | <<df acik T R H S4>> | <<df acik T R H PR_S2>> | <<lv mvp R H S2>> / <<lv mvp T H S2>> / <<lv mvp T_plan H S2>> | %<<lv soz R H PR_S3>> / %<<lv soz T H PR_S3>> / %<<lv soz T_plan H PR_S3>> |
| 2 | <<pc dogan T R 0.137@2 S4 @duy>> (<<df dogan T R 0.137@2 S4 @duy>>) | <<pc dogan T R 0.137@2 S6 @duy>> (<<df dogan T R 0.137@2 S6 @duy>>) | <<df acik T R 0.137@2 S4 @duy>> | <<df acik T R 0.137@2 PR_S2 @duy>> | <<lv mvp R 0.137@2 S2 @duy>> / <<lv mvp T 0.137@2 S2 @duy>> / <<lv mvp T_plan 0.137@2 S2 @duy>> | %<<lv soz R 0.137@2 PR_S3 @duy>> / %<<lv soz T 0.137@2 PR_S3 @duy>> / %<<lv soz T_plan 0.137@2 PR_S3 @duy>> |

Okuma: tarifin doğan hata avantajı `p` ile birlikte büyüyor (12 kişide <<pc dogan T R 0.297@0 S4 @duy>> → <<pc dogan T R H S4>> → <<pc dogan T R 0.137@2 S4 @duy>>; 50 kişide <<pc dogan T R 0.297@0 S6 @duy>> → <<pc dogan T R H S6>> → <<pc dogan T R 0.137@2 S6 @duy>>): `p = 0`'da ilke doğan hatada ayırt edilemiyor, `p = 2`'de %9-10. Buna karşılık açık hata, MVP ve kaçan söz bedelleri `p`'den bağımsız (3 kişide kaynaklı açık hata farkı <<df acik T R 0.297@0 PR_S2 @duy>> / <<df acik T R H PR_S2>> / <<df acik T R 0.137@2 PR_S2 @duy>>; MVP 6,4-6,7 hafta; kaçan söz %6-7,4), ve `T_plan` üç bedeli her `p`'de R düzeyine indiriyor. Yani `p` ilkenin kazancının büyüklüğünü belirliyor, bedelleri değil. [GÖRÜŞ] `p` Erdem'in örneğinden tek başına çıkmıyor (iki örnek en çok `p = 1`'e yakın); oyun içi ilkenin görünürlüğü (zor kartta yıldız farkı) isteniyorsa `p` 1 ile 2 arasında seçilebilir, bedeller değişmez.

## 3. PM tablosu (K-H)

Kollar: R (bugünkü PM kuralı), **Tarif** (PM okuması (i): en basit kart en zayıf PM), `T_zor` (PM okuması (ii): zor karta en iyi PM, kalanları boştaki en iyi PM sırayla), `T_d` ((i) + PM'in hata azaltması Δ_PM'e bağlı), `T_zord` ((ii) + Δ_PM), `E` (A3'ün tarifi: PM'de "yeten en düşük"). Atama hepsinde tarifin ataması. PM'siz ekipte (1 ve 3 kişi) bu kollar tarifle aynıdır (doğrulandı). 6 kişilik ekipte tek PM var, okumalar aynı sonucu verir.

*Teslim*

<<tbl pm_teslim>>

*Açık hata*

<<tbl pm_acik>>

*Doğan hata*

<<tbl pm_dogan>>

*Sürüme kaçan hata*

<<tbl pm_kacan>>

*Kaçan söz*

<<tbl pm_soz>>

*MVP haftası*

<<tbl pm_mvp>>

**Eşli farklar (PM okumaları):**

*Teslim*

<<tbl pmdf_teslim>>

*Açık hata*

<<tbl pmdf_acik>>

*Doğan hata*

<<tbl pmdf_dogan>>

*Kaçan hata*

<<tbl pmdf_kacan>>

*Kaçan söz*

<<tbl pmdf_soz>>

Okuma:

- **(i) A3'ün PM kuralından belirgin iyi.** Tarif (T) − A3 tarifi (E): teslim 12 / 25 / 50 kişide <<dm teslim T E H S4>> / <<dm teslim T E H S5>> / <<dm teslim T E H S6>> puan/hf, doğan hata <<dm dogan T E H S4>> / <<dm dogan T E H S5>> / <<dm dogan T E H S6>>. A3'ün "yeten en düşük yıldızlı PM" kuralı ikinci en zor kartı bile en zayıf PM'e veriyordu; (i) kartları karmaşıklık sırasına dizip zayıf PM'e yalnız en basit dilimi veriyor. Yine de PM kuralı tarifin kaybının tamamı değil: E − R teslim 50 kişide <<dm teslim E R H S6>>, T − R <<dm teslim T R H S6>>, tanı kolu `T_plan` − R <<dm teslim T_plan R H S6>> (yani 50 kişideki kalan kaybın büyük kısmı 1. adımın sırasından); 12-25 kişide `T_plan` da R'nin altında (<<dm teslim T_plan R H S4>> / <<dm teslim T_plan R H S5>>), o kısmın kaynağı ayrılmadı.
- **(ii) (i)'den kötü değil, biraz iyi.** (ii) − (i): teslim 12 / 25 / 50 kişide <<dm teslim T_zor T H S4>> / <<dm teslim T_zor T H S5>> / <<dm teslim T_zor T H S6>>, doğan hata <<dm dogan T_zor T H S4>> / <<dm dogan T_zor T H S5>> / <<dm dogan T_zor T H S6>>, kaçan söz 12 / 25 kişide <<dm soz T_zor T H PR_S4>> / <<dm soz T_zor T H PR_S5>>. 6 kişide tek PM var, iki okuma aynı.
- **Δ_PM'e bağlı hata azaltması bir şey kazandırmıyor.** `T_d` − T: doğan hata 12 kişide <<dm dogan T_d T H S4>> (iki taraftan da yönü tutarsız), açık hata 50 kişide <<dm acik T_d T H S6>> (tek ayırt edilebilir fark); teslim ve kaçan hatada standart hatanın içinde. `T_zord` − `T_zor` de aynı.
- MVP haftası PM okumasına bağlı değil (tüm PM kollarında aynı).

## 4. Demo ölçeğindeki üç bedelin izi

A4'ün "ucuz hamlesi": tarifin A3'te gösterdiği üç bedel yeni hata modeliyle duruyor mu, ve nedeni ne? Üçü de duruyor:

| Bedel (K-H) | R | Tarif | Fark |
|---|---|---|---|
| 3 kişide MVP haftası | <<lv mvp R H S2>> | <<lv mvp T H S2>> | <<dm mvp T R H S2>> hafta (tarifin R'den erken olduğu tohum: <<ne mvp T R H S2>>) |
| 3 kişide kaynaklı arzda açık hata | <<lv acik R H PR_S2>> | <<lv acik T H PR_S2>> | <<df acik T R H PR_S2>> |
| 6 kişide kaçan söz | %<<lv soz R H PR_S3>> | %<<lv soz T H PR_S3>> | <<df soz T R H PR_S3>> |

Aşağıdaki izler `a6iz.py` / `a6mvp.py` / `a6hata.py` / `a6soz.py` çıktılarıdır (K-H, hepsi 20 tohumla; ayrıntılı kart kart iz 1. tohumdan).

### 4.1 3 kişide MVP gecikmesi

Ekip: kurucu (Tasarım 2★, Yazılım 2★, Test 2★), Deniz (Yazılım 3★, test kutusu yok), Ece (Tasarım 2★). İlk sprintin planında üç K1 MVP kartı (15 puan, kilitsiz) ve 25 puanlık bir K2 kartı (kart 4: stok hattının ikinci kademesi, Tasarım ★1 ve Yazılım ★2 kilidi olan tek kart) var.

- **R, 1. tohum:** h0,0 Ece kart 1'in, kurucu kart 2'nin tasarımına girer (MVP kartları plan sırasıyla önde); h0,23 Deniz ve kurucu kart 2'nin yazılımına; h0,73 kurucu kart 2'nin testine. MVP kartları 1, 2 h2'de, 3 h4'te biter; **MVP 4. hafta**.
- **Tarif, 1. tohum:** h0,0 **Ece ve kurucu birlikte kart 4'ün tasarımına** girer (planda kilidi olan tek ve en büyük kart; tarifin 1. adımı onu başa alır, kadro tavanı 2); MVP kartlarının tasarımı h0,5, h0,5 ve h1,1'de başlar. Yazılımda Deniz önce kart 4'e (h0,5), kurucu da kart 4'e (h0,76) gider. Test tek kişide (kurucu) ve kurucu yazılımda tutulduğu için MVP kartlarının testi h2,5 (kart 3), h3,6 (kart 1), h4,0 (kart 2) olur; **MVP 6. hafta**.
- **20 tohumun ortalaması** (MVP kartlarının ilk aşama başlangıçları, hafta): R: Tasarım 0,2, Yazılım 0,7, Test 1,4; tarif: 0,7 / 1,5 / 3,4. Tarifte testin başlaması R'den ortalama 2,0 hafta geç: bunun yaklaşık 0,8 haftası yazılımın geç başlamasından devralındı, 1,2 haftası tek testçinin (kurucu) o sırada başka kartın yazılımında ya da testinde tutulmasından.
- **Neden "kalır" ya da "yetecek kadar en iyi" değil:** karşı-olgusal kollar (`a6tani.py`) tarifin MVP haftasını değiştirmiyor: kalır kapalı (`T_np`) <<raw tani_mvp_np>>, en iyiler yetecek kadar (`T_min`) <<raw tani_mvp_min>>, ikisi birden <<raw tani_mvp_npmin>>. Plan sırasıyla seçilen 1. adım (`T_plan`) MVP'yi R'nin seviyesine, <<lv mvp T_plan H S2>> haftaya indiriyor.

### 4.2 3 kişide kaynaklı arzda açık hata

- 100 puanda **doğan hata** R'de <<raw hata_R_PRS2_dogan100>>, tarifte <<raw hata_T_PRS2_dogan100>> (aynı); **yakalanan** ve **kaçan** hata da aynı büyüklükte (kaçan <<raw hata_R_PRS2_kacan>> / <<raw hata_T_PRS2_kacan>>). Yani açık hata farkı hata üretiminden değil.
- Fark **düzeltme kartlarının akışında**: pencerede teslim edilen düzeltme kartı R'de <<raw hata_R_PRS2_fixn>> adet, tarifte <<raw hata_T_PRS2_fixn>>; düzeltme kartının girişten teslime süresi R'de <<raw hata_R_PRS2_fixwait>> hafta, tarifte <<raw hata_T_PRS2_fixwait>> hafta.
- **1. tohumda kart kart:** R'de düzeltme kartı 18 h6'da girer, Deniz h7,3'te yazılıma başlar, kurucu h7,9'da testler, kart h10'da biter. Tarifte düzeltme kartı 20 h8'de girer, Deniz h8,7'de yazar, **testi h21,5'te** yapılır; kart 32 h16'da yazılır, h38,2'de test edilir. Yazılım aşaması hızlı; bekleyen **tek testçinin sırası**: kurucu h8,5 ile h21,4 arasında 15-40 puanlık dokuz özellik kartının testine ve yazılımına girer, bu aralıkta yalnız bir düzeltme kartını (kart 19) test eder; 4 puanlık dört düzeltme kartının (20, 24, 26, 30; yazılımları h8,7-h14,6'da bitmişti) testi h21,5-h21,9'da arka arkaya yapılır.
- Karşı-olgusal: kalır kapalı (`T_np`) açık hata <<raw tani_acik_np>>, yetecek kadar (`T_min`) <<raw tani_acik_min>>; plan sırasıyla 1. adım (`T_plan`) <<lv acik T_plan H PR_S2>> (R: <<lv acik R H PR_S2>>).

### 4.3 6 kişide kaçan söz

- Vadesi gelen söz kartlarından geç kalanların payı tarifte %<<lv soz T H PR_S3>>, R'de %<<lv soz R H PR_S3>>. Testte hata bulunup düzeltme aşamasına giren kartların payı: geç kalanlarda <<raw soz_T_bulgu>>, zamanında teslim edilenlerde <<raw soz_T_bulgu_ok>>. R'de geç kalan 4 kartın tamamında test bulgusu var, ama R kartın testine daha erken giriyor (girişle test başı arası <<raw soz_R_twait>> hafta, tarifte geç kalanlarda <<raw soz_T_twait>>).
- **Tarif söz kartına az kişi koyuyor:** geç kalan söz kartlarında yazılımda aynı anda çalışan en çok kişi R'de ortalama <<raw soz_R_crew>>, tarifte <<raw soz_T_crew>> (kart sprintin süresine "yetecek" kadar kişiyle başlıyor, test bulgusu çıkınca düzeltme aşaması sprinti aşıyor).
- **12. tohum, kart kart (6 kişi, kaynaklı):** vadesi sprint 17 olan kart 45 (40 puan) h32'de girer; tasarım Ece (3★) + kurucu, yazılım kurucu (2★) sonra Deniz (3,5★), test Ayşe (2,5★) h34,1'de başlar, h36,9'da Mert (1,5★) düzeltme yazar; sprint 18'de biter (bir sprint geç). Kart 56 (vade 13), 79 (32), 86 (24), 102 (37): hepsinde son adım testten sonra gelen küçük düzeltme yazısı.
- Karşı-olgusal: 1. adımı plana bağlamak (`T_plan`) kaçan sözü %<<lv soz T_plan H PR_S3>>'a (tohum ortalaması, ana tablonun ölçüsü; R: %<<lv soz R H PR_S3>>) indiriyor; toplam vadesi gelen karta bölünmüş oranla (a6tani.py) `T_plan` %<<raw tani_soz_plan>>, kalır kapalıyken (`T_plan_np`) %<<raw tani_soz_plannp>>.

### 4.4 Tanı kolu `T_plan` tüm ekiplerde (K-H)

`T_plan` tarifin yalnız 1. adımını değiştirir: "en önde duran kart" gereksinime göre değil plan sırasına göre seçilir; 2. ve 3. adım, kalır kuralı, PM (i) aynıdır. Tarif değildir; üç bedelin nedenini ayırmak için.

*MVP haftası*

<<tbl tani_mvp>>

*Açık hata*

<<tbl tani_acik>>

*Kaçan söz*

<<tbl tani_soz>>

*Doğan hata*

<<tbl tani_dogan>>

*Teslim*

<<tbl tani_teslim>>

*Eşli farklar, teslim*

<<tbl tanidf_teslim>>

*Eşli farklar, doğan hata*

<<tbl tanidf_dogan>>

*Eşli farklar, açık hata*

<<tbl tanidf_acik>>

*Eşli farklar, MVP haftası*

<<tbl tanidf_mvp>>

*Eşli farklar, kaçan söz*

<<tbl tanidf_soz>>

## 5. Yorum ve [GÖRÜŞ]

Ölçüm ayrı, görüş ayrı: "Ölçüm" satırları §2-§4'ten sayıdır, "[GÖRÜŞ]" satırları benim okumamdır, karar Erdem'indir.

1. **İlke hata modelinde doğru kurulabiliyor ve istenen yönde çalışıyor.** Ölçüm: Erdem'in iki sayısı (100 tavanda 3★ → 20, 5★ → 10; tavan 5'te 1★ ile 5★ farkı 0,75 hata) modelden birebir çıkıyor; tarifte gereksinimin altındaki kişiye iş düşmüyor (R'de %1-8). [GÖRÜŞ] Kural ekranda anlatılabilir ("bu iş en çok N hata çıkarabilir; sen X★ koyunca Y bekleniyor").
2. **Simülasyonda ilkenin ürettiği kazanç küçük.** Ölçüm: tarif doğan hatayı R'ye göre 12-50 kişide %3-6, kaçan hatayı %2-6 azaltıyor; 3 ve 6 kişide fark gürültü içinde. [GÖRÜŞ] Nedenler: (a) R de en hızlı kişiyi en büyük karta veriyor (ilkeye zaten yakın), (b) Yazılım işinin çoğu dar bir yıldız aralığında yapılıyor (A3 §2.2: 25 kişide Geliştirme işinin %62'si 2,5-3,5★ kişilerde); 5★ ağırlıklı bir ekipte fark büyür [DEĞERLENDİREMEM, ölçülmedi]. Ölçüm (A7 incelemesi): (c) simülasyonun kartlarında karmaşıklık farkı küçük (Yazılım kilidi en çok 2★; sınırsız arzda pencerede bütün özellik kartları 40 puan, tavanları yalnız 1'e 2 oranında ayrışıyor); (d) 12 kişide kazancın yarısından çoğu, 50 kişide yaklaşık üçte biri gereksinimin altı için seçtiğim eğri uzatmasından (§1 madde 4).
3. **Tarifin teslim, açık hata, MVP ve söz kayıpları hata modelinden gelmiyor; büyük kısmı tarifin 1. adımından.** Ölçüm: bugünkü hata modelinde de aynı büyüklükte (§2.4); `T_plan` açık hatayı R düzeyine indiriyor (hiçbir ekipte R'den ayırt edilebilir fark yok), MVP'yi 3-12 kişide (sınırsız arz) ve kaçan sözü 3-50 kişide R düzeyine getiriyor, 50 kişide teslim kaybını <<dm teslim T R H S6>>'dan <<dm teslim T_plan R H S6>>'a indiriyor (§4.4). Artakalan: 12-25 kişide teslim kaybı `T_plan`'da da duruyor (<<dm teslim T_plan R H S4>> / <<dm teslim T_plan R H S5>>) ve kaynaklı arzda 6-12 kişide MVP R'den <<dm mvp T_plan R H PR_S3>> hafta geç. [GÖRÜŞ] "En yüksek gereksinimli kart önce" sırası ile "plan sırası" (MVP, söz, düzeltme önceliği) çatışıyor. İlkenin kendisi (karmaşık işe en iyiler) ile çelişen bir şey yok; çatışan, sıranın hangi kartın önce eleman alacağını belirlemesi. Ayrım: **sıra** plana, **kişi seçimi** ilkeye ait olabilir. Bu ayrımla yazılmış tam bir kural koşulmadı (§7); `T_plan` yalnızca bunun ucuz bir tanısı.
4. **PM okuması (ii) yeterli.** Ölçüm: (i) ile (ii) teslimde ve açık hatada ayırt edilemiyor ya da (ii) biraz önde; doğan hatada (ii) 12-50 kişide önde görünüyor ama farklar standart hatanın 0,1-1,9 katı, ayırt edilemiyor (§3). (ii)'nin ataması bugünkü PM kuralıyla (en iyi PM'den başlayarak kartları büyükten küçüğe dağıtmak) neredeyse aynı; tek fark kartların puan yerine "puan × gereksinim" ile sıralanması (a6test.py pm: 6 kartlık örnekte (ii) ve bugünkü kural aynı atamayı veriyor). [GÖRÜŞ] Karar 21'in basit okuması (ii): kural tek cümle, zayıf PM'i "en basit karta" bağlayan ek mantık gerekmiyor. Δ_PM'e bağlı hata azaltması bir şey kazandırmıyor.
5. **`BK` önerilmez.** Ölçüm: MVP 25 ve 50 kişide 6 ve 8. hafta, 12-50 kişide açık hata R'den 5-8 fazla, kaynaklı arzda 6 kişide kaçan söz %<<lv soz BK H PR_S3>>.
6. **K-E ayarı oyun dengesini oynatır.** Ölçüm: bugünkü modelin yaklaşık iki katı hata doğuyor (hücrelere göre 1,8-2,3 kat; 6 kişide <<raw oran_E_S3>>). [GÖRÜŞ] Erdem'in örnek sayıları ilkenin biçimini veriyor, ölçeği değil; ölçek ayrı karar (§1 soru 1). Ölçüm (A7): kat "3 sprintlik iş" tanımına bağlı, 1,2 (Yazılım aşaması 3 sprint süren kart, `c = 0,264`) ile 2,8 (Erdem'in 3★ işi simülasyonun 2★ kartına eşlenince, `c = 0,718`) arası.
7. **Karar 20 (söz kartı öne geçmez, risk darboğaz satırında).** Ölçüm: kaynaklı arzda vadesi gelen sözlerden geç kalanların payı 6 kişide tarifte %<<lv soz T H PR_S3>> (R %<<lv soz R H PR_S3>>), 3 kişide %<<lv soz T H PR_S2>> (R %<<lv soz R H PR_S2>>), 12 / 25 / 50 kişide %<<lv soz T H PR_S4>> / %<<lv soz T H PR_S5>> / %<<lv soz T H PR_S6>> (R: 0). [GÖRÜŞ] Kural yazıldığı gibi kalabilir; riskin plan anında darboğaz satırında görünmesi ilk iki ekipte önemli.
8. **Karar 22 (darboğaz satırı tekrarında sayaç).** Not: "Test yetişmiyor; bu sorun N sprinttir sürüyor" tonu. Ölçüm gerektirmez; sayaç sürüm kaydından türetilir (A4 Soru 5 B). Bu belgede ölçülmedi.

## 6. Doğrulama

| Doğrulama | Beklenen | Bulunan | Sonuç |
|---|---|---|---|
| Hata modeli kapalıyken (kalibrasyon 0) A6 koşucusu = A3 kayıtları | 0 fark | R ve E kolları, S1-S6 ve PR S2-S4, 3 tohum: 2.592 metrik, 0 fark (`out6/a6_regress.txt`); kodun son hâlinde (atama kopyası düzenlendikten sonra) 1 tohumla yeniden: 864 metrik, 0 fark | GEÇTİ |
| Mikro testler: m(0) = 0,20, m(2) = 0,10, m(4) = 0,05, m(−2) = 0,40; K-E: 69,6 puan × R = 3 → tavan 100; Erdem'in örneği (tavan 100: 3★ → 20, 5★ → 10); kartın H'si elle hesapla aynı; R_TABAN; TİTİZ ×0,5; düzeltme kartı ×0,3 | 14/14 | 14/14 (`a6test.py micro`) | GEÇTİ |
| Hata sayısı kuyruğu (`_tail`) bugünkü `on_test_done`'ın H'den sonrası ile bayt bayt aynı | 0 fark | 39 tohum × 2 kart türü × 9 alan = 702 alan, 0 fark | GEÇTİ |
| PM okumaları (3 PM: 5★, 3★, 1★; 6 kart) | (i) en karmaşık → 5★, en basit → 1★; (ii) en karmaşık → 5★ | (i): 40×R3, 40×R2 → 5★; 25×R2, 25×R1 → 3★; 15×R1 iki kart → 1★. (ii): hepsi 5★ (zamanı yettiği için) | GEÇTİ |
| `BK`: 8 puanlık kart sıradaki en iyiye, tarifte yeten en düşüğe | d3 / d4 | d3 / d4 | GEÇTİ |
| Sahte bozma (testler boş değil): M0 0,25 yapılınca | mikro düşmeli | mikro 9/14 (5 vaka düştü) | GEÇTİ |
| Sahte bozma: ağır düzeltme olasılığı 0,18 → 0,5 yapılınca | kuyruk testi düşmeli | 15 alan farkı | GEÇTİ |
| Atama kopyasının yeniden düzenlenmesi (`alloc_gen`) kayıtlı sonuçları bozmadı | 0 fark | BK: 4 senaryo × 3 tohum, 696 alan, 0 fark; tarif (`alloc_gen` zorlanarak): 696 alan, 0 fark | GEÇTİ |
| PM'siz ekipte (S1, S2, PR S1, PR S2; 20 tohum) `T_zor`, `T_d`, `T_zord` = tarif | 0 fark | 10.800 alan, 0 fark | GEÇTİ |
| Tahmin = sonuç | ≤ 1e-6 | 2.800 kayıtlı koşunun hepsinde en büyük fark 7,1e-15 | GEÇTİ |
| Her hücrede 20 tohum | 20 | 140 dosyanın hepsinde 20 | GEÇTİ |
| Yakalanan hata ≤ doğan hata | 0 ihlal | 0 | GEÇTİ |
| Tarif, `BK`, PM kollarında gereksinimin altındaki Yazılım işi | 0 | tarif ailesi (T, BK, T_zor, T_d, T_zord, E, T_plan) her kalibrasyonda 0,0; R: K-H 17.566, K-E 14.821, bugünkü 17.249 puan (kuralın gereksinimi bilmediğinin kanıtı) | GEÇTİ |
| K-H kalibrasyonu | ±%2 | gerçekleşen +%1,9, beklenen −%0,8 (§6 alt tablo) | GEÇTİ |
| §0 koşulardan önce yazıldı | §0 dosya zamanı < ilk sonuç dosyası | §0 sürümü 23:49:31, ilk sonuç dosyası 23:53:11 (`out6/a6_sira.txt`) | GEÇTİ |
| Tanı kolları kayıtlı sonuca bağlı: karşı-olgusal sayımlar (`a6tani.py`) ana koşuyla uyumlu | `T` ve `R` satırları ana tablodakiyle aynı | MVP (3 kişi) 6,4 / 4,0, açık hata (3 kişi, kaynaklı) 32,4 / 14,5, kaçan söz (6 kişi) %6,0 / %1,1 ana tabloyla aynı* | GEÇTİ |

\* Ana tabloda `T` kaçan söz %6,1 (`df` hesabı ana pickle'dan, vadesi gelen kartlar toplamı değil tohum ortalaması), `a6tani.py` toplam vadesi gelen karta bölünmüş oran verir (%6,0). İki ölçü tanımı farklı, ayrıma dikkat.


**K-H kalibrasyon denemeleri** (6 kişi, R kolu, sınırsız arz, 21-60. hafta, 20 tohum ortalaması):

<<tbl kalib>>

## 7. Bitmeyenler ve sınırlar

- **Tarifin 1. adımının plan sırasına bağlı tam bir kuralı koşulmadı.** `T_plan` yalnız tanı: en iyi kişileri plandaki ilk karta verir, "en karmaşık karta en iyiler" ilkesini bozar. İlke ile plan sırasını birlikte koruyan kural (ör. plan sırası kartların kim önce eleman alacağını, gereksinim kimin gideceğini belirler) ayrı bir tasarım ve ölçüm adımı.
- **Test yakalaması** Karar 19'a göre değişmedi (bugünkü gibi). İlke testçi için de (karmaşık kartı en iyi testçi) kurulabilir; ölçülmedi.
- **Kapı verisi** yalnız ERP + paylaşılan hatlardan; Yazılım kapısı en çok 2★ (dokuz hattın dördünde K2 ve K3'te 2★, gerisinde kapı yok), yani R yalnız 1 ya da 2 (A7 incelemesi; önceki metinde "R ≤ 3" yazıyordu). 5★ ölçeğine geçişte kapılar yükselirse tavan (R ile doğrusal) büyür; `c` yeniden kalibre edilmeli. Duyarlılık: `p = 0` ve `p = 2` (§2.5) bedellerin sırasını ve `T_plan` tanısını değiştirmiyor; yalnız doğan hata kazancı `p` ile büyüyor.
- **"3 sprintlik iş" tanımı** (69,6 puan, 3★ kişi 6 haftada) benim; Erdem başka tanım (ör. ekip büyüklüğüne bağlı) isterse yalnız `c(K-E)` değişir, K-H etkilenmez. Tanımda 69,6 bir 3★ kişinin 6 haftalık **Yazılım** işidir ama tavan kartın **toplam** puanıyla (Tasarım + Yazılım + Test) çarpılır; K3 kartında Yazılım payı ortalama %55 (40 puanın 18 / 26 / 22'si). Ölçüm (A7, R kolu, 20 tohum): `c = 0,264` ile hacim bugünkünün 1,23 (6 kişi) / 1,20 (50 kişi) katı, `c = 0,718` ile 2,82 katı (6 kişi).
- **Simülasyonda kâğıt, acil durum ve söz olayı yok** (A3 ile aynı); "kalır" kuralı ile etkileşimi ölçülmedi.
- **Gürültü:** 20 tohum; doğan hata farklarının çoğu 1-2 standart hata; 3 ve 6 kişide ayırt edilemiyor. Poisson çekimi tohum ve kart kimliğiyle sabit olduğundan kollar arasında kart kimlikleri kaydığında bu ortak rastgelelik tam eşleşmiyor.
- **Δ_PM kolunun biçimi** (0,10 + 0,075 × Δ_PM) benim; başka biçim denenmedi.
- **Kurucu ve eşiği:** kurucu her alanda en az 2★ sayılır (A3'ün `tinfo`'su, Yazılım dahil); kurucunun Yazılım becerisi zaten 2★ olduğundan Yazılımda fark yok.
- **Gereksinimin altındaki iş için eğri uzatması** (Δ < 0) benim seçimim; R'nin işinin %1-8'i bu bölgede, sonucu bu seçim etkiler. Δ < 0'ı 0'a kırpmak R'nin hatasını azaltır, tarife karşı farkı küçültür. Ölçüm (A7, `a7neg.py`, 20 tohum): kırpınca R'nin doğan hatası 6 / 12 / 25 / 50 kişide %2,5 / %2,5 / %0,5 / %1,7 azalıyor (kaynaklı 6 kişide %7,9); tarif − R doğan hata farkı 6 kişide +0,8 ± 1,3 → +2,4 ± 1,0, 12 kişide −5,7 ± 1,9 → −2,5 ± 2,0, 25 kişide −9,6 ± 2,0 → −8,2 ± 2,4, 50 kişide −33,3 ± 4,0 → −23,3 ± 3,3, kaynaklı 6 kişide −1,6 ± 2,3 → +5,6 ± 2,1, kaynaklı 50 kişide −45,2 ± 4,4 → −36,6 ± 4,5.
- **Hacim-nötrlük yalnız 6 kişide kalibre** (K-H). Diğer hücrelerde R kolunda yeni model bugünkü doğan hatanın yaklaşık %95-97'sini (12-50 kişi, sınırsız arz), %84-86'sını (12-50 kişi, kaynaklı arz), 1 kişide %115'ini doğuruyor (§2.3 tablosu). Ekip büyüklüğüne göre ayrı kalibrasyon istenirse `c` ekip büyüklüğünün fonksiyonu olur; bu bir tasarım kararı, burada yapılmadı.
- **Elle atama** (A3'teki usta oyuncu) yeni hata modeliyle tekrar koşulmadı.

## 8. Yeniden üretim

Klasör: `docs/tasks/faz_cde/d_taslak/dsim/v3/atama/`. Hepsi `python -I`, en çok 2 işçi, her `chain6.sh` çağrısı 420 sn bütçeli ve önbellekli (eksik iş kalırsa yeniden çalışır).

```
python -I a6test.py micro | tail | pm | bk | regress 3       # doğrulamalar (regress: A3 kayıtlarıyla 0 fark)
python -I a6cal.py hedef ; python -I a6cal.py 0.205 0.21 0.212 0.213 0.215 ; echo 0.212 > out6/cal_h.txt     # K-H kalibrasyonu
bash run_a6.sh      # G1 K-H ana kollar, G2 PM kolları, G3 K-E, G4 bugünkü model
bash run_a6b.sh     # G5 tanı kolu T_plan
bash run_a6c.sh     # G6-G7 duyarlılık p = 0, 2  (c = 0.297@0, 0.137@2)
python -I a6dogrula.py                          # tohum sayısı, tahmin = sonuç, bulunan <= doğan
python -I a6hata.py H "PR|S2" R,T,BK ; python -I a6hata.py H S3 R,T ; python -I a6hata.py H S4 R,T ; python -I a6hata.py H S5 R,T ; python -I a6mvp.py H S2 ; python -I a6soz.py H ; python -I a6tani.py H R,T,T_np,T_min,T_np_min,T_plan,T_plan_np ; python -I a6hiza.py H S3,S4,S5
python -I a6iz.py mvp S2 1 R,T H ; python -I a6iz.py hata "PR|S2" 1 R,T H ; python -I a6iz.py soz "PR|S3" 12 T,R H
python -I -c "import a6test as T; T.H.CFG2.m0 = 0.25; T.micro()"     # sahte bozma: testler düşmeli (9/14)
python -I a6vals.py && python -I a6rapor.py     # bu belge (ATAMA/A6_HATA_MODELI.md)
```

`c(K-E)` hesabı: bir 3★ kişinin Yazılım hızı `BASE × Y(6) = 10 × (0,5 + 0,05 × 6 + 0,01 × 36) = 11,6` puan/hf; 3 sprint = 6 hf → 69,6 puan; `c = 100 ÷ (69,6 × 3^1) = 0,4789`.

Dosyalar: `hata2.py` (model, PM okumaları, `BK`, tanı seçeneği, `A6Sim`), `a6run.py` (kollar `ARMS`, koşucu), `a6test.py` (doğrulama), `a6cal.py` (K-H kalibrasyonu), `a6tab.py` ve `a6tablolar.py` (tablolar), `a6iz.py`, `a6hata.py`, `a6mvp.py`, `a6soz.py`, `a6tani.py`, `a6hiza.py` (izler), `a6dogrula.py`, `a6vals.py`, `a6rapor.py` (bu belge), `a6_metin.md` (belge şablonu), `chain6.sh`, `run_a6*.sh`, `out6/` (ham sonuçlar, günlükler).

## İnceleme notu (Opus)

A7 · 21 Ekim 2026 · tek tur, düzeltme hakkıyla. Godot koşturulmadı; oyun koduna, `strings.csv`'ye, `data/`'ya, `project.godot`'a dokunulmadı; git'te durum değişmedi. Yeni dosyalar yalnız `atama/` altında: `a7chk.py` (ham sonuçtan bağımsız yeniden hesap), `a7el.py` (elle kart hesabı, kapı verisi), `a7dag.py` ve `a7dag20.py` (kartların puan ve gereksinim dağılımı), `a7neg.py` ve `a7negtab.py` (Δ < 0 uzatmasının sınaması), `a7duzelt.py` (bu belgedeki metin düzeltmeleri); ham sonuçlar `out6/a7/`, `out6/a7neg/`. Düzeltmeden önceki belge `out6/a7/A6_HATA_MODELI_onceki.md`'de. Hata modelinin kodu (`hata2.py`) değişmedi; bulunan hataların hepsi metinde ya da yorumdaydı, bu yüzden ana koşular yeniden koşulmadı.

**Ne denetlendi**

1. Modelin kodu (`hata2.py`: `mfun`, `req_dev`, `ceiling`, `quality`, `on_test_done2`, PM okumaları, `alloc_gen`) ve yamaların gerçekten çağrıldığı yer (`D.on_test_done`, `A._pm_order_todo`, `A._pm_owners`, `A.prep_generic`, `A._alloc_erdem` modül düzeyinde değişiyor; `a3core` ve `dsim3` onları adıyla çağırıyor).
2. Elle kart hesabı (`a7el.py`) ve mikro testler (`a6test.py micro` 14/14, `a6test.py pm`).
3. K-H kalibrasyonu ham sonuçtan.
4. Ana tablodan 10 hücre ve 8 eşli fark, `a6tab.py`'yi kullanmayan ayrı bir betikle (`a7chk.py`).
5. Regress: yeni anahtarlar kapalıyken A3 kayıtlarıyla fark.
6. Belgenin sabit tablosu, özeti, bulguları ve Karar 20-21'in uygulanışı.

**Doğru bulunanlar**

- **Model Erdem'in ilkesini doğru okuyor.** Tavan = c × puan × gereksinim (kilitsiz kart 1★); oran m(Δ) = 0,20 × 0,5^(Δ/2): m(0) = 0,20, m(2) = 0,10, m(4) = 0,05 (koddan ve elle). Erdem'in örneği birebir: tavan 100'de 3★ → 20, 5★ → 10; tavan 5'te 1★ → 1,0, 5★ → 0,25 (fark 0,75 hata). Elle K-H (c = 0,212): 15 puanlık kilitsiz kart 1★ 0,636, 5★ 0,159; 40 puanlık 2★ kilitli kart 2★ 3,392, 4★ 1,696. Bugünkü modelden yalnız yapım kalitesi terimi değişiyor; test yakalama, TİTİZ ×0,5, düzeltme kartı ×0,3, PM hazırlığı (×0,90 → ×0,60, `h = 0,10 + 0,075 × (yıldız − 1)`) ve Poisson çekimi aynı (`_tail` bugünkü kodun H'den sonrasının kopyası).
- **Basit işte fark gerçekten küçük, karmaşık işte büyük.** K-H'de 1★ ile 5★ arasındaki mutlak fark 15 puanlık kilitsiz kartta 0,48 hata; 40 puanlık 2★ kartta 2★ ile 4★ arası 1,70 hata. Bugünkü modelde bu iki fark 0,33 ve 0,44. Yani yeni model karmaşık kartta farkı yaklaşık 4 katına çıkarıyor, basit kartta az büyütüyor.
- **Gereksinimin altında atama yok.** Tarif ailesinin bütün kollarında gereksinimin altındaki Yazılım işi 0,0 (`eligible` yıldızı gereksinimle karşılaştırıyor). Gereksinim ekibin en iyisiyle kırpılıyor (`creq`), ama Yazılım kapısı en çok 2★ ve her ekibin en iyi Yazılımcısı en az 2★ olduğundan bu kırpma hiçbir ekipte işlemiyor (S1-S6 en iyi Yazılım: 2 / 3 / 3,5 / 4 / 4 / 4★).
- **K-H hacim-nötr.** 6 kişi, R, sınırsız arz, 21-60. hafta, 20 tohum: bugünkü model doğan hata 59,80 (beklenen 60,13); c = 0,212 ile 60,95 (+%1,9), beklenen 59,63 (−%0,8). İkisi de ±%2 içinde. Beklenen değeri tam tutturan c yaklaşık 0,2133 olurdu; fark önemsiz.
- **Ana tablo ve eşli farklar doğru.** Ham sonuçtan yeniden hesap, belgeyle aynı: tarif teslim 25 kişi 260,85 (belge 260.9); R açık hata kaynaklı 3 kişi 14,53 (14.5); tarif açık hata kaynaklı 3 kişi 32,43 (32.4); tarif kaçan söz kaynaklı 6 kişi %6,06 (6.1%); R kaçan söz kaynaklı 6 kişi %1,13 (1.1%); `BK` teslim 50 kişi 504,20 (504.2); R teslim kaynaklı 50 kişi 428,88 (428.9); tarif açık hata 12 kişi 11,75 (11.8); `BK` kaçan söz kaynaklı 6 kişi %14,60 (14.6%); tarif MVP 3 kişi 6,40 (6.4). Eşli farklar (ortalama ± standart sapma ÷ √20): teslim kaynaklı 50 kişi −30,86 ± 0,90 (20/20); açık hata kaynaklı 3 kişi +17,90 ± 2,11 (0/20); doğan hata 50 kişi −33,30 ± 3,96 (20/20); kaçan söz kaynaklı 6 kişi +4,93 ± 1,88 pp (3/20); doğan hata 12 kişi −5,65 ± 1,90 (14/20); MVP 3 kişi +2,40 ± 0,18 (0/20); `T_zor` − tarif teslim 12 kişi +0,90 ± 0,39 (5/20); tarif − A3 tarifi doğan hata 50 kişi −29,10 ± 3,86 (19/20). Hepsi belgeyle aynı. §2.3'ün yeni ÷ bugünkü oran satırları da (12 hücre) aynı.
- **Regress geçti.** `a6test.py regress 5`: R ve E kolları, S1-S6 ve kaynaklı S2-S4, 5 tohum, 4.320 metrik, 0 fark (`out6/a7/regress5.txt`; 1 tohumla 864 metrik, 0 fark, `regress1.txt`).
- **Karar 20 doğru uygulanmış.** Söz kartına öncelik veren anahtar (`D3_PROMISEFIRST`) kapalı; tarifin sırası gereksinim, kalan iş ve plan sırasıyla, söz terimi yok.
- **Karar 21 doğru uygulanmış.** (i) kartları karmaşıklığa (puan × gereksinim) göre dizip PM'lere kapasiteleriyle orantılı ardışık dilimler veriyor, en karmaşık dilim en iyi PM'e, en basit dilim en zayıf PM'e (`a6test.py pm`: 40 puanlık iki kart 5★, 15 puanlık iki kart 1★ PM'e); (ii) her kartı zamanı kalan en iyi PM'e veriyor. PM'in kapısını geçemediği kart en yakın uygun PM'e kayıyor.
- **Karar 22** yalnız not olarak duruyor (§5 madde 8), ölçüm iddiası yok.
- Sabit tablosu tek tabloda ve tasarım sabitleri "onay bekliyor"; değişmeyen bugünkü sabitler "değişmiyor" diye ayrılmış.

**Hatalar ve düzeltmeler (eski → yeni)**

1. **Simülasyonda 3★ isteyen kart yok; belge örneklerini onunla kurmuştu.** Kapı verisinde Yazılım kilidi en çok 2★ (dokuz hattın dördünde K2 ve K3'te 2★, gerisinde kilit yok). §0 tavan örnekleri ("K3 kartı R = 3, tavan 57,5"), §1 madde 2 ("3★ isteyen 40 puanlık kart, 3★ → 5,1, 5★ → 2,5"), Erdem'e soru 1 ("aynı kartın hatası 5,1 / 11,5") ve §7 ("R ≤ 3") var olmayan bir kartı anlatıyordu. Düzeltme: örnekler simülasyonun en zor kartıyla yeniden yazıldı (40 puan, 2★ kilit: K-H 2★ → 3,4, 4★ → 1,7; K-E 2★ → 7,7, 4★ → 3,8), §0'a işaretli not eklendi, §7 "R yalnız 1 ya da 2" oldu. Sonuçların sayıları değişmedi, çünkü koşular gerçek kapı verisiyle yapılmıştı.
2. **Kazancın küçüklüğünün iki nedeni eksikti.** (a) Kartlarda karmaşıklık farkı küçük: sınırsız arzda ölçüm penceresinde teslim edilen bütün özellik kartları 40 puan; 6 kişide 20 tohumda kartların %68'i kilitsiz (R = 1), %32'si 2★ kilitli; en karmaşık kartın tavanı en basitininkinin yalnız 2 katı (kaynaklı arzda 15, 25 ve 40 puanlık kartlar karışık). (b) Kazancın bir kısmı benim değil A6'nın seçtiği bir uzatmadan geliyor: gereksinimin altındaki kişiye (yalnız R'de olur) daha yüksek hata oranı (Δ = −1'de 0,283). Bu uzatma kaldırılınca (`a7neg.py`, 20 tohum) tarif − R doğan hata: 6 kişi +0,8 ± 1,3 → +2,4 ± 1,0; 12 kişi −5,7 ± 1,9 → −2,5 ± 2,0; 25 kişi −9,6 ± 2,0 → −8,2 ± 2,4; 50 kişi −33,3 ± 4,0 → −23,3 ± 3,3; kaynaklı 6 kişi −1,6 ± 2,3 → +5,6 ± 2,1; kaynaklı 50 kişi −45,2 ± 4,4 → −36,6 ± 4,5. Belgede bu [DEĞERLENDİREMEM, koşulmadı] idi; şimdi ölçüm olarak §1 madde 4, §5 madde 2 ve §7'de.
3. **K-E'nin "iki kat" sonucu tanıma çok bağlı, belge bunu söylemiyordu.** "3 sprintlik iş" = 69,6 puan, bir 3★ kişinin 6 haftalık Yazılım işi; ama tavan kartın toplam puanıyla (Tasarım + Yazılım + Test) çarpılıyor ve K3 kartının yalnız ortalama %55'i Yazılım. Tanım makul ama tek okuma değil: "Yazılım aşaması tek başına 3 sprint süren kart" okunursa c = 0,264 ve hacim bugünkünün 1,23 (6 kişi) / 1,20 (50 kişi) katı; Erdem'in 3★ işi simülasyonun en zor kartına (2★) eşlenirse c = 0,718 ve 2,82 katı (6 kişi; R kolu, 20 tohum, `out6/a7/`). Düzeltme: §1 madde 3, soru 1, §5 madde 6, §7'ye eklendi ("1,2 ile 2,8 kat arası"). Bu, belgenin K-H önerisini güçlendiriyor.
4. **§1 madde 6: "standart hatanın 1-2 katı" yanlıştı.** (ii) − (i) teslim farkı 12 / 25 kişide standart hatanın 2,3 / 3,7 katı (ayırt edilebilir), 50 kişide 0,7 katı; doğan hata farkları 1,9 / 0,1 / 1,3 katı (ayırt edilemiyor). Düzeltildi. Aynı nedenle §5 madde 4'teki "doğan hatada (ii) 12-50 kişide önde" → "önde görünüyor ama ayırt edilemiyor".
5. **§4.3: iki farklı ölçü tek cümlede.** `T_plan`'ın kaçan sözü %1,9 tohum ortalamasıydı, yanındaki `T_plan_np` %1,4 ise toplam vadesi gelen karta bölünmüş oran (`a6tani.py`); cümle ikisini de `a6tani.py`'ye bağlıyordu. Bu ölçüde `T_plan` %2,0. Düzeltildi.
6. **§7: kurucu.** "Yazılım yıldızı ham" yanlıştı: kod kurucuyu her alanda (Yazılım dahil) en az 2★ sayıyor; kurucunun Yazılımı zaten 2★ olduğundan sonuç değişmiyor. Düzeltildi.
7. **§0 satır 10** değeri yalnız §0.1'deydi; tabloya işaretli olarak yazıldı (0,212). Türkçe ek hataları: "%7,7'i" → "%7,7'si", "%3,6'ü" → "%3,6'sı", "%1,9'e" → "%1,9'a".

**Erdem'in bilmesi gerekenler**

- **Model senin ilkeni doğru kuruyor ve senin örneğini birebir veriyor.** Bu belgeye kadar ölçülen her şey (sıralar, bedeller, PM okumaları) yeniden hesapta aynı çıktı.
- **Simülasyonun kartları ilkeyi sınamak için dar.** Bugünkü hatlarda hiçbir kart 2★'tan fazla Yazılım istemiyor ve ekiplerde 5★ kişi yok (en iyisi 4★). Senin "3★ 20 hata, 5★ 10 hata" örneğin simülasyonda hiçbir kartta yaşanmıyor. İlkenin oyunda hissedilmesi için kart kilitlerinin 3-5★'a yayılması gerekiyor; bu A6'nın değil kart verisinin (Faz D'nin hat ve kapı tasarımının) işi.
- **Tarifin "daha az hata" kazancı küçük ve bir kısmı model seçiminden.** Gereksinimin altındaki kişiye daha çok hata yazan uzatma kaldırılınca 12 kişide kazanç kayboluyor, 6 kişide tarif bugünkü kuraldan biraz fazla hata üretiyor; 25-50 kişide kazanç sürüyor (%3 ile %4 arası). Bu uzatma "onay bekliyor" listesinde (§0 satır 3); onu kabul edip etmemen tarifin kazancını doğrudan değiştirir.
- **Tavanı senin sayılarına birebir bağlamanın bedeli "3 sprintlik iş"i nasıl okuduğumuza bağlı:** bugünkünün 1,2 katı ile 2,8 katı arası hata. Hacim-nötr ayar (K-H) bu belirsizliği taşımıyor; önerim değişmedi.
- **Tarifin bedelleri (MVP gecikmesi, düzeltme kartlarının beklemesi, kaçan söz) hata modelinden değil, tarifin 1. adımının sırasından** geliyor; bu bulgu her denetimde tuttu.
- **PM için (ii) okuması** bugünkü PM kuralıyla neredeyse aynı (en iyi PM'den başlayıp kartları büyükten küçüğe dağıtmak); tek fark sıralamanın "puan × gereksinim" ile yapılması. Bu yüzden ucuz.

**Hüküm:** A6'nın ölçümü doğru, kodu doğru, hacim-nötr kalibrasyonu doğru; regress geçti. Hatalar metindeydi (var olmayan 3★ kartla verilen örnekler, eksik iki neden, K-E'nin tanıma bağlılığı, bir standart hata ifadesi, iki küçük ölçü ve kod tarifi hatası) ve düzeltildi. Belge Erdem'e gidebilir.
