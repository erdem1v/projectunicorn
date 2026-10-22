# A0 · Hata araştırması ve Karar 4 mekanizma önerisi (Faz A, 2026-10-16)

**Arama durumu:** WebSearch KULLANILABİLDİ. 13 arama (hepsi "standard") + 2 WebFetch yapıldı. Sonuçlar ince: bu oyunların resmî
hata formülü yayımlanmamış; bulunanlar oyuncu forumu ve wiki anlatımıdır. Kaynaksız satır "kaynaksız" yazılıdır; model bilgisi
kaynaklı gibi sunulmadı. Sayılar bölüm 1-4'te **bu oyunun kendi kuralları üzerinde** benim yaptığım basit bir Monte Carlo'dan
gelir (araştırma değil, hesap; betik `scratchpad/sim.py`, `sim2.py`, `sim3.py`, repoda yok).

## Tablo · Oyunlar hatayı nasıl ele alıyor

| Oyun | Hata nasıl doğar | Tipik sayı | Nasıl düzelir | Oyuncuya bedeli | Düzeltme payı | Boğulmamak için ne var | Kaynak | Durum |
|---|---|---|---|---|---|---|---|---|
| Game Dev Story | Personel oyun, konsol ya da sözleşme üstünde çalışırken puanlarla birlikte ara sıra hata çıkar; başarısız "Boost" bir anda çok hata ekler; %25'te "oyunu iyileştir" olayı başarısızsa +20-30 hata | Resmî sayı yok; sayaç alt çubukta | Oyun bitince "debug" aşaması: personel yavaşça siler, süre hata sayısı ve program becerisine bağlı | Erken çıkarsan eleştirmen hata bulursa puan düşer (puan 40 üstünden, HoF için 32); para gideri yok, yalnız zaman. Her silinen hata 1-3 araştırma puanı verir | Ayrı bir aşama; oyuncu eylemi değil, otomatik | Debug aşaması atlanabilir; hatayı silmek ödüllü (araştırma puanı) | https://kairosoft.wiki.gg/wiki/Creating_games_(Game_Dev_Story) | arandı-bulundu (sayılar: arandı-bulunamadı) |
| Software Inc. | Alfa aşamasında personel arttıkça ve düşük seviyeli çalışan çoğaldıkça hata üretimi artar; ekip becerisi test sırasında kaç hatanın göründüğünü etkiler (forum anlatımı) | Forum tahmini: sözleşme testinde orta beceride "kod birimi başına ≈50 hata"; 10 birimlik editör ≈500, OS ≈1.500; yayından sonra destek ekibi ≈500 hata daha buldu | Beta'da hata sayısının yaklaşık %70'i silinebilir (forum); yayın sonrası destek ekibi artığı taşır; beta 3-6 ay | Hata ürünü "daha kötü" yapmaz, destek iş yükünü artırır; basın incelemesinde anılırsa kalite düşer (oyuncular çelişiyor) | Destek ekibi ayrı kadro; oyuncu tek tek hata kovalamaz | "Bütün hatayı yakalamak maliyet etkin değil"; keşif yavaşlayınca yayınla; destek "çoğu zaman artığı yetişir"; hatalar önce hızlı sonra yavaş keşfedilir | https://steamcommunity.com/app/362620/discussions/0/1696043263502958919 ; https://steamcommunity.com/app/362620/discussions/0/603028826378785312 | arandı-bulundu (oyuncu anlatımı, resmî değil) |
| Game Dev Tycoon | Geliştirme sırasında rastgele aralıklarla çıkar (oyuncu gözlemi); fazlar boyunca birikir | Sayı bulunamadı | Her geliştirme fazının sonunda düzeltme zamanı; yayın öncesi temizlenebilir | Hatalı oyun kötü karşılanır, para ve itibar kaybettirir; yayını bekletmek erken satış gelirini geciktirir. Yayın sonrası yama yok (kaynaklarda) | Bilinmiyor (faz sonu zaman kaybı) | Yayın serbest; hatayla çıkmak bilinçli ödünleşim | https://www.tekrevue.com/game-dev-tycoon-review-minor-flaws-dont-kill-the-fun/ ; https://steamcommunity.com/app/239820/discussions/0/864977564346123827 | arandı-bulundu (kısmi), formül ve sayı arandı-bulunamadı |
| Mad Games Tycoon 2 | Bulunamadı | Bulunamadı | Bulunamadı (çıkan sonuçlar oyunun kendi çökme hataları, oyun içi hata sistemi değil) | Bulunamadı | Bulunamadı | Bulunamadı | https://steamcommunity.com/app/341000/discussions/0/1743393117802338387 (ilk oyun, ilgisiz) | arandı-bulunamadı |
| Startup Company | Bulunamadı (aramalar genel teknik borç yazılarına düştü) | Bulunamadı | Bulunamadı | Bulunamadı | Bulunamadı | Bulunamadı | https://steamcommunity.com/app/606800/discussions/1 (yalnız oyunun kendi hata başlıkları) | arandı-bulunamadı |
| Big Ambitions | Oyunda yazılım hatası modeli bulunamadı (perakende/iş simülasyonu; sonuçlar oyunun kendi bug'ları) | Yok | Yok | Yok | Yok | Yok | https://forum.bigambitionsgame.com/t/a-frustrating-bug-that-prevents-me-from-progressing-in-the-story/6337 | arandı-bulunamadı (büyük olasılıkla modeli yok; bu kesin değil) |
| Startup Panic, Tech Corp, Kairosoft'un öbürleri, Software Inc. modları | Aranmadı (bütçe: konuyla ilgili ilk sonuçlar ince geldi) | - | - | - | - | - | yok | kaynaksız |
| Genel örüntü (model bilgisi, kaynaksız) | Tycoon türünde hata çoğunlukla "kod/efor miktarı × ekip becerisi" ile doğar, bir tür kalite puanına bağlanır | - | - | - | - | - | yok | kaynaksız |

**Kaynaklardan çıkan dört ders** (yalnız bulunan satırlara dayanır, zayıf kanıt):
1. Hiçbir bulunan oyunda hata "her hat için ayrı kart" değildir; düzeltme ya otomatik bir aşamadır (GDS, GDT) ya ayrı bir
   destek kadrosudur (Software Inc.). Oyuncunun sprint kapasitesinden pay alan hat bazlı düzeltme bu türde yok; bu yüzden
   Karar 4 için doğrudan örnek alacak bir model bulunmadı, mekanizma bu oyunun kuralından türetilmiştir.
2. Artık hata normaldir: "hepsini yakalamak maliyet etkin değil", "yayından sonra destek artığı taşır" (Software Inc.).
   Bu, bir hat başına tolerans (birikim eşiği) fikrini destekler.
3. Bedel kişi/hat bazlı değil, toplu sonuçtur (puan, itibar, destek yükü). Hata başına doğrusal churn bulunan hiçbir oyunda
   yok; bu oyundaki churn bedeli özgündür ve eşik/üst sınırla yumuşatılmalıdır.
4. Keşif eğrisi öne yüklüdür: ilk aylar hızlı, sonra yavaş (Software Inc.). Bizdeki `e^(-yaş/3)` yeni kod terimi aynı biçimdedir.

## Bu oyunun bugünkü sayıları ve formül (doğrulandı)
- `support_system.gd:164-184`: günlük akış = (0,2 + 0,05 × açık hata + 0,03 × yeni_kod × e^(−yaş/3)) × kullanım çarpanı × altyapı.
  Hafta başına ×7. B2B çarpanı `1 + hesap/10` (170 hesapta ×18). Tek başına **taban** terimi 170 hesapta haftada ≈25 hata verir
  (A_PLAN §4.3). "0,05 × açık hata" terimi Karar 2'ye (yalnız kullanım ve yeni kod) aykırı bir geri besleme döngüsüdür; öneri: silinir.
- Bugünkü ölçüm (A_PLAN §4.3, bot 60 hafta): B2B yeni model açık hata ort. 25, hiç düzeltmeyen 138-168; B2C 18, hiç düzeltmeyen 58-64.

## Yöntem (bölüm 1-4'ün sayıları)
Hat sayısı L, her yeni hata bağımsız ve eşit olasılıkla bir hatta düşer (Karar 3). Sprint başında oyuncu planlar (hat sayısı
anındaki sayıya göre efor kilitlenir), sprint içinde Poisson(W × s) yeni hata gelir, sprint sonunda planlanan hatlar O ANKİ
sayıdan sıfırlanır (Karar 5). Politika: `none`, `worst` (tek kart, en çok hatalı hat), `due` (bedeli başlamış hepsi). 2000
sprint, medyanlar sondaki %75'ten. Kapasite: tek kurucu 2 puan/hafta; 6 kişilik ekip **varsayım olarak 10 puan/hafta**
(`person_points_week` 2 × beceri/saat çarpanları × Karar 13 payları; A1 gerçek rakamı doğrulamalı). W = haftada yeni hata
(toplam), A = W × s = sprint başına yeni hata.

**PRD formülü hakkında not:** "açık ≈ hat sayısı × haftalık akış × sprint haftası / 2" ifadesindeki akış **hat başına** olmalıdır;
toplam W ile çarpılırsa L (≈9) kat şişer. Doğru okuma: her şeyi temizleyen kusursuz oyuncuda açık ≈ W × s / 2 (ortalama),
sprint sonu tepesi ≈ W × s. Bir kart/sprint alan oyuncuda gözlem: açık ≈ 3-3,5 × A (L=9, yani ≈ L/3 × A).

## 1. Hedef değerler (Karar 11'in iki ölçüsü)

**Gerekçe:** Erdem hem haftada ≈11 yeni hatayı hem 12 açık hatayı çok buldu. Kusursuz oyuncu için bile sprint sonu tepesi ≈ W×s
olduğundan, açık hata hedefi akış hedefinden türer. Aşağıdaki W tek başına bölüm 2'deki sabitlerle tutturulur.

| Ölçü | B2B erken (v1.0 sonrası ilk 20 hf) | B2B geç | B2C erken | B2C geç |
|---|---|---|---|---|
| (a) Haftada yeni hata, medyan | ≤1,5 (aralık 1-2) | ≤4 (aralık 3-4) | ≤2 | ≤5 |
| (b1) Açık hata, **sürüm anı** (kapanıştan sonra, sürüm notundaki "→" sağ değer), `fix_due` medyanı | ≤4 | ≤8 | ≤4 | ≤8 |
| (b2) Açık hata, **sprint sonu tepesi** (kapanıştan önce), `fix_due` medyanı | ≤8 | ≤16 | ≤8 | ≤16 |
| (b3) `fix_worst` açık hata (bilgi, hedef değil) | ≈9 (2 hf, A=3) | ≈21-28 (2 hf), ≈9-13 (1 hf) | aynı | aynı |
| (b4) `fix_none`, v1.0'dan 20 hafta sonra | ≈20 × W ≥ 25 | ≈80 | ≥ 40 | ≈100 |

- Tablo (b1)-(b2) sayıları bölüm 3 simülasyonuyla uyumludur (aşağıda). Erdem'in "12 çok" tepkisi sürüm anı için karşılanır:
  geç dönemde sürüm anı 7-8.
- Ortak yönetmenin ilk önerisi ("her sprintte en kötü hattı düzelten oyuncuda medyan <5") **yalnız erken dönemde** tutar
  (L=3-5, A≤3). Geç dönemde `fix_worst` (bir kart/sprint, 9 hat) fiziksel olarak 3-3,5×A açık bırakır; hedef olarak
  korunamaz. Öneri: `fix_worst` için açık hata hedefi yok, onun hedefi churn (PRD 4.4: `fix_off`'tan en çok %10 fazla) ve düzeltme payıdır.
- "Belirgin yığılma" (`fix_none`): 20 hafta sonrası açık hata `fix_due`'nunkinin en az 5 katı.

## 2. Akış sabitleri (öneri, hepsi "onay bekliyor")

Bugünkü haftalık biçim korunur: `W = (taban + yeni_kod × e^(−yaş/3)) × kullanım_çarpanı × altyapı`.

| Sabit | Bugün | Öneri | Gerekçe |
|---|---|---|---|
| `INFLOW_CARRIED_COEF` (0,05 × açık hata) | 0,05 | **sil** | Karar 2: kaynak yalnız kullanım ve yeni kod. Açık hataya bağlı terim, ihmal eden oyuncuda akışı patlatır (138-168 açık) ve "hata hata doğurur" okunur; ihmalin bedeli churn'dür |
| `INFLOW_BASE` (gün) | 0,2 (haftada 1,4) | **0,10** (haftada 0,7) | Geç B2B hedefi W≤4 için taban × çarpan ≈ 4 olmalı |
| `INFLOW_BASE_RESEARCHED` | 0,14 | **0,07** | Oran korunur (×0,7) |
| `INFLOW_NEWCODE_COEF` | 0,03 | 0,03 (dokunma) | Ölçek `new_code_effort`'a bağlı; ortalama katkıyı ölçmedim. K5 ilk koşuda haftalık ortalamayı basar; beklenen 0,3-0,8/hf. Sapma olursa bunu oynatın, tabanı değil |
| `INFLOW_TAU` | 3 hf | 3 | Software Inc. keşif eğrisiyle aynı biçim |
| `USAGE_DIV_B2B` | 10 | **60** (A_PLAN'ın 25'i yetmez) | W = (0,7 + ≈0,4) × (1 + n/D). n=170, D=25 ⇒ ≈8,6 (hâlâ 2 kat fazla). D=60 ⇒ ×3,8 ⇒ W≈4,2. n=5 ⇒ ×1,08 ⇒ W≈1,2 (erken hedef 1-2). Alternatif: doğrusal yerine `1 + sqrt(n)/c` (aynı hata çok hesapta tekrar bildirilir ⇒ alt-doğrusal artış doğru): c=4 ile n=170 ⇒ ×4,3, n=5 ⇒ ×1,56. Doğrusal D=60 daha yalın ⇒ öneri bu |
| `USAGE_DIV_B2C` | 2000 | **değişmez (E'nin)**, yalnız not: W≤5 için 20k kitlede çarpan ≈5-6 gerekir ⇒ bölen ≈4000-5000. E karar verir | Görev: yalnız yorum |
| Altyapı çarpanı | ×1,25 / ×1,5 | dokunma | Bu çarpanlar W hedefinin üstüne biner: ucuz sağlayıcı + doluluk %100 üstü W≈4 ⇒ ≈7,5. Bilinçli ödünleşimdir; K5 raporuna yaz |

**Doğrulama borcu:** `new_code_effort` ve altyapı çarpanı ölçülmeden W hedefi %±50 oynayabilir; K5 ilk 104 haftalık koşuda (a) tablosunu
çıkarır, hedef tutmazsa sabit sessizce değişmez, "onay bekliyor" altında rapor edilir.

## 3. Karar 4 mekanizma önerisi

### 3.1 Seçim (bileşim)
Dört parça birlikte; her biri sınırlara uyar (kart yalnız kendi hattını temizler, hata rastgele düşer, düzeltmeyen belirgin öder):

1. **Hat başına birikim eşiği T=1.** Bir hattın bedeli, o hattaki ilk hatadan sonra başlar: hattın "bedelli hata" sayısı
   `excess = max(0, n_hat − 1)`. Tek hata hiçbir şeyi etkilemez. Churn/memnuniyet/itibar yalnız Σ excess okur. Neden: rastgele
   dağılımda çoğu hatta 1 hata görünür (Karar 4 "her hat için kart açmaya zorlama"); eşik bunu bedelsiz yapar, ama gösterilen "açık hata"
   sayısı tüm hataları sayar (dürüst).
2. **Azaltılmış doğrusal ceza.** A_PLAN'ın `min(0,5×b, 20)` formülü `excess` üstünde `min(0,4 × excess_kullanılan_hatlar, 20)` olur
   (B2B, hesabın kullandığı hatlar). Üst sınır korunur. Katsayı 0,5→0,4 ve girdi `b` yerine `excess` olduğundan etkin ceza ≈%50-60
   düşer. Hiç düzeltmeyen: 20 hf sonra excess ≈ 60-80 ⇒ üst sınır 20 ⇒ belirgin. Düzeltme yapan (`fix_worst`, geç, 2 hf): excess medyanı 8-14
   ⇒ ≈2-3 puan (hesap başına kullandığı hatlar payıyla daha az). **Churn büyüklüğünü ben simüle edemedim**; K5 doğrular (kabul:
   `fix_worst` kaybı `fix_off`'tan ≤%10 fazla, `fix_none` ≥2 kat).
3. **Efor kademeleri kayar:** 1-3 hata 1 puan, 4-6 hata 2 puan, 7+ 3 puan (PRD'nin 1-2/3-5/6+'ı yerine; `sprint.json`'da tek ayar,
   E1 kararı). Neden: tek kurucu 1 haftalık sprintte 2 puandır; bugünkü kademede 3-5 hatalık hat 2 puan = %100 hata sprinti.
   Kayık kademeyle erken dönemde kart çoğunlukla 1 puandır (2 hf sprintte %25, 1 hf'ta %50, ikisi de "hata sprinti" değil).
4. **Acil eşiği 3 → 6, zorunlu alım yalnız Acil'e.** Acil = hatlarında ≥6 hata (kayık kademede 2 puanın tepesi). Bot zorunlu listesi
   (`sprint_catalog.gd` `must`) bugünkü gibi acilleri alır, ama T=1 ile fix_due politikasında hat nadiren 6'ya varır
   ⇒ acil kart seyrek. "En zayıf alanın en iyi kartı" kuralı (düzeltme kartı olabilir) düzeltme payını gizlice şişirmesin diye
   `fix_worst`/`fix_due` kollarında zaten düzeltme kartlarını bot ayarlar (PRD 4.4 kurulum önerisi). Acil etiketi B'nin "acil durum" olayından
   ayrı adlandırılır (PRD notu).
5. **Haftalık akış** bölüm 2'deki gibi: asıl kaldıraç budur; eşik ve ceza yalnız artığı yumuşatır.

Reddedilenler: *tam zorunlu kart kaldırma* (hiç düzeltmeyen bedelini kaybettirmez ama bot `fix_worst` tanımı bulanır; acil seyrek
zaten); *toplu yama kartı* (Karar 5 sınırına aykırı); *otomatik düzeltme* (bedelsiz çıkış, Karar 4 "düzeltmeyen öder" ile çelişir).

### 3.2 Yapılabilirlik hesabı (simülasyon, T=1, kayık kademe, L=9)
Hat sayısı 9 (geç). Erken dönem L=3-5 aşağıda ayrı. Kapasite: kurucu 2 puan/hf; ekip **varsayım** 10 puan/hf. "Pay" = Σ efor / kapasite.
`due` = excess>0 olan (n≥2) bütün hatlar; `worst` = tek kart (n≥2 ise).

| Durum | W | s | Kapasite | Politika | Pay medyan / ort | Hata sprinti oranı | Üst üste iki | Açık: sprint sonu tepe / sürüm anı |
|---|---|---|---|---|---|---|---|---|
| Kurucu, L=9 | 1 | 1 hf | 2 | due | 0 / 0,22 | %8 | %0,3 | 6 / 5 |
| Kurucu, L=9 | 1 | 2 hf | 4 | due | 25% / 0,21 | %4 | %0,1 | 8 / 6 |
| Kurucu, L=9 | 1,5 | 2 hf | 4 | due | 25% / 0,30 | %11 | %0,4 | 9 / 6 |
| Kurucu, L=9 | 1 | 2 hf | 4 | worst | 25% / 0,20 | %0 | %0 | 9 / 7 |
| Ekip 6, L=9 | 3 | 1 hf | 10 | due | 10% / 0,12 | %0 | %0 | 9 / 6 |
| Ekip 6, L=9 | 4 | 1 hf | 10 | due | 10% / 0,16 | %0 | %0 | 11 / 6 |
| Ekip 6, L=9 | 3 | 2 hf | 20 | due | 10% / 0,11 | %0 | %0 | 14 / 7 |
| Ekip 6, L=9 | 4 | 2 hf | 20 | due | 10% / 0,13 | %0 | %0 | 16 / 8 |
| Ekip 6, L=9 | 3 | 2 hf | 20 | worst | 10% / 0,11 | %0 | %0 | 27 / 21 |
| Ekip 6, L=9 | 4 | 1 hf | 10 | worst | 20% / 0,15 | %0 | %0 | 17 / 13 |
| Kurucu, L=3 | 1 | 2 hf | 4 | due | 25% / 0,18 | %2 | %0 | 4 / 2 |
| Kurucu, L=5 | 1,5 | 2 hf | 4 | due | 25% / 0,27 | %9 | %0,1 | 7 / 4 |
| 3 kişi, L=5 | 2 | 2 hf | 12 | due | 8% / 0,11 | %0 | %0 | 8 / 4 |

Bugünkü kademe (1-2/3-5/6+) ve T=0 (eşiksiz) karşılaştırması aynı koşturmada: kurucu, 2 hf, W=2, `due` T=0 ⇒ pay ort. 0,60, hata sprinti %44,
üst üste iki %15 (hedef tutmaz). Kurucu 1 hf, W=2, `worst` T=2 ⇒ hata sprinti %61. Yani **eşik + kayık kademe olmadan hedefler tutmaz**;
akış tek başına yetmez.

**Kaba el hesabı (doğrulama):** A=6 yeni hata, L=9 ⇒ dolu hat sayısı ≈ 9(1−(8/9)^6)=4,6; beklenen efor (eski kademe) ≈4,65 puan. Ekip
kapasitesi 20 ⇒ %23; kurucu 2 hf (4 puan) ⇒ %116, yani **kurucuya geç dönem akışı (A=6) taşıtılamaz**: kurucu yalnız erken dönemde
(W≈1) kalır. Kayık kademede ekip A=6 için ≈3 puan (%15).

**Sonuçlar:**
- Kurucu için W≤1-1,5 ve 2 haftalık sprint şart; 1 haftalık sprintte kurucunun bir kartı zaten %50 olduğundan, tek bir 2 puanlık
  kart 1 hf'ta kaçınılmaz hata sprinti olur (%8 gözleniyor).
- Ekip için T=1 + kayık kademe yeterli; W=4'e kadar pay ≤%16, hata sprinti ≈%0.
- `fix_worst` ekip için açık hata bırakır (bölüm 1 b3) ama payı küçüktür; bu da onun bedelini churn'e taşır, kontrol K5'te.

### 3.3 Sınırlar ve açık riskler
- Simülasyon dışı: yayın sonrası ilk haftaların yeni kod patlaması (e^(−yaş/3)); hatalı kapanan kartın hatası (kartın hattına, Karar 3);
  sprint ortası düşen hatalar kapanışta "o anki sayıyı" siler (modelde var); hat sayısı büyüdükçe L değişimi (L=3→9).
- Rastgelelikte kuyruk: hata sprintleri düzenli oyuncuda da görünebilir (%4-11 kurucu); "üst üste iki yok" matematiksel garanti değil.
  Garanti istenirse `fix_due` botu sprint başına kapasitenin %50'sini aşmayan kartları alır (en çok hatalı hat önce); bu
  ölçümü sahte iyileştirir, o yüzden önerilmez, rapora "ölçülen oran" yazılır.

## 4. PRD 4.4 düzeltme payı hedeflerinin gözden geçirilmesi

**Düzeltme payı tanımı** PRD'deki gibi (sprint başında düzeltme kartlarının `remaining` / `capacity()`).

**"Düzeltilmesi gereken hat" (fix_due kolu):** bedeli başlamış hat, yani **n_hat ≥ 2 (excess>0)**; o sprint başında plan ekranındaki sayı kullanılır
(sprint içi yeni hata sayılmaz). Tek hatalı hat borçlu değildir. Acil (n≥6) olan hat her halükârda borçludur. B2B'de ek koşul
yok (hattı kullanan hesabı olmayan hattın bedeli zaten 0 olduğundan kart alınması gerekmez: bu yüzden **"hattı en az bir aktif/deneme hesabı kullanıyor"
koşulu eklenir**; B2C'de her hat borçlu sayılır).

| Hedef | PRD önerisi | Ölçüm (3.2) | Öneri |
|---|---|---|---|
| Geç, `fix_worst` medyan | ≤%15 | ekip %10-20 (1 hf W=4'te %20) | **≤%15 kalsın**, 1 hf sprintte W=4 sınırda; geçmezse W veya efor kademesi kontrol edilir |
| Geç, `fix_due` medyan | ≤%25 | %10-16 | **≤%20'ye sıkılaştır**; ölçüm payı bol, %25 gevşek |
| Geç, `fix_due` hata sprinti oranı | ≤%10 | %0-1 | **≤%5**; ekipte neredeyse sıfır beklenir |
| Geç, üst üste iki hata sprinti | yok | 0 | **0** (ölçüm şart; ihlal ⇒ rapor) |
| Erken (ilk 20 hf), `fix_worst` medyan | (yok) | %25 (kurucu 2 hf), 0 (1 hf) | **≤%30** |
| Erken, `fix_due` medyan | (yok) | %25 | **≤%30**, ortalama ≤%35 |
| Erken, `fix_due` hata sprinti oranı | (yok) | %2-11 | **≤%15** |
| Erken, üst üste iki | (yok) | %0-0,4 | **≤%1 sprint** (kurucu 1 puanlık kartta %50 sınırında; kesin sıfır garantisi yok) |
| Churn | `fix_worst` ≤ `fix_off`×1,10; `fix_none` ≥ 2× | simüle edilmedi | Aynı kalsın; **K5 ölçer**, tutmazsa bölüm 3.1 madde 2 katsayısı "onay bekliyor" altında rapor |

Notlar: (1) Erken dönem hedefi kurucunun kapasitesi 2 puan olduğundan %25 tabanını içerir; %50 altı "hata sprinti değil" tanımı sınırı
tam %50'yi dışarıda bırakır. (2) Tüm payları ekip kapasitesi 10 puan/hf varsayımıyla; A1/K5 gerçek kapasiteyle yeniden koşturur.
(3) Efor kademesi `sprint.json` tek ayarı olduğundan E1'de değişirse bu tablo yeniden koşturulur (betik hazır).

## Erdem için 10 satırlık özet
1. Araştırma: 13 arama; Game Dev Story, Software Inc. ve Game Dev Tycoon için kısmi, forum/wiki seviyesinde kaynak bulundu; Mad Games Tycoon 2, Startup Company, Big Ambitions için bulunamadı.
2. Bulunan oyunların hiçbiri hata düzeltmeyi hat bazlı sprint kartı yapmıyor: ya otomatik aşama (Game Dev Story) ya ayrı destek ekibi (Software Inc.); "bütün hatayı yakalamak gerekmez" ortak fikir.
3. Haftada yeni hata hedefi: B2B erken ≤1,5, geç ≤4; B2C erken ≤2, geç ≤5 (bugün geç B2B ≈25).
4. Açık hata hedefi (düzeltmeyi bilen oyuncu): sürüm anında erken ≤4, geç ≤8; sprint sonu tepesi erken ≤8, geç ≤16. Bir kart/sprint alan oyuncu geç dönemde 13-28 açık bırakır; bu normal, hedefi churn.
5. Akış sabitleri: açık hataya bağlı terim silinir; taban yarıya (0,2→0,10); B2B bölen 10→60 (A_PLAN'ın 25'i yetmez, geç W≈8,6 kalır); B2C bölen E'nin (not: ≈4000-5000 gerekir).
6. Mekanizma (dört parça): hat başına 1 hata bedelsiz eşik, azaltılmış ceza (0,5→0,4 × yalnız eşik üstü, üst sınır 20), efor kademesi 1-3 / 4-6 / 7+ (1/2/3 puan), acil eşiği 3→6.
7. Yapılabilirlik: bu dördü olmadan kurucuda hata sprinti oranı %44-61'e çıkıyor; dörtlüyle kurucuda %4-11, ekipte %0-1.
8. Kurucu geç dönem akışını (W≈4) taşıyamaz; geç dönem ekip kapasitesine dayanır. Bu zaten Karar 13 ve D ile uyumlu bir sonuç.
9. Düzeltme payı hedefleri: geç `fix_worst` ≤%15 (aynı), `fix_due` ≤%20 (25'ten), hata sprinti ≤%5 (10'dan); erken `fix_worst` ≤%30, `fix_due` ≤%30, hata sprinti ≤%15. "Düzeltilmesi gereken hat" = n≥2 olan, kullanılan hat.
10. Sınırlar: churn büyüklüğü simüle edilmedi (K5 ölçer); ekip kapasitesi 10 puan/hf varsayım; `new_code_effort` ve altyapı çarpanı ölçülmedi, W hedefi bu yüzden ±%50 oynayabilir; tüm sabitler "onay bekliyor".
