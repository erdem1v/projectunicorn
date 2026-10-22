# R12 · Sprint düzeni: bugünkü kurgu ve ekip 1'den 50'ye büyürken sprint nasıl işlemeli

Hazırlayan: araştırma alt ajanı, 17 Ekim 2026. Repo kodu, veri ve Godot'ya dokunulmadı; yalnız bu dosya yazıldı. Benzetim yalnız Python (`python -I`).
Erdem'in sorusu (`ERDEM_CDQ_CEVAP.md`, Ek, birebir): "ekip büyüdükçe bizim handle edebileceğimiz kart sayısı artar; bu düzen nasıl olmalı? Bu şu anki sprint düzeni ne kadar doğru kurgulanmış?"
Karar verilmedi. Tasarımcıya seçenek ve kanıt verildi. Eski raporlar (R1 to R8, D_SIM, D_MODEL_v2) tekrar edilmedi, atıf yapıldı.

---

## 0. Özet

1. **Kapasite tarafı doğru kurulmuş.** Sprintin kapasitesi kişi puanlarının toplamı çarpı sprint haftası; ekleme tavanı kapasitenin %125'i, yani oran. Sabit kart sayısı yok. Kart büyüklüğü (3/5/8 puan) ile kişi hızı (haftada 2 puan) birlikte kişi başına sprintte 0,75 kart verir. Mike Cohn'un yedi kişilik ekip için verdiği aralık 5-10 kart, yani kişi başına 0,7-1,4 kart. Bizim birim bu aralığın içinde.
2. **Ölçeklenmeyen şey kart arzı.** Aday havuzu hat başına tek kart üretir (`sprint_catalog.gd:224`). Bir alt türde 9 hat var, yani aynı anda en çok 9 özellik kartı açık (B2C'de ücretli plan, Ar-Ge'nin açtığı gizli hatla 11). Katalogun toplamı 144 puan (27 kademe).
3. **Ölçüm (Python kopyası, §1.9).** Kısıtsız modelde 25 ve 50 kişide sprintte hep 9 kart var; ilk sprintte kişi-haftaların %46'sı ve %73'ü boşta. Katalog bitişi: 6 kişi 15 hafta, 12 kişi 8 hafta, 25 kişi 5 hafta, 50 kişi 3 hafta. Bu bir alt sınır: Ar-Ge, yıldız ve lisans kapıları eklenmedi.
4. **Demoda da var.** 10 kişi bile 130 haftalık demoda 2 600 puan üretir, katalog 144. Pazaryeri PRD'sinin 14 hattı (233 puan, `PRD_URUN_DERINLIK.md:230`) 6 kişiyi 23 haftada bitirir. PRD'nin "104. haftada ağaç en çok %60 açık" kapısı (`PRD_URUN_DERINLIK.md:812`) kapısız modelde 2 kişiden büyük hiçbir ekipte tutmaz. Kapılar gerçek hız sınırıysa tutabilir; bunu ölçmek gerek.
5. **`D_MODEL_v2.md:772` cümlesi iyimser.** "50 kişilik ekip 60 haftada bugünkü kataloğu tüketir" yazıyor. Kısıtsız model 3 haftada tüketiyor. D_SIM'in sonsuz kart akışı kullanması (`D_MODEL_v2.md:841`) bu yüzden 50 kişilik sonuçlara "kart bitiyor" gerçeğini yansıtmıyor.
6. **Bugünkü düzenin iyi yanları:** plan ekranının tahmini ile sonuç aynı kodu kullanıyor (`plan_outcome` ve `_end_week` aynı `_assign`/`_work`); kartı bitirecek kadar kişi atanıyor, gereksiz yığılma yok; sprint süresi 1 ya da 2 hafta (Scrum Guide üst sınırı 1 ay).
7. **Eksik yanları:** ekip/takım kavramı yok, tek PM planlıyor (`sprint_catalog.gd:499-504`), koşan sprintte boşta kalan kişiye kart çekilemiyor, talep kartı arzı büyütmüyor (kademeyi yeniden adlandırıyor), kart büyüklüğü ürüne ve ekibe göre değişmiyor.
8. **Gerçek pratik** (§2): ekip 10 ve altı (Scrum Guide), büyüyünce aynı ürün için birden çok ekip, tek backlog, ortak sprint (LeSS, Nexus); ekip sayısı 2-9; 100 kişiye kadar tek "kabile" (Spotify). Kimse sprintteki iş sayısını sabit tutmuyor; kapasiteye ve geçmiş hıza bakıyor.
9. **Oyunlar** (§3): Software Inc. ve Mad Games Tycoon 2 paralel işi "ekip" ve "oda" ile çözüyor, ikisinde de ekip bölmenin bedeli var. Startup Company içerik tükenmesini "özellik seviyesi" ile çözüyor (seviye tavanı 10'dan 4 000'e çıkıyor). Game Dev Tycoon tek proje, büyük şirket modeli yok. Sprint ve hikâye puanı mekaniği olan başka oyun bulunamadı.
10. **Sentez** (§4): kart sayısını kural değil sonuç say; asıl iş arz. Benzetime göre 2 haftalık sprintte boşta payını %10'un altına indirmek için açık aday sayısı yaklaşık 0,9 çarpı ekip gerekir (12 kişi 9, 25 kişi 20, 50 kişi 45). 1 haftalık sprintte yarısı. Bugün üst sınır 9-14.

---

## 0.1 Yöntem, kaynak durumu ve sınırlar

- Kod okuması: `scripts/systems/sprint_system.gd`, `sprint_catalog.gd`, `data/product/sprint.json`, `data/product/lines/*.json`, `data/techtree/rnd_tree.json`, `scripts/debug/sprint_probe.gd`, `run_probe.gd`, `docs/HARITA.md`. Godot koşturulmadı.
- **Benzetim:** `sprint_system.gd`'nin `_assign`, `_work`, `_play_out`, `_takes` işlevlerinin Python kopyası. Dosyalar: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/r12/cur.py`, `run2.py` ... `run5.py`. Motor çıktısıyla doğrulanmadı. Tek tutarlılık kontrolü: tek kurucunun MVP'si 6. haftada çıkıyor (kopya) ve `D_SIM.md` §0 madde 8 aynı sonucu veriyor.
- **Benzetimin varsayımları (hepsi kısıtsız yöndedir, yani katalog gerçekte daha geç biter):** ekip S6 oranında (kurucu, sonra yüzde 51 geliştirici, 20 test, 16 tasarım, 12 PM, en büyük kalan kuralı), herkes orta beceri (haftada 2 puan, morali 1,0), kurucu 2 puan; kapı yok (K2 için yıldız, K3 için Ar-Ge düğümü, lisans bedeli sayılmadı); hata ve araştırma kartı yok; oyuncu her açık kartı `can_add` izin verdiği kadar "+" ile alıyor (etki sırası değil efor sırası). Sonraki sütundaki önden hazırlık ayrıca denendi (§1.9, fark yok).
- Arama bütçesi: 12 WebSearch izni, 9 kullanıldı. WebFetch 33 çağrı.
- **Açılmayanlar:** gamedevtycoon.fandom.com (HTTP 402), stickyminds.com (403), Atlassian velocity ve WIP sayfaları (yalnız gezinti metni geldi), scrum.org Nexus Guide (boş geldi), SAFe makaleleri (giriş duvarı), Spotify blog yazısı (yalnız video girişi). Bunların yerine ikincil ya da arama özeti kullanıldı ve her yerde "(arama özeti)" ya da "(kaynaksız)" yazıldı.

---

## 1. Bugünkü sprint düzeni (yalnız okuma)

### 1.1 Sprint süresi ve ritim

- Varsayılan 2 hafta, seçenek 1 ya da 2 hafta: `data/product/sprint.json:2-3`. Oyuncu süreyi yalnız planlamada seçer, seçim sonraki sprintlere taşınır: `sprint_system.gd:272-277`.
- Bir oyun günü bir haftadır; ilk hafta başlatma günüdür. Kapanış: sürenin sonunda ya da sprintin kartlarının hepsi biten haftanın sonunda (`sprint_system.gd:783`).
- 1 haftalık sprintte karar kâğıdı ve demo günü başlarken çekilir (`sprint_system.gd:164-166`).
- Kapanışta bitmeyen kart ilerlemesiyle sonraki sprinte devreder (`sprint_system.gd:1029-1129`). Hat kademesi yalnız kapanışta yazılır (`_close`, `ProductState.set_line_tier`), yani bir hattın K1'den K3'e gidişi en az üç kapanış.
- Çeyrek 12 hafta (`sprint.json:4`); PM planı 3 sprint ufku (`sprint.json:39`, `sprint_catalog.gd:532`).

### 1.2 Bir sprintte kaç kart; probe'daki `cards=<1|2>`

- **Kodda sabit kart sınırı yok.** "+" (`can_add`, `sprint_system.gd:577-583`) iki şart arar (`_takes`, `:586-594`): boş sprint her kartı alır; dolu sprintte (a) mevcut yük artı kartın kalanı kapasitenin %125'ini aşmamalı (`sprint.json:26`), (b) mevcut kartlar sprintte oynatılınca boş puan kalmalı. İkinci şartta yeni kart oynatmaya dahil değil, yalnız mevcut kartlar.
- `--sprint-probe cards=<1|2>` oyun kuralı değil probe parametresi: sprinti N karta tamamlar, devredenler kalır, Çekirdek K1 adayları efor sırasıyla `add` ile girer (`sprint_probe.gd:11-13`, `:151`). `fill=1` olunca `cards` okunmaz (`:13`, `:146`).
- **Neden 1|2 (çıkarım):** kapı komutu kurucu ve üç kişilik ekiple koşuyor (`docs/tasks/faz_ab/a_calisma/A1d/A1d_TABAN.md:20`: `cards=2 team=3 fill=1`). Tek kurucunun 2 haftalık sprinti 4 puan (`PRD_URUN_DERINLIK.md:231`), K1 3 puan. İkinci K1 yüklemeyi 6'ya çıkarır, tavan 5 (4 çarpı 1,25). Yani kurucu tek kart alır, ikinci kart ancak ekip ya da mesai büyüyünce girer. `lead.small_team_cards = 2` (`sprint.json:28`, `sprint_catalog.gd:801`) aynı sezgi: kapasitesi iki K1'e yetmeyen ekip "küçük ekip" sayılır ve liderin alan seçiminde araştırma kartı elenir.

### 1.3 Kartlar nasıl seçilir ve planlanır

| Yol | Ne yapar | Kod |
|---|---|---|
| Oyuncu | "+" bu sprinte, "→" sonraki sütuna, kaldır, boş geçir, başlat | `sprint_system.gd:91-134`, `:226` |
| Lider önerisi | Kapasiteyi oynatarak doldurur: yalnız bu sprintte bitecek kartlar ve en çok bir devreden kart | `sprint_catalog.gd:445-448`, `:820-860` |
| Zorunlu sırası (yalnız lider/PM önerisinde) | verilmiş sözlerin kartları, son tarihi en yakın talep, ücretli plan, liderin alanının en iyi kartı, öncelikli düzeltmeler (açık hata 5 ve üstü); sonra etki/efor oranı | `sprint_catalog.gd:830-860` |
| PM devri | PM'e devredilmişse sprint `plan_next`'te PM'in planıyla kendiliğinden başlar; plan 3 sprint ufuklu; ilk aktif PM planlar | `sprint_system.gd:234-239`, `:1002-1026`; `sprint_catalog.gd:499-504`, `:518-542` |
| Bot | `RunProbe._plan_the_sprint`: söz kartları, B2C ücretli plan, `apply_lead`, başlat; `SprintProbe` `cards`/`fill`/`lead` | `run_probe.gd:911-945`; `sprint_probe.gd:143-160` |
| Olay | Acil durum olayı hattın düzeltme kartını sprintin başına alır, koşan sprintte hemen koşar | `sprint_system.gd:209-224` |
| Karar kartı | Haftada bir, oran 0,35, bir kartı durdurur, aynı anda tek karar | `sprint.json:40`, `sprint_system.gd:875-896` |

Zorunluluk oyuncuya uygulanmaz; "zorunlu" yalnız önerinin sırasıdır. Kilitli kademe (Ar-Ge, yıldız) kartı alınamaz (`_movable`, `:1235`).

### 1.4 Kim hangi karta çalışır

- Oyuncu karta kişi atamaz. Ekip: Görevler matrisinde Yapım ya da Test işini tutan aktif kişiler, kurucu dahil (`sprint_system.gd:538-557`). Yapım+Destek tutan kişinin payı 0,5 (`:1349-1351`); yalnız Destek ya da Ar-Ge'deki kişi ekipte değil.
- Atama her hafta başı (`_assign`, `:795-826`): kartlar sırasıyla; kartın sıradaki fazına uyan kişi önce, sonra haftasından çok puanı kalan; **kart bu hafta bitecek kadar kişi alır**; kalan puan sıradaki karta akar. Fazlar zincirleme: bir kişi bütçesi kalınca aynı hafta içinde sonraki faz için başka kişi seçilir. Yani hafta içinde faz bekleme süresi yok (§1.10, P7).
- Fazlar ve roller: tasarım, geliştirme, test; özellik/talep payı 0,2/0,6/0,2, düzeltme 0/0,7/0,3, araştırma yalnız Ürün (`sprint.json:8-19`).
- Rol uyuşmazsa yarı hız (`no_role_speed 0.5`, `sprint.json:25`; `_work`, `:828-843`); test fazı rolsüz yapılırsa kart hatalı çıkabilir (`faulty_chance 0.4`, `sprint.json:29`).
- Tasarımcı ve PM "önden gider" (`ahead`): geliştirme ve teste uymazlar, ilk fazda çalışır, sprintte tasarım bekleyen kart kalmayınca sonraki sütunun kartlarının ilk fazına geçerler (`:1224-1228`, `:795-826`).
- Haftalık puan: 2 çarpı beceri bandı (0,75/1/1,25) çarpı verim (moral, olay) çarpı mesai saati çarpanı çarpı sprint payı (`sprint.json:21-22`, `sprint_system.gd:1331-1351`).

### 1.5 Kapasite ekip büyüdükçe nasıl artar

- `capacity()` = Σ kişi puanı × sprint haftası (`sprint_system.gd:466-472`). Doğrusal. Sprint kodunda ekip büyüklüğü cezası yok: verim yalnız moral ve olay satırlarından geliyor (`hr_system.gd:403-417`). `coordination_for_*` işlevleri var ama "bugün okuyucusu yok: sprint motoru koordinasyon çarpanı uygulamaz" (`hr_constants.gd:1030`).
- Kişi başı haftalık puan 1,5 ile 2,5 arasında (beceri bandı), mesai ve moralle oynar. 12 orta beceri kişi haftada 24, 50 kişi 100 puan.

### 1.6 Kart kataloğu

- Alt tür başına 9 hat: 5 kimlik hattı (`note_tool.json`, `video_clip.json`, `erp.json`) ve 4 paylaşılan hat (`shared.json`: entegrasyonlar, güvenlik, dayanıklılık, mobil). Her hatta 3 kademe: **27 kademe**.
- Kademe eforu `sprint.json:6`: K1 3, K2 5, K3 8; hat başına 16; **9 hat 144 puan**. Hat dosyalarındaki `effort` alanı kart eforunu belirlemiyor (`step_effort`, `sprint_catalog.gd:185-192`; Ar-Ge `design_system` Deneyim eforunu %20 indirir).
- Ek: B2C ücretli plan tek kart, 3 puan (`sprint.json:52`); Ar-Ge'nin açtığı gizli hat `line_hidden_self_serve` 3 kademe (`data/techtree/rnd_tree.json:40-50`). En çok 163 puan.
- Kapılar: 27 kademenin K3'leri (her alt türde 9) bir Ar-Ge düğümü ister; K2'lerin çoğu kişi yıldızı ister; K1'lerin 1 ya da 2'si yıldız ister (`data/product/lines/*.json`, sayım yapıldı). Lisans bedeli 2-3 kademede.
- Alanlar (`sprint.json:56-62`): Çekirdek (5 kimlik hattı), Onboarding (mobil + gizli), Büyüme (B2C) / Entegrasyonlar (B2B) (paylaşılan entegrasyon hattı), Güven (güvenlik, dayanıklılık), Gelir (B2C ücretli plan).
- **MVP:** Çekirdek'te üç kimlik hattının K1'i (`sprint.json:5`, `sprint_catalog.gd:479-485`); kapanış kapıda durur, oyuncu Yayınla der (`sprint_system.gd:242-260`). **Sürüm:** v1.0 = MVP; sonra sürüm çıkaran her kapanış +0,1 (`:1029-1129`, `HARITA.md:154`): sürüm kart başına değil sprint başına.
- Gelecek: pazaryeri 14 hat, 233 puan (`PRD_URUN_DERINLIK.md:230`); ERP 12 hat, 201 puan (`:483`).

### 1.7 Düzeltme kartları ve Ar-Ge kartları

- **Düzeltme:** hattında açık hata olan her hat için bir kart (`sprint_catalog.gd:239-242`); efor 1 (en çok 4 hata) ya da 2 (5 ve üstü) (`sprint.json:7`, `sprint_catalog.gd:179-182`). 5 hata ve üstü "öncelikli" (`:258`). Kapanışta hattın bütün açık hatasını siler (`sprint_system.gd:1054`).
- **Sprintteki "araştırma kartı"** Ar-Ge değil: alan başına bir kart, "{n} kullanıcıyla görüş", 1 puan, yalnız Ürün aşaması; yapıldıktan sonra bir kapanış gizli (`sprint_catalog.gd:243-246`, `sprint.json:6`).
- **Ar-Ge** sprint dışı: kişi işi `JOB_RESEARCH` dışlayıcı, Ar-Ge'deki kişi sprint ekibinden çıkar (`hr_constants.gd`, `HARITA.md:152`). Düğümleri `rnd_tree.json`.
- Aynı anda aday kart üst sınırı: 9 özellik (+1 plan, +1 gizli) + hat başına bir düzeltme (en çok 9-11) + alan başına bir araştırma (en çok 6): en çok yaklaşık 26, tipik 10-16.

### 1.8 Plan ekranı tahmini

- `plan_outcome` (`sprint_system.gd:607-628`) kartları `_play_out` ile (`:846-872`) `_end_week`'in kullandığı `_assign`/`_work` ile oynatır; ekran bunu kapasite çubuğunda, kart başına kişi dilimlerinde ve "devreder · 2,75/3" etiketinde gösterir (`product_model.gd:121`). MVP tahmini `mvp_eta` (`:631-672`).
- Probe aynı tahmini kapanışla karşılaştırır (`MATCH|MISMATCH`, `HARITA.md:159`). A1d tabanı: 245 kapanıştan 251'i eşleşti, 6 uyuşmazlığın hepsi adlı (olay ya da ekip) (`docs/tasks/faz_ab/a_calisma/A1_HARITA.md:67`).
- Tahmini bozan tek şey sprint içinde ekibin ya da kartın değişmesi (olay, ayrılan kişi); bu da tahmine "neden" olarak yazılıyor.

### 1.9 Ekip büyüyünce: ölçüm (Python kopyası)

Koşullar §0.1'de. 9 hat, kapısız, her açık kart alınıyor. "Boşta": tüm sprintlerde kişi-haftaların harcanmayan payı.

**2 haftalık sprint**

| Ekip | Katalog biter (hafta) | Sprint sayısı | Sprintteki kart (ort.) | Boşta (tümü) | İlk sprintte boşta |
|---|---|---|---|---|---|
| 1 | 81 | 45 | 1,0 | %11 | %25 |
| 3 | 32 | 16 | 2,0 | %20 | %0 |
| 6 | 15 | 8 | 5,0 | %20 | %13 |
| 12 | 8 | 4 | 7,5 | %25 | %44 |
| 25 | 5 | 3 | 9,0 | %42 | %46 |
| 50 | 3 | 3 | 9,0 | %52 | %73 |

**1 haftalık sprint**

| Ekip | Katalog biter (hafta) | Sprint sayısı | Sprintteki kart (ort.) | Boşta (tümü) | İlk sprintte boşta |
|---|---|---|---|---|---|
| 1 | 81 | 81 | 1,0 | %11 | %0 |
| 3 | 32 | 32 | 1,2 | %24 | %0 |
| 6 | 16 | 16 | 2,3 | %25 | %13 |
| 12 | 7 | 7 | 5,3 | %14 | %5 |
| 25 | 4 | 4 | 7,5 | %28 | %46 |
| 50 | 3 | 3 | 9,0 | %52 | %73 |

Ek ölçümler:
- **Hat sayısı:** 2 haftalık sprintte 14 hat (pazaryeri): 6 kişi 23, 12 kişi 11, 25 kişi 6, 50 kişi 4 hafta. 28 hat: 6 kişi 45, 12 kişi 20, 25 kişi 11, 50 kişi 6 hafta. Hat sayısını ikiye katlamak bitişi yaklaşık iki katına çıkarıyor, yani arz ekiple orantısız.
- **104. hafta kapısı** (`PRD_URUN_DERINLIK.md:812`, "en çok %60 açık"): 14 hat 224 puan (233'ün özellik kısmı). Kapısız modelde 2 kişi 59, 3 kişi 50, 6 kişi 23 haftada bitirir; tek kurucu 104. haftaya kadar 180 puanı (%80) bitirir. Bu kapı ancak Ar-Ge, yıldız ve lisans kapıları gerçek hız sınırıysa tutar.
- **Önden hazırlık** (sonraki sütunun tasarım ilk fazı) açıkken 6, 12, 25, 50 kişide bitiş ve boşta aynı (kart zaten sprinte sığıyor, sonraki sütunda kart yok).
- **Karışım, 12 kişi:** referans (6 geliştirici, 2 test, 2 tasarım, 1 PM + kurucu) boşta %25; hepsi geliştirici %13; PM'siz %25. Tasarımcı ve PM'in boşta payı yapısal: kartın yalnız %20'si tasarım (`sprint.json:9`) ve önden gidecek kart yok.
- **Tek kart, 12 kişi:** K1 (3 puan) için atama `[kurucu, 1 geliştirici]`, 10 kişi boşta; K3 (8 puan) için 4 kişi. Bu `D_SIM.md:74` S12 satırının (boşta 10,7/12) bugünkü motordaki karşılığı.
- **Havuz büyüklüğü deneyi** (sonsuz kart akışı, her an P açık aday, efor 3/5/8 döngüsü), boşta %/sprintteki kart:

2 haftalık sprint:

| Ekip | P=5 | P=9 | P=14 | P=20 | P=30 | P=45 | P=70 |
|---|---|---|---|---|---|---|---|
| 12 | 45%/5,0 | 6%/11,2 | 6%/12,3 | 6%/12,3 | 6%/12,3 | 6%/12,3 | 6%/12,3 |
| 25 | 47%/5,0 | 52%/9,0 | 26%/14,0 | 9%/24,9 | 9%/25,4 | 9%/25,4 | 9%/25,4 |
| 50 | 74%/5,0 | 52%/9,0 | 26%/14,0 | 47%/20,0 | 21%/30,0 | 9%/50,3 | 9%/50,7 |

1 haftalık sprint: 12 kişi P=9'da %6; 25 kişi P=9'da %10; 50 kişi P=20'de %9 (P=14'te %26). Kalan %6-9 taban, tasarımcı ve PM'in ilk faz dışında iş bulamamasından geliyor.
**Okuma:** boşta payını tabana indiren en küçük havuz yaklaşık 0,9 çarpı ekip (2 hafta) ya da 0,45 çarpı ekip (1 hafta). Sprintteki kart sayısı da 0,75 çarpı ekibe yakınsıyor (50 kişi 50 kart).

### 1.10 Bugünkü düzenin sorunları (kanıtlı)

- **P1. Kart arzı ekiple büyümüyor.** Her hattın yalnız sıradaki kademesi aday (`sprint_catalog.gd:224`); K2, K1 kapanmadan görünmez. Aynı anda özellik kartı ≤ hat sayısı. Kanıt: §1.9, 25 ve 50 kişide sprintte 9 kart, boşta %42-52.
- **P2. Katalog toplamı küçük.** 144 puan; 12 kişinin saf kapasitesi 6 haftada eder (144 bölü 24). 130 hafta boyunca kapasite katalogun 11 (6 kişi), 22 (12 kişi), 45 (25 kişi), 90 (50 kişi) katı. Kısıtsız bitişler §1.9. `D_MODEL_v2.md:772` ("60 haftada") bununla çelişiyor.
- **P3. Hat zinciri ekipten bağımsız alt sınır koyuyor.** K1, K2, K3 art arda kapanışlarda yazılıyor; 50 kişi bile bir hattı en az 3 hafta (1 haftalık sprint) ya da 3 sprintte (kartlar erken biterse 3 hafta) bitirebilir. Çok kişi tek bir hattı hızlandırmıyor.
- **P4. Talep kartı arzı büyütmüyor.** B2B talebi o kademenin özellik kartının yerini alıyor (`sprint_catalog.gd:226-236`: aynı `step`, kart kimliği `req:` olur). 50 müşteri aynı kademeyi istese de tek kart.
- **P5. Kart büyüklüğü ekibe ya da ürüne göre değişmiyor.** En büyük kart 8 puan; 50 kişi haftada 100 puan üretir. Büyük bir ekibin hızıyla küçük kartın boyutu arasındaki fark arzı eritir. (Birimin kendisi doğru: §0 madde 1.)
- **P6. Sprint içinde kart çekilemiyor.** "+" yalnız planlamada açık (`sprint_system.gd:577-583`). Koşan sprintte kartı biten kişiler "boşta" sayılır, panel "sonraki sprinti planla" der, iş kendiliğinden verilmez (`HARITA.md:152`, `idle_text`). Küçük ekipte sorun değil; kart arzı kıt olan büyük ekipte boşta kalma süresi sprint süresi kadar uzar.
- **P7. Hafta içi faz zinciri bekleme üretmiyor.** `_assign` bir kartın tasarım, geliştirme, test fazlarını aynı haftanın bütçelerine zincirler (`:795-826`). Yeterince kişi varsa K3 bir haftada biter. `D_SIM.md` §10 sağlıklı ekipte kart başına 3,5 hafta bekleme ölçmüştü; o ölçüm D modelinindi (zaman sıralı hafta, `D_MODEL_v2.md` §3.4), bugünkü motorun değil. D modeli uygulanınca arz sorunu hafifler (kartlar sprintte daha uzun kalır) ama çözülmez.
- **P8. Tek kurucuda granülerite.** 2 haftalık sprint 4 puan, K1 3 puan, ikinci kart tavanı aşıyor (6 > 5): her sprint 1 puan boşa (benzetimde %25 ilk sprint boşta). Araştırma ya da düzeltme kartı (1 puan) bunu doldurabilir; o kart yoksa boşa gider.
- **P9. Tek PM planlıyor.** `quarter_pm` ilk aktif PM'i döndürür (`sprint_catalog.gd:499-504`); ikinci ve sonraki PM'in plan yetkisi yok. Önden hazırlık ise her tasarımcı ve PM'de çalışıyor (`:1224`). 25-50 kişide birden çok PM olacağı varsayımı (`D_SIM.md` S5/S6) planlamayla uyumsuz.
- **P10. Ekip ya da takım nesnesi yok.** Tek sütun, tek lider önerisi, tek PM planı, tek sürüm notu. Ekip büyümesi için "ekip başına lider" kararı (Erdem, D1) planlama tarafında karşılıksız.
- **P11. Ölçek maliyeti (hesap, ölçülmedi).** Her "+" kartları derin kopyalayıp oynatıyor (`_takes`: `duplicate(true)`, `_play_out`); lider önerisi her aday için `plan_outcome` çağırıyor (`sprint_catalog.gd:852`). Maliyet kart sayısı çarpı kişi sayısı çarpı aday sayısıyla büyüyor. 40 kart ve 50 kişide ilk kez anlamlı olabilir; Godot'ta ölçülmedi.
- **P12. Plan ekranında kişi satırları.** Ekip satırı kişi başına (`HARITA.md:152`); 50 kişide 50 satır. D6 kararı (kişi yükü avatar satırında) bunu çözecek; sprint ekranında şimdilik karşılığı yok.

**Doğru kurulanlar (kanıtlı):** kapasite ve tavan oransal (`:466-472`, `:586-594`); plan tahmini = sonuç (probe 245/251, adsız uyuşmazlık yok); kartı bitirecek kadar kişi (gereksiz yığılma yok, §1.9 tek kart deneyi); sprint süresi 1|2 hafta, tek karar kâğıdı; boş sprint ve devir kuralları (`:226`, `:1002`); kart birimi (0,75 kart/kişi/sprint).

---

## 2. Gerçek pratik

Not: ekip büyüklüğünün genel kanıtı (QSM, Brooks, iki pizza, Pave, Team Topologies) `R4_GERCEK_PRATIK.md` §2.5-2.6'dadır, tekrar edilmedi. Burada R4'te olmayan sprint kapasitesi, ölçekleme çerçeveleri, sprint uzunluğu ve ekipler arası bağımlılık var.

### 2.1 Sprint kapasitesi ve hız (velocity)

| Bulgu | Kaynak |
|---|---|
| Sprint "bir ay ya da daha kısa" sabit uzunlukta olay. Geliştiriciler sprinte ne alacaklarını "geçmiş performans, gelecek kapasite ve Done tanımı"na bakarak seçer; "bir sprintte ne kadarının biteceğini seçmek zor olabilir". | https://scrumguides.org/scrum-guide.html |
| Scrum ekibi "tipik olarak 10 ya da daha az kişi". Büyürse "aynı ürüne odaklı birkaç bütünsel Scrum ekibine" bölünür; ekipler aynı Product Goal, Product Backlog ve Product Owner'ı paylaşır; hepsi aynı Done tanımına uyar. | https://scrumguides.org/scrum-guide.html |
| Yedi kişilik tipik ekip iterasyonda **5-10 kalem** planlar (kişi başı 0,7-1,4). Kısa iterasyonlar alt uçta, dört haftalık üst uçta; "uzun sprintte kalemler daha çok değil daha büyük olur". Tüm ekibin tek kaleme yığılması öğrenme egzersizi olarak iyi, varsayılan olarak kötü: "birbirinin yoluna çıkmak için çok fırsat var". Önerilen: birden çok kalemi aynı anda yürütmek. | Mike Cohn, https://www.mountaingoatsoftware.com/blog/should-a-team-swarm-on-to-one-backlog-item-at-a-time |
| Hız: son **üç sprintin** ortalaması; devamsızlıkla normalleştirilir (beş kişilik ekip biri tam yokken 50 puan yaparsa kapasite %80, normalleşmiş hız 60). "Ekip büyüklüğü değişirken normalleştirmeyi atlamak" yanıltıcı hedef üretir. Desen kararlı ekip için; ekip büyüyüp küçülünce uygulanmamalı. | https://www.scruminc.com/yesterdays-weather/ ; "büyüyen ekipte uygulanmamalı" kısmı arama özeti: https://archive.appliedframeworks.com/?p=3264 |
| Ekibe bir kişi eklenince (6'dan 7'ye) hız önce düşer: ilk sprintte yaklaşık %10, ikincide %5, üçüncüden itibaren yaklaşık %13 yükselir. Kaynak slaytına erişilemedi (arama özeti; kaynak doğrulanmadı). | Cohn slaytı: https://www.mountaingoatsoftware.com/uploads/presentations/Advanced-Agile-Planning-Norwegian-Developers-Conference-2010.pdf |
| Kalem boyutu: ürün sahibi için pratik kural "sprinte en az 4 öncelikli kalem sığmalı", "en üstteki 20-40 kalem bir sprinte sığacak kadar küçük". Başka kaynakta "kalem en çok ortalama hızın yarısı". Hepsi kural değil ampirik tavsiye (arama özeti; kaynak sayfa 403 verdi). | https://www.stickyminds.com/article/product-backlog-rules-thumb |
| SAFe'de ekip "tipik olarak on ya da daha az kişi"; planlama "ekibin kapasitesi ve geçmiş hızıyla" yapılır. Normalleştirilmiş hikâye puanı (1 puan yaklaşık 1 geliştirici günü, kişi başı sprint başına 8 puan) bilgisi model bilgisidir (kaynaksız); sayfa giriş duvarı çıkardı. | https://framework.scaledagile.com/agile-teams ; https://framework.scaledagile.com/iteration-planning |

**Çıkarım (bizim için):** sabit kart sayısı pratikte yok. Kapasite, geçmiş hız ve ekip değişiminde normalleştirme var. Kalem sayısı ekiple yaklaşık doğrusal (kişi başı 0,7-1,4). Bizim kapasite kuralı bu mantığa uyuyor; eksik olan kalem sayısı.

### 2.2 İdeal ekip büyüklüğü ve bölünme

| Çerçeve | Sayılar | Kaynak |
|---|---|---|
| Scrum Guide 2020 | ekip 10 ve altı; büyürse birden çok ekip, tek backlog | https://scrumguides.org/scrum-guide.html |
| Scrum@Scale | optimal ekip "10'dan az" (Harvard araştırması ortalaması 4,6); Scrum of Scrums'ta **4-5 ekip**; birden çok SoS bir "SoSoS" olur; Chief Product Owner tek backlog tutar | https://www.scrumatscale.com/scrum-at-scale-guide-online/ |
| LeSS | ekip 3-9 kişi (özellik ekibi); bir Product Owner altında **2-8 ekip** (8 "ampirik üst sınır gözlemi"); LeSS Huge 8+ ekip, "gereksinim alanları" 4-8 ekip, her alanın Area Product Owner'ı; tek Product Backlog; **tek ortak sprint**; Planning One ortak, Planning Two ekip başına; Overall Retrospective | https://less.works/less/framework/introduction |
| Nexus | yaklaşık **3-9 Scrum ekibi**, bir backlog; Nexus Integration Team entegre artışı her sprint üretmekten sorumlu (arama özeti) | https://www.scrum.org/node/38850 (arama sonucu; sayfa içeriği doğrulanamadı) |
| SAFe | Agile Release Train "genellikle **50-125 kişi**" (sayfa); ekip sayısı, PI uzunluğu giriş duvarında (kaynaksız: 5-12 ekip, 8-12 haftalık PI) | https://framework.scaledagile.com/agile-release-train |
| Spotify | Squad = mini girişim, kendi çalışma biçimini seçer ("kimi Scrum sprint, kimi Kanban"), uzun vadeli misyonu ve bir product owner'ı var; **kabile 100 kişinin altında** (Dunbar); 30 ekip, 3 yılda 30'dan 250 teknik kişiye büyüme. Squad büyüklüğü bu makalede yazılı değil. | Kniberg ve Ivarsson 2012, https://blog.crisp.se/wp-content/uploads/2012/11/SpotifyScaling.pdf |
| Software Inc. wiki | "10-12 kişilik ekipler proje etkinliği için ideal"; üstü ölçek dezekonomisi | https://softwareinc.coredumping.com/wiki/index.php/Teams |

**Ekip başına PM ya da lider:** LeSS ekip başına ayrı PO istemiyor (bir PO, 2-8 ekip; kabaca 8 ekibe kadar tek PO, ötesi alan PO'ları). Scrum@Scale ekip başına ürün sahibi, ekipler üstü Chief PO. Spotify squad başına product owner, kabile başına lider. R4 §2.5: yönetici gereksinimi 10-15 mühendisten başlıyor, PM oranı 5:1'den 11:1'e. **Çıkarım:** "ekip başına lider" Erdem'in kararı (D1) ile örtüşüyor; ekip başına ayrı PM şart değil.

### 2.3 Sprint uzunluğu seçimi

- Scrum Guide: en çok bir ay (aynı kaynak).
- Yaygın değer iki hafta. Anketler: VersionOne 6. yıllık rapor, iterasyonların %46'sı 8-14 gün, %29'u 15-21 gün (arama özeti; https://eg.bucknell.edu/~cs479/common-files/resources/versionone-state-of-agile/6th-annual-state-of-agile-report.pdf); Scrum Alliance 2015, ekiplerin %60'ı 2 haftalık (arama özeti; https://scrumalliance.org/ScrumRedesignDEVSite/media/scrumalliancemedia/files%20and%20pdfs/state%20of%20scrum/scrum-alliance-state-of-scrum-2015.pdf); Ambysoft 2018, ekiplerin %87'si iki hafta ya da kısa, ortalama 11 takvim günü (arama özeti; https://ambysoft.com/surveys/softwaredevelopment2018.html). Bir örneklemde 3 hafta çoğunluk çıktı (opensource.com, yöntem belirsiz, güvenilirlik düşük).
- Akademik: 8 aylık bir mobil yazılım dersinde 1, 2 ve 3 haftalık iterasyonlar denendi (her aşamada 10 proje); engeller ve proje değerlendirmesi uzunluğa göre değişti, "en iyi uzunluk" sonucu yok (https://scitepress.org/PublishedPapers/2022/110377).
- Cohn: iterasyon uzunluğu kalem sayısını az değiştirir, kalemin büyüklüğünü değiştirir (yukarıdaki kaynak).
- **Çıkarım:** 1|2 seçimi pratikle uyumlu. Süre kart sayısını değil kartın büyüklüğünü etkiler; bizde kart sabit olduğu için sprint süresi kapasiteyi ve arz hızını etkiliyor (§1.9, havuz deneyi).

### 2.4 Paralel iş akışları, WIP ve ekipler arası bağımlılık

- **Kanban Guide (2025):** "Kanban sisteminin üyeleri bir iş akışında başlayıp bitmeyen iş sayısını açıkça kontrol etmelidir"; kontrol "çekme" sistemi yaratmalı (kapasite sinyali olmadan iş başlamaz); WIP'in nasıl belirleneceği yazılı değil; Service Level Expectation: "işlerin %85'i sekiz günde ya da daha kısada biter" biçiminde tahmin; akış ölçüleri WIP, Throughput, Work Item Age, Cycle Time. https://kanbanguides.org/english/
- **Little yasası ve WIP-darboğaz** için bkz. R4 §2.6, R5 §2.5; tekrar edilmedi.
- **LeSS:** bağımlılıklar tek backlog ve ortak Planning One ile yönetilir: ekip temsilcileri kalemleri geçici olarak bölüştürür, ekipler ilgi ve beceriye göre takas eder; önceliklendirme PO'dan geçer, açıklama doğrudan ekip ve müşteri arasında; yakın ilişkili kalemler için çok ekipli Planning Two. https://less.works/less/framework/introduction
- **Scrum@Scale:** Scaled Daily Scrum'a her ekipten en az bir temsilci gelir ve ekipler arası bağımlılıkları sorar; SoS Master bağımlılıklara dikkat eder; ürün sahibi ekibi engelleri kaldırır. https://www.scrumatscale.com/scrum-at-scale-guide-online/
- **Spotify:** ekipler düzenli olarak hangi squad'a bağımlı olduklarını ve bunun ne kadar yavaşlattığını puanlıyor; bağımlılık Spotify'da "kötü olmak zorunda değil" ama bloke eden bağımlılıklar azaltılıyor ("yeniden önceliklendirme, yeniden örgütlenme, mimari değişiklik"). Scrum of Scrums yalnız "istek üzerine", çünkü squad'ların çoğu bağımsız; en sık darboğaz geliştirme ile operasyon. https://blog.crisp.se/wp-content/uploads/2012/11/SpotifyScaling.pdf
- **Paralel iş akışı / epik:** Atlassian epik ve SAFe özellik sayfaları açılmadı; "epik, birden çok sprint ve ekibe yayılan büyük iş" tanımı model bilgisidir (kaynaksız). Bizdeki karşılığı: hat zinciri (K1 ile K3) bir epik gibi birden çok sprint sürüyor ve ekip sayısından bağımsız ardışık.
- **Çıkarım:** ölçekte ana yöntem "ekibi küçük tut, ekip sayısını artır, backlog'u tek tut, sprint ritmini ortak tut". Bağımlılığı ölçmek (Spotify anketi) ve entegrasyon sorumlusu (Nexus) ekip sayısı 3-4'ü geçince önem kazanıyor.

---

## 3. Oyunlar (R1, R2, R3, R5 tekrar edilmedi)

Oyun oyun mekanik dökümü; R1 §2.3 ve §7.2 (önerilen kadro tabloları, lider ve PM), R2 §2.3 ve §7.1 (yönetici 3/5/8), R3 §2.2 ve §2.4 (GDT alanları, MGT2 odaları) zaten var. Aşağıda yalnız bu sorunun bosluğu.

### 3.1 Software Inc.

- **Kural:** "sınırsız ekip, ekipte sınırsız çalışan"; ekipler projelere atanır. "Her proje için önerilen ekip büyüklüğü vardır" ve ekip 10-12 kişi etkinliği en yükseğe çıkarır. Çoklu ekip: "30 kişilik iş için 10'arlı 3 ekip atamak büyük sorun değil" (wiki; çoklu ekip cezası "azaltıldı", sayı yok). https://softwareinc.coredumping.com/wiki/index.php/Teams
- **Tarih:** geliştirici (Ağustos 2015): "projeye birden çok ekip yüksek öncelikli, eski kayıtları bozacağı için erteliyorum." (https://steamcommunity.com/app/362620/discussions/0/535152511373031381) Haziran 2015'te "gece ve gündüz vardiyası için iki ekip" mümkün değildi; geliştirici ekibe farklı toplantı saatleri vermeyi planladı. (https://steamcommunity.com/app/362620/discussions/0/594820656446233293)
- **Oyuncu rehberi (2017, erken alfa, "mekanikler iyi anlaşılmamış" notuyla):** geliştirme ekibi önerilen boyutta, pazarlama ve destek ekipleri ayrı; pazarlama ve destek "çoklu görevi iyi taşıyor, boyut cezası yok"; "ikincil geliştirme ekipleri ürüne zarar verir"; bir ürün için bir ekip; eğitim iki ay cezayı siler. https://steamcommunity.com/app/362620/discussions/0/2119355556482487720
- **Lider:** ekip için lider gerekli; lider etkinliği ekibe yansıtıyor, yaklaşık %25 katkı (R1 §2.5 kodu yorumu, doğrulanmamış). PM lideri otomasyonu: R1 §2.5.
- **Ölçek ve sorun:** 200 çalışanda "kim hangi ekipte" izlenemiyor, ekip başına görev sınırı sonradan eklendi (1.7.24), kayıtlı ekip kurulumları (1.7.25) (R1 §2.6).
- **Bizim için:** ekip büyüklüğü cezasını oyun ekip başına koyuyor, şirket çapında değil (D1 ile uyumlu). Birden çok ekibin tek ürün için ek cezası önce yoktu, sonra "azaltıldı" ifadesiyle kaldı. 3 ekiple 30 kişilik iş sorun değil ifadesi, bizim "tek backlog çok ekip" modelimize dayanak.

### 3.2 Game Dev Tycoon

- **Kural:** aynı anda **tek proje**; orta ve üstü oyunlarda 3 aşama x 3 kaydırıcı, "en çok 9 kişi aynı anda çalışır" (R3 §2.2). Büyük şirket modeli yok (R3 §4).
- **Paralel yapı:** ikinci ofis ve laboratuvarlar. R&D laboratuvarı ve donanım laboratuvarı, 700 tasarım ya da 700 teknoloji puanlı "uzman" yetiştirilince açılıyor; donanım için önce R&D'de donanım projesi araştırılıyor (https://steamcommunity.com/app/239820/discussions/0/810938810725487045 , https://steamcommunity.com/app/239820/discussions/0/3105763714516541002). Bu sayfalar personelin lab ile oyun arasında nasıl bölündüğünü yazmıyor.
- **Ofis büyüklüğü:** ilk ofiste 2-4 kişi (oyuncu önerileri 3-4), 6 koltuklu büyük bina (R3 §2.2, https://steamcommunity.com/app/239820/discussions/0/864977564465087976).
- **Bulunamayan:** sözleşme işlerinin oyunla aynı anda yapılıp yapılmadığı ve laboratuvar personel sayıları. gamedevtycoon.fandom.com 402 verdi.
- **Bizim için:** paralel iş akışının oyundaki karşılığı "ayrı bina"; ölçek tavanı 6 kişi. Tek projede kişi arttıkça yığılmayı alan sayısı (9) sınırlıyor, bizde karşılığı hat sayısı (9).

### 3.3 Mad Games Tycoon 2

- **Kural:** her geliştirme odası bir proje; "personel odaya atanır, odadaki kişiler tek projeye ait". Aynı odadaki kişiler ayrı projelere bölünemez; çözüm ikinci oda (oyuncu Zsenya, Kyouko Tsukino). Bölmek, "her ekibin potansiyelinin yalnız bir kısmını projeye vermesi" demek (oyuncu iddiası). https://steamcommunity.com/app/1342330/discussions/0/4357870314534527235
- **Deney:** joeball123 39 araştırmacı ile 39 becerili tasarımcı/programcıyı aynı oyunda denedi: araştırmacılar birincil geliştirmeyi yaklaşık iki hafta erken bitirdi ama yaklaşık iki kat hata ve %30 daha az puan getirdi; sonuç "hız çoğunlukla odadaki çalışan sayısının işlevi, beceri kaliteyi etkiler". (aynı bağlantı)
- **Yan stüdyo:** sözleşme işleri için küçük programcı odası, erken oyun parası ve yıldız ilerlemesi (aynı bağlantı).
- **Ölçek:** oda başına yaklaşık 10 kişi sınırı, 20 üstü kişide yol bulma sorunu, 200 çalışanda FPS düşüşü (R3 §4).
- **Şikâyet:** oyuncu "odanın içinde projeye göre personel atayamıyorum"u sert bir kısıt buldu, başkaları yönetilebilir tasarım tercihi dedi (aynı bağlantı).
- **Bizim için:** paralel proje = ayrı oda = oyuncu kararı. Ekip bölmek verimi kısmen düşürüyor; bu, bizdeki ekip bölme bedeline benzer bir yön ("bölmek bedelsiz değil").

### 3.4 Startup Company

- **Kural:** yönetici kapasitesi 3/5/8 kişi; bir yönetici aynı anda tek üretim planı yürütür, birden çok yönetici aynı planı paylaşabilir; yöneticisiz çalışan plan yoksa boşta bekler (R2 §2.3, §7.1).
- **Arz sorunu çözümü:** özelliğin **seviyesi** (kullanıcı tavanı) yükseltilir; framework özellik yuvası ve en yüksek seviye belirler: Cute Framework Basic 3 özellik seviye 10; 2.0 6 özellik seviye 500; 3.0 9 özellik seviye 2 000; Nitrosoft 2016 daha yüksek (R2 §7.2). Yani içerik sayısı sabit, iş yükü seviye sayısıyla sonsuz; her seviye "kullanıcı tavanını" artırıyor. Özellik kullanımdayken yükseltilebilir (R2 §2.2).
- **Üretim zinciri:** bileşen, modül, özellik; bir özellik onlarca bileşen ve modül kalemi doğurur (örnek: Comment: 6 Backend, 3 Network, 3 UI bileşeni + 3 Backend, 3 Input modülü; R2 §7.2). İş sayısı özellik sayısından çok daha fazla. Kuyruk ve "tekrar eden kuyruk" (Beta 18, 22) ve minimum stok (Beta 14) ile ölçek yönetimi.
- **Şikâyet:** 180 çalışanla tek tek ikramiye tıklama; satış temsilcisi mikro yönetimi; geliştirici cevabı "tıklamayı azalt, yöneticiye yetki ver" (R2 §4).
- **Bizim için:** büyük ekip için içerik sayısını artırmak yerine **aynı içeriğin seviyesini ve iş kırılımını** büyütmek bu oyunun cevabı. Bizim hatlarda kademe sayısı 3, kırılım yok (bir kademe bir kart).

### 3.5 Diğerleri

- Sprint, backlog ve hikâye puanı mekaniği olan bir yönetim oyunu bulunamadı (arama). Yaklaşan "Agile Team" adlı Steam oyunu (çıkış tarihi 3 Kasım 2026, henüz çıkmadı) ürün sahibi rolünde anlatı ağırlıklı; mekanik sayısı yok (https://store.steampowered.com/app/4459220/). Sınıflandırma: ilgisiz.
- Football Manager, Two Point Hospital gibi kuyruk/ekip oyunları R5'te var; burada tekrar yok.

### 3.6 Oyunlardan çıkan ortak desen

| Soru | Oyunlar | Desen |
|---|---|---|
| Paralel işi ne taşır | Software Inc. ekip, MGT2 oda, GDT bina/laboratuvar, Startup Company yönetici + plan | Oyuncunun adlandırdığı bir kap (ekip/oda/plan) |
| Kap büyüklüğü | 10-12 (Software Inc.), ~10 (MGT2), 6 (GDT ofis), 3/5/8 (Startup yönetici) | Küçük, sayı bilinen |
| Bölmenin bedeli | MGT2 potansiyel bölünür, Software Inc. ikincil ekip zararlı (oyuncu), GDT yok | Bedelsiz değil |
| İçerik tükenmesi | Startup Company seviye ve bileşen kırılımı; diğerleri belirgin çözüm yok | Seviye/kırılım |
| Şikâyet | Kişi başı tıklama, "kim nerede" izlenemiyor | Toplu işlem ve özet |

---

## 4. Sentez: ekip büyüdükçe sprint nasıl ölçeklenmeli

Bu bölüm karar değil; seçenek, gerekçe ve ölçekte kırılma testi.

### 4.1 Ana ayrım: kart sayısı kuraldan değil arzdan çıkar

- Pratikte (Cohn) ve bizim kapasite kuralımızda kart sayısı **sonuç**: kapasite bölü kart büyüklüğü. Bizde 0,75 kart/kişi/sprint (§0). Bu kural 1, 3, 6, 12, 25, 50 kişide kırılmaz çünkü oran.
- Bu yüzden "ekibe bağlı kart yuvası" (3 kişiye 2, 12 kişiye 8 kart gibi) gerekmiyor. Yuva eklemek sabit sayı koymak olur (bağlayıcı ilke 1) ve bugünkü tavan zaten aynı işi yapıyor.
- Kırılan yer **arz**: ekibin yapabileceği kart sayısı artıyor, yapılabilecek kart sayısı artmıyor (§1.9, P1-P5).

### 4.2 Kart arzı nasıl yetmeli: seçenekler

Hedef büyüklük (benzetim, §1.9): açık aday sayısı P, 2 haftalık sprintte boşta payını tabana (yaklaşık %6-9) indirmek için yaklaşık 0,9 çarpı ekip; 1 haftalıkta yaklaşık 0,45 çarpı ekip. Karşılığı: 12 kişi 9-11, 25 kişi 20, 50 kişi 45 (2 hafta); 50 kişi 20 (1 hafta). Tüketim: kişi başı haftada yaklaşık 0,38 kart (2 puan bölü ortalama 5,3); 12 kişi 130 haftada yaklaşık 590, 25 kişi 1 240, 50 kişi 2 470 kart. Katalog 27-31 kademe.
**Sonuç:** hat ya da kademe eklemek tek başına yetmez (28 hat 12 kişiyi 20 hafta oyalıyor). Yenilenen bir arz kaynağı gerek.

| Seçenek | Ne olur | Neden var | Ölçek notu (1 ile 50) | Dikkat |
|---|---|---|---|---|
| A. Kademe sayısını artır (K4 ve üstü) ve kademeyi alt kartlara böl ("kol") | Hat başına eşzamanlı kart ×2-3, toplam 144 puan ×2-3 | Startup Company'de bileşen/modül kırılımı iş sayısını çarpıyor | 12 kişiyi 8 yerine 16-24 hafta oyalar; 50 kişi için hâlâ kısa | Yazım yükü büyük; sabit ek içerik, ölçekle orantılı değil |
| B. Müşteri ve pazar kaynaklı kartlar | B2B talebi kademenin yerine geçmesin, ayrı iş olsun (özel entegrasyon, hesaba özel istek); B2C'de kitle talebi | Arz iş büyüklüğüne (müşteri sayısına) bağlı olur; "talep" zaten oyunda var ve görünür (sprint_catalog.gd:226) | 1 müşteri: 1 kart; 50 müşteri: 50 kart; orantılı | Müşteri kaybı/yenileme kararlarıyla (C4/C5) çakışmaması; gizli model yok |
| C. Seviye kartları (kademe üstü) | K3'ten sonra hat "seviye" kazanır; efor ürün büyüklüğüne (kullanıcı/hesap) bağlı; etkisi oyuncuya görünür (kullanıcı tavanı, sunucu yükü) | Startup Company'nin çözümü; D modelindeki "tavan işin büyüklüğünden gelir" ilkesi | İş büyüklüğüne oranlı; ekip ne kadar büyükse ürün de o kadar büyük | Her seviyenin görünür bir kazancı olmalı (yoksa dolgu); sunucu yükü (C1) ile bağlanabilir |
| D. Hat sayısını artır (pazaryeri 14, ERP 12 hat) | Eşzamanlı kart 14 | Zaten planlı (PRD_URUN_DERINLIK) | 12 kişi 11 hafta (§1.9) | Lineer değil; tek başına yetmez |
| E. Sürekli işler (bakım, teknik borç) | Ürün büyüdükçe artan zorunlu iş | Gerçek hayatta var | Ekiple ölçeklenir | **Reddedilmiş fikir yakını:** "sürekli hata sprinti" ve gizli ceza. Oyuncuya görünür, bir tercih olmadan eklenmemeli. Önerilmiyor |

Bu tablo seçenek; seçim yok. A+B+C birleşimi ölçek açısından tek başına her birinden iyi görünüyor (benzetilmedi, tahmin).

### 4.3 Hat zinciri ve sprint süresi

- Hat zinciri K1, K2, K3 art arda kapanışlarda yazıldığı için ekipten bağımsız alt sınır koyuyor (P3). İki yol: kademeleri alt kartlara bölüp aynı sprintte birden çok kolun ilerlemesine izin vermek (A), ya da tek hattın K2'sini K1 kapanır kapanmaz sprint ortasında açmak (sprint içi çekme, §4.5).
- Sprint süresi: 2 haftalıkta arz ihtiyacı kişi başı 0,9 aday, 1 haftalıkta 0,45 (§1.9) ama haftada tüketilen kart aynı. Yani 1 haftalık sprint arzı "hızlı yeniliyor", 2 haftalık "daha çok aday birden" istiyor. Gerçek pratikte süre kalem sayısını değil boyutunu değiştiriyor (Cohn). **Şirket çapında tek süre** (LeSS: "tek ortak sprint") oyuncunun planlama yükünü küçük tutuyor; her ekibe ayrı süre vermek planı katlar.

### 4.4 Ekip yapısı: nereden itibaren, nasıl

| Kişi | Önerilen yapı (seçenek) | Dayanak |
|---|---|---|
| 1-9 | Tek ekip, tek sütun (bugünkü kurgu) | Scrum Guide ≤10; Software Inc. 10-12 etkin |
| 10-15 | Tek ekip ya da iki ekip; ilk lider burada | R4 §2.5 (yönetici 10-15'te); Software Inc. 10-12 |
| 16-30 | 3-4 ekip, ekip başına 4-9 kişi ve bir lider; alan eşlemesi | LeSS 2-8 ekip; S@S SoS 4-5 ekip |
| 31-50 | 5-7 ekip; her ekip bir alan (Çekirdek, Onboarding, Entegrasyon/Büyüme, Güven, Gelir) | LeSS "gereksinim alanı"; Spotify misyon başına squad; kabile <100 |

- **Alan sayısı yedi ekip tavanıyla uyumlu:** `sprint.json` 5-6 alan tanımlıyor (§1.6). Her ekip bir alanı sahiplenirse arz de alana bölünür: kimlik alanının 5 hattı en büyük ekibe, Gelir tek kartlı olduğu için küçük ekibe düşer. (Çıkarım: alan başına kart sayısı eşit değil; eşitsiz ekip büyüklüğü gerekebilir.)
- **Bölmenin bedeli:** MGT2'de "bölmek potansiyeli böler", Software Inc.'te ikincil ekip zararlı (oyuncu). Bizde bedel ekip içi kayıp (D1: ekip başına lider, ileride EA) olabilir; şirket çapında ceza değil (reddedilmiş).
- **Ortak sprint ritmi:** tek kapanış, tek sürüm notu (LeSS, §2.2); ekipler plan ekranında şerit.
- **Çoklu PM:** `quarter_pm` ilk PM'i alıyor (P9); ekip başına PM ya da lider planını kendi alanında yapacaksa bu işlev ekip parametresi alır. Her ekibin lideri yoksa bugünkü gibi tek PM tüm alanları planlar.

### 4.5 Sprint içi çekme (boşta kalanlar)

- Bugün koşan sprintte yeni kart eklenemiyor, boşta kalan kişi o sprintin sonunu bekliyor (P6).
- Seçenekler: (1) hiç değişmesin (oyuncu planlar; boşta uyarısı yeter); (2) hafta başı otomatik: kartı bitirenler için sonraki sütundaki ilk karttan çekilir (Kanban "çekme" mantığı, Kanban Guide); (3) oyuncu sprint içinde "+" ile ekler. HARITA şu an "iş kendiliğinden verilmez" diyor (`HARITA.md:152`), yani (2) bir ilke değişikliği.
- Ölçekte: 50 kişide kart arzı yoksa çekme de bir şey çekmez; arz çözülünce (4.2) çekme gerekli hâle gelir. Kartın dolması için "sonraki sütun" önden hazırlık sütunu zaten var.

### 4.6 Demo (yaklaşık 10 kişiye kadar) ve Erken Erişim (20-50 kişi) ayrımı

| | Demo (1-10 kişi, 0-130 hafta) | EA (20-50 kişi) |
|---|---|---|
| Yapı | Tek ekip, tek sütun, mevcut düzen | 3-7 ekip, tek ritim, ekip şeridi |
| Sorun | Arz: katalog 8-15 haftada biter (6-10 kişi, kısıtsız) | Arz ve plan yükü |
| Gerekli | 130 hafta için kapı hızı ve/veya seviye/müşteri kartı; PRD_URUN_DERINLIK kapısının ölçümü | Yukarıdakiler + ekip nesnesi + çoklu PM planı |
| Önce ne | `--sprint-probe` ile kapılı ağaç ölçümü (K2 yıldız, K3 Ar-Ge) | Ekip modeli onayı (D1 EA) |

Not: `D_MODEL_v2.md:772` "EA'da sonsuz koşu için kart arzı gerekir" demişti; bu rapor aynı sonuca ulaşıp demoyu da kapsıyor.

### 4.7 50 kişide oyuncunun planlama yükü

- Tek ekip mantığıyla 2 haftalıkta yaklaşık 38 kart (0,75 x 50), 1 haftalıkta 19. Cohn'un 5-10 kart/ekip aralığıyla 6-7 ekip x 5-8 kart = 30-56 kart tutarlı.
- Oyuncu tek tek "+" etmemeli. Bugün zaten tek tuş var: `apply_lead` (öneri) ve PM devri. Ölçeklenmesi için seçenek: ekip başına öneri (lider), oyuncu ekip başına "onayla" (6-7 tıklama) ve gerekirse tek tek değiştirir. Mevcut `delegate` anahtarı ekip başına PM'e genişler.
- Plan ekranında ekip satırı kişi başı değil aşama başı (D6, avatar satırı) olursa 50 satır sorunu da kalkar.
- Teknik risk: P11 (derin kopya + oynatma maliyeti). 40 kart ve 50 kişide ölçülmedi; kabul ölçütüne eklenmeli.

### 4.8 Ölçek test matrisi (kural 1 gereği)

Her seçenek şu 6 + 3 bileşimde kontrol edilmeli: 1, 3, 6, 12, 25, 50 kişi; hepsi testçi, aynı rolde 10 kişi, küçük karta çok kişi (S12 tipi), PM'siz, testçisiz. Ölçüt (öneri): boşta pay %10 altı **ya da** boşta neden yazılı ("kart yok", "test dolu", "rol uymuyor"). D_SIM kriter 9'un genişletmesi: S12 yerine gerçek arz sınırı.

---

## Tasarımcıya 10 madde

1. **Kart sayısını kural değil sonuç say.** Kapasite oranı (yük en çok %125, D'nin aşama tavanı) kalsın; ekibe bağlı sabit kart yuvası ekleme. Kanıt: 0,75 kart/kişi/sprint, Cohn aralığı 0,7-1,4.
2. **Asıl iş kart arzı.** Hedef: açık aday sayısı yaklaşık 0,9 x ekip (2 hafta) ya da 0,45 x ekip (1 hafta). Bugün üst sınır 9-14 ve 25-50 kişide sprintte hep 9 kart (§1.9).
3. **Arzı tek kaynaktan büyütme.** Kademe/kol (A), müşteri ve pazar kaynaklı kartlar (B), seviye kartları (C) birlikte düşün. Hat sayısı (D) tek başına yetmez. Hangisinin görünür bir kazancı ve "neden var" cevabı olduğunu seçimde yaz.
4. **Talep kartı arzı büyütmeli mi karar ver.** Bugün talep, kademe kartının yerine geçiyor (`sprint_catalog.gd:226-236`); 50 müşteri tek kart. Ayrı iş olması arzı müşteriyle ölçekler, ama C4/C5 kararlarıyla (yenileme, memnuniyet) birlikte düşünülmeli.
5. **Demo içeriğini ölç.** Kapısız modelde 6 kişi 15, 10 kişi 8 hafta (9 hat); 6 kişi 14 hatta 23 hafta. `PRD_URUN_DERINLIK.md:812` kapısı (104. haftada en çok %60) ancak Ar-Ge, yıldız ve lisans kapıları gerçek hız sınırıysa tutar. Kapılı ölçümü `--sprint-probe` ile yap; `D_MODEL_v2.md:772` cümlesini düzelt.
6. **Ekip nesnesi EA'da, demoda değil.** 10 kişiye kadar tek ekip. 10'dan sonra 3-9 kişilik ekipler, ekip başına lider (Erdem'in D1 kararı), alan eşlemesi (5-6 alan 5-7 ekibe denk). Şirket çapında verim cezası yok; kayıp ekip içinde.
7. **Tek ritim.** Tek sprint süresi (1|2), tek kapanış, tek sürüm notu; ekipler plan ekranında şerit. Ekip başına ayrı süre planlama yükünü katlar (LeSS: tek ortak sprint).
8. **Planlama yükünü sınırla.** 50 kişide yaklaşık 38 kart: oyuncu ekip başına öneriyi onaylasın (6-7 eylem), kart değiştirme isteğe bağlı olsun. `quarter_pm` ilk PM'e bağlı (P9); çok PM'li planı tasarla.
9. **Sprint içi çekmeyi ayrı karara bağla.** Bugün kart eklenemiyor ve iş kendiliğinden verilmiyor (`HARITA.md:152`). Arz çözülünce boşta kalma sprint süresi kadar uzayabilir; (1) olduğu gibi, (2) otomatik çekme, (3) oyuncu ekler seçenekleri arasında seç. Boşta nedenini (kart yok, test dolu, rol uymuyor) plan ekranı cümlesi olarak göster (D6 darboğaz cümlesi).
10. **Kabul ölçütü ekle.** 1, 3, 6, 12, 25, 50 kişi ve üç bileşimde (§4.8) probe: sprintteki kart, boşta payı ve nedeni, katalog bitişi, plan tahmini = sonuç (adsız uyuşmazlık 0), ayrıca 40 kart x 50 kişide plan hesabının süresi (P11).

---

## Kaynak listesi

**Kod ve veri (bu repo, satırlar yukarıda):** `scripts/systems/sprint_system.gd`, `scripts/systems/sprint_catalog.gd`, `data/product/sprint.json`, `data/product/lines/{note_tool,video_clip,erp,shared}.json`, `data/techtree/rnd_tree.json`, `scripts/debug/sprint_probe.gd`, `scripts/debug/run_probe.gd`, `scripts/systems/hr_constants.gd`, `scripts/systems/hr_system.gd`, `docs/HARITA.md`, `docs/tasks/PRD_URUN_DERINLIK.md`, `docs/tasks/faz_cde/{D_MODEL_v2,D_SIM}.md`, `docs/tasks/faz_cde/arastirma/R1..R5`.

**Dış kaynaklar (açılanlar):**
- Scrum Guide 2020: https://scrumguides.org/scrum-guide.html
- LeSS çerçevesi: https://less.works/less/framework/introduction
- Scrum@Scale kılavuzu: https://www.scrumatscale.com/scrum-at-scale-guide-online/
- SAFe Agile Release Train: https://framework.scaledagile.com/agile-release-train ; Agile Teams: https://framework.scaledagile.com/agile-teams ; Iteration Planning (giriş duvarı): https://framework.scaledagile.com/iteration-planning
- Spotify (Kniberg ve Ivarsson 2012): https://blog.crisp.se/wp-content/uploads/2012/11/SpotifyScaling.pdf
- Mike Cohn, swarming: https://www.mountaingoatsoftware.com/blog/should-a-team-swarm-on-to-one-backlog-item-at-a-time
- Scrum Inc., Yesterday's Weather: https://www.scruminc.com/yesterdays-weather/
- Kanban Guide: https://kanbanguides.org/english/
- Sprint uzunluğu çalışması: https://scitepress.org/PublishedPapers/2022/110377
- Software Inc. wiki, Teams: https://softwareinc.coredumping.com/wiki/index.php/Teams ; Project Management: https://softwareinc.coredumping.com/wiki/index.php/Project_Management
- Steam tartışmaları: Software Inc.: https://steamcommunity.com/app/362620/discussions/0/2119355556482487720 , https://steamcommunity.com/app/362620/discussions/0/594820656446233293 , https://steamcommunity.com/app/362620/discussions/0/535152511373031381 ; Game Dev Tycoon: https://steamcommunity.com/app/239820/discussions/0/3105763714516541002 , https://steamcommunity.com/app/239820/discussions/0/810938810725487045 , https://steamcommunity.com/app/239820/discussions/0/864977564465087976 ; Mad Games Tycoon 2: https://steamcommunity.com/app/1342330/discussions/0/4357870314534527235
- Steam, Agile Team: https://store.steampowered.com/app/4459220/

**Yalnız arama özeti (sayfa içeriği doğrulanmadı):** VersionOne 6. rapor, Scrum Alliance 2015, Ambysoft 2018 (sprint uzunluğu); Applied Frameworks (büyüyen ekipte Yesterday's Weather); Cohn slaytındaki 6'dan 7'ye hız etkisi; StickyMinds "product backlog rules of thumb"; Nexus (scrum.org/node/38850).

## Bulunamayanlar

- Game Dev Tycoon: sözleşme işleri ile oyunun aynı anda yürüyüp yürümediği, laboratuvar personel sayıları (fandom 402).
- SAFe ART kaç ekip, PI kaç hafta, normalleştirilmiş hikâye puanı (giriş duvarı); bunlar model bilgisi.
- Spotify squad büyüklüğü (makalede yok).
- Epik ve paralel iş akışının resmi tanımı (Atlassian/SAFe sayfaları açılmadı).
- Mad Games Tycoon 2 için resmi kaynak (wiki kapalı); yalnız oyuncu iddiaları.
- Sprint ve hikâye puanı mekaniği olan başka yönetim oyunu.
- Benzetimin motor çıktısıyla doğrulaması (Godot koşturulmadı); yalnız D_SIM ile tutarlılık kontrolü yapıldı.
