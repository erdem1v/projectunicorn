CLAUDE.md §8 istisnası: bu rapor `docs/tasks/PRD_RENDER_ASSETLAB.md` gereği ve sahibin kararıyla repoda tutulur.

# Teşhis: kaydırınca biçim değiştiren gölge bantları

## Künye

- Makine: AMD Radeon RX 9070 XT, D3D12 12_0, Forward+, Godot 4.6.2-stable. Pencere 1920×1080; ofisin 3B alt görüntüsü
  1736×976 (2560×1440 pencerede de 1736×976, büyütülür).
- Araç: `scripts/debug/office_pan_probe.gd` (`a878ce3`), `--office-shot` koşusuna `--pan`, `--pan-set`, `--pan-gpu`.
  Her adım kamerayı taban hedeften piksel cinsinden kaydırır, 3B görüntüyü alır ve aynı (küme, zoom) grubunun ilk
  karesine kaydırma kadar ötelenmiş farkı basar: `mean` (RGB ortalama mutlak fark, 0-255), `max`, `n8` (en büyük kanal
  farkı 8'i aşan piksel sayısı).
- Hücre = ofis × saat (dört hücre), her biri iki zoom'da; tablolarda satır = hücre × zoom. `R` = 1..16 piksel
  kaydırmanın `n8` medyanı; `F_shift` = gölge kapalıyken `R`.
- Kareler `docs/audits/render/` altında, git dışı (sahip kararı).

## Geçerlilik

| Kontrol | Koşu | Sonuç |
|---|---|---|
| Süreç içi belirlenimcilik | `ishani:13 --pan=0,0;0,0` | `resid_max 0` |
| Süreçler arası | iki ayrı APPDATA, `--pan=0,0`, PNG farkı | 0 |
| Sürükleme | `drag:200:0:1` ve `drag:200:0:20` | hedef farkı 0, görüntü farkı 0 |
| Kayma | her taramanın sonundaki `0,0` | `n8 0`, sekiz taramanın hepsinde |
| Pozitif kontrol | `SETDIFF`, gölge kapalı | ishani 13: 58.608 piksel; ev 13: 66.762 |
| Atlas belleği | `atlas=8192`, `video_mib` | 569,1 → 668,1 (+99 MiB) |

## Tarama (önce, `a878ce3`, tabanda vinyet kapalı)

`n8` medyanı, 1..16 piksel yatay kaydırma:

| Hücre | taban | gölge yok | ink yok | glow yok | Hard (0) | Medium (3) | atlas 8192 |
|---|---|---|---|---|---|---|---|
| ishani 13, ×1,08 | 2907 | 280 | 2690 | 2907 | 392 | 782 | 1631 |
| ishani 13, ×3,25 | 2416 | 323 | 2245 | 2416 | 388 | 608 | 1510 |
| ishani 17, ×1,08 | 4346 | 318 | 4065 | 4346 | 410 | 1071 | 2470 |
| ishani 17, ×3,25 | 5852 | 349 | 5614 | 5852 | 388 | 742 | 3198 |
| ev 13, ×1,74 | 5140 | 2076 | 5106 | 5140 | 2214 | 2460 | 4030 |
| ev 13, ×5,23 | 2229 | 354 | 2243 | 2230 | 438 | 631 | 1440 |
| ev 17, ×1,74 | 7688 | 2066 | 7340 | 7688 | 2164 | 2526 | 4694 |
| ev 17, ×5,23 | 4250 | 354 | 4232 | 4250 | 452 | 625 | 2248 |

Hüküm kuralı (önceden ilan edildi), her satırda: `R ≤ max(3·F_shift, 0,05·R0)` "kayboldu", `R ≤ 0,7·R0` "azaldı"; dört
hücrenin (ofis × saat) en az üçü aynı sonucu vermeli.

## Hüküm

İki ayrı mekanizma var.

1. **Ev: döşeme ile cephe derisinin z-çatışması.** Gölge kapalıyken bile evin geniş karelerinde `F_shift`
   2066-2076 (yakın karelerde 354; İş hanında 280-349); fark gölgeden bağımsız. Fark haritası pencerelerin üstünde 0,3 m'lik koyu bir bant gösteriyor: tasarımın döşemesi
   (`7d746a`, y −0,3..0) dış yüzleriyle (z 9,85 ve x 12,25) cephe derisiyle aynı düzlemde; derinlik testi kamera
   konumuna göre taraf değiştiriyor. Onarım `0d17090`: döşeme normali boyunca 0,01 m geri çekilir (toon gölgelendiricide
   `inset`, düğüm ölçeğine bölünerek). Ev 13 gölge kapalı: `n8` 2076 → 596, `max` 8209 → 1183.
2. **İki ofiste de: Soft Low PCF deseni ekrana bağlı.** Hard (`soft=0`) sekiz satırın hepsinde kurala göre "kayboldu"
   (ishani 13: 392, gölge kapalı 280). Medium (3) sekizin yedisinde kurala giriyor ama kalan farkı Hard'ınkinin 1,4
   ile 2,6 katı (ishani 13: 782) ve ishani 17 ×1,08'de "azaldı"da kalıyor (1071 > 3·318).
   Mekanizma Godot 4.6.2 kaynağında: PCF örnek diski `quick_hash(gl_FragCoord.xy + taa_frame_count·5,588)` ile
   döndürülür (`scene_forward_lights_inc.glsl:292-297`), yani piksel konumuna bağlı; aynı pozda iki kare bit bit aynı
   olduğuna göre bu projede kare sayısı deseni değiştirmiyor. Kamera kaydıkça gölge kenarındaki pikseller başka desene
   düşüyor.
   Onarım `d580b66`: `soft_shadow_filter_quality` 2 → 0 (tek örnek, desen yok). Plaza taranmadı; fark haritası orada
   da yalnız gölge kenarlarında (`filtre_plaza_13_soft_hard_kirpim.png`).

Elenenler:
- **Kutu kenarı yuvarlaması (aday 2):** motorun sığdırması `r·N/(N−2)`, `unit = 4r/N`; iki kenar ayrı yuvarlansa da genişlik
  N/2 birimde sabit. Ölçüm: her adımda W = 2048 (8192'de 4096); `n8` sıçramaları kenar indeksi atlamalarına denk
  düşmüyor.
- **Sapma (aday 3):** r ve derinlik kaydırmada değişmiyor; bandın durağan biçimini açıklar, kaydırmayı açıklamaz.
- **Kontur:** `ink=0` farkı tabanla aynı mertebede (2690 / 2907).
- **Glow:** gündüz `glow=0` SETDIFF 0 (ishani ve ev, 13 ve 17); tarama değişmiyor. Toplantı odasında 13:00'te 2329
  piksel değişiyor, fark haritasına göre yalnız animasyonlu toplantı kişilerinde.
- **Atlas 8192:** desen incelir ama kaybolmaz (2907 → 1631); +99 MiB ve GPU +%15.
- **Kayan nokta, z, 16 bit:** Hard sonrası kalan fark gölge kapalı tabana yakın (kural içinde), `bits=32` gerekmedi.

## Sonra (`e78b922`, son HEAD)

Aynı tarama, aynı ofsetler (`n8` medyanı; gölge kapalı küme taban):

| Hücre | önce | sonra | gölge kapalı (sonra) |
|---|---|---|---|
| ishani 13, ×1,08 | 2907 | 392 | 280 |
| ishani 13, ×3,25 | 2416 | 388 | 323 |
| ishani 17, ×1,08 | 4346 | 410 | 318 |
| ishani 17, ×3,25 | 5852 | 388 | 349 |
| ev 13, ×1,74 | 5140 | 680 | 596 |
| ev 13, ×5,23 | 2229 | 188 | 116 |
| ev 17, ×1,74 | 7688 | 614 | 540 |
| ev 17, ×5,23 | 4250 | 246 | 136 |

Kalan fark gölge kapalı tabana yakın (tabanın +%11 ile +%81 üstü, en çok 112 piksel); taban gölgeden bağımsızdır
(gölge kapalı kümede de var). Kareler: `once_gunduz_<ofis>_<sol|orta|sag>.png`, `sonra_gunduz_*`, `once_gece_*`, `sonra_gece_*`
(ishani, home, plaza, loft); z-çatışması kırpımları `zcatisma_ev_13_kirpim_{once,sonra}.png`.

Hard filtrenin kontrolleri:
- Sivilce, yatık güneşte (×3 zoom): plaza 08:00'de sapmayı iki katına çıkarmak yalnız sandalye ayaklarının temas
  gölgesini inceltiyor, aydınlık yüzeyde benek yok (`filtre_plaza_08_sandalye_sapma.png`); ev 08:00'de seçili sapma
  temiz (`bias_secili_ev_08.png`). Ev ve plaza 19:00'da iki katı sapma 458 ve 1080 piksel değiştiriyor; sivilce
  geniş yüzeyleri değiştirirdi.
- Kenar kırıklığı: plaza'da gölge texeli 2,04 piksel (×3'te 5,29); ×3 büyütmede basamak görünür ama kenar net
  (`filtre_plaza_13_soft_hard_kirpim.png`); 2560×1440 karesi `filtre_ishani_13_2560_soft_hard.png`.

## Gece ve gün

22:00:full, ışıklar tek tek kapatılarak (`SETDIFF`: ortalama fark 0-255 / 8'i aşan piksel):

| Küme | ishani | ev |
|---|---|---|
| glow kapalı | 0,015 / 1169 | 0,096 / 5665 |
| TopFill kapalı | 34,99 / 1,24 M | 46,69 / 1,43 M |
| güneş (ay) kapalı | 7,53 / 955 K | 10,57 / 1,26 M |
| TopFill gölgeli, ay gölgesiz | 2,40 / 129 K | 5,21 / 198 K |
| glow dörtgenleri kapalı | 1,24 / 52 K | 0,09 / 6 K |
| masa lambası ve ekran ışıkları kapalı | 0,21 / 13 K | 0,36 / 27 K |
| eşik 1,3, hdr_scale 1 | 0,004 / 12 | 0,008 / 15 |

- "Gece duvar ve eşyalar parlıyor"un kaynağı TopFill'in gece terimi (1,0 × LIGHT_SCALE, gündüzün 3,3 katı), glow değil.
  Glow kapalı farkı yalnız ışık kaynaklarının halesinde (`glow_ev_22_fark.png`); plaza 52 piksel, loft ve şehir 0, taç
  223. Kareler: `gece_yalitim_<ofis>_*.png`, adaylar `gece_topfill_<ofis>_{1_0,0_5,0_3,golgeli}.png`.
- Akşam: başsız dakika taraması (İş hanı, t = 0..1440): dakika başına en büyük açı adımı 72,94° (19:26) → 2,35° (19:33).
  19:25 ile 19:26 karelerinin farkı ortalama 16,38 → 2,66, `n8` 1.118.938 → 94.325
  (`aksam_gecisi_ishani_<ssdd>_{once,sonra}.png`, `gun_dongusu_<ofis>_{sabah,ogle,aksam,gece}.png`).
- İsimsiz emission: 6 GLB'nin dökümü 7 imza + 2 harita işareti; boş plaza 22:00'de onarım yalnız cihazlarda 4762
  piksel değiştiriyor (`cihaz_plaza_22_fark.png`), dolu ofiste kare bit bit aynı.

## Ham satır örnekleri

```
PANCFG|atlas=4096|bits16=true|soft=2|msaa=2|fxaa=1|vignette=0.220|people=true
PAN|0|0|0|1.0839|18.4518|85.369|155.587|70.218|39.857|0.01946|1.0294|2048|2048|-1.0000|-1|-1|0|-961|-1345
PAN|4|-400|0|1.0839|18.4518|85.369|155.587|70.218|39.857|0.01946|1.0294|2048|2048|6.3593|125|548647|0|-1155|-1352
DRAG|200|0|20|0.000000|0.0000|0|0
SETDIFF|1|1.4608|135|58608
```
