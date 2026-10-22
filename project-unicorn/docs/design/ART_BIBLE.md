# Art Bible: Project Unicorn

> **Durum:** İskelet. Sanat yönü seçilince bölüm bölüm doldurulur; her bölüm Erdem'in ayrı onayıyla kapanır.
> **Sahibi:** Erdem (karar), Claude (taslak).
> **Son güncelleme:** 2026-10-20
> **Kaynak:** Bölüm yapısı Claude Code Game Studios `templates/art-bible.md` (MIT, Donchitos) ile
> `create-game-assets` skill'inin eksen tablosundan (Apache-2.0) uyarlandı.

Bir bölümde hâlâ `[Tasarlanacak]` yazıyorsa o bölüm eksiktir. Bir bölüm onaylanınca o satır silinir ve onay tarihi yazılır.

## 0. Bağlayıcı kısıtlar (Erdem, 2026-10-20)

- **Dönemsiz.** Oyun 2012'de başlar ve yaklaşık 1,5 saatlik oyunla 2020'lere gelir. Ton bir döneme kilitlenmez.
  Dönem ancak değişen detay olabilir (cihaz, ekran, eşya); kimlik olamaz.
- **Bize has.** Hiçbir oyunun kopyası değil. Referanslardan özellik alınır (palet, şekil, malzeme, çizgi), görünüş alınmaz.
- **YZ görünümü yok.** Boşluksuz kalabalık, anlamsız detay, uyumsuz fontlar, yakında dağılan yüzeyler,
  birbirine yapıştırılmış üç ayrı dünya yok.
- **Oyun ölçeğinde okunur.** İzometrik kamera, 1920×1080. Her karar gerçek oyun ekranında ve küçük kapsülde
  (462×174) denetlenir.
- **Ton:** girişim dünyasına hiciv; oyuncuya alay değil.

## 1. Görsel kimlik cümlesi

[Tasarlanacak] Belirsizlik çıktığında hangi tarafın seçileceğini söyleyen tek satırlık görsel kural.
Altında 2–3 ilke yer alır. Her ilkenin bir tasarım testi vardır: "X belirsizse Y'yi seç".

## 2. Ruh hâli ve atmosfer

[Tasarlanacak] Aşağıdaki her oyun durumu için şunlar yazılır:
- duygusal hedef,
- ışık karakteri (saat, renk sıcaklığı, kontrast),
- 3–5 betimleyici,
- enerji düzeyi.

Durumlar birbirinden ayırt edilmeli.

| Durum | Hedef | Işık | Betimleyiciler | Enerji |
|---|---|---|---|---|
| Evde gece (yatak odası) | | | | |
| Ofiste gündüz | | | | |
| Ofiste gece | | | | |
| Toplantı (satış, yatırımcı) | | | | |
| Olay kartı ve mail | | | | |
| Menüler | | | | |

## 3. Görsel sistem (eksenler)

[Tasarlanacak] Her eksen gözlemlenebilir bir özellikle yazılır. "Güzel" ya da "sinematik" gibi kelimeler kullanılmaz.

| Eksen | Karar |
|---|---|
| Şekil dili (yuvarlak, köşeli, tıknaz, ince) | |
| Siluet (oyun ölçeğinde ne okunmalı) | |
| Değer bantları (kaç bant, gri tonda okunuyor mu) | |
| Renk rolleri (vurgu, tehlike, para, nötr, ortam, arayüz) | |
| Kenar ve çizgi (mürekkep kalınlığı, renk, nerede) | |
| Malzeme (ahşap, kumaş, cam, ekran, duvar) | |
| Işık (yön, yumuşaklık, ortam rengi, rim) | |
| Detay yoğunluğu (nerede toplanır, nerede kaybolur) | |
| Kamera (açı, odak, dönüş) | |
| Hareket (çevik, ağır, ölçülü) | |

## 4. Renk sistemi

[Tasarlanacak] Şunlar yazılır:
- 5–7 renklik ana palet ve her rengin anlamı,
- anlamsal kullanım,
- mekân başına renk sıcaklığı,
- arayüz paletinin nerede ayrıldığı (bugün koyu sıcak Menajer dili),
- renk körlüğü: hangi anlamsal renk bir şekil ya da ikonla desteklenir.

## 5. Karakter tasarımı

[Tasarlanacak]
- Kurucu, çalışan rolleri, yatırımcı ve müşteri bir bakışta nasıl ayrılır?
- İfade ve poz dili ne olacak?
- Oyun kamerasından bakınca hangi detay kalır?
- Bugünkü Quaternius gövdeleri kalacak mı, değişecek mi?

## 6. Mekân tasarım dili

[Tasarlanacak]
- **Mimari:** ev, iş hanı, loft, plaza.
- **Doku felsefesi:** boyalı, stilize ya da düz, ve neden.
- **Eşya yoğunluğu:** mekân başına kural.
- **Çevresel anlatım:** şirket büyüdükçe mekân ne anlatır?
- **Dönem geçişi:** 2012'den 2020'lere hangi eşyalar değişir?

## 7. Arayüz görsel yönü

[Tasarlanacak] Ekran üstü arayüz ile sahne nasıl tek dünya olur? Şunlar yazılır:
- tipografi (bugün Barlow Condensed, IBM Plex Sans, Source Serif 4),
- ikon dili,
- hareket,
- sanat ile okunabilirlik çatıştığında hangisinin seçildiği.

## 8. Aset standartları

[Tasarlanacak] Şunlar yazılır:
- dosya biçimleri,
- adlandırma,
- doku çözünürlüğü,
- mekân başına üçgen bütçesi (bugün loft 1,23 milyon üçgen),
- malzeme yuvası,
- Godot içe aktarma ayarları.

Sanat tercihi ile teknik sınır çatışırsa ikisi de yazılır ve seçilen ödünleşim not edilir.

## 9. Referans yönü

[Tasarlanacak] 3–5 referans. Her biri için iki şey yazılır:
- tam olarak hangi öğenin alındığı,
- kopya gibi okunmaması için neden kaçınıldığı.

## 10. Görsel hedef (sözleşme)

[Tasarlanacak] Onaylı bir hedef kare yer alır: gerçek oyun ekranında temsilî bir karakter, bir mekân parçası ve
bir arayüz parçası. Sonraki her aset bu kareyle aynı boyutta ve aynı ışıkta karşılaştırılır. Kareye aynı kameradan
iki görüntü eşlik eder, 13:00 ve 22:00; ikisinin yanında bu makinede ölçülen ms süresi yazılır.

## 11. Köken kaydı

[Tasarlanacak] Her aset için kaynak, lisans, araç ve düzenleme geçmişi tutulur. Steam'in YZ beyanı bu kayıttan yazılır.
