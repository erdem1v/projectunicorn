# Karar, pre-mortem ve takvim şablonları

SKILL.md §4, §5 ve §6'nın şablonları. Kopyala, doldur, boş kalan alanı silme: "bulunamadı" ya da
"değerlendiremem" yaz.

## 1. Karar kartı

```
K<n>. <Sorunun tek cümlesi, oyuncu diliyle>

Oyuncunun ekranında olan: <somut örnek: hangi hafta, hangi ekran, oyuncu ne görüyor, ne yapamıyor>
Neden şimdi soruyorum: <hangi iş bu karara bağlı>

A) <seçenek>  Oyuncu: <ne görür, ne hisseder>  Bedel: <süre / token / risk>  Geri dönüş: <kolay / kalıcı>
B) <seçenek>  ...
C) Yapma ya da bekle (dürüstse)  ...

Önerim: <harf>, çünkü <tek cümle>.
Ne yapmayacağız: <seçilmeyen yolun bıraktığı şey>.
Terimler: <gerekirse tek satır açıklama>
```

Kurallar:
- Kartta tek soru. Birden çok karar varsa ayrı kartlar, en önemlisi başta.
- Oyuncu örneği kartın ilk satırıdır; teknik ad (sabit, imza, kapı) parantez içinde ve açıklamalı kalır.
- Seçeneklerin her biri savunulabilir olmalı. Öneriyi parlatmak için zayıf seçenek eklenmez.
- Kalıcı kapı (Steam'de kilitlenen ad, Next Fest hakkı, kayıt şeması, yayınlanmış fiyat) kartta açıkça
  "kalıcı" diye yazılır ve daha çok kanıt ister.
- Uygulandıktan sonra kapanış: **Ne idi:** ... **Ne değişti:** ... **Şimdi:** ...

## 2. Oynanış merceği (mekanik başına)

| Soru | Cevap |
|---|---|
| Oyuncuya hangi kararı verdiriyor? | |
| Ne sıklıkta? (haftada, ayda, koşuda bir) | |
| Tek satırla okunuyor mu? Hangi satır? | |
| Angarya ya da akış kesintisi doğuruyor mu? | |
| 1 kişide ne hissettiriyor? 50 kişide? Uç bileşimde? | |
| Oyuncu bu gideri ya da düşüşü görüyor ve etkileyebiliyor mu? | |
| Düşüşün oyuncunun okuyabileceği bir nedeni var mı? | |
| Neden var? ("X oyununda var" gerekçe değil) | |
| **Hüküm:** tut / sadeleştir / kes / güçlendir | |

## 3. Pre-mortem

```
Varsayım: <öneri> yapıldı. <tarih> itibarıyla açıkça başarısız oldu: <somut sonuç>.

Yol 1 (kanıtı vurur): <yanlış çıkan olgu ya da taşınmayan emsal>, mekanizma, büyüklük, zaman.
  En erken uyarı: <gözlenebilir işaret + eşik>
Yol 2 (aktör tepkisi): <oyuncu / Steam / rakip / içerik üreticisi beklemediğimizi yaptı>.
  En erken uyarı: ...
Yol 3 (bağımlılık): <araç / model / eklenti / onay süresi>.
  En erken uyarı: ...

Olumsuz Steam yorumunun tek cümlesi: "<oyuncunun yazacağı cümle>"
En hızlı ucuz risk azaltma hamlesi: <ne, ne zaman, kim>  → plana girdi mi? evet / hayır, neden
Kabul edilen riskler: <kalanlar, açıkça>
```

Mercek kontrolü: oyuncu deneyimi, Steam yorumları, kapsam ve zaman, teknik, pazar, maliyet. Hiçbir yolun
dokunmadığı mercek bir satırla "neden risk değil" diye geçilir.

Pre-mortem bir şeyi değiştirmediyse (önlem, kapı, uyarı, sayı) ya geç yapılmıştır ya da göstermeliktir.

## 4. Kapsam hesabı

```
İş listesi (göl testi: "vb." yok):
  1. <iş>  <kişi-hafta>  <hangi oyuncu kararına hizmet eder>
  ...
Toplam kapsam:               T kişi-hafta
Kapasite:                    kişi × hafta × verim (0,6-0,8)  = K
Tampon (%20-30):             B
Açık:                        T − (K − B)   → > 0 ise kesme zorunlu
```

Bizde kapasite iki kaynaktan oluşur: Erdem'in haftalık saatleri (oynama, karar, kabul) ve ajan kotası (haftalık
hesap limiti). Kritik yol çoğu zaman Erdem'in oynama ve onay saatidir; plan bunu ayrı satırda gösterir.

Kesme sırası: oyuncu kararına hizmet etmeyen → bedeli yüksek etkisi düşük → çekirdeğe hizmet edenin en küçük
hâli → çekirdek döngü (korunur). Kesilen iş gerekçe ve "ne zaman yeniden bakılır" koşuluyla "sonra" listesine.

## 5. Risk matrisi

| Risk | Olasılık | Etki | Önlem (somut, tarihli) | Tespit (nasıl anlarız, eşik) |
|---|---|---|---|---|
| Çekirdek döngü 3. haftadan sonra tekrar ediyor | Orta | Yüksek | <tarih>'e kadar dilim oturumu; değilse sadeleştirme | Erdem'in 15 dk dilim oturumunda "karar kalmadı" notu |

"Sonra düzeltiriz" önlem değildir. "Anlarız" tespit değildir.

## 6. Kilometre taşı kapıları

Tarihler ve hedef fest `project-unicorn/docs/strateji/EL_KITABI.md`'den okunur (Haziran 2027 önerisi K1
kararına bağlı). Kapı ölçütü "o gün ne doğru olmalı":

| Kapı | Ne doğru olmalı |
|---|---|
| Çekirdek kanıtlandı | Çekirdek döngü insan oyununda eğlenceli bulundu (Kat 2), yalnız bot ya da smoke değil |
| Coming Soon sayfası | Sanat yönü seçildi; ad, kapsül, ekran görüntüleri çekirdeğin gerçek hâlini gösteriyor; YZ beyanı tutarlı |
| Kapalı playtest | Demo dilimi baştan sona oynanıyor; hipotez ve eşikler yazılı; bırakanlar da kaydediliyor |
| Demo yayında | Kapalı playtest bulgularının kritik olanları kapandı; fest öncesi wishlist birikmeye başladı |
| Next Fest | Steam'in fest koşulları sağlandı; demo festten aylar önce açık |

Atlanan kapı "atlandı, neden, bedeli" diye yazılır.

## 7. Playtest planı

```
Hipotez: Şuna inanıyoruz: <X>. Bunu <ölçü> ile ölçeriz; <eşik> doğrular, altı çürütür.
Kim: <Erdem / kapalı test, N kişi, profil>   Süre: <dk>   Dilim: <hangi hafta aralığı>
Gözlem: zaman damgalı not (duraksama, yanlış tık, sesli şikâyet)
Ölçü: yalnız hipotezi besleyenler; beslemeyen ölçü kesilir
Görüşme: açık sorular ("en son ne zaman ...?"), yönlendiren soru yok
Analiz: bulgu başına kaynak sayısı (gözlem / ölçü / söz): 1 = hipotez, 2 = kalıp, 3 = güçlü
Öncelik: şiddet (bıraktı / takıldı / kısa kafa karışıklığı / zevk) × sıklık (kişilerin kaçında)
Hüküm: DOĞRULANDI / ÇÜRÜTÜLDÜ / BELİRSİZ + kanıt
```

Önyargı kontrolü: yalnız destekleyen veriye bakmak, son oyuncuya fazla ağırlık, tasarım niyetiyle sorunu
açıklamak, yalnız bitirenleri saymak.
