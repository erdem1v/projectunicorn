CLAUDE.md §8 istisnası: bu rapor `docs/tasks/PRD_RENDER_ASSETLAB.md` gereği ve sahibin kararıyla repoda tutulur.

# Hüküm: ev ve İş hanı ücretsiz paketlerle

Kareler bu klasörde (git dışı): `<ev|ishani>_<kamera>_<gunduz|gece>_{mevcut,A,B,yanyana}.png`, `stil_*`,
`kalibrasyon_ishani_13.png`. Laboratuvar: `sandbox/asset_lab/` (`AssetLab.tscn`, tarifler `recipes/`).

## Ölçümün adaleti

- Kalibrasyon: laboratuvarın "mevcut" karesi oyunun kendi karesiyle bit bit aynı (İş hanı 13:00, `LABCAL` ortalama 0,
  en büyük fark 0; `kalibrasyon_ishani_13.png`). Kamera, ışık, ink ve vinyet oyunla aynıdır.
- Paketler çalışma zamanında `GLTFDocument` ile yüklenir; editör içe aktarmasıyla fark yalnız dokulu yüzeylerde
  (oyunun kendi GLB'si iki yoldan: ortalama 0,495, dokusuz yüzeylerde 0; `kalibrasyon_gltf_fark.png`).
- A'da ink ve vinyet yok (paketin kendi görünüşü). Paket malzemelerinin metallic'i 0'a çekildi: hiçbir pakette metalik
  haritası yok, oyunun gökyüzü laboratuvara yansıma vermiyor ve Nature Kit her modeli metallic 1 ile dışa aktardığı
  için ağaçlar siyah çıkıyordu. B'de toon malzemesi metallic okumaz.
- Görüntü oyunun 1920×1080 penceredeki 3B alt görüntüsüyle aynı boyda: 1736×976.
- Gece emission'ı rollerle elle bağlandı (ekran, lamba, direk, pencere); rol parçanın bütün yüzeylerini yakar, bu yüzden
  monitörün gövdesi ve lambanın direği de parlar. Yanan pencere camları statik (oyunda saat çizelgesiyle yanar).

## 1. Görsel dili bozmadan kurulabilir mi: kısmen

- **İç mekân: evet.** İki sahnenin oda düzeni, mobilya yerleri ve ölçüleri tasarımın kendi kurucularından çıkarılan
  konumlarla aynı kamerada kuruluyor (`ev_*`, `ishani_acik_ofis_*`, `ishani_toplanti_mutfak_*`). Oyunun toon ve ink
  geçişinden geçince (B) paket mobilyası oyunun çizgi diliyle okunuyor.
- **Kabuk ve şehir bağlamı: hayır.** Ücretsiz paketlerde tuğla cephe, beşik çatı, orta yükseklikte cephe ve tasarımın
  pencere düzeni yok. Komşu bloklar beyaz-gri, düz çatılı modern binalara dönüşüyor; siluet en çok burada değişiyor
  (`ishani_cephe_*`, `ev_acilis_*`).
- **Renk: kısmen.** Kenney'nin paleti (pembe sandalye, yatak ve koltuk; krem dolaplar; açık ahşap masalar) oyunun
  paletinden (lacivert sandalye, ceviz masa) farklı; Nature Kit ağaçları iki varyantta da nane rengi ve kökü kabarık,
  tasarımın yeşil yuvarlak taçları değil. Malzeme başına yeniden boyama gerekiyor.
- **Gece: kısmen.** Emission rolleri parçanın bütün yüzeylerini yaktığı için monitörün gövdesi ve lambanın direği de
  parlıyor; cephe pencereleri hep birlikte düz krem yanıyor (oyunda jaluzili, yaklaşık üçte ikisi). İkisi de malzeme
  düzeyinde rol ve pencere çizelgesi ister (laboratuvarın sınırı, paketin değil).

## 2. Aile ve varyant

- **Aile: Kenney** (Furniture Kit, Building Kit, Modular Buildings, City Commercial, Car, Nature). Stil testinde
  (`stil_*`) biçim dili oyunun kutu mobilyasına en yakın olan ve ink'le en temiz okunan aile. Ev tarifi tamamen Kenney
  (41 model); İş hanında üç Kenney dışı parça: KayKit `table_small` (Kenney masası 0,65 m), KayKit City `streetlight`
  (Kenney direği 3,34 m'ye sığınca 0,28 m kalın), MrEliptik `mug` (Kenney'de fincan yok). KayKit tıknaz ve yuvarlak,
  ayrı bir dil; Quaternius (Poly Pizza) ayrıntılı ve koyu, ink'te gürültü yapıyor ve ölçekleri tutarsız.
- **Varyant: B** (oyunun toon malzemesi ve ink). A paketin kendi gölgelemesiyle oyunun karakterlerinden ve
  ışığından ayrı bir dünya gibi duruyor.

## 3. Boşluklar ve kapanma yolu

`KARSILAMA.md` tam listeyi verir. Özet:
- Planlı ilkeller: beyaz tahta, cam bölme, bölme panosu, gardırop, korkuluk (PRD'nin saydığı dosya dolabı iki sahnenin
  envanterinde yok). Kapanma: basit kendi modelimiz (kutu düzeyinde), ya da bugünkü geometri kalır.
- Kabuk: döşemeler, duvarlar, kesik duvarlar, cephe kaplaması ve kat bantları, merdiven. Kapanma: bugünkü geometri
  kalır (tasarımın kurucusu zaten ilkel; paket karşılığı yok).
- Şehir bağlamı: tuğla bloklar, beşik çatılar, pencere çizelgesi, yanan pencereler. Kapanma: bugünkü dışa aktarım
  geometrisi kalır ya da kendi kiti.
- Küçük eşya: ocak üstü tencere, yuvarlak yemek masası, ayna, dolu kitaplık, masa üstü kırtasiye. Kapanma: kendi model.

## 4. İş tahmini

Tarif yazarlarının tahmini (ölçüm değil, tarifleri kuranların kalem kalem tahmini), bir sanatçının bu paketlerle
sahneyi yayın kalitesine getirmesi için:

| Sahne | Saat | Ana kalemler |
|---|---|---|
| Ev | 55-90 (orta 70) | beşik çatılı komşu bloklar ~22, pencere ve cam kiti ~10, ~35 modelin yeniden boyanması ~10, kesik kabuk, korkuluk ve merdiven ~12, eksik eşya ~10, ışık ve kontrol ~8 |
| İş hanı | 35-45 | sandalye, ağaç ve bina boyama ile tuğla cephe ~20, yalnız ekran ve lamba başı parlayan malzemeler ve pencere çizelgesi ~6, iç mekân dolgusu ~8, ışık ve kontrol ~6 |

İki sahnenin toplamı 90-135 saat; pencere ve cam kiti ile ortak modellerin yeniden boyanması ikinci sahnede tekrar
etmediği için gerçekçi toplam bunun alt yarısında, yaklaşık 80-110 saat.

**Ayrı satır, dışa aktarım hattının yerini paket hattının alması:** bugün `tools/office3d` tasarımın Three.js
kurucularından GLB üretir; oyun `OfficeLayout` ile o GLB'nin malzeme adlarını, pencere camlarını, glow'ları ve
istasyonlarını okur. Paket tabanlı bir hat, laboratuvarın tarif kurucusunun (`lab_scene.gd`) editörde koşan, sahneyi
diske yazan, emission rollerini malzeme düzeyinde ve pencere çizelgesini taşıyan bir sürümünü ister; yerleşim
verisinin bir kısmı (pencere camı düğümleri, gezinme zemini) yeni geometri için yeniden üretilir; koltuk, kapı ve
masa konumları tasarımın kurucularından geldiği için aynı kalır. Tahmin 32-50 saat: tarif kurucusunu editörde koşan,
sahneyi diske yazan bir araca çevirmek (paketlerin içe aktarma ayarları, malzeme düzeyinde emission rolleri, pencere
çizelgesi) 20-30 saat; yerleşim verisinin yeni geometriye bağlanması ve gezinme zemininin yeniden fırınlanması 6-10
saat; `OfficeView` ve `OfficeMaterials`'ın yeni sahneleri yüklemesi ve kontrol 6-10 saat. Plaza, loft, şehir ve
toplantı odası bu tahminin dışında (PRD kapsamı ev ve İş hanı).

## 5. Lisans

| Paket | Lisans | Kullanım |
|---|---|---|
| Kenney (8 paket indirildi, City Kit Suburban dışında 7'si kullanıldı) | CC0 1.0 | iki sahnenin ana ailesi |
| KayKit Furniture Bits, City Builder Bits | CC0 1.0 | İş hanında 2 model; stil testinde 5 |
| MrEliptik Office Low Poly Pack | CC0 1.0 | İş hanında fincan |
| Quaternius (Poly Pizza, 5 model) | CC0 1.0 (model başına) | yalnız stil testi |

Ayrıntı, bağlantılar ve sha256: `LISANS.md`; lisans metinleri `sandbox/asset_lab/licences/`. CC BY paket
kullanılmadı, atıf zorunlu değil. Nezaket atfı taslağı paket paket `sandbox/asset_lab/CREDITS.md`'de (önce EN, sonra
TR); önerilen aile için kısası:

> EN: Furniture, building, city, car and nature models by Kenney (www.kenney.nl); a table and street lights from KayKit
> by Kay Lousberg (www.kaylousberg.com); a mug from the Office Low Poly Pack by Victor Meunier (MrEliptik). All CC0 1.0.
>
> TR: Mobilya, bina, şehir, araba ve doğa modelleri Kenney'den (www.kenney.nl); bir masa ve sokak lambaları Kay
> Lousberg'in KayKit'inden (www.kaylousberg.com); bir fincan Victor Meunier'nin (MrEliptik) Office Low Poly Pack'inden.
> Hepsi CC0 1.0.

Quaternius uyarısı: quaternius.com 2026-08-28'de gelecekteki sürümler için QAL v1.0'a geçti (ticari kullanım serbest,
varlığı dağıtmak yasak). Oyundaki Quaternius 2022 karakterleri bundan önce alındı, etkilenmez. Önerilen ailede
Quaternius yok.

## 6. Oyun koduna dokunulmadı

Bölüm 2 başında (commit `a6b4592`'den önce, 17:31) çalışma ağacı temizdi. Bölüm 2'nin üç commit'i yalnız
`sandbox/asset_lab/`, `.gitignore` ve `docs/audits/asset_lab/` altına yazar:

```
a6b4592 Belgeler: render ve asset lab denetim klasörleri, yok sayma kuralları
 .gitignore                      | 8 ++++++++
 docs/audits/asset_lab/.gdignore | 0
 docs/audits/render/.gdignore    | 0
 sandbox/asset_lab/.gdignore     | 0
 4 files changed, 8 insertions(+)
293d14e Sandbox: asset laboratuvarı props aracı, paket manifestosu ve lisanslar
 docs/audits/asset_lab/ENVANTER.md                 | 226 ++++++++++++++++++++++++++++++
 docs/audits/asset_lab/LISANS.md                   |  41 ++++++
 sandbox/asset_lab/CREDITS.md                      |  41 ++++++
 sandbox/asset_lab/MANIFEST.md                     |  49 +++++++
 .../sandbox/asset_lab/licences/kaykit-city-builder-bits.txt       |  33 +++++
 .../sandbox/asset_lab/licences/kaykit-furniture-bits.txt          |  34 +++++
 .../sandbox/asset_lab/licences/kenney-building-kit.txt            |  28 ++++
 sandbox/asset_lab/licences/kenney-car-kit.txt     |  28 ++++
 .../sandbox/asset_lab/licences/kenney-city-kit-commercial.txt     |  28 ++++
 .../sandbox/asset_lab/licences/kenney-city-kit-roads.txt          |  28 ++++
 .../sandbox/asset_lab/licences/kenney-city-kit-suburban.txt       |  28 ++++
 .../sandbox/asset_lab/licences/kenney-furniture-kit.txt           |  23 +++
 .../sandbox/asset_lab/licences/kenney-modular-buildings.txt       |  28 ++++
 sandbox/asset_lab/licences/kenney-nature-kit.txt  |  23 +++
 sandbox/asset_lab/licences/mreliptik-office.txt   |  20 +++
 .../asset_lab/licences/quaternius-license-qal-2026-10-09.txt      |  73 ++++++++++
 .../sandbox/asset_lab/licences/quaternius-polypizza.txt           |  65 +++++++++
 .../licences/quaternius-ultimatehomeinterior-page-2026-10-09.txt  |  96 +++++++++++++
 sandbox/asset_lab/tools/props_extract/hooks.mjs   |  68 +++++++++
 sandbox/asset_lab/tools/props_extract/inst.mjs    |  32 +++++
 .../sandbox/asset_lab/tools/props_extract/package-lock.json       |  21 +++
 .../sandbox/asset_lab/tools/props_extract/package.json            |   9 ++
 sandbox/asset_lab/tools/props_extract/run.mjs     |  60 ++++++++
 23 files changed, 1082 insertions(+)
e2 (bu dosyayla birlikte)
 docs/audits/asset_lab/KARSILAMA.md     | 204 +++++++++++++++++
 sandbox/asset_lab/AssetLab.tscn        |   7 +
 sandbox/asset_lab/MANIFEST.md          |  24 +-
 sandbox/asset_lab/asset_lab.gd         | 352 +++++++++++++++++++++++++++++
 sandbox/asset_lab/lab_scene.gd         | 487 +++++++++++++++++++++++++++++++++++++++++
 sandbox/asset_lab/recipes/home.json    | 324 +++++++++++++++++++++++++++
 sandbox/asset_lab/recipes/ishani.json  | 300 +++++++++++++++++++++++++
 sandbox/asset_lab/recipes/palette.json |  39 ++++
 sandbox/asset_lab/recipes/style.json   |  43 ++++
 9 files changed, 1768 insertions(+), 12 deletions(-)
 docs/audits/asset_lab/HUKUM.md
```

e2'yi commit'lemeden hemen önce, yola göre süzülmüş `git status --short` (yalnız stage'lenmiş e2 dosyaları; stage dışı ya
da izlenmeyen artık yok):

```
A  docs/audits/asset_lab/KARSILAMA.md
A  sandbox/asset_lab/AssetLab.tscn
M  sandbox/asset_lab/MANIFEST.md
A  sandbox/asset_lab/asset_lab.gd
A  sandbox/asset_lab/lab_scene.gd
A  sandbox/asset_lab/recipes/home.json
A  sandbox/asset_lab/recipes/ishani.json
A  sandbox/asset_lab/recipes/palette.json
A  sandbox/asset_lab/recipes/style.json
```

Paket dosyaları, laboratuvar çıktısı ve kareler git dışında:

```
.gitignore:21:/sandbox/asset_lab/packs/        sandbox/asset_lab/packs/kenney-furniture-kit
.gitignore:22:/sandbox/asset_lab/out/          sandbox/asset_lab/out/cameras.json
.gitignore:20:/docs/audits/asset_lab/**/*.png  docs/audits/asset_lab/ev_acilis_gece_A.png
```
