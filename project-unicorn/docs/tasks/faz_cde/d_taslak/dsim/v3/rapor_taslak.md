# Faz D · Ekip modeli v3 simülasyon raporu
Hazırlayan: simülasyon alt ajanı, 17 Ekim 2026 gecesi. Repo kodu değişmedi, Godot koşturulmadı, commit yok. Kaynak: `D_MODEL_v3.md` §6 ("Simülasyon tanımı") ve §4, `SPRINT_DUZENI.md` (bundan sonra SD) §4 ile §5, `D_SIM.md` (v2 raporunun biçimi ve kapıları). Model değiştirilmedi; önerilerin etkisi ayrı koşularla ve "Öneri" etiketiyle §8'dedir.

Betik: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dsim3/dsim3.py` (v2 betiği `dsim/dsim.py` olduğu gibi kaldı; kopyası aynı klasörde `dsim_v2_base.py`). Koşu betikleri, ham sonuçlar ve tablo üreticileri aynı klasörde (§10).

## 0. Erdem'e özet
1. v3 modelini betiğe birebir işledim ve belgenin ön hesabını bağımsız olarak yeniden ürettim: 1, 3, 6, 12, 25 ve 50 kişide haftalık iş 4,5 · 19,6 · 48 · 107 · 265,5 · 539 puan, belgeyle fark %0,1'in altında. Toplam 8.220 koşu, her senaryo 20 tohum; ana koşular 60 hafta, arz ve EA 130, A'nın sınırları 80 hafta.
2. 23 kapının 18'i geçti, 5'i kaldı: `kurucu_buyume` (2), `pm_yildizi` (11), `arz_havuzu` (16), `oneri_dolulugu` (19), `takim_bolme` (22). Her birinin tanısı, önerisi ve önerinin etkisi §8'de; model öneriyle karıştırılmadı.
3. Plan tahmini sonuçla tam tutuyor: 8.220 koşuda kart başına aşama ilerlemesi, bitiş zamanı, hata sayısı, bulunan hata ve düzeltme işinin farkı en çok 1,4e-14.
4. Ölçekte hata kontrolde kalıyor: kişi başı iş 4,5'ten 10,8'e çıkıyor, açık hata medyanı 6,8 · 8 · 8 · 9,5 · 12 · 17, düzeltme payı %29'dan %3'e iniyor. Hata sprinti yalnız tek kurucuda ve 507 sprintin 3'ünde.
5. Testçi artık değer taşıyor: 1★ yerine 5★ testçi kaçan hatayı (100 puan başına) %57 ile %64 azaltıyor ve bulunan hatayı 2,3 ile 2,7 katına çıkarıyor. Testçisiz yerine 3★ testçi teslimi %9 ile %14 artırıyor, kaçan hatayı %25 ile %36 azaltıyor.
6. "Bu haliyle gönderelim mi" sorusu 6, 12 ve 25 kişide sprintlerin %21,5 · %29,2 · %18,5'inde çıkıyor (en çok üç sprintte bir). Hep gönder ile hep bırak arasında teslim farkı en çok %0,9; hep gönderen oyuncunun açık hatası en çok %13,8 artıyor.
7. "Tek başımayken daha hızlıydım" kaygısı ölçüldü: dört kurucu tipi, altı alım sırası, üç alımın 72 adımının hepsinde şirket teslimi arttı, MVP hiçbir alımla gecikmedi. Ama kurucunun kendi işi bir dizide tabanın %10,1 altına iniyor (kapı %10) ve %2'den büyük 16 düşüşün 9'unda aşama değişmiyor, iş yeni gelenle bölünüyor.
8. Sprint düzeni: bugünkü sonlu katalog 3, 6, 12, 25 ve 50 kişide 37, 18, 12, 9 ve 7 haftada bitiyor; bitince 6 kişi ve üstünde teslim sıfır. Kaynaklı arz 12 kişiye kadar ve 1 → 10 kişilik büyüme eğrisinde yetiyor (kart yok sprinti %0), 25 kişide sprintlerin %80'inde, 50 kişide hiçbirinde aday havuzu hedefte (derinlik kartı üst sınırı 4 × 9 hat = 36, 50 kişinin hedefi 37,5).
9. EA takım: 50 kişi takımsız 411 puan/hf; 3 liderli takım 305 (−%26), 7 takım 253 (−%39). Fark, takım hız çarpanı ile takıma bağlı arzdan boşta kalmanın çarpımıyla 3 ve 7 takımda %92 ile %100 açıklanıyor (67-130. hf). Takım büyüklüğü 8'i aşınca kişi eklemek teslimi 2,9 puana kadar düşürebiliyor.
10. Belgede düzeltilecekler (§9): "kurucunun işi en çok %7 düşer" gerçekte %10,1; PM kapısı kendi tablosuyla (23 kişide −%20) çelişiyor; 1 haftalık sprintte tek kurucuda düzeltme kartı (en az 5 puan) kapasitenin yarısından büyük ve sprintlerin %50'si hata sprinti oluyor.

## 1. Yöntem
- **Tohum ve pencere.** Tohum 1 ile 20. Ana koşular 60 hafta; ölçü penceresi kapanışı 20. haftadan sonra olan sprintler (21-60). Arz kipleri ve EA 130 hafta (EA'da 21-60 modül öncesi, 67-130 modül sonrası); D5 80 hafta. Ölçüler 20 tohumun medyanı; hata sprinti ve soru sıklığı 20 tohumda havuzlanmış (belgenin §4.8 yöntemi).
- **Uygulama.** v2 betiği (`dsim.py`) kopyalanıp §6'ya göre güncellendi: ×5 ölçek, dört aşamalı kart (Düzeltme), hata yükü 0,04, yakalama 0,57 × √Y ve kendi kartı ×0,6, test anında kart tohumuyla n ve F, hafif/ağır düzeltme işi, bilinen hata ve soru, dört politika, hazırlık eğrisi ve yıldıza bağlı fayda, en iyi PM, kurucu tabanı 0,86 ve güçlü alan kuralı, düzeltme kartı 2 puan/hata, A'nın sınırları için k, sonlu / kaynaklı / EA arzı, hesap isteği, derinlik kartı, EA takım kipi. Her formülün belge paragrafı betik yorumunda yazılı.
- **Bağımsızlık.** `dmodel3/dsim3.py` prototipi yalnız okundu, §6 ile çeliştiği yerde §6 izlendi. Sonuçlar prototiple ve belgenin §4.2 ile §4.7 tablolarıyla karşılaştırıldı: ölçek, uç bileşim, marjinal getiri, testçi yıldızı, PM yıldızı ve kurucu büyümesi tabloları 0,1 puan içinde örtüştü. Yani §6 tek başına yeterli bir tanım.
- **Süre.** 4 işçi; ana koşular yaklaşık 27 dakika, öneri kolları yaklaşık 25 dakika; en ağır koşu 130 haftalık 50 kişilik EA (tohum başına 5-8 saniye).
- **Öneri kolları** `D3_<AD>` ortam değişkenleriyle açılır; varsayılan belgedeki değerdir. Öneri sonuçları `out/P_*.pkl` dosyalarında, taban sonuçlardan ayrı.

### 1.1 Yorumlar (belgenin açık bırakıp benim seçtiğim yerler)
1. **PM_BEST (§6.4).** "Sprintte payı olan PM'lerin en yüksek Ürün puanı" hafta düzeyinde uygulandı: o hafta hazırlık işi yapan PM'lerin en yüksek puanı. Sprint düzeyi gelecek haftaları bilmeyi gerektirir. PM'ler hazırlık hızına göre sıralı çalıştığı için en iyi PM her zaman ilk iş alır; fark ancak en iyi PM'in o hafta boşta olmadığı durumda doğar.
2. **Kurucunun güçlü alanı (§3.4, §6.3).** Puanı ≥ 5 olan ve üç alanın (Tasarım, Yazılım, Test) en büyüğü; eşitlikte hepsi sınıf 0.
3. **Kart tohumu (§6.7).** `random.Random("<tohum>:<kart kimliği>")`; kart kimliği kartın oluşturulma sırası. Plan oynatmasının kopyaları kimliği korur, bu yüzden plan ve kapanış aynı n ve F'yi çeker.
4. **Katalog (SD arz.py).** Sonlu, kaynaklı ve EA'da 9 hat, profiller üçerli blok (0-2 tasarım, 3-5 geliştirme, 6-8 test ağırlıklı), MVP hatları 0, 3, 6; sınırsız kipte 12 hat (v2).
5. **Hesap eğrisi (§6.4).** MVP'den sonra haftada 3 hesap (ya da sabit N); her hesap 9 hattan 3'ünü kullanır; koltuk 5 ile 150 arası log düzgün; ilk istek 1 ile 52. haftada, sonra 52 haftada bir. Hesap özellikleri hesap sırasına bağlı ayrı tohumdan gelir (koşu RNG'sine dokunmaz).
6. **İstek kartı (§3.13 C).** Hesabın seçtiği hatta K3 bitmemişse açık kademe vardır ve istek o kartın yerine geçer (kart doğmaz); K3 bitmişse kendi kartı olur. Boyut koltukla (< 20: 15, 20-99: 25, ≥ 100: 40). §6 istek süresi vermiyor: 8 hafta içinde alınmayan istek düşer (yorum).
7. **Derinlik kartı (§3.13 B).** K3'ü biten hatta açık derinlik kartı = 1 + ⌊hattı kullanan hesap ÷ 10⌋, en çok 4; boyut 15 / 25 / 40 sırayla. "Alan" = hat numarası mod 4 (B2B'de 4 alan). Kazanç çarpanı 0,75^(k−1).
8. **Öneri sırası (§3.12 b, §6.5).** Benzetimde söz ve alan puanı yok. Sıra §6.5'teki gibi: düzeltme kartları, bırakılan ve devreden kartlar (sprint başında zorunlu), sonra adaylar: istekler (tarihe göre), kademe kartları (oluşma sırası), derinlik kartları. Basamak (5) "en zayıf alan" atlandı, (6) "etki ÷ iş" yerine oluşma sırası.
9. **EA takım (§3.14, §6.5 adım 7).** Kişiler role göre dengeli dağıtılır; kurucu takım 0'dadır (takımsız havuzda kart olmadığı için); hat → takım 9 hattın bloklara bölünmesi, 60. haftada gelen 4 modül hattı en az hatlı takıma. Takım dışı akış yok (K10). Kapasite ve tavanlar takım başına.
10. **Büyüme eğrisi (SD §5.2).** 1 kişi; 12. haftada 3 kişi (7 puanlı geliştirici ve 6 puanlı tasarımcı); 30. haftada 6 kişi (S3'ün PM, geliştirici, testçisi); 60. haftada 10 kişi (iki geliştirici, tasarımcı, testçi). Alımlar sprint başında uygulanır.
11. **Gerçek zamanlı kurucu büyümesi.** Alımlar 8, 14, 20. haftada; en yakın sprint başında uygulanır.
12. **Kapı 2.** Kurucunun işi = kurucunun log'una giren puan/hf (21-60). Neden "aşama değişti" = baskın aşama değişti ya da aşama payı en az 0,20 kaydı. Düşüş eşiği önceki adıma göre %2.
13. **Kapı 6 ve 7.** Ekip yalnız kurucu ve PM ise (PM sprint kapasitesi katmaz) tek kurucu eşikleri uygulandı. "Toplam hata işi" = düzeltme payı medyanı + sprint içi düzeltme (belgenin §4.2 yöntemi).
14. **Kapı 16.** Plan başında hücrenin sıralı aday listesinin uzunluğu (devreden ve düzeltme kartları hariç) ≥ 0,75 × kişi (8'in altında ≥ kişi); ölçü sprintlerin payı.
15. **Kapı 17.** Boşta süre her olay aralığında nedene bölünür: kişi açık bir aşamaya uyuyor ama kadro dolu (aşama dolu); sprintte açık aşamalardan hiçbirine uymuyor (rol uymuyor); sprintte biten kart dışında kart kalmamış (kart yok); PM'in artan zamanı (hazırlanacak kart yok). Dört nedenin toplamı her koşuda boşta'ya eşit (en çok 1,4e-8 fark).
16. **Kapı 18.** "Kart yok sprinti" = planın adayları bitti (durma nedeni arz) ve o sprintte "kart yok" nedeniyle en az 1 kişi-hafta boşta.
17. **Kapı 19.** Öneri doluluğu = öneri işi ÷ (öneri işi + öneri durduktan sonraki ilk 12 adaydan planın kurallarına uyup eklenebilecek iş). Öneri ilk uymayan adayda durur (§6.5 adım 4).
18. **Kapı 15.** k her hafta hesaplanır: canlı hat ÷ 9 ve √(son 8 haftanın haftalık teslimi ÷ 55). Benzetim 12 hatlı olduğu için k tabanı 1,33'tür; 9 hat varsayımıyla (en çok 9) ayrıca hesaplandı.
19. **Kapı 9.** "En iyi testçinin c'si" = kartın testinde çalışanların ×0,6 öncesi c'lerinin en büyüğü.
20. **Kapı 22, kişi ekleme.** Eklenen kişi dağıtımdan sonra takım 0'a konur. İlk sürümde dağıtımdan önce konuyordu ve diğer kişilerin yerleşimini kaydırıyordu; düzeltildi, yalnız EA kişi ekleme koşuları yeniden koşuldu.
21. **Politikalar (§6.7).** `bırak` = soruya hep bırak; `gönder` = soruya hep gönder; `eşikli` = soru geldiyse ağır bilinen hatası olmayanları gönder; `hep gönder` = soru olmasa da test bitmiş kartları gönder.

## 2. §6.9 elle doğrulama
@@check@@

Sekiz örneğin sekizi de tutuyor. Üçüncü satırdaki süre hata yokken ölçüldü (`H0` bu örnek için 0).

## 3. Ölçek tablosu (1, 3, 6, 12, 25, 50 kişi; sınırsız arz)
Teslim = biten özellik kartlarının hazırlıksız büyüklüğü, puan/hf. Hata sprinti = düzeltme payı > %50 olan sprint / pencere sprinti (20 tohum toplamı).

@@scale1@@

@@scale2@@

Belgenin ön hesabıyla karşılaştırma (D_MODEL_v3 §4.2):

@@vsdoc@@

- **Hata ölçekle patlamıyor.** 3 kişiden 50 kişiye kaçan hata / kart 1,09'dan 0,44'e iniyor (testçi payı büyüdükçe), düzeltme payı %9,5'ten %3'e. Açık hata ekiple yavaş büyüyor (8 → 17).
- **Boşta payı** 1-6 kişide %16-17 (yapısal: sprint sonu boşluğu ve tasarım/test tek kişide), 12 kişide %10, 25 ve 50 kişide %2-3.
- **Darboğaz** (kalan iş ÷ aşama kapasitesi) 3 kişiden itibaren Test: testçi payı %20'de bile sprint sonunda test kuyruğu en yüklü aşama.
- **Bilinen hata sorusu** 3 kişide %4,5, 6 kişide %21,5, 12 kişide %29,2, 25 kişide %18,5, 50 kişide %4,2: küçük ve çok büyük ekipte nadir, 6 ile 25 kişi arasında en çok üç sprintte bir.

### 3.1 Testçinin etkisi (ölçeğe göre)
Hücre: teslim · kaçan hata / 100 puan.

@@tester@@

1 ve 3 kişide kurucu ve geliştirici kendi kartını test ediyor (×0,6); testçi eklemek teslimi de artırıyor (4,5 → 7,3 ve 19,6 → 26,9) ve kaçan hata / 100 puanı 3,89'dan 1,83'e (1 kişi), 3,00'den 1,85'e (3 kişi) indiriyor.

## 4. Uç bileşimler
@@uc@@

Hiçbirinde model çökmüyor; kırık bileşim boşta kişi ve darboğaz olarak görünüyor. Belgenin §4.3 değerleri (parantezde) birebir tutuyor.

## 5. Marjinal getiri ve kişi ekleme eğrisi
### 5.1 Taban ekibe bir kişi eklemek (puan/hf; parantezde eklenen ekibin kaçan hatası / kart)
@@marj@@

En düşük hücre −1,0 (S3'e 3★ tasarımcı: ekipte tasarım darboğaz değil, hazırlıklı kartlarda tasarım ihtiyacı küçük). Kapı sınırında.

### 5.2 Kişi ekleme eğrisi (1 → 50 kişi, S6 oranı; seçili adımlar ve her negatif adım)
@@curve@@

@@curve_role@@

@@curve_neg@@. Tasarımcı adımları en değerli (ortalama +28,5), PM (+3,7) ve geliştirici (+7,1) adımları en küçük; 49 adımın 46'sı artı. 37. kişi (PM) −0,5. Belge, en iyi PM kuralı olmadan bu adımın −2,5 olduğunu yazıyor; kural bu turda kapalı koşulmadı.

## 6. Yeni senaryolar
### 6.1 Kurucu büyümesi (D4): tek → +1 → +2 → +3
Hücre: şirket teslimi / kurucunun kendi işi (puan/hf) / MVP haftası. Alınanlar 2,5★ (1★ satırı ayrıca).

@@founder@@

- Şirket teslimi 72 adımın 72'sinde arttı (en küçük artış +0,2: güçlü kurucuya üçüncü geliştirici). MVP hiçbir alımla gecikmedi; güçlü kuruculu ekipte üç alımdan sonra 4'ten 2'ye inen diziler var.
- Kurucunun kendi işi tabana göre en çok −%10,1 (5★ kurucu, üç geliştirici). Bu, belgenin "en çok %7" cümlesinden büyük (§9). Önceki adıma göre −%20,9'a varan düşüşler önceki adımdaki geçici yükselişin geri dönüşü (ör. 5★ kurucuya tasarımcı gelince 12,4 → 14,4, sonra geliştirici gelince 11,4).
- %2'den büyük 16 düşüşün nedenleri: 7'sinde baskın aşama değişti; 8'inde aşama aynı ama kurucunun o aşamadaki payı düştü (iş yeni gelenle bölündü); 1'inde PM geldi ve kart hazırlıkla küçüldü. Kapının yalnız "aşama değişti" nedeni 9 düşüşü açıklamıyor (§8.1).
- **Gerçek zaman** (alımlar 8, 14, 20. hafta; teslim puan/hf, 6 haftalık pencereler):

@@founder_rt@@

  @@founder_rt_n@@. Dördü "üç geliştirici" dizisi (üçüncü geliştirici gelince 6 haftalık teslim %10 ile %36 düşüyor: 14,2 → 11,7, 11,7 → 7,5, 11,7 → 10,4), biri "testçi → geliştirici → tasarımcı". "Üç geliştirici" dizisi zaten doygun: tasarım ve test kurucuda kalıyor, teslim 9,3 → 11,8 (+%27, üç kişiye). Pencere 6 haftalık ve sprint kartları 15 ile 40 puan olduğu için ±%3 gürültü payı var; sonuçlar yön gösterir.

### 6.2 PM yıldızı ve kaç kişiyi beslediği (D3)
@@pm@@

- 1★ PM bile PM'siz ekibi 6 ve 11 kişide %7 ile %9 hızlandırıyor (23 kişide %3,8); 1★'dan 5★'a teslim +%11 ile +%23, kaçan hata −%20 ile −%43 (belge §4.6 ile aynı).
- 23 kişide tek PM kartların yarısını hazırlıyor (hazır kart %34 → %51): hata çarpanı yalnız hazır karta uygulandığı için 5★ faydası yarım ekibe yayılıyor. Bir PM'in beslediği kişi sayısı tabloyla tutarlı (1★ yaklaşık 7, 5★ yaklaşık 12).

### 6.3 Bilinen hata politikaları (D2)
@@pol@@

- Hiçbir politikada hata sprinti yok (S1 3/507 hariç, tek kurucu). Hep bırak ile hep gönder arasında teslim farkı en çok %0,9 (S4); hep gönder kartı 0,1 ile 0,2 hafta erken çıkarıyor, açık hatayı en çok %13,8 (S10) ve kaçan hatayı %14 ile %33 artırıyor (S6 ve S10).
- Eşikli politika (ağır bilinen hata yoksa gönder) iki uç arasında: S4'te kaçan / 100 puan 1,46 (bırak), 1,57 (eşikli), 1,71 (gönder).
- S2'de (kapsam dışı) gönder teslimi 19,6'dan 19,1'e (−%2,5) düşürüyor; nedeni bu turda ayrıca ölçülmedi.

### 6.4 Sprint düzeni: arz kipleri ve kart sayısı ölçeği (`SPRINT_DUZENI.md` K7, K8)
Sonlu katalog (9 hat, 27 kart) tükenme haftası (2 hf sprint, 20 tohum medyanı): 3 kişi **37**, 6 kişi **18**, 12 kişi **12**, 25 kişi **9**, 50 kişi **7**; tek kurucu 140 haftada bitmiyor (20 tohumun 1'inde bitti). SD §4.1'in 32 · 16 · 11 · 9 · 7 değerleri v3 modelinde 0 ile 5 hafta geç (tahmin: düzeltme alt aşaması ve kurucu tabanı).

@@supply@@

- **Sonlu katalog** 6 kişi ve üstünde 21-60. haftada teslim sıfır, sprintlerin %100'ü "kart yok". 3 kişide %70'i (2 hf) ya da %20'si (1 hf).
- **Kaynaklı arz** 12 kişiye kadar yetiyor (açık aday ≥ hedef %100, kart yok sprinti %0). 25 kişide sprintlerin %20'sinde, 50 kişide tamamında aday havuzu hedefin altında; 50 kişide boşta %27 (1 hf) ile %42 (2 hf), baskın neden "aşama dolu".
- **Boşta nedenleri** kaynaklı arzda: 3 kişide "rol uymuyor"; 6 ile 12 kişide PM'in "hazırlanacak kart yok" payı baskın; 25 kişide "aşama dolu" ile eşit; 50 kişide "aşama dolu".
- **Öneri doluluğu** 3 kişide %77 ile %87, 6 kişide %89, 12 kişide %94 ile %95 (kapı 19).

Büyüme eğrisi (1 → 3 → 6 → 10 kişi, 130 hafta):

@@growth@@

- Kaynaklı arzda büyüme eğrisi 130 hafta boyunca arzda sıkışmıyor: kart yok sprinti %0, açık aday hedefte %100. Ama arzın taşıyıcısı istek akışı: oluşan 485 kartın 420'si istek, 41'i derinlik, 24'ü kademe; teslim puanının %89'u istek kartı. Derinlik kartı bu ekip büyüklüğünde arzın küçük payı (%2 puan); kademe ve istek kartları ekibi doyuruyor.
- İstek kartlarının 298'i yapıldı, 48'i süre dolunca düştü, 20'si kademe kartının yerine geçti. İstek 8 haftalık süre varsayımıyla düşüyor (yorum 6).

Sabit hesap sayısıyla istek payı (S3 ile S6, 60 hf):

@@istek@@

- Hesap sayısı arttıkça isteğin payı artıyor: 330 hesapta 6 kişide %75, 12 kişide %84, 25 kişide %57, 50 kişide %35 (teslim puanında). 330 hesapta 6 kişilik ekip 256 istek kartının yalnız 90'ını yapabiliyor, 101'i süre dolunca düşüyor: küçük ekipte istek akışı ekibi aşıyor, büyük ekipte yetmiyor.
- 50 kişi 330 hesapta bile sınırsız arzdan (539) %28 geride (386) ve boşta %23; derinlik kartı üst sınırı bunun ana nedeni (kapı 16, §8.3).

Bu bölümün ek ölçüsü `planlama_eylemi` (SD §5.2) yapısaldır: öneriyi uygula ve başlat, iki eylem, her boyutta; benzetimde ölçülmedi. `plan_suresi` yalnız Godot'ta ölçülür (D0).

### 6.5 EA takım (D1, K10): 50 kişi, 130 hafta
@@ea@@

Takımsıza göre farkın açıklaması: tahmin = takımsız teslim × takımların kişi ağırlıklı ortalama hız çarpanı × (1 − boşta) ÷ (1 − takımsız boşta).

@@ea_expl@@

- Fark iki sayıyla açıklanıyor: takım hız çarpanı (kişi başı %2 kayıp ve lider) ve takıma bağlı arzdan boşta kalma. 67-130. haftada 3 takımda %100, 7 takımda %92, lidersiz 3 takımda %100, lidersiz 7 takımda %95; modül öncesi pencerede (21-60) %76 ile %92.
- 17 ve 16 kişilik takımlar ×0,81 ile ×0,95 çarpanla çalışıyor (lider 4, 6, 8); 8-7 kişilik 7 takımın çarpanı ×0,92 ile ×1,13 (kayıp yok ama hat başına arz küçük): boşta %49.
- Lidersiz takım her koşulda daha yavaş (3 takım −%40, 7 takım −%48): lider çarpanı 0,85 ile 1,20 arası ve ortalama lider (Liderlik 6) 1,06 yapıyor.
- **Hiçbir takım düzeni takımsızdan hızlı değil.** Takımın kazancı bu benzetimde ölçülmüyor (oyuncunun planlama eylemi 26 → 2 ile 7); kayıp ise ölçülüyor. Takım satırı yalnız hız çarpanını yazarsa oyuncu kaybın yarısını görmez.

Takıma bir kişi eklemek (takım 0, puan/hf; 21-60 / 67-130):

@@ea_marg@@

### 6.6 D5: A'nın sınırları oranlı (80 hafta)
@@d5@@

- Hiç düzeltmeyen ekip her ölçekte MVP'den sonra 15 ile 23,5 haftada (yaklaşık 4 ile 5 ay) k × 30'a varıyor; düzenli düzelten ekip hiçbir ölçekte, hiçbir tohumda varmıyor (120 koşu).
- Mutlak 30 ile 50 kişilik ekip 5 haftada varıyordu; oranlı kuralla 15 hafta. Düzenli düzelten 50 kişilik ekibin tepesi 29 (mutlak 30'a 7/20 tohumda değiyordu).
- 12 hatlı benzetimde k tabanı 1,33; 9 hatlı oyunda S1 ile S3 için eşik 30 ve varış 23 · 17 · 16 hafta.

### 6.7 Plan tahmini = sonuç kontrolü (§3.11, kapı 14)
Her sprint başında plan, kartların kopyalarını aynı oynatma fonksiyonuyla (önden tasarım ve hazırlık kuyruğu dahil) 2 hafta oynatır; sprint bitince gerçek kartlar kopyalarla karşılaştırılır. Karşılaştırılanlar: kart başına dört aşamanın ilerlemesi, bitiş zamanı, kartın n (hata sayısı), F (bulunan) ve düzeltme işi toplamı. Hata sayısı kart tohumundan test anında çekildiği için plan ve kapanış aynı sayıyı bulur; v2'nin "çekiliş karşılaştırılmaz" istisnası kalktı.

Sonuç: 8.220 koşuda (tüm ölçek, uç bileşim, politika, arz ve EA senaryoları) en büyük fark **1,4e-14** (kapı: 1e-6). Aynı kart, aynı ekip, iki ayrı koşuda aynı n, F, düzeltme işi ve bitiş zamanını verdi (§2, son satır). Benzetimde adlı uyuşmazlık nedenleri (B'nin kararları, işe alım ya da ayrılık, izin, kurucu toplantısı) yok; bunlar tahmini oyunda bozar, benzetimde değil.

## 7. Kapı tablosu (§6.12)
@@gates@@

**23 kapının @@npass@@'ü geçti.** Kalanlar: 2, 11, 16, 19, 22. Kapı 1 sınırda (−1,0 = tolerans); kapı 12'nin en yüksek değeri %29,2 ve iki 5★ testçili 12 kişi %32,8 (sınır 33,3).

## 8. Kalan kapılar: tanı ve öneri
Her başlıkta önce tanı (neden kaldı, hangi formül), sonra öneri, sonra önerinin etkisi. **Öneri sonuçları taban sonuçlardan ayrı koşulardır; model değiştirilmedi.**

### 8.1 Kapı 2 · `kurucu_buyume`
**Tanı.** Kapının iki koşulu da tam tutmuyor.
- *Eşik:* kurucunun işi tabana göre 5★ kurucu + üç geliştirici dizisinde −%10,1 (11,1 / 12,4); eşik %10, aşım 0,1 puan. Formül: §3.4 aday sırası + §3.9. Yeni geliştirici (10 puan/hf) kurucunun (20 puan/hf, sınıf 0) olduğu aşamada kadro dolmadan aynı kartta çalışıyor ve geliştirme işi bölünüyor: kurucunun Geliştirme payı 1,00 → 0,65 → 0,55.
- *Neden kaydı:* kapı nedeni "aşama değişti" ile sınırlı. %2'den büyük 16 düşüşün yalnız 7'sinde aşama değişiyor; 8'inde aşama aynı ve iş bölünüyor, 1'inde PM hazırlığı kartı küçültüyor.
- Şirket teslimi her adımda artıyor; "tek başımayken daha hızlıydım" duygusunu doğuracak model davranışı (şirket teslimi düşmesi, MVP gecikmesi) yok. Duygu yalnız kişisel çıktıda (kurucunun kendi puanı) olabilir ve en kötü −%10,1.
- Gerçek zamanlı alımda (8, 14, 20. hafta) 5 / 24 dizide alım penceresinde geçici düşüş var; dördü "üç geliştirici" (tahmin: üçüncü geliştirici sprintin toplam tavanını (1,25 × kapasite) ve geliştirme aşama tavanını büyütüyor, sprint daha çok kart alıyor ve test kuyruğu şişiyor; bu bu turda ayrıca ölçülmedi).

**Öneri (kapı okuması, model aynı).** Kapıyı "kurucunun işi tabana göre en çok %12 düşer ve her düşüşte plan ekranı üç nedenden birini yazar: aşama değişti, iş yeni gelenle bölündü (kurucunun o aşamadaki payı düştü), kart hazırlıkla küçüldü" diye okumak. Plan ekranında kurucunun satırı payı da yazar.

**Etki (Öneri).** Aynı 72 adım, yeni okumayla: %2'den büyük 16 düşüşün 16'sında neden kodu var (7 aşama değişti, 8 iş bölündü, 1 hazırlık) ve en kötü düşüş −%10,1 ≤ %12: kapı geçer. Model sayıları değişmedi.

### 8.2 Kapı 11 · `pm_yildizi`
**Tanı.** 23 kişide kaçan / kart yalnız −%19,9 (0,60 → 0,48); kapı −%25 istiyor. Belge §4.6'da aynı −%20'yi yazmıştı: kapı kendi tablosundan sıkı. Formül: hazırlık hızı P(s) = 15 + 10 √((s − 2) ÷ 8) (15 ile 25 hazırlık puanı, yani 75 ile 125 kart puanı/hf); 23 kişilik ekibin tükettiği kart puanı yaklaşık 230/hf. Hazır kart oranı 1★'da %34, 5★'da %51; hata çarpanı (1 − h r) yalnız hazır karta uygulandığı için 5★ faydası kartların yarısına ulaşıyor. Tek PM'in beslediği kişi sayısı (7 ile 12) kapı senaryosunun 23 kişisinin altında.

**Öneri.** Kapının kapsamını "PM sayısı ekibi besleyecek kadar" yapmak (bir PM en çok 12 kişi; hazır kart ≥ %60). Sabitlerde değişiklik yok.

**Etki (Öneri).** Ekibi besleyen PM sayısıyla 1★ → 5★:

@@pm_prop@@

İki ekipte de teslim ≥ +%21 ve kaçan / kart ≤ −%33: kapı geçer.

### 8.3 Kapı 16 · `arz_havuzu`
**Tanı.** İki ayrı neden.
- *50 kişi:* derinlik kartı üst sınırı 4 × 9 hat = **36**; hedef 0,75 × 50 = **37,5**. Hesap ne kadar çok olursa olsun açık derinlik kartı 36'yı geçmiyor; 330 hesapta bile 50 kişi 386 puana kalıyor ve %23 boşta. Formül §3.13 B: min(4, 1 + ⌊hesap ÷ 10⌋).
- *Havuzun boşaltılması:* ekip her planda açık adayların hepsini alıyor; havuz ancak arz tüketimi aşarsa hedefin üstünde kalıyor. 25 kişide sabit ekip 0. haftadan tam: 21. haftada 57 hesapla hat başına 2 derinlik kartı var, havuz sprintlerin %20'sinde 18,75'in altında. 330 hesapta sorun yok (%100).
- Büyüme eğrisinde sorun yok (%100); sabit 50 kişilik ekibin 0. haftadan hesapsız başlaması gerçekçi bir oyun durumu değil.

**Öneri.** Açık derinlik kartı = 1 + ⌊hesap ÷ 5⌋ ve üst sınır 8 (ya da ilke 1 gereği üst sınırsız). Sabitler [ÇALIŞMA].

**Etki (Öneri).** Hücre: açık aday ≥ hedef · teslim · boşta payı (20 tohum, 2 hf sprint).

@@p16@@

- Bölen 5 ve üst sınır 8 birlikte: 25 kişi %80 → %100 (teslim 217,3 → 245,6, boşta %14,6 → %7,6); 50 kişi 330 hesapta %0 → %100 (teslim 385,9 → 474,8, boşta %23,4 → %12,1); büyüme eğrisi aynı (%100, teslim 66,6 → 66,8). Sabit 50 kişilik ekip 3 hesap/hf ile %0 → %65 (teslim 295,6 → 406,5) ama hâlâ < %90: ekip 0. haftadan tam ve hesap azken arz tüketimin gerisinde.
- Üst sınır tek başına yalnız 330 hesaplı 50 kişiyi düzeltiyor (%100), bölen tek başına yalnız 25 kişiyi (%100). İkisi ayrı eksende.
- Üst sınırı tamamen kaldırmak (bölen 5, son sütun) 25 kişide aynı (%100, 245,4), sabit 50 kişide %65 (419,1), 330 hesapta 50 kişide %100 (465,8); 330 hesapta 25 kişide teslim 228,1 → 217,1'e düşüyor (derinlik kartları isteklerin yerini alıyor). Bu yüzden öneri üst sınır 8.

### 8.4 Kapı 19 · `oneri_dolulugu`
**Tanı.** Formül §6.5 adım 4: "sprintte kart varsa şunlardan biri tutmazsa durulur". Sıradaki aday (ör. 40 puanlık K3 ya da 25 puanlık istek) toplam tavana (1,25 × kapasite) ya da aşama tavanına takılınca, arkasındaki 15 puanlık küçük kartlar da elenir. §3.12 b ise "öneri planın alım kuralıyla tavana kadar doldurur" diyor: ikisi çelişiyor. Sonuç: S2'de planın %13 ile %23'ü, S3'te %11'i, S4'te %5 ile %6'sı boş; S5 ve S6'da %2'nin altında. Bot öneriyle aynı kodu kullanıyor (bot = öneri koşulu yapısal olarak tutuyor).

**Öneri.** Uymayan adayı atla, sıradaki en çok 12 adaya bak (durma yok). Sabit yok, kural değişikliği.

**Etki (Öneri).** 20 tohum, kaynaklı arz:

@@p19@@

Doluluk %96,8 ile %100'e çıkıyor (en düşük S2, 1 hf); teslim S2 (1 hf) +%26, S3 +%5 (1 hf), S4 +%4 (1 hf); boşta payı düşüyor. S5 ve S6 değişmiyor. Yan etki: S2 1 hf'de düzeltme payı %10,1 → %17,4 ve ilk hata sprinti (1/800): atlayarak dolduran öneri düzeltme kartlarının payını da büyütüyor ama kapı 6'nın sınırları (≤ %30, ≤ %20) içinde.

### 8.5 Kapı 22 · `takim_bolme`
**Tanı.** Üç yan koşuldan ikisi kalıyor.
- *c1, takımlar takımsızdan geri kalıyor (kalan, koşullu geçer).* 67-130. hf takımsız 411,1; 3 takım 304,8 (−%26); 7 takım 252,6 (−%39). İki sayı farkı açıklıyor: ortalama hız çarpanı (3 takımda ×0,875) ve takıma bağlı arzdan boşta (%31, takımsız %19). Çarpım 3 takımda 304,9 (gerçek 304,8). Koşulun ikinci kolu ("farkı takım satırında yazılı") ancak takım satırı hız çarpanının yanında boşta kişi sayısını da yazarsa sağlanır; belgedeki takım satırı (§3.14) yalnız hız çarpanını yazıyor.
- *c3, kişi eklemek düşürmüyor (kalan).* 7 takımda takım 0'a testçi eklemek −2,9 (21-60 hf), 3 takımda PM eklemek −1,9 (67-130 hf). Formül §3.14 `TEAM_LOSS`: 8. kişiden sonra kişi başı %2 ve tüm takımın hızına uygulanıyor; darboğaz olmayan bir kişi hem hiçbir şey eklemiyor hem tüm takımı %2 yavaşlatıyor. Kayıp kapatılınca en kötü −0,5 (kanıt: `TEAMLOSS=0` koşusu).
- *c2, lidersiz 7 takım takımsızdan yavaş:* geçti (213,3).

**Öneri.** (1) Takım satırına "boşta N kişi" eklemek (c1 için). (2) Büyüklük kaybını yalnız 8. kişiden sonra gelenlerin hızına uygulamak (marjinal kayıp); kişi eklemek bu durumda diğerlerini yavaşlatmaz. Alternatif: kayıp katsayısını %2'den %1'e indirmek.

**Etki (Öneri).** 67-130. hf teslim ve kişi eklemede en kötü fark:

@@p22@@

@@p22_ratio@@. Marjinal kayıpta kişi eklemenin en kötü sonucu −0,8 (3 takım, PM; tolerans −1): c3 geçer. Kayıp %1'de −1,5 kalıyor (7 takım, testçi), yetmiyor. Marjinal kayıp 3 takımı +%9 hızlandırıyor ama takımsızın %81'inde bırakıyor; c1 yapısal olarak (arzın takıma bağlanması) kalıyor ve ancak takım satırındaki açıklamayla karşılanır.

### 8.6 Kapıların dışında: 1 haftalık sprintte tek kurucu
**Tanı.** `Kart sayısı ölçeği` senaryosunun 1 haftalık sprint kolunda tek kurucu 800 sprintin 401'inde hata sprinti (%50) ve düzeltme payı %43,6. Formül §3.12 c "en az 5 puan": kurucunun 1 haftalık kapasitesi 8,6 puan, tek açık hatalı hat bile 5 puanlık kart açıyor (kapasitenin %58'i); düzeltme payı tavanı "ilk kart her zaman girer" diyor. Bu, A'nın "sürekli hata sprinti yok" ilkesine (ilke 6) aykırı. 2 haftalık sprintte aynı ekip 4/569 (%0,7).

**Öneri.** Düzeltme kartının alt sınırını sprint süresine ve kapasiteye bağlamak. Denenen: alt sınır 5 → 2,5.

**Etki (Öneri).**

@@pfix@@

Hata sprinti 401/800 → 53/800 (%6,6; kapıda %5'in biraz üstünde); 3 ve 6 kişide teslim artıyor. Tam çözüm kapasiteye oranlı alt sınır (örn. kapasitenin %25'i); bu turda denenmedi.

## 9. Belgeye düzeltmeler ve belgeyle farklar
1. **§0 madde 8, §3.9, §4.7: "kurucunun kendi işi en çok %7 düşer"** → 5★ kurucu ve üç geliştirici dizisinde −%10,1 (tabloda yalnız geliştirici → tasarımcı → testçi sırası vardı).
2. **§6.12 kapı 11** → 23 kişide −%19,9 (belge §4.6 aynı −%20'yi yazmıştı): kapı kendi tablosuyla çelişiyor. Kapsam "PM sayısı ekibi besleyecek kadar" olmalı (§8.2).
3. **§3.13 B, §6.12 kapı 16** → üst sınır 4 × 9 hat = 36, 50 kişinin hedefi 37,5: matematiksel olarak yetmiyor (§8.3).
4. **§3.12 b ile §6.5 adım 4** → "tavana kadar doldurur" ile "tutmazsa durulur" çelişiyor; S2 ile S4'te planın %5 ile %23'ü boş (§8.4).
5. **§3.12 c "en az 5 puan"** → 1 haftalık sprintte tek kurucuda sürekli hata sprinti (%50) (§8.6).
6. **§3.14 takım kaybı** → 8. kişiden sonra kişi eklemek 2,9 puana kadar düşürüyor; takım satırı yalnız hız çarpanını yazıyor, boşta yazmıyor (§8.5).
7. **§0 madde 5 ve §4.8 soru sıklığı** → birebir tutuyor (havuzlanmış: S2 %4,5, S3 %21,5, S4 %29,2, S5 %18,5; medyan alınırsa %5 · %20 · %30 · %20).
8. **SD §4.1 katalog tükenme** (2 hf sprint) → v3 modelinde 3 kişi 37 (SD 32), 6 kişi 18 (16), 12 kişi 12 (11), 25 kişi 9 (9), 50 kişi 7 (7). `D_MODEL_v3.md` §3.13 düzeltme notundaki "12 kişide 11 haftada" 12 olmalı.
9. **§4.9 A'nın sınırları** → belgenin tablosu eşiği sabit teslimle hesaplamıştı; haftalık kayan k ile 12 hatlı benzetimde S1 23 · S2 23,5 · S3 20,5 · S4 17 · S5 17 · S6 15 hafta (belge 22,5 · 17 · 14 · 18 · 16 · 14). 9 hat varsayımıyla 23 · 17 · 16 · 17 · 17 · 15. Kapı 15 her iki okumada geçiyor.
10. **§4.3 ve §4.4 sayıları** → bu koşuda 0,1 puan içinde aynı. **Kişi ekleme eğrisi** −0,5 (belge −1,0, 10 tohum).
11. **Ek gözlem (belgede yok):** 130 haftalık büyüme eğrisinde teslim puanının %89'u istek kartı, %2'si derinlik kartı; derinlik kartı ancak 25 kişiden sonra devreye giriyor (sabit ekip koşularında 330 hesapla bile S3'te %75, S4'te %84 istek payı).

## 10. Yeniden üretim
Klasör: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dsim3/` (hepsi `python -I dsim3.py exec <dosya>` ile koşar).
```
python -I dsim3.py exec check69.py                    # §6.9 elle doğrulama
python -I dsim3.py exec collect.py A B C D E F G H H2 I R G2   # 20 tohum, ham sonuçlar out/*.pkl (yaklaşık 30 dk, 4 işçi)
python -I dsim3.py exec prop.py p11 p16 p16b p16c p16d p19 p22 p22b pfix   # öneri kolları (ortam değişkeniyle; out/P_*.pkl)
D3_TEAMLOSS=0 D3_TAG=_kayip0 python -I dsim3.py exec collect.py H3   # kapı 22 tanısı: büyüklük kaybı kapalı
python -I dsim3.py exec gates.py                      # 23 kapı -> out/gates.json
python -I dsim3.py exec tb1.py ; python -I dsim3.py exec tb2.py   # rapor tabloları
python -I dsim3.py exec mkreport.py                   # bu rapor (taslak rapor_taslak.md)
python -I dsim3.py quick S3 S6                        # tek senaryo, tohum 1
```
Parametreler `dsim3.py` başındaki sabitlerdedir (§6.2 ile birebir); öneri kolları `D3_H0`, `D3_CREF`, `D3_SELF`, `D3_FFLOOR`, `D3_QRATIO`, `D3_PHASEK`, `D3_FIXSHARE`, `D3_FIXMIN`, `D3_DEPTHMAX`, `D3_DEPTHDIV`, `D3_FILLSKIP`, `D3_TEAMLOSS`, `D3_TEAMLOSSMODE` ortam değişkenleriyle açılır.
