# PRD — ÜRÜN REV 7 · SPRINT DÖNGÜSÜ
### Ekranlardan türetilmiş tek belge (C1–C5 · Yön C · 3. tur · Erdem F5)

**Durum:** Kanonik. `TASK_URUN_REV7_SPRINT_DONUSUMU.md` ve `TASK_URUN_REV7_EKRAN_UYGULAMA.md` bu belgeyle değiştirildi; ikisine atıf yapılmaz.
**Girdi:** `docs/mockups/urun_rev7/C1_planlama.png · C2_sprint_ici.png · C3_surum_cikti.png · C4_ceyrek.png · C5_planlama_b2b.png`. Ekrandaki her öge §2'de adıyla var. Yerleşim ve görünüm Menajer Masası koyu dilindedir (Erdem kararı 11): maketler `docs/mockups/menajer/screens/urun/`, ortak kurallar §2.0.
**Okuma sırası:** §1 kapsam ve fazlar → §2 ekranlar (ne görünüyor · nereden geliyor · ne yapıyor) → §3 sistemler → §4 çalışma değerleri → §5–§10 yürütme ve doğrulama.
**Tek cümle:** Oyuncu tek bir ürünü sprint sprint geliştirir; ekrana oturduğunda okumadan görür: neresi zayıf, bu sprintte ne yapılıyor, bu kartı seçersem ne değişir. Sprint sabit iki oyun günü (iki hafta); bitince sürüm otomatik çıkar; bitmeyen kart ilerlemesiyle devreder; iş hiç bitmez.

---

## 1. Kapsam ve fazlar

**Faz A — Ekran (sürüyor).** Görünüm sözleşmesi (`ProductModel` Dictionary), tek kart sahnesi, tohumlar, uç durumlar, MCP kareleri, `product_rev7` bayrağı (varsayılan kapalı). Eski sekme dokunulmaz, silme yok. Bu faz onaylı plana göre devam eder; bu belge onun kurallarını da kapsar.

**Faz B — Sistemler (bu belgenin asıl işi).** §3'teki sistemler; `ProductModel.live()` adaptörü ve eylem bağları; köprüler; save v10 ve taşıma; eski sekmenin silinmesi ve `SWEEP_LIST.md` süpürmesi (GDD taraması + çağıran arama; çağıranı olan kalır); bayrağın kaldırılması. Süre tavanı 12 saat duvar saati; kesme çizgisi §6.

**OUT:** yaşayan rakipler (yol haritası, tepki); teknoloji dalgaları / dördüncü kademe; pazarlama satırı; hotfix eylemi; Tier 3; kişiye elle atama; sürükle-bırak; yeni içerik yazımı (katalog eksiğinde "TODO content"); altyapı sisteminin karta dönüşmesi; 3D beyaz tahta; görsel tema (laboratuvar ayrı); İngilizce metin dışında çeviri işi (EN anahtarları yazılır, onay bekler).

---

## 2. Ekranlar — öge öge

Her satır: **Gösterir** · **Kaynak / kural** · **Etkileşim**. Kart ortak tanımı §2.6'da.

### 2.0 Yerleşim (Menajer Masası)

- **Pencere:** 1424 × 928 (1536 genişlikte 712 boy, sütunlar kayar). Ortak koyu başlıkta ÜRÜN ve iki ölçü: tür anahtarıyla ("B2C · NOT & BİLGİ ARACI") ürün adı ve SÜRÜM ("v1.4"; MVP öncesi "MVP · yayında değil"). Altında denetim şeridi: SPRİNT | ÇEYREK segment sekmesi (PM yokken ÇEYREK kilitli, gerekçesi yanında) ve sağda Geçmiş anahtarı. Tür seçilmeden şerit yoktur.
- **Gövde:** solda alan paneli (430), ortada bu sprint, sağda kesikli kenarlı sonraki sprint. Sütunların başlığı ve alt şeridi sabit, kart yığını kayar. ÇEYREK'te pencere içeriği kadar kısalır.
- **Renk:** alanlar renk taşımaz; alan adı, üç seviye karesi ve kelimeyle okunur (Güçlü olumlu, Yeterli ikincil mürekkep, Zayıf uyarı, Yok soluk). Kırmızı yalnız tehlikedir: kapasite aşımı, Zayıf, yakın son tarih ve "!" uyarı rengindedir, alan satırı boyanmaz. Amber yalnız ekranın tek birincil eylemidir (Sprinti başlat, Sprint N planına geç, Hepsini onayla, Onayla ve başlat).
- **Belge dili:** sprint kartı kesik köşeli küçük bir belgedir; biten kart BİTTİ, canlı sürüm CANLI, onaylı PM sütunu ONAYLANDI damgası taşır. Hover bir kenardır.

### 2.1 C1 — Planlama (Notly, B2C)

| Öge | Gösterir | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Ürün adı | "Notly" | `ProductState.product_name`; başlığın ölçüsü | — |
| Sürüm | "SÜRÜM v1.4" | Sürüm listesinin son kaydı; başlığın ölçüsü. MVP öncesi "MVP · yayında değil" (§3.9). CANLI damgası yalnız sürüm notunda | — |
| Tür etiketi | "B2C · NOT & BİLGİ ARACI" | pazar + `ProductCatalog.type_name`; ürün adı ölçüsünün anahtarı | — |
| Geçmiş anahtarı | kapalı | Yerel UI | Açıkken sol panel üstünde sürüm listesi, en yenisi üstte (vX · Sprint N · çıkan kart sayısı, altında beklenen ya da gerçekleşen); sürüm yoksa "Henüz sürüm yok" |
| SPRİNT / ÇEYREK | SPRİNT aktif | PM yoksa ÇEYREK kilitli, gerekçesi yanında "PM işe alınca"; kesme çizgisi dışında kaldıysa "Yakında" | Görünüm değiştirir |
| ALANLAR · kapalı satır | ad · kareler · kelime · cümle · ses sayacı · rakip bayrağı · uyarı üçgeni | Kare = alan seviyesi (§3.4). Kelime = seviye vs beklenti (§3.4), kelimenin renginde. Cümle = şablon alan × durum × alt-tür; değişkenler: ticket sayısı, rakip. Ses sayacı "n · k yeni" = açık ticket + ses satırları, k son bir sprintte eklenen. Uyarı üçgeni = kesinti olayı açık ya da aynı yetenekte 3+ ticket. "Rakip: mobil" = statik rakip tablosu (§3.3) bu alana son 3 sprintte çıkış yaptı. Satır boyanmaz | Tık: aç/kapat; aynı anda tek satır açık (yükselir, sol kenarında işaret) |
| YAPILANLAR | yetenek · kareler ya da □□□ · "n/3 rakipte var" | Dilim = kademe (K1–K3) + cila (+½, en çok +1). n = rakip tablosunda bu yetenekte kademe ≥1 olan rakip sayısı | Hover çipte rakip adları |
| YAPILABİLECEKLER | aday kartlar | Üretim §3.2. Sıra: ACİL etiketli üstte, sonra etki/efor oranı azalan. Bu sprintte ya da sonrakinde olan kartın adı ikincil mürekkepte + "SPRİNT N" etiketi | "+" bu sprinte (`can_add`: kapasite >0, yük ≤ %125, kilitli değil); "→" sonrakine |
| SESLER | "4 ses · 1 yeni" | Açık ticket başlıkları + araştırma cümleleri + rakip çıkışı cümlesi; 0 ise blok çizilmez | Aç/kapat; açılınca "YENİ" etiketleri düşer |
| Diğer satırlar | Büyüme, Güven & Ölçek uyarı üçgeniyle, Gelir "Yok" | Aynı kurallar; Gelir alanı B2C'de var, B2B'de yok | — |
| Orta başlık | "SPRİNT 7 · 2 hafta" · BU SPRİNT | Sprint numarası GameState.day'den türetilir (§3.11) | — |
| Kapasite çubuğu | kart başına tek renk dilim · "10/12" | Kullanılan = sprintteki kartların puan toplamı; kapasite §3.5. Kapasitenin ötesi uyarı renginde, kapasite bir çizgiyle işaretli, taşan kartlarda "devreder" ve "Kapasite aşıldı · n kart devreder" notu; >%125 "+" kapalı ve notu ("%125 üstünde kart eklenmez") | — |
| Yüzler | ekibin yüz diskleri | Bu sprintte çalışabilecek herkes: aktif, Ar-Ge'de ve izinde olmayan | Hover: ad · rol |
| Uyarı notu | "Ekipte Test yok · kartlar hatalı çıkabilir" (uyarı renginde) | Test rolü yoksa. Kimse yoksa sütun gövdesinde boş durum: "Henüz kimse yok" ve çıkış yolu (kadro yoksa "İşe alım başlat", varsa "Ekip'e git") | Düğme Ekip'i (ve Atlas'ı) açar |
| Sprint kartları | üç kart | Kart tanımı §2.6 | Hover: efor dökümü "3 puan · Ece 1 hafta · Kaan 1 hafta" (otomatik atama ön izlemesi §3.5) ve etki satırının sağ ucunda → / Çıkar |
| SPRİNT SONUNDA | "Onboarding Zayıf → Yeterli · Güven kalkar · 3 ticket kapanır" | Öngörü §3.7; yalnız değişenler; her parça kazanç glifiyle | — |
| Liderin önerisi | yüz · "LİDERİN ÖNERİSİ Deniz" · cümle · Uygula | Kural §3.8; lider = Liderlik alanı en yüksek aktif çalışan, yoksa kurucu | Uygula: öneriyi sprinte uygular (boş yuvaları doldurur) |
| Beta kanalı | Kapalı / Açık | §3.6 | İki konumlu anahtar |
| Sprinti başlat | birincil düğme | `can_start`: ≥1 kart ve kapasite >0; aksi kapalı, gerekçesi yanında kapanan koşul: "Bu sprintte çalışacak kimse yok" ya da "En az bir kart ekle" | Planlama → sprint içi |
| Sağ başlık | "SPRİNT 8" · SONRAKİ · bayraklar | Nötr bayrak: rakip tablosunda o sprintte çıkış. Uyarı renginde saatli bayrak: bir talebin son tarihi = o sprint | — |
| Planlanan kartlar | kesikli kenarlı kart | Oyuncunun "→" ile gönderdiği ya da PM'in planladığı kartlar; "planlanan" damgası yok, kesikli kenar söyler | Hover: "↑" bu sprinte, Çıkar; boşsa "→ ile kart gönder" |

### 2.2 C2 — Sprint içi (yalnız farklar)

| Öge | Gösterir | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Başlık | "Hafta 1/2" | Sprint içindeki gün (1 gün = 1 hafta) | — |
| Çubuk | bitmiş kısım koyu | Bitmiş puan / kapasite | — |
| Kart faz adımları | Tasarım · Geliştirme · Test | Dolu ikincil = faz bitti; dolu vurgulu = sürüyor; boş halka = bekliyor (§3.5) | — |
| Kart yüzleri | o hafta atananlar | Otomatik atama; elle değişmez | Hover: ad · rol |
| BİTTİ damgası | bitti | Üç faz dolu | — |
| Karar satırı | "gönderen · konu" · Karara git, altında "Olaylar'da bekliyor · bu hafta" | Olay motoru `card_decision_requested` (§3.3); karar kâğıttır (bir hafta), gelen kutusunda bekler, kart orada cevaplanmaz. Karar bekleyen kart o hafta ilerlemez; sprint kapanışında hâlâ bekliyorsa varsayılan seçenekle çözülür. Kâğıt beklerken üst barın Sıradaki yuvası "Sprint kararı · bu hafta son" | Karara git → Olaylar kâğıt seçili açılır; saat ancak Cevapla'da durur |
| Otomatik başlama notu | "Sprint otomatik başladı" | Sprint bir gün bekleyip liderin önerisiyle başladıysa, o sprint sürdükçe; Ürün kapalıyken BuildHUD'da | — |
| DURUM | "1 kart bitti · 2 sürüyor · 1 karar bekliyor" | Sayımlar | — |
| SONRAKİ SÜRÜM | "v1.5 · 1 hafta sonra" | Sprint sonuna kalan hafta; beta açıksa "+1 sprint" | — |
| Çıkar | hover | Kart adaylara döner, ilerlemesi kalır; bedel yok | — |

### 2.3 C3 — Sürüm çıktı

| Öge | Gösterir | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Zaman | durur | `HOLD_RELEASE_NOTE`; pencere kapatılırsa durum korunur, yeniden açılınca sürüm notu gelir; planlamaya geçilmeden bir gün geçerse sprint liderin önerisiyle otomatik başlar (§3.11) | — |
| Sol panel | "■□□ → ■■□ · Zayıf → Yeterli" okları; "!" gitmiş | Bu sürümde değişen alanlar oklu; bir sonraki planlamada ok düşer | — |
| v1.5 · CANLI | büyük sürüm numarası ve CANLI damgası (betada damga yok, "Beta kanalında · bir sonraki sprintte yayına girer") | §3.6 numaralama; çıkan kart yoksa "Bu sprint sürüm çıkmadı", numara artmaz | — |
| ÇIKANLAR | kart · tik · puan | Bitti kartlar; etkileri uygulanmış (§3.6) | — |
| DEVREDEN | kart · ilerleme kareleri · "→ Sprint 8" | Tamamlanan puan / efor; kalan puan sonraki sütundaki kartta | — |
| HIZ | "8/12 · Ekip 12 puanın 8'ini bitirdi." | Bitirilen puan / kapasite | — |
| SONUÇ | çıkışta "Beklenen: …", bir gün sonra "Gerçekleşen: …" | §3.7; pencere açıksa satır canlı güncellenir | — |
| BASIN | "TeknoGündem · Notly kayıt akışını kısalttı." | Çekirdek K2+ çıkışı ya da bir alanın Zayıf → Yeterli geçişi; şablon; haber bandına da gider; yayın adı kendi renginde | — |
| Lider cümlesi | "Arama bir sprint daha ister." | Devreden kart varsa onu anar; yoksa en zayıf alanı | — |
| Sprint 8 planına geç | birincil düğme, üstünde "Sürüm notu açıkken oyun durur" | Planlamaya geçer, saat bırakılır (bekleyen olay yoksa) | — |
| Sağ panel | DEVREDEN etiketli kart + planlananlar | Devreden kart kalan puanıyla üstte | — |

### 2.4 C4 — Çeyrek (Tier 2 · kesme çizgisi arkası)

| Öge | Gösterir | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Hedef şeridi | "BU ÇEYREK · Onboarding · yeni kullanıcıların yarısı kalsın · on kare · şu an 10 üzerinden 4" | Hedef = alan; cümle şablon (alan başına); ilerleme = alan seviyesinin hedefe oranı, şablon metne proxy olarak yazılır (çalışma kararı); on karede hedef çizgisi beşinci karenin ardında, doluluk nötr. Çeyrek = 6 sprint; hedef çeyrek başında seçilir, seçilmezse PM en zayıf alanı önerir | Tık: şeridin sağına açılan menü, her alan adı ve hedef cümlesiyle |
| Altı sütun | Sprint 7 BU SPRİNT, 8–10 PM, 11–12 boş (kesikli) | PM planlayıcı §3.8 üç sprint ileriye plan yapar; sütunlar en uzununun içeriği kadar, pencere içeriği kadar kısalır | — |
| Sütun başlığı | kapasite çubuğu · x/y · PM etiketi · bayraklar | Gelecek kapasite = bugünkü ekip varsayımı | — |
| Onayla / Düzenle | sütun altı, kartların hemen altında aynı hizada | Onayla (ikincil) → `approved`, damga "ONAYLANDI"; Düzenle → SPRİNT görünümü, o sprint "sonraki" olarak | — |
| Hepsini onayla | sütunların altında, sağda | Tüm PM sütunları; görünümün tek birincil düğmesi | — |
| PM yokken | görünüm açılmaz | SPRINT/ÇEYREK anahtarı pasif | — |

### 2.5 C5 — Planlama (Fatura, B2B · farklar)

| Öge | Gösterir | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Alanlar | Çekirdek · Onboarding & Erişim · Entegrasyonlar · Güven & Ölçek | B2B'de Büyüme yerine Entegrasyonlar; Gelir yok | — |
| Müşteriler satırı | "3 talep" · talep kartları · "Beykoz · 2 ticket" | Hep açık, akordeon dışı, alanların üstünde (son tarihli talepler bir bakışta). Talep üreteci §3.3. Kart: "Nordica · SSO" · "Sprint 8 sonuna kadar" (bu ya da sonraki sprintte bitiyorsa uyarı renginde) · "$12.000/yıl" · alan bayrağı · planlıysa "SPRİNT 7" etiketi. Talebi olmayan müşteri ticket sayısıyla. Hiç yoksa "Açık talep yok" | "+" / "→" aday kart gibi |
| Talep kartı (orta) | "SSO (Nordica)" · etki: "Güven ■□□ → ■■□ · Nordica talebi · 12.000 $/yıl" | Efor = ilgili kademenin eforu | — |
| SPRINT SONUNDA | "… · Nordica talebi zamanında · …" | Talep son tarihinden önce çıkıyorsa | — |
| Son tarih bayrağı | uyarı renginde, saatli "Nordica · SSO · son tarih" | Son tarih sprinti = sonraki sprint | — |
| Lider cümlesi | "SSO gecikirse Nordica yenilemez." | Son tarihi en yakın talep | — |

### 2.6 Kart (tek sahne, ortak)

- **Kart:** kesik köşeli küçük belge (`SprintCard`); orta sütunda geniş, aday listesinde ve sonraki sütunda dar (ad iki satıra iner, durum etiketleri kendi satırında), çeyrekte mini (tür glifi, ad, puan).
- **Satır 1:** tür glifi (yeni · cila · düzeltme · araştırma) · ad · gerekli rol glifleri (beceri glifleri, fazlardan türetilir) · puan kutusu; aday kartta + ve →, alınmış adayda "SPRİNT N" etiketi.
- **Satır 2:** etki satırı, şablon parçalarından: alan kare geçişi · "n ticket kapatır" · "rakip açığını kapatır" · "{müşteri} talebi · {bedel}" · değişim yoksa "Alan Güçlü kalır · Yetenek ■■□ → ■■■". Öngörü kipinde kelime ("Zayıf → Yeterli") ve "kapanır".
- **Durumlar:** aday · aday_alınmış · sprint_plan · sprint_aktif · bitti · devreden · planlanan · kilitli · beta_bekliyor. Etiketler: DEVREDER ve ACİL uyarı renginde, DEVREDEN, BETA BEKLİYOR ve SÖZ VERİLDİ nötr. Kilitli: kilit glifi ve soluk ad, gerekçe satırı ("Ar-Ge: Gelişmiş arama"), + ve → kapalı.
- **Düğmeler:** aday + → hep görünür; sprint_plan → Çıkar, planlanan/devreden ↑ Çıkar üstüne gelince etki satırının sağ ucunda.
- Bileşen hesap yapmaz; izinler ve eşikler modelden gelir.

---

## 3. Sistemler

### 3.1 Veri modeli
- **Alan:** kimlik, ad, sıra, alt-tür kuralı.
- **Yetenek:** mevcut hat. Alan ataması katalogda: kimlik hatları → Çekirdek; Mobil&Erişim → Onboarding & Erişim; Entegrasyonlar → Büyüme (B2C) / Entegrasyonlar (B2B); Güvenlik&Yetki, Dayanıklılık → Güven & Ölçek. Gelir için katalogda hat yoksa "Ücretli plan" tek yetenek (TODO content).
- **Kademe:** mevcut K1–K3, isimli; K3 Ar-Ge kilidi aynen. Kartta seviye numarası asla görünmez.
- **Kart:** kimlik, tür, yetenek, hedef kademe, efor, gerekli roller, faz payları, faz ilerlemeleri, durum, atananlar, etki özeti, kaynak (ticket kimlikleri / müşteri), son tarih sprinti, bedel.
- **Sprint:** numara, başlangıç günü, kapasite, kartlar, durum (planlama / sürüyor / kapandı), hız, beta.
- **Sürüm:** numara, sprint, çıkanlar, devredenler, hız, beklenen, gerçekleşen, basın satırı.
- **Rezerve:** kart.kalite, sprint.takım_kimliği, sürüm.rakip_tepkisi, müşteri.talep_memnuniyeti.

### 3.2 Katalog ve kart üretimi
- **Özellik:** her yetenek için bir sonraki kademe = tek aday kart (K3 kilitliyse görünür, kilitli).
- **Cila:** yetenek K1+ ve katalogda cila adı varsa; yoksa üretilmez.
- **Düzeltme:** açık ticket'lar yeteneğe göre gruplanır → yetenek başına tek kart; çıkınca gruptaki ticket'lar kapanır; 3+ ticket ACİL.
- **Araştırma:** alan başına "kullanıcıyla görüş" (Ürün rolü, 1 puan); çıkınca alanın Sesler listesine şablon cümle ekler, bir sprint gizlenir.
- **Talep (B2B):** §3.3.
- Kart adları katalogdan; eksikte "TODO content".

### 3.3 Köprüler
- **DESTEK:** mevcut ticket üretimi değişmez; Ürün yalnız okur ve kapatır.
- **Talep üreteci:** her aktif müşteri en fazla bir açık talep. Yetenek = arketipe göre (Bürokratik → Güven & Ölçek, Fiyat-avcısı → Entegrasyonlar, Hevesli → Çekirdek, Temkinli → Onboarding). Son tarih = oluşturma + 4 sprint. Bedel = müşterinin yıllık geliri. Oluşma: imzadan 1 sprint sonra ve her yenilemeden 6 sprint önce. Zamanında çıkan talep → müşteri "memnun" (rezerve alana yazılır; mevcut sağlık alanı varsa oraya). Satış kodu değişmez.
- **Statik rakip tablosu (JSON):** üç rakip, yetenek kademeleri, çıkış listesi (rakip · yetenek · sprint). Çıkış günü: alan çipi, sonraki sütun bayrağı, beklenti +0.5 (en çok +1), haber bandı satırı. Markalar uydurma.
- **Olay motoru dikişleri:** `sprint_planned · sprint_started · card_phase_changed · card_done · card_carried_over · sprint_closed · version_shipped · card_decision_requested`. Kart kapsamlı olay `card_id` taşır; sonuç değiştiricileri: efor ±, ilerleme ±, devretme zorlaması, bir sprintlik çalışma saati çarpanı. İki debug olayı (TODO content): "iki yol var", "sprint yetişmeyecek".
- **Ekip:** kapasite mevcut rol/alan/moral/çalışma saati verisinden okunur; Ekip kodu değişmez. Rol→faz tablosu Ürün JSON'unda (Ekip GDD'sine atıf notu).
- **Eksen köprüsü:** alan seviyeleri → mevcut üç eksen puanı (JSON ağırlık matrisi, eksen merkezleri 4/9/12'ye kalibre) → GameState'e push. MarketBar, Satış, Finans değişmez.
- **Haber bandı:** basın satırı mevcut havuza şablondan eklenir.

### 3.4 Alan seviyesi, beklenti, durum
- Seviye = alandaki yeteneklerin kademe ortalaması (0–3), yarıma yuvarlanır; üç dilim. Cila yeteneğe +0.5 (en çok +1).
- Beklenti (alan düzeyi): Bootstrap 1 · Traction 2 · Series A 2; rakip çıkışı +0.5 (en çok +1).
- Durum: 0 → Yok · < beklenti → Zayıf · beklenti ±0.5 → Yeterli · ≥ beklenti+1 → Güçlü. "!" durumu düşürmez, rozet koyar.
- Cümleler, etki parçaları ve basın satırları JSON şablonlarından; kodda sabit metin yok.

### 3.5 Kapasite, atama, ilerleme
- Kişi puanı = uygun rolde haftada 2 × beceri (alan düşük 0.75 / orta 1.0 / yüksek 1.25) × moral bandı (mevcut) × çalışma saati (mevcut). Kurucu Ürün ve Yazılım'da 0.75. Ar-Ge'deki ve izindeki kişi sayılmaz.
- Kapasite = toplam × 2 hafta. Tavan %125.
- Faz payları: özellik/cila 20/60/20 (Tasarım/Geliştirme/Test); düzeltme 0/70/30; araştırma Ürün %100.
- Otomatik atama her hafta başı, açgözlü, sprint sırası korunur; kişi haftada tek kart. Uygun rol yoksa faz başka rolce yarım hızda; Test rolü yoksa uyarı çipi.
- İlerleme: fazın puanı dolunca sonraki faz; üçü dolunca bitti. Karar bekleyen kart ilerlemez.
- Hatalı çıkış: Test rolsüz tamamlanmış kart sürümde %40 ihtimalle 1 ticket üretir (deterministik hash); beta açıksa yarı.

### 3.6 Sprint yaşam döngüsü
- Başlat: kartlar kilitlenir (çıkar hariç), durum "sürüyor".
- Hafta tick'i: günlük tick 1. yuvası (Ürün): atama → ilerleme → dikişler.
- Kapanış (2. gün sonu): bitti kartlar sürüme girer, etkiler uygulanır (kademe artar, ticket kapanır, alan seviyesi ve eksen puanı yenilenir), devredenler sonraki sprinte, sürüm kaydı yazılır, `version_shipped`, zaman durur, sürüm notu açılır.
- Numara: v1.0 = MVP; her sürümde +0.1; çıkan kart yoksa artmaz.
- Beta: açıkken kartlar bir sprint "beta_bekliyor" (kapasite tüketmez), sürüm bir sprint gecikir, ticket ihtimali yarı.
- Devretme: ilerleme korunur, kalan puan gösterilir.
- Hotfix yok; acil düzeltme normal karttır.

### 3.7 Öngörü ve gerçekleşen
- Öngörü: bu sprintteki kartlar bitmiş varsayılarak alan/ticket/talep farkları; yalnız değişenler.
- Beklenen (sürüm anı): aynı hesap, çıkanlarla.
- Gerçekleşen (sürümden 1 gün sonra): alan seviyesi ve ticket sayımlarından şablon cümle; metrik yoksa dilim değişimi cümlesi. Sürüm kaydında güncellenir.

### 3.8 Lider önerisi ve PM planlayıcı
- Lider: en zayıf alandan etki/efor oranı en yüksek 1 kart + açık ACİL düzeltme + kapasiteyi dolduran en yüksek etki/efor kart; cümle şablon "{kart1} ve {kart2} bu sprintte bitmeli."
- PM planlayıcı (kesme çizgisi arkası): aynı kural, çeyrek hedef alanına ağırlık ×1.5, üç sprint ileriye; her sprint `approved=false` doğar. PM'in alan becerisi düşükse plan daha az kart taşır (0.8×).

### 3.9 MVP
- Ürün, Çekirdek'teki üç kimlik yeteneği K1'e ulaşınca v1.0 ile canlıya çıkar (başlıkta SÜRÜM v1.0); mevcut "MVP çıktı" sinyali aynı anda aynı adla atılır; Satış'ın MVP'ye bağlı davranışı değişmez. Öncesinde başlık "MVP · yayında değil", Sonraki sürüm satırı "v1.0 · N kart kaldı". Onboarding'deki alt-tür seçimi katalog seçimidir; Konsept ekranı yoktur.

### 3.10 Save v10 ve taşıma
- v10: yetenek kademeleri, cila sayaçları, kartlar, aktif sprint, planlanan sprint, sürüm listesi, rakip çıkış imleci, talepler, beta bayrağı, çeyrek hedefi.
- v9 → v10: hat kademeleri birebir; sürmekte olan Konsept sürümü seçili hatlar için özellik kartlarına, yüzdesi Geliştirme fazına; cila merdiveni cila sayacına (en çok 1.0); ticket'lar aynen. Taşınan run "Sprint 1 · planlama" ile açılır.

### 3.11 Zaman kuralları
- Sprint numarası ve hafta, GameState.day'den türetilir; ayrı sayaç yok.
- Planlama durumunda zaman akarsa: bir gün geçince sprint liderin önerisiyle otomatik başlar ve TopBar'a "Sprint otomatik başladı" notu düşer.
- Sürüm notu ve olay modalı zamanı durdurur; bekleyen olay varsa saat bırakılmaz.

---

## 4. Çalışma değerleri (JSON'da; playtest sonrası oynanır)

| Değer | Çalışma değeri |
|---|---|
| Sprint uzunluğu | 2 oyun günü (2 hafta) |
| Çeyrek | 6 sprint |
| Kart eforu | K1 3 · K2 5 · K3 8 · cila 2 · düzeltme 1 / 2 (3+ ticket) · araştırma 1 · talep = kademe eforu |
| Faz payları | 20 / 60 / 20 · düzeltme 0 / 70 / 30 · araştırma Ürün 100 |
| Kişi puanı | 2 / hafta × beceri 0.75–1.25 × moral × çalışma saati · kurucu 0.75 |
| Kapasite tavanı | %125 |
| Rolsüz faz hızı | %50 |
| Hatalı çıkış ihtimali | %40 · beta açıkken %20 |
| Beklenti | Bootstrap 1 · Traction 2 · Series A 2 · rakip +0.5 (en çok +1) |
| Cila katkısı | +0.5 / kart, yetenek başına en çok +1 |
| Talep son tarihi | oluşturma + 4 sprint |
| Talep oluşma | imzadan 1 sprint sonra · yenilemeden 6 sprint önce |
| PM planı ufku | 3 sprint · hedef alan ağırlığı ×1.5 |
| Panel oranları | sol .32 · orta .44 · sağ .24 · aralık 16 px |
| Kart | 56 px · aralık 8 · satır arası 6 · sol kenar 3 |
| Alan satırı kapalı | 72 px |
| Kapasite çubuğu | 8 px · köşe 2 |

---

## 5. Sistem saflığı kuralları

1. Ürün mantığı RefCounted sistemlerdedir; sahne yalnız çizer ve `action_requested` yayar.
2. Ürün durumunun tek evi GameState altındaki ürün durumudur; sprint, backlog, sürüm listesi oraya yazılır.
3. Satış, Finans, Ekip, Ar-Ge, DESTEK kodu değişmez; yalnız yeni sinyaller dinlenir ve eksen puanı push edilir.
4. Zamanı TimeManager sayar; Ürün türetir.
5. Tüm içerik ve çalışma değeri JSON'da; tüm UI metni `PRODUCT_*` anahtarlarında; sahnede sabit metin yok.
6. Deterministik hash; RNG yok.
7. Olay motoruna yalnız dikiş ve sinyal eklenir.
8. Anlamsal renk `D_` yardımcılarından gelir: kodun boyadığı renk çalışma anında yardımcıdan okunur (tek override istisnası bu kümedir), temadaki uyarı ve risk kutularının renk körü ikizi `Cb` varyasyonudur ve `UiTokens.D_variation` ile seçilir. Type variation adları: `SprintColumn` (+Current, +Next, +Head, +Foot), `SprintCard` (+Hover, +Low, +Planned, +Mini), `CardKeys`, `IconKey`, `PtsBox`, `FlagChip` (+Warn), `TagWarnBox` ve `TagWarnInk` (+Cb), `DocStamp`, `SegPickBox`, `SegPick`, `ColumnTitle`, `FigureValue`, `ReleaseValue`.
9. Faz B sonunda eski Konsept/faz/cila kodu ve `SWEEP_LIST.md`'deki yetimler silinir; GDD'de adı geçen ya da çağıranı olan kalır ve ISLER'e yeniden yuva listesi olarak yazılır.
10. Save v10; v9 yükleyicisi taşır, bozmaz.

---

## 6. Yürütme

**Faz B alt-ajanları:**
1. Model + katalog + kurallar (§3.1, §3.2, §3.4, §3.7, eksen köprüsü, JSON, birim testleri).
2. Sprint motoru (§3.5, §3.6, §3.9, §3.11, dikişler, tick yuvası).
3. Adaptör + eylemler: `ProductModel.live()` tam, `act(kind,args)` bağları, Faz A tohumlarının yerini canlı verinin alması.
4. Köprüler (§3.3) + save v10 taşıma.
5. Silme ve süpürme (`SWEEP_LIST.md`, GDD + çağıran kapısı), bayrağın kaldırılması, smoke güncellemeleri, debug tohumları.
6. Bütünleştirme, MCP kareleri, fark notları, done mesajı.
7. (Kesme çizgisi arkası) Çeyrek görünümü canlı: hedef, PM planlayıcı, onaylar.

**Kesme çizgisi:** 10. saatte 1–6 bitmemişse 7 açılmaz; ÇEYREK "Yakında". 1–6 kesilmez; aşım olacaksa smoke kapsamı daralır, kapsam değil.

**Ortak arayüz** 1. ajanda tanımlanır ve dondurulur; 2–4 aynı dosyaya yazmaz.

---

## 7. Doğrulama listesi

1. Bayrak kalkmış; Ürün sekmesi yeni ekranı canlı veriyle gösteriyor; eski ekranlara giden yol kalmamış.
2. Yeni run "MVP · yayında değil" ile başlar; üç kimlik yeteneği K1'e gelince "SÜRÜM v1.0" ve mevcut MVP sinyali bir kez atılır; Satış smoke'u yeşil.
3. Sprint tam iki gün sürer; TimeManager dışında gün sayan kod yok.
4. Kapasite Ekip'ten hesaplanır; Ar-Ge'ye alınan kişi ve moral değişimi kapasiteyi değiştirir.
5. "+" %125 üstünde pasif; %100–125 "devreder" uyarısı.
6. Otomatik atama: sprint içinde her kartta avatar; elle atama yok.
7. Test rolsüz ekipte uyarı çipi ve deterministik ticket üretimi (test sabitiyle).
8. Devreden kart ilerlemesini korur; kalan puan doğru.
9. Sürüm notu zamanı durdurur; "Beklenen" çıkışta, "Gerçekleşen" bir gün sonra; pencere kapatılıp açılınca sürüm notu geri gelir; bir gün geçince otomatik başlangıç ve notu (Ürün'ün orta sütununda, Ürün kapalıyken BuildHUD'da).
10. Sürümde eksen puanı push; MarketBar ve Satış davranışı mevcut smoke'ta yeşil.
11. Durum kelimeleri beklenti tablosuna uyar; rakip çıkışı çip + bayrak + haber satırı + beklenti artışı üretir.
12. Ticket'lar yeteneğe göre tek düzeltme kartında; kart çıkınca kapanır; 3+ ticket ACİL etiketi (uyarı üçgeniyle).
13. B2B run: talep kartı, son tarih bayrağı, "zamanında" öngörüsü, memnun işareti.
14. Karar satırının "Karara git"i Olaylar'ı kâğıt seçili açar; kâğıt son haftasındayken üst barda "Sprint kararı · bu hafta son"; karar bekleyen kart ilerlemez; iki debug olay efor/devretme değiştirir.
15. Geçmiş listesi; "Henüz sürüm yok" durumu.
16. Beta: sürüm bir sprint gecikir, ticket ihtimali yarı (test sabitiyle).
17. v9 kayıt yüklenir ve taşınır; v10 kayıt/yükleme döngüsü birebir.
18. Katalog eksiğinde "TODO content"; çökme yok.
19. Lider önerisi kurala uyar; Uygula'ya basınca sprint dolar.
20. Uç durumlar: aday yok, kapasite 0, taşma, boş başlatma, sürüm çıkmadı, beta açık, B2B talep yok, kilitli K3, karar bekliyor, Geçmiş boş, MVP öncesi — hepsi tetiklenir, çökmez.
21. Sahnede sabit metin yok; `PRODUCT_*` anahtarları TR+EN; glossary satırları ("ticket", "sprint", "PM" onay bekliyor).
22. Satır içi override yalnız CB kümesinde; variation adları kullanılmış.
23. Silme sonrası eski sınıf adlarına çağrı yok (`grep` temiz); `SWEEP_LIST.md` "kalır" satırları ISLER'de.
24. Smoke yeşil; MCP kareleri C1–C5 + uç durumlar `docs/audits/urun_rev7/` altında; fark notları yazılmış.
25. (Kesme çizgisi arkası) Çeyrek: PM varken dolu sütunlar ve onaylar; PM yokken pasif.

---

## 8. Erdem'in bakacakları (ajan göremez)

- Üç panel 1920×1080 ve 1600×900'de taşmıyor; sol akordeon açılınca sağ paneller yerinde.
- Uzun kart adları ve etki satırlarında kesilme (özellikle EN ve C5).
- Kapasite çubuğunun dilimleri kartların sırasıyla ve yüküyle eşleşiyor.
- Faz noktalarının üç durumu ayırt ediliyor.
- Hover kutusu tek sütunda.
- Sürüm notunda TopBar duraklama göstergesi.
- Rakip bayrağı ile son tarih bayrağının aynı başlıkta çakışması.
- CB paletinde Güçlü/Zayıf, "!", CANLI ayrımı.

---

## 9. Done mesajı biçimi

- Kaldırılan dosya ve sınıflar; yeni sistem/sahne/JSON listesi (tek satır görev).
- Çalışma değerleri tablosunun JSON'daki güncel hali.
- Ajanın verdiği ve Erdem'in onaylaması gereken kararlar (tasarım kararı gibi görünen her şey).
- Mockup ↔ kural çelişkileri ve çözümleri.
- Kesme çizgisi durumu.
- Smoke sonucu, kare yolları, fark notları, bilinen sorunlar, §8 hatırlatması.

---

## 10. Teaching Mode

**Sistem–sahne ayrımı.** Ne: sprint motoru RefCounted sistem; sahne çizer ve eylem yayar. Neden: aynı motor çeyrek görünümünü ve PM otomasyonunu besler. Godot kavramı: static tick + sinyal. Alternatif: panel scriptinde mantık; ikinci ekranda kopyalanır.

**Görünüm sözleşmesi + adaptör.** Ne: ekran bir Dictionary çizer; `live()` sistemlerden kurar, tohum aynı biçimi elle verir. Neden: ekran sistemlerden önce bitti ve test edildi; sistemler gelince yalnız adaptör yazıldı. Alternatif: ekranı sistemlere doğrudan bağlamak; ikisi birden gecikir.

**Push/pull köprüsü.** Ne: alan seviyeleri eksen puanına çevrilip GameState'e push edilir; tüketiciler değişmez. Neden: dönüşüm tek modülde kalır. Alternatif: Satış ve Finans'ı yeniden yazmak; 12 saate sığmaz.

**Deterministik hash.** Ne: hatalı çıkış ve olay tetikleri sabit hash ile. Neden: aynı kayıt aynı sonuç; test yazılabilir. Alternatif: RNG; smoke kararsız.

**Şema taşıma.** Ne: v9 → v10 alan eşleyerek, kaybetmeden. Neden: kayıt oyuncunun malı. Godot kavramı: JSON şema sürümü ve yükleyici zinciri. Alternatif: eski kayıtları reddetmek; playtest kayıtları gider.

**Bayrak arkasında geçiş.** Ne: yeni ekran bayrakla girdi, eski akış korundu, sistemler gelince bayrak kalktı ve eski kod tek seferde silindi. Neden: her commit'te oynanabilir oyun; süpürme doğru zamanda ve bir kez. Alternatif: önce silip sonra yapmak; arada oyun kırık.
