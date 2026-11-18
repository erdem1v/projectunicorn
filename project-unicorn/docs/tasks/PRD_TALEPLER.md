# PRD · Talepler

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_TALEPLER.md dosyasını oku ve
uygula." Ajan kendiliğinden başlamaz: §15'teki sorular cevaplanır, PRD güncellenir, sonra başlar (Erdem'in süreci, 13 Kasım).
**Durum:** taslak 2, 2026-11-13 gece, OLAYLAR oturumu; bir Opus incelemesinden geçti (bulguların hepsi işlendi). Tur 4 B
tasarımının (`tur4_ekranlar_2026-11-13/talepler/TASARIM.md`) ve Erdem'in 13 Kasım akşam yorumunun
(`tur4_ekranlar_2026-11-13/ERDEM_YORUMU_TUR4.md` §3, §4 OLAYLAR) sonucudur. Kaynak okuması ve ölçümdür; kareler commit'siz bir
prototipten çekildi. Her sayı başlangıç değeridir ve "onay bekliyor" diye iner (§12); sayı ayarı playtest'tedir.
**Tek cümle:** Müşterilerin istediği her şey Ürün › Talepler'de tek listede durur; oyuncu kaç hesabın istediğine ve neyin
tehlikede olduğuna bakıp plana alır, kıt bir paydan söz verir ya da gerekçeli "şimdilik olmaz" der; bekleyen talep adlı bir
memnuniyet bedeli yazar, teslim edilen talep o hesaplardan birkaçını büyütür.
**Çıktı:** main'e yaklaşık 16 commit (14 ile 20; push yok), §14'teki sırayla; her commit kendi kapısı, §9 incelemesi ve görsel
kabulüyle.
**Kapsam:** ERP (B2B) ve pazaryeri. Not ve video ürünleri oyundan kalktı (Erdem, 13 Kasım).
**Prototip:** `talepler/PROTOTIP.diff` görünümün nasıl göründüğünü gösterir; yerleşimi ve metin anahtarları alınabilir, verisi
fikstürdür ve alınmaz (`requests_fixture.gd` uygulamaya girmez). Kare türleri (`--product-shot=live:req_*`,
`--inbox-shot=requests_*`) bu PRD'nin ilk görünüm commit'inde `main.gd`'ye eklenir.
**Dayanak belgeler** (`tur4_ekranlar_2026-11-13/talepler/`): `TASARIM.md`, `C_KOD.md`, `ARASTIRMA.md` (K1–K22, başarısız örnekler
dahil), `ELESTIRMEN.md`, `TESLIM.md`, `kareler/`. Öbür oturumlar: URUN `PRD_ERP.md` ve `erp_tasarim_2026-11-12/MODUL_SEMASI.md`,
PAZARYERI `PRD_PAZARYERI.md` ve `tur4_ekranlar_2026-11-13/pazaryeri/TALEPLER_ICERIK.md`. Depo dosyaları bu belgelere atıf yapmaz.

## Erdem için kısa özet

- **Talepler, Ürün penceresinin dördüncü sekmesidir.** Satırda konu, kaç hesabın istediği, risk altındaki gelir, kayıp satış,
  süre, durum ve geciken hesap sayısı durur. Sırala ve süzgeç var. Liste senin beğendiğin hâliyle kalır.
- **Sağdaki ayrıntı sadeleşti:** modülün adı, üç sayı (isteyen, hesapların geliri, süre), eylemler ve isteyen hesaplar. Risk, kayıp
  satış, rakip ve geciken satırları ayrıntıdan çıktı; listede zaten duruyorlar.
- **"Söz ver" yeniden yazıldı:** düğme "Söz ver · Sprint 42", yanında düz cümle: "Sultanahmet İnşaat hesabına söz: Sprint 42 sonuna
  kadar çıkar. Tutulursa memnuniyet +15; bozulursa memnuniyet −20, marka −3. Plandan çıkarılamaz." (kare B05). Sözü alan hesap
  aşağıdaki listede seçili satırdır.
- **Söz tarihi gerçek bir taahhüttür:** sözlü kart her sprintte en çok payın kadar ilerler, tarih bu hızla hesaplanır. Testte
  çıkan hata ya da müşterinin eklediği kapsam tarihi kaydırır; PM'in hazırladığı kartta müşteri kapsam eklemez.
- **Kilitli satır şartı yazar:** "Kilitli" yerine "2★ Ürün Yöneticisi gerekli" ya da "Önce Veri Modeli araştırılmalı". Düğme
  yanında: "İşe alım" ya da "Ar-Ge". Semantik İndeks bugün Ar-Ge ağacında görünmüyor (kökü bitmeden açılmıyor); soru 5 bunun için.
- **"Bir sürü büyümek istiyor" mesajının nedeni bulundu (§8):** yeni özellikle ilgisi yok. Her memnun hesap 6. haftasında bir kez
  "büyümeye hazır" oluyor ve gelen kutusunda bekliyor; 60. haftada 117 hesabın 98'i. Her hatırlatıcının düğmesi bedava koltuk
  kâğıdını açıyor. Önerim: büyüme yalnız tutulan söz, teslim ve yenilemede doğar, sürüm başına en çok üç hesap, bedeli var; gelen
  kutusundaki büyüme hatırlatıcısı kalkar. URUN'la uzlaşıldı.
- **Modüller işlevle adlandırıldı** (URUN'un şeması): Fatura, Muhasebe, Stok, Satın Alma, Kullanıcılar ve Yetki ... "Çekirdek" yok.
- **ERP müşterileri ERP alan sektörlerden:** emlak ofisi, klinik, yayınevi listede yok (URUN'un sektör listesi, PRD_ERP §4.1).
- **Senden beklenen:** §15'te altı soru: söz bırakılabilir mi, söz kapasitesinin kuralı, derinlik listesi, büyüme kuralı, kilidin
  görünmeyen düğümü, bekleme bedeli kime yazar.

## 0. Kararlar

### 0.1 Erdem'in kararları
- Karar 8 (11 Kasım): gelen istekler tek yerde, isteyen sayısıyla; oyuncu planlayacağını seçer; söz verilen istek zorunludur.
- 13 Kasım: Talepler görünümü, "Plana al · Sprint 9" ve isteyen müşteriler listesi beğenildi. "Söz ver" anlaşılmadı. Destek
  raporundaki "büyümek istiyor" yığını beğenilmedi, izah istendi. Kilitli satır şartı yazar. Ayrıntı paneli sadeleşir. Pazaryeri
  talebinde "eğilim" kalkar. Modüller işlevle adlandırılır, "Çekirdek" kalkar. Not ve video ürünleri kalkar.
- Ortak kurallar (ERDEM_YORUMU_TUR4 §3): uydurma açıklama cümlesi yok; oyuncunun bilemeyeceği bilgi yok; ERP adayının sektörü ERP
  alacak sektör; her sayı neye göre olduğunu söyler; az ve temiz.

### 0.2 Yardımcı yönetmenin kararları
- Ürün penceresinin dördüncü alt sekmesi; sol raya sekme eklenmez. Kalibrasyon playtest'te (GOREV_TUR4 §1b).

### 0.3 Öbür oturumlarla uzlaşılanlar (13 Kasım)
- **URUN:** hesap başına tek açık istek; bekleme bedeli; sözlü işin sabit payı, PM'den bağımsız; "İsteyen ekledi" (§4.3);
  büyüme kuralı ve yenileme kâğıdıyla birleşmesi (§8); modül şeması ve ERP sektörleri; kilit metni PRD_ERP §3.5'te.
- **PAZARYERI:** "Bekleyen konu" ve "Geciken" tanımı ortak; bilet satırının alanları; açıcı `SprintUiShared.open_requests`;
  "Karşılandı"yı Pazaryeri sürüm kaydından kendisi okur; iniş sırası (`ORTAK_ARAYUZLER.md` §3); kayıtta şema numarası yok.
- **Kuralların tek yeri:** istek, söz ve büyümenin kuralları bu PRD'dedir. PRD_ERP §2.5'in "aynı anda en çok iki istek, sprint
  başına bir söz" ve "tutulan söz koltuğu ⌈koltuk × 0,2⌉ büyütür" satırları bu PRD'nin §1, §4 ve §8'ine döner; PRD_ERP onlara atıf
  yapar (URUN'a iletildi).

## 1. Kurallar

- Bir talep bir **konu**dur (bir ürün kartı) ve **isteyen**leri vardır. ERP'de isteyen hesaptır; pazaryerinde isteyen son dört
  haftanın biletidir.
- **Hesap başına tek açık istek.** Hattın kademe isteği ve hesabın acısı (`Customer.pain_feature_id`) tek isteğe döner. Aynı konuyu
  isteyen ikinci hesap yeni satır açmaz, sayacı artırır.
- **İstek pencerede doğar** (bugünkü pencereler, `sprint_bridges.gd:31-39`): imzadan 2 hafta sonra ve yenilemeden 12 hafta önce.
  Bugün süresi dolan istek `late` olup düşüyor (`:28-29`); bu kalkar.
  Açık isteği olan hesap yeni istek açmaz. İstek teslim edilince ya da kapatılınca hesap bir sonraki pencerede yeniden ister.
  Kapatılan konuyu o hesap bir sonraki pencereye kadar istemez; o pencerede acısı başka konuya geçer.
- **Bekleyen konu**: planda, sözlü ya da yayında olmayan konu (Yeni, Bekliyor, Kilitli). Başlıktaki sayı, Bekleyen sekmesi ve
  Pazaryeri › Genel'deki sayı bunu sayar.
- **Geciken**: isteği 8 haftayı geçen, sözü olmayan hesap (pazaryerinde 8 haftayı geçen konu). Satırın kum saatli sütunu, Destek
  raporunun satırı ve bekleme bedeli bunu sayar.
- Söz verilen istek zorunludur; söz yalnız bekleyen konuya, konu başına bir hesaba verilir; sözlü kart planda kilitlidir.
- Hiçbir talep sessizce düşmez: ya yayına çıkar ("Karşılandı"), ya oyuncu "Şimdilik olmaz" der, ya da hesap gider.
- Ayrıntı yalnız kararın gerektirdiğini taşır; liste sütununda duran bilgi ayrıntıda tekrar edilmez (ortak kural 5).

## 2. Model ve kayıt

- **Satır** bugünkü gibidir: `GameState.product.requests`'te hesap × kademe (`id`, `customer_id`, `line`, `step`,
  `created_sprint`, `value`, `status`, `card_id`, `day`). Konuya gruplama okumada yapılır (`ProductModel._requests`). `due_sprint`
  yazılmaz ve okunmaz (eski kayıttaki anahtar yok sayılır). Yeni anahtarlar varsayılanla doğar: `closed_day`, durum `declined`.
  `day` bekleme süresinin başlangıcıdır.
- **Tek yazar `SprintBridges`'tir** (CLAUDE.md §6). Öbür kaynaklar onun seam'lerinden yazar: `open_request(customer, line)` (var,
  `sprint_bridges.gd:66`), yeni `close_request(customer)` ve `add_promise_request(customer, step)`. Kaynaklar: hattın kademe isteği
  ve acı (`tick_requests`), Müşteri İlişkileri masası (`CustomerRepSystem._escalate`), sözün beş kaynağı (§4.2). Pazaryeri
  satırları bu depoya yazılmaz; `MarketplaceSystem.request_topics()`'ten okunur.
- **Söz** satıra girmez, `PromiseRegistry`'de kalır. Açık isteği olmayan hesaba verilen söz (satış görüşmesi) önce
  `add_promise_request` ile satırı açar.
- **Bekleme bedeli ve kapatma izi** hesabın üstünde yeni, affetmeyen, adlı bir alandır: `Customer.request_marks` (konu → puan),
  yazarı `CustomerRegistry.set_request_mark(id, topic, points)` ve `clear_request_mark`. `B2BSalesSystem.satisfaction_target`'a
  ayrı bir terim olarak girer. `trust_offset` kullanılmaz: o tek bir sayıdır, haftada affeder ve sınırını sözlerle paylaşır
  (`b2b_constants.gd:285-287`, `b2b_sales_system.gd:64`, `:181-182`); memnuniyete doğrudan yazılan değer de bir tikte silinir
  (`SAT_DRIFT_STEP`).
- Hesabın acısı haftalık tikte, pencerede ve açık isteği yokken satır açar; eski kayıt da yüklenince ilk tikte aynı yoldan geçer.
- **Kayıt:** şema numarası alınmaz; yeni alanlar varsayılanla doğar. İniş sırasında biçim bozulursa sıradaki numara alınır
  (PAZARYERI'nin kuralı, yardımcı yönetmen onayladı).
- **Konunun kartı:** kademe isteğinde kademenin özellik kartıdır (`feat:<step>`; bugün istek bu kart yayına çıkınca karşılanır,
  `SprintBridges.on_release`). Kademesiz ERP özelliğinde URUN'un kartı (PRD_ERP §2.5). Pazaryerinde PAZARYERI'nin konusu.
- Bugünkü kural "bir kademeye toplamda tek açık istek" (`request_step`, `sprint_bridges.gd:55-62`) "hesap başına tek açık
  istek"e döner.

## 3. Görünüm

### 3.1 Yer ve açıcı
- Ürün › Genel bakış · Sprint · Çeyrek · **Talepler**. Talepler ayrı bir sekme grubudur; Çeyrek'in kilidi Talepler'i etkilemez.
- Sprint görünümünün sol sütunundaki "Müşteri talepleri" bölümü kalkar (`area_panel.gd` `_add_requests`, `ProductModel._due`,
  `PRODUCT_DUE_NEXT_Q`).
- Adlı açıcı `SprintUiShared.open_requests(tree, opts)`: `opts` boş olabilir; `status` (all, waiting, planned, promised,
  shipped), `side` (all, users, stores), `sort`, `topic`. Destek raporu `{status: waiting}`, Pazaryeri › Genel `{status: waiting}`
  ya da bir tarafın satırından `{status: waiting, side: ...}` ile çağırır.

### 3.2 Liste
| Sütun | ERP | Pazaryeri |
|---|---|---|
| Konu | modül ikonu (adı ipucunda), kartın adı, gerekirse "Rakipte var" | iki taraf birlikteyken taraf ikonu (`side/users`, `side/stores`; yeri ipucunda), bir taraf seçiliyken modül ikonu; ve adı |
| İsteyen | "12 hesap" | "61 bilet" (son dört hafta) |
| Risk altında | isteyenlerden yenilemesine 12 haftadan az kalan ya da Risk evresindeki hesapların aylık geliri | yok |
| Kayıp satış | bu konunun modülü eksik diye son 12 haftada kaybedilen aday | yok |
| Etkilenen sipariş | yok | haftada etkilenen sipariş (PAZARYERI'nin tanımı, ipucunda) |
| Süre | ekibin hızıyla kartın süresi ("Yarım sprint") | yok |
| Durum | Yeni · Bekliyor · Planda (Sprint N) · Söz (Sprint N) · kilidin şartı · Yayında | Söz yok |
| Geciken | 8 haftayı geçmiş sözsüz isteyen sayısı, kum saatiyle | konu 8 haftayı geçtiyse haftası |

- **Neden bu sütunlar:** isteyen sayısı kaç hesabın beklediğini, risk altındaki gelir hangi bekleyişin yenilemeye dokunduğunu
  (yalnız sayı yanıltır, K7), kayıp satış eksikliğin satışa bedelini, süre karşı ağırlığı, geciken bekleme bedelinin kime
  yazdığını söyler. Her biri bir kararı taşır; ayrıntıda tekrar edilmez.
- **Risk** oyunun kendi riskini okur: hesabın evresi `risk` ise ya da yenilemesine 12 haftadan az kaldıysa. Sabit bir memnuniyet
  eşiği kullanılmaz; Satış'ta Risk görünen hesap burada da sayılır. Yenileme günü hesabın gelecekteki yenilemesidir
  (`term − (gün − imza) mod term`); `SprintBridges.next_renewal_day` yenileme geçtikten sonra bir sonraki pencereye kadar geçmiş
  günü döndürdüğü için risk onu okumaz.
- **Kayıp satış** bugün alan düzeyinde tutuluyor (`sales_rep_system.gd:239-241`, `sales_ledger.gd:401`). Konuya eşleme URUN'un
  modül şemasıyla gelir: kayıp kaydı modülü taşır, konu modülünün kaydını okur. Eşleme gelene kadar sütun boş kalır.
- Başlık: "8 konu · 54 hesap bekliyor · 1 sözlü" ve söz payı rozeti "Söz payı %25 / %25" (ipucunda kural, sözü tutan hesaplar,
  bu sprintin satış görüşmeleri). Pazaryerinde "10 konu · 8 bekliyor · son 4 haftada 208 bilet".
- Sıralama bir seçicidir: ERP'de En çok isteyen · Risk altındaki gelir · Kayıp satış · En yakın söz; pazaryerinde Etkilenen sipariş
  (varsayılan) · En çok isteyen. Süzgeç sekmedir: Hepsi · Bekleyen · Planda · Sözlü · Yayında; pazaryerinde Sözlü yok, Taraf
  seçicisi var. Üç konuya kadar sıralama ve süzgeç görünmez.

### 3.3 Ayrıntı (sağda)
- Modülün adı, ikon ve konunun adı, durum.
- Üç sayı: ERP'de İsteyen · Hesapların geliri (aylık) · Süre; pazaryerinde Bilet · Sipariş/hafta. Eğilim yok.
- Pazaryerinde tek "neden" satırı: kullanıcı konusunda kaybın olduğu huni adımı (Genel'deki adıyla; Yorum ve Puan'ın `returning` bağı iadeyi ölçer, adı İade), mağaza
  konusunda riskin derdi, ve konunun haftada etkilediği siparişin geçen haftanın teslimine oranı ("Kayıp: Sipariş verdi · haftalık
  siparişin %17 kadarı"). Adımın kendi oranı yazılmaz: o, adımın bütün kaybıdır ve aynı adımdaki iki konuda aynı çıkar. ERP'de neden
  satırı yok.
- Kilitli konuda kilidin bütün şartı ve düğmesi (§3.5).
- Eylemler (§3.4), sonra isteyen hesaplar: Gelir · Memnuniyet · Yenilemeye · Bekliyor; en riskliden. Sözü alacak hesap seçili
  satırdır; oyuncu başka satıra tıklayarak seçer. Sözlü hesabın satırında takvim ikonu, tarihi ipucunda. Uzun hesap adı sarar.

### 3.4 Eylemler
- **Plana al · Sprint N**: kartı sonraki sprintin planına gönderir (bugünkü `send_next`); söz değildir, geri çekilebilir. Çip yok.
- **Söz ver · Sprint N** (yalnız ERP, yalnız bekleyen konu). Yanında cümle: "<hesap> hesabına söz: Sprint N sonuna kadar çıkar.
  Tutulursa memnuniyet +15; bozulursa memnuniyet −20, marka −3. Plandan çıkarılamaz." Tarih §4.1'den çıkar. Pay doluysa ipucu:
  "Söz payı dolu: Dönem Kilidi. Söz tarihi: Sprint 42."
- **Şimdilik olmaz** (yalnız ERP): tek çip "39 hesap · her birine memnuniyet −2"; ipucu "Konu kapanır, bekleme bedeli geri
  alınır. Hesap bu konuyu bir sonraki yenileme penceresine kadar istemez. Kayıtlarına yazılır: Talep kapatıldı: <konu>."
- Planlanmış ya da sözlü konuda tek düğme "Planda gör" ve durum çipi. Kilitli konuda Plana al ve Söz ver görünmez; kilidin düğmesi
  ve Şimdilik olmaz durur. Pazaryerinde yalnız Plana al.

### 3.5 Kilitli satır
- Durum hücresi "Kilitli" yazmaz; kapının ilk karşılanmamış şartını yazar, bütünü ipucunda ve ayrıntıda. **Metnin sahibi PRD_ERP
  §3.5'tir** ("{yıldız} {rol} gerekli", "Toplam Yazılım: 3★ gerekli (ekipte 2★)", "{düğüm} araştırılmalı"); Talepler aynı işlevi
  okur, kendi metnini yazmaz. Düğme: kişi ya da toplam kilidi "İşe alım" (atlası o rolle süzülmüş açar), Ar-Ge kilidi "Ar-Ge"
  (ağacı düğümde açar).
- **Gizli Ar-Ge düğümü.** Dal düğümü ağaçta yalnız kökü bitince görünür (`rnd_system.gd:81-86`, `:475-483`). 60. hafta koşusunda
  Veri Modeli bitmemiş, Semantik İndeks ağaçta yok; kilit oyuncunun göremediği bir düğümü söylüyor. Prototip ağacın gösterdiği
  ilk düğümü yazar ("Önce Veri Modeli araştırılmalı"); hedef düğümün adını açıp açmamak §15 soru 5'tir. Cevap PRD_ERP §3.5'e de
  işler.
- Kilitli konu yalnız modül olan hatlardan doğar: Ar-Ge'nin henüz açmadığı gizli hat (bugün `line_hidden_self_serve`) listede
  görünmez.
- Not (URUN'a iletildi): kişi kapısı tek kişinin becerisini sayar, kurucu dahil (`line_gates.gd:38-58`); tasarımcının ikinci
  becerisi Ürün'dür (`hr_constants.gd:86-88`). "2★ Ürün Yöneticisi gerekli" yazan satır bir tasarımcı ya da kurucu karşıladığında
  da kalkar; rol metni bunu söylemez.

### 3.6 Pano
- Sprint panosunda ve sonraki sütunda konunun kartının satırı isteyen sayısını taşır ("2 hesap"); sözlüyse takvim çipiyle sözün
  son sprinti ("Söz · Sprint 10"; ipucu "Sözlü kart plandan çıkarılamaz"). Talep kartının adı yalnız kademenin adıdır.

## 4. Söz

### 4.1 Pay, hız ve tarih
- **Söz payı:** sözlü iş sprint kapasitesinin sabit bir payını geçmez [örnek %25], PM'den bağımsız.
- **Hız kuralı:** sözlü kart her sprintte en çok payın puanı kadar ilerler (sprintin atamasında kural: kartın o sprintte aldığı
  saat, sprint kapasitesinin payını geçmez; artan saat öbür kartlara gider). Pay birden çok söz arasında paylaşılır.
- **Tarih bu hızla hesaplanır:** pay boşsa tarih = planlanabilir sprint + ⌈süre ÷ boş pay⌉ − 1; pay doluysa söz sıraya girer: tarih =
  son sözün tarihi + ⌈süre ÷ pay⌉. Tarih sıkıdır: testte bulunan hatanın düzeltme işi (bugünkü hata modeli), acil durumun aldığı
  saat ya da müşterinin eklediği kapsam (§4.3) kartı geç bıraktırır ve bugünkü söz olayı (`product.promise_due`) gelir.
- **Neden tavan:** söz geri alınamaz ve planda kilitlidir; tavansız plan sözle kilitlenir. Hız kuralı olmadan ekip kartı tam hızla
  bitirir, söz hep erken tutulur ve zaten yapılacak işe bedava bir ödül olur.
- **Plan kilidi:** sözlü kart sprintten ve sonraki sütundan çıkarılamaz (`SprintSystem.add/remove`), PM'in planı atlayamaz.
- Ödül ve bedel bugünkü söz etkileridir: tutulursa memnuniyet +15, güven +6; bozulursa memnuniyet −20, güven −12, marka −3
  (`b2b_constants.gd:160`, `b2b_sales_system.gd:626`). ERP'de tutulan söz hesabın büyüme isteğini de doğurur (§8.2).

### 4.2 Sözün beş kaynağı
Bugün söz beş yoldan doğuyor; hepsi aynı paydan düşer ve tarihi §4.1'den alır:
1. Talepler'in "Söz ver"i.
2. Talep kâğıdının "Tarih ver"i (`customer.request_feature`).
3. Satış görüşmesinin anlaşma sözü (`sales_finalizer.gd:98`): bugünkü sabit 2 hafta paydan gelen tarihe döner [onay bekliyor,
   §12: görüşmenin dengesini değiştirir].
4. Olay teklifinin sözü (`b2b_sales_system.gd:447-450`).
5. Elde tutma kartının "Söz ver"i (`accept_promise`, `:455`).
Söz şıkkı gerekçesiyle kilitli görünür: pay dolu ("Söz payı dolu: Dönem Kilidi"), konu zaten sözlü ya da planda, konu kilitli,
ya da bu hesapla bozulan sözün 8 haftalık kilidi sürüyor (`b2b_constants.gd:172`).

### 4.3 "İsteyen ekledi" (kâğıt; URUN'un PRD_ERP §3.4'ü bu bölüme verir)
- **Tetik:** sözlü kart Geliştirme aşamasına ilk girdiğinde, kartı PM hazırlamamışsa: kâğıt `product.scope_added` gelir. Hazırlık
  yarımsa olasılık hazırlanmayan payla orantılıdır [örnek: hiç hazırlanmamışta %50]. PM'in tam hazırladığı kartta gelmez.
- **Konuşan:** sözü alan hesabın kişisi (yuva `{customer}`); sabit ad yok.
- **Şıklar** (her birinin bedeli çipte):
  - "Ekleyelim": kartın işi büyür (`sprint_card_effort` +%30 [örnek]), söz tarihi aynı kalır; hesabın memnuniyeti +3. Geç kalma
    riski büyür.
  - "Ekleyelim, tarihi bir sprint kaydıralım": kartın işi büyür, söz bir kez ileri alınır (`promise_extend`, güven −6).
  - "Kapsamı koru": kurucu isteyenle görüşür, kart büyümez; kurucunun bu haftasından görüşme saati gider (fiil yoksa `[VOCAB?]`,
    URUN'un D2 kurulum fiiliyle ortak yazılır), hesabın memnuniyeti −2.
- Satırda "İsteyen ekledi" izi kalır (kartın satırı).

## 5. Memnuniyet

- **Bekleme bedeli:** hesabın sözsüz açık isteği 8 haftayı geçince `request_marks`'a bir kez sabit bir düşüş yazılır [örnek −5].
  Süreyle büyümez, istek başına tektir. Planlı ve kilitli konuda da yazar (plan söz değildir; kilit oyuncunun açabileceği bir
  şarttır); sözlü konuda yazmaz. Kime yazdığı §15 soru 6'dır. Hesabın kaydında, isteyen satırında ve ipucunda adıyla görünür:
  "Geciken talep: Döviz Kurları".
- **Teslim:** kart yayına çıkınca isteyen her hesap bir kez "Karşılandı: <konu>" yazar ve bekleme bedeli `request_marks`'tan
  silinir. Sürüm notu sayıyı söyler ("Karşılandı: Döviz Kurları · 18 hesap").
- **Şimdilik olmaz:** bekleme bedeli silinir, her hesaba daha küçük adlı bir iz yazılır [örnek −2]: "Talep kapatıldı: <konu>". İz
  hesabın bir sonraki yenilemesinde silinir; birikmez (hesapta en çok bir kapatma izi, en yenisi).
- **Çifte sayım ölçülür:** istenen kademe hesabın beklentisindeyse `ProductQuality.account_fit` aynı eksiği zaten düşürür. Bekleme
  bedelinin commit'i önce ve sonra `--run-log` ile hesabın memnuniyet ortalamasını ve kayıp hesabı ölçer; çifte sayım görülürse
  bedel yalnız beklentide olmayan isteğe yazar.
- **Pazaryeri:** bekleme bedeli taraf başına bir kez, en uzun bekleyen konunun adıyla; satırları Pazaryeri yazar (PRD_PAZARYERI
  taslak 2, §3.8 ve §3.11).
- **Zaman baskısı yenilemeden gelir:** yenileme kâğıdı bekleyen talebi adıyla anar; hesabın kararı memnuniyeti okur.

## 6. Kâğıtlar, masa ve Destek raporu (H18)

- **Masa ve liste:** özellik talebi masanın kuyruğuna girmez. Masa (`CustomerRepSystem`) ilişki taleplerini (şikâyet, yenileme
  sinyali) bugünkü gibi işler (`customer_rep_system.gd:248-273`, türler `pick_request_kind` `:328`); özellik talebi doğduğu anda
  listedeki satırdır ve masa onu emmez, yani sessizce düşmez. `_escalate` özellik talebini artık kâğıda çıkarmaz.
- **Kâğıt yalnız iki anda gelir:** (a) bir konu ilk kez istendiğinde `customer.request_feature`, şıkları listenin eylemleridir
  (Tarih ver = Söz ver, Listede olduğunu söyle = listede kalır, Şimdilik olmaz de = Şimdilik olmaz); (b) sözün son sprintinde
  bugünkü `product.promise_due`.
- **Destek raporu:** talepler raporun (`SupportSystem.weekly_report`) bir bölümüdür, yalnız bir şey değişince yazar. İlk satır
  haber: "Bu hafta 9 hesabın talebi 8 haftayı geçti." Sonra konular: "<hesap>: <konu>. Artık 39 hesap istiyor." İkinci düğme
  "Talepleri aç" açıcıyı `{status: waiting}` ile çağırır.
- **Temsilcisiz şirket:** rapor gelmez; aynı haber Ürün rayının sayacına (geciken hesap sayısı) ve Talepler başlığına düşer. İlk
  kez istenen konunun kâğıdı temsilci olmadan da gelir (kurucu masadır).
- **Yenileme kâğıdı:** mekaniği ve şıkları PRD_ERP §4.5'tedir (yenile, büyüyerek yenile, gider); metni OLAYLAR yazar, URUN'un
  yenileme commit'iyle iner. Bu PRD'nin istediği: kâğıt bekleyen talebi adıyla anar, büyüyerek yenile §8.2'nin kuralını okur.
- Şikâyet kâğıtları kalır.

## 7. Pazaryeri

- Satırlar `MarketplaceSystem.request_topics()`'ten gelir (PAZARYERI, `TALEPLER_ICERIK.md`): konu, taraf, modül, son dört haftanın
  bileti, haftada etkilenen sipariş, onun geçen haftanın teslimine oranı (`share`), neden, durum, konunun yaşı, kaynak (`tickets` ya
  da `report`). Eğilim alanı yok. Sprint kartı olmayan konu (ek özellik, rapordan açılan) Talepler'e kartıyla gelir.
- Söz yok, Şimdilik olmaz yok; tek düğme Plana al. Kaynağı `report` olan konuda İsteyen sütunu raporun adını yazar.
- "Plana al" bugünkü sprint yolundan yazar; "Karşılandı" ve "Geciken talep" satırlarını Pazaryeri yazar (PRD_PAZARYERI §3.11).

## 8. Büyüme isteği ("bir sürü büyümek istiyor")

### 8.1 Bugün ne oluyor (kaynak okuması ve ölçüm)
- Memnun, aktif ve en az 6 haftalık her B2B hesabı bir kez "büyümeye hazır" olur: `B2BSalesSystem._tick_healthy` hesabı `active`'ten
  `expansion`'a geçirir (`b2b_sales_system.gd:299-317`); kapı `can_offer_expansion` (`:323-328`, `EXPANSION_MATURE_WEEKS = 6`,
  `b2b_constants.gd:29`). Yeni bir özellikle, sürümle ya da taleple ilgisi yoktur.
- `customer.expansion` kâğıdı hesap başına bir kez gelir (`latch.one_shot`) ve aile freninden geçer. Gelmeyen hesap `expansion`
  hâlinde kalır.
- Gelen kutusu `risk` ya da `expansion` hâlindeki her hesap için bir hatırlatıcı gösterir (`mail_clock.gd:90-92`, `inbox.gd:115-127`,
  konu "Büyümek istiyor"). Hatırlatıcının düğmesi kâğıdı hemen açar (`mail_pane.gd:706`, `:727`); oyuncunun isteği aile frenini
  ödemez. Satış sekmesinin hesap satırı aynı hatırlatıcıya götüren bir düğme gösterir (`sales_tab.gd:658-668`).
- "Koltukları ekle" hesabın koltuk fiyatıyla koltuk ve MRR ekler (`b2b_sales_system.gd:516-533`); sunucu yükü dışında
  (`infra_system.gd:124-125`) bedeli yok. "Şimdilik gerek yok" değişiklik yok.
- Ölçüm (`--run-log`, tohum 1, kopyada geçici sayaç): `full_run_staff6` 60. hafta 117 hesap, **98'i bekliyor**, bot 4 kez büyüdü
  (+$1.374 MRR, toplam $71.470); 104. hafta 241 hesap, 216 bekliyor, 7 büyüme (+$3.066). `full_run_staff1` 40. hafta 41 hesap, 31
  bekliyor, 3 büyüme.
- Sonuç: gelen kutusu her an onlarca "Büyümek istiyor" taşır ve her biri bir tıkla bedava MRR'dır. Ölçülen ortalamayla (hesap başına
  yaklaşık $340) 60. haftada 98 tık yaklaşık +$33 bin MRR, gelirin %47'si eder [kaba hesap, ölçülmedi].

### 8.2 Yeni kural (URUN ile uzlaşıldı; onay bekliyor, §15 soru 4)
- **Yıl ortasında büyüme isteği üç anda doğar, hepsi değer görülünce:** hesabın sözü zamanında tutulunca; hesabın istediği konu
  yayına çıkınca ("Karşılandı"); yenilemede (yenileme kâğıdının "büyüyerek yenile" şıkkı, PRD_ERP §4.5). Aynı haftaya iki kâğıt
  gelmez.
- **Tavan:** bir sürüm en çok üç büyüme isteği doğurur, hesap başına bir; önce sözü tutulan, sonra en memnun (bugünkü teşekkür
  notunun kotası `thanks.max`, `SprintBridges.thank`). Döviz Kurları 39 hesaba çıkınca 39 değil, en çok 3 hesap büyümek ister.
- **Bedel:** kâğıdın iki ayrı şıkkı var: "Koltukları ekle" yeni koltukların kurulumunu ister: temsilcinin ya da kurucunun bir haftası
  (PRD_ERP §4.5, URUN'un D2 kurulum ve veri taşıma mekaniği; fiil yoksa `[VOCAB?]`); "İndirimle ekle" kurulumu hesap üstlenir,
  koltuk fiyatı pazarlığın bugünkü indirim satırıyla düşer. "Şimdilik gerek yok" hesabı memnun bırakır, istek bir sonraki yenilemeye
  kalır.
- **Kalkanlar:** 6 haftalık kural (`_tick_healthy`'nin geçişi, `can_offer_expansion`'ın hafta kapısı) ve gelen kutusundaki büyüme
  hatırlatıcısı (`mail_clock.gd:91`'de yalnız `risk` kalır). Satış sekmesinin hesap satırındaki düğme yalnız doğmuş bir büyüme
  isteğinde görünür. Risk hatırlatıcısı kalır (Erdem, N03: "oyuncu bir şey kaçırmasın").
- **PRD_ERP §2.5'in ödülü:** "tutulan söz koltuğu ⌈koltuk × 0,2⌉ büyütür" yerine tutulan söz büyüme isteği doğurur (yukarıda);
  hesabın yıldız bandı doluysa istek yerine hesabın sektöründen bir referans aday gelir (PRD_ERP §2.5'in kendi kuralı).
- **Eski kayıt:** `expansion` hâlinde yüklenen hesap ilk tikte `active`'e döner; göç yok.
- Kuralın tek yeri bu bölümdür; PRD_ERP §2.5 ve §4.5 buna atıf yapar. Büyüme kâğıdının metni OLAYLAR'ındır.

## 9. Değişecek yerler

- `scripts/tabs/product_tab.gd`: `VIEW_KEYS`'e "requests", ayrı sekme grubu; yeni görünüm `scripts/tabs/product/requests_view.gd`.
- `scripts/tabs/product/product_model.gd`: `_requests` konu başına gruplar; `_due` ve "Gelecek çeyrek" kalkar (URUN'dan sonra).
- `scripts/tabs/product/area_panel.gd`: talep bölümü kalkar (URUN'dan sonra). `board_row.gd`, `sprint_next.gd`: isteyen sayısı ve
  söz çipi. `sprint_ui_shared.gd`: `open_requests`.
- `scripts/systems/sprint_bridges.gd`: `tick_requests` (pencere, hesap başına tek açık istek, acının isteğe dönüşü, kapatılan
  konunun beklemesi), `close_request`, `add_promise_request`, `request_step`'in kademe kuralı kalkar, `on_release` "Karşılandı",
  `thank` yanında büyüme isteği.
- `scripts/data_models/customer.gd`, `scripts/autoload/customer_registry.gd`: `request_marks` ve seam'leri.
- `scripts/systems/b2b_sales_system.gd`: `satisfaction_target`'ın yeni terimi; `_tick_healthy`'nin `expansion` geçişi ve
  `can_offer_expansion`'ın hafta kapısı kalkar; büyüme kapısı §8.2'ye bağlanır; sözün beş kaynağı paydan tarih alır.
- `scripts/systems/sales_finalizer.gd`: görüşme sözünün tarihi paydan.
- `scripts/systems/sprint_system.gd`: sözlü kartın plan kilidi ve hız kuralı (atamada payın sınırı); `scripts/systems/sprint_catalog.gd`:
  talep kartının adı.
- `scripts/systems/customer_rep_system.gd`: özellik talebi masadan geçmez; `_escalate` yalnız ilişki taleplerini çıkarır.
- `scripts/systems/support_system.gd`, `scripts/tabs/events/mail_pane.gd`: Destek raporunun talepler bölümü ve düğmesi.
- `scripts/systems/mail_clock.gd`, `scripts/ui/components/inbox.gd`, `scripts/tabs/sales_tab.gd`: büyüme hatırlatıcısı kalkar.
- `scripts/systems/sales_rep_system.gd`, `scripts/systems/sales_ledger.gd`: kayıp kaydı modülü taşır (URUN'un şemasıyla).
- Kartlar: `data/events/cards/customer/expansion.json` (tetik §8.2, iki bedelli şık), yeni `product.scope_added` (§4.3),
  `customer.request_feature` (yalnız ilk istekte).
- `data/product/sprint.json` `request` bloğu [WORKING]; `localization/strings.csv`: `REQ_` önekli anahtarlar, sayı taşıyan her
  metin `_ONE` ikiziyle (`Fmt.count_key`).
- `scripts/main/main.gd`: kare türleri `--product-shot=live:req_*`, `--inbox-shot=requests_week|requests_go`.

## 10. Bot

- `full_run*` botu Talepler'i oynar: her sprint planından önce en çok isteyen bekleyen konuyu plana alır; payın boşu varsa en
  riskli isteyene söz verir; 20 haftayı geçmiş, yenilemeye 12 haftadan çok kalan konuya "Şimdilik olmaz" der. `naive` politika
  Talepler'e dokunmaz.
- Büyüme kâğıdında bot "Koltukları ekle"yi seçer (kurulum haftası kapasiteden düşer).

## 11. Metinler (taslak; TR ve EN onay bekliyor)

Prototipte 99 anahtar (`talepler/PROTOTIP.diff`, `REQ_*`). Öne çıkanlar:
- `REQ_ACT_PROMISE` "Söz ver · Sprint {n}"; `REQ_PROMISE_WHAT` "{name} hesabına söz: Sprint {n} sonuna kadar çıkar. Tutulursa
  memnuniyet +{kept}; bozulursa memnuniyet −{broken}, marka −{brand}. Plandan çıkarılamaz."
- `REQ_SHARE_TAG` "Söz payı %{used} / %{cap}"; `REQ_PROMISE_QUEUE_TIP` "Söz payı dolu: {topics}. Söz tarihi: Sprint {n}."
- `REQ_CLOSE_COST` "{n} hesap · her birine memnuniyet −{v}" (`_ONE` "1 hesap · memnuniyet −{v}"); `REQ_CLOSE_TIP` "Konu kapanır,
  bekleme bedeli geri alınır. Hesap bu konuyu bir sonraki yenileme penceresine kadar istemez. Kayıtlarına yazılır: Talep
  kapatıldı: {topic}."
- `REQ_COL_WAIT` "Geciken"; `REQ_WAIT_TIP` "Geciken talep: {topic}. {n} hesap {weeks} haftayı geçti; her birinin memnuniyeti bir
  kez {v} puan düştü. Talep yayına çıkınca bu düşüş geri alınır."
- `REQ_LOCK_RESEARCH_FIRST_SHORT` "Önce {first} araştırılmalı" (soru 5'in cevabına bağlı); `REQ_MAIL_OVERDUE` "Bu hafta {n}
  hesabın talebi {weeks} haftayı geçti."; `REQ_MAIL_ROW` "{company}: {topic}. Artık {n} hesap istiyor."
- Kilit metinleri PRD_ERP §3.5'in; modül ve kademe adları URUN'un şemasından; pazaryeri konu adları PAZARYERI'nin.
- Tasarım gerekçeleri (ör. "müşteriye sprintin dörtte birinden fazlasını bağlamayız") oyuncu metnine girmez (ortak kural 1).

## 12. Tasarım sabitleri (hepsi [WORKING]; onay bekliyor; ayar playtest'te)

| Sabit | Değer | Nerede |
|---|---|---|
| Geciken eşiği | 8 hafta | `sprint.json` `request.wait_weeks` |
| Bekleme bedeli | memnuniyet −5, istek başına bir kez | `request.wait_cost` |
| Kapatma izi | memnuniyet −2, bir sonraki yenilemeye kadar, hesapta en çok bir | `request.close_cost` |
| Söz payı ve hız | sprint kapasitesinin %25'i; sözlü kart sprint başına en çok bu kadar ilerler | `request.promise_share` |
| Görüşme sözünün tarihi | sabit 2 hafta yerine paydan | `sales_finalizer.gd` (toplantı dengesi) |
| "İsteyen ekledi" | hiç hazırlanmamış kartta %50, iş +%30 | `request.scope_add_chance`, `request.scope_add_effort` |
| Risk altında | yenilemeye < 12 hafta ya da Risk evresi | `request.risk_renew_weeks` |
| Kayıp satış penceresi | 12 hafta | `request.lost_weeks` |
| Büyüme isteği | sürüm başına en çok 3, hesap başına 1; kurulum 1 hafta | `thanks.max` ile ortak, `expansion.setup_weeks` |

## 13. Test ve kapılar

- Kapı sırası CLAUDE.md §12: lint, `loc_residue`, `loc_csv_integrity`, hedefli smoke.
- Yeni smoke vakaları (çekirdek mantık): `requests_one_open_per_account`, `requests_born_in_window`, `requests_topic_groups_askers`,
  `request_wait_mark_once_and_cleared_on_ship`, `request_closed_topic_not_reasked`, `promise_share_pace_and_date`,
  `promise_card_locked_in_plan`, `promise_sources_share_one_pool`, `expansion_only_after_value` (söz, teslim, yenileme; sürüm
  başına tavan), `load_expansion_phase_to_active`. Etkilenen vakalar: `sprint_request_*`, `cs_request_*`, `promise_*`,
  `sales_promise_late_request_card`, `paper_cards_render`, `card_body_tokens_resolve`.
- Arayüz (gelen kutusunda büyüme hatırlatıcısının olmaması dahil) smoke'la değil görsel kabulle doğrulanır (CLAUDE.md §10, §11).
- Probe: `--run-log` her hafta `PROBE REQ topics= waiting= overdue= promised= kept= extended= broken= wait_marks= delivered=
  expansions=` basar. Her paket önce ve sonra `PROBE END`'i karşılaştırır (kayıp hesap, MRR, büyüme sayısı); fark commit mesajına.
- Görsel kabul her commit'te: kareler TR ve EN, `--screen 2`, dünya botun oynadığı koşudur.

## 14. Commit sırası ve bağımlılıklar

1. İstek modeli: pencere, hesap başına tek açık istek, acının isteğe dönüşü, konuya çok isteyen, sessiz düşmenin kalkması,
   `close_request` ve `add_promise_request` (`sprint_bridges`). URUN'un şema commit'inden sonra: `tick_requests` sektörün vurgu
   alanını okuyor (`sprint_bridges.gd:40`), şema onu ihtiyaç listesine çeviriyor.
2. Talepler görünümü ve açıcı (`product_tab`, `requests_view`, `product_model._requests`, `sprint_ui_shared`).
3. Bekleme bedeli, Karşılandı, Şimdilik olmaz (`customer`, `customer_registry`, `b2b_sales_system`, `on_release`). Görünümden
   sonra: oyuncu bedeli indiği gün görür. Önce ve sonra çifte sayım ölçümü (§5).
4. Sol sütunun talep bölümünün kalkması (`area_panel`, `_due`). URUN'dan sonra.
5. Pano ve sonraki sütun rozetleri.
6. Söz payı, hız kuralı, tarih ve plan kilidi (`sprint_system`, `PromiseRegistry`).
7. "İsteyen ekledi" kâğıdı (§4.3). 6'dan ve URUN'un PM hazırlık değişikliğinden sonra.
8. Sözün beş kaynağı aynı paydan; görüşme sözünün tarihi (`sales_finalizer`, `b2b_sales_system`).
9. Kilitli satır (PRD_ERP §3.5'in metniyle; URUN'un 2. paketinden sonra) ve gizli düğüm (soru 5'in cevabı).
10. H18: masa özellik talebini emmez, `request_feature` yalnız ilk kez, Destek raporu bölümü, temsilcisiz yol.
11. Büyüme: 6 hafta kuralı ve hatırlatıcı kalkar, değerden doğan büyüme, tavan, bedelli şıklar. URUN'un D2 kurulum fiilinden ve
    PRD_ERP soru 5'in cevabından sonra.
12. Yenileme kâğıdı bekleyen talebi anar ve büyümeyi taşır (URUN'un PRD_ERP yenileme commit'iyle birlikte).
13. Kayıp satışın modül eşlemesi (`sales_rep_system`, `sales_ledger`; URUN'un şemasından sonra).
14. Pazaryeri satırları (PAZARYERI'nin paket 3'ünden sonra; `ORTAK_ARAYUZLER.md` §3 dalga 5).
15. Bot (§10) ve probe satırları.
16. EN metinleri ve `_ONE` ikizleri; kod haritası ve sözlük (`docs/kod_haritasi/`, `--event-vocab`).

Ortak dosyaların sırası: `area_panel.gd`, `product_model.gd`, `sprint_catalog.gd`, `sprint_system.gd` önce URUN; `sprint_bridges.gd`,
`support_system.gd`, `b2b_sales_system.gd` önce bu PRD, sonra PAZARYERI; `sales_tab.gd` önce bu PRD (yalnız büyüme düğmesi),
sonra PAZARYERI ve URUN.

## 15. Erdem'e sorular

1. **Söz verilen istek bırakılabilir mi?** A: bırakılabilir, bedeli büyük ve seçimden önce görünür. B: bırakılamaz, yalnız bir kez
   ileri alınır; ikinci kez yetişmezse söz kendiliğinden bozulur. **Önerim B**, çünkü sözünüz "söz verdiysek yapmamız lazım"
   diyor ve söz kıt. Örnek: Meridian Mağazacılık'a Sprint 38 için Dönem Kilidi sözü verdin (kare B08), sprintte acil durum çıktı,
   kart yetişmiyor. B'de seçeneklerin ileri almak (güvene bedel), fazla mesai ya da testi kısaltmak; bırakmak yok.
2. **Söz kapasitesinin kuralı onayın mı?** Sözlü iş sprintin sabit bir payını geçmez [örnek dörtte bir] ve sözlü kart her sprintte
   en çok bu pay kadar ilerler; söz tarihi bu hızdan çıkar. Takas şu: söz sıkı bir tarihtir. Testte çıkan hata, acil durum ya da
   müşterinin eklediği kapsam kartı geç bıraktırır; PM'in hazırladığı kartta müşteri kapsam eklemez. Pay ekiple kendiliğinden
   büyür. Örnek: tek kurucu bir sprintlik kart için ancak dördüncü sprintin sonuna söz verebilir, altı kişilik ekip ikinci sprintin
   sonuna. Seçenek: sprint başına sabit söz sayısı ve tam hız; daha basit, ama söz hep erken tutulur ve bedava bir ödüle döner.
3. **Derinlik listesinden hangileri demoya?** (`talepler/TESLIM.md` §3, sekiz madde.) Önerim üç madde, yaklaşık 1,5 hafta:
   - "Bunu yapmazsanız gideriz": büyük hesap yenilemeyi bir konuya bağlar. Örnek: Haliç Lojistik, Kısmi Teslim Mart'a kadar
     çıkmazsa yenilemeyeceğini söyler; söz verirsin (pay dolar), indirimle oyalarsın ya da bırakırsın.
   - "PM isteyenle görüşür": PM'in haftası hazırlıktan görüşmeye kayar, kart küçülür.
   - "Sürüm notunda Karşılandı": çok istenen konu çıkınca en memnun hesap satışa referans olur.
   Seçenek: hiçbiri; Talepler derinlik maddesi olmadan da çalışır. Seçilen madde koda geçmeden bu PRD'ye bölüm olarak yazılır.
   "Ücretli özel geliştirme" URUN'un D4 kâğıdıyla tek mekanik; URUN dördüncü öneriyor.
4. **Büyüme kuralı onayın mı?** (§8.2) Senin cümlen: "yeni bir feature yüklediğimizde bütün müşteriler büyümek istiyor derse oyun
   inanılmaz kolaylaşır." Öneri: büyüme yalnız tutulan söz, teslim ve yenilemede doğar; bir sürüm en çok üç hesabı büyütür; büyümenin
   bedeli kurulum haftası ya da indirim; gelen kutusundaki "Büyümek istiyor" kalkar. Örnek: Döviz Kurları 18 hesaba çıktı; sözü
   tutulan Sultanahmet İnşaat ile en memnun iki hesap büyümek ister; kabul edersen temsilcinin bir haftası kuruluma gider. Bağlı
   olduğu: URUN'un kurulum fiili (D2) ve PRD_ERP soru 5'in (yıllık sözleşme) cevabı. Seçenek: bugünkü kural kalır, yalnız
   hatırlatıcı yığını kalkar; büyüme yine bedavadır.
5. **Kilit, ağaçta henüz görünmeyen düğümü söylesin mi?** Bugün Semantik İndeks ağaçta yalnız Veri Modeli bitince görünüyor;
   60. haftadaki şirket onu ağaçta bulamaz. A (önerim): kilit ağacın gösterdiği ilk düğümü söyler, "Önce Veri Modeli
   araştırılmalı"; hedef düğüm kök bitince görünür. B: kilit hedefi söyler, "Semantik İndeks araştırılmalı (önce Veri Modeli)";
   ağacın sakladığı adı açar ama oyuncu nereye gideceğini bilir. Cevap PRD_ERP §3.5'e de işler.
6. **Bekleme bedeli kime yazar?** A: 8 haftayı geçen her sözsüz isteğe bir kez −5; kare B05'teki 60. hafta şirketinde 62 hesabın
   25'ine. Baskı her yerde, ama sürekli bir vergi gibi okunabilir. B (önerim): yalnız yenilemesine 12 haftadan az kalan hesabın geciken isteğine;
   bedel yenilemenin yaklaştığı yerde, "Risk altında" ile aynı yerde. Örnek: Haliç Üretim 12 haftadır bekliyor ama yenilemesine 30
   hafta var; A'da bugün −5, B'de yenilemesine 12 hafta kalınca.

## 16. Ayrı işler (bu PRD'de değil)

- URUN'un D1 pilot müşteri, D4 özel geliştirme, D5 e-Fatura, D8 anahtar kişi kâğıtları: mekanik PRD_ERP §5'te; kâğıtları OLAYLAR,
  Erdem'in 16 Kasım seçiminden sonra ayrı bir yazım işiyle yazar (kurum ve mevzuat adları sorusu Erdem'de).
- Ar-Ge ağacının görünürlük kuralı (Ar-Ge'nin işi; soru 5 yalnız kilidin ne söylediğini sorar).
- Derinlik listesinin seçilmeyen maddeleri (`talepler/TESLIM.md` §3).
