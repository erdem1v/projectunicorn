CLAUDE.md §8 istisnası: bu rapor `docs/tasks/PRD_RENDER_ASSETLAB.md` gereği ve sahibin kararıyla repoda tutulur.

# Karşılama: paketler × envanter

- Aile kararı: ana aile Kenney; KayKit ve MrEliptik yalnız Kenney'nin vermediği ya da oturmadığı yerlerde; Quaternius kullanılmadı. Kullanılan paketlerin hepsi CC0 (`LISANS.md`). Kaynak `sandbox/asset_lab/recipes/home.json` ve `ishani.json`; kalem adları ve sırası `ENVANTER.md` ile aynı.
- "ilkel" = kutu ve silindirden, palet renginde kurulmuş (paket modeli yok); "atlandı" = tarif o kalemi kurmuyor. Adet tarifin sayısıdır, ENVANTER'den ayrılırsa notta yazar; model adı `önek/ad` biçimindedir (önekler Özet sayılar'da).

## Ev (home)

| kalem | adet | karşılayan | not |
|---|---|---|---|
| *iç mekân (52)* | | | |
| Döşeme levhası (merdiven boşluklu) | 4 kutu | ilkel | palet yaklaşımı: edge (#8b7e70), tasarım #7d746a |
| İç zemin düzlemleri | 3 | ilkel | tile, tileB, oakF paletiyle birebir |
| Sahanlık ve teras zemini | 4 düzlem | ilkel | palet yaklaşımı: concrete (#d8ccb6), tasarım #cdc5b8 |
| Arka duvar (z 0), üç pencere boşluklu | 10 kutu | ilkel | wall paletiyle birebir |
| Ortak duvar (x 0) ve duvar başlıkları | 1 duvar, 2 başlık | ilkel | wall ve cap paletiyle birebir |
| Daire pencereleri (arka duvar) | 3 | `mod/window-white` ×2, `mod/window-white-large` ×1 + ilkel | çerçeve paketten; yüz kutusu, söve ve denizlik ilkel; çerçeve kalın beyaz, orta dikme yok |
| Kesik iç duvarlar | 8 parça | ilkel | wall ve cap paletiyle birebir |
| Kesik dış duvarlar, cephe kaplaması, krem bant | 3 + 3 + 3 + 1 | ilkel | kaplama oakF (tasarım #d4ad8c), bant stone (tasarım #efe2c8) |
| Balkon kapısı kanadı | 2 | ilkel | frame ve glass kutuları |
| Daire giriş kapısı kanadı (elev_panel_0) | 1 | ilkel | walnut kutu (tasarım #6e4a32), 2 topuz; kit kapıları 2,1 m, kesik duvar boşluğu 1,05 m |
| Mutfak tezgâhı (kitchenRun) | 2 modül | `fur/kitchenStove`, `fur/kitchenCabinetDrawer` | ENVANTER: 1 sıra, 5 alt dolap; modül 0,86 m, evye modülüyle 3; dolaplar bej; sırt bandı yok |
| Buzdolabı (fridge) | 1 | `fur/kitchenFridge` | 1,95 m'ye oturtulur (kit 1,84 m, +%6) |
| Evye ve musluk (sink) | 1 | `fur/kitchenSink` | tezgâhın ortasında 0,86 m'lik modül; evye ve musluk modülün içinde |
| Kahve makinesi (coffeeMachine) | 1 | `fur/kitchenCoffeeMachine` | ayak izine oturtulur, 0,04 m kaldırılır |
| Duvar dolabı | 1 | `fur/kitchenCabinetUpper` | h 0,75 m'ye oturtulur |
| Açık raf ve kavanozlar | 1 raf, 4 kavanoz | ilkel | walnut raf, 4 silindir kavanoz |
| Ocak ve ocak üstü takımı | 1 ocak, 2 göz, 4 üst parça | `fur/kitchenStove` | satır 11 ile aynı modül, kendi gözleriyle; tencere, kapak, demlik, kepçe yapılmadı |
| Yemek masası (yuvarlak) | 1 | ilkel | walnut Ø0,90 m üst, metal ayak ve taban; kitin yuvarlak masası 1,4 × 1,6 m altıgen |
| Ahşap sandalye (woodChair), mutfak | 2 | `fur/chair` | h 0,93 m'ye oturtulur |
| Tabak ve fincan | 1 + 1 | ilkel | iki silindir; Kenney'de fincan yok |
| Klozet (toilet) | 1 | `fur/toilet` | kase altıgen |
| Lavabo dolabı, tezgâh, lavabo | 1 modül | `fur/bathroomCabinetDrawer` | ENVANTER: 1 + 1 + 1; w 0,74 m, dolap ve lavabo tek modülde |
| Banyo aynası | 1 | ilkel | krom kutu 0,60 × 0,55 m; kitin aynası ayaklı |
| Duş teknesi, cam perde, ray | 1 kabin | `fur/shower` | ENVANTER: 1 + 1 + 1; kit kabini 1,1 × 1,2 m, ayak izi 0,76 × 0,90 m'ye küçültülür |
| Çamaşır makinesi | 1 | `fur/washer` | h 0,82 m'ye oturtulur |
| Bitki (plant), sahanlık | 1 | `fur/pottedPlant` | tip 1, 0,87 m (kit bitkisi 1,31 m); üç bitki tipi de aynı modeli kullanır |
| Gri duvar levhası | 1 | ilkel | plasticG kutu (elektrik plakası) |
| Merdiven (aşağı) | 10 basamak | `fur/stairs` | iniş boyu 2,8 m'ye oturtulur; siyah çukurda kaybolur |
| Merdiven yan ve arka duvarları | 3 | ilkel | black kutular |
| Küpeşte ve baluster | 1 + 17 | ilkel | walnut küpeşte, black baluster; plan gereği |
| Antre konsolu | 1 | `fur/sideTableDrawers` | 1,3 m'ye büyütülür (kit 1,07 m, +%22); taş üst yok |
| Portmanto ve çanta | 1 + 1 | `fur/coatRackStanding` + ilkel | h 1,75 m (+%14); çanta walnut kutu |
| Yatak | 1 | `fur/bedDouble` | len 2,26 m; paket pembesi |
| Komodin ve abajur | 2 + 2 | `fur/cabinetBedDrawerTable` ×2, `fur/lampRoundTable` ×2 | komodin h 0,5 m, abajur h 0,42 m |
| Gardrop | 1 | ilkel | cabinet kutu 1,25 × 2,10 × 0,60 m, derz, 2 kulp; plan gereği |
| Halılar | 4 | ilkel | rug (çalışma), rug2 (salon, yatak odası, antre) birebir |
| Paspaslar | 2 | ilkel | palet yaklaşımı: laminate (banyo), walnut (sahanlık) |
| Çalışma istasyonu (station, katman 0) | 1 | `fur/desk`, `fur/chairDesk`, `fur/computerScreen`, `fur/laptop`, `fur/computerKeyboard`, `fur/computerMouse`, `fur/lampRoundTable` + ilkel | kupa ve kâğıt ilkel; sandalye paket pembesi; ekran gündüz açık mavi levha |
| Yapışkan not | 12 | ilkel | 12 ince kutu; renkler palet yaklaşımı (fabricW, fabricB, laminate, leaf2) |
| Duvar beyaz tahtası | 1 çerçeve, 1 yüz, 9 çizgi, 1 tepsi | ilkel | alu çerçeve, paper yüz, 9 çizgi kutusu, metal tepsi; plan gereği |
| Kitaplık (bookshelf) | 1 + 4 sıra kitap | `fur/bookcaseClosedWide`, `fur/books` ×4 | 1,8 m'ye büyütülür (kit 1,6 m, +%12,5); tekrarlı kitap yığınları, tasarımın renkli kitapları yok |
| Kanepe (sofaR) | 1 | `fur/loungeDesignSofa` | len 2,30 m'ye oturtulur |
| Sehpa, fincan, defter | 1 + 1 + 1 | `fur/tableCoffee` + ilkel | fincan ve defter ilkel, kit masasının yaklaşık 2 cm üstünde durur |
| Koltuk (armchair) | 1 | `fur/loungeChair` | paket pembesi |
| Lambader (floorLamp) | 1 | `fur/lampRoundFloor` | h 1,81 m'ye oturtulur (+%5) |
| Bitki (plant), salon | 2 | `fur/pottedPlant` ×2 | tip 1 (0,79 m) ve tip 0 (1,08 m); tip 0 şerit yapraklı çıkar |
| Işık havuzu (decal, gece) | 1 | atlandı | skip listesinde; lab ışık düzlemini kendisi çizer |
| Balkon levhası ve karo zemin | 1 + 1 | ilkel | stone levha (tasarım #efe2c8), tile zemin |
| Balkon korkuluğu (daire balkonu) | 1 takım | ilkel | black, 37 kutu (4 + 19 + 14); plan gereği |
| Bistro masası | 1 | ilkel | metal silindir ×2 |
| Ahşap sandalye (woodChair), balkon | 1 | `fur/chair` | h 0,93 m'ye oturtulur |
| Bitki (plant), balkon | 2 | `fur/pottedPlant` ×2 | tip 1 (0,52 m) ve tip 0 (0,61 m) |
| *bina kabuğu (7)* | | | |
| Alt cephe kaplaması (ön, yan) | 2 | ilkel | palet yaklaşımı: oakF (tasarım #d4ad8c) |
| Kat bantları ve saçak bandı | 6 + 2 | ilkel | palet yaklaşımı: stone (tasarım #efe2c8) |
| Pencere birimi (winUnit), alt cephe | 23 | `mod/window-white-large` ×21, `mod/window-white-tall` ×2, `bld/wall` ×23, `bld/wall-low` ×2 | çerçeve mod, yanan yüz bld; çerçeve kalın beyaz, yüz soluk lavanta, orta dikme yok |
| Alt kat balkonları | 1 (ENVANTER 2) | ilkel | stone levha, black korkuluk (37 kutu, plan gereği); ikinci balkon yapılmadı, kamera görmüyor; bitkisi `fur/pottedPlant` balkonsuz yerleşir, kamera dışı |
| Dükkân vitrini | 1 cam, 4 dikme, 1 alt çıta | atlandı | tarifte yok; kamera görmüyor (rapor) |
| Dükkân tentesi | 1 | atlandı | tarifte yok; kamera görmüyor (rapor) |
| Sokak kapısı, lento, basamak | 1 + 1 + 1 | atlandı | tarifte yok; kamera görmüyor (rapor) |
| *sokak bağlamı (12)* | | | |
| Zemin düzlemi | 1 | ilkel | ground |
| Kaldırımlar | 2 (ENVANTER 4) | ilkel | walk; yalnız iç ön ve iç yan, dış ikisi yok |
| Yollar | 2 | atlandı | tarifte yok; kamera görmüyor (rapor) |
| Şerit çizgileri | 22 + 13 | atlandı | tarifte yok; kamera görmüyor (rapor) |
| Komşu bloklar (4 kat) | 5 | `com/building-n` ×3, `com/building-l` ×2 | n modelleri 12,8 m yüksekliğe, l modelleri 7,07 ve 7,3 m genişliğe oturtulur; gri modern blok, koyu düz çatı; tasarım bej blok, turuncu hip çatı (en büyük ayrım) |
| Hip çatı (hipRoof) ve baca | 5 + 5 | atlandı | hipRoof skip listesinde: paket binaların çatısı düz, kitte hip çatı yok; baca tarifte yok |
| Pencere birimi (winUnit), komşu | 88 | atlandı | bilerek eşlenmedi (LABMISS 88): paket binalar kendi pencerelerini taşır; gece yanmaz |
| Karşı dükkânlar (3,4 m) | 6 | atlandı | tarifte yok; kamera görmüyor (rapor) |
| Dükkân çatı donanımı | 6 klima, 6 bitki, 6 tente, 24 parapet | atlandı | klima, tente, parapet tarifte yok; 6 bitki `fur/pottedPlant` olarak yerleşir, kamera dışı |
| Ağaç (tree) | 7 | `nat/tree_fat` | h kutuya oturtulur; 6'sı kamera dışı |
| Sokak lambası (lampPost) | 3 | `rod/light-square` | h 3,34 m'ye oturtulur; kamera dışı |
| Araba (car) | 3 (1 taksi) | `car/sedan` ×2, `car/taxi` ×1 | kamera dışı |

## İş hanı (ishani)

| kalem | adet | karşılayan | not |
|---|---|---|---|
| *iç mekân (45)* | | | |
| Taban levhası | 1 | ilkel | edge paletiyle birebir |
| Zemin düzlemleri | 6 | ilkel | carpet, oakF ×3, tile, tileB paletiyle birebir |
| Dış duvarlar | 4 | ilkel | wall işlemi (wall, cap, base paletleri) |
| Opak iç duvarlar | 5 parça | ilkel | 3 wall işlemi, boşluklarla 5 parça |
| Cam bölmeler | 6 koşu | ilkel | 4 glass işlemi, boşluklarla 6 koşu; plan gereği |
| Cam kapı (glassDoor) | 2 | ilkel | glass, frame, chrome kutuları; plan gereği |
| WC kapısı (ahşap) | 1 | `bld/door-rotate-square-a` | h 2,2 m'ye oturtulur |
| WC levhası (wcSign) | 1 | ilkel | fabric levha, 4 paper işaret kutusu (tasarımın yüzü doku) |
| Asansör çekirdeği | 1 kutu, 1 başlık, 1 girinti, 3 çerçeve, 2 kapı, 1 gösterge | ilkel | 9 kutu (shaft, cap, black, frame, alu, tileB) |
| Asansör önü halısı | 1 | ilkel | rug2 paletiyle birebir |
| Bitki (plant), asansör önü | 1 | `fur/pottedPlant` | tip 1 (0,90 m) |
| Toplantı masası | 2 modül | `fur/table` ×2 | ENVANTER: 1 üst, 2 ayak; 2 × 2,1 m = 4,2 m; kit masası 0,65 m yüksek, genişliğe göre ölçeklenir (+%25); bej, tasarım ceviz |
| Ofis sandalyesi (officeChair), toplantı | 7 | `fur/chairDesk` | h 0,95 m; paket pembesi (tasarım bej) |
| Kredenza | 2 modül | `fur/cabinetTelevision` ×2 | ENVANTER: 1; 2 × 1,6 m = 3,2 m |
| Bitki (plant), toplantı odası | 2 | `fur/pottedPlant` ×2 | tip 2 (2,06 m, 1,31 m'lik kit bitkisinden büyütülür; iri agave gibi) ve tip 1 (1,03 m) |
| Mutfak tezgâhı (kitchenRun) | 5 modül | `fur/kitchenBar` ×5 + ilkel | ENVANTER: 1 sıra, 8 alt dolap; 5 × 0,924 m = 4,62 m (+%7); bej (tasarım beyaz); sırt bandı ilkel |
| Duvar dolabı | 4 | `fur/kitchenCabinetUpper` ×4 | 4 × 0,6 m |
| Kahve makinesi (coffeeMachine) | 1 | `fur/kitchenCoffeeMachine` | h kutuya oturtulur (+%18) |
| Evye ve musluk (sink) | 1 | ilkel | krom tekne ve silindir musluk; Ev'de `fur/kitchenSink` kullanıldı |
| Fincan | 3 | ilkel | ceramic silindir ×3; istasyon kupaları `mre/mug` |
| Buzdolabı (fridge) | 1 | `fur/kitchenFridge` | h 1,95 m (+%6) |
| Kafe masası (yuvarlak) | 1 | ilkel | deskTop Ø1,10 m üst, metal ayak ve taban; kitin yuvarlak masası altıgen (Ev raporu) |
| Kare yemek masası | 1 | `kay/table_small` | KayKit; `fur/table` 0,65 m yüksek, h 0,76 m için yetmez; kahverengi okunur |
| Ahşap sandalye (woodChair), mutfak | 4 | `fur/chair` ×4 | h 0,93 m'ye oturtulur |
| Bitki (plant), mutfak | 1 | `fur/pottedPlant` | tip 0 (0,92 m) |
| WC bölmeleri | 1 + 3 | ilkel | laminate kutu ×4 |
| Klozet (toilet) | 2 | `fur/toiletSquare` ×2 | Ev'deki `fur/toilet` yerine kare kase modeli |
| Lavabo dolabı ve lavabo | 1 modül | `fur/bathroomCabinetDrawer` | ENVANTER: 1 + 1; h 0,85 m |
| Çalışma istasyonu (station, katman 1), personel | 10 | `fur/desk`, `fur/chairDesk`, `fur/computerScreen`, `fur/computerKeyboard`, `fur/computerMouse`, `fur/lampRoundTable`, `mre/mug` | kupa MrEliptik (Kenney'de yok), 10 / 10 (tasarım %70); kâğıt yok; sandalye paket pembesi (tasarım lacivert) |
| Alçak bölme ekranı | 3 | ilkel | alu kutu 2,60 × 0,38 m; plan gereği |
| Bitki (plant), açık ofis | 2 | `fur/pottedPlant` ×2 | tip 2 (2,11 m, iri agave gibi) ve tip 0 (1,29 m) |
| Kurucu istasyonu (station, büyük) | 1 | `fur/table`, `fur/chairDesk`, `fur/computerScreen` ×2, `fur/computerKeyboard`, `fur/computerMouse`, `fur/lampRoundTable`, `fur/plantSmall1`, `mre/mug` | defter yok; sandalye paket pembesi (tasarım koyu deri); masa h 0,735 m'ye oturtulur (+%12) |
| Ahşap sandalye (woodChair), ziyaretçi | 2 | `fur/chair` ×2 | h 0,93 m'ye oturtulur |
| Alçak büfe (bookshelf) | 4 modül | `fur/bookcaseOpenLow` ×4 | ENVANTER: 1; 4 × 0,75 m = 3,0 m; renkli kitap sıraları yok |
| Büfe üstü kitaplar | 2 yığın | `fur/books` ×2 | ENVANTER: 6 dikili + 1 yatık; w 0,3 m |
| Bitki (plant), büfe üstü | 1 | `fur/pottedPlant` | tip 1, 0,57 m'ye küçültülür (kit bitkisi 1,31 m) |
| Unicorn figürü (unicorn) | 1 | ilkel | 9 küçük kutu ve silindir (ceramic, fabricB, fabricW) |
| Altın kupa | 1 | ilkel | fabricW silindir ×3; altın yerine palet yaklaşımı |
| Eğik çerçeve | 1 | ilkel | walnut çerçeve, paper kâğıt; eğim, çizgiler ve ayak yok |
| Beyaz tahta (whiteboard, ayaklı) | 1 | ilkel | alu kutular (tahta, çerçeve, iki ayak); yüzü boş; plan gereği |
| Bitki (plant), kurucu köşesi | 1 | `fur/pottedPlant` | tip 2 (2,26 m, iri agave gibi) |
| Lambader (satır içi) | 1 | `fur/lampRoundFloor` | h 1,81 m (+%5) |
| Kurucu halısı | 1 | ilkel | rug paletiyle birebir |
| Işık havuzu (decal, gece) | 1 | atlandı | tip boş; lab ışık düzlemini kendisi çizer |
| Duvar apliği (sconce) | 7 | atlandı | skip listesinde; yayımlanan oyunda gizli |
| *bina kabuğu (7)* | | | |
| Alt cephe kaplaması (ön, yan) | 2 | ilkel | oakF kum rengi (tasarım somon #c98f6d) |
| Kat bantları | 4 | ilkel | wall paleti (tasarım #efe2c8) |
| Pencere birimi (winUnit), kabuk | 26 | `mod/window-white-tall` ×52 + ilkel | her birimde iki çerçeve; yüz (shaft) ve denizlik kutu; 4 yüz sabit krem yanık; yüzler gündüz koyu lacivert |
| Cephe solma düzlemleri | 2 | atlandı | tarifte yok; rapor gerekçe yazmıyor |
| Giriş vitrini ve cam paneli | 1 + 1 | ilkel | frame ve glass kutuları |
| Giriş saçak bandı | 1 | ilkel | wall paleti kutu |
| Bitki (plant), giriş | 2 | `fur/pottedPlant` ×2 | tip 0 (1,28 m ve 1,15 m) |
| *sokak bağlamı (12)* | | | |
| Zemin düzlemi | 1 | ilkel | ground |
| Kaldırımlar | 3 | ilkel | walk |
| Yollar | 2 | ilkel | road |
| Şerit ve yaya geçidi çizgileri | 24 + 13 + 6 | ilkel | line, 43 kutu |
| Çim, kenar bandı, yürüyüş yolları | 1 + 1 + 2 | ilkel | grass, wall (bant), walk |
| Havuz | 1 + kenar bandı | atlandı | tarifte yok; rapor gerekçe yazmıyor |
| Komşu tuğla blokları | 4 (ENVANTER 5) | `com/building-i`, `com/building-c`, `com/building-j`, `com/building-k` | ayak izine oturtulur; beşinci blok kamera görmüyor; beyaz ve gri blok, koyu düz çatı; tuğla ve turuncu yok |
| Pencere birimi (winUnit), komşu | 78 | atlandı | paket binalar kendi 2 m pencerelerini taşır; gece yanmaz |
| Ağaç (tree) | 42 | `nat/tree_oak` ×42 | 12'si kamera dışı |
| Araba (car) | 8 (2 taksi) | `car/sedan`, `car/van`, `car/taxi` ×2, `car/suv`, `car/truck-flat`, `car/police`, `car/sedan-sports` | 7 model 8 arabaya; kırık beyaz sedan beyaz kasalı pikap çıkar; far ve stop ışığı yok |
| Bank (bench) | 3 | `fur/bench` ×6 | her bank iki sandalye boyu bank yan yana |
| Sokak lambası (lampPost) | 6 | `kcb/streetlight` ×6 | KayKit; `rod/light-square` 3,34 m'de direği 0,28 m kalın, kolu 1,3 m (KayKit 0,94 m) |

## Boşluklar

| grup | satırlar | kapanış yolu |
|---|---|---|
| *(a) plana göre ilkel (PRD paket taraması: tahta, cam bölme, dosya dolabı paketlerde yok)* | | |
| beyaz tahta | Duvar beyaz tahtası (Ev); Beyaz tahta, ayaklı (İş hanı) | bugünkü geometriyi koru: kutu + malzeme en ucuz yol (PRD paket taraması) |
| cam bölme | Cam bölmeler; Cam kapı (İş hanı) | bugünkü geometriyi koru (glass + frame kutuları) |
| dosya dolabı | ENVANTER'de satırı yok; yakınları Kredenza ve Alçak büfe `fur/cabinetTelevision`, `fur/bookcaseOpenLow` ile karşılandı | işlem yok |
| bölme paneli | Alçak bölme ekranı ×3 (İş hanı) | bugünkü geometriyi koru (alu kutu) |
| gardrop | Gardrop (Ev) | basit kendi model; bugünkü kutu, derz ve kulp geometrisi zaten bu |
| korkuluk | Küpeşte ve baluster; Balkon korkuluğu; Alt kat balkonları (Ev) | basit kendi model: tek baluster ızgarası (bugün 18 + 37 + 37 kutu) |
| *(b) diğer ilkel* | | |
| mimari yüzeyler | levha, zeminler, halı ve paspaslar, duvarlar, kesik duvarlar, başlıklar, cephe kaplaması, bantlar, saçak, balkon levhası, vitrin, WC bölmeleri, asansör çekirdeği, sokak zemini, kaldırım, yol, çizgi, çim (iki sahne) | bugünkü geometriyi koru; raporlar kaplama ve bant için paket parçası bulmadı, hiçbir pakette tuğla yok; tuğla ve düz cephe için basit kendi kit |
| pencere yüzü, söve, kapı kanadı | Daire pencereleri (yüz, söve); Balkon kapısı kanadı; Pencere birimi, kabuk (İş hanı; yüz, denizlik); Giriş vitrini (İş hanı) | bugünkü geometriyi koru: Kenney pencere eklentileri içi boş, çerçeve paketten, yüz kutudan; gündüz ve gece yüz rolü lab değişikliği ister |
| yuvarlak masa, ayna, küçük eşya | Yemek masası; Kafe masası; Banyo aynası; Açık raf ve kavanozlar; Bistro masası; Gri duvar levhası; Daire giriş kapısı kanadı; Yapışkan not; çanta (Portmanto satırı) | basit kendi model; kitin yuvarlak masası 1,4 × 1,6 m altıgen, aynası ayaklı, kapıları 2,1 m |
| fincan | Tabak ve fincan (Ev); Fincan (İş hanı) | `mre/mug` (MrEliptik; istasyonlarda 11 yerleşimle kullanılıyor, Kenney'de fincan yok) |
| evye | Evye ve musluk (İş hanı) | `fur/kitchenSink` (Ev'de kullanıldı) |
| tasarıma özgü süs | Unicorn figürü; Altın kupa; Eğik çerçeve; WC levhası (İş hanı) | bugünkü geometriyi koru; paket karşılığı yok |
| *(c) atlandı: neden* | | |
| lab kendisi çiziyor ya da oyunda gizli | Işık havuzu (iki sahne); Duvar apliği ×7 (İş hanı) | işlem yok |
| pakette karşılığı yok | Hip çatı ×5 ve baca ×5 (Ev; paket binaların çatısı düz); ocak üstü takımı (Ev) | basit kendi model: çatı kiti; silindirlerden tencere, kapak, demlik, kepçe |
| paket binaların kendi penceresi var | Komşu pencereler: 88 (Ev), 78 (İş hanı) | işlem yok; yanma programı lab değişikliği ister |
| kamera görmüyor | Ev: Dükkân vitrini, tentesi, Sokak kapısı, Yollar, Şerit çizgileri, Karşı dükkânlar, Dükkân çatı donanımı, ikinci alt kat balkonu; İş hanı: beşinci komşu blok | kamera eklenirse bugünkü ilkel geometri aynen kurulur |
| tarifte yok, rapor gerekçe yazmıyor | Cephe solma düzlemleri ×2; Havuz (İş hanı) | basit kendi model: gradyan düzlem, elips |

Paketle karşılanıp rengi tutmayanlar: sandalye, yatak, koltuk pembe; tezgâh ve masalar bej; komşu bloklar gri. Tarifte yeniden boyama anahtarı yok. Rapor tahmini (sanatçı emeği): Ev ~70 kişi saati (55 ile 90), İş hanı ~35 ile 45; yeniden boyama payı Ev ~10 sa (35 kit modeli), İş hanı ~20 sa (sandalye, ağaç, bina ve tuğla cephe).

## Özet sayılar

| ölçüt | Ev | İş hanı |
|---|---|---|
| ENVANTER satırı | 71 | 64 |
| paket modeliyle karşılanan | 32 (4 karma) | 31 (2 karma) |
| ilkel | 29 | 28 |
| atlandı | 10 | 5 |

Sınıf, satırın kimliğini taşıyan parçaya göre verildi: ana gövde paket modeliyse "paket" (kalan küçük ilkel parçalar "+ ilkel", yani karma), hiç paket modeli yoksa "ilkel", tarif kurmuyorsa "atlandı". Yan parçası paket olan ilkel satır (Alt kat balkonları), yalnız bitkisi yerleşen atlanmış satır (Dükkân çatı donanımı) ve üst takımı eksik ocak satırı (ocak paketten geldiği için paket) kimliğine göre sayıldı.

| aile (önekler) | Ev: model / yerleşim | İş hanı: model / yerleşim |
|---|---|---|
| Kenney (fur, mod, bld, com, nat, car, rod) | 41 / 118 | 35 / 223 |
| KayKit (kay, kcb) | 0 | 2 / 7 (`kay/table_small` ×1, `kcb/streetlight` ×6) |
| MrEliptik (mre) | 0 | 1 / 11 (`mre/mug`) |
| Quaternius | 0 | 0 |

Yerleşim, raporların LABPACK n değeridir (tekrar koşuları tek sayılır). Kenney kitleri, model sayısı: Ev fur 30, mod 3, bld 2, com 2, car 2, nat 1, rod 1; İş hanı fur 21, car 7, com 4, bld 1, mod 1, nat 1. Önekler: fur Furniture Kit, mod Modular Buildings, bld Building Kit, com City Kit Commercial, nat Nature Kit, car Car Kit, rod City Kit Roads, kay KayKit Furniture Bits, kcb KayKit City Builder Bits, mre Office Low Poly Pack.
