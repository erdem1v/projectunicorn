# Sprint düzeni · analiz ve öneri
Hazırlayan: yardımcı yönetmenin alt ajanı (Opus), 17 Ekim 2026. Repo kodu değişmedi, Godot koşturulmadı, commit yok.

**Erdem'in sorusu** (`ERDEM_CDQ_CEVAP.md`, Ek, birebir): "ekip büyüdükçe bizim handle edebileceğimiz kart sayısı artar.
Ee, ya bu düzen nasıl olmalı? Bu şu anki sprint düzeni ne kadar doğru kurgulanmış? Bunun da bir analizini istiyorum."

**Girdiler.** Ana girdi `arastirma/R12_SPRINT_DUZENI.md` (bugünkü motorun Python kopyası, oyunlar, gerçek pratik). Model
`D_MODEL_v2.md` §3 ve §4, ölçüm `D_SIM.md` §3, §10, §15. Kod satırları bu oturumda yeniden okundu (`main` @ `f4a623b`,
çalışma ağacı Faz B'nin kirli dosyalarıyla; satırlar bugünkü dosyadandır).

**Bu belgenin yeni ölçümü.** R12 arzı bugünkü motorla ölçtü. Burada aynı soru **D modeliyle** (Erdem'in D1'de onayladığı
kadro ve aşama sırası, ×5 ölçek) ölçüldü: `D_SIM`'in betiği (`scratchpad/dsim/dsim.py`) olduğu gibi, üstüne iki kip:
sonlu katalog (hat başına K1 → K2 → K3, sonraki kademe öncekinin kapanışından sonra aday olur) ve sınırlı aday havuzu
(sonsuz akış ama plan başına en çok P yeni aday). Betik ve çıktı:
`C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/sprint_duzeni/arz.py`
ve aynı klasörde `arz_out.txt` (`python -I ../dsim/dsim.py exec arz.py`, 5 tohum medyanı, ekipler D_SIM'in S1 ile S6'sı,
ekip 0. haftadan tam). Kapı (Ar-Ge, yıldız, lisans) yok; yani katalog gerçekte biraz daha geç biter.

---

## 0. Erdem'e özet
1. Kapasite tarafı doğru kurulmuş: sprintte sabit kart sayısı yok, kaç kart gireceği ekibin gücünden çıkıyor. Bu kalsın.
2. Asıl sorun kart arzı. Her hatta aynı anda tek kart açık ve hatlar K3'te bitiyor. Bugün 9 hat, 27 kart.
3. D modeliyle ölçtüm: 12 kişi kataloğu 11, 25 kişi 9, 50 kişi 7 haftada bitiriyor. Bitene kadar da 12 kişinin %44'ü,
   50 kişinin %81'i boşta. Sonunda 10 kişiye varan bir demo ekibi 130 haftada kataloğun 7 ile 12 katı iş üretir (tahmin).
4. Kart sayısını artırmak için hat yazmak yetmez: sprintte açık kart sayısı hat sayısını geçemiyor. Ekip başına yaklaşık
   bir açık iş kalemi lazım. Öneri: K3'ten sonra her hat birbirine bağlı olmayan "derinlik" kartları açsın, B2B'de
   müşteri isteği kademeyi beklemeden kendi kartı olsun, EA'da modüller gelsin.
5. Lider önerisi D modeline uymuyor: yalnız bu sprintte bitecek kartları alıyor, oysa D'de kart ortalama iki sprint sürer.
   Öneri planın kendi tavanına kadar doldurmalı. Bot da yalnız öneriyi kullanmalı (bugün iki ek kuralı var).
6. 50 kişide oyuncu tek tek kart eklemez: öneri, değiştir, başlat. EA'da takım varsa takım başına bir onay.
7. Takım (ekip başına lider) EA'da, 10 kişiden sonra, oyuncunun isteğiyle kurulur. Tek sprint ritmi, tek kapanış kalır.

---

## 1. Bugünkü düzenin karnesi
| Öğe | Not | Neden (bir cümle) | Kanıt |
|---|---|---|---|
| Sprint uzunluğu (1 ya da 2 hafta, oyuncu seçer) | **Uygun** | Scrum'ın "bir ay ya da kısa" sınırının içinde, yaygın değer 2 hafta; tek süre tek planlama anı demek | `sprint.json:2-3`, `sprint_system.gd:271-277`; R12 §2.3 |
| Kart sayısı sınırı | **Uygun** | Sabit sayı yok: yük kapasitenin %125'ini aşmamalı ve yeni kart sprintte iş almalı; ikisi de oran. Probe'un `cards` alanı (1 ya da 2) oyun kuralı değil | `sprint_system.gd:577-594`, `sprint.json:26`; `sprint_probe.gd:11-13` |
| Kart seçimi (oyuncu, lider önerisi, PM devri) | **Sorunlu** | Öneri yalnız bu sprintte bitecek kartları ve en çok bir devreden kartı alıyor (D'de kart iki sprint sürer); zorunlu listede sabit "en çok bir talep"; plan yetkisi yalnız ilk PM'de | `sprint_catalog.gd:851-858`, `:836`, `:499-504` |
| Bot ile oyuncunun kuralı | **Sorunlu** | Bot öneriye ek olarak söz kartlarını ve B2C'de "yapmaya devam"ı kendisi ekliyor; oyuncunun düğmesi bunu yapmıyor | `run_probe.gd:915-946` (`_plan_promises`, `_keep_building`) |
| Atama (kim hangi karta) | **Sorunlu** (D v2 çözüyor) | Oyuncunun atamaması doğru; ama bir kartın üç aşaması aynı haftanın bütçesine zincirleniyor, rol uymayınca sabit 0,5 hız | `sprint_system.gd:795-826`, `:832`; `sprint.json:25` |
| Kapasite | **Uygun**, D v2 ile **düzelir** | Kişi puanlarının toplamı × hafta, doğrusal ve cezasız; ama kişi aşamadan bağımsız tam puanla sayılıyor | `sprint_system.gd:466-472` |
| Katalog arzı | **Yanlış** | Hat başına tek aday, sonraki kademe kapanıştan sonra görünür; talep kademe kartının yerine geçer, arzı büyütmez; 9 hat 144 puan (×5 ölçekte 720) | `sprint_catalog.gd:224-237`, `:227-234`; `sprint.json:6` |
| Düzeltme kartının yeri | **Sorunlu** | Hat başına bir kart, efor 1 ya da 2, kapanışta hattın bütün hatasını siler; Öncelikli düzeltmeler önerinin zorunlu listesinde, pay tavanı yok | `sprint.json:7`, `sprint_catalog.gd:179-182`, `:238-242`, `:839`; `sprint_system.gd:1054` |
| Plan ekranı | **Uygun** (tahmin), **sorunlu** (ölçek) | Ekran ve kapanış aynı oynatmayı koşuyor (probe 251 kapanışın 245'i eşleşti, 6'sı adlı); ama ekip satırı kişi başına, darboğaz cümlesi yok | `sprint_system.gd:607-628`, `:846-872`; `HARITA.md:153`; R12 §1.8 |
| Sprint içinde kart çekme | **Uygun** | Koşan sprintte "+" kapalı, iş kendiliğinden verilmiyor; D'nin dolu planıyla gerek kalmıyor (§3 K6) | `sprint_system.gd:577-583`; `HARITA.md:153` |
| Takım nesnesi | Demoda **uygun**, EA'da **eksik** | Tek sütun, tek öneri; lider katsayısı işlevleri yazılı ama okuyucusu yok | `hr_constants.gd:1030-1041` |
| 25 ve 50 kişide davranış | **Yanlış** | Sprintte açık kart hat sayısını (9) geçemiyor; D modeliyle 25 kişi %70, 50 kişi %81 boşta, katalog 9 ve 7 haftada biter | §4 tablo 4.1 |

**Doğru kurulanlar kalır:** oransal tavan, plan tahmini = sonuç, oyuncunun kişi atamaması, 1 ya da 2 haftalık tek ritim,
devir ve boş sprint kuralları.

---

## 2. Oyunlardan ve gerçek pratikten ne alıyoruz
| Kaynak | Ne yapıyor | Alıyoruz | Almıyoruz |
|---|---|---|---|
| Scrum Guide | Ekip 10 ve altı; büyürse aynı ürüne birkaç ekip, tek backlog | Tek backlog, takım 10 kişiden sonra | Ekip başına ayrı ürün sahibi zorunluluğu |
| LeSS | 2 ile 8 ekip, tek Product Owner, **tek ortak sprint** | Tek ritim, tek kapanış, takımlar plan ekranında şerit | Planning One ve Two törenleri (oyuncuya tören yükü) |
| Mike Cohn | 7 kişilik ekip sprintte 5 ile 10 kalem (kişi başı 0,7 ile 1,4) | Kart sayısı sonuçtur, kurala yazılmaz | Swarm (bütün ekip tek karta), D'nin kadrosu bunu zaten sınırlar |
| Yesterday's Weather (Scrum Inc.) | Kapasite son üç sprintin hızı | Almıyoruz | Tahmin hıza dayanmaz; bizim tahmin oynatmanın kendisi (deterministik) |
| Kanban Guide | Başlayıp bitmeyen işi sınırla, çek | Aşama tavanı (D v2 §3.11 a) bu işi görür | Sprint içi otomatik çekme (§3 K6) |
| Software Inc. | Takım projeye atanır, 10 ile 12 kişi ideal, lider etkisi takıma | Takım EA'da, lider takımın içinde | Şirket çapında büyüklük cezası (reddedildi) |
| Mad Games Tycoon 2 | Oda = proje; bölmek potansiyeli böler | Takım bölmenin bedeli görünür olsun (kişi takımı dışına geçmez) | Oda ve yol bulma |
| Startup Company | İçerik tükenmesini özellik seviyesi ve bileşen kırılımıyla çözer; 180 kişide tıklama şikâyeti | K3 sonrası derinlik kartı; toplu öneri ve onay | Bileşen ve modül üretim zinciri (kart sayısını değil karmaşayı artırır) |
| Game Dev Tycoon | Tek proje, en çok 9 kişi | Almıyoruz | Büyük şirket modeli yok |

Kaynaklar ve bağlantılar R12 §2, §3'tedir; burada tekrar edilmedi.

---

## 3. Önerilen düzen
Her kural aynı biçimde: kural, neden var, ölçekte neden kırılmaz.

### K1 · Tek ritim
Şirkette tek sprint süresi (1 ya da 2 hafta, oyuncu seçer), tek planlama, tek kapanış, tek sürüm notu. EA'da takımlar
olsa da ritim tektir.
- **Neden var:** oyuncunun haftada bir değil sprintte bir planlama anı olsun; sürüm sayısı (+0,1) sprint başına kalsın;
  plan ekranının tahmini tek oynatmadan çıksın (ilke 5). LeSS'in tek ortak sprinti aynı sebeple var.
- **Ölçek:** takım başına ayrı süre, 7 takımda 7 ayrı planlama anı demek; tek ritim 50 kişide de bir an.

### K2 · Kart sayısı kural değil sonuç
Sprint kartı şu üç şart tuttukça alır, başka sınır yoktur: toplam yük ≤ 1,25 × kapasite (bugünkü), her aşama satırında
yük ≤ 2 × o aşamanın kapasitesi (D v2 §3.11 a), yeni kart bu sprintte iş almalı (bugünkü). Kart "yuvası" yoktur.
- **Neden var:** sabit yuva (3 kişiye 2 kart gibi) ölçekte ya boş kalır ya taşar; oran her boyutta aynı okunur.
  Gerçek pratikte de kalem sayısı kapasiteden çıkar (Cohn).
- **Ölçek:** D modelinde sınırsız arzla sprintteki kart ekip büyüklüğüne yakınsıyor (12 kişi 12, 50 kişi 49), yeni kart
  ekibin yarısı kadar (§4). Kural hiçbir boyutta değişmiyor.

### K3 · Tek öneri, aynı kural (oyuncu, lider, PM, bot)
Öneri, planın kendi alım kuralıyla (K2) doldurur. "Yalnız bu sprintte bitecek kartlar ve en çok bir devreden" kalkar.
Zorunlu sıra: (1) verilmiş sözlerin kartları, son tarihi yakın önde; (2) son tarihi bu ya da sonraki sprint olan
**bütün** talepler (bugün sabit bir tane); (3) bekletilen kartlar (D2'nin "sonraki sprinte atalım" cevabı); (4) Öncelikli
düzeltmeler, düzeltme payı tavanına kadar (D v2 §3.11 b); (5) en zayıf alanın en iyi kartı; (6) etki ÷ iş sırasıyla
kalanlar. B2C ücretli plan (1)'in arkasına girer. Bot öneriyi uygular ve başlatır; ek kuralı olmaz. (inceleme) Bir aday
şartlara (K2) uymazsa öneri durmaz, onu atlar ve sıradaki en çok 12 adaya bakar; böylece büyük bir kartın arkasındaki küçük
kartlar elenmez (`D_MODEL_v3.md` §3.12 b, ölçüm `D_SIM_v3.md` §8.4).
- **Neden var (bitme şartı kalkar):** D'de kart sırayla üç aşamadan geçer, sağlıklı ekipte ortalama 3,5 hafta sürer
  (`D_SIM.md` §10). Yalnız bitecek kartı alan öneri sprinti yarı boş bırakır; oyuncu öneriyi kabul edince sistemin kendi
  sınırına kadar dolmalı.
- **Neden var (talep sayısı oran):** 330 hesaplı bir şirkette aynı anda onlarca talep açık; "en çok bir" sabiti
  tarihi geçen talep üretir.
- **Neden var (bot = oyuncu):** ilke 3 ve ölçüm: botun ek kuralları oyuncunun düğmesinde yoksa ölçtüğümüz oyun
  oynanan oyun değildir. `_plan_promises` zaten (1)'in işi; `_keep_building` (sprint yalnız araştırma kartıyla kalmasın) önerinin kuralı olur.
- **Ölçek:** her basamak ya kapasitenin oranı ya tarih; sabit kart sayısı yok.

### K4 · Oyuncunun planlama yükü
Planlama üç eylemdir: öneriyi uygula, istersen değiştir, başlat. "Planlamayı devret" (PM) kalır ve PM yoksa liderin
önerisiyle aynı işi yapar. "+" ile tek tek ekleme kalır ama gerekmez.
- **Neden var:** 50 kişide sprintte 25 yeni kart (§4). Startup Company'de 180 çalışanla tek tek tıklama en sık şikâyet
  (R2 §4). Oyuncunun kararı kart seçmek değil öncelik ve kadro olmalı.
- **Ölçek:** öneriyle eylem sayısı 1 kişide de 50 kişide de 2 ya da 3; değiştirme isteğe bağlı.

### K5 · Atama otomatik, görünür
Oyuncu karta kişi atamaz. D v2'nin kadrosu (her 8 puanlık iş için en çok bir kişi) ve aşama sırası atamayı yapar; kart
ipucu kimin çalıştığını, avatar satırı kişinin yükünü gösterir (D6).
- **Neden var:** atama oyuncuya bırakılırsa 50 kişide mikro yönetim; otomatik atama deterministik olduğu için tahmin =
  sonuç korunur.
- **Ölçek:** kadro işin büyüklüğünden gelir, ekip büyüklüğünden değil.

### K6 · Sprint içinde otomatik çekme yok
Koşan sprintte iş kendiliğinden verilmez (bugünkü kural). Boşta kalan tasarımcı ve PM önden işe geçer (D v2 §3.7).
Boşta kişi varsa nedeni plan ekranında tek cümle: "kart yok", "aşama dolu", "rol uymuyor".
- **Neden var:** D'nin planı sprinte kapasitenin %125'ine kadar iş koyar; arz yeterken 6 ile 50 kişide boşta %1 ile %6
  (§4). Otomatik çekme yalnız arz yokken gerekir ve o zaman da çekecek kart yoktur. Sorun arzdır, çekme değil.
- Örnek metin: "Planlanacak kart kalmadı: 6 kişi bu sprint boşta." / "No cards left to plan: 6 people are idle this
  sprint."

### K7 · Arz kuralı: plan anında açık aday ≥ 0,75 × ekip (8 kişinin altında ≥ ekip)
Bu bir oyun kuralı değil, içeriğin ve arz kaynaklarının tutması gereken **tasarım hedefidir** (kapı, §5).
- **Neden var:** ölçüm (§4 tablo 4.2): 2 haftalık sprintte boşta payını %8'in altına indirmek için plan başına yaklaşık
  0,75 × ekip yeni aday gerekiyor (12 kişi 9, 25 kişi 19, 50 kişi 38); küçük ekipte sayı küçük olduğu için ekip kadar
  (6 kişi 6; 4 adayda boşta %15). Bugün üst sınır hat sayısı (9; pazaryerinde 14).
- **Kart büyütmek çözmez:** büyük kart hacmi artırır ama sprintteki açık kalem sayısını artırmaz. Sınır eşzamanlılık:
  sonlu katalog kipinde sprintteki kart 9 hatta 8,8'de, 14 hatta 14,2'de duruyor (§4).
- **Hat eklemek tek başına çözmez:** 14 hat 50 kişide boşta payını %81'den %75'e indiriyor.

### K8 · Arz kaynakları (dördü birlikte)
| Kaynak | Ne | Ne zaman | Neden var | Ölçek |
|---|---|---|---|---|
| A. Kademe (bugünkü) | Hat başına K1 → K2 → K3, zincirli | Baştan | Ürünün iskeleti; "temel olmadan ileri özellik olmaz" bağımlılığı gerçek | Hat sayısıyla sınırlı, ekiple büyümez; ilk 6 kişiye yeter |
| B. Derinlik kartları (yeni) | K3'ü biten hat birbirine bağlı olmayan kartlar açar (aynı hatta aynı anda birden çok), boyut 15/25/40 karışık, kazancı alanın puanına küçük ve azalan artış | Hattın K3'ü kapanınca | Gerçek üründe bir alan bitmez, iyileştirme işi birbirinden bağımsızdır; Startup Company'nin seviye çözümünün zincirsiz hâli | Hat başına açık derinlik kartı hattın kullanımına bağlı (B2B: hattı kullanan hesap; B2C: hattın kitle payı), ekibe değil |
| C. Hesap isteği (değişen) | B2B'de istek, hesabın alanında açık kademe yoksa kademe beklemeden hesabın kendi kartı olur; boyut hesabın koltuğuyla | Bugünkü istek penceresi (imzadan sonra ve yenilemeden önce, yılda bir) | İş müşteri sayısıyla doğar; 330 hesap yılda 330 istek demek. Karşılanan istek memnuniyete görünür artı (C v3) | Hesap sayısıyla doğrusal; sabit yok |
| D. Modül ve ikinci ürün (EA) | Yeni hat grupları (E'nin modülleri, ikinci ürün) | EA | Büyük ekip daha geniş yüzey yapar; 50 kişilik şirketin tek 9 hatlı ürünü olmaz | Hat sayısını büyütür, A ve B'yi çoğaltır |

Kurallar:
- **Kazanç görünür, ceza yok.** Derinlik kartının kazancı ürün sayfasında alanın puanı olarak görünür (Q1: ürünün tek
  kalitesi alanlardır). Karşılanmayan hesap isteği düşer ve memnuniyeti düşürmez (C6: "memnuniyet durup dururken
  düşmez"); yalnız söz verilmişse sözün kuralı işler.
- **Azalan kazanç alanın beklentisine göre** (bugün `SprintCatalog.expectation`, `word_for`): beklentinin üstündeki derinlik
  az getirir ve kartın etki satırında öyle yazar. Oyuncu bunu görür, "Büyümeye açık" gibi bir etiket gelmez.
- **Gerekçe yazımı:** kart adı işin kendisidir, gerekçe söylemez. Örnek: "Toplu fatura: ikinci para birimi" / "Bulk
  invoicing: second currency"; "Ege Sigorta isteği: aylık rapor aktarımı" / "Ege Sigorta request: monthly report export".
- **Sürekli iş yok:** bakım ve teknik borç kartı önerilmiyor (reddedilen "sürekli hata sprinti"ne yakın, oyuncunun
  seçmediği iş olur).
- **İçerik bedeli:** B'nin kart adları şablonla (hat × iş türü) ya da elle yazılır; seçim D v3 ve içerik ajanınındır.
  Gerekli hacim §4 tablo 4.3'te.

### K9 · Düzeltme kartlarının yeri
Düzeltme kartı aynı sprint sütununda durur, öneri onları (K3 basamak 4) düzeltme payı tavanına (kapasitenin yarısı, ilk
kart her zaman girer) kadar alır. Testte bulunan hata kartın içinde düzeltilir (R10, D2: "testçiler N hata buldu, M'si
düzeltildi"); düzeltme kartı yalnız canlıda bulunan ve kaçan hata içindir. Sprint sonunda "bu haliyle gönderelim mi"
sorusunda "sonraki sprinte at" denilen kart sonraki planın 3. basamağına girer, kendi kalan işiyle.
- **Neden var:** hata sprinti olmasın (A'nın hedefi, Erdem 16 Ekim); tavan oran olduğu için 2 kişiden sonra neredeyse hiç
  bağlamıyor (`D_SIM.md` §15.3). Bekletilen kartın ayrı kuyruğu olmaz, aynı sütunda görünür.
- **Ölçek:** D5'te A'nın sabit hata sınırları yayındaki özellik grubu sayısına ve teslim edilen işe oranlanıyor; derinlik
  kartları (K8 B) teslimi büyüttükçe sınır da büyür. Düzeltme kartının en çok 10 puan olması (hat başına) büyük ekipte
  hatayı ucuzlatıyor (`D_MODEL_v2.md` inceleme 10); D v3 kartın büyüklüğünü hattın açık hatasına oranlamalı.
- (inceleme) D v3 bunu yaptı: kart hata başına 2 puan ve alt sınırı yok. Sabit "en az 5 puan" 1 haftalık sprintte tek
  kurucunun kapasitesinin (8,6) yarısını aştığı için sprintlerin %50'sini hata sprintine çeviriyordu (`D_SIM_v3.md` §8.6).

### K10 · Takım (ekip başına lider), yalnız EA
- 10 kişiye kadar tek ekip, tek sütun (bugünkü düzen). Demoda takım yok.
- EA'da oyuncu isterse takım kurar: bir lider, kişiler, sahiplendiği alanlar. Takım kurmak zorunlu değil; takımsız kişi
  bugünkü gibi her karta gider.
- Takımdaki kişi yalnız takımının alanlarındaki kartlarda çalışır. Takımın lideri takımın önerisini verir; oyuncu takım
  başına bir onay verir. Ritim, kapanış ve sürüm notu tek kalır (K1).
- Verim kaybı takımın içinde yaşar, takımın büyüklüğüne oranlıdır ve lider onu azaltır (Erdem D1: "ekip büyüdükçe bir verim
  kaybı... her ekip bazında bir lider"). Kayıp takım satırında yazılır. Şirket çapında kayıp yoktur. (inceleme) Kayıp
  yalnız 8. kişiden sonra gelenlerin hızına uygulanır; böylece kişi eklemek ötekileri yavaşlatmaz (`D_MODEL_v3.md` §3.14).
- Örnek satır: "Çekirdek takımı · lider Ayşe · 8 kişi · 6 kart · hız ×1,06 · boşta 2 kişi" / "Core team · lead Ayşe · 8
  people · 6 cards · speed ×1.06 · 2 idle" (inceleme: hız ve boşta eklendi; takımlı düzenin takımsızdan geri kalmasının
  %92 ile %100'ü bu iki sayıdır, `D_SIM_v3.md` §6.5).
- **Neden var:** 50 kişide oyuncu kartı değil takımı yönetmeli (Software Inc. 10 ile 12 kişilik takım, LeSS 2 ile 8 ekip);
  takım bölmenin bedeli (esneklik kaybı) ve kazancı (lider) ikisi de görünür (MGT2'de bölmek potansiyeli böler).
- **Neden kişi takım dışına geçmez:** geçebilseydi takım yalnız bir etiket olurdu; bedeli olmayan seçim seçim değildir.
- **Ölçek:** takım başına kural (büyüklüğe oranlı kayıp, lider çarpanı) 1 takımda da 7 takımda da aynı okunur. Lider
  katsayısının evi bugün okuyucusuz `coordination_for_lead`'dir (`hr_constants.gd:1041`).
- **Alan sayısı yeter mi:** B2B'de 4, B2C'de 5 alan var (`sprint.json:56-62`). 7 takım için alan az; EA'da modüller (K8 D)
  yeni alan getirir. Bir alanı iki takım paylaşabilir mi sorusu D v3'e bırakıldı.

### K11 · Plan ekranı (D6 ile aynı)
Aşama şeridi ve darboğaz cümlesi hep görünür, kart zinciri kartın üstüne gelince, kişi yükü avatar satırında. Ekranlar
oyunun kendi Menajer diliyle gösterilir (Claude Design maketi yok). Bu belgenin eklediği iki şey:
- Arz cümlesi (K6). Boşta nedeni "kart yok" ise cümle bunu söyler ve öneri yazmaz ("işe alma" ya da "hat aç" yazmaz).
- EA'da takım varsa şerit takım başına bir satır, kişi başına satır yok (50 satır sorunu kalkar, `HARITA.md:153`).

---

## 4. Sayılar
D modeli, 2 haftalık sprint, 5 tohum medyanı; ekipler `D_SIM.md`'nin S1 ile S6'sı (kurucu; 3; 6; 12; 25; 50 kişi), ekip 0.
haftadan tam. Kaynak: `scratchpad/sprint_duzeni/arz_out.txt`. Ar-Ge, yıldız ve lisans kapıları yok.

### 4.1 Bugünkü katalogla (sonlu, zincirli)
| Ekip | Katalog biter, 9 hat (hf) | Bitene kadar boşta | Sprintteki kart | Sprintte yeni kart | Katalog biter, 14 hat (hf) | Boşta, 14 hat |
|---|---|---|---|---|---|---|
| 1 | 114 | %13 | 1,5 | 0,4 | 140'tan sonra | %12 |
| 3 | 32 | %20 | 4,1 | 1,7 | 50 | %18 |
| 6 | 16 | %25 | 7,1 | 3,4 | 23 | %17 |
| 12 | 11 | %44 | 8,2 | 4,5 | 14 | %34 |
| 25 | 9 | %70 | 8,6 | 5,4 | 10 | %58 |
| 50 | 7 | %81 | 8,8 | 6,8 | 8 | %75 |

- R12'nin bugünkü motorla ölçümü aynı yönde (12 kişi 8, 25 kişi 5, 50 kişi 3 hafta); D'de kart aşamalardan sırayla geçtiği
  için katalog biraz geç biter ama boşta payı daha yüksek.
- `D_MODEL_v2.md:772` "50 kişilik ekip 60 haftada bugünkü kataloğu tüketir" yanlış: 7 hafta.
- Tek kurucu ve 3 kişinin boşta payı (%13, %20) arzdan değil yapıdan: testi ve tasarımı yalnız kurucu yapıyor
  (`D_SIM.md` §3.1, sınırsız arzda da aynı).

### 4.2 Sınırsız akış, plan başına P yeni aday (21 ile 60. hafta)
| Ekip | P = 3 | P = 6 | P = 9 | P = 14 | P ≈ 0,5 × ekip | P ≈ 0,75 × ekip | P = ekip |
|---|---|---|---|---|---|---|---|
| 6 | %23 | %6 | %5 | %4 | (3) %23 | (4) %15 | (6) %6 |
| 12 | %49 | %24 | %7 | %1 | (6) %24 | (9) %7 | (12) %1 |
| 25 | %78 | %55 | %31 | %12 | (12) %16 | (19) %6 | (25) %1 |
| 50 | %90 | %79 | %67 | %48 | (25) %15 | (38) %8 | (50) %5 |

Hücre: boşta payı (kişi-hafta oranı). Okuma: 6 kişiden büyük ekipte boşta payını %8'in altına indiren en küçük havuz
yaklaşık 0,75 × ekip. Teslim de aynı yerde tavana varır (50 kişi P = 38'de haftada 484, P = 50'de 498 puan).

### 4.3 Ekip başına beklenen değerler (önerilen düzen, arz K7'yi tuttuğunda)
| Ekip | Sprintte kart | Sprintte yeni kart | Gereken açık aday (plan başına) | Boşta | İş ihtiyacı (puan/hafta) | Katalog (720) kaç haftada biter | Planlama eylemi: elle / öneriyle / devirle / EA takımla |
|---|---|---|---|---|---|---|---|
| 1 | 1,5 | 0,4 | 1 | %10 (yapısal) | 6 | 114 | 2 / 2 / 0 / yok |
| 3 | 3,8 | 1,1 | 3 | %17 (yapısal) | 23 | 32 | 2 / 2 / 0 / yok |
| 6 | 6,5 | 2,7 | 6 | %6 | 55 | 16 | 4 / 2 / 0 / yok |
| 12 | 12,3 | 5,8 | 9 | %1 ile %7 | 116 | 11 | 7 / 2 / 0 / 2 (tahmin, 1 ile 2 takım) |
| 25 | 26 | 12,9 | 19 | %1 ile %6 | 258 | 9 | 14 / 2 / 0 / 4 (tahmin, 3 takım) |
| 50 | 49 | 24,9 | 38 | %5 ile %8 | 498 | 7 | 26 / 2 / 0 / 7 (tahmin, 6 takım) |

- "Elle" = yeni kart sayısı kadar "+" ve bir "başlat". "Öneriyle" = uygula ve başlat; değiştirme isteğe bağlı.
  "Devirle" = PM ya da lider planlar, oyuncu dokunmaz. "EA takımla" = takım başına bir onay ve başlat.
- **Hacim ihtiyacı (tahmin):** bir yılda (52 hafta) 6 kişi yaklaşık 2 900, 12 kişi 6 000, 25 kişi 13 400, 50 kişi 25 900 puan
  iş ister. Bugünkü katalog 720, pazaryeri 1 165, ERP 1 005 puan (×5 ölçekte, `PRD_URUN_DERINLIK.md:230`, `:483`).
  Varsayılan bir demo eğrisiyle (0-12. hafta 1, 12-30 3, 30-60 6, 60-130 10 kişi; **tahmin**) 130 haftada yaklaşık
  8 800 puan, kataloğun 7 ile 12 katı. Yazılı kademe içeriği bunu karşılayamaz; K8'in B ve C kaynakları bu yüzden var.
- **Kart sayısıyla:** ortalama biten kart 19 ile 33 puan (`D_SIM.md` §10'dan hesap). 12 kişi yılda yaklaşık 200, 50 kişi
  yaklaşık 800 kart bitirir (tahmin).
- **Hesap isteğinin payı (tahmin):** yılda hesap başına bir istek, ortalama 20 puan. 40 hesap haftada 15 puan (1,5 kişinin
  işi), 330 hesap haftada 130 puan (yaklaşık 13 kişinin işi). B2B'de arzın önemli bir kısmı, tek başına yetmez; derinlik
  kartları (K8 B) taban arzdır.

---

## 5. D v3'e devredilenler ve simülasyon kapıları

### 5.1 D v3'ün modele işleyeceği maddeler
1. **Öneri kuralı (K3):** bitme şartı ve "en çok bir devreden" kalkar; zorunlu sıra altı basamak; talepler tarihe göre
   hepsi; bot yalnız öneri. `sprint_catalog.gd:820-862` ve `run_probe.gd:915-946`'nın yerini alır.
2. **Arz (K7, K8):** derinlik kartlarının açılma kuralı (hattın kullanımına oranlı açık kart sayısı), boyut karışımı,
   kazancın alan puanına azalan katkısı; hesap isteğinin kademe yokken kendi kartı olması ve boyutu. C v3 ile birlikte:
   karşılanan isteğin memnuniyete katkısı, karşılanmayanın etkisiz düşmesi.
3. **Düzeltme (K9):** bekletilen kartın sıradaki yeri (basamak 3); düzeltme kartının büyüklüğünün hattın açık hatasına
   oranlanması (bugün en çok 10 puan); D5'in oranlı hata sınırlarıyla birlikte.
4. **Takım (K10, EA):** takım nesnesi, kişinin takım dışına geçmemesi, takım içi kayıp (büyüklüğe oran, lider çarpanı),
   takım başına öneri, plan şeridinin takım satırı. Bir alanı iki takımın paylaşıp paylaşamayacağı.
5. **Arz cümlesi (K6, K11):** "kart yok" nedeninin darboğaz cümlesine eklenmesi.
6. **`D_MODEL_v2.md:772` düzeltmesi:** "60 hafta" değil 7 hafta (9 hat, kapısız). §4.2'nin 25 ve 50 kişi satırları
   sınırsız arza dayanır; D v3 bunları K7'yi tutan arzla yeniden ölçer.
7. **Plan hesabının maliyeti:** her "+" ve öneri, kartları kopyalayıp oynatıyor (`sprint_system.gd:586-594`); 50 kişi ve
   50 kartta Godot'ta ölçülmedi (R12 P11).

### 5.2 Simülasyonun sınayacağı ölçütler
Bileşimler: 1, 3, 6, 12, 25, 50 kişi; uç bileşimler (hepsi testçi, aynı rolde 10 kişi, küçük karta çok kişi, PM'siz,
testçisiz); EA için 50 kişi 1, 3 ve 7 takım. 20 tohum, 130 hafta, ekip bir büyüme eğrisiyle (0. haftadan tam değil).

| Kapı | Ölçü | Hedef |
|---|---|---|
| `arz_havuzu` | Plan anında açık aday ÷ ekip | Sprintlerin en az %90'ında ≥ 0,75 (8 kişinin altında ≥ 1) |
| `bosta_nedenli` | Boşta payı | ≤ %10; değilse her sprintte nedeni yazılı (kart yok, aşama dolu, rol uymuyor) |
| `kart_yok_sprinti` | "Planlanacak kart kalmadı" sprinti, demo eğrisi | 130 haftada sprintlerin ≤ %5'i |
| `oneri_dolulugu` | Önerinin aldığı iş ÷ planın alabileceği iş (K2) | ≥ %95; bot ile öneri aynı kart kümesi (fark 0) |
| `tahmin_sonuc` | Adsız uyuşmazlık | 0 (bugünkü kural) |
| `planlama_eylemi` | Sprint başına oyuncu eylemi, öneriyle | ≤ 3, her boyutta |
| `duzeltme_payi` | 2 kişi ve üstünde pay; hata sprinti | (inceleme) A'nın hedefleri: erken ≤ %30, geç ≤ %20, hata sprinti (pay > %50) ≤ %5, üst üste yok; tek kurucu erken ≤ %50, geç hata sprinti ≤ %5 (`D_MODEL_v3.md` §6.12 kapı 6; `PRD_FAZ_A_HATALAR.md` §4.4). Taslaktaki "pay ≤ %12, hata sprinti 0" A ile çelişiyordu |
| `derinlik_kazanci` | Beklentinin üstündeki derinlik kartının alan puanına katkısı | Azalan; aynı alana art arda 5 kart, ilk karttan en az 3 kat az katkı (sayı D v3'te) |
| `istek_payi` | B2B arzında hesap isteklerinin payı, 100 ve 330 hesapta | Ölçülür ve raporlanır (hedef değil) |
| `takim_bolme` (EA) | 50 kişi, 1 / 3 / 7 takım, liderli ve lidersiz | Liderli takımlar teslimde tek takımdan geri kalmaz ya da farkı takım satırında yazılı; kişi eklemek teslimi düşürmez (tolerans −1) |
| `plan_suresi` | 50 kişi, 50 kart, bir "+" ve bir öneri hesabı (Godot, D0'da) | Hedef D0'da konur (bugün ölçü yok) |

---

## 6. Erdem'e sorular
1. **K3'ten sonra ne olsun?** Öneri: hat birbirine bağlı olmayan derinlik kartları açsın (kazancı alanın puanında görünür,
   beklentinin üstünde azalır), B2B'de istek kademe yokken hesabın kendi kartı olsun, EA'da modüller gelsin. Alternatif:
   katalog biter, ekip Ar-Ge ve Destek'e kayar. Bu dürüst ama 12 kişiden büyük ekipte oyunun yarısı boşta geçer (§4.1).
2. **Lider önerisi D'ye göre değişsin mi?** Öneri: evet. Öneri planın tavanına kadar doldurur, bot yalnız öneriyi kullanır,
   tarihi yaklaşan bütün talepler zorunlu listeye girer. Bedel: oyuncu öneriyi kabul edince sprintte devreden kart artar
   (D'de zaten olağan, kart ortalama iki sprint).
3. **EA'da takımdaki kişi takımının dışındaki karta geçebilsin mi?** Öneri: hayır. Takım kurmak isteğe bağlı; kuran oyuncu
   lider kazancını alır, esneklik kaybını öder ve ikisini de takım satırında görür. Geçebilirse takım yalnız etiket olur.

---

## Hacim (saat)
| Dilim | Ne | Bedel |
|---|---|---|
| S0 | D v3'e işleme (bu belgenin §5.1 maddeleri, model metni) | 2 sa |
| S1 | Simülasyon: büyüme eğrisi, sonlu ve kaynaklı arz, §5.2 kapıları | 3 sa |
| S2 | Öneri kuralı ve bot (K3), D2 ile aynı dilimde | 2,5 sa |
| S3 | Derinlik kartları (K8 B): kural, veri, kart adları şablonu, TR/EN | 5 sa (yazım hariç) |
| S4 | Hesap isteği (K8 C), C v3 ile | 2 sa |
| S5 | Arz cümlesi ve plan ekranı ekleri (K6, K11), D6 ile | 1 sa |
| S6 | EA takım (K10): nesne, atama, kayıp, öneri, şerit | 10 ile 14 sa |

- Demo için S0 ile S5: yaklaşık 15 saat, D'nin 30 ile 35 saatlik bütçesinin üstüne. S6 EA'dadır.
- Kart adı yazımı (derinlik ve istek kartları, iki dil) içerik ajanının işidir; hacmi şablonun seçimine bağlı.
- Bu belge: okuma, kod doğrulaması, ölçüm ve yazım, yaklaşık 2 saat.

---

## İnceleme notu (Opus)
Kıdemli inceleme, 17 Ekim 2026 gecesi. Ne değişti, neden:
1. K3: öneri uymayan adayı atlar (en çok 12 aday). Neden: "tavana kadar doldurur" ile "ilk uymayanda durur" çelişiyordu;
   ölçümde öneri doluluğu %77 ile %95'te kaldı (`D_SIM_v3.md` §8.4).
2. K9: düzeltme kartının alt sınırı (5 puan) kalktı. Neden: 1 haftalık sprintte tek kurucuda sprintlerin %50'si hata
   sprintiydi; reddedilen "sürekli hata sprinti"ne düşüyordu (`D_SIM_v3.md` §8.6).
3. K10: takım kaybı marjinal, takım satırı hız ve boşta kişiyi yazar. Neden: kişi eklemek takımı 2,9 puana kadar
   yavaşlatıyordu; takımın geride kalma nedeni satırda görünmüyordu (`D_SIM_v3.md` §8.5).
4. §5.2 `duzeltme_payi`: hedef A'nın ve D v3'ün hedefine bağlandı (taslaktaki %12 ve "hata sprinti 0" A ile çelişiyordu).
5. Değişmeyen: §4'ün sayıları v2 modeliyle ölçüldü; v3 modeliyle katalog 12 kişide 12, 3 kişide 37 haftada biter
   (`D_SIM_v3.md` §6.4). Yön aynı, sonuç aynı. Derinlik kartının sayısı D v3'te ÷ 5, en çok 8 oldu (`D_MODEL_v3.md` §3.13).
