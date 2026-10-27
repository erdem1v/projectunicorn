# Faz D · Görev · Ekip modeli ve sprint düzeni
2026-10-18 (Erdem'in 18 Ekim akşam cevabıyla güncellendi) · Sahip: Erdem · Bu belge **ne beklediğimizi** söyler: çıktı ne
olmalı, oyuncu ne görmeli, nasıl görmeli, neyle kabul edilir. Nasıl yapılacağına uygulayıcı ajan karar verir. Kod
gerçekleri `main` @ `889b9b8` (A ve B bitti).

## Bu belgeyi alan ajana
- Faz D'nin uygulama sorumlusu sensin. İşi alt ajanlarla yürütürsün; modeller §8'dedir.
- **İlk iş:** bu belgeyi ve §0'ın eklerini oku; Erdem'e adım tablonu ver (Adım | Ne | Kim | Model | Düşünme | Süre |
  Neden), onayını bekle. §8'deki tablo başlangıç noktasıdır; değiştirirsen gerekçesini yaz.
- **Erdem'e döndüğün üç yer:** (1) adım tablosunun onayı; (2) E1 durağı: yazım dalgası (W), plan ekranının oyunun kendi
  arayüzüyle kurulmuş maketi (M), D0s simülasyonu, derinlik kartının g₀ önerisi ve §10'un iki kalan sorusu; (2b) yalnız
  D0'ın plan süresi bir kareyi aşarsa; (3) son rapor (R). Bunların dışında sormadan ilerlersin.
- **İşaretler:** "(Erdem)" Erdem'in birebir onayladığı ya da istediği şeydir. 17 Ekim kararları `ERDEM_CDQ_CEVAP.md`
  numaralarıyla "Erdem D1", 18 Ekim kararları `ERDEM_QCD_CEVAP.md` §2.3 numaralarıyla "QCD D4" ya da "QCD Atama" diye
  anılır. "[onay bekliyor]" önerilmiş ama onaylanmamış sabit ya da kuraldır; kodda, commit mesajında ve raporda böyle
  işaretlenir (CLAUDE.md §3). Metinler "TR/EN onay bekliyor" diye işaretlenir.
- **Faz sırası Q → C → D.** Q ve C aynı ağaçta senden önce kod yazar; başlama koşulun §8'in başındadır. Playtest Q, C ve
  D bitince yapılır (Erdem); D oyunu bozmadan, kendi kapılarıyla kapanır.

## 0. Ekler ve öncelik
Ekler `docs/tasks/faz_cde/` klasöründedir.

| Ek | Ne işe yarar |
|---|---|
| `ERDEM_QCD_CEVAP.md` | Erdem'in 18 Ekim cevabı (§1 birebir) ve onayladığı okuma (§2.3). Bu turun tek yeni karar kaynağı |
| `ACIK_ISLER.md` | Bu turda yapılmayacak işler; D bunlardan iş almaz |
| `D_MODEL_v3.md` | Model, formüller, §6 simülasyon tanımı, §6.12 kapıları. Sondaki "İnceleme notu (Opus)" gövdeden önce gelir |
| `D_SIM_v3.md` | 8.220 koşuluk ölçüm; §11 inceleme sonrası birleşik ölçüm; betik ve yeniden üretim §10 |
| `SPRINT_DUZENI.md` | Bugünkü sprint düzeninin karnesi ve K1 ile K11; sondaki inceleme notu dahil |
| `D_MODEL_v2.md` | v3'ün "değişmeyen" dediği kısımlar: plan ekranı yönleri (§3.9), aşama ve pay tavanları (§3.11) |
| `OYNANIS_HUKMU.md` | Mekanik başına hüküm (§2.1, bu belgede "#n"), risk kapıları (§3). Erdem'in cevabı hükmü aştığı yerde Erdem geçerli |
| `ERDEM_CDQ_CEVAP.md`, `ERDEM_CD_YORUM.md`, `QCD_GOREV_PAKETI.md` | Erdem'in 17 Ekim sözleri (birebir); bu turun ortak kuralları |
| `arastirma/R1` ile `R5`, `R10`, `R12`; `R13` ile `R15` | Model kaynakları (Software Inc., Startup Company, GDT, MGT2, gerçek pratik, test, sprint); övülen ve kızılan oyunlar, bugünkü döngü |
| `../faz_ab/RAPOR_A.md`, `../faz_ab/RAPOR_B.md` | A ve B'nin gerçek adları ve ölçümleri. RAPOR_B §1 madde 1, 3 ve 4 D'nin kabulüne girer |

**Öncelik:** `ERDEM_QCD_CEVAP.md` §1 > aynı belgenin §2 > Erdem'in 17 Ekim sözleri > bu belge > `D_MODEL_v3` inceleme notu >
`D_MODEL_v3` gövdesi ve `D_SIM_v3` §11 > `SPRINT_DUZENI` > `D_MODEL_v2`. Proje kuralları `CLAUDE.md`'de, kod haritası
`docs/HARITA.md`'dedir. Satır numaraları `889b9b8`'e göredir; v3 belgelerindekiler eskimiş olabilir (D0 haritası doğrular).

**v3 belgelerinde geçersiz olanlar** (kodlanmaz)
1. Taslak sayılar: kurucunun işi "en çok %7" düşer (doğrusu %10,1, kapı %12); düzeltme kartı "en az 5 puan" (alt sınır
   yok); derinlik kartı "÷ 10, en çok 4" (÷ 5, en çok 8); takım kaybı bütün takıma. Hepsi inceleme notunda.
2. Kayıt şemasının "17" ya da "18" diye yazılması. Doğru sıra §8'dedir.
3. `D_MODEL_v2.md:772`: "50 kişi kataloğu 60 haftada tüketir". Doğrusu 7 hafta.
4. `SPRINT_DUZENI` §5.2 taslağı: "düzeltme payı ≤ %12, hata sprinti 0". Yerine A'nın hedefleri gelir (§4.1).
5. `D_MODEL_v3` §3.7: "`decision.rate` 0,35". Bugünkü anahtar `decision.sprint_chance` (`sprint.json:41`): 2 haftalıkta
   0,5; 1 haftalık anahtarı (0,3) D'de silinir.
6. `D_MODEL_v3` §5 C: "`b2b_sales_system.gd:147`". Bugünkü hata terimi `b2b_sales_system.gd:155-156`'dadır; C kaldırır.
7. 1 haftalık sprint ve `D_SIM_v3`'ün "1 hf" satırları (QCD D4; "2 hf"te de sprint erken kapanabiliyordu, D0s yeniden
   ölçer). "Fayda en iyi PM'den" (§3.8, hüküm #14) ve "sprint sırasıyla ilk karta" (§3.4): yerine Karar 4. EA takımı (§7).

## 1. Amaç
Erdem'in sözleri (`ERDEM_CD_YORUM.md`, `ERDEM_CDQ_CEVAP.md`, `ERDEM_QCD_CEVAP.md` §1):
- "Sabitlerle il, dinamik olması lazım ..." "Oyuncu şunu bilmeli ... testleri yetişmez çünkü yeterli testçimiz yok."
- "En baba işe en iyi adamlarını verirsin ... ve bunu bizim otomatik sağlıklı hatasız bir şekilde yapıyor yapabiliyor
  olmamız lazım." "İyi PM'in modifier'ı kötü PM'den farklı iyi oyuncu görebilmeli."
- "Sprintleri tamamen iki hafta şeklinde kurgulayabiliriz." "Planlamayı devret bence PM olmadan da açılamamalı."
- Paket: "core gameplay core döngü eğlenceli ve akıcı olmak zorunda."

Bu fazdan sonra oyuncu:
- kişinin rolünü, yıldızını, aşama başına haftalık puanını; her kartta işi kimin yaptığını ve yıldızından gelen etkiyi görür,
- planda neyin yetişmeyeceğini ve nedenini tek bakışta okur; testin bulduğunu ve aynı sprintte düzeltildiğini görür;
  planın tahmini sonuçla aynı çıkar,
- her sprinti 2 hafta ve dolu geçirir; kartlar erken biterse ekip sıradakini çeker. Bugün plan anında kapasitenin medyan
  %13 ile %15'i doludur (R15 §4.5), sprintlerin çoğu 1 tikte kapanır (RAPOR_B §1 madde 4),
- 50 kişide kart seçmez; çeyrek hedefi ve kadro seçer, planı 2 ya da 3 eylemle bitirir ya da PM'e devreder; bir sprintte
  saati birden çok kez durduran kesinti yaşamaz.

## 2. Kararlar (bağlayıcı)
Her kararın altında **Oynanışa etkisi**: karar, sıklık, okunuş, risk, 1 ve 50 kişide his, `OYNANIS_HUKMU.md`'nin hükmü.

### Model
1. **Birim ve kişinin hızı.**
   - Puan ölçeği ×5 olur: 2,5★ bir kişi ana alanında haftada 10 puan üretir (Erdem: "kişinin haftalık puanı ölçek falan
     okey"). Kart K1 15, K2 25, K3 40; araştırma 5; ücretli plan 15.
   - Haftalık aşama hızı = 10 × Y(s) × U × verim × saat × pay × huy; Y(s) = 0,5 + 0,05·s + 0,01·s², s alanın 0 ile 10
     puanı [onay bekliyor]. Ana alanda 1★ 6, 2★ 9, 3★ 12, 4★ 15, 5★ 20 puan/hafta. Pay A Karar 13'ün kuralıdır
     (`sprint_system.gd:1749-1751`). Huy: TİTİZ hız ×0,85, GÖZÜ YÜKSEKTE ×1,15 [onay bekliyor].
   - Puanla ölçülen her bedel aynı ölçeğe taşınır: kâğıt sabitleri (`sprint.json:42-49`), `effort` ve `paid_plan.effort`
     (`:6`, `:78`), karar fiillerinin miktarları.

   **Oynanışa etkisi.** Karar: kimi işe almalı (rol, yıldız, maaş). Sıklık: koşuda yaklaşık 21 alım (R15 §4.2). Okunuş:
   "Mert · Geliştirme 12/hf". Risk yok; yarım yıldız tam sayıyla okunur. 1 kişi: kurucunun hızı. 50 kişi: aşama toplamı.
   Hüküm: Tut (#12).

2. **Rol uyumu ve uymayan iş.**
   - Ana alan 1,0; ikincil alan 0,7 (Erdem: "0.7 çarpı eğer yıldızı varsa yıldızı kadar"); uymayan 0,4, Y × U en az 0,3
     (Erdem: "0.4 ... ya da işte atıyorum 0.3"). Tasarımcı kod yapmaz (Erdem).

     | Rol | Yapım kutusu | Test kutusu |
     |---|---|---|
     | Kurucu | Tasarım, Geliştirme, Düzeltme ×1,0 | Test ×1,0 |
     | Ürün yöneticisi | Sprint puanı yok: hazırlık ve araştırma kartı | Test ×0,4 |
     | Tasarımcı | Tasarım ×1,0; araştırma ×0,7 | Test ×0,4 |
     | Geliştirici | Geliştirme ve Düzeltme ×1,0 | Test ×0,7 |
     | Testçi | Geliştirme ve Düzeltme ×0,7 | Test ×1,0 |

   - Uymayan işte çalışılan her hafta sprint kapanışında −2 moral (Erdem: "eksi 2 moral alması okey").
   - **Atama koşulu** (hüküm §2.2 notu; Karar 4 korur): sistem uymayan işi yalnız kişi aksi hâlde boşta kalacaksa verir;
     plan ekranı bunu kişinin adıyla yazar.
   - Uyum hızı keser, kaliteyi kesmez (Erdem: "hata ihtimalinde gerçek test yıldızı okunur. Tamam").

   **Oynanışa etkisi.** Karar: Görevler matrisinde kime Test kutusu verilir. Sıklık: işe alım ve iş değişikliği. Okunuş:
   kartta "TEST ×0,4". Risk: otomatik atamadan gelen moral kaybı haksız gelir (R14 §5, Startup Panic); koşul bunu kapatır.
   1 kişi: kurucu her aşamada uyumludur, kural görünmez. 50 kişi: rol karışımı bir karardır. Hüküm: Tut, koşulla (#12).

3. **Kartın ihtiyacı, kadro ve aşama sırası.**
   - Kart üç aşama puanı ister; oran hattın veride duran iş profilinden gelir (tasarım, geliştirme ya da test ağırlıklı).
     Örnek K2 25: 9/11/5, 4/16/5, 3/13/9 (`D_MODEL_v3` §3.2). Oyuncu "Tasarım 9 · Geliştirme 11 · Test 5" görür.
   - Kadro = ⌈aşama ihtiyacı ÷ 8⌉, en az 1 (`D_MODEL_v2` D1, Erdem: "D1'e gelince okey"). Erdem'in "her 8 puanlık işe en
     çok bir kişi"si eski ölçekteydi (K3 = 8 puan); ×5 ölçekte 8 kalırsa büyük kartın aşamasına 2 ya da 3 kişi girer ve
     Karar 4 en iyileri oraya toplar. D0s 8 ile 40'ı (eski kuralın ×5 karşılığı) ölçer; karar E1'dedir (§10 Kalan soru 1).
     O zamana kadar `D_SIM_v3`'ün ölçtüğü 8 geçerlidir.
   - Aşamalar sırayla açılır; biri bittiği an sonraki açılır. Aşamaya kimin gireceğini aday sınıfı belirler: ana alanı o
     aşama olan, kurucu, ikincil alanlı, uymayan (Karar 2'nin koşuluyla). Kimin hangi karta gideceğini Karar 4 belirler.
   - Şirket çapında verim kaybı yoktur; kayıp yalnız aynı kartta yaşar (`D_MODEL_v2` D1; Erdem: "ekip büyüdükçe bir verim
     kaybı ... ekip bazında bir lider", yani kayıp takımda ve kartta, şirket çapında değil).
   - Boş süre önce sıradaki karta gider (Karar 11), sonra önden işe (PM hazırlığa, tasarımcı sonraki sütunun tasarımına);
     kalanı nedeniyle "boşta" görünür.

   **Oynanışa etkisi.** Karar: hangi rolü işe almalı. Sıklık: her alım. Okunuş: kart ipucu "Geliştirme en çok 2 kişi".
   Risk: Erdem'in sorusu ("5 tane testçim var ... küçük bir iş") cevapsız kalırsa işe alım şans gibi görünür; boşta nedeni
   cevaplar. 1 kişi: görünmez. 50 kişi: tek karta 12 kişi hızlandırmaz (`D_MODEL_v3` §4.3 S12); ekran bunu boştaki kişi
   sayısıyla söyler. Hüküm: Tut (#12, #16).

4. **Yeteneğe göre otomatik atama** (QCD Atama; paket sorusu 7'nin cevabı).
   - Sistem atar, oyuncu sonucu görür. Erdem: "Daha komplike ürüne otomatik olarak o esayen edilir ... daha büyük bir işe
     daha büyük bir PM bakar ... ve bu kartların bonusları buna göre okunur."
   - **İşin büyüklüğü.** Kartta ayrı bir zorluk alanı yoktur ve D eklemez. Bir aşamada işin büyüklüğü kartın o aşamadaki
     ihtiyacıdır (Karar 3); Erdem'in "tasarım seviyesi yüksek kart"ı Tasarım ihtiyacı büyük karttır. Düzeltme alt
     aşamasında büyüklük düzeltme işidir. Eşitlikte kartın toplam puanı, sonra planın sırası, sonra kartın kimliği.
   - **Eşleme.** Aşamaya giren kişiler o aşamadaki haftalık hızlarıyla sıralanır (yıldız, uyum, verim, pay, huy; Karar 1),
     eşitlikte kimlik. Her atama anında (hafta başı, aşama açılışı, kişinin kartı bitince, kâğıt cevaplanınca) aşamanın açık
     kartları büyükten küçüğe dizilir: en hızlı kişi en büyük karta, kadro dolunca sıradaki kişi sıradaki karta. Küçük işe
     daha az yıldızlı kişi düşer. Kişi aşama ya da hafta bitene dek kartında kalır. Atama bugünkü gibi kartın
     `assignees`'ine yazılır; kâğıdın konuşanı oradan okunur (`_speaker`).
   - **PM.** Hazırlanacak kartlar büyükten küçüğe, PM'ler yıldızdan aşağı dizilir. En iyi PM en büyük karttan başlar,
     haftalık hazırlık hızı bitene kadar sırayla gider; daha az yıldızlı PM onun yetişemediği kartları alır. Bir kartı tek
     PM hazırlar. Yeni PM hiçbir kartı daha iyi PM'in elinden almaz; yalnız hazırlıksız kalacak kartı hazırlar.
   - **Bonus kartta okunur.** Kartın bonusu ona atanan kişinin yıldızındandır ve plan ekranında kart başına yazar (§3.2):
     hazırlığın hızı ve hata çarpanı hazırlayan PM'den (Karar 8), yapım kalitesi geliştirenlerden (Karar 6), yakalama testi
     yapanlardan. Örnek: "Selin 5★ hazırladı · hız +%30", "Mert 4★ · Özenli".
   - **Sağlam kural.** Deterministik, plan oynatmasının parçası (Karar 9), 1 ile 50 kişide aynı; uymayan iş koşulunu bozmaz.
     Kapı (§4.1 madde 1): daha iyi bir kişi eklemek de PM eklemek de teslimi hiçbir senaryoda düşürmez.

   **Oynanışa etkisi.** Karar: kimi işe almalı; büyük işi iyi kişi hızlandırır, küçük işleri ortalama kişi taşır, "bir 5★
   mı, iki 2★ mı" anlam kazanır. Sıklık: her planda görünür, karar işe alımda. Okunuş: "Selin 5★ hazırladı · hız +%30".
   Risk: kart yüzü kalabalıklaşır (risk 4), yüzde iki satır durur; "neden Mert bu kartta"yı ipucunun tek cümlesi cevaplar;
   küçük söz kartı zayıf kişiye düşebilir (§10 Kalan soru 2). 1 kişi: kural görünmez. 50 kişi: oyuncu atamayla uğraşmaz,
   kadro kararı yıldız karışımına döner. Hüküm: #12 ve #14'ü güçlendirir, "fayda en iyi PM'den"in yerini alır.

5. **Kurucu.**
   - Kurucu her aşamada en az 2★ hızında çalışır (Y ≥ 0,86). Taban hiçbir yerde yazmaz (Erdem: "İki yıldız gibi
     çalıştıralım ama işte bunu oyuncunun görmemesi lazım"). Dosya gerçek yıldızları, plan aşama hızını puanla gösterir.
   - Güçlü alan kuralı [onay bekliyor]: puanı 5 ve üstü olan en güçlü alanında kurucu uzmanla aynı sınıftadır ve Karar 4'te
     hızıyla yarışır. Kuralsız, 4★ geliştirici kurucuya 1★ geliştirici almak MVP'yi 4'ten 6. haftaya itiyordu (v3 §3.4).
   - Sprint payı = 1 − (haftanın toplantı saati ÷ 40). Yenileme kurucuya saat yazmaz (Erdem C5).
   - Kurucunun kendi işi bir alımla en çok %10 düşer ve plan nedenini üç cümleden biriyle yazar (§3.1) (QCD D3, onaylı;
     kurucunun kalibrasyonu sonraya). Şirketin teslimi 72 alım adımının hepsinde artar, MVP gecikmez (`D_SIM_v3` §6.1).

   **Oynanışa etkisi.** Karar: kurucu bu hafta satsın mı, kod mu yazsın; yanına kimi alsın. Sıklık: her hafta. Okunuş:
   "Kurucu bu hafta 4 görüşmede: sprint payı %80." Risk: "tek başımayken daha hızlıydım" (Erdem D4); üç cümle kapatır.
   1 kişi: MVP 6. hafta (20 tohumun 17'sinde). 50 kişi: kurucunun payı küçük, kurucu büyük adayı oynar. Hüküm: Tut,
   güçlendir (#15).

6. **Hata doğuşu, test ve zincir yakalama.**
   - Hata yükü H = 0,04 × S × tür × (1 − h r) × yapım kalitesi. Tür: özellik, istek, ücretli plan 1,0; düzeltme kartı 0,3;
     araştırma 0. Yapım kalitesi: geliştirmeyi yapanların payla ağırlıklı 1 ÷ √Y(Yazılım); TİTİZ ×0,5. Çıkan hata
     geliştiricinin yıldızına ve işin büyüklüğüne bağlıdır (QCD D6, onaylı); katsayılar [onay bekliyor].
   - Yakalama C = Σ pay × c(kişi), en çok 1; c = 0,57 × √Y(Test): 1★ %46, 3★ %61, 5★ %81 [onay bekliyor]; 5★ artık %19
     kaçırır (Erdem'in "%43" itirazının cevabı). Kendi geliştirdiği kartı test eden ×0,6 bulur, kurucu dahil (QCD D6, onaylı).
   - **Zincir yakalama.** Birden çok testçi payı kadar katkı verir; toplam en iyi testçinin c'sini aşmaz (`D_MODEL_v3`
     §6.12 kapı 9). Kadro kuralı küçük karta tek testçi koyar. Kalabalık kaliteyi artırmaz.
   - Test bittiği an kartın hata sayısı n ve bulunan F kartın tohumundan belli olur. Bulunan her hata Düzeltme alt
     aşamasına iş ekler: hafif 1,3, ağır 5,3 puan, ağır payı %18 [onay bekliyor]. Düzeltme Geliştirme satırında ve
     geliştirme kuralıyla atanır; testçi düzeltmez.
   - Bulunamayan hata kart yayına çıkınca kartın hattına açık hata olur (`ProductState.add_bugs`, `product_state.gd:210`);
     v1.0'dan önce `pending_faulty`'de bekler. A Karar 3'ün tek istisnası budur.
   - Kartta, ipucunda ve planda yüzde yoktur (Erdem: "kart hata ihtimali %35 gibi bir şey yazmayalım"). Test bitince kart
     "Test: 3 hata buldu, 2'si düzeltildi." der.
   - **Kalkanlar:** `faulty` ve testçisiz test işareti (`sprint_system.gd:1170-1171`), `faulty_chance` (`sprint.json:29`),
     kapanış zarı (`:1462-1464`), destekteki yeni kod terimi (`support_system.gd:37`, `:162`), `promise.cut_test_escape`
     (`sprint.json:30`). "Testi kısalt" yakalamayı orantılı düşürür.

   **Oynanışa etkisi.** Karar: testçi mi geliştirici mi, hangi yıldız. Sıklık: işe alımda; sonucu her sprintte görünür.
   Okunuş: "Test: 3 hata buldu, 2'si düzeltildi." Risk yok: satır saati durdurmaz. 1 kişi: kurucu kendi kartını test eder,
   az bulur, hata canlıda çıkar. 50 kişi: satır ipucunda, özeti sürüm notunda. Testçisiz yerine 3★ testçi teslimi %9 ile
   %14 artırır, kaçanı %25 ile %36 azaltır; 1★ yerine 5★ kaçanı %57 ile %64 azaltır (`D_SIM_v3` §0). Hüküm: Tut (#13).

7. **Sprint sonu gönder sorusu.**
   - Soru vardır (Erdem: "Şu haliyle gönderelim mi yoksa ... bir sonraki sprinte mi atalım"). **Ne zaman** (QCD D1,
     önerildiği gibi): sprint kapanışında testi bitmiş ama düzeltmesi bitmemiş kart verilmiş bir söze, bir hesabın isteğine
     ya da tarihe (bu ya da sonraki sprint) bağlıysa. Öbür kartlarda soru gelmez: "bırak" sessiz işler, sürüm notu tek
     satır yazar. Sprint başına tek soru; bağlı kartlar tek tabloda.
   - **Kip ayarı kalır:** `sprint.json`'da tek anahtar; varsayılan **bağlı** kip. Eşikli kip (bilinen hata ≥ en büyüğü(1;
     ⌈bulunan ÷ 3⌉)) ayar olarak durur, yalnız karşılaştırma ölçümüne girer. C'de istekleri yalnız 3★ ve üstü hesaplar
     yapar (QCD C6); isteğe bağlı kart seyrektir, soru çoğunlukla söz kartında doğar.
   - Sıra: sprint kâğıdının altında, istek kartının üstünde (Karar 16). Önceki biri geldiyse sorulmaz, varsayılan uygulanır. Söz olayında "Testi
     kısalt" ya da "fazla mesai" seçildiyse söz kartı gönderilir; "ek süre" ya da "söz kaçsın" seçildiyse bırakılır.

   - **Gönder:** kart teslim sayılır (kademe ve alan puanı şimdi), bilinen hata kartın hattına açık hata olur ve C'nin
     memnuniyet satırına, B'nin "sürüm sonrası bozulma"sına bu sürümün hatası olarak girer. **Sonraki sprinte bırak**
     (vurgulu, varsayılan): kart sonraki planın 3. basamağına kalan düzeltmeyle girer, söz ya da istekse tarih kayabilir;
     işi düzeltme payına girmez, "toplam hata işi" olarak ölçülür (`D_MODEL_v3` §3.7).

   **Oynanışa etkisi.** Karar: söz mü, kalite mi. Sıklık: yalnız bağlı kart bilinen hatayla kapanınca; eşikli kipin 3 ile
   25 kişideki %4 ile %29'unun (`D_MODEL_v3` §4.8) çok altında [ölçülmedi; kapı ≤ %10]. Okunuş: "Ege Sigorta'ya söz
   verdiğimiz Toplu fatura'da 2 bilinen hata kaldı." Risk: ağırlıksız soru angaryadır; bağlı kip yalnız gerçek bir müşteri
   ya da tarih tartılırken sorar. 1 kişi: çok seyrek. 50 kişi: hesap sayısıyla büyümez, sprintte en çok bir. Hüküm:
   Sadeleştir (#13).

8. **PM önden hazırlık.**
   - PM sprint puanı üretmez, önden gider (Erdem: "PM değeri koordinasyon değil, önden hazırlık olsun"). Hazırlık işi
     kartın %20'sidir (Erdem: "Tamam böyle yapalım"). Düzeltme ve araştırma kartı hazırlanmaz.
   - Hazırlık hızı P(s) = 15 + 10 × √((s − 2) ÷ 8) puan/hafta: 1★ 15, 3★ 22, 5★ 25. Uçlar Erdem'in ("1 yıldız ... 15 SP",
     "5 yıldız ... 25 SP", "full lineer şekilde arttıramayız"); eğri [onay bekliyor].
   - Hazır kartın faydası: hız +%10 (1★) ile +%30 (5★) (Erdem); hata çarpanı ×0,90 ile ×0,60 [onay bekliyor] (Erdem: "bug
     ihtimalinde bunu yıldızına bağlayabiliriz"). Yarım hazırlık orantılı fayda alır.
   - Birden çok PM: hızlar toplanır; her kartın faydası onu hazırlayan PM'in yıldızındandır. Hangi PM'in hangi kartı
     hazırlayacağını Karar 4 belirler: büyük kart iyi PM'e, küçük kart daha az yıldızlı PM'e (QCD Atama).
   - PM'siz ekibe ceza yoktur (Erdem); tasarımcı sprintte çalışır (`sprint_system.gd:1123-1128`). Sürüm notu hazırlığın
     kazancını sayıyla yazar [onay bekliyor; #14].

   **Oynanışa etkisi.** Karar: PM almak mı, hangi yıldız, kaç PM. Sıklık: işe alımda. Okunuş: büyük kartta "Selin 5★
   hazırladı · hız +%30", küçük kartta "Can 2★ hazırladı · hız +%15": iyi PM'in etkisi kötüsünden farklı görünür (Erdem).
   Risk: kazanç görünmezse PM değersiz görünür; kart satırı kapatır. 1 kişi: PM almak teslimi 4,5'ten 5,4'e çıkarır. 50
   kişi: bir PM 7 ile 12 kişiyi besler; kaç PM ve hangi yıldız kadro kararıdır, ikinci PM teslimi düşürmez. Hüküm: Tut (#14).

9. **Tahmin = sonuç.**
   - Plan ekranı, "+", öneri, MVP tahmini ve kapanış aynı oynatmayı koşar (`plan_outcome`, `_play_out`,
     `sprint_system.gd:774-777`, `:1180-1210`). Erdem: "tahmin sonuçla aynı çıkmak zorunda". Atama (Karar 4) ve çekilen
     kart (Karar 11) oynatmanın parçasıdır; plan ikisini de gösterir.
   - Hata sayısı ve bulunan kart tohumuyla test anında belirlenir; plan sayıyı bulur ama göstermez [onay bekliyor;
     `D_MODEL_v3` Soru 4]. Adlı uyuşmazlıklar v2'deki gibidir (B'nin kararları, işe alım ya da ayrılık, izin ve eğitim,
     kurucu toplantısı); gönder sorusu kapanıştadır, tahmini bozmaz.

   **Oynanışa etkisi.** Karar doğurmaz; güven verir. Okunuş: plan ne diyorsa kapanış odur. Risk: tutmayan tahmin Software
   Inc.'in şikâyetidir (R5 §1 madde 4). 1 ve 50 kişide aynı. Hüküm: %90 listesi, "açıklanamayan puan olmasın" (§5).

10. **Plan ekranı.**
    - Erdem: "Aşama şeridi ve test yetişmiyor gibi darboğaz cümlesi her zaman görünür. Okey." ve "Direkt oyunun UI'yla".
      Gösterim Menajer dilidir (`docs/mockups/menajer/`).
    - Beş parça: aşama şeridi ve darboğaz cümlesi her zaman; kart başına atama ve bonus (Karar 4); "Sırada" satırı
      (Karar 11); kart zinciri kartın üstüne gelince; kişi yükü avatar satırında, sığmayan ekipte aşama başına özet
      [onay bekliyor]. Sprint süresi seçicisi yoktur.
    - Darboğaz cümlesi her zaman tektir ve en büyük oranı yazar: aşama yükü ÷ o aşamanın kapasitesi. Gözlem yazar, öneri
      yazmaz ("testçi al" yazmaz); ondalık yok. Bugünkü planda şerit ve cümle yoktur (`SPRINT_DUZENI` §1).

    **Oynanışa etkisi.** Karar: hangi rolü işe almalı, hangi kartı çıkarmalı. Sıklık: her plan (koşuda yaklaşık 52).
    Okunuş: "Test satırı dolu. Yeni kart sonraki sprinte kalır." Risk: birden çok cümle şerit olur (risk 4); tek cümle
    kuralı tutar. 1 kişi: çoğu zaman "Kurucu testte: ..." ya da cümlesiz. 50 kişi: aşama özeti; ekran 6 kişidekinden
    kalabalık olmaz. Hüküm: Tut, güçlendir (#16).

### Sprint düzeni
11. **Sprint sabit 2 hafta; erken kapanmaz** (QCD D4).
    - 1 hafta seçeneği ekrandan, kayıttan ve bottan kalkar (`sprint.json:3`, `set_weeks` `sprint_system.gd:324-328`,
      seçici `sprint_panel.gd:75-81`, eylem `product_tab.gd:262`). Tek planlama, tek kapanış, tek sürüm notu (K1).
    - Sprint üç şartla kart alır: toplam iş ≤ 1,25 × kapasite (`sprint.json:26`, `:753-761`); aşama satırında kalan iş
      ≤ 2 × aşama kapasitesi [onay bekliyor]; yeni kart bu sprintte iş almalı.
    - **Erken kapanış kalkar** (`sprint_system.gd:1109-1110`). Ekip bir aşamada işsiz kalacakken sistem öneri sırasındaki
      (Karar 12) sonraki uyan kartı sprinte çeker. Çekilen kart alım kuralına ve düzeltme pay tavanına uyar; sprintte en
      çok bir kart devreder (`sprint_catalog.gd:505-510`). Uyan kart yoksa kişi boşta kalır, darboğaz cümlesi nedenini yazar.
    - **Planda:** oynatma hangi kartın hangi hafta çekileceğini bilir; plan bunu "Sırada" satırında yazar, bitmeyecek olan
      "sonraki sprinte devreder" der (§3.1). Oyuncu sırayı kartı plana ekleyerek ya da çeyrek hedefiyle değiştirir. Çekme
      oynatmanın parçası olduğu için tahmin = sonuç korunur; prob `PRED` ve `CLOSE`'a çekilen kartı yazar (§4.4).
    - **Kâğıt zarı her sprintte atılır:** zar ilk haftanın sonundadır (`_end_week` → `_staff_week(true)`) ve her sprint
      oraya varır; 1 haftalık sprintin başlangıç zarı (`:164`) kalkar. Söz olayı ya da acil durum gelen sprintte kâğıt
      gelmez (B). **MVP ve sürüm sprint sonundadır**; sprint ortasında sürüm yoktur.
    - **B ile:** "Sprinti durdur"da düzeltme kartı koşan sprintin başına geçer (`put_first`), çip kayan kartı adıyla yazar;
      kayan kart öneri sırasının 3. basamağına döner, ekip erken biterse aynı sprintte ilk çekilen odur; düzeltme sprint
      sonunda sürümle çıkar. Acil durumun düzeltme kartı son gece mesaiden sonra gelirse sonraki sprinte geçer (`889b9b8`);
      son gece 2. haftanınkidir. Söz olayı 2. haftada sorulur. `team.demo_day` bugün yalnız 1 haftalık sprintin başında
      istenir (`sprint_system.gd:165-166`); D onu 2. haftanın başında ister, kâğıt gelen sprintte gelmez [onay bekliyor].
    - **Eski kayıt:** göç `sprint.weeks`'i 2 yapar; koşan 1 haftalık sprint 2 haftaya uzar, ikinci haftasında çekme işler.

    **Oynanışa etkisi.** Karar: süre kararı kalkar (tek doğru cevaplıydı: tek kurucuda 1 haftalık sprintte %6,6 hata
    sprinti, 2 haftalıkta %0,4); sprint kararı kartlar ve sıradır. Sıklık: koşuda yaklaşık 52 plan. Okunuş: "Sırada: Stok
    uyarısı. Ekip 2. haftada bu kartı çeker." Risk: bugün 1.506 sprintin 956'sı 1 tikte kapanıyor, bunlara kâğıt gelmiyor
    (RAPOR_B §1 madde 3, 4); sabit süre ve çekme kapatır. 52 plan angarya olabilir; öneri, çeyrek hedefi ve devret indirir.
    1 kişi: kurucu sprintte bir kart civarı bitirir, boş hafta yok. 50 kişi: 27 kart; çekilen kart kendiliğinden gelir.
    Hüküm: Sprint katmanı (§1.1); QCD §2.4: "iyi karar".

12. **Tek öneri, çeyrek hedefi ve planlamayı devret.**
    - Öneri planın alım kuralıyla tavana kadar doldurur; uymayan adayı atlar, sıradaki en çok 12 adaya bakar. Altı
      basamak: (1) verilmiş sözlerin kartları, tarihi yakın önde; (2) tarihi bu ya da sonraki sprint olan talepler;
      (3) bırakılan ve devreden kartlar; (4) Öncelikli düzeltmeler, pay tavanına kadar; (5) çeyrek hedefinin, hedef yoksa
      en zayıf alanın en iyi kartı; (6) kalanlar etki ÷ iş sırasıyla. Ücretli plan (1)'in arkasındadır [onay bekliyor].
      Kalkanlar: "yalnız bitecek kartlar, en çok bir devreden" (`sprint_catalog.gd:505-510`, `:912-921`), "en çok bir
      talep" (`:900`). Aynı sıra Karar 11'in çekme sırasıdır.
    - **Bot yalnız öneriyi kullanır** (`run_probe.gd:974`, `:989`, `:1045-1075`); düzeltme kolları (`:1006-1040`) kalır.
    - **Çeyrek hedefi PM'siz de seçilir** (QCD D4; Erdem: "bu çeyrekte bunu, bunları yapmalıyım diye ... sonrasında
      sprintler otomatik buna göre yapılıyor olabilir"). Bugün ÇEYREK yalnız PM'le açılır (`product_model.gd:411-413`),
      hedef yalnız PM'in planını ağırlıklar (`sprint_catalog.gd:582-606`), lider önerisi okumaz (`:509-510`). D'de seçenekler
      alanlar ve "Hatalar"; hedef önerinin 5. basamağını sürer, "Hatalar" düzeltmeyi yarı kapasiteye kadar öne alır.
    - **Planlamayı devret PM olmadan açılmaz** (QCD D4). Bugünkü şart korunur (`delegated`, `sprint_system.gd:592-594`).
      PM yokken düğme kilitli görünür ve nedenini yazar (§3.1); PM işe alınınca açılır, PM ayrılınca devir kalkar ve plan
      oyuncuyu bekler. Aynı öneri üç sprint değişmeden başlatılınca plan, PM varsa, devri bir satırla önerir [onay bekliyor;
      R13 Ders 5]. Devredilen plan saati durdurmaz (`awaits_plan`, `:581-589`); devir tek tıkla geri alınır.

    **Oynanışa etkisi.** Karar: bu çeyrek neye yüklenilecek; PM almak devri de açar. Sıklık: çeyrekte bir; plan sprintte 2
    ya da 3 eylem. Okunuş: "Bu çeyrek: Entegrasyonlar". Risk: GDT kalıbı, öneriyi uygula ve başlat (R14 §9); hedef önerinin
    sırasını gerçekten değiştirdiği için yüzey "tek doğru cevap" sınıfından çıkar (R15 §6 #8). PM'siz büyük ekip her 2
    haftada planı onaylar, öneriyle 2 eylem. 1 kişi: MVP öncesi hedef Çekirdek'te sabit. 50 kişi: asıl sprint kararı budur
    (Erdem: "50 kişide asıl karar ... bu çeyrek ne bekliyoruz"); PM'le plan çoğu zaman devirdedir. Hüküm: Güçlendir (#19).

13. **Kart arzı.**
    - Hedef (içeriğin tutması gereken): plan anında açık aday ≥ 0,75 × ekip, 8 kişinin altında ≥ ekip (`SPRINT_DUZENI`
      K7). Erken kapanış kalktığı için arz çekmeyi de besler. Dört kaynak:
      - **A. Kademe** (bugünkü): hat başına K1 → K2 → K3, zincirli (`sprint_catalog.gd:212-256`).
      - **B. Derinlik kartı:** K3'ü biten hatta aynı anda açık kart = 1 + ⌊hattı kullanan hesap ÷ 5⌋, en çok 8 (B2C'de
        1 + ⌊hattın kullanıcısı ÷ 2.500⌋, en çok 8, ölçülmedi). Boyut 15, 25, 40 sırayla; profil hattınkidir. Kazanç Q'nun
        `level`'ına eklenir, k'inci kartınki ilkinin 0,75^(k−1) katı [hepsi onay bekliyor]. İlk kazanç g₀ tanımsız; D0t Q'nun
        seviye biriminde önerir, E1'e götürür. Q'nun oran kesiğine (1,5) varmış alanda kart önerilmez.
      - **C. Hesap isteği kartı:** B2B'de istek, hesabın hattında açık kademe yoksa hesabın kendi kartı olur. İsteği yalnız
        3★ ve üstü hesaplar yapar (QCD C6); kaynak seyrektir. Boyut koltukla: 20'den az 15, 20 ile 99 arası 25, 100 ve
        üstü 40; hesap başına yılda bir [onay bekliyor].
      - **D. EA modülü:** yeni hat grupları (E'nin işi).
    - Derinlik kartının adı işin kendisidir; hat başına en az 6 elle yazılmış ad, şablon yok [onay bekliyor; #17]. Etki
      satırı azalan kazancı Q'nun `area_row` karesiyle yazar; kazanç bir kareden azsa "ilk karttan az" der.
    - Karşılanmayan istek düşer, memnuniyeti düşürmez (Erdem C6); söz verilmişse sözün kuralı işler. Bakım ya da teknik
      borç kartı yoktur (Erdem: "Oyuncuyu sürekli bug sprint koşarken görmeyelim"). İstek kâğıdı C'nindir; D arzı kurar.

    **Oynanışa etkisi.** Karar: hangi alan derinleşsin (çeyrek hedefiyle). Sıklık: K3'ten sonra sürekli. Okunuş: kart adı
    ve "Entegrasyonlar +1 kare (ilk karttan az)". Risk: jenerik ad grind hissi verir (R14 T01); istek seyrekleşince yük
    derinlik kartına biner. 1 kişi: kademe yeter, katalog 114 haftada biter. 50 kişi: arzsız katalog 7 haftada biterdi;
    arzla 330 hesapta hedef %100 (`D_SIM_v3` §11). Hüküm: Tut (#17); istek kesintisinin sadeleşmesi C'de (#18).

14. **Düzeltme kartı.**
    - Büyüklük = 2 × hattın açık hatası puan, alt sınır yok; faz payı 0 / 0,7 / 0,3 [onay bekliyor]. A'nın `fix_effort`
      kademeleri kalkar (`sprint.json:7`, `sprint_catalog.gd:179-182`). Öncelikli eşiği hatta 5 hata, değişmez.
    - Pay tavanı (v2): planın ve çekmenin kendiliğinden aldığı düzeltme işi kapasitenin yarısını aşmaz; sprintte düzeltme
      kartı yoksa ilk kart her zaman girer. Testte bulunan hata kartın içinde düzeltilir; düzeltme kartı canlı hata içindir.

    **Oynanışa etkisi.** Karar: hata mı, özellik mi. Sıklık: her plan. Okunuş: "Fatura düzeltmesi · 6 açık hata · 12
    puan" / "Invoicing fix · 6 open bugs · 12 points". Risk: sürekli hata sprinti (Erdem reddetti). 1 kişi: 2 haftalık
    sprintte hata sprinti %0,4. 50 kişi: düzeltme payı %3. Hüküm: Tut (#20).

15. **A'nın sınırları ekiple oranlanır** (Erdem 17 Ekim: "D5 okey").
    - k = en büyüğü(1; canlı hat ÷ 9; √(son 8 haftanın haftalık teslimi ÷ 55)) [formül onay bekliyor]. A'nın mutlak
      sayıları k ile çarpılır: itibar eşiği (`support_system.gd:86` `NEGLECT_BUGS` 30, okuyan `:283`) ve A'nın ölçüm
      hedefleri. Oyuncu formülü değil, Destek kartının ipucunda eşiği sayıyla görür.

    **Oynanışa etkisi.** Karar doğurmaz; adalet sağlar. Mutlak 30'da 50 kişi 5 haftada eşiğe varırdı (`D_SIM_v3` §6.6). 1
    kişi: eşik 30; 50 kişi: yaklaşık 95. Hüküm: "durup dururken düşüş yok" ilkesinin ölçek hâli.

16. **Kesinti bütçesi.**
    - Sprintte ve haftada saati durduran en çok bir kesinti olur: B Karar 12'nin uzantısı (`_paper_blocked`,
      `record_interrupt`, `sprint_system.gd:1270-1274`, `:564-567`). Tabloyu C kurar (C'nin PRD'si, yenileme kararı); D
      gönder sorusunu sprint kâğıdıyla istek kartı arasına ekler. Sıra: acil durum (servis çöktü) > söz olayı > yenileme kâğıdı > sprint kâğıdı > gönder
      sorusu > istek kartı [onay bekliyor; hüküm risk 5]. Servisin çöktüğü acil durum her zaman gelir.
    - Sıraya giremeyen varsayılanını uygular (gönder sorusu: bırak). Mail ve not saati durdurmaz. D'nin eklediği tek yeni
      saat durdurucu gönder sorusudur; plan tutuşu (`sprint_plan`) devirde kalkar.

    **Oynanışa etkisi.** Karar doğurmaz; akışı korur. Okunuş: hiçbir sprintte iki durma yok. Risk: B2B Traction'da bugün
    haftada 1,72 durma var (R15 §4.4); C ve D en kötü durumda +1,1 ekler (R15 §7.4); sabit 2 hafta kâğıdı her sprinte
    taşır, bütçe sprintte bir durmayı tutar. 1 ve 50 kişide aynı bütçe; kesinti kişi ya da hesapla doğrusal büyümez.
    Hüküm: risk 5.

### Ölçekte oyuncunun kararı (risk 3 özeti)
Sprintte kart ve planlama eylemi (elle / öneriyle): 1 kişi 0,4 kart, 2 / 2, tek kart ve "kurucu satsın mı kod mu yazsın";
6 kişi 2,4, 4 / 2, kart seçimi ve ilk rol karışımı; 12 kişi 5,4, 7 / 2, çeyrek hedefi, PM, testçi; 25 kişi 13,3, 14 / 2,
çeyrek hedefi, darboğaz rolü, PM'le devret; 50 kişi 27, 26 / 2, çeyrek hedefi ve yıldız karışımı, plan çoğu zaman devirde.
Kaynak `D_MODEL_v3` §4.2, `SPRINT_DUZENI` §4.3 (karışık süreli; D0s 2 haftayla yeniden yazar). Kayma Karar 10 ve 12 ile
kurulur (R14 T05). Gönder sorusu bağlı kipte ölçekle büyümez.

## 3. Oyuncu ne görecek
Sayılar örnektir [ÇALIŞMA]. Metinler TR ve EN, tiresiz, "TR/EN onay bekliyor". Gösterim Menajer dilidir; M adımı ekranı
oyunun kendi arayüzüyle fikstürle kurar (Claude Design maketi yok).

### 3.1 Ürün · Sprint planı
```
SPRINT 14 · 2 HAFTA                                    BU ÇEYREK: ENTEGRASYONLAR ▾
TASARIM     ███████░░░░░   17 iş · ekip 24
GELİŞTİRME  ████████████   46 iş · ekip 46
TEST        ███████████▓   26 iş · ekip 20    6 puan sonraki sprinte kalır
Test yetişmiyor: Hesap Planı ve Stok Sayacı testte kalır.
ÖNERİ  Fatura düzeltmesi ve Toplu fatura bu sprinte girer.        [ÖNERİYİ UYGULA]
(kartlar; her kartta atama ve bonus, §3.2)
SIRADA  Stok uyarısı · 2. haftada çekilir
Kurucu · Tasarım 9/hf   Ayşe · Test   Deniz · Geliştirme   Mert · boşta        [PLANLAMAYI DEVRET]
```
- Şerit satırı: TR "TEST · 26 iş · ekip 20" · EN "TEST · 26 work · team 20". Aşım: TR "6 puan sonraki sprinte kalır" ·
  EN "6 points wait for the next sprint".
- Darboğaz cümlesi (biri, her zaman): TR "Test yetişmiyor: Hesap Planı ve Stok Sayacı testte kalır." · EN "Testing can't
  keep up: Account Plan and Stock Counter stay in testing." TR "Test satırı dolu. Yeni kart sonraki sprinte kalır." · EN
  "The Test row is full. New cards wait for the next sprint." TR "Planlanacak kart kalmadı: 6 kişi bu sprint boşta." · EN
  "No cards left to plan: 6 people are idle this sprint." TR "Mert boşta: geliştirmeye açık kart yok." · EN "Mert is
  idle: no card is open for development." TR "Selin'in hazırlayacağı kart kalmadı." · EN "Selin has no cards left to
  prepare." TR "Testi yapacak kimse yok." · EN "Nobody can test."
- Kurucunun düşüşü: TR "Kurucu testte: ekipte testi yapacak başka kimse yok." · EN "Founder is testing: nobody else on the
  team can test." TR "Kurucu Geliştirme'yi Mert ile paylaşıyor." · EN "Founder shares Development with Mert." TR "Kartlar
  hazır geldi: aynı iş daha az puan tuttu." · EN "Cards came prepared: the same work took fewer points."
- Sırada: TR "Sırada: Stok uyarısı. Ekip 2. haftada bu kartı çeker." · EN "Up next: Stock alerts. The team picks it up in
  week 2." Bitmeyecekse: TR "Sırada: Stok uyarısı. 2. haftada başlar, sonraki sprinte devreder." · EN "Up next: Stock
  alerts. It starts in week 2 and carries over to the next sprint."
- Kurucu: TR "Kurucu bu hafta 4 görüşmede: sprint payı %80." · EN "Founder has 4 meetings this week: sprint share 80%."
  Uymayan iş: TR "Selin testte ×0,4 hızla çalışıyor; başka işi yok. Sprint sonunda 2 moral kaybeder." · EN "Selin is
  testing at ×0.4 speed; there is no other work for her. She loses 2 morale at sprint end." Çeyrek: TR "Bu çeyrek:
  Entegrasyonlar" · EN "This quarter: Integrations"; seçenekler alanlar ve TR "Hatalar" · EN "Bugs"; PM'siz de açılır.
- Devret, PM yokken kilitli: TR "Planlamayı devretmek için ekipte bir ürün yöneticisi olmalı." · EN "You need a product
  manager on the team to hand planning over." Devret önerisi (yalnız PM varken): TR "Son üç sprinti öneriyle aynen
  başlattın. Planlamayı Selin'e devredebilirsin." · EN "You started the last three sprints on the suggestion as it was.
  You can hand planning over to Selin." Devirdeyken: TR "Planlama Selin'de. Sprint öneriyle kendiliğinden başlar." · EN
  "Selin has the planning. Sprints start on the suggestion by themselves."
- Sığmayan ekipte aşama özeti: TR "TEST · 9 kişi · 2 boşta" · EN "TEST · 9 people · 2 idle".

### 3.2 Sprint kartı
- Plan kartının yüzünde iki satır (Karar 4): hazırlık, kart hazırlandıysa: TR "Selin 5★ hazırladı · hız +%30" · EN
  "Prepared by Selin 5★ · speed +30%"; küçük kartta TR "Can 2★ hazırladı · hız +%15" · EN "Prepared by Can 2★ · speed
  +15%". Ekip, aşama başına baştaki kişi: TR ve EN "Ece 3★ · Mert 4★ +1 · Ayşe 3★".
- Plan ipucu: TR "Tasarım 9 · Geliştirme 11 · Test 5 · Geliştirme en çok 2 kişi" · EN "Design 9 · Development 11 · Test 5
  · Development 2 people at most". Aşama satırı: TR "Geliştirme: Mert 4★ ve Can 2★ · Özenli" · EN "Development: Mert 4★
  and Can 2★ · Careful"; TR "Hazırlık: Selin 5★ · hız +%30 · hata ×0,6" · EN "Prep: Selin 5★ · speed +30% · bugs ×0.6".
  Kural: TR "En büyük işe en iyi kişi atanır." · EN "The biggest job goes to the best person."
- Test: TR "Test: Ayşe 3★" · EN "Test: Ayşe 3★"; kendi kartı TR "Test: Deniz 3★ (kartı kendisi yazdı)" · EN "Test: Deniz
  3★ (wrote this card)". Testten önce kart hata hakkında hiçbir şey yazmaz; yüzde hiçbir yerde yoktur.
- Koşan kart: [Tas][Gel][Test], hata bulunduysa [Düz] eklenir. TR "Test: 3 hata buldu, 2'si düzeltildi." · EN "Test:
  found 3 bugs, fixed 2." TR "Test: hata bulunmadı." · EN "Test: no bugs found." TR "Düzeltiliyor: 1 hata kaldı." · EN
  "Fixing: 1 bug left." Derinlik kartı: TR "Toplu fatura: ikinci para birimi" · EN "Bulk invoicing: second currency";
  etki TR "Entegrasyonlar +1 kare (bu alandaki ilk karttan az)" · EN "Integrations +1 square (less than the first card in
  this area)". İstek: TR "Ege Sigorta isteği: aylık rapor aktarımı" · EN "Ege Sigorta request: monthly report export".
  "Özenli" ve "Aceleci"nin yıldız eşikleri [onay bekliyor; #12]; ★ glifi `glyph_audit`'ten geçer.

### 3.3 Kapanış: gönder sorusu
Olaylar'da karar kâğıdı biçiminde, yalnız bağlı kartta gelir. Konuşan bilinen hatayı bulan testçidir; testçi yoksa
kurucunun notudur [onay bekliyor].
- Soru: TR "Ege Sigorta'ya söz verdiğimiz Toplu fatura'da 2 bilinen hata kaldı. Bu haliyle gönderelim mi, sonraki sprinte
  mi bırakalım?" · EN "Bulk invoicing, promised to Ege Sigorta, still has 2 known bugs. Ship it as it is, or leave it for
  the next sprint?" Düğmeler: TR "Gönder" / "Sonraki sprinte bırak" · EN "Ship" / "Leave for next sprint".
- Çipler: TR "Ege Sigorta'ya verilen söz bu sprintte tutulur." · EN "The promise to Ege Sigorta is kept this sprint." TR
  "Fatura hattına 2 açık hata yazılır." · EN "2 open bugs are added to Invoicing." TR "Toplu fatura sonraki sprintte 4
  puanlık düzeltmeyle biter." · EN "Bulk invoicing finishes next sprint after 4 points of fixing."

### 3.4 Sürüm notu
- TR "Bu sprintte testçiler 11 hata buldu. 9'u düzeltildi, 2'si bilinen hata olarak kaldı." · EN "Testers found 11 bugs
  this sprint. 9 were fixed, 2 remain known." Sessiz varsayılan: TR "Stok Sayacı düzeltmede kaldı: 1 bilinen hata,
  sonraki sprintte biter." · EN "Stock Counter stayed in fixing: 1 known bug, finishes next sprint."
- TR "Ekip 2. haftada Stok uyarısı'nı da çekti." · EN "The team also picked up Stock alerts in week 2." TR "Kartlar hazır
  geldi: aynı iş 12 puan az tuttu." · EN "Cards came prepared: the same work took 12 fewer points."

### 3.5 Ekip
- Atlas ve dosya, bugünkü tek sayının yerine (`hr_atlas_modal.gd:343`): TR "Geliştirme 12/hf · Test 8/hf" · EN
  "Development 12/wk · Test 8/wk". Yapım kalitesi sözcükle, sayısız [onay bekliyor; #12]: TR "Özenli" / "Aceleci" · EN
  "Careful" / "Hasty".
- Görevler matrisinde uymayan kutu: TR "Testte ×0,4 hız; sprint sonunda 2 moral" · EN "Testing at ×0.4 speed; 2 morale at
  sprint end". Kurucunun dosyası gerçek yıldızları gösterir; 2★ tabanı hiçbir metinde geçmez.

## 4. Kabul ölçütleri
### 4.1 Modelin Godot'taki ölçümü (D9)
Simülasyonun 23 kapısı (`D_MODEL_v3` §6.12; `D_SIM_v3` §11; atama ve sabit 2 hafta için D0s) Godot'ta `--sprint-probe` ekip
fikstürleri ve `--run-log` bot koşularıyla yeniden ölçülür. Beklenen değerler D0s tablosu ve `D_SIM_v3` §11'in "2 hf"
satırlarıdır; ±%10 sapma kabul. Daha büyük sapmada önce §6 tanımıyla uygulama karşılaştırılır. En az:
1. `ekleme_dusurmez`: bir kişi eklemek ya da bir kişiyi daha iyisiyle değiştirmek teslimi hiçbir senaryoda düşürmez
   (tolerans yok; v3'te en kötü −0,5, 37. kişi PM). `pm_ekleme`: PM eklemek teslimi düşürmez; "kartı hazırlayanın
   yıldızı" kuralıyla ölçülen −2,5 (`D_SIM_v3` §5.2) Karar 4'ün kuralıyla yeniden ölçülür, iki sayı yan yana yazılır.
   `atama_sirasi`: her atama anında ve aşamada daha büyük işte daha yavaş kişi yoktur; aynı girdi aynı atamayı verir;
   uymayan iş yalnız boşta kalacak kişiye gider.
2. `kurucu_buyume`: şirket teslimi her alımda artar, MVP gecikmez, kurucunun işi en çok %12 düşer, her düşüşün nedeni
   kayıtlıdır. `mvp_tek_kurucu`: MVP sprint sonunda, 6. hafta, en geç 8.
3. `duzeltme_payi`: 2 ve üstü kişide erken ≤ %30, geç ≤ %20, hata sprinti ≤ %5, üst üste yok; tek kurucuda erken ≤ %50,
   geç hata sprinti ≤ %5 (2 haftada ölçülen %0,4). `toplam_hata_isi`: ≤ %20, tek kurucuda ≤ %35.
4. `testci_yildizi`, `testci_degeri`: 1★ → 5★ kaçan hata ≥ %40 azalır, bulunan ≥ 2 katı; testçisiz yerine 3★ testçi
   teslimi düşürmez, kaçanı ≥ %20 azaltır. `kendi_karti`: ×0,6, kurucu dahil. `pm_yildizi`: besleyen PM sayısıyla
   1★ → 5★ teslim ≥ %10, kaçan ≥ %25 iyi.
5. `soru_sikligi`: bağlı kipte soru sprintlerin ≤ %10'unda; B2B söz veren bot kolunda koşu başına ≥ 1 [hedef önerisi],
   gelmiyorsa nedeni rapora. Eşikli kip yalnız karşılaştırmadır. `soru_politikasi`: dört politikada teslim farkı ≤ %2;
   hep gönder açık hata medyanını ≤ %20 artırır.
6. `arz_havuzu`, `kart_yok_sprinti`, `oneri_dolulugu`, `bosta_nedenli`: büyüme eğrisinde açık aday hedefi sprintlerin
   ≥ %90'ında, "kart yok" sprinti ≤ %5, öneri doluluğu ≥ %94, nedensiz boşta 0; C'nin 3★ istek kuralıyla.
7. `a_sinirlari_oranli`: hiç düzeltmeyen her ölçekte 10 ile 26 haftada k × 30'a varır, `fix_due` hiç varmaz.
8. `uymayan_moral`: 6 kişi + PM'in Test kutusu, 60 haftada PM 60 ile 90 moral kaybeder; atama koşuluyla ayrıca ölçülür.
9. Hedef tutmazsa sabit sessizce değiştirilmez; ölçüm ve öneri R raporunda "onay bekliyor" altında gider.

### 4.2 A'nın hedefleri olaylar açıkken (RAPOR_B §1 madde 1)
A'nın 16 koşusu (iki pazar × dört kol × tohum 7 ve 11, 104 hafta) olaylar açık ve `_free` ikizleriyle D'nin modeliyle
yeniden koşulur; tablo düzeltilmiş betikle okunur (`bug_sprint` küçük harf; RAPOR_B §1 madde 2). Tutmalı:
- `fix_due` B2C: erken düzeltme payı ≤ %30 (bugün %75), erken hata sprinti ≤ %15 (%52), üst üste iki ≤ %1 (%32).
- `fix_due` B2B: erken hata sprinti ≤ %15 (bugün %19), üst üste iki ≤ %1 (%10,5). `fix_worst` B2C: erken payı ≤ %30 (%50).
- Kalan 34 hedef ve churn'ün sekiz hedefi tutmaya devam eder; tutmayan raporda nedeniyle "onay bekliyor" altında. Neden
  beklenir: bugün 1 puanlık düzeltme kartı tek kurucunun 2 puanlık haftasının yarısıdır; D'de kart ve kapasite oranlıdır
  ve 1 tikte kapanan kısa sprintler kalkar.

### 4.3 Oynanış kapıları (`OYNANIS_HUKMU.md` §3)
1. **Sprint dolu ve tam:** bot koşularında plan anındaki doluluk medyanı ≥ %90 (bugün %13 ile %15). Her sprint 2 hafta
   sürer; erken kapanan sprint 0 (bugün 1.506'nın 956'sı 1 tikte). "Sırada" satırı ile kapanış aynı çekilen kartı sayar.
2. **50 kişide karar kayması:** sprint başına oyuncu eylemi 50 kişide 1 kişininkinin en çok 3 katı (R13 Ders 5); öneriyle
   planlama her ölçekte ≤ 3 eylem. Aynı durumda iki farklı çeyrek hedefi, PM'siz koşuda da, en az bir farklı kart seçer.
3. **Kesinti:** B2B Traction'da saat durması haftada ≤ 1,2 (bugün 1,72). İki kesintili hafta ≤ %2, çok kesintili sprint
   ≤ %1. 50 kişi ve 330 hesapta haftalık durma 6 kişi ve 20 hesaptakinin en çok 1,5 katı (C ile ortak).
4. **Kâğıt yaşıyor** (RAPOR_B §1 madde 3 ve 4), A'nın kollarında tohum 1 ile 10, 104 hafta:
   - kâğıt gelen sprint %30 ile %67 arası [hedef önerisi] (bugün %9,8); "en az üçte biri kâğıtsız" tutmaya devam eder;
   - tasarımcı kâğıtlarının en az 4/8'i ve PM kâğıtlarının en az 3/7'si en az bir kez gelir [hedef önerisi] (bugün 0/8 ve
     1/7). PM kâğıdının konusu müşteri isteği kartıdır; C'de istek yalnız 3★ hesaptan geldiği için tutmazsa neden ölçülür;
   - hiç gelmeyen her kâğıt nedeniyle listelenir; `promise_due` ve `sprint_late` sayıları da (bugün 0).
5. **Plan okunurluğu:** plan sütunu 50 kişide 6 kişidekinden en çok 2 satır uzundur; darboğaz cümlesi her karede tektir;
   şerit 3 satırdır; kart yüzünde atama en çok iki satırdır.
6. **Görünmez sayı yok:** her yeni sabitin oyuncunun gördüğü satırı vardır (`D_MODEL_v3` §4.1) ya da gerekçesiyle sessizdir
   (kurucu tabanı); kartın bonusu kart başına görünür. **Boş yüzey yok:** çeyrek hedefi, PM'le devret ve gönder sorusu iki
   bot politikasında farklı sonuç verir (R15 §6 sınıfı S); vermeyen raporda adıyla yazılır.
7. **Ölçekte boşta ve karar:** 50 kişide boşta payı en çok %15. Traction, Series A ve 50 kişilik EA koşusunda her 10
   haftada en az 3 gerçek karar; sayım C'nin PRD'si §4.3'ün `PROBE DECISION` tanımıyla [hedef önerisi].
8. **B'nin olayları kaymaz:** yeni hata doğuşu (Karar 6) B'nin acil durum zarını (`incident_system.gd:76`) ve sürüm sonrası
   bozulmayı değiştirir. Koşu başına sayı bugünle (medyan 4,5) yan yana; %30'dan büyük sapma "onay bekliyor" [hedef önerisi].

### 4.4 Tahmin ile sonuç
1. D1'den önce `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` bir kez koşulur; adlı uyuşmazlık listesi
   rapora yazılır. Her dilimden sonra adsız uyuşmazlık 0'dır.
2. `PRED` ve `CLOSE` satırlarına kart başına n, F, K, düzeltme işi, atanan kişiler ve çekilen kartlar eklenir; fark 0.
   Ekip fikstürleri 1, 6, 12, 25 ve 50 kişiyi kurar; 50 kişi ve 50 kartta "+" ve önerinin süresi ölçülür, hedef D0'da.

### 4.5 Smoke vakaları (yalnız çekirdek mantık, her biri falsification ile)
- `sprint_test_seed_deterministic` (aynı kart ve ekip aynı n, F, düzeltme işi), `sprint_escaped_bug_on_card_line` (kaçan
  hata kartın hattına düşer, v1.0 öncesi bekler; `endgame_smoke.gd:479-480` yerine).
- `sprint_ship_question_order`: bağlı kipte soru yalnız söz, istek ya da tarihli kartta; kesinti varken gelmez, "bırak"
  uygulanır; söz olayının cevabı söz kartının yerine geçer.
- `sprint_skill_assignment`: en büyük iş en hızlı kişide, en büyük kart en iyi PM'de, ikinci PM yalnız ilkinin
  yetişemediğini alır, aynı girdi aynı atama (sıralama ters çevrilince FAIL).
- `sprint_two_weeks_pull`: sprint erken kapanmaz; kartları biten ekip öneri sırasından çeker; plan ile kapanış aynı kartı
  sayar; kâğıt zarı ilk haftanın sonunda; eski kayıttaki 1 haftalık sprint 2 haftaya uzar.
- `sprint_founder_floor_silent`, `sprint_lead_fills_to_ceiling` (bot ile öneri aynı küme), `quarter_goal_without_pm`
  (hedef 5. basamağı değiştirir; "Hatalar" düzeltmeyi öne alır), `delegate_needs_pm` (PM yokken kapalı, gelince açık,
  ayrılınca devir kalkar).

### 4.6 Kayıt
Şema D1'de 19'dan 20'ye çıkar. Göç: saklı kartın ihtiyacı tablodan, ilerlemesi aşama payıyla ×5; yarım testli kart testi
baştan alır; `faulty`, `shares`, `effort_mod` gider (`D_MODEL_v3` §5); `sprint.weeks` 2 olur. Kanıt: `save_v<n>_*` vakaları.

### 4.7 Kapılar ve görsel kabul
- `--event-lint`, `loc_residue`, `loc_csv_integrity`, `plausibility_run.sh` (`fails=0`), `run_gate.sh` (üç koşu bir sonla,
  sıfır `ERROR`) temiz; oyun her commit'ten sonra açılır ve oynanır. Görsel kabul (CLAUDE.md §11): TR, EN, renk körü, 1,25
  ölçek. Yeni `--product-shot=edge:` fikstürleri HARITA'ya: plan 1, 6, 12, 50 kişi; darboğaz ve kurucu cümleleri; kart
  yüzünde atama ve bonus (iyi ve zayıf PM yan yana); ipucu; "Sırada" (biten, devreden); test satırı ve [Düz]; gönder
  sorusu; sürüm notu; PM'siz ÇEYREK; kilitli devret, devret önerisi ve devir; Atlas hızları.

## 5. Araştırma
Yeni dış araştırma gerekmez; R1 ile R5, R10 ve R12 bu modelin kaynağıdır. Uygulayıcı koddan önce üç iş yapar:
1. **Atama ve sabit 2 hafta simülasyonu** (D0s, oyun kodu istemez): `D_SIM_v3` §10'daki betik `d_taslak/sim/`'e kopyalanır;
   Karar 4'ün eşlemesi ve PM kuralı, erken kapanmayan 2 haftalık sprint ve çekme eklenir. Ölçülenler: §4.1 madde 1 (−2,5'in
   yeniden ölçümü dahil), doluluk, boşta payı, tek kurucunun hata sprinti, kadro dilimi 8 ile 40'ın teslim, boşta ve arz
   farkı (1, 6, 12, 25, 50 kişi), söz kartının iki atama sırasındaki gecikmesi. Sonuç E1'e gider.
2. **Plan hesabının bedeli** (D0): 50 kişi ve 50 kartla, atama ve çekme dahil oynatmanın süresi (R12 P11). Bir karede
   kalmıyorsa D0 durur, önbellek ya da artımlı oynatma önerisini Erdem'e götürür; kalıyorsa raporda yazar.
3. **Derinlik kartı adları** (W): her hat için gerçek ürünlerde o alanın iyileştirme işlerinden en az 6 ad; her satır kaynak
   bağlantısı ve "arandı / bulunamadı" alanı taşır; WebSearch bütçesi bitince sessizce model bilgisine düşülmez.

## 6. Bağlantılar: kopukluk olmayacak
Erdem: "Ürün akışını sprint sistemine çevirdik, sprint sistemi ekibin görevlerini bile okumuyor. Böyle kopukluklar
olmamalı." Harita kod yazılmadan çıkar (D0), Opus kodla karşılaştırır (D0v); her satır eski ve yeni karşılığıyla. En az:

**Sprint motoru** (`scripts/systems/sprint_system.gd`)
- Kişi ve ekip: `team()` `:705-723`, `capacity()` `:633-638`, `week_points` `:694-699`, `points_for`/`_points`
  `:1731-1745`, `_share` `:1749-1751`, `_fits` `:1722-1727`, `role_of` `:1710-1718`, `_restaff` `:1362`.
- Oynatma ve atama: `_assign` `:1129-1159` (bugün sprint sırasıyla doldurur; Karar 4 buraya), `_work` `:1162-1177`,
  `_play_out` `:1180-1210`, `_end_week` `:1087-1112` (erken kapanış `:1109-1110` kalkar, çekme girer), `plan_outcome`
  `:774-777`, `mvp_eta` `:804`, `_takes` `:753-761`, `card_late`…`cut_test_finishes` `:848-899`, `remaining`, `ready_share`
  `:657-680`, `total`, `phase` `:1687-1701`. Süre: `sprint_weeks` `:612-613`, `set_weeks` `:324-328` (silinir), 1 haftalık
  dal `:164-166` (zar ve `team.demo_day`), `new_state` `:75-86`, `weeks_left` `:629`.
- Hata: `escape_chance` `:954-956`, `cut_test` `:944-949`, `_close` zarı `:1462-1464`, `pending_faulty` `:1477-1481`,
  `_land_faulty` `:1547-1552`, sürüm kaydının `faulty`'si `:1508`, `_refresh_fix_cards` `:1642-1653`.
- Kesinti ve kâğıt: `record_interrupt` `:564-567`, `_request_decision` `:1213-1255`, `_speaker` `:1258-1267` (Karar 4'ün
  `assignees`'ini okur; Düzeltme geliştirme sayılır), `_paper_blocked` `:1270-1274`, `late_promise` ve `_ask_promise`
  `:964-1003`, `payers` `:727-741` (ödeyenlere Düzeltme eklenir). Kâğıt cevaplanınca atamayı baştan kuran düzeltme
  (RAPOR_B §1 madde 7) başka oturumda yazılıyor; D0 commit'li adını yazar, Karar 4 orada da işler.
- Plan ve devir: `apply_lead` `:332-338`, `pick_goal` `:556-558`, `set_delegate` `:286-288`, `delegated` `:592-594` (PM
  şartı kalır), `awaits_plan` `:581-589`, `sync_plan_hold` `:1604-1615`, `_auto_start` `:1392`, `fix_first` ve `put_first`
  `:208-235` (kayan kart çekme sırasına döner).

**Katalog ve öneri** (`sprint_catalog.gd`): `candidates` `:212-256` (derinlik ve istek kartı), `fix_effort` `:179-182`,
`is_priority` `:258-259`, `step_effort` `:185-193`, `lead_suggestion` `:509-510`, `_suggest` `:884-921` (çekme sırası),
`_lead_area` `:862-881`, `_weakest` `:832-847`, `open_cards` `:850-859`, `quarter_pm` `:563-568`, `quarter_goal`
`:571-575`, `pm_plans` `:582-606`, `_impact` `:809-823`.

**Veri** (`sprint.json`): `sprint_weeks` `:2`, `sprint_lengths` `:3` (silinir), `effort` `:6`, `fix_effort` `:7`,
`shares`/`roles` `:8-19`, `role_areas` `:20`, puan ve uyum `:21-25`, `cap_ceiling` `:26`, `lead` `:28`, `faulty_chance`
`:29`, `promise` `:30`, `pm` `:40`, `decision` `:41` ("1" silinir), `paper` `:42-49` (×5), `incident.fix` `:54-57`,
`paid_plan` `:78`, `impact` `:79`, `areas` `:132-139`; hat profilleri `data/product/lines/`'a.

**Öbür sistemler:** hata deposu `ProductState.add_bugs` `product_state.gd:210`, `clear_line_bugs` `:218`, `line_bugs`
`:180`, `open_bugs_by_line` `:176`; destek yeni kod terimi `support_system.gd:37`, `:156-162` (silinir), `NEGLECT_BUGS`
`:86`, `:283` (×k); `_regression_line` `incident_system.gd:351-366` sürüm kaydının `faulty`'sini okur (D kaçan ve
gönderilen hatanın hatlarını yazar), hata girdisi `:76`; B2B memnuniyeti `b2b_sales_system.gd:155-156`, `account_bugs`
`:171` (C'nin "Açık hata" satırı yerini alır); ekip `focus_mult` `hr_constants.gd:184-185`, `MAX_JOBS_PER_PERSON` `:142`,
`can_hold_area` `:253`, uymayan iş morali adlı seam ile; Atlas `hr_atlas_modal.gd:343`; `release_clock` `time_manager.gd:359`.

**Olay motoru:** `sprint_card_test` `effects.gd:482-487`, çipi `chips.gd:114-119` (TR "Hesap Planı'nın testi yarıya iner."
· EN "Account Plan's testing is cut in half."); seam'ler `seams_product.gd:273-274`, `:198-202`, `:227-229`, `:43`
(`urun.sprint_last_week`); kâğıtlar `promise_due`, `sprint_founder_test_pile`, `sprint_test_too_much`,
`sprint_untested_own_code` (bedeller ×5), `team/demo_day`. Gönder sorusu yeni kart; `_vocabulary.md` ve manifest üretilir.

**Arayüz:** `sprint_panel.gd` (`_center` `:65`, süre seçicisi `:75-81` silinir, ekip satırı `:96`, `_member` `:201-210`,
`_lead_row` `:386`), `sprint_card.gd` (atama ve bonus satırları), `product_model.gd` (`weeks` `:299`, `_quarter`
`:411-434`, çeyrek uzunluğu `:431`, `_goal` `:439`), `quarter_view.gd` (`_goal_strip` `:83`, seçici `:111-137`),
`product_tab.gd:252-275` (`weeks` eylemi `:262` silinir, devret `:259` kilit nedeniyle). Ofis `office_people.gd` `role_of`.

**Araçlar:** `run_probe.gd:963-1003` (`_plan_the_sprint`), `:1006-1040`, `:1045-1075`, `PROBE FIX` `weeks=` `:347`; bot
sprint başına eylem sayısını basar. `sprint_probe.gd`: ekip fikstürleri, `PRED`/`CLOSE`. Fikstür `main.gd:3556`
(`set_weeks(1)`). Smoke: `endgame_smoke.gd:479-480` ve bozulma vakası `:16260-16351` yeni modele; `set_weeks` çağıranlar
(`:19946`, `:20330`, `:20739`, `:20875`, `:20989`, `:21098`) ve `decision.sprint_chance`'ı süreyle okuyanlar
(`:18499-18500`, `:20260-20337`, `:20763-20826`, `:21086-21098`) tek süreye iner.

**Kayıt ve belgeler:** `save_manager.gd:16`, göç, `reset_all_owners`; `HARITA.md` Ürün ve Ekip; `CLAUDE.md` §6 (karar
kâğıdının "1 haftalık sprintte başlarken"i, söz olayının `escape_chance`'i); `GDDs/GDD — ZAMAN MODELİ.md:211`;
`GUNCELLEMELER.md:223`, `:345`; motor md §27 ve `:2753`; `docs/ACIK_ISLER/ISLER.md`; Ekip GDD'nin Test alanı cümlesi.

## 7. Kapsam dışı
- Memnuniyet, "Açık hata" satırı, istek kâğıdı, Hesaplar, sunucu, giderler (C); alan puanı ve beklenti (Q); pazaryeri
  modülleri ve ikinci ürün (E; D yalnız arzı onlara açık tutar).
- **EA takımı ertelendi** (QCD D5): EA'nın ilk sürümüne girmez; model `D_MODEL_v3` §3.14 ve inceleme notu madde 5,
  ölçüm `D_SIM_v3` §8.5. `coordination_for_lead` (`hr_constants.gd:1041`) okuyucusuz kalır.
- Kurucunun kalibrasyonu (QCD D3). Moralin onarımı, izin, eğitim, verim eğrisi (ayrı Ekip işi). Zorluk kadranı, kayıp
  ekranı, Series A doruğu, saatin kararlardan sonra sürmesi (`ACIK_ISLER.md` 4, 5, 7, 14).
- Kâğıt havuzunun büyümesi ve çok sprintlik büyük işler (`ACIK_ISLER.md` 12, 13); D yalnız var olan kâğıtları ölçer.
- Kâğıdın bekleyen kartı o hafta durdurması (RAPOR_B §1 madde 7): başka oturum düzeltiyor; D yazmaz, commit'li hâli korur.

## 8. Çalışma biçimi ve adım tablosu
**Başlama koşulu**
- **Koda başlama:** C'nin sonuç raporu (`docs/tasks/faz_cde/RAPOR_C.md`) vardır, içindeki son commit `git log`'da görünür;
  raporda ❌ varsa önce Erdem'e sorarsın. RAPOR_B §1 madde 7'nin düzeltmesi (`sprint_system.gd`, `sprint_probe.gd`,
  `endgame_smoke.gd`) commit'lenmiş olmalıdır; `git status`'ta bu dosyalar kirliyse durur, Erdem'e sorarsın.
- **Önce yapılabilenler:** Q kod yazarken yalnız Godot'suz işler: D0t (salt okuma harita; g₀ önerisi Q'nun raporundan
  sonra), D0s (yalnız `python -I`), W. M ekranlıdır: Q'nun raporundan sonra, C1 başlamadan, C'nin C0m'iyle sırayla ve
  Erdem oynamıyorken koşar. Sonra E1. Hiçbiri oyun dosyalarına, `strings.csv`'ye, `data/`'ya yazmaz; her şey
  `docs/tasks/faz_cde/d_taslak/` altında. Bitince Erdem'e "W, M, D0s ve harita hazır, C'yi bekliyorum" dersin.
- **Ortak dosyalar** (sıra Q → C → D; D, C'nin son hâlini okur): `sprint_system.gd` (Q `push_axes` çağrısı, C kesinti
  tablosu), `sprint.json`, `strings.csv`, `save_manager.gd` (şema 18 Q, 19 C, 20 D), `run_probe.gd`, `endgame_smoke.gd`,
  `sprint_catalog.gd` ve `sprint_bridges.gd` (C istek verisi; D istek kartı ve öneri), `product_model.gd`, `product_tab.gd`,
  `incident_system.gd` (C `load_mult`; D `:76`, `_regression_line`), `support_system.gd`, `hr_constants.gd` (C maaş bandı),
  `hr_atlas_modal.gd` (C masa tavanı), `customer_rep_system.gd`, `b2b_sales_system.gd`; Q'nun `level`'ı ve `area_row`'u.

**Genel kurallar**
- Önce adım tablosu ve Erdem'in onayı. Tek klasör, doğrudan `main`, worktree yok. Push yalnız Erdem "push et" deyince,
  öncesinde tam smoke yok. Commit mesajı `Faz D Dn: ...` ile başlar. `git checkout -- <yol>` yasak; yalnız kendi
  değişikliğin commit'lenir, editörün `project.godot` ve tema farkı değil. Erdem oyun oynarken ağır iş açılmaz.
- **Kayıt şeması** bugün 17; Q 18'i, C 19'u, D 20'yi alır. D1 başlarken `save_manager.gd:16`'yı okur; 19 değilse durur.

**Her commit'in akışı:** Sonnet kodlar (xhigh, büyük dilimde max) → Haiku kapıları koşar, ekranı çeker (CLAUDE.md §11) →
Opus kıdemli inceleme, diff ve kareler, düzeltme hakkı → commit. Commit başına en çok 1 inceleme ve 1 düzeltme turu.

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| D0t | §6 haritasının taslağı (salt okuma, Godot yok), g₀ önerisi (Q'nun raporundan) | Alt ajan | Sonnet | yüksek | 40 dk | Q ve C beklenirken yapılır |
| D0s | Simülasyon (§5 madde 1): atama, PM eşlemesi, sabit 2 hafta ve çekme; kadro dilimi 8 ile 40; söz kartının sırası | Alt ajan | Sonnet | xhigh | 1 sa 30 dk | Kural koddan önce ölçülür |
| W | Yazım dalgası: §3'ün bütün metinleri, atama ve "Sırada" satırları, gönder sorusu, derinlik kartı adları (hat başına ≥ 6) | Alt ajan | Opus | yüksek | 1 sa 30 dk | Yazım kalitesi |
| M | Plan ekranı maketi, oyunun kendi arayüzüyle (1, 6, 50 kişi; şerit, cümle, kart başına atama, "Sırada", hedef, kilitli ve açık devret). `UiFactory` ve `menajer_theme` ile kurulan, `class_name` taşımayan, `-s` ile koşan betik `d_taslak/`'ta | Alt ajan | Sonnet | xhigh | 2 sa | Erdem arayüzü koddan önce görür |
| E1 | **Erdem durağı:** W, M kareleri, D0s tablosu, g₀, §10'un iki kalan sorusu | Ana | Opus (ana) | orta | Erdem'e bağlı | Arayüz, metin ve kural onayı |
| D0 | Haritanın Q ve C'nin gerçek adlarıyla tazelenmesi; §4.4 madde 1'in taban koşusu (C'nin son commit'inde); probun ekip fikstürleri ve `PRED`/`CLOSE` alanları; plan süresi ölçümü | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 2 sa 30 dk | Ölçüm altyapısı |
| D0v | Haritanın doğrulanması | Alt ajan | Opus | yüksek | 15 dk | Kopukluk kod yazılmadan yakalanır |
| D1 | Ölçek ×5, kart ihtiyacı ve iş profili, Düzeltme alanları; sabit 2 hafta (seçici, `set_weeks`, kâğıt ihtimali, `team.demo_day`, fikstür ve smoke çağıranları); kayıt göçü, şema 20 | aynı | aynı | **max** / düşük / yüksek | 4 sa | Kayıt riski |
| D2 | Hafta oynatması: uyum, kadro, aşama sırası, Karar 4'ün ataması, kurucu tabanı ve güçlü alan, aşama tavanı, erken kapanmama ve çekme; tahmin = sonuç | aynı | aynı | **max** / düşük / yüksek | 8 sa | En büyük dilim |
| D3 | Hata: yük, yakalama, kendi kartı, kart tohumu, Düzeltme işi, kaçan hata, `faulty` ve yeni kod teriminin silinmesi, bozulma bağı | aynı | aynı | **max** / düşük / yüksek | 4 sa 30 dk | Tahmin = sonuç yükü |
| D3b | Gönder sorusu: kapanış akışı, bağlı kip varsayılan ve eşikli ayar, kesinti sırası, sürüm notu satırları | aynı | aynı | xhigh / düşük / yüksek | 3 sa | Olay motoru |
| D4 | PM hazırlığı: kuyruk, hız eğrisi, büyük karttan başlayan PM eşlemesi, kart başına fayda | aynı | aynı | xhigh / düşük / yüksek | 3 sa 30 dk | QCD Atama |
| D5 | Ekip ekranları: Atlas aşama hızları, Görevler matrisi uyarısı, uymayan iş morali ve atama koşulu | aynı | aynı | xhigh / düşük / yüksek | 2 sa 30 dk | Görsel kabul |
| D6 | Plan ekranı: şerit, darboğaz cümlesi, kart başına atama ve bonus, "Sırada", kart zinciri, kişi yükü ve aşama özeti, test satırları | aynı | aynı | **max** / düşük / yüksek | 5 sa | UI kanunu |
| D7 | Düzeltme kartı oranı ve A'nın sınırlarının k ile ölçeklenmesi | aynı | aynı | xhigh / düşük / yüksek | 2 sa | A'nın sabitleri |
| D8a | Öneri kuralı ve bot (tek öneri, atlayarak doldurma; çekme sırası aynı) | aynı | aynı | xhigh / düşük / yüksek | 2 sa 30 dk | Bot = oyuncu |
| D8b | Çeyrek hedefi PM'siz, "Hatalar"; devretin PM şartı ve kilit nedeni, devret önerisi | aynı | aynı | xhigh / düşük / yüksek | 2 sa | Risk 3 |
| D8c | Derinlik kartları: kural, veri, adlar (W'den), azalan kazanç | aynı | aynı | xhigh / düşük / yüksek | 5 sa | Arz |
| D8d | Hesap isteği kartı (C'nin 3★ istek akışıyla) | aynı | aynı | xhigh / düşük / yüksek | 2 sa | C bağı |
| D9 | Ölçüm: §4.1, §4.2, §4.3 tabloları, kâğıt kapısı dahil (commit yok) | Alt ajan | Sonnet | yüksek | 3 sa | Kabul |
| R | Sonuç raporu | Ana | Opus (ana) | orta | 20 dk | Rapor kuralı |

Toplam yaklaşık 57 saat ajan süresi; Erdem'in bekleme süresi dahil değildir. En büyük risk D2 ile D3'ün birleşimidir:
atama, çekme, kart tohumlu hata ve sprint içi düzeltme tahmin = sonuç kapısının yükünü artırır; D0'ın probu kapıdır.

## 9. Q ve C ile aynı ağaç
Başlama koşulu ve ortak dosyalar §8'in başındadır.
- **Q ile:** alan puanı ve beklenti Q'nundur. D derinlik kartının kazancını Q'nun alan puanına çarpanla yazar; eksen
  okumaz (Erdem Q1: ürünün tek kalitesi alanlardır).
- **C ile:** "Açık hata" satırı, istek kâğıdı, Hesaplar ve sunucu C'nindir. D, C'ye üç adlı okuma verir: hattıyla açık
  hata, sürümde gönderilen bilinen hatanın hatları, istek kartının teslimi. Kesinti tablosunu C kurar; D gönder sorusunu
  sprint kâğıdıyla istek kartı arasına yazar. İsteği yalnız 3★ ve üstü hesapların yapması (QCD C6) C'nindir; D istek kartını ve bağlı kipi bundan okur.
- **B ile:** D, B'nin kâğıt motorunu, kesinti sırasını, "Sprinti durdur"u ve son gece kuralını korur (Karar 11);
  değiştirdiği B satırlarını (`escape_chance`, `payers`, `_speaker`, 1 haftalık zar, `team.demo_day`) raporda adıyla yazar.
  Kapattığı B soruları: 13 (PM'in yapım kutusu yok, Karar 2) ve 4 (kaçan hata sürüm kaydına yazılır, Karar 6).

**R raporu** `docs/tasks/faz_cde/RAPOR_D.md`: ✅ / ⚠️ / ❌ ve kanıt; onay bekleyen sabitler ve metinler; commit listesi;
§4.1 ile §4.3 tabloları ve komutları; RAPOR_B §1 madde 1, 3 ve 4'ün yeni sayıları; E için adlı okuma noktaları (hat
profili, arz kaynakları, k). `docs/tasks/faz_cde/` izlenmez ve commit'lenmez.

## 10. Erdem'in cevapları (2026-10-18)
1. **Gönder sorusu ne zaman?** Önerildiği gibi: yalnız söze, isteğe ya da tarihe bağlı kartta; varsayılan bağlı kip,
   eşikli kip ayar olarak durur (QCD D1; Karar 7).
2. **Birden çok PM'de fayda kimin yıldızından?** Kartı hazırlayanın; büyük kart iyi PM'e, küçük kart daha az yıldızlı PM'e,
   aynı kural bütün ekipte (QCD Atama; Karar 4 ve 8). "Fayda en iyi PM'den" kalktı.
3. **Kurucunun işinin %10'a kadar düşmesi?** Onaylı; kurucunun kalibrasyonu sonraya (QCD D3; Karar 5).
4. **Sprint düzeni ve tek kurucuda %6,6?** Sprint sabit 2 hafta, erken kapanmaz, ekip sıradakini çeker; %6,6 süreyle
   birlikte kapandı. Çeyrek hedefi PM'siz seçilir, devret PM'siz açılmaz (QCD D4; Karar 11 ve 12).
5. **EA takımı?** Ertelendi (QCD D5; §7).
6. **Kendi kartını test eden daha az bulsun mu?** Onaylı: ×0,6, kurucu dahil; çıkan hata geliştiricinin yıldızına ve işin
   büyüklüğüne bağlı (QCD D6; Karar 6).

### Kalan sorular (E1 durağında sorulur)
1. **Kadro dilimi 8 mi, 40 mı?** Öneri: 8 kalsın (ölçülen değer); büyük kartın aşamasına 2 ya da 3 kişi girer, en iyiler
   orada toplanır. D0s iki değeri 1 ile 50 kişide karşılaştırır. Oynanış: 40 her aşamaya tek isim koyar, okunuş netleşir
   ama 25 kişiden sonra kart arzı yetmez ve ekip boşta kalır.
2. **Söz verilmiş küçük kart en iyi kişiyi beklesin mi?** Öneri: söz ya da tarihli kart atama sırasında büyüklükten önce
   gelir, öbür kartlarda Erdem'in kuralı aynen işler; D0s iki sırayı ölçer. Oynanış: söz verilen iş zayıf kişiye düşüp
   kaçmaz, saati durduran söz olayı seyrekleşir; bedeli büyük işin biraz yavaşlamasıdır.
