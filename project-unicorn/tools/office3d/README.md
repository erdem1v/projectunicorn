# Ofis 3B dışa aktarım hattı

Claude Design'daki ofis sahnesini (Three.js, prosedürel; kaynak `DESIGN_SOURCE.md`) Godot'nun
yükleyeceği GLB + JSON'a çevirir. Geometri tasarımın kendi kodundan üretilir, onaylı görünüm korunur;
Godot yalnız dinamik olanı yapar (kamera, ışık ve renk senaryosu, toon + mürekkep, kişiler, şehir
haritası). Bu dizin oyuna girmez; `.gdignore` Godot'yu dışarıda tutar.

Zincir: `src/*.js` → `export_office.html` + `export_office.js` (Chrome, three r0.160.0 esm.sh'ten)
→ `art/office3d/<id>.glb` + `<id>.json`, `assets/art/office/thumb_<id>.jpg` → Godot içe aktarma.
`<id>`: `home`, `ishani`, `plaza`, `loft`, `city` ve görüşme odası `meet` (yatırımcı kulesinin üst katı).

Komutlar `project-unicorn` kökünden, Git Bash'te koşulur.

| adım | komut | çıktı |
|---|---|---|
| 1. dışa aktarma | `bash tools/office3d/run_export.sh [durum_dizini] [sorgu]` | altı GLB + JSON, dört küçük resim |
| 2. denetim | `python tools/office3d/check_export.py [id ...]` | sayımlar, adlı düğümler, en ağır malzemeler; sözleşme ihlalinde çıkış kodu 1 |
| 3. içe aktarma | `"$GODOT" --headless --path . --import`, sonra bir ısınma koşusu | `art/office3d/<id>_<n>.png` (GLB'nin gömülü dokuları, içe aktarıcı çıkarır), `.godot/imported/` |
| 4. zemin | `"$GODOT" --headless --path . -s res://tools/office3d/bake_nav.gd [-- id ...]` | `art/office3d/<id>_nav.tres` (kişilerin yürüdüğü zemin ve bağlantıları); bir yerin girişi zeminde değilse çıkış kodu 1 |

Her dışa aktarımdan sonra zemin yeniden fırınlanır: `<id>_nav.tres` o yerin GLB'siyle aynı geometriden
çıkmalıdır, yoksa kişiler eski duvarların arasından yürür. Şehir (`city`) fırınlanmaz; orada kimse yürümez.

**1.** `run_export.sh` `serve.py`'yi `127.0.0.1:8735`'te başlatır (kök `project-unicorn`; `POST /save/<ad>`:
`.glb`/`.json` → `art/office3d/`, `.jpg`/`.png` → `assets/art/office/`, `.txt` → durum dizini), Chrome'u
kendi profiliyle (`$TMP/office3d_chrome_profile`) önde bir `--app` penceresi olarak açar, `DONE.txt`'yi en
çok 300 sn bekler ve yalnız kendi Chrome'unu kapatır. Durum dizininde `progress.txt` (sayfanın günlüğü,
hata ve uyarılar dahil), `DONE.txt` (`ok` ya da `ERR` + özet), `serve.log`, `chrome.log` olur; verilmezse
`$TMP/office3d_status`, repo içinde olmaz.

Sorgu bayrakları: `only=<id,...>` yalnız o ofisleri yazar, `thumbs=0` küçük resimleri atlar.
Commit'e giren dosyalar `only=` olmadan, tam koşudan gelir: builder'lar yuvarlak kenarlı kutu
geometrisini boyutu üç haneye yuvarlanmış anahtarla önbellekte paylaşır (`rbg`), kurulum sırası
değişince köşeler 0,5 mm'den az kayar. Tam koşunun geometrisi ve JSON'u bayt-deterministiktir; GLB'ye gömülü dokuların
baytları ise koşudan koşuya değişebilir (tuvalin rasterlenmesi ve GLTFExporter'ın eşzamansız görüntü sırası). Commit'lenecek
koşuda kaynağı değişmeyen yerlerin GLB'si repodakiyle aynı çıkmalıdır; çıkmazsa koşu yinelenir. Küçük resimler
bayt-deterministik değildir (Xbot animasyon fazı).

**Tuzaklar**
- Arka plandaki sekme `canvas.toBlob` ve `fetch().then()`'i dondurur; pencere önde bir `--app` penceresidir,
  örtülme bayrakları kapalıdır.
- Ağ gerekir: esm.sh (three ve örnekleri) her koşuda, threejs.org'daki `Xbot.glb` (yedeği
  raw.githubusercontent) küçük resimler için. Xbot inmezse küçük resimler kapsül karakterle çıkar,
  `DONE.txt` bunu `thumbs=capsule` diye yazar.
- `serve.py` her yanıta `Cache-Control: no-store` koyar; profil koşular arasında kalır, önbellekteki
  eski `src/*.js` eski geometri yazardı.
- `--import`'tan sonraki ilk Godot koşusu sınıf önbelleği yüzünden hata verebilir; kapılı bir koşudan
  önce bir ısınma koşusu yapılır.

## Sayfa ne yapar

Her ofis için, `createOffice.rebuildLayout`'un sırasıyla:
1. `initMats(); applyPalette();` (bir kez), `makeH()`.
2. `setTier`: city ve meet 1, home 0, ishani 1, plaza 2, loft 3. Builder: `buildHome(H)`, `buildA2('cevre')`,
   `buildPlaza(H)`, `buildLoft(H)`, `buildCity(H)` (`office-city-v2.js`), `buildMeet(H)`.
3. Şehirde tekneler `L.keep`'e eklenir; `bake()` onları manzaraya katardı, adlandırılamazlardı. Görüntü aynıdır.
4. `bake(L)`; `rebuildLayout`'taki cam değişimi (`cevre` → `lowDark`).
5. `L.tick(615, 1)` duvar saati 0'da: GLB 10:15'in gündüz hâlini dondurur (şehir arabaları şeritlerinin
   faz noktasında, feribot yolunun başında, kuleler gündüz dokusunda).
6. Toplamalı (additive) ışık lekeleri silinir, yerleri JSON'a yazılır; Godot ışığı yeniden kurar.
7. Adlandırma ve `extras` (sözleşme aşağıda); boşalan gruplar budanır.
8. `bake()`'in birleştirdiği tamponlar indeksizdir (üçgen başına üç köşe); `mergeVertices` (tolerans 1e-4)
   aynı üçgenleri aynı sırayla indeksli yazar. Konum ve normaller bayt-aynı kalır; GLB üç kat küçülür.
9. `GLTFExporter`: `binary`, dokular gömülü, `onlyVisible: false`.
10. Küçük resimler: tasarımın `createOffice`'i 960×600 bir kutuya kurulur (DPR 2), `loadXbot()` beklenir,
    `snapshot(k)` k = 0..3 (home, ishani, plaza, loft) 480×300 JPEG verir.

**Mahalle.** `neighbourhood.js` her ofis için builder'dan sonra, `bake()`'ten önce çağrılır (`export_office.js`'te
`build`'in hemen altı) ve `home`, `ishani` ile `loft`'un çevresini oyun kamerasının en geniş çerçevesine (0,6 × sığdırma,
16:9 ve 21:9) kadar doldurur: sokak ızgarası, apartman ve dükkân blokları, ağaç, park etmiş araba, sokak lambası. Ev'de ayrıca
park, okul ve spor sahası, pazar yeri ve bir apartman bloğu, ishani'de ana caddenin güney yakasında yan sokaklarda kesilen,
bir ucu iki katlı dükkân sıraları vardır. Renkler tasarımın paletindendir (birkaç nötr rengi biz ekledik, modülün başında
sayılı); rastlantı tohumlu akımlardan gelir ve modül kendi başına belirsizlik eklemez; düğüm adı verilmez; pencereler `facade`
malzemesiyle gece yanar, şehirdekiyle aynı yasa. plaza, city ve meet'e dokunulmaz. Küçük resimler (adım 10) tasarımın
`createOffice`'inden gelir ve mahalleyi göstermez. Çerçeve ve sokak ızgarası sayıları builder'ların ve `office_camera.gd`'nin
sayılarından ölçülmüştür; onlar değişirse modül yeniden ölçülür.

## Bağlama sözleşmesi

Godot düğüme adıyla, malzemeye adıyla bağlanır. Adlar Godot'nun içe aktarma ipucu son eklerinden
(`_col`, `_noimp`, `_occ`, …) kaçınır. Davranışın kendisi tasarımdadır: `src/office-sim-v12.js`'de
`createOffice` içindeki `update()` ve `colorScript()`, ofis dosyalarında `tick()`.

### Düğümler

| ad | ne | `extras` |
|---|---|---|
| `office_<id>` | kök | |
| `station_<i>_lamp`, `station_<i>_screen`, `station_<i>_screen_<k>` | Masa lambası ve ekranları. `i` = masa id − 1, kurucununki `f` (`^station_(\d+\|f)_(lamp\|screen)(_\d+)?$`). Bir istasyonun ekranları tek malzemeyi paylaşır | |
| `pane_<i>` | `L.low`: saatine göre `pane_dark` ile `pane_lit` arasında değişen pencere camı | `sched {on, off, allNight}` oyun dakikası |
| `fade_<i>` | İş hanı cephesinin sis perdesi | |
| `sconce_<i>` | Aplik; tasarımın varsayılan ışık modu (`tavan`) gizler | `hidden` |
| `elev_panel_<i>` | Asansör ya da kapı kanadı: `rot` ise `rotation.y`, değilse `position[ax]` = `p0 + d·o`, `o` yakınlıkla 0 → 1 | `p0, d, rot, ax` |
| `frame_<id>`, `pin` | Şehir seçim çerçevesi (`id` tasarımın harita id'si) ve mevcut ofis işareti | `hidden` |
| `pen` | Görüşme odası: masadaki kalem; bırakılınca JSON'daki `pen` yerine düşer | |
| `ferry`, `car_<i>`, `boat_<i>` | Şehir (loft'ta yalnız `ferry`) | |
| `keep_<i>` | `L.keep`'in adsız kalanları: loft'un çelik çerçeveli pencere camları | |
| `matlib_pane_lit` | `pane_lit` malzemesinin 1 cm taşıyıcısı; bu malzeme yalnız çalışma zamanında takılır | `hidden` |

Genel `extras`: `hidden` (yüklenince gizle), `noCast` (gölge düşürmez), `noReceive` (tasarımda gölge
almaz), `noEdge` (tasarımın mürekkep kenarı geçişinden hariç; saydam malzemeler de hariçtir).
`envpane_<i>` ve `sky_<i>` bu altı yerde oluşmaz.

### Malzemeler

| ad | kaynak | not |
|---|---|---|
| `pane_dark`, `pane_lit` | `lowDark`, `lowLit` (unlit, cam ve jaluzi dokusu) | `pane_<i>` saatine göre değişir |
| `post`, `flamp`, `sconce`, `car_head`, `car_tail` | sokak lambası başı, ayaklı lamba, aplik, far, stop | emisyon gücü 0; tasarım akşam ve gece yakar, apliği yalnız `duvar` modunda |
| `ground`, `walk`, `road`, `grass`, `line` | unlit zemin, kaldırım, yol, çim, şerit | renk gündüz/gece arası |
| `glass`, `fade` | `X.glass` (saydam .18), `fadeMat` (unlit, saydam) | |
| `haze` | `hazeMat` (unlit) | `extras.base` `#rrggbb`, sisle karışan taban renk |
| `tower` | kule cephesi | gündüz dokusu `map`, gece dokusu `emissiveMap`, emisyon gücü 0, `extras.unlit` |
| `water` | loft ve şehir suyu (haritası tasarımın `wtex`'i) | UV kaydırma |
| `facade` | şehir binası cephesi (depo tipi hariç); home, ishani ve loft'ta mahalle binalarının cepheleri | gece pencere ışığı `emissiveMap`; `extras.emissiveUv` o dokunun kendi ölçeği, çünkü Godot'nun içe aktarıcısı yalnız taban dokunun UV dönüşümünü tutar |
| `ferry_win` | feribot camları | |
| `station_lamp`, `station_screen` | istasyon başına bir örnek | emisyon gücü 0 |
| `crown` | şehir: yatırımcı kulesinin tacı | emisyon gücü 0; gece ve varışta parlar |

`win`, `ceil`, `view` bu altı GLB'de yoktur. Adsız malzemeler düz renklidir (`applyPalette` mobilya
dokularını siler); dokusunu koruyanlar tuğla, beyaz tahta, WC levhası, kurucu koltuğunun kumaşı ve
şehrin depo cepheleridir.

`extras` glTF'te düğümün ve malzemenin `extras` alanındadır. Çalışma zamanının düğüm başına ihtiyaç
duyduğu veri (cam saatleri, asansör, istasyonlar, gizli düğüm adları) JSON'da da vardır; gölge ve kenar
bayrakları (`noCast`, `noReceive`, `noEdge`) yalnız `extras`'tadır.

### Yan JSON (`<id>.json`)

Sayılar 4 haneye yuvarlanır; vektörler `[x, y, z]`.

| alan | ne |
|---|---|
| `bounds`, `sunOff`, `fog` | tasarımın sınır kutusu (`fitView`), güneş ofseti, sis `{near, far}` ya da `null` |
| `tier`, `maxN`, `spd`, `env` | mobilya kademesi, masa sayısı, yürüme hızı (birim / oyun dakikası), çevre |
| `spots` | tür → nokta listesi `{pos, face, pose, chain, floor, zone}`. `desk[0]` kurucu, `desk[i]` i. çalışan; `visit[i]` masa id i + 1'in yanı; İş hanında `meet`, plaza ve loft'ta `meet_<oda>` (`meetRooms`); ev: `desk, bal, ket, eat, wc, out, bed, stairs, door, enter`; görüşme odası: `desk` (kurucu), `guest` (0 ortada, 1 ve 2 iki yanında; masadaki kalem 2'nin önünde), `out` (asansör). `chain` noktadan koridora yürüme yolu; `zone` farklıysa tasarım yürütmez, ışınlar |
| `stations`, `founderStation` | `{deskId, node, lampPos, screenPos}`: masa lambası spotu ve ekran ışığının yeri |
| `elevNear`, `elevPanels` | asansör yakınlık kutusu (`y` kullanılmaz), kanatlar |
| `panes`, `envPanes`, `sconces`, `fades`, `keep`, `hidden` | düğüm adları; `panes` saatleriyle, `hidden` yüklenince gizlenecekler |
| `glows` | silinen ışık lekeleri: `pool` (ayaklı lamba havuzu), `street` (sokak lambası dibi), `sconce`; `{pos, size, normal}` |
| `mapHits` | şehir: `{id, office, box, anchor}`; `id` tasarımın (`ev`, `depo` …), `office` oyunun ofis id'si. Ofis olmayan kule burada yoktur |
| `meetHit` | şehir: görüşmelerin kulesi `{box, anchor}` (tasarımın `meridian`'ı) |
| `table`, `pen` | görüşme odası: masanın ortası; kalemin masaya bırakılmış yeri `{pos, rot}` (Euler XYZ); elde not alanın kendi kalemidir |
| `lanes` | şehir arabaları `{a, b, v, ph, ry, carNode}` (`a`, `b` x/z): `office-city-v2.js` `tick()` konumu `a + (b − a)·s`, `s = ((now·v + ph) mod len)/len`, `len = \|b − a\|` ile hesaplar; `now` duvar saati (sn), `y` 0,04, yön `ry` |
| `thumbTargets` | `snapshot(k)` çerçevesi: `target` (null = sığdırma merkezi), `zoom` (× sığdırma), `time`, kırpma |
| `materials` | GLB'deki adlı malzemeler |

## Boyut

`bake()` aynı malzemeli ve aynı gölge bayraklı en az üç mesh'i tek tampona birleştirir. En ağır
tamponlar yuvarlak kenarlı kutulardır (kutu başına 588 üçgen): loft'ta monitör gövdeleri (`0xc6c9ce`,
370 bin üçgen) ve `X.black` (287 bin), plaza'da aynı ikisi. İndekslemeden sonra loft 37,7 MB, plaza 18 MB,
İş hanı 8,3 MB, ev 5,4 MB, şehir 4,3 MB. Mahallenin payı: ev +23 bin üçgen ve +1,2 MB, İş hanı +10 bin ve +0,7 MB, loft +8 bin ve +0,5 MB.
