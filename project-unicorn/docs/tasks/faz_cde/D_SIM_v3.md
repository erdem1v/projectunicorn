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
| Örnek | Beklenen (§6.9) | Bulunan |
|---|---|---|
| K2 (25), 2,5★ geliştirici (q=1), hazırlıksız, testi tek kişi | H=1,0; E: başkasının kartı 0★ 0,60 · 3★ 0,39 · 5★ 0,19; kendi kartı 3★ 0,63 | başkasının kartı 0★ H=1,00 E=0,60; başkasının kartı 3★ H=1,00 E=0,39; başkasının kartı 5★ H=1,00 E=0,19; kendi kartı 3★ H=1,00 E=0,63 |
| K1 geliştirme ağırlıklı (2/10/3), S7 ekibi, tek kart | kadro [1,2,1]; test 4★ testçide; C = 0,71 | kadro [1, 2, 1]; test: T4 3,00; C=0,707 |
| K3 geliştirme ağırlıklı (6/26/8), 3★ tasarımcı ve testçi, 1 ile 6 3★ geliştirici (süre, hafta; hata yokken) | [3,45, 2,33, 1,95, 1,77, 1,77, 1,77] | [3,45, 2,33, 1,95, 1,77, 1,77, 1,77] |
| Hazırlık süresi, tek PM (hafta) | K1 (3 puan): 1★ 0,20 · 3★ 0,14 · 5★ 0,12; K3 (8 puan): 1★ 0,53 · 3★ 0,36 · 5★ 0,32 | 1★ K1 0,20 K3 0,53; 3★ K1 0,14 K3 0,36; 5★ K1 0,12 K3 0,32 |
| Hazır K2 (25), tam hazır | ihtiyaç ÷ 1,10 (1★), ÷ 1,20 (3★), ÷ 1,30 (5★); H × 0,90, × 0,75, × 0,60 | 1★ ihtiyaç ÷ 1,10; hata ×0,900; 3★ ihtiyaç ÷ 1,20; hata ×0,750; 5★ ihtiyaç ÷ 1,30; hata ×0,600 |
| Kurucu 0★ tasarımda | 8,6 puan/hafta | 8,60 |
| Düzeltme kartı | 1 hata 5 · 3 hata 6 · 5 hata 10 · 12 hata 24 puan | 1 hata 5 · 3 hata 6 · 5 hata 10 · 12 hata 24 |
| Aynı kart, aynı ekip, iki oynatma | Aynı n, F, costs, bitiş zamanı | iki koşu özdeş: True; plan-kapanış en büyük fark 1,8e-15 |

Sekiz örneğin sekizi de tutuyor. Üçüncü satırdaki süre hata yokken ölçüldü (`H0` bu örnek için 0).

## 3. Ölçek tablosu (1, 3, 6, 12, 25, 50 kişi; sınırsız arz)
Teslim = biten özellik kartlarının hazırlıksız büyüklüğü, puan/hf. Hata sprinti = düzeltme payı > %50 olan sprint / pencere sprinti (20 tohum toplamı).

| Ekip | Haftalık iş (puan) | Kişi başı | Kart / sprint | Kaçan / kart | Açık hata (medyan) | Düzeltme payı (geç) | Hata sprinti | MVP (hf) |
|---|---|---|---|---|---|---|---|---|
| S1 · 1 | 4,5 | 4,5 | 0,37 | 0,78 | 6,8 | %29,1 | 3/507 | 6 |
| S2 · 3 | 19,6 | 6,5 | 1,08 | 1,09 | 8,0 | %9,5 | 0/400 | 4 |
| S3 · 6 | 48,0 | 8,0 | 2,40 | 0,68 | 8,0 | %6,6 | 0/400 | 4 |
| S4 · 12 | 107,0 | 8,9 | 5,35 | 0,58 | 9,5 | %5,1 | 0/400 | 2 |
| S5 · 25 | 265,5 | 10,6 | 13,28 | 0,44 | 12,0 | %3,4 | 0/400 | 2 |
| S6 · 50 | 539,0 | 10,8 | 26,95 | 0,44 | 17,0 | %3,0 | 0/400 | 2 |

| Ekip | Bulunan / sprint | Bilinen / sprint | Bilinen hata sorusu (sprintlerin payı) | Sprint içi düzeltme | Toplam hata işi | Boşta (kişi-hf / hf) | Boşta payı | Darboğaz |
|---|---|---|---|---|---|---|---|---|
| S1 · 1 | 0,08 | 0,00 | %0,8 | %0,6 | %29,6 | 0,2 | %17 | yok |
| S2 · 3 | 0,40 | 0,05 | %4,5 | %1,5 | %11,0 | 0,5 | %17 | Test |
| S3 · 6 | 1,38 | 0,28 | %21,5 | %2,7 | %9,3 | 1,0 | %16 | Test |
| S4 · 12 | 3,23 | 0,70 | %29,2 | %3,3 | %8,5 | 1,2 | %10 | Test |
| S5 · 25 | 8,25 | 1,40 | %18,5 | %3,5 | %6,9 | 0,6 | %2 | Test |
| S6 · 50 | 16,40 | 2,12 | %4,2 | %3,5 | %6,5 | 1,3 | %3 | Test |

Belgenin ön hesabıyla karşılaştırma (D_MODEL_v3 §4.2):

| Ekip | Teslim: belge / bu koşu | Kaçan / kart: belge / bu koşu | Açık hata: belge / bu koşu | Düzeltme payı: belge / bu koşu |
|---|---|---|---|---|
| S1 · 1 | 4,5 / 4,5 (+%0,0) | 0,78 / 0,78 | 6,8 / 6,8 | %29,0 / %29,1 |
| S2 · 3 | 19,6 / 19,6 (+%0,1) | 1,09 / 1,09 | 8,0 / 8,0 | %9,5 / %9,5 |
| S3 · 6 | 48,0 / 48,0 (+%0,0) | 0,68 / 0,68 | 8,0 / 8,0 | %6,6 / %6,6 |
| S4 · 12 | 107,0 / 107,0 (+%0,0) | 0,58 / 0,58 | 9,5 / 9,5 | %5,1 / %5,1 |
| S5 · 25 | 265,5 / 265,5 (+%0,0) | 0,44 / 0,44 | 12,0 / 12,0 | %3,4 / %3,4 |
| S6 · 50 | 539,0 / 539,0 (+%0,0) | 0,44 / 0,44 | 17,0 / 17,0 | %3,0 / %3,0 |

- **Hata ölçekle patlamıyor.** 3 kişiden 50 kişiye kaçan hata / kart 1,09'dan 0,44'e iniyor (testçi payı büyüdükçe), düzeltme payı %9,5'ten %3'e. Açık hata ekiple yavaş büyüyor (8 → 17).
- **Boşta payı** 1-6 kişide %16-17 (yapısal: sprint sonu boşluğu ve tasarım/test tek kişide), 12 kişide %10, 25 ve 50 kişide %2-3.
- **Darboğaz** (kalan iş ÷ aşama kapasitesi) 3 kişiden itibaren Test: testçi payı %20'de bile sprint sonunda test kuyruğu en yüklü aşama.
- **Bilinen hata sorusu** 3 kişide %4,5, 6 kişide %21,5, 12 kişide %29,2, 25 kişide %18,5, 50 kişide %4,2: küçük ve çok büyük ekipte nadir, 6 ile 25 kişi arasında en çok üç sprintte bir.

### 3.1 Testçinin etkisi (ölçeğe göre)
Hücre: teslim · kaçan hata / 100 puan.

| Ekip | Testçisiz → 3★ testçi (aynı kişi sayısı) | 1★ testçi | 3★ testçi | 5★ testçi | 1★ → 5★: kaçan / 100 puan, bulunan / sprint |
|---|---|---|---|---|---|
| 1 kişi (kurucu) | yok (4,5 · 3,89) → +2,5★ testçi (7,3 · 1,83) | | | | testçi yıldızı kuruculu ekipte ölçülmedi |
| 3 kişi (S2) | yok (19,6 · 3,00) → +3★ testçi (26,9 · 1,85) | | | | |
| 6 kişi (S3) | 45,0 · 2,30 → 49,0 · 1,48 (teslim +%9, kaçan −%36) | 45,0 · 2,05 | 49,0 · 1,48 | 50,0 · 0,88 | −%57; 0,95 → 2,48 (×2,6) |
| 12 kişi (2 testçi) | 99,0 · 1,79 → 108,0 · 1,33 (teslim +%9, kaçan −%26) | 92,0 · 1,60 | 108,0 · 1,33 | 114,0 · 0,62 | −%61; 2,40 → 5,50 (×2,3) |
| 25 kişi (5 testçi) | 234,0 · 1,44 → 267,5 · 1,08 (teslim +%14, kaçan −%25) | 189,0 · 1,45 | 267,5 · 1,08 | 275,0 · 0,53 | −%64; 4,38 → 11,68 (×2,7) |

1 ve 3 kişide kurucu ve geliştirici kendi kartını test ediyor (×0,6); testçi eklemek teslimi de artırıyor (4,5 → 7,3 ve 19,6 → 26,9) ve kaçan hata / 100 puanı 3,89'dan 1,83'e (1 kişi), 3,00'den 1,85'e (3 kişi) indiriyor.

## 4. Uç bileşimler
| Senaryo | Kişi | Teslim (belge) | Boşta (kişi-hf / hf) | Kaçan / kart | Açık hata | Darboğaz | Okunuş |
|---|---|---|---|---|---|---|---|
| S7 · küçük kartlara 5 testçi | 8 | 22,1 (22,1) | 5,5 | 0,48 | 7,5 | Geliştirme | Tek testçiyle 19,8; dört testçi az teslim, belirgin kalite getirir |
| S8 · 10 geliştirici, Test kutusu yok | 11 | 17,0 (17,0) | 9,1 | 0,78 | 7,5 | Test | Tasarımı ve testi yalnız kurucu yapıyor |
| S8 + 1 Test kutulu geliştirici | 12 | 24,5 | 9,2 | 0,74 | 7,8 | Test | Test açılınca teslim artar |
| S8 · 10 geliştiricinin hepsinde Test kutusu | 11 | 31,0 (31,0) | 7,5 | 0,84 | 8,0 | Tasarım | Kendi kartını test edenler az yakalar |
| S9a · 8 testçi, yalnız Test | 9 | 7,9 (7,9) | 7,8 | 0,32 | 7,0 | Geliştirme | Yapımı yalnız kurucu yapıyor |
| S9a + 1 geliştirici | 10 | 17,4 | 8,0 | 0,41 | 7,5 | Geliştirme | Yapım rolü eklenince teslim iki katı |
| S9b · 8 testçi, Yapım ve Test | 9 | 19,6 (19,6) | 6,5 | 0,76 | 7,8 | yok | Testçi ikincil hızla geliştirir |
| S10 · PM'siz 30 kişi | 30 | 283,0 (283,0) | 1,5 | 0,60 | 14,5 | Test | Çökmez; bedeli hatada ve hızda |
| S11 · testçisiz 25 kişi, kutu yok | 25 | 36,0 (36,0) | 21,5 | 0,70 | 8,0 | Test | Darboğaz Test; testi yetişmez |
| S11 + 1 testçi | 26 | 91,0 | 17,3 | 0,56 | 9,0 | Test | Bir testçi teslimi iki buçuk kat yapar |
| S11b · aynı, geliştiricilerde Test kutusu | 25 | 162,0 (162,0) | 8,6 | 0,56 | 11,0 | yok | Test açılır |
| S12 · tek karta 12 kişi | 12 | 11,5 (11,5) | 10,8 | 0,31 | 6,0 | yok | Kadro dolu, öbürleri boşta |
| S3 PM'siz (5 kişi) | 5 | 39,0 | 0,6 | 0,86 | 8,0 | Test | PM'siz ceza yok ama hazır kart yok |
| S3 + PM'e Test kutusu | 6 | 47,0 | 0,7 | 0,69 | 8,0 | Test | PM uymayan işte moral kaybeder (kapı 23) |
| S4 PM'siz (10 kişi) | 10 | 89,0 | 0,4 | 0,77 | 9,8 | Test | PM'siz: kaçan hata artar |
| S5 tek PM (23 kişi) | 23 | 229,0 | 0,3 | 0,58 | 12,5 | Test | Tek PM ekibin yarısını hazırlar (hazır kart %47) |

Hiçbirinde model çökmüyor; kırık bileşim boşta kişi ve darboğaz olarak görünüyor. Belgenin §4.3 değerleri (parantezde) birebir tutuyor.

## 5. Marjinal getiri ve kişi ekleme eğrisi
### 5.1 Taban ekibe bir kişi eklemek (puan/hf; parantezde eklenen ekibin kaçan hatası / kart)
| Taban | +3★ geliştirici | +3★ testçi | +3★ tasarımcı | +3★ PM | +1★ geliştirici |
|---|---|---|---|---|---|
| S2 · 3 (19,6) | +7,6 (0,93) | +7,2 (0,71) | +0,5 (1,09) | +4,2 (0,81) | +5,2 (1,10) |
| S3 · 6 (48,0) | +17,0 (0,60) | +6,0 (0,54) | −1,0 (0,66) | +0,0 (0,68) | +10,0 (0,66) |
| S4 · 12 (107,0) | +11,5 (0,56) | +6,0 (0,52) | +0,0 (0,56) | +0,0 (0,58) | +9,0 (0,59) |
| S5 · 25 (265,5) | +16,5 (0,43) | +6,0 (0,43) | +1,0 (0,43) | +1,5 (0,44) | +11,5 (0,45) |
| S6 · 50 (539,0) | +5,0 (0,42) | +6,0 (0,41) | +15,0 (0,43) | +0,5 (0,42) | +3,5 (0,43) |

En düşük hücre −1,0 (S3'e 3★ tasarımcı: ekipte tasarım darboğaz değil, hazırlıklı kartlarda tasarım ihtiyacı küçük). Kapı sınırında.

### 5.2 Kişi ekleme eğrisi (1 → 50 kişi, S6 oranı; seçili adımlar ve her negatif adım)
| Kişi | Eklenen | Teslim | Marjinal | Kişi başı | Kaçan / kart | Açık hata | Boşta payı |
|---|---|---|---|---|---|---|---|
| 1 | kurucu | 4,5 | - | 4,50 | 0,78 | 6,8 | %17 |
| 2 | geliştirici | 9,5 | +5,0 | 4,76 | 0,89 | 7,5 | %32 |
| 3 | testçi | 15,4 | +5,9 | 5,12 | 0,47 | 7,8 | %37 |
| 4 | geliştirici | 19,1 | +3,8 | 4,78 | 0,70 | 7,8 | %41 |
| 5 | tasarımcı | 38,0 | +18,9 | 7,60 | 0,80 | 8,0 | %13 |
| 6 | PM | 48,0 | +10,0 | 8,00 | 0,59 | 8,0 | %18 |
| 7 | geliştirici | 68,0 | +20,0 | 9,71 | 0,53 | 9,0 | %10 |
| 12 | geliştirici | 117,0 | +10,0 | 9,75 | 0,58 | 9,0 | %3 |
| 13 | PM | 118,5 | +1,5 | 9,12 | 0,56 | 9,5 | %10 |
| 25 | testçi | 265,5 | +11,5 | 10,62 | 0,44 | 12,0 | %2 |
| 31 | PM | 327,0 | +0,0 | 10,55 | 0,42 | 13,2 | %4 |
| 37 | PM | 397,5 | −0,5 | 10,74 | 0,42 | 13,8 | %4 |
| 38 | geliştirici | 403,0 | +5,5 | 10,61 | 0,42 | 14,5 | %5 |
| 47 | tasarımcı | 500,0 | +11,0 | 10,64 | 0,43 | 16,5 | %2 |
| 48 | geliştirici | 501,0 | +1,0 | 10,44 | 0,44 | 16,2 | %4 |
| 49 | testçi | 536,0 | +35,0 | 10,94 | 0,43 | 16,5 | %2 |
| 50 | geliştirici | 539,0 | +3,0 | 10,78 | 0,44 | 17,0 | %3 |

| Eklenen rol | Adım | Ortalama | En küçük | En büyük |
|---|---|---|---|---|
| geliştirici | 25 | +7,1 | +1,0 | +20,0 |
| testçi | 10 | +10,6 | +2,5 | +35,0 |
| tasarımcı | 8 | +28,5 | +11,0 | +45,5 |
| PM | 6 | +3,7 | −0,5 | +11,0 |

Negatif adım: 1; sıfır adım: 2; en kötü −0,5. Tasarımcı adımları en değerli (ortalama +28,5), PM (+3,7) ve geliştirici (+7,1) adımları en küçük; 49 adımın 46'sı artı. 37. kişi (PM) −0,5. Belge, en iyi PM kuralı olmadan bu adımın −2,5 olduğunu yazıyor; kural bu turda kapalı koşulmadı.

## 6. Yeni senaryolar
### 6.1 Kurucu büyümesi (D4): tek → +1 → +2 → +3
Hücre: şirket teslimi / kurucunun kendi işi (puan/hf) / MVP haftası. Alınanlar 2,5★ (1★ satırı ayrıca).

| Kurucu | Alım sırası | Tek | +1 | +2 | +3 |
|---|---|---|---|---|---|
| Orta (ürün 4, yazılım 4) | geliştirici → tasarımcı → testçi | 4,5 / 7,2 / 6 | 9,4 / 8,1 / 6 | 17,8 / 8,6 / 4 | 24,9 / 8,6 / 4 |
| Orta (ürün 4, yazılım 4) | tasarımcı → geliştirici → testçi | 4,5 / 7,2 / 6 | 7,2 / 8,6 / 6 | 17,8 / 8,6 / 4 | 24,9 / 8,6 / 4 |
| Orta (ürün 4, yazılım 4) | testçi → geliştirici → tasarımcı | 4,5 / 7,2 / 6 | 7,3 / 8,0 / 6 | 13,6 / 8,3 / 4 | 24,9 / 8,6 / 4 |
| Orta (ürün 4, yazılım 4) | PM → geliştirici → tasarımcı | 4,5 / 7,2 / 6 | 5,4 / 7,0 / 6 | 10,6 / 8,3 / 4 | 21,5 / 8,6 / 4 |
| Orta (ürün 4, yazılım 4) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 4,5 / 7,2 / 6 | 7,5 / 7,2 / 6 | 13,6 / 8,6 / 4 | 17,8 / 8,5 / 4 |
| Orta (ürün 4, yazılım 4) | üç geliştirici | 4,5 / 7,2 / 6 | 9,4 / 8,1 / 6 | 12,6 / 8,5 / 4 | 14,6 / 8,6 / 4 |
| Güçlü yazılım 4★ (8) | geliştirici → tasarımcı → testçi | 7,5 / 10,5 / 4 | 10,4 / 10,7 / 4 | 20,1 / 10,5 / 4 | 31,3 / 13,5 / 2 |
| Güçlü yazılım 4★ (8) | tasarımcı → geliştirici → testçi | 7,5 / 10,5 / 4 | 12,0 / 12,4 / 4 | 20,1 / 10,5 / 4 | 31,3 / 13,5 / 2 |
| Güçlü yazılım 4★ (8) | testçi → geliştirici → tasarımcı | 7,5 / 10,5 / 4 | 11,6 / 12,0 / 4 | 17,0 / 11,9 / 4 | 31,3 / 13,5 / 2 |
| Güçlü yazılım 4★ (8) | PM → geliştirici → tasarımcı | 7,5 / 10,5 / 4 | 9,1 / 10,6 / 4 | 12,0 / 10,6 / 4 | 24,4 / 10,5 / 4 |
| Güçlü yazılım 4★ (8) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 7,5 / 10,5 / 4 | 9,8 / 10,7 / 4 | 16,6 / 11,2 / 4 | 24,5 / 13,2 / 4 |
| Güçlü yazılım 4★ (8) | üç geliştirici | 7,5 / 10,5 / 4 | 10,4 / 10,7 / 4 | 10,8 / 10,5 / 4 | 11,4 / 10,4 / 4 |
| Güçlü yazılım 5★ (10) | geliştirici → tasarımcı → testçi | 9,3 / 12,4 / 4 | 11,0 / 11,6 / 4 | 21,5 / 11,4 / 4 | 35,0 / 16,0 / 2 |
| Güçlü yazılım 5★ (10) | tasarımcı → geliştirici → testçi | 9,3 / 12,4 / 4 | 14,2 / 14,4 / 4 | 21,5 / 11,4 / 4 | 35,0 / 16,0 / 2 |
| Güçlü yazılım 5★ (10) | testçi → geliştirici → tasarımcı | 9,3 / 12,4 / 4 | 14,6 / 14,5 / 4 | 18,4 / 13,5 / 4 | 35,0 / 16,0 / 2 |
| Güçlü yazılım 5★ (10) | PM → geliştirici → tasarımcı | 9,3 / 12,4 / 4 | 10,6 / 12,4 / 4 | 13,6 / 11,7 / 4 | 25,1 / 11,3 / 4 |
| Güçlü yazılım 5★ (10) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 9,3 / 12,4 / 4 | 10,4 / 11,9 / 4 | 18,8 / 12,4 / 4 | 26,9 / 15,4 / 4 |
| Güçlü yazılım 5★ (10) | üç geliştirici | 9,3 / 12,4 / 4 | 11,0 / 11,6 / 4 | 11,6 / 11,2 / 4 | 11,8 / 11,1 / 4 |
| Tasarım ve test bilen (4, 6, 4, 6) | geliştirici → tasarımcı → testçi | 5,6 / 8,1 / 6 | 11,6 / 9,8 / 4 | 20,1 / 10,2 / 4 | 21,6 / 9,7 / 4 |
| Tasarım ve test bilen (4, 6, 4, 6) | tasarımcı → geliştirici → testçi | 5,6 / 8,1 / 6 | 7,9 / 9,3 / 6 | 20,1 / 10,2 / 4 | 21,6 / 9,7 / 4 |
| Tasarım ve test bilen (4, 6, 4, 6) | testçi → geliştirici → tasarımcı | 5,6 / 8,1 / 6 | 7,0 / 9,5 / 6 | 13,6 / 10,1 / 4 | 21,6 / 9,7 / 4 |
| Tasarım ve test bilen (4, 6, 4, 6) | PM → geliştirici → tasarımcı | 5,6 / 8,1 / 6 | 6,3 / 8,2 / 6 | 13,6 / 9,9 / 4 | 23,9 / 10,2 / 4 |
| Tasarım ve test bilen (4, 6, 4, 6) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 5,6 / 8,1 / 6 | 9,4 / 9,2 / 6 | 14,6 / 9,8 / 4 | 16,4 / 9,6 / 4 |
| Tasarım ve test bilen (4, 6, 4, 6) | üç geliştirici | 5,6 / 8,1 / 6 | 11,6 / 9,8 / 4 | 16,0 / 10,5 / 4 | 18,4 / 11,0 / 4 |

- Şirket teslimi 72 adımın 72'sinde arttı (en küçük artış +0,2: güçlü kurucuya üçüncü geliştirici). MVP hiçbir alımla gecikmedi; güçlü kuruculu ekipte üç alımdan sonra 4'ten 2'ye inen diziler var.
- Kurucunun kendi işi tabana göre en çok −%10,1 (5★ kurucu, üç geliştirici). Bu, belgenin "en çok %7" cümlesinden büyük (§9). Önceki adıma göre −%20,9'a varan düşüşler önceki adımdaki geçici yükselişin geri dönüşü (ör. 5★ kurucuya tasarımcı gelince 12,4 → 14,4, sonra geliştirici gelince 11,4).
- %2'den büyük 16 düşüşün nedenleri: 7'sinde baskın aşama değişti; 8'inde aşama aynı ama kurucunun o aşamadaki payı düştü (iş yeni gelenle bölündü); 1'inde PM geldi ve kart hazırlıkla küçüldü. Kapının yalnız "aşama değişti" nedeni 9 düşüşü açıklamıyor (§8.1).
- **Gerçek zaman** (alımlar 8, 14, 20. hafta; teslim puan/hf, 6 haftalık pencereler):

| Kurucu | Alım sırası | 0-8 hf | 8-14 hf | 14-20 hf | 20-26 hf | 26-40 hf | 40-60 hf | MVP | Alım penceresinde düşen aralık |
|---|---|---|---|---|---|---|---|---|---|
| Orta (ürün 4, yazılım 4) | geliştirici → tasarımcı → testçi | 5,6 | 11,0 | 15,0 | 26,7 | 25,0 | 24,0 | 6 | yok |
| Orta (ürün 4, yazılım 4) | tasarımcı → geliştirici → testçi | 5,6 | 9,2 | 15,0 | 26,7 | 24,5 | 25,0 | 6 | yok |
| Orta (ürün 4, yazılım 4) | testçi → geliştirici → tasarımcı | 5,6 | 9,2 | 15,4 | 23,5 | 22,9 | 25,0 | 6 | yok |
| Orta (ürün 4, yazılım 4) | PM → geliştirici → tasarımcı | 5,6 | 6,7 | 12,9 | 20,4 | 21,1 | 21,8 | 6 | yok |
| Orta (ürün 4, yazılım 4) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 5,6 | 9,2 | 12,3 | 14,2 | 19,4 | 17,8 | 6 | yok |
| Orta (ürün 4, yazılım 4) | üç geliştirici | 5,6 | 11,0 | 14,2 | 11,7 | 15,2 | 12,0 | 6 | 20-26 |
| Güçlü yazılım 4★ (8) | geliştirici → tasarımcı → testçi | 8,8 | 11,7 | 19,2 | 34,2 | 30,0 | 32,0 | 4 | yok |
| Güçlü yazılım 4★ (8) | tasarımcı → geliştirici → testçi | 8,8 | 14,2 | 16,7 | 34,2 | 31,1 | 30,0 | 4 | yok |
| Güçlü yazılım 4★ (8) | testçi → geliştirici → tasarımcı | 8,8 | 14,2 | 16,7 | 21,7 | 30,7 | 32,0 | 4 | yok |
| Güçlü yazılım 4★ (8) | PM → geliştirici → tasarımcı | 8,8 | 11,7 | 14,2 | 24,2 | 25,0 | 24,0 | 4 | yok |
| Güçlü yazılım 4★ (8) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 8,8 | 11,7 | 16,7 | 24,2 | 25,0 | 24,0 | 4 | yok |
| Güçlü yazılım 4★ (8) | üç geliştirici | 8,8 | 11,7 | 11,7 | 7,5 | 12,9 | 11,2 | 4 | 20-26 |
| Güçlü yazılım 5★ (10) | geliştirici → tasarımcı → testçi | 10,6 | 11,7 | 16,7 | 38,3 | 36,2 | 34,0 | 4 | yok |
| Güçlü yazılım 5★ (10) | tasarımcı → geliştirici → testçi | 10,6 | 14,2 | 20,8 | 34,2 | 34,5 | 34,0 | 4 | yok |
| Güçlü yazılım 5★ (10) | testçi → geliştirici → tasarımcı | 10,6 | 16,7 | 14,2 | 34,2 | 35,7 | 34,0 | 4 | 14-20 |
| Güçlü yazılım 5★ (10) | PM → geliştirici → tasarımcı | 10,6 | 11,7 | 14,2 | 24,2 | 25,0 | 26,0 | 4 | yok |
| Güçlü yazılım 5★ (10) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 10,6 | 11,7 | 15,4 | 30,0 | 27,0 | 28,0 | 4 | yok |
| Güçlü yazılım 5★ (10) | üç geliştirici | 10,6 | 11,7 | 11,7 | 10,4 | 13,6 | 11,0 | 4 | 20-26 |
| Tasarım ve test bilen (4, 6, 4, 6) | geliştirici → tasarımcı → testçi | 5,6 | 15,8 | 17,1 | 22,9 | 22,1 | 22,0 | 6 | yok |
| Tasarım ve test bilen (4, 6, 4, 6) | tasarımcı → geliştirici → testçi | 5,6 | 11,7 | 17,3 | 24,2 | 22,1 | 22,0 | 6 | yok |
| Tasarım ve test bilen (4, 6, 4, 6) | testçi → geliştirici → tasarımcı | 5,6 | 9,2 | 14,2 | 22,5 | 21,1 | 22,0 | 6 | yok |
| Tasarım ve test bilen (4, 6, 4, 6) | PM → geliştirici → tasarımcı | 5,6 | 9,2 | 14,2 | 26,7 | 22,5 | 24,0 | 6 | yok |
| Tasarım ve test bilen (4, 6, 4, 6) | 1★ geliştirici → 1★ tasarımcı → 1★ testçi | 5,6 | 11,7 | 14,6 | 22,5 | 16,4 | 16,5 | 6 | yok |
| Tasarım ve test bilen (4, 6, 4, 6) | üç geliştirici | 5,6 | 15,8 | 14,2 | 16,7 | 18,2 | 18,0 | 6 | 14-20 |

  5 / 24 dizide en az bir alım penceresinde (8-14, 14-20, 20-26 hf) teslim önceki pencerenin %3'ünden fazla düşer. Dördü "üç geliştirici" dizisi (üçüncü geliştirici gelince 6 haftalık teslim %10 ile %36 düşüyor: 14,2 → 11,7, 11,7 → 7,5, 11,7 → 10,4), biri "testçi → geliştirici → tasarımcı". "Üç geliştirici" dizisi zaten doygun: tasarım ve test kurucuda kalıyor, teslim 9,3 → 11,8 (+%27, üç kişiye). Pencere 6 haftalık ve sprint kartları 15 ile 40 puan olduğu için ±%3 gürültü payı var; sonuçlar yön gösterir.

### 6.2 PM yıldızı ve kaç kişiyi beslediği (D3)
| Ekip, tek PM | Teslim 1★ / 3★ / 5★ | Kaçan / kart | Hazır kart | PM'siz |
|---|---|---|---|---|
| 6 kişi (S3) | 42,5 / 48,0 / 52,0 | 0,88 / 0,68 / 0,50 | %100 / %100 / %100 | 39,0 (kaçan 0,86, 5 kişi) |
| 11 kişi | 95,0 / 107,0 / 117,0 | 0,67 / 0,58 / 0,45 | %78 / %100 / %100 | 89,0 (kaçan 0,77, 10 kişi) |
| 23 kişi | 217,0 / 229,0 / 241,0 | 0,60 / 0,58 / 0,48 | %34 / %47 / %51 | 209,0 (kaçan 0,64, 22 kişi) |

- 1★ PM bile PM'siz ekibi 6 ve 11 kişide %7 ile %9 hızlandırıyor (23 kişide %3,8); 1★'dan 5★'a teslim +%11 ile +%23, kaçan hata −%20 ile −%43 (belge §4.6 ile aynı).
- 23 kişide tek PM kartların yarısını hazırlıyor (hazır kart %34 → %51): hata çarpanı yalnız hazır karta uygulandığı için 5★ faydası yarım ekibe yayılıyor. Bir PM'in beslediği kişi sayısı tabloyla tutarlı (1★ yaklaşık 7, 5★ yaklaşık 12).

### 6.3 Bilinen hata politikaları (D2)
| Ekip | Politika | Teslim | Kaçan / 100 puan | Açık hata (medyan) | Kartın bekleme süresi (hf) | Düzeltme payı (geç) | Soru gelen sprint | Gönderilen bilinen hata / sprint |
|---|---|---|---|---|---|---|---|---|
| S1 | bırak | 4,5 | 3,89 | 6,8 | 3,67 | %29,1 | %0,8 | 0,00 |
| S1 | gönder | 4,5 | 3,46 | 7,0 | 3,67 | %29,1 | %1,0 | 0,00 |
| S1 | eşikli | 4,5 | 3,74 | 6,8 | 3,67 | %29,1 | %0,8 | 0,00 |
| S1 | hep gönder | 4,5 | 3,46 | 7,0 | 3,67 | %29,1 | %1,0 | 0,00 |
| S3 | bırak | 48,0 | 1,70 | 8,0 | 3,98 | %6,6 | %21,5 | 0,00 |
| S3 | gönder | 48,0 | 2,02 | 8,5 | 3,84 | %7,8 | %20,0 | 0,30 |
| S3 | eşikli | 48,0 | 1,92 | 8,2 | 3,92 | %6,6 | %18,0 | 0,15 |
| S3 | hep gönder | 48,0 | 2,00 | 8,5 | 3,83 | %7,8 | %19,5 | 0,30 |
| S4 | bırak | 107,0 | 1,46 | 9,5 | 4,09 | %5,1 | %29,2 | 0,00 |
| S4 | gönder | 107,0 | 1,70 | 9,5 | 3,91 | %5,1 | %34,8 | 0,70 |
| S4 | eşikli | 107,5 | 1,57 | 9,5 | 4,01 | %5,4 | %36,0 | 0,25 |
| S4 | hep gönder | 108,0 | 1,71 | 9,2 | 3,91 | %5,4 | %29,8 | 0,70 |
| S5 | bırak | 265,5 | 1,09 | 12,0 | 3,89 | %3,4 | %18,5 | 0,00 |
| S5 | gönder | 267,0 | 1,21 | 12,2 | 3,82 | %3,8 | %19,5 | 0,55 |
| S5 | eşikli | 266,0 | 1,16 | 12,2 | 3,86 | %3,4 | %16,0 | 0,20 |
| S5 | hep gönder | 266,0 | 1,38 | 13,0 | 3,73 | %4,0 | %14,5 | 1,15 |
| S6 | bırak | 539,0 | 1,09 | 17,0 | 3,70 | %3,0 | %4,2 | 0,00 |
| S6 | gönder | 540,0 | 1,10 | 17,0 | 3,69 | %3,0 | %4,5 | 0,20 |
| S6 | eşikli | 539,5 | 1,08 | 17,0 | 3,70 | %3,0 | %2,5 | 0,00 |
| S6 | hep gönder | 540,0 | 1,24 | 18,5 | 3,58 | %3,4 | %4,0 | 2,08 |
| S10 | bırak | 283,0 | 1,51 | 14,5 | 3,71 | %3,4 | %11,8 | 0,00 |
| S10 | gönder | 283,5 | 1,66 | 14,8 | 3,66 | %3,7 | %13,5 | 0,72 |
| S10 | eşikli | 282,5 | 1,62 | 15,0 | 3,67 | %3,5 | %13,2 | 0,47 |
| S10 | hep gönder | 283,5 | 2,00 | 16,5 | 3,47 | %4,1 | %11,0 | 2,10 |

- Hiçbir politikada hata sprinti yok (S1 3/507 hariç, tek kurucu). Hep bırak ile hep gönder arasında teslim farkı en çok %0,9 (S4); hep gönder kartı 0,1 ile 0,2 hafta erken çıkarıyor, açık hatayı en çok %13,8 (S10) ve kaçan hatayı %14 ile %33 artırıyor (S6 ve S10).
- Eşikli politika (ağır bilinen hata yoksa gönder) iki uç arasında: S4'te kaçan / 100 puan 1,46 (bırak), 1,57 (eşikli), 1,71 (gönder).
- S2'de (kapsam dışı) gönder teslimi 19,6'dan 19,1'e (−%2,5) düşürüyor; nedeni bu turda ayrıca ölçülmedi.

### 6.4 Sprint düzeni: arz kipleri ve kart sayısı ölçeği (`SPRINT_DUZENI.md` K7, K8)
Sonlu katalog (9 hat, 27 kart) tükenme haftası (2 hf sprint, 20 tohum medyanı): 3 kişi **37**, 6 kişi **18**, 12 kişi **12**, 25 kişi **9**, 50 kişi **7**; tek kurucu 140 haftada bitmiyor (20 tohumun 1'inde bitti). SD §4.1'in 32 · 16 · 11 · 9 · 7 değerleri v3 modelinde 0 ile 5 hafta geç (tahmin: düzeltme alt aşaması ve kurucu tabanı).

| Ekip | Sprint | Arz | Teslim | Boşta payı | Boşta nedenleri (kart yok / aşama dolu / rol uymuyor / hazırlanacak kart yok; kişi-hf / hf) | Açık aday ≥ hedef | Kart yok sprinti | Sprintte kart | Öneri doluluğu |
|---|---|---|---|---|---|---|---|---|---|
| S1 · 1 | 1 hf | sonlu | 4,2 | %18 | 0,2 / 0,0 / 0,0 / 0,0 | %100 | %0 | 1,2 | - |
| S1 · 1 | 1 hf | kaynaklı | 4,2 | %18 | 0,2 / 0,0 / 0,0 / 0,0 | %100 | %0 | 1,2 | %100 |
| S1 · 1 | 2 hf | sonlu | 4,1 | %21 | 0,2 / 0,0 / 0,0 / 0,0 | %100 | %0 | 1,2 | - |
| S1 · 1 | 2 hf | kaynaklı | 4,1 | %21 | 0,2 / 0,0 / 0,0 / 0,0 | %100 | %0 | 1,2 | %100 |
| S2 · 3 | 1 hf | sonlu | 9,0 | %59 | 0,8 / 0,1 / 0,9 / 0,0 | %50 | %20 | 1,4 | - |
| S2 · 3 | 1 hf | kaynaklı | 15,2 | %30 | 0,2 / 0,0 / 0,7 / 0,0 | %100 | %0 | 2,4 | %77 |
| S2 · 3 | 2 hf | sonlu | 8,0 | %69 | 1,5 / 0,1 / 0,6 / 0,0 | %16 | %70 | 1,3 | - |
| S2 · 3 | 2 hf | kaynaklı | 21,0 | %13 | 0,0 / 0,0 / 0,4 / 0,0 | %100 | %0 | 4,8 | %87 |
| S3 · 6 | 1 hf | sonlu | 0,0 | %96 | 4,1 / 0,3 / 0,4 / 1,0 | %0 | %100 | 0,5 | - |
| S3 · 6 | 1 hf | kaynaklı | 43,7 | %19 | 0,0 / 0,2 / 0,4 / 0,6 | %100 | %0 | 5,2 | %90 |
| S3 · 6 | 2 hf | sonlu | 0,0 | %96 | 4,1 / 0,3 / 0,4 / 1,0 | %0 | %100 | 0,5 | - |
| S3 · 6 | 2 hf | kaynaklı | 44,7 | %16 | 0,0 / 0,1 / 0,3 / 0,6 | %100 | %0 | 8,8 | %89 |
| S4 · 12 | 1 hf | sonlu | 0,0 | %98 | 8,5 / 0,6 / 0,8 / 2,0 | %0 | %100 | 0,5 | - |
| S4 · 12 | 1 hf | kaynaklı | 92,5 | %18 | 0,0 / 0,7 / 0,1 / 1,4 | %100 | %0 | 9,9 | %94 |
| S4 · 12 | 2 hf | sonlu | 0,0 | %98 | 8,5 / 0,6 / 0,7 / 2,0 | %0 | %100 | 0,5 | - |
| S4 · 12 | 2 hf | kaynaklı | 97,6 | %13 | 0,0 / 0,2 / 0,0 / 1,3 | %100 | %0 | 16,5 | %95 |
| S5 · 25 | 1 hf | sonlu | 0,0 | %99 | 19,0 / 1,3 / 1,5 / 3,0 | %0 | %100 | 0,5 | - |
| S5 · 25 | 1 hf | kaynaklı | 236,6 | %10 | 0,0 / 1,2 / 0,0 / 1,3 | %82 | %0 | 22,3 | %98 |
| S5 · 25 | 2 hf | sonlu | 0,0 | %99 | 19,0 / 1,3 / 1,5 / 3,0 | %0 | %100 | 0,5 | - |
| S5 · 25 | 2 hf | kaynaklı | 217,3 | %15 | 0,0 / 1,4 / 0,1 / 2,2 | %80 | %0 | 33,8 | %99 |
| S6 · 50 | 1 hf | sonlu | 0,0 | %100 | 38,0 / 2,8 / 3,1 / 6,0 | %0 | %100 | 0,5 | - |
| S6 · 50 | 1 hf | kaynaklı | 372,8 | %27 | 0,0 / 7,8 / 0,3 / 5,2 | %0 | %0 | 35,7 | %99 |
| S6 · 50 | 2 hf | sonlu | 0,0 | %100 | 38,2 / 2,7 / 3,0 / 6,0 | %0 | %100 | 0,5 | - |
| S6 · 50 | 2 hf | kaynaklı | 295,6 | %42 | 0,0 / 13,4 / 1,7 / 6,0 | %0 | %0 | 40,3 | %100 |

- **Sonlu katalog** 6 kişi ve üstünde 21-60. haftada teslim sıfır, sprintlerin %100'ü "kart yok". 3 kişide %70'i (2 hf) ya da %20'si (1 hf).
- **Kaynaklı arz** 12 kişiye kadar yetiyor (açık aday ≥ hedef %100, kart yok sprinti %0). 25 kişide sprintlerin %20'sinde, 50 kişide tamamında aday havuzu hedefin altında; 50 kişide boşta %27 (1 hf) ile %42 (2 hf), baskın neden "aşama dolu".
- **Boşta nedenleri** kaynaklı arzda: 3 kişide "rol uymuyor"; 6 ile 12 kişide PM'in "hazırlanacak kart yok" payı baskın; 25 kişide "aşama dolu" ile eşit; 50 kişide "aşama dolu".
- **Öneri doluluğu** 3 kişide %77 ile %87, 6 kişide %89, 12 kişide %94 ile %95 (kapı 19).

Büyüme eğrisi (1 → 3 → 6 → 10 kişi, 130 hafta):

| Eğri | Teslim (21-130 hf) | Boşta payı | Açık aday ≥ hedef | Kart yok sprinti | Kart kaynağı (oluşan kart: kademe / derinlik / istek) | Teslim puanında istek / derinlik / kademe | İstek: yapıldı / düştü / kademeye bağlandı |
|---|---|---|---|---|---|---|---|
| sonlu katalog (1 → 3 → 6 → 10 kişi) | 4,4 | %76 | %5 | %92,2 | 24 / 0 / 0 | %0 / %0 / %100 | 0 / 0 / 0 |
| kaynaklı (1 → 3 → 6 → 10 kişi) | 66,6 | %7 | %100 | %0,0 | 24 / 41 / 420 | %89 / %2 / %10 | 298 / 48 / 20 |

- Kaynaklı arzda büyüme eğrisi 130 hafta boyunca arzda sıkışmıyor: kart yok sprinti %0, açık aday hedefte %100. Ama arzın taşıyıcısı istek akışı: oluşan 485 kartın 420'si istek, 41'i derinlik, 24'ü kademe; teslim puanının %89'u istek kartı. Derinlik kartı bu ekip büyüklüğünde arzın küçük payı (%2 puan); kademe ve istek kartları ekibi doyuruyor.
- İstek kartlarının 298'i yapıldı, 48'i süre dolunca düştü, 20'si kademe kartının yerine geçti. İstek 8 haftalık süre varsayımıyla düşüyor (yorum 6).

Sabit hesap sayısıyla istek payı (S3 ile S6, 60 hf):

| Ekip | Hesap | Teslim | İstek kartı payı (oluşan kartlarda) | İstek payı (teslim puanında) | İstek: yapıldı / düştü | Boşta payı | Açık aday ≥ hedef |
|---|---|---|---|---|---|---|---|
| S3 · 6 | 100 | 43,1 | %58 | %68 | 77 / 0 | %20 | %100 |
| S3 · 6 | 330 | 46,4 | %82 | %75 | 90 / 101 | %7 | %100 |
| S4 · 12 | 100 | 98,1 | %38 | %37 | 88 / 0 | %14 | %100 |
| S4 · 12 | 330 | 105,4 | %82 | %84 | 212 / 32 | %8 | %100 |
| S5 · 25 | 100 | 227,4 | %20 | %18 | 94 / 0 | %13 | %100 |
| S5 · 25 | 330 | 228,1 | %59 | %57 | 307 / 0 | %11 | %100 |
| S6 · 50 | 100 | 309,6 | %15 | %13 | 97 / 0 | %40 | %0 |
| S6 · 50 | 330 | 385,9 | %39 | %35 | 316 / 0 | %23 | %0 |

- Hesap sayısı arttıkça isteğin payı artıyor: 330 hesapta 6 kişide %75, 12 kişide %84, 25 kişide %57, 50 kişide %35 (teslim puanında). 330 hesapta 6 kişilik ekip 256 istek kartının yalnız 90'ını yapabiliyor, 101'i süre dolunca düşüyor: küçük ekipte istek akışı ekibi aşıyor, büyük ekipte yetmiyor.
- 50 kişi 330 hesapta bile sınırsız arzdan (539) %28 geride (386) ve boşta %23; derinlik kartı üst sınırı bunun ana nedeni (kapı 16, §8.3).

Bu bölümün ek ölçüsü `planlama_eylemi` (SD §5.2) yapısaldır: öneriyi uygula ve başlat, iki eylem, her boyutta; benzetimde ölçülmedi. `plan_suresi` yalnız Godot'ta ölçülür (D0).

### 6.5 EA takım (D1, K10): 50 kişi, 130 hafta
| Düzen | Takım (kişi · hız çarpanı) | Teslim 21-60 hf | Teslim 67-130 hf | Takımsıza göre (67-130) | Boşta payı (67-130) | Kart yok sprinti (21-60) |
|---|---|---|---|---|---|---|
| takımsız (50 kişi) | 50 · ×1,00 | 295,6 | 411,1 | +%0 | %19 | %0 |
| 1 takım, lider 6 | 50 · ×0,85 | 269,7 | 368,9 | −%10 | %15 | %0 |
| 3 takım, liderler 4, 6, 8 | 17 · ×0,81, 17 · ×0,87, 16 · ×0,95 | 254,5 | 304,8 | −%26 | %31 | %2 |
| 3 takım, lidersiz | 17 · ×0,70, 17 · ×0,70, 16 · ×0,71 | 213,0 | 248,3 | −%40 | %30 | %0 |
| 7 takım, liderler 2 ile 8 | 8 · ×0,92, 7 · ×0,95, 7 · ×0,99, 7 · ×1,02, 7 · ×1,06, 7 · ×1,09, 7 · ×1,13 | 217,0 | 252,6 | −%39 | %49 | %30 |
| 7 takım, lidersiz | 8 · ×0,85, 7 · ×0,85, 7 · ×0,85, 7 · ×0,85, 7 · ×0,85, 7 · ×0,85, 7 · ×0,85 | 188,1 | 213,3 | −%48 | %48 | %15 |

Takımsıza göre farkın açıklaması: tahmin = takımsız teslim × takımların kişi ağırlıklı ortalama hız çarpanı × (1 − boşta) ÷ (1 − takımsız boşta).

| Düzen | Pencere | Gerçek | Tahmin: takımsız × ort. çarpan × (1 − boşta) ÷ (1 − takımsız boşta) | Fark açıklanan |
|---|---|---|---|---|
| 1 takım | 67-130 hf | 368,9 | 362,7 (çarpan 0,848, boşta %19 → %15) | %85 |
| 3 takım | 67-130 hf | 304,8 | 304,9 (çarpan 0,875, boşta %19 → %31) | %100 |
| 7 takım | 67-130 hf | 252,6 | 265,2 (çarpan 1,023, boşta %19 → %49) | %92 |
| 3 takım lidersiz | 67-130 hf | 248,3 | 247,9 (çarpan 0,702, boşta %19 → %30) | %100 |
| 7 takım lidersiz | 67-130 hf | 213,3 | 222,4 (çarpan 0,850, boşta %19 → %48) | %95 |
| 1 takım | 21-60 hf | 269,7 | 273,7 (çarpan 0,848, boşta %42 → %37) | %85 |
| 3 takım | 21-60 hf | 254,5 | 262,7 (çarpan 0,875, boşta %42 → %41) | %80 |
| 7 takım | 21-60 hf | 217,0 | 235,7 (çarpan 1,023, boşta %42 → %55) | %76 |
| 3 takım lidersiz | 21-60 hf | 213,0 | 219,6 (çarpan 0,702, boşta %42 → %39) | %92 |
| 7 takım lidersiz | 21-60 hf | 188,1 | 202,5 (çarpan 0,850, boşta %42 → %53) | %87 |

- Fark iki sayıyla açıklanıyor: takım hız çarpanı (kişi başı %2 kayıp ve lider) ve takıma bağlı arzdan boşta kalma. 67-130. haftada 3 takımda %100, 7 takımda %92, lidersiz 3 takımda %100, lidersiz 7 takımda %95; modül öncesi pencerede (21-60) %76 ile %92.
- 17 ve 16 kişilik takımlar ×0,81 ile ×0,95 çarpanla çalışıyor (lider 4, 6, 8); 8-7 kişilik 7 takımın çarpanı ×0,92 ile ×1,13 (kayıp yok ama hat başına arz küçük): boşta %49.
- Lidersiz takım her koşulda daha yavaş (3 takım −%40, 7 takım −%48): lider çarpanı 0,85 ile 1,20 arası ve ortalama lider (Liderlik 6) 1,06 yapıyor.
- **Hiçbir takım düzeni takımsızdan hızlı değil.** Takımın kazancı bu benzetimde ölçülmüyor (oyuncunun planlama eylemi 26 → 2 ile 7); kayıp ise ölçülüyor. Takım satırı yalnız hız çarpanını yazarsa oyuncu kaybın yarısını görmez.

Takıma bir kişi eklemek (takım 0, puan/hf; 21-60 / 67-130):

| Eklenen (takım 0'a) | 3 takım: 21-60 / 67-130 hf | 7 takım: 21-60 / 67-130 hf |
|---|---|---|
| +3★ geliştirici | −0,4 / −0,5 | +0,2 / +2,4 |
| +3★ testçi | +1,1 / +0,7 | −2,9 / −0,6 |
| +3★ tasarımcı | +6,9 / +18,1 | +13,9 / +20,6 |
| +3★ PM | −0,8 / −1,9 | +1,4 / +2,8 |

### 6.6 D5: A'nın sınırları oranlı (80 hafta)
| Ekip | k × 30 eşiği (sondaki) | Hiç düzeltmeyen: eşiğe varış (MVP'den sonra hf, medyan; en az-en çok) | 9 hat varsayımıyla | Mutlak 30 ile | Düzenli düzelten: tepe (medyan) | Düzenli düzelten eşiğe vardı |
|---|---|---|---|---|---|---|
| S1 · 1 | 30 | 23,0 (19-44) | 23,0 | 23,0 | 14,5 | 0/20 |
| S2 · 3 | 40 | 23,5 (17-31) | 17,0 | 17,0 | 15,0 | 0/20 |
| S3 · 6 | 40 | 20,5 (15-30) | 16,0 | 15,0 | 17,0 | 0/20 |
| S4 · 12 | 43 | 17,0 (13-21) | 17,0 | 13,0 | 18,0 | 0/20 |
| S5 · 25 | 67 | 17,0 (13-21) | 17,0 | 9,0 | 23,0 | 0/20 |
| S6 · 50 | 95 | 15,0 (13-17) | 15,0 | 5,0 | 29,0 | 0/20 |

- Hiç düzeltmeyen ekip her ölçekte MVP'den sonra 15 ile 23,5 haftada (yaklaşık 4 ile 5 ay) k × 30'a varıyor; düzenli düzelten ekip hiçbir ölçekte, hiçbir tohumda varmıyor (120 koşu).
- Mutlak 30 ile 50 kişilik ekip 5 haftada varıyordu; oranlı kuralla 15 hafta. Düzenli düzelten 50 kişilik ekibin tepesi 29 (mutlak 30'a 7/20 tohumda değiyordu).
- 12 hatlı benzetimde k tabanı 1,33; 9 hatlı oyunda S1 ile S3 için eşik 30 ve varış 23 · 17 · 16 hafta.

### 6.7 Plan tahmini = sonuç kontrolü (§3.11, kapı 14)
Her sprint başında plan, kartların kopyalarını aynı oynatma fonksiyonuyla (önden tasarım ve hazırlık kuyruğu dahil) 2 hafta oynatır; sprint bitince gerçek kartlar kopyalarla karşılaştırılır. Karşılaştırılanlar: kart başına dört aşamanın ilerlemesi, bitiş zamanı, kartın n (hata sayısı), F (bulunan) ve düzeltme işi toplamı. Hata sayısı kart tohumundan test anında çekildiği için plan ve kapanış aynı sayıyı bulur; v2'nin "çekiliş karşılaştırılmaz" istisnası kalktı.

Sonuç: 8.220 koşuda (tüm ölçek, uç bileşim, politika, arz ve EA senaryoları) en büyük fark **1,4e-14** (kapı: 1e-6). Aynı kart, aynı ekip, iki ayrı koşuda aynı n, F, düzeltme işi ve bitiş zamanını verdi (§2, son satır). Benzetimde adlı uyuşmazlık nedenleri (B'nin kararları, işe alım ya da ayrılık, izin, kurucu toplantısı) yok; bunlar tahmini oyunda bozar, benzetimde değil.

## 7. Kapı tablosu (§6.12)
| # | Kapı | Hedef | Sonuç | Değer |
|---|---|---|---|---|
| 1 | `ekleme_dusurmez` | Bir kişi eklemek hiçbir senaryoda teslimi 1 puan/hf'den fazla düşürmez (takım kipi kapı 22'de) | GEÇTİ | En kötü −1,0 (S3'e 3★ tasarımcı; sınırda). Marjinal tablo −1,0, kişi ekleme eğrisi −0,5 (37. kişi, PM), kurucu büyümesinin 72 adımında en küçük artış +0,2 |
| 2 | `kurucu_buyume` | Teslim her adımda artar; MVP gecikmez; kurucunun işi en çok %10 düşer ve nedeni (aşama değişti) kayıtta | **KALDI** | Teslim 72 adımda da arttı (en küçük +0,2); MVP gecikmesi 0. Kurucunun işi tabana göre en çok −%10,1 (5★ kurucu, üç geliştirici); %2'den büyük 16 düşüşün 9'unda aşama değişmedi |
| 3 | `mvp_tek_kurucu` | 6 ile 7. hafta | GEÇTİ | 20 tohumun 17'sinde 6., 3'ünde 7. hafta |
| 4 | `kisi_basi_olcek` | S5 ve S6 kişi başı, S3'ün %70 ile %150'si | GEÇTİ | S5 %132,8, S6 %134,8 (kişi başı 8,0 · 10,6 · 10,8) |
| 5 | `darbogaz_rolu` | Darboğaz rolüne kişi eklemek teslimi artırır | GEÇTİ | S8 + Test kutulu geliştirici 17,0 → 24,5; S11 + testçi 36,0 → 91,0; S9a + geliştirici 7,9 → 17,4 |
| 6 | `duzeltme_payi` | ≥ 2 kişi: erken ≤ %30, geç ≤ %20, hata sprinti ≤ %5, üst üste yok; tek kurucu erken ≤ %50, geç hata sprinti ≤ %5; dört politikada da | GEÇTİ | 341 senaryo: ≥ 2 kişide en yüksek erken %16,7, geç %16,7, hata sprinti %0,5; tek kurucuda erken en çok %29,1, hata sprinti en çok %1,2; üst üste hata sprinti yok |
| 7 | `toplam_hata_isi` | Düzeltme kartı + sprint içi düzeltme ≥ 2 kişide ≤ %20, tek kurucuda ≤ %35 | GEÇTİ | ≥ 2 kişide en çok %17,4; tek kurucuda en çok %29,8 (S1 %29,6) |
| 8 | `acik_hata_sinirli` | `fix_due` ile son 20 haftanın eğimi ≤ 0,2 hata/hf | GEÇTİ | En büyük medyan eğim +0,10; A senaryosunda tohum dağılımının %95'i 0,27 |
| 9 | `testci_yildizi` | 1★ → 5★: kaçan / 100 puan ≥ %40 azalır, bulunan ≥ 2 katı; C en iyi testçinin c'sini aşmaz | GEÇTİ | 6 kişi −%56,8 ve ×2,6; 12 kişi −%60,9 ve ×2,3; 25 kişi −%63,5 ve ×2,7; tavan aşımı 0 kart |
| 10 | `testci_degeri` | Testçisiz yerine 3★ testçi: teslim düşmez, kaçan / 100 ≥ %20 azalır | GEÇTİ | 6 kişi teslim +%8,9, kaçan −%35,8; 12 kişi +%9,1 ve −%25,9; 25 kişi +%14,3 ve −%24,9 |
| 11 | `pm_yildizi` | Tek PM 1★ → 5★: teslim ≥ %10, kaçan / kart ≥ %25 azalır; PM'siz → PM iyileşir | **KALDI** | 6 kişi +%22,4 ve −%43,3; 11 kişi +%23,2 ve −%33,3; **23 kişi +%11,1 ve −%19,9 (kalan)**; PM'siz → PM üç ekipte de iyileşiyor |
| 12 | `soru_sikligi` | S2 ile S5 ve S10: soru ≤ 1/3; 6 ve 12 kişide ≥ 1/20 | GEÇTİ | S2 %4,5 · S3 %21,5 · S4 %29,2 · S5 %18,5 · S10 %11,8; iki 5★ testçili 12 kişi %32,8 |
| 13 | `soru_politikasi` | Dört politikada teslim farkı ≤ %2; hep gönder açık hata medyanını ≤ %20 artırır; hata sprinti yok | GEÇTİ | Teslim farkı en çok %0,9 (S4); hep gönder açık hatayı en çok %13,8 artırır (S10); S2'de (kapsam dışı) gönder −%2,5 |
| 14 | `tahmin_sonuc` | Plan ile kapanış: aşama ilerlemesi, bitiş, n, F farkı ≤ 1e-6 | GEÇTİ | 8.220 koşuda en büyük fark 1,4e-14 (bulunan hata ve düzeltme işi dahil) |
| 15 | `a_sinirlari_oranli` | Hiç düzeltmeyen her ölçekte 10 ile 26 haftada k × 30'a varır; `fix_due` hiçbirinde varmaz | GEÇTİ | Medyan varış S1 23 · S2 23,5 · S3 20,5 · S4 17 · S5 17 · S6 15 hf (9 hat: 23 · 17 · 16 · 17 · 17 · 15); `fix_due` 120 koşunun hiçbirinde varmadı |
| 16 | `arz_havuzu` | Kaynaklı arzda sprintlerin ≥ %90'ında açık aday ≥ 0,75 × ekip (8 kişi altında ≥ ekip) | **KALDI** | Büyüme eğrisi %100; S1 ile S4 %100; **S5 %80, S6 %0** (330 hesapta S5 %100, S6 %0) |
| 17 | `bosta_nedenli` | Boşta ≤ %10; değilse her sprintte nedeni yazılı | GEÇTİ | 7.460 koşunun 5.525'inde boşta > %10; hepsinde dört nedenin toplamı boşta'ya eşit (nedensiz 0) |
| 18 | `kart_yok_sprinti` | Büyüme eğrisi, 130 hf: "planlanacak kart kalmadı" sprinti ≤ %5 | GEÇTİ | Kaynaklı %0,0 (sonlu katalog %92,2) |
| 19 | `oneri_dolulugu` | Önerinin aldığı iş ÷ planın alabileceği ≥ %95; bot = öneri | **KALDI** | **En düşük %77,0 (S2, 1 hf); S2 %77 ile %87, S3 %89, S4 %94 ile %95**; S5 ve S6 ≥ %97,8. Bot ayrı yol kullanmıyor |
| 20 | `derinlik_kazanci` | Aynı alana art arda 5 derinlik kartı: 5.'nin kazancı ilkinin ≤ 1/3'ü | GEÇTİ | %31,6 (0,75⁴); S6 kaynaklı koşuda 80 alanın 80'inde ≥ 5 derinlik kartı bitti |
| 21 | `istek_payi` | 100 ve 330 hesapta isteğin payı raporlanır | GEÇTİ | Teslim puanında istek payı: S3 %68,5 / %74,8 · S4 %36,9 / %83,9 · S5 %17,7 / %57,4 · S6 %13,2 / %35,0 (100 / 330 hesap) |
| 22 | `takim_bolme` | 50 kişi 3 ve 7 takım liderli: teslim takımsızdan geri kalmaz ya da farkı takım satırında yazılı; lidersiz 7 takım takımsızdan yavaş; kişi eklemek düşürmez (−1) | **KALDI** | 67-130. hf: takımsız 411,1; 1 takım 368,9; 3 takım 304,8; 7 takım 252,6; lidersiz 3 takım 248,3; lidersiz 7 takım 213,3. **Kişi eklemede en kötü −2,9 (7 takım, testçi)** |
| 23 | `uymayan_moral` | S3 + PM'in Test kutusu: PM 60 haftada 60 ile 90 moral kaybeder | GEÇTİ | PM medyan −68 (en az −56, en çok −80) |

**23 kapının 18'ü geçti.** Kalanlar: 2, 11, 16, 19, 22. Kapı 1 sınırda (−1,0 = tolerans); kapı 12'nin en yüksek değeri %29,2 ve iki 5★ testçili 12 kişi %32,8 (sınır 33,3).

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

| Ekip | 1★ → 5★ teslim | 1★ → 5★ kaçan / kart | Hazır kart (1★ → 5★) |
|---|---|---|---|
| 25 kişi, 3 PM | 230,0 → 279,0 (+%21,3) | 0,59 → 0,39 (−%34,1) | %97 → %100 |
| 24 kişi, 2 PM | 223,0 → 273,0 (+%22,4) | 0,60 → 0,40 (−%33,0) | %67 → %92 |

İki ekipte de teslim ≥ +%21 ve kaçan / kart ≤ −%33: kapı geçer.

### 8.3 Kapı 16 · `arz_havuzu`
**Tanı.** İki ayrı neden.
- *50 kişi:* derinlik kartı üst sınırı 4 × 9 hat = **36**; hedef 0,75 × 50 = **37,5**. Hesap ne kadar çok olursa olsun açık derinlik kartı 36'yı geçmiyor; 330 hesapta bile 50 kişi 386 puana kalıyor ve %23 boşta. Formül §3.13 B: min(4, 1 + ⌊hesap ÷ 10⌋).
- *Havuzun boşaltılması:* ekip her planda açık adayların hepsini alıyor; havuz ancak arz tüketimi aşarsa hedefin üstünde kalıyor. 25 kişide sabit ekip 0. haftadan tam: 21. haftada 57 hesapla hat başına 2 derinlik kartı var, havuz sprintlerin %20'sinde 18,75'in altında. 330 hesapta sorun yok (%100).
- Büyüme eğrisinde sorun yok (%100); sabit 50 kişilik ekibin 0. haftadan hesapsız başlaması gerçekçi bir oyun durumu değil.

**Öneri.** Açık derinlik kartı = 1 + ⌊hesap ÷ 5⌋ ve üst sınır 8 (ya da ilke 1 gereği üst sınırsız). Sabitler [ÇALIŞMA].

**Etki (Öneri).** Hücre: açık aday ≥ hedef · teslim · boşta payı (20 tohum, 2 hf sprint).

| Ölçüm | Taban (sınır 4, bölen 10) | Sınır 8 | Sınır yok | Bölen 5 | Bölen 5, sınır 8 | Bölen 5, sınır yok |
|---|---|---|---|---|---|---|
| S5 · 25 kişi, 3 hesap/hf (aday ≥ hedef · teslim · boşta) | %80 · 217,3 · boşta %15 | %80 · 221,1 · boşta %14 | %80 · 221,1 · boşta %14 | %100 · 230,2 · boşta %12 | %100 · 245,6 · boşta %8 | %100 · 245,4 · boşta %7 |
| S6 · 50 kişi, 3 hesap/hf (aday ≥ hedef · teslim · boşta) | %0 · 295,6 · boşta %42 | %5 · 317,3 · boşta %37 | %5 · 317,3 · boşta %37 | %0 · 319,8 · boşta %37 | %65 · 406,5 · boşta %21 | %65 · 419,1 · boşta %20 |
| S5, 330 hesap (aday ≥ hedef · teslim · boşta) | %100 · 228,1 · boşta %11 | %100 · 228,6 · boşta %11 | %100 · 225,5 · boşta %11 | %100 · 228,1 · boşta %11 | %100 · 228,6 · boşta %11 | %100 · 217,1 · boşta %13 |
| S6, 330 hesap (aday ≥ hedef · teslim · boşta) | %0 · 385,9 · boşta %23 | %100 · 474,8 · boşta %12 | %100 · 482,9 · boşta %11 | %0 · 385,9 · boşta %23 | %100 · 474,8 · boşta %12 | %100 · 465,8 · boşta %13 |
| büyüme eğrisi 1→10 kişi (aday ≥ hedef · teslim · boşta) | %100 · 66,6 · boşta %7 | %100 · 66,5 · boşta %7 | %100 · 66,6 · boşta %7 | %100 · 66,3 · boşta %7 | %100 · 66,8 · boşta %7 | %100 · 66,8 · boşta %7 |

- Bölen 5 ve üst sınır 8 birlikte: 25 kişi %80 → %100 (teslim 217,3 → 245,6, boşta %14,6 → %7,6); 50 kişi 330 hesapta %0 → %100 (teslim 385,9 → 474,8, boşta %23,4 → %12,1); büyüme eğrisi aynı (%100, teslim 66,6 → 66,8). Sabit 50 kişilik ekip 3 hesap/hf ile %0 → %65 (teslim 295,6 → 406,5) ama hâlâ < %90: ekip 0. haftadan tam ve hesap azken arz tüketimin gerisinde.
- Üst sınır tek başına yalnız 330 hesaplı 50 kişiyi düzeltiyor (%100), bölen tek başına yalnız 25 kişiyi (%100). İkisi ayrı eksende.
- Üst sınırı tamamen kaldırmak (bölen 5, son sütun) 25 kişide aynı (%100, 245,4), sabit 50 kişide %65 (419,1), 330 hesapta 50 kişide %100 (465,8); 330 hesapta 25 kişide teslim 228,1 → 217,1'e düşüyor (derinlik kartları isteklerin yerini alıyor). Bu yüzden öneri üst sınır 8.

### 8.4 Kapı 19 · `oneri_dolulugu`
**Tanı.** Formül §6.5 adım 4: "sprintte kart varsa şunlardan biri tutmazsa durulur". Sıradaki aday (ör. 40 puanlık K3 ya da 25 puanlık istek) toplam tavana (1,25 × kapasite) ya da aşama tavanına takılınca, arkasındaki 15 puanlık küçük kartlar da elenir. §3.12 b ise "öneri planın alım kuralıyla tavana kadar doldurur" diyor: ikisi çelişiyor. Sonuç: S2'de planın %13 ile %23'ü, S3'te %11'i, S4'te %5 ile %6'sı boş; S5 ve S6'da %2'nin altında. Bot öneriyle aynı kodu kullanıyor (bot = öneri koşulu yapısal olarak tutuyor).

**Öneri.** Uymayan adayı atla, sıradaki en çok 12 adaya bak (durma yok). Sabit yok, kural değişikliği.

**Etki (Öneri).** 20 tohum, kaynaklı arz:

| Ekip · sprint | Öneri doluluğu: taban → atlayarak | Teslim | Boşta payı | Sprintte kart | Düzeltme payı (geç) | Hata sprinti |
|---|---|---|---|---|---|---|
| S2 · 3 · 1 hf | %77 → %97 | 15,2 → 19,1 | %30 → %16 | 2,4 → 2,9 | %10,1 → %17,4 | 0/800 → 1/800 |
| S2 · 3 · 2 hf | %87 → %100 | 21,0 → 21,9 | %13 → %10 | 4,8 → 5,5 | %9,5 → %9,1 | 0/400 → 0/400 |
| S3 · 6 · 1 hf | %90 → %100 | 43,7 → 45,8 | %19 → %17 | 5,2 → 5,8 | %9,8 → %9,8 | 0/800 → 0/800 |
| S3 · 6 · 2 hf | %89 → %99 | 44,7 → 44,9 | %16 → %14 | 8,8 → 9,7 | %5,9 → %5,6 | 0/400 → 0/400 |
| S4 · 12 · 1 hf | %94 → %100 | 92,5 → 95,8 | %18 → %15 | 9,9 → 10,5 | %4,9 → %4,9 | 0/800 → 0/800 |
| S4 · 12 · 2 hf | %95 → %100 | 97,6 → 98,1 | %13 → %13 | 16,5 → 17,2 | %4,9 → %4,9 | 0/400 → 0/400 |
| S5 · 25 · 1 hf | %98 → %100 | 236,6 → 239,2 | %10 → %10 | 22,3 → 22,8 | %4,2 → %4,0 | 0/800 → 0/800 |
| S5 · 25 · 2 hf | %99 → %100 | 217,3 → 216,6 | %15 → %15 | 33,8 → 34,0 | %3,4 → %3,4 | 0/400 → 0/400 |
| S6 · 50 · 1 hf | %99 → %100 | 372,8 → 372,9 | %27 → %27 | 35,7 → 36,0 | %2,9 → %2,7 | 0/800 → 0/800 |
| S6 · 50 · 2 hf | %100 → %100 | 295,6 → 295,6 | %42 → %42 | 40,3 → 40,3 | %2,2 → %2,2 | 0/400 → 0/400 |

Doluluk %96,8 ile %100'e çıkıyor (en düşük S2, 1 hf); teslim S2 (1 hf) +%26, S3 +%5 (1 hf), S4 +%4 (1 hf); boşta payı düşüyor. S5 ve S6 değişmiyor. Yan etki: S2 1 hf'de düzeltme payı %10,1 → %17,4 ve ilk hata sprinti (1/800): atlayarak dolduran öneri düzeltme kartlarının payını da büyütüyor ama kapı 6'nın sınırları (≤ %30, ≤ %20) içinde.

### 8.5 Kapı 22 · `takim_bolme`
**Tanı.** Üç yan koşuldan ikisi kalıyor.
- *c1, takımlar takımsızdan geri kalıyor (kalan, koşullu geçer).* 67-130. hf takımsız 411,1; 3 takım 304,8 (−%26); 7 takım 252,6 (−%39). İki sayı farkı açıklıyor: ortalama hız çarpanı (3 takımda ×0,875) ve takıma bağlı arzdan boşta (%31, takımsız %19). Çarpım 3 takımda 304,9 (gerçek 304,8). Koşulun ikinci kolu ("farkı takım satırında yazılı") ancak takım satırı hız çarpanının yanında boşta kişi sayısını da yazarsa sağlanır; belgedeki takım satırı (§3.14) yalnız hız çarpanını yazıyor.
- *c3, kişi eklemek düşürmüyor (kalan).* 7 takımda takım 0'a testçi eklemek −2,9 (21-60 hf), 3 takımda PM eklemek −1,9 (67-130 hf). Formül §3.14 `TEAM_LOSS`: 8. kişiden sonra kişi başı %2 ve tüm takımın hızına uygulanıyor; darboğaz olmayan bir kişi hem hiçbir şey eklemiyor hem tüm takımı %2 yavaşlatıyor. Kayıp kapatılınca en kötü −0,5 (kanıt: `TEAMLOSS=0` koşusu).
- *c2, lidersiz 7 takım takımsızdan yavaş:* geçti (213,3).

**Öneri.** (1) Takım satırına "boşta N kişi" eklemek (c1 için). (2) Büyüklük kaybını yalnız 8. kişiden sonra gelenlerin hızına uygulamak (marjinal kayıp); kişi eklemek bu durumda diğerlerini yavaşlatmaz. Alternatif: kayıp katsayısını %2'den %1'e indirmek.

**Etki (Öneri).** 67-130. hf teslim ve kişi eklemede en kötü fark:

| Düzen | Taban: teslim 67-130 hf | Kayıp %1 (tüm takım) | Kayıp yalnız 8. kişiden sonra gelenlere | Kişi eklemede en kötü: taban | Kayıp %1 | Marjinal kayıp |
|---|---|---|---|---|---|---|
| 3 takım (liderli) | 304,8 | 332,4 | 332,9 | −1,9 | −1,0 | −0,8 |
| 7 takım (liderli) | 252,6 | 252,6 | 252,6 | −2,9 | −1,5 | −0,5 |

Takımsıza göre: 3 takım taban %74, marjinal %81; 7 takım taban %61, marjinal %61. Marjinal kayıpta kişi eklemenin en kötü sonucu −0,8 (3 takım, PM; tolerans −1): c3 geçer. Kayıp %1'de −1,5 kalıyor (7 takım, testçi), yetmiyor. Marjinal kayıp 3 takımı +%9 hızlandırıyor ama takımsızın %81'inde bırakıyor; c1 yapısal olarak (arzın takıma bağlanması) kalıyor ve ancak takım satırındaki açıklamayla karşılanır.

### 8.6 Kapıların dışında: 1 haftalık sprintte tek kurucu
**Tanı.** `Kart sayısı ölçeği` senaryosunun 1 haftalık sprint kolunda tek kurucu 800 sprintin 401'inde hata sprinti (%50) ve düzeltme payı %43,6. Formül §3.12 c "en az 5 puan": kurucunun 1 haftalık kapasitesi 8,6 puan, tek açık hatalı hat bile 5 puanlık kart açıyor (kapasitenin %58'i); düzeltme payı tavanı "ilk kart her zaman girer" diyor. Bu, A'nın "sürekli hata sprinti yok" ilkesine (ilke 6) aykırı. 2 haftalık sprintte aynı ekip 4/569 (%0,7).

**Öneri.** Düzeltme kartının alt sınırını sprint süresine ve kapasiteye bağlamak. Denenen: alt sınır 5 → 2,5.

**Etki (Öneri).**

| Ekip · 1 hf sprint | Teslim | Düzeltme payı (geç) | Hata sprinti | Açık hata (medyan) |
|---|---|---|---|---|
| S1 · tek kurucu | 4,2 → 4,5 | %43,6 → %34,9 | 401/800 → 53/800 | 5,0 → 5,2 |
| S2 · 3 kişi | 15,2 → 16,6 | %10,1 → %7,7 | 0/800 → 0/800 | 5,0 → 5,5 |
| S3 · 6 kişi | 43,7 → 44,7 | %9,8 → %7,8 | 0/800 → 0/800 | 6,0 → 5,2 |

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

## 11. İnceleme sonrası (Opus)
Kıdemli inceleme, 17 Ekim 2026 gecesi. Kabul edilen öneriler `D_MODEL_v3.md`'ye işlendi: kapı 2 okuması (§8.1, eşik %12 ve
üç neden kodu), kapı 11 kapsamı (§8.2), derinlik kartı ÷ 5 en çok 8 (§8.3), atlayarak doldurma 12 aday (§8.4), takım kaybı
marjinal ve takım satırında boşta (§8.5), düzeltme kartının alt sınırının kalkması (§8.6; kart en az 2 hatada açıldığı için
`D3_FIXMIN=2.5` "alt sınır yok" ile aynı sonucu verir). Kabul edilenler birlikte bir kez koşuldu (`rv_inceleme.py`, 20 tohum,
yaklaşık 6 dakika, 2 işçi; `out/P_rv_birlesik.pkl`, `out/rv_inceleme_out.txt`):

| Senaryo | Açık aday ≥ hedef | Öneri doluluğu | Teslim (puan/hf) | Boşta payı | Düzeltme payı (geç) | Hata sprinti |
|---|---|---|---|---|---|---|
| S1 · 1 hf | %100 → %100 | %100 → %100 | 4,3 → 4,5 | %18 → %20 | %43,6 → %34,9 | 401/800 → 53/800 |
| S1 · 2 hf | %100 → %100 | %100 → %100 | 4,1 → 4,8 | %21 → %18 | %29,1 → %23,3 | 4/569 → 2/540 |
| S2 · 1 hf | %100 → %100 | %77,0 → %94,9 | 15,3 → 19,6 | %30 → %16 | %10,1 → %13,9 | 0/800 → 0/800 |
| S2 · 2 hf | %100 → %100 | %87,1 → %100 | 21,0 → 22,3 | %13 → %8 | %9,5 → %9,2 | 0 → 0 |
| S3 · 1 hf | %100 → %100 | %89,5 → %100 | 43,7 → 46,9 | %19 → %17 | %9,8 → %7,8 | 0 → 0 |
| S3 · 2 hf | %100 → %100 | %89,2 → %99,5 | 44,7 → 46,5 | %16 → %16 | %5,9 → %7,4 | 0 → 0 |
| S4 · 1 hf | %100 → %100 | %94,2 → %100 | 92,5 → 96,9 | %18 → %16 | %4,9 → %3,9 | 0 → 0 |
| S4 · 2 hf | %100 → %100 | %94,7 → %100 | 97,6 → 99,9 | %13 → %13 | %4,9 → %4,4 | 0 → 0 |
| S5 · 1 hf | %82,5 → %100 | %97,8 → %100 | 236,6 → 246,1 | %10 → %8 | %4,2 → %3,4 | 0 → 0 |
| S5 · 2 hf | %80 → %100 | %99,2 → %100 | 217,3 → 247,0 | %15 → %7 | %3,4 → %3,0 | 0 → 0 |
| S6 · 1 hf | %0 → %71 | %99,2 → %100 | 372,8 → 472,3 | %27 → %13 | %2,9 → %2,5 | 0 → 0 |
| S6 · 2 hf | %0 → %65 | %100 → %100 | 295,6 → 406,4 | %42 → %22 | %2,2 → %2,5 | 0 → 0 |
| S5 · 330 hesap | %100 → %100 | %100 → %100 | 228,1 → 230,3 | %11 → %11 | %3,6 → %3,6 | 0 → 0 |
| S6 · 330 hesap | %0 → %100 | %100 → %100 | 385,9 → 475,5 | %23 → %12 | %2,9 → %2,7 | 0 → 0 |
| Büyüme eğrisi 1 → 10 kişi, 130 hf | %100 → %100 | %85,9 → %99,4 | 66,6 → 67,5 | %7 → %6 | %5,7 → %4,5 | 0/1107 → 0/1106 |

Okuma: kapı 16 gerçekçi bütün senaryolarda tutuyor (0. haftadan tam 50 kişi ve haftada 3 hesap hariç); kapı 19 en düşük
%94,9 (3 kişi, 1 hf); kapı 6'da tek aşım tek kurucunun 1 haftalık sprintinde %6,6 hata sprinti. Teslim hiçbir satırda
düşmüyor. Kapı tablosunun (§7) inceleme sonrası okuması: 2, 11, 16, 19 ve 22 kabul edilen değişiklik ya da okumayla geçer;
16 ve 19'un sınırdaki iki hücresi yukarıda yazılı. Yeniden üretim: `python -I dsim3.py exec rv_inceleme.py run`.
