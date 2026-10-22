# Araştırma şablonları

SKILL.md §3'ün ayrıntısı. Araştırma ajanına görev yazısıyla birlikte bu dosyanın yolu verilir.

## 1. Kaynak sicili

Raporun sonunda tek tablo. Numara ilk kullanımda verilir, sonra hiç değişmez; paralel ajanlara ayrı numara
blokları ayrılır (S1-S19 pazar, S20-S39 rakip, S40-S59 başarısızlar). Boşluk zararsızdır, çakışma değildir.

| ID | Kaynak (URL) | Yayıncı | Yayın | Erişim | Güven | Not |
|---|---|---|---|---|---|---|
| S1 | [Steamworks: Next Fest](https://partner.steamgames.com/doc/...) | Valve | güncel | 2026-10-20 | Yüksek | Birincil kaynak |
| S2 | [Oyun X postmortem](https://...) | Geliştiricinin blogu | 2024-05 | 2026-10-20 | Orta | Kendi sayılarını anlatıyor |
| S3 | [Wishlist dönüşüm raporu](https://...) | Pazarlama aracı satıcısı | 2025-02 | 2026-10-20 | Düşük | Satıcı; yöntem yazmıyor |

**Güven sınıfı kaynağa verilir, iddiaya değil:**
- **Yüksek:** platformun kendi belgesi (Steamworks), şirketin kendisi hakkındaki beyanı, geliştiricinin kendi
  oyununun sayıları, Steam'in kendi yorum verisi, hakemli çalışma.
- **Orta:** yöntemini yazan sektör analizi, tanınmış basın, birden çok kaynakla tutan haber.
- **Düşük:** araç ya da hizmet satıcısının içeriği, sponsorlu rapor, basın bülteni, tek blog yazısı, forum
  anekdotu, yöntemi yazılmamış her pazar sayısı.

Kullanım: Düşük kaynak renk ve hipotez verir, yük taşıyan bir sayıyı tek başına taşıyamaz. İki bağımsız Düşük
kaynağın uyuşması iddiayı güçlendirir, kaynağı değil; bunu yerinde yaz ("[S3][S7], bağımsız, %15 içinde
uyuşuyor").

## 2. Etiketleme

- Olgu cümlesi sonunda `[S#]`. Yorum cümlesi etiket istemez ama yalnız yakınındaki etiketli olgulara yaslanır.
- Bir kaynağı söylediğinden fazlası için kullanma: 2024 AB verisi "2026 Türkiye" için kanıt değildir.
- Oyuncu sözü, kural metni gibi sözcüğün önemli olduğu yerde harfi harfine alıntı ve etiket.
- Türetilmiş sayı formülüyle yazılır, her girdi etiketlidir, yumuşak girdide aralık verilir:
  `ilk hafta satış ≈ 10.000 wishlist [S4] × 0,10-0,15 dönüşüm [S5] ≈ 1.000-1.500`.
  Sayı en zayıf girdisinin güvenini taşır; bunu söyle.
- Kaynaksız her kabul `A#` alır ve varsayım tablosuna girer:

| ID | Varsayım | Dayanak | Duyarlılık |
|---|---|---|---|
| A1 | Demo oynayanların %30'u wishlist'ler | Benzer tür postmortem'i [S2], ölçeklenmiş | Yüksek: takvim hükmü buna bağlı |

  Duyarlılık sorusu: varsayım iki kat yanlışsa sonuç değişir mi? Yüksekse açık sorulara girer.
- Belge denetiminde beş etiket (`[BOŞLUK]`, `[SIÇRAMA]`, `[VARSAYIM]`, `[DEĞERLENDİREMEM]`, `[GÖRÜŞ]`) ve her
  bulguda harfi harfine alıntı ile `dosya:satır`. Kaynakta olmayan bir şey için "bulunamadı" yazılır.

## 3. Başarısızları bulma

Başarısız örnek arama motorunun ilk sayfasına kendiliğinden gelmez. Her emsal araştırmasında ayrı bir iz açılır
ve bütçeden pay alır (toplam aramanın en az dörtte biri).

Sorgu kalıpları (oyun adı ya da tür ile):
- `<oyun> postmortem`, `<oyun> "what went wrong"`, `<tür> indie failed launch postmortem`
- `<oyun> steam "mostly negative"` ya da `"mixed" reviews`, `<oyun> refund reasons`
- `<oyun> early access abandoned`, `<oyun> "update" "dead game"`
- `<tür> next fest "only" wishlists`, `<tür> demo low wishlists postmortem`
- Sanat için: `<oyun> art style criticism`, `<oyun> "looks like" asset flip`, `<oyun> ai art backlash`

Steam yorumlarının kendisi (oyuncu ne övüyor, neye kızıyor):
`https://store.steampowered.com/appreviews/<appid>?json=1&filter=all&language=english&review_type=negative&num_per_page=100`
ve aynısı `review_type=positive`. Olumlu ve olumsuz aynı sayıda okunur; sık geçen şikâyet ve övgü kendi
sözleriyle alıntılanır.

Karşılaştırma tablosu: aynı satırlar iki sütunda (başarılı / başarısız), ders farktan çıkar. Başarısız sütunu
boşsa "bulunamadı, şu sorgular denendi: ..." yazılır; sütun sessizce düşürülmez.

## 4. Şüpheci doğrulama turu

Teslimden önce, ayrı bir oturumda gibi düşmanca okunur. Liste:

1. Karara en çok yük bindiren ~10 iddia: her birinin kaynağını aç; sayı, birim, yıl ve tanım tutuyor mu?
2. Her türetilmiş sayıyı girdilerinden yeniden hesapla; zaman eksenini kontrol et (2024 tabanına 2026
   büyümesi uygulanmış mı?).
3. İki yıldan eski kaynak güncelmiş gibi mi sunuluyor? Metinde tarihle yaz ("2024 itibarıyla [S3]").
4. Kaynak yoğunlaşması: yük taşıyan sayıların çoğu tek yayıncıdan mı geliyor? Özellikle o yayıncı kendi
   aracını satıyorsa hükmün güveni bununla sınırlıdır; bunu hükmün kendisinde söyle.
5. Tek kaynağa çok iş: bir Düşük ya da Orta kaynak birkaç farklı iddiayı mı taşıyor? Her kullanımı ayrı
   desteklenmeli ya da her yerinde uyarılmalı.
6. Komşu kitle: en güçlü kanıt bizim hedef oyuncumuzu mu, yoksa komşu bir kitleyi mi anlatıyor?
7. Başarısız örnek izi gerçekten dolu mu?
8. İki kattan büyük ayrılıklar ortalamaya mı katıldı?
9. `searches: 0` ya da `evidence` alanı URL taşımayan hüküm var mı? Varsa "belirsiz (kanıtsız)" diye ayır.

Bulunan her şey ya düzeltilir ya raporda görünür uyarı olur; sessizce silinmez, sessizce bırakılmaz.

## 5. Araştırma raporu iskeleti

1. **Hüküm ve güven** (bir paragraf): "Öneri X, orta güven, çünkü A ve B; bunu değiştirecek şey C."
   Güven, kaynak yoğunlaşması ve komşu kitle sınırlarını hükmün içinde söyler.
2. **Hükmü taşıyan 3-5 olgu**, her biri `[S#]`.
3. **Başarılı / başarısız karşılaştırması** (tablo).
4. **Seçenekler ve öneri** (SKILL.md §4 kalıbı).
5. **Doğrulama turunun en büyük uyarısı.**
6. **Açık sorular**: masa başı araştırmanın kuramadığı ve nasıl sınanacağı (playtest, Erdem'in oynaması).
7. **Varsayım tablosu ve kaynak sicili** (ekte).

Masa başı araştırma oyuncu hakkında **sinyal** verir, doğrulanmış içgörü değil; oyuncu bölümü "açık sorular"
ile biter.
