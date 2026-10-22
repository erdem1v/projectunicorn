# Tur 2 sunumu: Erdem'in yorum yaptığı metin (2026-10-16)
Bu metin `../sprint/T2_5a_loop.md`, `T2_5b_product.md` ve `T2_6_review.md` dosyalarından sadeleştirildi. Erdem'in
yorumları `ERDEM_TUR2_YORUM.md`'dedir ve bu metnin önüne geçer.

**Bilinen düzeltme:** "40'ın altına düşerse ayrılma sayacı başlar" cümlesi bir sadeleştirmeydi. Kodda her hesabın
kendi eşiği var: `b2b_constants.gd:39-52` 33 + 9×(yıldız−1) + sektör ekini hesaplar.

---

## 1. Hotfix düğmesi kalkıyor; acil durumlar olay olarak gelir
Normal hatalar sprintte düzeltme kartlarıyla çözülür. Acil durum bir mail ya da olay kartı olarak gelir.

**Sıklık:** En fazla 4 haftada bir, sprint başına en fazla bir orta seviye olay. Olasılığı şunlar belirler:
- sunucu kalitesi,
- sunucu doluluğu,
- o hattaki açık hata sayısı,
- son sürümün hatalı çıkıp çıkmadığı.

**Ağırlık seviyeleri:**
- **Servis çöktü:** Sitede kesinti var, pazaryerinde ödeme alınamıyor.
- **Tek akış ya da önemli bir müşteri tıkandı:** Önemli bir müşteri işini yapamıyor.
- **Küçük sorun:** Olay olmaz; yalnız hattın hata sayısına yazılır.

**Beş olay:**
- **"Gece 02:10 · Kesinti":** Var olan kesinti kartı genişler.
  - B2B: "Ekol'ün depo ekibi gece vardiyasında sisteme giremiyor."
  - B2C: "Sepet sayfası zaman aşımına düşüyor."
- **"Ay sonu kapanışı yapamıyoruz" (B2B, müşteriden gece 23:40'ta mail):** "Fatura toplu onayı hata veriyor,
  muhasebe yarın 09:00'da bekliyor."
- **"Ödeme alınamıyor" (pazaryeri):** "Son 3 saatte 212 sepet yarıda kaldı."
  - Satıcı tarafındaki ikizi: "Satıcılar ödemelerini 3 gündür alamıyor, 14 mağaza ilanlarını durdurdu."
    **(REDDEDİLDİ)**
- **"Sürüm sonrası bozulma":** "v1.4 sonrası Stok sayımında eksi değerler görünüyor."
- **"Yorum fırtınası" (B2C):** "'Siparişim hazırlanıyorda kaldı' yorumu 300 kez paylaşıldı."

**Seçenekler ve bedelleri:**
- **Sprinti durdur, şimdi düzelt:** Sprintin başına bir acil düzeltme kartı girer; kapasiteye sığmayan kart sonraki
  sprinte kayar.
- **Ekip gece çalışsın:**
  - Sorun sabaha biter.
  - Geliştirici ve testçinin morali −6 düşer, bir hafta verim −%15 olur.
  - %25 ihtimalle aceleden yeni bir hata çıkar.
- **Kendin bak:** Yalnız ekip yokken ya da ekip en fazla 2 kişiyken açılır. Kurucunun o haftaki sprint payı −%40.
- **Sonraki sprinte bırak:**
  - B2B'de o hesabın memnuniyeti −6 düşer; 40'ın altına inerse ayrılma sayacı başlar.
  - B2C'de düzelene kadar kitle haftada −%2 azalır.
  - B2C'de servis tamamen çöktüyse kilitli: "Uygulama açılmıyor; bekleyecek bir şey yok."
- **Telafi et (yalnız servis çöktüğünde):**
  - B2B'de o hesabın bir aylık ücreti −%20.
  - B2C'de $4.000 kupon.

## 2. Hataların gösterilmesi
**Tek sayı:** Oyuncu yalnız "Açık hata" görür ve sayısı hat hat yazar. Arkadaki iki sayaç birlikte hareket eder;
düzeltme kartı açık hatayı düşürünce satış dönüşümü, yatırımcı görüşü ve memnuniyet düzelir. (Erdem: satış ve
yatırımcı ETKİLENMESİN, churn ve itibar etkilensin.)

**Hat başına tek satır:** "Faturalama · 4 açık hata · 3 hesap ↑".

**Düzeltme kartı:** Kart artık "N ticket kapatır" demez, kime dokunduğunu söyler.
- B2B: "Faturalama düzelt · 4 hata · Ekol, Mavi Ofis +1".
- B2C: "Ödeme düzelt · 5 hata · siparişlerin ~%4'ü".
- Erdem ikisini de beğenmedi; sayı istiyor: "3 hesap · N kullanıcı".
- Efor hata sayısına bağlı: 1–2 hata 1, 3–5 hata 2, 6+ hata 3.
- Sürüm notunda "Faturalama: 4 → 0" yazar.

**Temsilciden önce:**
- **B2B:** Ayrı hata maili yok; müşterinin sesi olaylarla gelir.
- **B2C:** "Sesler" bölümünde 1–2 mağaza ya da sosyal medya yorumu: "★★☆☆☆ Sepete ekliyorum, ödeme sayfası beyaz kalıyor."

**Temsilciden sonra:** Haftalık destek raporu gelir; yeni bir şey yoksa gelmez. Örnek:
```
En çok sorun çıkan
  Faturalama   4 açık hata · 3 hesap   ↑
  Stok         2 açık hata · 1 hesap   ↓
En çok istenen
  Toplu fatura onayı   Ekol, Mavi Ofis · $1,8K aylık
Bu hafta
  Ekol'ü aradım, gecikmeyi anlattım; memnuniyet 52 → 55.
[Faturalama düzeltmesini aç]
```
- B2C'de "en çok istenen" yorum sayısıyla gelir: "Kargo takibi (38 yorum), Taksit (21)".
- Satıcı istekleri ayrı yazar: "Toplu ilan yükleme (11 mağaza)".

**"Kaçırıldı" kalkıyor:** Yalnız temsilci gerçekten yetişemediğinde raporda tek satır olarak çıkar: "Yetişemedim:
5 bildirim cevapsız kaldı."

## 3. Sprint sürerken kurucu ne yapar
Kurucunun haftası 40 saat. Sprint dışında harcadığı her saat, o haftaki sprint puanından düşer. Eylemler:
- Satış görüşmesi (var): 4–8 saat.
- Yatırımcı hazırlığı (var): bütün hafta.
- Aday görüşmesi, eğitim, Ar-Ge (var).
- **Yeni, müşteri ya da kullanıcı görüşmesi:** 4 saat. **(Erdem: EKLENMEYECEK.)**
- **Yeni, sürüm duyurusu:** 4 saat; B2C'de kitle +%3. **(Erdem: pazarlamayla birlikte, araştırılacak.)**

## 4. Ekip rolü ve kapasite
- Geliştirici geliştirme puanı, tasarımcı tasarım puanı, testçi test puanı üretir.
- **Testçi:** Hata ihtimalini düşürür. Kart kapanırken hata ihtimali 3 test becerisinde %19, 7'de %11. Testçi yoksa
  %40. **(Erdem: oranlar yüksek.)**
- **Ürün yöneticisi:** Puan üretmez. Büyük ekibin koordinasyon kaybını azaltır, Çeyrek'i ve aylık rakip analizini
  açar, karar kâğıtlarına soru ekler.
- **Yıldız çarpanı (onaylı):** 1★ ×0,64 · 2★ ×0,86 · 3★ ×1,16 · 4★ ×1,54 · 5★ ×2,0.
- **Uyum:** Ana alan 1,0, ikincil alan 0,7, uymayan iş 0,4.
- **Ekip büyüklüğü:** Üreten kişi 3'ü aşınca kişi başı −%6 **(Erdem: fazla ve kaba)**. PM bu kaybın bir kısmını geri
  kazandırır.
- **Örnek (2 haftalık sprint):** tek kurucu 4 puan; kurucu ve iki kişi ~13; PM'li 6 kişi ~20.
- Bedeli büyük: ekrandaki tahmin aynı hesabı birebir yapmalı.

## 5. Gözden kaçan hatalar
1. İki ayrı hata sayacı var.
2. Hangi hattın düzeltildiği bilinmiyor.
3. Kurucu çift sayılıyor.
4. Ürün karmaşıklığı hiç hesaplanmıyor (aşınmada olası 24 kat fazla sayım var).
5. Sprint ortası kararları tekrar ediyor.
6. Kart düğmeleri gözden kaçıyor.
7. Ekip boşken saat boşa akıyor.
8. "Hotfix yayınla" etiketi yalan söylüyor.

## 6. v1 sonrası ürün sayfası
**Ürün penceresi:** 3 kâğıt: GENEL BAKIŞ, SPRINT, ÇEYREK. GENEL BAKIŞ'ta şu bloklar var:
- **Sürüm ve kalite.**
- **Destek:** "Açık hata 7 ▲2 · En kötü hat: Stok Takibi · 4 hata → Sprint'te düzelt".
- **İstekler.**
- **Sunucu:**
  - Kademeler: Ekonomik $35, Standart $55, Kurumsal $85 (1.000 kullanıcı başına).
  - Doluluk çubuğu.
  - Otomatik ölçekleme eşiği %70, %80 ya da %90; elle ayar da var.
  - Fatura ve marj.
  - Ekonomik'te kurumsal müşteri imzalanmaz. **(Erdem: imza iptal olmasın, şart olsun.)**
  - **(Erdem: sunucu bölümü fazla ağır.)**
- **İş özeti.**

**Rakip analizi:** PM'in aylık maili. İçeriği:
- özellik tablosu ("Olmazsa olmaz / Fark yaratan / Boşluk"),
- fiyat konumu,
- duyum,
- tek öneri.

**(Erdem: yarım ve angarya; olmalı mı?)**

**ERP Satış sekmesi, hesap tablosu:**
- Sütunlar: Firma, Koltuk, Aylık, Memnuniyet ▼, Açık istek, Yenileme, Sorumlu.
- Durum etiketleri: "Ayrılabilir · ~3 hafta", "Büyümeye açık". **(Erdem: "Büyümeye açık" ve hafta sayısı olmasın.)**
- Memnuniyetin üstüne gelince nedenleri görünür.
- Aylık gelir akışı.

**B2C'de Satış sekmesi Pazaryeri olur:**
- **Mağazalar:** "Aktif 184 · bu ay +22 / −6". Komisyon önizlemeli: "%10 → %12 · mağaza girişi −%15 · bir kerelik −8 mağaza
  · ayda +$3.900". Satıcı çağrısı da var.
- **Alıcılar:** "Aktif 12.400 · Üye 1.050 (%8,5) · Ücretsiz 11.350". Üyelik ücreti önizlemeli.
- **Gelir:** komisyon, üyelik, toplam, satış hacmi, sepet ortalaması.

## 7. Eğlence
**Sprint ortası kararları karta ve role özgü.** Örnekler:
- **PM:** "Bu kartın yarısını müşteri istedi, yarısı bizim fikrimiz. Yarısını kesersek sprintte biter."
  **(Erdem: üslup korkunç.)**
- **Geliştirici:** "Faturalama'daki hataların üçü aynı yerden çıkıyor. Altını yeniden yazarsam bir daha çıkmaz."
  **(Beğenildi.)**
- **Testçi:** "İndirim kodu ve taksit birlikte seçilince toplam yanlış çıkıyor. Nadir ama para."
  **(Fikir iyi, üslup korkunç.)**

**"Testi kısalt" söz olayının bir seçeneği:** "Ekol'e bu sprint sonu söz verdik. Testi kısaltırsak yetişir."
- Seçenekler: Testi kısalt / Fazla mesai / Ekol'ü ara, bir sprint iste / Söz kaçsın. **(Çok beğenildi.)**
- B2C ikizi: "Kasım indirimleri 2 hafta sonra; satıcılar kampanya aracını bekliyor." **(Basit ve cheesy.)**

**Sürüm anı:**
- **B2B:** Teşekkür maili: "Toplu fatura onayı geldi. Muhasebe bu ay kapanışı iki gün erken yaptı."
  **(Fikir iyi, cümle çelişkili.)**
- **B2C:** 3–5 sosyal medya ya da mağaza yorumu; satıcı yorumu da var.

**İstek → kart:** İstek yalnız temsilci raporu ya da kurucu görüşmesi ortaya çıkardıysa karta "İstenen · 38 yorum"
etiketi düşer. **(Erdem: yalnız müşteri temsilcisi ortaya çıkarır.)**

## Faz önerisi (Erdem onayladı)
- **A:** Hatalar ve hata gösterimi.
- **B:** Olaylar.
- **C:** Ürün sayfası.
- **D:** Ekip modeli.
- **E:** Pazaryeri çekirdeği.

**Erken Erişim'e kalanlar:**
- Premium mağaza.
- Reklam.
- Paketler.
- ERP modülleri.
- Ücretsiz deneme.
