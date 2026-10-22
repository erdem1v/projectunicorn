# Faz A · Görev · Hatalar ve hata gösterimi
2026-10-16 · Sahip: Erdem · Bu belge **ne beklediğimizi** söyler: çıktı ne olmalı, oyuncu ne görmeli, nasıl görmeli,
neyle kabul edilir. Nasıl yapılacağına uygulayıcı ajan karar verir.

## Bu belgeyi alan ajana
- Faz A'nın uygulama sorumlusu sensin. İşi alt ajanlarla yürütürsün; modeller §8'dedir.
- **İlk iş:**
  1. Bu belgeyi ve §0'daki ekleri oku.
  2. Erdem'e adım tablonu ver. Sütunlar: Adım | Ne | Kim | Model | Düşünme | Süre | Neden.
  3. Onayını bekle.
  - §8'deki tablo başlangıç noktasıdır. Değiştirirsen gerekçesini yaz.
- **Erdem'e döndüğün üç yer:**
  1. adım tablosunun onayı,
  2. E1 durağı,
  3. son rapor (R).
- Bunların dışında sormadan ilerlersin.
- **"Onay bekliyor" işareti:** Bu belgede "önerildi, Erdem itiraz etmedi" diye geçen her sabit ve kural, kodda ve raporda
  "onay bekliyor" diye işaretlenir (CLAUDE.md §3).
- Faz B aynı çalışma ağacında başka bir ajanda koşuyor olabilir. Ortak kurallar §9'dadır.

## 0. Ekler ve öncelik
Ekler `docs/tasks/faz_ab/ek/` klasöründedir.

| Ek | Ne işe yarar |
|---|---|
| `A_PLAN.md` | Tasarım girdisi. Formüller, dosya:satır başvuruları, commit dilimleri. Opus incelemesinin düzeltmeleri içine "(inceleme)" diye işlendi; incelemenin kendisi `A_INCELEME.md`'de |
| `ERDEM_TUR2_YORUM.md`, `ERDEM_AB_CEVAP.md` | Erdem'in sözleri, birebir. Son cevap `ERDEM_AB_CEVAP.md`'nin sonunda |
| `ORTAK.md` | Fazlar arası sınırlar. İçindeki dosya yolları planlama turuna aittir; yalnız sınırlar için oku |
| `TUR2_SUNUM.md` | Erdem'e gösterilen ikinci tur tasarımı ve reddedilen fikirlerin işaretleri |

**Öncelik ve sınırlar**
- Bu belge `A_PLAN.md` ile çelişirse **bu belge** geçerlidir.
- Plandaki satır numaraları plan günündendir. Kod o günden beri değişmiş olabilir; güncel satırları A1 haritası bulur.
- Proje kuralları `CLAUDE.md`'de, kod haritası `docs/HARITA.md`'dedir.

**`A_PLAN.md`'de geçersiz olanlar** (plandan alınıp kodlanmaz)
1. **Gözde hesap.**
   - Planda hesap adla gösterilmiyor, ipucunda `{stars}★` yazıyordu. Bu geçersizdir.
   - Yerine en büyük etkilenen hesap **adıyla ve koltuk (lisanslı kullanıcı) sayısıyla, kartın içinde** gösterilir.
   - `line_impact` en büyük hesabın kimliğini ve koltuk sayısını döndürür: `{accounts, seats, top_id, top_seats}`.
   - `top_star` alanı ve `PRODUCT_BUGS_TIP_B2B`'deki `{stars}★` kalkar.
2. **İtibar tabanı 0.** Planda itibar `max(0, …)` ile 0'da kesiliyordu. Bu taban kalkar; `GameState`'in kendi alt sınırı
   (−10) geçerlidir.
3. **K5 kapısı "B2B gönderim açık hata ortalaması ≤ 12".** Yerine §2.11'deki iki ölçü ve §4.4'teki düzeltme payı gelir.
4. **"Haftanın hattı" (haftalık kümeleme).** Erdem reddetti: "tamamen random olsun". Şunlar kodlanmaz:
   - A_PLAN:296 ve §5.3 madde 1'deki "yeni hata hattı = haftanın hattı (son iki sürüm × 3 ağırlık)" kuralı,
   - 8. sorunun 2. maddesi,
   - "Haftalık kümeleme" ayarı.

   Yerine Karar 3 ve Karar 4 gelir. Plandaki "kümelemeyle 45 → 25" ölçümü artık geçerli değildir.
5. **Plandaki `fix_all` tanımı** ("en kötü hattın kartını alır"). Yerine §4.4'teki bot kolları gelir.
6. **Şema numarası.** Plandaki "D 17" geçersizdir. Doğru sıra: A 16, B 17. Sonraki numaraları fazlar kod yazdıkları
   sırayla alır.

## 1. Amaç
Erdem'in ilk şikâyeti: "O kadar fazla ticket geliyor ki bug çözme işi neredeyse deliriyor ve anlamsız kalıyor."

Bu fazdan sonra oyuncu:
- hata durumunu **tek bir sayıdan** okur,
- hatanın **hangi hatta** olduğunu görür,
- düzeltme kartını o hat için planlar ve kart kapanınca **o hattın hatalarının gittiğini** görür,
- sprintlerinin çoğunu **yeni iş yaparak** geçirir. Hata düzeltmek sprintin küçük bir parçasıdır. Erdem: "Oyuncuyu sürekli
  bug sprint koşarken görmeyelim."

Hata satışı ve yatırımcıyı doğrudan etkilemez. Hatanın bedeli müşteri kaybıdır (churn). Uzun süre ihmal edilen ürünün
memnuniyeti ve itibarı da düşer.

## 2. Kararlar (bağlayıcı)
1. **Tek sayı.** İki hata sayacı ve bilet defteri tek bir hata deposuna iner. Oyuncunun gördüğü ad: **"Açık hata"**.
2. **Aşınma kalkar.** Hata yalnız iki kaynaktan doğar (Erdem): **kullanımdan** ve **yeni koddan**.
   - Yeni kod, son sürümle gelen değişikliği ve hatalı kapanan kartı kapsar.
   - Yayındaki ürün kendiliğinden gizli hata biriktirmez.
   - Ürün karmaşıklığı hesabı ve ölü kodu silinir.
   - Hata sayısının formülü bugünkü akıştır (`support_system.gd` `reports_per_day`): taban, yeni kod terimi, kullanım ve
     altyapı. Değerleri §5 ve E1'den gelir.
3. **Hata rastgele bir hatta düşer; toplama yok** (Erdem, 2026-10-16: "tamamen random olsun").
   - Her yeni hata kendi başına, tohumlu rastgelelikle, yayındaki hatlardan birine düşer.
     - Yayındaki hat, en az bir canlı özelliği olan hattır.
     - Hatlar eşit olasılıklıdır. Kullanım ya da son sürüm ağırlığı yoktur.
   - Aynı haftanın hataları bir hatta toplanmaz.
   - Kaynak, yani kullanım ya da yeni kod, yalnız hatanın **sayısını** belirler, **yerini** belirlemez. Bu yüzden hata
     kaynağını taşımak gerekmez.
   - **Tek istisna hatalı kapanan karttır.** Onun hatası kartın kendi hattına düşer. Bu, tur 2'de onaylanan "hata bozulan
     hatta düşer" kuralıdır. Ortak yönetmen bunu Erdem'e ayrıca bildirdi.
   - Yayında hiç hat yokken doğan hata, bugünkü gibi v1.0'a saklanır.
4. **Sürekli hata sprinti yok** (Erdem, 2026-10-16: "Oyuncuyu sürekli bug sprint koşarken görmeyelim").
   - **Beklenen sonuç:**
     - Hatalarını düzenli düzelten oyuncu, sprint kapasitesinin küçük bir kısmını düzeltmeye ayırır.
     - Sprintlerin çoğu yeni işle geçer.
     - "Hata sprinti", kapasitenin yarısından fazlasının düzeltmeye gittiği sprinttir. Bu seyrek olur ve iki hata
       sprinti arka arkaya gelmez.
   - **Rastgele dağılımın etkisi:** Hatalar dağıldığı için birçok hatta 1–2 hata görünür. Bu, oyuncuyu her hat için
     hemen kart açmaya zorlamamalı.
   - **Bugünkü acil kuralı:**
     - 3 ve üstü hatası olan hattın kartı "Acil" olur ve eforu 2'dir.
     - Bot planlayıcı acil kartları zorunlu alır (`sprint_catalog.gd`, `must` listesi).
     - Rastgele dağılımda bu kural çok sayıda acil kart üretebilir. Acil eşiği ve zorunluluk bu hedefe göre yeniden ele
       alınır.
   - **İki "acil" karışmaz.** Düzeltme kartının "Acil" etiketi, B'nin "acil durum" olayıyla oyuncu metninde karışmayacak
     biçimde adlandırılır [TR/EN onay bekliyor].
   - **Nasıl sağlanacağına ajan karar verir.** Aşağıdakiler örnektir, karar değildir:
     - haftalık hata akışı (§5'in hedefi),
     - bedelin bir birikim eşiğinden sonra başlaması,
     - A_PLAN §5.3.7'deki doğrusal cezanın küçültülerek tutulması,
     - acil eşiği,
     - düzeltme kartının eforu,
     - bunların bileşimi.
   - **Bedel formülleri bu hedefe uyar.** Karar 9 ve 10'daki bedel formülleri, Karar 4'ün hedefine uymak zorundadır.
     A_PLAN'daki toplam tabanlı formüller yalnız katsayı girdisidir.
   - **Yapılabilirlik.** Ajan E1'de, kod yazmadan önce, basit bir hesapla hedeflerin tutup tutmayacağını gösterir:
     - açık hata ≈ hat sayısı × haftalık akış × sprint haftası / 2,
     - düzeltme payı ≈ hatalı hat sayısı × efor / kapasite,
     - tek kurucu: kapasite 2 puan/hafta. 1 puanlık kart, 2 haftalık sprintte kapasitenin %25'i, 1 haftalık sprintte
       %50'sidir.
   - **Bozulmayacak sınırlar:**
     - Düzeltme kartı yalnız kendi hattını temizler (Karar 5). Birden çok hattı silen genel bir kart yoktur.
     - Hata yine rastgele düşer (Karar 3).
     - Hiç düzeltmeyen oyuncu belirgin bir bedel öder (§4.4).
   - Ölçü: §4.4 ve §4.5. Mekanizma ve sayılar E1'de Erdem'e sunulur.
5. **Düzeltme kartı kendi hattını temizler.**
   - Kart kapanınca o hattın açık hataları anında düşer; başka hatta dokunmaz.
   - Liste her kapanışta güncellenir.
   - Kartın sayıları her zaman canlıdır; bayat kopya kalmaz.
6. **Etkilenenler sayıyla yazılır, en büyük hesap adıyla öne çıkar.**
   - **B2B kartı:** "Fatura düzeltmesi · 6 hata · 3 hesap · 140 kullanıcı · en büyüğü Demir Holding (100 kullanıcı)".
   - **B2B hat satırı:** "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı ↑".
   - **Büyüklük ölçüsü:** Sözleşmedir (koltuk ya da lisanslı kullanıcı), yıldız değildir. Öteki hesaplar adla sayılmaz.
   - **B2C:** "5 hata · 300 kullanıcı".
     - Kullanıcı = kitle (Satış'taki "kullanıcı" sayısı) × hattın payı.
     - "Siparişlerin %4'ü" gibi oran yazılmaz.
   - **Uygulama notu:**
     - Kullanıcı sayısı `Customer.seats`'tir, ad `display_name()`'dir.
     - Aday hesaplar şu üç koşulu sağlar:
       - `market_type == "b2b"`,
       - `status` aktif ya da deneme,
       - hattı kullanıyor.
     - "Hattı kullanıyor" için yeni bir yüklem yazılır: `SalesArchetypes.uses_axis(sektör, eksen)`. Eşik `USE_AXIS_MIN`
       0,25'tir [onay bekliyor] (A_PLAN §4.4). Bu yüklem bugün kodda yoktur.
     - B2C kullanıcı tabanını tutan `Customer` aday değildir.
     - En büyük hesap koltuk sayısına göre seçilir. Eşitlikte MRR, sonra kimlik belirler.
     - Hattı kullanan hesapların **listesi** de okunur, çünkü B her hesaba ayrı bedel yazar (§9).
7. **Efor.** 1–2 hata 1 puan, 3–5 hata 2 puan, 6 ve üstü 3 puan [onay bekliyor].
   - Efor kademeleri ve acil eşiği `sprint.json`'da tek ayar olarak durur. E1 cevabı yalnız bu değerleri değiştirir.
   - D gelince rol puanı ölçeğine uyar.
8. **Satış ve yatırımcı hatayı okumaz.** Şunlar artık hatayı okumaz:
   - dönüşüm,
   - toplantı ihtimali,
   - yıldız karışımı,
   - VC sorguları,
   - term sheet uyumu,
   - ürün fonunun geri dönüş koşulu.

   Satış toplantısındaki "açık hatalarınız var" sorusu ve yatırımcının "ürün hata kaynıyor" sorgusu silinir. Erdem:
   "Nereden bilecek?"
9. **Hatanın bedeli churn'dür.**
   - **B2B:** Hesabın kullandığı hatlardaki açık hata, hesabın memnuniyet hedefini düşürür. Var olan Risk → sayaç →
     ayrılma makinesi çalışır.
   - **B2C:** Açık hata yığıldıkça kitle ve ödeyen kullanıcı yavaşça erir.
   - Var olan destek memnuniyet zararı kalır.
   - Bedelin nasıl başladığı Karar 4'e uyar.
10. **İtibar.**
    - **Erdem'in sözü:** Uzun süre düzeltilmeyen hata itibarı düşürür. Negatif itibarı yatırımcının sorgulaması
      doğaldır.
    - İtibar sıfırın altına inebilir; en düşük değer −10'dur.
    - **Negatif itibarı bugün üç yer okur:**
      - VC itibar sorusu (Erdem'in söylediği),
      - anlatı odaklı fonda toplantı ihtimali,
      - B2C kitle büyümesi.
      - Son ikisi var olan itibar kurallarıdır. Kalmaları önerildi, Erdem itiraz etmedi (2026-10-16).
    - İtibar hata yüzünden düşünce oyuncu sebebini bir yerde görür. Hangi yüzeyde görüneceğini ajan önerir: sürüm notu,
      haftalık özet ya da Destek kartı ipucu.
    - **Şimdi yapılmayanlar:** Şu ikisi sonraki VC işidir; `ACIK_ISLER/ISLER.md`'ye not düşülür:
      - "Bunu düzeltmek için ne planlıyorsunuz?" türü takip sorusu,
      - yatırımcı ikna olmazsa anlaşmanın düşmesi.
11. **Hata akışı insanca olmalı.**
    - Her rapor ve hedef iki ölçüyü ayrı ve adıyla verir:
      1. **Haftada yeni hata.**
      2. **Açık hata** (sprint sonunda ve sürüm anında).
    - **Erdem'in tepkisi:**
      - Erdem "haftada 12 bug çok fazla" dedi.
      - Plandaki 12 aslında sürüm anındaki ortalama açık hataydı.
      - Aynı planda haftalık yeni hata, geç B2B'de yaklaşık 11'di.
      - Erdem ikisini de çok buluyor.
    - **Onaylanan mekanizma:** B2B'de akış hesap sayısıyla daha yavaş büyür, çünkü aynı hatayı çok hesap bildirir.
      Değeri onay bekliyor.
    - **Hedef değerler** §5 araştırmasından gelir. Ortak yönetmenin ilk önerisi aşağıdadır; Erdem'in sözü değildir:
      - Her sprintte en kötü hattı düzelten oyuncuda açık hatanın medyanı 5'in altında kalır.
      - Hiç düzeltmeyen oyuncu belirgin bir yığılma görür.
    - **Bilinen alt sınır:** Düzeltme kartı yalnız sprint başında planlanır. Bu yüzden açık hata kabaca haftalık akış ×
      sprint haftası kadardır. Rastgele dağılımda en kötü hattı düzelten oyuncunun açık hatası bunun da üstündedir
      (Karar 4'teki hesap).
12. **Kalkanlar:**
    - Hotfix düğmesi, düzeltme koşusu ve kodu, "Hotfix yayınla".
    - "Kaçırıldı".
    - Bilet başına "ses".
    - "N ticket" metinleri.
    - "Hata yığını" kartı.
    - Destek kartının eylem düğmesi ve gerekçe satırı.
    - Test işinin oyuncu metinlerindeki "canlı hata aşınması" vaadi (`HR_AREA_MEANING_TESTER_QA`, `ONB_SKILL_QA_DESC`).
      Test'in yayındaki ürüne etkisi D'de testçiyle geri gelir.
13. **Görevler matrisi sprinte bağlanır; kimse iki yerde tam sayılmaz.**
    - **Gerekçe:** Erdem'in kopukluk örneği budur: "Sprint sistemi ekibin görevlerini bile okumuyor." Bağın A'da
      kurulması önerildi, Erdem itiraz etmedi (2026-10-16).
    - **Bugün:**
      - Sprint yalnız Ar-Ge'deki kişiyi dışarıda bırakır (`SprintSystem.team()`). Geri kalan herkes, Destek'e atanmış
        geliştirici dahil, sprintte tam sayılır.
      - Ürün kalitesi ise kurucunun işini zaten okuyor (`ProductSystem._founder_on_build`).
      - Matris bir kişiye en çok iki sürekli iş verir. İki işte her işin payı 0,5'tir (`HRConstants.focus_mult`). Ar-Ge
        tek başına tutulur. Masa sayımı bu payı `effective_skill` ile zaten uygular; sprint uygulamaz.
    - **Beklenen:**
      - **Kim sayılır:** Sprintte yalnız Yapım ekibi (`build`) ve Test işini tutan kişi sayılır.
      - **Pay:** Tek işte 1,0, iki sürekli işte her birinde 0,5, Ar-Ge'de 0.
      - **Masa sayımı:** Aynı payı okur. Kimse iki yerde birden tam sayılmaz.
      - **Matrisi okuyanlar:** sprint ekibi, kapasite, plan tahmini, kart ataması (`assignees`, `role_of`) ve masa sayımı.
      - **Kurucu da bu kurala uyar:**
        - Yapım'daki kurucu masada sayılmaz.
        - Yapım ve Destek tutan kurucu iki yerde 0,5 sayılır.
        - İşi olmayan kurucu sprintte değildir ve masada bugünkü pasif ilgiyle sayılır.
        - Sprintte kartı olan kurucu "Boşta" görünmez.
        - Oyun başında kurucu Yapım'dadır (`GameState` başlangıç işi). Bu yüzden ilk sprint boş kalmaz.
      - **Kayıt kuralı:** `_validate_shape` bugün kurucunun iki işini kayıt yüklemede hata sayıyor. Bu kural bağla
        birlikte düzeltilir.
      - **Sprintte kimse yoksa:** Plan bunu söyler ve Ekip'e bağlar. Saat akar. Metin TR/EN onay bekliyor.
    - **Sınır:**
      - A yalnız "kim sprintte ve ne kadar" bağını kurar.
      - Test'teki kişinin hangi aşamaya uyduğu ve puanın role göre hesabı D'nindir. A'da aşama uyumu bugünkü kuralla kalır.
    - **B'nin iki kuralı bu bağa dayanır:** kâğıdı kim konuşur ve acil durumun moral bedelini kim öder.
    - **Bilinen etki:**
      - B2C bot kolu, ödeyen kullanıcı gelince kurucuyu Destek'e taşır. Bunu "sprint puanı işini okumaz" varsayımıyla
        yapar (`run_probe.gd`, B2C kolu).
      - Bu kol yeniden kurulur. `full_run_b2c` ve `run_gate.sh` etkilenir; ekonomi kayması K1 raporunda yazılır.
14. **Kart düğmeleri** ("+", "→", "çıkar") hep sönük görünür, üstüne gelince parlar.
15. **Değişmeyen:** Hiç çalışan yokken ve kurucu izinde ya da eğitimdeyken saat akar (Erdem onayladı).

## 3. Oyuncu ne görecek
Sayılar örnektir [ÇALIŞMA]. Metinler TR ve EN yazılır, tire kullanılmaz ve "TR/EN onay bekliyor" diye işaretlenir.

**Ürün penceresi · Sprint görünümü · hat paneli**
- Alan satırı "N açık hata" der.
- Açık alanda yalnız hatası olan hatlar listelenir, her biri tek satır:
  - B2B: "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı ↑".
  - B2C: "Eşitleme · 5 açık hata · 300 kullanıcı ↓".
- Hatası olmayan hat yazılmaz.
- Rastgele dağılımda birçok hatta 1–2 hata görünebilir. Panel uzun listede de taşmadan okunur.
- Sesler bölümü yoktur.
- Alan cümlesi hatayla çelişmez: "9 açık hata" yanında "sorunsuz yürüyor" yazmaz.

**Düzeltme kartı**
- Kartta şunlar yazar: hat, hata sayısı, etkilenen hesap ve kullanıcı sayısı. B2B'de ayrıca en büyük hesabın adı ve
  kullanıcı sayısı.
- Efor Karar 7'ye göredir.
- Acil etiketi Karar 4'ün sonucuna göre yeniden ayarlanmış eşikte çıkar.
- Sprint sonu önizlemesi "6 hata kapanır" der.

**Sprint planı**
- Ekip listesi ve kapasite Görevler matrisini yansıtır (Karar 13).
- Yalnız Destek'teki kişi ekipte görünmez. Yapım ve Destek tutan kişi yarım payla görünür.
- Kapasite çubuğu buna göre değişir.
- Sprintte kimse yoksa plan bunu söyler ve Ekip'e bağlar.

**Sürüm notu**
- Kart satırı kapanıştaki gerçek sayıyı yazar: "Fatura düzeltmesi · 6 → 0 açık hata".
- Sprint içinde aynı hatta yeni hata düştüyse yine gerçek sayıyı yazar: "9 → 0".
- Sonuç cümlesi: "6 hata kapandı".

**Ofisteki Destek kartı**
- Tek satır: "7 açık hata ›". Tıklayınca Ürün penceresi, en çok hatası olan hattın alanı açık olarak açılır.
- Kartta düğme, yüzde ya da "Doğrulanmış/Gelen" yazısı yoktur.

**Kart düğmeleri**
- Sprint, sonraki sprint ve devreden kartlarda hep görünür ve sönüktür; fare kartın üstüne gelince parlar.

## 4. Kabul ölçütleri
1. **Tek kaynak.**
   - `scripts/`, `data/`, `tools/` ve `localization/` altında, eski iki sayacı ya da bilet defterini okuyan veya yazan
     satır kalmaz.
   - **İstisnalar:** `save_manager.gd` içindeki A göçü (`_migrate_16`) ve şema 15 göç vakalarının fikstürleri.
   - **Aramaya girmeyenler:** Tarihçe belgeleri (`docs/tasks/`, `docs/mockups/`, `GUNCELLEMELER.md`'nin eski girişleri).
   - Kalan her eşleşme raporda gerekçesiyle listelenir.
   - Diğer fazlar için adlı okuma ve yazma noktaları vardır ve R raporunda listelenir (§9).
2. **Hattı temizleme.** Bir hattın kartı kapanınca yalnız o hat sıfırlanır.
   - Kanıt: smoke vakası, falsification ile birlikte.
3. **Rastgele dağılım.** Smoke vakası şunları kanıtlar:
   - Aynı haftanın hataları birden çok hatta düşebilir.
   - Hatalar yayındaki hatlara eşit olasılıkla dağılır. Kanıt: çok tohumlu sayım.
   - Hatalı kapanan kartın hatası kartın hattına düşer.
4. **Churn ve düzeltme payı (bot kolları).**
   - **Kollar.** K5, `RunProbe.PRESETS`'e B2B ve B2C için şu kolları ekler. Preset anahtarı `fix`'tir; `policy` olay
     cevabının anahtarıdır.

     | Kol | Ne yapar | Kimi temsil eder |
     |---|---|---|
     | `fix_none` | Hiç düzeltme kartı almaz | İhmal eden oyuncu |
     | `fix_worst` | Her sprintte en çok hatası olan hattın kartını alır | Makul oyuncu |
     | `fix_due` | Her sprintte, Karar 4'teki mekanizmaya göre bedeli başlamış bütün hatların kartlarını alır. Mekanizma bedeli eşiksiz başlatıyorsa ajan "düzeltilmesi gereken hat"ı E1'de tanımlar | Titiz oyuncu |
     | `fix_off` | `fix_worst` ile aynı; yalnız bir debug ayarı hatanın churn, memnuniyet ve itibar etkisini sıfırlar | Taban. Ayar harness değişikliğidir, ayrı raporlanır |

   - **Kurulum önerisi** (ajan başka yol seçerse gerekçesini yazar):
     - Bot bugün planı `SprintSystem.apply_lead()` ile kurar.
     - Liderin zorunlu listesi acil kartları ve en zayıf alanın en iyi kartını alır. Bu kart da bir düzeltme kartı
       olabilir (`sprint_catalog.gd`).
     - Bu yüzden kol şu sırayla kurulur:
       1. Liderin planı kurulur.
       2. Bütün düzeltme kartları çıkarılır.
       3. Kolun düzeltme kartları önce eklenir.
       4. Kalan kapasite liderin kuralıyla doldurulur.
     - `SprintSystem.add` kartı `cap_ceiling` ya da `_takes` yüzünden reddederse bot bu sınırı bot tarafında aşabilir.
       A_PLAN 4.5'teki "FIXBOT" denemesi bu yüzden düşmüştü.
   - **Acil durum kartında botun seçimi.** Bot seçeneği etikete göre değil, fiile göre seçer. B gelince kollar şöyle
     seçer:
     - `fix_none`: "Sonraki sprinte bırak". Bu seçenek kilitliyse ilk açık seçenek.
     - Öbür kollar: "Sprinti durdur, şimdi düzelt".
     - Bu kuralı B kurar. A, kolları buna açık bırakır.
   - **Koşu:** Her kol 104 hafta, tohum 7 ve 11 ile koşulur.
   - **Tanımlar:**
     - **Düzeltme payı:** Sprint başladığı anda sprintteki düzeltme kartlarının `remaining` toplamının, o andaki
       `SprintSystem.capacity()` değerine (plan kipinde) oranı.
       - B'nin acil durum kartı da düzeltme yükü sayılır.
       - Bot her sprint başında bir `PROBE FIX` satırı basar.
     - **Hata sprinti:** Düzeltme payı %50'nin üstündeki sprint.
     - **Kayıp:**
       - B2B'de koşu boyunca ayrılan hesap sayısıdır, B2C'de kitle farkıdır.
       - İki pazarda da MRR farkı ayrıca verilir.
     - **Erken biten koşu:** 104 haftadan önce biten koşu, bittiği haftaya kadar sayılır ve tabloda işaretlenir.
   - **Beklenen** [hedefler önerilir, onay bekliyor; E1'de kesinleşir]:
     - **Churn:**
       - `fix_worst` kolunun kaybı `fix_off`'tan en çok %10 fazladır.
       - `fix_none` kolunun kaybı `fix_off`'un en az 2 katıdır.
     - **Düzeltme payı, geç dönem** (v1.0'dan 20 hafta sonrası):
       - `fix_worst` kolunda medyan en çok %15'tir.
       - `fix_due` kolunda medyan en çok %25'tir.
       - `fix_due` kolunda hata sprintleri sprintlerin en çok %10'udur.
     - **Düzeltme payı, erken dönem:**
       - Tek kurucuda 1 puanlık kart bile kapasitenin %25 ile %50'sidir. Bu yüzden erken dönemin hedeflerini ajan E1'de
         önerir.
     - **Her dönemde:** `fix_worst` ve `fix_due` kollarında arka arkaya iki hata sprinti olmaz.
5. **Akış tablosu.** Rapor üç tablo içerir:
   - (a) haftada yeni hata,
   - (b) açık hata,
   - (c) düzeltme payı ve hata sprinti oranı.

   **Kurallar:**
   - Her tablo şu ayrımlarla verilir:
     - B2B ve B2C,
     - erken dönem (v1.0 sonrası ilk 20 hafta) ve geç dönem,
     - dört kol,
     - tohum 7 ve 11.
   - Medyan (a) ve (b)'de haftalık örneklerden, (c)'de sprint örneklerinden alınır.
   - Hedef tutmazsa sabit sessizce değiştirilmez.
     - Ajan durmaz; K6–K8 sürer.
     - Ölçüm tabloları ve öneri R raporunda "onay bekliyor" altında Erdem'e gider.
6. **Tahmin ile sonuç.**
   - (a) **Sprint probe.**
     - K1'den önce şu koşu bir kez yapılır: `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1`.
     - Adlı uyuşmazlık listesi rapora yazılır.
     - Her dilimden sonra adsız uyuşmazlık 0'dır. Adlı uyuşmazlıklar bu listeden artmaz.
     - Karar 13'ün getirdiği yeni bir ad varsa gerekçesiyle yazılır.
   - (b) **Yeni smoke vakası `sprint_fix_preview_matches_close`:**
     - Önizleme N der.
     - Sprint içinde o hatta yeni hata düşmezse kapanış N hata siler.
     - Düşerse kapanış hattın o anki sayısını siler ve sürüm notu gerçek sayıyı yazar.
   - (c) Başlamamış kartın sayısı yenilenir. Koşan kartın eforu kilitlidir.
7. **Kayıt.**
   - Şema 15 kayıt açılır ve hata sayısı yeni depoya taşınır.
   - Bekleyen VC `bugs_under` geri dönüşü yeni koşula ("En zayıf eksen > 40") çevrilir. Göç sonrası kayıtta `bugs_under`
     kalmaz.
   - Kanıt: göç vakaları (`save_v15_*`).
8. **İtibar.** Smoke vakası `neglect_reputation_below_zero`:
   - İhmal senaryosunda düzeltme yoktur ve akış sürer. Bu senaryoda itibar, Karar 4'e uyan kuralla düşer ve −10'da durur.
   - Düzeltme kartları hatları temizleyince düşüş durur.
   - İtibar sıfırın altındayken VC itibar sorusu açılır.
   - Kural ve eşik raporda "onay bekliyor" diye yazılır.
9. **Kurucu.** Smoke vakası `founder_not_double_counted` üç durumu ayrı ölçer:
   - Yapım'daki kurucu masaya ve `destek.desk_staffed`'e girmez.
   - Yapım ve Destek tutan kurucu iki yerde 0,5 sayılır.
   - İşi olmayan kurucu sprintte değildir ve masada pasif ilgiyle sayılır.
   - Masanın boş hâlinin ofis karesi rapora konur.
10. **Görevler matrisi.** Smoke vakası üç durumu ayrı ölçer:
    - Yalnız Destek'teki geliştirici sprintte 0 sayılır.
    - Yapım ve Destek'teki geliştirici 0,5 puanla sayılır.
    - Atama geri alınınca kapasite eski değerine döner.
    - Plan tahmini her üç durumda kapanışla eşleşir.
11. **Olay kapıları.** Şunlar temiz geçer:
    - `--event-lint`,
    - `loc_residue`,
    - `plausibility_run.sh` (`fails=0`),
    - `run_gate.sh` (üç koşu bir sonla biter, sıfır `ERROR`).
12. **Görsel kabul** (CLAUDE.md §11). Kareler TR, EN, renk körü paleti ve 1,25 ölçekte çekilir. Taşma, kesilme ve log
    hatası olmaz.
    - **Destek kartı:** `--office-shot=<ofis>:<saat>:desk_shut`. Bu çekim silinmez, yeni karta göre yeniden kurulur.
    - **Yeni fikstürler.** Şunlar için yeni `--product-shot=edge:<ad>` fikstürleri yazılır ve adları HARITA'ya eklenir:
      - hat paneli (B2B, B2C),
      - 1–2 hatalı çok hatlı uzun liste,
      - düzeltme kartı (uzun hesap adıyla),
      - sürüm notu.
    - **Sönük düğmeler:** `--product-shot=live:active` ve `live:plan`.
    - **Sprint planı:** Destek'e atanmış kişiyle ekip listesi ve kapasite çubuğu. Ayrıca sprintte kimsenin olmadığı hâl.

## 5. Araştırma (uygulayıcı yapar; Sonnet; koddan önce)
**Konu:** Diğer oyunlar hatayı nasıl ele alıyor? Bu, Erdem'in isteğidir.
- **Oyunlar:** Game Dev Tycoon, Software Inc., Mad Games Tycoon 2, Startup Company, Big Ambitions, Game Dev Story ve
  benzerleri.
- **Her oyun için:**
  - hata nasıl doğar (formül),
  - oyuncu kaç hata görür (tipik sayı),
  - nasıl düzeltilir,
  - bedeli nedir,
  - düzeltme oyuncunun zamanının ne kadarını alır,
  - oyun oyuncuyu sürekli düzeltmeye boğmamak için ne yapar (ör. eşik, bakım payı, toplu yama).
- **Kaynak kuralı:**
  - Her satır kaynak bağlantısı ve "arandı / bulunamadı" alanı taşır.
  - Kaynaksız satır "kaynaksız" diye işaretlenir.
  - Bu kural, WebSearch bütçesi bitince sessizce model bilgisine düşmeyi önler.
- **Çıktı:**
  - §2.11'deki iki ölçü için hedef değer önerisi, gerekçesiyle,
  - akış sabitleri için öneri,
  - Karar 4 için mekanizma önerisi ve yapılabilirlik hesabı,
  - §4.4'teki düzeltme payı hedeflerinin gözden geçirilmesi.
- Kısa özet E1 durağında Erdem'e gider.

## 6. Bağlantılar: kopukluk olmayacak
Erdem'in uyarısı: "Ürün akışını sprint sistemine çevirdik, sprint sistemi ekibin görevlerini bile okumuyor. Böyle
kopukluklar olmamalı."

Uygulayıcı kod yazmadan önce bir **bağlantı haritası** çıkarır. Haritada aşağıdakileri okuyan ya da yazan her yer, satır
satır ve yeni karşılığıyla listelenir:
- eski hata sayaçları,
- bilet defteri,
- aşınma,
- düzeltme koşusu,
- hata dağıtımı,
- acil kuralı,
- masa sayımı,
- Görevler matrisi, `team()`, `capacity()` ve `role_of`.

Opus haritayı kodla karşılaştırarak doğrular. Haritada en az şunlar yer alır.

**Sistemler**
- Destek: doğrulama, hasar, ısınma bandı, masa sayımı, `founder_passive_care`, `validation_per_day`'in sprint rolü olmayan
  okurları.
- Sprint:
  - düzeltme kartı, plan tahmini, kapanış, hatalı kart,
  - acil eşiği (`sprint.json`: `urgent_tickets`, `effort.fix`, `effort.fix_urgent`),
  - bot planlayıcının zorunlu listesi (`sprint_catalog.gd`),
  - `team()`, `capacity()`, `assignees`, `role_of`, mesai modalının `week_points`'i, `pm_plans`.
- Ekip:
  - Görevler matrisi ve iş/alan adaptörü (`assign_area`, `AREA_PRIMARY_JOB`),
  - `HRConstants.focus_mult`, `MAX_JOBS_PER_PERSON`,
  - `hr_system.gd` (`founder_task_label` dahil),
  - `character_registry.gd` (`_validate_shape`).
- Ürün kalitesi: `ProductSystem._founder_on_build`.
- Sürüm notu ve köprü.
- Satış (B2B ve B2C).
- B2B hesap yaşam döngüsü ve şikâyet ailesi.
- VC ve term sheet.
- İtibar.
- Kalite okuması (Kararlılık).
- Ar-Ge.
- Zaman yöneticisi ve tohumlar.

**Olay motoru**
- `urun.*` seam'leri.
- `destek.*` seam'leri: `can_start_fix_run`, `fix_run_active`, `desk_staffed`, `warmth_band`.
- Fiiller ve çipler. `effects.gd`'deki `productivity_mod` fiili de dahil; `scope=team` ile `team()` okur.
- Kartlar:
  - `bug_pile`,
  - `b2c_refunds`,
  - `support_overflow`,
  - `wiped_table`,
  - `repeat_reminders`,
  - `urun.axis_stability` okuyan bütün kartlar: `b2c_floor_*`, `launch_leak`, `password_rule`, `shutdown_notice`,
    `b2c_creator_feature`.
- Üretilen ve sabit dosyalar: `_vocabulary.md`, sinyal manifesti, `tools/lint_v3_frozen.json`.

**Arayüz**
- Hat paneli.
- Düzeltme kartı.
- Sprint planı: ekip listesi ve kapasite çubuğu.
- Sürüm notu.
- Destek kartı (build bar).
- Gelen kutusu şikâyet maili.
- Satış'taki Risk rozeti.
- TopBar'daki itibar değeri.
- Ekip iş anlamı satırı ve onboarding beceri açıklaması (aşınma vaadi).
- Ofis: `office_people.gd`. Sprint açılışına kimin yürüdüğünü ve `role_of` üzerinden rol animasyonunu okur.

**Kayıt**
- Şema 16 göçü.
- `reset_all_owners`.
- `GameState.FLAG_TYPES`.
- `SprintSystem.new_state` (`tickets`, `ticket_seq`, `voices_seen`).

**Veri**
- `sprint.json`: `urgent_tickets`, `impact.ticket`, `content.ticket_titles`.

**Araçlar**
- Bot ve probe:
  - `run_probe` artık Hotfix değil düzeltme kartı kullanır.
  - Dört kol eklenir: `fix_none`, `fix_worst`, `fix_due`, `fix_off`.
  - Düzeltme payı ölçülür (`PROBE FIX`).
  - B2C kolunda kurucunun Destek'e geçişi Karar 13'e göre yeniden kurulur.
- `sprint_probe.gd`'nin ekip fikstürü.
- Debug fikstürleri.
- Smoke vakaları.

**Belgeler**
- `HARITA.md`.
- `CLAUDE.md`: §6, §8 ve §12'deki `desk_shut`.
- `GUNCELLEMELER.md`.
- Motor md §27.
- ZAMAN MODELİ tablosu.
- Glossary.
- `ACIK_KARARLAR` 39 ve 45.
- `ISLER.md` C-07 ve INT-9.
- `FRANK_VOICE_INVENTORY.md`.
- `hr_constants.gd`'deki AREA_QA yorumu.
- Ekip GDD'sindeki "canlı aşınma Test alanının işi" cümlesi (GUNCELLEMELER notu).

**Bilinen gerçek (D incelemesinden)**
- Bugün testçisiz kartın %40 hatalı kapanma zarı fiilen hiç atılmıyor, çünkü kurucu her rolü tutuyor.
- A bu ihtimali değiştirmez; onu D değiştirir.
- A yalnız iki şey yapar:
  - hatalı kapanışın hatasını kartın hattına düşürür,
  - yayın öncesindeki hatalı kapanışı v1.0'a saklar.
- Karar 13'le kurucu artık her rolü tutmayabilir. Bu durumda zarın atılıp atılmadığı değişir.
  - A1 haritası bunu kontrol eder.
  - Değişiyorsa K1 raporunda ekonomi kayması olarak yazılır.

## 7. Kapsam dışı
- Acil durum olayları ve yatırımcı hazırlığı (B).
- Genel Bakış, haftalık rapor, sunucu ve doluluk (C).
- Testçi, hatalı kapanış ihtimali, rol puanı ve Test işindeki kişinin aşama uyumu (D).
- Pazaryeri (E).
- VC takip sorusu katmanları (sonraki VC işi).
- Test işinin yayındaki ürüne etkisi A ile D arasında yoktur; A bunu metinde dürüstçe gösterir.

## 8. Çalışma biçimi ve adım tablosu
**Genel kurallar**
- Tek klasörde, doğrudan `main` üzerinde çalışılır. Worktree açılmaz. Commit'ler sırayla gelir.
- Push yok. Push yalnız Erdem'in sözüyle yapılır, öncesinde tam smoke koşulmaz.
- Commit mesajı `Faz A Kn: ...` ile başlar (ör. `Faz A K3: ...`).

**Her commit'in akışı**
1. Sonnet kodlar: xhigh, büyük dilimde max.
2. Haiku kapıları koşar ve ekranı çeker. Görsel dilimlerde kareleri CLAUDE.md §11 listesine göre raporlar.
3. Opus kıdemli inceleme yapar: diff'i ve kareleri görür, düzeltme hakkı vardır.
4. En çok bir düzeltme turu yapılır.
5. Commit.

**İşaretleme ve dokunulmayanlar**
- Tasarım sabitleri "onay bekliyor", metinler "TR/EN onay bekliyor" diye işaretlenir.
- **Sahipsiz editör farkı commit'lenmez.** Bugün `project.godot`, `themes/master_theme.tres` ve
  `themes/menajer_theme.tres` sahipsiz fark taşıyor.
- **Tema üretimi (K7):** İki `.tres` dosyasını baştan yazar. Bu yüzden:
  - üretimden önce `git diff -- themes/` ve iki dosyanın kopyası scratchpad'e alınır,
  - yalnız üretilen tema sahnelenir,
  - `project.godot`'a dokunulmaz.

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| A0 | §5 araştırması | Alt ajan | Sonnet | orta | 25 dk | Akış hedefleri ve Karar 4'ün mekanizması buna dayanır |
| A1 | Bağlantı haritası (§6) ve §4.6(a)'nın taban koşusu | Alt ajan | Sonnet | yüksek | 45 dk | Kod tarama |
| A2 | Haritanın doğrulanması | Alt ajan | Opus | yüksek | 15 dk | Kopukluk kod yazılmadan yakalanır |
| E1 | **Erdem durağı:** A0 özeti, akış hedefleri, Karar 4'ün mekanizması ve yapılabilirlik hesabı, düzeltme payı hedefleri (erken dönem dahil) | Ana | Opus (ana) | orta | Erdem'e bağlı | K5'in kalibrasyonu bu cevaba dayanır. K1–K4 bu sırada ilerler |
| K1a | Kurucu çift sayılmaz | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 1 sa | Masa sayımı |
| K1b | Görevler matrisi sprinte bağlanır; B2C bot kolu ve okuyucular | aynı | aynı | **max** / düşük / yüksek | 2 sa 30 dk | Çok okuyucu, bot ve kapı etkisi |
| K2 | Hotfix, düzeltme koşusu, "Kaçırıldı" ve "Hata yığını" kalkar | aynı | aynı | xhigh / düşük / yüksek | 1 sa 50 dk | Olay motoru sözleşmesi |
| K3 | Tek hata deposu, kaynaklar, rastgele dağılım, şema 16 göçü | aynı | aynı | **max** / düşük / yüksek | 2 sa 45 dk | En büyük dilim, kayıt riski |
| K4 | Düzeltme kartı: efor, etkilenenler, en büyük hesap, sürüm notu; efor ve acil eşiği `sprint.json`'da tek ayar | aynı | aynı | xhigh / düşük / yüksek | 1 sa 40 dk | Arayüz, tahmin eşliği |
| K5 | Etki zinciri, aşınmanın silinmesi, akış ayarı, acil kuralı, dört bot kolu, düzeltme payı ölçümü | aynı | aynı | xhigh / düşük / yüksek | 4 sa 30 dk | Kalibrasyon; sabitler Erdem'e |
| K6 | Hat paneli ve Destek kartı görünümü | aynı | aynı | **max** / düşük / yüksek | 2 sa 40 dk | UI kanunu, görsel kabul |
| K7 | Sönük kart düğmeleri | aynı | aynı | xhigh / düşük / yüksek | 55 dk | Küçük |
| K8 | Ölü kod ve belgeler | aynı | aynı | xhigh / düşük / yüksek | 1 sa 20 dk | Temizlik |
| R | Sonuç raporu (§9) | Ana | Opus (ana) | orta | 20 dk | Rapor kuralı ve B'nin girdisi |

Toplam yaklaşık 21 saat ajan süresi. Erdem'in E1'deki bekleme süresi buna dahil değildir.

## 9. Faz B ile aynı ağaç
**B ne zaman koda başlar?**
- B'nin ajanı senin raporun gelene kadar oyun koduna dokunmaz. O süre içinde yalnız yazım dalgalarını ve okuma işini
  yürütür, sonra durur.
- R raporunu yazınca Erdem'e "A bitti" dersin. B'yi Erdem yeniden başlatır.

**Ağaçta dikkat:**
- Commit'e yalnız kendi değişikliklerini koy. Ağaçta sana ait olmayan değişiklik görürsen dokunma ve commit'leme.
- `git checkout -- <yol>` yasaktır; kirli dosyada başkasının işini siler. Geri alman gerekirse yalnız kendi parçanı elle
  geri al.

**R raporu** `docs/tasks/faz_ab/RAPOR_A.md` dosyasına yazılır. İçinde şunlar bulunur:
1. ✅ / ⚠️ / ❌ listesi ve kanıtı.
2. Onay bekleyen sabitler ve metinler.
3. Commit listesi. Son satır A'nın son kod commit'idir.
4. Diğer fazlar için adlı okuma noktaları:
   - açık hata,
   - hat dökümü,
   - hattı kullanan hesapların listesi, etkilenen hesap ve kullanıcı sayıları,
   - hatalı sürüm (sürüm kaydındaki hatalı hatlar),
   - Görevler matrisi okuması (kim sprintte, payı kaç).
5. B'nin kullanacağı adlı yazma noktaları ve sinyaller. Bunlar A_PLAN'ın "(inceleme)" notlarında tasarlandı ve A'nın
   sözleşmesidir:
   - hatta hata ekleme,
   - hattı yeni hataya kapatma (`line_blocked`),
   - "hat temizlendi" sinyali,
   - hattın düzeltme kartını sprinte koyan ya da başa taşıyan giriş.
6. Bot kollarının tam preset adları ve §4.4 ile §4.5 tablolarını üreten komutlar.

`docs/tasks/faz_ab/` klasörü ve rapor dosyaları commit'lenmez (CLAUDE.md §8). Erdem isterse ayrıca karar verir.
