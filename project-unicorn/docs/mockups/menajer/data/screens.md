# Maket verisi: Ekip, Satış ve Frank'in teklifi

Seed `_seed_theme_surface` (run_seed 424242, hafta 14), ofis `ishani`, saat 11:00, dil TR. Kaynak: `ref/explore_screens.md`, `localization/strings.csv` ve `sandbox/ui_lab/shots/baseline/*.png` ile karşılaştırıldı. Makine için aynı veri: `screens.json`.

Baseline PNG'ler renk körü paletiyle çekildi: olumlu mavi `#2C6FAE`, olumsuz turuncu `#B36B00`. Standart palette olumlu `#2F6B3A`, olumsuz `#9B3B28`.

## Maket düzeltmeleri

Bunlar yalnız makette uygulanır; oyun ve CSV değişmez.

| Yer | Oyunda bugün | Makette |
|---|---|---|
| Ekip sütun başlığı | TRAIT | HUY |
| Frank kartı, ilişki etiketi | NEUTRAL | NÖTR |
| Bildirim kartı etiketi | NORDİCA | NORDICA |
| Satış aday satırı, Karadeniz Fabrika | PH: Ölçülü bir alıcı. Önce kararlılığı sorar. | Ölçülü bir alıcı. Önce kararlılığı sorar. |
| Satış aday satırı, Efes Emlak | PH: Hızlı konuşur, rakama erken gelir. | Hızlı konuşur, rakama erken gelir. |
| Ekip mesai çipi | 09:00–17:00 | 09:00 ile 17:00 arası (dar alan için: 09.00 · 17.00) |
| Ekip DURUM hücresi, Deniz Arslan | — | boş |
| Satış portföyü, temsilci satırı (üç kart) | Müşteri temsilcisi: — | Müşteri temsilcisi: atanmadı |

CSV'deki gibi kalanlar: rol unvanları (Ürün Yöneticisi, UX/UI Designer, Yazılım Mühendisi, Test Mühendisi, Satış Temsilcisi) ve "Operating Partner".

Açık not: oyun rol unvanını Türkçe büyük harfe çevirir, bu yüzden "UX/UI Designer" ekranda "UX/UI DESİGNER" olur. Makette CSS `text-transform: uppercase` ile `lang="tr"` aynı sonucu verir. Bu düzeltme listesinde değil; karar sahibinde.

## Kabuk ölçüleri

- Sahne 1920×1080. TopBar 54 px, haber şeridi altta 34 px, sol ray 84 px.
- Ofis alanı (84, 54), 1836×992. Ofis görseli: `art/office_game.png` tam bu alana oturur.
- Ekip penceresi 1200×720, (100, 70). Satış penceresi 1280×760, (100, 70). Frank kartı 780 px geniş, en az 420 px yüksek, ortada.

## TopBar

Soldan sağa:

| Başlık | Değer | Not |
|---|---|---|
| (logo) | Unicorn Inc. | amber kare `#FFA028` |
| KASA | $10.000 | |
| MRR | $4,0K | |
| BURN | $1,5K /ay | |
| NET | +$2,5K /ay | olumlu renk |
| RUNWAY | Artıda | olumlu renk; ipucu: "Gider gelirin altında; kasa erimiyor. Sayaç, net akış eksiye dönerse işler." |
| MARKA | 50 | |
| İTİBAR | 0 | |

- Tarih: "Hafta 14 · Nisan 2026 · 11:00" (1600 px altında: "H14 · Nis · 11:00").
- Evre: "BOOTSTRAP" ve üç nokta, ilki etkin.
- Hız tuşları: II, 1x, 2x, 3x, 4x. Etkin olan "II" (saat tutuluyor).
- Not: BURN $1,5K başlangıç değeridir, $43.600'lük maaş yükünü yansıtmaz (saat tutulduğu için tik yeniden hesaplamadı).

## Sol ray

| Sekme | Etiket | Rozet |
|---|---|---|
| product | Ürün | yok |
| sales | Satış | 1 (Ege Sigorta risk altında) |
| hr | Ekip | 1 (Selin Kaya ayrılabilir) |
| finance | Finans | yok |
| personal | Kişisel | yok |
| marketing | Pazarlama | kilitli: saydamlık 0,45 ve "YAKINDA" etiketi |
| rnd | Ar-Ge | yok |
| events | Olaylar | yok |
| settings (dişli, altta) | Ayarlar | yok |

Simgeler: `project-unicorn/assets/icons/tabs/*.svg` (Lucide, beyaz çizgi). Etkin renk `#9A6A12`, boşta `#8A8175`. Rozet amber hap `#F4C430`, yazı `#2B2722`.

## Haber şeridi

Ayraç "   ·   ". Yayın adı amber `#FFA028`.

1. **Sektör Telgrafı** Teknoloji kampüslerinde staj kontenjanları rekor kırdı.
2. **Ekonomi Postası** Sunucu kiralarında indirim sezonu; altyapı ekipleri pazarlıkta.
3. **TeknoGündem** Sanayi bölgelerinde dijital dönüşüm ihaleleri sıraya girdi.
4. **Girişim Bülteni** Melek yatırım ağları yeni dönem başvurularını açtı.
5. **Sektör Telgrafı** Yazılım ihracatçıları yeni pazar arayışında; fuar takvimi dolu.
6. **Ekonomi Postası** Ofis pazarında küçülme sürüyor; paylaşımlı katlar dolu.
7. **TeknoGündem** Teknoloji basınında değerleme sohbeti hiç bitmiyor.
8. **Ekonomi Postası** Tohum yatırımcıları takvim dolduruyor; erken aşamada trafik yoğun.

## Ofis üstü öğeler

- **Bildirim kartı** (ofis sağ alt): yeşil nokta (`#2F6B3A`; renk körü `#2C6FAE`), etiket "NORDICA", başlık "Büyüme talebi masada".
- **Ofisi taşı** düğmesi (ofis sol alt): "Ofisi taşı".
- **Yapım kartı (BuildHUD)** (sağ üst): "Unicorn Inc. v1" · "DESTEK" "DOĞRULANMIŞ 0" · "▸ DÜZELTME BAŞLAT".
  - Not: DOĞRULANMIŞ 0 ile Ege'nin "sık kesinti" gerekçesi farklı kaynaklardan okunuyor (oyundaki çelişki).

## Ekip penceresi

- Başlık: **Ekip**
- Özet: "ÇALIŞAN 5 · ORTALAMA MORAL 50 · AYLIK MAAŞ YÜKÜ $43.600"
- Mesai çipi (saat simgesi, yalnız kenar çizgisi): "09:00 ile 17:00 arası"
- Amber düğme: "+ İŞE ALIM BAŞLAT"
- Bölümler: **KADRO** (etkin, mürekkep rengi ve 2 px amber alt çizgi) · GÖREVLER
- Risk şeridi: uyarı simgesi, "Selin Kaya", "MORAL 22" (olumsuz renk)

**Sütunlar** (genişlik px): ÇALIŞAN · ROLLER · LİDERLİK (256) · GÖREV (150) · DENEYİM (72) · DURUM (140) · HUY (56) · MAAŞ (76) · MORAL (124)

**Gruplar ve satır sırası** (grup içinde önce en kötü rozet, sonra en eski işe giriş):

- ÜRÜN & TASARIM: Deniz Arslan, Elif Demir
- GELİŞTİRME EKİBİ: Selin Kaya, Mert Yıldız
- SATIŞ: Burak Şahin
- MÜŞTERİ İLİŞKİLERİ: boş; "Henüz kimse yok" ve "İŞE ALIM BAŞLAT" düğmesi

**Çalışanlar**

| | Elif Demir | Deniz Arslan | Mert Yıldız | Selin Kaya | Burak Şahin |
|---|---|---|---|---|---|
| Unvan (CSV) | Ürün Yöneticisi | UX/UI Designer | Yazılım Mühendisi | Test Mühendisi | Satış Temsilcisi |
| Ekranda | ÜRÜN YÖNETİCİSİ | UX/UI DESİGNER | YAZILIM MÜHENDİSİ | TEST MÜHENDİSİ | SATIŞ TEMSİLCİSİ |
| Ana alan | Ürün 7 (3,5★) | Tasarım 6 (3★) | Yazılım 8 (4★) | Test 5 (2,5★) | Satış 6 (3★) |
| İkincil alan | Tasarım 6 (3★) | Ürün 5 (2,5★) | Test 7 (3,5★) | Yazılım 4 (2★) | yok |
| Liderlik | 6 (3★) | 2 (1★) | 3 (1,5★) | 1 (0,5★) | 2 (1★) |
| GÖREV | Yapımda görev alıyor | Yapımda görev alıyor | Yapımda görev alıyor (soluk) | Test ediyor | Satışta görev alıyor |
| DENEYİM | %0 (eşik 250) | %0 (eşik 190) | %0 (eşik 244) | %0 (eşik 172) | %0 (eşik 178) |
| DURUM | YENİ çipi | boş | İzinde · 2 hafta kaldı | AYRILABİLİR çipi (olumsuz) | YENİ çipi |
| HUY | GERÇEK LİDER | İŞKOLİK | SADIK | TİTİZ | ÇABUK KAPAR |
| MAAŞ | $9.800 | $7.400 | $11.200 (soluk) | $6.900 | $8.300 |
| MORAL | 72 | 38 | 61 | 22 | 55 |
| Bust | art/bust_elif.png | art/bust_deniz.png | art/bust_mert.png | art/bust_selin.png | art/bust_burak.png |

Mert izinde: bütün satırı 0,45 saydamlıkla çizilir.

**Yedi becerinin tamamı** (puan; yıldız = puan / 2):

| | Ürün | Tasarım | Yazılım | Test | Satış | Müşteri İlişkileri | Liderlik |
|---|---|---|---|---|---|---|---|
| Elif | 7 | 6 | 4 | 4 | 4 | 4 | 6 |
| Deniz | 5 | 6 | 3 | 3 | 3 | 3 | 2 |
| Mert | 4 | 4 | 8 | 7 | 4 | 4 | 3 |
| Selin | 3 | 3 | 4 | 5 | 3 | 3 | 1 |
| Burak | 3 | 3 | 3 | 3 | 6 | 3 | 2 |

Deneyim eşiği = 40 + 6 × yedi becerinin toplamı. Deneyim hücresi 4 px çubuk ve "%0".

**Huylar** (hücrede yalnız 26 px simge kutusu; ipucu "etiket" ve altında "etki"):

| Huy | Etki | Simge |
|---|---|---|
| GERÇEK LİDER | Sorumlusu olduğu alanda herkes daha hızlı öğrenir; ayrılıkları ağır alır. | traits/takes_them_under.svg |
| İŞKOLİK | Mesai morali onda çok daha yavaş erir. | traits/last_one_out.svg |
| SADIK | Moral düşükken bile kolay kolay ayrılmaz; rakip teklifine dayanır. | traits/loyal.svg |
| TİTİZ | Geliştirmede çok daha az hata çıkarır, ama yavaş çalışır. | traits/double_checker.svg |
| ÇABUK KAPAR | Deneyimi belirgin şekilde hızlı kazanır. | traits/picks_it_up_fast.svg |

Simge klasörü: `project-unicorn/assets/icons/traits/`.

**Rol ipuçları** (satır üstüne gelince):

- Ürün Yöneticisi: Ne yapılacağına karar verir, ekibi aynı hedefe bakar tutar.
- UX/UI Designer: Ürünün nasıl göründüğünü ve nasıl kullanıldığını kurar.
- Yazılım Mühendisi: Ürünü yazar. Kod tabanı ondan çıkar.
- Test Mühendisi: Ürünü kırmaya çalışır. Bulduğu her hata müşteriye gitmeyen hatadır.
- Satış Temsilcisi: Aday müşteri bulur, anlaşmayı kapatır.

**Moral eşikleri** (çubuk 92×6 ve sayı):

| Eşik | Anlamı |
|---|---|
| 35'in altı | Kaçma riski: AYRILABİLİR çipi, kadronun üstünde kırmızı risk şeridi, Ekip rayında rozet, grubunda en üste çıkar. 2 hafta bu durumda kalırsa istifa zarı atılır; 3 haftada istifa kesindir. |
| 50'nin altı | Amber renk ve çalışma hızı ×0,85 (yüzde 15 yavaş). |
| 80 ve üstü | Çalışma hızı ×1,10 (yüzde 10 hızlı). |

- Renk: 50 ve üstü olumlu, 35 ile 49 arası amber, 35'in altı olumsuz.
- Yeni işe alınan 75 moralle başlar.
- Motorda "tükeniyor" eşiği yoktur; terim yalnız sözlükte geçer.

## Frank'in teklifi kartı

- Üst satır: **MENTOR** rozeti, "KARAR · HAFTA 14 · NİSAN 2026"
- Başlık: **Frank'in teklifi**
- Gövde, dört paragraf:
  1. Ürün para kazandırmaya başladı.
  2. Arayan yine Frank.
  3. "Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?"
  4. Cevap bekliyor.
- Konuşan: portre `art/frank.png` (oyunda 24 px kare), "Frank Köseoğlu · Operating Partner", ilişki etiketi **NÖTR**. Huy rozeti yok.
- Seçenek 1: **Kabul et**, amber çip "NAKİT +$25K · FRANK'E %4 HİSSE"
- Seçenek 2: **Reddet**, kilitli (0,5 saydam), çip "ZOR MODDA AÇILIR." Kilit gerekçesi: "Zor modda açılır."
- Alt satır (ince çizginin altında): "SEÇİM KALICIDIR · OYUN DURAKLATILDI"

## Satış penceresi (tamamlık için)

- Başlık: **Satış**
- Göstergeler: MÜŞTERİ 3 · ORT. MEMNUNİYET %56 · BU AY KAZANILAN +0 · BU AY NET 0
- Fiyat duruşu: Rekabetçi · **Standart** (etkin) · Premium
  - Rekabetçi: Koltuk fiyatı bandın altında. Masa kolay açılır.
  - Standart: Koltuk fiyatı bandın ortasında.
  - Premium: Koltuk fiyatı bandın üstünde. Temsilcinin işlemesi uzar.
- **BORU HATTI**, sağda "Akış: 6,5/hafta"
  1. **Karadeniz Fabrika**, 2★ (5 üzerinden), "1 hafta". Satır: "Ölçülü bir alıcı. Önce kararlılığı sorar." Düğmeler: Ayır · Temsilciye ver · **Görüşmeye git** (amber).
  2. **Efes Emlak**, 1★, "1 hafta". Satır: "Hızlı konuşur, rakama erken gelir." Aynı düğmeler.
- **SATIŞ MASASI**: Burak Şahin 3★. "Çalıştığı bant:" 1★ · 2★ · 3★ · **Kendi ligi** (etkin).
- **MÜŞTERİ PORTFÖYÜ**, sağda "3 müşteri". Sıra: risk, büyüme, diğerleri. Hepsi 3★.
  1. **Ege Sigorta** (dikkat kartı), çip RİSK ALTINDA. "$1,0K/ay · 12 koltuk · 2 aydır müşteri". İtalik: "Sebep: sık kesinti şikayeti". "Müşteri temsilcisi: atanmadı" [Değiştir]. Amber: "İlgilen →". Memnuniyet 25.
  2. **Nordica**, çip BÜYÜMEK İSTİYOR. "$2,0K/ay · 20 koltuk · 6 aydır müşteri". İtalik: "Başka departmana yaymak istiyor." "Müşteri temsilcisi: atanmadı" [Değiştir]. Amber: "Değerlendir →". Memnuniyet 72.
  3. **Kuzey İnşaat**, çip SAĞLIKLI. "$1,0K/ay · 12 koltuk · 3 aydır müşteri". "Müşteri temsilcisi: atanmadı" [Değiştir]. Eylem düğmesi yok. Memnuniyet 72.

## Görseller

| Dosya | İçerik |
|---|---|
| art/office_game.png | Ofis, bugünkü oyun çerçevesi, 1836×992 (sha1 baseline ile aynı) |
| art/office_full.png | Ofis, tam 1920×1080 çerçeve |
| art/bust_<ad>.png | 512×512 bust, alfa düzeltilmiş: elif, deniz, mert, selin, burak, kurucu |
| art/bust64_<ad>.png | 64×64 bust, oyundaki çizgi kalınlığını görmek için |
| art/frank.png | Frank'in boyalı portresi, 1408×1760 |
| art/founder_portrait.png | Kurucu portresi (founder_01), 1408×1760 |

Bust'lar oyunda `#1B232B` renkli yuvarlak bir diskin içinde gösterilir (CSS: `border-radius: 50%`).

## Renk ve yazı referansı (scripts/theme/ui_tokens.gd)

- Sayfa `#F6F1E6`, kart ve pencere `#FBF7EE`, ray `#ECE5D6`, mürekkep `#2B2722`, ikincil `#5B544A`, soluk `#8A8175`, en soluk `#A99E8E`
- Kart kenarı `#D9D0BF`, iç çizgi `#E3DAC9`
- Amber dolgu `#F4C430`, amber yazı `#9A6A12`, amber çip zemini `rgba(154,106,18,.10)`
- Koyu çerçeve `#07090B`, üstünde yazı `#E8EDF2`, alt yazı `#74828F`, TopBar başlıkları `#46525D`, amber `#FFA028`
- Olumlu `#2F6B3A` (renk körü `#2C6FAE`), olumsuz `#9B3B28` (renk körü `#B36B00`), koyu zeminde olumlu `#3FD68C` (renk körü `#56B4E9`)
- Yazılar: JetBrains Mono, IBM Plex Sans, Source Serif 4 (`project-unicorn/assets/fonts/`)
