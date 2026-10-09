CLAUDE.md §8 istisnası: bu rapor `docs/tasks/PRD_RENDER_ASSETLAB.md` gereği ve sahibin kararıyla repoda tutulur.

# Envanter: ev ve İş hanı (Başlangıç ofisi)

Kapsam: `home` ve `ishani` iç mekânları, bina kabukları ve çerçeveye giren sokak bağlamı (komşu cepheler, ağaç, direk, araba, bank). Şehir haritası, plaza, loft ve toplantı odası kapsam dışıdır. Birim: 1 birim = 1 m, Y yukarı.

**Not.** Tüm geometri prosedürel Three.js'tir (`B`, `RB`, `Cy`, `floorP` ve birkaç kurucu fonksiyonla; dokular canvas'tan üretilir). Zincirdeki tek dış dosya Xbot'tur (Mixamo kaynaklı; ticari onay kayıtlı değil, `docs/ACIK_ISLER/ACIK_KARARLAR.md` madde 72) ve yalnız harita kartı küçük resimlerinde kullanılır. İş hanı iç mekânı aynalıdır (`x -> 20 - x`); props JSON'daki `pose` ve `bboxWorld` değerleri zaten dünya konumudur, `args` ise aynalanmamış kurucu argümanlarıdır.

## Okuma

- `sim:N` = `tools/office3d/src/office-sim-v12.js` satır N; `home:N` = `tools/office3d/src/office-home.js` satır N (`tools/office3d/DESIGN_SOURCE.md` deltalarından sonraki sürüm; sha256 `fd075441c435` ve `30cd177562e7`). Adlı kalemlerde kaynak sütunu kurucunun tanım satırını ve sahne kurucusundaki çağrı satırını verir; satır içi kalemlerde yalnız çağrı satırı vardır. Ortak ilkeller: `B` sim:94, `RB` sim:98, `Cy` sim:102, `floorP` sim:107.
- Ölçü: x × y × z (dünya eksenleri), metre. Yaw'ı yaklaşık ±π/2 olan gruplarda (kanepe, kitaplık, tahta, unicorn, aplik, araba, bank, büfe üstü eşyalar, çerçeve) kalemin kendi uzunluk × yükseklik × derinlik sırasıdır ve hücrede "kendi ekseninde" yazar. Düzlemler x × z. `Ø` çap.
- Konum kaynağı. **araç**: `sandbox/asset_lab/out/props/{home,ishani}_props.json` (gitignore'lu çıktı; üretici `sandbox/asset_lab/tools/props_extract/`): `items[].pose` (`pos`, `yaw` radyan; yalnız grup tabanlı kalemlerde) ya da `items[].bboxWorld`; pose yoksa `items[].args` (aynalanmamış kalemlerde dünya koordinatı). **elle**: kurucu sayıları, dünya koordinatına çevrilmiş; İş hanı'nda ayna grubundaki (MIR) kalemler `x -> 20 - x` ile. Aralık `a..b`. Ayna grubundaki adlı kalemlerde `yaw` dünya yönüdür, geometri x'te yansıtılmıştır.
- Renk: `PAL` (sim:410) adı; hex yalnız palette olmayan satır içi renkte. `(e #hex)` emissive rengi; tasarımda yoğunluk 0'dan başlar, gece açılır.
- `plant(tip, k)`: tip 0 beyaz saksılı yuvarlak yaprak kümesi, tip 1 terakota saksılı şerit yapraklar, tip 2 gövdeli büyük yer bitkisi (sim:177-191); k ölçek. `station` katmana (`TIER`) göre değişir: ev 0 (dizüstü + 1 monitör), İş hanı 1 (1 monitör, kurucuda 2).
- Çok adetli kalemlerde (pencere, ağaç) tek tek konumlar JSON'dadır; bu tabloda aralık ve tür ayrımı verilir.

### Palet

| ad | hex | ad | hex | ad | hex |
|---|---|---|---|---|---|
| `wall` | #f1e6d2 | `cap` | #2b2a35 | `base` | #3d3a48 |
| `oakF` | #d9a877 | `carpet` | #86a3a2 | `tile` | #ece5d6 |
| `tileB` | #cfe3df | `edge` | #8b7e70 | `deskTop` | #e8cfa4 |
| `walnut` | #7a4b36 | `metal` | #3b3f4c | `alu` | #bcc2c9 |
| `chrome` | #e3e6ea | `black` | #262633 | `plasticG` | #9aa0ab |
| `plasticW` | #f2efe8 | `fabric` | #3c4a63 | `fabricB` | #d98c5f |
| `fabricW` | #e2c58f | `glass` (alfa 0,18) | #9fd3d0 | `ceramic` | #fbf8f2 |
| `stone` | #efe9dd | `cabinet` | #f4ede0 | `terracotta` | #c8744f |
| `potW` | #f6f1e7 | `soil` | #4a3426 | `rug` | #c0583f |
| `rug2` | #3f6f7a | `paper` | #fffdf6 | `laminate` | #9fc4c0 |
| `frame` | #34384a | | | | |

- `leaves[0..2]`: #4d8a57, #2f6b4f, #88b35a. `books[0..6]`: #c0583f, #3f6f7a, #e2b04a, #5d7f4a, #34384a, #9a5a8a, #efe2c8.
- Ortak malzemeler (sim:278-282, 623-631): `groundMat` #a7b38f, `walkMat` #d8ccb6, `roadMat` #6b6f78, `grassMat` #9dbb7c, `lineMat` #efe9dd (ışıksız düz renk); `lowDark` #33415e pencere camı (dokulu, geceleri `lowLit` #ffe2b8); `postMat` #fff2dc (e #ffd08a); `fLampMat` #fff2dc (e #ffc27a); `sconceMat` #f3e6cf (e #ffc88a); `carHead` #fff6e0 (e #fff0c0); `carTail` #8a1a1a (e #ff3a2a); `poolMat`, `streetGlow`, `glowMat` toplamalı glow dokusu; `fadeMat` #888888 gradyan, saydam.
- Palet sonrası kalan dokular: İş hanı komşu tuğla blokları (`brickMat`, sim:669), beyaz tahta yüzü (sim:653), WC levhası (sim:124), kurucu koltuğu kumaşı (sim:253), pencere cam ve jaluzi dokuları (`lowDark`, `lowLit`; sim:663-666).

## Ev (`home`)

Daire 12,0 × 9,6 m, arka ve ortak duvar 2,9 m, kesik duvarlar 1,05 m (home:12). Daire zemini y 0; sokak y -9,6 (üç kat aşağıda, kat 3,2 m). Tavan ve çatı yok.

### Ev: iç mekân

| kalem | adet | ölçü (m) | renk (palet adı) | kaynak | konum kaynağı |
|---|---|---|---|---|---|
| Döşeme levhası (merdiven boşluklu) | 4 kutu | toplam 12,45 × 0,30 × 10,05; boşluk 2,1 × 2,8 | #7d746a | home:17 | elle: x -0,2..12,25; z -0,2..9,85; boşluk x 9,7..11,8, z 0,2..3,0 |
| İç zemin düzlemleri | 3 | karo 4,0 × 3,4; banyo karosu 2,6 × 3,4; meşe 12,0 × 6,2 | `tile`, `tileB`, `oakF` | home:18 | elle: karo x 0..4, banyo karosu x 4..6,6 (z 0..3,4); meşe z 3,4..9,6 |
| Sahanlık ve teras zemini | 4 düzlem | 3,1 × 3,4; 2,1 × 0,4; 0,2 × 3,4; 2,1 × 0,2 | #cdc5b8 | home:19-20 | elle: x 6,6..12; z 0..3,4 |
| Arka duvar (z 0), üç pencere boşluklu | 10 kutu | 12,45 × 2,90 × 0,20 | `wall` | home:22-23 | elle: x -0,2..12,25; z -0,2..0 |
| Ortak duvar (x 0) ve duvar başlıkları | 1 duvar, 2 başlık | duvar 0,20 × 2,90 × 9,85; başlık 12,56 × 0,06 × 0,28 ve 0,28 × 0,06 × 10,16 | `wall`, `cap` | home:24-25 | elle: duvar x -0,2..0; z 0..9,85 |
| Daire pencereleri (arka duvar) | 3 | cam 1,2 × 1,3; 0,6 × 0,55; 1,0 × 1,3 (çerçeve 0,05, orta dikme, taş denizlik) | `lowDark` ×2, #dfe6e8, `frame`, `stone` | home:26-31 (`backWin`) | elle: x 1,0..2,2; 5,05..5,65; 10,2..11,2; y 1,0..2,3; 1,75..2,3; 1,2..2,5 |
| Kesik iç duvarlar | 8 parça (duvar + başlık) | kalınlık 0,12; yükseklik 1,05 (+0,03 başlık); uzunluk 1,75; 0,9; 3,75; 3,4; 3,4; 4,18; 0,3; 3,28 | `wall`, `cap` | home:33-35 (`wx`, `wz`) | elle: z 3,4 üzerinde x 4..12 (boşluk 5,75..6,45 ve 7,35..8,25); x 4 ve 6,6 üzerinde z 0..3,4; x 7,4 üzerinde z 5,3..9,48; z 5,3 üzerinde x 7,4..11,88 (boşluk 7,7..8,6) |
| Kesik dış duvarlar, cephe kaplaması, krem bant | 3 duvar, 3 kaplama, 3 bant, 1 eşik | duvar 0,12 kalın, 1,05 yüksek; kaplama 0,25 kalın (y -0,3..1,05); bant 0,05 yüksek × 0,44 derin | `wall`, #d4ad8c, #efe2c8, `stone` | home:36-41 | elle: ön z 9,48..9,6 (x 0..3,4 ve 4,6..11,88; balkon kapısı boşluğu 3,4..4,6); sağ x 11,88..12 |
| Balkon kapısı kanadı | 2 | 0,60 × 1,05 × 0,05 (cam 0,44 × 0,70); ±1,25 rad açık | `frame`, `lowDark` | home:42 | elle: menteşe (3,4; 9,5) ve (4,6; 9,5) |
| Daire giriş kapısı kanadı (`elev_panel_0`) | 1 | 0,90 × 1,05 × 0,06; 2 topuz Ø0,06 | #6e4a32, #c9a24a | home:71 | elle: menteşe (8,25; 3,4); z 3,4 duvarındaki 7,35..8,25 boşluğu |
| Mutfak tezgâhı (`kitchenRun`) | 1 | 2,87 × 1,58 × 0,64; 5 alt dolap, üst dolap yok | `cabinet`, `stone`, `chrome`, `black`, `tile`, #1d1f23 | sim:228; çağrı home:44 | araç: bbox x 0,14..3,01; z 0,1..0,74 |
| Buzdolabı (`fridge`) | 1 | 0,75 × 1,95 × 0,76 | #e9e7e1, `black`, `chrome` | sim:238; çağrı home:44 | araç: bbox x 3,05..3,8; z 0,1..0,86 |
| Evye ve musluk (`sink`) | 1 | 0,56 × 0,37 × 0,45 (y 0,8..1,17) | `chrome`, `metal` | sim:237; çağrı home:52 | araç: bbox x 1,32..1,88; z 0,15..0,6 |
| Kahve makinesi (`coffeeMachine`) | 1 | 0,34 × 0,42 × 0,40 | `black`, `chrome`, `ceramic` | sim:224; çağrı home:52 | araç: bbox x 2,38..2,72; y 0,86..1,28; z 0,17..0,57 |
| Duvar dolabı | 1 | 0,70 × 0,75 × 0,35; kapak 0,66 × 0,69; kulp 0,03 × 0,25 | `cabinet`, `chrome` | home:45 | elle: x 2,3..3,0; y 1,55..2,3; z 0,1..0,45 |
| Açık raf ve kavanozlar | 1 raf, 4 kavanoz | raf 0,80 × 0,03 × 0,28 (y 1,62); kavanoz Ø0,10 × 0,14 ve 0,18 | `walnut`, `ceramic` ×2, #c98b5a, #6f8a7a | home:46 | elle: x 0,15..0,95; z 0,1..0,38 |
| Ocak ve ocak üstü takımı | 1 ocak, 2 göz, tencere, kapak, demlik, kepçe | ocak 0,64 × 0,02 × 0,46; göz Ø0,18; tencere Ø0,24 × 0,15; demlik Ø0,15 × 0,11 | `black`, #2e3036, #c9ccd1, #f4f1ea, #b03a2e, #1f2126 | home:47-51 | elle: x 0,28..0,92; y 0,86..1,19; z 0,16..0,62 |
| Yemek masası (yuvarlak) | 1 | Ø0,90 × 0,76; ayak Ø0,10; taban Ø0,48 | `walnut`, `metal` | home:53 | elle: merkez (2,4; 2,3) |
| Ahşap sandalye (`woodChair`), mutfak | 2 | 0,42 × 0,93 × 0,43 | `walnut`, `metal` | sim:171; çağrı home:54 | araç: pose (2,4; 0; 1,62) yaw 0 ve (2,4; 0; 2,98) yaw 3,142 |
| Tabak ve fincan | 1 + 1 | tabak Ø0,20 × 0,015; fincan Ø0,08 × 0,09 | `ceramic`, #c98b5a | home:55 | elle: (2,25; 0,77; 2,2) ve (2,62; 0,805; 2,35) |
| Klozet (`toilet`) | 1 | 0,40 × 0,77 × 0,59 | `ceramic`, `plasticW` | sim:243; çağrı home:57 | araç: bbox x 4,35..4,75; z 0,165..0,75 |
| Lavabo dolabı, tezgâh, lavabo | 1 + 1 + 1 | dolap 0,70 × 0,80 × 0,45; tezgâh 0,74 × 0,04 × 0,50; lavabo 0,46 × 0,06 × 0,30 | `cabinet`, `stone`, `ceramic` | home:58 | elle: x 4,98..5,72; z 0,03..0,53 |
| Banyo aynası | 1 | 0,60 × 0,55 × 0,02 (y 1,1..1,65) | #cfd8dc | home:59 | elle: x 5,05..5,65; z 0,01..0,03 |
| Duş teknesi, cam perde, ray | 1 + 1 + 1 | tekne 0,72 × 0,06 × 0,90; cam 0,02 × 1,65 × 0,89; ray 0,76 × 0,02 × 0,02 (y 2,0) | `ceramic`, #e6ecee, `chrome` | home:60 | elle: x 5,78..6,54; z 0,05..0,95 |
| Çamaşır makinesi | 1 | 0,58 × 0,82 × 0,56; kapak Ø0,34 | #f4f3ef, #2e3036 | home:61 | elle: x 5,95..6,53; z 1,72..2,28 |
| Bitki (`plant`), sahanlık | 1 | tip 1, k 0,8: 0,26 × 0,87 × 0,26 | `terracotta`, `soil`, `leaves` | sim:177; çağrı home:65 | araç: bbox x 6,97..7,23; z 0,32..0,58 |
| Gri duvar levhası | 1 | 0,50 × 0,60 × 0,12 (y 1,3..1,9) | #9aa0a6 | home:65 | elle: x 8,4..8,9; z 0..0,12 |
| Merdiven (aşağı) | 10 basamak | genişlik 2,10; basamak 0,28 derin × 0,18 yüksek; iniş 1,8, yatay 2,8; basamaklar y -3,3'ten dolu blok | #cdc5b8 ve `stone` dönüşümlü | home:66 | elle: x 9,7..11,8; z 0,2..3,0 |
| Merdiven yan ve arka duvarları | 3 | 0,10 × 3,30 × 2,80 (iki yan); 2,30 × 3,30 × 0,40 (arka) | #1b1c20 | home:67 | elle: x 9,6..11,9; z -0,2..3,0 |
| Küpeşte ve baluster | 1 + 17 | küpeşte 0,10 × 0,05 × 2,88 (y 0,95); baluster 0,03 × 0,95 × 0,024, aralık 0,16 | `walnut`, #1f2126 | home:68-69 | elle: x 9,62..9,72; z 0,2..3,08 |
| Antre konsolu | 1 | 1,30 × 0,90 × 0,37; taş üst 1,26 × 0,03 × 0,39 | `walnut`, `stone` | home:73 | elle: x 9,0..10,3; z 3,48..3,87 |
| Portmanto ve çanta | 1 + 1 | direk Ø0,05 × 1,75; taban Ø0,36 × 0,02; çanta 0,30 × 0,70 × 0,12 | `metal`, #6f5a4a | home:74 | elle: (11,5; 3,85) |
| Yatak | 1 | çerçeve 2,20 × 0,32 × 1,60; baş ucu 0,14 × 1,00 × 1,70; şilte 2,10 × 0,24 × 1,52; yorgan 1,40 × 0,08 × 1,58; 2 yastık 0,42 × 0,12 × 0,58 | `walnut`, #f2efe9, #7a93b3, #f7f5f0 | home:77-79 | elle: x 7,44..9,7 (baş ucu x 7,44'te); z 6,25..7,95 |
| Komodin ve abajur | 2 + 2 | komodin 0,45 × 0,50 × 0,45; abajur: taban Ø0,10, sap 0,30, kep Ø0,20 × 0,14 | `walnut`, `metal`, #f1e6d0 | home:80 | elle: x 7,5..7,95; z 5,75..6,2 ve 8,0..8,45 |
| Gardrop | 1 | 1,25 × 2,10 × 0,60; derz 0,01 × 2,0; 2 kulp 0,02 × 0,25 | #e9e4da, #9a948a, `chrome` | home:81 | elle: x 10,6..11,85; z 5,42..6,02 |
| Halılar | 4 | çalışma 1,90 × 1,87; salon 2,50 × 2,80; yatak odası 1,40 × 2,10; antre 2,60 × 0,80 | `rug` (çalışma), `rug2` (diğer üçü) | home:75, 82, 85, 97 | elle: çalışma x 0,35..2,25, z 7,55..9,42; salon x 4,7..7,2, z 6,0..8,8; yatak odası x 9,9..11,3, z 6,5..8,6; antre x 8,7..11,3, z 4,0..4,8 |
| Paspaslar | 2 | sahanlık 0,70 × 0,35; banyo 0,80 × 0,50 | #6b4e3a, #9ec3c9 | home:70, 62 | elle: sahanlık x 7,45..8,15, z 2,95..3,3; banyo x 4,95..5,75, z 0,6..1,1 |
| Çalışma istasyonu (`station`, katman 0) | 1 | 1,43 × 1,30 × 1,37; masa 1,40 × 0,035 × 0,63 (üst y 0,735); dizüstü, 1 monitör (0,56), klavye, fare, kupa, kâğıt, lamba, sandalye (40 mesh) | `deskTop`, `metal`, `black`, `chrome`, `alu`, `plasticG`, `paper`; sandalye #3f6f7a (`books[1]` ile ortak malzeme); ekran #0d1016 (e #9cc6ff); lamba #fff2dc (e #ffb25e) | sim:251 (+ `officeChair` sim:158, `monitorUnit` sim:142); çağrı home:84 | araç: pose (1,2; 0; 8,3) yaw 0 |
| Yapışkan not | 12 | 0,009 × 0,085 × 0,085 | #f2d25c ×5, #ef8fa0 ×3, #8cc6e8 ×2, #a8d88a ×2 | home:86-87 | elle: x 0,005; y 1,28..1,79; z 8,06..8,99 (`rng(5)` ile kayık) |
| Duvar beyaz tahtası | 1 çerçeve, 1 yüz, 9 çizgi, 1 tepsi | çerçeve 0,045 × 0,86 × 1,26; yüz 0,01 × 0,80 × 1,20; tepsi 0,115 × 0,03 × 0,90 | #b9bdc2, #f7f7f4, #2f5f8a ×8, #c0392b, `metal` | home:88-92 | elle: x 0,005..0,06; y 1,12..1,98; z 6,32..7,58 |
| Kitaplık (`bookshelf`) | 1 (127 mesh) | kendi ekseninde 1,80 × 2,00 × 0,34 | `walnut`, `books` | sim:201; çağrı home:93 | araç: bbox x 0,05..0,39; z 3,85..5,65 |
| Kanepe (`sofaR`) | 1 | kendi ekseninde 2,30 × 0,75 × 0,90 | `fabricB` | sim:131; çağrı home:94 | araç: pose (6,92; 0; 7,4) yaw -1,571 |
| Sehpa, fincan, defter | 1 + 1 + 1 | sehpa 0,70 × 0,44 × 1,20 (üst 0,04 kalın; 4 ayak 0,04); fincan Ø0,09 × 0,09; defter 0,30 × 0,03 × 0,35 | `walnut`, `ceramic`, #3f5a6e | home:95-96 | elle: x 5,2..5,9; z 6,8..8,0 |
| Koltuk (`armchair`) | 1 | 0,73 × 0,84 × 0,74 | `fabricW`, `walnut` | sim:150; çağrı home:98 | araç: pose (3,2; 0; 7,3) yaw 1,571 |
| Lambader (`floorLamp`) | 1 | 0,44 × 1,81 × 0,44 | `metal`, `fLampMat` | sim:157; çağrı home:98 | araç: bbox x 6,73..7,17; z 5,73..6,17 |
| Bitki (`plant`), salon | 2 | tip 1, k 0,7: 0,22 × 0,79 × 0,22; tip 0, k 0,9: 0,69 × 1,08 × 0,72 | `terracotta` / `potW`, `soil`, `leaves` | sim:177; çağrı home:99 | araç: bbox x 2,64..2,86, z 9,14..9,36 ve x 6,54..7,23, z 8,7..9,42 |
| Işık havuzu (`decal`, gece) | 1 | 3,2 × 3,0 düzlem (y 0,02) | `poolMat` | sim:630; çağrı home:100 | araç: bbox x -0,4..2,8; z 7,05..10,05 |
| Balkon levhası ve karo zemin | 1 + 1 | 2,80 × 0,18 × 1,10 | #efe2c8, `tile` | home:106 | elle: x 2,6..5,4; z 9,85..10,95 |
| Balkon korkuluğu (daire balkonu) | 1 takım | ön üst küpeşte 2,80 × 0,05 × 0,06; ön alt çıta 2,80 × 0,04 × 0,06; 2 yan küpeşte 0,06 × 0,05 × 1,11; 19 ön baluster 0,022 × 0,85 × 0,04; 14 yan baluster 0,022 × 0,85 × 0,022 | #1f2126 | home:102-105 (`rail`); çağrı home:106 | elle: x 2,6..5,4; y 0,06..1,0; z 9,85..10,96 |
| Bistro masası | 1 | Ø0,40 × 0,71; ayak Ø0,03 | `metal` | home:107 | elle: (4,35; 10,4) |
| Ahşap sandalye (`woodChair`), balkon | 1 | 0,43 × 0,93 × 0,42 | `walnut`, `metal` | sim:171; çağrı home:107 | araç: pose (4,95; 0; 10,4) yaw -1,571 |
| Bitki (`plant`), balkon | 2 | tip 1, k 0,55: 0,18 × 0,52 × 0,18; tip 0, k 0,5: 0,34 × 0,61 × 0,35 | `terracotta` / `potW`, `soil`, `leaves` | sim:177; çağrı home:108 | araç: bbox x 2,76..2,94, z 10,61..10,79 ve x 3,01..3,34, z 10,5..10,85 |

### Ev: bina kabuğu (alt üç kat)

| kalem | adet | ölçü (m) | renk (palet adı) | kaynak | konum kaynağı |
|---|---|---|---|---|---|
| Alt cephe kaplaması (ön, yan) | 2 | ön 12,45 × 9,30 × 0,25; yan 0,25 × 9,30 × 10,05 (y -9,6..-0,3) | #d4ad8c | home:109 | elle: ön z 9,6..9,85; yan x 12..12,25 |
| Kat bantları ve saçak bandı | 6 + 2 | kat bandı 12,50 × 0,16 × 0,05 ve 0,05 × 0,16 × 10,10 (üç kat); saçak 12,80 × 0,30 × 0,20 ve 0,20 × 0,30 × 10,25 | #efe2c8 | home:116-117 | elle: bant y -0,46..-0,3, -3,66..-3,5, -6,86..-6,7; saçak y -7,0..-6,7 |
| Pencere birimi (`winUnit`), alt cephe | 23 (10 ön, 12 yan, 1 vitrin yanı) | 19 × (1,44 × 1,89 × 0,17); 2 × (1,24 × 1,89 × 0,17); 2 × (1,44 × 2,59 × 0,17) | `black`, `lowDark`, `frame`, #efe2c8 | sim:675; çağrı home:113-115, 122 | araç: items (bölüm `home:balcony_facade_windows`), bbox |
| Alt kat balkonları | 2 | levha 2,80 × 0,18 × 1,10; korkuluk takımı (daire balkonuyla aynı); 1 bitki (tip 1, k 0,5: 0,16 × 0,57 × 0,17) | #efe2c8, #1f2126, `terracotta`, `soil`, `leaves` | home:102-105, 114 | elle: levha y -6,58..-6,4 ve -3,38..-3,2 (x 2,6..5,4; z 9,85..10,95); bitki araç bbox x 4,92..5,08, z 10,51..10,68 |
| Dükkân vitrini | 1 cam, 4 dikme, 1 alt çıta | cam 5,40 × 2,15 × 0,05; dikme 0,08 × 2,25 × 0,08; alt çıta 5,48 × 0,08 × 0,09 | #2c3446, #1f2126 | home:119 | elle: x 6,0..11,4; y -9,25..-7,1; z 9,85..9,9 |
| Dükkân tentesi | 1 | 5,80 × 0,06 × 1,10; eğim 0,38 rad | #3f6f7a | home:120 | elle: x 5,8..11,6; y -6,98..-6,52; z 9,88..10,92 |
| Sokak kapısı, lento, basamak | 1 + 1 + 1 | kapı 1,20 × 2,23 × 0,07 (üst cam 1,20 × 0,40); lento 1,36 × 0,10 × 0,09; basamak 1,60 × 0,12 × 0,50 | #6e4a32, `lowDark`, #efe2c8, `stone` | home:121-122 | elle: x 0,9..2,1 (basamak 0,7..2,3); y -9,48..-6,75 |

### Ev: sokak bağlamı

| kalem | adet | ölçü (m) | renk (palet adı) | kaynak | konum kaynağı |
|---|---|---|---|---|---|
| Zemin düzlemi | 1 | 152 × 149,6 (y -9,6) | `groundMat` | home:124 | elle: x -70..82; z -70..79,6 |
| Kaldırımlar | 4 | iç 55 × 0,12 × 2,75 ve 2,75 × 0,12 × 52,6; dış 92 × 0,12 × 2,5 ve 2,5 × 0,12 × 58,6 | `walkMat` | home:125, 129 | elle: iç z 9,85..12,6 ve x 12,25..15; dış z 18,6..21,1 ve x 21..23,5 |
| Yollar | 2 | 92 × 0,04 × 6,0 ve 6,0 × 0,04 × 52,6 | `roadMat` | home:126 | elle: ön z 12,6..18,6; yan x 15..21 |
| Şerit çizgileri | 22 + 13 | 1,4 × 0,01 × 0,2 ve 0,2 × 0,01 × 1,4 | `lineMat` | home:127-128 | elle: ön z 15,5..15,7 (x -24..40,4); yan x 17,9..18,1 (z -24..13,4) |
| Komşu bloklar (4 kat) | 5 | 11,80 × 12,80 × 10,05; 12,00 × 12,80 × 10,05; 12,00 × 12,80 × 11,50; 7,00 × 12,80 × 11,50; 7,25 × 12,80 × 11,50; çatı altı korniş 0,22 | #c9b49a, #b8c0b0, #d9c3a3, #c7a58a, #d6c7ae; korniş #efe2c8 | home:131-140 (`bld`) | elle: x -24..-0,2 (iki bitişik), z -0,2..9,85; x -14..12,25 (üç bitişik), z -16..-4,5; y -9,6..3,2; araç: sayaç `neighbour_building` 5 |
| Hip çatı (`hipRoof`) ve baca | 5 + 5 | çatı 12,4 × 1,8 × 10,65; 12,6 × 1,8 × 10,65; 12,6 × 1,8 × 12,1; 7,6 × 1,8 × 12,1; 7,85 × 1,8 × 12,1; baca 0,6 × 2,5 × 0,6 | #c0674a ×2, #a24b36 ×2, #b5553a; baca bina rengi | home:3-7; çağrı home:133 | araç: bbox (çatı, y 3,2..5,0); baca elle (x0 + 0,7 × genişlik, z orta) |
| Pencere birimi (`winUnit`), komşu | 88 (72 ön, 16 yan) | 1,44 × 1,84 × 0,17 | `black`, `lowDark`, `frame`, #efe2c8 | sim:675; çağrı home:136-137 | araç: items (bölüm `home:neighbour_blocks`), bbox |
| Karşı dükkânlar (3,4 m) | 6 | 12,0 × 3,4 × 5,5; 10,0 × 3,4 × 5,5; 15,2 × 3,4 × 5,5; 5,5 × 3,4 × 14,0; 5,5 × 3,4 × 12,0; 5,5 × 3,4 × 14,8; korniş 0,2 | #d9a896 ×2, #b9c4a0, #d8b77a, #cdbfa9, #b8a58e; korniş #efe2c8 | home:142-149 (`shop`) | elle: ön sıra z 21,1..26,6 (x -16..21,2); sağ sıra x 23,5..29 (z -22..18,8); y -9,6..-6,2; araç: sayaç `neighbour_shop` 6 |
| Dükkân çatı donanımı | 6 klima, 6 bitki, 6 tente, 24 parapet | klima 1,2 × 1,0 × 1,2; parapet 0,2 kalın × 0,45; tente 0,06 × 1,2 sarkma × 9,2..14,4; bitki tip 1, k 0,9 | klima #9aa0a6; parapet #efe2c8; tente #3f6f7a, #c0583f ×2, #d9a441 ×2, #6f8a7a; bitki `terracotta`, `soil`, `leaves` | home:144-147; bitki sim:177 | elle: klima, parapet, tente; araç: bitki items (bölüm `home:neighbour_blocks`) |
| Ağaç (`tree`) | 7 (4 serbest, 3 çukurlu) | serbest (k 1,0-1,1) 2,45-2,77 × 3,35-3,69 × 2,33-2,99; çukurlu (k 0,9) 2,12-2,32 × 3,02 × 2,19-2,42 | #6b4e3a, `leaves`, #9bc26a; çukur #3a3026, `metal` | sim:632; çağrı home:150-151 | araç: items `args` (x; y; z; k; çukur), dünya |
| Sokak lambası (`lampPost`) | 3 | direk Ø0,10 × 3,20; kafa 0,30 × 0,18 × 0,30 (toplam 3,34); zemin ışığı 4,5 × 4,5 | `metal`, `postMat`, `streetGlow` | sim:643; çağrı home:152 | araç: items `args` (2; -9,48; 12,2), (14,6; -9,48; -3), (-14; -9,48; 12,2) |
| Araba (`car`) | 3 (1 taksi) | kendi ekseninde 2,18 × 0,83 × 1,00 (taksi 0,92 yüksek) | gövde #c0583f, #6f9a7a, #f2c230 (taksi); cam #3a4a66; tampon #1f2229; lastik `black`; jant `alu`; `carHead`, `carTail`; taksi tepe lambası #fff4c8 (e #ffe08a) | sim:683; çağrı home:153 | araç: pose (-6; -9,56; 13,8) yaw 0; (3,5; -9,56; 13,8) yaw 0; (16,2; -9,56; -6) yaw 1,571 |

## İş hanı (`ishani`)

Ofis 20 × 15 m, arka ve sol duvar 2,8 m, ön ve sağ dış duvar 0,45 m, iç duvarlar 1,05 / 2,4 m, cam bölme 2,4 m (sim:696). Ofis zemini y 0; sokak y -6,6 (iki kat aşağıda, kat 3,3 m). Tavan ve çatı yok. Zemin, bölmeler, toplantı odası, mutfak, WC, açık ofis ve kurucu köşesi `MIR` grubunda kurulur (sim:695; ayna içi bölümler sim:700-703 ve 718-782); asansör çekirdeği, dış duvarlar, aplikler, kabuk ve sokak ayna dışıdır.

### İş hanı: iç mekân

| kalem | adet | ölçü (m) | renk (palet adı) | kaynak | konum kaynağı |
|---|---|---|---|---|---|
| Taban levhası | 1 | 20,5 × 0,30 × 15,5 | `edge` | sim:699 | elle: x -0,25..20,25; z -0,25..15,25 (ayna dışı) |
| Zemin düzlemleri | 6 | halı 14,6 × 6,8; meşe 5,4 × 6,6; meşe koridor 20 × 2,2; meşe toplantı 8 × 6; karo 7 × 6; banyo karosu 5 × 6 | `carpet`, `oakF` ×3, `tile`, `tileB` | sim:701-703 | elle (MIR): halı x 0..14,6, z 8,2..15; meşe x 14,6..20, z 8,4..15; koridor z 6..8,2; toplantı x 12..20, z 0..6; karo x 5..12; banyo karosu x 0..5 (z 0..6) |
| Dış duvarlar | 4 (duvar + başlık + süpürgelik) | arka ve ön 20,18 × h × 0,18; sol ve sağ 0,18 × h × 15; h: arka ve sol 2,8, ön ve sağ 0,45; başlık +0,03; süpürgelik 0,08 yüksek × 0,204 kalın | `wall`, `cap`, `base` | sim:706-707 (`wallX`, `wallZ`); çağrı sim:710-711 | elle: arka z 0, sol x 0, ön z 15, sağ x 20 (ayna dışı) |
| Opak iç duvarlar | 5 parça | kalınlık 0,18; h 1,05: uzunluk 1,9 ve 3,9; h 2,4: uzunluk 1,9; 1,9; 6 | `wall`, `cap`, `base` | sim:706-707; çağrı sim:721-722 | elle (MIR): z 6 üzerinde x 5..12 (boşluk 8,9..10,1) ve x 0..5 (boşluk 1,9..3,1); x 5 üzerinde z 0..6 |
| Cam bölmeler | 6 koşu (toplam cam 23,8 m) | yükseklik 2,4; cam 2,35 × 0,024; çerçeve 0,05-0,06; çıta aralığı en çok 1,2 | `glass`, `frame` | sim:708-709 (`glassX`, `glassZ`); çağrı sim:719-720 | elle (MIR): toplantı z 6 üzerinde x 12..20 (boşluk 15,4..16,6), x 12 üzerinde z 0..6; kurucu z 8,4 üzerinde x 14,6..20 (boşluk 15,1..16,1), x 14,6 üzerinde z 8,4..15 |
| Cam kapı (`glassDoor`) | 2 | kanat 0,95 × 2,35 × 0,05 (cam 0,95 × 2,25 × 0,024); 0,9 ve 1,0 rad açık | `glass`, `frame`, `chrome` | sim:661; çağrı sim:719-720 | araç: pose (15,4; 0; 6) yaw -2,242 ve (16,1; 0; 8,4) yaw 1 (ikisi aynalı) |
| WC kapısı (ahşap) | 1 | 1,15 × 2,2 × 0,06 (90° açık); kulp 0,05 × 0,10 × 0,14 | `walnut`, `chrome` | sim:723 | elle (MIR): menteşe (1,95; 5,88); bbox x 1,88..2,02, z 4,73..5,88 |
| WC levhası (`wcSign`) | 1 | 0,52 × 0,52 × 0,02 | #1b2b40; yüz dokulu (e #ffffff, yoğunluk 0,3) | sim:123; çağrı sim:724 | araç: pose (4; 1,95; 6,1) yaw 0 |
| Asansör çekirdeği | 1 kutu, 1 başlık, 1 girinti, 3 çerçeve, 2 kapı, 1 gösterge | kutu 1,26 × 2,80 × 2,16; başlık 1,28 × 0,04 × 2,20; girinti 0,01 × 2,24 × 1,30; çerçeve 0,08 × 2,37 × 1,54; kapı kanadı 0,02 × 2,24 × 0,65; gösterge 0,08 × 0,10 × 0,36 | #5a6275, `cap`, `black`, `frame`, `alu`, #9fd3ff (e #9fd3ff) | sim:712-716 | elle (ayna dışı): x 0,09..1,43; z 6,0..8,2; kapı kanatları ayrı düğüm `elev_panel_0/1` |
| Asansör önü halısı | 1 | 1,8 × 1,7 | `rug2` | sim:717 | elle: x 1,4..3,2; z 6,25..7,95 |
| Bitki (`plant`), asansör önü | 1 | tip 1, k 0,8: 0,26 × 0,90 × 0,26 | `terracotta`, `soil`, `leaves` | sim:177; çağrı sim:717 | araç: bbox x 1,62..1,88; z 8,42..8,68 |
| Toplantı masası | 1 üst, 2 ayak | üst 4,20 × 0,05 × 1,30 (y 0,715..0,765); ayak 0,08 × 0,72 × 0,80 | `walnut`, `metal` | sim:726 | elle (MIR): x 13,9..18,1; z 2,35..3,65 |
| Ofis sandalyesi (`officeChair`), toplantı | 7 | 0,57 × 1,08 × 0,59 | `fabricW`, `metal`, `black`, `chrome` | sim:158; çağrı sim:731 | araç: pose (17,3; 0; 1,7), (16; 0; 1,7), (14,7; 0; 1,7) yaw 0; (17,3; 0; 4,3), (16; 0; 4,3), (14,7; 0; 4,3) yaw -3,142; (13,4; 0; 3) yaw 1,571 |
| Kredenza | 1 | 3,20 × 0,50 × 0,40 | `walnut` | sim:732 | elle (MIR): x 14,4..17,6; z 0,1..0,5 |
| Bitki (`plant`), toplantı odası | 2 | tip 2, k 1: 0,95 × 2,06 × 1,05; tip 1, k 0,9: 0,29 × 1,03 × 0,29 | `potW`, #6b5140, `soil`, `leaves` / `terracotta` | sim:177; çağrı sim:732 | araç: bbox x 12,14..13,09, z 0,13..1,18 ve x 19,16..19,45, z 0,56..0,85 |
| Mutfak tezgâhı (`kitchenRun`) | 1 | 4,62 × 1,58 × 0,64; 8 alt dolap, üst dolap yok | `cabinet`, `stone`, `chrome`, `black`, `tile`, #1d1f23 | sim:228; çağrı sim:734 | araç: bbox x 7,19..11,81; z 0,1..0,74 |
| Duvar dolabı | 4 | 0,588 × 0,70 × 0,34 (y 1,6..2,3); kulp 0,16 × 0,015 | `cabinet`, `chrome` | sim:735 | elle (MIR): x 9,4..11,8; z 0,1..0,44 |
| Kahve makinesi (`coffeeMachine`) | 1 | 0,34 × 0,42 × 0,40 | `black`, `chrome`, `ceramic` | sim:224; çağrı sim:736 | araç: bbox x 10,63..10,97; y 0,89..1,31; z 0,2..0,6 |
| Evye ve musluk (`sink`) | 1 | 0,56 × 0,37 × 0,45 | `chrome`, `metal` | sim:237; çağrı sim:736 | araç: bbox x 7,82..8,38; z 0,2..0,65 |
| Fincan | 3 | Ø0,076 × 0,09 | `ceramic` | sim:737 | elle (MIR): x 10,01; 10,13; 10,25; y 0,89; z 0,5 |
| Buzdolabı (`fridge`) | 1 | 0,90 × 1,95 × 0,81 | #e9e7e1, `black`, `chrome` | sim:238; çağrı sim:738 | araç: bbox x 5,95..6,85; z 0,1..0,91 |
| Kafe masası (yuvarlak) | 1 | Ø1,10 × 0,76; ayak Ø0,10; taban Ø0,60 | `deskTop`, `metal` | sim:739 | elle (MIR): merkez (6,4; 3,6) |
| Kare yemek masası | 1 | 0,90 × 0,76 × 0,72; 4 ayak Ø0,04 | `deskTop`, `metal` | sim:743 | elle (MIR): x 10,35..11,25; z 4,04..4,76 |
| Ahşap sandalye (`woodChair`), mutfak | 4 | 0,42 × 0,93 × 0,43 | `walnut`, `metal` | sim:171; çağrı sim:744 | araç: pose (7,15; 0; 3,6) yaw -1,571; (5,65; 0; 3,6) yaw 1,571; (10,8; 0; 3,72) yaw 0; (10,8; 0; 5,08) yaw -3,142 |
| Bitki (`plant`), mutfak | 1 | tip 0, k 0,8: 0,55 × 0,92 × 0,60 | `potW`, `soil`, `leaves` | sim:177; çağrı sim:744 | araç: bbox x 5,34..5,9; z 5,14..5,74 |
| WC bölmeleri | 1 + 3 | 0,08 × 1,48 × 2,6 (kabin arası); 0,7; 1,4; 0,7 × 1,48 × 0,08 (y 0,12..1,6) | `laminate` | sim:746-747 | elle (MIR): kabin arası x 2,46..2,54, z 0..2,6; ön z 2,56..2,64, x 0..0,7, 1,8..3,2, 4,3..5 |
| Klozet (`toilet`) | 2 | 0,40 × 0,77 × 0,59 | `ceramic`, `plasticW` | sim:243; çağrı sim:748 | araç: bbox x 1,05..1,45 ve 3,55..3,95; z 0,115..0,7 |
| Lavabo dolabı ve lavabo | 1 + 1 | dolap 0,60 × 0,85 × 1,00; lavabo 0,45 × 0,05 × 0,50 (y 0,845..0,895) | `cabinet`, `ceramic` | sim:749 | elle (MIR): x 0,15..0,75; z 3,4..4,4 |
| Çalışma istasyonu (`station`, katman 1), personel | 10 | 1,40 × 1,30 × 1,37; masa 1,40 × 0,035 × 0,63 (üst y 0,735); 1 monitör (0,62), klavye, fare, lamba, sandalye; kupa %70, kâğıt %60 | `deskTop`, `fabric` (sandalye), `metal`, `black`, `chrome`, `plasticG`, `paper`, `ceramic` / #3f5a6e (kupa); ekran #0d1016 (e #9cc6ff); lamba #fff2dc (e #ffb25e) | sim:251 (+ `officeChair` sim:158, `monitorUnit` sim:142); çağrı sim:761 | araç: pose yaw 0: (12,8; 9,9), (11,4; 9,9), (8,2; 9,9), (6,8; 9,9), (3,6; 9,9), (2,2; 9,9); yaw -3,142: (12,8; 12,1), (11,4; 12,1), (8,2; 12,1), (6,8; 12,1) |
| Alçak bölme ekranı | 3 | 2,60 × 0,38 × 0,02 (y 0,74..1,12) | #c9cfd3 | sim:763 | elle (MIR): z 11,0; x 10,8..13,4, 6,2..8,8, 1,6..4,2 |
| Bitki (`plant`), açık ofis | 2 | tip 2, k 1: 0,89 × 2,11 × 0,91; tip 0, k 1,1: 0,80 × 1,29 × 0,88 | `potW`, #6b5140, `soil`, `leaves` | sim:177; çağrı sim:765 | araç: bbox x 3,47..4,36, z 13,37..14,28 ve x 0,27..1,07, z 13,85..14,73 |
| Kurucu istasyonu (`station`, büyük) | 1 | 2,00 × 1,30 × 1,57; masa 2,00 × 0,035 × 0,83; 2 monitör (0,6), koyu deri sandalye, defter 0,25 × 0,03 × 0,33, masa üstü bitki (k 0,4) (54 mesh) | `walnut`, #2a211b (dokulu), #5b2f26, `terracotta`, `soil`, `leaves`, `metal`, `black`, `chrome`, `plasticG`, `paper`, kupa #3f5a6e; ekran #0d1016 (e #9cc6ff); lamba #fff2dc (e #ffb25e) | sim:251; çağrı sim:769 | araç: pose (17,4; 0; 10,1) yaw 0 |
| Ahşap sandalye (`woodChair`), ziyaretçi | 2 | 0,42 × 0,93 × 0,43 | `walnut`, `metal` | sim:171; çağrı sim:770 | araç: pose (18,1; 0; 12,4) ve (16,7; 0; 12,4) yaw -3,142 |
| Alçak büfe (`bookshelf`) | 1 (87 mesh) | kendi ekseninde 3,00 × 0,85 × 0,40 | `walnut`, `books` | sim:201; çağrı sim:771 | araç: bbox x 19,45..19,85; z 9,2..12,2 |
| Büfe üstü kitaplar | 6 dikili + 1 yatık | kendi ekseninde dikili 0,06 × 0,30-0,38 × 0,30; yatık 0,30 × 0,28 × 0,28 | `books[0..3]` | sim:773-774 | elle (MIR): x 19,5..19,8; z 11,25..12,1; y 0,85'ten |
| Bitki (`plant`), büfe üstü | 1 | tip 1, k 0,5: 0,18 × 0,57 × 0,16 | `terracotta`, `soil`, `leaves` | sim:177; çağrı sim:774 | araç: bbox x 19,57..19,75; y 0,85..1,42; z 10,87..11,03 |
| Unicorn figürü (`unicorn`) | 1 | kendi ekseninde 0,24 × 0,24 × 0,07 | #fbf8f2, #f4c430, #e68ab8 | sim:644; çağrı sim:774 | araç: pose (19,65; 0,85; 10,45) yaw -1,571 |
| Altın kupa | 1 | Ø0,18 × 0,32 | #c9a15a | sim:775 | elle (MIR): (19,65; 0,85; 10,1) |
| Eğik çerçeve | 1 | kendi ekseninde 0,42 × 0,52 × 0,03 (eğim -0,18 rad); kâğıt 0,34 × 0,42; 5 çizgi; ayak 0,04 × 0,16 × 0,03 | `walnut`, `paper`, `metal` ×4, #c0583f | sim:776-778 | elle (MIR): x 19,64..19,78; y 0,85..1,36; z 9,44..9,86 |
| Beyaz tahta (`whiteboard`, ayaklı) | 1 | kendi ekseninde 1,44 × 1,92 × 0,60; tahta 1,40 × 0,90 × 0,03 | `alu`; yüz #ffffff × doku (zemin #fbfaf6, çizgiler #3f6f7a, #c0583f, #34384a) | sim:651; çağrı sim:779 | araç: pose (15,15; 0; 13,3) yaw 1,571 |
| Bitki (`plant`), kurucu köşesi | 1 | tip 2, k 1,1: 1,15 × 2,26 × 0,98 | `potW`, #6b5140, `soil`, `leaves` | sim:177; çağrı sim:780 | araç: bbox x 14,65..15,8; z 14,04..15,02 |
| Lambader (satır içi) | 1 | Ø0,44 × 1,81 (taban Ø0,28, direk Ø0,04 × 1,6) | `metal`, `fLampMat` | sim:781 | elle (MIR): merkez (19,45; 8,95) |
| Kurucu halısı | 1 | 4,4 × 5,7 | `rug` | sim:767 | elle (MIR): x 15,1..19,5; z 8,9..14,6 |
| Işık havuzu (`decal`, gece) | 1 | 5,6 × 7,2 düzlem (y 0,03) | `poolMat` | sim:630; çağrı sim:782 | araç: bbox x 14,5..20,1; z 7,8..15 |
| Duvar apliği (`sconce`) | 7 | kendi ekseninde gövde 0,24 × 0,14 × 0,08 + braket; ışık düzlemi 1,7 × 2,3 (varsayılan gizli) | `sconceMat`, `metal`, `glowMat` | sim:283; çağrı sim:850 | araç: pose (12,5; 2,5; 0,1), (16; 2,5; 0,1), (19,5; 2,5; 0,1), (6; 2,3; 0,1) yaw 0; (0,1; 2,2; 8,9), (0,1; 2,2; 11,8), (0,1; 2,2; 14,3) yaw 1,571 |

### İş hanı: bina kabuğu (alt iki kat)

| kalem | adet | ölçü (m) | renk (palet adı) | kaynak | konum kaynağı |
|---|---|---|---|---|---|
| Alt cephe kaplaması (ön, yan) | 2 | ön 20,45 × 6,30 × 0,25; yan 0,25 × 6,30 × 15,45 (y -6,6..-0,3) | #c98f6d | sim:791-792 | elle: ön z 15..15,25 (x -0,2..20,25); yan x 20..20,25 (z -0,2..15,25) |
| Kat bantları | 4 | 20,5 × 0,16 × 0,05 ve 0,05 × 0,16 × 15,5 (iki seviye) | #efe2c8 | sim:793 | elle: y -3,46..-3,3 ve -0,46..-0,3 |
| Pencere birimi (`winUnit`), kabuk | 26 (14 ön, 12 yan) | 1,84 × 1,79 × 0,17 (cam 1,6 × 1,6) | `black`, `lowDark`, `frame`, #efe2c8 | sim:675; çağrı sim:798-799 | araç: items (bölüm `A2:building_shell`), bbox; alt kat önünde giriş yüzünden x 3,2..4,8 ve 5,6..7,2 birimleri atlanır |
| Cephe solma düzlemleri | 2 | ön 20,6 × 6,35 (z 15,4); yan 15,6 × 6,35 (x 20,4) | `fadeMat` | sim:801-802 | elle: ön x -0,3..20,3; yan z -0,3..15,3; y -6,625..-0,275 |
| Giriş vitrini ve cam paneli | 1 + 1 | vitrin 3,20 × 2,60 × 0,05; cam panel 2,80 × 2,40 | #2c3446, `lowDark` | sim:836 | elle: x 2,4..5,6 (panel 2,6..5,4); y -6,6..-4,0; z 15,25..15,32 |
| Giriş saçak bandı | 1 | 4,00 × 0,16 × 1,55 | #efe2c8 | sim:836 | elle: x 2..6; y -3,9..-3,74; z 15,25..16,8 |
| Bitki (`plant`), giriş | 2 | tip 0, k 1,1: 0,92 × 1,28 × 0,71 ve 0,67 × 1,15 × 0,86 | `potW`, `soil`, `leaves` | sim:177; çağrı sim:837 | araç: bbox x 1,15..2,07, z 15,46..16,18 ve x 6,03..6,71, z 15,32..16,18 |

### İş hanı: sokak bağlamı

| kalem | adet | ölçü (m) | renk (palet adı) | kaynak | konum kaynağı |
|---|---|---|---|---|---|
| Zemin düzlemi | 1 | 190 × 235 (y -6,6) | `groundMat` | sim:807 | elle: x -80..110; z -80..155 |
| Kaldırımlar | 3 | 103,2 × 0,12 × 2,95; 2,95 × 0,12 × 98,2; 2,5 × 0,12 × 104,5 | `walkMat` | sim:808, 820 | elle: z 15,25..18,2 (x -80..23,2); x 20,25..23,2 (z -80..18,2); x 29,5..32 (z -80..24,5) |
| Yollar | 2 | 190 × 0,04 × 6,3 ve 6,3 × 0,04 × 104,5 | `roadMat` | sim:809 | elle: ön z 18,2..24,5; yan x 23,2..29,5 |
| Şerit ve yaya geçidi çizgileri | 24 + 13 + 6 | şerit 1,4 × 0,01 × 0,2 ve 0,2 × 0,01 × 1,4; yaya geçidi 0,5 × 0,01 × 5,9 | `lineMat` | sim:810-812 | elle: ön z 21,25..21,45 (x -20..50,4); yan x 26,25..26,45 (z -20..17,4); geçit x 23,4..28,9, z 18,4..24,3 |
| Çim, kenar bandı, yürüyüş yolları | 1 + 1 + 2 | çim 39,2 × 30,5 (y -6,54); kenar 39,2 × 0,35 × 0,3; yollar 39,2 × 0,09 × 1,4 ve 1,4 × 0,09 × 30,2 | `grassMat`, #efe2c8, `walkMat` | sim:813-815 | elle: çim x -16..23,2, z 24,5..55; yollar z 32..33,4 ve x 8,4..9,8 (z 24,8..55) |
| Havuz | 1 + kenar bandı | elips 7,2 × 0,04 × 3,96; kenar 7,4 × 0,06 × 0,3 | #7fb3c9 (ışıksız); #efe2c8 | sim:816 | elle: merkez (15,5; 41); kenar z 38,8..39,1 |
| Komşu tuğla blokları | 5 | 12,20 × 16,50 × 21,25; 15,50 × 14,00 × 21,74; 9,00 × 10,80 × 17,74; 8,25 × 14,00 × 23,74; 14,00 × 7,60 × 22,00; korniş 0,35; 8 kat bandı 0,14 | tuğla dokusu × #dcc0a0, #c0876a, #cfa585, #b97a60, #c9a07e; korniş ve bant #efe2c8 (ışıksız) | sim:821-835 (`nb`; `brickMat` sim:669) | elle: x -12,5..-0,3, z -6..15,25; x -12,5..3, z -22..-0,26; x 3..12, z -18..-0,26; x 12..20,25, z -24..-0,26; x 32..46, z -26..-4; alt y -6,6; araç: sayaç `neighbour_building` 5 |
| Pencere birimi (`winUnit`), komşu | 78 (20, 48, 10) | 1,74 × 1,79 × 0,17 (cam 1,5 × 1,6) | `black`, `lowDark`, `frame`, #efe2c8 | sim:675; çağrı sim:824, 830, 834 | araç: items (bölüm `A2:neighbour_buildings`), bbox |
| Ağaç (`tree`) | 42 (14 sıra, 14 çukurlu, 14 park) | 2,1-3,1 × 2,8-4,1 × 2,1-3,1 | #6b4e3a, `leaves`, #9bc26a; çukur #3a3026, `metal` | sim:632; çağrı sim:817, 838-839, 841 | araç: items `args`, dünya; sıra z 26 (k 0,95), çukurlu z 17,2 ve x 22,2 / 30,7 (k 1 / 0,9), park k 0,8..1,3 |
| Araba (`car`) | 8 (2 taksi) | kendi ekseninde 2,18 × 0,83 × 1,00 (taksi 0,92 yüksek) | gövde #c0583f, #3f6f7a, #f2c230 (taksi), #6f9a7a, #e9e4da, #34384a, #f2c230 (taksi), #d98c5f; cam #3a4a66; tampon #1f2229; lastik `black`; jant `alu`; `carHead`, `carTail`; taksi tepe lambası #fff4c8 (e #ffe08a) | sim:683; çağrı sim:818-819 | araç: pose y -6,56; z 18,95: x -3, 6,5, 13 (taksi), -10, 17,2 yaw 0; (23,95; 2) ve (23,95; 9, taksi) yaw 1,571; (28,7; -6) yaw -1,571 |
| Bank (`bench`) | 3 | kendi ekseninde 1,40 × 0,85 × 0,43 | `walnut`, `metal` | sim:642; çağrı sim:842 | araç: pose (4; -6,51; 31,4) ve (14; -6,51; 31,4) yaw 0; (11; -6,51; 37) yaw -1,571 |
| Sokak lambası (`lampPost`) | 6 | direk Ø0,10 × 3,20; kafa 0,30 × 0,18 × 0,30 (toplam 3,34); zemin ışığı 4,5 × 4,5 | `metal`, `postMat`, `streetGlow` | sim:643; çağrı sim:843-844 | araç: items `args` (x; y; z): (-4; -6,48; 17,9), (5; -6,48; 17,9), (14; -6,48; 17,9), (7,6; -6,51; 33,8), (15,6; -6,51; 33,8), (10,4; -6,51; 45) |

## Dikkat

- Ev çalışma sandalyesi #3f5a6e değil #3f6f7a görünür: `M()` aynı anahtarlı malzemeyi önbellekten döndürür, sandalye `books[1]` ile ortak malzemedir ve palet `books[1]`'i #3f6f7a yapar (sim:27-33, 117, 414).
- JSON `bboxWorld` sokak lambası ve aplikte glow düzlemini içerir (4,5 × 4,5 ve 1,7 × 2,3); ölçü sütununda kod değerleri yazılıdır.
- Araç iki cephe solma düzlemini görmez (doğrudan `new THREE.Mesh`, sim:801-802); elle eklendi.
- `station` içindeki sandalye, monitör, kupa ve masa üstü bitki ayrı kalem değildir (iç içe çağrılar istasyonun mesh'ine girer); envanterde de ayrı satırları yoktur. Koltuk sayısı: İş hanı 11 istasyon sandalyesi + 7 toplantı sandalyesi.
- Ayna grubundaki adlı kalemlerde JSON `args` aynalanmamıştır (örnek: klozet `args` x 16,25, dünya x 3,75); konum için `pose` ve `bboxWorld` okunur.

## Sayılar

| sahne | iç mekân | kabuk | sokak | toplam satır |
|---|---|---|---|---|
| Ev | 52 | 7 | 12 | 71 |
| İş hanı | 45 | 7 | 12 | 64 |

Mesh kapsamı (props JSON): ev 1991 mesh = 1548 adlı kalem + 443 satır içi; İş hanı 2792 = 2563 + 229 (2'si cephe solma düzlemi). Ayna dönüşümü `art/office3d/ishani.json` spot'larıyla doğrulandı: `desk[0]` (17,4; 10,1) kurucu istasyonu, `meet[0]` (17,3; 1,7) ilk toplantı sandalyesi, `eat[0]` (7,15; 3,6) ilk mutfak sandalyesi; `art/office3d/home.json` `desk` (1,2; 8,3) ev istasyonuyla aynıdır.
