# Piyasa · P3 ekran maketleri (grup "piyasa"), kabul edilen yön V1

Piyasa penceresi (PRD_RAKIP_DUNYASI §3) Menajer Masası koyu dilinde, tam kabuk içinde, 1920×1080 (ve 1536×864); bir
çerçeve İngilizce (SPEC §3.4 genişlik geçişi), bir çerçeve renk körü paleti. **Yön sahip kararıdır (2026-10-07):** ilk
11 karelik set ve dört yön eskizi (`rounds/r3_rejected/`, `directions/dir_*.png`) reddedildi; 37 referanstan sahibin
beğendiği iki pano/rapor kartı ekranı (`startup05.jpg` Website Stats kartı + Plutocracy Finances karoları) üzerinden üç
varyant çizildi (`directions/rk_v1..v3.png`), **sahip V1'i seçti.** Sahibin sözleri: "sade ama rafine; bilgi yoğunluğu
az; oyunu yansıtsın; oyuncuya sıra gösterme."

**V1 düzeni (aynen korunur: oranlar, bölmeler, tipografi, karo dili):** pencere 1424×928; başlıkta PİYASA + ay ve tek
cümle bağlam; üstte üç koyu karo (LİSTE DEĞERİ $3,0T ▲ %3,9 + 13 çubuk · LİDER $560B ▲ %11,2 + 13 çubuk · SENİN DEĞERLEMEN
$0,8M, çubuk yok); solda **460 px** kısa sıralı liste (üstte tek satır filtre çipi Tümü · Teknoloji · Finans · Sektörüm,
36 px + 12 boşluk; satırda sıra ink-4 · ad + altında sektör · **hisse fiyatı** ink-2 küçük punto · değer sağa yaslı; ilk 3
büyük punto; **11 satır**; altında "ve 24 şirket daha"); sağda seçili şirketin rapor kartı (ad + sektör etiketi +
Kurucu/CEO, sağda "Halka arz 1980"; üç bölme: kahraman değer + "Piyasa değeri · Nisan 2012" + ▲ %11,2 dört haftada | yıl
sonu etiket:değer 5 satır | yarım daire kadran "Listedeki payı %19"; DEĞER + 13H·1Y·5Y·TÜMÜ segmenti + tek 5 yıllık
grafik; HAKKINDA iki cümle). Fiyat yalnız listede; kartın kahraman sayısı değerdir.

**Sahibin üç set kararı (2026-10-07, r6):** (1) fiyat listeye döndü (PRD karar C: fiyat VE değer): liste sütunu 424 →
460 px, kart o kadar daraldı (kart 964 px; iç genişlik 964 − 1 çizgi − 2 × 32 dolgu = 899 → grafik SVG 934'ten
**898**'e indi, sağ ucu DEĞER çizgisiyle ve "Halka arz" yuvasıyla aynı hizada); satır ızgarası `36 sıra · 1fr ad · 76 fiyat · 88 değer`, sütun
aralığı 8, sol dolgu 24, sağ 16 (ad sütunu 196 px: "Dragonwell Semiconductor" 15 px/600'de tek satırda, elips yok);
fiyat sütunu ink-2, tabular, ilk 3 satırda 15 px (değer 18), diğerlerinde 13 px (değer 15); TR "$595,74" / EN "$595.74"
(`gen.price` + `n()`); halka arz satırında Facewall $49,52 (104B / 2,1B hisse). (2) Filtre çipleri her karede:
36 px satır + 12 boşluk; 1080'de liste 703 px'e 12 satır (728) sığmadığından 11 satır + "ve 24 şirket daha"; 1536'da 7
satır + "ve 28 şirket daha"; seçili çip ink kenar + surface-4, `filtre_sektor`'de Sektörüm, öbür karelerde Tümü.
(3) Seed karosu PRD §3.5 formülünün değerini basar: post-money = tutar × 100 / pay = $130K × 100 / 16 = $812,5K →
"$0,8M" / "$0.8M", açıklama "Seed sonrası · Nisan 2012"; Series A $18M.

V1'den kapatılan bilinen kusurlar (rk_v1.png'ye göre): (1) grafik verisi tablo çapalarıyla birebir (2008 $76B · 2009
$190B · 2010 $295B · 2011 $375B · Nisan 2012 $560B; aralar düz interpolasyon + sönen gürültü; yıl etiketleri çapa
noktalarında; rk_v3 `five_year`; tablo ve grafik aynı `table_years` kümesini okur, son 4 yıl sonu); (2) LİDER karosunun
etiketi tek kelime, şirket adı açıklamada "Malus · cihaz · son 13 hafta" (özel ad caps olmaz, SPEC kural 7); (3) kadran
6 px, dolu yay ink-2, kalan yay ink-4, tik yok (rk_v3 kadranı); (4) sektör etiketi tohumun kelimesi yazıldığı gibi
(`text-transform: none`): "cihaz", "kurumsal" küçük harf, kısaltma "ERP" caps kalır (kural 8); (5) oyuncu için SIRA
hiçbir yerde (sanal sıra yok, "~#" yok, "listedeki karşılığın" yok). Düzeltme turlarında eklenenler: grafikte son yıl
çapası bugünün etiketine 100 px'ten yakınsa yıl etiketi kendi tikine sağdan yaslanır ("2011  Nisan 2012" çakışması);
kadranda pay 0,1 %'nin altındaysa yay hiç çizilmez (6 px yuvarlak uçlu kısacık yay nokta gibi okunuyordu), sayı "<%0,1"
değeri taşır; kadran SVG metni `html.escape` ile yazılır (`&lt;%0,1`, HTML geçerli).

- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, A2 ikonları, üst bar ızgarası; sistem klasörüne
  hiçbir şey yazılmadı (kit kopyaları `tools/syskit/`). Grubun ekleri `piyasa.css` (eski setin paylaşılan kuralları) ve
  `tools/gen_v1.py` içindeki yerel CSS (kt-/rk-/rc-/g- önekli sınıflar).
- **Kabuk kabuk grubunundur** (`gen.py`: `office()`, `topbar()`, `rail()`, `ticker()`). Koşu Per 5 Oca 2012'de başlar
  (PRD §2); üst bar **koşu haftasını** yazar ("Hafta 14 · Nisan 2012", "Hafta 72 · Mayıs 2013"): `gen.py`'nin yıl
  haftası ilk yılda aynı sonucu verir, ikinci yılda vermezdi; `gen_v1.py` `date()`'i koşu haftasıyla ezer.
- Pencerede amber YOK (tek amber kabuğun hız tuşu), kırmızı YOK (düşüş mürekkep + U+2212), belge motifi YOK (pencere
  mobilya), tire YOK, caps yalnız ≤3 kelimelik etiketlerde, veri yoksa hücre BOŞ (kural 9).

Yeniden üretmek: `python tools/gen_v1.py` (HTML'ler `build/`, `*_en` İngilizce; `--sizes` çerçeve boylarını basar),
`bash tools/render_v1.sh <tur> [ad ...]` (PNG'ler bu klasöre, kopyası `rounds/<tur>/`; boylar `gen_v1.py --sizes`'tan).
Paralel: `python tools/gen_v1.py --sizes | cut -d' ' -f1 | xargs -P 3 -I{} bash tools/render_v1.sh <tur> {}`.
Turlar: r1, r2 (reddedilen liste+panel seti, `rounds/r3_rejected/` son hâli), r4 (V1 setinin ilk basımı), r5 (inceleme
bulguları kapatıldı), **r6** (bu set: sahibin üç set kararı uygulandı: fiyat sütunu, her karede çip, formül değeri; 9
çerçevenin hepsi tam boy okundu, düzeltme turu gerekmedi). Tur adı "r2" reddedilen setin kopyalarıyla çakıştığı için
V1'in düzeltme turu r5 adını aldı.

## Çerçeveler

| PNG | Boy | Gösterdiği | Tohum / kurgu |
|---|---|---|---|
| `piyasa__liste.png` | 1920×1080 | V1'in kendisi, Seed SONRASI: TRACTION kabuğu, kasa $418.000; üçüncü karo $0,8M "Seed sonrası · Nisan 2012"; çip satırı Tümü seçili; liste 1–11, her satırda fiyat ($595,74 · $31,55 · … · $1.292,52 Samdal · $34,48) + değer, "ve 24 şirket daha"; kart Malus. | `TOP_SEED`; `seed_amount_k` 130 @ `seed_equity_pct` 16 |
| `piyasa__seed_oncesi.png` | 1920×1080 | BOOTSTRAP kabuğu (kasa $10.000); üçüncü karo: etiket SENİN DEĞERLEMEN, değer BOŞ (satır yüksekliği korunur), açıklama "Değerleme henüz yok. Seed turunda belirlenir." (mevcut `PER_NO_VALUATION` anahtarının PRD §3.5 metni; kural 9). Liste ve çipler 1 numaralı kareyle aynı. | `TOP_THEME` |
| `piyasa__series_a.png` | 1920×1080 | SERIES A kabuğu (kasa $330.000, MRR $125K), üst bar "Hafta 72 · Mayıs 2013", başlık bağlamı "Mayıs 2013 · Mobil reklam yılı" (dönem satırı yılla değişir); üçüncü karo $18M "Series A · Hafta 72"; liste 36 şirket (Facewall #11 $49,52 · $104B, artık Yeni değil), "ve 25 şirket daha"; kart Malus: yıl sonu 2012 $500B · 2011 · 2010 · 2009, "2012 sonundan beri ▲ %12", grafik 2009…2012 + Mayıs 2013 (tabloyla aynı dört çapa). | **Kurgu:** hafta 72 = 16 May 2013; liste değerleri, fiyatlar ve 4H/13H rakamları Nisan 2012'den donuk (tohum tek hafta; oyunda haftalık yürür), Facewall 4H +%3,0 kurgu; Malus yıl sonu 2012 $500B kurgu (gerçek analoğun yuvarlanmışı) |
| `piyasa__detay_sektor.png` | 1920×1080 | Pythia (ERP, $236M, #35, fiyat $3,37) seçili; liste 25–35 aralığına kaydırılmış (11 satır), üstte "24 şirket yukarıda" ipucu, altta "daha" satırı yok; kart: "Halka arz 2007", kurucu satırı boş (tohumda kişi yok), yıl sonu 2011 $210M · 2010 $170M · 2009 $120M · 2008 $140M · "2011 sonundan beri ▲ %12"; kadran "<%0,1" (0,008 %; eşik 0,1 %, yay çizilmez), grafik 150 px ($100M·$200M·$300M); ek **ÜRÜNLERİ [I2]** bölümü (Defter · Hesap Planı / Fatura · Toplu Fatura / Nakit Akışı · Nakit Akış Tablosu; `PROD_LINE_ERP_*` + `_K2` adım adları) HAKKINDA'nın üstünde: I1 Piyasa salt-okunur teslimine girmez, hafif rakipler artırımında (PRD §4) bağlanır; tek satır Hakkında. | `PYTHIA_HIST` kurgu; halka arz yılı kurgu |
| `piyasa__filtre_sektor.png` | 1920×1080 | Çip satırında **Sektörüm** seçili (ink kenar + surface-4; amber değil); liste 2 satır (Datenwald #14 $66,67 · $80B "kurumsal", Pythia #35 $3,37 · $236M "ERP": sektör kelimesi tohumdan, filtre `group`'tan) + ink-3 satır "Werktag · halka arz Ekim 2012"; kart Datenwald: etiket "kurumsal", "Halka arz 1988", Kurucu Hanno Blattner (CEO boş), yıl sonu 2011 $66B · 2010 $62B · 2009 $58B · 2008 $45B · ▲ %21, kadran %3. | `DATENWALD` yıl sonu kurgu (gerçek analoğun yuvarlanmışı); Werktag `listed_year` 2012 (Ekim, ~H41) |
| `piyasa__ipo.png` | 1920×1080 | Hafta 20 · Mayıs 2012: Facewall $104B listeye girmiş (#11, son görünen satır), satırda "YENİ" tag-neutral, fiyat $49,52 (104B / 2,1B hisse); "ve 25 şirket daha"; LİSTE DEĞERİ $3,1T · 36 şirket; Lider karosu hâlâ Malus; kart Facewall: iskelet öbür kartlarla aynı: sektör "sosyal ağ", başlık sağında "Halka arz Mayıs 2012" (aynı yuva, yıl yerine ay), Kurucu Marcus Sugarhill (CEO boş), kahraman $104B "Piyasa değeri · Mayıs 2012", dört hafta satırı BOŞ (4H yok), yıl sonu bölmesi BOŞ (kural 9; bilgi iki kez basılmaz), kadran %3, grafik 13H segmentinde halka arzdan bugüne 2 haftalık kısa çizgi + "halka arz" işareti. Şeritte "Facewall halka arzı: ilk gün $104B". | `ipo_frame` (H20, $104B); halka arz H18 (2 hafta önce) kurgu |
| `piyasa__1536.png` | 1536×864 ×1,25 | Pencere 1424×712 x 88; kompakt üst bar "H14 · Nis", simge rayı; karolar 100 px (şerit dolgusu 8, karo alt dolgusu 12: açıklama ve çubuklar alt kenardan 12 px, Godot'un %8 geniş metnine pay), bölmeler 128 px, çip satırı + liste 7 satır + "ve 28 şirket daha", grafik 140 px; Hakkında iki satır sığıyor. | Seed sonrası tohumu |
| `piyasa__liste_en.png` | 1920×1080 | 1 numaralı kare İngilizce: MARKET, LIST VALUE, LEADER, YOUR VALUATION, "35 companies · last 13 weeks", "Malus · devices · last 13 weeks", "$0.8M", "Post seed · April 2012", All · Technology · Finance · My sector, "and 24 more", "Listed 1980", "Founder", "Market value · April 2012", "over four weeks", "Year end 2011", "Since end of 2011", "Share of the list", VALUE, 13W·1Y·5Y·ALL, ABOUT; sayılar EN ($3.0T, 11.2%, 19%, fiyat $595.74 · $1,292.52). Taşan kutu yok. | Aynı |
| `piyasa__renk_koru.png` | 1920×1080 | 1 numaralı kare `[data-palette=cb]`: artı mavi (▲ ikinci kanal) karolarda, kartta ve yıl sonu satırında; başka renk yok; fiyat sütunu ink-2 kalır. | Aynı |

## Veri tohumu ve kurgu (`tools/seed.json` + `gen_v1.py`)

- **Adlar:** parodi kataloğu (`seed.json`), oyuncuya görünen metinde gerçek marka yok; lint alt dize listesi temiz.
- **Satırlar:** 35 halka açık (5 finans + 28 teknoloji + 2 sektör: Datenwald, Pythia); Nisan 2012 değerleri. Sektör
  kelimesi her satırda tohumun `sector_tr/en`'idir (Datenwald "kurumsal / enterprise", Pythia ve Werktag "ERP");
  Sektörüm filtresi `group == "sektor"`'den çalışır, kelimeye bakmaz. Türetilenler: LİSTE DEĞERİ = satır toplamı
  (2.973,7B → $3,0T; Facewall'la 3.077,7B → $3,1T), 4H endeksi değer ağırlıklı (Σdeğer / Σ(değer/(1+4H%)) − 1 = +%3,9;
  yeni satır iki toplamdan da düşülür), karo çubukları = satır serilerinin 13 haftalık toplamı (4H pini komşu
  ortalamasıyla düzlenir), Lider çubukları Malus'un çapalı 52 haftalık serisinin son 13'ü.
- **Kart tablosu ve grafik aynı sayıyı söyler:** `HIST` sözlüğü (Malus 2007 $170B · 2008 $76B · 2009 $190B · 2010 $295B ·
  2011 $375B · 2012 $500B; Pythia ve Datenwald kurgu) → `table_years` = bugünün yılından önceki son 4 yıl sonu; yıl sonu
  satırları o dört yıl + "{y} sonundan beri"; `five_year` yalnız o dört çapa + bugün arasında düz çizgi + çapada sönen
  gürültü; bugünün yılı tabloya girmez (`hist_of` filtreler).
- **Fiyat:** her satırın `price`'ı tohumda (değer / hisse; Facewall halka arzda 104B / 2,1B = $49,52 `listed()`'den);
  `gen.price` TR "$1.292,52" yazar, `n()` EN'e çevirir ("$1,292.52"). Yalnız listede; kart ve karolar değer basar.
- **Oyuncu:** Seed post-money **PRD §3.5 formülü** (sahip kararı 2026-10-07: formül kalır, maket küçük sayıyı
  gösterir): tutar × 100 / pay = `seed_amount_k` 130 × 100 / `seed_equity_pct` 16 = $812,5K → `money_m` "$0,8M";
  tohumdaki `seed_post_money_m` 0,8125 aynı sonucun kopyasıdır, yalnız reddedilen yön betikleri (`dir_*.py`, `rk_*.py`)
  okur. Series A $18M. **Sıra hiçbir yerde** (sahip kararı).
- **Halka arz yılları kurgu:** Malus 1980, Pythia 2007, Datenwald 1988; Facewall H18 (Mayıs 2012), Werktag Ekim 2012
  (~H41, Sektörüm filtresinde ipucu satırı). Facewall H72'de "Yeni" değil ve 4H +%3,0 (kurgu).
- **Bağlam cümlesi dönemle değişir:** 2012 "Akıllı telefon dalgası listeyi taşıyor", 2013 "Mobil reklam yılı" (ikisi
  de maket kurgusu; oyunda dönem tablosundan gelir, I3).
- **Şerit:** `gen.py` `news_market()` değişmedi; IPO haftasında ilk satır "Facewall halka arzı: ilk gün $104B".

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

Eski setin anahtarlarından yalnız şunlar yaşıyor: `TAB_PIYASA`, `PIYASA_FILTER_ALL/TECH/FIN/MINE`, `PIYASA_RANGE_13W/1Y/5Y/ALL`,
`PIYASA_TAG_NEW`, `PIYASA_ABOUT_TITLE`, `PIYASA_PRODUCTS_TITLE`, `PIYASA_FOUNDER_KEY`, `PIYASA_CEO_KEY`, `PIYASA_VALUE_TITLE`,
`PIYASA_NEWS_*`, `PIYASA_WHY_*`, `PIYASA_KPI_LIST_VALUE` (List value / Liste değeri; birinci karo etiketi, karar 12),
`PIYASA_COL_PRICE` (PRD'de var; listenin fiyat sütunu, maket başlık satırı çizmediği için ekranda görünmez, Godot
tablosunda sütun adı ve erişilebilirlik etiketi olarak kullanılır).
Emekli: `PIYASA_KPI_YOUR_RANK`, `PIYASA_PLAYER_ROW`, `PIYASA_GAP_NEXT`, `PIYASA_PASSED`, `PIYASA_COL_*` (`PIYASA_COL_PRICE`
hariç), `PIYASA_EOY_*`, `PIYASA_DETAIL_CLOSE`, `PIYASA_PEERS_TITLE`, `PIYASA_COL_RANK_DELTA_TIP*`.

**Metni değişen mevcut anahtar** (yeni değil; `localization/strings.csv:337`, Kişisel sekmesi `personal_tab.gd` de aynı
satırı okur): `PER_NO_VALUATION` · EN "No valuation yet. Your seed round sets it." · TR "Değerleme henüz yok. Seed
turunda belirlenir." (PRD §3.5 taslağıyla birebir; bugünkü "Series A imzasında belirlenir" metni PRD'ye göre yanlış).

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `PIYASA_CTX_2012` | {month} · The smartphone wave carries the list | {month} · Akıllı telefon dalgası listeyi taşıyor | pencere başlığının dönem satırı: ay + dönem metni; **dönem anahtarlı aile** (koşu yılına göre seçilir, dönem tablosu I3), tek anahtar değil |
| `PIYASA_CTX_2013` | {month} · The year of mobile ads | {month} · Mobil reklam yılı | aynı aile, 2013 (kurgu) |
| `PIYASA_KPI_LEADER` | Leader | Lider | ikinci karo etiketi |
| `PIYASA_KPI_YOUR_VALUATION` | Your valuation | Senin değerlemen | üçüncü karo etiketi |
| `PIYASA_KPI_LIST_DESC` | {c} companies · last 13 weeks | {c} şirket · son 13 hafta | birinci karo açıklaması |
| `PIYASA_KPI_LEADER_DESC` | {name} · {sector} · last 13 weeks | {name} · {sector} · son 13 hafta | ikinci karo açıklaması (özel ad caps değil) |
| `PIYASA_KPI_POST_SEED` | Post seed · {month} | Seed sonrası · {month} | üçüncü karo açıklaması |
| `PIYASA_KPI_SERIES_A` | Series A · Week {w} | Series A · Hafta {w} | üçüncü karo açıklaması |
| `PIYASA_LIST_MORE` | and {c} more | ve {c} şirket daha | listenin altı |
| `PIYASA_LIST_ABOVE` | {c} more above | {c} şirket yukarıda | kaydırılmış listenin üstü |
| `PIYASA_LISTS_IN` | {name} · listing {month} | {name} · halka arz {month} | Sektörüm filtresinde henüz girmemiş rakip; yer tutucu ek almaz (CLAUDE.md §5) |
| `PIYASA_LISTED_YEAR` | Listed {y} | Halka arz {y} | kart başlığı sağı, her kartta aynı yuva; yeni girmiş şirkette {y} ay taşır ("Halka arz Mayıs 2012") |
| `PIYASA_CARD_CAP` | Market value · {month} | Piyasa değeri · {month} | kahraman değerin altı |
| `PIYASA_FOUR_WEEKS` | over four weeks | dört haftada | ▲ %'nin yanı |
| `PIYASA_EOY_FIRST` | Year end {y} | Yıl sonu {y} | yıl sonu ilk satırı (sonrakiler yalnız yıl) |
| `PIYASA_SINCE_EOY` | Since end of {y} | {y} sonundan beri | yıl sonu son satırı |
| `PIYASA_SHARE` | Share of the list | Listedeki payı | kadran altı |
| `PIYASA_SHARE_LT` | <{p} | <{p} | kadran, pay 0,1 %'nin altında ("<%0,1" / "<0.1%"); değer '<' ile başlar, CSV'de düz karakter, ekrana kaçışlı yazılır |
| `PIYASA_IPO_MARK` | listed | halka arz | yeni girmiş şirketin grafiğinde ilk tik |

Hakkında paragrafları (Malus, Pythia, Datenwald, Facewall) parodi dünyası metnidir, maket için yazıldı; kişi adları
katalog ⭐ (Stephan Laborde, Timo Koch, Hanno Blattner, Marcus Sugarhill); özel ad çevrilmez. Ürünleri satırları Ürün
sekmesinin `PROD_LINE_ERP_*` / `PROD_STEP_ERP_*_K2` metinleri ([I2]).

## Sahip kararları

Verilmiş (bu sette uygulandı):
1. **Yön V1** (liste + rapor kartı); oranlar, bölmeler, tipografi, karo dili sabit.
2. **Liste sayfası yok:** liste sol sütunda 12 satır, gerisi "ve N şirket daha" (kaydırma); ayrı tam liste ekranı yok.
3. **"Sıradaki şirkete fark" yok**, oyuncunun sırası yok, "~#" yok, oyuncu şeridi yok: oyuncu yalnız üçüncü karoda.
4. **Fiyat listede** (2026-10-07, PRD karar C korunur: fiyat VE değer): her satırda değerin yanında hisse fiyatı
   sütunu, ink-2, değerden küçük punto; liste 460 px, kart daraldı; fiyat yalnız listede, kart değer basar.
5. **Seed karosu formül değeri** (2026-10-07): $130K × 100 / 16 = $812,5K → "$0,8M"; önceki sabit kurgu değeri kalktı.
6. **Filtre çipleri her karede** (2026-10-07): 36 px satır + 12 boşluk; 1080'de 11 satır + "ve 24 şirket daha",
   1536'da 7 satır; seçili çip ink kenar + surface-4.

Açık (onay bekliyor):
7. **Series A çerçevesi hafta 72'de** (Mayıs 2013): üst bar koşu haftasını yazar; liste değerleri Nisan'dan donuk. Oyunda
   liste haftalık yürür.
8. **Yeni girmiş şirketin kartı:** iskelet sabit: başlık sağında "Halka arz Mayıs 2012" (aynı yuva, yıl yerine ay), yıl
   sonu bölmesi boş (kural 9); grafik 13H. Alternatif (reddedilirse): bölmede tek satır "Halka arz · Mayıs 2012", başlık
   sağı boş.
9. **Pay eşiği:** 0,1 %'nin altı "<%0,1"; alternatif iki ondalık ("%0,01").
10. **Kadran yay tabanı:** pay 0,1 %'nin altında yay hiç çizilmez, sayı değeri taşır (uygulanan). Alternatif: yay
    tabanı ~2 % (görünür kısa yay, sayı gerçek).
11. **Yıl sonu satırı sayısı:** son 4 yıl + "sonundan beri" (bölme 160 px, 5×28). Daha eski yıllar Tümü segmentinde.
12. **İngilizce birinci karo "List value"** (`PIYASA_KPI_LIST_VALUE` çifti List value / Liste değeri; görev metni
    "MARKET VALUE" demişti). "Market value" kart kahramanının etiketi; "Market value" istenirse TR de "Piyasa değeri"
    olur ve kart alt yazısı "Değer · Nisan 2012" gibi ayrışır.
13. Pythia ve Datenwald'ın CEO satırı boş, Facewall'da kurucu = CEO olduğu için yalnız Kurucu yazıldı (kural 9).
14. **Alt tip etiketi:** sektör rakibinin kartında sektör kelimesi tohumdan ("kurumsal"); oyuncunun alt tipi (ERP)
    ayrıca gösterilecekse yalnız kartta ikinci bir tag olur, listede değil. Bu sette çizilmedi.

## Godot notları (öneri)

- **Karo** = `PanelContainer` (surface-4, line-1, r-3) + VBox: etiket `Label` (t-label), değer satırı HBox (`Label`
  Barlow 36 + ▲ % `Label`), alt HBox (açıklama `Label` + 13 çubuk `_draw`: 6 px genişlik, 3 px boşluk, 5–24 px, son
  çubuk ink-1). Değer boşken satır yüksekliği korunur (`custom_minimum_size.y = lh-36`). Başlığın dönem satırı koşu
  yılına göre `PIYASA_CTX_<yıl>` ailesinden (I3 dönem tablosu).
- **Liste** = 460 px sütun; üstte çip HBox (36 px, `Chip` varyasyonu, seçili ink kenar + surface-4), 12 boşluk;
  `HRUiShared` koyu tablo satırı 52 px, ızgara 36 · esnek · 76 · 88 (aralık 8): sıra (t-small ink-4) · ad/sektör VBox ·
  fiyat sağa (ink-2, ilk üçte 15 px, diğerlerinde 13 px, tabular) · değer sağa; ilk üç satır `t-value`; seçili surface-4
  + 3 px işaret; hover kenar. "ve N şirket daha" `Label` ink-3; kaydırma `ScrollContainer`. Sektör kelimesi katalogdan
  yazıldığı gibi (kısaltma caps kalır). Fiyat `Fmt` para biçimi iki ondalıkla (TR "$595,74", EN "$595.74").
- **Kart** = `VBox` (surface-2, sol line-1): başlık HBox (ad Barlow 40 + sektör `Tag` sentence case + "Halka arz", her
  kartta aynı yuva), kişiler satırı, üç bölme `HBox` 160 px (ayırıcılar line-1): kahraman `Label` Plex 40 + iki `Label`;
  `GridContainer` 2 sütun 28 px satır (yeni girmişte boş); **kadran `_draw`**: `draw_arc` R 88, 6 px, ink-4 tam yarım +
  ink-2 pay (pay < 0,1 % ise yalnız ink-4), round cap, tik yok, sayı Plex 26 ortada, altında `Label`. DEĞER satırı +
  `SegTab` (13H·1Y·5Y·TÜMÜ).
- **Grafik** = `cash_curve` kalıbı: `_draw` gridline (chart-grid) + y etiketleri, alan (chart-pos-area), çizgi 2 px
  (chart-line), çapa diskleri ink-4 r 3, son nokta ink-1 r 4 + zemin halkası; x etiketleri çapa haftalarında, son yıl
  etiketi bugünün etiketine 100 px'ten yakınsa tikine sağdan yaslı. Veri: `RivalRegistry` yıl sonu çapaları (tablonun
  dört yılı, aynı küme) + bugünkü değer, aralar düz; yeni girmiş şirkette halka arz haftasından bugüne.
- **ÜRÜNLERİ [I2]:** I1 Piyasa salt-okunur teslimine girmez; hafif rakipler artırımında `line_tiers`'tan bağlanır.
- **1536:** karolar 100 px (şerit dolgusu 8, karo alt dolgusu 12), bölmeler 128 px, çip satırı + liste 7 satır,
  grafik 140 px; kabuk simge kipi.

## Reddedilen setler

`rounds/r1`, `rounds/r2`, `rounds/r3_rejected/` (liste + sağ panel + oyuncu şeridi seti, 11 kare; `build/piyasa__detay_dev.html`,
`piyasa__gecis.html`, `piyasa__seed_sonrasi.html` o setin artıkları), `directions/dir_sade|endeks|harita|merdiven.png`
(dört yön eskizi), `directions/rk_v2.png`, `rk_v3.png` (V1'in kardeşleri; `five_year` ve kadran rk_v3'ten alındı).
`rounds/r4` V1 setinin ilk basımı (inceleme öncesi). Üretici `tools/gen.py` eski setindir; kabuk, tohum ve seri üreteci
olarak `gen_v1.py` onu içe alır.
