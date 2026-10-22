# D0s · Simülasyon: atama, PM eşlemesi, sabit 2 hafta ve çekme
18 Ekim 2026 · D0s alt ajanı (Sonnet) · Godot koşturulmadı, oyun dosyalarına, `strings.csv`'ye ve `data/`'ya dokunulmadı, git'te durum değiştirilmedi. Her şey `docs/tasks/faz_cde/d_taslak/dsim/v3/` altındadır. Bağlayıcı belgeler: `PRD_FAZ_D_EKIP_SPRINT.md` (Karar 1 ile 16, §4.1, §5 madde 1, §10), `ERDEM_QCD_CEVAP.md` §2.3, `D_MODEL_v3.md` §3, §6 ve inceleme notu, `D_SIM_v3.md`. Sayıların hepsi koşulardan gelir; tahmin yazılmadı.

## 0. E1 özeti
1. **Karar 4'ün birebir okuması küçük kartı açlığa mahkûm ediyor.** Hem kaç kişi alacağını hem kimin gideceğini aşama ihtiyacı belirleyince MVP 6 kişide 6., 25 kişide 8., 50 kişide 12. haftaya kayıyor (öneri R: 4, 2, 2), açık hata 50 kişide 21,8 (R: 13,2), söz veren 6 kişilik ekipte vadesi gelen sözlerin %27'si kaçıyor (R: %0,3). **Karar:** "kaç kişi alacağını plan sırası, kimin gideceğini büyüklük belirlesin" (R). Bu okumada Karar 4 eski atamadan iyi: 25 kişide 264 ve 50 kişide 514 puan/hf (eski atama 250 ve 494,5), açık hata 10,8 ve 13,2 (15,8 ve 22,8).
2. **PM kuralı:** PRD'nin haftalık eşlemesi (fayda hazırlayanın yıldızından) PM eklemeyi düşürüyor: 36. kişi PM, −4,3 ± 0,2 puan/hf, 100 tohumun 94'ünde eksi. PRD'nin −2,5'i yeniden üretildi (eski oynatma, hazırlayanın yıldızı: ilk 20 tohum medyanı −2,5; 100 tohum −2,65 ± 0,22). "Yalnız hazırlıksız kalacak kartı hazırlar" cümlesini sprint ufkuyla okuyan kural −0,32 ± 0,27, yani fark yok. **Karar:** ufuklu okuma.
3. **Sabit 2 hafta:** erken kapanan sprint 0 (9.460 koşu), tahmin = sonuç farkı en çok 1,4e-14. Plan 3 kişiden büyük ekiplerde %100 ile %123 dolu olduğu için çekme orada hiç devreye girmiyor; yalnız tek kurucuda çalışıyor (0,17 kart/sprint, teslim 3,5 → 4,5). Tek kurucuda bedeli var: teslim 4,5 (eski kural 5,1), boşta %26 (eski %14); hata sprinti %0,6 (PRD'nin 2 haftalıkta ölçülen %0,4'ü).
4. **"Yalnız bitecek kartlar, en çok bir devreden" kalkanı 2 haftalık sprintte uygulanamaz:** plan doluluğu %34 ile %57'ye düşüyor, teslim 12 / 25 / 50 kişide −%40 / −%46 / −%48 (birebir okumaya göre), boşta %30 ile %48. **Karar:** kalkan kalksın; "sprintte en çok bir talep" kalsın (ölçümler kalkansız).
5. **Kadro dilimi 8 kalsın:** 40'ta teslim sınırsız arzda −%2 ile −%3,5 (3 kişide −%9,5), kaynaklı arzda 12 / 25 / 50 kişide −%3,6 / −%3,9 / −%9,7, boşta +2 ile +8 puan; arz yetmezliği 25 kişiye kadar yok, 50 kişide %37,5 → %50.
6. **Söz kartı:** R'de "söz önce" gereksiz (3 kişide kaçan %20 → %12, 6 kişide %0,3 → %0, daha büyükte %0). Birebir okumada şart (6 / 12 / 25 kişide kaçan %27 / %12 / %11 → %0,3 / %0 / %0). Büyük kartın süresi değişmiyor (50 kişide 4,0 hf).
7. **Testçiye Geliştirme ×0,7 vermek** teslimi çoğu ekipte değiştirmiyor (S3-S6 ±%1; 5★ testçili 6 kişide 51,0 → 60,0) ama testçinin kalitesini siliyor (1★ → 5★ testçide kaçan hata −%62 yerine −%30): kapı 9 yalnız "testçi yalnız Test" kolunda geçiyor. Düzeltme alt aşamasından dışlamak (Karar 6) fark yaratmıyor.
8. **Derinlik kartı adı:** hat başına 6 ad yetmez. 104 haftada hat başına açılan derinlik kartı 3 kişide 13, 6 kişide 25, 12 kişide 47, 25 kişide 102, 50 kişide 177 (tek kurucuda medyan hat 0; en çok kullanılan hat medyan koşuda 9, hiçbir koşuda 12'yi geçmiyor).
9. **Kapılar (R okumasıyla):** 28 kapıdan (eski 23 + yeni 5) R okumasında **14 geçti, 13 kaldı, 1 ölçülmedi** (22, EA takımı: kapsam dışı). Geçenler: 3, 4, 5, 11, 13, 14, 15, 18, 19, 20, 21 ve yeni `atama_sirasi`, `kendi_karti`, `early_closed`. Kalanlar §13'te nedenleriyle: tolerans 0'ın gürültü sınırında kaldığı kapılar (1, `pm_ekleme`), testçinin varsayılan kutusu (9, 10), küçük ekip ve kurucu hücreleri (2, 6, 7, 8, `plan_fill` 1 kişide %70), 0. haftadan 50 kişi yüklemesi (16, 17), söz yoğunluğu varsayımı (12) ve koşullu moral bandı (23).
10. **Erdem'e kalan sorular:** (a) Karar 4'te kadroyu plan sırası mı belirlesin (R), büyüklük mü (birebir)? (b) PM'de ufuklu okuma mı? (c) Bitecek-kart kalkanı kalksın mı? (d) Çok aşamaya uyan kurucu için "sınıf önce" mi "öncelikli kart önce" mi (§3.4: kurucu büyümesinde MVP gecikmesi ya da kurucunun kendi işinin düşmesi)? (e) Testçi Geliştirme yapsın mı? (f) Derinlik kartı için hat başına kaç ad? (g) Tek kurucuda erken kapanış/çekme bedeli kabul mü (teslim −%12, boşta +12 puan)?

## 1. Ne ölçüldü, nasıl okunur
- **Betik:** `dsim/v3/dsim3.py` (D_SIM_v3'ün betiği; değişmeyen kopyası `dsim3_orig.py`, inceleyen ona karşı diff alır). Kurallar ortam anahtarıdır; varsayılan PRD'nin okuması, `D3_LEGACY=1` eski kural. Yeni oynatma yolu (`week2`, `assign_k4`, `Puller`, `plan2`) eskisinin yanına eklendi; eski yol (`run_week`, `plan`) olduğu gibi duruyor.
- **Tohum ve pencere:** her senaryo 20 tohum (1 ile 20), 60 hafta (21-60 pencere); kaynaklı arz ve büyüme eğrisi 130, derinlik tüketimi 104 hafta; tablolar tohum medyanıdır. PM adımı 100 tohum.
- **S1 ile S6 = 1, 3, 6, 12, 25, 50 kişi.** Doğrulandı: koşuların `n` alanı sırasıyla 1, 3, 6, 12, 25, 50 (Yorum 1).
- **Okumalar (tablolardaki satırlar):**
  - **Eski:** D_SIM_v3 kuralı (`D3_LEGACY=1`): sprint sırasıyla doldurma, erken kapanış, çekme yok, PM haftanın en iyisi.
  - **R (önerilen okuma):** `D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h` ve PRD'nin geri kalanı. Yani: kadroyu plan sırası, kişiyi büyüklük belirler; PM'de ufuklu eşleme; sabit 2 hafta ve çekme; alım kuralı; altı basamaklı öneri; "sprintte en çok bir talep" kalkanı; Y × U tabanı 0,3; GÖZÜ YÜKSEKTE ×1,15; istekler yalnız 3★ ve üstü hesaptan; derinlik 1 + ⌊hesap ÷ 5⌋ (en çok 8); düzeltme kartı 2 × hata (alt sınır yok); FILL_SKIP 12.
  - **PRD birebir (R_size):** R'den farkı: `D3_KEYMODE=size D3_PMRULE=karar4` (kadro ve kişi büyüklüğe göre, PM haftalık).
  - **PRD birebir tam (P):** ortam değişkeni yok, her şey kodun varsayılanı; R_size + bitecek-kart kalkanı.
  - **Kural kolları:** R'den tek farkla: `R_asgsprint` (atama kart sırasıyla), `R_nopull` (çekme yok), `R_early` (erken kapanış var), `R_shield` (bitecek-kart kalkanı), `R_slice40`, `R_pf1`, `R_tf0`/`R_tf1`/`R_tfm`.
- **Kapı değerlendirmesi** (§13): `dgates.py`; eşikler PRD §4.1'e göre hizalandı (ekleme: tolerans yok; kurucu işi %12; MVP sprint sonu, 6, en geç 8; öneri doluluğu %94).

## 2. Doğrulama (sonuç buna dayanıyor)
- **Eski yol aynen korundu:** `D3_LEGACY=1` ile `dsim3.py` ve `dsim3_orig.py` 14 senaryo × 2 tohumda 1.540 metrikte 0 fark (ayrıca S12 yaması sonrası 5 senaryo × 2 tohumda 550 metrikte 0 fark). Yeni yol + eski anahtarlar (atama sprint sırası, PM best, erken kapanış, çekme yok, eski öneri, kalkan yok) ile aynı karşılaştırma 990 metrikte 3 fark çıkıyor; üçü de sayaç, ölçü değil: S12'de iki `new_sp` (tek kart kipinde alınan kart artık sayılıyor) ve bir `stop_phase` (tutmayan aşamayı sayma biçimi); teslim, boşta, hata, MVP, doluluk dahil bütün ölçüler aynı. Yani yeni yol, anahtarlar kapalıyken eski betiği yeniden üretiyor.
- **Tahmin = sonuç:** plan oynatması (çekilen kartlar, hazırlık, önden tasarım dahil) ile kapanış arasında kart başına aşama ilerlemesi, bitiş, hata sayısı, bulunan hata ve düzeltme işi farkı R koşularında en çok 1,4e-14 (9.460 koşu) (kapı 14: 1e-6).
- **Elle doğrulama ve mikro testler** (`dcheck.py`, 12 test, hepsi geçti):

| Mikro test | Beklenen | Bulunan | Sonuç |
|---|---|---|---|
| Uymayan iş tabanı (PM, Test kutusu, qa 2) | 3,0 puan/hf (0,256 → 0,3) | 3.00 | GEÇTİ |
| Uymayan iş, yüksek Test puanı (qa 8) | 10 x Y(8) x 0,4 = 6,16 (taban işlemez) | 6.16 | GEÇTİ |
| Huy: GÖZÜ YÜKSEKTE x1,15, TİTİZ x0,85 | 11,6 / 13,34 / 9,86 (Y(6) = 1,16) | 11.60 / 13.34 / 9.86 | GEÇTİ |
| Düzeltme kartı | 1 hata 2 - 3 hata 6 - 5 hata 10 - 12 hata 24 | 1 hata 2 - 3 hata 6 - 5 hata 10 - 12 hata 24 | GEÇTİ |
| Karar 4 (PRD birebir, KEYMODE=size): 5★,5★,3★,3★,1★,1★ geliştirici; kartlar 26, 16, 10 | 26'ya en hızlı dört (5a 5b 3a 3b), 16'ya kalan iki (1a 1b), 10'a kimse | {26.0: ['3a', '3b', '5a', '5b'], 16.0: ['1a', '1b']} | GEÇTİ |
| Karar 4 (KEYMODE=plan): aynı girdi, kadroyu plan sırası belirler | 10'a, 16'ya, 26'ya ikişer kişi; en hızlı iki 26'da, sonraki iki 16'da, son iki 10'da | {26.0: ['5a', '5b'], 16.0: ['3a', '3b'], 10.0: ['1a', '1b']} | GEÇTİ |
| Aynı girdi aynı atama (kişi listesi ters ve karışık, iki kip) | üç listede de aynı (kişi, kart) çiftleri | size: True, plan: True | GEÇTİ |
| Uymayan iş koşulu (PM, Test kutusu) | hazırlık varken Test'e girmez; hazırlık yokken girer | hazırlık var: False; yok: True | GEÇTİ |
| Kendi kartı x0,6 (kurucu dahil) | C = 0,57 x sqrt(Y(qa)) x 0,6 (kendi) / x 1,0 (başkası) | kurucu kendi kartı, qa 0 C=0.2418 (beklenen 0.2418); geliştirici kendi kartı, qa 6 C=0.3683 (beklenen 0.3683); testçi başkasının kartı, qa 6 C=0.6139 (beklenen 0.6139) | GEÇTİ |
| PM eşleme: 5★ ve 1★ PM; kartlar 40, 25, 15 | pm_5 büyük karttan başlar (40, sonra 25); pm_1 kalanı alır; her kartın tek hazırlayanı | {15: 'pm_5', 40: 'pm_5', 25: 'pm_5'} | GEÇTİ |
| Yeni PM daha önce başlanmış kartı almaz, hazırlanmamışı alır | eski kartların hazırlayanı değişmez; yeni kart pm_3'te | True; yeni=pm_3 | GEÇTİ |
| Çekme: ekip boşta kalınca sıradaki kart sprinte girer | ekip boşta kalınca en az bir kart aynı sprintte çekilir | 2 kart sprintte; bitenler: [True, False] | GEÇTİ |

- **Aynı girdi aynı atama, tüm koşu düzeyinde** (`ddet.py`): aynı ekip kişi listesi ters ve karışık sırayla verildiğinde atama kaydı ve sonuç aynı:

| Senaryo (16 hf) | Atama kaydı (satır) | Kişi listesi ters ve karışık: aynı atama | Teslim | Plan-kapanis farkı |
|---|---|---|---|---|
| S3 | 162 | evet | 47,50 | 8.9e-16 |
| S4 | 227 | evet | 90,00 | 8.9e-16 |
| HUY|S3 | 156 | evet | 50,00 | 8.9e-16 |
| HUY|S4 | 220 | evet | 90,00 | 8.9e-16 |
| A|S3|kaynakli|2 | 157 | evet | 40,94 | 6.7e-16 |
| S5 | 432 | evet | 220,00 | 8.9e-16 |

## 3. §4.1 madde 1
### 3.1 `ekleme_dusurmez` (tolerans yok), daha iyisiyle değiştirme dahil
Aileler: taban ekibe bir kişi (S2-S6 × 5 ekleme), 1 → 50 kişi ekleme eğrisi, kurucu büyümesi (4 kurucu tipi × 6 sıra × 3 alım), ve yeni **değiştirme** senaryosu (`REP`): taban ekibin bir rolündeki en zayıf kişi bir yıldız (+2 puan) ya da 5★ bir kişiyle değiştirilir (S2-S6, rol başına; 36 sınama).

| Aile | Adım | En kötü (puan/hf) | En kötü adım | Eksi adım | Sıfır adım | Adım medyanı |
|---|---|---|---|---|---|---|
| Taban ekibe bir kişi (S2-S6 x 5 ekleme) | 25 | −1,0 | S5 +3★ tasarımcı | 1 | 5 | 4,8 |
| Kişi ekleme eğrisi 1→50 | 49 | −4,0 | eğri 41→42 | 3 | 1 | 5,0 |
| Kurucu büyümesi (4 tip x 6 sıra x 3 alım) | 72 | 0,0 | G|gel4|uc-gel|+3 | 0 | 2 | 6,0 |
| Bir kişiyi aynı roldeki daha iyisiyle değiştirme | 36 | −0,6 | REP|S2|des|+1 | 2 | 6 | 3,3 |

En kötü on iki adım:

| Adım | Aile | Fark (puan/hf) |
|---|---|---|
| eğri 41→42 | C | −4,0 |
| S5 +3★ tasarımcı | B | −1,0 |
| eğri 23→24 | C | −1,0 |
| eğri 36→37 | C | −1,0 |
| REP|S2|des|+1 | REP | −0,6 |
| REP|S5|des|5 | REP | −0,5 |
| G|gel4|uc-gel|+3 | E | 0,0 |
| G|gel5|uc-gel|+3 | E | 0,0 |
| REP|S2|des|5 | REP | 0,0 |
| REP|S3|des|+1 | REP | 0,0 |
| REP|S3|des|5 | REP | 0,0 |
| REP|S4|des|+1 | REP | 0,0 |

Değiştirme matrisi (taban teslimine göre fark, puan/hf; "." o ekipte o rol yok):

| Taban | Taban teslim | dev +1★ | dev 5★ | test +1★ | test 5★ | des +1★ | des 5★ | pm +1★ | pm 5★ |
|---|---|---|---|---|---|---|---|---|---|
| S2 (3 kişi) | 21,1 | 3,1 | 7,3 | . | . | −0,6 | 0,0 | . | . |
| S3 (6 kişi) | 49,0 | 5,0 | 18,0 | 4,0 | 11,0 | 0,0 | 0,0 | 2,0 | 5,0 |
| S4 (12 kişi) | 109,0 | 3,5 | 9,0 | 3,0 | 9,0 | 0,0 | 0,0 | 0,0 | 10,0 |
| S5 (25 kişi) | 264,0 | 4,0 | 8,5 | 3,0 | 8,0 | 0,5 | −0,5 | 1,5 | 10,0 |
| S6 (50 kişi) | 514,0 | 1,0 | 1,5 | 1,0 | 3,5 | 11,0 | 9,5 | 2,0 | 13,0 |

**Okuma.** Kapı tolerans 0'da **KALDI**: 182 adımın (25 taban + 49 eğri + 72 kurucu + 36 değiştirme) 6'sı eksi: eğri 41→42 −4,0; eğri 23→24 −1,0; eğri 36→37 (PM) −1,0; S5'e +3★ tasarımcı −1,0; değiştirme: S2 tasarımcı +1★ −0,6 ve S5 tasarımcı 5★ −0,5. Kurucu büyümesinde eksi adım yok (iki sıfır adım). Gürültü ayrımı için her adımın aynı tohumlardaki ortalama farkı ve standart hatası da hesaplandı: ortalaması −2 standart hatanın altına inen (yani tohum gürültüsünden ayrılan) adım yalnız **eğri 41 → 42** (ortalama −2,85 ± 0,83, 20 tohumun 17'si eksi). O adımda eklenen geliştirici; ekip test darboğazında (Test satırı yükü kapasiteye oranı 0,97 → 1,02, Geliştirme 0,13 → 0,02), açık hata 14,5 → 19,8, teslim 423,0 → 419,0 (−%0,9). Olası neden: ek geliştirici test kuyruğuna daha çok kart sokuyor ve teste düşük yakalamalı kişiler giriyor; bu turda ayrıca sınanmadı. Yani "darboğaz olmayan role kişi eklemek hiçbir şey kazandırmaz" ve çok küçük bir kayıp doğurabilir; ekran bunu darboğaz cümlesiyle söylüyor (Karar 10). Değiştirme sınamalarında iki eksi değer (S2'de tasarımcı +1★: −0,6; S5'te tasarımcı 5★: −0,5) tohum gürültüsü büyüklüğünde. Kurucu büyümesinin 72 adımı: teslim 70 adımda arttı, 2'sinde artmadı (4★ ve 5★ geliştirmede güçlü kurucuya üçüncü geliştirici: 11,4 → 11,4 ve 12,0 → 12,0; ekip zaten doygun); MVP iki alım adımında gecikti (4 → 8 hf: 4★ ve 5★ güçlü kurucuya ilk alım tasarımcı iken); kurucunun kendi işi tabana göre en çok %8,1 düştü (kapı %12) ve işi önceki adıma göre %2'den çok düşen 9 adımın hepsinin nedeni kayıtlı (8'i iş yeni gelenle bölündü, 1'i aşama değişti). Kapı iki koşuldan kalıyor: teslim her adımda artmıyor ve MVP gecikiyor.

### 3.2 `pm_ekleme`: üç PM kolu yan yana ve "−2,5"in yeniden ölçümü
PM eklemenin teslim farkı (puan/hf). Kollar: **karar4h** (R: sprint ufkuyla "yalnız hazırlıksız kalacak kart"), **karar4** (PRD'nin haftalık okuması), **best** (v3: fayda haftanın en iyi PM'inden), **preparer** (fayda kartın hazırlayanından, eski kuyruk sırası: "kartı hazırlayanın yıldızı" kuralı).

| Kural | Tohum | 36. kişi: teslim (medyan) | 37. kişi (PM) | Fark (medyan, tüm tohum) | Fark (ilk 20 tohum, kapı okuması) | Ortalama fark +- SE | Eksi tohum |
|---|---|---|---|---|---|---|---|
| karar4h: Karar 4 + ufuklu (yalnız hazırlıksız kalacak kart) | 100 | 382,0 | 382,0 | 0,0 | −1,0 | −0,32 +- 0,27 | 42/100 |
| karar4: Karar 4 haftalık (PRD birebir) | 100 | 382,0 | 378,0 | −4,0 | −4,0 | −4,26 +- 0,23 | 94/100 |
| best: fayda haftanın en iyi PM'inden | 100 | 397,0 | 398,0 | 1,0 | 1,5 | 1,52 +- 0,26 | 23/100 |
| preparer: fayda kartın hazırlayanından, kuyruk sırası | 100 | 381,0 | 379,0 | −2,0 | −2,5 | −2,80 +- 0,27 | 84/100 |
| ESKİ oynatma + preparer (prototipin ayarı: düzeltme kartı en az 5, eski derinlik) - PRD'nin −2,5'i | 100 | 379,0 | 377,0 | −2,0 | −2,5 | −2,65 +- 0,22 | 82/100 |
| ESKİ oynatma + best (v3 kuralı) | 100 | 398,0 | 398,0 | 0,0 | −0,5 | 0,11 +- 0,21 | 34/100 |

Sütun "fark (ilk 20 tohum)", kapının 20 tohumlu okumasıdır. PRD'nin −2,5'i **yeniden üretildi**: eski oynatmada (prototipin ayarıyla) "hazırlayanın yıldızı" kuralı 36 → 37. kişi PM için ilk 20 tohumda −2,5 verdi; 100 tohumda medyan −2,0, ortalama −2,65 ± 0,22. Eski oynatmada v3'ün "best" kuralı: −0,5 (ilk 20), −0,0 (100). Karar 4'ün haftalık okuması aynı kuralı daha da kötüleştiriyor (−4,3 ± 0,2; 94/100 tohum eksi). Nedeni büyük olasılıkla şu: en iyi PM her hafta kapasitesini bitirince yeni ve zayıf PM, daha iyi PM'lerin sonraki hafta alacağı kartları kapıyor ve kartın hazırlayanı kalıcı olduğu için o kart zayıf faydayla çıkıyor (ufuklu okumanın farkı kapatması bunu destekliyor; kart kart izlenmedi). Ufuklu okuma (bir PM sahipsiz kartı yalnız daha iyi PM'lerin sprint sonuna kadarki toplam kapasitesi yetmiyorsa alır) bu sızıntıyı kapatıyor: ortalama fark −0,32 ± 0,27, 100 tohumun 42'si eksi (fark yok). 20 tohumlu kapı okuması tolerans 0'da yine de −1,0 veriyor; tek adımın gürültüsü ±1 ile 3 puan olduğu için bu bir kural hatası değil, ölçüm sınırı (Yorum 18).

Bütün PM adımları ("eğri": 1 → 50 eğrisinde PM'in eklendiği altı adım; "S2" ile "S6": tabana PM eklenmiş hâli; "1 kişi + PM": kurucuya ilk PM):

| PM adımı (teslim farkı, puan/hf, 20 tohum medyanı) | karar4h | karar4 | best | preparer |
|---|---|---|---|---|
| eğri 5→6 | 8,0 | 8,0 | 8,0 | 8,0 |
| eğri 12→13 | 0,5 | −0,5 | 1,0 | 0,0 |
| eğri 20→21 | 10,0 | 6,5 | 11,0 | 8,0 |
| eğri 30→31 | 1,5 | −1,0 | 1,0 | 1,5 |
| eğri 36→37 | −1,0 | −4,0 | 1,5 | −2,5 |
| eğri 45→46 | 5,5 | 1,5 | 0,5 | 3,0 |
| S2 | 3,8 | 3,8 | 3,8 | 3,8 |
| S3 | 0,0 | 0,0 | 0,0 | 0,0 |
| S4 | 0,0 | 1,0 | −0,5 | 1,0 |
| S5 | 2,0 | −0,5 | 3,5 | 1,0 |
| S6 | 4,0 | 1,5 | 0,5 | 1,5 |
| 1 kişi + PM | 0,4 | 0,4 | 0,4 | 0,4 |

### 3.3 `atama_sirasi`
Her atama anında ve her aşamada (aynı anda atanan kişiler arasında) daha büyük işte daha yavaş kişi yok; hafta başındaki tam eşlemede de yok; uymayan iş yalnız boşta kalacak kişiye gidiyor; aynı girdi aynı atamayı veriyor (§2). Tablo: R koşularındaki atama satırı sayıları (her satır bir aşamada bir atama anı):

| Ekip (kişi) | Atama satırı (aşama x an) | Ters (yeni atananlar arasında) | Hafta başı tam eşleme | Hafta başı ters | Sürerken kartında kalan yavaş kişi (bilgi) | Uymayan iş verilen | Önden işi varken verilen |
|---|---|---|---|---|---|---|---|
| 1 | 2622 | 0 | 1062 | 0 | 0 | 0 | 0 |
| 3 | 6091 | 0 | 2136 | 0 | 0 | 0 | 0 |
| 6 | 9686 | 0 | 2548 | 0 | 68 | 0 | 0 |
| 12 | 15670 | 0 | 3219 | 0 | 2461 | 0 | 0 |
| 25 | 31684 | 0 | 3560 | 0 | 2813 | 0 | 0 |
| 50 | 59541 | 0 | 3560 | 0 | 5085 | 0 | 0 |
| HUY|S3 | 9801 | 0 | 2584 | 0 | 60 | 0 | 0 |
| HUY|S4 | 16316 | 0 | 3481 | 0 | 1954 | 0 | 0 |
| S3_PM_testkutulu | 9827 | 0 | 2549 | 0 | 79 | 341 | 0 |
| S4_PMsiz | 13594 | 0 | 2674 | 0 | 2632 | 0 | 0 |

"Sürerken kartında kalan yavaş kişi" bir ihlal değil bilgidir: PRD "kişi aşama ya da hafta bitene dek kartında kalır" dediği için, daha hızlı biri boşa çıkınca daha küçük karta gidebiliyor. 12 kişide 15.670 atama satırının 2.461'inde, 25 kişide 31.684'ünün 2.813'ünde, 50 kişide 59.541'inin 5.085'inde görülüyor.

**Çok aşamaya uyan kişi** (kurucu): önce sınıf (ana alan 0, kurucu 1, güçlü alanında 0, ikincil 2, uymayan 3), sonra o aşamadaki hız, sonra kimlik; aynı sınıf ve hızla birden çok aşamaya uyuyorsa en öncelikli açık kartın aşamasını alır. İlk deneme (Geliştirme, Tasarım, Test sabit sırası) 3 kişide MVP'yi 4. haftadan 8. haftaya kaydırıyordu; kurucuyu testte bekleyen kartı bırakıp yeni kartın tasarımına sokuyordu. Hâlâ açık bir durum var (§3.4).

### 3.4 Kurucu: sınıf önce mi, öncelikli kart önce mi
`kurucu_buyume` kapısında (72 alım adımı) R okumasında iki adımda MVP gecikiyor (4 → 8 hf: 4★ ve 5★ geliştirme güçlü kurucuya önce tasarımcı alınınca) ve iki adımda teslim artmıyor (üçüncü geliştirici). Neden: güçlü alanında kurucu sınıf 0'dır; ekipte yeni bir geliştirme kartı olduğu sürece sınıf-önce eşleme onu geliştirmede tutuyor ve MVP kartlarının testi (kurucu orada sınıf 1) bekliyor. Denenen düzeltme (`D3_FOUNDERROW=1`: kurucu uzmanlar yerleştikten sonra, en öncelikli açık kartın aşamasına girer): teslim 72 adımın hepsinde artıyor (en küçük artış +0,4), ekleme kapısının kurucu ailesinde 0/72 eksi adım, MVP gecikmesi 2'den 1'e iniyor (4★ kurucu, ilk alım 1★ geliştirici: 4 → 6), nedensiz düşüş 0/15; ama kurucunun kendi işi tabana göre en çok **%19,0** düşüyor (kapı %12), çünkü kurucu uzmanlar yerleştikten sonra boş kalan aşamaya gidiyor ve hızlı güçlü alan iddiasını kaybediyor. Yani iki okuma da bir koşuldan kalıyor: sınıf-önce MVP'yi ve teslim artışını, öncelik-önce kurucunun kendi işini kırıyor. Karar E1'in: sınıf-önce (PRD'nin yazdığı) ya da öncelik-önce.

## 4. Plan anındaki doluluk
Plan anında planın taşıdığı kalan iş ÷ sprint kapasitesi (medyan). Hedef ≥ %90 (bugün %13 ile %15).

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 81,1% | 99,6% | 97,5% | 115,9% | 121,3% | 123,2% |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 70,1% | 99,8% | 110,9% | 116,6% | 121,1% | 123,3% |
| R, atama eski (kart sırasıyla doldur) | 70,1% | 94,9% | 101,8% | 116,1% | 114,4% | 118,5% |
| R, çekme yok | 77,9% | 100,4% | 111,7% | 116,2% | 121,1% | 123,3% |
| R, erken kapanış var | 73,0% | 99,8% | 110,9% | 116,6% | 121,1% | 123,3% |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 70,1% | 94,7% | 109,3% | 116,3% | 121,5% | 123,1% |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 57,3% | 34,8% | 51,6% | 44,9% | 37,1% | 34,2% |
| R + bitecek-kart kalkanı | 59,3% | 37,6% | 53,2% | 46,6% | 40,1% | 34,5% |

Kaynaklı arz (hat başına K1 → K2 → K3 + derinlik + istek) için:

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | Büyüme 1→10 |
|---|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 46,5% | 114,1% | 119,4% | 122,4% | 123,7% | 117,1% | 120,9% |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 46,5% | 116,0% | 120,1% | 120,3% | 123,4% | 123,2% | 118,9% |
| R, atama eski (kart sırasıyla doldur) | 46,5% | 112,5% | 117,0% | 120,0% | 123,2% | 122,5% | 117,0% |
| R, çekme yok | 46,5% | 116,0% | 120,1% | 120,3% | 123,4% | 123,2% | 118,9% |
| R, erken kapanış var | 68,6% | 116,0% | 120,1% | 120,3% | 123,4% | 123,2% | 119,0% |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 46,5% | 112,0% | 119,6% | 121,0% | 123,3% | 122,1% | 119,3% |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 46,5% | 34,4% | 58,6% | 52,0% | 43,4% | 39,1% | 52,4% |

**Okuma.** 3 kişiden büyük ekiplerde plan %100 ile %123 dolu (sınırsız arzda 6 kişi ve üstü %111 ile %123; kaynaklıda %116 ile %123), yani hedef tutuyor; üst sınır 1,25 × kapasitedir. **1 kişide %70 (kaynaklıda %46,5)** ve 3 kişide sınırsız arzda %99,8: tek kurucunun bir kartı birkaç sprint sürer, devreden kartın plan anındaki kalanı küçüktür ve sınırsız akışta sıradaki kart K3 (40 puan) 1,25 × 17,2 tavanına sığmaz. Bu PRD'nin "1 kişi: kurucu sprintte bir kart civarı bitirir" cümlesiyle uyumlu ama %90'ın altı.

## 5. Boşta payı
Boşta kişi-hafta ÷ (kişi × hafta). PRD §4.3 madde 7: 50 kişide en çok %15.

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 13,7% | 16,6% | 15,8% | 9,5% | 2,1% | 2,7% |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 26,4% | 16,6% | 11,6% | 8,5% | 2,8% | 5,4% |
| R, atama eski (kart sırasıyla doldur) | 26,4% | 16,5% | 12,1% | 8,6% | 5,8% | 7,7% |
| R, çekme yok | 30,8% | 17,1% | 11,6% | 8,5% | 2,8% | 5,4% |
| R, erken kapanış var | 12,2% | 16,6% | 11,6% | 8,5% | 2,8% | 5,4% |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 26,4% | 21,5% | 9,6% | 8,5% | 3,2% | 6,8% |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 27,1% | 36,1% | 29,9% | 40,2% | 43,8% | 48,3% |
| R + bitecek-kart kalkanı | 26,3% | 34,9% | 29,2% | 38,3% | 38,2% | 45,3% |

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | Büyüme 1→10 |
|---|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 18,0% | 8,3% | 15,5% | 12,6% | 7,4% | 21,6% | 6,4% |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 37,0% | 12,0% | 12,3% | 13,1% | 8,1% | 17,9% | 6,2% |
| R, atama eski (kart sırasıyla doldur) | 37,0% | 12,5% | 13,4% | 13,0% | 8,8% | 19,0% | 7,0% |
| R, çekme yok | 40,6% | 12,0% | 12,3% | 13,1% | 8,1% | 17,9% | 6,2% |
| R, erken kapanış var | 14,8% | 12,0% | 12,3% | 13,1% | 8,1% | 17,9% | 6,3% |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 37,0% | 13,7% | 11,6% | 14,2% | 11,3% | 27,1% | 5,9% |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 37,7% | 28,0% | 26,5% | 35,5% | 39,6% | 45,6% | 25,6% |

**Okuma.** Sınırsız arzda 50 kişi %5,4 (kaynaklı arzda 330 hesapla %13,2 ve büyüme eğrisinde %6,2), kaynaklı arzda 0. haftadan tam 50 kişi ve haftada 3 hesapla **%17,9** (kapı 16'nın "sabit 50 kişi %62,5" hücresiyle aynı neden: arz tüketimin gerisinde, gerçek bir oyun durumu değil). Tek kurucuda eski kurala göre +12 puan (%13,7 → %26,4); çekme 30,8 → 26,4, erken kapanış kolu 12,2.

## 6. Tek kurucunun hata sprinti (2 hafta, erken kapanış yok)
| Kural | Arz | Hata sprinti (MVP sonrası hepsi) | Hata sprinti (21-60 hf) | Düzeltme payı erken | Düzeltme payı geç | Teslim | MVP hf |
|---|---|---|---|---|---|---|---|
| Eski (2 hf, erken kapanış) | S1 sınırsız | 2/655 (0,3%) | 1/497 (0,2%) | 23,3% | 23,3% | 5,1 | 6,0 |
| Eski (2 hf, erken kapanış) | S1 kaynaklı | 3/686 (0,4%) | 2/540 (0,4%) | 23,3% | 23,3% | 4,8 | 6,0 |
| R (2 hf sabit, çekme) | S1 sınırsız | 3/537 (0,6%) | 1/400 (0,2%) | 23,3% | 23,3% | 4,5 | 6,0 |
| R (2 hf sabit, çekme) | S1 kaynaklı | 2/514 (0,4%) | 2/400 (0,5%) | 23,3% | 23,3% | 3,3 | 8,0 |
| PRD birebir | S1 sınırsız | 3/537 (0,6%) | 1/400 (0,2%) | 23,3% | 23,3% | 4,5 | 6,0 |
| PRD birebir | S1 kaynaklı | 2/514 (0,4%) | 2/400 (0,5%) | 23,3% | 23,3% | 3,3 | 8,0 |
| PRD birebir tam | S1 sınırsız | 4/537 (0,7%) | 2/400 (0,5%) | 23,3% | 23,3% | 4,5 | 6,0 |
| PRD birebir tam | S1 kaynaklı | 1/514 (0,2%) | 1/400 (0,2%) | 23,3% | 23,3% | 3,3 | 8,0 |

Hata sprinti oranı MVP sonrası sprintlerde %0,4 ile %0,6 (PRD'nin 2 haftalıkta ölçülen %0,4'üyle aynı düzey; 1 haftalıkta %6,6 idi), 21-60. haftada %0,2 ile %0,5; kapı ≤ %5. Düzeltme payı %23,3 (kapı: erken ≤ %50). Sabit sürenin tek maliyeti §5'teki boşta payı ve tek kurucuda teslimin 5,1'den 4,5'e inmesi.

## 7. Kadro dilimi 8 ile 40
Sınırsız arz ve kaynaklı arzda, 1, 3, 6, 12, 25, 50 kişi; "arz yetmezliği" = açık aday havuzunun hedefin altında kaldığı sprint payı ve "planlanacak kart kalmadı" sprinti:

**Sınırsız arz**

| SLICE | Ölçü | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|---|
| 8 | Teslim (puan/hf) | 4,5 | 21,1 | 49,0 | 109,0 | 264,0 | 514,0 |
| 8 | Boşta payı | 26,4% | 16,6% | 11,6% | 8,5% | 2,8% | 5,4% |
| 8 | Plan doluluk | 70,1% | 99,8% | 110,9% | 116,6% | 121,1% | 123,3% |
| 8 | Açık hata | 6,0 | 8,8 | 8,0 | 9,5 | 10,8 | 13,2 |
| 40 | Teslim (puan/hf) | 4,5 | 19,1 | 48,0 | 106,5 | 257,0 | 496,0 |
| 40 | Boşta payı | 26,4% | 21,5% | 14,7% | 10,5% | 5,0% | 8,5% |
| 40 | Plan doluluk | 70,1% | 96,1% | 112,0% | 115,9% | 121,1% | 123,3% |
| 40 | Açık hata | 6,0 | 9,0 | 8,5 | 10,5 | 10,5 | 13,0 |

**Kaynaklı arz** (arz yetersizliği = açık aday havuzunun hedefin altında kaldığı sprint payı = 1 - 'arz yeterli sprint'; ayrıca 'planlanacak kart kalmadı' sprinti)

| SLICE | Ölçü | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | Büyüme 1→10 |
|---|---|---|---|---|---|---|---|---|
| 8 | Teslim (puan/hf) | 3,3 | 20,9 | 47,2 | 98,1 | 237,7 | 415,4 | 66,7 |
| 8 | Boşta payı | 37,0% | 12,0% | 12,3% | 13,1% | 8,1% | 17,9% | 6,2% |
| 8 | Arz yeterli sprint | 100,0% | 100,0% | 100,0% | 100,0% | 100,0% | 62,5% | 100,0% |
| 8 | Kart yok sprinti | 0,0% | 0,0% | 0,0% | 0,0% | 0,0% | 0,0% | 0,0% |
| 40 | Teslim (puan/hf) | 3,3 | 21,3 | 47,4 | 94,6 | 228,4 | 375,1 | 65,0 |
| 40 | Boşta payı | 37,0% | 11,9% | 11,9% | 15,0% | 10,9% | 25,6% | 6,9% |
| 40 | Arz yeterli sprint | 100,0% | 100,0% | 100,0% | 100,0% | 100,0% | 50,0% | 100,0% |
| 40 | Kart yok sprinti | 0,0% | 0,0% | 0,0% | 0,0% | 0,0% | 0,0% | 0,0% |

**Okuma.** 40 her aşamaya tek isim koyuyor ama teslim ve boşta bedeli ödetiyor: sınırsız arzda 3 / 6 / 12 / 25 / 50 kişide teslim −%9,5 / −%2,0 / −%2,3 / −%2,7 / −%3,5, boşta +4,9 / +3,2 / +2,0 / +2,2 / +3,1 puan; kaynaklıda 12 / 25 / 50 kişide teslim −%3,6 / −%3,9 / −%9,7, boşta +1,9 / +2,8 / +7,6 puan (1 kişide fark yok). PRD'nin çekincesi (25 kişiden sonra kart arzı yetmez ve ekip boşta kalır) kaynaklı arzda yalnız 50 kişide görülüyor: arz yetmezliği %37,5 → %50. Öneri: **8 kalsın**.

## 8. Söz kartı iki sırada
Söz: MVP'den sonra her sprint başında 0,5 olasılıkla, aynı anda en çok 2 açık söz, kart sprintte henüz olmayan ilk 8 adaydan biri, vadesi 1 ya da 2 sprint sonra (Yorum 13). 80 hafta, 20 tohum, B2B. "Kaçan" = vadeden sonra teslim edilen ya da hâlâ edilmemiş.

| Sıra | Ekip | Verilen söz | Vadesi gelen | Kaçan (geç + teslim edilmemiş) | Ortalama gecikme (sprint, teslimlerde) | Teslim edilmemiş | Küçük kart (<=25) kaçan | Büyük kart (40) ort. süre (hf) | Teslim (puan/hf) | Bağlı soru sprintleri |
|---|---|---|---|---|---|---|---|---|---|---|
| R, saf büyüklük (PROMISEFIRST=0) | 1 kişi | 267 | 258 | 185 (71,7%) | 2,15 | 17 | 128/198 | 8,00 | 5,7 | 0,0% |
| R, saf büyüklük (PROMISEFIRST=0) | 3 kişi | 366 | 352 | 71 (20,2%) | 0,32 | 1 | 10/163 | 5,71 | 20,1 | 1,7% |
| R, saf büyüklük (PROMISEFIRST=0) | 6 kişi | 370 | 359 | 1 (0,3%) | 0,00 | 1 | 0/84 | 3,23 | 47,3 | 8,7% |
| R, saf büyüklük (PROMISEFIRST=0) | 12 kişi | 371 | 359 | 0 (0,0%) | 0,00 | 0 | 0/34 | 4,08 | 100,2 | 8,7% |
| R, saf büyüklük (PROMISEFIRST=0) | 25 kişi | 373 | 363 | 0 (0,0%) | 0,00 | 0 | 0/79 | 4,02 | 242,4 | 13,3% |
| R, saf büyüklük (PROMISEFIRST=0) | 50 kişi | 373 | 363 | 0 (0,0%) | 0,00 | 0 | 0/141 | 4,01 | 427,0 | 12,5% |
| R, söz önce (PROMISEFIRST=1) | 1 kişi | 269 | 260 | 187 (71,9%) | 2,11 | 15 | 130/200 | 6,00 | 5,8 | 0,0% |
| R, söz önce (PROMISEFIRST=1) | 3 kişi | 366 | 352 | 41 (11,6%) | 0,14 | 1 | 7/160 | 5,21 | 19,9 | 2,3% |
| R, söz önce (PROMISEFIRST=1) | 6 kişi | 370 | 359 | 0 (0,0%) | 0,00 | 0 | 0/78 | 2,85 | 47,8 | 7,8% |
| R, söz önce (PROMISEFIRST=1) | 12 kişi | 371 | 359 | 0 (0,0%) | 0,00 | 0 | 0/30 | 4,05 | 100,5 | 10,3% |
| R, söz önce (PROMISEFIRST=1) | 25 kişi | 373 | 363 | 0 (0,0%) | 0,00 | 0 | 0/76 | 4,02 | 241,9 | 10,7% |
| R, söz önce (PROMISEFIRST=1) | 50 kişi | 373 | 363 | 0 (0,0%) | 0,00 | 0 | 0/138 | 4,02 | 425,2 | 9,3% |
| PRD birebir, saf büyüklük | 1 kişi | 267 | 258 | 189 (73,3%) | 2,17 | 18 | 132/198 | 8,00 | 5,6 | 0,7% |
| PRD birebir, saf büyüklük | 3 kişi | 351 | 341 | 111 (32,6%) | 0,63 | 4 | 24/154 | 4,87 | 20,5 | 3,2% |
| PRD birebir, saf büyüklük | 6 kişi | 364 | 352 | 95 (27,0%) | 1,05 | 7 | 13/83 | 6,25 | 47,4 | 62,8% |
| PRD birebir, saf büyüklük | 12 kişi | 367 | 353 | 41 (11,6%) | 0,17 | 2 | 3/42 | 3,98 | 100,3 | 29,8% |
| PRD birebir, saf büyüklük | 25 kişi | 373 | 363 | 41 (11,3%) | 0,17 | 2 | 12/107 | 4,23 | 231,8 | 35,0% |
| PRD birebir, saf büyüklük | 50 kişi | 373 | 363 | 13 (3,6%) | 0,04 | 0 | 8/196 | 3,76 | 380,1 | 16,3% |
| PRD birebir, söz önce | 1 kişi | 269 | 259 | 186 (71,8%) | 2,11 | 15 | 130/200 | 6,00 | 5,7 | 0,0% |
| PRD birebir, söz önce | 3 kişi | 350 | 340 | 62 (18,2%) | 0,31 | 4 | 10/138 | 5,36 | 21,1 | 1,7% |
| PRD birebir, söz önce | 6 kişi | 364 | 352 | 1 (0,3%) | 0,00 | 0 | 0/74 | 3,69 | 47,2 | 5,7% |
| PRD birebir, söz önce | 12 kişi | 367 | 353 | 0 (0,0%) | 0,00 | 0 | 0/49 | 3,82 | 100,2 | 9,8% |
| PRD birebir, söz önce | 25 kişi | 373 | 363 | 0 (0,0%) | 0,00 | 0 | 0/110 | 4,16 | 232,6 | 9,5% |
| PRD birebir, söz önce | 50 kişi | 373 | 363 | 0 (0,0%) | 0,00 | 0 | 0/195 | 3,75 | 378,9 | 8,8% |

**Okuma.**
- **R'de** (kadroyu plan sırası belirliyor, söz kartı 1. basamak): "söz önce" yalnız 3 kişide fark yaratıyor (kaçan %20,2 → %11,6); 6 kişiden büyükte iki sırada da kaçan 0 ile 1 söz. Büyük kartın (40) ortalama süresi değişmiyor (6 kişide 3,2 → 2,9; 12-50 kişide 4,0 → 4,0 hf): "büyük işin biraz yavaşlaması" bedeli ölçülemeyecek kadar küçük.
- **Birebir okumada** (saf büyüklük) küçük söz kartı zayıf kişiye düşüyor ve kaçıyor: 3 / 6 / 12 / 25 / 50 kişide kaçan %32,6 / %27,0 / %11,6 / %11,3 / %3,6, küçük kartlarda (≤ 25) 24/154, 13/83, 3/42, 12/107, 8/196. "Söz önce" bunu %18,2 / %0,3 / %0 / %0 / %0'a indiriyor ve toplam teslimi değiştirmiyor (47,4 → 47,2; 231,8 → 232,6).
- **Tek kurucuda** iki sırada da vadesi gelen sözlerin yaklaşık %72'si kaçıyor (kapasite sorunu, sıra değil).
- **Sonuç.** Önerim: R'de söz önce sırası gerekmiyor (kadro zaten plan sırasıyla verildiği için söz 1. basamakta); birebir okumada şart. Karar 4'ün yazısına "söz ya da tarihli kart büyüklükten önce" cümlesini eklemek iki okumada da güvenli (R'de zararsız).
- **Bağlı soru** sütunu: PRD §4.1 madde 5 "bağlı kipte soru sprintlerin ≤ %10'unda": R'de 3-12 kişide %2 ile %9, 25 ve 50 kişide %13,3 ve %12,5 (kapı sınırın üstünde). Bu sayı söz yoğunluğuna (sprint başı 0,5 olasılık, aynı anda ≤ 2) bağlı bir varsayımdır; gerçek oyunda söz sıklığı C'nin kuralıdır.

## 9. Testçi Geliştirme ve Düzeltme yapar mı
Üç kol: testçi yalnız Test (eski, kutu yok); **TESTERFIX=0**: Geliştirme ×0,7 var, Düzeltme alt aşaması yok (Karar 6 "testçi düzeltmez"); **TESTERFIX=1**: Geliştirme ve Düzeltme ×0,7 (Karar 2 tablosu).

| Kol | Ölçü | S3 | S4 | S5 | S6 | S7 | S9b | S10 | T3_1 | T3_3 | T3_5 | T3_yok | T4_3 | T5_3 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Testçi yalnız Test (kutu yok) | teslim | 48,5 | 109,0 | 263,5 | 514,5 | 23,1 | 21,6 | 290,5 | 46,0 | 49,0 | 51,0 | 48,0 | 110,0 | 264,5 |
| Testçi yalnız Test (kutu yok) | kaçan/100 puan | 1,57 | 1,43 | 1,15 | 1,20 | 1,28 | 2,31 | 1,53 | 1,97 | 1,50 | 0,74 | 1,92 | 1,32 | 1,12 |
| Testçi yalnız Test (kutu yok) | açık hata | 8,5 | 9,5 | 10,0 | 13,0 | 7,0 | 8,0 | 11,5 | 8,0 | 8,0 | 8,0 | 11,5 | 9,0 | 10,0 |
| Testçi yalnız Test (kutu yok) | boşta | 15,9% | 8,8% | 3,3% | 5,4% | 68,1% | 70,9% | 3,0% | 15,3% | 15,9% | 18,6% | 10,7% | 10,0% | 4,3% |
| Testçi Geliştirme x0,7, Düzeltme yok (TESTERFIX=0) | teslim | 49,0 | 109,0 | 263,0 | 515,0 | 24,5 | 19,6 | 293,0 | 46,0 | 51,0 | 59,0 | 48,0 | 111,5 | 268,0 |
| Testçi Geliştirme x0,7, Düzeltme yok (TESTERFIX=0) | kaçan/100 puan | 1,82 | 1,44 | 1,22 | 1,20 | 1,87 | 2,30 | 1,61 | 2,01 | 1,77 | 1,42 | 1,92 | 1,31 | 1,17 |
| Testçi Geliştirme x0,7, Düzeltme yok (TESTERFIX=0) | açık hata | 8,0 | 9,5 | 10,5 | 13,0 | 8,0 | 8,0 | 11,8 | 8,5 | 8,2 | 8,2 | 11,5 | 8,8 | 10,0 |
| Testçi Geliştirme x0,7, Düzeltme yok (TESTERFIX=0) | boşta | 12,5% | 8,7% | 2,8% | 5,4% | 64,8% | 72,1% | 1,0% | 13,2% | 11,8% | 9,3% | 10,7% | 8,7% | 3,0% |
| Testçi Geliştirme ve Düzeltme x0,7 (tablo, TESTERFIX=1) | teslim | 49,0 | 109,0 | 264,0 | 514,0 | 25,5 | 21,6 | 295,0 | 46,0 | 51,0 | 60,0 | 48,0 | 112,0 | 269,0 |
| Testçi Geliştirme ve Düzeltme x0,7 (tablo, TESTERFIX=1) | kaçan/100 puan | 1,91 | 1,38 | 1,20 | 1,20 | 1,98 | 2,31 | 1,58 | 2,12 | 1,76 | 1,48 | 1,92 | 1,36 | 1,16 |
| Testçi Geliştirme ve Düzeltme x0,7 (tablo, TESTERFIX=1) | açık hata | 8,0 | 9,5 | 10,8 | 13,2 | 7,2 | 8,0 | 11,5 | 9,0 | 8,2 | 8,2 | 11,5 | 9,0 | 10,0 |
| Testçi Geliştirme ve Düzeltme x0,7 (tablo, TESTERFIX=1) | boşta | 11,6% | 8,5% | 2,8% | 5,4% | 63,8% | 70,9% | 0,5% | 12,9% | 10,6% | 7,6% | 10,7% | 8,2% | 2,7% |

Testçi kapıları, kol kol (kapı 9 ve 10):

| Kol | 6 kişi: 1★→5★ testçi | 6 kişi: testcisiz→3★ | 12 kişi: 1★→5★ | 12 kişi: testcisiz→3★ | 25 kişi: 1★→5★ | 25 kişi: testcisiz→3★ | Kapı 9 testci_yildizi | Kapı 10 testci_degeri |
|---|---|---|---|---|---|---|---|---|
| Testçi yalnız Test | kaçan −62,3%, bulunan x2,3 | teslim +2,1%, kaçan −21,9% | kaçan −60,2%, bulunan x2,4 | teslim +7,8%, kaçan −15,2% | kaçan −60,2%, bulunan x2,7 | teslim +13,5%, kaçan −19,0% | GEÇTİ | KALDI |
| Testçi Geliştirme x0,7, Düzeltme yok | kaçan −29,3%, bulunan x1,9 | teslim +6,2%, kaçan −7,8% | kaçan −39,1%, bulunan x2,0 | teslim +9,3%, kaçan −16,3% | kaçan −45,0%, bulunan x2,6 | teslim +15,0%, kaçan −15,3% | KALDI | KALDI |
| Testçi Geliştirme ve Düzeltme x0,7 | kaçan −30,2%, bulunan x1,8 | teslim +6,2%, kaçan −8,5% | kaçan −41,8%, bulunan x1,9 | teslim +9,8%, kaçan −13,1% | kaçan −43,4%, bulunan x2,6 | teslim +15,5%, kaçan −15,7% | KALDI | KALDI |

**Okuma.** (1) Düzeltme'yi dışlamak (kol 0) ile dahil etmek (kol 1) arasında teslim, kaçan hata ve boşta farkı gürültü düzeyinde (örnek 25 kişi: 263,0 / 264,0 puan, kaçan/100 puan 1,22 / 1,20). Testçinin Düzeltme yapıp yapmaması ölçülebilir bir şey değiştirmiyor; Karar 6'nın "testçi düzeltmez" cümlesi güvenle tutulabilir. (2) Asıl etki **Geliştirme ×0,7**: testçi boşta kalınca geliştirir. Teslime etkisi küçük: S3 / S4 / S5 / S6'da 48,5 → 49,0, 109,0 → 109,0, 263,5 → 264,0, 514,5 → 514,0; yalnız 5★ testçili 6 kişide 51,0 → 60,0 (+%17,6) ve 5 testçili küçük kartlı S7'de 23,1 → 25,5. Boşta biraz düşer (S3 %15,9 → %11,6). Ama kişi aşama bitene dek işinde kaldığı için geliştirme yapan testçi test açılınca testte olamıyor ve teste kurucu giriyor: 5★ testçili 6 kişide kaçan/100 puan 0,74 → 1,48, bulunan/sprint 2,40 → 1,65. Bu yüzden kapı 9 yalnız "testçi yalnız Test" kolunda geçiyor (−%62 / −%60 / −%60, ×2,3 / ×2,4 / ×2,7); kol 0 ve 1'de 6 kişide −%29 / −%30 ve ×1,9 / ×1,8. (3) Kapı 10 (testçisiz → 3★ testçi: kaçan ≥ %20 azalır) her üç kolda da kalıyor: en iyi kolda (yalnız Test) 12 ve 25 kişide −%15,2 ve −%19,0, öteki kollarda 6 kişide de −%8; D_SIM_v3'te −%25,9 ve −%24,9'du. Testçisiz taban bu turda daha iyi (kaçan/100 puan 6 kişide 2,30 → 1,92), 3★ testçili kol aynı düzeyde; fark nedenini ayrıca ölçmedim. **Öneri:** testçiye varsayılan Geliştirme kutusu verilmesin (Test kutusu yeter) ya da testçinin ikincil işi, test açılınca bırakılsın (bunu PRD "kişi aşama bitene dek kalır" diye yasaklıyor).

## 10. Derinlik kartı tüketimi ve 6 yazılı ad
Bir hatta koşu boyunca açılan derinlik kartı sayısı (9 hat). Oyunun yumuşak tavanı 104 hafta; büyüme eğrisi 130.

| Ekip | Hafta | Hat başına açılan derinlik kartı: medyan hat | en çok kullanılan hat (medyan koşu) | en çok (tüm koşular) | Hat başına biten: en çok (medyan koşu) | 6 adı aşan hat payı |
|---|---|---|---|---|---|---|
| 1 kişi | 104 | 0,0 | 9,0 | 12 | 1,0 | 14,4% |
| 3 kişi | 104 | 13,0 | 16,0 | 18 | 9,0 | 97,2% |
| 6 kişi | 104 | 25,0 | 28,0 | 30 | 21,0 | 100,0% |
| 12 kişi | 104 | 47,0 | 51,5 | 56 | 44,0 | 100,0% |
| 25 kişi | 104 | 102,0 | 114,0 | 123 | 109,5 | 100,0% |
| 50 kişi | 104 | 177,0 | 192,0 | 200 | 187,5 | 100,0% |
| Büyüme 1→10 | 130 | 36,0 | 40,0 | 42 | 32,5 | 100,0% |

**Okuma.** 6 ad hat başına yalnız tek kurucuyu karşılıyor. 3 kişide medyan hat 13, 6 kişide 25, 12 kişide 47, 25 kişide 102, 50 kişide 177 derinlik kartı açıyor; en çok kullanılan hat 16 / 28 / 51,5 / 114 / 192. Büyüme eğrisinde (1 → 10 kişi, 130 hf) medyan hat 36. Yani derinlik kartı adı "hat başına 6" değil; PRD'nin "şablon yok, jenerik ad grind hissi verir" ilkesi (#17) ancak adlar hat başına onlarca ve oyuncunun gördüğü sıra karışık olursa tutar. W'nin hedefi için: 12 kişilik ekibin 104 haftasında hat başına 47-52, 25 kişide 100-114 ad ya da adların, aynı işin farklı kapsamları olarak (Toplu fatura: ikinci para birimi, üçüncü, vergi türü...) yeniden kullanılması gerekir. 1 kişilik oyunda bile hatların %14,4'ü 6 adı aşıyor (en çok kullanılan hat medyan koşuda 9, hiçbir koşuda 12'yi geçmiyor).

## 11. Uç karışımlar
Aynı kod ve kurallar; "Eski" D_SIM_v3 kuralı, "R" önerilen okuma.

| Karışım | Kod | Eski: teslim | boşta | kaçan/kart | açık hata | R: teslim | boşta | kaçan/kart | açık hata |
|---|---|---|---|---|---|---|---|---|---|
| 5 testçi, küçük kartlar | S7 | 22,5 | 68,8% | 0,48 | 7,2 | 25,5 | 63,8% | 0,75 | 7,2 |
| 10 geliştirici, Test kutusu yok | S8 | 17,0 | 82,4% | 0,75 | 7,5 | 18,0 | 82,6% | 0,85 | 9,0 |
| 10 geliştirici, hepsinde Test kutusu | S8_hepsi_testkutulu | 31,0 | 68,5% | 0,84 | 8,0 | 30,5 | 69,2% | 0,88 | 8,0 |
| 8 testçi, yalnız Test | S9a | 8,4 | 87,1% | 0,30 | 6,8 | 8,9 | 86,9% | 0,30 | 8,0 |
| 8 testçi, Yapım ve Test | S9b | 20,6 | 71,8% | 0,75 | 7,0 | 21,6 | 70,9% | 0,80 | 8,0 |
| PM yok (5 kişi) | S3_PMsiz | 39,5 | 11,0% | 0,85 | 8,0 | 41,0 | 5,4% | 1,02 | 8,0 |
| PM yok (10 kişi) | S4_PMsiz | 90,0 | 3,8% | 0,75 | 9,0 | 92,0 | 1,1% | 0,78 | 11,0 |
| PM yok (30 kişi) | S10 | 285,0 | 4,9% | 0,61 | 14,5 | 295,0 | 0,5% | 0,63 | 11,5 |
| Testçi yok (25 kişi, kutu yok) | S11 | 37,0 | 85,7% | 0,73 | 8,0 | 37,0 | 86,1% | 0,69 | 9,0 |
| Testçi yok (25 kişi, geliştiricide Test kutusu) | S11b | 162,0 | 34,4% | 0,56 | 11,0 | 151,5 | 39,0% | 0,64 | 9,5 |
| Tek karta 12 kişi | S12 | 11,7 | 90,3% | 0,30 | 6,0 | 3,5 | 96,5% | 0,17 | 5,0 |

- **Tek karta 12 kişi** (S12): çekme bu senaryoda kapalı; tek kart kipi kadro kuralını sınar. 12 kişi, sprintte tek kart: teslim 3,5 ve %96,5 boşta (eski kuralda erken kapanışla 11,7 ve %90,3; sabit 2 haftada tek kart 2 haftada biter, bu iki sayı birbirine denk değildir). Kadro kuralı çalışıyor: tek karta 12 kişi hızlandırmıyor, ekip boşta kalıyor.
- Testçi yok (S11, kutu yok) 37,0 teslim ve %86 boşta; geliştiricilere Test kutusu verilince (S11b) 151,5 (eski 162,0). PM yok ekipler çökmüyor (S3 PM'siz 41,0, 30 kişilik S10 295,0). 10 aynı rol ve hepsi testçi karışımları da çökmüyor; kırık karışım boşta kişi olarak görünüyor.

## 12. Kuralların tek tek etkisi ve PRD'nin birebir okuması
Teslim (puan/hf, sınırsız arz): 

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 5,1 | 20,1 | 48,0 | 108,0 | 267,5 | 540,0 |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 4,5 | 21,1 | 49,0 | 109,0 | 264,0 | 514,0 |
| R, atama eski (kart sırasıyla doldur) | 4,5 | 21,1 | 49,0 | 108,0 | 250,0 | 494,5 |
| R, çekme yok | 3,5 | 21,1 | 49,0 | 109,0 | 264,0 | 514,0 |
| R, erken kapanış var | 5,3 | 21,1 | 49,0 | 109,0 | 264,0 | 514,0 |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 4,5 | 19,8 | 51,8 | 112,0 | 263,5 | 503,0 |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 4,5 | 15,4 | 38,5 | 67,0 | 141,5 | 262,0 |
| R + bitecek-kart kalkanı | 4,5 | 15,8 | 39,0 | 70,0 | 157,5 | 281,5 |

Açık hata (medyan):

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 6,0 | 8,0 | 8,0 | 9,5 | 12,0 | 16,2 |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 6,0 | 8,8 | 8,0 | 9,5 | 10,8 | 13,2 |
| R, atama eski (kart sırasıyla doldur) | 6,0 | 8,0 | 8,0 | 9,8 | 15,8 | 22,8 |
| R, çekme yok | 6,0 | 8,8 | 8,0 | 9,2 | 10,8 | 13,2 |
| R, erken kapanış var | 6,0 | 8,8 | 8,0 | 9,5 | 10,8 | 13,2 |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 6,0 | 13,0 | 19,2 | 23,8 | 23,5 | 21,8 |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 6,0 | 8,0 | 8,2 | 8,5 | 10,0 | 12,5 |
| R + bitecek-kart kalkanı | 6,0 | 7,5 | 8,0 | 8,5 | 10,0 | 13,0 |

MVP haftası (medyan) ve sprintte çekilen kart:

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 6,0 | 4,0 | 4,0 | 2,0 | 2,0 | 2,0 |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 6,0 | 4,0 | 4,0 | 2,0 | 2,0 | 2,0 |
| R, atama eski (kart sırasıyla doldur) | 6,0 | 4,0 | 4,0 | 2,0 | 2,0 | 2,0 |
| R, çekme yok | 6,0 | 4,0 | 4,0 | 2,0 | 2,0 | 2,0 |
| R, erken kapanış var | 6,0 | 4,0 | 4,0 | 2,0 | 2,0 | 2,0 |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 6,0 | 7,0 | 6,0 | 4,0 | 8,0 | 12,0 |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 6,0 | 4,0 | 2,0 | 4,0 | 4,0 | 2,0 |
| R + bitecek-kart kalkanı | 6,0 | 4,0 | 2,0 | 2,0 | 2,0 | 2,0 |

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi |
|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 0,00 | 0,00 | 0,00 | 0,00 | 0,00 | 0,00 |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 0,17 | 0,00 | 0,00 | 0,00 | 0,00 | 0,00 |
| R, atama eski (kart sırasıyla doldur) | 0,17 | 0,00 | 0,15 | 0,05 | 0,00 | 0,00 |
| R, çekme yok | 0,00 | 0,00 | 0,00 | 0,00 | 0,00 | 0,00 |
| R, erken kapanış var | 0,13 | 0,00 | 0,00 | 0,00 | 0,00 | 0,00 |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 0,17 | 0,05 | 0,00 | 0,00 | 0,00 | 0,00 |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 0,20 | 0,62 | 0,45 | 0,55 | 1,05 | 1,90 |
| R + bitecek-kart kalkanı | 0,20 | 0,53 | 0,45 | 0,53 | 1,58 | 3,02 |

Kaynaklı arz (hat başına K1, K2, K3 + derinlik + istek):

| Kural | 1 kişi | 3 kişi | 6 kişi | 12 kişi | 25 kişi | 50 kişi | Büyüme 1→10 |
|---|---|---|---|---|---|---|---|
| Eski kural (D_SIM_v3: sprint sırası, erken kapanış, çekme yok, PM haftanın en iyisi) | 4,8 | 22,2 | 46,5 | 99,9 | 247,0 | 406,4 | 67,5 |
| R: Karar 4 (kadroyu plan sırası, kişiyi büyüklük), PM ufuklu, sabit 2 hf + çekme, kalkan yalnız talep | 3,3 | 20,9 | 47,2 | 98,1 | 237,7 | 415,4 | 66,7 |
| R, atama eski (kart sırasıyla doldur) | 3,3 | 20,6 | 46,5 | 97,2 | 233,0 | 401,9 | 65,7 |
| R, çekme yok | 3,2 | 20,9 | 47,2 | 98,1 | 237,7 | 415,4 | 66,7 |
| R, erken kapanış var | 4,8 | 20,9 | 47,2 | 98,1 | 237,7 | 415,4 | 66,7 |
| PRD birebir Karar 4 ve 8 (kadro ve kişi büyüklüğe göre, haftalık PM), kalkan yalnız talep | 3,3 | 20,6 | 47,5 | 96,4 | 226,9 | 364,2 | 65,9 |
| PRD birebir tam (R_size + bitecek-kart kalkanı) | 3,3 | 17,1 | 39,4 | 69,5 | 147,5 | 277,3 | 49,1 |

**Okuma.**
- **Karar 4'ün eşlemesi (R, atama eski ile):** 25 kişide teslim 264,0 vs 250,0 (+%5,6), 50 kişide 514,0 vs 494,5 (+%3,9); açık hata 10,8 vs 15,8 ve 13,2 vs 22,8. Büyük işe en iyi kişi hem teslimi hem kaliteyi artırıyor. Eski kurala göre (sprint sırası, erken kapanış, çekme yok): 50 kişide 540,0 → 514,0 (−%4,8), 25 kişide 267,5 → 264,0 (−%1,3), 12 kişide 108,0 → 109,0; 1 kişide 5,1 → 4,5.
- **Çekme:** R ile "çekme yok" arasındaki fark yalnız 1 kişide (3,5 → 4,5 puan/hf, boşta %30,8 → %26,4); 3 kişi ve üstünde çekme sprintte ~0 kart çekiyor, çünkü plan %100-123 dolu. Çekme bir güvenlik ağı, ana mekanik değil; ancak plan kasten az dolu bırakıldığında (kalkan) devreye giriyor (aşağıda).
- **Erken kapanış:** yalnız tek kurucuyu etkiliyor (5,3 vs 4,5); öteki ekiplerde sprintler zaten erken bitmiyor.
- **Birebir okuma (R_size):** MVP 3 / 6 / 12 / 25 / 50 kişide 7 / 6 / 4 / 8 / 12. hafta (R: 4, 4, 2, 2, 2), açık hata 13,0 / 19,2 / 23,8 / 23,5 / 21,8 (R: 8,8 / 8,0 / 9,5 / 10,8 / 13,2). Neden: sprint 1,25 × kapasite yüklendiği için büyük kartlar bütün aşama slotlarını tutuyor, MVP'nin K1 kartları ve düzeltme kartları (küçük) devreden kalıp sırada beklemeye devam ediyor. Teslim 6 / 12 kişide R'den biraz iyi (51,8 / 112,0), 3 ve 50 kişide kötü (19,8 / 503,0).
- **Tam birebir (P, kalkanlı):** teslim 3 / 6 / 12 / 25 / 50 kişide 15,4 / 38,5 / 67,0 / 141,5 / 262,0 (R_size'a göre −%22 / −%26 / −%40 / −%46 / −%48), plan doluluğu %34,8 / %51,6 / %44,9 / %37,1 / %34,2, boşta %36,1 / %29,9 / %40,2 / %43,8 / %48,3, çekilen kart 0,62 / 0,45 / 0,55 / 1,05 / 1,90 (çekme devrede ama yetmiyor). Sebep yapısal: bir kartın tasarım → geliştirme → test yolu 2 haftanın büyük kısmını yiyor (bir K1 için yaklaşık 1,6 hafta); aynı sprintte "biter" diyebilen kart ilk dalgadır, ikinci dalga bitmez ve kalkan onu almaz. Bu bir model hatası değil, 2 haftalık sprintte çok aşamalı kartın doğası.
- **R_shield** (R + bitecek-kart kalkanı; yalnız sınırsız arz, 20 tohum, kaynaklı arz koşulmadı) aynı çöküşü yapıyor: teslim S2 / S3 / S4 / S5 / S6'da 15,75 / 39,0 / 70,0 / 157,5 / 281,5 (R: 21,1 / 49,0 / 109,0 / 264,0 / 514,0; −%25 / −%20 / −%36 / −%40 / −%45), plan doluluğu %37,6 / %53,2 / %46,6 / %40,1 / %34,5, boşta %34,9 / %29,2 / %38,3 / %38,2 / %45,3, sprintte çekilen kart 0,53 / 0,45 / 0,53 / 1,58 / 3,03. Kalkan atama kuralını değiştirmeden de aynı çöküşü yaratıyor.

## 13. Kapı tablosu (eski 23 + yeni 5)
Hepsi R okumasıyla (20 tohum; PM adımı 100 tohum). Eşikler PRD §4.1'e göre hizalı. Kapı 22 (EA takımı) PRD §7 gereği ölçülmedi.

| No | Kapı | Hedef (PRD §4.1 okuması) | Sonuç | Değer ve kanıt |
|---|---|---|---|---|
| 1 | `ekleme_dusurmez` | her ekleme ve her daha iyisiyle değiştirme ≥ 0 puan/hf (tolerans yok) | **KALDI** | en kötü −4,0 (eğri 41→42); eksi adım 6/182 · B: 25 adım, en kötü −1,0 (S5 +3★ tasarımcı), eksi adım 1 ¦ C: 49 adım, en kötü −4,0 (eğri 41→42), eksi adım 3 ¦ E: 72 adım, en kötü 0,0 (G¦gel4¦uc-gel¦+3), eksi adım 0 ¦ REP: 36 adım, en kötü −0,6 (REP¦S2¦des¦+1), eksi adım 2 ¦ ortalama farkı −2 SE'nin altında olan (gürültüden ayrılan) eksi adım: 1/182 [('eğri 41→42', −2.85, 0.83, 17, 20)] |
| 2 | `kurucu_buyume` | teslim her alımda artar; MVP gecikmez; kurucunun işi <= %12 düşer, her düşüş nedenli | **KALDI** | 72 adım: teslim en küçük artış 0,0 (gel4/uc-gel/3); MVP gecikme 2; kurucu işi tabana göre en çok 8,1% (gel5/uc-gel/3); nedensiz düşüş 0/9 · düşüşlerin nedeni (kurucu işi önceki adıma göre >%2 düştü): {'aşama': 1, 'bölündü': 8, 'hazırlık': 0, 'YOK': 0}; nedensiz: [] |
| 3 | `mvp_tek_kurucu` | MVP sprint sonunda: 6. hafta, en geç 8 | **GEÇTİ** | 6. hafta 17 tohum, 8. hafta 3 tohum, başka 0 |
| 4 | `kisi_basi_olcek` | S5 ve S6 kişi başı, S3'un %70 ile %150'si | **GEÇTİ** | S5 129,3%, S6 125,9% (kişi başı 8,2, 10,6, 10,3) |
| 5 | `darbogaz_rolu` | darboğaz rolüne kişi eklemek teslimi artırır | **GEÇTİ** | S8 + Test kutulu geliştirici 18,0 → 26,2; S11 + testçi 37,0 → 91,0; S9a + geliştirici 8,9 → 19,2 |
| 6 | `duzeltme_payi` | >=2 kişi: erken <=30%, geç <=20%, hata sprinti <=5%, üst üste yok; tek kurucu erken <=50%, geç hata sprinti <=5% | **KALDI** | 347 senaryo: >=2 kişi en yüksek erken 16,1%, geç 21,5%, hata sprinti 1,0%; tek kurucu erken en çok 23,3%, hata sprinti en çok 0,2% · ihlal: ['G¦orta¦tas-gel-test¦1', 'GT¦orta¦tas-gel-test¦1'] |
| 7 | `toplam_hata_isi` | >=2 kişi <=%20, tek kurucu <=%35 | **KALDI** | >=2 kişi en çok 22,6% (G¦orta¦tas-gel-test¦1); tek kurucu en çok 23,8% · ihlal: [('G¦orta¦tas-gel-test¦1', 0.226), ('GT¦orta¦tas-gel-test¦1', 0.223)] |
| 8 | `acik_hata_sinirli` | son 20 haftanın eğimi <= 0,2 hata/hf | **KALDI** | en büyük medyan eğim 0,20 (G¦gel4¦tas-gel-test¦1) |
| 9 | `testci_yildizi` | 1→5 yıldız: kaçan/100 >= %40 azalır, bulunan >= 2 kat; yakalama en iyi testçinin c'sini aşmaz | **KALDI** | 6 kişi kaçan/100 2,12 → 1,48 (−30,2%), bulunan 0,90 → 1,65 (x1,8); 12 kişi kaçan/100 1,69 → 0,98 (−41,8%), bulunan 2,35 → 4,57 (x1,9); 25 kişi kaçan/100 1,45 → 0,82 (−43,4%), bulunan 4,30 → 11,07 (x2,6); tavan aşımı 0 kart |
| 10 | `testci_degeri` | testçisiz yerine 3★ testçi: teslim düşmez, kaçan/100 >= %20 azalır | **KALDI** | 6 kişi teslim 48,0 → 51,0 (+6,2%), kaçan/100 1,92 → 1,76 (−8,5%); 12 kişi teslim 102,0 → 112,0 (+9,8%), kaçan/100 1,56 → 1,36 (−13,1%); 25 kişi teslim 233,0 → 269,0 (+15,5%), kaçan/100 1,38 → 1,16 (−15,7%) |
| 11 | `pm_yildizi` | besleyen PM sayısıyla 1→5 yıldız: teslim >= %10, kaçan/kart >= %25 iyi; PM'siz→PM iyileşir | **GEÇTİ** | 6 kişi, 1 PM teslim 45,0 → 54,0 (+20,0%), kaçan/kart 0,89 → 0,63 (−29,4%) ¦ 11 kişi, 1 PM teslim 98,0 → 120,0 (+22,4%), kaçan/kart 0,68 → 0,44 (−35,0%) ¦ 24 kişi, 2 PM teslim 229,0 → 277,0 (+21,0%), kaçan/kart 0,61 → 0,40 (−34,1%) ¦ 25 kişi, 3 PM teslim 236,0 → 280,0 (+18,6%), kaçan/kart 0,57 → 0,40 (−29,6%) ¦ PM'siz→PM: S3 PM'siz→PM 41,0 → 49,0, kaçan 1,02 → 0,76; S4 PM'siz→1 PM 92,0 → 109,0, kaçan 0,78 → 0,58; 23 kişi PM'siz→PM(3★) 216,0 → 234,0, kaçan 0,64 → 0,57 · kalan: [] bilgi (kapı dışı): 23 kişi, 1 PM teslim +8,9%, kaçan/kart −19,0% |
| 12 | `soru_sikligi` | bağlı kip: soru sprintlerin <= %10'unda; eşikli kip (karşılaştırma): S2-S5, S10 <= 1/3, 6 ve 12 kişi >= 1/20 | **KALDI** | eşikli: S2 5,8%, S3 18,0%, S4 31,5%, S5 18,2%, S10 15,0%; bağlı kip (söz verilen kartta, PR senaryoları): S1 0,0%, S2 1,7%, S3 8,7%, S4 8,7%, S5 13,3%, S6 12,5% |
| 13 | `soru_politikasi` | dört politikada teslim farkı <= %2; hep gönder açık hata medyanı <= +%20; hata sprinti yok | **GEÇTİ** | teslim farkı en çok 0,6% (S5); hep gönder açık hata artışı en çok 17,0% (S6) |
| 14 | `tahmin_sonuc` | plan-kapanis farkı <= 1e-6 | **GEÇTİ** | en büyük fark 1.4e-14 (9460 koşu; aşama ilerlemesi, bitiş, n, F, düzeltme işi, çekilen kart) |
| 15 | `a_sinirlari_oranli` | hiç düzeltmeyen 10-26 haftada k x 30'a varır; fix_due varmaz | **GEÇTİ** | S1 22,5 hf (9 hat: 22,5), fix_due 0/20; S2 23,0 hf (9 hat: 17,0), fix_due 0/20; S3 19,0 hf (9 hat: 15,0), fix_due 0/20; S4 16,5 hf (9 hat: 16,5), fix_due 0/20; S5 17,0 hf (9 hat: 17,0), fix_due 0/20; S6 13,0 hf (9 hat: 13,0), fix_due 0/20 |
| 16 | `arz_havuzu` | kaynaklı arzda sprintlerin >= %90'inda açık aday >= 0,75 x ekip (8 kişi altında >= ekip) | **KALDI** | büyüme eğrisi 100,0%; sabit ekipler: S1 100,0%, S2 100,0%, S3 100,0%, S4 100,0%, S5 100,0%, S6 62,5%; 330 hesapta S5 100,0%, S6 100,0% · altında: {'A¦S6¦kaynakli¦2': 0.62} |
| 17 | `bosta_nedenli` | boşta <= %10; değilse her sprintte neden yazılı (nedensiz 0); 50 kişi boşta <= %15 (PRD 4.3 madde 7) | **KALDI** | 8300 koşunun 5163'inde boşta > %10; nedensiz 0; 50 kişi boşta: S6 5,4%, A¦S6¦kaynakli¦2 17,9%, R¦S6¦330 13,2% |
| 18 | `kart_yok_sprinti` | büyüme eğrisi 130 hf: 'planlanacak kart kalmadı' sprinti <= %5 | **GEÇTİ** | kaynaklı 0,0% (sonlu katalog: 87,3%) |
| 19 | `oneri_dolulugu` | önerinin aldığı iş / planın alabileceği >= %94; bot = öneri | **GEÇTİ** | en düşük 99,2% (GC¦kaynakli) · altında: {} |
| 20 | `derinlik_kazanci` | 5. kartın kazancı ilkinin <= 1/3'u | **GEÇTİ** | 5. kart ilkinin 31,6%'i (0,75^4); S6 kaynaklı 20 tohumun 80 alanından 80'inde >=5 derinlik kartı bitti |
| 21 | `istek_payi` | raporlanır (hedef yok); isteği yalnız 3★ ve üstü hesap yapar | **GEÇTİ** | teslim puanında istek payı S3/100 hesap: 12,2%; S3/330 hesap: 23,3%; S4/100 hesap: 7,3%; S4/330 hesap: 13,3%; S5/100 hesap: 3,5%; S5/330 hesap: 6,4%; S6/100 hesap: 2,1%; S6/330 hesap: 3,5% |
| 22 | `takim_bolme (EA)` | EA takımı ertelendi (PRD 7, QCD D5) | **ÖLÇÜLMEDİ** | ÖLÇÜLMEDİ: kapsam dışı |
| 23 | `uymayan_moral` | S3 + PM'in Test kutusu: 60 haftada PM 60 ile 90 moral kaybeder; atama koşuluyla ayrıca ölçülür | **KALDI** | atama koşuluyla PM medyan −28 (en az −22, en çok −34); koşulsuz (UNFITCOND=0) medyan −98 (en az −82, en çok −104) · koşulla PM'in hazırlayacak kartı olduğu haftalarda Test'e girmez: koşullu değer koşulsuzdan küçük olmalı |
| N1 | `pm_ekleme` | PM eklemek teslimi hiçbir senaryoda düşürmez (tolerans yok); kartın hazırlayanı kuralı Karar 4 ile yeniden ölçülür | **KALDI** | karar4h: en kötü −1,0 (C36→C37), eksi adım 1/12; karar4: en kötü −4,0 (C36→C37), eksi adım 4/12; best: en kötü −0,5 (S4→S4 +3★ PM), eksi adım 1/12; preparer: en kötü −2,5 (C36→C37), eksi adım 1/12 |
| N2 | `atama_sirasi` | her atama anında ve aşamada daha büyük işte daha yavaş kişi yok; aynı girdi aynı atama; uymayan iş yalnız boşta kalacağa | **GEÇTİ** | 628085 atama satırı: yeni atananlar arasında ters 0, hafta başı tam eşlemede ters 0, uymayan işi önden işi varken verilen 0; aynı girdi aynı atama 6/6 koşuda · bilgi: sürerken kartında kalan (yapısal) yavaş kişi sayısı 45396 (kişi aşama ya da hafta bitene dek kartında kalır) |
| N3 | `kendi_karti` | kendi geliştirdiği kartı test eden x0,6 bulur, kurucu dahil | **GEÇTİ** | mikro test: geçti; tek kurucuda (S1) her test edilen kart kendi kartı: True; A+S koşularında 128487 test edilen kartın 20890'i kendi kartı, 9261'i kurucu |
| N4 | `early_closed` | erken kapanan sprint = 0 (PRD 4.3 madde 1) | **GEÇTİ** | 9460 koşuda erken kapanan sprint 0 |
| N5 | `plan_fill` | plan anındaki doluluk medyanı >= %90 (1, 3, 6, 12, 25, 50 kişi ve büyüme eğrisi) | **KALDI** | S1 (1 kişi) 70,1%, S2 (3 kişi) 99,8%, S3 (6 kişi) 110,9%, S4 (12 kişi) 116,6%, S5 (25 kişi) 121,1%, S6 (50 kişi) 123,3%; büyüme eğrisi 118,9% |

**Kalan kapıların okuması.**
- **1 `ekleme_dusurmez` ve `pm_ekleme` (KALDI):** kapı tolerans 0'da 20 tohumun medyanına bakıyor; tek adımın gürültüsü ±1 ile 3 puan/hf. Ortalaması gürültüden ayrılan tek eksi adım eğri 41 → 42 (test darboğazında geliştirici eklemek, §3.1). PM adımı: R'nin kuralı (ufuklu) 20 tohumda −1,0, 100 tohumda −0,32 ± 0,27 (fark yok); PRD'nin haftalık kuralı 100 tohumda −4,26 ± 0,23 (gerçek kayıp, 94/100 tohum eksi). Kapıyı geçirmek için tolerans ya da tohum sayısı gerekir (E1'e soru).
- **2 `kurucu_buyume` (KALDI):** §3.1 ve §3.4. Kurucu işi sınırı (%12) tutuyor, düşüşlerin hepsi nedenli; teslim her adımda artmıyor (2 adım) ve MVP 2 adımda geç (4 → 8 hf).
- **6 `duzeltme_payi`, 7 `toplam_hata_isi`, 8 `acik_hata_sinirli` (KALDI):** her biri tek hücreden: kurucu + tasarımcı (2 kişi, geliştirici yok, `G|orta|tas-gel-test|1`) geç düzeltme payı %21,5 (kapı %20) ve toplam hata işi %22,6 (kapı %20); açık hata eğimi `G|gel4|tas-gel-test|1`'de 0,2045 (kapı 0,2; 0,0045 üstü). 347 senaryonun ≥ 2 kişilik hücrelerinde en yüksek erken düzeltme payı %16,1, hata sprinti en çok %1,0.
- **9 `testci_yildizi`, 10 `testci_degeri` (KALDI):** testçinin varsayılan Geliştirme ×0,7 kutusu yüzünden (§9); "testçi yalnız Test" kolunda 9 geçiyor, 10 yine kalıyor (12 ve 25 kişide −%15,2 ve −%19,0).
- **12 `soru_sikligi` (KALDI):** eşikli kip (karşılaştırma) sınırın içinde (en yüksek S4 %31,5); bağlı kip PR senaryolarında 25 ve 50 kişide %13,3 ve %12,5 (sınır %10): bu sayı benim söz yoğunluğu varsayımıma bağlı (§8).
- **16 `arz_havuzu`, 17 `bosta_nedenli` (KALDI):** ikisi de aynı hücre: 0. haftadan tam 50 kişi ve haftada 3 hesap (kaynaklı sabit ekip %62,5; D_SIM_v3 inceleme: %65). Büyüme eğrisi %100, 330 hesapta 25 ve 50 kişi %100. Boşta payı bu hücrede %17,9 (50 kişi sınırı %15); öteki 50 kişi hücreleri %5,4 ve %13,2.
- **23 `uymayan_moral` (KALDI):** atama koşuluyla PM 60 haftada medyan −28 moral kaybediyor (en az −22, en çok −34); koşulsuz (eski kural) −98. Koşul kaybı %71 azaltıyor; kapının 60 ile 90 bandı koşulsuz içindi, koşullu için yeni bir bant E1'in kararı (öneri 20 ile 35).
- **`plan_fill` (KALDI):** yalnız 1 kişi %70,1; 3 kişi %99,8 ve üstü hepsi ≥ %99,8 (§4).

## Yorumlar (PRD'nin açık bıraktığı ya da çeliştiği yerlerde benim seçtiklerim)
Her biri `dsim3.py`'de bir ortam anahtarıdır (parantezde); varsayılan PRD'nin birebir okumasıdır, "R" önerdiğim okumadır.

1. **S1 ile S6 = 1, 3, 6, 12, 25, 50 kişi.** `BASES` sayımı: S1 kurucu; S2 kurucu, geliştirici, tasarımcı; S3 kurucu, PM, tasarımcı, 2 geliştirici, testçi; S4 1 + 2 PM + 2 tasarımcı + 5 geliştirici + 2 testçi; S5 1 + 3 + 4 + 12 + 5; S6 1 + 6 + 8 + 25 + 10. Koşuların `n` alanı da 1, 3, 6, 12, 25, 50 çıktı (`dgates` ve tablolar `n`'e dayanır).
2. **Aşamanın büyüklüğü** (Karar 4): kartın o aşamadaki *toplam* ihtiyacı (hazırlık küçültmesinden sonra, kalan değil). Düzeltme alt aşaması Geliştirme satırındadır ve büyüklüğü düzeltme işidir. Eşitlikte kartın toplam puanı, plan sırası, kart kimliği (`card_key`).
3. **Çok aşamaya uyan kişi** (kurucu, ikincil alanlı): önce aday sınıfı (ana alan 0, kurucu 1 ya da güçlü alanında 0, ikincil 2, uymayan 3), sonra o aşamadaki hız, sonra kimlik sıralar. Aynı sınıf ve hızla birden çok aşamaya uyan kişi (4/0/4/0 kurucu her aşamada 8,6) o anda **en öncelikli açık kartın aşamasını** seçer; eşitlikte Geliştirme, Tasarım, Test. Neden: sabit bir aşama sırası (ilk denemem) kurucuyu testte bekleyen kartı bırakıp yeni kartın tasarımına sokuyordu; 3 kişide MVP 4. haftadan 8. haftaya kayıyordu. Sınıf ile öncelik çatıştığında (güçlü alanlı kurucu) PRD sustuğu için sınıf önce okundu; öbür okuma `FOUNDERROW=1` (§3.4).
4. **Uymayan iş** (sınıf 3): yalnız kişi aksi hâlde boşta kalacaksa verilir. "Boşta" = uyduğu başka aşamada açık slot yok **ve** önden işi yok (PM'in hazırlanmamış kartı, tasarımcının önden tasarlayacağı kart). `UNFITCOND=0` koşulsuz, eski. Y × U tabanı 0,3 yalnız sınıf 3'e uygulanır (`UFLOOR`).
5. **Yerinden almama:** kişi aşama ya da hafta bitene dek kartında kalır. Yeniden atama anları: hafta başı, bir aşamanın açılışı, bir kişinin kartındaki aşama bitince (o an yalnız boştaki kişiler atanır), çekilen kartın gelişi. Sonuç: daha hızlı biri boşa çıkınca daha küçük karta gidebiliyor; denetimde bu "kartında kalan yavaş kişi" olarak ayrıca sayılır (bilgi, §3.3).
6. **Kadro dağıtımı** (`KEYMODE`): `size` PRD'nin birebir okuması; hem kaç kişi alacağını hem kimin gideceğini büyüklük belirler. `plan` önerdiğim okuma: **kaç kişi alacağını plan/öneri sırası, kimin gideceğini büyüklük belirler.** Neden: `size` küçük kartı açlığa mahkûm ediyor (§12). Kişi eşlemesi iki kipte de aynı: en hızlı kişi en büyük karta, kadro dolunca sıradaki karta.
7. **PM eşleme** (`PMRULE`): `karar4` PRD'nin haftalık okuması (PM'ler yıldızdan aşağı, en iyisi en büyük karttan başlar ve haftalık hızı bitene dek gider; kartı ilk dokunan PM hazırlayanıdır ve sprintler boyunca kalır; yeni PM yalnız sahipsiz kartı alır). `karar4h`, "yalnız hazırlıksız kalacak kartı hazırlar" cümlesini sprint ufkuyla okur: bir PM sahipsiz kartı yalnız daha iyi PM'lerin sprint sonuna kadarki toplam kapasitesi o kartı karşılamıyorsa alır. `preparer` eski kuyruk sırası ve hazırlayanın yıldızı (PRD'nin −2,5'ini veren kural); `best` v3'ün kuralı (fayda haftada hazırlık yapan en iyi PM'in yıldızından).
8. **Hazırlanacak kartlar kümesi** (`PREPMULT`, yeni oynatma yolu, her PM kuralı için): kuyruğun başındaki, planın o sprintte aldığı yeni kart sayısı kadar kart (= sonraki sprintin girişi, D_MODEL_v3 §3.8 "sonraki sprint sütunu"). `PREPMULT=0` eski "3 × sprintteki kart" penceresidir. Karar 4'ün "büyükten küçüğe" sırası bu küme içindedir.
9. **Sabit 2 hafta ve çekme** (`EARLY=0`, `PULL=1`): sprint her zaman 2 hafta oynar. Ekip bir aşamada işsiz kalacakken (boştaki kişi, uyduğu aşamada açık slot yok) çekme kuyruğundaki ilk uyan kart sprinte girer; kuyruk planın sonunda kalan adayların öneri sırasıdır (düzeltme kartları dahil) ve plan anında dondurulur (tahmin = sonuç için). Alım kuralı planınkiyle aynıdır ve **sprintin kalan süresiyle ölçeklenir**: toplam iş ≤ 1,25 × kapasite × kalan süre oranı, aşama satırı ≤ 2 × aşama kapasitesi × kalan oran. Plan oynatması, "+", çekme denetimi ve kapanış aynı `week2` ve `Puller` kodunu koşar.
10. **Düzeltme kartı yalnız düzeltme payı tavanına tabidir** (toplam 1,25 tavanına değil); sprintte düzeltme işi yoksa ilk kart girer (eski simülasyonla aynı). "Öncelikli düzeltme" = hatta ≥ 2 açık hata (A'nın `fix_due` ve D_MODEL_v3 §6.5'in tanımı); PRD'nin "5 hata" eşiği `PRIOFIX=5` ile denenebilir, koşulmadı.
11. **Öneri (6 basamak):** (1) söz kartları, vade yakın önde; (2) vadesi bu ya da sonraki sprintte olan talepler; (3) devreden kartlar (zorunlu, plana doğrudan girer); (4) düzeltme kartları; (5) çeyrek hedefinin, hedef yoksa **en zayıf alanın** (hat numarası mod 4; kademe toplamı + derinlik kazancı en düşük olan) en iyi kartı; (6) kalanlar etki ÷ iş. "Etki": kademe ve istek kartı 1, derinlik kartı 0,75^(alanda biten derinlik kartı), düzeltme kartı açık hata sayısı. Ücretli plan simülasyonda yok; çeyrek hedefi koşulmadı (`GOAL=1` kodda, kapalı).
12. **Kalkanlar:** `SHIELD` "yalnız bitecek kartlar, en çok bir devreden"; `REQCAP` "sprintte en çok bir talep". Bitecek kart = plan oynatmasının (çekmesiz, önden işsiz) sprint sonunda bitirdiği kart; ikili aramayla, bitmeyen kart sayısı en çok max(1, zorunlu devreden kartlarınki) olan en uzun plan öneki bulunur. Çekilen kart için aynı denetim o anki durumdan sprint sonuna oynatılarak yapılır.
13. **Söz kartı** (PRD Kalan soru 2): MVP'den sonra her sprint başında 0,5 olasılıkla, aynı anda en çok 2 açık söz; söz, henüz sprinte girmemiş ilk 8 adaydan birinin kartına verilir (istek kartları hariç), vadesi o sprintten 1 ya da 2 sprint sonra, sprintin sonudur. Ayrı RNG (`<tohum>:promise`) ana akışa dokunmaz. Kaçan söz = vadeden sonra teslim edilen ya da hâlâ edilmemiş. `PROMISEFIRST=1` söz ve istek kartlarını Karar 4'te büyüklükten önce atar. Büyük kartın yavaşlaması, sözsüz (K3, 40 puan) kartların ortalama sprinte giriş-çıkış süresiyle ölçüldü.
14. **Hesap isteği 3★ ve üstü** (QCD C6): hesabın koltuğu ≥ 100 (Q3: koltuk büyüklüğü yıldızdır; istek kartı boyutlarının eşikleriyle aynı). Koltuklar 5 ile 150 arası log düzgün olduğundan hesapların yaklaşık %12'si 3★'dır (`REQSEATS`).
15. **Testçi kutusu** (`TESTERFIX`): 1 = Karar 2 tablosu, testçinin Yapım kutusu varsayılan açık (Geliştirme ve Düzeltme ×0,7, sınıf 2); 0 = Yapım kutusu açık ama Düzeltme alt aşamasına girmez; −1 = eski, testçi yalnız Test. Açık `test_boxes` verilen senaryolar (S9a "yalnız Test") korunur.
16. **GÖZÜ YÜKSEKTE ×1,15** hız çarpanı eklendi (`Person.gozu`); varsayılan senaryolarda kimsede yok, `HUY|S3` ve `HUY|S4` karışık huylu ekiplerdir (atama denetimine girer).
17. **Plan anındaki doluluk** = planın sprint başında taşıdığı kalan iş ÷ sprint kapasitesi (devreden kartların kalan işi dahil), 21-60. haftadaki sprintlerin medyanı; tohumlar arası medyan. **Boşta payı** = boşta kişi-hafta ÷ (kişi × hafta), PM'in artan hazırlık zamanı dahil (eski ölçü). **Arz yetmezliği** = açık aday sayısı hedefin (§3.13: 8 kişinin altında ekip, üstünde 0,75 × ekip) altında kalan sprint payı ve "planlanacak kart kalmadı" sprinti.
18. **Kapı eşikleri** PRD §4.1'e göre: `ekleme_dusurmez` tolerans yok (tohum medyanı farkı ≥ 0), `kurucu_buyume` %12, `mvp_tek_kurucu` sprint sonu, 6. hafta, en geç 8 (tüm tohumlar çift hafta ve 6 ile 8 arası, medyan 6), `oneri_dolulugu` %94. Tek adımın gürültüsü teslimde ±1 ile 3 puan/hf düzeyindedir (kart büyüklüğü 15 ile 40, tohumlar arası dağılım); tolerans yok kapısı gerçek bir etkiyi gürültüden ayıramaz, bu yüzden her adım için aynı tohumlarda ortalama fark ± standart hata da hesaplandı ve PM adımı için 100 tohum koşuldu.
19. **Daha iyisiyle değiştirme** (`REP`): taban ekibin o roldeki **en zayıf** kişisi aynı kimlik ve kutularla bir yıldız daha iyi (+2 puan) ya da 5★ (10 puan) bir kişiyle değiştirilir; rol başına bir sınama (geliştirici, testçi, tasarımcı, PM), S2 ile S6'da.
20. **Derinlik kartı tüketimi** = bir hatta koşu boyunca açılan derinlik kartı sayısı (`depth_seq`, 9 hat); yazılı ad sayısı hat başına 6'dır (PRD Karar 13). Koşu uzunluğu oyunun yumuşak tavanı olan 104 hafta (büyüme eğrisinde 130).
21. **EA takımı** (kapı 22) PRD §7 gereği ölçülmedi.
22. **Kapı 12 (soru sıklığı):** PRD'nin bağlı kipi (yalnız söz, istek ya da tarihli kartta soru) `PR` senaryolarında sayıldı (`linked_q`: kapanışta bilinen hatası olan kart söz ya da istek kartıysa). Eşikli kip karşılaştırma olarak eski ölçüyle verildi.
23. **Plan–kapanış karşılaştırması** kart başına dört aşamanın ilerlemesi, bitiş zamanı, hata sayısı, bulunan hata ve düzeltme işini kapsar; çekilen kartlar aynı sırayla eşlenir (`compare_pred`, sıra farklı olsaydı fark büyük çıkardı).
24. **Kod değişikliği notu:** zincir koşulduktan sonra `dsim3.py`'ye iki yama girdi: tek kart kipinde (S12) çekmenin kapatılması ve düzeltme kartlarının eskisi gibi önce alınması; `FOUNDERROW` anahtarı (varsayılan kapalı). S12 yeniden koşuldu; başka senaryo bu yamalardan etkilenmiyor (eski yol kontrolü ve dcheck/ddet yeniden koşuldu).

## Yeniden üretim
Klasör: `docs/tasks/faz_cde/d_taslak/dsim/v3/`. Her komut buradan koşulur; hepsi `python -I`. Windows'ta işçiler `dsim3.py`'yi yeniden okuduğu için ortam değişkenleri komuttan **önce** verilir; senaryolar `dsim3.py` içinde kayıtlıdır. En çok 2 işçi (`D3_WORKERS=2`); her çağrı 8 dakikalık bütçeyle biter, eksik iş sonraki çağrıda önbellekten tamamlanır (`out/<etiket>/<senaryo>.pkl`).
```
R="D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h"          # önerilen okuma; P = ortam değişkeni yok; L = D3_LEGACY=1
bash chain.sh main      # R: A SK S E D B F G R I PR DEP HUY UF PMC (20 tohum)
bash chain.sh pm        # R PM3 (100 tohum), R_pm4w, R_pmbest, R_pmpreparer (PMC + PM3)
bash chain.sh repro     # eski oynatmada "-2,5": L_pmpreparer, L_pmbest (PM3, 100 tohum)
bash chain.sh arms      # R_asgsprint R_nopull R_early R_slice40 R_size R_pf1 R_size_pf0/1 R_tf0 R_tfm R_tf1 R_unfit0
bash chain.sh rep       # R REP;  bash chain.sh curve   # R C (1..50 kişi)
bash chain.sh legacy    # L: A SK S G PMC
bash chain.sh final     # R A (S12 yaması sonrası), R_frow (D3_FOUNDERROW=1) E ve S, R_shield S
bash chain.sh shield    # P: S SK;  R_shield: S SK
python -I dsim3.py exec dcheck.py     # mikro testler -> out/dcheck.json
python -I dsim3.py exec ddet.py       # aynı girdi aynı atama -> out/ddet.json
D3_LEGACY=1 D3_DEPTHMAX=8 D3_DEPTHDIV=5 D3_FILLSKIP=12 D3_FIXMIN=0 python -I dsim3.py exec dregress.py "S1,S3,S4,A|S3|kaynakli|2,GC|kaynakli,EA3" 2   # dsim3_orig.py ile karşılaştırma
python -I dsim3.py exec dgates.py R   # kapı tablosu -> out/dgates_R.json, out/dgates_R.txt
python -I dsim3.py exec mkd0s.py      # tablolar -> out/d0s_tablolar.md
python -I d0s_rapor.py                # bu rapor (rapor_sablon.md + tablolar)
```
Dosyalar: `dsim3.py` (betik), `dsim3_orig.py` (değişmeyen kopya), `dgroups.py` (koşu grupları), `dbatch.py` (önbellekli toplu koşu), `chain.sh`, `dcheck.py`, `ddet.py`, `dregress.py`, `dan.py`, `dgates.py`, `mkd0s.py`, `trfix.py`, `fill.py`, `d0s_rapor.py`, `rapor_sablon.md`. Ham sonuçlar `out/`.

## Bitmeyenler
- **Kapı 22 `takim_bolme` (EA takımı):** PRD §7 gereği ölçülmedi (EA ertelendi); takım kodu `dsim3.py`'de duruyor ama koşturulmadı.
- **`R_shield` kaynaklı arz:** yalnız sınırsız arz (S) koşuldu; kalkanın kaynaklı arzdaki etkisi `P` (birebir tam) satırından okunur. 25 ve 50 kişilik kaynaklı kalkan koşuları bir saati aşıyordu.
- **Koşulmayan anahtarlar:** `PRIOFIX=5` (öncelikli düzeltme eşiği 5 hata), `GOAL=1` (çeyrek hedefi), `PREPMULT` duyarlılığı kodda var, koşulmadı. Öneri adımlarında ücretli plan ve çeyrek hedefi simülasyonda yok.
- **100 tohumlu PM ölçümü** yalnız 36 → 37. kişi adımında; öbür beş PM adımı 20 tohum.
- **Plan hesabının süresi** (D0 işi, Godot'ta) ölçülmedi; bu turun kapsamı dışı.
- **Sınanmayan nedenler:** testçisiz tabanın neden daha iyi çıktığı (§9), `FOUNDERROW` varyantının başka kapılara etkisi (yalnız kurucu büyümesi ve S1-S6 koşuldu).
- **Varsayımlar ölçümü sınırlıyor:** söz yoğunluğu (§8), hesap eğrisi (haftada 3 hesap), 3★ = koltuk ≥ 100. Değişirlerse kapı 12, 16 ve 17'nin değerleri değişir.

## İnceleme notu (Opus)
18 Ekim 2026 · D0s.v kıdemli inceleme, tek tur, düzeltme hakkıyla. Godot koşturulmadı, oyun dosyalarına dokunulmadı, git'te durum değişmedi. Yukarıdaki gövde olduğu gibi duruyor; düzeltilmiş sayılar aşağıda **eski → yeni** olarak yazılıdır. Gövdeyi okuyan, bu notla birlikte okumalıdır.

### Ne denetlendi
1. `dsim3_orig.py` ile `dsim3.py` farkı, PRD Karar 1–16, §4.1 ve QCD §2.3 "Atama"ya karşı satır satır.
2. Tahmin = sonuç: plan oynatması (`predict2`) ile hafta oynatması aynı `week2`, `assign_k4` ve `Puller` kodunu mu koşuyor.
3. `dgates.py`'nin kapı tanımları ve eşikleri PRD §4.1'e karşı; S1–S6 ölçekleri.
4. Rapordaki sayılar pkl çıktılarından yeniden hesaplandı: §12 teslim tablosunun Eski, R, "R atama eski", R_size ve P satırları; §5 kaynaklı boşta satırı; §3.2 PM tablosunun 100 tohumluk beş satırı; §4 plan doluluğu; §12 açık hata ve R_size MVP satırları. Hepsi raporla birebir aynı çıktı. S1–S6'nın `n` alanı 1, 3, 6, 12, 25, 50.
5. Yorumlar (Yorum 1–24).

### Doğru bulunanlar
- ✅ Hız Y(s) = 0,5 + 0,05·s + 0,01·s²; uyum ana 1,0 / ikincil 0,7 / uymayan 0,4; Y × U tabanı 0,3 yalnız uymayanda; tasarımcı kod yapmaz, PM'in sprint puanı yok (`fit`, `Person.rate`). Kurucu tabanı Y ≥ 0,86 yalnız hızda; yakalama ve yapım kalitesi gerçek yıldızı okuyor. Güçlü alan kuralı (puan ≥ 5, en güçlü alan → sınıf 0). TİTİZ ×0,85, GÖZÜ YÜKSEKTE ×1,15.
- ✅ Kadro ⌈ihtiyaç ÷ SLICE⌉, en az 1, aşamanın tam ihtiyacıyla. Karar 4'ün eşitlik sırası (aşama ihtiyacı, kartın toplam puanı, plan sırası, kimlik; kişide hız sonra kimlik). Kişi aşama ya da hafta bitene dek kartında kalıyor.
- ✅ PM: kart başına tek hazırlayan, kalıcı, yeni PM başlanmış kartı almıyor, fayda hazırlayanın yıldızından (iki PM kuralında da). Hazırlık %20, P(s) 15 → 25, hız +%10 → +%30, hata ×0,90 → ×0,60, yarım hazırlık orantılı; düzeltme kartı hazırlanmıyor.
- ✅ Erken kapanış yok (`EARLY=0`). Çekilen kart alım kuralına (kalan süreyle ölçekli) ve düzeltme pay tavanına uyuyor.
- ✅ H = 0,04 × S × tür × (1 − h) × yapım kalitesi (yalnız Geliştirme payıyla ağırlıklı 1 ÷ √Y), TİTİZ ×0,5, düzeltme kartı türü 0,3. C = Σ pay × c, en çok 1, en iyi testçinin c'sini aşmıyor (kapı 9'da 0 kart). Kendi kartını test eden ×0,6, kurucu dahil. Hafif 1,3, ağır 5,3, ağır payı %18. Düzeltme kartı 2 × açık hata, alt sınır yok, faz payı 0 / 0,7 / 0,3.
- ✅ Tahmin = sonuç: `predict2` kopyalar üstünde aynı `week2` ve `Puller`'ı koşuyor; tek fark `commit` (gerçek akıştan kart düşmek), tahmini etkilemiyor.
- ✅ Öneri basamakları 1, 2, 3, 5, 6 ve 12 aday atlama (kaynaklı arzda) PRD'deki gibi.
- ✅ Yorumlar makul ve açıkça yazılmış; PRD'den ayrılan her okuma (R'nin üç anahtarı) birebir okumanın sayısıyla yan yana veriliyor.

### Bulunan hatalar ve düzeltmeler
1. ❌ → ✅ **"Öncelikli düzeltme" eşiği 2 okunmuştu (Yorum 10); PRD Karar 14: "Öncelikli eşiği hatta 5 hata, değişmez."** `PRIOFIX` varsayılanı 5 oldu (`dsim3.py:41`). Düzeltme kartı yine 2 açık hatadan doğuyor; 2–4 hatalı kart artık 4. basamakta değil, 6. basamakta etki ÷ iş sırasıyla giriyor. Etki yalnız kaynaklı arzda: sınırsız arzda kartların sırası aynı kalıyor (S1–S6, 20 tohum, yeniden koşuldu: bütün metrikler 0 fark). Tek kurucuda etki büyük: boş sprinte ilk giren kart her zaman alındığı için 4 puanlık düzeltme kartı ilk giriyordu, 25 puanlık kart 1,25 × 17,2 tavanına sığmadığı için kurucu sprinti tek düzeltmeyle geçiriyordu (tohum 1, 34–38. hafta). Gövdedeki tek kurucu kaynaklı sayıları (teslim 3,3, boşta %37, plan doluluğu %46,5) bu hatanın ürünüydü.
2. ❌ → ✅ **Tahmin = sonuç denetimi (`compare_pred`) iki listeyi `zip` ile eşliyordu:** plan ile kapanış farklı sayıda kart çekseydi fazlası görülmezdi. Uzunluk ve kart kimliği denetimi eklendi (fark 1 sayılır). Yeniden koşulan bütün koşularda (S1'in çekme yaptığı koşular dahil) fark yine en çok 1,4e-14.
3. ❌ → ✅ **`atama_sirasi` denetimi kendiliğinden doğruydu.** "Ters" koşulu (`placed[b][1] < placed[a][1]`) hiç doğamıyordu, çünkü yerleşim listesi kart sırasıyla dolar; "uymayan iş önden işi varken" sayacı da koşulun kendisi geçtikten sonra sayılıyordu. Yani kapı N2'nin "628.085 satırda ters 0" sonucu bir şey ölçmüyordu (atamanın kendisi doğruydu, bunu `dcheck`'in mikro testleri gösteriyor). Denetim aşamanın ihtiyacıyla yeniden yazıldı; uymayan iş yerleşimden sonra iki yönden sayılıyor: önden işi varken ve uyduğu satırda boş yer varken. Falsification (`inceleme_falsify.py`): kişi sırası ters çevrilince S5'te 797 satırın 155'i, HUY|S4'te 422'nin 66'sı ters çıkıyor (eski denetim aynı bozuk kodda 0 buluyordu); uymayan iş koşulu kapatılınca önden işi varken verilen 27. Düzeltilmiş denetimle N2 yine geçti.
4. ❌ → ✅ **Beş kapının tanımı PRD §4.1'den ayrılıyordu** (`dgates.py`):
   - Kapı 16 `arz_havuzu`: §4.1 madde 6 "büyüme eğrisinde" diyor; betik sabit ekipleri de kapıya sokuyordu. Sabit ekipler artık bilgi satırı.
   - Kapı 17 `bosta_nedenli`: §4.1 madde 6 "nedensiz boşta 0" diyor; "50 kişide en çok %15" §4.3 madde 7'nin oynanış kapısıdır. Ayrı satır oldu (`4.3/7 bosta_50`).
   - Kapı 23 `uymayan_moral`: §4.1 madde 8'in 60–90 bandı koşulsuz ölçüm içindir ("atama koşuluyla ayrıca ölçülür"); betik bandı koşullu değere uyguluyordu. Bant artık koşulsuz değere uygulanıyor, koşullu değer yanında.
   - Kapı 12 `soru_sikligi`: §4.1 madde 5 "eşikli kip yalnız karşılaştırmadır"; eşikli kip artık kapıya girmiyor.
   - Kapı 2 `kurucu_buyume`: eşik %12'den %10'a indi. ERDEM_QCD_CEVAP §2.3 D3 (%10) PRD §4.1'deki %12'nin üstünde bağlayıcı. Ölçülen en kötü %8,1, iki eşikte de geçiyor.

### Kapı tablosu (§13), düzeltilmiş (etiket `R6`, `out/dgates_R6.txt`)
| No | Kapı | Eski | Yeni |
|---|---|---|---|
| 2 | `kurucu_buyume` | KALDI (eşik %12) | KALDI (eşik %10): kurucu işi en çok %8,1, düşüşlerin hepsi nedenli; teslim 2 adımda artmıyor, MVP 2 adımda gecikiyor (değerler aynı) |
| 12 | `soru_sikligi` | KALDI; bağlı kip S1–S6 %0,0 / 1,7 / 8,7 / 8,7 / 13,3 / 12,5 | KALDI; bağlı kip %0,3 / 2,0 / 6,8 / 8,8 / 12,0 / 15,0 (eşikli kip bilgi: değişmedi) |
| 16 | `arz_havuzu` | KALDI (sabit 50 kişi %62,5) | **GEÇTİ**: büyüme eğrisi %100; sabit 50 kişi %65,0 (bilgi), 330 hesapta 25 ve 50 kişi %100 |
| 17 | `bosta_nedenli` | KALDI (50 kişi kaynaklı %17,9) | **GEÇTİ**: nedensiz boşta 0 |
| 4.3/7 | `bosta_50` (yeni satır) | (17'nin içindeydi) | KALDI: S6 %5,4, A\|S6\|kaynaklı %17,7, R\|S6\|330 %13,3 |
| 19 | `oneri_dolulugu` | GEÇTİ, en düşük %99,2 | GEÇTİ, en düşük %99,1 (GC\|kaynaklı) |
| 21 | `istek_payi` | S3/100 %12,2 · S3/330 %23,3 · S4/330 %13,3 · S5/330 %6,4 | S3/100 %12,3 · S3/330 %24,4 · S4/330 %13,2 · S5/330 %6,8 (öbürleri aynı) |
| 23 | `uymayan_moral` | KALDI (koşullu −28 banda bakılıyordu) | KALDI: koşulsuz −98 (bant 60–90, 8 üstünde); koşullu −28 ayrıca |
| N2 | `atama_sirasi` | GEÇTİ (denetim boştu) | GEÇTİ, denetim çalışıyor: 628.317 satırda ters 0; uymayan iş 341, önden işi varken 0, uyduğu satırda boş yer varken 0; aynı girdi aynı atama 6/6 |
| N5 | `plan_fill` | KALDI, büyüme eğrisi %118,9 | KALDI (yalnız S1 sınırsız %70,1), büyüme eğrisi %119,5 |

Öbür kapıların değeri değişmedi (1, 3–11, 13–15, 18, 20, 22, N1, N3, N4; hepsi sınırsız arzdan ya da etkilenmeyen gruplardan). **Sayım:** 29 satır (eski 28 + ayrılan `4.3/7`): **16 geçti, 12 kaldı, 1 ölçülmedi** (eski: 14 / 13 / 1). Gövdenin §0 madde 9'u ve §13'ün "Kalan kapıların okuması"ndaki 16 ve 17 maddesi buna göre okunmalı.

### Düzeltilmiş satırlar (eski → yeni)
**§4 ve §12, kaynaklı arz** (1 / 3 / 6 / 12 / 25 / 50 kişi / büyüme 1→10):
- R teslim: 3,3 / 20,9 / 47,2 / 98,1 / 237,7 / 415,4 / 66,7 → **5,0** / 21,2 / 47,6 / 97,8 / 239,9 / 415,1 / 66,6
- R plan doluluğu: %46,5 / 116,0 / 120,1 / 120,3 / 123,4 / 123,2 / 118,9 → **%91,9** / 117,2 / 119,8 / 120,7 / 123,3 / 123,2 / 119,5
- R, atama eski teslim: 3,3 / 20,6 / 46,5 / 97,2 / 233,0 / 401,9 / 65,7 → 5,0 / 21,3 / 46,3 / 97,0 / 230,1 / 405,1 / 65,3
- R, erken kapanış var teslim: 4,8 / 20,9 / … → 5,9 / 21,2 / 47,6 / 97,8 / 239,9 / 415,1 / 66,6
- PRD birebir (R_size) teslim: 3,3 / 20,6 / 47,5 / 96,4 / 226,9 / 364,2 / 65,9 → 5,0 / 20,6 / 47,4 / 96,8 / 227,6 / 364,1 / 67,2
- Plan doluluğu öbür kollar, 1 kişi: atama eski %46,5 → %94,8; çekme yok %46,5 → %112,2; erken kapanış %68,6 → %97,7; R_size %46,5 → %91,9
- Sprintte çekilen kart, 1 kişi: R 0,10 → 0,20; atama eski 0,10 → 0,15; erken kapanış 0,10 → 0,15; R_size 0,10 → 0,20
- "PRD birebir tam (P)" kaynaklı satırı eski eşikle kaldı; kalkanlı kaynaklı koşu pahalı olduğu için yeniden koşulmadı.

**§5, kaynaklı arz boşta** (aynı sütunlar):
- R: %37,0 / 12,0 / 12,3 / 13,1 / 8,1 / 17,9 / 6,2 → **%10,9** / 12,1 / 12,4 / 12,8 / 8,0 / **17,7** / 6,4
- R, atama eski: %37,0 / 12,5 / 13,4 / 13,0 / 8,8 / 19,0 / 7,0 → %10,9 / 12,7 / 13,4 / 12,9 / 9,0 / 18,8 / 7,0
- R, çekme yok: %40,6 → %10,9 (öbürleri R gibi); R, erken kapanış: %14,8 → %6,8
- R_size: %37,0 / 13,7 / 11,6 / 14,2 / 11,3 / 27,1 / 5,9 → %10,9 / 14,4 / 11,7 / 14,4 / 11,1 / 26,9 / 5,6
- §5 okumasındaki "%17,9" → %17,7; "R\|S6\|330 %13,2" → %13,3.

**§6, tek kurucu kaynaklı** (hata sprinti MVP sonrası · 21–60 hf · düzeltme payı erken · geç · teslim · MVP):
- R: 2/514 (%0,4) · 2/400 (%0,5) · %23,3 · %23,3 · 3,3 · 8 → **11/514 (%2,1) · 11/400 (%2,8)** · %23,0 · **%6,5** · **5,0** · 8
- PRD birebir: 2/514 (%0,4) · 2/400 (%0,5) · %23,3 · %23,3 · 3,3 · 8 → 10/514 (%1,9) · 10/400 (%2,5) · %23,0 · %4,4 · 5,0 · 8
- Kapı 6'nın tek kurucu sınırı (hata sprinti ≤ %5, erken ≤ %50) iki satırda da tutuyor.

**§7, kaynaklı arz SLICE 8 / 40** (1 / 3 / 6 / 12 / 25 / 50 / büyüme):
- 8 teslim → R satırı yukarıdaki gibi; 8 boşta → R satırı yukarıdaki gibi; 8 arz yeterli sprint, 50 kişi: %62,5 → %65,0
- 40 teslim: 3,3 / 21,3 / 47,4 / 94,6 / 228,4 / 375,1 / 65,0 → 5,0 / 21,1 / 47,2 / 94,8 / 227,8 / 376,1 / 65,1
- 40 boşta: %37,0 / 11,9 / 11,9 / 15,0 / 10,9 / 25,6 / 6,9 → %10,9 / 12,0 / 12,3 / 15,1 / 11,1 / 25,3 / 6,8
- 40 arz yeterli sprint, 50 kişi: %50,0 → %45,0
- Okuma (ve §0 madde 5): kaynaklıda 40'ın teslim farkı 12 / 25 / 50 kişide −%3,6 / −%3,9 / −%9,7 → **−%3,1 / −%5,1 / −%9,4**; boşta +1,9 / +2,8 / +7,6 → +2,4 / +3,1 / +7,7 puan; 50 kişide arz yetmezliği %37,5 → %50 yerine **%35 → %55**. "8 kalsın" önerisi değişmiyor.

**§8, söz kartı** (kaçan oranı; 1 / 3 / 6 / 12 / 25 / 50 kişi):
- R, saf büyüklük: %71,7 / 20,2 / 0,3 / 0 / 0 / 0 → %79,8 / 20,8 / 0,3 / 0 / 0 / 0; bağlı soru %0,0 / 1,7 / 8,7 / 8,7 / 13,3 / 12,5 → %0,3 / 2,0 / 6,8 / 8,8 / 12,0 / 15,0
- R, söz önce: %71,9 / 11,6 / 0 / 0 / 0 / 0 → %81,0 / **13,6** / 0 / 0 / 0 / 0
- PRD birebir, saf büyüklük: %73,3 / 32,6 / 27,0 / 11,6 / 11,3 / 3,6 → %80,2 / **36,8 / 25,6 / 14,4 / 11,3 / 2,8**; küçük kart kaçan (3–50 kişi) 24/154, 13/83, 3/42, 12/107, 8/196 → 34/155, 14/71, 3/41, 14/110, 6/203
- PRD birebir, söz önce: %71,8 / 18,2 / 0,3 / 0 / 0 / 0 → %80,6 / **16,3** / 0,3 / 0 / 0 / 0
- Tek kurucuda sözsüz 40 puanlık kart bu 80 haftalık koşularda hiç teslim edilmedi (süre sütunu "-"). §0 madde 6'nın sonucu (R'de söz önce yalnız 3 kişide fark yaratıyor; birebir okumada şart) değişmiyor.

**§10, derinlik kartı** (medyan hat · en çok kullanılan hat · tüm koşularda en çok · biten en çok · 6 adı aşan hat payı):
- 1 kişi: 0 · 9 · 12 · 1 · %14,4 → 0 · 10 · 12 · 2 · **%35,6**
- 3 kişi: … · %97,2 → 13 · 16 · 18 · 9 · %95,0; 6 kişi en çok 30 → 31; 12 kişi 51,5 · 56 · 44 → 52 · 55 · 45; 25 kişi 114 · 123 · 109,5 → 115 · 122 · 109; 50 kişi 177 · 192 · 200 · 187,5 → 178 · 192,5 · 202 · 188; büyüme 40 · 32,5 → 41 · 33
- §0 madde 8'in "tek kurucuda medyan 0, en çok kullanılan hat 9" cümlesi: en çok kullanılan hat medyan koşuda 10 ve hatların %35,6'sı 6 adı aşıyor.

**§2, aynı girdi aynı atama:** A\|S3\|kaynaklı\|2 157 satır, teslim 40,94 → 155 satır, 41,88 (aynı atama: evet). Mikro testler 12/12 geçti; eski yol `dsim3_orig.py` ile 5 senaryo × 2 tohumda 550 metrikte 0 fark (yeniden koşuldu).

**§0 madde 10 (g), tek kurucu:** sınırsız arzdaki sayılar (teslim 4,5, boşta %26,4, erken kapanış kolu 5,3 ve %12,2) değişmedi. Kaynaklı arzda tek kurucu artık R'de 5,0 puan/hf, boşta %10,9 (erken kapanış kolu 5,9, %6,8); kaynaklı tek kurucunun bedeli −%15 teslim, +4 puan boşta.

### Değiştirilmeyen, Erdem'in bilmesi gerekenler
- ⚠️ **Kapı tablosu R okumasıyla.** R, PRD'den üç yerde ayrılıyor: kadroyu plan sırası belirliyor (Karar 4 "büyükten küçüğe" diyor), PM ufuklu (karar4h), kalkan kapalı. Birebir okuma (R_size, P) yalnız ölçek gruplarında (S, SK, PR) koşuldu; onunla kapı tablosu yok. Ayrılıkların her biri gerekçeli ve E1 sorusu olarak yazılmış; doğru okuma.
- ⚠️ **Karar 11 "sprintte en çok bir kart devreder" R'de çekmede de yok.** `SHIELD=0` hem planın kalkanını hem çekmenin "en çok bir devreden" kuralını kapatıyor. R'de 3 kişi ve üstünde çekme sprintte ~0 kart olduğu için etki yalnız tek kurucuda (0,2 kart/sprint). Yalnız çekmeye uygulanan kural ayrıca koşulmadı.
- ⚠️ **Düzeltme kartı plan alımında 1,25 tavanından ve aşama tavanından muaf** (eski simülasyondan; Yorum 10). Çekmede ise hızlı ret satırı (`Puller.pull`: kalan ÷ 1,3 > 1,25 × kalan kapasite) düzeltme kartına da uygulanıyor. İki yol tutarsız; Karar 11 çekilen kart için alım kuralını istiyor. Ölçüme etkisi küçük (çekme seyrek).
- ⚠️ **Sınırsız arzda öneri 12 adayı atlamıyor,** ilk tutmayan kartta duruyor (eski simülasyondan). Gövdenin §4 açıklaması (S1 sınırsız %70,1: K3 1,25 × 17,2 tavanına sığmıyor) bu kuralla birlikte okunmalı: sınırsız arzda daha küçük aday denenmiyor; payı ayrıca ölçülmedi. Kaynaklı arzda (12 adayı atlıyor) tek kurucu artık %91,9.
- ⚠️ **Bağlı soru sayımı** (kapı 12, `asked_linked`) söz ya da istek kartında tarihe bakmıyor (PRD: "bu ya da sonraki sprint"): üst sınır sayar. Kesinti bütçesi (Karar 16) simülasyonda yok.
- ⚠️ Yeni fark: tek kurucu kaynaklıda hata sprinti %0,4'ten %2,1'e çıktı (21–60. hafta %2,8; kapı %5). Tohum 1'in plan izinde kurucu artık önce özellik kartını alıyor, 2–4 hatalı düzeltme arkada kalıyor; geç düzeltme payı %23,3 → %6,5.

### Dosyalar ve yeniden üretim
- Değişen betikler: `dsim/v3/dsim3.py` (PRIOFIX, `compare_pred`, `assign_k4` denetimi; fark 34 satır), `dsim/v3/dgates.py` (kapı 2, 12, 16, 17, 23, N2). İnceleme öncesi kopyalar `out/_prio2/dsim3_before_review.py`, `out/_prio2/dgates_before_review.py`; eski çıktılar `out/R` ve `out/_prio2/` altında durur.
- Düzeltilmiş çıktılar: `out/R6/` (ana R okuması; S, A, SK, HUY, G, R, PR, DEP yeniden koşuldu, kalanı `out/R`'den kopya), `out/R5_*` (kaynaklı kollar), `out/dgates_R6.txt` ve `.json`, `out/d0s_tablolar_R6.md`. Yeniden koşu yaklaşık 25 dakika, en çok 2 işçi, her çağrı 8 dakikanın altında.
- Komutlar: `bash inceleme_rerun.sh main` ve `arms` (R5), `python -I dsim3.py exec inceleme_mkR6.py`, sonra `R6` için A, SK, HUY grupları (`dbatch.py R6 <grup> 470`, R'nin ortam anahtarlarıyla), `python -I dsim3.py exec dgates.py R6`, `python -I dsim3.py exec inceleme_mkd0s_R6.py`, `python -I inceleme_falsify.py` (R'nin ortam anahtarlarıyla).
