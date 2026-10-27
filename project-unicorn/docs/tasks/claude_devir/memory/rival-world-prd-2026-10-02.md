---
name: rival-world-prd-2026-10-02
description: "Rakip dünyası yönü (Erdem 2026-10-06 son hâli): SOS olsun, çekirdek değil; Nasdaq benzeri Piyasa penceresi + hafif sektör rakipleri + 2010'da başlayan dönem/AI devrimi birlikte tasarlanır; görev YOK; v4 ve v5 ağır bulundu"
metadata:
  node_type: memory
  type: project
  originSessionId: bdb8d661-b2cc-40d3-a6eb-43f58d809039
  modified: 2026-10-06T21:50:01.268Z
---

**Tarihçe.** v4 (`c706349`, 2026-10-02) ince bulundu → iki araştırma turu → v5 (5.812 satır, M1–M3 "X'i yakala"
görevleri, rakip defteri, 42 karar; sayfa https://claude.ai/artifact/1fDUAteSJNZMXkesyWAXVz). **v5 de reddedildi
(2026-10-06):** "bu kadar detaylı çalışılmasına gerek var mı; rakip dünyası oyuna bir sos katsın, core mekanik olmasın;
verdiğin kısımlar (dünya tarafı) sığ geldi". v5 commit EDİLMEDİ (yalnız çalışma ağacında / scratchpad `rival_page/prd.md`).

**Erdem'in istediği (bağlayıcı, 2026-10-06):**
1. **Piyasa penceresi** (raydaki yeni sekme): Nasdaq listesi gibi en değerli şirketler. Sektörden bağımsız uydurma devler
   (Apple/Amazon/Nvidia benzeri) + bizim sektörden 15–20 irili ufaklı şirket. Halka açıkların değeri ve hisse fiyatı,
   dinamik değişen değerler ve büyüme grafikleri; kurucu/CEO adları (uydurma); halka açık olmayanlar hakkında az bilgi.
   Amaç oyuncunun kendine hikâye kurması ("Amazon'dan değerli olacağım", "net servetim X'i geçecek"), oyun hedef VERMEZ.
   Oyuncu listede **Seed turuyla değerleme oluşunca** görünmeye başlar. Hisse alma / küçük şirkete yatırım sonraki perdeler.
2. **Sektör rakipleri hafif:** ürünlerini kendileri geliştirir; **satış toplantısında** müşteri "X'te bu özellik var, neden
   sizi seçelim?" der → söz ver (özelliği yapacağız) / fiyat kır / başka yoldan sat; **özellik kararında** rakiplerin ne
   yaptığı biraz önemli. Rakip olayları hafif.
3. **Görev YOK** (Frank ya da yatırımcıdan "şu şirketi geç" yok). Senaryo ve öğretici görevleri ileride.
4. **Dönem birlikte tasarlanır:** oyun ~2010'da başlar, oyuncu 8–10 yıl oynar, sonra AI devrimi gelir ve şirketler AI'lı
   ürüne yönelir; Ar-Ge ağacı yıllarla genişler (araştırma, kendi modelini geliştirmek, AI'ı ürüne entegre etmek).
   Gerekçe: 2026'da startup'ın AI modeli geliştirmesi gerçekçi değil (maliyet, tatmin). Demo 104 hafta ile çelişir → karar.

**Durum 2026-10-06:** araştırma workflow'u `wf_57bdad19-1a8` eski hesabın haftalık sınırına takıldı; Erdem hesabı
değiştirdi (aynı yerel oturum, yeni köprü session_017zvx1YwgyJDNGVtneXyqUf). Biten 3 rapor `scratchpad/piyasa_research/`
(market_ui, real_timeline, objections). **Sesli mesajla brief inceldi:** ~50 büyük şirketlik Piyasa listesi (CEO adı,
değerleme; hisse fiyatı gösterilsin mi → araştırma karar verir); sektörden 5–6 rakip (SAP benzeri dev listede yüksekte,
birkaç küçüğü listenin dibinde, en az biri bizim gibi görünmez/özel); rakipler ürün geliştirir/satar/işe alır/çıkarır,
manşet + seyrek event (müşterimizi çelme, layoff, Ar-Ge kumarı, AI'a geçiş); oyuncuyu BOĞMASIN; "en iyi rakip sektörün
kalite tavanını belirler" fikri değerlendirilecek (bağlayıcı değil); perde 3'e ölçeklenme ZORUNLU (hisse alma, rakip
satın alma, güç zehirlenmesi; referans oyun: Plutocracy) ama şimdi trading yok; dönem 2000'ler YA DA 2010'lar (ikisi de
açık). Yeni workflow `wf_4406d0ae-818` TAMAMLANDI: 3 rapor + **tasarım önerisi `scratchpad/piyasa_research/proposal.md`**
(era_games.md, market_model.md, code_map.md yanında). Önerinin özü: dönem 2012-01-05 Perşembe başlangıcı (kod herhangi
bir Perşembe'yi kabul ediyor; AI devrimi ~10-11. yıl; demo = 2012-13 dilimi, AI yalnız ayak sesi; tam oyun perde 2+
`days_per_tick` kabalaşır), Piyasa ~50 şirket (değer = yıl çapaları + sektör endeksi + deterministik gürültü + ShockLog
şokları; hisse fiyatı GÖSTERİLMEZ, `shares_outstanding` gizli rezerve; özel şirket yalnız tur duyurusuyla; oyuncu
Seed post-money ile girer — `seed_round_system.accept` bugün post-money SAKLAMIYOR, `PER_NO_VALUATION` strings:337
çelişkisi düzeltilecek), rakipler 6 kişilikli slot + takvim üreteci (ekonomi defteri yok), kalite tavanı ADAPT (lig içi
lider çıtayı belirler, dev değil: kompozit 285 vs <110), artırım sırası I1 Piyasa → I2 rakipler → I3 dönem göçü (kendi
task'ı) → I4 Kişiler/net servet sekmesi. Kod iddiaları oturumda doğrulandı.

**Erdem'in kararları (2026-10-06 akşam):** (1) dönem **2012** (5 Ocak Per); (2) tempo **dilim** (demo 2012-13, AI yalnız
ayak sesi; tam oyunda tik kabalaşır); (3) **Piyasa listesi YALNIZ halka açık (IPO'lu) şirketler** — "daha gerçekçi olur
hem tüm rakipleri o listeye sokmayız"; özel şirketler listede YOK (turları şerit haberi), oyuncu Seed sonrası sabit
karşılaştırma satırıyla görünür (önceki "Seed'le listede görünür" cevabıyla uzlaştırma; IPO ilerideki perdelere hedef
olabilir — Erdem'e açıkça yazıldı, itiraz etmedi mi kesinleşir); (4) kalite çıtası: ne dev-belirler ne bugünkü sistem —
**"bugünkü sistem de çok kötüymüş; iyi bir sistem araştırması yapın, en ideal hesaplamayı bulun"** → beklenti/kalite
çıtası ayrı araştırma görevi (Kano/table-stakes + Capsim drifting ideal + kod haritası) başlatıldı.

**Kalite çıtası kararları (2026-10-06 gece, Erdem):** kaynak **C "Saat + Yayılım"** (yazarlı tarihli piyasa saati
`market_bar.json`; lig çoğunluğu M=⌈lig/2⌉ tarihi en çok 26 hafta öne çeker, 12 hafta gecikmeli; yeni dönem yeteneği
18 ay muaf; faz tablosu + rival_bump EMEKLİ; telgraf 8 hafta önce); **Güçlü = beklenti+1 YA DA liderle başa baş**
(Gelir'in hiç Güçlü okuyamaması düzelir — bugünkü word_for'da strong=expect+1 tavan yüzünden ulaşılmazdı, koddan
doğrulandı); **B2C aşınma bağlanması SONRA** (ayrı artırım, kalibre küme bozulmaz). Çıta I2 ile iner, I3 2012'ye
yeniden çapalar. Araştırma `scratchpad/quality_bar/` (proposal + 3 rapor).

**v6 YAZILDI 2026-10-07 (`wf_298d9c6a-ead`: yazar + 2 inceleme + düzeltme):** `docs/tasks/PRD_RAKIP_DUNYASI.md`
**777 satır** (v5 5.812'ydi), çalışma ağacında, **commit Erdem onayı bekliyor**. Bölümler: §1 karar defteri A-F ·
§2 Dönem 2012 (`tick_epochs` parçalı takvim) · §3 Piyasa ~42 halka açık satır (katalog kaydedilmez, I1 şema artırmaz;
`seed_post_money_m` kalıcılaşır) · §4 hafif rakipler (lig tek tanım: M=3, lider sabit slot 1; gizli özel yüzeye çıkana
dek hiçbir yüzeyde yok; itiraz 4 cevabı mevcut fiil, tek yeni tür `VERB_PRICE`) · §5 çıta (muafiyet yalnız `avail`
taşıyan satırlar; kelime hat bazında `area_word`) · §7 39 madde doğrulama · §8 tek [ÇD] tablosu · Ek A marka taraması
belgeye taşındı. Persona→slot eşlemesi v5'ten DEĞİŞTİ (slot 1=lider Merivel, 3=fonlu Halvero, 5=kopyacı Stokdar).
**Erdem'in gözü gereken 3 nokta:** (1) itiraz öznesi yalnız slot 1-2; (2) `funding_round` kartı lidere hedeflenince
"halka açık şirket tur aldı" çelişkisi — kopya/hedef onay bekliyor; (3) `finance.valuation` kapanışı + tüm [ÇD]
sayıları. **Erdem v6'yı ONAYLADI 2026-10-06 gece** ("implementasyona geçilebilir") tek değişiklikle: **adlar PARODİ olacak (karar G)**
— uydurma adlar beğenilmedi; gerçek şirket/kişilerden uyarlanmış, tanınır ama birebir olmayan kelime oyunları (GDT
Mirconoft/Ninvento, GTA tarzı). Kapsam kararları: (1) HER ŞEY parodi (devler + kurucular + sektör rakipleri; sektörde
global emsaller parodilenir — SAP/Evernote/Notion/CapCut çevresi; gerçek KÜÇÜK Türk firmaları parodilenmez); (2) büyük
listede Türk devi YOK, yalnız global; (3) tarz karışık, espri başına; adaylar tuvalde Erdem'e sunulur, o seçer; tarama
Erdem seçiminden SONRA yapılır (bütçe), taranmamış ad kataloğa/Ek A'ya yazılmaz. Eski taranmış uydurma setler yedek.
Plan: Adım 0 PRD parodi düzeltmesi + commit → P1 parodi katalog (üret → tuval → seç → tara) → P3 Piyasa maketleri →
P4 taban ölçümü (paralel) → I1 (C1 katalog+değer fonksiyonu · C2 seed_post_money+finance.valuation · C3 ray sekmesi+
pencere · C4 şerit+probe+belgeler). Menajer F10+ beklemede, Erdem isteyince.

**Adım 0 TAMAM:** v6 + karar G **commit `74d873f`** (push yok; 804 satır). §9 incelemesi 6 MAJOR + 10 MINOR buldu,
hepsi uygulandı; kritik yenisi: **parodi ad gerçek markayı ALT DİZE olarak taşıyamaz** (`lint.gd FORBIDDEN_TERMS`
:344-348 "notion/sequoia/a16z/salesforce…" yayın engeli; GDD ch14 §6) — P1 adayları buna karşı elenir ("Notionary"
tarzı adlar yasak). Bir gerçek hedef yalnız bir parodiye gider (Oracle çifte parodilenmez). Kadro yeniden adlandırması
üç alt-türde de I1'de. P1 üretim workflow'u `wf_ba32e588-801` + P4 taban (33 koşu, `scratchpad/p4_baseline/`) koşuyor;
**P1 tur 1 kataloğu REDDEDİLDİ 2026-10-07** ("rezil olmuş çok kötü"): devlerde Türkçe karakter/isim ve TR mizahı
(Elmac, Cevat Bezirgan, Duvarmart, Vıdıfon, Makdonat…) kabul edilmedi. **Yeni kayıt (karar G düzeltmesi):** devler,
kişiler ve fonlar YALNIZ uluslararası/ASCII adlar; ad önce gerçek bir şirket/kişi adı gibi okunur ("haber başlığı
testi", HBO Silicon Valley'nin Hooli'si / GDT'nin Mirconoft'u kaydı), espri ikinci bakışta; TR mizahı yalnız yerel
dokuda (yedek uydurma setler). Tur 1'in uluslararası register'a oturan adayları (Tensora, Winmill, Nostradata,
Fossilux, Ozapft, Evermammoth, Baytoven…) havuzda kalır. Tur 1 verisi `scratchpad/p1_names/`; tuval
https://claude.ai/artifact/Q4i8vPKBNsrwehuWDmn7yH tur 2 kataloğuyla güncellenecek.

**Oturum devri 2026-10-07 gece (bdb8d661 → deba1d13):** tur 2 workflow'u (`wf_799fc749-184`) oturum kapanırken
yarımdı: devler/sektör/fonlar tabloları bitti (yeni scratchpad `p1r2/{devler,sektor,fonlar}.md`), dolgu ajanı 10 dk
düşünüp kesildi, birleştirme hiç koşmadı. Devam workflow'u `wf_d1af1aef-f8a`: dolgu yeniden + her kümeye 2 eleştirmen
(kayıt/haber başlığı · tanınırlık) + birleştirici (collisions alanı tuvalin çakışma uyarısını besler). Tuval hattı
`p1r2/{parse,gen}.py` + `template.html` (seçim anahtarı v2, sayaçlar hesaplanır). **P4 ilk koşusu 33/33 düşmüştü:**
F9'un koyu ikonlarının `.ctex`'i yoktu (headless tema yüklemeden çöktü) → `--import` + ısınma sonrası yeniden koşu
`deba1d13/scratchpad/p4_baseline/` (+`digest.py`); koşu ~40 sn. Bulgu: `full_run_naive` ≡ `full_run` bayt-aynı
(retention kartının satır sırası tercih sırasıyla çakışıyor → naive preset ölçmüyor); bugünkü probe'da kelime ve
toplantı kayıp nedeni satırı YOK (P4'ün o iki kalemi I2 öncesi harness satırı ister).
**Tur 2 tuvali YAYINDA 2026-10-07 04:45 (sürüm 3, aynı link Q4i8vPKBNsrwehuWDmn7yH):** 74 hedef · 162 şirket + 45 kişi
adayı · 17 çakışma grubu; birleştirici 73 aday attı, 34 ⭐ taşıdı, 34 aday ekledi; iki boşluk turu (`wf_bde3b89e-2ad`,
`wf_a3c07352-626`) tek adaylı 8 hedeften 7'sini doldurdu, **AT&T tek aday kaldı** (Atwater Telephone; 8 aday denendi,
en yakını Mabel Networks). **Tur 1 sayfasının betiği hiç çalışmıyordu** (Oracle kartında tek tırnaklı JS dizesinde
kaçışsız `NetSuite'i`) → Erdem büyük ihtimalle yalnız sohbetteki örnek adları gördü. P4 raporu
`deba1d13/scratchpad/p4_baseline/P4_RAPOR.md` (33/33 temiz). **Sıradaki:** Erdem'in seçimleri → yalnız seçilenlere
marka taraması → Ek A'ya işleme + commit → P3 Piyasa maketleri → I1.

**Erdem 2026-10-07 sabah: "İsim listesi gayet hoş ama sektör aware yap; ilaçlara vs gerek yok; IPO için 3-5 banka
tut, gerisi tech; bir sonraki fazla devam et."** → Liste yeniden kuruldu (karar H, PRD'ye işlenecek): ilaç/telekom/
perakende/havacılık/petrol(Exxon)/holding(Berkshire) ÇIKTI; finans = JPMorgan, Goldman, Citi, Visa + Morgan Stanley
(2012 Facebook IPO aracısı, yeni); teknoloji dolgusu 27 yeni hedef (Cisco, Qualcomm, AMD, HP, Dell, Nokia, Xiaomi,
Yahoo, eBay, PayPal, Baidu, Alibaba, Tencent, LinkedIn, Twitter, Zynga, Groupon, Snap, Spotify, Uber, Airbnb, Dropbox,
ServiceNow, Palantir, Shopify, Square + Sony/Samsung/IBM/Adobe kaldı); 2012'de halka açık olmayanlar `listed_year`
ile sonradan listeye girer (dönem olayı). Workflow `wf_301ec689-6d8` (2 üretici × 2 mercek + birleştirici).
**Tuval sürüm 4** (83 hedef · 177 şirket + 65 kişi); ⭐'lar seçim sayıldı (Erdem "gayet hoş"); Oracle varsayılan
"ayrı şirket" (NetSuite 2012'de bağımsız halka açık: tarihsel olarak doğru). AT&T artık listede yok (sorun kapandı).
Kataloğun bütün üretimi `deba1d13/scratchpad/p1r2/` (catalog.md = nihai; splice_r3.py, scan_targets.py).
**KOŞAN:** marka taraması `wf_b2b4a971-985` (129 ⭐ ad, 8'li 17 parça, çakışma → doğrulayıcı; betik
`p1r2/scan_workflow.js`) + **P3 maketleri `wf_2d8ece2c-98c`** (yazar→2 eleştirmen→düzelt→2. inceleme; brief
`p3/BRIEF.md`, tohum `p3/seed.json` Nisan 2012 35 listeli satır; grup `docs/mockups/menajer/screens/piyasa/`;
öneriler: ray Finans altı, ikon `rail/rivals.svg` podyum, pencere 1424×928, 11 çerçeve). Sonra: tarama → Ek A +
§3.1 + karar H → commit; maketler → tuval → Erdem onayı → I1.

**2026-10-07 öğle, durum:** Tarama bitti: 129 ⭐ ad, ilk tur 111 temiz / 15 çakışma / 3 belirsiz; yeniden deneme +
yeni aday turları WebSearch bütçesi (200/oturum) TÜKENDİKTEN sonra koştu ([[websearch-session-budget]]) → kanıtsız
hükümler "belirsiz (kanıtsız)". ⭐ taşımaları (`p1r2/moves.json`; Erdem onayı bekler): Pomelo→Malus, Winmill→Fenstra,
Loupe→Mutely, Quillcom→Dragonwell Semiconductor, Paybuddy→Chequemate, Baisou→Baiyun, Dotify→Jukewave,
Nowdesk→Instanter Systems, Tenon→Joinery, Montara→Cutaway; geçici: Glimpse→Blipframe, Lutkens→Luedecke,
Rhombus→Tapworth, Plainly→Monoline, Reverie→Velvetbank, Fountainhead→Zeroth Capital; çözümsüz çakışma: Basalt
(Obsidian), Kinomeister (KineMaster) → tuvalde yeni seçim. erp slot 1 hedefi NetSuite'e çevrildi (2012'de bağımsız).
PRD: karar H + §3.1 (30 dolgu + 5 finans, ~48) + §7/§9 sayıları + A.1 eşik cümlesi + Ek A.2-A.4/A.7/A.8 (49 satır,
"Listede (yıl)") /A.9 (taşımalar, sahip kararı listesi 12 ad, açık işler) yazıldı; §9 ilk inceleme 2 BLOCKER + 8 MAJOR
→ hepsi uygulandı; ikinci inceleme M3/M4/M7 kalanlarını buldu, kapatıldı → **COMMIT `ce0b3bb`** (push yok; A.8 49 satır, 17 sahip-kararı adı, 2 çakışma tuvalde). Üretici `p1r2/ek_a_gen.py`
(idempotent, A.2-A.9'u yeniden yazar). Tuval P1 sürüm 7. **P3 maketleri HAZIR:** `docs/mockups/menajer/screens/piyasa/`
11 PNG (r3 = tarama sonrası adlar), workflow `wf_2d8ece2c-98c` (1 BLOCKER + 5 MAJOR + 13 MINOR → ikinci incelemede
açık yok), INDEX.md 27 yeni anahtar + 16 sahip kararı; tuval **https://claude.ai/artifact/Xy3WzHq8GmbrHzcWR7YKSt** (`p3/index.html` + frames/*.png; üretici `p3/canvas_gen.py`).
Yazarın 6 sorusu tuvalde (ray yeri, pencere boyu, fiyat sütunu, oyuncu şeridi, filtre çipleri, detay paneli).
Seed değerlemesi tohumda $4,2M sabit (PRD formülü ~$0,8M verir); kuyrukta $10-30M'lik erp küçüğü yok → sıra ~#36.
**P3 İLK SET REDDEDİLDİ 2026-10-07 öğleden sonra** ("gelişigüzel; sıra gösterme yanlış; sade ama rafine istiyorum",
bkz. [[feedback-design-research-first]]). Yön workflow'u `wf_56e25b4c-d14`: 4 yön × tek kare
(`screens/piyasa/directions/dir_<endeks|merdiven|harita|sade>.png`) + eleştirmen; ortak kayıt: oyuncuya sıra YOK
(yalnız değerleme), fiyat sütunu YOK (karar C'ye karşı, onay bekler), 4H%/kıvılcım listede YOK, yoğunluk yarı.
Erdem yön seçince tam set yeniden çizilir; 11 karelik ilk set yalnız referans. **Yönler çizildi:** A endeks sayfası (serif
dönem cümlesi + sebepli hareketler iyi, 4 sütun yine yoğun), B değer merdiveni (fikir en oyuna ait: boş Trilyon
çizgisi + oyuncuyla liste arasındaki boşluk; icra kelime bulutu), C piyasa haritası (ölçek en iyi: "senin
değerlemenin 133 bin katı"; köşe kırık, sektör renkleri SPEC'e aykırı), D sade liste (en rafine: Zirve 5 + Liste,
sağda hikâye kartı, oyuncu altta sessiz). Benim ve eleştirmenin kanısı: **D omurga + A'nın dönem cümlesi ve
3 sebepli hareket + C'nin oran satırı + B'nin "trilyonluk şirket henüz yok" cümlesi.** Erdem'in seçimi bekleniyor
(tuval aynı URL'de güncellendi). **Erdem yönleri de yetersiz buldu: "rakip oyunların ekranlarını incelediniz mi???"** →
referans workflow'u `wf_ae9d81ae-8e5` (arama bütçesi yok; Steam `api/appdetails?appids=` galerileri, Capitalism Lab
sitesi, FM resmi site, headless Chrome ile cmc/Yahoo): **37 gerçek ekran** `deba1d13/scratchpad/refs/<küme>/`
(capitalism 7 · tycoon 5 · strategy 5 [Plutocracy gerçek appid 754500] · sports 8 · finapps 4 · wiki 8); kalıp
raporu `p3/wf_refs.json` (pat). Pano tuvalde sürüm 3 (aynı URL, `p3/refs_index.html` + refs_pub/r00-36.jpg).
En iyi referanslar: Startup Company Competitors (3 sütun, logo, ilk 3 büyük, oyuncu listenin DIŞINDA kart),
Plutocracy Stock Exchange (liste→koyu grafik kutusu→işlem, dönem malzemesi), Motorsport Manager Team Select
(logo kart şeridi + "Best in Championship" referans çizgisi), Offworld lig tablosu (2 sütun, sayfanın %10'u),
cmc detay (2×3 büyük sayı/küçük etiket). **Erdem'in işaretleri (2026-10-07):** 37'den yalnız 2 beğeni, ikisi de ŞİRKET RAPOR KARTI/PANO (liste değil):
r08 Startup Company "Website Stats" (kahraman sayı → etiket:değer listesi → altta grafik, üç sütunlu kart + kadran) ve
r14 Plutocracy "Finances" (üç koyu KPI karosu + mini çubuk sparkline, dönem sütunlu kıyas/ağaç tablosu, kadranlar).
Çıkarım: Piyasa = pano + rapor kartı; liste yalnız kartı açan kısa yol. Yön workflow'u `wf_60071f8a-ede` (p3-piyasa-rapor-karti; ilk koşu brief içindeki ters tırnak yüzünden düştü, düzeltilip resume edildi):
V1 liste(420)+rapor kartı(940) + üstte 3 KPI karosu (Liste değeri / Lider / Senin değerlemen) · V2 sekmeli şirket
sayfası (Özet·Yıllar·Benzerler; KPI karoları + yıl/olay kıyas tablosu + kadran + 5Y grafik). Çıktı
`screens/piyasa/directions/rk_v1|v2.png`. **V1/V2 çizildi:** V1 (liste + rapor kartı) yine liste dili → ret beklenir;
V2 (sekmeli şirket sayfası: ‹ Liste, Özet/Yıllar/Benzerler, 3 karo, yıl satırlı kıyas tablosu, kadran, tam genişlik
grafik) referanslara en sadık ama oyuncu karosu yok, 2. karo mükerrer, grafik tabloyla çelişiyor (2008 $76B vs ~$190B).
Eleştirmen + ben: V2 iskeleti + V1 "Senin değerlemen" karosu + 3-4 satırlık dönem kıyası (ağaç/yıl cümlesi yok) +
tutarlı grafik = **V3** (`wf_8f9b14fc-2e9`, `rk_v3.png`; eleştirmen 7/10, veri tutarlı, benim önerim).
V3 açık kusurları: "Sıradaki şirkete fark" satırı sıra kavramını geri getiriyor + yetim ▲; tablo altı ~100 px boş;
iki karonun çubukları sentetik rampa; karo/tablo mükerrerliği. Tuval sürüm 5 (aynı URL): V1/V2/V3 + iki referans,
`p3/rk_canvas.py` + `rk_merge_v3.py`. **ERDEM V1'İ SEÇTİ (2026-10-07 akşam): liste + rapor kartı** (benim tahminim V3'tü; yanıldım — master-detail
istiyor). Tam set workflow'u `wf_7f22b2b4-9ec` (p3-piyasa-v1-tam-set): V1 düzeni dokunulmaz, yalnız 5 kusur kapanır (grafik =
tablo çapaları, "LİDER · MALUS" caps, kadran 6 px, CİHAZ tag sentence case, oyuncuya sıra yok); 9 çerçeve
(liste/seed_oncesi/series_a/detay_sektor/filtre_sektor/ipo/1536/liste_en/renk_koru), eski set rounds/r3_rejected/,
INDEX yeniden. **Set HAZIR 2026-10-07 akşam:** 9 PNG `screens/piyasa/piyasa__*.png` (r5), eski set
`rounds/r3_rejected/`, araçlar `tools/gen_v1.py` + `tools/render_v1.sh`; incelemede 0 BLOCKER / 3 MAJOR / 11 MINOR →
hepsi kapandı; ikinci incelemede tek açık MAJOR: series_a karesinde Lider karosunun 13 haftalık çubuğunda tek çentik
(gen.py series() 4 haftalık pin'i, hafta 72). 20 yeni anahtar (EN önce) + PER_NO_VALUATION metni PRD §3.5 ile aynı;
INDEX'te 8 açık sahip kararı. Tuval `p3/canvas_gen_v1.py` → `v1_index.html` (4 soru: onay, fiyat sütunu/karar C,
filtre çipleri, Seed tabanı $4,2M vs formül $0,8M). **ERDEM ONAYLADI 2026-10-07 gece: "Onay, I1'e geç".** Üç karar: **fiyat listeye döner** (karar C kalır; maket
güncelleniyor), **çipler her karede kalır**, **Seed formülü kalır** (maket $0,8M gösterir; tam-milyon yuvarlama [ÇD]).
Maket güncelleme workflow'u p3-piyasa-v1-kararlar; PRD §3.4/§3.5/§3.8 kararlarla güncellenip commit'lenecek; sonra
**I1 kodu** (C1 katalog + değer fonksiyonu · C2 seed_post_money + finance.valuation · C3 ray sekmesi + pencere ·
C4 şerit + probe + belgeler), her parça §9 inceleme → düzelt → hedefli smoke → görsel kabul (--tab-shot) → commit. Maketler r6 (fiyat sütunu, çipler, $0,8M) tuval sürüm 6. PRD §3.4/§3.5/§3.8 + §9 inceleme (5 MAJOR
kapandı) → **COMMIT `ec84952`** (push yok). **I1 C1 COMMIT `69d21c0`** (wf_97205f26-9f5, 61 dk; 56 şirket + 46 kişi JSON, MarketCatalog 217 satır, GameState 3 alan,
7 market_ smoke; sabitler onay bekliyor: sigma_giant 0,05 / smallcap 0,14 / market 0,03, knot 4 hafta, doku eşiği
0,004, fiyat bandı $10-1300; **sahip sorusu: Bitwaltz (video_clip dev) halka açık/2010 kurgusuyla yazıldı** (PRD
§3.1 sektör devi halka açık; gerçek emsal özel), 17 provisional ad; delisted_week/parent_company_id/cash_hint/ln S
I3'e). **C2 COMMIT `b131255`** (41 dk; seed_post_money_m + POST_MONEY_STEP_M 0,1 [ÇD] + get_valuation_m, finance.valuation
seam, PER_NO_VALUATION EN + PER_VALUATION_ROW (TR/EN onay bekliyor), Kişisel satırı "$800K" (C3'te $M biçimine
geçer), 3 valuation_ smoke; 33/33). **C3 TAMAM** (wf_55522f04-b41, 133 dk; commit ajanı smoke bitmeden kesildi → kapı logu "GATES DONE, smoke 20/20"
bekledikten sonra 17 yolu BEN commit'ledim; ağaç c4e7a766 bayt-aynı): PiyasaTab.tscn + piyasa_tab.gd, UiTokens.TABS
piyasa, assets/icons/rail/piyasa.svg, window_layer SPECS 1424×928, Fmt.money_market ($M/B/T bantları), MarketTile,
ChipFilter varyasyonları (build_theme + iki tema), CLAUDE §12 `--tab-shot=piyasa[:durum]` + `--theme-audit=piyasa`,
PIYASA_* + PIYASA_ABOUT_* anahtarları TR/EN onay bekliyor. İlk --import segfault → warm1'de autoload hatası, import2+warm2
temiz (import tuzağı). Oyun 2026'da başladığı için liste 2025 çapalarını gösteriyor (I3 2012'ye çeker). Sahip soruları:
1536 kompaksiyon vs kaydırma; Tümü grafiğinin başlangıç yılı; kadran <%1 ondalığı; money_market bant kuralı
(9,5–9,94 ondalıklı, 10+ tam); Sektörüm çipi ürün tipi yokken gizli; provisional adlar. **C4 TAMAM `b241411` (2026-10-07):** uygulama ajanı Fable limitinde kesildi (kapılar yeşil, son kareler alınıyordu); yardımcı yönetmen oturumu (2a632836, Opus) devraldı: Sonnet §9 incelemesi (0 BLOCKER/MAJOR, 9 MINOR düzeltildi), bozma testi, kapılar yeniden, commit. **I1 TAMAM (C1-C4), push yok.** Açık sahip kararı: piyasa sebep satırları sektörü okumuyor; `Rival.company_id` okuyucusuz (I2 Ürünleri okuyacak). I1 hattı: `deba1d13/scratchpad/i1/i1-part.js` (args {key, job,
done}) + `i1/jobs.md` (C1-C4 iş tanımları). Helper'lar 0e406678 scratchpad (gd.sh, f3/*.sh). Bulunamayan: Big Ambitions
(appid yanlış), Software Inc wiki (WAF), Fandom (Cloudflare).

**How to apply:** Rakip işinde mekanik derinlik değil DÜNYA derinliği (dönem, piyasa, şirketlerin hikâyesi) iste; rakip
mekaniği hafif kalsın. Görev sistemi önerme. Önce referans araştırması ([[feedback-design-research-first]]); GDD'yi
değiştiren dönem kararları sahibe sorulur (CLAUDE §2).


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Rakip Dünyası yönü](rival-world-prd-2026-10-02.md) — SOS yönü; **v6 PRD commit `74d873f`+`34a50f5` (push yok)**: dönem 2012, Piyasa yalnız halka açık, hafif rakipler, görev YOK, adlar PARODİ (yalnız uluslararası/ASCII); **P1 tur 2 tuvali sürüm 3 yayında 2026-10-07 (Erdem'in seçimi bekleniyor), P4 taban 33/33 temiz**; **I1 Piyasa TAMAM 2026-10-07 (C1 `69d21c0` · C2 `b131255` · C3 `6551024` · C4 `b241411`, push yok)**; sıradaki I2 (hafif rakipler + kalite çıtası)
