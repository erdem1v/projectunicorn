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

{{T:dcheck}}

- **Aynı girdi aynı atama, tüm koşu düzeyinde** (`ddet.py`): aynı ekip kişi listesi ters ve karışık sırayla verildiğinde atama kaydı ve sonuç aynı:

{{T:ddet}}

## 3. §4.1 madde 1
### 3.1 `ekleme_dusurmez` (tolerans yok), daha iyisiyle değiştirme dahil
Aileler: taban ekibe bir kişi (S2-S6 × 5 ekleme), 1 → 50 kişi ekleme eğrisi, kurucu büyümesi (4 kurucu tipi × 6 sıra × 3 alım), ve yeni **değiştirme** senaryosu (`REP`): taban ekibin bir rolündeki en zayıf kişi bir yıldız (+2 puan) ya da 5★ bir kişiyle değiştirilir (S2-S6, rol başına; 36 sınama).

{{T:ekleme}}

En kötü on iki adım:

{{T:ekleme_kotu}}

Değiştirme matrisi (taban teslimine göre fark, puan/hf; "." o ekipte o rol yok):

{{T:rep}}

**Okuma.** Kapı tolerans 0'da **KALDI**: 182 adımın (25 taban + 49 eğri + 72 kurucu + 36 değiştirme) 6'sı eksi: eğri 41→42 −4,0; eğri 23→24 −1,0; eğri 36→37 (PM) −1,0; S5'e +3★ tasarımcı −1,0; değiştirme: S2 tasarımcı +1★ −0,6 ve S5 tasarımcı 5★ −0,5. Kurucu büyümesinde eksi adım yok (iki sıfır adım). Gürültü ayrımı için her adımın aynı tohumlardaki ortalama farkı ve standart hatası da hesaplandı: ortalaması −2 standart hatanın altına inen (yani tohum gürültüsünden ayrılan) adım yalnız **eğri 41 → 42** (ortalama −2,85 ± 0,83, 20 tohumun 17'si eksi). O adımda eklenen geliştirici; ekip test darboğazında (Test satırı yükü kapasiteye oranı 0,97 → 1,02, Geliştirme 0,13 → 0,02), açık hata 14,5 → 19,8, teslim 423,0 → 419,0 (−%0,9). Olası neden: ek geliştirici test kuyruğuna daha çok kart sokuyor ve teste düşük yakalamalı kişiler giriyor; bu turda ayrıca sınanmadı. Yani "darboğaz olmayan role kişi eklemek hiçbir şey kazandırmaz" ve çok küçük bir kayıp doğurabilir; ekran bunu darboğaz cümlesiyle söylüyor (Karar 10). Değiştirme sınamalarında iki eksi değer (S2'de tasarımcı +1★: −0,6; S5'te tasarımcı 5★: −0,5) tohum gürültüsü büyüklüğünde. Kurucu büyümesinin 72 adımı: teslim 70 adımda arttı, 2'sinde artmadı (4★ ve 5★ geliştirmede güçlü kurucuya üçüncü geliştirici: 11,4 → 11,4 ve 12,0 → 12,0; ekip zaten doygun); MVP iki alım adımında gecikti (4 → 8 hf: 4★ ve 5★ güçlü kurucuya ilk alım tasarımcı iken); kurucunun kendi işi tabana göre en çok %8,1 düştü (kapı %12) ve işi önceki adıma göre %2'den çok düşen 9 adımın hepsinin nedeni kayıtlı (8'i iş yeni gelenle bölündü, 1'i aşama değişti). Kapı iki koşuldan kalıyor: teslim her adımda artmıyor ve MVP gecikiyor.

### 3.2 `pm_ekleme`: üç PM kolu yan yana ve "−2,5"in yeniden ölçümü
PM eklemenin teslim farkı (puan/hf). Kollar: **karar4h** (R: sprint ufkuyla "yalnız hazırlıksız kalacak kart"), **karar4** (PRD'nin haftalık okuması), **best** (v3: fayda haftanın en iyi PM'inden), **preparer** (fayda kartın hazırlayanından, eski kuyruk sırası: "kartı hazırlayanın yıldızı" kuralı).

{{T:pm37}}

Sütun "fark (ilk 20 tohum)", kapının 20 tohumlu okumasıdır. PRD'nin −2,5'i **yeniden üretildi**: eski oynatmada (prototipin ayarıyla) "hazırlayanın yıldızı" kuralı 36 → 37. kişi PM için ilk 20 tohumda −2,5 verdi; 100 tohumda medyan −2,0, ortalama −2,65 ± 0,22. Eski oynatmada v3'ün "best" kuralı: −0,5 (ilk 20), −0,0 (100). Karar 4'ün haftalık okuması aynı kuralı daha da kötüleştiriyor (−4,3 ± 0,2; 94/100 tohum eksi). Nedeni büyük olasılıkla şu: en iyi PM her hafta kapasitesini bitirince yeni ve zayıf PM, daha iyi PM'lerin sonraki hafta alacağı kartları kapıyor ve kartın hazırlayanı kalıcı olduğu için o kart zayıf faydayla çıkıyor (ufuklu okumanın farkı kapatması bunu destekliyor; kart kart izlenmedi). Ufuklu okuma (bir PM sahipsiz kartı yalnız daha iyi PM'lerin sprint sonuna kadarki toplam kapasitesi yetmiyorsa alır) bu sızıntıyı kapatıyor: ortalama fark −0,32 ± 0,27, 100 tohumun 42'si eksi (fark yok). 20 tohumlu kapı okuması tolerans 0'da yine de −1,0 veriyor; tek adımın gürültüsü ±1 ile 3 puan olduğu için bu bir kural hatası değil, ölçüm sınırı (Yorum 18).

Bütün PM adımları ("eğri": 1 → 50 eğrisinde PM'in eklendiği altı adım; "S2" ile "S6": tabana PM eklenmiş hâli; "1 kişi + PM": kurucuya ilk PM):

{{T:pmadim}}

### 3.3 `atama_sirasi`
Her atama anında ve her aşamada (aynı anda atanan kişiler arasında) daha büyük işte daha yavaş kişi yok; hafta başındaki tam eşlemede de yok; uymayan iş yalnız boşta kalacak kişiye gidiyor; aynı girdi aynı atamayı veriyor (§2). Tablo: R koşularındaki atama satırı sayıları (her satır bir aşamada bir atama anı):

{{T:atama}}

"Sürerken kartında kalan yavaş kişi" bir ihlal değil bilgidir: PRD "kişi aşama ya da hafta bitene dek kartında kalır" dediği için, daha hızlı biri boşa çıkınca daha küçük karta gidebiliyor. 12 kişide 15.670 atama satırının 2.461'inde, 25 kişide 31.684'ünün 2.813'ünde, 50 kişide 59.541'inin 5.085'inde görülüyor.

**Çok aşamaya uyan kişi** (kurucu): önce sınıf (ana alan 0, kurucu 1, güçlü alanında 0, ikincil 2, uymayan 3), sonra o aşamadaki hız, sonra kimlik; aynı sınıf ve hızla birden çok aşamaya uyuyorsa en öncelikli açık kartın aşamasını alır. İlk deneme (Geliştirme, Tasarım, Test sabit sırası) 3 kişide MVP'yi 4. haftadan 8. haftaya kaydırıyordu; kurucuyu testte bekleyen kartı bırakıp yeni kartın tasarımına sokuyordu. Hâlâ açık bir durum var (§3.4).

### 3.4 Kurucu: sınıf önce mi, öncelikli kart önce mi
`kurucu_buyume` kapısında (72 alım adımı) R okumasında iki adımda MVP gecikiyor (4 → 8 hf: 4★ ve 5★ geliştirme güçlü kurucuya önce tasarımcı alınınca) ve iki adımda teslim artmıyor (üçüncü geliştirici). Neden: güçlü alanında kurucu sınıf 0'dır; ekipte yeni bir geliştirme kartı olduğu sürece sınıf-önce eşleme onu geliştirmede tutuyor ve MVP kartlarının testi (kurucu orada sınıf 1) bekliyor. Denenen düzeltme (`D3_FOUNDERROW=1`: kurucu uzmanlar yerleştikten sonra, en öncelikli açık kartın aşamasına girer): teslim 72 adımın hepsinde artıyor (en küçük artış +0,4), ekleme kapısının kurucu ailesinde 0/72 eksi adım, MVP gecikmesi 2'den 1'e iniyor (4★ kurucu, ilk alım 1★ geliştirici: 4 → 6), nedensiz düşüş 0/15; ama kurucunun kendi işi tabana göre en çok **%19,0** düşüyor (kapı %12), çünkü kurucu uzmanlar yerleştikten sonra boş kalan aşamaya gidiyor ve hızlı güçlü alan iddiasını kaybediyor. Yani iki okuma da bir koşuldan kalıyor: sınıf-önce MVP'yi ve teslim artışını, öncelik-önce kurucunun kendi işini kırıyor. Karar E1'in: sınıf-önce (PRD'nin yazdığı) ya da öncelik-önce.

## 4. Plan anındaki doluluk
Plan anında planın taşıdığı kalan iş ÷ sprint kapasitesi (medyan). Hedef ≥ %90 (bugün %13 ile %15).

{{T:olcek_fillplan}}

Kaynaklı arz (hat başına K1 → K2 → K3 + derinlik + istek) için:

{{T:kay_fillplan}}

**Okuma.** 3 kişiden büyük ekiplerde plan %100 ile %123 dolu (sınırsız arzda 6 kişi ve üstü %111 ile %123; kaynaklıda %116 ile %123), yani hedef tutuyor; üst sınır 1,25 × kapasitedir. **1 kişide %70 (kaynaklıda %46,5)** ve 3 kişide sınırsız arzda %99,8: tek kurucunun bir kartı birkaç sprint sürer, devreden kartın plan anındaki kalanı küçüktür ve sınırsız akışta sıradaki kart K3 (40 puan) 1,25 × 17,2 tavanına sığmaz. Bu PRD'nin "1 kişi: kurucu sprintte bir kart civarı bitirir" cümlesiyle uyumlu ama %90'ın altı.

## 5. Boşta payı
Boşta kişi-hafta ÷ (kişi × hafta). PRD §4.3 madde 7: 50 kişide en çok %15.

{{T:olcek_idle_pct}}

{{T:kay_idle_pct}}

**Okuma.** Sınırsız arzda 50 kişi %5,4 (kaynaklı arzda 330 hesapla %13,2 ve büyüme eğrisinde %6,2), kaynaklı arzda 0. haftadan tam 50 kişi ve haftada 3 hesapla **%17,9** (kapı 16'nın "sabit 50 kişi %62,5" hücresiyle aynı neden: arz tüketimin gerisinde, gerçek bir oyun durumu değil). Tek kurucuda eski kurala göre +12 puan (%13,7 → %26,4); çekme 30,8 → 26,4, erken kapanış kolu 12,2.

## 6. Tek kurucunun hata sprinti (2 hafta, erken kapanış yok)
{{T:kurucu}}

Hata sprinti oranı MVP sonrası sprintlerde %0,4 ile %0,6 (PRD'nin 2 haftalıkta ölçülen %0,4'üyle aynı düzey; 1 haftalıkta %6,6 idi), 21-60. haftada %0,2 ile %0,5; kapı ≤ %5. Düzeltme payı %23,3 (kapı: erken ≤ %50). Sabit sürenin tek maliyeti §5'teki boşta payı ve tek kurucuda teslimin 5,1'den 4,5'e inmesi.

## 7. Kadro dilimi 8 ile 40
Sınırsız arz ve kaynaklı arzda, 1, 3, 6, 12, 25, 50 kişi; "arz yetmezliği" = açık aday havuzunun hedefin altında kaldığı sprint payı ve "planlanacak kart kalmadı" sprinti:

{{T:slice}}

**Okuma.** 40 her aşamaya tek isim koyuyor ama teslim ve boşta bedeli ödetiyor: sınırsız arzda 3 / 6 / 12 / 25 / 50 kişide teslim −%9,5 / −%2,0 / −%2,3 / −%2,7 / −%3,5, boşta +4,9 / +3,2 / +2,0 / +2,2 / +3,1 puan; kaynaklıda 12 / 25 / 50 kişide teslim −%3,6 / −%3,9 / −%9,7, boşta +1,9 / +2,8 / +7,6 puan (1 kişide fark yok). PRD'nin çekincesi (25 kişiden sonra kart arzı yetmez ve ekip boşta kalır) kaynaklı arzda yalnız 50 kişide görülüyor: arz yetmezliği %37,5 → %50. Öneri: **8 kalsın**.

## 8. Söz kartı iki sırada
Söz: MVP'den sonra her sprint başında 0,5 olasılıkla, aynı anda en çok 2 açık söz, kart sprintte henüz olmayan ilk 8 adaydan biri, vadesi 1 ya da 2 sprint sonra (Yorum 13). 80 hafta, 20 tohum, B2B. "Kaçan" = vadeden sonra teslim edilen ya da hâlâ edilmemiş.

{{T:soz}}

**Okuma.**
- **R'de** (kadroyu plan sırası belirliyor, söz kartı 1. basamak): "söz önce" yalnız 3 kişide fark yaratıyor (kaçan %20,2 → %11,6); 6 kişiden büyükte iki sırada da kaçan 0 ile 1 söz. Büyük kartın (40) ortalama süresi değişmiyor (6 kişide 3,2 → 2,9; 12-50 kişide 4,0 → 4,0 hf): "büyük işin biraz yavaşlaması" bedeli ölçülemeyecek kadar küçük.
- **Birebir okumada** (saf büyüklük) küçük söz kartı zayıf kişiye düşüyor ve kaçıyor: 3 / 6 / 12 / 25 / 50 kişide kaçan %32,6 / %27,0 / %11,6 / %11,3 / %3,6, küçük kartlarda (≤ 25) 24/154, 13/83, 3/42, 12/107, 8/196. "Söz önce" bunu %18,2 / %0,3 / %0 / %0 / %0'a indiriyor ve toplam teslimi değiştirmiyor (47,4 → 47,2; 231,8 → 232,6).
- **Tek kurucuda** iki sırada da vadesi gelen sözlerin yaklaşık %72'si kaçıyor (kapasite sorunu, sıra değil).
- **Sonuç.** Önerim: R'de söz önce sırası gerekmiyor (kadro zaten plan sırasıyla verildiği için söz 1. basamakta); birebir okumada şart. Karar 4'ün yazısına "söz ya da tarihli kart büyüklükten önce" cümlesini eklemek iki okumada da güvenli (R'de zararsız).
- **Bağlı soru** sütunu: PRD §4.1 madde 5 "bağlı kipte soru sprintlerin ≤ %10'unda": R'de 3-12 kişide %2 ile %9, 25 ve 50 kişide %13,3 ve %12,5 (kapı sınırın üstünde). Bu sayı söz yoğunluğuna (sprint başı 0,5 olasılık, aynı anda ≤ 2) bağlı bir varsayımdır; gerçek oyunda söz sıklığı C'nin kuralıdır.

## 9. Testçi Geliştirme ve Düzeltme yapar mı
Üç kol: testçi yalnız Test (eski, kutu yok); **TESTERFIX=0**: Geliştirme ×0,7 var, Düzeltme alt aşaması yok (Karar 6 "testçi düzeltmez"); **TESTERFIX=1**: Geliştirme ve Düzeltme ×0,7 (Karar 2 tablosu).

{{T:testci}}

Testçi kapıları, kol kol (kapı 9 ve 10):

{{T:testci_kapi}}

**Okuma.** (1) Düzeltme'yi dışlamak (kol 0) ile dahil etmek (kol 1) arasında teslim, kaçan hata ve boşta farkı gürültü düzeyinde (örnek 25 kişi: 263,0 / 264,0 puan, kaçan/100 puan 1,22 / 1,20). Testçinin Düzeltme yapıp yapmaması ölçülebilir bir şey değiştirmiyor; Karar 6'nın "testçi düzeltmez" cümlesi güvenle tutulabilir. (2) Asıl etki **Geliştirme ×0,7**: testçi boşta kalınca geliştirir. Teslime etkisi küçük: S3 / S4 / S5 / S6'da 48,5 → 49,0, 109,0 → 109,0, 263,5 → 264,0, 514,5 → 514,0; yalnız 5★ testçili 6 kişide 51,0 → 60,0 (+%17,6) ve 5 testçili küçük kartlı S7'de 23,1 → 25,5. Boşta biraz düşer (S3 %15,9 → %11,6). Ama kişi aşama bitene dek işinde kaldığı için geliştirme yapan testçi test açılınca testte olamıyor ve teste kurucu giriyor: 5★ testçili 6 kişide kaçan/100 puan 0,74 → 1,48, bulunan/sprint 2,40 → 1,65. Bu yüzden kapı 9 yalnız "testçi yalnız Test" kolunda geçiyor (−%62 / −%60 / −%60, ×2,3 / ×2,4 / ×2,7); kol 0 ve 1'de 6 kişide −%29 / −%30 ve ×1,9 / ×1,8. (3) Kapı 10 (testçisiz → 3★ testçi: kaçan ≥ %20 azalır) her üç kolda da kalıyor: en iyi kolda (yalnız Test) 12 ve 25 kişide −%15,2 ve −%19,0, öteki kollarda 6 kişide de −%8; D_SIM_v3'te −%25,9 ve −%24,9'du. Testçisiz taban bu turda daha iyi (kaçan/100 puan 6 kişide 2,30 → 1,92), 3★ testçili kol aynı düzeyde; fark nedenini ayrıca ölçmedim. **Öneri:** testçiye varsayılan Geliştirme kutusu verilmesin (Test kutusu yeter) ya da testçinin ikincil işi, test açılınca bırakılsın (bunu PRD "kişi aşama bitene dek kalır" diye yasaklıyor).

## 10. Derinlik kartı tüketimi ve 6 yazılı ad
Bir hatta koşu boyunca açılan derinlik kartı sayısı (9 hat). Oyunun yumuşak tavanı 104 hafta; büyüme eğrisi 130.

{{T:derinlik}}

**Okuma.** 6 ad hat başına yalnız tek kurucuyu karşılıyor. 3 kişide medyan hat 13, 6 kişide 25, 12 kişide 47, 25 kişide 102, 50 kişide 177 derinlik kartı açıyor; en çok kullanılan hat 16 / 28 / 51,5 / 114 / 192. Büyüme eğrisinde (1 → 10 kişi, 130 hf) medyan hat 36. Yani derinlik kartı adı "hat başına 6" değil; PRD'nin "şablon yok, jenerik ad grind hissi verir" ilkesi (#17) ancak adlar hat başına onlarca ve oyuncunun gördüğü sıra karışık olursa tutar. W'nin hedefi için: 12 kişilik ekibin 104 haftasında hat başına 47-52, 25 kişide 100-114 ad ya da adların, aynı işin farklı kapsamları olarak (Toplu fatura: ikinci para birimi, üçüncü, vergi türü...) yeniden kullanılması gerekir. 1 kişilik oyunda bile hatların %14,4'ü 6 adı aşıyor (en çok kullanılan hat medyan koşuda 9, hiçbir koşuda 12'yi geçmiyor).

## 11. Uç karışımlar
Aynı kod ve kurallar; "Eski" D_SIM_v3 kuralı, "R" önerilen okuma.

{{T:uc}}

- **Tek karta 12 kişi** (S12): çekme bu senaryoda kapalı; tek kart kipi kadro kuralını sınar. 12 kişi, sprintte tek kart: teslim 3,5 ve %96,5 boşta (eski kuralda erken kapanışla 11,7 ve %90,3; sabit 2 haftada tek kart 2 haftada biter, bu iki sayı birbirine denk değildir). Kadro kuralı çalışıyor: tek karta 12 kişi hızlandırmıyor, ekip boşta kalıyor.
- Testçi yok (S11, kutu yok) 37,0 teslim ve %86 boşta; geliştiricilere Test kutusu verilince (S11b) 151,5 (eski 162,0). PM yok ekipler çökmüyor (S3 PM'siz 41,0, 30 kişilik S10 295,0). 10 aynı rol ve hepsi testçi karışımları da çökmüyor; kırık karışım boşta kişi olarak görünüyor.

## 12. Kuralların tek tek etkisi ve PRD'nin birebir okuması
Teslim (puan/hf, sınırsız arz): 

{{T:olcek_deliv}}

Açık hata (medyan):

{{T:olcek_open_med}}

MVP haftası (medyan) ve sprintte çekilen kart:

{{T:olcek_mvp}}

{{T:olcek_pulls}}

Kaynaklı arz (hat başına K1, K2, K3 + derinlik + istek):

{{T:kay_deliv}}

**Okuma.**
- **Karar 4'ün eşlemesi (R, atama eski ile):** 25 kişide teslim 264,0 vs 250,0 (+%5,6), 50 kişide 514,0 vs 494,5 (+%3,9); açık hata 10,8 vs 15,8 ve 13,2 vs 22,8. Büyük işe en iyi kişi hem teslimi hem kaliteyi artırıyor. Eski kurala göre (sprint sırası, erken kapanış, çekme yok): 50 kişide 540,0 → 514,0 (−%4,8), 25 kişide 267,5 → 264,0 (−%1,3), 12 kişide 108,0 → 109,0; 1 kişide 5,1 → 4,5.
- **Çekme:** R ile "çekme yok" arasındaki fark yalnız 1 kişide (3,5 → 4,5 puan/hf, boşta %30,8 → %26,4); 3 kişi ve üstünde çekme sprintte ~0 kart çekiyor, çünkü plan %100-123 dolu. Çekme bir güvenlik ağı, ana mekanik değil; ancak plan kasten az dolu bırakıldığında (kalkan) devreye giriyor (aşağıda).
- **Erken kapanış:** yalnız tek kurucuyu etkiliyor (5,3 vs 4,5); öteki ekiplerde sprintler zaten erken bitmiyor.
- **Birebir okuma (R_size):** MVP 3 / 6 / 12 / 25 / 50 kişide 7 / 6 / 4 / 8 / 12. hafta (R: 4, 4, 2, 2, 2), açık hata 13,0 / 19,2 / 23,8 / 23,5 / 21,8 (R: 8,8 / 8,0 / 9,5 / 10,8 / 13,2). Neden: sprint 1,25 × kapasite yüklendiği için büyük kartlar bütün aşama slotlarını tutuyor, MVP'nin K1 kartları ve düzeltme kartları (küçük) devreden kalıp sırada beklemeye devam ediyor. Teslim 6 / 12 kişide R'den biraz iyi (51,8 / 112,0), 3 ve 50 kişide kötü (19,8 / 503,0).
- **Tam birebir (P, kalkanlı):** teslim 3 / 6 / 12 / 25 / 50 kişide 15,4 / 38,5 / 67,0 / 141,5 / 262,0 (R_size'a göre −%22 / −%26 / −%40 / −%46 / −%48), plan doluluğu %34,8 / %51,6 / %44,9 / %37,1 / %34,2, boşta %36,1 / %29,9 / %40,2 / %43,8 / %48,3, çekilen kart 0,62 / 0,45 / 0,55 / 1,05 / 1,90 (çekme devrede ama yetmiyor). Sebep yapısal: bir kartın tasarım → geliştirme → test yolu 2 haftanın büyük kısmını yiyor (bir K1 için yaklaşık 1,6 hafta); aynı sprintte "biter" diyebilen kart ilk dalgadır, ikinci dalga bitmez ve kalkan onu almaz. Bu bir model hatası değil, 2 haftalık sprintte çok aşamalı kartın doğası.
- **R_shield** (R + bitecek-kart kalkanı; yalnız sınırsız arz, 20 tohum, kaynaklı arz koşulmadı) aynı çöküşü yapıyor: teslim S2 / S3 / S4 / S5 / S6'da 15,75 / 39,0 / 70,0 / 157,5 / 281,5 (R: 21,1 / 49,0 / 109,0 / 264,0 / 514,0; −%25 / −%20 / −%36 / −%40 / −%45), plan doluluğu %37,6 / %53,2 / %46,6 / %40,1 / %34,5, boşta %34,9 / %29,2 / %38,3 / %38,2 / %45,3, sprintte çekilen kart 0,53 / 0,45 / 0,53 / 1,58 / 3,03. Kalkan atama kuralını değiştirmeden de aynı çöküşü yaratıyor.

## 13. Kapı tablosu (eski 23 + yeni 5)
Hepsi R okumasıyla (20 tohum; PM adımı 100 tohum). Eşikler PRD §4.1'e göre hizalı. Kapı 22 (EA takımı) PRD §7 gereği ölçülmedi.

{{GATES}}

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
