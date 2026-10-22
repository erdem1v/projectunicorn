# Faz C planı · Ürün sayfası (v1 sonrası) ve B2B hesaplar
Planlayıcı: Opus · 2026-10-16 · Kod `1faeb82` üstünde okundu. A ve B henüz koda girmedi; onlara dayanan her
varsayım **"A/B varsayımı"** diye işaretli. Plan, A ve B commit'lenince güncel koda karşı tazelenir.

(inceleme) Opus kıdemli incelemesi 2026-10-16: düzeltmeler `(inceleme)` işaretiyle duruyor; bulgular `C_INCELEME.md`'de.
Örnek şirket adları gerçek şirketlerden uydurma adlara çevrildi (Kuzey Lojistik, Yelken Ofis, Poyraz Lojistik, Nehir
Tekstil); rakip adları oyunun ERP rakipleridir (Ardenna, Raketenhaus, Sumpter; `rival_catalog.gd` `NAMES.erp` 3, 5, 6).
Hat ve eksen adları oyundakilerle eşlendi (Fatura, Eşitleme, İnovasyon).

---

## 0. Özet

- **Ürün penceresi** üç kâğıt olur: GENEL BAKIŞ | SPRINT | ÇEYREK. Genel Bakış v1.0'dan önce kilitlidir. Beş blok
  taşır: Sürüm ve kalite, Destek, İstekler, Sunucu, İş. Her blok birkaç satırdır ve açıklama satırı taşımaz.
- **Sunucu sadeleşir.** Üç kademe kalır: Ekonomik, Standart, Kurumsal. Kapasite her hafta kullanıcıya göre kendiliğinden
  büyür ve küçülür. Doluluk, aşım ve elle kapasite kalkar. Oyuncu yalnız kademeyi seçer ve aylık faturayı görür.
- **Kurumsal sunucu şartı:** 3★ ve üstü hesap imzalanır, şart sözleşmeye yazılır. Geçiş toplantı çıkışında ya da
  mailde tek tıktır. Şart karşılanmazsa o hesabın memnuniyet hedefi düşer.
- **Satış (B2B)** iki kâğıt olur: ADAYLAR | HESAPLAR. HESAPLAR bir hesap tablosudur. Durum sütununda yalnız
  "Ayrılabilir", "Yenilemeyebilir" ya da kesinleşmişse "Yenilemeyecek · Mart" yazar. Memnuniyetin ipucu nedenleri
  sayıyla söyler. Ekranda "Onboarding" kelimesi kalmaz.
- **Sözleşme yenileme:** Hesabın satışçısı varsa kurucuya ayda bir kez sorar: "Fiyatı artıralım mı?" Pazarlığı o
  yürütür, sonucu satışçının yıldızı belirler ve sonuç maille gelir. Satışçı yoksa kurucuya "Bu müşterilerle
  görüşmemiz gerekiyor" kâğıdı gelir.
- **Haftalık destek raporu:** Müşteri temsilcisi gönderir; yeni bir şey yoksa gelmez. İstekler yalnız temsilci
  varken görünür. Temsilci yokken B2C'de "Sesler" bölümünde 1–2 kullanıcı alıntısı durur.
- **Ayrılma eşiği** 30'a iner: 30 + 3 × (yıldız − 1) + sektör ekinin yarısı.
- **Rakip analizi** ayrı bir ekran olmaz. Gerekçe §2.7'de.
- **Oyuncu ne hisseder:** v1'den sonra ürününe tek bakışta hâkim olur. Hesaplarını bir yönetici gibi okur. Para
  kararlarını (sunucu, zam) yerinde ve bedelini görerek verir. Mail kutusu dolmaz.
- **Hacim:** 9 commit (inceleme: C3 ikiye bölündü). Uygulama, kapılar ve incelemeyle birlikte yaklaşık 22 saat sürer; gerçekçi takvim 3 iş günüdür.

---

## 1. Bugünkü akış

**Ürün penceresi**
- Başlıkta ürün adı ve sürüm var; canlı B2C'de ayrıca kullanıcı ve ödeyen sayısı.
- Altında SPRINT | ÇEYREK şeridi, Geçmiş ve devir anahtarı.
- v1.0'dan sonra ürünün genel hâlini gösteren bir sayfa yok. Memnuniyet, gelir, sunucu ve destek ekranın hiçbir yerinde
  toplu okunmuyor. Eski canlı sayfa ürün rev 7'de silindi.
- **Neden yetersiz:** Oyuncu yayındaki ürünün ne durumda olduğunu görmek için Satış, Finans ve build bar arasında gezer.
  Sunucu hiçbir ekranda görünmez.

**Sunucu**
- Arka planda üç sağlayıcı var. Kapasite yalnız sürümde büyüyor, hiç küçülmüyor. Oyuncu kapasiteye dokunamıyor.
- Doluluk %80'de sarı, %100'ü aşınca memnuniyet, bildirim ve B2C kazanımı cezalanıyor.
- Ekonomik (yerel) sunucu kurumsal imzayı engelliyor.
- Bot ölçümü (B2C, 97 hafta): doluluk hiç %100'ü aşmadı, 57 hafta %80–100 bandında kaldı. Doluluk oyuncuya bir karar
  sunmuyor; arka planda kendi kendine dönüyor.

**Satış (B2B)**
- Sağda hesap kartları var. Her kartta evre etiketi (Onboarding, Aktif, Risk, Genişleme), künye, ses satırı, açık söz,
  memnuniyet çubuğu, "Churn'e ~2 hafta" sayacı ve sorumlu var.
- Tolerans (ayrılma eşiği) gizli. Memnuniyetin neden düştüğünü yalnız Risk'teki hesabın tek "neden" satırı söylüyor.
- Ürün alanının adı "Onboarding & Erişim". Kartta "Onboarding gelecek hafta bitiyor" satırı var.
- **Neden yetersiz:** Kartlar uzun ve kalabalık. On hesaptan sonra okunmuyor. Erdem iki etiketi açıkça reddetti:
  "Büyümeye açık" ve hafta sayısı.

**Yenileme**
- Sözleşme diye bir kayıt yok. Müşteri temsilcisinin talep kanalı, kıdemi 44 haftayı geçen hesaba bazen bir
  "yenileme sinyali" kâğıdı açıyor. Seçenekleri: konuş, indirim ver, beklet. Fiyat artışı hiç yok.

**Destek ve istekler**
- B2B istekleri her hesapta sözleşme takvimine göre kendiliğinden açılıyor ve sprintte "talep kartı" olarak görünüyor.
  Bunun için temsilci gerekmiyor.
- B2C'de istek verisi yok.
- Temsilci haftalık bir rapor göndermiyor. Satışçı ise haftalık satış raporu gönderiyor; bu kalıp yeniden kullanılır.

**Rakip**
- Rakip çıkışları haber bandına düşüyor ve o alanın beklentisini yükseltiyor. Ancak beklenti yalnız alan kelimesini
  ("Zayıf", "Yeterli") değiştiriyor; satışa ve memnuniyete etkisi yok.
- Özellik karşılaştırması kaldırıldı. Piyasa penceresinde pazar payı merdiveni var. Ar-Ge notlarında rakip adları geçiyor,
  ama analiz yok.

**Ayrılma eşiği**
- Bugün hesap başına 33, 42, 45, 51 ya da 56.
- Bot (B2B, 3 tohum, 104 hafta) hesapların %2–7'sini kaybediyor. Kayıpların neredeyse hepsi ilk 30 haftada, zayıf
  v1 döneminde. 40. haftadan sonra memnuniyet hemen her hesapta 59–67 bandında; eşiğin çok üstünde.

---

## 2. Hedef akış

### 2.1 Ürün penceresi: üç kâğıt
- Şerit: **GENEL BAKIŞ | SPRINT | ÇEYREK** ... Geçmiş ○ ... devir anahtarı.
- v1.0'dan önce GENEL BAKIŞ kilitlidir. Kilidi bugünkü ÇEYREK kilidinin aynısıdır. İpucu: "v1.0 yayınlanınca açılır."
- Pencere son açık kâğıdı hatırlar. Sürüm notu açıkken pencere her zaman SPRINT'te açılır (bugünkü kural).
- Genel Bakış, Sprint'in oyuncunun asıl vakit geçirdiği yer olduğunu bozmaz. Kâğıt hiçbir zaman kendiliğinden öne
  çıkmaz.

**Genel Bakış · B2B** ([ÇALIŞMA] sayılar)
```
 GENEL BAKIŞ | SPRINT | ÇEYREK                                             Geçmiş ○
┌ SÜRÜM ──────────────────────┐┌ DESTEK ─────────────────────────────────────────────┐
│ v1.4 · 3 hafta önce         ││ Açık hata                7   ▲2                      │
│ Kararlılık 61 · İnovasyon 54││ Fatura · 4 açık hata · 3 hesap               ↑  ›  │
│ · Deneyim 48                ││ Stok   · 2 açık hata · 1 hesap               ↓  ›  │
│ Sonraki v1.5 · Sprint 9     ││ Temsilci   Selin K.                                  │
└─────────────────────────────┘└──────────────────────────────────────────────────────┘
┌ İSTEKLER ─────────────────────────────────────────────┐┌ SUNUCU ─────────────────────────┐
│ Toplu fatura onayı · Kuzey Lojistik, Yelken Ofis · ayda $1.800 ›││ [Ekonomik│Standart│Kurumsal]│
│ e-Defter dışa aktar · Poyraz Lojistik · ayda $600            ›││ Ayda $405 · 412 koltuk       │
└────────────────────────────────────────────────────────┘│ Kurumsal sunucu bekleyen 1 hesap│
┌ İŞ ──────────────────────────────────────────────────────────────────────────────┐
│ MRR $14.200 · Yıllık $170.400 · 9 hesap · bu ay +2 −1                          › │
└──────────────────────────────────────────────────────────────────────────────────┘
```

**Genel Bakış · B2C, temsilci yok**
```
┌ SÜRÜM ──────────────────────┐┌ DESTEK ─────────────────────────────────────────────┐
│ v1.3 · 1 hafta önce         ││ Açık hata                5   ▲1                      │
│ Deneyim 57 · Kararlılık 49  ││ Eşitleme · 3 açık hata · 2.100 kullanıcı      ↑  ›   │
│ · İnovasyon 52              ││ Arama    · 2 açık hata · 900 kullanıcı           ›   │
│ Sonraki v1.4 · Sprint 7     ││ SESLER                                               │
└─────────────────────────────┘│ ★★☆☆☆ "Telefonda yazdığım not bilgisayara gelmedi,  │
                               │        iki kez yeniden yazdım."                      │
                               │ ★☆☆☆☆ "Aradığım notu bulamıyorum, başlığını         │
                               │        bilsem bile."                                 │
                               └──────────────────────────────────────────────────────┘
┌ İSTEKLER ─────────────────────┐┌ SUNUCU ──────────────────────┐┌ İŞ ───────────────────┐
│ Müşteri temsilcisi yok        ││ [Ekonomik│Standart│Kurumsal] ││ MRR $3.150            │
│                               ││ Ayda $880 · 12.400 kullanıcı ││ · dönüşüm %5        › │
└───────────────────────────────┘└──────────────────────────────┘└───────────────────────┘
```
- Temsilci gelince SESLER kalkar. İstekler bloğu dolar: "Kargo takibi · 38 yorum", "Taksit · 21 yorum".
- B2C'de İş satırı E gelene kadar bugünkü sayıları okur. (inceleme) E gelince satır E'nin `figures()`'ından
  "MRR $57.650 · 12.400 alıcı · 184 mağaza ›" olur: B2B satırı gibi MRR ile başlar, satış hacmi (GMV) ve sepet
  ortalaması Pazaryeri sayfasında kalır. E planı (§2 sonu) aynı satırı "alıcı · mağaza · aylık gelir" diye yazıyor;
  biçim C'nin, sayılar E'nin. Eski öneri "Satış hacmi $193K · 184 mağaza" E ile çelişiyordu.

**Blokların kuralları**
- **Sürüm:** sürüm, yaşı, üç eksen sayıyla, sonraki sürüm ve sprinti. Eksen sırası pazara göredir: B2B'de Kararlılık,
  B2C'de Deneyim önce gelir. Gerekçe: memnuniyeti o eksen sürüklüyor. Tıklama yok.
- **Destek:**
  - "Açık hata" A'nın tek sayısıdır, haftalık değişimiyle yazar.
  - Altında en kötü iki hat durur. Hat satırı A'nın biçimindedir (A/B varsayımı: A'nın hat satırı metni ve etkilenen
    hesap/kullanıcı sayısı tek fonksiyondan okunur). (inceleme) A'nın satırı B2B'de "Fatura · 4 açık hata · 3 hesap ↑",
    B2C'de "Eşitleme · 3 açık hata · 2.100 kullanıcı ↑"; kullanıcı sayısı B2B'de yalnız ipucunda (A §2.1). Ok küçük bir
    ikondur, eşitse çizilmez (A). A'nın Sprint hat panelindeki "AÇIK HATALAR" satırları yerinde kalır: düzeltme kartı
    oradadır. Karar defterindeki "taşır" burada "Genel Bakış'ta da özetlenir" diye okundu.
  - Satır tıklanınca SPRINT açılır, hattın alanı açılır ve düzeltme kartı bir kez vurgulanır. Kart sprintteyse
    sprint sütununda vurgulanır.
  - Temsilci satırında adı yazar. (inceleme) Temsilci yokken satır çizilmez; "Müşteri temsilcisi yok" yalnız İstekler
    bloğunda bir kez yazar.
  - Build bar'daki destek satırı A'nındır; C onu çizmez. (inceleme) Tıklaması da A'nın kuralında kalır: Sprint, en
    kötü hattın alanı açık (A §2.4). Eski öneri "v1.0 sonrası Genel Bakış açılır" düzeltme kartına giden yolu bir tık
    uzatıyordu; Genel Bakış zaten pencerenin ilk kâğıdıdır.
- **İstekler:** Temsilci yokken tek satır: "Müşteri temsilcisi yok". Temsilci varken en çok üç istek. B2B'de
  "<özellik> · <hesaplar> · $<aylık>/ay", B2C'de "<özellik> · <n> yorum". Satır tıklanınca SPRINT'te o kart
  vurgulanır.
- **Sunucu:** §2.3.
- **İş:** tek satır, Satış'a gider.

### 2.2 İstekler ve "İstenen" etiketi
- İstekler B2B'de de B2C'de de yalnız müşteri temsilcisi varken görünür.
- Temsilci: Destek işinde çalışan bir çalışan. Kurucunun pasif ilgisi temsilci sayılmaz.
- **B2B:**
  - Hesap istekleri bugünkü gibi sözleşme takvimine göre arka planda doğar.
  - Temsilci yokken görünmez. Sprintteki kart düz özellik kartı olarak kalır.
  - Temsilcinin çalıştığı ilk hafta, açık istekler "bilinir" olur. Kart talep kartına döner ve hesabın adıyla değerini
    taşır (bugünkü talep kartı).
  - Bilinen istek, temsilci sonradan ayrılsa da bilinir kalır.
- **B2C:**
  - İstek verisi türetilir, saklanmaz.
  - Canlı hatların sonraki kademeleri kullanım ağırlığına göre sıralanır.
  - Yorum sayısı kitleyle ölçeklenir. Örnek: 12.400 kullanıcı × 0,004 = 50 yorum, ilk üç isteğe bölünür.
  - Temsilci varken o kademenin kartına etiket düşer: "İstenen · 38 yorum".
  - Pazaryerinde satıcı hatlarından gelen istekler ayrı tutulur ("Satıcılardan"). Bu ayrımı E'nin hat verisi taşır
    (A/B varsayımı değil, E varsayımı).
- Kartta en çok bir etiket durur. İstek etiketi önce gelir.
- (inceleme) Bilinmeyen istek de o kademe yayına girince karşılanmış sayılır (`on_release` bugünkü gibi `met` yazar).
  Bugün geç kalan isteğin memnuniyete bir bedeli yok (`tick_requests` yalnız `late` yazar), yani temsilcisiz oyuncu
  görmediği bir istek yüzünden gizli bir ceza yemez.

### 2.3 Sunucu
**Model (oyuncunun gördüğü)**
- Üç kademe: **Ekonomik · Standart · Kurumsal**.
- Kapasite kullanıcıyla kendiliğinden büyür ve küçülür. Oyuncunun kararı yalnız kademedir.
- Ekranda doluluk ve "kapasite" kelimesi yoktur. Fatura tek sayıdır: "Ayda $880 · 12.400 kullanıcı".

**Kademelerin artı ve eksisi** (her kademenin ipucunda; sayılar)

| | Ekonomik | Standart | Kurumsal |
|---|---|---|---|
| Fiyat (B2C) | 1.000 kullanıcı başına ayda $35 | $55 | $85 |
| Fiyat (B2B) | 50 koltuk başına ayda $30 | $45 | $70 |
| Kesinti olasılığı | ×1,5 (B'nin sayısı) | ×1,0 | ×0,6 (B'nin sayısı) |
| Bildirim | %25 fazla | | |
| Satış görüşmesi | Güven sinyali eksi | | |
| Kurumsal sözleşme şartı | Karşılamaz | Karşılamaz | Karşılar |

- Kesinti çarpanları B'nin olasılık modelinden okunur ve ipucunda B'nin sayısıyla yazar (A/B varsayımı: B kademe başına
  tek bir çarpan tablosu tutar). (inceleme) Çarpanın tek evi B'nin `sprint.json` `incident.tier` alanıdır; ipucu
  `IncidentSystem.tier_mult(kademe)`'yi okur, sayıyı kopyalamaz (B incelemesi bulgu 8). Eski tablo ×1,6 / ×0,5
  yazıyordu.
- (inceleme) İpucunda boş hücre çizilmez; tire yok (CLAUDE.md §5).

**Kademe değiştirme**
```
SUNUCU
[Ekonomik │ Standart │ Kurumsal]        ← tık: önizleme satırı açılır
Standart → Kurumsal · ayda $880 → $1.360          [Geç]  [Vazgeç]
```
- Geçiş anında olur ve bedava. Yeni fiyat ertesi haftadan işler (bugünkü kural).
- Karar kâğıdı beklerken seçici kapalıdır (bugünkü kapı kuralı).
- (inceleme) Kurumsal'dan aşağı inerken şartlı hesap varsa önizleme bir olgu satırı ekler:
  "2 hesabın sözleşmesindeki sunucu maddesi karşılanmaz olur." / EN "The server clause of 2 accounts will no longer be
  met." (anahtar `OV_SERVER_PREVIEW_CLAUSE`). Hüküm vermez, sayı söyler.

### 2.4 Kurumsal sunucu şartı (3★ ve üstü hesap)
- Ekonomik sunucu artık imzayı engellemez. Büyük hesap imzalanır, şart sözleşmeye yazılır.
- **Pazarlığın onay şeridi** (bugün "Kapasite 412/600" yazan satırın yerine):
  `Sözleşme maddesi: kurumsal sunucu · ayda $225 fazla`
  Satır yalnız 3★ ve üstü hesapta ve sunucu Kurumsal değilken görünür.
- **Toplantı çıkışı** (görüşme "anlaşıldı" panelinde):
```
Anlaşıldı · Kuzey Lojistik · 60 koltuk · $2.100/ay
Sözleşme maddesi: kurumsal sunucu
[Kurumsal sunucuya geç · ayda $405 → $630]      [Sonra]
```
- **Mail** (imza günü, sunucu hâlâ Kurumsal değilse; gönderen müşterinin BT sorumlusu):
```
Gönderen: Deniz Aras · Kuzey Lojistik, Bilgi İşlem
Konu: Sözleşmedeki sunucu maddesi

Sözleşmede konuştuğumuz gibi verilerimizin kurumsal düzeyde bir sunucuda tutulmasını
bekliyoruz. Taşıma bittiğinde haber verirseniz seviniriz.

                        [Kurumsal sunucuya geç · ayda $405 → $630]
```
- Düğme bugünkü aylık faturayı ve yenisini yazar. Tek tıktır.
- **Şart karşılanmazsa:**
  - O hesabın memnuniyet hedefi 10 puan düşer [ÇALIŞMA]. Şart karşılanınca terim kalkar.
  - Yeni hesabın ilk 4 haftalık tabanı (bugünkü "onboarding tabanı") terimi o süre boyunca örter. Oyuncunun geçmek için
    doğal bir süresi olur.
  - Memnuniyetin ipucunda "Kurumsal sunucu şartı −10" satırı görünür.
- Mail hesap başına bir kezdir. Hatırlatma maili yoktur. İz, tablodaki memnuniyet ipucudur.
- (inceleme) Toplantı çıkışı ile mail aynı anlaşma için ikisi birden gelmez. Kurucunun masada kapattığı anlaşmada
  düğme toplantı çıkışındadır, "Sonra" denirse mail gelmez (Genel Bakış'taki "Kurumsal sunucu bekleyen" satırı ve
  kademe seçicisi yeter). Satış masasının kapattığı anlaşmada oyuncu toplantıyı görmediği için mail gelir. Bot
  koşusunda 3★ hesap 104 haftada 9–10 tane; mail yükü küçük.
- (inceleme) Şartı yalnız Kurumsal kademe karşılar. `security_cert` araştırması bugünkü etkisini (`meets_enterprise_trust`,
  seam `urun.enterprise_trust`, beş olay kartı) korur ve şartı karşılamaz. Bu ayrım ve şartın bedeli sahip sorusu 6'dadır.

### 2.5 Satış (B2B): ADAYLAR | HESAPLAR
- Şeridin solunda iki kâğıt: **ADAYLAR | HESAPLAR**. Sağda bugünkü fiyat duruşu seçicisi kalır.
- ADAYLAR bugünkü sol sütundur: boru hattı, satış masası, son hareketler; iki sütuna yayılır.
- HESAPLAR tablodur ve pencerenin tüm genişliğini kullanır.
- İlk hesap imzalanınca pencere HESAPLAR'da açılır. Sonra son seçileni hatırlar.

**Başlık ölçüleri (B2B):** `HESAP 9 · MRR $14.200 · YILLIK $170.400 · BU AY +2 −1`.
Bugünkü "ortalama memnuniyet" kalkar; memnuniyet tabloda hesap hesap okunur.

**HESAPLAR tablosu** (inceleme: Satışçı sütunu Yenileme hücresinin ipucuna taşındı; boş hücre tire değil boşluktur)
```
FİRMA                  KOLTUK  AYLIK    MEMNUNİYET     DURUM                YENİLEME   İSTEK                       TEMSİLCİ
Yelken Ofis ★★★           60  $2.100   31 ▮▮▮░░░      Yenilemeyebilir      Mar 2027   Toplu fatura onayı          Selin K. [Değiştir]  [İlgilen]
Lale Klinik ★★            24    $840   29 ▮▮▮░░░      Ayrılabilir          Ağu 2027   Söz · Stok K2 · Sprint 9    Selin K. [Değiştir]  [İlgilen]
Poyraz Lojistik ★★        32  $1.150   48 ▮▮▮▮▮░      Yenilemeyecek · Mar  Mar 2027                               [Değiştir]
Kuzey Lojistik ★★★        60  $2.268   66 ▮▮▮▮▮▮▮                          Eki 2027   e-Defter dışa aktar         Selin K. [Değiştir]
...                                                                                                         ▐ kaydırma çubuğu
9 hesap · 412 koltuk · ayda $14.200
```
- (inceleme) **Ölçek:** Bot koşusunda B2B defteri 104. haftada 327–342 hesaptır (tohum 7: 222/97/9, tohum 11: 156/176/10
  hesap 1★/2★/3★). Tablo 9 satırla değil yüzlerce satırla da okunmalıdır: gövde kayar, kaydırma çubuğu her zaman görünür
  (Erdem: dosyada kaydırma çubuğu şart), başlık satırı ve alt toplam satırı sabit kalır. Sıralama kuralı (aşağıda) durum
  taşıyan hesapları en üste aldığı için oyuncunun bakması gereken satırlar kaydırmadan görünür. C7 kapısına 300 hesaplı
  bir fikstür eklenir (`--sales-shot=accounts_many`).
- (inceleme) **Satışçı** sütun olmaktan çıkar: Yenileme hücresinin ipucu "Yenilemeyi Ayşe Kaya yürütür." ya da
  "Yenilemeyi sen yürütürsün." der. Gerekçe: sütun yalnız yenileme ayında anlam taşıyor ve dokuz sütun 1280 enli
  Satış penceresinde planın kendi en büyük UI riskiydi.
- **Sıra:** önce durum taşıyan hesaplar (Yenilemeyecek, Yenilemeyebilir, Ayrılabilir), kendi içinde aylık gelire göre;
  sonra açık sözü olanlar, en yakın son tarih önde; sonra aylık gelire göre.
- **Durum sütunu** üç olgudan birini yazar, başka evre etiketi yoktur:
  - **Ayrılabilir:** memnuniyet eşiğin altında.
  - **Yenilemeyebilir:** memnuniyet eşiğin altında ve sözleşme yenileme dönemi içinde (bitişe 8 hafta ya da daha az).
  - **Yenilemeyecek · Mar:** yenileme görüşmesi kaybedildi, hesap sözleşmesinin sonunda ayrılacak. Bu üçüncü etiket
    bir risk değil, gerçekleşmiş bir olgudur. Gösterilmezse oyuncu ayrılacağını bildiği bir hesabı sağlıklı sanır.
  - "Onboarding", "Risk", "Büyümeye açık" yoktur. Churn sayacının kareleri ve "~2 hafta" kalkar.
  - **Neden başka evre etiketi yok:** Genişleme fırsatı zaten Olaylar'a kâğıt olarak geliyor. Risk, "Ayrılabilir"in kendisi.
    Yeni hesabın tabanı ise ipucunda tek satır olarak görünüyor.
- **Yenileme sütunu:** sözleşme bitiş ayı. Hafta sayısı yazılmaz.
- **İstek sütunu:** açık söz varsa onu yazar (sözü kurucu verdi; hep görünür). Yoksa bilinen isteği yazar; temsilci
  yokken boş kalır.
- **Satışçı** (inceleme: sütun değil, Yenileme ipucu): hesabı imzalayan satış masası çalışanı ya da kurucu. Yenilemeyi o
  yürütür (§2.6).
- **Temsilci sütunu:** bugünkü sorumlu ve Değiştir seçicisi, aynen kalır.
- **Satır eylemi:** yalnız "Ayrılabilir" ve "Yenilemeyebilir" satırında "İlgilen" (bugünkü elde tutma maili).
  Genişleme düğmesi satırdan kalkar.

**Memnuniyetin ipucu** (fareyle memnuniyet hücresinin üstüne gelince)
```
Memnuniyet 31, hedef 27
  Ürün kararlılığı                         58
  Kullandığı hatlarda açık hata           −13
  Söz ve kesintiler (Stok K2 kaçtı)        −8
  Kurumsal sunucu şartı                   −10
Ayrılma eşiği 36
```
- Terimler hedefin toplamıdır; ekran kendi hesabını yapmaz.
- (inceleme) Güven defteri (`trust_offset`) yalnız sözü değil B'nin kesinti bedellerini de taşır (B incelemesi bulgu 12).
  Terim bu yüzden "Sözler" değil "Söz ve kesintiler" diye adlanır; parantezdeki not defterin son kaydını söyler
  ("Stok K2 kaçtı", "Söz tutuldu: Stok K2", "Gece kesintisi"). Erdem'in istediği "sözün tutulması ya da tutulmaması"
  böylece satırın kendisinde okunur.
- "Yeni hesap tabanı" satırı yalnız ilk 4 haftada çıkar: `İlk 4 hafta tabanı   en az 38`.
- Eşik ipucunda yazar. Bugün tolerans gizli, ama tablo "Ayrılabilir" dediği an eşiği zaten ele veriyor. Sayıyı yazmak
  oyuncuya hangi düzeltmenin yeteceğini söyler (açık soru 1).

**Fiyat konumu** (rakip kararı, §2.7)
- Fiyat duruşu seçicisinin ipucuna bir satır eklenir: `Rakiplerin koltuk fiyatı: Ardenna $52 · Raketenhaus $44 · Sumpter $39`.
- (inceleme) Satırın yanında kendi koltuk fiyatı da yazar ("Senin koltuk fiyatın $35"); yoksa rakip fiyatı bir
  karşılaştırma değil düz bir listedir. Rakip fiyatları `rivals.json`'a yeni veri olarak girer; bugün oyunda hiçbir
  etkileri yok. Bir kaldıraca bağlanmaları için en ucuz yol var olan `rival.price_cut` kartıdır (rakip müşterine
  koltukları daha ucuza teklif eder): kartın gövdesi rakibin bu fiyatını yazar. Bu bağ sahip sorusu 3'e bağlıdır.

### 2.6 Sözleşme yenileme
**Kurallar**
- Her B2B sözleşmesi 12 aydır (bugünkü talep takviminin 52 haftası). Yenileme sözleşmenin bitiş ayında olur.
- Her ayın ilk haftası, sözleşmesi bir sonraki ay biten hesaplar sahiplerine göre toplanır. Böylece görüşme 4 ile 8
  hafta önce başlar.
- **Sahip:** hesabın satışçısı Satış işinde çalışıyorsa o; değilse kurucu.
- Sahip başına ayda **tek kâğıt** gelir. Gerekçe: bot 104 haftada 132–149 yenileme yaşıyor; tek bir ayda 21'e kadar.
  Hesap başına kâğıt oyuncuyu boğar.
- (inceleme) **Hacim gerçeği:** İlk yenileme 61. haftada gelir; 61 ile 104. hafta arasında yaklaşık 11 ay vardır. Bot
  koşusunda 328 imzanın 328'i `by=founder` (kurucu masada kapatıyor), yani ikinci yıl boyunca her ay hem kurucuya hem
  varsa satışçıya birer kâğıt düşer: yılda 12 ile 24 kâğıt, hep aynı üç seçenekle. Bu, Erdem'in "tekrar çok seyrek" ve
  "angarya yok" kuralına sürtünür. Plan bu yüzden sahip sorusu 4'te bir daraltma öneriyor: kâğıt yalnız grupta karar
  isteyen bir hesap varsa gelir (3★ hesap, eşiğin altında hesap ya da karşılanmamış sunucu maddesi); öteki aylarda son
  verilen karar uygulanır ve yalnız sonuç maili gelir.
- (inceleme) **Kâğıdın gövdesi kısa kalır:** 21 hesaplık bir ayda bile gövde hesapları tek tek dökmez. Karar isteyen
  hesaplar (eşiğin altında, eşiğe 5 puandan yakın ya da 3★) adıyla, memnuniyeti ve eşiğiyle yazar, en çok 4 satır;
  gerisi tek satırdır: "Diğer 17 hesabın hepsi eşiğinin en az 5 puan üstünde." Tam liste Satış'taki tabloda, Yenileme
  sütununa göre sıralanınca okunur.

**A · Satışçı varsa: soru kâğıdı** (gönderen satışçı)
```
Gönderen: Ayşe Kaya · Satış temsilcisi · Satış 2★
Konu: Mart yenilemeleri

Mart'ta dört sözleşme bitiyor: Kuzey Lojistik, Yelken Ofis, Poyraz Lojistik, Nehir Tekstil.
Fiyatı artıralım mı, aynı fiyattan mı yenileyelim?

  Kuzey Lojistik ★★★   memnuniyet 66 · eşik 36
  Yelken Ofis ★★★      memnuniyet 31 · eşik 36
  Poyraz Lojistik ★★   memnuniyet 48 · eşik 33
  Nehir Tekstil ★      memnuniyet 59 · eşik 30

1  Memnun olanlardan %8 zam iste          Ayşe'nin masası 1 hafta dolu
2  Hepsini aynı fiyattan yenile           Ayşe'nin masası 1 hafta dolu
3  Ayrılabilecek olanlara %10 indirim öner, gerisini aynı fiyattan yenile
                                          (yalnız eşiğin altında hesap varsa)
```
- Kâğıt 2 hafta bekler. Cevapsız kalırsa Ayşe hepsini aynı fiyattan yeniler.
- Pazarlık bir hafta sürer. O hafta Ayşe yeni aday işlemez. Bunun bedeli satış masasında görünür.
  (inceleme) Masa aynı anda tek anlaşma işlediği için (`SalesLedger.rep_busy`) bu, satışçının ayının dörtte biridir.
  C8 kapısı bot koşusunda ikinci yılın imza sayısını yenilemeli ve yenilemesiz ölçer; kayıp %10'u geçerse
  `RENEWAL_DESK_WEEKS` 0,5'e iner ya da sahip sorusu 4'teki daraltma zorunlu olur.
- **Sonuç maili** (Ayşe'den, bir hafta sonra):
```
Konu: Mart yenilemeleri tamam

FİRMA             ESKİ      YENİ      DEĞİŞİM
Kuzey Lojistik    $2.100    $2.163    +%3
Poyraz Lojistik   $1.150    $1.208    +%5
Nehir Tekstil       $420      $454    +%8
Yelken Ofis       $2.100              Yenilemeyecek. Sözleşmesi Mart ayında bitiyor.

Toplam: ayda +$155.
```
- (inceleme) Örnek sonuç tablosuyla tutarlı hâle getirildi (Ayşe 2★): 3★ hesapta bir yıldız düşük, %3; 2★ hesapta
  eşit, %5; 1★ hesapta en az bir yıldız yüksek, %8; eşiğin altındaki 3★ hesap görüşenden yüksek yıldızlı, yenilemez.
  Eski örnekte eşiğinin 29 puan üstündeki Nehir Tekstil "zammı kabul etmedi" diyordu; tablo bunu yalnız eşiğe 5 puandan
  yakın hesaba izin veriyor. Mailde boş hücre tire değil boşluktur (CLAUDE.md §5).

**B · Satışçı yoksa: görüşme kâğıdı** (kurucunun notu)
```
Konu: Mart'ta biten sözleşmeler

Şu müşterilerle sözleşmemiz Mart ayında bitiyor: Kuzey Lojistik, Yelken Ofis, Poyraz Lojistik.
Onlarla görüşmemiz gerekiyor.

1  Görüşmeleri yap, memnun olanlardan %8 zam iste     bu hafta 6 saatin gider
2  Görüşmeleri yap, aynı fiyattan yenile               bu hafta 6 saatin gider
3  Ayrılabilecek olanlara %10 indirim öner             bu hafta 6 saatin gider
4  Hesapları Ayşe'ye devret, o görüşsün                Ayşe'nin masası 1 hafta dolu
                                          (yalnız Satış işinde biri varsa)
```
- Kurucunun bedeli hesap başına 2 saattir, en çok 24 saat [ÇALIŞMA]. Saat kurucunun o haftaki sprint payından düşer.
  (inceleme) Saat `GameState.add_founder_meeting_hours` ile yazılır; D'nin modeli kurucunun iş payını
  "1 − toplantı saati / 40" diye okur (D §5). 24 saat, kurucunun o haftaki sprint katkısının %60'ıdır; tavan bu yüzden
  [ÇALIŞMA] kalır.
- (inceleme) **Kurucu kâğıdı cevapsız kalırsa** (2 hafta): görüşme yapılmamış sayılır. Eşiğin üstündeki hesaplar aynı
  fiyattan yeniler, eşiğin altındakiler yenilemez ve tabloda "Yenilemeyecek · ay" olur. Kurucu saati yazılmaz.
  Gerekçe: bedava çıkış yok; görüşmeyen kurucu en kırılgan hesapları kaybeder.
- Kurucu yolunda sonuç kâğıdın sonucunda görünür; ayrı mail gelmez. Kurucu kendi görüşmesinin sonucunu kendine
  yazmaz.
- "Devret" seçilince bu hesapların satışçısı Ayşe olur. Bu yenilemeyi ve sonrakileri o yürütür. Bu ayın görüşmesini
  aynı fiyatla yapar ve sonuç maili gönderir.
- **Her seçenek bir durumda en iyisidir:** Zam memnun hesap ve güçlü satışçıda. Aynı fiyat sınırda hesap çoksa.
  İndirim eşiğin altında hesap varsa. Devret ise kurucunun haftası doluysa.

**Sonuç tablosu** (zar yok; görüşmeyi yapanın Satış yıldızı ve hesabın yıldızı belirler)

| Seçim | Hesap eşiğin üstünde | Hesap eşiğin altında |
|---|---|---|
| Zam (%8) | Görüşen ≥ hesap +1★: %8 · eşit: %5 · bir yıldız düşük: %3 · iki yıldız düşük: zam yok, aynı fiyat. Eşiğe 5 puandan yakın hesapta görüşen hesaptan düşük yıldızlıysa: zammı kabul etmez, aynı fiyattan yeniler, ilişki gerilir (güven −6) | Zam istenmez; aynı fiyat satırı uygulanır |
| Aynı fiyat | Yeniler | Görüşen ≥ hesap yıldızıysa yeniler; değilse yenilemez |
| İndirim (%10) | Aynı fiyat | Yeniler, aylık %10 düşer, güven +4. İndirim hakkı dolmuşsa (hesap başına 2) aynı fiyat satırı |

- "Yenilemez" denince hesap sözleşmesinin bitiş haftasında ayrılır. O zamana kadar tabloda "Yenilemeyecek · Mar"
  yazar. Ayrılırken bugünkü ayrılma bedeli (marka −2) işler.
- Zam ve indirim koltuk fiyatına da işler: hesap sonradan büyürse yeni koltuklar yeni fiyattan gelir.
- Bugünkü "yenileme sinyali" talep kâğıdı kalkar.

### 2.7 Rakip analizi: ayrı bir ekran olmaz
**Cevap: Hayır.**
- **Kodda kaldıracı yok.** Rakip çıkışı yalnız alanın beklentisini yükseltiyor; bu da yalnız alan kelimesini değiştiriyor.
  Satışa, memnuniyete ya da kayba etkisi yok. Matris ya da aylık rapor olsa oyuncunun ona göre yapacağı hamlenin hiçbir
  karşılığı olmaz. Erdem'in "bir kere bakarım, sonra bana ne" sezgisi doğru.
- **Araştırma bulgusu:** Gerçek PM'in rakip analizi fiyat, yol haritası ve kayıp anlaşma kararlarını besler. Oyunlarda
  anlamlı rakip ekranı karar tetikler (Big Ambitions). Karşılığı olmayan sinyal gösterilmez.
- **Yapılan:**
  - Fiyat konumu, oyuncunun gerçekten fiyat kararı verdiği yerde, fiyat duruşu seçicisinin ipucunda tek satırdır
    (§2.5).
  - Var olan rakip çıkışı bayrağı, haber satırı ve Piyasa penceresi kalır.
  - (inceleme) Planın atladığı bir gerçek: oyunda rakip zaten karar isteyen olaylar olarak geliyor
    (`data/events/cards/rival/`: `price_cut` rakip müşterine koltukları daha ucuza teklif eder, `copycat`, `copycat_reply`,
    `funding_round`, `shutdown_notice`, `false_partner`). Araştırmanın "bilgi bildirimli gelsin, sürekli açık tablo
    olmasın" önerisi bugün bu kartlarla karşılanıyor. Erdem'in "duyum olabilir" sözü de buraya oturur: duyum ayrı bir
    ekran değil, bu ailenin bir kartıdır. "Hayır" cevabı bu yüzden "oyuncu rakibe göre hamle yapmaz" demek değildir;
    hamle olay kâğıdında yapılır.
- **Erken Erişim'e kalan:** Duyum ve rakip raporu. Rakip çıkışı kayıp nedenine bağlanınca anlamlı olur ("Ardenna'yı
  seçtiler, mobil uygulamaları var"). O zaman duyum, kartı öne çekmek için gerçek bir sebep olur.

### 2.8 Haftalık destek raporu
- Gönderen Destek işindeki en iyi temsilcidir. Haftada en çok bir rapor gelir.
- **Yeni bir şey yoksa rapor gelmez.** "Yeni" şunlardan biridir:
  - (inceleme) bir hat "Acil" eşiğine (3 açık hata) ulaştı ya da sıfırlandı, ya da en kötü hat değişti. Eski koşul
    "bir hattın sayısı değişti" idi; A'da her doğrulanan bildirim saatinde bir açık hata olduğu için bu koşul hemen her
    hafta doğru olur ve "sessiz hafta" kuralı hiç çalışmazdı.
  - yeni bir istek bilindi,
  - bir düzeltme yayına girdi,
  - temsilci gerçekten yetişemedi.
- Okunmamış eski destek raporu, yenisi gelince kutudan düşer. Kutu dolmaz.

**B2B örneği**
```
Gönderen: Selin Koç · Müşteri temsilcisi
Konu: Destek · 12. hafta

EN ÇOK SORUN ÇIKAN
  Fatura   4 açık hata · 3 hesap · 140 kullanıcı   ↑
  Stok         2 açık hata · 1 hesap · 60 kullanıcı    ↓
EN ÇOK İSTENEN
  Toplu fatura onayı    Kuzey Lojistik, Yelken Ofis · $1.800/ay
  e-Defter dışa aktar   Poyraz Lojistik · $600/ay
BU HAFTA
  Stok düzeltmesi yayında: 3 → 0
  Hesap taleplerinden 2 tanesini kapattım.
  Yetişemedim: 5 bildirim cevapsız kaldı.

                                  [Fatura düzeltmesini aç]
```

**B2C örneği**
```
EN ÇOK SORUN ÇIKAN
  Eşitleme   3 açık hata · 2.100 kullanıcı   ↑
EN ÇOK İSTENEN
  Kargo takibi · 38 yorum   Taksit · 21 yorum   Favori satıcı · 9 yorum
SATICILARDAN                         (yalnız pazaryeri; E'nin hatlarıyla)
  Toplu ilan yükleme · 11 mağaza
```
- "Yetişemedim" satırı yalnız şu durumda çıkar: hafta sonunda en az 5 bildirim cevapsız [ÇALIŞMA] ve masanın haftalık
  doğrulaması gelen bildirimden az. (inceleme) Sayı A'nın `ProductState.reports_incoming()`'inden okunur (A §5.7
  okuma noktaları). A'nın ölçümünde gelen yığın 54 haftanın 52'sinde 0; satır yalnız masa boşken ya da temsilci sprint
  kartındayken çıkar, yani gerçekten seyrektir.
- Düğme en kötü hattın düzeltme kartını Sprint'te açar (Genel Bakış'ın Destek satırıyla aynı yol).
- Temsilci yokken rapor yoktur. B2B'de müşterinin sesi yalnız B'nin olaylarıyla gelir. B2C'de Sesler Genel Bakış'tadır.

### 2.9 B2B yıllık, B2C aylık gelir
**Öneri**
- Gelirin ortak dili **MRR** kalır: üst bar, Finans, Frank'in eşiği ve VC hep MRR okur. İki pazar arasında gösterim
  değişmez.
- B2B koltuk fiyatı **aylık** söylenir ve sözleşme **yıllıktır**: "koltuk başına ayda $35, 12 aylık sözleşme". Sektörde
  kurumsal yazılım böyle fiyatlanır.
- B2B'de **yıllık gelir (ARR = MRR × 12)** ikincil sayıdır. Bütün sözleşmeler 12 ay olduğu için bu hesap doğrudur.
  Şu üç yerde görünür:
  - Satış başlığında ölçü: `YILLIK $170.400`.
  - Genel Bakış'ın İş satırında.
  - Üst barda MRR'nin ipucunda: "Yıllık gelir $170.400 · 9 hesap, 12 aylık sözleşme".
- Pazarlığın onay şeridi sözleşmenin yıllık değerini de yazar: `60 koltuk · $35/ay · yıllık $25.200`.
- Nakit bugünkü gibi aylık tahsil edilir. Yıllık peşin tahsilat yoktur (açık soru 5).
- **Neden:** Yıllık peşin ödeme koşunun nakit eğrisini kökten değiştirir. Runway, kepenk ve tur kalibrasyonu baştan
  ayar ister. ARR bir gelir ölçüsüdür; peşin nakit ARR değildir.
- B2C'de yalnız MRR vardır. Finans'ta değişiklik yoktur: Finans nakdi gösterir, ARR nakit değildir.

### 2.10 "Onboarding" etiketinin kalkışı
| Yer | Bugün | Olacak |
|---|---|---|
| Satış hesap kartı | "Onboarding" etiketi | Kalkar (tabloda evre etiketi yok) |
| Satış hesap kartı | "Onboarding gelecek hafta bitiyor…" | Kalkar; ipucunda "İlk 4 hafta tabanı" |
| Ürün alanı | "Onboarding & Erişim" / kısa "Onboarding" | "İlk Kullanım ve Erişim" / "İlk kullanım" |
| Ar-Ge düğümü | "Onboarding Akışı" | "İlk Açılış Akışı" |
| İç kod adları (`ONBOARDING_*`, `onboarding_until`) | — | Kalır; oyuncu görmez |

### 2.11 Ayrılma eşiği
- **Öneri:** `eşik = 30 + 3 × (yıldız − 1) + ⌊sektör eki / 2⌋`.
- Sonuç: 1★ 30 · 2★ 33 · 3★ 36. Sektör eki: inşaat ve sağlık +2, sigorta +1. En yüksek eşik 38'dir.
- Büyük müşteri hâlâ biraz daha seçicidir; yalnız fark küçülür.
- Söz bağlı kaymalar aynı kalır: tutulan söz eşiği −5, kırılan +5, tavan +10.
- **Bot ölçümü** (bugünkü build, A öncesi; 3 tohum, 104 hafta; aşağıdaki "karşı olgu", aynı koşunun memnuniyet kaydından
  eşik değiştirilerek sayıldı):

| Eşik | Tohum 7 | Tohum 11 | Tohum 23 | Eşiğin altındaki hesap-haftası |
|---|---|---|---|---|
| Bugün (33 + 9×) | 22 (%6,7) | 24 (%7,0) | 16 (%4,8) | %0,5–0,7 |
| **Öneri (30 + 3×)** | **5 (%1,5)** | **4 (%1,2)** | **5 (%1,5)** | %0,2 |
| 28 + 3× | 3 (%0,9) | 0 | 5 (%1,5) | %0,1 |
| 30 sabit | 4 (%1,2) | 0 | 5 (%1,5) | %0,1 |

- Gerçek koşuda kaybedilen hesap 7, 24 ve 14'tü. Fark, elde tutma kâğıtları ile risk histerezisinden geliyor.
- Bütün kayıplar ilk 30 haftada. 40. haftadan sonra memnuniyetin onda biri bile 59'un altına inmiyor.
- **Uyarı:** Bu tabloda A'nın "hata churn'ü etkiler" terimi yok. A memnuniyete hesap başına hata terimi ekleyince
  dağılım aşağı kayacak. Nihai değer A'nın ardından yeniden ölçülür (C3'ün kapısı).
- (inceleme) **Karşı olgu yönteminin sınırları** (`scratchpad/c_runs/churn_cf.py`, yeniden koşuldu, sayılar tutuyor):
  - Bugünkü eşikte betik 22 ve 24 kayıp sayıyor, gerçek koşu 7 ve 24. Betik elde tutma kâğıtlarını ve risk
    histerezisini görmüyor; bu yüzden mutlak sayılar değil, eşikler arası sıra güvenilirdir. Bugünkü gerçek kayıp oranı
    %2,1 ile %7,0 arasıdır; "%5–7" yalnız betiğin sayısıdır.
  - İlk 4 haftanın tabanı eşik + 2'dir. Eşik inince taban da iner, memnuniyet 5. haftaya daha düşük girer. Betik eski
    tabanlı kaydı okuduğu için yeni eşikteki erken kaybı biraz az sayar.
  - Söz kaymaları (eşik ±5) betikte ilk kayıttan sabitlenir; sonraki sözler görünmez.
  - Bu yüzden C3'ün kapısı betikle değil, yeni formülle gerçek koşuyla ölçer.
- (inceleme) **A ile çatışma (sahip sorusu 1):** 40. haftadan sonra memnuniyet 59–67 bandında; A'nın hesap başına
  hata cezasının tavanı 20 puan. Eşik 30 + 3× olursa 3★ hesap bile en kötü durumda 39–47'de kalır ve eşiğin (36)
  üstündedir. Yani eşik inince A'nın "hata churn'ü etkiler" kararı B2B'de ilk 30 haftadan sonra neredeyse işlemez;
  A'nın "hiç düzeltmeyen B2B ürünü MRR'ın %47'sini kaybeder" ölçümü bugünkü eşikle yapıldı. Erdem'in iki isteği (eşik 30
  civarı, hata churn'e yol açar) bu noktada birbirine sürtünüyor. C3'ün kapısı bu yüzden iki kolu birlikte ölçer:
  düzelten bot ve hiç düzeltmeyen bot, ikisi de yeni eşikte. Hiç düzeltmeyen kolun kaybı bugünkünün yarısının altına
  düşerse Erdem'e iki yol sunulur: A'nın ceza tavanını (20) artırmak ya da eşiği daha az indirmek (33 + 4×, betikte
  %3,1 / %4,7).
- **B için iki senaryo** (B erteleme düşüşünü önerecek):
  - Eşik 30'a inerse, 40. haftadan sonra hesapların eşiğe uzaklığı ortanca +33 puan. Tek seferlik bir memnuniyet düşüşü
    zaten bir tikte siliniyor; erteleme bedeli ancak güven kaydı (trust) olarak yazılırsa ve ilk 30 haftada iz bırakır.
  - Eşik bugünkü gibi kalırsa, aynı düşüş ilk 30 haftada 2★ ve 3★ hesapları eşiğin altına kolayca iter.
  - Öneri: Eşik 30'a iner, B'nin erteleme bedeli güven kaydına yazılır. İki planın sayıları çelişirse ORTAK gereği bu
    tablo esastır.

---

## 3. İzlenebilirlik

**Karar defteri · Faz C**

| Madde | Nasıl karşılandı |
|---|---|
| Üç kâğıt: Genel Bakış, Sprint, Çeyrek; Genel Bakış v1'den önce kilitli | §2.1; C4 |
| Bloklar: Sürüm ve kalite, Destek, İstekler, Sunucu, İş özeti | §2.1; C4, C5 |
| Destek: Açık hata ve en kötü hat; tıklayınca Sprint'teki düzeltme kartı | §2.1 Destek; C4 (`product_view_requested`, A'nın `open_area` yolunu sarar; inceleme) |
| Rakip bloğu rakip kararına bağlı | §2.7: blok yok; fiyat konumu Satış'ta |
| Sunucu fazla ağır; Startup Company ve başka oyunlar araştırılır | §4.1; §2.3 |
| Birim: kullanıcı başına mı, 1.000 kullanıcı mı, koltuk mu | §2.3 ve §5.1: oyuncuya birim değil aylık fatura; ipucunda B2C 1.000 kullanıcı, B2B 50 koltuk |
| Doluluk ve otomatik ölçekleme gerekli mi | §2.3: doluluk kalkar, ölçekleme hep otomatik (açık soru 2) |
| Kalite kademeleri kalır, artı/eksi açık | §2.3 tablosu, kademe ipucu |
| 3★+ kurumsal sunucu ister, anlaşma iptal olmaz | §2.4; C2 (imza engeli silinir) |
| Şart sözleşmeye yazılır, oyuncu imzadan sonra geçer | §2.4 onay şeridi; C2 |
| Geçiş toplantı çıkışında ya da mailde tek tık; düğme aylık maliyeti ve artışı gösterir | §2.4; C2 |
| Rakip analizi var olsun mu, gerekçeyle | §2.7 (açık soru 3) |
| Hamle yapılmalı; fiyat konumu fena değil; duyum olabilir | §2.7: fiyat konumu var; duyum EA, gerekçeli |
| ERP tablosunda "Büyümeye açık" ve hafta sayısı yok | §2.5 |
| Eşik altında yalnız "Ayrılabilir" ya da "Yenilemeyebilir" | §2.5 Durum sütunu |
| Başka evre etiketi gerekiyorsa gerekçeyle | §2.5: yalnız "Yenilemeyecek · Ay" eklendi, gerekçeli |
| "Onboarding" ürün ve hesap görünümünden kalkar; ürün alanı yeniden adlandırılır | §2.10; C7 |
| Memnuniyet ipucu: kalite, açık hata, sunucu, söz | §2.5 ipucu. "Sunucu aşımı" doluluk kalktığı için "Kurumsal sunucu şartı" terimine döner |
| B2B yıllık / B2C aylık: fiyat yıllık mı, üst bar ve Finans, geçişte değişir mi | §2.9 (açık soru 5) |
| Yenileme: satışçı varsa mail, kurucu karar verir, yıldız belirler, sonuç maili | §2.6 A; C8 |
| Kimse atanmamışsa kurucuya "görüşmemiz gerekiyor" kartı | §2.6 B; C8 |
| Bugünkü temsilci yenileme kartları uzlaştırılır | §2.6: `customer.request_renewal` silinir; C8 |
| Haftalık rapor temsilciden; yeni bir şey yoksa gelmez | §2.8; C6 |
| İçerik: sorunlu hatlar sayıyla, en çok istenen, bu hafta, "Yetişemedim" yalnız gerçekten | §2.8; C6 |
| B2C'de istek yorum sayısıyla; satıcı istekleri ayrı | §2.2, §2.8 (satıcı ayrımı E'nin hat verisinden) |
| Rapordan düzeltme kartına düğme | §2.8; C6 |
| Temsilci yokken: B2B hata maili yok; B2C'de Sesler | §2.8, §2.1 B2C; C5 |
| İstekler yalnız temsilci bulunca; karta "İstenen · 38 yorum" | §2.2; C5 |
| Kurucunun müşteri görüşmesi yok; düşük memnuniyetli müşteriyle toplantı sonra | Eklenmedi. Yenileme görüşmesi kurucunun eylemi değil, yenileme kâğıdının seçeneği |
| Ayrılma eşiği: Erdem 30 civarı; öneri, etki, bot ölçümü | §2.11; C3 |

**Görev yazısı · tur 1 istekleri ve §5 soruları**

| Madde | Nasıl karşılandı |
|---|---|
| Sektörde kullanılan metrikler | İş satırı: MRR, yıllık gelir, hesap, bu ay kazanılan ve kaybedilen (logo churn). B2C: MRR, dönüşüm. Pazaryeri ölçüleri E'nin |
| Sekmeler pazara göre; B2C'de Satış boş | E'nin (Pazaryeri). C'nin B2B Satış kâğıtları §2.5 |
| Rakip analizi Ar-Ge'de var mı, PM'in aylık analizi | §1 Rakip, §2.7: yok, aylık rapor yok |
| Kapasite: kalite kademeleri, otomatik eşik ya da elle, görünür maliyet | §2.3: kademe var, ölçekleme hep otomatik, fatura görünür |
| Destek bloğu açık hataları gösterir, Sprint'e yönlendirir | §2.1 |
| ERP hesap yöneticisi görünümü: hesap, koltuk, memnuniyet, talepler | §2.5 |
| Sadeleşmiş sunucu: kademe, birim, doluluk, aşım bedeli, B'nin girdileri | §2.3, §5.1. Aşım yok; B kademeyi okur |
| Kurumsal şart akışı ve karşılanmazsa bedeli | §2.4 |
| Tablo sütunları, sıra, ipucu terimleri; hazır olan ve yeni veri | §2.5, §5.3 |
| Yenileme ile temsilci kartlarının birleşmesi; satışçı ataması; yıldızın etkisi | §2.6, §5.4 |
| Rapor verisinin kaynağı ve okunmamış mail yükü | §2.8, §5.5 |
| Genel Bakış'ın yerleşimi ve kâğıt yapısıyla birleşmesi | §2.1, §7 C4 (`D_seg_tabs` + `D_locked_tab`, onboarding'in sekmeli kâğıdı) |

**ORTAK sınırları**

| Sınır | Nasıl |
|---|---|
| Tek hata sayısı A'nın; C yalnız okur | Destek bloğu ve rapor A'nın fonksiyonlarını okur (A/B varsayımı, §5.7) |
| Sunucu: C kademeyi kurar, doluluğa karar verir | Doluluk kalkar. B yalnız `InfraSystem.provider()` okur |
| Ayrılma eşiği: C önerir ve ölçer | §2.11 |
| Sesler: C yeni bileşen kurar; build bar satırı A'nın | §2.1 |
| Pazaryeri sayıları E'nin; C İş satırında okur | §2.1 B2C İş satırı |
| MRR gösterimi C'nin | §2.9 |
| İstek verisi ve haftalık rapor C'nin; B istek kaynaklı olayları okur | `SprintCatalog.known_requests()` (yeni, inceleme: `open_requests()` değişmez) ve `b2c_asks()` B'nin teşekkür mailine açık |

---

## 4. Araştırma bulguları
Kaynaklar `C_ARASTIRMA.md`'de, oradan kısaltıldı.

### 4.1 Startup Company ve sunucu
- **Bulgu:** Startup Company'nin çekirdeği tek bir kapasite sayısıdır (CU): web, veritabanı ve önbelleğin en düşüğü.
  Oyuncular dengeli bir kule kurup çoğaltıyor; karar yükü bir kez oranı bulmak. Kesinti ya da aşım cezası hiçbir
  kaynakta geçmiyor. (steamcommunity.com/app/606800/discussions/…; wiki sayfası erişilemedi, arama özetinden.)
- **Bulgu:** Asıl karar sermaye ile aylık gider arasında: barındırılan sunucu pahalı ve esnek, kendi sunucun ucuz ama
  sermaye ister.
- **Bulgu:** Software Inc. sunucu mekaniği için kaynak bulunamadı.
- **Kararı nasıl etkiledi:** Sunucu tek karar ve tek sayıya indi: kademe ve aylık fatura. Doluluk kalktı. Bot ölçümü de
  doluluğun oyuncuya hiç karar sunmadığını gösterdi.

### 4.2 Gerçek SaaS barındırma
- **Bulgu:** Paylaşımlı mimaride müşteri başına kabaca ayda $50–500, ayrılmış ortamda $500–5.000 (tek satıcı sayfası,
  kaba). Standart müşteri paylaşımlı, kurumsal müşteri ayrılmış ortamda tutulur.
- **Bulgu:** SOC 2 Type II ve ayrılmış ortam kurumsal müşterinin tipik şartıdır.
- **Bulgu:** Olgun SaaS'ta barındırma gelirin %5–10'udur.
- **Bulgu:** Koltuk ya da istek başına barındırma birimi için otoriter sayı yok.
- **Kararı nasıl etkiledi:**
  - Kurumsal şart "kurumsal kademe" olarak kaldı.
  - Birim oyuncuya gösterilmez, yalnız ipucunda yazar.
  - Fiyatlar değişmedi. Bot koşusunun 101. haftasında sunucu faturası MRR'nin yaklaşık %3'ü (B2B $5.642 / $181.790;
    B2C $4.662 / $159.152). Bu, %5–10 bandının altında; ama asıl barındırma yükü ayrı "servis gideri" kaleminde (MRR'nin
    %30–37'si). Sabit değiştirmek kalibrasyon işidir, burada önerilmez.

### 4.3 Yıllık sözleşme, MRR, ARR, yenileme
- **Bulgu:** ARR, sözleşme değerinin yıllıklandırılmasıdır. Yıllık peşin nakit ARR değildir; peşin $1.200 yine ayda $100
  MRR'dir. Karışık faturalamada MRR × 12 aşırı raporlar; bizde bütün sözleşmeler 12 ay olduğundan doğrudur.
  (cut-the-saas.com, chargeover.com)
- **Bulgu:** Fiyat artışı tipik olarak yılda %3–5; satıcı varsayılanları %7–15. (redresscompliance.com, düşük güven)
- **Bulgu:** Yenilemenin tek sahibi yok. En yaygın model ayrı hesap yöneticisi; satışı kapatan AE'nin sahiplenmesi de
  yaygın. CS ekiplerinin yalnız %11,8'i yenilemeden tek başına sorumlu. (customersuccesscollective.com)
- **Kararı nasıl etkiledi:**
  - MRR tek dil kaldı; ARR ikincil gösterim oldu.
  - Nakit aylık kaldı.
  - Yenilemeyi Erdem'in dediği gibi satışçı yürütür (AE modeli). Temsilci memnuniyete bakar (CSM modeli).
  - Zam %8 [ÇALIŞMA], bandın üst ucu. Gerekçe: oyunda yılda tek fırsat var ve satışçı yıldızı bunu kırpıyor.

### 4.4 Rakip analizi
- **Bulgu:** Big Ambitions'ın rakip ekranı karara bağlı sayılar verir (işletme, haftalık gelir, bölge) ve rakip ancak
  aynı alana girince etkin olur.
- **Bulgu:** Gerçek PM analizi fiyat, yol haritası ve kayıp anlaşma kararlarına iner. Kimsenin okumadığı kapsamlı
  belge tipik bir başarısızlıktır.
- **Kararı nasıl etkiledi:** Kaldıracı olmayan bir rapor kurulmadı. Fiyat konumu fiyat kararının yanına kondu.

### 4.5 Sektör metrikleri (tur 2 araştırması)
- MRR akışı, hesap ve koltuk, logo churn B2B panolarının çekirdeğidir. İş satırı bunların en az kümesini taşır.

---

## 5. Model

### 5.1 Sunucu
- `InfraSystem.daily_tick` canlı üründe kapasiteyi her hafta yeniden kurar:
  `birim = ceil(hizmet edilen × yük / (birim boyu × HEDEF_DOLULUK))`, canlıyken en az 1.
  `HEDEF_DOLULUK` = 0,80; bugünkü sürüm kuralının değeri.
- Fatura = birim × kademe birim fiyatı (değişmez).
- Etkin kapasite hep hizmet edilenin üstündedir, aşım olmaz. Aşımın üç etkisi ve onları okuyan kod silinir.
- Kademe etkileri:
  - Ekonomik: bildirim ×1,25 (var).
  - Satış görüşmesinin güven sinyali (var, `W_PROVIDER_TIER` 0,10, Ekonomik'te eksi). (inceleme) Sinyalin bugünkü
    girdisi `blocks_enterprise_signature()` (`sales_meeting_system.gd:157`); o fonksiyon silindiği için satır
    `InfraSystem.provider() == PROVIDER_LOCAL`'a bağlanır. `meets_enterprise_trust()` ve seam `urun.enterprise_trust`
    SİLİNMEZ: beş olay kartı (`security_review`, `leak_questions`, `named_in_leak`, `password_rule`, `launch_leak`)
    okuyor. `urun.capacity_tier` seam'i görüşme çipinin etiketi olarak kalır.
  - Kesinti çarpanı B'nin.
- Kurumsal şart:
  - `ENTERPRISE_CLAUSE_STAR` = 3. Hesabın yıldızı 3 ya da üstüyse şart vardır; türetilir, saklanmaz.
  - Kademe Kurumsal değilse hedefe `SERVER_CLAUSE_PENALTY` = −10 [ÇALIŞMA] eklenir.
  - Terim taban (ilk 4 hafta) hesabından önce uygulanır; taban onu o süre örter.
- Ar-Ge düğümleri:
  - `scalable_backend` yük bölenini değiştirmeye devam eder. Artık doğrudan faturayı düşürür.
  - `incident_playbook` bugün aşım cezasını yumuşatıyor. Aşım kalkınca bu etkisi ölür. (inceleme) B etkisini aldı:
    araştırılmışsa bütün kesinti süreleri ×0,75 [ÇALIŞMA] (B incelemesi bulgu 10). C yalnız düğümün oyuncu metnini
    (`PROD_RND_NODE_INCIDENT_PLAYBOOK*` açıklama, açılış ve keşif) "kesintiye hazırlık" anlamına göre yeniden yazar ve
    `rnd_tree.json`'daki `effect` adını B'nin adıyla eşler.

### 5.2 Ayrılma eşiği ve memnuniyet hedefi
- `seed_tolerance = 30 + 3 × (yıldız − 1) + floor(sektör eki / 2)`; sektör eki tablosu aynı (inşaat 5, sağlık 5,
  sigorta 3).
- Hedef tek fonksiyondan, terim listesi olarak kurulur: `B2BSalesSystem.target_terms(c) -> Array[{key, value, note}]`.
  - `satisfaction_target` bu terimlerin toplamıdır.
  - İpucu aynı listeyi çizer.
  - Terimler:
    1. Ürün kararlılığı (bugünkü kararlılık ekseni; A hatayı ondan ayırırsa hatasız hâli; A/B varsayımı).
    2. Kullandığı hatlarda açık hata (A'nın hesap başına terimi; A/B varsayımı).
    3. Kurumsal sunucu şartı (C).
    4. İlk 4 hafta tabanı (var, eşik + 2'ye yükseltir).
    5. Sözler (`trust_offset`, var).

### 5.3 Hesap tablosunun verisi
| Sütun | Kaynak | Hazır mı |
|---|---|---|
| Firma, yıldız, koltuk, aylık | `Customer` | Hazır |
| Memnuniyet ve ipucu | `satisfaction`, `target_terms` | Yeni fonksiyon |
| Durum | `satisfaction < tolerance`, `term_end`, `leaves_on_day` | Yeni türetme ve 1 alan |
| Yenileme | `term_end(c)` = imza + k × 52 hafta | Yeni türetme |
| İstek | `PromiseRegistry.get_open_for`, `SprintCatalog.known_requests()` | Söz hazır, bilinen istek yeni süzgeç |
| Satışçı | `Customer.seller_id` | Yeni alan |
| Temsilci | `assigned_to` | Hazır |

### 5.4 Yenileme
- Sabitler (`B2BConstants`):
  - `CONTRACT_WEEKS` 52 (`sprint.json` `request.contract_weeks` buraya taşınır; talepler de buradan okur).
  - `RENEWAL_RAISE_PCT` 0,08 [ÇALIŞMA].
  - `RENEWAL_RAISE_BY_STAR_GAP` {+1 ve üstü: 1,0; 0: 0,6; −1: 0,4; −2 ve altı: 0} [ÇALIŞMA].
  - `RENEWAL_RAISE_HEADROOM` 5 [ÇALIŞMA]: eşiğe bu kadar yakın hesap, görüşen daha düşük yıldızlıysa zammı reddeder.
  - `RENEWAL_REFUSE_TRUST` −6 [ÇALIŞMA].
  - `RENEWAL_DISCOUNT_PCT` 0,10 [ÇALIŞMA]; `RENEWAL_DISCOUNT_TRUST` +4 [ÇALIŞMA].
  - `RENEWAL_DESK_WEEKS` 1 [ÇALIŞMA].
  - `RENEWAL_FOUNDER_HOURS_PER_ACCOUNT` 2 [ÇALIŞMA]; `RENEWAL_FOUNDER_HOURS_MAX` 24 [ÇALIŞMA].
  - `RENEWAL_CARD_EXPIRES_WEEKS` 2.
- Yeni `Customer` alanları:
  - `seller_id: String = ""`: imzada satış masası çalışanı. Kurucunun görüşmesiyle imzalanan hesapta boştur.
  - `renewal_stage: String = ""`: "" | "asked" | "desk".
  - `renewal_choice: String = ""`.
  - `renewal_until: int = -1`.
  - `leaves_on_day: int = -1`.
- Akış `SalesRepSystem` içinde, satış masasının günlük tikine eklenir (yeni sistem yok):
  1. Ayın ilk tikinde gruplar kurulur.
  2. `EventGate.request("customer.renewal_ask", {employee})` ya da `"customer.renewal_meet"`.
  3. Fiil `renewal_choose(choice)` seçimi gruba yazar. Satışçı yolunda masa `renewal_until`'e kadar doludur
     (`SalesLedger.rep_busy` bunu da sayar). Kurucu yolunda sonuç hemen uygulanır ve kurucu saati yazılır.
  4. Masa süresi bitince sonuç uygulanır: `CustomerRegistry.set_mrr` + `SalesSystem.reflect_mrr()`, koltuk fiyatı,
     güven, `leaves_on_day`. Ardından `MessageSystem.post("renewal_result", …)`.
  5. `leaves_on_day` gelince `B2BSalesSystem._churn`.
- Kâğıt gövdesi hesap listesini seam'den okur: `sales.renewal_month`, `sales.renewal_accounts`. Kart gövdesinde yalnız
  `{slot}` ve `{seam:…}` çözülür. Hesap satırları (memnuniyet ve eşik) kâğıdın bilgi bloğudur; Satış'ın hesap maili
  kalıbıyla çizilir.
- Fiiller:
  - `renewal_choose` (yeni, C).
  - (inceleme) Kurucu saati için `founder_hours` fiilini C kurar: `GameState.add_founder_meeting_hours` çağırır,
    çipi `EvChips.describe`'a girer, `_vocabulary.md` `--event-vocab` ile yenilenir. B bu fiili kurmuyor; B'nin
    kurucu bedelleri `productivity_mod` ile yazılıyor (B incelemesi bulgu 11).
  - Çip etiketleri `EvChips.describe`'a girer: "Zam iste %8", "Bu hafta 6 saat".
- `customer.request_renewal` kartı, `CS_KIND_RENEWAL`, `RENEWAL_MIN_TENURE_WEEKS`, `pick_request_kind`'in yenileme kolu
  ve `B2B_EV_RENEWAL_*` anahtarları silinir.
- Bot (RunProbe) yeni kâğıtları cevaplar: memnunsa zam, eşik altı hesap varsa indirim. Bu bir harness değişikliğidir,
  ayrı raporlanır.

### 5.5 İstekler ve haftalık rapor
- **Bilinen istek:** `SprintBridges.tick_requests` temsilci görevdeyse açık isteklere `known: true` yazar (köprünün
  yazdığı `requests` anahtarı).
  - (inceleme) Yeni `SprintCatalog.known_requests()` yalnız bilinenleri döndürür; B'nin teşekkür maili ve "ne zaman
    geliyor" kartı bunu okur (B planı §5.7). `open_requests()` bugünkü anlamıyla kalır; talep kartının görünümü
    isteğin `known` alanına bakar. Eski metin `open_requests()`'u daraltıyordu ve B'nin beklediği ad hiç doğmuyordu.
  - Bilinmeyen istek sprintte düz özellik kartıdır.
- **B2C:** `SprintCatalog.b2c_asks()` saklanmaz, türetilir. Canlı hatlarda sonraki kademe, kapısı açık, kullanım
  ağırlığına göre sıralanır. Yorum = round(kitle × `ASK_COMMENT_RATE` 0,004 [ÇALIŞMA] × pay). İlk üç döner.
- **Temsilci:** `CustomerRepSystem.ranked_reps()` ilk elemanı (var olan sıra).
- **Rapor:**
  - `CustomerRepSystem._tick_weekly_report()` kurulur; satış raporunun kalıbıdır (`sales_rep_system.gd`
    `_tick_weekly_summary`).
  - Durumu: `support_weekly_anchor_day` ve `support_report_last` = {hat: sayı, bilinen istek kimlikleri}. İkisi de
    `GameState` bayrağıdır.
  - "Bu hafta" satırları şunlardan gelir: bu haftaki sürümün düzeltme kartları, satış defterindeki `cs_absorb`
    kayıtları ve yeni bilinen istekler.
- **Mail yükü:** `MessageSystem.post(kind, key, args, supersede := false)`. `supersede` açıkken aynı türden okunmamış
  eski mesaj düşer. Yalnız `support_week` kullanır.

### 5.6 Ürün penceresi
- `ProductTab.VIEW_KEYS` üçe çıkar. `ProductModel` sözleşmesine `overview` sözlüğü eklenir
  (`release`, `support`, `asks`, `server`, `business`). Saf okuyucu `ProductModel` içinde kalır; yeni dosya
  `scripts/tabs/product/overview_view.gd` yalnız çizer.
- Yeni sinyal `EventBus.product_view_requested(view: String, focus: Dictionary)`. Odak bugünkü `ui.open_area` ve
  `ui.hover_card` alanlarına yazılır (kare için zorlanan hover zaten var).
- (inceleme) A, Destek kartının tıklamasını `ProductTab.open_area(hat_alanı)` ile kuruyor ve A'nın incelemesi "C kendi
  sinyalini kurunca bu tıklama o sinyale taşınır" diyor. Sinyal A'nın yolunu sarar, ikinci bir açma yolu kurulmaz.
  Build bar tıklamasının hedefi değişmez (Sprint, en kötü hattın alanı).

### 5.7 A/B varsayımları (tek liste)
1. A: (inceleme: adlar A planından) `ProductState.open_bugs()`, `open_bugs_by_line()`, `worst_bug_line()`,
   `open_bugs_delta(hat)`; hat satırının metni, ipucu ve oku `ProductModel.bug_row(hat) -> {text, tip, delta}`;
   etkilenen sayı `SprintCatalog.line_impact(hat)`; hesap başına terim `B2BSalesSystem.account_bugs(c)` ×
   `B2BConstants.B2B_BUG_SAT_PER`, tavan `_CAP`.
2. A: Düzeltme kartının kimliği `fix:<hat>` kalır.
3. A: Hesap başına açık hata terimi memnuniyet hedefine bir terim olarak girer; `target_terms` onu listeler.
4. A: Gelen ve doğrulanan bildirim akışı kalır ("Yetişemedim" `ProductState.reports_incoming()`'i okur). "Kaçırıldı"
   A'da kalkar.
5. A: Build bar'ın destek satırı tıklanabilir kalır; hedefi A'nındır (inceleme).
6. B: Kesinti olasılığı yalnız sunucu kademesini okur ve kademe başına çarpan tablosu tutar (`IncidentSystem.tier_mult`).
   (inceleme) B, bugünkü `outage.json`'u (`urun.capacity_state` okuyan tek kart) silip yerine yenisini koyuyor; B'nin
   sahip sorusu 6 kabul edilirse B doluluğu hiç okumaz. Reddedilirse B'nin `_load_mult()`'ı C1'de silinir.
7. ~~B: Kurucu saati fiili (`founder_hours`) kurulur.~~ (inceleme) C kurar; bkz. §5.4.
8. B: Sürüm anı teşekkür maili `SprintCatalog.known_requests()`'ten okur.
9. B: `incident_playbook` düğümünün etkisini kesinti modeline alır. (inceleme) B aldı (süreler ×0,75); C yalnız metni
   yazar.

### 5.8 Kayıt şeması
- (inceleme) Şema numarası A'nın bıraktığı 16 kalır (A K3 şemayı 16'ya çıkarıyor); C artırmaz. Yeni alanların hepsi
  anlamlı varsayılan taşır:
  - `Customer.seller_id` "": (inceleme) yüklemede boşsa var olan `acquisition_source`'tan türetilir
    (`"sales_rep:<id>"` → o kişi, öteki her kaynak → kurucu). Ayrı alan yine gerekir, çünkü "Devret" satışçıyı
    değiştirir ama kazanım kaynağı değişmez. Eski metin "eski hesaplar kurucunun" diyordu; bu masanın imzaladığı
    hesapları da kurucuya yığardı.
  - `renewal_*` boş.
  - `leaves_on_day` −1.
  - İstekte `known` yoksa false; ilk tikte temsilci varsa bilinir olur.
- Eski kayıtta kıdemi 52 haftayı geçmiş hesaplar sıradaki ayın grubuna girer. Göç gerekmez.
- `InfraSystem` kayıt bloğu (`warning_consumed_version`) silinir. `from_dict` boş sözlüğü zaten yok sayıyor; eski
  kayıttaki anahtar okunmaz.

### 5.9 Silinecek kod
- `InfraSystem`:
  - `OVERAGE_*`, `OCCUPANCY_*`, `STATE_*`, `capacity_state`, `is_over_capacity`, `occupancy`
  - `satisfaction_delta_per_day`, `acquisition_multiplier`, `adjust_capacity`, `CAPACITY_STEP`
  - `blocks_enterprise_signature`, `due_capacity_warning`, `mark_capacity_warning_shown`
  - `_warning_consumed_version` ve kayıt bloğu, `suggested_start_units`
- Okuyucuları:
  - `support_system.gd:274`, `sales_system.gd:191`, `b2b_sales_system.gd:504`
  - `sprint_catalog.gd` `_over_capacity` ve `sprint.json` `infra_alert`
  - `sprint_bridges.gd:119` (sürümde büyütme) ve `on_mvp` başlangıç birimi (otomatik kurulur)
  - `negotiation_system.gd:266-267` ve `NEG_CAPACITY`
  - `sales_probes.gd:72-74`, `run_probe.gd` `occ=`
  - `seams_product.gd` `urun.capacity_state` (B'nin kartı okumuyorsa)
- Balina ve kayıp:
  - `SalesConstants.WHALE_COND_PROVIDER` ve arketip koşullarındaki iki kullanım
  - `LOSS_PROVIDER_TRUST` ve dalları, metin anahtarları
  - `sales_faucet_system.gd:276-280`, `sales_ledger.gd:341-342`
- Satış kartları:
  - `sales_tab.gd` `_account_card`, `_satisfaction_row` churn kareleri, `PHASE_TAGS`
  - `SALES_CHIP_*` evre anahtarları, `SALES_ONBOARDING_ENDS`, `SALES_CHURN_COUNTDOWN*`
  - `B2BSalesSystem.onboarding_ends_under_bar`
- Yenileme talebi: §5.4'teki liste.
- Her silmede smoke vakaları aynı commit'te güncellenir. Bulmak için:
  `grep -n "InfraSystem\.\|request_renewal\|WHALE_COND_PROVIDER\|onboarding_ends_under_bar" scripts/debug/*.gd`.

### 5.10 Onay bekliyor (tasarım sabitleri ve kurallar)
| Sabit / kural | Değer |
|---|---|
| Doluluk ve aşım kalkar, ölçekleme hep otomatik | kural (GDD Ürün §10 değişir; `GDDs/GUNCELLEMELER.md`'ye yazılır) |
| `HEDEF_DOLULUK` | 0,80 |
| Ekonomik sunucu imzayı engellemez; 3★+ şart | kural |
| `ENTERPRISE_CLAUSE_STAR` / `SERVER_CLAUSE_PENALTY` | 3 / −10 |
| Eşik formülü | 30 + 3 × (yıldız − 1) + ⌊sektör / 2⌋ |
| Eşik ipucunda görünür (bugün gizli) | kural (Satış GDD'si değişir) |
| `CONTRACT_WEEKS` | 52 |
| Yenileme zam / indirim / kademeler | %8 · %10 · {1,0; 0,6; 0,4; 0} |
| `RENEWAL_RAISE_HEADROOM` / `RENEWAL_REFUSE_TRUST` / `RENEWAL_DISCOUNT_TRUST` | 5 / −6 / +4 |
| `RENEWAL_DESK_WEEKS` | 1 |
| Kurucu saati | hesap başına 2, en çok 24 |
| `ASK_COMMENT_RATE` | 0,004 |
| "Yetişemedim" eşiği | 5 cevapsız bildirim |
| Rakip koltuk fiyatları (`rivals.json` `erp.seat_prices`) | $52 · $44 · $39 |

---

## 6. Metin taslakları
Önce İngilizce yazıldı; Türkçe yeniden yazımdır. Tire yok. Hepsi "TR/EN onay bekliyor". `{…}` adlı yer tutucudur;
yer tutucuya ek getirilmez.

### 6.1 Ürün penceresi
| Anahtar | EN | TR |
|---|---|---|
| `PRODUCT_VIEW_OVERVIEW` | Overview | Genel Bakış |
| `PRODUCT_OVERVIEW_LOCKED` | Opens when v1.0 ships. | v1.0 yayınlanınca açılır. |
| `OV_RELEASE_HEAD` | Release | Sürüm |
| `OV_RELEASE_AGE` / `_ONE` | {version} · {n} weeks ago / {version} · last week | {version} · {n} hafta önce / {version} · geçen hafta |
| `OV_RELEASE_NEXT` | Next: {version} · Sprint {n} | Sonraki: {version} · Sprint {n} |
| `OV_SUPPORT_HEAD` | Support | Destek |
| `OV_OPEN_BUGS` | Open bugs | Açık hata |
| `OV_REP` | Rep: {name} | Temsilci: {name} |
| `OV_REP_NONE` | No customer rep | Müşteri temsilcisi yok |
| `OV_VOICES_HEAD` | Voices | Sesler |
| `OV_ASKS_HEAD` | Requests | İstekler |
| `OV_ASK_B2B` | {feature} · {accounts} · {mrr} a month | {feature} · {accounts} · ayda {mrr} |
| `OV_ASK_B2C` | {feature} · {n} comments | {feature} · {n} yorum |
| `OV_SERVER_HEAD` | Server | Sunucu |
| `SERVER_TIER_LOCAL` / `_CLOUD` / `_ENTERPRISE` | Economy / Standard / Enterprise | Ekonomik / Standart / Kurumsal |
| `OV_SERVER_BILL_USERS` | {bill} a month · {n} users | Ayda {bill} · {n} kullanıcı |
| `OV_SERVER_BILL_SEATS` | {bill} a month · {n} seats | Ayda {bill} · {n} koltuk |
| `OV_SERVER_PREVIEW` | {from} → {to} · {old} → {new} a month | {from} → {to} · ayda {old} → {new} |
| `OV_SERVER_SWITCH` / `OV_SERVER_CANCEL` | Switch / Cancel | Geç / Vazgeç |
| `OV_SERVER_WAITING` | Accounts expecting an enterprise server: {n} | Kurumsal sunucu bekleyen hesap: {n} |
| `SERVER_TIP_PRICE_USERS` | {price} a month per 1,000 users | 1.000 kullanıcı başına ayda {price} |
| `SERVER_TIP_PRICE_SEATS` | {price} a month per 50 seats | 50 koltuk başına ayda {price} |
| `SERVER_TIP_OUTAGE` | Outage odds ×{mult} | Kesinti olasılığı ×{mult} |
| `SERVER_TIP_REPORTS` | 25% more bug reports | %25 daha fazla bildirim |
| `SERVER_TIP_PITCH` | Big clients trust it less at the table | Büyük müşteri görüşmede ona daha az güvenir |
| `SERVER_TIP_CLAUSE_NO` / `_YES` | Does not meet an enterprise contract / Meets an enterprise contract | Kurumsal sözleşme şartını karşılamaz / Kurumsal sözleşme şartını karşılar |
| `OV_BIZ_HEAD` | Business | İş |
| `OV_BIZ_B2B` | MRR {mrr} · ARR {arr} · {n} accounts · this month +{won} −{lost} | MRR {mrr} · Yıllık {arr} · {n} hesap · bu ay +{won} −{lost} |
| `OV_BIZ_B2C` | MRR {mrr} · conversion {pct} | MRR {mrr} · dönüşüm {pct} |
| `PRODUCT_AREA_ONBOARDING` (değişir) | First Use & Access | İlk Kullanım ve Erişim |
| `PRODUCT_AREA_ONBOARDING_SHORT` (değişir) | First use | İlk kullanım |
| `PROD_RND_NODE_ONBOARDING_FLOW` (değişir) | First Run Flow | İlk Açılış Akışı |

**Sesler** (anahtar `VOICE_<HAT>_<1|2>`, 14 hat × 2 = 28 satır; örnekler):
| Anahtar | EN | TR |
|---|---|---|
| `VOICE_LINE_NOTE_TOOL_SYNC_1` | ★★☆☆☆ "The note I typed on my phone never reached my laptop. I wrote it twice." | ★★☆☆☆ "Telefonda yazdığım not bilgisayara gelmedi, iki kez yeniden yazdım." |
| `VOICE_LINE_NOTE_TOOL_SEARCH_1` | ★☆☆☆☆ "I can't find a note even when I know its title." | ★☆☆☆☆ "Başlığını bilsem bile aradığım notu bulamıyorum." |
| `VOICE_LINE_VIDEO_CLIP_CAPTIONS_1` | ★★☆☆☆ "The captions drift a second behind by the end of the clip." | ★★☆☆☆ "Klibin sonuna doğru altyazı bir saniye geriden geliyor." |
| `VOICE_LINE_SHARED_MOBILE_1` | ★★☆☆☆ "On my phone the app closes when I switch screens." | ★★☆☆☆ "Telefonda ekran değiştirince uygulama kapanıyor." |

### 6.2 Satış
| Anahtar | EN | TR |
|---|---|---|
| `SALES_PAPER_LEADS` / `SALES_PAPER_ACCOUNTS` | Leads / Accounts | Adaylar / Hesaplar |
| `SALES_KPI_ACCOUNTS` / `SALES_KPI_MRR` / `SALES_KPI_ARR` / `SALES_KPI_MONTH` | Accounts / MRR / ARR / This month | Hesap / MRR / Yıllık / Bu ay |
| `SALES_COL_COMPANY` … `SALES_COL_STEWARD` | Company · Seats · Monthly · Satisfaction · Status · Renewal · Request · Seller · Rep | Firma · Koltuk · Aylık · Memnuniyet · Durum · Yenileme · İstek · Satışçı · Temsilci |
| `SALES_STATUS_MAY_LEAVE` | May leave | Ayrılabilir |
| `SALES_STATUS_MAY_NOT_RENEW` | May not renew | Yenilemeyebilir |
| `SALES_STATUS_NOT_RENEWING` | Not renewing · {month} | Yenilemeyecek · {month} |
| `SALES_SELLER_FOUNDER` | You | Sen |
| `SALES_REQ_PROMISE` | Promised · {feature} · Sprint {n} | Söz · {feature} · Sprint {n} |
| `SALES_TABLE_FOOT` | {n} accounts · {seats} seats · {mrr} a month | {n} hesap · {seats} koltuk · ayda {mrr} |
| `SAT_TIP_HEAD` | Satisfaction {now}, heading to {target} | Memnuniyet {now}, hedef {target} |
| `SAT_TERM_QUALITY` | Product stability | Ürün kararlılığı |
| `SAT_TERM_BUGS` | Open bugs on the lines they use | Kullandığı hatlarda açık hata |
| `SAT_TERM_SERVER` | Enterprise server clause | Kurumsal sunucu şartı |
| `SAT_TERM_TRUST` (inceleme; eski `SAT_TERM_PROMISES`) | Promises and outages | Söz ve kesintiler |
| `SAT_TERM_FLOOR` | First 4 weeks floor · at least {n} | İlk 4 hafta tabanı · en az {n} |
| `SAT_TERM_BAR` | Leaves under {n} | Ayrılma eşiği {n} |
| `SALES_STANCE_RIVALS` | Rival seat prices: {list} | Rakiplerin koltuk fiyatı: {list} |
| `TOPBAR_MRR_TIP_B2B` | ARR {arr} · {n} accounts on 12 month contracts | Yıllık gelir {arr} · 12 aylık sözleşmeli {n} hesap |
| `NEG_CONTRACT_YEAR` | Yearly {amount} | Yıllık {amount} |
| `NEG_SERVER_CLAUSE` | Contract clause: enterprise server · {delta} a month more | Sözleşme maddesi: kurumsal sunucu · ayda {delta} fazla |
| `SERVER_SWITCH_BUTTON` | Move to Enterprise · {old} → {new} a month | Kurumsal sunucuya geç · ayda {old} → {new} |
| `MEET_LATER` | Later | Sonra |

### 6.3 Mailler ve kâğıtlar
**Sunucu maddesi maili** (`server_clause`)
- Konu: EN "Server clause in our contract" · TR "Sözleşmedeki sunucu maddesi"
- Gövde EN: "As we agreed in the contract, we expect our data on an enterprise grade server. Let us know once it is
  moved."
- Gövde TR: "Sözleşmede konuştuğumuz gibi verilerimizin kurumsal düzeyde bir sunucuda tutulmasını bekliyoruz. Taşıma
  bittiğinde haber verirseniz seviniriz."

**Satışçının yenileme kâğıdı** (`customer.renewal_ask`)
- Başlık EN "{seam:sales.renewal_month} renewals" · TR "{seam:sales.renewal_month} yenilemeleri"
- Gövde EN: "These contracts end in {seam:sales.renewal_month}: {seam:sales.renewal_accounts}. Do we raise the price
  or renew them as they are?"
- Gövde TR: "Şu sözleşmeler {seam:sales.renewal_month} ayında bitiyor: {seam:sales.renewal_accounts}. Fiyatı artıralım
  mı, aynı fiyattan mı yenileyelim?"
- Seçenekler:
  - EN "Ask the happy ones for 8% more" · TR "Memnun olanlardan %8 zam iste"
  - EN "Renew them all at today's price" · TR "Hepsini aynı fiyattan yenile"
  - EN "Offer 10% off to the ones who may leave" · TR "Ayrılabilecek olanlara %10 indirim öner"
  - Kilit gerekçesi EN "Every account here is above its bar." · TR "Buradaki hesapların hepsi eşiğin üstünde."
- Süresi dolunca EN "{employee} renewed them at today's price." · TR "{employee} hepsini aynı fiyattan yeniledi."

**Kurucunun görüşme kâğıdı** (`customer.renewal_meet`)
- Başlık EN "Contracts ending in {seam:sales.renewal_month}" · TR "{seam:sales.renewal_month} ayında biten sözleşmeler"
- Gövde EN: "Our contracts with these customers end in {seam:sales.renewal_month}: {seam:sales.renewal_accounts}. We
  need to sit down with them."
- Gövde TR (inceleme: "X için sözleşmeler" kuruluşu yerine): "Şu müşterilerle sözleşmemiz {seam:sales.renewal_month}
  ayında bitiyor: {seam:sales.renewal_accounts}. Onlarla görüşmemiz gerekiyor."
- Seçenekler:
  - EN "Meet them and ask the happy ones for 8% more" · TR "Görüşmeleri yap, memnun olanlardan %8 zam iste"
  - EN "Meet them and renew at today's price" · TR "Görüşmeleri yap, aynı fiyattan yenile"
  - EN "Offer 10% off to the ones who may leave" · TR "Ayrılabilecek olanlara %10 indirim öner"
  - EN "Hand the accounts to {employee}" · TR "Hesapları {employee} üstlensin"
  - Kilit gerekçesi (devret) EN "Nobody works the sales desk." · TR "Satış masasında kimse yok."

**Yenileme sonucu maili** (`renewal_result`)
- Konu EN "{month} renewals done" · TR "{month} yenilemeleri tamam"
- Sütunlar EN "Company · Before · After · Change" · TR "Firma · Eski · Yeni · Değişim"
- Satırlar:
  - EN "Did not take the raise" · TR "Zammı kabul etmediler"
  - EN "Not renewing. The contract ends in {month}." · TR "Yenilemeyecek. Sözleşmesi {month} ayında bitiyor."
- Alt satır EN "Total: {delta} a month" · TR "Toplam: ayda {delta}"

**Haftalık destek raporu** (`support_week`)
| Anahtar | EN | TR |
|---|---|---|
| `SUPPORT_WEEK_TITLE` | Support · week {n} | Destek · {n}. hafta |
| `SUP_RPT_TROUBLE` | Most trouble | En çok sorun çıkan |
| `SUP_RPT_ASKED` | Most asked for | En çok istenen |
| `SUP_RPT_SELLERS` | From sellers | Satıcılardan |
| `SUP_RPT_WEEK` | This week | Bu hafta |
| `SUP_RPT_SHIPPED` | The {line} fix is live: {from} to {to} | {line} düzeltmesi yayında: {from} → {to} |
| `SUP_RPT_ABSORBED` / `_ONE` | I closed {n} account requests. / I closed one account request. | Hesap taleplerinden {n} tanesini kapattım. / Bir hesap talebini kapattım. |
| `SUP_RPT_NEW_ASK` | {feature} was asked for by {accounts}. | {feature} isteyen hesaplar: {accounts}. |
| `SUP_RPT_BEHIND` | I could not keep up: {n} reports are still unanswered. | Yetişemedim: {n} bildirim cevapsız kaldı. |
| `SUP_RPT_OPEN_FIX` | Open the {line} fix | {line} düzeltmesini aç |
| `SUP_RPT_SELLER_ROW` | {feature} · {n} stores | {feature} · {n} mağaza |

Not: (inceleme) `SUP_RPT_NEW_ASK` TR'de iki yer tutucu yan yana durup özneyi belirsizleştiriyordu ("Kuzey Lojistik,
Yelken Ofis Toplu fatura onayı istedi"); yeni biçimde yer tutucular ek almaz ve cümle tek okunur. Glossary denetimi C6'da
`loc_residue` ile yapılır. "Yıllık" (ARR) için glossary'ye satır önerilir: TR'de ARR ödünç kelime listesinde yok.

---

## 7. Uygulama dilimleri
Her commit'te kapı sırası CLAUDE.md §12'dir: `--event-lint` → `loc_residue` → `loc_csv_integrity` → hedefli smoke.
Ekran kapıları sırayla ve pencerelidir; ayrı `APPDATA` ile koşar. (inceleme) Tam smoke koşulmaz: Erdem 2026-10-06'da
"push et doğrudan push demektir, öncesinde tam smoke yok" dedi. Push yalnız Erdem'in sözüyle.

**C1 · Sunucu modeli sadeleşir (mantık)**
- Ne:
  - Haftalık otomatik ölçekleme, aşağı ve yukarı.
  - Doluluk ve aşım etkileri silinir.
  - Ekonomik sunucunun imza engeli, balina sağlayıcı koşulu ve sağlayıcı kayıp nedeni silinir.
  - Görüşmenin güven sinyali kalır.
  - `GDDs/GUNCELLEMELER.md`'ye Ürün §10 notu.
- Dosyalar: `infra_system.gd`, `support_system.gd`, `sales_system.gd`, `b2b_sales_system.gd`, `sprint_catalog.gd`,
  `sprint_bridges.gd`, `data/product/sprint.json`, `sales_faucet_system.gd`, `sales_ledger.gd`, `sales_archetypes.gd`,
  `sales_constants.gd`, `sales_meeting_system.gd`, `negotiation_system.gd`, `sales_probes.gd`, `seams_product.gd`,
  `run_probe.gd`, `endgame_smoke.gd` (infra vakaları), `strings.csv` (`NEG_CAPACITY`, kayıp nedeni anahtarları).
  (inceleme) Ayrıca `main.gd` (fikstür `set_capacity(suggested_start_units())`, satır ≈2642), `time_manager.gd`
  dokunulmaz ama `daily_tick` sırası korunur; `PROD_RND_NODE_INCIDENT_PLAYBOOK_UNLOCK` "taşan kapasite" diyor, metni
  yeniden yazılır. `endgame_smoke.gd`'de silinen API'yi okuyan 25 satır ve elle kapasite kuran 8 satır var; elle
  kapasite artık ertesi tikte otomatik ölçeklemeyle eziliyor, o vakalar aynı commit'te yeniden kurulur.
- Kapılar:
  - Smoke `infra_*`, `sales_*`, `b2b_*`, `destek_*`.
  - Yeni vaka `server_autoscale_tracks_load`: kitle iki katına çıkınca birim büyür, yarıya inince küçülür, fatura onu
    izler.
  - `bash tools/run_gate.sh` (üç koşu sonla biter, sıfır `ERROR`).
  - `--why-fire=product.outage` (A/B varsayımı 6).
- Risk: B'nin kesinti kartı hâlâ `urun.capacity_state` okuyorsa kart ölü kalır. C1'den önce `grep` ile bakılır.

**C2 · Kurumsal sunucu şartı**
- Ne: hedefe şart terimi, onay şeridinde madde, toplantı çıkışında düğme, imzada mail ve tek tık geçiş.
- Dosyalar: `b2b_sales_system.gd`, `b2b_constants.gd`, `sales_finalizer.gd` ve `sales_rep_system.gd` (imzada mail),
  `message_system.gd` (tür), `scripts/tabs/events/mail_pane.gd` (`server_clause` çizimi ve düğme), `inbox.gd`
  (gönderen), `scripts/ui/meeting/sales_meeting_adapter.gd` (onay şeridi ve düğme), `strings.csv`.
- Kapılar:
  - Yeni vaka `server_clause_lowers_target_after_floor`.
  - Görsel: `--negotiation-shot=confirm`, `--meeting-shot=won`, yeni `--inbox-shot=server_clause`; her biri `--lang=en`
    ile de.
- Risk: Toplantı paneli dar dokta taşabilir; `--shot-scale=1.25` ile bakılır.

**C3 · Ayrılma eşiği ve memnuniyetin terimleri** (değer onaydan sonra)
- (inceleme) **İkiye bölünür.** C3a: `target_terms` yeniden düzenlemesi, değer değişmeden; C2'den önce girer, çünkü
  C2'nin şart terimi ve C7'nin ipucu bu listeye yazılır. C3b: eşik formülü; Erdem'in onayından sonra, en geç C8'den önce.
- Ne: `seed_tolerance` yeni formül, `target_terms`, `satisfaction_target` onların toplamı.
- Dosyalar: `b2b_constants.gd`, `b2b_sales_system.gd`, `inbox.gd` (`risk_reason` terimlerden okur), smoke.
- Kapılar:
  - Smoke `b2b_*`, `risk_*`, `retention_gate_shared`.
  - Yeni vaka `target_terms_sum_to_target`.
  - Bot ölçümü: `--run-log=full_run:104:sim:<7|11|23>`, A'dan sonraki build'le. Kaybedilen hesap sayısı ve ilk 30 hafta
    payı rapora yazılır; tablo §2.11'in güncel hâlidir.
  - (inceleme) Aynı ölçüm "hiç düzeltmeyen" bot koluyla da koşulur (A'nın naif kolu), yeni eşikte. Rapor iki kolun
    kayıp farkını yazar; fark A'nın ölçtüğünün yarısının altına düşerse §2.11'deki iki yol Erdem'e gider. Ölçüm tek
    turdur (Erdem'in 2026-10-11 kuralı: ölçüm turu tekrarlanmaz).
  - `run_gate.sh`.
- Risk: A'nın hata terimiyle churn ya sıfıra iner ya patlar. Ölçüm kötüyse değer değiştirilmez, rapor Erdem'e gider.

**C4 · Genel Bakış kâğıdı**
- Ne: üçüncü kâğıt, kilidi, Sürüm, Destek, Sunucu ve İş blokları, `product_view_requested` ve Sprint odağı. Build bar
  satırı Genel Bakış'ı açar.
- Dosyalar: `product_tab.gd`, yeni `scripts/tabs/product/overview_view.gd`, `product_model.gd`, `event_bus.gd`,
  `area_panel.gd` ve `sprint_panel.gd` (odak), `product_fixtures.gd`, `main.gd` (`--product-shot` türleri),
  `build_bar.gd` (tık, A/B varsayımı 5), `strings.csv`. Gerekirse `ui_tokens.gd` ve `build_theme.gd`'de yeni
  varyasyon; o durumda `THEME_STAMP` artar ve iki tema yeniden üretilir.
- Kapılar:
  - `--product-shot=live:overview_b2b`, `live:overview_b2c` (yeni türler), `live:b2c_mvp` (kilitli sekme),
    `live:overview_focus` (Destek satırı tıklanınca Sprint'te kart vurgulu).
  - `--lang=en`, `--palette=cb`, `--theme-contrast-audit`.
  - `--sprint-probe=hours=40:cards=2:ticks=20` (Sprint ekranı bozulmadı).
- Risk: Ürün penceresinin yeniden kurulumu sürüm notunun saat tutuşuna dokunur. Release kipi her zaman SPRINT'i zorlar,
  ayrıca test edilir.

**C5 · İstekler ve Sesler**
- Ne: bilinen istek süzgeci, B2C istek türetmesi, "İstenen · N yorum" etiketi, İstekler bloğu, Sesler bileşeni ve 28
  ses satırı. (inceleme) E, not ve video uygulamasını siliyor (E §5.8, E'nin açık sorusu 1). O soru "evet" çıkarsa C
  yalnız dört ortak hattın (`line_shared_*`) sesini yazar (4 × 2 = 8 satır); not ve video hatlarının 20 satırı E2'de çöpe
  giderdi. Pazaryeri hatlarının sesi E'de yazılır. B incelemesinin sahip sorusu 7 ile aynı karar.
- Dosyalar: `sprint_bridges.gd`, `sprint_catalog.gd`, `product_model.gd`, `sprint_card.gd` (etiket),
  `overview_view.gd`, `strings.csv`.
- Kapılar:
  - Yeni vaka `requests_hidden_without_rep` (temsilci yokken talep kartı yok, gelince var, ayrılınca kalır).
  - Smoke `sprint_*`.
  - Görsel `--product-shot=live:b2b_requests` (temsilcili), yeni `live:overview_b2c_norep` (Sesler).
  - `--product-shot=cards` (etiket kartta taşmıyor).
- Risk: `b2b_requests` fikstürü temsilcisiz kuruluyor. Fikstüre temsilci eklenir.

**C6 · Haftalık destek raporu**
- Ne: `support_week` mesajı, çizimi, düğmesi, sessiz hafta kuralı, eski okunmamış raporun düşmesi.
- Dosyalar: `customer_rep_system.gd`, `message_system.gd`, `mail_pane.gd`, `inbox.gd`, `main.gd`
  (`--inbox-shot` türleri), `strings.csv`.
- Kapılar:
  - Yeni vaka `support_report_skips_quiet_week`; smoke `messages_*`.
  - Görsel `--inbox-shot=support_week_b2b`, `support_week_b2c`; düğme tıklanınca Ürün'de kart vurgulu kare.
- Risk: Rapor B'nin olay maillerinin yanında kutuyu kalabalıklaştırabilir. Sessiz hafta kuralı 20 haftalık koşuda
  sayılır (`--run-log` mesaj sayısı) ve rapora yazılır.

**C7 · Satış HESAPLAR tablosu, yıllık gelir, "Onboarding" ve fiyat konumu**
- Ne:
  - ADAYLAR | HESAPLAR kâğıtları ve tablo; Durum, Yenileme, İstek, Satışçı sütunları; memnuniyet ipucu.
  - Başlık ölçüleri ve yıllık gelir; üst bar ipucu; onay şeridinde yıllık değer.
  - Alan ve Ar-Ge düğümü adları.
  - Fiyat duruşunun ipucunda rakip fiyatları; `rivals.json` `erp.seat_prices`.
- Dosyalar: `sales_tab.gd`, `top_bar.gd`, `negotiation_system.gd` ya da `sales_meeting_adapter.gd`, `data/product/rivals.json`,
  `customer.gd` (`seller_id`), `sales_rep_system.gd` (imzada `seller_id`), `strings.csv`,
  `docs/design/localization_glossary.md` (Yıllık gelir satırı), gerekirse tema varyasyonu ve `THEME_STAMP`.
- Kapılar:
  - Görsel: `--sales-shot=accounts` (yeni: 9 hesap, üç durum etiketi), `accounts_tip` (yeni: ipucu açık), `pipeline`
    ve `desk` (ADAYLAR bozulmadı), `--sales-shot=b2b_pre`, `--lang=en`, `--palette=cb`, `--shot-scale=1.25`.
  - `--theme-audit=sales`. Smoke `sales_*` (hesap kartını okuyan vakalar tabloya çevrilir).
- Risk: En büyük UI işi bu. Dokuz sütun 1280 genişlikte dar; gerekirse Satış penceresi Ürün'ün eni olan 1424'e çıkar
  (`window_layer.gd` boyu). (inceleme) Satışçı sütunu ipucuna taşındığı için sütun sayısı sekizdir. Ek kare
  `--sales-shot=accounts_many` (300 hesap, kaydırma çubuğu görünür, başlık ve alt satır sabit).

**C8 · Sözleşme yenileme**
- Ne:
  - Yeni alanlar, aylık gruplar, iki kâğıt, `renewal_choose` fiili, sonuç uygulaması ve maili, ayrılma günü.
  - Satış masasının yenilemede dolu sayılması.
  - Eski yenileme talebinin silinmesi.
  - Bot cevabı.
- Dosyalar: `customer.gd`, `b2b_constants.gd`, `sales_rep_system.gd`, `sales_ledger.gd` (`rep_busy`),
  `b2b_sales_system.gd` (`leaves_on_day`), `customer_rep_system.gd` (yenileme kolu silinir), `effects.gd`, `chips.gd`,
  yeni `seams_sales.gd` satırları, yeni `data/events/cards/customer/renewal_ask.json` ve `renewal_meet.json`,
  `request_renewal.json` silinir, `plausibility.gd:364`, `mail_pane.gd` (`renewal_result`), `run_probe.gd` (bot
  cevabı ve `RENEW` satırı), `strings.csv`, `docs/content/events_draft/_vocabulary.md` (`--event-vocab` üretir),
  `GDDs/GUNCELLEMELER.md`.
- Kapılar:
  - `--event-lint`, `--event-vocab`.
  - `--why-fire=customer.renewal_ask` ve `customer.renewal_meet`.
  - `--event-harness=guided:seeds=4:weeks=70`.
  - `bash tools/plausibility_run.sh` (`fails=0`).
  - Yeni vaka `renewal_outcome_table` (§2.6 tablosunun her hücresi). Smoke `cs_*`, `discount_*`, `sales_*`.
  - `run_gate.sh` ve `--run-log=full_run:104:sim:7`'de `RENEW` satırları: yenilenen, zamlanan, kaybedilen, ay başına
    kâğıt sayısı.
  - Görsel: `--inbox-shot=renewal_ask`, `renewal_meet`, `renewal_result`, `--sales-shot=accounts` (Yenilemeyecek).
- Risk: Ayda bir kâğıt bile kurucuyu B'nin olaylarıyla birlikte sıkıştırabilir. Bot koşusunda Olaylar'a düşen kâğıt
  sayısı haftalık sayılır.
- (inceleme) Ek kapı: ikinci yılın imza sayısı yenilemeli ve yenilemesiz (bayrakla) koşuda karşılaştırılır; satış
  masasının yenileme haftası kaybı %10'u geçerse §2.6'daki eşik işler. Yeni vaka `renewal_founder_card_expires`
  (cevapsız kurucu kâğıdı: eşiğin altındaki hesap yenilemez, üstündeki aynı fiyattan yeniler).

**Genel riskler**
1. **Eşik ve A'nın hata terimi birlikte churn'ü öngörülemez biçimde kaydırır.** C3 A'dan sonra ölçülür. Değer onaysız
   değişmez.
2. **Yenileme hacmi.** Bot 104 haftada 132–149 yenileme yaşıyor. Gruplama ve kurucu saat tavanı bunu taşır; yine de
   B'nin acil olaylarıyla aynı aya düşen kâğıtlar ölçülür.
3. **Doluluğun kalkması geniş bir silme.** Seam, smoke, olay kartı ve satış probları birlikte değişir. C1 ilk commit'tir
   ve kendi başına `run_gate.sh`'den geçer.

---

## 8. Açık sorular
(inceleme) Planın beş sorusu incelemenin bulgularıyla birleştirildi; altı soru. Hepsi kapalı uçlu ve önerili.

1. **Ayrılma eşiği** "30 + 3 × (yıldız − 1) + sektör ekinin yarısı" olsun mu (1★ 30, 2★ 33, 3★ 36, en çok 38), ve eşik
   memnuniyetin ipucunda yazsın mı?
   **Öneri:** Evet ve evet, ama değer A'dan sonraki ölçümle kesinleşir. Bugünkü gerçek kayıp %2–7; betiğe göre öneri
   %1–1,5'e indirir. Bedeli: eşik inince A'nın "hata churn'ü etkiler" kararı B2B'de ilk 30 haftadan sonra neredeyse
   işlemez (40. haftadan sonra memnuniyet 59–67, A'nın cezası en çok 20). C3 bu yüzden hiç düzeltmeyen bot koluyla da
   ölçer; hata etkisi yarıdan fazla kaybolursa sana iki yol gelir: A'nın ceza tavanı artar ya da eşik daha az iner
   (33 + 4×).
2. **Sunucu doluluğu** tamamen kalksın, üç kademe kendiliğinden ölçeklensin; oyuncu yalnız kademeyi ve aylık faturayı
   görsün, birim (1.000 kullanıcı ya da 50 koltuk) yalnız ipucunda yazsın mı?
   **Öneri:** Evet. Bot ölçümünde doluluk 97 haftada en çok %99'a çıktı, hiç aşılmadı; oyuncuya bir karar sunmuyor.
   Startup Company'nin sade çekirdeği de tek bir kapasite sayısı. Kalite kademeleri ve artısıyla eksisi kalır.
3. **Rakip analizi** ayrı bir ekran ya da rapor olmasın mı? Rakip fiyatı fiyat duruşu seçicisinin ipucunda kendi
   fiyatınla birlikte dursun ve var olan "rakip müşterine daha ucuz teklif verdi" kâğıdı bu fiyatı yazsın mı?
   **Öneri:** Evet. Oyunda rakip zaten karar isteyen olaylarla geliyor (fiyat kırma, kopyalama, yatırım turu, kapanış);
   "duyum" bu ailenin bir kartıdır. Ayrı bir tablonun hiçbir kaldıracı olmazdı ("bir kere bakarım, sonra bana ne").
   Kayıp nedenine bağlı rakip raporu Erken Erişim'e kalır.
4. **Yenileme kâğıdı** ne sıklıkla gelsin? Plan: sahip başına ayda tek kâğıt; zam %8, indirim %10; sonucu zarsız
   tablo belirler. İkinci yılda bu, yılda 12 ile 24 aynı biçimli kâğıt demek.
   **Öneri:** Kâğıt yalnız grupta karar isteyen bir hesap varsa gelsin (3★ hesap, eşiğin altında hesap ya da
   karşılanmamış sunucu maddesi). Öteki aylarda satışçı son verdiğin kararı uygular ve yalnız sonuç maili gelir.
   Satışçının ilk kâğıdı her durumda gelir; senin sorunun cevabı sonraki ayların varsayılanı olur. Zam, indirim ve
   tablo planın önerdiği gibi kalır.
5. **B2B fiyatı ve nakit:** Koltuk fiyatı aylık söylensin, sözleşme 12 ay olsun, nakit aylık tahsil edilsin; yıllık gelir
   (ARR) yalnız gösterim olsun ve B2C'den B2B'ye geçişte ana gösterim (MRR) değişmesin mi?
   **Öneri:** Evet. Yıllık peşin tahsilat runway ve tur kalibrasyonunu baştan bozar. MRR tek ortak dil kalır; B2B'de
   yıllık gelir Satış başlığında, Genel Bakış'ta ve üst barın ipucunda yazar.
6. **Kurumsal sunucu şartı karşılanmazsa** bedel ne olsun? Plan: o hesabın memnuniyet hedefi −10. Ancak yeni eşikte
   memnuniyet 60 civarındayken −10 hesabı hiçbir zaman eşiğin altına itmiyor; şartı görmezden gelmek bedava kalıyor.
   **Öneri:** −10 ipucunda görünen işaret olarak kalsın; asıl bedel yenilemede çıksın: şart karşılanmadan biten sözleşme
   yenilenmez. Yenileme döneminde Durum sütununda "Yenilemeyebilir" yazar, ipucu nedenini söyler. Anlaşma iptal olmaz,
   oyuncunun geçmek için bir yılı olur, bedel gerçek hayattaki yerinde çıkar ve 3★ hesaplar büyük olduğu için düğmenin
   bir anlamı olur. Yenileme tablosuna tek satır eklenir; yeni durum yok. Güvenlik sertifikası araştırması şartı
   karşılamaz; şart sunucu kademesidir.

---

## 9. Uygulama adım tablosu

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| 0 | Planı A ve B commit'lerine karşı tazele; §5.7 varsayımlarını tek tek doğrula ya da düzelt | Alt ajan | Sonnet | yüksek | 20 dk | Fark kontrolü, tasarım değil |
| 0b | Tazelenmiş planı ve açık soruları Erdem'e sun; metinlerin onayı | Ana | Opus (ana) | orta | 15 dk | Sahip kararı |
| 1 | C1 kodu | Alt ajan | Sonnet | xhigh | 2 sa | Geniş ama mekanik silme; okuyucuları kaçırmamak dikkat ister |
| 1g | C1 kapıları: lint, loc, smoke, `run_gate.sh` | Alt ajan | Haiku | düşük | 25 dk | Komut koşmak |
| 1r | C1 kıdemli inceleme ve düzeltme | Alt ajan | Opus | yüksek | 25 dk | Ekonomi değişikliği, ölü kod riski |
| 2 | C2 kodu | Alt ajan | Sonnet | xhigh | 1,5 sa | Model + üç yüzey |
| 2g | C2 kapıları ve üç ekran (TR, EN) | Alt ajan | Haiku | düşük | 25 dk | Ekran çekimi |
| 2r | C2 inceleme | Alt ajan | Opus | yüksek | 20 dk | Mail ve toplantı paneli kalıbı |
| 3 | (inceleme) C3a `target_terms` düzenlemesi C2'den önce; C3b eşik formülü onaydan sonra | Alt ajan | Sonnet | xhigh | 1 sa | Küçük ama merkezi formül; C2 ve C7 bu listeye yazar |
| 3g | C3 kapıları ve 3 tohumluk bot ölçümü (inceleme: düzelten ve hiç düzeltmeyen kol, yeni eşikte, gerçek koşu; betik yalnız karşılaştırma için) | Alt ajan | Haiku | düşük | 45 dk | Koşu ve sayma; betik hazır (`scratchpad/c_runs/churn_cf.py`) |
| 3r | C3 inceleme ve ölçümün yorumu | Alt ajan | Opus | yüksek | 20 dk | Kalibrasyon yargısı |
| 4 | C4 kodu | Alt ajan | Sonnet | max | 3 sa | Yeni görünüm, model sözleşmesi, odak; UI kanunu |
| 4g | C4 ekranları (B2B, B2C, kilitli, odak; EN, cb), kontrast denetimi, sprint probu | Alt ajan | Haiku | düşük | 40 dk | Sıralı pencereli koşular |
| 4r | C4 inceleme ve tek düzeltme (inceleme: Erdem'in 2026-10-11 kuralı, commit başına en çok bir inceleme ve bir düzeltme; CLAUDE.md §11'in iki turu tavandır, hedef değil) | Alt ajan | Opus | yüksek | 30 dk | Görsel kabul ve sade kod |
| 5 | C5 kodu ve ses satırları (EN önce, TR yeniden yazım; inceleme: E not ve videoyu silerse 28 değil 8 satır) | Alt ajan | Sonnet | xhigh | 1,5–2 sa | Veri süzgeci + içerik |
| 5g | C5 kapıları ve ekranları | Alt ajan | Haiku | düşük | 25 dk | Komut ve ekran |
| 5r | C5 inceleme, metin tonu dahil | Alt ajan | Opus | yüksek | 20 dk | Yazım Erdem'in en sert ölçütü |
| 6 | C6 kodu | Alt ajan | Sonnet | xhigh | 2 sa | Satış raporu kalıbının kopyası değil, uyarlaması |
| 6g | C6 kapıları, iki mail ekranı, 20 haftalık mesaj sayımı | Alt ajan | Haiku | düşük | 25 dk | Sayma |
| 6r | C6 inceleme | Alt ajan | Opus | yüksek | 20 dk | Mail yükü kuralı |
| 7 | C7 kodu | Alt ajan | Sonnet | max | 3,5 sa | En büyük UI: kâğıtlar, tablo, ipucu, pencere eni |
| 7g | C7 ekranları (accounts, accounts_many, accounts_tip, pipeline, desk, b2b_pre; EN, cb, 1,25), tema denetimi | Alt ajan | Haiku | düşük | 50 dk | Çok kare |
| 7r | C7 inceleme ve tek düzeltme (inceleme: 4r ile aynı kural) | Alt ajan | Opus | yüksek | 30 dk | Tablo yoğunluğu ve sakin ekran |
| 8 | C8 kodu, iki kart, fiil, sonuç maili, bot cevabı | Alt ajan | Sonnet | max | 4 sa | Yeni akış, olay motoru kuralları, kayıt alanları |
| 8g | C8 kapıları: lint, vocab, why-fire, harness, plausibility, run_gate, RENEW sayımı, ekranlar | Alt ajan | Haiku | düşük | 50 dk | Uzun kapı zinciri |
| 8r | C8 inceleme ve düzeltme | Alt ajan | Opus | yüksek | 30 dk | Ekonomi + içerik + motor |
| 9 | (inceleme) Faz sonu raporu ✅/⚠️/❌; push yalnız Erdem'in sözüyle ve tam smoke koşulmadan | Ana | Opus (ana) | orta | 15 dk | Erdem 2026-10-06: "push et" doğrudan push demek |

- Kod toplamı yaklaşık 19 saat, kapılar ve incelemeler yaklaşık 9 saat. Kapılar ve incelemeler kodla kısmen örtüşür,
  bu yüzden toplam yaklaşık 22 saattir.
- (inceleme) Sıra C1 → C3a → C2 → C4 → C5 → C6 → C7 → C3b → C8. C3b'nin değeri onay bekler; öteki dilimler onu
  beklemez, C3b en geç C8'den önce girer (C8'in "Yenilemeyebilir"i yeni eşiği okur).
- Push yalnız Erdem'in sözüyle yapılır.
